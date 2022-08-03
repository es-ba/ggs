import { Respuestas, IdUnidadAnalisis, IdVariable, } from "dmencu/dist/unlogged/unlogged/tipos";
import {setCalculoReaNoRea, buscarNoReaEnRespuestas, getEstructura} from "dmencu/dist/unlogged/unlogged/bypass-formulario";
import { strict as likeAr, beingArray } from "like-ar";

var esNoRea = (respuestas:Respuestas)=>{
    //TODO GENERALIZAR
    var unidadesARecorrer = ['viviendas','hogares','personas'] as IdUnidadAnalisis[];
    var estructura = getEstructura();
    var uaPrincipal = likeAr(estructura.unidades_analisis).find((ua)=>!ua.padre);
    var esNoRea = false;
    var codNoRea:string|null= null;
    let resnorea = buscarNoReaEnRespuestas( unidadesARecorrer,uaPrincipal!,respuestas,estructura.noReas,'no_rea');
    codNoRea=resnorea.nrcodigo;
    esNoRea=resnorea.esvalor;
    return {codNoRea, esNoRea};
};
var esNoReaSup = (respuestas:Respuestas)=>{
    //TODO GENERALIZAR buscarNoreaRespuestas
    var unidadesARecorrerSup = ['viviendas','hogares_sup','personas_sup'] as IdUnidadAnalisis[];
    var estructura = getEstructura();
    var uaPrincipal = likeAr(estructura.unidades_analisis).find((ua)=>!ua.padre);
    var esNoReaSup = false;
    var codNoReaSup:string|null= null;
    let resnorea =buscarNoReaEnRespuestas( unidadesARecorrerSup,uaPrincipal!,respuestas,estructura.noReasSup,'no_rea_sup');//con los parametros que necesitariamos para generalizar
        codNoReaSup=resnorea.nrcodigo;
        esNoReaSup=resnorea.esvalor;
    return {codNoReaSup,esNoReaSup}
};
var esRealizada = (respuestas:Respuestas)=>{
    //TODO GENERALIZAR
    var esRea = false;
    var codRea:number|null= null;
    if(!respuestas['identif' as IdVariable]){
        return {codRea, esRea}
    }else if(respuestas['identif' as IdVariable]==2 ||respuestas['resid_hog' as IdVariable]==2||respuestas['contact' as IdVariable]==2){
        codRea = 2;
        esRea = false;
    }else{
        var reahs: number[]=[] ;
        var respuestasHs = respuestas['hogares'];
        if(respuestasHs){
            for(let respuestasH of respuestasHs){
                var reah:number;
                var selec:number;
                if(respuestasH['entrea' ] != 1||respuestasH['prejue1']==2||respuestasH['tp']==0){
                    reah=2;
                }else{
                    selec=respuestasH['cr_num_miembro']
                    if(respuestasH['personas'] && respuestasH.personas[selec-1] ){
                        var respuestasP = respuestasH.personas[selec-1];
                        var resp_entrea_ind = respuestasP['entreaind' as IdVariable ];
                        if(resp_entrea_ind==null){ //queremos contemplar el undefined
                            reah = 3;
                        }else{
                            reah = Number(resp_entrea_ind);
                        }
                    }else{
                        reah = 3;
                    }
                }
                reahs.push(reah);
            }
            if (reahs.every(rh=>rh==1)){
                codRea = 1;
                esRea = true;
            }else if(reahs.every(rh=>rh==2)){
                codRea = 2;
                esRea = false;
            }else if(reahs.every(rh=>rh==1||rh==3)){
                codRea = 3;
                esRea = false;
            }else{
                codRea = 4;
                esRea = false;
            }
        } else{
            codRea = 3;
            esRea = false;
        }
    }
    return {codRea,esRea}
};
var esRealizadaSup=(respuestas:Respuestas)=>{
    var esReaSup = false;
    var codReaSup:number|null= null;
    if(!respuestas['confir_tel_sup' as IdVariable] && !respuestas['sp1a' as IdVariable]){
        return {codReaSup, esReaSup}
    }else if( respuestas['confir_tel_sup' as IdVariable]==2 || respuestas['confir_dom_sup' as IdVariable]==2||respuestas['sp1a' as IdVariable]==2 ||respuestas['sp1b' as IdVariable]==2||respuestas['sp1c' as IdVariable]==2){
        codReaSup = 2;
        esReaSup = false;
    }else{
        var reahs: number[]=[] ;
        var respuestasHs = respuestas['hogares_sup'];
        if(respuestasHs){
            for(let respuestasH of respuestasHs){
                var reah:number;
                var selec:number;
                if(respuestasH['entrea_sup' ] == 2||respuestasH['spr1_sup']==2||respuestasH['sp4']==3||respuestasH['total_rango_sup']==0){
                    reah=2;
                }else{
                    if(respuestasH['entrea_sup' ]){
                        reah = 1;
                    }else {
                        reah=3;
                    }     
                }
                reahs.push(reah);
            }
            if (reahs.every(rh=>rh==1)){
                codReaSup = 1;
                esReaSup = true;
            }else if(reahs.every(rh=>rh==2)){
                codReaSup = 2;
                esReaSup = false;
            }else if(reahs.every(rh=>rh==1||rh==3)){
                codReaSup = 3;
                esReaSup = false;
            }else{
                codReaSup = 4;
                esReaSup = false;
            }
        } else{
            codReaSup = 3;
            esReaSup = false;
        }
    }
    return {codReaSup,esReaSup}
}

setCalculoReaNoRea(esNoRea, esNoReaSup, esRealizada, esRealizadaSup);