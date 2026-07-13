CREATE PROCEDURE "informix".sp_buscar_paquete(pNumGuia char(30),pSolicitud char(10),pCliente char(9),pNumToken char(9),pCodRastreo char(10))
	RETURNING CHAR(5),CHAR(10),CHAR(108),CHAR(10),CHAR(9),CHAR(3),CHAR(3),CHAR(9),CHAR(1),CHAR(200),CHAR(10),CHAR(30);
	
	--// ***************************************************************************
	--//sp_buscar_paquete
	--//Version:			 	1.0
	--//Objetivo:			Optener el paquete para el Administrador de TOKEN
	--//Parametros de Entrada:	
	--//					pNumGuia(El numero de Guia)
	--//Parametros salida:
	--//					sFecEnvio(Fecha Envio)		
	--//					sNomCte(Nombre del Cliente)
	--//					sNumSerieToken(Num Serie del token)
	--//Autor:	Francisco Rodriguez Ibarra
	--//Fecha: 9 Noviembre 2009	
	--//Modificacion:Se modifico para traer la fecha de envio si es reprocesada y si es nuve trae el concepto "NINGUNA"
	--//Autor:Francsico Rodriguez Ibarra
	--//Fecha modificacio: 15 -Abril -2010
	--// ***************************************************************************
	
	--Modifico:José Rubén López
	--Actividad: Se modifico la consulta principal, agregandole mas criterios de busqueda de paquete
	--Fecha: 26-08-2014
	--Solilcitó: José de Jesus Nevarez
	
	--DECLARACION DE VARIABLES

	DEFINE vsCodRet  		CHAR(5);
	DEFINE vSqlErr          INTEGER;
	DEFINE vNomCte  		CHAR(108);
	DEFINE vNumSerieToken  	CHAR(9);
	DEFINE vFecEnvio 		CHAR(10);
	DEFINE vNumSolicitud	CHAR(10);
	DEFINE vNumCte			CHAR(9);
	DEFINE vStatusSol       SMALLINT;
	DEFINE vStatusEnvios    SMALLINT;
	DEFINE vNumEnvio        SMALLINT;
	DEFINE vTipo			SMALLINT;
	DEFINE vComentario		CHAR(200);
	DEFINE vRazonSocial 	char (60); 
	DEFINE vCodRastreo		char(10);
	DEFINE vNumGuia			char(30);
	DEFINE vNombre1			CHAR(26);
	DEFINE vNombre2			CHAR(26);
	DEFINE vApell_paterno	CHAR(26);
	DEFINE vApell_materno	CHAR(26);
	
    --SET DEBUG FILE TO "/informix/gaby/ArchivosOut/sp_buscar_paquete.out";
	--TRACE ON;

	--Asignacion de variables
	LET vsCodRet = '00000';
	LET vSqlErr = 0;
	LET vNomCte = '';
	LET vNumCte = '';
	LET vNumSerieToken = '';
	LET vFecEnvio = '';
	LET vNumSolicitud = '';
	LET vStatusSol = 0;
	LET vStatusEnvios = 0;
	LET vNumEnvio = 0;
	LET vTipo=0;
	LET vComentario='';
	LET vRazonSocial = '';
	LET vCodRastreo='';
	LET vNumGuia='';
	LET vNombre1	='';
	LET vNombre2	='';
	LET vApell_paterno='';
	LET vApell_materno='';
	
		

	BEGIN
		ON EXCEPTION SET vSqlErr
	      IF vSqlErr <> 0 THEN
	            let vsCodRet = vSqlErr;
	            RETURN vsCodRet , vFecEnvio , vNomCte , vNumSolicitud , vNumSerieToken,vNumEnvio,vStatusSol,vNumCte,vTipo,vComentario,vCodRastreo,vNumGuia;
	      END IF;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION DIRTY READ ;
		
		
		SELECT   E.num_envio,E.solicitud,DATE(E.f_envio)::char(10) AS fecEnvio,TRIM(E.numcte) AS numCte,E.id_status,S.id_status,S.tipo,S.ns_token,E.comentarios,E.num_guia,E.cod_rastreo
			INTO vNumEnvio,vNumSolicitud , vFecEnvio , vNumCte, vStatusEnvios,vStatusSol,vTipo,vNumSerieToken,vComentario,vNumGuia,vCodRastreo
			FROM bdibpi:"informix".tkn_envios as E, bdibpi:"informix".tkn_guias as G, bdibpi:"informix".bpi_tokensolicitud as S
			WHERE E.num_guia = G.num_guia
			AND NVL(E.num_guia,'') MATCHES ('*' || pNumGuia)
			AND NVL(S.solicitud,'') MATCHES ('*' || pSolicitud)
			AND NVL(S.numcte,'')  MATCHES ('*' || pCliente)
			AND NVL(S.ns_token,'')  MATCHES ('*' || pNumToken)
			AND NVL(E.cod_rastreo,'') MATCHES ('*' || pCodRastreo)
			AND E.solicitud = S.solicitud
            AND E.num_envio= (SELECT MAX(num_envio) FROM bdibpi:"informix".tkn_envios WHERE num_guia=E.num_guia);
			
			
			    			
     			
		IF(vNumSolicitud IS NULL OR  vNumSolicitud=='') THEN
			-- No existe la guia
			
			SELECT id_status 
			INTO vStatusSol
			FROM bdibpi:"informix".bpi_tokensolicitud 
			WHERE numcte= pCliente AND solicitud =pSolicitud AND ns_token = pNumToken; 
			
			IF(vStatusSol<>120 AND vStatusSol<>130 AND vStatusSol<>170)THEN
				LET vsCodRet='00400';
			ELSE
				LET vsCodRet = '00100';
			END IF;	
		ELSE
			--se obtiene el nombre del cliente
			
			--SELECT TRIM(si.nombre1)|| ' ' || TRIM(si.nombre2)|| ' ' || TRIM(si.apell_paterno)|| ' ' ||  TRIM( si.apell_materno) as nombre, razon_social 
			SELECT si.nombre1, si.nombre2, si.apell_paterno, si.apell_materno 
			into 	vNombre1, vNombre2,vApell_paterno, vApell_materno
			FROM  bdinteg:"informix".si_cliente as si 
			WHERE si.numcte=vNumCte;
			
			Let vNomCte=TRIM(vNombre1)|| ' ' || TRIM(vNombre2)|| ' ' || TRIM(vApell_paterno)|| ' ' ||  TRIM(vApell_materno);
			
			IF(vNomCte IS NULL OR vNomCte='') THEN
				LET vNomCte = vRazonSocial;
			END IF;
			IF TRIM(NVL(vNomCte,'')) = '' THEN
				LET vsCodRet = '00200';	--Error al obtener nombre del cliente				
			ELSE
				--Verifica si la Solicitud ya ha sido enviada, o devuelta, o no tiene fecha envio
				IF (vStatusEnvios IS NULL OR vStatusEnvios == '' ) THEN
					--Error al Obtener estatus del envio
					LET vsCodRet = '00300';	
				ELSE
					--Verifica si trae el los estatus 120,130 0 170
					IF(vStatusSol<>120 AND vStatusSol<>130 AND vStatusSol<>170)THEN
						LET vsCodRet='00400';
					END IF;	
				END IF;
			END IF;
		END IF;
		
		RETURN vsCodRet , vFecEnvio , vNomCte , vNumSolicitud , vNumSerieToken,vNumEnvio,vStatusSol,vNumCte,vTipo,vComentario,vCodRastreo,vNumGuia;
	END
