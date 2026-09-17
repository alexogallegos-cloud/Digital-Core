CREATE PROCEDURE "informix".sp_cnsif_actualizanivelesaccesomodulos(pIdUsuario CHAR(8), pIdFuncion CHAR(10), pIdFuncionC CHAR(8), pIdModulos CHAR(255), pNivelesAcceso CHAR(100))
	RETURNING CHAR(5) AS codret,
			INTEGER AS regitros_procesados;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cModulo CHAR(6);
	DEFINE iNivelAcceso SMALLINT;
	DEFINE iTamCadModulos INTEGER;
	DEFINE iTamCadNiveles INTEGER;
	DEFINE iSelIniModulos INTEGER;
	DEFINE iSelFinModulos INTEGER;
	DEFINE iSelIniNiveles INTEGER;
	DEFINE iSelFinNiveles INTEGER;
	DEFINE iRegistrosAfectados INTEGER;
	DEFINE iNoCaracteres INTEGER;
	DEFINE i INTEGER;
	DEFINE ii INTEGER;
	DEFINE cCaracter CHAR(1);
	DEFINE iExiste SMALLINT;
	DEFINE iTransaccion SMALLINT;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cModulo = '';
	LET iNivelAcceso = 0;
	LET iTamCadModulos = 0;
	LET iTamCadNiveles = 0;
	LET iSelIniModulos = 1;
	LET iSelFinModulos = 0;
	LET iSelIniNiveles = 1;
	LET iSelFinNiveles = 0;
	LET iRegistrosAfectados = 0;
	LET iNoCaracteres = 0;
	LET i = 0;
	LET ii = 0;
	LET cCaracter = '';
	LET iExiste = 0;
	LET iTransaccion = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			ROLLBACK WORK;
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iRegistrosAfectados;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			COMMIT WORK;
			BEGIN WORK;
			LET iTransaccion = 1;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cnsif_actualizanivelesaccesomodulos.out';
		--TRACE ON;
		
		IF pIdUsuario = '' OR pIdFuncion = '' OR pIdFuncionC = '' OR pIdModulos = '' OR pNivelesAcceso = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iRegistrosAfectados;
		END IF;
		
		-- VALIDACIÓN DE ACCESO AL PROCEDIMIENTO
		EXECUTE PROCEDURE 'informix'.sp_cnsif_confirmaejecutivo(pIdUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iRegistrosAfectados;
		END IF;
		
		-- VALIDAMOS QUE EL USUARIO YA HAYA SIDO DADO DE ALTA
		SELECT COUNT(id_usuario)
		INTO iExiste
		FROM 'informix'.si_seg_nivel_acceso_modulo
		WHERE id_usuario = pIdFuncionC;
		
		IF iExiste = 0 THEN
			LET cCodRet = '00025';
			RETURN cCodRet, iRegistrosAfectados;
		END IF;
		
		-- Colocamos un pipe al final de la cadena para que el procedimiento funcione adecuadamente
		LET cCaracter = SUBSTR(TRIM(pIdModulos), LENGTH(TRIM(pIdModulos)), 1);
		IF cCaracter <> '|' THEN
			LET pIdModulos = TRIM(pIdModulos)||'|';
		END IF;
		
		-- Colocamos un pipe al final de la cadena para que el procedimiento funcione adecuadamente
		LET cCaracter = SUBSTR(TRIM(pNivelesAcceso), LENGTH(TRIM(pNivelesAcceso)), 1);
		IF cCaracter <> '|' THEN
			LET pNivelesAcceso = TRIM(pNivelesAcceso)||'|';
		END IF;
		
		LET iTamCadModulos = LENGTH(TRIM(pIdModulos));
		LET iTamCadNiveles = LENGTH(TRIM(pNivelesAcceso));
		
		-- Actualización de los modulos que se vayan insertando y que no tengan
		INSERT INTO 'informix'.si_seg_nivel_acceso_modulo(id_usuario, id_modulo, nivel_acceso)
		SELECT --+AVOID_FULL('informix'.si_seg_modulos) 
		b.id_usuario, a.id_modulo, b.id_nivel_consulta
		FROM bdinteg:si_seg_modulos a, bdinteg:si_seg_usuarios b
		WHERE b.id_usuario = pIdFuncionC
			AND a.id_modulo NOT IN (SELECT id_modulo 
									FROM bdinteg:si_seg_nivel_acceso_modulo 
									WHERE id_usuario = b.id_usuario);

		
		-- INICIAMOS TRANSACCION
		BEGIN WORK;
		
			FOR i = 1 TO iTamCadModulos
				
				LET cCaracter = SUBSTR(TRIM(pIdModulos), i, 1);
				IF cCaracter = '|' THEN
					LET iSelFinModulos = i;
					LET iNoCaracteres = iSelFinModulos - iSelIniModulos;
					LET cModulo = SUBSTR(TRIM(pIdModulos), iSelIniModulos, iNoCaracteres);
					
					-- Obtenemos el valor del nivel de acceso
					FOR ii = iSelIniNiveles TO LENGTH(TRIM(pNivelesAcceso))
						LET cCaracter = SUBSTR(TRIM(pNivelesAcceso), ii, 1);
						IF cCaracter = '|' THEN
							LET iSelFinNiveles = ii;
							LET iNoCaracteres = iSelFinNiveles - iSelIniNiveles;
							LET iNivelAcceso = SUBSTR(TRIM(pNivelesAcceso), iSelIniNiveles, iNoCaracteres);
							LET iSelIniNiveles = ii + 1;
							EXIT FOR;
						END IF;
						
					END FOR;
					
					-- Se realiza la actualización del modulo con el nivel indicado
					UPDATE 'informix'.si_seg_nivel_acceso_modulo
					SET nivel_acceso = iNivelAcceso
					WHERE id_usuario = pIdFuncionC
						AND id_modulo = cModulo;
					
					LET iRegistrosAfectados = iRegistrosAfectados + 1;
					
					LET iSelIniModulos = i + 1;
				END IF;
				
			END FOR;
		
		COMMIT WORK;
		
		IF iTransaccion = 1 THEN
			BEGIN WORK;
		END IF;
		
		RETURN cCodRet, iRegistrosAfectados;
		
	END;
	
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 30/12/2013",
"DESCRIPCION: Procedimiento que actualiza los niveles de acceso para un usuario",
"BD: bdinteg";

CREATE PROCEDURE "informix".sp_cnsif_buscausuario(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cID_USUARIO CHAR (8),cNOMBRE CHAR(45),cSTATUS CHAR(1),cID_NIVEL_CONSULTA INTEGER,cID_PERFIL CHAR(10),cTIPOBUSQUEDA CHAR(1),pNumRegistro INTEGER,pRecuperacion INTEGER)

    RETURNING CHAR(5),CHAR(8),CHAR(45),CHAR(1),INTEGER,CHAR(60),CHAR(10),CHAR(100), INTEGER, CHAR(1);
				

	--Variables
	DEFINE iexiste 				INT;
	DEFINE cCodRet 				CHAR(5);
	DEFINE iSql_err 			INT;
	DEFINE cId_usuario2			CHAR(8);
	DEFINE cNombre2				CHAR(45);
	DEFINE cStatus2 			CHAR(1);
	DEFINE cId_nivel_consulta2 	INTEGER;
	DEFINE cD_nivel_consulta	CHAR(60);
	DEFINE cId_perfil2			CHAR(10);
	DEFINE cd_perfil2			CHAR(100);
	DEFINE iUsu_bloqueo			INTEGER;
	DEFINE cUsu_estado			CHAR(1);
    DEFINE iCont            INTEGER;
	

	--inicializando variables
	LET iexiste 	= 0;
	LET cCodRet 	= "00000";	
	LET iSql_err 	= 0;
	LET cId_usuario2 = '';
	LET cNombre2	= '';
	LET cStatus2 	= '';
	LET cId_nivel_consulta2	= 0;
	LET cId_perfil2			= '';
	LET cd_perfil2			= '';
	LET iUsu_bloqueo	 = 0;
	LET cUsu_estado = "";
	LET cD_nivel_consulta = "";
    LET iCont=0;
	BEGIN
	
		ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET cCodRet = iSql_err;
                RETURN cCodRet,cId_usuario2,cNombre2,cStatus2,cId_nivel_consulta2,cD_nivel_consulta,cId_perfil2,cD_perfil2,iUsu_bloqueo,cUsu_estado;
            END IF;
        END EXCEPTION;
		--SET DEBUG FILE TO "/informix/VH/sp_cnsif_buscausuario.out";
		--TRACE ON;
		IF cTIPOBUSQUEDA <> '1' AND cTIPOBUSQUEDA <> '2' THEN 
			LET cCodRet = "00005";
			RETURN cCodRet,cId_usuario2,cNombre2,cStatus2,cId_nivel_consulta2,cD_nivel_consulta,cId_perfil2,cD_perfil2,iUsu_bloqueo,cUsu_estado;
		END IF; 

        IF pNumRegistro<0 THEN
            LET cCodRet='00098';
            RETURN cCodRet,cId_usuario2,cNombre2,cStatus2,cId_nivel_consulta2,cD_nivel_consulta,cId_perfil2,cD_perfil2,iUsu_bloqueo,cUsu_estado;
        ELSE
            IF pRecuperacion<=0 THEN
                LET cCodRet='00098';
                RETURN cCodRet,cId_usuario2,cNombre2,cStatus2,cId_nivel_consulta2,cD_nivel_consulta,cId_perfil2,cD_perfil2,iUsu_bloqueo,cUsu_estado;
            END IF;
        END IF; 		
		
		EXECUTE FUNCTION sp_cnsif_confirmaejecutivo (cID_USUARIOC,cID_FUNCIONC)
		INTO cCodRet;
		  
		IF cCodRet = '00028' THEN 
			RETURN cCodRet,cId_usuario2,cNombre2,cStatus2,cId_nivel_consulta2,cD_nivel_consulta,cId_perfil2,cD_perfil2,iUsu_bloqueo,cUsu_estado;
		END IF;
		
		IF cTIPOBUSQUEDA = 2 THEN
			IF cID_USUARIO = '' AND  cNOMBRE = '' AND cSTATUS = '' AND cID_NIVEL_CONSULTA = '' AND cID_PERFIL = '' THEN
				LET cCodRet = "00003";
				RETURN cCodRet,cId_usuario2,cNombre2,cStatus2,cId_nivel_consulta2,cD_nivel_consulta,cId_perfil2,cD_perfil2,iUsu_bloqueo,cUsu_estado;
			END IF; 	
			
			IF cID_USUARIO <> '' THEN
                SELECT nvl(Count(id_usuario),0) INTO iexiste  FROM si_seg_usuarios US LEFT JOIN si_ejecut EJ ON EJ.ejecutivo = US.Id_usuario WHERE Us.id_usuario LIKE TRIM(cID_USUARIO)||'%' AND EJ.vigencia>=today;
                IF iexiste = 0 THEN
                    LET cCodRet = "00002";
                    RETURN cCodRet,cId_usuario2,cNombre2,cStatus2,cId_nivel_consulta2,cD_nivel_consulta,cId_perfil2,cD_perfil2,iUsu_bloqueo,cUsu_estado;
                END IF;
				set isolation to dirty read;
				FOREACH
					SELECT SKIP pNumRegistro FIRST pRecuperacion US.id_usuario, EJ.nombre,US.status,US.id_nivel_consulta,NC.d_nivel_consulta,US.id_perfil,PE.d_perfil,US.usu_bloqueo 
					INTO 
					cId_usuario2,cNombre2,cStatus2,cId_nivel_consulta2,cD_nivel_consulta,cId_perfil2,cD_perfil2,iUsu_bloqueo
					FROM  si_seg_usuarios US
					LEFT JOIN si_ejecut EJ
					ON EJ.ejecutivo = US.Id_usuario
					LEFT JOIN si_seg_perfiles PE
					ON PE.id_perfil = US.Id_perfil
					LEFT JOIN si_seg_nivel_consulta NC
					ON NC.id_nivel_consulta = US.id_nivel_consulta	
					WHERE Us.id_usuario LIKE TRIM(cID_USUARIO)||'%'
                    AND EJ.vigencia>=today order by 1

                    
                    SELECT LIMIT 1 nvl(status,"") INTO cUsu_estado FROM si_macejecutivo
                    WHERE status='A' AND ejecutivo=cID_USUARIO;

                    LET iCont=iCont+1;
					RETURN cCodRet,cId_usuario2,cNombre2,cStatus2,cId_nivel_consulta2,cD_nivel_consulta,cId_perfil2,cD_perfil2,iUsu_bloqueo,cUsu_estado with resume;
				END FOREACH;
                IF iCont = 0 THEN
                    LET cCodRet = 1001; 
                    RETURN cCodRet,cId_usuario2,cNombre2,cStatus2,cId_nivel_consulta2,cD_nivel_consulta,cId_perfil2,cD_perfil2,iUsu_bloqueo,cUsu_estado;
                END IF 
			ELIF cNOMBRE <> '' THEN
                    SELECT nvl(Count(id_usuario),0) INTO iexiste  FROM si_seg_usuarios US LEFT JOIN si_ejecut EJ ON EJ.ejecutivo = US.Id_usuario WHERE EJ.Nombre LIKE'%'||TRIM(cNOMBRE)||'%' AND EJ.vigencia>=today;
                    IF iexiste = 0 THEN
                        LET cCodRet = "00002";
                        RETURN cCodRet,cId_usuario2,cNombre2,cStatus2,cId_nivel_consulta2,cD_nivel_consulta,cId_perfil2,cD_perfil2,iUsu_bloqueo,cUsu_estado;
                    END IF;
					set isolation to dirty read;
					FOREACH
						SELECT SKIP pNumRegistro FIRST pRecuperacion US.id_usuario, EJ.nombre,US.status,US.id_nivel_consulta,NC.d_nivel_consulta,US.id_perfil,PE.d_perfil,US.usu_bloqueo
						INTO 
						cId_usuario2,cNombre2,cStatus2,cId_nivel_consulta2,cD_nivel_consulta,cId_perfil2,cD_perfil2,iUsu_bloqueo
						FROM  si_seg_usuarios US
						LEFT JOIN si_ejecut EJ
						ON EJ.ejecutivo = US.Id_usuario
						LEFT JOIN si_seg_perfiles PE
						ON PE.id_perfil = US.Id_perfil
						LEFT JOIN si_seg_nivel_consulta NC
						ON NC.id_nivel_consulta = US.id_nivel_consulta	
						WHERE EJ.Nombre LIKE'%'||TRIM(cNOMBRE)||'%'
                        AND EJ.vigencia>=today order by 1

                        SELECT LIMIT 1 nvl(status,"") INTO cUsu_estado FROM si_macejecutivo
                        WHERE status='A' AND ejecutivo=cID_USUARIO;

                        LET iCont=iCont+1;
						RETURN cCodRet,cId_usuario2,cNombre2,cStatus2,cId_nivel_consulta2,cD_nivel_consulta,cId_perfil2,cD_perfil2,iUsu_bloqueo,cUsu_estado with resume;
					END FOREACH;
                    IF iCont = 0 THEN
                        LET cCodRet = 1001; 
                        RETURN cCodRet,cId_usuario2,cNombre2,cStatus2,cId_nivel_consulta2,cD_nivel_consulta,cId_perfil2,cD_perfil2,iUsu_bloqueo,cUsu_estado;
                    END IF 
			ELIF cSTATUS <> '' THEN
                        SELECT --+AVOID_FULL('informix'.si_seg_usuarios)
						nvl(Count(id_usuario),0) INTO iexiste  FROM si_seg_usuarios US LEFT JOIN si_ejecut EJ ON EJ.ejecutivo = US.Id_usuario WHERE US.Status LIKE TRIM(cSTATUS)||'%' AND EJ.vigencia>=today;
                        IF iexiste = 0 THEN
                            LET cCodRet = "00002";
                            RETURN cCodRet,cId_usuario2,cNombre2,cStatus2,cId_nivel_consulta2,cD_nivel_consulta,cId_perfil2,cD_perfil2,iUsu_bloqueo,cUsu_estado;
                        END IF;
						set isolation to dirty read;
						FOREACH
							SELECT SKIP pNumRegistro FIRST pRecuperacion US.id_usuario, EJ.nombre,US.status,US.id_nivel_consulta,NC.d_nivel_consulta,US.id_perfil,PE.d_perfil,US.usu_bloqueo 
							INTO 
							cId_usuario2,cNombre2,cStatus2,cId_nivel_consulta2,cD_nivel_consulta,cId_perfil2,cD_perfil2,iUsu_bloqueo
							FROM  si_seg_usuarios US
							LEFT JOIN si_ejecut EJ
							ON EJ.ejecutivo = US.Id_usuario
							LEFT JOIN si_seg_perfiles PE
							ON PE.id_perfil = US.Id_perfil
							LEFT JOIN si_seg_nivel_consulta NC
							ON NC.id_nivel_consulta = US.id_nivel_consulta
							WHERE US.Status LIKE TRIM(cSTATUS)||'%'
                            AND EJ.vigencia>=today order by 1

                            SELECT LIMIT 1 nvl(status,"") INTO cUsu_estado FROM si_macejecutivo
                            WHERE status='A' AND ejecutivo=cID_USUARIO;

                            LET iCont=iCont+1;
							RETURN cCodRet,cId_usuario2,cNombre2,cStatus2,cId_nivel_consulta2,cD_nivel_consulta,cId_perfil2,cD_perfil2,iUsu_bloqueo,cUsu_estado with resume;
						END FOREACH;
                        IF iCont = 0 THEN
                            LET cCodRet = 1001; 
                            RETURN cCodRet,cId_usuario2,cNombre2,cStatus2,cId_nivel_consulta2,cD_nivel_consulta,cId_perfil2,cD_perfil2,iUsu_bloqueo,cUsu_estado;
                        END IF 
			ELIF cast(cID_NIVEL_CONSULTA as char(1)) <> '' THEN
                            SELECT --+AVOID_FULL('informix'.si_seg_usuarios)
							nvl(Count(id_usuario),0) INTO iexiste  FROM si_seg_usuarios US LEFT JOIN si_ejecut EJ ON EJ.ejecutivo = US.Id_usuario WHERE cast (US.id_nivel_consulta as char(1)) LIKE (cID_NIVEL_CONSULTA)||'%' AND EJ.vigencia>=today;
                            IF iexiste = 0 THEN
                                LET cCodRet = "00002";
                                RETURN cCodRet,cId_usuario2,cNombre2,cStatus2,cId_nivel_consulta2,cD_nivel_consulta,cId_perfil2,cD_perfil2,iUsu_bloqueo,cUsu_estado;
                            END IF;
							set isolation to dirty read;
							FOREACH
								SELECT SKIP pNumRegistro FIRST pRecuperacion US.id_usuario, EJ.nombre,US.status,US.id_nivel_consulta,NC.d_nivel_consulta,US.id_perfil,PE.d_perfil,US.usu_bloqueo
								INTO 
								cId_usuario2,cNombre2,cStatus2,cId_nivel_consulta2,cD_nivel_consulta,cId_perfil2,cD_perfil2,iUsu_bloqueo
								FROM  si_seg_usuarios US
								LEFT JOIN si_ejecut EJ
								ON EJ.ejecutivo = US.Id_usuario
								LEFT JOIN si_seg_perfiles PE
								ON PE.id_perfil = US.Id_perfil
								LEFT JOIN si_seg_nivel_consulta NC
								ON NC.id_nivel_consulta = US.id_nivel_consulta	
								WHERE cast (US.id_nivel_consulta as char(1)) LIKE (cID_NIVEL_CONSULTA)||'%'
                                AND EJ.vigencia>=today order by 1

                                SELECT LIMIT 1 nvl(status,"") INTO cUsu_estado FROM si_macejecutivo
                                WHERE status='A' AND ejecutivo=cID_USUARIO;

                                LET iCont=iCont+1;
								RETURN cCodRet,cId_usuario2,cNombre2,cStatus2,cId_nivel_consulta2,cD_nivel_consulta,cId_perfil2,cD_perfil2,iUsu_bloqueo,cUsu_estado with resume;
							END FOREACH;
                            IF iCont = 0 THEN
                                LET cCodRet = 1001; 
                                RETURN cCodRet,cId_usuario2,cNombre2,cStatus2,cId_nivel_consulta2,cD_nivel_consulta,cId_perfil2,cD_perfil2,iUsu_bloqueo,cUsu_estado;
                            END IF 
			ELIF cID_PERFIL <> '' THEN
                                SELECT --+AVOID_FULL('informix'.si_seg_usuarios)
								nvl(Count(id_usuario),0) INTO iexiste  FROM si_seg_usuarios US LEFT JOIN si_ejecut EJ ON EJ.ejecutivo = US.Id_usuario WHERE US.id_perfil LIKE TRIM(cID_PERFIL)||'%' AND EJ.vigencia>=today;
                                IF iexiste = 0 THEN
                                    LET cCodRet = "00002";
                                    RETURN cCodRet,cId_usuario2,cNombre2,cStatus2,cId_nivel_consulta2,cD_nivel_consulta,cId_perfil2,cD_perfil2,iUsu_bloqueo,cUsu_estado;
                                END IF;
								set isolation to dirty read;
								FOREACH
									SELECT SKIP pNumRegistro FIRST pRecuperacion US.id_usuario, EJ.nombre,US.status,US.id_nivel_consulta,NC.d_nivel_consulta,US.id_perfil,PE.d_perfil,US.usu_bloqueo
									INTO 
									cId_usuario2,cNombre2,cStatus2,cId_nivel_consulta2,cD_nivel_consulta,cId_perfil2,cD_perfil2,iUsu_bloqueo
									FROM  si_seg_usuarios US
									LEFT JOIN si_ejecut EJ
									ON EJ.ejecutivo = US.Id_usuario
									LEFT JOIN si_seg_perfiles PE
									ON PE.id_perfil = US.Id_perfil
									LEFT JOIN si_seg_nivel_consulta NC
									ON NC.id_nivel_consulta = US.id_nivel_consulta	
									WHERE US.id_perfil LIKE TRIM(cID_PERFIL)||'%'
                                    AND EJ.vigencia>=today order by 1

                                    SELECT LIMIT 1 nvl(status,"") INTO cUsu_estado FROM si_macejecutivo
                                    WHERE status='A' AND ejecutivo=cID_USUARIO;

                                    LET iCont=iCont+1;
									RETURN cCodRet,cId_usuario2,cNombre2,cStatus2,cId_nivel_consulta2,cD_nivel_consulta,cId_perfil2,cD_perfil2,iUsu_bloqueo,cUsu_estado with resume;
								END FOREACH;
                                IF iCont = 0 THEN
                                    LET cCodRet = 1001; 
                                    RETURN cCodRet,cId_usuario2,cNombre2,cStatus2,cId_nivel_consulta2,cD_nivel_consulta,cId_perfil2,cD_perfil2,iUsu_bloqueo,cUsu_estado;
                                END IF 
			END IF;

			
        ELIF cTIPOBUSQUEDA = 1 THEN
            IF 	cID_USUARIOC ='' 	OR 
				cID_FUNCIONC = '' 	OR 
				cID_USUARIO ='' 		THEN
				LET cCodRet = "00003";
				RETURN cCodRet,cId_usuario2,cNombre2,cStatus2,cId_nivel_consulta2,cD_nivel_consulta,cId_perfil2,cD_perfil2,iUsu_bloqueo,cUsu_estado;
			END IF;		
			--SELECT nvl(Count(id_usuario),0) INTO iexiste  FROM si_seg_usuarios where id_usuario = cID_USUARIO and vigencia>=today;
            SELECT nvl(Count(id_usuario),0) INTO iexiste  FROM si_seg_usuarios US LEFT JOIN si_ejecut EJ ON EJ.ejecutivo = US.Id_usuario WHERE Us.id_usuario = cID_USUARIO AND EJ.vigencia>=today;
			IF iexiste = 0 THEN
				LET cCodRet = "00002";
				RETURN cCodRet,cId_usuario2,cNombre2,cStatus2,cId_nivel_consulta2,cD_nivel_consulta,cId_perfil2,cD_perfil2,iUsu_bloqueo,cUsu_estado;
			END IF;
			SELECT US.id_usuario, EJ.nombre,US.status,US.id_nivel_consulta,NC.d_nivel_consulta,US.id_perfil,NVL(PE.d_perfil,''),US.usu_bloqueo
			INTO 
			cId_usuario2,cNombre2,cStatus2,cId_nivel_consulta2,cD_nivel_consulta,cId_perfil2,cD_perfil2,iUsu_bloqueo
			FROM  si_seg_usuarios US
			LEFT JOIN si_ejecut EJ
			ON EJ.ejecutivo = US.Id_usuario
			LEFT JOIN si_seg_perfiles PE
			ON PE.id_perfil = US.Id_perfil
			LEFT JOIN si_seg_nivel_consulta NC
			ON NC.id_nivel_consulta = US.id_nivel_consulta
			WHERE Us.id_usuario = cID_USUARIO
            AND EJ.vigencia>=today;

            SELECT LIMIT 1 nvl(status,"") INTO cUsu_estado FROM si_macejecutivo
            WHERE status='A' AND ejecutivo=cID_USUARIO;
                    
			RETURN cCodRet,cId_usuario2,cNombre2,cStatus2,cId_nivel_consulta2,cD_nivel_consulta,cId_perfil2,cD_perfil2,iUsu_bloqueo,cUsu_estado with resume;
		END IF;	
	END
END PROCEDURE
DOCUMENT
"Autor : Antonio Flores",
"FUNCIONAMIENTO:Este SP hara una busqueda usuario dependiendo del tipo de busqueda que se requiera si es del tipo 1 se buscara el usuario por su id ",
"si es del tipo 2 se hara la busqueda por los parametros que el usuario escriba, y traera todas las coincidencias segun el parametro escrito",
"los parametros que el usuario puede escrbir son los siquientes:id_usuario, nombre, status, id_nivel_consulta y el Id_perfil",
"NOTA: para la busqueda de tipo 2  se tomara el primer parametro que escriba el usuario, por ejemeplo, si escribe el id_usuario solo se tomara",
"ese parametro para hacer la busqueda y los demas no se tomaran en cuenta.",
"FECHA : 27-12-2011",
"BD    : bdinteg",
"VER   : 1.0",
"Modificación: Victor Hugo Sánchez. Se agrego parametrización para la recuperacion de informacion";

CREATE PROCEDURE "informix".sp_cnsif_concheques(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCUENTA CHAR(20), cCONSECUTIVOCHEQUERA CHAR(10), iNOCHEQUE INTEGER,pNumRegistro INTEGER,pRecuperacion INTEGER)
							
				returning CHAR(5)  AS Cod_Retorno, 
						  CHAR(10) AS Consecutivo_Chequera, 
						  INTEGER  AS Numero_Cheque_Final, 
						  INTEGER  AS Numero_Cheque, 
						  CHAR(50) AS Detalle_Status, 
						  DATE     AS Fecha_Movimiento, 
						  DECIMAL(14,2) AS Importe, 
						  CHAR(4)  AS Sucursal;
										
DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;
							
--VARIABLES STORE
DEFINE iNumCheqFinal    INTEGER;       -- numero de cheque final
DEFINE iNumCheq         INTEGER;       -- numero de cheque
DEFINE cStatus          CHAR(1);       -- Cve Estatus
DEFINE dFechaMovimiento DATE;          -- Fecha de Movimiento
DEFINE decImporte       DECIMAL(14,2); -- Importe
DEFINE cDetalleStatus   CHAR(50);      -- Detalle de Estatus

-- VARIABLES ADICIONALES
DEFINE cSucursal        CHAR(4);       --Clave de la Sucursal
DEFINE smallSecuencia   SMALLINT;      --Secuencia
DEFINE cNumCta          CHAR(20);
DEFINE cConsecutivoChq  CHAR(10); 
DEFINE sConsecC         INTEGER;
DEFINE dFechapresenta   DATE;

--VARIABLES DE PAGINACION
DEFINE iCont            INT;

--inicializando variables
LET  iexiste 		 = 0;
LET cCodRet 		 = "00000";
LET iSql_err 		 = 0 ;
LET iNumCheqFinal    = 0 ;
LET iNumCheq         = 0 ;
LET cStatus          = "";
LET dFechaMovimiento = "";
LET decImporte       = 0 ;
LET cDetalleStatus   = "";
LET cSucursal        = "";
LET smallSecuencia   = 0;
LET cNumCta          = "";
LET cConsecutivoChq  = "";
LET sConsecC         =0;
LET dFechapresenta   ="";

--VARIABLES DE PAGINACION 
LET iCont       = 0;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet,cCONSECUTIVOCHEQUERA, iNumCheqFinal, iNOCHEQUE, cDetalleStatus, dFechaMovimiento,  decImporte,  cSucursal;						
		END IF;
	END EXCEPTION;
	
	--  SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_concheques.out";
	-- TRACE ON;
		
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cNUMCUENTA   = ''   OR
		cCONSECUTIVOCHEQUERA = '' THEN 
		LET cCodRet = "00069";
		RETURN cCodRet,cCONSECUTIVOCHEQUERA, iNumCheqFinal, iNOCHEQUE, cDetalleStatus, dFechaMovimiento,  decImporte,  cSucursal;						
	END IF;	

    IF pNumRegistro<0 THEN
        LET cCodRet='00098';
        RETURN cCodRet,cCONSECUTIVOCHEQUERA, iNumCheqFinal, iNOCHEQUE, cDetalleStatus, dFechaMovimiento,  decImporte,  cSucursal;						
    ELSE
        IF pRecuperacion<=0 THEN
            LET cCodRet='00098';
            RETURN cCodRet,cCONSECUTIVOCHEQUERA, iNumCheqFinal, iNOCHEQUE, cDetalleStatus, dFechaMovimiento,  decImporte,  cSucursal;						
        END IF;
    END IF;  
	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'30','1')
	INTO
	cCodRet;

	IF (cCodRet != '00000')  THEN
		RETURN cCodRet,cCONSECUTIVOCHEQUERA, iNumCheqFinal, iNOCHEQUE, cDetalleStatus, dFechaMovimiento,  decImporte,  cSucursal;						
	END IF;
	-- TERMINA VALIDACION	
	
	SELECT NVL(COUNT(cuenta),0) INTO iexiste FROM bdicheq:sc_maechq WHERE empresa = '001' AND  cuenta = cNUMCUENTA; 
	IF iexiste  = 0 THEN 
	LET cCodRet = "00070";
	RETURN cCodRet,cCONSECUTIVOCHEQUERA, iNumCheqFinal, iNOCHEQUE, cDetalleStatus, dFechaMovimiento,  decImporte,  cSucursal;						
	END IF;
	
	IF pNumRegistro=0 THEN
	  DELETE --+AVOID_FULL("informix".si_tempoconcheques) 
	  FROM si_tempoconcheques WHERE numcte = cNUMCUENTA AND ejecutivosif= cID_USUARIOC;
	  
		SET ISOLATION TO DIRTY READ;

        IF iNOCHEQUE<>0 THEN
            SELECT NVL(consec,0) INTO sConsecC FROM bdicheq:sc_contch
            WHERE CUENTA =cNUMCUENTA AND numero=iNOCHEQUE;
            
            IF sConsecC IS NULL THEN
                LET cCONSECUTIVOCHEQUERA=0;
            ELSE
                LET cCONSECUTIVOCHEQUERA=sConsecC;
            END IF;
            

        END IF;
		
		FOREACH 
		
		 EXECUTE PROCEDURE bdicntchq:sp_concheques('001',cNUMCUENTA,cCONSECUTIVOCHEQUERA,iNOCHEQUE)
		 INTO 		
		 cCodRet, iNumCheqFinal, iNumCheq, cStatus, dFechaMovimiento,
		 decImporte, cDetalleStatus

        SET ISOLATION TO DIRTY READ;
        SELECT FIRST 1 fechapresenta INTO dFechapresenta FROM bditef:cce_cheques_img WHERE numcuenta=cNUMCUENTA AND numcheque=iNumCheq AND empresa='001';
        IF dFechapresenta IS NOT NULL THEN
            LET dFechaMovimiento=dFechapresenta;
        END IF;
		
		IF iNumCheq > 0 THEN		
			 SELECT MAX(secuencia)
			 INTO
			 smallSecuencia
			 FROM bdicheq:sc_contch_hist
			 WHERE cuenta = cNUMCUENTA
			 AND numchq = iNumCheq;
		END IF
		
		IF 	smallSecuencia > 0 THEN	
			SELECT sucursal
			INTO		 
			cSucursal
			FROM bdicheq:sc_contch_hist
			WHERE cuenta = cNUMCUENTA
			AND numchq = iNumCheq
			AND secuencia = smallSecuencia;
		END IF
		
		IF LENGTH(cCodRet) = 3 THEN
		    LET cCodRet = '00' || cCodRet;
		END IF;	
		
		IF cCodRet != '00000' THEN
		    RETURN 	cCodRet,cConsecutivoChq,iNumCheqFinal,iNumCheq,cDetalleStatus,dFechaMovimiento,decImporte,cSucursal;	
		END IF;
		
		INSERT INTO si_tempoconcheques (cod_retorno, consecutivo, cheque_final, no_cheque, status, fecha_movimiento, importe, sucursal, numcte, ejecutivosif)
		VALUES (cCodRet,cCONSECUTIVOCHEQUERA, iNumCheqFinal, iNumCheq, cDetalleStatus, dFechaMovimiento, decImporte, cSucursal, cNUMCUENTA, cID_USUARIOC);

		END FOREACH;
		
	END IF;	
	
	SELECT --+AVOID_FULL("informix".si_tempoconcheques) 
	NVL(COUNT(cod_retorno),0) INTO iexiste FROM si_tempoconcheques WHERE numcte = cNUMCUENTA AND ejecutivosif= cID_USUARIOC;
	IF iexiste  = 0 THEN 
		LET cCodRet = "00091";
		RETURN cCodRet,cConsecutivoChq, iNumCheqFinal, iNumCheq, cDetalleStatus, dFechaMovimiento,  decImporte,  cSucursal;
	END IF;		

	SET ISOLATION TO DIRTY READ;
	FOREACH
		SELECT --+AVOID_FULL("informix".si_tempoconcheques)
		SKIP pNumRegistro FIRST pRecuperacion cod_retorno, consecutivo, cheque_final, no_cheque, 
		status, fecha_movimiento, importe, sucursal
		INTO
		cCodRet,cConsecutivoChq, iNumCheqFinal, iNumCheq, cDetalleStatus, dFechaMovimiento, decImporte, cSucursal
		FROM si_tempoconcheques
		WHERE numcte = cNUMCUENTA AND ejecutivosif= cID_USUARIOC ORDER BY no_cheque
		
		LET iCont=iCont+1;
		
		RETURN 	cCodRet,cConsecutivoChq, iNumCheqFinal, iNumCheq, cDetalleStatus, dFechaMovimiento,  decImporte,  cSucursal WITH resume;			
		
	END FOREACH;
	
	IF iCont = 0 THEN
		DELETE --+AVOID_FULL("informix".si_tempoconcheques)
		FROM si_tempoconcheques WHERE numcte = cNUMCUENTA AND ejecutivosif= cID_USUARIOC;
		LET cCodRet = '1001'; 
		RETURN cCodRet,cConsecutivoChq, iNumCheqFinal, iNumCheq, cDetalleStatus, dFechaMovimiento,  decImporte,  cSucursal;
	END IF
			
