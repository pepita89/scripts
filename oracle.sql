create or replace PACKAGE PRUEBASRRHH AS 
 TYPE vcursor IS REF CURSOR;
  procedure TITULOS(
    p_cod_situacion in varchar2 DEFAULT NULL,
    p_cod_categoria in VARCHAR2 DEFAULT NULL,
    p_cod_concepto in NUMERIC DEFAULT NULL,
    p_cod_subconcepto in NUMERIC DEFAULT NULL,
    p_cod_nivel in numeric default null,
    p_dsSituacion in NVARCHAR2 DEFAULT NULL, 
    p_dsTotales in VARCHAR2 DEFAULT NULL,
    titulocursor OUT vcursor
);
procedure NOMINA_FILTROS(
    p_cod_convenio in varchar2 DEFAULT NULL,
    p_cod_situacion in varchar2 DEFAULT NULL,
    p_cod_categoria in VARCHAR2 DEFAULT NULL,
    p_cod_concepto in NUMERIC DEFAULT NULL,
    p_cod_subconcepto in NUMERIC DEFAULT NULL,
    p_cod_nivel in numeric default null,
    p_periodo in int DEFAULT null,
    p_dependencia in varchar2 DEFAULT NULL,
    p_dsSituacion in NVARCHAR2 DEFAULT NULL,
    infocursor OUT vcursor,
    vusercursor OUT vcursor
);
procedure NOMINA_TOTALES(
    p_periodo in int DEFAULT null,
    p_dependencia in varchar2 DEFAULT NULL,
    p_dsTotales in VARCHAR2 DEFAULT NULL,
    infocursor OUT vcursor,
    vusercursor OUT vcursor
);

END PRUEBASRRHH;
--------------------------
cuerpo
create or replace PACKAGE BODY PRUEBASRRHH AS
 PROCEDURE TITULOS (
    p_cod_situacion in varchar2 DEFAULT NULL,
    p_cod_categoria in VARCHAR2 DEFAULT NULL,
    p_cod_concepto in NUMERIC DEFAULT NULL,
    p_cod_subconcepto in NUMERIC DEFAULT NULL,
    p_cod_nivel in numeric default null,
    p_dsSituacion in NVARCHAR2 DEFAULT NULL, 
    p_dsTotales in VARCHAR2 DEFAULT NULL,
   titulocursor OUT vcursor
)
  AS
    var_tituloS varchar2(200);
    var_tituloSA varchar2(200);
    var_tituloE varchar2(200);
    var_tituloC varchar2(200);
    var_titulo varchar2(200);
    p_titulo varchar2(200);
   BEGIN
if(p_dsTotales is null)then
   SELECT CASE 
        WHEN  p_cod_situacion IS NOT NULL THEN 'SITUACION'  
        WHEN  p_cod_categoria IS NOT NULL THEN 'CATEGORIA'
        WHEN  p_cod_concepto IS NOT NULL THEN 'SIN ADICIONAL'
        WHEN p_cod_nivel IS NOT NULL THEN 'ESTUDIO'
  END INTO p_titulo
  FROM DUAL;
   SELECT CASE WHEN p_titulo = 'ESTUDIO'THEN
        decode((select NIVEL_ESTUDIO from apprrhh.dotacion_actual where COD_NIVEL_ESTUDIO= p_cod_nivel group by COD_NIVEL_ESTUDIO,NIVEL_ESTUDIO),null,'', 
        'POR NIVEL DE ESTUDIO: ' || (select NIVEL_ESTUDIO from apprrhh.dotacion_actual where COD_NIVEL_ESTUDIO= p_cod_nivel group by p_cod_nivel,NIVEL_ESTUDIO)) 
   END  INTO var_tituloE from dual;
   SELECT 
     CASE WHEN p_titulo ='SIN ADICIONAL' then 
     decode((select    NVL( s.DESCRIPCION, '(SIN ADICIONAL)')  ADICIONAL from apprrhh.dotacion_actual A
                               LEFT JOIN SARHA.SUBCONCEPTO  s ON A.COD_CONCEPTO=S.COD_CONCEPTO AND S.COD_SUBCONCEPTO=a.COD_SUBCONCEPTO
                               where A.COD_SUBCONCEPTO= p_cod_subconcepto
                                      AND A.cod_concepto= p_cod_concepto
                                group by A.cod_concepto,A.COD_SUBCONCEPTO,S.DESCRIPCION),null,'','POR ADICIONAL: ' 
                               || (select    NVL( s.DESCRIPCION, '(SIN ADICIONAL)')  ADICIONAL from apprrhh.dotacion_actual A
                                       LEFT JOIN SARHA.SUBCONCEPTO  s ON A.COD_CONCEPTO=S.COD_CONCEPTO AND S.COD_SUBCONCEPTO=a.COD_SUBCONCEPTO
                                       where A.COD_SUBCONCEPTO= p_cod_subconcepto
                                              AND A.cod_concepto= p_cod_concepto
                                        group by A.cod_concepto,A.COD_SUBCONCEPTO,S.DESCRIPCION) )   
   end
   into var_tituloSA
        from dual;
   SELECT 
         CASE WHEN p_titulo = 'SITUACION' THEN 
       (select SITUACION from apprrhh.dotacion_actual where cod_tipo_ausencia= p_cod_situacion  and SITUACION LIKE p_dsSituacion   group by cod_tipo_ausencia,SITUACION)
       END 
      into var_tituloS 
        from dual;   
   SELECT CASE WHEN p_titulo='CATEGORIA' THEN 
         decode((select rtrim(ltrim(nivel)) from apprrhh.dotacion_actual 
             where rtrim(ltrim(nivel))= p_cod_categoria group by rtrim(ltrim(nivel))),null,'','POR SITUACION: ' || (select rtrim(ltrim(nivel)) from apprrhh.dotacion_actual where rtrim(ltrim(nivel))= p_cod_categoria   group by rtrim(ltrim(nivel))) ) 
    END  INTO var_tituloC from dual;
   select
       case when var_tituloS is not null then 
       var_tituloS
       when  var_tituloSA is not null then 
       var_tituloSA
       when   var_tituloE is not null then 
       var_tituloE
       when var_tituloC is not null then 
       var_tituloC
       end 
       into var_titulo  from dual;   
       
   end if;    
       
if(p_dsTotales is not  null)then

 SELECT CASE 
        WHEN  p_dsTotales ='SITUACION' THEN 'SITUACION'  
        WHEN  p_dsTotales ='CATEGORIA'  THEN 'CATEGORIA'
        WHEN  p_dsTotales = 'SIN ADICIONAL' THEN 'SIN ADICIONAL'
        WHEN  p_dsTotales ='ESTUDIO'   THEN 'ESTUDIO'
  END INTO p_titulo
  FROM DUAL;
  
  
  
   SELECT CASE WHEN p_titulo = 'ESTUDIO'THEN
        'POR NIVEL DE ESTUDIO: ' 
   END  INTO var_tituloE from dual;
 
 
   SELECT CASE WHEN p_titulo ='SIN ADICIONAL' then 
          '(SIN ADICIONAL)'
          END
        into var_tituloSA  from dual;
        
        
   SELECT CASE WHEN p_titulo = 'SITUACION' THEN 
       'SITUACIONES'
       END
      into var_tituloS  from dual;   
   SELECT CASE WHEN p_titulo='CATEGORIA' THEN 
         'CATEGORIAS'
    END 
    
    INTO var_tituloC from dual;
   select
       case when var_tituloS is not null then 
       var_tituloS
       when  var_tituloSA is not null then 
       var_tituloSA
       when   var_tituloE is not null then 
       var_tituloE
       when var_tituloC is not null then 
       var_tituloC
       end 
       into var_titulo  from dual;       
   
end if;
   open titulocursor for
   SELECT 
    var_titulo TITULO  from dual;
   END TITULOS;

 procedure NOMINA_FILTROS(
    p_cod_convenio in varchar2 DEFAULT NULL,
    p_cod_situacion in varchar2 DEFAULT NULL,
    p_cod_categoria in VARCHAR2 DEFAULT NULL,
    p_cod_concepto in NUMERIC DEFAULT NULL,
    p_cod_subconcepto in NUMERIC DEFAULT NULL,
    p_cod_nivel in numeric default null,
    p_periodo in int DEFAULT null,
    p_dependencia in varchar2 DEFAULT NULL,
    p_dsSituacion in NVARCHAR2 DEFAULT NULL,
    infocursor OUT vcursor,
    vusercursor OUT vcursor
) AS
 var_SITUACION_REVISTA varchar2(200);
 var_cod int;
 var_totales varchar2(20);
 var_titulo varchar2(200);
 resultset apprrhh.PRUEBASRRHH.vcursor;
 BEGIN
  PRUEBASRRHH.TITULOS(p_cod_situacion,p_cod_categoria,p_cod_concepto,p_cod_subconcepto,p_cod_nivel,p_dsSituacion,var_totales,resultset);
  FETCH resultset INTO var_titulo;  
  SELECT nvl(REGEXP_SUBSTR(p_cod_convenio,'[^-]+',1,2),'Sin R') sr , null cod_convenio 
   into var_SITUACION_REVISTA, var_cod 
  FROM dual;
 OPEN      infocursor   FOR
  SELECT 
    'REPORTE - NOMINA ' 

     || 'DEPENDECIA : ' || nvl((SELECT DESCRIPCION FROM SARHA.ESTRUCTURA_REAL WHERE COD_ESTRUCTURA_REAL=p_dependencia),'TODAS ')
        || case 
       WHEN (var_SITUACION_REVISTA = 'Sin R') THEN
         decode((select convenio from apprrhh.dotacion_actual where cod_convenio=p_cod_convenio group by cod_convenio,convenio),null,'','POR CONVENIO: ' || (select convenio from apprrhh.dotacion_actual where cod_convenio=p_cod_convenio group by cod_convenio,convenio) )
          ELSE 
            decode((select convenio from apprrhh.dotacion_actual where cod_convenio=SUBSTR(p_cod_convenio,0,1) group by cod_convenio,convenio),null,'','POR CONVENIO: ' || (select convenio from apprrhh.dotacion_actual where cod_convenio=SUBSTR(p_cod_convenio,0,1)  group by cod_convenio,convenio) )  ||' ' || SUBSTR(p_cod_convenio,2)
          END   
        ||var_titulo 
        ||' '|| DECODE(p_periodo ,NULL,'DEL PERIODO ACTUAL','DEL PERIODO: '|| p_periodo)
        AS "T�TULO"  FROM dual;

 

IF(var_SITUACION_REVISTA = 'Sin R')THEN
   
    OPEN      vusercursor   FOR 
             select        
                CUIL,          
                NOMBRE,
                APELLIDO,
              
                LUE,
                ESTADO_REGISTRO,
                USUARIO_GDE,
                CON_USUARIO_GDE,
                GENERO,
                TO_CHAR(FECHA_NACIMIENTO,'DD/MM/RRRR') FECHA_NACIMIENTO,
                EDAD,
                TO_CHAR(INGRESO,'DD/MM/RRRR') INGRESO,
                ANTIGUEDAD,
                JURISDICCION_MINISTERIO,
                DEPENDENCIA_SECRETARIA,
                DEPENDENCIA_SECRETARIA_2,
                DIRECCION_GENERAL,
                DEPARTAMENTO_DIVISION,
                ESTRUCTURA_LIQ,
                FUNCION,
                DOMICILIO_LABORAL,
                SITUACION_REVISTA,
                CONVENIO,
                AGRUPAMIENTO,
                ESCALAFON,
                BRUTO_ESCALAFON,
                NIVEL,
                GRADO,
                TRAMO,
                FUNCION_EJECUTIVA,
                SUPLEMENTO_FUNCION_EJECUTIVA,
                CANT_HS_SIMPLES,
                HS_SIMPLES,
                CANT_HS_50,
                HS_50,
                CANT_HS_100,
                HS_100,
                HS_EXTRAS,
                CANT_COMIDAS,
                COMIDAS,
                CANT_UR,
                UR,
                MOVILIDAD,
                BONIFICACIONES,
                GUARDERIA,
                INTERESES,
                PREMIO_PRESENTISMO,
                TOTAL_BRUTO,
                DESCUENTOS,
                NETO,
                NO_REMUNERATIVO_PASANTE,
                CONTRIB,
                SITUACION,
                COD_TIPO_AUSENCIA,
                NIVEL_ESTUDIO,
                TITULO,
                NVL( s.DESCRIPCION, '(SIN ADICIONAL)')  ADICIONAL,
                BAJA
 from apprrhh.dotacion_actual A
 LEFT JOIN SARHA.SUBCONCEPTO  s ON A.COD_CONCEPTO=S.COD_CONCEPTO AND S.COD_SUBCONCEPTO=a.COD_SUBCONCEPTO
      where (cod_convenio = p_cod_convenio  or p_cod_convenio is null)
      and  (cod_tipo_ausencia = p_cod_situacion  or p_cod_situacion is null   )
      and (rtrim(ltrim(nivel)) = p_cod_categoria  or p_cod_categoria is null)
      and (A.cod_concepto =p_cod_concepto or p_cod_concepto  is null)
      and (A.cod_subconcepto =p_cod_subconcepto or p_cod_subconcepto  is null )  
      and (COD_NIVEL_ESTUDIO=p_cod_nivel or p_cod_nivel is null )
      AND BAJA IS NULL
      AND ( periodo= nvl(p_periodo ,to_char(sysdate,'RRRRMM')))
         AND((COD_JURISDICCION =p_dependencia)
          OR (COD_SECRETARIA=p_dependencia)
          OR (COD_SECRETARIA2=p_dependencia )
          OR (COD_DIRECCION=p_dependencia )
          OR (COD_DEPARTAMENTO=p_dependencia)
          OR (p_dependencia is null))
             ORDER BY APELLIDO,NOMBRE ASC;

      ELSE      
    IF(var_SITUACION_REVISTA='OTROS')THEN
     SELECT 
      0
    INTO var_cod
    FROM DUAL;  
    ELSE
     SELECT 
      1 
    INTO var_cod
    FROM DUAL;
    END IF;
      OPEN      vusercursor   FOR  select        
                CUIL,          
                NOMBRE,
                APELLIDO,
              
                LUE,
                ESTADO_REGISTRO,
                USUARIO_GDE,
                CON_USUARIO_GDE,
                GENERO,
                TO_CHAR(FECHA_NACIMIENTO,'DD/MM/RRRR') FECHA_NACIMIENTO,
                EDAD,
                TO_CHAR(INGRESO,'DD/MM/RRRR') INGRESO,
                ANTIGUEDAD,
                JURISDICCION_MINISTERIO,
                DEPENDENCIA_SECRETARIA,
                DEPENDENCIA_SECRETARIA_2,
                DIRECCION_GENERAL,
                DEPARTAMENTO_DIVISION,
                ESTRUCTURA_LIQ,
                FUNCION,
                DOMICILIO_LABORAL,
                SITUACION_REVISTA,
                CONVENIO,
                AGRUPAMIENTO,
                ESCALAFON,
                BRUTO_ESCALAFON,
                NIVEL,
                GRADO,
                TRAMO,
                FUNCION_EJECUTIVA,
                SUPLEMENTO_FUNCION_EJECUTIVA,
                CANT_HS_SIMPLES,
                HS_SIMPLES,
                CANT_HS_50,
                HS_50,
                CANT_HS_100,
                HS_100,
                HS_EXTRAS,
                CANT_COMIDAS,
                COMIDAS,
                CANT_UR,
                UR,
                MOVILIDAD,
                BONIFICACIONES,
                GUARDERIA,
                INTERESES,
                PREMIO_PRESENTISMO,
                TOTAL_BRUTO,
                DESCUENTOS,
                NETO,
                NO_REMUNERATIVO_PASANTE,
                CONTRIB,
                SITUACION,
                COD_TIPO_AUSENCIA,
             NIVEL_ESTUDIO,
                TITULO,
                NVL( s.DESCRIPCION, '(SIN ADICIONAL)')  ADICIONAL,
                BAJA
 from apprrhh.dotacion_actual A
 LEFT JOIN SARHA.SUBCONCEPTO  s ON A.COD_CONCEPTO=S.COD_CONCEPTO AND S.COD_SUBCONCEPTO=a.COD_SUBCONCEPTO
   where ((var_cod =0 and cod_convenio=1  and SITUACION_REVISTA<>'TITULAR' and SITUACION_REVISTA<>'DESIGNACION TRANSITORIA') 
            OR(var_cod=1 and cod_convenio=1 AND SITUACION_REVISTA=var_SITUACION_REVISTA ) AND BAJA IS NULL)
      and  (cod_tipo_ausencia = p_cod_situacion  or p_cod_situacion is null)
      and (rtrim(ltrim(nivel)) = p_cod_categoria  or p_cod_categoria is null)
      AND ( periodo= nvl(p_periodo ,to_char(sysdate,'RRRRMM')))
         AND((COD_JURISDICCION =p_dependencia)
          OR (COD_SECRETARIA=p_dependencia)
          OR (COD_SECRETARIA2=p_dependencia )
          OR (COD_DIRECCION=p_dependencia )
          OR (COD_DEPARTAMENTO=p_dependencia)
          OR (p_dependencia is null))   ORDER BY APELLIDO,NOMBRE ASC;



