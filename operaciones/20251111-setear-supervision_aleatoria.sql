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
   v_pre_sorteo integer;
   v_sup_aleat        integer;
   v_rea              integer;
   v_norea            text;
   v_grupo0           text;
   v_estado           text;
   v_dominio          integer;
   v_con_telefono     boolean;
   v_seleccionado_ant jsonb;
   v_new_aleat        integer;
   v_rea_tel          bigint;
   v_rea_pres         bigint;
   v_tarea_actual     text;
   v_cant_sup_aleat   integer;
   v_cant_efectivas   integer; 
   v_fijo             text; 
begin
    select pre_sorteo, supervision_aleatoria, t.rea, t.norea, grupo0,estado,dominio,seleccionado_ant, t.tarea_actual
      into   v_pre_sorteo, v_sup_aleat, v_rea, v_norea, v_grupo0, v_estado, v_dominio,v_seleccionado_ant, v_tarea_actual
      from base.tem t
        left join base.tareas_tem tt on t.enc=tt.enc and t.tarea_actual=tt.tarea
        left join base.no_rea on t.norea::text=no_rea
      where t.operativo=new.operativo and t.enc=new.enc ;
     -- raise notice ' valores % % % % % % % %',v_pre_sorteo,v_sup_aleat, v_rea, v_norea, v_grupo0, v_estado, v_dominio, v_tarea_actual;   
    v_new_aleat=null;
    select rea_tel, rea_pres, fijo into v_rea_tel, v_rea_pres, v_fijo
           from viviendas where operativo=new.operativo and vivienda= new.enc;
    v_con_telefono=concat(v_seleccionado_ant->>'telms',v_seleccionado_ant->>'movil')~'\d{3}' ;

    if v_pre_sorteo in (1,2)  and v_sup_aleat is null and v_estado='V' and v_tarea_actual in ('encu','recu') then
        if v_rea=1 and v_pre_sorteo=2 and v_con_telefono and (v_rea_tel=1 or v_rea_pres=1) then
           --control de 10% efectivo a supervisar
            SELECT COUNT(*)  INTO v_cant_sup_aleat 
              FROM tem 
              WHERE supervision_aleatoria is not null;
            SELECT count(*) into v_cant_fectivas
              FROM tem join viviendas on vivienda=enc 
              WHERE rea=1 and (rea_pres=1 or rea_tel=1);
            IF v_cant_efectivas>0 and (v_cant_sup_aleat + 1)*1.0/v_cant_efectivas*100 <= 10 then 

                update base.tem
                    set supervision_aleatoria=v_pre_sorteo
                    where operativo=new.operativo and enc=new.enc ;

            END IF;
        end if; 
    end if;
    return new;
end;    
$BODY$;

ALTER FUNCTION base.setear_sup_aleat_tareas_tem_trg()
    OWNER TO ggs2026_owner;

--el trigger tiene que estar antes que el de próxima tarea    
-- DROP TRIGGER IF EXISTS csetear_sup_aleat_tareas_tem_trg ON base.tareas_tem;

CREATE TRIGGER csetear_sup_aleat_tareas_tem_trg     
    AFTER UPDATE OF verificado
    ON base.tareas_tem
    FOR EACH ROW
    EXECUTE FUNCTION base.setear_sup_aleat_tareas_tem_trg();
    