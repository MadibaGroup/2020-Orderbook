import { Signer, BytesLike, BigNumberish } from 'ethers';
import { Provider, TransactionRequest } from '@ethersproject/providers';
import { ContractFactory, Overrides } from '@ethersproject/contracts';
import type { TesterERC20Token } from '../TesterERC20Token';
export declare class TesterERC20Token__factory extends ContractFactory {
    constructor(signer?: Signer);
    deploy(_decimals: BigNumberish, _name: BytesLike, _symbol: BytesLike, overrides?: Overrides): Promise<TesterERC20Token>;
    getDeployTransaction(_decimals: BigNumberish, _name: BytesLike, _symbol: BytesLike, overrides?: Overrides): TransactionRequest;
    attach(address: string): TesterERC20Token;
    connect(signer: Signer): TesterERC20Token__factory;
    static connect(address: string, signerOrProvider: Signer | Provider): TesterERC20Token;
}
