CREATE PROCEDURE "informix".sp_genera_reporte_correos_validos()
RETURNING 
CHAR(5) AS CodRet,
CHAR(50) AS Mensaje;

----------------DEFINE VARIABLES----------------------
DEFINE sFechaEjecucion    CHAR(10);
DEFINE cCodRet        	  CHAR(5);
DEFINE cCodRetC           CHAR(5);
DEFINE iSqlErr	       	  INTEGER;
DEFINE cDesc          	  CHAR(50);
DEFINE sMes               CHAR(2);
DEFINE sAnio              CHAR(4);
DEFINE sDescMes           CHAR(10);    
DEFINE sSolic_cap         CHAR(20);
DEFINE sCtes_titulares    CHAR(20);
DEFINE sCtes_no_titulares CHAR(20);

DEFINE sMes2              CHAR(2);
DEFINE sAnio2             CHAR(4);
DEFINE sDescMes2          CHAR(10);    
DEFINE sTotal             CHAR(20);
DEFINE sCod_valid         CHAR(20);
DEFINE sCod_notvalid      CHAR(20);
DEFINE sCod_null          CHAR(20);
DEFINE sFecha_valida_null CHAR(20);
DEFINE sValidos           CHAR(20);

DEFINE sMes3              CHAR(2);
DEFINE sAnio3             CHAR(4);
DEFINE sDescMes3          CHAR(10);    
DEFINE sTitulares         CHAR(20);
DEFINE sTodos             CHAR(20);
DEFINE sDiaspormes        CHAR(20);
DEFINE sPromdiatit        CHAR(20);
DEFINE sPromdiatod        CHAR(20);

DEFINE sPorcentaje        CHAR(5);
DEFINE svt_fecha_hoy      DATE;
DEFINE svt_fecha_udia      DATE;
DEFINE sUdia              CHAR(2);
DEFINE sDiaP              CHAR(2);
DEFINE sMesP              CHAR(2);
DEFINE sAnoP              CHAR(4);

----------------INICIALIZA VARIABLES------------------
LET sFechaEjecucion     = '';
LET cCodRet             ='00000';
LET cCodRetC            ='00000';
LET iSqlErr	            = 0;
LET cDesc               ='';
LET sMes                ='';
LET sAnio               ='';
LET sDescMes            ='';
LET sSolic_cap          ='';
LET sCtes_titulares     ='';
LET sCtes_no_titulares  ='';

LET sMes2               ='';
LET sAnio2              ='';
LET sDescMes2           ='';
LET sTotal              ='';
LET sCod_valid          ='';
LET sCod_notvalid       ='';
LET sCod_null           ='';
LET sFecha_valida_null  ='';
LET sValidos            ='';

LET sMes3               ='';
LET sAnio3              ='';
LET sDescMes3           ='';
LET sTitulares          ='';
LET sTodos              ='';
LET sDiaspormes         ='';
LET sPromdiatit         ='';
LET sPromdiatod         ='';

LET sPorcentaje         ='';
LET svt_fecha_hoy       ='';
LET sUdia               ='';
LET sDiaP               ='';
LET sMesP               ='';
LET sAnoP               ='';

