import { config } from "@samatech/onflow-fcl-esm";

config({
  "accessNode.api": import.meta.env.VITE_ACCESS_NODE_API,
  "discovery.wallet": import.meta.env.VITE_DISCOVERY_WALLET,
  "0xFLOAT": "0x2d4c3caffbeab845",
  "0xCORE": "0x1d7e57aa55817448",
  "0xFN": "0x233eb012d34b0070",
  "0xFIND": "0x097bafa4e0b48eef"
})