import { Signer } from 'ethers';
import { Provider } from '@ethersproject/providers';
import type { IERC1363Receiver } from '../IERC1363Receiver';
export declare class IERC1363Receiver__factory {
    static connect(address: string, signerOrProvider: Signer | Provider): IERC1363Receiver;
}
