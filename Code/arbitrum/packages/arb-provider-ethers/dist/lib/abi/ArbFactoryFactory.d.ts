import { ContractFactory, Signer } from 'ethers';
import { Provider } from 'ethers/providers';
import { UnsignedTransaction } from 'ethers/utils/transaction';
import { TransactionOverrides } from '.';
import { ArbFactory } from './ArbFactory';
export declare class ArbFactoryFactory extends ContractFactory {
    constructor(signer?: Signer);
    deploy(_rollupTemplate: string, _globalInboxAddress: string, _challengeFactoryAddress: string, overrides?: TransactionOverrides): Promise<ArbFactory>;
    getDeployTransaction(_rollupTemplate: string, _globalInboxAddress: string, _challengeFactoryAddress: string, overrides?: TransactionOverrides): UnsignedTransaction;
    attach(address: string): ArbFactory;
    connect(signer: Signer): ArbFactoryFactory;
    static connect(address: string, signerOrProvider: Signer | Provider): ArbFactory;
}
