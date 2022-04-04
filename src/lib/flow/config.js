import { config } from "@samatech/onflow-fcl-esm";

config({
  "accessNode.api": import.meta.env.VITE_ACCESS_NODE_API,
  "discovery.wallet": import.meta.env.VITE_DISCOVERY_WALLET,
  "0xFLOAT": "0x0afe396ebc8eee65",
  "0xCORE": "0x631e88ae7f1d7c20",
  "0xFN": "0xb05b2abb42335e88",
  "0xFIND": "0xa16ab1d0abde3625"
})