END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la información de los cheques asociados a una Chequera de una cuenta de Cheques. ",
"El SP obtendrá la información de la Base de Datos central de Informix, enviando como parámetro el  Número de Cuenta y el ID de Chequera o Número de Cheque",
"FECHA : 28-02-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cnsif_cons_tarjetas_adic(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCUENTA CHAR(20),cSISTEMACUENTA CHAR(2),pNumRegistro INTEGER,pRecuperacion INTEGER)

RETURNING 	     	CHAR(5)  AS Cod_Retorno,
					CHAR(20) AS Numero_Cliente,
					CHAR(26) AS Nombre_1,
					CHAR(26) AS Nombre_2,
					CHAR(26) AS Apellido_Paterno,
					CHAR(26) AS Apellido_Materno,
					CHAR(20) AS Numero_Tarjeta,
					CHAR(15) AS Status,
					DATE     AS Fecha_Expira,
					CHAR(1)  AS Tipo_Tarjeta;


-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret     	CHAR(5);
DEFINE vsqlerr      	INTEGER;
DEFINE cNumero_cliente	CHAR(20);
DEFINE cNombre1			CHAR(26);
DEFINE cNombre2			CHAR(26);
DEFINE cAPaterno		CHAR(26);
DEFINE cAMaterno		CHAR(26);
DEFINE cNumero_tarjeta	CHAR(20);
DEFINE cStatus_tarjeta	CHAR(15);
DEFINE dFecha_expiracion DATE;
DEFINE cTipo_tarjeta	CHAR(1);
DEFINE iexiste			INTEGER;
DEFINE iCont            INTEGER;
-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET vsqlerr    = 0;
LET scod_ret = "00000";
LET cNumero_cliente	="";
LET cNombre1			="";
LET cNombre2			="";
LET cAPaterno		="";
LET cAMaterno		="";
LET cNumero_tarjeta	="";
LET cStatus_tarjeta	="";
LET dFecha_expiracion ="";
LET cTipo_tarjeta	="";
LET iexiste = 0;
LET iCont=0;
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
	IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret,cNumero_cliente,cNombre1,cNombre2,cAPaterno, cAMaterno, cNumero_tarjeta,cStatus_tarjeta,dFecha_expiracion,cTipo_tarjeta;
	END IF;
