CREATE PROCEDURE "informix".sp_obtenerctas_cfdi2(pEmpresa CHAR(3), 
									 pNumCte CHAR(20),
									 pCuenta CHAR(20),
									 pTarjeta CHAR(20),
									 pTpo SMALLINT,
									 pLimit INTEGER,
									 pEjecucion INTEGER)	
--DATOS A REGRESAR---
RETURNING CHAR(6)   AS Retorno,  
		  CHAR(20)  AS Cuenta, 
		  CHAR(20)  AS Tarjeta,
		  CHAR(4)   AS Sucursal,   
		  CHAR(40)  AS Producto, 
		  DATE      AS Fech_Alta, 
		  DATE 		AS Fech_Venc,     
		  CHAR(20)  AS Estatus,
		  CHAR(1)  	AS EstatusCFDI,
		  CHAR(10)  AS TelefonoCel,
		  CHAR(30)  AS CompaniaTel,
		  CHAR(100) AS Correo,
		  CHAR(1)   AS ServHistorico,
		  CHAR(1)   AS ServImp,		  
		  INTEGER   AS Tipo,
		  INTEGER   AS iSkip,
		  INTEGER   AS iEjecucion;


		  
	-- DEFINICION DE VARIABLES
	DEFINE cCod_ret      	 CHAR(6);	
    DEFINE cNumCte      	 CHAR(20);
	DEFINE cSucursal    	 CHAR(4);
    DEFINE cProducto    	 CHAR(40);
    DEFINE cCuenta      	 CHAR(20);
    DEFINE cEstatus     	 CHAR(20);
	DEFINE cTarjeta      	 CHAR(20);
	DEFINE sTipo 			 SMALLINT;
	DEFINE iSqlErr      	 INTEGER;
	DEFINE iLimit 			 INTEGER;
	DEFINE iCantReg 		 INTEGER;
	DEFINE iSistema     	 INTEGER;
	DEFINE iTipo			 INTEGER;
	DEFINE iSkip			 INTEGER;
	DEFINE iEjecucion	     INTEGER;
	DEFINE dFecha_alta       DATE;
	DEFINE dFecha_venc  	 DATE;
	DEFINE cEstatusCFDI		CHAR(1);
	DEFINE cTelefono		CHAR(10);
	DEFINE cNomCarrier		CHAR(30);
	DEFINE cCorreo			CHAR(100);	
	DEFINE cHistEnv			CHAR(1);
	DEFINE cStatusServImp	CHAR(1);
	DEFINE cNumeroProdusctosTarjetaCredito CHAR(100);	DEFINE cNumProdTarCre CHAR(100);	DEFINE cQuery CHAR(1500);
	
	--INICIALIZACION DE VARIABLES
	LET cCod_ret     	  = "000000";		
	LET cNumCte    	 	  = "";	
	LET cSucursal    	  = "";
    LET cProducto    	  = "";
    LET cCuenta      	  = "";
	LET cEstatus     	  = "";	
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
	LET cEstatusCFDI	  = "0";
	LET cTelefono		  = "";
	LET cNomCarrier		  = "";
	LET cCorreo			  = "";
	LET cHistEnv		  = "";
	LET cStatusServImp    = "";
	LET cNumeroProdusctosTarjetaCredito = ""; --DBS 23/01/2019 Folio 531
	LET cNumProdTarCre = ""; --DBS 23/01/2019 Folio 531
	LET cQuery = ''; --DBS 23/01/2019 Folio 531

BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
			    LET cCod_ret = iSqlErr;
				
				RETURN cCod_ret,cCuenta,cTarjeta,cSucursal,cProducto,dFecha_alta,dFecha_venc,cEstatus,cEstatusCFDI,					cTelefono,cNomCarrier,cCorreo,cHistEnv,cStatusServImp,iTipo,iSkip,iEjecucion;	
			END IF;
		END EXCEPTION;
		
	--SET DEBUG FILE TO '/home/sysifx/JesusRubio/531/sp_obtenerctas_cfdi.out';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	-- INICIO DEL PROCEDIMIENTO
	IF NVL(pEmpresa,'') = '' THEN
			LET cCod_ret = '00001';
			LET iTipo = 20; 
			RETURN cCod_ret,cCuenta,cTarjeta,cSucursal,cProducto,NVL(dFecha_alta,""),NVL(dFecha_venc,""),cEstatus,
				NVL(cEstatusCFDI,""),NVL(cTelefono,""),NVL(cNomCarrier,""),NVL(cCorreo,""),cHistEnv,cStatusServImp,iTipo,iSkip,iEjecucion;
		ELIF NVL(pNumCte,'') = '' AND (NVL(pCuenta,'') = '' AND NVL(pTarjeta,'') = '') THEN
			LET cCod_ret = '00001';
			LET iTipo = 20;
			RETURN cCod_ret,cCuenta,cTarjeta,cSucursal,cProducto,NVL(dFecha_alta,""),NVL(dFecha_venc,""),cEstatus,
				NVL(cEstatusCFDI,""),NVL(cTelefono,""),NVL(cNomCarrier,""),NVL(cCorreo,""),cHistEnv,cStatusServImp,iTipo,iSkip,iEjecucion;
		ELIF NVL(pTpo,'') = '' THEN
			LET cCod_ret = '00001';
			LET iTipo = 20;
			RETURN cCod_ret,cCuenta,cTarjeta,cSucursal,cProducto,NVL(dFecha_alta,""),NVL(dFecha_venc,""),cEstatus,
				NVL(cEstatusCFDI,""),NVL(cTelefono,""),NVL(cNomCarrier,""),NVL(cCorreo,""),cHistEnv,cStatusServImp,iTipo,iSkip,iEjecucion;
		ELIF NVL(pLimit,'') = '' THEN
			LET cCod_ret = '00001';
			LET iTipo = 20;
			RETURN cCod_ret,cCuenta,cTarjeta,cSucursal,cProducto,NVL(dFecha_alta,""),NVL(dFecha_venc,""),cEstatus,
				NVL(cEstatusCFDI,""),NVL(cTelefono,""),NVL(cNomCarrier,""),NVL(cCorreo,""),cHistEnv,cStatusServImp,iTipo,iSkip,iEjecucion;
		ELIF NVL(pEjecucion,'') = '' THEN
			LET cCod_ret = '00001';
			LET iTipo = 20;
			RETURN cCod_ret,cCuenta,cTarjeta,cSucursal,cProducto,NVL(dFecha_alta,""),NVL(dFecha_venc,""),cEstatus,
				NVL(cEstatusCFDI,""),NVL(cTelefono,""),NVL(cNomCarrier,""),NVL(cCorreo,""),cHistEnv,cStatusServImp,iTipo,iSkip,iEjecucion;
		ELSE
			IF pCuenta <> '' THEN
				SELECT num_cte,cuenta 
				INTO cNumCte,cCuenta 
				FROM bdicheq:"informix".sc_maechq 
				WHERE empresa = pEmpresa 
				AND cuenta = pCuenta;
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
					SELECT numcte,num_credito 
					INTO cNumCte,cCuenta 
					FROM bdicred:"informix".sd_maecred 
					WHERE empresa = pEmpresa 
					AND num_credito = pCuenta;
					
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
							WHERE empresa = pEmpresa 
							AND num_credito = pCuenta;
							
							IF dbinfo("sqlca.sqlerrd2") = 0 THEN
								LET cCod_ret = '00100';
								LET iTipo = 12;
								RETURN cCod_ret,cCuenta,cTarjeta,cSucursal,cProducto,NVL(dFecha_alta,""),NVL(dFecha_venc,""),cEstatus,
				NVL(cEstatusCFDI,""),NVL(cTelefono,""),NVL(cNomCarrier,""),NVL(cCorreo,""),cHistEnv,cStatusServImp,iTipo,iSkip,iEjecucion;
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
					WHERE empresa = pEmpresa 
					AND num_tarjeta = pTarjeta
					AND status_tar = "A";
					
					IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
						LET cCod_ret = '00100';
						LET iTipo = 6;
						RETURN cCod_ret,cCuenta,cTarjeta,cSucursal,cProducto,NVL(dFecha_alta,""),NVL(dFecha_venc,""),cEstatus,
				NVL(cEstatusCFDI,""),NVL(cTelefono,""),NVL(cNomCarrier,""),NVL(cCorreo,""),cHistEnv,cStatusServImp,iTipo,iSkip,iEjecucion;
					ELSE
						LET iSistema = 6;
					END IF;
					
				ELSE
					LET iSistema = 1;
				END IF;
				
			ELIF pNumCte <> '' THEN
				LET cNumCte = pNumCte;
			END IF;
			
			 SELECT numcte
			INTO cNumCte
			FROM bdinteg:"informix".si_cliente
			WHERE empresa = pEmpresa 
			AND numcte = cNumCte;

			IF cNumCte IS NULL THEN
				LET cCod_ret = "000003";
				LET iTipo = 11;
				RETURN cCod_ret,cCuenta,cTarjeta,cSucursal,cProducto,NVL(dFecha_alta,""),NVL(dFecha_venc,""),cEstatus,
				NVL(cEstatusCFDI,""),NVL(cTelefono,""),NVL(cNomCarrier,""),NVL(cCorreo,""),cHistEnv,cStatusServImp,iTipo,iSkip,iEjecucion;
			END IF;
			
			
				SELECT a.telefono, b.nombre_carrier
				INTO cTelefono, cNomCarrier
				FROM bdinteg:"informix".si_telefonos_actual a,  bdinteg:"informix".si_carriers b
				WHERE a.empresa = pEmpresa
				AND a.numcte =  cNumCte 
				AND a.tipo_tel = '2'
				AND a.status_tel = 'A'
				AND a.cofetel = 'V'
				AND a.secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_telefonos_actual 
				WHERE numcte =  cNumCte 
				AND empresa = pEmpresa
				AND tipo_tel = '2'
				AND status_tel = 'A'
				AND cofetel = 'V')
				AND  a.carrier = b.cve_carrier;
				
				
				
				SELECT correo_elec 
				INTO cCorreo
				FROM  bdinteg:"informix".si_correos
				WHERE empresa = pEmpresa AND numcte = cNumCte
				AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_correos 
				WHERE empresa = pEmpresa  AND numcte = cNumCte); 
				

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
						mc.cuenta,sucursal,mc.producto||" "||pr.nombre,status_cta 
							
						INTO cCuenta,cSucursal,cProducto,cEstatus
						FROM bdicheq:"informix".sc_maechq mc,
							 bdicheq:"informix".sc_producto pr
						WHERE num_cte = cNumCte 
						AND mc.empresa = pEmpresa
						AND mc.cuenta = CASE WHEN iSistema <> 1 THEN mc.cuenta ELSE cCuenta END
						AND mc.status_cta IN ('1','3','4','5')
						AND mc.producto = pr.producto 
						ORDER BY cuenta 
						
						
						
						SELECT fecha_alta,fecha_mod
						INTO dFecha_alta,dFecha_venc
						FROM bdicheq:"informix".sc_maenoc
						WHERE empresa = pEmpresa
						AND cuenta = cCuenta;

						SELECT num_tarjeta
						INTO  cTarjeta
						FROM bdicheq:"informix".sc_tarjeta
						WHERE numcte = cNumCte
						AND empresa = pEmpresa
						AND cuenta = cCuenta 
						AND secuencia = (SELECT MAX(secuencia) FROM bdicheq:"informix".sc_tarjeta WHERE empresa = pEmpresa AND numcte = cNumCte AND cuenta = cCuenta); 

						
						SELECT hist_env,status_serv_imp, status_serv_elec
						INTO cHistEnv,cStatusServImp, cEstatusCFDI
						FROM bdiedoelec:"informix".edelec_alta_serv
						WHERE empresa = pEmpresa				
						AND numcte = cNumCte
						AND cuenta = cCuenta;

																														
						LET iCantReg = iCantReg + 1;
						LET iSkip = iCantReg;
						RETURN cCod_ret,NVL(cCuenta,""),NVL(cTarjeta,""),NVL(cSucursal,""),NVL(cProducto,""),NVL(							dFecha_alta,DATE(1)) ,NVL(dFecha_venc, DATE(1)),NVL(cEstatus,""),NVL(cEstatusCFDI,"I"),
						NVL(cTelefono,""),NVL(cNomCarrier,""),NVL(cCorreo,""),NVL(cHistEnv,""),NVL(cStatusServImp,"I"),							iTipo,iSkip+sTipo,iEjecucion WITH RESUME;
						
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
				--IF iEjecucion = 1 THEN
				IF iEjecucion = 0 THEN
					LET sTipo = 0;
				END IF;
				IF iEjecucion in (0,1,2) THEN
					IF pNumCte <> '' OR iSistema = 6 THEN
