CREATE PROCEDURE "informix".sp_abono_cta(		pcAgent_trans_type_code CHAR(10),
											pcAgent_cd 				CHAR(6),
											pcUsuario 				CHAR(8),
											pcPassword 				CHAR(8),
											pcIp_origen 			CHAR(15),
											pcSession_id 			CHAR(30),
											pcServiceName 			CHAR(128),
											pcTransactionType	 	CHAR(2),
											pcSystemDate 			CHAR(20),
											pcCountryCode 			CHAR(3),
											pcBankId 				CHAR(3),
											pcMpsTransactionId 		CHAR(12),
											pcAccessMethod 			CHAR(3),
											pcCurrency 				CHAR(3),
											pcAmount 				DECIMAL(14,3),
											pcSourceAccountId 		CHAR(18),
											pcSourceAccountIdType 	CHAR(3),
											pcSourceBankId 			CHAR(3),
											pcBankDestAccount 		CHAR(18),
											pcBankDestAccountType 	CHAR(3),
											pcReferences 			CHAR(250))
	RETURNING
		CHAR (20) AS cRetCode,
		CHAR (256) AS cErDescription,
		CHAR (30) AS cExtTransactionId,
		CHAR (40) AS codigoRastreo;
	---DECLARACION DE VARIABLES
	DEFINE iSqlErr  				INTEGER;
	DEFINE cPCodRet 				CHAR(5);
	DEFINE cReturnCode 				CHAR (20);
	DEFINE cErrorDescription 		CHAR (100);
	DEFINE cExternalTransactionId 	CHAR (30);
	DEFINE cIdTransaccionReverso 	CHAR (40);
	DEFINE cReferences 				CHAR (250);

	DEFINE vcEmpresa		CHAR(3);
	DEFINE cAgent_cd		CHAR(3);
	DEFINE cUsuario			CHAR(8);
	DEFINE cPassword		CHAR(8);
	DEFINE cIp_origen		CHAR(15);
	DEFINE cId_sesion_act	CHAR(30);
	DEFINE cNombre_preceso	CHAR(17);
	DEFINE dtFecha_dia		DATE;
	DEFINE cOpcode			CHAR(5);
	DEFINE dFechaNueva 	 	CHAR(10);
	DEFINE cDia         	CHAR(2);
	DEFINE cMes         	CHAR(2);
	DEFINE cAnio        	CHAR(4);

	DEFINE cCodRet 			CHAR(4);
	DEFINE cCodRet1			CHAR(4);
	DEFINE VMRET1 			MONEY(16,2);
	DEFINE VMRET2 			MONEY(16,2);
	DEFINE VMRET3 			MONEY(16,2);
	DEFINE VMRET4 			MONEY(16,2);
	DEFINE VMRET5 			MONEY(16,2);
	DEFINE VMRET6 			MONEY(16,2);
	DEFINE VMRET7 			MONEY(16,2);
	DEFINE VMRET8 			MONEY(16,2);
	DEFINE VMRET9 			MONEY(16,2);

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

	DEFINE vcPrefijo		CHAR(3);
	DEFINE vcHHMMSSFolio	CHAR(12);
	DEFINE vcodretTemp    	CHAR(5);
    DEFINE vctranret   		CHAR(4);
	DEFINE vcusuario  		CHAR(8);
	DEFINE vdfechoy 		DATE;
	DEFINE vmsdodisp		MONEY(16,2);
	define vmontoret		MONEY(16,2);
	DEFINE vcTranAbonoCred 	CHAR(4);
	DEFINE P 				CHAR(4);
	DEFINE CTA 				CHAR(20);
	define cprueba 			char(20);
	DEFINE cTipotarjeta		CHAR(1);
	DEFINE cCveBanco        CHAR(3);
	DEFINE cTarjetaSub      CHAR(15);
	DEFINE cTarjetaConca    CHAR(16);
	DEFINE cDigValidador    CHAR(1);
	DEFINE ejec 			CHAR(250);		
	DEFINE cNombresp 		CHAR(30);
	DEFINE cNombresp1 		CHAR(30);
	DEFINE cNombresp2       CHAR(30);
	DEFINE cIni           CHAR(2);
	DEFINE cFi           CHAR(2);
    DEFINE cCreditoCebito   CHAR(2);
	DEFINE cCodigoRastreo CHAR (40);
	DEFINE cMerror			CHAR(200);
	DEFINE cCvecesif         CHAR(6);
	DEFINE cFlgSpei         CHAR(6);
	DEFINE cTelefono        CHAR(18);
	DEFINE cBandera        CHAR(10);

	---INICIALIZACION DE VARIABLES
	LET iSqlErr = 0;
	LET cReturnCode = '0';
	LET cErrorDescription = 'Consulta exitosa';
	LET cExternalTransactionId ='';
	LET cIdTransaccionReverso='00000';
	LET cReferences='value1,value2,value3';
	LET dFechaNueva   = DATE(1);

	LET cAgent_cd ='';
	LET cUsuario ='';
	LET cPassword ='';
	LET cIp_origeN ='';
	LET cId_sesion_act ='';
	LET cNombre_preceso = 'sp_abono_cta';
	LET dtFecha_dia   = CURRENT::DATE;
	LET cCodRet = '0000';
	LET cOpcode = '';
	LET cCodRet1='';

	LET vcSucursal='9747';
	LET vcTranccTemp='';
	LET	vcEmpresa='001';
	LET vcTransuc='';
	LET vcFolioSucCargo ='';
	LET vcNoCuentaOri ='';
	LET viCheque ='0';
	LET vmMonto =pcamount;
	LET vcDivisa =''   ;
    LET vcReferencia ='CREDIT TO BANK-TRANSFER';
    LET vcNoTarjeta ='';
	LET P='';
	let cTipotarjeta='';

	let vcodretTemp='1';
	LET vctranret='';
	LET vcUsuario ='informix';
	LET vcTranAbonoCred ='';
	LET CTA='';
	LET pcSystemDate=replace(pcSystemDate,'/','');
	let cprueba='';
	LET cCveBanco='';
	LET cDigValidador='';
	LET ejec='';
	LET cNombresp="abono_ref";
	LET cNombresp1="principal";
	LET cNombresp2='digver10';
	LET cIni= '';
	LET cFi='';
    LET cCreditoCebito='';
	LET cCodigoRastreo='';
	LET cMerror='';
	LET cCvecesif='';
	LET cFlgSpei='';
	LET cTelefono='';
	LET cBandera='No entro';
	
 --SET DEBUG FILE TO '/informix/ivega/sp_abono_cta.out';
 --TRACE ON;

     BEGIN
    -- 
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN--manejador de errores
			LET cCodRet = iSqlErr;
			LET cOpcode = cCodRet;
			LET cErrorDescription='Codigo no registrado en catalogo.';

			/*LET cDescr_mensaje = '';
			LET cDescr_completa_mensaje = '';

			--Se inserta el error generado en la tabla sac_ws_errores Y Se actualiza la tabla sac_ws_procesos con el codigo de error generado
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_preceso, cCodRet, cDescr_mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario, pcFecha_peticion, pcHora_peticion)
			INTO cCod_retorno;*/
		RETURN trim(cReturnCode), trim(cErrorDescription), trim(cExternalTransactionId), NVL(cCodigoRastreo,'');
		
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
		IF NVL(pcServiceName,'?')= '?' OR NVL(pcCountryCode,'?')= '?' OR NVL(pcAgent_cd,'?')= '?' OR NVL(pcUsuario,'?')= '?'
			OR NVL(pcBankId,'?')= '?' OR NVL(pcAccessMethod,'?')= '?'  OR NVL(pcAgent_trans_type_code,'?')= '?' OR NVL(pcPassword,'?')= '?'
		    OR NVL(pcIp_origen,'?')= '?' OR NVL(pcSession_id,'?')= '?'
			OR NVL(pcCurrency,'?')= '?' OR NVL(pcAmount,'?')= '?'
			OR NVL(pcBankDestAccount,'?')= '?' OR NVL(pcBankDestAccountType,'?')= '?'
			OR NVL(pcMpsTransactionId,'?')= '?' OR NVL(pcTransactionType,'?')= '?' THEN
			LET cReturnCode ='9996';
			LET cErrorDescription = "Error de parametros de entrada";


		ELSE
			IF EXISTS (SELECT transaccion FROM bdisac:"informix".sac_ws_transacc_ctes
			   WHERE agent_cd = pcAgent_cd AND transaccion = pcAgent_trans_type_code AND usuario = trim(pcusuario) AND activa = 'S' ) THEN

				--Se obtienen lo0s valores de lo0s campo0s, para la validacio0n de lo0s parametro0s de entrada
				SELECT agent_cd,usuario,password,ip_origen,id_sesion_act
				INTO cAgent_cd,cUsuario,cPassword,cIp_origen,cId_sesion_act
				FROM bdisac:"informix".sac_ws_clientes WHERE agent_cd = pcAgent_cd AND usuario = trim(pcusuario) and  fecha_insert = dtFecha_dia;

				IF  (pcBankId='002' or pcBankId='036' or pcBankId='012' or pcBankId='137')  THEN
					IF pcCountryCode='484' THEN
						IF	( pcSourceBankId='?' or pcSourceBankId='' or  pcSourceBankId='002' or pcSourceBankId='036' or pcSourceBankId='012' or pcSourceBankId='137' or pcSourceBankId='044') THEN
							IF pcAccessMethod='115' THEN
								IF pcCurrency='484' THEN
									IF (pcSourceAccountIdType='' or pcSourceAccountIdType='?' or pcSourceAccountIdType='101' OR pcSourceAccountIdType='102' OR pcSourceAccountIdType='103' OR pcSourceAccountIdType='104' or pcSourceAccountIdType='106') THEN

										IF (pcSourceAccountId ='?' 
											or pcSourceAccountId =''
											or (length(pcSourceAccountId)=12 and pcSourceAccountIdType='101')
											or (length(pcSourceAccountId)=12 and pcSourceAccountIdType='106')
											or (length(pcSourceAccountId)=18 and pcSourceAccountIdType='102')
											or (length(pcSourceAccountId)=16 and pcSourceAccountIdType='103')
											or (length(pcSourceAccountId)=11 and pcSourceAccountIdType='104'))	THEN
												let cprueba=pcSystemDate;
											IF (pcTransactionType='01' or pcTransactionType='02') THEN
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
																					
																					IF (pcBankDestAccountType='102' OR pcBankDestAccountType='104' OR pcBankDestAccountType='103') THEN
																						--CLABE
																						IF (pcBankDestAccountType='102' and length(pcBankDestAccount)=18) then
																									
																									
																									SELECT  {INDEX (bdicheq:"informix".sc_maechq ix174_4)} NVL(cuenta,'00000'),NVL(num_cte,'00000')
																									INTO CTA,vcNoCliente
																									FROM bdicheq:"informix".sc_maechq
																									WHERE empresa='001' AND status_cta=1 AND cuenta_clabe=pcBankDestAccount;
																									--WHERE --cuenta_clabe=pcBankDestAccount;
																									--status_cta=1 AND cuenta_clabe=pcBankDestAccount;
																									--WHERE empresa='001' AND cuenta_clabe=pcBankDestAccount;
																									-- empresa='001' AND status_cta=1 AND cuenta_clabe=pcBankDestAccount;--idx_maechqtrs
																																	
																									LET vcNoCuentaOri=CTA;
																						end if;
																						
																						IF (pcBankDestAccountType='103' and (length(pcBankDestAccount)=16 OR length(pcBankDestAccount)=15)) then
																							IF SUBSTR(pcBankDestAccount,1,2) = '37' THEN
																								LET cIni=1;
																								LET cFi= 2;
																							 ELSE
																								LET cIni=1;
																								LET cFi= 6;
																							 END IF;								 
																								--SE VERIFICA SI EL NUMERO DE TARJETA ES DE OTRO BANCO Y ES DE CREDITO
																								SELECT {INDEX (bdicheq:"informix".sc_bines i_bin_cd)} cve_banco,creditodebito INTO cCveBanco,cCreditoCebito
																								FROM bdicheq:"informix".sc_bines
																								WHERE bin = SUBSTR(pcBankDestAccount,cIni,cFi);
																								--AND creditodebito='c';
																								--TARJETAS DE OTROS BANCOS
																								
																						    IF (cCveBanco<>'137'AND NVL(cCveBanco,'')<>'') THEN
																							   IF SUBSTR(pcBankDestAccount,1,2) = '37' THEN
																									LET pcBankDestAccount = '0'||pcBankDestAccount;
																								END IF;

																							    LET cTarjetaSub = SUBSTR(pcBankDestAccount,1,15);    
																								--EXTRAE EL DIGITO VERIFICADOR DE LA TARJETA 
																								EXECUTE PROCEDURE bdicheq:"informix".digver10(cTarjetaSub)
																								INTO vcodretTemp,cDigValidador;
																		 			 	
																									LET ejec= 'digver10('||cTarjetaSub||')';
																									
																									INSERT INTO "informix".oterroresspext(transaccion,cod_error,mensaje_error,sp_llamado,usuario_transfer,ejecucionsp,fecha_insert)
																									VALUES(cNombre_preceso,vcodretTemp,'',cNombresp2,pcSourceAccountId,ejec,current); 																									
																										
																								IF vcodretTemp ::INTEGER != 0 THEN
																								
																									LET cReturnCode = '9996';
																									LET cErrorDescription = "Error al ejecutar digver10";
																									
																								ELSE
																								     
																								    LET cTarjetaConca = cTarjetaSub||cDigValidador;
																			                        
																									IF (cTarjetaConca = pcBankDestAccount) THEN
																									
																										IF(cCreditoCebito='c') THEN
																											--CUENTA ORIGEN 
																											SELECT valor
																											INTO vcNoCuentaOri  
																											FROM bdisac:"informix".sac_param 
																											WHERE cod_param = '33009'; 
																										END IF;

																									ELSE
																									
																										LET cReturnCode = '9996';
																										LET cErrorDescription = "El digito verificador de la tarjeta no es correcto";
																									
																									END IF;	
																								
																								END IF;																								
																						
																								
																							ELSE 
																									--TARJETA DEBITO																						
																									select creditodebito 
																									into ctipotarjeta
																									from intercard:"informix".bines 
																									where bin=substr(pcBankDestAccount,1,6);

																								IF (cTipotarjeta='D') THEN
																									
																									let vcNoTarjeta=pcBankDestAccount;
																							
																									SELECT NVL(cuenta,'00000') 
																									INTO cta 
																									FROM bdicheq:"informix".sc_tarjeta 			--TARJETA
																									WHERE num_tarjeta = vcNoTarjeta AND numcte = numcte  AND tipo_tarjeta = 'T';
														
																									LET vcNoCuentaOri=CTA;
																									
																								elif (cTipotarjeta='C') THEN
																								--TARJETA CREDITO		 
																									let vcNoTarjeta=pcBankDestAccount;
																																												
																									SELECT NVL(num_credito,'00000') 
																									INTO cta 
																									FROM bdicred:"informix".sd_tarjeta 			--TARJETA
																									WHERE num_tarjeta = vcNoTarjeta AND numcte = numcte  AND tipo_tarjeta = 'T';
																									
																									LET vcNoCuentaOri=CTA;
																								end if;
																							
																							END IF;
																							
																							
																						end if;
																						
																						
																						IF pcBankDestAccountType='104' and length(pcBankDestAccount)=11 then
																							--CUENTA DEBITO
																									SELECT NVL(num_cte,'00000') 
																									INTO vcNoCliente 
																									FROM BDICHEQ:"informix".SC_MAECHQ 			--CLIENTE
																									WHERE cuenta =pcBankDestAccount  AND num_cte = num_cte;

																									LET vcNoCuentaOri=pcBankDestAccount;
																						end if;			
																									
																						
																							--CUENTA CREDITO		
																						IF pcBankDestAccountType='104' and length(pcBankDestAccount)=12 then
																									
																									
																									SELECT NVL(numcte,'00000') 
																									INTO vcNoCliente 
																									FROM bdicred:"informix".SD_MAECRED 						--CLIENTE
																									WHERE num_credito = pcBankDestAccount AND numcte = numcte;

																									SELECT NVL(num_tarjeta,'00000') 
																									INTO vcNoTarjeta 
																									FROM bdicred:"informix".sd_tarjeta 			--TARJETA
																									WHERE num_credito = pcBankDestAccount AND numcte = trim(vcNoCliente)  AND tipo_tarjeta = 'T' AND status_tar = 'A';																									
																									LET vcNoCuentaOri=pcBankDestAccount;
																						end if;
																						
																							

																							IF SUBSTR(vcNoCuentaOri,1,1) in (1,2) and length(vcNoCuentaOri)=11 then
																							
																								SELECT NUMERO
																								INTO vcTranccTemp  
																								FROM bdinteg:"informix".si_transacc 
																								WHERE sistema = '01' AND NUMERO = '0205';
																								
																								LET vcTransuc=vcTranccTemp;
		
																								
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
																								execute Procedure bdicheq:"informix".sp_generafolionomina('TRANSFER')
																								into cCodRet1,vcFolioSucCargo;
		
																								EXECUTE PROCEDURE bdicheq:"informix".abono_ref(vcEmpresa, vcSucursal, vcUsuario, vcTranccTemp, vcTransuc, vcFolioSucCargo, vcNoCuentaOri, 0, vmMonto, vmMonto,0.00,0.00,0, vcDivisa, vcReferencia, nvl(vcNoTarjeta,'') , vcUsuario )
																								INTO vcodretTemp;
																						 																											
																									LET ejec= 'abono_ref('||vcEmpresa||''','''||vcSucursal||''','''||vcUsuario||''','''||vcTranccTemp ||''','''||vcTransuc||''','''||nvl(vcFolioSucCargo,'')||''','''||vcNoCuentaOri||''','''||'0'||''','''||vmMonto||''','''||vmMonto||''','''||'0'||''','''||'0'||''','''||'0'||''','''||vcDivisa||''','''||nvl(vcReferencia,'')||''','''||nvl(vcNoTarjeta,'')||''','''||vcUsuario||')';
																									
																									INSERT INTO "informix".oterroresspext(transaccion,cod_error,mensaje_error,sp_llamado,usuario_transfer,ejecucionsp,fecha_insert)
																									VALUES(cNombre_preceso,vcodretTemp,'',cNombresp,pcSourceAccountId,ejec,current);  
																									
																									IF vcodretTemp ::INTEGER != 0 THEN
																									
																										
																										LET cReturnCode = '9974';
																										LET cErrorDescription = "Error al ejecutar abono_ref/principal. Cuenta invalida";
																									ELSE
																																														
																											
																										LET cExternalTransactionId = vcFolioSucCargo;
																										IF cCodigoRastreo='' THEN
																													LET cBandera='11111';
																													SELECT  clave_rastreo 
																													INTO cCodigoRastreo
																													FROM  bdispei:tbldetranpago WHERE cuenta = pcSourceAccountId and monto_tot = pcAmount;
																										end if;
																										RETURN trim(cReturnCode), trim(cErrorDescription), trim(cExternalTransactionId), NVL(cCodigoRastreo,'');
																									END IF;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
																							elif SUBSTR(vcNoCuentaOri,1,1) in (6,7,8) and length(vcNoCuentaOri)=12 then
		
																								select transacc 
																								into vcTranccTemp 
																								from bdicred:"informix".sd_conceptospagomanual 
																								where codigo='30';
		
																								execute Procedure bdicheq:"informix".sp_generafolionomina('TRANSFER')
																								into cCodRet1,vcFolioSucCargo;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
																								EXECUTE PROCEDURE bdicred:"informix".principalrefer(vcEmpresa,vcNoCuentaOri , 1, vcNoTarjeta, vcUsuario, vcSucursal, Trim(vcFolioSucCargo),vcTranccTemp,0,vmMonto,vcReferencia)
																								INTO vcodretTemp, VMRET1, VMRET2, VMRET3, VMRET4, VMRET5, VMRET6, VMRET7, VMRET8, VMRET9;
		
																	
																									
																									LET ejec= 'principalrefer('||vcEmpresa||''','''||vcNoCuentaOri||''','''||'1'||''','''||nvl(vcNoTarjeta,'')||''','''||vcUsuario ||''','''||vcSucursal||''','''||nvl(vcFolioSucCargo,'')||''','''||vcTranccTemp||''','''||'0'||''','''||nvl(vmMonto,0)||''','''||nvl(vcReferencia,'')||')';
																									
																									INSERT INTO "informix".oterroresspext(transaccion,cod_error,mensaje_error,sp_llamado,usuario_transfer,ejecucionsp,fecha_insert)
																									VALUES(cNombre_preceso,vcodretTemp,'',cNombresp1,pcSourceAccountId,ejec,current); 
																									
																									IF vcodretTemp ::INTEGER != 0 THEN
																									
																										 
																									
																										LET cReturnCode = '9974';
																										LET cErrorDescription = "Error al ejecutar abono_ref/principal. Cuenta invalida";
																									ELSE
																										LET cExternalTransactionId = vcFolioSucCargo;
																										IF cCodigoRastreo='' THEN
																												LET cBandera='2222';
																												SELECT  clave_rastreo 
																												INTO cCodigoRastreo
																												FROM  bdispei:tbldetranpago WHERE cuenta = pcSourceAccountId and monto_tot = pcAmount and folio_suc = vcFolioSucCargo;
																											end if;
																										
																										
																										RETURN trim(cReturnCode), trim(cErrorDescription), trim(cExternalTransactionId), NVL(cCodigoRastreo,'');
																									END IF;
																									
																							--CUENTA CONCENTRADORA PAGO INTERBANCARIO TCD       																							
																							elif SUBSTR(vcNoCuentaOri,1,1)=9 and length(vcNoCuentaOri)=11  then
																									--TRANSACCION TEMP
																								SELECT valor 
																								INTO vcTranccTemp  
																								FROM bdisac:"informix".sac_param  
																								WHERE cod_param = '33011';	
																									--por el momento se pondra vcTranccTemp ='1195';
																									--LET vcTranccTemp='1195';
																									LET vcTransuc = vcTranccTemp;
																									LET vcNoTarjeta=pcBankDestAccount;
																									
																								EXECUTE PROCEDURE bdicheq:"informix".sp_generafolionomina('TRANSFER')
																								INTO cCodRet1,vcFolioSucCargo;
																									
																								EXECUTE PROCEDURE bdicheq:"informix".abono_ref(vcEmpresa,vcSucursal,vcUsuario,vcTranccTemp,vcTransuc,vcFolioSucCargo,vcNoCuentaOri,1,vmMonto,vmMonto,0,0,0,vcDivisa,vcNoTarjeta,0,vcUsuario)
																								INTO vcodretTemp;         
																								
																									LET ejec= 'abono_ref('||vcEmpresa||''','''||vcSucursal||''','''||vcUsuario||''','''||vcTranccTemp ||''','''||vcTransuc||''','''||nvl(vcFolioSucCargo,'')||''','''||vcNoCuentaOri||''','''||'1'||''','''||vmMonto||''','''||vmMonto||''','''||'0'||''','''||'0'||''','''||'0'||''','''||vcDivisa||''','''||nvl(vcNoTarjeta,'')||''','''||vcUsuario||')';
																	 								
																									INSERT INTO "informix".oterroresspext(transaccion,cod_error,mensaje_error,sp_llamado,usuario_transfer,ejecucionsp,fecha_insert)
																									VALUES(cNombre_preceso,vcodretTemp,'',cNombresp,pcSourceAccountId,ejec,current); 																									
																										
																										IF vcodretTemp ::INTEGER != 0 THEN
																										
																											LET cReturnCode = '9996';
																											LET cErrorDescription = "Error al ejecutar abono_ref / CUENTA CONCENTRADORA PAGO INTERBANCARIO TCD  ";
																										ELSE
																											LET cExternalTransactionId = vcFolioSucCargo;
																											IF cCodigoRastreo='' THEN
																												LET cBandera='3333';
																												SELECT  clave_rastreo 
																												INTO cCodigoRastreo
																												FROM  bdispei:tbldetranpago WHERE cuenta = pcSourceAccountId and monto_tot = pcAmount and folio_suc = vcFolioSucCargo;
																											end if;
																											
																											
																											RETURN trim(cReturnCode), trim(cErrorDescription), trim(cExternalTransactionId), NVL(cCodigoRastreo,'');
																										END IF;
																							--SPEI TARJETA DE DEBITO DE OTROS BANCOS  			
																							elif (cCveBanco<>'137'AND NVL(cCveBanco,'')<>'' AND cCreditoCebito='d') THEN
																						
																								
																								SELECT valor
																								INTO vcTranccTemp
																								FROM bdiprog:"informix".pp_parametros WHERE cve_param = '10';
																							
																								
																								SELECT  cvecesif,flg_spei INTO cCvecesif,cFlgSpei FROM  bdinteg:si_bancos WHERE  banco=cCveBanco;
																								
																								IF (cFlgSpei='1') THEN
																								
																								LET cBandera='44444';
																									SELECT telefono INTO cTelefono	FROM bditransfer:"informix".tf_maecte WHERE cuenta_tf=TRIM(pcSourceAccountId) AND status_cta=1;
																									
																									EXECUTE PROCEDURE bdicheq:"informix".sp_generafolionomina('TRANSFER')
																									INTO cCodRet1,vcFolioSucCargo;
																								
																									--EXECUTE PROCEDURE bdispei:sp_regordenpagospei_pp (vcEmpresa,vcUsuario,vcSucursal,vcFolioSucCargo,cCvecesif,TODAY,1,4,vmMonto,'SPEI TRANSFER',cTelefono,'XAXX010101000','SPEI TRANSFER',pcBankDestAccount,'XAXX010101000',0.00,0,'','Transfer-Anonimo','','','','','Transfer-Anonimo','0274',10,3) 
																									--INTO vcodretTemp,cMerror,cCodigoRastreo; 
																								
																									--LET ejec= 'sp_regordenpagospei_pp('||vcEmpresa||''','''||vcUsuario||''','''||vcSucursal||''','''||vcFolioSucCargo ||''','''||cCvecesif||''','''||TODAY||''','''||'1'||''','''||'4'||''','''||vmMonto||''','''||'SPEI TRANSFER'||''','''||cTelefono||''','''||'XAXX010101000'||''','''||'SPEI TRANSFER'||''','''||pcBankDestAccount||''','''||'XAXX010101000'||''','''||'0.00'||''','''||'0'||''','''||''||''','''||'Transfer-Anonimo'||''','''||''||''','''||''||''','''||''||''','''||''||''','''||'Transfer-Anonimo'||''','''||'0274'||''','''||'10'||''','''||'3'||')';
																									--cTipobenef = 3 (TTD)
																									--cTipoord = 10 (MOVIL)
																									EXECUTE PROCEDURE bdispei:"informix".sp_regordenctecte_pp(vcEmpresa,vcSucursal,vcUsuario,cCvecesif ,vmMonto,vcTranccTemp,vcFolioSucCargo,TODAY,0.00,0.00,'SPEI TRANSFER',10,trim(cTelefono),'XAXX010101000',TRIM('Anonimo Transfer'),3,pcBankDestAccount,'XAXX010101000','Transfer Anonimo',
																									0.00 ,0,nvl(pcReferences,''))
																									INTO vcodretTemp,cMerror,cCodigoRastreo; 
																								
																								
																									/*SELECT valor 
																									INTO vcTranccTemp  
																									FROM bdisac:"informix".sac_param  
																									WHERE cod_param = '33011';	
																									--por el momento se pondra vcTranccTemp ='1195';
																									--LET vcTranccTemp='1195';
																									LET vcTransuc = vcTranccTemp;
																									LET vcNoTarjeta=pcBankDestAccount;
																									
																									EXECUTE PROCEDURE bdicheq:"informix".abono_ref(vcEmpresa,vcSucursal,vcUsuario,vcTranccTemp,vcTransuc,vcFolioSucCargo,vcNoCuentaOri,1,vmMonto,vmMonto,0,0,0,vcDivisa,vcNoTarjeta,0,vcUsuario)
																									INTO vcodretTemp; */ 
																									
																									LET ejec= 'sp_regordenctecte_pp('||vcEmpresa||''','''||vcSucursal||''','''||vcUsuario||''','''||cCvecesif ||''','''||vmMonto||''','''||'0000'||''','''||vcFolioSucCargo||''','''||TODAY||''','''||0.00||''','''||0.00||''','''||'SPEI TRANSFER'||''','''||10||''','''||cTelefono||''','''||'XAXX010101000'||''','''||'Anonimo Transfer'||''','''||3||''','''||pcBankDestAccount||''','''||'XAXX010101000'||''','''||'Transfer-'||''','''||0.00||''','''||0||''','''||pcReferences||')';
																									--LET ejec= 'abono_ref('||vcEmpresa||''','''||vcSucursal||''','''||vcUsuario||''','''||vcTranccTemp ||''','''||vcTransuc||''','''||nvl(vcFolioSucCargo,'')||''','''||vcNoCuentaOri||''','''||'1'||''','''||vmMonto||''','''||vmMonto||''','''||'0'||''','''||'0'||''','''||'0'||''','''||vcDivisa||''','''||nvl(vcNoTarjeta,'')||''','''||vcUsuario||')';
																							
																									INSERT INTO "informix".oterroresspext(transaccion,cod_error,mensaje_error,sp_llamado,usuario_transfer,ejecucionsp,fecha_insert)
																									VALUES(cNombre_preceso,vcodretTemp,'','sp_regordenctecte_pp',pcSourceAccountId,ejec,current); 
																									
																									
																									
																										IF vcodretTemp ::INTEGER != 0 THEN
																											LET cCodigoRastreo = '';
																											LET cReturnCode = '9996';
																											LET cErrorDescription = 'Error al al generar el SPEI parametro invalido '||cMerror;
																										ELSE
																											LET cExternalTransactionId = cCodigoRastreo;
																											IF cCodigoRastreo='' THEN
																												LET cBandera='55555';
																												SELECT  clave_rastreo 
																												INTO cCodigoRastreo
																												FROM  bdispei:tbldetranpago WHERE cuenta = pcSourceAccountId and monto_tot = pcAmount and folio_suc = vcFolioSucCargo;
																											end if;
																											
																											RETURN trim(cReturnCode), trim(cErrorDescription), trim(cExternalTransactionId), NVL(cCodigoRastreo,'');
																										END IF;	
																								ELSE
																									LET cReturnCode = '9996';
																									LET cErrorDescription = "Error cFlgSpei el banco no puedo realizar spei";
																								END IF;
																							ELSE
																								LET cReturnCode = '9996';
																								LET cErrorDescription = "Error al ejecutar Cuenta Invalida";
																							END IF;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
																						
																					ELSE
																						LET cReturnCode ='9996';
																						LET cErrorDescription = " Error de parametros de entrada. BankDestAccountType";
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
												LET cErrorDescription = " Error de parametros de entrada. TransactionType";
											END IF;
										ELSE
											LET cReturnCode ='9996';
											LET cErrorDescription = " Error de parametros de entrada. SourceAccountId";
										END IF;
									ELSE
										LET cReturnCode ='9996';
										LET cErrorDescription = " Error de parametros de entrada. SourceAccountIdType";
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
							LET cErrorDescription = " Error de parametros de entrada. SourceBankId";
						END IF;
					ELSE
						LET cReturnCode ='9996';
						LET cErrorDescription = " Error de parametros de entrada. CountryCode";
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
		
				IF cCodigoRastreo='' THEN
				LET cBandera='7777777';
			SELECT  clave_rastreo 
			INTO cCodigoRastreo
			 FROM  bdispei:tbldetranpago WHERE cuenta = pcSourceAccountId and monto_tot = pcAmount and folio_suc = vcFolioSucCargo;
		end if;

	RETURN trim(cReturnCode), trim(cErrorDescription), trim(cExternalTransactionId), NVL(cCodigoRastreo,'');

	END;
