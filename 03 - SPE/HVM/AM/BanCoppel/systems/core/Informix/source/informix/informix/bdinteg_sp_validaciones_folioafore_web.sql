CREATE PROCEDURE "informix".sp_validaciones_folioafore_web(pEmpresa CHAR(3),pNumCte CHAR(20),pTipoTarj CHAR(1),pNumTarj CHAR(16),pNumCuenta CHAR(20))

RETURNING CHAR(6) AS cCodRet, CHAR(18) AS CURP, CHAR(13) AS RFC,CHAR(1) AS SEXO, DATE AS FECHANAC,CHAR(3) AS Nac;

--DEFINICION DE VARIABLES
DEFINE	iSqlErr	 	INTEGER;
DEFINE  iProcesa	SMALLINT;
DEFINE	cCodRet	 	CHAR(5);
DEFINE  cRfc		CHAR(13);
DEFINE  cRfc2		CHAR(10);
DEFINE	cCurp 		CHAR(18);
DEFINE	cCurp2 		CHAR(10);
DEFINE	cNac 		CHAR(3);
DEFINE	cStatus 	CHAR(2);
DEFINE	cSexo		CHAR(1);
DEFINE  dFechaNac	DATE;
DEFINE  dFechaHoy	DATE;
DEFINE  dFechaExpira	DATE;

--INICIALIZACION DE LAS VARIABLES
LET	iSqlErr 	= 0;
LET iProcesa	= 0;
LET cCodRet		= '00000';
LET cRfc		= '';
LET cRfc2		= '';
LET cCurp		= '';
LET cCurp2		= '';
LET cNac		= '';
LET cStatus		= '';
LET cSexo		= '';
LET dFechaHoy	= DATE(1);
LET dFechaNac	= DATE(1);
LET dFechaExpira	= DATE(1);

--SET DEBUG FILE TO '/dbexportb/ernestoaguilera/sp_validaciones_folioafore.out';
--TRACE ON;

