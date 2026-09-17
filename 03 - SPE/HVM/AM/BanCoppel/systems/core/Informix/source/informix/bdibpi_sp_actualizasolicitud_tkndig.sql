CREATE PROCEDURE "informix".sp_actualizasolicitud_tkndig(pOpcion INTEGER, pEmpresa CHAR(3),pNumCliente CHAR(9),pFolio CHAR(8), pUsrAtendio CHAR(9),  pCanal CHAR(2) )
   RETURNING CHAR(5);

   
	DEFINE cCodRet 			CHAR(10);
	DEFINE iSqlErr 			INTEGER;
	DEFINE cCodSp          	VARCHAR(5);
	DEFINE vSolic		   	VARCHAR(20);
	DEFINE vnskn 			CHAR(9);
	DEFINE cCodSp1 			VARCHAR(5);
	DEFINE cToken 			char(10);
	DEFINE FolioSuc 		varchar(16);
	DEFINE vFolio 			CHAR(12);
	DEFINE FolioRet			CHAR(10);
	DEFINE cEstatusSol 		CHAR(3);
	DEFINE dFecSol 			datetime year to second;

	
	LET cCodRet 	= '00000';
	LET iSqlErr 	= 0;
	LET cCodSp 		='00000';
	LET cCodSp1 	='00000';
	LET vSolic 		='';
	LET vnskn		='';
	LET cToken		='0000000000';
	LET FolioSuc	='';
	LET vFolio		='';
	LET FolioRet	='';
	LET cEstatusSol = '';
	LET dFecSol 	= current;

   

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	
	IF pOpcion = 1 then --Actualizar las solicitudes de los token cuando son digitales
	SELECT solicitud,ns_token INTO vSolic,vnskn FROM bpi_tokensolicitud WHERE numcte = pNumCliente and  id_status in ('300','310','320','330') ;   
     
		IF(vSolic <> '' OR vSolic IS NOT NULL) THEN
		
			UPDATE bpi_tokensolicitud  SET id_status = '300'  WHERE numcte = pNumCliente AND id_status in ('300','310','320','330') ;
			
			UPDATE bdinteg:si_bpitoken  SET id_status_token = '300', ns_token = '' WHERE num_cliente = pNumCliente AND ns_token=vnskn;
				
			UPDATE tkn_envios  SET id_status = '199' WHERE solicitud= vSolic;
			
			DELETE FROM tkn_nseries where ns_token=vnskn;
			
		ELSE
			LET cCodRet = '00001';
		END IF;
		
	ELSE 
		IF pOpcion = 2 then --Elimina registros y crea una nueva solicitud
		
			LET FolioSuc = 'SINCOMIS'||pFolio;
			
			SELECT {+INDEX bdinteg: "informix".si_bpiusuarios idx_bpi} folio_contrato 
					INTO vFolio
					FROM bdinteg:"informix".si_bpiusuarios 
					WHERE numcte = pNumCliente AND empresa = '001'; 
							
			SELECT MAX(f_solicitud)
					INTO dFecSol
					FROM bdibpi:"informix".bpi_tokensolicitud
					WHERE numcte = pNumCliente;
				
			SELECT TS.id_status
				   INTO cEstatusSol
				   FROM bdibpi:"informix".bpi_tokensolicitud AS TS, bdibpi:"informix".tkn_nseries AS TK
				   WHERE TK.ns_token = TS.ns_token
				   AND TS.f_solicitud = dFecSol
				   AND TS.numcte = pNumCliente;
				
			IF cEstatusSol <> '199' then -- Cancela los token activos si existen registros
				EXECUTE PROCEDURE bdibpi:sp_cancelartokensucursal(pEmpresa, pNumCliente, pUsrAtendio, pCanal)
				INTO cCodSp, cToken;
			ELSE -- Elimina el token para asiganar uno nuevo
				DELETE bdinteg:"informix".si_bpitoken WHERE num_cliente = pNumCliente;
			END IF;
						
			IF cCodSp = '00000'  THEN --Crea una nueva solicitud de token
				EXECUTE PROCEDURE bdibpi:sp_cargareversatokendig('8','1',pEmpresa,pNumCliente,'5007',pUsrAtendio,FolioSuc,'2','127.0.0.1',vFolio,'300')
				INTO cCodSp1,FolioRet;

				IF cCodSp1 <> '00000'  THEN
					LET cCodRet = cCodSp1;
				END IF;
				
			ELSE
				LET cCodRet = cCodSp;
			END IF;
		
		END IF;
	END IF;
	
	RETURN cCodRet;
	
	END;
END PROCEDURE;