END PROCEDURE
DOCUMENT
'AUTOR: 96103817, Carlos Andres Crespo',
'DESCRIPCION: Realiza abono a una TDC desde tranfer o un abono a tarjeta de debito ',
'FECHA: 29/08/2014',
'SOLICITO:Manuel Osuna',
'RQI 63 070 WS-PUB Transfer ',
'BD: BDITRANSFER';

CREATE PROCEDURE "informix".sp_cons_cte_transfer_web(pEmpresa CHAR(3), 
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
					LET cCodRet = '00623';
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
'SUSTENTO: Asigna_Tarjeta.pdf, Reposicion_Tarjeta.pdf, EliminaciÃ³n de tarjeta.pdf',
'SOLICITA: Rodolfo Gomez',
'00001: falta un parametro obligatorio',
'623: no se emcontro el cliente transfer',
'BD: bditransfer';

CREATE PROCEDURE "informix".sp_generaredoctaeje_factelect_transfer_esp(pEmpresa char(3))
RETURNING CHAR(5);
    
    DEFINE vcSql                    CHAR(600);
    DEFINE vcStmt                   CHAR(250);
    DEFINE vcodret                  CHAR(5);
    DEFINE vNum_Tarjeta             CHAR(16);
    DEFINE vdescripcion             CHAR(180);
    DEFINE vSucursal_nombre         CHAR(40);
    DEFINE vexiste_genedoctaeje     CHAR(3);
    DEFINE vcortSig                 CHAR(255);
    DEFINE vDireccion_del           CHAR(120);
    DEFINE vEdo_cd                  CHAR(120);
    DEFINE cErrorInfo               CHAR(80);
    DEFINE vErrorInfo               CHAR(80);
    DEFINE vaniomes                 CHAR(6);
    DEFINE vcodretDet               CHAR(6);
    DEFINE vcodretEnc               CHAR(6);
    DEFINE vmin_aniomes             CHAR(6);
    DEFINE vmax_aniomes             CHAR(6);
    DEFINE vmin_cta                 CHAR(20);
    DEFINE vmax_cta                 CHAR(20);
    DEFINE vMensajeProducto         CHAR(255);
    DEFINE vPiePagina               CHAR(255);
    DEFINE bInicia                  BOOLEAN;
    DEFINE iIsamErr                 SMALLINT;
    DEFINE vsdocuenta               MONEY(14,2);
    DEFINE vdeposito                MONEY(14,2);
    DEFINE vretiro                  MONEY(14,2);
    DEFINE vTasaBruta               DECIMAL(9, 6);
    DEFINE vGAT                     DECIMAL(9, 6);
    DEFINE vIvaOtrosCargos          DECIMAL(18,2);
    DEFINE vInteresesNetos          DECIMAL(18,2);
    DEFINE vInteresesPagados        DECIMAL(18,2);
    DEFINE vOtrosCargos             DECIMAL(18,2);
    DEFINE vRetencionIsr            DECIMAL(18,2);
    DEFINE vTotRetirosEfec          DECIMAL(18,2);
    DEFINE vTotOtrosCargos          DECIMAL(18,2);
    DEFINE vcortSig2                INTEGER;
    DEFINE vsecuencia               INTEGER;
    DEFINE vnlinea                  INTEGER;
    DEFINE vidreg                   INTEGER;
    DEFINE vsqlerr                  INTEGER;
    DEFINE visamerr                 INTEGER;
    DEFINE vultejec                 DATE;
    DEFINE vfecha_hoy               DATE;
    DEFINE vfecha_ant               DATE;
    DEFINE vfechaAlta               DATE;
    DEFINE vfechealt                DATE;
    DEFINE vFecha_emision           DATE;
    DEFINE vfechaFinal              DATE;
    DEFINE dFechaInicioMovimientos  DATE;
    DEFINE dFechaFinMovimientos     DATE;
    DEFINE dFechaEmision            DATE;
    DEFINE vsql                     CHAR(500);
    DEFINE vfecha                   CHAR(8);
    DEFINE vfechaproc               DATE;
	
    
	-- EMPIEZAN LAS VARIABLES DE LOS CAMPOS NUEVOS
	DEFINE vestado 			CHAR(50);
	DEFINE vciudad 			VARCHAR(60);  
	DEFINE vtelefono 		CHAR(14);
	DEFINE vgerente 		CHAR(40);
	DEFINE cNumProducto		CHAR(4);
	DEFINE vmensaje			CHAR(255);
	DEFINE vfechafin 		DATE;
	DEFINE vcuenta  		CHAR(20);
	DEFINE vnumcte			CHAR(20);
	DEFINE vnumctetf		CHAR(20);
	DEFINE vnombre_completo CHAR(150);
	DEFINE vdireccion  		CHAR(200);
	DEFINE vzona	   		CHAR(120);
	DEFINE vnomsuc     		CHAR(40);
	DEFINE vrfc				CHAR(13);
	DEFINE vrfc_alterno		CHAR(13);
	DEFINE vcp				CHAR(5);
	DEFINE vclabe			CHAR(60);
	DEFINE vcurp			CHAR(60);
	DEFINE valta_cte		DATE;
	DEFINE vfechaini		DATE;
	DEFINE vsucursal		CHAR(4);
	DEFINE vsdoant			DECIMAL(18,2);
	DEFINE vtotdep			DECIMAL(18,2);
	DEFINE vtotret			DECIMAL(18,2);
	DEFINE vsdoact			DECIMAL(18,2);
	DEFINE vsdoprom			DECIMAL(18,2);
	DEFINE vdias 			SMALLINT;
	DEFINE cMensajeProducto CHAR(255);  
	DEFINE vedosuc 			CHAR(4);
	DEFINE vcdsuc 			VARCHAR(60); 
	DEFINE vtel 			CHAR(14);
	DEFINE vdescrip     	CHAR(180);
	DEFINE vmonto 		 	MONEY(14,2);
	DEFINE vmontoRet 	 	MONEY(14,2);
	DEFINE vmontodep 	 	MONEY(14,2);
	DEFINE vsdoactual 	 	MONEY(14,2);
	DEFINE vcuantos  		INTEGER;
	DEFINE vcuantos2  		INTEGER;  
	DEFINE vconreg 			smallint;
    DEFINE viva      	 	MONEY(14,2);
	DEFINE vcomisiones 	 	MONEY(14,2);
	DEFINE votrocargos		MONEY(14,2);
    DEFINE vretiefect       MONEY(14,2);
    DEFINE vcorreo          CHAR(100);
	DEFINE vEnvioMovtos     SMALLINT;
	
	
	
---NUEVAS VARIABLES
	DEFINE vConfirmacion            CHAR(5);
	DEFINE vValor_tasa              DECIMAL(9, 6);
    DEFINE vValor_tasa_isr          DECIMAL(9, 6); 
	DEFINE vBaseisr                 MONEY (16,2);
	DEFINE vanio 					INTEGER;
	DEFINE vresiduo				    INTEGER;
	DEFINE vaniobase                INTEGER;
	DEFINE vbase_exenta             MONEY (16,2);
	DEFINE v_descuento              MONEY (16,2);
	DEFINE v_Subtotal				MONEY (16,2);
	DEFINE v_Total					MONEY (16,2);
	DEFINE v_secuencia              INTEGER;
	DEFINE v_tasa_isr               MONEY (16,2);
	DEFINE vfecha_ant_edo_cta       DATE;
	DEFINE vtpo_persona             CHAR(2); 
	DEFINE vNum_cte                 CHAR(20);
	DEFINE vres_iva_otros_cargos    DECIMAL(18,2);
	DEFINE ves_fisica               CHAR(1);
	DEFINE vexento_isr              CHAR(1); 
	DEFINE Vcodret_2                CHAR(5);
	
    LET vaniomes = "";                              
    LET vcodretDet = "";                        
    LET vcodretEnC = "";                          
    LET cErrorInfo ="";                          
    LET vErrorInfo = "INICIO DEL PROCESO";
    LET vcortSig2 = 0;                              
    LET vcortSig = "";                          
    LET vsecuencia = 0;
    LET vnlinea = 0;                                 
    LET vidreg = 0;                             
    LET vultejec = '';                   
    LET vsqlerr = 0;                            
    LET vdeposito = 0;
    LET vretiro = 0;                                
    LET vfechealt = "";                         
    LET vsdocuenta = 0;                                                 
    LET vcuenta = "";                                   
    LET vcodret = "00000";
    LET vfecha_hoy = "";                            
    LET vfecha_ant = "";                                                                                          
    LET bInicia = "F";                          
    LET iIsamErr = 0;
    LET vFecha_emision = "01-01-1900";                                    
    LET vNum_Tarjeta = "";
    LET vDireccion_del = "";                        
    LET vEdo_cd = "";                           
    LET vSucursal_nombre = "";                                       
    LET vrfc = "";
	LET vrfc_alterno ="";
    LET vCP = "";                                   
    LET vClabe = "";
    LET vCurp = "";                                                                                      
    LET vInteresesPagados = 0;                  
    LET vOtrosCargos = 0;                           
    LET vIvaOtrosCargos = 0;                                            
    LET vRetencionIsr = 0;    
    LET vTotRetirosEfec = 0;
    LET vTotOtrosCargos = 0;
    LET vInteresesNetos = 0;                                
    LET vTasaBruta = 0;     
    LET vGAT = 0;    
    LET vfechaFinal = "";                           
    LET vcSql = "";                             
    LET vcStmt = "";         
    LET vmin_cta = '';                              
    LET vmax_cta = '';
    LET dFechaInicioMovimientos = '01-01-1900';     
    LET dFechaFinMovimientos = '01-01-1900';    
    LET dFechaEmision = '01-01-1900';  
    LET vMensajeProducto = '';
    LET vPiePagina = ""; 
    LET vsql = '';
    LET vfecha = '';
    LET vfechaproc = '';
	LET Vcodret_2 = ''; 
    
    -- EMPIEZAN LAS VARIABLES DE LOS CAMPOS NUEVOS
	LET vestado 	 = "";
	LET vciudad 	 = "";
	LET vtel 		 = "";
	LET vgerente 	 = "";
	LET cNumProducto = "";
	LET vmensaje 	 = '';
	LET vdescrip     = "";     
	LET vmonto 		 = 0;
	LET vmontoRet 	 = 0;
	LET vmontodep 	 = 0;
	LET vsdoactual 	 = 0;
	LET vcdsuc		 = "";
	LET vcuantos	 = 0;
	LET vcuantos2	 = 0;
	LET vnumctetf 	 = "";
	LET vnumcte 	 = "";
	LET viva   		 = 0;
	LET vcomisiones	 = 0;
	LET votrocargos	 = 0;
	LET vretiefect	 = 0;
    LET vcorreo      = '';
	LET vEnvioMovtos = 0;
	
	
	
	---NUEVAS VARIABLES
	LET vConfirmacion =  " ";
	LET vValor_tasa   =  0;
	LET vBaseisr      =  0.0;
	LET vaniobase     =  365;
	LET v_descuento   =  0.00;
	LET v_Subtotal    =  0.00;
	LET v_Total	      =  0.00;
	

    BEGIN
    
    ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
        IF vsqlerr != 0 THEN
            SET DEBUG FILE TO "/resplogifx/conciliachq/edoctacfd/sp_generaredoctaeje_factelect_transfer.err";
            TRACE ON;
            LET vcodret = vsqlerr;
            LET vErrorInfo = cErrorInfo;
            IF bInicia = "T" THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodRet;
        END IF;
    END EXCEPTION;
    
     ---SET DEBUG FILE TO "/resplogifx/conciliachq/TRANSFER.TXT";
     ---TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    IF pEmpresa IS NULL  THEN
        LET vcodret = '00001';
        RETURN vcodret;
    END IF; 
    
    -- // Obtener la fecha de ayer y hoy
    SELECT pri_dia_mes - 1 units day, fecha_hoy,fecha_ant
      INTO vfecha_ant, vfecha_hoy,vfecha_ant_edo_cta
      FROM bdicheq:sc_fechas
     WHERE empresa = pEmpresa;
	 
	 
      -- SE OBTIENE EL MONTO EXENTO
	  SELECT valor::INT
	    INTO vbase_exenta 
        FROM bdicheq:sc_param
       WHERE empresa = '001'
         AND codparam ='baseexenta';
	  

	  -- // CALCULA ANIOBASE
	  
	  LET vanio    = YEAR(vfecha_hoy);
      LET vresiduo =  MOD(vanio, 4);
	  
      IF vresiduo  = 0 THEN 
         LET vaniobase = 366;
      END IF;
	  

	   
	    --SE OBTIENE EL ANIO MES 		
	  LET v_secuencia  =  year(vfecha_ant_edo_cta)||lpad(month(vfecha_ant_edo_cta),2,"0");
	 

	 
	-- // Armar la fecha de emision
	LET dFechaEmision = vfecha_ant;
    
	--RETENCION ISR
	LET  vRetencionIsr  = 0;
	
		  -- // CARGA TABLA CON CUENTAS POR PROCESAR
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'ctasxprocesar_tranf') THEN
        DROP TABLE "informix".ctasxprocesar_tranf;
    END IF;
	
	CREATE TABLE "informix".ctasxprocesar_tranf( cuenta char(20) not null )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idxtmp_ctasxprocesar_cuenta_tr ON "informix".ctasxprocesar_tranf(cuenta) USING BTREE;
	
	    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/cuentasxprocesar_tr.unl INSERT INTO ctasxprocesar_tranf" > /resplogifx/conciliachq/ctasxproc_tr.sql';
        SYSTEM vsql;
        LET vsql = '';
       
        LET vsql = '/ifxsif01/bin/dbaccess bditransfer /resplogifx/conciliachq/ctasxproc_tr.sql'; 
        SYSTEM vsql;
        LET vsql = '';
		

		FOREACH WITH HOLD 
			SELECT tf.periodo_fin, tf.cuenta, TRIM(NVL(TRIM(tf.nombre), "")||' '||NVL(TRIM(tf.ape_paterno), "")||' '||NVL(TRIM(tf.ape_materno), "")), 
                   TRIM(NVL(TRIM(tf.calle), "")||' '||NVL(TRIM(tf.no_ext), "")||' '||NVL(TRIM(tf.no_int), "")), tf.colonia, tf.municipio, tf.ent_federativa,
                   tf.cod_postal, tf.clabe , tf.curp, tf.fecha_apert, tf.periodo_ini, LPAD (TRIM(tf.sucursal),4,'0'), tf.saldo_ini, tf.abonos_sum,
                   tf.cargos_sum, tf.saldo_fin, tf.saldo_prom,  tf.diasperiodo,  (tf.sv_tici - tf.at_tisi) as iva,tf.monto_efectivo, tf.comisiones_sum, 
                   ( tf.cargos_sum - tf.monto_efectivo) as otrocargo, tf.email,mae.numcte
			  INTO vfechafin, vcuenta, vnombre_completo,
                   vdireccion, vzona, vciudad, vestado, 
                   vcp, vclabe, vcurp, valta_cte, vfechaini,  vsucursal, vsdoant, vtotdep, 
                   vtotret, vsdoact, vsdoprom, vdias, viva, vretiefect, vcomisiones, votrocargos, vcorreo, vNum_cte
			  FROM bditransfer:tf_resumen_edocta tf, 
                   bditransfer:tf_maecte mae 
			 WHERE tf.periodo_fin =  dFechaEmision
			   AND tf.integridad = 'V'
			   AND tf.cuenta = mae.cuenta_tf
			   AND tf.cuenta IN ( SELECT cuenta FROM ctasxprocesar_tranf )  
			   AND tf.cuenta NOT IN ( SELECT ee.num_cuenta
                                         FROM bdicheq:sc_encabezado_edocta_factelect ee
                                        WHERE ee.num_cuenta = tf.cuenta
                                          AND ee.fechafinal = tf.periodo_fin)
			  
			  
			
            SELECT rfc, numcte, numcte_tf         	
			  INTO vrfc, vnumcte, vnumctetf
			  FROM bditransfer:tf_maecte
			 WHERE cuenta_tf = vcuenta;
			
			IF vnumcte IS NOT null THEN
                SELECT rfc, rfc_alterno, envio_movtos
				  INTO  vrfc, vrfc_alterno, vEnvioMovtos
				  FROM bdinteg:si_cliente 
				 WHERE numcte = vnumcte;
							
				IF vrfc_alterno IS NOT null THEN
                    LET vrfc = vrfc_alterno;
				END IF
			END IF
			
			BEGIN WORK;
			LET bInicia = "T";
					
			LET vsucursal = '5001';
			
			SELECT nombre, estado,  ciudad, telefono1, gerente
			  INTO vnomsuc, vedosuc, vcdsuc , vtel, vgerente
			  FROM bdinteg:si_sucursales 
			 WHERE sucursal = vsucursal;
			
			SELECT nombre 
			  INTO vcdsuc
			  FROM bdinteg:si_ciudades 
			 WHERE estado = vedosuc  
			   AND ciudad = vcdsuc;   
			
			SELECT siglas 
			  INTO vedosuc
			  FROM bdinteg:si_estados 
			 WHERE estado = vedosuc;
			
			SELECT LIMIT 1 TRIM(producto) || ' ' || TRIM(nombre) AS producto
			  INTO vMensajeProducto
			  FROM bdicheq:sc_producto 
			 WHERE empresa = '001'
			   AND producto = '8000';
			  
			-- mensaje para sc_piepagina_edocta_factelect
			SELECT LIMIT 1 mensaje
			  INTO vPiePagina
			  FROM bdicheq:sc_mensajes_producto
			 WHERE producto = '8000'
			   and secuencia = '1';
			 
			-- se obtiene el numero de tarjeta
		   SELECT LIMIT 1 tar.num_tarjeta 
			  INTO vNum_Tarjeta
			  FROM bdicheq:sc_tarjeta tar
			 WHERE tar.cuenta = vcuenta
			   AND tar.status_tar = 'A'
			   AND tar.tipo_tarjeta = 'T';
			-- *********** TERMINA PARTE DE TRANSFER ****** --
					 
			-- // Ejecutar el store para llenar el encabezado
			SELECT NVL(MAX(idreg), 0) + 1
			  INTO vidreg
			  FROM bdicheq:sc_encabezado_edocta_factelect;
			 
			-- // Hacer las inserciones si el resultado del SP_generarEdoCtaejeencabezado_factelect fue satisfactorio
			IF ( vrfc IS NULL OR vnombre_completo IS NULL OR vfechaini IS NULL OR vfechafin IS NULL ) THEN
				LET vcodret = '00001'; 
				RETURN vcodret;
			END IF;
			
			IF vEnvioMovtos = 1 THEN
				LET vcorreo = vcorreo;
            ELSE
                LET vcorreo = '';
            END IF;
			
			LET vcorreo = NVL(vcorreo,'');

			
			IF vRetencionIsr > 0 THEN
			
			   --OBTIENE LA TASA-ISR
                SELECT first 1 tasa_isr
                  INTO v_tasa_isr
                  FROM bdicheq:sc_isr 
                 WHERE cuenta    = vcuenta
                   AND secuencia = v_secuencia
                   AND tasa_isr > 0;
				   
				   
				   IF v_tasa_isr IS NULL  THEN 
			           LET v_tasa_isr = 0;
			       END IF;
                   
                --TASA ISR 			
                LET vValor_tasa = TRUNC(((v_tasa_isr / 100 ) *  vdias) / vaniobase,6 ); 
			
		
                SELECT tpo_persona
                  INTO vtpo_persona
                  FROM bdinteg:si_cliente
                 WHERE numcte = vNum_cte;

                SELECT es_fisica, exento_isr
                  INTO ves_fisica, vexento_isr
                  FROM bdinteg:si_tipper
                 WHERE tpo_persona = vtpo_persona;

                IF vexento_isr = 'N' THEN
                   IF ves_fisica = 'S' THEN
				      IF  vsdoprom > vbase_exenta THEN 
			              LET vBaseisr = vsdoprom - vbase_exenta;
					      LET vValor_tasa_isr = vValor_tasa;
				      ELSE
                          LET vBaseisr = 0;
                          LET vValor_tasa_isr = 0.0;
					  END IF;
                   ELSE
				   	  LET vBaseisr = vsdoprom;
					  LET vValor_tasa_isr = vValor_tasa;
				   END IF;
				ELSE   
                    LET vBaseisr = 0;
                    LET vValor_tasa_isr = 0.0;
                END IF;					
			ELSE  	  
			    LET vBaseisr = 0.0; 
                LET vValor_tasa_isr = 0.0;
			END IF;  

				
			-- INICIALIZAMOS LA VARIABLE v_descuento
			LET v_descuento = 0.0;	
			
				
			IF viva = 0 AND vRetencionIsr > 0 THEN 
			   LET v_descuento = 0.00;
			END IF;  
			
			
			IF vcomisiones = 0 AND viva = 0 AND vRetencionIsr = 0 THEN 
			   LET v_descuento = 0.01;
			END IF; 
			
			
			IF viva > 0 AND vRetencionIsr > 0 THEN  
			   LET v_descuento = 0.00;
			END IF; 
			
			
			IF viva > 0 AND vRetencionIsr =  0 THEN  
			   LET v_descuento = 0.00;
			END IF; 

			--DETERMINA EL TOTAL
			LET v_Subtotal =  ( vcomisiones + v_descuento + vRetencionIsr );
			--DETERMINA EL SUBTOTAL
			LET v_Total    =  ( vcomisiones + viva );
			
			--VALIDA EL VALOR DE LAS COMISIONES	
			LET vres_iva_otros_cargos = 0;
			LET vres_iva_otros_cargos = TRUNC((vcomisiones * .16 ),2);
			
			IF vres_iva_otros_cargos <> viva THEN 
			   LET vcomisiones = TRUNC((viva /.16),2); 
            ELSE 
               LET vcomisiones = vcomisiones;
            END IF; 
				
			IF trim(vcodret) = '00000' THEN 
                INSERT INTO bdicheq:sc_encabezado_edocta_factelect
				(idreg, fecha_emision, num_cuenta, num_cte, num_tarjeta, nombre_cte, direccion_cte, direccion_col, direccion_del, edo_cd, cve_ruta, 
				 sucursal_nombre, rfc, cp, cve_ahorro, clabe, curp, fechaalta, fechainicio, mensajeproducto, inserto, fechafinal, sucursal, ciudad_suc, siglas_edo_suc, telefono_suc, gerente_suc, correo,confirmacion )
				VALUES
				(vidreg, dFechaEmision, vcuenta, vnumctetf, nvl (vNum_Tarjeta,''), vnombre_completo, vdireccion, vzona,vciudad, vestado, ' ', 
				 vnomsuc, vrfc, vcp, ' ', vclabe, vcurp, valta_cte,  vfechaini, vMensajeProducto, '000000000000000', vfechafin, vsucursal, vcdsuc, vedosuc, vtel, vgerente, vcorreo, vConfirmacion);
					
				 INSERT INTO bdicheq:sc_encabezado2_edocta_factelect
				 (idreg, fecha_emision, num_cuenta, saldoanterior, depositos, interesespagados, retiros, 
				  otroscargos, ivaotroscargos, saldocorte, saldopromedio, retencionisr, interesesnetos, dias,tasabruta, baseisr,tasaisr,descuento,subtotal,total)
				VALUES
				(vidreg, dFechaEmision, vcuenta, vsdoant, vtotdep, '0', vtotret,
				vcomisiones, viva, vsdoact, vsdoprom,vRetencionIsr, '0', vdias, '0',vBaseisr, vValor_tasa_isr,v_descuento,v_Subtotal,v_Total);

				LET vsecuencia = 1;
				LET vnlinea = 1;
					
				INSERT INTO bdicheq:sc_piepagina_edocta_factelect 
				(idreg, fecha_emision, num_cuenta, secuencia, nlinea, mensaje)
				VALUES
				(vidreg, dFechaEmision, vcuenta, vsecuencia, vnlinea, vPiePagina);
					
				FOREACH WITH HOLD -- PARA INSERTAR LAS TABLAS
					SELECT nlinea, mensaje, secuencia
					  INTO vnlinea, vmensaje, vsecuencia
					  FROM bdicheq:sc_mensajes_producto
					 WHERE producto = '8000'
					   AND secuencia IN('2','3','4','5','6','7','8')
							
                    IF   vsecuencia = 2 THEN LET vsecuencia = 1;
					ELIF vsecuencia = 3 THEN LET vsecuencia = 2;
					ELIF vsecuencia = 4 THEN LET vsecuencia = 3;
					ELIF vsecuencia = 5 THEN LET vsecuencia = 4; 
					ELIF vsecuencia = 6 THEN LET vsecuencia = 5; 
					ELIF vsecuencia = 7 THEN LET vsecuencia = 6; 
					ELIF vsecuencia = 8 THEN LET vsecuencia = 7; 
					END IF
							
					INSERT INTO bdicheq:sc_mensajes_edocta_factelect
					(idreg, fecha_emision, num_cuenta, secuencia, nlinea, mensaje)
					VALUES
					(vidreg, dFechaEmision, vcuenta, vsecuencia, vnlinea, vmensaje);
				END FOREACH 
					
				INSERT INTO bdicheq:sc_grafica_fe
				(id_reg, fecha_emision, num_cuenta, saldo_inicial, saldo_final, retiros_efectivo, depositos, intereses, comisiones, comisiones_iva, otros_cargos, gat)
				VALUES
				(vidreg, dFechaEmision, vcuenta, vsdoant, vsdoact, vretiefect, vtotdep, '0', vcomisiones, viva, votrocargos, '0');
			ELSE 
				ROLLBACK WORK;
				LET bInicia = "F";
				LET vcodret = '00003';
				RETURN vcodret;
			END IF;

			-- // Ejecutar store para el detalle
			LET vsecuencia = 0;
			LET vmontodep = 0;
			LET vmontoRet = 0;
			LET vsdoactual = vsdoact;
            
			FOREACH
				SELECT TRIM(NVL(TRIM(desc_mov1), "")||' '||NVL(TRIM(desc_mov2), "")||' '||NVL(TRIM(desc_mov3), "")), monto, fecha_mov    
				  INTO vdescrip, vmonto, vfechealt
				  FROM bditransfer:tf_detalle_edocta  
				 WHERE cuenta = vcuenta
				   AND periodo_fin = vfechafin
				 ORDER BY fecha_mov DESC, orden_mov::INTEGER DESC
					
				IF vmonto < 0 THEN
					LET vmontoRet = vmonto;
					LET vmontodep = 0;
					LET vmontoRet = vmontoRet * -1;
				ELSE
					LET vmontodep = vmonto;
					LET vmontoRet = 0;
				END IF						
								
				LET vsdoactual = vsdoactual - vmontodep + vmontoRet;
				LET vsecuencia = vsecuencia + 1;
				LET vnlinea = 0;
						
				-- // Cortar los detalles en lineas
				FOREACH 
					EXECUTE PROCEDURE bdicred:corta_linea(vdescrip, 40)
					INTO vcortSig, vcortsig2
                
					LET vnlinea = vnlinea + 1;
							
                    IF vnlinea > 1 THEN
						LET vfechealt = '01-01-1900';
								
						INSERT INTO bdicheq:sc_detalle_edocta_factelect
						(idreg, fecha_emision, num_cuenta, secuencia, nlinea, fechamov, descripcion, retiro, deposito, saldo)
						VALUES
						(vidreg, dFechaEmision, vcuenta, vsecuencia, vnlinea, vfechealt, vcortSig, '0.00', '0.00', '0.00');					
					ELSE
						INSERT INTO bdicheq:sc_detalle_edocta_factelect
						(idreg, fecha_emision, num_cuenta, secuencia, nlinea, fechamov, descripcion, retiro, deposito, saldo)
						VALUES
						(vidreg, dFechaEmision, vcuenta, vsecuencia, vnlinea, vfechealt, vcortSig, vmontoRet, vmontodep, vsdoactual);
					END IF;
				END FOREACH;
			END FOREACH;
				
			COMMIT WORK;
			LET bInicia = "F";        
		END FOREACH;
			
	    RETURN vcodret;
	
	
    END;
    
END PROCEDURE;