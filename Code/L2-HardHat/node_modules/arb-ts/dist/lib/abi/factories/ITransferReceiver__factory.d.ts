import { Signer } from 'ethers';
import { Provider } from '@ethersproject/providers';
import type { ITransferReceiver } from '../ITransferReceiver';
export declare class ITransferReceiver__factory {
    static connect(address: string, signerOrProvider: Signer | Provider): ITransferReceiver;
}
