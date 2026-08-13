CREATE PROCEDURE "informix".sp_bitacora_facial_ine(
	pNumcte      	CHAR(20),
    pSucursal    	CHAR(4),
    pEjecutivo   	CHAR(8),
    pFecha_insert	DATETIME YEAR to FRACTION(3),
	pRespuesta_ine  CHAR(8),
	pClave_elector	VARCHAR(32),
	pAnio_registro	VARCHAR(32),
	pAnio_emision	VARCHAR(32),
	pNumero_emision_credencial	VARCHAR(32),
	pCurp	VARCHAR(32),
	pOcr	VARCHAR(32),
	pCic	VARCHAR(32)
	)
	
RETURNING CHAR(5);

	DEFINE cCodRet 			CHAR(5);	
	DEFINE iSqlErr 			INTEGER;
	DEFINE cExiste 			INTEGER;
	DEFINE v_fecha_actual	DATE;
	DEFINE v_fecha_validacion DATETIME YEAR TO FRACTION(3);
	

		
	LET cCodRet 	  ='00000';
	LET iSqlErr 	  = 0;
	LET cExiste		  = 0;
	LET v_fecha_actual = CURRENT;
	LET v_fecha_validacion = CURRENT;
	
	
--	SET DEBUG FILE TO '/home/sysifx/viridiana/SP_BITACORA_HUELLA_INE.out';
--	TRACE ON;
	
BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	
	
			INSERT INTO "informix".si_bitacora_facial_ine(numcte, sucursal, ejecutivo, fecha_insert, respuesta_ws,respuesta_ine, clave_elector, anio_registro, anio_emision, numero_emision_credencial, curp, ocr, cic)
			VALUES(pNumcte, pSucursal, pEjecutivo, current, SUBSTRING_INDEX(pRespuesta_ine,'-',1), SUBSTRING_INDEX(pRespuesta_ine,'-',-1), pClave_elector, pAnio_registro, pAnio_emision, pNumero_emision_credencial, pCurp, pOcr, pCic);
			
			
			SELECT count(*) 
			INTO cExiste
			FROM si_facial_cliente_ine_estatus
			WHERE numcte = pNumcte AND fecha = v_fecha_actual;
			
			IF SUBSTRING_INDEX(pRespuesta_ine,'-',-1) = '99' THEN
				IF cExiste > 0 THEN
					UPDATE si_facial_cliente_ine_estatus SET validado_ine = 0 WHERE numcte = pNumcte AND fecha = v_fecha_actual;
				ELIF cExiste <= 0 THEN
					IF cExiste <= 0 THEN
						INSERT INTO si_facial_cliente_ine_estatus (numcte, fecha, validado_ine) VALUES (pNumcte, v_fecha_actual, 0);
					END IF;
				END IF;
				
			ELSE
				IF cExiste > 0 THEN
					UPDATE si_facial_cliente_ine_estatus SET validado_ine = 1, fecha_validacion = v_fecha_validacion WHERE numcte = pNumcte AND fecha = v_fecha_actual;
				ELIF cExiste <= 0 THEN
					IF cExiste <= 0 THEN
						INSERT INTO si_facial_cliente_ine_estatus (numcte, fecha, validado_ine, fecha_validacion) VALUES (pNumcte, v_fecha_actual, 1, v_fecha_validacion);
					END IF;
				END IF;
				
			END IF;

	RETURN cCodRet;

END;
END PROCEDURE
DOCUMENT
'DescripciÃ³n: SP que guarda la respuesta del servicio web del ine en la bitacora y actualiza el estatus de validad ante el ine en la table si_facial_cliente_ine_estatus',
'AUTOR : Eduardo Ãvila PÃ©rez Tagle',
'Gerencia de Mtto y Soporte IV',
'Fecha: 17/Octubre/2023',
'ActualizaciÃ³n: Se implemento Current para que inserte la fecha y hora del servidor',
'AUTOR : Eduardo Ãvila PÃ©rez Tagle',
'Gerencia de Mtto y Soporte IV',
'Fecha: 17/Julio/2024',
'Version: 1.0.0',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_obtiene_puntos_seguridad_ine(pNumcte      	CHAR(20))
	
RETURNING CHAR(5), CHAR(50);

	DEFINE cCodRet 			CHAR(5);	
	DEFINE iSqlErr 			INTEGER;
	DEFINE vLuz				INTEGER;
	DEFINE cTest1			VARCHAR(10);
	DEFINE cTest2			VARCHAR(10);
	DEFINE cTest3			VARCHAR(10);
	DEFINE cTest4			VARCHAR(10);
	DEFINE cTest5			VARCHAR(10);
	
	DEFINE vUv				INTEGER;
	DEFINE vIr				INTEGER;	
	
	DEFINE vRespuesta		VARCHAR(10);
	
	DEFINE vMaximo			INTEGER;
	DEFINE v_Fecha			DATETIME YEAR TO SECOND;
	
	
	LET cCodRet 	  ='00000';
	LET iSqlErr 	  = 0;
	LET vLuz		  = 0;
	
	LET cTest1		  = '';
	LET cTest2		  = '';
	LET cTest3		  = '';
	LET cTest4		  = '';
	LET cTest5		  = '';
	
	LET vMaximo		  = 0;
	
	LET vUv			  = 0;
	LET vIr			  = 0;
	
	LET vRespuesta	  = 'Falso';
	LET v_Fecha		  = CURRENT;
	
	--SET DEBUG FILE TO '/tmp/EAPT/11062024/sp_obtiene_puntos.out';
	--TRACE ON;
	
BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, vRespuesta;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
			SELECT max(fecha) INTO v_Fecha FROM bdinteg:"informix".si_bitacora_ife WHERE numcte=pNumcte;
			
			SELECT test_uv_reflec_anv, test_uv_shape_anv, test_ir_ink_anv, test_uv_reflectance_rev, test_ir_ink_rev
				INTO cTest1, cTest2, cTest3, cTest4, cTest5
				FROM bdinteg:"informix".si_bitacora_ife 
				WHERE numcte = pNumcte AND fecha = v_Fecha;
	
			IF cTest1 = 'OK' THEN                  
				LET vLuz = vLuz + 1;
				LET vUv  = vUv + 1;
			END IF;
			IF cTest2 = 'OK' THEN
				LET vLuz = vLuz + 1;
				LET vUv  = vUv + 1;
			END IF;
			IF cTest3 = 'OK' THEN
				LET vLuz = vLuz + 1;
				LET vIr = vIr + 1;
			END IF;
			IF cTest4 = 'OK' THEN
				LET vLuz = vLuz + 1;
				LET vUv  = vUv + 1;
			END IF;
			IF cTest5 = 'OK' THEN
				LET vLuz = vLuz + 1;
				LET vIr = vIr + 1;
			END IF;
			
			IF vLuz>=3 AND vUv>=1 AND vIr>=1 THEN
				LET vRespuesta = 'Verdadero';
			END IF;

	RETURN cCodRet, vRespuesta;

END;
END PROCEDURE
DOCUMENT
'DescripciÃÂ³n: SP que obtiene los valores de las luces al digitalizar la credencial de elector',
'AUTOR : Eduardo ÃÂvila PÃÂ©rez Tagle',
'Gerencia de Mtto y Soporte IV',
'Fecha: 17/Julio/2024',
'Version: 1.0.0',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_valida_dummy_40()
RETURNING CHAR(5) as codRet, CHAR(1) as activo

	DEFINE cCodRet 			CHAR(5);
	DEFINE cActivo 			CHAR(1);
	DEFINE iSqlErr 			INTEGER;
	
		
	LET cCodRet 	  ='00000';
	LET cActivo		  ='0';
	LET iSqlErr 	  = 0;
	
	
BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cActivo;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	
		SELECT valor INTO cActivo
		FROM si_param
		WHERE cod_param = 531;
	
	
	RETURN cCodRet, cActivo;

END;
END PROCEDURE
DOCUMENT
'DescripciÃ³n: SP que obtiene el estatus dummy del servicio web 4.0',
'AUTOR : Eduardo Ãvila PÃ©rez Tagle',
'Gerencia de Mtto y Soporte IV',
'Fecha: 17/Julio/2024',
'Version: 1.0.0',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_cnsif_confirmaejecutivo(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10))
							
			returning   CHAR(5)  AS Cod_Retorno;	      

							
DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;							


--inicializando variables
LET  iexiste 		 = 0;
LET cCodRet 		 = "00000";
LET iSql_err 		 = 0 ;   
                     

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet;						
		END IF;
	END EXCEPTION;
	
	--	SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_confirmaejecutivo.out";
	--	TRACE ON;
		
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	THEN 
		LET cCodRet = "00003";
		RETURN cCodRet;
	END IF;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	SELECT COUNT(*) INTO iexiste FROM si_seg_usuarios_funciones WHERE id_usuario = cID_USUARIOC AND id_funcion = cID_FUNCIONC AND status=1;		
	IF NVL(iexiste,0)>0 THEN
		RETURN cCodRet;	
	ELSE
		LET cCodRet = '00028';
		RETURN 	cCodRet;
	END IF

END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Verifica la existencia del usuario y si cuenta con permisos de ejecucion del SP. ",
"El SP obtendrá la información de la Base de Datos central de Informix.",
"FECHA : 21-03-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cnsif_permisosejecutivo(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10), cNUMCTECTARJ CHAR(20),cSISTEMACUENTA CHAR(2),cTIPOBUSQUEDA CHAR(1))
			returning   CHAR(5)  AS Cod_Retorno;	      

							
DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;	
DEFINE iNivel           INT;						
DEFINE iNivelCte        INT;
DEFINE iLong            INT;
DEFINE iExisteCta       INT;	
DEFINE cNumcte			CHAR(20);	
DEFINE cNumCtaTarj		CHAR(20);	
DEFINE cDigitos         CHAR(02);			


--inicializando variables
LET  iexiste 		 = 0;
LET cCodRet 		 = "00000";
LET iSql_err 		 = 0 ;   
LET iNivel           = 0;
LET iNivelCte        = 0;       
LET iLong            = 0;  
LET iExisteCta       = 0;   
LET cNumcte			 = '';
LET cNumCtaTarj      = ''; 
LET cDigitos         = '';              


BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet;						
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/ifxsif01/gpe/sp_cnsif_permisosejecutivo.out";
	--TRACE ON;
		
	IF 	cID_USUARIOC = '' 		OR
		cID_FUNCIONC = '' 		OR
		cNUMCTECTARJ = ''		OR
        cSISTEMACUENTA = ''     OR
        cTIPOBUSQUEDA = ''      THEN 
		LET cCodRet = '00079';
		RETURN cCodRet;
	END IF;	

	-- faltan mas
	IF cSISTEMACUENTA NOT IN ('01','03','05','06','11','22','23','25','26','28','30','00') THEN
		LET cCodRet = '00077';
		RETURN cCodRet;
	END IF;
	
	IF cTIPOBUSQUEDA NOT IN ('1','2','3','4','5','6','7') THEN
		LET cCodRet = '00087';
		RETURN cCodRet;
	END IF;	

	IF (SELECT COUNT(*) FROM si_seg_usuarios_funciones WHERE id_usuario = cID_USUARIOC AND id_funcion = cID_FUNCIONC AND status=1) > 0 THEN		
        --cTIPOBUSQUEDA 1 POR CUENTA, cTIPOBUSQUEDA 2 NUMCTE, cTIPOBUSQUEDA 3 NUMTARJETA
		IF cTIPOBUSQUEDA='1' THEN
			IF cSISTEMACUENTA IN('01','05','11','23','30') THEN
				FOREACH
				SELECT NVL(COUNT(cuenta),'0') INTO cNumCtaTarj FROM bdicheq:sc_maechq WHERE empresa='001' and cuenta = cNUMCTECTARJ
				UNION
				SELECT NVL(COUNT(cuenta_tf),'0') FROM bditransfer:tf_maecte WHERE cuenta_tf = cNUMCTECTARJ
				END FOREACH;
				IF cNumCtaTarj = '0.00' THEN
					LET cCodRet = '00081';
					RETURN cCodRet;
				END IF
				FOREACH
				SELECT NVL(num_cte,'0') INTO cNumcte FROM bdicheq:sc_maechq WHERE empresa='001' and cuenta = cNUMCTECTARJ
				UNION
				SELECT NVL(numcte_tf,'0') FROM bditransfer:tf_maecte WHERE cuenta_tf = cNUMCTECTARJ
				END FOREACH;
			ELIF cSISTEMACUENTA IN('03') THEN
				SELECT NVL(COUNT(cuenta),'0') INTO cNumCtaTarj FROM bdinvers:sv_maeinv WHERE empresa='001' and cuenta = cNUMCTECTARJ;
				IF cNumCtaTarj = '0.00' THEN
					LET cCodRet = '00081';
					RETURN cCodRet;
				END IF
				SELECT LIMIT 1 NVL(num_cte,'0') INTO cNumcte FROM bdinvers:sv_maeinv WHERE empresa='001' and cuenta = cNUMCTECTARJ;
			ELIF cSISTEMACUENTA IN('06','22') THEN
                FOREACH
                    SELECT LIMIT 1 NVL(COUNT(num_credito),'0') AS CANT 
                    INTO 
                    cNumCtaTarj 
                    FROM bdicred:sd_maecred 
                    WHERE empresa = '001' 
                    AND num_credito = cNUMCTECTARJ
                UNION ALL
                    SELECT NVL(COUNT(num_credito),'0')  AS CANT 
                    FROM bdicred:sd_maecredcrd 
                    WHERE empresa = '001' 
                    AND num_credito = cNUMCTECTARJ 
				UNION ALL
                    SELECT NVL(COUNT(num_credito),'0') AS CANT 
                    FROM bdicred:sd_maecred_old 
                    WHERE empresa = '001' 
                    AND num_credito = cNUMCTECTARJ
					ORDER BY CANT DESC
				END FOREACH;		
				IF cNumCtaTarj = '0.00' THEN
					LET cCodRet = '00081';
					RETURN cCodRet;
				END IF;
                FOREACH
                    SELECT LIMIT 1 numcte INTO cNumcte FROM bdicred:sd_maecred WHERE empresa='001' and num_credito = cNUMCTECTARJ			
                    UNION ALL
                    SELECT numcte FROM bdicred:sd_maecredcrd WHERE empresa='001' and num_credito = cNUMCTECTARJ
					UNION ALL
					SELECT numcte FROM bdicred:sd_maecred_old WHERE empresa='001' and num_credito = cNUMCTECTARJ
                END FOREACH;
            ELSE
                LET cCodRet = '00077';
                RETURN cCodRet;
			END IF;
		ELIF cTIPOBUSQUEDA = '2' THEN
			IF cSISTEMACUENTA IN('01','03','06','11','23','26','28','00') THEN
			--	LET cNumcte = cNUMCTECTARJ;
			--ELIF cSISTEMACUENTA IN('23') THEN
				IF cID_FUNCIONC = 'CLI352' THEN
					IF EXISTS(SELECT numcte FROM bdinteg:si_cliente WHERE numcte = cNUMCTECTARJ) THEN
						SELECT NVL(COUNT(numcte),0) AS numcte INTO cNumCtaTarj FROM si_cliente WHERE numcte  = cNUMCTECTARJ;
					ELSE
						SELECT NVL(COUNT(numcte),0) AS numcte INTO cNumCtaTarj FROM si_fuscliente WHERE numcte  = cNUMCTECTARJ;					
					END IF;
				ELSE
					FOREACH
						SELECT LIMIT 1 NVL(COUNT(numcte),0) AS numcte INTO cNumCtaTarj FROM si_cliente WHERE numcte  = cNUMCTECTARJ
						UNION
						SELECT NVL(COUNT(numcte_tf),0) AS numcte FROM bditransfer:tf_maecte WHERE numcte_tf = cNUMCTECTARJ
						UNION
						SELECT NVL(COUNT(numcte),0) AS numcte FROM si_fuscliente WHERE numcte  = cNUMCTECTARJ
						ORDER BY numcte desc
					END FOREACH;
				END IF;
				IF cNumCtaTarj = '0.00' THEN
					LET cCodRet = '00088';
					RETURN cCodRet;
				END IF;
				IF cID_FUNCIONC = 'CLI352' THEN
					IF EXISTS(SELECT numcte FROM bdinteg:si_cliente WHERE numcte = cNUMCTECTARJ) THEN
						SELECT NVL(numcte,0) AS numcte INTO cNumcte FROM si_cliente WHERE numcte  = cNUMCTECTARJ;
					ELSE
						SELECT NVL(numcte,0) AS numcte INTO cNumcte FROM si_fuscliente WHERE numcte  = cNUMCTECTARJ;
					END IF;
				ELSE
					FOREACH
						SELECT NVL(numcte,'0') AS numcte INTO cNumcte FROM si_cliente WHERE numcte  = cNUMCTECTARJ
						UNION
						SELECT NVL(numcte_tf,'0') AS numcte FROM bditransfer:tf_maecte WHERE numcte_tf = cNUMCTECTARJ										
					END FOREACH;
				END IF;
            ELSE
                LET cCodRet = '00077';
                RETURN cCodRet;    
			END IF;	
		ELIF cTIPOBUSQUEDA='3' THEN	
			IF cSISTEMACUENTA IN('06','11','25') THEN				
				--LET cDigitos = SUBSTR(cNUMCTECTARJ,1,2);
				--IF cDigitos = '42' THEN
					SELECT NVL(COUNT(num_tarjeta),'0') INTO cNumCtaTarj FROM bdicred:sd_tarjeta WHERE empresa='001' and num_tarjeta = cNUMCTECTARJ;
					IF cNumCtaTarj = '0.00' THEN
                        SELECT NVL(COUNT(num_tarjeta),'0') INTO cNumCtaTarj FROM bdicheq:sc_tarjeta WHERE empresa='001' and num_tarjeta = cNUMCTECTARJ;
                        IF cNumCtaTarj = '0.00' THEN
                            LET cCodRet = '00082';
                            RETURN cCodRet;
                        ELSE
                            SELECT LIMIT 1 NVL(numcte,'0') INTO cNumcte FROM bdicheq:sc_tarjeta WHERE empresa='001' and num_tarjeta = cNUMCTECTARJ;    
                        END IF;
                    ELSE
    					SELECT NVL(numcte,'0') INTO cNumcte FROM bdicred:sd_tarjeta WHERE empresa='001' and num_tarjeta = cNUMCTECTARJ;
					END IF;				
    		ELSE
				LET cCodRet = '00077';
				RETURN cCodRet;
			END IF;
