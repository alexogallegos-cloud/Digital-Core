CREATE PROCEDURE "informix".sp_cobro_automatico_adn(pEmpresa 		CHAR(3),
													pNumCte 		CHAR (20),
													pNumSol 		CHAR (20),
													pCtaNom 		CHAR (20), 
													pDivisa 		CHAR(2), 
													pMonto_disp 	MONEY(14,2),
													pStatusCred 	CHAR(2),
													pIdUnidadProd 	INTEGER)
RETURNING CHAR(6)       AS codigo_retorno,       
          CHAR(125)     AS mens_ret, 		  
		  CHAR (15)     AS proceso, 
		  CHAR(16) 		AS NumeroFolio,
		  CHAR(6)		AS CodRetAux,
		  VARCHAR(80,1) AS ErrorInfo,
		  DECIMAL(18,2) AS MontoFinanciado;

--Ejecucion por hora dentro del proceso de PDN (sp_cobro_automatico_pp_6400.sql)
DEFINE cCodRet			CHAR(5);
DEFINE cCodRetAux		CHAR(6);
DEFINE iSqlErr			INTEGER;
DEFINE iSamErr			INTEGER;
DEFINE cErrorInfo		VARCHAR(80,1);
DEFINE cMensajeRet  	CHAR(125);
DEFINE vcproceso    	CHAR(15);
DEFINE wBegin       	CHAR(1);
DEFINE g_StatusCtaCap 	CHAR(1);
DEFINE g_SdoCta	 		DECIMAL(14,2);
DEFINE g_SdoDisp	 	DECIMAL(14,2);
DEFINE g_TranRet		CHAR(4);
DEFINE g_FechaCargo		DATE;
DEFINE dtFechaHoy		DATE;
DEFINE g_MtoRet	 		DECIMAL(14,2);
DEFINE cDivisa			CHAR(2);
DEFINE cNumeroFolio 	CHAR(16);
DEFINE cNumCte   		CHAR(20);
DEFINE cCtaNom   		CHAR(20);
DEFINE cNumSol   		CHAR(20);
DEFINE dMonto_disp    	MONEY(14,2);
DEFINE iBandera			INTEGER;
DEFINE dFechaCuota		DATE;
DEFINE dCapitalStatus	CHAR(1);
DEFINE dCapitalDebe		DECIMAL(18,2);
DEFINE dMontoFinanciado	DECIMAL(18,2);
DEFINE dCodRef			INTEGER;
DEFINE dStatusCred		CHAR(2);
DEFINE cIdUnidadProd	INTEGER;

LET cCodRet				= "00000";
LET cCodRetAux			= "000000";
LET iSqlErr				= 0;
LET iSamErr				= 0;
LET cErrorInfo			= '';
LET cMensajeRet			= "Se realiza el pago correctamente";
LET vcproceso			= 'CobroautoADN';
LET g_StatusCtaCap		= '';
LET g_SdoCta			= 0;
LET g_SdoCta			= 0;
LET g_SdoDisp			= 0;
LET g_TranRet			= '';
LET g_FechaCargo		= DATE(1);
LET dtFechaHoy			= DATE(1);
LET g_MtoRet			= 0;
LET cDivisa				= pDivisa;
LET cNumeroFolio		= '';
LET cNumCte				= pNumCte;
LET cCtaNom				= pCtaNom;
LET cNumSol				= pNumSol;
LET dMonto_disp			= pMonto_disp;
LET  iBandera			= 0;
LET dFechaCuota			=  DATE(1);
LET dCapitalStatus		= '';
LET dCapitalDebe		= 0;
LET dCodRef				= 0;
LET dStatusCred			= pStatusCred;
LET cIdUnidadProd		= pIdUnidadProd;
LET wbegin				= 'N';
LET dMontoFinanciado	= 0;

BEGIN
	-- MANEJO DE EXCEPCIONES SQL
	ON EXCEPTION SET iSqlErr, iSamErr, cErrorInfo
		IF iSqlErr != 0 THEN
			LET cCodRet     = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			IF wbegin = 'S' THEN
				ROLLBACK WORK;
				BEGIN WORK;
			ELSE
				ROLLBACK WORK;
			END IF;		
		END IF;
		RETURN cCodRet, cMensajeRet, vcproceso, cNumeroFolio, cCodRetAux, cErrorInfo, dMontoFinanciado;
	END EXCEPTION;

	ON EXCEPTION IN (-255)
		LET wBegin = "B";
	END EXCEPTION WITH RESUME;

	ON EXCEPTION IN (-535)
		LET wBegin = "S";
		COMMIT WORK;
		BEGIN WORK;
	END EXCEPTION WITH RESUME;	

