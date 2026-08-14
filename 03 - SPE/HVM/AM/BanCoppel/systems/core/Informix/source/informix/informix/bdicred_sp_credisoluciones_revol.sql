CREATE PROCEDURE "informix".sp_credisoluciones_revol(pempresa CHAR(3), pFolioMovto CHAR(20) DEFAULT "", pSucursal CHAR(4), pUsuario CHAR(20))
   RETURNING CHAR(6), CHAR(80);
	
	--DECLARACION DE VARIABLES.
	DEFINE iSqlErr                      INTEGER;
	DEFINE iIsamErr                     INTEGER;
	DEFINE cErrorInfo                   CHAR(100);
	DEFINE CodRet                       CHAR(6);
	DEFINE Mensaje                  	CHAR(80);
	DEFINE CSnum_credito,cCredito_promo	CHAR(20);
	DEFINE v_total_cap_cs				DECIMAL(14,2); 
	DEFINE v_total_mto_cs, v_mto_pag_cs	DECIMAL(14,2);
	DEFINE v_capital_cs, v_interes_cs 	DECIMAL(14,2);
	DEFINE v_iva_cs, v_monto_actual		DECIMAL(14,2);
	DEFINE v_monto_int_iva 				DECIMAL(14,2);
	DEFINE cfolio_mov_promo  			CHAR(16);	
	DEFINE cfolio_suc_promo 			CHAR(16);
	DEFINE cCharAux          			CHAR(80);
	DEFINE dtDateAux         			DATE;
	DEFINE dDecAux           			DECIMAL(18,2);
	DEFINE iIntAux           			INTEGER;
	DEFINE dPagoCom,dPagoIvaCom			DECIMAL(18,2);
	DEFINE dSdoAdeudTotal,dIntDevengado	DECIMAL(18,2);
	DEFINE dIvaIntDevengado,vcap_vig	DECIMAL(18,2);
	DEFINE dSdoAdeudTotalAct,dIntVig	DECIMAL(18,2);	
	DEFINE dIvaIntVig   				DECIMAL(18,2);
	DEFINE dtFechaApertura				DATE;
	DEFINE dtFechaProxPago  			DATE;
	DEFINE dPagoMinAct        			DECIMAL(18,2);
	DEFINE cStatus						CHAR(23);
	DEFINE cStatus_tar					CHAR(1);
	DEFINE dFecha_hoy					DATE;
	DEFINE dFecha_credisol				DATE;
	DEFINE cTipo_promo					CHAR(2);
	DEFINE sStatus_cancel1				SMALLINT;
	DEFINE sStatus_cancel2				SMALLINT;
	DEFINE sStatus_cancel3				SMALLINT;
	DEFINE sBand				 		SMALLINT;
	DEFINE cStatus_promo				CHAR(1);
	DEFINE cTipoContrato				CHAR(3);
	DEFINE dSdoReducido					DECIMAL(18,2);
	DEFINE dFechaReducRestaurada		DATE;
	DEFINE cFolioSuc					CHAR(16);
	DEFINE cDivisa             			CHAR(2);
	DEFINE cNumProducto   				CHAR(4); 
	DEFINE cSucursal 					CHAR(4);
	DEFINE dMonto_LinOrig				DECIMAL(18,2);	
	DEFINE dMonto_LinNva 				DECIMAL(18,2);		
	DEFINE cNumCte						CHAR(20);
	DEFINE dSdoRet_Orig 				DECIMAL(18,2);		
	DEFINE dSdoRet_Aux	 				DECIMAL(18,2);		
	DEFINE dSdoRet_Nvo	 				DECIMAL(18,2);		
	DEFINE cTran_PagoAntTot_CredPP 		CHAR(4);
	DEFINE cTran_CargoTdc_Int 			CHAR(4);
	DEFINE cTran_CargoTdc_Iva 			CHAR(4);
	DEFINE cTran_CargoTdc_Capital 		CHAR(4);
	DEFINE cNumProd_crd   				CHAR(4);
	
	--INICIALIZACION DE VARIABLES.

	LET iSqlErr     			= 0;
	LET iIsamErr    			= 0;
	LET cErrorInfo  			= "";
	LET CodRet      			= "000000";
	LET Mensaje   				= "Se realizo proceso exitosamente";
	LET CSnum_credito			= '';
	LET cCredito_promo 			= '';
	LET v_total_cap_cs			= 0;
	LET v_total_mto_cs			= 0;
	LET v_mto_pag_cs 			= 0;
	LET v_capital_cs			= 0;
	LET v_interes_cs			= 0;
	LET v_iva_cs				= 0;
	LET v_monto_actual			= 0;
	LET v_monto_int_iva 		= 0;
	LET cfolio_mov_promo		= '';
	LET cfolio_suc_promo 		= '';
	LET cCharAux       = "";
	LET dtDateAux      = DATE(1);
	LET dDecAux        = 0; 
	LET iIntAux = 0; 
	LET dPagoCom = 0; 
	LET dPagoIvaCom = 0; 
	LET dSdoAdeudTotal = 0; 
	LET dIntDevengado = 0; 
	LET dIvaIntDevengado = 0; 
	LET vcap_vig = 0; 
	LET dIntVig = 0; 
	LET dIvaIntVig = 0;
	LET dtFechaApertura  = DATE(1); LET dtFechaProxPago = DATE(1); LET dPagoMinAct = 0; LET dSdoAdeudTotalAct = 0;
	LET cStatus 		 = "";
	LET cStatus_tar 	 = "";
	LET dFecha_hoy 	 	 = "";
	LET dFecha_credisol  = "";
	LET cTipo_promo 	 = "";
	LET sStatus_cancel1  = 0;
	LET sStatus_cancel2  = 0;
	LET sStatus_cancel3  = 0;
	LET sBand      		= 0;
	LET cStatus_promo 	= "";
	LET cTipoContrato	= "";
	LET dSdoReducido	= 0;
	LET dFechaReducRestaurada = DATE(1);
	LET cFolioSuc		= "";
	LET cDivisa			= "";
	LET cNumProducto   	= "";
	LET cSucursal 		= "";
	LET dMonto_LinOrig	= 0;	
	LET dMonto_LinNva 	= 0;	
	LET cNumCte			= 0;
	LET dSdoRet_Orig 	= 0;
	LET dSdoRet_Aux		= 0;
	LET dSdoRet_Nvo		= 0;	
	LET cTran_PagoAntTot_CredPP = "";
	LET cTran_CargoTdc_Int 		= "";
	LET cTran_CargoTdc_Iva 		= "";
	LET cTran_CargoTdc_Capital 	= "";
	LET cNumProd_crd			= "";
	
	BEGIN

		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		   IF iSqlErr != 0 THEN
				LET CodRet     = iSqlErr;
				LET Mensaje = cErrorInfo;
				RETURN CodRet, TRIM(Mensaje);
		   END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO "/informix/mahr/sp_credisoluciones_revol4.out";
		--TRACE ON;
	  
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- SE TOMA LA FECHA HOY PARA COMPARARSE CON LA FECHA DE LA CREDISOLUCION A CANCELAR YA QUE NO SE PUEDE CANCELAR EL MISMO DIA QUE SE DA DE ALTA
		SELECT fecha_hoy 
		INTO dFecha_hoy
		FROM "informix".sd_fechas WHERE empresa = '001';
		
	
		-- SE OBTIENEN LOS ESTATUS DE CREDISOLUCIONES QUE SI SE PUEDEN CANCELAR
		SELECT valor INTO sStatus_cancel1 FROM "informix".sd_param WHERE cod_param = '965';
		SELECT valor INTO sStatus_cancel2 FROM "informix".sd_param WHERE cod_param = '966';
		SELECT valor INTO sStatus_cancel3 FROM "informix".sd_param WHERE cod_param = '967';
	
		FOREACH
		  -- SE OBTIENEN LOS DATOS DE LAS CREDISOL QUE SE VAN A CANCELAR DE ACUERDO AL FOLIO_MOVTO 
		  SELECT {+avoid_full (bdicred:sd_promocion_credito)}
				 --{+ INDEX (bdicred:sd_promocion_credito idx_sd_promocion_credito4)}
				 b.num_credito  , a.num_sol_prestamo , a.monto_actual       , a.monto_int_iva, a.folio_movto   , a.folio_suc     , a.fecha        , a.num_promo, a.status     , 
				 a.tipo_contrato, a.sdo_disp_reducido, a.fecha_sdo_disp_rest, b.num_producto , b.sucursal      , b.divisa, b.numcte, a.num_pro_prestamo
		  INTO   CSnum_credito  , cCredito_promo     , v_monto_actual       , v_monto_int_iva, cfolio_mov_promo, cfolio_suc_promo, dFecha_credisol, cTipo_promo, cStatus_promo, 
		         cTipoContrato  , dSdoReducido       , dFechaReducRestaurada, cNumProducto   , cSucursal       , cDivisa , cNumCte , cNumProd_crd
		  FROM bdicred:"informix".sd_promocion_credito a
		 INNER JOIN bdicred:"informix".sd_maecred b ON (a.empresa = b.empresa AND a.num_credito = b.num_credito)
         INNER JOIN bdicred:"informix".sd_maesdos d ON (b.num_credito = d.num_credito)
		  WHERE b.status_cred IN ('AA','E1')
			AND (d.monto_vencido + d.mto_venc_trasp) = 0
			AND a.folio_movto = pFolioMovto
			AND a.folio_movto != ''
			AND a.sistema = '06'			
		

			-- SI EL ESTATUS DE LA CREDISOL NO COINCIDE CON LOS DE LA SD_PARAM YA NO SE TOMA ENCUENTA Y SE TOMA LA SIGUIENTE
			IF cStatus_promo NOT IN(sStatus_cancel1,sStatus_cancel2,sStatus_cancel3) THEN
				CONTINUE FOREACH;
			END IF

			-- LA CREDISOL NO SE PUEDE CANCELAR EL MISMO DIA QUE SE DA DE ALTA, POR TAL MOTIVO SE COMPARA LA FECHA DE ALTA CON LA FECHA HOY
			IF dFecha_hoy <= dFecha_credisol AND cTipoContrato != '3' THEN				
				CONTINUE FOREACH;
			END IF;

			-- Identifica la transaccion depdiendo si es Credisoluciones  o Meses sin intereses
			IF cNumProd_crd = '6900' THEN
				LET cTran_PagoAntTot_CredPP = "4210";
				LET cTran_CargoTdc_Iva = "4202";
				LET cTran_CargoTdc_Int = "4201";	
				LET cTran_CargoTdc_Capital = "4200";
			ELIF cNumProd_crd = '8900' THEN
				LET cTran_PagoAntTot_CredPP = "4250";
				LET cTran_CargoTdc_Iva = "4254";	
				LET cTran_CargoTdc_Int = "4255";
				LET cTran_CargoTdc_Capital = "4256";
			ELSE
				CONTINUE FOREACH;
			END IF;
			--SE OBTIENE EL ADEUDO DEL CLIENTE DE CREDISOLUCIONES HASTA ESE MOMENTO				

			EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(pEmpresa,cCredito_promo)
				INTO CodRet,Mensaje,cCharAux,cCharAux,dtFechaApertura,dtFechaProxPago,dPagoMinAct,dtDateAux,
				  iIntAux,iIntAux,dDecAux,dDecAux,dDecAux,dDecAux,vcap_vig,dDecAux,dDecAux,dDecAux,
				  dDecAux,dIntVig,dDecAux,dDecAux,dDecAux,dDecAux,dIvaIntVig,dDecAux,dDecAux,dDecAux,
				  dDecAux,dDecAux,dDecAux,dDecAux,dSdoAdeudTotalAct,dIntDevengado,dIvaIntDevengado,
				  dDecAux,dDecAux,cCharAux,iIntAux,cCharAux,cCharAux,cCharAux,cCharAux,iIntAux,
				  cCharAux,cCharAux,iIntAux,cCharAux;

			IF  dSdoAdeudTotalAct > 0 THEN
				--SE REALIZA EL PAGO POR EL MONTO CORRESPONDIENTE AL MES CORRIENTE DE CREDISOLUCIONES
				CALL "informix".sp_cargo_abono_palzo(pEmpresa,cCredito_promo,'',dSdoAdeudTotalAct,USER,'9290',cTran_PagoAntTot_CredPP,3,'')
				RETURNING CodRet, Mensaje;

				IF CodRet::INTEGER <> 0 THEN
					RETURN CodRet, TRIM(Mensaje);
				ELSE
					LET CodRet = "000";
				END IF;
				
				--IF (SELECT sdo_retenido FROM "informix".sd_maesdos WHERE empresa = '001' and num_credito = CSnum_credito) >= (v_monto_actual + v_monto_int_iva) THEN		
					
				LET sBand = 1;
				
				SELECT sdo_retenido INTO dSdoRet_Orig FROM "informix".sd_maesdos WHERE num_credito = CSnum_credito;
				LET dSdoRet_Aux = dSdoRet_Orig - (v_monto_actual + v_monto_int_iva);
				IF dSdoRet_Aux < 0 THEN
					LET dSdoRet_Nvo = 0;
				ELSE
					LET dSdoRet_Nvo = dSdoRet_Aux;
				END IF;
				
				UPDATE "informix".sd_maesdos
					--SET sdo_retenido = sdo_retenido - (v_monto_actual + v_capital_cs)     --FMV 19mar14: Se omite v_capital_cs sin valor
					--SET sdo_retenido = sdo_retenido - (v_monto_actual + v_monto_int_iva) 
					SET sdo_retenido = dSdoRet_Nvo
				 WHERE empresa = '001' 
				  and num_credito = CSnum_credito;

				UPDATE "informix".sd_promocion_credito
				   SET status = 7		-- SE CAMBIA EL ESTATUS A CANCELADO
				 WHERE empresa = '001'
				   AND num_sol_prestamo = cCredito_promo
				   AND folio_movto = pFolioMovto;

				UPDATE "informix".sd_maeretenido
				   SET estatus = 'S'
				 WHERE empresa = '001'
				   AND num_credito = CSnum_credito
				   AND folio_suc = cfolio_mov_promo;

				UPDATE "informix".sd_maeretenido
				   SET estatus = 'S'
				 WHERE empresa = '001'
				   AND num_credito = CSnum_credito
				   AND NVL(SUBSTR(referencia,1,16),'') = cfolio_suc_promo;
				   
				UPDATE "informix".sd_amortiza_creditocrd
				   SET capital_status = 5,
					   capital_status_ant = 1, 
					   interes_pagado = interes_debe,
					   interes_fecha_pago = dFecha_hoy,
					   iva_pagado = iva_debe,
					   iva_fecha_pago = dFecha_hoy							   
				 WHERE fecha_cuota = dFecha_hoy
				   AND num_credito = cCredito_promo;   
				   
				   LET cStatus = 'A SOLICITUD DEL CLIENTE'; 
				   
				IF NVL(pFolioMovto, '') = '' THEN -- SI ES POR PROCESO BATCH SI LA TARJETA ESTA VENCIDA ES LA DESCRIPCION QUE SE REGISTRA EN LA TABLA SD_CANCELA_CREDISOL
			   
					LET pSucursal = '9250';
			   
					SELECT status_tar
					INTO cStatus_tar
					FROM "informix".sd_tarjeta 
					WHERE empresa = '001'
					AND num_credito = CSnum_credito
					AND tipo_tarjeta = 'T'
					AND secuencia = (SELECT MAX(secuencia) FROM "informix".sd_tarjeta WHERE empresa = '001' AND num_credito = CSnum_credito AND tipo_tarjeta = 'T');
					
					IF cStatus_tar <> 'A' THEN
						LET cStatus = 'TARJETA VENCIDA';
					END IF							   
			   END IF							   
				   
				   
				-- Se agrega registro en tabla sd_cancela_credisol para Credisoluciones y sd_msi_cancela_credito_msi cuando se cancela Meses Sin intereses
				IF cNumProd_crd = '6900' THEN
					INSERT INTO "informix".sd_cancela_credisol (empresa, num_credito   , folio_movto      , fecha_cancela, motivo_de_cancelacion,tipo_promo , sucursal , fecha_insert, user_insert)
					                                   VALUES (pempresa, cCredito_promo, TRIM(pFolioMovto), CURRENT      , TRIM(cStatus)        ,cTipo_promo, pSucursal, dFecha_hoy , pUsuario);

				ELIF cNumProd_crd = '8900' THEN
					INSERT INTO bdicred:"informix".sd_msi_cancela_credito_msi 
					            (empresa , num_credito   , folio_movto      , fecha_cancela, motivo_de_cancelacion, tipo_promo , canal , sucursal , fecha_insert, user_insert)
					     VALUES (pempresa, cCredito_promo, TRIM(pFolioMovto), CURRENT   , TRIM(cStatus)           , cTipo_promo, 1     , pSucursal, dFecha_hoy  , pUsuario);				
				END IF;							 

				-- RESTAURA LINEA DE CREDITO PARA CLIENTES CON PROGRAMA: PAGOS FIJOS SALDO INMEDIATO - APOYO 2020
				IF dSdoReducido IS NULL THEN LET dSdoReducido = 0; END IF;					
				IF dFechaReducRestaurada IS NULL THEN LET dFechaReducRestaurada = date(1); END IF;
				
				IF cTipoContrato = '3' AND dSdoReducido > 0 AND dFechaReducRestaurada = date(1) THEN
				
					SELECT monto_otorgado INTO dMonto_LinOrig FROM bdicred:sd_maesdos WHERE num_credito = CSnum_credito;			
					LET dMonto_LinNva = dMonto_LinOrig + dSdoReducido;
					UPDATE bdicred:sd_maesdos SET monto_otorgado = dMonto_LinNva WHERE num_credito = CSnum_credito;

					EXECUTE PROCEDURE bdicheq:"informix".sp_generafolionomina(TRIM("informix")) INTO CodRet, cFolioSuc;
					---  Graba movimiento sd_movdia
					EXECUTE PROCEDURE GENMOV(pEmpresa, CSnum_credito, cNumProducto, 1, '008', dFecha_hoy, dSdoReducido, cFolioSuc, cSucursal, cDivisa, '6696')
					   INTO  CodRet, Mensaje;
					IF CodRet::INTEGER <> 0 THEN
						UPDATE bdicred:sd_maesdos SET monto_otorgado = dMonto_LinOrig WHERE num_credito = CSnum_credito;
					ELSE
						UPDATE "informix".sd_promocion_credito SET fecha_sdo_disp_rest = dFecha_hoy 		-- Actualiza fecha de restauracion de linea.
						 WHERE empresa = '001' AND num_sol_prestamo = cCredito_promo AND folio_movto = pFolioMovto;
						 
						-- Inserta registro en bitacora de incremento/reduccion de lineas de credito 
						INSERT INTO bdicred:sd_incremento_reduccion(empresa, tp_parametrico, numcte , num_credito  , meses_ina, bc_score, rango, linea_original, linea_nueva  , 
																	total_mov   , fecha_insert, transaccion_mov, describe_mov                       , descripcion)
															 VALUES('001',   'I'           , cNumCte, CSnum_credito, 0        , 0       , ''   , dMonto_LinOrig, dMonto_LinNva, 
																	dSdoReducido, dFecha_hoy  , '6696'         , 'INCREMENTO PAGOS-FIJOS APOYO 2020', 'Transaccion exitosa');
					END IF;	
				END IF;
				--END IF;

				IF dtFechaProxPago - dFecha_hoy = 0 THEN ----VALIDAR CUANDO ES EL MISMO DIA DEL MESIVERSARIO
					IF dIvaIntVig <> 0 THEN
						CALL "informix".sp_cargo_abono_palzo(pEmpresa,CSnum_credito,'',dIvaIntVig,USER,'9290',cTran_CargoTdc_Iva,1,cCredito_promo)
						RETURNING CodRet, Mensaje;

						IF CodRet::INTEGER <> 0 THEN
							RETURN CodRet, TRIM(Mensaje);
						ELSE
							LET CodRet = "000";
						END IF;
					END IF; 

					IF dIntVig <> 0 THEN
						CALL "informix".sp_cargo_abono_palzo(pEmpresa,CSnum_credito,'',dIntVig,USER,'9290',cTran_CargoTdc_Int,1,cCredito_promo)
						RETURNING CodRet, Mensaje;

						IF CodRet::INTEGER <> 0 THEN
						   RETURN CodRet, TRIM(Mensaje);
						ELSE
						 LET CodRet = "000";
						END IF;
					END IF;

				ELSE 
					IF dIvaIntDevengado <> 0 THEN
						CALL "informix".sp_cargo_abono_palzo(pEmpresa,CSnum_credito,'',dIvaIntDevengado,USER,'9290',cTran_CargoTdc_Iva,1,cCredito_promo)
						RETURNING CodRet, Mensaje;

						IF CodRet::INTEGER <> 0 THEN
							RETURN CodRet, TRIM(Mensaje);
						ELSE
							LET CodRet = "000";
						END IF;
					END IF;

					IF dIntDevengado <> 0 THEN
						CALL "informix".sp_cargo_abono_palzo(pEmpresa,CSnum_credito,'',dIntDevengado,USER,'9290',cTran_CargoTdc_Int,1,cCredito_promo)
						  RETURNING CodRet, Mensaje;

						  IF CodRet::INTEGER <> 0 THEN
							   RETURN CodRet, TRIM(Mensaje);
						  ELSE
							 LET CodRet = "000";
						  END IF;
					END IF;
				END IF;

				IF vcap_vig <> 0 THEN
					CALL "informix".sp_cargo_abono_palzo(pEmpresa,CSnum_credito,'',vcap_vig,USER,'9290',cTran_CargoTdc_Capital,1,cCredito_promo)
					  RETURNING CodRet, Mensaje;

					IF CodRet::INTEGER <> 0 THEN
					   RETURN CodRet, TRIM(Mensaje);
					ELSE
					 LET CodRet = "000";
					END IF;
				END IF;
			END IF;

			LET dSdoAdeudTotalAct = 0;
			LET vcap_vig = 0;
			LET dIntDevengado = 0;
			LET dIvaIntDevengado = 0;

		END FOREACH;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 OR sBand = 0 THEN
			LET CodRet = '000001';
			IF cNumProd_crd = '8900' THEN
				LET Mensaje = 'MSI NO VALIDA PARA CANCELARSE';
			ELSE
				LET Mensaje = 'CREDISOLUCION NO VALIDA PARA CANCELARSE';
			END IF;
		ELSE
			LET CodRet = '000000';
			IF cNumProd_crd = '8900' THEN
				LET Mensaje = 'MSI CANCELADA CORRECTAMENTE';
			ELSE
				LET Mensaje = 'CREDISOLUCION CANCELADA CORRECTAMENTE';			
			END IF;	
		END IF;

		RETURN CodRet, TRIM(Mensaje);
	END;
