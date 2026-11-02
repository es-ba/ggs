-- Solo cambios en la base: no hace falta deployar la app ni cortarla.
-- Adapta a ggs el script de dmencu operaciones/2026-11-02-actualizar_xcalcular_resultado_trg.sql
-- tem.resultado se calcula con el trigger xcalcular_resultado_trg. La base de ggs no lo tenía y resultado quedó vacío en todas las encuestas:
-- el control de campo (tablero y grillas de control) no contaba las efectivas, pendientes ni mixtas.
-- Crea el trigger y recalcula resultado de las encuestas existentes. Se puede correr más de una vez.
set role ggs2026_owner; -- adecuar al entorno
set search_path = base;

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

DROP TRIGGER IF EXISTS xcalcular_resultado_trg ON base.tem;
CREATE TRIGGER xcalcular_resultado_trg
    BEFORE INSERT OR UPDATE OF rea, norea
    ON base.tem
    FOR EACH ROW
    EXECUTE PROCEDURE base.xcalcular_resultado_trg();

-- recalcula resultado de las encuestas existentes: nombrar rea y norea en el set dispara el trigger aunque no cambien.
-- Se puede correr más de una vez.
update tem set rea = rea, norea = norea;

alter function base.xcalcular_resultado_trg() owner to ggs2026_owner;