BEGIN

	--CONTROL DE ERRORES DE INFORMIX
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET  cCodRet = iSqlErr;
			RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cCurp,'')),TRIM(NVL(cRfc,'')),TRIM(NVL(cSexo,'')),NVL(dFechaNac,DATE(1)),TRIM(NVL(cNac,''));
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	LET cCodRet = TRIM(cCodRet);
	LET cCurp = TRIM(cCurp);
	LET cRfc = TRIM(cRfc);
	LET cSexo = TRIM(cSexo);
	LET cNac = TRIM(cNac);
	
	--VALIDA ERRORES DE LOS PARAMETROS
	IF NVL(pNumCte,'') = ''  OR NVL(pTipoTarj,'') = '' OR NVL(pNumTarj,'') = '' OR NVL(pNumCuenta,'') = '' OR NVL(pTipoTarj,'') NOT IN ('C','D') THEN
		LET cCodRet = '00001';
		RETURN NVL(cCodRet,''),NVL(cCurp,''),NVL(cRfc,''),NVL(cSexo,''),NVL(dFechaNac,DATE(1)),NVL(cNac,'');
	END IF;

	--SELECCIONAMOS LA FECHA DEL DIA DE HOY
	SELECT fecha_hoy
	INTO dFechaHoy
	FROM "informix".si_fechas
	WHERE empresa = pEmpresa;

	--VALIDA SI LA CUENTA DE CAPTACION O ASOCIADA ESTA ACTIVA

	IF pTipoTarj = 'C' THEN
		
		LET iProcesa = 1;
		--VALIDA LA VIGENCIA DE LA TARJETA
		SELECT expiracion
		INTO dFechaExpira
		FROM bdicred: "informix".sd_tarjeta
		WHERE empresa = pEmpresa
		AND num_credito = pNumCuenta
		AND num_tarjeta = pNumTarj;

		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET iProcesa = 0;
			LET cCodRet = '00003';
			LET cCurp   = '';
		ELIF dFechaHoy >= dFechaExpira THEN
			LET iProcesa = 0;
			LET cCodRet = '00003';
			LET cCurp = 'Tarjeta Vencida';
		END IF;

		SELECT status_cred
		INTO cStatus
		FROM bdicred: "informix".sd_maecred
		WHERE empresa = pEmpresa
		AND numcte = pNumCte
		AND num_credito = pNumCuenta;
		--IFRS Se contemplan los nuevos estatus de crÃ©dito por Etapas
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET iProcesa = 0;
			LET cCodRet = '00002';
			LET cCurp   = '';
		ELIF NVL(cStatus,'') NOT IN ('AA','BA','BT','E1','E2','E3') THEN
			LET iProcesa = 0;
			LET cCodRet = '00002'; --LA CUENTA DE CREDITO NO ESTA ACTIVA
			LET cCurp = 'Credito inactivo';
		END IF;
		
	ELIF pTipoTarj = 'D' THEN
		
		LET iProcesa = 1;
		--VALIDA LA VIGENCIA DE LA TARJETA
		SELECT expiracion
		INTO dFechaExpira
		FROM bdicheq: "informix".sc_tarjeta
		WHERE empresa = pEmpresa
		AND cuenta = pNumCuenta
		AND num_tarjeta = pNumTarj;

		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET iProcesa = 0;
			LET cCodRet = '00003';
			LET cCurp   = '';
		ELIF dFechaHoy >= dFechaExpira THEN
			LET iProcesa = 0;
			LET cCodRet = '00003';
			LET cCurp = 'Tarjeta Vencida';
		END IF;

		SELECT status_cta
		INTO cStatus
		FROM bdicheq: "informix".sc_maechq
		WHERE empresa = pEmpresa
		AND num_cte = pNumCte
		AND cuenta = pNumCuenta;

		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET iProcesa = 0;
			LET cCodRet = '00002';
			LET cCurp   = '';
		ELIF NVL(cStatus,'') <> '1' THEN
			LET iProcesa = 0;
			LET cCodRet = '00002'; --LA CUENTA DE CAPTACION NO ESTA ACTIVA
			LET cCurp = 'Cta Cap inactiva';
		END IF;
		
	END IF;
	
	IF iProcesa = 1 THEN
		
		--CONSULTA DATOS DEL CLIENTE
		SELECT  CL.rfc,PF.fecha_nac, PF.sexo, PF.curp, PF.nacionalidad
		INTO cRfc,dFechaNac,cSexo,cCurp,cNac
		FROM si_cliente CL
		LEFT JOIN si_ctepf PF
		ON PF.numcte = CL.numcte
		WHERE CL.empresa = pEmpresa
		AND PF.empresa = CL.empresa
		AND CL.numcte = pNumCte;		
			
		LET cCurp2 = SUBSTR(TRIM(cCurp),1,10);
		LET cRfc2 = SUBSTR(TRIM(cRfc),1,10);
			
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00001';
			LET cCurp   = '';
			LET cRfc = '';
			LET cNac = '';
			LET cSexo = '';
			LET dFechaNac	= '';
		ELIF NVL(cCurp,'') = '' OR TRIM(cRfc2) <> TRIM(cCurp2) THEN
			LET cCodRet = '00001';
			LET cCurp = 'No existe Curp';
			LET cRfc = '';
			LET cNac = '';
			LET cSexo = '';
			LET dFechaNac	= '';			
		END IF;
	END IF;
	
	RETURN NVL(cCodRet,''),NVL(cCurp,''),NVL(cRfc,''),NVL(cSexo,''),NVL(dFechaNac,DATE(1)),NVL(cNac,'');
END;
END PROCEDURE
DOCUMENT
'AUTOR: 95281495 JesÃÂºs Ernesto Aguilera Inda.',
'DESCRIPCION: SP que valida que exista y sea correcta la CURP del cliente, ademas de validar que la cuenta de crÃÂ©dito o captaciÃÂ³n',
'sea la correcta. TambiÃÂ©n valida que la tarjeta no este vencida',
'FOLIO: 1629',
'FECHA: 28/07/2014',
'VERSION: 20140728.1700',
'BASE DE DATOS: bdinteg';

