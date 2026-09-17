CREATE PROCEDURE "informix".sp_consultactasgral(pEmpresa CHAR(3), 
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
		  CHAR(20)  AS Estatus,
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
							RETURN cCod_ret, NVL(cCompleto,""),NVL(cCuenta,""),NVL(cTarjeta,""),NVL(cSucursal,""),NVL(cProducto,""),NVL(dFecha_alta,DATE(1)) ,NVL(dFecha_venc, DATE(1)),NVL(cEstatus,""),NVL(cNumCte,""),iTipo,iSkip+sTipo,iEjecucion,NVL(dFec_cancelo,"01/01/1900"),NVL(cPromotor_cancelo,""),NVL(cDescMot_cancelo,""),NVL(cFolio_cancelo,"") WITH RESUME;
							
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
							   mc.num_credito,sucursal,mc.num_producto||" "||pr.nombre_prod,
							   fecha_apertura,fecha_vencim, tc.descripcion, mc.status_cred
							INTO cCuenta,cSucursal,cProducto,dFecha_alta,
							   dFecha_venc,cEstatus,cStatusCred
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
								   mcd.fecha_apertura, mcd.fecha_vencim, tc.descripcion
								INTO cCuenta,cSucursal,cProducto,
								   dFecha_alta,dFecha_venc,cEstatus
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
"BD:          bdinteg";

CREATE PROCEDURE "informix".direcciones( pEmpresa         CHAR(3),  
                                         pFuncion         CHAR(1),   
                                         pNumCte          CHAR(20), 
                                         pSecuencia       SMALLINT, 
                                         pTipoDir         CHAR(1), 
                                         pCalle           CHAR(40),
                                         pColonia         CHAR(60), 
                                         pMunicipio       CHAR(5), 
                                         pEntre_Calles    CHAR(40),
                                         pPais            CHAR(3),
                                         pEntidad         CHAR(2),
                                         pLocalidad       CHAR(3),
                                         pCodPostal       CHAR(5),
                                         pTipoTel1        CHAR(1),
                                         pTelefono1       CHAR(13),
                                         pTipoTel2        CHAR(1),
                                         pTelefono2       CHAR(13),
                                         pTipoTel3        CHAR(1),
                                         pTelefono3       CHAR(13),
                                         pExtension       CHAR(5),
                                         pEstado_Inegi    CHAR(2),
                                         pMunicipio_Inegi CHAR(3),
                                         pLocalidad_Inegi CHAR(4),
                                         pNoCiudad        SMALLINT,
                                         pNoExt           CHAR(10),
                                         pNoInt           CHAR(10),
                                         pDepto           CHAR(6),
                                         pNoCalle         INTEGER,
                                         pNoColonia       INTEGER,
                                         pPuntoCar        CHAR(1),
                                         pUniHabi         CHAR(1),
                                         pManz            SMALLINT,
                                         pPOtros          SMALLINT,
                                         pAndador         SMALLINT,
                                         pEtapa           SMALLINT,
                                         pLote            SMALLINT,
                                         pEdif            SMALLINT,
                                         pEntrada         SMALLINT,
                                         pObserva         CHAR(80),
                                         pUser_Insert     CHAR(8),
                                         pFecha_Insert    DATE,
                                         cSucursal        CHAR(4) )
RETURNING CHAR(5);

    DEFINE v_CodRet             CHAR(5);
    DEFINE v_CodRet2            CHAR(5);
    DEFINE v_CodRet3            CHAR(50);
    DEFINE v_SqlErr             INTEGER;
    DEFINE v_IsamErr            INTEGER;
    DEFINE v_DescErr            CHAR(50);
    DEFINE v_NumCte             CHAR(20);
    DEFINE pcoincide_dir        SMALLINT;
    DEFINE o_tipo_dir       	CHAR(1);
    DEFINE o_calle          	CHAR(40);
    DEFINE o_colonia        	CHAR(60);
    DEFINE o_entre_calles   	CHAR(40);
    DEFINE o_pais           	CHAR(3);
    DEFINE o_estado         	CHAR(2);
    DEFINE o_ciudad         	CHAR(3);
    DEFINE o_municipio      	CHAR(5);
    DEFINE o_cod_postal     	CHAR(5);
    DEFINE o_apart_postal   	CHAR(11);
    DEFINE o_telefono1      	CHAR(13);
    DEFINE o_telefono2      	CHAR(13);
    DEFINE o_telefono3      	CHAR(13);
    DEFINE o_extension      	CHAR(5);
    DEFINE o_estado_inegi   	CHAR(2);
    DEFINE o_municipio_inegi	CHAR(3);
    DEFINE o_localidad_inegi    CHAR(4);
    DEFINE o_numerociudad   	SMALLINT;
    DEFINE o_numeroextcalle 	CHAR(10);
    DEFINE o_numerointcalle 	CHAR(10);
    DEFINE o_departamento   	CHAR(6);
    DEFINE o_numerocalle    	INTEGER;
    DEFINE o_numerocolonia  	INTEGER;
    DEFINE o_puntocardinal  	CHAR(1);
    DEFINE o_unidadhabitac  	CHAR(1);
    DEFINE o_manzana        	SMALLINT;
    DEFINE o_otros          	SMALLINT;
    DEFINE o_andador        	SMALLINT;
    DEFINE o_etapa          	SMALLINT;
    DEFINE o_lote           	SMALLINT;
    DEFINE o_edificio       	SMALLINT;
    DEFINE o_entrada        	SMALLINT;
    DEFINE o_observaciones  	CHAR(80);
    DEFINE v_CodRetTel          CHAR(5);
    DEFINE vTipoTel             SMALLINT;
    DEFINE vCanal               SMALLINT;
    DEFINE cSituacionEsp        CHAR(1);  --- VARIABLE DE SITUACIÓN ESPECIAL
    DEFINE iCausa               INTEGER;  --- VARIABLE DE SITUACIÓN ESPECIAL

    LET v_CodRet          = '';
    LET v_CodRet2         = '';
    LET v_CodRet3         = '';
    LET v_SqlErr          = 0;
    LET v_IsamErr         = 0;
    LET v_DescErr         = '';
    LET v_NumCte          = '';
    LET pcoincide_dir     = 0;
    LET o_tipo_dir        = '';
    LET o_calle           = '';
    LET o_colonia         = '';
    LET o_entre_calles    = '';
    LET o_pais            = '';
    LET o_estado          = '';
    LET o_ciudad          = '';
    LET o_municipio       = '';
    LET o_cod_postal      = '';
    LET o_apart_postal    = '';
    LET o_telefono1       = '';
    LET o_telefono2       = '';
    LET o_telefono3       = '';
    LET o_extension       = '';
    LET o_estado_inegi    = '';
    LET o_municipio_inegi = '';
    LET o_localidad_inegi = '';
    LET o_numerociudad    = 0;
    LET o_numeroextcalle  = '';
    LET o_numerointcalle  = '';
    LET o_departamento    = '';
    LET o_numerocalle     = 0;
    LET o_numerocolonia   = 0;
    LET o_puntocardinal   = '';
    LET o_unidadhabitac   = '';
    LET o_manzana         = 0;
    LET o_otros           = 0;
    LET o_andador         = 0;
    LET o_etapa           = 0;
    LET o_lote            = 0;
    LET o_edificio        = 0;
    LET o_entrada         = 0;
    LET o_observaciones   = '';
    LET v_CodRetTel       = '';
    LET vTipoTel          = 0;
    LET vCanal            = 1;
    LET cSituacionEsp     = 'N'; --- VARIABLE DE SITUACIÓN ESPECIAL
    LET iCausa            = 0;   --- VARIABLE DE SITUACIÓN ESPECIAL

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/direcciones.out";
    --- TRACE ON;

    BEGIN

    ON EXCEPTION SET v_SqlErr, v_IsamErr, v_DescErr
        SET DEBUG FILE TO "/tmp/direcciones.err";
        TRACE ON;
        IF v_SqlErr != 0 THEN
            LET v_CodRet = v_SqlErr;
            LET v_CodRet2 = v_IsamErr;
            LET v_CodRet3 = v_DescErr;
            RETURN v_CodRet;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    LET v_CodRet = "000";
    LET pEntidad = CAST( LPAD (TRIM(pEntidad), 2 ,  "0") AS CHAR(2));

    SELECT numcte 
      INTO v_NumCte 
      FROM si_cliente
     WHERE numcte = pNumCte;
     
    IF v_NumCte IS NULL THEN
        LET v_CodRet = "104";
        RETURN v_CodRet;
    END IF

    IF pFuncion = "C" THEN
        DELETE FROM si_direcciones
         WHERE numcte = pNumCte 
           AND secuencia = pSecuencia;
           
        DELETE FROM si_direcciones_actual
         WHERE numcte = pNumCte 
           AND secuencia = pSecuencia;
           
        LET pFuncion = "A";
    END IF

    IF pFuncion = "A" THEN
        SELECT MAX(secuencia) 
          INTO pSecuencia
          FROM si_direcciones_actual
         WHERE numcte = pNumCte;
         
        IF pSecuencia IS NULL THEN
            LET pSecuencia = 1;
        ELSE
            LET pSecuencia = pSecuencia + 1;
            LET cSituacionEsp = 'S';
        END IF;

        -- // SE AGREGA VALIDACIÓN PARA SI LA CLAVE DEL MUNICIPIO VIENE VACIO, LE ASIGNE  "00000".
        IF pMunicipio = "" OR pMunicipio is null  THEN
            LET pMunicipio = LPAD(TRIM(NVL(pMunicipio,"00000")),5,"0");
        END IF;
        
        -- // VALIDA LA INFORMACION DE LA DIRECCION DEL CLIENTE
        SELECT tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal,
               estado_inegi, municipio_inegi, localidad_inegi, numerociudad, 
               numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, 
               puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones
          INTO o_tipo_dir, o_calle, o_colonia, o_entre_calles, o_pais, o_estado, o_ciudad, o_municipio, o_cod_postal, o_apart_postal,
               o_estado_inegi, o_municipio_inegi, o_localidad_inegi, o_numerociudad, 
               o_numeroextcalle, o_numerointcalle, o_departamento, o_numerocalle, o_numerocolonia, 
               o_puntocardinal, o_unidadhabitac, o_manzana, o_otros, o_andador, o_etapa, o_lote, o_edificio, o_entrada, o_observaciones
          FROM si_direcciones_actual
         WHERE numcte = pNumCte
           AND tipo_dir = pTipoDir;
        
        IF ( o_tipo_dir is not null               
             AND o_calle = pCalle                     
             AND o_colonia = pColonia                 
             AND o_entre_calles = pEntre_Calles       
             AND o_pais = pPais                       
             AND o_estado = pEntidad                  
             AND o_ciudad = pLocalidad                
             AND o_municipio = pMunicipio             
             AND o_cod_postal = pCodPostal            
             AND o_estado_inegi = pEstado_Inegi       
             AND o_municipio_inegi = pMunicipio_Inegi 
             AND o_localidad_inegi = pLocalidad_Inegi 
             AND o_numerociudad = pNoCiudad           
             AND o_numeroextcalle = pNoExt            
             AND o_numerointcalle = pNoInt            
             AND o_departamento = pDepto              
             AND o_numerocalle = pNoCalle             
             AND o_numerocolonia = pNoColonia         
             AND o_puntocardinal = pPuntoCar          
             AND o_unidadhabitac = pUniHabi           
             AND o_manzana = pManz                    
             AND o_otros = pPOtros                    
             AND o_andador  = pAndador                
             AND o_etapa = pEtapa                     
             AND o_lote = pLote                       
             AND o_edificio = pEdif                   
             AND o_entrada = pEntrada                 
             AND o_observaciones = pObserva ) THEN
            LET pcoincide_dir = 1;
        ELSE
            LET pcoincide_dir = 0;
        END IF;
        
        IF ( pcoincide_dir <= 0 ) THEN
			INSERT INTO si_direcciones
            ( numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal,
              estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, 
              departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, otros, 
              andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert )
            VALUES
            ( pNumCte, pSecuencia, pTipoDir, pCalle, pColonia, pEntre_Calles, pPais, pEntidad, pLocalidad, pMunicipio, pCodPostal, "",
              pEstado_Inegi, pMunicipio_Inegi, pLocalidad_Inegi, pNoCiudad, pNoExt, pNoInt,
              pDepto, pNoCalle, pNoColonia, pPuntoCar, pUniHabi, pManz, pPOtros,
              pAndador, pEtapa, pLote, pEdif, pEntrada, pObserva, pUser_Insert, pFecha_Insert );
        END IF;
        
        -- // VALIDA LA INFORMACIÓN DE LOS TELEFONOS DEL CLIENTE
        SELECT telefono
          INTO o_telefono1
          FROM si_telefonos_actual
         WHERE numcte = pNumCte
           AND tipo_tel = 1;
           
        IF o_telefono1 is null THEN
            LET o_telefono1 = ' ';
        END IF;
           
        IF o_telefono1 <> pTelefono1 THEN
            IF cSucursal = '5002' THEN
                LET vCanal = 12;
            END IF;
              
            IF ( ( pTipoTel1 is not null AND pTipoTel1 <> '' ) AND ( pTelefono1 is not null AND pTelefono1 <> '' ) ) THEN
                LET vTipoTel = 1;
                CALL sp_registra_telefonos(pEmpresa, pNumCte, pTelefono1, vTipoTel, '', 0, vCanal, pUser_Insert)
                RETURNING v_CodRetTel;
            END IF;
        END IF;
           
        SELECT telefono
          INTO o_telefono2
          FROM si_telefonos_actual
         WHERE numcte = pNumCte
           AND tipo_tel = 2;
           
        IF o_telefono2 is null THEN
            LET o_telefono2 = ' ';
        END IF;
           
        IF o_telefono2 <> pTelefono2 THEN
            IF cSucursal = '5002' THEN
                LET vCanal = 12;
            END IF;
              
            IF ( ( pTipoTel2 is not null AND pTipoTel2 <> '' ) AND ( pTelefono2 is not null AND pTelefono2 <> '' ) ) THEN
                LET vTipoTel = 2;
                CALL sp_registra_telefonos(pEmpresa, pNumCte, pTelefono2, vTipoTel, '', 0, vCanal, pUser_Insert)
                RETURNING v_CodRetTel;
            END IF;
        END IF;
           
        SELECT telefono, extension
          INTO o_telefono3, o_extension
          FROM si_telefonos_actual
         WHERE numcte = pNumCte
           AND tipo_tel = 3;
           
        IF o_telefono3 is null THEN
            LET o_telefono3 = ' ';
        END IF;
           
        IF o_telefono3 <> pTelefono3 THEN
            IF cSucursal = '5002' THEN
                LET vCanal = 12;
            END IF;
              
            IF ( ( pTipoTel3 is not null AND pTipoTel3 <> '' ) AND ( pTelefono3 is not null AND pTelefono3 <> '' ) ) THEN
                LET vTipoTel = 3;
                CALL sp_registra_telefonos(pEmpresa, pNumCte, pTelefono3, vTipoTel, pExtension, 0, vCanal, pUser_Insert)
                RETURNING v_CodRetTel;
            END IF;
        END IF;
        
        -- // VALIDACIÓN DE SITUACIÓN ESPECIAL
        IF pTipoDir = '1' AND cSituacionEsp = 'S' THEN
            SELECT LIMIT 1 NVL(situacion,''), causa
              INTO cSituacionEsp, iCausa
              FROM bdisitesp:se_ctessitespcte
             WHERE numcte = pNumCte;
			
            IF cSituacionEsp = 'L' THEN			 
                DELETE FROM bdisitesp:se_ctessitespcte 
                 WHERE numcte = pNumCte 
                   AND situacion = 'L';
            
                INSERT INTO bdisitesp:se_ctessitespcte_his
                (empresa, sucursal, numcte, situacion, causa, tipomovto, empleadoefectuo, usralta, fchmodifica)
                VALUES
                (pEmpresa, cSucursal, pNumCte, cSituacionEsp, iCausa, 'B', pUser_Insert, pUser_Insert, pFecha_Insert);
            END IF;
        END IF;
        
        RETURN v_CodRet;
    END IF;
    
    END;
    
END PROCEDURE

DOCUMENT
"Alta de direcciones del cliente",
"Autor : Procesamiento Interactivo S.A. de C.V.",
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1",
"MODIFICO : Hector Bojórquez",
"FECHA : 17/Junio/2009",
"MODIFICACION: En la actualización de domicilios se identifica si el cliente",
"              tiene una situación especial L, de ser asi lo desmarca",
"Ver.  : 1.2",
"MODIFICO : Frank Gaxiola Gaxiola",
"FECHA : 28/Octubre/2009",
"MODIFICACION: Se quita funcionalidad de desmarcaje L, solicitado por Alfonso",
"              Velázquez",
"Ver.  : 1.3",
"MODIFICO : Rodolfo Tortolero Varela",
"FECHA : 06/Abril/2010",
"MODIFICACION: Se implementa validación para formatear el campo municipio con",
"                             0 cuando este sea vacio o null, para que no inserte nuevo registro.",
"solicitado por Daniel Zambada",
"Ver.  : 1.4",
"MODIFICO : Rodolfo Gómez Hernández",
"FECHA : Mayo/2010",
"MODIFICACION: Se optimiza sp guardando la dirección del cliente en variables",
"              para la comparación si hay algún cambio en la dirección del cliente",
"Ver.  : 1.5",
"MODIFICO : Marco A. Campos",
"FECHA: 08-Ago-2011",
"MODIFICACION: Reactivar funcionalidad de desmarcaje situación especial L.";

CREATE PROCEDURE "informix".sp_obthuellasactes(pNumCteCorr CHAR(20), pNumCteInc CHAR(20))
RETURNING
CHAR(6) 	AS 	cCodRet,
CHAR(942)	AS	cTrama,
CHAR(942)	AS	cTrama2;


	--DECLARACIONES
    DEFINE cCodRet          CHAR(6);
    DEFINE iSqlErr          INTEGER;
    DEFINE iIsamErr         INTEGER;
    
	DEFINE cTrama	    	CHAR(942);
	DEFINE cTrama2	    	CHAR(942);
	DEFINE cTipoCte	    	CHAR(1);
	DEFINE cTipoCte2    	CHAR(1);
	DEFINE cSecTitular    	CHAR(2);
	DEFINE cSecInco	    	CHAR(2);
	DEFINE cTicket1	    	CHAR(20);
	DEFINE cTicket2	    	CHAR(20);
	DEFINE cTicket3	    	CHAR(20);
	DEFINE iNumCte	    	INTEGER;
	DEFINE ibandera	    	INTEGER;

    --INICIALIZACIONES
	LET cCodRet				= '000000';
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	
	LET cTrama				= '';
	LET cTrama2				= '';
	LET cTipoCte			= '';
	LET cTipoCte2			= '';
	LET cSecTitular    		= '';
	LET cSecInco	    	= '';
	LET cTicket1	    	= '';
	LET cTicket2	    	= '';
	LET cTicket3	    	= '';
	LET iNumCte	    		= 0;
	LET ibandera	    	= 0;

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN TRIM(cCodRet), TRIM(NVL(cTrama,'')), TRIM(NVL(cTrama2,''));
		END IF;
    END EXCEPTION;

	--SET DEBUG FILE TO "/respaldosbd/hectorb/sp_obthuellasactes.out";
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;	
	
	IF NVL(pNumCteCorr,'') = '' OR NVL(pNumCteInc,'') = '' THEN
		LET cCodRet = '000001';
		RETURN TRIM(cCodRet), TRIM(NVL(cTrama,'')), TRIM(NVL(cTrama2,''));
	END IF
	
	--VALIDA QUE SEAN TITULARES AMBOS CLIENTES.
	SELECT tipo_cliente
	INTO cTipoCte
	FROM bdinteg:"informix".si_cliente
	WHERE numcte = pNumCteCorr;
	
	IF NVL(cTipoCte,'') = '' THEN -- CLIENTE CORRECTO NO EXISTE
		LET cCodRet = '000002';
		RETURN TRIM(cCodRet), TRIM(NVL(cTrama,'')), TRIM(NVL(cTrama2,''));
	END IF;
		
	SELECT tipo_cliente
	INTO cTipoCte2
	FROM bdinteg:"informix".si_cliente
	WHERE numcte = pNumCteInc;
	
	IF NVL(cTipoCte2,'') = '' THEN --CLIENTE INCORRECTO NO EXISTE
		LET cCodRet = '000003';
		RETURN TRIM(cCodRet), TRIM(NVL(cTrama,'')), TRIM(NVL(cTrama2,''));
	ELSE
		--OBTIENE EL TEMPLATE DE LA HUELLA DEL CLIENTE TITULAR
		SELECT dmapa, secuencia
		INTO cTrama, cSecTitular
		FROM bdinteg:"informix".si_cte_huella   
		WHERE numcte = pNumCteCorr
		AND secuencia = (SELECT MAX(secuencia)
						FROM bdinteg:"informix".si_cte_huella
						WHERE numcte = pNumCteCorr);		
		
		--OBTIENE EL TEMPLATE DE LA HUELLA DEL CLIENTE TRASPASAR
		SELECT dmapa, secuencia
		INTO cTrama2, cSecInco
		FROM bdinteg:"informix".si_cte_huella   
		WHERE numcte = pNumCteInc
		AND secuencia = (SELECT MAX(secuencia)
						FROM bdinteg:"informix".si_cte_huella
						WHERE numcte = pNumCteInc);
		
		--VALIDA QUE LA SECUENCIA EXISTA EN LA CONSULTA A LA TABLA "si_cte_huella" SINO, REGRESA UN CODIGO DE RETORNO
		IF cSecTitular <> '' THEN
			SELECT ticket
			INTO cTicket1
			FROM bdinteg:"informix".si_huella_linea
			WHERE numcte = pNumCteCorr
			AND secuencia = cSecTitular;
			
			IF NVL(cTicket1,'') = '' THEN
				SELECT ticket
				INTO cTicket2
				FROM bdinteg:"informix".si_huella_linea_hist
				WHERE numcte = pNumCteCorr
				AND secuencia = cSecTitular
				AND fecha_consulta = (SELECT MAX (fecha_consulta)
									  FROM bdinteg:"informix".si_huella_linea_hist
									  WHERE numcte = pNumCteCorr
									  AND secuencia = cSecTitular);
									  
				IF cTicket2 = '' THEN
					LET cCodRet = "000000";  --NO SE A REALIZADO LA COMPARACION DE HUELLA DEL CLIENTE SOLICITADO
					RETURN TRIM(cCodRet), TRIM(NVL(cTrama,'')), TRIM(NVL(cTrama2,''));
				END IF;
			END IF;
		END IF;
		
		
		--SE CONSULTA EL NUMERO DE CLIENTE PARA VER SI SE REALIZO LA COMPARACIÓN DE HUELLA EXITOSA EN SUCURSAL SINO SE MANDA CODIGO DE EXITO
		IF cTicket1 <> '' THEN
			LET cTicket3 = cTicket1;
		ELIF cTicket2 <> '' THEN
			LET cTicket3 = cTicket2;
		ELSE
			LET cCodRet = "000000";  --NO SE A REALIZADO LA COMPARACION DE HUELLA DEL CLIENTE SOLICITADO
			RETURN TRIM(cCodRet), TRIM(NVL(cTrama,'')), TRIM(NVL(cTrama2,''));
		END IF;	
		
		
			SELECT LIMIT 1 cliente
			INTO iNumCte
			FROM bdinteg:"informix".si_huella_linea_resultado
			WHERE estado_proceso = '2'
			AND cliente = pNumCteInc
			AND ticket = cTicket3
			AND empresa  = '5'
			AND num_mensaje = '602';
			--AND secuencia = cSecInco; -- ESTA LINEA SE ACTIVARA CUANDO LO DE SUCURSAL YA ESTE
										-- FUNCIONANDO,ES DECIR, CUANDO EL VALOR DE LA SECUENCIA SE ESTE
										-- GUARDANDO EN LAS TABLAS.

			IF NOT iNumCte > 0 THEN
                SELECT LIMIT 1 cliente
                INTO iNumCte
                FROM bdinteg:"informix".si_huella_linea_resultado_hist
                WHERE estado_proceso = '2'
                AND cliente = pNumCteInc
                AND ticket = cTicket3
                AND empresa  = '5'
                AND num_mensaje = '602';
            END IF;    
		
			IF iNumCte > 0 THEN
				LET cCodRet = '000006';  --Los clientes consultados ya tuvieron la comparación de huellas
			END IF;
	END IF;
	
	RETURN TRIM(cCodRet), TRIM(NVL(cTrama,'')), TRIM(NVL(cTrama2,''));		
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea procedimiento el cual consulta la tabla si_cte_huella para traer la informacion de la huella derecha del cliente por su maxima secuencia ',		   
'AUTOR: Armando Morales',
'FECHA: Octubre 2012',
'VERSION: 20121001.1600',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_cnsif_movproac(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCUENTA CHAR(20),cNUMEMP CHAR(20),iCONSULTA INTEGER,pNumRegistro INTEGER,pRecuperacion INTEGER)
							
				returning CHAR(5)      AS Codred,
						  DATE         AS Fecha_Operacion,
						  MONEY(14,2)  AS Importe_Redondeo,
						  MONEY(14,2)  AS Saldo_Redondeo,
						  MONEY(14,2)  AS Importe_Premio,
						  MONEY(14,2)  AS Saldo_Premio,
						  MONEY(14,2)  AS Total_Acumulado;

							
DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;							
--SISTEMA DE CUENTA 01 VARIABLES
DEFINE dFechaMovimiento	DATE;
DEFINE mImporte_Red		MONEY(14,2);
DEFINE mSaldo_Red	    MONEY(14,2);
DEFINE mImporte_Pre		MONEY(14,2);
DEFINE mSaldo_Pre	    MONEY(14,2);
DEFINE mTotal_Acum	    MONEY(14,2);
DEFINE cCuentaPROAC     CHAR(20);



-- VARIABLES STORE sp_reporte_edocuenta
DEFINE vCodRet               CHAR(05);
--VARIABLES DE PAGINACION
DEFINE iCont            INT;

--inicializando variables
LET  iexiste 		 = 0;
LET cCodRet 		 = "00000";
LET iSql_err 		 = 0 ;	
LET dFechaMovimiento = "";
LET mImporte_Red		 = 0;
LET mSaldo_Red			 = 0;
LET mImporte_Pre		 = 0;
LET mSaldo_Pre			 = 0;
LET mTotal_Acum			 = 0;
LET cCuentaPROAC         ="";       

--VARIABLES DE PAGINACION 
LET iCont       = 0;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet,dFechaMovimiento,mImporte_Red, mSaldo_Red, mImporte_Pre, mSaldo_Pre, mTotal_Acum;						
		END IF;
	END EXCEPTION;
	
	--  SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_movproac.out";
	--	TRACE ON;
		
    IF 	cID_USUARIOC = '' 	OR
        cID_FUNCIONC = '' 	OR
        cNUMCUENTA   = ''	OR 
        cNUMEMP      = ''   OR 
        iCONSULTA 	 = 0	THEN 
        LET cCodRet = "00036";
        RETURN cCodRet,dFechaMovimiento,mImporte_Red, mSaldo_Red, mImporte_Pre, mSaldo_Pre, mTotal_Acum;	
    END IF


    IF pNumRegistro<0 THEN
        LET cCodRet='00098';
        RETURN cCodRet,dFechaMovimiento,mImporte_Red, mSaldo_Red, mImporte_Pre, mSaldo_Pre, mTotal_Acum;	
    ELSE
        IF pRecuperacion<=0 THEN
            LET cCodRet='00098';
            RETURN cCodRet,dFechaMovimiento,mImporte_Red, mSaldo_Red, mImporte_Pre, mSaldo_Pre, mTotal_Acum;	
        END IF;
    END IF;  	
  

	--VALIDACION
    EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'01','1')
    INTO
    cCodRet;

	IF (cCodRet != '00000')  THEN
	    RETURN cCodRet,dFechaMovimiento,mImporte_Red, mSaldo_Red, mImporte_Pre, mSaldo_Pre, mTotal_Acum;	
	END IF;
	-- TERMINA VALIDACION

    SELECT cuenta INTO cCuentaPROAC FROM bdicheq:sc_proac WHERE cta_eje = cNUMCUENTA
    AND secuencia = (SELECT Max(secuencia) FROM bdicheq:sc_proac WHERE cta_eje = cNUMCUENTA And status_cta in ('1','3'))
    And status_cta in ('1','3');
		
    SELECT NVL(COUNT(cuenta),0)	INTO iexiste FROM bdicheq:vedoctamov_proac WHERE cod_usuario = cNUMEMP AND cuenta  = cCuentaPROAC AND consulta  = iCONSULTA;
    IF iexiste  = 0 THEN 
        LET cCodRet = "00078";
        RETURN cCodRet,dFechaMovimiento,mImporte_Red, mSaldo_Red, mImporte_Pre, mSaldo_Pre, mTotal_Acum;	
    END IF;     
			SET ISOLATION TO DIRTY READ;
			
			FOREACH 
			 SELECT SKIP pNumRegistro FIRST pRecuperacion  fechamov,importe_redondeo,saldo_redondeo,importe_premio,saldo_premio,total_acumulado
			   INTO dFechaMovimiento,mImporte_Red, mSaldo_Red, mImporte_Pre, mSaldo_Pre, mTotal_Acum		
			FROM bdicheq:vedoctamov_proac 
			WHERE cod_usuario = cNUMEMP 
			 AND cuenta  = cCuentaPROAC	
			 AND consulta  = iCONSULTA ORDER BY secuencia
			 
			
			LET iCont=iCont+1;

			
			RETURN cCodRet,dFechaMovimiento,mImporte_Red, mSaldo_Red, mImporte_Pre, mSaldo_Pre, mTotal_Acum WITH resume;						
			
			END FOREACH;
			
			IF iCont = 0 THEN
                LET cCodRet = 1001; 
				RETURN cCodRet,dFechaMovimiento,mImporte_Red, mSaldo_Red, mImporte_Pre, mSaldo_Pre, mTotal_Acum;						
			END IF;
			

