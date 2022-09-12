set role to ggs2022_owner;
set search_path = "base";

drop table if exists personas ;
drop table if exists hogares ;
drop table if exists visitas ;
drop table if exists visitas_sup ;
drop table if exists personas_sup ;
drop table if exists hogares_sup ;
drop table if exists viviendas ;


create table "viviendas" (
  "operativo" text, 
  "vivienda" text, 
  "vdominio" bigint, 
  "obs_re" text, 
  "total_vis" bigint, 
  "soporte" bigint, 
  "entreav" bigint, 
  "identif" bigint, 
  "habita" bigint, 
  "construc" bigint, 
  "razon_viv" bigint, 
  "razon2_2" bigint, 
  "razon2_6" bigint, 
  "razon3" text, 
  "resid_hog" bigint, 
  "razon_hog" bigint, 
  "razon2_1" bigint, 
  "razon2_3" bigint, 
  "razon2_5" bigint, 
  "razon_9v" bigint, 
  "contacto" bigint, 
  "v1" bigint, 
  "total_h" bigint, 
  "vdominio_sup" bigint, 
  "s1a1_obs_sup" text, 
  "datos_personal_sup" text, 
  "datos_personal_enc" text, 
  "total_vis_sup" bigint, 
  "soporte_sup" bigint, 
  "modo_sup" bigint, 
  "confir_tel_sup" bigint, 
  "domicilio_sup" text, 
  "confir_dom_sup" bigint, 
  "sp1a" bigint, 
  "habita_sup" bigint, 
  "construccion_sup" bigint, 
  "razon_viv_sup" bigint, 
  "razon_2_sup" bigint, 
  "razon2_6_sup" bigint, 
  "razon3_sup" text, 
  "sp1b" bigint, 
  "razon_hog_sup" bigint, 
  "razon_1_sup" bigint, 
  "razon2_3_sup" bigint, 
  "razon2_5_sup" bigint, 
  "razon_9v_sup" bigint, 
  "sp1c" bigint, 
  "sp3_sup" bigint, 
  "total_h_sup" bigint, 
  "consistido" timestamp
, primary key ("operativo", "vivienda")
);
grant select, insert, update, delete, references on "viviendas" to ggs2022_admin;
grant all on "viviendas" to ggs2022_owner;



create table "visitas" (
  "operativo" text, 
  "vivienda" text, 
  "visita" bigint, 
  "anoenc" bigint, 
  "rol" text, 
  "per" bigint, 
  "usu" text, 
  "fecha" text, 
  "hora" text, 
  "anotacion" text
, primary key ("operativo", "vivienda", "visita")
);
grant select, insert, update, delete, references on "visitas" to ggs2022_admin;
grant all on "visitas" to ggs2022_owner;



create table "hogares" (
  "operativo" text, 
  "vivienda" text, 
  "hogar" bigint, 
  "observaciones" text, 
  "gg1" bigint, 
  "entrea" bigint, 
  "f_realiz_o" date, 
  "fijo" text, 
  "los_nombres" text, 
  "total_m" bigint, 
  "nombrer" text, 
  "sorteo" bigint, 
  "tp" bigint, 
  "cr_num_miembro" bigint, 
  "msnombre" text, 
  "cr_num_miembro_ing" bigint, 
  "razon1" bigint, 
  "razon2_7" bigint, 
  "razon2_8" bigint, 
  "razon2_9" bigint
, primary key ("operativo", "vivienda", "hogar")
);
grant select, insert, update, delete, references on "hogares" to ggs2022_admin;
grant all on "hogares" to ggs2022_owner;



