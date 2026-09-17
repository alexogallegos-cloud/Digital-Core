CREATE PROCEDURE "informix".sp_obtiene_cancel_cs(pEmpresa CHAR(3), pNumCte CHAR (20), pNumCredito CHAR(20),pNumTarjeta CHAR(20))
	RETURNING 
				CHAR (5)  AS codigo_retorno,
				CHAR (3)  AS codigo_msj,
				CHAR (50) AS nombre_promocion,
				CHAR (16) AS folio,
				--DECIMAL (18,2) AS saldo,
				CHAR(16) AS Num_CrediSoluciones,
				DECIMAL(18,2) AS monto_apertura,
				DECIMAL(18,2) AS saldo_dia,
				CHAR (10) AS Fecha,
				SMALLINT AS Mens_rest,
				SMALLINT AS  Plazo,
				SMALLINT AS  codigo_promocion,
				CHAR(20)  AS  numcred_credisolucion,
				DECIMAL(10,2) AS TasaPlazo;			--DSB20140917
				
				
	----- DECLARACION DE VARIABLES  -----
	DEFINE cCodRet		CHAR (5);
	DEFINE cNombrePromo CHAR (50); 
	DEFINE cFolio		CHAR (16);
	DEFINE dcSaldo		DECIMAL(18,2);
	DEFINE iSqlErr		INTEGER;
	DEFINE cCodRetMsj	CHAR (3);
	DEFINE sPlazo 		SMALLINT;	
	DEFINE dFecha 		DATE;
	DEFINE cNum_sol_prestamo CHAR(20);	
	DEFINE sMens_rest 	SMALLINT;	
	DEFINE sNum_pagos 	SMALLINT;
	DEFINE sStatus_cancel1		SMALLINT;
	DEFINE sStatus_cancel2		SMALLINT;
	DEFINE sStatus_cancel3		SMALLINT;
	DEFINE cStatus_promo	CHAR(1);
	DEFINE sBand		SMALLINT;
	DEFINE sNum_promo		SMALLINT;
	DEFINE dcMonto_Apertura DECIMAL(18,2);
	DEFINE cNum_CrediSoluciones CHAR(16);
	----- DECLARACION DE VARIABLES sp_consulta_saldos_general.sql-----
	DEFINE cCsg_codigo_ret CHAR(6);
	DEFINE cCsg_mensaje_ret CHAR(80);
	DEFINE cCsg_num_credito CHAR(20);
	DEFINE cCsg_cod_tipcred CHAR(2);
	DEFINE dtCsg_fec_origen DATE;
	DEFINE dtCsg_fec_prox_pago DATE;
	DEFINE dcmCsg_pago_min DECIMAL(18,2);
	DEFINE dtCsg_fec_ult_pago DATE;
	DEFINE iCsg_plazo INTEGER;
	DEFINE iCsg_pagos_realizados INTEGER;
	DEFINE dcmCsg_linea_otorgada DECIMAL(18,2);
	DEFINE dcmCsg_tasa_interes DECIMAL(9,6);
	DEFINE dCsg_tasa_moratorios DECIMAL(9,6);
	DEFINE dCsg_monto_sbc DECIMAL(14,2);
	DEFINE dcmCsg_cap_vig DECIMAL(18,2);
	DEFINE dcmCsg_cap_trans DECIMAL(18,2);
	DEFINE dcmCsg_cap_vdo_exig DECIMAL(18,2);
	DEFINE dcmCsg_cap_vdo_no_exig DECIMAL(18,2);
	DEFINE dcmCsg_sdo_act_total_cap DECIMAL(18,2);
	DEFINE dcmCsg_int_vig DECIMAL(18,2);
	DEFINE dcmCsg_int_vdo DECIMAL(18,2);
	DEFINE dcmCsg_int_moratorios DECIMAL(18,2);
	DEFINE dcmCsg_int_mes DECIMAL(18,2);
	DEFINE dcmCsg_sdo_act_total_int DECIMAL(18,2);
	DEFINE dcmCsg_iva_int_vig DECIMAL(18,2);
	DEFINE dcmCsg_iva_int_vdo DECIMAL(18,2);
	DEFINE dcmCsg_iva_int_moratorios DECIMAL(18,2);
	DEFINE dcmCsg_iva_int_mes DECIMAL(18,2);
	DEFINE dcmCsg_sdo_act_total_iva DECIMAL(18,2);
	DEFINE dcmCsg_com_pend DECIMAL(18,2);
	DEFINE dcmCsg_iva_com DECIMAL(18,2);
	DEFINE dcmCsg_sdo_retenido DECIMAL(18,2);
	DEFINE dcmCsg_tot_liquidacion DECIMAL(18,2);
	DEFINE dcmCsg_int_devengado DECIMAL(18,2);
	DEFINE dcmCsg_iva_int_devengado DECIMAL(18,2);
	DEFINE dcmCsg_linea_disp DECIMAL(18,2);
	DEFINE dcmCsg_pagos_vdos DECIMAL(18,2);
	DEFINE cCsg_desc_status_cred CHAR(60);
	DEFINE iCsg_id_bloqueo_cred INTEGER;
	DEFINE cCsg_bloqueo_cta CHAR(60);
	DEFINE cCsg_id_causa_bloq_cred CHAR(3);
	DEFINE cCsg_causa_bloqueo_cta CHAR(50);
	DEFINE cCsg_id_sit_esp_cte CHAR(75);
	DEFINE iCsg_id_causa_esp_cte INTEGER;
	DEFINE cCsg_sit_esp_cte CHAR(75);
	DEFINE cCsg_id_sit_esp_cred CHAR(1);
	DEFINE iCsg_id_causa_esp_cred INTEGER;
	DEFINE cCsg_sit_esp_cred CHAR(75);
	
	DEFINE dcmTasaPlazo	DECIMAL(10,2);			--DSB20140917
	----------------------------------------------------------------------

	----- INICIALIZACION DE VARIABLES -----
	LET cCodRet			= '00000';
	LET cNombrePromo 	= '';
	LET cFolio			= '';
	LET dcSaldo			= 0.00;
	LET iSqlErr			= 0;
	LET cCodRetMsj 		= '000';
	LET sPlazo 			= 0;
	LET dFecha 			= '';
	LET cNum_sol_prestamo = '';
	LET sMens_rest 		= 0 ;
	LET sNum_pagos 		= 0 ;
	LET sStatus_cancel1      = 0;
	LET sStatus_cancel2      = 0;
	LET sStatus_cancel3      = 0;
	LET cStatus_promo 	 	 = "";
	LET sBand			     = 0;
	LET sNum_promo			     = 0;
    LET dcMonto_Apertura = 0.00;
	LET cNum_CrediSoluciones = '';
	------------------------------------------------------------------------
	------ INICIALIZACION DE VARIABLES sp_consulta_saldos_general.sql-------
	LET cCsg_codigo_ret = '00000';
	LET cCsg_mensaje_ret = '';
	LET cCsg_num_credito = '';
	LET cCsg_cod_tipcred = '';
	LET dtCsg_fec_origen = '';
	LET dtCsg_fec_prox_pago = '';
	LET dcmCsg_pago_min = 0.00;
	LET dtCsg_fec_ult_pago = '';
	LET iCsg_plazo = 0;
	LET iCsg_pagos_realizados = 0;
	LET dcmCsg_linea_otorgada = 0.00;
	LET dcmCsg_tasa_interes = 0.00;
	LET dCsg_tasa_moratorios = 0.00;
	LET dCsg_monto_sbc = 0.00;
	LET dcmCsg_cap_vig = 0.00;
	LET dcmCsg_cap_trans = 0.00;
	LET dcmCsg_cap_vdo_exig = 0.00;
	LET dcmCsg_cap_vdo_no_exig = 0.00;
	LET dcmCsg_sdo_act_total_cap = 0.00;
	LET dcmCsg_int_vig = 0.00;
	LET dcmCsg_int_vdo = 0.00;
	LET dcmCsg_int_moratorios = 0.00;
	LET dcmCsg_int_mes = 0.00;
	LET dcmCsg_sdo_act_total_int = 0.00;
	LET dcmCsg_iva_int_vig = 0.00;
	LET dcmCsg_iva_int_vdo = 0.00;
	LET dcmCsg_iva_int_moratorios = 0.00;
	LET dcmCsg_iva_int_mes = 0.00;
	LET dcmCsg_sdo_act_total_iva = 0.00;
	LET dcmCsg_com_pend = 0.00;
	LET dcmCsg_iva_com = 0.00;
	LET dcmCsg_sdo_retenido = 0.00;
	LET dcmCsg_tot_liquidacion = 0.00;
	LET dcmCsg_int_devengado = 0.00;
	LET dcmCsg_iva_int_devengado = 0.00;
	LET dcmCsg_linea_disp = 0.00;
	LET dcmCsg_pagos_vdos = 0.00;
	LET cCsg_desc_status_cred = '';
	LET iCsg_id_bloqueo_cred = 0;
	LET cCsg_bloqueo_cta = '';
	LET cCsg_id_causa_bloq_cred = '';
	LET cCsg_causa_bloqueo_cta = '';
	LET cCsg_id_sit_esp_cte = '';
	LET iCsg_id_causa_esp_cte = 0;
	LET cCsg_sit_esp_cte = '';
	LET cCsg_id_sit_esp_cred = '';
	LET iCsg_id_causa_esp_cred = 0;
	LET cCsg_sit_esp_cred = '';
	------------------------------------------------------------------------
	LET dcmTasaPlazo = 0.00;					--DSB20140917

	BEGIN
		ON EXCEPTION SET iSqlErr  -- SI EL PROCEDIMIENTO REGRESA UN ERROR
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				--RETURN cCodRet,cCodRetMsj, NVL(TRIM(cNombrePromo),''), NVL(TRIM(cFolio),''),NVL(dcSaldo,0.00),NVL(dFecha,''),NVL(sMens_rest,0),NVL(sPlazo,0), NVL(sNum_promo, 0), NVL(TRIM(cNum_sol_prestamo),'');
				RETURN cCodRet,cCodRetMsj, NVL(TRIM(cNombrePromo),''), NVL(TRIM(cFolio),''), NVL(TRIM(cNum_CrediSoluciones),''),NVL(dcMonto_Apertura,0.00),NVL(dcmCsg_tot_liquidacion,0.00),NVL(dFecha,''),NVL(sMens_rest,0),NVL(sPlazo,0), NVL(sNum_promo, 0), NVL(TRIM(cNum_sol_prestamo),''),NVL(dcmTasaPlazo,0.00); ------ DSB20140617--------    
			END IF;
		END EXCEPTION;
		
		-- RUTA Y NOMBRE DONDE SE GENERARÃ LO QUE REALIZÃ EL PROCEDIMIENTO
 		-- SET DEBUG FILE TO '/informix/Rebeca/sp_obtiene_cancel_cs.out';
		-- TRACE ON; 
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- SE VALIDA QUE LOS PARAMETROS NO VENGAN VACÃOS
		IF NVL (TRIM(pEmpresa),'') = '' OR NVL(TRIM(pNumCredito),'')= '' AND  NVL (TRIM(pNumCte),'') = '' AND NVL (TRIM(pNumTarjeta),'') = '' THEN
			LET cCodRet = '00001';	-- LOS PARAMETROS ESTÃN EN BLANCO.
			LET cCodRetMsj = '590';
			--RETURN cCodRet,cCodRetMsj, NVL(TRIM(cNombrePromo),''), NVL(TRIM(cFolio),''),NVL(dcSaldo,0.00),NVL(dFecha,''),NVL(sMens_rest,0),NVL(sPlazo,0), NVL(sNum_promo, 0), NVL(TRIM(cNum_sol_prestamo),'');
			RETURN cCodRet,cCodRetMsj, NVL(TRIM(cNombrePromo),''), NVL(TRIM(cFolio),''), NVL(TRIM(cNum_CrediSoluciones),''),NVL(dcMonto_Apertura,0.00),NVL(dcmCsg_tot_liquidacion,0.00),NVL(dFecha,''),NVL(sMens_rest,0),NVL(sPlazo,0), NVL(sNum_promo, 0), NVL(TRIM(cNum_sol_prestamo),''),NVL(dcmTasaPlazo,0.00); ------ DSB20140617--------    
		END IF;
		
		-- SE OBTIENEN LOS ESTATUS DE CREDISOLUCIONES QUE SI SE PUEDEN CANCELAR
		SELECT valor INTO sStatus_cancel1 FROM "informix".sd_param WHERE cod_param = '965';
		SELECT valor INTO sStatus_cancel2 FROM "informix".sd_param WHERE cod_param = '966';
		SELECT valor INTO sStatus_cancel3 FROM "informix".sd_param WHERE cod_param = '967';
		
		FOREACH
            SELECT TRIM (a.nombre_promo),a.folio_movto,c.num_credito,c.monto_otorgado, (a.monto_actual + a.monto_int_iva),a.fecha,a.plazo, a.num_sol_prestamo, a.status, a.num_promo
			INTO cNombrePromo, cFolio, cNum_CrediSoluciones, dcMonto_Apertura, dcmCsg_tot_liquidacion,dFecha, sPlazo,cNum_sol_prestamo,cStatus_promo, sNum_promo
			FROM "informix".sd_promocion_credito a
			INNER JOIN "informix".sd_maecred b on (b.empresa = a.empresa AND b.num_credito = a.num_credito  AND b.status_cred IN ('AA','E1'))
			INNER JOIN "informix".sd_maesdos d ON (d.num_credito = b.num_credito AND (d.monto_vencido + d.mto_venc_trasp) = 0)
			INNER JOIN "informix".sd_maesdoscrd c ON (c.empresa = a.empresa AND SUBSTR(c.num_credito,1,4) = '6900' AND c.num_credito = a.num_sol_prestamo) --DSB20140617
			WHERE a.empresa = pEmpresa			
			  AND a.folio_suc = a.folio_suc  	--PARA ACTIVAR INDICE
			  AND a.sistema = '06'
              AND a.status = 2   --FMV 13-MAR-14 Se adiciona estatus aperturado para cancelacion SIF y OFI
			  AND a.num_cte = DECODE(NVL(TRIM(pNumCte),''),'', a.num_cte,TRIM(pNumCte))  
			  AND a.num_credito = DECODE(NVL(TRIM(pNumCredito),''),'', a.num_credito,TRIM(pNumCredito))  
			  AND a.num_tarjeta = DECODE(NVL(TRIM(pNumTarjeta),''),'', a.num_tarjeta,TRIM(pNumTarjeta))
			  ORDER BY a.num_cte, a.num_credito, a.num_sol_prestamo
			  
			  -- SI EL ESTATUS DE LA CREDISOL NO COINCIDE CON LOS DE LA SD_PARAM YA NO SE TOMA ENCUENTA Y SE TOMA LA SIGUIENTE
			  IF cStatus_promo NOT IN(sStatus_cancel1,sStatus_cancel2,sStatus_cancel3) THEN
					LET cNombrePromo = '';
					LET cFolio = '';
					LET dcSaldo = 0.00;
					LET dFecha = '';
					LET sPlazo = 0;
					LET cNum_sol_prestamo = '';
					LET cStatus_promo = '';
					LET sNum_promo = 0;
					LET cNum_CrediSoluciones = ''; --DSB20140617
					LET dcMonto_Apertura = 0.00; --DSB20140617
					LET dcmCsg_tot_liquidacion = 0.00; --DSB20140617
					CONTINUE FOREACH; 					
			  END IF 
			  
			  LET sBand = 1;
			------INICIO DSB20140617--------           
              EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(pEmpresa,cNum_CrediSoluciones)
				INTO  cCsg_codigo_ret,cCsg_mensaje_ret,cCsg_num_credito,cCsg_cod_tipcred,dtCsg_fec_origen,dtCsg_fec_prox_pago,dcmCsg_pago_min,
					  dtCsg_fec_ult_pago,iCsg_plazo,iCsg_pagos_realizados,dcmCsg_linea_otorgada,dcmCsg_tasa_interes,dCsg_tasa_moratorios,
			          dCsg_monto_sbc,dcmCsg_cap_vig,dcmCsg_cap_trans,dcmCsg_cap_vdo_exig,dcmCsg_cap_vdo_no_exig,dcmCsg_sdo_act_total_cap,dcmCsg_int_vig,
			          dcmCsg_int_vdo,dcmCsg_int_moratorios,dcmCsg_int_mes,dcmCsg_sdo_act_total_int,dcmCsg_iva_int_vig,dcmCsg_iva_int_vdo,dcmCsg_iva_int_moratorios,
			          dcmCsg_iva_int_mes,dcmCsg_sdo_act_total_iva,dcmCsg_com_pend,dcmCsg_iva_com,dcmCsg_sdo_retenido,dcmCsg_tot_liquidacion,dcmCsg_int_devengado,
			          dcmCsg_iva_int_devengado,dcmCsg_linea_disp,dcmCsg_pagos_vdos,cCsg_desc_status_cred,iCsg_id_bloqueo_cred,cCsg_bloqueo_cta,
			          cCsg_id_causa_bloq_cred,cCsg_causa_bloqueo_cta,cCsg_id_sit_esp_cte,iCsg_id_causa_esp_cte,cCsg_sit_esp_cte,cCsg_id_sit_esp_cred,
			          iCsg_id_causa_esp_cred,cCsg_sit_esp_cred;
					  
				IF cCsg_codigo_ret::INTEGER <> 0 THEN					
					LET dcmCsg_tot_liquidacion = 0.00;				
				END IF			  
			  ------FIN DSB20140617-------- 
			  -- SE TOMA EL NÃMERO DE PAGOS QUE SE TIENE AL MOMENTO 
			  SELECT COUNT(num_credito) 
			  INTO sNum_pagos 
			  FROM "informix".sd_amortiza_creditocrd 
			  WHERE num_credito = cNum_sol_prestamo 
			  AND capital_status = '5';
			  
			  -- SE SACAN LOS MESES RESTANTES AL RESTAR EL NÃMERO DE PAGOS AL PLAZO
		      LET sMens_rest = sPlazo - sNum_pagos;			
				
				--SELECT tasa INTO dcmTasaPlazo FROM sd_tasa_plazo WHERE num_promo = sNum_promo AND plazo = sPlazo;		--DSB20140917
				SELECT tasa_interes INTO dcmTasaPlazo FROM bdicred:sd_maecredcrd WHERE num_credito = cNum_CrediSoluciones AND numcte = pNumCte; --INC 25 011
				
			-- SE RETORNA LA INFORMACIÃN DE LA CREDISOL QUE SE PODRÃ CANCELAR
			--RETURN cCodRet,cCodRetMsj, NVL(TRIM(cNombrePromo),''), NVL(TRIM(cFolio),''),NVL(dcSaldo,0.00)NVL(dcmCsg_tot_liquidacion,0.00),NVL(dFecha,''),NVL(sMens_rest,0),NVL(sPlazo,0), NVL(sNum_promo, 0), NVL(TRIM(cNum_sol_prestamo),'') WITH RESUME;
			RETURN cCodRet,cCodRetMsj, NVL(TRIM(cNombrePromo),''), NVL(TRIM(cFolio),''), NVL(TRIM(cNum_CrediSoluciones),''),NVL(dcMonto_Apertura,0.00),NVL(dcmCsg_tot_liquidacion,0.00),NVL(dFecha,''),NVL(sMens_rest,0),NVL(sPlazo,0), NVL(sNum_promo, 0), NVL(TRIM(cNum_sol_prestamo),''),NVL(dcmTasaPlazo,0.00) WITH RESUME;
			
		END FOREACH
		
		-- SE VERIFÃCA SI HAY INFORMACIÃN O NO DE LA CONSULTA
		IF DBINFO('sqlca.sqlerrd2') = 0 OR sBand = 0 THEN
		
			LET cCodret = '00002'; -- NO HAY INFORMACIÃN EN LA CONSULTA
			LET cCodRetMsj = '595';
			
			LET cNombrePromo = '';
			LET cFolio = '';
			LET dcSaldo = 0.00;
			LET dFecha = '';
			LET sPlazo = 0;
			LET cNum_sol_prestamo = '';
			LET cStatus_promo = '';
			LET sNum_promo = 0;
			LET cNum_CrediSoluciones = ''; --DSB20140617
            LET dcMonto_Apertura = 0.00; --DSB20140617
		    LET dcmCsg_tot_liquidacion = 0.00; --DSB20140617			
			
			--RETURN cCodRet,cCodRetMsj, NVL(TRIM(cNombrePromo),''), NVL(TRIM(cFolio),''),NVL(dcSaldo,0.00),NVL(dcmCsg_tot_liquidacion,0.00),NVL(dFecha,''),NVL(sMens_rest,0),NVL(sPlazo,0), NVL(sNum_promo, 0), NVL(TRIM(cNum_sol_prestamo),'');
			RETURN cCodRet,cCodRetMsj, NVL(TRIM(cNombrePromo),''), NVL(TRIM(cFolio),''), NVL(TRIM(cNum_CrediSoluciones),''),NVL(dcMonto_Apertura,0.00),NVL(dcmCsg_tot_liquidacion,0.00),NVL(dFecha,''),NVL(sMens_rest,0),NVL(sPlazo,0), NVL(sNum_promo, 0), NVL(TRIM(cNum_sol_prestamo),''),NVL(dcmTasaPlazo,0.00);
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT
'--------------------------------------------------------------------------------------------------------------',
'DESCRIPCIÃN: Muestra las Credisoluciones que se pueden cancelar',
'FECHA DE CREACIÃN: 11-junio-2013',
'BASE DE DATOS: BDICRED',
'AUTOR: MARIO GAMALIEL OLIVO URIAS',
'VERSION: 20130611.1732',
'--------------------------------------------------------------------------------------------------------------',
'Folio: 1397',
'Autor: 94912599 JOSUE ZAZUETA',
'Fecha: 23/12/2013',
'DescripciÃ³n: Se modifica para que se cancelen las cresidol solo los que esten en la sd_param',
'tambien para que se retorne el numero de pagos restantes, el plazo,y la fecha de alta, se documenta',
'Sustento: RQM 10 214-4 Ademdum Credisoluciones Efec_Vf_cancela.doc',
'Solicita: Faviola Martinez Juarez',
'BD:BDICRED',
'--------------------------------------------------------------------------------------------------------------',
'-- Folio.........: 1452 - CrediSoluciones',
'-- Autor.........: 95519203 - Ivan Garcia',
'-- Fecha.........: 17/06/2014 - DSB20140617',
'-- ModificaciÃ³n..: Se modifica para obtener el valor de los nuevos campos, el valor del campo monto apertura se obtendrÃ¡  del valor del campo monto_otorgado,el valor del campo saldo al dia se obtendrÃ¡ del valor del retorno total_liquidacion',
'-- Sustento......: Analisis incidencias credisoluciones.doc',
'-- Solicita......: Faviola Martinez',
'-- BD............: Bdicred',
'----------------------------------------------------------------------------------------------------------------',
'-- Folio.........: 1498 - ModifGridCancelacionCredisoluciones',
'-- Autor.........: 95526749 - JesÃºs Horacio LÃ³pez GonzÃ¡lez',
'-- Fecha.........: 17/09/2014 - DSB20140917',
'-- ModificaciÃ³n..: Se modifica para que retorne la tasa de interes que utiliza cada promocion para mostrarla en el Grid.',
'-- Sustento......: Se solicita por correo, enviado por Francisco J. Martinez Viveros(fmartinez@mailbancoppel.com), el 10/09/201410 a las 12:21:09',
'-- Solicita......: Faviola Martinez',
'-- BD............: Bdicred',
'----------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_pagopp_quitacondona(pempresa  char(3), pNumCredito  char(20),
                                            p_Monto DECIMAL(18,2), p_Usuario char(8), p_Sucursal char(4),
                                            p_Folio LIKE sd_movdia.Folio_Suc,p_TpOperacion CHAR (1),
											totalquitacapvenc DECIMAL(18,2))
RETURNING  CHAR(5)        AS cod_ret,
		   smallint       AS bandera_quita_restante,
		   DECIMAL(18,2)  AS monto_nuevo;

DEFINE iSqlErr                       INTEGER;
DEFINE iIsamErr                      INTEGER;
DEFINE cErrorInfo                    CHAR(80);
DEFINE cCodRet                       CHAR(5);
DEFINE cCodRetAux                    CHAR(6);
DEFINE cMensajeRet                   CHAR(125);
DEFINE wBegin                        CHAR(1);

DEFINE iIntAux                       INTEGER;
DEFINE cCharAux                      CHAR(80);
DEFINE dDecAux                       DECIMAL(18,2);
DEFINE dtDateAux                     DATE;

DEFINE GLOBAL g_Empresa    CHAR(03)  DEFAULT '';                             
DEFINE GLOBAL g_NumCredito CHAR(20)  DEFAULT '';                             

DEFINE dCuentamens                   INTEGER;
DEFINE dFechaCuota                   DATE;
DEFINE dCapitalStatus                CHAR(1);
DEFINE dIntMoraOrdi                  DECIMAL(18,2);
DEFINE dIntMoraCope                  DECIMAL(18,2);
DEFINE dIvaMoraDebe                  DECIMAL(18,2);
DEFINE dIntDebe                      DECIMAL(18,2);
DEFINE dIvaIntDebe                   DECIMAL(18,2);
DEFINE dCapitalDebe                  DECIMAL(18,2);
DEFINE dPagoMoraCope                 DECIMAL(18,2);
DEFINE dPagoMoraOrdi                 DECIMAL(18,2);
DEFINE dPagoIvaMora                  DECIMAL(18,2);
DEFINE dStatusCred                   CHAR(2);
DEFINE dSdoCapInsolutoPP             DECIMAL(18,2);
--DEFINE dSdoVdo                       DECIMAL(18,2);
DEFINE dSdoTrasp                     DECIMAL(18,2);
DEFINE dIntTrasp                     DECIMAL(18,2);
DEFINE dIvaTrasp                     DECIMAL(18,2);
DEFINE dIvaSuc                       DECIMAL(5,3);
DEFINE dFechaVenci                   DATE;
DEFINE dProvIntFinMes                DECIMAL(18,2);
DEFINE dProvIvaFinMes                DECIMAL(18,2);
DEFINE cConceptoPago                 CHAR(50);
--

----------------------- Datos General ------------------------------------------------------

DEFINE cNomProd    		             CHAR(40);
DEFINE dMoraBase           		 	 DECIMAL(18,2);
DEFINE dMoraCopete      		 	 DECIMAL(18,2);
DEFINE dIvamoraBase     		 	 DECIMAL(18,2);
DEFINE dIvaMoraCopete   			 DECIMAL(18,2);
DEFINE vnumcte                       CHAR(20); --RQM 10 915-4
DEFINE vNumCel                       CHAR(13); --RQM 10 915-4
DEFINE vFecha                        CHAR(10); --RQM 10 915-4
DEFINE vstcred                       CHAR(2); --RQM 10 915-4

--- SDFM Se agrega variable para creditos bloqueados
DEFINE vcodigo_bloq CHAR (2);
DEFINE cNumCredito      CHAR(20);
DEFINE mMontoEfec     MONEY(14,2);
DEFINE mMontoCargo    MONEY(14,2);
DEFINE mMonto		  MONEY(14,2);
DEFINE v_iva_cs       DECIMAL(14,2);
DEFINE cfolio_mov     CHAR(16);
DEFINE c_Folio_Suc	  CHAR(16);

DEFINE sCountExist	  INTEGER;
--------------------------------------------------------------------------------------------
DEFINE cUsrCobroAut		   CHAR(8);
DEFINE aux_vencidos 		INT;

---------------------------
DEFINE p_Cuenta				CHAR(20);
DEFINE dtfechahoy           DATE;
DEFINE numprod				CHAR(4);



--VARIABLES para sp_consulta_saldos_general
DEFINE cCodRetSP			 CHAR(6);
DEFINE cMensajeSP			 CHAR(80);
DEFINE cCodTipCred      	 CHAR(2);
DEFINE cDescStatusCred  	 CHAR(60);
DEFINE iIdUnidadProd     	 INTEGER;
DEFINE cCodCaract2       	 CHAR(3);
DEFINE dtFechaOrigen    	 DATE;
DEFINE dtFechaProxPago  	 DATE;
DEFINE dPagoMinimo      	 DECIMAL(18,2);
DEFINE dtFechaUltPago    	 DATE;
DEFINE iPlazo           	 INTEGER;
DEFINE iPagosRealizados 	 INTEGER;
DEFINE dLineaOtorgada    	 DECIMAL(18,2);
DEFINE dTasaInteres      	 DECIMAL(9,6);
DEFINE dTasaMoratorios  	 DECIMAL(9,6);
DEFINE dMontoSBC        	 DECIMAL(14,2);
DEFINE dCapVig           	 DECIMAL(18,2);
DEFINE dCapTrans         	 DECIMAL(18,2);
DEFINE dCapVdoExig       	 DECIMAL(18,2);
DEFINE dCapVdoNoExig    	 DECIMAL(18,2);
DEFINE dSdoActCap        	 DECIMAL(18,2);
DEFINE dIntVig           	 DECIMAL(18,2);
DEFINE dIntVdo           	 DECIMAL(18,2);
DEFINE dIntMoratorio     	 DECIMAL(18,2);
DEFINE dIntMes          	 DECIMAL(18,2);
DEFINE dSdoActInt        	 DECIMAL(18,2);
DEFINE dIvaIntVig        	 DECIMAL(18,2);
DEFINE dIvaIntVdo        	 DECIMAL(18,2);
DEFINE dIvaIntMoratorio  	 DECIMAL(18,2);
DEFINE dIvaIntMes        	 DECIMAL(18,2);
DEFINE dSdoActIvaInt     	 DECIMAL(18,2);
DEFINE dComPend          	 DECIMAL(18,2);
DEFINE dIvaCom            	 DECIMAL(18,2);
DEFINE dSdoRetenido     	 DECIMAL(18,2);
DEFINE dSdoTotalLiq     	 DECIMAL(18,2);
DEFINE dIntDevengado         DECIMAL(18,2);
DEFINE dIvaIntDevengado      DECIMAL(18,2);
DEFINE dLineaDisponible      DECIMAL(18,2);
DEFINE dPagosVdos            DECIMAL(18,2);
DEFINE cDescBloqueoCta       CHAR(60);
DEFINE cDescCausaBloqueoCta  CHAR(50);
DEFINE cSitCte               CHAR(1);
DEFINE iCausaCte             INTEGER;
DEFINE cDescSitEspCte        CHAR(75);
DEFINE cSitCred              CHAR(1);
DEFINE iCausaCred            INTEGER;
DEFINE cDescSitEspCred       CHAR(75);
DEFINE iAplicoPago           INTEGER;
DEFINE CodRetResp            CHAR(5);