END EXCEPTION;


 --SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_cons_tarjetas_adic.out";
 --TRACE ON;
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
  -- Valida Parametros de Entrada

  IF cID_USUARIOC = "" OR 
	 cID_FUNCIONC = "" OR
     cNUMCUENTA  = ""  OR
	 cSISTEMACUENTA = "" THEN
     LET scod_ret = "00036";
     RETURN scod_ret,cNumero_cliente,cNombre1,cNombre2,cAPaterno, cAMaterno, cNumero_tarjeta,cStatus_tarjeta,dFecha_expiracion,cTipo_tarjeta;
  END IF;
  IF cSISTEMACUENTA <> '01' AND cSISTEMACUENTA <> '06'  AND cSISTEMACUENTA <> '00' THEN 
		LET scod_ret = "00037";
		RETURN scod_ret,cNumero_cliente,cNombre1,cNombre2,cAPaterno, cAMaterno, cNumero_tarjeta,cStatus_tarjeta,dFecha_expiracion,cTipo_tarjeta;
  END IF;  
  
    IF pNumRegistro<0 THEN
        LET scod_ret='00098';
        RETURN scod_ret,cNumero_cliente,cNombre1,cNombre2,cAPaterno, cAMaterno, cNumero_tarjeta,cStatus_tarjeta,dFecha_expiracion,cTipo_tarjeta;
    ELSE
        IF pRecuperacion<=0 THEN
            LET scod_ret='00098';
            RETURN scod_ret,cNumero_cliente,cNombre1,cNombre2,cAPaterno, cAMaterno, cNumero_tarjeta,cStatus_tarjeta,dFecha_expiracion,cTipo_tarjeta;
        END IF;
    END IF;   
	 --VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,cSISTEMACUENTA,'1')
	INTO
	scod_ret;
	IF (scod_ret != '00000')  THEN
		RETURN scod_ret,cNumero_cliente,cNombre1,cNombre2,cAPaterno, cAMaterno, cNumero_tarjeta,cStatus_tarjeta,dFecha_expiracion,cTipo_tarjeta;
	END IF;
	-- TERMINA VALIDACION  
  
  -- Extrae las Tarjeta adicionales
  --PARA CAPTACION
	  IF cSISTEMACUENTA = '01' THEN
		  SELECT NVL(COUNT(cuenta),0) INTO iexiste FROM bdicheq:sc_tarjeta WHERE cuenta = cNUMCUENTA AND empresa = '001';	
		  IF iexiste = 0 THEN 
				LET scod_ret = "00023";
				RETURN scod_ret,cNumero_cliente,cNombre1,cNombre2,cAPaterno, cAMaterno, cNumero_tarjeta,cStatus_tarjeta,dFecha_expiracion,cTipo_tarjeta;
		  END IF;
		  SET ISOLATION TO dirty READ;
		  FOREACH
			SELECT SKIP pNumRegistro FIRST pRecuperacion num_tarjeta,numcte,expiracion,tipo_tarjeta 
			INTO  cNumero_tarjeta,cNumero_cliente,dFecha_expiracion,cTipo_tarjeta
			FROM bdicheq:sc_tarjeta 
			WHERE cuenta = cNUMCUENTA
			AND empresa = '001' ORDER BY num_tarjeta
			
			SELECT  nombre1,nombre2, apell_paterno,apell_materno
			INTO 
			cNombre1,cNombre2,cAPaterno,cAMaterno
			FROM 
			bdinteg:si_cliente  
			WHERE  numcte = cNumero_cliente;

            SELECT LIMIT 1 {+INDEX (intercard:"informix".tarjeta idx_numcte)} NVL(UPPER(B.descstatustarjeta),"") INTO cStatus_tarjeta FROM intercard:tarjeta A
            LEFT JOIN intercard:statustarjeta B
            ON A.codstatustarjeta = B.codstatustarjeta
            WHERE A.numcliente= cNumero_cliente
            AND A.numtarjeta= cNumero_tarjeta;

			LET iCont=iCont+1;	  
			RETURN scod_ret,cNumero_cliente,cNombre1,cNombre2,cAPaterno, cAMaterno, cNumero_tarjeta,cStatus_tarjeta,dFecha_expiracion,cTipo_tarjeta with resume;

		  END FOREACH;
		  IF iCont = 0 THEN
			LET scod_ret = '1001'; 
			RETURN scod_ret,cNumero_cliente,cNombre1,cNombre2,cAPaterno, cAMaterno, cNumero_tarjeta,cStatus_tarjeta,dFecha_expiracion,cTipo_tarjeta;
		  END IF 
 -- PARA CREDITO	  
  ELIF cSISTEMACUENTA = '06' THEN
		  SELECT nvl(COUNT(num_credito),0) INTO iexiste FROM bdicred:sd_tarjeta WHERE num_credito = cNUMCUENTA AND empresa = '001';	
		  IF iexiste = 0 THEN 
				LET scod_ret = "00023";
				RETURN scod_ret,cNumero_cliente,cNombre1,cNombre2,cAPaterno, cAMaterno, cNumero_tarjeta,cStatus_tarjeta,dFecha_expiracion,cTipo_tarjeta;
		  END IF;
		  SET ISOLATION TO dirty READ;
		  FOREACH
			SELECT SKIP pNumRegistro FIRST pRecuperacion num_tarjeta,numcte,expiracion,tipo_tarjeta 
			INTO  cNumero_tarjeta,cNumero_cliente,dFecha_expiracion,cTipo_tarjeta
			FROM bdicred:sd_tarjeta
			WHERE num_credito = cNUMCUENTA
			AND empresa = '001' ORDER BY num_tarjeta
			
			SELECT  nombre1,nombre2, apell_paterno,apell_materno
			INTO 
			cNombre1,cNombre2,cAPaterno,cAMaterno
			FROM 
			bdinteg:si_cliente  
			WHERE  numcte = cNumero_cliente;

            SELECT LIMIT 1 {+INDEX (intercard:"informix".tarjeta idx_numcte)} NVL(UPPER(B.descstatustarjeta),"") INTO cStatus_tarjeta FROM intercard:tarjeta A
            LEFT JOIN intercard:statustarjeta B
            ON A.codstatustarjeta = B.codstatustarjeta
            WHERE A.numcliente= cNumero_cliente
            AND A.numtarjeta= cNumero_tarjeta;

			LET iCont=iCont+1;	 
			
			RETURN scod_ret,cNumero_cliente,cNombre1,cNombre2,cAPaterno, cAMaterno, cNumero_tarjeta,cStatus_tarjeta,dFecha_expiracion,cTipo_tarjeta with resume;

		  END FOREACH;
		  IF iCont = 0 THEN
			LET scod_ret = '1001'; 
			RETURN scod_ret,cNumero_cliente,cNombre1,cNombre2,cAPaterno, cAMaterno, cNumero_tarjeta,cStatus_tarjeta,dFecha_expiracion,cTipo_tarjeta;
		  END IF
  --PARA AMBOS
  ELIF cSISTEMACUENTA = '00' THEN
	  IF pNumRegistro = 0 THEN
		  DELETE --+AVOID_FULL ("informix".si_tempotarjetasadc)
		  FROM si_tempotarjetasadc WHERE ejecutivosif= cID_USUARIOC;
		  SET ISOLATION TO dirty READ;
		  FOREACH 
			SELECT SKIP pNumRegistro FIRST pRecuperacion num_tarjeta,numcte,expiracion,tipo_tarjeta 
			INTO  cNumero_tarjeta,cNumero_cliente,dFecha_expiracion,cTipo_tarjeta
			FROM bdicheq:sc_tarjeta 
			WHERE cuenta = cNUMCUENTA
			AND empresa = '001' order by num_tarjeta
			
			SELECT  nombre1,nombre2, apell_paterno,apell_materno
			INTO 
			cNombre1,cNombre2,cAPaterno,cAMaterno
			FROM   bdinteg:si_cliente  
			WHERE  numcte = cNumero_cliente;

            SELECT LIMIT 1 {+INDEX (intercard:"informix".tarjeta idx_numcte)} NVL(UPPER(B.descstatustarjeta),"") INTO cStatus_tarjeta FROM intercard:tarjeta A
            LEFT JOIN intercard:statustarjeta B
            ON A.codstatustarjeta = B.codstatustarjeta
            WHERE A.numcliente= cNumero_cliente
            AND A.numtarjeta= cNumero_tarjeta;

			LET iCont=iCont+1;	 

			INSERT INTO si_tempotarjetasadc(cod_ret, numcte, nombre1, nombre2, paterno, materno, tarjeta, status, expiracion, tipo_tar, cuenta, ejecutivosif) 
			VALUES(scod_ret,cNumero_cliente,cNombre1,cNombre2,cAPaterno, cAMaterno, cNumero_tarjeta,cStatus_tarjeta,dFecha_expiracion,cTipo_tarjeta,cNUMCUENTA, cID_USUARIOC);		

		  END FOREACH;

		SET ISOLATION TO dirty READ;
		  FOREACH
			SELECT SKIP pNumRegistro FIRST pRecuperacion num_tarjeta,numcte,expiracion,tipo_tarjeta 
			INTO  cNumero_tarjeta,cNumero_cliente,dFecha_expiracion,cTipo_tarjeta
			FROM bdicred:sd_tarjeta
			WHERE num_credito = cNUMCUENTA
			AND empresa = '001' order by num_tarjeta
			
			SELECT  nombre1,nombre2, apell_paterno,apell_materno
			INTO 
			cNombre1,cNombre2,cAPaterno,cAMaterno
			FROM 
			bdinteg:si_cliente  
			WHERE  numcte = cNumero_cliente;

            SELECT LIMIT 1 {+INDEX (intercard:'informix'.tarjeta idx_numcte)} NVL(UPPER(B.descstatustarjeta),"") INTO cStatus_tarjeta FROM intercard:tarjeta A
            LEFT JOIN intercard:statustarjeta B
            ON A.codstatustarjeta = B.codstatustarjeta
            WHERE A.numcliente= cNumero_cliente
            AND A.numtarjeta= cNumero_tarjeta;

			LET iCont=iCont+1;	 
			
			INSERT INTO si_tempotarjetasadc(cod_ret, numcte, nombre1, nombre2, paterno, materno, tarjeta, status, expiracion, tipo_tar, cuenta, ejecutivosif) 
			VALUES(scod_ret,cNumero_cliente,cNombre1,cNombre2,cAPaterno, cAMaterno, cNumero_tarjeta,cStatus_tarjeta,dFecha_expiracion,cTipo_tarjeta,cNUMCUENTA, cID_USUARIOC);		

		  END FOREACH;
            SELECT --+AVOID_FULL ("informix".si_tempotarjetasadc)
			NVL(COUNT(cod_ret),0) into iexiste FROM si_tempotarjetasadc WHERE ejecutivosif= cID_USUARIOC;
            IF iexiste  = 0 THEN 
                LET scod_ret = "00023";
                RETURN scod_ret,cNumero_cliente,cNombre1,cNombre2,cAPaterno, cAMaterno, cNumero_tarjeta,cStatus_tarjeta,dFecha_expiracion,cTipo_tarjeta;
            END IF;			  
	  END IF
	  
	  SET ISOLATION TO dirty READ;
	  FOREACH
		SELECT --+AVOID_FULL ("informix".si_tempotarjetasadc)
		SKIP pNumRegistro FIRST pRecuperacion
		cod_ret, numcte, nombre1, nombre2, paterno, materno, tarjeta, status, expiracion, tipo_tar
		INTO
		scod_ret,cNumero_cliente,cNombre1,cNombre2,cAPaterno, cAMaterno, cNumero_tarjeta,cStatus_tarjeta,dFecha_expiracion,cTipo_tarjeta
		FROM si_tempotarjetasadc
		WHERE ejecutivosif= cID_USUARIOC
		ORDER BY tarjeta

		LET iCont=iCont+1;	 
		
		RETURN scod_ret,cNumero_cliente,cNombre1,cNombre2,cAPaterno, cAMaterno, cNumero_tarjeta,cStatus_tarjeta,dFecha_expiracion,cTipo_tarjeta with resume;

	  END FOREACH;
	  
	  IF iCont = 0 THEN
		DELETE --+AVOID_FULL ("informix".si_tempotarjetasadc)
		FROM si_tempotarjetasadc WHERE ejecutivosif= cID_USUARIOC;
		LET scod_ret = '1001'; 
		RETURN scod_ret,cNumero_cliente,cNombre1,cNombre2,cAPaterno, cAMaterno, cNumero_tarjeta,cStatus_tarjeta,dFecha_expiracion,cTipo_tarjeta;
	  END IF;
	  
  END IF
  
