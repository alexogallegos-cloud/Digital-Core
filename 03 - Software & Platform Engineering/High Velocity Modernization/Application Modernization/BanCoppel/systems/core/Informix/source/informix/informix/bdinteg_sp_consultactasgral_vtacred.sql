CREATE PROCEDURE "informix".sp_consultactasgral_vtacred(pEmpresa CHAR(3), 
									 pNumCte CHAR(20), 
									 pCuenta CHAR(20), 
									 pTarjeta CHAR(20),
									 pTpo SMALLINT,
									 pLimit INTEGER,
									 pEjecucion INTEGER)	
--DATOS A REGRESAR---
RETURNING CHAR(5)   AS Retorno, 
          CHAR(104) AS Nombre,
		  CHAR(20)  AS Cuenta, 
		  CHAR(20)  AS Tarjeta,
		  CHAR(4)   AS Sucursal,   
		  CHAR(40)  AS Producto, 
		  DATE      AS Fech_Alta, 
		  DATE 		AS Fech_Venc,     
		  CHAR(30)  AS Estatus,
		  CHAR(20)  AS NumCte,
		  INTEGER   AS Tipo,
		  INTEGER   AS iSkip,
		  INTEGER   AS iEjecucion,
		  DATE      AS FechaCancela,
		  CHAR(8)   AS PromotorCancela,
		  CHAR(40)  AS MotivoCancela,
		  CHAR(22)  AS FolioCancela;

		  
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
    DEFINE cProducto    	 CHAR(40);
    DEFINE cCuenta      	 CHAR(20);
    DEFINE cEstatus     	 CHAR(30);
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
	
	
	DEFINE iIdUnidadProd	INTEGER;
	DEFINE dFecha_hoy		DATE;
	DEFINE dFecha_reporte	DATE;
	DEFINE cIdOrigen		CHAR(2);
	DEFINE cNumProducto		CHAR(4);
	DEFINE cDesPVta			CHAR(100);
	DEFINE cDesVendido		CHAR(100);
	
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
	
	
	LET iIdUnidadProd	=0;
	LET dFecha_hoy		= DATE(1);
	LET dFecha_reporte	= DATE(1);
	LET cIdOrigen		= '';
	LET cNumProducto	= '';
	LET cDesPVta		= '';
	LET cDesVendido		= '';
		
	--SET DEBUG FILE TO '/respaldosbd/Martha/sp_consultactasgral.out';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	-- INICIO DEL PROCEDIMIENTO
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,'','','','','','','','','','','','','','','','';
			END IF;
		END EXCEPTION;		  

		IF NVL(pEmpresa,'') = '' THEN
			LET cCod_ret = '00001';
			LET iTipo = 20; 
			RETURN cCod_ret,cCompleto,cCuenta,cTarjeta,cSucursal,cProducto,dFecha_alta,dFecha_venc,cEstatus,cNumCte,iTipo,iSkip,iEjecucion,dFec_cancelo,cPromotor_cancelo,cDescMot_cancelo,cFolio_cancelo;	
		ELIF NVL(pNumCte,'') = '' AND (NVL(pCuenta,'') = '' AND NVL(pTarjeta,'') = '') THEN
			LET cCod_ret = '00001';
			LET iTipo = 20;
			RETURN cCod_ret,cCompleto,cCuenta,cTarjeta,cSucursal,cProducto,dFecha_alta,dFecha_venc,cEstatus,cNumCte,iTipo,iSkip,iEjecucion,dFec_cancelo,cPromotor_cancelo,cDescMot_cancelo,cFolio_cancelo;	
		ELIF NVL(pTpo,'') = '' THEN
			LET cCod_ret = '00001';
			LET iTipo = 20;
			RETURN cCod_ret,cCompleto,cCuenta,cTarjeta,cSucursal,cProducto,dFecha_alta,dFecha_venc,cEstatus,cNumCte,iTipo,iSkip,iEjecucion,dFec_cancelo,cPromotor_cancelo,cDescMot_cancelo,cFolio_cancelo;
		ELIF NVL(pLimit,'') = '' THEN
			LET cCod_ret = '00001';
			LET iTipo = 20;
			RETURN cCod_ret,cCompleto,cCuenta,cTarjeta,cSucursal,cProducto,dFecha_alta,dFecha_venc,cEstatus,cNumCte,iTipo,iSkip,iEjecucion,dFec_cancelo,cPromotor_cancelo,cDescMot_cancelo,cFolio_cancelo;
		ELIF NVL(pEjecucion,'') = '' THEN
			LET cCod_ret = '00001';
			LET iTipo = 20;
			RETURN cCod_ret,cCompleto,cCuenta,cTarjeta,cSucursal,cProducto,dFecha_alta,dFecha_venc,cEstatus,cNumCte,iTipo,iSkip,iEjecucion,dFec_cancelo,cPromotor_cancelo,cDescMot_cancelo,cFolio_cancelo;
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
								RETURN cCod_ret,cCompleto,cCuenta,cTarjeta,cSucursal,cProducto,dFecha_alta,dFecha_venc,cEstatus,cNumCte,iTipo,iSkip,iEjecucion,dFec_cancelo,cPromotor_cancelo,cDescMot_cancelo,cFolio_cancelo;
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
						RETURN cCod_ret,cCompleto,cCuenta,cTarjeta,cSucursal,cProducto,dFecha_alta,dFecha_venc,cEstatus,cNumCte,iTipo,iSkip,iEjecucion,dFec_cancelo,cPromotor_cancelo,cDescMot_cancelo,cFolio_cancelo;
					ELSE
						LET iSistema = 6;
					END IF;
					
				ELSE
					LET iSistema = 1;
				END IF;
				
			ELIF pNumCte <> '' THEN
				LET cNumCte = pNumCte;
			END IF;
			
			SELECT numcte,apell_paterno,apell_materno,nombre1,nombre2,razon_social
			INTO cNumCte,cPaterno,cMaterno,cNombre1,cNombre2,cRazon
			FROM bdinteg:"informix".si_cliente
			WHERE numcte = cNumCte;

			IF cNumCte IS NULL THEN
				LET cCod_ret = "00137";
				LET iTipo = 11;
				RETURN cCod_ret,cCompleto,cCuenta,cTarjeta,cSucursal,cProducto,dFecha_alta,dFecha_venc,cEstatus,cNumCte,iTipo,iSkip,iEjecucion,dFec_cancelo,cPromotor_cancelo,cDescMot_cancelo,cFolio_cancelo;
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
					FOREACH
						SELECT skip sTipo LIMIT iLimit
						mc.cuenta,sucursal,mc.producto||" "||pr.nombre,
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
						INTO cCuenta,cSucursal,cProducto,cEstatus
						FROM bdicheq:"informix".sc_maechq mc,
							 bdicheq:"informix".sc_producto pr
						WHERE num_cte = cNumCte 
						AND mc.empresa = "001"
						AND mc.cuenta = CASE WHEN iSistema <> 1 THEN mc.cuenta ELSE cCuenta END
						AND mc.producto = pr.producto 
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
						END IF;
																																						
						LET iCantReg = iCantReg + 1;
						LET iSkip = iCantReg;
						RETURN cCod_ret, NVL(cCompleto,""),NVL(cCuenta,""),NVL(cTarjeta,""),NVL(cSucursal,""),NVL(cProducto,""),NVL(dFecha_alta,DATE(1)) ,NVL(dFecha_venc, DATE(1)),NVL(cEstatus,""),NVL(cNumCte,""),iTipo,iSkip+sTipo,iEjecucion,NVL(dFec_cancelo,"01/01/1900"),NVL(cPromotor_cancelo,""),NVL(cDescMot_cancelo,""),NVL(cFolio_cancelo,"") WITH RESUME;												
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
							   cuenta,mv.sucursal,mv.cod_instrum||" "||pr.nombre,
							   mv.fecha_alta,fecha_venc,
							   NVL(DECODE(status_cta, "1","Activa","2","Cancelada"),'')
							INTO cCuenta,cSucursal,cProducto,dFecha_alta,
							   dFecha_venc,cEstatus
							FROM bdinvers:"informix".sv_maeinv mv,
							   bdinvers:"informix".sv_instrum pr
							WHERE mv.num_cte = cNumCte
							AND mv.cod_instrum = pr.cod_instrum
							AND mv.empresa = "001"
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
							RETURN cCod_ret, NVL(cCompleto,""),NVL(cCuenta,""),NVL(cTarjeta,""),NVL(cSucursal,""),NVL( cProducto,""),NVL(dFecha_alta,DATE(1)) ,NVL(dFecha_venc, DATE(1)),NVL(cEstatus,""),NVL(cNumCte,""),iTipo,iSkip+sTipo,iEjecucion,NVL(dFec_cancelo,"01/01/1900"),NVL(cPromotor_cancelo,""),NVL(cDescMot_cancelo,""),NVL(cFolio_cancelo,"") WITH RESUME;
							
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
					
					
					--Se obtiene la fecha actual
					SELECT fecha_hoy INTO dFecha_hoy FROM bdicred:"informix".sd_fechas where empresa = NVL(pEmpresa,'');
					--Se obtienen las descripciones para cuando el credito este en proceso de venta o vendido
					SELECT valor INTO cDesVendido FROM bdicred:"informix".sd_param where empresa = NVL(pEmpresa,'') AND cod_param = '170';
					SELECT valor INTO cDesPVta FROM bdicred:"informix".sd_param where empresa = NVL(pEmpresa,'') AND cod_param = '185';					
					
					IF iEjecucion in (0,1,2) THEN
						IF pNumCte <> '' OR iSistema = 6 THEN
							FOREACH
						-- *********************************************************************
						-- Extrae la informacion del Sistema de Credito
						-- *********************************************************************
							SELECT skip sTipo LIMIT iLimit
							   mc.num_credito,sucursal,mc.num_producto||" "||pr.nombre_prod,
							   fecha_apertura,fecha_vencim, tc.descripcion, mc.status_cred, mc.id_unidad_prod 
							INTO cCuenta,cSucursal,cProducto,dFecha_alta,
							   dFecha_venc,cEstatus,cStatusCred,iIdUnidadProd
							FROM bdicred:"informix".sd_maecred mc,
							   bdicred:"informix".sd_definicion pr,
							   bdicred:"informix".sd_tipocartera tc
							WHERE numcte = cNumCte 
							AND mc.num_credito = CASE WHEN iSistema <> 6 THEN mc.num_credito ELSE cCuenta END
							AND mc.num_producto = pr.num_producto
							AND mc.status_cred = tc.status_cred
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
							
							IF  TRIM(NVL(cStatusCred,'')) = 'BT' AND NVL(iIdUnidadProd,0) = 1 THEN
								IF EXISTS(SELECT MAX(fechareporte) 
								FROM bdicobranza:"informix".cb_rep_cart_quebrantar
								WHERE num_credito = TRIM(cCuenta)) THEN
									LET cEstatus = TRIM(NVL(cDesPVta,''));
								END IF;
							ELIF TRIM(NVL(cStatusCred,' ')) = 'CV' THEN
								LET cEstatus = TRIM(NVL(cDesVendido,''));
							END IF;
							
							RETURN cCod_ret,cCompleto,cCuenta,cTarjeta,cSucursal,cProducto,dFecha_alta,dFecha_venc,cEstatus,cNumCte,iTipo,iSkip+sTipo,iEjecucion,NVL(dFec_cancelo,"01/01/1900"),NVL(cPromotor_cancelo,""),NVL(cDescMot_cancelo,""),NVL(cFolio_cancelo,"") WITH RESUME;
							
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
						IF pNumCte <> '' OR iSistema = 7 THEN
							FOREACH
								SELECT skip sTipo LIMIT iLimit
								   mcd.num_credito,mcd.sucursal,mcd.num_producto||" "||df.nombre_prod,
								   mcd.fecha_apertura, mcd.fecha_vencim, tc.descripcion, mcd.status_cred, mcd.id_origen, mcd.num_producto 
								INTO cCuenta,cSucursal,cProducto,
								   dFecha_alta,dFecha_venc,cEstatus, cStatusCred, cIdOrigen, cNumProducto
								FROM bdicred:"informix".sd_maecredcrd mcd,
								   bdicred:"informix".sd_definicion df,
								   bdicred:"informix".sd_tipocartera tc
								WHERE numcte = cNumCte 
								AND mcd.num_producto = df.num_producto
								AND mcd.status_cred = tc.status_cred
								ORDER BY 1
								
							LET dFec_cancelo      = DATE(1);
							LET cPromotor_cancelo = "";
							LET cMotivo_cancelo   = "";
							LET cFolio_cancelo    = "";								
						    LET cDescMot_cancelo   = "";
							
							LET iCantReg = iCantReg + 1;
							LET iSkip = iCantReg;
							LET iEjecucion = 3;
							
							
							IF  (TRIM(NVL(cStatusCred,'')) = 'BT' OR (TRIM(NVL(cNumProducto,'')) = '6011' AND TRIM(NVL(cStatusCred,'')) = 'VP')) AND NVL(cIdOrigen,'') = '1' THEN
								IF EXISTS(SELECT MAX(fechareporte) 
								FROM bdicobranza:"informix".cb_rep_cart_quebrantar
								WHERE num_credito = TRIM(cCuenta)) THEN
									LET cEstatus = TRIM(NVL(cDesPVta,'')); 
								END IF;
							ELIF TRIM(NVL(cStatusCred,' ')) = 'CV' THEN
								LET cEstatus = TRIM(NVL(cDesVendido,''));
							END IF;
							
							RETURN cCod_ret,cCompleto,cCuenta,cTarjeta,cSucursal,cProducto,dFecha_alta,dFecha_venc,cEstatus,cNumCte,iTipo,iSkip+sTipo,iEjecucion,NVL(dFec_cancelo,"01/01/1900"),NVL(cPromotor_cancelo,""),NVL(cDescMot_cancelo,""),NVL(cFolio_cancelo,"") WITH RESUME;
							END FOREACH;
						END IF;
					END IF;
				END IF;
			END IF;
			IF iSkip = 0 THEN
				LET cCod_ret = "00127";
				LET iTipo = 11;
				RETURN cCod_ret,cCompleto,cCuenta,cTarjeta,cSucursal,cProducto,dFecha_alta,dFecha_venc,cEstatus,cNumCte,iTipo,iSkip,iEjecucion,NVL(dFec_cancelo,"01/01/1900"),NVL(cPromotor_cancelo,""),NVL(cDescMot_cancelo,""),NVL(cFolio_cancelo,"");
			END IF;
		END IF;				
	END
