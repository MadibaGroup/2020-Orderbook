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
Object.defineProperty(exports, "__esModule", { value: true });
exports.Result = exports.Log = exports.ResultCode = exports.OutgoingMessage = exports.IncomingMessage = exports.L2Message = exports.ERC721Message = exports.ERC20Message = exports.EthMessage = exports.BuddyRegisteredMessage = exports.MessageCode = exports.L2ContractTransaction = exports.L2Call = exports.L2Batch = exports.L2SignedTransaction = exports.L2Transaction = exports.L2MessageCode = exports.marshaledBytesHash = void 0;
var ArbValue = __importStar(require("./value"));
var ethers = __importStar(require("ethers"));
function hex32(val) {
    return ethers.utils.padZeros(ethers.utils.arrayify(val), 32);
}
function encodedAddress(addr) {
    return ethers.utils.padZeros(ethers.utils.arrayify(addr), 32);
}
function intValueToAddress(value) {
    return ethers.utils.getAddress(ethers.utils.hexZeroPad(value.bignum.toHexString(), 20));
}
function marshaledBytesHash(data) {
    var ret = ethers.utils.hexZeroPad(ethers.utils.bigNumberify(data.length).toHexString(), 32);
    var chunks = [];
    var offset = 0;
    while (offset < data.length) {
        var nextVal = new Uint8Array(32);
        nextVal.set(data.slice(offset, offset + 32));
        chunks.push('0x' + Buffer.from(nextVal).toString('hex'));
        offset += 32;
    }
    for (var i = 0; i < chunks.length; i++) {
        ret = ethers.utils.solidityKeccak256(['bytes32', 'bytes32'], [ret, chunks[chunks.length - 1 - i]]);
    }
    return ret;
}
exports.marshaledBytesHash = marshaledBytesHash;
var L2MessageCode;
(function (L2MessageCode) {
    L2MessageCode[L2MessageCode["Transaction"] = 0] = "Transaction";
    L2MessageCode[L2MessageCode["ContractTransaction"] = 1] = "ContractTransaction";
    L2MessageCode[L2MessageCode["Call"] = 2] = "Call";
    L2MessageCode[L2MessageCode["TransactionBatch"] = 3] = "TransactionBatch";
    L2MessageCode[L2MessageCode["SignedTransaction"] = 4] = "SignedTransaction";
})(L2MessageCode = exports.L2MessageCode || (exports.L2MessageCode = {}));
var L2Transaction = /** @class */ (function () {
    function L2Transaction(maxGas, gasPriceBid, sequenceNum, destAddress, payment, calldata) {
        if (!destAddress) {
            destAddress = '0x';
        }
        if (!calldata) {
            calldata = '0x';
        }
        if (!payment) {
            payment = 0;
        }
        this.maxGas = ethers.utils.bigNumberify(maxGas);
        this.gasPriceBid = ethers.utils.bigNumberify(gasPriceBid);
        this.sequenceNum = ethers.utils.bigNumberify(sequenceNum);
        this.destAddress = ethers.utils.hexZeroPad(ethers.utils.hexlify(destAddress), 20);
        this.payment = ethers.utils.bigNumberify(payment);
        this.calldata = ethers.utils.hexlify(calldata);
        this.kind = L2MessageCode.Transaction;
    }
    L2Transaction.fromData = function (data) {
        var bytes = ethers.utils.arrayify(data);
        return new L2Transaction(bytes.slice(0, 32), bytes.slice(32, 64), bytes.slice(64, 96), bytes.slice(108, 128), bytes.slice(128, 160), bytes.slice(160));
    };
    L2Transaction.prototype.asData = function () {
        return ethers.utils.concat([
            hex32(this.maxGas),
            hex32(this.gasPriceBid),
            hex32(this.sequenceNum),
            encodedAddress(this.destAddress),
            hex32(this.payment),
            ethers.utils.arrayify(this.calldata),
        ]);
    };
    L2Transaction.prototype.messageID = function (sender, chainId) {
        var data = ethers.utils.concat([[this.kind], this.asData()]);
        var inner = ethers.utils.solidityKeccak256(['uint256', 'bytes32'], [chainId, marshaledBytesHash(data)]);
        return ethers.utils.solidityKeccak256(['bytes32', 'bytes32'], [ethers.utils.hexZeroPad(sender, 32), inner]);
    };
    return L2Transaction;
}());
exports.L2Transaction = L2Transaction;
var L2SignedTransaction = /** @class */ (function () {
    function L2SignedTransaction(tx, sig) {
        this.tx = tx;
        this.sig = sig;
        this.kind = L2MessageCode.SignedTransaction;
    }
    L2SignedTransaction.fromData = function (data) {
        var bytes = ethers.utils.arrayify(data);
        var tx = L2Transaction.fromData(bytes.slice(0, bytes.length - 65));
        var sig = bytes.slice(bytes.length - 65, bytes.length);
        return new L2SignedTransaction(tx, ethers.utils.hexlify(sig));
    };
    L2SignedTransaction.prototype.asData = function () {
        return ethers.utils.concat([this.tx.asData(), this.sig]);
    };
    return L2SignedTransaction;
}());
exports.L2SignedTransaction = L2SignedTransaction;
var L2Batch = /** @class */ (function () {
    function L2Batch(messages) {
        this.messages = messages;
        this.kind = L2MessageCode.TransactionBatch;
    }
    L2Batch.fromData = function (data) {
        var bytes = ethers.utils.arrayify(data);
        var offset = 0;
        var messages = [];
        while (offset < data.length) {
            var lengthData = bytes.slice(offset, offset + 8);
            offset += 8;
            var length_1 = ethers.utils.bigNumberify(lengthData).toNumber();
            messages.push(L2Message.fromData(bytes.slice(offset, offset + length_1)));
        }
        return new L2Batch(messages);
    };
    L2Batch.prototype.asData = function () {
        return ethers.utils.concat(this.messages.map(function (msg) {
            var data = msg.asData();
            var lengthHex = ethers.utils.bigNumberify(data).toHexString();
            return ethers.utils.concat([
                ethers.utils.hexZeroPad(lengthHex, 8),
                data,
            ]);
        }));
    };
    return L2Batch;
}());
exports.L2Batch = L2Batch;
var L2Call = /** @class */ (function () {
    function L2Call(maxGas, gasPriceBid, destAddress, calldata) {
        if (!maxGas) {
            maxGas = 0;
        }
        if (!gasPriceBid) {
            gasPriceBid = 0;
        }
        if (!destAddress) {
            destAddress = ethers.utils.hexZeroPad('0x', 20);
        }
        if (!calldata) {
            calldata = '0x';
        }
        this.maxGas = ethers.utils.bigNumberify(maxGas);
        this.gasPriceBid = ethers.utils.bigNumberify(gasPriceBid);
        this.destAddress = ethers.utils.hexlify(destAddress);
        this.calldata = ethers.utils.hexlify(calldata);
        this.kind = L2MessageCode.Call;
    }
    L2Call.fromData = function (data) {
        var bytes = ethers.utils.arrayify(data);
        return new L2Call(bytes.slice(0, 32), bytes.slice(32, 64), bytes.slice(64, 96), bytes.slice(96));
    };
    L2Call.prototype.asData = function () {
        return ethers.utils.concat([
            hex32(this.maxGas),
            hex32(this.gasPriceBid),
            encodedAddress(this.destAddress),
            this.calldata,
        ]);
    };
    return L2Call;
}());
exports.L2Call = L2Call;
var L2ContractTransaction = /** @class */ (function () {
    function L2ContractTransaction(maxGas, gasPriceBid, destAddress, payment, calldata) {
        if (!maxGas) {
            maxGas = 0;
        }
        if (!gasPriceBid) {
            gasPriceBid = 0;
        }
        if (!destAddress) {
            destAddress = ethers.utils.hexZeroPad('0x', 20);
        }
        if (!payment) {
            payment = 0;
        }
        if (!calldata) {
            calldata = '0x';
        }
        this.maxGas = ethers.utils.bigNumberify(maxGas);
        this.gasPriceBid = ethers.utils.bigNumberify(gasPriceBid);
        this.destAddress = ethers.utils.hexlify(destAddress);
        this.payment = ethers.utils.bigNumberify(payment);
        this.calldata = ethers.utils.hexlify(calldata);
        this.kind = L2MessageCode.ContractTransaction;
    }
    L2ContractTransaction.fromData = function (data) {
        var bytes = ethers.utils.arrayify(data);
        return new L2ContractTransaction(bytes.slice(0, 32), bytes.slice(32, 64), bytes.slice(64, 96), bytes.slice(96, 128), bytes.slice(128));
    };
    L2ContractTransaction.prototype.asData = function () {
        return ethers.utils.concat([
            hex32(this.maxGas),
            hex32(this.gasPriceBid),
            encodedAddress(this.destAddress),
            hex32(this.payment),
            this.calldata,
        ]);
    };
    return L2ContractTransaction;
}());
exports.L2ContractTransaction = L2ContractTransaction;
var MessageCode;
(function (MessageCode) {
    MessageCode[MessageCode["Eth"] = 0] = "Eth";
    MessageCode[MessageCode["ERC20"] = 1] = "ERC20";
    MessageCode[MessageCode["ERC721"] = 2] = "ERC721";
    MessageCode[MessageCode["L2"] = 3] = "L2";
    MessageCode[MessageCode["Initialization"] = 4] = "Initialization";
    MessageCode[MessageCode["BuddyRegistered"] = 5] = "BuddyRegistered";
})(MessageCode = exports.MessageCode || (exports.MessageCode = {}));
var BuddyRegisteredMessage = /** @class */ (function () {
    function BuddyRegisteredMessage(valid) {
        this.valid = valid;
        this.kind = MessageCode.BuddyRegistered;
    }
    BuddyRegisteredMessage.fromData = function (data) {
        var bytes = ethers.utils.arrayify(data);
        return new BuddyRegisteredMessage(bytes[0] == 1);
    };
    BuddyRegisteredMessage.prototype.asData = function () {
        var arr = new Uint8Array(1);
        arr[0] = this.valid ? 1 : 0;
        return arr;
    };
    return BuddyRegisteredMessage;
}());
exports.BuddyRegisteredMessage = BuddyRegisteredMessage;
var EthMessage = /** @class */ (function () {
    function EthMessage(dest, value) {
        this.kind = MessageCode.Eth;
        this.dest = dest;
        this.value = ethers.utils.bigNumberify(value);
    }
    EthMessage.fromData = function (data) {
        var bytes = ethers.utils.arrayify(data);
        return new EthMessage(ethers.utils.hexlify(bytes.slice(12, 32)), bytes.slice(32, 64));
    };
    EthMessage.prototype.asData = function () {
        return ethers.utils.concat([encodedAddress(this.dest), hex32(this.value)]);
    };
    return EthMessage;
}());
exports.EthMessage = EthMessage;
var ERC20Message = /** @class */ (function () {
    function ERC20Message(tokenAddress, dest, value) {
        this.kind = MessageCode.ERC20;
        this.tokenAddress = ethers.utils.hexlify(tokenAddress);
        this.dest = ethers.utils.hexlify(dest);
        this.value = ethers.utils.bigNumberify(value);
    }
    ERC20Message.fromData = function (data) {
        var bytes = ethers.utils.arrayify(data);
        return new ERC20Message(bytes.slice(12, 32), bytes.slice(44, 64), bytes.slice(64, 96));
    };
    ERC20Message.prototype.asData = function () {
        return ethers.utils.concat([
            encodedAddress(this.tokenAddress),
            encodedAddress(this.dest),
            hex32(this.value),
        ]);
    };
    return ERC20Message;
}());
exports.ERC20Message = ERC20Message;
var ERC721Message = /** @class */ (function () {
    function ERC721Message(tokenAddress, dest, id) {
        this.kind = MessageCode.ERC721;
        this.tokenAddress = ethers.utils.hexlify(tokenAddress);
        this.dest = ethers.utils.hexlify(dest);
        this.id = ethers.utils.bigNumberify(id);
    }
    ERC721Message.fromData = function (data) {
        var bytes = ethers.utils.arrayify(data);
        return new ERC721Message(bytes.slice(12, 32), bytes.slice(44, 64), bytes.slice(64, 96));
    };
    ERC721Message.prototype.asData = function () {
        return ethers.utils.concat([
            encodedAddress(this.tokenAddress),
            encodedAddress(this.dest),
            hex32(this.id),
        ]);
    };
    return ERC721Message;
}());
exports.ERC721Message = ERC721Message;
function l2SubMessageFromData(data) {
    var bytes = ethers.utils.arrayify(data);
    var kind = bytes[0];
    switch (kind) {
        case L2MessageCode.Transaction:
            return L2Transaction.fromData(bytes.slice(1));
        case L2MessageCode.ContractTransaction:
            return L2ContractTransaction.fromData(bytes.slice(1));
        case L2MessageCode.Call:
            return L2Call.fromData(bytes.slice(1));
        case L2MessageCode.SignedTransaction:
            return L2SignedTransaction.fromData(bytes.slice(1));
        default:
            throw Error('invalid L2 message type ' + kind);
    }
}
var L2Message = /** @class */ (function () {
    function L2Message(message) {
        this.message = message;
        this.kind = MessageCode.L2;
    }
    L2Message.fromData = function (data) {
        return new L2Message(l2SubMessageFromData(data));
    };
    L2Message.prototype.asData = function () {
        return ethers.utils.concat([[this.message.kind], this.message.asData()]);
    };
    return L2Message;
}());
exports.L2Message = L2Message;
function newMessageFromData(kind, data) {
    switch (kind) {
        case MessageCode.Eth:
            return EthMessage.fromData(data);
        case MessageCode.ERC20:
            return ERC20Message.fromData(data);
        case MessageCode.ERC721:
            return ERC721Message.fromData(data);
        case MessageCode.L2:
            return L2Message.fromData(data);
        default:
            throw 'Invalid arb message type';
    }
}
var IncomingMessage = /** @class */ (function () {
    function IncomingMessage(msg, blockNumber, timestamp, sender, inboxSeqNum) {
        this.msg = msg;
        this.blockNumber = ethers.utils.bigNumberify(blockNumber);
        this.timestamp = ethers.utils.bigNumberify(timestamp);
        this.sender = sender;
        this.inboxSeqNum = ethers.utils.bigNumberify(inboxSeqNum);
    }
    IncomingMessage.fromValue = function (val) {
        var tup = val;
        var kind = tup.get(0).bignum.toNumber();
        var data = ArbValue.bytestackToBytes(tup.get(5));
        return new IncomingMessage(newMessageFromData(kind, data), tup.get(1).bignum, tup.get(2).bignum, intValueToAddress(tup.get(3)), tup.get(4).bignum);
    };
    IncomingMessage.prototype.asValue = function () {
        return new ArbValue.TupleValue([
            new ArbValue.IntValue(this.msg.kind),
            new ArbValue.IntValue(this.blockNumber),
            new ArbValue.IntValue(this.timestamp),
            new ArbValue.IntValue(this.sender),
            new ArbValue.IntValue(this.inboxSeqNum),
            ArbValue.hexToBytestack(this.msg.asData()),
        ]);
    };
    IncomingMessage.prototype.commitmentHash = function () {
        return ethers.utils.solidityKeccak256(['uint8', 'address', 'uint256', 'uint256', 'uint256', 'bytes32'], [
            this.msg.kind,
            this.sender,
            this.blockNumber,
            this.timestamp,
            this.inboxSeqNum,
            ethers.utils.keccak256(this.msg.asData()),
        ]);
    };
    IncomingMessage.prototype.messageID = function () {
        return this.inboxSeqNum.toHexString();
    };
    return IncomingMessage;
}());
exports.IncomingMessage = IncomingMessage;
var OutgoingMessage = /** @class */ (function () {
    function OutgoingMessage(msg, sender) {
        this.msg = msg;
        this.sender = sender;
    }
    OutgoingMessage.prototype.asValue = function () {
        return new ArbValue.TupleValue([
            new ArbValue.IntValue(this.msg.kind),
            new ArbValue.IntValue(this.sender),
            ArbValue.hexToBytestack(this.msg.asData()),
        ]);
    };
    return OutgoingMessage;
}());
exports.OutgoingMessage = OutgoingMessage;
var ResultCode;
(function (ResultCode) {
    ResultCode[ResultCode["Return"] = 0] = "Return";
    ResultCode[ResultCode["Revert"] = 1] = "Revert";
    ResultCode[ResultCode["Congestion"] = 2] = "Congestion";
    ResultCode[ResultCode["InsufficientGasFunds"] = 3] = "InsufficientGasFunds";
    ResultCode[ResultCode["InsufficientTxFunds"] = 4] = "InsufficientTxFunds";
    ResultCode[ResultCode["BadSequenceCode"] = 5] = "BadSequenceCode";
    ResultCode[ResultCode["InvalidMessageFormatCode"] = 6] = "InvalidMessageFormatCode";
    ResultCode[ResultCode["UnknownErrorCode"] = 255] = "UnknownErrorCode";
})(ResultCode = exports.ResultCode || (exports.ResultCode = {}));
var Log = /** @class */ (function () {
    function Log(address, topics, data) {
        this.address = address;
        this.topics = topics;
        this.data = data;
    }
    Log.fromValue = function (val) {
        var tup = val;
        var topics = tup.contents
            .slice(2)
            .map(function (rawTopic) {
            return ethers.utils.hexZeroPad(ethers.utils.hexlify(rawTopic.bignum), 32);
        });
        return new Log(intValueToAddress(tup.get(0)), topics, ethers.utils.hexlify(ArbValue.bytestackToBytes(tup.get(1))));
    };
    Log.prototype.asValue = function () {
        var values = [];
        values.push(new ArbValue.IntValue(this.address));
        values.push(ArbValue.hexToBytestack(this.data));
        for (var _i = 0, _a = this.topics; _i < _a.length; _i++) {
            var topic = _a[_i];
            values.push(new ArbValue.IntValue(topic));
        }
        return new ArbValue.TupleValue(values);
    };
    return Log;
}());
exports.Log = Log;
var Result = /** @class */ (function () {
    function Result(incoming, resultCode, returnData, logs, gasUsed, gasPrice, cumulativeGas, txIndex, startLogIndex) {
        this.incoming = incoming;
        this.resultCode = resultCode;
        this.returnData = returnData;
        this.logs = logs;
        this.gasUsed = ethers.utils.bigNumberify(gasUsed);
        this.gasPrice = ethers.utils.bigNumberify(gasPrice);
        this.cumulativeGas = ethers.utils.bigNumberify(cumulativeGas);
        this.txIndex = ethers.utils.bigNumberify(txIndex);
        this.startLogIndex = ethers.utils.bigNumberify(startLogIndex);
    }
    Result.fromValue = function (val) {
        var tup = val;
        var incoming = IncomingMessage.fromValue(tup.get(0));
        var resultInfo = tup.get(1);
        var gasInfo = tup.get(2);
        var chainInfo = tup.get(3);
        var resultCode = resultInfo.get(0).bignum.toNumber();
        var returnData = ArbValue.bytestackToBytes(resultInfo.get(1));
        var logs = stackValueToList(resultInfo.get(2)).map(function (val) { return Log.fromValue(val); });
        var gasUsed = gasInfo.get(0).bignum;
        var gasPrice = gasInfo.get(1).bignum;
        var cumulativeGas = chainInfo.get(0).bignum;
        var chainIndex = chainInfo.get(1).bignum;
        var startLogIndex = chainInfo.get(2).bignum;
        return new Result(incoming, resultCode, returnData, logs, gasUsed, gasPrice, cumulativeGas, chainIndex, startLogIndex);
    };
    Result.prototype.asValue = function () {
        return new ArbValue.TupleValue([
            this.incoming.asValue(),
            new ArbValue.TupleValue([
                new ArbValue.IntValue(this.resultCode),
                ArbValue.hexToBytestack(this.returnData),
                listToStackValue(this.logs.map(function (log) { return log.asValue(); })),
            ]),
            new ArbValue.TupleValue([
                new ArbValue.IntValue(this.gasUsed),
                new ArbValue.IntValue(this.gasPrice),
            ]),
            new ArbValue.TupleValue([
                new ArbValue.IntValue(this.cumulativeGas),
                new ArbValue.IntValue(this.txIndex),
                new ArbValue.IntValue(this.startLogIndex),
            ]),
        ]);
    };
    return Result;
}());
exports.Result = Result;
function stackValueToList(value) {
    var values = [];
    while (value.contents.length !== 0) {
        values.push(value.get(0));
        value = value.get(1);
    }
    return values;
}
function listToStackValue(values) {
    var tup = new ArbValue.TupleValue([]);
    for (var _i = 0, values_1 = values; _i < values_1.length; _i++) {
        var val = values_1[_i];
        tup = new ArbValue.TupleValue([val, tup]);
    }
    return tup;
}
