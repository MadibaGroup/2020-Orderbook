import { Signer } from 'ethers';
import { Provider, TransactionRequest } from '@ethersproject/providers';
import { ContractFactory, Overrides } from '@ethersproject/contracts';
import type { ArbTokenBridge } from '../ArbTokenBridge';
export declare class ArbTokenBridge__factory extends ContractFactory {
    constructor(signer?: Signer);
    deploy(overrides?: Overrides): Promise<ArbTokenBridge>;
    getDeployTransaction(overrides?: Overrides): TransactionRequest;
    attach(address: string): ArbTokenBridge;
    connect(signer: Signer): ArbTokenBridge__factory;
    static connect(address: string, signerOrProvider: Signer | Provider): ArbTokenBridge;
}
