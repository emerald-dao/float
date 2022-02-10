export function parseErrorMessageFromFCL(errorString) {
  let newString = errorString?.replace('[Error Code: 1101] cadence runtime error Execution failed:\nerror: assertion failed:', 'Error:')
  newString = newString.replace(/-->.*/,'');
  return newString;
}