CREATE PROCEDURE "informix".sp_valida_producto_tf(pEmpresa CHAR(3),pNumCta CHAR(20))
RETURNING CHAR(5) AS cCodRet,
		  CHAR(4) AS cProducto;

--DEFINICION DE VARIABLES--
DEFINE  cCodRet 	CHAR(5);
DEFINE  cProducto 	CHAR(4);
DEFINE  cProdTr 	CHAR(4);
DEFINE  iSqlErr		INTEGER;

--INICIALIZACION DE VARIABLES--
LET cCodRet 	= '00000';
LET cProducto 	= '';
LET cProdTr 	= '';
LET iSqlErr		= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
	   IF (iSqlErr != 0) THEN
		  LET cCodRet = iSqlErr;
		  RETURN cCodRet, cProducto;
	   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/respaldosbd/claudio/sp_valida_producto_tf.out';
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa,'') <> '' AND NVL(pNumCta,'') <> '' THEN
		SELECT producto	INTO cProducto
		FROM bditransfer:"informix".tf_maecte
		WHERE empresa = pEmpresa
		AND cuenta_tf = pNumCta;

		IF NVL(cProducto,'') <> '' THEN
			SELECT producto INTO cProducto
			FROM bdicheq:"informix".sc_producto
			WHERE empresa = pEmpresa
			AND producto = cProducto;
			
			IF NVL(cProducto,'') = '' THEN
				LET cCodRet ='01223';
			ELSE
				SELECT valor INTO cProdTr
				FROM bditransfer:"informix".tf_param
				WHERE empresa = pEmpresa AND cod_param = '4';
				
				IF TRIM(NVL(cProducto,'')) <> TRIM(NVL(cProdTr,'')) THEN
					LET cCodRet ='01223';
				END IF;
			END IF;
		ELSE
			LET cCodRet ='01223';
		END IF;
	ELSE
		LET cCodRet ='00001';
	END IF;
	RETURN cCodRet, cProducto;
END;
END PROCEDURE
DOCUMENT
'00000 - exito',
'00001 - parametro vacio',
'01223 - parametro no encontrado',
'AUTOR : Claudio Almodovar',
'FECHA : 16/06/2015',
'BD: bditransfer';

CREATE PROCEDURE "informix".sp_cons_cte_transfer(pEmpresa CHAR(3), 
											     pConsulta CHAR(20), 
												 pNombre1 CHAR(26), 
												 pNombre2 CHAR(26), 
												 pApellPat CHAR(26),
												 pAPellMat CHAR(26),
												 pFechaNac DATE, 
												 pTipoConsulta INTEGER, 
												 pTipoEjeucion INTEGER,
												 pRFC CHAR(13))
	RETURNING CHAR(5)  AS CodRet,
			  CHAR(26) AS Nombre1,
			  CHAR(26) AS Nombre2,
			  CHAR(26) AS ApellidoPaterno,
			  CHAR(26) AS ApellidoMaterno,
			  CHAR(10) AS FechaNacimiento,
			  CHAR(10) AS Telefono,
			  CHAR(20) AS Cuenta,
			  CHAR(20) AS Cliente,
			  INTEGER  AS BanderaCteNvo,
			  CHAR(20) AS ClienteTf;

DEFINE cCodRet  	CHAR(5);
DEFINE cTelefono	CHAR(10);
DEFINE cCuenta  	CHAR(20);
DEFINE cCliente 	CHAR(20);
DEFINE cClienteTf 	CHAR(20);
DEFINE cClienteTar 	CHAR(20);
DEFINE cNombre1 	CHAR(26);
DEFINE cNombre2 	CHAR(26);
DEFINE cApellPat 	CHAR(26);
DEFINE cAPellMat 	CHAR(26);
DEFINE dFechaNac 	DATE;
DEFINE cFechaNac    CHAR(10);
DEFINE iEjecucion	INTEGER;
DEFINE iBandCteNvo	INTEGER;
DEFINE iSqlErr  	INTEGER;

