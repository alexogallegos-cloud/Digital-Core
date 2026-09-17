CREATE PROCEDURE "informix".sp_bit_ctes_rel (pNumCte CHAR(20), 
											 pNumCteRef CHAR (20), 
											 pNumCteRefCoinc CHAR (20), 
											 pSucursal CHAR(4),
											 pNumEmp CHAR(8))
RETURNING CHAR(5) AS CodRetorno;

--Definicion de Variables 
DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);


--Inicializacion de Variables
LET iSqlErr = 0;
LET cCodRet = '00000';

--SET DEBUG FILE TO '/tmp/sp_bit_ctes_rel.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	
	IF (pNumCte IS NULL OR pNumCte  = '') 
		OR (pSucursal IS NULL OR pSucursal= '') 
		OR (pNumEmp IS NULL OR pNumEmp = '') THEN
		LET cCodRet = '00001';
	ELSE
	
		INSERT INTO bdinteg:"informix".si_bitacora_ctes_rel  
		(numcte, numcte_ref, numcte_ref_coinc, sucursal, numemp,fecha_insert)
		VALUES( pNumCte, pNumCteRef, pNumCteRefCoinc, pSucursal, pNumEmp, CURRENT);
	END IF	
	RETURN cCodRet;
		
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION:Se crea procedimiento almacenado para llamar sp_bit_ctes_rel el cual guardarà una bitacora de las coincidencias para su posterior procesamiento. ',
'AUTOR : Leonardo Alfonso Plata Garcia',
'FECHA : 06/09/2013',
'VERSION:20130906 ',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_bit_comparaciones (pNumcte CHAR(20), 
											      pOrigen CHAR (1), 
												  pSucursal CHAR (4), 
												  pNum_huellas SMALLINT,
												  pNumEmp CHAR(8),
												  pStatus_alerta CHAR(1))
RETURNING CHAR(5) AS CodRetorno;

--Definicion de Variables
DEFINE iSqlErr INTEGER; 
DEFINE cCodRet CHAR(5);

--Inicializacion de Variables
LET iSqlErr = 0;
LET cCodRet = '00000';


--SET DEBUG FILE TO '/tmp/sp_bit_comparaciones.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	
	IF (pNumcte IS NULL OR pNumcte  = '') OR (pOrigen IS NULL OR pOrigen  = '')
		OR (pSucursal  IS NULL OR pSucursal  = '') OR (pNumEmp IS NULL OR pNumEmp = '') 
		OR (pNum_huellas IS NULL OR pNum_huellas = '') OR (pStatus_alerta IS NULL OR pStatus_alerta = '') THEN
		LET cCodRet = '00001';
	ELSE
	
		INSERT INTO bdinteg:"informix".si_bitacora_comparaciones  
		(numcte, origen, sucursal, numemp, Num_huellas, status_alerta,fecha_insert)
		VALUES( pNumcte, pOrigen, pSucursal, pNumEmp, pNum_huellas, pStatus_alerta, CURRENT);
	END IF	
	RETURN cCodRet;
		
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION:Se crea procedimiento almacenado para llamar sp_bit_comparaciones el cual guardarà una bitacora de las coincidencias para su posterior procesamiento. ',
'AUTOR : Leonardo Alfonso Plata Garcia',
'FECHA : 06/09/2013',
'VERSION: ',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_cnsif_edoctacred(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10), cNUMEROTARJETA CHAR(16),cNUMCUENTA CHAR(20), cTIPOBUSQUEDA CHAR(01),cPERIODO  CHAR(07))

			returning   CHAR(5)      		  AS Cod_Retorno,
						CHAR(150)             AS Nombre_cliente,
						CHAR(200)    		  AS Calle,
						CHAR(120)    		  AS Colonia,
						CHAR(120)    		  AS Del_Mpo,
						CHAR(120)    		  AS Ciudad,
						CHAR(05)     		  AS Codigo_Postal,
						CHAR(20)     		  AS Num_Credito,
						CHAR(13)     		  AS RFC_Cliente,
						CHAR(40)    		  AS Entre_Calles,
						CHAR(80)              AS Observaciones,
						CHAR(62)    		  AS CL_Cobra,
						CHAR(47)     		  AS Ruta,
						CHAR(20)     		  AS Numero_Cliente,
						CHAR(20)     		  AS Numero_Tarjeta,
						CHAR(120)     		  AS Sucursal_Nombre,
						CHAR(150)    		  AS Gerente,
						CHAR(15)              AS Telefono_Sucursal,
						DECIMAL(14,2)     	  AS Capital,
						DECIMAL(14,2)         AS Capital_Venc,
						DECIMAL(14,2)         AS Int_Venc,
						DECIMAL(14,2)         AS IVA_Int_Venc,
						DECIMAL(14,2)         AS Moratorios,
						DECIMAL(14,2)         AS IVA_Moratorios,
						DECIMAL(14,2)         AS Pago_Minimo,
						DECIMAL(14,2)         AS Pago_No_Gen_Interes,
						DECIMAL(14,2)         AS Limite_Credito,
						DECIMAL(14,2)         AS Credito_Dispon,
						DATE                  AS Periodo_Inicio,
						DATE                  AS Periodo_Fin,
						CHAR(10)              AS Fecha_Limite_Pago,
						DATE                  AS Fecha_Corte,
						CHAR(255)             AS Dias_Periodo,
						DECIMAL(14,2)         AS Intereses,
						DECIMAL(14,2)         AS IVA_Intereses,
						DECIMAL(14,2)         AS Usted_Debia,
						DECIMAL(14,2)         AS Menos_Abonos,
						DECIMAL(14,2)         AS Mas_Compras,
						DECIMAL(14,2)         AS Mas_Comisiones,
						DECIMAL(14,2)         AS Disp_Efectivo,
						DECIMAL(14,2)         AS Mas_Interes,
						DECIMAL(14,2)         AS Mas_IVA,
						DECIMAL(14,2)         AS Rendimientos,
						CHAR(20)              AS Numero_Cta_Cheques,
						DECIMAL(14,2)         AS Int_Efec_Cargados,
						DECIMAL(14,2)         AS Com_Por_Pagar,
						DECIMAL(14,2)         AS Interes,
						DECIMAL(14,2)         AS IVA,
						CHAR(09)              AS Numero_Pagos,
						DECIMAL(14,2)         AS Monto_Pago,
						DECIMAL(14,2)         AS Pago_Total,
						DECIMAL(14,2)         AS Monto_Credito,
						DATE                  AS Fecha_Otorgamiento,
						DECIMAL(14,2)         AS Saldo_Insoluto,
						DECIMAL(14,2)         AS Int_Efec_Pagados,
						DECIMAL(14,2)         AS Com_Efec_Cargadas,
						CHAR(09)              AS Tasa_Mensual,
						CHAR(09)              AS Tasa_Anual,
						DECIMAL(14,2)         AS Tasa_Mora,
						DECIMAL(14,2)         AS Tasa_Mensual_Mora,
						CHAR(08)              AS CAT,
						CHAR(20)              AS Saldo_Promedio;

DEFINE iexiste 			INT;
DEFINE cCodRet 		CHAR(5);
DEFINE iSql_err 		INT;
--VARIABLES
DEFINE cNombreCliente   	 CHAR(150);
DEFINE cCalle	       		 CHAR(200);
DEFINE cColonia	       		 CHAR(120);
DEFINE cDelMpo		   		 CHAR(120);
DEFINE cCiudad		   		 CHAR(120);
DEFINE cCodPostal      		 CHAR(05);
DEFINE cNumCredito     		 CHAR(20);
DEFINE cRFCCliente     		 CHAR(13);
DEFINE cEntreCalles	   		 CHAR(40);
DEFINE cObservaciones  		 CHAR(80);
DEFINE cCLCobra        		 CHAR(62);
DEFINE cRuta           		 CHAR(47);
DEFINE cNumCliente           CHAR(20);
DEFINE cNumTarjeta     		 CHAR(20);
DEFINE cSucursalNombre       CHAR(120);
DEFINE cGerente        		 CHAR(150);
DEFINE cTelSucursal          CHAR(15);

DEFINE decCapital      		 DECIMAL(14,2);
DEFINE decCapitalVenc  		 DECIMAL(14,2);
DEFINE decIntVenc      		 DECIMAL(14,2);
DEFINE decIVAIntVenc   		 DECIMAL(14,2);
DEFINE decMoratorios   		 DECIMAL(14,2);
DEFINE decIVAMoratorios      DECIMAL(14,2);
DEFINE decPagoMinimo         DECIMAL(14,2);
DEFINE decPagoNoGenInteres   DECIMAL(14,2);
DEFINE decLimiteCredito      DECIMAL(14,2);
DEFINE decCreditoDispon      DECIMAL(14,2);
DEFINE dPeriodoInicio        DATE;
DEFINE dPeriodoFin           DATE;
DEFINE cFechaLimitePago      CHAR(10);
DEFINE dFechaCorte           DATE;
DEFINE cDiasPeriodo          CHAR(255);
DEFINE decIntereses     	 DECIMAL(14,2);
DEFINE decIVAIntereses     	 DECIMAL(14,2);
DEFINE decUstedDebia  	 	 DECIMAL(14,2);
DEFINE decMenosAbonos 		 DECIMAL(14,2);
DEFINE decMasCompras    	 DECIMAL(14,2);
DEFINE decMasComisiones      DECIMAL(14,2);
DEFINE decDispEfectivo     	 DECIMAL(14,2);
DEFINE decMasInteres     	 DECIMAL(14,2);
DEFINE decMasIVA  	     	 DECIMAL(14,2);
DEFINE decRendimientos     	 DECIMAL(14,2);
DEFINE cNumeroCtaCheques   	 CHAR(20);
DEFINE decIntEfecCargados    DECIMAL(14,2);
DEFINE decComPorPagar        DECIMAL(14,2);
DEFINE decInteres          	 DECIMAL(14,2);
DEFINE decIVA	          	 DECIMAL(14,2);
DEFINE cNumeroPagos   	     CHAR(09);
DEFINE decMontoPago        	 DECIMAL(14,2);
DEFINE decPagoTotal        	 DECIMAL(14,2);
DEFINE decMontoCredito     	 DECIMAL(14,2);
DEFINE dFechaOtorgamiento    DATE;
DEFINE decSaldoInsoluto    	 DECIMAL(14,2);
DEFINE decIntEfecPagados 	 DECIMAL(14,2);
DEFINE decComEfecCargadas  	 DECIMAL(14,2);
DEFINE cTasaMensual   	     CHAR(09);
DEFINE cTasaAnual   	     CHAR(09);
DEFINE decTasaMora		 	 DECIMAL(14,2);
DEFINE decTasaMensualMora  	 DECIMAL(14,2);
DEFINE cCAT			   	     CHAR(08);
DEFINE cSaldoPromedio  	     CHAR(20);


