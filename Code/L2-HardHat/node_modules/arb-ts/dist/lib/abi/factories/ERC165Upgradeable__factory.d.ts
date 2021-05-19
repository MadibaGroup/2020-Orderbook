import { Signer } from 'ethers';
import { Provider } from '@ethersproject/providers';
import type { ERC165Upgradeable } from '../ERC165Upgradeable';
export declare class ERC165Upgradeable__factory {
    static connect(address: string, signerOrProvider: Signer | Provider): ERC165Upgradeable;
}
