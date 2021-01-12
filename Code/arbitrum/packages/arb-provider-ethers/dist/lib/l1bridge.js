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
exports.L1Bridge = void 0;
var message_1 = require("./message");
var GlobalInboxFactory_1 = require("./abi/GlobalInboxFactory");
var ArbRollupFactory_1 = require("./abi/ArbRollupFactory");
var L1Bridge = /** @class */ (function () {
    function L1Bridge(signer, chainAddress) {
        this.signer = signer;
        this.chainAddress = chainAddress;
    }
    L1Bridge.prototype.globalInbox = function () {
        return __awaiter(this, void 0, void 0, function () {
            var arbRollup, _a, _b, globalInboxAddress, globalInbox;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        if (!!this.globalInboxCache) return [3 /*break*/, 3];
                        _b = (_a = ArbRollupFactory_1.ArbRollupFactory).connect;
                        return [4 /*yield*/, this.chainAddress];
                    case 1:
                        arbRollup = _b.apply(_a, [_c.sent(), this.signer]);
                        return [4 /*yield*/, arbRollup.globalInbox()];
                    case 2:
                        globalInboxAddress = _c.sent();
                        globalInbox = GlobalInboxFactory_1.GlobalInboxFactory.connect(globalInboxAddress, this.signer).connect(this.signer);
                        this.globalInboxCache = globalInbox;
                        return [2 /*return*/, globalInbox];
                    case 3: return [2 /*return*/, this.globalInboxCache];
                }
            });
        });
    };
    L1Bridge.prototype.withdrawEthFromLockbox = function () {
        return __awaiter(this, void 0, void 0, function () {
            var globalInbox;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this.globalInbox()];
                    case 1:
                        globalInbox = _a.sent();
                        return [2 /*return*/, globalInbox.withdrawEth()];
                }
            });
        });
    };
    L1Bridge.prototype.withdrawERC20FromLockbox = function (erc20, overrides) {
        if (overrides === void 0) { overrides = {}; }
        return __awaiter(this, void 0, void 0, function () {
            var globalInbox;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this.globalInbox()];
                    case 1:
                        globalInbox = _a.sent();
                        return [2 /*return*/, globalInbox.withdrawERC20(erc20, overrides)];
                }
            });
        });
    };
    L1Bridge.prototype.withdrawERC721FromLockbox = function (erc721, tokenId, overrides) {
        if (overrides === void 0) { overrides = {}; }
        return __awaiter(this, void 0, void 0, function () {
            var globalInbox;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this.globalInbox()];
                    case 1:
                        globalInbox = _a.sent();
                        return [2 /*return*/, globalInbox.withdrawERC721(erc721, tokenId, overrides)];
                }
            });
        });
    };
    L1Bridge.prototype.depositERC20 = function (to, erc20, value, overrides) {
        if (overrides === void 0) { overrides = {}; }
        return __awaiter(this, void 0, void 0, function () {
            var globalInbox, _a, _b;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0: return [4 /*yield*/, this.globalInbox()];
                    case 1:
                        globalInbox = _c.sent();
                        _b = (_a = globalInbox).depositERC20Message;
                        return [4 /*yield*/, this.chainAddress];
                    case 2: return [2 /*return*/, _b.apply(_a, [_c.sent(), erc20,
                            to,
                            value,
                            overrides])];
                }
            });
        });
    };
    L1Bridge.prototype.depositERC721 = function (to, erc721, tokenId, overrides) {
        if (overrides === void 0) { overrides = {}; }
        return __awaiter(this, void 0, void 0, function () {
            var globalInbox, _a, _b;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0: return [4 /*yield*/, this.globalInbox()];
                    case 1:
                        globalInbox = _c.sent();
                        _b = (_a = globalInbox).depositERC721Message;
                        return [4 /*yield*/, this.chainAddress];
                    case 2: return [2 /*return*/, _b.apply(_a, [_c.sent(), erc721,
                            to,
                            tokenId,
                            overrides])];
                }
            });
        });
    };
    L1Bridge.prototype.depositETH = function (to, value, overrides) {
        if (overrides === void 0) { overrides = {}; }
        return __awaiter(this, void 0, void 0, function () {
            var globalInbox, _a, _b;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0: return [4 /*yield*/, this.globalInbox()];
                    case 1:
                        globalInbox = _c.sent();
                        _b = (_a = globalInbox).depositEthMessage;
                        return [4 /*yield*/, this.chainAddress];
                    case 2: return [2 /*return*/, _b.apply(_a, [_c.sent(), to, __assign(__assign({}, overrides), { value: value })])];
                }
            });
        });
    };
    L1Bridge.prototype.transferPayment = function (originalOwner, newOwner, messageIndex, overrides) {
        if (overrides === void 0) { overrides = {}; }
        return __awaiter(this, void 0, void 0, function () {
            var globalInbox;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this.globalInbox()];
                    case 1:
                        globalInbox = _a.sent();
                        return [2 /*return*/, globalInbox.transferPayment(originalOwner, newOwner, messageIndex, overrides)];
                }
            });
        });
    };
    L1Bridge.prototype.sendL2Message = function (l2tx, from, overrides) {
        if (overrides === void 0) { overrides = {}; }
        return __awaiter(this, void 0, void 0, function () {
            var walletAddress, globalInbox, _a, _b;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0: return [4 /*yield*/, this.signer.getAddress()];
                    case 1:
                        walletAddress = _c.sent();
                        if (from.toLowerCase() != walletAddress.toLowerCase()) {
                            throw Error("Can only send from wallet address " + from + ", but tried to send from " + walletAddress);
                        }
                        return [4 /*yield*/, this.globalInbox()];
                    case 2:
                        globalInbox = _c.sent();
                        _b = (_a = globalInbox).sendL2Message;
                        return [4 /*yield*/, this.chainAddress];
                    case 3: return [2 /*return*/, _b.apply(_a, [_c.sent(), new message_1.L2Message(l2tx).asData(),
                            overrides])];
                }
            });
        });
    };
    L1Bridge.prototype.getEthLockBoxBalance = function (address) {
        return __awaiter(this, void 0, void 0, function () {
            var globalInbox;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this.globalInbox()];
                    case 1:
                        globalInbox = _a.sent();
                        return [2 /*return*/, globalInbox.getEthBalance(address)];
                }
            });
        });
    };
    L1Bridge.prototype.getERC20LockBoxBalance = function (contractAddress, ownerAddress) {
        return __awaiter(this, void 0, void 0, function () {
            var globalInbox;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this.globalInbox()];
                    case 1:
                        globalInbox = _a.sent();
                        return [2 /*return*/, globalInbox.getERC20Balance(contractAddress, ownerAddress)];
                }
            });
        });
    };
    L1Bridge.prototype.getERC721LockBoxTokens = function (contractAddress, ownerAddress) {
        return __awaiter(this, void 0, void 0, function () {
            var globalInbox;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this.globalInbox()];
                    case 1:
                        globalInbox = _a.sent();
                        return [2 /*return*/, globalInbox.getERC721Tokens(contractAddress, ownerAddress)];
                }
            });
        });
    };
    return L1Bridge;
}());
exports.L1Bridge = L1Bridge;
