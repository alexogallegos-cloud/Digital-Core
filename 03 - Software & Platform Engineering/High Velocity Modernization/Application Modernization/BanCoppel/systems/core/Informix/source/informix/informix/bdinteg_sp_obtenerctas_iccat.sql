CREATE PROCEDURE "informix".sp_obtenerctas_iccat(pEmpresa CHAR(3), 
									 pNumCte CHAR(9),
									 pRegistros SMALLINT)
--DATOS A REGRESAR---
RETURNING CHAR(9)   AS codRet, 
		  CHAR(104) AS nombre, 
		  CHAR(20)  AS tarjeta,
		  CHAR(60)  AS producto,  
		  CHAR(1)  	AS estatus_Envio,
		  CHAR(20)  AS cuenta,
		  CHAR(60)  AS estatus_Cuenta,		  
		  CHAR(10)  AS telefonoCel,
		  CHAR(100) AS correo;

		  
	-- DEFINICION DE VARIABLES
	DEFINE cCod_ret      	 CHAR(9);	
    DEFINE cNumCte      	 CHAR(9);
    DEFINE cProducto    	 CHAR(60);
    DEFINE cEstatus     	 CHAR(20);
	DEFINE cTarjeta      	 CHAR(20);
	DEFINE sTipo 			 SMALLINT;
	DEFINE iSqlErr      	 INTEGER;
	DEFINE iLimit 			 INTEGER;
	DEFINE iCantReg 		 INTEGER;
	DEFINE iSistema     	 INTEGER;
	DEFINE iSkip			 INTEGER;
	DEFINE cEstatusCFDI		CHAR(1);
	DEFINE cCuenta      	 CHAR(20);
	DEFINE cTelefono		CHAR(10);
	DEFINE cCorreo			CHAR(100);
	DEFINE cNombre1     	 CHAR(26);
	DEFINE cNombre2			 CHAR(26);
	DEFINE cMaterno			 CHAR(26);
	DEFINE cPaterno			 CHAR(26);
	DEFINE cRazon       	 CHAR(36);
	DEFINE cNomCompleto    	 CHAR(36);
	DEFINE sContReg			 SMALLINT;

	
	--INICIALIZACION DE VARIABLES
	LET cCod_ret     	  = "000000000";		
	LET cNumCte    	 	  = "";	
    LET cProducto    	  = "";
	LET cEstatus     	  = "";	
	LET cTarjeta     	  = "";
	LET sTipo        	  = 0;
	LET iSqlErr      	  = 0;
	LET iLimit       	  = 0;
	LET iCantReg 	 	  = 0;
	LET iSistema     	  = 0;
	LET iSkip        	  = 0;
	LET cEstatusCFDI	  = "";
	LET cCuenta      	  = "";
	LET cTelefono		  = "";
	LET cCorreo			  = "";
	LET cNombre1     	  = "";
	LET cNombre2     	  = "";
	LET cMaterno     	  = "";
	LET cPaterno     	  = "";
	LET cRazon    	 	  = "";
	LET cNomCompleto   	  = "";
	LET sContReg		  = 0;

BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
			    LET cCod_ret = iSqlErr;
				
				RETURN cCod_ret,cNomCompleto,cTarjeta,cProducto,cEstatusCFDI,cCuenta,cEstatus,cTelefono,cCorreo;	
			END IF;
		END EXCEPTION;
		
	--SET DEBUG FILE TO '/informix/tmp/sp_obtenerctas_iccat.out';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	-- INICIO DEL PROCEDIMIENTO
	IF NVL(pEmpresa,'') = '' THEN
			LET cCod_ret = '000000001';
			RETURN cCod_ret,cNomCompleto,cTarjeta,cProducto,
				cEstatusCFDI,NVL(cCuenta,""),cEstatus,cTelefono,cCorreo;
		ELIF NVL(pNumCte,'') = '' THEN
			LET cCod_ret = '000000001';
			RETURN cCod_ret,cNomCompleto,cTarjeta,cProducto,
				cEstatusCFDI,NVL(cCuenta,""),cEstatus,cTelefono,cCorreo;
		ELIF NVL(pRegistros,'') = '' THEN
			LET cCod_ret = '000000001';
			RETURN cCod_ret,cNomCompleto,cTarjeta,cProducto,
				cEstatusCFDI,NVL(cCuenta,""),cEstatus,cTelefono,cCorreo;
	ELSE
			
			LET cNumCte = pNumCte;
			
			SELECT numcte
			INTO cNumCte
			FROM bdinteg:"informix".si_cliente
			WHERE numcte = cNumCte;

			IF cNumCte IS NULL THEN
				LET cCod_ret = "000000003";
				RETURN cCod_ret,cNomCompleto,cTarjeta,cProducto,
				cEstatusCFDI,NVL(cCuenta,""),cEstatus,cTelefono,cCorreo;
			END IF;
			
			
			SELECT a.telefono
			INTO cTelefono
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
			
			SELECT numcte,apell_paterno,apell_materno,nombre1,nombre2,razon_social
			INTO cNumCte,cPaterno,cMaterno,cNombre1,cNombre2,cRazon
			FROM bdinteg:"informix".si_cliente
			WHERE numcte = cNumCte;
			
			LET cNomCompleto = TRIM(cNombre1) || " " || TRIM(cNombre2) || " " || TRIM(cPaterno) ||" " || TRIM(cMaterno);

			LET iLimit = 10;
			LET sTipo = pRegistros;
				-- *****************************************************************
				-- Extrae la informacion del Sistema de Cheques
				-- *****************************************************************
				IF pNumCte <> '' OR iSistema = 1 THEN
				
					SELECT COUNT(*)							
					INTO sContReg
					FROM bdicheq:"informix".sc_maechq mc,
						 bdicheq:"informix".sc_producto pr,
						 bdicheq: sc_mae_estatus mas
					WHERE num_cte = cNumCte 
					AND mc.empresa = pEmpresa
					AND mc.cuenta = mc.cuenta
					AND mc.producto IN ('1300','1400','1500','1700','1800','1900','2000','2400','2500','8000')
					AND mc.status_cta IN ('1','3','4','5','8')
					AND mc.producto = pr.producto
					AND mc.status_cta = mas.cod_estatus;
				
					FOREACH
						SELECT skip sTipo LIMIT iLimit
						mc.cuenta,mc.producto||" "||pr.nombre,mas.descripcion
							
						INTO cCuenta,cProducto,cEstatus
						FROM bdicheq:"informix".sc_maechq mc,
							 bdicheq:"informix".sc_producto pr,
							 bdicheq: sc_mae_estatus mas
						WHERE num_cte = cNumCte 
						AND mc.empresa = pEmpresa
						AND mc.cuenta = mc.cuenta
						AND mc.producto IN ('1300','1400','1500','1700','1800','1900','2000','2400','2500','8000')
						AND mc.status_cta IN ('1','3','4','5','8')
						AND mc.producto = pr.producto
						AND mc.status_cta = mas.cod_estatus
						ORDER BY cuenta 

						SELECT num_tarjeta
						INTO  cTarjeta
						FROM bdicheq:"informix".sc_tarjeta
						WHERE numcte = cNumCte
						AND empresa = pEmpresa
						AND cuenta = cCuenta 
						AND secuencia = (SELECT MAX(secuencia) FROM bdicheq:"informix".sc_tarjeta WHERE numcte = cNumCte AND cuenta = cCuenta);

						IF EXISTS (SELECT cuenta
						FROM bdinteg:"informix".si_altaserv_edoctamov
						WHERE empresa = pEmpresa				
						AND numcte = cNumCte
						AND cuenta = cCuenta) THEN
						LET cEstatusCFDI = "T";
						ELSE
						LET cEstatusCFDI = "F";
						END IF;

						LET iCantReg = iCantReg + 1;
						LET iSkip = iCantReg;
						RETURN cCod_ret,NVL(cNomCompleto,""),NVL(cTarjeta,""),NVL(cProducto,""),cEstatusCFDI,NVL(cCuenta,""),NVL(cEstatus,""),cTelefono,cCorreo WITH RESUME;
						
					END FOREACH;
				END IF;	
			
			IF iCantReg < iLimit  THEN
			
					IF sTipo > sContReg THEN
						LET sTipo = sTipo - sContReg;
					ELSE
						LET sTipo = 0;
					END IF;
			
				LET iLimit = iLimit - iCantReg;
				LET iCantReg = 0;

					-- *********************************************************************
					-- Extrae la informacion del Sistema de Credito
					-- *********************************************************************
					IF pNumCte <> '' OR iSistema = 6 THEN
						--IFRS Se contempla nuevo estatus vigente por Etapas	
						SELECT COUNT(*)	
							INTO sContReg
							FROM bdicred:"informix".sd_maecred mc,
							bdicred:"informix".sd_definicion pr,
							bdicred:"informix".sd_tipocartera tc
							WHERE numcte = cNumCte 
							AND mc.num_credito = mc.num_credito
							AND mc.num_producto = pr.num_producto
							AND pr.num_producto IN('6001','6600','8100','7000', '5400')
							AND mc.status_cred = tc.status_cred 
							AND mc.status_cred IN ('AA','BA','BT','FF','E1','E2','E3');
							--AND mcd.status_cred IN ('AA','BA','BT','FF');
						--IFRS Se contempla nuevo estatus vigente por Etapas	
						FOREACH
							SELECT skip sTipo LIMIT iLimit
							mc.num_credito,mc.num_producto||" "||pr.nombre_prod,tc.descripcion
							INTO cCuenta,cProducto,cEstatus
							FROM bdicred:"informix".sd_maecred mc,
							bdicred:"informix".sd_definicion pr,
							bdicred:"informix".sd_tipocartera tc
							WHERE numcte = cNumCte 
							AND mc.num_credito = mc.num_credito
							AND mc.num_producto = pr.num_producto
							AND pr.num_producto IN('6001','6600','8100','7000', '5400')
							AND mc.status_cred = tc.status_cred 
							AND mc.status_cred IN ('AA','BA','BT','FF','E1','E2','E3')
							--AND mcd.status_cred IN ('AA','BA','BT','FF')							
							ORDER BY 1
							
							SELECT num_tarjeta
							INTO cTarjeta
							FROM bdicred:"informix".sd_tarjeta
							WHERE numcte = cNumCte
							AND num_credito = cCuenta
							AND secuencia = (SELECT MAX(secuencia) FROM bdicred:"informix".sd_tarjeta WHERE numcte = cNumCte AND num_credito = cCuenta);  
							

							IF EXISTS (SELECT cuenta
							FROM bdinteg:"informix".si_altaserv_edoctamov
							WHERE empresa = pEmpresa				
							AND numcte = cNumCte
							AND cuenta = cCuenta) THEN
							LET cEstatusCFDI = "T";
							ELSE
							LET cEstatusCFDI = "F";
							END IF;

							LET iCantReg = iCantReg + 1;
							LET iSkip = iCantReg;
							
							RETURN cCod_ret,NVL(cNomCompleto,""),NVL(cTarjeta,""),NVL(cProducto,""),
							cEstatusCFDI,NVL(cCuenta,""),NVL(cEstatus,""),cTelefono,cCorreo WITH RESUME;
						END FOREACH;
					END IF;	
					
				IF iCantReg < iLimit THEN
					LET iLimit = iLimit - iCantReg;
					LET iCantReg = 0;
					LET cTarjeta = "";
					
					IF sTipo > sContReg THEN
						LET sTipo = sTipo - sContReg;
					ELSE
						LET sTipo = 0;
					END IF;

					-- **********************************************************************************
					-- Extrae la informacion del Sistema de Prestamo personal, credinomina y reestructura
					-- **********************************************************************************
					IF pNumCte <> '' OR iSistema = 7 THEN
					--IFRS Se contempla nuevo estatus vigente por Etapas	
						FOREACH
							SELECT skip sTipo LIMIT iLimit
							   mcd.num_credito,mcd.num_producto||" "||df.nombre_prod, tc.descripcion
							INTO cCuenta,cProducto,cEstatus
							FROM bdicred:"informix".sd_maecredcrd mcd,
							   bdicred:"informix".sd_definicion df,
							   bdicred:"informix".sd_tipocartera tc
							WHERE numcte = cNumCte 
							AND mcd.num_producto = df.num_producto
							AND df.num_producto IN ('6300','6400','7600','7700','7800')
							AND mcd.status_cred = tc.status_cred
							AND mcd.status_cred IN ('AA','BA','BT','FF','E1','E2','E3')
							--AND mcd.status_cred IN ('AA','BA','BT','FF')
							ORDER BY 1				

							IF EXISTS (SELECT cuenta
							FROM bdinteg:"informix".si_altaserv_edoctamov
							WHERE empresa = pEmpresa				
							AND numcte = cNumCte
							AND cuenta = cCuenta) THEN
							LET cEstatusCFDI = "T";
							ELSE
							LET cEstatusCFDI = "F";
							END IF;
				
							LET iCantReg = iCantReg + 1;
							LET iSkip = iCantReg;
							RETURN cCod_ret,cNomCompleto,NVL(cTarjeta,""),cProducto,
							cEstatusCFDI,NVL(cCuenta,""),cEstatus,cTelefono,cCorreo WITH RESUME;
						END FOREACH;
					END IF;
				END IF;
			END IF;
			
			IF iSkip = 0 THEN
				LET cCod_ret = "000000001";
				
				RETURN cCod_ret,cNomCompleto,NVL(cTarjeta,""),cProducto,
				cEstatusCFDI,NVL(cCuenta,""),cEstatus,cTelefono,cCorreo;
			END IF;
		END IF;	
	
	END
END PROCEDURE;