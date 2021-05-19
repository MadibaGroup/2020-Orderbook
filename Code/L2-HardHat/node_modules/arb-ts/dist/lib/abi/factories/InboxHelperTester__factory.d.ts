import { Signer } from 'ethers';
import { Provider, TransactionRequest } from '@ethersproject/providers';
import { ContractFactory, Overrides } from '@ethersproject/contracts';
import type { InboxHelperTester } from '../InboxHelperTester';
export declare class InboxHelperTester__factory extends ContractFactory {
    constructor(signer?: Signer);
    deploy(overrides?: Overrides): Promise<InboxHelperTester>;
    getDeployTransaction(overrides?: Overrides): TransactionRequest;
    attach(address: string): InboxHelperTester;
    connect(signer: Signer): InboxHelperTester__factory;
    static connect(address: string, signerOrProvider: Signer | Provider): InboxHelperTester;
}