DEFINE cTipoEdoCta           CHAR(02);
DEFINE dFechaPeriodo         DATE;

-- VARIABLES STORE sp_reporte_edocuenta
DEFINE vCodRet               CHAR(05);
DEFINE iTipoReporte          INTEGER;

--VARIABLES STORE ...
DEFINE cMensaje             CHAR(80);
DEFINE cPeriodoAux          DATE;

--INICIALIZA VARIABLES
LET  iexiste 		    = 0;
LET cCodRet 	        = "00000";
LET iSql_err 			= 0 ;

LET cNombreCliente       = "";
LET cCalle 				 = "";
LET cColonia		  	 = "";
LET cDelMpo			     = '';
LET cCiudad		         = 0;
LET cCodPostal       	 = "";
LET cNumCredito  		 = "";
LET cRFCCliente       	 = "";
LET cEntreCalles	     = "";
LET cObservaciones  	 = '';
LET cCLCobra             = '';
LET cRuta           	 = '';
LET cNumCliente          = '';
LET cNumTarjeta     	 = '';
LET cSucursalNombre       	 = '';
LET cGerente        	 = '';
LET cTelSucursal         = '';
LET decCapital      	 = 0;
LET decCapitalVenc  	 = 0;
LET decIntVenc      	 = 0;
LET decIVAIntVenc   	 = 0;
LET decMoratorios   	 = 0;
LET decIVAMoratorios     = 0;
LET decPagoMinimo        = 0;
LET decPagoNoGenInteres  = 0;
LET decLimiteCredito     = 0;
LET decCreditoDispon     = 0;
LET dPeriodoInicio       = 0;
LET dPeriodoFin          = '';
LET cFechaLimitePago     = '';
LET dFechaCorte          = '';
LET cDiasPeriodo      	 = 0;
LET decIntereses     	 = 0;
LET decIVAIntereses      = 0;
LET decUstedDebia        = 0;
LET decMenosAbonos 		 = 0;
LET decMasCompras   	 = 0;
LET decMasComisiones     = 0;
LET decDispEfectivo      = 0;
LET decMasInteres     	 = 0;
LET decMasIVA  	     	 = 0;
LET decRendimientos      = 0;
LET cNumeroCtaCheques    = '';
LET decIntEfecCargados   = 0;
LET decComPorPagar       = 0;
LET decInteres           = 0;
LET decIVA	          	 = 0;
LET cNumeroPagos   	     = '';
LET decMontoPago         = 0;
LET decPagoTotal         = 0;
LET decMontoCredito      = 0;
LET dFechaOtorgamiento   = '';
LET decSaldoInsoluto     = 0;
LET decIntEfecPagados 	 = 0;
LET decComEfecCargadas   = 0;
LET cTasaMensual   	     = '';
LET cTasaAnual   	     = '';
LET decTasaMora		 	 = 0;
LET decTasaMensualMora   = 0;
LET cCAT			   	 = '';
LET cSaldoPromedio  	 = '';

LET cTipoEdoCta          = '';
LET dFechaPeriodo        = '';

LET vCodRet             = '';
LET iTipoReporte        = '0';

LET cMensaje           = '';
LET cPeriodoAux        = '';


BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN  cCodRet,cNombreCliente,cCalle,cColonia,cDelMpo,cCiudad,cCodPostal,cNumCredito,cRFCCliente,cEntreCalles,cObservaciones,cCLCobra,     		--12
					cRuta,cNumCliente,cNumTarjeta,cSucursalNombre,cGerente,cTelSucursal,decCapital,decCapitalVenc,decIntVenc,decIVAIntVenc,decMoratorios,   	        		--10
					decIVAMoratorios,decPagoMinimo,decPagoNoGenInteres,decLimiteCredito,decCreditoDispon,dPeriodoInicio,dPeriodoFin,cFechaLimitePago,   		--08
					dFechaCorte,cDiasPeriodo,decIntereses,decIVAIntereses,decUstedDebia,decMenosAbonos,decMasCompras,decMasComisiones,decDispEfectivo,  		--09
					decMasInteres,decMasIVA,decRendimientos,cNumeroCtaCheques,decIntEfecCargados,decComPorPagar,decInteres,decIVA,cNumeroPagos,decMontoPago,    --10
					decPagoTotal,decMontoCredito,dFechaOtorgamiento,decSaldoInsoluto,decIntEfecPagados,decComEfecCargadas,cTasaMensual,cTasaAnual,decTasaMora,  --09
					decTasaMensualMora,cCAT,cSaldoPromedio;																										--03
																																								--62
		END IF;
	END EXCEPTION;

		      --SET DEBUG FILE TO "/informix/VH/cnsif/sp_cnsif_edoctacred.out";
		      --TRACE ON;

	IF 	cID_USUARIOC 	 = "" 	OR
		cID_FUNCIONC 	 = "" 	OR
		cTIPOBUSQUEDA    = ""   OR
		cPERIODO    	 = ""   THEN
		LET cCodRet = "00045";
		RETURN  cCodRet,cNombreCliente,cCalle, cColonia, cDelMpo,cCiudad,cCodPostal,cNumCredito,cRFCCliente,cEntreCalles,cObservaciones,cCLCobra,
				cRuta, cNumCliente, cNumTarjeta, cSucursalNombre,cGerente,cTelSucursal,decCapital,decCapitalVenc,decIntVenc,decIVAIntVenc,decMoratorios,
				decIVAMoratorios,decPagoMinimo,decPagoNoGenInteres,decLimiteCredito,decCreditoDispon,dPeriodoInicio,dPeriodoFin,cFechaLimitePago,
				dFechaCorte,cDiasPeriodo,decIntereses,decIVAIntereses,decUstedDebia,decMenosAbonos,decMasCompras,decMasComisiones,decDispEfectivo,
				decMasInteres,decMasIVA,decRendimientos,cNumeroCtaCheques,decIntEfecCargados,decComPorPagar,decInteres,decIVA,cNumeroPagos,decMontoPago,
				decPagoTotal,decMontoCredito,dFechaOtorgamiento,decSaldoInsoluto,decIntEfecPagados,decComEfecCargadas,cTasaMensual,cTasaAnual,decTasaMora,
				decTasaMensualMora,cCAT,cSaldoPromedio;
	END IF;

	--VALIDACION
	IF cTIPOBUSQUEDA = 'T' THEN
		EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMEROTARJETA,'06','3')
		INTO
		cCodRet;
	ELSE
		EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'06','1')
		INTO
		cCodRet;
	END IF;

	IF (cCodRet != '00000')  THEN
	RETURN  cCodRet,cNombreCliente,cCalle,cColonia,cDelMpo,cCiudad,cCodPostal,cNumCredito,cRFCCliente,cEntreCalles,cObservaciones,cCLCobra,     		--12
			cRuta,cNumCliente,cNumTarjeta,cSucursalNombre,cGerente,cTelSucursal,decCapital,decCapitalVenc,decIntVenc,decIVAIntVenc,decMoratorios,   	        		--10
			decIVAMoratorios,decPagoMinimo,decPagoNoGenInteres,decLimiteCredito,decCreditoDispon,dPeriodoInicio,dPeriodoFin,cFechaLimitePago,   		--08
			dFechaCorte,cDiasPeriodo,decIntereses,decIVAIntereses,decUstedDebia,decMenosAbonos,decMasCompras,decMasComisiones,decDispEfectivo,  		--09
			decMasInteres,decMasIVA,decRendimientos,cNumeroCtaCheques,decIntEfecCargados,decComPorPagar,decInteres,decIVA,cNumeroPagos,decMontoPago,    --10
			decPagoTotal,decMontoCredito,dFechaOtorgamiento,decSaldoInsoluto,decIntEfecPagados,decComEfecCargadas,cTasaMensual,cTasaAnual,decTasaMora,  --09
			decTasaMensualMora,cCAT,cSaldoPromedio;
	END IF;
	-- TERMINA VALIDACION

	IF cTIPOBUSQUEDA = 'T' THEN
		SELECT LIMIT 1 num_credito
		INTO cNUMCUENTA
		FROM bdicred@pld_tcp:sd_encabezado_edocta
		WHERE  num_tarjeta = cNUMEROTARJETA;

    ELSE
    	SELECT LIMIT 1 num_tarjeta
        INTO cNUMEROTARJETA
		FROM bdicred:sd_tarjeta
		WHERE num_credito = cNUMCUENTA;
	END IF;


	LET  cTipoEdoCta = SUBSTR(cNUMCUENTA,1,2);

	IF   cTipoEdoCta = '60' THEN  --CREDITO
		--PARA 60
		SELECT NVL(COUNT(num_credito),0) into iexiste FROM bdicred:sd_maecred WHERE num_credito = cNUMCUENTA ;
		IF iexiste  = 0 THEN
		LET cCodRet = "00046";
		RETURN  cCodRet,cNombreCliente,cCalle, cColonia, cDelMpo,cCiudad,cCodPostal,cNumCredito,cRFCCliente,cEntreCalles,cObservaciones,cCLCobra,
				cRuta, cNumCliente, cNumTarjeta, cSucursalNombre,cGerente,cTelSucursal,decCapital,decCapitalVenc,decIntVenc,decIVAIntVenc,decMoratorios,
				decIVAMoratorios,decPagoMinimo,decPagoNoGenInteres,decLimiteCredito,decCreditoDispon,dPeriodoInicio,dPeriodoFin,cFechaLimitePago,
				dFechaCorte,cDiasPeriodo,decIntereses,decIVAIntereses,decUstedDebia,decMenosAbonos,decMasCompras,decMasComisiones,decDispEfectivo,
				decMasInteres,decMasIVA,decRendimientos,cNumeroCtaCheques,decIntEfecCargados,decComPorPagar,decInteres,decIVA,cNumeroPagos,decMontoPago,
				decPagoTotal,decMontoCredito,dFechaOtorgamiento,decSaldoInsoluto,decIntEfecPagados,decComEfecCargadas,cTasaMensual,cTasaAnual,decTasaMora,
				decTasaMensualMora,cCAT,cSaldoPromedio;
		END IF;
	ELIF cTipoEdoCta <> '60'   THEN 
		SELECT NVL(COUNT(num_credito),0) into iexiste FROM bdicred:sd_maecredcrd WHERE num_credito  = cNUMCUENTA;
		IF iexiste  = 0 THEN
		LET cCodRet = "00046";
		RETURN  cCodRet,cNombreCliente,cCalle, cColonia, cDelMpo,cCiudad,cCodPostal,cNumCredito,cRFCCliente,cEntreCalles,cObservaciones,cCLCobra,
				cRuta, cNumCliente, cNumTarjeta, cSucursalNombre,cGerente,cTelSucursal,decCapital,decCapitalVenc,decIntVenc,decIVAIntVenc,decMoratorios,
				decIVAMoratorios,decPagoMinimo,decPagoNoGenInteres,decLimiteCredito,decCreditoDispon,dPeriodoInicio,dPeriodoFin,cFechaLimitePago,
				dFechaCorte,cDiasPeriodo,decIntereses,decIVAIntereses,decUstedDebia,decMenosAbonos,decMasCompras,decMasComisiones,decDispEfectivo,
				decMasInteres,decMasIVA,decRendimientos,cNumeroCtaCheques,decIntEfecCargados,decComPorPagar,decInteres,decIVA,cNumeroPagos,decMontoPago,
				decPagoTotal,decMontoCredito,dFechaOtorgamiento,decSaldoInsoluto,decIntEfecPagados,decComEfecCargadas,cTasaMensual,cTasaAnual,decTasaMora,
				decTasaMensualMora,cCAT,cSaldoPromedio;
		END IF;
	END IF

	IF   cTipoEdoCta = '60' THEN  --CREDITO
		--PARA FORMAR EL PERIODO SE AGREGA DIA 20 AL MES Y AÑO
		--LET dFechaPeriodo = EXTEND(MDY(SUBSTR(cPERIODO,6,2),20,SUBSTR(cPERIODO,1,4)), YEAR TO SECOND);
		LET dFechaPeriodo = EXTEND(MDY(SUBSTR(cPERIODO,5,2),20,SUBSTR(cPERIODO,1,4)), YEAR TO SECOND);

        IF EXISTS(SELECT {+INDEX(sd_encabezado_edocta idx_encabezado_edocta1)} fecha_emision FROM bdicred@pld_tcp:sd_encabezado_edocta WHERE fecha_emision = dFechaPeriodo AND num_credito = cNUMCUENTA) THEN
 
        ELSE
            LET cCodRet = "00051";
            RETURN  cCodRet,cNombreCliente,cCalle, cColonia, cDelMpo,cCiudad,cCodPostal,cNumCredito,cRFCCliente,cEntreCalles,cObservaciones,cCLCobra,
                    cRuta, cNumCliente, cNumTarjeta, cSucursalNombre,cGerente,cTelSucursal,decCapital,decCapitalVenc,decIntVenc,decIVAIntVenc,decMoratorios,
                    decIVAMoratorios,decPagoMinimo,decPagoNoGenInteres,decLimiteCredito,decCreditoDispon,dPeriodoInicio,dPeriodoFin,cFechaLimitePago,
                    dFechaCorte,cDiasPeriodo,decIntereses,decIVAIntereses,decUstedDebia,decMenosAbonos,decMasCompras,decMasComisiones,decDispEfectivo,
                    decMasInteres,decMasIVA,decRendimientos,cNumeroCtaCheques,decIntEfecCargados,decComPorPagar,decInteres,decIVA,cNumeroPagos,decMontoPago,
                    decPagoTotal,decMontoCredito,dFechaOtorgamiento,decSaldoInsoluto,decIntEfecPagados,decComEfecCargadas,cTasaMensual,cTasaAnual,decTasaMora,
                    decTasaMensualMora,cCAT,cSaldoPromedio;
        END IF; 

		SELECT nombre_cte,direccion_cn,direccion_col,direccion_del,edo_cd,cp,num_credito,rfc,entre_calles,observaciones,cl_cobra,
		ruta,numcte,num_tarjeta,sucursal_nombre,sucursal_gerente,sucursal_tel
		INTO
		cNombreCliente,cCalle,cColonia,cDelMpo,cCiudad,cCodPostal,cNumCredito,cRFCCliente,cEntreCalles,cObservaciones, cCLCobra,
		cRuta,cNumCliente,cNumTarjeta, cSucursalNombre, cGerente,cTelSucursal
		FROM bdicred@pld_tcp:sd_encabezado_edocta
		WHERE num_credito = cNUMCUENTA
		AND fecha_emision = dFechaPeriodo;

		SELECT capital_tc,capital_ven_tc,interes_ven_tc ,iva_interes_ven_tc,moratorios_tc,iva_moratorios_tc,sdo_pagar,interes_pago_total_tc,
		limite_tc,sdo_disponible,periodo_tc_ini,periodo_tc_fin,CASE WHEN pago_antes_de = EXTEND(MDY(1,1,1900), YEAR TO SECOND)  THEN 'INMEDIATO' ELSE TO_CHAR(pago_antes_de,'%d/%m/%Y') END,fecha_corte,dias_periodo_tc, interes_tc ,iva_interes_tc,usted_debia,
		menos_abonos,mas_compras,sus_comisiones,mas_disp_efectivo,mas_intereses,mas_iva ,mas_rendimientos,intereses_pag,sus_comisiones
		INTO
		decCapital,decCapitalVenc,decIntVenc,decIVAIntVenc,decMoratorios,decIVAMoratorios,decPagoMinimo,decPagoNoGenInteres,
		decLimiteCredito,decCreditoDispon,dPeriodoInicio,dPeriodoFin,cFechaLimitePago,dFechaCorte,cDiasPeriodo,decIntereses,decIVAIntereses,decUstedDebia,
		decMenosAbonos,decMasCompras,decMasComisiones,decDispEfectivo,decMasInteres,decMasIVA,decRendimientos,decIntEfecCargados,decComPorPagar
		FROM bdicred@pld_tcp:sd_encabezado2_edocta
		WHERE num_credito = cNUMCUENTA
		AND fecha_emision = dFechaPeriodo;

		SELECT tasa_mensual,tasa_anual,tasa_mora,tasa_mensual_mora,cat,saldo_promedio
		INTO
		cTasaMensual,cTasaAnual,decTasaMora,decTasaMensualMora,cCAT,cSaldoPromedio
		FROM bdicred@pld_tcp:sd_pie_edocta
		WHERE num_credito = cNUMCUENTA
		AND fecha_emision = dFechaPeriodo;

		RETURN  cCodRet,cNombreCliente,cCalle, cColonia, cDelMpo,cCiudad,cCodPostal,cNumCredito,cRFCCliente,cEntreCalles,cObservaciones,cCLCobra,
				cRuta, cNumCliente, cNumTarjeta, cSucursalNombre,cGerente,cTelSucursal,decCapital,decCapitalVenc,decIntVenc,decIVAIntVenc,decMoratorios,
				decIVAMoratorios,decPagoMinimo,decPagoNoGenInteres,decLimiteCredito,decCreditoDispon,dPeriodoInicio,dPeriodoFin,cFechaLimitePago,
				dFechaCorte,cDiasPeriodo,decIntereses,decIVAIntereses,decUstedDebia,decMenosAbonos,decMasCompras,decMasComisiones,decDispEfectivo,
				decMasInteres,decMasIVA,decRendimientos,cNumeroCtaCheques,decIntEfecCargados,decComPorPagar,decInteres,decIVA,cNumeroPagos,decMontoPago,
				decPagoTotal,decMontoCredito,dFechaOtorgamiento,decSaldoInsoluto,decIntEfecPagados,decComEfecCargadas,cTasaMensual,cTasaAnual,decTasaMora,
				decTasaMensualMora,cCAT,cSaldoPromedio;

	ELIF cTipoEdoCta <> '60'   THEN  
		FOREACH
			EXECUTE PROCEDURE bdicred:obtenPeriodos_edocuentacrd (cNUMCUENTA)
			INTO
			cCodRet,cMensaje,cPeriodoAux
		END FOREACH;

		--LET dFechaPeriodo = EXTEND(MDY(SUBSTR(cPERIODO,6,2),DAY(cPeriodoAux),SUBSTR(cPERIODO,1,4)), YEAR TO SECOND);
        LET dFechaPeriodo = EXTEND(MDY(SUBSTR(cPERIODO,5,2),DAY(cPeriodoAux),SUBSTR(cPERIODO,1,4)), YEAR TO SECOND);

        SELECT NVL(COUNT(fecha_emision),0) into iexiste FROM bdicred:sd_encabezado_edoctacrd WHERE num_credito = cNUMCUENTA AND fecha_emision = dFechaPeriodo;
        IF iexiste  = 0 THEN
            LET cCodRet = "00051";
            RETURN  cCodRet,cNombreCliente,cCalle, cColonia, cDelMpo,cCiudad,cCodPostal,cNumCredito,cRFCCliente,cEntreCalles,cObservaciones,cCLCobra,
                    cRuta, cNumCliente, cNumTarjeta, cSucursalNombre,cGerente,cTelSucursal,decCapital,decCapitalVenc,decIntVenc,decIVAIntVenc,decMoratorios,
                    decIVAMoratorios,decPagoMinimo,decPagoNoGenInteres,decLimiteCredito,decCreditoDispon,dPeriodoInicio,dPeriodoFin,cFechaLimitePago,
                    dFechaCorte,cDiasPeriodo,decIntereses,decIVAIntereses,decUstedDebia,decMenosAbonos,decMasCompras,decMasComisiones,decDispEfectivo,
                    decMasInteres,decMasIVA,decRendimientos,cNumeroCtaCheques,decIntEfecCargados,decComPorPagar,decInteres,decIVA,cNumeroPagos,decMontoPago,
                    decPagoTotal,decMontoCredito,dFechaOtorgamiento,decSaldoInsoluto,decIntEfecPagados,decComEfecCargadas,cTasaMensual,cTasaAnual,decTasaMora,
                    decTasaMensualMora,cCAT,cSaldoPromedio;
        END IF;

		SELECT FIRST 1 nombre_cte,direccion_cn,direccion_col,direccion_del,edo_cd,cp,num_credito,rfc,entre_calles,observaciones,'R ' || cl_cobra,
			   ruta,numcte,sucursal_nombre,sucursal_gerente,sucursal_tel,num_cta_efec
		INTO
		cNombreCliente,cCalle,cColonia,cDelMpo,cCiudad,cCodPostal,cNumCredito,cRFCCliente,cEntreCalles,cObservaciones, cCLCobra,
		cRuta,cNumCliente,cSucursalNombre, cGerente,cTelSucursal,cNumeroCtaCheques
		FROM bdicred:sd_encabezado_edoctacrd  --- la busqueda num credito y fecha_emision
		WHERE num_credito = cNUMCUENTA
		AND fecha_emision = dFechaPeriodo;

		SELECT FIRST 1 capital_tc,capital_ven_tc,interes_ven_tc ,iva_interes_ven_tc,moratorios_tc,iva_moratorios_tc,
		periodo_tc_ini,periodo_tc_fin,CASE WHEN fecha_limite_tc = EXTEND(MDY(1,1,1900), YEAR TO SECOND)  THEN 'INMEDIATO' ELSE TO_CHAR(fecha_limite_tc,'%d/%m/%Y') END,fecha_corte_tc,dias_periodo_tc,
		interes_tc ,iva_interes_tc,intereses_efec_pag,comisiones_efec_cargadas,
		numero_pago_tc,monto_pago,pago_total_tc,monto_credito_tc,fecha_otorgamiento_tc
		INTO
		decCapital,decCapitalVenc,decIntVenc,decIVAIntVenc,decMoratorios,decIVAMoratorios,
		dPeriodoInicio,dPeriodoFin,cFechaLimitePago,dFechaCorte,cDiasPeriodo,
		decIntereses,decIVAIntereses,decIntEfecCargados,decComPorPagar,
		cNumeroPagos,decMontoPago,decPagoTotal,decMontoCredito,dFechaOtorgamiento
		FROM bdicred:sd_encabezado2_edoctacrd
		WHERE num_credito = cNUMCUENTA
		AND fecha_emision = dFechaPeriodo;

		SELECT FIRST 1 tasa_mensual,tasa_anual,tasa_mora_anual,tasa_mora_mensual,cat,saldo_insoluto
		INTO
		cTasaMensual,cTasaAnual,decTasaMora,decTasaMensualMora,cCAT,decSaldoInsoluto
		FROM bdicred:sd_pie_edoctacrd
		WHERE num_credito = cNUMCUENTA
		AND fecha_emision = dFechaPeriodo;

		RETURN  cCodRet,cNombreCliente,cCalle, cColonia, cDelMpo,cCiudad,cCodPostal,cNumCredito,cRFCCliente,cEntreCalles,cObservaciones,cCLCobra,
					cRuta, cNumCliente, cNumTarjeta, cSucursalNombre,cGerente,cTelSucursal,decCapital,decCapitalVenc,decIntVenc,decIVAIntVenc,decMoratorios,
					decIVAMoratorios,decPagoMinimo,decPagoNoGenInteres,decLimiteCredito,decCreditoDispon,dPeriodoInicio,dPeriodoFin,cFechaLimitePago,
					dFechaCorte,cDiasPeriodo,decIntereses,decIVAIntereses,decUstedDebia,decMenosAbonos,decMasCompras,decMasComisiones,decDispEfectivo,
					decMasInteres,decMasIVA,decRendimientos,cNumeroCtaCheques,decIntEfecCargados,decComPorPagar,decInteres,decIVA,cNumeroPagos,decMontoPago,
					decPagoTotal,decMontoCredito,dFechaOtorgamiento,decSaldoInsoluto,decIntEfecPagados,decComEfecCargadas,cTasaMensual,cTasaAnual,decTasaMora,
					decTasaMensualMora,cCAT,cSaldoPromedio;

	END IF
