import { Signer } from 'ethers';
import { Provider } from '@ethersproject/providers';
import type { TokenAddressHandler } from '../TokenAddressHandler';
export declare class TokenAddressHandler__factory {
    static connect(address: string, signerOrProvider: Signer | Provider): TokenAddressHandler;
}
