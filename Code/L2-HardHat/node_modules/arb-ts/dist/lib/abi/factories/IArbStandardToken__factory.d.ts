import { Signer } from 'ethers';
import { Provider } from '@ethersproject/providers';
import type { IArbStandardToken } from '../IArbStandardToken';
export declare class IArbStandardToken__factory {
    static connect(address: string, signerOrProvider: Signer | Provider): IArbStandardToken;
}
