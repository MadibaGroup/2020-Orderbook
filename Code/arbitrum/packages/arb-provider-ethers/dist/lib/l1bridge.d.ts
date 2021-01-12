import { L2Transaction } from './message';
import { GlobalInbox } from './abi/GlobalInbox';
import { TransactionOverrides } from './abi';
import { TransactionResponse } from 'ethers/providers';
import { BigNumberish, BigNumber } from 'ethers/utils';
import { Signer } from 'ethers';
export declare class L1Bridge {
    signer: Signer;
    chainAddress: string | Promise<string>;
    globalInboxCache?: GlobalInbox;
    constructor(signer: Signer, chainAddress: string | Promise<string>);
    globalInbox(): Promise<GlobalInbox>;
    withdrawEthFromLockbox(): Promise<TransactionResponse>;
    withdrawERC20FromLockbox(erc20: string, overrides?: TransactionOverrides): Promise<TransactionResponse>;
    withdrawERC721FromLockbox(erc721: string, tokenId: BigNumberish, overrides?: TransactionOverrides): Promise<TransactionResponse>;
    depositERC20(to: string, erc20: string, value: BigNumberish, overrides?: TransactionOverrides): Promise<TransactionResponse>;
    depositERC721(to: string, erc721: string, tokenId: BigNumberish, overrides?: TransactionOverrides): Promise<TransactionResponse>;
    depositETH(to: string, value: BigNumberish, overrides?: TransactionOverrides): Promise<TransactionResponse>;
    transferPayment(originalOwner: string, newOwner: string, messageIndex: BigNumberish, overrides?: TransactionOverrides): Promise<TransactionResponse>;
    sendL2Message(l2tx: L2Transaction, from: string, overrides?: TransactionOverrides): Promise<TransactionResponse>;
    getEthLockBoxBalance(address: string): Promise<BigNumber>;
    getERC20LockBoxBalance(contractAddress: string, ownerAddress: string): Promise<BigNumber>;
    getERC721LockBoxTokens(contractAddress: string, ownerAddress: string): Promise<BigNumber[]>;
}
