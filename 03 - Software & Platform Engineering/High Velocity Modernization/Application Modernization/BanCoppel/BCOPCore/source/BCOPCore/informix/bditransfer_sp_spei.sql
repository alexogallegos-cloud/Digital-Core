CREATE PROCEDURE "informix".sp_spei(pcAgent_trans_type_code CHAR(10),
									pcAgent_cd 				CHAR(6),
									pcUsuario 				CHAR(8),
									pcPassword 				CHAR(8),
									pcIp_origen 			CHAR(15),
									pcSession_id 			CHAR(30),
									pcServiceName 			CHAR(128),
									pcSystemDate 			CHAR(20),
									pcCountryCode 			CHAR(3),
									pcBankId 				CHAR(5),
									pcAccessMethod 			CHAR(3),
									pcCuentaCargo 			CHAR(18),
									pcCuentaAbono 			CHAR(18),
									pcNumCelular 			CHAR(12),
									pcBeneficiario 			CHAR(100),--optional
									pcRfcBeneficiario 		CHAR(13),--optional
									pcImporte 				DECIMAL(7,2),
									pcComision 				DECIMAL(7,2),
									pcIva 					DECIMAL(7,2),
									pcTasaIva 				DECIMAL(5,2),
									pcFolioMPS 				CHAR(30),
									pcTipoTransferencia 	CHAR(4),
									pcReferenciaNumerica 	CHAR(7),--optional
									pcReferenciaLeyenda 	CHAR(40),
									pcBankDest 				CHAR(3))--optional
						RETURNING
									CHAR (100) AS cReturnCode,
									CHAR (11) AS cFolioTransaccion,
									CHAR (40) AS cCodigoRastreo,
									CHAR (3) AS cdstBankid;

	---DECLARACION DE VARIABLES
	DEFINE iSqlErr  INTEGER;
	DEFINE cPCodRet CHAR(5);
	DEFINE cReturnCode CHAR (5);
	DEFINE cErrorDescription CHAR (100);
	DEFINE cFolioTransaccion CHAR (11);
	DEFINE cCodigoRastreo CHAR (40);
	DEFINE cCuentaCargo CHAR(18);

	DEFINE cAgent_cd		CHAR(3);
	DEFINE cUsuario			CHAR(8);
	DEFINE cPassword		CHAR(8);
	DEFINE cIp_origen		CHAR(15);
	DEFINE cId_sesion_act	CHAR(30);
	DEFINE cNombre_preceso	CHAR(17);
	DEFINE dtFecha_dia		DATE	;
	--DEFINE cFecha 		CHAR(8);
	--DEFINE cHora 			CHAR(6);
	DEFINE cCodRet 			CHAR	(4);
	DEFINE cCodRet1			CHAR	(4);

	DEFINE vcTranccTemp		CHAR	(4);
	DEFINE vcTransuc		CHAR	(4);
	DEFINE vcFolioSucCargo	CHAR	(16);
	DEFINE viCheque         CHAR	(4);
	DEFINE vmMonto          MONEY(16,2);
	DEFINE vcDivisa         CHAR	(4);
	DEFINE vcReferencia     CHAR	(20);
	DEFINE vcNoTarjeta      CHAR	(18);
	DEFINE vcSucursal		CHAR	(4);
	DEFINE vcNocliente    	CHAR	(10);


	DEFINE vcTansacc  		CHAR(4);
	DEFINE vcodretTemp    	CHAR(5);
    DEFINE vctranret   		CHAR(4);
	DEFINE vcusuario  		CHAR(8);
	DEFINE vdfechoy 		DATE;
	DEFINE vmsdodisp		MONEY(16,2);
	define vmontoret		MONEY(16,2);
	DEFINE vdFechaHoy 		DATE;
	DEFINE cTipoord			CHAR(2);
	DEFINE cTipobenef		CHAR(2);
	DEFINE cMerror			CHAR(200);
	DEFINE dFechaNueva 	 	CHAR(10);
	DEFINE cDia         	CHAR(2);
	DEFINE cMes         	CHAR(2);
	DEFINE cAnio        	CHAR(4);
	DEFINE cesif			CHAR(5);
	DEFINE cBanco			CHAR(3);
	DEFINE vcEmpresa 		CHAR(3);
	DEFINE vcFolioSucCargo1 CHAR(11);
	
	DEFINE ejec 			CHAR(250);		
	DEFINE cNombresp 		CHAR(30);
	
	DEFINE cdstBankid		CHAR(3);

	---INICIALIZACION DE VARIABLES
	LET iSqlErr = 0;
	LET cPCodRet = '';
	LET cReturnCode = '0';
	LET cErrorDescription = 'Consulta exitosa';
	LET cMerror = '';
	LET cFolioTransaccion ='';
	LET cCodigoRastreo='';
	LET dFechaNueva   = DATE(1);
	LET vdFechaHoy=CURRENT::DATE;
	LET pcSystemDate=replace(pcSystemDate,'/','');
	LET cAgent_cd ='';
	LET cUsuario ='';
	LET cPassword ='';
	LET cIp_origeN ='';
	LET cId_sesion_act ='';
	LET cNombre_preceso = 'sp_spei';
	LET dtFecha_dia   = CURRENT::DATE;
	LET cCodRet = '0000';
	LET cCodRet1='';
	/*LET cOpcode = '';
	LET cDescr_mensaje = '';
	LET cDescr_completa_mensaje = '';*/

	LET vcEmpresa='001';
	LET vcSucursal='9250';
	LET vcTranccTemp='';
	LET vcTransuc='0000';
	LET vcFolioSucCargo ='';
	LET vcFolioSucCargo1='';
	--TRIM(pcbankSourceAccount);
	LET viCheque ='0';
	LET vmMonto =pcImporte;
	LET vcDivisa =''   ;
    LET vcReferencia ='DEBIT TO BANK-TRANSFER';
    LET vcNoTarjeta ='';
	--TRIM(pcdestAccountId);
    LET vcUsuario ='informix';
	LET vcTansacc = '';
	let vcodretTemp='';
	LET vctranret='';
	LET cesif='';
	LET cBanco='';
	LET cCuentaCargo='';
	
	LET ejec='';
	LET cNombresp="regordenctecte";
	
	LET cdstBankid='';

	--SET DEBUG FILE TO '/informix/manuel/sp_spei2.out';
	--TRACE ON;

    BEGIN
    -- 
    ON EXCEPTION SET iSqlErr
        IF 	iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			let cErrorDescription='Codigo no registrado en catalogo.';
				RETURN trim(cCodRet)||"-"||trim(cErrorDescription), trim(cFolioTransaccion), cCodigoRastreo, cdstBankid;
		END IF;
    END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--LET cFecha = SUBSTR(pcSystemDate, 1, 8);
	--LET cHora = SUBSTR(pcSystemDate, 9, 6);

