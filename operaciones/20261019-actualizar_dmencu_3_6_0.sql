-- Actualización a dmencu 3.6.0 sobre una base ya instalada.
-- Adapta a ggs el script de dmencu operaciones/2026-10-19-actualizar_desverificar_excepcional.sql
-- (desverificación excepcional de encuestas: el historial guarda quién la hizo y por qué).
set role ggs2026_owner; -- adecuar al entorno
set search_path = base;

alter table historial_tem add column if not exists usuario_accion text;
alter table historial_tem add column if not exists motivo text;