create table "personas" (
  "operativo" text, 
  "vivienda" text, 
  "hogar" bigint, 
  "persona" bigint, 
  "nombre" text, 
  "sexo" bigint, 
  "edad" bigint, 
  "p4" bigint, 
  "lp" bigint, 
  "l0" text, 
  "p5" bigint, 
  "p5b" bigint, 
  "p6a" bigint, 
  "p6b" bigint, 
  "p722" bigint, 
  "p825" bigint, 
  "msi" bigint, 
  "msnombrei" text, 
  "msedadi" bigint, 
  "entreaind" bigint, 
  "movili" text, 
  "correoi" text, 
  "fecha_cita" text, 
  "hora_cita" text, 
  "resulcita" bigint, 
  "reams" bigint, 
  "telms" text, 
  "correoms" text, 
  "nacms" text, 
  "id_blaise" text, 
  "id_blaise_parseado" text, 
  "fin_1" bigint, 
  "fin_2" bigint, 
  "escif" text, 
  "fin_3" bigint
, primary key ("operativo", "vivienda", "hogar", "persona")
);
grant select, insert, update, delete, references on "personas" to ggs2022_admin;
grant all on "personas" to ggs2022_owner;



create table "visitas_sup" (
  "operativo" text, 
  "vivienda" text, 
  "visita" bigint, 
  "anoenc_sup" bigint, 
  "rol_sup" text, 
  "per_sup" bigint, 
  "usu_sup" text, 
  "fecha_sup" text, 
  "hora_sup" text, 
  "anotacion_sup" text
, primary key ("operativo", "vivienda", "visita")
);
grant select, insert, update, delete, references on "visitas_sup" to ggs2022_admin;
grant all on "visitas_sup" to ggs2022_owner;



create table "hogares_sup" (
  "operativo" text, 
  "vivienda" text, 
  "hogar" bigint, 
  "obs_hogar_sup" text, 
  "resp_comp_sup" text, 
  "resp_comp_ed_sup" bigint, 
  "resp_indi_sup" text, 
  "resp_indi_ed_sup" bigint, 
  "spr1_sup" bigint, 
  "entrea_sup" bigint, 
  "sp4" bigint, 
  "sp5_sup" text, 
  "spr2_sup" bigint, 
  "fecha_realiz_sup" date, 
  "nombres_componentes_sup" text, 
  "total_m_sup" bigint, 
  "sorteo_sup" bigint, 
  "total_rango_sup" bigint, 
  "nro_miembro_sel_sup" bigint, 
  "nombre_miembro_sel_sup" text, 
  "nro_mie_sel_ing_sup" bigint, 
  "spr3_sup" bigint, 
  "razon1_sup" bigint, 
  "razon_7_1h_sup" bigint, 
  "razon_8_1_sup" bigint, 
  "razon_9_1h_sup" bigint
, primary key ("operativo", "vivienda", "hogar")
);
grant select, insert, update, delete, references on "hogares_sup" to ggs2022_admin;
grant all on "hogares_sup" to ggs2022_owner;



create table "personas_sup" (
  "operativo" text, 
  "vivienda" text, 
  "hogar" bigint, 
  "persona" bigint, 
  "nombre_sup" text, 
  "sexo_sup" bigint, 
  "edad_sup" bigint, 
  "sp4_sup" bigint, 
  "spl0_sup" text, 
  "spp5" bigint
, primary key ("operativo", "vivienda", "hogar", "persona")
);
grant select, insert, update, delete, references on "personas_sup" to ggs2022_admin;
grant all on "personas_sup" to ggs2022_owner;

