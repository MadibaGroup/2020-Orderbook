/*
 * Copyright 2019, Offchain Labs, Inc.
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
/* eslint-env node */
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
var __spreadArrays = (this && this.__spreadArrays) || function () {
    for (var s = 0, i = 0, il = arguments.length; i < il; i++) s += arguments[i].length;
    for (var r = Array(s), k = 0, i = 0; i < il; i++)
        for (var a = arguments[i], j = 0, jl = a.length; j < jl; j++, k++)
            r[k] = a[j];
    return r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.unmarshal = exports.marshal = exports.hexToBytestack = exports.bytestackToBytes = exports.TupleValue = exports.CodePointValue = exports.IntValue = exports.ImmOp = exports.BasicOp = exports.OperationType = exports.ValueType = exports.MAX_TUPLE_SIZE = void 0;
var ethers = __importStar(require("ethers"));
function assertNever(x) {
    throw new Error('Unexpected object: ' + x);
}
// Max tuple size
exports.MAX_TUPLE_SIZE = 8;
var ValueType;
(function (ValueType) {
    ValueType[ValueType["Int"] = 0] = "Int";
    ValueType[ValueType["CodePoint"] = 1] = "CodePoint";
    ValueType[ValueType["HashOnly"] = 2] = "HashOnly";
    ValueType[ValueType["Tuple"] = 3] = "Tuple";
    ValueType[ValueType["TupleMax"] = 3 + exports.MAX_TUPLE_SIZE] = "TupleMax";
})(ValueType = exports.ValueType || (exports.ValueType = {}));
// Extracts first n bytes from s returning two separate strings as list
function extractBytes(s, offset, n) {
    if (n < 0 || n > s.length) {
        throw Error('Error extracting bytes: Uint8Array is too short');
    }
    return [s.slice(offset, offset + n), offset + n];
}
// Convert unsigned int i to byte array of n bytes.
function intToBytes(i, n) {
    return ethers.utils.padZeros(ethers.utils.arrayify(ethers.utils.bigNumberify(i)), n);
}
// Convert unsigned BigNumber to hexstring of 32 bytes. Does not include "0x".
function uBigNumToBytes(bn) {
    return ethers.utils.padZeros(ethers.utils.arrayify(bn), 32);
}
var OperationType;
(function (OperationType) {
    OperationType[OperationType["Basic"] = 0] = "Basic";
    OperationType[OperationType["Immediate"] = 1] = "Immediate";
})(OperationType = exports.OperationType || (exports.OperationType = {}));
var BasicOp = /** @class */ (function () {
    function BasicOp(opcode) {
        this.opcode = opcode;
        this.kind = OperationType.Basic;
    }
    return BasicOp;
}());
exports.BasicOp = BasicOp;
var ImmOp = /** @class */ (function () {
    function ImmOp(opcode, value) {
        this.opcode = opcode;
        this.value = value;
        this.kind = OperationType.Immediate;
    }
    return ImmOp;
}());
exports.ImmOp = ImmOp;
var IntValue = /** @class */ (function () {
    function IntValue(bignum) {
        this.bignum = ethers.utils.bigNumberify(bignum);
    }
    IntValue.prototype.typeCode = function () {
        return ValueType.Int;
    };
    IntValue.prototype.hash = function () {
        return ethers.utils.solidityKeccak256(['uint256'], [this.bignum]);
    };
    IntValue.prototype.toString = function () {
        return this.bignum.toString();
    };
    IntValue.prototype.size = function () {
        return ethers.utils.bigNumberify(1);
    };
    return IntValue;
}());
exports.IntValue = IntValue;
var CodePointValue = /** @class */ (function () {
    function CodePointValue(op, nextHash) {
        this.op = op;
        this.nextHash = nextHash;
    }
    CodePointValue.prototype.typeCode = function () {
        return ValueType.CodePoint;
    };
    CodePointValue.prototype.hash = function () {
        switch (this.op.kind) {
            case OperationType.Basic: {
                return ethers.utils.solidityKeccak256(['uint8', 'uint8', 'bytes32'], [this.typeCode(), this.op.opcode, this.nextHash]);
            }
            case OperationType.Immediate: {
                return ethers.utils.solidityKeccak256(['uint8', 'uint8', 'bytes32', 'bytes32'], [this.typeCode(), this.op.opcode, this.op.value.hash(), this.nextHash]);
            }
            default:
                assertNever(this.op);
                return '';
        }
    };
    CodePointValue.prototype.toString = function () {
        switch (this.op.kind) {
            case OperationType.Basic: {
                return 'Basic(OpCode(0x' + this.op.opcode.toString() + '))';
            }
            case OperationType.Immediate: {
                return ('Immediate(OpCode(0x' +
                    this.op.opcode.toString() +
                    '), ' +
                    this.op.value.toString() +
                    ')');
            }
            default:
                assertNever(this.op);
                return '';
        }
    };
    CodePointValue.prototype.size = function () {
        return ethers.utils.bigNumberify(1);
    };
    return CodePointValue;
}());
exports.CodePointValue = CodePointValue;
var TupleValue = /** @class */ (function () {
    // contents: array of Value(s)
    // size: num of Value(s) in contents
    function TupleValue(contents) {
        if (contents.length > exports.MAX_TUPLE_SIZE) {
            throw Error('Error TupleValue: illegal size ' + contents.length);
        }
        this.contents = contents;
        if (contents.length == 0) {
            var firstHash = ethers.utils.solidityKeccak256(['uint8'], [0]);
            this.cachedHash = ethers.utils.solidityKeccak256(['uint8', 'bytes32', 'uint256'], [ValueType.Tuple, firstHash, 1]);
        }
        else {
            var hashes = this.contents.map(function (value) { return value.hash(); });
            var types = ['uint8'].concat(Array(contents.length).fill('bytes32'));
            var values = [contents.length];
            var firstHash = ethers.utils.solidityKeccak256(types, values.concat(hashes));
            this.cachedHash = ethers.utils.solidityKeccak256(['uint8', 'bytes32', 'uint256'], [ValueType.Tuple, firstHash, this.size()]);
        }
    }
    TupleValue.prototype.typeCode = function () {
        return ValueType.Tuple + this.contents.length;
    };
    TupleValue.prototype.hash = function () {
        return this.cachedHash;
    };
    TupleValue.prototype.size = function () {
        var valSize = 1;
        for (var i = 0; i < this.contents.length; i++) {
            var current = this.get(i).size();
            valSize += current.toNumber();
        }
        return ethers.utils.bigNumberify(valSize);
    };
    // index: uint8
    TupleValue.prototype.get = function (index) {
        if (index < 0 || index >= this.contents.length) {
            throw Error('Error TupleValue get: index out of bounds ' + index);
        }
        return this.contents[index];
    };
    // Non-mutating
    // index: uint8
    // value: *Value
    TupleValue.prototype.set = function (index, value) {
        if (index < 0 || index >= this.contents.length) {
            throw Error('Error TupleValue set: index out of bounds ' + index);
        }
        var contents = __spreadArrays(this.contents);
        contents[index] = value;
        return new TupleValue(contents);
    };
    TupleValue.prototype.toString = function () {
        var ret = 'Tuple([';
        ret += this.contents.map(function (val) { return val.toString(); }).join(', ');
        ret += '])';
        return ret;
    };
    return TupleValue;
}());
exports.TupleValue = TupleValue;
function bytesToIntValues(bytearray) {
    var bignums = [];
    var sizeBytes = bytearray.length;
    var chunkCount = Math.ceil(sizeBytes / 32);
    for (var i = 0; i < chunkCount; i++) {
        var byteSlice = bytearray.slice(i * 32, (i + 1) * 32);
        var nextNumBytes = new Uint8Array(32);
        nextNumBytes.set(byteSlice);
        var bignum = ethers.utils.bigNumberify(nextNumBytes);
        bignums.push(bignum);
    }
    return bignums;
}
// twoTupleValue: (byterange: SizedTupleValue, size: IntValue)
function bytestackToBytes(twoTupleValue) {
    var sizeInt = twoTupleValue.get(0);
    var stack = twoTupleValue.get(1);
    var sizeBytes = sizeInt.bignum.toNumber();
    var chunkCount = Math.ceil(sizeBytes / 32);
    var result = new Uint8Array(chunkCount * 32);
    var i = 0;
    while (stack.contents.length == 2) {
        var value = stack.get(0);
        stack = stack.get(1);
        var chunk = ethers.utils.padZeros(ethers.utils.arrayify(value.bignum), 32);
        var offset = (chunkCount - 1 - i) * 32;
        result.set(chunk, offset);
        i++;
    }
    return result.slice(0, sizeBytes);
}
exports.bytestackToBytes = bytestackToBytes;
// hexString: must be a byte string (hexString.length % 2 === 0)
function hexToBytestack(hex) {
    var bytearray = ethers.utils.arrayify(hex);
    var sizeBytes = bytearray.length;
    var bignums = bytesToIntValues(bytearray);
    // Empty tuple
    var t = new TupleValue([]);
    for (var i = 0; i < bignums.length; i++) {
        t = new TupleValue([new IntValue(bignums[i]), t]);
    }
    return new TupleValue([new IntValue(sizeBytes), t]);
}
exports.hexToBytestack = hexToBytestack;
function _marshalValue(acc, v) {
    var ty = v.typeCode();
    var accTy = ethers.utils.concat([acc, intToBytes(ty, 1)]);
    if (ty === ValueType.Int) {
        var val = v;
        // 1B type; 32B hex int
        if (val.bignum.lt(0)) {
            throw Error('Error marshaling IntValue: negative values not supported');
        }
        return ethers.utils.concat([accTy, uBigNumToBytes(val.bignum)]);
    }
    else if (ty === ValueType.CodePoint) {
        var val = v;
        // 1B type; 1B immCount; 1B opcode; Val?; 32B hash
        var packed = ethers.utils.concat([
            accTy,
            intToBytes(val.op.kind, 1),
            intToBytes(val.op.opcode, 1),
        ]);
        switch (val.op.kind) {
            case OperationType.Basic: {
                return ethers.utils.concat([packed, val.nextHash]);
            }
            case OperationType.Immediate: {
                var op = val.op;
                return ethers.utils.concat([
                    _marshalValue(packed, op.value),
                    val.nextHash,
                ]);
            }
            default: {
                assertNever(val.op);
                return new Uint8Array();
            }
        }
        // } else if (ty === ValueType.HashOnly) {
        //   const val = v as HashOnlyValue
        //   // 1B type; 8B size; 32B hash
        //   return ethers.utils.concat([accTy, intToBytes(val.size, 8), val.hash()])
    }
    else if (ty >= ValueType.Tuple && ty <= ValueType.TupleMax) {
        var val = v;
        // 1B type; (ty-TYPE_TUPLE_0) number of Values
        for (var _i = 0, _a = val.contents; _i < _a.length; _i++) {
            var subVal = _a[_i];
            accTy = _marshalValue(accTy, subVal);
        }
        return accTy;
    }
    else {
        throw Error('Error marshaling value no such TYPE: ' + ty);
    }
}
function marshal(someValue) {
    return _marshalValue(new Uint8Array(), someValue);
}
exports.marshal = marshal;
function unmarshalOpCode(array, offset) {
    var _a;
    var head;
    _a = extractBytes(array, offset, 1), head = _a[0], offset = _a[1];
    var opcode = ethers.utils.bigNumberify(head).toNumber();
    return [opcode, offset];
}
function unmarshalOp(array, offset) {
    var _a, _b, _c, _d;
    var head = new Uint8Array();
    _a = extractBytes(array, offset, 1), head = _a[0], offset = _a[1];
    var kind = ethers.utils.bigNumberify(head).toNumber();
    if (kind === OperationType.Basic) {
        var opcode = void 0;
        _b = unmarshalOpCode(array, offset), opcode = _b[0], offset = _b[1];
        return [new BasicOp(opcode), offset];
    }
    else if (kind === OperationType.Immediate) {
        var opcode = void 0;
        var value = void 0;
        _c = unmarshalOpCode(array, offset), opcode = _c[0], offset = _c[1];
        _d = _unmarshalValue(array, offset), value = _d[0], offset = _d[1];
        return [new ImmOp(opcode, value), offset];
    }
    else {
        throw Error('Error unmarshalOp no such immCount: ' + kind);
    }
}
function unmarshalTuple(size, array, offset) {
    var _a;
    var contents = new Array(size);
    for (var i = 0; i < size; i++) {
        var value = void 0;
        _a = _unmarshalValue(array, offset), value = _a[0], offset = _a[1];
        contents[i] = value;
    }
    return [contents, offset];
}
function _unmarshalValue(array, offset) {
    var _a, _b, _c, _d, _e;
    var head;
    _a = extractBytes(array, offset, 1), head = _a[0], offset = _a[1];
    var ty = ethers.utils.bigNumberify(head).toNumber();
    if (ty === ValueType.Int) {
        ;
        _b = extractBytes(array, offset, 32), head = _b[0], offset = _b[1];
        var i = ethers.utils.bigNumberify(head);
        return [new IntValue(i), offset];
    }
    else if (ty === ValueType.CodePoint) {
        var op = void 0;
        _c = unmarshalOp(array, offset), op = _c[0], offset = _c[1];
        _d = extractBytes(array, offset, 32), head = _d[0], offset = _d[1];
        var nextHash = ethers.utils.hexlify(head);
        return [new CodePointValue(op, nextHash), offset];
    }
    else if (ty === ValueType.HashOnly) {
        throw Error('Error unmarshaling: HashOnlyValue was not expected');
    }
    else if (ty >= ValueType.Tuple && ty <= ValueType.TupleMax) {
        var size = ty - ValueType.Tuple;
        var contents = void 0;
        _e = unmarshalTuple(size, array, offset), contents = _e[0], offset = _e[1];
        return [new TupleValue(contents), offset];
    }
    else {
        throw Error('Error unmarshaling value no such TYPE: ' + ty.toString(16));
    }
}
function unmarshal(array, offset) {
    if (!offset) {
        offset = 0;
    }
    return _unmarshalValue(ethers.utils.arrayify(array), offset)[0];
}
exports.unmarshal = unmarshal;