END
END PROCEDURE
DOCUMENT
"AutOR : Antonio Flores",
"FUNCIONAMIENTO:Este sp realizara la busqueda de tarjetas adicionales  dependiendo del numero de cuenta   que se envie a dicho SP se mostraran las tarjetas activas o canceladas",
"FECHA : 06-01-2012",
"BD    : bdinteg",
"Modifico : ARTURO CERVANTES PEÑA",
"MODIFICACION : Se agrega el tipo de sistema cuenta asi como una tabla temporal para cuando sea la opcion 00",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cnsif_cons_tarjetas_cte(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCTE CHAR(20),pNumRegistro INTEGER,pRecuperacion INTEGER)

RETURNING 	    CHAR(5)  AS Cod_Retorno,
				CHAR(1)  AS Chequera,
				CHAR(4)  AS Cve_Producto,
				CHAR(40) AS Producto,
				CHAR(20) AS Numero_Cuenta,
				CHAR(20) AS Numero_Tarjeta,
				CHAR(15) AS Status_Tarjeta,
				DATE     AS Fecha_Expira,
				CHAR(15) AS Tipo_Tarjeta,
				CHAR(2)  AS Sistema_Cuenta;



-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret     	CHAR(5);
DEFINE vsqlerr      	INTEGER;
DEFINE cIchequera		CHAR(1);
DEFINE cProducto		CHAR(4);
DEFINE cNombre_producto	CHAR(40);
DEFINE cNumero_cuenta	CHAR(20);
DEFINE cNumero_tarjeta	CHAR(20);
DEFINE cStatus_tarjeta	CHAR(15);
DEFINE dFecha_expiracion DATE;
DEFINE cTipo_tarjeta	CHAR(15);
DEFINE cNTarjeta		CHAR(20);
DEFINE iexiste			INTEGER;
DEFINE iexistente		SMALLINT;
DEFINE iCont            INTEGER;
DEFINE cSistema_cuenta	CHAR(2);
DEFINE sSecuencia       SMALLINT;

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret = "00000";
LET cIchequera	= '';
LET cProducto = '';
LET cNombre_producto = '';
LET cNumero_cuenta	= '';
LET cNumero_tarjeta	= '';
LET cStatus_tarjeta	= '';
LET dFecha_expiracion = '';
LET cTipo_tarjeta	= '';
LET cNTarjeta = '' ;
LET iexiste	 = 0;
LET iCont=0;
LET cSistema_cuenta='';
LET iexistente=0;
LET sSecuencia=0;
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret,cIchequera, cProducto, cNombre_producto, cNumero_cuenta, cNumero_tarjeta, cStatus_tarjeta, dFecha_expiracion, cTipo_tarjeta,cSistema_cuenta;
   END IF;
END EXCEPTION;


--SET DEBUG FILE TO "/tmp/CNSIF/p_cnsif_cons_tarjetas_cte.out";
--TRACE ON;
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
  -- Valida Parametros de Entrada

      IF cID_USUARIOC = "" OR 
         cID_FUNCIONC = "" OR
         cNUMCTE  = ""  THEN
         LET scod_ret = "00054";
         RETURN scod_ret,cIchequera, cProducto, cNombre_producto, cNumero_cuenta, cNumero_tarjeta, cStatus_tarjeta, dFecha_expiracion, cTipo_tarjeta,cSistema_cuenta;
      END IF;

    IF pNumRegistro<0 THEN
        LET scod_ret='00098';
        RETURN scod_ret,cIchequera, cProducto, cNombre_producto, cNumero_cuenta, cNumero_tarjeta, cStatus_tarjeta, dFecha_expiracion, cTipo_tarjeta,cSistema_cuenta;
    ELSE
        IF pRecuperacion<=0 THEN
            LET scod_ret='00098';
            RETURN scod_ret,cIchequera, cProducto, cNombre_producto, cNumero_cuenta, cNumero_tarjeta, cStatus_tarjeta, dFecha_expiracion, cTipo_tarjeta,cSistema_cuenta;
        END IF;
    END IF;   	  
--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCTE,'01','2')
	INTO
	scod_ret;
	IF (scod_ret != '00000')  THEN
		RETURN scod_ret,cIchequera, cProducto, cNombre_producto, cNumero_cuenta, cNumero_tarjeta, cStatus_tarjeta, dFecha_expiracion, cTipo_tarjeta,cSistema_cuenta;
	END IF;
	-- TERMINA VALIDACION	  
	  
     SELECT NVL(COUNT(numcte),0) into iexiste FROM si_cliente  WHERE numcte = cNUMCTE;
     IF iexiste = 0 THEN 
            LET scod_ret = "00055";
            RETURN scod_ret,cIchequera, cProducto, cNombre_producto, cNumero_cuenta, cNumero_tarjeta, cStatus_tarjeta, dFecha_expiracion, cTipo_tarjeta,cSistema_cuenta;
      END IF;	
  -- Extrae las Tarjeta de Cheques
    IF pNumRegistro=0 THEN
          DELETE FROM si_tempotarjetas WHERE ejecutivosif= cID_USUARIOC;
          SET ISOLATION TO dirty READ;
          FOREACH
            SELECT --+AVOID_FULL(bdicheq:"informix".sc_tarjeta)
			num_tarjeta,secuencia  
            INTO  cNTarjeta,sSecuencia 
            FROM bdicheq:sc_tarjeta 
            WHERE numcte = cNUMCTE AND cuenta IS NOT NULL ORDER BY cuenta,secuencia

            SELECT --+AVOID_FULL(bdicheq:"informix".sc_tarjeta)
			DECODE(prodtarjeta,"2200","S","1900","S","N"),prodtarjeta,cuenta,num_tarjeta,expiracion,DECODE(tipo_tarjeta,"T","TITULAR","A","ADICIONAL","DESCONOCIDO")
            INTO 
            cIchequera,cProducto, cNumero_cuenta, cNumero_tarjeta, dFecha_expiracion, cTipo_tarjeta
            FROM bdicheq:sc_tarjeta 
            WHERE  num_tarjeta =  cNTarjeta AND cuenta IS NOT NULL AND secuencia=sSecuencia;

            SELECT  nombre
            INTO cNombre_producto
            FROM bdicheq:sc_producto 
            WHERE producto = cProducto;

            SELECT LIMIT 1 {+INDEX (intercard:"informix".tarjeta idx_numcte)} NVL(UPPER(B.descstatustarjeta),"") INTO cStatus_tarjeta FROM intercard:tarjeta A
            LEFT JOIN intercard:statustarjeta B
            ON A.codstatustarjeta = B.codstatustarjeta
            WHERE A.numcliente= cNUMCTE
            AND A.numtarjeta= cNTarjeta;

            INSERT INTO si_tempotarjetas (cod_ret,ichequera,producto,nombre_producto,numero_cuenta,numero_tarjeta,status_tarjeta,fecha_expiracion, tipo_tarjeta,numcte,sistema,ejecutivosif)
            VALUES (scod_ret,cIchequera, cProducto, cNombre_producto, cNumero_cuenta, cNumero_tarjeta, cStatus_tarjeta, dFecha_expiracion, cTipo_tarjeta,cNUMCTE,'01',cID_USUARIOC);
			
            LET iexistente=1;
           END FOREACH;

          -- Extrae las Tarjeta de Credito
         SET ISOLATION TO dirty READ;
          FOREACH
            SELECT num_tarjeta,num_credito,secuencia 
            INTO  cNTarjeta,cNumero_cuenta,sSecuencia  
            FROM bdicred:sd_tarjeta
            WHERE numcte=cNUMCTE ORDER BY num_credito,secuencia

            SELECT DECODE(prodtarjeta,"2200","S","1900","S","N"),num_tarjeta,
                    expiracion,DECODE(tipo_tarjeta,"T","TITULAR","A","ADICIONAL","DESCONOCIDO")
            INTO 
            cIchequera,cNumero_tarjeta, dFecha_expiracion, cTipo_tarjeta
            FROM bdicred:sd_tarjeta      
            WHERE num_tarjeta = cNTarjeta AND secuencia=sSecuencia;


            SELECT LIMIT 1 {+INDEX (intercard:"informix".tarjeta idx_numcte)} NVL(UPPER(B.descstatustarjeta),"") INTO cStatus_tarjeta FROM intercard:tarjeta A
            LEFT JOIN intercard:statustarjeta B
            ON A.codstatustarjeta = B.codstatustarjeta
            WHERE A.numcliente= cNUMCTE
            AND A.numtarjeta= cNTarjeta;

            FOREACH
                SELECT LIMIT 1 num_producto AS PROD INTO cProducto FROM bdicred:sd_maecred where num_credito=cNumero_cuenta AND empresa='001'
                UNION
                SELECT num_producto as PROD FROM bdicred:sd_maecredcrd where num_credito=cNumero_cuenta AND empresa='001' ORDER BY PROD DESC
            END FOREACH;

            SELECT nombre_prod,num_producto 
            INTO cNombre_producto,cProducto
            FROM bdicred:sd_definicion
            WHERE num_producto = cProducto;


            INSERT INTO si_tempotarjetas (cod_ret,ichequera,producto,nombre_producto,numero_cuenta,numero_tarjeta,status_tarjeta,fecha_expiracion, tipo_tarjeta,numcte,sistema,ejecutivosif)
            VALUES (scod_ret,cIchequera, cProducto, cNombre_producto, cNumero_cuenta, cNumero_tarjeta, cStatus_tarjeta, dFecha_expiracion, cTipo_tarjeta,cNUMCTE,'06',cID_USUARIOC);

            LET iexistente=1;			
          END FOREACH;
          IF iexistente=0 THEN
            LET scod_ret = '00097'; 
            RETURN scod_ret,cIchequera, cProducto, cNombre_producto, cNumero_cuenta, cNumero_tarjeta, cStatus_tarjeta, dFecha_expiracion, cTipo_tarjeta,cSistema_cuenta;
          END IF;
     END IF;

     SET ISOLATION TO dirty READ;
     FOREACH
        SELECT SKIP pNumRegistro FIRST pRecuperacion cod_ret,ichequera,producto,nombre_producto,numero_cuenta,numero_tarjeta,status_tarjeta,fecha_expiracion, tipo_tarjeta,sistema
        INTO scod_ret,cIchequera, cProducto, cNombre_producto, cNumero_cuenta, cNumero_tarjeta, cStatus_tarjeta, dFecha_expiracion, cTipo_tarjeta,cSistema_cuenta
        FROM si_tempotarjetas
        WHERE ejecutivosif= cID_USUARIOC ORDER BY numero_cuenta

        LET iCont=iCont+1;
        RETURN scod_ret,cIchequera, cProducto, cNombre_producto, cNumero_cuenta, cNumero_tarjeta, cStatus_tarjeta, dFecha_expiracion, cTipo_tarjeta,cSistema_cuenta WITH RESUME;
     END FOREACH;
     IF iCont = 0 THEN
        DELETE FROM si_tempotarjetas WHERE ejecutivosif= cID_USUARIOC;
        LET scod_ret = '1001'; 
        RETURN scod_ret,cIchequera, cProducto, cNombre_producto, cNumero_cuenta, cNumero_tarjeta, cStatus_tarjeta, dFecha_expiracion, cTipo_tarjeta,cSistema_cuenta;
     END IF 
END

END PROCEDURE
DOCUMENT
"AutOR : Antonio Flores",
"FUNCIONAMIENTO:Este sp realizara la busqueda de tarjetas de cheques y credito dependiendo del numero de cliente  que se envie a dicho SP",
"FECHA : 05-01-2012",
"BD    : bdinteg",
"Modifico : Victor Hugo Sánchez",
"MODIFICACION : Se almacenan los datos de las tarjetas en tabla de paso y se agrega la paginacion",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cnsif_consultacatalogotiposdepago(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10))
							
			returning   CHAR(5)         AS Cod_Retorno,
						CHAR(02)        AS Clave_Tipo_Pago,	      
						CHAR(70)        AS Desc_Tipo_Pago;	      

							
DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;							
--VARIABLES
DEFINE v_CveTipoPago        CHAR(02);
DEFINE v_Descripcion        CHAR(70);

LET v_CveTipoPago           = "";
LET v_Descripcion           = "";

--inicializando variables
LET  iexiste 		 = 0;
LET cCodRet 		 = "00000";
LET iSql_err 		 = 0 ;                          

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet,v_CveTipoPago,v_Descripcion;						
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_consultacatalogotiposdepago.out";
	--TRACE ON;
		
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	THEN 
		LET cCodRet = "00067";
		RETURN cCodRet,v_CveTipoPago,v_Descripcion;
	END IF;	

	EXECUTE FUNCTION sp_cnsif_confirmaejecutivo (cID_USUARIOC,cID_FUNCIONC)
	INTO cCodRet;

	IF cCodRet = '00028' THEN 
		RETURN cCodRet,v_CveTipoPago,v_Descripcion;
	END IF;	
	
	SET ISOLATION TO DIRTY READ;
	
	IF EXISTS (SELECT cve_pago FROM BDIPROG:PP_TPPAGO) THEN
		FOREACH
			SELECT --+AVOID_FULL (bdiprog:"informix".pp_tppago)
			cve_pago,descripcion
			INTO v_CveTipoPago, v_Descripcion
			FROM  BDIPROG:PP_TPPAGO
			WHERE cve_pago IS NOT NULL
			ORDER BY cve_pago
			
			RETURN cCodRet,v_CveTipoPago,v_Descripcion WITH Resume;
			
		END FOREACH;
	ELSE
		RETURN 	cCodRet,v_CveTipoPago,v_Descripcion;
	END IF

