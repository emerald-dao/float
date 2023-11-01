import { createClient } from '@supabase/supabase-js';
import { PUBLIC_SUPABASE_API_URL } from '$env/static/public';
import { PRIVATE_SUPABASE_SERVICE_ROLE } from '$env/static/private';

export const serviceSupabase = createClient(
  PUBLIC_SUPABASE_API_URL,
  PRIVATE_SUPABASE_SERVICE_ROLE
);