END IF;







 END NOMINA_FILTROS;
 
 procedure NOMINA_TOTALES(
    p_periodo in int DEFAULT null,
    p_dependencia in varchar2 DEFAULT NULL,
    p_dsTotales in VARCHAR2 DEFAULT NULL,
    infocursor OUT vcursor,
    vusercursor OUT vcursor
)

AS 
var_cod int;
 var_totales varchar2(20);
 var_titulo varchar2(200);
 resultset apprrhh.PRUEBASRRHH.vcursor;
 
 BEGIN
  PRUEBASRRHH.TITULOS(null,null,null,null,null,null,p_dsTotales,resultset);
  FETCH resultset INTO var_titulo;  
  
 OPEN      infocursor   FOR
  SELECT 
    'REPORTE - NOMINA ' 

     || 'DEPENDECIA : ' || nvl((SELECT DESCRIPCION FROM SARHA.ESTRUCTURA_REAL WHERE COD_ESTRUCTURA_REAL=p_dependencia),'TODAS ')

        ||var_titulo 
        ||' '|| DECODE(p_periodo ,NULL,'DEL PERIODO ACTUAL','DEL PERIODO: '|| p_periodo)
        AS "T�TULO"  FROM dual;

  OPEN      vusercursor   FOR 
            select      
                CUIL,          
                NOMBRE,
                APELLIDO,
                LUE,
                ESTADO_REGISTRO,
                USUARIO_GDE,
                CON_USUARIO_GDE,
                GENERO,
                TO_CHAR(FECHA_NACIMIENTO,'DD/MM/RRRR') FECHA_NACIMIENTO,
                EDAD,
                TO_CHAR(INGRESO,'DD/MM/RRRR') INGRESO,
                ANTIGUEDAD,
                JURISDICCION_MINISTERIO,
                DEPENDENCIA_SECRETARIA,
                DEPENDENCIA_SECRETARIA_2,
                DIRECCION_GENERAL,
                DEPARTAMENTO_DIVISION,
                ESTRUCTURA_LIQ,
                FUNCION,
                DOMICILIO_LABORAL,
                SITUACION_REVISTA,
                CONVENIO,
                AGRUPAMIENTO,
                ESCALAFON,
                BRUTO_ESCALAFON,
                NIVEL,
                GRADO,
                TRAMO,
                FUNCION_EJECUTIVA,
                SUPLEMENTO_FUNCION_EJECUTIVA,
                CANT_HS_SIMPLES,
                HS_SIMPLES,
                CANT_HS_50,
                HS_50,
                CANT_HS_100,
                HS_100,
                HS_EXTRAS,
                CANT_COMIDAS,
                COMIDAS,
                CANT_UR,
                UR,
                MOVILIDAD,
                BONIFICACIONES,
                GUARDERIA,
                INTERESES,
                PREMIO_PRESENTISMO,
                TOTAL_BRUTO,
                DESCUENTOS,
                NETO,
                NO_REMUNERATIVO_PASANTE,
                CONTRIB,
                SITUACION,
                COD_TIPO_AUSENCIA,
                NIVEL_ESTUDIO,
                TITULO,
                NVL( s.DESCRIPCION, '(SIN ADICIONAL)')  ADICIONAL,
                BAJA
 from apprrhh.dotacion_actual A
 LEFT JOIN SARHA.SUBCONCEPTO  s ON A.COD_CONCEPTO=S.COD_CONCEPTO AND S.COD_SUBCONCEPTO=a.COD_SUBCONCEPTO         
      where 
           (p_dsTotales like 'SITUACION' and cod_tipo_ausencia in(SELECT 
                cod_tipo_ausencia 
                 FROM DOTACION_ACTUAL 
                WHERE 
                (periodo = NVL( p_periodo ,to_char(sysdate,'RRRRMM')))
                and  BAJA is null
                 GROUP BY SITUACION,cod_tipo_ausencia )
                 
                 
                 
       OR(p_dsTotales like 'SIN ADICIONAL' and a.cuil in(select  distincT CUIL
                FROM DOTACION_ACTUAL  A
                LEFT JOIN SARHA.SUBCONCEPTO  s ON A.COD_CONCEPTO=S.COD_CONCEPTO AND S.COD_SUBCONCEPTO=a.COD_SUBCONCEPTO
                WHERE   a.periodo= nvl(p_periodo, to_char(sysdate,'RRRRMM'))
                AND BAJA IS NULL
                GROUP BY CUIL, s.DESCRIPCION,A.COD_SUBCONCEPTO,A.COD_CONCEPTO))
                
         OR(p_dsTotales like 'ESTUDIO' and a.cuil IN(SELECT  DISTINCT CUIL
                FROM DOTACION_ACTUAL 
                WHERE PERIODO= nvl(p_periodo, to_char(sysdate,'RRRRMM'))
                AND COD_NIVEL_ESTUDIO IN(2, 4,5 ,17,12,6,1,3,9,10,19,29,28,30,-1)
                AND BAJA IS NULL)))    
         AND ( periodo= nvl(p_periodo ,to_char(sysdate,'RRRRMM')))
         AND ( BAJA IS NULL)
         AND((COD_JURISDICCION =p_dependencia)
          OR (COD_SECRETARIA=p_dependencia)
          OR (COD_SECRETARIA2=p_dependencia )
          OR (COD_DIRECCION=p_dependencia )
          OR (COD_DEPARTAMENTO=p_dependencia)
          OR (p_dependencia is null))

         ORDER BY APELLIDO,NOMBRE ASC;



END NOMINA_TOTALES;
 
 
 
 
 
END PRUEBASRRHH;
-----------------
insert
create or replace PACKAGE HORASEXTRAS AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */ 

   TYPE vcursor IS REF CURSOR;

   PROCEDURE REPORTECARGA (
      p_periodo     IN       liquidaciones.periodo_liquidacion%TYPE,
      vusercursor   OUT      vcursor
   );
  PROCEDURE HORASEXTRAS_I (
      p_periodo     IN       HX_HORASEXTRAS.CDPERIODO%TYPE,  
      p_cuil        in       HX_HORASEXTRAS.DSCUIL%TYPE,  
      p_dtFechaIngreso in    VARCHAR2,
      p_dtFechaSalida in varchar2,   
     p_CDUSUARIO_TRN in int,

      vusercursor   OUT      vcursor
   );
  PROCEDURE HORASEXTRASDETALLE_D (
      p_cdHoraExtraDetalle     IN       HX_HORASEXTRASDETALLE.cdHoraExtraDetalle%TYPE,      
      p_CDUSUARIO_TRN in int,
      ID_HORAEXTRADETALLE   OUT      HX_HORASEXTRASDETALLE.ID_HORAEXTRA_DETALLE%TYPE
   );
  PROCEDURE HORASEXTRASDETALLE_porCUIL (
        p_periodo     IN       HX_HORASEXTRAS.CDPERIODO%TYPE,  
        p_cuil        in       HX_HORASEXTRAS.DSCUIL%TYPE,  
        vusercursor   OUT      vcursor
   );  
  PROCEDURE HORASEXTRA_TotalesporPeriodo (
        p_periodo     IN       HX_HORASEXTRAS.CDPERIODO%TYPE,  
        p_cuil        in       HX_HORASEXTRAS.DSCUIL%TYPE,  
        vusercursor   OUT      vcursor
   );  
  PROCEDURE HORAEXTRA_CUIL(
     p_cuil        in       HX_HORASEXTRAS.DSCUIL%TYPE,  
      vusercursor   OUT      vcursor);
 
 PROCEDURE HORAEXTRA_PENDIENTES(
    p_dependencia        in       HX_HORASEXTRAS.COD_ESTRUCTURA_REAL%TYPE,    
    p_periodo in    HX_HORASEXTRAS.CDPERIODO%TYPE,
    vusercursor   OUT      vcursor,
    registros out number);


PROCEDURE HORAEXTRA_PENDIENTES_VISADO(
    p_dependencia        in       HX_HORASEXTRAS.COD_ESTRUCTURA_REAL%TYPE,   
    p_periodo in    HX_HORASEXTRAS.CDPERIODO%TYPE,
    p_estado in int,
    vusercursor   OUT      vcursor,
    registros out number);    
    
 FUNCTION Es_Ultimo_dia_Habil(p_cuil IN  HX_HORASEXTRAS.DSCUIL%TYPE, 
                       p_periodo in int,
                       p_fecha in varchar2) 
   RETURN SMALLINT; 
     PROCEDURE POR_DEPENDENCIA_ESTADO(
      p_dependencia IN sarha.estructura_real.cod_estructura_real%TYPE,     
      p_periodo in int,
      vusercursor   OUT      vcursor
   );  
   
    FUNCTION Tiene_12hs_descanso(p_cuil IN  HX_HORASEXTRAS.DSCUIL%TYPE, 
                                 p_fechaingreso in varchar2,
                                 p_fechasalida in varchar2) 
   RETURN SMALLINT; 
   
END HORASEXTRAS;
---cuerpo
create or replace PACKAGE BODY HORASEXTRAS AS 


FUNCTION Es_Ultimo_dia_Habil(p_cuil IN  HX_HORASEXTRAS.DSCUIL%TYPE, 
                       p_periodo in int,
                       p_fecha in varchar2) 
   RETURN SMALLINT
   AS
   v_dtUltimo date;
   v_dtFeriado date;
   BEGIN
   

   
   
 select 


        trunc( 
                   
                              CASE  WHEN last_day(to_DATE(P_PERIODO ||'01','RRRRMMDD'))= fin THEN inicio
                                   WHEN last_day(to_DATE(P_PERIODO ||'01','RRRRMMDD')) IN (SELECT TRUNC(dtFeriado) from HX_FERIADOS where to_char(dtFeriado,'RRRRMM')=P_PERIODO ) 
                                   then 
                                   CASE 
                                      WHEN (last_day(to_DATE(P_PERIODO ||'01','RRRRMMDD')) - 1)   IN (SELECT TRUNC(dtFeriado) from HX_FERIADOS where to_char(dtFeriado,'RRRRMM')=P_PERIODO ) then  last_day(to_DATE(P_PERIODO ||'01','RRRRMMDD')) - 2
                                       else (last_day(to_DATE(P_PERIODO ||'01','RRRRMMDD')) - 1)  end
                                   ELSE  last_day(to_DATE(P_PERIODO ||'01','RRRRMMDD')) END
           
            - decode(fin-inicio, null, 0, fin-inicio))
         
           into v_dtUltimo
            



