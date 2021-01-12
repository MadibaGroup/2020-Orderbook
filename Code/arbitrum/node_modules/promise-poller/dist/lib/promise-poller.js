"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = promisePoller;
exports.CANCEL_TOKEN = void 0;

var _debug = _interopRequireDefault(require("debug"));

var _strategies = _interopRequireDefault(require("./strategies"));

var _util = require("./util");

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

var debugMessage = (0, _debug.default)('promisePoller');
var DEFAULTS = {
  strategy: 'fixed-interval',
  retries: 5,
  shouldContinue: function shouldContinue(err) {
    return !!err;
  }
};
var pollerCount = 0;
var CANCEL_TOKEN = {};
exports.CANCEL_TOKEN = CANCEL_TOKEN;

function promisePoller() {
  var options = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : {};

  function debug(message) {
    debugMessage("(".concat(options.name, "): ").concat(message));
  }

  if (typeof options.taskFn !== 'function') {
    throw new Error('No taskFn function specified in options');
  }

  options = Object.assign({}, DEFAULTS, options);
  options.name = options.name || "Poller-".concat(pollerCount++);
  debug("Creating a promise poller \"".concat(options.name, "\" with interval=").concat(options.interval, ", retries=").concat(options.retries));

  if (!_strategies.default[options.strategy]) {
    throw new Error("Invalid strategy \"".concat(options.strategy, "\". Valid strategies are ").concat(Object.keys(_strategies.default)));
  }

  var strategy = _strategies.default[options.strategy];
  debug("Using strategy \"".concat(options.strategy, "\"."));
  var strategyDefaults = strategy.defaults;
  Object.keys(strategyDefaults).forEach(function (option) {
    return options[option] = options[option] || strategyDefaults[option];
  });
  debug('Options:');
  Object.keys(options).forEach(function (option) {
    debug("    \"".concat(option, "\": ").concat(options[option]));
  });
  return new Promise(function (resolve, reject) {
    var polling = true;
    var retriesRemaining = options.retries;
    var rejections = [];
    var timeoutId = null;

    if (options.masterTimeout) {
      debug("Using master timeout of ".concat(options.masterTimeout, " ms."));
      timeoutId = setTimeout(function () {
        debug('Master timeout reached. Rejecting master promise.');
        polling = false;
        reject('master timeout');
      }, options.masterTimeout);
    }

    function poll() {
      var task = options.taskFn();

      if (task === false) {
        task = Promise.reject('Cancelled');
        debug('Task function returned false, canceling.');
        reject(rejections);
        polling = false;
      }

      var taskPromise = Promise.resolve(task);

      if (options.timeout) {
        taskPromise = (0, _util.timeout)(taskPromise, options.timeout);
      }

      taskPromise.then(function (result) {
        debug('Poll succeeded. Resolving master promise.');

        if (options.shouldContinue(null, result)) {
          debug('shouldContinue returned true. Retrying.');
          var nextInterval = strategy.getNextInterval(options.retries - retriesRemaining, options);
          debug("Waiting ".concat(nextInterval, "ms to try again."));
          (0, _util.delay)(nextInterval).then(poll);
        } else {
          if (timeoutId !== null) {
            clearTimeout(timeoutId);
          }

          resolve(result);
        }
      }, function (err) {
        if (err === CANCEL_TOKEN) {
          debug('Task promise rejected with CANCEL_TOKEN, canceling.');
          reject(rejections);
          polling = false;
        }

        rejections.push(err);

        if (typeof options.progressCallback === 'function') {
          options.progressCallback(retriesRemaining, err);
        }

        if (! --retriesRemaining || !options.shouldContinue(err)) {
          debug('Maximum retries reached. Rejecting master promise.');
          reject(rejections);
        } else if (polling) {
          debug("Poll failed. ".concat(retriesRemaining, " retries remaining."));
          var nextInterval = strategy.getNextInterval(options.retries - retriesRemaining, options);
          debug("Waiting ".concat(nextInterval, "ms to try again."));
          (0, _util.delay)(nextInterval).then(poll);
        }
      });
    }

    poll();
  });
}