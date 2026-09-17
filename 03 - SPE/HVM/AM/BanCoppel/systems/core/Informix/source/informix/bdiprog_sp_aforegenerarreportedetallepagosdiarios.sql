CREATE PROCEDURE "informix".sp_aforegenerarreportedetallepagosdiarios(pFecha DATE)
	RETURNING CHAR(5),CHAR(18),CHAR(40),CHAR(120), MONEY(17,2),MONEY(17,2),decimal(18,2),CHAR(30),CHAR(2),DATE,INTEGER,MONEY(17,2),INTEGER,MONEY(17,2),
	CHAR(1); -- DSB 31/03/2014
	
--------------------------------------------------------------------------------------------------
------------------------------------GENERALES -----------------------------------------------
DEFINE cTipoRegistro 				CHAR(1);
DEFINE cFinLinea					CHAR(2);
DEFINE iSqlErr              		INTEGER;
DEFINE cCodRet              		CHAR(5);
DEFINE dFecha_Hoy           		DATE;
Define cSQL                 		CHAR(100);
DEFINE cProceso						CHAR(10);
DEFINE cNombreArchivoSalida 		CHAR(30);
DEFINE cRenglon						CHAR(30);
DEFINE cStatus						CHAR(1);
DEFINE dHora  datetime HOUR TO SECond;
--------------------------------------------------------------------------------------------------

DEFINE cCLABE		CHAR(18);
DEFINE cTipoCuenta  CHAR(40);
DEFINE cNombreCliente CHAR(120);
DEFINE cImporte   MONEY(17,2);
DEFINE dIva  decimal(18,2);
DEFINE cEstado  CHAR(2);
DEFINE cEstatusPago  CHAR(30);
DEFINE cTransaccCargo CHAR(4);
DEFINE mComision MONEY(17,2);
DEFINE iNumTotalPagados INTEGER;
DEFINE mImpTotalPagados MONEY(17,2);
DEFINE iNumNoPagados INTEGER;
DEFINE mImpTotalNoPagados MONEY(17,2);
DEFINE cCuenta CHAR(11);

DEFINE cIdentificadorArchivo CHAR(2); -- DSB 31/03/2014
DEFINE cTipoArchivo CHAR(1); -- DSB 31/03/2014
DEFINE cBandera1 CHAR(1);    -- DSB 31/03/2014
DEFINE cBandera2 CHAR(1);    -- DSB 31/03/2014

LET cCuenta = '';
LET iNumNoPagados = 0;
LET mImpTotalNoPagados = 0.00;
LET iNumTotalPagados = 0;
LET mImpTotalPagados = 0.00;
LET cTransaccCargo = '';
LET mComision =0.00;
LET cEstado		= '';
LET cCLABE		= '';
LET cTipoCuenta  = '';
LET cNombreCliente = '';
LET cImporte  = '';
LET dIva  = 0.00;
LET cEstatusPago  = '';

LET cTipoRegistro = '';
LET cFinLinea = '';
LET iSqlErr = 0;
LET cCodRet = '00000';
LET dFecha_Hoy = '';
LET cSQL = '';
LET cProceso = '';
LET cStatus = '';
LET cNombreArchivoSalida = '';
LET dhora = CURRENT HOUR TO SECOND;

LET cIdentificadorArchivo = ''; -- DSB 31/03/2014
LET cTipoArchivo = ''; -- DSB 31/03/2014
LET cBandera1 = '0';   -- DSB 31/03/2014
LET cBandera2 = '0';   -- DSB 31/03/2014

--------------------------------------------------------------------------------------------------


	--SET DEBUG FILE TO "/respaldosbd/ceav/sp_aforegenerarreportedetallepagosdiarios.out";
	--TRACE ON;	