from dual 
   left join (select
           min(FECHA) inicio,
           MAX (fecha) fin
              
         FROM  sarha.empleado e
          inner join SARHA.CAUSAL_AUSENCIA  ca on CA.cuil=E.cuil AND CA.fecha_cancelacion IS NULL
          inner join SARHA.TIPO_AUSENCIA ta on ta.cod_tipo_ausencia=ca.cod_tipo_ausencia and ta.cod_tipo_causal=ca.cod_tipo_causal
          inner join SARHA.TIPO_CAUSAL SA ON SA.COD_TIPO_CAUSAL=CA.COD_TIPO_CAUSAL,
          (  SELECT
            trunc(to_DATE(P_PERIODO ||'01','RRRRMMDD'),'MON') + ROWNUM - 1 fecha,
            TO_CHAR(TO_CHAR(TO_DATE(trunc(to_DATE(P_PERIODO ||'01','RRRRMMDD'),'MON') + ROWNUM - 1,'DD/MM/YYYY HH24:MI:SS'),'DD') ) numero,
            CASE to_number(TO_CHAR(TO_DATE(trunc(to_DATE(P_PERIODO ||'01','RRRRMMDD'),'MON') + ROWNUM - 1,'DD/MM/YYYY HH24:MI:SS'),'D','NLS_DATE_LANGUAGE=SPANISH') )
                    WHEN 1   THEN 'LUNES'
                    WHEN 2   THEN 'MARTES'
                    WHEN 3   THEN 'MIERCOLES'
                    WHEN 4   THEN 'JUEVES'
                    WHEN 5   THEN 'VIERNES'
                    WHEN 6   THEN 'SABADO'
                    WHEN 7   THEN 'DOMINGO'
                END
            dia
        FROM
            dual
        WHERE
            TO_CHAR(to_DATE(P_PERIODO ||'01','RRRRMMDD'),'MON') = TO_CHAR(trunc(to_DATE(P_PERIODO ||'01','RRRRMMDD'),'MON') + ROWNUM - 1,'MON')
        CONNECT BY
            level <= 31) h
          
          where  e.cuil=p_cuil 
       and  h.fecha between FECHA_DESDE and FECHA_HASTA ) l on  trunc( last_day(to_DATE(P_PERIODO ||'01','RRRRMMDD'))
     - decode(to_char(last_day(to_DATE(P_PERIODO ||'01','RRRRMMDD')), 'd'),  '7', 2,'6',1, 0) ) between inicio and fin;


     v_dtUltimo:= CASE  to_char(v_dtUltimo,'d')
                   when 6  then v_dtUltimo -1              
                   when 7 then  v_dtUltimo -2
                   else v_dtUltimo end;
                   
     -- v_dtFeriado:= ( select trunc(dtFeriado) from HX_FERIADOS WHERE TRUNC(dtFeriado)=to_date(v_dtUltimo,'DD/MM/RRRR'));
      
     /* if (v_dtferiado=v_dtUltimo) then
            v_dtUltimo:=v_dtUltimo-1;
      end if;*/
      

   if(v_dtUltimo<=p_fecha)then
      return 1;
   else
      return 0;
   end if;
 
   

  end Es_Ultimo_dia_Habil; 
PROCEDURE REPORTECARGA (
    p_periodo     IN liquidaciones.periodo_liquidacion%TYPE,
    vusercursor   OUT vcursor
) AS
       
    BEGIN OPEN vusercursor FOR 

    SELECT
    a.cuil,
    apellido,
    nombre,
    c1.descripcion convenio,
    er.descripcion estructura,
    b.descripcion tipo_supl,
    po.descripcion pago_supl,
    TO_CHAR(fecha_desde,'DD/MM/YYYY') AS fecha_desde,
    TO_CHAR(fecha_hasta,'DD/MM/YYYY') AS fecha_hasta,
    cantidad,
    a.fecha_transaccion,
    fecha_proceso,
    a.fecha_autorizacion
                               FROM
    sarha.suplemento_empleado a,
    sarha.tipo_suplemento_horario b,
    segu.securityuser u,
    sarha.tipo_pago_supl po,
    sarha.empleado e,
    sarha.asignacion e1,
    sarha.convenio c1,
    sarha.escalafon e2,
    sarha.estructura_real er
                               WHERE
    a.cod_tipo_suplemento_horario = b.cod_tipo_suplemento_horario
    AND   u.userid = a.cod_usuario
    AND   po.cod_tipo_pago_supl = a.cod_tipo_pago_supl
    AND   e.cuil = a.cuil
    AND   e1.cuil = e.cuil
    AND   c1.cod_convenio = e1.cod_convenio
    AND   e2.cod_escalafon = e1.cod_escalafon
    AND   e1.cod_estructura_real = er.cod_estructura_real
    AND   e1.fecha_fin IS NULL
ORDER BY
    fecha_proceso,
    a.cuil;


    END REPORTECARGA;
 PROCEDURE HORASEXTRAS_I (
      p_periodo     IN       HX_HORASEXTRAS.CDPERIODO%TYPE,  
      p_cuil        in       HX_HORASEXTRAS.DSCUIL%TYPE,  
      p_dtFechaIngreso in    VARCHAR2,
      p_dtFechaSalida in varchar2,   
     p_CDUSUARIO_TRN in int,

      vusercursor   OUT      vcursor
   ) AS
     
       v_vtotal                      DECIMAL(18,2);
        v_vsimples                    DECIMAL(18,2);
        v_vl50                        DECIMAL(18,2);
        v_vl100                       DECIMAL(18,2);
          v_vl100_lv                       DECIMAL(18,2);
        v_vlcomidas                   INT;
        resultset                     apprrhh.hx_nomina_empleados.vcursor;
        v_cdhoraextra                 INT;
        v_cdestado                    INT;
        v_cdhoraextradetalle          INT;
        v_cuil                        VARCHAR2(30);
        v_apellido                    VARCHAR2(60);
        v_nombre                      VARCHAR2(60);
        v_legajo                      VARCHAR2(30);
        v_dni                         INT;
        v_cod_estructura_real         VARCHAR2(30);
        v_des_estructura_real         VARCHAR2(200);
        v_cod_estructura_desempenio   VARCHAR2(30);
        v_des_estructura_desempenio   VARCHAR2(200);
        v_cod_estructura_pagadora     VARCHAR2(30);
        v_des_estructura_pagadora     VARCHAR2(200);
        v_cod_convenio                INT;
        v_des_convenio                VARCHAR2(200);
        v_cod_escalafon               INT;
        v_letra                       CHAR(2);
        v_grado                       CHAR(4);
        v_cod_funcion                 INT;
        v_vlsueldo_limite             DECIMAL(18,2);
        v_vlsueldo_horas              DECIMAL(18,2);
        v_montosimplexhs              DECIMAL(18,2);
        v_monto50xhs                  DECIMAL(18,2);
        v_monto100xhs                 DECIMAL(18,2);
        v_montocomida                 DECIMAL(18,2);
        v_vlferiado                   INT;
        v_id_horaextra                INT;
        v_id_horaextra_detalle        INT;
        v_dia                         INT;
        v_dtalmuerzodesde             DATE;
        v_dtalmuerzohasta             DATE;
        v_dtcenadesde                 DATE;
        v_dtcenahasta                 DATE;
        v_dtlimite50                  DATE;  
        v_dtlimite1000                  DATE;
        v_dtAlta varchar(10);
       v_dtSalida varchar(10);
      v_HORAINGRESO varchar(10);
     v_HORASALIDA varchar(10);
     v_lang varchar(50);
     v_aux   DECIMAL(18,2);
     v_totalGeneral DECIMAL(18,2);
     v_dtAsignadoIngreso date;
     v_dtAsignadoSalida date;
     v_Limite_100LV_min date;
     v_Limite_100LV_max date;
     v_Es_Ultimo int;
     v_icValido int;
    BEGIN

  -- TAREA: Se necesita implantaci�n para PROCEDURE HORASEXTRAS.HORASEXTRAS_I

     -- raise_application_error(-20020,TO_DATE(p_dtfechasalida,'DD/MM/RRRR HH24:MI:SS','NLS_LANGUAGE=SPANISH'));
       --dbms_output.put_line(p_dtfechasalida);
        -- dbms_output.put_line(TO_CHAR(LOCALTIMESTAMP,'DD/MM/RRRR HH24:MI:SS','NLS_DATE_LANGUAGE=SPANISH') );

    /*    if (   TO_NUMBER(TO_char(p_dtfechasalida,'RRRRMM','NLS_DATE_LANGUAGE=SPANISH')) <>  p_periodo      ) then

             raise_application_error(-20001,'Elpreriodo no coincide con la fecha ingresada');
        end if;*/
        
        
        

         v_icValido :=1;
        
     v_Es_Ultimo:=Es_Ultimo_dia_Habil(p_cuil,p_periodo,TO_DATE(p_dtfechasalida,'DD/MM/RRRR HH24:MI:SS','NLS_DATE_LANGUAGE=SPANISH'));

   if (v_Es_Ultimo=0) then

      if( TO_DATE(p_dtfechasalida,'DD/MM/RRRR HH24:MI:SS','NLS_DATE_LANGUAGE=SPANISH')  > TO_DATE(TO_CHAR(LOCALTIMESTAMP,'DD/MM/RRRR HH24:MI:SS','NLS_DATE_LANGUAGE=SPANISH'),'DD/MM/RRRR HH24:MI:SS','NLS_DATE_LANGUAGE=SPANISH' ))then
            rollback work;
             raise_application_error(-20001,'El horario de salida no puede ser mayor al horario actual.');

      end if;
      if ( TO_DATE(p_dtfechaingreso,'DD/MM/RRRR HH24:MI:SS','NLS_DATE_LANGUAGE=SPANISH') > TO_DATE(TO_CHAR(LOCALTIMESTAMP,'DD/MM/RRRR HH24:MI:SS','NLS_DATE_LANGUAGE=SPANISH') ,'DD/MM/RRRR HH24:MI:SS','NLS_DATE_LANGUAGE=SPANISH'  )    )then
             rollback work;
             raise_application_error(-20001,'El horario de ingreso no puede ser mayor al horario actual.');

      end if;
      end if;
   hx_nomina_empleados.por_cuil_fecha(p_cuil,p_dtfechaingreso,resultset);  

   begin
   --OPEN resultSet;
   FETCH resultset INTO v_cuil,v_apellido,v_nombre,v_legajo,v_dni,v_cod_estructura_real,v_des_estructura_real,v_cod_estructura_desempenio
    ,v_des_estructura_desempenio,v_cod_estructura_pagadora,v_des_estructura_pagadora,v_cod_convenio,v_des_convenio,v_cod_escalafon,v_letra
    ,v_grado,v_cod_funcion,v_vlsueldo_limite,v_vlsueldo_horas,v_montosimplexhs,v_monto50xhs,v_monto100xhs,v_montocomida,v_dtAlta,v_dtSalida,v_HORAINGRESO,v_HORASALIDA;

      /* EXIT WHEN resultset%notfound;*/
    dbms_output.put_line('CUIL: '
    || v_cuil
    || ' APELLIDO Y NOMBRE : '
    || v_apellido
    || v_nombre
    || ' LEGAJO : '
    || v_legajo
    || ' DNI : '
    || v_dni
    || ' ESTRUCTURA REAL : '
    || v_cod_estructura_real
    || v_des_estructura_real
    || ' ESTRUCTURA DESEMPENIO : '
    || v_cod_estructura_desempenio
    || v_des_estructura_desempenio
    || ' ESTRUCTURA PAGADORA : '
    || v_cod_estructura_pagadora
    || v_des_estructura_pagadora
    || ' CONVENIO : '
    || v_cod_convenio
    || v_des_convenio
    || ' ESCALAFON : '
    || v_cod_escalafon
    || ' LETRA : '
    || v_letra
    || ' GRADO : '
    || v_grado
    || ' FUNCION : '
    || v_cod_funcion
    || ' SUELDO LIMITE: '
    || v_vlsueldo_limite
    || ' SUELDO CALCULO: '
    || v_vlsueldo_horas
    || ' VALOR HORAS SIMPLES : '
    || v_montosimplexhs
    || ' VALOR HORAS 50 : '
    || v_monto50xhs
    || ' VALOR HORAS 100 : '
    || v_monto100xhs
    || ' VALOR COMIDA : '
    || v_montocomida); 
    
    if (v_cuil is null) then
      raise_application_error(-20045,'No se pudo procesar la solicitud. Comuniquese con  el administrador del sistema');
    end if;
     if (v_HORAINGRESO is null) then
      raise_application_error(-20045,'Falta definir el horario de jornada laboral');
    end if;


              /*Total de horas realizadas incluyendo las horas nomarles laborales*/

    v_vtotal := ( ( TO_DATE(p_dtfechasalida,'DD/MM/RRRR HH24:MI:SS') - TO_DATE(p_dtfechaingreso,'DD/MM/RRRR HH24:MI:SS') ) * 24 );
    v_totalGeneral:=v_vtotal;
    /*Asigno fecha para horarios asignados y los horarios limites para horas al 100 de Lunes a viernes*/

     v_dtAsignadoIngreso :=    trunc(to_date(p_dtfechaingreso, 'DD/MM/RRRR HH24:MI:SS')) +  to_number(SUBSTR ( v_HORAINGRESO,0,2) )/ 24  + to_number(SUBSTR ( v_HORAINGRESO,4,5) )/1440  ;
     v_dtAsignadoSalida :=   trunc(to_date(p_dtfechaingreso, 'DD/MM/RRRR HH24:MI:SS')) +  to_number(SUBSTR ( v_HORASALIDA,0,2) )/ 24  + to_number(SUBSTR ( v_HORASALIDA,4,5) )/1440  ;
    /* begin

       v_dtAsignadoIngreso:=    to_date( trunc(to_date(p_dtfechaingreso, 'DD/MM/RRRR HH24:MI:SS')) || ' ' || v_HORAINGRESO || ':00', 'DD/MM/RRRR HH24:MI:SS');  
       v_dtAsignadoSalida :=  to_date( trunc(to_date(p_dtfechasalida, 'DD/MM/RRRR HH24:MI:SS')) || ' ' || v_HORASALIDA || ':00',  'DD/MM/RRRR HH24:MI:SS');
       EXCEPTION
       WHEN OTHERS THEN

          v_dtAsignadoIngreso :=    trunc(to_date(p_dtfechaingreso, 'DD/MM/RRRR HH24:MI:SS')) +  to_number(SUBSTR ( v_HORAINGRESO,0,2) )/ 24  + to_number(SUBSTR ( v_HORAINGRESO,4,5) )/1440  ;
         v_dtAsignadoSalida :=   trunc(to_date(p_dtfechasalida, 'DD/MM/RRRR HH24:MI:SS')) +  to_number(SUBSTR ( v_HORASALIDA,0,2) )/ 24  + to_number(SUBSTR ( v_HORASALIDA,4,5) )/1440  ;
     end;*/

      dbms_output.put_line('v_dtAsignadoIngreso: '        ||  v_dtAsignadoIngreso);
      dbms_output.put_line('v_dtAsignadoSalida: '        ||  v_dtAsignadoSalida);

        v_Limite_100LV_min:= trunc(to_date(p_dtfechaingreso, 'DD/MM/RRRR HH24:MI:SS')) + 6/24;
         v_Limite_100LV_max:= trunc(to_date(p_dtfechaingreso, 'DD/MM/RRRR HH24:MI:SS'))  + 22/24;
