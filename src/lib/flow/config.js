import { config } from "@onflow/fcl";

config({
  "app.detail.title": "FLOAT", // Shows user what dapp is trying to connect
  "app.detail.icon": "https://floats.city/floatlogo_big.png", // shows image to the user to display your dapp brand
  "accessNode.api": import.meta.env.VITE_ACCESS_NODE_API, // import.meta.env.VITE_ACCESS_NODE_API,
  "0xFLOAT": import.meta.env.VITE_FLOAT_ADDRESS,
  "0xCORE": import.meta.env.VITE_CORE_ADDRESS,
  "0xFLOWTOKEN": import.meta.env.VITE_FLOWTOKEN_ADDRESS,
  "0xFUNGIBLETOKEN": import.meta.env.VITE_FUNGIBLETOKEN_ADDRESS,
  "0xFN": "0x233eb012d34b0070",
  "0xFIND": "0x097bafa4e0b48eef",
  "0xFLOWSTORAGEFEES": "0xe467b9dd11fa00df"
})

const isTestnet = import.meta.env.VITE_FLOW_NETWORK === 'testnet'
const floatEventSeriesAddress = import.meta.env.VITE_FLOAT_EVENTSERIES_ADDRESS || (isTestnet ? "0x78ba14dd1c817ec7" : "0x1dd5caae66e2c440")

export const addressMap = {
  FlowToken: import.meta.env.VITE_FLOWTOKEN_ADDRESS,
  FungibleToken: import.meta.env.VITE_FUNGIBLETOKEN_ADDRESS,
  NonFungibleToken: import.meta.env.VITE_CORE_ADDRESS,
  MetadataViews: import.meta.env.VITE_CORE_ADDRESS,
  FLOAT: import.meta.env.VITE_FLOAT_ADDRESS,
  FLOATVerifiers: import.meta.env.VITE_FLOAT_ADDRESS,
  GrantedAccountAccess: import.meta.env.VITE_FLOAT_ADDRESS,
  FLOATEventSeries: floatEventSeriesAddress,
  FLOATEventSeriesViews: floatEventSeriesAddress,
  FLOATEventSeriesGoals: floatEventSeriesAddress,
  FLOATTreasuryStrategies: floatEventSeriesAddress,
  EmeraldPass: import.meta.env.VITE_EMERALD_PASS_ADDRESS || (isTestnet ? "0x88b6d0be84df0918" : "0x6a07dbeb03167a13"),
  NFTCatalog: isTestnet ? "0x324c34e1c517e4db" : "0x49a7cda3a1eecc29",
  NFTRetrieval: isTestnet ? "0x324c34e1c517e4db" : "0x49a7cda3a1eecc29",
}

export const verifiersIdentifier = 'A.2d4c3caffbeab845';
export const flowTokenIdentifier = 'A.1654653399040a61';
export const secretSalt = import.meta.env.VITE_SECRET_SALT;