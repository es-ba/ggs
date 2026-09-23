set role ggs2026_muleto_owner; --cambiar por el owner del entorno correspondiente
set search_path=base;

-- (Opcional) Si la columna seleccionado_ant en tem todavía es de tipo text, podés migrarla con:
-- alter table base.tem alter column seleccionado_ant type jsonb using seleccionado_ant::jsonb;

--areas
   insert into base.areas(operativo, area)
     select distinct 'GGS_2026' as operativo, area from operaciones.ui260821_ggs2026_variables_para_muestra
        order by area;
--INSERT 0 356    

--para PRODUCCION--
  insert into tem(
    operativo, enc, area,
    enc_ant, area_ant,
    seleccionado_ant, 
    zona, codcalle, nomcalle, nrocatastral, piso, departamento, habitacion, sector, edificio, entrada, barrio,
    areaup, codpos, dominio, estrato_ing, id_marco, obs,
    nrocomuna, nrofraccion, nroradio, nromanzana, nrolado, usodomicilio, participacion, 
    casa, 
    obsconjunto, 
    semana, 
    habilitada
    )
   select 'GGS_2026' operativo, (id_enc::text||hogar::text) as enc, area,
       id_enc as enc_ant, area as area_ant,
       
       -- Inserción directa como objeto JSONB nativo
       jsonb_build_object(
          'sel', persona,
          'nombre', nombre,
          'sexo', sexo,
          'anio nacimiento', anio_nacimiento,
          'telms', CASE WHEN lower(telms) IN ('-9', '0','//','ns/nc','n/c','') THEN NULL ELSE telms END, 
          'movil', CASE WHEN lower(movil) IN ('-9', '0','//','ns/nc','n/c','') THEN NULL ELSE movil END, 
          'email', CASE WHEN lower(correoms) IN ('-9', '0','//','ns/nc','n/c','') THEN NULL ELSE correoms END
      ) as seleccionado_ant,

       zona, codcalle, nomcalle, nrocatastral, hp as piso, hd as departamento, hab as habitacion, sector, edificio, entrada, barrio,
       areaup, codpos, dominio, estratoing as estrato_ing, idmarco as id_marco, obsconjunto as obs, 
       comuna as nrocomuna, nrofraccion, nroradio, nromanzana, 
       lado nrolado, usodomiciliario usodomicilio, 2 participacion, 
       null casa,  
       obsconjunto, 
       null semana, 
       true as habilitada
      from operaciones.ui260821_ggs2026_variables_para_muestra
    order by area, enc;
--INSERT 0 2268

---para TEST y CAPA (Anonimización nativa sobre JSONB)
update base.tem 
  set nomcalle = regexp_replace(nomcalle,'[a-zA-Z0-9]','X','g');

update base.tem 
  set obs = regexp_replace(obs,'[a-zA-Z0-9]','X','g');    

update base.tem 
  set obsdatosdomicilio = regexp_replace(obsdatosdomicilio,'[a-zA-Z0-9]','X','g');    

-- Sobrescribe las claves directamente sobre el JSONB nativo
update base.tem 
  set seleccionado_ant = seleccionado_ant || jsonb_build_object(
      'telms', '9999999999', 
      'movil', '9999999999', 
      'anio nacimiento','XXXX',
      'nombre', 'NOMBRE FALSO',
      'email', 'mailfalso@dominio.com'
  )
  where seleccionado_ant is not null;

--- BORRADO DE MUESTRA ORDEN DE TABLAS
/*
delete from tareas_areas;
delete from tareas_tem;
delete from tem_blaise;
delete from tem;
*/

-- Ejecutar el script carga_inicial_tareas_tem.sql (se encuentra en Dmencu/install) - para cargar tareas_tem y tareas_areas. 
/* controles básicos */
select count(*) from base.tem; --2268
select count(*) from base.tareas_tem; --13608 


/* ejemplo básico  de generación de un idblaise 
select operativo, enc, 'TEST'||(1130+(row_number() OVER () -1) )::text id_blaise
  from base.tem
 order by enc;
*/ 