END PROCEDURE             
DOCUMENT
"DESCRIPCION: Reaaliza consulta de Cliente para regresar la información de sus cuentas de cheques, créditos",
"             Sistemas de Prestamo Persona, Credinomina y Reestructura, además de los datos básicos del Cliente",
"REALIZÓ: Nancy Sevilla Camacho / Martín Eduardo Miranda Miranda",
"FECHA: 23/Febrero/2012",
"MODIFICÓ:    Martha Aguirre",
"DESCRIPCIÓN: Se modifica procedimiento para que regrese 4 valores mas cuando la cuenta del sistema de cheques esté cancelada:",
"			  fecha de cancelación,promotor que canceló, motivo por el que se canceló y folio de cancelación",
"FECHA:       03/Agosto/2012",
"BD:          bdinteg",
"MODIFICÓ:    Jesus Aguilar",
"DESCRIPCIÓN: Se modifica procedimiento controlar la paginacion de forma correcta",
"FECHA:       29/Agosto/2012",
"BD:          bdinteg",
"MODIFICÓ:    Guadalupe Payan",
"DESCRIPCIÓN: Se modifica procedimiento para inicializar las variables dFec_cancelo,cPromotor_cancelo,cMotivo_cancelo,cFolio_cancelo,cDescMot_cancelo",
"			  cuando la consulta sea por numero de cliente y que el status sea diferente de cancelada.",
"FECHA DE MODIFICACION: 07/Septiembre/2012",
"MODIFICÓ:    Martha Aguirre",
"DESCRIPCIÓN: Se modifica procedimiento para regresar dFec_cancelo,cPromotor_cancelo,cMotivo_cancelo,cFolio_cancelo,cDescMot_cancelo",
"			  para las cuentas de crédito.",
"FECHA DE MODIFICACION: 17/Octubre/2012",
"BD:          bdinteg",
"MODIFICÓ:    Obed Vega",
"DESCRIPCIÓN: Se clona procedimito para integrar validaciones en los casos en que el credito se encuentre en proceso de venta o vendido",
"FECHA DE MODIFICACION: 14/Junio/2016",
"BD:          bdinteg";

