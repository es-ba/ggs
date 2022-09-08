"use strict";

import * as dmencu from "./types-ggs";
import {Context, MenuInfoBase, Request, Response, OptsClientPage, TableDefinition } from "./types-ggs";
import {defConfig} from "./def-config"
import {procedures} from "./procedures-ggs"
import {tem_hogar} from  "./table-tem_hogar";

const APP_DM_VERSION="#22-09-08";

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
    createResourcesForCacheJson(parameters){
        var be = this;
        var jsonResult = super.createResourcesForCacheJson(parameters);
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
    getMenu(context:Context){
        let menu:MenuInfoBase[] = [];
        if(this.config.server.policy=='web'){
            if(context.puede?.encuestas?.relevar){
                if(this.config['client-setup'].ambiente=='demo' || this.config['client-setup'].ambiente=='test' || this.config['client-setup'].ambiente=='capa'){
                    menu.push({menuType:'demo', name:'demo', selectedByDefault:true})
                }else{
                    menu.push({menuType:'path', name:'relevamiento', path:'/campo'})
                }
                menu.push(
                    {menuType:'sincronizar_dm', name:'sincronizar'},
                );
            }
        }else{
            if(context.puede?.campo?.editar){
                menu.push(
                    {menuType:'abrir_encuesta', name:'abrir_encuesta'},
                    //{menuType:'consistir_encuesta', name:'consistir_encuesta'},
                )
                menu.push(
                    {menuType:'menu', name:'recepcion', label:'recepción' ,menuContent:[
                        {menuType:'table', name:'mis_areas', table:'areas', ff:{recepcionista:context.user.idper}},
                        {menuType:'table', name:'mis_encuestadores'},
                        {menuType:'table', name:'areas'},
                        {menuType:'table', name:'tem_recepcion', label:'TEM'},
                        {menuType:'table', name:'tareas_tem', label:'TareasTEM'}
                    ]},            
                )
            }
            console.log("context user", context.user)
            if(context.superuser){
                menu.push(
                    {menuType:'menu', name:'control', menuContent:[
                        {menuType:'table', name:'resumen', table:'control_resumen', selectedByDefault:true},
                        {menuType:'table', name:'dominio', table:'control_campo_dominio'},
                        {menuType:'table', name:'zona'   , table:'control_campo_zona'  },
                        {menuType:'table', name:'comuna' , table:'control_campo_comuna'},
                        {menuType:'table', name:'área'   , table:'control_campo_area'  },
                        {menuType:'table', name:'participacion'        , table:'control_campo_participacion'  },
                    ]},            
                )
            }
            if(context.puede?.encuestas.procesar){
                menu = [ ...menu,
                    {menuType:'menu', name:'procesar', menuContent:[
                        {menuType:'table', name:'variables'    },
                        {menuType:'table', name:'consistencias'},
                        {menuType:'table', name:'inconsistencias'},
                        {menuType:'table', name:'tabla_datos'  },
                        {menuType:'table', name:'diccionario'  , label:'diccionarios' },
                    ]},
                ]
            }
            if(context.superuser){
                menu = [ ...menu,
                    {menuType:'menu', name:'configurar', menuContent:[
                        {menuType:'menu', name:'muestra', label:'muestra', menuContent:[
                            {menuType:'table', name:'tem', label: 'TEM'} ,
                            {menuType:'table', name:'tareas'},
                        // {menuType:'table', name:'personal_rol'},
                        ]},
                        {menuType:'menu', name:'metadatos', menuContent:[
                            {menuType:'table', name:'operativos'},
                            {menuType:'table', name:'formularios' , table:'casilleros_principales'},
                            {menuType:'table', name:'plano'       , table:'casilleros'},
                            {menuType:'table', name:'tipoc'       , label:'tipos de celdas'},
                            {menuType:'table', name:'tipoc_tipoc' , label:'inclusiones de celdas'},
                        ]},
                        {menuType:'table', name:'parametros'},
                    ]},
                    {menuType:'menu', name:'usuarios', menuContent:[
                        {menuType:'table', name:'usuarios', selectedByDefault:true},
                        {menuType:'table', name:'roles'},
                        {menuType:'table', name:'permisos'},
                        {menuType:'table', name:'roles_permisos'},
                    ]},
                    // {menuType:'proc', name:'generate_tabledef', proc:'tabledef_generate', label:'generar tablas'  },
                ]
            }
        }       
        return {menu};
    }
    prepareGetTables(){
        var be=this;
        super.prepareGetTables();
        this.getTableDefinition={
            ...this.getTableDefinition,
            tem_hogar,
        }

        be.appendToTableDefinition('tem',function(tableDef:TableDefinition, context:Context){
            tableDef.hiddenColumns=tableDef.hiddenColumns.filter(element => element !='semana');
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

        be.appendToTableDefinition('tareas_tem',function(tableDef:TableDefinition, context:Context){
            tableDef.hiddenColumns=tableDef.hiddenColumns.filter(element => element !='semana');
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
        be.appendToTableDefinition('usuarios',function(tableDef:TableDefinition, context:Context){
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