--     v_Limite_100LV_min:= to_date( trunc(to_date(p_dtfechasalida, 'DD/MM/RRRR HH24:MI:SS')) || ' ' || '06:00:00', 'DD/MM/RRRR HH24:MI:SS');
  --   v_Limite_100LV_max:= to_date( trunc(to_date(p_dtfechasalida, 'DD/MM/RRRR HH24:MI:SS')) || ' ' || '22:00:00', 'DD/MM/RRRR HH24:MI:SS');

      dbms_output.put_line('v_Limite_100LV_min: '        ||  v_Limite_100LV_min);
      dbms_output.put_line('v_Limite_100LV_max: '        ||  v_Limite_100LV_max);

  
     

  




      dbms_output.put_line('Total de horas realizadas incluyendo las horas nomarles laborales: '    || v_vtotal);
      
        dbms_output.put_line('Horario ingreso : '        || TO_DATE(p_dtfechaingreso,'DD/MM/RRRR HH24:MI:SS'));
      dbms_output.put_line('Horario salida   : '             || TO_DATE(p_dtfechasalida,'DD/MM/RRRR HH24:MI:SS'));
      dbms_output.put_line('Horario ingreso asignado: '        || v_dtAsignadoIngreso);
      dbms_output.put_line('Horario salida asignado  : '             || v_dtAsignadoSalida);




            /*Si son mas de 13 hs corresponde 2 comidas y se restan 1 hora*/
 

            /*Si son mas de 9 hs  y menos de 13 corresponde comida y se restan 0.5 hora*/

    IF
        ( v_vtotal > 9 AND v_vtotal < 14 )
    THEN
        v_vtotal := v_vtotal - 0.5;
        v_vlcomidas := 1;
        dbms_output.put_line('Se resta 0.5 por 1 comida: '
        || v_vtotal);
    END IF;      

   IF
        v_vtotal >= 14
    THEN
        v_vtotal := v_vtotal - 1;
        v_vlcomidas := 2;
        dbms_output.put_line('Se resta 1 hora por 2 comidas: '
        || v_vtotal);
    END IF;    

            /*VERIFICO SI LA FECHA ES FERIADO*/

    SELECT
        CASE
            WHEN COUNT(*) > 0 THEN 1
            ELSE 0
        END
    INTO
        v_vlferiado
    FROM
        apprrhh.hx_feriados
    WHERE
        trunc(dtferiado) = trunc(TO_DATE(p_dtfechaingreso,'DD/MM/RRRR HH24:MI:SS','NLS_DATE_LANGUAGE=SPANISH') );

    v_dia := to_number(TO_CHAR(TO_DATE(p_dtfechaingreso,'DD/MM/RRRR HH24:MI:SS','NLS_DATE_LANGUAGE=SPANISH'),'D','NLS_DATE_LANGUAGE=SPANISH') );

    dbms_output.put_line('Dia de la semana: '    || v_dia);
    dbms_output.put_line('Es Feriado: '    || v_vlferiado);
    IF
        ( v_vlferiado = 1 )
    THEN
                                        /*Si es feriado son todas las horas al 100*/
        v_vl100 := v_vtotal;
        dbms_output.put_line('Horas 100%: '        || v_vl100);
    ELSE
        dbms_output.put_line('Dia: '        || v_dia);


        /*Si es Sabado o domingo*/
        IF
            ( v_dia = 6 OR v_dia = 7 )
        THEN
            IF
                ( v_dia = 6 )
            THEN
               v_dtlimite50 := trunc(TO_DATE(p_dtfechaingreso,'DD/MM/RRRR HH24:MI:SS','NLS_DATE_LANGUAGE=SPANISH') ) + INTERVAL '13' HOUR;
                dbms_output.put_line('Fecha Limite: '
                || v_dtlimite50);
             
             
             
             
                --v_vtotal
             /*1- de 00 a 6  al 100%*/
                if (TO_DATE(p_dtfechaingreso,'DD/MM/RRRR HH24:MI:SS','NLS_DATE_LANGUAGE=SPANISH') between trunc(TO_DATE(p_dtfechaingreso,'DD/MM/RRRR HH24:MI:SS','NLS_DATE_LANGUAGE=SPANISH') ) and  v_Limite_100LV_min) then
                    
                      if (TO_DATE(p_dtfechasalida,'DD/MM/RRRR HH24:MI:SS','NLS_DATE_LANGUAGE=SPANISH') between trunc(TO_DATE(p_dtfechaingreso,'DD/MM/RRRR HH24:MI:SS','NLS_DATE_LANGUAGE=SPANISH') ) and  v_Limite_100LV_min) then
                          v_vl100:=(TO_DATE(p_dtfechasalida,'DD/MM/RRRR HH24:MI:SS','NLS_DATE_LANGUAGE=SPANISH') -  TO_DATE(p_dtfechaingreso,'DD/MM/RRRR HH24:MI:SS','NLS_DATE_LANGUAGE=SPANISH')  ) * 24 ;
                      else 
                           v_vl100:= ( v_Limite_100LV_min -TO_DATE(p_dtfechaingreso,'DD/MM/RRRR HH24:MI:SS','NLS_DATE_LANGUAGE=SPANISH')  ) * 24 ;
                      end if;                     
                 
                end if;
             /*2- de 6 a 13 horas al 50%*/
             
              if (TO_DATE(p_dtfechaingreso,'DD/MM/RRRR HH24:MI:SS','NLS_DATE_LANGUAGE=SPANISH') between v_Limite_100LV_min and v_dtlimite50 ) then
                     
                      if (TO_DATE(p_dtfechasalida,'DD/MM/RRRR HH24:MI:SS','NLS_DATE_LANGUAGE=SPANISH') between v_Limite_100LV_min and v_dtlimite50) then
                          v_vl50:=(TO_DATE(p_dtfechasalida,'DD/MM/RRRR HH24:MI:SS','NLS_DATE_LANGUAGE=SPANISH') -  TO_DATE(p_dtfechaingreso,'DD/MM/RRRR HH24:MI:SS','NLS_DATE_LANGUAGE=SPANISH')  ) * 24 ;
                          
                      else 
                           v_vl50:= ( v_dtlimite50 -TO_DATE(p_dtfechaingreso,'DD/MM/RRRR HH24:MI:SS','NLS_DATE_LANGUAGE=SPANISH')  ) * 24 ;
                          
                  
                      end if;     
                  else
                      
                     if (TO_DATE(p_dtfechasalida,'DD/MM/RRRR HH24:MI:SS','NLS_DATE_LANGUAGE=SPANISH') between v_Limite_100LV_min and v_dtlimite50) then
                     
                          v_vl50:=(TO_DATE(p_dtfechasalida,'DD/MM/RRRR HH24:MI:SS','NLS_DATE_LANGUAGE=SPANISH') - v_dtlimite50) * 24;
                     else
                          if (TO_DATE(p_dtfechaingreso,'DD/MM/RRRR HH24:MI:SS','NLS_DATE_LANGUAGE=SPANISH')<v_dtlimite50) then
                             v_vl50:=( v_dtlimite50 - v_Limite_100LV_min) * 24;
                          end if;
                         
                     end if;
                    
             
                end if;
             
             
             /*3- de 13 a 23.59 horas al 100%*/
             
             if (TO_DATE(p_dtfechaingreso,'DD/MM/RRRR HH24:MI:SS','NLS_DATE_LANGUAGE=SPANISH') >= v_dtlimite50  ) then
                    
                     v_vl100:=(TO_DATE(p_dtfechasalida,'DD/MM/RRRR HH24:MI:SS','NLS_DATE_LANGUAGE=SPANISH') -  TO_DATE(p_dtfechaingreso,'DD/MM/RRRR HH24:MI:SS','NLS_DATE_LANGUAGE=SPANISH')  ) * 24 ;
                         
               else
                 if (TO_DATE(p_dtfechasalida,'DD/MM/RRRR HH24:MI:SS','NLS_DATE_LANGUAGE=SPANISH') > v_dtlimite50)then
                  
                   v_vl100:= nvl( v_vl100,0) +  ( TO_DATE(p_dtfechasalida,'DD/MM/RRRR HH24:MI:SS','NLS_DATE_LANGUAGE=SPANISH') - v_dtlimite50 ) * 24;
                    
                  
             end if;
             
          
         end if;
            dbms_output.put_line('Horas 100%: '                || v_vl100);

                    if (v_vlcomidas=1) then
                         
                     if (v_vl100 > 9) then
                              v_vl100:=v_vl100 - 0.5;
                        else
                             v_vl50:=v_vl50 - 0.5;
                      end if;
                         
                            else
                             dbms_output.put_line('no aplica comida '                || v_vl100);
                     end if;
                if (v_vlcomidas=2) then
                     if (v_vl100 >= 13) then
                              v_vl100:=v_vl100-1;
                        else
                             v_vl50:=v_vl50-0.5;
                             v_vl100:=v_vl100-0.5;
                      end if;                
                 end if;
             
             dbms_output.put_line('Horas 100%: '                || v_vl100);
             dbms_output.put_line('Horas 50%: '                 || v_vl50);
            
             
            ELSE
                                          /*Si es domingo son al 100*/
                v_vl100 := v_vtotal;
                dbms_output.put_line('Horas 100%: '
                || v_vl100);
            END IF;

        ELSE


         if( v_letra IN (  'E', 'F' )) then
              if (v_vtotal>7) then
                /*Se restan la hora normales para saber cuantas horas extras hay*/
               v_vtotal := v_vtotal-7;
               else
                rollback work;
                 raise_application_error(-20010,'El rango de horas ingresado no tiene horas extraordinarias para registrar. Deben superar las 7 hs normales.');

                 --EXIT;
              end if;

           else
            if (v_vtotal>8) then
              /*Se restan la hora normales para saber cuantas horas extras hay*/
            v_vtotal := v_vtotal-8;
            else
             rollback work;
             raise_application_error(-20010,'El rango de horas ingresado no tiene horas extraordinarias para registrar. Deben superar las 8 hs normales.');

                 --EXIT;
            end if;

         end if;




     /* if (TO_DATE(p_dtfechaingreso,'DD/MM/RRRR HH24:MI:SS') > v_dtAsignadoIngreso)then
                raise_application_error(-20004,'El horario de ingreso no puede ser mayor al horario asignado para esta fecha. Solicite cambio de horario para este dia en ser necesario cargar esta franja horaria');
             ELSE*/
                  if( TO_DATE(p_dtfechaingreso,'DD/MM/RRRR HH24:MI:SS') <  v_dtAsignadoIngreso ) THEN
                             --Horas extras realizadas antes del horario
                     if (TO_DATE(p_dtfechaingreso,'DD/MM/RRRR HH24:MI:SS') < v_Limite_100LV_min)  then

                               if ( v_dtAsignadoIngreso < v_Limite_100LV_min )then 

                                v_aux :=( v_dtAsignadoIngreso - TO_DATE(p_dtfechaingreso,'DD/MM/RRRR HH24:MI:SS'))* 24  ;

                               else
                                v_aux :=( v_Limite_100LV_min - TO_DATE(p_dtfechaingreso,'DD/MM/RRRR HH24:MI:SS')) *24 ;

                               end if;

                               dbms_output.put_line('horas 100 LaV antes de ingreso asignado: '    || v_aux);
                               v_vl100_lv :=v_aux;




                       else
                    --     v_vsimples:=(  v_dtAsignadoIngreso - TO_DATE(p_dtfechaingreso,'DD/MM/RRRR HH24:MI:SS') )*24;  
                          dbms_output.put_line('horas simples LaV entre de ingreso y el ingreso asignado: '    || v_vsimples);
                    end if;                             

                  else
                --    v_vsimples:=( TO_DATE(p_dtfechaingreso,'DD/MM/RRRR HH24:MI:SS') - v_dtAsignadoIngreso)*24 ; 
                    dbms_output.put_line('horas simples LaV antes de salida asignada: '    || v_vsimples);
                 end IF;

            -- end if;




    /*  if (TO_DATE(p_dtfechasalida,'DD/MM/RRRR HH24:MI:SS') <v_dtAsignadoSalida)then

                 raise_application_error(-20012,'El horario de salida no puede ser menor al horario asignado para esta fecha. Solicite cambio de horario para este dia en ser necesario cargar esta franja horaria');
      ELSE*/

                 if( TO_DATE(p_dtfechasalida,'DD/MM/RRRR HH24:MI:SS')>v_dtAsignadoSalida ) THEN
                             --Horas extras realizadas despues del horario
                     if (TO_DATE(p_dtfechasalida,'DD/MM/RRRR HH24:MI:SS')>v_Limite_100LV_max) then


                              if (TO_DATE(v_dtAsignadoSalida,'DD/MM/RRRR HH24:MI:SS')>v_Limite_100LV_max)  then

                                   v_aux :=  ( TO_DATE(p_dtfechasalida,'DD/MM/RRRR HH24:MI:SS') - v_dtAsignadoSalida)*24 ;
                                   dbms_output.put_line('horas 100 LaV entre la salida y el horario aisgnado de salida de horas simples: '    || v_aux);

                              else
                                  v_aux :=  (TO_DATE(p_dtfechasalida,'DD/MM/RRRR HH24:MI:SS') - v_Limite_100LV_max )*24  ;
                                  dbms_output.put_line('horas 100 LaV entre la salida y el limite de horas simples: '    || v_aux);

                              end if;


                             dbms_output.put_line('horas 100 LaV despues de salida asignada: '    || v_aux);
                             v_vl100_lv := nvl(v_vl100_lv ,0 )+ v_aux;
                      /* else


                        v_vsimples:= nvl(v_vsimples ,0) + ( (TO_DATE(p_dtfechasalida,'DD/MM/RRRR HH24:MI:SS') -v_dtAsignadoSalida )*24            );  
                        dbms_output.put_line('horas simples LaV despues de salida asignada: '    || v_vsimples);*/


                --    end if;                             



                 end IF;
                 dbms_output.put_line('condicion salida: false '  );



      end if;

         --v_vsimples:=(  v_dtAsignadoIngreso - TO_DATE(p_dtfechaingreso,'DD/MM/RRRR HH24:MI:SS') )*24;  
         if (v_vtotal > v_vl100_lv) then
                v_vsimples:=v_vtotal - v_vl100_lv;
         else
            if (v_vlcomidas=1) then
                                 -- v_vsimples:= v_vsimples - 0.5;
                            if(v_vl100_lv>0 and v_vsimples=0) then
                             v_vl100_lv :=    v_vl100_lv - 0.5;
                            end if;

                           end if;
           if (v_vlcomidas=2) then
                            --v_vsimples:= v_vsimples - 1;
                            if(v_vl100_lv>0 and v_vsimples=0) then
                              v_vl100_lv :=    v_vl100_lv - 1;
                            end if;
              end if;

              if (nvl(v_vl100_lv,0)=0 and nvl(v_vsimples,0)=0 ) then
              v_vsimples := v_vtotal ;
              end if ; 
         end if;




             /*Son Horas simples no es fin de semana ni feriado*/
             -- v_vsimples := v_vtotal ;


            dbms_output.put_line('Horas simples: '            || v_vsimples);
        END IF;

    END IF;

