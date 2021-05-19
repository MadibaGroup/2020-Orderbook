import { Signer } from 'ethers';
import { Provider } from '@ethersproject/providers';
import type { IRollup } from '../IRollup';
export declare class IRollup__factory {
    static connect(address: string, signerOrProvider: Signer | Provider): IRollup;
}
