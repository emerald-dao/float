/* 
Standard communications protocol:
{
  success: bool,
  body: <content>, (object)
  retryable: bool, (whether or not this action can be retried)
  error: <error>,  (contents of the error)
}
It is recommended to use the respondWith* functions, as they abstract away the object construction
*/

function respond(success, body, error, errorCode, retryable) {
  return {
    success,
    body,
    error,
    errorCode,
    retryable
  }
}

export function respondWithSuccess(body) {
  return respond(true, body || {}, null, null, false)
}

export function respondWithError(error, errorCode, retryable, body) {
  return respond(false, body || false, error, errorCode, retryable)
}