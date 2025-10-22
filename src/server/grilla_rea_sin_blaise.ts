"use strict";

import { FieldDefinition, TableContext, TableDefinition } from "dmencu";
import { personas } from "./table-personas";


export function grilla_rea_sin_blaise(context:TableContext): TableDefinition {
    let def = personas(context);
    def.title= "Rea sin Blaise"
    def.allow= {import:false, delete:false, insert: false, deleteAll:false, select:true, export: true, update:true}

    let fieldsToShow:FieldDefinition[] =[
        {name:'enc'      ,  typeName: 'text' },
        {name: "hogar", typeName: "bigint", nullable: false},
        {name:'idblaise'      ,  typeName: 'integer' },
        {name:'f_realiz_o'      ,  typeName: 'date' },
        {name:'rea'      ,  typeName: 'integer' },
        {name:'norea'      ,  typeName: 'integer' },
        {name:'cant_h'      ,  typeName: 'integer' },
        {name:'nombre'      ,  typeName: 'text' },
        {name:'edad'      ,  typeName: 'bigint' },
        {name:'sexo'      ,  typeName: 'bigint' },
        {name:'nacms'      ,  typeName: 'text' },
        {name:'tarea'      ,  typeName: 'text' },
        {name:'operacion'      ,  typeName: 'text' },
        {name:'encuestador'      ,  typeName: 'text' },
        {name:'recuperador'      ,  typeName: 'text' },
        {name:'supervisor'      ,  typeName: 'text' },
        // {name:'recepcionista'      ,  typeName: 'text' },
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
            from:`(select th.enc, th.idblaise, t.rea, t.norea, t.cant_h, --t.recepcionista,
                h.f_realiz_o,
                p.*,--operativo, p.vivienda, p.hogar, p.persona, p.nombre, p.edad, p.sexo, p.nacms, p.fin_1, p.fin_3, p.obs_faltantes,
                tt.verif_campo, tt.tarea, 
                tt.etareas->tt.tarea->>'operacion' as operacion,
                tt.etareas->'encu'->>'asignado' as encuestador,
                tt.etareas->'recu'->>'asignado' as recuperador,
                tt.etareas->'supe'->>'asignado' as supervisor,
                b.respid 
                from personas p 
                left join base.tem_blaise th on (p.operativo = th.operativo AND p.vivienda = th.enc AND p.hogar = th.hogar AND th.idblaise = p.id_blaise::integer)
                join base.hogares h on (th.operativo = h.operativo and th.enc=h.vivienda and th.hogar=h.hogar)
                join base.tem t on t.operativo=h.operativo and t.enc=h.vivienda
                left join lateral (
                    select 
                        case when 
                            (COUNT(*) filter (where tt.tarea in ('encu','recu'))) = 
                            (COUNT(verificado) filter (where tt.tarea in ('encu','recu'))) 
                                then '1' else null end verif_campo,
                        max(tt.tarea) tarea,
                        jsonb_object_agg(
                            tarea,
                            jsonb_build_object('asignado',asignado, 'operacion', operacion)
                        ) etareas 
                      from base.tareas_tem tt 
                      where tt.operativo = th.operativo AND tt.enc=th.enc 
                         and tt.asignado is not null and tt.operacion is not null
                ) as tt on true
                left join backups.backups b on (th.idblaise = b.respid)
                where (t.rea=1 or t.rea=4) 
                and b.respid is null)`,
            insertIfNotUpdate:false
        }
    
  return def;
}
