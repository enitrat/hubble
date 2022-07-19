import create from "zustand";
import {AccountInterface, Provider} from "starknet";
import {disconnect, getStarknet} from "get-starknet";
import {Logger} from "ethers/lib/utils";

interface StarknetState {
  account: AccountInterface | undefined,
  provider: Provider | undefined,
  setAccount: (account: AccountInterface) => void,
  setProvider: (provider: Provider) => void,
  connectWallet: () => Promise<string|undefined>
  disconnect: () => void
}

const GOERLI_CHAIN_ID = "0x534e5f474f45524c49";
export const useStarknet = create<StarknetState>((set) => ({
    account: undefined,
    provider: undefined,
    setAccount: (account: AccountInterface) => {
      set((state) => ({...state, account: account}))
    },
    setProvider: (provider: Provider) => {
      set((state) => ({...state, provider: provider}))
    },
    connectWallet: async () => {
      Logger.globalLogger().info('Connecting.');
      const starknet = getStarknet();
      Logger.globalLogger().debug(starknet);
      await starknet.enable({showModal:true});
      Logger.globalLogger().debug(starknet);
      if(starknet.account.address==='' || !starknet.isConnected) {
        Logger.globalLogger().info('Connection failed.')
        return('Connection failed');
      }
      // @ts-ignore
      if(starknet.account.chainId!==GOERLI_CHAIN_ID) {
        Logger.globalLogger().info('Wrong chain. Use your Goerli testnet account.')
        return('Wrong chain. Use your Goerli testnet account.')
      }
      set((state) => ({...state, account: starknet.account, provider: starknet.provider}))
    },
    disconnect: () => {
      disconnect();
      set((state) => ({account: undefined, provider: undefined}))
    },
  })
)
