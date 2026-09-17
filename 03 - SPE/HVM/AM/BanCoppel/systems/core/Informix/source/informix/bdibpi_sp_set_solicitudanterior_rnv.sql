CREATE PROCEDURE "informix".sp_set_solicitudanterior_rnv(pEmpresa CHAR(3), pNumSolicitud CHAR(10), pNumCliente CHAR(9), pUsrAtiende char(8), pConsulta CHAR(1))

RETURNING CHAR(5) AS codret, CHAR(100) AS mensajeret, CHAR(10) AS token_anterior, CHAR(10) AS solictud_anterior;

--Declaracion de variables
DEFINE vcCodRet CHAR(5);
DEFINE vcMensajeRet CHAR(100);
DEFINE viSqlErr INTEGER;
DEFINE vcNum_cliente CHAR(9);
DEFINE vcSolicitud CHAR(10);
DEFINE vcNs_token CHAR(10);
DEFINE vcNumSolicitudAnterior CHAR(10);
DEFINE viCountSolCanceladasRnv INT;
DEFINE pStatusViejo CHAR(3);
DEFINE vCod_Ret_Token char(5);

--Inicilizando variables
LET vcCodRet = '00000';
LET vcMensajeRet = 'PROCESO EXITOSO';
LET viSqlErr = '';

LET vcNum_cliente = '';
LET vcSolicitud = '';
LET vcNs_token = '';
LET vcNumSolicitudAnterior = '';
LET viCountSolCanceladasRnv = 0;
LET pStatusViejo = '';
LET vCod_Ret_Token = '';



BEGIN

ON EXCEPTION SET viSqlErr
	IF (viSqlErr <> 0) THEN
		RETURN viSqlErr, vcMensajeRet, vcNs_token, vcNumSolicitudAnterior;
	END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/tmp/Lazalde/sp_set_solicitudanterior_rnv.out";
--TRACE ON;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;
--SET ISOLATION TO COMMITTED READ LAST COMMITTED;

--Si es de forma masiva se recorre todas las solicitudes procesadas para verificar las solicitudes anteriores y cancelarlas por renovación
IF (pConsulta='2') THEN
	
	FOREACH	    
	    SELECT {+INDEX(tkn_solprocesadas idx_tkn_solprocesadas)} solicitud,cliente 
	    INTO vcSolicitud,vcNum_cliente
	    FROM bdibpi:"informix".tkn_solprocesadas
	    WHERE estatus_sol = 0

	    EXECUTE PROCEDURE bdibpi:"informix".sp_set_solicitudanterior_rnv(pEmpresa, vcSolicitud, TRIM(vcNum_cliente), pUsrAtiende, '1')
	    INTO vcCodRet, vcMensajeRet, vcNs_token, vcNumSolicitudAnterior;
	    
	    IF (vcCodRet='00000')THEN
		LET viCountSolCanceladasRnv = viCountSolCanceladasRnv + 1;
	    END IF;
	    
	END FOREACH;	
	
	LET vcCodRet = '00000';
	LET vcMensajeRet = viCountSolCanceladasRnv::CHAR(5) || 'Canceladas por renovación';
	RETURN vcCodRet, vcMensajeRet, vcNs_token, vcNumSolicitudAnterior;
END IF;

IF NOT EXISTS(SELECT {+INDEX(bpi_tokensolicitud idx_tokensolicitud)} solicitud FROM bdibpi:'informix'.bpi_tokensolicitud WHERE solicitud = pNumSolicitud AND numcte = pNumCliente and empresa = pEmpresa) THEN
	RETURN '001', 'NO EXISTE SOLICTUD CON ESE CLIENTE', vcNs_token, vcNumSolicitudAnterior;
END IF;

