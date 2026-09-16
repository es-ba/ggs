import { IdFormulario, RespuestasRaiz, ForPk, IdVariable, TEM as TEMBase} from "dmencu/dist/unlogged/unlogged/tipos";
import {getDatosByPass, setCalcularVariablesEspecificasOperativo, respuestasForPk} from "dmencu/dist/unlogged/unlogged/bypass-formulario";
import {setOrdenPorDefectoAtributos} from "dmencu/dist/unlogged/unlogged/render-formulario";


export type TEM = TEMBase & {
    seleccionado_ant: null | {
        sel:number,
        edad:number,
        sexo:number,
        email:string,
        movil:string,
        telms:string,
        nombre:string,
    };
    idblaise: string | null;
};

setCalcularVariablesEspecificasOperativo((respuestasRaiz:RespuestasRaiz, forPk:ForPk)=>{
    //ajustar variables
    if(forPk.formulario == 'F:S1_SUP' as IdFormulario){
        let hogar = forPk.hogar as number - 1;
        if(respuestasRaiz.hogares && respuestasRaiz.hogares[hogar]){
            let respuestasHogarSup = respuestasRaiz.hogares_sup[hogar];
            let respuestasHogar = respuestasRaiz.hogares[hogar];
            respuestasHogarSup.resp_indi_sup = respuestasHogar.msnombre;
            if(respuestasHogar.personas && respuestasHogar.personas instanceof Array){
                respuestasHogarSup.resp_comp_ed_sup = respuestasHogar.personas[0]?.edad;
                respuestasHogarSup.resp_comp_sup = respuestasHogar.personas[0]?.nombre;
                respuestasHogarSup.resp_indi_ed_sup = 
                    respuestasHogar.cr_num_miembro?
                        respuestasHogar.personas[respuestasHogar.cr_num_miembro -1]?.edad
                    :null;
            }
        }
    }
    if(forPk.formulario == 'F:RE' as IdFormulario){
        let {respuestas} = respuestasForPk(forPk);
        if(respuestasRaiz.rea_web == '1' || respuestasRaiz.rea_tel == '1' || respuestasRaiz.rea_pres == '1'){
            const datosByPassViv= getDatosByPass().informacionHdr[forPk.vivienda];
            const datosTEM = datosByPassViv.tem as TEM;
            var seleccionadoAnt=datosTEM.seleccionado_ant;
            if(seleccionadoAnt){
                respuestas['msnombrei' as IdVariable] = seleccionadoAnt.nombre;
            }

            let idBlaise = datosTEM.idblaise;
            if(idBlaise){
                respuestas['id_blaise' as IdVariable] = idBlaise;
                let idParseado = idBlaise.split('');
                idParseado.splice(6,0,"-");
                idParseado.splice(3,0,"-");
                idParseado = idParseado.join('');
                respuestas['id_blaise_parseado' as IdVariable] = idParseado;
            }else{
                //throw Error ("no hay id de blaise asignado para el hogar")
            }
            respuestas['total_i1' as idVariable] = 1;
        }else {
            respuestas['msnombrei' as IdVariable] = null;
            respuestas['id_blaise' as IdVariable] = null;
            respuestas['id_blaise_parseado' as IdVariable] = null;
            respuestas['total_i1' as idVariable] = 0;
        }
    }    
})

setOrdenPorDefectoAtributos(['sel','nombre','sexo','email', 'telms', 'movil', 'email'])