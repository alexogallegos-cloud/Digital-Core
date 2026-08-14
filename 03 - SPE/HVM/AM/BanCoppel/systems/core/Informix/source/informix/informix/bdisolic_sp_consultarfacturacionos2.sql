CREATE PROCEDURE "informix".sp_consultarfacturacionos2 (pEmpresa CHAR(3),
                                            pSucursal CHAR(4),
                                            pNumCte CHAR(9),
                                            cFechaIni CHAR(10),
                                            cFechaFin CHAR(10),
                                            pTipoFecha SMALLINT,
                                            pTipoConsulta SMALLINT,
											pRegistros INTEGER, 
											pRecuperacion INTEGER)
RETURNING  CHAR(6), CHAR(4),INTEGER,
            INTEGER, DECIMAL(5,2),
            INTEGER, DECIMAL(5,2),
            INTEGER, DECIMAL(5,2),
            INTEGER, DECIMAL(5,2),
            INTEGER, DECIMAL(5,2),
            INTEGER, DECIMAL(5,2),
			INTEGER, INTEGER,
			INTEGER, INTEGER;
			

--Declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			                INTEGER;
DEFINE error_info		                CHAR(80);
DEFINE cCod_ret                         CHAR(6);

DEFINE cSucursal                        CHAR (4);
DEFINE iTotalEnviadas                   INTEGER;
DEFINE iImpresas                        INTEGER;
DEFINE dImpresasPor                     DECIMAL(5,2);
DEFINE iNoImpresas                      INTEGER;
DEFINE dNoImpresasPor                   DECIMAL(5,2);
DEFINE iStatusA                         INTEGER;
DEFINE dStatusAPor                      DECIMAL(5,2);
DEFINE iStatusR                         INTEGER;
DEFINE dStatusRPor                      DECIMAL(5,2);
DEFINE iStatusD                         INTEGER;
DEFINE dStatusDPor                      DECIMAL(5,2);
DEFINE iStatusS                         INTEGER;
DEFINE dStatusSPor                      DECIMAL(5,2);
DEFINE pFechaIni                        DATE;
DEFINE pFechaFin                        DATE;
DEFINE iBancoppel                       INTEGER;
DEFINE iCoppel                          INTEGER;
DEFINE iMixta                           INTEGER;
DEFINE iTotal                           INTEGER;
DEFINE iRegistros						INTEGER;
---------------

LET sql_err 			                = 0;
LET error_info		                    = "";
LET cCod_ret                            = "";

LET cSucursal                           = "";
LET iTotalEnviadas                      = 0;
LET iImpresas                           = 0;
LET dImpresasPor                        = 0;
LET iNoImpresas                         = 0;
LET dNoImpresasPor                      = 0;
LET iStatusA                            = 0;
LET dStatusAPor                         = 0;
LET iStatusR                            = 0;
LET dStatusRPor                         = 0;
LET iStatusD                            = 0;
LET dStatusDPor                         = 0;
LET iStatusS                            = 0;
LET dStatusSPor                         = 0;
LET pFechaIni                           = DATE(1);
LET pFechaFin                           = DATE(1);
LET iBancoppel                          = 0;
LET iCoppel                             = 0;
LET iMixta                              = 0;
LET iTotal                              = 0;
LET iRegistros						    = 1;

-- Creado: Bernardo Carlos BÃÂ¡ez GonzÃÂ¡lez
-- Fecha: 11 de  enero de 2010
-- Se crea con el objetivo de obtener El total y el detalle de las ordenes de supervicion
-- modifico: JesÃÂºs Manuel Aguilar Heredia
-- Fecha: 02 de junio de 2010
-- se modifico  para que los tipos de consulta  1 y 2  se maneje por rango de fechas

LET cCod_ret = '00000';
LET sql_err = 0;


      BEGIN

        ON EXCEPTION SET sql_err
	        LET cCod_ret = sql_err;

			DROP TABLE IF EXISTS mixtas;
			DROP TABLE IF EXISTS solicitud_temp;

			RETURN cCod_ret, NVL(cSucursal,''), NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), NVL(iStatusR,0), NVL(dStatusRPor,0),
				NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0), NVL(iBancoppel,0), NVL(iCoppel,0), NVL(iMixta,0), NVL(iTotal,0);
	    END EXCEPTION;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "/home/sysifx/paulq/sp_ConsultarFacturacionOS2.out";
