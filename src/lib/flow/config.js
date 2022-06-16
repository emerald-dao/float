import { config } from "@onflow/fcl";

config({
  "app.detail.title": "FLOAT", // Shows user what dapp is trying to connect
  "app.detail.icon": "https://floats.city/floatlogo_big.png", // shows image to the user to display your dapp brand
  "accessNode.api": import.meta.env.VITE_ACCESS_NODE_API, // import.meta.env.VITE_ACCESS_NODE_API,
  "discovery.authn.endpoint": import.meta.env.VITE_DISCOVERY_API, // Mainnet: "https://fcl-discovery.onflow.org/api/authn"
  "0xFLOAT": import.meta.env.VITE_FLOAT_ADDRESS,
  "0xCORE": import.meta.env.VITE_CORE_ADDRESS,
  "0xFLOWTOKEN": import.meta.env.VITE_FLOWTOKEN_ADDRESS,
  "0xFUNGIBLETOKEN": import.meta.env.VITE_FUNGIBLETOKEN_ADDRESS,
  "0xFN": "0x233eb012d34b0070",
  "0xFIND": "0x097bafa4e0b48eef",
  "0xFLOWSTORAGEFEES": "0xe467b9dd11fa00df",
})

export const verifiersIdentifier = 'A.2d4c3caffbeab845';
export const flowTokenIdentifier = 'A.1654653399040a61';
export const secretSalt = import.meta.env.VITE_SECRET_SALT;