--Valida la solicitud que se renovo si esta en proceso
IF EXISTS(SELECT {+INDEX(bpi_tokensolicitud idx_tokensolicitud)} solicitud FROM bdibpi:'informix'.bpi_tokensolicitud WHERE solicitud = pNumSolicitud AND numcte = pNumCliente AND id_status = 110 and empresa = pEmpresa) THEN
		
		SELECT first 1 {+INDEX(bpi_tokensolicitud idx_tokensolicitud)} b.solicitud, b.ns_token, b.id_status
		INTO vcNumSolicitudAnterior, vcNs_token, pStatusViejo
		FROM bdibpi:'informix'.bpi_tokensolicitud b
		INNER JOIN bdinteg:'informix'.si_bpitoken a ON a.ns_token = b.ns_token AND b.numcte = a.num_cliente
		WHERE b.numcte = pNumCliente and TRIM(b.solicitud) <> TRIM(pNumSolicitud) AND a.id_status_token = 140 and b.empresa = pEmpresa ;
						
		IF (vcNumSolicitudAnterior IS NULL OR vcNumSolicitudAnterior = '') THEN
			LET vcCodRet = '002';
			LET vcMensajeRet = 'NO EXISTE SOLICITUD ANTERIOR';			
			RETURN vcCodRet, vcMensajeRet, vcNs_token, vcNumSolicitudAnterior;
		END IF;
		
		IF (vcNs_token IS NOT NULL OR vcNs_token <> '') THEN
			
			--Poner tipo (5) Solicitud cancelada
			UPDATE {+INDEX(bpi_tokensolicitud idx_tokensolicitud)} bdibpi:'informix'.bpi_tokensolicitud
			SET tipo = 5
			WHERE ns_token = vcNs_token and numcte = pNumCliente and solicitud = vcNumSolicitudAnterior and empresa = pEmpresa;
			
			--Cancela por renovacion (220) la solicitud anterior con token disponible (140)		
			EXECUTE PROCEDURE bdibpi:"informix".sp_set_solicitudstatus_admtoken(vcNumSolicitudAnterior, pNumCliente, pUsrAtiende, pStatusViejo, '220') INTO  vCod_Ret_Token;
				
				IF (vCod_Ret_Token<>'000') THEN
					LET vcCodRet='005';						
				END IF;
		ELSE 
			LET vcCodRet = '003';
			LET vcMensajeRet = 'NO TIENE TOKEN ASIGNADO LA SOLICTUD';
		END IF;
ELSE
	LET vcCodRet = '004';
	LET vcMensajeRet = 'SOLICTUD ACTUAL NO RENOVADA';		
	
END IF;

RETURN vcCodRet, vcMensajeRet, vcNs_token, vcNumSolicitudAnterior;

END
END PROCEDURE
DOCUMENT
'AUTOR: JUAN DANIEL LAZALDE CENTENO',
'PROYECTO: ADMTOKEN',
'SOLICITÓ: José de Jesus Nevarez',
'DESCRIPCIÓN:Cancelación por renovación la solicitud anterior. cuando pConsulta = 1 es cancelación individual y pConsulta = 2 es masiva',
'MODIFICACION:  Daniel Lazalde   Actualizar la solicid con tipo = 5 (Cancelación)  2013/11/29 ',
'FECHA: 2013/11/15',
'VERSIÓN: 20131115.0001',
'BD: bdibpi';

CREATE PROCEDURE "informix".sp_devolucion_paquete( 
										pEmpresa char(3), 
										pNumGuia char(30), 
										pNumSolicitud char(10),
										pNumSToken char(9),
										pUsuario char(8),
										pNumEnvio char(3),
										pComentario char(200),
										pCanal char(2)
										)
	RETURNING CHAR(5);
	
	--// ***************************************************************************
	--//sp_devolucion_paquete
	--//Version:			 	1.0
	--//Objetivo:			Devolver token
	--//Parametros de Entrada:	
	--//					pEmpresa(El numero de empresa)
	--//					pNumGuia(El numero de Guia)
	--//					pNumSolcitiud(El numero de Solicitud)
	--//					pNumSToken(El numero de  Token)
	--//					pUsuario(El  Usuario)
	--//					pStatus(status): con este estatus se sabe si es devolucion o entrega de token
	--//Parametros salida:
	--//					vsCodRet:codigo de retorno
	--//Autor:	Francisco Rodriguez Ibarra
	--//Fecha: 9 Noviembre 2009	
	--// ***************************************************************************
	
	---------------------------------------------------------------------------------------------
