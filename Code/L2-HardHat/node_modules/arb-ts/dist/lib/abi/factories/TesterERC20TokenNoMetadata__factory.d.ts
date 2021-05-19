import { Signer } from 'ethers';
import { Provider, TransactionRequest } from '@ethersproject/providers';
import { ContractFactory, Overrides } from '@ethersproject/contracts';
import type { TesterERC20TokenNoMetadata } from '../TesterERC20TokenNoMetadata';
export declare class TesterERC20TokenNoMetadata__factory extends ContractFactory {
    constructor(signer?: Signer);
    deploy(overrides?: Overrides): Promise<TesterERC20TokenNoMetadata>;
    getDeployTransaction(overrides?: Overrides): TransactionRequest;
    attach(address: string): TesterERC20TokenNoMetadata;
    connect(signer: Signer): TesterERC20TokenNoMetadata__factory;
    static connect(address: string, signerOrProvider: Signer | Provider): TesterERC20TokenNoMetadata;
}