v_dtalmuerzodesde := TO_DATE(p_dtfechaingreso,'DD/MM/RRRR HH24:MI:SS','NLS_DATE_LANGUAGE=SPANISH')  + INTERVAL '4' HOUR;
v_dtalmuerzohasta := TO_DATE(p_dtfechaingreso,'DD/MM/RRRR HH24:MI:SS','NLS_DATE_LANGUAGE=SPANISH')  + INTERVAL '4' HOUR + INTERVAL '30' MINUTE;
v_dtcenadesde := TO_DATE(p_dtfechasalida,'DD/MM/RRRR HH24:MI:SS','NLS_DATE_LANGUAGE=SPANISH')  - INTERVAL '2' HOUR;
v_dtcenahasta :=TO_DATE(p_dtfechasalida,'DD/MM/RRRR HH24:MI:SS','NLS_DATE_LANGUAGE=SPANISH') - INTERVAL '2' HOUR + INTERVAL '30' MINUTE;

  /*  v_dtalmuerzodesde := trunc(TO_DATE(p_dtfechaingreso,'DD/MM/RRRR HH24:MI:SS','NLS_DATE_LANGUAGE=SPANISH') ) + INTERVAL '12' HOUR;
    v_dtalmuerzohasta := trunc(TO_DATE(p_dtfechaingreso,'DD/MM/RRRR HH24:MI:SS','NLS_DATE_LANGUAGE=SPANISH') ) + INTERVAL '12' HOUR + INTERVAL '30' MINUTE;
    v_dtcenadesde := trunc(TO_DATE(p_dtfechaingreso,'DD/MM/RRRR HH24:MI:SS','NLS_DATE_LANGUAGE=SPANISH') ) + INTERVAL '21' HOUR;
    v_dtcenahasta := trunc(TO_DATE(p_dtfechaingreso,'DD/MM/RRRR HH24:MI:SS','NLS_DATE_LANGUAGE=SPANISH') ) + INTERVAL '21' HOUR + INTERVAL '30' MINUTE;*/

    BEGIN
               /**Existe cabecera de hora extra para el cuil y periodo */
        SELECT


                   cdhoraextra 
                  ,
                cdestado
        INTO
            v_cdhoraextra,v_cdestado
        FROM
            apprrhh.hx_horasextras
        WHERE
            dscuil = p_cuil
            AND   cdperiodo = p_periodo;
     dbms_output.put_line('Estado: '    || v_cdestado);
     dbms_output.put_line('cdhora extra: '    || v_cdhoraextra);
        IF
            ( v_cdestado in( 3,6) )
        THEN
            BEGIN



                         /*Ya existe una carga para esa fecha y se debe modificar**/
                SELECT
                    h.cdhoraextradetalle
                INTO
                    v_cdhoraextradetalle
                FROM
                    hx_horasextrasdetalle h
                    INNER JOIN apprrhh.hx_horasextras ON apprrhh.hx_horasextras.cdhoraextra = h.cdhoraextra
                WHERE
                    dscuil = p_cuil
                    AND   cdperiodo = p_periodo
                    AND   dthoraextradetalle = trunc(TO_DATE(p_dtfechaingreso,'DD/MM/RRRR HH24:MI','NLS_DATE_LANGUAGE=SPANISH') )
                    AND   id_horaextra_detalle IN (
                        SELECT
                            MAX(id_horaextra_detalle)
                        FROM
                            hx_horasextrasdetalle h1
                        WHERE
                            h1.cdhoraextradetalle = h.cdhoraextradetalle
                    );

                         /*Se da de baja el detalle existente*/

                INSERT INTO hx_horasextrasdetalle (
                    cdhoraextra,
                    cdhoraextradetalle,
                    dthoraextradetalle,
                    thoradesdelaboral,
                    thorahastalaboral,
                    thoradesdealmuerzo,
                    thorahastaalmuerzo,
                    thoradesdecena,
                    thorahastacena,
                    vlhorassimples,
                    vlhoras50,
                    vlhoras100,
                    vlreintegrocena,
                    cdusuario_trn,
                    dtmodificacion,
                    dtalta,
                    vlreintegroalmuerzo,
                    icbaja,
                    vlhoras100lv,
                    vltotal,
                    ICVALIDO
                )
                    SELECT
                        cdhoraextra,
                        cdhoraextradetalle,
                        dthoraextradetalle,
                        thoradesdelaboral,
                        thorahastalaboral,   
                        thoradesdealmuerzo,
                        thorahastaalmuerzo,
                        thoradesdecena,
                        thorahastacena,
                        vlhorassimples,
                        vlhoras50,
                        vlhoras100,
                        vlreintegrocena,
                        p_cdusuario_trn,
                        SYSDATE,
                        dtalta,
                        vlreintegroalmuerzo,
                        1,
                        vlHORAS100lv,
                        v_totalGeneral,
                    
                   icValido
                    FROM
                        hx_horasextrasdetalle
                    WHERE
                        cdhoraextradetalle = v_cdhoraextradetalle
                        AND   id_horaextra_detalle IN (
                            SELECT
                                MAX(id_horaextra_detalle)
                            FROM
                                hx_horasextrasdetalle
                            WHERE
                                cdhoraextradetalle = v_cdhoraextradetalle
                        );
                        
                                                
                v_icValido:=   Tiene_12hs_descanso(   p_cuil     ,        p_dtFechaIngreso,      p_dtFechaSalida   ) ;
 dbms_output.put_line('modificacion 12 hs descanso: '        ||  v_icValido);
                insert into  hx_detalle 
     select v_cuil,
            to_date(p_dtfechaingreso, 'DD/MM/RRRR HH24:MI:SS'),
            to_date(p_dtfechasalida, 'DD/MM/RRRR HH24:MI:SS'),
            v_dtAsignadoIngreso,
          v_dtAsignadoSalida,         

             v_Limite_100LV_min,
            v_Limite_100LV_maX,
            v_HORAINGRESO,
            v_HORASALIDA,
            TO_NUMBER(SUBSTR(v_HORAINGRESO,0,2))/24,
            TO_NUMBER(SUBSTR(v_HORAINGRESO,4,5))/1440,
            TO_NUMBER(SUBSTR(v_HORASALIDA,0,2))/24,
          v_icValido -- TO_NUMBER(SUBSTR(v_HORASALIDA,4,5))/1440
            
            from dual;
      
                     
                     
                     
                     
                     
                     

                             /*alta modificacion de detalle**/

                INSERT INTO hx_horasextrasdetalle (
                    cdhoraextra,
                    cdhoraextradetalle,
                    dthoraextradetalle,
                    thoradesdelaboral,
                    thorahastalaboral,
                    thoradesdecena,
                    thorahastacena,
                    thoradesdealmuerzo,
                    thorahastaalmuerzo,
                    vlhorassimples,
                    vlhoras50,
                    vlhoras100,
                    vlreintegroalmuerzo,
                    vlreintegrocena,
                    dtalta,
                    cdusuario_trn,
                    icbaja,
                    dtmodificacion,
                    vlHoras100LV,
                    vltotal,
                     ICVALIDO
                ) VALUES (
                    v_cdhoraextra, --cdHoraExtra
                    v_cdhoraextradetalle,
                    trunc(TO_DATE(p_dtfechaingreso,'DD/MM/RRRR HH24:MI','NLS_DATE_LANGUAGE=SPANISH') ),
                    TO_DATE(p_dtfechaingreso,'DD/MM/RRRR HH24:MI','NLS_DATE_LANGUAGE=SPANISH'),
                    TO_DATE(p_dtfechasalida,'DD/MM/RRRR HH24:MI','NLS_DATE_LANGUAGE=SPANISH'),
                        CASE
                            WHEN v_vlcomidas = 2 THEN v_dtcenadesde
                            ELSE NULL
                        END,
                        CASE
                            WHEN v_vlcomidas = 2 THEN v_dtcenahasta
                            ELSE NULL
                        END,
                        CASE
                            WHEN v_vlcomidas >= 1 THEN v_dtalmuerzodesde
                            ELSE NULL
                        END,
                        CASE
                            WHEN v_vlcomidas >= 1 THEN v_dtalmuerzohasta
                            ELSE NULL
                        END,
                    v_vsimples,
                    v_vl50,
                    v_vl100,
                        CASE
                            WHEN v_vlcomidas >= 1 THEN 1
                            ELSE 0
                        END,
                        CASE
                            WHEN v_vlcomidas > 1 THEN 1
                            ELSE 0
                        END,
                    SYSDATE,
                    p_cdusuario_trn,
                    0,
                    SYSDATE,
                     CASE v_vl100_lv when 0 then null else v_vl100_lv end,
                    v_totalGeneral,
                  
                     v_icValido
                    ) RETURNING id_horaextra_detalle INTO v_id_horaextra_detalle;



                OPEN vusercursor FOR SELECT
                     cdhoraextra,
                    cdhoraextradetalle,
                    dthoraextradetalle,
                    thoradesdelaboral,
                    thorahastalaboral,
                    thoradesdecena,
                    thorahastacena,
                    thoradesdealmuerzo,
                    thorahastaalmuerzo,
                    vlhorassimples,
                    vlhoras50,
                   case( nvl(vlhoras100,0) + nvl(vlhoras100lv, 0) )when 0 then null

                   else nvl(vlhoras100,0) + nvl( vlhoras100lv ,0) end vlhoras100,
                    vlreintegroalmuerzo,
                    vlreintegrocena,
                    dtalta,
                    cdusuario_trn,
                    icbaja,
                    dtmodificacion,

                    vltotal
                                     FROM
                    hx_horasextrasdetalle
                                     WHERE
                    id_horaextra_detalle = v_id_horaextra_detalle;

                commit work;
            EXCEPTION
                WHEN no_data_found THEN
                    SELECT
                        CASE
                            WHEN MAX(cdhoraextradetalle) IS NULL THEN 1
                            ELSE MAX(cdhoraextradetalle) + 1
                        END
                    INTO
                        v_cdhoraextradetalle
                    FROM
                        hx_horasextrasdetalle;
                        
              v_icValido:=   Tiene_12hs_descanso(   p_cuil     ,        p_dtFechaIngreso,      p_dtFechaSalida   ) ;
               dbms_output.put_line('nuevo 12 hs descanso: '        ||  v_icValido);
                    INSERT INTO hx_horasextrasdetalle (
                        cdhoraextra,
                        cdhoraextradetalle,
                        dthoraextradetalle,
                        thoradesdelaboral,
                        thorahastalaboral,
                        thoradesdecena,
                        thorahastacena,
                        thoradesdealmuerzo,
                        thorahastaalmuerzo,
                        vlhorassimples,
                        vlhoras50,
                        vlhoras100,
                        vlreintegroalmuerzo,
                        vlreintegrocena,
                        dtalta,
                        cdusuario_trn,
                        icbaja,
                        vlHoras100lv,
                        vltotal,
                        icValido
                    ) VALUES (
                        v_cdhoraextra, --cdHoraExtra
                        v_cdhoraextradetalle,
                        trunc(TO_DATE(p_dtfechaingreso,'DD/MM/RRRR HH24:MI','NLS_DATE_LANGUAGE=SPANISH') ),
                        TO_DATE(p_dtfechaingreso,'DD/MM/RRRR HH24:MI','NLS_DATE_LANGUAGE=SPANISH'),
                        TO_DATE(p_dtfechasalida,'DD/MM/RRRR HH24:MI','NLS_DATE_LANGUAGE=SPANISH'),
                            CASE
                                WHEN v_vlcomidas = 2 THEN v_dtcenadesde
                                ELSE NULL
                            END,
                            CASE
                                WHEN v_vlcomidas = 2 THEN v_dtcenahasta
                                ELSE NULL
                            END,
                            CASE
                                WHEN v_vlcomidas >= 1 THEN v_dtalmuerzodesde
                                ELSE NULL
                            END,
                            CASE
                                WHEN v_vlcomidas >= 1 THEN v_dtalmuerzohasta
                                ELSE NULL
                            END,
                        v_vsimples,
                        v_vl50,
                        v_vl100,
                            CASE
                                WHEN v_vlcomidas >= 1 THEN 1
                                ELSE 0
                            END,
                            CASE
                                WHEN v_vlcomidas > 1 THEN 1
                                ELSE 0
                            END,
                        SYSDATE,
                        p_cdusuario_trn,
                        0,
                        CASE v_vl100_lv when 0 then null else v_vl100_lv end,
                        v_totalGeneral,
                        
                     
                      v_icValido
                    ) RETURNING id_horaextra_detalle INTO v_id_horaextra_detalle;

                    OPEN vusercursor FOR SELECT
                         cdhoraextra,
                    cdhoraextradetalle,
                    dthoraextradetalle,
                    thoradesdelaboral,
                    thorahastalaboral,
                    thoradesdecena,
                    thorahastacena,
                    thoradesdealmuerzo,
                    thorahastaalmuerzo,
                    vlhorassimples,
                    vlhoras50,
                   case( nvl(vlhoras100,0) + nvl(vlhoras100lv, 0) )when 0 then null

                   else nvl(vlhoras100,0) + nvl( vlhoras100lv ,0) end vlhoras100,
                    vlreintegroalmuerzo,
                    vlreintegrocena,
                    dtalta,
                    cdusuario_trn,
                    icbaja,
                    dtmodificacion,

                    vltotal,
                       TO_CHAR(thoradesdelaboral,'RRRR-MM-DD HH24:MI:SS') HORADESDELABORAL,
         TO_CHAR(thorahastalaboral,'RRRR-MM-DD HH24:MI:SS') HORAHASTALABORAL,
         icValido
           
                                         FROM
                        hx_horasextrasdetalle
                                         WHERE
                        id_horaextra_detalle = v_id_horaextra_detalle;
               commit work;
                    NULL;
                    --EXIT;
            END;

        ELSE
          rollback work;
            raise_application_error(-20004,'El periodo de carga de horas extras fue finalizado');

            --EXIT;
        END IF;

    EXCEPTION
        WHEN no_data_found THEN
                /*OBTENGO EL VALOR MAXIMO DE CDHORAEXTRA PARA AGREGAR UN REGISTRO NUEVO EN LA CABECERA*/
            SELECT
                CASE
                    WHEN MAX(cdhoraextra) IS NULL THEN 1
                    ELSE MAX(cdhoraextra) + 1
                END
            INTO
                v_cdhoraextra
            FROM
                apprrhh.hx_horasextras;

            INSERT INTO hx_horasextras (
                cdhoraextra,
                cdperiodo,
                dslegajo,
                dsdocumento,
                dsapellido,
                dsnombre,
                dscuil,
                dsescalafon,
                cdestado,
                dsestructurapagadora,
                dsestructurareal,
                vlremuneraciones,
                vlneto,
                vlsimple,
                vlcomida,
                vl50,
                vl100,
                dtmodificacion,
                cdusuario_trn,
                cod_estructura_real
            ) VALUES (
                v_cdhoraextra,
                p_periodo,
                v_legajo,
                v_dni,
                v_apellido,
                v_nombre,
                v_cuil,
                v_letra
                || ' '
                || v_grado,

                3,
                v_cod_estructura_pagadora,
                v_cod_estructura_real,
                v_vlsueldo_limite,
                v_vlsueldo_horas,
                v_montosimplexhs,
                v_montocomida,
                v_monto50xhs,
                v_monto100xhs,
                NULL,
                p_cdusuario_trn,
                v_cod_estructura_desempenio
            ) RETURNING id_horaextra INTO v_id_horaextra;


             SELECT
                        CASE
                            WHEN MAX(cdhoraextradetalle) IS NULL THEN 1
                            ELSE MAX(cdhoraextradetalle) + 1
                        END
                    INTO
                        v_cdhoraextradetalle
                    FROM
                        hx_horasextrasdetalle;

                           /*alta modificacion de detalle**/
                              v_icValido:=   Tiene_12hs_descanso(   p_cuil     ,        p_dtFechaIngreso,      p_dtFechaSalida   ) ;
 dbms_output.put_line('12 hs descanso: '        ||  v_icValido);
                INSERT INTO hx_horasextrasdetalle (
                    cdhoraextra,
                    cdhoraextradetalle,
                    dthoraextradetalle,
                    thoradesdelaboral,
                    thorahastalaboral,
                    thoradesdecena,
                    thorahastacena,
                    thoradesdealmuerzo,
                    thorahastaalmuerzo,
                    vlhorassimples,
                    vlhoras50,
                    vlhoras100,
                    vlreintegroalmuerzo,
                    vlreintegrocena,
                    dtalta,
                    cdusuario_trn,
                    icbaja,
                    dtmodificacion,
                    vlhoras100lv,
                    vltotal,
                    icValido
                ) VALUES (
                    v_cdhoraextra, --cdHoraExtra
                    v_cdhoraextradetalle,
                    trunc(TO_DATE(p_dtfechaingreso,'DD/MM/RRRR HH24:MI','NLS_DATE_LANGUAGE=SPANISH') ),
                    TO_DATE(p_dtfechaingreso,'DD/MM/RRRR HH24:MI','NLS_DATE_LANGUAGE=SPANISH'),
                    TO_DATE(p_dtfechasalida,'DD/MM/RRRR HH24:MI','NLS_DATE_LANGUAGE=SPANISH'),
                        CASE
                            WHEN v_vlcomidas = 2 THEN v_dtcenadesde
                            ELSE NULL
                        END,
                        CASE
                            WHEN v_vlcomidas = 2 THEN v_dtcenahasta
                            ELSE NULL
                        END,
                        CASE
                            WHEN v_vlcomidas >= 1 THEN v_dtalmuerzodesde
                            ELSE NULL
                        END,
                        CASE
                            WHEN v_vlcomidas >= 1 THEN v_dtalmuerzohasta
                            ELSE NULL
                        END,
                    v_vsimples,
                    v_vl50,
                    v_vl100,
                        CASE
                            WHEN v_vlcomidas >= 1 THEN 1
                            ELSE 0
                        END,
                        CASE
                            WHEN v_vlcomidas > 1 THEN 1
                            ELSE 0
                        END,
                    SYSDATE,
                    p_cdusuario_trn,
                    0,
                    SYSDATE,
                     CASE v_vl100_lv when 0 then null else v_vl100_lv end,
                    v_totalGeneral,
                         v_icValido
                    
                ) RETURNING id_horaextra_detalle INTO v_id_horaextra_detalle;

                OPEN vusercursor FOR SELECT
                 cdhoraextra,
                    cdhoraextradetalle,
                    dthoraextradetalle,
                    thoradesdelaboral,
                    thorahastalaboral,
                    thoradesdecena,
                    thorahastacena,
                    thoradesdealmuerzo,
                    thorahastaalmuerzo,
                    vlhorassimples,
                    vlhoras50,
                   case( nvl(vlhoras100,0) + nvl(vlhoras100lv, 0) )when 0 then null

                   else nvl(vlhoras100,0) + nvl( vlhoras100lv ,0) end vlhoras100,
                    vlreintegroalmuerzo,
                    vlreintegrocena,
                    dtalta,
                    cdusuario_trn,
                    icbaja,
                    dtmodificacion,

                    vltotal, icValido
                                     FROM
                    hx_horasextrasdetalle
                                     WHERE
                    id_horaextra_detalle = v_id_horaextra_detalle;

             commit work;

    END;



    CLOSE resultset;
   end;



