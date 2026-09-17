CREATE PROCEDURE "informix".sp_cancelartokensucursal(pEmpresa CHAR(3), pNumCliente CHAR(9), pUsrAtendio CHAR(9), pCanal CHAR(2))

	RETURNING CHAR(5), CHAR(10)	

	-- DECLARA
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cNumCliente CHAR(9);
	DEFINE cSolicitud CHAR(10);
	DEFINE cToken CHAR(10);
	DEFINE cEstatusSol CHAR(3);
	DEFINE cEstatusToken CHAR(3);
	DEFINE cSucursalRegistra CHAR(4);
	DEFINE cFolioToken CHAR(25);
	DEFINE dF_Status DATE;
	DEFINE dF_Registro DATE;
	DEFINE cCodRet_Token CHAR(5);
	DEFINE cCodRet_Sol CHAR(5);
	DEFINE dFechaSol DATE;
        DEFINE dFecSol datetime year to second;

	-- INICIALIZA
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNumCliente = '';
	LET cSolicitud = '';
	LET cToken = '0000000000';
	LET cEstatusSol = '';
	LET cEstatusToken = '';
	LET cSucursalRegistra = '';
	LET cFolioToken = '';
	LET dF_Status = '01-01-1900';
	LET dF_Registro = '01-01-1900';
	LET cCodRet_Token = '00000';
	LET cCodRet_Sol = '00000';
	LET dFechaSol = '01-01-1900';
	LET dFecSol = current;

	--SET DEBUG FILE TO "/informix/gaby/ArchivosOut/sp_cancelartokensucursal.out";
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3; 
	SET ISOLATION TO DIRTY READ;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cToken;
			END IF;
		END EXCEPTION;

		IF(pNumCliente <> '' OR pNumCliente IS NOT NULL) THEN
			SELECT MAX(f_solicitud)
                        INTO dFecSol
			FROM bdibpi:"informix".bpi_tokensolicitud 
			WHERE numcte = pNumCliente;		
			
			SELECT TS.solicitud, TS.ns_token, TS.id_status, TK.id_status
			INTO cSolicitud, cToken, cEstatusSol, cEstatusToken
			FROM bdibpi:"informix".bpi_tokensolicitud AS TS, bdibpi:"informix".tkn_nseries AS TK
			WHERE TK.ns_token = TS.ns_token
			AND TS.f_solicitud = dFecSol
			AND TS.numcte = pNumCliente;

			IF(cSolicitud <> '' OR cSolicitud IS NOT NULL) THEN
				IF (cEstatusSol::INTEGER < 120) OR (cEstatusSol::INTEGER = 175) OR (cEstatusSol::INTEGER = 199)  THEN-- OR (cEstatusSol::INTEGER >= 300 AND cEstatusSol::INTEGER < 320) THEN
					LET cCodRet = '00006'; --No se puede cancelar el token				
				ELSE
					IF (cEstatusSol::INTEGER = 120) OR (cEstatusSol::INTEGER = 320) THEN
						EXECUTE PROCEDURE bdibpi:"informix".sp_set_solicitudstatus_admtoken(cSolicitud, pNumCliente, pUsrAtendio, cEstatusSol, '199') INTO cCodRet_Sol;
					END IF;

					IF (cCodRet_Sol::INTEGER = 0) THEN							
						SELECT num_cliente,suc_registro,folio_token ,f_status::DATE,f_registro::DATE
						INTO cNumCliente, cSucursalRegistra, cFolioToken, dF_Status, dF_Registro
						FROM bdinteg:"informix".si_bpitoken 
						WHERE empresa = TRIM(pEmpresa) 
						AND num_cliente = TRIM(pNumCliente) 
						AND ns_token = TRIM(cToken);

						IF(cNumCliente <> '' OR cNumCliente IS  NULL) THEN
							INSERT INTO bdinteg:"informix".si_bpitokenhis(empresa, num_cliente, ns_token, suc_registro, folio_token, id_status_token, f_status, f_registro)
								VALUES(pEmpresa, cNumCliente, cToken, cSucursalRegistra, cFolioToken, '199', dF_Status, dF_Registro);

							DELETE bdinteg:"informix".si_bpitoken WHERE empresa = TRIM(pEmpresa) AND num_cliente = TRIM(pNumCliente) AND ns_token = TRIM(cToken);

							EXECUTE PROCEDURE bdibpi:"informix".sp_set_statustoken_admtoken(cToken, cEstatusToken, '199', pUsrAtendio, pCanal) INTO cCodRet_Token;
							IF (cCodRet_Token <> '000') THEN
								LET cCodRet = '00005'; --Error al querer actualizar estatus del token en la BD bdibpi
							END IF;

                            EXECUTE PROCEDURE bdibpi:"informix".sp_set_solicitudstatus_admtoken(cSolicitud, pNumCliente, pUsrAtendio, cEstatusSol, '199') INTO cCodRet_Sol;
							IF (cCodRet_Sol <> '000') THEN
								LET cCodRet = '00007'; --Error al querer actualizar estatus de la solicitud en la BD bdibpi
							END IF;
							
							IF (SELECT COUNT(numcte) FROM  bdibpi:"informix".tkn_envios WHERE solicitud = cSolicitud AND numcte = pNumCliente) > 0 THEN
								UPDATE bdibpi:"informix".tkn_envios SET id_status = 199 WHERE solicitud = cSolicitud AND numcte = pNumCliente;
							END IF;
						ELSE
							LET cCodRet = '00004'; --No existe el cliente ne la bdinteg:si_bpicliente
						END IF
					ELSE
						LET cCodRet = '00003'; --Error al querer cancelar la solicitud
					END IF
				END IF
			ELSE
				LET cCodRet = '00002'; --Error al tratar de obtener datos de la solicitud
			END IF
		ELSE
			LET cCodRet = '00001'; --Error en parametros de entrada
		END IF;
		RETURN cCodRet, cToken;
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Cancela la el token, es decir elimina registro de la si_bpitoken, registra la informacion en la si_bpitokenhis',
'AUTOR: Francisco RodrÃ­guez Ibarra',
'FECHA: 04-10-2010',
'MODIFICO : SaÃºl Ivanhoe Valdespino HernÃ¡ndez',
'FECHA : 25/Enero/2011',
'DESCRIPCION: Se modifica para que al cancelar el token actualice las tablas: bpi_tokensolicitud, tkn_stasolicitud, tkn_envios',
'BD: bdibpi',
'Folio: 368.1 - RQI 03 639 Proceso OFI para ImplementaciÃ³n de Token Digital',
'ModificaciÃ³n: Se agregan los status 300 y 320 para la validaciÃ³n de token digital y se agrega una condiciÃ³n validando si exite el registro',
'en la tabla tkn_envios para poder actualizar el campo id_status = 199 al cliente correspondiente',
'ModificÃ³: IRMA URETA',
'Fecha: 08/02/2018',
'ModificaciÃ³n: Se quitan los status 300 y 320 para la validaciÃ³n de token digital y se quita la condiciÃ³n validando si exite el registro',
'en la tabla si_bpitoken',
'ModificÃ³: Gabriela Aguilar',
'Fecha: 29/04/2019',
'BD: bdibpi';

