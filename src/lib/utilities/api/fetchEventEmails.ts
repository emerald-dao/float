import { user } from "$stores/flow/FlowStore";
import { get } from "svelte/store";

export async function fetchEventEmails(eventId: string) {
  const response = await fetch(`/api/events/get-emails/${eventId}`, {
    method: 'POST',
    body: JSON.stringify({
      user: get(user)
    }),
    headers: {
      'content-type': 'application/json'
    }
  });
  return await response.json();
}