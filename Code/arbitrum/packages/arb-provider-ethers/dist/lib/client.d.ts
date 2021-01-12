import * as ArbValue from './value';
import { L2ContractTransaction } from './message';
import * as ethers from 'ethers';
import evm from './abi/evm.evm.d';
interface OutputMessage {
    outputMsg: ArbValue.Value;
}
export declare class ArbClient {
    client: any;
    constructor(managerUrl: string);
    sendTransaction(signedTransaction: string): Promise<string>;
    getBlockCount(): Promise<number>;
    getOutputMessage(index: number): Promise<OutputMessage>;
    getRequestResult(txHash: string): Promise<ArbValue.Value | null>;
    private _call;
    call(tx: L2ContractTransaction, sender: string | undefined): Promise<ArbValue.Value | undefined>;
    pendingCall(tx: L2ContractTransaction, sender: string | undefined): Promise<ArbValue.Value | undefined>;
    findLogs(filter: ethers.providers.Filter): Promise<evm.FullLogBuf[]>;
    getChainAddress(): Promise<string>;
}
export {};
