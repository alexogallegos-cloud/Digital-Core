CREATE PROCEDURE "informix".sp_calcula_fechas_porperiodo_calif_13(pEmpresa CHAR(3),pPeriodicidad CHAR(1),pNumProducto CHAR(04),pDiaCorte SMALLINT,pFechaHoy DATE)
RETURNING   CHAR(6)        AS resultado,
            VARCHAR(100,1) AS mensaje,
			DATE AS Fecha_Actual_t_0,
			DATE AS Fecha_t_1,
			DATE AS Fecha_t_2,
			DATE AS Fecha_t_3,
			DATE AS Fecha_t_4,
			DATE AS Fecha_t_5,
			DATE AS Fecha_t_6,
			DATE AS Fecha_t_7,
			DATE AS Fecha_t_8,
			DATE AS Fecha_t_9,
			DATE AS Fecha_t_10,
			DATE AS Fecha_t_11,
			DATE AS Fecha_t_12,
			DATE AS Fecha_t_13;
			
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
		RETURN cCodRet,cMensajeRet,dfecha0,dfecha1,dfecha2,dfecha3,dfecha4,dfecha5,dfecha6,dfecha7
			,dfecha8,dfecha9,dfecha10,dfecha11,dfecha12,dfecha13;
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
		IF pNumProducto NOT IN ('6400','7800', '9300') THEN 
			LET cCodRet= '000002';
			--LET cMensajeRet = 'Producto para periodo quincenal no valido en CALCULO FECHAS POR PERIODO.';
			LET cMensajeRet = 'Periodo quincenal no valido para el producto';
			RETURN cCodRet,cMensajeRet,dfecha0,dfecha1,dfecha2,dfecha3,dfecha4,dfecha5,dfecha6,dfecha7
				,dfecha8,dfecha9,dfecha10,dfecha11,dfecha12,dfecha13;
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
		RETURN cCodRet,cMensajeRet,dfecha0,dfecha1,dfecha2,dfecha3,dfecha4,dfecha5,dfecha6,dfecha7
		,dfecha8,dfecha9,dfecha10,dfecha11,dfecha12,dfecha13;
	END IF;	 

RETURN cCodRet,cMensajeRet,dfecha0,dfecha1,dfecha2,dfecha3,dfecha4,dfecha5,dfecha6,dfecha7
		,dfecha8,dfecha9,dfecha10,dfecha11,dfecha12,dfecha13;
END
END PROCEDURE
DOCUMENT 
'Proceso para el calculo de fechas por periodo para la calificacion de cuentas_CORRIGIENDO LOS INHABILES E INCLUYENDO 7800 a QUINCENALES',
'BD    : bdicred';

create procedure "informix".sp_tasaefectiva(pmonto decimal(18,2),pcomisap decimal(18,2),ptasacontrac_an decimal(18,9),ppagos integer,ptipofac char(1)) --trace1
									
        --CHAR(1); -- Bandera
		--RETURNING   CHAR(5), CHAR(100), char(60);
		RETURNING  DECIMAL(18,8), DECIMAL(18,5);

--Declaracion de variables.
/*
DEFINE sql_err      INT;
DEFINE cod_ret      CHAR(6);
DEFINE s_regreso    CHAR(1);
*/

DEFINE iSqlErr      					INTEGER;
DEFINE iIsamErr         				INTEGER;
DEFINE cErrorInfo       				CHAR(100);
DEFINE cCodRet          				CHAR(6);
DEFINE cMensajeRet    					CHAR(100);
DEFINE cMensajeRet2    	CHAR(60);
DEFINE Ini_proc char(22);  	DEFINE Fin_proc char(22);

DEFINE vporcen_tasa_men DECIMAL(18,9); 
DEFINE vtasa_mensual  DECIMAL (18,9);
DEFINE vtasa_mensual_1 DECIMAL(18,15);
DEFINE vpago_int_mensual DECIMAL(18,9); 
DEFINE vtasa_pagointmens DECIMAL(18,9); 
DEFINE vpago_mensual DECIMAL(18,9); 
DEFINE var3prosum DECIMAL(18,9); 
DEFINE vtotal_pagos_per DECIMAL(18,9); 
DEFINE vvalinicial DECIMAL(18,9); 
DEFINE Var6 DECIMAL(18,9); 
DEFINE vtotal DECIMAL(18,9); 
DEFINE Var8 DECIMAL(18,9); 
DEFINE Var9 DECIMAL(18,9); 
DEFINE Var10 DECIMAL(18,9); 
DEFINE Var11 DECIMAL(18,9); 
DEFINE Var12 DECIMAL(18,9); 
DEFINE Var13 DECIMAL(18,9); 
DEFINE Var14 DECIMAL(18,9); 
DEFINE Var15 DECIMAL(18,9); 
DEFINE Var16 DECIMAL(18,9); 
DEFINE Var17 DECIMAL(18,9);
DEFINE Var17Aux DECIMAL(18,9);  
DEFINE FlagVar17 DECIMAL(1,0);
DEFINE FlagVar18 DECIMAL(1,0);
DEFINE Var18 DECIMAL(18,9);  
DEFINE vcontper integer;
--DEFINE COUNTER_REG DECIMAL(5,0);
DEFINE VarInc DECIMAL(18,9); 
DEFINE VarInc2 DECIMAL(18,9);
DEFINE VarIncSum DECIMAL(18,9); 
DEFINE VVan DECIMAL (18,9);
DEFINE VVan2 DECIMAL (18,9);
DEFINE vtir DECIMAL(18,9); 

