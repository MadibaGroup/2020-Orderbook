import { L1Bridge } from './l1bridge';
import { L2Transaction } from './message';
import { ArbProvider } from './provider';
import { TransactionOverrides } from './abi';
import * as ethers from 'ethers';
export declare class ArbWallet extends L1Bridge implements ethers.Signer {
    l1Signer: ethers.Signer;
    provider: ArbProvider;
    constructor(l1Signer: ethers.Signer, provider: ArbProvider);
    getAddress(): Promise<string>;
    signMessage(message: ethers.utils.Arrayish | string): Promise<string>;
    depositERC20(to: string, erc20: string, value: ethers.utils.BigNumberish, overrides?: TransactionOverrides): Promise<ethers.providers.TransactionResponse>;
    depositERC721(to: string, erc721: string, tokenId: ethers.utils.BigNumberish, overrides?: TransactionOverrides): Promise<ethers.providers.TransactionResponse>;
    depositETH(to: string, value: ethers.utils.BigNumberish, overrides?: TransactionOverrides): Promise<ethers.providers.TransactionResponse>;
    sendTransactionMessage(l2tx: L2Transaction, from: string, overrides?: TransactionOverrides): Promise<ethers.providers.TransactionResponse>;
    sendTransaction(transaction: ethers.providers.TransactionRequest): Promise<ethers.providers.TransactionResponse>;
    private sendTransactionAtL1;
}
