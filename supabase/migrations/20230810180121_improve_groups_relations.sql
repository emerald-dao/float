alter table "public"."float_floats_groups" drop constraint "floats_groups_group_id_fkey";

alter table "public"."float_floats_groups" add constraint "floats_groups_group_id_fkey" FOREIGN KEY (group_id) REFERENCES float_groups(id) ON DELETE CASCADE not valid;

alter table "public"."float_floats_groups" validate constraint "floats_groups_group_id_fkey";

create policy "Enable read access for all users"
on "public"."float_floats_groups"
as permissive
for select
to public
using (true);



