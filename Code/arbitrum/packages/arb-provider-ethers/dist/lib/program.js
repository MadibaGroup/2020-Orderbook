/*
 * Copyright 2020, Offchain Labs, Inc.
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
Object.defineProperty(exports, "__esModule", { value: true });
exports.machineHash = exports.programMachineHash = void 0;
var ArbValue = __importStar(require("./value"));
var ethers = __importStar(require("ethers"));
function loadValue(val, codePoints, totalOps) {
    if (val.Int) {
        return new ArbValue.IntValue('0x' + val.Int);
    }
    if (val.Tuple) {
        return new ArbValue.TupleValue(val.Tuple.map(function (subVal) { return loadValue(subVal, codePoints, totalOps); }));
    }
    if (val.CodePoint) {
        var cpIndex = totalOps - val.CodePoint.Internal;
        if (cpIndex < 0 || cpIndex >= codePoints.length) {
            throw Error("invalid internal reference " + val.CodePoint.Internal + " " + totalOps + " " + cpIndex + " " + codePoints.length);
        }
        return codePoints[cpIndex];
    }
    throw Error('Invalid value');
}
function loadOperation(op, codePoints, totalOps) {
    if (op.immediate) {
        return new ArbValue.ImmOp(op.opcode.AVMOpcode, loadValue(op.immediate, codePoints, totalOps));
    }
    else {
        return new ArbValue.BasicOp(op.opcode.AVMOpcode);
    }
}
function loadProgram(progString) {
    var prog = JSON.parse(progString);
    var nextHash = ethers.utils.hexZeroPad('0x', 32);
    var codePoints = [
        new ArbValue.CodePointValue(new ArbValue.BasicOp(0), nextHash),
    ];
    nextHash = codePoints[0].hash();
    for (var i = 0; i < prog.code.length; i++) {
        var rawOp = prog.code[prog.code.length - 1 - i];
        var op = loadOperation(rawOp, codePoints, prog.code.length);
        var cp = new ArbValue.CodePointValue(op, nextHash);
        nextHash = cp.hash();
        codePoints.push(cp);
    }
    var staticVal = loadValue(prog.static_val, codePoints, prog.code.length);
    return [codePoints.reverse(), staticVal];
}
function programMachineHash(progString) {
    var _a = loadProgram(progString), codePoints = _a[0], staticVal = _a[1];
    return machineHash(codePoints[0], new ArbValue.TupleValue([]), new ArbValue.TupleValue([]), new ArbValue.TupleValue([]), staticVal, new ArbValue.CodePointValue(new ArbValue.BasicOp(0), ethers.utils.hexZeroPad('0x00', 32)), new ArbValue.IntValue(ethers.constants.MaxUint256), new ArbValue.TupleValue([]));
}
exports.programMachineHash = programMachineHash;
function machineHash(pc, stack, auxstack, registerVal, staticVal, errPc, arbGasRemaining, pendingMessage) {
    return ethers.utils.solidityKeccak256([
        'bytes32',
        'bytes32',
        'bytes32',
        'bytes32',
        'bytes32',
        'uint256',
        'bytes32',
        'bytes32',
    ], [
        pc.hash(),
        stack.hash(),
        auxstack.hash(),
        registerVal.hash(),
        staticVal.hash(),
        arbGasRemaining.bignum,
        errPc.hash(),
        pendingMessage.hash(),
    ]);
}
exports.machineHash = machineHash;
