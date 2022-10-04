set role ggs2022_owner;
--se agregan estas funciones en la base, para poder generar consistencia en menu consistencias que valide edad contra mes annio.
--las dos primeras funciones vienen de sieh 1.0
CREATE OR REPLACE FUNCTION comun.es_fecha(
    valor text)
    RETURNS integer
    LANGUAGE 'plpgsql'
    IMMUTABLE PARALLEL UNSAFE
AS $BODY$
DECLARE bisiesto boolean;
DECLARE v_fechas_array integer[];
DECLARE v_anio_extraido integer;
DECLARE v_mes_extraido integer;
DECLARE v_dia_extraido integer;
DECLARE v_anio_actual integer;
DECLARE dias_mes integer[12]:= array[31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
BEGIN
  if valor is null then
    return 0;
  end if;  
  v_anio_actual := extract (year from current_date)::integer;
  v_fechas_array := regexp_split_to_array(valor,'/');  
  v_anio_extraido := v_fechas_array[3];
  v_mes_extraido := v_fechas_array[2];
  v_dia_extraido := v_fechas_array[1];
  if v_anio_extraido is null then
    v_anio_extraido := v_anio_actual;
  end if;  
  if v_anio_extraido%4=0 then
    if v_anio_extraido%100=0 then
        if v_anio_extraido%400=0 then
            bisiesto = true;
        else
            bisiesto = false;
        end if;
    else
        bisiesto = true;
    end if;
  else
    bisiesto = false;
  end if;
  if v_anio_extraido is null or v_mes_extraido is null or v_dia_extraido is null then
    return 0;
  end if;
  if v_anio_extraido < 1890 or v_anio_extraido > v_anio_actual then
      return 0;
  end if;
  if v_mes_extraido <= 0 or v_mes_extraido > 12 or v_dia_extraido <=0 then
      return 0;
  end if;
  if v_mes_extraido <> 2 or bisiesto = false then
    if v_dia_extraido>dias_mes[v_mes_extraido] then
        return 0;
    end if;
  else
    if v_dia_extraido>dias_mes[2]+1 then
        return 0;
    end if;
  end if;
  return 1;  
EXCEPTION
  WHEN invalid_text_representation THEN
    return 0;
  WHEN invalid_datetime_format THEN
    return 0;
  WHEN datetime_field_overflow THEN
    return 0;     
END;
$BODY$;

ALTER FUNCTION comun.es_fecha(text)
    OWNER TO ggs2022_owner;
    

-- FUNCTION: comun.completar_fecha(text)

-- DROP FUNCTION IF EXISTS comun.completar_fecha(text);

CREATE OR REPLACE FUNCTION comun.completar_fecha(
    p_fecha text)
    RETURNS text
    LANGUAGE 'plpgsql'
    COST 100
    IMMUTABLE PARALLEL UNSAFE
AS $BODY$
DECLARE
  v_fecha_construida text;
  v_array_fecha text[];
begin
     if(comun.es_fecha(p_fecha)) then
        return p_fecha;
     else
       v_array_fecha:=regexp_split_to_array(p_fecha, '/');
       v_fecha_construida:='15/'||v_array_fecha[array_length(v_array_fecha, 1)-1]||'/'||v_array_fecha[array_length(v_array_fecha, 1)];
       return v_fecha_construida;
     end if;    
end;
$BODY$;

ALTER FUNCTION comun.completar_fecha(text)
    OWNER TO ggs2022_owner;

set role ggs2022_owner;
--drop function base.valida_mesanio_edad(text,text,bigint);
CREATE OR REPLACE FUNCTION base.valida_mesanio_edad(
    p_nacms text,
    p_f_realiz date,
    p_edad bigint)
    RETURNS boolean
    LANGUAGE 'plpgsql'
    IMMUTABLE PARALLEL UNSAFE
AS $BODY$
DECLARE v_edad integer;
        xedad  integer;
        v_nac_comp text;
        esfecha_realiz integer;
        esfecha_mesanio integer;
BEGIN
  v_nac_comp=comun.completar_fecha(p_nacms);
  esfecha_realiz= comun.es_fecha(to_char(p_f_realiz,'DD/MM/YYYY' ));
  esfecha_mesanio= comun.es_fecha(v_nac_comp);
  xedad=p_edad::integer;
  raise notice 'vnaccompl % fecha_realiz % mesanio %', v_nac_comp, esfecha_realiz, esfecha_mesanio ;
  if (esfecha_realiz=1 and esfecha_mesanio=1) then
     v_edad= extract(year from age( p_f_realiz,v_nac_comp::date));
     raise notice 'vedad %', v_edad;
     if v_edad = xedad then
        raise notice 'v_edad % p_edad %', v_edad, xedad ; 
        return true;
     else 
        return false;
     end if;
  else 
     return false;
  end if;
/*  
EXCEPTION
  WHEN invalid_datetime_format THEN
    return null;
  WHEN datetime_field_overflow THEN
    return null;
*/    
END;

$BODY$;

ALTER FUNCTION  base.valida_mesanio_edad(text, date, bigint)
    OWNER TO ggs2022_owner;
--comprobacion   
set search_path=base, comun;
select p.vivienda, p.hogar, p.persona, edad,nacms, f_realiz_o,
      base.valida_mesanio_edad(nacms, f_realiz_o,edad),
      age(f_realiz_o,('15/'||nacms)::date)
   from base.personas p
   inner join base.hogares h on p.vivienda=h.vivienda and p.hogar=h.hogar 
   where nacms is not null 
limit 10;

