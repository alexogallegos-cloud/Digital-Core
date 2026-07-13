CREATE PROCEDURE "informix".sp_cons_cteofna_web(pEmpresa CHAR(3), 
									 pNumCte CHAR(20), 
									 pCuenta CHAR(20), 
									 pTarjeta CHAR(20),
									 pTipoCuenta CHAR(8),
									 pTpo SMALLINT,
									 pLimit INTEGER,
									 pEjecucion INTEGER)
									
--DATOS A REGRESAR---
RETURNING CHAR(5)   AS Retorno, 
          CHAR(104) AS Nombre,
		  CHAR(20)  AS Cuenta, 
		  CHAR(20)  AS Tarjeta,
		  CHAR(4)   AS Sucursal,  
		  INTEGER	AS Cod_Producto, -- se agrega 
		  CHAR(40)  AS Producto, 
		  DATE      AS Fech_Alta, 
		  DATE 		AS Fech_Venc,     
		  CHAR(20)  AS Estatus,
		  CHAR(20)  AS NumCte,
		  INTEGER   AS Tipo,
		  INTEGER   AS iSkip,
		  INTEGER   AS iEjecucion,
		  DATE      AS FechaCancela,
		  CHAR(8)   AS PromotorCancela,
		  CHAR(40)  AS MotivoCancela,
		  CHAR(22)  AS FolioCancela,
		  MONEY(16,2)  AS SaldoRetenido,
		  MONEY(16,2)  AS SaldoDisponible,
		  DECIMAL(14,2)  AS Abono_mes,
		  MONEY(16,2)  AS Cargo_mes,
		  CHAR(8)	   AS Tipo_Cuenta;
		  
		  
	-- DEFINICION DE VARIABLES
	DEFINE cCod_ret      	 CHAR(5);
	DEFINE cRazon       	 CHAR(36);
    DEFINE cNumCte      	 CHAR(20);
    DEFINE cNombre1     	 CHAR(26);
	DEFINE cNombre2			 CHAR(26);
	DEFINE cMaterno			 CHAR(26);
	DEFINE cPaterno			 CHAR(26);
	DEFINE cCompleto    	 CHAR(36);
	DEFINE cSucursal    	 CHAR(4);
	DEFINE cCodigoProducto	 INTEGER; -- nuevo que se agrega
    DEFINE cProducto    	 CHAR(40);
    DEFINE cCuenta      	 CHAR(20);
    DEFINE cEstatus     	 CHAR(20);
	DEFINE cStatusCred  	 CHAR(2);
	DEFINE cTarjeta      	 CHAR(20);
	DEfine sTipo 			 SMALLINT;
	DEFINE iSqlErr      	 INTEGER;
	DEFINE iLimit 			 INTEGER;
	DEFINE iCantReg 		 INTEGER;
	DEFINE iSistema     	 INTEGER;
	DEFINE iTipo			 INTEGER;
	DEFINE iSkip			 INTEGER;
	DEFINE iEjecucion	     INTEGER;
	DEFINE dFecha_alta       DATE;
	DEFINE dFecha_venc  	 DATE;
	DEFINE dFec_cancelo 	 DATE;
	DEFINE cPromotor_cancelo CHAR (8);
	DEFINE cMotivo_cancelo 	 CHAR(3); 
	DEFINE cFolio_cancelo    CHAR(22);
	DEFINE cDescMot_cancelo  CHAR(40);
	DEFINE cSdo_disp         money(14,2);
	DEFINE cSdo_ret          money(14,2);
	DEFINE abono_mes         DECIMAL(14,2); 	-- nuevo
	DEFINE cargo_mes         DECIMAL(14,2);	-- nuevo
	DEFINE tipo_cuenta       CHAR(8);	-- nuevo
	DEFINE tipo_sistema      CHAR(8);	-- nuevo
	DEFINE v_abono           DECIMAL(14,2);  -- nuevo   
	DEFINE v_cargo           DECIMAL(14,2); -- nuevo
	DEFINE cod_ret           CHAR(5); -- nuevo
	--DEFINE aNumCred          CHAR(20); -- nuevo
	DEFINE temporal_pCuenta  CHAR(20);
	DEFINE temporal_pTarjeta CHAR(20);


	
	-- sp_consulta_saldos_general
	DEFINE cCodRet           CHAR(6);
	DEFINE cMensajeRet       CHAR(80);
	DEFINE cNumCredito       CHAR(20);
	DEFINE cCodTipCred       CHAR(2);
	DEFINE dtFechaOrigen     DATE;
	DEFINE dtFechaProxPago   DATE;
	DEFINE dPagoMinimo       DECIMAL(18,2);
	DEFINE dtFechaUltPago    DATE;
	DEFINE iPlazo            INTEGER;
	DEFINE iPagosRealizados  INTEGER;
	DEFINE dLineaOtorgada    DECIMAL(18,2);
	DEFINE dTasaInteres      DECIMAL(9,6);
	DEFINE dTasaMoratorios   DECIMAL(9,6);
	DEFINE dMontoSBC         DECIMAL(14,2);
	DEFINE dCapVig           DECIMAL(18,2);
	DEFINE dCapTrans         DECIMAL(18,2);
	DEFINE dCapVdoExig       DECIMAL(18,2);
	DEFINE dCapVdoNoExig     DECIMAL(18,2);
	DEFINE dSdoActCap        DECIMAL(18,2);
	DEFINE dIntVig           DECIMAL(18,2);
	DEFINE dIntVdo           DECIMAL(18,2);
	DEFINE dIntMoratorio     DECIMAL(18,2);
	DEFINE dIntMes           DECIMAL(18,2);
	DEFINE dSdoActInt        DECIMAL(18,2);
	DEFINE dIvaIntVig        DECIMAL(18,2);
	DEFINE dIvaIntVdo        DECIMAL(18,2);
	DEFINE dIvaIntMoratorio  DECIMAL(18,2);
	DEFINE dIvaIntMes        DECIMAL(18,2);
	DEFINE dSdoActIvaInt     DECIMAL(18,2);
	DEFINE dComPend          DECIMAL(18,2);
	DEFINE dIvaCom           DECIMAL(18,2);
	DEFINE dSdoRetenido      DECIMAL(18,2);
	DEFINE dSdoTotalLiq      DECIMAL(18,2);
	DEFINE dIntDevengado     DECIMAL(18,2);
	DEFINE dIvaIntDevengado  DECIMAL(18,2);
	DEFINE dLineaDisponible  DECIMAL(18,2);
	DEFINE dPagosVdos        DECIMAL(18,2);
	DEFINE cDescStatusCred   CHAR(60);
	DEFINE cDescBloqueoCta       CHAR(60);
	DEFINE cDescCausaBloqueoCta  CHAR(50);
	DEFINE cSitCte               CHAR(1);
	DEFINE cCausaCte             INTEGER;
	DEFINE iIdUnidadProd    	 INTEGER;
	DEFINE cCodCaract2      	 CHAR(3);
	DEFINE cDescSitEspCte        CHAR(75);
	DEFINE cSitCred              CHAR(1);
	DEFINE cCausaCred            INTEGER;
	DEFINE cDescSitEspCred       CHAR(75);
		
	-- CONS_SDOS1	
	DEFINE vcod_ret             char(5);
	DEFINE vcuenta              char(20);
	DEFINE vnum_cte             char(20);
	DEFINE vapell_pat           char(26);
	DEFINE vapell_mat           char(26);
	DEFINE vnombre1             char(26);
	DEFINE vnombre2             char(26);
	DEFINE vrazon_soc           char(60);
	DEFINE vedo_cta             char(1);
	DEFINE vsdo_disp            money(14,2);
	DEFINE vsdo_ret             money(14,2);
	DEFINE vsdo_ccc             money(14,2);
	DEFINE vsdo_disp_ccc        money(14,2);
	DEFINE vsdo_cta             money(14,2);
	DEFINE vtipo_linea          char(1);
	DEFINE vdescrip1            char(40);
	DEFINE vdescrip2            char(40);
	DEFINE vsdo_t1              money(14,2);
	DEFINE vsdo_cong            money(14,2);
	DEFINE vimp_chq_sbc         money(14,2);
	DEFINE vusubloq             char(8);
	DEFINE vfecbloq             date;
	DEFINE vnum_tarjeta         char(16);
	DEFINE vcta_clabe           char(18);
	DEFINE CodRet				CHAR(5);



	
	
	--INICIALIZACION DE VARIABLES
	LET cCod_ret     	  = "00000";
	LET cCompleto    	  = "";
	LET cRazon    	 	  = "";
	LET cNumCte    	 	  = "";
	LET cNombre1     	  = "";
	LET cNombre2     	  = "";
	LET cMaterno     	  = "";
	LET cPaterno     	  = "";
	LET cSucursal    	  = "";
	LET cCodigoProducto   = ""; -- se acaba de agregar
    LET cProducto    	  = "";
    LET cCuenta      	  = "";
	LET cEstatus     	  = "";
	LET cStatusCred	      = "";
	LET cTarjeta     	  = "";
	LET sTipo        	  = 0;
	LET iSqlErr      	  = 0;
	LET iLimit       	  = 0;
	LET iCantReg 	 	  = 0;
	LET iSistema     	  = 0;
	LET iTipo        	  = 0;
	LET iSkip        	  = 0;
	LET iEjecucion   	  = 0;
	LET dFecha_alta       = DATE(1);
	LET dFecha_venc  	  = DATE(1);
	LET dFec_cancelo  	  = DATE(1);
	LET cPromotor_cancelo = "";
	LET cMotivo_cancelo   = "";
	LET cFolio_cancelo    = "";
	LET cDescMot_cancelo  = "";
	LET cSdo_disp 		  = 0 ;
    LET cSdo_ret   		  = 0 ;
	LET abono_mes 		  = 0 ; -- nuevo
    LET cargo_mes  		  = 0 ; -- nuevo
	LET tipo_cuenta		  = ""; -- nuevo
	LET tipo_sistema	  = ""; -- nuevo
	LET cod_ret           = "00000";
	--LET cNumCredito       = "";
	
	-- sp_consulta_saldos_general
	LET cCodRet          	 = '';
	LET cMensajeRet          = '';
	LET cNumCredito          = '';
	LET cCodTipCred          = '';
	LET dtFechaOrigen         = DATE(1);
	LET dtFechaProxPago       = DATE(1);
	LET dPagoMinimo           = 0;
	LET dtFechaUltPago        = DATE(1);
	LET iPlazo                = 0;
	LET iPagosRealizados      = 0;
	LET dLineaOtorgada        = 0;
	LET dTasaInteres          = 0;
	LET dTasaMoratorios       = 0;
	LET dMontoSBC             = 0;
	LET dCapVig               = 0;
	LET dCapTrans             = 0;
	LET dCapVdoExig           = 0;
	LET dCapVdoNoExig         = 0;
	LET dSdoActCap            = 0;
	LET dIntVig               = 0;
	LET dIntVdo               = 0;
	LET dIntMoratorio         = 0;
	LET dIntMes               = 0;
	LET dSdoActInt            = 0;
	LET dIvaIntVig            = 0;
	LET dIvaIntVdo            = 0;
	LET dIvaIntMoratorio      = 0;
	LET dIvaIntMes            = 0;
	LET dSdoActIvaInt         = 0;
	LET dComPend              = 0;
	LET dIvaCom               = 0;
	LET dSdoRetenido          = 0;
	LET dSdoTotalLiq          = 0;
	LET dIvaIntDevengado      = 0;
	LET dIntDevengado         = 0;
	LET dLineaDisponible      = 0;
	LET dPagosVdos            = 0;
	LET cDescSitEspCte        = '';
	LET cSitCred              = '';
	LET cCausaCred            = 0;
	LET cDescBloqueoCta       = '';
	LET cDescCausaBloqueoCta  = '';
	LET cDescSitEspCred       = '';
	LET cSitCte               = '';
	LET cCausaCte             = 0;
	LET cDescStatusCred       = '';
	LET iIdUnidadProd         = 0;
	LET cCodCaract2           = '';
	LET cCodRet				  = '00000';


	