--SET DEBUG FILE TO "/ifxsif01/c90039427/sp_ConsultarFacturacionOS2.out";
--TRACE ON; 
 
LET pFechaIni      = MDY (SUBSTR(cFechaIni,6,2),SUBSTR(cFechaIni,9,2),SUBSTR(cFechaIni,1,4));
LET pFechaFin      = MDY (SUBSTR(cFechaFin,6,2),SUBSTR(cFechaFin,9,2),SUBSTR(cFechaFin,1,4));

DROP TABLE IF EXISTS mixtas;
DROP TABLE IF EXISTS solicitud_temp;

create temp table mixtas ( secuencia char(7)) with no log;
--create index ss_ctas_mixtas_total on ctas_mixtas_total (numcte);
--update statistics medium for table ctas_mixtas_total;

IF pTipoConsulta NOT IN (1, 2, 3) THEN

	LET cCod_ret = '00001';

    RETURN cCod_ret, NVL(cSucursal,''), NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), NVL(iStatusR,0), NVL(dStatusRPor,0),
		NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0), NVL(iBancoppel,0), NVL(iCoppel,0), NVL(iMixta,0), NVL(iTotal,0);

ELIF pTipoConsulta = 1 THEN
	IF pSucursal <> "" AND pSucursal IS NOT NULL THEN

		select a.num_solicitud, secuencia, fecha_solicitud, clave, fechaimpresion , count(*) cantidad
			from bdisolic:ss_osclientesupervisar a
			left outer join bdisolic:ss_solicitud_os b on (b.secuenciaos=a.secuencia AND b.fecha_solicitud=a.fechasolicitud)  
			where DATE(fechamovto) BETWEEN pFechaIni and pFechaFin 
						OR fechaimpresion BETWEEN pFechaIni and pFechaFin 
						OR fecharespuesta BETWEEN pFechaIni and pFechaFin
			group by 1,2,3,4,5
			INTO TEMP solicitud_temp with no log;

			create index ss_osclientesupervisar_idx on solicitud_temp (num_solicitud);
			update statistics medium for table solicitud_temp ;

			select sucursal, COUNT(*) as TotalEnviadas,
				SUM(CASE WHEN fechaimpresion <> DATE(1) THEN 1 ELSE 0 END) as Impresas,
				SUM(CASE WHEN fechaimpresion = DATE(1)THEN 1 ELSE 0 END) as NoImpresas,
				SUM(CASE WHEN clave = 'A' THEN 1 ELSE 0 END) as StatusA,
				SUM(CASE WHEN clave = 'R' THEN 1 ELSE 0 END) as StatusR,
				SUM(CASE WHEN clave = 'D' THEN 1 ELSE 0 END) as StatusD,
				SUM(CASE WHEN clave = '' THEN 1 ELSE 0 END) as StatusS,
				sum(case when cantidad = 1 and b.num_solicitud not matches '65*' then 1 else 0 end) as Bancoppel,
				sum(case when cantidad = 1 and b.num_solicitud matches '65*' then 1 else 0 end) as Coppel,
				sum(case when cantidad > 1 then 1 else 0 end) as Mixta
			INTO cSucursal,iTotalEnviadas,iImpresas,iNoImpresas,iStatusA,iStatusR,iStatusD,iStatusS,iBancoppel,iCoppel,iMixta
			from solicitud_temp b
			INNER JOIN bdisolic:ss_solicitudes a ON b.num_solicitud = a.num_solicitud
			WHERE sucursal=pSucursal	
			group by 1;

			LET dImpresasPor = iImpresas / iTotalEnviadas * 100;
			LET dNoImpresasPor = iNoImpresas / iTotalEnviadas * 100;
			LET dStatusAPor = iStatusA / iTotalEnviadas * 100;
			LET dStatusRPor = iStatusR / iTotalEnviadas * 100;
			LET dStatusDPor = iStatusD / iTotalEnviadas * 100;
			LET dStatusSPor = iStatusS / iTotalEnviadas * 100;
			LET iTotal = NVL(iBancoppel,0) + NVL(iCoppel,0) + NVL(iMixta,0);

			RETURN cCod_ret, NVL(cSucursal,''), NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), NVL(iStatusR,0), NVL(dStatusRPor,0),
				NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0), NVL(iBancoppel,0), NVL(iCoppel,0), NVL(iMixta,0), NVL(iTotal,0) WITH RESUME;

			SELECT LIMIT 1 COUNT(*)
	            INTO iRegistros FROM solicitud_temp;

	ELSE
		LET cCod_ret = '00002';

	    RETURN cCod_ret, NVL(cSucursal,''), NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), NVL(iStatusR,0), NVL(dStatusRPor,0),
			NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0), NVL(iBancoppel,0), NVL(iCoppel,0), NVL(iMixta,0), NVL(iTotal,0);
	END IF;