END
END PROCEDURE
DOCUMENT
"AutOR : VICTOR HUGO SANCHEZ",
"FUNCIONAMIENTO:Obtener la información de los Movimientos de PROAC",
"FECHA : 20-11-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cnsif_menedoctacred(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCUENTA CHAR(20),cFECHAEMISION CHAR(07),pNumRegistro INTEGER,pRecuperacion INTEGER)
				returning CHAR(5)             AS Cod_Retorno,
						  CHAR(255)           AS Mensaje;

DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;							

--SISTEMA DE CUENTA 01 VARIABLES+

DEFINE v_fecha_emision 		DATE ;
DEFINE v_num_credito 		CHAR(20);
DEFINE vCodRet 			    CHAR(6);
DEFINE cMensaje 	        CHAR(255);
DEFINE v_secuencia 			SMALLINT;
DEFINE v_nlinea 			SMALLINT;
DEFINE v_si_paga 			CHAR(255);
DEFINE v_numProducto        CHAR(4);
DEFINE cTipoEdoCta      CHAR(02);
DEFINE dFechaPeriodo    DATE;

--VARIABLES STORE ...
DEFINE cMensajeAux     CHAR(80);
DEFINE cPeriodoAux     DATE;
--VARIABLES DE PAGINACION
DEFINE iCont            INT;
--inicializando variables
LET  iexiste 		 = 0;
LET cCodRet 		 = "00000";
LET iSql_err 		 = 0 ;	
LET v_fecha_emision  = '';
LET v_num_credito 	 = '';
LET vCodRet          = '';
LET cMensaje	     = "";
LET v_secuencia 	 = 0;		
LET v_nlinea 		 = 0;
LET v_si_paga 		 = '';
LET v_numProducto    = '';
LET cTipoEdoCta        = '';
LET dFechaPeriodo      = '';
LET cMensaje           = '';
LET cPeriodoAux        = '';

