import { Box } from "@chakra-ui/react";
import dynamic from "next/dynamic";

import CTASection from "components/samples/CTASection";
import SomeText from "components/samples/SomeText";
import { MintTokens, Transactions } from "components/wallet";

const Home = () => {
  // Create a psuedo component using dynamic import that will only be imported client-side
  const Chart = dynamic(() => import("../components/charts/Chart"), {
    ssr: false,
  });

  return (
    <Box mb={8} w="full" h="full" d="flex" flexDirection="column">
      <Box flex="1 1 auto">
        <MintTokens />
      </Box>
      <Chart id="chartdiv" />
    </Box>
  );
};

export default Home;
