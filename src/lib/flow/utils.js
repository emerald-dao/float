import {
  getUser
} from './stores.js';

export function parseErrorMessageFromFCL(errorString) {
  let newString = errorString?.replace('[Error Code: 1101] cadence runtime error Execution failed:\nerror: assertion failed:', 'Error:')
  newString = newString.replace(/-->.*/,'');
  return newString;
}

// Converts addresses. We can use this for .find and .fn later as well.
export function convertAddress(address) {
  console.log(getUser?.addr);
  if (address === getUser?.addr) {
    return "you";
  }
  return address;
}