--VARIABLES DE PAGINACION 
LET iCont       = 0;



BEGIN

	ON EXCEPTION SET iSql_err

		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet,cMensaje;
		END IF;

	END EXCEPTION;


	--  SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_menedoctacred.out";
	-- 	TRACE ON;

	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cNUMCUENTA   = ''	OR 
		cFECHAEMISION = '' THEN 
		LET cCodRet = "00045";
		RETURN cCodRet,cMensaje;
	END IF 	   

    IF pNumRegistro<0 THEN
        LET cCodRet='00098';
        RETURN cCodRet,cMensaje;				
    ELSE
        IF pRecuperacion<=0 THEN
            LET cCodRet='00098';
            RETURN cCodRet,cMensaje;
        END IF;
    END IF;  		
	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'06','1')
	INTO
	cCodRet;
	IF (cCodRet != '00000')  THEN
	    RETURN cCodRet,cMensaje;
	END IF;
	-- TERMINA VALIDACION


	LET  cTipoEdoCta = SUBSTR(cNUMCUENTA,1,2); 
	IF   cTipoEdoCta = '60' THEN 
		--PARA 60
		SELECT NVL(COUNT(num_credito),0) into iexiste FROM bdicred:sd_maecred WHERE num_credito = cNUMCUENTA ;
		IF iexiste  = 0 THEN 
			LET cCodRet = "00046";
			RETURN  cCodRet,cMensaje;
		END IF;
	ELIF cTipoEdoCta <> '60'   THEN 
		SELECT NVL(COUNT(num_credito),0) into iexiste FROM bdicred:sd_maecredcrd WHERE num_credito  = cNUMCUENTA;
		IF iexiste  = 0 THEN 
			LET cCodRet = "00046";
			RETURN  cCodRet,cMensaje;
		END IF;
	END IF

	IF   cTipoEdoCta = '60' THEN  
		--PARA FORMAR EL PERIODO SE AGREGA DIA 20 AL MES Y AÑO
--		LET dFechaPeriodo = EXTEND(MDY(SUBSTR(cFECHAEMISION,6,2),20,SUBSTR(cFECHAEMISION,1,4)), YEAR TO SECOND);
        LET dFechaPeriodo = EXTEND(MDY(SUBSTR(cFECHAEMISION,5,2),20,SUBSTR(cFECHAEMISION,1,4)), YEAR TO SECOND);
		SELECT NVL(COUNT(*),0) into iexiste FROM bdicred@pld_tcp:sd_mensajes_edocta WHERE num_credito = cNUMCUENTA AND fecha_emision = dFechaPeriodo;
		IF iexiste  = 0 THEN 
			LET cCodRet = "00058";
			RETURN  cCodRet,cMensaje;
		END IF;

		SET ISOLATION TO DIRTY READ;		
		FOREACH 
			SELECT SKIP pNumRegistro FIRST pRecuperacion 
			a.fecha_emision, a.num_credito,  b.secuencia, b.nlinea, '', b.mensaje
			FROM bdicred@pld_tcp:sd_mensajes_edocta a
			LEFT OUTER JOIN bdicred@pld_tcp:sd_mensajes_mensual_edocta b on a.fecha_emision = b.fecha_emision
			WHERE a.fecha_emision = dFechaPeriodo and a.secuencia = 2 and a.nlinea = 1 and a.num_credito = cNUMCUENTA
		UNION ALL
			SELECT fecha_emision, num_credito,  secuencia, nlinea, nvl(si_paga,''), mensajes
			INTO 	v_fecha_emision, v_num_credito,	v_secuencia, v_nlinea, v_si_paga, cMensaje
			FROM bdicred@pld_tcp:sd_mensajes_edocta a
			WHERE a.fecha_emision = dFechaPeriodo and num_credito = cNUMCUENTA
			ORDER BY 2,3,4				

			LET iCont = iCont + 1;				

			RETURN cCodRet,cMensaje WITH resume;
		END FOREACH;

		IF iCont = 0 THEN
			LET cCodRet = 1001; 
			RETURN cCodRet,cMensaje;
		END IF
	ELIF cTipoEdoCta <> '60' THEN  --REESTRUCTURA Y PRESTAMO PERSONAL
		SET ISOLATION TO DIRTY READ;
		FOREACH
			EXECUTE PROCEDURE bdicred:obtenPeriodos_edocuentacrd (cNUMCUENTA)
			INTO
			vCodRet,cMensajeAux,cPeriodoAux
		END FOREACH;
		
		IF vCodRet = '000002' THEN
			LET cCodRet = '00051';
			RETURN cCodRet,cMensaje;
		END IF
		
		IF vCodRet != '000000' THEN
			LET cCodRet = SUBSTR(vCodRet,2,5);
			RETURN cCodRet,cMensaje;
		ELSE
			LET cCodRet = SUBSTR(vCodRet,2,5);
		END IF

--		LET dFechaPeriodo = EXTEND(MDY(SUBSTR(cFECHAEMISION,6,2),DAY(cPeriodoAux),SUBSTR(cFECHAEMISION,1,4)), YEAR TO SECOND);
        LET dFechaPeriodo = EXTEND(MDY(SUBSTR(cFECHAEMISION,5,2),DAY(cPeriodoAux),SUBSTR(cFECHAEMISION,1,4)), YEAR TO SECOND);

		SET ISOLATION TO DIRTY READ;
		SELECT num_producto 
		INTO v_numProducto
        FROM bdicred:sd_maecredcrd
        WHERE empresa = '001'
        AND num_credito = cNUMCUENTA;

		IF EXISTS (SELECT * FROM bdicred:sd_mensajes_edoctacrd WHERE fecha_emision = dFechaPeriodo AND num_credito = cNUMCUENTA) THEN
			SET ISOLATION TO DIRTY READ;
			FOREACH 
				SELECT SKIP pNumRegistro FIRST pRecuperacion
				a.fecha_emision, a.num_credito,  b.secuencia, b.nlinea, '', b.mensaje
				FROM bdicred:sd_mensajes_edoctacrd a
				LEFT OUTER JOIN bdicred:sd_mensajes_mensual_edoctacrd b ON a.fecha_emision = b.fecha_emision
				WHERE a.fecha_emision = dFechaPeriodo AND a.secuencia = 1 AND a.nlinea = 1 AND a.num_credito = cNUMCUENTA AND a.num_producto = v_numProducto
				 AND a.num_producto = b.num_producto  
			UNION ALL
				SELECT  
				fecha_emision, num_credito,  secuencia, nlinea, nvl(si_paga,''), mensajes
				INTO 	v_fecha_emision, v_num_credito,	v_secuencia, v_nlinea, v_si_paga, cMensaje
				FROM bdicred:sd_mensajes_edoctacrd a
				WHERE a.fecha_emision = dFechaPeriodo AND num_credito = cNUMCUENTA AND a.num_producto = v_numProducto
				ORDER BY 2,3,4

				LET iCont = iCont + 1;
				RETURN cCodRet,cMensaje WITH resume;
			END FOREACH;

			IF iCont = 0 THEN
				LET cCodRet = 1001; 
				RETURN cCodRet,cMensaje;
			END IF
		ELSE
			SELECT NVL(COUNT(*),0) into iexiste FROM bdicred:sd_mensajes_mensual_edoctacrd WHERE fecha_emision = dFechaPeriodo AND num_producto = v_numProducto;
			IF iexiste  = 0 THEN 
				LET cCodRet = "00058";
				RETURN  cCodRet,cMensaje;
			END IF;

			SET ISOLATION TO DIRTY READ;
			FOREACH 
				SELECT SKIP pNumRegistro FIRST pRecuperacion 
				a.fecha_emision, '',  a.secuencia, a.nlinea, '', a.mensaje
				INTO v_fecha_emision, v_num_credito,v_secuencia, v_nlinea, v_si_paga, cMensaje
				FROM bdicred:sd_mensajes_mensual_edoctacrd a
				WHERE a.fecha_emision = dFechaPeriodo AND a.num_producto = v_numProducto
				ORDER BY 3,4

				LET iCont = iCont + 1;
				RETURN cCodRet,cMensaje WITH resume;
			END FOREACH;

			IF iCont = 0 THEN
				LET cCodRet = 1001; 
				RETURN cCodRet,cMensaje;
			END IF
		END IF
	END IF		