ELIF pTipoConsulta = 2 THEN
	IF pNumCte <> "" AND pNumCte IS NOT NULL THEN

		select a.num_solicitud, secuencia, fecha_solicitud, clave, fechaimpresion , count(*) cantidad
			from bdisolic:ss_osclientesupervisar a
			left outer join bdisolic:ss_solicitud_os b on (b.secuenciaos=a.secuencia AND b.fecha_solicitud=a.fechasolicitud)  
			where DATE(fechamovto) BETWEEN pFechaIni and pFechaFin 
						OR fechaimpresion BETWEEN pFechaIni and pFechaFin 
						OR fecharespuesta BETWEEN pFechaIni and pFechaFin
			group by 1,2,3,4,5
			INTO TEMP solicitud_temp with no log;

			create index ss_osclientesupervisar_idx on solicitud_temp (num_solicitud);
			update statistics medium for table solicitud_temp ;

			select sucursal, COUNT(*) as TotalEnviadas,
				SUM(CASE WHEN fechaimpresion <> DATE(1) THEN 1 ELSE 0 END) as Impresas,
				SUM(CASE WHEN fechaimpresion = DATE(1)THEN 1 ELSE 0 END) as NoImpresas,
				SUM(CASE WHEN clave = 'A' THEN 1 ELSE 0 END) as StatusA,
				SUM(CASE WHEN clave = 'R' THEN 1 ELSE 0 END) as StatusR,
				SUM(CASE WHEN clave = 'D' THEN 1 ELSE 0 END) as StatusD,
				SUM(CASE WHEN clave = '' THEN 1 ELSE 0 END) as StatusS,
				sum(case when cantidad = 1 and b.num_solicitud not matches '65*' then 1 else 0 end) as Bancoppel,
				sum(case when cantidad = 1 and b.num_solicitud matches '65*' then 1 else 0 end) as Coppel,
				sum(case when cantidad > 1 then 1 else 0 end) as Mixta
			INTO cSucursal,iTotalEnviadas,iImpresas,iNoImpresas,iStatusA,iStatusR,iStatusD,iStatusS,iBancoppel,iCoppel,iMixta
			from solicitud_temp b
			INNER JOIN bdisolic:ss_solicitudes a ON b.num_solicitud = a.num_solicitud
			WHERE numcte=pNumCte	
			group by 1;

			LET dImpresasPor = iImpresas / iTotalEnviadas * 100;
			LET dNoImpresasPor = iNoImpresas / iTotalEnviadas * 100;
			LET dStatusAPor = iStatusA / iTotalEnviadas * 100;
			LET dStatusRPor = iStatusR / iTotalEnviadas * 100;
			LET dStatusDPor = iStatusD / iTotalEnviadas * 100;
			LET dStatusSPor = iStatusS / iTotalEnviadas * 100;
			LET iTotal = NVL(iBancoppel,0) + NVL(iCoppel,0) + NVL(iMixta,0);

			RETURN cCod_ret, NVL(cSucursal,''), NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), NVL(iStatusR,0), NVL(dStatusRPor,0),
				NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0), NVL(iBancoppel,0), NVL(iCoppel,0), NVL(iMixta,0), NVL(iTotal,0) WITH RESUME;
			
			SELECT LIMIT 1 COUNT(*)
	            INTO iRegistros FROM solicitud_temp;

	ELSE
		LET cCod_ret = '00003';

	    RETURN cCod_ret, NVL(cSucursal,''), NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), NVL(iStatusR,0), NVL(dStatusRPor,0),
			NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0), NVL(iBancoppel,0), NVL(iCoppel,0), NVL(iMixta,0), NVL(iTotal,0);
	END IF;