DEFINE dCuentaCap				CHAR(20);
DEFINE totalsinaccesorios		DECIMAL(18,2);
--DEFINE totalquitacapvenc       DECIMAL(18,2);
DEFINE dadeudototal				DECIMAL(18,2);
DEFINE padeudomoraint			DECIMAL(18,2);
DEFINE dFactor					DECIMAL(14,9);
DEFINE dpagomoraint				DECIMAL(18,2);
DEFINE dPagoIvaMoraInt			DECIMAL(18,2);
DEFINE dFactorMoraCope			DECIMAL(14,9);
DEFINE pMoraCope 				DECIMAL(18,2);
DEFINE dIntMora					DECIMAL(18,2);
DEFINE dIvaIntMora				DECIMAL(18,2);
DEFINE dpagoint					DECIMAL(18,2);
DEFINE dPagoIvaInt				DECIMAL(18,2);
DEFINE vtarjeta					CHAR(20);
DEFINE cproduto					VARCHAR(3);
DEFINE Mensaje					CHAR(50);
DEFINE pcodfun					CHAR(3);
DEFINE p_numpago				CHAR(40);
DEFINE p_Divisa               	CHAR(2);
DEFINE p_status_cred			CHAR(2);
DEFINE p_Monto_q				DECIMAL(18,2);
DEFINE p_Monto_c				DECIMAL(18,2);
DEFINE p_Transacc				CHAR(4);
DEFINE bandera_quita_restante		smallint;
DEFINE total_condonado_quita	DECIMAL(18,2);
DEFINE total_condonado			DECIMAL(18,2);
DEFINE monto_nuevo				DECIMAL(18,2);
DEFINE suma_condonado			DECIMAL(18,2);
DEFINE p_codigo_ref             INTEGER;
DEFINE vMontoQuitaCapVencido    DECIMAL(18,2);
DEFINE v_PagoCte                DECIMAL(18,2);
DEFINE v_CobraIntVenc           DECIMAL(18,2);
DEFINE montoAccesorios			DECIMAL(18,2);

LET p_Cuenta			= "";
LET dtfechahoy			= DATE(1);
LET numprod				= '';

LET iSqlErr               = 0;
LET iIsamErr              = 0;
LET cErrorInfo            = "";
LET cCodRet               = "00000";
LET cMensajeRet           = "Se realizo el pago correctamente";
LET cCodRetAux            = "000000";
LET dFechaCuota          = DATE(1);
LET iIntAux               = 0;
LET cCharAux              = "";
LET dDecAux               = 0;
LET dtDateAux             = DATE(1);

--
LET dFechaCuota                   = DATE(1);
LET dCapitalStatus                = "";
LET dIntMoraOrdi                  = 0;
LET dIntMoraCope                  = 0;
LET dIvaMoraDebe                  = 0;
LET dIntDebe                      = 0;
LET dIvaIntDebe                   = 0;
LET dCapitalDebe                  = 0;
LET dPagoMoraCope                 = 0;
LET dPagoMoraOrdi                 = 0;
LET dPagoIvaMora                  = 0;
LET dStatusCred                   = "";
LET dSdoCapInsolutoPP             = 0;
LET dIvaSuc                       = 0;
LET dFechaVenci                   = DATE(1);
LET cConceptoPago                 = '';
LET dMoraBase               	  = "";
LET dMoraCopete             	  = "";
LET dIvamoraBase           		  = "";
LET dIvaMoraCopete         		  = "";

LET cNomProd    		  = "";
--- SDFM Se agrega variable para creditos bloqueados
LET vcodigo_bloq = '';
LET cNumCredito           = '';
LET mMontoEfec          = 0;
LET mMontoCargo         = 0;
LET mMonto		        = 0;
LET v_iva_cs            = 0;
LET cfolio_mov          = "";
LET c_Folio_Suc     	='';

LET sCountExist			= 0;


--INICIALIZACIONES PARA sp_consulta_saldos_general
LET cCodRetSP             = '';
LET cMensajeSP			  = '';
LET cCodTipCred      	  = '';
LET cDescStatusCred  	  = '';
LET iIdUnidadProd     	  = 0;
LET cCodCaract2       	  = '';
LET dtFechaOrigen    	  = DATE(1);
LET dtFechaProxPago  	  = DATE(1);
LET dPagoMinimo      	  = 0;
LET dtFechaUltPago    	  = DATE(1);
LET iPlazo           	  = 0;
LET iPagosRealizados 	  = 0;
LET dLineaOtorgada    	  = 0;
LET dTasaInteres      	  = 0;
LET dTasaMoratorios  	  = 0;
LET dMontoSBC        	  = 0;
LET dCapVig           	  = 0;
LET dCapTrans         	  = 0;
LET dCapVdoExig       	  = 0;
LET dCapVdoNoExig    	  = 0;
LET dSdoActCap        	  = 0;
LET dIntVig           	  = 0;
LET dIntVdo           	  = 0;
LET dIntMoratorio     	  = 0;
LET dIntMes          	  = 0;
LET dSdoActInt        	  = 0;
LET dIvaIntVig        	  = 0;
LET dIvaIntVdo        	  = 0;
LET dIvaIntMoratorio  	  = 0;
LET dIvaIntMes        	  = 0;
LET dSdoActIvaInt     	  = 0;
LET dComPend          	  = 0;
LET dIvaCom            	  = 0;
LET dSdoRetenido     	  = 0;
LET dSdoTotalLiq     	  = 0;
LET dIntDevengado         = 0;
LET dIvaIntDevengado      = 0;
LET dLineaDisponible      = 0;
LET dPagosVdos            = 0;
LET cDescBloqueoCta       = '';
LET cDescCausaBloqueoCta  = '';
LET cSitCte               = '';
LET iCausaCte             = 0;
LET cDescSitEspCte        = '';
LET cSitCred              = '';
LET iCausaCred            = 0;
LET cDescSitEspCred       = '';
LET iAplicoPago           = 0;

LET dCuentaCap				= "";
LET totalsinaccesorios		= 0;
LET dadeudototal			= 0;
LET padeudomoraint			= 0;
LET dFactor					= 0;
LET dpagomoraint			= 0;
LET dPagoIvaMoraInt			= 0;
LET dFactorMoraCope			= 0;
LET pMoraCope				= 0;
LET dIntMora				= 0;
LET dIvaIntMora				= 0;
LET dpagoint				= 0;
LET dPagoIvaInt				= 0;
LET vtarjeta				= '';
LET cproduto				= '';
LET Mensaje					= '';	
LET pcodfun					= '';
LET p_numpago				= '';
LET p_Divisa				= '';
LET p_status_cred			= '';
LET p_Monto_q				= 0;
LET p_Monto_c				= 0;
LET v_PagoCte               = 0;
LET vMontoQuitaCapVencido   = 0;
LET p_Transacc				= '';
LET bandera_quita_restante	= 0;
LET total_condonado_quita	= 0;
LET total_condonado			= 0;
LET monto_nuevo				= 0;
LET suma_condonado			= 0;
LET p_codigo_ref            = 0;
LET v_CobraIntVenc          = 0;
LET CodRetResp              = '';
LET montoAccesorios 		= 0;
--LET totalquitacapvenc      = 0;

-- SET DEBUG FILE TO "/ifxsif01/Israel/sp_pagopp_quitacondona.out";
-- TRACE ON;

BEGIN
ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
      --SET DEBUG FILE TO "sp_principal_rr.err";
       IF iSqlErr != 0 THEN
          LET cCodRet     = iSqlErr;
          LET cMensajeRet = cErrorInfo;
		  LET bandera_quita_restante	 = 0;
       END IF;
       ROLLBACK WORK;
      IF (wBegin = "S") THEN
         BEGIN WORK;
      END IF;
      RETURN cCodRet,bandera_quita_restante,monto_nuevo;
END EXCEPTION;

   ON EXCEPTION IN (-535)
      LET wBegin = "S";
      ROLLBACK WORK;
      BEGIN WORK;
   END EXCEPTION WITH RESUME;

   LET wBegin = "N";
--   BEGIN WORK;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

    IF pempresa = "" OR pempresa IS NULL THEN LET pempresa='001'; END IF;
    IF p_Sucursal = "" OR p_Sucursal IS NULL THEN
       LET cCodRet      = "00205";
       LET cMensajeRet  = "CODIGO DE SUCURSAL NULO O BLANCO";
         ROLLBACK WORK;
        IF (wBegin = "S") THEN
           BEGIN WORK;
        END IF;
       RETURN cCodRet,bandera_quita_restante,monto_nuevo;
    ELSE
        LET p_Sucursal=p_Sucursal;
    END IF;
    IF p_Usuario = "" OR p_Usuario IS NULL THEN
       LET cCodRet      = "00192";
       LET cMensajeRet  = "CODIGO DE SUCURSAL NULO O BLANCO";
         ROLLBACK WORK;
        IF (wBegin = "S") THEN
           BEGIN WORK;
        END IF;
       RETURN cCodRet,bandera_quita_restante,monto_nuevo;
    END IF;
    IF p_Folio = ""  OR p_Folio IS NULL THEN

     SELECT
         TRIM(p_Usuario)||DAY(CURRENT)||MONTH(CURRENT)||SUBSTR(current,3,2)||
         SUBSTR(CURRENT,12,2)||substr(current,15,2)
         ||SUBSTR(current,18,2)
      INTO p_Folio
      FROM "informix".dual;
    ELSE
       LET p_Folio = p_Folio;
    END IF;
	-- Obtiene usuario de cobro automatico
	LET cUsrCobroAut = substr(p_Folio,1,8); -- cobroapp	

	LET g_Empresa = pempresa;
	LET g_NumCredito = pNumCredito;

    SELECT fecha_proceso INTO dtFechaHoy
      FROM "informix".sd_maecredanexocrd
     WHERE empresa=pempresa
       AND num_credito = pNumCredito;

-- Obtiene numero de producto
	SELECT num_producto, id_origen, numcte,divisa ,status_cred
	  INTO NumProd, vcodigo_bloq, vnumcte,p_Divisa,p_status_cred
	  FROM "informix".sd_maecredcrd 
	 WHERE num_credito = pNumCredito
       AND empresa     = pempresa;
				  
	-- Se obtiene la cuenta a la cual se le realizo el deposito del prestamo.
	IF p_Transacc = "8150" THEN
		 -- DSB TH 20161108
		SELECT a.numcta
		INTO p_Cuenta
		FROM  "informix".sd_verif_cuentas_crd a
		WHERE a.empresa      = pempresa
		  AND a.numcredisol  = pNumCredito;

		--ME 17/04/2018
		SELECT num_credito
		INTO  cNumCredito
		FROM "informix".sd_promocion_credito
		WHERE  empresa= pempresa
		and num_sol_prestamo = pNumCredito;	
	
	ELSE
		IF NumProd <> '6900' THEN 
               SELECT num_cta
                 INTO p_Cuenta
                 FROM "informix".sd_ctascarg
                WHERE naturaleza='A'
                  AND num_credito=pNumCredito;
	   END IF;
	END IF;
 	IF (NVL(p_Cuenta,"") = "" AND NumProd <> '6900') OR (NVL(p_Cuenta,"") = "" AND p_Transacc = "8150") THEN
	   LET cCodRet      = "00193";
	   LET cMensajeRet  = "El cliente no tiene asociada un cuenta de captacion";
	     ROLLBACK WORK;
		IF (wBegin = "S") THEN
		   BEGIN WORK;
		END IF; 

	   RETURN cCodRet,bandera_quita_restante,monto_nuevo;
    END IF;
	
    --IF p_Monto<= 0.01 THEN   --FMV 6-DIC-11
    IF p_Monto < 0 THEN   --FMV 12-JUL-12
       LET cCodRet      = "00064";
       LET cMensajeRet  = "Se requiere cubrir un monto mayor a 0";
         ROLLBACK WORK;
        IF (wBegin = "S") THEN
           BEGIN WORK;
        END IF;
       RETURN cCodRet,bandera_quita_restante,monto_nuevo;
    END IF;

    LET dCuentaCap=p_Cuenta;


	IF  vcodigo_bloq = '1' THEN
		LET cCodRet      = "00199";
		LET cMensajeRet  = "Cuenta bloqueada";
		  ROLLBACK WORK;
		IF (wBegin = "S") THEN
			BEGIN WORK;
		END IF;

		RETURN cCodRet,bandera_quita_restante,monto_nuevo;
	END IF;
		   
		   
	LET p_Transacc = '8410'; --SU PAGO PRESTAMO PERSONAL QUITA CONDONA
---SE REALIZA  CONSULTA A LA TABLA DE  sd_conceptospagomanualcrd para obtener el codigo fun de la transacciones
/* 	IF p_Transacc IN ("7998") THEN --PAGO CON CGO. A CTA. EN VENT. PREST. PERS.
        SELECT LIMIT 1 cod_fun, concepto INTO pcodfun, cConceptoPago
		FROM "informix".sd_conceptospagomanualcrd
		WHERE transacc = p_Transacc
		AND num_producto = NumProd;
    ELSE
		LET cCodRet      = "00189";
		LET cMensajeRet  = "Transaccion incorrecta";
		--  ROLLBACK WORK;
		IF (wBegin = "S") THEN
			BEGIN WORK;
		END IF;

		RETURN cCodRet,bandera_quita_restante,monto_nuevo;
	END IF; */
	
  SELECT iva INTO dIvaSuc
	FROM bdinteg:"informix".si_sucursales
   WHERE empresa=pempresa
	 AND sucursal=p_Sucursal;

	-- *************************************
	-- Se realiza respaldo del credito     *
	-- *************************************
	IF p_TpOperacion <> 'F' THEN
		EXECUTE PROCEDURE bdicred:"informix".sp_respaldacredito_quitacondonacion('P') INTO CodRetResp;
		IF CodRetResp <> "00000" THEN 
			LET cCodRet = CodRetResp;
			ROLLBACK WORK;
			RETURN cCodRet,bandera_quita_restante,monto_nuevo;
--		ELSE  
--			LET CodRetResp = "000";  
		END IF;	
	END IF;

	--Se obtienen saldos
	EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general(pempresa,pNumCredito)
		INTO cCodRetSP,cMensajeSP,cNumCredito,cCodTipCred,dtFechaOrigen,dtFechaProxPago,dPagoMinimo,dtFechaUltPago,
		iPlazo,iPagosRealizados,dLineaOtorgada,dTasaInteres,dTasaMoratorios,dMontoSBC,dCapVig,dCapTrans,dCapVdoExig,dCapVdoNoExig,
		dSdoActCap,dIntVig,dIntVdo,dIntMoratorio,dIntMes,dSdoActInt,
		dIvaIntVig,dIvaIntVdo,dIvaIntMoratorio, dIvaIntMes,dSdoActIvaInt,dComPend,dIvaCom,dSdoRetenido,
		dSdoTotalLiq,dIntDevengado,dIvaIntDevengado,
		dLineaDisponible,dPagosVdos,cDescStatusCred,iIdUnidadProd,cDescBloqueoCta,cCodCaract2,cDescCausaBloqueoCta, cSitCte,iCausaCte,cDescSitEspCte,cSitCred,iCausaCred,cDescSitEspCred;
		
	IF cCodRetSP <> '000000' THEN
		LET cCodRet = '00068';
		ROLLBACK WORK;
		RETURN cCodRet,bandera_quita_restante,monto_nuevo;
	END IF;
	
	--LET totalquitacapvenc = dSdoTotalLiq - p_Monto;
	
	LET v_PagoCte = p_Monto;
	
	---- Si el tipo es es Condonacion o Quita y no tiene saldo a favor
	IF (p_TpOperacion = 'C' OR p_TpOperacion = 'Q') AND dSdoActCap > 0  THEN 	----- dSdoActCap = saldo capital insoluto
		--- el total de lo que debe menos los accesorios
		LET TotalSinAccesorios = dSdoActCap;
		LET montoAccesorios = dSdoTotalLiq - dSdoActCap;	--- OBTIENE EL MONTO DE INTERES MORA Y VENCIDOS
		-- dSdoTotalLiq - dIntVig - dIntVdo - dIntMoratorio - dIvaIntVig - dIvaIntVdo - dIvaIntMoratorio;
		--- el monto sin accesorios es mayor o igual al monto de pago se rasura Quita o Condonacion
		LET p_Monto_c = p_Monto - dSdoActCap;
		--LET vMontoQuitaCapVencido = p_Monto_c; --Para enviar la transaccion para capital vencido

		IF TotalSinAccesorios >= p_Monto THEN --Saldo insoluto mayor que el pago del cliente
		
			--CONDONA INTERESES MORATORIOS
			FOREACH 
				SELECT a.fecha_cuota, a.capital_status, a.mora_sdo_ordi - a.mora_sdo_ordi_pag, a.mora_sdo_cope - a.mora_sdo_cope_pag,
						a.num_pago
				INTO dFechaCuota, dCapitalStatus, dIntMoraOrdi, dIntMoraCope,
						p_NumPago
				FROM "informix".sd_amortiza_creditocrd a
				WHERE a.empresa     = pempresa
					AND a.num_credito = pNumCredito
					AND a.capital_status IN ("7", "2","6")
				ORDER BY a.num_credito,a.fecha_cuota

				LET dIvaMoraDebe = (dIntMoraOrdi + dIntMoraCope) * dIvaSuc;
				
				LET pcodfun = 110;
				--ELIF  p_TpOperacion = 'Q' THEN LET p_Transacc = '7998';  LET pcodfun = 4;
				--END IF;
				--- actualiza amortiza y maesdoscrd por cada recibo de moratorios 
					CALL "informix".sp_cobra_mora_pp_qc(dFechaCuota,dIvaMoraDebe,dIntMoraCope,dIntMoraOrdi, 
														pempresa,pNumCredito,NumProd,pcodfun,dtFechaHoy,
														p_Folio,p_Sucursal, p_Divisa, p_Transacc,p_numpago, p_TpOperacion)
					RETURNING cCodRetAux,cMensajeRet;
					IF (cCodRetAux <> "000000") THEN
						LET cCodRet     = "00069";
						LET cMensajeRet = "Ocurrio un error al cobrar el interes moratorio";
						  ROLLBACK WORK;
						IF (wBegin = "S") THEN
							BEGIN WORK;
						END IF;
						RETURN cCodRet,bandera_quita_restante,monto_nuevo;
					END IF;
				
				
				LET total_condonado = total_condonado + dIvaMoraDebe + dIntMoraCope + dIntMoraOrdi;

			END FOREACH;
			
			--LET v_CobraIntVenc = dSdoActCap - v_PagoCte;
			--IF p_TpOperacion IN ('Q') AND  v_CobraIntVenc < 0 THEN --Solo en caso de Quita, se condonan intereses Vencidos
			IF p_TpOperacion IN ('Q')  THEN
				--CONDONA INTERESES VENCIDOS
				FOREACH
					SELECT a.fecha_cuota, a.capital_status,a.interes_debe - a.interes_pagado, a.iva_debe - a.iva_pagado,a.num_pago
						INTO dFechaCuota, dCapitalStatus,dIntDebe, dIvaIntDebe,p_NumPago
					FROM "informix".sd_amortiza_creditocrd a
					WHERE a.empresa     = pempresa
						AND a.num_credito = pNumCredito
						AND a.capital_status IN ("7", "2","6")
					ORDER BY a.num_credito,a.fecha_cuota
					--- actualiza amortiza y maesdoscrd por cada recibo de vencidos
					CALL "informix".sp_cobra_int_pp_qc(dFechaCuota,dIntDebe,dIvaIntDebe,dCapitalStatus,
													pempresa,pNumCredito,NumProd,pcodfun,dtFechaHoy,
													p_Folio,p_Sucursal, p_Divisa, p_Transacc,p_numpago,p_TpOperacion)
						RETURNING cCodRetAux,cMensajeRet;
						IF (cCodRetAux <> "000000") THEN
							LET cCodRet = "00070";
							LET cMensajeRet = "Ocurrio un error al cobrar el interes e iva vencido";
							  ROLLBACK WORK;
							IF (wBegin = "S") THEN
								BEGIN WORK;
							END IF;
							RETURN cCodRet,bandera_quita_restante,monto_nuevo;
						END IF;
						
					LET total_condonado = total_condonado + dIntDebe + dIvaIntDebe;
				END FOREACH;
			END IF;
			
			IF p_TpOperacion = 'Q' THEN
				LET bandera_quita_restante = 1;
			END IF;
		END IF;
		
		--- Si es quita y el monto (pago del cliente) no alcanza a pagar el capital se sale y sigue su proceso normal.
		IF p_TpOperacion = 'Q' AND dSdoTotalLiq <= p_Monto THEN
			/*	----- se omite actualización de bandera cuando el pago es igual a la deuda para dejar bandera prendida
			UPDATE bdicred:"informix".sd_bitacora_quitacondonacion
				SET estatus_proceso = 'FI'
			WHERE num_credito = pNumCredito;
			
			IF(cCodRet <> "00000") THEN
				--  ROLLBACK WORK;
				LET cMensajeRet = "Se produjo un error en el pago";
			ELSE
				COMMIT WORK;
			END IF;*/
			COMMIT WORK;
			
			RETURN cCodRet,bandera_quita_restante,monto_nuevo;
			
			
			
		--- si es quita y su saldo el capital menos el pago es negativo, Se tiene un saldo a favor, entonces se condona parte proporcional
		ELIF (p_TpOperacion = 'Q' AND (dSdoActCap - p_Monto) < 0) OR  (p_Monto_c > 0 AND p_Monto <> dSdoTotalLiq) THEN
			
			--- SE OBTIENE LA DIFERENCIA A FAVOR DEL PAGO, ES DECIR SI EL PAGO ES MAYOR AL CAPITAL, LA DIFERENCIA NO SE CONDONA
			--- DEUDA DE CAPITAL 5000 PAGO DE CLIENTE 6000, LA DIFERENCIA DE 1000 NO SE CONDONA, PARA QUE EL PAGO APLIQUE 1000 A ACCESORIOS Y 5000 A CAPITAL
			--- Y EN LOS MOVIMIENTOS SE REFLEJEN LOS 6000 Y NO MANDE ERROR POR CUENTA SALDADA EN EL PROCESO DE PRINCIPAL_SUC_RR
			IF p_TpOperacion = 'Q' THEN
				LET p_Monto_q = montoAccesorios - (p_Monto - dSdoActCap);
			ELIF p_TpOperacion = 'C' THEN
				LET p_Monto_q = montoAccesorios - p_Monto_c;
			END IF;
			
			FOREACH WITH HOLD
				SELECT a.fecha_cuota, a.capital_status, a.mora_sdo_ordi - a.mora_sdo_ordi_pag, a.mora_sdo_cope - a.mora_sdo_cope_pag,
					   a.interes_debe - a.interes_pagado, a.iva_debe - a.iva_pagado,a.capital_debe - a.capital_pagado,a.num_pago
				  INTO dFechaCuota, dCapitalStatus, dIntMoraOrdi, dIntMoraCope,
					   dIntDebe, dIvaIntDebe, dCapitalDebe,p_NumPago
				  FROM "informix".sd_amortiza_creditocrd a
				 WHERE a.empresa     = pempresa
				   AND a.num_credito = pNumCredito
				   AND a.capital_status IN ("7", "2","6")
			  ORDER BY a.num_credito,a.fecha_cuota

				LET dIvaMoraDebe = (dIntMoraOrdi + dIntMoraCope) * dIvaSuc; 	--- Obtiene IVA de Interes moratorio e int mora copete
				LET dAdeudoTotal = dIvaMoraDebe + dIntMoraOrdi + dIntMoraCope;	--- obtiene el monto total interes moratorios, copete y sus ivas
				LET pAdeudoMoraInt = dIntMoraCope + dIntMoraOrdi;				--- Obtiene el total de ineteres mora y copete
				
				---- calcula diferencia
		
				IF dAdeudoTotal > p_Monto_q AND pAdeudoMoraInt > 0 THEN	--- cuando no alcanza el pago a cubrir
				   LET dFactor = pAdeudoMoraInt / dAdeudoTotal;			--- total de intereses mora y copete / entre el total de adeudo intereses + IVAS
				   LET dPagoMoraInt = round(p_Monto_q * dFactor,2);		--- monto de pago por el factor para obtener el pago de interes
				   LET dPagoIvaMoraInt = p_Monto_q - dPagoMoraInt;		--- monto de pago iva moratorio
				ELSE
				   LET dPagoMoraInt = pAdeudoMoraInt;					--- si alcanza a cubrir se manda completo
				   LET dPagoIvaMoraInt = dIvaMoraDebe;        
				END IF;

				IF  pAdeudoMoraInt > 0 THEN											--- se obtiene pago de interes e iva de mora copete
				   LET dFactorMoraCope = (dIntMoraCope / pAdeudoMoraInt);			---- interes copete / total de intereses de mora
				   LET dPagoMoraCope   = round(dPagoMoraInt * dFactorMoraCope,2);	--- obtiene el pago int copete obtenido anteriormente * factor
				   LET dPagoMoraOrdi   = dPagoMoraInt - dPagoMoraCope;				--- pago de iva obtenido por diferencia
				   LET dPagoMoraInt    = 0;
				END IF;

				  -- Se cobra interes moratorio e iva de moratorios.
				  IF (dPagoIvaMoraInt  > 0 or dPagoMoraCope  > 0 or dPagoMoraOrdi  > 0) AND (p_Monto_q > 0) THEN
				      LET pcodfun = 110; 
					  CALL "informix".sp_cobra_mora_pp_qc(dFechaCuota,dPagoIvaMoraInt,dPagoMoraCope,dPagoMoraOrdi, 
													pempresa,pNumCredito,NumProd,pcodfun,dtFechaHoy,
													p_Folio,p_Sucursal, p_Divisa, p_Transacc,p_numpago, p_TpOperacion)
					  RETURNING cCodRetAux,cMensajeRet;
					  IF (cCodRetAux <> "000000") THEN
						   LET cCodRet     = "00071";
						   LET cMensajeRet = "Ocurrio un error al cobrar el interes moratorio";
							  ROLLBACK WORK;
							 IF (wBegin = "S") THEN
								 BEGIN WORK;
							 END IF;
						   RETURN cCodRet,bandera_quita_restante,monto_nuevo;
					  END IF;
					  LET p_Monto_q = p_Monto_q - (dPagoIvaMoraInt + dPagoMoraCope + dPagoMoraOrdi);
					  LET dIntMora    = dIntMora + dPagoMoraCope + dPagoMoraOrdi;
					  LET dIvaIntMora = dIvaIntMora + dPagoIvaMoraInt;
					  LET total_condonado_quita = dPagoIvaMoraInt + dPagoMoraCope + dPagoMoraOrdi;
				  END IF;

				  --- Se calcula el porcentaje a pagar por cada concepto para la cuota.
				LET dAdeudoTotal = dIntDebe + dIvaIntDebe;
				IF dAdeudoTotal > p_Monto_q AND dAdeudoTotal > 0 THEN
				   LET dFactor = dIntDebe / dAdeudoTotal;
				   LET dPagoInt = round(p_Monto_q * dFactor,2);
				   LET dPagoIvaInt = p_Monto_q - dPagoInt;
				ELSE
				   LET dPagoInt = dIntDebe;
				   LET dPagoIvaInt = dIvaIntDebe;        
				END IF;

 				--LET v_CobraIntVenc = dSdoActCap - v_PagoCte; 
				--IF p_TpOperacion IN ('Q') AND v_CobraIntVenc > 0  THEN --Solo en caso de Quita, se condonan intereses Vencidos
				IF p_TpOperacion IN ('Q')  THEN --Solo en caso de Quita, se condonan intereses Vencidos
					 -- Se cobra interes vdo e iva de interes vdo.
					 IF ((dPagoInt > 0 OR  dPagoIvaInt > 0)  AND (p_Monto_q > 0)) THEN
						  CALL "informix".sp_cobra_int_pp_qc(dFechaCuota,dPagoInt,dPagoIvaInt,dCapitalStatus,
													pempresa,pNumCredito,NumProd,pcodfun,dtFechaHoy,
													p_Folio,p_Sucursal, p_Divisa, p_Transacc,p_numpago,p_TpOperacion)
						  RETURNING cCodRetAux,cMensajeRet;
						  IF (cCodRetAux <> "000000") THEN
							  LET cCodRet = "00072";
							  LET cMensajeRet = "Ocurrio un error al cobrar el interes e iva vencido";
								  ROLLBACK WORK;
								 IF (wBegin = "S") THEN
									 BEGIN WORK;
								 END IF;
							  RETURN cCodRet,bandera_quita_restante,monto_nuevo;
						  END IF;

						  LET p_Monto_q = p_Monto_q - (dPagoInt + dPagoIvaInt);
						  LET total_condonado_quita = total_condonado_quita + (dPagoInt + dPagoIvaInt);
					  END IF;
				END IF; 
			END FOREACH;
			/*
			---- condona el resto por quita
			FOREACH 
				SELECT a.fecha_cuota, a.capital_status, a.mora_sdo_ordi - a.mora_sdo_ordi_pag, a.mora_sdo_cope - a.mora_sdo_cope_pag,
						a.num_pago
				INTO dFechaCuota, dCapitalStatus, dIntMoraOrdi, dIntMoraCope,
						p_NumPago
				FROM "informix".sd_amortiza_creditocrd a
				WHERE a.empresa     = pempresa
					AND a.num_credito = pNumCredito
					AND a.capital_status IN ("7", "2")
				ORDER BY a.num_credito,a.fecha_cuota

				LET dIvaMoraDebe = (dIntMoraOrdi + dIntMoraCope) * dIvaSuc;
				LET pcodfun = 110;
				--- actualiza amortiza y maesdoscrd por cada recibo de moratorios 
				CALL "informix".sp_cobra_mora_pp_qc(dFechaCuota,dIvaMoraDebe,dIntMoraCope,dIntMoraOrdi, 
													pempresa,pNumCredito,NumProd,pcodfun,dtFechaHoy,
													p_Folio,p_Sucursal, p_Divisa, p_Transacc,p_numpago, p_TpOperacion)
				RETURNING cCodRetAux,cMensajeRet;
				IF (cCodRetAux <> "000000") THEN
					LET cCodRet     = "00073";
					LET cMensajeRet = "Ocurrio un error al cobrar el interes moratorio";
					  ROLLBACK WORK;
					IF (wBegin = "S") THEN
						BEGIN WORK;
					END IF;
					RETURN cCodRet,bandera_quita_restante,monto_nuevo;
				END IF;
				LET total_condonado = total_condonado + dIvaMoraDebe + dIntMoraCope + dIntMoraOrdi;
			END FOREACH;
			
			LET v_CobraIntVenc = dSdoActCap - v_PagoCte;
			--IF p_TpOperacion IN ('Q') THEN 
			IF p_TpOperacion IN ('Q') AND v_CobraIntVenc < 0 THEN 
				--CONDONA INTERESES VENCIDOS
				FOREACH
					SELECT a.fecha_cuota, a.capital_status,a.interes_debe - a.interes_pagado, a.iva_debe - a.iva_pagado,a.num_pago
						INTO dFechaCuota, dCapitalStatus,dIntDebe, dIvaIntDebe,p_NumPago
					FROM "informix".sd_amortiza_creditocrd a
					WHERE a.empresa     = pempresa
						AND a.num_credito = pNumCredito
						AND a.capital_status IN ("7", "2")
					ORDER BY a.num_credito,a.fecha_cuota
					--- actualiza amortiza y maesdoscrd por cada recibo de vencidos
					CALL "informix".sp_cobra_int_pp_qc(dFechaCuota,dIntDebe,dIvaIntDebe,dCapitalStatus,
													pempresa,pNumCredito,NumProd,pcodfun,dtFechaHoy,
													p_Folio,p_Sucursal, p_Divisa, p_Transacc,p_numpago,p_TpOperacion)
						RETURNING cCodRetAux,cMensajeRet;
						IF (cCodRetAux <> "000000") THEN
							LET cCodRet = "00074";
							LET cMensajeRet = "Ocurrio un error al cobrar el interes e iva vencido";
							  ROLLBACK WORK;
							IF (wBegin = "S") THEN
								BEGIN WORK;
							END IF;
							RETURN cCodRet,bandera_quita_restante,monto_nuevo;
						END IF;
						
					LET total_condonado = total_condonado + dIntDebe + dIvaIntDebe;
					
				END FOREACH;
			END IF;
			
			IF p_TpOperacion = 'Q' THEN
				LET bandera_quita_restante = 1;
			END IF;
		*/
		END IF;
		--- se obtienen los montos de condonacion
		LET suma_condonado = total_condonado_quita + total_condonado;
		-- se resta los montos condonados para obetener diferencia del total a liquidar.
		LET dSdoTotalLiq = dSdoTotalLiq - suma_condonado;
		--- Para ajusta monto de pago y liquide capital.
		--- si el monto total a liquidar restante es menor al pago, se obtiene diferencia
		IF dSdoTotalLiq < p_Monto THEN
			LET monto_nuevo = p_Monto - dSdoActCap;
		END IF;
		
		------ Apaga condonacion
		UPDATE bdicred:"informix".sd_bitacora_quitacondonacion
		SET estatus_proceso = 'FI'
		WHERE num_credito = pNumCredito;
	END IF; 			

	
	IF p_TpOperacion = 'F' THEN  --Para saldar el credito
	--IF p_TpOperacion IN ('Q','C') THEN --Prueba
		IF totalquitacapvenc > 0 AND p_TpOperacion = 'F'  THEN --Se genera transaccion por el monto del capital vencido
		    --LET totalquitacapvenc = totalquitacapvenc * -1;
			IF NumProd = '6300' THEN
				LET p_codigo_ref = 8;
				LET p_Transacc = 8416;
			ELIF NumProd = '7600' THEN
				LET p_codigo_ref = 15;
				LET p_Transacc = 8423;
			ELIF NumProd = '7700' THEN
				LET p_codigo_ref = 22;
				LET p_Transacc = 8430;
			ELIF NumProd = '6800' THEN
				LET p_codigo_ref = 29;
				LET p_Transacc = 8389;
			END IF;		
			LET pcodfun = 110; 