--SET DEBUG FILE TO "/tmp/sp_cobro_automatico_adn.out";
--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF TRIM(NVL(pEmpresa,"")) = ""  THEN
		LET cCodRet		= "00001";
		LET cMensajeRet	= "No tiene empresa el parametro";
		RETURN cCodRet, cMensajeRet, vcproceso, cNumeroFolio, cCodRetAux, cErrorInfo, dMontoFinanciado;	
	END IF;

	SELECT 	fecha_hoy
	INTO 	dtFechaHoy
	FROM 	bdicred:"informix".sd_fechas
	WHERE 	empresa = pEmpresa;
	
	--INC Anticipo se corrige para que no cobre doble
	SELECT 	COUNT(*)
	INTO 	dCapitalDebe
	FROM 	"informix".sd_amortiza_credito a
	WHERE 	a.empresa     		= pEmpresa
	AND 	a.num_credito 		= cNumSol
	AND 	a.capital_status 	IN ("1", "7", "2", "6")
	AND 	(a.capital_debe - a.capital_pagado) > 0;	

	IF dCapitalDebe = 0 THEN
		LET cCodRet 	= "00002";
		LET cMensajeRet	= "No tiene Saldo Deudor";	
		RETURN cCodRet, cMensajeRet, vcproceso, cNumeroFolio, cCodRetAux, cErrorInfo, dMontoFinanciado;				
	END IF;
	
	-- SE OBTIENE SALDO DE LA CUENTA DE NOMINA
	CALL bdicheq:"informix".cons_saldo(cCtaNom) RETURNING cCodRetAux,g_SdoCta,g_StatusCtaCap;

	IF (cCodRetAux <> "000") THEN
		LET cCodRet 	= "00003";
		LET cMensajeRet	= "Ocurrio un error al obtener saldo de cuenta nomina";			
		RETURN cCodRet, cMensajeRet, vcproceso, cNumeroFolio, cCodRetAux, cErrorInfo, dMontoFinanciado;			
	END IF;

	-- SE VALIDA EL SALDO DE LA CUENTA
	IF NVL(g_SdoCta,0) <= 0 THEN
		LET cCodRet 	= "00004";
		LET cMensajeRet	= "No tiene Saldo la cuenta de nomina";			
		RETURN cCodRet, cMensajeRet, vcproceso, cNumeroFolio, cCodRetAux, cErrorInfo, dMontoFinanciado;				
	END IF;
	
	LET  iBandera	= 0;

	IF g_SdoCta < dMonto_disp THEN
		LET dMonto_disp = g_SdoCta;
		LET iBandera = 1;
	END IF;

	-- SE GENERA EL FOLIO
	CALL bdicheq:"informix".sp_generafolionomina('ANTICIPO') RETURNING cCodRetAux, cNumeroFolio;

	BEGIN WORK;

	-- SE REALIZA EL CARGO A LA CUENTA
	EXECUTE PROCEDURE  bdicheq:"informix".cargo_ref('001', '9290', 'informix', '0398', "0000", cNumeroFolio, cCtaNom, 0, dMonto_disp, cDivisa, "", "0", '')
	INTO cCodRetAux, g_TranRet, g_FechaCargo, g_SdoDisp, g_MtoRet;

	IF cCodRetAux <> "000" THEN
		LET cCodRet 	= "00005";
		LET cMensajeRet = "Ocurrio un error al realizar el cargo a la cuenta de nomina";
		IF wbegin = 'S' THEN
			ROLLBACK WORK;
			BEGIN WORK;
		ELSE
			ROLLBACK WORK;
		END IF;
		RETURN cCodRet, cMensajeRet, vcproceso, cNumeroFolio, cCodRetAux, cErrorInfo, dMontoFinanciado;	
	END IF;

	-- SE CONSULTA FECHA CUOTA, STATUS Y CAPITAL DEBE DE LA AMORTIZACION
	FOREACH WITH HOLD
		SELECT 	a.fecha_cuota, a.capital_status,  a.capital_debe - a.capital_pagado
		INTO 	dFechaCuota, dCapitalStatus, dCapitalDebe
		FROM 	"informix".sd_amortiza_credito a
		WHERE 	a.empresa     		= pEmpresa
		AND 	a.num_credito 		= cNumSol
		AND 	a.capital_status 	IN ("1", "7", "2", "6")
		ORDER BY a.num_credito, a.fecha_cuota			

		IF g_SdoCta < dCapitalDebe THEN
			LET dCapitalDebe = g_SdoCta;
			LET iBandera = 1;
		END IF;
			
		--se realiza el pago al credito de nomina

		IF (dStatusCred ='AA' OR dStatusCred ='BA' OR dStatusCred ='BT') THEN
			IF dCapitalStatus = "1" THEN
				LET dCodRef = 10;
			ELIF dCapitalStatus = "7" THEN
				LET dCodRef = 7;
			ELIF dCapitalStatus = "2" THEN 
				LET dCodRef = 8;
			END IF;
		ELIF (dStatusCred ='E3' OR dStatusCred ='E2' OR dStatusCred ='E1') THEN
			IF dCapitalStatus = "1" THEN
				LET dCodRef = 1120; --PAGO NO EXGIBLE E1
			ELIF dCapitalStatus = "7" THEN
				LET dCodRef = 1121;  --PAGO EXGIBLE E1
			ELIF dCapitalStatus = "6" THEN 
				LET dCodRef = 1122;  --PAGO EXGIBLE E3
			END IF;
		END IF;
					
		IF dCapitalDebe > 0 THEN

			IF (dStatusCred ='AA' OR dStatusCred ='BA' OR dStatusCred ='BT') THEN

				UPDATE 	"informix".sd_maesdos
				SET 	sdo_cap_insoluto	= sdo_cap_insoluto - dCapitalDebe,
						sdo_capital			= (CASE WHEN dCapitalStatus = "1" THEN (sdo_capital - dCapitalDebe) ELSE sdo_capital END),
						monto_vencido		= (CASE WHEN dCapitalStatus = "7" THEN (monto_vencido - dCapitalDebe)  ELSE monto_vencido END),
						mto_venc_trasp		= (CASE WHEN dCapitalStatus = "2" THEN (mto_venc_trasp - dCapitalDebe) ELSE mto_venc_trasp END),
						monto_financiado	= monto_financiado - dCapitalDebe
				WHERE 	empresa			= pEmpresa 
				AND 	num_credito		= cNumSol;

			ELIF (dStatusCred ='E3' OR dStatusCred ='E2' OR dStatusCred ='E1') THEN

				UPDATE 	"informix".sd_maesdos
				SET 	sdo_cap_insoluto	= sdo_cap_insoluto - dCapitalDebe,
						sdo_capital			= (CASE WHEN dCapitalStatus = "1" THEN (sdo_capital - dCapitalDebe) ELSE sdo_capital END),
						monto_vencido		= (CASE WHEN dCapitalStatus IN ("7","6") THEN (monto_vencido - dCapitalDebe)  ELSE monto_vencido END),
						monto_financiado	= monto_financiado - dCapitalDebe
				WHERE 	empresa		= pEmpresa 
				AND 	num_credito	= cNumSol;

			END IF;

			UPDATE "informix".sd_amortiza_credito
			SET		capital_pagado     = capital_pagado + dCapitalDebe,
					capital_fecha_pago = dtFechaHoy,
					capital_status_ant = (CASE WHEN ((capital_pagado + dCapitalDebe) >= capital_debe) THEN capital_status ELSE capital_status_ant END),
					capital_status     = (CASE WHEN ((capital_pagado + dCapitalDebe) >= capital_debe) THEN "5" ELSE capital_status END)
			WHERE	empresa		= pEmpresa
			AND		num_credito	= cNumSol
			AND		fecha_cuota	= dFechaCuota;

			-- Total del Pago
			CALL "informix".GenMov(pEmpresa , cNumSol, '7800', 1, '074', dtFechaHoy, dCapitalDebe, cNumeroFolio, '9290', cDivisa, '8175') 		RETURNING cCodRet, cErrorInfo;

			CALL "informix".genmov(pEmpresa, cNumSol, '7800', dCodRef, '074', dtFechaHoy, dCapitalDebe,cNumeroFolio,'9290', cDivisa, '8175')	RETURNING cCodRet, cErrorInfo;

			if cCodRet = '00000' then
				-- ACTUALIZAR sd_indicador_cred
				UPDATE 	"informix".sd_indicador_cred
				SET 	fecha_ultimo_pago = dtFechaHoy,
						monto_ultimo_pago = dCapitalDebe
				WHERE 	empresa = pEmpresa
				AND 	num_credito = cNumSol;

				--- ACTUALIZAR sd_maecredanexo   
				UPDATE 	"informix".sd_maecredanexo
				SET 	fecha_ult_pago = dtFechaHoy
				WHERE 	empresa 	= pEmpresa
				AND 	num_credito = cNumSol;

			END IF;
							
		END IF;
					
	END FOREACH;
				 
				 
	IF iBandera =  1 THEN
	
		UPDATE 	bdisolic:"informix".ss_adn_solicitudcuenta
		SET 	activacion_cobrada 	= '2' , -- 2 SE COBRO PERO NO TOTALMENTE
				monto_disp			= monto_disp - dMonto_disp
		WHERE 	numcte 			= cNumCte
		AND 	num_solicitud	= cNumSol;
	
	ELSE

		UPDATE	bdisolic:"informix".ss_adn_solicitudcuenta
		SET		activacion_cobrada	= '1',
				fecha_ult_disp		= '',
				monto_disp			= monto_disp - dMonto_disp
		WHERE 	numcte			= cNumCte
		AND 	num_solicitud	= cNumSol;

		--- Actualizar sd_maecredanexo   
		UPDATE 	"informix".sd_maecredanexo
		SET 	fecha_vencto	= null
		WHERE 	empresa 	= pEmpresa
		AND	 	num_credito	= cNumSol;

		UPDATE 	"informix".sd_maesdos
		SET 	act = 0
		WHERE 	empresa 	= pEmpresa
		AND 	num_credito = cNumSol;

		IF (cIdUnidadProd != 3) THEN
			LET cIdUnidadProd = NULL;
		END IF;

		IF (dStatusCred ='AA' OR dStatusCred ='BA' OR dStatusCred ='BT') THEN

			UPDATE 	bdicred:"informix".sd_maecred
			SET 	id_unidad_prod	= cIdUnidadProd, 
					Cod_caract_2	= '', 
					status_cred		='AA'
			WHERE 	empresa 	= '001'
			AND 	num_credito = cNumSol;

		ELIF (dStatusCred ='E1' OR dStatusCred ='E2' OR dStatusCred ='E3') THEN

			UPDATE 	bdicred:"informix".sd_maecred
			SET 	id_unidad_prod	= cIdUnidadProd,
					Cod_caract_2	= '',
					status_cred		= 'E1'
			WHERE 	empresa 	= '001'
			AND 	num_credito = cNumSol;

			UPDATE	bdicred:"informix".sd_indicador_cred
			SET		dias_atraso = '0'
			WHERE	empresa 	= '001'
			AND		num_credito = cNumSol;

		END IF;

	END IF;

	-- SE OBTIENE NUEVO MONTO FINANCIADO
	SELECT 	monto_financiado INTO dMontoFinanciado
	FROM 	"informix".sd_maesdos  
	WHERE 	empresa 	= pEmpresa
	AND 	num_credito = cNumSol;			
		
    IF wbegin = 'S' THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK;
    END IF;		
		
	RETURN cCodRet, cMensajeRet, vcproceso, cNumeroFolio, cCodRetAux, cErrorInfo, dMontoFinanciado;
	
END
END PROCEDURE
DOCUMENT
'=======================================================',
'Proyecto	: RQM 09 704',
'Descripcion: Procedimiento para realizar el cobro con cargo a cuenta por credito del producto de Anticipo de Nomina',
'Desarrollo	: Juan Olivares Martinez/Maria Elena Angulo',
'Fecha		: 13/Marzo/2025',
'=======================================================';