END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la información de los Tipos de Pago para rellenar el combo correspondiente en la Consulta de Pagos Programados. ",
"El SP obtendrá la información de la Base de Datos central de Informix.",
"FECHA : 15-03-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cnsif_consultafunciones( cID_USUARIOC char(8),cID_FUNCIONC char(10),pNumRegistro INTEGER,pRecuperacion INTEGER)
 
    RETURNING CHAR(5),CHAR(10),CHAR(6),CHAR(20),INTEGER,CHAR(60),CHAR(60),CHAR(100), CHAR(1),INTEGER;
													
	DEFINE iexiste 			INT;
	DEFINE cCodRet 			CHAR(5);
	DEFINE iSql_err 		INT;
	DEFINE cId_funcion 		CHAR(10);
	DEFINE cId_Modulo		CHAR(6);
	DEFINE cD_Modulo		CHAR(20);
	DEFINE iId_SubModulo 	INTEGER;
	DEFINE cD_SubModulo		CHAR(60);
	DEFINE cD_Funcion_link	CHAR(60);
	DEFINE cD_Funcion		CHAR(100);
	DEFINE cStatus 			CHAR(1);
	DEFINE iOrden 			INTEGER;
    DEFINE iCont            INTEGER;
	
	LET iexiste = 0;
	LET cCodRet = "00000";	
	LET iSql_err = 0;
	LET cId_funcion =" ";
	LET cId_Modulo	=" ";
	LET cD_Modulo=" ";
	LET iId_SubModulo = 0;
	LET cD_SubModulo = " ";
	LET cD_Funcion_link = "";
	LET cD_Funcion		= "";
	LET cStatus 		= "";
	LET iOrden 			=  0;
    LET iCont=0;
	
    
	
	BEGIN
		ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET cCodRet = iSql_err;
                RETURN cCodRet,cId_funcion,cId_Modulo,cD_Modulo,iId_SubModulo, cD_SubModulo,cD_Funcion_link,cD_Funcion,cStatus,iOrden;
            END IF;
        END EXCEPTION;
		--SET DEBUG FILE TO "/informix/VH/sp_cnsif_consultafunciones_pba.out";
		--TRACE ON;
		IF 	cID_USUARIOC ='' OR 
		cID_FUNCIONC = '' THEN
			LET cCodRet = "00003";
			RETURN cCodRet,cId_funcion,cId_Modulo,cD_Modulo,iId_SubModulo, cD_SubModulo,cD_Funcion_link,cD_Funcion,cStatus,iOrden;
		END IF;		
		
        IF pNumRegistro<0 THEN
            LET cCodRet='00098';
            RETURN cCodRet,cId_funcion,cId_Modulo,cD_Modulo,iId_SubModulo, cD_SubModulo,cD_Funcion_link,cD_Funcion,cStatus,iOrden;
        ELSE
            IF pRecuperacion<=0 THEN
                LET cCodRet='00098';
                RETURN cCodRet,cId_funcion,cId_Modulo,cD_Modulo,iId_SubModulo, cD_SubModulo,cD_Funcion_link,cD_Funcion,cStatus,iOrden;
            END IF;
        END IF; 
		
		EXECUTE FUNCTION sp_cnsif_confirmaejecutivo (cID_USUARIOC,cID_FUNCIONC)
		INTO cCodRet;
		  
		IF cCodRet = '00028' THEN 
			RETURN cCodRet,cId_funcion,cId_Modulo,cD_Modulo,iId_SubModulo, cD_SubModulo,cD_Funcion_link,cD_Funcion,cStatus,iOrden;
		END IF;
		
		SELECT nvl(Count(id_funcion),0) INTO iexiste  FROM si_seg_funciones;
		IF iexiste = 0 THEN
			LET cCodRet = "00002";
			RETURN cCodRet,cId_funcion,cId_Modulo,cD_Modulo,iId_SubModulo, cD_SubModulo,cD_Funcion_link,cD_Funcion,cStatus,iOrden;
		END IF;
		set isolation to dirty read;
       FOREACH
			SELECT --+AVOID_FULL ('informix'.si_seg_funciones)
			SKIP pNumRegistro FIRST pRecuperacion SSF.id_funcion,SSF.id_modulo, SSM.d_modulo,SSS.id_submodulo, SSS.d_submodulo,SSF.d_funcion_link,SSF.d_funcion,SSF.status,SSF.orden
			
			INTO cId_funcion,cId_Modulo,cD_Modulo,iId_SubModulo, cD_SubModulo,cD_Funcion_link,cD_Funcion,cStatus,iOrden
			FROM si_seg_funciones SSF
			LEFT JOIN si_seg_modulos SSM
			ON  SSM.Id_modulo = SSF.Id_modulo
			LEFT JOIN si_seg_submodulo SSS
			ON SSS.Id_submodulo = SSF.Id_submodulo
            order by id_submodulo,orden

            LET iCont=iCont+1;
			RETURN cCodRet,cId_funcion,cId_Modulo,cD_Modulo,iId_SubModulo, cD_SubModulo,cD_Funcion_link,cD_Funcion,cStatus,iOrden with resume;
		END FOREACH;	
         IF iCont = 0 THEN
            LET cCodRet = 1001; 
            RETURN cCodRet,cId_funcion,cId_Modulo,cD_Modulo,iId_SubModulo, cD_SubModulo,cD_Funcion_link,cD_Funcion,cStatus,iOrden;
        END IF 
    END
END PROCEDURE
DOCUMENT		
"AutOR : Antonio Flores",
"FUNCIONAMIENTO: Este SP regresara todas las funciones que se encuentran registraras dentro de la base con su id_modulo y la descripcion del modulo",
"asi como sus submodulos",
"FECHA : 21-12-2011",
"BD    : bdinteg",
"VER   : 1.0",
"Modificación: Victor Hugo Sánchez. Se agrego parametrización para la recuperacion de informacion";

CREATE PROCEDURE "informix".sp_cnsif_consultamovtosdiarioscta2(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCUENTA CHAR(20),dPERIODOI DATE,dPERIODOF DATE, cSISTEMACUENTA CHAR(20),cUsuario CHAR(8),cSuc CHAR(4),mImporte MONEY(14,2),pNumRegistro INTEGER,pRecuperacion INTEGER)

				returning CHAR(5)  AS Cod_Retorno,
						  DATE     AS Fecha,
						  DATETIME HOUR to FRACTION(3) AS Hora,
						  CHAR(4)  AS CveTransaccion,
						  CHAR(50) AS Desc_Transaccion,
						  CHAR(16) AS Folio,
						  DATE     AS Periodo_Inicial,
						  MONEY(14,2) AS Monto,
						  DATE     AS Periodo_Final,
						  CHAR(20) AS Sistema_Cuenta,
						  CHAR(1)  AS Naturaleza,
						  CHAR(40) AS Referencia,
						  CHAR(1)  AS Reversos,
						  CHAR(4)  AS Sucursal,
						  CHAR(20) AS CveProcedencia,
						  CHAR(50) AS Desc_Procedencia,
						  MONEY(14,2) AS Saldo,
						  CHAR(20) AS Numero_Tarjeta,
						  CHAR(1)  AS Reversados;

DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;							
--SISTEMA DE CUENTA 01 VARIABLES
DEFINE dFecha	 		DATE;
DEFINE dHora 			DATETIME HOUR to FRACTION(3);
DEFINE cTransaccion		CHAR(4);
DEFINE cD_Transaccion	CHAR(50);
DEFINE mMonto			MONEY(14,2);
DEFINE cNaturaleza		CHAR(1);
DEFINE mSaldo 			MONEY(14,2);
DEFINE cReferencia 		CHAR(40);
DEFINE cReversos		CHAR(1);
DEFINE cReversados		CHAR(1);
DEFINE cSucursal 	 	CHAR(4);
DEFINE cFolio 			CHAR(16);
DEFINE cProcedencia		CHAR(20);
DEFINE cD_Procedencia	CHAR(50);
DEFINE dPeriodoI_1		DATE;
DEFINE dPeriodoF_1		DATE;
DEFINE sNUMSERIAL       INT8;
--SISTEMA DE CUENTA 06 VARIABLES
DEFINE cNumtarjeta		CHAR(20);
--VARIABLES PARA FECHAS HISTORICAS
DEFINE cconsmovhis      CHAR(10);
DEFINE cconsmovhisold   CHAR(10);
DEFINE cconsmovhisold2  CHAR(10);
--VARIABLES DE PAGINACION
DEFINE iCont            INT;
--VARIABLE PARA LA EMPRESA
DEFINE pEmpresa     CHAR(3);
DEFINE cCodfun		CHAR(3);
DEFINE cCodref		INTEGER;
--inicializando variables
LET  iexiste = 0;
LET cCodRet = "00000";
LET iSql_err = 0 ;	
LET dFecha	 		= "";
LET dHora 			= "";
LET cTransaccion	= "";
LET cD_Transaccion	= "";
LET mMonto			= 0;
LET cNaturaleza		= "";
LET mSaldo 			= 0;
LET cReferencia		= "";
LET cReversos		= "";
LET cReversados		= "";
LET cSucursal 	 	= "";
LET cFolio 			= "";
LET cProcedencia	= "";
LET cD_Procedencia	= "";
LET dPeriodoI_1		= "";
LET dPeriodoF_1		= "";
LET sNUMSERIAL      =  0;
--SISTEMA DE CUENTA 06 VARIABLES
LET cNumtarjeta	= "";
--VARIABLES PARA FECHAS HISTORICAS
LET cconsmovhis     = '';
LET cconsmovhisold  = '';
LET cconsmovhisold2 = '';
--VARIABLES DE PAGINACION 
LET iCont       = 0;
LET pEmpresa   = '001';
LET cCodfun			='';
LET cCodref			=0;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
			cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados;
		END IF;
	END EXCEPTION;
		  	--SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_consultamovtosdiarioscta.out";
		  	--TRACE ON;
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cNUMCUENTA  = ''	OR 
		dPERIODOI   IS NULL OR 
		dPERIODOF 	IS NULL	OR 
		cSISTEMACUENTA = '' THEN 
		LET cCodRet = "00036";
		RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
		cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados;
	END IF;	

    IF pNumRegistro<0 THEN
        LET cCodRet='00098';
		RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
		cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados;					
    ELSE
        IF pRecuperacion<=0 THEN
            LET cCodRet='00098';
            RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
            cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados;
        END IF;
    END IF;  
	IF cSISTEMACUENTA <> 'CAPTACION' AND cSISTEMACUENTA <> 'CREDITO'  AND cSISTEMACUENTA <> 'INVERSIONES' THEN 
		LET cCodRet = "00037";
		RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
		cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados;
	END IF;

	--VALIDACION
	IF cSISTEMACUENTA = 'CAPTACION' THEN
		EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'01','1')
		INTO cCodRet;
	END IF;

	IF cSISTEMACUENTA = 'CREDITO' THEN
		EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'06','1')
		INTO cCodRet;
	END IF;

	IF cSISTEMACUENTA = 'INVERSIONES' THEN
		EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'03','1')
		INTO cCodRet;
	END IF;

	IF (cCodRet != '00000')  THEN
		RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
			   cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados;
	END IF;
	-- TERMINA VALIDACION

      SELECT valor
      INTO cconsmovhis
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'fechcon_movhis';

    SELECT valor
      INTO cconsmovhisold
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'FechIniCon_movhis_ol';

	SELECT valor
      INTO cconsmovhisold2
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'FechaIniMovhisOld2';
	   
	IF cSISTEMACUENTA = 'CAPTACION' THEN 
		SELECT NVL(COUNT(cuenta),0) INTO iexiste FROM bdicheq:sc_maechq WHERE cuenta  = cNUMCUENTA;
		IF iexiste  = 0 THEN 
			LET cCodRet = "00009";
			RETURN 
			cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
			cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados;
		END IF;

		SELECT NVL(COUNT(cuenta),0)  
			INTO iexiste
			FROM bdicheq:"informix".sc_movdia 
			WHERE empresa='001' AND cuenta  = cNUMCUENTA AND fech_alt BETWEEN dPERIODOI AND dPERIODOF
            AND monto_tot = CASE WHEN mImporte = 0 THEN monto_tot ELSE mImporte END
            AND sucursal = CASE WHEN cSuc = "" THEN sucursal ELSE cSuc END
            AND usuario = CASE WHEN cUsuario = "" THEN usuario ELSE cUsuario END;   
			IF iexiste  = 0 THEN 
				SELECT NVL(COUNT(cuenta),0)  
				INTO iexiste
				FROM bdicheq:"informix".sc_movhis 
				WHERE empresa='001' AND cuenta  = cNUMCUENTA AND fech_alt BETWEEN dPERIODOI AND dPERIODOF
                AND monto_tot = CASE WHEN mImporte = 0 THEN monto_tot ELSE mImporte END
                AND sucursal = CASE WHEN cSuc = "" THEN sucursal ELSE cSuc END
                AND usuario = CASE WHEN cUsuario = "" THEN usuario ELSE cUsuario END;  
				IF iexiste  = 0 THEN
					SELECT NVL(COUNT(cuenta),0)  
					INTO iexiste
					FROM bdicheq:"informix".sc_movhis_old 
					WHERE empresa='001' AND cuenta  = cNUMCUENTA AND fech_alt BETWEEN dPERIODOI AND dPERIODOF
                    AND monto_tot = CASE WHEN mImporte = 0 THEN monto_tot ELSE mImporte END
                    AND sucursal = CASE WHEN cSuc = "" THEN sucursal ELSE cSuc END
                    AND usuario = CASE WHEN cUsuario = "" THEN usuario ELSE cUsuario END;
					IF iexiste  = 0 THEN
						SELECT NVL(COUNT(cuenta),0)  
						INTO iexiste
						FROM bdicheq:"informix".sc_movhis_old2 
						WHERE empresa='001' AND cuenta  = cNUMCUENTA AND fech_alt BETWEEN dPERIODOI AND dPERIODOF
						AND monto_tot = CASE WHEN mImporte = 0 THEN monto_tot ELSE mImporte END
						AND sucursal = CASE WHEN cSuc = "" THEN sucursal ELSE cSuc END
						AND usuario = CASE WHEN cUsuario = "" THEN usuario ELSE cUsuario END;  
					END IF;
				END IF;
			END IF;

			IF iexiste  = 0 THEN 
                LET cCodRet = "00039";
                RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
                cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados;
			END IF;

            IF cID_FUNCIONC='CAP008' THEN
                SET ISOLATION TO DIRTY READ;
                FOREACH 			
                    SELECT SKIP pNumRegistro FIRST pRecuperacion MO.fech_alt,MO.fech_hor,MO.transacc,TR.descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
                            MO.sucursal,MO.folio_suc,   
                            dPERIODOI,dPERIODOF,MO.num_serial,MO.num_tarjeta
                    INTO dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,mSaldo,cReferencia,cReversos,cSucursal,cFolio,
                    dPeriodoI_1,dPeriodoF_1,sNUMSERIAL,cNumtarjeta
                    FROM bdicheq:sc_maechq MC
                    LEFT JOIN bdicheq:sc_movdia  MO 
                    ON MC.cuenta = MO.cuenta
                    LEFT JOIN bdinteg:si_transacc TR 
                    ON MO.transacc = TR.numero 
                    WHERE MO.empresa='001' AND MO.cuenta = cNUMCUENTA 
                    AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF	AND MO.producto<>'1600'									
                UNION
                    SELECT 	MO.fech_alt,MO.fech_hor,MO.transacc,TR.descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
                        MO.sucursal,MO.folio_suc,   
                        dPERIODOI,dPERIODOF,MO.num_serial,MO.num_tarjeta
                FROM bdicheq:sc_maechq MC
                    LEFT JOIN bdicheq:sc_movhis  MO 
                    ON MC.cuenta = MO.cuenta
                    LEFT JOIN bdinteg:si_transacc TR 
                    ON MO.transacc = TR.numero 
                    WHERE MO.empresa='001' AND MO.cuenta = cNUMCUENTA
                AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF	AND MO.producto<>'1600'	
                AND MO.fech_alt >= cconsmovhis
            UNION
                SELECT  MO.fech_alt,MO.fech_hor,MO.transacc,TR.descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
                        MO.sucursal,MO.folio_suc,   
                        dPERIODOI,dPERIODOF,MO.num_serial,MO.num_tarjeta
                FROM bdicheq:sc_maechq MC
                LEFT JOIN bdicheq:sc_movhis_old  MO 
                ON MC.cuenta = MO.cuenta
                LEFT JOIN bdinteg:si_transacc TR 
                ON MO.transacc = TR.numero
                WHERE MO.empresa='001' AND MO.cuenta = cNUMCUENTA
                AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF AND MO.producto<>'1600'	
                AND MO.fech_alt >= cconsmovhisold
                AND MO.fech_alt < cconsmovhis			
            UNION
                SELECT 	MO.fech_alt,MO.fech_hor,MO.transacc,TR.descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
                        MO.sucursal,MO.folio_suc,   
                        dPERIODOI,dPERIODOF,MO.num_serial,MO.num_tarjeta
                FROM bdicheq:sc_maechq MC
                LEFT JOIN bdicheq:sc_movhis_old2  MO 
                ON MC.cuenta = MO.cuenta
                LEFT JOIN bdinteg:si_transacc TR 
                ON MO.transacc = TR.numero
                WHERE MO.empresa='001' AND MO.cuenta = cNUMCUENTA
                AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF AND MO.producto<>'1600'	
                AND MO.fech_alt >= cconsmovhisold2
                AND MO.fech_alt < cconsmovhisold 
                ORDER BY MO.fech_alt DESC,MO.fech_hor DESC 

                IF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'')>0 THEN
                    SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'';
                ELIF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE transacc=cTransaccion AND transacc<>'')>0 THEN
                    SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia WHERE transacc=cTransaccion AND transacc<>'';
                ELIF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE sucursal=cSucursal AND transacc='')>0 THEN
                    SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia WHERE sucursal=cSucursal AND transacc='';
                ELSE
                    LET cProcedencia="";
                    LET cD_Procedencia="";
                END IF;


                LET iCont=iCont+1;
                RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
                cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados WITH resume;						
                END FOREACH;

                IF iCont = 0 THEN
                LET cCodRet = '1001'; 
                    RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
                           cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados;
                END IF
            ELSE
                SET ISOLATION TO DIRTY READ;
                FOREACH 			
                    SELECT SKIP pNumRegistro FIRST pRecuperacion MO.fech_alt,MO.fech_hor,MO.transacc,TR.descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
                            MO.sucursal,MO.folio_suc,   
                            dPERIODOI,dPERIODOF,MO.num_serial,MO.num_tarjeta
                    INTO dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,mSaldo,cReferencia,cReversos,cSucursal,cFolio,
                    dPeriodoI_1,dPeriodoF_1,sNUMSERIAL,cNumtarjeta
                    FROM bdicheq:sc_maechq MC
                    LEFT JOIN bdicheq:sc_movdia MO 
                    ON MC.cuenta = MO.cuenta
                    LEFT JOIN bdinteg:si_transacc TR 
                    ON MO.transacc = TR.numero 
                    WHERE MO.empresa='001' AND MO.cuenta = cNUMCUENTA 
                    AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF
                    AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
                    AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
                    AND MO.usuario = CASE WHEN cUsuario = "" THEN MO.usuario ELSE cUsuario END  											
                UNION
                    SELECT 	MO.fech_alt,MO.fech_hor,MO.transacc,TR.descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
                        MO.sucursal,MO.folio_suc,   
                        dPERIODOI,dPERIODOF,MO.num_serial,MO.num_tarjeta
                FROM bdicheq:sc_maechq MC
                    LEFT JOIN bdicheq:sc_movhis MO 
                    ON MC.cuenta = MO.cuenta
                    LEFT JOIN bdinteg:si_transacc TR 
                    ON MO.transacc = TR.numero 
                    WHERE MO.empresa='001' AND MO.cuenta = cNUMCUENTA
                AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF	
                AND MO.fech_alt >= cconsmovhis
                AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
                AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
                AND MO.usuario = CASE WHEN cUsuario = "" THEN MO.usuario ELSE cUsuario END 
            UNION
                SELECT  MO.fech_alt,MO.fech_hor,MO.transacc,TR.descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
                        MO.sucursal,MO.folio_suc,   
                        dPERIODOI,dPERIODOF,MO.num_serial,MO.num_tarjeta
                FROM bdicheq:sc_maechq MC
                LEFT JOIN bdicheq:sc_movhis_old  MO 
                ON MC.cuenta = MO.cuenta
                LEFT JOIN bdinteg:si_transacc TR 
                ON MO.transacc = TR.numero
                WHERE MO.empresa='001' AND MO.cuenta = cNUMCUENTA
                AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF
                AND MO.fech_alt >= cconsmovhisold
                AND MO.fech_alt < cconsmovhis
                AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
                AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
                AND MO.usuario = CASE WHEN cUsuario = "" THEN MO.usuario ELSE cUsuario END 			
           UNION
                SELECT 	MO.fech_alt,MO.fech_hor,MO.transacc,TR.descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
                        MO.sucursal,MO.folio_suc,   
                        dPERIODOI,dPERIODOF,MO.num_serial,MO.num_tarjeta
                FROM bdicheq:sc_maechq MC
                LEFT JOIN bdicheq:sc_movhis_old2  MO 
                ON MC.cuenta = MO.cuenta
                LEFT JOIN bdinteg:si_transacc TR 
                ON MO.transacc = TR.numero
                WHERE MO.empresa='001' AND MO.cuenta = cNUMCUENTA
                AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF
                AND MO.fech_alt >= cconsmovhisold2
                AND MO.fech_alt < cconsmovhisold 
                AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
                AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
                AND MO.usuario = CASE WHEN cUsuario = "" THEN MO.usuario ELSE cUsuario END 	 
				ORDER BY MO.fech_alt DESC,MO.fech_hor DESC

                IF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'')>0 THEN
                    SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'';
                ELIF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE transacc=cTransaccion AND transacc<>'')>0 THEN
                    SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia WHERE transacc=cTransaccion AND transacc<>'';
                ELIF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE sucursal=cSucursal AND transacc='')>0 THEN
                    SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia WHERE sucursal=cSucursal AND transacc='';
                ELSE
                    LET cProcedencia="";
                    LET cD_Procedencia="";
                END IF;

                LET iCont=iCont+1;
                RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
                cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados WITH resume;						
                END FOREACH;

                IF iCont = 0 THEN
                LET cCodRet = '1001'; 
                    RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
                           cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados;
                END IF

            END IF;
	ELIF cSISTEMACUENTA = 'CREDITO' THEN 
        FOREACH
            SELECT LIMIT 1 NVL(COUNT(num_credito),0) AS CONT INTO iexiste FROM bdicred:sd_maecred WHERE num_credito = cNUMCUENTA
            UNION
            SELECT NVL(COUNT(num_credito),0) AS CONT FROM bdicred:sd_maecredcrd WHERE num_credito = cNUMCUENTA ORDER BY CONT DESC
        END FOREACH;
		IF iexiste  = 0 THEN 
			LET cCodRet = "00009";
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
			cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados;
		END IF;

		SELECT NVL(COUNT(num_credito),0)  
		INTO iexiste
		FROM bdicred:sd_movdia 
		WHERE empresa='001' AND num_credito = cNUMCUENTA AND fecha_mov BETWEEN dPERIODOI AND dPERIODOF
        AND monto = CASE WHEN mImporte = 0 THEN monto ELSE mImporte END
        AND sucursal = CASE WHEN cSuc = "" THEN sucursal ELSE cSuc END
        AND usuario = CASE WHEN cUsuario = "" THEN usuario ELSE cUsuario END; 
		IF iexiste  = 0 THEN 
			SELECT NVL(COUNT(num_credito),0)  
			INTO iexiste
			FROM bdicred:sd_movhis 
			WHERE empresa='001' AND num_credito = cNUMCUENTA AND fecha_mov BETWEEN dPERIODOI AND dPERIODOF
            AND monto = CASE WHEN mImporte = 0 THEN monto ELSE mImporte END
            AND sucursal = CASE WHEN cSuc = "" THEN sucursal ELSE cSuc END
            AND usuario = CASE WHEN cUsuario = "" THEN usuario ELSE cUsuario END; 
			IF iexiste  = 0 THEN 
				SELECT NVL(COUNT(num_credito),0)  
				INTO iexiste
				FROM bdicred:sd_movdiacrd 
				WHERE empresa='001' AND num_credito = cNUMCUENTA AND fecha_mov BETWEEN dPERIODOI AND dPERIODOF
                AND monto = CASE WHEN mImporte = 0 THEN monto ELSE mImporte END
                AND sucursal = CASE WHEN cSuc = "" THEN sucursal ELSE cSuc END
                AND usuario = CASE WHEN cUsuario = "" THEN usuario ELSE cUsuario END; 
				IF iexiste  = 0 THEN 
					SELECT NVL(COUNT(num_credito),0)  
					INTO iexiste
					FROM bdicred:sd_movhiscrd 
					WHERE empresa='001' AND num_credito = cNUMCUENTA AND fecha_mov BETWEEN dPERIODOI AND dPERIODOF
                    AND monto = CASE WHEN mImporte = 0 THEN monto ELSE mImporte END
                    AND sucursal = CASE WHEN cSuc = "" THEN sucursal ELSE cSuc END
                    AND usuario = CASE WHEN cUsuario = "" THEN usuario ELSE cUsuario END; 					
				END IF;
			END IF;
		END IF;

		IF iexiste  = 0 THEN 
			LET cCodRet = "00039";
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
			cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados;
		END IF;

		SET ISOLATION TO DIRTY READ;
		FOREACH 
			SELECT SKIP pNumRegistro FIRST pRecuperacion  MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,   
            MO.transacc_suc,TR.descripcion,MO.referencia,
            MO.monto,TR.sentido,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia
			INTO 		
			cCodfun,cCodref,dFecha,dHora,cNumtarjeta,cFolio,cTransaccion,cD_Transaccion,cReferencia,mMonto,cNaturaleza,cReversos,cSucursal,
			dPeriodoI_1,dPeriodoF_1,sNUMSERIAL
			FROM bdicred:sd_maecred MC
			LEFT JOIN bdicred:sd_movdia MO
			ON MC.num_credito = MO.num_credito
			LEFT JOIN bdicred:sd_transfun TR
			ON MO.codigo_fun= TR.codigo_fun and MO.codigo_ref= TR.codigo_ref
			WHERE MO.num_credito = cNUMCUENTA
			AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF
            AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
            AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
            AND MO.usuario = CASE WHEN cUsuario = "" THEN MO.usuario ELSE cUsuario END 	
		UNION
			SELECT --+AVOID_FULL (bdicred:"informix".sd_movhis) 
			MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,   
            MO.transacc_suc,TR.descripcion,MO.referencia,
            MO.monto,TR.sentido,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia
			FROM bdicred:sd_maecred MC
			LEFT JOIN bdicred:sd_movhis  MO
			ON MC.num_credito = MO.num_credito
			LEFT JOIN bdicred:sd_transfun TR
			ON MO.codigo_fun= TR.codigo_fun and MO.codigo_ref= TR.codigo_ref
			WHERE MO.num_credito = cNUMCUENTA
			AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF
            AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
            AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
            AND MO.usuario = CASE WHEN cUsuario = "" THEN MO.usuario ELSE cUsuario END 				
		UNION  	
			SELECT MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,   
            MO.transacc_suc,TR.descripcion,MO.referencia,
            MO.monto,TR.sentido,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia
			FROM bdicred:sd_maecredcrd MC
			LEFT JOIN bdicred:sd_movdiacrd  MO
			ON MC.num_credito = MO.num_credito
			LEFT JOIN bdicred:sd_transfun TR
			ON MO.codigo_fun= TR.codigo_fun and MO.codigo_ref= TR.codigo_ref
			WHERE MO.empresa='001' AND MO.num_credito = cNUMCUENTA
			AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF
            AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
            AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
            AND MO.usuario = CASE WHEN cUsuario = "" THEN MO.usuario ELSE cUsuario END 	
		UNION 
			SELECT MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,   
            MO.transacc_suc,TR.descripcion,MO.referencia,
            MO.monto,TR.sentido,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia
			FROM bdicred:sd_maecredcrd MC
			LEFT JOIN bdicred:sd_movhiscrd  MO
			ON MC.num_credito = MO.num_credito
			LEFT JOIN bdicred:sd_transfun TR
			ON MO.codigo_fun= TR.codigo_fun and MO.codigo_ref= TR.codigo_ref
			WHERE MO.num_credito = cNUMCUENTA
			AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF
            AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
            AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
            AND MO.usuario = CASE WHEN cUsuario = "" THEN MO.usuario ELSE cUsuario END 	
            ORDER BY MO.fecha_mov DESC,MO.hora_mov DESC

            IF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'')>0 THEN
                SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'';
            ELIF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE transacc=cTransaccion AND transacc<>'')>0 THEN
                SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia WHERE transacc=cTransaccion AND transacc<>'';
            ELIF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE sucursal=cSucursal AND transacc='')>0 THEN
                SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia WHERE sucursal=cSucursal AND transacc='';
            ELSE
                LET cProcedencia="";
                LET cD_Procedencia="";
            END IF;
			
			LET iCont=iCont+1;

			IF cCodfun ='001' AND cCodref in (1,2,3) THEN
				IF iCont>0 THEN
					LET iCont=iCont - 1;
				END IF;

			ELIF cCodfun ='002' AND cCodref =1 THEN
				IF iCont>0 THEN
					LET iCont=iCont - 1;
				END IF;
			ELSE
				RETURN 
					cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
					cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados WITH resume;
			END IF;

		END FOREACH;

					
    	IF iCont = 0 AND pNumRegistro=0 THEN
			LET cCodRet = '00039'; 
				RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
					   cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados;
		
		ELIF iCont=0 THEN
			LET cCodRet = '1001'; 
				RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
					   cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados;
		END IF
	ELIF cSISTEMACUENTA = 'INVERSIONES' THEN 
		SELECT NVL(COUNT(cuenta),0) INTO iexiste FROM bdinvers:sv_maeinv WHERE cuenta  = cNUMCUENTA;
		IF iexiste  = 0 THEN 
			LET cCodRet = "00009";
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
			cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados;
		END IF;
        
        FOREACH
		SELECT LIMIT 1 NVL(COUNT(cuenta),0)  AS CONT
		INTO iexiste
		FROM bdinvers:sv_movdia 
		WHERE cuenta = cNUMCUENTA AND fech_alt BETWEEN dPERIODOI AND dPERIODOF
        AND monto_tot = CASE WHEN mImporte = 0 THEN monto_tot ELSE mImporte END
        AND sucursal = CASE WHEN cSuc = "" THEN sucursal ELSE cSuc END
        AND usuario = CASE WHEN cUsuario = "" THEN usuario ELSE cUsuario END 	
        UNION
		SELECT NVL(COUNT(cuenta),0) AS CONT  
		FROM bdinvers:sv_movhis 
		WHERE cuenta = cNUMCUENTA AND fech_alt BETWEEN dPERIODOI AND dPERIODOF 
        AND monto_tot = CASE WHEN mImporte = 0 THEN monto_tot ELSE mImporte END
        AND sucursal = CASE WHEN cSuc = "" THEN sucursal ELSE cSuc END
        AND usuario = CASE WHEN cUsuario = "" THEN usuario ELSE cUsuario END 	
        ORDER BY CONT DESC
        END FOREACH;
		IF iexiste  = 0 THEN 
			LET cCodRet = "00039";
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
			cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados;
		END IF;

    	SET ISOLATION TO DIRTY READ;
		FOREACH 
			SELECT SKIP pNumRegistro FIRST pRecuperacion 	
			MO.fech_alt,MO.fech_hor,MO.folio_suc,MO.transacc,TR.descripcion,MO.monto_tot,MO.cancelad,dPERIODOI,dPERIODOF,MO.secuencia,MO.sucursal
			INTO 
			dFecha,dHora,cFolio,cTransaccion,cD_Transaccion,mMonto,cReversados,dPeriodoI_1,dPeriodoF_1,sNUMSERIAL,cSucursal
			FROM bdinvers:sv_maeinv MC
			LEFT JOIN bdinvers:sv_movdia MO 
			ON MC.cuenta = MO.cuenta
			LEFT JOIN bdinteg:si_transacc TR 
			ON MO.transacc = TR.numero  
			WHERE MO.cuenta = cNUMCUENTA
			AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF
            AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
            AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
            AND MO.usuario = CASE WHEN cUsuario = "" THEN MO.usuario ELSE cUsuario END 	
			UNION
			SELECT MO.fech_alt,MO.fech_hor,MO.folio_suc,MO.transacc,TR.descripcion,MO.monto_tot,MO.cancelad,dPERIODOI,dPERIODOF,MO.secuencia,MO.sucursal
			FROM bdinvers:sv_maeinv MC
			LEFT JOIN bdinvers:sv_movhis MO 
			ON MC.cuenta = MO.cuenta
			LEFT JOIN bdinteg:si_transacc TR 
			ON MO.transacc = TR.numero  
			WHERE MO.cuenta = cNUMCUENTA
			AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF
            AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
            AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
            AND MO.usuario = CASE WHEN cUsuario = "" THEN MO.usuario ELSE cUsuario END 	
            ORDER BY MO.fech_alt DESC,MO.fech_hor DESC

			LET iCont=iCont+1;	

			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
			cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados WITH resume;
		END FOREACH;

		IF iCont = 0 THEN
		LET cCodRet = '1001'; 
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
				   cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados;
		END IF
	END IF
