import { Signer } from 'ethers';
import { Provider, TransactionRequest } from '@ethersproject/providers';
import { ContractFactory, Overrides } from '@ethersproject/contracts';
import type { EthERC20Bridge } from '../EthERC20Bridge';
export declare class EthERC20Bridge__factory extends ContractFactory {
    constructor(signer?: Signer);
    deploy(overrides?: Overrides): Promise<EthERC20Bridge>;
    getDeployTransaction(overrides?: Overrides): TransactionRequest;
    attach(address: string): EthERC20Bridge;
    connect(signer: Signer): EthERC20Bridge__factory;
    static connect(address: string, signerOrProvider: Signer | Provider): EthERC20Bridge;
}
