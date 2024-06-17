create policy "Enable read access for all users"
on "public"."float_claims"
as permissive
for select
to public
using (true);



