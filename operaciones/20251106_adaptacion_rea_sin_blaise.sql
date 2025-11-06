
set search_path to base;

alter table viviendas add column obs_faltantes text;
alter table viviendas add constraint "obs_faltantes<>''" check ("obs_faltantes"<>'');
