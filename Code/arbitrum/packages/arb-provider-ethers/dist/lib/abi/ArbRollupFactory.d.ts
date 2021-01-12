import { ContractFactory, Signer } from 'ethers';
import { Provider } from 'ethers/providers';
import { UnsignedTransaction } from 'ethers/utils/transaction';
import { TransactionOverrides } from '.';
import { ArbRollup } from './ArbRollup';
export declare class ArbRollupFactory extends ContractFactory {
    constructor(signer?: Signer);
    deploy(overrides?: TransactionOverrides): Promise<ArbRollup>;
    getDeployTransaction(overrides?: TransactionOverrides): UnsignedTransaction;
    attach(address: string): ArbRollup;
    connect(signer: Signer): ArbRollupFactory;
    static connect(address: string, signerOrProvider: Signer | Provider): ArbRollup;
}