OPEN vusercursor FOR SELECT
     cdhoraextra,
                    cdhoraextradetalle,
                    dthoraextradetalle,
                    thoradesdelaboral,
                    thorahastalaboral,
                    thoradesdecena,
                    thorahastacena,
                    thoradesdealmuerzo,
                    thorahastaalmuerzo,
                    vlhorassimples,
                    vlhoras50,
                   case( nvl(vlhoras100,0) + nvl(vlhoras100lv, 0) )when 0 then null

                   else nvl(vlhoras100,0) + nvl( vlhoras100lv ,0) end vlhoras100,
                    vlreintegroalmuerzo,
                    vlreintegrocena,
                    dtalta,
                    cdusuario_trn,
                    icbaja,
                    dtmodificacion,

                    vltotal,
                       TO_CHAR(thoradesdelaboral,'RRRR-MM-DD HH24:MI:SS') HORADESDELABORAL,
         TO_CHAR(thorahastalaboral,'RRRR-MM-DD HH24:MI:SS') HORAHASTALABORAL,
         icValido
           
                     FROM
    hx_horasextrasdetalle
                     WHERE
    id_horaextra_detalle = v_id_horaextra_detalle;


NULL;

  END HORASEXTRAS_I;
PROCEDURE HORASEXTRASDETALLE_D (
      p_cdHoraExtraDetalle     IN       HX_HORASEXTRASDETALLE.cdHoraExtraDetalle%TYPE,      
      p_CDUSUARIO_TRN in int,
           ID_HORAEXTRADETALLE   OUT      HX_HORASEXTRASDETALLE.ID_HORAEXTRA_DETALLE%TYPE
   ) AS
   BEGIN
      INSERT INTO hx_horasextrasdetalle (
                            cdhoraextra,
                            cdhoraextradetalle,
                            dthoraextradetalle,
                            thoradesdelaboral,
                            thorahastalaboral,
                            thoradesdealmuerzo,
                            thorahastaalmuerzo,
                            thoradesdecena,
                            thorahastacena,
                            vlhorassimples,
                            vlhoras50,
                            vlhoras100,
                            vlreintegrocena,
                            cdusuario_trn,
                            dtmodificacion,
                            dtalta,
                            vlreintegroalmuerzo,
                            icbaja,
                             vlhoras100lv
                        )
                            SELECT
                                cdhoraextra,
                                cdhoraextradetalle,
                                dthoraextradetalle,
                                thoradesdelaboral,
                                thorahastalaboral,
                                thoradesdealmuerzo,
                                thorahastaalmuerzo,
                                thoradesdecena,
                                thorahastacena,
                                vlhorassimples,
                                vlhoras50,
                                vlhoras100,
                                vlreintegrocena,
                                p_cdusuario_trn,
                                SYSDATE,
                                dtalta,
                                vlreintegroalmuerzo,
                                1,
                                vlhoras100lv
                            FROM
                                hx_horasextrasdetalle
                            WHERE
                                cdhoraextradetalle = p_cdHoraExtraDetalle
                                AND   id_horaextra_detalle IN (
                                    SELECT
                                        MAX(id_horaextra_detalle)
                                    FROM
                                        hx_horasextrasdetalle
                                    WHERE
                                        cdhoraextradetalle = p_cdHoraExtraDetalle
                                );
   END HORASEXTRASDETALLE_D;
PROCEDURE HORASEXTRASDETALLE_porCUIL (
        p_periodo     IN       HX_HORASEXTRAS.CDPERIODO%TYPE,  
        p_cuil        in       HX_HORASEXTRAS.DSCUIL%TYPE,  
        vusercursor   OUT      vcursor
   ) as  

   BEGIN
     OPEN vusercursor FOR 
     SELECT  cdHORAEXTRADETALLE,
        DTHORAEXTRADETALLE,
       TO_CHAR(thoradesdelaboral,'HH24:MI') THORADESDELABORAL,
       TO_CHAR(thorahastalaboral,'HH24:MI') THORAHASTALABORAL,
       CASE NVL(TO_CHAR(thoradesdealmuerzo,'HH24:MM'),'')  || ' a ' ||  NVL(TO_CHAR(thorahastaalmuerzo,'HH24:MI'),'')
           when ' a ' then ''
           else   NVL(TO_CHAR(D.thoradesdealmuerzo,'HH24:MI'),'')  || ' a ' ||  NVL(TO_CHAR(thorahastaalmuerzo,'HH24:MI'),'')   end THORAALMUERZO,
          CASE NVL(TO_CHAR(thoradesdecena,'HH24:MM'),'')  || ' a ' ||  NVL(TO_CHAR(thorahastacena,'HH24:MI'),'')
           when ' a ' then ''
           else   NVL(TO_CHAR(thoradesdecena,'HH24:MI'),'')  || ' a ' ||  NVL(TO_CHAR(thorahastacena,'HH24:MI'),'')   end THORACENA,
           d.vlhorassimples ,
           d.vlhoras50 ,
          nvl( d.VLHORAS100,0) + nvl(d.vlhoras100lv ,0) VLHORAS100,
          vlreintegroalmuerzo ,
          vlreintegrocena ,
          nvl(vlreintegroalmuerzo,0) + nvl(vlreintegrocena,0)  totalcomidad,
          vltotal,
          TO_CHAR(thoradesdelaboral,'RRRR-MM-DD HH24:MI:SS') HORADESDELABORAL,
         TO_CHAR(thorahastalaboral,'RRRR-MM-DD HH24:MI:SS') HORAHASTALABORAL,
         icValido
           

   FROM apprrhh.HX_HORASEXTRAS H
        inner join apprrhh.HX_HORASEXTRASDETALLE D ON H.CDHORAEXTRA=D.CDHORAEXTRA 
                                                        AND id_horaextra_detalle IN (SELECT MAX(id_horaextra_detalle) FROM  apprrhh.HX_HORASEXTRASDETALLE  GROUP BY  CDHORAEXTRADETALLE )

        WHERE H.CDHORAEXTRA=D.CDHORAEXTRA AND ICBAJA=0
        AND H.DSCUIL=p_cuil
        AND H.CDPERIODO=p_periodo
        order by  dthoraextradetalle asc;



END HORASEXTRASDETALLE_porCUIL;   
PROCEDURE HORASEXTRA_TotalesporPeriodo (
        p_periodo     IN       HX_HORASEXTRAS.CDPERIODO%TYPE,  
        p_cuil        in       HX_HORASEXTRAS.DSCUIL%TYPE,  
        vusercursor   OUT      vcursor
   )as
   BEGIN
       OPEN vusercursor FOR 
     SELECT h.cdperiodo,
            sum( d.vlhorassimples) Cant_HorasSimples ,
            sum( d.vlhorassimples * h.VLSIMPLE) vlMonto_HorasSimples ,
            sum(d.vlhoras50  ) Cant_Horas50,
            sum(d.vlhoras50 * h.VL50 ) vlmonto_Horas50,
            sum(nvl(d.VLHORAS100 ,0) ) +   sum(nvl(vlhoras100lv,0)) Cant_Horas100 ,
            sum(nvl(d.VLHORAS100 ,0)   * h.VL100) +  sum(nvl(d.VLHORAS100LV ,0)   * h.VL100)  vlmonto_Horas100 ,
            sum((nvl(vlreintegroalmuerzo,0) + nvl(vlreintegrocena,0)) ) Cant_comidas,
            sum((nvl(vlreintegroalmuerzo,0) + nvl(vlreintegrocena,0)) * vlcomida ) vlmonto_comidas,
            sum(nvl(vltotalsimples,0)) CantTotalhssimple,
              sum(nvl(vltotalsimples,0) *  h.VLSIMPLE ) vlTotalhssimple
          --  sum(nvl(vlhoras100lv,0) )Cant_Horas100LV

   FROM apprrhh.HX_HORASEXTRAS H
        inner join apprrhh.HX_HORASEXTRASDETALLE D ON H.CDHORAEXTRA=D.CDHORAEXTRA AND id_horaextra_detalle IN (SELECT MAX(id_horaextra_detalle) FROM  apprrhh.HX_HORASEXTRASDETALLE  GROUP BY  CDHORAEXTRADETALLE )
        WHERE H.CDHORAEXTRA=D.CDHORAEXTRA AND ICBAJA=0
        AND H.DSCUIL=p_cuil
        AND H.CDPERIODO=p_periodo
        group by cdPeriodo 
                order by  cdperiodo asc;

   end HORASEXTRA_TotalesporPeriodo;