--rss						
			--Se genera movimiento de capital vencido
			CALL "informix".genmovcrd(pempresa,pNumCredito,NumProd,p_codigo_ref,pcodfun,dtFechaHoy,totalquitacapvenc,p_Folio,p_Sucursal, p_Divisa, p_Transacc ,p_numpago, "") 
			RETURNING cCodRet, cMensajeRet;
			IF cCodRet::INTEGER <> 0 THEN
				LET cCodRet = "00075";
				LET cMensajeRet = "Ocurrio un error al generar movimiento de capital";
			    ROLLBACK WORK;
				IF (wBegin = "S") THEN
					BEGIN WORK;
				END IF;
				RETURN cCodRet,bandera_quita_restante,monto_nuevo;
			END IF;
			
			--Se genera movimiento de cancelacion de linea solo para Prestamo Digital
			IF  NumProd = '6800' THEN
				CALL "informix".genmovcrd(pempresa,pNumCredito, '6800', 2, '002', dtFechaHoy,dLineaOtorgada,p_Folio,p_Sucursal, '01', '7480', 'Cancelacion Linea Prestamo Digital' , '' ) 
				RETURNING cCodRet, cMensajeRet;				
				IF cCodRet::INTEGER <> 0 THEN
					LET cCodRet = "00076";
					LET cMensajeRet = "currio un error al generar movimiento de capital PD";
					ROLLBACK WORK;
					IF (wBegin = "S") THEN
						BEGIN WORK;
					END IF;
					RETURN cCodRet,bandera_quita_restante,monto_nuevo;
				END IF;
			END IF;
		ELIF  totalquitacapvenc = 0 THEN
			--Se genera movimiento de cancelacion de linea solo para Prestamo Digital, cuando el capital se salda con el pago y se debe cancelar el credito
			IF  NumProd = '6800' THEN
				CALL "informix".genmovcrd(pempresa,pNumCredito, '6800', 2, '002', dtFechaHoy,dLineaOtorgada,p_Folio,p_Sucursal, '01', '7480', 'Cancelacion Linea Prestamo Digital' , '' ) 
				RETURNING cCodRet, cMensajeRet;				
				IF cCodRet::INTEGER <> 0 THEN
					LET cCodRet = "00076";
					LET cMensajeRet = "currio un error al generar movimiento de capital PD";
					ROLLBACK WORK;
					IF (wBegin = "S") THEN
						BEGIN WORK;
					END IF;
					RETURN cCodRet,bandera_quita_restante,monto_nuevo;
				END IF;
			END IF;
		END IF;

		/*IF dCapTrans > 0 THEN
			CALL "informix".genmovcrd(pempresa,pNumCredito,NumProd,19,pcodfun,dtFechaHoy,dCapTrans,
				p_Folio,p_Sucursal, p_Divisa, '8427',p_numpago,"") --CAPITAL VENCIDO TRANSITORIO
			RETURNING cCodRet, cMensajeRet;
		END IF;*/
		
		/*IF dCapVdoExig > 0 THEN
			CALL "informix".genmovcrd(pempresa,pNumCredito,NumProd,20,pcodfun,dtFechaHoy,dCapVdoExig,
				p_Folio,p_Sucursal, p_Divisa, '8428',p_numpago,"") --CAPITAL VENCIDO 
			RETURNING cCodRet, cMensajeRet;
		END IF;*/
		
		/*IF dCapVdoNoExig > 0 THEN
			CALL "informix".genmovcrd(pempresa,pNumCredito,NumProd,21,pcodfun,dtFechaHoy,dCapVdoNoExig,
				p_Folio,p_Sucursal, p_Divisa, '8429',p_numpago,"") --TRASP. CAPITAL VENCIDO NO EXIG. A VIG.
			RETURNING cCodRet, cMensajeRet;
		END IF;*/
		BEGIN WORK;
		
		Update bdicred:sd_maecredcrd Set status_cred= 'FF' Where empresa = pempresa and num_credito= pNumCredito;
			
		-- Se Actualizan los saldos
		UPDATE bdicred:sd_maesdoscrd
		SET    mto_venc_trasp=0, monto_vencido=0, cap_tras_no_venci=0, int_tra_no_exig =0, sdo_no_exig = 0, sdo_capital=0,
			   sdo_cap_insoluto=0, monto_otorgado = 0, monto_financiado = 0, sdo_contab_mora = 0, sdo_moratorio = 0,
			   sdo_intereses = 0, sdo_dia_ant_int = 0, provision_normal = 0, sdo_cap_insoluto = 0, sdo_dia_ant_cap = 0, sdo_mes_ant_cap = 0,
			   sdo_acum_mes_cap = 0, mto_capitalizado = 0, mto_ministra_cap = 0, cargos_dia_cap = 0, abonos_dia_cap = 0, cargos_mes_cap = 0,
			   abonos_mes_cap = 0, sdo_global_int = 0, mto_venc_int = 0, mto_fin_ven_trasp = 0
		WHERE  empresa = pempresa
		AND    num_credito= pNumCredito;
		
		-- Se Actualizan las amortizaciones

		UPDATE sd_amortiza_creditocrd
		SET    capital_status = 5, iva_pagado = iva_debe, mora_iva_debe = mora_iva_debe + mora_provi_ordi + mora_provi_cope,
			   mora_iva_pagado = mora_iva_debe + mora_provi_ordi + mora_provi_cope, mora_provi_ordi = 0, mora_provi_cope = 0, capital_pagado  = 0
		WHERE  empresa = pempresa
		AND    num_credito= pNumCredito
		AND    (capital_status in ('2','7','6') or interes_debe <> 0);
		
	END IF;
	
    IF cCodRet::INTEGER <> 0 THEN
         ROLLBACK WORK;
		LET cMensajeRet = "Se produjo un error en el pago";
    ELSE
        COMMIT WORK;
	END IF;
	
  RETURN cCodRet,bandera_quita_restante,monto_nuevo;
END;
END PROCEDURE

DOCUMENT
'DESCRIPCION: ',
'BASE DE DATOS: BDICRED',
'CREADOR: ',
'FOLIO: Condonacion de intereses moratorios y vencidos.';

CREATE PROCEDURE "informix".sp_principal_llama_recompensa ()
RETURNING CHAR(6);

DEFINE v_FolioSUC        	CHAR(16);
DEFINE v_fecha_folio        CHAR(10);
DEFINE sql_err          	INTEGER;
DEFINE isam_err         	INTEGER;
DEFINE error_info       	VARCHAR(60);
DEFINE vsql                 CHAR(2000);
DEFINE CodRet           	CHAR(6);
DEFINE v_num_credito		CHAR(20);
DEFINE v_monto_recompensa	CHAR(20);

DEFINE g_Remanente			MONEY(14,2);
DEFINE g_IntMoraCob 		MONEY(14,2);
DEFINE g_IntVencCob 		MONEY(14,2);
DEFINE g_CapVencCob 		MONEY(14,2);
DEFINE g_IntVigCob 			MONEY(14,2);
DEFINE g_CapVigCob 			MONEY(14,2);
DEFINE g_Impuesto 			MONEY(14,2);
DEFINE g_Comision 			MONEY(14,2);	
DEFINE g_Seguro				MONEY(14,2);

LET v_FolioSUC        		= '';
LET v_fecha_folio        	= '';
LET sql_err             	= 0;
LET isam_err            	= 0;
LET error_info          	= "";
LET CodRet              	= '000000';
LET v_num_credito			='';
LET v_monto_recompensa					='';


	BEGIN
		ON EXCEPTION SET sql_err, isam_err, error_info
			
			LET CodRet = sql_err;
			RETURN CodRet;
		END EXCEPTION;

		--SET DEBUG FILE TO "/tmp/sp_principal_llama_recompensa.out";
		--TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;
   --BEGIN WORK;
		
		

		CREATE TABLE "informix".carga_recompensa
		(
		num_credito char(20),
		monto char(20),
		primary key (num_credito))
		extent size 32 next size 32 lock mode row;

        LET vsql = '';
        LET vsql=  'echo "LOAD FROM /respaldos/carga_recompensa_'||day(today)||LPAD (MONTH(today),2,"0")||year(today)||'.unl insert into bdicred:carga_recompensa;">/respaldos/carga_recompensa.sql';      
        system vsql;
        
        LET vsql='chmod a+rwx /respaldos/carga_recompensa.sql';
        System vsql;
        			
        LET vsql = '';
        LET vsql= 'dbaccess bdicred /respaldos/carga_recompensa.sql';
        system vsql;
        			
        LET vsql = vsql;
        LET vsql ='rm /respaldos/carga_recompensa.sql';

	FOREACH WITH HOLD

		SELECT a.num_credito,a.monto
		INTO v_num_credito,v_monto_recompensa
		FROM carga_recompensa a,
		     sd_maecred b,
			 sd_maesdos c
		where a.num_credito = b.num_credito
		  and b.num_credito = c.num_credito
		  and b.status_cred in ('AA','E1')
		  and (c.monto_vencido + c.mto_venc_trasp) = 0

		LET v_fecha_folio  = USER||substr((current HOUR TO HOUR),1,2)||substr((current HOUR TO MINUTE),3,3)||substr((current HOUR TO SECOND),6,4);
		LET v_FolioSUC = trim(v_fecha_folio)||1||1||1;

		CALL principalrefer ('001', v_num_credito, 1, '', user, '9050', v_FolioSUC, '8800', 0, v_monto_recompensa, v_FolioSUC) -- Abono por recompensa inmediata
		RETURNING CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
		
	END FOREACH;

	DROP TABLE carga_recompensa;

	COMMIT WORK;
	
	IF CodRet = '000' THEN
		LET CodRet = '00000';
	END IF;	

	RETURN CodRet;

	END;
	
END PROCEDURE
DOCUMENT
'Programa para implementar recompensa a creditos de manera especial',
'Puede ser llamado de manera manual',
'AUTOR : Jorge Alberto Rayas Chan',
'FECHA : 13/Octubre/2017',
'VERSION: 1.00.000',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_proyecta_pfsms
(
pTipo 			SMALLINT, -- 1- consulta proyeccion, 2-regresa el desglose, 3-guarda proyeccion
pSucursal 		CHAR(4),
pEjecutivo		CHAR(8),
pNumPromocion 	SMALLINT, -- 1-Perma.Efec, 2-Perma.Comps, 3-Perma.Saldos, 4-Temp.Efec, 5-Temp.Comps, 6-Temp.Saldo 7-Esp.Efec, 8-Esp.Comps, 9-Esp.Saldo
pNumCredito 	CHAR(20),
pNumTarjeta		CHAR(20),
pMonto 			DECIMAL(18,2),
pPlazo 			SMALLINT,
pTasa			SMALLINT,
pFolioMovto		CHAR(16)
)