---------------------------------------------------------------------------------DSB 23/01/2019--------------------------------------------------------------------------------------------------------------------			
						SELECT valor 
						INTO cNumeroProdusctosTarjetaCredito
						FROM bdicred:"informix".sd_param WHERE empresa = pEmpresa AND cod_param IN('058');
						LET cNumProdTarCre = TRIM(cNumeroProdusctosTarjetaCredito);
						LET cNumCte = TRIM(cNumCte);
						
						LET cQuery = "SELECT skip "||sTipo||" LIMIT "||iLimit||" mc.num_credito,sucursal,mc.num_producto|| ' '||pr.nombre_prod, fecha_apertura,fecha_vencim, mc.status_cred"||
						" FROM bdicred:sd_maecred mc, bdicred:sd_definicion pr, bdicred:sd_tipocartera tc WHERE numcte = '"||cNumCte||"'"||
						" AND mc.num_credito = CASE WHEN '"||iSistema||"' <> 6 THEN mc.num_credito ELSE '"||cCuenta||"' END"||
						" AND mc.num_producto = pr.num_producto	AND pr.num_producto IN ("||cNumProdTarCre||")"||
						" AND mc.status_cred = tc.status_cred "||
						" AND mc.status_cred IN ('AA','BA','BT','E1','E2','E3') ORDER BY 1";	--IFRS 
								
						PREPARE stmtId FROM TRIM(cQuery);
						DECLARE custCur CURSOR FOR stmtId;
						OPEN custCur;
						FETCH custCur INTO cCuenta,cSucursal,cProducto,dFecha_alta,dFecha_venc,cEstatus;
						
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cCod_ret = "000002";
							LET iTipo = 11;
				
							RETURN cCod_ret,cCuenta,NVL(cTarjeta,""),cSucursal,cProducto,dFecha_alta,dFecha_venc,cEstatus,
							NVL(cEstatusCFDI,"I"),NVL(cTelefono,""),NVL(cNomCarrier,""),NVL(cCorreo,""),NVL(cHistEnv,""),
							NVL(cStatusServImp,"I"),iTipo,iSkip,iEjecucion;
						END IF	
										
						WHILE  SQLCODE= 0 --Si encuentra registros el cursor
						-- *********************************************************************
						-- Extrae la informacion del Sistema de Credito
						-- *********************************************************************
									
							SELECT num_tarjeta
							INTO cTarjeta
							FROM bdicred:"informix".sd_tarjeta
							WHERE empresa = pEmpresa 
							AND numcte = cNumCte
							AND num_credito = cCuenta
							AND secuencia = (SELECT MAX(secuencia) FROM bdicred:"informix".sd_tarjeta WHERE numcte = cNumCte AND num_credito = cCuenta);  
														
								

							SELECT hist_env,status_serv_imp, status_serv_elec
							INTO cHistEnv,cStatusServImp, cEstatusCFDI
							FROM bdiedoelec:"informix".edelec_alta_serv
							WHERE empresa = pEmpresa				
							AND numcte = cNumCte
							AND cuenta = cCuenta;

							LET iCantReg = iCantReg + 1;
							LET iSkip = iCantReg;
							LET iEjecucion = 2;
								
								
							RETURN cCod_ret,NVL(cCuenta,""),NVL(cTarjeta,""),NVL(cSucursal,""),NVL(cProducto,""),
							NVL(dFecha_alta,DATE(1)) ,NVL(dFecha_venc, DATE(1)),NVL(cEstatus,""),
							NVL(cEstatusCFDI,"I"),NVL(cTelefono,""),NVL(cNomCarrier,""),NVL(cCorreo,""),
							NVL(cHistEnv,""),NVL(cStatusServImp,"I"),iTipo,iSkip+sTipo,iEjecucion WITH RESUME;
							
							FETCH custCur INTO cCuenta,cSucursal,cProducto,dFecha_alta,dFecha_venc,cEstatus;	
						END WHILE;
						CLOSE custCur;
						FREE custCur;
						FREE stmtId;

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
							   mcd.fecha_apertura, mcd.fecha_vencim, mcd.status_cred
							INTO cCuenta,cSucursal,cProducto,
							   dFecha_alta,dFecha_venc,cEstatus
							FROM bdicred:"informix".sd_maecredcrd mcd,
							   bdicred:"informix".sd_definicion df,
							   bdicred:"informix".sd_tipocartera tc
							WHERE numcte = cNumCte 
							AND mcd.num_producto = df.num_producto
							AND df.num_producto IN ('6300','6011')
							AND mcd.status_cred = tc.status_cred
							AND mcd.status_cred IN ('AA','BA','BT','VP','E1','E2','E3')	--IFRS 
							ORDER BY 1
							
						

						SELECT hist_env,status_serv_imp, status_serv_elec
						INTO cHistEnv,cStatusServImp, cEstatusCFDI
						FROM bdiedoelec:"informix".edelec_alta_serv
						WHERE empresa = pEmpresa				
						AND numcte = cNumCte
						AND cuenta = cCuenta;
			
						
						LET iCantReg = iCantReg + 1;
						LET iSkip = iCantReg;
						LET iEjecucion = 3;
						RETURN cCod_ret,cCuenta,NVL(cTarjeta,""),cSucursal,cProducto,dFecha_alta,dFecha_venc,cEstatus,
						NVL(cEstatusCFDI,"I"),NVL(cTelefono,""),NVL(cNomCarrier,""),NVL(cCorreo,""),NVL(cHistEnv,""),NVL(cStatusServImp,"I"),iTipo,
						iSkip+sTipo,iEjecucion WITH RESUME;
						END FOREACH;
					END IF;
				END IF;
			END IF;
			
			IF iSkip = 0 THEN
				LET cCod_ret = "000002";
				LET iTipo = 11;
				
							RETURN cCod_ret,cCuenta,NVL(cTarjeta,""),cSucursal,cProducto,dFecha_alta,dFecha_venc,cEstatus,
							NVL(cEstatusCFDI,"I"),NVL(cTelefono,""),NVL(cNomCarrier,""),NVL(cCorreo,""),NVL(cHistEnv,""),
							NVL(cStatusServImp,"I"),iTipo,iSkip,iEjecucion;
			END IF;
		END IF;	
	
	END
