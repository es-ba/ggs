-- Actualización a dmencu 3.5.0 sobre una base ya instalada.
-- Reúne, adaptados a ggs, los scripts de dmencu:
--   operaciones/2026-09-29-actualizar_rea_no_rea.sql
--   operaciones/2026-10-15-validar_manzana_casa_tem.sql
-- Correr ANTES de levantar el backend con la versión nueva (dmencu lee las tablas rea y rea_sup al arrancar).
set role ggs2026_owner; -- adecuar al entorno
set search_path=base;

-- 1. no_rea: orden (ya existía como bigint, agregado desde app-ggs.ts) y no_rea pasa a integer
alter table no_rea add column if not exists "orden" integer default 0;
alter table no_rea alter column "orden" type integer;
alter table no_rea alter column "orden" set default 0;
update no_rea set orden = 0 where orden is null;
alter table no_rea alter column "orden" set not null;

alter table "no_rea" drop constraint "no_rea<>''";
alter table "no_rea" alter column "no_rea" type integer using nullif(no_rea, '')::integer;

-- 2. no_rea_sup: se agrega operativo a la pk, orden (ya existía como bigint) y no_rea_sup pasa a integer
alter table no_rea_sup add column if not exists "operativo" text;
update no_rea_sup set operativo = 'GGS_2026' where operativo is null;
alter table no_rea_sup alter column "operativo" set not null;
alter table "no_rea_sup" add constraint "operativo<>''" check ("operativo"<>'');
alter table "no_rea_sup" add constraint "no_rea_sup operativos REL" foreign key ("operativo") references "operativos" ("operativo") on update cascade;

alter table no_rea_sup add column if not exists "orden" integer default 0;
alter table no_rea_sup alter column "orden" type integer;
alter table no_rea_sup alter column "orden" set default 0;
update no_rea_sup set orden = 0 where orden is null;
alter table no_rea_sup alter column "orden" set not null;

alter table no_rea_sup drop constraint no_rea_sup_pkey;
alter table no_rea_sup add primary key (operativo, no_rea_sup);

alter table "no_rea_sup" drop constraint "no_rea_sup<>''";
alter table "no_rea_sup" alter column "no_rea_sup" type integer using nullif(no_rea_sup, '')::integer;

-- 3. tablas nuevas rea y rea_sup (en ggs quedan vacías: rea y rea_sup se calculan en my-bypass-formulario.ts)
create table "rea" (
  "operativo" text,
  "orden" integer default 0,
  "rea" integer,
  "descripcion" text,
  "condicion" text,
  "es_positiva" boolean default true,
  "tarea" text
, primary key ("operativo", "rea")
);
grant select, insert, update, delete on "rea" to ggs2026_admin;
grant all on "rea" to ggs2026_owner;

create table "rea_sup" (
  "operativo" text,
  "orden" integer default 0,
  "rea_sup" text,
  "descripcion" text,
  "condicion" text,
  "es_positiva" boolean default true,
  "tarea" text
, primary key ("operativo", "rea_sup")
);
grant select, insert, update, delete on "rea_sup" to ggs2026_admin;
grant all on "rea_sup" to ggs2026_owner;

alter table "rea" add constraint "operativo<>''" check ("operativo"<>'');
alter table "rea" alter column "operativo" set not null;
alter table "rea" alter column "orden" set not null;
alter table "rea" add constraint "descripcion<>''" check ("descripcion"<>'');
alter table "rea" add constraint "condicion<>''" check ("condicion"<>'');
alter table "rea" alter column "es_positiva" set not null;
alter table "rea" add constraint "tarea<>''" check ("tarea"<>'');
alter table "rea_sup" add constraint "operativo<>''" check ("operativo"<>'');
alter table "rea_sup" alter column "operativo" set not null;
alter table "rea_sup" alter column "orden" set not null;
alter table "rea_sup" add constraint "rea_sup<>''" check ("rea_sup"<>'');
alter table "rea_sup" add constraint "descripcion<>''" check ("descripcion"<>'');
alter table "rea_sup" add constraint "condicion<>''" check ("condicion"<>'');
alter table "rea_sup" alter column "es_positiva" set not null;
alter table "rea_sup" add constraint "tarea<>''" check ("tarea"<>'');