END PROCEDURE
DOCUMENT
'--------------------------------------------------------------------------------------------------------------',
'NOMBRE: Mario Olivo',
'DESCRIPCION: Se agrega parametro pFolioMovto con (DEFAULT = '') para agregar el filtro',
' 			(AND a.folio_movto = DECODE(pFolioMovto, "", a.folio_movto, pFolioMovto)) en la consulta de',
'			la tabla sd_promocion_credito.',
'			Se implementan reglas de informix.',
'			Se castea el codret por integer para compactar el codigo de retorno y entrar a las validaciones',
'FECHA DE MODIFICACION: 11/junio/2013',
'BASE DE DATOS: bdicred',
'FOLIO DE PROYECTO: 1373',
'--------------------------------------------------------------------------------------------------------------',
'Folio: 1397',
'Autor: 94912599 ',
'Fecha: 23/12/2013',
'Descripcion: Se modifica para que se cancelen las cresidol solo los que esten en la sd_param,asi como',
'que no se puedan cancelar el mismo dia, tambien se agrega un registro cada vez que se cancela una credisol',
' a la tabla sd_cancela_credisol.',
'Si folio_movto = vacio se compara el estatus de la tarjeta y si esta vencida se regresa la descripcion:',
'TARJETA VENCIDA y si no es es asi sera por default A SOLICITUD DEL CLIENTE',
'Sustento: RQM 10 214-4 Ademdum Credisoluciones Efec_Vf_cancela.doc',
'Solicita: Faviola Martinez Juarez',
'BD:BDICRED',
'--------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_consulta_pre_aprobado_apertc(canalOri SMALLINT, folioPre CHAR(14), gen1 CHAR(20), gen2 CHAR(20), gen3 CHAR(20))
RETURNING
    CHAR(5)     AS Retorno ,           -- Codigo de Retorno
    CHAR(20)    AS Solicitud ,         -- Nro de Solicitud
    CHAR(20)    AS Cliente,            -- Nro de Cliente
    CHAR(120)   AS Nombre,             -- Nombre del Cliente
    CHAR(15)    AS RFC,                -- R.F.C.
    DATE        AS Fecha_solicitud,    -- Fecha de Solicitud
    DATE        AS Fecha_Autorizacion, -- Fecha Autorizacion
    CHAR(4)     AS Producto,           -- Numero de producto
    CHAR(40)    AS NombProd,           -- Nombre Producto
    MONEY(14,2) AS Linea_Otorgada,     -- Linea Otorgada
    CHAR(2)     AS Status,             -- Status de la Solicitud
    CHAR(130)   AS Descripcion_Status, -- Descripcion del Status de la Solicitud --1757
    CHAR(255)   AS Comentario,         -- Comentario
    CHAR(2)     AS Dia_Corte,          -- Dia de Corte
    CHAR(2)     AS Divisa,             -- Divisa
    MONEY(14,2) As v,                  -- Ingreso del Cliente
    CHAR(3)     AS Causa_solicitud,    -- Causa de solicitud
    CHAR(100)   AS Descripcin_Causa,   -- DescripciÃ³n de la causa de solicitud
    INTEGER     AS vigencia,           -- Dias de vigencia de la solicitud en su ultimo estatus
    INTEGER     AS Ejecucion,
    INTEGER     AS Limite,
    SMALLINT    AS CausaSituacion,
    INTEGER     AS iEsCtaCap,
    INTEGER     AS iConsultaSP,
    INTEGER     AS vCantRegPres,
    CHAR(1)     AS SituacionEsp,        -- Valor para identificar si tiene o no cuenta de captaciÃ³n
    CHAR(20)    AS NumCuenta,           -- numero de cuenta
    INTEGER     AS FrecuenciaPago,      -- frecuencia de pago de nomina
    INTEGER     AS DiaPago,   -- dias de vigencia
    CHAR(10)    AS telefono_casa,   -- telefono de casa
    CHAR(10)    AS telefono_oficina; -- telefono de Oficina


    -- DEFINICION DE VARIABLES
    DEFINE vIdOfert INTEGER;
    DEFINE vNumProducto CHAR(4);
    DEFINE vNumCte CHAR(9);
    DEFINE vSucursal CHAR(4);
    DEFINE vGen1 CHAR(20);
    DEFINE vGen2 CHAR(20);
    DEFINE vGen3 CHAR(20);
    DEFINE vVigFolio INTEGER;
    DEFINE cValRetorno CHAR(5);    DEFINE cValRetorno2 CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE s_numsol CHAR(20);    DEFINE s_numcte CHAR(20);    DEFINE s_nombre CHAR(110);    DEFINE s_fechaaut DATE;    DEFINE  s_fechasol DATE;    DEFINE s_linea MONEY(14,2);    DEFINE s_status CHAR(2);    DEFINE s_stdesc CHAR(130);    DEFINE s_comentario CHAR(255);    DEFINE s_rfc CHAR(15);    DEFINE s_diacorte CHAR(2);    DEFINE s_divisa CHAR(2);    DEFINE s_ingreso MONEY(14,2);    DEFINE v_CausaSitEsp SMALLINT;    DEFINE vfecha_hoy DATE;
    DEFINE vdias_rt SMALLINT;
    DEFINE vdias_at SMALLINT;
    DEFINE vdias_vigencia INTEGER;    DEFINE cSitEsp CHAR(1);
	DEFINE cCausaSol CHAR(100);    DEFINE vDescCausaSol    CHAR(100);    DEFINE iEsCtaCap         INTEGER;    DEFINE s_Producto        CHAR(4);    DEFINE s_ProdDes         CHAR(40);    DEFINE s_Limit           SMALLINT;    DEFINE iejecucion        INTEGER;    DEFINE iConsultaSP       INTEGER;    DEFINE vCantRegPres      INTEGER;    --VARIABLES PARA CREDINOMINA
    DEFINE cCuenta_eje      CHAR(20);    DEFINE iFrecuencia      INTEGER;    DEFINE iDiaPago         INTEGER;    --VARIABLES DE TELEFONOS
    DEFINE cTelCasa      CHAR(10);    DEFINE cTelOficina   CHAR(10);    
    --INICIALIZACION DE VARIABLES
    LET cValRetorno      = "00000";    --LET cValRetorno2     = "00000";
    LET s_nombre         = "";    LET s_numcte         = "";    LET s_fechaaut       = "";    LET s_fechasol       = "";    LET s_status         = "";    LET s_numsol         = "";    LET s_comentario     = "";    LET s_stdesc         = "";    LET s_rfc            = "";    LET s_linea          = 0;    LET s_diacorte       = "";    LET s_divisa         = "";    LET v_CausaSitEsp    = 0;    LET vdias_vigencia   = 0;    LET s_ingreso        = 0;    LET cSitEsp          = "";    LET cCausaSol        = "";    LET vDescCausaSol    = "";    LET iEsCtaCap         = 0;    LET s_Producto        = "";    LET s_ProdDes         = "";    LET s_Limit           = 0;    LET iejecucion        = 0;    LET iConsultaSP       = 0;    LET vCantRegPres      = 0;    --VARIABLES PARA CREDINOMINA
    LET cCuenta_eje         = "";    LET iFrecuencia         = 1;    LET iDiaPago            = 0;    --VARIABLES DE TELEFONOS
    LET cTelCasa      = "";    LET cTelOficina   = "";    LET iSqlErr ='0';
    LET vIdOfert =0;
    LET vNumProducto='';
    LET vNumCte ='';
    LET vGen1 ='';
    LET vGen2 ='';
    LET vGen3 ='';

    LET vVigFolio= 0;
	
	 -- SET DEBUG FILE TO "/ifxsif01/tmp/sp_consulta_pre_aprobado_apertc.out";
	 -- TRACE ON;

   BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
            LET cValRetorno=iSqlErr;
			RETURN  cValRetorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,s_fechaaut,s_Producto,s_ProdDes,s_linea,s_status,s_stdesc,
                s_comentario,s_diacorte,s_divisa,s_ingreso,cCausaSol,vDescCausaSol,vdias_vigencia,iejecucion,s_Limit,v_CausaSitEsp,
                iEsCtaCap,iConsultaSP,vCantRegPres,cSitEsp,cCuenta_eje,iFrecuencia,iDiaPago,NVL(cTelCasa,''),NVL(cTelOficina,'');
		END IF;
	END EXCEPTION;
	


	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    --0 BUSCA PARAMETRO MAXIMO DE DIAS DE VIGENCIA DE FOLIO [vVigFolio], ESTA VALIDACIÃN SERÃ EN EL SP DE BUSQUEDA DEL FOLIO DESDE PROMOTORÃA
    LET vVigFolio=(SELECT valor::INTEGER FROM "informix".sd_pre_aprobados_param WHERE codparam=2);

    IF EXISTS(SELECT folio_preaprobado FROM "informix".sd_pre_aprobados_ctrl WHERE folio_preaprobado=folioPre AND respuesta=1) THEN

        SELECT T.numcte, T.num_producto, C.sucursal INTO vNumCte, vNumProducto, vSucursal
        FROM "informix".sd_pre_aprobados_ctrl C, "informix".sd_pre_aprobados_trx T 
        WHERE C.folio_preaprobado =T.folio_preaprobado AND T.folio_preaprobado=folioPre AND respuesta=1
        AND (today - fecha_respuesta::date) <= vVigFolio;

        --BUSCAR FOLIOS EN HISTORICA
        IF vNumProducto IS NULL THEN
            SELECT T.numcte, T.num_producto, C.sucursal INTO vNumCte, vNumProducto, vSucursal
            FROM "informix".sd_pre_aprobados_ctrl C, "informix".sd_pre_aprobados_his T 
            WHERE C.folio_preaprobado =T.folio_preaprobado AND T.folio_preaprobado=folioPre AND respuesta=1
            AND (today - fecha_respuesta::date) <= vVigFolio;        
        END IF;

        IF vNumProducto IS NOT NULL THEN

            FOREACH EXECUTE PROCEDURE bdisolic:"informix".sp_conssolicitudescredito2_mov_2(1,'001',vSucursal,0,vNumCte,'','',0,0,0, 1, 0, '', '')
                INTO cValRetorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,s_fechaaut,s_Producto,s_ProdDes,s_linea,s_status,s_stdesc,
                  s_comentario,s_diacorte,s_divisa,s_ingreso,cCausaSol,vDescCausaSol,vdias_vigencia,iejecucion,s_Limit,v_CausaSitEsp,
                  iEsCtaCap,iConsultaSP,vCantRegPres,cSitEsp,cCuenta_eje,iFrecuencia,iDiaPago,cTelCasa,cTelOficina

            IF vNumProducto = s_Producto THEN --OBTIENE SOLO EL PRODUCTO CORRESPONDIENTE AL FOLIO
                RETURN  cValRetorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,s_fechaaut,s_Producto,s_ProdDes,s_linea,s_status,s_stdesc,
                s_comentario,s_diacorte,s_divisa,s_ingreso,cCausaSol,vDescCausaSol,vdias_vigencia,iejecucion,s_Limit,v_CausaSitEsp,
                iEsCtaCap,iConsultaSP,vCantRegPres,cSitEsp,cCuenta_eje,iFrecuencia,iDiaPago,NVL(cTelCasa,''),NVL(cTelOficina,'') WITH RESUME;
            END IF;

            END FOREACH;

        ELSE
            LET cValRetorno='01262'; -- folio no estÃ¡ vigente

            --CONSIDERAR ACTUALIZAR EL ESTATUS DE SS_SOLICITUDES Y DEMAS TABLAS DE BDISOLIC

            RETURN  cValRetorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,s_fechaaut,s_Producto,s_ProdDes,s_linea,s_status,s_stdesc,
                    s_comentario,s_diacorte,s_divisa,s_ingreso,cCausaSol,vDescCausaSol,vdias_vigencia,iejecucion,s_Limit,v_CausaSitEsp,
                    iEsCtaCap,iConsultaSP,vCantRegPres,cSitEsp,cCuenta_eje,iFrecuencia,iDiaPago,NVL(cTelCasa,''),NVL(cTelOficina,'');
        END IF;
    ELSE
        LET cValRetorno='01263'; -- folio no encontrado
        RETURN  cValRetorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,s_fechaaut,s_Producto,s_ProdDes,s_linea,s_status,s_stdesc,
                s_comentario,s_diacorte,s_divisa,s_ingreso,cCausaSol,vDescCausaSol,vdias_vigencia,iejecucion,s_Limit,v_CausaSitEsp,
                iEsCtaCap,iConsultaSP,vCantRegPres,cSitEsp,cCuenta_eje,iFrecuencia,iDiaPago,NVL(cTelCasa,''),NVL(cTelOficina,'');
    END IF;
    
    END;
