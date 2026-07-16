"use strict";

import { FieldDefinition, TableContext, TableDefinition } from "dmencu";
import { viviendas } from "./table-viviendas";

export function rea_sin_blaise(context:TableContext): TableDefinition {
    let def = viviendas(context);
    def.title= "Rea sin Blaise"
    def.allow= {import:false, delete:false, insert: false, deleteAll:false, select:true, export: true, update:true}

    let fieldsToShow:FieldDefinition[] =[
        {name:'enc'      ,  typeName: 'text' },
        {name:'idblaise'      ,  typeName: 'text' },
        {name:'rea'      ,  typeName: 'integer' },
        {name:'norea'      ,  typeName: 'integer' },
        {name:'rea_web'      ,  typeName: 'integer' },
        {name:'rea_tel'      ,  typeName: 'integer' },
        {name:'rea_pres'      ,  typeName: 'integer' },
        {name:'msnombrei'      ,  typeName: 'text' },
        {name:'tarea'      ,  typeName: 'text' },
        {name:'operacion'      ,  typeName: 'text' },
        {name:'encuestador'      ,  typeName: 'text' },
        {name:'supervisor'      ,  typeName: 'text' },
        {name:'verif_campo'      ,  typeName: 'text' },
        {name:'fin_1'      ,  typeName: 'bigint' },
        {name:'fin_3'      ,  typeName: 'bigint' },
        {name:'obs_faltantes'      ,  typeName: 'text', editable: true }
    ]

    const fieldsToNotShow = def.fields.filter(f=> !fieldsToShow.map(f=>f.name).includes(f.name))
    def.fields= [
        //adding fields to show as editable false (except explicit editable=true)
        ...fieldsToShow.map(f=>({...f, editable:!!f.editable})),
        // adding rest of personas fields (not present in fields to show) as not visible
        ...fieldsToNotShow.map(f=>({...f, visible:false}))
        ]
    def.sql= {
            isTable:false,
            from:`(
                SELECT tb.enc, tb.idblaise, t.rea, t.norea, t.cant_h, --t.recepcionista,
                v.*,
                tt.verif_campo, tt.tarea, 
                tt.etareas->tt.tarea->>'operacion' as operacion,
                tt.etareas->'encu'->>'asignado' as encuestador,
                tt.etareas->'recu'->>'asignado' as recuperador,
                tt.etareas->'supe'->>'asignado' as supervisor,
                b.respid 
                FROM viviendas v 
                LEFT JOIN base.tem_blaise tb ON (v.operativo = tb.operativo AND v.vivienda = tb.enc AND tb.idblaise = v.id_blaise)
                JOIN base.tem t ON t.operativo=v.operativo AND t.enc=v.vivienda
                LEFT JOIN lateral (
                    SELECT 
                        case when 
                            (COUNT(*) filter (where tt.tarea in ('encu','recu'))) = 
                            (COUNT(verificado) filter (where tt.tarea in ('encu','recu'))) 
                                then '1' else null end verif_campo,
                        max(tt.tarea) tarea,
                        jsonb_object_agg(
                            tarea,
                            jsonb_build_object('asignado',asignado, 'operacion', operacion)
                        ) etareas 
                      FROM base.tareas_tem tt 
                      WHERE tt.operativo = tb.operativo AND tt.enc=tb.enc 
                         AND tt.asignado is not null AND tt.operacion is not null
                ) as tt ON true
                LEFT JOIN backups.backups b ON (tb.idblaise = b.respid)
                WHERE (t.rea=1 OR t.rea=4) 
                AND b.respid is null)`,
            insertIfNotUpdate:false
        }
    
  return def;
}