END PROCEDURE             
DOCUMENT
"DESCRIPCION: Reaaliza consulta de Cliente para regresar la información de sus cuentas de créditos 7000 y 8100 y todas las futuras tarjetas de credito",
"Folio: 531",
"Autor: 97877352 Jesús Alberto Rubio Lugo",
"Fecha: 23/01/2019",
"Solicitante: Cutberto Gonzalez",
"BD:bdiedoelec";

CREATE PROCEDURE "informix".sp_upd_status_cred(pempresa char(3)) 
RETURNING CHAR(5) AS CodigoRetorno

    DEFINE iSqlErr              INTEGER;
    DEFINE v_sCodRet            CHAR(5);
	DEFINE v_valor 				SMALLINT;
	DEFINE v_fecha_hoy 			SMALLINT;
	DEFINE v_numcte 			CHAR(20);
	DEFINE v_cuenta 			CHAR(20);
	DEFINE v_status_cred_serv   CHAR(2);
	DEFINE v_status_cred_cred   CHAR(2);
	DEFINE v_status_serv_elec   CHAR(1);
	DEFINE v_status_serv_imp    CHAR(1);
	DEFINE v_fecha_cancel_servicio DATE;
	DEFINE cMtoVen				DECIMAL(14,2);
	
	--SET DEBUG FILE TO  "sp_upd_status_cred.out"; 
    --TRACE ON;

	LET v_sCodRet = '000';
	LET v_valor = 0;
	LET v_fecha_hoy = 0;
	LET v_numcte = ''; 			
	LET v_cuenta = '';			
	LET v_status_cred_serv = '';  
	LET v_status_cred_cred = '';  
	LET v_status_serv_elec = '';  
	LET v_status_serv_imp = '';   
	LET v_fecha_cancel_servicio = TODAY;
	LET cMtoVen = 0;	
	BEGIN
		ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET v_sCodRet = iSqlErr;
                RETURN v_sCodRet;
            END IF;
        END EXCEPTION;

		SELECT (valor)::SMALLINT
		  INTO v_valor 
	 	  FROM bdiedoelec:edelec_param 
		 WHERE cod_param = 2;
		
		SELECT (DAY(fecha_hoy))::SMALLINT
		  INTO v_fecha_hoy 
		  FROM bdinteg:si_fechas 
		 WHERE 1=1;
		 
		IF v_valor = v_fecha_hoy THEN
		
			FOREACH WITH HOLD
				SELECT a.numcte,a.cuenta,a.status_serv_elec,a.status_cred,b.status_cred, NVL(m.monto_vencido + m.mto_venc_trasp,0)
				  INTO v_numcte, v_cuenta, v_status_serv_elec,v_status_cred_serv, v_status_cred_cred, cMtoVen
				  FROM bdiedoelec:edelec_alta_serv a, bdicred:sd_maecred b, bdicred:sd_maesdos m
				 WHERE a.cuenta = b.num_credito
				   AND b.num_credito = m.num_credito
				   AND a.producto = '6001'

		    IF v_status_cred_serv <> v_status_cred_cred AND v_status_serv_elec = 'A' THEN
			
				if (v_status_cred_cred IN ('BA','BT','E1','E2','E3') AND cMtoVen > 0) THEN		--IF v_status_cred_cred IN ('BA','BT') THEN	--IFRS 
				
					LET v_status_serv_imp = 'A';
					LET v_fecha_cancel_servicio = NULL;
				
				END IF
				
				IF (v_status_cred_cred IN ('AA','E1') AND cMtoVen = 0) THEN	--IFRS 
				
					LET v_status_serv_elec = 'A';
					LET v_status_serv_imp = 'I';
					LET v_fecha_cancel_servicio = NULL;
				
				END IF
				
				IF v_status_cred_cred NOT IN ('AA','BA','BT','E1','E2','E3') THEN	--IFRS 
				
					LET v_status_serv_elec = 'I';
					LET v_status_serv_imp = 'I';
					LET v_fecha_cancel_servicio = TODAY;
				
				END IF
				
				UPDATE bdiedoelec:edelec_alta_serv 
				   SET status_serv_elec = v_status_serv_elec,
					   status_serv_imp = v_status_serv_imp,
					   status_cred = v_status_cred_cred,
					   fecha_ultima_mod = TODAY,
					   fecha_cancel_servicio = v_fecha_cancel_servicio,
					   tipo_modificacion = 'S',
					   user_modif = 'informix'
				 WHERE empresa = pempresa 
				   AND numcte = v_numcte 
				   AND cuenta = v_cuenta 
				   AND producto = '6001';
				 
			END IF
					
				CONTINUE FOREACH;
			END FOREACH;
		END IF

		RETURN v_sCodRet;    

    END
END PROCEDURE;