CREATE PROCEDURE "informix".sp_ws_afore_cntar(pcAgent_trans_type_code CHAR(10),
											  pcAgent_cd CHAR(3),
											  pcUsuario CHAR(8),
											  pcPassword CHAR(8),
											  pcIp_origen CHAR(15),
											  pcSession_id CHAR(30),
											  pcFecha_peticion CHAR(8),
											  pcHora_peticion CHAR(6),
											  pNumTarjeta CHAR(16))

RETURNING CHAR(5),CHAR(4),CHAR(100),CHAR(8),CHAR(6),CHAR(20),CHAR(940),CHAR(940);

--Definicion de Variables
DEFINE iSqlErr 			INTEGER;
DEFINE iIsamError 		INTEGER;
DEFINE vsMensaje        CHAR(200);
DEFINE cCodRet 			CHAR(5);
DEFINE cOpcode 			CHAR(4);
DEFINE cDescr_mensaje 	CHAR(255);
DEFINE cDescr_completa_mensaje 	CHAR(80);
DEFINE cNumCte			CHAR(20);
DEFINE cdMapa			CHAR(942);
DEFINE ciMapa			CHAR(942);
DEFINE cFecha_proceso 	CHAR(8);
DEFINE cHora_proceso 	CHAR(6);
DEFINE cCadena_ent		CHAR(100);
DEFINE cAgent_cd		CHAR(3);
DEFINE cUsuario			CHAR(8);
DEFINE cPassword		CHAR(8);
DEFINE cIp_origen		CHAR(15);
DEFINE cId_sesion_act	CHAR(30);
DEFINE cNombre_proceso	CHAR(17);
DEFINE cCod_retorno		CHAR(5);
DEFINE cBin 			CHAR(6);
DEFINE cCreditoDebito 	CHAR(1);
DEFINE dFechaHoy 		DATE;
DEFINE dExpiracion 		DATE;
DEFINE cStatusTarjeta 	CHAR(1);
DEFINE cCuenta 			CHAR(11);
DEFINE cCredito 		CHAR(12);
DEFINE cStatusCuenta 	CHAR(2);


DEFINE cFecha_dia		CHAR(8);
DEFINE dtFecha_dia		DATE;

DEFINE cProducto 		CHAR(4);
DEFINE cNumTarjeta 		CHAR(16);
DEFINE cFechaVenc 		CHAR(8);
DEFINE cTipoTarjeta		CHAR(1);

DEFINE cRdMapa			CHAR(1);
DEFINE cRiMapa			CHAR(1);


--Inicializacion de Variables
LET iSqlErr = 0;
LET iIsamError = 0;
LET cCodRet = '0000';
LET cOpcode = '';
LET cDescr_mensaje = '';
LET cDescr_completa_mensaje = '';
LET cNumCte = '';			
LET cdMapa = '';
LET ciMapa = '';

LET cFecha_proceso = trim(YEAR(CURRENT::DATE) || LPAD(MONTH(CURRENT::DATE),2,'0') || LPAD(DAY(CURRENT::DATE),2,'0'));

LET cHora_proceso = REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
LET cCadena_ent = TRIM(NVL(pcAgent_trans_type_code,'NULL')) || '|' || TRIM(NVL(pcAgent_cd,'NULL')) || '|' || TRIM(NVL(pcUsuario,'NULL')) || '|' || TRIM(NVL(pcIp_origen,'NULL'));
LET cAgent_cd = '';
LET cUsuario = '';
LET cPassword = '';
LET cIp_origen = '';
LET cId_sesion_act = '';
LET cNombre_proceso = 'sp_ws_afore_cntar';
LET cCod_retorno  = '';
LET cFecha_dia    = '';
LET dtFecha_dia   = CURRENT::DATE;
LET vsMensaje     = '';

LET cBin = '';
LET cCreditoDebito = '';
LET dFechaHoy = '';
LET dExpiracion = '';
LET cStatusTarjeta = '';
LET cCuenta = '';
LET cCredito = '';
LET cStatusCuenta = '';

LET cRdMapa = 'F';
LET cRiMapa = 'F';


