import { config } from "@samatech/onflow-fcl-esm";

config({
  "accessNode.api": import.meta.env.VITE_ACCESS_NODE_API, // import.meta.env.VITE_ACCESS_NODE_API,
  "discovery.wallet": import.meta.env.VITE_DISCOVERY_WALLET, // import.meta.env.VITE_DISCOVERY_WALLET,
  "0xFLOAT": import.meta.env.VITE_FLOAT_ADDRESS,
  "0xCORE": import.meta.env.VITE_CORE_ADDRESS,
  "0xFLOWTOKEN": import.meta.env.VITE_FLOWTOKEN_ADDRESS,
  "0xFUNGIBLETOKEN": import.meta.env.VITE_FUNGIBLETOKEN_ADDRESS,
  "0xFN": "0x233eb012d34b0070",
  "0xFIND": "0x097bafa4e0b48eef",
  "0xFLOWSTORAGEFEES": "0xe467b9dd11fa00df"
})

export const verifiersIdentifier = 'A.0afe396ebc8eee65';
export const flowTokenIdentifier = 'A.7e60df042a9c0868';
export const secretSalt = import.meta.env.VITE_SECRET_SALT;