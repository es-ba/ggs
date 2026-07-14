--borrar rama de casilleros 
--parametros: p_ope, p_id_casillero
set search_path= base;
with recursive subcasilleros(operativo, id_casillero) as (
        select operativo, id_casillero, 0::bigint as depth
               FROM casilleros where operativo= 'GGS_2026' and id_casillero='S1_SUP' --and not es_activo
        union all
            select c.operativo, c.id_Casillero, s.depth+1
                from subcasilleros s inner join casilleros c 
                    on s.operativo = c.operativo and s.id_casillero = c.padre
    ), x AS (select  s.*, cr.*
        from subcasilleros s, lateral casilleros_recursivo(operativo, id_casillero) cr
        where s.operativo='GGS_2026' --and s.depth>0 
        order by s.depth desc, orden_total desc
    )--,borrando as (
        delete from casilleros c using  x where x.operativo=c.operativo and x.id_casillero=c.id_casillero
