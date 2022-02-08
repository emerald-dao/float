import { config } from '@samatech/onflow-fcl-esm'

config({
  'accessNode.api': import.meta.env.VITE_ACCESS_NODE_API,
  'discovery.wallet': import.meta.env.VITE_DISCOVERY_WALLET,
  '0xFLOAT': import.meta.env.VITE_FLOAT_ADDRESS,
  '0xNFT': import.meta.env.VITE_FLOAT_ADDRESS,
  '0xMDV': import.meta.env.VITE_FLOAT_ADDRESS,
  '0xEID': import.meta.env.VITE_EMERALDID_ADDRESS,
  '0xFIND': import.meta.env.VITE_FIND_ADDRESS,
  '0xFLOWNS': import.meta.env.VITE_FLOWNS_ADDRESS,
  '0xDOMAINS': import.meta.env.VITE_FLOWNS_ADDRESS,
})
