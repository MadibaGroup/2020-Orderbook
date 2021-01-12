import { TransactionOverrides } from './abi';
import * as ethers from 'ethers';
export declare function withdrawEth(l2signer: ethers.Signer, value: ethers.utils.BigNumberish, overrides?: TransactionOverrides): Promise<ethers.providers.TransactionResponse>;