END PROCEDURE
DOCUMENT
'AUTOR : 90120580 - Miguel Angel Espinoza Salmoran.',
'DESCRIPCION: Credito - Consulta Clientes Pre-Aprobados (APERTC)',
'FOLIO:OneClick PreAprobados ',
'FECHA : 21-12-2021',
'VERSION: 20211221.0840',
'BD: bdicred',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_ics_compara_secuencias()
RETURNING CHAR(5) as codret, CHAR (300) as mensaje;

--Definicion de Variables
DEFINE iSqlErr INTEGER;
DEFINE iIsamError INTEGER;
DEFINE cCod_err CHAR(5);
DEFINE vsMensaje CHAR(100);

DEFINE vContador INTEGER;
DEFINE vtransaccion SMALLINT;
DEFINE vNumcte CHAR(9);
DEFINE v_num_credito CHAR(12);

DEFINE vSec_dir CHAR(9);
DEFINE vSec_tel CHAR(9);
DEFINE vSec_dir_old CHAR(9);
DEFINE vSec_tel_old CHAR(9);
DEFINE horaActual DATETIME YEAR TO FRACTION(5);
DEFINE v_proceso CHAR(20);
DEFINE vEjecucionSemanal INTEGER;
DEFINE vEjecucionMensual INTEGER;
DEFINE vDiasNoComparaSecuencia INTEGER;

