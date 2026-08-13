CREATE PROCEDURE "informix".sp_aforebuscararchivosprocesar2_totales(pTipo CHAR(1), pNombreArchivo CHAR(30), pFechaInicial DATE,pFechaFinal DATE,pEstatus CHAR(2))
        RETURNING CHAR(5), INTEGER;
        
DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE iNoRegistros INTEGER;

LET iSqlErr = '';
LET cCodRet = '00000';
LET iNoRegistros = 0;

--SET DEBUG FILE TO "/tmp/mfinis/sp_aforebuscararchivosprocesar2.out";
--TRACE ON;

BEGIN

        -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------           
        -------Crea el control de errores
        ON EXCEPTION SET iSqlErr
                IF iSqlErr != 0 THEN
                        LET cCodRet= iSqlErr;
                        RETURN cCodRet, iNoRegistros;
                END IF;
        END EXCEPTION;

        IF pEstatus <> 19 THEN
                ----si me mandan defchas i gual a 1900-01-01 
                IF pFechaInicial = date(1) and pFechaFinal = date(1) THEN
					Select COUNT(*)
					Into iNoRegistros
					From bdiprog:pp_arch_afore arc
					inner join bdiprog:pp_tparchivo tp on arc.tipo = tp.tipo    
					Where arc.nombre_arch = CASE WHEN pNombreArchivo = '' THEN  arc.nombre_arch  ELSE pNombreArchivo END
					and arc.status = CASE WHEN pEstatus = '' THEN  arc.status  ELSE pEstatus END
					and arc.tipo = CASE WHEN pTipo = '' THEN  arc.tipo  ELSE pTipo END;
					
					IF iNoRegistros = 0 THEN
						LET cCodRet = '00017';
					END IF;
					
					RETURN cCodRet, iNoRegistros;
                ELSE--- si me mandan un a fecha o un rango de fechas
					Select COUNT(*)
					Into iNoRegistros
					From bdiprog:pp_arch_afore arc
					inner join bdiprog:pp_tparchivo tp on arc.tipo = tp.tipo    
					Where arc.nombre_arch = CASE WHEN pNombreArchivo = '' THEN  arc.nombre_arch  ELSE pNombreArchivo END
					and arc.status = CASE WHEN pEstatus = '' THEN  arc.status  ELSE pEstatus END
					and arc.tipo = CASE WHEN pTipo = '' THEN  arc.tipo  ELSE pTipo END
					and fecha_generado >= pFechaInicial  AND fecha_generado <= pFechaFinal; 
                                
					IF iNoRegistros = 0 THEN
						LET cCodRet = '00017';
					END IF;
					
					RETURN cCodRet, iNoRegistros;
                END IF;
        ELSE--si me mandan un stado 19 se obtienen los archivos con estado 01 y  09
                ----si me mandan defchas i gual a 1900-01-01          
                IF pFechaInicial = date(1) and pFechaFinal = date(1) THEN
					Select COUNT(*)
					Into iNoRegistros
					From bdiprog:pp_arch_afore arc
					inner join bdiprog:pp_tparchivo tp on arc.tipo = tp.tipo    
					Where arc.nombre_arch = CASE WHEN pNombreArchivo = '' THEN  arc.nombre_arch  ELSE pNombreArchivo END
					and arc.status IN ('01','09') 
					and arc.tipo = CASE WHEN pTipo = '' THEN  arc.tipo  ELSE pTipo END;
					IF iNoRegistros = 0 THEN
						LET cCodRet = '00017';
					END IF;
					
					RETURN cCodRet, iNoRegistros;
                ELSE--- si me mandan un a fecha o un rango de fechas
					Select COUNT(*)
					Into iNoRegistros
					From bdiprog:pp_arch_afore arc
					inner join bdiprog:pp_tparchivo tp on arc.tipo = tp.tipo    
					Where arc.nombre_arch = CASE WHEN pNombreArchivo = '' THEN  arc.nombre_arch  ELSE pNombreArchivo END
					and arc.status IN ('01','09') 
					and arc.tipo = CASE WHEN pTipo = '' THEN  arc.tipo  ELSE pTipo END
					and fecha_generado >= pFechaInicial  AND fecha_generado <= pFechaFinal; 
					
					IF iNoRegistros = 0 THEN
						LET cCodRet = '00017';
					END IF;
					
					RETURN cCodRet, iNoRegistros;
                END IF;
        END IF;
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Este procedimmiento cuenta los archivos que se han generado para que se creen reportes, ', 
'AUTOR: Oscar Flores Conde',
'FECHA: 10 de Junio 2015',
'BD: BDIPROG';

