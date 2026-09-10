
set search_path=base;

UPDATE base.tem 
  SET seleccionado_ant = NULL;

alter table "tem" drop constraint "seleccionado_ant<>''";

ALTER TABLE base.tem 
  ALTER COLUMN seleccionado_ant TYPE jsonb 
  USING seleccionado_ant::jsonb;