-- 	SP CONS_SDOS1
	let vcod_ret   = "000";
	let vcuenta    = pCuenta;
	let vnum_cte   = "";
	let vapell_pat = " ";
	let vapell_mat = " ";
	let vnombre1   = " ";
	let vnombre2   = " ";
	let vrazon_soc = " ";
	let vedo_cta   = "";
	let vsdo_disp  = 0 ;
	let vsdo_ret   = 0 ;
	let vsdo_ccc   = 0 ;
	let vsdo_disp_ccc = 0 ;
	let vsdo_cta   = 0 ;
	let vtipo_linea = " ";
	let vdescrip1 = "";
	let vdescrip2 = "";
	let vsdo_t1 =  0 ;
	let vsdo_cong  = 0 ;
	let vimp_chq_sbc = 0;
	let vusubloq = " ";
	let vfecbloq = "";
	let vnum_tarjeta = "";
	let vcta_clabe = "";
	
		
-- 	

		
	--SET DEBUG FILE TO '/informix/sp_consultactasgralcheck2.out';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	-- INICIO DEL PROCEDIMIENTO
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,'','','','','','','','','','','','','','','','','','','','','','';
			END IF;
		END EXCEPTION;		  

		IF NVL(pEmpresa,'') = '' THEN
			LET cCod_ret = '00001';
			LET iTipo = 20; 
			RETURN cCod_ret,cCompleto,cCuenta,cTarjeta,cSucursal,cCodigoProducto,cProducto,dFecha_alta,dFecha_venc,cEstatus,cNumCte,iTipo,iSkip,iEjecucion,dFec_cancelo,cPromotor_cancelo,cDescMot_cancelo,cFolio_cancelo,cSdo_disp, cSdo_ret,abono_mes,cargo_mes,tipo_cuenta;	
		ELIF NVL(pNumCte,'') = '' AND (NVL(pCuenta,'') = '' AND NVL(pTarjeta,'') = '' AND NVL(pTipoCuenta,'') = '' ) THEN
			LET cCod_ret = '00001';
			LET iTipo = 20;
			RETURN cCod_ret,cCompleto,cCuenta,cTarjeta,cSucursal,cCodigoProducto,cProducto,dFecha_alta,dFecha_venc,cEstatus,cNumCte,iTipo,iSkip,iEjecucion,dFec_cancelo,cPromotor_cancelo,cDescMot_cancelo,cFolio_cancelo,cSdo_disp, cSdo_ret,abono_mes,cargo_mes,tipo_cuenta;
		ELIF NVL(pTpo,'') = '' THEN
			LET cCod_ret = '00001';
			LET iTipo = 20;
			RETURN cCod_ret,cCompleto,cCuenta,cTarjeta,cSucursal,cCodigoProducto,cProducto,dFecha_alta,dFecha_venc,cEstatus,cNumCte,iTipo,iSkip,iEjecucion,dFec_cancelo,cPromotor_cancelo,cDescMot_cancelo,cFolio_cancelo,cSdo_disp, cSdo_ret,abono_mes,cargo_mes,tipo_cuenta;
		ELIF NVL(pLimit,'') = '' THEN
			LET cCod_ret = '00001';
			LET iTipo = 20;
			RETURN cCod_ret,cCompleto,cCuenta,cTarjeta,cSucursal,cCodigoProducto,cProducto,dFecha_alta,dFecha_venc,cEstatus,cNumCte,iTipo,iSkip,iEjecucion,dFec_cancelo,cPromotor_cancelo,cDescMot_cancelo,cFolio_cancelo,cSdo_disp, cSdo_ret,abono_mes,cargo_mes,tipo_cuenta;
		ELIF NVL(pEjecucion,'') = '' THEN
			LET cCod_ret = '00001';
			LET iTipo = 20;
	/* 		RETURN cCod_ret,cCompleto,cCuenta,cTarjeta,cSucursal,cCodigoProducto,cProducto,dFecha_alta,dFecha_venc,cEstatus,cNumCte,iTipo,iSkip,iEjecucion,dFec_cancelo,cPromotor_cancelo,cDescMot_cancelo,cFolio_cancelo,cSdo_disp, cSdo_ret,abono_mes,cargo_mes,tipo_cuenta;
	ELIF NVL(pTipoCuenta,'') = '' THEN
			LET cCod_ret = '00001';
			LET iTipo = 20; */
			RETURN cCod_ret,cCompleto,cCuenta,cTarjeta,cSucursal,cCodigoProducto,cProducto,dFecha_alta,dFecha_venc,cEstatus,cNumCte,iTipo,iSkip,iEjecucion,dFec_cancelo,cPromotor_cancelo,cDescMot_cancelo,cFolio_cancelo,cSdo_disp, cSdo_ret,abono_mes,cargo_mes,tipo_cuenta;
	ELSE
			IF pCuenta <> '' THEN
				SELECT num_cte,cuenta 
				INTO cNumCte,cCuenta 
				FROM bdicheq:"informix".sc_maechq 
				WHERE cuenta = pCuenta;
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
					SELECT numcte,num_credito 
					INTO cNumCte,cCuenta 
					FROM bdicred:"informix".sd_maecred 
					WHERE num_credito = pCuenta;
					
					IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
						SELECT num_cte,cuenta
						INTO cNumCte,cCuenta 
						FROM bdinvers:"informix".sv_maeinv 
						WHERE empresa = "001"
						AND cuenta = pCuenta
						AND secuencia IS NOT NULL;
						
						IF dbinfo("sqlca.sqlerrd2") = 0 THEN
							SELECT numcte,num_credito 
							INTO cNumCte,cCuenta 
							FROM bdicred:"informix".sd_maecredcrd 
							WHERE num_credito = pCuenta;
							
							IF dbinfo("sqlca.sqlerrd2") = 0 THEN
								LET cCod_ret = '00100';
								LET iTipo = 12;
								RETURN cCod_ret,cCompleto,cCuenta,cTarjeta,cSucursal,cCodigoProducto,cProducto,dFecha_alta,dFecha_venc,cEstatus,cNumCte,iTipo,iSkip,iEjecucion,dFec_cancelo,cPromotor_cancelo,cDescMot_cancelo,cFolio_cancelo,cSdo_disp, cSdo_ret,abono_mes,cargo_mes,tipo_cuenta;
							ELSE
								LET iSistema = 7;
							END IF;
						ELSE
							LET iSistema = 3;
						END IF;
					ELSE
						LET iSistema = 6;
					END IF;
				ELSE
					LET iSistema = 1;
				END IF;
				
			ELIF pTarjeta <> '' THEN
			
				SELECT numcte,cuenta
				INTO cNumCte,cCuenta 
				FROM bdicheq:"informix".sc_tarjeta 
				WHERE empresa = "001"
				AND num_tarjeta = pTarjeta
				AND status_tar = "A";
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
					SELECT numcte,num_credito 
					INTO cNumCte,cCuenta 
					FROM bdicred:"informix".sd_tarjeta 
					WHERE num_tarjeta = pTarjeta
					AND status_tar = "A";
					
					IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
						LET cCod_ret = '00100';
						LET iTipo = 6;
						RETURN cCod_ret,cCompleto,cCuenta,cTarjeta,cSucursal,cCodigoProducto,cProducto,dFecha_alta,dFecha_venc,cEstatus,cNumCte,iTipo,iSkip,iEjecucion,dFec_cancelo,cPromotor_cancelo,cDescMot_cancelo,cFolio_cancelo,cSdo_disp, cSdo_ret,abono_mes,cargo_mes,tipo_cuenta;
					ELSE
						LET iSistema = 6;
					END IF;
					
				ELSE
					LET iSistema = 1;
				END IF;
				
			ELIF pNumCte <> '' THEN
				LET cNumCte = pNumCte;
						
			/* ELIF pTipoCuenta <> '' THEN
				LET tipo_sistema = pTipoCuenta; */
			END IF;
			
			SELECT numcte,apell_paterno,apell_materno,nombre1,nombre2,razon_social
			INTO cNumCte,cPaterno,cMaterno,cNombre1,cNombre2,cRazon
			FROM bdinteg:"informix".si_cliente
			WHERE numcte = cNumCte;

			IF cNumCte IS NULL THEN
				LET cCod_ret = "00137";
				LET iTipo = 11;
				RETURN cCod_ret,cCompleto,cCuenta,cTarjeta,cSucursal,cCodigoProducto,cProducto,dFecha_alta,dFecha_venc,cEstatus,cNumCte,iTipo,iSkip,iEjecucion,dFec_cancelo,cPromotor_cancelo,cDescMot_cancelo,cFolio_cancelo,cSdo_disp, cSdo_ret,abono_mes,cargo_mes,tipo_cuenta;
			END IF;

			IF (cRazon IS NULL) OR (TRIM(cRazon) = "") THEN
				LET cCompleto = TRIM(cNombre1)||" "||TRIM(cNombre2)||" "||TRIM(cPaterno)||" "||TRIM(cMaterno);
			ELSE
				LET cCompleto = cRazon;
			END IF;		

			LET iLimit = pLimit;
			LET sTipo = pTpo;
			LET iEjecucion = pEjecucion;
			

				-- *****************************************************************
				-- Extrae la informacion del Sistema de Cheques
				-- *****************************************************************
			IF iEjecucion = 0 THEN
				IF pNumCte <> '' OR iSistema = 1 THEN
					IF isistema = 1 THEN
						LET iLimit = 1;
						LEt sTipo = 0;
					END IF;
					LET tipo_sistema = pTipoCuenta;
					FOREACH
						SELECT skip sTipo LIMIT iLimit
						mc.cuenta,sucursal,mc.producto,pr.nombre,ps.sistema,mc.imp_cgos_mes, mc.imp_abonos_mes,
						CASE WHEN status_cta = "1" AND marca_ret = "0" THEN
								"Sin Deposito Inicial"
							WHEN status_cta = "1" AND marca_ret = "1" THEN
								"Activa"
							WHEN status_cta = "2" THEN
								"Cancelada" 
							WHEN status_cta = "3" THEN
								"Bloqueada"
							WHEN status_cta = "4" THEN
								"Inactiva"
							WHEN status_cta = "5" THEN
								"Informada"
							WHEN status_cta = "6" THEN
								"Concentrada"
							WHEN status_cta = "7" THEN
								"Traspasada"
							END
						INTO cCuenta,cSucursal,cCodigoProducto,cProducto,tipo_cuenta,cargo_mes,abono_mes,cEstatus
						FROM bdicheq:"informix".sc_maechq mc,
							 bdicheq:"informix".sc_producto pr,
							 bdinteg:"informix".si_productos_sistemas ps
							 
						WHERE num_cte = cNumCte 
						AND mc.empresa = "001"
						AND mc.cuenta = CASE WHEN iSistema <> 1 THEN mc.cuenta ELSE cCuenta END
						AND mc.producto = pr.producto 
						AND mc.producto = ps.producto
						AND sistema = pTipoCuenta
						ORDER BY cuenta 
						
						SELECT fecha_alta,fecha_mod
						INTO dFecha_alta,dFecha_venc
						FROM bdicheq:"informix".sc_maenoc
						WHERE empresa = "001" 
						AND cuenta = cCuenta;

						SELECT num_tarjeta
						INTO  cTarjeta
						FROM bdicheq:"informix".sc_tarjeta
						WHERE numcte = cNumCte
						AND cuenta = cCuenta 
						AND secuencia = (SELECT MAX(secuencia) FROM bdicheq:"informix".sc_tarjeta WHERE numcte = cNumCte  AND cuenta = cCuenta); 
						
						IF  cEstatus = "Cancelada" THEN
							SELECT NVL(fec_cancelac,"01/01/1900"), NVL(motivo, '') 
							INTO dFec_cancelo, cMotivo_cancelo 
							FROM bdicheq:"informix".sc_maechq 
							WHERE empresa = pEmpresa 
							AND cuenta = cCuenta;
							
							SELECT descripcion 
							INTO cDescMot_cancelo
							FROM bdicheq:"informix".sc_motivocancel
							WHERE clave = cMotivo_cancelo;
		   
							SELECT NVL(promotor_cancelo,''), NVL(folio_cancelacion,'') 
							INTO cPromotor_cancelo, cFolio_cancelo 
							FROM bdicheq:"informix".sc_ctacancelada
							WHERE empresa = pEmpresa 
							AND cuenta = cCuenta 
							AND folio_cancelacion > 0;
						ELSE
							--Se inicializan las variables cuando sea el estatus diferente de cancelada.
							LET dFec_cancelo      = DATE(1);
							LET cPromotor_cancelo = "";
							LET cMotivo_cancelo   = "";
							LET cFolio_cancelo    = "";
							LET cDescMot_cancelo   = ""; 
						Call bdicheq:"informix".cons_sdos1(pEmpresa,cCuenta,cTarjeta) 
						
						RETURNING vcod_ret,vcuenta,vnum_cte,vapell_pat,vapell_mat, vnombre1,vnombre2,vrazon_soc,vedo_cta,cSdo_disp,cSdo_ret,vsdo_ccc,vsdo_disp_ccc,vsdo_cta,vtipo_linea, vdescrip1,vdescrip2,vsdo_t1,vsdo_cong,vimp_chq_sbc, vusubloq,vfecbloq,vnum_tarjeta,vcta_clabe;
							
							
						END IF;
																																						
						LET iCantReg = iCantReg + 1;
						LET iSkip = iCantReg;
						
								
					
									
						RETURN cCod_ret, NVL(cCompleto,""),NVL(cCuenta,""),NVL(cTarjeta,""),NVL(cSucursal,""),NVL(cCodigoProducto,""),NVL(cProducto,""),NVL(dFecha_alta,DATE(1)) ,NVL(dFecha_venc, DATE(1)),NVL(cEstatus,""),NVL(cNumCte,""),iTipo,iSkip+sTipo,iEjecucion,NVL(dFec_cancelo,"01/01/1900"),NVL(cPromotor_cancelo,""),NVL(cDescMot_cancelo,""),NVL(cFolio_cancelo,""), NVL(cSdo_ret,""), NVL(cSdo_disp,""),NVL(abono_mes,""),NVL(cargo_mes,""),NVL(tipo_cuenta,"") WITH RESUME;												
					END FOREACH;
				END IF;	
			END IF;
			IF iCantReg < iLimit  THEN
				LET iLimit = iLimit - iCantReg;
				LET iCantReg = 0;
				IF isistema = 3 THEN
					LET iLimit = 1;
					LEt sTipo = 0;
				END IF;
				IF iEjecucion = 0 THEN
					LET sTipo = 0;
				END IF;
				IF iEjecucion in (0,1) THEN
					IF pNumCte <> '' OR iSistema = 3 THEN
						FOREACH
						-- *********************************************************************
						-- Extrae la informacion del Sistema de Inversiones
						-- *********************************************************************
						
							SELECT skip sTipo LIMIT iLimit
							   cuenta,mv.sucursal,mv.cod_instrum,pr.nombre,
							   mv.fecha_alta,fecha_venc, mv.capital,mv.sdo_retenido,ps.sistema,
							   NVL(DECODE(status_cta, "1","Activa","2","Cancelada"),'') AS estatus
							INTO cCuenta,cSucursal,cCodigoProducto,cProducto,dFecha_alta,
							   dFecha_venc, cSdo_disp, cSdo_ret, tipo_cuenta, cEstatus
							FROM bdinvers:"informix".sv_maeinv mv,
								 bdinvers:"informix".sv_instrum pr,
	 							 bdinteg:"informix".si_productos_sistemas ps
							WHERE mv.num_cte = cNumCte
							AND mv.cod_instrum = pr.cod_instrum
							AND mv.cod_instrum = ps.producto
							AND mv.empresa = "001"
							AND mv.status_cta = "1"
							AND sistema = pTipoCuenta
							AND mv.cuenta = CASE WHEN iSistema <> 3 THEN mv.cuenta ELSE cCuenta END
							AND mv.secuencia IS NOT NULL
							
							ORDER BY mv.cuenta				

											
							LET dFec_cancelo      = DATE(1);
							LET cPromotor_cancelo = "";
							LET cMotivo_cancelo   = "";
							LET cFolio_cancelo    = "";
							LET cDescMot_cancelo   = "";
													
							LET iCantReg = iCantReg + 1;
							LET iSkip = iCantReg;
							LET iEjecucion = 1;

							RETURN cCod_ret, NVL(cCompleto,""),NVL(cCuenta,""),NVL(cTarjeta,""),NVL(cSucursal,""),NVL(cCodigoProducto,""),NVL(cProducto,""),NVL(dFecha_alta,DATE(1)) ,NVL(dFecha_venc, DATE(1)),NVL(cEstatus,""),NVL(cNumCte,""),iTipo,iSkip+sTipo,iEjecucion,NVL(dFec_cancelo,"01/01/1900"),NVL(cPromotor_cancelo,""),NVL(cDescMot_cancelo,""),NVL(cFolio_cancelo,""),NVL(cSdo_ret,""),NVL(cSdo_disp,""),NVL(abono_mes,""),NVL(cargo_mes,""),NVL(tipo_cuenta,"") WITH RESUME;
							
						END FOREACH;
					END IF;	
				END IF;
				IF iCantReg < iLimit  THEN
					LET iLimit = iLimit - iCantReg;
					LET iCantReg = 0;
					IF isistema = 6 THEN
						LET iLimit = 1;
						LEt sTipo = 0;
					END IF;
					IF iEjecucion = 1 THEN
						LET sTipo = 0;
					END IF;
					IF iEjecucion in (0,1,2) THEN
						IF pNumCte <> '' OR iSistema = 6 THEN
							FOREACH
						-- *********************************************************************
						-- Extrae la informacion del Sistema de Credito
						-- *********************************************************************

							SELECT skip sTipo LIMIT iLimit
							   mc.num_credito,sucursal,mc.num_producto,pr.nombre_prod,
							   fecha_apertura,fecha_vencim, tc.descripcion, mc.status_cred,ps.sistema
							INTO cCuenta,cSucursal,cCodigoProducto,cProducto,dFecha_alta,
							   dFecha_venc,cEstatus,cStatusCred,tipo_cuenta

							FROM bdicred:"informix".sd_maecred mc,
							   bdicred:"informix".sd_definicion pr,
							   bdicred:"informix".sd_tipocartera tc,
							   bdinteg:"informix".si_productos_sistemas ps
							WHERE numcte = cNumCte 
							AND mc.num_credito = CASE WHEN iSistema <> 6 THEN mc.num_credito ELSE cCuenta END
							AND mc.num_producto = pr.num_producto
							AND mc.num_producto = ps.producto
							AND mc.status_cred = tc.status_cred
							AND sistema = pTipoCuenta
							ORDER BY 1
							
							SELECT num_tarjeta
							INTO cTarjeta
							FROM bdicred:"informix".sd_tarjeta
							WHERE numcte = cNumCte
							AND num_credito = cCuenta
							AND secuencia = (SELECT MAX(secuencia) FROM bdicred:"informix".sd_tarjeta WHERE numcte = cNumCte AND num_credito = cCuenta);  
													
							IF  TRIM(cStatusCred) = "FF" THEN
								SELECT NVL(fecha_can,"01/01/1900"), motivo_can, ejecutivo, folio_cancelacion 
								INTO  dFec_cancelo,cMotivo_cancelo,cPromotor_cancelo, cFolio_cancelo
								FROM bdicred:"informix".sd_cred_can
								WHERE num_credito = cCuenta
								AND folio_cancelacion <> '';
																
								SELECT descripcion
								INTO cDescMot_cancelo
								FROM bdicred:"informix". sd_cat_cancred
								WHERE codigo = TRIM(cMotivo_cancelo);
							ELSE
								LET dFec_cancelo      = DATE(1);
								LET cPromotor_cancelo = "";
								LET cMotivo_cancelo   = "";
								LET cFolio_cancelo    = "";								
								LET cDescMot_cancelo   = "";
							END IF;
	
							LET iCantReg = iCantReg + 1;
							LET iSkip = iCantReg;
							LET iEjecucion = 2;
							
							
							Call bdicred:"informix".sp_consulta_saldos_general(pEmpresa,cCuenta) -- se ejecuta consulta de saldos general para obtener saldo_actual y retenido
							RETURNING cCodRet, cMensajeRet, cNumCredito, cCodTipCred, dtFechaOrigen, dtFechaProxPago, dPagoMinimo, dtFechaUltPago, iPlazo, iPagosRealizados, dLineaOtorgada, dTasaInteres, dTasaMoratorios, dMontoSBC, dCapVig, dCapTrans, dCapVdoExig, dCapVdoNoExig, dSdoActCap, dIntVig, dIntVdo, dIntMoratorio, dIntMes, dSdoActInt, dIvaIntVig,dIvaIntVdo, dIvaIntMoratorio, dIvaIntMes, dSdoActIvaInt, dComPend, dIvaCom ,cSdo_disp, cSdo_ret,dIntDevengado, dIvaIntDevengado, dLineaDisponible, dPagosVdos, cDescStatusCred, iIdUnidadProd, cDescBloqueoCta, cCodCaract2,cDescCausaBloqueoCta, cSitCte, cCausaCte, cDescSitEspCte, cSitCred, cCausaCred, cDescSitEspCred;
							
							--FOREACH
                            Call bdicred:"informix".sp_cargo_abono_mes_tdc(pEmpresa,cCuenta) --se agregan abonos y cargo del mes para TDC
							RETURNING cod_ret,v_abono,v_cargo; -- v_abono -- v_cargo	
		                       
							--END FOREACH;
							IF cod_ret = "00000" THEN
							LET abono_mes = v_abono;
							LET cargo_mes = v_cargo;
							END IF;
							
							RETURN cCod_ret,cCompleto,cCuenta,cTarjeta,cSucursal,cCodigoProducto,cProducto,dFecha_alta,dFecha_venc,cEstatus,cNumCte,iTipo,iSkip+sTipo,iEjecucion, NVL(dFec_cancelo,"01/01/1900"),NVL(cPromotor_cancelo,""),NVL(cDescMot_cancelo,""),NVL(cFolio_cancelo,""),cSdo_disp, cSdo_ret,abono_mes,cargo_mes,tipo_cuenta WITH RESUME;
							
							END FOREACH;
						END IF;	
					END IF;	
					IF iCantReg < iLimit THEN
						LET iLimit = iLimit - iCantReg;
						LET iCantReg = 0;
						LET cTarjeta = "";
						IF isistema = 7 THEN
							LET iLimit = 1;
							LEt sTipo = 0;
						END IF;
						IF iEjecucion = 2 THEN
							LET sTipo = 0;
						END IF;
						-- **********************************************************************************
						-- Extrae la informacion del Sistema de Prestamo personal, credinomina y reestructura
						-- **********************************************************************************
						LET tipo_sistema = pTipoCuenta;

						IF pNumCte <> '' OR iSistema = 7 THEN
							FOREACH
								SELECT skip sTipo LIMIT iLimit
								   mcd.num_credito,mcd.sucursal,mcd.num_producto,df.nombre_prod,
								   mcd.fecha_apertura, mcd.fecha_vencim, tc.descripcion, ps.sistema
								INTO cCuenta,cSucursal,cCodigoProducto, cProducto,
								   dFecha_alta,dFecha_venc,cEstatus,tipo_cuenta
								FROM bdicred:"informix".sd_maecredcrd mcd,
								   bdicred:"informix".sd_definicion df,
								   bdicred:"informix".sd_tipocartera tc,
								   bdinteg:"informix".si_productos_sistemas ps
								WHERE numcte = cNumCte 
								AND mcd.num_producto = df.num_producto
								AND mcd.num_producto = ps.producto
								AND mcd.status_cred = tc.status_cred
                                --AND mcd.num_credito = cCuenta
								AND sistema = pTipoCuenta
								ORDER BY 1
								
				
							

							LET dFec_cancelo      = DATE(1);
							LET cPromotor_cancelo = "";
							LET cMotivo_cancelo   = "";
							LET cFolio_cancelo    = "";								
						    LET cDescMot_cancelo   = "";
							
							LET iCantReg = iCantReg + 1;
							LET iSkip = iCantReg;
							LET iEjecucion = 3;
							
							Call bdicred:"informix".sp_consulta_saldos_general(pEmpresa,cCuenta) 
							RETURNING cCodRet, cMensajeRet, cNumCredito, cCodTipCred, dtFechaOrigen, dtFechaProxPago, dPagoMinimo, dtFechaUltPago, iPlazo, iPagosRealizados, dLineaOtorgada, dTasaInteres, dTasaMoratorios, dMontoSBC, dCapVig, dCapTrans, dCapVdoExig, dCapVdoNoExig, dSdoActCap, dIntVig, dIntVdo, dIntMoratorio, dIntMes, dSdoActInt, dIvaIntVig, dIvaIntVdo, dIvaIntMoratorio, dIvaIntMes, dSdoActIvaInt, dComPend, dIvaCom ,cSdo_disp, cSdo_ret,dIntDevengado, dIvaIntDevengado, dLineaDisponible, dPagosVdos, cDescStatusCred, iIdUnidadProd, cDescBloqueoCta, cCodCaract2,cDescCausaBloqueoCta, cSitCte, cCausaCte, cDescSitEspCte, cSitCred, cCausaCred, cDescSitEspCred;
							--LET cSdo_disp = dSdoTotalLiq;
							--LET cSdo_ret = dSdoRetenido;
							Call bdicred:"informix".sp_abonoAct_credPlazos(pEmpresa, cCuenta)					
                            RETURNING CodRet, abono_mes;	
                             LET cargo_mes = 0;
				RETURN cCod_ret,cCompleto,cCuenta,cTarjeta,cSucursal,cCodigoProducto,cProducto,dFecha_alta,dFecha_venc,cEstatus,cNumCte,iTipo,iSkip+sTipo,iEjecucion,NVL(dFec_cancelo,"01/01/1900"),NVL(cPromotor_cancelo,""),NVL(cDescMot_cancelo,""),NVL(cFolio_cancelo,""),cSdo_disp, cSdo_ret,abono_mes,cargo_mes,tipo_cuenta WITH RESUME;
							END FOREACH;
						END IF;
					END IF;
				END IF;
			END IF;
			IF iSkip = 0 THEN
				LET cCod_ret = "00127";
				LET iTipo = 11;
				
								
				RETURN cCod_ret,cCompleto,cCuenta,cTarjeta,cSucursal,cCodigoProducto,cProducto,dFecha_alta,dFecha_venc,cEstatus,cNumCte,iTipo,iSkip,iEjecucion,NVL(dFec_cancelo,"01/01/1900"),NVL(cPromotor_cancelo,""),NVL(cDescMot_cancelo,""),NVL(cFolio_cancelo,""), cSdo_disp, cSdo_ret,abono_mes,cargo_mes,tipo_cuenta;
			END IF;
		END IF;				
	END