DEFINE vtir_mensual DECIMAL (18,9);
DEFINE vtir_anual DECIMAL (18,9);
DEFINE vportir_an DECIMAL (18,9);
DEFINE var_dec DECIMAL (18,15);

--LET s_regreso = '0';

LET iSqlErr                         = 0;
LET iIsamErr         				= 0;
LET cErrorInfo       				= "";
LET cCodRet          				= "00000";


LET vporcen_tasa_men =0;
LET vtasa_mensual = 0;
LET vtasa_mensual_1 =0;
LET  vpago_int_mensual =0;
LET  vtasa_pagointmens =0;
LET  vpago_mensual =0;
LET  var3prosum =0;
LET  vtotal_pagos_per =0;
LET  vvalinicial =0;
LET  Var6 =0;
LET  vtotal =0;
LET  Var8 =0;
LET  Var9 =0;
LET  Var10 =0;
LET  Var11 =0;
LET  Var12 =0;
LET  Var13 =0;
LET  Var14 =0;
LET  Var15 =0;
LET  Var16 =0;
LET  Var17 =0;
LET  Var17Aux =0; 
LET  FlagVar17 =0;
LET  FlagVar18 =0;
LET  Var18 =0; 
LET  vcontper =1;
--LET  COUNTER_REG DECIMAL(5,0);
LET  VarInc =0;
LET  VarInc2 =0;
LET  VarIncSum =0;
LET VVan = 0;
LET  vtir =0;
LEt var_dec = 0;

BEGIN

    --Errores no controlados.
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
          LET cCodRet= iSqlErr;
          LET cMensajeRet= cErrorInfo;
	  	  LET cMensajeRet2 = '';
		 -- IF (val_trans_Commit = -1) THEN
			--rollback work;
		 --- END IF; 
			
		  RETURN cCodRet, cMensajeRet;    END EXCEPTION;
	
--SET DEBUG FILE TO "/RESPALDOS/INFOSAT/TIR/sp_tasaefectiva_v2.out";
--TRACE ON;


	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
--SELECT DBINFO('utc_to_datetime', sh_curtime) INTO Ini_proc   FROM sysmaster:sysshmvals;

IF ptasacontrac_an = 0 OR pmonto <= pcomisap OR ppagos = 0 THEN
		LET vtir_mensual = 0;
		LET vtir_anual = 0;
		LET vportir_an =0;		
ELIF pcomisap = 0 THEN
	LET vporcen_tasa_men = ptasacontrac_an/12;	
	LET vtasa_mensual = vporcen_tasa_men/100;	
	
	LET vtir_mensual = vtasa_mensual;
	LET vtir_anual = ptasacontrac_an/100;
	LET vportir_an =ptasacontrac_an;	
ELSE

  LET vporcen_tasa_men = ptasacontrac_an/12;
  LET vtasa_mensual = vporcen_tasa_men/100;
  
  
  LET vpago_int_mensual = (pmonto*vtasa_mensual);
  
  LET vtasa_pagointmens = ((1- (POW((1+vtasa_mensual),-ppagos))));
  
  LET vpago_mensual = vpago_int_mensual/vtasa_pagointmens;

  LET vtotal_pagos_per = vpago_mensual * ppagos;  
  
  LET vvalinicial = -1*(pmonto-pcomisap);
  
  LET vcontper = 1;
  
  LET vtotal = 0;

--Calculo VAN ORIGINAL  
  WHILE vcontper <= ppagos LOOP	
	LET vtotal = vtotal+(vpago_mensual/(pow(1+vtasa_mensual,vcontper)));
	LET vcontper = (vcontper+1);
  END LOOP
	LET VVan = vvalinicial + vtotal;
	
    LET vcontper = 1;  
	LET vtotal = 0;
	LET VVan2 = VVan;	
	let var_dec = .001;
	
	LET vtasa_mensual_1 = vtasa_mensual;	
--Proyeccion VAN, para definicion de TIR
	WHILE round(VVan2,4) <> 0 LOOP
		let var_dec = var_dec / 10;
		let VVan2 = 1;
		WHILE  VVan2 > 0 LOOP	
			LET vtasa_mensual_1 = vtasa_mensual_1 + var_dec;	
			LET vcontper = 1;  
			LET vtotal = 0;
			LET VVan2 = 0;
			WHILE vcontper <= ppagos LOOP
				LET vtotal = vtotal+(vpago_mensual/(pow(1+vtasa_mensual_1,vcontper)));
				LET vcontper = (vcontper+1);
			END LOOP
			LET VVan2 =vvalinicial + vtotal;
		END LOOP
		if VVan2 < 0 then
			let vtasa_mensual_1 = vtasa_mensual_1 - var_dec;		
		end if;
	END LOOP
     
	 LET vtir_mensual = round(vtasa_mensual_1,8);
	 LET vtir_anual = round(vtir_mensual * 12,5);
	 LET vportir_an =vtir_anual*100;
END IF;	 
--SELECT DBINFO('utc_to_datetime', sh_curtime) INTO fin_proc  FROM sysmaster:sysshmvals;
	
   -- LET cCodRet     = "00000";
    --LET cMensajeRet = "TIR: " ||vtasa_mensual_1;
	--LET cMensajeRet2= 'Inicio: '||Ini_proc||' Fin: '||fin_proc ;	
	
	--RETURN cCodRet, cMensajeRet, cMensajeRet2;
	
	RETURN vtir_mensual,vtir_anual;END
END PROCEDURE

;