BEGIN
	ON EXCEPTION SET iSqlErr,iIsamError,vsMensaje
		--SET DEBUG FILE TO '/tmp/sp_ws_afore_cntar.out';
		--TRACE ON;
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			LET cOpcode = cCodRet;

			LET cDescr_mensaje = '';
			LET cDescr_completa_mensaje = '';
			
			--Se obtienen los mensajes de error asi como el codigo del mensaje
			SELECT NVL(opcode, ''),NVL(opcode_sd, ''),NVL(opcode_ds, '')
			INTO cOpcode,cDescr_mensaje,cDescr_completa_mensaje
			FROM bdisac:"informix".sac_ws_catmensajes WHERE agent_trans_type_code = pcAgent_trans_type_code AND opcode = cCodRet;
			--En caso de que no exista el codigo del mensaje se les asigna otros valores
			IF cOpcode IS NULL THEN
				LET cOpcode = cCodRet;
				LET cDescr_mensaje = 'Codigo no registrado en catalogo.';
				LET	cDescr_completa_mensaje = 'Codigo no registrado en catalogo.';
			END IF;
			
			LET cNumCte ='';
			
			INSERT INTO bdinteg:"informix".si_ws_afore_cntar(agent_cd,user_request,password,ip_origen,id_sesion,date_request,time_request,num_tarjeta,opcode,descr_message,date_process,time_process,numcte,dmapa,imapa,datetimeinsert)
			VALUES (pcAgent_cd,pcUsuario,pcPassword,pcIp_origen,pcSession_id,pcFecha_peticion,pcHora_peticion,pNumTarjeta,cOpcode,cDescr_completa_mensaje,cFecha_proceso,cHora_proceso,cNumCte,cRdMapa,cRiMapa,current);

			RETURN LPAD(cCodRet,5,'0'),cOpcode,cDescr_completa_mensaje,cFecha_proceso,cHora_proceso,NVL(cNumCte,''),NVL(cDMapa,''),NVL(cIMapa,'');

		END IF;
	END EXCEPTION;

	--log
	--SET DEBUG FILE TO '/tmp/cristo/sp_ws_afore_cntar.out';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;


	--Se valida que alguno de los parametros de entrada no venga nulo

	IF NVL(pcAgent_trans_type_code, '') = '' OR NVL(pcAgent_cd, '') = '' OR NVL(pcUsuario, '') = '' OR NVL(pcPassword, '') = '' OR NVL(pcIp_origen, '') = '' OR NVL(pcSession_id, '') = '' OR NVL(pNumTarjeta, '') = '' OR NVL(pcFecha_peticion, '') = '' OR NVL(pcHora_peticion, '') = '' THEN
		LET cCodRet = '9996';

	ELSE
		IF EXISTS (SELECT transaccion FROM bdisac:"informix".sac_ws_transacc_ctes
				   WHERE agent_cd = pcAgent_cd AND transaccion = pcAgent_trans_type_code AND  usuario=trim(pcusuario) AND activa = 'S' ) THEN

			--Se obtienen lo0s valores de lo0s campo0s, para la validacio0n de lo0s parametro0s de entrada
			SELECT agent_cd,usuario,password,ip_origen,id_sesion_act
			INTO cAgent_cd,cUsuario,cPassword,cIp_origen,cId_sesion_act
			FROM bdisac:"informix".sac_ws_clientes WHERE agent_cd = pcAgent_cd and usuario=trim(pcusuario);

            SELECT fecha_hoy
            INTO dtFecha_dia
            FROM bdisac:"informix".sac_fechas
			where empresa = '001';

 			LET cFecha_dia = YEAR(dtFecha_dia) || LPAD(MONTH(dtFecha_dia),2,'0') || LPAD(DAY(dtFecha_dia),2,'0');

			IF cAgent_cd = pcAgent_cd THEN
				IF cUsuario = pcUsuario THEN
					IF cPassword = pcPassword THEN
						IF cIp_origen = pcIp_origen THEN
							IF cId_sesion_act = pcSession_id THEN
								IF LENGTH(TRIM(pNumTarjeta)) = 16 THEN
									--Se valida que la fecha sea correcta la del servidor
									IF pcFecha_peticion = cFecha_dia THEN
										SELECT NVL(opcode, ''),NVL(opcode_sd, ''),NVL(opcode_ds, '')
										INTO cOpcode,cDescr_mensaje,cDescr_completa_mensaje
										FROM bdisac:"informix".sac_ws_catmensajes
										WHERE agent_trans_type_code = pcAgent_trans_type_code AND opcode = cCodRet;

										IF cOpcode IS NULL THEN
											LET cOpcode = cCodRet;
											LET cDescr_mensaje = 'Codigo no registrado en catalogo.';
											LET cDescr_completa_mensaje = 'Codigo no registrado en catalogo.';
										END IF;
												
										-- Se debe verificar que la tarjeta de crÃÂ©dito o dÃÂ©bito pertenezca a  Bancoppel bdicheq:sc_bines.cve_banco='137'), tomando como referencia el bin de la tarjeta.
										SELECT fecha_hoy INTO dFechaHoy FROM bdinteg:"informix".si_fechas where empresa='001';
										LET cBin = SUBSTR(pNumTarjeta , 1 , 6);
										
										SELECT UPPER(creditodebito) INTO cCreditoDebito FROM bdicheq:"informix".sc_bines WHERE cve_banco = 137 AND bin = cBin ;
										
										IF dbinfo("sqlca.sqlerrd2") = 0 THEN
											LET cCodRet = '0002';
										END IF;
										
										IF cCodRet = '0000' THEN
											-- La fecha de expiraciÃÂ³n de la tarjeta sea vigente al momento de la consulta: dÃÂ©bito(bdicheq:sc_tarjeta.expiracion) o crÃÂ©dito(bdicred:sd_tarjeta.expiracion)
											-- La tarjeta debe estar activa: dÃÂ©bito(bdicheq:sc_tarjeta.status_tar) o crÃÂ©dito(bdicred:sd_tarjeta.status_tar)
											IF cCreditoDebito = 'D' THEN
												SELECT numcte,expiracion,status_tar,cuenta INTO cNumCte,dExpiracion,cStatusTarjeta,cCuenta 
												FROM bdicheq:"informix".sc_tarjeta WHERE num_tarjeta = pNumTarjeta;
												
												IF dbinfo("sqlca.sqlerrd2") = 0 THEN
													LET cCodRet = '0005';
												ELSE
													
													IF NVL(dExpiracion,'01/01/1900') < dFechaHoy THEN
														LET cCodRet = '0003';
													ELSE
														IF NVL(cStatusTarjeta,'') <> 'A' THEN
															LET cCodRet = '0004';
														ELSE 
															-- La tarjeta debe tener una cuenta relacionada: dÃÂ©bito(bdicheq:sc_tarjeta.cuenta)
															IF NVL(cCuenta,'') = '' THEN
																LET cCodRet = '0005';
															ELSE
																-- La cuenta relacionada de la tarjeta debe estar activa: dÃÂ©bito(bdicheq:sc_maechq.status_cta='1')
																SELECT status_cta INTO  cStatusCuenta FROM bdicheq:"informix".sc_maechq WHERE cuenta = cCuenta;
																IF TRIM(NVL(cStatusCuenta,'')) <> '1' THEN
																	LET cCodRet = '0006';
																END IF;
															END IF;
														END IF;
													END IF;
												END IF;
												
											ELIF cCreditoDebito = 'C' THEN
												SELECT numcte,expiracion,status_tar,num_credito INTO cNumCte,dExpiracion,cStatusTarjeta,cCredito FROM bdicred:"informix".sd_tarjeta WHERE num_tarjeta = pNumTarjeta;
												
												IF dbinfo("sqlca.sqlerrd2") = 0 THEN
													LET cCodRet = '0005';
												ELSE
													IF NVL(dExpiracion,'01/01/1900') < dFechaHoy THEN
														LET cCodRet = '0003';
													ELSE
														IF NVL(cStatusTarjeta,'') <> 'A' THEN
															LET cCodRet = '0004';
														ELSE 
															-- La tarjeta debe tener una cuenta relacionada: crÃÂ©dito(bdicred:sd_tarjeta.num_credito)
															IF NVL(cCredito,'') = '' THEN
																LET cCodRet = '0005';
															ELSE
																-- La cuenta relacionada de la tarjeta debe estar activa: crÃÂ©dito(bdicred:sd_maecred.status_cred='AA'
																SELECT nvl(status_cred,'') INTO  cStatusCuenta FROM bdicred:"informix".sd_maecred WHERE num_credito = cCredito;
																IF TRIM(cStatusCuenta) NOT IN ('AA','BA','BT','E1','E2','E3') THEN
																	LET cCodRet = '0006';
																END IF;
															END IF;
														END IF;
													END IF;
												END IF;
											END IF;
											
											IF (cCodRet = '0000') THEN											
												SELECT NVL(numcte,''),NVL(dmapa,''),NVL(imapa,'') INTO cNumCte,cDMapa, cIMapa 
												FROM bdinteg:"informix".si_cte_huella 
												WHERE numcte = cNumCte  AND estado = 'A' 
												AND  secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_cte_huella WHERE numcte = cNumCte);
												
												IF dbinfo("sqlca.sqlerrd2") = 0 THEN
													LET cCodRet = '0007';
												ELSE
													LET cRdMapa = 'V';
													LET cRiMapa = 'V';
												END IF;	
											END IF;	
											INSERT INTO bdinteg:"informix".si_ws_afore_cntar(agent_cd,user_request,password,ip_origen,id_sesion,date_request,time_request,num_tarjeta,opcode,descr_message,date_process,time_process,numcte,dmapa,imapa,datetimeinsert)
											VALUES (pcAgent_cd,pcUsuario,pcPassword,pcIp_origen,pcSession_id,pcFecha_peticion,pcHora_peticion,pNumTarjeta,cOpcode,cDescr_completa_mensaje,cFecha_proceso,cHora_proceso,cNumCte,cRdMapa,cRiMapa,current);
											
										END IF;
									ELSE
										LET cCodRet = '9977';
									END IF;
								ELSE
									LET cCodRet = '9995';
								END IF;
							ELSE
								LET cCodRet = '9975';
							END IF;
						ELSE
							LET cCodRet = '9976';
						END IF;
					ELSE
						LET cCodRet = '9979';
					END IF;
				ELSE
					LET cCodRet = '9980';
				END IF;
			ELSE
				LET cCodRet = '9998';
			END IF;
		ELSE
			LET cCodRet = '9999';
		END IF;
	END IF;
	
	IF cCodRet <> '0000' THEN
		--Se obtienen los mensajes de error asi como el codigo del mensaje
		SELECT NVL(opcode, ''),NVL(opcode_sd, ''),NVL(opcode_ds, '')
		INTO cOpcode,cDescr_mensaje,cDescr_completa_mensaje
		FROM bdisac:"informix".sac_ws_catmensajes WHERE agent_trans_type_code = pcAgent_trans_type_code AND opcode = cCodRet;
		--En caso de que no exista el codigo del mensaje se les asigna otros valores
		IF cOpcode IS NULL THEN
			LET cOpcode = cCodRet;
			LET cDescr_mensaje = 'Codigo no registrado en catalogo.';
			LET	cDescr_completa_mensaje = 'Codigo no registrado en catalogo.';
		END IF;
		
		LET cNumCte ='';
		INSERT INTO bdinteg:"informix".si_ws_afore_cntar(agent_cd,user_request,password,ip_origen,id_sesion,date_request,time_request,num_tarjeta,opcode,descr_message,date_process,time_process,numcte,dmapa,imapa,datetimeinsert)
		VALUES (pcAgent_cd,pcUsuario,pcPassword,pcIp_origen,pcSession_id,pcFecha_peticion,pcHora_peticion,pNumTarjeta,cOpcode,cDescr_completa_mensaje,cFecha_proceso,cHora_proceso,cNumCte,cRdMapa,cRiMapa,current);
		
	END IF;

	
	RETURN LPAD(cCodRet,5,'0'),cOpcode,cDescr_completa_mensaje,cFecha_proceso,cHora_proceso,NVL(cNumCte,''),NVL(cDMapa,''),NVL(cIMapa,'');
END;
END PROCEDURE;