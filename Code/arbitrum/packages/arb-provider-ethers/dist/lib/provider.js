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
 * distributed under the License is distributed on afn "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
/* eslint-env node */
'use strict';
var __extends = (this && this.__extends) || (function () {
    var extendStatics = function (d, b) {
        extendStatics = Object.setPrototypeOf ||
            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
            function (d, b) { for (var p in b) if (Object.prototype.hasOwnProperty.call(b, p)) d[p] = b[p]; };
        return extendStatics(d, b);
    };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
var __assign = (this && this.__assign) || function () {
    __assign = Object.assign || function(t) {
        for (var s, i = 1, n = arguments.length; i < n; i++) {
            s = arguments[i];
            for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p))
                t[p] = s[p];
        }
        return t;
    };
    return __assign.apply(this, arguments);
};
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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ArbProvider = void 0;
var message_1 = require("./message");
var client_1 = require("./client");
var wallet_1 = require("./wallet");
var ethers = __importStar(require("ethers"));
var promise_poller_1 = __importDefault(require("promise-poller"));
var ArbRollupFactory_1 = require("./abi/ArbRollupFactory");
var GlobalInboxFactory_1 = require("./abi/GlobalInboxFactory");
var ArbSysFactory_1 = require("./abi/ArbSysFactory");
var ArbInfoFactory_1 = require("./abi/ArbInfoFactory");
// EthBridge event names
var EB_EVENT_CDA = 'RollupAsserted';
var MessageDelivered = 'MessageDelivered';
var ARB_SYS_ADDRESS = '0x0000000000000000000000000000000000000064';
var ARB_INFO_ADDRESS = '0x0000000000000000000000000000000000000065';
function getL2Tx(incoming) {
    if (incoming.msg.kind != message_1.MessageCode.L2) {
        throw Error('Can only call getTransaction on an L2 message');
    }
    if (incoming.msg.message.kind == message_1.L2MessageCode.SignedTransaction) {
        return incoming.msg.message.tx;
    }
    else if (incoming.msg.message.kind == message_1.L2MessageCode.Transaction) {
        return incoming.msg.message;
    }
    else {
        throw Error('Invalid l2 subtype');
    }
}
var ArbProvider = /** @class */ (function (_super) {
    __extends(ArbProvider, _super);
    function ArbProvider(aggregatorUrl, provider, chainAddress) {
        var _this = this;
        var client = new client_1.ArbClient(aggregatorUrl);
        if (!chainAddress) {
            chainAddress = client.getChainAddress();
        }
        var network;
        if (typeof chainAddress == 'string') {
            var chainId = ethers.utils
                .bigNumberify(ethers.utils.hexDataSlice(chainAddress, 14))
                .toNumber();
            network = {
                chainId: chainId,
                name: 'arbitrum',
            };
            var origChainAddress_1 = chainAddress;
            chainAddress = new Promise(function (resolve) {
                resolve(origChainAddress_1);
            });
        }
        else {
            network = chainAddress.then(function (addr) {
                var chainId = ethers.utils
                    .bigNumberify(ethers.utils.hexDataSlice(addr, 14))
                    .toNumber();
                var network = {
                    chainId: chainId,
                    name: 'arbitrum',
                };
                return network;
            });
        }
        _this = _super.call(this, network) || this;
        _this.chainAddress = chainAddress;
        _this.ethProvider = provider;
        _this.client = new client_1.ArbClient(aggregatorUrl);
        return _this;
    }
    ArbProvider.prototype.arbRollupConn = function () {
        return __awaiter(this, void 0, void 0, function () {
            var arbRollup, _a, _b;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        if (!!this.arbRollupCache) return [3 /*break*/, 2];
                        _b = (_a = ArbRollupFactory_1.ArbRollupFactory).connect;
                        return [4 /*yield*/, this.chainAddress];
                    case 1:
                        arbRollup = _b.apply(_a, [_c.sent(), this.ethProvider]);
                        this.arbRollupCache = arbRollup;
                        return [2 /*return*/, arbRollup];
                    case 2: return [2 /*return*/, this.arbRollupCache];
                }
            });
        });
    };
    ArbProvider.prototype.globalInboxConn = function () {
        return __awaiter(this, void 0, void 0, function () {
            var arbRollup, globalInboxAddress, globalInbox;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        if (!!this.globalInboxCache) return [3 /*break*/, 3];
                        return [4 /*yield*/, this.arbRollupConn()];
                    case 1:
                        arbRollup = _a.sent();
                        return [4 /*yield*/, arbRollup.globalInbox()];
                    case 2:
                        globalInboxAddress = _a.sent();
                        globalInbox = GlobalInboxFactory_1.GlobalInboxFactory.connect(globalInboxAddress, this.ethProvider);
                        this.globalInboxCache = globalInbox;
                        return [2 /*return*/, globalInbox];
                    case 3: return [2 /*return*/, this.globalInboxCache];
                }
            });
        });
    };
    ArbProvider.prototype.getArbSys = function () {
        return ArbSysFactory_1.ArbSysFactory.connect(ARB_SYS_ADDRESS, this);
    };
    ArbProvider.prototype.getSigner = function (index) {
        return new wallet_1.ArbWallet(this.ethProvider.getSigner(index), this);
    };
    ArbProvider.prototype.getArbTxId = function (ethReceipt) {
        return __awaiter(this, void 0, void 0, function () {
            var globalInbox, logs, _i, logs_1, log;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this.globalInboxConn()];
                    case 1:
                        globalInbox = _a.sent();
                        if (ethReceipt.logs) {
                            logs = ethReceipt.logs.map(function (log) {
                                return globalInbox.interface.parseLog(log);
                            });
                            for (_i = 0, logs_1 = logs; _i < logs_1.length; _i++) {
                                log = logs_1[_i];
                                if (!log) {
                                    continue;
                                }
                                if (log.name == MessageDelivered) {
                                    return [2 /*return*/, ethers.utils.hexZeroPad(ethers.utils.hexlify(log.values.inboxSeqNum), 32)];
                                }
                            }
                        }
                        return [2 /*return*/, null];
                }
            });
        });
    };
    ArbProvider.prototype.getPaymentMessage = function (index) {
        return __awaiter(this, void 0, void 0, function () {
            var results;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this.client.getOutputMessage(index)];
                    case 1:
                        results = _a.sent();
                        return [2 /*return*/, {
                                value: results.outputMsg,
                            }];
                }
            });
        });
    };
    ArbProvider.prototype.getMessageResult = function (txHash) {
        return __awaiter(this, void 0, void 0, function () {
            var arbTxHash, ethReceipt, arbTxId, log, result, txHashCheck;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this.ethProvider.getTransactionReceipt(txHash)];
                    case 1:
                        ethReceipt = _a.sent();
                        if (!ethReceipt) return [3 /*break*/, 3];
                        return [4 /*yield*/, this.getArbTxId(ethReceipt)];
                    case 2:
                        arbTxId = _a.sent();
                        if (!arbTxId) {
                            // If the Ethereum transaction wasn't actually a message send, the input data was bad
                            return [2 /*return*/, null];
                        }
                        arbTxHash = arbTxId;
                        return [3 /*break*/, 4];
                    case 3:
                        arbTxHash = txHash;
                        _a.label = 4;
                    case 4: return [4 /*yield*/, this.client.getRequestResult(arbTxHash)];
                    case 5:
                        log = _a.sent();
                        if (!log) {
                            return [2 /*return*/, null];
                        }
                        result = message_1.Result.fromValue(log);
                        txHashCheck = result.incoming.messageID();
                        // Check txHashCheck matches txHash
                        if (arbTxHash !== txHashCheck) {
                            throw Error('txHash did not match its queried transaction ' +
                                arbTxHash +
                                ' ' +
                                txHashCheck);
                        }
                        // Optionally check if the log was actually included in an assertion
                        // const validateLogs = false
                        // if (validateLogs) {
                        //   const assertionTxHash = ''
                        //   let proof: AVMProof
                        //   await this.verifyDisputableAssertion(assertionTxHash, log, proof)
                        // }
                        return [2 /*return*/, result];
                }
            });
        });
    };
    // This should return a Promise (and may throw errors)
    // method is the method name (e.g. getBalance) and params is an
    // object with normalized values passed in, depending on the method
    // eslint-disable-next-line @typescript-eslint/no-explicit-any, @typescript-eslint/explicit-module-boundary-types
    ArbProvider.prototype.perform = function (method, params) {
        return __awaiter(this, void 0, void 0, function () {
            var _a, arbInfo, arbsys, count, result, currentBlockNum, messageBlockNum, confirmations, block, incoming, msg, contractAddress, status_1, logs, logIndex, _i, _b, log, txReceipt, getMessageRequest, arbInfo, tx, result;
            var _this = this;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        _a = method;
                        switch (_a) {
                            case 'getCode': return [3 /*break*/, 1];
                            case 'getTransactionCount': return [3 /*break*/, 2];
                            case 'getTransactionReceipt': return [3 /*break*/, 4];
                            case 'getTransaction': return [3 /*break*/, 8];
                            case 'getLogs': return [3 /*break*/, 9];
                            case 'getBalance': return [3 /*break*/, 10];
                            case 'getBlockNumber': return [3 /*break*/, 11];
                            case 'estimateGas': return [3 /*break*/, 12];
                            case 'getGasPrice': return [3 /*break*/, 14];
                            case 'sendTransaction': return [3 /*break*/, 15];
                        }
                        return [3 /*break*/, 16];
                    case 1:
                        {
                            if (params.address == ARB_SYS_ADDRESS ||
                                params.address == ARB_INFO_ADDRESS) {
                                return [2 /*return*/, '0x100'];
                            }
                            arbInfo = ArbInfoFactory_1.ArbInfoFactory.connect(ARB_INFO_ADDRESS, this);
                            return [2 /*return*/, arbInfo.getCode(params.address)];
                        }
                        _c.label = 2;
                    case 2:
                        arbsys = this.getArbSys();
                        return [4 /*yield*/, arbsys.getTransactionCount(params.address)];
                    case 3:
                        count = _c.sent();
                        return [2 /*return*/, count.toNumber()];
                    case 4: return [4 /*yield*/, this.getMessageResult(params.transactionHash)];
                    case 5:
                        result = _c.sent();
                        if (!result) {
                            return [2 /*return*/, null];
                        }
                        return [4 /*yield*/, this.ethProvider.getBlockNumber()];
                    case 6:
                        currentBlockNum = _c.sent();
                        messageBlockNum = result.incoming.blockNumber.toNumber();
                        confirmations = currentBlockNum - messageBlockNum + 1;
                        return [4 /*yield*/, this.ethProvider.getBlock(messageBlockNum)];
                    case 7:
                        block = _c.sent();
                        incoming = result.incoming;
                        msg = getL2Tx(incoming);
                        contractAddress = undefined;
                        if (ethers.utils.hexStripZeros(msg.destAddress) == '0x0') {
                            contractAddress = ethers.utils.hexlify(result.returnData.slice(12));
                        }
                        status_1 = 0;
                        logs = [];
                        if (result.resultCode === message_1.ResultCode.Return) {
                            status_1 = 1;
                            logIndex = result.startLogIndex.toNumber();
                            for (_i = 0, _b = result.logs; _i < _b.length; _i++) {
                                log = _b[_i];
                                logs.push(__assign(__assign({}, log), { transactionIndex: result.txIndex.toNumber(), blockNumber: messageBlockNum, transactionHash: incoming.messageID(), logIndex: logIndex, blockHash: block.hash }));
                                logIndex++;
                            }
                        }
                        txReceipt = {
                            blockHash: block.hash,
                            blockNumber: messageBlockNum,
                            contractAddress: contractAddress,
                            confirmations: confirmations,
                            cumulativeGasUsed: result.cumulativeGas,
                            from: incoming.sender,
                            gasUsed: result.gasUsed,
                            logs: logs,
                            status: status_1,
                            to: msg.destAddress,
                            transactionHash: incoming.messageID(),
                            transactionIndex: result.txIndex.toNumber(),
                            byzantium: true,
                        };
                        return [2 /*return*/, txReceipt];
                    case 8:
                        {
                            getMessageRequest = function () { return __awaiter(_this, void 0, void 0, function () {
                                var result, incoming, msg, network, tx, response, currentBlockNum, messageBlockNum, confirmations, blockNumber, block;
                                return __generator(this, function (_a) {
                                    switch (_a.label) {
                                        case 0: return [4 /*yield*/, this.getMessageResult(params.transactionHash)];
                                        case 1:
                                            result = _a.sent();
                                            if (!result) {
                                                return [2 /*return*/, null];
                                            }
                                            incoming = result.incoming;
                                            msg = getL2Tx(incoming);
                                            return [4 /*yield*/, this.getNetwork()];
                                        case 2:
                                            network = _a.sent();
                                            tx = {
                                                data: ethers.utils.hexlify(msg.calldata),
                                                from: incoming.sender,
                                                gasLimit: msg.maxGas,
                                                gasPrice: msg.gasPriceBid,
                                                hash: incoming.messageID(),
                                                nonce: msg.sequenceNum.toNumber(),
                                                to: msg.destAddress,
                                                value: msg.payment,
                                                chainId: network.chainId,
                                            };
                                            response = this.ethProvider._wrapTransaction(tx);
                                            return [4 /*yield*/, this.ethProvider.getBlockNumber()];
                                        case 3:
                                            currentBlockNum = _a.sent();
                                            messageBlockNum = result.incoming.blockNumber.toNumber();
                                            confirmations = currentBlockNum - messageBlockNum + 1;
                                            blockNumber = incoming.blockNumber.toNumber();
                                            return [4 /*yield*/, this.ethProvider.getBlock(blockNumber)];
                                        case 4:
                                            block = _a.sent();
                                            return [2 /*return*/, __assign(__assign({}, response), { blockHash: block.hash, blockNumber: blockNumber,
                                                    confirmations: confirmations })];
                                    }
                                });
                            }); };
                            /* eslint-disable no-alert, @typescript-eslint/no-explicit-any */
                            return [2 /*return*/, promise_poller_1.default({
                                    interval: 100,
                                    shouldContinue: function (reason, value) {
                                        if (reason) {
                                            return true;
                                        }
                                        else if (value) {
                                            return false;
                                        }
                                        else {
                                            return true;
                                        }
                                    },
                                    taskFn: getMessageRequest,
                                })];
                        }
                        _c.label = 9;
                    case 9:
                        {
                            return [2 /*return*/, this.client.findLogs(params.filter)];
                        }
                        _c.label = 10;
                    case 10:
                        {
                            arbInfo = ArbInfoFactory_1.ArbInfoFactory.connect(ARB_INFO_ADDRESS, this);
                            return [2 /*return*/, arbInfo.getBalance(params.address)];
                        }
                        _c.label = 11;
                    case 11:
                        {
                            return [2 /*return*/, this.client.getBlockCount()];
                        }
                        _c.label = 12;
                    case 12:
                        tx = params.transaction;
                        return [4 /*yield*/, this.callImpl(tx)];
                    case 13:
                        result = _c.sent();
                        if (!result) {
                            throw Error('failed to estimate gas');
                        }
                        return [2 /*return*/, result.gasUsed];
                    case 14:
                        {
                            return [2 /*return*/, 0];
                        }
                        _c.label = 15;
                    case 15:
                        {
                            return [2 /*return*/, this.client.sendTransaction(params.signedTransaction)];
                        }
                        _c.label = 16;
                    case 16:
                        console.log('Forwarding query to provider', method, params);
                        return [4 /*yield*/, this.ethProvider.perform(method, params)];
                    case 17: return [2 /*return*/, _c.sent()];
                }
            });
        });
    };
    ArbProvider.prototype.callImpl = function (transaction, blockTag) {
        return __awaiter(this, void 0, void 0, function () {
            var from, tx, _a, _b, callLatest, resultVal, tag;
            var _this = this;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0: return [4 /*yield*/, transaction.from];
                    case 1:
                        from = _c.sent();
                        _a = message_1.L2ContractTransaction.bind;
                        return [4 /*yield*/, transaction.gasLimit];
                    case 2:
                        _b = [void 0, _c.sent()];
                        return [4 /*yield*/, transaction.gasPrice];
                    case 3:
                        _b = _b.concat([_c.sent()]);
                        return [4 /*yield*/, transaction.to];
                    case 4:
                        _b = _b.concat([_c.sent()]);
                        return [4 /*yield*/, transaction.value];
                    case 5:
                        _b = _b.concat([_c.sent()]);
                        return [4 /*yield*/, transaction.data];
                    case 6:
                        tx = new (_a.apply(message_1.L2ContractTransaction, _b.concat([_c.sent()])))();
                        callLatest = function () {
                            return _this.client.pendingCall(tx, from);
                        };
                        return [4 /*yield*/, blockTag];
                    case 7:
                        tag = _c.sent();
                        if (!tag) return [3 /*break*/, 13];
                        if (!(tag == 'pending')) return [3 /*break*/, 9];
                        return [4 /*yield*/, this.client.pendingCall(tx, from)];
                    case 8:
                        resultVal = _c.sent();
                        return [3 /*break*/, 12];
                    case 9:
                        if (!(tag == 'latest')) return [3 /*break*/, 11];
                        return [4 /*yield*/, callLatest()];
                    case 10:
                        resultVal = _c.sent();
                        return [3 /*break*/, 12];
                    case 11: throw Error('Invalid block tag');
                    case 12: return [3 /*break*/, 15];
                    case 13: return [4 /*yield*/, callLatest()];
                    case 14:
                        resultVal = _c.sent();
                        _c.label = 15;
                    case 15:
                        if (!resultVal) {
                            return [2 /*return*/, undefined];
                        }
                        return [2 /*return*/, message_1.Result.fromValue(resultVal)];
                }
            });
        });
    };
    ArbProvider.prototype.call = function (transaction, blockTag) {
        return __awaiter(this, void 0, void 0, function () {
            var result;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this.callImpl(transaction, blockTag)];
                    case 1:
                        result = _a.sent();
                        if (!result) {
                            throw new Error("Call didn't return a value");
                        }
                        if (result.resultCode != message_1.ResultCode.Return) {
                            throw new Error('Call was reverted');
                        }
                        return [2 /*return*/, ethers.utils.hexlify(result.returnData)];
                }
            });
        });
    };
    // Returns the valid node hash if assertionHash is logged by the onChainTxHash
    ArbProvider.prototype.verifyDisputableAssertion = function (assertionTxHash, value, proof) {
        return __awaiter(this, void 0, void 0, function () {
            var receipt, arbRollup, events, eventIndex, rawLog, cda, chainAddress, startHash, logPostHash;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this.ethProvider.waitForTransaction(assertionTxHash)];
                    case 1:
                        receipt = _a.sent();
                        if (!receipt.logs) {
                            throw Error('RollupAsserted tx had no logs');
                        }
                        return [4 /*yield*/, this.arbRollupConn()];
                    case 2:
                        arbRollup = _a.sent();
                        events = receipt.logs.map(function (l) { return arbRollup.interface.parseLog(l); });
                        eventIndex = events.findIndex(function (event) { return event.name === EB_EVENT_CDA; });
                        if (eventIndex == -1) {
                            throw Error('RollupAsserted ' + assertionTxHash + ' not found on chain');
                        }
                        rawLog = receipt.logs[eventIndex];
                        cda = events[eventIndex];
                        return [4 /*yield*/, this.chainAddress];
                    case 3:
                        chainAddress = _a.sent();
                        if (rawLog.address.toLowerCase() !== chainAddress.toLowerCase()) {
                            throw Error('RollupAsserted Event is from a different address: ' +
                                rawLog.address +
                                '\nExpected address: ' +
                                chainAddress);
                        }
                        startHash = ethers.utils.solidityKeccak256(['bytes32', 'bytes32'], [proof.logPreHash, value.hash()]);
                        logPostHash = proof.logValHashes.reduce(function (acc, hash) {
                            return ethers.utils.solidityKeccak256(['bytes32', 'bytes32'], [acc, hash]);
                        }, startHash);
                        // Check correct logs hash
                        if (cda.values.fields[6] !== logPostHash) {
                            throw Error('RollupAsserted Event on-chain logPostHash is: ' +
                                cda.values.fields[6] +
                                '\nExpected: ' +
                                logPostHash);
                        }
                        return [2 /*return*/];
                }
            });
        });
    };
    return ArbProvider;
}(ethers.providers.BaseProvider));
exports.ArbProvider = ArbProvider;
