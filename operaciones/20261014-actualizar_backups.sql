set search_path=base;
set role ggs2026_owner; -- adecuar al entorno

--agregar campos
alter table backups 
    add column if not exists b2dem17 text,
    add column if not exists b11gen55 text,
    add column if not exists b3uni19 text,
    add column if not exists b3dem30c text,
    add column if not exists b3dem22_y text,
    add column if not exists b3dem22_m text,
    add column if not exists b3dem23   text,
    add column if not exists b14dem25 text,
    add column if not exists b14dem26 text,
    add column if not exists b15inc03 text,    
    add column if not exists b15inc06 text;

alter table "backups" 
  add constraint "b2dem17 <>''"    check ("b2dem17" <>''),
  add constraint "b11gen55 <>''"   check ("b11gen55"<>''),
  add constraint "b3uni19 <>''"    check ("b3uni19" <>''),
  add constraint "b3dem30c <>''"   check ("b3dem30c" <>''),
  add constraint "b3dem22_y <>''"  check ("b3dem22_y"<>''),
  add constraint "b3dem22_m <>''"  check ("b3dem22_m"<>''),
  add constraint "b3dem23  <>''"   check ("b3dem23"  <>''),
  add constraint "b14dem25 <>''"   check ("b14dem25" <>''),
  add constraint "b14dem26 <>''"   check ("b14dem26" <>''),
  add constraint "b15inc03 <>''"   check ("b15inc03" <>''), 
  add constraint "b15inc06 <>''"   check ("b15inc06" <>'');