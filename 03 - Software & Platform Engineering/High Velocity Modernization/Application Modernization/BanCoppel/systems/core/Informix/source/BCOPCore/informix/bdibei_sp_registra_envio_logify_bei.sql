CREATE PROCEDURE "informix".sp_registra_envio_logify_bei(pNumGuia char(30), pCodRast char(10), pNumSolicitud char(10), pNumCte char(9), pNumEnvio char(3), pStatus char(3), pComentario char(200), pFechaEnvio char(30))
RETURNING CHAR(5);
	--*************************************************************
	--Objetivo: aumentar la longitud del parametro numero de guia.
	--Solicitó: Gabriela Aguilar (BanCoppel).
	--Elaboró Arturo Astorga.
	--Fecha: 2018-05-04.
	--BD:bdibei.
	DEFINE CodRet  		    CHAR(5);
	DEFINE sqlErr           INTEGER;
	DEFINE vNumSolicitud	CHAR(10);
	DEFINE vNumCte			CHAR(9);
	DEFINE vEstado			CHAR(4);
	DEFINE vSiglas			CHAR(3);
	DEFINE vSecDomicilio	INTEGER;
	DEFINE vTipoDir			CHAR(1);
	DEFINE dFechaReg        DATETIME YEAR TO SECOND;
	DEFINE dFechaEnv        DATETIME YEAR TO SECOND;
	
	LET codRet = '00000';
	LET sqlErr = 0;
	LET vNumCte=pNumCte;
	LET vNumSolicitud= pNumSolicitud;
	LET vEstado='';
	LET vSecDomicilio = 0;
	LET vSiglas = '';
	LET vTipoDir='';
	LET dFechaReg = CURRENT YEAR TO FRACTION;
	LET dFechaEnv = pFechaEnvio::DATETIME YEAR TO FRACTION; 
	
	--SET DEBUG FILE TO "/respaldosbd/CesarMendoza/sp_registra_envio_bei.out";
	--TRACE ON;
		
	BEGIN
	
		ON EXCEPTION SET sqlErr
			  IF sqlErr <> 0 THEN
					LET codRet = sqlErr;
					RETURN codRet;
			  END IF ;
		END EXCEPTION ;
	
		SET LOCK MODE TO WAIT 10;
		SET ISOLATION TO DIRTY READ;
	
		IF((vNumCte<>'') AND (vNumSolicitud<>'')) THEN
			
			-- Obtiene el estado de envio
			SELECT FIRST 1 dira.tipo_dir, tkns.sec_domicilio
			INTO vTipoDir, vSecDomicilio
			FROM bdinteg:"informix".si_direcciones dira,	bdibei:"informix".bei_solicitudtoken tkns
			WHERE dira.numcte = vNumCte
			AND tkns.solicitud = vNumSolicitud
			AND dira.secuencia = tkns.sec_domicilio;

			IF NVL(vTipoDir,'0') = 1 OR NVL(vTipoDir,'0')=2 THEN
				SELECT estado {+ INDEX (bdinteg:"informix".si_direcciones_actual idx_diract_cte)} 
				INTO vEstado
				FROM bdinteg:"informix".si_direcciones_actual
				WHERE numcte = vNumCte AND tipo_dir= vTipoDir AND secuencia=NVL(vSecDomicilio,0);
			ELIF NVL(vTipoDir,'0') = 3 THEN
				SELECT estado {+ INDEX (bdinteg:"informix".si_direcciones_actual inx_puntocardinales)} 
				INTO vEstado
				FROM bdinteg:"informix".si_direcciones
				WHERE numcte = vNumCte AND secuencia=NVL(vSecDomicilio,0) AND tipo_dir= vTipoDir;
			END IF;
				
			IF NVL(vEstado,'')<>'' THEN
				SELECT siglas
				INTO vSiglas -- Siglas del estado obtenido
				FROM bdinteg:"informix".si_estados
				WHERE estado = vEstado;
			END IF;
			-- 
			IF EXISTS(SELECT solicitud FROM "informix".bei_envios
						WHERE solicitud = pNumSolicitud
						AND	numcte = vNumCte )THEN				
					UPDATE "informix".bei_envios SET
					num_guia = pNumGuia,
					cod_rastreo=pCodRast,
					num_envio = num_envio + 1,
					id_status = pStatus,
					f_envio=dFechaEnv,
					f_registro=dFechaReg,
					estado=vSiglas
					WHERE numcte = vNumCte AND solicitud = vNumSolicitud;
			ELSE
				INSERT INTO "informix".bei_envios (num_guia,cod_rastreo,solicitud,numcte,num_envio,id_status,comentarios,f_envio,f_registro,estado) 
				VALUES (pNumGuia, pCodRast, vNumSolicitud, vNumCte, pNumEnvio, pStatus, pComentario, dFechaEnv, dFechaReg, vSiglas);
		
			END IF;
		ELSE
			LET codRet='0001';
			
		END IF;
		
		RETURN codRet;
		
	END;
	
END PROCEDURE;