CREATE PROCEDURE "informix".sp_genera_rpt_cobranza_automatica()
RETURNING 	CHAR(5) as cCodRet, 
			CHAR(150) as cMensajeRet;
	
	
	--Variables de retorno del SP 
	DEFINE cCodRet				CHAR(5);
	DEFINE cMensajeRet			CHAR(150);
	--Variables para el manejo de excepciones
	DEFINE iSQLError            INTEGER;
	DEFINE iISAMError           INTEGER;
	--Variables para la generacion de los reportes
	DEFINE dFechaAnt			DATE;
	DEFINE cNombreArchivoAN		CHAR(40);
	DEFINE cNombreArchivoPDN	CHAR(40);
	DEFINE cEncabezadoArchivo	CHAR(150);
	DEFINE cRutaArchivo			CHAR(100);
	DEFINE cSystem				CHAR(400);
	DEFINE cDia					CHAR(2);
	DEFINE cMes                 CHAR(2);
	DEFINE cAnio                CHAR(4);
	--Variables para la obtencion de datos para el archivo
	DEFINE dFechaOperacion		DATE;
	DEFINE cFechaFormato		CHAR(10);
	DEFINE cCuentaCredito       CHAR(20);
	DEFINE cCuentaEje           CHAR(20);
	DEFINE mMontoPorCobrar      DECIMAL(18,2);
	DEFINE mMontoCobrado        DECIMAL(18,2);
	DEFINE mMontoPendiente      DECIMAL(18,2);
	DEFINE iRecuperacion        INTEGER;
	--Variables de utileria
	DEFINE iContadorAND			INTEGER;
	DEFINE iContadorPDN			INTEGER;
	
	
	--Declaracion de archivo de debuggeo
	--SET DEBUG FILE TO "/home/c90314833/sp_genera_rpt_cobranza_automatica.out";
    --TRACE ON;	
	
	--Asignacion de variables
	LET cCodRet					= '00000';
	LET cMensajeRet				= 'Reportes generados correctamente';
								  
	LET iSQLError				= 0;
	LET iISAMError				= 0;
	
	LET dFechaAnt				= TODAY;
	LET cNombreArchivoAN		= 'COBRANZA_AN_AAAAMMDD.txt';
	LET cNombreArchivoPDN		= 'COBRANZA_PDN_AAAAMMDD.txt';
	LET cEncabezadoArchivo		= '| FechaOperacion | CuentaCredito | CuentaEje | MontoPorCobrar | Cobrado | PendientePorCobrar | % Recuperacion |';
	LET cRutaArchivo			= '/RESPALDOSNEW/';
	LET cSystem 				= '';
	LET cDia					= '';
	LET cMes                    = '';
	LET cAnio                   = '';
	
	LET dFechaOperacion			= TODAY;
	LET cFechaFormato			= '';
	LET cCuentaCredito  		= ''; 
	LET cCuentaEje      		= ''; 
	LET mMontoPorCobrar 		= 0.00; 
	LET mMontoCobrado   		= 0.00; 
	LET mMontoPendiente 		= 0.00; 
	LET iRecuperacion   		= 0; 
								  
	LET iContadorAND			= 0;
	LET iContadorPDN			= 0;
	
	BEGIN
		--Manejo de excepciones
		ON EXCEPTION SET iSQLError, iISAMError, cMensajeRet
			IF iSQLError <> 0 THEN
				LET cCodRet = iSQLError;
			END IF;
			RETURN cCodRet,cMensajeRet;
			
		END EXCEPTION;
		
		--Directivas de lectura y espera
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
			
		--Obtencion de la fecha del dia anterior
		SELECT fecha_ant 
		INTO dFechaAnt
		FROM bdicred:sd_fechas;
		
		--Obtencion de datos sobre la fecha para sustitucion en el nombre
		LET cDia   = LPAD(DAY(dFechaAnt::DATE), 2, '0');
		LET cMes   = LPAD(MONTH(dFechaAnt::DATE), 2, '0');
		LET cAnio = YEAR(dFechaAnt ::DATE);
		
		--Generacion del nombre del archivo y la ruta para la escritura del reporte.
		LET cNombreArchivoAN  = REPLACE(cNombreArchivoAN,'AAAA',cAnio);
		LET cNombreArchivoAN  = REPLACE(cNombreArchivoAN,'MM',cMes);
		LET cNombreArchivoAN  = REPLACE(cNombreArchivoAN,'DD',cDia);
		LET cRutaArchivo = TRIM(cRutaArchivo) || TRIM(cNombreArchivoAN);
		
		--Armado de encabezado del archivo de anticipo de nomina
		LET cSystem = 'echo "'|| TRIM(cEncabezadoArchivo) ||'" > ' ||TRIM(cRutaArchivo);
		SYSTEM cSystem;
		
		--Ciclo para la alimentacion del archivo de Anticipo de Nomina
		FOREACH WITH HOLD
		SELECT fch.fecha_ant as fecha_operacion, mae.num_credito as Cuenta_credito,adn.cuenta_nomina as Cuenta_eje,sdo.mto_reser_int as montoxcobrar,
			NVL(SUM(mov.monto),0) as mto_cobrado,  sdo.monto_reservado as Pendientexcobrar, 
			CASE WHEN sdo.mto_reser_int > 0 THEN ROUND((NVL(SUM(mov.monto),0)/sdo.mto_reser_int)*100,2) ELSE 0 END as Recuperacion
		INTO dFechaOperacion,cCuentaCredito,cCuentaEje,mMontoPorCobrar,mMontoCobrado,mMontoPendiente,iRecuperacion
		FROM bdicred:sd_maesdos sdo
		 INNER JOIN bdicred:sd_maecred mae ON (sdo.num_credito = mae.num_credito AND mae.status_cred IN ('E1','E2','E3') AND mae.num_producto ='7800')
		 INNER JOIN bdisolic: ss_adn_solicitudcuenta adn ON (mae.num_credito=adn.num_solicitud) 
		 INNER JOIN bdicred:sd_fechas fch ON (mae.empresa = fch.empresa)
		 LEFT JOIN bdicred:sd_movhis mov ON (mae.num_credito = mov.num_credito AND mov.fecha_mov >= fch.fecha_ant 
												AND mov.codigo_fun IN(select cod_fun from bdicred:sd_conceptospagomanual) AND codigo_ref ='1')
			WHERE sdo.mto_reser_int > 0
			group by fch.fecha_ant , mae.num_credito,adn.cuenta_nomina,sdo.mto_reser_int,sdo.monto_reservado
		
			IF cCuentaCredito != '' THEN
				LET iContadorAND = iContadorAND + 1;
			END IF;			
		
			LET cFechaFormato = LPAD(DAY(dFechaOperacion::DATE), 2, '0') || '/' || LPAD(MONTH(dFechaOperacion::DATE), 2, '0') || '/' || YEAR(dFechaOperacion ::DATE) ;
			
			LET cSystem = 'echo " | ' || cFechaFormato || ' | ' ||TRIM(cCuentaCredito)|| ' | ' ||TRIM(cCuentaEje)|| ' | ' ||mMontoPorCobrar|| ' | ' ||mMontoCobrado|| ' | ' ||mMontoPendiente|| ' | ' ||iRecuperacion|| '% |" >> '||TRIM(cRutaArchivo);
			SYSTEM cSystem;
			
		END FOREACH;		
		
		--Generacion del nombre del archivo y la ruta para la escritura del reporte.
		LET cRutaArchivo = '/RESPALDOSNEW/';
		LET cNombreArchivoPDN  = REPLACE(cNombreArchivoPDN,'AAAA',cAnio);
		LET cNombreArchivoPDN  = REPLACE(cNombreArchivoPDN,'MM',cMes);
		LET cNombreArchivoPDN  = REPLACE(cNombreArchivoPDN,'DD',cDia);
		LET cRutaArchivo = TRIM(cRutaArchivo) || TRIM(cNombreArchivoPDN);
		
		--Armado de encabezado del archivo de prestamo directo de nomina
		LET cSystem = 'echo "'|| TRIM(cEncabezadoArchivo) ||'" > ' ||TRIM(cRutaArchivo);
		SYSTEM cSystem;
		
		--Reinicio de variables para evitar sobreescritura.
		LET dFechaOperacion			=TODAY;	
		LET cFechaFormato 			='';
		LET cCuentaCredito  		=''; 
		LET cCuentaEje      		=''; 
		LET mMontoPorCobrar 		=0.00; 
		LET mMontoCobrado   		=0.00; 
		LET mMontoPendiente 		=0.00; 
		LET iRecuperacion   		=0; 
		
		--Ciclo para la alimentacion del archivo de Prestamo Directo de Nomina
		FOREACH WITH HOLD
		SELECT fch.fecha_ant as fecha_operacion, mae.num_credito as Cuenta_credito,  cta.num_cta as Cuenta_eje,sdo.mto_reser_int as montoxcobrar,
			NVL(SUM(mov.monto),0) as mto_cobrado,  sdo.monto_reservado as Pendientexcobrar, 
			CASE WHEN sdo.mto_reser_int > 0 THEN ROUND((NVL(SUM(mov.monto),0)/sdo.mto_reser_int)*100,2) ELSE 0 END as Recuperacion
			INTO dFechaOperacion,cCuentaCredito,cCuentaEje,mMontoPorCobrar,mMontoCobrado,mMontoPendiente,iRecuperacion
				FROM bdicred:sd_maesdoscrd sdo
				INNER JOIN bdicred:sd_maecredcrd mae ON (sdo.num_credito = mae.num_credito AND mae.status_cred IN ('E1','E2','E3') AND mae.num_producto ='6400')
				INNER JOIN bdicred:sd_ctascarg cta ON (mae.num_credito=cta.num_credito) 
				INNER JOIN bdicred:sd_fechas fch ON (mae.empresa = fch.empresa)
				LEFT JOIN bdicred:sd_movhiscrd mov ON (mae.num_credito = mov.num_credito AND mov.fecha_mov >= fch.fecha_ant 
						AND mov.codigo_fun IN(select cod_fun from bdicred:sd_conceptospagomanualcrd) AND codigo_ref ='1')
						WHERE sdo.mto_reser_int > 0
						GROUP BY fch.fecha_ant , mae.num_credito,cta.num_cta,sdo.mto_reser_int,sdo.monto_reservado
			
			IF cCuentaCredito != '' THEN
				LET iContadorPDN = iContadorPDN + 1;
			END IF;			
						
			LET cFechaFormato = LPAD(DAY(dFechaOperacion::DATE), 2, '0') || '/' || LPAD(MONTH(dFechaOperacion::DATE), 2, '0') || '/' || YEAR(dFechaOperacion ::DATE) ;
						
			LET cSystem = 'echo " | ' || cFechaFormato || ' | ' ||TRIM(cCuentaCredito)|| ' | ' ||TRIM(cCuentaEje)|| ' | ' ||mMontoPorCobrar|| ' | ' ||mMontoCobrado|| ' | ' ||mMontoPendiente|| ' | ' ||iRecuperacion|| '% |" >> '||TRIM(cRutaArchivo);	
			SYSTEM cSystem;
			
		END FOREACH;
		
		IF iContadorAND > 0 AND iContadorPDN > 0 THEN
			
			RETURN cCodRet,cMensajeRet;
		
		END IF; 
		
		IF iContadorAND = 0 AND iContadorPDN = 0 THEN
			
			LET cCodRet = '00001';
			LET cMensajeRet = 'Los reportes generados no contienen datos';
			RETURN cCodRet,cMensajeRet;
		
		ELSE		
			LET cCodRet = '00002';
			LET cMensajeRet = 'Al menos uno de los reportes se genero sin datos';
			RETURN cCodRet,cMensajeRet;
			
		END IF;
	
	END
END PROCEDURE
DOCUMENT
'AUTOR :        Daniel Hernandez Garcia',
'FECHA :        01-10-2025',
'DESCRIPCION :  Este SPL tiene la finalidad de generar los reporte de las cuentas de PDN(Prestamo Directo de Nomina) y de ADN (Anticipo de Nomina)',
'               considerando como terminarion al finar el dia anterior, mostrando solo las cuentas que cuentan con una exigencia de pago',
'PROYECTO :     RQM 09 704 Cobranza Automatica en Cuentas de Captacion',
'BD :           bdicred',
'VERSION :      1.0.0';

CREATE PROCEDURE "informix".apercred1_tc(
			 P_EMPRESA       VARCHAR(3),
             P_SOLICITUD     VARCHAR(20),
		 	 P_EJECUTIVO     CHAR(8))