-- conss
alter table "viviendas" add constraint "operativo<>''" check ("operativo"<>'');
alter table "viviendas" alter column "operativo" set not null;
alter table "viviendas" add constraint "vivienda<>''" check ("vivienda"<>'');
alter table "viviendas" alter column "vivienda" set not null;
alter table "viviendas" add constraint "obs_re<>''" check ("obs_re"<>'');
alter table "viviendas" add constraint "razon3<>''" check ("razon3"<>'');
alter table "viviendas" add constraint "s1a1_obs_sup<>''" check ("s1a1_obs_sup"<>'');
alter table "viviendas" add constraint "datos_personal_sup<>''" check ("datos_personal_sup"<>'');
alter table "viviendas" add constraint "datos_personal_enc<>''" check ("datos_personal_enc"<>'');
alter table "viviendas" add constraint "domicilio_sup<>''" check ("domicilio_sup"<>'');
alter table "viviendas" add constraint "razon3_sup<>''" check ("razon3_sup"<>'');
alter table "visitas" add constraint "operativo<>''" check ("operativo"<>'');
alter table "visitas" alter column "operativo" set not null;
alter table "visitas" add constraint "vivienda<>''" check ("vivienda"<>'');
alter table "visitas" alter column "vivienda" set not null;
alter table "visitas" alter column "visita" set not null;
alter table "visitas" add constraint "rol<>''" check ("rol"<>'');
alter table "visitas" add constraint "usu<>''" check ("usu"<>'');
alter table "visitas" add constraint "fecha<>''" check ("fecha"<>'');
alter table "visitas" add constraint "hora<>''" check ("hora"<>'');
alter table "visitas" add constraint "anotacion<>''" check ("anotacion"<>'');
alter table "hogares" add constraint "operativo<>''" check ("operativo"<>'');
alter table "hogares" alter column "operativo" set not null;
alter table "hogares" add constraint "vivienda<>''" check ("vivienda"<>'');
alter table "hogares" alter column "vivienda" set not null;
alter table "hogares" alter column "hogar" set not null;
alter table "hogares" add constraint "observaciones<>''" check ("observaciones"<>'');
alter table "hogares" add constraint "fijo<>''" check ("fijo"<>'');
alter table "hogares" add constraint "los_nombres<>''" check ("los_nombres"<>'');
alter table "hogares" add constraint "nombrer<>''" check ("nombrer"<>'');
alter table "hogares" add constraint "msnombre<>''" check ("msnombre"<>'');
alter table "personas" add constraint "operativo<>''" check ("operativo"<>'');
alter table "personas" alter column "operativo" set not null;
alter table "personas" add constraint "vivienda<>''" check ("vivienda"<>'');
alter table "personas" alter column "vivienda" set not null;
alter table "personas" alter column "hogar" set not null;
alter table "personas" alter column "persona" set not null;
alter table "personas" add constraint "nombre<>''" check ("nombre"<>'');
alter table "personas" add constraint "l0<>''" check ("l0"<>'');
alter table "personas" add constraint "msnombrei<>''" check ("msnombrei"<>'');
alter table "personas" add constraint "movili<>''" check ("movili"<>'');
alter table "personas" add constraint "correoi<>''" check ("correoi"<>'');
alter table "personas" add constraint "telms<>''" check ("telms"<>'');
alter table "personas" add constraint "correoms<>''" check ("correoms"<>'');
alter table "personas" add constraint "id_blaise<>''" check ("id_blaise"<>'');
alter table "personas" add constraint "id_blaise_parseado<>''" check ("id_blaise_parseado"<>'');
alter table "personas" add constraint "escif<>''" check ("escif"<>'');
alter table "personas" add constraint "nacms<>''" check ("nacms"<>'');
alter table "personas" add constraint "fecha_cita<>''" check ("fecha_cita"<>'');
alter table "personas" add constraint "hora_cita<>''" check ("hora_cita"<>'');

