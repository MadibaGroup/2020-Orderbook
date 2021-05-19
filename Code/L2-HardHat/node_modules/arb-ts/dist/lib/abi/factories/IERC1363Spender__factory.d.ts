import { Signer } from 'ethers';
import { Provider } from '@ethersproject/providers';
import type { IERC1363Spender } from '../IERC1363Spender';
export declare class IERC1363Spender__factory {
    static connect(address: string, signerOrProvider: Signer | Provider): IERC1363Spender;
}
