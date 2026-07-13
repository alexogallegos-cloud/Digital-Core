CREATE PROCEDURE "informix".sp_ctes_tf(	pcAgent_trans_type_code CHAR(10),
                                        pcAgent_cd 				CHAR(6),
                                        pcUsuario 				CHAR(8),
                                        pcPassword 				CHAR(8),
                                        pcIp_origen 			CHAR(15),
										pcSession_id 			CHAR(30),
										pcServiceName 		    CHAR(128),--serviceName
										pcCountryCode 			CHAR(3),--countryCode
										pcIdCustomerNumber		CHAR (9),--IdCustomerNumber
										pcAccountNumber 		CHAR(11),--accountNumber
										pcBankId 				CHAR(3),--bankId
										pcNombre 				CHAR(64),--name
										pcNombreDos 			CHAR(64),--secondName
										pcApellidoPaterno 		CHAR(128),--firstLastName
										pcApellidoMaterno 		CHAR(128),--secondLastName
										pcCalle 				CHAR(128),--addressStreet
										pcNumInterno 			CHAR(128),--addressBuildingInternal
										pcNumExterno			CHAR(128),--addressBuildingExternal
										pcNumDepartamento 		CHAR(128),--addressAppartment
										pcColonia 				CHAR(128),--addressNeighbourhood
										pcMunicipio 			CHAR(128),--addressLocation
										pcEstado 				CHAR(128),--addressState
										pcCodigoPostal 			CHAR(12),--postalCode
										pcFechaNac 				CHAR(15), --dateOfBirth (yyyy-MM-dd)
										pcTelefono 				CHAR(13),--msisdn
										pcEmail 				CHAR(128),--emailed
										pcEstatusRegistro 		CHAR(1),--esRegistro
										pcRfc 					CHAR(13),--rfc
										pcMetodoNotificacion 	CHAR(15),--notificationMethod
										pcAccessMethod 		    CHAR(3),--accessMethod
										pcSystemDate 			CHAR(15), --systemDate (long value, epoch time))
										pcNumTarjeta 			CHAR(16),--cardNumber
										pcIdentificacionPersona CHAR(20),--customerNumber
										pcIdentificacion 		CHAR(1),--idType
										pcNumIdentificacion 	CHAR(15),--idNumber
										pcGenero 				CHAR(1),--gender
										pcEntidadNacimiento 	CHAR(50),--birthState
										pcCurp 					CHAR(50),--curp
										pcEstatusRenapo 		CHAR(3),--renapoStatus
										pcFecValRenapo			CHAR(15),--renapoValidationDate
										pcComentarios			CHAR(50),--Remarks
										pcNumConfronta			CHAR(1),--renapoValidationCounter
										pcCuentaClabe           CHAR(18),--CLABE
										pcMSISDNrecepcion		CHAR(12),
										pcTelefonica         	CHAR(4),
										pcTipoAsociacion      	CHAR(1))

RETURNING	CHAR(6)   AS returnCode,
			CHAR(256) AS errorDescription,
			CHAR (12) AS customerNumber;


---DECLARACION DE VARIABLES
DEFINE iSqlErr      		INTEGER;
DEFINE cReturnCode     	 	CHAR(6);
DEFINE cCotRetSP    		CHAR(6);
DEFINE cErrorDescription   	CHAR(100);
DEFINE iSecuencia   		INTEGER;
DEFINE cNumTranfer 			CHAR(12);
DEFINE ctelef				CHAR(12);

DEFINE cAgent_cd		CHAR(3);
DEFINE cUsuario			CHAR(8);
DEFINE cPassword		CHAR(8);
DEFINE cIp_origen		CHAR(15);
DEFINE cId_sesion_act	CHAR(30);
DEFINE cNombre_preceso	CHAR(17);
DEFINE dtFecha_dia		DATE	;

DEFINE dFechaNueva 	 	CHAR(10);
DEFINE cDia         	CHAR(2);
DEFINE cMes         	CHAR(2);
DEFINE cAnio        	CHAR(4);

DEFINE dFechaNueva2 	DATE;
DEFINE cDia2         	CHAR(2);
DEFINE cMes2         	CHAR(2);
DEFINE cAnio2        	CHAR(4);

DEFINE dFechaNueva3		DATE;
DEFINE cDia3         	CHAR(2);
DEFINE cMes3         	CHAR(2);
DEFINE cAnio3        	CHAR(4);
DEFINE cNombre_completo	CHAR(50);

DEFINE cNvoRfc          CHAR(13);

---INICIALIZACION DE VARIABLES
LET iSqlErr       = 0;
LET cReturnCode   = '0';
LET cCotRetSP     = '0';
LET cErrorDescription = 'Success';
LET iSecuencia    = 0;
LET cNumTranfer   = 0;
LET ctelef		  = 0;

