"use strict";

import { AppBackend, emergeAppMetaEnc, emergeAppOperativos, emergeAppRelEnc } from "meta-enc";
import {OperativoGenerator, emergeAppVarCal, emergeAppDatosExt, emergeAppConsistencias, emergeAppProcesamiento, emergeAppDmEncu} from 'dmencu';
import { emergeAppGgs } from "./app-ggs";

OperativoGenerator.mainTD = 'personas';
OperativoGenerator.mainTDPK = 'persona'; // TODO: hacer esto dinámico en paquete consistencias
OperativoGenerator.orderedIngresoTDNames = [OperativoGenerator.mainTD, 'persona_calculada'];
OperativoGenerator.orderedReferencialesTDNames = ['lotes'];

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

