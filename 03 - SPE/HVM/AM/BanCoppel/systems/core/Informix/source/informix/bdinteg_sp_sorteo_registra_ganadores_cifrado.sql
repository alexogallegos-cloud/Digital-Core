CREATE PROCEDURE "informix".sp_sorteo_registra_ganadores_cifrado(pProceso char(20))
RETURNING CHAR(5) AS cCod_Ret;
-- DEFINICION DE VARIABLES
DEFINE cCodRet						CHAR(5);
DEFINE iSqlErr						INTEGER;


---------------------------------------
DEFINE vUsuario         CHAR(20);
DEFINE vLLave           CHAR(200);
DEFINE vNomarch         CHAR(100);
DEFINE vRutaOrigen      CHAR(100);
DEFINE vRutaDestino     CHAR(100);
DEFINE vNomarchSalida   CHAR(100);
DEFINE vRutaOriginales  CHAR(100);
DEFINE vNomarch_salida  CHAR(100);
DEFINE v_proceso  		CHAR(20);

--INICIALIZACION DE VARIABLES--
LET cCodRet						= "00000";
LET iSqlErr						= 0;

-----------------------------------------------------------  
  LET vUsuario        = '';
    LET vLLave          = '';
    LET vNomarch        = '';
    LET vRutaOrigen     = '';
    LET vRutaDestino    = '';
    LET vNomarchSalida  = '';
    LET vRutaOriginales = '';
    LET vNomarch_salida = '';
	LET v_proceso 		= pProceso;


	--SET DEBUG FILE TO  '/RESPALDOSNEW/Sorteo2024/sp_generacion_folios_sorteo_efectivo_cifrado.out';
	--TRACE ON;

	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				--insert into "informix".sac_log_errores_sorteo (codigoError,mensaje,fecha)
				--values (cCodRet,vCadena_req,sysdate);
				--COMMIT;
			RETURN cCodRet;
			END IF;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
--Consulta que regresa la fecha del dia actual
			
			LET v_proceso 		= trim(v_proceso);
			
		--------------------------------------------------Encrip------------------------------
		 FOREACH
			SELECT TRIM(usuario), TRIM(llave), TRIM(nomarch), TRIM(ruta_origen), TRIM(nomarch_salida), TRIM(ruta_destino), TRIM(ruta_originales)
				INTO vUsuario, vLLave, vNomarch, vRutaOrigen, vNomarch_salida, vRutaDestino, vRutaOriginales    
			FROM bdinteg:si_configura_pgp_chq
				WHERE codigo = v_proceso
			ORDER BY secuencia
			
			SYSTEM 'echo "export PATH=/usr/bin:/etc:/usr/sbin:/usr/ucb:/home/'||TRIM(vUsuario)||'/bin:/usr/bin/X11:/sbin:.:/opt/pgp/bin:/informix/bin" > '||TRIM(vRutaOrigen)||'blinda_sorteo.sh';
			SYSTEM 'echo "export HOME=/home/'||TRIM(vUsuario)||'" >> '||TRIM(vRutaOrigen)||'blinda_sorteo.sh';
			
			SYSTEM 'echo "/opt/pgp/bin/pgp --encrypt -i '||TRIM(vRutaOrigen)||TRIM(vNomarch)||' -r '||''''||TRIM(vLLave)||''''||' '||TRIM(vRutaDestino)||TRIM(vNomarch_salida)||'" >> '||TRIM(vRutaOrigen)||'blinda_sorteo.sh';
			
			SYSTEM '/usr/bin/chmod 777 '||TRIM(vRutaOrigen)||'blinda_sorteo.sh';   
			SYSTEM '/usr/bin/sh '||TRIM(vRutaOrigen)||'blinda_sorteo.sh';
			
			SYSTEM '/usr/bin/mv '||TRIM(vRutaOrigen)||TRIM(vNomarch)||' '||vRutaOriginales; 
			SYSTEM '/usr/bin/mv '||TRIM(vRutaOriginales)||TRIM(vNomarch)||'pgp'||' '||vRutaDestino; 
			
			SYSTEM 'rm /RESPALDOSNEW/Sorteo2024/blinda_sorteo.sh';
		
		END  FOREACH;
		
		RETURN cCodRet;
	
	END;
END PROCEDURE;