CREATE PROCEDURE "informix".sp_aforegenerarreportedetallepagosdiarios2(pFecha DATE, pRegistros INTEGER, pRecuperacion INTEGER)
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
		SELECT SKIP pRegistros FIRST pRecuperacion det.clabe, det.imp_netopagar,det.status,  NVL(det.comision,0), NVL(det.iva_comision,0), 
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
			FROM "informix".pp_detalle
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

CREATE PROCEDURE "informix".sp_aforegenerarreporteresumpagproc2(p_FechaReporte DATE, pRegistros INTEGER, pRecuperacion INTEGER)
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
				SELECT SKIP pRegistros FIRST pRecuperacion DISTINCT a.fecha_procesado, COUNT(b.consecutivo), NVL(SUM(b.comision),0),  -- DSB 31/03/2014
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

create procedure "informix".sp_ppvalidafechaprox (cempresa char (3), cusuario char (8))

RETURNING CHAR(5), INTEGER, CHAR (30);

DEFINE cretcode 		CHAR (5);
DEFINE cdesc_retcode    CHAR (50);
DEFINE isqlerr  	   	INTEGER;
DEFINE iisamerr    		INTEGER;
DEFINE cinfoerr    		CHAR (100);
DEFINE cnomproceso		CHAR (10);
DEFINE dfechproceso		DATE;
DEFINE cstatus			CHAR (1);
DEFINE cusrinsrt		CHAR (8);
DEFINE dfechinsrt		DATE;
DEFINE dfechintg		DATE;
DEFINE caniofech		CHAR (4);
DEFINE caniofechp		CHAR (4);
DEFINE icontupdts		INTEGER;
DEFINE danionvo			DATE;
DEFINE irgsupdt			INTEGER;
DEFINE dfchprox			DATE;
DEFINE tmp_dfchprog		DATE;
DEFINE cstproceso		CHAR (1);
DEFINE icntproc			INTEGER;
DEFINE ccvepprog		CHAR(10);
DEFINE cconsec  		INTEGER;
DEFINE dfchprog			DATE;
DEFINE dfchferia		DATE;
DEFINE cDescripcionSPJ	 CHAR(100);

	--	SET DEBUG FILE TO '/informix/frg/sp_ppvalidafechaprox.out';
	--	TRACE ON;

LET cretcode 		= "00000";
LET cdesc_retcode   = "Act. Fechas PpPgr Exitosa.";
LET isqlerr  	   	= 0;
LET iisamerr    	= 0;
LET cinfoerr    	= " ";
LET cnomproceso		= "act_fechpp";
LET dfechproceso	= today;
LET cstatus			= "0";
LET cusrinsrt		= cusuario;
LET dfechinsrt		= today;
LET dfechintg		= today;
LET caniofech		= " ";
LET caniofechp		= " ";
LET icontupdts		= 0;
LET danionvo		= today;
LET irgsupdt		= 0;
LET dfchprox		= today;
LET	tmp_dfchprog	= today;
LET cstproceso		= "0";
LET icntproc		= 0;
LET ccvepprog		= "";
LET cconsec		  	= 0;
LET dfchprog		= today;
LET dfchferia		= today;
LET cDescripcionSPJ	 = 'Actualizacion Fecha-Aplicacion Pagos Programados (días inhabiles)';