BEGIN
   -------Crea el control de errores
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cCLABE,cTipoCuenta,cNombreCliente,cImporte,mComisiON,dIva,cEstatusPago,cEstado,dFecha_Hoy,
			        iNumTotalPagados,mImpTotalPagados,iNumNoPagados,mImpTotalNoPagados,cTipoArchivo;
		END IF;
	END EXCEPTION;
	--No Encontro El Archivo o No Exixte
	ON EXCEPTION IN (-668)
		Let cCodRet = '10010';
		RETURN cCodRet,cCLABE,cTipoCuenta,cNombreCliente,cImporte,mComision,dIva,cEstatusPago,cEstado,dFecha_Hoy,
		       iNumTotalPagados,mImpTotalPagados,iNumNoPagados,mImpTotalNoPagados,cTipoArchivo;
	END EXCEPTION WITH resume;	
	
	/*---------------------ERRORES
		let cCodRet = '10010'; no se encontro el archivo
	*/
	LET dhora = CURRENT;
	--se obtiene el cargo de la transaccion de la tabla parametros
	SELECT valor INTO cTransaccCargo FROM bdiprog:pp_parametros WHERE cve_param ='103';
	------------- Se  obtiene la fecha del sistema   
	SELECT fecha_hoy INTO dFecha_Hoy FROM bdinteg:si_fechas;
	
			-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	FOREACH
		SELECT det.clabe, det.imp_netopagar,det.status,  NVL(det.comision,0), NVL(det.iva_comision,0), 
			CASE WHEN SUBSTR(det.nombre_arch,15,2) = 'AC' THEN '1'
				WHEN SUBSTR(det.nombre_arch,15,2) = 'OB' THEN '2'
			END
		INTO cCLABE,cImporte,cEstado,mComision,dIva,cTipoArchivo
		FROM bdiprog:pp_detalle det 
			WHERE det.fecha_ejec = pFecha
			ORDER BY 6 ASC -- ORDENAR POR TIPO DE ARCHIVO
		
		IF cTipoArchivo = '1' THEN   -- DSB 31/03/2014
			LET cBandera1 = '1';
		ELIF cTipoArchivo = '2' THEN
			LET cBandera2 = '1';
		END IF;
		
		IF cTipoArchivo = '1' THEN -- DSB 31/03/2014
			LET cIdentificadorArchivo = 'AC'; -- DSB 31/03/2014
			
			--- es esta seleccion se obtiene el nombre del beneficiario completo en base a la CLABE para obtener los datos reales de la cuenta  NVL(h.sdo_actual, 0),
			LET cCuenta = SUBSTR(cCLABE,7,11);
			--- es esta seleccion se obtiene el nombre del beneficiario completo en base a la CLABE para obtener los datos reales de la cuenta  NVL(h.sdo_actual, 0),
			SELECT TRIM(NVL(cte.nombre1, '')) || ' ' || TRIM(NVL(cte.nombre2, '')) || ' ' ||TRIM(NVL(cte.apell_paterno, '')) || ' ' ||TRIM(NVL(cte.apell_materno, ''))
			INTO cNombreCliente
			FROM bdicheq:sc_maechq mae
			INNER JOIN bdinteg:si_cliente cte ON mae.num_cte = cte.numcte
			WHERE mae.empresa = '001' AND mae.cuenta = cCuenta;
			---si la CLABE no es valida retorna puros valores nulos en el nombre del beneficiario!! y en la descripcion de el tipo de cuenta
			IF  (cNombreCliente is NULL OR TRIM(cNombreCliente) = '') THEN
				LET cNombreCliente = '  ';
				LET cTipoCuenta = '  ';
			ELSE --De lo contrario ya tenemos el nombre del cliente ahi q buscar la descripcion del producto o del tipo de cuenta
				SELECT pro.nombre INTO cTipoCuenta
				FROM bdicheq:sc_maechq mae
				INNER JOIN bdicheq:sc_producto pro ON mae.producto= pro.producto
				WHERE mae.cuenta = cCuenta;
			END IF;
		ELIF cTipoArchivo = '2' THEN -- DSB 31/03/2014
			LET cIdentificadorArchivo = 'OB'; -- DSB 31/03/2014
		
			-- TOMAR EL NOMBRE DEL CLIENTE
			SELECT DISTINCT(TRIM(nom_benef) || ' ' || TRIM(apell_pat) || ' ' || TRIM(apell_mat)) 
			INTO cNombreCliente
			FROM 'informix'.pp_detalle
			WHERE clabe = TRIM(cCLABE); -- DSB 31/03/2014
			
			LET cTipoCuenta = SUBSTR(cCLABE,7,11); -- DSB 31/03/2014
		END IF; -- DSB 31/03/2014
		--se selecciona la descripcion del estado de la tabla estados
		SELECT descripcion
		INTO cEstatusPago
		FROM bdiprog:pp_status_afore
		WHERE status = cEstado;
		
		--selecciona el numero de detalle con estado 2  
		SELECT COUNT(status),NVL(SUM(imp_netopagar),0) INTO iNumTotalPagados,mImpTotalPagados FROM bdiprog:pp_detalle 
		WHERE status = '02' AND fecha_ejec = pFecha
		AND SUBSTR(nombre_arch,15,2) = cIdentificadorArchivo; -- DSB 31/03/2014
		
		--selecciona el numero de detalle con estado distinto a 2  
		SELECT COUNT(status),NVL(SUM(imp_netopagar),0) INTO iNumNoPagados,mImpTotalNoPagados FROM bdiprog:pp_detalle 
		WHERE status <> '02' AND fecha_ejec = pFecha
		AND SUBSTR(nombre_arch,15,2) = cIdentificadorArchivo; -- DSB 31/03/2014
		
		IF cTipoArchivo <> '1' and cBandera1 = '0' THEN  -- DSB 31/03/2014
			RETURN cCodRet,'','','','0',0.00,0.00,'','',dFecha_Hoy,0,0.00,0,0.00,'1' WITH resume;
			LET cBandera1 = '1';
		END IF;
		
		--Regresa resultados
		RETURN cCodRet,cCLABE,cTipoCuenta,cNombreCliente,cImporte,mComision,dIva,cEstatusPago,cEstado,dFecha_Hoy,
		       iNumTotalPagados,mImpTotalPagados,iNumNoPagados,mImpTotalNoPagados,cTipoArchivo WITH resume;
	END FOREACH;
	
		IF cTipoArchivo <> '1' and cBandera1 = '0' THEN  -- DSB 31/03/2014
			RETURN cCodRet,'','','','0',0.00,0.00,'','',dFecha_Hoy,0,0.00,0,0.00,'1' WITH resume;
			LET cBandera1 = '1';
		END IF;
		
		IF cTipoArchivo <> '2' and cBandera2 = '0' THEN  -- DSB 31/03/2014
			RETURN cCodRet,'','','','0',0.00,0.00,'','',dFecha_Hoy,0,0.00,0,0.00,'2' WITH resume;
			LET cBandera2 = '1';
		END IF;
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Genera un reporte a detalle  de los pagos diarios de una fecha espesifica', 
'..........................................................',
'Solicito : Armando Mercado',	
'AUTOR: César Valdéz Figueroa',
'FECHA: 21 de Mayo 2009',
'BD: BDIPROG',
'CAMBIOS: Este Sp obtenia el nombre del beneficiario de la si_clientes, por medio de la cuenta, pero cuando esta no existia ',
'         ignoraba completamente este registro y no lo retornaba. por lo que se realizo esta modificacion y cuando la cuenta ',
'		  no existe se retorna el nombre en blanco ',
'MODIFICO: César Valdéz Figueroa',
'FECHA: 16/Junio/2009',
'VERSION: 20090616',
'MODIFICO   : Josue Zepeda - 92802036',
'FOLIO      : 1411',
'DESCRIPCION: Se agrega proceso para otros bancos y parametro pTipoarch',
'FECHA      : 26 de Marzo de 2014',
'SUSTENTO   : Se definio con Leonardo Hernández Moreno y Yuridia Espinoza en el requerimiento',
'RQM 06 292 Creacion de archivo Afore Coppel para dispersar pagos a otros Bancos',
'BD         : BDIPROG';

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