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
exports.ArbWallet = void 0;
var l1bridge_1 = require("./l1bridge");
var message_1 = require("./message");
var ethers = __importStar(require("ethers"));
var ArbWallet = /** @class */ (function (_super) {
    __extends(ArbWallet, _super);
    function ArbWallet(l1Signer, provider) {
        var _this = _super.call(this, l1Signer, provider.chainAddress) || this;
        _this.l1Signer = l1Signer;
        _this.provider = provider;
        return _this;
    }
    ArbWallet.prototype.getAddress = function () {
        return this.l1Signer.getAddress();
    };
    ArbWallet.prototype.signMessage = function (message) {
        return this.l1Signer.signMessage(message);
    };
    ArbWallet.prototype.depositERC20 = function (to, erc20, value, overrides) {
        return __awaiter(this, void 0, void 0, function () {
            var tx;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, _super.prototype.depositERC20.call(this, to, erc20, value, overrides)];
                    case 1:
                        tx = _a.sent();
                        return [2 /*return*/, this.provider._wrapTransaction(tx, tx.hash)];
                }
            });
        });
    };
    ArbWallet.prototype.depositERC721 = function (to, erc721, tokenId, overrides) {
        return __awaiter(this, void 0, void 0, function () {
            var tx;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, _super.prototype.depositERC20.call(this, to, erc721, tokenId, overrides)];
                    case 1:
                        tx = _a.sent();
                        return [2 /*return*/, this.provider._wrapTransaction(tx, tx.hash)];
                }
            });
        });
    };
    ArbWallet.prototype.depositETH = function (to, value, overrides) {
        return __awaiter(this, void 0, void 0, function () {
            var tx;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, _super.prototype.depositETH.call(this, to, value, overrides)];
                    case 1:
                        tx = _a.sent();
                        return [2 /*return*/, this.provider._wrapTransaction(tx, tx.hash)];
                }
            });
        });
    };
    ArbWallet.prototype.sendTransactionMessage = function (l2tx, from, overrides) {
        return __awaiter(this, void 0, void 0, function () {
            var network, tx;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        this.sendL2Message(l2tx, from, overrides);
                        return [4 /*yield*/, this.provider.getNetwork()];
                    case 1:
                        network = _a.sent();
                        tx = {
                            data: ethers.utils.hexlify(l2tx.calldata),
                            from: from,
                            gasLimit: l2tx.maxGas,
                            gasPrice: l2tx.gasPriceBid,
                            hash: l2tx.messageID(from, network.chainId),
                            nonce: l2tx.sequenceNum.toNumber(),
                            to: l2tx.destAddress,
                            value: l2tx.payment,
                            chainId: network.chainId,
                        };
                        return [2 /*return*/, this.provider._wrapTransaction(tx, tx.hash)];
                }
            });
        });
    };
    ArbWallet.prototype.sendTransaction = function (transaction) {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                // try {
                //   return this.l1Signer.sendTransaction(transaction)
                // } catch (e) {
                // }
                // Using the L1 wallet plugin, we can only send non-batched transactions
                // because we only have access to an L1 signer, not an L2 signer
                return [2 /*return*/, this.sendTransactionAtL1(transaction)];
            });
        });
    };
    ArbWallet.prototype.sendTransactionAtL1 = function (transaction) {
        return __awaiter(this, void 0, void 0, function () {
            var gasLimit, gasPrice, from, nonce, tx, _a, _b;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0: return [4 /*yield*/, transaction.gasLimit];
                    case 1:
                        gasLimit = _c.sent();
                        if (!gasLimit) {
                            // default to 90000 based on spec
                            gasLimit = 90000;
                        }
                        return [4 /*yield*/, transaction.gasPrice];
                    case 2:
                        gasPrice = _c.sent();
                        if (!gasPrice) {
                            // What do we want to make the default for this
                            gasPrice = 0;
                        }
                        return [4 /*yield*/, transaction.from];
                    case 3:
                        from = _c.sent();
                        if (!!from) return [3 /*break*/, 5];
                        return [4 /*yield*/, this.getAddress()];
                    case 4:
                        from = _c.sent();
                        _c.label = 5;
                    case 5: return [4 /*yield*/, transaction.nonce];
                    case 6:
                        nonce = _c.sent();
                        if (!!nonce) return [3 /*break*/, 8];
                        return [4 /*yield*/, this.provider.getTransactionCount(from)];
                    case 7:
                        nonce = _c.sent();
                        _c.label = 8;
                    case 8:
                        _a = message_1.L2Transaction.bind;
                        _b = [void 0, gasLimit,
                            gasPrice,
                            nonce];
                        return [4 /*yield*/, transaction.to];
                    case 9:
                        _b = _b.concat([_c.sent()]);
                        return [4 /*yield*/, transaction.value];
                    case 10:
                        _b = _b.concat([_c.sent()]);
                        return [4 /*yield*/, transaction.data];
                    case 11:
                        tx = new (_a.apply(message_1.L2Transaction, _b.concat([_c.sent()])))();
                        return [2 /*return*/, this.sendTransactionMessage(tx, from)];
                }
            });
        });
    };
    return ArbWallet;
}(l1bridge_1.L1Bridge));
exports.ArbWallet = ArbWallet;
