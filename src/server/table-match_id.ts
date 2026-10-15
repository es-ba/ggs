"use strict";

import { changing } from "best-globals";
import { backups } from "./table-backups";
import { TableDefinition } from "./types-ggs";

export function match_id(): TableDefinition {
    let def = backups();
    def.title='Consistencias Blaise'
    const ggs_fields = [
        //campos base.tem_blaise
        {name:'idblaise'   ,  typeName: 'text',  editable: false },
        {name:'operativo'  ,  typeName: 'text',     editable: false },
        {name:'enc'        ,  typeName: 'text',     editable: false },
        // {name:'hogar'      ,  typeName: 'integer',  editable: false },
        //campos base.tem
        {name:'tarea_actual'    , typeName: 'text'  ,  editable: false },
        {name:'rea'      ,  typeName: 'integer',  editable: false },
        {name:'norea'      ,  typeName: 'integer',  editable: false },
        //{name:'resumen_estado' , typeName:'text',  editable:false},
        //{name:'resultado'       , typeName: 'text'    ,  editable: false },

        {name:'rea_web'         , typeName: 'integer',  editable: false },
        {name:'rea_tel'         , typeName: 'integer',  editable: false },
        {name:'rea_pres'        , typeName: 'integer',  editable: false },

        {name:'result_sup'      , typeName: 'integer' ,  editable: false },

        //campos base.personas intercalados con campos espejo de backups (dem01,asex,dobm,doby)
        //podriamos agregar una variable construida con la comparacion de estos campos como en la grilla del censo
        //{name:'msnombrei'    ,  typeName: 'text'   ,  editable: false },
        //campos base.tareas_tem
        {name:'verif_campo'     ,  typeName: 'text' ,  editable: false },
    ]
    //agrego msnombrei  para luego ordenarlos
    def.fields=[{name:'msnombrei'    ,  typeName: 'text'   ,  editable: false }, ...def.fields];
    // se pide ver todos los campos del backup con este orden
    const camposOrden=['respid'
        ,'lote'
	    ,'verificado_procesamiento'
	    ,'observaciones'
	    ,'resul_proc'
	    ,'web_proc'

        ,'begindate'
        ,'begintime'
        ,'enddate'
        ,'endtime'
        ,'breportint01_3601'
        ,'breportint02_3601'
        ,'complete'
        ,'last_var'
        ,'agreedintro'
        ,'completitud'
        ,'msnombrei'
        ,'age'
        ,'b1dem01'
        ,'b1dem02_y'
        ,'b1dem202_m'
        //,'b2dem17'
        ,'b2dem09'
        ,'b2dem11'
        ,'b2dem21_3601'
        ,'b10hhd01b'
        ,'nbiolkids'
        ,'nstepkids'
        ,'nadoptkids'
        ,'nkidstotal'
        //,'b11gen55'
        ,'b3uni01'
        //,'b3uni19'
        //,'b3dem30c'
        ,'b3uni07'
        ,'b3uni18'
        ,'hascorespartner'
        ,'partnerage'
        //,'b3dem22_y'
        //,'b3dem22_m'
        //,'b3dem23'
        //,'b14dem25'
        //,'b14dem26'
        ,'hascoreschildunder15'
        ,'b6lhi31_1'
        ,'b11gen01'
        ,'mumcores'
        ,'b11gen02'
        ,'dadcores'
        ,'adopt_step_fosterparentcores'
        ,'b13dem07'
        ,'b13dem06'
        ,'b13wrk02'
        ,'b13wrk04_3601'
        ,'b13wrk04_3602'
        ,'b13wrk17_3601'
        ,'b13wrk18'
        ,'b13wrk06'
        ,'b13wrk07'
        ,'b13wrk11'
        ,'b13wrk26_3603'
        ,'b13wrk27_3604'
        ,'b13wrk27_3605'
        ,'b13wrk28_3601'
        ,'b9wel01'
        ,'b9wel02'
        //,'b15inc03'
        //,'b15inc06'
        ,'breportb17rep01'
        ,'breportb17rep02'
        ,'breportb17rep04'
        ,'breportb17rep05'
        ,'breportb17rep06'
    ];
    // genero indice campo, indice a partir  de aareglo de ordenes
    const ordenMap = new Map(camposOrden.map((name, index) => [name, index]));
    // si no encuentra el campo, va al finak
    const camposOrdenados = [...def.fields].sort((x, y) => {
        const indexA = ordenMap.get(x.name) ?? Infinity;
        const indexB = ordenMap.get(y.name) ?? Infinity;
        return indexA - indexB;
    });
    ['instrument'].forEach(fNameToNotShow=>{
        const fieldToNotShow=def.fields.find(f=>f.name===fNameToNotShow)
        if (!fieldToNotShow) throw new Error('columna no existente '+ fNameToNotShow)
        fieldToNotShow.visible = false
    })

    /*     
    fieldsToShow.forEach(fNameToShow=>{
        const fieldToShow=def.fields.find(f=>f.name===fNameToShow)
        if (!fieldToShow) throw new Error('columna no existente '+ fNameToShow)
        fieldToShow.visible = true
    })
    */    
    //@ts-ignore
    def.fields=[...ggs_fields, ...camposOrdenados]
    


    def.sql = changing(def.sql||{}, 
        {
            isTable:false,
            from:`(
                SELECT
                    tb.*,
                    v.msnombrei, v.rea_web, v.rea_tel, v.rea_pres,
                    t.rea, t.norea, t.resumen_estado, t.resultado, t.result_sup,
                    t.tarea_actual,
                    tt.verif_campo,
                    b.*
                FROM backups b 
                    JOIN base.tem_blaise tb ON (b.respid = tb.idblaise)
                    JOIN base.tem t ON t.operativo=tb.operativo AND t.enc=tb.enc
                    LEFT JOIN base.viviendas v ON (v.operativo = tb.operativo AND v.vivienda = tb.enc AND tb.idblaise = v.id_blaise)
                    LEFT JOIN lateral (
                        select case when count(*) = count(verificado) then max(tt.verificado) else null end verif_campo 
                        FROM base.tareas_tem tt 
                        WHERE tt.operativo = tb.operativo AND tt.enc=tb.enc 
                            AND tt.tarea = 'encu' AND tt.asignado is not null AND tt.operacion is not null
                    ) as tt ON true
                    LEFT JOIN backups otrob ON b.respid=otrob.respid AND otrob.lote <>b.lote AND otrob.verificado_procesamiento
                WHERE 
                    b.verificado_procesamiento
                    OR (b.lote = (select max(lote) FROM backups bm where b.respid=bm.respid))
                    AND otrob.respid is null)`,
            insertIfNotUpdate:false
        })
  return def;
}