END PROCEDURE             
DOCUMENT
"DESCRIPCION: Se agrega el saldo retenido, saldo disponible, abono_mes,cargo_mes,tipo_cuenta a la consulta general",
"REALIZÃÂÃÂ: Jorge Lara",
"FECHA: 03/Enero/2016",
"BD:          bdinteg";

CREATE PROCEDURE "informix".sp_consultacte_altaunica_filtro_web(pEmpresa CHAR(3), pNumero CHAR(16),pOpcion CHAR(1))
RETURNING CHAR(5) AS cCodRet,CHAR(26) AS cPrimerNombre,CHAR(26) AS cSegundoNombre,CHAR(26) AS cApellidoPaterno,CHAR(26) AS cApellidoMaterno,DATE AS dFechaNacimiento,CHAR(13) AS cRfc,CHAR(20) AS cClienteCoppel,CHAR(20) AS cNumCte;

--DEFINICION DE VARIABLES
DEFINE cCodRet  CHAR(5);
DEFINE cCodRet2  CHAR(5);
DEFINE cPrimerNombre  CHAR(26);
DEFINE cSegundoNombre CHAR(26);
DEFINE cApellidoPaterno CHAR(26);
DEFINE cApellidoMaterno CHAR(26);
DEFINE dFechaNacimiento DATE;
DEFINE cRfc CHAR(13);
DEFINE cClienteCoppel CHAR(20);
DEFINE iSqlErr INTEGER;
DEFINE cNumCte CHAR(20);
--INICIALIZACION DE VARIABLES 
LET cCodret	= "00000";
LET cCodret2 = "00000";
LET cPrimerNombre = "";
LET cSegundoNombre ="";
LET cApellidoPaterno ="";
LET cApellidoMaterno ="";
LET dFechaNacimiento ="";
LET cRfc ="";
LET cClienteCoppel ="";
LET iSqlErr = 0;
LET cNumCte ="";

	--SET DEBUG FILE TO '/respaldosbd/Leslie/sp_consultacte_altaunica_filtro.out';
    --TRACE ON;
	
