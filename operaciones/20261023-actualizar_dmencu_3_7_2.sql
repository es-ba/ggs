-- Actualización a dmencu 3.7.2 sobre una base con dmencu 3.6.0 ya instalado.
-- Adapta a ggs los scripts de dmencu:
--   operaciones/2026-10-20-actualizar_no_rea_grupo0.sql (no_rea es hija de no_rea_grupo0, con operativo en la clave)
--   operaciones/2026-10-21-actualizar_join_no_rea_operativo.sql (los joins a no_rea usan también el operativo)
-- y la función xcalcular_resultado_trg, que cambió en dmencu pero no tiene script propio en dmencu.
-- Se puede correr más de una vez. Si hay no_rea sin grupo0, el set not null falla: completar el grupo0 de esos códigos y volver a correr.
set role ggs2026_owner; -- adecuar al entorno
set search_path = base;

-- ======================================================================
-- no_rea_grupo0 y nueva clave de no_rea
-- ======================================================================

create table if not exists "no_rea_grupo0" (
  "operativo" text not null,
  "grupo0" text,
  "orden" integer not null default 0,
  "es_otras_causas" boolean not null default false,
  "es_no_encuestable" boolean not null default false,
  "es_en_curso" boolean not null default false,
  primary key ("operativo", "grupo0")
);

-- el usuario admin (el que usa el backend) necesita poder modificar la tabla
grant select, insert, update, delete on "no_rea_grupo0" to ggs2026_admin;
grant all on "no_rea_grupo0" to ggs2026_owner;

alter table "no_rea_grupo0" drop constraint if exists "operativo<>''";
alter table "no_rea_grupo0" add constraint "operativo<>''" check ("operativo"<>'');
alter table "no_rea_grupo0" drop constraint if exists "grupo0<>''";
alter table "no_rea_grupo0" add constraint "grupo0<>''" check ("grupo0"<>'');

alter table "no_rea_grupo0" drop constraint if exists "no_rea_grupo0 operativos REL";
alter table "no_rea_grupo0" add constraint "no_rea_grupo0 operativos REL" foreign key ("operativo") references "operativos" ("operativo") on update cascade;
create index if not exists "operativo 4 no_rea_grupo0 IDX" on "no_rea_grupo0" ("operativo");

-- un registro por cada grupo0 que ya usan los no_rea, con el significado que hasta ahora tenía en el código;
-- si se vuelve a correr no pisa lo que se haya cambiado a mano
insert into "no_rea_grupo0" ("operativo", "grupo0", "orden", "es_otras_causas", "es_no_encuestable", "es_en_curso")
    select "operativo", "grupo0", min("orden"),
            "grupo0" = 'otras causas',
            "grupo0" like 'no encuestable%',
            "grupo0" = 'no finalizada'
        from "no_rea"
        where "grupo0" is not null
        group by "operativo", "grupo0"
    on conflict ("operativo", "grupo0") do nothing;

-- no_rea.grupo0 pasa a referenciar a no_rea_grupo0 (que ya referencia a operativos: no_rea deja de referenciar a operativos directamente)
alter table "no_rea" drop constraint if exists "no_rea operativos REL";
drop index if exists "operativo 4 no_rea IDX";
alter table "no_rea" drop constraint if exists "no_rea no_rea_grupo0 REL";
alter table "no_rea" add constraint "no_rea no_rea_grupo0 REL" foreign key ("operativo", "grupo0") references "no_rea_grupo0" ("operativo", "grupo0") on update cascade;
create index if not exists "operativo,grupo0 4 no_rea IDX" on "no_rea" ("operativo", "grupo0");

-- no_rea es hija de no_rea_grupo0: su clave es la del padre más la agregada (operativo, grupo0, no_rea).
-- El código sigue siendo único por operativo (todo el sistema identifica la no respuesta por su código), por eso la restricción única.
-- Si hay no_rea sin grupo0, el set not null falla: completar el grupo0 de esos códigos y volver a correr.
alter table "no_rea" drop constraint if exists "no_rea_codigo_uk";
alter table "no_rea" add constraint "no_rea_codigo_uk" unique ("operativo", "no_rea");
alter table "no_rea" alter column "grupo0" set not null;
do $$
begin
    if not exists (
        select 1
            from pg_index i
            where i.indrelid = '"no_rea"'::regclass and i.indisprimary
                and (select array_agg(a.attname::text order by k.ord)
                        from unnest(i.indkey) with ordinality k(attnum, ord)
                            join pg_attribute a on a.attrelid = i.indrelid and a.attnum = k.attnum) = array['operativo', 'grupo0', 'no_rea']
    ) then
        alter table "no_rea" drop constraint "no_rea_pkey";
        alter table "no_rea" add primary key ("operativo", "grupo0", "no_rea");
    end if;
end
$$;

-- historial de cambios: his.changes_trg recibe la clave de la tabla como argumento (no_rea cambió de clave)
drop trigger if exists changes_trg on "no_rea_grupo0";
create trigger changes_trg after insert or delete or update on "no_rea_grupo0" for each row execute function his.changes_trg('operativo,grupo0');
drop trigger if exists changes_trg on "no_rea";
create trigger changes_trg after insert or delete or update on "no_rea" for each row execute function his.changes_trg('operativo,grupo0,no_rea');

-- ======================================================================
-- los joins a no_rea usan también el operativo
-- ======================================================================

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
    left join no_rea nr on (te.operativo = nr.operativo and te.norea = nr.no_rea)
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
    left join no_rea nr on (te.operativo = nr.operativo and te.norea = nr.no_rea)
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

--regenerar la primera vez (ya que se cargan antes en el dump los estados_acciones)
with aux as (select * from estados_acciones limit 1)
update estados_acciones ea
  set condicion=aux.condicion
  from aux 
  where ea.operativo= aux.operativo and
    ea.estado=aux.estado and 
    ea.eaccion=aux.eaccion and
    ea.estado_destino=aux.estado_destino;

-- ======================================================================
-- xcalcular_resultado_trg busca la no rea por operativo y código
-- ======================================================================

CREATE or replace FUNCTION base.xcalcular_resultado_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $BODY$
declare
  vresultado       text;
begin
    select  
        case 
          when new.rea=1 then 'efectiva'  
          when new.rea=3 then 'pendiente' 
          when new.rea=4 then 'mixta' 
          when (new.rea=2 and new.norea is not null) then
            (select grupo 
              from no_rea 
              where new.operativo=no_rea.operativo and new.norea=no_rea.no_rea
            )  
          else null 
        end  into vresultado
      from tem t join parametros p using (operativo)
      where p.unico_registro
        and enc=new.enc;
    
    new.resultado= vresultado ;
    return new; 
end;
$BODY$;