LET cCodRet  	= '00000';
LET cTelefono  	= '';
LET cCuenta  	= '';
LET cCliente 	= '';
LET cClienteTf 	= '';
LET cClienteTar	= '';
LET cNombre1 	= '';
LET cNombre2 	= '';
LET cApellPat 	= '';
LET cAPellMat 	= '';
LET dFechaNac   = DATE(1);
LET cFechaNac   = '';
LET iEjecucion 	= 0;
LET iBandCteNvo	= 0;
LET iSqlErr  	= 0;


			  
--SET DEBUG FILE TO '/respaldosbd/martin/sp_cons_cte_transfer.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			LET cFechaNac = CAST(NVL(dFechaNac,DATE(1)) AS CHAR(10));
			RETURN cCodRet, TRIM(NVL(cNombre1,'')), TRIM(NVL(cNombre2,'')), TRIM(NVL(cApellPat,'')), TRIM(NVL(cApellMat,'')), cFechaNac , NVL(cTelefono,''), NVL(cCuenta,''), NVL(cCliente,''), iBandCteNvo, NVL(cClienteTf,'');
	
		END IF;
	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO dirty READ;
	
	IF TRIM(NVL(pEmpresa,'')) <> '' AND NVL(pTipoConsulta,0) > 0  AND NVL(pTipoConsulta,0) < 5 AND NVL(pTipoEjeucion,0) > 0 AND NVL(pTipoEjeucion,0) < 5 THEN
		IF TRIM(NVL(pConsulta,'')) <> '' OR  pTipoConsulta = 3 THEN
			IF  pTipoConsulta = 1 THEN -- TELEFONO TIPO 1
				SELECT cuenta_tf, numcte, numcte_tf, telefono, nombre1, nombre2, apell_paterno, apell_materno, fecha_nac
				INTO cCuenta, cCliente, cClienteTf, cTelefono, cNombre1, cNombre2, cApellPat, cApellMat, dFechaNac
				FROM bditransfer:"informix".tf_maecte
				WHERE empresa = pEmpresa
				AND telefono = TRIM(pConsulta)
                AND status_cta = '1';
			ELIF  pTipoConsulta = 2 THEN -- CUENTA TRANSFER TIPO 2 
				SELECT cuenta_tf, numcte, numcte_tf, telefono, nombre1, nombre2, apell_paterno, apell_materno, fecha_nac
				INTO cCuenta, cCliente, cClienteTf, cTelefono, cNombre1, cNombre2, cApellPat, cApellMat, dFechaNac
				FROM bditransfer:"informix".tf_maecte
				WHERE empresa = pEmpresa 
				AND cuenta_tf = TRIM(pConsulta)
                AND status_cta = '1';
			ELIF  pTipoConsulta = 3 THEN --NOMBRE TIPO 3
				IF TRIM(NVL(pNombre1,'')) <> '' AND TRIM(NVL(pApellPat,'')) <> ''  AND NVL(pFechaNac,DATE(1)) <>  DATE(1) AND TRIM(NVL(pRFC,'')) <> ''  THEN
					SELECT cuenta_tf, numcte, numcte_tf, telefono, nombre1, nombre2, apell_paterno, apell_materno, fecha_nac 
					INTO cCuenta, cCliente, cClienteTf, cTelefono, cNombre1, cNombre2, cApellPat, cApellMat, dFechaNac
					FROM bditransfer:"informix".tf_maecte
					WHERE empresa = pEmpresa 
					AND nombre1 = pNombre1
					AND nombre2= pNombre2
					AND apell_paterno = pApellPat
					AND apell_materno = pApellMat
					AND fecha_nac = pFechaNac
					AND rfc = pRFC
                    AND status_cta = '1';
				ELSE
					LET cCodRet = '00001';
				END IF;
			ELIF  pTipoConsulta = 4 THEN --	tarjeta tipo 4 
				SELECT numcte 
				INTO cClienteTar
				FROM bdicheq:"informix".sc_tarjeta
				WHERE empresa = pEmpresa 
				AND num_tarjeta = TRIM(pConsulta);
				
				SELECT cuenta_tf, numcte, numcte_tf, telefono, nombre1, nombre2, apell_paterno, apell_materno, fecha_nac
				INTO cCuenta, cCliente, cClienteTf, cTelefono, cNombre1, cNombre2, cApellPat, cApellMat, dFechaNac
				FROM bditransfer:"informix".tf_maecte
				WHERE empresa = pEmpresa 
				AND numcte = cClienteTar
                AND status_cta = '1';
				
			END IF;
			IF cCodRet = '00000' THEN
             LET cCliente = (SELECT numcte  FROM bdinteg:"informix".si_cliente WHERE numcte=cCliente AND tipo_cliente=1);
				IF TRIM(NVL(cCuenta,'')) <> '' THEN 
				
					IF NVL(pTipoEjeucion,0) = 1  OR NVL(pTipoEjeucion,0)= 2 THEN
						LET iEjecucion = 1; --alta
					ELIF NVL(pTipoEjeucion,0) = 3 OR NVL(pTipoEjeucion,0) = 4 THEN
						LET iEjecucion = 2; ---cancelacion y remplazo
                        
					END IF;
					                  

					IF iEjecucion= 1 THEN
						IF TRIM(NVL(cCliente,'')) = '' THEN
							LET iBandCteNvo = 1;
						END IF;
					END IF;
						
					IF iBandCteNvo = 0 THEN
						SELECT nombre1,nombre2,apell_paterno,apell_materno
						INTO cNombre1, cNombre2, cApellPat,  cApellMat
						FROM bdinteg:"informix".si_cliente
						WHERE empresa = pEmpresa 
						AND numcte = cCliente;
						
						SELECT  fecha_nac 
						INTO dFechaNac
						FROM bdinteg:"informix". si_ctepf  
						WHERE empresa = pEmpresa 
						AND numcte = cCliente;
					END IF;
					
					--LET cNombre =  TRIM(TRIM(NVL(cNombre1,'')) || ' ' || TRIM(NVL(cNombre2,''))) || ' ' || TRIM(TRIM(NVL(cApellPat,'')) || ' ' ||  TRIM(NVL(cApellMat,''))) ;
						
				ELSE
					LET cCodRet = '623';
				END IF;
			END IF;
		ELSE
			LET cCodRet = '00001';
		END IF;
	ELSE
		LET cCodRet = '00001';
	END IF;		
	
	LET cFechaNac = CAST(NVL(dFechaNac,DATE(1)) AS CHAR(10));
	
	RETURN cCodRet, TRIM(NVL(cNombre1,'')), TRIM(NVL(cNombre2,'')), TRIM(NVL(cApellPat,'')), TRIM(NVL(cApellMat,'')), cFechaNac , NVL(cTelefono,''), NVL(cCuenta,''), NVL(cCliente,''), iBandCteNvo, NVL(cClienteTf,'');
	
END
END PROCEDURE
DOCUMENT
'FOLIO: 1600',
'AUTOR : 94972834',
'FECHA : 01/05/2014',
'SUSTENTO: Asigna_Tarjeta.pdf, Reposicion_Tarjeta.pdf, Eliminación de tarjeta.pdf',
'SOLICITA: Rodolfo Gomez',
'00001: falta un parametro obligatorio',
'623: no se emcontro el cliente transfer',
'BD: bditransfer';

CREATE PROCEDURE "informix".sp_consulta_nombre_tf
(
	pEmpresa 	CHAR(03),
	pNombre1 	CHAR(20),
	pNombre2 	CHAR(20),
    pPaterno 	CHAR(20),
    pMaterno 	CHAR(20),
	pFechaNac 	DATE,
    pSecuencia 	SMALLINT
)

RETURNING
	CHAR(6) 	AS cCodRet,
	CHAR(50) 	AS cNombre1,
	CHAR(26) 	AS cNombre2,
	CHAR(26) 	AS cApPaterno,
	CHAR(26) 	AS cApMaterno,
	DATE 		AS dFechaNac,
	CHAR(20) 	AS cNumCteTf,
	CHAR(13) 	AS cRFC,
	CHAR(20) 	AS cCuentaTf;

--DECLARACIÓN DE VARIABLES
DEFINE iSql_err		INTEGER;
DEFINE cCodRet		CHAR(06);
DEFINE cNombre1		CHAR(50);
DEFINE cNombre2		CHAR(26);
DEFINE cAPaterno	CHAR(26);
DEFINE cAMaterno	CHAR(26);
DEFINE dFN			DATE;
DEFINE cNumcteTf 	CHAR(20);
DEFINE cRfc 		CHAR(13);
DEFINE cCuentaTf	CHAR(20);

--INICIALIZACIÓN DE VARIABLES
LET cCodRet			= '000000';
LET cNombre1		= '';
LET cNombre2		= '';
LET cAPaterno		= '';
LET cAMaterno		= '';
LET cNumcteTf		= '0000000000';
LET cRfc			= '';
LET dFN				= '';
LET cCuentaTf		= '';