END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la información necesaria para el Reporte del Estado de Cuenta. ",
"El SP obtendrá la información de la Base de Datos central de Informix, enviando como parámetro el   No. de Cuenta.",
"FECHA : 26-03-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_historico_fusion_aut(pDia CHAR(2), pMes CHAR(2), pAnio CHAR(4), pDiaHasta CHAR(2), pMesHasta CHAR(2), pAnioHasta CHAR(4), pOpcion CHAR(1), pUsuarioAnalista CHAR(8))

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5) 						AS cCodRet,						
	CHAR(20) 						AS Numero_del_cliente_titular,
	CHAR (110) 						AS Nombre_completo_del_cliente_titular,
	CHAR(10) 						AS Fecha_de_nacimiento_del_cliente_titular,
	CHAR(20) 						AS Numero_del_cliente_traspasado,
	CHAR (110) 						AS Nombre_completo_del_cliente_traspasado,
	CHAR(10) 						AS Fecha_de_nacimiento_del_cliente_traspasado,
	CHAR(20) 						AS Numero_de_cuenta_del_cliente_traspasado,
	CHAR(4) 						AS Producto,
	CHAR(20) 						AS Numero_de_Cliente,
	CHAR(2) 						AS Estatus,
	MONEY(16,2) 					AS Saldo,
	CHAR(40) 						AS Descripcion,
	CHAR(10) 						AS Fecha_de_Alta,
	INTEGER 							AS Numero_de_direcciones_fusionadas,
	DATETIME YEAR TO SECOND 		AS Fecha_de_Fusion,
	DATETIME HOUR TO FRACTION(3) 	AS Hora_de_Fusion,
	CHAR(10) 						AS Status_Cuenta,
	CHAR(45) 						AS Nombre_de_Analista;
	
	--DEFINICION DE VARIABLES--
	DEFINE iSql_err 		INTEGER;
	DEFINE cCodRet 			CHAR(5);
	DEFINE cNumCteTit 		CHAR(20);
	DEFINE cNumCteTrasp 	CHAR(20);
	DEFINE cApePaterTit 	CHAR(26);
	DEFINE cApeMaterTit 	CHAR(26);
	DEFINE cNom1Tit 		CHAR(26);
	DEFINE cNom2Tit 		CHAR(26);
	DEFINE cFechaNacTit 	CHAR(10);
	DEFINE cApePaterTrasp	CHAR(26);
	DEFINE cApeMaterTrasp	CHAR(26);
	DEFINE cNom1Trasp 		CHAR(26);
	DEFINE cNom2Trasp 		CHAR(26);
	DEFINE cFechaNacTrasp 	CHAR(10);
	DEFINE cNomCompTitular 	CHAR (110);
	DEFINE cNomCompTransp 	CHAR (110);
	
	DEFINE cCta 			CHAR(20);
	DEFINE cProducto 		CHAR(4);
	DEFINE cNumCte 			CHAR(20);
	DEFINE cStatus 			CHAR(2);
	DEFINE vSaldo 			MONEY(16,2);
	DEFINE cDescripcion 	CHAR(40);
	DEFINE cFechaAlta 		CHAR(10);
	DEFINE iDirecciones 	CHAR(5);
	DEFINE dHoraFecha       DATETIME YEAR TO FRACTION(3);
	DEFINE cNumCteTrasp2	CHAR(20);
    DEFINE iBandera         SMALLINT;
    DEFINE iBandera1        SMALLINT;
    DEFINE iBandera2        SMALLINT;
    DEFINE iBandera3        SMALLINT;
	DEFINE Iconsecutivo     INTEGER;
	DEFINE iConteo			INTEGER;	
	DEFINE cTitular 		CHAR(20);
	DEFINE cTraspasar 	    CHAR(20);
	DEFINE iExiste			INTEGER;
	DEFINE dHora  			DATETIME HOUR TO FRACTION(3);
	DEFINE cUnidadp 	    CHAR(20);
	DEFINE cStatusCuenta    CHAR(10);
	DEFINE cExiste          CHAR(1);
	DEFINE cUser_insert     CHAR(10);
	DEFINE cNombreAnalista  CHAR(45);
	DEFINE dValidaFecha		DATE;					
	DEFINE cValidaNumCte	CHAR(20);				
	DEFINE iNumRows			INTEGER;				
	DEFINE cUsuParam		CHAR(8);
	
	--INICIALIZACION DE VARIABLES--
	LET iSql_err 		= 0;
	LET cCodRet 		= '00000';
	LET cNumCteTit 		= '';
	LET cNumCteTrasp 	= '';
	LET cApePaterTit 	= '';
	LET cApeMaterTit 	= '';
	LET cNom1Tit 		= '';
	LET cNom2Tit 		= '';
	LET cFechaNacTit 	= '';
	LET cApePaterTrasp 	= '';
	LET cApeMaterTrasp 	= '';
	LET cNom1Trasp 		= '';
	LET cNom2Trasp 		= '';
	LET cFechaNacTrasp 	= '';
	LET cNomCompTitular = '';
	LET cNomCompTransp 	= '';
		
	LET cCta 			= '';
	LET cProducto 		= '';
	LET cNumCte 		= '';
	LET cStatus 		= '';
	LET vSaldo 			= 0;
	LET cDescripcion 	= '';
	LET cFechaAlta 		= '';
	LET iDirecciones 	= '';
	LET dHoraFecha 		= CURRENT;
	LET cNumCteTrasp2 	= '';
    LET iBandera		= 0;
    LET iBandera1		= 0;
    LET iBandera2		= 0;
    LET iBandera3		= 0;
	LET Iconsecutivo	= 0;
	LET iConteo			= 0;
	LET cTitular		= '';
	LET cTraspasar		= '';
	LET iExiste			= 0;
	LET dHora 			= '';
	LET cUnidadp 		= '';
	LET cStatusCuenta 	= '';
	LET cExiste 		= '0';
	LET cUser_insert 	= '';
	LET cNombreAnalista = '';
	LET dValidaFecha 	= '';							
	LET cValidaNumCte	= '';							
	LET iNumRows		= 0;	
	LET cUsuParam		= '';
	
	--SET DEBUG FILE TO '/home/tmp/oscar/sp_historico_fusion_aut.out';
	--TRACE ON;
	
	BEGIN
	
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
				RETURN  cCodRet,cNumCteTit,cNomCompTitular,cFechaNacTit,cNumCteTrasp,cNomCompTransp,cFechaNacTrasp, cCta,cProducto,cNumCte,cStatus,vSaldo,cDescripcion,cFechaAlta,iDirecciones,dHoraFecha,dHora,cStatusCuenta,cNombreAnalista;
			END IF;	
		END EXCEPTION;

		TRUNCATE TABLE bdinteg:"informix".si_fusreporteaut;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT valor 
		INTO cUsuParam
		FROM bdinteg:"informix".si_param 
		WHERE empresa = '001'
		AND cod_param ='184';
		
		
		IF pOpcion = 1 THEN																			
			SELECT FIRST 1 {+INDEX (bdinteg:"informix".log_fusionclientes idxfeclogfu)} fecha_insert INTO dValidaFecha
			FROM bdinteg:"informix".log_fusionclientes
			WHERE fecha_insert = MDY(pMes,pDia,pAnio) 
			AND user_insert = TRIM(cUsuParam);
			LET iNumRows = dbinfo("sqlca.sqlerrd2");
			IF(iNumRows > 0) THEN																	
				LET cExiste = "1";

				FOREACH
					SELECT {+INDEX (bdinteg:"informix".log_fusionclientes idxfeclogfu)} DISTINCT TRIM(cliente_tit), TRIM(cliente_tras),fecha_hora
					INTO cNumCteTit, cNumCteTrasp, dHoraFecha
					FROM bdinteg:"informix".log_fusionclientes 
					WHERE fecha_insert = MDY(pMes,pDia,pAnio)
					AND user_insert = TRIM(cUsuParam)
					ORDER BY fecha_hora

					IF iConteo=0 THEN
						LET cTitular= TRIM(cNumCteTit);
						LET cTraspasar= TRIM(cNumCteTrasp);
						LET Iconsecutivo= Iconsecutivo + 1;
						SELECT NVL(COUNT(*),0) INTO iExiste FROM bdinteg:"informix".si_fusreporteaut WHERE cliente_tit= cNumCteTit AND cliente_tras= cNumCteTrasp;
						IF iExiste=0 THEN
							INSERT INTO bdinteg:"informix".si_fusreporteaut (cliente_tit,cliente_tras ,id_rep) VALUES (cNumCteTit,cNumCteTrasp,Iconsecutivo);
						END IF;
					ELSE
						IF TRIM(cTitular)=TRIM(cNumCteTit) AND TRIM(cTraspasar)=TRIM(cNumCteTrasp) THEN
						
						ELSE
							LET Iconsecutivo= Iconsecutivo + 1;
							SELECT NVL(COUNT(*),0) INTO iExiste FROM bdinteg:"informix".si_fusreporteaut WHERE cliente_tit= cNumCteTit AND cliente_tras= cNumCteTrasp;
							IF iExiste=0 THEN
								INSERT INTO bdinteg:"informix".si_fusreporteaut (cliente_tit,cliente_tras ,id_rep) VALUES (cNumCteTit,cNumCteTrasp,Iconsecutivo);
							END IF;
							LET cTitular= cNumCteTit;
							LET cTraspasar= cNumCteTrasp;
						END IF;	
					END IF;
					LET iConteo= iConteo + 1;
				END FOREACH;
			END IF;
		ELSE
			SELECT FIRST 1 {+INDEX (bdinteg:"informix".log_fusionclientes idxfeclogfu)} fecha_insert INTO dValidaFecha	
			FROM bdinteg:"informix".log_fusionclientes
			WHERE fecha_insert >= MDY(pMes,pDia,pAnio) AND fecha_insert <= MDY(pMesHasta,pDiaHasta,pAnioHasta) AND user_insert = TRIM(cUsuParam);
			LET iNumRows = dbinfo("sqlca.sqlerrd2");
			IF(iNumRows > 0) THEN									
				LET cExiste = "1";																						
			
				FOREACH
					SELECT {+INDEX (bdinteg:"informix".log_fusionclientes idxfeclogfu)} DISTINCT TRIM(cliente_tit), TRIM(cliente_tras),fecha_hora
					INTO cNumCteTit, cNumCteTrasp, dHoraFecha
					FROM bdinteg:"informix".log_fusionclientes 
					WHERE fecha_insert >= MDY(pMes,pDia,pAnio)
					AND fecha_insert <= MDY(pMesHasta,pDiaHasta,pAnioHasta)
					AND user_insert = TRIM(cUsuParam)
					ORDER BY fecha_hora

					IF iConteo=0 THEN
						LET cTitular= TRIM(cNumCteTit);
						LET cTraspasar= TRIM(cNumCteTrasp);
						LET Iconsecutivo= Iconsecutivo + 1;
						SELECT NVL(COUNT(*),0) INTO iExiste FROM bdinteg:"informix".si_fusreporteaut WHERE cliente_tit= cNumCteTit AND cliente_tras= cNumCteTrasp;
						IF iExiste=0 THEN
							INSERT INTO bdinteg:"informix".si_fusreporteaut (cliente_tit,cliente_tras ,id_rep) VALUES (cNumCteTit,cNumCteTrasp,Iconsecutivo);
						END IF;
					ELSE
						IF TRIM(cTitular)=TRIM(cNumCteTit) AND TRIM(cTraspasar)=TRIM(cNumCteTrasp) THEN
						
						ELSE
							LET Iconsecutivo= Iconsecutivo + 1;
							SELECT NVL(COUNT(*),0) INTO iExiste FROM bdinteg:"informix".si_fusreporteaut WHERE cliente_tit= cNumCteTit AND cliente_tras= cNumCteTrasp;
							IF iExiste=0 THEN
								INSERT INTO bdinteg:"informix".si_fusreporteaut (cliente_tit,cliente_tras ,id_rep) VALUES (cNumCteTit,cNumCteTrasp,Iconsecutivo);
							END IF;
							LET cTitular= cNumCteTit;
							LET cTraspasar= cNumCteTrasp;
						END IF;	
					END IF;
					LET iConteo= iConteo + 1;
				END FOREACH;
			END IF;
		END IF;


		IF cExiste = "1" THEN
			FOREACH
			
				SELECT {+INDEX (bdinteg:"informix".si_fusreporteaut idx_fusreporteaut)} DISTINCT TRIM(cliente_tit), TRIM(cliente_tras),id_rep
				INTO cNumCteTit, cNumCteTrasp, Iconsecutivo
				FROM bdinteg:"informix".si_fusreporteaut
				ORDER BY id_rep

				SELECT MIN(fecha_hora) INTO dHoraFecha FROM bdinteg:"informix".log_fusionclientes WHERE cliente_tit=cNumCteTit AND cliente_tras=cNumCteTrasp;
				
				SELECT user_insert INTO cUser_insert FROM bdinteg:"informix".log_fusionclientes WHERE cliente_tit=cNumCteTit AND cliente_tras=cNumCteTrasp AND fecha_hora = dHoraFecha GROUP BY user_insert;
				SELECT nombre INTO cNombreAnalista FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = cUser_insert;

				IF cNumCteTrasp <> cNumCteTrasp2 THEN
				
					SELECT LIMIT 1 nomctetit.apell_paterno, nomctetit.apell_materno, nomctetit.nombre1, nomctetit.nombre2, fecnactit.fecha_nac
					INTO cApePaterTit, cApeMaterTit, cNom1Tit, cNom2Tit, cFechaNacTit 
					FROM bdinteg:"informix".si_cliente nomctetit,
						 bdinteg:"informix".si_ctepf fecnactit
					WHERE nomctetit.numcte = cNumCteTit
					AND fecnactit.numcte = cNumCteTit;
					   
					SELECT LIMIT 1 nomctetras.apell_paterno, nomctetras.apell_materno, nomctetras.nombre1, 
						   nomctetras.nombre2, fecnactras.fecha_nac
					INTO cApePaterTrasp, cApeMaterTrasp, cNom1Trasp, cNom2Trasp, cFechaNacTrasp
					FROM bdinteg:"informix".si_fuscliente nomctetras,
						 bdinteg:"informix".si_fusctepf fecnactras
					WHERE nomctetras.numcte = cNumCteTrasp
					AND fecnactras.numcte = cNumCteTrasp;
					
					LET cNomCompTitular = TRIM(cNom1Tit)||" "||TRIM(cNom2Tit)||" "||TRIM(cApePaterTit)||" "||TRIM(cApeMaterTit);
					LET cNomCompTransp = TRIM(cNom1Trasp)||" "||TRIM(cNom2Trasp)||" "||TRIM(cApePaterTrasp)||" "||TRIM(cApeMaterTrasp);
					
					LET iDirecciones = '0';
                    LET iBandera1=0;
                    LET iBandera2=0;
                    LET iBandera3=0;
                    LET iBandera=0;
					LET cValidaNumCte = '';																					
					SELECT FIRST 1 numcte INTO cValidaNumCte 
					FROM bdinteg:"informix".si_fusdirecciones 
					WHERE numcte = cNumCteTrasp;
					LET iNumRows = dbinfo("sqlca.sqlerrd2");
					IF(iNumRows > 0) THEN																					
						SELECT NVL(COUNT(numcte),0)
						INTO iDirecciones
						FROM bdinteg:"informix".si_fusdirecciones
						WHERE numcte = cNumCteTrasp;
					END IF;

						FOREACH
						
							SELECT TRIM(cuenta), TRIM(producto), TRIM(num_cte), TRIM(status_cta), sdo_actual
							INTO cCta, cProducto, cNumCte, cStatus, vSaldo
							FROM bdinteg:"informix".si_fusmaechq
							WHERE num_cte = cNumCteTrasp
							--AND status_cta IN (1,3)
							
							IF cStatus = "3" THEN
								LET cStatusCuenta = "Bloqueada";
							ELSE
								LET cStatusCuenta = "Activa";
							END IF

							SELECT LIMIT 1 TRIM(prod.nombre), fecalta.fecha_alta
							INTO cDescripcion, cFechaAlta
							FROM bdicheq:"informix".sc_producto prod,
							     bdicheq:"informix".sc_maenoc fecalta
							WHERE prod.producto = cProducto
							AND fecalta.cuenta = cCta;

							SELECT MIN(fecha_hora::DATETIME HOUR TO SECOND) INTO dHora FROM bdinteg:"informix".log_fusionclientes WHERE cliente_tit=cNumCteTit AND cliente_tras=cNumCteTrasp;
							
							SELECT user_insert INTO cUser_insert FROM bdinteg:"informix".log_fusionclientes WHERE cliente_tit=cNumCteTit AND cliente_tras=cNumCteTrasp AND fecha_hora = dHoraFecha GROUP BY user_insert;
							SELECT nombre INTO cNombreAnalista FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = cUser_insert;
							
                            LET iBandera=1;
                            LET iBandera1=iBandera1 + 1;
                            IF iBandera1>1 THEN
                                LET iDirecciones='';
                            END IF;

							--IF NVL(cCta, '') <> '' THEN																							
								RETURN cCodRet,cNumCteTit,cNomCompTitular,cFechaNacTit,cNumCteTrasp,cNomCompTransp,cFechaNacTrasp,
									   cCta,cProducto,cNumCte,cStatus,vSaldo,cDescripcion,cFechaAlta,iDirecciones,dHoraFecha,dHora,cStatusCuenta,cNombreAnalista WITH RESUME;
							--END IF;

						END FOREACH;
                        FOREACH

                            SELECT TRIM(num_credito), TRIM(num_producto), TRIM(numcte), TRIM(status_cred), 0, id_unidad_prod
                                INTO cCta, cProducto, cNumCte, cStatus, vSaldo, cUnidadp
                                FROM bdinteg:"informix".si_fusmaecred
                                WHERE numcte = cNumCteTrasp
								
								IF cUnidadp > 0 OR cUnidadp IS NOT NULL THEN
									LET cStatusCuenta = "Bloqueada";
								ELSE
									LET cStatusCuenta = "Activa";
								END IF

                            IF LENGTH(cProducto)=3 THEN
                                SELECT LIMIT 1 TRIM(prod.nombre_prod), fecalta.fecha_apertura
                                INTO cDescripcion, cFechaAlta
                                FROM bdicred:"informix".sd_definicion prod,
                                     bdinteg:"informix".si_fusmaecred fecalta
                                WHERE prod.num_producto = '6'||cProducto
                                AND fecalta.num_credito = cCta;
                            ELSE
                                SELECT LIMIT 1 TRIM(prod.nombre_prod), fecalta.fecha_apertura
                                INTO cDescripcion, cFechaAlta
                                FROM bdicred:"informix".sd_definicion prod,
                                     bdinteg:"informix".si_fusmaecred fecalta
                                WHERE prod.num_producto = cProducto
                                AND fecalta.num_credito = cCta;
                            END IF;
							
							SELECT MIN(fecha_hora::DATETIME HOUR TO SECOND) INTO dHora FROM bdinteg:"informix".log_fusionclientes WHERE cliente_tit=cNumCteTit AND cliente_tras=cNumCteTrasp;
							
							SELECT user_insert INTO cUser_insert FROM bdinteg:"informix".log_fusionclientes WHERE cliente_tit=cNumCteTit AND cliente_tras=cNumCteTrasp AND fecha_hora = dHoraFecha GROUP BY user_insert;
							SELECT nombre INTO cNombreAnalista FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = cUser_insert;
							
                            LET iBandera=1;
                            LET iBandera2=iBandera2 + 1;
                            IF iBandera2>1 THEN
                                LET iDirecciones='';
                            END IF;

							--IF NVL(cCta, '') <> '' THEN																							
								RETURN cCodRet,cNumCteTit,cNomCompTitular,cFechaNacTit,cNumCteTrasp,cNomCompTransp,cFechaNacTrasp,
									   cCta,cProducto,cNumCte,cStatus,vSaldo,cDescripcion,cFechaAlta,iDirecciones,dHoraFecha,dHora,cStatusCuenta,cNombreAnalista WITH RESUME;
							--END IF;
							
                        END FOREACH;
                        FOREACH
                             SELECT {+INDEX (bdinteg:"informix".si_fusmaecredcrd pk_maecdtcte)} TRIM(num_credito), TRIM(num_producto), TRIM(numcte), TRIM(status_cred), 0
                                INTO cCta, cProducto, cNumCte, cStatus, vSaldo
                                FROM bdinteg:"informix".si_fusmaecredcrd
                                WHERE numcte = cNumCteTrasp

                            IF LENGTH(cProducto)=3 THEN
                                SELECT {+INDEX (bdinteg:"informix".si_fusmaecredcrd pk_maecdtcrd)} LIMIT 1 TRIM(prod.nombre_prod), fecalta.fecha_apertura
                                INTO cDescripcion, cFechaAlta
                                FROM bdicred:"informix".sd_definicion prod,
                                     bdinteg:"informix".si_fusmaecredcrd fecalta
                                WHERE prod.num_producto = '6'||cProducto
                                AND fecalta.num_credito = cCta;
                            ELSE
                                SELECT {+INDEX (bdinteg:"informix".si_fusmaecredcrd pk_maecdtcrd)} LIMIT 1 TRIM(prod.nombre_prod), fecalta.fecha_apertura
                                INTO cDescripcion, cFechaAlta
                                FROM bdicred:"informix".sd_definicion prod,
									 bdinteg:"informix".si_fusmaecredcrd fecalta
                                WHERE prod.num_producto = cProducto
                                AND fecalta.num_credito = cCta;
                            END IF; 

							SELECT MIN(fecha_hora::DATETIME HOUR TO SECOND) INTO dHora FROM bdinteg:"informix".log_fusionclientes WHERE cliente_tit=cNumCteTit AND cliente_tras=cNumCteTrasp;
							
							SELECT user_insert INTO cUser_insert FROM bdinteg:"informix".log_fusionclientes WHERE cliente_tit=cNumCteTit AND cliente_tras=cNumCteTrasp AND fecha_hora = dHoraFecha GROUP BY user_insert;
							SELECT nombre INTO cNombreAnalista FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = cUser_insert;
							
                            LET iBandera=1;
                            LET iBandera3=iBandera3 + 1;
                            IF iBandera3>1 THEN
                                LET iDirecciones='';
                            END IF;

							--IF NVL(cCta, '') <> '' THEN																							
								RETURN cCodRet,cNumCteTit,cNomCompTitular,cFechaNacTit,cNumCteTrasp,cNomCompTransp,cFechaNacTrasp,
									   cCta,cProducto,cNumCte,cStatus,vSaldo,cDescripcion,cFechaAlta,iDirecciones,dHoraFecha,dHora,cStatusCuenta,cNombreAnalista WITH RESUME;
							--END IF;

                    END FOREACH;						   
                    IF iBandera=0 THEN
						LET cCta = "";
						LET cProducto = "";
						LET cNumCte = "";
						LET cStatus = "";
						LET vSaldo = "";
						LET cDescripcion = "";
						LET dHora = "";
						LET cStatusCuenta = "";
						LET iDirecciones = "";
						
						--IF NVL(cCta, '') <> '' THEN																							
							RETURN cCodRet,cNumCteTit,cNomCompTitular,cFechaNacTit,cNumCteTrasp,cNomCompTransp,cFechaNacTrasp,
							   cCta,cProducto,cNumCte,cStatus,vSaldo,cDescripcion,cFechaAlta,iDirecciones,dHoraFecha,dHora,cStatusCuenta,cNombreAnalista WITH RESUME;
						--END IF;
                    END IF;

				END IF;	
				LET cNumCteTrasp2 = cNumCteTrasp;
			END FOREACH;
		ELSE
			LET cCodRet = '00001'; -- No existe registro de ctes fusionados para la fecha proporcionada
			
			RETURN cCodRet,cNumCteTit,cNomCompTitular,cFechaNacTit,cNumCteTrasp,cNomCompTransp,cFechaNacTrasp,
				   cCta,cProducto,cNumCte,cStatus,vSaldo,cDescripcion,cFechaAlta,iDirecciones,dHoraFecha,dHora,cStatusCuenta,cNombreAnalista;
		END IF;
	END
	
