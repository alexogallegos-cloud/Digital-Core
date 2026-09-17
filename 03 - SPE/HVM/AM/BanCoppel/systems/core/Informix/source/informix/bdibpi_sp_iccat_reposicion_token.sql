CREATE PROCEDURE "informix".sp_iccat_reposicion_token(pEmpresa CHAR(3),pNumCliente CHAR(9),pUsrAtendio CHAR(9))
RETURNING CHAR(5)
	--------------------------------------------------------
	--15-11-2013
	--Realizo: Jose Ruben Lopez
	--Realiza el proceso para reposicion del token
	--Solicito:Jose de Jesus Nevarez
	--BD: bdibpi
	--------------------------------------------------------
DEFINE cCod_Ret           CHAR(5);
DEFINE iSqlErr            INTEGER;
DEFINE iSamErr            INTEGER;
DEFINE vDesErr            CHAR(60);
DEFINE vNumCte			  CHAR(9);
DEFINE vNsToken   		  CHAR(10);
DEFINE vSucRegistro		  CHAR(4);
DEFINE vFolioToken	      CHAR(25);
DEFINE vIdStatusToken	  CHAR(4);
DEFINE vFechaStatus		  DATE;
DEFINE vFechaRegistro     DATE;
DEFINE tipoSol			  CHAR(2);
DEFINE vNuevoNsToken	  CHAR(10);
DEFINE cCodRet_Token	  CHAR(5);
DEFINE vEstatusNuevoToken CHAR(4);
DEFINE vVencidoNsToken	  CHAR(10);
DEFINE vEstatusVencidoToken CHAR(4);
DEFINE cCodRet_Sol		  CHAR(5);
DEFINE vNumSol			  CHAR(10);
DEFINE vEstatusSolicitudAnt CHAR(4);
DEFINE vFechaUltimoSt     CHAR(25);
DEFINE v_transaccion 		CHAR(1);
DEFINE vregistros			CHAR(2);


LET vNumCte='';
LET vNsToken='';
LET vSucRegistro='';
LET vFolioToken='';
LET vIdStatusToken='';
LET vFechaStatus='01-01-1900';
LET vFechaRegistro='01-01-1900';
LET cCod_Ret='00000';
LET cCodRet_Token='00000';
LET vEstatusNuevoToken='';
LET vVencidoNsToken='';
LET vEstatusVencidoToken='';
LET cCodRet_Sol='';
LET vNumSol='';
LET vEstatusSolicitudAnt = '';
LET v_transaccion	=	'0';
LET vregistros = '0';

LET iSqlErr=0;
LET iSamErr=0;
LET vDesErr='';

--SET DEBUG FILE TO "/tmp/sp_iccat_reposicion_token.out";
--TRACE ON;