RETURNING
	CHAR(5) 		AS cod_ret,
	CHAR(80)		AS descripcion,
	DECIMAL(18,2)	AS total_pagar,
	SMALLINT		AS num_plazo,
	DECIMAL(18,2)	AS pago_mensual,
	DECIMAL(18,2)	AS interes_iva,
	DECIMAL(18,2)	AS saldo_tdc,
	CHAR(16)		AS folio_promo,
	SMALLINT		AS Num_promocion;
	
	---DECLARACIONES
    DEFINE iSqlErr				INTEGER;
    DEFINE iIsamErr				INTEGER;
    DEFINE cErrorInfo			CHAR(80);
    DEFINE cCodRet				CHAR(5);
    DEFINE cMensajeRet			CHAR(80);
	DEFINE sNumPagos			SMALLINT;
	DEFINE dTasaAnual			DECIMAL(18,6);
	DEFINE dTasaAnualIva		DECIMAL(18,6);
	DEFINE dFactorIvaSucursal	DECIMAL(5,3);
	DEFINE dPagoMensual			DECIMAL(18,6);
	DEFINE dPagoPorPlazo		DECIMAL(18,6);
	DEFINE dInterIvaPlazoMax	DECIMAL(18,6);
	DEFINE dFactorInteresIva	DECIMAL(18,6);
	DEFINE dComisDisposicion	DECIMAL(18,6);
	DEFINE dIvaComision			DECIMAL(18,6);
	DEFINE dFactorComDispEfect	DECIMAL(18,6);
	DEFINE cCodComDispEfectivo	CHAR(4);
	DEFINE dValorMinDiferir		DECIMAL(18,6);
	DEFINE dMontoDiferir		DECIMAL(18,6);
	DEFINE dTotalPagar			DECIMAL(18,6);
	DEFINE vcNumCte				VARCHAR(20);
	DEFINE cCodRetGF			CHAR(6);
	DEFINE cFolioSucGF			CHAR(16);
	DEFINE vcNomEjecutivo		VARCHAR(45);
	DEFINE vcNomPromocion		VARCHAR(50);
	DEFINE dSaldoTDC			DECIMAL(18,2);
	DEFINE cFolioPromo			CHAR(16);
	DEFINE dtFechaHoy			DATE;
	DEFINE dtFechaCorte			DATE;
	DEFINE dMontoPromo			DECIMAL(18,2);
	DEFINE cCodRetGenMov	  CHAR(10);
	DEFINE cMsjeGenMov		  CHAR(80);
    DEFINE vsucorig           CHAR(4);
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general
	DEFINE cCsg_codigo_ret			CHAR(6);
	DEFINE dCsg_cap_vig				DECIMAL(18,2);	
	DEFINE dCsg_tot_liquidacion		DECIMAL(18,2);	
	DEFINE dCsg_linea_disp			DECIMAL(18,2);
    DEFINE vvalor1                  DECIMAL(18,6);
    DEFINE vvalor2                  DECIMAL(18,6);
    DEFINE vcompras                 SMALLINT;
	DEFINE dMontoDiferir_aux	    DECIMAL(18,6);
    DEFINE vdivisa                  CHAR(2);
    DEFINE v_dv                     CHAR(2);
    DEFINE v_tipocambio             DECIMAL(14,6);
    DEFINE vPromoRetSdo             DECIMAL(18,6);
    DEFINE vPromoRetSdo2            DECIMAL(18,6);
    DEFINE vs_precal_num_promo      SMALLINT;  --FMV 19-NOV-13
    DEFINE vs_secuencia             INTEGER;
    -- VARIABLES PARA OBTENER RESPUESTA DEL SP: sp_proyecta_prest_credisol
    DEFINE c_CodigoRet_pp           CHAR(6);
    DEFINE i_Periodo_pp             INTEGER;
    DEFINE d_FechaCouta_pp          DATE;
    DEFINE dd_SaldoInicial_pp       DECIMAL(18,2);
    DEFINE dd_Mensualidad_pp        DECIMAL(18,2);
    DEFINE dd_Mensualidad_aux_pp    DECIMAL(18,2);
    DEFINE dd_Intereses_pp          DECIMAL(18,2);
    DEFINE dd_IvaInteres_pp         DECIMAL(18,2);
    DEFINE dd_Capital_pp            DECIMAL(18,2);
    DEFINE dd_SaldoFinal_pp         DECIMAL(18,2);
    DEFINE dd_SaldoFinal_aux_pp     DECIMAL(18,2);
    DEFINE s_DiasPeriodo_pp         SMALLINT;
    DEFINE d_FechaAper_pp           DATE;
    DEFINE c_NumMesesPago_pp        CHAR(3);
    DEFINE i_Cont                   SMALLINT;
    DEFINE v_bandesp                SMALLINT;
    DEFINE v_NumCredito             CHAR(20);
	DEFINE sCountExists				INTEGER;
	DEFINE sYield					INTEGER;	
	DEFINE cBandera268				CHAR(1);
	DEFINE dSdoRetenidoApoyo		DECIMAL(18,6);
	

	---INICIALIZACIONES
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	LET cErrorInfo			= '';
	LET cCodRet				= '00000';
	LET cMensajeRet			= 'PROCESO EXITOSO';
	LET sNumPagos			= 0;
	LET dTasaAnual			= 0.0;
	LET dTasaAnualIva		= 0.0;
	LET dFactorIvaSucursal	= 0.0;
	LET dPagoMensual		= 0.0;
	LET dPagoPorPlazo		= 0.0;
	LET dInterIvaPlazoMax	= 0.0;
	LET dFactorInteresIva	= 0.0;
	LET dComisDisposicion	= 0.0;
	LET dIvaComision		= 0.0;
	LET dFactorComDispEfect	= 0.0;
	LET cCodComDispEfectivo	= '';
	LET dValorMinDiferir	= 0.0;
	LET dMontoDiferir		= 0.0;
	LET dTotalPagar			= 0.0;
	LET vcNumCte			= '';
	LET cCodRetGF			= '000000';
	LET cFolioSucGF			= '';
	LET vcNomEjecutivo		= '';
	LET vcNomPromocion		= '';
	LET dSaldoTDC			= 0.0;
	LET cFolioPromo			= '';
	LET dtFechaHoy			= DATE(1);
	LET dtFechaCorte		= DATE(1);
	LET dMontoPromo			= 0.0;
	LET cCodRetGenMov		= "";
	LET cMsjeGenMov		    = "";
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general
	LET cCsg_codigo_ret				= "000000";
	LET dCsg_cap_vig				= 0.0;		
	LET dCsg_tot_liquidacion		= 0.0;
	LET dCsg_linea_disp				= 0.0;
    LET vvalor1                     = 0;
    LET vvalor2                     = 0;
    LET vcompras                    = 0;
	LET dMontoDiferir_aux	        = 0;
    LET vdivisa                     = '00';
    LET v_dv                        = "00";
    LET v_tipocambio                = 0;
    LET vsucorig                    = "";
    LET vPromoRetSdo                = 0;
    LET vPromoRetSdo2               = 0;
    LET vs_precal_num_promo         = 0;
    LET vs_secuencia                = 0;
    -- VARIABLES PARA OBTENER RESPUESTA DEL SP: sp_proyecta_prest_credisol
    LET c_CodigoRet_pp              = '';
    LET i_Periodo_pp                = 0;
    LET d_FechaCouta_pp             = MDY(1,1,1900);
    LET dd_SaldoInicial_pp          = 0.0;
    LET dd_Mensualidad_pp           = 0.0;
    LET dd_Mensualidad_aux_pp       = 0.0;
    LET dd_Intereses_pp             = 0.0;
    LET dd_IvaInteres_pp            = 0.0;
    LET dd_Capital_pp               = 0.0;
    LET dd_SaldoFinal_pp            = 0.0;
    LET dd_SaldoFinal_aux_pp        = 0.0;
    LET s_DiasPeriodo_pp            = 0;
    LET d_FechaAper_pp              = MDY(1,1,1900);
    LET c_NumMesesPago_pp           = '';
    LET i_Cont                      = 0;
    LET v_bandesp                   = 0;
    LET v_NumCredito                ='';
	LET sCountExists				= 0;
	LET sYield						= 0;
	LET cBandera268					= '0';
	LET dSdoRetenidoApoyo			= 0;


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			RETURN cCodRet, cMensajeRet, NVL(dTotalPagar,0), NVL(pPlazo,0), NVL(dPagoMensual,0), NVL(dInterIvaPlazoMax,0), NVL(dSaldoTDC,0), NVL(cFolioPromo,''), NVL(pNumPromocion,0);
       END IF;
    END EXCEPTION;
	
	ON EXCEPTION IN (-268) SET iSqlErr, iIsamErr, cErrorInfo
		IF cBandera268 = '1' THEN  -- El error es por insertar en la tabla sd_promocion_credito
			SELECT --pEjecutivo 
				year(current) || lpad(month(current),2,0) || lpad(day(current),2,0)
				|| substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,1,2)
				||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,4,2)
				||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,7,2)
				||lpad(bdicheq:sp_random(),2,'0'), sysmaster:yieldn( 1 )
			  INTO cFolioSucGF, sYield FROM sysmaster:sysshmvals;

			--SET DEBUG FILE TO '/informix/mahr/sp_proy_pfsms.out';
			--TRACE ON;
			--LET cFolioPromo = cFolioPromo;
			--let pNumCredito = pNumCredito;			
			LET cFolioPromo = cFolioSucGF;
			LET cCodRet = '00000';
			LET cMensajeRet = '';
		
			INSERT INTO "informix".sd_promocion_credito
				(empresa,sistema,num_promo,fecha,ejecutivo,num_cte,num_credito,num_tarjeta,plazo,folio_suc,monto_actual,monto_int_iva,mensualidad,status,nombre_promo,sucursal,num_sol_prestamo,num_pro_prestamo,folio_movto)
			VALUES ('001','06',pNumPromocion,dtFechaHoy,pEjecutivo,vcNumCte, pNumCredito,pNumTarjeta,pPlazo,cFolioSucGF,pMonto,dInterIvaPlazoMax,dPagoMensual,0,vcNomPromocion,pSucursal,'','6900',pFolioMovto);
	  
	  ELSE
			RETURN cCodRet, cMensajeRet, NVL(dTotalPagar,0), NVL(pPlazo,0), NVL(dPagoMensual,0), NVL(dInterIvaPlazoMax,0), NVL(dSaldoTDC,0), NVL(cFolioPromo,''), NVL(pNumPromocion,0);	  
	  END IF;
	END EXCEPTION WITH RESUME;
   

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    --SET DEBUG FILE TO '/tmp/sp_proyecta_pfsms.out';
	--TRACE ON;
	  
	--SE OBTIENE LA FECHA HOY.
	SELECT fecha_hoy INTO dtFechaHoy
	  FROM "informix".sd_fechas WHERE empresa = '001';	  


	SELECT valor INTO v_dv FROM bdinteg:si_param WHERE cod_param = 17;

    SELECT precio_venta
	  INTO v_tipocambio
	  FROM bdinteg:"informix".si_tpcambio
	 WHERE empresa = "001"
	   AND divisa = v_dv
	   AND clase_tpcambio = "O"
	   AND fecha_tpcambio = (SELECT MAX(fecha_tpcambio)
				   FROM bdinteg:"informix".si_tpcambio
				  WHERE empresa = "001"
					AND divisa = v_dv);

	-- VALIDA QUE LOS PARAMETROS NO VENGAN VACIOS
    IF pTipo IS NULL OR NVL(pSucursal,'') = '' OR NVL(pEjecutivo,'') = '' OR pNumPromocion IS NULL
			OR (NVL(pNumCredito,'') = '' AND NVL(pNumTarjeta,'') = '') OR (pTipo = 1 AND pMonto IS NULL)
			OR (pTipo = 2 AND pMonto IS NULL) OR (pTipo = 3 AND NVL(pMonto,0) = 0)
			OR (pTipo = 1 AND pPlazo IS NULL) OR (pTipo = 2 AND pPlazo IS NULL )
			OR (pTipo = 3 AND NVL(pPlazo,0) = 0) THEN
		LET cCodRet = '00432';
		LET cMensajeRet = 'FALTA UNO O MAS PARAMETROS';
    END IF;
	-- VALIDA EL TIPO DE EJECUCION
	IF cCodRet = '00000' AND pTipo NOT IN (1,2,3) THEN
		LET cCodRet = '00434';
		LET cMensajeRet = 'EL PARAMETRO TIPO NO ES VALIDO';
	END IF;
	-- VALIDA EL EJECUTIVO Y OBTIENE EL SU NOMBRE
	IF cCodRet = '00000' THEN
        SELECT nombre
		INTO vcNomEjecutivo
		FROM bdinteg:"informix".si_ejecut
		WHERE ejecutivo = pEjecutivo;
		IF NVL(vcNomEjecutivo,'') = '' THEN
			LET cCodRet = '00435';
			LET cMensajeRet = 'CODIGO DE EJECUTIVO NO ES VALIDO';
		END IF;
	END IF;

	--*** VALOR DE PARAMETRO 901 ESTA POR MIENTRAS
	-- OBTIENE EL VALOR MINIMO CONTEMPLADO PARA EL MONTO A DIFERIR EN LAS PROMOCIONES DE CREDISOLUCION
	IF cCodRet = '00000' THEN
		SELECT TRIM(valor)::DECIMAL(18,2)
		INTO dValorMinDiferir
		FROM "informix".sd_param
		WHERE cod_param  = '029';
		IF dValorMinDiferir IS NULL THEN
			LET cCodRet = '00437';
			LET cMensajeRet = 'ERROR AL OBTENER EL PARAMETRO DEL VALOR MINIMO A DIFERIR';
		END IF;
	END IF;


	SELECT COUNT(num_credito) INTO sCountExists FROM "informix".sd_credpaso 
	 WHERE num_credito = pNumCredito and num_promo = pNumPromocion and activo = 1;
    --IF EXISTS() THEN
	IF sCountExists	> 0 THEN
		LET sCountExists = 0;
        LET v_bandesp=1;
    END IF

    IF pNumPromocion IN (1, 4, 7) THEN   --FMV 11nov13 : CampaÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ±as 1.-Permanente, 4.-Temporal y 7.-Especial en Efectivo
        -- VALIDA QUE EL MONTO A DIFERIR SEA MAYOR AL VALOR MINIMO DE LA PROMOCION PARA LA PROMOCION DE EFECTIVO
        -- Mahr Feb2015: No valide el monto para credisoluciones ya credisol ya generadas, las ya autorizadas, no las rechaza (solicitudes con saldo a favor)
        -- credisol, ya generadas y pendientes, si las pase.
        IF cCodRet = '00000' AND pMonto < dValorMinDiferir 
            AND ( (select count(*) from bdicred:sd_promocion_credito where num_promo = pNumPromocion and num_credito = pNumCredito 
                           and folio_movto = pFolioMovto and status = 0 ) = 0 ) THEN
            LET cCodRet = '01433';
			LET cMensajeRet = 'EL CLIENTE NO ES VIABLE PARA DIFERIR ';
		END IF;
	END IF;

	-- VALIDA QUE AL MENOS RECIBA EL NUMERO DE CREDITO O LA TARJETA
    IF cCodRet = '00000' AND (NVL(pNumCredito,'') = '' OR NVL(pNumTarjeta,'') = '' ) THEN
		IF NVL(pNumCredito,'') <> '' THEN
            SELECT a.num_credito, a.numcte, a.divisa, a.sucursal
			  INTO pNumCredito,  vcNumCte, vdivisa, vsucorig
			  FROM bdicred:"informix".sd_maecred a
			  INNER JOIN bdicred:sd_maesdos maes on (a.num_credito = maes.num_credito)
		     WHERE a.empresa = '001' 
			   AND a.num_credito = pNumCredito
			   AND a.status_cred IN ('AA','E1') 
			   and (maes.monto_vencido + maes.mto_venc_trasp) = 0;

            IF NVL(pNumCredito,'') = '' THEN
                LET cCodRet = '00439';
				LET cMensajeRet = 'NUMERO DE CREDITO NO ESTA VIGENTE O NO ES VALIDO';
			END IF
        ELIF NVL(pNumTarjeta,'') <> '' THEN

            SELECT a.num_tarjeta, b.num_credito, a.numcte, b.divisa,sucursal
		  	  INTO pNumTarjeta, pNumCredito, vcNumCte,vdivisa,vsucorig
			  FROM "informix".sd_tarjeta a, "informix".sd_maecred b,  "informix".sd_maesdos maes
			 WHERE a.num_tarjeta = pNumTarjeta
               AND a.tipo_tarjeta = 'T'
               AND a.status_tar IN ('A','I')			 
			   AND a.empresa = b.empresa
			   AND a.num_credito = b.num_credito			 
			   AND a.num_credito = maes.num_credito
			   AND b.status_cred IN ('AA','E1') 
			   and (maes.monto_vencido+maes.mto_venc_trasp) = 0;

            IF NVL(pNumTarjeta,'') = '' THEN
                LET cCodRet = '00440';
				LET cMensajeRet = 'NUMERO DE TARJETA NO ES VALIDO O SU CREDITO NO ESTA VIGENTE';
			END IF;
		END IF;
	END IF;

    -- VALIDA QUE EL NUMERO DE PROMOCION
    IF cCodRet = '00000' THEN
        -- OBTIENE LA PROMOCION PRECALIFICADA.
		/*IF pNumPromocion IN (2,5,8)THEN --COMPRAS
            SELECT MAX(secuencia)
             INTO vs_secuencia
             FROM "informix".sd_precal_credsol
            WHERE num_credito = pNumCredito
            AND num_promo IN (2,5,8);
        ELIF pNumPromocion IN (3,6,9)THEN --SALDOS
            SELECT max(secuencia)
             INTO vs_secuencia
             FROM "informix".sd_precal_credsol
            WHERE num_credito = pNumCredito
            AND num_promo IN (3,6,9);
        ELIF pNumPromocion IN (1,4,7)THEN --EFECTIVO
            SELECT max(secuencia)
             INTO vs_secuencia
             FROM "informix".sd_precal_credsol
            WHERE num_credito = pNumCredito
            AND num_promo IN (1,4,7);
        END IF

        SELECT num_promo
          INTO vs_precal_num_promo
          FROM "informix".sd_precal_credsol
         WHERE num_credito = pNumCredito
           AND secuencia = vs_secuencia;*/

        -- FMV Reasigana el valor de la promocion por la campaÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ±a previamente valida en el Sp_val_datos_promo
        --IF NVL(vs_precal_num_promo,0) <> 0 THEN
        --    LET pNumPromocion = vs_precal_num_promo;
        --END IF;  --  Para provenientes de sms no valida, ya que no se inserta en sd_precal_credsol y  cambia numero de promocion.

        SELECT nombre_promo
          INTO vcNomPromocion
          FROM "informix".sd_promocion
         WHERE num_promo = pNumPromocion;
        IF NVL(vcNomPromocion,'') = '' THEN
            LET cCodRet = '00436';
            LET cMensajeRet = 'EL PARAMETRO NUMERO DE PROMOCION NO ES VALIDO';
        END IF;
    END IF;

    IF cCodRet = '00000' THEN
		/*--SE OBTIENE LA FECHA HOY.
		SELECT fecha_hoy INTO dtFechaHoy  FROM "informix".sd_fechas  WHERE empresa = '001'; se cambia ubicacion de consulta*/

		--- OBTIENE LOS SALDOS ACTUALES DEL CREDITO
        /*EXECUTE PROCEDURE "informix".sp_consulta_saldos_general('001',pNumCredito)		
		INTO cCsg_codigo_ret,cCsg_mensaje_ret,cCsg_num_credito,cCsg_cod_tipcred,dtCsg_fec_origen,dtCsg_fec_prox_pago,dCsg_pago_min,
			dtCsg_fec_ult_pago,iCsg_plazo,iCsg_pagos_realizados,dCsg_linea_otorgada,dCsg_tasa_interes,dCsg_tasa_moratorios,
			dCsg_monto_sbc,dCsg_cap_vig,dCsg_cap_trans,dCsg_cap_vdo_exig,dCsg_cap_vdo_no_exig,dCsg_sdo_act_total_cap,dCsg_int_vig,
			dCsg_int_vdo,dCsg_int_moratorios,dCsg_int_mes,dCsg_sdo_act_total_int,dCsg_iva_int_vig,dCsg_iva_int_vdo,dCsg_iva_int_moratorios,
			dCsg_iva_int_mes,dCsg_sdo_act_total_iva,dCsg_com_pend,dCsg_iva_com,dCsg_sdo_retenido,dCsg_tot_liquidacion,dCsg_int_devengado,
			dCsg_iva_int_devengado,dCsg_linea_disp,dCsg_pagos_vdos,cCsg_desc_status_cred,iCsg_id_bloqueo_cred,cCsg_bloqueo_cta,
			cCsg_id_causa_bloq_cred,cCsg_causa_bloqueo_cta,cCsg_id_sit_esp_cte,iCsg_id_causa_esp_cte,cCsg_sit_esp_cte,cCsg_id_sit_esp_cred,
			iCsg_id_causa_esp_cred,cCsg_sit_esp_cred;*/
			
		SELECT sdo_capital,  (monto_otorgado - (sdo_cap_insoluto + sdo_retenido)), (sdo_cap_insoluto + sdo_retenido) 
		  INTO dCsg_cap_vig, dCsg_linea_disp,									   dCsg_tot_liquidacion
		  FROM bdicred:sd_maesdos WHERE num_credito = pNumCredito;			
		LET cCsg_codigo_ret = '000000';

		IF cCsg_codigo_ret::INTEGER <> 0 THEN
            LET cCodRet = '00441';
			LET cMensajeRet = 'OCURRIO UN ERROR EN EL SP DE CONSULTA DE SALDOS GENERAL';
		ELSE
            IF pTipo = 2 AND pNumPromocion in (3, 6, 9) AND pMonto = 0 AND pPlazo = 0 THEN
                --LET dSaldoTDC = dCsg_linea_otorgada - dCsg_linea_disp;
                LET dSaldoTDC =dCsg_cap_vig;
            ELSE
                IF pTipo = 1 THEN
                    -- OBTIENE EL PLAZO MINIMO PARA EL NUMERO DE CAMPAÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂA
                    /*SELECT MAX(plazo)					-- No se valida en tabla ya que el plazo podria haber cambiado en BD.
				 	  INTO sNumPagos
					  FROM "informix".sd_tasa_plazo_sms
					 WHERE num_promo = pNumPromocion;*/
					IF pPlazo = 0 THEN LET sNumPagos = 0; ELSE LET sNumPagos = pPlazo; END IF;
                    IF NVL(sNumPagos,0) = 0 THEN
                        LET cCodRet = '00442';
						LET cMensajeRet = 'ERROR AL OBTENER EL PLAZO MAXIMO DE LA PROMOCION';
                    END IF;
                ELSE
					-- VALIDA EL PLAZO
                    /*SELECT plazo						-- No se valida en tabla ya que el plazo podria haber cambiado en BD.
   			    	  INTO sNumPagos
					  FROM "informix".sd_tasa_plazo_sms
					 WHERE num_promo = pNumPromocion
                       AND plazo = pPlazo
                       AND plazo_activo = 1;    --FMV 5jun14: Valida este activo 
					LET sNumPagos = NVL(sNumPagos,0);  */
					IF pPlazo = 0 THEN LET sNumPagos = 0; ELSE LET sNumPagos = pPlazo; END IF;
					LET sNumPagos = pPlazo;
                    IF sNumPagos = 0 THEN
                        LET cCodRet = '00443';
						LET cMensajeRet = 'EL PLAZO NO ES VALIDO PARA LA PROMOCION';
                    END IF;
                END IF;

				
                IF cCodRet = '00000' THEN
					-- OBTIENE LA TASA DE LA PROMOCION		2019: Ya no valida tabla por que plazos y tasas varian en BD
                    /*SELECT tasa	INTO dTasaAnual
					  FROM "informix".sd_tasa_plazo_sms
				 	 WHERE num_promo = pNumPromocion AND plazo = sNumPagos AND plazo_activo = 1;    --FMV 5jun14: Valida este activo */
					LET dTasaAnual = pTasa;
					
					-- VALIDA QUE LA SUCURSAL EXISTA Y ADEMAS OBTIENE EL IVA
                    SELECT iva
					  INTO dFactorIvaSucursal
					  FROM bdinteg:"informix".si_sucursales
					 WHERE sucursal = pSucursal;

                    IF cCodRet = '00000' AND NVL(dFactorIvaSucursal,0.0) = 0.0 THEN
                        LET cCodRet = '00444';
						LET cMensajeRet = 'SUCURSAL NO EXISTE O FALTA FACTOR DE IVA DE SUCURSAL';
					END IF;

					-- CALCULA LA TASA ANUAL CON IVA
                    LET dTasaAnualIva = (dTasaAnual/100) * (1 + dFactorIvaSucursal);
					-- VALIDA SI SE TRATA DE PROMOCION DE EFECTIVO
					IF cCodRet = '00000' THEN
                        --PROMOCION 1
                        IF pNumPromocion in (1, 4, 7) THEN  --FMV 5jun14: CampaÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ±as en Ventanilla Sucursal
                            -- OBTIENE EL CODIGO PARA LA COMISION DE LA DISPOSICION DE EFECTIVO
							SELECT TRIM(valor)::CHAR(4)
							  INTO cCodComDispEfectivo   --> FMV valor fijo variable: 6901
						 	  FROM "informix".sd_param
							 WHERE cod_param  = '334';
                            IF NVL(cCodComDispEfectivo,'') = '' THEN
                                LET cCodRet = '00445';
                                LET cMensajeRet = 'ERROR AL OBTENER EL PARAMETRO DEL CODIGO DE LA COMISION DE DISP. DE EFECTIVO';
							END IF;
							-- OBTIENE EL FACTOR PARA LA COMISION DE LA DISPOSICION DE EFECTIVO
                            SELECT apli_factor
							  INTO dFactorComDispEfect    --> FMV valor de la variable : 7
							  FROM "informix".sd_tpcomis
							 WHERE cod_comis = cCodComDispEfectivo;
                            IF NVL(dFactorComDispEfect,0.0) = 0.0 THEN
                                LET cCodRet = '00446';
								LET cMensajeRet = 'ERROR AL OBTENER EL PARAMETRO DEL FACTOR DE LA COMISION DE DISP. DE EFECTIVO';
							END IF;

                            --FMV 20-JUN14  TIENE SALDO A FAVOR Y LA CONTRATACION DE CREDISOLICIONES ES MENOR O IGUAL AL SALDO A FAVOR, NO CONTRATA
                            IF dCsg_cap_vig < 0 THEN   --  'OJO'
                                LET pMonto = pMonto + dCsg_cap_vig;  --FMV Se suma el monto negativo para descontar
                                --  MAHR Feb 2015 // Valida si el monto de la credisol (Retiro + Saldo Favor) es negativo (sigue estando Sdo Favor
                                --  (mayor el saldo a favor que el retiro, o el Sdo Favor = Monto del Retiro => no genere la credisolucion.
                                IF ( pMonto <= 0 ) THEN
                                    LET cCodRet = '02433';
                                    LET cMensajeRet = 'EL CLIENTE NO ES VIABLE PARA DIFERIR ';
                                END IF;
                            END IF;

                            -- CALCULA LA COMISION POR LA DISPOSICION
							LET dComisDisposicion = pMonto * (dFactorComDispEfect/100);
							-- CALCULA EL IVA DE LA COMISION
							LET dIvaComision = dComisDisposicion * dFactorIvaSucursal;
							-- CALCULA EL FACTOR INTERES IVA
                                --LET dFactorInteresIva = POW((1 + dTasaAnualIva/12), sNumPagos);
							-- CALCULA EL PAGO MENSUAL Y MONTO FINAL
                            --LET dPagoMensual = pMonto * (((dTasaAnualIva/12)*dFactorInteresIva) / (dFactorInteresIva - 1));
                            -- MAHR Se modifica el calculo del pago mensual por el llamado al sp: sp_proyecta_prest_credisol
                            --LET dPagoMensual = ROUND((pMonto *30.5* dTasaAnualIva/12)/ (30 * (1 - POW((1 + dTasaAnualIva/12),-sNumPagos))), 0);
                            LET i_Cont = 0;
                            LET dd_SaldoFinal_pp = 0;
                            LET pPlazo = pPlazo;
                            IF v_bandesp=1 THEN
                                LET v_NumCredito=pNumCredito;
                            END IF;
                            FOREACH                 
                                EXECUTE PROCEDURE bdicred:"informix".sp_proyecta_prest_credisol(pMonto,pPlazo::INTEGER,0,'6900',pSucursal,1,0,v_NumCredito,null,1,pNumPromocion::INTEGER, '1', pTasa) INTO
                                c_CodigoRet_pp, i_Periodo_pp, d_FechaCouta_pp, dd_SaldoInicial_pp, dd_Mensualidad_aux_pp, dd_Intereses_pp, dd_IvaInteres_pp, 
                                dd_Capital_pp, dd_SaldoFinal_aux_pp, s_DiasPeriodo_pp, d_FechaAper_pp, c_NumMesesPago_pp

                                IF c_CodigoRet_pp != '000000' THEN
                                    LET cMensajeRet = 'ERROR AL EJECUTAR sp_proyecta_prest_credisol';
                                    RETURN c_CodigoRet_pp, TRIM(cMensajeRet), NVL(dTotalPagar,0), NVL(pPlazo,0), NVL(dPagoMensual,0), NVL(dInterIvaPlazoMax,0), NVL(dSaldoTDC,0), TRIM(cFolioPromo), NVL(pNumPromocion,0);
                                END IF;

                                LET i_Cont = i_Cont + 1;
                                IF i_Cont = 1 THEN
                                    LET dd_Mensualidad_pp = dd_Mensualidad_aux_pp;
                                END IF;
                                LET dd_SaldoFinal_pp = dd_SaldoFinal_pp + dd_Mensualidad_aux_pp;
                            END FOREACH;

                            LET dPagoMensual = dd_Mensualidad_pp;
							-- CALCULA EL PAGO POR PLAZO
						       --LET dPagoPorPlazo = dPagoMensual * sNumPagos;
							-- CALCULA EL INTERES E IVA A PLAZO MAXIMO
                               --LET dInterIvaPlazoMax = dPagoPorPlazo - pMonto;
							LET dInterIvaPlazoMax = dd_SaldoFinal_pp - pMonto;
							--LET dTotalPagar = pMonto + dInterIvaPlazoMax;
                            LET dTotalPagar = dd_SaldoFinal_pp;
							-- VALIDA SI LA PROYECCION ES DE TIPO CONSULTA
							IF cCodRet = '00000' AND pTipo = 1 THEN
                                -- VALIDA SI EL CLIENTE ES VIABLE PARA DIFERIR EL MONTO DE EFECTIVO
                                IF (dCsg_linea_disp < (pMonto + dComisDisposicion + dIvaComision + dInterIvaPlazoMax)) THEN
									LET cCodRet = '02433';
									LET cMensajeRet = 'EL CLIENTE NO ES VIABLE PARA DIFERIR ';
								END IF;
								LET dTotalPagar = dTotalPagar;
								LET sNumPagos = sNumPagos;
								LET dPagoMensual = dPagoMensual;
								LET dInterIvaPlazoMax = dInterIvaPlazoMax;

                            -- VALIDA SI LA PROYECCION ES PARA RETORNAR EL DESGLOSE
                            ELIF cCodRet = '00000' AND pTipo = 2 THEN
								-- VALIDA QUE SI TRAE EL FOLIO DEL MOVIMIENTO QUE SE RECIBE CUANDO SE MANDA A LLAMAR EL PROCESO DESDE EL PROCESO NOCTURNO
                                IF NVL(pFolioMovto,"") <> "" THEN
                                    -- OBTIENE EL MONTO DE LOS INTERESES RETENIDOS DE LA PROMOCION POR MEDIO DEL FOLIO DEL MOVTO
                                    SELECT SUM(monto_actual + monto_int_iva)
									  INTO dMontoPromo
									  FROM "informix".sd_promocion_credito
									 WHERE status = 0
									   AND fecha = dtFechaHoy
                                       AND num_credito = pNumCredito
                                       AND num_promo = pNumPromocion
                                       AND folio_movto = pFolioMovto;

                                END IF;

                                -- IF (dCsg_linea_disp + dMontoPromo ) < (pMonto + dComisDisposicion + dIvaComision + dInterIvaPlazoMax) THEN
                                IF dCsg_linea_disp < 0 THEN
                                    LET cCodRet = '03433';
									LET cMensajeRet = 'EL CLIENTE NO ES VIABLE PARA DIFERIR ';
									--LET dTotalPagar = 0;
									--LET sNumPagos = 0;
									--LET dPagoMensual = 0;
									--LET dInterIvaPlazoMax = 0;
                                END IF;
                            -- VALIDA SI LA PROYECCION ES PARA GUARDAR EL DESGLOSE EN TABLA
							ELIF cCodRet = '00000' AND pTipo = 3 THEN
                                IF dCsg_linea_disp < (pMonto + dComisDisposicion + dIvaComision + dInterIvaPlazoMax) THEN
                                    LET cCodRet = '04433';
									LET cMensajeRet = 'EL CLIENTE NO ES VIABLE PARA DIFERIR ';
									-- LET dTotalPagar = 0;
									-- LET sNumPagos = 0;
									-- LET dPagoMensual = 0;
									-- LET dInterIvaPlazoMax = 0;
                                ELSE
                                    --- PROCESO GENERICO PARA GENERAR UN FOLIO PARA LA PROMOCION
                                    --EXECUTE PROCEDURE bdicheq:"informix".sp_generafolionomina(pEjecutivo)
									--INTO cCodRetGF,cFolioSucGF;
									LET cCodRetGF = '000000';
									SELECT --pEjecutivo 
										year(current) || lpad(month(current),2,0) || lpad(day(current),2,0)
										|| substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,1,2)
										||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,4,2)
										||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,7,2)
										||lpad(bdicheq:sp_random(),2,'0')
									INTO cFolioSucGF 
									FROM sysmaster:sysshmvals;
										-------
										-- Valida folio no exista y lo recalcula si existe
										LET sCountExists = 0;  
										SELECT COUNT(folio_suc) INTO sCountExists FROM bdicred:"informix".sd_promocion_credito 
										 WHERE empresa = '001' AND folio_suc = cFolioSucGF;
										IF sCountExists > 0 THEN
											SELECT --pEjecutivo 
												year(current) || lpad(month(current),2,0) || lpad(day(current),2,0)
												|| substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,1,2)
												||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,4,2)
												||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,7,2)
												||lpad(bdicheq:sp_random(),2,'0'), sysmaster:yieldn( 1 )
											  INTO cFolioSucGF, sYield FROM sysmaster:sysshmvals;
										END IF;
										-------									
									
                                    IF cCodRetGF::INTEGER <> 0 THEN
                                        LET cCodRet = '00447';
										LET cMensajeRet = 'OCURRIO UN ERROR EN EL PROCESO QUE GENERA EL FOLIO';
										LET dTotalPagar = 0;
										LET sNumPagos = 0;
										LET dPagoMensual = 0;
										LET dInterIvaPlazoMax = 0;
									ELSE
                                        LET cFolioPromo = cFolioSucGF;
										-- DA DE ALTA LA PROMOCION PARA EL CREDITO
										LET cBandera268 = '1';
										INSERT INTO "informix".sd_promocion_credito
										(empresa,sistema,num_promo,fecha,ejecutivo,num_cte,num_credito,num_tarjeta,plazo,folio_suc,monto_actual,monto_int_iva,mensualidad,status,nombre_promo,sucursal,num_sol_prestamo,num_pro_prestamo,folio_movto)
										VALUES ('001','06',pNumPromocion,dtFechaHoy,pEjecutivo,vcNumCte, pNumCredito,pNumTarjeta,pPlazo,cFolioSucGF,pMonto,dInterIvaPlazoMax,dPagoMensual,6,vcNomPromocion,pSucursal,'','6900',pFolioMovto);
										LET cBandera268 = '0';
                                    END IF;
                                END IF;
                            END IF;
                        -- VALIDA SI SE TRATA DE  PROMOCION DE COMPRAS
                        --PROMOCION 2
                        ELIF pNumPromocion in (2, 5, 8 )THEN
                            IF pTipo = 1 THEN
                                IF DAY(dtFechaHoy) > 20 THEN
                                    LET dtFechaCorte = MDY(MONTH(dtFechaHoy),20,YEAR(dtFechaHoy));
                                ELSE
                                    EXECUTE PROCEDURE bdicred:"informix".monthadd(dtFechaHoy, -1)
									INTO dtFechaCorte;
									LET dtFechaCorte = MDY(MONTH(dtFechaCorte),20,YEAR(dtFechaCorte));
                                END IF;
                                LET dtFechaCorte = dtFechaCorte + 1;


								IF NVL(dMontoDiferir,0) = 0 THEN
                                    -- OBTIENE EL MONTO MAXIMO DE LAS COMPRAS DEL CREDITO EN LOS MOVIMIENTOS HISTORICOS
									LET sCountExists = 0;  -- Valida si busca en movdia o en movhis. sCountExists = 1 ==> Existe en movdia 
                                    FOREACH
                                        SELECT nvl(monto,0) INTO dMontoDiferir_aux
                                          FROM "informix".sd_movdia a, bdinteg:"informix".si_transacc b
                                         WHERE a.empresa = b.empresa
                                           AND a.fecha_mov >= dtFechaCorte
                                           AND a.fecha_mov <= dtFechaHoy
                                           AND a.transacc_suc = b.numero
                                           AND a.num_credito = pNumCredito
										   AND folio_suc = pFolioMovto
                                           AND b.naturaleza = 'C'
										   AND b.sistema = '06'
                                           AND a.reversado = 'N'
                                           AND a.codigo_ref IN (31,51)
                                           AND a.monto >= dValorMinDiferir
										   
                                        IF dMontoDiferir_aux = 0 THEN
                                            LET dFactorInteresIva = 0;
                                            LET dPagoMensual = 0;
                                            LET dPagoPorPlazo = 0;
                                            LET dInterIvaPlazoMax = 0;
                                            LET dTotalPagar = 0;
                                            LET dMontoDiferir_aux = 0;
                                            CONTINUE FOREACH;
                                        ELIF dMontoDiferir_aux <> 0 AND dCsg_tot_liquidacion >= dMontoDiferir_aux THEN
                                            LET i_Cont = 0;
                                            LET dd_SaldoFinal_pp = 0;
                                            LET pPlazo = pPlazo;
                                            IF v_bandesp=1 THEN
                                                LET v_NumCredito=pNumCredito;
                                            END IF;
											LET sCountExists = 1;
                                            FOREACH
                                                EXECUTE PROCEDURE bdicred:"informix".sp_proyecta_prest_credisol(pMonto,pPlazo::INTEGER,0,'6900',pSucursal,1,0,v_NumCredito,null,1,pNumPromocion::INTEGER, '1', pTasa) INTO
                                                c_CodigoRet_pp, i_Periodo_pp, d_FechaCouta_pp, dd_SaldoInicial_pp, dd_Mensualidad_aux_pp, dd_Intereses_pp, dd_IvaInteres_pp, 
                                                dd_Capital_pp, dd_SaldoFinal_aux_pp, s_DiasPeriodo_pp, d_FechaAper_pp, c_NumMesesPago_pp

                                                IF c_CodigoRet_pp != '000000' THEN
                                                    LET cMensajeRet = 'ERROR AL EJECUTAR sp_proyecta_prest_credisol';
                                                    RETURN c_CodigoRet_pp, TRIM(cMensajeRet), NVL(dTotalPagar,0), NVL(pPlazo,0), NVL(dPagoMensual,0), NVL(dInterIvaPlazoMax,0), NVL(dSaldoTDC,0), TRIM(cFolioPromo), NVL(pNumPromocion,0);
                                                END IF;

                                                LET i_Cont = i_Cont + 1;
                                                IF i_Cont = 1 THEN
                                                    LET dd_Mensualidad_pp = dd_Mensualidad_aux_pp;
                                                END IF;
                                                LET dd_SaldoFinal_pp = dd_SaldoFinal_pp + dd_Mensualidad_aux_pp;
                                            END FOREACH;

                                            LET dPagoMensual = dd_Mensualidad_pp;
                                            LET dPagoPorPlazo = dd_SaldoFinal_pp;
                                            LET dInterIvaPlazoMax = dPagoPorPlazo - dMontoDiferir_aux;
                                            LET dTotalPagar = dd_SaldoFinal_pp;

                                            IF dCsg_linea_disp > (dInterIvaPlazoMax) THEN
                                                LET dFactorInteresIva = 0;
                                                LET dPagoMensual = 0;
                                                LET dPagoPorPlazo = 0;
                                                LET dInterIvaPlazoMax = 0;
                                                LET dTotalPagar = 0;
                                                LET vcompras = 1;
                                                LET dMontoDiferir = dMontoDiferir_aux;
                                            ELSE
                                                CONTINUE FOREACH;
                                            END IF;
                                        END IF;
                                    END FOREACH;
									IF sCountExists = 0 THEN -- Busca en movhis
										FOREACH
											SELECT nvl(monto,0) INTO dMontoDiferir_aux
											  FROM "informix".sd_movhis a, bdinteg:"informix".si_transacc b
											 WHERE a.empresa = b.empresa
											   AND a.fecha_mov >= dtFechaCorte
											   AND a.fecha_mov <= dtFechaHoy
											   AND a.transacc_suc = b.numero
											   AND a.num_credito = pNumCredito
											   AND folio_suc = pFolioMovto
											   AND b.naturaleza = 'C'
											   AND b.sistema = '06'
											   AND a.reversado = 'N'
											   AND a.codigo_ref IN (31,51)
											   AND a.monto >= dValorMinDiferir
											   
											IF dMontoDiferir_aux = 0 THEN
												LET dFactorInteresIva = 0;
												LET dPagoMensual = 0;
												LET dPagoPorPlazo = 0;
												LET dInterIvaPlazoMax = 0;
												LET dTotalPagar = 0;
												LET dMontoDiferir_aux = 0;
												CONTINUE FOREACH;
											ELIF dMontoDiferir_aux <> 0 AND dCsg_tot_liquidacion >= dMontoDiferir_aux THEN
												LET i_Cont = 0;
												LET dd_SaldoFinal_pp = 0;
												LET pPlazo = pPlazo;
												IF v_bandesp=1 THEN
													LET v_NumCredito=pNumCredito;
												END IF;

												FOREACH
													EXECUTE PROCEDURE bdicred:"informix".sp_proyecta_prest_credisol(pMonto,pPlazo::INTEGER,0,'6900',pSucursal,1,0,v_NumCredito,null,1,pNumPromocion::INTEGER, '1', pTasa) INTO
													c_CodigoRet_pp, i_Periodo_pp, d_FechaCouta_pp, dd_SaldoInicial_pp, dd_Mensualidad_aux_pp, dd_Intereses_pp, dd_IvaInteres_pp, 
													dd_Capital_pp, dd_SaldoFinal_aux_pp, s_DiasPeriodo_pp, d_FechaAper_pp, c_NumMesesPago_pp

													IF c_CodigoRet_pp != '000000' THEN
														LET cMensajeRet = 'ERROR AL EJECUTAR sp_proyecta_prest_credisol';
														RETURN c_CodigoRet_pp, TRIM(cMensajeRet), NVL(dTotalPagar,0), NVL(pPlazo,0), NVL(dPagoMensual,0), NVL(dInterIvaPlazoMax,0), NVL(dSaldoTDC,0), TRIM(cFolioPromo), NVL(pNumPromocion,0);
													END IF;

													LET i_Cont = i_Cont + 1;
													IF i_Cont = 1 THEN
														LET dd_Mensualidad_pp = dd_Mensualidad_aux_pp;
													END IF;
													LET dd_SaldoFinal_pp = dd_SaldoFinal_pp + dd_Mensualidad_aux_pp;
												END FOREACH;

												LET dPagoMensual = dd_Mensualidad_pp;
												LET dPagoPorPlazo = dd_SaldoFinal_pp;
												LET dInterIvaPlazoMax = dPagoPorPlazo - dMontoDiferir_aux;
												LET dTotalPagar = dd_SaldoFinal_pp;

												IF dCsg_linea_disp > (dInterIvaPlazoMax) THEN
													LET dFactorInteresIva = 0;
													LET dPagoMensual = 0;
													LET dPagoPorPlazo = 0;
													LET dInterIvaPlazoMax = 0;
													LET dTotalPagar = 0;
													LET vcompras = 1;
													LET dMontoDiferir = dMontoDiferir_aux;
												ELSE
													CONTINUE FOREACH;
												END IF;
											END IF;
										END FOREACH;
									END IF;
                                END IF;

                            ELIF pTipo IN (2,3) THEN
								LET dMontoDiferir = pMonto;
							END IF;

                            IF (vcompras = 0 AND NVL(dMontoDiferir,0) = 0) THEN
                                LET cCodRet = '05433';
								LET cMensajeRet = 'EL CLIENTE NO ES VIABLE PARA DIFERIR ';
								--LET dTotalPagar = 0;
								--LET sNumPagos = 0;
								--LET dPagoMensual = 0;
								--LET dInterIvaPlazoMax = 0;
							ELSE
                                -- CALCULA EL FACTOR INTERES IVA
								   --LET dFactorInteresIva = POW((1 + dTasaAnualIva/12), sNumPagos);
								-- CALCULA EL PAGO MENSUAL
                                LET i_Cont = 0;
                                LET dd_SaldoFinal_pp = 0;
                                LET pPlazo = pPlazo;
                                IF v_bandesp=1 THEN
                                    LET v_NumCredito=pNumCredito;
                                END IF;
                                FOREACH
                                    EXECUTE PROCEDURE bdicred:"informix".sp_proyecta_prest_credisol(pMonto,pPlazo::INTEGER,0,'6900',pSucursal,1,0,v_NumCredito,null,1,pNumPromocion::INTEGER, '1', pTasa) INTO
                                    c_CodigoRet_pp, i_Periodo_pp, d_FechaCouta_pp, dd_SaldoInicial_pp, dd_Mensualidad_aux_pp, dd_Intereses_pp, dd_IvaInteres_pp, 
                                    dd_Capital_pp, dd_SaldoFinal_aux_pp, s_DiasPeriodo_pp, d_FechaAper_pp, c_NumMesesPago_pp

                                    IF c_CodigoRet_pp != '000000' THEN
                                        LET cMensajeRet = 'ERROR AL EJECUTAR sp_proyecta_prest_credisol';
                                        RETURN c_CodigoRet_pp, TRIM(cMensajeRet), NVL(dTotalPagar,0), NVL(pPlazo,0), NVL(dPagoMensual,0), NVL(dInterIvaPlazoMax,0), NVL(dSaldoTDC,0), TRIM(cFolioPromo), NVL(pNumPromocion,0);
                                    END IF;

                                    LET i_Cont = i_Cont + 1;
                                    IF i_Cont = 1 THEN
                                        LET dd_Mensualidad_pp = dd_Mensualidad_aux_pp;
                                    END IF;
                                    LET dd_SaldoFinal_pp = dd_SaldoFinal_pp + dd_Mensualidad_aux_pp;
                                END FOREACH;
                                LET dPagoMensual = dd_Mensualidad_pp;
								-- CALCULA EL PAGO POR PLAZO
                                LET dPagoPorPlazo = dd_SaldoFinal_pp;
								-- CALCULA EL INTERES E IVA A PLAZO MAXIMO
								LET dInterIvaPlazoMax = dPagoPorPlazo - dMontoDiferir;
    							--LET dTotalPagar = pMonto + dInterIvaPlazoMax;
                                LET dTotalPagar = dd_SaldoFinal_pp;
								-- VALIDA SI LA PROYECCION ES DE TIPO CONSULTA

								IF cCodRet = '00000' AND pTipo = 1 THEN
                                    --	IF dCsg_linea_disp < (dMontoDiferir + dInterIvaPlazoMax) THEN
                                    IF dCsg_linea_disp < (dInterIvaPlazoMax) THEN
                                        LET cCodRet = '06433';
										LET cMensajeRet = 'EL CLIENTE NO ES VIABLE PARA DIFERIR ';
									END IF
									LET dTotalPagar = dTotalPagar;
									LET sNumPagos = sNumPagos;
									LET dPagoMensual = dPagoMensual;
									LET dInterIvaPlazoMax = dInterIvaPlazoMax;
								-- VALIDA SI LA PROYECCION ES PARA RETORNAR EL DESGLOSE
                                ELIF cCodRet = '00000' AND pTipo = 2 THEN
                                    -- VALIDA QUE SI TRAE EL FOLIO DEL MOVIMIENTO QUE SE RECIBE CUANDO SE MANDA A LLAMAR EL PROCESO DESDE EL PROCESO NOCTURNO
									IF NVL(pFolioMovto,"") <> "" THEN
                                        -- OBTIENE EL MONTO DE LOS INTERESES RETENIDOS DE LA PROMOCION POR MEDIO DEL FOLIO DEL MOVTO
                                        SELECT SUM(monto_actual + monto_int_iva)
										  INTO dMontoPromo
										  FROM  "informix".sd_promocion_credito  
										  WHERE status = 0 AND fecha = dtFechaHoy AND num_credito = pNumCredito AND num_promo = pNumPromocion AND folio_movto = pFolioMovto;
                                        LET dMontoPromo = NVL(dMontoPromo,0.0);
                                    END IF;
								    -- IF (dCsg_linea_disp + dMontoPromo) < (dMontoDiferir + dInterIvaPlazoMax) THEN
                                    IF  dCsg_linea_disp < 0 THEN
										LET cCodRet = '07433';
										LET cMensajeRet = 'EL CLIENTE NO ES VIABLE PARA DIFERIR ';
										--LET dTotalPagar = 0;
										--LET sNumPagos = 0;
										--LET dPagoMensual = 0;
										--LET dInterIvaPlazoMax = 0;
									END IF;
                                -- VALIDA SI LA PROYECCION ES PARA GUARDAR EL DESGLOSE EN TABLA
								ELIF cCodRet = '00000' AND pTipo = 3 THEN
                                    --IF dCsg_linea_disp < (dMontoDiferir + dInterIvaPlazoMax) THEN
                                    IF dCsg_linea_disp < dInterIvaPlazoMax THEN
										LET cCodRet = '08433';
										LET cMensajeRet = 'EL CLIENTE NO ES VIABLE PARA DIFERIR ';
										--LET dTotalPagar = 0;
										--LET sNumPagos = 0;
										--LET dPagoMensual = 0;
										--LET dInterIvaPlazoMax = 0;
									ELSE
                                        --- PROCESO GENERICO PARA GENERAR UN FOLIO
										--EXECUTE PROCEDURE bdicheq:"informix".sp_generafolionomina(pEjecutivo)
										--INTO cCodRetGF,cFolioSucGF;
										LET cCodRetGF = '000000';
										SELECT --pEjecutivo 
											year(current) || lpad(month(current),2,0) || lpad(day(current),2,0)
											|| substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,1,2)
											||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,4,2)
											||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,7,2)
											||lpad(bdicheq:sp_random(),2,'0')
										INTO cFolioSucGF 
										FROM sysmaster:sysshmvals;
											-------
											-- Valida folio no exista y lo recalcula si existe
											LET sCountExists = 0;  
											SELECT COUNT(folio_suc) INTO sCountExists FROM bdicred:"informix".sd_promocion_credito 
											 WHERE empresa = '001' AND folio_suc = cFolioSucGF;
											IF sCountExists > 0 THEN
												SELECT --pEjecutivo 
													year(current) || lpad(month(current),2,0) || lpad(day(current),2,0)
													|| substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,1,2)
													||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,4,2)
													||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,7,2)
													||lpad(bdicheq:sp_random(),2,'0'), sysmaster:yieldn( 1 )
												  INTO cFolioSucGF, sYield FROM sysmaster:sysshmvals;
											END IF;
											-------											
									
										IF cCodRetGF::INTEGER <> 0 THEN
                                            LET cCodRet = '00447';
											LET cMensajeRet = 'OCURRIO UN ERROR EN EL PROCESO QUE GENERA EL FOLIO';
											LET dTotalPagar = 0;
											LET sNumPagos = 0;
											LET dPagoMensual = 0;
											LET dInterIvaPlazoMax = 0;
										ELSE
                                            LET cFolioPromo = cFolioSucGF;
											-- GUARDA LOS DATOS DE LA PROMOCION
											LET cBandera268 = '1';
											INSERT INTO "informix".sd_promocion_credito
											   (empresa,sistema,num_promo,fecha,ejecutivo,num_cte,num_credito,num_tarjeta,plazo,folio_suc,monto_actual,monto_int_iva,mensualidad,status,nombre_promo,sucursal,num_sol_prestamo,num_pro_prestamo,folio_movto)
											    VALUES ('001','06',pNumPromocion,dtFechaHoy,pEjecutivo,vcNumCte, pNumCredito,pNumTarjeta,pPlazo,cFolioSucGF,pMonto,dInterIvaPlazoMax,dPagoMensual,0,vcNomPromocion,pSucursal,'','6900',pFolioMovto);
											LET cBandera268 = '0';
											-- REALIZA EL RETENIDO POR EL MONTO DE LOS INTERESES E IVA PARA EVITAR EL SOBREGIRO
											INSERT INTO "informix".sd_maeretenido
											   (empresa,num_credito,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,estatus,referencia,sucursal,dias_ori)
											   VALUES('001',pNumCredito,cFolioSucGF,dtFechaHoy,CURRENT HOUR TO FRACTION(3),'6837',0,dInterIvaPlazoMax,pEjecutivo,'R',cFolioSucGF||' RET. CREDISOLUCIONES',pSucursal,0);
											-- ACTUALIZA EL SALDO RETENIDO EN EL MAESTRO DE SALDOS
											UPDATE "informix".sd_maesdos
											   SET sdo_retenido = sdo_retenido + dInterIvaPlazoMax
											 WHERE num_credito = pNumCredito
											   AND empresa = '001';
											-- GENERAMOS EL MOVIMIENTO DEL RETENIDO DE LOS INTERESES
											EXECUTE PROCEDURE "informix".genmov_tc('001',pNumCredito,'6001',dtFechaHoy,dInterIvaPlazoMax,cFolioSucGF,pSucursal,vdivisa,'6837','','RET. de INT. e Iva CS',v_tipocambio,0,pEjecutivo,vsucorig,'','')
											INTO cCodRetGenMov, cMsjeGenMov;
                                        END IF;
									END IF;
								END IF;
							END IF;
                        ----PROMOCION 3
						-- VALIDA SI SE TRATA DE  PROMOCION DE SALDO TDC
                        ELIF pNumPromocion in (3, 6 ,9) THEN
                            -- OBTIENE EL MONTO DE LO QUE DEBE EL CLIENTE SIN EL SALDO RETENIDO
                            SELECT NVL(monto_int_iva,0)
                              INTO vPromoRetSdo2
                              FROM "informix".sd_promocion_credito
                             WHERE empresa = '001'
                               AND num_credito = pNumCredito
                               AND num_promo in (3, 6, 9)
                               AND status = 0;

							-- Obtiene monto de saldo retenido apoyo, si no tiene no afecta el monto
							SELECT sum(monto) INTO dSdoRetenidoApoyo					
							  FROM bdicred:sd_maeretenido WHERE num_credito = pNumCredito
							   AND transacc in ('8369', '8370') AND estatus = "R";
							IF dSdoRetenidoApoyo IS NULL THEN LET dSdoRetenidoApoyo = 0; END IF; 							

							LET dSaldoTDC = dCsg_cap_vig + dSdoRetenidoApoyo; -- Actualiza dato de retorno
							   
                            -- LET dMontoDiferir = dCsg_tot_liquidacion - dCsg_sdo_retenido;
							-- LET dMontoDiferir = dCsg_tot_liquidacion;
                            -- LET dMontoDiferir = dCsg_cap_vig;
							LET dMontoDiferir = dCsg_cap_vig + dSdoRetenidoApoyo;
							--> VALIDA QUE SALDOS CUENTE CON SALDO MAYOR O IGUAL AL  MINÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂMO PERMITIDO
							IF dMontoDiferir < dValorMinDiferir THEN
                                LET cCodRet = '09433';
								LET cMensajeRet = 'EL CLIENTE NO ES VIABLE PARA DIFERIR ';
                            ELSE
                                -- CALCULA EL FACTOR INTERES IVA
								  --LET dFactorInteresIva = POW((1 + dTasaAnualIva/12), sNumPagos);
								  -- CALCULA EL PAGO MENSUAL
								  --LET dPagoMensual = dMontoDiferir * (((dTasaAnualIva/12)*dFactorInteresIva) / (dFactorInteresIva - 1));

                                -- MAHR Se modifica el calculo del pago mensual por el llamado al sp: sp_proyecta_prest_credisol
                                LET i_Cont = 0;
                                LET dd_SaldoFinal_pp = 0;
                                LET pPlazo = pPlazo;
                                IF v_bandesp=1 THEN
                                    LET v_NumCredito=pNumCredito;
                                END IF;
                                FOREACH
                                    EXECUTE PROCEDURE bdicred:"informix".sp_proyecta_prest_credisol(pMonto,pPlazo::INTEGER,0,'6900',pSucursal,1,0,v_NumCredito,null,1,pNumPromocion::INTEGER, '1', pTasa) INTO
                                    c_CodigoRet_pp, i_Periodo_pp, d_FechaCouta_pp, dd_SaldoInicial_pp, dd_Mensualidad_aux_pp, dd_Intereses_pp, dd_IvaInteres_pp, 
                                    dd_Capital_pp, dd_SaldoFinal_aux_pp, s_DiasPeriodo_pp, d_FechaAper_pp, c_NumMesesPago_pp

                                    IF c_CodigoRet_pp != '000000' THEN
                                        LET cMensajeRet = 'ERROR AL EJECUTAR sp_proyecta_prest_credisol';
                                        RETURN c_CodigoRet_pp, TRIM(cMensajeRet), NVL(dTotalPagar,0), NVL(pPlazo,0), NVL(dPagoMensual,0), NVL(dInterIvaPlazoMax,0), NVL(dSaldoTDC,0), TRIM(cFolioPromo), NVL(pNumPromocion,0);
                                    END IF;

                                    LET i_Cont = i_Cont + 1;
                                    IF i_Cont = 1 THEN
                                        LET dd_Mensualidad_pp = dd_Mensualidad_aux_pp;
                                    END IF;
                                    LET dd_SaldoFinal_pp = dd_SaldoFinal_pp + dd_Mensualidad_aux_pp;
                                END FOREACH;
                                ---LET dPagoMensual = ROUND((dMontoDiferir *30.5* dTasaAnualIva/12)/ (30 * (1 - POW((1 + dTasaAnualIva/12),-sNumPagos))), 0);
                                LET dPagoMensual = dd_Mensualidad_pp;
								-- CALCULA EL PAGO POR PLAZO
                                   --LET dPagoPorPlazo = dPagoMensual * sNumPagos;
                                LET dPagoPorPlazo = dd_SaldoFinal_pp;
								-- CALCULA EL INTERES E IVA A PLAZO MAXIMO
								LET dInterIvaPlazoMax = dPagoPorPlazo - dMontoDiferir;
								--LET dTotalPagar = dMontoDiferir + dInterIvaPlazoMax;
                                LET dTotalPagar = dd_SaldoFinal_pp;

								-- VALIDA SI LA PROYECCION ES DE TIPO CONSULTA
								IF cCodRet = '00000' AND pTipo = 1 THEN

								--	IF (dMontoDiferir = 0) OR (dCsg_linea_disp < (dMontoDiferir + dInterIvaPlazoMax)) THEN
                                    IF ((dMontoDiferir = 0) OR (dCsg_linea_disp < (dInterIvaPlazoMax))) THEN
										LET cCodRet = '10433';
										LET cMensajeRet = 'EL CLIENTE NO ES VIABLE PARA DIFERIR ';
									END IF;
									LET dTotalPagar = dTotalPagar;
									LET sNumPagos = sNumPagos;
									LET dPagoMensual = dPagoMensual;
									LET dInterIvaPlazoMax = dInterIvaPlazoMax;
								-- VALIDA SI LA PROYECCION ES PARA RETORNAR EL DESGLOSE
                                ELIF cCodRet = '00000' AND pTipo = 2 THEN
                                    -- VALIDA QUE SI TRAE EL FOLIO DEL MOVIMIENTO QUE SE RECIBE CUANDO SE MANDA A LLAMAR EL PROCESO DESDE EL PROCESO NOCTURNO
									IF NVL(pFolioMovto,"") <> "" THEN
                                        -- OBTIENE EL MONTO DE LOS INTERESES RETENIDOS DE LA PROMOCION POR MEDIO DEL FOLIO DEL MOVTO
										SELECT SUM(monto_actual + monto_int_iva)
										INTO dMontoPromo
										FROM  "informix".sd_promocion_credito
										WHERE status = 0 AND fecha = dtFechaHoy AND num_credito = pNumCredito AND num_promo = pNumPromocion AND folio_movto = pFolioMovto;
										LET dMontoPromo = NVL(dMontoPromo,0.0);
                                    END IF;
                                    IF ((dMontoDiferir = 0) OR ((dCsg_linea_disp + vPromoRetSdo2) < (dInterIvaPlazoMax))) THEN
									-- IF (dMontoDiferir = 0) OR ((dCsg_linea_disp + dMontoPromo) < (dMontoDiferir + dInterIvaPlazoMax)) THEN
                                        LET cCodRet = '11433';
										LET cMensajeRet = 'EL CLIENTE NO ES VIABLE PARA DIFERIR ';
										--LET dTotalPagar = 0;
										--LET sNumPagos = 0;
										--LET dPagoMensual = 0;
										--LET dInterIvaPlazoMax = 0;
									END IF;
                                    IF pNumPromocion=9 AND pFolioMovto<>"" THEN
                                        --IF pMonto < dCsg_cap_vig THEN
										IF pMonto > (dCsg_cap_vig + dSdoRetenidoApoyo) THEN -- Ya realizo un pago el saldo de invitacion es menor al actual										
                                            LET cCodRet = '13433';
                                            LET cMensajeRet = 'EL MONTO DE LA CREDISOLUCION ES DIFERENTE AL SALDO INSOLUTO';
                                            LET dTotalPagar = 0;
                                            LET sNumPagos = 0;
                                            LET dPagoMensual = 0;
                                            LET dInterIvaPlazoMax = 0;
                                        END IF  
                                    END IF; 
								-- VALIDA SI LA PROYECCION ES PARA GUARDAR EL DESGLOSE EN TABLA
								ELIF cCodRet = '00000' AND pTipo = 3 THEN
                                    --	IF (dMontoDiferir = 0) OR (dCsg_linea_disp < (dMontoDiferir + dInterIvaPlazoMax)) THEN
                                    IF ((dMontoDiferir = 0) OR (dCsg_linea_disp < (dInterIvaPlazoMax))) THEN
										LET cCodRet = '12433';
										LET cMensajeRet = 'EL CLIENTE NO ES VIABLE PARA DIFERIR ';
										--LET dTotalPagar = 0;
										--LET sNumPagos = 0;
										--LET dPagoMensual = 0;
										--LET dInterIvaPlazoMax = 0;
                                    ELSE
                                        --- PROCESO GENERICO PARA GENERAR UN FOLIO
										--EXECUTE PROCEDURE bdicheq:"informix".sp_generafolionomina(pEjecutivo)
										--INTO cCodRetGF,cFolioSucGF;
										LET cCodRetGF = '000000';
										SELECT --pEjecutivo 
											year(current) || lpad(month(current),2,0) || lpad(day(current),2,0)
											|| substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,1,2)
											||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,4,2)
											||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,7,2)
											||lpad(bdicheq:sp_random(),2,'0')
										INTO cFolioSucGF 
										FROM sysmaster:sysshmvals;
											-------
											-- Valida folio no exista y lo recalcula si existe
											LET sCountExists = 0;  
											SELECT COUNT(folio_suc) INTO sCountExists FROM bdicred:"informix".sd_promocion_credito 
											 WHERE empresa = '001' AND folio_suc = cFolioSucGF;
											IF sCountExists > 0 THEN
												SELECT --pEjecutivo 
													year(current) || lpad(month(current),2,0) || lpad(day(current),2,0)
													|| substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,1,2)
													||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,4,2)
													||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,7,2)
													||lpad(bdicheq:sp_random(),2,'0'), sysmaster:yieldn( 1 )
												  INTO cFolioSucGF, sYield FROM sysmaster:sysshmvals;
											END IF;
											-------											
										
										IF cCodRetGF::INTEGER <> 0 THEN
											LET cCodRet = '00447';
											LET cMensajeRet = 'OCURRIO UN ERROR EN EL PROCESO QUE GENERA EL FOLIO';
											LET dTotalPagar = 0;
											LET sNumPagos = 0;
											LET dPagoMensual = 0;
											LET dInterIvaPlazoMax = 0;
											ELSE
											LET cFolioPromo = cFolioSucGF;
											-- GUARDA LOS DATOS DE LA PROMOCION
											LET cBandera268 = '1';
											INSERT INTO "informix".sd_promocion_credito
											   (empresa,sistema,num_promo,fecha,ejecutivo,num_cte,num_credito,num_tarjeta,plazo,folio_suc,monto_actual,monto_int_iva,mensualidad,status,nombre_promo,sucursal,num_sol_prestamo,num_pro_prestamo,folio_movto)
											   VALUES ('001','06',pNumPromocion,dtFechaHoy,pEjecutivo,vcNumCte, pNumCredito,pNumTarjeta,pPlazo,cFolioSucGF,pMonto,dInterIvaPlazoMax,dPagoMensual,0,vcNomPromocion,pSucursal,'','6900',cFolioSucGF);
											LET cBandera268 = '0';
											   -- REALIZA EL RETENIDO POR EL MONTO DE LOS INTERESES E IVA PARA EVITAR EL SOBREGIRO
											INSERT INTO "informix".sd_maeretenido
											   (empresa,num_credito,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,estatus,referencia,sucursal,dias_ori)
											   VALUES('001',pNumCredito,cFolioSucGF,dtFechaHoy,CURRENT HOUR TO FRACTION(3),'6837',0,dInterIvaPlazoMax,pEjecutivo,'R',cFolioSucGF || ' RET. CREDISOLUCIONES',pSucursal,0);
											-- ACTUALIZA EL SALDO RETENIDO EN EL MAESTRO DE SALDOS
											UPDATE "informix".sd_maesdos
											   SET sdo_retenido = sdo_retenido + dInterIvaPlazoMax
											 WHERE num_credito = pNumCredito
											   AND empresa = '001';
											-- GENERAMOS EL MOVIMIENTO DEL RETENIDO DE LOS INTERESES
											EXECUTE PROCEDURE "informix".genmov_tc('001',pNumCredito,'6001',dtFechaHoy,dInterIvaPlazoMax,cFolioSucGF,pSucursal,vdivisa,'6837','','RET. de INT. e Iva CS',v_tipocambio,0,pEjecutivo,vsucorig,'','')
											   INTO cCodRetGenMov, cMsjeGenMov;
                                        END IF;	-- Termina --> PROCESO GENERICO PARA GENERAR UN FOLIO
									END IF; -- Termina --> VALIDA SI LA PROYECCION ES PARA GUARDAR EL DESGLOSE EN TABLA
								END IF;  -- Termina --> VALIDA SI LA PROYECCION ES DE TIPO CONSULTA
							END IF; -- Termina --> VALIDA QUE SALDOS CUENTE CON SALDO MAYOR O IGUAL AL MINÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂMO PERMITIDO
						END IF; -- Termina --> VALIDA SI SE TRATA DE PROMOCION DE EFECTIVO
					END IF;
				END IF;
			END IF;
		END IF;
	END IF;

    IF cCodRet <> '00000' THEN
        INSERT INTO "informix".sd_bitacora_promocion VALUES('001',pNumCredito,'sp_proyecta_pfsms',dtFechaHoy,CURRENT,pTipo,pNumPromocion,cCodRet);
    END IF;

	RETURN cCodRet, TRIM(cMensajeRet), NVL(dTotalPagar,0), NVL(pPlazo,0), NVL(dPagoMensual,0), NVL(dInterIvaPlazoMax,0), NVL(dSaldoTDC,0), TRIM(cFolioPromo), NVL(pNumPromocion,0);

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para obtener el desglose de informacion de saldos del credito y validar si es viable el cliente para Pagos Fijos SMS',
'MODIFICO: Mario Gamaliel Olivo Urias',
'VERSION: 20141021.0930',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_proyecta_promo
(
pTipo 			SMALLINT, -- 1- consulta proyeccion, 2-regresa el desglose, 3-guarda proyeccion
pSucursal 		CHAR(4),
pEjecutivo		CHAR(8),
pNumPromocion 	SMALLINT, -- 1-Perma.Efec, 2-Perma.Comps, 3-Perma.Saldos, 4-Temp.Efec, 5-Temp.Comps, 6-Temp.Saldo 7-Esp.Efec, 8-Esp.Comps, 9-Esp.Saldo
pNumCredito 	CHAR(20),
pNumTarjeta		CHAR(20),
pMonto 			DECIMAL(18,2),
pPlazo 			SMALLINT,
pFolioMovto		CHAR(16)
)

