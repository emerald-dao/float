alter table "public"."floats_groups" drop constraint "floats_groups_group_id_fkey";

alter table "public"."floats_groups" add constraint "floats_groups_group_id_fkey" FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE not valid;

alter table "public"."floats_groups" validate constraint "floats_groups_group_id_fkey";

create policy "Enable read access for all users"
on "public"."floats_groups"
as permissive
for select
to public
using (true);