BEGIN
    ON EXCEPTION SET isqlerr, iisamerr, cinfoerr
        IF isqlerr <> 0 
			THEN
				LET cretcode = isqlerr;
				LET cdesc_retcode = "Error en el proceso Act. Fechas PpPgr. Validar.";
				RETURN cretcode, icontupdts, cdesc_retcode;
        END IF;
	END EXCEPTION;

	set isolation to dirty read;
	select fecha_hoy::date into dfechintg
	from bdinteg:"informix".si_fechas
	where empresa = cempresa;

	set isolation to dirty read;
	select max (fecha)
		into dfchferia
	from bdinteg:si_feriado_banca;
	
	select count (*) 
	into icntproc
	from "informix".pp_procesos 
		WHERE proceso = cnomproceso AND fech_proceso = dfechintg;
	
	--INSERTA EN BITACORA
	EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'IND_PP_DI', dfechintg, '0', 'informix', 'sp_ppvalidafechaprox', cDescripcionSPJ);
	
	IF icntproc > 0	--	Ya corrió el proceso.
		THEN
			select status
			into cstproceso
			from "informix".pp_procesos 
			WHERE proceso = cnomproceso AND fech_proceso = dfechintg;
			if 
				cstproceso = "1"
				then
					let cretcode = '00001';
					let cdesc_retcode = 'Proceso ya fue ejecutado con exito el dia de hoy.';
					RETURN cretcode, icontupdts, cdesc_retcode;
				else
					delete from "informix".pp_procesos where proceso = cnomproceso AND fech_proceso = dfechintg;
					insert into "informix".pp_procesos values
					(cnomproceso, dfechintg, cstproceso, cusuario, today);
			end if;
		ELSE
			insert into "informix".pp_procesos values
			(cnomproceso, dfechintg, cstproceso, cusuario, today);
	END IF;
	
	set isolation to dirty read;
	select COUNT (*) 
		into icontupdts
	from bdiprog:pp_pagospend where 
	estado in ('01', '03') and 
	fecha_prog in 
		(select {+INDEX(bdinteg:si_feriado_banca 413_793)}
		fecha from bdinteg:si_feriado_banca 
		where 
		pais = cempresa and 
		fecha between dfechintg and dfchferia);

	if icontupdts <= 0
		then
			LET isqlerr = 0;
			LET iisamerr = 0;
			LET cinfoerr = "No hay Pagos Programados en dias feriados para el rango. Validar.";
			LET cretcode = "00001";
			LET cdesc_retcode = cinfoerr;
			EXECUTE PROCEDURE bdisac:sp_sac_guardamensajeerror (isqlerr, iisamerr, cinfoerr, "sp_ppvalidafechaprox");
            RETURN cretcode, icontupdts, cdesc_retcode;
		else
	end if;

	set isolation to dirty read;
	insert into "informix".pp_fechasactualizadas
	select {+INDEX(bdiprog:"informix".pp_pagospend idx_fecha_prog)}
		cve_pagoprog, consecutivo, fecha_prog, " ", CURRENT
		from bdiprog:pp_pagospend 
		where 
		estado in ('01', '03') and 
		fecha_prog in 
		(select {+INDEX(bdinteg:si_feriado_banca 413_793)}
		fecha from bdinteg:si_feriado_banca 
		where 
		pais = cempresa and 
		fecha between dfechintg and dfchferia);

	FOREACH
		select cve_pagoprog, consecutivo, fecha_prog
		into ccvepprog, cconsec, dfchprog
		from bdiprog:pp_fechasactualizadas
		where fecha_prog >= dfechintg
	
		select fecha_prox
		into dfchprox
		from bdinteg:si_feriado_banca 
		where fecha = dfchprog;
			
		update bdiprog:pp_pagospend
		set fecha_prog = dfchprox
		where cve_pagoprog = ccvepprog and consecutivo = cconsec and fecha_prog = dfchprog;
		
		update bdiprog:pp_fechasactualizadas
		set fecha_ppupdt = dfchprox
		where cve_pagoprog = ccvepprog and consecutivo = cconsec and fecha_prog = dfchprog;
		
	END FOREACH;

	UPDATE "informix".pp_procesos SET status = "1"
		WHERE PROCESO = cnomproceso AND fech_proceso::date = dfechintg AND status = "0";	
	--ACTUALIZA EN BITACORA
	EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'IND_PP_DI', dfechintg, '1', 'informix', 'sp_ppvalidafechaprox', cDescripcionSPJ);
		
	RETURN cretcode, icontupdts, cdesc_retcode;
