import * as ethers from 'ethers';
export declare const MAX_TUPLE_SIZE = 8;
export declare enum ValueType {
    Int = 0,
    CodePoint = 1,
    HashOnly = 2,
    Tuple = 3,
    TupleMax
}
export declare enum OperationType {
    Basic = 0,
    Immediate = 1
}
export declare type Operation = BasicOp | ImmOp;
export declare class BasicOp {
    opcode: number;
    kind: OperationType.Basic;
    constructor(opcode: number);
}
export declare class ImmOp {
    opcode: number;
    value: Value;
    kind: OperationType.Immediate;
    constructor(opcode: number, value: Value);
}
export declare type Value = IntValue | TupleValue | CodePointValue;
export declare class IntValue {
    bignum: ethers.utils.BigNumber;
    constructor(bignum: ethers.utils.BigNumberish);
    typeCode(): ValueType;
    hash(): string;
    toString(): string;
    size(): ethers.utils.BigNumber;
}
export declare class CodePointValue {
    op: Operation;
    nextHash: string;
    constructor(op: Operation, nextHash: string);
    typeCode(): ValueType;
    hash(): string;
    toString(): string;
    size(): ethers.utils.BigNumber;
}
export declare class TupleValue {
    contents: Value[];
    cachedHash: string;
    constructor(contents: Value[]);
    typeCode(): ValueType;
    hash(): string;
    size(): ethers.utils.BigNumber;
    get(index: number): Value;
    set(index: number, value: Value): TupleValue;
    toString(): string;
}
export declare function bytestackToBytes(twoTupleValue: TupleValue): Uint8Array;
export declare function hexToBytestack(hex: ethers.utils.Arrayish): TupleValue;
export declare function marshal(someValue: Value): Uint8Array;
export declare function unmarshal(array: ethers.utils.Arrayish, offset?: number): Value;
