alter table "public"."groups" alter column "name" set not null;

alter table "public"."groups" alter column "user_address" set not null;

create policy "Enable read access for all users"
on "public"."groups"
as permissive
for select
to public
using (true);


create policy "Enable read access for all users"
on "public"."users"
as permissive
for select
to public
using (true);