END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener los mensajes para el o los Estados de Cuenta de Crédito, dependiendo del periodo consultado.  ",
"El SP obtiene la información de  la Base de Datos central de Informix, enviando como parámetro el Número de Cuenta y la Fecha de Emisión a consultar. ",
"FECHA : 27-02-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cnsif_movedocta(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cTIPOSISTEMA CHAR(20),pNumRegistro INTEGER,pRecuperacion INTEGER,cNUMCUENTA CHAR(20),cNUMEMP CHAR(20),iCONSULTA INTEGER,cPERIODO CHAR(07))
							
				returning CHAR(5),
						  CHAR(11),
						  CHAR(50),
						  CHAR(50),
						  CHAR(50),
						  CHAR(50),
						  CHAR(50),
						  CHAR(50),
						  DECIMAL(16,2),
						  DECIMAL(16,2),
						  DECIMAL(16,2),
						  CHAR(50),
						  MONEY(14,2),
						  MONEY(14,2);
							
DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;							
--SISTEMA DE CUENTA 01 VARIABLES
DEFINE dFechaMovimiento	DATE;
DEFINE descMes          CHAR(11);
DEFINE cGenerico_1 	    CHAR(50);
DEFINE cGenerico_2 	    CHAR(50);
DEFINE cGenerico_3 	    CHAR(50);
DEFINE cGenerico_4 	    CHAR(50);
DEFINE cGenerico_5 	    CHAR(50);
DEFINE cGenerico_6 	    CHAR(50);
DEFINE decRetiros		DECIMAL(16,2);
DEFINE decDepositos 	DECIMAL(16,2);
DEFINE decSaldos  		DECIMAL(16,2);
DEFINE cConcepto		CHAR(50);
DEFINE mCompras			MONEY(14,2);
DEFINE mAbonos		    MONEY(14,2);

DEFINE cTipoEdoCta      CHAR(02);
DEFINE dFechaPeriodo    DATE;
DEFINE cNumTarjeta      CHAR(16);

-- VARIABLES STORE sp_reporte_edocuenta
DEFINE vCodRet               CHAR(05);
DEFINE iTipoReporte          INTEGER;

--VARIABLES STORE ...
DEFINE cMensaje             CHAR(80);
DEFINE cPeriodoAux          DATE;

--VARIABLES DE PAGINACION
DEFINE iCont            INT;

--inicializando variables
LET  iexiste 		 = 0;
LET cCodRet 		 = "00000";
LET iSql_err 		 = 0 ;	
LET dFechaMovimiento = "";
LET descMes          = '';
LET cGenerico_1	     = "";
LET cGenerico_2	     = "";
LET cGenerico_3	     = "";
LET cGenerico_4	     = "";
LET cGenerico_5	     = "";
LET cGenerico_6	     = "";
LET decRetiros		 = 0;
LET decDepositos 	 = 0;
LET decSaldos  		 = 0;
LET cConcepto		 = "";
LET mCompras		 = 0;
LET mAbonos			 = 0;

LET cTipoEdoCta      = '';
LET dFechaPeriodo    = '';
LET cNumTarjeta      = '';

LET vCodRet             = '';
LET iTipoReporte        = '';

LET cMensaje           = '';
LET cPeriodoAux        = '';

--VARIABLES DE PAGINACION 
LET iCont       = 0;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet,descMes,cGenerico_1, cGenerico_2, cGenerico_3, cGenerico_4, cGenerico_5, cGenerico_6, decRetiros, decDepositos, decSaldos,cConcepto, mCompras,mAbonos;						
		END IF;
	END EXCEPTION;
	
	--  SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_movedocta_2.out";
	--	TRACE ON;
		
	IF cTIPOSISTEMA = 'CAPTACION' THEN	
		IF 	cID_USUARIOC = '' 	OR
			cID_FUNCIONC = '' 	OR
			cNUMCUENTA   = ''	OR 
			cNUMEMP      = ''   OR 
			iCONSULTA 	 = 0	OR 
			cTIPOSISTEMA = '' THEN 
			LET cCodRet = "00036";
			RETURN cCodRet,descMes,cGenerico_1, cGenerico_2, cGenerico_3, cGenerico_4, cGenerico_5, cGenerico_6, decRetiros, decDepositos, decSaldos,cConcepto, mCompras,mAbonos;						
		END IF
	END IF;
	IF cTIPOSISTEMA = 'CREDITO' THEN	
		IF 	cID_USUARIOC = '' 	OR
			cID_FUNCIONC = '' 	OR
			cNUMCUENTA   = ''	OR 
			cPERIODO     = ''   OR
			cTIPOSISTEMA = '' THEN 
			LET cCodRet = "00045";
			RETURN cCodRet,descMes,cGenerico_1, cGenerico_2, cGenerico_3, cGenerico_4, cGenerico_5, cGenerico_6, decRetiros, decDepositos, decSaldos,cConcepto, mCompras,mAbonos;						
		END IF
	END IF;

    IF pNumRegistro<0 THEN
        LET cCodRet='00098';
        RETURN cCodRet,descMes,cGenerico_1, cGenerico_2, cGenerico_3, cGenerico_4, cGenerico_5, cGenerico_6, decRetiros, decDepositos, decSaldos,cConcepto, mCompras,mAbonos;						
    ELSE
        IF pRecuperacion<=0 THEN
            LET cCodRet='00098';
            RETURN cCodRet,descMes,cGenerico_1, cGenerico_2, cGenerico_3, cGenerico_4, cGenerico_5, cGenerico_6, decRetiros, decDepositos, decSaldos,cConcepto, mCompras,mAbonos;						
        END IF;
    END IF;  	
	IF cTIPOSISTEMA <> 'CAPTACION' AND cTIPOSISTEMA <> 'CREDITO' THEN 
		LET cCodRet = "00048";
		RETURN cCodRet,descMes,cGenerico_1, cGenerico_2, cGenerico_3, cGenerico_4, cGenerico_5, cGenerico_6, decRetiros, decDepositos, decSaldos,cConcepto, mCompras,mAbonos;						
	END IF;    	   

	--VALIDACION
	IF cTIPOSISTEMA = 'CAPTACION' THEN
		EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'01','1')
		INTO
		cCodRet;
	ELSE
		EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'06','1')
		INTO
		cCodRet;
	END IF
	IF (cCodRet != '00000')  THEN
	    RETURN cCodRet,descMes,cGenerico_1, cGenerico_2, cGenerico_3, cGenerico_4, cGenerico_5, cGenerico_6, decRetiros, decDepositos, decSaldos,cConcepto, mCompras,mAbonos;						
	END IF;
	-- TERMINA VALIDACION
		
	IF cTIPOSISTEMA = 'CAPTACION' THEN 

		SELECT NVL(COUNT(cuenta),0)	INTO iexiste FROM bdicheq:vedoctamov WHERE cod_usuario = cNUMEMP AND cuenta  = cNUMCUENTA	AND consulta  = iCONSULTA;
		IF iexiste  = 0 THEN 
		LET cCodRet = "00078";
		RETURN cCodRet,descMes,cGenerico_1, cGenerico_2, cGenerico_3, cGenerico_4, cGenerico_5, cGenerico_6, decRetiros, decDepositos, decSaldos,cConcepto, mCompras,mAbonos;						
		END IF;
		
			SET ISOLATION TO DIRTY READ;
			
			FOREACH 
			 SELECT SKIP pNumRegistro FIRST pRecuperacion 
			   CASE
			   WHEN MONTH(fechamov) = 1 THEN
				DAY(fechamov) ||  '/' ||  'ENE' ||  '/' || YEAR(fechamov)
			   WHEN MONTH(fechamov) = 2 THEN
			    DAY(fechamov) ||  '/' ||  'FEB' ||  '/' || YEAR(fechamov)
			   WHEN MONTH(fechamov) = 3 THEN
			    DAY(fechamov) ||  '/' ||  'MAR' ||  '/' || YEAR(fechamov)
			   WHEN MONTH(fechamov) = 4 THEN
			    DAY(fechamov) ||  '/' ||  'ABR' ||  '/' || YEAR(fechamov)
			   WHEN MONTH(fechamov) = 5 THEN
			    DAY(fechamov) ||  '/' ||  'MAY' ||  '/' || YEAR(fechamov)
			   WHEN MONTH(fechamov) = 6 THEN
			    DAY(fechamov) ||  '/' ||  'JUN' ||  '/' || YEAR(fechamov)
			   WHEN MONTH(fechamov) = 7 THEN
			    DAY(fechamov) ||  '/' ||  'JUL' ||  '/' || YEAR(fechamov)
			   WHEN MONTH(fechamov) = 8 THEN
			    DAY(fechamov) ||  '/' ||  'AGO' ||  '/' || YEAR(fechamov)
			   WHEN MONTH(fechamov) = 9 THEN
			    DAY(fechamov) ||  '/' ||  'SEP' ||  '/' || YEAR(fechamov)
			   WHEN MONTH(fechamov) = 10 THEN
			    DAY(fechamov) ||  '/' ||  'OCT' ||  '/' || YEAR(fechamov)
			   WHEN MONTH(fechamov) = 11 THEN
			    DAY(fechamov) ||  '/' ||  'NOV' ||  '/' || YEAR(fechamov)
			   WHEN MONTH(fechamov) = 12 THEN
			    DAY(fechamov) ||  '/' ||  'DIC' ||  '/' || YEAR(fechamov)
			   ELSE '' END AS FechaDesc,
			   NVL(generico_1,'') , NVL(generico_2,'') , NVL(generico_3,'') , NVL(generico_4,'') , 
			   NVL(generico_5,'') , NVL(generico_6,''),  NVL(retiro,0), NVL(deposito,0), NVL(saldo,0)
			   INTO 		
			   descMes, cGenerico_1, cGenerico_2, cGenerico_3, cGenerico_4, cGenerico_5, cGenerico_6,
			   decRetiros, decDepositos, decSaldos
			FROM bdicheq:vedoctamov 
			WHERE cod_usuario = cNUMEMP 
			 AND cuenta  = cNUMCUENTA	
			 AND consulta  = iCONSULTA ORDER BY secuencia
			 
			
			LET iCont=iCont+1;

            IF descMes="01/01/1900" THEN
                LET descMes="";
            END IF;
			
			RETURN 	cCodRet,descMes,cGenerico_1, cGenerico_2, cGenerico_3, cGenerico_4, cGenerico_5, cGenerico_6, decRetiros, decDepositos, decSaldos,cConcepto, mCompras,mAbonos WITH resume;						
			
			END FOREACH;
			
			IF iCont = 0 THEN
            LET cCodRet = 1001; 
				RETURN cCodRet,descMes,cGenerico_1, cGenerico_2, cGenerico_3, cGenerico_4, cGenerico_5, cGenerico_6, decRetiros, decDepositos, decSaldos,cConcepto, mCompras,mAbonos;						
			END IF
			
	ELIF cTIPOSISTEMA = 'CREDITO' THEN 
		
		LET  cTipoEdoCta = SUBSTR(cNUMCUENTA,1,2); 
		
		IF   cTipoEdoCta = '60' THEN  --CREDITO
			--PARA 60
			SELECT NVL(COUNT(num_credito),0) into iexiste FROM bdicred:sd_maecred WHERE num_credito = cNUMCUENTA ;
			IF iexiste  = 0 THEN 
				LET cCodRet = "00046";
				RETURN  cCodRet,descMes, cGenerico_1, cGenerico_2, cGenerico_3, cGenerico_4, cGenerico_5, cGenerico_6, decRetiros, decDepositos, decSaldos,cConcepto, mCompras,mAbonos;
			END IF;
		ELIF cTipoEdoCta <> '60'   THEN 
			SELECT NVL(COUNT(num_credito),0) into iexiste FROM bdicred:sd_maecredcrd WHERE num_credito  = cNUMCUENTA;
			IF iexiste  = 0 THEN 
				LET cCodRet = "00046";
				RETURN  cCodRet,descMes, cGenerico_1, cGenerico_2, cGenerico_3, cGenerico_4, cGenerico_5, cGenerico_6, decRetiros, decDepositos, decSaldos,cConcepto, mCompras,mAbonos;
			END IF;
		END IF
		
		IF   cTipoEdoCta = '60' THEN  --CREDITO
			--PARA FORMAR EL PERIODO SE AGREGA DIA 20 AL MES Y AÑO
			--  LET dFechaPeriodo = EXTEND(MDY(SUBSTR(cPERIODO,6,2),20,SUBSTR(cPERIODO,1,4)), YEAR TO SECOND);
			LET dFechaPeriodo = EXTEND(MDY(SUBSTR(cPERIODO,5,2),20,SUBSTR(cPERIODO,1,4)), YEAR TO SECOND);
			
			SELECT LIMIT 1 num_tarjeta
			INTO cNumTarjeta
			FROM bdicred@pld_tcp:sd_encabezado_edocta 
			WHERE  num_credito = cNUMCUENTA;

            IF EXISTS(SELECT {+INDEX(sd_encabezado_edocta idx_encabezado_edocta1)} fecha_emision FROM bdicred@pld_tcp:sd_encabezado_edocta WHERE fecha_emision = dFechaPeriodo AND num_credito = cNUMCUENTA) THEN

            ELSE
                LET cCodRet = "00034";
                RETURN  cCodRet,descMes, cGenerico_1, cGenerico_2, cGenerico_3, cGenerico_4, cGenerico_5, cGenerico_6, decRetiros, decDepositos, decSaldos,cConcepto, mCompras,mAbonos;
            END IF; 


			SET ISOLATION TO DIRTY READ;
			FOREACH 
			   SELECT SKIP pNumRegistro FIRST pRecuperacion 
			   fecha_mov,concepto,cargos,abonos 
			   INTO descMes,cConcepto, mCompras,mAbonos
			   FROM bdicred@pld_tcp:sd_detalle_edocta
			   WHERE num_credito = cNUMCUENTA
			   AND fecha_emision = dFechaPeriodo
			   ORDER BY secuencia, nlinea

				LET iCont=iCont+1;

				IF descMes="01/01/1900" THEN
					LET descMes="";
				END IF;

				RETURN cCodRet,descMes,cGenerico_1, cGenerico_2, cGenerico_3, cGenerico_4, cGenerico_5, cGenerico_6, decRetiros, decDepositos, decSaldos,cConcepto, mCompras,mAbonos WITH resume;
			END FOREACH;

			IF iCont = 0 THEN
				LET cCodRet = 1001; 
				RETURN cCodRet,descMes,cGenerico_1, cGenerico_2, cGenerico_3, cGenerico_4, cGenerico_5, cGenerico_6, decRetiros, decDepositos, decSaldos,cConcepto, mCompras,mAbonos;
			END IF;			
		ELIF cTipoEdoCta <> '60'   THEN  
		
			FOREACH
				EXECUTE PROCEDURE bdicred:obtenPeriodos_edocuentacrd (cNUMCUENTA)
				INTO
				cCodRet,cMensaje,cPeriodoAux
			END FOREACH;
			
			--  LET dFechaPeriodo = EXTEND(MDY(SUBSTR(cPERIODO,6,2),DAY(cPeriodoAux),SUBSTR(cPERIODO,1,4)), YEAR TO SECOND);

            LET dFechaPeriodo = EXTEND(MDY(SUBSTR(cPERIODO,5,2),DAY(cPeriodoAux),SUBSTR(cPERIODO,1,4)), YEAR TO SECOND);

			SELECT NVL(COUNT(fecha_mov),0) into iexiste FROM bdicred:sd_detalle_edoctacrd WHERE num_credito = cNUMCUENTA AND fecha_emision = dFechaPeriodo;
			IF iexiste  = 0 THEN 
				LET cCodRet = "00034";
				RETURN  cCodRet,descMes, cGenerico_1, cGenerico_2, cGenerico_3, cGenerico_4, cGenerico_5, cGenerico_6, decRetiros, decDepositos, decSaldos,cConcepto, mCompras,mAbonos;
			END IF;					
			SET ISOLATION TO DIRTY READ;
			FOREACH 
			   SELECT SKIP pNumRegistro FIRST pRecuperacion 
			   CASE
			   WHEN MONTH(fecha_mov) = 1 THEN
				DAY(fecha_mov) ||  '-' ||  'Ene' ||  '-' || YEAR(fecha_mov)
			   WHEN MONTH(fecha_mov) = 2 THEN
			    DAY(fecha_mov) ||  '-' ||  'Feb' ||  '-' || YEAR(fecha_mov)
			   WHEN MONTH(fecha_mov) = 3 THEN
			    DAY(fecha_mov) ||  '-' ||  'Mar' ||  '-' || YEAR(fecha_mov)
			   WHEN MONTH(fecha_mov) = 4 THEN
			    DAY(fecha_mov) ||  '-' ||  'Abr' ||  '-' || YEAR(fecha_mov)
			   WHEN MONTH(fecha_mov) = 5 THEN
			    DAY(fecha_mov) ||  '-' ||  'May' ||  '-' || YEAR(fecha_mov)
			   WHEN MONTH(fecha_mov) = 6 THEN
			    DAY(fecha_mov) ||  '-' ||  'Jun' ||  '-' || YEAR(fecha_mov)
			   WHEN MONTH(fecha_mov) = 7 THEN
			    DAY(fecha_mov) ||  '-' ||  'Jul' ||  '-' || YEAR(fecha_mov)
			   WHEN MONTH(fecha_mov) = 8 THEN
			    DAY(fecha_mov) ||  '-' ||  'Ago' ||  '-' || YEAR(fecha_mov)
			   WHEN MONTH(fecha_mov) = 9 THEN
			    DAY(fecha_mov) ||  '-' ||  'Sep' ||  '-' || YEAR(fecha_mov)
			   WHEN MONTH(fecha_mov) = 10 THEN
			    DAY(fecha_mov) ||  '-' ||  'Oct' ||  '-' || YEAR(fecha_mov)
			   WHEN MONTH(fecha_mov) = 11 THEN
			    DAY(fecha_mov) ||  '-' ||  'Nov' ||  '-' || YEAR(fecha_mov)
			   WHEN MONTH(fecha_mov) = 12 THEN
			    DAY(fecha_mov) ||  '-' ||  'Dic' ||  '-' || YEAR(fecha_mov)
			   ELSE '' END AS fecha_mov,
			   concepto,cargos,abonos
			   INTO descMes,cConcepto, mCompras,mAbonos
			   FROM bdicred:sd_detalle_edoctacrd
			   WHERE num_credito = cNUMCUENTA
			   AND fecha_emision = dFechaPeriodo
			   ORDER BY secuencia, nlinea
				
				LET iCont = iCont + 1;

                IF SUBSTR(descMes,7,4)="1900" THEN
                    LET descMes="";
				ELSE 
					IF LENGTH(descMes)=10 THEN
						LET descMes=SUBSTR(descMes,1,1) ||  '-' ||  SUBSTR(descMes,3,3)||  '-' || SUBSTR(descMes,9,2);
					ELSE
						LET descMes=SUBSTR(descMes,1,2) ||  '-' ||  SUBSTR(descMes,4,3)||  '-' || SUBSTR(descMes,10,2);
					END IF;
                END IF;
				
				RETURN cCodRet,descMes,cGenerico_1, cGenerico_2, cGenerico_3, cGenerico_4, cGenerico_5, cGenerico_6, decRetiros, decDepositos, decSaldos,cConcepto, mCompras,mAbonos WITH resume;
			END FOREACH;
				
			IF iCont = 0 THEN
				LET cCodRet = 1001; 
				RETURN cCodRet,descMes,cGenerico_1, cGenerico_2, cGenerico_3, cGenerico_4, cGenerico_5, cGenerico_6, decRetiros, decDepositos, decSaldos,cConcepto, mCompras,mAbonos;
			END IF
		
		END IF		
	END IF
