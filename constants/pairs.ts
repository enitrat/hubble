const tokens = [
  {
    name: "ETH",
    address: "123456"
  },
  {
    name: "DAI",
    address: "582893"
  },
  {
    name: "CMP",
    address: "898762"
  },
  {
    name: "AAVE",
    address: "769863"
  }
];

const pairs = [
  {
    token0: tokens[0],
    token1: tokens[1]
  },
  {
    token0: tokens[3],
    token1: tokens[2]
  },
  {
    token0: tokens[0],
    token1: tokens[2]
  },
  {
    token0: tokens[1],
    token1: tokens[3]
  },
]

export {pairs};
export default tokens;
