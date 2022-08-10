"use strict";

import { ProcedureDef, TableDefinition, Client } from "./types-ggs";
import {json, jsono} from "pg-promise-strict";
import { setHdrQuery } from "dmencu/dist/server/server/procedures-dmencu"

setHdrQuery((quotedCondViv:string)=>{
    return `
    with viviendas as 
        (select t.enc, t.json_encuesta as respuestas, t.resumen_estado as "resumenEstado", 
            jsonb_build_object(
                'dominio'       , dominio       ,
                'nomcalle'      , nomcalle      ,
                'sector'        , sector        ,
                'edificio'      , edificio      ,
                'entrada'       , entrada       ,
                'nrocatastral'  , nrocatastral  ,
                'piso'          , piso          ,
                'departamento'  , departamento  ,
                'habitacion'    , habitacion    ,
                'casa'          , casa          ,
                'prioridad'     , reserva+1     ,
                'observaciones' , tt.carga_observaciones ,
                'cita'          , cita ,
                'carga'         , t.area         
            ) as tem, t.area,
            --TODO: GENERALIZAR
            jsonb_build_object(
                'tarea', tarea,
                'fecha_asignacion', fecha_asignacion,
                'asignado', asignado,
                'main_form', main_form
            ) as tarea,
            min(fecha_asignacion) as fecha_asignacion,
            jsonb_agg(jsonb_build_object(
				'enc',th.enc,
				'hogar',th.hogar, 
				'idblaise', th.idblaise
			)) codigos_blaise
            from tem t left join tareas_tem tt using (operativo, enc) left join tareas using (tarea) left join tem_hogar th on (th.operativo=t.operativo and th.enc =t.enc)
            where ${quotedCondViv}
            group by t.enc, t.json_encuesta, t.resumen_estado, dominio, nomcalle,sector,edificio, entrada, nrocatastral, piso,departamento,habitacion,casa,reserva,tt.carga_observaciones, cita, t.area, tarea, fecha_asignacion, asignado, main_form
        )
        select jsonb_build_object(
                'viviendas', ${jsono(
                    `select enc, respuestas, jsonb_build_object('resumenEstado',"resumenEstado") as otras from viviendas`,
                    'enc',
                    `otras || coalesce(respuestas,'{}'::jsonb)`
                )}
            ) as respuestas,
            ${json(`
                select area as carga, observaciones_hdr as observaciones, min(fecha_asignacion) as fecha
                    from viviendas inner join areas using (area) 
                    group by area, observaciones_hdr`, 
                'fecha')} as cargas,
            ${jsono(
                `select enc, jsonb_build_object('tem', tem, 'tarea', tarea,'codigosBlaise',codigos_blaise) as otras from viviendas`,
                    'enc',
                    `otras ||'{}'::jsonb`
                )}
            as "informacionHdr"
`
    
})

export const procedures : ProcedureDef[] = [
    
];