END

END PROCEDURE

DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Este sp realizara la busqueda por tipo de cuenta, dependiendo de tipo de cuenta regresara los datos correspondientes, para captacion o cuenta de cheques, para cuentas tipo credito 06 que seran de credito y las cuentas tipo 03 que son de  tipo inversiones",
"FECHA : 09-02-2012",
"ACTUALIZO: Victor Hugo Sánchez M.",
"MODIFICACION: Se agregaron los parametros empleado,sucursal e importe para filtrar movimientos",
"FECHA: 04/07/2012",
"BD    : bdinteg",
"VER   : 2.0";

CREATE PROCEDURE "informix".sp_cnsif_consultasucursal(cID_USUARIOC CHAR(8),cID_FUNCIONC CHAR(10),cSucursal CHAR(4))

				returning CHAR(5)  AS Cod_Retorno,
                          CHAR(40) AS Nom_Sucursal,
						  CHAR(40) AS Plaza;

DEFINE iexiste 			INT;
DEFINE cCodRet          CHAR(5);
DEFINE iSql_err 		INT;
DEFINE cNomSucursal 	CHAR(40);
DEFINE cNumsu           CHAR(30);
DEFINE cPlaza			CHAR(40);
--inicializando variables
LET iexiste 			 = 0;
LET cCodRet 	   = "00000";
LET iSql_err 			=  0;
LET cNomSucursal        = "";
LET cNumsu              = "";
LET cPlaza        = "";


BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
			RETURN cCodRet,cNomSucursal,cPlaza;
		END IF;
	END EXCEPTION;
	--  SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_consultasucursal.out";
	--  TRACE ON;
    IF 	cID_USUARIOC = '' 	OR
        cID_FUNCIONC = '' 	OR
        cSucursal    = ''   THEN
            LET cCodRet = "00054";
            RETURN cCodRet,cNomSucursal,cPlaza;
    END IF;


	EXECUTE FUNCTION sp_cnsif_confirmaejecutivo (cID_USUARIOC,cID_FUNCIONC)
	INTO cCodRet;

	IF cCodRet = "00028" THEN
		RETURN cCodRet,cNomSucursal,cPlaza;
	END IF;

    FOREACH
        EXECUTE FUNCTION sp_consulta_sucursal_numero (cSucursal,'001')
        INTO cNumsu,cNomSucursal
    END FOREACH;

    IF cNomSucursal IS NULL THEN
        LET cCodRet = "00105";
    END IF;

	-- Busqueda de la plaza
	SELECT --+AVOID_FULL ("informix".si_plazas)
	sp.nombre AS plaza
	INTO cPlaza
	FROM bdinteg:si_sucursales ss, bdinteg:si_plazas sp
	WHERE ss.sucursal = cSucursal
		AND sp.plaza = ss.plaza
		AND sp.empresa = '001';


    RETURN cCodRet,cNomSucursal, cPlaza;
END

END PROCEDURE
DOCUMENT
"Autor :Victor Hugo Sánchez Mendoza",
"FUNCIONAMIENTO:Consulta Sucursales por numero CNSIFWEB",
"FECHA : 04-07-2012",
"BD    : bdinteg",
"VER   : 1.0",
"FECHA MODIFICACION: 29/04/2013",
"MODIFICO: Oscar Flores Conde",
"MODIFICACIÓN: SE AGREGA LA PLAZA DE LA SUCURSAL";

CREATE PROCEDURE "informix".sp_cnsif_scoringsolic(cID_USUARIOC char(08),cID_FUNCIONC CHAR(10),cNUMSOL CHAR(20))

				returning CHAR(5)  AS Cod_Retorno,
						  CHAR(80) AS Categoria,
						  CHAR(80) AS Respuesta,
						  DECIMAL(5,2) AS Puntuacion;
								

DEFINE iexiste 			INT;
DEFINE cCodRet 		CHAR(5);
DEFINE iSql_err 		INT;
--CLIENTES VARIABLES
DEFINE cCategoria	   CHAR(80);
DEFINE cRespuesta	   CHAR(80);
DEFINE dPuntuacion	   DECIMAL(5,2);


--inicializando variables
LET  iexiste 			 = 0;
LET cCodRet 	   = "00000";
LET iSql_err 			= 0 ;
LET cCategoria	 		= "";
LET cRespuesta 			= "";
LET dPuntuacion			=  0;


BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN
			cCodRet,cCategoria,cRespuesta,dPuntuacion;
		END IF;
	END EXCEPTION;
	-- SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_scoringsolic.out";
	-- TRACE ON;
	
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cNUMSOL  = ''	THEN
		LET cCodRet = "00045";
		RETURN
			cCodRet,cCategoria,cRespuesta,dPuntuacion;
	END IF;

	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMSOL,'06','5')
	INTO
	cCodRet;
	IF (cCodRet != '00000')  THEN
		RETURN cCodRet,cCategoria,cRespuesta,dPuntuacion;
	END IF;
	-- TERMINA VALIDACION

		SELECT NVL(COUNT(num_solicitud),0) into iexiste FROM bdisolic:ss_detalle_scoring WHERE num_solicitud  = cNUMSOL;
		IF iexiste  = 0 THEN
			LET cCodRet = "00071";
			RETURN
			cCodRet,cCategoria,cRespuesta,dPuntuacion;
		END IF;
		set isolation to dirty read;
		FOREACH
			Select --+AVOID_FULL (bdisolic:"informix".ss_detalle_scoring) 
			trim(a.descripcion) as CATEGORIA, trim(c.descripcion) as respuesta, nvl(b.valor,0) as valor
			INTO cCategoria,cRespuesta,dPuntuacion
			From bdisolic:ss_scoring_grupo a, bdisolic:ss_detalle_scoring b, bdisolic:ss_scoring_element c
			Where a.empresa = '001'
			and a.empresa = c.empresa
			and a.empresa = b.empresa
			and a.seccion = '2'
			and a.seccion = b.seccion
			and a.grupo = b.grupo
			and b.tpo_persona='01'
			and b.num_solicitud = cNUMSOL
			and a.seccion = c.seccion
			and a.grupo = c.grupo
			and b.elemento = c.elemento
			and b.tpo_persona = c.tpo_persona
			order by b.seccion, b.grupo, b.elemento

			RETURN
			cCodRet,cCategoria,cRespuesta,dPuntuacion WITH RESUME;

		END FOREACH;
END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la información del Scoring para las Solicitudes de Crédito. El SP obtendrá la información de la Base de Datos central de Informix, enviando como parámetro el  No. de Solicitud",
"FECHA : 10-02-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cnsif_sitespecial(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCLIENTE CHAR(20),cNUMCUENTA CHAR(20),cTIPOBUSQUEDA CHAR(1),pNumRegistro INTEGER,pRecuperacion INTEGER)
            
			RETURNING   CHAR(5)  AS Cod_Retorno,
						CHAR(1)  AS Tipo_Movimiento,
						CHAR(20) AS Movimiento,
						CHAR(1)  AS Cve_Situacion,
						SMALLINT AS Cve_Causa,
						CHAR(75) AS Desc_Situacion_Especial,
						CHAR(12) AS Cve_Situacion_Origen, 
						CHAR(20) AS Situacion_Origen,
						CHAR(4)  AS Sucursal,
						CHAR(8)  AS Numero_Ejecutivo,
						CHAR(45) AS Nombre_Ejecutivo,
						CHAR(8)  AS Usuario_Alta,
						DATETIME YEAR TO SECOND AS Fecha_Alta,
						CHAR(8)  AS Usuario_Modifica,
						DATETIME YEAR TO SECOND AS Fecha_Modifica;
											

DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;

-- SEGUN LAYOUT DE SALIDA 
DEFINE cTipoMovimiento   CHAR(1);
DEFINE cMovimiento       CHAR(20);
DEFINE cClaveSituacion   CHAR(1);
DEFINE smallCveCausa     SMALLINT;
DEFINE cDescSitEspecial  CHAR(75);
DEFINE cCveSitOrigen     CHAR(12);
DEFINE cSituacionOrigen  CHAR(20);
DEFINE cSucursal         CHAR(4);
DEFINE cNoEjecutivo      CHAR(8);
DEFINE cNombreEjecutivo  CHAR(45);   
DEFINE cUsuarioAlta      CHAR(8);
DEFINE dFechaAlta        DATETIME YEAR TO SECOND;
DEFINE cUsuarioModifica  CHAR(8);
DEFINE dFechaModifica    DATETIME YEAR TO SECOND;

--VARIABLES DE PAGINACION
DEFINE iCont            INT;

--INICIALIZACION DE VARIABLES
LET  iexiste 		 = 0;
LET cCodRet 		 = "00000";
LET iSql_err 		 = 0;
LET iCont            = 0;

-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************
LET cTipoMovimiento    = " ";
LET cMovimiento        = 0;
LET cClaveSituacion    = " ";
LET smallCveCausa      = " ";        
LET cDescSitEspecial   = " ";  
LET cCveSitOrigen      = " ";
LET cSituacionOrigen   = " ";
LET cSucursal          = " ";
LET cNoEjecutivo       = " ";
LET cNombreEjecutivo   = " ";
LET cUsuarioAlta       = 0;
LET dFechaAlta         = " ";
LET cUsuarioModifica   = " ";
LET dFechaModifica     = " "; 


--VARIABLES DE PAGINACION
LET iCont               = 0;
   
BEGIN
   ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet, cTipoMovimiento, cMovimiento, cClaveSituacion, smallCveCausa, cDescSitEspecial, cCveSitOrigen, cSituacionOrigen,
				   cSucursal, cNoEjecutivo, cNombreEjecutivo, cUsuarioAlta, dFechaAlta, cUsuarioModifica, dFechaModifica;					
		END IF;
	END EXCEPTION;	

	  --    SET debug FILE TO "/tmp/CNSIF/sp_cnsif_sitespecial.out";
	  --    TRACE ON;