alter table "rea" add constraint "rea operativos REL" foreign key ("operativo") references "operativos" ("operativo")  on update cascade;
alter table "rea" add constraint "rea tareas REL" foreign key ("operativo", "tarea") references "tareas" ("operativo", "tarea")  on update cascade;
alter table "rea_sup" add constraint "rea_sup operativos REL" foreign key ("operativo") references "operativos" ("operativo")  on update cascade;
alter table "rea_sup" add constraint "rea_sup tareas REL" foreign key ("operativo", "tarea") references "tareas" ("operativo", "tarea")  on update cascade;

create index "operativo 4 rea IDX" ON "rea" ("operativo");
create index "operativo,tarea 4 rea IDX" ON "rea" ("operativo", "tarea");
create index "operativo 4 rea_sup IDX" ON "rea_sup" ("operativo");
create index "operativo,tarea 4 rea_sup IDX" ON "rea_sup" ("operativo", "tarea");

-- 4. funciones de dmencu que comparaban norea con no_rea como texto (tarea_cumple_condicion.sql y generador_accion_cumple_condicion.sql)
CREATE OR REPLACE FUNCTION tarea_cumple_condicion(p_operativo text, p_tarea text, p_estado text, p_enc text, p_condicion text)
RETURNS boolean AS
$BODY$
DECLARE
    v_sent text;
    v_cond text;
    v_salida integer;
BEGIN
 v_cond=p_condicion;
 v_sent=' select 1
    from base.tareas_tem t
    inner join base.tareas_proximas tp using (operativo, tarea, estado)
    inner join tem te using (operativo,enc)
    --left join tokens tok on t.cargado_dm=tok.token
    left join no_rea nr on (te.norea = nr.no_rea)
    where t.operativo='||quote_literal(p_operativo)||
    ' and t.tarea='||quote_literal(p_tarea)||
    ' and t.estado='||quote_literal(p_estado)||
    ' and t.enc='||quote_literal(p_enc)||
    ' and '||v_cond||';';
 --raise notice 'esto %',vsent;
 execute v_sent into v_salida;
 IF v_salida=1 THEN
    return true;
 ELSE
    return false;
 END IF;

END;
$BODY$
 LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION regenerar_accion_cumple_condicion_trg()
  RETURNS trigger
  LANGUAGE plpgsql
  SECURITY DEFINER AS
$CREATOR$
DECLARE
  xcase_condiciones TEXT;
  v_sql text := $SQL_CON_TAG$

CREATE OR REPLACE FUNCTION accion_cumple_condicion(
    p_operativo text,
    p_estado text,
    p_enc text,
    p_eaccion text,
    p_condicion text)
    RETURNS boolean
    LANGUAGE SQL
    STABLE
AS $SQL$
    -- ¡ATENCIÓN! NO MODIFICAR MANUALMENTE ESTA FUNCIÓN FUE GENERADA CON EL SCRIPT generador_accion_cumple_condicion.sql
  select true
    from base.tareas_tem t
    inner join base.estados_acciones ea using (operativo, estado)
    inner join tem te using (operativo,enc)
    left join no_rea nr on (te.norea = nr.no_rea)
    left join tareas_tem tta on (te.operativo = tta.operativo and te.enc = tta.enc and te.tarea_actual = tta.tarea)
    where t.operativo = p_operativo
    and t.estado = p_estado
    and t.enc = p_enc
    and ea.eaccion = p_eaccion
    and te.habilitada
    and
    -- COMIENZA LA PARTE GENERADA DINÁMICAMENTE:
      /**xcase_condiciones**/
    -- FIN DE LA GENERADA DINÁMICAMENTE:
    ;
    $SQL$;

$SQL_CON_TAG$;
BEGIN

 SELECT 'CASE p_condicion' ||
    string_agg(distinct chr(10) || lpad(' ',8)|| 'WHEN ' || quote_literal(condicion) || ' THEN ' || condicion, '')
    ||chr(10) ||lpad(' ',6)|| 'END'
  INTO xcase_condiciones
  FROM base.estados_acciones;

  execute replace(v_sql,'/**xcase_condiciones**/',xcase_condiciones);
  RETURN new;
END;
$CREATOR$;

CREATE OR REPLACE TRIGGER update_accion_cumple_condicion_trg
    AFTER UPDATE of condicion
    ON base.estados_acciones
    FOR EACH ROW
    EXECUTE FUNCTION base.regenerar_accion_cumple_condicion_trg();

--regenerar accion_cumple_condicion con la nueva comparación de no_rea
with aux as (select * from estados_acciones limit 1)
update estados_acciones ea
  set condicion=aux.condicion
  from aux
  where ea.operativo= aux.operativo and
    ea.estado=aux.estado and
    ea.eaccion=aux.eaccion and
    ea.estado_destino=aux.estado_destino;

