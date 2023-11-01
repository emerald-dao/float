export async function signUserProvidedEmail(userAddress: string, eventId: string) {
  const res = await fetch(`/api/get-sig-from-email/${eventId}/${userAddress}`);
  const response = await res.json();
  return response;

}