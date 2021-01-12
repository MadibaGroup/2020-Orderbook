import * as ArbValue from './value';
import * as ethers from 'ethers';
export declare function marshaledBytesHash(data: Uint8Array): string;
export declare enum L2MessageCode {
    Transaction = 0,
    ContractTransaction = 1,
    Call = 2,
    TransactionBatch = 3,
    SignedTransaction = 4
}
export declare class L2Transaction {
    maxGas: ethers.utils.BigNumber;
    gasPriceBid: ethers.utils.BigNumber;
    sequenceNum: ethers.utils.BigNumber;
    destAddress: string;
    payment: ethers.utils.BigNumber;
    calldata: string;
    kind: L2MessageCode.Transaction;
    constructor(maxGas: ethers.utils.BigNumberish, gasPriceBid: ethers.utils.BigNumberish, sequenceNum: ethers.utils.BigNumberish, destAddress: ethers.utils.Arrayish | undefined, payment: ethers.utils.BigNumberish | undefined, calldata: ethers.utils.Arrayish | undefined);
    static fromData(data: ethers.utils.Arrayish): L2Transaction;
    asData(): Uint8Array;
    messageID(sender: string, chainId: number): string;
}
export declare class L2SignedTransaction {
    tx: L2Transaction;
    sig: string;
    kind: L2MessageCode.SignedTransaction;
    constructor(tx: L2Transaction, sig: string);
    static fromData(data: ethers.utils.Arrayish): L2SignedTransaction;
    asData(): Uint8Array;
}
export declare class L2Batch {
    messages: L2Message[];
    kind: L2MessageCode.TransactionBatch;
    constructor(messages: L2Message[]);
    static fromData(data: ethers.utils.Arrayish): L2Batch;
    asData(): Uint8Array;
}
export declare class L2Call {
    maxGas: ethers.utils.BigNumber;
    gasPriceBid: ethers.utils.BigNumber;
    destAddress: string;
    calldata: string;
    kind: L2MessageCode.Call;
    constructor(maxGas: ethers.utils.BigNumberish | undefined, gasPriceBid: ethers.utils.BigNumberish | undefined, destAddress: ethers.utils.Arrayish | undefined, calldata: ethers.utils.Arrayish | undefined);
    static fromData(data: ethers.utils.Arrayish): L2Call;
    asData(): Uint8Array;
}
export declare class L2ContractTransaction {
    maxGas: ethers.utils.BigNumber;
    gasPriceBid: ethers.utils.BigNumber;
    destAddress: string;
    payment: ethers.utils.BigNumber;
    calldata: string;
    kind: L2MessageCode.ContractTransaction;
    constructor(maxGas: ethers.utils.BigNumberish | undefined, gasPriceBid: ethers.utils.BigNumberish | undefined, destAddress: ethers.utils.Arrayish | undefined, payment: ethers.utils.BigNumberish | undefined, calldata: ethers.utils.Arrayish | undefined);
    static fromData(data: ethers.utils.Arrayish): L2ContractTransaction;
    asData(): Uint8Array;
}
export declare type L2SubMessage = L2Transaction | L2Call | L2ContractTransaction | L2Batch | L2SignedTransaction;
export declare enum MessageCode {
    Eth = 0,
    ERC20 = 1,
    ERC721 = 2,
    L2 = 3,
    Initialization = 4,
    BuddyRegistered = 5
}
export declare class BuddyRegisteredMessage {
    valid: boolean;
    kind: MessageCode.BuddyRegistered;
    constructor(valid: boolean);
    static fromData(data: ethers.utils.Arrayish): BuddyRegisteredMessage;
    asData(): Uint8Array;
}
export declare class EthMessage {
    kind: MessageCode.Eth;
    dest: ethers.utils.Arrayish;
    value: ethers.utils.BigNumber;
    constructor(dest: string, value: ethers.utils.BigNumberish);
    static fromData(data: ethers.utils.Arrayish): EthMessage;
    asData(): Uint8Array;
}
export declare class ERC20Message {
    kind: MessageCode.ERC20;
    tokenAddress: string;
    dest: string;
    value: ethers.utils.BigNumber;
    constructor(tokenAddress: ethers.utils.Arrayish, dest: ethers.utils.Arrayish, value: ethers.utils.BigNumberish);
    static fromData(data: ethers.utils.Arrayish): ERC20Message;
    asData(): Uint8Array;
}
export declare class ERC721Message {
    kind: MessageCode.ERC721;
    tokenAddress: string;
    dest: string;
    id: ethers.utils.BigNumber;
    constructor(tokenAddress: ethers.utils.Arrayish, dest: ethers.utils.Arrayish, id: ethers.utils.BigNumberish);
    static fromData(data: ethers.utils.Arrayish): ERC721Message;
    asData(): Uint8Array;
}
export declare class L2Message {
    message: L2SubMessage;
    kind: MessageCode.L2;
    constructor(message: L2SubMessage);
    static fromData(data: ethers.utils.Arrayish): L2Message;
    asData(): Uint8Array;
}
export declare type Message = EthMessage | ERC20Message | ERC721Message | L2Message;
export declare type OutMessage = EthMessage | ERC20Message | ERC721Message | BuddyRegisteredMessage;
export declare class IncomingMessage {
    msg: Message;
    blockNumber: ethers.utils.BigNumber;
    timestamp: ethers.utils.BigNumber;
    sender: string;
    inboxSeqNum: ethers.utils.BigNumber;
    constructor(msg: Message, blockNumber: ethers.utils.BigNumberish, timestamp: ethers.utils.BigNumberish, sender: string, inboxSeqNum: ethers.utils.BigNumberish);
    static fromValue(val: ArbValue.Value): IncomingMessage;
    asValue(): ArbValue.Value;
    commitmentHash(): string;
    messageID(): string;
}
export declare class OutgoingMessage {
    msg: OutMessage;
    sender: string;
    constructor(msg: OutMessage, sender: string);
    asValue(): ArbValue.Value;
}
export declare enum ResultCode {
    Return = 0,
    Revert = 1,
    Congestion = 2,
    InsufficientGasFunds = 3,
    InsufficientTxFunds = 4,
    BadSequenceCode = 5,
    InvalidMessageFormatCode = 6,
    UnknownErrorCode = 255
}
export declare class Log {
    address: string;
    topics: string[];
    data: string;
    constructor(address: string, topics: string[], data: string);
    static fromValue(val: ArbValue.Value): Log;
    asValue(): ArbValue.Value;
}
export declare class Result {
    incoming: IncomingMessage;
    resultCode: ResultCode;
    returnData: Uint8Array;
    logs: Log[];
    gasUsed: ethers.utils.BigNumber;
    gasPrice: ethers.utils.BigNumber;
    cumulativeGas: ethers.utils.BigNumber;
    txIndex: ethers.utils.BigNumber;
    startLogIndex: ethers.utils.BigNumber;
    constructor(incoming: IncomingMessage, resultCode: ResultCode, returnData: Uint8Array, logs: Log[], gasUsed: ethers.utils.BigNumberish, gasPrice: ethers.utils.BigNumberish, cumulativeGas: ethers.utils.BigNumberish, txIndex: ethers.utils.BigNumberish, startLogIndex: ethers.utils.BigNumberish);
    static fromValue(val: ArbValue.Value): Result;
    asValue(): ArbValue.Value;
}
