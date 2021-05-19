import { Signer } from 'ethers';
import { Provider } from '@ethersproject/providers';
import type { IArbTokenBridge } from '../IArbTokenBridge';
export declare class IArbTokenBridge__factory {
    static connect(address: string, signerOrProvider: Signer | Provider): IArbTokenBridge;
}
