"use strict";

import {TableDefinition, TableContext} from "./types-dmencu";

export function tem_hogar(context:TableContext):TableDefinition {
    var be=context.be;
    var puedeEditar = context.forDump || context.puede?.campo?.administrar||context.user.rol==='recepcionista';
    return {
        name:'tem_hogar',
        elementName:'tem_hogar',
        editable:puedeEditar,
        fields:[
            {name:'operativo'  ,  typeName: 'text',     editable: false, nullable: false },
            {name:'enc'        ,  typeName: 'text',     editable: false, nullable: false },
            {name:'hogar'      ,  typeName: 'integer',  editable: false, nullable: false },
            {name:'idblaise'   ,  typeName: 'integer',  editable: false, nullable: false },
            
        ],
        primaryKey:['operativo','enc', 'hogar', 'idblaise'],
        foreignKeys:[
            {references:'operativos', fields:['operativo']},
            {references:'tem', fields:['operativo','enc'], abr:'E', label:'TEM'},
        ],

    };
}