--Realizo: Francisco Rodríguez Ibarra
--Modificación:Se modifico para agregar el canal en la tkn_series y tkn_status_token.
--Solicito: Jorge Nuñez
--Fecha:28/09/2010
---------------------------------------------------------------------------------------------
--Realizo: Ilse Jazmin Gómez Pérez.
--Modificación:Se modifico para que no se actualize la tabla si_bpitoken cuando sea una solicitud Rnv.
--Solicito: José de Jesus Nevarez
--Fecha:22/11/2013
---------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
--Realizo: Jessica Gutiérrez Rodríguez.
--Modificación:Se integra la devolución y reactivación de paquetes PM.
--Fecha:13/02/2014
---------------------------------------------------------------------------------------------
	--DECLARACION DE VARIABLES

	DEFINE vsCodRet  		CHAR(5);
	DEFINE vNumCliente      CHAR(9);
	DEFINE vStatusAnt       CHAR(4);
	DEFINE vSqlErr          INTEGER;
	DEFINE vStatusAct       SMALLINT;
	DEFINE vTipo       		SMALLINT;
	
	--SET DEBUG FILE TO "/tmp/sp_agrega_devolucion";
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
	
	--Asignacion de variables
	LET vsCodRet = '00000';
	LET vSqlErr = 0;
	LET vNumCliente='';
	LET vStatusAct=0;
	LET vTipo=0;
	
	BEGIN
		ON EXCEPTION SET vSqlErr
	      IF vSqlErr <> 0 THEN
	            let vsCodRet = vSqlErr;
	            RETURN vsCodRet;
	      END IF ;
		END EXCEPTION ;
		
		SELECT tipo INTO vTipo
		FROM bdibpi:"informix".bpi_tokensolicitud
		WHERE solicitud=TRIM(pNumSolicitud)
		AND ns_token=TRIM(pNumSToken);
		
		SELECT 	numcte  INTO vNumCliente 
		FROM bdibpi:"informix".tkn_envios 
		WHERE solicitud=TRIM(pNumSolicitud)
		AND num_guia=TRIM(pNumGuia)
		AND num_envio=TRIM(pNumEnvio);
			
		IF(vNumCliente=='' OR vNumCliente IS NULL) THEN
			let vsCodRet = '00100';		
		ELSE
			
			IF (vTipo=='6' OR vTipo=='7') THEN --Si es Renovada.
			
				SELECT id_status INTO vStatusAnt FROM bdibpi:"informix".tkn_nseries WHERE ns_token=pNumSToken;
					
				IF (vStatusAnt=='' OR vStatusAnt IS NULL) THEN
					let vsCodRet = '00300';			
				ELSE
						
					UPDATE bdibpi:"informix".bpi_tokensolicitud SET id_status=170,ns_token='' WHERE solicitud=TRIM(pNumSolicitud)	AND numcte=TRIM(vNumCliente);
					
					UPDATE bdibpi:"informix".tkn_envios SET id_status=170,comentarios=pComentario WHERE solicitud=pNumsolicitud AND num_guia=pNumGuia AND num_envio=pNumEnvio;
						
					UPDATE bdibpi:"informix".tkn_nseries SET id_status=105,canal=pCanal WHERE ns_token=trim(pNumSToken);
					
					INSERT INTO bdibpi:"informix".tkn_stasolicitud VALUES(pNumSolicitud,120,170,CURRENT);
					
					INSERT INTO bdibpi:"informix".tkn_status_token VALUES(pNumSToken,105,120,CURRENT,pUsuario,pCanal);
				END IF;
				
			ELIF (vTipo=='1' OR vTipo=='2') THEN --Si es PF.
			
				IF EXISTS(SELECT SI.num_cliente FROM bdinteg:"informix".si_bpitoken AS SI
							WHERE empresa=TRIM(pEmpresa) 
							AND SI.num_cliente=TRIM(vNumCliente) 
							AND SI.ns_token=TRIM(pNumSToken)) THEN
							
					SELECT id_status INTO vStatusAnt FROM bdibpi:"informix".tkn_nseries WHERE ns_token=pNumSToken;
					
					IF (vStatusAnt=='' OR vStatusAnt IS NULL) THEN
						let vsCodRet = '00300';				
					ELSE
							
						UPDATE bdibpi:"informix".bpi_tokensolicitud SET id_status=170,ns_token='' WHERE solicitud=TRIM(pNumSolicitud) AND numcte=TRIM(vNumCliente);
						
						UPDATE bdibpi:"informix".tkn_envios SET id_status=170,comentarios=pComentario WHERE solicitud=pNumsolicitud AND num_guia=pNumGuia AND num_envio=pNumEnvio;
							
						UPDATE bdibpi:"informix".tkn_nseries SET id_status=105,canal=pCanal WHERE ns_token=trim(pNumSToken);
						
						INSERT INTO bdibpi:"informix".tkn_stasolicitud VALUES(pNumSolicitud,120,170,CURRENT);
						
						INSERT INTO bdibpi:"informix".tkn_status_token VALUES(pNumSToken,105,120,CURRENT,pUsuario,pCanal);
						
						UPDATE bdinteg:"informix".si_bpitoken set id_status_token=0,ns_token=''  WHERE num_cliente=TRIM(vNumCliente);
					END IF;
				ELSE
					let vsCodRet = '00200';			
				END IF;
				
			ELIF (vTipo=='3' OR vTipo=='4') THEN --Si es PM.
			
				IF EXISTS(SELECT SI.num_cliente FROM bdinteg:"informix".si_bpitokenpm AS SI
							WHERE empresa=TRIM(pEmpresa) 
							AND SI.num_cliente=TRIM(vNumCliente) 
							AND SI.ns_token=TRIM(pNumSToken)) THEN
							
					SELECT id_status INTO vStatusAnt FROM bdibpi:"informix".tkn_nseries WHERE ns_token=pNumSToken;
					
					IF (vStatusAnt=='' OR vStatusAnt IS NULL) THEN
						let vsCodRet = '00300';				
					ELSE
							
						UPDATE bdibpi:"informix".bpi_tokensolicitud SET id_status=180,ns_token='', tipo=4 WHERE solicitud=TRIM(pNumSolicitud) AND numcte=TRIM(vNumCliente);
						
						UPDATE bdibpi:"informix".tkn_envios SET id_status=170,comentarios=pComentario WHERE solicitud=pNumsolicitud AND num_guia=pNumGuia AND num_envio=pNumEnvio;
							
						UPDATE bdibpi:"informix".tkn_nseries SET id_status=105,canal=pCanal WHERE ns_token=trim(pNumSToken);
						
						INSERT INTO bdibpi:"informix".tkn_stasolicitud VALUES(pNumSolicitud,120,170,CURRENT);
						INSERT INTO bdibpi:"informix".tkn_stasolicitud VALUES(pNumSolicitud,170,180,CURRENT);
						
						INSERT INTO bdibpi:"informix".tkn_status_token VALUES(pNumSToken,105,120,CURRENT,pUsuario,pCanal);
						
						UPDATE bdinteg:"informix".si_bpitokenpm set id_status_token=0,ns_token=''  WHERE num_cliente=TRIM(vNumCliente);
						
					END IF;
				ELSE
					let vsCodRet = '00200';			
				END IF;
   			
			END IF;
		END IF;
		
		RETURN vsCodRet;
	
	END
END PROCEDURE;