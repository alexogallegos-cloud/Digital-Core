CREATE PROCEDURE "informix".sp_portabregistraejecucion(pProceso CHAR(50), pFechaEjec DATE, pCodRet CHAR(5), pMensaje CHAR(100), pConsecDiario INTEGER)
RETURNING CHAR   (5) AS CodigoRetorno,
		  CHAR (100) AS MensajeEjecucion;

	--DESCRIPCION DE LOS PARAMETROS DE ENTRADA
		
		/*  pProceso:      	Proceso ejecutado que se registra en bitacora
			pFechaEjec:    	Fecha de ejecucion del proceso
			pCodRet:		Codigo correspondiente a la ejecucion del proceso ejecutado
			pMensaje:		Mensaje que describe la ejecucion del proceso ejecutado
			pConsecDiario: 	Numero de transferencias al proceso de pagos programados
		*/			
	
	-- DECLARACION DE VARIABLES
		  
DEFINE iSqlErr INTEGER;				-- ERROR DE INFORMIX
DEFINE cCodRet CHAR(5);				-- CODIGO DEL ERROR

DEFINE cHoraEjec        CHAR  (8);	-- HORA DE LA EJECUCION DEL PROCESO DE PORTABILIDAD
DEFINE cMensajeBitacora CHAR(100);	-- MENSAJE DE LA EJECUCION DEL PROCESO DE PORTABILIDAD
DEFINE cMensajeEjec     CHAR(100);	-- MENSAJE DE LA EJECUCION DEL PROCESO DE REGISTRO EN BITACORA

	-- INICIALIZACION DE VARIABLES
		  
LET iSqlErr = 0;
LET cCodRet = '00000';

LET cHoraEjec        = CURRENT HOUR TO SECOND;
LET cMensajeBitacora = '';
LET cMensajeEjec     = 'SE REALIZO CORRECTAMENTE EL REGISTRO EN LA BITACORA';

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeEjec = TRIM('ERROR INESPERADO EN LA EJECUCION DEL PROCEDIMIENTO');
			RETURN cCodRet, cMensajeEjec;
		END IF;
	END EXCEPTION;
	
--	SET DEBUG FILE TO "/tmp/sp_PortabRegistraEjecucion.out";
--	TRACE ON;	
	
	-- se valida que los parametros traigan datos
	IF pProceso = '' OR pProceso IS NULL OR pFechaEjec = '' OR pFechaEjec IS NULL OR pCodRet = '' OR pCodRet IS NULL OR
	   pMensaje = '' OR pMensaje IS NULL OR pConsecDiario IS NULL THEN
		LET cCodRet = '00001';
		LET cMensajeEjec = TRIM('ERROR EN LOS PARAMETROS; TODOS LOS PARAMETROS SON OBLIGATORIOS. VERIFIQUE');
		RETURN cCodRet, cMensajeEjec;
	END IF;	
	
	-- se concatena el codigo y el mensaje de la ejecucion del proceso de portabilidad
	LET cMensajeBitacora = TRIM(pCodRet ||' - '|| pMensaje);
	
	-- se registra la ejecucion del proceso de portabilidad en la bitacora
	INSERT INTO bdicheq:sc_portabitacora (proceso, fecha_ejec, hora, mensaje, consec_diario)
	                              VALUES (pProceso, pFechaEjec, TRIM(cHoraEjec), cMensajeBitacora, pConsecDiario);
	
	RETURN cCodRet, TRIM(cMensajeEjec);
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Genera el registro en bitacora de la ejecucion del proceso de la transferencia del servicio de portabilidad',
'al proceso de pagos programados',
'AUTOR: Clemente Angulo Ballardo',
'FECHA: 09 de Junio de 2010',
'VERSION: 20100609.1630',
'BD: BDICHEQ';

create procedure "informix".consnombcta(pempresa char(3),
        ppaterno char(26),
        pmaterno char(26),
        pnombre1 char(26),
        pnombre2 char(26),
        prfc     char(13))

        returning char(5), char(20), char(20);

        DEFINE v_cod_ret char(5);
        DEFINE v_ciclo smallint;
        DEFINE v_numcte char(20);
        DEFINE v_cuenta char (20);


        LET v_cod_ret  = "000";
        LET v_ciclo    = 0;
        LET v_numcte   = "";
        LET v_cuenta   = "";


                foreach
                select
                                a.numcte, b.cuenta
                into
                                v_numcte, v_cuenta
                from
                                bdinteg:si_cliente a,
                                bdicheq:sc_maechq b
                where
                                a.empresa = pempresa and
                                a.apell_paterno matches ppaterno and
                                a.apell_materno matches pmaterno and
                                a.nombre1 matches pnombre1 and
                                a.nombre2 matches pnombre2 and
                                a.rfc = prfc and
                                a.numcte = b.num_cte and
                                b.status_cta = '1'
                order by
                                b.cuenta

                                if not v_cuenta is null then
                                        LET v_ciclo = v_ciclo + 1;

                                        return v_cod_ret, v_cuenta, v_numcte with resume;
                                end if

                end foreach;


        if  v_ciclo = 0 then
                return "141", "", "";
        end if

end procedure
;