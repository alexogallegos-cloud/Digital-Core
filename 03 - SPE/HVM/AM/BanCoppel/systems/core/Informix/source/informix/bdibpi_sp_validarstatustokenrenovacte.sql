CREATE PROCEDURE "informix".sp_validarstatustokenrenovacte(pEmpresa CHAR(3),pNumCte CHAR(20))
RETURNING CHAR(5);

	--DEFINICION DE VARIABLES
	DEFINE vCodret			CHAR(5);
	DEFINE vSqlerr			INTEGER;
	DEFINE iExistCte		INTEGER;
	DEFINE cSerieToken		CHAR(10);
	DEFINE cStatusSolicitud	BOOLEAN;
	DEFINE cStatusServicio	SMALLINT;
	DEFINE cStatusToken		SMALLINT;

	--INICIALIZACION DE VARIABLES
	LET vCodret				= "00000";
	LET vSqlerr				= 0;
	LET iExistCte			= 0;
	LET cSerieToken			= "";
	LET cStatusSolicitud	= "f";
	LET cStatusServicio		= 0;
	LET cStatusToken		= 0;

	--SET DEBUG FILE TO "/home/informix/Aida/validarstatustokenrenovacte.out";
	--TRACE ON;

    BEGIN
 
		ON EXCEPTION SET vSqlerr
			IF vSqlerr <> 0 THEN
				LET vCodret = vSqlerr;
				RETURN vCodret;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;

		SELECT ns_token
		INTO cSerieToken
		FROM bdinteg:"informix".si_bpitoken
		WHERE empresa = pEmpresa
		AND num_cliente = pNumCte;

	-- se valida si existe registro en la tabla si_bpitoken para determinar si está cancelado el token (Aída Valenzuela)
	IF(cSerieToken IS NULL OR cSerieToken = "") THEN
	 	LET vCodret  = "00199";
     
	 ELSE 	
	 
    	 SELECT COUNT(numcte)
		INTO iExistCte
		FROM bdibpi:"informix".tkn_tokenexpira
		WHERE numcte = pNumCte
		AND ns_token = cSerieToken;

	  
		
		IF iExistCte > 0 THEN

			SELECT id_status_solicitud, id_status_servicio, id_status_token
			INTO cStatusSolicitud, cStatusServicio, cStatusToken
			FROM bdibpi:"informix".tkn_tokenexpira
			WHERE numcte = pNumCte
			AND ns_token = cSerieToken;

			IF NVL(cStatusSolicitud,"t") = "t" THEN
				LET vCodret  = "00197";
			ELIF NVL(cStatusServicio,"0") <> 30 AND NVL(cStatusServicio,"0") <> 35 AND NVL(cStatusServicio,"0") <> 40 AND NVL(cStatusServicio,"0") <> 50 AND NVL(cStatusServicio,"0") <> 60
				AND NVL(cStatusServicio,"0") <> 80 AND NVL(cStatusServicio,"0") <> 85 AND NVL(cStatusServicio,"0") <> 90 AND NVL(cStatusServicio,"0") <> 95 THEN
					LET vCodret  = "00198";
			ELIF NVL(cStatusToken,"0") <> 140 AND NVL(cStatusToken,"0") <> 150 AND NVL(cStatusToken,"0") <> 151 AND NVL(cStatusToken,"0") <> 152 AND NVL(cStatusToken,"0") <> 160 THEN
				LET vCodret  = "00199";
			END IF
		ELSE	
			LET vCodret  = "00200";				
		END IF
 END IF
		RETURN  vCodret;
	END
END PROCEDURE
DOCUMENT
"DESCRIPCION:Valida reposicion de token por vencimiento o caducidad",
"REALIZO :Claudio Almodovar",
"FECHA : 26/02/2014",
"BD    : bdibpi";

CREATE PROCEDURE "informix".sp_actualiza_guia_proceso(pNumSolicitud CHAR(10), pNumCliente CHAR(9), pGuia BOOLEAN,pProceso CHAR(1))
   returning CHAR(5);

--------------------------------------------------------------------------------------------
-- Realizó: José Rubén López
-- Actividad: Actualiza el campo guia y proceso de la tabla bpi_tokensolicitud
-- Solicitó: José de Jesus Nevarez
-- Fecha de Solicitud: 11-08-2014
--------------------------------------------------------------------------------------------
-- Realizó: José de Jesús Nevarez
-- Actividad: Se modifica para que no actualize el campo proceso de la tabla bpi_tokensolicitud cuando sea proceso masivo.
-- Solicitó: Gabriela Aguilar (BanCoppel)
-- Fecha de Solicitud: 11-11-2014

    DEFINE sql_err INTEGER ;
    DEFINE cod_ret CHAR(5);
  
	LET cod_ret  = '00000';
	
  --SET DEBUG FILE TO "/tmp/sp_actualiza_guia_proceso.out";
  --TRACE ON;
BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
      END IF;
   END EXCEPTION;
   
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
    IF EXISTS(SELECT id_status FROM bdibpi:"informix".bpi_tokensolicitud WHERE solicitud = pNumSolicitud AND numcte=pNumCliente) THEN
        IF (pProceso <> "0") THEN -- Cero para para proceso de asignación masiva de guia.
			UPDATE bdibpi:"informix".bpi_tokensolicitud SET guia = pGuia,proceso= pProceso  
			WHERE solicitud = pNumSolicitud AND numcte=pNumCliente;
		ELSE
			UPDATE bdibpi:"informix".bpi_tokensolicitud SET guia = pGuia
			WHERE solicitud = pNumSolicitud AND numcte=pNumCliente;
		END IF;
    ELSE
        LET cod_ret = '00001';
    END IF;
        
    RETURN cod_ret;
   
END

END PROCEDURE;