END PROCEDURE
DOCUMENT
'FOLIO: 1568',
'AUTOR : 95584315',
'FECHA : 24-11-2013',
'MODIFICACIÓN: Se crea SP para que consulte solo las transacciones por el usuario infoaut.',
'SUSTENTO: RQM 61 071 Fusión automática de clientes (Página 9)',
'SOLICITA: Jaime Gonzalez',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_obtiene_conexion_param(pEmpresa CHAR (3))
	
	RETURNING CHAR(5)   AS CodRetorno, 
	          CHAR(100) AS NumIp,
              CHAR(100) AS Puerto,
              CHAR(100) AS NomUsuario,
              CHAR(100) AS Password,
			  CHAR(100) AS NomBd,
			  CHAR(100) AS Tiempo,
			  CHAR(100) AS Limite;
			  

--Definicion de Variables
DEFINE iSqlErr        INTEGER;
DEFINE cCodRet        CHAR(5);
DEFINE cNumIp         CHAR(100);
DEFINE cPuerto        CHAR(100);
DEFINE cNomUsuario    CHAR(100);
DEFINE cPassword      CHAR(100);
DEFINE cNomBd         CHAR(100);
DEFINE iTiempo        INTEGER;
DEFINE cLimite        CHAR(100);

--Inicializacion de Variables
LET iSqlErr        = 0;
LET cCodRet        = '00000';
LET cNumIp         = '';
LET cPuerto        = '';
LET cNomUsuario    = '';
LET cPassword      = ''; 
LET cNomBd         = '';
LET iTiempo        = 0;
LET cLimite        = '';