--SET DEBUG FILE TO '/respaldosbd/Ernesto/sp_consulta_nombre_tf.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet, cNombre1, cNombre2, cAPaterno, cAMaterno, dFN, cNumcteTf, cRfc, cCuentaTF;
		END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 4;

	--VALIDAR PARÁMETROS VACÍOS Y NULOS
	IF NVL(TRIM(pEmpresa),'') = ''  THEN
		LET cCodRet = '000001';
		LET cNombre1 = 'Debe proporcionar el código de empresa';
		RETURN cCodRet, cNombre1, cNombre2, cAPaterno, cAMaterno, dFN, cNumcteTf, cRfc, cCuentaTF;
	END IF;

	IF NVL(TRIM(pPaterno), '') = '' THEN
		LET cCodRet = '000002';
		LET cNombre1 = 'Debe proporcionar el apellido paterno';
		RETURN cCodRet, cNombre1, cNombre2, cAPaterno, cAMaterno, dFN, cNumcteTf, cRfc, cCuentaTF;
	ELSE
		LET pPaterno = TRIM(pPaterno);
	END IF;

	IF NVL(TRIM(pNombre1), '') = '' THEN
		LET cCodRet = '000003';
		LET cNombre1 = 'Debe proporcionar el primer nombre';
		RETURN cCodRet, cNombre1, cNombre2, cAPaterno, cAMaterno, dFN, cNumcteTf, cRfc, cCuentaTF;
	ELSE
		LET pNombre1 = TRIM(pNombre1)||'*';
	END IF;

	IF NVL(TRIM(pNombre2), '') = '' THEN
		LET pNombre2 = '';
	ELSE
		LET pNombre2 = TRIM(pNombre2)||'*';
	END IF;  
	
	IF NVL(pFechaNac, '') = '' THEN
		FOREACH
			SELECT SKIP pSecuencia LIMIT 21
			nombre1, nombre2, apell_paterno, apell_materno, fecha_nac, numcte_tf, rfc, cuenta_tf
			INTO cNombre1, cNombre2, cAPaterno, cAMaterno, dFN, cNumcteTf, cRfc, cCuentaTF
			FROM bditransfer:"informix".tf_maecte
			WHERE nombre1 MATCHES pNombre1 AND nombre2 MATCHES pNombre2 AND apell_paterno = pPaterno AND apell_materno = pMaterno AND status_cta = '1'

			RETURN cCodRet, cNombre1, cNombre2, cAPaterno, cAMaterno, dFN, cNumcteTf, cRfc, cCuentaTF WITH RESUME;
		END FOREACH;
	ELSE
	
		FOREACH
			SELECT SKIP pSecuencia LIMIT 21
			nombre1, nombre2, apell_paterno, apell_materno, fecha_nac, numcte_tf, rfc, cuenta_tf
			INTO cNombre1, cNombre2, cAPaterno, cAMaterno, dFN, cNumcteTf, cRfc, cCuentaTF
			FROM bditransfer:"informix".tf_maecte
			WHERE nombre1 MATCHES pNombre1 AND nombre2 MATCHES pNombre2 AND apell_paterno = pPaterno AND apell_materno = pMaterno AND fecha_nac = pFechaNac AND status_cta = '1'

			RETURN cCodRet, cNombre1, cNombre2, cAPaterno, cAMaterno, dFN, cNumcteTf, cRfc, cCuentaTF WITH RESUME;
		END FOREACH;
	
	END IF
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '000004';
		LET cNombre1 = 'No se encontró coincidencia';
		RETURN cCodRet, cNombre1, cNombre2, cAPaterno, cAMaterno, dFN, cNumcteTf, cRfc, cCuentaTF;
	END IF

END;
END PROCEDURE

DOCUMENT
'Consulta clientes transfer por medio de los parámetros nombre(s) y apellido(s) y por fecha de nacimiento',
'AUTOR : 95579737 - José Ernesto Raygoza Villa',
'FECHA : 16/Abril/2014',
'MODIFICO: Leslie Rendón',
'DESCRIPCIÓN: Se modifica para evitar forzar la consulta por fecha de nacimiento.',
'BD    : bditransfer';

