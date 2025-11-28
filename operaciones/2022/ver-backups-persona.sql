set search_path = base, comun, mues, his, public;

select * from (
 select operativo, enc, nomcalle, asignado, json_backup -> 'hogares' -> 0 -> 'nombrer' as respondente
    , json_backup -> 'resumenEstado' as resumenEstado
    , (select max(cha_when) from his.changes
        where cha_new_pk = jsonb_build_object('operativo', t.operativo, 'enc', t.enc)
            and cha_table = 'tem'
            and cha_column = 'json_backup' ) fecha_backup
    , (select max(cha_when) from his.changes
        where cha_new_pk = jsonb_build_object('operativo', t.operativo, 'enc', t.enc)
            and cha_table = 'tem'
            and cha_column = 'json_encuesta' ) fecha_datos
    from tareas_tem tt inner join tem t using (operativo, enc)
    where json_encuesta is distinct from json_backup
) x
where fecha_backup > fecha_datos;

/*
{"v1": "1", "$dirty": true, "codRea": 1, "habita": "1", "obs_re": "NOREA - AUSENCIA. Recu. REA.", "$B.F:S1": "ok", "hogares": 
   [{"tp": 2, "gg1": "1", "fijo": "1123908948", "entrea": "1", "razon1": null, "sorteo": "1", "$B.F:I1": "ok", "nombrer": "Jose", "total_m": 2, "msnombre": "Jose", "personas": [{"l0": "A", "p4": 1, "p5": "2", "$p0": 1, "msi": 1, "p5b": 2, "p6a": null, "edad": 57, "p722": "2", "p825": "2", "sexo": "1", "fin_1": "1", "fin_3": "1", "nacms": "06/1965", "reams": "1", "telms": "1123908948", "nombre": "Jose", "msedadi": 57, "correoms": ".", "entreaind": "1", "id_blaise": 544160518, "msnombrei": "Jose", "id_blaise_parseado": "544-160-518"}, {"l0": "B", "p4": "2", "p5": "2", "$p0": 2, "p5b": 1, "edad": 53, "p722": "2", "p825": "2", "sexo": "2", "nombre": "sandra"}], "razon2_7": null, "$B.F:S1_P": "ok", "f_realiz_o": "17/9/2022", "los_nombres": "Jose, sandra", "observaciones": "NOREA - AUSENCIA", "cr_num_miembro": 1, "_personas_incompletas": 0}], "identif": "1", "total_h": 1, "visitas": [{"hora": "14.05", "fecha": "09/09/2022", "anotacion": "Deje anuncio"}, {"hora": "12", "fecha": "1709", "anotacion": null}]
   , "$B.F:VIS": "ok", "codNoRea": null, "contacto": "1", "vdominio": 3, "codReaSup": null, "resid_hog": "1", "total_vis": 2, "codNoReaSup": null, "resumenEstado": "ok"} 
*/