--función trigger para setear el campo supervision aleatoria- primera versión.
--poner el rol que corresponda según el entorno en cual estamos corriendo este script
set role ggs2026_owner;
set search_path=base;

----PRUEBA SCRIPT TAREAS TEM
----Solo va a haber supervisión aleatoria telefónica(2) para ggs2026 y para reas.
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
        FROM base.tem t LEFT JOIN base.no_rea n ON t.operativo=n.operativo AND t.norea::text=n.no_rea
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

--el trigger tiene que estar antes que el de próxima tarea    
-- DROP TRIGGER IF EXISTS csetear_sup_aleat_tareas_tem_trg ON base.tareas_tem;
CREATE TRIGGER csetear_sup_aleat_tareas_tem_trg     
    AFTER UPDATE OF verificado
    ON base.tareas_tem
    FOR EACH ROW
        WHEN (NEW.verificado = '1' AND OLD.verificado IS DISTINCT FROM NEW.verificado
            AND NEW.estado='P' AND NEW.tarea in ('encu','recu') )  
    EXECUTE FUNCTION base.setear_sup_aleat_tareas_tem_trg();
