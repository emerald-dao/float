import { config } from "@samatech/onflow-fcl-esm";

config({
  "accessNode.api": "https://mainnet.onflow.org", // import.meta.env.VITE_ACCESS_NODE_API,
  "discovery.wallet": "https://flow-wallet.blocto.app/authn", // import.meta.env.VITE_DISCOVERY_WALLET,
  "0xFLOAT": "0x2d4c3caffbeab845",
  "0xCORE": "0x1d7e57aa55817448",
  "0xFLOWTOKEN": "0x1654653399040a61",
  "0xFUNGIBLETOKEN": "0xf233dcee88fe0abe",
  "0xFN": "0x233eb012d34b0070",
  "0xFIND": "0x097bafa4e0b48eef",
  "0xFLOWSTORAGEFEES": "0xe467b9dd11fa00df"
})

export const verifiersIdentifier = 'A.2d4c3caffbeab845';
export const flowTokenIdentifier = 'A.1654653399040a61';