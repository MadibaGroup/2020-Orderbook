import { Signer } from 'ethers';
import { Provider } from '@ethersproject/providers';
import type { IArbCustomToken } from '../IArbCustomToken';
export declare class IArbCustomToken__factory {
    static connect(address: string, signerOrProvider: Signer | Provider): IArbCustomToken;
}
