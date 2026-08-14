CREATE PROCEDURE "informix".sp_calcula_fechas_porperiodo_calif(pEmpresa CHAR(3),pPeriodicidad CHAR(1),pNumProducto CHAR(04),pDiaCorte SMALLINT,pFechaHoy DATE)
RETURNING   CHAR(6)        AS resultado,
            VARCHAR(100,1) AS mensaje,
			DATE AS Fecha_Actual_t_0,
			DATE AS Fecha_t_1,
			DATE AS Fecha_t_2,
			DATE AS Fecha_t_3,
			DATE AS Fecha_t_4,
			DATE AS Fecha_t_5,
			DATE AS Fecha_t_6,
			DATE AS Fecha_t_7;
			/*DATE AS Fecha_t_8,
			DATE AS Fecha_t_9,
			DATE AS Fecha_t_10,
			DATE AS Fecha_t_11,
			DATE AS Fecha_t_12,
			DATE AS Fecha_t_13;*/
			
DEFINE iSqlErr      	     		INTEGER;
DEFINE iIsamErr              		INTEGER;
DEFINE cErrorInfo            		CHAR(80);
DEFINE cCodRet               		CHAR(6); 
DEFINE cMensajeRet           		VARCHAR(100,1);
DEFINE cMensaje                     CHAR(40);
DEFINE dfecha0,dfecha1,dfecha2,dfecha3,dfecha4,dfecha5,dfecha6,dfecha7 DATE;
DEFINE dfecha8,dfecha9,dfecha10,dfecha11,dfecha12,dfecha13 DATE;
DEFINE dFechaHoyAux date;
DEFINE cLaborable					CHAR(01);
DEFINE sDiaInicial,sDiaFinal	SMALLINT;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
		LET cCodRet= iSqlErr;
		LET cMensajeRet = 'Error en CALCULO FECHAS POR PERIODO';
		RETURN cCodRet,cMensajeRet,dfecha0,dfecha1,dfecha2,dfecha3,dfecha4,dfecha5,dfecha6,dfecha7;
--			,dfecha8,dfecha9,dfecha10,dfecha11,dfecha12,dfecha13;
	  END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/RESPALDOS/INFOSAT/sp_calcula_fechas_porperiodo_trace.out";
--TRACE ON;

LET iSqlErr                  	= 0;
LET iIsamErr                 	= 0;
LET cErrorInfo               	= "";
LET cCodRet                  	= '000000';
--LET cMensajeRet              	= 'Los calculos se realizaron correctamente en CALCULO FECHAS POR PERIODO';
LET cMensajeRet              	= 'Calculos Correcto';
LET cMensaje                    = '';
LET dFechaHoyAux 				= DATE(1);
LET cLaborable					= '';
LET sDiaInicial,sDiaFinal = 0,0;
LET dfecha0,dfecha1,dfecha2,dfecha3,dfecha4,dfecha5,dfecha6,dfecha7 = date(1),date(1),date(1),date(1),date(1),date(1),date(1),date(1);
LET dfecha8,dfecha9,dfecha10,dfecha11,dfecha12,dfecha13 = date(1),date(1),date(1),date(1),date(1),date(1);
LET dFechaHoyAux = date(1);

LET dfecha0,dfecha1,dfecha2,dfecha3,dfecha4,dfecha5,dfecha6,dfecha7 = null,null,null,null,null,null,null,null;
LET dfecha8,dfecha9,dfecha10,dfecha11,dfecha12,dfecha13 = null,null,null,null,null,null;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

-- Se determinan las fechas de consulta
    IF pPeriodicidad = 'M' THEN
		IF pDiaCorte = 31 THEN
			IF month(pFechaHoy) = 2 THEN
				LET dFechaHoyAux = monthadd(pFechaHoy,+1);
				LET dFechaHoyAux = mdy(month(dFechaHoyAux),pDiaCorte,year(dFechaHoyAux));
				LET dFecha0  = monthadd(dFechaHoyAux,-1);	
				LET dFecha1 = monthadd(dFechaHoyAux,-2);
				LET dFecha2 = monthadd(dFechaHoyAux,-3);
				LET dFecha3 = monthadd(dFechaHoyAux,-4);
				LET dFecha4 = monthadd(dFechaHoyAux,-5);
			ELSE
				IF day(pFechaHoy) = 30 THEN
					LET dFechaHoyAux = monthadd(pFechaHoy,+1);
					LET dFechaHoyAux = mdy(month(dFechaHoyAux),pDiaCorte,year(dFechaHoyAux));
					LET dFecha0 = monthadd(dFechaHoyAux,-1);
					LET dFecha1 = monthadd(dFechaHoyAux,-2);
					LET dFecha2 = monthadd(dFechaHoyAux,-3);
					LET dFecha3 = monthadd(dFechaHoyAux,-4);
					LET dFecha4 = monthadd(dFechaHoyAux,-5);
				ELSE
					LET dFechaHoyAux = pFechaHoy;
					LET dFecha0 = dFechaHoyAux;
					LET dFecha1 = monthadd(dFechaHoyAux,-1);
					LET dFecha2 = monthadd(dFechaHoyAux,-2);
					LET dFecha3 = monthadd(dFechaHoyAux,-3);
					LET dFecha4 = monthadd(dFechaHoyAux,-4);
				END IF;
			END IF;	
		ELIF pDiaCorte = 30 THEN
			IF month(pFechaHoy) = 2 THEN
				LET dFechaHoyAux = monthadd(pFechaHoy,+1);
				LET dFechaHoyAux = mdy(month(dFechaHoyAux),pDiaCorte,year(dFechaHoyAux));
				LET dFecha0  = monthadd(dFechaHoyAux,-1);	
				LET dFecha1 = monthadd(dFechaHoyAux,-2);
				LET dFecha2 = monthadd(dFechaHoyAux,-3);
				LET dFecha3 = monthadd(dFechaHoyAux,-4);
				LET dFecha4 = monthadd(dFechaHoyAux,-5);
			ELSE
				LET dFechaHoyAux = mdy(month(pFechaHoy),pDiaCorte,year(pFechaHoy));
				LET dFecha0  = dFechaHoyAux;	
				LET dFecha1 = monthadd(dFechaHoyAux,-1);
				LET dFecha2 = monthadd(dFechaHoyAux,-2);
				LET dFecha3 = monthadd(dFechaHoyAux,-3);
				LET dFecha4 = monthadd(dFechaHoyAux,-4);
			END IF;	
		ELIF pDiaCorte = 29 THEN
			IF month(pFechaHoy) = 2 THEN
				LET dFechaHoyAux = monthadd(pFechaHoy,+1);
				LET dFechaHoyAux = mdy(month(dFechaHoyAux),pDiaCorte,year(dFechaHoyAux));
				LET dFecha0  = monthadd(dFechaHoyAux,-1);	
				LET dFecha1 = monthadd(dFechaHoyAux,-2);
				LET dFecha2 = monthadd(dFechaHoyAux,-3);
				LET dFecha3 = monthadd(dFechaHoyAux,-4);
				LET dFecha4 = monthadd(dFechaHoyAux,-5);
			ELSE
				LET dFechaHoyAux = mdy(month(pFechaHoy),pDiaCorte,year(pFechaHoy));
				LET dFecha0  = dFechaHoyAux;	
				LET dFecha1 = monthadd(dFechaHoyAux,-1);
				LET dFecha2 = monthadd(dFechaHoyAux,-2);
				LET dFecha3 = monthadd(dFechaHoyAux,-3);
				LET dFecha4 = monthadd(dFechaHoyAux,-4);
			END IF;	
		ELSE
			LET dFechaHoyAux = mdy(month(pFechaHoy),pDiaCorte,year(pFechaHoy));
			LET dFecha0  = dFechaHoyAux;	
			LET dFecha1 = monthadd(dFechaHoyAux,-1);
			LET dFecha2 = monthadd(dFechaHoyAux,-2);
			LET dFecha3 = monthadd(dFechaHoyAux,-3);
			LET dFecha4 = monthadd(dFechaHoyAux,-4);
		END IF;

-- Se validan dias inhabiles
		SELECT laborable INTO cLaborable FROM bdinteg:si_feriado WHERE empresa = pEmpresa AND fecha = dFecha0;
		IF cLaborable IS NULL OR cLaborable = '' THEN LET cLaborable = 'S'; END IF;
		
		IF cLaborable = 'N' THEN LET dFecha0 = dFecha0 + 1 units day; END IF;

		SELECT laborable INTO cLaborable FROM bdinteg:si_feriado WHERE empresa = pEmpresa AND fecha = dFecha1;
		IF cLaborable IS NULL OR cLaborable = '' THEN LET cLaborable = 'S'; END IF;

		IF cLaborable = 'N' THEN LET dFecha1 = dFecha1 + 1 units day; END IF;
		
		SELECT laborable INTO cLaborable FROM bdinteg:si_feriado WHERE empresa = pEmpresa AND fecha = dFecha2;
		IF cLaborable IS NULL OR cLaborable = '' THEN LET cLaborable = 'S'; END IF;

		IF cLaborable = 'N' THEN LET dFecha2 = dFecha2 + 1 units day; END IF;

		SELECT laborable INTO cLaborable FROM bdinteg:si_feriado WHERE empresa = pEmpresa AND fecha = dFecha3;
		IF cLaborable IS NULL OR cLaborable = '' THEN LET cLaborable = 'S'; END IF;

		IF cLaborable = 'N' THEN LET dFecha3 = dFecha3 + 1 units day; END IF;

		SELECT laborable INTO cLaborable FROM bdinteg:si_feriado WHERE empresa = pEmpresa AND fecha = dFecha4;
		IF cLaborable IS NULL OR cLaborable = '' THEN LET cLaborable = 'S'; END IF;

		IF cLaborable = 'N' THEN LET dFecha4 = dFecha4 + 1 units day; END IF;
	ELIF pPeriodicidad = 'Q' THEN