RETURNING CHAR(5),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),CHAR(1);
--Martha Aguirre
--08-Sep-09
--Se agrega filtro por tipo de ingreso en la busqueda de tabla si_ingresos
--*****************************************************
--DECLARACION DE VARIABLES
--*****************************************************
DEFINE V_SECUENCIA_MAX       INTEGER;
DEFINE V_EQ_DIAS             INTEGER;
DEFINE V_EXISTE_REG          INTEGER;
DEFINE P_ERROR               VARCHAR(8);
DEFINE cCodRetTDif			 CHAR(6);		-- CODIGO DE RETORNO OBTIENE TASAS DE INTERES DIFERENCIADAS
DEFINE P_MENSAJE             VARCHAR(80);
DEFINE V_DIF_INT             INTEGER;
DEFINE V_FECHA_FIN_PRORRATEO DATE;
DEFINE V_INSERT              INTEGER;
DEFINE V_E_CODTRASP          INTEGER;
DEFINE V_TASA_INTERES        DECIMAL(9,6);
DEFINE V_TASA_MORA           DECIMAL(9,6);
DEFINE V_SOBRETASA           DECIMAL(9,6);
DEFINE V_SOBRETASA_MORA      DECIMAL(9,6);
DEFINE V_TASA_FAVOR          DECIMAL(9,6);
DEFINE V_SOBRETASA_FAV       DECIMAL(9,6);
DEFINE V_FACTOR	             CHAR(1);
DEFINE V_FACTOR_MORA         CHAR(1);
DEFINE V_FECHA_APERT         DATE;
DEFINE V_FECHA_VENC          DATE;
define v_num_credito         char(20);
define vdigverif             char(1);
DEFINE SQL_ERR               INTEGER;
DEFINE ISAM_ERR              INTEGER;
DEFINE ERROR_INFO            VARCHAR(80);
define vcodret               char(5);
DEFINE vNumCte               CHAR(20);
DEFINE vTpCte                CHAR(1);
DEFINE vIngreso              DECIMAL(14,2);
DEFINE V_FACTOR_FAV          CHAR(1);
DEFINE V_PRODUCTO            CHAR(4);
DEFINE VV_DIVISA             CHAR(2);
DEFINE V_MONTO               DECIMAL(14,2);
DEFINE VV_SUCURSAL           CHAR(4);
DEFINE VV_FOLIO	             CHAR(16);
DEFINE vMensaje              CHAR(200);
DEFINE vFechaT               DATE;
DEFINE vDiaCorte             SMALLINT;
DEFINE i		     SMALLINT;
DEFINE V_CATIVA		     DECIMAL(9,6);
DEFINE V_MERCADEO            CHAR(1);
DEFINE iSecIngreso SMALLINT;
---I---RQM 10 960 TDC GC
DEFINE vPtosTasaPref		DECIMAL(9,6);
DEFINE vIdTasaFref			CHAR(1);
DEFINE v_cont				INTEGER;
---F---RQM 10 960 TDC GC
--RQM 10 679 AAME
DEFINE cCodRetOro	 CHAR(6);
DEFINE cMenRet VARCHAR(100,1);
DEFINE dLinea		  DECIMAL(18,2)	;
DEFINE cSolOro		  CHAR(20) ;
DEFINE iConfirmaOro		SMALLINT ;
DEFINE cTelCel		CHAR(10) ;
DEFINE cCodRet		CHAR(6) ;

DEFINE dFechaT              DATE;
DEFINE iDiaPago      	INTEGER;
DEFINE iFrecuencia      	INTEGER;

DEFINE cMensajeRet      VARCHAR(80,1);
DEFINE vCatFinal            DECIMAL(21,10);
DEFINE dPagoReq      	DECIMAL(18,2);

DEFINE cCobro_Apertu    CHAR(1);            -- INI RQM 10 993 CAT
DEFINE cCodComis_Apert  CHAR(4);
DEFINE cCobrComisAnual  CHAR(1);
DEFINE dClvComAnualTit  CHAR(4);
DEFINE dClvComAnualAdi  CHAR(4);      
DEFINE cCat_adicional   CHAR(1);            
DEFINE dMtoComAnualTit  DECIMAL(18,2);
DEFINE dMtoComAnualAdi  DECIMAL(18,2);			  
DEFINE mMntoComApert    DECIMAL(18,2);      
DEFINE dComisiones      DECIMAL(18,2);
DEFINE mMntoComAnual    DECIMAL(18,2);      -- FIN RQM 10 993 CAT
DEFINE dComs_GastCob	DECIMAL(18,2);		-- RQM 10 1253
DEFINE cGrupo_sol		CHAR(1);			-- INI RQM 10 1224
DEFINE cEvalua_cc_sol	CHAR(1);
DEFINE dMax_fecha_tasa	DATE;				-- FIN RQM 10 1224

--- Cuenta Clabe RQM 06 683
DEFINE vcod_ret				CHAR (6);
DEFINE cta_Clabe			CHAR (18);
DEFINE gpo              CHAR(1); --RQM 10 1225
DEFINE evalcc           CHAR(1); --RQM 10 1225
DEFINE v_idi            CHAR(1); --RQM 10 1225
DEFINE vDispEfec        CHAR(1); --RQM 10 1225
DEFINE v_indde          SMALLINT; --RQM 10 1225
DEFINE cIFRS			CHAR(1);
DEFINE cStatus_cred 	CHAR(2);
DEFINE iAtr_Act_ifrs	INTEGER;

--RQM 09 616
DEFINE cCanal           CHAR(1);
DEFINE cStatuSol        CHAR(2);

-- Bloqueo por apertura en horario de cierre
DEFINE dFechaIntegral   DATE;
DEFINE dFechaCierreCred   DATE;
DEFINE dFechaHabilAnt		DATE;
DEFINE cStatusCierreCred  CHAR(1);
DEFINE cIndCierreCheq   CHAR(1);
DEFINE cCodRet2 			  CHAR(5);
DEFINE cCuentaSolDif    INT;
-- Bloqueo por apertura en horario de cierre

-- SET DEBUG FILE TO "/home/c90271846/apercred1_tc.out";
-- TRACE ON;

LET V_TASA_MORA = 0;
LET V_TASA_INTERES = 0;
LET V_MERCADEO = "";

---I---RQM 10 960 TDC GC
LET vPtosTasaPref = 0;
LET vIdTasaFref = "";
LET v_cont = 0;
---F---RQM 10 960 TDC GC

--RQM 10 679 AAME
LET  cCodRetOro	= "";
LET  cMenRet = "";
LET  dLinea	 = 0;
LET  cSolOro = "";
LET  iConfirmaOro = 0;

LET cTelCel = "";
LET dFechaT = DATE(1);
LET iDiaPago = 0;
LET iFrecuencia = 0;
LET cCodRet             = "000000";
LET cMensajeRet         = "Se realizo el calculo correctamente";
LET vCatFinal =0;
LET dPagoReq =0;

LET cCobro_Apertu    = '';          -- INI RQM 10 993 CAT
LET cCodComis_Apert  = '';
LET cCobrComisAnual  = '';
LET dClvComAnualTit  = '';
LET dClvComAnualAdi  = '';
LET cCat_adicional   = '';
LET dMtoComAnualTit  = 0;
LET dMtoComAnualAdi  = 0;
LET mMntoComApert    = 0;
LET mMntoComAnual    = 0;
LET dComisiones      = 0;           -- FIN RQM 10 993 CAT
LET dComs_GastCob	 = 0;			-- RQM 10 1253
LET V_SOBRETASA      = 0;
LET V_SOBRETASA_MORA = 0;
LET V_FACTOR		 = '';
LET V_FACTOR_MORA	 = '';
LET cGrupo_sol		 = ''; 
LET cEvalua_cc_sol	 = ''; 
LET dMax_fecha_tasa	 = DATE(1);
LET cCodRetTDif		 = '';

--- Cuenta Clabe RQM 06 683
LET vcod_ret			= '000';
LET cta_Clabe			= '';
LET gpo              =''; --RQM 10 1225
LET evalcc           =''; --RQM 10 1225
LET v_idi            =''; --RQM 10 1225
LET vDispEfec        =''; --RQM 10 1225
LET v_indde          = 0; --RQM 10 1225
LET cIFRS			 = '';
LET cStatus_cred 	 = '';
LET iAtr_Act_ifrs	 = 0;

--RQM 09 616
LET cCanal           = '';
LET cStatuSol        = '';

-- Bloqueo por apertura en horario de cierre
LET dFechaIntegral   = DATE(1);
LET dFechaCierreCred   = DATE(1);
LET dFechaHabilAnt   = DATE(1);
LET cStatusCierreCred  = '1';
LET cIndCierreCheq   = '1';
LET cCodRet2			   = '00000';
LET cCuentaSolDif    = 0;
-- Bloqueo por apertura en horario de cierre

--   Asigna el Valor del CAT con IVA para el Contrato TC MEL 15 May 2008
SELECT valor INTO V_CATIVA
FROM   sd_param
WHERE  cod_param = '034';

IF V_CATIVA IS NULL THEN
   LET V_CATIVA = 0;
END IF