--SET DEBUG FILE TO '/home/tmp/leonardo/sp_obtiene_conexion_param.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumIp, cPuerto, cNomUsuario, cPassword, cNomBd, iTiempo, cLimite;
		END IF;
	END EXCEPTION;
	IF (pEmpresa IS NULL OR NVL (pEmpresa, '') = '') THEN
		LET cCodRet = '00001';
    ELSE
	SET LOCK MODE TO WAIT 3;
		
		SELECT valor
		INTO cNumIp
		FROM bdinteg:"informix".si_param 
		WHERE empresa = pEmpresa
        AND cod_param = '300';
		
		SELECT valor
		INTO cPuerto
		FROM bdinteg:"informix".si_param 
		WHERE empresa = pEmpresa
        AND cod_param = '301';
		
		SELECT valor
		INTO cNomUsuario
		FROM bdinteg:"informix".si_param 
		WHERE empresa = pEmpresa
		AND cod_param = '157';
		
		SELECT valor
		INTO cPassword
		FROM bdinteg:"informix".si_param 
		WHERE empresa = pEmpresa 
		AND cod_param = '158';
		
		SELECT valor
		INTO cNomBd
		FROM bdinteg:"informix".si_param 
		WHERE empresa = pEmpresa 
		AND  cod_param = '159';
		
		SELECT valor
		INTO cLimite
		FROM bdinteg:"informix".si_param 
		WHERE empresa = pEmpresa
        AND cod_param = '166';
		
		SELECT CAST(valor AS INTEGER) 
		INTO iTiempo
		FROM bdinteg:"informix".si_param 
		WHERE empresa = pEmpresa
        AND cod_param = '167';
		
		IF  (cNumIp IS NULL OR cNumIp  = '') OR (cPuerto IS NULL OR cPuerto  = '') OR (cNomUsuario  IS NULL OR cNomUsuario  = '') 
			OR (cPassword IS NULL OR cPassword = '') OR (cNomBd IS NULL OR cNomBd  = '')  OR (iTiempo IS NULL OR iTiempo = '') 
			OR (cLimite IS NULL OR cLimite = '') THEN
			LET cCodRet = '00002';
		END IF;
	END IF;
	RETURN cCodRet, TRIM(cNumIp), TRIM(cPuerto), TRIM(cNomUsuario), TRIM(cPassword), TRIM(cNomBd), iTiempo, TRIM(cLimite);	