CREATE PROCEDURE "informix".sp_trans_consultacte(	pTpoTrans	CHAR(1), -- 1 = Deposito, ? 2 = Retiro.
														pTarjeta	CHAR(20),
														pCuenta		CHAR(20),
														pTelefono	CHAR(20)	)
	  RETURNING CHAR(6)   AS cCodinfx,
				CHAR(6)   AS cCodRet,
				CHAR(20)  AS cCuenta_tf, 
				CHAR(18)  AS cCta_clabe,
				CHAR(13)  AS cTelCelular,
				CHAR(1)   AS cStatus_cta,
				CHAR(20)  AS cNum_cte_ret,
				CHAR(20)  AS cNumcte_tf,
				CHAR(4)   AS cProducto,
				CHAR(100) AS cNombre,
				CHAR(10)  AS cFecha_nac,
				CHAR(13)  AS cRfc,
				CHAR(100) AS cCorreo,
				CHAR(18)  AS cCurp,
				CHAR(15)  AS cMet_notificacion,
				CHAR(8)   AS cEjecutivo,
				CHAR(10)  AS cFec_alta,
				CHAR(10)  AS cFec_cancelac,
				CHAR(10)  AS cFec_modific,
				CHAR(2)   AS cCod_ent_nac;
		
	--DEFINICION DE VARIABLES
	DEFINE iSqlErr 				INTEGER;
	DEFINE cCodinfx 			CHAR(6);
	DEFINE cCodRet 				CHAR(6);

	DEFINE cCuenta 		   		CHAR(20);
	DEFINE cApellpaterno   		CHAR(26); 
	DEFINE cApellmaterno   		CHAR(26);
	DEFINE cNombre1		   		CHAR(26);
	DEFINE cNombre2		   		CHAR(26);
	DEFINE cTelCelular	   		CHAR(13);
	DEFINE cNum_cte		   		CHAR(20);
	DEFINE cNum_cte_1	   		CHAR(20);
	DEFINE iNum_cte_fon	   		INTEGER;
	DEFINE iNumParams	   		INTEGER;

	DEFINE cCuenta_tf 			CHAR(20);
	DEFINE cCta_clabe			CHAR(18);
	DEFINE cStatus_cta			CHAR(1);
	DEFINE cNumcte_tf			CHAR(20);
	DEFINE cProducto			CHAR(4);
	DEFINE cFecha_nac			CHAR(10);
	DEFINE cRfc					CHAR(13);
	DEFINE cCorreo				CHAR(100);
	DEFINE cCurp				CHAR(18);
	DEFINE cMet_notificacion	CHAR(15);
	DEFINE cEjecutivo			CHAR(8);
	DEFINE cFec_alta			CHAR(10);
	DEFINE cFec_cancelac		CHAR(10);
	DEFINE cFec_modific			CHAR(10);
	DEFINE cCod_ent_nac			CHAR(2);
	DEFINE cNum_cte_ret 		CHAR(20);
	DEFINE cNombre		 		CHAR(100);

	--INICIALIZACION DE VARIABLES
	LET iSqlErr 			= 0;
	LET cCodinfx 			= '000000';
	LET cCodRet 			= '000000';

	LET cCuenta  			= '';
	LET cApellpaterno   	= ''; 
	LET cApellmaterno   	= '';
	LET cNombre1			= '';
	LET cNombre2			= '';
	LET cTelCelular	    	= '';
	LET cNum_cte			= '';
	--LET cNum_cte_tar		= '';
	LET iNum_cte_fon		= 0;

	LET cCuenta_tf  		= '';
	LET cCta_clabe			= '';
	LET cStatus_cta			= '';
	LET cNumcte_tf			= '';
	LET cProducto			= '';
	LET cFecha_nac			= '';
	LET cRfc				= '';
	LET cCorreo				= '';
	LET cCurp				= '';
	LET cMet_notificacion	= '';
	LET cEjecutivo			= '';
	LET cFec_alta			= '';
	LET cFec_cancelac		= '';
	LET cFec_modific		= '';
	LET cCod_ent_nac		= '';
	LET cNum_cte_ret		= '';
	LET cNombre				= '';
	LET iNumParams			= 0;

	-- SET DEBUG FILE TO '/home/sysifx/vlv/sp_trans_consultacte.out';
	-- TRACE ON;

	BEGIN
		ON EXCEPTION -- CONTROL DE ERROR DE INFORMIX
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodinfx = iSqlErr;
				RETURN cCodinfx,cCodRet,cCuenta_tf,cCta_clabe,cTelCelular,cStatus_cta,cNum_cte_ret,cNumcte_tf,cProducto,cNombre,
				cFecha_nac,cRfc,cCorreo,cCurp,cMet_notificacion,cEjecutivo,cFec_alta,cFec_cancelac,cFec_modific,cCod_ent_nac;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- SE VALIDA EL VALOR DE LA TRANSACCION
		IF NVL(pTpoTrans,'') = '' THEN
			LET cCodRet = '832';
			RETURN cCodinfx,cCodRet,cCuenta_tf,cCta_clabe,cTelCelular,cStatus_cta,cNum_cte_ret,cNumcte_tf,cProducto,cNombre,cFecha_nac,cRfc,cCorreo,cCurp,cMet_notificacion,cEjecutivo,cFec_alta,cFec_cancelac,cFec_modific,cCod_ent_nac;
		END IF
		
		-- SE VALIDA QUE EL CLIENTE SOLO ENVIE UN CRITERIO DE CONSULTA
		IF NVL(pTarjeta,'') <> '' THEN
			LET iNumParams = iNumParams +1;
		END IF
		
		IF NVL(pCuenta,'') <> '' THEN
			LET iNumParams = iNumParams +1;
		END IF

		IF NVL(pTelefono,'') <> '' THEN
			LET iNumParams = iNumParams +1;
		END IF
		
		-- SE VALIDA QUE MINIMO 1 PARAMETRO DE LOS RESTANTES TENGA INFORMACIÓN
		IF iNumParams <> 1 THEN
			LET cCodRet = '832';
		ELSE
			IF NVL(pTpoTrans,'') = 1 THEN			
				-- SI LA CONSULTA ES POR CUENTA O POR CELULAR
				IF (NVL(pCuenta,'') <> '') OR (NVL(pTelefono,'') <> '') THEN
					IF NVL(pCuenta,'') <> '' THEN
						-- LA CUENTA TIENE QUE SER DE 11 POSICIONES.
						IF LENGTH(TRIM(pCuenta)) <> 11 THEN
							LET cCodRet = '831';
							RETURN cCodinfx,cCodRet,cCuenta_tf,cCta_clabe,cTelCelular,cStatus_cta,cNum_cte_ret,cNumcte_tf,cProducto,cNombre,cFecha_nac,cRfc,cCorreo,cCurp,cMet_notificacion,cEjecutivo,cFec_alta,cFec_cancelac,cFec_modific,cCod_ent_nac;
						ELSE
							LET cCuenta = TRIM(pCuenta);							
						
							SELECT cuenta_tf,cta_clabe,telefono,status_cta,numcte,numcte_tf,producto,nombre1,nombre2,apell_paterno,apell_materno,
							fecha_nac,rfc,correo,curp,met_notificacion,ejecutivo,fec_alta,fec_cancelac,fec_modific,cod_ent_nac
							INTO cCuenta_tf,cCta_clabe,cTelCelular,cStatus_cta,cNum_cte_ret,cNumcte_tf,cProducto,cNombre1,
							cNombre2,cApellpaterno,cApellmaterno,cFecha_nac,cRfc,cCorreo,cCurp,cMet_notificacion,cEjecutivo,
							cFec_alta,cFec_cancelac,cFec_modific,cCod_ent_nac
							FROM "informix".tf_maecte 
							WHERE cuenta_tf = TRIM(cCuenta)
								AND empresa = '001'
								AND status_cta = '1';

							IF NVL(cNumcte_tf,'') <> '' THEN
								LET cNombre = TRIM(cNombre1)||" "||TRIM(cNombre2)||" "||TRIM(cApellpaterno)||" "||TRIM(cApellmaterno);
							ELSE
								--EL CLIENTE TRANSFER NO EXISTE
								LET cCodRet = '833';
							END IF							
						END IF	
					ELIF NVL(pTelefono,'') <> '' THEN
						-- EL TELEFONO TIENE QUE SER DE 10 POSICIONES.						
						IF LENGTH(TRIM(pTelefono)) <> 10 THEN
							LET cCodRet = '831';
							RETURN cCodinfx,cCodRet,cCuenta_tf,cCta_clabe,cTelCelular,cStatus_cta,cNum_cte_ret,cNumcte_tf,cProducto,cNombre,cFecha_nac,cRfc,cCorreo,cCurp,cMet_notificacion,cEjecutivo,cFec_alta,cFec_cancelac,cFec_modific,cCod_ent_nac;
						ELSE
							
							SELECT {+INDEX( "informix".tf_maecte  "informix".idx_tf_maecte_tel)} 
							cuenta_tf,cta_clabe,telefono,status_cta,numcte,numcte_tf,producto,nombre1,nombre2,apell_paterno,apell_materno,
							fecha_nac,rfc,correo,curp,met_notificacion,ejecutivo,fec_alta,fec_cancelac,fec_modific,cod_ent_nac
							INTO cCuenta_tf,cCta_clabe,cTelCelular,cStatus_cta,cNum_cte_ret,cNumcte_tf,cProducto,cNombre1,
							cNombre2,cApellpaterno,cApellmaterno,cFecha_nac,cRfc,cCorreo,cCurp,cMet_notificacion,cEjecutivo,
							cFec_alta,cFec_cancelac,cFec_modific,cCod_ent_nac
							FROM "informix".tf_maecte 
							WHERE telefono = TRIM(pTelefono)
								AND empresa = '001'
								AND status_cta = '1';

							IF NVL(cNumcte_tf,'') <> '' THEN
								LET cNombre = TRIM(cNombre1)||" "||TRIM(cNombre2)||" "||TRIM(cApellpaterno)||" "||TRIM(cApellmaterno);
							ELSE
								--EL CLIENTE TRANSFER NO EXISTE
								LET cCodRet = '833';
							END IF							
						END IF
					END IF;					
				-- SI EL PARAMETRO DE LA TARJETA ESTA CONTENIDO
				ELIF (NVL(pTarjeta,'') <> '') THEN
					-- LA TARJETA TIENE QUE SER DE 16 POSICIONES.
					IF LENGTH(TRIM(pTarjeta)) <> 16 THEN
						LET cCodRet = '831';
						RETURN cCodinfx,cCodRet,cCuenta_tf,cCta_clabe,cTelCelular,cStatus_cta,cNum_cte_ret,cNumcte_tf,cProducto,cNombre,cFecha_nac,cRfc,cCorreo,cCurp,cMet_notificacion,cEjecutivo,cFec_alta,cFec_cancelac,cFec_modific,cCod_ent_nac;
					ELSE
					
						SELECT NVL(cuenta,'') INTO cCuenta FROM bdicheq:"informix".sc_tarjeta WHERE empresa = "001" AND num_tarjeta = pTarjeta;
						
						IF NVL(cCuenta,'') <> '' THEN
						
							SELECT cuenta_tf,cta_clabe,telefono,status_cta,numcte,numcte_tf,producto,nombre1,nombre2,apell_paterno,apell_materno,
							fecha_nac,rfc,correo,curp,met_notificacion,ejecutivo,fec_alta,fec_cancelac,fec_modific,cod_ent_nac
							INTO cCuenta_tf,cCta_clabe,cTelCelular,cStatus_cta,cNum_cte_ret,cNumcte_tf,cProducto,cNombre1,
							cNombre2,cApellpaterno,cApellmaterno,cFecha_nac,cRfc,cCorreo,cCurp,cMet_notificacion,cEjecutivo,
							cFec_alta,cFec_cancelac,cFec_modific,cCod_ent_nac
							FROM "informix".tf_maecte 
							WHERE cuenta_tf = TRIM(cCuenta)
							AND empresa = '001'
							AND status_cta = '1';

							IF NVL(cNumcte_tf,'') <> '' THEN
								LET cNombre = TRIM(cNombre1)||" "||TRIM(cNombre2)||" "||TRIM(cApellpaterno)||" "||TRIM(cApellmaterno);
							ELSE
								--EL CLIENTE TRANSFER NO EXISTE
								LET cCodRet = '833';
							END IF
						ELSE
							--EL CLIENTE TRANSFER NO EXISTE
							LET cCodRet = '838';
						END IF
					END IF
				END IF;
			-- PARA LA TRANSACCION POR RETIRO
			ELIF NVL(pTpoTrans,'') = 2 THEN
				--EN CASO QUE CLIENTE HAYA PROPORCIONADO EL DATO DE LA CUENTA O DEL CELULAR
				IF (NVL(pCuenta,'') <> '') OR (NVL(pTelefono,'') <> '') THEN
					IF NVL(pCuenta,'') <> '' THEN					
						-- LA CUENTA TIENE QUE SER DE 11 POSICIONES.
						IF LENGTH(TRIM(pCuenta)) <> 11 THEN
							--LA LONGITUD DE LA CUENTA NO ES DE 11 POSICIONES
							LET cCodRet = '831';
							RETURN cCodinfx,cCodRet,cCuenta_tf,cCta_clabe,cTelCelular,cStatus_cta,cNum_cte_ret,cNumcte_tf,cProducto,cNombre,cFecha_nac,cRfc,cCorreo,cCurp,cMet_notificacion,cEjecutivo,cFec_alta,cFec_cancelac,cFec_modific,cCod_ent_nac;
						ELSE
							-- OBTENER EL NUMERO DEL CLIENTE
							SELECT NVL(numcte,'') INTO cNum_cte	FROM "informix".tf_maecte WHERE cuenta_tf = TRIM(pCuenta) AND status_cta = "1";
						END IF					
					ELIF NVL(pTelefono,'') <> '' THEN						
						-- EL TELEFONO TIENE QUE SER DE 10 POSICIONES.
						IF LENGTH(TRIM(pTelefono)) <> 10 THEN
							LET cCodRet = '831';
							RETURN cCodinfx,cCodRet,cCuenta_tf,cCta_clabe,cTelCelular,cStatus_cta,cNum_cte_ret,cNumcte_tf,cProducto,cNombre,cFecha_nac,cRfc,cCorreo,cCurp,cMet_notificacion,cEjecutivo,cFec_alta,cFec_cancelac,cFec_modific,cCod_ent_nac;
						ELSE
							-- OBTENER EL NUMERO DEL CLIENTE
							SELECT NVL(numcte,'') INTO cNum_cte	FROM "informix".tf_maecte WHERE telefono = TRIM(pTelefono) AND status_cta = "1";
						END IF
					END IF;
					
					-- VALIDAR EL DATO DEL NUMERO DEL CLIENTE
					IF NVL(cNum_cte,'') = '' THEN
						-- CLIENTE INCORRECTO
						LET cCodRet = '845';
					ELSE
						SELECT numcte 
						INTO cNum_cte_1  
						FROM bdinteg:si_cliente 
						WHERE numcte=TRIM(cNum_cte)
						AND  tipo_cliente=1;
												 
							IF NVL(cNum_cte_1,'') = '' THEN
								LET cCodRet = '838';  --CLIENTE NO SE ENCUENTRA REGISTRADO
							END IF;
									
						IF (NVL(cNum_cte_1,'') <> '') THEN
							-- SI SE TIENE LA CUENTA SE CONSULTARA POR CUENTA
							IF NVL(pCuenta,'') <> '' THEN						
								SELECT cuenta_tf,cta_clabe,telefono,status_cta,numcte,numcte_tf,producto,nombre1,nombre2,apell_paterno,apell_materno,
								fecha_nac,rfc,correo,curp,met_notificacion,ejecutivo,fec_alta,fec_cancelac,fec_modific,cod_ent_nac
								INTO cCuenta_tf,cCta_clabe,cTelCelular,cStatus_cta,cNum_cte_ret,cNumcte_tf,cProducto,cNombre1,
								cNombre2,cApellpaterno,cApellmaterno,cFecha_nac,cRfc,cCorreo,cCurp,cMet_notificacion,cEjecutivo,
								cFec_alta,cFec_cancelac, cFec_modific,cCod_ent_nac
								FROM "informix".tf_maecte
								WHERE cuenta_tf = pCuenta
									AND numcte = TRIM(cNum_cte)
									AND status_cta = "1";
									
							-- SI SE TIENE EL TELEFO CELULAR SE CONSULTARA POR EL TELEFO CELULAR
							ELIF NVL(pTelefono,'') <> '' THEN
								SELECT cuenta_tf,cta_clabe,telefono,status_cta,numcte,numcte_tf,producto,nombre1,nombre2,apell_paterno,apell_materno,
								fecha_nac,rfc,correo,curp,met_notificacion,ejecutivo,fec_alta,fec_cancelac,fec_modific,cod_ent_nac
								INTO cCuenta_tf,cCta_clabe,cTelCelular,cStatus_cta,cNum_cte_ret,cNumcte_tf,cProducto,cNombre1,
								cNombre2,cApellpaterno,cApellmaterno,cFecha_nac,cRfc,cCorreo,cCurp,cMet_notificacion,cEjecutivo,
								cFec_alta,cFec_cancelac, cFec_modific,cCod_ent_nac
								FROM "informix".tf_maecte
								WHERE telefono = pTelefono
									AND numcte = TRIM(cNum_cte)
									AND status_cta = "1";

							END IF;
							-- ARMAR EL NOMBRE COMPLETO DEL CLIENTE
							LET cNombre = TRIM(cNombre1)||" "||TRIM(cNombre2)||" "||TRIM(cApellpaterno)||" "||TRIM(cApellmaterno);							
						END IF;
					END IF;
				END IF;
				-- SI EL PARAMETRO DE LA TARJETA ESTA CONTENIDO
				IF (NVL(pTarjeta,'') <> '') THEN
					
					-- LA TARJETA TIENE QUE SER DE 16 POSICIONES.
					IF LENGTH(TRIM(pTarjeta)) <> 16 THEN
						LET cCodRet = '831';
						RETURN cCodinfx,cCodRet,cCuenta_tf,cCta_clabe,cTelCelular,cStatus_cta,cNum_cte_ret,cNumcte_tf,cProducto,cNombre,cFecha_nac,cRfc,cCorreo,cCurp,cMet_notificacion,cEjecutivo,cFec_alta,cFec_cancelac,cFec_modific,cCod_ent_nac;
					END IF
					
					SELECT NVL(cuenta,'') INTO cCuenta FROM bdicheq:"informix".sc_tarjeta WHERE empresa = "001" AND num_tarjeta = pTarjeta AND prodtarjeta = "8000";
					-- SI SE TIENE EL DATO DE LA CUENTA
					IF NVL(cCuenta,'') <> '' THEN
						SELECT cuenta_tf,cta_clabe,telefono,status_cta,numcte,numcte_tf,producto,nombre1,nombre2,apell_paterno,apell_materno,fecha_nac,rfc,correo,curp,met_notificacion,ejecutivo,fec_alta,fec_cancelac,fec_modific,cod_ent_nac
						INTO cCuenta_tf,cCta_clabe,cTelCelular,cStatus_cta,cNum_cte_ret,cNumcte_tf,cProducto,cNombre1,cNombre2,cApellpaterno,cApellmaterno,cFecha_nac,cRfc,cCorreo,cCurp,cMet_notificacion,cEjecutivo,cFec_alta,cFec_cancelac,cFec_modific,cCod_ent_nac
						FROM "informix".tf_maecte 
						WHERE cuenta_tf = TRIM(cCuenta)
						AND status_cta = '1';
						
						IF NVL(cNumcte_tf,'') = '' THEN
							--EL CLIENTE TRANSFER NO EXISTE
							LET cCodRet = '835';
						ELSE
							LET cNombre = TRIM(cNombre1)||" "||TRIM(cNombre2)||" "||TRIM(cApellpaterno)||" "||TRIM(cApellmaterno);
						END IF;
					ELSE
						--EL CLIENTE TRANSFER NO EXISTE
						LET cCodRet = '838';
					END IF;
				END IF;
			ELSE
				-- LA TRANSACCION NO ES DEPOSITO NI ES RETIRO
				LET cCodRet = '832';
				RETURN cCodinfx,cCodRet,cCuenta_tf,cCta_clabe,cTelCelular,cStatus_cta,cNum_cte_ret,cNumcte_tf,cProducto,cNombre,cFecha_nac,cRfc,cCorreo,cCurp,cMet_notificacion,cEjecutivo,cFec_alta,cFec_cancelac,cFec_modific,cCod_ent_nac;

			END IF;
		END IF;		
		-- SE RETORNA LA INFORMACIÓN OBTENIDA
		RETURN cCodinfx,cCodRet,cCuenta_tf,cCta_clabe,cTelCelular,cStatus_cta,cNum_cte_ret,cNumcte_tf,cProducto,cNombre,
		cFecha_nac,cRfc,cCorreo,cCurp,cMet_notificacion,cEjecutivo,cFec_alta,cFec_cancelac,cFec_modific,cCod_ent_nac;
			
	END;

	END PROCEDURE
	DOCUMENT
	'Folio: 1433',
	'Autor: 93893061 ',
	'Fecha: 08/07/2014',
	'Descripción: Consulta el nombre del cliente dependiendo del criterio de consulta que el cliente proporcione ya sea "Tarjeta", "Cuenta" o "Num. Teléfono". ',
	'Sustento: Retiro_efectivo.pdf y Deposito_ Efectivo.pdf',
	'Solicita: Berenice Méndez Rivera',
	'BD: bditransfer';

