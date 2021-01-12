import { ContractFactory, Signer } from 'ethers';
import { Provider } from 'ethers/providers';
import { UnsignedTransaction } from 'ethers/utils/transaction';
import { TransactionOverrides } from '.';
import { GlobalInbox } from './GlobalInbox';
export declare class GlobalInboxFactory extends ContractFactory {
    constructor(signer?: Signer);
    deploy(overrides?: TransactionOverrides): Promise<GlobalInbox>;
    getDeployTransaction(overrides?: TransactionOverrides): UnsignedTransaction;
    attach(address: string): GlobalInbox;
    connect(signer: Signer): GlobalInboxFactory;
    static connect(address: string, signerOrProvider: Signer | Provider): GlobalInbox;
}
