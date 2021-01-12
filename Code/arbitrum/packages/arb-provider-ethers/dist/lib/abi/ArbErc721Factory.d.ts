import { ContractFactory, Signer } from 'ethers';
import { Provider } from 'ethers/providers';
import { UnsignedTransaction } from 'ethers/utils/transaction';
import { TransactionOverrides } from '.';
import { ArbErc721 } from './ArbErc721';
export declare class ArbErc721Factory extends ContractFactory {
    constructor(signer?: Signer);
    deploy(overrides?: TransactionOverrides): Promise<ArbErc721>;
    getDeployTransaction(overrides?: TransactionOverrides): UnsignedTransaction;
    attach(address: string): ArbErc721;
    connect(signer: Signer): ArbErc721Factory;
    static connect(address: string, signerOrProvider: Signer | Provider): ArbErc721;
}