RETURNING
	CHAR(5) 		AS cod_ret,
	CHAR(80)		AS descripcion,
	DECIMAL(18,2)	AS total_pagar,
	SMALLINT		AS num_plazo,
	DECIMAL(18,2)	AS pago_mensual,
	DECIMAL(18,2)	AS interes_iva,
	DECIMAL(18,2)	AS saldo_tdc,
	CHAR(16)		AS folio_promo;
	---DECLARACIONES
    DEFINE iSqlErr				INTEGER;
    DEFINE iIsamErr				INTEGER;
    DEFINE cErrorInfo			CHAR(80);
    DEFINE cCodRet				CHAR(5);
    DEFINE cMensajeRet			CHAR(80);
	DEFINE sNumPagos			SMALLINT;
	DEFINE dTasaAnual			DECIMAL(18,6);
	DEFINE dTasaAnualIva		DECIMAL(18,6);
	DEFINE dFactorIvaSucursal	DECIMAL(5,3);
	DEFINE dPagoMensual			DECIMAL(18,6);
	DEFINE dPagoPorPlazo		DECIMAL(18,6);
	DEFINE dInterIvaPlazoMax	DECIMAL(18,6);
	DEFINE dFactorInteresIva	DECIMAL(18,6);
	DEFINE dComisDisposicion	DECIMAL(18,6);
	DEFINE dIvaComision			DECIMAL(18,6);
	DEFINE dFactorComDispEfect	DECIMAL(18,6);
	DEFINE cCodComDispEfectivo	CHAR(4);
	DEFINE dValorMinDiferir		DECIMAL(18,6);
	DEFINE dMontoDiferir		DECIMAL(18,6);
	DEFINE dTotalPagar			DECIMAL(18,6);
	DEFINE vcNumCte				VARCHAR(20);
	DEFINE cCodRetGF			CHAR(6);
	DEFINE cFolioSucGF			CHAR(16);
	DEFINE vcNomEjecutivo		VARCHAR(45);
	DEFINE vcNomPromocion		VARCHAR(50);
	DEFINE dSaldoTDC			DECIMAL(18,2);
	DEFINE cFolioPromo			CHAR(16);
	DEFINE dtFechaHoy			DATE;
	DEFINE dtFechaCorte			DATE;
	DEFINE dMontoPromo			DECIMAL(18,2);
	DEFINE cCodRetGenMov	  CHAR(10);
	DEFINE cMsjeGenMov		  CHAR(80);
    DEFINE vsucorig           CHAR(4);
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general
	DEFINE cCsg_codigo_ret			CHAR(6);
	DEFINE cCsg_mensaje_ret			CHAR(80);
	DEFINE cCsg_num_credito			CHAR(20);
	DEFINE cCsg_cod_tipcred			CHAR(2);
	DEFINE dtCsg_fec_origen			DATE;
	DEFINE dtCsg_fec_prox_pago		DATE;
	DEFINE dCsg_pago_min			DECIMAL(18,2);
	DEFINE dtCsg_fec_ult_pago		DATE;
	DEFINE iCsg_plazo				INTEGER;
	DEFINE iCsg_pagos_realizados	INTEGER;
	DEFINE dCsg_linea_otorgada		DECIMAL(18,2);
	DEFINE dCsg_tasa_interes		DECIMAL(9,6);
	DEFINE dCsg_tasa_moratorios		DECIMAL(9,6);
	DEFINE dCsg_monto_sbc			DECIMAL(14,2);
	DEFINE dCsg_cap_vig				DECIMAL(18,2);
	DEFINE dCsg_cap_trans			DECIMAL(18,2);
	DEFINE dCsg_cap_vdo_exig		DECIMAL(18,2);
	DEFINE dCsg_cap_vdo_no_exig		DECIMAL(18,2);
	DEFINE dCsg_sdo_act_total_cap	DECIMAL(18,2);
	DEFINE dCsg_int_vig				DECIMAL(18,2);
	DEFINE dCsg_int_vdo				DECIMAL(18,2);
	DEFINE dCsg_int_moratorios		DECIMAL(18,2);
	DEFINE dCsg_int_mes				DECIMAL(18,2);
	DEFINE dCsg_sdo_act_total_int	DECIMAL(18,2);
	DEFINE dCsg_iva_int_vig			DECIMAL(18,2);
	DEFINE dCsg_iva_int_vdo			DECIMAL(18,2);
	DEFINE dCsg_iva_int_moratorios	DECIMAL(18,2);
	DEFINE dCsg_iva_int_mes			DECIMAL(18,2);
	DEFINE dCsg_sdo_act_total_iva	DECIMAL(18,2);
	DEFINE dCsg_com_pend			DECIMAL(18,2);
	DEFINE dCsg_iva_com				DECIMAL(18,2);
	DEFINE dCsg_sdo_retenido		DECIMAL(18,2);
	DEFINE dCsg_tot_liquidacion		DECIMAL(18,2);
	DEFINE dCsg_int_devengado		DECIMAL(18,2);
	DEFINE dCsg_iva_int_devengado	DECIMAL(18,2);
	DEFINE dCsg_linea_disp			DECIMAL(18,2);
	DEFINE dCsg_pagos_vdos			DECIMAL(18,2);
	DEFINE cCsg_desc_status_cred	CHAR(60);
	DEFINE iCsg_id_bloqueo_cred		INTEGER;
	DEFINE cCsg_bloqueo_cta			CHAR(60);
	DEFINE cCsg_id_causa_bloq_cred	CHAR(3);
	DEFINE cCsg_causa_bloqueo_cta	CHAR(50);
	DEFINE cCsg_id_sit_esp_cte		CHAR(1);
	DEFINE iCsg_id_causa_esp_cte	INTEGER;
	DEFINE cCsg_sit_esp_cte			CHAR(75);
	DEFINE cCsg_id_sit_esp_cred		CHAR(1);
	DEFINE iCsg_id_causa_esp_cred	INTEGER;
	DEFINE cCsg_sit_esp_cred		CHAR(75);
    DEFINE vvalor1                  DECIMAL(18,6);
    DEFINE vvalor2                  DECIMAL(18,6);
    DEFINE vcompras                 SMALLINT;
	DEFINE dMontoDiferir_aux	    DECIMAL(18,6);
    DEFINE vdivisa                  CHAR(2);
    DEFINE v_dv                     CHAR(2);
    DEFINE v_tipocambio             DECIMAL(14,6);
    DEFINE vPromoRetSdo             DECIMAL(18,6);
    DEFINE vPromoRetSdo2            DECIMAL(18,6);
    DEFINE vs_precal_num_promo      SMALLINT;  --FMV 19-NOV-13
    DEFINE vs_secuencia             INTEGER;
    -- VARIABLES PARA OBTENER RESPUESTA DEL SP: sp_proyecta_prest_credisol
    DEFINE c_CodigoRet_pp           CHAR(6);
    DEFINE i_Periodo_pp             INTEGER;
    DEFINE d_FechaCouta_pp          DATE;
    DEFINE dd_SaldoInicial_pp       DECIMAL(18,2);
    DEFINE dd_Mensualidad_pp        DECIMAL(18,2);
    DEFINE dd_Mensualidad_aux_pp    DECIMAL(18,2);
    DEFINE dd_Intereses_pp          DECIMAL(18,2);
    DEFINE dd_IvaInteres_pp         DECIMAL(18,2);
    DEFINE dd_Capital_pp            DECIMAL(18,2);
    DEFINE dd_SaldoFinal_pp         DECIMAL(18,2);
    DEFINE dd_SaldoFinal_aux_pp     DECIMAL(18,2);
    DEFINE s_DiasPeriodo_pp         SMALLINT;
    DEFINE d_FechaAper_pp           DATE;
    DEFINE c_NumMesesPago_pp        CHAR(3);
    DEFINE i_Cont                   SMALLINT;
    DEFINE v_bandesp                SMALLINT;
    DEFINE v_NumCredito             CHAR(20);
	DEFINE sCountExists				INTEGER;
	DEFINE sYield					INTEGER;
    DEFINE vProducto			    CHAR(4);
	---INICIALIZACIONES
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	LET cErrorInfo			= '';
	LET cCodRet				= '00000';
	LET cMensajeRet			= 'PROCESO EXITOSO';
	LET sNumPagos			= 0;
	LET dTasaAnual			= 0.0;
	LET dTasaAnualIva		= 0.0;
	LET dFactorIvaSucursal	= 0.0;
	LET dPagoMensual		= 0.0;
	LET dPagoPorPlazo		= 0.0;
	LET dInterIvaPlazoMax	= 0.0;
	LET dFactorInteresIva	= 0.0;
	LET dComisDisposicion	= 0.0;
	LET dIvaComision		= 0.0;
	LET dFactorComDispEfect	= 0.0;
	LET cCodComDispEfectivo	= '';
	LET dValorMinDiferir	= 0.0;
	LET dMontoDiferir		= 0.0;
	LET dTotalPagar			= 0.0;
	LET vcNumCte			= '';
	LET cCodRetGF			= '000000';
	LET cFolioSucGF			= '';
	LET vcNomEjecutivo		= '';
	LET vcNomPromocion		= '';
	LET dSaldoTDC			= 0.0;
	LET cFolioPromo			= '';
	LET dtFechaHoy			= DATE(1);
	LET dtFechaCorte		= DATE(1);
	LET dMontoPromo		= 0.0;
	LET cCodRetGenMov		= "";
	LET cMsjeGenMov		    = "";
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general
	LET cCsg_codigo_ret				= "000000";
	LET cCsg_mensaje_ret			= "";
	LET cCsg_num_credito			= "";
	LET cCsg_cod_tipcred			= "";
	LET dtCsg_fec_origen			= MDY(1,1,1900);
	LET dtCsg_fec_prox_pago			= MDY(1,1,1900);
	LET dCsg_pago_min				= 0.0;
	LET dtCsg_fec_ult_pago			= MDY(1,1,1900);
	LET iCsg_plazo					= 0;
	LET iCsg_pagos_realizados		= 0;
	LET dCsg_linea_otorgada			= 0.0;
	LET dCsg_tasa_interes			= 0.0;
	LET dCsg_tasa_moratorios		= 0.0;
	LET dCsg_monto_sbc				= 0.0;
	LET dCsg_cap_vig				= 0.0;
	LET dCsg_cap_trans				= 0.0;
	LET dCsg_cap_vdo_exig			= 0.0;
	LET dCsg_cap_vdo_no_exig		= 0.0;
	LET dCsg_sdo_act_total_cap		= 0.0;
	LET dCsg_int_vig				= 0.0;
	LET dCsg_int_vdo				= 0.0;
	LET dCsg_int_moratorios			= 0.0;
	LET dCsg_int_mes				= 0.0;
	LET dCsg_sdo_act_total_int		= 0.0;
	LET dCsg_iva_int_vig			= 0.0;
	LET dCsg_iva_int_vdo			= 0.0;
	LET dCsg_iva_int_moratorios		= 0.0;
	LET dCsg_iva_int_mes			= 0.0;
	LET dCsg_sdo_act_total_iva		= 0.0;
	LET dCsg_com_pend				= 0.0;
	LET dCsg_iva_com				= 0.0;
	LET dCsg_sdo_retenido			= 0.0;
	LET dCsg_tot_liquidacion		= 0.0;
	LET dCsg_int_devengado			= 0.0;
	LET dCsg_iva_int_devengado		= 0.0;
	LET dCsg_linea_disp				= 0.0;
	LET dCsg_pagos_vdos				= 0.0;
	LET cCsg_desc_status_cred		= "";
	LET iCsg_id_bloqueo_cred		= 0;
	LET cCsg_bloqueo_cta			= "";
	LET cCsg_id_causa_bloq_cred		= "";
	LET cCsg_causa_bloqueo_cta		= "";
	LET cCsg_id_sit_esp_cte			= "";
	LET iCsg_id_causa_esp_cte		= 0;
	LET cCsg_sit_esp_cte			= "";
	LET cCsg_id_sit_esp_cred		= "";
	LET iCsg_id_causa_esp_cred		= 0;
	LET cCsg_sit_esp_cred			= "";
    LET vvalor1                     = 0;
    LET vvalor2                     = 0;
    LET vcompras                    = 0;
	LET dMontoDiferir_aux	        = 0;
    LET vdivisa                     = '00';
    LET v_dv                        = "00";
    LET v_tipocambio                = 0;
    LET vsucorig                    = "";
    LET vPromoRetSdo                = 0;
    LET vPromoRetSdo2               = 0;
    LET vs_precal_num_promo         = 0;
    LET vs_secuencia                = 0;
    -- VARIABLES PARA OBTENER RESPUESTA DEL SP: sp_proyecta_prest_credisol
    LET c_CodigoRet_pp              = '';
    LET i_Periodo_pp                = 0;
    LET d_FechaCouta_pp             = MDY(1,1,1900);
    LET dd_SaldoInicial_pp          = 0.0;
    LET dd_Mensualidad_pp           = 0.0;
    LET dd_Mensualidad_aux_pp       = 0.0;
    LET dd_Intereses_pp             = 0.0;
    LET dd_IvaInteres_pp            = 0.0;
    LET dd_Capital_pp               = 0.0;
    LET dd_SaldoFinal_pp            = 0.0;
    LET dd_SaldoFinal_aux_pp        = 0.0;
    LET s_DiasPeriodo_pp            = 0;
    LET d_FechaAper_pp              = MDY(1,1,1900);
    LET c_NumMesesPago_pp           = '';
    LET i_Cont                      = 0;
    LET v_bandesp                   = 0;
    LET v_NumCredito                ='';
	LET sCountExists				= 0;
	LET sYield						= 0;
	LET vProducto			        ='';


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			RETURN cCodRet, cMensajeRet, NVL(dTotalPagar,0), NVL(sNumPagos,0), NVL(dPagoMensual,0), NVL(dInterIvaPlazoMax,0), NVL(dSaldoTDC,0), NVL(cFolioPromo,'');
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    --SET DEBUG FILE TO '/tmp/sp_proyecta_promo_MOD1.out';
	--TRACE ON;
	  
	--SE OBTIENE LA FECHA HOY.
	SELECT fecha_hoy INTO dtFechaHoy
	  FROM "informix".sd_fechas WHERE empresa = '001';	  

	SELECT valor INTO v_dv FROM bdinteg:si_param WHERE cod_param = 17;

    SELECT precio_venta
	  INTO v_tipocambio
	  FROM bdinteg:"informix".si_tpcambio
	 WHERE empresa = "001"
	   AND divisa = v_dv
	   AND clase_tpcambio = "O"
	   AND fecha_tpcambio = (SELECT MAX(fecha_tpcambio)
				   FROM bdinteg:"informix".si_tpcambio
				  WHERE empresa = "001"
					AND divisa = v_dv);

	-- VALIDA QUE LOS PARAMETROS NO VENGAN VACIOS
    IF pTipo IS NULL OR NVL(pSucursal,'') = '' OR NVL(pEjecutivo,'') = '' OR pNumPromocion IS NULL
			OR (NVL(pNumCredito,'') = '' AND NVL(pNumTarjeta,'') = '') OR (pTipo = 1 AND pMonto IS NULL)
			OR (pTipo = 2 AND pMonto IS NULL) OR (pTipo = 3 AND NVL(pMonto,0) = 0)
			OR (pTipo = 1 AND pPlazo IS NULL) OR (pTipo = 2 AND pPlazo IS NULL )
			OR (pTipo = 3 AND NVL(pPlazo,0) = 0) THEN
		LET cCodRet = '00432';
		LET cMensajeRet = 'FALTA UNO O MAS PARAMETROS';
    END IF;
	-- VALIDA EL TIPO DE EJECUCION
	IF cCodRet = '00000' AND pTipo NOT IN (1,2,3) THEN
		LET cCodRet = '00434';
		LET cMensajeRet = 'EL PARAMETRO TIPO NO ES VALIDO';
	END IF;
	-- VALIDA EL EJECUTIVO Y OBTIENE EL SU NOMBRE
	IF cCodRet = '00000' THEN
        SELECT nombre
		INTO vcNomEjecutivo
		FROM bdinteg:"informix".si_ejecut
		WHERE ejecutivo = pEjecutivo;
		IF NVL(vcNomEjecutivo,'') = '' THEN
			LET cCodRet = '00435';
			LET cMensajeRet = 'CODIGO DE EJECUTIVO NO ES VALIDO';
		END IF;
	END IF;

	--*** VALOR DE PARAMETRO 901 ESTA POR MIENTRAS
	-- OBTIENE EL VALOR MINIMO CONTEMPLADO PARA EL MONTO A DIFERIR EN LAS PROMOCIONES DE CREDISOLUCION
	IF cCodRet = '00000' THEN
		SELECT TRIM(valor)::DECIMAL(18,2)
		INTO dValorMinDiferir
		FROM "informix".sd_param
		WHERE cod_param  = '029';
		IF dValorMinDiferir IS NULL THEN
			LET cCodRet = '00437';
			LET cMensajeRet = 'ERROR AL OBTENER EL PARAMETRO DEL VALOR MINIMO A DIFERIR';
		END IF;
	END IF;


	SELECT COUNT(num_credito) INTO sCountExists FROM "informix".sd_credpaso 
	 WHERE num_credito = pNumCredito and num_promo = pNumPromocion and activo = 1;
    --IF EXISTS() THEN
	IF sCountExists	> 0 THEN
		LET sCountExists = 0;
        LET v_bandesp=1;
    END IF

    IF pNumPromocion IN (1, 4, 7) THEN   --FMV 11nov13 : Campañas 1.-Permanente, 4.-Temporal y 7.-Especial en Efectivo
        -- VALIDA QUE EL MONTO A DIFERIR SEA MAYOR AL VALOR MINIMO DE LA PROMOCION PARA LA PROMOCION DE EFECTIVO
        -- Mahr Feb2015: No valide el monto para credisoluciones ya credisol ya generadas, las ya autorizadas, no las rechaza (solicitudes con saldo a favor)
        -- credisol, ya generadas y pendientes, si las pase.
        IF cCodRet = '00000' AND pMonto < dValorMinDiferir 
            AND ( (select count(*) from bdicred:sd_promocion_credito where num_promo = pNumPromocion and num_credito = pNumCredito 
                           and folio_movto = pFolioMovto and status = 0 ) = 0 ) THEN
            LET cCodRet = '01433';
			LET cMensajeRet = 'EL CLIENTE NO ES VIABLE PARA DIFERIR ';
		END IF;
	END IF;

	-- VALIDA QUE AL MENOS RECIBA EL NUMERO DE CREDITO O LA TARJETA
    IF cCodRet = '00000' AND (NVL(pNumCredito,'') = '' OR NVL(pNumTarjeta,'') = '' ) THEN
		IF NVL(pNumCredito,'') <> '' THEN
             /*SELECT b.num_credito, a.num_tarjeta, a.numcte, b.divisa, b.sucursal INTO pNumCredito, pNumTarjeta, vcNumCte, vdivisa, vsucorig
			  FROM "informix".sd_tarjeta a, "informix".sd_maecred b WHERE a.empresa = b.empresa AND a.num_credito = pNumCredito
               AND a.num_credito = b.num_credito AND a.tipo_tarjeta = 'T' AND a.status_tar = 'A' AND b.status_cred = 'AA'; */
            SELECT a.num_credito, a.numcte, a.divisa, a.sucursal, a.num_producto
			  INTO pNumCredito,  vcNumCte, vdivisa, vsucorig, vProducto
			  FROM bdicred:"informix".sd_maecred a
			  INNER JOIN bdicred:sd_maesdos maes on (a.num_credito = maes.num_credito)
		     WHERE a.empresa = '001' 
			   AND a.num_credito = pNumCredito
			   AND a.status_cred IN ('AA','E1') 
			   and (maes.monto_vencido + maes.mto_venc_trasp) = 0;

            IF NVL(pNumCredito,'') = '' THEN
                LET cCodRet = '00439';
				LET cMensajeRet = 'NUMERO DE CREDITO NO ESTA VIGENTE O NO ES VALIDO';
			END IF
        ELIF NVL(pNumTarjeta,'') <> '' THEN

            SELECT a.num_tarjeta, b.num_credito, a.numcte, b.divisa,sucursal
		  	  INTO pNumTarjeta, pNumCredito, vcNumCte,vdivisa,vsucorig
			  FROM "informix".sd_tarjeta a, "informix".sd_maecred b,  "informix".sd_maesdos maes
			 WHERE a.num_tarjeta = pNumTarjeta
               AND a.tipo_tarjeta = 'T'
               AND a.status_tar IN ('A','I')			 
			   AND a.empresa = b.empresa
			   AND a.num_credito = b.num_credito			 
			   AND a.num_credito = maes.num_credito
			   AND b.status_cred IN ('AA','E1') 
			   and (maes.monto_vencido+maes.mto_venc_trasp) = 0;

            IF NVL(pNumTarjeta,'') = '' THEN
                LET cCodRet = '00440';
				LET cMensajeRet = 'NUMERO DE TARJETA NO ES VALIDO O SU CREDITO NO ESTA VIGENTE';
			END IF;
		END IF;
	END IF;

    -- VALIDA QUE EL NUMERO DE PROMOCION
    IF cCodRet = '00000' THEN
        -- OBTIENE LA PROMOCION PRECALIFICADA.
		IF pNumPromocion IN (2,5,8)THEN --COMPRAS
            SELECT MAX(secuencia)
             INTO vs_secuencia
             FROM "informix".sd_precal_credsol
            WHERE num_credito = pNumCredito
            AND num_promo IN (2,5,8);
        ELIF pNumPromocion IN (3,6,9)THEN --SALDOS
            SELECT max(secuencia)
             INTO vs_secuencia
             FROM "informix".sd_precal_credsol
            WHERE num_credito = pNumCredito
            AND num_promo IN (3,6,9);
        ELIF pNumPromocion IN (1,4,7)THEN --EFECTIVO
            SELECT max(secuencia)
             INTO vs_secuencia
             FROM "informix".sd_precal_credsol
            WHERE num_credito = pNumCredito
            AND num_promo IN (1,4,7);
        END IF

        SELECT num_promo
          INTO vs_precal_num_promo
          FROM "informix".sd_precal_credsol
         WHERE num_credito = pNumCredito
           AND secuencia = vs_secuencia;

        -- FMV Reasigana el valor de la promocion por la campaña previamente valida en el Sp_val_datos_promo
        IF NVL(vs_precal_num_promo,0) <> 0 THEN
            LET pNumPromocion = vs_precal_num_promo;
        END IF;

        SELECT nombre_promo
          INTO vcNomPromocion
          FROM "informix".sd_promocion
         WHERE num_promo = pNumPromocion;
        IF NVL(vcNomPromocion,'') = '' THEN
            LET cCodRet = '00436';
            LET cMensajeRet = 'EL PARAMETRO NUMERO DE PROMOCION NO ES VALIDO';
        END IF;
    END IF;

    IF cCodRet = '00000' THEN
		/*--SE OBTIENE LA FECHA HOY.
		SELECT fecha_hoy INTO dtFechaHoy  FROM "informix".sd_fechas  WHERE empresa = '001'; se cambia ubicacion de consulta*/
		--- OBTIENE LOS SALDOS ACTUALES DEL CREDITO
        EXECUTE PROCEDURE "informix".sp_consulta_saldos_general('001',pNumCredito)
		INTO cCsg_codigo_ret,cCsg_mensaje_ret,cCsg_num_credito,cCsg_cod_tipcred,dtCsg_fec_origen,dtCsg_fec_prox_pago,dCsg_pago_min,
			dtCsg_fec_ult_pago,iCsg_plazo,iCsg_pagos_realizados,dCsg_linea_otorgada,dCsg_tasa_interes,dCsg_tasa_moratorios,
			dCsg_monto_sbc,dCsg_cap_vig,dCsg_cap_trans,dCsg_cap_vdo_exig,dCsg_cap_vdo_no_exig,dCsg_sdo_act_total_cap,dCsg_int_vig,
			dCsg_int_vdo,dCsg_int_moratorios,dCsg_int_mes,dCsg_sdo_act_total_int,dCsg_iva_int_vig,dCsg_iva_int_vdo,dCsg_iva_int_moratorios,
			dCsg_iva_int_mes,dCsg_sdo_act_total_iva,dCsg_com_pend,dCsg_iva_com,dCsg_sdo_retenido,dCsg_tot_liquidacion,dCsg_int_devengado,
			dCsg_iva_int_devengado,dCsg_linea_disp,dCsg_pagos_vdos,cCsg_desc_status_cred,iCsg_id_bloqueo_cred,cCsg_bloqueo_cta,
			cCsg_id_causa_bloq_cred,cCsg_causa_bloqueo_cta,cCsg_id_sit_esp_cte,iCsg_id_causa_esp_cte,cCsg_sit_esp_cte,cCsg_id_sit_esp_cred,
			iCsg_id_causa_esp_cred,cCsg_sit_esp_cred;

		IF cCsg_codigo_ret::INTEGER <> 0 THEN
            LET cCodRet = '00441';
			LET cMensajeRet = 'OCURRIO UN ERROR EN EL SP DE CONSULTA DE SALDOS GENERAL';
		ELSE
            IF pTipo = 2 AND pNumPromocion in (3, 6, 9) AND pMonto = 0 AND pPlazo = 0 THEN
                --LET dSaldoTDC = dCsg_linea_otorgada - dCsg_linea_disp;
                LET dSaldoTDC =dCsg_cap_vig;
            ELSE
                IF pTipo = 1 THEN
                    -- OBTIENE EL PLAZO MINIMO PARA EL NUMERO DE CAMPAÑA
                    SELECT MAX(plazo)
				 	  INTO sNumPagos
					  FROM "informix".sd_tasa_plazo
					 WHERE num_promo = pNumPromocion;
                    IF NVL(sNumPagos,0) = 0 THEN
                        LET cCodRet = '00442';
						LET cMensajeRet = 'ERROR AL OBTENER EL PLAZO MAXIMO DE LA PROMOCION';
                    END IF;
                ELSE
					-- VALIDA EL PLAZO
                    SELECT plazo
   			    	  INTO sNumPagos
					  FROM "informix".sd_tasa_plazo
					 WHERE num_promo = pNumPromocion
                       AND plazo = pPlazo
                       AND plazo_activo = 1;    --FMV 5jun14: Valida este activo
                    LET sNumPagos = NVL(sNumPagos,0);

                    IF sNumPagos = 0 THEN
                        LET cCodRet = '00443';
						LET cMensajeRet = 'EL PLAZO NO ES VALIDO PARA LA PROMOCION';
                    END IF;
                END IF;

                IF cCodRet = '00000' THEN
					-- OBTIENE LA TASA DE LA PROMOCION
                    SELECT tasa
					  INTO dTasaAnual
					  FROM "informix".sd_tasa_plazo
				 	 WHERE num_promo = pNumPromocion
                       AND plazo = sNumPagos
                       AND plazo_activo = 1;    --FMV 5jun14: Valida este activo
					-- VALIDA QUELA SUCURSAL EXISTA Y ADEMAS OBTIENE EL IVA
                    SELECT iva
					  INTO dFactorIvaSucursal
					  FROM bdinteg:"informix".si_sucursales
					 WHERE sucursal = pSucursal;

                    IF cCodRet = '00000' AND NVL(dFactorIvaSucursal,0.0) = 0.0 THEN
                        LET cCodRet = '00444';
						LET cMensajeRet = 'SUCURSAL NO EXISTE O FALTA FACTOR DE IVA DE SUCURSAL';
					END IF;

					-- CALCULA LA TASA ANUAL CON IVA
                    LET dTasaAnualIva = (dTasaAnual/100) * (1 + dFactorIvaSucursal);
					-- VALIDA SI SE TRATA DE PROMOCION DE EFECTIVO
					IF cCodRet = '00000' THEN
                        --PROMOCION 1
                        IF pNumPromocion in (1, 4, 7) THEN  --FMV 5jun14: Campañas en Ventanilla Sucursal
                            -- OBTIENE EL CODIGO PARA LA COMISION DE LA DISPOSICION DE EFECTIVO
							SELECT TRIM(valor)::CHAR(4)
							  INTO cCodComDispEfectivo   --> FMV valor fijo variable: 6901
						 	  FROM "informix".sd_param
							 WHERE cod_param  = '334';
                            IF NVL(cCodComDispEfectivo,'') = '' THEN
                                LET cCodRet = '00445';
                                LET cMensajeRet = 'ERROR AL OBTENER EL PARAMETRO DEL CODIGO DE LA COMISION DE DISP. DE EFECTIVO';
							END IF;
							-- OBTIENE EL FACTOR PARA LA COMISION DE LA DISPOSICION DE EFECTIVO
                            SELECT apli_factor
							  INTO dFactorComDispEfect    --> FMV valor de la variable : 7
							  FROM "informix".sd_tpcomis
							 WHERE cod_comis = cCodComDispEfectivo;
                            IF NVL(dFactorComDispEfect,0.0) = 0.0 THEN
                                LET cCodRet = '00446';
								LET cMensajeRet = 'ERROR AL OBTENER EL PARAMETRO DEL FACTOR DE LA COMISION DE DISP. DE EFECTIVO';
							END IF;

                            --FMV 20-JUN14  TIENE SALDO A FAVOR Y LA CONTRATACION DE CREDISOLICIONES ES MENOR O IGUAL AL SALDO A FAVOR, NO CONTRATA
                            IF dCsg_cap_vig < 0 THEN   --  'OJO'
                                LET pMonto = pMonto + dCsg_cap_vig;  --FMV Se suma el monto negativo para descontar
                                --      dCsg_cap_vig >= (pMonto + dComisDisposicion + dIvaComision + dInterIvaPlazoMax)
                                --      LET cCodRet = '02433';
                                --		LET cMensajeRet = 'EL CLIENTE NO ES VIABLE PARA DIFERIR ';
                                --  MAHR Feb 2015 // Valida si el monto de la credisol (Retiro + Saldo Favor) es negativo (sigue estando Sdo Favor
                                --  (mayor el saldo a favor que el retiro, o el Sdo Favor = Monto del Retiro => no genere la credisolucion.
                                --IF (pMonto < 0 AND pMonto >= ( dValorMinDiferir * -1 )) OR  pMonto = 0  OR pMonto < dValorMinDiferir THEN
                                IF ( pMonto <= 0 ) THEN
                                    LET cCodRet = '02433';
                                    LET cMensajeRet = 'EL CLIENTE NO ES VIABLE PARA DIFERIR ';
                                END IF;
                            END IF;

                            -- CALCULA LA COMISION POR LA DISPOSICION
							LET dComisDisposicion = pMonto * (dFactorComDispEfect/100);
							-- CALCULA EL IVA DE LA COMISION
							LET dIvaComision = dComisDisposicion * dFactorIvaSucursal;
							-- CALCULA EL FACTOR INTERES IVA
                                --LET dFactorInteresIva = POW((1 + dTasaAnualIva/12), sNumPagos);
							-- CALCULA EL PAGO MENSUAL Y MONTO FINAL
                            --LET dPagoMensual = pMonto * (((dTasaAnualIva/12)*dFactorInteresIva) / (dFactorInteresIva - 1));
                            -- MAHR Se modifica el calculo del pago mensual por el llamado al sp: sp_proyecta_prest_credisol
                            --LET dPagoMensual = ROUND((pMonto *30.5* dTasaAnualIva/12)/ (30 * (1 - POW((1 + dTasaAnualIva/12),-sNumPagos))), 0);
                            LET i_Cont = 0;
                            LET dd_SaldoFinal_pp = 0;
                            LET pPlazo = pPlazo;
                            IF v_bandesp=1 THEN
                                LET v_NumCredito=pNumCredito;
                            END IF;
                            FOREACH                 
                                EXECUTE PROCEDURE bdicred:"informix".sp_proyecta_prest_credisol(pMonto,pPlazo::INTEGER,0,'6900',pSucursal,1,0,v_NumCredito,null,1,pNumPromocion::INTEGER) INTO
                                c_CodigoRet_pp, i_Periodo_pp, d_FechaCouta_pp, dd_SaldoInicial_pp, dd_Mensualidad_aux_pp, dd_Intereses_pp, dd_IvaInteres_pp, 
                                dd_Capital_pp, dd_SaldoFinal_aux_pp, s_DiasPeriodo_pp, d_FechaAper_pp, c_NumMesesPago_pp

                                IF c_CodigoRet_pp != '000000' THEN
                                    LET cMensajeRet = 'ERROR AL EJECUTAR sp_proyecta_prest_credisol';
                                    RETURN c_CodigoRet_pp, TRIM(cMensajeRet), NVL(dTotalPagar,0), NVL(sNumPagos,0), NVL(dPagoMensual,0), NVL(dInterIvaPlazoMax,0), NVL(dSaldoTDC,0), TRIM(cFolioPromo);
                                END IF;

                                LET i_Cont = i_Cont + 1;
                                IF i_Cont = 1 THEN
                                    LET dd_Mensualidad_pp = dd_Mensualidad_aux_pp;
                                END IF;
                                LET dd_SaldoFinal_pp = dd_SaldoFinal_pp + dd_Mensualidad_aux_pp;
                            END FOREACH;

                            LET dPagoMensual = dd_Mensualidad_pp;
							-- CALCULA EL PAGO POR PLAZO
						       --LET dPagoPorPlazo = dPagoMensual * sNumPagos;
							-- CALCULA EL INTERES E IVA A PLAZO MAXIMO
                               --LET dInterIvaPlazoMax = dPagoPorPlazo - pMonto;
							LET dInterIvaPlazoMax = dd_SaldoFinal_pp - pMonto;
							--LET dTotalPagar = pMonto + dInterIvaPlazoMax;
                            LET dTotalPagar = dd_SaldoFinal_pp;
							-- VALIDA SI LA PROYECCION ES DE TIPO CONSULTA
							IF cCodRet = '00000' AND pTipo = 1 THEN
                                -- VALIDA SI EL CLIENTE ES VIABLE PARA DIFERIR EL MONTO DE EFECTIVO
                                IF (dCsg_linea_disp < (pMonto + dComisDisposicion + dIvaComision + dInterIvaPlazoMax)) THEN
									LET cCodRet = '02433';
									LET cMensajeRet = 'EL CLIENTE NO ES VIABLE PARA DIFERIR ';
								END IF;
								LET dTotalPagar = 0;
								LET sNumPagos = 0;
								LET dPagoMensual = 0;
								LET dInterIvaPlazoMax = 0;

                            -- VALIDA SI LA PROYECCION ES PARA RETORNAR EL DESGLOSE
                            ELIF cCodRet = '00000' AND pTipo = 2 THEN
								-- VALIDA QUE SI TRAE EL FOLIO DEL MOVIMIENTO QUE SE RECIBE CUANDO SE MANDA A LLAMAR EL PROCESO DESDE EL PROCESO NOCTURNO
                                IF NVL(pFolioMovto,"") <> "" THEN
                                    -- OBTIENE EL MONTO DE LOS INTERESES RETENIDOS DE LA PROMOCION POR MEDIO DEL FOLIO DEL MOVTO
                                    SELECT SUM(monto_actual + monto_int_iva)
									  INTO dMontoPromo
									  FROM "informix".sd_promocion_credito
									 WHERE status = 0
									   AND fecha = dtFechaHoy
                                       AND num_credito = pNumCredito
                                       AND num_promo = pNumPromocion
                                       AND folio_movto = pFolioMovto;

                                END IF;

                                -- IF (dCsg_linea_disp + dMontoPromo ) < (pMonto + dComisDisposicion + dIvaComision + dInterIvaPlazoMax) THEN
                                IF dCsg_linea_disp < 0 THEN
                                    LET cCodRet = '03433';
									LET cMensajeRet = 'EL CLIENTE NO ES VIABLE PARA DIFERIR ';
									--LET dTotalPagar = 0;
									--LET sNumPagos = 0;
									--LET dPagoMensual = 0;
									--LET dInterIvaPlazoMax = 0;
                                END IF;
                            -- VALIDA SI LA PROYECCION ES PARA GUARDAR EL DESGLOSE EN TABLA
							ELIF cCodRet = '00000' AND pTipo = 3 THEN
                                IF dCsg_linea_disp < (pMonto + dComisDisposicion + dIvaComision + dInterIvaPlazoMax) THEN
                                    LET cCodRet = '04433';
									LET cMensajeRet = 'EL CLIENTE NO ES VIABLE PARA DIFERIR ';
									LET dTotalPagar = 0;
									LET sNumPagos = 0;
									LET dPagoMensual = 0;
									LET dInterIvaPlazoMax = 0;
                                ELSE
                                    --- PROCESO GENERICO PARA GENERAR UN FOLIO PARA LA PROMOCION
                                    --EXECUTE PROCEDURE bdicheq:"informix".sp_generafolionomina(pEjecutivo)
									--INTO cCodRetGF,cFolioSucGF;
									LET cCodRetGF = '000000';
									SELECT pEjecutivo || substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,1,2)
										 ||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,4,2)
										 ||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,7,2)
										 ||lpad(bdicheq:sp_random(),2,'0')
									INTO cFolioSucGF 
									FROM sysmaster:sysshmvals;
										-------
										-- Valida folio no exista y lo recalcula si existe
										LET sCountExists = 0;  
										SELECT COUNT(folio_suc) INTO sCountExists FROM bdicred:"informix".sd_promocion_credito 
										 WHERE empresa = '001' AND folio_suc = cFolioSucGF;
										IF sCountExists > 0 THEN
											SELECT pEjecutivo || substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,1,2)
												||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,4,2)
												||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,7,2)
												||lpad(bdicheq:sp_random(),2,'0'), sysmaster:yieldn( 1 )
											  INTO cFolioSucGF, sYield FROM sysmaster:sysshmvals;
										END IF;
										-------
									
                                    IF cCodRetGF::INTEGER <> 0 THEN
                                        LET cCodRet = '00447';
										LET cMensajeRet = 'OCURRIO UN ERROR EN EL PROCESO QUE GENERA EL FOLIO';
										LET dTotalPagar = 0;
										LET sNumPagos = 0;
										LET dPagoMensual = 0;
										LET dInterIvaPlazoMax = 0;
									ELSE
                                        LET cFolioPromo = cFolioSucGF;
										-- DA DE ALTA LA PROMOCION PARA EL CREDITO
										INSERT INTO "informix".sd_promocion_credito
										(empresa,sistema,num_promo,fecha,ejecutivo,num_cte,num_credito,num_tarjeta,plazo,folio_suc,monto_actual,monto_int_iva,mensualidad,status,nombre_promo,sucursal,num_sol_prestamo,num_pro_prestamo,folio_movto)
										VALUES ('001','06',pNumPromocion,dtFechaHoy,pEjecutivo,vcNumCte, pNumCredito,pNumTarjeta,pPlazo,cFolioSucGF,pMonto,dInterIvaPlazoMax,dPagoMensual,6,vcNomPromocion,pSucursal,'','6900',pFolioMovto);
                                    END IF;
                                END IF;
                            END IF;
                        -- VALIDA SI SE TRATA DE  PROMOCION DE COMPRAS
                        --PROMOCION 2
                        ELIF pNumPromocion in (2, 5, 8 )THEN
                            IF pTipo = 1 THEN
                                IF DAY(dtFechaHoy) > 20 THEN
                                    LET dtFechaCorte = MDY(MONTH(dtFechaHoy),20,YEAR(dtFechaHoy));
                                ELSE
                                    EXECUTE PROCEDURE bdicred:"informix".monthadd(dtFechaHoy, -1)
									INTO dtFechaCorte;
									LET dtFechaCorte = MDY(MONTH(dtFechaCorte),20,YEAR(dtFechaCorte));
                                END IF;
                                LET dtFechaCorte = dtFechaCorte + 1;

                                --FMV 3-SEP-14: LAS COMPRAS DEL DIA NO SE CONSIDERAN PARA LAS PROMOCIONES, TENDRAN QUE CONTRATARSE AL SIGUIENTE DIA 
                                -- EN LA SUCURSAL POR LO TANTO, SE OMITE SD_MOVDIA PARA VALIDACION DE COMPRAS EXCLUSIVAS EN LA TABLA HISTORICA DE MOVIMIENTOS.
                                -- OBTIENE EL MONTO MAXIMO DE LAS COMPRAS DEL CREDITO EN LOS MOVIMIENTOS DIARIOS
                                /*FOREACH
                                    SELECT nvl(monto,0)
                                      INTO dMontoDiferir_aux
                                      FROM bdicred:"informix".sd_movdia a, bdinteg:"informix".si_transacc b
                                     WHERE a.empresa = b.empresa
                                       AND a.num_credito = pNumCredito
                                       AND folio_suc NOT IN (SELECT folio_movto FROM bdicred:sd_promocion_credito
                                                                               WHERE num_promo = pNumPromocion
                                                                                 AND num_credito = pNumCredito
                                                                                 AND status IN (2,0))
                                       AND a.transacc_suc = b.numero
                                       AND b.naturaleza = 'C'
                                       AND a.reversado = 'N'
                                       AND a.codigo_ref IN (37,57)
                                       AND a.monto >= dValorMinDiferir
                                    IF dMontoDiferir_aux = 0 THEN
                                        LET dFactorInteresIva = 0;
                                        LET dPagoMensual = 0;
                                        LET dPagoPorPlazo = 0;
                                        LET dInterIvaPlazoMax = 0;
                                        LET dTotalPagar = 0;
                                        LET dMontoDiferir_aux = 0;
                                        CONTINUE FOREACH;
                                     ELIF dMontoDiferir_aux <> 0 AND dCsg_tot_liquidacion >= dMontoDiferir_aux THEN
                                   --  ELIF dMontoDiferir_aux <> 0 AND dCsg_linea_disp >= dMontoDiferir_aux THEN
                                            LET dFactorInteresIva = POW((1 + dTasaAnualIva/12), sNumPagos);
                                            LET dPagoMensual = dMontoDiferir_aux * (((dTasaAnualIva/12)*dFactorInteresIva) / (dFactorInteresIva - 1));
                                            LET dPagoPorPlazo = dPagoMensual * sNumPagos;
                                            LET dInterIvaPlazoMax = dPagoPorPlazo - dMontoDiferir_aux;
                                            LET dTotalPagar = pMonto + dInterIvaPlazoMax;
                                         IF dCsg_linea_disp > (dInterIvaPlazoMax) THEN
                                            LET dFactorInteresIva = 0;
                                            LET dPagoMensual = 0;
                                            LET dPagoPorPlazo = 0;
                                            LET dInterIvaPlazoMax = 0;
                                            LET dTotalPagar = 0;
                                            LET vcompras = 1;
                                            LET dMontoDiferir = dMontoDiferir_aux;
                                          ELSE
                                            CONTINUE FOREACH;
                                         END IF;
                                    END IF;
                                END FOREACH;
*/
								IF NVL(dMontoDiferir,0) = 0 THEN
                                    -- OBTIENE EL MONTO MAXIMO DE LAS COMPRAS DEL CREDITO EN LOS MOVIMIENTOS HISTORICOS
                                    FOREACH
                                        SELECT nvl(monto,0)
                                          INTO dMontoDiferir_aux
                                          FROM "informix".sd_movhis a, bdinteg:"informix".si_transacc b
                                         WHERE a.empresa = b.empresa
                                           AND a.fecha_mov >= dtFechaCorte
                                           AND a.fecha_mov <= dtFechaHoy
                                           AND a.transacc_suc = b.numero
                                           AND a.num_credito = pNumCredito
                                           AND folio_suc NOT IN (SELECT folio_movto FROM "informix".sd_promocion_credito
                                                                                   WHERE num_promo = pNumPromocion
                                                                                     AND num_credito = pNumCredito
                                                                                     AND status IN (2,0))
                                           AND b.naturaleza = 'C'
										   AND b.sistema = '06'
                                           AND a.reversado = 'N'
                                           AND a.codigo_ref IN (37,57,937,938)
                                           AND a.monto >= dValorMinDiferir

                                        IF dMontoDiferir_aux = 0 THEN
                                            LET dFactorInteresIva = 0;
                                            LET dPagoMensual = 0;
                                            LET dPagoPorPlazo = 0;
                                            LET dInterIvaPlazoMax = 0;
                                            LET dTotalPagar = 0;
                                            LET dMontoDiferir_aux = 0;
                                            CONTINUE FOREACH;
                                        ELIF dMontoDiferir_aux <> 0 AND dCsg_tot_liquidacion >= dMontoDiferir_aux THEN
                                        -- ELIF dMontoDiferir_aux <> 0 AND dCsg_linea_disp >= dMontoDiferir_aux THEN
                                            --LET dFactorInteresIva = POW((1 + dTasaAnualIva/12), sNumPagos);
                                            --LET dPagoMensual = dMontoDiferir_aux * (((dTasaAnualIva/12)*dFactorInteresIva) / (dFactorInteresIva - 1));

                                            -- MAHR Se modifica el calculo del pago mensual por el llamado al sp: sp_proyecta_prest_credisol
                                            --LET dPagoMensual = ROUND((dMontoDiferir_aux *30.5* dTasaAnualIva/12)/ (30 * (1 - POW((1 + dTasaAnualIva/12),-sNumPagos))), 0);    
                                            --LET dPagoPorPlazo = dPagoMensual * sNumPagos;
                                            --LET dInterIvaPlazoMax = dPagoPorPlazo - dMontoDiferir_aux;
                                            --LET dTotalPagar = pMonto + dInterIvaPlazoMax;

                                            LET i_Cont = 0;
                                            LET dd_SaldoFinal_pp = 0;
                                            LET pPlazo = pPlazo;
                                            IF v_bandesp=1 THEN
                                                LET v_NumCredito=pNumCredito;
                                            END IF;
                                            FOREACH
                                                EXECUTE PROCEDURE bdicred:"informix".sp_proyecta_prest_credisol(pMonto,pPlazo::INTEGER,0,'6900',pSucursal,1,0,v_NumCredito,null,1,pNumPromocion::INTEGER) INTO
                                                c_CodigoRet_pp, i_Periodo_pp, d_FechaCouta_pp, dd_SaldoInicial_pp, dd_Mensualidad_aux_pp, dd_Intereses_pp, dd_IvaInteres_pp, 
                                                dd_Capital_pp, dd_SaldoFinal_aux_pp, s_DiasPeriodo_pp, d_FechaAper_pp, c_NumMesesPago_pp

                                                IF c_CodigoRet_pp != '000000' THEN
                                                    LET cMensajeRet = 'ERROR AL EJECUTAR sp_proyecta_prest_credisol';
                                                    RETURN c_CodigoRet_pp, TRIM(cMensajeRet), NVL(dTotalPagar,0), NVL(sNumPagos,0), NVL(dPagoMensual,0), NVL(dInterIvaPlazoMax,0), NVL(dSaldoTDC,0), TRIM(cFolioPromo);
                                                END IF;

                                                LET i_Cont = i_Cont + 1;
                                                IF i_Cont = 1 THEN
                                                    LET dd_Mensualidad_pp = dd_Mensualidad_aux_pp;
                                                END IF;
                                                LET dd_SaldoFinal_pp = dd_SaldoFinal_pp + dd_Mensualidad_aux_pp;
                                            END FOREACH;

                                            LET dPagoMensual = dd_Mensualidad_pp;
                                            LET dPagoPorPlazo = dd_SaldoFinal_pp;
                                            LET dInterIvaPlazoMax = dPagoPorPlazo - dMontoDiferir_aux;
                                            LET dTotalPagar = dd_SaldoFinal_pp;

                                            IF dCsg_linea_disp > (dInterIvaPlazoMax) THEN
                                                LET dFactorInteresIva = 0;
                                                LET dPagoMensual = 0;
                                                LET dPagoPorPlazo = 0;
                                                LET dInterIvaPlazoMax = 0;
                                                LET dTotalPagar = 0;
                                                LET vcompras = 1;
                                                LET dMontoDiferir = dMontoDiferir_aux;
                                            ELSE
                                                CONTINUE FOREACH;
                                            END IF;
                                        END IF;
                                    END FOREACH;
                                END IF;

                            ELIF pTipo IN (2,3) THEN
								LET dMontoDiferir = pMonto;
							END IF;

                            IF (vcompras = 0 AND NVL(dMontoDiferir,0) = 0) THEN
                                LET cCodRet = '05433';
								LET cMensajeRet = 'EL CLIENTE NO ES VIABLE PARA DIFERIR ';
								LET dTotalPagar = 0;
								LET sNumPagos = 0;
								LET dPagoMensual = 0;
								LET dInterIvaPlazoMax = 0;
							ELSE
                                -- CALCULA EL FACTOR INTERES IVA
								   --LET dFactorInteresIva = POW((1 + dTasaAnualIva/12), sNumPagos);
								-- CALCULA EL PAGO MENSUAL
								--LET dPagoMensual = dMontoDiferir * (((dTasaAnualIva/12)*dFactorInteresIva) / (dFactorInteresIva - 1));
                                -- MAHR Se modifica el calculo del pago mensual por el llamado al sp: sp_proyecta_prest_credisol
                                --LET dPagoMensual = ROUND((dMontoDiferir *30.5* dTasaAnualIva/12)/ (30 * (1 - POW((1 + dTasaAnualIva/12),-sNumPagos))), 0);
                                LET i_Cont = 0;
                                LET dd_SaldoFinal_pp = 0;
                                LET pPlazo = pPlazo;
                                IF v_bandesp=1 THEN
                                    LET v_NumCredito=pNumCredito;
                                END IF;
                                FOREACH
                                    EXECUTE PROCEDURE bdicred:"informix".sp_proyecta_prest_credisol(pMonto,pPlazo::INTEGER,0,'6900',pSucursal,1,0,v_NumCredito,null,1,pNumPromocion::INTEGER) INTO
                                    c_CodigoRet_pp, i_Periodo_pp, d_FechaCouta_pp, dd_SaldoInicial_pp, dd_Mensualidad_aux_pp, dd_Intereses_pp, dd_IvaInteres_pp, 
                                    dd_Capital_pp, dd_SaldoFinal_aux_pp, s_DiasPeriodo_pp, d_FechaAper_pp, c_NumMesesPago_pp

                                    IF c_CodigoRet_pp != '000000' THEN
                                        LET cMensajeRet = 'ERROR AL EJECUTAR sp_proyecta_prest_credisol';
                                        RETURN c_CodigoRet_pp, TRIM(cMensajeRet), NVL(dTotalPagar,0), NVL(sNumPagos,0), NVL(dPagoMensual,0), NVL(dInterIvaPlazoMax,0), NVL(dSaldoTDC,0), TRIM(cFolioPromo);
                                    END IF;

                                    LET i_Cont = i_Cont + 1;
                                    IF i_Cont = 1 THEN
                                        LET dd_Mensualidad_pp = dd_Mensualidad_aux_pp;
                                    END IF;
                                    LET dd_SaldoFinal_pp = dd_SaldoFinal_pp + dd_Mensualidad_aux_pp;
                                END FOREACH;
                                LET dPagoMensual = dd_Mensualidad_pp;
								-- CALCULA EL PAGO POR PLAZO
                                    --LET dPagoPorPlazo = dPagoMensual * sNumPagos;
                                LET dPagoPorPlazo = dd_SaldoFinal_pp;
								-- CALCULA EL INTERES E IVA A PLAZO MAXIMO
								LET dInterIvaPlazoMax = dPagoPorPlazo - dMontoDiferir;
    							--LET dTotalPagar = pMonto + dInterIvaPlazoMax;
                                LET dTotalPagar = dd_SaldoFinal_pp;
								-- VALIDA SI LA PROYECCION ES DE TIPO CONSULTA

								IF cCodRet = '00000' AND pTipo = 1 THEN
                                    --	IF dCsg_linea_disp < (dMontoDiferir + dInterIvaPlazoMax) THEN
                                    IF dCsg_linea_disp < (dInterIvaPlazoMax) THEN
                                        LET cCodRet = '06433';
										LET cMensajeRet = 'EL CLIENTE NO ES VIABLE PARA DIFERIR ';
									END IF
									LET dTotalPagar = 0;
									LET sNumPagos = 0;
									LET dPagoMensual = 0;
									LET dInterIvaPlazoMax = 0;
								-- VALIDA SI LA PROYECCION ES PARA RETORNAR EL DESGLOSE
                                ELIF cCodRet = '00000' AND pTipo = 2 THEN
                                    -- VALIDA QUE SI TRAE EL FOLIO DEL MOVIMIENTO QUE SE RECIBE CUANDO SE MANDA A LLAMAR EL PROCESO DESDE EL PROCESO NOCTURNO
									IF NVL(pFolioMovto,"") <> "" THEN
                                        -- OBTIENE EL MONTO DE LOS INTERESES RETENIDOS DE LA PROMOCION POR MEDIO DEL FOLIO DEL MOVTO
                                        SELECT SUM(monto_actual + monto_int_iva)
										  INTO dMontoPromo
										  FROM  "informix".sd_promocion_credito  
										  WHERE status = 0 AND fecha = dtFechaHoy AND num_credito = pNumCredito AND num_promo = pNumPromocion AND folio_movto = pFolioMovto;
                                        LET dMontoPromo = NVL(dMontoPromo,0.0);
                                    END IF;
								    -- IF (dCsg_linea_disp + dMontoPromo) < (dMontoDiferir + dInterIvaPlazoMax) THEN
                                    IF  dCsg_linea_disp < 0 THEN
										LET cCodRet = '07433';
										LET cMensajeRet = 'EL CLIENTE NO ES VIABLE PARA DIFERIR ';
										--LET dTotalPagar = 0;
										--LET sNumPagos = 0;
										--LET dPagoMensual = 0;
										--LET dInterIvaPlazoMax = 0;
									END IF;
                                -- VALIDA SI LA PROYECCION ES PARA GUARDAR EL DESGLOSE EN TABLA
								ELIF cCodRet = '00000' AND pTipo = 3 THEN
                                    --IF dCsg_linea_disp < (dMontoDiferir + dInterIvaPlazoMax) THEN
                                    IF dCsg_linea_disp < dInterIvaPlazoMax THEN
										LET cCodRet = '08433';
										LET cMensajeRet = 'EL CLIENTE NO ES VIABLE PARA DIFERIR ';
										LET dTotalPagar = 0;
										LET sNumPagos = 0;
										LET dPagoMensual = 0;
										LET dInterIvaPlazoMax = 0;
									ELSE
                                        --- PROCESO GENERICO PARA GENERAR UN FOLIO
										--EXECUTE PROCEDURE bdicheq:"informix".sp_generafolionomina(pEjecutivo)
										--INTO cCodRetGF,cFolioSucGF;
										LET cCodRetGF = '000000';
										SELECT pEjecutivo || substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,1,2)
											 ||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,4,2)
											 ||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,7,2)
											 ||lpad(bdicheq:sp_random(),2,'0')
										INTO cFolioSucGF 
										FROM sysmaster:sysshmvals;
											-------
											-- Valida folio no exista y lo recalcula si existe
											LET sCountExists = 0;  
											SELECT COUNT(folio_suc) INTO sCountExists FROM bdicred:"informix".sd_promocion_credito 
											 WHERE empresa = '001' AND folio_suc = cFolioSucGF;
											IF sCountExists > 0 THEN
												SELECT pEjecutivo || substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,1,2)
													||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,4,2)
													||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,7,2)
													||lpad(bdicheq:sp_random(),2,'0'), sysmaster:yieldn( 1 )
												  INTO cFolioSucGF, sYield FROM sysmaster:sysshmvals;
											END IF;
											-------
										
										IF cCodRetGF::INTEGER <> 0 THEN
                                            LET cCodRet = '00447';
											LET cMensajeRet = 'OCURRIO UN ERROR EN EL PROCESO QUE GENERA EL FOLIO';
											LET dTotalPagar = 0;
											LET sNumPagos = 0;
											LET dPagoMensual = 0;
											LET dInterIvaPlazoMax = 0;
										ELSE
                                            LET cFolioPromo = cFolioSucGF;
											-- GUARDA LOS DATOS DE LA PROMOCION
											INSERT INTO "informix".sd_promocion_credito
											   (empresa,sistema,num_promo,fecha,ejecutivo,num_cte,num_credito,num_tarjeta,plazo,folio_suc,monto_actual,monto_int_iva,mensualidad,status,nombre_promo,sucursal,num_sol_prestamo,num_pro_prestamo,folio_movto)
											    VALUES ('001','06',pNumPromocion,dtFechaHoy,pEjecutivo,vcNumCte, pNumCredito,pNumTarjeta,pPlazo,cFolioSucGF,pMonto,dInterIvaPlazoMax,dPagoMensual,0,vcNomPromocion,pSucursal,'','6900',pFolioMovto);
											-- REALIZA EL RETENIDO POR EL MONTO DE LOS INTERESES E IVA PARA EVITAR EL SOBREGIRO
											INSERT INTO "informix".sd_maeretenido
											   (empresa,num_credito,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,estatus,referencia,sucursal,dias_ori)
											   VALUES('001',pNumCredito,cFolioSucGF,dtFechaHoy,CURRENT HOUR TO FRACTION(3),'6837',0,dInterIvaPlazoMax,pEjecutivo,'R',cFolioSucGF||' RET. CREDISOLUCIONES',pSucursal,0);
											-- ACTUALIZA EL SALDO RETENIDO EN EL MAESTRO DE SALDOS
											UPDATE "informix".sd_maesdos
											   SET sdo_retenido = sdo_retenido + dInterIvaPlazoMax
											 WHERE num_credito = pNumCredito
											   AND empresa = '001';
											-- GENERAMOS EL MOVIMIENTO DEL RETENIDO DE LOS INTERESES
											EXECUTE PROCEDURE "informix".genmov_tc('001',pNumCredito,vProducto,dtFechaHoy,dInterIvaPlazoMax,cFolioSucGF,pSucursal,vdivisa,'6837','','RET. de INT. e Iva CS',v_tipocambio,0,pEjecutivo,vsucorig,'','')
											INTO cCodRetGenMov, cMsjeGenMov;
                                        END IF;
									END IF;
								END IF;
							END IF;
                        ----PROMOCION 3
						-- VALIDA SI SE TRATA DE  PROMOCION DE SALDO TDC
                        ELIF pNumPromocion in (3, 6 ,9) THEN
                            -- OBTIENE EL MONTO DE LO QUE DEBE EL CLIENTE SIN EL SALDO RETENIDO
                            SELECT NVL(monto_int_iva,0)
                              INTO vPromoRetSdo2
                              FROM "informix".sd_promocion_credito
                             WHERE empresa = '001'
                               AND num_credito = pNumCredito
                               AND num_promo in (3, 6, 9)
                               AND status = 0;

                            -- LET dMontoDiferir = dCsg_tot_liquidacion - dCsg_sdo_retenido;
							--LET dMontoDiferir = dCsg_tot_liquidacion;
                            LET dMontoDiferir = dCsg_cap_vig;
							--> VALIDA QUE SALDOS CUENTE CON SALDO MAYOR O IGUAL AL  MINÍMO PERMITIDO
							IF  dMontoDiferir < dValorMinDiferir THEN
                                LET cCodRet = '09433';
								LET cMensajeRet = 'EL CLIENTE NO ES VIABLE PARA DIFERIR ';
                            ELSE
                                -- CALCULA EL FACTOR INTERES IVA
								  --LET dFactorInteresIva = POW((1 + dTasaAnualIva/12), sNumPagos);
								  -- CALCULA EL PAGO MENSUAL
								  --LET dPagoMensual = dMontoDiferir * (((dTasaAnualIva/12)*dFactorInteresIva) / (dFactorInteresIva - 1));

                                -- MAHR Se modifica el calculo del pago mensual por el llamado al sp: sp_proyecta_prest_credisol
                                LET i_Cont = 0;
                                LET dd_SaldoFinal_pp = 0;
                                LET pPlazo = pPlazo;
                                IF v_bandesp=1 THEN
                                    LET v_NumCredito=pNumCredito;
                                END IF;
                                FOREACH
                                    EXECUTE PROCEDURE bdicred:"informix".sp_proyecta_prest_credisol(pMonto,pPlazo::INTEGER,0,'6900',pSucursal,1,0,v_NumCredito,null,1,pNumPromocion::INTEGER) INTO
                                    c_CodigoRet_pp, i_Periodo_pp, d_FechaCouta_pp, dd_SaldoInicial_pp, dd_Mensualidad_aux_pp, dd_Intereses_pp, dd_IvaInteres_pp, 
                                    dd_Capital_pp, dd_SaldoFinal_aux_pp, s_DiasPeriodo_pp, d_FechaAper_pp, c_NumMesesPago_pp

                                    IF c_CodigoRet_pp != '000000' THEN
                                        LET cMensajeRet = 'ERROR AL EJECUTAR sp_proyecta_prest_credisol';
                                        RETURN c_CodigoRet_pp, TRIM(cMensajeRet), NVL(dTotalPagar,0), NVL(sNumPagos,0), NVL(dPagoMensual,0), NVL(dInterIvaPlazoMax,0), NVL(dSaldoTDC,0), TRIM(cFolioPromo);
                                    END IF;

                                    LET i_Cont = i_Cont + 1;
                                    IF i_Cont = 1 THEN
                                        LET dd_Mensualidad_pp = dd_Mensualidad_aux_pp;
                                    END IF;
                                    LET dd_SaldoFinal_pp = dd_SaldoFinal_pp + dd_Mensualidad_aux_pp;
                                END FOREACH;
                                ---LET dPagoMensual = ROUND((dMontoDiferir *30.5* dTasaAnualIva/12)/ (30 * (1 - POW((1 + dTasaAnualIva/12),-sNumPagos))), 0);
                                LET dPagoMensual = dd_Mensualidad_pp;
								-- CALCULA EL PAGO POR PLAZO
                                   --LET dPagoPorPlazo = dPagoMensual * sNumPagos;
                                LET dPagoPorPlazo = dd_SaldoFinal_pp;
								-- CALCULA EL INTERES E IVA A PLAZO MAXIMO
								LET dInterIvaPlazoMax = dPagoPorPlazo - dMontoDiferir;
								--LET dTotalPagar = dMontoDiferir + dInterIvaPlazoMax;
                                LET dTotalPagar = dd_SaldoFinal_pp;

								-- VALIDA SI LA PROYECCION ES DE TIPO CONSULTA
								IF cCodRet = '00000' AND pTipo = 1 THEN

								--	IF (dMontoDiferir = 0) OR (dCsg_linea_disp < (dMontoDiferir + dInterIvaPlazoMax)) THEN
                                    IF ((dMontoDiferir = 0) OR (dCsg_linea_disp < (dInterIvaPlazoMax))) THEN
										LET cCodRet = '10433';
										LET cMensajeRet = 'EL CLIENTE NO ES VIABLE PARA DIFERIR ';
									END IF;
									LET dTotalPagar = 0;
									LET sNumPagos = 0;
									LET dPagoMensual = 0;
									LET dInterIvaPlazoMax = 0;
								-- VALIDA SI LA PROYECCION ES PARA RETORNAR EL DESGLOSE
                                ELIF cCodRet = '00000' AND pTipo = 2 THEN
                                    -- VALIDA QUE SI TRAE EL FOLIO DEL MOVIMIENTO QUE SE RECIBE CUANDO SE MANDA A LLAMAR EL PROCESO DESDE EL PROCESO NOCTURNO
									IF NVL(pFolioMovto,"") <> "" THEN
                                        -- OBTIENE EL MONTO DE LOS INTERESES RETENIDOS DE LA PROMOCION POR MEDIO DEL FOLIO DEL MOVTO
										SELECT SUM(monto_actual + monto_int_iva)
										INTO dMontoPromo
										FROM  "informix".sd_promocion_credito
										WHERE status = 0 AND fecha = dtFechaHoy AND num_credito = pNumCredito AND num_promo = pNumPromocion AND folio_movto = pFolioMovto;
										LET dMontoPromo = NVL(dMontoPromo,0.0);
                                    END IF;
                                    IF ((dMontoDiferir = 0) OR ((dCsg_linea_disp + vPromoRetSdo2) < (dInterIvaPlazoMax))) THEN
									-- IF (dMontoDiferir = 0) OR ((dCsg_linea_disp + dMontoPromo) < (dMontoDiferir + dInterIvaPlazoMax)) THEN
                                        LET cCodRet = '11433';
										LET cMensajeRet = 'EL CLIENTE NO ES VIABLE PARA DIFERIR ';
										--LET dTotalPagar = 0;
										--LET sNumPagos = 0;
										--LET dPagoMensual = 0;
										--LET dInterIvaPlazoMax = 0;
									END IF;
                                    IF pNumPromocion=9 AND pFolioMovto<>"" THEN
                                        IF pMonto <> dCsg_cap_vig THEN
                                            LET cCodRet = '13433';
                                            LET cMensajeRet = 'EL MONTO DE LA CREDISOLUCION ES DIFERENTE AL SALDO INSOLUTO';
                                            LET dTotalPagar = 0;
                                            LET sNumPagos = 0;
                                            LET dPagoMensual = 0;
                                            LET dInterIvaPlazoMax = 0;
                                        END IF  
                                    END IF; 
								-- VALIDA SI LA PROYECCION ES PARA GUARDAR EL DESGLOSE EN TABLA
								ELIF cCodRet = '00000' AND pTipo = 3 THEN
                                    --	IF (dMontoDiferir = 0) OR (dCsg_linea_disp < (dMontoDiferir + dInterIvaPlazoMax)) THEN
                                    IF ((dMontoDiferir = 0) OR (dCsg_linea_disp < (dInterIvaPlazoMax))) THEN
										LET cCodRet = '12433';
										LET cMensajeRet = 'EL CLIENTE NO ES VIABLE PARA DIFERIR ';
										LET dTotalPagar = 0;
										LET sNumPagos = 0;
										LET dPagoMensual = 0;
										LET dInterIvaPlazoMax = 0;
                                    ELSE
                                        --- PROCESO GENERICO PARA GENERAR UN FOLIO
										--EXECUTE PROCEDURE bdicheq:"informix".sp_generafolionomina(pEjecutivo)
										--INTO cCodRetGF,cFolioSucGF;
										LET cCodRetGF = '000000';
										SELECT pEjecutivo || substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,1,2)
											 ||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,4,2)
											 ||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,7,2)
											 ||lpad(bdicheq:sp_random(),2,'0')
										INTO cFolioSucGF 
										FROM sysmaster:sysshmvals;										
											-------
											-- Valida folio no exista y lo recalcula si existe
											LET sCountExists = 0;  
											SELECT COUNT(folio_suc) INTO sCountExists FROM bdicred:"informix".sd_promocion_credito 
											 WHERE empresa = '001' AND folio_suc = cFolioSucGF;
											IF sCountExists > 0 THEN
												SELECT pEjecutivo || substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,1,2)
													||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,4,2)
													||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,7,2)
													||lpad(bdicheq:sp_random(),2,'0'), sysmaster:yieldn( 1 )
												  INTO cFolioSucGF, sYield FROM sysmaster:sysshmvals;
											END IF;
											-------										
										
										IF cCodRetGF::INTEGER <> 0 THEN
											LET cCodRet = '00447';
											LET cMensajeRet = 'OCURRIO UN ERROR EN EL PROCESO QUE GENERA EL FOLIO';
											LET dTotalPagar = 0;
											LET sNumPagos = 0;
											LET dPagoMensual = 0;
											LET dInterIvaPlazoMax = 0;
											ELSE
											LET cFolioPromo = cFolioSucGF;
											-- GUARDA LOS DATOS DE LA PROMOCION
											INSERT INTO "informix".sd_promocion_credito
											   (empresa,sistema,num_promo,fecha,ejecutivo,num_cte,num_credito,num_tarjeta,plazo,folio_suc,monto_actual,monto_int_iva,mensualidad,status,nombre_promo,sucursal,num_sol_prestamo,num_pro_prestamo,folio_movto)
											   VALUES ('001','06',pNumPromocion,dtFechaHoy,pEjecutivo,vcNumCte, pNumCredito,pNumTarjeta,pPlazo,cFolioSucGF,pMonto,dInterIvaPlazoMax,dPagoMensual,0,vcNomPromocion,pSucursal,'','6900',cFolioSucGF);
											-- REALIZA EL RETENIDO POR EL MONTO DE LOS INTERESES E IVA PARA EVITAR EL SOBREGIRO
											INSERT INTO "informix".sd_maeretenido
											   (empresa,num_credito,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,estatus,referencia,sucursal,dias_ori)
											   VALUES('001',pNumCredito,cFolioSucGF,dtFechaHoy,CURRENT HOUR TO FRACTION(3),'6837',0,dInterIvaPlazoMax,pEjecutivo,'R',cFolioSucGF || ' RET. CREDISOLUCIONES',pSucursal,0);
											-- ACTUALIZA EL SALDO RETENIDO EN EL MAESTRO DE SALDOS
											UPDATE "informix".sd_maesdos
											   SET sdo_retenido = sdo_retenido + dInterIvaPlazoMax
											 WHERE num_credito = pNumCredito
											   AND empresa = '001';
											-- GENERAMOS EL MOVIMIENTO DEL RETENIDO DE LOS INTERESES
											EXECUTE PROCEDURE "informix".genmov_tc('001',pNumCredito,vProducto,dtFechaHoy,dInterIvaPlazoMax,cFolioSucGF,pSucursal,vdivisa,'6837','','RET. de INT. e Iva CS',v_tipocambio,0,pEjecutivo,vsucorig,'','')
											   INTO cCodRetGenMov, cMsjeGenMov;
                                        END IF;	-- Termina --> PROCESO GENERICO PARA GENERAR UN FOLIO
									END IF; -- Termina --> VALIDA SI LA PROYECCION ES PARA GUARDAR EL DESGLOSE EN TABLA
								END IF;  -- Termina --> VALIDA SI LA PROYECCION ES DE TIPO CONSULTA
							END IF; -- Termina --> VALIDA QUE SALDOS CUENTE CON SALDO MAYOR O IGUAL AL MINÍMO PERMITIDO
						END IF; -- Termina --> VALIDA SI SE TRATA DE PROMOCION DE EFECTIVO
					END IF;
				END IF;
			END IF;
		END IF;
	END IF;

    IF cCodRet <> '00000' THEN
        INSERT INTO "informix".sd_bitacora_promocion VALUES('001',pNumCredito,'sp_proyecta_promo',dtFechaHoy,CURRENT,pTipo,pNumPromocion,cCodRet);
    END IF;

	RETURN cCodRet, TRIM(cMensajeRet), NVL(dTotalPagar,0), NVL(sNumPagos,0), NVL(dPagoMensual,0), NVL(dInterIvaPlazoMax,0), NVL(dSaldoTDC,0), TRIM(cFolioPromo);

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para obtener el desglose de información de saldos del credito y validar si es viable el cliente',
'AUTOR: Mohamed Carreón ',
'FECHA DE CREACION: 27 de Enero del 2012',
'DESCRIPCION MODIFICACION: Se cambia el proceso para que devuelva el folio de la promoción para credi-compras y credi-saldos, ya lo hacia con credi-efectivo.',
'MODIFICO: Mohamed Carreón',
'VERSION: 20120606.0906',
'BD: bdicred',
'DESCRIPCION: Se agrega validación para corroborar que saldos cuente con saldo mayor o igual al  minímo permitido',
'MODIFICO: Josué R. Zazueta Acosta',
'VERSION: 20120711.1110',
'BD: bdicred',
'DESCRIPCION: Se cambia la validacion para tomar la maxima secuencia de la tabla sd_precal_credsol segun el tipo de promocion elegida por el usuario.',
'MODIFICO: Mario Gamaliel Olivo Urias',
'VERSION: 20141021.0930',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_rasura_moratorios_condonacion(e_fcuota DATE)
                                                            --eIntVdo MONEY(18,2),
															--eIvaIntVdo MONEY(18,2))
   RETURNING CHAR(5);

   DEFINE CodRet              CHAR(5);
   DEFINE CodRetResp          CHAR(6);
   DEFINE Mensaje             CHAR(80);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE nRows               SMALLINT;

   DEFINE GLOBAL g_Empresa      CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_NumCredito   CHAR(20)    DEFAULT ' ';
   DEFINE GLOBAL g_NumProducto  CHAR(4)     DEFAULT ' ';
   --DEFINE GLOBAL g_Remanente    MONEY(14,2) DEFAULT 0;
   --DEFINE GLOBAL g_Remanente_cq MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL vIndProceso    CHAR(1)     DEFAULT ' '; --RQM 09 459    
   DEFINE g_Fecha        DATE;
   DEFINE GLOBAL g_Sucursal     CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_Divisa       CHAR(2)     DEFAULT ' ';