--Inicializacion de Variables
LET iSqlErr = 0;
LET iIsamError = 0;
LET cCod_err = '00000';
LET vsMensaje = 'PROCESO EXITOSO';

LET vContador = 0;
LET vtransaccion = 0;
LET vNumcte = '';
LET v_num_credito = '';

LET horaActual = NULL;
LET v_proceso ='sp_ics_compara_secuencias';
LET vEjecucionSemanal=0;
LET vEjecucionMensual=0;
LET vDiasNoComparaSecuencia=0;

    --SET DEBUG FILE TO '/RESPALDOSNEW/noe/ics/sp_ics_compara_secuencias.out';
    --TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr,iIsamError,vsMensaje
		SET DEBUG FILE TO '/RESPALDOSNEW/sp_ics_compara_secuencias.out';
		TRACE ON;

		SELECT DBINFO("utc_to_datetime", sh_curtime)
			INTO horaActual
		FROM sysmaster:sysshmvals;

		INSERT INTO "informix".ics_control_errores(num_credito, numcte, num_producto, descripcion_error, proceso, fecha_insert)
		VALUES(v_num_credito, vNumcte, '', iSqlErr, v_proceso, horaActual);

		IF iSqlErr <> 0 THEN
			LET cCod_err = iSqlErr;
			RETURN cCod_err, trim(vsMensaje);
		END IF;

	END EXCEPTION;

	ON EXCEPTION IN (-535)
        LET vtransaccion = 1;
    END EXCEPTION WITH RESUME;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	SELECT valor::INTEGER dias INTO vDiasNoComparaSecuencia FROM "informix".ics_parametros WHERE cod_param=2;

--COMPARA SECUENCIAS DE TELEFONO Y DIRECCION
	LET v_proceso ='INICIO COMPARA SECUENCIAS';

	SELECT DBINFO("utc_to_datetime", sh_curtime)
		INTO horaActual
	FROM sysmaster:sysshmvals;
	INSERT INTO ics_tiempos (num_registro, hora, proceso) VALUES (0, horaActual, v_proceso);

	BEGIN WORK;

	--FOREACH vCursor WITH HOLD FOR SELECT numcte, nvl(secuencia_telefono,'0'), nvl(secuencia_direccion,'0')
	FOREACH WITH HOLD SELECT DISTINCT numcte, nvl(secuencia_telefono,'0'), nvl(secuencia_direccion,'0')
		INTO vNumcte, vSec_tel_old, vSec_dir_old
		FROM "informix".ics_maectrl WHERE activo_ics and enviado_ics and (((today - fecha_act_secuencia_telefono) > vDiasNoComparaSecuencia)
														OR ((today - fecha_act_secuencia_direccion) > vDiasNoComparaSecuencia))

		SELECT nvl(sum(case when tipo_dir='1' then secuencia else 0 end)
		|| sum(case when tipo_dir='2' then secuencia else 0 end)
		|| sum(case when tipo_dir='3' then secuencia else 0 end),'0') sec_dir INTO vSec_dir
		FROM bdinteg:"informix".si_direcciones_actual  where numcte=vNumcte;

		SELECT nvl(sum(case when tipo_tel='1' then secuencia else 0 end)
		|| sum(case when tipo_tel='2' then secuencia else 0 end)
		|| sum(case when tipo_tel='3' then secuencia else 0 end),'0') sec_tel INTO vSec_tel
		FROM bdinteg:"informix".si_telefonos_actual where numcte=vNumcte and tipo_tel in('1','2','3') and status_tel='A';

		IF (TRIM(vSec_tel_old) <> TRIM(vSec_tel)) OR (TRIM(vSec_dir_old) <> TRIM(vSec_dir)) THEN

			IF (TRIM(vSec_tel_old) <> TRIM(vSec_tel)) AND (TRIM(vSec_dir_old) <> TRIM(vSec_dir)) THEN
				UPDATE "informix".ics_maectrl
				SET secuencia_telefono = TRIM(vSec_tel)
					, secuencia_direccion = TRIM(vSec_dir)
					, fecha_act_secuencia_telefono = TODAY
					, fecha_act_secuencia_direccion = TODAY
					, enviado_ics = 'f'
				--WHERE CURRENT OF vCursor;
				WHERE numcte = vNumcte;
			END IF;

			IF (TRIM(vSec_tel_old) = TRIM(vSec_tel)) AND (TRIM(vSec_dir_old) <> TRIM(vSec_dir)) THEN
				UPDATE "informix".ics_maectrl
				SET secuencia_direccion = TRIM(vSec_dir)
					, fecha_act_secuencia_direccion = TODAY
					, enviado_ics = 'f'
				--WHERE CURRENT OF vCursor;
				WHERE numcte = vNumcte;
			END IF;

			IF (TRIM(vSec_tel_old) <> TRIM(vSec_tel)) AND (TRIM(vSec_dir_old) = TRIM(vSec_dir)) THEN
				UPDATE "informix".ics_maectrl
				SET secuencia_telefono = TRIM(vSec_tel)
					, fecha_act_secuencia_telefono = TODAY
					, enviado_ics = 'f'
				--WHERE CURRENT OF vCursor;
				WHERE numcte = vNumcte;
			END IF;

			IF vContador >= 5000 THEN
				COMMIT WORK;
				LET vContador = 0;
				BEGIN WORK;
			END IF;

		END IF;

	END FOREACH;

	IF vContador < 5000 THEN
		COMMIT WORK;
		LET vContador = 0;
	END IF;

--REGISTRA FIN EN BITACORA
	LET v_proceso ='FIN COMPARA SECUENCIAS';

	SELECT DBINFO("utc_to_datetime", sh_curtime)
		INTO horaActual
	FROM sysmaster:sysshmvals;
	INSERT INTO ics_tiempos (num_registro, hora, proceso) VALUES (0, horaActual, v_proceso);

	RETURN cCod_err, TRIM(vsMensaje);

END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Compara secuencias de Telefonos y Direcciones en tabla de control de iCS',
'AUTOR : Noe Medina',
'FECHA : 22 Junio 2022',
'VERSION: 1.0';

CREATE PROCEDURE "informix".sp_buscarctesamigrar(pnumcte CHAR(20),iOpcion INTEGER, pSucursal CHAR(4), pNombreEmbozado CHAR(60), pNumEjecutivo CHAR(8))
RETURNING	 CHAR(6), --Codigo Retorno
             CHAR(20), --Numero de Cliente
			 CHAR(20), --Numero de Credito
			 CHAR(60), --Direccion de la sucursal
			 CHAR(4), --Sucursal
			 CHAR(1), -- Bandera Verifica Estatus
			 CHAR(20),--Descripcion Estatus
			 CHAR(20),-- Fecha de solicitud
			 CHAR(10),--MONTO LINEA
			 CHAR(10),--IVA
			 CHAR(10),--INTERES MORATORIO
			 CHAR(10),--INTERES ORDINARIO
			 CHAR(6),--BIN
			 CHAR(8),--CODIGO DEL PRODUCTO
			 CHAR(8); --CLAVE TAJETA
			
             										 
DEFINE iSqlerr				INTEGER;
DEFINE iExiste				INTEGER;
DEFINE cCodret				CHAR(6);
DEFINE cCliente     		CHAR(20);
DEFINE cSucursal    		CHAR(20);
DEFINE iFlagstatus  		CHAR(1);
DEFINE cStatus      		CHAR(20);
DEFINE cFchsoli     		CHAR(20);
DEFINE cNomSuc      		CHAR(60);
DEFINE cLineaCredito 		CHAR(10);
DEFINE cCat          		CHAR(10);
DEFINE cInteresOrdinario 	CHAR(10);
DEFINE cInteresMoratorio 	CHAR(10);
DEFINE cCodBin      		CHAR(6);
DEFINE cCodProd 			CHAR(8);
DEFINE cCodClaveTar 		CHAR(8);
DEFINE cNumCredito 			CHAR(20);
DEFINE cDireccionSucursal 	CHAR(80);
DEFINE cSolOro 				VARCHAR(20);
DEFINE cLineaTeorica 		DECIMAL(18,2);
DEFINE v_valor		 		MONEY(14,2);
DEFINE v_capacidad_pago 	MONEY(14,2);
DEFINE iPlazo 				INTEGER; 
DEFINE sNombreCliente 		CHAR(100);
DEFINE sNumTarjeta			CHAR(16);
DEFINE sMiembro				CHAR(2);
DEFINE sCodRetOro           CHAR(6);
DEFINE sMsjRetOro           VARCHAR(100);

