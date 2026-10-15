import { IdFormulario, RespuestasRaiz, ForPk, IdVariable, IdUnidadAnalisis, TEM as TEMBase} from "dmencu/dist/unlogged/unlogged/tipos";
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
            let respuestasHogarSup = respuestasRaiz['hogares_sup' as IdUnidadAnalisis][hogar];
            let respuestasHogar = respuestasRaiz.hogares[hogar];
            respuestasHogarSup['resp_indi_sup' as IdVariable] = respuestasHogar['msnombre' as IdVariable];
            if(respuestasHogar.personas && respuestasHogar.personas instanceof Array){
                respuestasHogarSup['resp_comp_ed_sup' as IdVariable] = respuestasHogar.personas[0]?.['edad' as IdVariable];
                respuestasHogarSup['resp_comp_sup' as IdVariable] = respuestasHogar.personas[0]?.['nombre' as IdVariable];
                respuestasHogarSup['resp_indi_ed_sup' as IdVariable] =
                    respuestasHogar['cr_num_miembro' as IdVariable]?
                        respuestasHogar.personas[Number(respuestasHogar['cr_num_miembro' as IdVariable]) -1]?.['edad' as IdVariable]
                    :null;
            }
        }
    }
    if(forPk.formulario == 'F:RE' as IdFormulario){
        let {respuestas} = respuestasForPk(forPk);
        if(respuestasRaiz['rea_web' as IdVariable] == '1' || respuestasRaiz['rea_tel' as IdVariable] == '1' || respuestasRaiz['rea_pres' as IdVariable] == '1'){
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
                respuestas['id_blaise_parseado' as IdVariable] = idParseado.join('');
            }else{
                //throw Error ("no hay id de blaise asignado para el hogar")
            }
            respuestas['total_i1' as IdVariable] = 1;
        }else {
            respuestas['msnombrei' as IdVariable] = null;
            respuestas['id_blaise' as IdVariable] = null;
            respuestas['id_blaise_parseado' as IdVariable] = null;
            respuestas['total_i1' as IdVariable] = 0;
        }
    }    
})

setOrdenPorDefectoAtributos(['sel','nombre','sexo','email', 'telms', 'movil', 'email'])