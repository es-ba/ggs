"use strict";

import { TableDefinition } from "./types-ggs";

export function lotes(): TableDefinition {
  return {
    name: "lotes",
    elementName: "lote",
    editable: true,
    fields: [
      { name: "lote", typeName: "integer", specialDefaultValue: "next_number" },
      { name: "recepcion", typeName: "date", specialDefaultValue: "current_date"},
      { name: "observaciones", typeName: "text", label:'obs lote', isName: true },
      { name: "procesamiento", typeName: "text" },
      { name: "cant", typeName: "bigint", inTable: false, editable: false },
    ],
    primaryKey: ["lote"],
    detailTables: [
      { table: "backups", abr: "B", fields: ["lote"] },
    ],
    sortColumns: [{ column: "lote", order: -1 }],
    sql: {
      fields: {
        cant: {
          expr: "coalesce(nullif((select count(*) from backups where backups.lote = lotes.lote),0), (select count(*) from backups where backups.lote = lotes.lote))",
        },
      },
    },
  };
}