BEGIN
    
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodret = iSqlErr;
				RETURN  cCodRet,cPrimerNombre,cSegundoNombre,cApellidoPaterno,cApellidoMaterno,dFechaNacimiento,cRfc,cClienteCoppel,cNumcte;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;
		
		IF TRIM(NVL(pEmpresa,''))='' OR TRIM(NVL(pNumero,'')) ='' OR TRIM(NVL(pOpcion,''))='' THEN
			LET cCodret = '00001'; --ParÃÂ¡metros de entrada vacÃÂ­os
		ELSE
			IF TRIM(NVL(pOpcion,''))='1' THEN
				SELECT numcte 
				INTO cNumCte
				FROM  bdicheq:"informix".sc_tarjeta
				WHERE num_tarjeta=TRIM(NVL(pNumero,''))
				AND empresa=TRIM(NVL(pEmpresa,''));
			ELIF TRIM(NVL(pOpcion,''))='2' THEN
				FOREACH
					SELECT num_cte
					INTO cNumCte
					FROM bdicheq:"informix".sc_maechq
					WHERE cuenta= TRIM(NVL(pNumero,''))
					AND empresa=TRIM(NVL(pEmpresa,''))
					UNION
					SELECT num_cte
					FROM bdinvers:"informix".sv_maeinv
					WHERE cuenta= TRIM(NVL(pNumero,''))
					AND empresa=TRIM(NVL(pEmpresa,''))
				END FOREACH;
			ELIF TRIM(NVL(pOpcion,''))='3' THEN
				LET cNumCte=pNumero;
			ELIF TRIM(NVL(pOpcion,''))='4' THEN
				SELECT numcte 
				INTO cNumCte
				FROM  bdicred:"informix".sd_tarjeta
				WHERE num_tarjeta=TRIM(NVL(pNumero,''))
				AND empresa=TRIM(NVL(pEmpresa,''));
			END IF
			
			SELECT apell_paterno,apell_materno,nombre1,nombre2,rfc
			INTO cApellidoPaterno, cApellidoMaterno, cPrimerNombre, cSegundoNombre, cRfc
			FROM bdinteg:"informix".si_cliente
			WHERE numcte=TRIM(NVL(cNumcte,''))
			AND empresa=TRIM(NVL(pEmpresa,''));
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodret	= "00002";
				LET cPrimerNombre='';
				LET cSegundoNombre='';
				LET cApellidoPaterno='';
				LET cApellidoMaterno='';
				LET dFechaNacimiento='';
				LET cRfc='';
				LET cClienteCoppel='';
			ELSE
				SELECT fecha_nac
				INTO dFechaNacimiento
				FROM bdinteg:"informix".si_ctepf
				WHERE numcte= TRIM(NVL(cNumcte,''))
				AND empresa=TRIM(NVL(pEmpresa,''));
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN
					LET cCodret	= "00002";
					LET cPrimerNombre='';
					LET cSegundoNombre='';
					LET cApellidoPaterno='';
					LET cApellidoMaterno='';
					LET dFechaNacimiento='';
					LET cRfc='';
					LET cClienteCoppel='';
				ELSE
					EXECUTE PROCEDURE bdinteg:"informix".sp_consultactesrelacionados_filtro (TRIM(NVL(pEmpresa,'')),TRIM(NVL(cNumcte,'')))
					INTO cCodret2, cClienteCoppel;
				END IF
			END IF
		END IF
		RETURN  cCodRet,cPrimerNombre,cSegundoNombre,cApellidoPaterno,cApellidoMaterno,dFechaNacimiento,cRfc,TRIM(NVL(cClienteCoppel,'')),TRIM(NVL(cNumcte,''));
