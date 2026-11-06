-- Actualización a dmencu 3.9.2 sobre una base con dmencu 3.8.x ya instalado.
-- Adapta a ggs el script de dmencu:
--   operaciones/2026-10-18-actualizar_casilleros_versiones.sql
-- Crea la tabla casilleros_versiones que usa el editor visual de metadatos.
-- Se puede correr más de una vez.
set role ggs2026_owner; -- adecuar al entorno
set search_path = base;

create sequence if not exists casilleros_versiones_seq start with 1;

create table if not exists casilleros_versiones (
    version bigint default nextval('casilleros_versiones_seq'::regclass) not null,
    operativo text not null,
    id_formulario text not null,
    cuando timestamp default current_timestamp,
    usuario text,
    descripcion text,
    casilleros jsonb not null,
    primary key (version),
    constraint "casilleros_versiones operativos REL" foreign key (operativo) references operativos (operativo) on update cascade
);

grant select, insert, update, delete on casilleros_versiones to ggs2026_admin;
grant usage on sequence casilleros_versiones_seq to ggs2026_admin;

-- historial de cambios
drop trigger if exists changes_trg on "casilleros_versiones";
create trigger changes_trg after insert or delete or update on "casilleros_versiones" for each row execute function his.changes_trg('version');
