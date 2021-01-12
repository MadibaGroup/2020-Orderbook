"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.timeout = timeout;
exports.delay = delay;

function timeout(promise, millis) {
  return new Promise(function (resolve, reject) {
    var timeoutId = setTimeout(function () {
      return reject(new Error('operation timed out'));
    }, millis);
    promise.then(function (result) {
      clearTimeout(timeoutId);
      resolve(result);
    });
  });
}

function delay(millis) {
  return new Promise(function (resolve) {
    setTimeout(resolve, millis);
  });
}