END
END PROCEDURE
DOCUMENT
"DescripciÃÂ³n: Consulta datos generales del cliente",
"Autor : Leslie RendÃÂ³n",
"FECHA : 24/10/2014",
"DescripciÃÂ³n: Se modifica para agregar consulta por Tarjeta de crÃÂ©dito",
"Modifico : Leslie RendÃÂ³n",
"FECHA : 16/12/2014",
"BD    : bdinteg",
'Clon de sp sp_consultacte_altaunica, que deja en blanco el cliente coppel si empieza con 9 y es de 11 digitos',
'Autor :Obed Vega',
'FECHA : 01/Julio/2016',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_consultaorigenpoliza_club_web(
   pEmpresa CHAR(3),
   pNumCte CHAR(20),
   pTipoCte INTEGER
)
RETURNING CHAR(5) AS CodRet,
		  CHAR(1) AS OrigenPoliza;

DEFINE	cCodRet CHAR(5);
DEFINE	iSql_err INTEGER;
DEFINE cOrigenPol CHAR(1);
DEFINE sExiste SMALLINT;
DEFINE cCteBanco CHAR(20);

LET cCodRet = '00000';
LET iSql_err = 0;
LET cOrigenPol = '';
LET sExiste = 0;
LET cCteBanco = '';

