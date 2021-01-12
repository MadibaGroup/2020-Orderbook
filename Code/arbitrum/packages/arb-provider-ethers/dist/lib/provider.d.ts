import { Result } from './message';
import { ArbClient } from './client';
import * as ArbValue from './value';
import { ArbWallet } from './wallet';
import * as ethers from 'ethers';
import { ArbRollup } from './abi/ArbRollup';
import { GlobalInbox } from './abi/GlobalInbox';
import { ArbSys } from './abi/ArbSys';
export interface AVMProof {
    logPreHash: string;
    logValHashes: string[];
}
interface VerifyMessageResult {
    value: ArbValue.Value;
}
export declare class ArbProvider extends ethers.providers.BaseProvider {
    ethProvider: ethers.providers.JsonRpcProvider;
    client: ArbClient;
    chainAddress: Promise<string>;
    private arbRollupCache?;
    private globalInboxCache?;
    private validatorAddressesCache?;
    constructor(aggregatorUrl: string, provider: ethers.providers.JsonRpcProvider, chainAddress?: string | Promise<string>);
    arbRollupConn(): Promise<ArbRollup>;
    globalInboxConn(): Promise<GlobalInbox>;
    getArbSys(): ArbSys;
    getSigner(index: number): ArbWallet;
    private getArbTxId;
    getPaymentMessage(index: number): Promise<VerifyMessageResult>;
    getMessageResult(txHash: string): Promise<Result | null>;
    perform(method: string, params: any): Promise<any>;
    private callImpl;
    call(transaction: ethers.providers.TransactionRequest, blockTag?: ethers.providers.BlockTag | Promise<ethers.providers.BlockTag>): Promise<string>;
    private verifyDisputableAssertion;
}
export {};