-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

    IF  cID_USUARIOC = '' OR
	    cID_FUNCIONC ='' THEN
       LET cCodRet = "00045";
       RETURN cCodRet, cTipoMovimiento, cMovimiento, cClaveSituacion, smallCveCausa, cDescSitEspecial, cCveSitOrigen, cSituacionOrigen,
			  cSucursal, cNoEjecutivo, cNombreEjecutivo, cUsuarioAlta, dFechaAlta, cUsuarioModifica, dFechaModifica;
    END IF;
	
    IF cTIPOBUSQUEDA='1' THEN
        IF cNUMCLIENTE = '' THEN
           LET cCodRet = "00045";
           RETURN cCodRet, cTipoMovimiento, cMovimiento, cClaveSituacion, smallCveCausa, cDescSitEspecial, cCveSitOrigen, cSituacionOrigen,
			  cSucursal, cNoEjecutivo, cNombreEjecutivo, cUsuarioAlta, dFechaAlta, cUsuarioModifica, dFechaModifica;
        END IF;
    ELSE
        IF cNUMCUENTA = '' THEN
           LET cCodRet = "00045";
           RETURN cCodRet, cTipoMovimiento, cMovimiento, cClaveSituacion, smallCveCausa, cDescSitEspecial, cCveSitOrigen, cSituacionOrigen,
			  cSucursal, cNoEjecutivo, cNombreEjecutivo, cUsuarioAlta, dFechaAlta, cUsuarioModifica, dFechaModifica;
        END IF;
    END IF;
	IF cTIPOBUSQUEDA <> '1' AND cTIPOBUSQUEDA <> '2' THEN 
		LET cCodRet = "00049";
		RETURN cCodRet, cTipoMovimiento, cMovimiento, cClaveSituacion, smallCveCausa, cDescSitEspecial, cCveSitOrigen, cSituacionOrigen,
			  cSucursal, cNoEjecutivo, cNombreEjecutivo, cUsuarioAlta, dFechaAlta, cUsuarioModifica, dFechaModifica;
	END IF;

    IF pNumRegistro<0 THEN
        LET cCodRet='00098';
		RETURN cCodRet, cTipoMovimiento, cMovimiento, cClaveSituacion, smallCveCausa, cDescSitEspecial, cCveSitOrigen, cSituacionOrigen,
			   cSucursal, cNoEjecutivo, cNombreEjecutivo, cUsuarioAlta, dFechaAlta, cUsuarioModifica, dFechaModifica;				
    ELSE
        IF pRecuperacion<=0 THEN
            LET cCodRet='00098';
            RETURN cCodRet, cTipoMovimiento, cMovimiento, cClaveSituacion, smallCveCausa, cDescSitEspecial, cCveSitOrigen, cSituacionOrigen,
                   cSucursal, cNoEjecutivo, cNombreEjecutivo, cUsuarioAlta, dFechaAlta, cUsuarioModifica, dFechaModifica;
        END IF;
    END IF;   
	
    IF cTIPOBUSQUEDA = '1' THEN
		SELECT NVL(COUNT(numcte),0) INTO iexiste FROM si_cliente WHERE empresa = '001' AND  numcte = cNUMCLIENTE; 
		IF iexiste  = 0 THEN 
		LET cCodRet = "00050";
		RETURN cCodRet, cTipoMovimiento, cMovimiento, cClaveSituacion, smallCveCausa, cDescSitEspecial, cCveSitOrigen, cSituacionOrigen,
			   cSucursal, cNoEjecutivo, cNombreEjecutivo, cUsuarioAlta, dFechaAlta, cUsuarioModifica, dFechaModifica;
		END IF;
	 
	--VALIDACION 
	IF cTIPOBUSQUEDA = '1' THEN
		EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCLIENTE,'06','2')
		INTO
		cCodRet;
	ELSE
		EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'06','1')
		INTO
		cCodRet;
	END IF
	IF (cCodRet != '00000')  THEN
	    RETURN cCodRet, cTipoMovimiento, cMovimiento, cClaveSituacion, smallCveCausa, cDescSitEspecial, cCveSitOrigen, cSituacionOrigen,
			   cSucursal, cNoEjecutivo, cNombreEjecutivo, cUsuarioAlta, dFechaAlta, cUsuarioModifica, dFechaModifica;					
	END IF;
	-- TERMINA VALIDACION	

	-- ****************************************************************************
	-- obtener registros
	-- ****************************************************************************

        FOREACH
			SELECT LIMIT 1 NVL(COUNT(*),0) AS CONT INTO iexiste 
			FROM bdisitesp:se_ctessitespcte
            WHERE numcte = cNUMCLIENTE
            UNION
			SELECT NVL(COUNT(*),0) AS CONT
			FROM bdisitesp:se_ctessitespcte_his 
			WHERE numcte = cNUMCLIENTE ORDER BY CONT DESC
       END FOREACH;     

		IF iexiste  = 0 THEN 
		LET cCodRet = "00100";
		RETURN cCodRet, cTipoMovimiento, cMovimiento, cClaveSituacion, smallCveCausa, cDescSitEspecial, cCveSitOrigen, cSituacionOrigen,
			   cSucursal, cNoEjecutivo, cNombreEjecutivo, cUsuarioAlta, dFechaAlta, cUsuarioModifica, dFechaModifica;
		END IF;

		SET ISOLATION TO DIRTY READ;

		FOREACH

			SELECT SKIP pNumRegistro FIRST pRecuperacion  
			   a.tipomovto,
			CASE
			   WHEN a.tipomovto = 'M' THEN 
				'MARCA'
			   WHEN a.tipomovto = 'S' THEN 
				'SUSTITUCION'
			   WHEN a.tipomovto = 'E' THEN 
				'ELIMINACION'
			   ELSE 
				' '
			   END AS tipo_movimiento,a.situacion,a.causa,b.descripcion,a.cvesitesporigen,csit.descripcion,
			        a.empleadoefectuo ,	a.usralta,a.fchalta,a.usrmodifica, a.fchmodifica
			INTO    cTipoMovimiento, cMovimiento, cClaveSituacion, smallCveCausa, cDescSitEspecial, cCveSitOrigen, cSituacionOrigen,
				    cNoEjecutivo, cUsuarioAlta, dFechaAlta, cUsuarioModifica, dFechaModifica
			FROM bdisitesp:se_ctessitespcte a
			LEFT JOIN  bdisitesp:se_catsitesp b ON a.situacion = b .situacion
			AND a.causa = b.causa
			LEFT JOIN bdisitesp:se_sitesporigen csit ON a.cvesitesporigen = csit.cvesitesporigen
			WHERE a.numcte = cNUMCLIENTE
		UNION
			SELECT --+AVOID_FULL(bdisitesp:"informix".se_sitesporigen)
			a.tipomovto,
			CASE
			   WHEN a.tipomovto = 'M' THEN 
				'MARCA'
			   WHEN a.tipomovto = 'S' THEN 
				'SUSTITUCION'
			   WHEN a.tipomovto = 'E' THEN 
				'ELIMINACION'
			   ELSE 
				' '
			   END AS tipo_movimiento,a.situacion,a.causa,b.descripcion,cast(a.cvesitesporigen as char(2)),csit.descripcion,
			       NVL(a.empleadoefectuo,''), a.usralta,a.fchalta,a.usrmodifica, a.fchmodifica 
			FROM bdisitesp:se_ctessitespcte_his a
			LEFT JOIN  bdisitesp:se_catsitesp b ON a.situacion = b .situacion
			AND a.causa = b.causa
			LEFT JOIN bdisitesp:se_sitesporigen csit ON a.cvesitesporigen = csit.cvesitesporigen
			WHERE a.numcte = cNUMCLIENTE
			
			--para sacar el nombre del usuario
			IF cNoEjecutivo <> '' THEN
				SELECT nombre
				INTO
				cNombreEjecutivo
				FROM si_ejecut
				WHERE ejecutivo = cNoEjecutivo;
			END IF;

			
			IF cCodRet = '000' THEN
				LET cCodRet = '00000';
			END IF

			LET iCont = iCont +1;
						  
			RETURN  cCodRet, cTipoMovimiento, cMovimiento, cClaveSituacion, smallCveCausa, cDescSitEspecial, cCveSitOrigen, cSituacionOrigen,
				    cSucursal, cNoEjecutivo, cNombreEjecutivo, cUsuarioAlta, dFechaAlta, cUsuarioModifica, dFechaModifica  WITH resume;

		END FOREACH;
		
		IF iCont = 0 THEN
			LET cCodRet = '1001'; 
			RETURN  cCodRet, cTipoMovimiento, cMovimiento, cClaveSituacion, smallCveCausa, cDescSitEspecial, cCveSitOrigen, cSituacionOrigen,
				    cSucursal, cNoEjecutivo, cNombreEjecutivo, cUsuarioAlta, dFechaAlta, cUsuarioModifica, dFechaModifica;
	    END IF;
		
	ELIF cTIPOBUSQUEDA = '2' THEN
        FOREACH
            SELECT LIMIT 1 NVL(COUNT(num_credito),0) AS CANT INTO iexiste FROM bdicred:sd_maecred WHERE empresa = '001' AND  num_credito = cNUMCUENTA 
            UNION
            SELECT NVL(COUNT(num_credito),0) AS CANT FROM bdicred:sd_maecredcrd WHERE empresa = '001' AND  num_credito = cNUMCUENTA ORDER BY CANT DESC
        END FOREACH;
		IF iexiste  = 0 THEN 
		LET cCodRet = "00046";
		RETURN cCodRet, cTipoMovimiento, cMovimiento, cClaveSituacion, smallCveCausa, cDescSitEspecial, cCveSitOrigen, cSituacionOrigen,
			   cSucursal, cNoEjecutivo, cNombreEjecutivo, cUsuarioAlta, dFechaAlta, cUsuarioModifica, dFechaModifica;
		END IF;
	 
        FOREACH
			SELECT --+AVOID_FULL (bdisitesp:"informix".se_ctessitespcred)
			LIMIT 1 NVL(COUNT(*),0) AS CONT INTO iexiste 
			FROM bdisitesp:se_ctessitespcred
            WHERE numcred =  cNUMCUENTA
			AND empresa = '001'
            UNION
			SELECT NVL(COUNT(*),0) AS CONT
			FROM bdisitesp:se_ctessitespcred_his 
			WHERE numcred =  cNUMCUENTA ORDER BY CONT DESC
       END FOREACH;     

		IF iexiste  = 0 THEN 
		LET cCodRet = "00090";
		RETURN cCodRet, cTipoMovimiento, cMovimiento, cClaveSituacion, smallCveCausa, cDescSitEspecial, cCveSitOrigen, cSituacionOrigen,
			   cSucursal, cNoEjecutivo, cNombreEjecutivo, cUsuarioAlta, dFechaAlta, cUsuarioModifica, dFechaModifica;
		END IF;
	-- ****************************************************************************
	-- obtener registros
	-- ****************************************************************************

		SET ISOLATION TO DIRTY READ;

		FOREACH

			SELECT --+AVOID_FULL (bdisitesp:"informix".se_ctessitespcred)
			SKIP pNumRegistro FIRST pRecuperacion  
			a.tipomovto,
			CASE
			   WHEN a.tipomovto = 'M' THEN 
				'MARCA'
			   WHEN a.tipomovto = 'S' THEN 
				'SUSTITUCION'
			   WHEN a.tipomovto = 'E' THEN 
				'ELIMINACION'
			   ELSE 
				' '
			   END AS tipo_movimiento,
			   a.situacion,a.causa,b.descripcion,a.cvesitesporigen,csit.descripcion,a.sucursal,
			   a.nombreefectuo,a.usralta,a.fchalta,a.usrmodifica, a.fchmodifica
			INTO    
			   cTipoMovimiento, cMovimiento, cClaveSituacion, smallCveCausa, cDescSitEspecial, cCveSitOrigen, cSituacionOrigen,cSucursal,
			   cNombreEjecutivo, cUsuarioAlta, dFechaAlta, cUsuarioModifica, dFechaModifica
			FROM bdisitesp:se_ctessitespcred a
			LEFT JOIN  bdisitesp:se_catsitesp b ON a.situacion = b .situacion
			AND a.causa = b.causa
			LEFT JOIN bdisitesp:se_sitesporigen csit ON a.cvesitesporigen = csit.cvesitesporigen
			WHERE a.numcred =  cNUMCUENTA
		UNION
			SELECT --+AVOID_FULL(bdisitesp:"informix".se_sitesporigen)
			a.tipomovto,
			CASE
			   WHEN a.tipomovto = 'M' THEN 
				'MARCA'
			   WHEN a.tipomovto = 'S' THEN 
				'SUSTITUCION'
			   ELSE 
				'ELIMINACION'
			   END AS tipo_movimiento,
			   a.situacion,a.causa,b.descripcion,cast(a.cvesitesporigen as char(2)),csit.descripcion,a.sucursal,
			   a.nombreefectuo,a.usralta,a.fchalta,a.usrmodifica, a.fchmodifica 
			FROM bdisitesp:se_ctessitespcred_his a
			LEFT JOIN  bdisitesp:se_catsitesp b ON a.situacion = b .situacion
			AND a.causa = b.causa
			LEFT JOIN bdisitesp:se_sitesporigen csit ON a.cvesitesporigen = csit.cvesitesporigen
			WHERE a.numcred = cNUMCUENTA
			
			
			IF cCodRet = '000' THEN
				LET cCodRet = '00000';
			END IF

			LET iCont = iCont +1;
						  
			RETURN  cCodRet, cTipoMovimiento, cMovimiento, cClaveSituacion, smallCveCausa, cDescSitEspecial, cCveSitOrigen, cSituacionOrigen,
				    cSucursal, cNoEjecutivo, cNombreEjecutivo, cUsuarioAlta, dFechaAlta, cUsuarioModifica, dFechaModifica  WITH resume;

		END FOREACH;
		IF iCont = 0 THEN
			LET cCodRet = '1001'; 
			RETURN  cCodRet, cTipoMovimiento, cMovimiento, cClaveSituacion, smallCveCausa, cDescSitEspecial, cCveSitOrigen, cSituacionOrigen,
			        cSucursal, cNoEjecutivo, cNombreEjecutivo, cUsuarioAlta, dFechaAlta, cUsuarioModifica, dFechaModifica;
		END IF;
	END IF	
	


END    
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la información de las Situaciones Especiales que presente un Cliente. ",
"El SP obtendrá la información de la Base de Datos central de Informix, enviando como parámetro el  No. de Cliente.",
"FECHA : 28-02-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cons_conc_efect_aud( pTipo     INTEGER,
													pFechaIni CHAR(10),
													pFechaFin CHAR(10),
													pEmpresa  CHAR(3),
													pSucursal CHAR(4),
													pCodigo   CHAR(4),
													pUsuario  CHAR(8),
													pSkip     INTEGER,
													pLimite   INTEGER)
RETURNING CHAR(5)   AS  CodRet,
		  CHAR(10)	AS	Fecha,
		  CHAR(12)  AS 	Hora,
		  CHAR(16)  AS  Folio,
		  CHAR(8)	AS	Usuario,
		  CHAR(4)   AS	Sucursal,
		  CHAR(17)  AS  Importe,
		  CHAR(4)	AS	Transaccion,
		  CHAR(17)  AS	Folio_Papeleta,
		  INTEGER   AS  TotRows;
			  			  
DEFINE cCodRet				CHAR(5);
DEFINE cFecha               CHAR(10);
DEFINE cHora                CHAR(12);
DEFINE cFolio               CHAR(16);
DEFINE cUsuario             CHAR(8);
DEFINE cSucursal            CHAR(4);
DEFINE cImporte             CHAR(17);
DEFINE cTransaccion         CHAR(4);
DEFINE cFolio_Pap           CHAR(10);
DEFINE dFechaIni			DATE;
DEFINE dFechaFin			DATE;
DEFINE dFechaHoy			DATE;
DEFINE dFechaParaMovhisOld 	DATE;
DEFINE dFechaParaMovhisOld2 DATE;
DEFINE cFechaParaMovhisOld 	CHAR(10);
DEFINE cFechaParaMovhisOld2 CHAR(10);
DEFINE iRango 		     	INTEGER;
DEFINE cFechaIni 			CHAR(10);
DEFINE cFechaFin 			CHAR(10);
DEFINE cDia					CHAR(2);
DEFINE cMes					CHAR(2);
DEFINE cAnio				CHAR(4);
DEFINE iSqlErr              INTEGER;
DEFINE iLinea               INTEGER;
DEFINE iTotalRows			INTEGER;
DEFINE dFecha               DATE;
DEFINE dFechaActual			DATE;


LET cCodRet              = '';
LET cFecha               = '';
LET cHora                = '';
LET cFolio               = '';
LET cUsuario             = '';
LET cSucursal            = '';
LET cImporte             = '';
LET cTransaccion         = '';
LET cFolio_Pap           = '';
LET dFechaIni 			 = '';
LET dFechaFin 			 = '';
LET dFechaHoy 			 = '';
LET dFechaParaMovhisOld  = '';
LET dFechaParaMovhisOld2 = '';
LET cFechaParaMovhisOld  = '';
LET cFechaParaMovhisOld2 = '';
LET iRango  			 = 0;
LET cFechaIni 			 = '';
LET cFechaFin 			 = '';
LET cDia 				 = '';
LET cMes 				 = '';
LET cAnio 				 = '';
LET iLinea               = 0;
LET iTotalRows 			 = 0;
LET dFecha               = DATE(1);
LET dFechaActual         = DATE(1);
 
/*----------------*----------------*----------------*----------------*----------------*------------*
/ Se crea procedimiento almacenado para extraer la información requerida para la generación        /
/ del reporte de "Concentracion de Efectivo" desde la tabla si_rptcaja_aud                         /
/ Elaborado por: Adilene Lara                                                                      /
/ Fecha: 25/11/2014                                                                                /
/ Solicitado por: Norberto Corona                                                                  /
*----------------*----------------*----------------*----------------*----------------*------------*/

--SET DEBUG FILE TO '/informix/sp_cons_conc_efect_aud.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			LET cFecha        = '';
			LET cHora         = '';
			LET cFolio        = '';
			LET cUsuario      = '';
			LET cSucursal     = '';
			LET cImporte      = '';
			LET cTransaccion  = '';
			LET cFolio_Pap    = '';
			LET dFecha        = '';
			LET iTotalRows    = 0;
				
			RETURN  cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cFolio_Pap,iTotalRows;
			
		END IF;
	END EXCEPTION;
		
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
			
				LET cFechaIni = pFechaIni;
				LET cDia  = SUBSTRING(cFechaIni FROM 1 FOR 2);
				LET cMes  = SUBSTRING(SUBSTRING(cFechaIni FROM 4 FOR 4) FROM 1 FOR 2);
				LET cAnio = SUBSTRING(cFechaIni FROM 7 FOR 10);
				LET dFechaIni = DATE(TRIM(cMes||'/'||cDia||'/'||cAnio));

				LET cFechaFin = pFechaFin;
				LET cDia  = SUBSTRING(cFechaFin FROM 1 FOR 2);
				LET cMes  = SUBSTRING(SUBSTRING(cFechaFin FROM 4 FOR 4) FROM 1 FOR 2);
				LET cAnio = SUBSTRING(cFechaFin FROM 7 FOR 10);
				LET dFechaFin = DATE(TRIM(cMes||'/'||cDia||'/'||cAnio));
				
				SELECT DISTINCT(COUNT(folio))
				INTO iTotalRows
				FROM bdinteg:"informix".si_rptcaja_aud
				WHERE empresa = pEmpresa
				AND sucursal = pSucursal
				AND cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE empresa = pEmpresa  AND codigo = pCodigo)
				AND  fecha BETWEEN 	dFechaIni AND dFechaFin
				AND reversado = '0';
				
			FOREACH
				SELECT SKIP pSkip LIMIT  pLimite  DISTINCT fecha,hora,folio,usuario,sucursal,monto,cod_transacc,folio_oper
				INTO cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cFolio_Pap
				FROM bdinteg:"informix".si_rptcaja_aud
				WHERE empresa = pEmpresa
				AND sucursal = pSucursal
				AND cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE empresa = pEmpresa  AND codigo = pCodigo)
				AND fecha BETWEEN 	dFechaIni AND dFechaFin
				AND reversado = '0'
				ORDER BY fecha,hora ASC
				
				LET cCodRet = '00000';
				
				RETURN  cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cFolio_Pap,iTotalRows WITH RESUME;         
			END FOREACH;
			
			LET pSkip = pSkip + pLimite ;

END

END PROCEDURE;