BEGIN
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
		LET P_ERROR    = SQL_ERR;
		LET P_MENSAJE  = ERROR_INFO;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		DELETE FROM SD_MAESDOS
		WHERE EMPRESA = P_EMPRESA
		AND NUM_CREDITO = P_SOLICITUD;

		DELETE FROM SD_MOVDIA
		WHERE EMPRESA = P_EMPRESA
	    AND NUM_CREDITO = P_SOLICITUD;

		DELETE FROM SD_MAECREDANEXO
		WHERE EMPRESA = P_EMPRESA
	    AND NUM_CREDITO = P_SOLICITUD;

        UPDATE bdisolic:ss_solicitudes SET status_solicitud = "AT"
        WHERE empresa = P_EMPRESA
        AND num_solicitud = P_SOLICITUD;

		DELETE FROM bdisolic:ss_autorizacion
        WHERE empresa = P_EMPRESA
        AND num_solicitud = P_SOLICITUD
	    AND status_solicitud = "AP";

		DELETE FROM bdicred:sd_amortiza_credito
		WHERE EMPRESA = P_EMPRESA
	    AND NUM_CREDITO = P_SOLICITUD;

		DELETE FROM SD_MAECRED
		WHERE EMPRESA = P_EMPRESA
	    AND NUM_CREDITO = P_SOLICITUD;

		DELETE FROM SD_INDICADOR_CRED
		WHERE EMPRESA = P_EMPRESA
	    AND NUM_CREDITO = P_SOLICITUD;
		
        RETURN P_ERROR,V_TASA_INTERES,V_TASA_MORA,V_CATIVA,V_MERCADEO;
	END EXCEPTION;

	--***********************
    --INICIALIZA VARIABLE
    --***********************
	LET V_EXISTE_REG = 0;
    LET P_ERROR      = '00000';
    LET P_MENSAJE    = 'PROCESO EXITOSO';
    LET V_EQ_DIAS    = 0;
    LET V_DIF_INT    = 0;
    LET V_FECHA_FIN_PRORRATEO = NULL;
    LET v_num_credito = "";
    LET i = 0;

    -- ******************
    -- Determina Fechas *
    -- ******************

	SELECT fecha_hoy
	INTO V_FECHA_APERT
	FROM sd_fechas
	WHERE empresa = P_EMPRESA;
	
    -- INC 27 331 Bloqueo de aperturas para el producto 7800 Anticipo de Nomina
    SELECT fecha_hoy INTO dFechaIntegral FROM bdinteg:"informix".si_fechas WHERE empresa = '001';
    SELECT max(fecha) INTO dFechaCierreCred FROM "informix".sd_contproc WHERE empresa = '001' AND proceso = "CierreCred";
    SELECT status_proc INTO cStatusCierreCred FROM "informix".sd_contproc WHERE proceso = "CierreCred" AND fecha = dFechaCierreCred;
    SELECT ind_cierre INTO cIndCierreCheq FROM bdicheq:"informix".sc_fechas WHERE empresa = '001';

    EXECUTE PROCEDURE "informix".sp_valfechabil((dFechaIntegral - 1),'-') INTO cCodRet2, dFechaHabilAnt;

    IF cIndCierreCheq = '0' OR dFechaCierreCred <> dFechaHabilAnt OR UPPER(cStatusCierreCred) <> 'F' THEN	
		-- 00014, Por el momento no le podemos ofrecer el servicio. Por favor intenta mas tarde
        SELECT cod_return, mensaje
        INTO P_ERROR, cMenRet
        FROM bdisolic:"informix".ss_catalogo_mensajes
        WHERE empresa = '001'
        AND cod_msj = 'ADN_14';
        
        RETURN P_ERROR,V_TASA_INTERES,V_TASA_MORA,V_CATIVA,V_MERCADEO;
	END IF;
    
	-- INC 27 331 Bloqueo de aperturas para el producto 7800 Anticipo de Nomina
    --  Obtiene datos de comisiones de Apertura y Anualidad para calculo del CAT	
	SELECT a.num_producto, a.divisa, b.monto_solicitado, b.sucursal, nvl(a.cobro_comis_apertura,'0'), nvl(a.cod_comision_apertura,''), 
    a.cobro_comision_anual, substr(a.cod_comision_anualidad,1,4), substr(a.cod_comision_anualidad,5,4), a.cat_comi_anual_adicional, b.canal_sol, 
    b.numcte, b.status_solicitud
    INTO V_PRODUCTO, VV_DIVISA, V_MONTO, VV_SUCURSAL, cCobro_Apertu, cCodComis_Apert, cCobrComisAnual, dClvComAnualTit, dClvComAnualAdi, cCat_adicional, cCanal, 
    vNumCte, cStatuSol
    FROM bdisolic:ss_solicitudes b, sd_definicion a
    WHERE b.empresa = P_EMPRESA
    AND b.num_solicitud = P_SOLICITUD
    AND a.empresa = b.empresa
    AND a.num_producto = b.num_producto;

    -- ******************
    --RQM 09 616
    -- Si tiene un estatus diferente a AT no avanzar
    IF NVL(cStatuSol,'') != 'AT' THEN
		LET P_ERROR = '00001';
        RETURN P_ERROR,V_TASA_INTERES,V_TASA_MORA,V_CATIVA,V_MERCADEO;
	END IF;
    -- ******************

    -- INC 27 331 Bloqueo de aperturas para el producto 7800 Anticipo de Nomina
    IF (V_PRODUCTO = '7800') THEN
		SELECT    COUNT(*) INTO cCuentaSolDif
        FROM      bdisolic:"informix".ss_solicitudes
        WHERE     empresa = P_EMPRESA
        AND       numcte = vNumCte
        AND       num_producto = '7800'
        AND       status_solicitud IN ('AT','RT') -- SE ELIMINA EL STATUS AP
        AND       num_solicitud <> P_SOLICITUD;

        IF (cCuentaSolDif > 0 AND cCanal = '8') THEN
			-- 00015, Por el momento no podemos ofrecerte el servicio, acude a tu sucursal BanCoppel mas cercana para revisar la situacion de tu cuenta
			SELECT cod_return, mensaje
			INTO P_ERROR, cMenRet
			FROM bdisolic:"informix".ss_catalogo_mensajes
			WHERE empresa = '001'
			AND cod_msj = 'ADN_15';

			RETURN P_ERROR,V_TASA_INTERES,V_TASA_MORA,V_CATIVA,V_MERCADEO;
		ELIF (cCuentaSolDif > 0 AND cCanal <> '8') THEN
			LET P_ERROR = '00412'; -- EL CREDITO YA TIENE UNA SOLICITUD EN TRAMITE
			RETURN P_ERROR,V_TASA_INTERES,V_TASA_MORA,V_CATIVA,V_MERCADEO;
        END IF;
		
		-- CAX Mar 2026 se agrega validacion para rechazar la apertura con dia de corte nulo o vacio
		--se obtiene la fecha de la proxima cuota.
		EXECUTE PROCEDURE bdisolic:"informix".sp_obtienefechapagoadn('001',V_FECHA_APERT,P_SOLICITUD)
		INTO cCodRet,dFechaT,iDiaPago;
		
		IF (cCodRet <> "000" AND cCanal = '8') THEN
			-- 00015, Por el momento no podemos ofrecerte el servicio, acude a tu sucursal BanCoppel mas cercana para revisar la situacion de tu cuenta
			SELECT cod_return, mensaje
			INTO P_ERROR, cMenRet
			FROM bdisolic:"informix".ss_catalogo_mensajes
			WHERE empresa = '001'
			AND cod_msj = 'ADN_15';
			
			RETURN P_ERROR,V_TASA_INTERES,V_TASA_MORA,V_CATIVA,V_MERCADEO;
		ELIF (cCodRet <> "000" AND cCanal <> '8') THEN
			LET P_ERROR = '00001';
			RETURN P_ERROR,V_TASA_INTERES,V_TASA_MORA,V_CATIVA,V_MERCADEO;
		END IF;
		
		IF (dFechaT is null or dFechaT = '') AND cCanal = '8' THEN 
			-- 00015, Por el momento no podemos ofrecerte el servicio, acude a tu sucursal BanCoppel mas cercana para revisar la situacion de tu cuenta
			SELECT cod_return, mensaje
			INTO P_ERROR, cMenRet
			FROM bdisolic:"informix".ss_catalogo_mensajes
			WHERE empresa = '001'
			AND cod_msj = 'ADN_15';
			
			RETURN P_ERROR,V_TASA_INTERES,V_TASA_MORA,V_CATIVA,V_MERCADEO;
		END IF;
	END IF;
    -- INC 27 331 Bloqueo de aperturas para el producto 7800 Anticipo de Nomina

	--	SELECT fecha_hoy, fecha_hoy + 12 units month

	let  V_FECHA_VENC=date(0);

    call monthadd(V_FECHA_APERT,12) returning V_FECHA_VENC;
	 
    -- Valida si se encuentra activa funcionalidad de IFRS		
	SELECT valor INTO cIFRS FROM bdicred:sd_param WHERE cod_param = '700';
	IF cIFRS = 'A' THEN
		LET cStatus_cred = 'E1';
		LET iAtr_Act_ifrs = 0;
	ELSE
		LET cStatus_cred = 'AA';
		LET iAtr_Act_ifrs = NULL;
	END IF;
	 
	---AAME RQM 10 679 Se lee si la solicitud es candidato a oro y confirmo que si la quiere en la pantalla de asignacion
	SELECT  confirma_oro	
	INTO iConfirmaOro
	FROM  bdisolic:"informix".ss_solicitudes_tdcoro 
	WHERE numero_solicitud_oro = P_SOLICITUD;
	 
	IF  NVL(iConfirmaOro,0) = 1 THEN --AAME RQM 10 679 Clientes que se les apertura la solicitud de oro
		SELECT valor INTO V_CATIVA
		FROM   "informix".sd_param
		WHERE  cod_param = '093';
	END IF;
	
	-- ****************************
    -- Determina Tasas de Interes *
    -- ****************************
	/*--INTERES ORDINARIO 
    SELECT c.valor, a.factor_sobretasa, a.sobretasa, a.dia_cuota, a.id_tasa_pref, a.puntos_tasa_pref, a.ind_disp_efec
	INTO V_TASA_INTERES, V_FACTOR, V_SOBRETASA, vDiaCorte, vIdTasaFref, vPtosTasaPref, vDispEfec
	FROM sd_definicion a, bdisolic:ss_solicitudes b,
	bdinteg:si_fechavalor c
	WHERE b.empresa = P_EMPRESA
	AND num_solicitud = P_SOLICITUD
	AND a.empresa = b.empresa
	AND a.num_producto = b.num_producto
	AND c.empresa = a.empresa
	AND c.tasa = a.cod_tasa_base
	AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:si_fechavalor r
	WHERE r.empresa = P_EMPRESA
	AND r.tasa = a.cod_tasa_base);
	*/			--	RQM 10 1224
	
	EXECUTE PROCEDURE bdicred:"informix".sp_obtiene_tasa_int_diferenciadas(P_EMPRESA, P_SOLICITUD, '') INTO cCodRetTDif, V_TASA_INTERES, V_TASA_MORA;
	IF cCodRetTDif <> '000000' THEN
		LET P_ERROR = cCodRetTDif;
		RETURN P_ERROR,V_TASA_INTERES,V_TASA_MORA,V_CATIVA,V_MERCADEO;
	END IF;	
	   
	SELECT a.factor_sobretasa, a.sobretasa, a.dia_cuota, a.id_tasa_pref, a.puntos_tasa_pref, a.fact_sobret_mora, a.sobretasa_mora, a.ind_disp_efec
	INTO V_FACTOR,           V_SOBRETASA, vDiaCorte,   vIdTasaFref,    vPtosTasaPref,      V_FACTOR_MORA,      V_SOBRETASA_MORA, vDispEfec
	FROM bdicred:sd_definicion a JOIN bdisolic:ss_solicitudes b ON (a.empresa = b.empresa AND a.num_producto = b.num_producto AND a.empresa = P_EMPRESA AND b.num_solicitud = P_SOLICITUD);
	
	IF v_factor = "+" THEN
		LET V_TASA_INTERES = V_TASA_INTERES + V_SOBRETASA;
	ELIF v_factor = "-" THEN
		LET V_TASA_INTERES = V_TASA_INTERES - V_SOBRETASA;
	ELIF v_factor = "*" THEN
		LET V_TASA_INTERES = V_TASA_INTERES * V_SOBRETASA;
	ELSE
		LET V_TASA_INTERES = V_TASA_INTERES / V_SOBRETASA;
	END IF
	
	---I---RQM 10 960 TDC GC
	---- VALIDACION PARA CALCULO DE TASA PREFERENCIAL
	IF vIdTasaFref = '1' THEN
	
		SELECT COUNT (*) 
		INTO v_cont
		FROM bdicred:"informix".sd_ctascarg
		WHERE empresa = P_EMPRESA AND num_credito = P_SOLICITUD;
	
		IF v_cont <> 0 THEN
			LET V_TASA_INTERES = V_TASA_INTERES - vPtosTasaPref;
		END IF
		
		IF V_TASA_INTERES < 0 THEN
			LET V_TASA_INTERES = 0;
		END IF

	END IF
	---F---RQM 10 960 TDC GC
	--INTERES MORATORIO
    /*SELECT c.valor, a.fact_sobret_mora, a.sobretasa_mora
    INTO V_TASA_MORA   , V_FACTOR, V_SOBRETASA
    FROM sd_definicion a, bdisolic:ss_solicitudes b,
    bdinteg:si_fechavalor c
    WHERE b.empresa = P_EMPRESA
    AND num_solicitud = P_SOLICITUD
    AND a.empresa = b.empresa
    AND a.num_producto = b.num_producto
    AND c.empresa = a.empresa
    AND c.tasa = a.cod_tasa_mora
    AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:si_fechavalor r
    WHERE r.empresa = P_EMPRESA
    AND r.tasa = a.cod_tasa_mora);
	*/													--	RQM 10 1224
    
	IF V_FACTOR_MORA = "+" THEN
		LET V_TASA_MORA = V_TASA_MORA + V_SOBRETASA_MORA;
	ELIF V_FACTOR_MORA = "-" THEN
		LET V_TASA_MORA = V_TASA_MORA - V_SOBRETASA_MORA;
	ELIF V_FACTOR_MORA = "*" THEN
		LET V_TASA_MORA = V_TASA_MORA * V_SOBRETASA_MORA;
	ELSE
		LET V_TASA_MORA = V_TASA_MORA / V_SOBRETASA_MORA;
	END IF
    
	--INTERES A FAVOR DEL CLIENTE
    SELECT c.valor, a.factor_sobretasa, a.sobretasa
    INTO V_TASA_FAVOR   , V_FACTOR_FAV, V_SOBRETASA_FAV
    FROM sd_anexodefinicion a, bdisolic:ss_solicitudes b,
    bdinteg:si_fechavalor c
    WHERE b.empresa = P_EMPRESA
    AND num_solicitud = P_SOLICITUD
    AND a.empresa = b.empresa
    AND a.num_producto = b.num_producto
    AND c.empresa = a.empresa
    AND c.tasa = a.cod_tasa_base
    AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:si_fechavalor r
    WHERE r.empresa = P_EMPRESA
    AND r.tasa = a.cod_tasa_base);

	IF V_FACTOR_FAV = "+" THEN
		LET V_TASA_FAVOR = V_TASA_FAVOR + V_SOBRETASA_FAV;
	ELIF V_FACTOR_FAV = "-" THEN
		LET V_TASA_FAVOR = V_TASA_FAVOR - V_SOBRETASA_FAV;
	ELIF V_FACTOR_FAV = "*" THEN
		LET V_TASA_FAVOR = V_TASA_FAVOR * V_SOBRETASA_FAV;
	ELSE
		LET V_TASA_FAVOR = V_TASA_FAVOR / V_SOBRETASA_FAV;
	END IF

	--- Genera cuenta Clabe 
	EXECUTE PROCEDURE bdicred:"informix".sp_gen_clabe_interbancaria (P_EMPRESA,P_SOLICITUD,V_PRODUCTO)
	INTO vcod_ret, cta_Clabe;
	
	--***** ACTUALIZA SD_MAECRED
	INSERT INTO bdicred:sd_maecred
               (EMPRESA                ,NUM_CREDITO
               ,NUM_PRODUCTO           ,EJECUTIVO
               ,NUMCTE                 ,DIVISA
               ,SUCURSAL               ,ID_ORIGEN
               ,ORIGEN                 ,COD_TIPO_LINEA
               ,COD_LINEA              ,PORC_REC_PROP
               ,STATUS_CRED            ,BANDERA_RENOVAC
               ,BANDERA_PRORROGA       ,PERIODO_PLAZO
               ,PLAZO                  ,FECHA_APERTURA
               ,FECHA_VENCIM           ,PERIOD_PAGO_CAP
               ,PERIOD_PAG_INT         ,DIAS_TRASP_CAP
               ,DIAS_TRASP_INT         ,TASA_FIJA_O_VAR
               ,COD_TASA_BASE          ,FACTOR_SOBRETASA
               ,SOBRETASA              ,TASA_INTERES
               ,COD_TASA_MORA          ,SOBRETASA_MORA
               ,FACT_SOBRET_MORA       ,TASA_MORATORIOS
               ,FECHA_PAGO_CAP         ,FECHA_PAGO_INT
               ,ES_FISICA              ,BANDERA_FI_FO
               ,CODIGO_PRO             ,SUPERFICIE
               ,ACTIVIDAD              ,CAL_EDOS_FIN
               ,TIPO_CALCULO           ,ADMITE_TLP
               ,REL_GARCRED            ,ID_UNIDAD_PROD
               ,NUM_APER_ANT           ,REV_TASA_VAR_PER
               ,DIA_PARA_REVISAR       ,COD_PROD
               ,BANDERA_MINISTRA       ,NUM_FIDEICOMISO
               ,CREDITO_EXTERNO        ,GRACIA_CAPITAL
               ,DIFERIMIENTO_INT       ,FECHA_FIN_PRORRATEO
               ,CAMPO_TRAB1            ,CAMPO_TRAB2
               ,CAMPO_TRAB3            ,CAMPO_TRAB4
               ,CALIFICACION_RIESGO    ,COD_AGRICOLA
               ,TASA_BASE_PISO         ,SOBRETASA_PISO
               ,FACTOR_PISO            ,TASA_PISO
               ,TASA_BASE_TECHO        ,SOBRETASA_TECHO
               ,FACTOR_TECHO           ,TASA_TECHO
			   ,cuenta_clabe
               )
    SELECT SOL.EMPRESA                ,P_SOLICITUD
               ,SOL.NUM_PRODUCTO           ,ANX.EJECUTIVO_SOL
               ,SOL.NUMCTE                 ,DEF.DIVISA
               ,SOL.SUCURSAL               ,''
               ,''                         ,''
               ,''                         ,100
               --IFRS ,'AA'                       ,'N'
			   ,cStatus_cred               ,'N'
               ,'N'                        ,DEF.PERIODO_PLAZO
               ,0                          ,V_FECHA_APERT
               ,V_FECHA_VENC               ,"3"
               ,"2"                        ,CTR.DIAS_TRAS_CAP
               ,CTR.DIAS_TRAS_INT          ,DEF.TASA_FIJA_O_VAR
               ,DEF.COD_TASA_BASE          ,DEF.FACTOR_SOBRETASA
               ,DEF.SOBRETASA              ,V_TASA_INTERES
               ,DEF.COD_TASA_MORA          ,DEF.SOBRETASA_MORA
               ,DEF.FACT_SOBRET_MORA       ,V_TASA_MORA
               ,''                         ,''
               ,TIP.ES_FISICA              ,''
               ,DEF.COD_PROD               ,0
               ,''                         ,''
               ,DEF.TIPO_CALCULO           ,''
               ,0                          ,''
               ,''                         ,DEF.REV_TASA_VAR_PER
               ,DEF.DIA_PARA_REVISAR       ,''
               ,'M'                        ,''
               ,''                         ,0
               ,0                          ,V_FECHA_APERT
               ,0                          ,0
               ,''                         ,CASE WHEN (DEF.NUM_PRODUCTO='8100') THEN '1' ELSE '' END
               ,'A'                        ,''
               ,''                         ,''
               ,''                         ,''
               ,''                         ,''
               ,''                         ,''
			   ,cta_Clabe
	FROM   BDISOLIC:SS_SOLICITUDES SOL
    , BDISOLIC:SS_ANEXOSOL    ANX
    , BDINTEG:SI_CLIENTE      CLI
    , BDINTEG:SI_TIPPER       TIP
    , SD_CODTRASP             CTR
    , SD_DEFINICION           DEF
    WHERE  DEF.EMPRESA         = SOL.EMPRESA
    AND    DEF.NUM_PRODUCTO    = SOL.NUM_PRODUCTO
    AND    CTR.PERIOD_PAG_INT  = "2"
    AND    CTR.PERIOD_PAGO_CAP = "3"
    AND    CTR.NUM_PRODUCTO    = DEF.NUM_PRODUCTO
    AND    CTR.EMPRESA         = DEF.EMPRESA
    AND    TIP.TPO_PERSONA     = CLI.TPO_PERSONA
    AND    CLI.NUMCTE          = SOL.NUMCTE
    AND    CLI.EMPRESA         = SOL.EMPRESA
    AND    ANX.NUM_SOLICITUD   = SOL.NUM_SOLICITUD
    AND    ANX.EMPRESA         = SOL.EMPRESA
    AND    SOL.NUM_SOLICITUD   = P_SOLICITUD
    AND    SOL.EMPRESA         = P_EMPRESA;
    --END;

    --LET V_INSERT = DBINFO("SQLCA.SQLERRD1");
    --IF V_INSERT = 0 THEN
    --LET P_ERROR = '00001';
    --LET P_MENSAJE = 'EXISTE ERROR EN LA INFORMACION DEL CREDITO';
    --RETURN P_ERROR, P_MENSAJE,v_num_credito;
    --END IF;

	--***** ACTUALIZA SD_MAESDOS
	INSERT INTO SD_MAESDOS (EMPRESA                ,NUM_CREDITO
                                ,FECHA_ULT_MOV          ,SDO_INT_ANTICIP
                                ,SDO_INT_ANT_DEV        ,SDO_INTERESES
                                ,SDO_DIA_ANT_INT        ,SDO_MES_ANT_INT
                                ,SDO_ACUM_MES_INT       ,SDO_RETENIDO
                                ,SDO_ACUM_CAP_INT       ,SDO_EXIG_INT
                                ,SDO_NO_EXIG            ,PROVISION_NORMAL
                                ,DIAS_ACUM_INT          ,SDO_MORATORIO
                                ,SDO_DIA_ANT_MOR        ,SDO_MES_ANT_MOR
                                ,SDO_CONTAB_MORA        ,DIAS_ACUM_MORA
                                ,SDO_CAPITAL            ,SDO_CAP_INSOLUTO
                                ,SDO_DIA_ANT_CAP        ,SDO_MES_ANT_CAP
                                ,SDO_ACUM_MES_CAP       ,MTO_CAPITALIZADO
                                ,MTO_MINISTRA_CAP       ,CARGOS_DIA_CAP
                                ,ABONOS_DIA_CAP         ,CARGOS_MES_CAP
                                ,ABONOS_MES_CAP         ,DIAS_ACUM_CAP
                                ,MONTO_VENCIDO          ,MTO_VENC_TRASP
                                ,MONTO_FINANCIADO       ,MONTO_RESERVADO
                                ,SDO_ACUM_VENCIDO       ,DIAS_ACUM_INTPER
                                ,SDO_GLOBAL_INT         ,SDO_ACUM_INTPER
                                ,MONTO_OTORGADO         ,PROVI_VENC_NORMAL
                                ,PROVI_VENC_ANTICIP     ,CAP_TRAS_NO_VENCI
                                ,MTO_VENC_INT           ,MTO_VENC_TRA_INT
                                ,MTO_FINAN_VDO          ,MTO_RESER_INT
                                ,MTO_FIN_VEN_TRASP      ,MTO_FIN_VIG_TRASP
                                ,INT_TRA_NO_EXIG        ,SDO_TRAB4
								,ACT
                                )
	SELECT SOL.EMPRESA            ,P_SOLICITUD
                                ,TODAY                  ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,SOL.MONTO_SOLICITADO   ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
								,iAtr_Act_ifrs
	FROM   BDISOLIC:SS_SOLICITUDES SOL
	WHERE  SOL.NUM_SOLICITUD = P_SOLICITUD
	AND    SOL.EMPRESA   = P_EMPRESA;

	SELECT USER
	|| REPLACE(REPLACE(CURRENT HOUR TO FRACTION,':',''),'.','') FOLIO
    INTO VV_FOLIO
    FROM sd_fechas where empresa = '001';

	EXECUTE PROCEDURE GENMOV( P_EMPRESA         , P_SOLICITUD,
	                        V_PRODUCTO        , 1,
							"001"             , V_FECHA_APERT,
                            V_MONTO           , VV_FOLIO,
                            VV_SUCURSAL       ,VV_DIVISA,
                            "0000")
	INTO P_ERROR, P_MENSAJE;

    -- *********************************************************
    -- INSERTA PRIMEROS 12 MESES DE LA TABLA DE AMORTIZACIONES *
    -- *********************************************************
	IF V_PRODUCTO  <> "7800" THEN
		LET vFechaT = MONTH(V_FECHA_APERT) || "/" || vDiaCorte || "/" ||
		    YEAR(V_FECHA_APERT);
		IF DAY(V_FECHA_APERT) > vDiaCorte THEN
			CALL sp_calcula_fecha ("001" ,1 ,"M" ,vFechaT ,"01" ,"01")
			RETURNING P_ERROR, P_MENSAJE, vFechaT;
		END IF

        FOR i = 1 TO 12
			INSERT INTO sd_amortiza_credito values
			(P_EMPRESA,P_SOLICITUD,vFechaT,"3",0,0,0,"1","0","",
            0,0,"1","0","",
            0,0,"1","0","",
            0,0,0,0,0,0,0,"1",
            0,0,"1","",
            i,0,0,"","");

            EXECUTE PROCEDURE sp_calcula_fecha
            (P_EMPRESA ,1 ,"M" ,vFechaT ,"01" ,"01")
            INTO P_ERROR, P_MENSAJE, vFechaT;
        END FOR
	END IF
    
	-- **************************************
    -- Actualiza el Estatus de la Solicitud *
    -- **************************************
    UPDATE bdisolic:ss_solicitudes SET status_solicitud = "AP"
	WHERE empresa = P_EMPRESA
    AND num_solicitud = P_SOLICITUD;

    SELECT nombre INTO vMensaje
    FROM bdinteg:si_ejecut
    WHERE ejecutivo = P_EJECUTIVO
    AND empresa = P_EMPRESA;

    LET vMensaje = "Apertura de Credito Autorizada por: " || TRIM(vMensaje);

    INSERT INTO bdisolic:ss_autorizacion
    (empresa, ejecutivo_auto, num_solicitud, status_solicitud,
    comentario, fecha_entrada, fecha_salida, user_insert, fecha_insert)
    VALUES(P_EMPRESA, P_EJECUTIVO, P_SOLICITUD, "AP", vMensaje,
	V_FECHA_APERT, V_FECHA_APERT, USER, TODAY);

    INSERT INTO bdicred:"informix".sd_indicador_cred
	(empresa,num_credito, fecha_alta)
    VALUES(P_EMPRESA,P_SOLICITUD,V_FECHA_APERT );
    
	-- ******************************
    -- Actualiza Datos del Cliente  *
    -- ******************************

    SELECT tipo_cliente, NVL(ingreso_mensual,0)
    INTO vTpCte, vIngreso
    FROM bdinteg:si_cliente a, bdisolic:ss_solicitudes b,
	bdisolic:ss_resum_scor_fin c
    WHERE a.numcte = b.numcte
    AND b.empresa = P_EMPRESA
    AND b.num_solicitud = P_SOLICITUD
    AND c.empresa = b.empresa
    AND c.num_solicitud = b.num_solicitud;

    -- Saca la Publicacion de si_ctepf Jose Luis Puebla
    SELECT string1 INTO V_MERCADEO 
    FROM   bdinteg:si_ctepf 
    WHERE  numcte = vNumCte;
       
	IF  V_PRODUCTO   =  "7800" THEN
		--Se actualiza la solicitud de credito ligada a la cuenta y movil	
		SELECT  movil_cuenta ,frecuencia_pgo
		INTO cTelCel ,iFrecuencia
		FROM   bdisolic:"informix".ss_adn_solicitudcuenta		
		WHERE numcte = vNumCte
		AND num_solicitud  = P_SOLICITUD;
		
		--se obtiene la fecha de la proxima cuota.
		--EXECUTE PROCEDURE bdisolic:"informix".sp_obtienefechapagoadn('001',V_FECHA_APERT,P_SOLICITUD)
		--INTO cCodRet,dFechaT,iDiaPago;

		INSERT INTO sd_maecredanexo
		(empresa,               num_credito,
		dia_corte,             dias_gracia_mora,
		tp_dias_calc_mora,     dias_fecha_max_pago,
		tp_dias_fecha_pago,    cod_tasa_base_cte,
		factor_sobretasa_cte,  sobretasa_cte,
		tasa_interes_cte,      fecha_proceso,prox_fecha_pago )
		SELECT P_EMPRESA,               P_SOLICITUD,
	    DAY(dFechaT),           def.gracia_calc_mora,
	    def.pago_adic_sig_cuo,   def.tipo_cliente,
	    iFrecuencia,        def.cod_tasa_base,
	    def.factor_sobretasa,    def.sobretasa,
	    V_TASA_FAVOR,            V_FECHA_APERT ,dFechaT
		FROM sd_definicion def, sd_anexodefinicion b,
	    bdisolic:ss_solicitudes c
		WHERE c.empresa = P_EMPRESA
		AND c.num_solicitud = P_SOLICITUD
		AND def.empresa = c.empresa
		AND def.num_producto = c.num_producto
		AND b.empresa = def.empresa
		AND b.num_producto = c.num_producto
		AND b.cod_prod = def.cod_tipcred;

		-- SE INSERTA INSERTA INFORMACION EN LA TABLA DE AMORTIZACIONES
		/*INSERT INTO "informix".sd_amortiza_credito
		(
			empresa, 			num_credito,
			fecha_cuota, 		tipo_cuota,
			capital_mto_cuota, 	capital_debe,
			capital_pagado, 	capital_status,
			capital_status_ant, capital_fecha_pago,
			interes_debe, 		interes_pagado,
			interes_status, 	interes_status_ant,
			interes_fecha_pago, iva_debe,
			iva_pagado, 		iva_status,
			iva_status_ant, 	iva_fecha_pago,
			mora_provi_ordi, 	mora_provi_cope,
			mora_sdo_ordi, 		mora_sdo_ordi_pag,
			mora_sdo_cope, 		mora_sdo_cope_pag,
			mora_bonificado, 	mora_status,
			mora_iva_debe, 		mora_iva_pagado,
			mora_iva_status, 	mora_iva_fecha_pago,
			num_pago, 			campo_trabajo1,
			campo_trabajo2, 	campo_trabajo3,
			campo_trabajo4
		)
		VALUES
		(
			P_EMPRESA,			P_SOLICITUD,
			dFechaT,			"3",
			0,					0,
			0,					"3",
			"3",				"",
			0,					0,
			"1",				"1",
			"",					0,
			0,					"1",
			"1",				"",
			0,					0,
			0,					0,
			0,					0,
			0,					"1",
			0,					0,
			"1",				"",
			1,					0,
			0,					"",
			""
		);*/

	ELSE
		INSERT INTO sd_maecredanexo
		(empresa,               num_credito,
		dia_corte,             dias_gracia_mora,
		tp_dias_calc_mora,     dias_fecha_max_pago,
		tp_dias_fecha_pago,    cod_tasa_base_cte,
		factor_sobretasa_cte,  sobretasa_cte,
		tasa_interes_cte,      fecha_proceso )
		SELECT P_EMPRESA,               P_SOLICITUD,
	    def.dia_cuota,           def.gracia_calc_mora,
	    def.pago_adic_sig_cuo,   def.tipo_cliente,
	    def.maneja_linea,        def.cod_tasa_base,
	    def.factor_sobretasa,    def.sobretasa,
	    V_TASA_FAVOR,            V_FECHA_APERT
		FROM sd_definicion def, sd_anexodefinicion b,
	    bdisolic:ss_solicitudes c
		WHERE c.empresa = P_EMPRESA
		AND c.num_solicitud = P_SOLICITUD
		AND def.empresa = c.empresa
		AND def.num_producto = c.num_producto
		AND b.empresa = def.empresa
		AND b.num_producto = c.num_producto
		AND b.cod_prod = def.cod_tipcred;
	END IF
	
    IF vTpCte = "1" THEN
		SELECT MAX(sec_ingreso) INTO iSecIngreso FROM bdinteg:si_ingresos WHERE empresa = P_EMPRESA
		AND numcte = vNumCte AND tipo_ingreso = 'T';
		
		UPDATE bdinteg:si_ingresos
		SET ingreso_mensual = vIngreso
		WHERE empresa = P_EMPRESA
		AND numcte = vNumCte
		AND tipo_ingreso = "T"
		AND sec_ingreso = iSecIngreso;
    ELSE
		UPDATE bdinteg:si_cliente
		SET tipo_cliente = "1"
		WHERE numcte = vNumCte;
		
		SELECT NVL(MAX(sec_ingreso), 0) + 1 INTO iSecIngreso
		FROM bdinteg:si_ingresos 
		WHERE empresa = P_EMPRESA 
		AND numcte = vNumCte 
		AND tipo_ingreso = "T";

		INSERT INTO bdinteg:si_ingresos
		(empresa, numcte, sec_ingreso, tipo_ingreso, ingreso_mensual)
		VALUES
		(P_EMPRESA, vNumCte, iSecIngreso, "T", vIngreso);
    END IF

    -- Resta el Valor de la Tasa Moratoria con la de Intereses
    -- Solicitado por el Banco JLP 23May2008
    LET V_TASA_MORA = V_TASA_MORA - V_TASA_INTERES;
    IF V_TASA_MORA < 0 THEN --Si es Menor a Cero la vuelve Positivo
		LET V_TASA_MORA = V_TASA_MORA * -1;
    END IF
	
	IF V_PRODUCTO  = "7800" THEN
        IF cCanal IN ('1','3','5') THEN
            --Mandar el registra evento para el envio de mensajes
            --insertar en la tabla para enviar sms	 Â¡Felicidades! Tu Anticipo de Nomina ha sido autorizado, puedes disponer de hasta $#,### cuando lo necesites.	
            EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_1' , '000000000','', '','1', V_MONTO, '', '', '', '', '', '', '', '', '', '', cTelCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
            --insertar en la tabla para enviar sms	Solicita tu Anticipo de Nomina enviando un SMS al ###### con la palabra Anticipo + monto que deseas sin signo de pesos?	
            EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_2' , '000000000','', '','1', '', '', '', '', '', '', '', '', '', '', '', cTelCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;	
        END IF;
    ELSE
		LET dPagoReq = V_MONTO * (V_TASA_INTERES /100) / 360 * 30;
        IF cCobro_Apertu = '1' THEN    -- Si el producto tiene cobro de comision por apertura.
            SELECT monto INTO mMntoComApert FROM bdicred:"informix".sd_tpcomis WHERE empresa = '001' AND cod_comis = cCodComis_Apert; 
            LET mMntoComApert = NVL(mMntoComApert,0);                                       -- Se toma cat originacion. Se agrega com apertura
        END IF;
		-- AAME 16072019 INI Se modifica calculo del CAT igual al de Portada de Apertura RQM 10 1253
        IF cCobrComisAnual = '1' THEN   -- Si el producto tiene cobro de comision por anualidad.
			SELECT monto INTO dMtoComAnualTit FROM bdicred:sd_tpcomis WHERE cod_comis = dClvComAnualTit;    -- Monto anualidad titular
			SELECT monto INTO dMtoComAnualAdi FROM bdicred:sd_tpcomis WHERE cod_comis = dClvComAnualAdi;    -- Monto anualidad adicional
			LET dMtoComAnualTit = nvl(dMtoComAnualTit,0);
			LET dMtoComAnualAdi = nvl(dMtoComAnualAdi,0);	
			
            IF cCat_adicional = '0' THEN LET dMtoComAnualAdi = 0; END IF; -- Si adicional no se agrega al CAT, se asigna valor cero.
            LET mMntoComAnual = dMtoComAnualTit + dMtoComAnualAdi;
		ELSE
			LET mMntoComAnual = 0;
		END IF;  				
		-- Para 6001 solo cobra apertura, para <> 6001 no cobra apertura, cobra anualidad
		LET dComisiones = dComisiones + mMntoComApert;		
        --LET dComisiones = NVL(mMntoComApert,0) + NVL(mMntoComAnual,0);

		--EXECUTE PROCEDURE bdicred:"informix".sp_calculo_tiir(V_MONTO,dPagoReq,36,36,50) 
        --EXECUTE PROCEDURE bdicred:"informix".sp_calculo_tiir(V_MONTO,dPagoReq,36,36, dComisiones) 
		EXECUTE PROCEDURE bdicred:"informix".sp_calculo_tiir(V_MONTO, dPagoReq, 36, 36, dComisiones, dComs_GastCob, mMntoComAnual, V_TASA_INTERES) 
		into cCodRet,cMensajeRet,vCatFinal;
		IF cCodRet::INTEGER =0 AND  vCatFinal <> 0 THEN
			LET V_CATIVA = vCatFinal;
		END IF;
		-- AAME 16072019 FIN Se modifica calculo del CAT igual al de Portada de Apertura RQM 10 1253	
		UPDATE bdisolic:ss_revision_determinacion SET cat = V_CATIVA 	WHERE empresa = P_EMPRESA 	AND num_solicitud = P_SOLICITUD;
	END IF;
	
	--***** ACTUALIZA SD_BITACORA_DISPEFEC RQM 10 1225
	IF vDispEfec  = '1' THEN
		SELECT b.grupo,b.evalua_cc  
		INTO  gpo,evalcc
		FROM  bdisolic:ss_revision_determinacion b 
		WHERE b.EMPRESA = P_EMPRESA
		AND   b.num_solicitud = P_SOLICITUD;
		
		IF gpo = '1' AND evalcc IN ('0','X')  THEN --A+ -> HIT / NO HIT
		   LET v_idi = '2';
		ELIF gpo <> '1' AND evalcc IN ('0')  THEN -- NO A+ -> HIT
		   LET v_idi = '2';
		ELIF gpo <> '1' AND nvl(evalcc,'X') = 'X' THEN-- NO A+ -> NO HIT
		   LET v_idi = '1';
		ELSE 
		   LET v_idi = '0';
		END IF;
		
		--INSERCION EN TABLA BITACORA DISPOSICION EN EFECTIVO
		INSERT INTO bdicred:sd_bitacora_dispefec
			(EMPRESA                ,NUM_CREDITO
			,FECHA_STATUS           ,IND_DISP_INI
			,IND_DISP_ACT           ,GRUPO
			,EVALUA_CC              ,FECHA_INSERT)
		VALUES(P_EMPRESA,P_SOLICITUD,null,v_idi,null,gpo,evalcc,TODAY);
			 
		--SE ACTUALIZA TABLA SD_MAECRED CON EL VALOR DEL PERIODO_POR_EVALUAR REUSANDO EL CAMPO DIFERIMIENTO_INT
		LET v_indde = v_idi::INTEGER;
		UPDATE bdicred:"informix".sd_maecred SET diferimiento_int = v_indde
		WHERE empresa = P_EMPRESA AND num_credito = p_solicitud;
        		
	END IF;
    ---------------------------- 
    RETURN P_ERROR,V_TASA_INTERES,V_TASA_MORA,V_CATIVA,V_MERCADEO;
END;
END PROCEDURE;