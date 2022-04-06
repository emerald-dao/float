import { config } from "@samatech/onflow-fcl-esm";

config({
  "accessNode.api": import.meta.env.VITE_ACCESS_NODE_API,
  "discovery.wallet": import.meta.env.VITE_DISCOVERY_WALLET,
  "0xFLOAT": "0x0afe396ebc8eee65", // "0xf8d6e0586b0a20c7", // "0x2d4c3caffbeab845",
  "0xCORE": "0x631e88ae7f1d7c20", // "0xf8d6e0586b0a20c7", // "0x1d7e57aa55817448",
  "0xFLOWTOKEN": "0x7e60df042a9c0868", // "0x0ae53cb6e3f42a79",
  "0xFUNGIBLETOKEN": "0x9a0766d93b6608b7", // "0xee82856bf20e2aa6",
  "0xFN": "", // "0x233eb012d34b0070",
  "0xFIND": "", // "0x097bafa4e0b48eef"
})