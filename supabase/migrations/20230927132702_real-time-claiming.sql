alter table "public"."claims" drop constraint "claims_event_id_fkey";

alter table "public"."claims" drop column "block_id";

alter table "public"."claims" drop column "transaction_id";


