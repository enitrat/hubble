import React from "react";
import { useStarknet } from "../StarknetProvider";
import { BlockHashContext } from "./context";
import {logger} from "ethers";

interface BlockHashProviderProps {
  children: React.ReactNode;
  interval?: number;
}

export function BlockHashProvider({
  interval,
  children,
}: BlockHashProviderProps): JSX.Element {
  const { library } = useStarknet();
  const [blockHash, setBlockHash] = React.useState<string | undefined>(
    undefined
  );

  const fetchBlockHash = React.useCallback(() => {
    try {
      library.getBlock().then((block) => {
        setBlockHash(block.block_hash);
      });
    } catch (e) {
      logger.warn(e);
    }
  }, [library]);

  React.useEffect(() => {
    fetchBlockHash();
    const intervalId = setInterval(() => {
      fetchBlockHash();
    }, interval ?? 5000);
    return () => clearInterval(intervalId);
  }, [interval, fetchBlockHash]);

  return <BlockHashContext.Provider value={blockHash} children={children} />;
}
