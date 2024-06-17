alter table "public"."float_claims" drop constraint "claims_event_id_fkey";

alter table "public"."float_claims" drop column "block_id";

alter table "public"."float_claims" drop column "transaction_id";