END;
END PROCEDURE
DOCUMENT
'Folio: 1559',
'AUTOR : 95594213',
'FECHA : 17-10-2013',
'DESCRIPCION: Se crea sp_obtiene_conexion_param para mandar llamar Ip, Puerto, Nombre Usuario, Password, BD, Nombre de Archivo, Ruta, Servicio, Usuariosub, Passwordsub, Rutadepo',
'SUSTENTO:RQM 12 023 Consulta de Transacciones.doc No viene documentado en el RQM ',
'SOLICITA: Norberto Corona Berruecos',
'BD: bdinteg',
'Folio: 1587',
'AUTOR : 95594213',
'FECHA : 20-02-2014',
'MODIFICACIÓN: Se Modifica sp_obtiene_conexion_param para hacer una conexion a postgres quitarle retornos y agregar uno nuevo.',
'SUSTENTO:DMP Integral Procesos',
'SOLICITA: Norberto Corona Berruecos',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_registra_actualiza_transfolio(pEmpresa   	CHAR(3), 
															 pSucursal      CHAR(4),
															 pOpcion        INTEGER, 
															 pFechaTran     CHAR(8),
															 pHoraTran      CHAR(6),
															 pNumTarje      CHAR(16), 
															 pFechaExp      CHAR(4), 
															 pCodSeg        CHAR(4), 
															 pCURP          CHAR(18), 
															 pFolio         CHAR(2), 
															 pCodResp       CHAR(2),
															 pMotRechazo    CHAR(3),
															 pNumEmpleado   CHAR (8),
															 pCveAfore	    CHAR(3),
															 pTipoTarjeta   CHAR(1),--'C' PARA CREDITO O 'D' PARA DEBITO
															 pFlagCteHuella CHAR(1))--'1' CLIENTE TITULAR	
																					--'2' NO ES DEL CLIENTE TITULAR	
RETURNING CHAR(5);																	--'3' HUELLA CORRESPONDE AL TITULAR DE LA TARJETA
																					--'4' SI LA TARJETA ES DEL TITULAR Y NO ESTA ACTIVA,NO ES DEL TITULAR Y NO ESTA ACTIVA
--DECLARACION DE VARIABLES;															--O HUELLA DEL CLIENTE NO COINCIDE 				
DEFINE cCodret         CHAR(5);
DEFINE iSqlerr	       INTEGER;
DEFINE cTipoTarjeta    CHAR(1);
DEFINE cFlagCteHuella  CHAR(1);
DEFINE cStatusTar      CHAR(1);

--INICIALIZACIÓN DE VARIABLES
LET cCodret        = '00000';
LET iSqlerr        = 0;
LET cTipoTarjeta   = '';
LET cFlagCteHuella = '';
LET cStatusTar     = '';

--SET DEBUG FILE TO '/respaldosbd/isarai/sp_registra_actualiza_transfolio.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN
	--CONTROLADOR DE ERRORES
	ON EXCEPTION SET iSqlerr
		IF iSqlerr <> 0 THEN
			LET cCodret = iSqlerr;
			RETURN cCodret;
		END IF;
	END EXCEPTION;
	
	--PARAMETROS VACIOS
	IF NVL(pEmpresa,'') = '' OR NVL(pFechaTran,'')= '' OR NVL(pFechaExp,'') = '' OR NVL(pNumTarje,'') = '' OR NVL(pOpcion,0) = 0 THEN
		LET cCodret = '00001';
		RETURN cCodret;
	END IF;
	
	IF NVL(pTipoTarjeta,'')  NOT IN ('','C','D') THEN
		LET cCodret = '00001'; --PARAMETROS INALIDOS
		RETURN cCodret;
	END IF;

	IF pOpcion = 1 THEN 
		--CONSULTA LA TABLA sd_tarjeta CUANDO EL NUMERO DE TARJETA ES DE CREDITO
		IF pTipoTarjeta = 'C' THEN
			SELECT tipo_tarjeta, status_tar
			INTO cTipoTarjeta,cStatusTar
			FROM bdicred: "informix".sd_tarjeta
			WHERE num_tarjeta = pNumTarje
			AND empresa = pEmpresa
			AND secuencia = (SELECT MAX(secuencia)
							FROM bdicred: "informix".sd_tarjeta
							WHERE empresa = pEmpresa
							AND num_tarjeta = pNumTarje)
			AND empresa = empresa 
			AND num_tarjeta = num_tarjeta	
			AND status_tar = status_tar;	
							
		--CONSULTA LA TABLA sc_tarjeta CUANDO EL NUMERO DE TARJETA ES DE DEDITO
		ELIF pTipoTarjeta = 'D' THEN
			SELECT tipo_tarjeta, status_tar
			INTO cTipoTarjeta,cStatusTar
			FROM bdicheq: "informix".sc_tarjeta
			WHERE num_tarjeta = pNumTarje
			AND empresa = pEmpresa
			AND secuencia = (SELECT MAX(secuencia)
							FROM bdicheq: "informix".sc_tarjeta
							WHERE empresa = pEmpresa
							AND num_tarjeta = pNumTarje)
			AND empresa = empresa 
			AND num_tarjeta = num_tarjeta	
			AND status_tar = status_tar;	
										
		ELSE
		
			--SI EL TIPO DE TARJETA NO ES DE ALGUN CLIENTE BANCOPPEL
			INSERT INTO "informix".si_folioafore (empresa, sucursal, fecha_transac, hora_transac, num_tarjeta, fecha_expira, cod_seguridad,curp_resp, folio_resp, codigo_resp, motivo_rechazo, 
							   fecha_insert, num_usuario,cve_afore, flag_cte_huella)
			VALUES(pEmpresa, pSucursal, pFechaTran, pHoraTran, pNumTarje, pFechaExp, TRIM(pCodSeg), pCURP, pFolio, pCodResp, pMotRechazo, CURRENT, pNumEmpleado,pCveAfore,cFlagCteHuella);
			
			RETURN cCodret;
		END IF;
		
		--SI NO EXISTEN REGISTROS EN NINGUNA DE LAS DOS TABLAS, EL SP RETORNARA UN ERROR CONTROLADO
		IF ( DBINFO('sqlca.sqlerrd2') = 0 ) THEN
			LET cCodret = '00004';
			RETURN cCodret;
		END IF;

		IF NVL(cTipoTarjeta,'') = 'T' AND NVL(cStatusTar,'') = 'A' THEN
			LET cFlagCteHuella = '1'; -- SI LA TARJETA ES DEL TITULAR Y ESTA ACTIVA
		ELIF NVL(cTipoTarjeta,'') = 'A' AND NVL(cStatusTar,'') = 'A' THEN
			LET cFlagCteHuella = '2'; -- SI LA TARJETA NO ES DEL TITULAR Y ESTA ACTIVA
			LET cCodret = '00005';
		ELIF (NVL(cTipoTarjeta,'') = 'T' AND NVL(cStatusTar,'') = 'C') THEN
			LET cFlagCteHuella = '5'; -- SI LA TARJETA ES DEL TITULAR Y ESTA CANCELADA
			LET cCodret = '00006';	
		ELIF (NVL(cTipoTarjeta,'') = 'A' AND NVL(cStatusTar,'') = 'C') THEN
			LET cFlagCteHuella = '2'; -- NO ES DEL TITULAR Y ESTA CANCELADA
			LET cCodret = '00005';
		END IF;
		
		--SE INSERTA EL REGISTRO EN LA PRIMERA VUELTA.
		INSERT INTO "informix".si_folioafore (empresa, sucursal, fecha_transac, hora_transac, num_tarjeta, fecha_expira, cod_seguridad,curp_resp, folio_resp, codigo_resp, motivo_rechazo, 
							   fecha_insert, num_usuario,cve_afore, flag_cte_huella)
		VALUES(pEmpresa, pSucursal, pFechaTran, pHoraTran, pNumTarje, pFechaExp, TRIM(pCodSeg), pCURP, pFolio, pCodResp, pMotRechazo, CURRENT, pNumEmpleado,pCveAfore,cFlagCteHuella);
	
	    RETURN cCodret;
		
	ELIF pOpcion = 2 THEN --CLIENTE BANCOPPEL
		IF pFlagCteHuella NOT IN ('3','4') THEN
			LET cCodret = '00001'; -- ERROR EN LOS PARAMETROS
		END IF;
			
		IF pCodResp = '01' AND NVL(pFolio,'') = '' AND pFlagCteHuella = '3' THEN 
			LET cCodret = '00002'; -- ERROR EN LOS PARAMETROS
		END IF;
		
	ELIF pOpcion = 3 THEN  --CLIENTE DE OTRO BANCO 
		IF pCodResp = '01' AND NVL(pFolio,'') = '' THEN
			LET cCodret = '00002'; --SI EL TIPO DE TARJETA NO ES DE ALGUN CLIENTE BANCOPPEL Y OCURRIO UN ERROR EN LA CONSULTA A PROSA
		END IF
	
	ELSE
		LET cCodret = '00007'; -- ERROR,NUMERO DE OPCION INVALIDA
	
	END IF
	
	IF cCodret::INTEGER = 0 THEN
	
		--ACTUALIZA EL NUMERO DE FOLIO,MOTIVO DE RECHAZO,CLAVE AFORE,FLAG_CTE_HUELLA EN LA SEGUNDA VUELTA
		UPDATE "informix".si_folioafore SET folio_resp = pFolio, codigo_resp = pCodResp, motivo_rechazo = pMotRechazo, cve_afore = pCveAfore,flag_cte_huella = pFlagCteHuella
		WHERE empresa = pEmpresa AND fecha_transac = pFechaTran AND hora_transac = pHoraTran AND num_tarjeta = pNumTarje;

	END IF

--RETURN PRINCIPAL
	RETURN cCodret;

