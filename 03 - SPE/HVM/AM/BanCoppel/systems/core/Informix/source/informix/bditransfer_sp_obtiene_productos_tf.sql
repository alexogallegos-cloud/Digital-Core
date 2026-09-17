CREATE PROCEDURE "informix".sp_obtiene_productos_tf(pEmpresa CHAR(3))
RETURNING CHAR(6) as Cod_Retorno, CHAR(4) as Cod_Producto;
--Declaracion de variables

DEFINE sCodRet CHAR(6);
DEFINE iSqlErr INTEGER;
DEFINE sCodProd CHAR(4);

--SET DEBUG FILE TO "/respaldosbd/Leslie/sp_obtiene_productos_tf.out";
--TRACE ON;

--Asignacion de variables

LET sCodRet = '000000';
LET iSqlErr = 0;
LET sCodProd = '';

--Inicio del procedimiento
BEGIN

    ON EXCEPTION SET iSqlErr --Manejador de Errores
        IF iSqlErr <> 0 THEN
            LET sCodRet = iSqlErr;
            RETURN sCodRet, sCodProd;
        END IF;
    END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 5;
	
	IF NVL(pEmpresa,'')='' THEN
		LET sCodRet = '000001';
		RETURN sCodRet, sCodProd;
	ELSE
		FOREACH
			SELECT producto 
			INTO sCodProd
			FROM bdicheq:"informix".sc_producto 
			WHERE asociar_transfer='2'
			AND empresa = pEmpresa
		
			RETURN sCodRet, sCodProd WITH RESUME;
		END FOREACH
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET sCodRet = '000002';
			RETURN sCodRet, sCodProd;
		END IF
	END IF
END
END PROCEDURE
DOCUMENT
"Realiza búsqueda de productos asociados a transfer que se pueden ofertar",
"Autor : Leslie Rendón",
"FECHA : 10/04/2014",
"BD    : bditransfer";

