set search_path = base;

alter table usuarios add column "usuario_blaise" text;
alter table "usuarios" add constraint "usuario_blaise<>''" check ("usuario_blaise"<>'');