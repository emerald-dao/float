alter table "public"."float_claims" drop constraint "claims_event_id_fkey";

alter table "public"."float_claims" drop column "event_id";

alter table "public"."float_claims" alter column "float_id" set data type text using "float_id"::text;

alter table "public"."float_claims" alter column "user_address" set data type text using "user_address"::text;

alter table "public"."float_events" alter column "creator_address" set data type text using "creator_address"::text;

alter table "public"."float_events" alter column "id" set data type text using "id"::text;