CREATE PROCEDURE "informix".sp_traspasocuentas_ide(pClienteTitular CHAR(20), pClienteTraspasaCtas CHAR(20), pUsuario CHAR(8)) 
RETURNING CHAR(5), CHAR(80);
--DEFINICION DE VARIABLES
DEFINE vc_CodRet        CHAR(5);
DEFINE vi_SqlErr        INTEGER;
DEFINE vi_iSAMErr        INTEGER;
DEFINE vi_iSAMData        CHAR(80);
DEFINE vc_Mensaje       CHAR(80);
DEFINE vc_detalle_mov2   CHAR(200);
DEFINE vc_proceso       CHAR(50);
DEFINE vc_tabla         CHAR(30);
DEFINE vc_detalle_mov   CHAR(200);
DEFINE vc_numsolic        CHAR(20);
DEFINE vc_Cuenta2        CHAR(20);
DEFINE vi_secuencia     INTEGER;
DEFINE vc_AnioMes	CHAR(6);
DEFINE vc_aniomesI       CHAR(6);
DEFINE vc_aniomesF       CHAR(6);
DEFINE pCte        CHAR(20);
DEFINE vi_num_serial    INTEGER;
DEFINE iExiste     INTEGER;
DEFINE vc_statusolic    CHAR(2);
DEFINE vd_FechaSolic    DATE;
DEFINE iNumRows			INTEGER;
DEFINE vc_rfc           CHAR(13);
DEFINE vc_rfc_ori          CHAR(13);
DEFINE vc_ref_ret       CHAR(20);
DEFINE vc_tipo_cta      CHAR(1);
DEFINE vc_sucursal      CHAR(4);
DEFINE vc_num_cta       CHAR(20);
DEFINE vd_fecha_mov     DATE;
DEFINE vm_imp_tot_dep   MONEY(10,2);
DEFINE vm_imp_ide       MONEY(10,2);
DEFINE vc_user_insert   CHAR(8);
DEFINE vd_fecha_insert  DATE;
DEFINE CparamRango		CHAR(13);
DEFINE sEjercicio		SMALLINT;
DEFINE cUser_insert_ide	CHAR(8);
DEFINE dFecha_insert_ide	DATE;
DEFINE cPendiente		CHAR(1);
DEFINE cAniomes		CHAR(6);
DEFINE cCuenta_ret	CHAR(20);
DEFINE cConsecutivo  CHAR(1);
DEFINE cNumcte		CHAR(20);
DEFINE cRfc			CHAR(13);