/* 		ELIF cTIPOBUSQUEDA = '4' THEN
			IF cSISTEMACUENTA IN('06','22') THEN
				SELECT NVL(COUNT(numcte),0)	INTO cNumCtaTarj FROM bdinteg:si_cliente WHERE numcte  = cNUMCTECTARJ;
				IF cNumCtaTarj = '0.00' THEN
					LET cCodRet = '00088';
					RETURN cCodRet;
				END IF
				SELECT NVL(COUNT(numcte),'0') INTO cNumcte FROM bdinteg:si_cliente WHERE numcte  = cNUMCTECTARJ;
				SELECT NVL(COUNT(numcte),'0') INTO cNumCtaTarj FROM bdisolic:ss_solicitudes WHERE numcte  = cNUMCTECTARJ;
				IF cNumCtaTarj = '0.00' THEN
					LET cCodRet = '00082';
					RETURN cCodRet;
				END IF
				SELECT NVL(COUNT(numcte),'0') INTO cNumcte FROM bdisolic:ss_solicitudes WHERE numcte  = cNUMCTECTARJ;
			ELSE
				LET cCodRet = '00077';
				RETURN cCodRet;
			END IF; */
		ELIF cTIPOBUSQUEDA = '5' THEN
			IF cSISTEMACUENTA IN('06') THEN
				SELECT NVL(COUNT(num_solicitud),0) INTO cNumCtaTarj FROM bdisolic:ss_detalle_scoring WHERE num_solicitud  = cNUMCTECTARJ;
				IF cNumCtaTarj = '0.00' THEN
					LET cCodRet = '00071';
					RETURN cCodRet;
				END IF			
                SELECT NVL(numcte,'0') INTO cNumcte FROM bdisolic:ss_solicitudes WHERE num_solicitud = cNUMCTECTARJ;
            ELSE
                LET cCodRet = '00077';
                RETURN cCodRet;
			END IF
		ELIF cTIPOBUSQUEDA = '6' THEN
			IF cSISTEMACUENTA IN('22') THEN
				SELECT NVL(COUNT(num_solicitud),0) INTO cNumCtaTarj FROM bdisolic:ss_solicitudes WHERE num_solicitud = cNUMCTECTARJ;
				IF cNumCtaTarj = '0.00' THEN
					LET cCodRet = '00089';
					RETURN cCodRet;
				END IF			
                SELECT NVL(numcte,'0') INTO cNumcte FROM bdisolic:ss_solicitudes WHERE num_solicitud = cNUMCTECTARJ;
            ELSE
                LET cCodRet = '00077';
                RETURN cCodRet;
			END IF
		ELIF cTIPOBUSQUEDA = '7' THEN
			IF cSISTEMACUENTA IN('00') THEN
				FOREACH
					SELECT NVL(COUNT(cuenta),'0') INTO cNumCtaTarj FROM bdicheq:sc_maechq WHERE empresa='001' AND cuenta_clabe = cNUMCTECTARJ
					UNION
					SELECT NVL(COUNT(cuenta_tf),'0') FROM bditransfer:tf_maecte WHERE cta_clabe = cNUMCTECTARJ
					UNION
					SELECT NVL(COUNT(num_credito),'0') FROM bdicred:sd_maecred WHERE empresa = '001' AND cuenta_clabe = cNUMCTECTARJ
					UNION
                    SELECT NVL(COUNT(num_credito),'0') FROM bdicred:sd_maecredcrd WHERE empresa = '001' AND cuenta_clabe = cNUMCTECTARJ 
				END FOREACH;
					IF cNumCtaTarj = '0.00' THEN
						LET cCodRet = '00081';
						RETURN cCodRet;
				END IF
				FOREACH
					SELECT NVL(num_cte,'0') INTO cNumcte FROM bdicheq:sc_maechq WHERE empresa='001' and cuenta_clabe = cNUMCTECTARJ
					UNION
					SELECT NVL(numcte_tf,'0') FROM bditransfer:tf_maecte WHERE cta_clabe = cNUMCTECTARJ
					UNION
					SELECT NVL(numcte,'0') FROM bdicred:sd_maecred WHERE empresa = '001' AND cuenta_clabe = cNUMCTECTARJ
					UNION
					SELECT NVL(numcte,'0') FROM bdicred:sd_maecredcrd WHERE empresa = '001' AND cuenta_clabe = cNUMCTECTARJ 
				END FOREACH;

            ELSE
                LET cCodRet = '00077';
                RETURN cCodRet;
			END IF
		END IF;
		
        SELECT LIMIT 1 NVL(nivel,0)INTO iExisteCta  FROM si_cliente_nivel WHERE numcte = cNumcte;
        IF iExisteCta > 0 THEN
            -- SELECT NVL(id_nivel_consulta,0) INTO iNivel FROM si_seg_usuarios WHERE id_usuario=cID_USUARIOC;
			
			EXECUTE PROCEDURE "informix".sp_cnsif_valida_nivelacceso_funcionalidad(cID_USUARIOC, cID_FUNCIONC) INTO cCodRet, iNivel;
			IF cCodRet <> '00000' THEN
				RETURN cCodRet;	
			END IF;
			
            IF iNivel=0 THEN
                LET cCodRet = '00076';
                RETURN cCodRet;	
            ELSE
                SELECT NVL(nivel,0) INTO iNivelCte FROM si_cliente_nivel WHERE numcte=cNumcte;
                IF iNivelCte >= iNivel THEN
                    RETURN cCodRet;	
                ELSE
					LET cCodRet = '00075';
					RETURN cCodRet;	
                END IF;
            END IF;
        ELSE
            LET cCodRet = '00000';
            RETURN 	cCodRet;
		END IF;	
	ELSE
		LET cCodRet = '00074';
		RETURN 	cCodRet;
	END IF