LET cAgent_cd ='';
LET cUsuario ='';
LET cPassword ='';
LET cIp_origeN ='';
LET cId_sesion_act ='';
LET cNombre_preceso = 'sp_spei';
LET dtFecha_dia   = CURRENT::DATE;
LET dFechaNueva   = DATE(1);
LET dFechaNueva2   = DATE(1);
LET dFechaNueva3   = DATE(1);
LET pcSystemDate=replace(pcSystemDate,'/','');

--SET DEBUG FILE TO '/informix/andrescrespo/cte_tf.out';
--TRACE ON;

BEGIN
    ON EXCEPTION
	SET iSqlErr
	IF 	iSqlErr <> 0 THEN
		LET cReturnCode = iSqlErr;
		LET cErrorDescription = 'Error desconocido';
		RETURN trim(cReturnCode),trim(cErrorDescription),trim(cNumTranfer);
	END IF
END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	IF NVL(pcServiceName,'?')= '?' OR NVL(pcCountryCode,'?')= '?' OR NVL(pcAgent_cd,'?')= '?' OR NVL(pcUsuario,'?')= '?'
			OR NVL(pcBankId,'?')= '?' OR NVL(pcAccessMethod,'?')= '?'  OR NVL(pcAgent_trans_type_code,'?')= '?' OR NVL(pcPassword,'?')= '?'
			/*OR length(pcSystemDate)< 14 */OR NVL(pcIp_origen,'?')= '?' OR NVL(pcSession_id,'?')= '?'
			OR NVL(pcIdCustomerNumber,'?')= '?' OR NVL(pcAccountNumber,'?')= '?' OR NVL(pcNombre,'?')= '?' OR NVL(pcNombreDos,'?')= '?'
			OR NVL(pcApellidoPaterno,'?')= '?' OR NVL(pcApellidoMaterno,'?')= '?' OR NVL(pcCalle,'?')= '?'
			OR NVL(pcNumInterno,'?')= '?' OR NVL(pcColonia,'?')= '?' OR NVL(pcMunicipio,'?')= '?' OR NVL(pcEstado,'?')= '?'
			OR NVL(pcCodigoPostal,'?')= '?' OR NVL(pcFechaNac,'?')= '?' OR NVL(pcTelefono,'?')= '?'
			OR NVL(pcEmail,'?')= '?' OR NVL(pcEstatusRegistro,'?')= '?' OR NVL(pcRfc,'?')= '?' OR NVL(pcMetodoNotificacion,'?')= '?'
			OR NVL(pcIdentificacionPersona,'?')= '?' OR NVL(pcIdentificacion,'?')= '?' OR NVL(pcNumIdentificacion,'?')= '?'
			OR NVL(pcGenero,'?')= '?' OR NVL(pcEntidadNacimiento,'?')= '?' OR NVL(pcCurp,'?')= '?' OR NVL(pcCuentaClabe,'?')= '?'
			THEN
			LET cReturnCode ='9996';
			LET cErrorDescription = "Error de parametros de entrada";
		ELSE
			IF EXISTS (SELECT transaccion FROM bdisac:"informix".sac_ws_transacc_ctes
			   WHERE agent_cd = pcAgent_cd AND transaccion = pcAgent_trans_type_code AND usuario = trim(pcusuario) AND activa = 'S' ) THEN

				--Se obtienen lo0s valores de lo0s campo0s, para la validacio0n de lo0s parametro0s de entrada
				SELECT agent_cd,usuario,password,ip_origen,id_sesion_act
				INTO cAgent_cd,cUsuario,cPassword,cIp_origen,cId_sesion_act
				FROM bdisac:"informix".sac_ws_clientes WHERE agent_cd = pcAgent_cd AND usuario = trim(pcusuario) and  fecha_insert = dtFecha_dia;

				IF cAgent_cd = pcAgent_cd THEN
					IF cUsuario = pcUsuario   THEN
						IF cPassword = pcPassword THEN
							IF cIp_origen = pcIp_origen THEN
								IF cId_sesion_act::CHAR(30) = pcSession_id THEN
									IF pcSession_id = (SELECT id_sesion_act::CHAR(30) FROM bdisac:"informix".sac_ws_clientes WHERE agent_cd = pcAgent_cd AND usuario = trim(pcusuario) and fecha_insert = dtFecha_dia) THEN
										IF (pcMSISDNrecepcion='' or length(pcMSISDNrecepcion)=12) THEN
											IF (pcTelefonica	='' or pcTelefonica='0002' or pcTelefonica='0003' or pcTelefonica='0004' or pcTelefonica='0005' or pcTelefonica='0032') THEN
												IF (pcTipoAsociacion='' or pcTipoAsociacion='1' or pcTipoAsociacion='2' or pcTipoAsociacion='3' or pcTipoAsociacion='4') THEN
													IF length(pcSystemDate)>1 THEN
														LET cDia=SUBSTR(pcSystemDate,1,2);
														LET cMes=SUBSTR(pcSystemDate,3,2);
														LET cAnio=SUBSTR(pcSystemDate,5,4);
														LET dFechaNueva = mdy(cMes,cDia,cAnio);
														IF  NVL(dFechaNueva,'')!='' and dFechaNueva::DATE=today THEN
														
															LET pcFechaNac = REPLACE(pcFechaNac ,'-','');
															LET pcFecValRenapo = REPLACE(pcFecValRenapo ,'-','');	
													
															LET cDia2=SUBSTR(pcFechaNac,7,2);
															LET cMes2=SUBSTR(pcFechaNac,5,2);
															LET cAnio2=SUBSTR(pcFechaNac,1,4);
															LET dFechaNueva2 = mdy(cMes2,cDia2,cAnio2);
			
															LET cDia3=SUBSTR(pcFecValRenapo,7,2);
															LET cMes3=SUBSTR(pcFecValRenapo,5,2);
															LET cAnio3=SUBSTR(pcFecValRenapo,1,4);
															LET dFechaNueva3 = mdy(cMes2,cDia2,cAnio2);
		
		
															LET ctelef= TRIM(substr(pcTelefono,3,10));
															
															LET cNombre_completo = TRIM(pcNombre) || ' ' || TRIM(pcNombreDos);
											
															EXECUTE PROCEDURE bdicnweb:"informix".sp_calcularrfc(pcApellidoPaterno,pcApellidoMaterno,cNombre_completo,dFechaNueva2)
															INTO cCotRetSP,cNvoRfc;
															IF (cCotRetSP == '00000') THEN
																LET pcRfc = cNvoRfc;
															END IF;
		
															INSERT INTO "informix".tf_cte_online(nom_servicio,codigo_ciudad,cliente_mps,cuenta_tf,id_banco,nombre1,nombre2,apell_paterno,apell_materno,
															calle,num_interno,num_exterior,num_depto,colonia,municipio,estado,cod_postal,
															fecha_nac,telefono,correo, esregistro,rfc,met_notificacion,metodo_acceso,fec_sistema,num_tarjeta,id_persona,identificacion,num_identificacion,
															genero,entidad_nac,curp, status_cta,fec_valrenapo,comentarios,num_confronta,cta_clabe,
															cte_conciliado,cte_fusionado,cod_error,desc_error,msisdnrecepcion,telefonica,tipoasociacion)
		
		
															VALUES (pcServiceName,pcCountryCode,pcIdCustomerNumber,pcAccountNumber,pcBankId,pcNombre,pcNombreDos,pcApellidoPaterno,pcApellidoMaterno,
															pcCalle,pcNumInterno,pcNumExterno,pcNumDepartamento,pcColonia,pcMunicipio,pcEstado,pcCodigoPostal,
															dFechaNueva2,ctelef,pcEmail,pcEstatusRegistro,pcRfc,pcMetodoNotificacion,pcAccessMethod,dtFecha_dia,pcNumTarjeta,pcIdentificacionPersona,pcIdentificacion,pcNumIdentificacion,
															pcGenero,pcEntidadNacimiento,pcCurp,pcEstatusRenapo,dFechaNueva3,pcComentarios,pcNumConfronta,pcCuentaClabe,
															'0',' ',' ',' ',pcMSISDNrecepcion,pcTelefonica,pcTipoAsociacion);
		
															IF pcIdentificacion=5 THEN
																LET cReturnCode = '956';
																LET cErrorDescription= 'IdentificaciÃ³n del cliente no vÃ¡lida';
		
															ELSE
		
																	IF pcEstatusRegistro = '0' THEN --Cliente Modificaciion
																		EXECUTE PROCEDURE "informix".sp_ctes_modif
																								(pcAccountNumber,
																								pcCuentaClabe,
																								ctelef,
																								--pcIdentificacionPersona,
																								pcEstatusRegistro,
																								pcServiceName,
																								pcBankId,
																								pcAccessMethod,
																								pcApellidoPaterno,
																								pcApellidoMaterno,
																								pcNombre,
																								dFechaNueva2,
																								pcCalle,
																								pcNumExterno,
																								pcIdentificacion,
																								pcNumIdentificacion,
																								dtFecha_dia)
		
		
																		INTO cCotRetSP,cErrorDescription,cNumTranfer;
																		LET cReturnCode=cCotRetSP;
		
		
		
																	ELIF pcEstatusRegistro = '1' OR pcEstatusRegistro = '2' THEN --Cliente Alta
																	/*	EXECUTE PROCEDURE "informix".sp_ctes_alta
																								(pcAccountNumber,
																								pcCuentaClabe,
																								ctelef,
																								pcEstatusRegistro,
																								pcServiceName,
																								pcBankId,
																								pcAccessMethod,
																								pcApellidoPaterno,
																								pcApellidoMaterno,
																								pcNombre,
																								dFechaNueva2,
																								pcCalle,
																								pcNumExterno,
																								pcIdentificacion,
																								pcNumIdentificacion,
																								dtFecha_dia)
																		INTO cCotRetSP,cErrorDescription,cNumTranfer;
																		LET cReturnCode=cCotRetSP;*/
																		
																		LET cReturnCode = '8886';
																		LET cErrorDescription = "Por el momento el servicio no estÃ¡ disponible.";
		
		
																	ELSE
		
																		LET cReturnCode = '300';
																		SELECT descripcion
																		INTO  cErrorDescription
																		FROM  "informix".tf_codret
																		WHERE cod_error = cReturnCode;
																	END IF;
																	
																		LET cReturnCode = '8886';
																		LET cErrorDescription = "Por el momento el servicio no estÃ¡ disponible.";
																	
															END IF;
		
														ELSE
															LET cReturnCode = '9996';
															LET cErrorDescription = "Consulta no exitosa. Fecha invÃ¡lida.";
														END IF;
		
													ELSE
														LET cReturnCode = '9996';
														LET cErrorDescription = "Consulta no exitosa. Fecha invÃ¡lida.";
													END IF;
												ELSE
													LET cReturnCode = '9996';
													LET cErrorDescription = "Consulta no exitosa. TipoAsociacion.";
												END IF;
											ELSE
												LET cReturnCode = '9996';
												LET cErrorDescription = "Consulta no exitosa. Telefonica.";
											END IF;
										ELSE
											LET cReturnCode = '9996';
											LET cErrorDescription = "Consulta no exitosa. MSISDNrecepcion.";
										END IF;
									ELSE
										LET cReturnCode = '9975';
										LET cErrorDescription = "Error autenticaciÃ³n. Id de sesiÃ³n invÃ¡lido.";
									END IF;
								ELSE
									LET cReturnCode = '9975';
									LET cErrorDescription = "Error autenticaciÃ³n. Id de sesiÃ³n invÃ¡lido.";
								END IF;
							ELSE
								LET cReturnCode = '9976';
								LET cErrorDescription = "Error autenticaciÃ³n. IP origen invÃ¡lida ";
							END IF;
						ELSE
							LET cReturnCode = '9979';
							LET cErrorDescription = " Error autenticaciÃ³n. Password no existe.";
						END IF;
					ELSE
						LET cReturnCode = '9980';
						LET cErrorDescription = 'Error autenticaciÃ³n. Usuario no existe';
					END IF;
				ELSE
					LET cReturnCode = '9998';
					LET cErrorDescription = "AutenticaciÃ³n fallida. CÃ³digo de agente invÃ¡lido.";
				END IF;
			ELSE
				LET cReturnCode ='9982';
				LET cErrorDescription = " Consulta no exitosa. TransacciÃ³n no definida.";
			END IF;
		END IF;

	---------------------------------------------------------------------------------------------------------------
		SELECT MAX(id)
		INTO iSecuencia
		FROM "informix".tf_cte_online
		WHERE cuenta_tf = pcAccountNumber
		AND telefono = pcTelefono;

		UPDATE "informix".tf_cte_online
		SET cod_error = cReturnCode, desc_error = cErrorDescription
		WHERE cuenta_tf = pcAccountNumber
		AND telefono = pcTelefono
		AND id = iSecuencia;

		SELECT numcte_tf
		INTO cNumTranfer
		FROM "informix".tf_maecte
		where numcte_tf=cNumTranfer;

	RETURN trim(cReturnCode),trim(cErrorDescription),trim(cNumTranfer);
END;
END PROCEDURE
DOCUMENT
'Folio:1589',
'Autor:95594213 Leonardo Plata',
'Fecha:06-Marzo-2014',
'ModificaciÃ³n: Se crea sp que registre en la base de datos de BanCoppel la informaciÃ³n que recibe el WS Clientes_transfer correspondiente a la alta o modificaciÃ³n de clientes.',
'Sustento: RQI 63 049 Procesos Transfer Central.pdf ',
'Solicita: Manuel Osuna',
'Folio:1604',
'Modifico:Felipe Urias',
'Fecha:22/04/2014',
'ModificaciÃ³n: se agrego codigo de error 300 para el caso de que pcEstatusRegistro sea diferente de  0,1 y 2',
'Sustento: Evidencias Ciclo 1.ods',
'Solicita: Gabriela GudiÃ±o',
'Modifico:Carlos Andres Crespo Prado',
'Fecha:30/09/2014',
'ModificaciÃ³n: Se agregaron 3 campos nuevos a los sp y las tablas',
'Sustento: Transfer',
'Solicita: Manuel Osuna',
'BD: bditransfer';