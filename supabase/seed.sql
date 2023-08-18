insert into
users (address)
values
('0x99bd48c8036e2876');

insert into
groups (id, user_address, name, description)
values
(1, '0x99bd48c8036e2876', 'Wonderful Group', 'This is a wonderful group'),
(2, '0x99bd48c8036e2876', 'Another Group', 'This is another group');

insert into 
floats (id)
values
('187900113'), ('196985252'), ('242885523');

insert into
floats_groups (float_id, group_id)
values
('187900113', 1), ('196985252', 1), ('242885523', 2);