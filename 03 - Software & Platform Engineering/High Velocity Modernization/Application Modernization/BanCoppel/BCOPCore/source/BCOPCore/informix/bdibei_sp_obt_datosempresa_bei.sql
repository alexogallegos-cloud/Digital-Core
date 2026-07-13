CREATE PROCEDURE "informix".sp_obt_datosempresa_bei(
						pRfc char(15),
						pNumCte char(9),
						pCuenta char(20),
						pIdentAdmin char(30))
	RETURNING char(5), char(13), char(41), char(2),INTEGER,DATETIME YEAR TO SECOND,char(10);


--****************************************************************************************************
-- DESCRIPCION:  Obtiene los datos del cliente
-- AUTOR : Irving Guzman Salas
-- FECHA : 24/05/2013
-- BD: bdibei
-- SOLICITO :
-- MODIFICACION: Se actualiza query para que consulta las personas es_fisica=N en lugar de tipo de persona 02
-- MODIFICA:	BanCoppel - Internet - Berenice Noriega Guevara
-- SOLICITA: Alejandro Vazquez Fernandez
-- FECHA MOD. PROD: 10 Julio 2015
--***************************************************************************************************
-- MODIFICACIÓN:  Para identificar a los usuarios que tuvieron problemas en el paso definición de usuario
--                generandole un id de usuario pero no pass, ni creacion en AM.
-- AUTOR : Berenice Noriega Guevara - BanCoppel Analista M3-Internet
-- FECHA : 29-Septiembre-2015
-- BD: bdibei
-- SOLICITO : Alejandro Vazquez Fernandez - BanCoppel Coordinador M3-Internet
--***************************************************************************************************


	DEFINE sql_err integer;
	DEFINE cCod_ret char(5);
	DEFINE cRFC char(13);
	DEFINE cNombre char(41);
	DEFINE cIdStatus char(2);
	DEFINE cIdUsuario INTEGER;
	DEFINE sIdStatusToken INTEGER;
	DEFINE cNsToken char(10);
	DEFINE iUsuario VARCHAR(50);	DEFINE vUsuario VARCHAR(50);
	DEFINE cFecBloqueoTemp DATETIME YEAR TO SECOND;
	LET cCod_ret = '00000';
	LET cRFC = '';
	LET cNombre = '';
	LET cIdStatus = '';
	LET cIdUsuario=-1;
	LET sIdStatusToken=-1;
	LET cNsToken ='';
	LET  cFecBloqueoTemp='';
	LET iUsuario='';	LET vUsuario='';	
	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET cCod_ret = sql_err;
				RETURN cCod_ret, cRFC, cNombre, cIdStatus,cIdUsuario,NVL(cFecBloqueoTemp,''),sIdStatusToken;
			END IF
		END EXCEPTION;

		IF NVL(TRIM(pRfc), '') = '' AND NVL(TRIM(pNumCte), '') = '' AND NVL(TRIM(pCuenta), '') = ''  AND NVL(TRIM(pIdentAdmin), '') = '' THEN
			LET cCod_ret = '00001'; --datos incompletos
		ELSE

			SET LOCK MODE TO WAIT ;
			SET ISOLATION DIRTY READ ;

			SELECT rfc INTO cRFC FROM bdinteg:"informix".si_cliente as a, bdinteg:"informix".si_tipper as b
			WHERE a.rfc = pRfc AND a.numcte = pNumCte AND a.tipo_cliente = '1' AND a.tpo_persona = b.tpo_persona and b.es_fisica='N';

			IF NVL(cRFC, '') <> '' THEN
				SELECT a.id_status ,a.id_usuario,a.ns_token
				INTO cIdStatus ,cIdUsuario,cNsToken
				FROM bdibei:"informix".bei_servicio a, bdicheq:"informix".sc_maechq c
				WHERE a.num_cliente = pNumCte
				AND a.num_cliente = c.num_cte
				AND a.identificacion_admin = pIdentAdmin
				AND c.cuenta = pCuenta;

				IF NVL(cIdStatus, '') = '' THEN
					LET cCod_ret = '00003'; --cliente no existe
					
				ElSE
					
					SET LOCK MODE TO WAIT ;
					SET ISOLATION DIRTY READ ;

					SELECT nombre_corto
					INTO cNombre
					FROM bdinteg:"informix".si_ctepm
					WHERE numcte = pNumCte;

					IF NVL(TRIM(cNombre), '') = '' THEN
						LET cCod_ret = '00004'; --fecha no existe
					END IF


					SELECT a.f_bloqueo_temp
					INTO cFecBloqueoTemp
					FROM "informix".bei_usuario a
					WHERE a.num_cliente = pNumCte
					AND a.id_usuario = cIdUsuario ;

					IF cFecBloqueoTemp IS NULL THEN
							LET  cFecBloqueoTemp='';
					END IF

					SELECT  btk.id_status_token
           			INTO   sIdStatusToken
            		FROM bdibei:"informix".bei_token  btk
            		WHERE btk.num_cliente  = pNumCte
            		AND btk.id_usuario = cIdUsuario
            		AND btk.ns_token=cNsToken;


					IF NVL(sIdStatusToken, -1) = -1 THEN
							LET  sIdStatusToken=-1;
					END IF
					
					------------------------------------------------------------------------------------------------------------
					IF NVL(cIdStatus, '') = '10' THEN
						
						LET iUsuario='RESETUSUARIO'||cIdUsuario; 
						
						SELECT usuario_bei
						INTO vUsuario
						FROM bdibei:"informix".bei_usuario
						WHERE id_usuario = cIdUsuario
						AND num_cliente = pNumCte;
					
						IF NVL(vUsuario, iUsuario) <> iUsuario THEN --Si nombre usuario bei_usuario no es "RESETUSUARIO + idusuario"
							IF  (SELECT COUNT(id_usuario) FROM bdibei:"informix".bei_datos_usuario WHERE id_usuario=cIdUsuario )>= 1 								THEN
				
								--Borrar en bei_usuario, bei_datos_usuario y modificar bei_servicio--
									delete bdibei:"informix".bei_datos_usuario 
									where id_usuario=cIdUsuario;
									
									delete bdibei:"informix".bei_usuario 
									where num_cliente=pNumCte 
									and id_usuario=cIdUsuario;
								
									UPDATE bdibei:"informix".bei_servicio 
									SET id_usuario=' ' 
									WHERE identificacion_admin = pIdentAdmin 
									AND num_cliente=pNumCte;
								
								--SIN ID DE USUARIO--
								LET cIdUsuario='';
								
							END IF --Fin de si existe un registro en bei_datos_usuario.
						END IF --Fin del usuario diferente a resetusuario+id
					END IF --Fin del estatus 10
					
					----------------------------------------------------------------------------------------------------------

				END IF
			ELSE
				LET cCod_ret = '00002'; --rfc no existe
			END IF
		END IF
		RETURN cCod_ret, cRFC, cNombre, cIdStatus,cIdUsuario,NVL(cFecBloqueoTemp,''),sIdStatusToken;

	END
END PROCEDURE;