END
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 03/04/2020',
'MODULO: GENERAL',
'FUNCIONALIDAD: GENERAL',
'DESCRIPCION: Se agrega la busqueda por cuenta CLABE',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_cnsif_valida_nivelacceso_funcionalidad(pIdUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
			SMALLINT AS nivel_acceso;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNivelAcceso SMALLINT;
	DEFINE cIdModulo CHAR(6);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNivelAcceso = 0;
	LET cIdModulo = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNivelAcceso;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cnsif_valida_nivelacceso_funcionalidad.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SELECT b.id_modulo, b.nivel_acceso
		INTO cIdModulo, iNivelAcceso
		FROM bdinteg:si_seg_funciones a, bdinteg:si_seg_nivel_acceso_modulo b
		WHERE id_funcion = pIdFuncion
			AND b.id_usuario = pIdUsuario
			AND b.id_modulo = a.id_modulo;
		
		IF cIdModulo IS NULL THEN
			LET cCodRet = '00076'; -- El usuario no cuenta con niveles para realizar la consulta;
		END IF;
		
		RETURN cCodRet, iNivelAcceso;
	
	END;
	
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 30/12/2013",
"DESCRIPCION: Determina el nivel de acceso al modulo donde se encuentra la funciÃ³n invocada",
"BD: bdinteg";

CREATE PROCEDURE "informix".sp_obt_datosusuario_iccat(pEmpresa CHAR(3), pCliente CHAR(9), pTarjeta CHAR(20), pCuenta CHAR(20))
   returning CHAR(5), CHAR(20), CHAR(20), CHAR(20), CHAR(20), CHAR(20), CHAR(20), CHAR(20), DATE, DATE, CHAR(1),
 		  CHAR(30), CHAR(25), CHAR(30), CHAR(30), CHAR(10), CHAR(10), CHAR(5), CHAR(13), CHAR(13) ;

--------------------------------------------------------------------------------------------
-- Realizo: Mauricio Leon
-- Actividad: Obtiene los datos de la consulta de clientes del ICCAT
-- Solicito: Mauricio Leon
-- Fecha de Solicitud: 19/11/2008
-- Modifico: Pedro Enrique Zavala Valdez
-- Fecha de Modificacion: 28/04/2009
-- Modifico: Javier Chavez
-- Fecha: 05/05/09
-- Modifico: Pedro Enrique Zavala Valdez
-- Fecha de Modificacion: 04/08/2009
-- Actividad: Se modifcia para obtener unicamente un registro de la direccion del cliente
-- Modificaco: Sergio Fernandez
-- Fecha: Enero 2012
-- Modificacion: cambio de tabla de consulta de si_direcciones por si_direcciones_actual
-- Actividad: Se modifica para que consulte los datos telefono y correo de las nuevas tablas si_telefonos_actual y si_correos. Viridiana Rosas.
-- Fecha: DIC 2012
---------------------------------------------------------------------------------------------

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
    DEFINE cod_ret CHAR(5);
    DEFINE sql_err INTEGER ;
    DEFINE vStatusCred CHAR(2);
    DEFINE vStatusTar CHAR(1);
    DEFINE vSecuencia SMALLINT ;
    DEFINE vApellido1 CHAR(20);
    DEFINE vApellido2 CHAR(20);
    DEFINE vNombre1 CHAR(20);
    DEFINE vNombre2 CHAR(20);
    DEFINE vFechaAlta DATE ;
    DEFINE vFechaNac DATE ;
    DEFINE vSexo CHAR(1);
    DEFINE vEstado  CHAR(30);
    DEFINE vMunicipio CHAR(25);
    DEFINE vColonia CHAR(30);
    DEFINE vCalle CHAR(30);
    DEFINE vNumExterior CHAR(10);
    DEFINE vNumInterior CHAR(10);
    DEFINE vCodPostal CHAR(5);
    DEFINE vTelefono1 CHAR(13);
    DEFINE vTelefono2  CHAR(13);
	DEFINE vTipo CHAR(1);
	DEFINE cProdTransfer CHAR(4);
	DEFINE cProdTarjeta CHAR(4);
	DEFINE numCteBanco char(9);
	DEFINE binPay CHAR(6);
-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   LET cod_ret  = "000";
   LET vStatusCred = '';
   LET vStatusTar = '';
   LET vSecuencia = 0;
   LET vApellido1 = '';
   LET vApellido2 = '';
   LET vNombre1 = '';
   LET vNombre2 = '';
   LET vFechaAlta = '01-01-1900';
   LET vFechaNac = '01-01-1900';
   LET vSexo = '';
   LET vEstado = '';
   LET vMunicipio = '';
   LET vColonia = '';
   LET vCalle = '';
   LET vNumExterior = '';
   LET vNumInterior = '';
   LET vCodPostal = '';
   LET vTelefono1 = '';
   LET vTelefono2 = '';
   LET vTipo = '';
   LET cProdTransfer = "";
   LET cProdTarjeta = "";
   LET numCteBanco = '';
   LET binPay = '';
   
BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret, pCliente, pCuenta, pTarjeta, vApellido1, vApellido2, vNombre1,
                            vNombre2, vFechaAlta, vFechaNac, vSexo, vEstado, vMunicipio, vColonia, vCalle,
                            vNumExterior, vNumInterior, vCodPostal, vTelefono1, vTelefono2;
      END IF ;
	  
   END EXCEPTION ;
   
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;	
	
      --SET DEBUG FILE TO "/respaldosbd/mario/sp_obt_datosusuario_iccat.out";
      --TRACE ON;
	
	IF (pTarjeta <> "") THEN
	
				SELECT creditodebito,bin INTO vTipo,binPay FROM intercard:"informix".bines WHERE bin = substring(pTarjeta FROM 1 FOR 6);
				
				IF (binPay = '514014') THEN
				
						SELECT DISTINCT c.numcuenta,a.numcte_banco,'ACTIVO'
						INTO pCuenta,pCliente,vStatusTar
						FROM bdinteg:"informix".si_relacion_ctebcplcpl AS a
						INNER JOIN intercard:"informix".tarjeta AS b ON a.numcte_banco = b.numcliente AND SUBSTR(a.num_tar_coppelaplazos, 0, 6) = '514014'
						INNER JOIN intercard:"informix".tarjetacuenta AS c ON b.numtarjeta = c.numtarjeta
						INNER JOIN intercard:"informix".cuenta AS d	ON c.numcuenta = d.numcuenta
						WHERE SUBSTR(d.codprodcta, 0, 2) = '65'
						AND b.numtarjeta = pTarjeta
						AND a.numcte_banco != '';
						
				ELIF (vTipo = 'C') THEN
				
						SELECT num_credito, numcte, status_tar
						INTO pCuenta, pCliente, vStatusTar 
						FROM bdicred:"informix".sd_tarjeta 
						WHERE empresa = pEmpresa
						AND num_tarjeta = pTarjeta;
						
						IF (pCuenta = '') THEN
							 LET cod_ret = '002'; --Numero de tarjeta inexistente
						END IF;
						
				ELIF (vTipo = 'D') THEN
				
						SELECT cuenta,numcte, status_tar
						INTO pCuenta, pCliente, vStatusTar
						FROM bdicheq:"informix".sc_tarjeta
						WHERE empresa = pEmpresa
						AND num_tarjeta = pTarjeta;
					
						IF (pCuenta = '') THEN
							 LET cod_ret = '002'; --Numero de tarjeta inexistente
						END IF;
						
				ELSE
						LET cod_ret = '002';					
				END IF;
				
				SELECT valor
				INTO cProdTransfer
				FROM bditransfer:"informix".tf_param 
				WHERE cod_param = 4;

				SELECT prodtarjeta 
				INTO cProdTarjeta
				FROM bdicheq:"informix".sc_tarjeta 
				WHERE num_tarjeta = pTarjeta;

				IF TRIM(cProdTransfer) = TRIM(cProdTarjeta) THEN
				
					LET cod_ret = "858";
					
				END IF
	
	ELIF (pCuenta <> "") THEN
	
			IF(LENGTH(pCuenta) = 12) THEN
				--credito
				IF EXISTS(SELECT numcte FROM bdicred:"informix".sd_maecred WHERE empresa = pEmpresa AND num_credito = pCuenta) THEN
					
					SELECT nvl(MAX(secuencia),0)
					INTO vSecuencia
					FROM bdicred:"informix".sd_tarjeta
					WHERE empresa = pEmpresa
					AND num_credito = pCuenta;
					
					SELECT LIMIT 1 num_tarjeta, numcte
					INTO pTarjeta, pCliente 
					FROM bdicred:"informix".sd_tarjeta 
					WHERE empresa = pEmpresa
					AND num_credito = pCuenta
					AND nvl(secuencia,0) = vSecuencia;
					
				ELSE
				
					LET cod_ret = '003'; --Numero de credito inexistente
					
				END IF;
				
			ELIF (LENGTH(pCuenta)=11) THEN 
				--debito
				IF EXISTS(SELECT num_cte FROM bdicheq:"informix".sc_maechq WHERE empresa = pEmpresa AND cuenta = pCuenta) THEN
					
					SELECT LIMIT 1 num_tarjeta, numcte
					INTO pTarjeta, pCliente
					FROM bdicheq:"informix".sc_tarjeta
					WHERE empresa = pEmpresa
					AND cuenta = pCuenta;
					
					IF (pCliente = '' OR pCliente IS NULL) THEN
					
						SELECT num_cte INTO pCliente FROM bdicheq:"informix".sc_maechq WHERE empresa = pEmpresa AND cuenta = pCuenta;
						
					END IF;
					
				ELSE
					LET cod_ret = '003'; --Numero de debito inexistente
				END IF;				
			END IF;    
    --END IF ;
	ELIF (pCliente <> "") THEN -- 08-24-Softtek
	
			SELECT DISTINCT a.numcte_banco
			INTO numCteBanco
			FROM bdinteg:"informix".si_relacion_ctebcplcpl AS a
			INNER JOIN intercard:"informix".tarjeta AS b ON a.numcte_banco = b.numcliente
			INNER JOIN intercard:"informix".tarjetacuenta AS c ON b.numtarjeta = c.numtarjeta
			INNER JOIN intercard:"informix".cuenta AS d ON c.numcuenta = d.numcuenta
			WHERE SUBSTR(d.codprodcta, 0, 2) = '65'
			AND a.cliente = pCliente
			AND a.numcte_banco != '';
			
	END IF ;

    IF (numCteBanco IS NULL OR numCteBanco = '') THEN
	    LET numCteBanco = pCliente;
    END IF;
	
	SELECT  LIMIT 1 rpad(TRIM(nvl(a.apell_paterno,'')),20,' ') AS apellpaterno,       --Apellido 1
					rpad(TRIM(nvl(a.apell_materno,'')),20,' ') AS apellmaterno,     --Apellido 2				
					rpad(TRIM(nvl(a.nombre1,'')),20,' ') AS nombre1,      -- Nombre 1
					rpad(TRIM(nvl(a.nombre2,'')),20,' ') AS nombre2,      -- Nombre 2
					nvl(a.fecha_alta, DATE(1)) AS fechaalta, --Fecha alta de cliente
					nvl(b.fecha_nac, DATE(1)) AS fechanac,    -- Fecha de nacimiento
					rpad(TRIM(nvl(b.sexo,'')),1,' ') AS sexo -- Sexo
    INTO vApellido1, vApellido2, vNombre1, vNombre2, vFechaAlta, vFechaNac, vSexo
    FROM bdinteg:"informix".si_cliente a
	LEFT OUTER JOIN bdinteg:"informix".si_ctepf b ON (b.empresa=a.empresa AND b.numcte = a.numcte)
    WHERE a.empresa= pEmpresa
	AND a.numcte = numCteBanco;

    SELECT LIMIT 1 rpad(TRIM(nvl(e.nombre,'')),30,' ') AS estado, -- Estado
				   nvl(z.municipiozona, '') AS municipio,  -- Municipio / Delegacion
				   nvl(z.NombreZona,'') AS colonia, --Colonia
				   nvl(c.nombrecalle,'') AS calle, --Calle
				   TRIM(d.numeroextcalle) AS numextcalle,   -- Numero exterior
				   TRIM(d.numerointcalle) AS numintecalle,  -- Numero interior
				   lpad(TRIM(d.cod_postal),5,'0') AS cod_postal     -- Codigo postal				   
    INTO vEstado, vMunicipio, vColonia, vCalle, vNumExterior, vNumInterior, vCodPostal --, vTelefono1, vTelefono2
    FROM bdinteg:"informix".si_cliente a
	LEFT OUTER JOIN bdinteg:"informix".si_direcciones_actual d ON (d.numcte = a.numcte AND d.tipo_dir  = '1')
	LEFT OUTER JOIN bdinteg:"informix".si_estados e ON (e.estado = d.estado)
	LEFT OUTER JOIN bdinteg:"informix".si_catzonas z ON (d.numerociudad = z.numerociudad AND d.numerocolonia = z.numerocolonia)
	LEFT OUTER JOIN bdinteg:"informix".si_catcalles c ON (d.numerocalle  = c.numerocalle)						
    WHERE a.NumCte = numCteBanco ;		
	
	IF (vNombre1 = "" OR vNombre1 IS NULL AND cod_ret = '000') THEN
		LET cod_ret = '005';
	END IF;
				
				--CONSULTA LOS NUEVOS TELEFONOS
	LET vTelefono1 = '';
	LET vTelefono2 = '';

	SELECT telefono
	INTO vTelefono1 ---TELEFONO PARTICULAR
	FROM bdinteg:"informix".si_telefonos_actual
	WHERE numcte = numCteBanco
	AND tipo_tel = 1;

	SELECT telefono
	INTO vTelefono2 ---TELEFONO CELULAR
	FROM bdinteg:"informix".si_telefonos_actual
	WHERE numcte = numCteBanco
	AND tipo_tel = 2;

   RETURN cod_ret, numCteBanco, pCuenta, pTarjeta, vApellido1, vApellido2, vNombre1,
                    vNombre2, vFechaAlta, vFechaNac, vSexo, vEstado, vMunicipio, vColonia, vCalle,
                     vNumExterior, vNumInterior, vCodPostal, vTelefono1, vTelefono2;

END
END PROCEDURE
DOCUMENT
"Folio:1636",
"Autor:951421354 Mario Gallardo",
"Fecha:29/08/2014",
"Modificacion: Se modifica SP para retornar error 858 en caso de que el producto de la tarjeta sea 8000.",
"Sustento: Cambios_Plataforma_Observaciones.doc",
"Solicita:Berenice Mendez Riveraz ",
"BD: bdinteg";

CREATE PROCEDURE "informix".ctemoral(pempresa char(3),
			  pfuncion 			char(1),
			  pnumcte 			char(20),
              pdato 			char(2),
			  psucursal 		char(4),
			  pejecutivo 		char(8),
			  ptp_persona 		char(2),
			  ptp_cliente 		char(1),
			  prazon_social 	char(254),
			  prfc       		char(13),
			  pfechaalta  		date,
			  pnacionalidad   	char(2),
			  pnombrecorto    	char(60),
			  pnombrecontacto 	char(48),
			  ptelefonocontacto char(13),
			  psufijo 			char(2),
			  pgiro 			char(20),
 			  pactividad_princ 	char(3),
              ppaginainternet 	char(30),
			  pejecutivo2 		char(8),
			  pfechaalta2 		date,
			  pCURP             CHAR(20),
			  pRFCAlt           CHAR(13),
			  pRegimen			CHAR(3))
 returning char(5),char(20);

define v_codret char(5);
define v_cliente,vnumcte char(20);
define v_nombre char(40);
define v_fecha date;
define v_signumcte int;
define v_rowid,v_rowid2 integer;
define v_tppersona char(2);
define v_cont1,v_cont2 smallint;
define v_esfisica char(1);
define v_longitud,vlong_cte smallint;
define v_sucursal char(4);
define v_razon_social char(120);
define v_ejecutivo char(8);
define v_tp_cliente char(1);
define v_rfc char (13);
define v_sector char (2);
define v_segmento char (3);
define v_actividad_princ char (3);
define v_grupo char(3);
define v_subgrupo char(3);
define v_nacionalidad char(2);
define v_residencia char(1);
define v_nombre_comercial,v_nombre_titular char(40);
define v_giro char(20);
define v_fecha_inscrip,v_fecha_constit date;
define v_sqlerr,v_isamerr integer;
DEFINE v_apodo CHAR(20);
DEFINE v_distrito CHAR(2);
define vcod_param smallint;
define vdescripcion char(40);
define vdiferencia, i smallint;
DEFINE vRFC CHAR(13);
DEFINE cCodRetAux CHAR(5);
DEFINE vcteApo CHAR(20);
DEFINE v_canal CHAR(2);

define psegmento char(3);
define pgrupo char(3);
define psubgrupo char(3);


--set debug file to "/tmp/mfinis/ctemoral.out";
--trace on;


--begin
--on exception set v_sqlerr,v_isamerr
--	if v_sqlerr !=0 then
--		let v_codret=v_sqlerr;
--		return v_codret,vnumcte;
--	end if;
--end exception;

set isolation to dirty read;
SET LOCK MODE TO WAIT 3;

let psegmento = "000";
let pgrupo = "000";
let psubgrupo = "000";


let vnumcte = "000000000";
let v_codret = "000";
LET vRFC = '';
LET cCodRetAux ='';
LET vcteApo ='';
LET v_canal = '0';

--- *************************** Validaciones ******************************
select fecha_hoy into v_fecha from bdinteg:"informix".si_fechas WHERE empresa = pempresa;
if pfuncion="A" then

	--- Verifica recepcion correcta de datos
	if psucursal is null
		or pejecutivo is null
		or ptp_persona is null
		or ptp_cliente is null
		or prfc is null
		or pactividad_princ is null
		or psubgrupo is null
		or pnombrecorto is null
		or pgiro is null then
		let v_codret = "110";
		return v_codret,vnumcte;
	end if;

---*************************** Extraccion de Parametros ***************
	if pnumcte is null or pnumcte = " " then
   	   select valor into vlong_cte
    	      from bdinteg:"informix".si_param
    	      WHERE cod_param = 7 AND empresa = pempresa;
   	   if vlong_cte is null then
	      let v_codret="105";
    	      return v_codret,vnumcte;
       	   end if

           SELECT valor INTO v_signumcte
              FROM bdinteg:"informix".si_param
              WHERE empresa = pempresa and cod_param = 6;
           LET vnumcte = v_signumcte;
           LET v_signumcte = v_signumcte + 1;
           UPDATE bdinteg:"informix".si_param
              SET (valor) = (v_signumcte)
              WHERE empresa = pempresa and cod_param = 6;
           let vdiferencia = vlong_cte - length(vnumcte);
           if vdiferencia > 0 then
              for i = 1 to vdiferencia
                  let vnumcte = "0" || vnumcte;
              end for;
           end if
	else
	   let vnumcte=pnumcte;
	end if;

 	select numcte into v_cliente
                from bdinteg:"informix".si_cliente
                where numcte = vnumcte;
        if v_cliente = vnumcte then
                let v_codret="118";
                return v_codret,vnumcte;
        end if;
        let ptp_persona = ptp_persona;
        let ptp_cliente = ptp_cliente;
	select es_fisica into v_esfisica from bdinteg:"informix".si_tipper
  	   where tpo_persona = ptp_persona;
	if v_esfisica is null or
           (v_esfisica != "N" and v_esfisica != "n") then
           let v_codret = "120";
           return v_codret,vnumcte;
	end if;

 	select nombre into v_nombre
                from bdinteg:"informix".si_sucursales
                where sucursal=psucursal;
        if v_nombre is null then
                let v_codret="111";
                return v_codret,vnumcte;
        end if;

        select nombre into v_nombre
                from bdinteg:"informix".si_ejecut
                where ejecutivo=pejecutivo;
        if v_nombre is null then
                let v_codret="112";
                return v_codret,vnumcte;
        end if;

 	/*select nombre into v_nombre
                from si_actecon
                where actividad=pactividad_princ;
        if v_nombre is null then
                let v_codret="125";
                return v_codret,vnumcte;
        end if;*/
		
		--SELECT numcteapoderado	
	--	INTO vcteApo
	--	FROM "informix".si_apoderado where numcte = TRIM(pnumcte);
		
	--	IF NVL (vcteApo,'') = '' THEN
	--	  let v_codret="00022";
     --           return v_codret,vnumcte;
	--	END IF;
		
        SELECT numcte	
		INTO vcteApo
		FROM "informix".si_ctepf where numcte = TRIM(vnumcte);	 
		
	   IF nvl (psufijo,'') ='' THEN 
		LET psufijo ='99';
	   END IF;

	   	SELECT cve_canal 
		INTO  v_canal
		FROM bdinteg:si_canal
		WHERE nombre_canal = 'SOC';

-- ********************** Actualizacion de Parametros ************************

   begin
	
   	insert into bdinteg:"informix".si_cliente
          (numcte,      empresa,      status_cte,     sucursal,     ejecutivo,
           tpo_persona, tipo_cliente, apell_paterno,  apell_materno,
           nombre1,     nombre2,      razon_social,   rfc,
           sector,      segmento,     actividad_princ,grupo,
           subgrupo,    residencia,   fecha_alta, rfc_alterno)
        values
          (vnumcte,    pempresa,     pdato,            psucursal,    pejecutivo,
           ptp_persona, ptp_cliente,  " ",            " ",
           " ",         " ",          prazon_social,  prfc,
           "31",     psegmento,    pactividad_princ, pgrupo,
           psubgrupo,   "1",        v_fecha, pRFCAlt );

	insert into bdinteg:"informix".si_ctepm
           (empresa,numcte,  giro, nombre_corto, nombre_contacto, telefono_contacto, sufijo,pagina_internet,nacionalidad,
            actividadsocial,operador,sucursal,fecha_alta)
         values
           (pempresa, vnumcte,pgiro,pnombrecorto, pnombrecontacto, ptelefonocontacto, psufijo, ppaginainternet,pnacionalidad,
            pactividad_princ,pejecutivo,psucursal,pfechaalta);
			
			update bdinteg:"informix".si_ctepf set curp =pCURP  where numcte =vcteApo;
			
	insert into bdinteg:"informix".si_fiscal
			(empresa, numcte, sucursal, ejecutivo, nom_razon_soc, cod_postal, rfc, regim_fiscal, fecha_hora, canal)
	values ( pempresa,vnumcte, psucursal, pejecutivo,  prazon_social, '', prfc, pRegimen, 	CURRENT YEAR TO SECOND, 	v_canal);
   end;
   return v_codret,vnumcte;

elif pfuncion = "B" then


	let pnumcte = pnumcte;


	select rowid,tpo_persona into v_rowid,v_tppersona
	  from bdinteg:"informix".si_cliente
      	 where numcte = pnumcte;
      	if v_rowid is null then
       	   let vnumcte=pnumcte;
       	   let v_codret = "104";
       	   return v_codret,pnumcte;
	else
	   select es_fisica into v_esfisica
	     from bdinteg:"informix".si_tipper
	    where tpo_persona=v_tppersona;

        let v_esfisica = v_esfisica;

        if v_esfisica != "N" then
       	     let v_codret = "12a0";
       	     return v_codret,pnumcte;
	   end if;
      	end if

--   	select count(*) into v_cont2 from bdicheq:sc_maechq
--      	 where num_cte = pnumcte;
--      	if v_cont2>0 then
--          let vnumcte = pnumcte;
--       	  let v_codret = "121";
--       	  return v_codret,pnumcte;
--      	end if

--   	select count(*) into v_cont2 from bdisolic:ss_solicitudes
--      	 where num_cte = pnumcte;
--      	if v_cont2>0 then
--          let vnumcte = pnumcte;
--       	  let v_codret = "121";
--       	  return v_codret,pnumcte;
--      	end if

--   	select count(*) into v_cont2 from bdicred:sd_maecred
--      	 where num_cte = pnumcte;
--      	if v_cont2>0 then
---          let vnumcte = pnumcte;
--       	  let v_codret = "121";
--       	  return v_codret,pnumcte;
--      	end if
   	let vnumcte = pnumcte;
	begin
		/*Nueva tabla*/
	  delete from bdinteg:"informix".si_fiscal 
	  		where numcte = pnumcte;

   	  delete from bdinteg:"informix".si_cliente
      	   where rowid=v_rowid;

	  delete from bdinteg:"informix".si_ctepf where numcte = pnumcte;
	end;
else
	select rowid,sucursal,ejecutivo,rfc,
	       actividad_princ
	  into v_rowid,v_sucursal,v_ejecutivo,
	       v_rfc, v_actividad_princ
	  from bdinteg:"informix".si_cliente
	  where numcte = pnumcte;

	if v_rowid is null then
        	let v_codret = "104";
         	return v_codret,pnumcte;
	end if

	if psucursal is null then
		let psucursal=v_sucursal;
	end if;

	if pejecutivo is null then
	  	let pejecutivo=v_ejecutivo;
	end if;

	if ptp_persona is null then
		let ptp_persona=v_tppersona;
	end if;

	if ptp_cliente is null then
		let ptp_cliente = v_tp_cliente;
	end if;

	if prazon_social is null then
		let prazon_social=v_razon_social;
	end if;

	if psufijo is null then
		let prfc=v_rfc;
	end if;
	
	SELECT numcteapoderado	
		INTO vcteApo
		FROM "informix".si_apoderado where numcte = TRIM(pnumcte);
		
		IF NVL (vcteApo,'') = '' THEN
		  	let v_codret="104";
            return v_codret,vnumcte;
		END IF;
			   
	   IF nvl (psufijo,'') ='' THEN 
		LET psufijo ='99';
	   END IF;

	   	SELECT cve_canal 
		INTO  v_canal
		FROM bdinteg:si_canal
		WHERE nombre_canal = 'SOC';

--	select rowid, numcte,nombre_titular,giro,fecha_inscrip,fecha_constit
--	into v_rowid2,vnumcte,	v_nombre_titular,	v_giro,	v_fecha_inscrip,v_fecha_constit
--	from si_ctepm
--	where numcte=pnumcte;
--ACTUALIZACACION 
	/*Nueva tabla*/
	begin
	update bdinteg:"informix".si_fiscal set
		(empresa, sucursal, ejecutivo,  nom_razon_soc, cod_postal, rfc, regim_fiscal, fecha_hora, canal)
		= 
		(pempresa, psucursal, pejecutivo, prazon_social, '', prfc, pRegimen, CURRENT YEAR TO SECOND, v_canal)
	WHERE numcte = pnumcte;

	update bdinteg:"informix".si_cliente set
	     (sucursal,        ejecutivo, tpo_persona,tipo_cliente,
              razon_social,    rfc,  sector,     segmento,
              actividad_princ, grupo,     subgrupo,   residencia,
	      fecha_alta,rfc_alterno)
            =
             (psucursal,       pejecutivo, ptp_persona,ptp_cliente,
              prazon_social,   prfc,       "31",    "000",
              pactividad_princ,pgrupo,     psubgrupo,  "1",
	      v_fecha,pRFCAlt)
        where rowid=v_rowid;

	update bdinteg:"informix".si_ctepm set
             (giro,nombre_corto,nombre_contacto, telefono_contacto, sufijo,pagina_internet,nacionalidad, actividadsocial)
            =
	     (pgiro,pnombrecorto, pnombrecontacto, ptelefonocontacto,psufijo, ppaginainternet,pnacionalidad,pactividad_princ)
	where numcte=pnumcte;
	
	update bdinteg:"informix".si_ctepf set curp =pCURP  where numcte =vcteApo;	
	
	end;

	return v_codret,pnumcte;
end if;
--end;
end procedure
DOCUMENT
"MODIFICO : Manuel Hernandez",
"FECHA : 12/Septiembre/2006",
"MODIFICO : Dulce Ramirez",
"FECHA : 22/Junio/2011",
"DESCRIPCION : Se inhibe select a la tabla si_actecon ya que es la tabla del giro",
" e intentaba buscar la variable que contiene la actividad",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1",
"MODIFICO : Daniel Reyes Guillen",
"FECHA : 24/06/2021",
"DESCRIPCION : Se aÃ±ade rfc alterno y curp persona fisica",
"MODIFICO : JosÃ© Antonio RamÃ­rez Franco",
"FECHA : 29/09/2023",
"DESCRIPCION : SP CLON de ctemoral para SW Prometeo Cliente moral Se aÃ±ade el regimen fiscal y se cambia la logitud del campo Nombre corto y razÃ³n social";

CREATE PROCEDURE "informix".sp_consultahuelladeclinea(pStatus CHAR(1))

--DATOS A REGRESAR---
RETURNING
	CHAR(5) 	AS CodRet,             	
	CHAR(20) 	AS NumCte,
	CHAR(1) 	AS Sexo,
	SMALLINT 	AS Secuencia,
	CHAR(15) 	AS Ip,
	CHAR(4) 	AS Sucursal,
	CHAR(20) 	AS FechaEnroll,
	CHAR(1) 	AS TipoMov,
	CHAR(8) 	AS Empleado,
	CHAR(2) 	AS TipoSensor,
	CHAR(1) 	AS Situacion,
	CHAR(20) 	AS Referencia,
	CHAR(20) 	AS FechaCambio,
	CHAR(2) 	AS TipoCliente,
	CHAR(2) 	AS TipoVerificador,
	SMALLINT 	AS HuellasCap;

/*
SCRIPT DE PROCEDIMIENTO ALMACENADO "sp_consultahuelladeclinea "
Folio.........: 841 - ComparaciÃ³n en linea de 10 huellas.
Autor.........: 90127902 - Carlos VÃ¡zquez Mitre
Fecha.........: 31/01/2022
Solicita......: Juan Francisco Ponce Damian
BD............: bdinteg
*/

-- DEFINICION DE VARIABLES.
DEFINE cCodRet				CHAR(5);
DEFINE iSqlErr				INTEGER;
DEFINE cEmpresa				CHAR(3);
DEFINE shSecuencia			SMALLINT;
DEFINE cNumCte				CHAR(20);
DEFINE cSucursal			CHAR(4);
DEFINE cIp					CHAR(15);
DEFINE iContador			INTEGER;
DEFINE cFechaAlta			CHAR(20);
DEFINE cSexo				CHAR(1);
DEFINE cTipoMov				CHAR(1);
DEFINE cEmpleado			CHAR(8);
DEFINE cTipoSensor			CHAR(2);
DEFINE cSituacion			CHAR(1);
DEFINE cReferencia			CHAR(20);
DEFINE cFechaCambio			CHAR(20);
DEFINE cTipoCliente			CHAR(2);
DEFINE cTipoVerificador		CHAR(2);	
DEFINE iHuellasCap			SMALLINT;
DEFINE cStatus				CHAR(1);

-- SET DEBUG FILE TO '/home/sysifx/sp_consultahuelladeclinea.trc';
-- TRACE ON;

-- INICIALIZACION DE VARIABLE.
LET cCodRet					= '00001';
LET iSqlErr					= 0;
LET cEmpresa				= '';
LET shSecuencia				= 0;
LET cNumCte					= '';
LET cSucursal				= '';
LET cIp						= '';
LET iContador				= 0;
LET cSexo					= '';
LET cTipoMov				= '';
LET cFechaAlta 				= TO_CHAR(CURRENT, '%m/%d/%Y');
LET cFechaCambio 			= TO_CHAR(CURRENT, '%m/%d/%Y');
LET cEmpleado				= '';
LET cTipoSensor				= '';
LET cSituacion				= '';
LET cReferencia				= '';
LET cTipoCliente			= '';
LET cTipoVerificador		= '';
LET iHuellasCap				= 0;
LET cStatus					= '0';

BEGIN
	ON EXCEPTION SET iSqlErr
		IF(iSqlErr != 0) THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumCte, cSexo, shSecuencia, cIp, cSucursal, cFechaAlta, cTipoMov, cEmpleado, cTipoSensor, cSituacion, 
					cReferencia, cFechaCambio, cTipoCliente, cTipoVerificador,iHuellasCap WITH RESUME;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF (NVL(pStatus,'') == '')THEN
		RETURN cCodRet, cNumCte, cSexo, shSecuencia, cIp, cSucursal, cFechaAlta, cTipoMov, cEmpleado, cTipoSensor, cSituacion, cReferencia, 
			cFechaCambio, cTipoCliente, cTipoVerificador,iHuellasCap WITH RESUME;
	ELSE
		FOREACH
			SELECT numcte,secuencia,sexo,sucursal,fecha_alta_huella,
					ip,tipo_mov,empleado,tipo_sensor,status_huella,ref_coppel,tipo_cliente,tipo_verificacion,fecha_ult_cambio,huellas_cap
				INTO cNumCte, shSecuencia,cSexo, cSucursal, cFechaAlta, cIp, cTipoMov, cEmpleado, cTipoSensor, 	cSituacion, cReferencia, 
					cTipoCliente, cTipoVerificador, cFechaCambio, iHuellasCap
			FROM "informix".si_huella_linea_dec
			WHERE status_consulta = pStatus and fecha_consulta=today
			
			LET cCodRet	= '00000';
			
			RETURN cCodRet, cNumCte, cSexo, shSecuencia, cIp, cSucursal, cFechaAlta, cTipoMov, cEmpleado, cTipoSensor, cSituacion, 
				cReferencia,cFechaCambio, cTipoCliente, cTipoVerificador,iHuellasCap WITH RESUME;
		END FOREACH
	END IF;
	
END;
END PROCEDURE;