BEGIN

    ON EXCEPTION SET iSql_err
        IF iSql_err <> 0 THEN
            LET cCodRet = iSql_err;
           RETURN cCodRet, cOrigenPol;
        END IF;

    END EXCEPTION;

     --SET DEBUG FILE TO "/respaldosbd/obed/sp_consultaorigenpoliza_club.out";
     --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa,'') <> '' AND NVL(pNumCte,'') <> '' AND NVL(pTipoCte,0) <> 0  THEN
		IF pTipoCte = 2 THEN
			SELECT  numcte_banco
			INTO cCteBanco
			FROM "informix".si_relacion_ctebcplcpl 
			WHERE empresa = pEmpresa
			AND cliente = pNumCte;
			
			IF NVL(cCteBanco,'') = '' THEN
				LET cOrigenPol = 'N';
			END IF;
		ELSE
			LET cCteBanco = pNumCte;
		END IF;
		IF pTipoCte = 1 OR cOrigenPol <> 'N' THEN
			SELECT  COUNT(numcte)
			INTO sExiste
			FROM "informix".si_club_proteccion
			WHERE empresa = pEmpresa
			AND numcte = cCteBanco
			AND aceptada = '1';
			IF sExiste > 0 THEN
				LET cOrigenPol = 'S';
			ELSE
				LET cOrigenPol = 'N';
			END IF;
		END IF;
		
	ELSE
		LET cCodRet = '00001'; 
	END IF;	
	RETURN cCodRet, cOrigenPol;
END;
END PROCEDURE;