CREATE PROCEDURE "informix".sp_cargo(	pcAgent_trans_type_code CHAR(10),
										pcAgent_cd              CHAR(6),
										pcUsuario               CHAR(8),
										pcPassword              CHAR(8),
										pcIp_origen             CHAR(15),
										pcSession_id            CHAR(30),
										pcServiceName 			CHAR (128),
                                        pctransactionType 		CHAR (2),
										pcSystemDate 			CHAR(20),
                                        pcCountryCode 			CHAR (3),
                                        pcBankId				CHAR (3),
                                        pcOriginalMpsTransactionId CHAR (12),
										pcAccessMethod 			CHAR (3),
										pccurrency 				CHAR (3),
										pcamount 				DECIMAL(16,3),
										pcdestAccountId 		CHAR (18),
										pcdestAccountIdType 	CHAR (3),
										pcdestBankId 			CHAR (3),
										pcbankSourceAccount 	CHAR (18),
										pcbankSourceAccountType CHAR (3),
										pcreferences 			CHAR(250))


	RETURNING
		CHAR (20) AS cReturnCode,
		CHAR (256) AS cErrorDescription,
		CHAR(30) AS CexternalTransactionId;

	---DECLARACION DE VARIABLES
	DEFINE iSqlErr  				INTEGER;
	Define iNumeroAleatorio 		Integer;
	DEFINE cPCodRet 				CHAR(5);
	DEFINE cReturnCode 				CHAR(20);
	DEFINE cErrorDescription 		CHAR(256);
	DEFINE cExternalTransactionId 	CHAR(30);
	DEFINE cIdTransaccionReverso	CHAR(40);
	DEFINE cReferences 				CHAR(250);
	
	DEFINE vcEmpresa		CHAR(3);
	DEFINE cAgent_cd		CHAR(3);
	DEFINE cUsuario			CHAR(8);
	DEFINE cPassword		CHAR(8);
	DEFINE cIp_origen		CHAR(15);
	DEFINE cId_sesion_act	CHAR(30);
	DEFINE cNombre_preceso	CHAR(17);
	DEFINE dtFecha_dia		DATE	;
	DEFINE cOpcode			CHAR(5);
	--DEFINE cFecha 		CHAR(8);
	--DEFINE cHora 			CHAR(6);
	DEFINE cCodRet 			CHAR(4);
	DEFINE cCodRet1			CHAR(4);

	DEFINE vcTranccTemp		CHAR(4);
	DEFINE vcTransuc		CHAR(4);
	DEFINE vcFolioSucCargo	CHAR(30);
	DEFINE vcNoCuentaOri    CHAR(18);
	DEFINE viCheque         CHAR(4);
	DEFINE vmMonto          MONEY(16,2);
	DEFINE vcDivisa         CHAR(4);
	DEFINE vcReferencia     CHAR(20);
	DEFINE vcNoTarjeta      CHAR(18);
	DEFINE vcSucursal		CHAR(4);
	DEFINE vcNocliente    	CHAR(10);

	DEFINE vcodretTemp    	CHAR(5);
    DEFINE vctranret   		CHAR(4);
	DEFINE vcusuario  		CHAR(8);
	DEFINE vdfechoy 		DATE;
	DEFINE vmsdodisp		MONEY(16,2);
	define vmontoret		MONEY(16,2);
	DEFINE vdFechaHoy 		DATE;

	DEFINE dFechaNueva 	 	CHAR(10);
	DEFINE cDia         	CHAR(2);
	DEFINE cMes         	CHAR(2);
	DEFINE cAnio        	CHAR(4);
	DEFINE tipo				CHAR(3);
	DEFINE CTA 				CHAR(20);
	
	DEFINE ejec 			CHAR(250);		
	DEFINE cNombresp 		CHAR(30);

	---INICIALIZACION DE VARIABLES

	LET iSqlErr = 0;
	let iNumeroAleatorio=0;
	LET cReturnCode = '0';
	LET cErrorDescription = 'Consulta exitosa';
	LET cIdTransaccionReverso='00000';
	LET cReferences='key1,key2,key3,value1,value2,value3';
	LET cExternalTransactionId ='';
	LET cAgent_cd ='';
	LET cUsuario ='';
	LET cPassword ='';
	LET cIp_origeN ='';
	LET cId_sesion_act ='';
	LET cNombre_preceso = 'sp_cargo';
	LET dtFecha_dia   = CURRENT::DATE;
	LET cCodRet = '0000';
	LET cOpcode = '';
	LET cCodRet1='';
	/*LET cDescr_mensaje = '';
	LET cDescr_completa_mensaje = '';*/
	LET vcSucursal='9250';
	LET	vcEmpresa='001';
	LET vcTranccTemp='';
	LET vcTransuc='0000';
	LET vcFolioSucCargo ='';
	LET vcNoCuentaOri  ='';
	LET viCheque =0;
	LET vmMonto =pcamount;
	LET vcDivisa =''   ;
    LET vcReferencia ='DEBIT TO BANK-TRANSFER';
    LET vcNoTarjeta ='';
	--TRIM(pcdestAccountId);
    LET vcUsuario ='informix';
	LET dFechaNueva   = DATE(1);

	let vcodretTemp='';
	LET vctranret='';
	LET tipo='';
	LET CTA='';
	LET pcSystemDate=replace(pcSystemDate,'/','');
	
	LET ejec='';
	LET cNombresp="cargo";



--SET DEBUG FILE TO '/informix/andrescrespo/sp_dmcargo.out';
--TRACE ON;

     BEGIN
    -- // MANEJO DE EXCEPCIONES
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN--manejador de errores
			LET cCodRet = iSqlErr;
			LET cOpcode = cCodRet;
			LET cErrorDescription='Codigo no registrado en catalogo.';
			RETURN trim(cOpcode),TRIM(cErrorDescription),cExternalTransactionId;
        END IF;
    END EXCEPTION;




SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	--LET cFecha = SUBSTR(pcSystemDate, 1, 8);
	--LET cHora = SUBSTR(pcSystemDate, 9, 6);

