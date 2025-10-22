"use strict";

import {TableDefinition, TableContext} from "./types-ggs";

export function tem_blaise(context:TableContext):TableDefinition {
    var be=context.be;
    var puedeEditar = context.forDump || context.puede?.campo?.administrar||context.user.rol==='recepcionista';
    return {
        name:'tem_blaise',
        elementName:'tem_blaise',
        editable:puedeEditar,
        fields:[
            {name:'operativo'  ,  typeName: 'text',     editable: true, nullable: false },
            {name:'enc'        ,  typeName: 'text',     editable: true, nullable: false },
            {name:'idblaise'   ,  typeName: 'integer',  editable: true, nullable: false },
            
        ],
        primaryKey:['operativo','enc'],
        hiddenColumns:[
            'TEM__cluster',
        ],
        constraints:[
            {constraintType:'unique', fields:['idblaise']},
        ],
        foreignKeys:[
            {references:'operativos', fields:['operativo']},
            {references:'tem', fields:['operativo','enc'], abr:'E', label:'TEM'},
        ],

    };
}

