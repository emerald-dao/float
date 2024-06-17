create table "public"."float_pinned_floats" (
    "float_id" text not null,
    "user_address" text not null
);


alter table "public"."float_pinned_floats" enable row level security;

CREATE UNIQUE INDEX pinned_floats_pkey ON public.float_pinned_floats USING btree (float_id);

alter table "public"."float_pinned_floats" add constraint "pinned_floats_pkey" PRIMARY KEY using index "pinned_floats_pkey";


