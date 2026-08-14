CREATE PROCEDURE "informix".sp_aforegenerarreporteresumpagproc(p_FechaReporte DATE)
	RETURNING CHAR(6), DATE, DATE, INTEGER, DECIMAL(16, 2), DECIMAL(16, 2), DECIMAL(16, 2), 
	CHAR(1); -- DSB 31/03/2014
	--cod retorno, fecha servidor, fecha mov, Num operacion, Comision cobrada, IVA obrado, Total.

	--Declaracion de variables
	DEFINE v_codret				CHAR(6);
	DEFINE v_sqlerr				INTEGER;

	DEFINE v_fecha_hoy			DATE;
	DEFINE v_FechaPago			DATE;
	DEFINE v_NumOperacion		INTEGER;
	DEFINE v_TotNumOperacion	INTEGER;
	DEFINE v_Comision			DECIMAL(16, 2);
	DEFINE dAcumulado		DECIMAL(16, 2);
	DEFINE v_IVA				DECIMAL(16, 4);
	DEFINE dTotalIva			DECIMAL(16, 2);
	DEFINE dTotal				DECIMAL(16, 2);
	DEFINE cTipoArchivo 		CHAR(1); -- DSB 31/03/2014
	DEFINE cBandera1			CHAR(1);    -- DSB 31/03/2014
	DEFINE cBandera2			CHAR(1);    -- DSB 31/03/2014
	
	
	--SET DEBUG FILE TO '/tmp/sp_AforeGenerarReporteResumPagProc.out';
	--TRACE ON;
	
	--Inicializacion de variables
	LET v_codret 			= "00000";
	LET v_sqlerr 			= 0;
	
	LET v_fecha_hoy			= DATE(1);
	LET v_FechaPago			= DATE(1);
	LET v_NumOperacion		= 0;
	LET v_TotNumOperacion	= 0;
	LET v_Comision			= 0.00;
	LET dAcumulado   		= 0.00;
	LET v_IVA				= 0.00;
	LET dTotalIva			= 0.00;
	LET dTotal				= 0.00;
	LET cTipoArchivo = ''; -- DSB 31/03/2014
	LET cBandera1 = '0';   -- DSB 31/03/2014
	LET cBandera2 = '0';   -- DSB 31/03/2014
        
	BEGIN
	    ON EXCEPTION SET v_sqlerr
	        IF v_sqlerr != 0 THEN
	            LET v_codret = v_sqlerr;
	            RETURN v_codret, v_fecha_hoy, v_FechaPago, v_NumOperacion, v_Comision, dTotalIva, dTotal, cTipoArchivo;
	        END IF;
	    END EXCEPTION;

		IF p_FechaReporte = DATE(1) OR p_FechaReporte IS NULL THEN

			LET v_codret = '10015';	--Faltan parametros
			RETURN v_codret, v_fecha_hoy, v_FechaPago, v_NumOperacion, v_Comision, dTotalIva, dTotal, cTipoArchivo;
		ELSE
			--El procedimiento obtiene la fecha del sistema central.
			SELECT fecha_hoy 
			INTO v_fecha_hoy 
			FROM bdinteg:si_fechas 
			WHERE empresa = '001';

			SELECT valor  
			INTO v_IVA 
			FROM bdinteg:si_param 
			WHERE cod_param= '47';

			FOREACH
				SELECT DISTINCT a.fecha_procesado, COUNT(b.consecutivo), NVL(SUM(b.comision),0),  -- DSB 31/03/2014
				CASE WHEN SUBSTR(a.nombre_arch,15,2) = 'AC' THEN '1'
					WHEN SUBSTR(a.nombre_arch,15,2) = 'OB' THEN '2'
				END
				INTO v_FechaPago, v_NumOperacion, v_Comision, cTipoArchivo
				FROM bdiprog:pp_arch_afore a
				INNER JOIN bdiprog:pp_detalle b ON (a.nombre_arch = b.nombre_arch)
				WHERE (a.status = '02' OR a.status = '03')
					AND a.tipo = 'P'
					AND MONTH(a.fecha_procesado) = MONTH(p_FechaReporte)
					AND YEAR(a.fecha_procesado) = YEAR(p_FechaReporte)
				GROUP BY 4, 1
				ORDER BY 4, 1 ASC
				
				IF cTipoArchivo = '1' THEN   -- DSB 31/03/2014
					LET cBandera1 = '1';
				ELIF cTipoArchivo = '2' THEN
					LET cBandera2 = '1';
				END IF;

				LET dAcumulado= dAcumulado + v_Comision;
				LET dTotalIva= dAcumulado * v_IVA;
				LET dTotal= dTotalIva + dAcumulado;
				
				IF cTipoArchivo <> '1' and cBandera1 = '0' THEN  -- DSB 31/03/2014
					RETURN v_codret, v_fecha_hoy, '', '0', 0.00, 0.00, 0.00, '1' WITH RESUME;
					LET cBandera1 = '1';
				END IF;

				RETURN v_codret, v_fecha_hoy, v_FechaPago, v_NumOperacion, v_Comision, dTotalIva, dTotal, cTipoArchivo WITH RESUME;
				LET dAcumulado   		= 0.00;
				LET dTotalIva			= 0.00;
				LET dTotal				= 0.00;
			END FOREACH;
			
			IF cTipoArchivo <> '1' and cBandera1 = '0' THEN  -- DSB 31/03/2014
				RETURN v_codret, v_fecha_hoy, '', '0', 0.00, 0.00, 0.00, '1' WITH RESUME;
				LET cBandera1 = '1';
			END IF;
			
			IF cTipoArchivo <> '2' and cBandera2 = '0' THEN  -- DSB 31/03/2014
				RETURN v_codret, v_fecha_hoy, '', '0', 0.00, 0.00, 0.00, '2' WITH RESUME;
				LET cBandera2 = '1';
			END IF;
			
		END IF;
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION:',
'* Tener un procedimiento que permita generar, imprimir y exportar un reporte de pagos mensuales, totalizados por día.',
'* Mostrar la cantidad de pagos que fueron procesados diariamente.',
'* Mostrar el detalle diario de las comisiones a cobrar  por el procesamiento de pagos.',
'SOLICITO : Armando Mercado',	
'AUTOR: Abraham Ayala Aguilar',
'FECHA: 21 Mayo 2009',
'VERSION: 20090521',
'BD: BDIPROG',
'MODIFICO: Abigail Vasavilbazo Cañedo',
'FECHA: DICIEMBRE 2009',
'VERSION: 20091216.1638',
'MODIFICACION: Se modifica para regresar el iva total calculado en base al total de la comision en el mes y regresar el total de comision mas iva en el mes',
'MODIFICO   : Josue Zepeda - 92802036',
'FOLIO      : 1411',
'DESCRIPCION: Se agrega proceso para otros bancos y parametro de retorno cTipoArchivo',
'FECHA      : 26 de Marzo de 2014',
'SUSTENTO   : Se definio con Leonardo Hernández Moreno y Yuridia Espinoza en el requerimiento',
'RQM 06 292 Creacion de archivo Afore Coppel para dispersar pagos a otros Bancos',
'BD         : BDIPROG';