END;
--*********************************************************
--| Procedimiento   : sp_registra_actualiza_transfolio
--| Versión         : 20110504
--| Creado por      : Adrian Lara
--| Fecha creacion  : 4 de mayo de 2011
--| Descripción     : Registra y actualiza las transacciones para la consulta de Folio de Estado de Cuenta a PROSA.
--**********************************************************
END PROCEDURE
DOCUMENT
'Modifico: Eduardo Lopez',
'Fecha: 21-03-2013',
'BD: bdinteg',
'ver.:20130321',
'Descripción: Se modifico para que guarde o actualice el nuevo campo(cve_afore) en la tabla si_folioafore',
'MODIFICO: ISARAI BOJORQUEZ AGUIRRE',
'FECHA: 24/02/2014',
'BD:BDINTEG',
'VERSION: 20140224.0948',
'DESCRIPCION: SE MODIFICA PROCEDIMIENTO PARA AGREGAR LOS NUEVOS PARAMETROS pTipoTarjeta,pFlagCteHuella NECESARIOS EN LA INSERCCION O ACTUALIZACION DE LA TABLA',
'si_folioafore. SE AGREGA LA OPCION 3 EN CASO DE NO SER CLIENTE BANCOPPEL SE INSERTE O ACTUALICE EN LA MISMA TABLA.SE APLICAN REGLAS DE INFORMIX';

CREATE PROCEDURE "informix".sp_cnsif_guardanivelesaccesomodulos(pIdUsuario CHAR(8), pIdFuncion CHAR(10), pIdFuncionC CHAR(8), pIdModulos CHAR(255), pNivelesAcceso CHAR(100))
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNivelAcceso SMALLINT;
	DEFINE iRegsProcesados INTEGER;
	DEFINE iExiste SMALLINT;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNivelAcceso = 0;
	LET iRegsProcesados = 0;
	LET iExiste = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cnsif_guardanivelesaccesomodulos.out';
		--TRACE ON;
		
		IF pIdUsuario = '' OR pIdFuncion = '' OR pIdFuncionC = '' OR pIdModulos = '' OR pNivelesAcceso = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACIÃN DE ACCESO AL PROCEDIMIENTO
		EXECUTE PROCEDURE "informix".sp_cnsif_confirmaejecutivo(pIdUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		-- Se valida que el usuario no este insertado ya en tabla, en ese caso solo se actualizaran sus niveles de acceso
		SELECT COUNT(id_usuario)
		INTO iExiste
		FROM "informix".si_seg_nivel_acceso_modulo
		WHERE id_usuario = pIdFuncionC;
		
		IF iExiste <> 0 THEN
			LET cCodRet = '00004';
			RETURN cCodRet;
		END IF;
		
		-- Se inserta al usuario en tablas
		INSERT INTO bdinteg:si_seg_nivel_acceso_modulo(id_usuario, id_modulo, nivel_acceso)
		SELECT pIdFuncionC, a.id_modulo, iNivelAcceso
		FROM bdinteg:si_seg_modulos a;
		
		EXECUTE PROCEDURE "informix".sp_cnsif_actualizanivelesaccesomodulos(pIdUsuario, pIdFuncion, pIdFuncionC, pIdModulos, pNivelesAcceso) INTO cCodRet, iRegsProcesados;
		IF cCodRet::INTEGER < 0 THEN
			RAISE EXCEPTION cCodRet::INTEGER, 0, 'ERROR EN SP sp_cnsif_actualizanivelesaccesomodulos';
		END IF;
		
		RETURN cCodRet;
		
	END;
	
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 30/12/2013",
"DESCRIPCION: Procedimiento que guarda los niveles de acceso para un usuario",
"BD: bdinteg";

CREATE PROCEDURE "informix".sp_validaemail(pEmail	Char(100)) 
RETURNING CHAR(5) As Codigo_error,
 CHAR(1) As Valido;

DEFINE vlStrTemp  Char(1);
DEFINE vlContador  Smallint;
DEFINE vlEmail    char(100);
DEFINE vlValidaEmail char(1);
DEFINE sCodRet		char(5);
DEFINE vlPosArroba	smallint;
DEFINE	vlPosPunto	smallint;
DEFINE	vsqlerr		smallint;
DEFINE	vlPosGuionB	smallint;
DEFINE	vlPosGuionA	smallint;

LET vlStrTemp = '';
LET	vlcontador = '';
LET	vlEmail = '';	
LET vlValidaEmail ='V';
LET sCodRet ='00000';
LET vlPosArroba	=0;
LET	vlPosPunto	=0;
LET	vlPosGuionB	=0;
LET	vlPosGuionA	=0;

BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scodret=vsqlerr;
      RETURN scodret,'F';
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "validaemail.out";
--TRACE ON;

  LET vlEmail = trim(pEmail);
  
  let vlContador = 1;
  
  If pEmail = "" Then
    let vlValidaEmail = 'F';
    let scodret =  '00001'; --"No se indicó ninguna dirección de mail para verificar"   
	RETURN scodret,vlValidaEmail;  
  ELIF length(vlEmail) < 7 then
    let vlValidaEmail = 'F';
    let scodret =  '00002'; --"La direccion no es valida favor de verificar"   
	RETURN scodret,vlValidaEmail;
  END IF;	
  
  While vlContador <= length(vlEmail) LOOP
     let vlStrTemp = Substr(vlEmail,vlContador,1);
     if (vlStrTemp not in ('a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z')) 
	     and
		 (vlStrTemp not in ('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'))
		 and
		 (vlStrTemp not in ('1','2','3','4','5','6','7','8','9','0'))
		 and 
		 (vlStrTemp not in ('-','.','@','_'))		 
		  then 
	   let sCodRet = '00003'; --La dirección cuenta con un caracter invalido
	   let vlValidaEmail = 'F';
	   RETURN scodret,vlValidaEmail;  
	 elif vlStrTemp in ('-','.','@','_') and (( vlContador = 1) or (vlContador = length(vlEmail) ) ) then
	   let sCodRet = '00004'; --La dirección de email no puede llevar -,.,@,_ ni al principio ni al final 
	   let vlValidaEmail = 'F';	   
	   RETURN scodret,vlValidaEmail;  
	 elif vlStrTemp = ' ' then
	   let sCodRet = '00006'; --La dirección de email no puede llevar espacios vacios
	   let vlValidaEmail = 'F';	     
	   RETURN scodret,vlValidaEmail;  
	 end if;
	 
	 if ((vlPosArroba >0)  and vlStrTemp in ('@') and (vlPosArroba +1 =vlContador) ) then	   
	   let sCodRet = '00008'; --No pueden ir  @@ 
	   let vlValidaEmail = 'F';	   
	   RETURN scodret,vlValidaEmail;  	
	 end if;

	if ((vlPosPunto >0)  and vlStrTemp in ('.') and  (vlPosPunto +1 =vlContador) ) then	   
	   let sCodRet = '00014'; --No pueden ir dos puntos juntos
	   let vlValidaEmail = 'F';	   
	   RETURN scodret,vlValidaEmail;   
	 end if; 	 
	if ((vlPosGuionB >0)  and vlStrTemp in ('_') and  (vlPosGuionB +1 =vlContador) ) then	   
	   let sCodRet = '00015'; --No pueden ir dos guiones bajo juntos
	   let vlValidaEmail = 'F';	   
	   RETURN scodret,vlValidaEmail; 
	 end if; 	 
	if ((vlPosGuionA >0)  and vlStrTemp in ('-') and  (vlPosGuionA +1 =vlContador) ) then	   
	   let sCodRet = '00016'; --No pueden ir dos guiones alto juntos
	   let vlValidaEmail = 'F';	   
	   RETURN scodret,vlValidaEmail; 
	 end if;

	 if vlStrTemp in ('.') then
	   let vlPosPunto = vlContador;
	 end if;
	 if vlStrTemp in ('@') then
	   let vlPosArroba = vlContador;
	 end if;

	if vlStrTemp in ('-') then
	   let vlPosGuionA = vlContador;
	 end if;

	if vlStrTemp in ('_') then
	   let vlPosGuionB = vlContador;
	 end if;


	 if ((vlPosPunto >0)  and (vlPosArroba > 0)) and ( (vlPosPunto +1 =vlPosArroba) or (vlPosPunto -1 = vlPosArroba) ) then	   
	   let sCodRet = '00005'; --No puede ir un punto antes ni despues del arroba
	   let vlValidaEmail = 'F';	   
	   RETURN scodret,vlValidaEmail; 	
	 end if;  

	if ((vlPosGuionA >0)  and (vlPosArroba > 0)) and ( (vlPosGuionA +1 =vlPosArroba) or (vlPosGuionA -1 = vlPosArroba) ) then	   
	   let sCodRet = '00009'; --No puede ir un guion alto antes ni despues del arroba
	   let vlValidaEmail = 'F';	   
	   RETURN scodret,vlValidaEmail; 
	 end if;            

     if ((vlPosGuionB >0)  and (vlPosArroba > 0)) and ( (vlPosGuionB +1 =vlPosArroba) or (vlPosGuionB -1 = vlPosArroba) ) then	   
	   let sCodRet = '00010'; --No puede ir un guion bajo antes ni despues del arroba
	   let vlValidaEmail = 'F';	   
	   RETURN scodret,vlValidaEmail; 
	 end if;            
     if ((vlPosGuionB >0)  and (vlPosPunto > 0)) and ( (vlPosGuionB +1 =vlPosPunto) or (vlPosGuionB -1 = vlPosPunto) ) then	   
	   let sCodRet = '00011'; --No puede ir un guion bajo antes ni despues del punto
	   let vlValidaEmail = 'F';	   
	   RETURN scodret,vlValidaEmail; 
	 end if;            
     if ((vlPosGuionA >0)  and (vlPosPunto > 0)) and ( (vlPosGuionA +1 =vlPosPunto) or (vlPosGuionA -1 = vlPosPunto) ) then	   
	   let sCodRet = '00012'; --No puede ir un guion alto antes ni despues del punto
	   let vlValidaEmail = 'F';	   
	   RETURN scodret,vlValidaEmail;  
	 end if; 
     if ((vlPosGuionA >0)  and (vlPosGuionB > 0)) and ( (vlPosGuionA +1 =vlPosGuionB) or (vlPosGuionA -1 = vlPosGuionB) ) then	   
	   let sCodRet = '00013'; --No puede ir un guion alto antes ni despues del guion bajo
	   let vlValidaEmail = 'F';	   
	   RETURN scodret,vlValidaEmail;  	
	 end if;            

	 LET vlContador = vlContador +1;
  END LOOP;
  RETURN scodret,vlValidaEmail;
END;  
END PROCEDURE;