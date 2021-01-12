import { ContractFactory, Signer } from 'ethers';
import { Provider } from 'ethers/providers';
import { UnsignedTransaction } from 'ethers/utils/transaction';
import { TransactionOverrides } from '.';
import { ArbInfo } from './ArbInfo';
export declare class ArbInfoFactory extends ContractFactory {
    constructor(signer?: Signer);
    deploy(overrides?: TransactionOverrides): Promise<ArbInfo>;
    getDeployTransaction(overrides?: TransactionOverrides): UnsignedTransaction;
    attach(address: string): ArbInfo;
    connect(signer: Signer): ArbInfoFactory;
    static connect(address: string, signerOrProvider: Signer | Provider): ArbInfo;
}