--   DEFINE GLOBAL g_TRansacc     CHAR(4)     DEFAULT ' ';
--   DEFINE GLOBAL g_CodigoFun    CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_Folio        CHAR(16)    DEFAULT ' ';
--   DEFINE GLOBAL g_TpPago       SMALLINT    DEFAULT 0;
--   DEFINE GLOBAL g_MontoFinanciado MONEY(14,2) DEFAULT 0;

   --DEFINE GLOBAL g_Moratorio    MONEY(14,2) DEFAULT 0;
   DEFINE g_Moratorio    MONEY(14,2);
--   DEFINE GLOBAL g_IntMoraCob   MONEY(14,2) DEFAULT 0;
--   DEFINE GLOBAL g_ManejaLinea  CHAR(1)     DEFAULT ' ';
--   DEFINE GLOBAL g_SdoMoratorio MONEY(14,2) DEFAULT 0;
   DEFINE dSdoMoraOrdi          MONEY(14,2);
   DEFINE dSdoMoraCope          MONEY(14,2);

   DEFINE vPerContMora          CHAR(1);
   DEFINE vProviMoraOrdi        LIKE sd_detmora.provi_mora_ordi;
   DEFINE vProviMoraCope        LIKE sd_detmora.provi_mora_cope;
   DEFINE vSdoMoraOrdi          LIKE sd_detmora.sdo_mora_ordi;
   DEFINE vSdoMoraCope          LIKE sd_detmora.sdo_mora_cope;
   DEFINE vMontoMora            LIKE sd_detmora.sdo_acum_mes_mora;
   DEFINE vCodigoRef            SMALLINT;
   
   DEFINE vFechaCuota            LIKE sd_amortiza_credito.fecha_cuota;
   DEFINE vCuotaRec              LIKE sd_pagocapit.cuota_rec;
   DEFINE vIvadebe               LIKE sd_amortiza_credito.iva_debe;
   DEFINE vIvaPagado             LIKE sd_amortiza_credito.iva_pagado;
   DEFINE vIvaAdeudo             LIKE sd_amortiza_credito.iva_debe;
   DEFINE vIvaStatus             LIKE sd_amortiza_credito.iva_status;
   DEFINE vMoraIvaDebe           LIKE sd_amortiza_credito.mora_iva_debe;
   DEFINE vMoraIvaPagado         LIKE sd_amortiza_credito.mora_iva_pagado;
   DEFINE vMoraIvaAdeudo         LIKE sd_amortiza_credito.mora_iva_debe;
   DEFINE vMoraIvaStatus         LIKE sd_amortiza_credito.mora_iva_status;
   DEFINE vIvaBase		         DECIMAL(9,6);
   DEFINE GLOBAL g_IvaCte	     DECIMAL(9,6) DEFAULT 0;
   DEFINE GLOBAL csg_int_vdo	 MONEY(18,2) DEFAULT 0.00; --RQM 09 459