-- 5. función propia de ggs (operaciones/20261007-setear-supervision_aleatoria.sql) que comparaba norea::text con no_rea
CREATE OR REPLACE FUNCTION base.setear_sup_aleat_tareas_tem_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $BODY$

declare
   v_estado           text;
   v_pre_sorteo       integer;
   v_sup_aleat        integer;
   v_rea              integer;
   v_norea            text;
   v_grupo0           text;
   v_dominio          integer;
   v_con_telefono     boolean;
   v_seleccionado_ant jsonb;
   v_rea_tel          bigint;
   v_rea_pres         bigint;
   v_tarea_actual     text;
   v_cant_sup_aleat   integer;
   v_cant_efectivas   integer;
   v_fijo             text;
begin
    v_estado=new.estado;
    SELECT pre_sorteo, supervision_aleatoria, t.rea, t.norea, grupo0,dominio,seleccionado_ant, t.tarea_actual
        INTO   v_pre_sorteo, v_sup_aleat, v_rea, v_norea, v_grupo0, v_dominio,v_seleccionado_ant, v_tarea_actual
        FROM base.tem t LEFT JOIN base.no_rea n ON t.operativo=n.operativo AND t.norea=n.no_rea
        WHERE t.operativo=new.operativo AND t.enc=new.enc ;
    RAISE NOTICE ' valores sort % ,aleat % ,rea % ,norea % , estad % ,domi % , tactual % ',v_pre_sorteo,v_sup_aleat, v_rea, v_norea, v_estado, v_dominio, v_tarea_actual;

    SELECT rea_tel, rea_pres, fijo
        INTO v_rea_tel, v_rea_pres, v_fijo
        FROM viviendas
        WHERE operativo=new.operativo AND vivienda= new.enc;
    v_con_telefono=concat_ws('|',v_seleccionado_ant->>'telms',v_seleccionado_ant->>'movil',v_fijo)~'\d{3}' ;
    RAISE NOTICE 'tel% , reat%, reap% ', v_rea_tel, v_rea_pres, v_fijo;

    --revisar condiciones si se agrega supervision presencial
    IF v_pre_sorteo =2 AND v_sup_aleat IS NULL
        AND v_rea=1 AND v_con_telefono
        AND v_estado='P' AND v_tarea_actual in ('encu','recu')
        AND (v_rea_tel=1 OR v_rea_pres=1) THEN
        --control de 10% efectivo a supervisar
        -- de acuerdo con la IA por el tamaño de la muestra podemos poner aqui el control
        -- si empeora la performance, se puede pasar esto a un proceso semanal y necesitaria una marca mas relacionada con este proceso
        SELECT COUNT(*)  INTO v_cant_sup_aleat
            FROM tem
            WHERE supervision_aleatoria IS NOT NULL;
        SELECT count(*) INTO v_cant_efectivas
            FROM tem join viviendas on vivienda=enc
            WHERE rea=1 AND (rea_pres=1 or rea_tel=1);
        RAISE NOTICE 'n_supalea %, n_efect %', v_cant_sup_aleat, v_cant_efectivas;
        IF v_cant_efectivas >0 AND (v_cant_sup_aleat + 1)*1.0/v_cant_efectivas * 100 <= 10 THEN
            UPDATE base.tem
                SET supervision_aleatoria=v_pre_sorteo
                WHERE operativo=new.operativo AND enc=new.enc ;

        END IF;
    END IF;
    RETURN new;
end;
$BODY$;

-- 6. nromanzana y casa de tem sólo se pueden modificar en encuestas de dominio 5 (validar_manzana_casa_tem_trg.sql)
CREATE OR REPLACE FUNCTION validar_manzana_casa_tem_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $BODY$
begin
    if old.dominio is distinct from 5 then
        raise exception 'Error: la manzana y la casa de la encuesta % del operativo % sólo se pueden modificar si el dominio es 5', new.enc, new.operativo;
    end if;
    return new;
end;
$BODY$;

DROP TRIGGER IF EXISTS validar_manzana_casa_tem_trg ON tem;
CREATE TRIGGER validar_manzana_casa_tem_trg
   BEFORE UPDATE OF nromanzana, casa
   ON tem
   FOR EACH ROW
   WHEN (old.nromanzana is distinct from new.nromanzana or old.casa is distinct from new.casa)
   EXECUTE PROCEDURE validar_manzana_casa_tem_trg();
