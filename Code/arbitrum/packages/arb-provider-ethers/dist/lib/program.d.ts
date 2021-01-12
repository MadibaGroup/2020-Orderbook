import * as ArbValue from './value';
export interface CodePointRef {
    Internal: number;
}
export interface Value {
    Int?: string;
    Tuple?: Value[];
    CodePoint?: CodePointRef;
}
export interface Opcode {
    AVMOpcode: number;
}
export interface Operation {
    opcode: Opcode;
    immediate: Value | undefined;
}
export interface Program {
    code: Operation[];
    static_val: Value;
}
export declare function programMachineHash(progString: string): string;
export declare function machineHash(pc: ArbValue.Value, stack: ArbValue.Value, auxstack: ArbValue.Value, registerVal: ArbValue.Value, staticVal: ArbValue.Value, errPc: ArbValue.Value, arbGasRemaining: ArbValue.IntValue, pendingMessage: ArbValue.Value): string;
