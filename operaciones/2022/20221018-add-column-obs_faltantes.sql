set role ggs2022_owner;
set search_path=base;

GRANT ALL ON SCHEMA backups TO ggs2022_admin;
GRANT SELECT ON TABLE backups.backups TO ggs2022_admin;

ALTER TABLE "personas" 
    add column "obs_faltantes" text,
    add constraint "obs_faltantes<>''" check ("obs_faltantes"<>'');