END;	
END PROCEDURE
DOCUMENT
'AUTOR : FRG',
'DESCRIPCION: SP que busca fechas de Pagos Programados en dias feriados del anio proximo y actualiza a siguiente dia habil.',
'EJECUTADO O LLAMADO POR: CTRL-M(Job: NNN_ACTFECHPGPGR)',
'FECHA : Febrero-2014',
'BD    : bdiprog';

CREATE PROCEDURE "informix".sp_encriptaarchivo(cUsuario CHAR(50), cRutaArchivoOrigen CHAR(100), cRutaArchivoDestino CHAR(100), cRutaRespaldo CHAR(100),cNombreArchivo CHAR(50), cLlave CHAR(200))
RETURNING CHAR(6), CHAR(100);

/*DEFINICION DE VARIABLES*/
DEFINE iSqlErr  INTEGER;
DEFINE cCodRet 	CHAR(6);
DEFINE cComando CHAR(600);
DEFINE cMensaje CHAR(100);
DEFINE iExisteSH SMALLINT;


/*INICIALIZACION DE VARIABLES*/
LET cCodRet = '000000';
LET cMensaje = 'ENCRIPTACION CORRECTA';
LET cComando = '';
LET iExisteSH = 0;
	--SET DEBUG FILE TO '/informix/sp_encriptaarchiv.out';
	--TRACE ON;
BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensaje = "ENCRIPTACION INCORRECTA";			
			IF iExisteSH = 1 THEN
				LET cComando = 'rm -f '|| TRIM(cRutaArchivoOrigen) || 'encriptaarchivo.sh';
				SYSTEM cComando;
			END IF;						
			RETURN cCodRet, cMensaje;
		END IF;
	END EXCEPTION;
	
	IF cUsuario = '' OR cRutaArchivoOrigen = '' OR cRutaArchivoDestino = '' OR cNombreArchivo = '' OR cLlave = '' OR cRutaRespaldo = '' THEN
		LET cCodRet = '000001';
		LET cMensaje = "PARAMETROS DE ENCRIPTACION INCOMPLETOS/INCORRECTOS";
	ELSE
		
		--Genera el archivo "encriptaarchivo.sh" en la ruta origen que se recibio como parametro en el cual escribe los comandos necesarios
		--para exportar las variables de ambiente PATH y HOME, que se necesitan para poder encriptar archivos con PGP
		LET cComando = 'echo "export PATH=/usr/bin:/etc:/usr/sbin:/usr/ucb:/home/' || TRIM(cUsuario) ||'/bin:/usr/bin/X11:/sbin:.:/opt/pgp/bin:/informix/bin">' || TRIM(cRutaArchivoOrigen) || 'encriptaarchivo.sh';
		SYSTEM cComando; 
		
		LET iExisteSH = 1;
		
		LET cComando = 'echo "export HOME=/home/' || TRIM(cUsuario) || '">>' || TRIM(cRutaArchivoOrigen) || 'encriptaarchivo.sh';
		SYSTEM cComando;
		
		--Escribe en "encriptaarchivo.sh" el comando para encriptar el archivo		
		LET cComando = 'echo "/opt/pgp/bin/pgp --encrypt -i ' || TRIM(cRutaArchivoOrigen) || TRIM(cNombreArchivo) || ' -r ' || '''' || TRIM(cllave) ||
		'''' ||" --armor --compression --output " || TRIM(cRutaArchivoDestino)||' ">>' || TRIM(cRutaArchivoOrigen) || 'encriptaarchivo.sh';
		SYSTEM cComando;
		
		--Asigna permisos a "encriptaarchivo.sh"
		LET cComando = 'chmod 777 ' || TRIM(cRutaArchivoOrigen) || 'encriptaarchivo.sh';   
		SYSTEM cComando;
		
		--Ejecuta el bash "encriptaarchivo.sh"
		LET cComando = '/usr/bin/sh ' || TRIM(cRutaArchivoOrigen) || 'encriptaarchivo.sh';
		--|| TRIM(cRutaArchivoOrigen) ||'salida.out 2>&1" sysafore';
		SYSTEM cComando;
		
		IF TRIM(cRutaArchivoOrigen) <> TRIM(cRutaRespaldo) THEN
			LET cComando = 'mv ' || TRIM(cRutaArchivoOrigen) || TRIM(cNombreArchivo) || ' ' || cRutaRespaldo; 
			SYSTEM cComando;
		END IF;
		
		--Elimina el bash "encriptaarchivo.sh"
		LET cComando = 'rm -f '|| TRIM(cRutaArchivoOrigen) || 'encriptaarchivo.sh';
		SYSTEM cComando;		
	END IF;
	RETURN cCodRet, cMensaje;