alter table "visitas_sup" add constraint "operativo<>''" check ("operativo"<>'');
alter table "visitas_sup" alter column "operativo" set not null;
alter table "visitas_sup" add constraint "vivienda<>''" check ("vivienda"<>'');
alter table "visitas_sup" alter column "vivienda" set not null;
alter table "visitas_sup" alter column "visita" set not null;
alter table "visitas_sup" add constraint "rol_sup<>''" check ("rol_sup"<>'');
alter table "visitas_sup" add constraint "usu_sup<>''" check ("usu_sup"<>'');
alter table "visitas_sup" add constraint "fecha_sup<>''" check ("fecha_sup"<>'');
alter table "visitas_sup" add constraint "hora_sup<>''" check ("hora_sup"<>'');
alter table "visitas_sup" add constraint "anotacion_sup<>''" check ("anotacion_sup"<>'');
alter table "hogares_sup" add constraint "operativo<>''" check ("operativo"<>'');
alter table "hogares_sup" alter column "operativo" set not null;
alter table "hogares_sup" add constraint "vivienda<>''" check ("vivienda"<>'');
alter table "hogares_sup" alter column "vivienda" set not null;
alter table "hogares_sup" alter column "hogar" set not null;
alter table "hogares_sup" add constraint "obs_hogar_sup<>''" check ("obs_hogar_sup"<>'');
alter table "hogares_sup" add constraint "resp_comp_sup<>''" check ("resp_comp_sup"<>'');
alter table "hogares_sup" add constraint "resp_indi_sup<>''" check ("resp_indi_sup"<>'');
alter table "hogares_sup" add constraint "sp5_sup<>''" check ("sp5_sup"<>'');
alter table "hogares_sup" add constraint "nombres_componentes_sup<>''" check ("nombres_componentes_sup"<>'');
alter table "hogares_sup" add constraint "nombre_miembro_sel_sup<>''" check ("nombre_miembro_sel_sup"<>'');
alter table "personas_sup" add constraint "operativo<>''" check ("operativo"<>'');
alter table "personas_sup" alter column "operativo" set not null;
alter table "personas_sup" add constraint "vivienda<>''" check ("vivienda"<>'');
alter table "personas_sup" alter column "vivienda" set not null;
alter table "personas_sup" alter column "hogar" set not null;
alter table "personas_sup" alter column "persona" set not null;
alter table "personas_sup" add constraint "nombre_sup<>''" check ("nombre_sup"<>'');
alter table "personas_sup" add constraint "spl0_sup<>''" check ("spl0_sup"<>'');

-- index
create index "operativo,vivienda 4 visitas IDX" ON "visitas" ("operativo", "vivienda");
create index "operativo,vivienda 4 hogares IDX" ON "hogares" ("operativo", "vivienda");
create index "operativo,vivienda,hogar 4 personas IDX" ON "personas" ("operativo", "vivienda", "hogar");
create index "operativo,vivienda 4 visitas_sup IDX" ON "visitas_sup" ("operativo", "vivienda");
create index "operativo,vivienda 4 hogares_sup IDX" ON "hogares_sup" ("operativo", "vivienda");
create index "operativo,vivienda,hogar 4 personas_sup IDX" ON "personas_sup" ("operativo", "vivienda", "hogar");

--fks
alter table "visitas" add constraint "visitas viviendas REL" foreign key ("operativo", "vivienda") references "viviendas" ("operativo", "vivienda")  on update cascade;
alter table "hogares" add constraint "hogares viviendas REL" foreign key ("operativo", "vivienda") references "viviendas" ("operativo", "vivienda")  on update cascade;
alter table "personas" add constraint "personas hogares REL" foreign key ("operativo", "vivienda", "hogar") references "hogares" ("operativo", "vivienda", "hogar")  on update cascade;
alter table "visitas_sup" add constraint "visitas_sup viviendas REL" foreign key ("operativo", "vivienda") references "viviendas" ("operativo", "vivienda")  on update cascade;
alter table "hogares_sup" add constraint "hogares_sup viviendas REL" foreign key ("operativo", "vivienda") references "viviendas" ("operativo", "vivienda")  on update cascade;
alter table "personas_sup" add constraint "personas_sup hogares_sup REL" foreign key ("operativo", "vivienda", "hogar") references "hogares_sup" ("operativo", "vivienda", "hogar")  on update cascade;

do $SQL_ENANCE$
 begin
PERFORM enance_table('viviendas','operativo,vivienda');
PERFORM enance_table('visitas','operativo,vivienda,visita');
PERFORM enance_table('hogares','operativo,vivienda,hogar');
PERFORM enance_table('personas','operativo,vivienda,hogar,persona');
PERFORM enance_table('visitas_sup','operativo,vivienda,visita');
PERFORM enance_table('hogares_sup','operativo,vivienda,hogar');
PERFORM enance_table('personas_sup','operativo,vivienda,hogar,persona');
end
$SQL_ENANCE$;