END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la información de los Movimientos al Detalle para el o los Estados de Cuenta de Captación, dependiendo del periodo consultado.  ",
"El SP obtiene la información de  la Base de Datos central de Informix, enviando como parámetro el Número de Cuenta y el Periodo o Periodos a consultar.",
"FECHA : 27-02-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cnsif_movprocaclaracioncred(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCUENTA CHAR(20),cFECHAEMISION CHAR(07),pNumRegistro INTEGER,pRecuperacion INTEGER)
							
				returning CHAR(5)             AS Cod_Retorno,
						  DATE                AS Fecha,
						  CHAR(255)           AS Descripcion,
						  DECIMAL(14,2)       AS Importe,
						  DATE                AS Fecha_Movimiento,
						  CHAR(11)            AS Folio;
							
DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;							
--SISTEMA DE CUENTA 01 VARIABLES
DEFINE dFecha           DATE;
DEFINE cDescripcion 	CHAR(255);
DEFINE dFechaMovimiento	DATE;
DEFINE decImporte 	    DECIMAL(14,2);
DEFINE cFolio 	        CHAR(11);

DEFINE cTipoEdoCta      CHAR(02);
DEFINE dFechaPeriodo    DATE;
DEFINE dFecha2          CHAR(10);
DEFINE dFecha3          CHAR(10);


--VARIABLES STORE ...
DEFINE cMensaje             CHAR(80);
DEFINE cPeriodoAux          DATE;

--VARIABLES DE PAGINACION
DEFINE iCont            INT;

DEFINE iDia             INT;
DEFINE iMes             INT;
DEFINE iAnio            INT;

--inicializando variables
LET  iexiste 		 = 0;
LET cCodRet 		 = "00000";
LET iSql_err 		 = 0 ;	

LET dFecha           = '';
LET cDescripcion	 = "";
LET decImporte	     = "";
LET dFechaMovimiento = "";
LET cFolio	         = "";

LET cTipoEdoCta        = '';
LET dFechaPeriodo      = '';

LET cMensaje           = '';
LET cPeriodoAux        = '';
LET dFecha2             ="";
LET dFecha3             ="";

--VARIABLES DE PAGINACION 
LET iCont       = 0;

LET iDia        = 0;
LET iMes        = 0;
LET iAnio       = 0;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet,dFecha,cDescripcion, decImporte, dFechaMovimiento,cFolio;
		END IF;
	END EXCEPTION;
	
	  	--  SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_movprocaclaracioncred.out";
	  	--  TRACE ON;
	
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cNUMCUENTA   = ''	OR 
		cFECHAEMISION = '' THEN 
		LET cCodRet = "00045";
		RETURN cCodRet,dFecha,cDescripcion, decImporte, dFechaMovimiento,cFolio;
	END IF 	   

    IF pNumRegistro<0 THEN
        LET cCodRet='00098';
        RETURN cCodRet,dFecha,cDescripcion, decImporte, dFechaMovimiento,cFolio;
    ELSE
        IF pRecuperacion<=0 THEN
            LET cCodRet='00098';
            RETURN cCodRet,dFecha,cDescripcion, decImporte, dFechaMovimiento,cFolio;
        END IF;
    END IF;    
    --VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'06','1')
	INTO
	cCodRet;
	IF (cCodRet != '00000')  THEN
	    RETURN cCodRet,dFecha,cDescripcion, decImporte, dFechaMovimiento,cFolio;
	END IF;
	-- TERMINA VALIDACION
			
	LET  cTipoEdoCta = SUBSTR(cNUMCUENTA,1,2); 
	
	IF   cTipoEdoCta != '61' AND cTipoEdoCta != '63' THEN  --CREDITO
		--PARA 60
		SELECT NVL(COUNT(num_credito),0) into iexiste FROM bdicred:sd_maecred WHERE num_credito = cNUMCUENTA ;
		IF iexiste  = 0 THEN 
			LET cCodRet = "00046";
			RETURN  cCodRet,dFecha,cDescripcion, decImporte, dFechaMovimiento,cFolio;
		END IF;
	ELIF cTipoEdoCta = '61'   THEN  --REESTRUCTURA
		SELECT NVL(COUNT(num_credito),0) into iexiste FROM bdicred:sd_maecredcrd WHERE num_credito  = cNUMCUENTA;
		IF iexiste  = 0 THEN 
			LET cCodRet = "00046";
			RETURN  cCodRet,dFecha,cDescripcion, decImporte, dFechaMovimiento,cFolio;
		END IF;
	ELIF cTipoEdoCta = '63'   THEN  --PRESTAMO PERSONAL
		SELECT NVL(COUNT(num_credito),0) into iexiste FROM bdicred:sd_maecredcrd WHERE num_credito  = cNUMCUENTA;
		IF iexiste  = 0 THEN 
			LET cCodRet = "00046";
			RETURN  cCodRet,dFecha,cDescripcion, decImporte, dFechaMovimiento,cFolio;
		END IF;
	END IF
	
	IF   cTipoEdoCta != '61' AND  cTipoEdoCta != '63' THEN  --CREDITO
		--PARA FORMAR EL PERIODO SE AGREGA DIA 20 AL MES Y AÑO
		--LET dFechaPeriodo = EXTEND(MDY(SUBSTR(cFECHAEMISION,6,2),20,SUBSTR(cFECHAEMISION,1,4)), YEAR TO SECOND);
		LET dFechaPeriodo = EXTEND(MDY(SUBSTR(cFECHAEMISION,5,2),20,SUBSTR(cFECHAEMISION,1,4)), YEAR TO SECOND);

		SELECT NVL(COUNT(*),0) into iexiste FROM bdicred@pld_tcp:sd_aclaraciones_edocta WHERE num_credito  = cNUMCUENTA AND fecha_emision = dFechaPeriodo;
		IF iexiste  = 0 THEN 
			LET cCodRet = "00058";
			RETURN  cCodRet,dFecha,cDescripcion, decImporte, dFechaMovimiento,cFolio;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH 
		   SELECT SKIP pNumRegistro FIRST pRecuperacion 
		   fecha_aclara,descripcion,importe 
		   INTO dFecha2,cDescripcion,decImporte
		   FROM bdicred@pld_tcp:sd_aclaraciones_edocta
		   WHERE num_credito = cNUMCUENTA
		   AND fecha_emision = dFechaPeriodo
		   ORDER BY secuencia, nlinea
           --2011/05/20

            LET dFecha3 = SUBSTR(dFecha2,1,2)||'/'||SUBSTR(dFecha2,4,2)||'/'||SUBSTR(dFecha2,7,4);
            LET dFecha=dFecha3;
			LET iCont=iCont+1;

			IF dFecha3="01/01/1900" THEN
				LET dFecha="";
			END IF;		
	
			RETURN cCodRet,dFecha,cDescripcion, decImporte, dFechaMovimiento,cFolio WITH resume;
		END FOREACH;
			
		IF iCont = 0 THEN
			LET cCodRet = 1001; 
			RETURN cCodRet,dFecha,cDescripcion, decImporte, dFechaMovimiento,cFolio;
		END IF
		
	ELIF cTipoEdoCta = '61'  OR  cTipoEdoCta = '63' THEN  --REESTRUCTURA Y PRESTAMO PERSONAL
	
		FOREACH
			EXECUTE PROCEDURE bdicred:obtenPeriodos_edocuentacrd (cNUMCUENTA)
			INTO
			cCodRet,cMensaje,cPeriodoAux
		END FOREACH;
	
		--LET dFechaPeriodo = cPeriodoAux;
		
		LET iDia   = DAY(cPeriodoAux);
		LET iMes   = MONTH(cPeriodoAux);
		LET iAnio  = YEAR(cPeriodoAux);
		
		--LET dFechaPeriodo = EXTEND(MDY(MONTH(cPeriodoAux),DAY(cPeriodoAux),YEAR(cPeriodoAux)), YEAR TO SECOND);
		