LET sCodRetOro              = '';
LET sMsjRetOro              = '';
--INICIALIZANDO VARIABLES
LET iSqlerr    			= 0;
LET iExiste	   			= 0;
LET cCodret    			= "000000";
LET cCliente  	 		= "";
LET iFlagstatus			= "";
LET cStatus    			= "";
LET cFchsoli   			= "";
LET cSucursal  			= "";
LET cNomSuc    			= "";
LET cLineaCredito		= "";
LET cCat                = "";
LET cInteresOrdinario	= "";
LET cInteresMoratorio	= "";
LET cCodBin				= "";
LET cCodProd			= "";
LET cCodClaveTar		= "";
LET cNumCredito 		= "";
LET cDireccionSucursal 	= "";
LET cSolOro 			= "";
LET cLineaTeorica 		= "";
LET v_valor		  		= 0;
LET v_capacidad_pago 	= 0;
LET iPlazo 		  		= 0;
LET sNombreCliente		= "";
LET sNumTarjeta			= "";
LET sMiembro			= "";


BEGIN
	ON EXCEPTION SET iSqlerr
		IF iSqlerr <> 0 THEN
			LET cCodret = iSqlerr;
			RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/home/sysifx/Oscar/736/sp_buscarctesamigrar.out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF pnumcte IS NULL OR pnumcte = '' OR iOpcion is NULL  THEN
		LET cCodret="000100";
		RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
	END IF;
	

	SELECT numcte,num_credito,nomsuc,sucursal,flagstatussol,status,fchsoli 
	INTO cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli
	FROM bdicred:"informix".sd_ctesamigrar WHERE numcte = TRIM(pnumcte);
   
	IF iOpcion=0  THEN
		IF DBINFO("sqlca.sqlerrd2") = '0' THEN -- No existe el cliente
			LET cCodret="000001";
			RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
		ELSE
			IF (iFlagstatus IS NULL OR iFlagstatus='' OR iFlagstatus=3) THEN
				RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
			END IF;
		END IF;
	END IF;
	
	IF iOpcion=1  THEN -- Solicitud Rechazada
		IF NVL(pSucursal,'') = '' THEN
			LET cCodret="000100";
		ELSE
			SELECT TRIM(suc.nombre), (TRIM(suc.direccion1) || ", " || TRIM(suc.direccion2) || ", " || TRIM(ciu.nombre) || ", " || TRIM(est.nombre)) As Direccion 
			INTO cNomSuc,cDireccionSucursal
			FROM bdinteg: "informix".si_sucursales suc
			INNER JOIN bdinteg: "informix".si_estados est
			ON est.estado = suc.estado
			INNER JOIN bdinteg: "informix".si_ciudades ciu
			ON suc.ciudad = ciu.ciudad and suc.estado = ciu.estado
			WHERE  suc.empresa = '001'
			AND sucursal = pSucursal
			AND suc.tpo_sucursal = 'S';
			
			UPDATE  bdicred:"informix".sd_ctesamigrar SET  flagstatussol='3',status="Rechazada",fchsoli=TO_CHAR(current), sucursal = pSucursal, nomsuc =  cNomSuc, domsuc = TRIM(cDireccionSucursal) WHERE numcte=pnumcte;
		END IF;
		RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
	END IF;
   
	IF iOpcion=2 THEN -- Solicitud Aceptada
		IF NVL(pSucursal, '') = '' OR NVL(pNombreEmbozado,'') = '' OR NVL(pNumEjecutivo,'') = '' THEN
			LET cCodret="000100";
		ELSE
			SELECT TRIM(suc.nombre), (TRIM(suc.direccion1) || ", " || TRIM(suc.direccion2) || ", " || TRIM(ciu.nombre) || ", " || TRIM(est.nombre)) As Direccion 
			INTO cNomSuc,cDireccionSucursal
			FROM bdinteg: "informix".si_sucursales suc
			INNER JOIN bdinteg: "informix".si_estados est
			ON est.estado = suc.estado
			INNER JOIN bdinteg: "informix".si_ciudades ciu
			ON suc.ciudad = ciu.ciudad and suc.estado = ciu.estado
			WHERE  suc.empresa = '001'
			AND sucursal = pSucursal
			AND suc.tpo_sucursal = 'S';			
			
			SELECT TRIM(apell_paterno) || " " || TRIM(apell_materno) || " " || TRIM(nombre1) || " " || TRIM(nombre2) AS Nombre, b.num_tarjeta , SUBSTR(YEAR(c.fecha_apertura),3,2)
			INTO sNombreCliente, sNumTarjeta, sMiembro
			FROM bdicred:"informix".sd_ctesamigrar a			
			INNER JOIN bdicred:"informix".sd_tarjeta b ON a.num_credito = b.num_credito
			INNER JOIN bdicred:"informix".sd_maecred c ON c.num_credito = a.num_credito
			WHERE a.numcte = pnumcte 
			AND a.num_credito = cNumCredito 
			AND b.numcte = a.numcte
			AND c.numcte = b.numcte
			AND b.status_tar = 'A';
			
			UPDATE  bdicred:"informix".sd_ctesamigrar SET  flagstatussol = '1',status = "Aceptada", fchsoli = TO_CHAR(current), sucursal = pSucursal, nomsuc =  cNomSuc, domsuc = TRIM(cDireccionSucursal) 
			WHERE numcte = pnumcte;
			
			LET sNombreCliente = REPLACE(sNombreCliente,"  ", " ");
			
			--INSERT INTO bdicred:"informix".sd_credito_upgrade(empresa, num_credito, numcte, numerotarjeta, numero_credito_upgrade, numerotarjeta_upgrade, num_producto_upgrade, tipotar, nombre, nombre_embosado, bandtarjpersonal, tipo_proceso, nombre_archivo, master, tipo_dom, miembro, resultado, bclonadocompleto, user_insert, fecha_insert, fecha_cancelaupgrade)
			--VALUES('001', cNumCredito, pnumcte, sNumTarjeta, '', '', '8100', 'TIT', TRIM(sNombreCliente), TRIM(pNombreEmbozado), '1', '1', '', '1', '1', sMiembro, '0', '0', pNumEjecutivo,CURRENT,NULL);

            EXECUTE PROCEDURE "informix".sp_graba_prod_upgrade('001', cNumCredito, pnumcte, sNumTarjeta, 'TIT', TRIM(sNombreCliente), 
             TRIM(pNombreEmbozado), '1', '1', pNumEjecutivo, '3', '', '8100') INTO sCodRetOro, sMsjRetOro;
		END IF;		
		RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
	END IF;
  
	IF iOpcion=3 THEN
		RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
	END IF;
  
	IF iOpcion=4 THEN
	  --SE OBTIENE EL VALOR DE LA TASA DE INTERES ORDINARIO
	  SELECT a.valor,b.cat_caratula,b.monto_min_cred INTO cInteresOrdinario,Ccat,cLineaCredito
	  FROM bdinteg:"informix".si_fechavalor AS a,bdicred:"informix".sd_definicion AS b
	  WHERE a.tasa = b.cod_tasa_base AND fecha = (SELECT MAX(fecha)
	  FROM bdinteg:"informix".si_fechavalor
	  WHERE  tasa=b.cod_tasa_base    --
	  AND b.num_producto = '8100');

	--SE OBTIENE EL VALOR DE LA TASA DE INTERES MORATORIO
	  SELECT a.valor INTO cInteresMoratorio
	  FROM bdinteg:"informix".si_fechavalor AS a, bdicred:"informix".sd_definicion AS b
	  WHERE a.tasa = b.cod_tasa_mora AND fecha = (SELECT MAX(fecha)
	  FROM bdinteg:"informix".si_fechavalor 
	  WHERE  tasa=b.cod_tasa_mora AND b.num_producto = '8100');  -- FMV 13-MAY-11 SE OMITE a.tasa para mostrar las tasas en reporte
	  LET cInteresMoratorio = cInteresMoratorio - cInteresOrdinario;
		IF cInteresMoratorio < 0 THEN
				LET cInteresMoratorio= cInteresMoratorio * -1;
		END IF;
	RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
	END IF;
 
	IF iOpcion=5 THEN
		SELECT codproductotarjeta,clave_tipotarjeta,bin  
		INTO cCodProd,cCodClaveTar,cCodBin 
		FROM intercard:"informix".tipotarjeta 
		WHERE codproductotarjeta = '005'
		AND Tipo = 'C'
		AND clave = '007';
		
		RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
	END IF;
	
	IF iOpcion = 6 THEN
		IF NVL(pnumcte,'') = '' THEN
			LET cCodret="000100";
		ELSE
			DELETE bdicred:"informix".sd_credito_upgrade WHERE numcte = pnumcte AND num_credito = cNumCredito;		
			UPDATE bdicred:"informix".sd_ctesamigrar SET sucursal = '',nomsuc = '',domsuc = '',flagstatussol = null,status = '',fchsoli = '' WHERE numcte = pnumcte;
			RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
		END IF;
	END IF;
	
  
END;
END PROCEDURE
DOCUMENT
'Se crea SP para consultar los  de clientes candidatos a actualizar su Tarjeta de Credito Visa Bancoppel a Tarjeta de Credito Oro Bancoppel',
'asi como actualizar su estatus (Aceptada, Rechazada) e insertar la solicitud.',
'AUTOR : Oscar Marquez 98681011',
'FECHA : 26/03/2021',
'BD    : BDICRED';

create procedure "informix".sp_rep_regulatorios_irb_compl(pEmpresa char(03))
returning 
          char(06) as resultado,
          char(80) as mensaje;

--************************ Definicion de variables *****************************
DEFINE cMensajeRet, cMensajeRet2     CHAR(80);

define iCodRet              integer;
define SCodRet              char(06);
define cSql                 char(5000);
define vfecha_hoy           DATE;
define cont                 integer;
define vFecha_proceso       DATE;
define vhora_inicio         char(8);
define vhora_fin            char(8);
define vstatus_proceso      char(2);
define NombreArchivo        char(50);
define NombreArchivoCifras  char(50);
define FechaReporte         date;
define PrimerDiaMes         date;
define UltimoDiaMes         date;
define vDia,v_mes_corte     char(2);
define vMes,v_mes_appdate   char(2);
define vAnio                char(4);

define cNumCliente          char(20);
define cNumCredito          char(20);
define cauxNumCredito          char(20);
define dFechaApertura       date;
define sMesesVencidos       smallint;
define cStatusCredito       char(02);
define dPagoMinimo          dec(18,2);
define dSaldoCorte          dec(18,2);
define dSdoDisponible       dec(18,2);
define dFechaLimitePago     date;
define dFechaCorte          date;
define dPagosPAYMENTS       dec(18,2);
define dComprasPURCHASES    dec(18,2);
define dDispWITHDRAWALS     dec(18,2);
define dIntereses           dec(18,2);
define dMOB                 dec(18,2);
define dLimiteCredito       dec(18,2);
define dTasa                dec(9,6);
define v_tasa               dec(5,2);
define dFecha               date;
define dSdoCorteAnt         dec(18,2);
define dIva                 dec(18,2);
define iNumDispCASHATM      dec(18,2);
define iNumPagosPAYMENTS    dec(18,2);
define iNumCompPURCHASES    dec(18,2);
define iImpComisiones       dec(18,2);
define dFechaIni            date;

