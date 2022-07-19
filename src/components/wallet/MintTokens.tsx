import {
  Box,
  Button,
  Code, Flex,
  Link, Menu, MenuButton, MenuItem, MenuList,
  Text,
  useBreakpointValue,
  useColorMode,
} from "@chakra-ui/react";
import {Abi, Contract, stark} from "starknet";
import ABI from "../../abis/abi.json";

import {useStarknet} from "context";
import {ArrowRightIcon, ChevronDownIcon} from "@chakra-ui/icons";
import {useState} from "react";
import tokens, {pairs} from "../../../constants/pairs";
import {compiledErc20} from "starknet/__tests__/fixtures";


const MintTokens = () => {
  const CONTRACT_ADDRESS = "0x06ded6724e61c4d92b8271f294c79cec7a207bb602be319df7e4211d4748b5a4";

  const {connected, library} = useStarknet();
  const {colorMode} = useColorMode();
  const textSize = useBreakpointValue({
    base: "xs",
    sm: "md",
  });
  const [tokenFrom, setTokenFrom] = useState(pairs[0].token0);
  const [tokenTo, setTokenTo] = useState(pairs[0].token1);
  const [pathLoading, setPathLoading] = useState(false);
  const [bestPath, setBestPath] = useState([]);

  // const { getSelectorFromName } = stark;
  // const selector = getSelectorFromName("mint");

  const getPairs = async () => {
    const hubble = new Contract(ABI as Abi, CONTRACT_ADDRESS);

    const pairs = await hubble.get_all_routes();

    console.log(`received pairs : ${pairs}`);
  };

  const getBestPath = async () => {
    const hubble = new Contract(ABI as Abi, CONTRACT_ADDRESS);
    const pairs = await hubble.get_best_route();
    const bestTokensRoute = parseBestRoutes(pairs);
  }

  const parseBestRoutes = (hubbleResponse: any) => {
    let tokensRoute = [];
    for (let i = 1; i < hubbleResponse.length; i++) {
      tokensRoute.push(tokens.find((token) => hubbleResponse[i] === token.address));
    }
    return tokensRoute;
  }

  const getTokensTo = () => {
    return pairs
      .filter(pair => pair.token0.address === tokenFrom.address || pair.token1.address === tokenFrom.address)
  }

  return (
    <Box>
      <Text as="h2" marginTop={4} fontSize="2xl">
        Find the best route
      </Text>
      <Box d="flex" flexDirection="column" marginY={'15px'}>
        <Text>Hubble Contract:</Text>
        <Code marginTop={4} w="fit-content">
          <Link
            isExternal
            textDecoration="none !important"
            outline="none !important"
            boxShadow="none !important"
            href={`https://voyager.online/contract/${CONTRACT_ADDRESS}`}
          >
            {CONTRACT_ADDRESS}
          </Link>
        </Code>
        {connected && (
          <Flex maxW={'400px'} marginY={'15px'} justifyContent={'center'}>
            <Menu>
              <MenuButton as={Button} rightIcon={<ChevronDownIcon/>}>
                {tokenFrom.name}
              </MenuButton>
              <MenuList>
                {tokens.map(token => {
                  return (
                    <MenuItem
                      key={token.address}
                      onClick={() => {
                        setTokenFrom(token)
                      }}
                    >
                      {token.name}
                    </MenuItem>
                  );
                })}
              </MenuList>
            </Menu>
            <Box marginY={'5px'} margin={'auto'}>
              <ArrowRightIcon/>
            </Box>
            <Menu>
              <MenuButton as={Button} rightIcon={<ChevronDownIcon/>}>
                {tokenTo.name}
              </MenuButton>
              <MenuList>
                {getTokensTo()
                  .map((pair, index) => {
                    const token = pair.token0.address === tokenFrom.address ? pair.token1 : pair.token0
                    return (
                      <MenuItem
                        key={index}
                        onClick={() => {
                          setTokenTo(token)
                        }}
                      >
                        {token.name}
                      </MenuItem>
                    );
                  })}
              </MenuList>
            </Menu>
          </Flex>
        )}
        {!connected && (
          <Box
            backgroundColor={colorMode === "light" ? "gray.200" : "gray.500"}
            padding={4}
            marginTop={4}
            borderRadius={4}
          >

            <Box fontSize={textSize}>
              Connect your wallet to use hubble.
            </Box>
          </Box>
        )}
      </Box>
    </Box>
  );
};

export default MintTokens;
