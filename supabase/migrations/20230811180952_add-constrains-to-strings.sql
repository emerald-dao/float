alter table "public"."float_groups" add constraint "groups_description_check" CHECK ((length(description) < 110)) not valid;

alter table "public"."float_groups" validate constraint "groups_description_check";

alter table "public"."float_groups" add constraint "groups_name_check" CHECK ((length(name) < 60)) not valid;

alter table "public"."float_groups" validate constraint "groups_name_check";


