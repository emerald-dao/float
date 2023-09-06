create policy "Enable read access for all users"
on "public"."claims"
as permissive
for select
to public
using (true);