define cApplicationId      char(20);
define cApplicationDate    char(08);
define cApplicationStatus  char(02);
define dRequestedAmount    decimal(18,2);
define cTerm               char(01);
define cDownPayment        char(10);
define cPostalCode         char(05);
define cPostalCode4        char(05);
define cLastName           char(50);
define cFirstName          char(50);
define cMiddleName         char(50);
define cNameSuffix         char(01);
define cCharacterBlanks    char(01);
define cHouseNumber        char(10);
define cNombreZona         char(50);
define cThoroughfareName   char(50);
define cThoroughfareType   char(01);
define cApartmentNumber    char(10);
define cCityName           char(50);
define cGender             char(06);
define cAge                char(03);
define cJobType            char(50);
define cTelephone          char(15);
define cPresenceCknSvn     char(01);
define cTimeResidence      char(03);
define cTimeJob            char(03);
define dMonthlyIncome      decimal(18,2);
define dMonthlyExpense     char(12);   
define cNumberDependents   char(03);
define cNumberPeopleHouse  char(03);
define cYearlyHouseIncome  char(10);
define cNumberDebtObli     char(03);
define cNumberPrevLoansBank char(02);
define cState               char(50);
define cTypeResidence	   char(15);
define sYearsCreditExp	   smallint;
define cnumerociudad	   smallint;

define v_term, v_name_suffix, v_character_blanks, v_presence_ckn_svn, v_thoroughfare_type                char(01);
define v_application_status, v_number_prev_loans_bank                                                    char(02);
define v_age, v_time_residence,v_time_job,v_number_dependents,v_number_people_house, v_number_debt_obli  char(03);
define v_postal_code, v_postal_code4                                                                     char(05);
define v_gender                                                                                          char(06);
define v_application_date                                                                                char(08);
define v_down_payment, v_apartment_number, v_house_number, v_yearly_house_income                         char(10);
define v_monthly_expense                                                                                 char(12);
define v_type_residence, v_telephone                                                                     char(15);
define v_application_id                                                                                  char(20);
define v_last_name, v_first_name, v_middle_name, v_nombrezona, v_thoroughfare_name, v_city_name, v_state char(50);
define v_job_type                                                                                        char(50);
define v_monthly_income, v_requested_amount                                                              decimal(18,2);
define v_years_credit_exp                                                                                smallint;

define v_status_credito                                                                                  char(15);
define v_numcte, v_num_credito                                                                           char(20);
define v_fecha_apertura, v_fecha_limite_pago, v_fecha_corte                                              date;
define v_meses_vencidos, v_pago_minimo, v_saldo_corte, v_sdo_disponible, v_sdo_corte_anterior, v_pagos_PAYMENTS, v_compras_PURCHASES  decimal(18,2);
define v_disposiciones_WITHDRAWALS, v_intereses, v_iva, v_rendimientos, v_comisiones, v_MOB, v_limite_credito                         decimal(18,2);
define v_numero_disposiciones_CASH_ATM, v_numero_pagos_PAYMENTS, v_numero_compras_PURCHASES              integer;

define vNumproceso            char(4);                  
define vCurrent, vCurrent2    char(25);
define vdia2                  date; 
define vhora, vhora2          char(8);
define vHora3                 char(22);
define v_fecha_emision        date;  
define v_num_solicitud        char(20);
define v_fecha_insert, v_fecha_nac, v_fechacorte_actual, v_fecha_finmesant         date;
define cNumCte          char(20);
define dMesesVencidos   decimal(18,2);
define dDisposicionesWithdrawals decimal(18,2);
define dFechaEmision      date;
define dSdoCorteAnterior decimal(18,2);
define iNumeroDisposicionesCashATM integer;
define iNumeroPagosPayments integer;
define iNumeroComprasPurchases integer;
define dComisiones      decimal(18,2);
define dRendimientos    decimal(18,2);
define vFechaappdate    date;

let vNumproceso    = '0054';
let v_term         = '';   let v_name_suffix       = '';  let v_character_blanks    = '';   let v_presence_ckn_svn = '';   let v_thoroughfare_type = '';
let v_mes_corte    = '';   let v_age               = '';  let v_time_residence      = '';   let v_number_debt_obli = '';   let v_postal_code       = '';
let v_time_job     = '';   let v_number_dependents = '';  let v_number_people_house = '';   let v_telephone        = '';   let v_nombrezona        = '';  
let v_gender       = '';   let v_application_date  = '';  let v_down_payment        = '';   let v_apartment_number = '';   let v_type_residence    = '';
let v_house_number = '';   let v_monthly_expense   = '';  let v_first_name          = '';   let v_middle_name      = '';   let v_last_name         =  '';                  
let v_city_name    = '';   let v_state             = '';  let v_job_type            = '';   let v_status_credito   = '';   let v_years_credit_exp  = 0;              
let v_postal_code4 = '';   let v_application_id    = '';  let v_compras_PURCHASES   = 0;    let v_intereses        = 0;    let v_saldo_corte       = 0;
let v_numcte       = '';   let v_num_credito       = '';  let v_meses_vencidos      = 0;    let v_pago_minimo      = 0;    let v_iva               = 0;                           
let v_rendimientos = 0;    let v_comisiones        = 0;   let v_MOB                 = 0;    let v_limite_credito   = 0;    let vHora3              = ''; 
let vCurrent       = '';   let vCurrent2           = '';  let vhora                 = '';   let vhora2             = '';   let cMensajeRet2        = ''; 
let cNumCte        = '';   let dMesesVencidos      = 0;   let v_sdo_disponible      = 0;    let v_monthly_income   = 0;    let dComisiones         = 0; 
let dRendimientos  = 0;    let v_mes_appdate       = '';  let dSdoCorteAnterior     = 0;    
let v_yearly_house_income           = '';   let dDisposicionesWithdrawals = 0;    let v_application_status        = '';  
let v_sdo_corte_anterior            = 0;    let v_pagos_PAYMENTS          = 0;    let v_disposiciones_WITHDRAWALS = 0;
let v_numero_disposiciones_CASH_ATM = 0;    let v_numero_pagos_PAYMENTS   = 0;    let v_numero_compras_PURCHASES  = 0;
let v_requested_amount              = 0;    let iNumeroPagosPayments      = 0;    let iNumeroDisposicionesCashATM = 0;
let v_number_prev_loans_bank        = '';   let iNumeroComprasPurchases   = 0;    let v_thoroughfare_name         = '';                                                                                    
let v_fecha_apertura  = date(1);  let v_fecha_limite_pago = date(1);  let v_fechacorte_actual = date(1);
let v_fecha_finmesant = date(1);  let dFechaEmision       = date(0);  let vdia2               = date(1); 
let v_fecha_emision   = date(1);  let v_fecha_nac         = date(1);  let v_fecha_insert      = date(1);
let v_fecha_corte     = date(1);
let vFechaappdate     = date(1);
  


--********************** Inicializacion de variables ***************************
let cMensajeRet = 'El proceso de REPORTES IRB_COMPL se realizó correctamente';
let iCodRet                 = 0;
let SCodRet                 = '000000';
let cont                    = 1;
let cSql                    = '';
let vFecha_proceso          = date(0);
let vhora_inicio            = '';
let vhora_fin               = '';
let vstatus_proceso         = '';
let NombreArchivo           = '';
let NombreArchivoCifras     = '';
let vDia                    = '';
let vMes                    = '';
let vAnio                   = '';

let cNumCliente          = '';
let cNumCredito          = '';
let cauxNumCredito       = '';
let dFechaApertura       = date(0);
let sMesesVencidos       = 0;
let cStatusCredito       = '';
let dPagoMinimo          = 0;
let dSaldoCorte          = 0;
let dSdoDisponible       = 0;
let dFechaLimitePago     = date(0);
let dFechaCorte          = date(0);
let dPagosPAYMENTS       = 0;
let dComprasPURCHASES    = 0;
let dDispWITHDRAWALS     = 0;
let dIntereses           = 0;
let dMOB                 = 0;
let dLimiteCredito       = 0;
let dTasa                = 0;
let dFecha               = date(0);
let dSdoCorteAnt         = 0;
let dIva                 = 0;
let iNumDispCASHATM      = 0;
let iNumPagosPAYMENTS    = 0;
let iNumCompPURCHASES    = 0;
let iImpComisiones       = 0;
let dFechaIni            = date(0);

let cApplicationId      = '';
let cApplicationDate    = '';
let cApplicationStatus  = '';
let dRequestedAmount    = 0;
let cTerm               = '';
let cDownPayment        = '';
let cPostalCode         = '';
let cPostalCode4        = '';
let cLastName           = '';
let cFirstName          = '';
let cMiddleName         = '';
let cNameSuffix         = '';
let cCharacterBlanks    = '';
let cHouseNumber        = '';
let cNombreZona         = '';
let cThoroughfareName   = '';
let cThoroughfareType   = '';
let cApartmentNumber    = '';
let cCityName           = '';
let cGender             = '';
let cAge                = '';
let cJobType            = '';
let cTelephone          = '';
let cPresenceCknSvn     = '';
let cTimeResidence      = '';
let cTimeJob            = '';
let dMonthlyIncome      = '';
let dMonthlyExpense     = '';
let cNumberDependents   = '';
let cNumberPeopleHouse  = '';
let cYearlyHouseIncome  = '';
let cNumberDebtObli     = '';
let cNumberPrevLoansBank = '';
let cState		= '';
let cTypeResidence	= '';
let sYearsCreditExp	= 0;
let cnumerociudad = 0;
let v_tasa = 0;

--**************************** Control de errores ******************************
begin
    on exception set iCodRet
	if iCodRet <> 0 then
--            execute procedure sp_obtener_hora() into vhora_fin;
        	let SCodRet = iCodRet;
--            let cMensajeRet ='Error al generar los REPORTES IRB_COMPL >> '||NombreArchivo;
            let cMensajeRet ='Error al generar los REPORTES IRB_COMPL >> '||cauxNumCredito;
			
            update bdicred:sd_param
               set valor = cont
             where empresa = pEmpresa and cod_param = '078';
             
              	
			return SCodRet,cMensajeRet ;
        end if;
    end exception;

-- Set debug file to "/RESPALDOSNEW/mbucio/sp_rep_regulatorios_irb_complMIB032.trc";
--  trace on;



--*******************a******** Programa principal *******************************
    -- obtener la hora que inicio la ejecucion el proceso
    --execute procedure sp_obtener_hora() into vhora_inicio;
 
    -- obtener la fecha de hoy
    select fecha_hoy,pri_dia_mes into vfecha_hoy,FechaReporte from bdicred:sd_fechas where empresa = pEmpresa;

