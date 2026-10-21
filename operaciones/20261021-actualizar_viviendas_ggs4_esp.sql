set search_path=base;
set role ggs2026_owner; -- adecuar al entorno

alter table viviendas 
    alter column  ggs4_esp type text,

alter table viviendas 
  add constraint "ggs4_esp <>''"    check ("ggs4_esp" <>'');

update variables
  set tipovar='texto'
  where operativo='GGS2026' AND tabla_datos='viviendas' AND variable='ggs4_esp' ;  
