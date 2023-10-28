export async function fetchEventEmails(eventId: string) {
  const response = await fetch(`/api/events/get-emails/${eventId}`);
  return await response.json();
}