CREATE PROCEDURE "informix".sp_consulta_ctetf(pEmpresa CHAR(3), pNumTelefono CHAR(20), pNumCta CHAR(20), pNumTarjeta CHAR(16), pNumCte CHAR(20))

	--DATOS A REGRESAR
	RETURNING
	CHAR(6)	  AS  CodRet,
	CHAR(60)  AS  Mensaje,
	CHAR(104) AS  NombreCte,
	CHAR(20)  AS  NumCteTf,
	CHAR(20)  AS  NumCteBco,
	CHAR(20)  AS  NumCtaTf,
	CHAR(16)  AS  NumTarjeta,
	CHAR(13)  AS  NumTelefono,
	CHAR(50)  AS  Identificacion,
	CHAR(20)  AS  NumIdentificacion,
	CHAR(100) AS  Correo,
	DATE	  AS  FechaNac, 
	DATE	  AS  FechaAlta, 
	CHAR(13)  AS  Rfc,
	CHAR(100) AS  Estado,
	CHAR(50)  AS  Municipio,
	CHAR(100) AS  Colonia,
	CHAR(100) AS  Calle,
	CHAR(15)  AS  NumExt,
	CHAR(15)  AS  NumInt,
	CHAR(15)  AS  NumDepto,
	CHAR(5)   AS  CodPostal,
	CHAR(5)   AS  MunicipioSi,
	CHAR(40)  AS  EntreCalles,
	CHAR(1)	  AS  StatusCta;

	--DEFINICION DE VARIABLES--
	DEFINE iSqlErr 				INTEGER;
	DEFINE cCodRet 				CHAR(6);
	DEFINE cMensaje				CHAR(60);
	DEFINE cNombreCte			CHAR(104);
	DEFINE cNumCteTf			CHAR(20);
	DEFINE cNumCteBco			CHAR(20);
	DEFINE cNumCtaTf			CHAR(20);
	DEFINE cNumTarjeta			CHAR(16);
	DEFINE cNumTelefono			CHAR(13);
	DEFINE cIdentificacion		CHAR(50);
	DEFINE cNumIdentificacion	CHAR(20);
	DEFINE cCorreo				CHAR(100);
	DEFINE dFechaNac			DATE;
	DEFINE dFechaAlta			DATE;
	DEFINE cRfc					CHAR(13);
	DEFINE cEstado				CHAR(100);
	DEFINE cMunicipio			CHAR(50);
	DEFINE cColonia				CHAR(100);
	DEFINE cCalle				CHAR(100);
	DEFINE cNumExt				CHAR(15);
	DEFINE cNumInt				CHAR(15);
	DEFINE cNumDepto			CHAR(15);
	DEFINE cCodPostal			CHAR(5);
	DEFINE cMunicipioSi			CHAR(5);
	DEFINE cEntreCalles			CHAR(40);
	DEFINE cStatusCta			CHAR(1);
	
	--INICIALIZACION DE VARIABLES--
	LET iSqlErr 			= 0;
	LET cCodRet 			= '000000';
	LET cMensaje			= 'PROCESO EJECUTADO EXITOSAMENTE';
	LET cNombreCte			= '';
	LET cNumCteTf			= '';
	LET cNumCteBco			= '';
	LET cNumCtaTf			= '';
	LET cNumTarjeta			= '';
	LET cNumTelefono		= '';
	LET cIdentificacion		= '';
	LET cNumIdentificacion	= '';
	LET cCorreo				= '';
	LET dFechaNac			= DATE(1);
	LET dFechaAlta			= DATE(1);
	LET cRfc				= '';
	LET cEstado				= '';
	LET cMunicipio			= '';
	LET cColonia			= '';
	LET cCalle				= '';
	LET cNumExt				= '';
	LET cNumInt				= '';
	LET cNumDepto			= '';
	LET cCodPostal			= '';
	LET cMunicipioSi		= '';
	LET cEntreCalles		= '';
	LET cStatusCta			= '';
	
	--SET DEBUG FILE TO '/respaldosbd/CarlosAguirre/sp_consulta_ctetf.out';
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensaje = 'OCURRIO UN ERROR NO CONTROLADO';
				RETURN cCodRet,cMensaje,cNombreCte,cNumCteTf, cNumCteBco, cNumCtaTf,cNumTarjeta,cNumTelefono,cIdentificacion,
					cNumIdentificacion,	cCorreo, dFechaNac,dFechaAlta,cRfc,cEstado,cMunicipio,cColonia,cCalle,cNumExt,
					cNumInt,cNumDepto,cCodPostal,cMunicipioSi,cEntreCalles,cStatusCta;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SE VALIDA SI LO PARAMETROS VIENE VACIOS.
		IF NVL(pEmpresa,'') = '' OR  pEmpresa <> '' AND NVL(pNumTelefono,'') = '' AND NVL(pNumCta,'') = '' AND NVL(pNumTarjeta,'') = '' 
			AND NVL(pNumCte,'') = '' THEN 
		
			LET cCodRet = '000001';
			LET cMensaje = 'ERROR PARAMETROS VACIOS';
			RETURN cCodRet,cMensaje,cNombreCte,cNumCteTf, cNumCteBco, cNumCtaTf,cNumTarjeta,cNumTelefono,cIdentificacion,
				cNumIdentificacion,	cCorreo, dFechaNac,dFechaAlta,cRfc,cEstado,cMunicipio,cColonia,cCalle,cNumExt,
				cNumInt,cNumDepto,cCodPostal,cMunicipioSi,cEntreCalles,cStatusCta;
		END IF;
		
		--SE VALIDA CUAL PARAMETRO TRAE DATO PARA EJECUTAR EL SELECT CORRESPONDIENTE.
		IF pEmpresa <> '' AND pNumTelefono <>'' AND  NVL(pNumCta,'') = '' AND  NVL(pNumTarjeta,'') = '' AND  NVL(pNumCte,'') = '' THEN 
		
			SELECT TRIM(mae.nombre1) || ' ' || TRIM(mae.nombre2) || ' ' || TRIM(mae.apell_paterno) || ' ' || TRIM(mae.apell_materno), 
				mae.numcte_tf, mae.numcte, mae.cuenta_tf,mae.num_tarjeta, mae.telefono, mae.identificacion, mae.num_identificacion, 
				mae.correo, mae.fecha_nac, mae.fec_alta, mae.rfc, dir.estado, dir.municipio, dir.colonia, dir.calle, dir.num_externo, 
				dir.num_interno, dir.num_depto, dir.cod_postal, 
				--dir.municipio,
				sid.municipio,
				sid.entre_calles,mae.status_cta
			INTO cNombreCte,cNumCteTf,cNumCteBco,cNumCtaTf,cNumTarjeta,cNumTelefono,cIdentificacion,cNumIdentificacion,cCorreo,
				dFechaNac,dFechaAlta,cRfc,cEstado,cMunicipio,cColonia,cCalle,cNumExt,cNumInt,cNumDepto,cCodPostal,cMunicipioSi,cEntreCalles,cStatusCta
			FROM 'informix'.tf_maecte mae 
				INNER JOIN 'informix'.tf_direcciones dir ON (mae.cuenta_tf = dir.cuenta_tf AND mae.numcte_tf = dir.numcte_tf)
				LEFT OUTER JOIN bdinteg:'informix'.si_direcciones_actual sid on(mae.numcte = sid.numcte AND sid.tipo_dir = '1')
			WHERE mae.empresa = pEmpresa 
				AND mae.telefono = TRIM(pNumTelefono)
				AND mae.status_cta=1;
	
		ELIF pEmpresa <>'' AND  NVL(pNumTelefono,'') ='' AND pNumCta <> '' AND  NVL(pNumTarjeta,'') = '' AND  NVL(pNumCte,'') = '' THEN 
	
			SELECT TRIM(mae.nombre1) || ' ' || TRIM(mae.nombre2) || ' ' || TRIM(mae.apell_paterno) || ' ' || TRIM(mae.apell_materno), 
				mae.numcte_tf, mae.numcte, mae.cuenta_tf,mae.num_tarjeta, mae.telefono, mae.identificacion, mae.num_identificacion, 
				mae.correo, mae.fecha_nac, mae.fec_alta, mae.rfc, dir.estado, dir.municipio, dir.colonia, dir.calle, dir.num_externo, 
				dir.num_interno, dir.num_depto, dir.cod_postal, sid.municipio, sid.entre_calles,mae.status_cta
			INTO cNombreCte,cNumCteTf,cNumCteBco,cNumCtaTf,cNumTarjeta,cNumTelefono,cIdentificacion,cNumIdentificacion,cCorreo,
				dFechaNac,dFechaAlta,cRfc,cEstado,cMunicipio,cColonia,cCalle,cNumExt,cNumInt,cNumDepto,cCodPostal,cMunicipioSi,cEntreCalles,cStatusCta
			FROM 'informix'.tf_maecte mae 
				INNER JOIN 'informix'.tf_direcciones dir ON (mae.cuenta_tf = dir.cuenta_tf AND mae.numcte_tf = dir.numcte_tf)
				LEFT OUTER JOIN bdinteg:'informix'.si_direcciones_actual sid on(mae.numcte = sid.numcte AND sid.tipo_dir = '1')
			WHERE mae.empresa = pEmpresa 
				AND mae.cuenta_tf = TRIM(pNumCta)
				AND mae.status_cta=1;
		
		ELIF pEmpresa <>'' AND  NVL(pNumTelefono,'') ='' AND  NVL(pNumCta,'') = '' AND pNumTarjeta <> '' AND  NVL(pNumCte,'') = '' THEN 
	
			SELECT TRIM(mae.nombre1) || ' ' || TRIM(mae.nombre2) || ' ' || TRIM(mae.apell_paterno) || ' ' || TRIM(mae.apell_materno), 
				mae.numcte_tf, mae.numcte, mae.cuenta_tf,mae.num_tarjeta, mae.telefono, mae.identificacion, mae.num_identificacion, 
				mae.correo, mae.fecha_nac, mae.fec_alta, mae.rfc, dir.estado, dir.municipio, dir.colonia, dir.calle, dir.num_externo, 
				dir.num_interno, dir.num_depto, dir.cod_postal, sid.municipio, sid.entre_calles,mae.status_cta
			INTO cNombreCte,cNumCteTf,cNumCteBco,cNumCtaTf,cNumTarjeta,cNumTelefono,cIdentificacion,cNumIdentificacion,cCorreo,
				dFechaNac,dFechaAlta,cRfc,cEstado,cMunicipio,cColonia,cCalle,cNumExt,cNumInt,cNumDepto,cCodPostal,cMunicipioSi,cEntreCalles,cStatusCta
			FROM 'informix'.tf_maecte mae 
				INNER JOIN 'informix'.tf_direcciones dir ON (mae.cuenta_tf = dir.cuenta_tf AND mae.numcte_tf = dir.numcte_tf)
				LEFT OUTER JOIN bdinteg:'informix'.si_direcciones_actual sid on(mae.numcte = sid.numcte AND sid.tipo_dir = '1')
				LEFT OUTER JOIN bdicheq:'informix'.sc_tarjeta tar on(mae.numcte=tar.numcte)
			WHERE mae.empresa = pEmpresa 
				AND tar.num_tarjeta = TRIM(pNumTarjeta)
				AND mae.status_cta=1;
			
		ELIF pEmpresa <>'' AND  NVL(pNumTelefono,'') = '' AND  NVL(pNumCta,'') = '' AND  NVL(pNumTarjeta,'') = '' AND pNumCte <> '' THEN
	
			SELECT TRIM(mae.nombre1) || ' ' || TRIM(mae.nombre2) || ' ' || TRIM(mae.apell_paterno) || ' ' || TRIM(mae.apell_materno), 
				mae.numcte_tf, mae.numcte, mae.cuenta_tf,mae.num_tarjeta, mae.telefono, mae.identificacion, mae.num_identificacion, 
				mae.correo, mae.fecha_nac, mae.fec_alta, mae.rfc, dir.estado, dir.municipio, dir.colonia, dir.calle, dir.num_externo, 
				dir.num_interno, dir.num_depto, dir.cod_postal, sid.municipio, sid.entre_calles,mae.status_cta
			INTO cNombreCte,cNumCteTf,cNumCteBco,cNumCtaTf,cNumTarjeta,cNumTelefono,cIdentificacion,cNumIdentificacion,cCorreo,
				dFechaNac,dFechaAlta,cRfc,cEstado,cMunicipio,cColonia,cCalle,cNumExt,cNumInt,cNumDepto,cCodPostal,cMunicipioSi,cEntreCalles,cStatusCta
			FROM 'informix'.tf_maecte mae 
				INNER JOIN 'informix'.tf_direcciones dir ON (mae.cuenta_tf = dir.cuenta_tf AND mae.numcte_tf = dir.numcte_tf)
				LEFT OUTER JOIN bdinteg:'informix'.si_direcciones_actual sid on(mae.numcte = sid.numcte AND sid.tipo_dir = '1')
			WHERE mae.empresa = pEmpresa 
				AND mae.numcte_tf = TRIM(pNumCte)
				AND mae.status_cta=1;
		END IF;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '000002';
			LET cMensaje = 'NO SE ENCONTRARON DATOS';
		END IF;
		
		RETURN cCodRet,cMensaje,cNombreCte,cNumCteTf, cNumCteBco, cNumCtaTf,cNumTarjeta,cNumTelefono,cIdentificacion,
			cNumIdentificacion,	cCorreo, dFechaNac,dFechaAlta,cRfc,cEstado,cMunicipio,cColonia,cCalle,cNumExt,
			cNumInt,cNumDepto,LPAD(TRIM(cCodPostal),5,'0'),cMunicipioSi,cEntreCalles,cStatusCta;
		
	END	