BEGIN
    ON EXCEPTION
        SET iSqlErr, iSamErr, vDesErr
        IF iSqlErr <> 0 THEN
            LET cCod_Ret = iSqlErr;
        END IF;
        RETURN cCod_Ret;
    END EXCEPTION;
	

	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	
	--Se valida que el cliente no tenga una registro en la tabla si_bpitokenhis con el numero de token a cancelar por caducidad
	SELECT COUNT(*)	
	INTO vregistros
	FROM bdinteg:"informix".si_bpitokenhis 
	WHERE num_cliente=pNumCliente 
	AND ns_token=(SELECT ns_token FROM bdinteg:"informix".si_bpitoken WHERE num_cliente=pNumCliente);
	
	
	IF vregistros > 0 THEN
            LET cCod_Ret = '00005'; --ya existe un registro del cliente con el numero de token a cancelar.
			RETURN cCod_Ret;			
    END IF;
	
		SELECT num_cliente,ns_token,suc_registro,folio_token,id_status_token,f_status,f_registro
		INTO vNumCte,vNsToken,vSucRegistro,vFolioToken,vIdStatusToken,vFechaStatus,vFechaRegistro
		FROM bdinteg:"informix".si_bpitoken
		WHERE num_cliente=pNumCliente;
		
		IF (NVL(vNumCte,'') <>'')THEN
				INSERT INTO bdinteg:"informix".si_bpitokenhis(empresa,num_cliente,ns_token,suc_registro,folio_token,id_status_token,f_status,f_registro) 
				VALUES(pEmpresa,vNumCte,vNsToken,vSucRegistro,vFolioToken,vIdStatusToken,vFechaStatus,vFechaRegistro);
				
				UPDATE bdinteg:"informix".si_bpitokenhis SET id_status_token='220', f_status=CURRENT
				WHERE num_cliente=pNumCliente
				AND ns_token=vNsToken;
				
				--SE OBTIENE EL NUEVO TOKEN
				SELECT ns_token,id_status
				INTO vNuevoNsToken,vEstatusNuevoToken
				FROM bdibpi:"informix".bpi_tokensolicitud
				WHERE numcte=pNumCliente
				AND id_status='120'
				AND tipo IN('6','7');
				
				UPDATE bdinteg:"informix".si_bpitoken SET ns_token=vNuevoNsToken,id_status_token='210',f_registro=CURRENT,f_status=CURRENT
				WHERE num_cliente=pNumCliente;
				
				--Se actualiza el nuevo token repuesto
				UPDATE bdibpi:"informix".tkn_tokenexpira SET ns_token=vNuevoNsToken WHERE numcte=pNumCliente AND ns_token=vNsToken; 
				
				EXECUTE PROCEDURE  bdibpi:"informix".sp_set_statustoken_admtoken(vNuevoNsToken,vEstatusNuevoToken,'210',pUsrAtendio,'04') INTO cCodRet_Token;
				
				IF(cCodRet_Token <> '000') THEN
					LET cCod_Ret='00002';
					RETURN cCod_Ret;
				END IF;
				
				--SE OBTIENE EL TOKEN VENCIDO		
				SELECT ns_token
				INTO vVencidoNsToken
				FROM bdinteg:"informix".si_bpitokenhis 
				WHERE num_cliente=pNumCliente
				AND id_status_token='220' 
				AND f_status=(SELECT  MAX(f_status) FROM bdinteg:"informix".si_bpitokenhis WHERE num_cliente=pNumCliente) ;

				--SE OBTIENE EL ULTIMO ESTATUS DEL TOKEN VENCIDO
				SELECT id_status 
				INTO vEstatusVencidoToken
				FROM bdibpi:"informix".tkn_nseries
				WHERE ns_token=vVencidoNsToken;
				--SE ACTUALIZA ESTATUS TOKEN VENCIDO
				UPDATE bdibpi:"informix".tkn_nseries set id_status='220',f_status=CURRENT WHERE ns_token=vVencidoNsToken;
				INSERT INTO bdibpi:tkn_status_token (ns_token,anterior,actual,f_cambio_status, usr_cambio_status,canal) 
				VALUES(vVencidoNsToken, vEstatusVencidoToken, '220', CURRENT, pUsrAtendio,'04');
			
				
				--SE ACTUALIZA EL ESTATUS DE LA SOLICITUD A 130
				SELECT solicitud,id_status
				INTO vNumSol,vEstatusSolicitudAnt
				FROM bdibpi:"informix".bpi_tokensolicitud
				WHERE id_status='120'
				AND numcte=pNumCliente
				AND tipo IN('6','7');
				
			    EXECUTE PROCEDURE bdibpi:"informix".sp_set_solicitudstatus_admtoken(vNumSol, pNumCliente, pUsrAtendio, vEstatusSolicitudAnt, '130') INTO cCodRet_Sol;
				IF(cCodRet_Sol <>'000') THEN
					LET cCod_Ret='00004';
					RETURN cCod_Ret;
					
				END IF;
				
				RETURN cCod_Ret;
				
		ELSE
			LET cCod_Ret='00001';			RETURN cCod_Ret;
		END IF;
	
END;
END PROCEDURE;