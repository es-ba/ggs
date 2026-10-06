set search_path=base;
set role ggs2026_owner; -- adecuar al entorno

alter table backups rename column b13wrk17 to b13wrk17_3601; 
alter table backups rename column b13wrk28 to b13wrk28_3601;
alter table backups 
    add column if not exists wrk17_3601 text,
    add column if not exists wrk28_3601 text,
    add column if not exists breportb17rep01 text,
    add column if not exists breportb17rep02 text,
    add column if not exists breportb17rep04 text,
    add column if not exists breportb17rep05 text,
    add column if not exists breportb17rep06 text,
    add column if not exists breportint01_3601 text,
    add column if not exists breportint02_3601 text;

alter table "backups" 
  add constraint "wrk17_3601<>''"        check ("wrk17_3601"<>''),
  add constraint "wrk28_3601<>''"        check ("wrk28_3601"<>''),
  add constraint "breportb17rep01<>''"   check ("breportb17rep01"<>''),
  add constraint "breportb17rep02<>''"   check ("breportb17rep02"<>''),
  add constraint "breportb17rep04<>''"   check ("breportb17rep04"<>''),
  add constraint "breportb17rep05<>''"   check ("breportb17rep05"<>''),
  add constraint "breportb17rep06<>''"   check ("breportb17rep06"<>''),
  add constraint "breportint01_3601<>''" check ("breportint01_3601"<>''),
  add constraint "breportint02_3601<>''" check ("breportint02_3601"<>'');
 