CREATE PROCEDURE "informix".sp_aforegeneraarchivosob(pUsuario CHAR(8) )

RETURNING CHAR(5),-->Codigo de Retorno CHAR(5) AS CodigoRet, 
	      CHAR(50);
DEFINE vcodret       CHAR(5);
DEFINE vCodRet1      CHAR(5);
DEFINE vsqlerr       INTEGER;
DEFINE dFechaActual	 DATE;
DEFINE cHoraActual	 DATETIME HOUR TO SECOND;
DEFINE cMensaje		CHAR(50);
DEFINE cNomProceso  CHAR(10);
DEFINE cFechaFormat CHAR(8);
DEFINE pNombreArchivo CHAR(30);
DEFINE cIndicadorNomArch CHAR(2);

LET vcodret = '00000';
LET dFechaActual = '';
LET vcodret1 = '00000';
LET cMensaje = '';
LET cNomProceso = '';
LET cFechaFormat = '';
LET pNombreArchivo = '';
LET cIndicadorNomArch = '';
LET cHoraActual = CURRENT HOUR TO SECOND;


-- SET DEBUG FILE TO "/home/informix/sp_AforeGeneraArchivosOB.out";
-- TRACE ON;

BEGIN

	ON EXCEPTION
	   SET vsqlerr
	   LET vcodret = vsqlerr;

	   RETURN vcodret,cMensaje;
	END EXCEPTION;
	ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET cMensaje = 'Ocurrio un error no controlado';
			INSERT INTO pp_bitacora (proceso,archivo,cod_ret,mensaje,user_insert,fecha_insert,hora_insert)
			VALUES (cNomProceso,pNombreArchivo,vcodret,cMensaje,pUsuario,dFechaActual,cHoraActual);
            Return vcodret,cMensaje;
        END IF;
    END EXCEPTION;
	
		--consulta la fecha actual del sistema de integral	
		SELECT {+  INDEX(bdicheq:sc_fechas idx_fechas1) } fecha_hoy INTO dFechaActual FROM bdicheq:sc_fechas;
		
		LET cFechaFormat = LPAD(DAY(dFechaActual),2,0) || LPAD(MONTH(dFechaActual),2,0) || YEAR(dFechaActual);	
		LET cNomProceso = 'AfoEPPOB'; 
		LET cIndicadorNomArch = 'OB';
		
		FOREACH WITH HOLD
			SELECT nombre_arch INTO pNombreArchivo FROM bdiprog:pp_arch_afore 
			WHERE SUBSTR(nombre_arch,1,5) = 'PAGOS' 
			AND SUBSTR(nombre_arch,6,8) = cFechaFormat 
			AND SUBSTR(nombre_arch,15,2) = TRIM(cIndicadorNomArch)
			AND status = '20'
			AND tipo = 'P'
					
			CALL sp_aforearchconfob(pNombreArchivo,pUsuario)Returning vcodret,cMensaje;
			LET cMensaje = TRIM (cMensaje);
			IF vCodRet <> 0 THEN
				CONTINUE FOREACH;						
			END IF;
		END FOREACH;
		
		IF pNombreArchivo = '' OR pNombreArchivo IS NULL THEN
			LET cMensaje = 'No existen archivos por procesar';
		END IF;
		
		UPDATE pp_arch_afore SET status = '02',fecha_procesado = dFechaActual WHERE nombre_arch = pNombreArchivo;
		RETURN vcodret,cMensaje;

END
END PROCEDURE;