ELIF pTipoConsulta = 3 THEN

    IF pTipoFecha NOT IN (1,2,3,4) THEN

		LET cCod_ret = '00004';

		RETURN cCod_ret, NVL(cSucursal,''), NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), NVL(iStatusR,0), NVL(dStatusRPor,0),
			NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0), NVL(iBancoppel,0), NVL(iCoppel,0), NVL(iMixta,0), NVL(iTotal,0);

    ELIF pTipoFecha = 1 THEN
		IF pFechaIni <= pFechaFin AND pFechaIni IS NOT NULL AND pFechaFin IS NOT NULL THEN

			select a.num_solicitud, secuencia, fecha_solicitud, clave, fechaimpresion , count(*) cantidad
			from bdisolic:ss_osclientesupervisar a
			left outer join bdisolic:ss_solicitud_os b on (b.secuenciaos=a.secuencia AND b.fecha_solicitud=a.fechasolicitud)  
			where DATE(fechamovto) BETWEEN pFechaIni and pFechaFin
			group by 1,2,3,4,5
			INTO TEMP solicitud_temp with no log;

			create index ss_osclientesupervisar_idx on solicitud_temp (num_solicitud);
			update statistics medium for table solicitud_temp ;

			select sucursal, COUNT(*) as TotalEnviadas,
				SUM(CASE WHEN fechaimpresion <> DATE(1) THEN 1 ELSE 0 END) as Impresas,
				SUM(CASE WHEN fechaimpresion = DATE(1)THEN 1 ELSE 0 END) as NoImpresas,
				SUM(CASE WHEN clave = 'A' THEN 1 ELSE 0 END) as StatusA,
				SUM(CASE WHEN clave = 'R' THEN 1 ELSE 0 END) as StatusR,
				SUM(CASE WHEN clave = 'D' THEN 1 ELSE 0 END) as StatusD,
				SUM(CASE WHEN clave = '' THEN 1 ELSE 0 END) as StatusS,
				sum(case when cantidad = 1 and b.num_solicitud not matches '65*' then 1 else 0 end) as Bancoppel,
				sum(case when cantidad = 1 and b.num_solicitud matches '65*' then 1 else 0 end) as Coppel,
				sum(case when cantidad > 1 then 1 else 0 end) as Mixta
			from solicitud_temp b
			INNER JOIN bdisolic:ss_solicitudes a ON b.num_solicitud = a.num_solicitud
			group by 1
			INTO TEMP solicitudes with no log;

	        FOREACH
			SELECT sucursal,TotalEnviadas,Impresas,NoImpresas,StatusA,StatusR,StatusD,StatusS,Bancoppel,Coppel, Mixta
				INTO cSucursal,iTotalEnviadas,iImpresas,iNoImpresas,iStatusA,iStatusR,iStatusD,iStatusS,iBancoppel,iCoppel,iMixta
				FROM solicitudes
	
	            LET dImpresasPor = iImpresas / iTotalEnviadas * 100;
	            LET dNoImpresasPor = iNoImpresas / iTotalEnviadas * 100;
	            LET dStatusAPor = iStatusA / iTotalEnviadas * 100;
	            LET dStatusRPor = iStatusR / iTotalEnviadas * 100;
	            LET dStatusDPor = iStatusD / iTotalEnviadas * 100;
	            LET dStatusSPor = iStatusS / iTotalEnviadas * 100;
				LET iTotal = NVL(iBancoppel,0) + NVL(iCoppel,0) + NVL(iMixta,0);

	            RETURN cCod_ret, NVL(cSucursal,''), NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), NVL(iStatusR,0), NVL(dStatusRPor,0),
					NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0), NVL(iBancoppel,0), NVL(iCoppel,0), NVL(iMixta,0), NVL(iTotal,0) WITH RESUME;
	        END FOREACH;

			SELECT LIMIT 1 COUNT(*)
	            INTO iRegistros FROM solicitudes;

		ELSE
			LET cCod_ret = '00005';

			RETURN cCod_ret, NVL(cSucursal,''), NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), NVL(iStatusR,0), NVL(dStatusRPor,0),
				NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0), NVL(iBancoppel,0), NVL(iCoppel,0), NVL(iMixta,0), NVL(iTotal,0);
		END IF;

    ELIF pTipoFecha = 2 THEN
		IF pFechaIni <= pFechaFin AND pFechaIni IS NOT NULL AND pFechaFin IS NOT NULL THEN

        select a.num_solicitud, secuencia, fecha_solicitud, clave, fechaimpresion , count(*) cantidad
			from bdisolic:ss_osclientesupervisar a
			left outer join bdisolic:ss_solicitud_os b on (b.secuenciaos=a.secuencia AND b.fecha_solicitud=a.fechasolicitud)  
			where fechaimpresion BETWEEN pFechaIni and pFechaFin
			group by 1,2,3,4,5
			INTO TEMP solicitud_temp with no log;

			create index ss_osclientesupervisar_idx on solicitud_temp (num_solicitud);
			update statistics medium for table solicitud_temp ;

			select sucursal, COUNT(*) as TotalEnviadas,
				SUM(CASE WHEN fechaimpresion <> DATE(1) THEN 1 ELSE 0 END) as Impresas,
				SUM(CASE WHEN fechaimpresion = DATE(1)THEN 1 ELSE 0 END) as NoImpresas,
				SUM(CASE WHEN clave = 'A' THEN 1 ELSE 0 END) as StatusA,
				SUM(CASE WHEN clave = 'R' THEN 1 ELSE 0 END) as StatusR,
				SUM(CASE WHEN clave = 'D' THEN 1 ELSE 0 END) as StatusD,
				SUM(CASE WHEN clave = '' THEN 1 ELSE 0 END) as StatusS,
				sum(case when cantidad = 1 and b.num_solicitud not matches '65*' then 1 else 0 end) as Bancoppel,
				sum(case when cantidad = 1 and b.num_solicitud matches '65*' then 1 else 0 end) as Coppel,
				sum(case when cantidad > 1 then 1 else 0 end) as Mixta
			from solicitud_temp b
			INNER JOIN bdisolic:ss_solicitudes a ON b.num_solicitud = a.num_solicitud
			group by 1
			INTO TEMP solicitudes with no log;

	        FOREACH
			SELECT sucursal,TotalEnviadas,Impresas,NoImpresas,StatusA,StatusR,StatusD,StatusS,Bancoppel,Coppel, Mixta
				INTO cSucursal,iTotalEnviadas,iImpresas,iNoImpresas,iStatusA,iStatusR,iStatusD,iStatusS,iBancoppel,iCoppel,iMixta
				FROM solicitudes
	
	            LET dImpresasPor = iImpresas / iTotalEnviadas * 100;
	            LET dNoImpresasPor = iNoImpresas / iTotalEnviadas * 100;
	            LET dStatusAPor = iStatusA / iTotalEnviadas * 100;
	            LET dStatusRPor = iStatusR / iTotalEnviadas * 100;
	            LET dStatusDPor = iStatusD / iTotalEnviadas * 100;
	            LET dStatusSPor = iStatusS / iTotalEnviadas * 100;
				LET iTotal = NVL(iBancoppel,0) + NVL(iCoppel,0) + NVL(iMixta,0);

	            RETURN cCod_ret, NVL(cSucursal,''), NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), NVL(iStatusR,0), NVL(dStatusRPor,0),
					NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0), NVL(iBancoppel,0), NVL(iCoppel,0), NVL(iMixta,0), NVL(iTotal,0) WITH RESUME;
	        END FOREACH;

			SELECT LIMIT 1 COUNT(*)
	            INTO iRegistros FROM solicitudes;

		ELSE
			LET cCod_ret = '00005';

			RETURN cCod_ret, NVL(cSucursal,''), NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), NVL(iStatusR,0), NVL(dStatusRPor,0),
				NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0), NVL(iBancoppel,0), NVL(iCoppel,0), NVL(iMixta,0), NVL(iTotal,0);
		END IF;
    ELIF pTipoFecha = 3 THEN
		IF pFechaIni <= pFechaFin AND pFechaIni IS NOT NULL AND pFechaFin IS NOT NULL THEN

	        select a.num_solicitud, secuencia, fecha_solicitud, clave, fechaimpresion , count(*) cantidad
			from bdisolic:ss_osclientesupervisar a
			left outer join bdisolic:ss_solicitud_os b on (b.secuenciaos=a.secuencia AND b.fecha_solicitud=a.fechasolicitud)  
			where fecharespuesta BETWEEN pFechaIni and pFechaFin
			group by 1,2,3,4,5
			INTO TEMP solicitud_temp with no log;

			create index ss_osclientesupervisar_idx on solicitud_temp (num_solicitud);
			update statistics medium for table solicitud_temp ;

			select sucursal, COUNT(*) as TotalEnviadas,
				SUM(CASE WHEN fechaimpresion <> DATE(1) THEN 1 ELSE 0 END) as Impresas,
				SUM(CASE WHEN fechaimpresion = DATE(1)THEN 1 ELSE 0 END) as NoImpresas,
				SUM(CASE WHEN clave = 'A' THEN 1 ELSE 0 END) as StatusA,
				SUM(CASE WHEN clave = 'R' THEN 1 ELSE 0 END) as StatusR,
				SUM(CASE WHEN clave = 'D' THEN 1 ELSE 0 END) as StatusD,
				SUM(CASE WHEN clave = '' THEN 1 ELSE 0 END) as StatusS,
				sum(case when cantidad = 1 and b.num_solicitud not matches '65*' then 1 else 0 end) as Bancoppel,
				sum(case when cantidad = 1 and b.num_solicitud matches '65*' then 1 else 0 end) as Coppel,
				sum(case when cantidad > 1 then 1 else 0 end) as Mixta
			from solicitud_temp b
			INNER JOIN bdisolic:ss_solicitudes a ON b.num_solicitud = a.num_solicitud
			group by 1
			INTO TEMP solicitudes with no log;

	        FOREACH
			SELECT sucursal,TotalEnviadas,Impresas,NoImpresas,StatusA,StatusR,StatusD,StatusS,Bancoppel,Coppel, Mixta
				INTO cSucursal,iTotalEnviadas,iImpresas,iNoImpresas,iStatusA,iStatusR,iStatusD,iStatusS,iBancoppel,iCoppel,iMixta
				FROM solicitudes
	
	            LET dImpresasPor = iImpresas / iTotalEnviadas * 100;
	            LET dNoImpresasPor = iNoImpresas / iTotalEnviadas * 100;
	            LET dStatusAPor = iStatusA / iTotalEnviadas * 100;
	            LET dStatusRPor = iStatusR / iTotalEnviadas * 100;
	            LET dStatusDPor = iStatusD / iTotalEnviadas * 100;
	            LET dStatusSPor = iStatusS / iTotalEnviadas * 100;
				LET iTotal = NVL(iBancoppel,0) + NVL(iCoppel,0) + NVL(iMixta,0);

	            RETURN cCod_ret, NVL(cSucursal,''), NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), NVL(iStatusR,0), NVL(dStatusRPor,0),
					NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0), NVL(iBancoppel,0), NVL(iCoppel,0), NVL(iMixta,0), NVL(iTotal,0) WITH RESUME;
	        END FOREACH;

			SELECT LIMIT 1 COUNT(*)
	            INTO iRegistros FROM solicitudes;
		ELSE
			LET cCod_ret = '00005';

			RETURN cCod_ret, NVL(cSucursal,''), NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), NVL(iStatusR,0), NVL(dStatusRPor,0),
				NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0), NVL(iBancoppel,0), NVL(iCoppel,0), NVL(iMixta,0), NVL(iTotal,0);
		END IF;
    ELIF pTipoFecha = 4 THEN
		IF pFechaIni <= pFechaFin AND pFechaIni IS NOT NULL AND pFechaFin IS NOT NULL THEN

			select a.num_solicitud, secuencia, fecha_solicitud, clave, fechaimpresion , count(*) cantidad
			from bdisolic:ss_osclientesupervisar a
			left outer join bdisolic:ss_solicitud_os b on (b.secuenciaos=a.secuencia AND b.fecha_solicitud=a.fechasolicitud)  
			where DATE(fechamovto) BETWEEN pFechaIni and pFechaFin
					OR fechaimpresion BETWEEN pFechaIni and pFechaFin
					OR fecharespuesta BETWEEN pFechaIni and pFechaFin
			group by 1,2,3,4,5
			INTO TEMP solicitud_temp with no log;

			create index ss_osclientesupervisar_idx on solicitud_temp (num_solicitud);
			update statistics medium for table solicitud_temp ;

			select sucursal, COUNT(*) as TotalEnviadas,
				SUM(CASE WHEN fechaimpresion <> DATE(1) THEN 1 ELSE 0 END) as Impresas,
				SUM(CASE WHEN fechaimpresion = DATE(1)THEN 1 ELSE 0 END) as NoImpresas,
				SUM(CASE WHEN clave = 'A' THEN 1 ELSE 0 END) as StatusA,
				SUM(CASE WHEN clave = 'R' THEN 1 ELSE 0 END) as StatusR,
				SUM(CASE WHEN clave = 'D' THEN 1 ELSE 0 END) as StatusD,
				SUM(CASE WHEN clave = '' THEN 1 ELSE 0 END) as StatusS,
				sum(case when cantidad = 1 and b.num_solicitud not matches '65*' then 1 else 0 end) as Bancoppel,
				sum(case when cantidad = 1 and b.num_solicitud matches '65*' then 1 else 0 end) as Coppel,
				sum(case when cantidad > 1 then 1 else 0 end) as Mixta
			from solicitud_temp b
			INNER JOIN bdisolic:ss_solicitudes a ON b.num_solicitud = a.num_solicitud
			group by 1
			INTO TEMP solicitudes with no log;

	        FOREACH
			SELECT sucursal,TotalEnviadas,Impresas,NoImpresas,StatusA,StatusR,StatusD,StatusS,Bancoppel,Coppel, Mixta
				INTO cSucursal,iTotalEnviadas,iImpresas,iNoImpresas,iStatusA,iStatusR,iStatusD,iStatusS,iBancoppel,iCoppel,iMixta
				FROM solicitudes
	
	            LET dImpresasPor = iImpresas / iTotalEnviadas * 100;
	            LET dNoImpresasPor = iNoImpresas / iTotalEnviadas * 100;
	            LET dStatusAPor = iStatusA / iTotalEnviadas * 100;
	            LET dStatusRPor = iStatusR / iTotalEnviadas * 100;
	            LET dStatusDPor = iStatusD / iTotalEnviadas * 100;
	            LET dStatusSPor = iStatusS / iTotalEnviadas * 100;
				LET iTotal = NVL(iBancoppel,0) + NVL(iCoppel,0) + NVL(iMixta,0);

	            RETURN cCod_ret, NVL(cSucursal,''), NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), NVL(iStatusR,0), NVL(dStatusRPor,0),
					NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0), NVL(iBancoppel,0), NVL(iCoppel,0), NVL(iMixta,0), NVL(iTotal,0) WITH RESUME;
	        END FOREACH;

			SELECT LIMIT 1 COUNT(*)
	            INTO iRegistros FROM solicitudes;

		ELSE
			LET cCod_ret = '00005';

			RETURN cCod_ret, NVL(cSucursal,''), NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), NVL(iStatusR,0), NVL(dStatusRPor,0),
				NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0), NVL(iBancoppel,0), NVL(iCoppel,0), NVL(iMixta,0), NVL(iTotal,0);
		END IF;
    END IF;
END IF;

DROP TABLE IF EXISTS mixtas;
DROP TABLE IF EXISTS solicitudes;
DROP TABLE IF EXISTS solicitud_temp;
--LET iRegistros = DBINFO("sqlca.sqlerrd2");

	IF iRegistros = 0 THEN
		LET cCod_ret = '00006';

	    RETURN cCod_ret, NVL(cSucursal,''), NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), NVL(iStatusR,0), NVL(dStatusRPor,0),
			NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0), NVL(iBancoppel,0), NVL(iCoppel,0), NVL(iMixta,0), NVL(iTotal,0);
	END IF;

END;
END PROCEDURE