PROCEDURE HORAEXTRA_CUIL(
  p_cuil in HX_HORASEXTRAS.DSCUIL%TYPE,  
  vusercursor OUT vcursor) 
 AS

     begin


      
       
     OPEN vusercursor FOR
     
      select cdperiodo,
            cdEstado,
            estado,
            descripcion,
            dtmovimiento,
            horario, nombre
     from (
     select to_number( to_char(sysdate,'RRRRMM') ) cdperiodo, 
              3 cdEstado,
              'CARGA' Estado,
              '' descripcion,
              null dtmovimiento,
              hr.horario,
              ee.Nombre || ' ' || ee.APELLIDO AS Nombre
       from dual,
         (  select distinct cuil,
                                    TO_CHAR(hr.dtingreso, 'RRRRMM') periodo ,
                                LISTAGG( TO_CHAR(hr.dtingreso, 'DD/MM/RRRR') || ' al ' || TO_CHAR(hr.dtsalida, 'DD/MM/RRRR') ||' de ' || TO_CHAR(hr.dtingreso, 'HH24:MI') || ' a ' || TO_CHAR(hr.dtsalida, 'HH24:MI') , '; ')
                      WITHIN GROUP (ORDER BY hr.dtingreso ) over (partition by  hr.cuil,TO_CHAR(hr.dtingreso, 'RRRRMM') ) Horario
                      
                      from HX_HRIO_EMPLEADO hr 
                      where hr.ID_HRIO_EMPLEADO in (select max(ID_HRIO_EMPLEADO) from HX_HRIO_EMPLEADO group by HX_HRIO_EMPLEADO.CUIL,HX_HRIO_EMPLEADO.dtingreso) 
                      and hr.icbaja=0 ) hr 
          left join     HX_HORASEXTRAS HE on he.dscuil= hr.cuil and he.cdperiodo=  TO_CHAR(SYSDATE,'RRRRMM')     
          inner join sarha.empleado ee on ee.cuil=hr.cuil
         where hr.cuil = p_cuil AND periodo=TO_CHAR(SYSDATE,'RRRRMM')
            and he.CDHORAEXTRA is null
        
         
         UNION 
       SELECT HE.cdperiodo, 
                HE.CDESTADO,
                D.DSTCADETALLE ESTADO,
                NVL(M.DESCRIPCION,'')DESCRIPCION,
             M.DTMOVIMIENTO,
                HR.HORARIO,
                
                      ee.Nombre || ' ' || ee.APELLIDO as Nombre
         FROM HX_HORASEXTRAS HE
           inner join sarha.empleado ee on ee.cuil=he.dscuil
         LEFT JOIN HX_MOVIMIENTOS M ON HE.CDHORAEXTRA= M.CDHORAEXTRA   AND ID_MOVIMIENTO IN (SELECT MAX(ID_MOVIMIENTO) FROM HX_MOVIMIENTOS GROUP BY CDHORAEXTRA)
         LEFT JOIN HX_TCA_DETALLE D ON D.CDTCADETALLE=HE.CDESTADO AND ID_TCA_DETALLE IN(SELECT MAX(ID_TCA_DETALLE) FROM HX_TCA_DETALLE GROUP BY  CDTCADETALLE) AND D.ICBAJA=0
         LEFT JOIN  (  select distinct cuil, 
                                    TO_CHAR(hr.dtingreso, 'RRRRMM') periodo ,
                                LISTAGG( TO_CHAR(hr.dtingreso, 'DD/MM/RRRR') || ' al ' || TO_CHAR(hr.dtsalida, 'DD/MM/RRRR') ||' de ' || TO_CHAR(hr.dtingreso, 'HH24:MI') || ' a ' || TO_CHAR(hr.dtsalida, 'HH24:MI') , '; ')
                      WITHIN GROUP (ORDER BY hr.dtingreso ) over (partition by  hr.cuil,TO_CHAR(hr.dtingreso, 'RRRRMM') ) Horario
                      from HX_HRIO_EMPLEADO hr 
                      where hr.ID_HRIO_EMPLEADO in (select max(ID_HRIO_EMPLEADO) from HX_HRIO_EMPLEADO group by HX_HRIO_EMPLEADO.CUIL,HX_HRIO_EMPLEADO.dtingreso) 
                      and hr.icbaja=0 ) hr  ON HR.CUIL=HE.DSCUIL AND HR.PERIODO=HE.CDPERIODO
         WHERE HE.ID_HORAEXTRA IN (SELECT MAX(ID_HORAEXTRA) FROM HX_HORASEXTRAS GROUP BY CDHORAEXTRA,DSCUIL,CDPERIODO )
       AND HE.DSCUIL=P_CUIL
           order by cdperiodo desc)
       where     ROWNUM<= 3
   ;
   
       
       
      
      end HORAEXTRA_CUIL;
      

      
      
 PROCEDURE HORAEXTRA_PENDIENTES(
     p_dependencia        in       HX_HORASEXTRAS.COD_ESTRUCTURA_REAL%TYPE, 
     p_periodo in    HX_HORASEXTRAS.CDPERIODO%TYPE,
     vusercursor   OUT      vcursor,
     registros out number)
      is
      begin

          SELECT COUNT(*)
          INTO registros
   FROM(      
       SELECT      H.DSCUIL,
                   H.DSAPELLIDO,
                   H.DSNOMBRE,       
                   H.CDPERIODO

                    FROM apprrhh.HX_HORASEXTRAS H
                    left join apprrhh.HX_HORASEXTRASDETALLE D ON H.CDHORAEXTRA=D.CDHORAEXTRA   AND d.ID_HORAEXTRA_DETALLE IN (SELECT MAX(ID_HORAEXTRA_DETALLE) FROM apprrhh.HX_HORASEXTRASDETALLE GROUP BY CDHORAEXTRADETALLE  ) and d.icbaja=0 
                    WHERE H.ID_HORAEXTRA IN (SELECT MAX(ID_HORAEXTRA) FROM apprrhh.HX_HORASEXTRAS GROUP BY CDHORAEXTRA  ) 
                   AND CDESTADO in(4,10)
                   --- and ((CDESTADO = 4     AND H.COD_ESTRUCTURA_REAL=p_dependencia ) 
                      --- or (CDESTADO=10 and H.COD_ESTRUCTURA_REAL in (select COD_ESTRUCTURA_REAL from  sarha.estructura_real where COD_ESTRUCTURA_DEPENDIENTE =p_dependencia )) )
                   AND (H.COD_ESTRUCTURA_REAL=p_dependencia  or ( H.COD_ESTRUCTURA_REAL in (select COD_ESTRUCTURA_REAL from  sarha.estructura_real where COD_ESTRUCTURA_DEPENDIENTE =p_dependencia )))
                    and h.cdperiodo=p_periodo
                      GROUP BY   H.DSCUIL,
       H.DSAPELLIDO,
       H.DSNOMBRE,  
        H.CDPERIODO);




      OPEN vusercursor FOR

       SELECT
       H.DSCUIL,
       H.DSAPELLIDO,
       H.DSNOMBRE,       
        H.CDPERIODO,
                         SUM(nvl(vlhorassimples ,0))Cant_simples,
                        sum(nvl(vlhoras50 ,0)) Cant_al50,
                        sum(nvl(vlhoras100 ,0)) Cant_al100,
                        sum((nvl(vlreintegroalmuerzo,0)+nvl(vlreintegrocena,0)) )Cant_comida
                        ,SUM(nvl(vlhorassimples ,0)* nvl(h.vlSimple,0)) SIMPLES
                        ,sum( (nvl(vlhoras50,0)*nvl(h.vl50,0)) ) AL50
                        ,sum( (nvl(vlhoras100,0)*nvl(vl100,0))) + sum( (nvl(vlhoras100lv,0)*nvl(vl100,0)))   AL100
                        ,SUM(nvl(vlcomida,0)*(nvl(vlreintegroalmuerzo,0)+nvl(vlreintegrocena,0))) COMIDA
                        ,SUM(nvl(vlhorassimples ,0)* nvl(h.vlSimple,0)) + sum( (nvl(vlhoras50,0)*nvl(h.vl50,0)) ) + sum( (nvl(vlhoras100,0)*nvl(vl100,0))) +SUM(nvl(vlcomida,0)*(nvl(vlreintegroalmuerzo,0)+nvl(vlreintegrocena,0)))  + sum( (nvl(vlhoras100lv,0)*nvl(vl100,0)))   vlMontoUtilizado,
                        decode(CDESTADO,10,'Visto','') dsVisto,
                        decode(CDESTADO,10,'VISTO',4,'PENDIENTE','')  ESTADO
                    FROM apprrhh.HX_HORASEXTRAS H
                    left join apprrhh.HX_HORASEXTRASDETALLE D ON H.CDHORAEXTRA=D.CDHORAEXTRA   AND d.ID_HORAEXTRA_DETALLE IN (SELECT MAX(ID_HORAEXTRA_DETALLE) FROM apprrhh.HX_HORASEXTRASDETALLE GROUP BY CDHORAEXTRADETALLE  ) and d.icbaja=0 
                    WHERE H.ID_HORAEXTRA IN (SELECT MAX(ID_HORAEXTRA) FROM apprrhh.HX_HORASEXTRAS GROUP BY CDHORAEXTRA  ) 
                    AND CDESTADO in(4,10)
                   --- and ((CDESTADO = 4     AND H.COD_ESTRUCTURA_REAL=p_dependencia ) 
                      --- or (CDESTADO=10 and H.COD_ESTRUCTURA_REAL in (select COD_ESTRUCTURA_REAL from  sarha.estructura_real where COD_ESTRUCTURA_DEPENDIENTE =p_dependencia )) )
                   AND (H.COD_ESTRUCTURA_REAL=p_dependencia  or ( H.COD_ESTRUCTURA_REAL in (select COD_ESTRUCTURA_REAL from  sarha.estructura_real where COD_ESTRUCTURA_DEPENDIENTE =p_dependencia )))
                   and h.cdperiodo=p_periodo
                    GROUP BY   H.DSCUIL,
       H.DSAPELLIDO,
       H.DSNOMBRE,  
        H.CDPERIODO,CDESTADO
        ORDER BY CDPERIODO ASC, DSAPELLIDO ASC;

      NULL;
      END HORAEXTRA_PENDIENTES;
      
      
      
      
    PROCEDURE HORAEXTRA_PENDIENTES_VISADO(
     p_dependencia        in       HX_HORASEXTRAS.COD_ESTRUCTURA_REAL%TYPE,
       p_periodo in    HX_HORASEXTRAS.CDPERIODO%TYPE ,
     p_estado in int,
     vusercursor   OUT      vcursor,
     registros out number)
      AS
      v_cdestado    INT;
      begin
      
       if (p_estado = 0) then
          v_cdestado := 4;
      else
          v_cdestado := 10;
      end if;
      
      

          SELECT COUNT(*)
          INTO registros
   FROM(      
       SELECT      H.DSCUIL,
                   H.DSAPELLIDO,
                   H.DSNOMBRE,       
                   H.CDPERIODO

                    FROM apprrhh.HX_HORASEXTRAS H
                    left join apprrhh.HX_HORASEXTRASDETALLE D ON H.CDHORAEXTRA=D.CDHORAEXTRA   AND d.ID_HORAEXTRA_DETALLE IN (SELECT MAX(ID_HORAEXTRA_DETALLE) FROM apprrhh.HX_HORASEXTRASDETALLE GROUP BY CDHORAEXTRADETALLE  ) and d.icbaja=0 
                    WHERE H.ID_HORAEXTRA IN (SELECT MAX(ID_HORAEXTRA) FROM apprrhh.HX_HORASEXTRAS GROUP BY CDHORAEXTRA  ) 
                    and CDESTADO = v_cdestado
                   and ((v_cdestado = 4     AND H.COD_ESTRUCTURA_REAL=p_dependencia ) 
                       or (v_cdestado=10 and H.COD_ESTRUCTURA_REAL in (select COD_ESTRUCTURA_REAL from  sarha.estructura_real where COD_ESTRUCTURA_DEPENDIENTE =p_dependencia )) )
                   --AND CDESTADO in (4,10)
                  -- and CDESTADO = v_cdestado
                  --  AND H.COD_ESTRUCTURA_REAL=p_dependencia
                   and h.cdperiodo=p_periodo
                      GROUP BY   H.DSCUIL,
       H.DSAPELLIDO,
       H.DSNOMBRE,  
        H.CDPERIODO);




      OPEN vusercursor FOR

       SELECT
       H.DSCUIL,
       H.DSAPELLIDO,
       H.DSNOMBRE,       
        H.CDPERIODO,
                         SUM(nvl(vlhorassimples ,0))Cant_simples,
                        sum(nvl(vlhoras50 ,0)) Cant_al50,
                        sum(nvl(vlhoras100 ,0)) Cant_al100,
                        sum((nvl(vlreintegroalmuerzo,0)+nvl(vlreintegrocena,0)) )Cant_comida
                        ,SUM(nvl(vlhorassimples ,0)* nvl(h.vlSimple,0)) SIMPLES
                        ,sum( (nvl(vlhoras50,0)*nvl(h.vl50,0)) ) AL50
                        ,sum( (nvl(vlhoras100,0)*nvl(vl100,0))) + sum( (nvl(vlhoras100lv,0)*nvl(vl100,0)))   AL100
                        ,SUM(nvl(vlcomida,0)*(nvl(vlreintegroalmuerzo,0)+nvl(vlreintegrocena,0))) COMIDA
                        ,SUM(nvl(vlhorassimples ,0)* nvl(h.vlSimple,0)) + sum( (nvl(vlhoras50,0)*nvl(h.vl50,0)) ) + sum( (nvl(vlhoras100,0)*nvl(vl100,0))) +SUM(nvl(vlcomida,0)*(nvl(vlreintegroalmuerzo,0)+nvl(vlreintegrocena,0)))  + sum( (nvl(vlhoras100lv,0)*nvl(vl100,0)))   vlMontoUtilizado,
                        decode(CDESTADO,10,'Visto','') dsVisto,
                         decode(CDESTADO,10,'VISTO',4,'PENDIENTE','')  ESTADO
                    FROM apprrhh.HX_HORASEXTRAS H
                    left join apprrhh.HX_HORASEXTRASDETALLE D ON H.CDHORAEXTRA=D.CDHORAEXTRA   AND d.ID_HORAEXTRA_DETALLE IN (SELECT MAX(ID_HORAEXTRA_DETALLE) FROM apprrhh.HX_HORASEXTRASDETALLE GROUP BY CDHORAEXTRADETALLE  ) and d.icbaja=0 
                    WHERE H.ID_HORAEXTRA IN (SELECT MAX(ID_HORAEXTRA) FROM apprrhh.HX_HORASEXTRAS GROUP BY CDHORAEXTRA  ) 
                    and CDESTADO = v_cdestado
                    and ((v_cdestado = 4     AND H.COD_ESTRUCTURA_REAL=p_dependencia ) 
                       or (v_cdestado=10 and H.COD_ESTRUCTURA_REAL in (select COD_ESTRUCTURA_REAL from  sarha.estructura_real where COD_ESTRUCTURA_DEPENDIENTE =p_dependencia )) )
                     and h.cdperiodo=p_periodo   
                   --AND CDESTADO in (4,10)
                  -- and CDESTADO = v_cdestado
                  --  AND H.COD_ESTRUCTURA_REAL=p_dependencia
                    GROUP BY   H.DSCUIL,
       H.DSAPELLIDO,
       H.DSNOMBRE,  
        H.CDPERIODO,CDESTADO
        ORDER BY CDPERIODO ASC, DSAPELLIDO ASC;

      NULL;
      END HORAEXTRA_PENDIENTES_VISADO;
 
   PROCEDURE POR_DEPENDENCIA_ESTADO(
    p_dependencia IN sarha.estructura_real.cod_estructura_real%TYPE,     
       p_periodo in int,
    vusercursor   OUT      vcursor
   )  AS
  BEGIN

                      OPEN      vusercursor   FOR                            
                       
               SELECT                              
                        DISTINCT 
                        E.cuil,
                        e.apellido,
                        e.nombre,        
                        NVL(Consumo.vlMontoUtilizado,0) vlMontoActual,
                        NVL(ConsumoAnt.vlMontoUtilizado,0) vlMontoAnt
     
                       , NVL((SELECT 
                       DECODE (cdEstado, 3, 'CARGA', 
                             4, 'PENDIENTE', 
                             5, 'APROBADO', 
                             6, 'DESAPROBADO',
                             8,  'IMPRESO',
                             10,'VISTO')  ESTADO from HX_HORASEXTRAS where  dscuil= e.CUIL and CDPERIODO= p_periodo --- to_char(Sysdate,'yyyymm') 
                                ),'SIN CARGAR') Estado
                    , (  SELECT 
                       DECODE (cdEstado, 3, 'CARGA', 
                             4, 'PENDIENTE', 
                             5, 'APROBADO', 
                             6, 'DESAPROBADO',
                             8,  'IMPRESO',
                             10,'VISTO')  ESTADOant from HX_HORASEXTRAS where  dscuil= E.cuil and CDPERIODO= to_char(add_months( to_date(p_periodo,'yyyymm'),-1),'yyyymm')--to_char( to_date(p_periodo,'yyyymm') -30,'yyyymm')
                             
                             ) EstadoAnt,
                             
                             p_periodo PeriodoActual,
                             to_char(add_months( to_date(p_periodo,'yyyymm'),-1),'yyyymm') PeriodoAnterior
                           --  to_char( to_date(p_periodo,'yyyymm') -30,'yyyymm') PeriodoAnterior
                     
                            
                             
                         FROM  sarha.empleado e
                        LEFT JOIN  (SELECT  ID_HRIO_EMPLEADO,e1.CDHRIO_EMPLEADO,E1.CUIL, TO_CHAR(e1.DTINGRESO,'HH24:MI' )HORAINGRESO,TO_CHAR(e1.DTSALIDA,'HH24:mi' )HORASALIDA,
                        TO_CHAR(e1.DTINGRESO,'DD/MM/RRRR' )dtVigenciaDesde,TO_CHAR(e1.DTSALIDA,'DD/MM/RRRR' )dtVigenciaHasta ,to_char(e1.DTSALIDA,'RRRRMM') periodo
                        FROM apprrhh.HX_HRIO_EMPLEADO  e1
                        WHERE  e1.ID_HRIO_EMPLEADO IN( SELECT MAX(ID_HRIO_EMPLEADO) ID_HRIO_EMPLEADO  FROM apprrhh.HX_HRIO_EMPLEADO  em group by em.CUIL)   --group by em.CUIL,TO_CHAR(em.DTINGRESO,'RRRRMM'))
                        AND   e1.ICBAJA=0 
                        ORDER BY ID_HRIO_EMPLEADO DESC)  hse ON  hse.CUIL = e.cuil and periodo= p_periodo-- to_char(sysdate,'RRRRMM')
                        INNER JOIN sarha.asignacion a ON e.cuil = a.cuil  AND fecha_fin IS NULL
                        INNER JOIN sarha.estructura_real r ON r.cod_estructura_real = a.cod_estructura_real
                        INNER JOIN sarha.estructura_real d ON d.cod_estructura_real = a.cod_estructura_desempenio
                        INNER JOIN sarha.estructura_real p ON p.cod_estructura_real = a.cod_estructura_pagadora
                        INNER JOIN sarha.convenio c ON c.cod_convenio = a.cod_convenio
                        INNER JOIN sarha.escalafon es ON es.cod_escalafon = a.cod_escalafon AND es.cod_convenio = a.cod_convenio
                        
                        left join  (
                         SELECT                         
                         DISTINCT H.DSCUIL,
                         SUM(nvl(vlhorassimples ,0))Cant_simples,
                         sum(nvl(vlhoras50 ,0)) Cant_al50,
                         sum(nvl(vlhoras100 ,0)) Cant_al100,
                         sum((nvl(vlreintegroalmuerzo,0)+nvl(vlreintegrocena,0)) )Cant_comida
                        ,SUM(nvl(vlhorassimples ,0)* nvl(h.vlSimple,0)) SIMPLES
                        ,sum( (nvl(vlhoras50,0)*nvl(h.vl50,0)) ) AL50
                      ,sum( (nvl(vlhoras100,0)*nvl(vl100,0)) + (nvl(d.vlHoras100,0) * h.vl100) ) AL100
                      --  ,sum( (nvl(vlhoras100,0)*nvl(vl100,0))) AL100
                        ,SUM(nvl(vlcomida,0)*(nvl(vlreintegroalmuerzo,0)+nvl(vlreintegrocena,0))) COMIDA
                        ,SUM(nvl(vlhorassimples ,0)* nvl(h.vlSimple,0)) + sum( (nvl(vlhoras50,0)*nvl(h.vl50,0)) ) + sum( (nvl(vlhoras100,0)*nvl(vl100,0))) +SUM(nvl(vlcomida,0)*(nvl(vlreintegroalmuerzo,0)+nvl(vlreintegrocena,0)))   vlMontoUtilizado
                      
                        FROM apprrhh.HX_HORASEXTRAS H
                        left join apprrhh.HX_HORASEXTRASDETALLE D ON H.CDHORAEXTRA=D.CDHORAEXTRA   AND d.ID_HORAEXTRA_DETALLE IN (SELECT MAX(ID_HORAEXTRA_DETALLE) FROM apprrhh.HX_HORASEXTRASDETALLE GROUP BY CDHORAEXTRADETALLE  ) and d.icbaja=0 
                        INNER JOIN sarha.estructura_real r ON r.cod_estructura_real = h.cod_estructura_real 
                        WHERE H.ID_HORAEXTRA IN (SELECT MAX(ID_HORAEXTRA) FROM apprrhh.HX_HORASEXTRAS  GROUP BY CDHORAEXTRA  ) 
                         and cdperiodo =p_periodo-- in(select max (h.cdperiodo) from HX_HORASEXTRAS h )
                         GROUP BY   DSCUIL 
                       ) Consumo on Consumo.dscuil=e.cuil         
                       
                        left join  (
                         SELECT                         
                         DISTINCT H.DSCUIL,
                         SUM(nvl(vlhorassimples ,0))Cant_simples,
                         sum(nvl(vlhoras50 ,0)) Cant_al50,
                         sum(nvl(vlhoras100 ,0)) Cant_al100,
                         sum((nvl(vlreintegroalmuerzo,0)+nvl(vlreintegrocena,0)) )Cant_comida
                        ,SUM(nvl(vlhorassimples ,0)* nvl(h.vlSimple,0)) SIMPLES
                        ,sum( (nvl(vlhoras50,0)*nvl(h.vl50,0)) ) AL50
                       ,sum( (nvl(vlhoras100,0)*nvl(vl100,0)) + (nvl(d.vlHoras100,0) * h.vl100) ) AL100
                      
                        --,sum( (nvl(vlhoras100,0)*nvl(vl100,0))) AL100
                        ,SUM(nvl(vlcomida,0)*(nvl(vlreintegroalmuerzo,0)+nvl(vlreintegrocena,0))) COMIDA
                        ,SUM(nvl(vlhorassimples ,0)* nvl(h.vlSimple,0)) + sum( (nvl(vlhoras50,0)*nvl(h.vl50,0)) ) + sum( (nvl(vlhoras100,0)*nvl(vl100,0))) +SUM(nvl(vlcomida,0)*(nvl(vlreintegroalmuerzo,0)+nvl(vlreintegrocena,0)))   vlMontoUtilizado
              
                        FROM apprrhh.HX_HORASEXTRAS H
                        left join apprrhh.HX_HORASEXTRASDETALLE D ON H.CDHORAEXTRA=D.CDHORAEXTRA   AND d.ID_HORAEXTRA_DETALLE IN (SELECT MAX(ID_HORAEXTRA_DETALLE) FROM apprrhh.HX_HORASEXTRASDETALLE GROUP BY CDHORAEXTRADETALLE  ) and d.icbaja=0 
                        INNER JOIN sarha.estructura_real r ON r.cod_estructura_real = h.cod_estructura_real 
                        WHERE H.ID_HORAEXTRA IN (SELECT MAX(ID_HORAEXTRA) FROM apprrhh.HX_HORASEXTRAS  GROUP BY CDHORAEXTRA  ) 
                        and H.cdperiodo =   to_char(add_months( to_date(p_periodo,'yyyymm'),-1),'yyyymm')
                        --to_char( to_date(p_periodo,'yyyymm') -30,'yyyymm')  ---to_char( Sysdate -30,'yyyymm')
                         GROUP BY   DSCUIL 
                       ) ConsumoAnt on ConsumoAnt.dscuil=e.cuil        
                         
                        INNER JOIN sueldos ON sueldos.cuil = e.cuil,
                        (
                            SELECT
                            vltcadetalle AS limite_sueldo_he
                            FROM
                            apprrhh.hx_tca_detalle d
                            INNER JOIN apprrhh.hx_tca t ON t.cdtca = d.cdtca
                            WHERE
                            dstca = 'LIMITE_SUELDO_HE'
                            AND   id_tca_detalle IN (
                                SELECT
                                    MAX(id_tca_detalle) AS id_tca_detalle
                             FROM
                                    apprrhh.hx_tca_detalle
                                GROUP BY
                                    cdtcadetalle
                            )
                    ) limite,
                    (
                        SELECT
                           vltcadetalle AS valor_ur
                     FROM
                            apprrhh.hx_tca_detalle d
                            INNER JOIN apprrhh.hx_tca t ON t.cdtca = d.cdtca
                     WHERE
                            dstca = 'VALOR_UR'
                            AND   id_tca_detalle IN (
                                SELECT
                                    MAX(id_tca_detalle) AS id_tca_detalle
                              FROM
                                   apprrhh.hx_tca_detalle
                               GROUP BY
                                   cdtcadetalle
                         )
                    ) vlur,
                    (
                      SELECT
                         vltcadetalle AS reintegro_comida
                        FROM
                            apprrhh.hx_tca_detalle d
                            INNER JOIN apprrhh.hx_tca t ON t.cdtca = d.cdtca
                     WHERE
                           dstca = 'REINTEGRO_COMIDA'
                           AND   id_tca_detalle IN (
                               SELECT
                                   MAX(id_tca_detalle) AS id_tca_detalle
                               FROM
                                   apprrhh.hx_tca_detalle
                               GROUP BY
                                  cdtcadetalle
                           )
                 ) vlreintegro_comida
 

                WHERE
                    
                    CAST(valor_ur * sueldos.vlsueldo_limite AS DECIMAL(18,2) ) <= limite_sueldo_he
                    and cod_estructura_desempenio=p_dependencia;
                 
                          


  end POR_DEPENDENCIA_ESTADO;     
  FUNCTION Tiene_12hs_descanso(p_cuil IN  HX_HORASEXTRAS.DSCUIL%TYPE, 
                                 p_fechaingreso in varchar2,
                                 p_fechasalida in varchar2) 
   RETURN SMALLINT as 
   v_bool smallint ;
  
   BEGIN
    v_bool:=0;
   
    -- TAREA: Se necesita implantaci�n para FUNCTION PRUEBA_HORASEXTRAS.Es_Ultimo_dia_Habil
      select 
    
     count(*)
         
     into v_bool
