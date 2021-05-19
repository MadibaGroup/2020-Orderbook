import { Signer } from 'ethers';
import { Provider } from '@ethersproject/providers';
import type { IEthERC20Bridge } from '../IEthERC20Bridge';
export declare class IEthERC20Bridge__factory {
    static connect(address: string, signerOrProvider: Signer | Provider): IEthERC20Bridge;
}
