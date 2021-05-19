import { Signer } from 'ethers';
import { Provider } from '@ethersproject/providers';
import type { IERC165Upgradeable } from '../IERC165Upgradeable';
export declare class IERC165Upgradeable__factory {
    static connect(address: string, signerOrProvider: Signer | Provider): IERC165Upgradeable;
}