DEFINE mImp_acumulado	MONEY;
DEFINE mImp_gravado		MONEY;
DEFINE mImp_arecaudar	MONEY;
DEFINE mImp_recaudado	MONEY;
DEFINE mImp_mesanterior MONEY;
DEFINE mImp_excedente	MONEY;
DEFINE mImp_arecaudarc	MONEY;
DEFINE mImp_recaudadoc	MONEY;
DEFINE mImp_pendiente	MONEY;
DEFINE mImp_anterior	MONEY;

--INICIALIZACION DE VARIABLES
LET vc_CodRet = "00000";
LET vi_SqlErr = 0;
LET vi_iSAMErr=0;
LET vi_secuencia = 0;
LET vi_iSAMData="";
LET vc_Mensaje = "EL PROCESO SE EFECTUO CORRECTAMENTE";
LET vc_detalle_mov2 = "";
LET vc_proceso = "FusionClientes";
LET vc_tabla = "";
LET vc_detalle_mov = "";
LET vc_numsolic = "";
LET vc_AnioMes= "";
LET vc_aniomesI="";
LET vc_aniomesF="";
LET vc_Cuenta2="";
LET pCte="";
LET vi_num_serial=0;
LET vd_fecha_mov = "";
LET iExiste=0;
LET vc_statusolic = "";
LET vd_FechaSolic = "";
LET iNumRows= 0;
LET vc_rfc="";
LET vc_rfc_ori="";
LET vc_ref_ret = "";
LET vc_tipo_cta = "";
LET vc_sucursal = "";
LET vc_num_cta = "";
LET vd_fecha_mov = "";
LET vm_imp_tot_dep = 0;
LET vm_imp_ide = 0;
LET vc_user_insert = "";
LET vd_fecha_insert = "";
LET CparamRango="";
LET sEjercicio=0;
LET cUser_insert_ide = '';
LET dFecha_insert_ide = '';
LET cPendiente = '';
LET cAniomes	= '';
LET cCuenta_ret = '';
LET cConsecutivo = '';
LET cNumcte = '';
LET cRfc = '';

LET mImp_acumulado	= 0;
LET mImp_gravado	= 0;
LET mImp_arecaudar	= 0;
LET mImp_recaudado	= 0;
LET mImp_mesanterior	= 0;
LET mImp_excedente = 0;
LET mImp_arecaudarc = 0;
LET mImp_recaudadoc = 0;
LET mImp_pendiente = 0;
LET mImp_anterior = 0;


SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

    BEGIN WORK;
    BEGIN

    ON EXCEPTION SET vi_SqlErr,vi_iSAMErr,vi_iSAMData
        IF vi_SqlErr <> 0 THEN
            LET vc_CodRet = vi_SqlErr;
            LET vc_Mensaje = "ERROR NO CONTROLADO";
            ROLLBACK WORK;
            let vc_detalle_mov2=vi_SqlErr||'|'||vi_iSAMErr||'|'||vi_iSAMData; 
            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov2, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);

            RETURN vc_CodRet, vc_Mensaje;
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "/tmp/ALAN/fusion/sp_traspasocuentas_ide.out";
    --TRACE ON;

	--SELECT  trim(valor) INTO vc_aniomesI FROM si_param where cod_param=151;
	SELECT  MIN (aniomes)  
	INTO vc_aniomesI
	FROM bdilide:sl_movefec WHERE num_cta IN (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta FROM bdicheq:sc_maechq WHERE empresa='001' AND num_cte IN (pClienteTraspasaCtas, pClienteTraspasaCtas));
	--SELECT  trim(valor) INTO vc_aniomesF FROM si_param where cod_param=152;
	SELECT  MAX (aniomes)  
	INTO vc_aniomesF
	FROM bdilide:sl_movefec WHERE num_cta IN (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta FROM bdicheq:sc_maechq WHERE empresa='001' AND num_cte IN (pClienteTraspasaCtas,pClienteTraspasaCtas));
	--LET sEjercicio=SUBSTR(vc_aniomesI,1,4);

    SELECT  {+INDEX(bdinteg:si_cliente idx_si_cliente5)} rfc INTO vc_rfc FROM si_cliente WHERE numcte = pClienteTitular;

	SELECT  {+INDEX(bdilide:sl_movefec i_102)} FIRST 1 num_cte INTO pCte FROM bdilide:sl_movefec WHERE aniomes BETWEEN vc_aniomesI AND vc_aniomesF 
	AND num_cta IN (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta FROM bdicheq:sc_maechq WHERE empresa='001' AND num_cte=pClienteTraspasaCtas);
	LET iNumRows = dbinfo("sqlca.sqlerrd2");
	IF iNumRows>0 THEN
        SET ISOLATION TO DIRTY READ;
         FOREACH         
           SELECT  {+INDEX(bdilide:sl_movefec i_102)} num_serial, rfc, ref_ret, tipo_cta, sucursal, num_cta, fecha_mov, imp_tot_dep, imp_ide, user_insert, fecha_insert,aniomes
            INTO   vi_num_serial, vc_rfc_ori, vc_ref_ret, vc_tipo_cta, vc_sucursal, vc_num_cta, vd_fecha_mov, vm_imp_tot_dep, vm_imp_ide, vc_user_insert, vd_fecha_insert,vc_AnioMes
            FROM bdilide:sl_movefec WHERE aniomes BETWEEN vc_aniomesI AND vc_aniomesF AND num_cta in (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta from bdicheq:sc_maechq where empresa='001' and num_cte=pClienteTraspasaCtas)

            LET vc_tabla = "sl_movefec";
            LET vc_detalle_mov = TRIM(vc_AnioMes)||'|'||TRIM(pClienteTraspasaCtas)||'|'||TRIM(vc_rfc_ori)||'|'||TRIM(vc_ref_ret)||'|'||TRIM(vc_num_cta)||'|'||vd_fecha_mov||'|'||vm_imp_tot_dep;
            LET vc_proceso='MOVIMIENTO IDE';   
        
            INSERT INTO bdinteg:si_fusmovefec
            SELECT  {+INDEX(bdilide:sl_movefec i_102)} * FROM bdilide:sl_movefec WHERE aniomes = vc_AnioMes AND num_cta= vc_num_cta AND num_cte = pClienteTraspasaCtas;

			
			--DELETE {+INDEX(bdilide:sl_movefec i_102)} FROM bdilide:sl_movefec WHERE aniomes = vc_AnioMes AND num_cta= vc_num_cta AND num_cte = pClienteTraspasaCtas;

            --INSERT INTO bdilide:sl_movefec(aniomes, num_cte,num_serial,rfc,ref_ret,tipo_cta,sucursal,num_cta,fecha_mov,imp_tot_dep,imp_ide,user_insert,fecha_insert)
            --VALUES (vc_AnioMes, pClienteTitular,vi_num_serial, vc_rfc, vc_ref_ret, vc_tipo_cta, vc_sucursal, vc_num_cta, vd_fecha_mov, vm_imp_tot_dep, vm_imp_ide, vc_user_insert, vd_fecha_insert);

            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);

			UPDATE {+INDEX(bdilide:sl_movefec i_102)} bdilide:sl_movefec SET num_cte=pClienteTitular,rfc=vc_rfc WHERE aniomes =vc_AnioMes AND num_cta=vc_num_cta AND num_cte=pClienteTraspasaCtas;
        END FOREACH;
    END IF;	
	
	SELECT  MIN (aniomes)  
	INTO vc_aniomesI
	FROM bdilide:sl_movefec_his WHERE num_cta IN (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta FROM bdicheq:sc_maechq WHERE empresa='001' AND num_cte IN (pClienteTraspasaCtas,pClienteTraspasaCtas));

	SELECT  MAX (aniomes)  
	INTO vc_aniomesF
	FROM bdilide:sl_movefec_his WHERE num_cta IN (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta FROM bdicheq:sc_maechq WHERE empresa='001' AND num_cte IN (pClienteTraspasaCtas,pClienteTraspasaCtas));
	
    SELECT  FIRST 1 num_cte INTO pCte FROM bdilide:sl_movefec_his WHERE aniomes BETWEEN vc_aniomesI AND vc_aniomesF 
	AND num_cta IN (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta FROM bdicheq:sc_maechq WHERE empresa='001' AND num_cte=pClienteTraspasaCtas);
	LET iNumRows = dbinfo("sqlca.sqlerrd2");
	
	IF iNumRows>0 THEN
        SET ISOLATION TO DIRTY READ;
        FOREACH         
            SELECT  {+INDEX(bdilide:sl_movefec_his i_102_his)} num_serial, rfc, ref_ret, tipo_cta, sucursal, num_cta, fecha_mov, imp_tot_dep, imp_ide, user_insert, fecha_insert,aniomes
            INTO   vi_num_serial, vc_rfc_ori, vc_ref_ret, vc_tipo_cta, vc_sucursal, vc_num_cta, vd_fecha_mov, vm_imp_tot_dep, vm_imp_ide, vc_user_insert, vd_fecha_insert,vc_AnioMes
            FROM bdilide:sl_movefec_his
            WHERE aniomes BETWEEN vc_aniomesI AND vc_aniomesF AND num_cta IN (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta FROM bdicheq:sc_maechq WHERE empresa='001' and num_cte=pClienteTraspasaCtas)

            LET vc_tabla = "sl_movefec_his";
            LET vc_detalle_mov = TRIM(vc_AnioMes)||'|'||TRIM(pClienteTraspasaCtas)||'|'||TRIM(vc_rfc_ori)||'|'||TRIM(vc_ref_ret)||'|'||TRIM(vc_num_cta)||'|'||vd_fecha_mov||'|'||vm_imp_tot_dep;
            LET vc_proceso='MOVIMIENTO IDE';           

            INSERT INTO bdinteg:si_fusmovefec_his
            SELECT  {+INDEX(bdilide:sl_movefec_his i_102_his)} * FROM bdilide:sl_movefec_his WHERE aniomes = vc_AnioMes AND num_cta= vc_num_cta AND num_cte = pClienteTraspasaCtas;

			--DELETE {+INDEX(bdilide:si_fusmovefec_his i_102_his)} FROM bdilide:sl_movefec_his WHERE aniomes = vc_AnioMes AND num_cta= vc_num_cta AND num_cte = pClienteTraspasaCtas;

            --INSERT INTO bdilide:sl_movefec_his(aniomes, num_cte,num_serial,rfc,ref_ret,tipo_cta,sucursal,num_cta,fecha_mov,imp_tot_dep,imp_ide,user_insert,fecha_insert)
            --VALUES (vc_AnioMes, pClienteTitular,vi_num_serial, vc_rfc, vc_ref_ret, vc_tipo_cta, vc_sucursal, vc_num_cta, vd_fecha_mov, vm_imp_tot_dep, vm_imp_ide, vc_user_insert, vd_fecha_insert);

            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);

			UPDATE {+INDEX(bdilide:sl_movefec_his i_102_his)} bdilide:sl_movefec_his SET num_cte=pClienteTitular,rfc=vc_rfc WHERE aniomes=vc_AnioMes AND num_cta=vc_num_cta AND num_cte=pClienteTraspasaCtas;
			
        END FOREACH;
    END IF;

	SELECT  MIN (aniomes)  
	INTO vc_aniomesI
	FROM bdilide:sl_retlide WHERE num_cte IN (pClienteTraspasaCtas,pClienteTitular) AND pendiente IS NOT NULL;

	SELECT  MAX (aniomes)  
	INTO vc_aniomesF
	FROM bdilide:sl_retlide WHERE num_cte IN (pClienteTraspasaCtas,pClienteTitular) AND pendiente IS NOT NULL;
	
	SELECT  {+INDEX(bdilide:sl_retlide idx_retcte)}  FIRST 1 num_cte INTO pCte FROM bdilide:sl_retlide WHERE aniomes BETWEEN vc_aniomesI AND vc_aniomesF AND num_cte =pClienteTraspasaCtas AND pendiente IS NOT NULL;
	
	LET iNumRows = dbinfo("sqlca.sqlerrd2");
	
	IF iNumRows>0 THEN
        SET ISOLATION TO DIRTY READ;
         FOREACH         
           SELECT   {+INDEX(bdilide:sl_retlide idx_retcte)} rfc, ref_ret,aniomes
            INTO   vc_rfc_ori, vc_ref_ret,vc_AnioMes
            FROM bdilide:sl_retlide
            WHERE aniomes BETWEEN vc_aniomesI AND vc_aniomesF AND num_cte = pClienteTraspasaCtas AND pendiente IS NOT NULL

            LET vc_tabla = "sl_retlide";
            LET vc_detalle_mov = TRIM(vc_AnioMes)||'|'||TRIM(pClienteTraspasaCtas)||'|'||TRIM(vc_rfc_ori)||'|'||TRIM(vc_ref_ret);
            LET vc_proceso='RETENCION IDE';   
			
			IF EXISTS (SELECT  {+INDEX(bdilide:sl_retlide idx_retcte)} 1 FROM bdilide:sl_retlide  WHERE num_cte = pClienteTitular AND aniomes = vc_AnioMes) THEN
				SELECT  {+INDEX(bdilide:sl_retlide idx_retcte)} user_insert, fecha_insert, pendiente
				INTO cUser_insert_ide, dFecha_insert_ide, cPendiente
				FROM bdilide:sl_retlide  WHERE num_cte = pClienteTitular AND aniomes = vc_AnioMes;
				
				INSERT INTO bdinteg:si_fusretlide
				SELECT  * FROM bdilide:sl_retlide WHERE aniomes = vc_AnioMes AND num_cte IN (pClienteTitular, pClienteTraspasaCtas) AND pendiente IS NOT NULL;
				
				SELECT  {+INDEX(bdilide:sl_retlide idx_retcte)} 
					 SUM(imp_acumulado), SUM(imp_gravado), SUM(imp_arecaudar), SUM(imp_recaudado), SUM(imp_mesanterior)
				INTO mImp_acumulado, mImp_gravado, mImp_arecaudar, mImp_recaudado, mImp_mesanterior
				FROM bdilide:sl_retlide WHERE num_cte IN (pClienteTitular, pClienteTraspasaCtas)
				AND aniomes = vc_AnioMes;
				
				UPDATE {+INDEX(bdilide:sl_retlide idx_retcte)}  bdilide:sl_retlide 
				SET imp_acumulado = mImp_acumulado, imp_gravado = mImp_gravado, imp_arecaudar = mImp_arecaudar, imp_recaudado = mImp_recaudado, imp_mesanterior = mImp_mesanterior
				WHERE rfc = vc_rfc AND num_cte = pClienteTitular AND aniomes = vc_AnioMes AND pendiente IS NOT NULL;
				
				DELETE FROM bdilide:sl_retlide
				WHERE aniomes = vc_AnioMes AND num_cte = pClienteTraspasaCtas AND  pendiente IS NOT NULL;				

			ELSE
				INSERT INTO bdinteg:si_fusretlide
				SELECT  * FROM bdilide:sl_retlide WHERE aniomes = vc_AnioMes AND num_cte = pClienteTraspasaCtas AND pendiente IS NOT NULL;
				
				UPDATE bdilide:sl_retlide SET rfc = vc_rfc,num_cte = pClienteTitular WHERE aniomes = vc_AnioMes AND num_cte = pClienteTraspasaCtas AND pendiente IS NOT NULL;
			END IF;
			
			INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);		

        END FOREACH;
    END IF;
	
	SELECT  MIN (aniomes)  
	INTO vc_aniomesI
	FROM bdilide:sl_detlide WHERE cuenta_ret IN (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta FROM bdicheq:sc_maechq WHERE empresa='001' AND num_cte IN (pClienteTraspasaCtas,pClienteTitular));

	SELECT  MAX (aniomes)  
	INTO vc_aniomesF
	FROM bdilide:sl_detlide WHERE cuenta_ret IN (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta FROM bdicheq:sc_maechq WHERE empresa='001' AND num_cte IN (pClienteTraspasaCtas,pClienteTitular));
	
	SELECT  {+INDEX(bdilide:sl_detlide i_d102)} FIRST 1 num_cte INTO pCte FROM bdilide:sl_detlide WHERE aniomes BETWEEN vc_aniomesI AND vc_aniomesF 
	AND cuenta_ret IN (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta FROM bdicheq:sc_maechq where empresa='001' AND num_cte=pClienteTraspasaCtas);
	LET iNumRows = dbinfo("sqlca.sqlerrd2");
	IF iNumRows>0 THEN
        SET ISOLATION TO DIRTY READ;
         FOREACH         
           SELECT   {+INDEX(bdilide:sl_detlide i_d102)} rfc, ref_ret,aniomes,cuenta_ret,consecutivo
            INTO   vc_rfc_ori, vc_ref_ret,vc_AnioMes,vc_num_cta,vi_num_serial
            FROM bdilide:sl_detlide WHERE aniomes BETWEEN vc_aniomesI AND vc_aniomesF AND cuenta_ret IN (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta from bdicheq:sc_maechq where empresa='001' and num_cte=pClienteTraspasaCtas)

            LET vc_tabla = "sl_detlide";
            LET vc_detalle_mov = TRIM(vc_AnioMes)||'|'||TRIM(pClienteTraspasaCtas)||'|'||TRIM(vc_rfc_ori)||'|'||TRIM(vc_ref_ret)||'|'||TRIM(vc_num_cta)||'|'||vi_num_serial;
            LET vc_proceso='DETALLE IDE';  

			IF EXISTS (SELECT  {+INDEX(bdilide:sl_detlide i_d102)} 1 FROM bdilide:sl_detlide  WHERE num_cte = pClienteTitular AND aniomes = vc_AnioMes) THEN
				SELECT  {+INDEX(bdilide:sl_detlide i_d102)} aniomes,cuenta_ret--,consecutivo
				INTO cAniomes, cCuenta_ret --cConsecutivo
				FROM bdilide:sl_detlide  WHERE num_cte = pClienteTitular AND aniomes = vc_AnioMes AND consecutivo = vi_num_serial;
				
				INSERT INTO bdinteg:si_fusdetlide
				SELECT  * FROM bdilide:sl_detlide 
				WHERE aniomes = cAniomes 
					AND cuenta_ret IN (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta FROM bdicheq:sc_maechq WHERE empresa='001' AND num_cte IN (pClienteTraspasaCtas,pClienteTitular)) AND consecutivo = vi_num_serial;
				
				SELECT  {+INDEX(bdilide:sl_detlide i_d102)} 
					 SUM(imp_recaudado)
				INTO mImp_recaudado
				FROM bdilide:sl_detlide WHERE num_cte IN (pClienteTitular, pClienteTraspasaCtas)
				AND aniomes = vc_AnioMes AND consecutivo = vi_num_serial;
				
				UPDATE {+INDEX(bdilide:sl_detlide i_d102)}  bdilide:sl_detlide 
				SET  imp_recaudado = mImp_recaudado
				WHERE rfc = vc_rfc_ori AND num_cte = pClienteTitular AND aniomes = vc_AnioMes AND consecutivo = vi_num_serial;
				
				DELETE FROM bdilide:sl_detlide 
				WHERE aniomes = vc_AnioMes AND num_cte = pClienteTraspasaCtas AND consecutivo = vi_num_serial;				
			ELSE
        
				INSERT INTO bdinteg:si_fusdetlide
				SELECT  {+INDEX(bdilide:sl_detlide i_d102)} * FROM bdilide:sl_detlide WHERE aniomes = vc_AnioMes AND cuenta_ret =vc_num_cta AND num_cte=pClienteTraspasaCtas;
			
				UPDATE {+INDEX(bdilide:sl_detlide i_d102)} bdilide:sl_detlide SET rfc = vc_rfc,num_cte = pClienteTitular WHERE aniomes = vc_AnioMes AND cuenta_ret =vc_num_cta AND num_cte=pClienteTraspasaCtas AND consecutivo = vi_num_serial;
			END IF;
			
            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);			
        END FOREACH;
    END IF;

	
	SELECT  MIN (aniomes)  
	INTO vc_aniomesI
	FROM bdilide:sl_constancias WHERE  num_cte IN (pClienteTraspasaCtas,pClienteTitular) AND tipo_cons is not null;

	SELECT  MAX (aniomes)  
	INTO vc_aniomesF
	FROM bdilide:sl_constancias WHERE  num_cte IN (pClienteTraspasaCtas,pClienteTitular) AND tipo_cons is not null;
	
	SELECT  {+INDEX(bdilide:sl_constancias 112_228)} FIRST 1 num_cte INTO pCte FROM bdilide:sl_constancias WHERE aniomes BETWEEN vc_aniomesI AND vc_aniomesF AND num_cte =pClienteTraspasaCtas AND tipo_cons is not null;
	LET iNumRows = dbinfo("sqlca.sqlerrd2");
	IF iNumRows>0 THEN
        SET ISOLATION TO DIRTY READ;
         FOREACH         
           SELECT   rfc, tipo_cons,aniomes
            INTO   vc_rfc_ori, vc_sucursal,vc_AnioMes
            FROM bdilide:sl_constancias
            WHERE aniomes BETWEEN vc_aniomesI AND vc_aniomesF AND num_cte = pClienteTraspasaCtas AND tipo_cons is not null

            LET vc_tabla = "sl_constancias";
            LET vc_detalle_mov = TRIM(vc_AnioMes)||'|'||TRIM(pClienteTraspasaCtas)||'|'||TRIM(vc_rfc_ori)||'|'||TRIM(vc_sucursal);
            LET vc_proceso='CONSTANCIAS IDE';
						
			IF EXISTS (SELECT  {+INDEX(bdilide:sl_constancias  112_228)} 1 FROM bdilide:sl_constancias  WHERE num_cte = pClienteTitular AND aniomes = vc_AnioMes) THEN
				SELECT  {+INDEX(bdilide:sl_constancias  112_228)} aniomes,num_cte,rfc
				INTO cAniomes,cNumcte,cRfc
				FROM bdilide:sl_constancias  WHERE num_cte = pClienteTitular AND aniomes = vc_AnioMes AND tipo_cons = vc_sucursal;
				
				INSERT INTO bdinteg:si_fusconstancias
				SELECT  * FROM bdilide:sl_constancias  WHERE aniomes = vc_AnioMes AND num_cte IN (pClienteTraspasaCtas,pClienteTitular) AND tipo_cons = vc_sucursal;
				
				SELECT  {+INDEX(bdilide:sl_constancias  112_228)} 
					 SUM(imp_excedente),SUM(imp_arecaudar),SUM(imp_recaudado),SUM(imp_pendiente),SUM(imp_anterior)
				INTO mImp_excedente, mImp_arecaudarc,mImp_recaudadoc,mImp_pendiente,mImp_anterior
				FROM bdilide:sl_constancias WHERE num_cte IN (pClienteTitular, pClienteTraspasaCtas)
				AND aniomes = vc_AnioMes AND tipo_cons = vc_sucursal;
				
				UPDATE {+INDEX(bdilide:sl_constancias  112_228)}  bdilide:sl_constancias 
				SET  imp_excedente = mImp_excedente, imp_arecaudar = mImp_arecaudarc,imp_recaudado = mImp_recaudadoc,imp_pendiente = mImp_pendiente,imp_anterior = mImp_anterior
				WHERE rfc = vc_rfc_ori AND num_cte = pClienteTitular AND aniomes = vc_AnioMes AND tipo_cons = vc_sucursal;
				
				DELETE FROM bdilide:sl_constancias 
				WHERE aniomes = vc_AnioMes AND num_cte = pClienteTraspasaCtas AND tipo_cons = vc_sucursal;							
			ELSE
			
				INSERT INTO bdinteg:si_fusconstancias
				SELECT  * FROM bdilide:sl_constancias WHERE aniomes = vc_AnioMes AND num_cte = pClienteTraspasaCtas AND tipo_cons is not null;

				UPDATE bdilide:sl_constancias SET rfc = vc_rfc,num_cte = pClienteTitular WHERE aniomes = vc_AnioMes AND num_cte = pClienteTraspasaCtas AND tipo_cons is not null;
			END IF;
			
			INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
			VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);		
        END FOREACH;
    END IF;

	SELECT  FIRST 1 num_cte INTO pCte FROM bdicheq:sc_retenisr WHERE empresa='001' 
	AND cuenta in (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta from bdicheq:sc_maechq where empresa='001' and num_cte=pClienteTraspasaCtas);
	LET iNumRows = dbinfo("sqlca.sqlerrd2");
	IF iNumRows>0 THEN
        SET ISOLATION TO DIRTY READ;
         FOREACH         
           --BD-- SELECT   {+INDEX(bdicheq:sc_retenisr inx_retenisr_02)}  cuenta
           SELECT   cuenta
            INTO    vc_num_cta
            FROM bdicheq:sc_retenisr WHERE empresa='001' AND cuenta in (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta from bdicheq:sc_maechq where empresa='001' and num_cte=pClienteTraspasaCtas)

            LET vc_tabla = "sc_retenisr";
            LET vc_detalle_mov = vi_num_serial||'|'||TRIM(vc_num_cta)||'|'||TRIM(pClienteTraspasaCtas);
            LET vc_proceso='RETEN ISR';   
        
            INSERT INTO bdinteg:si_fusretenisr
            SELECT  {+INDEX(bdicheq:sc_retenisr inx_retenisr_02)} * FROM bdicheq:sc_retenisr WHERE empresa='001' AND num_cte =pClienteTraspasaCtas AND cuenta=vc_num_cta; 

			INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);

			UPDATE {+INDEX(bdicheq:sc_retenisr inx_retenisr_02)} bdicheq:sc_retenisr SET num_cte = pClienteTitular WHERE empresa='001' AND num_cte = pClienteTraspasaCtas AND cuenta=vc_num_cta;

        END FOREACH;
    END IF;

   IF vc_CodRet = "00000" THEN
        COMMIT WORK;
        RETURN vc_CodRet, vc_Mensaje;
    END IF;

END;
END PROCEDURE;