END
END PROCEDURE
DOCUMENT
'PARAMETROS DE ENTRADA',
'cUsuario: Se refiere al usuario que se utilizara para encriptar el archivo, es necesario para cargar las variables de ambiente',
'cRutaArchivoOrigen: Se refiere a la ruta donde se encuentra el archivo que sera encriptado',
'cRutaArchivoDestino: Se refiere a la ruta donde sera depositado el archivo encriptado',
'cRutaRespaldo: Se refiere a la ruta donde se depositara el archivo original',
'cNombreArchivo: Se refiere al nombre del archivo <original> que sera encriptado',
'cLlave: Se refiere al USER ID o KEY ID de la llave que sera utilizada para encriptar el archivo',
'**********************************************************************************************',
'DESCRIPCION: Stored procedure para utilizar PGP encryption', 
'SOLICITO :Jaime Gonzalez',	
'AUTOR: Jose Angel Lopez Adams',
'FECHA: 29/05/2014',
'VERSION: 20140529.1151',
'BD: BDIPROG',
'VERSION: 20090616';

CREATE PROCEDURE "informix".sp_consultacuentasdestino_bpi_trans(p_NumCte CHAR(20), p_CvePago CHAR(2), p_Registros SMALLINT)
RETURNING
     CHAR(6)     as cod_ret, ---cod_ret
	 CHAR(20)    as cuenta, ---cuenta
	 CHAR(100)   as nombre, ---nombre
	 CHAR(50)    as banco, ---banco
	 CHAR(2)     as compcelular, ---compañia celular
	 CHAR(10)    as numcelular, ---numero celular
	 CHAR(40)    as correoelect, ---correo electronico
	 CHAR(2)     as cve_cuenta, ---cve cuenta
     CHAR(20)    as desc_cuenta, ---desc cuenta
     CHAR(13)    as rfc, ---rfc
	 MONEY(16,2) as monto_max, ---Monto Máximo
	 CHAR(1)     as cta_activa;    -- bandera de activación
		  
    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
    DEFINE vDesErr              CHAR(60);
	DEFINE v_CodDesc			CHAR(50);
	DEFINE v_CvePago			CHAR(2);
	DEFINE v_CtaDestino			CHAR(20);
	DEFINE v_Nombre				CHAR(100);
	DEFINE v_Banco				CHAR(50);
	DEFINE v_CompCel			CHAR(2);
	DEFINE v_NumCel				CHAR(10);
	DEFINE v_CorreoE			CHAR(40);
	DEFINE v_CveCuenta			CHAR(2);
	DEFINE v_ContReg			SMALLINT;
	DEFINE v_DescCta			CHAR(20);
    DEFINE v_Rfc                CHAR(13);
	DEFINE v_Canal				CHAR(2);
	DEFINE v_FechaInsert		DATE;
	DEFINE v_HoraInsert			DATETIME HOUR TO SECOND;
	DEFINE v_FechaHoraInsert	DATETIME YEAR TO FRACTION;
	DEFINE v_MontoMaximo		MONEY(16,2);
	DEFINE v_activo				CHAR(1);
	
	LET v_CodDesc			    = "";
	LET v_CvePago				= "";
	LET v_CtaDestino			= "";
	LET v_Nombre				= "";
	LET v_Banco					= "";
	LET v_CompCel				= "";
	LET v_NumCel				= "";
	LET v_CorreoE				= "";
	LET v_CveCuenta				= "";
	LET v_ContReg			 	= 0;
	LET v_DescCta				= "";
    LET v_Rfc                   = "";
	LET v_Canal					= "";
	LET v_MontoMaximo			= 0.00;
	LET v_activo				= "";
	
	SET LOCK MODE TO WAIT 10;

