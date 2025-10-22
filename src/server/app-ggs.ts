"use strict";

import * as dmencu from "./types-ggs";
import {Context, MenuInfoBase, Request, Response, OptsClientPage, TableDefinition } from "./types-ggs";
import {defConfig} from "./def-config"
import {procedures} from "./procedures-ggs"
import {tem_blaise} from  "./table-tem_blaise";

import { viviendas           } from './table-viviendas';
import { visitas             } from './table-visitas';
import { hogares             } from './table-hogares';
import { visitas_web         } from './table-visitas_web';
import { visitas_tel         } from './table-visitas_tel';
import { visitas_pres        } from './table-visitas_pres';
import { personas            } from './table-personas';
import { visitas_sup         } from './table-visitas_sup';
import { hogares_sup         } from './table-hogares_sup';
import { visitas_web_sup         } from './table-visitas_web_sup';
import { visitas_tel_sup         } from './table-visitas_tel_sup';
import { visitas_pres_sup         } from './table-visitas_pres_sup';
import { personas_sup        } from './table-personas_sup';
import { grilla_rea_sin_blaise } from './grilla_rea_sin_blaise';

const APP_DM_VERSION="#22-10-06";

export type Constructor<T> = new(...args: any[]) => T;
export function emergeAppGgs<T extends Constructor<dmencu.AppAppDmEncuType>>(Base:T){
  return class AppGgs extends Base{
    constructor(...args:any[]){ 
        super(args);
    }
    
    configStaticConfig(){
        super.configStaticConfig();
        this.setStaticConfig(defConfig);
    }

    async getProcedures(){
        var parentProc = await super.getProcedures()
        return parentProc.concat(procedures);
    }

    clientIncludes(req:Request, hideBEPlusInclusions:OptsClientPage){
        return super.clientIncludes(req, hideBEPlusInclusions).concat([
            { type: 'js', src: 'client/ggs.js' },
            { type: 'js', src: 'my-bypass-formulario.js' },
            { type: 'js', src: 'my-render-formulario.js' },
        ])
    }
    createResourcesForCacheJson(){
        var be = this;
        var jsonResult = super.createResourcesForCacheJson();
        jsonResult.version = APP_DM_VERSION;
        jsonResult.appName = 'ggs';
        jsonResult.cache=jsonResult.cache.concat([
            "my-render-formulario.js",
            'my-bypass-formulario.js'
        ])
        return jsonResult
    }
    getColorsJson(sufijo:'_test'|'_capa'|''){
        let miSufijo: '_prod'|'_test'|'_capa' = sufijo || '_prod';
        let coloresEntornos = {
            "_prod":"#067DB5",
            "_test":"#C47208",
            "_capa":"#880996",
        }
        return {
            "start_url": "../campo",
            "display": "standalone",
            "theme_color": "#3F51B5",
            "background_color": coloresEntornos[miSufijo]
        }
    }
    
    getMenuControles(context:Context){
    
        let menuControles = super.getMenuControles(context);
        menuControles.push({menuType:'table', name:'grilla_rea_sin_blaise', label:'rea sin blaise'})
        return menuControles;
    
    }
    prepareGetTables(){
        var be=this;
        super.prepareGetTables();
        this.getTableDefinition={
            ...this.getTableDefinition,
            tem_blaise,
            
            viviendas,
            visitas,
            hogares,
            personas,
            visitas_sup,
            hogares_sup,
            visitas_web,
            visitas_tel,
            visitas_pres,
            visitas_web_sup,
            visitas_tel_sup,
            visitas_pres_sup,
            personas_sup,
            grilla_rea_sin_blaise,
        }
        // delete(this.getTableDefinition.hogares);
        // delete(this.getTableDefinition.hogares_sup);
        // delete(this.getTableDefinition.visitas);
        // delete(this.getTableDefinition.visitas_sup);

        be.appendToTableDefinition('tem',function(tableDef:TableDefinition){
            tableDef.hiddenColumns=tableDef.hiddenColumns?.filter(element => element !='semana');
           // console.log('camposhidden', tableDef.hiddenColumns )
            tableDef.fields.find((field)=>field.name=='semana')!.visible=true;
            tableDef.fields.splice(26, 0, 
                {name :'recep_blaise' , typeName: 'text', editable: true  },
            );
            tableDef.fields.splice(27, 0, 
                {name :'proie_blaise' , typeName: 'text', editable: true  },
            );
            tableDef.fields.splice(28, 0, 
                {name :'lote' , typeName: 'text', editable: true  },
            );
            tableDef.fields.splice(29, 0, 
                {name :'grado_matching' , typeName: 'decimal', editable: true  },
            );
            tableDef.fields.splice(30, 0, 
                {name :'observaciones_blaise' , typeName: 'text', editable: true  },
            );
            tableDef.fields.splice(31, 0, 
                {name :'resultado_blaise' , typeName: 'text', editable: true  },
            );
            tableDef.sql!.from = tableDef.sql!.from!.replace(
                'from tem t',
                ',t.recep_blaise, t.proie_blaise, t.lote, t.grado_matching, t.observaciones_blaise, t.resultado_blaise from tem t'
            );
        });

        be.appendToTableDefinition('tareas_tem',function(tableDef:TableDefinition){
            tableDef.hiddenColumns=tableDef.hiddenColumns?.filter(element => element !='semana');
           // console.log('camposhidden', tableDef.hiddenColumns )
            tableDef.fields.splice(26, 0, 
                {name :'recep_blaise'        , typeName: 'text'   , editable: false, inTable: false },
            );
            tableDef.fields.splice(27, 0, 
                {name :'proie_blaise'        , typeName: 'text'   , editable: false, inTable: false },
            );
            tableDef.fields.splice(28, 0, 
                {name :'lote'                , typeName: 'text'   , editable: false, inTable: false },
            );
            tableDef.fields.splice(29, 0, 
                {name :'grado_matching'      , typeName: 'decimal', editable: false, inTable: false },
            );
            tableDef.fields.splice(30, 0, 
                {name :'observaciones_blaise', typeName: 'text'   , editable: false, inTable: false },
            );
            tableDef.fields.push(
                {name:'semana'               , typeName:'integer' , editable: false, inTable: false },
            );
            tableDef.sql!.from = tableDef.sql!.from!.replace(
                'select tareas.tarea, t.operativo, t.enc, t.area',
                'select tareas.tarea, t.operativo, t.enc, t.area, t.recep_blaise, t.proie_blaise, t.lote, t.grado_matching, t.observaciones_blaise, t.semana, t.resultado_blaise '
            );
        })
        be.appendToTableDefinition('usuarios',function(tableDef:TableDefinition){
            tableDef.fields.push(
                {name:'usuario_blaise' , typeName:'text' , editable: true },
            );
        })
        //be.appendToTableDefinition('inconsistencias',function(tableDef:TableDefinition, context:Context){
        //    tableDef.fields.splice(2,0,
        //        {name:'persona'     , typeName:'bigint'   , editable: false},
        //    );
        //    tableDef.editable=tableDef.editable || context.puede?.encuestas.justificar;
        //    tableDef.fields.forEach(function(field){
        //        if(field.name=='pk_integrada'){
        //            field.visible=false;
        //        }
        //        if(field.name=='justificacion'){
        //            field.editable=context.forDump || context.puede?.encuestas.justificar;
        //        }
        //    })
        //})
    }
  }
}