BEGIN

    ----------ERRORES DE INFORMIX-------------------------
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            LET cDesc='Error no controlado';
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	-------------------------------------OBTIENE FECHA-------------------------------------------
	SELECT {+INDEX (bdinteg:"informix".si_fechas idx_si_fechas)} add_months(fecha_hoy,-1) INTO svt_fecha_hoy
	FROM bdinteg:si_fechas
	WHERE empresa = '001';

    LET sDiaP = SUBSTR(svt_fecha_hoy,4,2);
    LET sMesP = SUBSTR(svt_fecha_hoy,0,2);
    LET sAnoP = SUBSTR(svt_fecha_hoy,7,4);
	
	SELECT LAST_DAY(mdy(sMesP,sDiaP,sAnoP)) INTO svt_fecha_udia
	FROM systables WHERE tabid = 1;
	
	LET sUdia = SUBSTR(svt_fecha_udia,4,2);
	---------------------------------------------------------------------------------------------
	
	------------------SOLICITUDES----------------------------------------------------------------
	DROP TABLE IF EXISTS tmp_tabla_solic;
    SELECT 
        month(S.fecha_insert) as mes
        , year(S.fecha_insert) as anio
        ,DECODE(MONTH(S.fecha_insert),1,'Enero',2,'Febrero',3,'Marzo',4,'Abril',5,'Mayo',6,'Junio',7,'Julio',8,'Agosto',9,'Septiembre',10,'Octubre',11,'Noviembre',12,'Diciembre') || ' ' || year(S.fecha_insert) as mesDesc
        , count(*) as Solic_Cap 
        ,sum(case when C.tipo_cliente='1' then 1 else 0 end) as ctes_titulares
        ,sum(case when C.tipo_cliente='1' then 0 else 1 end) as ctes_no_titulares    
    FROM bdisolic:informix.ss_solicitudes S, bdinteg:informix.si_cliente C
    where 
        (S.fecha_insert >= mdy(sMesP,'01',sAnoP) and S.fecha_insert <= mdy(sMesP,sUdia,sAnoP) )
        and S.num_producto='6500'
        and (C.fecha_insert >= mdy(sMesP,'01',sAnoP) and C.fecha_insert <= mdy(sMesP,sUdia,sAnoP) )
        --and S.fecha_insert = C.fecha_insert
        and C.numcte=S.numcte
    group by 1,2,3 order by 2,1,3 asc
	INTO TEMP tmp_tabla_solic WITH NO LOG;

	SET ISOLATION TO DIRTY READ;
    FOREACH c1 FOR
		SELECT mes, anio, mesDesc, Solic_Cap, ctes_titulares, ctes_no_titulares
			INTO sMes, sAnio, sDescMes, sSolic_cap, sCtes_titulares, sCtes_no_titulares
		FROM tmp_tabla_solic			
    END FOREACH;
	--------------------------------------------------------------------------------------
	
	-------------------------------VALIDACION DE CORREO-----------------------------------
	DROP TABLE IF EXISTS tmp_tabla_valida_correo;
	select {+INDEX (bdinteg:"informix".si_correos idx_si_correos8)}
	month(cast(C.fecha_hora AS DATETIME YEAR to FRACTION(3))::date) as mes2
	, year(cast(C.fecha_hora AS DATETIME YEAR to FRACTION(3))::date) as anio2
	,DECODE(MONTH(cast(C.fecha_hora AS DATETIME YEAR to FRACTION(3))::date),1,'Enero',2,'Febrero',3,'Marzo',4,'Abril',5,'Mayo',6,'Junio',7,'Julio',8,'Agosto',9,'Septiembre',10,'Octubre',11,'Noviembre',12,'Diciembre') || ' ' || year(cast(C.fecha_hora AS DATETIME YEAR to FRACTION(3))::date) as mesDesc2
    ,count(*) as Total
    , sum(case when valida_correo='200' then 1 when valida_correo='210' then 1 when valida_correo='220' then 1 else 0 end) as cod_valid
    , sum(case when valida_correo='300' then 1 when valida_correo='400' then 1 when valida_correo='500' then 1 else 0 end) as cod_notvalid
    , sum(case when valida_correo is null then 1 else 0 end) as cod_NULL
    , sum(case when fecha_valida is null then 1 else 0 end) as fecha_valida_NULL
    , (sum(case when valida_correo='200' then 1 when valida_correo='210' then 1 when valida_correo='220' then 1 else 0 end) / count(*)) * 100 as validos
    from bdinteg:"informix".si_correos C, bdinteg:si_cliente T
    where substr(C.fecha_hora, 12, 5) between '10:00' and '20:00'
    and T.tipo_cliente='1'
    and cast(C.fecha_hora AS DATETIME YEAR to FRACTION(3))::date >= mdy(sMesP,'01',sAnoP)
    and cast(C.fecha_hora AS DATETIME YEAR to FRACTION(3))::date <= mdy(sMesP,sUdia,sAnoP)
    and T.numcte=C.numcte
    group by 2,1,3
    order by 2,1,3 asc
	INTO TEMP tmp_tabla_valida_correo WITH NO LOG;
	
    SET ISOLATION TO DIRTY READ;
    FOREACH c2 FOR
		SELECT mes2, anio2, mesDesc2, Total, cod_valid, cod_notvalid, cod_NULL, fecha_valida_NULL,validos
			INTO sMes2, sAnio2, sDescMes2, sTotal, sCod_valid, sCod_notvalid, sCod_null, sFecha_valida_null, sValidos
		FROM tmp_tabla_valida_correo			
    END FOREACH;
    ----------------------------------------------------------------------------

    ------------------------ALTAS DE CLIENTES-----------------------------------
    DROP TABLE IF EXISTS tmp_tabla_altas_ctes; 
    select month(fecha_insert) as mes3
    ,year(fecha_insert) as anio3
    ,DECODE(MONTH(fecha_insert),1,'Enero',2,'Febrero',3,'Marzo',4,'Abril',5,'Mayo',6,'Junio',7,'Julio',8,'Agosto',9,'Septiembre',10,'Octubre',11,'Noviembre',12,'Diciembre') || ' ' || year(fecha_insert) as mesDesc3
    ,sum(case tipo_cliente when '1' then 1 else 0 end) as titulares
    , count(*) Todos
    , count(distinct(day(fecha_insert))) as diasPorMes
    , cast(sum(case tipo_cliente when '1' then 1 else 0 end) / count(distinct(day(fecha_insert))) as decimal(18,0)) as PromDiaTit
    , cast(count(*) / count(distinct(day(fecha_insert))) as decimal(18,0)) as PromDiaTod
    from bdinteg:si_cliente
    where empresa='001'
    and fecha_insert is not null
    and fecha_insert >= mdy(sMesP,'01',sAnoP) and fecha_insert <= mdy(sMesP,sUdia,sAnoP)
    group by 1,2,3
    order by 2,1,3 asc
    INTO TEMP tmp_tabla_altas_ctes WITH NO LOG;

    SET ISOLATION TO DIRTY READ;
    FOREACH c3 FOR
		SELECT mes3, anio3, mesDesc3, titulares, Todos, PromDiaTit, PromDiaTod
			INTO sMes3, sAnio3, sDescMes3, sTitulares, sTodos, sPromDiaTit, sPromDiaTod
		FROM tmp_tabla_altas_ctes			
    END FOREACH;
	--------------------------------------------------------------------------------
	
	-----------------------------------VALIDA CIFRAS---------------------------------	
	SELECT {+INDEX (bdinteg:"informix".si_fechas idx_si_fechas)}
	SUBSTR(LOWER(DECODE(MONTH(svt_fecha_hoy),1,'Enero',2,'Febrero',3,'Marzo',4,'Abril',5,'Mayo',6,'Junio',7,'Julio',8,'Agosto',9,'Septiembre',10,'Octubre',11,'Noviembre',12,'Diciembre') || ' ' || year(svt_fecha_hoy)),0,3)
	||'-'|| SUBSTR(sAnoP,3,2)
	INTO sDescMes  
	FROM bdinteg:si_fechas
	WHERE empresa = '001';	
	
	IF(sTitulares = '' OR sTitulares IS NULL) THEN
		LET sTitulares=0;
	END IF;
	
	IF(sSolic_cap = '' OR sSolic_cap IS NULL) THEN
		LET sSolic_cap=0;
	END IF;
	
	IF(sTotal = '' OR sTotal IS NULL) THEN
		LET sTotal=0;
	END IF;
	
	IF(sCod_valid = '' OR sCod_valid IS NULL) THEN
		LET sCod_valid=0;
	END IF;
			
	IF(sTotal = 0 OR sCod_valid = 0) THEN
		LET sPorcentaje=0;
		ELSE
		---------------------CALCULA PORCENTAJE-----------------------------------------
		LET sPorcentaje = SUBSTR(ROUND((sCod_valid / sTotal),2),3,2) || '%';
		--------------------INSERTA EN TABLA DE REPORTE---------------------------------
	END IF;
	---------------------------------------------------------------------------------
	
	INSERT INTO "informix".si_reporte_correos_validos(mes, altas_clientes, solicitudes_coppel, correos_capturados, correos_validos, porcentaje) 
    VALUES(sDescMes, TO_CHAR(sTitulares, "<<<,<<<,<<<,<<&"), TO_CHAR(sSolic_cap, "<<<,<<<,<<<,<<&"), TO_CHAR(sTotal, "<<<,<<<,<<<,<<&"), TO_CHAR(sCod_valid, "<<<,<<<,<<<,<<&"), sPorcentaje);
    --------------------------------------------------------------------------------
	
	----------Envio de correo automatico--------------------------------------------
	EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento_prod ('1', 'COR_CAP_AU', 'COR_CAP_AU','GRUPO_COR_CAP', '','', '1',
	sDescMes,TO_CHAR(sTitulares, "<<<,<<<,<<<,<<&"),TO_CHAR(sSolic_cap, "<<<,<<<,<<<,<<&"),TO_CHAR(sTotal, "<<<,<<<,<<<,<<&"),TO_CHAR(sCod_valid, "<<<,<<<,<<<,<<&"),sPorcentaje,'','','','','','',1,0,0,0,0,'','')
	INTO cCodRetC;
	--------------------------------------------------------------------------------
	
	LET cDesc= 'PROCESO EXITOSO';
	RETURN cCodRet, cDesc;
END 
END PROCEDURE;