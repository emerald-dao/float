export const isFlowAddr = (address) => {
  return /^0x[0-9a-f]{16}$/.test(address)
}

export const ellipseStr = (str = '', start = 4, end = 4) => {
  return `${str.slice(0, start)}...${str.slice(-end)}`
}

export const logoPaths = {
  eid: '/emeraldcitylogo.png',
  find: '/findlogo.png',
  fn: '/flownslogo.png',
}
// export const isFindName = (search) => {
//   //force lower case
//   let searchName = search.toLowerCase()
//   searchName = searchName.replace(/\b(.find)\b/i, '')
//   searchName = searchName.replace(/[^a-z0-9-]/g, '')
//   //return if input is out of range
//   if (!searchName || searchName.length > 18 || searchName.length < 3) {
//     return false
//   }
//   //is it an address or a name?

//   if (searchName.length <= 16) {
//     return searchName
//   } else {
//     return false
//   }
// }

// export const isFlownsName = (search) => {
//   const domainReg = /^[a-z0-9-]{2,30}.[a-z0-9-_]{1,10}$/
//   // todo
// }
