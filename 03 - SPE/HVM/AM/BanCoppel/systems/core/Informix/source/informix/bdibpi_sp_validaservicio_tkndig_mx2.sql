CREATE PROCEDURE "informix".sp_validaservicio_tkndig_mx2(pNumCliente CHAR(9))
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
			END IF
		
			
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
					LET cCodRet = '00002';	 --USUARIO QUE NO TIENE SOLICITUD DE TOKEN  PERO TIENE REGISTROS
				END IF;
			END IF;	
			
	ELSE
			LET cCodRet = '00003' ; --ES SERVICIO BASICO
	END IF;

	RETURN cCodRet, vnumcte, vservicio, bid_status, vsolicitud, vid_status, vfolio_token, vns_token, vidstatustoken, vtkndig;
	
	END;
END PROCEDURE;