alter table "public"."claims" add column "block_id" text;

alter table "public"."claims" add column "transaction_id" text;

alter table "public"."claims" add constraint "claims_event_id_fkey" FOREIGN KEY (event_id) REFERENCES events(id) not valid;

alter table "public"."claims" validate constraint "claims_event_id_fkey";


