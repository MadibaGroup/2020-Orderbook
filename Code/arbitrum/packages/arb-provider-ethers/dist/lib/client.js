/*
 * Copyright 2019-2020, Offchain Labs, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
/* eslint-env browser */
'use strict';
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    Object.defineProperty(o, k2, { enumerable: true, get: function() { return m[k]; } });
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g;
    return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (_) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ArbClient = void 0;
var ArbValue = __importStar(require("./value"));
var ethers = __importStar(require("ethers"));
var NAMESPACE = 'Aggregator';
// TODO remove this dep
var jaysonBrowserClient = require('jayson/lib/client/browser'); // eslint-disable-line @typescript-eslint/no-var-requires
/* eslint-disable no-alert, @typescript-eslint/no-explicit-any */
function _arbClient(managerAddress) {
    /* eslint-disable no-alert, @typescript-eslint/no-explicit-any */
    var callServer = function (request, callback) {
        var options = {
            body: request,
            headers: {
                'Content-Type': 'application/json',
            },
            method: 'POST',
        };
        fetch(managerAddress, options)
            /* eslint-disable no-alert, @typescript-eslint/no-explicit-any */
            .then(function (res) {
            return res.text();
        })
            .then(function (text) {
            callback(null, text);
        })
            .catch(function (err) {
            callback(err);
        });
    };
    return jaysonBrowserClient(callServer, {});
}
function convertBlockTag(tag) {
    if (tag === undefined || typeof tag == 'string') {
        return tag;
    }
    return ethers.utils.bigNumberify(tag).toHexString();
}
function convertTopics(topicGroups) {
    if (topicGroups == undefined) {
        return topicGroups;
    }
    return topicGroups.map(function (topics) {
        if (typeof topics == 'string') {
            return { topics: [topics] };
        }
        else {
            return { topics: topics };
        }
    });
}
var ArbClient = /** @class */ (function () {
    function ArbClient(managerUrl) {
        this.client = _arbClient(managerUrl);
    }
    ArbClient.prototype.sendTransaction = function (signedTransaction) {
        return __awaiter(this, void 0, void 0, function () {
            var _this = this;
            return __generator(this, function (_a) {
                return [2 /*return*/, new Promise(function (resolve, reject) {
                        var params = { signedTransaction: signedTransaction };
                        _this.client.request(NAMESPACE + ".SendTransaction", [params], function (err, error, result) {
                            if (err) {
                                reject(err);
                            }
                            else if (error) {
                                reject(error);
                            }
                            else {
                                resolve(result.transactionHash);
                            }
                        });
                    })];
            });
        });
    };
    ArbClient.prototype.getBlockCount = function () {
        return __awaiter(this, void 0, void 0, function () {
            var params;
            var _this = this;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        params = {};
                        return [4 /*yield*/, new Promise(function (resolve, reject) {
                                _this.client.request(NAMESPACE + ".GetBlockCount", [params], function (err, error, result) {
                                    if (err) {
                                        reject(err);
                                    }
                                    else if (error) {
                                        reject(error);
                                    }
                                    else {
                                        resolve(result.height);
                                    }
                                });
                            })];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    ArbClient.prototype.getOutputMessage = function (index) {
        return __awaiter(this, void 0, void 0, function () {
            var params, msgResult;
            var _this = this;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        params = { index: index };
                        return [4 /*yield*/, new Promise(function (resolve, reject) {
                                _this.client.request(NAMESPACE + ".GetOutputMessage", [params], function (err, error, result) {
                                    if (err) {
                                        reject(err);
                                    }
                                    else if (error) {
                                        reject(error);
                                    }
                                    else {
                                        resolve(result);
                                    }
                                });
                            })];
                    case 1:
                        msgResult = _a.sent();
                        if (msgResult.rawVal === undefined) {
                            throw Error("reply didn't contain output");
                        }
                        return [2 /*return*/, {
                                outputMsg: ArbValue.unmarshal(msgResult.rawVal),
                            }];
                }
            });
        });
    };
    ArbClient.prototype.getRequestResult = function (txHash) {
        return __awaiter(this, void 0, void 0, function () {
            var params, messageResult;
            var _this = this;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        params = {
                            txHash: txHash,
                        };
                        return [4 /*yield*/, new Promise(function (resolve, reject) {
                                _this.client.request(NAMESPACE + ".GetRequestResult", [params], function (err, error, result) {
                                    if (err) {
                                        reject(err);
                                    }
                                    else if (error) {
                                        reject(error);
                                    }
                                    else {
                                        resolve(result);
                                    }
                                });
                            })];
                    case 1:
                        messageResult = _a.sent();
                        if (messageResult.rawVal === undefined) {
                            return [2 /*return*/, null];
                        }
                        return [2 /*return*/, ArbValue.unmarshal(messageResult.rawVal)];
                }
            });
        });
    };
    ArbClient.prototype._call = function (callFunc, l2Call, sender) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            var params = {
                data: ethers.utils.hexlify(l2Call.asData()),
                sender: sender,
            };
            _this.client.request(callFunc, [params], function (err, error, result) {
                if (err) {
                    reject(err);
                }
                else if (error) {
                    reject(error);
                }
                else {
                    if (result.rawVal === undefined) {
                        resolve(undefined);
                    }
                    else {
                        resolve(ArbValue.unmarshal(result.rawVal));
                    }
                }
            });
        });
    };
    ArbClient.prototype.call = function (tx, sender) {
        return this._call(NAMESPACE + ".Call", tx, sender);
    };
    ArbClient.prototype.pendingCall = function (tx, sender) {
        return this._call(NAMESPACE + ".PendingCall", tx, sender);
    };
    ArbClient.prototype.findLogs = function (filter) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            var addresses = [];
            if (filter.address !== undefined) {
                addresses.push(filter.address);
            }
            var params = {
                addresses: addresses,
                fromHeight: convertBlockTag(filter.fromBlock),
                toHeight: convertBlockTag(filter.toBlock),
                topicGroups: convertTopics(filter.topics),
            };
            return _this.client.request(NAMESPACE + ".FindLogs", [params], function (err, error, result) {
                if (err) {
                    reject(err);
                }
                else if (error) {
                    reject(error);
                }
                else {
                    resolve(result.logs);
                }
            });
        });
    };
    ArbClient.prototype.getChainAddress = function () {
        var _this = this;
        var params = {};
        return new Promise(function (resolve, reject) {
            _this.client.request(NAMESPACE + ".GetChainAddress", [params], function (err, error, result) {
                if (err) {
                    reject(err);
                }
                else if (error) {
                    reject(error);
                }
                else {
                    resolve(result.chainAddress);
                }
            });
        });
    };
    return ArbClient;
}());
exports.ArbClient = ArbClient;