--calcula 13 periodos de pago
		IF pNumProducto NOT IN ('6400','7800') THEN 
			LET cCodRet= '000002';
			--LET cMensajeRet = 'Producto para periodo quincenal no valido en CALCULO FECHAS POR PERIODO.';
			LET cMensajeRet = 'Periodo quincenal no valido para el producto';
			RETURN cCodRet,cMensajeRet,dfecha0,dfecha1,dfecha2,dfecha3,dfecha4,dfecha5,dfecha6,dfecha7;
				--,dfecha8,dfecha9,dfecha10,dfecha11,dfecha12,dfecha13;
		END IF;
		
		LET pNumProducto = '6400';

		IF (pDiaCorte <= 15) then
			SELECT perdiafac,sdodiafac
			  INTO sDiaInicial,sDiaFinal
			  FROM "informix".sd_diafactura
			 WHERE empresa = pEmpresa
			   AND num_producto = pNumProducto
			   AND perdiafac = pDiaCorte
			   AND tipo_pago = 2 --iTpDiasFechaPago
			   AND fac_especial = 'N';
		ELSE
			SELECT perdiafac,sdodiafac
			  INTO sDiaInicial,sDiaFinal
			  FROM "informix".sd_diafactura
			 WHERE empresa = pEmpresa
			   AND num_producto = pNumProducto
			   AND sdodiafac = pDiaCorte
			   AND tipo_pago = 2 --iTpDiasFechaPago
			   AND fac_especial = 'S';
		END IF;
		
	   IF sDiaInicial IS NULL OR sDiaInicial = '' THEN LET sDiaInicial = 0; END IF;
	   IF sDiaFinal IS NULL OR sDiaFinal = '' THEN LET sDiaFinal = 0; END IF;
			   
	    IF pDiaCorte = 31 OR pDiaCorte = 15 THEN
			IF month(pFechaHoy) = 2 THEN
				LET dFechaHoyAux = monthadd(pFechaHoy,+1);
				LET dFechaHoyAux = mdy(month(dFechaHoyAux),sDiaFinal,year(dFechaHoyAux));
				LET dfecha0 = monthadd(dFechaHoyAux,-1);
				LET dfecha1 = mdy(month(date(dfecha0)),sDiaInicial,year(date(dfecha0)));
				LET dfecha2 = monthadd(dFechaHoyAux,-2);
				LET dfecha3 = mdy(month(date(dfecha2)),sDiaInicial,year(date(dfecha2)));
				LET dfecha4 = monthadd(dFechaHoyAux,-3);
				LET dfecha5 = mdy(month(date(dfecha4)),sDiaInicial,year(date(dfecha4)));
				LET dfecha6 = monthadd(dFechaHoyAux,-4);
				LET dfecha7 = mdy(month(date(dfecha6)),sDiaInicial,year(date(dfecha6)));
				LET dfecha8 = monthadd(dFechaHoyAux,-5);
				LET dfecha9 = mdy(month(date(dfecha8)),sDiaInicial,year(date(dfecha8)));
				LET dfecha10 = monthadd(dFechaHoyAux,-6);
				LET dfecha11 = mdy(month(date(dfecha10)),sDiaInicial,year(date(dfecha10)));
				LET dfecha12 = monthadd(dFechaHoyAux,-7);
				LET dfecha13 = mdy(month(date(dfecha12)),sDiaInicial,year(date(dfecha12)));
			ELIF day(pFechaHoy) = 30 THEN
				LET dFechaHoyAux = monthadd(pFechaHoy,+1);
				LET dFechaHoyAux = mdy(month(dFechaHoyAux),sDiaFinal,year(dFechaHoyAux));
				LET dfecha0 = monthadd(dFechaHoyAux,-1);
				LET dfecha1 = mdy(month(date(dfecha0)),sDiaInicial,year(date(dfecha0)));
				LET dfecha2 = monthadd(dFechaHoyAux,-2);
				LET dfecha3 = mdy(month(date(dfecha2)),sDiaInicial,year(date(dfecha2)));
				LET dfecha4 = monthadd(dFechaHoyAux,-3);
				LET dfecha5 = mdy(month(date(dfecha4)),sDiaInicial,year(date(dfecha4)));
				LET dfecha6 = monthadd(dFechaHoyAux,-4);
				LET dfecha7 = mdy(month(date(dfecha6)),sDiaInicial,year(date(dfecha6)));
				LET dfecha8 = monthadd(dFechaHoyAux,-5);
				LET dfecha9 = mdy(month(date(dfecha8)),sDiaInicial,year(date(dfecha8)));
				LET dfecha10 = monthadd(dFechaHoyAux,-6);
				LET dfecha11 = mdy(month(date(dfecha10)),sDiaInicial,year(date(dfecha10)));
				LET dfecha12 = monthadd(dFechaHoyAux,-7);
				LET dfecha13 = mdy(month(date(dfecha12)),sDiaInicial,year(date(dfecha12)));
			ELSE
				LET dFechaHoyAux = pFechaHoy;
				LET dfecha0 = dFechaHoyAux;
				LET dfecha1 = mdy(month(date(dfecha0)),sDiaInicial,year(date(dfecha0)));
				LET dfecha2 = monthadd(dFechaHoyAux,-1);
				LET dfecha3 = mdy(month(date(dfecha2)),sDiaInicial,year(date(dfecha2)));
				LET dfecha4 = monthadd(dFechaHoyAux,-2);
				LET dfecha5 = mdy(month(date(dfecha4)),sDiaInicial,year(date(dfecha4)));
				LET dfecha6 = monthadd(dFechaHoyAux,-3);
				LET dfecha7 = mdy(month(date(dfecha6)),sDiaInicial,year(date(dfecha6)));
				LET dfecha8 = monthadd(dFechaHoyAux,-4);
				LET dfecha9 = mdy(month(date(dfecha8)),sDiaInicial,year(date(dfecha8)));
				LET dfecha10 = monthadd(dFechaHoyAux,-5);
				LET dfecha11 = mdy(month(date(dfecha10)),sDiaInicial,year(date(dfecha10)));
				LET dfecha12 = monthadd(dFechaHoyAux,-6);
				LET dfecha13 = mdy(month(date(dfecha12)),sDiaInicial,year(date(dfecha12)));
			END IF;	
		ELIF pDiaCorte = 30 THEN
			IF month(pFechaHoy) = 2 THEN
				LET dFechaHoyAux = monthadd(pFechaHoy,+1);
				LET dFechaHoyAux = mdy(month(dFechaHoyAux),sDiaFinal,year(dFechaHoyAux));
				LET dfecha0 = monthadd(dFechaHoyAux,-1);
				LET dfecha1 = mdy(month(date(dfecha0)),sDiaInicial,year(date(dfecha0)));
				LET dfecha2 = monthadd(dFechaHoyAux,-2);
				LET dfecha3 = mdy(month(date(dfecha2)),sDiaInicial,year(date(dfecha2)));
				LET dfecha4 = monthadd(dFechaHoyAux,-3);
				LET dfecha5 = mdy(month(date(dfecha4)),sDiaInicial,year(date(dfecha4)));
				LET dfecha6 = monthadd(dFechaHoyAux,-4);
				LET dfecha7 = mdy(month(date(dfecha6)),sDiaInicial,year(date(dfecha6)));
				LET dfecha8 = monthadd(dFechaHoyAux,-5);
				LET dfecha9 = mdy(month(date(dfecha8)),sDiaInicial,year(date(dfecha8)));
				LET dfecha10 = monthadd(dFechaHoyAux,-6);
				LET dfecha11 = mdy(month(date(dfecha10)),sDiaInicial,year(date(dfecha10)));
				LET dfecha12 = monthadd(dFechaHoyAux,-7);
				LET dfecha13 = mdy(month(date(dfecha12)),sDiaInicial,year(date(dfecha12)));
			ELIF day(pFechaHoy) = 30 THEN
				LET dFechaHoyAux = pFechaHoy;
				LET dfecha0 = dFechaHoyAux;
				LET dfecha1 = mdy(month(date(dfecha0)),sDiaInicial,year(date(dfecha0)));
				LET dfecha2 = monthadd(dFechaHoyAux,-1);
				LET dfecha3 = mdy(month(date(dfecha2)),sDiaInicial,year(date(dfecha2)));
				LET dfecha4 = monthadd(dFechaHoyAux,-2);
				LET dfecha5 = mdy(month(date(dfecha4)),sDiaInicial,year(date(dfecha4)));
				LET dfecha6 = monthadd(dFechaHoyAux,-3);
				LET dfecha7 = mdy(month(date(dfecha6)),sDiaInicial,year(date(dfecha6)));
				LET dfecha8 = monthadd(dFechaHoyAux,-4);
				LET dfecha9 = mdy(month(date(dfecha8)),sDiaInicial,year(date(dfecha8)));
				LET dfecha10 = monthadd(dFechaHoyAux,-5);
				LET dfecha11 = mdy(month(date(dfecha10)),sDiaInicial,year(date(dfecha10)));
				LET dfecha12 = monthadd(dFechaHoyAux,-6);
				LET dfecha13 = mdy(month(date(dfecha12)),sDiaInicial,year(date(dfecha12)));
			ELIF day(pFechaHoy) = 31 THEN
				LET dFechaHoyAux = mdy(month(pFechaHoy),pDiaCorte,year(pFechaHoy));
				LET dfecha0 = dFechaHoyAux;
				LET dfecha1 = mdy(month(date(dfecha0)),sDiaInicial,year(date(dfecha0)));
				LET dfecha2 = monthadd(dFechaHoyAux,-1);
				LET dfecha3 = mdy(month(date(dfecha2)),sDiaInicial,year(date(dfecha2)));
				LET dfecha4 = monthadd(dFechaHoyAux,-2);
				LET dfecha5 = mdy(month(date(dfecha4)),sDiaInicial,year(date(dfecha4)));
				LET dfecha6 = monthadd(dFechaHoyAux,-3);
				LET dfecha7 = mdy(month(date(dfecha6)),sDiaInicial,year(date(dfecha6)));
				LET dfecha8 = monthadd(dFechaHoyAux,-4);
				LET dfecha9 = mdy(month(date(dfecha8)),sDiaInicial,year(date(dfecha8)));
				LET dfecha10 = monthadd(dFechaHoyAux,-5);
				LET dfecha11 = mdy(month(date(dfecha10)),sDiaInicial,year(date(dfecha10)));
				LET dfecha12 = monthadd(dFechaHoyAux,-6);
				LET dfecha13 = mdy(month(date(dfecha12)),sDiaInicial,year(date(dfecha12)));
			END IF;	
		ELSE
			LET dFechaHoyAux = pFechaHoy;
			IF month(dFechaHoyAux) = 2 AND sDiaFinal = 29 THEN 
				LET dfecha0 = dFechaHoyAux;
			ELSE
				LET dfecha0 = mdy(month(date(dFechaHoyAux)),sDiaFinal,year(date(dFechaHoyAux)));
			END IF;
			LET dfecha1 = mdy(month(date(dfecha0)),sDiaInicial,year(date(dfecha0)));

			LET dFechaHoyAux = mdy(month(date(dfecha1)),1,year(date(dfecha1))) - 1 units day;
			IF month(dFechaHoyAux) = 2 AND sDiaFinal = 29 THEN 
				LET dfecha2 = dFechaHoyAux;
			ELSE
				LET dfecha2 = (mdy(month(date(dFechaHoyAux)),sDiaFinal,year(date(dFechaHoyAux))));
			END IF;
			LET dfecha3 = mdy(month(date(dfecha2)),sDiaInicial,year(date(dfecha2)));
			
			LET dFechaHoyAux = mdy(month(date(dfecha3)),1,year(date(dfecha3))) - 1 units day;
			IF month(dFechaHoyAux) = 2 AND sDiaFinal = 29 THEN 
				LET dfecha4 = dFechaHoyAux;
			ELSE
				LET dfecha4 = (mdy(month(date(dFechaHoyAux)),sDiaFinal,year(date(dFechaHoyAux))));
			END IF;
			LET dfecha5 = mdy(month(date(dfecha4)),sDiaInicial,year(date(dfecha4)));
			
			LET dFechaHoyAux = mdy(month(date(dfecha5)),1,year(date(dfecha5))) - 1 units day;
			IF month(dFechaHoyAux) = 2 AND sDiaFinal = 29 THEN 
				LET dfecha6 = dFechaHoyAux;
			ELSE
				LET dfecha6 = (mdy(month(date(dFechaHoyAux)),sDiaFinal,year(date(dFechaHoyAux))));
			END IF;
			LET dfecha7 = mdy(month(date(dfecha6)),sDiaInicial,year(date(dfecha6)));
			
			LET dFechaHoyAux = mdy(month(date(dfecha7)),1,year(date(dfecha7))) - 1 units day;
			IF month(dFechaHoyAux) = 2 AND sDiaFinal = 29 THEN 
				LET dfecha8 = dFechaHoyAux;
			ELSE
				LET dfecha8 = (mdy(month(date(dFechaHoyAux)),sDiaFinal,year(date(dFechaHoyAux))));
			END IF;
			LET dfecha9 = mdy(month(date(dfecha8)),sDiaInicial,year(date(dfecha8)));

			LET dFechaHoyAux = mdy(month(date(dfecha9)),1,year(date(dfecha9))) - 1 units day;
			IF month(dFechaHoyAux) = 2 AND sDiaFinal = 29 THEN 
				LET dfecha10 = dFechaHoyAux;
			ELSE
				LET dfecha10 = (mdy(month(date(dFechaHoyAux)),sDiaFinal,year(date(dFechaHoyAux))));
			END IF;
			LET dfecha11 = mdy(month(date(dfecha10)),sDiaInicial,year(date(dfecha10)));
			
			LET dFechaHoyAux = mdy(month(date(dfecha11)),1,year(date(dfecha11))) - 1 units day;
			IF month(dFechaHoyAux) = 2 AND sDiaFinal = 29 THEN 
				LET dfecha12 = dFechaHoyAux;
			ELSE
				LET dfecha12 = (mdy(month(date(dFechaHoyAux)),sDiaFinal,year(date(dFechaHoyAux))));
			END IF;
			LET dfecha13 = mdy(month(date(dfecha12)),sDiaInicial,year(date(dfecha12)));
		END IF;

