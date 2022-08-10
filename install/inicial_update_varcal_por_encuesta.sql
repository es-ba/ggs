set role ggs_admin;
-- FUNCTION: base.update_varcal_por_encuesta(text, text)

-- DROP FUNCTION IF EXISTS base.update_varcal_por_encuesta(text, text);

CREATE OR REPLACE FUNCTION base.update_varcal_por_encuesta(
	p_operativo text,
	p_id_caso text)
    RETURNS text
    LANGUAGE 'plpgsql'
AS $BODY$
BEGIN

  RETURN 'OK';
END;
$BODY$;

ALTER FUNCTION base.update_varcal_por_encuesta(text, text)
    OWNER TO ggs_admin;
