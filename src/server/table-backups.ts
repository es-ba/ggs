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

export function backups(_context:TableContext): TableDefinition {
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
		{ name:"begindate"               , typeName: "text", editable: false },
		{ name:"begintime"               , typeName: "text", editable: false },
		{ name:"enddate"                 , typeName: "text", editable: false },
		{ name:"endtime"                 , typeName: "text", editable: false },
		
		{ name: "instrument"             , typeName: "text", editable: false  },
		//{ name: "status"                 , typeName: "text", editable: false  },
		{ name: "agreedintro"            , typeName: "text", editable: false  },
		{ name: "complete"               , typeName: "text", editable: false  },
		{ name: "last_var"               , typeName: "text", editable: false  },
		{ name: "completitud"            , typeName: "text", editable: false  },
		//{ name: "gender"                 , typeName: "text", editable: false  },
		{ name: "age"                    , typeName: "text", editable: false  },
		{ name: "nbiolkids"              , typeName: "text", editable: false  },
		{ name: "nstepkids"              , typeName: "text", editable: false  },
		{ name: "nadoptkids"             , typeName: "text", editable: false  },
		{ name: "nkidstotal"             , typeName: "text", editable: false  },
		{ name: "partnerage"             , typeName: "text", editable: false  },
		{ name: "hascorespartner"        , typeName: "text", editable: false  },
		{ name: "hascoreschildunder15"   , typeName: "text", editable: false  },
		{ name: "mumcores"               , typeName: "text", editable: false  },
		{ name: "dadcores"               , typeName: "text", editable: false  },
		{ name: "adopt_step_fosterparentcores",typeName: "text", editable: false  },

		{ name: "b1dem01"                , typeName: "text", editable: false  },
		//{ name: "b1dem02"                , typeName: "text", editable: false  },
		{ name: "b1dem02_y"              , typeName: "text", editable: false  },
		{ name: "b1dem202_m"             , typeName: "text", editable: false  },
		{ name: "b2dem09"                , typeName: "text", editable: false  },
		{ name: "b2dem11"                , typeName: "text", editable: false  },
		{ name: "b2dem21_3601"           , typeName: "text", editable: false  },
		{ name: "b3uni01"                , typeName: "text", editable: false  },
		{ name: "b3uni07"                , typeName: "text", editable: false  },
		{ name: "b3uni18"                , typeName: "text", editable: false  },
		{ name: "b6lhi31_1"              , typeName: "text", editable: false  },
		{ name: "b9wel01"                , typeName: "text", editable: false  },
		{ name: "b9wel02"                , typeName: "text", editable: false  },
		{ name: "b10hhd01b"              , typeName: "text", editable: false  },
		{ name: "b11gen01"               , typeName: "text", editable: false  },
		{ name: "b11gen02"               , typeName: "text", editable: false  },
		{ name: "b13dem06"               , typeName: "text", editable: false  },
		{ name: "b13dem07"               , typeName: "text", editable: false  },
		{ name: "b13wrk02"               , typeName: "text", editable: false  },
		{ name: "b13wrk04_3601"          , typeName: "text", editable: false  },
		{ name: "b13wrk04_3602"          , typeName: "text", editable: false  },
		{ name: "b13wrk06"               , typeName: "text", editable: false  },
		{ name: "b13wrk07"               , typeName: "text", editable: false  },
		{ name: "b13wrk11"               , typeName: "text", editable: false  },
		{ name: "b13wrk17"               , typeName: "text", editable: false  },
		{ name: "b13wrk18"               , typeName: "text", editable: false  },
		{ name: "b13wrk26_3603"          , typeName: "text", editable: false  },
		{ name: "b13wrk27_3604"          , typeName: "text", editable: false  },
		{ name: "b13wrk27_3605"          , typeName: "text", editable: false  },
		{ name: "b13wrk28"               , typeName: "text", editable: false  },		
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