-- Se validan dias inhabiles
		SELECT laborable INTO cLaborable FROM bdinteg:si_feriado WHERE empresa = pEmpresa AND fecha = dfecha0;
		IF cLaborable IS NULL OR cLaborable = '' THEN LET cLaborable = 'S'; END IF;
		
		IF cLaborable = 'N' THEN LET dfecha0 = dfecha0 + 1 units day; END IF;

		SELECT laborable INTO cLaborable FROM bdinteg:si_feriado WHERE empresa = pEmpresa AND fecha = dfecha1;
		IF cLaborable IS NULL OR cLaborable = '' THEN LET cLaborable = 'S'; END IF;

		IF cLaborable = 'N' THEN LET dfecha1 = dfecha1 + 1 units day; END IF;
		
		SELECT laborable INTO cLaborable FROM bdinteg:si_feriado WHERE empresa = pEmpresa AND fecha = dfecha2;
		IF cLaborable IS NULL OR cLaborable = '' THEN LET cLaborable = 'S'; END IF;

		IF cLaborable = 'N' THEN LET dfecha2 = dfecha2 + 1 units day; END IF;

		SELECT laborable INTO cLaborable FROM bdinteg:si_feriado WHERE empresa = pEmpresa AND fecha = dfecha3;
		IF cLaborable IS NULL OR cLaborable = '' THEN LET cLaborable = 'S'; END IF;

		IF cLaborable = 'N' THEN LET dfecha3 = dfecha3 + 1 units day; END IF;
------
		SELECT laborable INTO cLaborable FROM bdinteg:si_feriado WHERE empresa = pEmpresa AND fecha = dfecha4;
		IF cLaborable IS NULL OR cLaborable = '' THEN LET cLaborable = 'S'; END IF;
		
		IF cLaborable = 'N' THEN LET dfecha4 = dfecha4 + 1 units day; END IF;

		SELECT laborable INTO cLaborable FROM bdinteg:si_feriado WHERE empresa = pEmpresa AND fecha = dfecha5;
		IF cLaborable IS NULL OR cLaborable = '' THEN LET cLaborable = 'S'; END IF;

		IF cLaborable = 'N' THEN LET dfecha5 = dfecha5 + 1 units day; END IF;
		
		SELECT laborable INTO cLaborable FROM bdinteg:si_feriado WHERE empresa = pEmpresa AND fecha = dfecha6;
		IF cLaborable IS NULL OR cLaborable = '' THEN LET cLaborable = 'S'; END IF;

		IF cLaborable = 'N' THEN LET dfecha6 = dfecha6 + 1 units day; END IF;

		SELECT laborable INTO cLaborable FROM bdinteg:si_feriado WHERE empresa = pEmpresa AND fecha = dfecha7;
		IF cLaborable IS NULL OR cLaborable = '' THEN LET cLaborable = 'S'; END IF;

/*------
		SELECT laborable INTO cLaborable FROM bdinteg:si_feriado WHERE empresa = pEmpresa AND fecha = dfecha8;
		IF cLaborable IS NULL OR cLaborable = '' THEN LET cLaborable = 'S'; END IF;
		
		IF cLaborable = 'N' THEN LET dfecha8 = dfecha8 + 1 units day; END IF;

		SELECT laborable INTO cLaborable FROM bdinteg:si_feriado WHERE empresa = pEmpresa AND fecha = dfecha9;
		IF cLaborable IS NULL OR cLaborable = '' THEN LET cLaborable = 'S'; END IF;

		IF cLaborable = 'N' THEN LET dfecha9 = dfecha9 - 1 units day; END IF;
		
		SELECT laborable INTO cLaborable FROM bdinteg:si_feriado WHERE empresa = pEmpresa AND fecha = dfecha10;
		IF cLaborable IS NULL OR cLaborable = '' THEN LET cLaborable = 'S'; END IF;

		IF cLaborable = 'N' THEN LET dfecha10 = dfecha10 - 1 units day; END IF;

		SELECT laborable INTO cLaborable FROM bdinteg:si_feriado WHERE empresa = pEmpresa AND fecha = dfecha11;
		IF cLaborable IS NULL OR cLaborable = '' THEN LET cLaborable = 'S'; END IF;

		IF cLaborable = 'N' THEN LET dfecha11 = dfecha11 - 1 units day; END IF;

		SELECT laborable INTO cLaborable FROM bdinteg:si_feriado WHERE empresa = pEmpresa AND fecha = dfecha12;
		IF cLaborable IS NULL OR cLaborable = '' THEN LET cLaborable = 'S'; END IF;

		IF cLaborable = 'N' THEN LET dfecha12 = dfecha12 - 1 units day; END IF;

		SELECT laborable INTO cLaborable FROM bdinteg:si_feriado WHERE empresa = pEmpresa AND fecha = dfecha13;
		IF cLaborable IS NULL OR cLaborable = '' THEN LET cLaborable = 'S'; END IF;

		IF cLaborable = 'N' THEN LET dfecha13 = dfecha13 - 1 units day; END IF;
	*/	
--	ELIF pPeriodicidad = 'S' THEN
	ELSE
		LET cCodRet= '000003';
		--LET cMensajeRet = 'Periodo no valido en CALCULO FECHAS POR PERIODO.';
		LET cMensajeRet = 'Periodo no valido.';
		RETURN cCodRet,cMensajeRet,dfecha0,dfecha1,dfecha2,dfecha3,dfecha4,dfecha5,dfecha6,dfecha7;
		--,dfecha8,dfecha9,dfecha10,dfecha11,dfecha12,dfecha13;
	END IF;	 

RETURN cCodRet,cMensajeRet,dfecha0,dfecha1,dfecha2,dfecha3,dfecha4,dfecha5,dfecha6,dfecha7;
		--,dfecha8,dfecha9,dfecha10,dfecha11,dfecha12,dfecha13;
END
END PROCEDURE
DOCUMENT 
'Proceso para el calculo de fechas por periodo para la calificacion de cuentas_CORRIGIENDO LOS INHABILES E INCLUYENDO 7800 a QUINCENALES',
'BD    : bdicred';

