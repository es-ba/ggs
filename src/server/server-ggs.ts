"use strict";

import { AppBackend, emergeAppMetaEnc, emergeAppOperativos, emergeAppRelEnc } from "meta-enc";
import {OperativoGenerator, emergeAppVarCal, emergeAppDatosExt, emergeAppConsistencias, emergeAppProcesamiento, emergeAppDmEncu, pgWhiteList} from 'dmencu';
import { emergeAppGgs } from "./app-ggs";

OperativoGenerator.mainTD = 'viviendas';
OperativoGenerator.mainTDPK = 'vivienda'; // TODO: hacer esto dinámico en paquete consistencias
OperativoGenerator.orderedIngresoTDNames = [OperativoGenerator.mainTD, 'viviendas_calculada'];
OperativoGenerator.orderedReferencialesTDNames = ['lotes'];
pgWhiteList.push('blanco','es_fecha','completar_fecha','valida_mesanio_edad');
var AppGgs = emergeAppGgs(
    emergeAppDmEncu(
        emergeAppProcesamiento(
            emergeAppConsistencias(
                emergeAppDatosExt(
                    emergeAppMetaEnc(
                        emergeAppRelEnc(
                            emergeAppVarCal(
                                emergeAppOperativos(AppBackend)
                            )
                        )
                    )
                )
            )
        )
    )
);

new AppGgs().start();

