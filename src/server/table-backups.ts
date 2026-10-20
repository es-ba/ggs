"use strict";

import { FieldDefinition, TableContext, TableDefinition } from "./types-ggs";

export const getProcesamientoFields = (opts:{editable:boolean, inTable:boolean }): FieldDefinition[] => ([
	{ name: "verificado_procesamiento",  typeName: "boolean", editable: opts.editable},
	{ name: "observaciones"			  ,  typeName: "text"   , editable: opts.editable},
	{ name: "resul_proc"		 	  					  , typeName: "integer", editable: opts.editable},
	{ name: "web_proc"				  ,  typeName: "text"   , editable: opts.editable}
] as FieldDefinition[]).map(f=>{
    f.title=opts.inTable?f.title:(`bkp_blaise_${f.name}`).replace(/_/g, " ");
    return f;
}); 

export function backups(_context?:TableContext): TableDefinition {
  var definition: TableDefinition = {
    name: "backups",
    elementName: "backup",
    title: "Backups",
    tableName: "backups",
    editable:true,
    allow: {import:true},
    fields: [
        //campo propios:
        { name: "lote", typeName: "integer", editable: false},
        
        // //campos para codificacion - anulados para esta prueba de concepto
        // { name: "cno_padre",        typeName: "integer"},
        // { name: "ciuo_padre",       typeName: "integer"},
        // { name: "cno_madre",        typeName: "integer"},
        // { name: "ciuo_madre",       typeName: "integer"},
        // { name: "cno_ocup_actual",  typeName: "integer"},
        // { name: "ciuo_ocup_actual", typeName: "integer"},
        // { name: "cno_ocup_anterior",  typeName: "integer"},
        // { name: "ciuo_ocup_anterior", typeName: "integer"},
        // { name: "cno_ocup_pareja",  typeName: "integer"},
        // { name: "ciuo_ocup_pareja", typeName: "integer"},
		
        //campos fuentes externas:
        // campos agregados de backups
        { name: "respid", typeName: 'text', editable: false},
        ...getProcesamientoFields({editable:true, inTable:true}),
        { name: "instrument"                    , typeName: "text", editable: false },
        { name: "b1dem01"                       , typeName: "text", editable: false , label:'Identidad de género'},
        { name: "b1dem02_y"                     , typeName: "text", editable: false , label:'Año de nacimiento'},
        { name: "b1dem202_m"                    , typeName: "text", editable: false , label:'Mes de nacimiento'},
        { name: "b2dem17"                       , typeName: "text", editable: false , label:'Dónde vive en la actualidad (comp ult enc)'},
        { name: "b2dem09"                       , typeName: "text", editable: false , label:'Cant habitaciones del hogar'},
        { name: "b2dem11"                       , typeName: "text", editable: false , label:'Régimen de tenencia de la vivienda'},
        { name: "b2dem21_3601"                  , typeName: "text", editable: false, label:'Cant pers de 18 a 79 años del hogar' },
        { name: "b3uni01"                       , typeName: "text", editable: false, label:'Tenía pareja en última enc' },
        { name: "b3uni07"                       , typeName: "text", editable: false, label:'Vive en la misma vivienda con "pareja última enc"' },
        { name: "b3uni18"                       , typeName: "text", editable: false, label:'Convive con su pareja' },
        { name: "b3uni19"	                      , typeName: "text", editable: false, label:'Relación con alguien con quien no convive' },
        { name: "b3dem30c"                      , typeName: "text", editable: false, label:'Intención de convivir en los próximos 3 años' },
        { name: "b3dem22_y"                     , typeName: "text", editable: false, label:'Año de nacimiento de la pareja' },
        { name: "b3dem22_m"                     , typeName: "text", editable: false, label:'Mes de nacimiento de la pareja' },
        { name: "b3dem23"                       , typeName: "text", editable: false, label:'Identidad de género de la pareja' },
        { name: "b6lhi31_1"                     , typeName: "text", editable: false, label:'Convive con hijx_"1"' },
        { name: "b9wel01"                       , typeName: "text", editable: false, label:'Nivel de satisfacción con su vida hoy' },
        { name: "b9wel02"                       , typeName: "text", editable: false, label:'Estado de salud general' },
        { name: "b10hhd01b"                     , typeName: "text", editable: false, label:'Otras pers de 18 a 79 años del hogar (no pareja, no hijx)'},
        { name: "b11gen01"                      , typeName: "text", editable: false, label:'Está viva su madre biológica' },
        { name: "b11gen02"                      , typeName: "text", editable: false, label:'Está vivo su padre biológico' },
        { name: "b11gen55"                      , typeName: "text", editable: false, label:'Tiene nietxs' },
        { name: "b13dem07"                      , typeName: "text", editable: false, label:'Nivel de educación más alto que ha completado' },
        { name: "b13dem06"                      , typeName: "text", editable: false, label:'Situación de empleo' },
        { name: "b13wrk02"                      , typeName: "text", editable: false, label:'Trabajó la semana pasada' },
        { name: "b13wrk04_3601"                 , typeName: "text", editable: false, label:'Nombre de la ocupación actual' },
        { name: "b13wrk04_3602"                 , typeName: "text", editable: false, label:'Tareas y herramientas que utiliza en su ocup actual' },
        { name: "b13wrk06"                      , typeName: "text", editable: false, label:'Tiempo completo o medio tiempo' },
        { name: "b13wrk07"                      , typeName: "text", editable: false, label:'Cant hs de trabajo semanal' },
        { name: "b13wrk11"                      , typeName: "text", editable: false, label:'Trabajó entre las 8pm y las 5am' },
        { name: "b13wrk18"                      , typeName: "text", editable: false, label:'Tipo de contrato de trabajo' },
        { name: "b13wrk26_3603"                 , typeName: "text", editable: false, label:'Tenía trabajo anterior' },
        { name: "b13wrk27_3604"                 , typeName: "text", editable: false, label:'Nombre de su ocupación anterior' },
        { name: "b13wrk27_3605"                 , typeName: "text", editable: false, label:'Tareas y herramientas que utilizaba en su ocup anterior' },
        { name: "b13wrk17_3601"                 , typeName: "text", editable: false, label:'Tipo de organización (privada, pública, mixta)' },
        { name: "b13wrk28_3601"                 , typeName: "text", editable: false, label:'Categoria ocupacional de la ocu anterior' },
        { name: "b14dem25"                      , typeName: "text", editable: false, label:'Máximo nivel educativo que su pareja completó' },
        { name: "b14dem26"                      , typeName: "text", editable: false, label:'Situación actual de empleo de su pareja' },
        { name: "b15inc03"                      , typeName: "text", editable: false, label:'El hogar llega a fin de mes' },
        { name: "b15inc06"                      , typeName: "text", editable: false, label:'Ingreso neto total del hogar' },
        { name: "age"                           , typeName: "text", editable: false, label:'Edad' },
        { name: "hascorespartner"               , typeName: "text", editable: false, label:'Con pareja cohabitante en el hogar' },
        { name: "hascoreschildunder15"          , typeName: "text", editable: false, label:'Con hijx cohabitante menor de 15 años' },
        { name: "mumcores"                      , typeName: "text", editable: false, label:'La madre vive en el mismo hogar' },
        { name: "dadcores"                      , typeName: "text", editable: false, label:'El padre vive en el mismo hogar' },
        { name: "breportint01_3601"             , typeName: "text", editable: false, label:'Código de encuestador' },
        { name: "breportint02_3601"             , typeName: "text", editable: false, label:'Nombre de encuestador' },
        { name: "breportb17rep01"               , typeName: "text", editable: false, label:'Persona presente con el respondiente' },
        { name: "breportb17rep02"               , typeName: "text", editable: false, label:'Influencia de esa presencia' },
        { name: "breportb17rep04"               , typeName: "text", editable: false, label:'Preguntas que influenció' },
        { name: "breportb17rep05"               , typeName: "text", editable: false, label:'Predispocisión del respondiente' },
        { name: "breportb17rep06"               , typeName: "text", editable: false, label:'Confianza sobre la información del respondiente' },
        { name: "begindate"                     , typeName: "text", editable: false, label:'Fecha de inicio' },
        { name: "begintime"                     , typeName: "text", editable: false, label:'Horario de inicio' },
        { name: "enddate"                       , typeName: "text", editable: false, label:'Fecha de finalización' },
        { name: "endtime"                       , typeName: "text", editable: false, label:'Horario de finalización' },
        { name: "last_var"                      , typeName: "text", editable: false },
        { name: "agreedintro"                   , typeName: "text", editable: false },
        { name: "complete"                      , typeName: "text", editable: false },
        { name: "partnerage"                    , typeName: "text", editable: false, label:'Edad de la pareja' },
        { name: "nbiolkids"                     , typeName: "text", editable: false, label:'Número de hijxs biológicxs' },
        { name: "nstepkids"                     , typeName: "text", editable: false, label:'Número de hijastrxs' },
        { name: "nadoptkids"                    , typeName: "text", editable: false, label:'Número de hijxs adoptivxs' },
        { name: "nkidstotal"                    , typeName: "text", editable: false, label:'Número de hijxs total' },
        { name: "adopt_step_fosterparentcores"  , typeName: "text", editable: false, label:'Vive en el hogar algún padre/madre no biológico' },
        { name: "completitud"                   , typeName: "text", editable: false },
    ],
    primaryKey: ["lote", "respid"],
    constraints:[
        {constraintType:'unique', fields:['respid', 'verificado_procesamiento']},
        {constraintType:'check', expr:'verificado_procesamiento in (null,true)', consName:'verificado_procesamiento puede true o nulo'},
    ],
    foreignKeys: [{ references: "lotes", fields: ["lote"] }],
    // hiddenColumns: [
    //    "modificado",
    // ],
  };
  return definition;
}
