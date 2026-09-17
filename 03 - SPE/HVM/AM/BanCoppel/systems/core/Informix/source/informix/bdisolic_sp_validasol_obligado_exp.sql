CREATE PROCEDURE "informix".sp_validasol_obligado_exp(pNumSolicitudObli VARCHAR(20),pNumSolicitudTit VARCHAR(20))

RETURNING CHAR(5) AS CodRet,
		  VARCHAR(100) AS Mensaje,
		  VARCHAR(12)  AS NumSolic;

DEFINE cCodRet   CHAR(5);
DEFINE cNumSolic VARCHAR(20);
DEFINE cNumcte 	 VARCHAR(20);
DEFINE cMensaje  VARCHAR (100);
DEFINE iSqlErr   INTEGER;
DEFINE ccountsolic INTEGER;
DEFINE cNumcteTit CHAR(20);
DEFINE cEmpresa CHAR(3);
DEFINE cNumSolobligado  CHAR(20);

LET cCodRet = '00000';
LET cNumSolic = '';
LET cNumcte = '';
LET cMensaje = '';
LET iSqlErr = 0;
LET ccountsolic = 0;
LET cNumcteTit = '';
LET cEmpresa ='001';
LET cNumSolobligado = '';

	BEGIN
		-- // MANEJO DE EXCEPCIONES
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,'Ocurrio Una Excepcion','';
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO "/tmp/sp_validasol_obligado.out";
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		-- // VALIDA PARAMETROS DE ENTRADA
		IF  (pNumSolicitudTit IS NULL OR pNumSolicitudTit = '') THEN
			LET cCodRet = '00001';
			LET cNumSolic = pNumSolicitudObli;
			LET cMensaje = 'Faltan Parametros de entrada';					
		ELIF substr(pNumSolicitudTit,1,4) = substr(pNumSolicitudObli,1,4) THEN
				LET cCodRet = '01305';
				LET cNumSolic = pNumSolicitudObli;
				LET cMensaje = 'La Solicitud ingresada no puede ser del mismo producto';					
		ELIF substr(pNumSolicitudObli,1,4) NOT IN ('9200','9400') THEN
				LET cCodRet = '01305';
				LET cNumSolic = pNumSolicitudObli;
				LET cMensaje = 'El Numero De Solicitud de obligado no es valido';		
		ELIF substr(pNumSolicitudTit,1,4) NOT IN ('9100','9300') THEN
				LET cCodRet = '01306';
				LET cNumSolic = pNumSolicitudTit;
				LET cMensaje = 'El Numero De Solicitud de Acreditado no es valido';			
		ELSE
			-- // OBTIENE INFORMACION
			SELECT num_solicitud,numcte
			INTO cNumSolic,cNumcte
			FROM "informix".ss_solicitudes
			WHERE empresa = cEmpresa AND num_solicitud = pNumSolicitudObli;


			SELECT numcte
			INTO cNumcteTit
			FROM "informix".ss_solicitudes
			WHERE empresa = cEmpresa AND num_solicitud = pNumSolicitudTit;

			IF (cNumSolic IS NULL OR cNumSolic = '') AND  (pNumSolicitudObli  <> '') THEN
				LET cCodRet = '01302';
				LET cNumSolic = pNumSolicitudObli;
				LET cMensaje = 'El Numero De Solicitud No Existe';
			ELIF(cNumSolic IS NULL OR cNumSolic = '') AND  (NVL(pNumSolicitudObli,'')  = '') THEN
				IF  substr(cNumSolic,1,4) IN ('9100','9300') OR substr(pNumSolicitudTit ,1,4) IN('9100','9300')THEN
					SELECT count(num_solicitud)
					INTO ccountsolic
					FROM bdinteg:"informix".si_refclientes
					WHERE  numcte = cNumcteTit AND  num_solicitud=  pNumSolicitudTit
					AND numcte_ref <> ''
					AND TRIM(nombre1)||" " || TRIM(nombre2) || " " || TRIM(apell_paterno) || " " || TRIM(apell_materno) IN (select nombre_ref from  bdisolic:"informix".ss_refpersonales
											WHERE num_solicitud = pNumSolicitudTit
											AND substr(numcte_ref,1,2)  = 'R3'
											AND tipo_relacion = '02'
											AND numcte = cNumcteTit);
						IF ccountsolic >=1 Then
							FOREACH
								SELECT numcte_ref INTO cNumSolobligado
								FROM bdinteg:"informix".si_refclientes
								WHERE  numcte = cNumcteTit AND  num_solicitud=  pNumSolicitudTit
								AND numcte_ref <> ''
								AND TRIM(nombre1)||" " || TRIM(nombre2) || " " || TRIM(apell_paterno) || " " || TRIM(apell_materno) IN (select nombre_ref from  bdisolic:"informix".ss_refpersonales
														WHERE num_solicitud = pNumSolicitudTit
														AND substr(numcte_ref,1,2)  = 'R3'
														AND tipo_relacion = '02'
														AND numcte = cNumcteTit)

									SELECT num_solicitud
									INTO cNumSolic
									FROM "informix".ss_solicitudes
									WHERE empresa = cEmpresa AND num_solicitud = cNumSolobligado
									AND status_solicitud = 'AT';

									IF (cNumSolic IS NULL OR cNumSolic = '') THEN
										LET cCodRet = '01300';
										LET cNumSolic = pNumSolicitudObli;
										LET cMensaje = 'La Solicitud Indicada No Se Encuentra Autorizada';
									ELSE
										LET cCodRet = '00000';
										LET cMensaje = 'Proceso Exitoso';
										EXIT FOREACH;
									END IF;
							END FOREACH;
						ELSE
							LET cCodRet = '01308';
							LET cNumSolic = pNumSolicitudObli;
							LET cMensaje = 'La solicitud no cuenta con un obligado solidario capturado';
						END IF;
				END IF;
			ELSE
				/*select num_solicitud,numcte INTO cNumSolic,cNumcte
				from bdinteg:"informix".si_refclientes
				WHERE numcte_ref = pNumSolicitud AND numcte_banco = cNumcte;*/

			
				SELECT COUNT(num_solicitud) INTO ccountsolic from bdinteg:si_refclientes a 
				WHERE numcte_ref = pNumSolicitudObli AND num_solicitud IN (select num_solicitud
																		FROM "informix".ss_refpersonales
																		WHERE numcte = a.numcte AND num_solicitud = a.num_solicitud AND numcte_ref LIKE 'R3%');				

				IF (ccountsolic IS NULL OR ccountsolic = 0 ) THEN
					LET cCodRet = '01295';
					LET cNumSolic = pNumSolicitudObli;
					LET cMensaje = 'La solicitud capturada no corresponde a un cliente obligado solidario';

				ELSE
					FOREACH
						SELECT numcte_ref INTO cNumSolobligado
						FROM bdinteg:"informix".si_refclientes a
						WHERE  a.numcte = cNumcteTit AND  a.num_solicitud=  pNumSolicitudTit
						AND a.numcte_ref <> ''
						AND TRIM(a.nombre1)||" " || TRIM(a.nombre2) || " " || TRIM(a.apell_paterno) || " " || TRIM(a.apell_materno) IN (select nombre_ref from  bdisolic:"informix".ss_refpersonales
												WHERE num_solicitud = pNumSolicitudTit
												AND numcte_ref LIKE 'R3%'
												AND tipo_relacion = '02'
												AND parentesco = a.parentesco											
												AND numcte = cNumcteTit)
									
							SELECT num_solicitud
							INTO cNumSolic
							FROM "informix".ss_solicitudes
							WHERE empresa = cEmpresa AND num_solicitud = pNumSolicitudObli
							AND status_solicitud = 'AT';
							
							IF pNumSolicitudObli <> cNumSolobligado THEN
								LET cCodRet = '01298';
								LET cNumSolic = pNumSolicitudObli;
								LET cMensaje = 'El nÃºmero de la solicitud no corresponde al Prestamo Titular solicitado';	
							ELIF pNumSolicitudObli = cNumSolobligado THEN									
								IF (cNumSolic IS NULL OR cNumSolic = '') THEN									
									LET cCodRet = '01300';
									LET cMensaje = 'La Solicitud Indicada No Se Encuentra Autorizada';
								ELSE
									LET cCodRet = '00000';
									LET cMensaje = 'Proceso Exitoso';
								END IF;
								LET cNumSolic = pNumSolicitudObli;
								EXIT FOREACH;
							END IF;
					END FOREACH;
				END IF;
			END IF;
		END IF;
		RETURN cCodRet,TRIM(cMensaje), cNumSolic;
	END
END PROCEDURE
