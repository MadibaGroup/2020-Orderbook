import { ContractFactory, Signer } from 'ethers';
import { Provider } from 'ethers/providers';
import { UnsignedTransaction } from 'ethers/utils/transaction';
import { TransactionOverrides } from '.';
import { ArbErc20 } from './ArbErc20';
export declare class ArbErc20Factory extends ContractFactory {
    constructor(signer?: Signer);
    deploy(overrides?: TransactionOverrides): Promise<ArbErc20>;
    getDeployTransaction(overrides?: TransactionOverrides): UnsignedTransaction;
    attach(address: string): ArbErc20;
    connect(signer: Signer): ArbErc20Factory;
    static connect(address: string, signerOrProvider: Signer | Provider): ArbErc20;
}