END PROCEDURE
DOCUMENT
'MODIFICO: Juan Pablo Soto Ibarra',
'FECHA: 01/Agosto/2018',
'SOLICITANTE: Arturo Alejandro Vázquez Fernández',
'DESCRIPCION: Se modifica parametro de retorno vNumGuia a 30 caracteres',
'Folio: 427.1 RQI 03 712 - Mantenimiento AdmonToken',
'BD: bdibpi';

CREATE PROCEDURE "informix".sp_insertaactualiza_tkndig(pTipo CHAR(1), pNumCliente CHAR(9), pnskn CHAR(9), pStatusV CHAR(3), pStatusN CHAR(3), pUsr CHAR(8), pNumSol CHAR(10),  pCanal CHAR(2), pFolioTkn CHAR(30))
   RETURNING CHAR(5);
   
   --SE DEFINE VARIABLES
	DEFINE cCodRet 			CHAR(10);
	DEFINE iSqlErr 			INTEGER;
	DEFINE vnumcte 			CHAR (9);
	
	DEFINE vcSer			INTEGER;
	DEFINE vcSts			INTEGER;
	DEFINE vcEnv			INTEGER;
	DEFINE ext1				INTEGER;
	
	DEFINE vservicio 		CHAR(2);
	DEFINE vsolicitud		CHAR(10);
	DEFINE vid_status		SMALLINT;
	DEFINE vfolio_token		VARCHAR(25);
	DEFINE vns_token		CHAR(12);
	DEFINE vidstatustoken	SMALLINT;
	DEFINE vtkndig			CHAR(2);
	DEFINE vConta			INTEGER;
   
   --ASIGNACION DE VARIABLES
    LET cCodRet 		= '00000';
	LET iSqlErr 		= 0;
	LET vnumcte 		= '';
	LET vcSer			= 0;
	LET vcSts			= 0;
	LET vcEnv			= 0;
	LET ext1			= 0;
	LET vConta			= 0;
	
	
	LET vservicio 		= '';
	LET vsolicitud		= '';
	LET vid_status		= 0;
	LET vfolio_token	= '';
	LET vns_token		= '';
	LET vidstatustoken	= 0;
	LET vtkndig			= 'F';
   

	--El canal es 17
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;

	IF NVL(pTipo, '') = '' OR NVL(pNumCliente, '') = '' OR NVL(pnskn, '') = '' OR NVL(pStatusV, '') = '' OR NVL(pStatusN, '') = '' OR NVL(pUsr, '') = '' OR NVL(pNumSol, '') = ''  OR NVL(pCanal, '') = '' THEN 
        LET cCodRet 		= '00002'; --FALTAN DATOS
		RETURN cCodRet;
	END IF;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF pTipo = '1' THEN 
		SELECT COUNT(ns_token) INTO vcSer FROM bdibpi:tkn_nseries where ns_token  = pnskn and id_status <> '199';
		
		SELECT COUNT(solicitud) INTO vcEnv FROM bdibpi:tkn_envios where solicitud= pNumSol AND id_status <> '199';
		
		IF vcSer = 0 AND  vcEnv = 0 THEN
		
			INSERT INTO bdibpi:tkn_nseries(ns_token, id_status, f_status, usr_registro_estatus, canal, f_caducidad)
			VALUES(pnskn, pStatusV, CURRENT, pUsr, pCanal, NULL);
			
			SELECT COUNT(num_cliente) INTO vConta FROM  bdinteg:"informix".si_bpitoken WHERE num_cliente=pNumCliente ;
			
			IF vConta = 0 THEN 
			
				INSERT INTO bdinteg:"informix".si_bpitoken(empresa, num_cliente, ns_token, suc_registro, folio_token, id_status_token, f_status, f_registro)
				VALUES('001', pNumCliente, '', 5007, pFolioTkn, pStatusV, CURRENT, CURRENT);
			
			END IF;	
		
			INSERT INTO bdibpi:tkn_envios(solicitud, num_envio, id_status, comentarios, f_envio, f_registro, num_guia, numcte, cod_rastreo)
			VALUES(pNumSol, 1, pStatusN, NULL, CURRENT, CURRENT, pFolioTkn, pNumCliente, '000000000');
			
		
			LET cCodRet 		= '00000';
		ELSE 
			 LET cCodRet 		= '00001'; --SE ENCONTRARON REGISTROS NO SE PUEDE INSERTAR
		END IF;
		
	ELIF pTipo = '2'  THEN 
	
		SELECT COUNT(folio_token) INTO vcSer FROM bdinteg:si_bpitoken WHERE  num_cliente = pNumCliente and folio_token=pFolioTkn and id_status_token <> '199' ;
		
		IF vcSer = 1 THEN
			
			IF pStatusN = 140 THEN 
			
			UPDATE bdinteg:si_bpitoken SET ns_token = pnskn, id_status_token = pStatusN , tipo_token='2' WHERE  num_cliente = pNumCliente and folio_token = pFolioTkn and tipo_token = '1' and id_status_token <> '199';
			
			UPDATE bdibpi:bpi_tokensolicitud SET ns_token=pnskn, f_solicitud = CURRENT  WHERE numcte = pNumCliente and solicitud = pNumSol;
			
			UPDATE bdibpi:tkn_envios SET id_status='330'  WHERE solicitud = pNumSol and id_status = '310';
			
			UPDATE bdinteg:si_bpitoken SET ns_token = pnskn, id_status_token = pStatusN  WHERE  num_cliente = pNumCliente and folio_token = pFolioTkn and id_status_token <> '199';
			
			UPDATE bdibpi:bpi_tokensolicitud SET ns_token=pnskn, f_solicitud = CURRENT  WHERE numcte = pNumCliente and solicitud = pNumSol;
			
			LET cCodRet 		= '00000';
			
			END IF;
		ELSE 
			 LET cCodRet 		= '00003'; --NO SE ENCONTRARON REGISTROS PARA ACTUALIZAR
		END IF;
		
	END IF;			 
	
	RETURN cCodRet;	
END	
END PROCEDURE;