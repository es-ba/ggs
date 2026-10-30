-- Actualización a dmencu 3.8.0 sobre una base con dmencu 3.7.2 o 3.7.3 ya instalado.
-- Adapta a ggs el script de dmencu:
--   operaciones/2026-10-30-actualizar_validar_domicilio_tem.sql
-- nromanzana, casa, nomcalle, nrocatastral, piso, departamento y habitacion de tem sólo se pueden modificar en encuestas de dominio 5.
-- El trigger validar_manzana_casa_tem_trg se reemplaza por validar_domicilio_tem_trg.
-- Se puede correr más de una vez.
set role ggs2026_owner; -- adecuar al entorno
set search_path = base;

DROP TRIGGER IF EXISTS validar_manzana_casa_tem_trg ON tem;
DROP FUNCTION IF EXISTS validar_manzana_casa_tem_trg();

CREATE OR REPLACE FUNCTION validar_domicilio_tem_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $BODY$
begin
    if old.dominio is distinct from 5 then
        raise exception 'Error: la manzana, la casa, la calle, el número catastral, el piso, el departamento y la habitación de la encuesta % del operativo % sólo se pueden modificar si el dominio es 5', new.enc, new.operativo;
    end if;
    return new;
end;
$BODY$;

DROP TRIGGER IF EXISTS validar_domicilio_tem_trg ON tem;
CREATE TRIGGER validar_domicilio_tem_trg
   BEFORE UPDATE OF nromanzana, casa, nomcalle, nrocatastral, piso, departamento, habitacion
   ON tem
   FOR EACH ROW
   WHEN (old.nromanzana is distinct from new.nromanzana or old.casa is distinct from new.casa or old.nomcalle is distinct from new.nomcalle
                or old.nrocatastral is distinct from new.nrocatastral or old.piso is distinct from new.piso
                or old.departamento is distinct from new.departamento or old.habitacion is distinct from new.habitacion)
   EXECUTE PROCEDURE validar_domicilio_tem_trg();