/*
    --obtener la fecha en la que se realizara la ejecucucion.
    select fecha_proceso, status_proceso
      into vFecha_proceso, vstatus_proceso
      from bdicred:sd_control_procesos where empresa = pEmpresa and
           cod_proceso = 'CrearReportesIBR';

    if (vFecha_prox_proceso != vfecha_hoy) then
        return 'Hoy no se ejecuta el proceso "sp_crear_reportes_IBR()"';
    end if;
 
    -- checar si hoy ya se ejecuto y si finalizo correctamente
    if (vFecha_proceso=vfecha_hoy) then
        if(vstatus_proceso='F') then
            return 'El proceso "sp_crear_reportes_IBR()" ' ||
                   ' ya fue ejecutado hoy y finalizado con exito';
        end if;
        -- checar si se esta esjecutando el proceso
        if(vstatus_proceso='I') then
            return 'El proceso "sp_crear_reportes_IBR()" esta en ejecucion';
        end if;
    end if;

    -- checar si hoy se ejecuta
    --IF vFecha_prox_proceso=vfecha_hoy then

    -- actualizar el control proceso
        UPDATE bdicred:sd_control_procesos
               SET hora_inicio = vhora_inicio,
                   status_proceso = 'I',
                   fecha_proceso = vfecha_hoy,
                   mensaje = 'Proceso "sp_crear_reportes_IBR" en ejecusion'
             where cod_proceso = 'CrearReportesIBR';

    -- obtiene el numero de reporte con el que inicializara
    select parametros into cont
    from bdicred:sd_control_procesos where empresa = pEmpresa and
         cod_proceso = 'CrearReportesIBR';
*/

-- obtener el ultimo reporte generado.
  select trim(valor) into cont from bdicred:sd_param where cod_param = '078';

    if cont is null or cont = '' then
       let SCodRet = '000010';
       let cMensajeRet = 'No se encuentra el valor del número de reporte a ejecutar para IRB_COMPL.';
       return SCodRet,cMensajeRet ;
    elif cont < 1 or cont >=6 then
       let SCodRet = '000020';
       let cMensajeRet = 'El valor del número de reporte a ejecutar para IRB_COMPL no es válido.';
    end if;

--obtener los rangos de fechas para el mes del reporte en cuestion
    let PrimerDiaMes = FechaReporte - 1 units month;
    let UltimoDiaMes = FechaReporte - 1 units day;
    
    
-- obtener por separado el dia, mes y año de la fecha en cuestion para el nombre del archivo
    let vDia = lpad(day(UltimoDiaMes),2,'0');
    let vMes = lpad(month(UltimoDiaMes),2,'0');
    let vAnio = lpad(year(UltimoDiaMes),4,'0');

    LET v_fecha_finmesant = FechaReporte -1 UNITS day;
    LET v_fechacorte_actual = mdy(month(v_fecha_finmesant),20,year(v_fecha_finmesant));
         
 
 
    if(cont=1) then