--		LET dFechaPeriodo = EXTEND(MDY(SUBSTR(cFECHAEMISION,6,2),DAY(cPeriodoAux),SUBSTR(cFECHAEMISION,1,4)), YEAR TO SECOND);
        LET dFechaPeriodo = EXTEND(MDY(SUBSTR(cFECHAEMISION,5,2),DAY(cPeriodoAux),SUBSTR(cFECHAEMISION,1,4)), YEAR TO SECOND);  

		SELECT NVL(COUNT(*),0) into iexiste FROM bdicred:sd_aclaraciones_edoctacrd WHERE num_credito  = cNUMCUENTA AND fecha_emision = dFechaPeriodo;
		IF iexiste  = 0 THEN 
			LET cCodRet = "00058";
			RETURN  cCodRet,dFecha,cDescripcion, decImporte, dFechaMovimiento,cFolio;
		END IF;

		
		SET ISOLATION TO DIRTY READ;
		
		FOREACH 
		   SELECT SKIP pNumRegistro FIRST pRecuperacion 
		   fecha_aclara,descripcion,importe,fecha_mov,folio_suc
		   INTO dFecha,cDescripcion,decImporte,dFechaMovimiento,cFolio
		   FROM bdicred:sd_aclaraciones_edoctacrd
		   WHERE num_credito = cNUMCUENTA
		   AND fecha_emision = dFechaPeriodo
		   ORDER BY secuencia, nlinea
			
			LET iCont = iCont + 1;

			IF dFecha="01/01/1900" THEN
				LET dFecha="";
			END IF;
			
			RETURN cCodRet,dFecha,cDescripcion, decImporte, dFechaMovimiento,cFolio WITH resume;
			
		END FOREACH;
		
		IF iCont = 0 THEN
			LET cCodRet = 1001; 
			RETURN cCodRet,dFecha,cDescripcion, decImporte, dFechaMovimiento,cFolio;
		END IF
		
	END IF		

END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la información de los Movimientos en proceso de aclaración para el o los Estados de Cuenta de Crédito, dependiendo del periodo consultado.  ",
"El SP obtiene la información de  la Base de Datos central de Informix, enviando como parámetro el Número de Cuenta y la Fecha de Emisión a consultar. ",
"FECHA : 27-02-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_relacion_carteractes_rgh(pTpoProceso CHAR(1))
	
	RETURNING 	
			CHAR(6)    AS COD_RET,
			CHAR(80)   AS DESCRIPCION;

	---DECLARACION DE VARIABLES.
	DEFINE iSqlErr              INTEGER;
	DEFINE iIsamErr             INTEGER;
	DEFINE iCont	            INTEGER;	
	DEFINE cErrorInfo           CHAR(80);
	DEFINE cCodRet              CHAR(6);
	DEFINE cMensajeRet          CHAR(80);		
	DEFINE iCantEjecucion       INTEGER;
	DEFINE cNumCte		        CHAR(20);		
	DEFINE cNumCteAdi	        CHAR(20);		
	DEFINE cNumCteRef           CHAR(20);		
	DEFINE cNumCteRefAdi        CHAR(20);		
	DEFINE cTipoRel		        CHAR(1);		
	DEFINE sCommit              SMALLINT;	
	DEFINE cValor     			CHAR(100);
	DEFINE cValorRel     			CHAR(100);
	DEFINE cValorSep     			CHAR(100);
	DEFINE cBand				CHAR(1);
	---INICIALIZACION DE VARIABLES.
	LET iSqlErr                 = 0;
	LET iIsamErr                = 0;
	LET iCont	                = 0;	
	LET cErrorInfo              = '';
	LET cCodRet                 = '000000';
	LET cMensajeRet             = 'PROCESO EXISTOSO';		
	LET iCantEjecucion          = 0;
	LET cNumCte		            = '';
	LET cNumCteAdi	            = '';
	LET cNumCteRef	            = '';
	LET cNumCteRefAdi	        = '';
	LET cTipoRel	            = '0';		
	LET sCommit          		= 0;			
	LET cValor        			= '';  
	LET cValorRel        			= '';  
	LET cValorSep       			= '';  
	LET cBand					= '0';
    
	BEGIN
		
		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensajeRet = cErrorInfo;					
				IF (sCommit = -1) THEN
					ROLLBACK WORK;
				END IF;
				RETURN TRIM(cCodRet), TRIM(cMensajeRet);
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--SET DEBUG FILE TO '/respaldosbd/Guadalupe/sp_relacion_carteractes.out';
		--TRACE ON;

		--VALORES QUE PUEDE RECIBIR pTpoProceso.
			-- 0-Sin informacion.
			-- 1-Alta unica.
			-- 2-Alta de cliente.
			-- 3-Todos.		
		
		--SE VALIDA PARAMETRO.
		/*IF NVL(pTpoProceso,'') = '' OR pTpoCte NOT IN ('1','2') OR NVL(pNumRegistro,0) <= 0 THEN 
			LET cCodRet ='000001';
			LET cMensajeRet = 'PARAMETROS DE ENTRADA INVALIDOS, VERIFIQUE';				
			RETURN TRIM(cCodRet), TRIM(cMensajeRet);		
		END IF;

		SELECT  valor 
		INTO cValorRel
		FROM bdicobranza:"informix".cb_param 
		WHERE empresa = '001' AND descripcion = 'REP_TIPO_RELACION'
			AND cod_param = 43;
			
			
		SELECT  valor 
		INTO cValorSep
		FROM bdicobranza:"informix".cb_param 
		WHERE empresa = '001' AND descripcion = 'REP_TIPO_RELACION'
			AND cod_param = 44;
		*/
		IF pTpoProceso ='1' THEN  ---Solo procesa registros de Alta unica
		 --SE CONSULTA SI ES CTE DE ALTA UNICA.
				FOREACH WITH HOLD
				
					SELECT cte.numcte,cte.numcte_ref
					INTO cNumCteAdi, cNumCteRefAdi
					FROM "informix".si_adiccoppel adic,
					"informix".si_ctes_coppel cte 
					WHERE  cte.numcte_ref = adic.numctecoppel
					AND cte.numcte =adic.numcte
					AND cte.bctecoppel = '1'
					AND cte.altaunica = 0
					AND adic.tipotar= '1'
					
					IF (sCommit = 0) THEN
						BEGIN WORK;
						LET iCont = 0;
						LET sCommit = -1;
					END IF; 
					
					--SE INSERTA EL REGISTRO DE LA RELACION.
					INSERT INTO "informix".si_relacion_ctebcplcpl 
					(empresa,numcte_banco,cliente,numempleado,tipo_relacion,definicion,status,tipo_re_ini,fecha_insert)
					VALUES ('001',cNumCteAdi,cNumCteRefAdi,'informix','1',cValor,'1',0,TODAY);
					
					UPDATE "informix".si_ctes_coppel SET altaunica = 1 
					WHERE numcte = cNumCteAdi AND numcte_ref = cNumCteRefAdi;
					/*
					LET cTipoRel = '';					
					
					LET iCont = iCont  + 1;			
				
					IF (iCont >= 25000) THEN
						COMMIT WORK;	
						LET iCont = 0;
						BEGIN WORK;
					END IF;
					
					LET iCantEjecucion = iCantEjecucion + 1;
					
					IF iCantEjecucion = pNumRegistro THEN
						EXIT FOREACH;
					END IF
					*/
				END FOREACH;	
		
		--ELIF pTpoProceso = '2' THEN  ---SOLO PROCESA REGISTROS DE ALTA CLIENTE
			
			FOREACH	WITH HOLD	

					SELECT {+INDEX("informix".si_ctes_coppel ix_ctes_coppel5)} numcte,numcte_ref 
					INTO cNumCte,cNumCteRef
					FROM "informix".si_ctes_coppel 
					WHERE empresa = '001'
					AND bctecoppel = '1'
					AND altaunica = 0
						
					IF (sCommit = 0) THEN
						BEGIN WORK;
						LET iCont = 0;
						LET sCommit = -1;
					END IF; 
					
					--SE INSERTA EL REGISTRO DE LA RELACION.
					INSERT INTO "informix".si_relacion_ctebcplcpl 
					(empresa,numcte_banco,cliente,numempleado,tipo_relacion,definicion,status,tipo_re_ini,fecha_insert)
					VALUES ('001',cNumCte,cNumCteRef,'informix','2',cValor,'1',0,TODAY);					
					
					UPDATE "informix".si_ctes_coppel SET altaunica = 2 
					WHERE numcte = cNumCte AND numcte_ref = cNumCteRef;
					
					/*
					LET cTipoRel = '';
					
					LET iCont = iCont  + 1;			
				
					IF (iCont >= 25000) THEN
						COMMIT WORK;	
						LET iCont = 0;
						BEGIN WORK;
					END IF;
					
					LET iCantEjecucion = iCantEjecucion + 1;
					
					IF iCantEjecucion = pNumRegistro THEN
						EXIT FOREACH;
					END IF
					*/
			END FOREACH;
		END IF;
			
		--ELSE--0, y 3 --PROCESA CLIENTES SIN INFORMACION Y TODOS.
		--CICLO PARA OBTENER LOS DETALLES DE MOVIMIENTOS DEL DIA.
		/*	FOREACH	WITH HOLD	

		SELECT cte.numcte,cte.numcte_ref 
				INTO cNumCte,cNumCteRef
				FROM bdinteg:"informix".si_cliente cte 
				WHERE cte.empresa = '001' 				
					AND cte.numcte NOT IN(SELECT numcte_banco FROM bdinteg:"informix".si_relacion_ctebcplcpl
										  WHERE numcte_banco = cte.numcte)
					AND cte.tipo_cliente = pTpoCte
					AND NVL(cte.numcte_ref,'')  = CASE WHEN pTpoProceso = '0' THEN '' ELSE NVL(cte.numcte_ref,'') END 
							
				IF pTpoProceso ='3' THEN --PROCESA TODOS.
					--SE CONSULTA SI ES CTE DE ALTA UNICA.
					SELECT numcte,numctecoppel
					INTO cNumCteAdi, cNumCteRefAdi
					FROM bdinteg:"informix".si_adiccoppel
					WHERE numcte = cNumCte
						AND numctecoppel = numctecoppel
						AND secuencia = 1;
						
						LET cBand = '1';
						LET cValor = cValorRel;
						--ALTA UNICA
						IF NVL(cNumCteRefAdi,'') <> '' AND NVL(cNumCteRef,'') = NVL(cNumCteRefAdi,'') THEN
							LET cTipoRel = '1';																
							LET cNumCte = cNumCteAdi;
							LET cNumCteRef = cNumCteRefAdi;
						ELIF NVL(cNumCteRefAdi,'') = '' AND NVL(cNumCteRef,'') <>'' THEN--Alta de Cliente 
							LET cTipoRel = '2';														
						ELSE 
							LET cTipoRel = '0';
							LET cBand = '0';
							LET cValor = cValorSep;									
						END IF;
						
				ELSE
					LET cTipoRel = '0';							
					LET cBand = '0';
					LET cValor = cValorSep;
				END IF;			
							
				
				IF (sCommit = 0) THEN
					BEGIN WORK;
					LET iCont = 0;
					LET sCommit = -1;
				END IF; 
						
							
				--SE INSERTA EL REGISTRO DE LA RELACION.
				INSERT INTO bdinteg:"informix".si_relacion_ctebcplcpl 
				(empresa,numcte_banco,cliente,numempleado,tipo_relacion,definicion,status,tipo_re_ini,fecha_insert)
				VALUES ('001',cNumCte,cNumCteRef,'informix',cTipoRel,cValor,cBand,0,TODAY);					
													
				LET cTipoRel = '';
				
											
				LET iCont = iCont  + 1;			
			
				IF (iCont >= 25000) THEN
					COMMIT WORK;	
					LET iCont = 0;
					BEGIN WORK;
				END IF;
				
				LET iCantEjecucion = iCantEjecucion + 1;
				
				IF iCantEjecucion = pNumRegistro THEN
					EXIT FOREACH;
				END IF			
							
			END FOREACH
		END IF;
		*/
		IF iCantEjecucion = 0 THEN		
			LET cCodRet ='000002';
			LET cMensajeRet = 'NO SE ENCONTRARON DATOS PARA PROCESAR';		
			IF sCommit = -1 THEN
				COMMIT WORK;
		    END IF;
			LET sCommit = 0;
			RETURN TRIM(cCodRet), TRIM(cMensajeRet);
		ELSE
			IF sCommit = -1 THEN
				COMMIT WORK;
		    END IF;
			LET sCommit = 0;
			--SE OPTIMIZA PARA SU MEJOR PROCESAMIENTO LA TABLA DE INSERCION.	
			UPDATE STATISTICS MEDIUM FOR TABLE bdinteg:"informix".si_relacion_ctebcplcpl;
			RETURN TRIM(cCodRet), TRIM(cMensajeRet);
		END IF;											  				   				
	END;
	
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento que recorre la cartera de la "bdinteg:si_cliente" con los existentes en la',
'             tabla "bdinteg:si_adiccoppel" para que estos sean insertados en la tabla .bdinteg:si_relacion_ctebcplcpl.',
'             con un tipo de relación por .Alta Única.. De igual forma este proceso debe de insertar los clientes ya',
'             existentes en la tabla .bdinteg:si_cliente. y que ya cuenten con un numero de referencia (Ya es Cliente Coppel)',
' 			  se deben de insertar con un tipo de relación .Alta de Cliente. en la tabla .bdinteg:si_relacion_ctebcplcpl..',
'			  Al igual que los clientes existentes en la tabla .bdinteg:si_cliente pero que no cuentan con un numero de referencia',
'             (No Cuentan con Numero de Cliente Coppel), deberán ser insertados en la tabla .bdinteg:si_relacion_ctebcplcpl. pero',
'			  con una relación .Sin Información..', 
'AUTOR: Guadalupe Payan',
'FECHA DE CREACION: 14 de Agosto de 2012',
'VERSION: 20120814.1232',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_actstatenviocpel(pNum_sol CHAR(20), pNuevo_estatus CHAR(1))
	RETURNING 
			CHAR(5)		AS Cod_ret,
			CHAR(80)	AS Mensaje_ret;
		
	---DECLARACIONES
    DEFINE iSqlErr						INTEGER;
    DEFINE iIsamErr						INTEGER;
    DEFINE vErrorInfo					VARCHAR(80);
    DEFINE cCodRet						CHAR(5);
	DEFINE cMensajeRet     				CHAR(80);
	DEFINE cEstatus						CHAR(2);	
	---INICIALIZACIONES
	LET iSqlErr						= 0;
	LET iIsamErr					= 0;
	LET vErrorInfo					= '';
	LET cCodRet						= '00000';
	LET cMensajeRet					= 'PROCESO EXITOSO';
	LET cEstatus					= '';
		
	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, vErrorInfo
		   IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensajeRet = TRIM(NVL(vErrorInfo,''));
				RETURN TRIM(cCodRet),NVL(cMensajeRet,'');				
		   END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
    
		--SET DEBUG FILE TO '/home/sysifx/respaldosbd/josue/sp_actstatenviocpel';
		--TRACE ON;
	
		-- VALIDA QUE LOS PARAMETROS NO VENGAN VACIOS	
		IF TRIM(NVL(pNum_sol,'')) = '' OR TRIM(NVL(pNuevo_estatus,'')) = '' THEN
			LET cCodRet = '00001';
			LET cMensajeRet = 'PARÁMETROS VACÍOS';			
			-- SI LOS PARAMETROS TRAEN INFORMACIÓN SE BUSCA EL ESTATUS DE LA SOLICITUD Y VALIDA SI PUEDE CAMBIAR O NO SU ESTATUS.
		ELSE
			SELECT  status_solicitud
			INTO  	cEstatus
			FROM bdisolic:"informix".ss_solicitudes
			WHERE	 num_solicitud = pNum_sol;			
			IF cEstatus NOT IN("PC", "AN") THEN			
				IF pNuevo_estatus = '1' OR pNuevo_estatus ='2' THEN
			
					UPDATE bdisolic:"informix".ss_solicitudes
					SET envio_coppel = pNuevo_estatus
					WHERE num_solicitud = pNum_sol;					
				ELSE
					LET cCodRet		= '00002';
					LET cMensajeRet	= 'LA SOLICITUD NO PUEDE SER PROCESADA';
				END IF;
			ELSE
				LET cCodRet		= '00003';
				LET cMensajeRet	= 'ESTATUS INCORRECTO';
			END IF;				
		END IF;	
		RETURN TRIM(cCodRet),NVL(cMensajeRet,'');		
	END;
	
