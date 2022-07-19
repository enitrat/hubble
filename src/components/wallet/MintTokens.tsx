import {
  Box,
  Button,
  Code, Flex,
  Link, Menu, MenuButton, MenuItem, MenuList,
  Text,
  useBreakpointValue,
  useColorMode,
} from "@chakra-ui/react";
import {stark} from "starknet";

import {useStarknet} from "context";
import {ArrowRightIcon, ChevronDownIcon} from "@chakra-ui/icons";
import {useState} from "react";
import tokens, {pairs} from "../../../constants/pairs";


const MintTokens = () => {
  const CONTRACT_ADDRESS =
    "0x06a09ccb1caaecf3d9683efe335a667b2169a409d19c589ba1eb771cd210af75";

  const {connected, library} = useStarknet();
  const {colorMode} = useColorMode();
  const textSize = useBreakpointValue({
    base: "xs",
    sm: "md",
  });
  const [tokenFrom, setTokenFrom] = useState(pairs[0].token0);
  const [tokenTo, setTokenTo] = useState(pairs[0].token1);

  // const { getSelectorFromName } = stark;
  // const selector = getSelectorFromName("mint");

  const mintTokens = async () => {
    const mintTokenResponse = await library.addTransaction({
      type: "INVOKE_FUNCTION",
      contract_address: CONTRACT_ADDRESS,
      // entry_point_selector: selector,
      calldata: [
        "25337092028752943692105536859798085962999747221745650943814125673320853150",
        "10000000000000000000",
        "0",
      ],
    });
    // eslint-disable-next-line no-console
    console.log(mintTokenResponse);
  };

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
