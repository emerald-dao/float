alter table "public"."float_claims" add column "event_id" text;

alter table "public"."float_claims" add constraint "claims_event_id_fkey" FOREIGN KEY (event_id) REFERENCES float_events(id) not valid;

alter table "public"."float_claims" validate constraint "claims_event_id_fkey";


