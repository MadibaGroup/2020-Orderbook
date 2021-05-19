import { Signer } from 'ethers';
import { Provider } from '@ethersproject/providers';
import type { IERC1363 } from '../IERC1363';
export declare class IERC1363__factory {
    static connect(address: string, signerOrProvider: Signer | Provider): IERC1363;
}
