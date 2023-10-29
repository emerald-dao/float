import { createClient } from '@supabase/supabase-js';
import { env as PrivateEnv } from '$env/dynamic/private';
import { env as PublicEnv } from '$env/dynamic/public';
import type { Database } from '$lib/supabase/database.types.js';
import Stripe from 'stripe';
import type { RequestHandler } from './$types';
import { json } from '@sveltejs/kit';

const supabase = createClient<Database>(
  PublicEnv.PUBLIC_SUPABASE_API_URL,
  PrivateEnv.PRIVATE_SUPABASE_SERVICE_ROLE
);

const stripe = new Stripe(PrivateEnv.STRIPE_SECRET_KEY);
const endpointSecret = PrivateEnv.STRIPE_ENDPOINT_SECRET;

export const POST: RequestHandler = async ({ request }) => {
  const body = await request.text();
  const signature = request.headers.get('stripe-signature');
  let event;

  try {
    event = stripe.webhooks.constructEvent(
      body,
      signature,
      endpointSecret
    );
  } catch (e) {
    console.log(`⚠️  Webhook signature verification failed.`, e.message);
    return json({ e }, { status: 400 });
  }

  // Handle the event
  switch (event.type) {
    // Sent when a customer’s subscription ends.
    case 'customer.subscription.deleted':
      const subscriptionOver = event.data.object;
      const customer = subscriptionOver.customer;
      console.log(subscriptionOver)
      // Then define and call a method to handle the successful attachment of a PaymentMethod.
      // handlePaymentMethodAttached(paymentMethod);
      break;
    // Sent when the invoice is successfully paid. 
    // You can provision access to your product when you receive this event and the subscription status is active.
    case 'invoice.paid':
      const subscriptionPaid = event.data.object;
      console.log(subscriptionPaid)
      // Then define and call a method to handle the successful attachment of a PaymentMethod.
      // handlePaymentMethodAttached(paymentMethod);
      break;
    // To get custom field data (like wallet address)
    case 'checkout.session.completed':
      const checkoutInfo = event.data.object;
      const walletAddress = checkoutInfo.custom_fields[0].text?.value;
      // Then define and call a method to handle the successful attachment of a PaymentMethod.
      // handlePaymentMethodAttached(paymentMethod);
      break;
    // ... handle other event types
    default:
      console.log(`Unhandled event type ${event.type}`);
  }

  // Return a response to acknowledge receipt of the event
  return json({ received: true }, { status: 200 });
}