BEGIN

   ON EXCEPTION
        SET iSqlErr, iSamErr, vDesErr
        IF iSqlErr <> 0 THEN
                LET v_cod_ret = iSqlErr;
                --EXECUTE PROCEDURE bdinteg:sp_desc_ret(20, v_cod_ret)
                --INTO v_cod_ret, vDesErr;
        END IF;
        RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
    END EXCEPTION;

	--SET DEBUG FILE TO "/home/informix/raldana/RQI10664TranfBanc/bdiprog/sp_ConsultaCuentasDestino.out";
	--TRACE ON;

	SELECT cod_ret
	INTO v_cod_ret
	FROM  bdiprog:"informix".PP_MENSAJES
	WHERE cve_mensaje = "00";

	select banco || " " ||
		(CASE
			WHEN TRIM(vchrnombrecorto) = ''
				THEN descripcion
			ELSE
				vchrnombrecorto
		END) 
	INTO v_Banco
	FROM bdinteg:"informix".si_bancos
	WHERE banco = "137";

	IF (p_NumCte <> "" AND p_NumCte IS NOT NULL) AND (p_CvePago <> "" AND p_CvePago IS NOT NULL)  THEN
 		IF EXISTS (SELECT ct.cuenta FROM bdiprog:"informix".pp_ctasterceros ct, bdiprog:"informix".pp_cuentapago cp WHERE ct.num_cte = p_NumCte AND ct.cve_cuenta = cp.cve_cuenta)  THEN
                FOREACH
                    SELECT ct.cuenta, ct.nombre, b.banco|| "  " ||
					(CASE
						WHEN TRIM(vchrnombrecorto) = ''
						THEN descripcion
					ELSE
					vchrnombrecorto
					END), ct.cve_compania, ct.no_celular, ct.direc_correo, ct.cve_cuenta,ct.descrip_cta, ct.rfc, ct.canal_alta, ct.fecha_insert, ct.hora_insert, NVL(ct.monto_maximo,0)
                    INTO v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta, v_Rfc, v_Canal, v_FechaInsert, v_HoraInsert, v_MontoMaximo
                    FROM bdiprog:"informix".pp_ctasterceros ct, bdinteg:"informix".si_bancos b, bdiprog:"informix".pp_cuentapago cp
                    WHERE ct.num_cte = p_NumCte
                    AND ct.cve_banco = b.banco
                    AND ct.cve_cuenta = cp.cve_cuenta
                    AND cp.cve_pago = p_CvePago
                    AND ct.cve_estado = '01'   
					ORDER BY ct.descrip_cta, ct.nombre
				
					-- Si el canal es de internet, devolvera solo los registros que tengan 30 minutos o mas transcurridos despues de su alta
					IF v_Canal = '03' THEN
						LET v_FechaHoraInsert = ( YEAR(v_FechaInsert) || '-' || MONTH(v_FechaInsert) || '-' || DAY(v_FechaInsert) || ' ' || v_HoraInsert)::DATETIME YEAR TO FRACTION;
						IF (current - v_FechaHoraInsert) < '0 00:30:00' THEN
							LET v_activo = '0';														
						ELSE 
							LET v_activo = '1';																				
						END IF;
					END IF;
					
                    LET v_ContReg = v_ContReg + 1;

                    IF v_ContReg <= p_Registros THEN -- Si el registro no es mayor al numero de registro recibido, no regresa nada y continua con el siguiente registro
                        CONTINUE FOREACH;
                    END IF;					
                    RETURN v_cod_ret, v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta,v_Rfc, v_MontoMaximo,v_activo  WITH RESUME;
					
                END FOREACH;
		END IF
	ELSE
		SELECT cod_ret
		INTO v_cod_ret
		FROM  BDIPROG:"informix".PP_MENSAJES
		WHERE cve_mensaje = "01";

        RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
	END IF
END;
--##############################################################################
--## Procedimiento   : sp_consultacuentasdestino_bpi_trans
--## Version         : 1.0
--## Fecha creacion  : Diciembre de 2015
--## Descripcion     : Consulta las cuentas frecuente transfer de un cliente
--##############################################################################
END PROCEDURE;