import { Signer } from 'ethers';
import { Provider } from 'ethers/providers';
import { ArbSys } from './ArbSys';
export declare class ArbSysFactory {
    static connect(address: string, signerOrProvider: Signer | Provider): ArbSys;
}
