CREATE PROCEDURE "informix".sp_consultar_status_solicitud_token(p_snumcte char(9), p_sSolicitud char(10))
    RETURNING   CHAR(5),            --Código Retorno				
				SMALLINT,       --id_status				
				CHAR(30),	--direccion
                CHAR(50),	--colonia
                CHAR(50),	--municipio
                CHAR(5),	--cp
                CHAR(30),	--dirCom
				CHAR(200),	--comentarios
				DATE;	--Fecha envio
	--******************************************************
	-- Realizó:         Walber Castro
	-- Solicitó:        Mauricio León
	-- Proyecto:	Solicitud Token ICCAT
	-- Actividad:	Se crea por primera vez para consultar el status, descripcion, direccion y comentarios de envio de token.
	-- Fecha:           2011/06/10
	--******************************************************
    DEFINE sql_err INT;
    DEFINE vCodRet CHAR(5);
		
	DEFINE iStatus               SMALLINT;	
	DEFINE sDireccion	CHAR(30);
	DEFINE sColonia			CHAR(50);
	DEFINE sDelMpio				CHAR(50);
	DEFINE sCP		CHAR(5);
    DEFINE sDirCom      CHAR(30);                
    DEFINE sComentarios CHAR(200);
    DEFINE dFechaEnvio DATE;

    LET sql_err = 0;        
    LET vCodRet = '00000';
	LET iStatus = 0;	
	LET sDireccion = '';
	LET sColonia = '';
	LET sDelMpio = '';
	LET sCP = '';
    LET sDirCom = '';        
    LET sComentarios = '';
    LET dFechaEnvio = '';

    --SET DEBUG FILE TO "/tmp/sp_consultar_status_solicitud_token.out";
    --TRACE ON;
    SET LOCK MODE TO WAIT 10;

BEGIN		
        ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET vCodRet = sql_err;
				RETURN vCodRet, iStatus, sDireccion,  sColonia, sDelMpio, sCP, sDirCom,sComentarios, dFechaEnvio;
			END IF;
		END EXCEPTION;

                IF EXISTS(SELECT solicitud FROM bdibpi:"informix".bpi_tokensolicitud WHERE numcte = p_snumcte AND solicitud = p_sSolicitud) THEN
                        SELECT a.id_status,TRIM(NVL(t.direccion,'')), TRIM(NVL(t.colonia,'')), TRIM(NVL(t.del_mpio,'')), TRIM(NVL(t.cp,'')), TRIM(NVL(t.dir_com,''))
                        INTO iStatus, sDireccion, sColonia, sDelMpio, sCP, sDirCom
                        FROM bdibpi:"informix".bpi_tokensolicitud a
                        JOIN bdibpi:"informix".tkn_agendacte t ON ( a.numcte = t.numcte )                        
                        WHERE a.numcte = p_snumcte AND solicitud = p_sSolicitud;                       
                        
                        SELECT TRIM(NVL(comentarios,'')),f_envio
                        INTO sComentarios, dFechaEnvio
                        FROM bdibpi:"informix".tkn_envios
                        WHERE numcte = p_snumcte AND solicitud = p_sSolicitud AND id_status = iStatus
                        AND f_registro = (SELECT MAX(f_registro) FROM bdibpi:"informix".tkn_envios WHERE numcte = p_snumcte AND solicitud = p_sSolicitud AND id_status = iStatus);                        

                        IF sComentarios IS NULL THEN
                            LET sComentarios = "";
                       END IF;
                       IF dFechaEnvio IS NULL THEN
                            LET dFechaEnvio = "";
                       END IF;
               ELSE
                        LET vCodRet = '00001'; --NO EXISTE LA SOLICITUD
               END IF;
               RETURN vCodRet, iStatus, sDireccion,  sColonia, sDelMpio, sCP, sDirCom,sComentarios, dFechaEnvio;
END;
END PROCEDURE;