-- crea el reporte payment_hist del RQM 07 044
-- Tarda 9 min aprox.
        
        let NombreArchivo = trim('PaymentHist_' || trim(vdia) || trim(vMes) || trim(vAnio) || '.txt');
        
        /*let cSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/archivoscartera/' || trim(NombreArchivo) ||
          ' DELIMITER ' || '''|'''  || ' select ' || 
          ' a.num_credito application_id,' ||
          ' a.fecha record_date,' ||
          ' b.status_cred status,' ||
          ' a.sdo_cap_insoluto saldo,' ||
          ' a.sdo_capital saldo_vigente,' ||
          ' a.mto_venc_trasp saldo_vdo_ex,' ||
          ' a.cap_tras_no_venci saldo_vdo_no_ex,' ||
          ' a.monto_vencido + a.mto_venc_trasp + a.cap_tras_no_venci saldo_vencido,' ||
          ' nvl(a.mto_fin_ven_trasp,0) delinquency_status,' ||
          ' b.fecha_apertura fecha_salida,' ||
          ' a.monto_otorgado linea_de_credito, ' ||
		  ' (select interes_pago_total_tc from bdicred@pld_tcp:sd_encabezado2_edocta where fecha_emision = mdy('||vMes||',20,'||vAnio||') - 1 units month and num_credito = a.num_credito) ' ||
		  ' saldo_a_pagar, ' ||
		  ' c.menos_abonos pago_realizado, ' ||
		  ' case when ' ||
		  ' (select interes_pago_total_tc from bdicred@pld_tcp:sd_encabezado2_edocta where fecha_emision = mdy('||vMes||',20,'||vAnio||') - 1 units month and num_credito = a.num_credito) <= 0 and c.menos_abonos = 0 then ''I'' else ' ||
		  ' case when (select interes_pago_total_tc from bdicred@pld_tcp:sd_encabezado2_edocta where fecha_emision = mdy('||vMes||',20,'||vAnio||') - 1 units month and num_credito = a.num_credito) = 0 and c.menos_abonos > 0 then ''T'' else ''N'' end end ' ||
      ' status_pago_cliente ' ||
          ' from bdicred:sd_maesdoscont a ' ||
          ' join bdicred:sd_maecredcont b on b.empresa = a.empresa and b.num_credito = a.num_credito and b.fecha = a.fecha ' ||
          ' left outer join bdicred@pld_tcp:sd_encabezado2_edocta c on c.fecha_emision = mdy('||vMes||',20,'||vAnio||') and c.num_credito = a.num_credito ' ||
          ' where a.fecha = ''' || UltimoDiaMes || ''' ' ||
          ' and a.empresa = ''' || pEmpresa || ''' ' ||
          ' and a.num_credito > ''600000000000'' ' ||
          ' and b.campo_trab3 <> ''BAJA'';"' ||
          ' > /resplogifx/archivoscartera/QueryPayMenthist.sql'; */
        
        let cSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/archivoscartera/' || trim(NombreArchivo) ||
          ' DELIMITER ' || '''|'''  || ' select ' || 
          ' a.num_credito application_id,' ||
          ' a.fecha record_date,' ||
          ' b.status_cred status,' ||
          ' a.sdo_cap_insoluto saldo,' ||
          ' a.sdo_capital saldo_vigente,' ||
          ' a.mto_venc_trasp saldo_vdo_ex,' ||
          ' a.cap_tras_no_venci saldo_vdo_no_ex,' ||
          ' a.monto_vencido + a.mto_venc_trasp + a.cap_tras_no_venci saldo_vencido,' ||
          ' nvl(a.mto_fin_ven_trasp,0) delinquency_status,' ||
          ' b.fecha_apertura fecha_salida,' ||
          ' a.monto_otorgado linea_de_credito, ' ||
          ' (select interes_pago_total_tc from bdicred:sd_info_edocta where fecha_emision = mdy('||vMes||',20,'||vAnio||') - 1 units month and num_credito = a.num_credito) ' ||
		    --' (select interes_pago_total_tc from bdicred@pld_tcp:sd_encabezado2_edocta where fecha_emision = mdy('||vMes||',20,'||vAnio||') - 1 units month and num_credito = a.num_credito) ' ||
		      ' saldo_a_pagar, ' ||
		      ' c.menos_abonos pago_realizado, ' ||
		      ' case when ' ||
		      ' (select interes_pago_total_tc from bdicred:sd_info_edocta where fecha_emision = mdy('||vMes||',20,'||vAnio||') - 1 units month and num_credito = a.num_credito) <= 0 and c.menos_abonos = 0 then ''I'' else ' ||
       -- ' (select interes_pago_total_tc from bdicred@pld_tcp:sd_encabezado2_edocta where fecha_emision = mdy('||vMes||',20,'||vAnio||') - 1 units month and num_credito = a.num_credito) <= 0 and c.menos_abonos = 0 then ''I'' else ' ||
		      ' case when (select interes_pago_total_tc from bdicred:sd_info_edocta where fecha_emision = mdy('||vMes||',20,'||vAnio||') - 1 units month and num_credito = a.num_credito) = 0 and c.menos_abonos > 0 then ''T'' else ''N'' end end ' ||
		   -- ' case when (select interes_pago_total_tc from bdicred@pld_tcp:sd_encabezado2_edocta where fecha_emision = mdy('||vMes||',20,'||vAnio||') - 1 units month and num_credito = a.num_credito) = 0 and c.menos_abonos > 0 then ''T'' else ''N'' end end ' ||      
          ' status_pago_cliente ' ||
          ' from bdicred:sd_maesdoscont a ' ||
          ' join bdicred:sd_maecredcont b on b.empresa = a.empresa and b.num_credito = a.num_credito and b.fecha = a.fecha ' ||
          ' left outer join bdicred:sd_info_edocta c on c.fecha_emision = mdy('||vMes||',20,'||vAnio||') and c.num_credito = a.num_credito ' ||
       -- ' left outer join bdicred@pld_tcp:sd_encabezado2_edocta c on c.fecha_emision = mdy('||vMes||',20,'||vAnio||') and c.num_credito = a.num_credito ' ||
          ' where a.fecha = ''' || UltimoDiaMes || ''' ' ||
          ' and a.empresa = ''' || pEmpresa || ''' ' ||
          ' and a.num_credito > ''600000000000'' ' ||
          ' and b.campo_trab3 <> ''BAJA'';"' ||
          ' > /resplogifx/archivoscartera/QueryPayMenthist.sql';
        
        system cSql;

        let cSql='';
        let cSql = 'dbaccess bdicred /resplogifx/archivoscartera/QueryPayMenthist.sql';
        system cSql;
        let cSql = 'rm /resplogifx/archivoscartera/QueryPayMenthist.sql';
        system cSql;

        
        let NombreArchivoCifras = trim('PaymentHistCifrasControl_' || trim(vdia) || trim(vMes) || trim(vAnio) || '.txt');
        let cSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/archivoscartera/' || trim(NombreArchivoCifras) ||
          ' DELIMITER ' || '''|'''  || 
          ' select ' || trim(vdia) || trim(vMes) || trim(vAnio) || ',count(*)::integer,' ||
          ' sum(a.sdo_cap_insoluto),' ||
          ' sum(a.sdo_capital),' ||
          ' sum(a.mto_venc_trasp),' ||
          ' sum(a.cap_tras_no_venci),' ||
          ' sum(a.monto_vencido + a.mto_venc_trasp + a.cap_tras_no_venci),' ||
          ' sum(a.monto_otorgado),' ||
          ' sum(c.sdo_pagar)' ||
          ' from bdicred:sd_maesdoscont a ' ||
          ' join bdicred:sd_maecredcont b on b.empresa = a.empresa and b.num_credito = a.num_credito and b.fecha = a.fecha ' ||
          ' left outer join bdicred:sd_info_edocta c on c.fecha_emision = mdy('||vMes||',20,'||vAnio||') and c.num_credito = a.num_credito ' ||
          --' left outer join bdicred@pld_tcp:sd_encabezado2_edocta c on c.fecha_emision = mdy('||vMes||',20,'||vAnio||') and c.num_credito = a.num_credito ' ||
          ' where a.fecha = ''' || UltimoDiaMes || ''' ' ||
             ' and a.empresa = ''' || pEmpresa || ''' ' ||
             ' and a.num_credito > ''600000000000'' ' ||
             ' and b.campo_trab3 <> ''BAJA'';"' ||
             ' > /resplogifx/archivoscartera/QueryPayMenthistCifrasControl.sql';
        system cSql;

        let cSql='';
        let cSql = 'dbaccess bdicred /resplogifx/archivoscartera/QueryPayMenthistCifrasControl.sql';
        system cSql;
        let cSql = 'rm /resplogifx/archivoscartera/QueryPayMenthistCifrasControl.sql';
        system cSql;

        let cont=cont + 1;

        update bdicred:sd_param
           set valor = cont
         where empresa = pEmpresa and cod_param = '078';
       
    end if;

    
  if(cont=2) then
     
     set isolation to dirty read;
     
      select limit 1 fecha_corte INTO v_fecha_corte
        from bdicred:basebvr
       where num_credito >= ''; 
      
      IF v_fecha_corte < v_fechacorte_actual THEN
          truncate "informix".basebvr drop storage;
      END IF;  
 		
      let dFechaIni = date((mdy(vMes,20,vAnio) - 1 units month) + 1 units day);

  		 select a.numcte numcte, a.num_credito num_credito, a.fecha_apertura fecha_apertura
  		   from bdicred:sd_maecred a
        where a.empresa = pEmpresa 
          and a.num_credito>=''
          and a.status_cred in ('AA','BA','BT')
          and a.num_credito not in (select num_credito from bdicred:basebvr)
          and a.campo_trab3 <> 'BAJA'
         into temp cartera_basebvr with no log;
  
         
  
      foreach with hold

            select numcte, num_credito, fecha_apertura
              into cNumCte,cNumCredito,dFechaApertura
              from cartera_basebvr
            
let cauxNumCredito  = cNumCredito;

            select limit 1 nvl(b.mto_fin_ven_trasp,0) meses_vencidos,
                   case when b.monto_vencido > 0  then 'TRANSITORIO' 
                        when b.mto_venc_trasp > 0 then 'VENCIDO'
                        else 'VIGENTE' end status_credito,
                    date((b.fecha + 1 units month)) - 4 fecha_limite_pago,
                    b.monto_otorgado Limite_Credito
             into dMesesVencidos, v_status_credito, dFechaLimitePago, dLimiteCredito
             from bdicred:sd_maesdoshist b
            where b.fecha = mdy(vMes,20,vAnio)
              and b.empresa = pEmpresa
              and b.num_credito = cNumCredito;

            if v_status_credito is null and dFechaLimitePago is null and dLimiteCredito is null then continue foreach; end if;

            select limit 1
                    c.sdo_pagar pago_minimo, 
                    nvl(c.sdo_debe,0) + nvl(c.interes_pago_total_tc,0) saldo_corte,
                    c.sdo_disponible, 
                    c.fecha_emision fecha_corte,
                    c.menos_abonos pagos_payments,
                    c.mas_compras compras_purchases,
                    c.mas_disp_efectivo disposiciones_withdrawals, 
                    c.mas_intereses intereses,
                    c.fecha_emision,
/*                    case when to_char(a.fecha_apertura,'%Y%m') = to_char(c.fecha_emision,'%Y%m') 
                         then (month(c.fecha_emision) - month(a.fecha_apertura)) + ((year(c.fecha_emision) - year(a.fecha_apertura)) * 12) + 1
                         else (month(c.fecha_emision) - month(a.fecha_apertura)) + ((year(c.fecha_emision) - year(a.fecha_apertura)) * 12)
                        end MOB,*/
                    --d.tasa_anual::decimal(5,2)  --macf
                    c.tasa_anual 
              into dPagoMinimo, 
                    dSaldoCorte,
                    dSdoDisponible, 
                    dFechaCorte,
                    dPagosPayments,
                    dComprasPurchases,
                    dDisposicionesWithdrawals, 
                    dIntereses,
                    dFechaEmision,
--                    dMOB,
                    dTasa 
             --from bdicred@pld_tcp:sd_encabezado2_edocta c
               from bdicred:sd_info_edocta c
                 --inner join bdicred@pld_tcp:sd_pie_edocta d on d.fecha_emision=c.fecha_emision and d.num_credito=c.num_credito  
            where c.fecha_emision = mdy(vMes,20,vAnio)
              and c.num_credito = cNumCredito;


              if dFechaApertura = dFechaEmision then
                 let dMOB = (month(dFechaEmision) - month(dFechaApertura)) + ((year(dFechaEmision) - year(dFechaApertura)) * 12) + 1;
              else
                 let dMOB = (month(dFechaEmision) - month(dFechaApertura)) + ((year(dFechaEmision) - year(dFechaApertura)) * 12);
              end if
/*
                    case when to_char(a.fecha_apertura,'%Y%m') = to_char(c.fecha_emision,'%Y%m') 
                         then (month(c.fecha_emision) - month(a.fecha_apertura)) + ((year(c.fecha_emision) - year(a.fecha_apertura)) * 12) + 1
                         else (month(c.fecha_emision) - month(a.fecha_apertura)) + ((year(c.fecha_emision) - year(a.fecha_apertura)) * 12)
                        end MOB,*/

			select limit 1 nvl(sdo_debe,0) + nvl(interes_pago_total_tc,0)
              into dSdoCorteAnterior
              --from bdicred@pld_tcp:sd_encabezado2_edocta
              from bdicred:sd_info_edocta
  			 where fecha_emision = (mdy(vMes,20,vAnio) - 1 units month)
			   and num_credito = cNumCredito;


-- TRASPASO INTERES VIGENTE A VENCIDO
            if dIntereses >= 0 then
                select {+INDEX(sd_movhis inx_movhis)} nvl(sum(monto),0) into dIva
                  from bdicred:sd_movhis
                 where empresa = pEmpresa
                   and fecha_mov = mdy(vMes,20,vAnio)
                   and num_credito = cNumCredito
                   and codigo_fun = '605' 
                   and codigo_ref = 3
                   and reversado='N';
             else
                let dIva = 0;
             end if;

        
        select limit 1 nvl(num_atm_ch+num_vtn_ch,0) as numdisposiciones, nvl(num_pagos_ch,0) as num_pagos, nvl(num_pos_ch,0) as num_compras  
          into iNumeroDisposicionesCashATM, iNumeroPagosPayments, iNumeroComprasPurchases 
          from bdicred:sd_indicador_cred
         where empresa = pEmpresa
           and num_credito = cNumCredito;   

-- DISPOSICIONES Y DESEMBOLSOS
/*      select {+INDEX(sd_movhis inx_movhis)} count(*) into iNumeroDisposicionesCashATM
			  from bdicred:sd_movhis
			 where empresa=pEmpresa
		  	   and fecha_mov >= dFechaIni and fecha_mov <= mdy(vMes,20,vAnio)
			   and num_credito = cNumCredito
			   and codigo_fun ='002'
			   and codigo_ref IN (50,30,40,41,42,34,35,36,60,61,62,63,64)
			   and reversado='N';
-- PAGOS
			select {+INDEX(sd_movhis inx_movhis)} count(*) into iNumeroPagosPayments
			  from bdicred:sd_movhis
		 	 where empresa=pEmpresa
			   and fecha_mov >= dFechaIni and fecha_mov <= mdy(vMes,20,vAnio)
			   and num_credito = cNumCredito
			   and codigo_fun in (select cod_fun from bdicred:sd_conceptospagomanual) 
			   and codigo_ref=1
			   and reversado='N';


            select {+INDEX(sd_movhis inx_movhis)} count(*) into iNumeroComprasPurchases
			  from bdicred:sd_movhis
			 where empresa=pEmpresa
			   and fecha_mov >= dFechaIni and fecha_mov <= mdy(vMes,20,vAnio)
			   and num_credito = cNumCredito
			   and codigo_fun ='002'
			   and codigo_ref in (37,57)
			   and reversado='N';
*/

-- COMISIONES DE TARJETA DE CREDITO
			select {+INDEX(sd_movhis inx_movhis)} nvl(sum(monto),0) into dComisiones
			  from bdicred:sd_movhis
			 where empresa=pEmpresa
			   and fecha_mov >= dFechaIni and fecha_mov <= mdy(vMes,20,vAnio)
			   and num_credito = cNumCredito
			   and codigo_fun ='339'
			   and codigo_ref in (50,51,1,3,24,25,26,17,18,19,90,91,92,93,94,95,6,7,8)
			   and reversado='N';

        BEGIN WORK;

              INSERT INTO bdicred:basebvr
                      (numcte,num_credito,fecha_apertura,meses_vencidos,status_credito,pago_minimo,saldo_corte,sdo_disponible,fecha_limite_pago,
                      fecha_corte,sdo_corte_anterior,pagos_PAYMENTS,compras_PURCHASES,disposiciones_WITHDRAWALS,intereses,iva,rendimientos,
                      numero_disposiciones_CASH_ATM,numero_pagos_PAYMENTS,numero_compras_PURCHASES,comisiones,MOB,limite_credito,tasa)
                   values
                      (cNumCte,cNumCredito,dFechaApertura,dMesesVencidos,v_status_credito,dPagoMinimo,dSaldoCorte,dSdoDisponible,dFechaLimitePago,
                      dFechaCorte,dSdoCorteAnterior,dPagosPayments,dComprasPurchases,dDisposicionesWithdrawals,dIntereses,dIva,dRendimientos,
                      iNumeroDisposicionesCashATM,iNumeroPagosPayments,iNumeroComprasPurchases,dComisiones,dMOB,dLimiteCredito,dTasa);
                
        COMMIT WORK;
let cauxNumCredito  = '';
	end foreach;
 
  UPDATE statistics medium FOR TABLE "informix".basebvr;
 
  DROP TABLE cartera_basebvr;
 
    

    let NombreArchivo = trim('BaseBvr_' || trim(vdia) || trim(vMes) || trim(vAnio) || '.txt');
    let cSql = 'echo "UNLOAD TO /resplogifx/archivoscartera/' || trim(NombreArchivo) ||
               ' DELIMITER ' || '''|'''  || ' select * from basebvr;" > /resplogifx/archivoscartera/QueryBaseBvr.sql';
    system cSql;
	
    let cSql='';
    let cSql = 'dbaccess bdicred /resplogifx/archivoscartera/QueryBaseBvr.sql';
    system cSql;
    
	let cSql = 'rm /resplogifx/archivoscartera/QueryBaseBvr.sql';
    system cSql; 

    let cont=cont + 1;

    update bdicred:sd_param
         set valor = cont
         where empresa = pEmpresa and cod_param = '078';         
  
   
  end if;

   --return SCodRet,cMensajeRet;  --- solo para Test MACF

    if(cont=3) then
        let NombreArchivoCifras = trim('BaseBvrCifrasControl_' || trim(vdia) || trim(vMes) || trim(vAnio) || '.txt');
        let cSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/archivoscartera/' || trim(NombreArchivoCifras) ||
       ' DELIMITER ' || '''|'''  || 
       ' select count(*)::integer,sum(pago_minimo),sum(saldo_corte),sum(sdo_disponible),sum(sdo_corte_anterior),' ||
       ' sum(pagos_PAYMENTS),sum(compras_PURCHASES),sum(disposiciones_WITHDRAWALS),sum(intereses),sum(iva),0,' ||
       ' sum(numero_disposiciones_CASH_ATM),sum(numero_pagos_PAYMENTS),sum(numero_compras_PURCHASES),sum(comisiones),sum(limite_credito) ' ||
       ' from basebvr;" > /resplogifx/archivoscartera/QueryBaseBvrCifrasControl.sql';

        system cSql;
        let cSql='';
        let cSql = 'dbaccess bdicred /resplogifx/archivoscartera/QueryBaseBvrCifrasControl.sql';
        system cSql;
        let cSql = 'rm /resplogifx/archivoscartera/QueryBaseBvrCifrasControl.sql';
        system cSql; 

        let cont=cont + 1;

        update bdicred:sd_param
           set valor = cont
         where empresa = pEmpresa and cod_param = '078';
    end if;

    update bdicred:sd_param
       set valor = '1'
     where empresa = pEmpresa and cod_param = '078';


	return SCodRet,cMensajeRet ;
end;
end procedure;