END PROCEDURE
DOCUMENT
'AUTOR: 95689966, Pedro Jimenez Guzman',
'FOLIO: 1440',
'DESCRIPCION: Realiza una consulta para obtener datos generales del cliente',
'FECHA: 10/06/2014',
'SUSTENTO: Se definio con Manuel Osuna y Grabiela Gudino en el requerimiento',
'RQI 63 050 Procesos Transfer Sucursal v1 4.pdf',
'BD: BDITRANSFER',
'-----------------------------------------------------------------------------',
'AUTOR: 95337997 - Carlos Aguirre Vega',
'FOLIO: 1440',
'DESCRIPCION: Se le agrega a las consultas "status_cta" para obtener el status de la cuenta transfer.',
'FECHA: 06/08/2014',
'SUSTENTO: Se atienden las peticiones del archivo Evidencias y defectos_v1.xlsx',
'RQI 63 050 Procesos Transfer Sucursal v1 4.pdf',
'BD: BDITRANSFER';

CREATE PROCEDURE "informix".sp_registra_transadmin(pTipo CHAR(1),pNumCteTf CHAR(20),pFolio CHAR(12),pMpsTransactionId CHAR(12),pEjecutivo CHAR(8))
	RETURNING CHAR(5)  AS CodRet;

DEFINE cCodRet  	 CHAR(5);
DEFINE iSqlErr  	 INTEGER;

LET cCodRet  	  = '00000';
LET iSqlErr  	  = 0;
			  
--SET DEBUG FILE TO '/informix/cristo/sp_bit_actualizacte.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO dirty READ;
	
	IF NVL(pNumCteTf ,'') <> '' THEN
	
		INSERT INTO "informix".tf_bitacora_transadmin(numcte_tf,folio,mpstransactionid,tipo,fecha_insert,ejecutivo) 
		VALUES (pNumCteTf,pFolio,pMpsTransactionId,pTipo,CURRENT,pEjecutivo);

	END IF;
	
	RETURN cCodRet;
	
END
END PROCEDURE;