--   DEFINE GLOBAL csg_int_moratorios		MONEY(18,2) DEFAULT 0.00; --RQM 09 459
   DEFINE GLOBAL csg_iva_int_vdo		MONEY(18,2) DEFAULT 0.00; --RQM 09 459
--   DEFINE GLOBAL csg_iva_int_moratorios	MONEY(18,2) DEFAULT 0.00; --RQM 09 459	
   DEFINE GLOBAL g_MoraIva          MONEY(14,2) DEFAULT 0;	
   DEFINE vMoraIvaTran   DECIMAL(18,2);
   DEFINE vMoraTran      DECIMAL(18,2);
   DEFINE g_TotalTransaccMontoIva   DECIMAL(18,2);
   DEFINE g_TotalTransaccMonto      DECIMAL(18,2);
      
	ON EXCEPTION SET sql_err, isam_err, error_info
		SET DEBUG FILE TO "CobraMoratorios.err";
		TRACE sql_err||" * "||isam_err||" * "||error_info;
		LET CodRet = sql_err;
		RETURN CodRet;
	END EXCEPTION;

   --SET DEBUG FILE TO "/home/tmp/MireyaR/cobramoratorios.out";
   --TRACE ON;
   
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	SELECT valor
	INTO vPerContMora
	FROM "informix".sd_param
	WHERE empresa = g_Empresa
	AND cod_param = '17';

	LET CodRet      = "000";
	LET CodRetResp  = "000";
	--LET vCodigoRef  = 1;
	LET vMontoMora  = 0;
	LET g_Moratorio = 0;
	--LET g_Remanente_cq = g_Remanente_cq;
	LET dSdoMoraOrdi = 0; 
	LET dSdoMoraCope = 0;
	LET vMoraIvaDebe = 0;
	LET vMoraIvaTran = 0;
	LET vMoraTran = 0;	
	LET g_Fecha = e_fcuota;
	LET g_TotalTransaccMontoIva = 0;
	LET g_TotalTransaccMonto = 0;
	--LET vMoraIvaDebe = 0;

	-- *************************************
	-- Se realiza respaldo del credito     *
	-- *************************************
	IF g_NumProducto IN ('6001','8100') THEN
		CALL "informix".sp_respaldacredito_quitacondonacion('R') RETURNING CodRetResp;
		IF (CodRetResp <> "000") THEN RETURN CodRetResp;
		ELSE  LET CodRetResp = "000";  END IF;		
	ELIF g_NumProducto IN ('6300','7600','7700','6800','6011') THEN
		CALL "informix".sp_respaldacredito_quitacondonacion('P') RETURNING CodRetResp;
		IF (CodRetResp <> "000") THEN RETURN CodRetResp;
		ELSE  LET CodRetResp = "000";  END IF;		
	END IF;
	
	-- *************************************
	-- Calcula Iva de Intereses Moratorios *
	-- *************************************
	FOREACH
		SELECT fecha_cuota, mora_provi_ordi + mora_provi_cope
		INTO vFechaCuota, vMoraIvaDebe
		FROM "informix".sd_amortiza_credito
		WHERE num_credito = g_NumCredito
		AND empresa =  g_empresa
		AND capital_status IN ("2","7","6")
		AND (mora_provi_ordi + mora_provi_cope) > 0
		ORDER BY 1

		LET vMoraIvaDebe = vMoraIvaDebe * g_IvaCte;
		--LET vMoraIvaTran = vMoraIvaTran + vMoraIvaDebe; --Para guardar el total del iva moratorio
		
		UPDATE "informix".sd_amortiza_credito
		SET mora_sdo_ordi = mora_sdo_ordi + mora_provi_ordi,
		mora_sdo_cope = mora_sdo_cope + mora_provi_cope,
		mora_provi_cope = 0,
		mora_provi_ordi = 0,
		mora_iva_debe = mora_iva_debe + vMoraIvaDebe
		WHERE num_credito = g_NumCredito
		AND empresa =  g_empresa
		AND fecha_cuota = vFechaCuota;
	END FOREACH
	
	UPDATE "informix".sd_maesdos SET sdo_contab_mora = 0,
	sdo_moratorio = sdo_moratorio + sdo_contab_mora 
	WHERE num_credito = g_NumCredito AND empresa =  g_empresa;
	
	FOREACH
		SELECT fecha_cuota, (mora_iva_debe - mora_iva_pagado)
		INTO vFechaCuota, vMoraIvaDebe
		FROM "informix".sd_amortiza_credito a
		WHERE a.empresa   = g_empresa  AND a.num_credito = g_NumCredito
		AND capital_status IN ("2","7","6")  AND (mora_iva_debe - mora_iva_pagado) > 0
		ORDER BY fecha_cuota
		
		LET vMoraIvaTran = vMoraIvaTran + vMoraIvaDebe; --Para guardar el total del iva moratorio
		--IF (g_Remanente_cq > 0) THEN
			/*IF g_Remanente_cq >= vMoraIvaDebe then
				--LET g_Remanente_cq    = g_Remanente_cq - vMoraIvaDebe;
			ELSE
				--LET vMoraIvaDebe = g_Remanente_cq;
				LET g_Remanente_cq    = 0;
			END IF;*/

			UPDATE "informix".sd_amortiza_credito
			SET mora_iva_pagado     = mora_iva_pagado + vMoraIvaDebe,
			mora_iva_fecha_pago = g_fecha
			WHERE empresa     = g_empresa
			and   num_credito = g_NumCredito
			and   fecha_cuota = vFechaCuota;

			LET g_MoraIva = g_MoraIva + vMoraIvaDebe;
		--END IF;	
	END FOREACH	
	
	--**Movimientos Contables IVA INTERES MORATORIO **--
	--SELECT indicador_proceso FROM bdicred:"informix".sd_bitacora_quitacondonacion WHERE num_credito = g_NumCredito;
	/*IF vIndProceso = 'Q' THEN  --Quita
		CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vCodigoref,'136', g_Fecha, vMoraIvaTran, g_Folio, g_Sucursal, g_Divisa, '8390') 
		RETURNING CodRet, Mensaje;		
		IF (CodRet <> "00000") THEN RETURN CodRet;
		ELSE  LET Codret = "000";  END IF;	
	ELIF vIndProceso = 'C' THEN*/ --Condonacion
	--**Movimientos Contables IVA INTERES MORATORIO **--
	IF g_NumProducto = '6001' THEN --Condonacion
		LET vCodigoRef  = 2;
		--LET g_TotalTransaccMontoIva = vMoraIvaTran + eIvaIntVdo; 
		CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vCodigoref,'111', g_Fecha, vMoraIvaTran, g_Folio,	g_Sucursal, g_Divisa, '8379') 
		RETURNING CodRet, Mensaje;
		IF (CodRet <> "00000") THEN RETURN CodRet;
		ELSE  LET Codret = "000";  END IF;
	ELIF g_NumProducto = '8100' THEN --Condonacion
		LET vCodigoRef  = 5;
		--LET g_TotalTransaccMontoIva = vMoraIvaTran + eIvaIntVdo; 
		CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vCodigoref,'111', g_Fecha, vMoraIvaTran, g_Folio,	g_Sucursal, g_Divisa, '8382') 
		RETURNING CodRet, Mensaje;
		IF (CodRet <> "00000") THEN RETURN CodRet;
		ELSE  LET Codret = "000";  END IF;	
	END IF;
	
	-----------------------------------------------------
    --Para Rasurar Intereses Moratorios - Condonaciones y Quitas
	-----------------------------------------------------
	FOREACH
		SELECT fecha_cuota, mora_sdo_ordi - mora_sdo_ordi_pag, 
		mora_sdo_cope - mora_sdo_cope_pag
		INTO vFechaCuota, vSdoMoraOrdi, vSdoMoraCope
		FROM "informix".sd_amortiza_credito
		WHERE empresa = g_Empresa
		AND num_credito = g_NumCredito
		AND capital_status in ('2','7','6')
		AND (mora_sdo_ordi - mora_sdo_ordi_pag) + 
		(mora_sdo_cope - mora_sdo_cope_pag) > 0
		ORDER BY 1

		LET dSdoMoraOrdi = vSdoMoraOrdi;
		LET dSdoMoraCope = vSdoMoraCope;
		LET vMoraTran    = vMoraTran + vSdoMoraOrdi + vSdoMoraCope;
		--IF vIndProceso = 'C' THEN LET g_Remanente_cq = vSdoMoraCope; END IF;
		
		--IF(g_Remanente_cq > 0) THEN
			--IF(g_Remanente_cq >= vSdoMoraCope) THEN
				--LET g_Remanente_cq   = g_Remanente_cq - vSdoMoraCope;
				--LET vMontoMora    = vMontoMora + vSdoMoraCope;
			--ELSE
				--LET vSdoMoraCope  = g_Remanente_cq;
				--LET vMontoMora    = vMontoMora + g_Remanente_cq;
				--LET g_Remanente_cq   = 0;
			--END IF;
			--IF(g_Remanente_cq >= vSdoMoraOrdi) THEN
				--LET g_Remanente_cq   = g_Remanente_cq - vSdoMoraOrdi;
				--LET vMontoMora    = vMontoMora + vSdoMoraOrdi;
			--ELSE
				--LET vSdoMoraOrdi  = g_Remanente_cq;
				--LET vMontoMora    = vMontoMora + g_Remanente_cq;
				--LET g_Remanente_cq   = 0;
			--END IF;

			UPDATE "informix".sd_amortiza_credito
			SET  mora_sdo_ordi_pag = mora_sdo_ordi_pag + vSdoMoraOrdi,
			mora_sdo_cope_pag = mora_sdo_cope_pag + vSdoMoraCope
			WHERE empresa = g_Empresa
			AND num_credito = g_NumCredito
			AND fecha_cuota = vFechaCuota;
			
			LET g_Moratorio = g_Moratorio + vMontoMora;
			--LET g_Moratorio  = 0;
			LET vSdoMoraOrdi = 0;
			LET vSdoMoraCope = 0;
			
		--END IF;		
	END FOREACH;

	-- Actualiza sd_maesdos
	LET g_Moratorio = g_Moratorio;
	
	UPDATE "informix".sd_maesdos
	--SET	sdo_moratorio = sdo_moratorio - g_Moratorio
	SET	sdo_moratorio = 0
	WHERE empresa = g_Empresa
	AND num_credito = g_NumCredito;

	--LET g_Remanente_cq = NVL(dSdoMoraOrdi,0) + NVL(dSdoMoraCope,0) + NVL(vMoraIvaDebe,0);
	
	--**Movimientos Contables INTERES MORATORIO**--
	/*IF vIndProceso = 'Q' THEN  --Quita
		CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vCodigoref,'135', g_Fecha, vMoraTran, g_Folio, g_Sucursal, g_Divisa, '8389') 
		RETURNING CodRet, Mensaje;
		IF (CodRet <> "00000") THEN RETURN CodRet;
		ELSE  LET Codret = "000";  END IF;		
	ELIF vIndProceso = 'C' THEN */ --Condonacion
	IF g_NumProducto = '6001' THEN --Condonacion
		LET vCodigoRef  = 1;
		--LET g_TotalTransaccMonto = vMoraTran + eIntVdo; 
    	CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vCodigoref,'111', g_Fecha, vMoraTran, g_Folio, g_Sucursal, g_Divisa, '8378') 
		RETURNING CodRet, Mensaje;
		IF (CodRet <> "000") THEN RETURN CodRet;
		ELSE  LET Codret = "000";  END IF;		
	ELIF g_NumProducto = '8100' THEN --Condonacion
		LET vCodigoRef  = 4;
		--LET g_TotalTransaccMonto = vMoraTran + eIntVdo; 
    	CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vCodigoref,'111', g_Fecha, vMoraTran, g_Folio, g_Sucursal, g_Divisa, '8381') 
		RETURNING CodRet, Mensaje;
		IF (CodRet <> "000") THEN RETURN CodRet;
		ELSE  LET Codret = "000";  END IF;		
	
	END IF;
	--LET g_IntMoraCob = g_IntMoraCob + g_Moratorio;
	LET g_Moratorio = 0;
	--LET g_Remanente_cq = 0;
	
	-----------------------------------------------------
    --Para Reverso Intereses Vencidos - Condonaciones y Quitas
	-----------------------------------------------------	
	--Pago Interes Vencido		
	/*LET mRemanente_cq = e_IvaInt + e_Int;
	CALL "informix".cobraintvencido_quitas(e_Fecha,e_IvaInt,e_Int,mRemanente_cq) RETURNING CodRet;
	IF CodRet <> "000" THEN
		SELECT descripcion INTO Mensaje
		FROM bdinteg:"informix".si_codret
		WHERE sistema = g_sistema
		 AND codigo_retorno = CodRet;
		RETURN CodRet;				 
	END IF;
	
	--RETURN CodRet;
	
	--**Movimientos Contables IVA INTERES MORATORIO **--
	LET vCodigoref = 2;
	LET g_TRansacc = '8386';
	CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vCodigoref,g_CodigoFun, e_Fecha, mRemanente_cq, g_Folio, g_Sucursal, g_Divisa, g_TRansacc) 
	RETURNING CodRet, Mensaje;
	IF (CodRet <> "00000") THEN RETURN CodRet;
	ELSE  LET Codret = "000";  END IF;	*/
	
    --LET g_IntMoraCob = g_IntMoraCob + g_Moratorio;
	LET g_Moratorio = 0;
	--LET g_Remanente_cq = 0;

