/** @type {import('next-seo').DefaultSeoProps} */
const defaultSEOConfig = {
  title: "hubble",
  titleTemplate: "%s",
  defaultTitle: "hubble",
  description: "Flexible Starknet Dapp Template",
  canonical: "https://nextarter-chakra.sznm.dev",
  openGraph: {
    url: "https://nextarter-chakra.sznm.dev",
    title: "hubble",
    description: "Flexible Starknet Dapp Template",
    images: [
      {
        url: "https://cairopal.xyz/cairopal.png",
        alt: "hubble hubble",
      },
    ],
    site_name: "hubble",
  },
  twitter: {
    handle: "@a5f9t4",
    cardType: "summary_large_image",
  },
};

export default defaultSEOConfig;
