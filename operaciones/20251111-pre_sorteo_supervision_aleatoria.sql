--cálculo de pre_sorteo para supervisión aleatoria
--poner el rol que corresponda según el entorno en cual estamos corriendo este script
set role ggs2026_owner;
set search_path=base;

select count(*) from tem 
  where operativo='GGS_2026'; 

--pre-sorteo presenciales
--no va a haber en este operativo 
/*
with a as(
select enc,random() vrandom
  from tem
  where dominio=3 and operativo='GGS_2026' 
order by enc
    )
update tem  t set pre_sorteo=b.pre_sorteo
 from (
  select enc, case when vrandom <=0.1 then 1 else 0 end as pre_sorteo --asi quedan aprox el 10% de elegidas (con valor 1 para candidatas a presenciales)
    from a
    ) b
where t.enc=b.enc and t.operativo='GGS_2026';
*/
--pre-sorteo telefonico
--hacemos presorteo inicial de 30% como colchon para obtener el 10% de efectivas

with a as(
select enc,random() vrandom
  from tem
  where operativo='GGS_2026' and coalesce(pre_sorteo,0)=0
order by enc
    )
update tem  t set pre_sorteo=b.pre_sorteo
 from (
  select enc, case when vrandom <=0.30 then 2 else 0 end as pre_sorteo --asi quedan aprox el 30% de elegidas (con valor 2 para candidatas a telefónicas)
    from a
    ) b
where t.enc=b.enc and t.operativo='GGS_2026';

/* comprobación 
select count(*) filter (where pre_sorteo=2)*1.0/count(*)*100  from tem;

select pre_sorteo,count(*)
  from tem
  --where dominio=3
  group by 1
  order by pre_sorteo;
  --las que tienen valor 2  --aprox ...
  --son las elegidas para supervision aleatoria telefónica
 
*/
