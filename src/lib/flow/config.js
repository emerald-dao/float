import { config } from "@onflow/config";

config({
  "flow.network": "mainnet",
  "app.detail.title": "FLOAT", // Shows user what dapp is trying to connect
  "app.detail.icon": "https://floats.city/floatlogo_big.png", // shows image to the user to display your dapp brand
  "accessNode.api": "https://rest-mainnet.onflow.org", 
  "discovery.wallet": "https://fcl-discovery.onflow.org/authn", // import.meta.env.VITE_DISCOVERY_WALLET,
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