END PROCEDURE
DOCUMENT
'DESCRIPCION:Procedimiento que realiza la actualización del campo bdisolic: ss_solicitudes envio_coppel al status requerido.', 
'AUTOR: Josué Remberto Zazueta Acosta ',
'FECHA: 23 de Julio del 2012',
'BD   : bdisolic',
'VERSION: 20120723.1015';

CREATE PROCEDURE "informix".sp_consenvioscoppel(pNumero CHAR(20))
	RETURNING 
			 CHAR(5)			AS cod_ret,			
			 VARCHAR(80)		AS mensaje_ret,
			 CHAR (350)  		AS cad1;
			
	---DECLARACIONES
    DEFINE iSqlErr						INTEGER;
    DEFINE iIsamErr						INTEGER;
    DEFINE vErrorInfo					VARCHAR(80);
    DEFINE cCodRet						CHAR(5);
	DEFINE vMensajeRet     				VARCHAR(80);
	DEFINE cNumero_sol					CHAR(20);
	DEFINE cNombre1						CHAR(26);		
	DEFINE cNombre2						CHAR(26);
	DEFINE cApell_paterno				CHAR(26);	
	DEFINE cApell_materno				CHAR(26);
    DEFINE cFecha_nac 					CHAR(10);
	DEFINE cFecha_alta_sol				CHAR(10);
	DEFINE cNumcte						CHAR(20);
	DEFINE cEnvio						CHAR(1);
	DEFINE cCad1                       	CHAR (350);	
	---INICIALIZACIONES
	LET iSqlErr						= 0;
	LET iIsamErr					= 0;
	LET vErrorInfo					= '';
	LET cCodRet						= '00000';
	LET vMensajeRet					= 'PROCESO EXITOSO';
	LET cNumero_sol					= '';
	LET cNombre1					= '';
	LET cNombre2					= '';
	LET cApell_paterno				= '';
	LET cApell_materno				= '';
	LET cFecha_nac					= '1900/01/01';
	LET cFecha_alta_sol				= '1900/01/01';
	LET	cNumcte						= '';
	LET cEnvio						= '';
	LET cCad1 						= '';		
	
	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, vErrorInfo
		   IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;
				LET vMensajeRet = TRIM(NVL(vErrorInfo,''));
				RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(vMensajeRet,'')),TRIM(NVL(cCad1,''));			
		   END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;    
		
		--SET DEBUG FILE TO '/home/sysifx/respaldosbd/josue/sp_consenvioscoppel';
		--TRACE ON;	
	    
		LET cNumero_sol =  TRIM(NVL(pNumero,''));				
		-- SI LOS PARAMETROS TRAEN INFORMACIÓN SE BUSCA LA INFORMACIÓN PERSONAL DEL CLIENTE SOLICITANTE Y SE REGRESA
		-- SI NO TRAE TODAS LAS SOLICITUDES QUE SU CAMPO envio_coppel= 1   		
		IF cNumero_sol <> '' THEN		
			
			SELECT envio_coppel, fecha_insert,numcte
			INTO cEnvio, cFecha_alta_sol,cNumcte
			FROM bdisolic:"informix".ss_solicitudes
			WHERE	 num_solicitud = pNumero
				AND tipo_solicitud='C';	
				
			IF NVL(cEnvio,'0') = '1' THEN
				
				SELECT a.nombre1, a.nombre2, a.apell_paterno, a.apell_materno, b.fecha_nac 
				INTO cNombre1, cNombre2, cApell_paterno, cApell_materno, cFecha_nac 
				FROM  bdinteg:"informix".si_cliente a,  
					  bdinteg:"informix".si_ctepf b
				WHERE a.numcte = cNumcte
					AND a.numcte = b.numcte;	
					
					LET cNombre1 = REPLACE (REPLACE (cNombre1,'Ñ','#'),'ñ','#');
					LET cNombre2 = REPLACE (REPLACE (cNombre2,'Ñ','#'),'ñ','#');
					LET cApell_paterno = REPLACE(REPLACE (cApell_paterno,'Ñ','#'),'ñ','#');
					LET cApell_materno = REPLACE(REPLACE (cApell_materno,'Ñ','#'),'ñ','#');
					
				LET cCad1 = 
					"90"||"|"||"0026"||"|"||"0"||"|"|| TRIM(NVL(cNumero_sol,'')) ||"|"||
					TRIM(NVL(cNombre1,'')) ||"|"||TRIM(NVL(cNombre2,'')) ||"|"|| 
					TRIM(NVL(cApell_paterno,'')) ||"|"||TRIM(NVL(cApell_materno,'')) ||"|"|| 
					TRIM(NVL(cFecha_nac,'1900/01/01')) ||"|"||TRIM(NVL(cFecha_alta_sol,'1900/01/01'))||"|";					
				RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(vMensajeRet,'')),TRIM(NVL(cCad1,''));				
				
			ELSE
			
				LET cCodRet = '00001';
				LET vMensajeRet = 'SOLICITUD CONSULTADA NO ES APTA PARA ENVÍO A COPPEL';
				LET cNumero_sol='';							  
				RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(vMensajeRet,'')),TRIM(NVL(cCad1,''));						
				
			END IF;
		ELSE 		
			FOREACH
			
					SELECT  fecha_insert,numcte,num_solicitud
					INTO cFecha_alta_sol,cNumcte,cNumero_sol
					FROM bdisolic:"informix".ss_solicitudes
					WHERE  status_solicitud NOT IN("PC", "AN")
						AND  envio_coppel = '1'
						
					SELECT a.nombre1, a.nombre2, a.apell_paterno, a.apell_materno, b.fecha_nac 
					INTO cNombre1, cNombre2, cApell_paterno, cApell_materno, cFecha_nac 
					FROM  bdinteg:"informix".si_cliente a,  bdinteg: "informix".si_ctepf b
					WHERE a.numcte = cNumcte
						AND a.numcte = b.numcte;
					
					LET cNombre1 = REPLACE (REPLACE (cNombre1,'Ñ','#'),'ñ','#');
					LET cNombre2 = REPLACE (REPLACE (cNombre2,'Ñ','#'),'ñ','#');
					LET cApell_paterno = REPLACE(REPLACE (cApell_paterno,'Ñ','#'),'ñ','#');
					LET cApell_materno = REPLACE(REPLACE (cApell_materno,'Ñ','#'),'ñ','#');
					
					LET cCad1 =  
							"|"||"#90"||"|"||"0026"||"|"||"0"||"|"|| TRIM(NVL(cNumero_sol,'')) ||"|"||
							TRIM(NVL(cNombre1,'')) ||"|"||TRIM(NVL(cNombre2,'')) ||"|"|| 
							TRIM(NVL(cApell_paterno,'')) ||"|"||TRIM(NVL(cApell_materno,'')) ||"|"|| 
							TRIM(NVL(cFecha_nac,'1900/01/01')) ||"|"||TRIM(NVL(cFecha_alta_sol,'1900/01/01'))||"|";					
					
					RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(vMensajeRet,'')),TRIM(NVL(cCad1,'')) WITH RESUME;					
					
			END FOREACH;
		END IF;
	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Creación de un procedimiento nuevo el cual consulta y regresa la información necesaria para el envió a Coppel de todas las solicitudes Coppel listas para el envió', 
'AUTOR: Josué Remberto Zazueta Acosta ',
'FECHA: 20 de Julio del 2012',
'BD   : bdisolic',
'VERSION: 20120720.1115';

CREATE PROCEDURE "informix".sp_consultactesrelacionados(pEmpresa CHAR(3), pNumCteBanco CHAR(20))

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5)  AS CodigoRetorno,
	CHAR(20) AS NumCteCoppel;

	DEFINE iSql_err	  INTEGER;
	DEFINE cCodRet	  CHAR(5);
	DEFINE cNumCteCPL CHAR(20);
	
	LET iSql_err	= 0;
	LET cCodRet		= '00000';
	LET cNumCteCPL	= '';

	--SET DEBUG FILE TO "/respaldosbd/Daniela/sp_consultactesrelacionados.out";
	--TRACE ON;
	
	BEGIN
	
		ON EXCEPTION SET iSql_err
		
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
				RETURN  cCodRet, cNumCteCPL;
			END IF;
			
		END EXCEPTION;
		
		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pNumCteBanco IS NULL OR pNumCteBanco = '' OR pEmpresa IS NULL OR pEmpresa = '' THEN
			LET cCodRet = '00001';
		ELSE
			IF EXISTS (SELECT numcte_banco FROM bdinteg:"informix".si_relacion_ctebcplcpl WHERE numcte_banco = TRIM(pNumCteBanco)) THEN
				SELECT TRIM(cliente)
				INTO cNumCteCPL
				FROM bdinteg:"informix".si_relacion_ctebcplcpl 
				WHERE empresa = pEmpresa
				AND numcte_banco = TRIM(pNumCteBanco);
				
				IF cNumCteCPL = "" OR cNumCteCPL IS NULL THEN
					LET cCodRet = '00001';
				END IF;
				
			ELSE
				LET cCodRet = '00001';
			END IF;
		END IF;
		
		RETURN  cCodRet, cNumCteCPL;
	END
	
END PROCEDURE