--	Se inserta el registro del proceso en curso
--	INSERT INTO bdisac:"informix".sac_ws_procesos(proceso,fecha_proceso,hora_proceso,estatus,cod_ret,user_insert,fecha_insert,hora_insert)
--	VALUES(cNombre_preceso,cFecha,cHora,'0','',pcUsuario,current::date,REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', ''));




--------------------VALIDACIÃN DE PARAMETROS-------------------------
--------------VALIDACIÃN DE PARAMETROS-------------------------
		IF (NVL(pcServiceName,'?')= '?' OR NVL(pcCountryCode,'?')= '?' OR NVL(pcAgent_cd,'?')= '?' OR NVL(pcUsuario,'?')= '?'
			OR NVL(pcBankId,'?')= '?' OR NVL(pcAccessMethod,'?')= '?'  OR NVL(pcAgent_trans_type_code,'?')= '?' OR NVL(pcPassword,'?')= '?'	
			OR NVL(pcIp_origen,'')='' OR NVL(pcSession_id,'')=''
			OR NVL(pcNumCelular,'?')= '?' OR NVL(pcImporte,'?')= '?'  OR NVL(pcComision,'?')= '?' OR NVL(pcIva,'?')= '?'
			OR NVL(pcTasaIva,'?')= '?' OR NVL(pcFolioMPS,'?')= '?' OR NVL(pcTipoTransferencia,'?')= '?' OR NVL(pcIp_origen,'?')= '?'
			OR NVL(pcCuentaAbono,'?')= '?' OR NVL(pcCuentaCargo,'?')= '?'  OR NVL(pcComision,'?')= '?' OR NVL(pcIva,'?')= '?'	)
			THEN
			LET cReturnCode ='9996';
			LET cErrorDescription = "Error de parametros de entrada";
				
		ELSE
			IF EXISTS (SELECT transaccion FROM bdisac:"informix".sac_ws_transacc_ctes
			   WHERE agent_cd = pcAgent_cd AND transaccion = pcAgent_trans_type_code AND usuario = trim(pcusuario) AND activa = 'S' ) THEN

				--Se obtienen lo0s valores de lo0s campo0s, para la validacio0n de lo0s parametro0s de entrada
				SELECT agent_cd,usuario,password,ip_origen,id_sesion_act
				INTO cAgent_cd,cUsuario,cPassword,cIp_origen,cId_sesion_act
				FROM bdisac:"informix".sac_ws_clientes WHERE agent_cd = pcAgent_cd AND usuario = trim(pcusuario) and fecha_insert = dtFecha_dia;


				IF pcImporte >0 THEN
					IF pcComision >=0	THEN
						IF pcIva >=0 THEN
							IF pcTasaIva >=0 THEN
								IF  (pcBankId='002' or pcBankId='036' or pcBankId='012' or pcBankId='137' or pcBankId='044' or pcBankId='40012')  then
									IF pcCountryCode='484'  then
										IF pcAccessMethod='115'  THEN
											IF length(pcFolioMPS)>=9 THEN
												IF length(pcNumCelular)=12 THEN
													IF (pcTipoTransferencia='SPEI') THEN
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

																							IF (length(pcCuentaCargo)=18 OR length(pcCuentaCargo)=11 OR length(pcCuentaCargo)=12) and
																							(length(pcCuentaAbono)=18 or length(pcCuentaAbono)=11 /*or length(pcCuentaAbono)=16*/ or length(pcCuentaAbono)=12)  THEN
																								
																								SELECT valor
																								INTO vcDivisa
																								FROM bdiprog:"informix".pp_parametros 
																								WHERE cve_param = '08';
																						
                                                                                                SELECT banco
                                                                                                INTO cdstBankid
                                                                                                FROM bdinteg:"informix".si_bancos
                                                                                                WHERE banco = substr(pcCuentaAbono, 0,3);

																								SELECT valor
																								INTO vcTansacc
																								FROM bdiprog:"informix".pp_parametros WHERE cve_param = '10';

																								
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
																								if (length(pcCuentaAbono)=18) THEN
																									LET ctipobenef=40;
																																																		
																									select cvecesif 
																									into cesif 
																									from bdinteg:"informix".si_bancos 
																									where banco=SUBSTR(pcCuentaAbono,1,3);
																								end if;
																								
																								if (length(pcCuentaCargo)=18) THEN
																									LET cTipoord=40;
																								end if;
																								
																								
																								if (length(pcCuentaAbono)=12) THEN
																									LET pcCuentaAbono=SUBSTR(pcCuentaAbono,3,10);
																									LET ctipobenef=10;
																									
																									select cvecesif 
																									into cesif 
																									from bdinteg:"informix".si_bancos 
																									where banco=trim(pcBankDest);
																								end if;
																								
																								
																								if (length(pcCuentaCargo)=12 OR length(pcCuentaCargo)=11) THEN
																									LET cTipoord=10;
																									
																									select telefono
																									into cCuentaCargo
																									from "informix".tf_maecte where cuenta_tf=trim(pcCuentaCargo) and status_cta=1;
																									
																									LET pcCuentaCargo=TRIM(cCuentaCargo);
																									
																								end if;
																							
																										execute Procedure bdicheq:"informix".sp_generafolionomina('TRANSFER')
																										into cCodRet1,vcFolioSucCargo;
																										
																										LET vcFolioSucCargo1='TRF'||SUBSTR(vcFolioSucCargo,9,8);
					
																										if (pcBeneficiario='' or pcBeneficiario='?') THEN
																											Let pcBeneficiario='Anonimo Transfer';
																										end if;
																										
																										if (pcRfcBeneficiario='' or pcRfcBeneficiario='?') THEN
																											Let pcRfcBeneficiario='XAXX010101000';
																										end if;
																									

																									EXECUTE PROCEDURE bdispei:"informix".sp_regordenctecte_pp(
																									vcEmpresa,vcSucursal,vcUsuario,cesif ,vmMonto,vcTansacc,vcFolioSucCargo1,vdFechaHoy,
																									0.00,0.00,'SPEI TRANSFER',cTipoord,trim(pcCuentaCargo),'XAXX010101000',TRIM(pcBeneficiario),
																									cTipobenef,pcCuentaAbono,trim(pcRfcBeneficiario),'Transfer'||'-'||nvl( pcReferenciaLeyenda,''),
																									0.00 ,0,nvl(pcReferenciaNumerica,''))
																									into cPCodRet,cMerror,cCodigoRastreo;
																										
																									LET ejec= 'regordenctecte_pp('||vcEmpresa||''','''||vcSucursal||''','''||vcUsuario||''','''||cesif ||''','''||vmMonto||''','''||vcTansacc||''','''||nvl(vcFolioSucCargo,'')||''','''||vdFechaHoy||''','''||'0.00,0.00,SPEI TRANSFER,'||''','''||cTipoord||''','''||trim(pcCuentaCargo)||''','''||'XAXX010101000'||''','''||TRIM(pcBeneficiario)||''','''||cTipobenef||''','''||pcCuentaAbono||''','''||trim(pcRfcBeneficiario)||''','''||nvl( pcReferenciaLeyenda,'')||''','''||'0.00 ,0'||''','''||nvl(pcReferenciaNumerica,'')||''','''||')';
																									
																									INSERT INTO "informix".oterroresspext(transaccion,cod_error,mensaje_error,sp_llamado,usuario_transfer,ejecucionsp,fecha_insert)
																									VALUES(cNombre_preceso,cPCodRet,cMerror,cNombresp,pcCuentaCargo,ejec,current);  
																									
																									IF cPCodRet ::INTEGER != 0 THEN
																										LET cReturnCode = '9996';
																										LET cErrorDescription = "Error al al generar el SPEI parametro invalido.";
																										LET cCodigoRastreo='';
																										RETURN trim(cReturnCode)||"-"||trim(cErrorDescription), trim(cFolioTransaccion), cCodigoRastreo , cdstBankid;
																									ELSE
																									LET  cFolioTransaccion=lpad(substr(vcFolioSucCargo,9,8),11,0);
																									END IF;

																							ELSE
																								LET cReturnCode = '300';
																								SELECT descripcion
																								INTO  cErrorDescription
																								FROM  bditransfer:"informix".tf_codret
																								WHERE cod_error = cReturnCode;
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
														LET cReturnCode ='9996';
														LET cErrorDescription = " Error de parametros de entrada. TipoTransferencia";
													END IF;
												ELSE
													LET cReturnCode ='9996';
													LET cErrorDescription = " Error de parametros de entrada. NumCelular";
												END IF;
											ELSE
												LET cReturnCode ='9996';
												LET cErrorDescription = " Error de parametros de entrada. FolioMPS";
											END IF;
										ELSE
											LET cReturnCode ='9996';
											LET cErrorDescription = " Error de parametros de entrada. AccessMethod";
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
								LET cReturnCode ='9996';
								LET cErrorDescription = " Error de parametros de entrada.TasaIva ";
							END IF;
						ELSE
							LET cReturnCode ='9996';
							LET cErrorDescription = " Error de parametros de entrada. Iva";
						END IF;
					ELSE
						LET cReturnCode ='9996';
						LET cErrorDescription = " Error de parametros de entrada.Comision ";
					END IF;
				ELSE
					LET cReturnCode ='9996';
					LET cErrorDescription = " Error de parametros de entrada. Importe ";
				END IF;
			ELSE
				LET cReturnCode ='9982';
				LET cErrorDescription = " Consulta no exitosa. TransacciÃ³n no definida.";
			END IF;
		END IF;


	RETURN trim(cReturnCode)||"-"||trim(cErrorDescription), trim(cFolioTransaccion), cCodigoRastreo, cdstBankid;

	END;
END PROCEDURE
DOCUMENT
'AUTOR: 96103817, Carlos Andres Crespo',
'DESCRIPCION: Realiza un spei desde transfer ',
'FECHA: 29/08/2014',
'SOLICITO:Manuel Osuna',
'RQI 63 070 WS-PUB Transfer ',
'BD: BDITRANSFER';

CREATE PROCEDURE "informix".sp_genera_bd_transfer()
RETURNING VARCHAR(5) AS CodRetorno, 
		  VARCHAR(200) AS Mensaje;
		  

/*DEFINICION DE VARIABLES */
DEFINE viSqlError         INTEGER;
DEFINE vsCodRetorno       VARCHAR (5);
DEFINE vsMensaje          VARCHAR(200);
DEFINE vdFechaHoy         DATE;
DEFINE pFecha             DATE;
DEFINE vsDia              VARCHAR(2);
DEFINE vsMes 		      VARCHAR(2);
DEFINE vsAnio 		      VARCHAR(2);

DEFINE vsNombre			  VARCHAR(35);
DEFINE vsApell_Pat		  VARCHAR(30);
DEFINE vsApell_Mat		  VARCHAR(30);
DEFINE vsNumeroCliente	  VARCHAR(12);
DEFINE vcCelular	      VARCHAR(10);
DEFINE vsAnioNac		  VARCHAR(10);
DEFINE vsMesNac		  	  VARCHAR(10);
DEFINE vsDiaNac		  	  VARCHAR(10);
DEFINE vsEstado			  VARCHAR(30);
DEFINE vsMunicipio		  VARCHAR(30);
DEFINE vsDiaApert    	  VARCHAR(10);
DEFINE vsMesApert    	  VARCHAR(10);
DEFINE vsAnioApert    	  VARCHAR(10);
DEFINE vcstatus_cta		  VARCHAR(5);
DEFINE vsCancelacion_cta  VARCHAR(10);
DEFINE vsUltima_trans	  VARCHAR(10);

DEFINE vsStmt1			  CHAR(1000);
DEFINE vsStmt2			  CHAR(1000);
DEFINE viRegistros 		  INTEGER;
--DEFINE vArch  			  INTEGER;
DEFINE vsDelimiter        VARCHAR(1);
DEFINE vsNombreArchivo    VARCHAR(50);
DEFINE visam_error		  INTEGER;
DEFINE isam_error      	  INTEGER;
DEFINE vsfechacomp		  VARCHAR(10);
DEFINE vsestatus_cta	  VARCHAR(100);
--DEFINE vsnum_cta		  VARCHAR(20);
DEFINE vsfech_registro	  VARCHAR(20);
DEFINE vsfech_registro2	  VARCHAR(20);
DEFINE vsAnio2 		      VARCHAR(4);
DEFINE vsMes2			  VARCHAR(30);
DEFINE vsMesAnt			  VARCHAR(2);


/*FIN DE DEFINICION DE VARIABLES*/
LET viSqlError = 0;
LET vsCodRetorno = '00000';
LET vsMensaje = '';
LET vdFechaHoy = today;
LET pFecha = today;
LET vsDia = '';
LET vsMes = '';
LET vsAnio = '';

LET vsNombre='';
LET vsApell_Pat='';
LET vsApell_Mat='';
LET vsNumeroCliente='';
LET vcCelular	   ='';
LET vsAnioNac	   ='';
LET vsMesNac	   ='';
LET vsDiaNac	   ='';
LET vsEstado	   ='';
LET vsMunicipio	   ='';
LET vsDiaApert ='';
LET vsMesApert ='';
LET vsAnioApert ='';
LET vcstatus_cta   ='';
LET vsCancelacion_cta='';
LET vsUltima_trans ='';

LET vsStmt1 = '';
LET vsStmt2 = '';
LET viRegistros = 0;
--LET vArch =0;
LET vsDelimiter= '';
LET vsNombreArchivo = '';
LET visam_error = 0;
LET isam_error = 0;
LET vsfechacomp = '';
LET vsestatus_cta = '';
--LET vsnum_cta = '';
LET vsfech_registro= '';
LET vsfech_registro2= '';
LET vsAnio2= '';
LET vsMes2= '';
LET vsMesAnt= '';

/*FIN DE INICIALIZACION*/

--SET DEBUG FILE TO "/informix/ragomez/sp_genera_bd_transfer.out";
--TRACE ON;

BEGIN
	
	
	SELECT current - 1 units month
	INTO vsMes2 
	FROM bdinteg:"informix".si_fechas;
	
	--LET vsMes2 = vdFechaHoy - 1 units month;
	
	--Obtiene fecha hoy
	LET vsDia =	substr(CAST(pFecha AS DATETIME YEAR TO FRACTION(5)),9,2);
	LET vsMes =	substr(CAST(pFecha AS DATETIME YEAR TO FRACTION(5)),6,2);
	LET vsAnio = substr(CAST(pFecha AS DATETIME YEAR TO FRACTION(5)),3,2);
	LET vdFechaHoy = pFecha;
	LET vsfechacomp = LPAD(YEAR(TODAY),4,'0')||'-'||LPAD(MONTH(TODAY),2,'0')||'-'||LPAD(DAY(TODAY),2,'0');
	
	LET vsMesAnt = substr(vsMes2 , 6,2);
	LET vsAnio2 = LPAD(YEAR(TODAY),4,'0');
	
	
	LET vsfech_registro = NVL(vsMesAnt,'01')||'-'||'01'||'-'||NVL(vsAnio2,'01');
	LET vsfech_registro2 = NVL(vsMes,'01')||'-'||'01'||'-'||NVL(vsAnio2,'01');
	
	
	IF (vsCodRetorno='00000') THEN
	
	TRUNCATE "informix".tf_user_transfer_tmp;
	
	  INSERT INTO "informix".tf_user_transfer_tmp SELECT {+INDEX(tf_user_transfer,idx_cta_fecha_tf_user)} cuenta,MAX(fecha_corte) AS fecha_corte, MAX(consecutivo) AS consecutivo 
	  FROM "informix".tf_user_transfer
	  /*WHERE fecha_corte::date >=vsfech_registro AND fecha_corte::date <= vsfech_registro2*/ GROUP BY cuenta;
  			
				--Nombre del archivo
		LET vsNombreArchivo = 'BD_TRANSFER'||'_'|| NVL(vsDia,'01') || NVL(vsMes,'01') || NVL(vsAnio,'01')||'.csv';
		
		LET vsStmt1 =  'Nombre'||','||'Apell_Pat'||','||'Apell_Mat'||','||'Cuenta'||','||'Celular'||','||'Año_Nac'||','
						||'Mes_Nac'||','||'Dia_Nac'||','||'Estado'||','||'Municipio'||','||'Dia_Aper'||','||'Mes_Aper'||','||'Año_Aper'||','
						||'Estatus'||','||'Fecha_Cancelacion'||','||'Ult_Transaccion';
						INSERT INTO bdimnsj:"informix".mnsj_susc_paso (linea)
						VALUES (vsStmt1);
		
		SET LOCK MODE TO WAIT 3;
		
		FOREACH	WITH HOLD
			
			SELECT {+INDEX(tf_user_transfer,idx_cta_fecha_tf_user)} SUBSTR(nom_cliente,0,(INSTR(nom_cliente, '/',0))-1) AS nombre, 
													SUBSTR(nom_cliente,(INSTR(nom_cliente, '/',0)+1),(INSTR(nom_cliente, ',',0)-1) - (INSTR(nom_cliente, '/',0))) AS apellido1, 
													SUBSTR(nom_cliente,(INSTR(nom_cliente, ',',0)+1)) AS apellido2,
													a.numcte,a.telefono,
													SUBSTR(fecha_nac,7,4) as anio_nac , SUBSTR(fecha_nac,0,2) as mes_nac, SUBSTR(fecha_nac,4,2) as dia_nac,
													trim(b.estado) as estado,a.poblacion,
													SUBSTR(fecha_alta,4,2) as dia_alta , SUBSTR(fecha_alta,0,2) as mes_alta, SUBSTR(fecha_alta,7,4) as anio_alta,
													a.status_cta,a.fecha_baja,a.fecha_ult_transac 
			INTO vsNombre,vsApell_Pat,vsApell_Mat,vsNumeroCliente,vcCelular,vsAnioNac,vsMesNac,vsDiaNac,vsEstado,vsMunicipio,vsDiaApert,vsMesApert,vsAnioApert,vcstatus_cta,vsCancelacion_cta,vsUltima_trans
			FROM "informix".tf_user_transfer AS a
			JOIN tf_entidadfed_rpt AS b
			ON a.estado = b.id
			JOIN tf_user_transfer_tmp AS c
			ON  c.numcte = a.cuenta AND c.fecha_corte::date = a.fecha_corte::date AND c.consecutivo = a.consecutivo
			/*WHERE a.fecha_corte::date >= vsfech_registro AND a.fecha_corte::date <= vsfech_registro2*/
			
			
      
			IF (vcstatus_cta='20') THEN
					
				LET vsestatus_cta ='PRE-ACTIVA';
				LET vsCancelacion_cta='';
					
			ELIF (vcstatus_cta= '30') THEN
						
				LET vsestatus_cta ='ACTIVA';
				LET vsCancelacion_cta='';
				
						
			ELIF (vcstatus_cta= '40') THEN
						
				LET vsestatus_cta ='PENDIENTE DE RETIRO';
				LET vsCancelacion_cta='';

							
			ELIF (vcstatus_cta= '50') THEN
								
				LET vsestatus_cta ='CANCELADA';
								
							
			ELIF (vcstatus_cta='60') THEN
								
				LET vsestatus_cta ='DORMANT';
				LET vsCancelacion_cta='';
				
			ELSE 
									
				LET vsestatus_cta ='BLOQUEADA';
				LET vsCancelacion_cta='';
				
			END IF;
				
					LET vsStmt2 =  trim(vsNombre)||','||trim(vsApell_Pat)||','||trim(vsApell_Mat)||','||trim(vsNumeroCliente)||','||trim(vcCelular)||','||trim(vsAnioNac)||','
								   ||trim(vsMesNac)||','||trim(vsDiaNac)||','||trim(vsEstado)||','||trim(vsMunicipio)||','||trim(vsDiaApert)||','||trim(vsMesApert)||','||trim(vsAnioApert)||','
								   ||trim(vsestatus_cta)||','||trim(vsCancelacion_cta)||','||trim(vsUltima_trans);
					INSERT INTO bdimnsj:"informix".mnsj_susc_paso (linea)
					VALUES (vsStmt2);
						--LET vArch = vArch +1;
						LET viRegistros = viRegistros +1;
		END FOREACH; 
		
         
		IF viRegistros > 0 THEN
			EXECUTE PROCEDURE bdimnsj:"informix".sp_generaarch_transfer(vsNombreArchivo,vsDelimiter) INTO vsCodRetorno;
				IF vsCodRetorno <> '00000' THEN
					INSERT INTO bdimnsj:"informix".mnsj_errores (sql_error,isam_error, descripcion, origen_error, fecha, fecha_insert)
					VALUES (vsCodRetorno,visam_error, vsMensaje, 'sp_generaarch', vdFechaHoy,CURRENT);
					LET vsMensaje = 'Error en la generacion de archivo';	
				END IF;
		END IF;
			
		IF vsCodRetorno = '00000' THEN
			LET vsMensaje  = 'REPORTE GENERADO CORRECTAMENTE';
		
			UPDATE bdimnsj:"informix".mnsj_procesos set status = '1' WHERE proceso = 'BD_TRANSFER'
			and fecha_proceso = vdFechaHoy;				
		END IF;		
	END IF;
	RETURN vsCodRetorno, vsMensaje;
END;
END PROCEDURE;