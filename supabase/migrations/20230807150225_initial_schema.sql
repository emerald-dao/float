alter table "public"."groups" drop constraint "groups_user_fkey";

alter table "public"."floats_groups" drop constraint "floats_groups_float_id_fkey";

alter table "public"."floats" alter column "id" drop identity;

alter table "public"."floats" alter column "id" set data type text using "id"::text;

alter table "public"."floats_groups" alter column "float_id" drop identity;

alter table "public"."floats_groups" alter column "float_id" set data type text using "float_id"::text;

alter table "public"."groups" drop column "user";

alter table "public"."groups" add column "user_address" text;

alter table "public"."groups" alter column "name" set data type text using "name"::text;

alter table "public"."users" alter column "address" drop identity;

alter table "public"."users" alter column "address" set data type text using "address"::text;

alter table "public"."groups" add constraint "groups_user_address_fkey" FOREIGN KEY (user_address) REFERENCES users(address) not valid;

alter table "public"."groups" validate constraint "groups_user_address_fkey";

alter table "public"."floats_groups" add constraint "floats_groups_float_id_fkey" FOREIGN KEY (float_id) REFERENCES floats(id) not valid;

alter table "public"."floats_groups" validate constraint "floats_groups_float_id_fkey";


