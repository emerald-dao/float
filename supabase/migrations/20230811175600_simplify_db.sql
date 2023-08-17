drop policy "Enable read access for all users" on "public"."users";

alter table "public"."floats_groups" drop constraint "floats_groups_float_id_fkey";

alter table "public"."groups" drop constraint "groups_user_address_fkey";

alter table "public"."floats" drop constraint "events_pkey";

alter table "public"."users" drop constraint "users_pkey";

drop index if exists "public"."events_pkey";

drop index if exists "public"."users_pkey";

drop table "public"."floats";

drop table "public"."users";