FROM apprrhh.HX_HORASEXTRAS H
        inner join apprrhh.HX_HORASEXTRASDETALLE D ON H.CDHORAEXTRA=D.CDHORAEXTRA 
                                                        AND id_horaextra_detalle IN (SELECT MAX(id_horaextra_detalle) FROM  apprrhh.HX_HORASEXTRASDETALLE  GROUP BY  CDHORAEXTRADETALLE )
    
    where 
     nvl(icbaja,0)=0
   and (d.dthoraextradetalle between trunc( TO_DATE(p_fechaingreso,'DD/MM/RRRR HH24:MI:SS')) - 1 and trunc(TO_DATE(p_fechasalida,'DD/MM/RRRR HH24:MI:SS')) + 1 )

  and( ( (   TO_DATE(p_fechaingreso,'DD/MM/RRRR HH24:MI:SS')  - thorahastalaboral
          
    
               ) * 24  < 12
               
           and   (   TO_DATE(p_fechaingreso,'DD/MM/RRRR HH24:MI:SS')  - thorahastalaboral
             
    
               ) * 24  >0  )
    
    or  ( (  thoradesdelaboral - TO_DATE(p_fechasalida,'DD/MM/RRRR HH24:MI:SS') 
           
                
                ) * 24  < 12
      and    (  thoradesdelaboral - TO_DATE(p_fechasalida,'DD/MM/RRRR HH24:MI:SS') 
            
                
                ) * 24  > 0      ) 
    
    )



 -- and  h.cdperiodo=to_char(TO_DATE(p_fechaingreso,'DD/MM/RRRR HH24:MI:SS'),'RRRRMM') 
    and h.dscuil=p_cuil

    order by dtHoraextraDetalle asc;
   
 dbms_output.put_line('funcion: '        ||  v_bool);

if (v_bool is null)then
    RETURN 1; 
    else
    if (v_bool>0)then
      RETURN 2; 
    else
      RETURN 1; 
    end if;
end if;
    
  --  RETURN 1; 
  
    end Tiene_12hs_descanso;    
END HORASEXTRAS;