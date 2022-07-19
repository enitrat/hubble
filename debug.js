const { Account, defaultProvider, ec, number } = require("starknet");

const ADDRESS =
  "0x077F4F677c12b6f570F9bEE5503eF3D79678942FC5F016747AA80D040E6582C9".toLowerCase();
const PK =
  "0x6FD3959EDFD22728B442CFD46FECCFBF04BAA56A949574069A37F96CD26C3AD".toLowerCase();

async function main() {
  const starkPair = ec.getKeyPair(PK);
  const acc = new Account(defaultProvider, ADDRESS, starkPair);
  const tx = await acc.execute(
    {
      contractAddress:
        "0x0439266a28234669b8d336411853dd9b594c8c6422661d81a6af0d2f3b585fa9",
      entrypoint: "get_all_routes",
      calldata: [
        number.toFelt(
          "0x005a643907b9a4bc6a55e9069c4fd5fd1f5c79a22470690f75556c4736e34426"
        ),
        number.toFelt(
          "0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7"
        ),
        5,
      ],
    },
    undefined,
    { maxFee: "1000000000000" }
  );
  console.log(tx);
}
main();