CREATE PROCEDURE "informix".sp_validaservicio_tkndig(pNumCliente CHAR(9))
   RETURNING CHAR(5) as cCodRet, CHAR (9) as vnumcte , CHAR(2) as vservicio , SMALLINT as bid_status,CHAR(10) as vsolicitud, SMALLINT as vid_status,CHAR(25) as vfolio_token,CHAR(12) as vns_token,CHAR(3) as vidstatustoken,INTEGER as vtkndig;

   --SE DEFINE VARIABLES
	DEFINE cCodRet 			CHAR(10);
	DEFINE iSqlErr 			INTEGER;
	DEFINE vnumcte 			CHAR (9);
	DEFINE vservicio 		CHAR(2);
	DEFINE vsolicitud		CHAR(10);
	DEFINE vid_status		SMALLINT;
	DEFINE bid_status		SMALLINT;
	DEFINE vfolio_token		CHAR(25);
	DEFINE vfolio_contr		CHAR(25);
	DEFINE vns_token		CHAR(12);
	DEFINE vidstatustoken	CHAR(3);
	DEFINE vtkndig			INTEGER;
	DEFINE dFecSol 			datetime year to second;
	--define csol				integer;
   
   --ASIGNACION DE VARIABLES
    LET cCodRet 		= '00000';
	LET iSqlErr 		= 0;
	LET vnumcte 		= '';
	LET vservicio 		= '';
	LET vsolicitud		= '';
	LET vid_status		= 0;
	LET bid_status		= 0;
	LET vfolio_token	= '';
	let vfolio_contr	= '';
	LET vns_token		= '';
	LET vidstatustoken	= '';
	LET vtkndig			= 0;
	--let csol 			= 0;
	LET dFecSol 	= current;
   
   
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, vnumcte, vservicio, bid_status, vsolicitud, vid_status, vfolio_token, vns_token, vidstatustoken, vtkndig;
			END IF;
		END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	SELECT numcte,servicio, id_status, folio_contrato
	INTO vnumcte, vservicio, bid_status, vfolio_contr
	FROM bdinteg:si_bpiusuarios  WHERE numcte=pNumCliente;
	
	
	IF vservicio=2 THEN
	
			--Obtener la solicitud mas reciente
			SELECT MAX(f_solicitud)
            INTO dFecSol
			FROM bdibpi:"informix".bpi_tokensolicitud
			WHERE numcte = pNumCliente
			AND id_status not in ('199','220');
				
			--Verifica la solicitud
			SELECT solicitud,id_status 
			INTO vsolicitud, vid_status 
			FROM bdibpi:bpi_tokensolicitud WHERE numcte = pNumCliente and id_status not in ('199','220')
			AND f_solicitud = dFecSol;
				
			--Verifica el token
			SELECT folio_token,ns_token,id_status_token ,tipo_token
			INTO vfolio_token, vns_token, vidstatustoken,vtkndig 
			FROM bdinteg:si_bpitoken WHERE num_cliente = pNumCliente and id_status_token not in ('199','220');
			
			IF vfolio_token = '' or vfolio_token is null THEN 
				LET vfolio_token = vfolio_contr;
			END IF;
		
			
			IF vtkndig = 1 THEN 
				IF vsolicitud <> '' AND vid_status <> '300' THEN 
					LET cCodRet = '00002';	 --USUARIO QUE TIENE SOLICITUD DE TOKEN FISICO ACTIVO
				END IF;	 
			ELSE	
				IF vtkndig=2 THEN
					IF vsolicitud <> '' AND vid_status = '300' THEN 
						LET cCodRet = '00000';	 --USUARIO QUE NO TIENE SOLICITUD DE TOKEN
					ELSE	
						LET cCodRet = '00001';	 --USUARIO TIENE SOLICITUD DE TOKEN
					END IF;
				ELSE 
					IF (vtkndig IS NULL OR vtkndig = '') THEN 
						IF  vid_status = '300' THEN 
							LET cCodRet = '00001';	 --USUARIO QUE NO TIENE SOLICITUD DE TOKEN  PERO TIENE REGISTROS
						ELSE
							LET cCodRet = '00002';	 --USUARIO QUE NO TIENE SOLICITUD DE TOKEN  PERO TIENE REGISTROS
						END IF; 
					END IF;
				END IF;
			END IF;	
			
	ELSE
			LET cCodRet = '00003' ; --ES SERVICIO BASICO
	END IF;

	RETURN cCodRet, vnumcte, vservicio, bid_status, vsolicitud, vid_status, vfolio_token, vns_token, vidstatustoken, vtkndig;
	
	END;
END PROCEDURE;