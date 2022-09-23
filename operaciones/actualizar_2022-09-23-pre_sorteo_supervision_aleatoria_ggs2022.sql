--poner el rol que corresponda
set role ggs2022_owner;
set search_path=base;

--alter table tem add column pre_sorteo integer;
--alter table tareas_tem add column supervision_dirigida integer;
--alter table tem add column supervision_aleatoria integer;
--alter table tem add column supervision integer; --se activa con el valor de pre_sorteo si se dan las condiciones
select count(*) from tem where dominio=3 and operativo='GGS_2022'; --6000
with a as(
select enc,random() vrandom
  from tem
  where dominio=3 and operativo='GGS_2022'
order by enc
    )
update tem  t set pre_sorteo=b.pre_sorteo
 from (
  select enc, case when vrandom <=0.1 then 1 else 0 end as pre_sorteo --asi da el 10% de elegidas (con valor 1)
    from a
    ) b
where t.enc=b.enc and t.operativo='GGS_2022';

/*
select pre_sorteo,count(*)
  from tem
  group by 1
  order by pre_sorteo;
  0 5376
  1 624 -- son las elegidas para supervision aleatoria 
  null 240
  
*/
--van a ser supervisiones presenciales  las seleccionadas no encuestables
/* comprobacion
select a.enc, a.supervision_aleatoria, a.norea, a.pre_sorteo
from tem a,
( select distinct  t.enc, t.rea, no_rea, pre_sorteo
        from base.tem t
        inner join base.no_rea r  on norea::text=no_rea
        inner join base.tareas_tem tt on t.enc=tt.enc
      where t.rea=2  and r.grupo0 in ('no encuestable')  --no_encuestable van a supervision presencial
         and tt.supervision_dirigida is null and t.supervision_aleatoria is null
         and pre_sorteo=1 
     order by t.enc
   )x
where operativo='GGS_2022'  and a.enc=x.enc and a.dominio=3 and a.pre_sorteo=1 ;
*/
update tem a set supervision_aleatoria=1 
  from 
  ( select distinct  t.enc, t.rea, no_rea, pre_sorteo
        from base.tem t
        inner join base.no_rea r  on norea::text=no_rea
        inner join base.tareas_tem tt on t.enc=tt.enc
      where t.rea=2  and r.grupo0 in ('no encuestable')  --no_encuestable van a supervision presencial
         and tt.supervision_dirigida is null and t.supervision_aleatoria is null
         and pre_sorteo=1 
     order by t.enc
   )x
where operativo='GGS_2022'  and a.enc=x.enc and a.dominio=3 and a.pre_sorteo=1 ;

--19 casos
--van a ser supervisiones telefonicas las seleccionadas rea que tengan telefono
set search_path=base;
with c as(
select tt.enc,h.hogar,tt.rea,tt.norea,tt.fin_campo,tt.cant_h,
      concat_ws('x', fijo, ' ',movili, ' ',telms) telefono         
  from tem tt
  left join hogares h on tt.enc=h.vivienda 
  left join personas p on h.vivienda=p.vivienda and h.hogar=p.hogar 
  where dominio=3 and h.operativo='GGS_2022'  and tt.rea=1 and pre_sorteo=1
     and  h.cr_num_miembro=p.persona 
  order by tt.enc,h.hogar  ),
d as(
select   t.enc,
    case when (concat_ws('x', string_agg('h'||h.hogar||' '||telefono ,',' order by h.vivienda))) ilike '%No tiene%'  then 'st' else 'ct' end as telefono
  from tem t  
  inner join tareas_tem tt on t.enc=tt.enc
  inner join c on t.enc=c.enc
  inner join hogares h on h.vivienda=c.enc and h.hogar=c.hogar  
  where supervision_dirigida is null and supervision_aleatoria is null
  group by 1,c.hogar
  order by 1
 ) 
/*--comprobación antes de correr update 
 select x.enc, x.supaleat ,t.rea
 from tem t,  (
   select enc, case  when telefono='ct' then 2 else 1 end as supaleat
      from d 
   )x   
  where operativo='GGS_2022'  and t.enc=x.enc and t.dominio=3 and t.pre_sorteo=1 and t.supervision_aleatoria is null;
*/
 
 update tem t set supervision_aleatoria=supaleat
 from (
   select enc, case  when telefono='ct' then 2 else 1 end as supaleat
      from d 
   )x   
  where operativo='GGS_2022'  and t.enc=x.enc and t.dominio=3 and t.pre_sorteo=1 and t.supervision_aleatoria is null;
 --26 filas 
 
  select distinct t.enc,t.rea, t.norea, supervision_aleatoria,tt.supervision_dirigida, t.pre_sorteo
   from tem t
   inner join tareas_tem tt on t.enc=tt.enc
   where pre_sorteo=1 and  supervision_aleatoria is not null;
 --45 casos
