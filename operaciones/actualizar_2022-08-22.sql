set search_path = base;

alter table tem add column "lote" text;
alter table tem add column "grado_matching" numeric;
alter table tem add column "observaciones_blaise" text;

alter table "tem" add constraint "lote<>''" check ("lote"<>'');
alter table "tem" add constraint "observaciones_blaise<>''" check ("observaciones_blaise"<>'');