--Se inserta el registro del proceso en curso
--	INSERT INTO bdisac:"informix".sac_ws_procesos(proceso,fecha_proceso,hora_proceso,estatus,cod_ret,user_insert,fecha_insert,hora_insert)
--	VALUES(cNombre_preceso,cFecha,cHora,'0','',pcUsuario,current::date,REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', ''));


--------------VALIDACIÓN DE PARAMETROS-------------------------
		IF (NVL(pcServiceName,'?')= '?' OR NVL(pcCountryCode,'?')= '?' OR NVL(pcAgent_cd,'?')= '?' OR NVL(pcUsuario,'?')= '?'
			OR NVL(pcBankId,'?')= '?' OR NVL(pcAccessMethod,'?')= '?'  OR NVL(pcAgent_trans_type_code,'?')= '?' OR NVL(pcPassword,'?')= '?'
			OR NVL(pcIp_origen,'?')= '?' OR NVL(pcSession_id,'?')= '?'
			OR NVL(pctransactionType,'?')= '?' OR NVL(pcOriginalMpsTransactionId,'?')= '?' OR NVL(pccurrency,'?')= '?' OR NVL(pcamount,'?')= '?'
			OR NVL(pcbankSourceAccount,'?')= '?' OR NVL(pcbankSourceAccountType,'?')= '?')
			THEN
			LET cReturnCode ='9996';
			LET cErrorDescription = "Error de parametros de entrada";
		ELSE
			IF EXISTS (SELECT transaccion FROM bdisac:"informix".sac_ws_transacc_ctes
			   WHERE agent_cd = pcAgent_cd AND transaccion = pcAgent_trans_type_code AND usuario = trim(pcusuario) AND activa = 'S' ) THEN

				--Se obtienen lo0s valores de lo0s campo0s, para la validacio0n de lo0s parametro0s de entrada
				SELECT agent_cd,usuario,password,ip_origen,id_sesion_act
				INTO cAgent_cd,cUsuario,cPassword,cIp_origen,cId_sesion_act
				FROM bdisac:"informix".sac_ws_clientes 
				WHERE agent_cd = pcAgent_cd AND usuario = trim(pcusuario) and  fecha_insert = dtFecha_dia;

				IF (pcBankId='002' or pcBankId='036' or pcBankId='012' or pcBankId='137' or pcBankId='044' ) THEN
					IF (pcAccessMethod ='115') THEN
						IF (pcCurrency ='484') THEN
						
							IF (pcdestAccountIdType='' or pcdestAccountIdType='?' or pcDestAccountIdType='101' 
								OR pcDestAccountIdType='102' OR pcDestAccountIdType='103' OR pcDestAccountIdType='104') THEN
								let tipo = TRIM(pcdestAccountIdType);
							
								IF (pcdestAccountId ='?' or pcdestAccountId ='' 
									or (length(pcdestAccountId)=12 and tipo='101')
									or (length(pcdestAccountId)=12 and tipo='106')
									or (length(pcdestAccountId)=18 and tipo='102')
									or (length(pcdestAccountId)=16 and tipo='103')
									or (length(pcdestAccountId)=11 and tipo='104'))	THEN

									IF(pcdestBankId='' or pcdestBankId='?' or pcdestBankId='002' or pcdestBankId='036' or pcdestBankId='012' or pcdestBankId='137' or pcdestBankId='044') THEN
										IF (length(pcOriginalMpsTransactionId)=12) THEN	
											
											IF pctransactionType = '01' THEN
												IF pcamount > 0 THEN
													IF pcCountryCode='484'	THEN
														IF cAgent_cd = pcAgent_cd THEN
															IF cUsuario = pcUsuario   THEN
																IF cPassword = pcPassword THEN
																	IF cIp_origen = pcIp_origen THEN
																		IF cId_sesion_act::CHAR(30) = pcSession_id THEN
																			IF pcSession_id = (SELECT id_sesion_act::CHAR(30) FROM bdisac:"informix".sac_ws_clientes WHERE agent_cd = pcAgent_cd AND usuario = trim(pcusuario) and fecha_insert = dtFecha_dia) THEN
																				IF length(pcSystemDate)>1 THEN
																					LET cDia=SUBSTR(pcSystemDate,1,2);
																					LET cMes=SUBSTR(pcSystemDate,3,2);
																					LET cAnio=SUBSTR(pcSystemDate,5,4);
																					LET dFechaNueva = mdy(cMes,cDia,cAnio);
																					
																					IF  NVL(dFechaNueva,'')!='' and dFechaNueva::DATE=today THEN
																						
																						
																						SELECT valor INTO vcDivisa
																						FROM bdiprog:"informix".pp_parametros WHERE cve_param = '08';
																						
																						SELECT NUMERO
																						INTO vcTranccTemp  
																						FROM bdinteg:"informix".si_transacc 
																						WHERE sistema = '01' AND NUMERO = '0239';
																						
																	
																						execute Procedure bdicheq:"informix".sp_generafolionomina('TRANSFER')
																						into cCodRet1,vcFolioSucCargo;
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
																						--102 CLAVE
																						--104 ACC NUMBER
																						IF(pcBankSourceAccountType='102' OR pcBankSourceAccountType='104') THEN

																									IF pcBankSourceAccountType='102' then
																										
																										
																										SELECT NVL(cuenta,'00000')
																										INTO CTA
																										FROM BDICHEQ:"informix".SC_MAECHQ
																										WHERE cuenta_clabe=pcbankSourceAccount;		--CUENTA
																																																																												
																										LET vcNoCuentaOri=CTA;
																										
																									END IF;
																									
																									
																									IF pcBankSourceAccountType='104' then

																										SELECT NVL(num_cte,'00000') 
																										INTO vcNoCliente 
																										FROM BDICHEQ:"informix".SC_MAECHQ 						--CLIENTE
																										WHERE cuenta = pcbankSourceAccount AND num_cte = num_cte   ;
																										
																										LET vcNoCuentaOri=pcbankSourceAccount;
																									END IF;
																									

																							IF (LENGTH(vcNoCuentaOri)=11 ) THEN

																								EXECUTE PROCEDURE bdicheq:"informix".cargo_ref(vcEmpresa, vcSucursal, vcUsuario, vcTranccTemp, vcTransuc,vcFolioSucCargo,trim(vcNoCuentaOri), viCheque, vmMonto, trim(vcDivisa), vcReferencia,'', vcUsuario )
																								INTO vcodretTemp, vctranret, vdfechoy, vmsdodisp, vmontoret;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			
																								LET ejec= 'cargo('||vcEmpresa||''','''||vcSucursal||''','''||vcUsuario||''','''||vcTranccTemp ||''','''||vcTransuc||''','''||nvl(vcFolioSucCargo,'')||''','''||vcNoCuentaOri||''','''||viCheque||''','''||vmMonto||''','''||vcDivisa||''','''||nvl(vcReferencia,'')||''','''||'0'||''','''||vcUsuario||')';
																									
																									INSERT INTO "informix".oterroresspext(transaccion,cod_error,mensaje_error,sp_llamado,usuario_transfer,ejecucionsp,fecha_insert)
																									VALUES(cNombre_preceso,vcodretTemp,vctranret,cNombresp,pcbankSourceAccount,ejec,current);  
																									
																								IF vcodretTemp::INTEGER != 0 THEN
																																																		
																									LET cReturnCode = '9974';
																									LET cErrorDescription = "Error al ejecutar cargo_ref. Cuenta invalida";
																								ELSE
																								
																									LET cExternalTransactionId = trim(vcFolioSucCargo);
																									RETURN TRIM(cReturnCode),TRIM(cErrorDescription),cExternalTransactionId;
																								END IF;
																								
																								
																							ELSE
																								LET cReturnCode = '9996';
																								LET cErrorDescription = "Consulta no exitosa. Cuenta invalida.";
																							END IF;
																						
																						ELSE
																							LET cReturnCode ='9996';
																							LET cErrorDescription = " Error de parametros de entrada. BankSourceAccountType";
																						END IF;
																						
																					ELSE
																						LET cReturnCode = '9996';
																						LET cErrorDescription = "Consulta no exitosa. Fecha inválida.";
																					END IF;
		
																				ELSE
																					LET cReturnCode = '9996';
																					LET cErrorDescription = "Consulta no exitosa. Fecha inválida.";
																				END IF;
																			ELSE
																				LET cReturnCode = '9975';
																				LET cErrorDescription = "Error autenticación. Id de sesión inválido.";
																			END IF;
																		ELSE
																			LET cReturnCode = '9975';
																			LET cErrorDescription = "Error autenticación. Id de sesión inválido.";
																		END IF;
																	ELSE
																		LET cReturnCode = '9976';
																		LET cErrorDescription = "Error autenticación. IP origen inválida ";
																	END IF;
																ELSE
																	LET cReturnCode = '9979';
																	LET cErrorDescription = " Error autenticación. Password no existe.";
																END IF;
															ELSE
																LET cReturnCode = '9980';
																LET cErrorDescription = 'Error autenticación. Usuario no existe';
															END IF;
														ELSE
															LET cReturnCode = '9998';
															LET cErrorDescription = "Autenticación fallida. Código de agente inválido.";
														END IF;
													ELSE
														LET cReturnCode ='9996';
														LET cErrorDescription = " Error de parametros de entrada. CountryCode ";
													END IF;
												ELSE
													LET cReturnCode ='9996';
													LET cErrorDescription = " Error de parametros de entrada. Amount debe ser > 0";
												END IF;
											ELSE
												LET cReturnCode ='9996';
												LET cErrorDescription = " Error de parametros de entrada. TransactionType";
											END IF;
										ELSE
											LET cReturnCode ='9996';
											LET cErrorDescription = " Error de parametros de entrada.OriginalMpsTransactionId";
										END IF;
									ELSE
										LET cReturnCode ='9996';
										LET cErrorDescription = " Error de parametros de entrada. destBankId ";
									END IF;
								ELSE
									LET cReturnCode ='9996';
									LET cErrorDescription = " Error de parametros de entrada. destAccountId";
								END IF;
							ELSE
								LET cReturnCode ='9996';
								LET cErrorDescription = " Error de parametros de entrada. destAccountIdType";
							END IF;	
							
						ELSE
							LET cReturnCode ='9996';
							LET cErrorDescription = " Error de parametros de entrada. Currency";
						END IF;
					ELSE
						LET cReturnCode ='9996';
						LET cErrorDescription = " Error de parametros de entrada. AccessMethod";
					END IF;
				ELSE
					LET cReturnCode ='9996';
					LET cErrorDescription = " Error de parametros de entrada. BankId";
				END IF;
			ELSE
				LET cReturnCode ='9982';
				LET cErrorDescription = " Consulta no exitosa. Transacción no definida.";
			END IF;
		END IF;

	RETURN trim(cReturnCode),TRIM(cErrorDescription),cExternalTransactionId;

	END;
END PROCEDURE
DOCUMENT
'AUTOR: 96103817, Carlos Andres Crespo',
'DESCRIPCION: Realiza un cargo a tarjeta de debito ',
'FECHA: 29/08/2014',
'SOLICITO:Manuel Osuna',
'RQI 63 070 WS-PUB Transfer ',
'BD: BDITRANSFER';

CREATE PROCEDURE "informix".sp_renapo(		pcAgent_trans_type_code CHAR(10),
											pcAgent_cd 				CHAR(6),
											pcUsuario 				CHAR(8),
											pcPassword 				CHAR(8),
											pcIp_origen 			CHAR(15),
											pcSession_id 			CHAR(30),
											pcServiceName 			CHAR(128), 
											pcSystemDate 			CHAR(15), 
											pcCountryCode 			CHAR(3), 
											pcBankId 				CHAR(3), 
											pcAccessMethod 			CHAR(3),
											pcMedioAcceso 			CHAR(2),
											pcApellidoPaterno 		CHAR(50),
											pcApellidoMaterno 		CHAR(50),
											pcNombre 				CHAR(50),
											pcFechaNacimiento 		CHAR(15), --DD/MM/YYYY
											pcNumCelular 			CHAR(12),
											pcNumTarjeta 			CHAR(16),--opcional
											pcCalle 				CHAR(100),
											pcNumeroExterior 		CHAR(15),--opcional
											pcNumeroInterior 		CHAR(15),--opcional
											pcColonia 				CHAR(100),
											pcEstado 				CHAR(100),
											pcMunicipio 			CHAR(50),
											pcCodigoPostal 			CHAR(8),
											pcSexo 					CHAR(1),
											pcRfc 					CHAR(13),--opcional
											pcEntidadNacimiento 	CHAR(2)) --ent federativa
	
RETURNING
		CHAR (4)  AS cCod_error,				
		CHAR (2)  AS cClave,
		CHAR (2)  AS cEntidadEmisora,
		CHAR (12)  AS vcUsuario,
		CHAR (15) AS cIpRenapo,
		CHAR (10) AS cFecNac,
		CHAR (50) AS pcNombre,
		CHAR (8)  AS cPassword,
		CHAR (50) AS pcApellidoPaterno,
		CHAR (50) AS pcApellidoMaterno,
		CHAR (1)  AS cSexo,
		CHAR (1)  AS cTipoTransaccion,
		CHAR (10) AS pcAgent_trans_type_code,
		CHAR (6)  AS pcAgent_cd,
		CHAR (8)  AS pcUsuario,
		CHAR (8)  AS pcPassword,
		CHAR (15) AS pcIp_origen,
		CHAR (30) AS pcSession_id;
		
		
																							
				
	---DECLARACION DE VARIABLES
	DEFINE iSqlErr  			INTEGER;
	DEFINE cPCodRet 			CHAR(5);
	DEFINE cCod_error	 		CHAR (5);
	DEFINE cErrorDescription 	CHAR (256);
	DEFINE cApellidoPaterno 	CHAR (50);
	DEFINE cApellidoMaterno 	CHAR (50);
	DEFINE cNombre 				CHAR (50);
	DEFINE cfechaNacimiento 	CHAR (15);
	DEFINE cNumTarjeta	 		CHAR (16);
	DEFINE cFechaValidacionRenapo CHAR (10);
	DEFINE cUsuario				CHAR(12);
	DEFINE cIpRenapo			CHAR(15);
	DEFINE cPassword			CHAR(8);
	DEFINE cTipoTransaccion		CHAR(1);
	DEFINE cAgent_cd			CHAR(3);
	DEFINE vcUsuario			CHAR(12);
	DEFINE vcPassword			CHAR(8);
	DEFINE cIp_origen			CHAR(15);
	DEFINE cId_sesion_act		CHAR(30);
	DEFINE dtFecha_dia			DATE;
	DEFINE dFechaNueva 	 		CHAR(10);
	DEFINE cFecNac				CHAR(10);
	DEFINE cDia         		CHAR(2);
	DEFINE cMes         		CHAR(2);
	DEFINE cAnio        		CHAR(4);
	DEFINE cDiaNac				CHAR(2);
	DEFINE cMesNac              CHAR(2);
	DEFINE cAnioNac             CHAR(4);
	DEFINE CCLAVE 				CHAR(2);
	DEFINE cEntidadEmisora 		CHAR(2);
	DEFINE CRFC					CHAR(13);
	DEFINE cNumCelular			CHAR(10);
	---INICIALIZACION DE VARIABLES
	LET cAgent_cd ='';
	LET CCLAVE='';
	LET cUsuario ='';
	LET cPassword ='';
	LET cIp_origeN ='';
	LET cId_sesion_act ='';
	LET dtFecha_dia   = CURRENT::DATE;
	LET pcSystemDate=replace(pcSystemDate,'/','');
	LET dFechaNueva   = DATE(1);
	LET cFecNac = DATE(1);
	LET cTipoTransaccion='6';

	--user: WS9003888
	--pwd : HDFRM69
	LET vcPassword='HDFRM69';
	LET cIpRenapo='201.158.207.46';
	LET vcUsuario='WS9003888';
	LET cEntidadEmisora='30';
	LET iSqlErr = 0;
	LET cPCodRet = '0';
	LET cCod_error = '0000';
	LET cErrorDescription = 'Consulta exitosa';
	LET cApellidoPaterno='';
    LET cApellidoMaterno='';
	LET cNombre='';
	LET cNumCelular='';
	LET cNumTarjeta='';
	LET cFechaValidacionRenapo=date(1);
	LET cfechaNacimiento=date(1);
	LET	cDiaNac='';
	LET	cMesNac=''; 
	LET	cAnioNac='';
	LET	cDia='';
	LET	cMes=''; 
	LET	cAnio='';
	let crfc='';
				
	--SET DEBUG FILE TO '/informix/andrescrespo/sp_dm_renapo.out';
	--TRACE ON;

    BEGIN
    -- 
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN--manejador de errores
			LET cCod_error = iSqlErr;
			let cErrorDescription='Error desconocido';
			RETURN  cCod_error,cClave,cEntidadEmisora,vcUsuario,trim(cIpRenapo),cFecNac,pcNombre,pcPassword,pcApellidoPaterno,pcApellidoMaterno,pcSexo,cTipoTransaccion,pcAgent_trans_type_code,pcAgent_cd,pcUsuario,pcPassword,	pcIp_origen,pcSession_id;																				
        END IF;
    END EXCEPTION;
	
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 10;

	 IF TRIM(pcUsuario) = 'sys_ofi' AND  TRIM(pcPassword)='sucursal' THEN
			
            LET cDiaNac=SUBSTR(pcfechaNacimiento,9,2);
            LET cMesNac=SUBSTR(pcfechaNacimiento,6,2);
            LET cAnioNac=SUBSTR(pcfechaNacimiento,1,4);
            LET cFecNac=(cDiaNac||'/'||cMesNac||'/'||cAnioNac); --ddmmyyyy se necesita dmy para el wsdl renapo

            LET pcfechaNacimiento = mdy(cMesNac,cDiaNac,cAnioNac)::date; --mmddyyyy para la validacion de nacimiento valida	
            LET cNumCelular=SUBSTR(pcNumCelular,3,10);
			LET cNumTarjeta=pcNumTarjeta;
			LET crfc=pcRfc;
			
			
			
            SELECT clave INTO cclave FROM bditransfer:"informix".tf_entidadfed WHERE id=pcEntidadNacimiento;	

            INSERT INTO "informix".tf_renapo(Apellido_paterno,Apellido_materno,Nombre,Sexo,Fecha_nacimiento,Nacionalidad,Municipio,Num_Registro_Extranjero,CURP,cStatusRenapo,fecha_validacion,num_celular,num_tarjeta)
			VALUES (pcApellidoPaterno,pcApellidoMaterno,pcNombre,pcSexo,pcfechaNacimiento,'',cClave,'','', '','',cNumCelular,cNumTarjeta);

			RETURN  cCod_error,cClave,cEntidadEmisora,vcUsuario,trim(cIpRenapo),cFecNac,pcNombre,vcPassword,pcApellidoPaterno,pcApellidoMaterno,pcSexo,cTipoTransaccion,pcAgent_trans_type_code,pcAgent_cd,pcUsuario,pcPassword,pcIp_origen,pcSession_id;																													--testconsulta			ddmmyyyy				test2009									6 o 1
															  
    ELSE
		IF NVL(pcServiceName,'?')= '?' OR NVL(pcCountryCode,'?')= '?' OR NVL(pcAgent_cd,'?')= '?' OR NVL(pcUsuario,'?')= '?'
			OR NVL(pcBankId,'?')= '?' OR NVL(pcAccessMethod,'?')= '?'  OR NVL(pcAgent_trans_type_code,'?')= '?' OR NVL(pcPassword,'?')= '?'
		    OR NVL(pcIp_origen,'?')= '?' OR NVL(pcSession_id,'?')= '?'
			OR NVL(pcMedioAcceso,'?')= '?' OR NVL(pcApellidoPaterno,'?')= '?' OR NVL(pcNombre,'?')= '?' OR NVL(pcFechaNacimiento,'?')= '?'
			OR NVL(pcNumCelular,'?')= '?' OR NVL(pcCalle,'?')= '?' OR NVL(pcColonia,'?')= '?' OR NVL(pcEstado,'?')= '?'
			OR NVL(pcMunicipio,'?')= '?' OR NVL(pcCodigoPostal,'?')= '?' OR NVL(pcSexo,'?')= '?' OR NVL(pcEntidadNacimiento,'?')= '?'
			
			THEN
			LET cCod_error ='9996';
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
										IF  (pcBankId='002' or pcBankId='036' or pcBankId='012' or pcBankId='137' or pcBankId='044')  THEN
											IF pcCountryCode='484' THEN
												IF pcAccessMethod='115' THEN
													IF ( pcMedioAcceso='1' OR pcMedioAcceso='2' OR pcMedioAcceso='3' OR pcMedioAcceso='4' OR pcMedioAcceso='5' OR pcMedioAcceso='6' OR pcMedioAcceso='7' OR pcMedioAcceso='8' ) THEN
															LET cDiaNac=SUBSTR(pcfechaNacimiento,9,2);
															LET cMesNac=SUBSTR(pcfechaNacimiento,6,2);
															LET cAnioNac=SUBSTR(pcfechaNacimiento,1,4);
															LET cFecNac=(cDiaNac||'/'||cMesNac||'/'||cAnioNac); --ddmmyyyy se necesita dmy para el wsdl renapo
														
															LET pcfechaNacimiento = mdy(cMesNac,cDiaNac,cAnioNac)::date; --mmddyyyy para la validacion de nacimiento valida
															
														IF ((pcfechaNacimiento > date(1)::date) and (pcfechaNacimiento < today::date)) THEN
														
															IF LENGTH(pcnumCelular)=12 THEN
																LET cNumCelular=SUBSTR(pcNumCelular,3,10);
																IF (LENGTH(pcNumTarjeta)=16 OR pcNumTarjeta='')  THEN
																	LET cNumTarjeta=pcNumTarjeta;
																	IF LENGTH(pcCodigoPostal)<=8 THEN
																		IF (pcSexo='H' OR pcSexo='M' OR pcSexo='h' OR pcSexo='m' ) THEN
																			let crfc=pcRfc;
																			IF (LENGTH(pcRfc)=13 OR pcRfc='' or pcRfc='?') THEN
																				IF LENGTH(pcEntidadNacimiento)=2 THEN
																				
																					SELECT CLAVE
																					INTO CCLAVE
																					FROM "informix".tf_entidadfed
																					WHERE id=pcEntidadNacimiento;		
																					
																					
																					
																					
																					/*IF length(pcSystemDate)!='' THEN
																						LET cDia=SUBSTR(pcSystemDate,1,2);
																						LET cMes=SUBSTR(pcSystemDate,3,2);
																			
																			LET cAnio=SUBSTR(pcSystemDate,5,4);
																						LET dFechaNueva = mdy(cMes,cDia,cAnio);
																						IF  NVL(dFechaNueva,'')!='' and dFechaNueva::DATE=today THEN*/
																						
																						
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------														
																							INSERT INTO "informix".tf_renapo(Apellido_paterno,Apellido_materno,Nombre,Sexo,Fecha_nacimiento,Nacionalidad,Municipio,Num_Registro_Extranjero,CURP,cStatusRenapo,fecha_validacion,num_celular,num_tarjeta)
																							VALUES (pcApellidoPaterno,pcApellidoMaterno,pcNombre,pcSexo,pcfechaNacimiento,'',cClave,'','', '','',cNumCelular,cNumTarjeta);
																			
																							RETURN  cCod_error,cClave,cEntidadEmisora,vcUsuario,trim(cIpRenapo),cFecNac,pcNombre,vcPassword,pcApellidoPaterno,pcApellidoMaterno,pcSexo,cTipoTransaccion,pcAgent_trans_type_code,pcAgent_cd,pcUsuario,pcPassword,	pcIp_origen,pcSession_id;																													--testconsulta			ddmmyyyy				test2009									6 o 1
														  
											
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
																						/*ELSE
																							LET cCod_error = '9996';
																							LET cErrorDescription = "Consulta no exitosa. Fecha inválida.";
																						END IF;
																					ELSE
																						LET cCod_error = '9996';
																						LET cErrorDescription = "Consulta no exitosa. Fecha inválida.";
																					END IF;*/
																				ELSE
																					LET cCod_error = '9996';
																					LET cErrorDescription = "Consulta no exitosa. EntidadNacimiento.";
																				END IF;
																			ELSE
																				LET cCod_error = '9996';
																				LET cErrorDescription = "Consulta no exitosa. RFC.";
																			END IF;	
																		ELSE
																			LET cCod_error = '9996';
																			LET cErrorDescription = "Consulta no exitosa. Sexo H/M.";
																		END IF;
																	ELSE
																		LET cCod_error = '9996';
																		LET cErrorDescription = "Consulta no exitosa. CodigoPostal.";
																	END IF;
																ELSE
																	LET cCod_error = '9996';
																	LET cErrorDescription = "Consulta no exitosa. NumTarjeta.";
																END IF;
															ELSE
																LET cCod_error = '9996';
																LET cErrorDescription = "Consulta no exitosa. NumCelular.";
															END IF;
														ELSE
															LET cCod_error = '9996';
															LET cErrorDescription = "Consulta no exitosa. FechaNacimiento.";
														END IF;
													ELSE
														LET cCod_error = '9996';
														LET cErrorDescription = "Consulta no exitosa. MedioAcceso";
													END IF;
												ELSE
													LET cCod_error ='9996';
													LET cErrorDescription = " Error de parametros de entrada. AccessMethod";
												END IF;
						
											ELSE
												LET cCod_error ='9996';
												LET cErrorDescription = " Error de parametros de entrada. CountryCode";
											END IF;
										ELSE
											LET cCod_error ='9996';
											LET cErrorDescription = " Error de parametros de entrada. BankId";
										END IF;											
									ELSE
										LET cCod_error = '9975';
										LET cErrorDescription = "Error autenticación. Id de sesión inválido.";
									END IF;
								ELSE
									LET cCod_error = '9975';
									LET cErrorDescription = "Error autenticación. Id de sesión inválido.";
								END IF;
							ELSE
								LET cCod_error = '9976';
								LET cErrorDescription = "Error autenticación. IP origen inválida ";
							END IF;
						ELSE
							LET cCod_error = '9979';
							LET cErrorDescription = " Error autenticación. Password no existe.";
						END IF;
					ELSE
						LET cCod_error = '9980';
						LET cErrorDescription = 'Error autenticación. Usuario no existe';
					END IF;
				ELSE
					LET cCod_error = '9998';
					LET cErrorDescription = "Autenticación fallida. Código de agente inválido.";
				END IF;
			ELSE
				LET cCod_error ='9982';
				LET cErrorDescription = " Consulta no exitosa. Transacción no definida.";
			END IF;					
		END IF;								  
	END IF;

	
	RETURN  cCod_error,cClave,cEntidadEmisora,vcUsuario,trim(cIpRenapo),cFecNac,pcNombre,cPassword,pcApellidoPaterno,pcApellidoMaterno,pcSexo,cTipoTransaccion,pcAgent_trans_type_code,pcAgent_cd,pcUsuario,pcPassword,	pcIp_origen,pcSession_id;																						
	END;
END PROCEDURE
DOCUMENT
'AUTOR: 96103817, Carlos Andres Crespo',
'DESCRIPCION: Servicio OT que recibe datos de transfer y ejecuta un web service RENAPO para validar la curp. ',
'FECHA: 29/08/2014',
'SOLICITO:Manuel Osuna',
'RQI 63 070 WS-PUB Transfer ',
'BD: BDITRANSFER';

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