--RETURN CodRet;

END PROCEDURE
DOCUMENT
'Sub Procedimiento para el cobro de intereses moratorios, ',
' es llamada por Principal',
'AUTOR : Raul Mendoza D nes',
'FECHA : 17/Octubre/2003',
'CTE   : CACSI',
'BD    : BDICRED',
'MODIFICACION: Se contemplan las transacciones 7795 y 7796 para condonacion de intereses moratorios para la TDC.',
'AUTOR : Mireya Gpe Reyes Vargas',
'FECHA : 3/enero/2014',
'FOLIO: 1395 - Condonacion de intereses para TDC,PP y CREDINOMINA .',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_rasura_moratorios_quitas(e_fcuota DATE, g_Remanente_cq MONEY(14,2))
   RETURNING CHAR(5);

   DEFINE CodRet              CHAR(5);
   DEFINE Mensaje             CHAR(80);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE nRows               SMALLINT;

   DEFINE GLOBAL g_Empresa      CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_NumCredito   CHAR(20)    DEFAULT ' ';
   DEFINE GLOBAL g_NumProducto  CHAR(4)     DEFAULT ' ';
   --DEFINE GLOBAL g_Remanente    MONEY(14,2) DEFAULT 0;
   --DEFINE GLOBAL g_Remanente_cq MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL vIndProceso    CHAR(1)     DEFAULT ' '; --RQM 09 459    
   DEFINE GLOBAL g_Fecha        DATE        DEFAULT ' ';
   DEFINE GLOBAL g_Sucursal     CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_Divisa       CHAR(2)     DEFAULT ' ';
   DEFINE GLOBAL g_TRansacc     CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_CodigoFun    CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_Folio        CHAR(16)    DEFAULT ' ';
   DEFINE GLOBAL g_TpPago       SMALLINT    DEFAULT 0;
   DEFINE GLOBAL g_MontoFinanciado MONEY(14,2) DEFAULT 0;

   DEFINE GLOBAL g_Moratorio    MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_IntMoraCob   MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_ManejaLinea  CHAR(1)     DEFAULT ' ';
   DEFINE GLOBAL g_SdoMoratorio MONEY(14,2) DEFAULT 0;
   DEFINE dSdoMoraOrdi          MONEY(14,2);
   DEFINE dSdoMoraCope          MONEY(14,2);

   DEFINE vPerContMora          CHAR(1);
   DEFINE vFechaCuota           DATE;
   DEFINE vProviMoraOrdi        LIKE sd_detmora.provi_mora_ordi;
   DEFINE vProviMoraCope        LIKE sd_detmora.provi_mora_cope;
   DEFINE vSdoMoraOrdi          LIKE sd_detmora.sdo_mora_ordi;
   DEFINE vSdoMoraCope          LIKE sd_detmora.sdo_mora_cope;
   DEFINE vMontoMora            LIKE sd_detmora.sdo_acum_mes_mora;
   DEFINE vCodigoRef            SMALLINT;

   DEFINE vCuotaRec              LIKE sd_pagocapit.cuota_rec;
   DEFINE vIvadebe               LIKE sd_amortiza_credito.iva_debe;
   DEFINE vIvaPagado             LIKE sd_amortiza_credito.iva_pagado;
   DEFINE vIvaAdeudo             LIKE sd_amortiza_credito.iva_debe;
   DEFINE vIvaStatus             LIKE sd_amortiza_credito.iva_status;
   DEFINE vMoraIvaDebe           LIKE sd_amortiza_credito.mora_iva_debe;
   DEFINE vMoraIvaPagado         LIKE sd_amortiza_credito.mora_iva_pagado;
   DEFINE vMoraIvaAdeudo         LIKE sd_amortiza_credito.mora_iva_debe;
   DEFINE vMoraIvaStatus         LIKE sd_amortiza_credito.mora_iva_status;
   DEFINE vIvaBase		         DECIMAL(9,6);
   DEFINE GLOBAL g_IvaCte	     DECIMAL(9,6) DEFAULT 0;
   DEFINE GLOBAL csg_int_vdo	 MONEY(18,2) DEFAULT 0.00; --RQM 09 459
   DEFINE GLOBAL csg_int_moratorios		MONEY(18,2) DEFAULT 0.00; --RQM 09 459
   DEFINE GLOBAL csg_iva_int_vdo		MONEY(18,2) DEFAULT 0.00; --RQM 09 459
   DEFINE GLOBAL csg_iva_int_moratorios	MONEY(18,2) DEFAULT 0.00; --RQM 09 459	
   DEFINE GLOBAL g_MoraIva          MONEY(14,2) DEFAULT 0;	
   DEFINE vMoraIvaTran   DECIMAL(18,2);
   DEFINE vMoraTran      DECIMAL(18,2);   
   
	ON EXCEPTION SET sql_err, isam_err, error_info
		SET DEBUG FILE TO "CobraMoratorios.err";
		TRACE sql_err||" * "||isam_err||" * "||error_info;
		LET CodRet = sql_err;
		RETURN CodRet;
	END EXCEPTION;

   --SET DEBUG FILE TO "/home/tmp/MireyaR/cobramoratorios.out";
   --TRACE ON;
   
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	SELECT valor
	INTO vPerContMora
	FROM "informix".sd_param
	WHERE empresa = g_Empresa
	AND cod_param = '17';

	LET CodRet      = "000";
	LET vCodigoRef  = 1;
	LET vMontoMora  = 0;
	LET g_Moratorio = 0;
	LET g_Remanente_cq = g_Remanente_cq;
	LET vMoraIvaTran = 0;
	LET vMoraTran = 0;

	-- *************************************
	-- Calcula Iva de Intereses Moratorios *
	-- *************************************
	FOREACH
		SELECT fecha_cuota, mora_provi_ordi + mora_provi_cope
		INTO vFechaCuota, vMoraIvaDebe
		FROM "informix".sd_amortiza_credito
		WHERE num_credito = g_NumCredito
		AND empresa =  g_empresa
		AND capital_status IN ("2","7","6")
		AND (mora_provi_ordi + mora_provi_cope) > 0
		ORDER BY 1

		LET vMoraIvaDebe = vMoraIvaDebe * g_IvaCte;
		
		UPDATE "informix".sd_amortiza_credito
		SET mora_sdo_ordi = mora_sdo_ordi + mora_provi_ordi,
		mora_sdo_cope = mora_sdo_cope + mora_provi_cope,
		mora_provi_cope = 0,
		mora_provi_ordi = 0,
		mora_iva_debe = mora_iva_debe + vMoraIvaDebe
		WHERE num_credito = g_NumCredito
		AND empresa =  g_empresa
		AND fecha_cuota = vFechaCuota;
	END FOREACH
	
	UPDATE "informix".sd_maesdos SET sdo_contab_mora = 0,
	sdo_moratorio = sdo_moratorio + sdo_contab_mora 
	WHERE num_credito = g_NumCredito AND empresa =  g_empresa;	

	FOREACH
		SELECT fecha_cuota, (mora_iva_debe - mora_iva_pagado)
		INTO vFechaCuota, vMoraIvaDebe
		FROM "informix".sd_amortiza_credito a
		WHERE a.empresa   = g_empresa  AND a.num_credito = g_NumCredito
		AND capital_status IN ("2","7","6")  AND (mora_iva_debe - mora_iva_pagado) > 0
		ORDER BY fecha_cuota
		
		LET vMoraIvaTran = vMoraIvaTran + vMoraIvaDebe; --Para guardar el total del iva moratorio
		IF (g_Remanente_cq > 0) THEN
			IF g_Remanente_cq >= vMoraIvaDebe then
				LET g_Remanente_cq    = g_Remanente_cq - vMoraIvaDebe;
			ELSE
				LET vMoraIvaDebe = g_Remanente_cq;
				LET g_Remanente_cq    = 0;
			END IF;

			UPDATE "informix".sd_amortiza_credito
			SET mora_iva_pagado     = mora_iva_pagado + vMoraIvaDebe,
			mora_iva_fecha_pago = e_fcuota
			WHERE empresa     = g_empresa
			and   num_credito = g_NumCredito
			and   fecha_cuota = vFechaCuota;

			LET g_MoraIva = g_MoraIva + vMoraIvaDebe;
		END IF;	
	END FOREACH	
	
	--**Movimientos Contables IVA INTERES MORATORIO **--
	/*CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vCodigoref,'111', e_fcuota, vMoraIvaTran, g_Folio, g_Sucursal, g_Divisa, '8386') 
	RETURNING CodRet, Mensaje;
	IF (CodRet <> "00000") THEN RETURN CodRet;
	ELSE  LET Codret = "000";  END IF;*/	
	
	-----------------------------------------------------
    --Para Rasurar Intereses Moratorios - Condonaciones y Quitas
	-----------------------------------------------------
	FOREACH
		SELECT fecha_cuota, mora_sdo_ordi - mora_sdo_ordi_pag, 
		mora_sdo_cope - mora_sdo_cope_pag
		INTO vFechaCuota, vSdoMoraOrdi, vSdoMoraCope
		FROM "informix".sd_amortiza_credito
		WHERE empresa = g_Empresa
		AND num_credito = g_NumCredito
		AND capital_status in ('2','7','6')
		AND (mora_sdo_ordi - mora_sdo_ordi_pag) + 
		(mora_sdo_cope - mora_sdo_cope_pag) > 0
		ORDER BY 1

		LET dSdoMoraOrdi = vSdoMoraOrdi;
		LET dSdoMoraCope = vSdoMoraCope;
		LET vMoraTran    = vMoraTran + vSdoMoraOrdi + vSdoMoraCope;	

		IF(g_Remanente_cq > 0) THEN
			/*IF(g_Remanente_cq >= vSdoMoraCope) THEN
				LET g_Remanente_cq   = g_Remanente_cq - vSdoMoraCope;
				LET vMontoMora    = vMontoMora + vSdoMoraCope;
			ELSE
				LET vSdoMoraCope  = g_Remanente_cq;
				LET vMontoMora    = vMontoMora + g_Remanente_cq;
				LET g_Remanente_cq   = 0;
			END IF;
			IF(g_Remanente_cq >= vSdoMoraOrdi) THEN
				LET g_Remanente_cq   = g_Remanente_cq - vSdoMoraOrdi;
				LET vMontoMora    = vMontoMora + vSdoMoraOrdi;
			ELSE
				LET vSdoMoraOrdi  = g_Remanente_cq;
				LET vMontoMora    = vMontoMora + g_Remanente_cq;
				LET g_Remanente_cq   = 0;
			END IF;*/


			UPDATE "informix".sd_amortiza_credito
			SET  mora_sdo_ordi_pag = mora_sdo_ordi_pag + vSdoMoraOrdi,
			mora_sdo_cope_pag = mora_sdo_cope_pag + vSdoMoraCope
			WHERE empresa = g_Empresa
			AND num_credito = g_NumCredito
			AND fecha_cuota = vFechaCuota;
			
			LET g_Moratorio = g_Moratorio + vMontoMora;
			--LET g_Moratorio  = 0;
			LET vSdoMoraOrdi = 0;
			LET vSdoMoraCope = 0;
		END IF;
	END FOREACH;
	
	-- Actualiza sd_maesdos
	LET g_Moratorio = g_Moratorio;
	
	UPDATE "informix".sd_maesdos
	SET sdo_moratorio = sdo_moratorio - g_Moratorio
	WHERE empresa = g_Empresa
	AND num_credito = g_NumCredito;
	
	--**Movimientos Contables Condonacion Quitas **--
	/*CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vCodigoref,'111', e_fcuota, vMoraTran, g_Folio, g_Sucursal, g_Divisa, '8385') 
	RETURNING CodRet, Mensaje;
	IF (CodRet <> "00000") THEN RETURN CodRet;
	ELSE  LET Codret = "000";  END IF;*/

	--LET g_IntMoraCob = g_IntMoraCob + g_Moratorio;
	LET g_Moratorio = 0;
	
RETURN CodRet;

END PROCEDURE
DOCUMENT
'Sub Procedimiento para el rasurado de intereses moratorios  para Quitas, ',
' es llamada por Principal',
'AUTOR : Raul Mendoza D nes',
'FECHA : 17/Octubre/2003',
'CTE   : CACSI',
'BD    : BDICRED',
'MODIFICACION: Se contemplan las transacciones 7795 y 7796 para condonacion de intereses moratorios para la TDC.',
'AUTOR : Mireya Gpe Reyes Vargas',
'FECHA : 3/enero/2014',
'FOLIO: 1395 - Condonacion de intereses para TDC,PP y CREDINOMINA .',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_saldos_ap_tdc(pEmpresa  CHAR (3),pNumcte CHAR (20))
  RETURNING CHAR (5), -- Codigo de retorno
            CHAR(40), -- Nombre producto
            CHAR(20), -- Numero credito
            CHAR(20), -- Numero tarjeta
            DECIMAL (14,2), -- 1 = Saldo al Cierre
            DECIMAL (14,2), -- 2 = Pago para no generar intereses
            DECIMAL (14,2), -- 3 = pago minimo al corte
            DECIMAL (14,2); -- 5 = Saldo actual TDC

 -- DEFINICION DE VARIABLES --
DEFINE sSqlErr SMALLINT;
DEFINE cCodRet CHAR(5);
DEFINE dSaldoCierre     DECIMAL (14,2);
DEFINE dPagonoInteres   DECIMAL (14,2);
DEFINE dMinimoCorte     DECIMAL (14,2);
DEFINE dSaldoActual     DECIMAL (14,2);
DEFINE nNumeroCredito   char(20);
DEFINE nNumeroTarjeta   char(20);
DEFINE cNombreProducto  char(40);
DEFINE cNumProducto     char(04);
DEFINE nContador        smallint;


LET sSqlErr = 0;
LET cCodRet = '00000';

LET dSaldoCierre    = 0;
LET dPagonoInteres  = 0;
LET dMinimoCorte    = 0;
LET dSaldoActual    = 0;
LET nNumeroCredito  = '';
LET nNumeroTarjeta  = '';
LET cNombreProducto = '';
LET cNumProducto    = '';
LET nContador       = 0;


BEGIN

    ON EXCEPTION SET sSqlErr
        LET cCodRet = sSqlErr;
        RETURN cCodRet, cNombreProducto, nNumeroCredito, nNumeroTarjeta, dSaldoCierre, dPagonoInteres, dMinimoCorte, dSaldoActual;
    END EXCEPTION;
	
	SET LOCK MODE TO wait 3;
	SET ISOLATION TO dirty READ;
	
	
    FOREACH 
        select num_credito, num_producto
          into nNumeroCredito, cNumProducto
          from bdicred:"informix".sd_maecred
         where numcte = pNumcte
           and status_cred in ('AA','BA','BT','E1','E2','E3')
           and num_producto in ('6001','6600','8100','7000','8500')

        let nContador = nContador + 1;

        select num_tarjeta
          into nNumeroTarjeta
          from bdicred:"informix".sd_tarjeta
         where num_credito = nNumeroCredito
           and tipo_tarjeta = 'T'
           and secuencia = (select max(secuencia) from bdicred:"informix".sd_tarjeta where num_credito = nNumeroCredito and tipo_tarjeta = 'T');

        select nombre_prod
          into cNombreProducto
          from bdicred:"informix".sd_definicion
         where num_producto = cNumProducto;

         let cNombreProducto = trim(cNombreProducto);

        execute procedure bdicred:sp_consultasaldocortemin(pEmpresa,nNumeroCredito,1) into cCodRet, dSaldoCierre;    --                1 = Saldo al Cierre
        execute procedure bdicred:sp_consultasaldocortemin(pEmpresa,nNumeroCredito,2) into cCodRet, dPagonoInteres;  --                2 = Pago para no generar intereses
        execute procedure bdicred:sp_consultasaldocortemin(pEmpresa,nNumeroCredito,3) into cCodRet, dMinimoCorte;    --                3 = pago minimo al corte
        execute procedure bdicred:sp_consultasaldocortemin(pEmpresa,nNumeroCredito,5) into cCodRet, dSaldoActual;    --                5 = Saldo actual TDC 

        RETURN cCodRet, cNombreProducto, nNumeroCredito, nNumeroTarjeta, dSaldoCierre, dPagonoInteres, dMinimoCorte, dSaldoActual WITH RESUME;
    END FOREACH;

    if (nContador = 0) then
       let cCodRet = '00001'; -- No cuenta con credito activos o asociados
       RETURN cCodRet, cNombreProducto, nNumeroCredito, nNumeroTarjeta, dSaldoCierre, dPagonoInteres, dMinimoCorte, dSaldoActual WITH RESUME;
    end if;

END;
END PROCEDURE;