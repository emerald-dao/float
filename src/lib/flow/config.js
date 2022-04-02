import {config} from "@samatech/onflow-fcl-esm";

config({
  "app.detail.title": "FLOAT",
  "app.detail.icon": "https://i.imgur.com/WJMROey.png",
  "accessNode.api": import.meta.env.VITE_ACCESS_NODE_API,
  "discovery.wallet": import.meta.env.VITE_DISCOVERY_WALLET,
  "0xFLOAT": import.meta.env.VITE_FLOAT_ADDRESS,
  "0xCORE": import.meta.env.VITE_CORE_ADDRESS,
  "0xFN": import.meta.env.VITE_FN_ADDRESS,
  "0xFIND": import.meta.env.VITE_FIND_ADDRESS
})