CREATE PROCEDURE "informix".sp_consultaexcepcionesaumlincred(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechainicial DATE, pFechaFinal DATE,
		pExcepcion CHAR(3),	pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  INTEGER AS tieneCausa,
				  CHAR(100) AS descripcion,
				  INTEGER AS totalExcepcion,
				  DECIMAL(18,2) AS porcentaje,
				  INTEGER AS totalGeneral,
				  DECIMAL(18,2) AS totalPorcentaje;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE iNoRegs INTEGER;
	
	DEFINE cMensajeRetorno  CHAR(80);
	DEFINE iTieneCausa      INTEGER;
	DEFINE cDescripcion      CHAR(100);
	DEFINE iTotalExcepcion  INTEGER;
	DEFINE dPorcentaje       DECIMAL(18,2);
	DEFINE iTotalGeneral    INTEGER;
	DEFINE dTotalPorcentaje DECIMAL(18,2);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET iNoRegs = 0;
	
	LET cMensajeRetorno  = '';
	LET iTieneCausa      = 0;
	LET cDescripcion      = '';
	LET iTotalExcepcion  = 0;
	LET dPorcentaje      = 0;
	LET iTotalGeneral    = 0;
	LET dTotalPorcentaje = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTieneCausa, cDescripcion, iTotalexcepcion,  dPorcentaje, iTotalGeneral, dTotalPorcentaje;
		END EXCEPTION;
		
		ON EXCEPTION IN (-206)
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultaexcepcionesaumlincred.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechainicial = '' OR pFechaFinal = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTieneCausa, cDescripcion, iTotalexcepcion,  dPorcentaje, iTotalGeneral, dTotalPorcentaje;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, iTieneCausa, cDescripcion, iTotalexcepcion,  dPorcentaje, iTotalGeneral, dTotalPorcentaje;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTieneCausa, cDescripcion, iTotalexcepcion,  dPorcentaje, iTotalGeneral, dTotalPorcentaje;
		END IF;
		DROP TABLE tme_consultaincrementos;
		FOREACH EXECUTE PROCEDURE bdicred:'informix'.sp_cac_rep_excepciones2(pFechainicial, pFechaFinal, pExcepcion, pRegistros, pRecuperacion)
			INTO cCodRetSp, cMensajeRetorno, iTieneCausa, cDescripcion, iTotalexcepcion,  dPorcentaje, iTotalGeneral, dTotalPorcentaje
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_cac_rep_excepciones2';
			ELIF iCodRetSp = 000002 THEN
				LET cCodRet = '00388'; --PARÃ?ÂMETRO DE FECHA INVALIDO PARA REALIZAR  LA CONSULTA');
				RETURN cCodRet, iTieneCausa, cDescripcion, iTotalexcepcion,  dPorcentaje, iTotalGeneral, dTotalPorcentaje;
			ELIF iCodRetSp = 000001 THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iTieneCausa, cDescripcion, iTotalexcepcion,  dPorcentaje, iTotalGeneral, dTotalPorcentaje;
			ELSE
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet, iTieneCausa, cDescripcion, iTotalexcepcion,  dPorcentaje, iTotalGeneral, dTotalPorcentaje WITH RESUME;
			END IF;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iTieneCausa, cDescripcion, iTotalexcepcion,  dPorcentaje, iTotalGeneral, dTotalPorcentaje;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '01001';
			RETURN cCodRet, 0, '', 0,  0, 0, 0 ;
		END IF;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 08/09/2014',
'cDescripcion: Consulta que llena el grid de excepciones para los reportes de incrementos de lineas de crÃ?Â©dito',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_graba_prod_upgrade(pEmpresa CHAR(3),
pCredito CHAR(20) ,
pNumCte CHAR(20) ,
pNumTar CHAR(20) ,
pTit CHAR(3),
pNombre CHAR(107),
pEmbozado CHAR(21),
pMaster CHAR(1),
pTipoDom CHAR(1),
pUsuario CHAR(10),
pTipoProceso CHAR(1),--1 Manual 2 Masivo 3 Sucursal
pNombreArchivo CHAR(100),
pprod_upgrade CHAR(4)
)
RETURNING CHAR(6)         AS codigo_retorno,
          VARCHAR(100,1)  AS mensaje_retorno;

DEFINE nrows         INTEGER;
DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(6);
DEFINE cCodRetRep    CHAR(6);
DEFINE cMensajeRet   VARCHAR(100,1);
DEFINE cEmpresa      CHAR(3);
DEFINE cNumProducto  CHAR(4);
DEFINE cNomProducto  VARCHAR(100,1);
DEFINE cbandtarjpersonal CHAR(1);
DEFINE cmiembro 	CHAR(2);
DEFINE ccodflujo	CHAR(3);
DEFINE dFechaHoy    DATE;
DEFINE ccredito 	CHAR(20);
DEFINE ccliente 	CHAR(20);
DEFINE cnumerotarjeta  CHAR(20);
DEFINE cvalor       CHAR(100);

LET nrows         = 0;
LET iSqlErr       = 0;
LET iIsamErr      = 0;
LET cErrorInfo    = '';
LET cCodRet       = '000000';
LET cCodRetRep    = '000000';
LET cMensajeRet   = 'PROCESO EXITOSO.';

LET cEmpresa      = '';
LET cNumProducto  = '';
LET cNomProducto  = '';
LET cbandtarjpersonal= '1';
LET cmiembro = '';

LET ccredito = NULL;
LET ccliente = NULL;
LET cnumerotarjeta = NULL;
LET dFechaHoy = NULL;
LET ccodflujo = '';

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = cErrorInfo;
      RETURN cCodRet, cMensajeRet;
    END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/tmp/sp_graba_prod_upgrade.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT empresa
INTO cEmpresa
FROM bdinteg:si_empresas
WHERE empresa= pEmpresa;

IF TRIM(NVL(cEmpresa,'')) = '' OR pTipoProceso = '' THEN
  LET cCodRet = '000001';
  LET cMensajeRet = 'EL PARÁMETRO NO ES VALIDO';
  RETURN cCodRet, cMensajeRet;
END IF;

SELECT fecha_hoy
INTO dFechaHoy
FROM bdicred:"informix".sd_fechas;
		
SELECT valor
INTO cvalor
FROM bdicred:"informix".sd_param
WHERE cod_param = '055';

IF pMaster = '1' Then
	SELECT substr(YEAR(fecha_apertura),3,2)
	INTO cmiembro
	FROM bdicred:"informix".sd_maecred
	WHERE num_credito = pCredito;


	IF pTipoProceso IN ('1','3') THEN
	--AAME 20190624 Solicitud de BD eliminar IF NOT EXISTS
		SELECT num_credito 
		INTO ccredito 
		FROM "informix".sd_credito_upgrade
		WHERE num_credito = pCredito and numcte = pNumCte;
		
		IF NVL(ccredito,'') = '' THEN

			--IF pTipoProceso = '3' THEN
			--	LET cbandtarjpersonal = '2';
			--END IF;
				-- AAME 20160901 SE AGREGA BANDERA PARA PROCESO NOCTURNO
				INSERT INTO  "informix".sd_credito_upgrade (empresa ,num_credito,numcte ,numerotarjeta ,numero_credito_upgrade, numerotarjeta_upgrade, num_producto_upgrade,tipoTar ,nombre,nombre_embosado ,bandtarjpersonal,tipo_proceso, nombre_archivo,master,Tipo_dom,miembro,Resultado,bclonadocompleto,user_insert ,fecha_insert,fecha_cancelaupgrade)
				VALUES (pEmpresa ,pCredito ,pNumCte, pNumTar, "","",pprod_upgrade,pTit ,pNombre ,pEmbozado, cbandtarjpersonal,pTipoProceso,pNombreArchivo,pMaster , pTipoDom ,cmiembro,"0","0", pUsuario ,CURRENT,NULL);
				
		ELSE
		
			 --- AAME 20190218 RQM 10682-4 Se afecta para consultar si fue cancelado volver activarse
			SELECT num_credito
			INTO ccredito
			FROM bdicred:"informix".sd_credito_upgrade a
			WHERE a.num_credito = pCredito
			AND a.resultado = '3';
			
			IF NVL(ccredito,'') <> '' THEN			
				UPDATE bdicred:"informix".sd_credito_upgrade SET numerotarjeta = pNumTar, nombre_embosado = pEmbozado, tipo_dom = pTipoDom, nombre_archivo ='', resultado = '0', fecha_insert = dFechaHoy WHERE num_credito = ccredito AND resultado = '3'; 
			ELSE					
				  LET cCodRet = '000002';
				  LET cMensajeRet = 'YA EXISTE LA SOLICITUD DE UPGRADE PARA ESTE CRÉDITO';
			END IF;  
			-----------		
  			  
			  RETURN cCodRet, cMensajeRet;
		END IF;
	ELIF pTipoProceso = '2' THEN
		--AAME 20190624 Solicitud de BD eliminar IF NOT EXISTS
		SELECT num_credito  INTO ccredito
		FROM "informix".sd_credito_upgrade
		WHERE nombre_archivo = pNombreArchivo 
		AND num_credito = pCredito and numcte = pNumCte;
		
		IF NVL(ccredito,'') = '' THEN
			SELECT num_credito INTO ccredito 
			FROM "informix".sd_credito_upgrade
			WHERE num_credito = pCredito and numcte = pNumCte;
			
			IF NVL(ccredito,'') = '' THEN
				-- AAME 20160901 SE AGREGA BANDERA PARA PROCESO NOCTURNO
				INSERT INTO  "informix".sd_credito_upgrade (empresa ,num_credito,numcte ,numerotarjeta ,numero_credito_upgrade,numerotarjeta_upgrade, num_producto_upgrade,tipoTar ,nombre,nombre_embosado ,bandtarjpersonal,tipo_proceso, nombre_archivo,master ,Tipo_dom,miembro,Resultado,bclonadocompleto,user_insert ,fecha_insert,fecha_cancelaupgrade)
				VALUES (pEmpresa ,pCredito ,pNumCte, pNumTar, "","",pprod_upgrade,pTit ,pNombre ,pEmbozado, cbandtarjpersonal,pTipoProceso,pNombreArchivo,pMaster , pTipoDom ,cmiembro,"0","0", pUsuario ,CURRENT,NULL);
				
				LET cMensajeRet = 'PROCESO EXITOSO';
				-- AAME 20190218 RQM 10682-4 SE GUARDA INFORMACIÓN DE REPORTERÍA
				EXECUTE PROCEDURE "informix".sp_grabadetallearchivotdc(pCredito, pNumTar, pprod_upgrade, pTit, pNombre ,'0','SI','NO',cMensajeRet,pUsuario,pNombreArchivo,dFechaHoy)
				INTO cCodRetRep,cMensajeRet;
					
			ELSE
				 --- AAME 20190218 RQM 10682-4 Se afecta para consultar si fue cancelado volver activarse
				SELECT num_credito
				INTO ccredito
				FROM bdicred:"informix".sd_credito_upgrade a
				WHERE a.num_credito = pCredito
				AND a.resultado = '3';
				
				IF NVL(ccredito,'') <> '' THEN			
					UPDATE bdicred:"informix".sd_credito_upgrade SET numerotarjeta = pNumTar, nombre_embosado = pEmbozado, tipo_dom = pTipoDom, nombre_archivo = pNombreArchivo, resultado = '0', user_insert = pUsuario, fecha_insert = dFechaHoy WHERE num_credito = ccredito AND resultado = '3'; 
					LET cMensajeRet = 'PROCESO EXITOSO';
					-- AAME 20190218 RQM 10682-4 SE GUARDA INFORMACIÓN DE REPORTERÍA
					EXECUTE PROCEDURE "informix".sp_grabadetallearchivotdc(pCredito, pNumTar, pprod_upgrade, pTit, pNombre ,'0','SI','NO',cMensajeRet,pUsuario,pNombreArchivo,dFechaHoy)
					INTO cCodRetRep,cMensajeRet;					
				ELSE					
					IF substr(pNombreArchivo,1,13) = 'CAMBIOPRODTDC' THEN
					  LET cCodRet = '000002';
					  LET cMensajeRet = 'YA EXISTE LA SOLICITUD DE UPGRADE PARA ESTE CRÉDITO';					 
						--- AAME 20190218 RQM 10682-4 SE GUARDA INFORMACIÓN DE REPORTERÍA
						EXECUTE PROCEDURE "informix".sp_grabadetallearchivotdc(pCredito ,pNumTar,pprod_upgrade,pTit, pNombre,'1','NO','NO',cMensajeRet,pUsuario,pNombreArchivo,dFechaHoy)
						INTO cCodRetRep,cMensajeRet;
					END IF; 
				END IF;	
				
				RETURN cCodRet, cMensajeRet;
			END IF;
		ELSE
			LET cCodRet = '000002';
			IF substr(pNombreArchivo,1,13) = 'CAMBIOPRODTDC' THEN
			  LET cMensajeRet = 'YA EXISTE LA CARGA DE ESTE ARCHIVO PARA UPGRADE';
			END IF;
			RETURN cCodRet, cMensajeRet;
		END IF;
	END IF;
ELSE
	  LET cCodRet = '000003';
	  LET cMensajeRet = 'Se requiere seleccionar opción Master para poder continuar';
	  RETURN cCodRet, cMensajeRet;
END IF;

 RETURN cCodRet, cMensajeRet;
END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para grabar la información referente a la solicitud del upgrade del producto ',
'AUTOR : Maria Elena Angulo Aispuro',
'FECHA : 22/02/2018',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_grabadetallearchivotdc(pCredito CHAR(20) ,
pNumTar CHAR(20) ,
pproducto CHAR(4),
pTipotar CHAR(3),
pNombre CHAR(107),
pError CHAR(1),
pMarcaje CHAR(3),
pSol_plastico CHAR(2),
pMsj_error CHAR(120),
pUsuario CHAR(8),
pNombreArchivo CHAR(35),
pFechaInsert DATE
)
RETURNING CHAR(6)         AS codigo_retorno,
          VARCHAR(100,1)  AS mensaje_retorno;

DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(6);
DEFINE cMensajeRet   VARCHAR(100,1);
DEFINE cTipoArchivo  CHAR(1);
DEFINE dFechaHoy     DATE;
DEFINE cmarcaje		 CHAR(3);
DEFINE csolplastico  CHAR(2);
DEFINE cerror		 CHAR(1);
DEFINE cmsj_error    VARCHAR(100,1);
DEFINE crptupgrade   CHAR(20);
--AAME RQM 10 682-4 Variables para obtener el nombre completo del cte
DEFINE cNumCte  CHAR(107);
DEFINE cnombre1 CHAR(26); 
DEFINE cnombre2 CHAR(26);
DEFINE capell_paterno CHAR(26);             
DEFINE capell_materno CHAR(26);
DEFINE cnumtarjeta CHAR(20);

LET iSqlErr       = 0;
LET iIsamErr      = 0;
LET cErrorInfo    = '';
LET cCodRet       = '000000';
LET cMensajeRet   = 'Se realizó la consulta correctamente.';
LET cTipoArchivo  = ''; -- 1 Upgrade , 2  Reposicion
LET dFechaHoy     = DATE(1);
LET cmarcaje      = '';
LET csolplastico  = '';
LET cerror		  = '';
LET cmsj_error    = ''; -- 0 Exito, 1 Error, 3 Cancelar
LET crptupgrade   = '';
--AAME RQM 10 682-4 Variables para obtener el nombre completo del cte
LET cNumCte = '';
LET cnombre1 = ''; 
LET cnombre2 = '';
LET capell_paterno = '';               
LET capell_materno = '';
LET cnumtarjeta ='';

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = cErrorInfo;
      RETURN cCodRet, cMensajeRet;
    END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/tmp/sp_grabadetallearchivotdc.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

IF NVL(pUsuario,'') = '' THEN
  LET cCodRet = '000001';
  LET cMensajeRet = 'El parámetro no es valido';
  RETURN cCodRet, cMensajeRet;
END IF;

SELECT fecha_hoy
INTO dFechaHoy
FROM "informix".sd_fechas;
	
IF NVL(pCredito,'') <> '' THEN
	--AAME RQM 10 682-4 Se agrega liga a la tabla bdinteg:si_cliente para extraer el nombre completo del cliente para la reportería

	IF NVL(pTipotar,'') = 'TIT' THEN
		SELECT limit 1 numcte
		INTO cNumCte
		FROM bdicred:"informix".sd_maecred 
		WHERE num_credito = pCredito;
		IF NVL(pNumTar,'') = '' THEN 
			SELECT num_tarjeta
			INTO cnumtarjeta
			FROM bdicred:"informix".sd_tarjeta 
			WHERE num_credito = pCredito AND tipo_tarjeta ='T' AND status_tar ='A';		
		ELSE
			LET cnumtarjeta = pNumTar;			
		END IF;
		
	ELIF NVL(pTipotar,'') = 'ADI' THEN
		SELECT limit 1 numcte,num_tarjeta
		INTO cNumCte, cnumtarjeta
		FROM bdicred:"informix".sd_tarjeta 
		WHERE num_credito = pCredito AND tipo_tarjeta ='A' AND status_tar ='A';	
		IF NVL(pNumTar,'') <> '' THEN 
			LET cnumtarjeta = pNumTar;
		END IF;
	END IF;

	SELECT nombre1, nombre2, apell_paterno, apell_materno 
	INTO cnombre1, cnombre2, capell_paterno, capell_materno
	FROM bdinteg:"informix".si_cliente
	WHERE numcte = cNumCte;
	
	LET pNombre = TRIM(NVL(cnombre1,'')) || " " || TRIM(NVL(cnombre2,'')) || " " || TRIM(NVL(capell_paterno,'')) || " " || TRIM(NVL(capell_materno,''));	
END IF; 

IF 	pError IN (0,1) THEN	
	--cTipoArchivo  1 Upgrade , 2  Reposicion		
	IF substr(pNombreArchivo,1,16) = 'CAMBIOPRODTDCREP' Then
		LET cTipoArchivo = '2';
		LET pMarcaje = 'N/A';
		IF pError = '0' THEN			
			LET pSol_plastico = 'SI';
		ELSE
			LET pSol_plastico = 'NO';
		END IF;		
	ELSE
		LET cTipoArchivo = '1';

	END IF;
	
	LET pTipotar = substr(pTipotar,1,1);
	-- RQM 10 682-4 Se contempla la consulta a la tabla de Reportería de la información con los errores presentados al realizar la marca o solicitar plasticos
	SELECT limit 1 num_credito, error_proceso, marcaje, sol_plastico, mensaje_error
	INTO crptupgrade, cerror, cmarcaje, csolplastico,  cmsj_error
	FROM "informix".sd_rep_detallearchivotdc
	WHERE num_tarjeta = cnumtarjeta 
	AND nombre_archivo = pNombreArchivo;
	
	IF NVL(crptupgrade,'') = '' THEN	
		-- SE REGISTRA INFORMACIÓN EN LA TABLA DE REPORTERÍA
		INSERT INTO "informix".sd_rep_detallearchivotdc(num_credito,num_tarjeta,prod_destino,
		tipo_tarjeta,nombre,tipo_archivo,nombre_archivo,error_proceso, marcaje, sol_plastico,mensaje_error,usuario,fecha_insert)
		VALUES (pCredito ,pNumTar, pproducto, pTipotar, pNombre, cTipoArchivo, pNombreArchivo, pError, pMarcaje,
		pSol_plastico, pMsj_error, pUsuario, dFechaHoy);

	ELSE	
		IF cTipoArchivo ='1' AND cmarcaje = 'SI' AND  csolplastico = 'NO'   THEN
			IF pError = '0' THEN
				LET csolplastico = 'SI';
			ELSE 
				LET csolplastico = 'NO';
			END IF;
			/*IF NVL(pCredito,'') <> '' THEN
				UPDATE "informix".sd_rep_detallearchivotdc SET error_proceso = pError, marcaje = cmarcaje, sol_plastico = csolplastico, mensaje_error= pMsj_error 
				WHERE num_credito = pCredito 
				AND num_tarjeta = cnumtarjeta 
				AND nombre_archivo = pNombreArchivo;
			ELIF NVL(pNumTar,'') <> '' THEN*/
			UPDATE "informix".sd_rep_detallearchivotdc SET error_proceso = pError, marcaje = cmarcaje, sol_plastico = csolplastico, mensaje_error= pMsj_error 
			WHERE num_tarjeta = cnumtarjeta   
			AND nombre_archivo = pNombreArchivo;
			--END IF;
			
		ELIF cTipoArchivo ='2' THEN-- RQM 10 682-4 Se contempla solo para solicitud de plástico para reposición
				IF pError = '0' THEN
					LET csolplastico = 'SI';
				ELSE 
					LET csolplastico = 'NO';
				END IF;
				--IF NVL(pCredito,'') <> '' THEN
				UPDATE "informix".sd_rep_detallearchivotdc SET error_proceso = pError, marcaje = 'N/A', sol_plastico = csolplastico, mensaje_error= pMsj_error 
				WHERE num_tarjeta = cnumtarjeta 
				AND nombre_archivo = pNombreArchivo;
				/*ELIF NVL(pNumTar,'') <> '' THEN
					UPDATE "informix".sd_rep_detallearchivotdc SET error_proceso = pError, marcaje = 'N/A', sol_plastico = csolplastico, mensaje_error= pMsj_error 
					WHERE num_tarjeta = pNumTar  
					AND nombre_archivo = pNombreArchivo;					
				END IF;*/
		END IF;
	END IF;
 ELIF pError IN (3) THEN
		-- RQM 10 682-4 Se contempla la opción de error 3 para el borrado de Reportería de la información en caso de que el cliente cancele el procesar.
		DELETE
		FROM "informix".sd_rep_detallearchivotdc
		WHERE nombre_archivo = pNombreArchivo AND fecha_insert = pFechaInsert;
		
 END IF;
	
 RETURN cCodRet, cMensajeRet;
END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para grabar la información de reportería referente a la solicitud del upgrade de producto y plásticos para reposición',
'AUTOR : Maria Elena Angulo Aispuro',
'FECHA : 12/02/2019',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_rep_prod_upgrade2(pEmpresa CHAR(3),
pFechaIni DATE,
pFechaFin DATE,
pTipo CHAR(1),
pStatus CHAR(1),
pArchivo CHAR(50),
pRegistros INTEGER, 
pRecuperacion INTEGER
)
RETURNING CHAR(6)        AS codigo_retorno,
          VARCHAR(100,1) AS mensaje_retorno,
          VARCHAR(20,1)  AS num_credito,
		  VARCHAR(20,1)  AS num_tarjeta,		  
          VARCHAR(10,1)  AS tipo_tarjeta,
		  VARCHAR(100,1) AS nombre,
		  DATE 			 AS fecha,
          CHAR(15) 		 AS resultado,
		  CHAR(3)        AS marcaje,
		  CHAR(2)		 AS sol_plastico,
		  VARCHAR(100,1) AS mensaje_error;
		  		  
DEFINE nrows         INTEGER;
DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(6);
DEFINE cMensajeRet   VARCHAR(100,1);
DEFINE cEmpresa      CHAR(3);
DEFINE cNombre       CHAR(100);
DEFINE cNumCredito   CHAR(20);
DEFINE cTipo_Tarjeta  CHAR(10);
DEFINE cfecha		  DATE;
DEFINE cresultado     CHAR(15);
DEFINE cMarcaje 	  CHAR(3);
DEFINE cSolPlastico   CHAR(2);
DEFINE cMensajeError  VARCHAR(100,1);
DEFINE cNumTarjeta    CHAR(20);
DEFINE cTipoArchivo   CHAR(1);
DEFINE cnomarchivo	  CHAR(50);
--AAME 20190624 Se considera nva variable de tipo datetime para la busqueda en la tabla bdicred:sd_credito_upgrade para eliminar el casteo en consulta
DEFINE dtFechaIni 	DATETIME YEAR TO FRACTION;
DEFINE dtFechaFin 	DATETIME YEAR TO FRACTION;

LET nrows         = 0;
LET iSqlErr       = 0;
LET iIsamErr      = 0;
LET cErrorInfo    = '';
LET cCodRet       = '000000';
LET cMensajeRet   = 'Se realizó la consulta correctamente.';

LET cEmpresa      = '';
LET cNombre  = '';
LET cNumCredito = '';
LET cTipo_Tarjeta = '';
LET cfecha = date(1);
LET cresultado = '';
LET cNumTarjeta = '';
LET cMarcaje = '';
LET cSolPlastico = '';
LET cMensajeError = '';
LET cTipoArchivo = '';
LET cnomarchivo = '';
--AAME 20190624
LET dtFechaIni = pFechaIni::DATETIME YEAR TO FRACTION;
LET dtFechaFin = pFechaFin::DATETIME YEAR TO FRACTION;


BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = cErrorInfo;
      RETURN cCodRet, cMensajeRet, NVL(cNumCredito,''), NVL(cNumTarjeta,''), NVL(cTipo_Tarjeta,''), NVL(cNombre,''), NVL(cfecha,DATE(1)), NVL(cresultado,''), NVL(cMarcaje,''), NVL(cSolPlastico,''), NVL(cMensajeError,'');
    END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/tmp/mfinis/sp_rep_prod_upgrade2.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT empresa
INTO cEmpresa
FROM bdinteg:si_empresas
WHERE empresa= pEmpresa;

IF TRIM(NVL(cEmpresa,'')) = ''    THEN
  LET cCodRet = '000001';
  LET cMensajeRet = 'El parámetro no es valido';
  --RETURN cCodRet, cMensajeRet,"","","","","","";
  RETURN cCodRet, cMensajeRet, NVL(cNumCredito,''), NVL(cNumTarjeta,''), NVL(cTipo_Tarjeta,''), NVL(cNombre,''), NVL(cfecha,DATE(1)), NVL(cresultado,''), NVL(cMarcaje,''), NVL(cSolPlastico,''), NVL(cMensajeError,'');
END IF;

IF  pTipo = '1' then

	IF NVL(pArchivo,'') ='' THEN
		FOREACH WITH HOLD
		-- RQM 10 682-4 Se contempla la consulta a la tabla de Reportería de la información con los errores presentados la realizar la marca o solicitar plasticos
			SELECT SKIP pRegistros FIRST pRecuperacion distinct (nombre_archivo)
			INTO cNombre
			FROM "informix".sd_rep_detallearchivotdc
			WHERE fecha_insert BETWEEN pFechaIni and pFechaFin
		
			--RETURN cCodRet, cMensajeRet,cNombre,"","","","","" WITH resume;
			RETURN cCodRet, cMensajeRet, NVL(cNumCredito,''), NVL(cNumTarjeta,''), NVL(cTipo_Tarjeta,''), NVL(cNombre,''), NVL(cfecha,DATE(1)), NVL(cresultado,''), NVL(cMarcaje,''), NVL(cSolPlastico,''), NVL(cMensajeError,'') WITH resume;

		END FOREACH;
		-- RQM 10 682-4 Se consulta de la tabla de upgrade para los primeros casos en que se libere el cambio y la tabla de reportería no devuelva información de los archivos previos cargados
		IF NVL(cNombre,'') = '' THEN
			FOREACH WITH HOLD
				SELECT SKIP pRegistros FIRST pRecuperacion distinct (nombre_archivo)
				INTO cNombre
				FROM "informix".sd_credito_upgrade
				WHERE empresa = pEmpresa
				AND fecha_insert BETWEEN dtFechaIni and dtFechaFin
			
				--RETURN cCodRet, cMensajeRet,cNombre,"","","","","" WITH resume;
				RETURN cCodRet, cMensajeRet, NVL(cNumCredito,''), NVL(cNumTarjeta,''), NVL(cTipo_Tarjeta,''), NVL(cNombre,''), NVL(cfecha,DATE(1)), NVL(cresultado,''), NVL(cMarcaje,''), NVL(cSolPlastico,''), NVL(cMensajeError,'') WITH resume;

			END FOREACH;			
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			   LET cCodRet= '000002';
			   LET cMensajeRet= 'No existen archivos cargados en el periodo especificado';
			      --RETURN cCodRet, cMensajeRet,"","","","","","";
				  RETURN cCodRet, cMensajeRet, NVL(cNumCredito,''), NVL(cNumTarjeta,''), NVL(cTipo_Tarjeta,''), NVL(cNombre,''), NVL(cfecha,DATE(1)), NVL(cresultado,''), NVL(cMarcaje,''), NVL(cSolPlastico,''), NVL(cMensajeError,'');
			END IF;
			
		END IF;		
				
	ELSE

		FOREACH WITH HOLD
		-- RQM 10 682-4 Se contempla la consulta a la tabla de Reportería de la información con los errores presentados la realizar la marca o solicitar plasticos
			SELECT SKIP pRegistros FIRST pRecuperacion num_credito, num_tarjeta, tipo_tarjeta, nombre, fecha_insert, error_proceso,mensaje_error, tipo_archivo, marcaje 
			INTO  cNumCredito,cNumTarjeta,cTipo_Tarjeta,cNombre,cfecha,cresultado,cMensajeError,cTipoArchivo, cMarcaje
			FROM "informix".sd_rep_detallearchivotdc
			WHERE nombre_archivo = pArchivo
			AND fecha_insert BETWEEN pFechaIni and pFechaFin
			
			IF NVL(cTipo_Tarjeta,'') ='T' THEN
				LET cTipo_Tarjeta = 'TITULAR';
			ELIF NVL(cTipo_Tarjeta,'') ='A' THEN
				LET cTipo_Tarjeta = 'ADICIONAL';
			END IF;
			--cTipoArchivo  1 Upgrade , 2  Reposicion	
			IF NVL(cresultado,'') = '0' THEN
				LET cresultado = 'EXITOSO';
				IF cTipoArchivo = '1' THEN 
					LET cMarcaje = 'SI'; LET cSolPlastico ='SI';
				ELSE
					LET cMarcaje = 'N/A'; LET cSolPlastico ='SI';
				END IF;
				LET cMensajeError = '';
			ELSE
				LET cresultado = 'NO EXITOSO';

				IF NVL(cTipoArchivo,'') = '1' THEN 
					IF NVL(cMarcaje,'') = '' THEN
						LET cMarcaje = 'NO';
					END IF;				
					LET cSolPlastico ='NO';					
				ELSE
					LET cMarcaje = 'N/A'; LET cSolPlastico ='NO';
				END IF;			
				
			END IF;
			
			RETURN cCodRet, cMensajeRet, NVL(cNumCredito,''), NVL(cNumTarjeta,''), NVL(cTipo_Tarjeta,''), NVL(cNombre,''), NVL(cfecha,DATE(1)), NVL(cresultado,''), NVL(cMarcaje,''), NVL(cSolPlastico,''), NVL(cMensajeError,'') WITH resume;
			--RETURN cCodRet, cMensajeRet,cNombre,cNumCredito,cTipo_Tarjeta,cmiembro,cfecha,cresultado WITH resume;

		END FOREACH;
		-- RQM 10 682-4 Se consulta de la tabla de upgrade para los primeros casos en que se libere el cambio y la tabla de reportería no devuelva información de los archivos previos cargados
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			FOREACH WITH HOLD
				SELECT SKIP pRegistros FIRST pRecuperacion num_credito, numerotarjeta, tipoTar, --DECODE(tipoTar,'TIT','TITULAR','ADICIONAL'),
				nombre, fecha_insert, resultado,nombre_archivo--DECODE(Resultado,'0','EXITOSO','1','EXITOSO','NO EXITOSO')
				INTO  cNumCredito,cNumTarjeta,cTipo_Tarjeta,cNombre,cfecha,cresultado,cnomarchivo
				FROM "informix".sd_credito_upgrade
				WHERE empresa = pEmpresa
				AND fecha_insert BETWEEN dtFechaIni and dtFechaFin
				AND nombre_archivo = pArchivo
				
				IF NVL(cTipo_Tarjeta,'') ='TIT' THEN
					LET cTipo_Tarjeta = 'TITULAR';
				ELIF NVL(cTipo_Tarjeta,'') ='ADI' THEN
					LET cTipo_Tarjeta = 'ADICIONAL';
				END IF;				
				
				--Se valida el tipo de Archivo
				IF substr(cnomarchivo,1,16) ='CAMBIOPRODTDCREP' THEN
					LET cTipoArchivo = '2';
				ELSE
					LET cTipoArchivo = '1';
				END IF;
				IF NVL(cresultado,'') IN ('0','1') THEN
					LET cresultado = 'EXITOSO';
				
					IF cTipoArchivo = '1' THEN 
						LET cMarcaje = 'SI'; LET cSolPlastico ='SI';
					ELSE
						LET cMarcaje = 'N/A'; LET cSolPlastico ='SI';
					END IF;
					LET cMensajeError = '';					
				ELSE 
					LET cresultado = 'NO EXITOSO';
					IF NVL(cTipoArchivo,'') = '1' THEN 
						IF NVL(cnomarchivo,'') = '' THEN
							LET cMarcaje = 'NO';
						END IF;				
						LET cSolPlastico ='NO';
					ELSE
						LET cMarcaje = 'N/A'; LET cSolPlastico ='NO';
					END IF;		
				END IF;				

			RETURN cCodRet, cMensajeRet, NVL(cNumCredito,''), NVL(cNumTarjeta,''), NVL(cTipo_Tarjeta,''), NVL(cNombre,''), NVL(cfecha,DATE(1)), NVL(cresultado,''), NVL(cMarcaje,''), NVL(cSolPlastico,''), NVL(cMensajeError,'') WITH resume;
			
			END FOREACH;
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				   LET cCodRet= '000002';
				   LET cMensajeRet= 'No existe información del archivo en el periodo seleccionado';
				   --RETURN cCodRet, cMensajeRet,"","","","","","";
				   RETURN cCodRet, cMensajeRet, NVL(cNumCredito,''), NVL(cNumTarjeta,''), NVL(cTipo_Tarjeta,''), NVL(cNombre,''), NVL(cfecha,DATE(1)), NVL(cresultado,''), NVL(cMarcaje,''), NVL(cSolPlastico,''), NVL(cMensajeError,'');
			END IF;			
		END IF;	

	END IF;
ELIF pTipo = '2' THEN

	--AAME RQM 10 682-4 Valida que se contemple el tipo de estatus que seleccione el cliente para la busqueda 'TODOS'
	IF pStatus = '1' THEN
		FOREACH WITH HOLD
		-- RQM 10 682-4 Se contempla la consulta a la tabla de Reportería de la información con los errores presentados la realizar la marca o solicitar plasticos
			SELECT SKIP pRegistros FIRST pRecuperacion num_credito, num_tarjeta, tipo_tarjeta,--DECODE(tipoTar,'TIT','TITULAR','ADICIONAL'),
			nombre, fecha_insert, error_proceso,mensaje_error, tipo_archivo, marcaje --DECODE(Resultado,'0','EN PROCESO','1','OK','ERROR')
			INTO  cNumCredito,cNumTarjeta,cTipo_Tarjeta,cNombre,cfecha,cresultado,cMensajeError,cTipoArchivo, cMarcaje
			FROM "informix".sd_rep_detallearchivotdc
			WHERE fecha_insert BETWEEN pFechaIni and pFechaFin
			
			IF NVL(cTipo_Tarjeta,'') ='T' THEN
				LET cTipo_Tarjeta = 'TITULAR';
			ELIF NVL(cTipo_Tarjeta,'') ='ADI' THEN
				LET cTipo_Tarjeta = 'ADICIONAL';
			END IF;
			--cTipoArchivo  1 Upgrade , 2  Reposicion	
			IF NVL(cresultado,'') = '0' THEN
				LET cresultado = 'EXITOSO';
				IF cTipoArchivo = '1' THEN 
					LET cMarcaje = 'SI'; LET cSolPlastico ='SI';
				ELSE
					LET cMarcaje = 'N/A'; LET cSolPlastico ='SI';
				END IF;
				LET cMensajeError = '';
			ELSE
				LET cresultado = 'NO EXITOSO';
				IF NVL(cTipoArchivo,'') = '1' THEN 
					IF NVL(cMarcaje,'') = '' THEN
						LET cMarcaje = 'NO';
					END IF;		 
					LET cSolPlastico ='NO';
				ELSE
					LET cMarcaje = 'N/A'; LET cSolPlastico ='NO';
				END IF;			
				
			END IF;
			
			RETURN cCodRet, cMensajeRet, NVL(cNumCredito,''), NVL(cNumTarjeta,''), NVL(cTipo_Tarjeta,''), NVL(cNombre,''), NVL(cfecha,DATE(1)), NVL(cresultado,''), NVL(cMarcaje,''), NVL(cSolPlastico,''), NVL(cMensajeError,'') WITH resume;
			--RETURN cCodRet, cMensajeRet,cNombre,cNumCredito,cTipo_Tarjeta,cmiembro,cfecha,cresultado WITH resume;

		END FOREACH;
			
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		-- RQM 10 682-4 Se consulta de la tabla de upgrade para los primeros casos en que se libere el cambio y la tabla de reportería no devuelva información de los archivos previos cargados
			FOREACH WITH HOLD
				SELECT SKIP pRegistros FIRST pRecuperacion num_credito, numerotarjeta, tipoTar,--DECODE(tipoTar,'TIT','TITULAR','ADICIONAL'),
			    nombre, fecha_insert, Resultado,nombre_archivo--, tipo_archivo --DECODE(Resultado,'0','EN PROCESO','1','OK','ERROR')
			    INTO  cNumCredito,cNumTarjeta,cTipo_Tarjeta,cNombre,cfecha,cresultado,cnomarchivo--,cTipoArchivo
				FROM "informix".sd_credito_upgrade
				WHERE empresa = pEmpresa
				AND fecha_insert BETWEEN dtFechaIni and dtFechaFin
				AND tipo_proceso = 2
				
				IF NVL(cTipo_Tarjeta,'') ='TIT' THEN
					LET cTipo_Tarjeta = 'TITULAR';
				ELIF NVL(cTipo_Tarjeta,'') ='ADI' THEN
					LET cTipo_Tarjeta = 'ADICIONAL';
				END IF;		
				--Se valida el tipo de Archivo
				IF substr(cnomarchivo,1,16) ='CAMBIOPRODTDCREP' THEN
					LET cTipoArchivo = '2';
				ELSE
					LET cTipoArchivo = '1';
				END IF;
				IF NVL(cresultado,'') IN ('0','1') THEN
					LET cresultado = 'EXITOSO';
				
					IF cTipoArchivo = '1' THEN 
						LET cMarcaje = 'SI'; LET cSolPlastico ='SI';
					ELSE
						LET cMarcaje = 'N/A'; LET cSolPlastico ='SI';
					END IF;
					LET cMensajeError = '';					
				ELSE 
					LET cresultado = 'NO EXITOSO';
					IF NVL(cTipoArchivo,'') = '1' THEN 
						IF NVL(cnomarchivo,'') = '' THEN
							LET cMarcaje = 'NO';
						END IF;				
						LET cSolPlastico ='NO';
					ELSE
						LET cMarcaje = 'N/A'; LET cSolPlastico ='NO';
					END IF;		
				END IF;

			RETURN cCodRet, cMensajeRet, NVL(cNumCredito,''), NVL(cNumTarjeta,''), NVL(cTipo_Tarjeta,''), NVL(cNombre,''), NVL(cfecha,DATE(1)), NVL(cresultado,''), NVL(cMarcaje,''), NVL(cSolPlastico,''), NVL(cMensajeError,'') WITH resume;
			
			END FOREACH;
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				   LET cCodRet= '000002';
				   LET cMensajeRet= 'No existe información del archivo en el periodo seleccionado';
				   --RETURN cCodRet, cMensajeRet,"","","","","","";
				   RETURN cCodRet, cMensajeRet, NVL(cNumCredito,''), NVL(cNumTarjeta,''), NVL(cTipo_Tarjeta,''), NVL(cNombre,''), NVL(cfecha,DATE(1)), NVL(cresultado,''), NVL(cMarcaje,''), NVL(cSolPlastico,''), NVL(cMensajeError,'');
			END IF;		
		END IF;	
	ELSE --AAME RQM 10 682-4 Valida que se contemple el tipo de estatus que seleccione el cliente para la busqueda 
		IF pStatus = '2' THEN --EXITO
			LET pStatus = '0'; 
		ELIF pStatus = '3' THEN --NO EXITOSO
			LET pStatus = '1'; 
		END IF;
		FOREACH WITH HOLD
		-- RQM 10 682-4 Se contempla la consulta a la tabla de Reportería de la información con los errores presentados la realizar la marca o solicitar plasticos
			SELECT SKIP pRegistros FIRST pRecuperacion num_credito, num_tarjeta, tipo_tarjeta,--DECODE(tipoTar,'TIT','TITULAR','ADICIONAL'),
			nombre, fecha_insert, error_proceso,mensaje_error, tipo_archivo,marcaje --DECODE(Resultado,'0','EN PROCESO','1','OK','ERROR')
			INTO  cNumCredito,cNumTarjeta,cTipo_Tarjeta,cNombre,cfecha,cresultado,cMensajeError,cTipoArchivo,cMarcaje
			FROM "informix".sd_rep_detallearchivotdc
			WHERE error_proceso = pStatus
			AND fecha_insert BETWEEN pFechaIni and pFechaFin
			
			IF NVL(cTipo_Tarjeta,'') ='T' THEN
				LET cTipo_Tarjeta = 'TITULAR';
			ELIF NVL(cTipo_Tarjeta,'') ='A' THEN
				LET cTipo_Tarjeta = 'ADICIONAL';
			END IF;
			--cTipoArchivo  1 Upgrade , 2  Reposicion	
			IF NVL(cresultado,'') = '0' THEN
				LET cresultado = 'EXITOSO';
				IF cTipoArchivo = '1' THEN 
					LET cMarcaje = 'SI'; LET cSolPlastico ='SI';
				ELSE
					LET cMarcaje = 'N/A'; LET cSolPlastico ='SI';
				END IF;
				LET cMensajeError = '';
			ELSE
				LET cresultado = 'NO EXITOSO';
				IF NVL(cTipoArchivo,'') = '1' THEN 
					IF NVL(cMarcaje,'') = '' THEN
						LET cMarcaje = 'NO';
					END IF;		
					LET cSolPlastico ='NO';
				ELSE
					LET cMarcaje = 'N/A'; LET cSolPlastico ='NO';
				END IF;			
				
			END IF;
			
			RETURN cCodRet, cMensajeRet, NVL(cNumCredito,''), NVL(cNumTarjeta,''), NVL(cTipo_Tarjeta,''), NVL(cNombre,''), NVL(cfecha,DATE(1)), NVL(cresultado,''), NVL(cMarcaje,''), NVL(cSolPlastico,''), NVL(cMensajeError,'') WITH resume;
			--RETURN cCodRet, cMensajeRet,cNombre,cNumCredito,cTipo_Tarjeta,cmiembro,cfecha,cresultado WITH resume;

		END FOREACH;
			
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		-- RQM 10 682-4 Se consulta de la tabla de upgrade para los primeros casos en que se libere el cambio y la tabla de reportería no devuelva información de los archivos previos cargados
			FOREACH WITH HOLD
				SELECT SKIP pRegistros FIRST pRecuperacion num_credito, numerotarjeta, tipoTar,--DECODE(tipoTar,'TIT','TITULAR','ADICIONAL'),
			    nombre, fecha_insert, Resultado,nombre_archivo--, tipo_archivo --DECODE(Resultado,'0','EN PROCESO','1','OK','ERROR')
			    INTO  cNumCredito,cNumTarjeta,cTipo_Tarjeta,cNombre,cfecha,cresultado,cnomarchivo--,cTipoArchivo
				FROM "informix".sd_credito_upgrade
				WHERE empresa = pEmpresa
				AND fecha_insert BETWEEN dtFechaIni and dtFechaFin
				AND Resultado = pStatus
				AND tipo_proceso = 2
				
				IF NVL(cTipo_Tarjeta,'') ='TIT' THEN
					LET cTipo_Tarjeta = 'TITULAR';
				ELIF NVL(cTipo_Tarjeta,'') ='ADI' THEN
					LET cTipo_Tarjeta = 'ADICIONAL';
				END IF;		
				--Se valida el tipo de Archivo
				IF substr(cnomarchivo,1,16) ='CAMBIOPRODTDCREP' THEN
					LET cTipoArchivo = '2';
				ELSE
					LET cTipoArchivo = '1';
				END IF;
				IF NVL(cresultado,'') IN ('0','1') THEN
					LET cresultado = 'EXITOSO';
				
					IF cTipoArchivo = '1' THEN 
						LET cMarcaje = 'SI'; LET cSolPlastico ='SI';
					ELSE
						LET cMarcaje = 'N/A'; LET cSolPlastico ='SI';
					END IF;
					LET cMensajeError = '';					
				ELSE 
					LET cresultado = 'NO EXITOSO';
					IF NVL(cTipoArchivo,'') = '1' THEN 
						IF NVL(cnomarchivo,'') = '' THEN
							LET cMarcaje = 'NO';
						END IF;	
						LET cSolPlastico ='NO';
					ELSE
						LET cMarcaje = 'N/A'; LET cSolPlastico ='NO';
					END IF;		
				END IF;

			RETURN cCodRet, cMensajeRet, NVL(cNumCredito,''), NVL(cNumTarjeta,''), NVL(cTipo_Tarjeta,''), NVL(cNombre,''), NVL(cfecha,DATE(1)), NVL(cresultado,''), NVL(cMarcaje,''), NVL(cSolPlastico,''), NVL(cMensajeError,'') WITH resume;
			
			END FOREACH;
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				   LET cCodRet= '000002';
				   LET cMensajeRet= 'No existe información del archivo en el periodo seleccionado';
				   --RETURN cCodRet, cMensajeRet,"","","","","","";
				   RETURN cCodRet, cMensajeRet, NVL(cNumCredito,''), NVL(cNumTarjeta,''), NVL(cTipo_Tarjeta,''), NVL(cNombre,''), NVL(cfecha,DATE(1)), NVL(cresultado,''), NVL(cMarcaje,''), NVL(cSolPlastico,''), NVL(cMensajeError,'');
			END IF;		
		END IF;
	END IF;
		
END IF;

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para obtener información de reportería para de las solicitudes de marca de upgrade de un producto y de solicitud de plásticos personalizados',
'AUTOR : Maria Elena Angulo Aispuro',
'FECHA : 22/02/2016',
'AUTOR: L. Montserrat León Amador',
'FECHA 18/04/2017',
'DESCRIPCION: Se crea SPL clon para el tratado de la paginación.',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_reporte_bim_bajas_nom()
RETURNING   CHAR(5) 	AS retorno; ---,
            --CHAR(100)   AS mensaje_ret;

--Declaración de variables.
DEFINE v_num_credito             	 CHAR(20);
DEFINE v_num_producto             	 CHAR(4);
DEFINE v_status_cred				 CHAR(2);
DEFINE v_tipo_credito                SMALLINT;
DEFINE v_baja_cred                   CHAR(12);
DEFINE v_tipo_baja_cred              SMALLINT;
DEFINE v_mto_perdonado               DECIMAL(18,2);
DEFINE iSqlErr      				 INTEGER;
DEFINE iIsamErr         			 INTEGER;
DEFINE cErrorInfo       			 CHAR(100);
DEFINE cCodRet          			 CHAR(6);
DEFINE cMensajeRet    				 CHAR(100);
DEFINE pPeriodo              		 DATE;
DEFINE piniPeriodo					 DATE;
DEFINE flag_aniobis					 INTEGER;
DEFINE cRuta CHAR (50);
DEFINE cBitCamp CHAR (50);
DEFINE cCadena  CHAR (1500);

--INICIALIZACION DE VARIABLES
LET v_num_credito             	  ="";
LET v_num_producto             	  ="";
LET v_status_cred				  ="";
LET v_tipo_credito                =0;
LET v_baja_cred                   ="";
LET v_tipo_baja_cred              =0;
LET v_mto_perdonado               =0.00;
LET iSqlErr                         = 0;
LET iIsamErr         				= 0;
LET cErrorInfo       				= "";
LET cCodRet          				= "00000";
LET cMensajeRet    					= "REPORTE BIMESTRAL BAJAS NOMINA se realizó correctamente";
LET cRuta = '';
LET cBitCamp = '';
LET cCadena = '';



BEGIN
    --Errores no controlados.
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
          LET cCodRet= iSqlErr;
          LET cMensajeRet= cErrorInfo;

          RETURN cCodRet; --, cMensajeRet;
    END EXCEPTION;

    --SET DEBUG FILE TO "/ifxsif01/tmp/b_pp/proceso_dic_bajas_nomina/sp_reporte_bimestral_bajas_nom.out";
   -- TRACE ON;

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO dirty READ;

   -- LET pPeriodo = mdy(month(today),1,year(today)) - 1 units day;
   --IPCB  Se cambia por consulta a la BD
	SELECT pri_dia_mes-1 units day , pri_dia_mes-2 units month  
	INTO pPeriodo, piniPeriodo
	FROM bdicred:sd_fechas;
	
	LET cRuta="/resplogifx/archivosriesgos/";	
	LET cBitCamp="bim_bajas_nom";
	LET cBitCamp= TRIM(cBitCamp)||'_'||YEAR(today)||LPAD(MONTH(today),2,0)||LPAD(DAY(today),2,0)||'.unl';

--Reproceso de Junio
--LET pPeriodo = mdy('06','30','2018');
--LET piniPeriodo = mdy('05','01','2018');
--Reproceso de Junio	

--Valida Anio Bisiesto
IF mod(year(pPeriodo),4) = 0 AND ((mod(year(pPeriodo),4)) = 0 OR (mod(year(pPeriodo),4) = 0)) THEN
	LET flag_aniobis = 1;
ELSE
	LET flag_aniobis = 0;
END IF;

	
    FOREACH WITH HOLD
        
        SELECT a.num_credito,
		30 as tipo_credito, 
		TO_CHAR(b.fecha_proceso, '%Y/%m/%d') as fecha_proc, 
		case when a.status_cred ='CV' then 50 else 60 end tipo_baja_cred,
		0.00 as mto_perdonado
		--INTO v_num_credito,v_tipo_credito,v_baja_cred,v_tipo_baja_cred,v_mto_perdonado
		FROM sd_maecredcrd a, 
		sd_maecredanexocrd b
		WHERE a.num_credito=b.num_credito
		and a.status_cred IN('FF','CV','FI', 'FC')
		and b.fecha_proceso>=piniPeriodo
		and b.fecha_proceso<=pPeriodo
		and a.num_producto in('6400')
	UNION ALL
		SELECT a.num_credito,
		30 as tipo_credito, 
		TO_CHAR(b.fecha_proceso, '%Y/%m/%d') as fecha_proc,  
		case when a.status_cred ='CV' then 50 else 60 end tipo_baja_cred,
		0.00 as mto_perdonado
		INTO v_num_credito,v_tipo_credito,v_baja_cred,v_tipo_baja_cred,v_mto_perdonado
		FROM sd_maecred a, 
		sd_maecredanexo b
		WHERE a.num_credito=b.num_credito
		and a.status_cred IN('FF','CV','FI', 'FC')
		and b.fecha_proceso>=piniPeriodo
		and b.fecha_proceso<=pPeriodo
		and a.num_producto in('7800')
							
        BEGIN WORK;
            INSERT INTO sd_reporte_bim_bajas_nom (fecha_cierre,num_credito,tipo_credito,fecha_baja_cred,tipo_baja_cred,mto_perdonado)
                 VALUES( pPeriodo,v_num_credito,v_tipo_credito,v_baja_cred,v_tipo_baja_cred,v_mto_perdonado);
      	COMMIT WORK;
	
	END FOREACH; 
	
	LET cCadena = '';
	LET cCadena = '/usr/bin/echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || TRIM(cBitCamp)  ||'  delimiter '';'' SELECT num_credito,tipo_credito,fecha_baja_cred,tipo_baja_cred,mto_perdonado FROM bdicred:"informix".sd_reporte_bim_bajas_nom WHERE fecha_cierre= ''' ||mdy(month(pPeriodo), day(pPeriodo), year(pPeriodo))|| '''" >'||TRIM(cRuta)||'bim_bajas_nom.sql';
	SYSTEM cCadena;				
	LET cCadena='chmod 777 '|| TRIM(cRuta)||'bim_bajas_nom.sql';
	System cCadena;				
	let cCadena = 'dbaccess bdicred ' || TRIM(cRuta) || 'bim_bajas_nom.sql';
	System cCadena;				
	LET cCadena = '' ;
	LET cCadena = 'rm ' || TRIM(cRuta) || 'bim_bajas_nom.sql';
	SYSTEM cCadena;
	
    LET cCodRet     = "00000";
    LET cMensajeRet = "REPORTE BIMESTRAL BAJAS NOMINA OK ";

	RETURN cCodRet; --, cMensajeRet;
END
END PROCEDURE
;