DOCUMENT
'Consulta si existe relacion de un cliente Bancoppel con un numero de cliente Coppel',
'Autor :Daniela Ramírez',
'FECHA : 19/Septiembre/2012',
'BD: bdinteg',
'Valida que el campo cliente de la tabla si_relacion_ctebcplcpl, no este vacio o sea nulo',
'Autor :Rodolfo Tortolero',
'FECHA : 03/Enero/2013',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_actdepctesbcplcpl(pEmpresa CHAR(3))

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5)  AS CodigoRetorno;

	DEFINE iSql_err	  	INTEGER;
	DEFINE cCodRet		CHAR(5);
	DEFINE cNumCte		CHAR(20);
	DEFINE cValorCte	CHAR(1);
	DEFINE cValorLimpio	CHAR(1);
	
	LET iSql_err	= 0;
	LET cCodRet		= '00000';
	LET cNumCte		= '';
	LET cValorCte	= '';
	LET cValorLimpio = '';

	--SET DEBUG FILE TO "/respaldosbd/Daniela/sp_actdepctesbcplcpl.out";
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
				RETURN  cCodRet WITH RESUME;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pEmpresa IS NULL OR pEmpresa = '' THEN
			LET cCodRet = '00001';
			RETURN cCodRet WITH RESUME;
		ELSE
			FOREACH
				--NOTA:
				--bctecoppel = 0: El cliente coppel no se encuentra en la base de datos de Coppel
				--bctecoppel = 1: El cliente coppel se encuentra en la base de datos de Coppel
				--bctecoppel = 2: Se actualizó registros a cValorLimpio para borrar relacion entre clientes BCPL-CPL
			
				SELECT TRIM(numcte), TRIM(bctecoppel)
				INTO cNumCte, cValorCte 
				FROM "informix".si_ctes_coppel 
				WHERE empresa = pEmpresa 
				AND bctecoppel = "0"
				
				IF cValorCte = "0" THEN
					
					IF EXISTS (SELECT numcte FROM "informix".si_cliente WHERE empresa = pEmpresa AND numcte = cNumCte) THEN
						UPDATE "informix".si_cliente 
						SET numcte_ref = cValorLimpio 
						WHERE empresa = pEmpresa
						AND numcte = cNumCte;
						/*
						IF EXISTS (SELECT numcte_banco FROM "informix".si_relacion_ctebcplcpl WHERE empresa = pEmpresa AND numcte_banco = cNumCte) THEN
							UPDATE "informix".si_relacion_ctebcplcpl
							SET cliente = cValorLimpio
							WHERE empresa = pEmpresa
							AND numcte_banco = cNumCte;
						END IF
						
						IF EXISTS (SELECT numcte FROM "informix".si_ctes_coppel WHERE empresa = pEmpresa AND numcte = cNumCte AND bctecoppel = "0") THEN
							UPDATE "informix".si_ctes_coppel
							SET bctecoppel = "2"
							WHERE empresa = pEmpresa
							AND numcte = cNumCte
							AND bctecoppel = "0";
						END IF
						*/
					END IF
				END IF;
				
				CONTINUE FOREACH;
				
			END FOREACH;

			RETURN cCodRet WITH RESUME;
			
		END IF;
		
	END
END PROCEDURE
DOCUMENT
'Conocer si el cliente coppel registrado como referencia de un cliente Bancoppel',
'se encuentra o no en la base de datos de Coppel',
'Autor :Daniela Ramírez',
'FECHA : 25/Septiembre/2012',
'BD: bdinteg';

CREATE PROCEDURE "informix".cteppes(pempresa 	      CHAR(3),
                                    pfuncion 	      CHAR(1),
					                pnumcte           CHAR(20),
					                ptipo_ppes        CHAR(1),
					                ppuesto_ppes      CHAR(2),
					                papell_paterno    CHAR(26),
					                papell_materno    CHAR(26),
					                pnombre1          CHAR(26),
					                pnombre2          CHAR(26),
					                pparticipacion    DECIMAL(14,2),
					                pdomicilio        CHAR(80),
					                ptelefono         CHAR(20),
					                puser_insert      CHAR(8),
					                pfecha_insert     DATE,
                                    pasociacion       CHAR(40),
					                pnumeroregistro   INTEGER)
RETURNING CHAR(5);

DEFINE vcodret            CHAR(5);
DEFINE vfecha             DATE;
--DEFINE vsignumcte         INT;
DEFINE vexiste            CHAR(1);
--DEFINE vempresa           CHAR(3);
--DEFINE vsucursal          CHAR(4);
--DEFINE vejecutivo         CHAR(8);
--DEFINE vejecut_autoriza   CHAR(8);
--DEFINE vtp_persona        CHAR(2);
--DEFINE vtp_cliente        CHAR(1);
DEFINE vnumcte 		      CHAR(20);
--DEFINE vtipo_ppes         CHAR(1);
--DEFINE vpuesto_ppes       CHAR(2);
--DEFINE vpaterno 	        CHAR(26);
--DEFINE vmaterno 	        CHAR(26);
--DEFINE vnombre1 	        CHAR(26);
--DEFINE vnombre2 	        CHAR(26);
--DEFINE vparticipacion     DECIMAL(14,2);
--DEFINE vdomicilio         CHAR(80);
--DEFINE vtelefono          CHAR(20);
--DEFINE vuser_insert       CHAR(8);
--DEFINE vfecha_insert      DATE;
DEFINE vnumeroregistro    INTEGER;
DEFINE vsqlerr,visamerr   INTEGER;

LET vfecha           = "";
--LET vsignumcte       = 0;
LET vexiste          = "";
--LET vempresa         = "";
--LET vsucursal        = "";
--LET vejecutivo       = "";
--LET vejecut_autoriza = "";
--LET vtp_persona      = "";
--LET vtp_cliente      = "";
LET vnumcte          = "";
--LET vtipo_ppes       = "";
--LET vpuesto_ppes     = "";
--LET vpaterno         = "";
--LET vmaterno         = "";
--LET vnombre1         = "";
--LET vnombre2         = "";
--LET vparticipacion   = "";
--LET vdomicilio       = "";
--LET vtelefono        = "";
--LET vuser_insert     = "";
--LET vfecha_insert    = "";
LET vnumeroregistro  = 0;


LET vcodret          = "000";
--LET vempresa = pempresa;
--LET vexiste = "";


	-- SET DEBUG FILE TO "/tmp/cteppes.out";
	-- TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;


BEGIN
ON EXCEPTION SET vsqlerr,visamerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      RETURN vcodret;
   END IF;
END EXCEPTION;

SELECT fecha_hoy INTO vfecha
   FROM bdinteg:"informix".si_fechas
   WHERE empresa = pempresa;

   --alida datos Nulos
   IF pnumcte IS NULL OR pnumcte = " " THEN
      LET vcodret = "104";
      RETURN vcodret;
   END IF


   SELECT 1 INTO vexiste FROM bdinteg:"informix".si_cliente
      WHERE numcte = pnumcte AND empresa = pempresa;
   IF vexiste IS NULL THEN
      LET vcodret="104";
      RETURN vcodret;
   END IF;

   IF ptipo_ppes IS NULL OR ptipo_ppes = " " THEN
      LET vcodret = "302";
      RETURN vcodret;
   END IF

   IF ppuesto_ppes IS NULL OR ppuesto_ppes = " " THEN
      LET vcodret = "300";
      RETURN vcodret;
   END IF

   SELECT 1 INTO vexiste
     FROM bdinteg:"informix".si_puestosppes
    WHERE empresa=pempresa AND puesto_ppes = ppuesto_ppes;
   IF vexiste IS NULL THEN
      LET vcodret="300";
      RETURN vcodret;
   END IF;

   SELECT 1 INTO vexiste
     FROM bdinteg:"informix".si_empresas
    WHERE empresa=pempresa;
   IF vexiste IS NULL THEN
      LET vcodret="301";
      RETURN vcodret;
   END IF;

   SELECT 1 INTO vexiste
     FROM bdinteg:"informix".si_ejecut
    WHERE empresa= pempresa AND ejecutivo = puser_insert;
   IF vexiste IS NULL THEN
      LET vcodret="112";
      RETURN vcodret;
   END IF;

-- ****************** Actualizacion de Parametros *****************
IF pfuncion="A" THEN

   SELECT MAX(numeroregistro) + 1
     INTO vnumeroregistro
     FROM bdinteg:"informix".si_cteppes
    WHERE empresa = pempresa AND numcte = pnumcte;

   IF vnumeroregistro IS NULL THEN
      LET vnumeroregistro = 1;
   END IF


   BEGIN
      INSERT INTO bdinteg:"informix".si_cteppes
         (empresa,		numcte,		tipo_ppes, 	puesto_ppes,
	  apell_paterno, 	apell_materno,	nombre1,	nombre2,
	  participacion,	domicilio,	telefono,	user_insert,
	  fecha_insert,		numeroregistro,  asociacion_civil)
      VALUES
         (pempresa,		pnumcte,	ptipo_ppes, 	ppuesto_ppes,
	  papell_paterno, 	papell_materno,	pnombre1,	pnombre2,
	  pparticipacion,	pdomicilio,	ptelefono,	puser_insert,
	  pfecha_insert, vnumeroregistro,  pasociacion);
   END;
   RETURN vcodret;

ELSE

   SELECT 1 INTO vexiste FROM bdinteg:"informix".si_cteppes
      WHERE numcte = vnumcte AND empresa = pempresa AND numeroregistro = pnumeroregistro;
   IF vexiste IS NULL THEN
      --LET vcodret="303";
      --RETURN vcodret;
	  SELECT MAX(numeroregistro) + 1
      INTO vnumeroregistro
      FROM bdinteg:"informix".si_cteppes
      WHERE empresa = pempresa AND numcte = pnumcte;

	   IF vnumeroregistro IS NULL THEN
		  LET vnumeroregistro = 1;
	   END IF

	   BEGIN
		  INSERT INTO bdinteg:"informix".si_cteppes
			(empresa,		numcte,		tipo_ppes, 	puesto_ppes,
		  apell_paterno, 	apell_materno,	nombre1,	nombre2,
		  participacion,	domicilio,	telefono,	user_insert,
		  fecha_insert,		numeroregistro,  asociacion_civil)
		  VALUES
			 (pempresa,		pnumcte,	ptipo_ppes, 	ppuesto_ppes,
		  papell_paterno, 	papell_materno,	pnombre1,	pnombre2,
		  pparticipacion,	pdomicilio,	ptelefono,	puser_insert,
		  pfecha_insert, vnumeroregistro,  pasociacion);
	   END;
	   RETURN vcodret;
	  
   END IF;

   BEGIN
      UPDATE bdinteg:"informix".si_cteppes
 	 SET(tipo_ppes,		puesto_ppes,	apell_paterno,	apell_materno,
 	     nombre1,		nombre2,   	participacion,	domicilio,
 	     telefono,	 	user_insert,	fecha_insert,  asociacion_civil)
	   =
 	    (ptipo_ppes,	ppuesto_ppes,	papell_paterno,	papell_materno,
 	     pnombre1,		pnombre2,   	pparticipacion,	pdomicilio,
 	     ptelefono,	 	puser_insert,		pfecha_insert,   pasociacion)
       WHERE empresa = pempresa AND numcte = pnumcte AND numeroregistro = pnumeroregistro;
   END;

END IF;
RETURN vcodret;
END;
END PROCEDURE
DOCUMENT
"Alta y Cambio de Personas Politicamente",
"AutOR : Procesamiento Interactivo S.A. de C..",
"MODIFICO : Victor Luna",
"FECHA : 17/Octubre/2006",
"BD    : bdinteg",
"VER   : 1.1",
"MODIFICO : Felipe Urias",
"FECHA : 30/Agosto/2012",
"Se Agregan Reglas de Informix, se agrega insert en caso",
"De Realizar un mantenimiento que no tubiese registro de",
"ppes";

CREATE PROCEDURE "informix".sp_buscar_movimientos_inversion_his2(p_sNumeroCuenta CHAR(30), p_sFechaInicial DATE, p_sFechaFinal DATE, p_sMonto money(14,2), p_skip INT, ids_transacciones lvarchar, p_sNumeroEmpresa CHAR(3))

     RETURNING	DATE AS fechaMovimiento;
	-- Definicion de variables	    
	DEFINE resultado_fechaMovimiento    DATE;
	DEFINE resultado_monto				money(16,2);
	DEFINE resultado_horaMovimiento		DATETIME HOUR TO FRACTION(3);
	DEFINE resultado_folioSuc			CHAR(30);
    DEFINE resultado_sucursal			CHAR(4);
    DEFINE resultado_nombre             CHAR(30);
    DEFINE resultado_claveTipo          CHAR(5);
    DEFINE resultado_tipo   			CHAR(40);
    DEFINE resultado_reversado   		CHAR(1);
    DEFINE transacciones 				LIST(CHAR(4) NOT NULL);
    DEFINE iSqlErr                      INTEGER;
	 
     -- InicializaciÃ³n de las variables.
	LET resultado_fechaMovimiento 		= '';
	LET resultado_monto 				= '';
	LET resultado_horaMovimiento 		= TO_DATE("00:00","%H:%M");
	LET resultado_folioSuc 				= '';
    LET resultado_sucursal 				= '';
    LET resultado_nombre 				= '';
    LET resultado_claveTipo 			= '';
	LET resultado_tipo 					= '';
	LET resultado_reversado 			= '';
	LET transacciones 					= 'LIST{' || ids_transacciones || '}';

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Actualizaciones OptimizaciÃ³n de SPÂ´s II 05/03/2013
-- Cambio para que en un sÃ³lo SP se realicen todas las consultas que correspan.
-- Se cambia el nombre para la identificaciÃ³n correcta de los SPÂ´s del sistema.
-- SADVC 
	
-- SET DEBUG FILE TO "/informix/SD/Optimizacion_sps_root_II/sp_buscar_movimientos_inversion_his2.out";
-- TRACE ON;

    RETURN resultado_fechaMovimiento;
END PROCEDURE;