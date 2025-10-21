"use strict";

import { TableDefinition, TableContext } from "./types-ggs";
export function visitas_web_sup(context: TableContext): TableDefinition {
    var esEditable = context.user.rol === 'admin';
    return {
        "name": "visitas_web_sup",
        editable: esEditable,
        "fields": [
            { "name": "operativo", "typeName": "text", "nullable": false },
            { "name": "vivienda", "typeName": "text", "nullable": false },
            { "name": "visita_web", "typeName": "bigint", "nullable": false },
            { "name": "anoenc_sup", "typeName": "bigint", "nullable": true },
            { "name": "rol_sup", "typeName": "text", "nullable": true },
            { "name": "per_sup", "typeName": "bigint", "nullable": true },
            { "name": "usu_sup", "typeName": "text", "nullable": true },
            { "name": "fecha_sup", "typeName": "text", "nullable": true },
            { "name": "hora_sup", "typeName": "text", "nullable": true },
            { "name": "anotacion_sup", "typeName": "text", "nullable": true }
        ],
        "sql": {
            "isReferable": true
        },
        "primaryKey": ["operativo", "vivienda", "visita_web"],
        "detailTables": [],
        "foreignKeys": [
            { "references": "viviendas", "fields": ["operativo", "vivienda"] }
        ]
    };
}