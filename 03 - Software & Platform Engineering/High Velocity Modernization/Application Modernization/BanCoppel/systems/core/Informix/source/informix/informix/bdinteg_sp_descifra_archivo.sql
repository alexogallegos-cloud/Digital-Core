CREATE PROCEDURE "informix".sp_descifra_archivo(pCodigo CHAR(20)) 
RETURNING
          CHAR(06) AS resultado,
          CHAR(80) AS mensaje;

--************************ Definicion de variables *****************************
DEFINE cMensajeRet, cMensajeRet2     CHAR(80);

define vEmpresa             CHAR(3);
define iCodRet              INTEGER;
define cCodRet              CHAR(06);
define isam_err             INTEGER;
define visam_err            INTEGER;
define error_info	        CHAR(150);
define verror_info	        CHAR(150);
define vUsuario             CHAR(20);
define vCodigo              CHAR(20);
define vLLave               CHAR(200);
define vNomarch             CHAR(100);
define vRutaOrigen          CHAR(100);
define vRutaDestino         CHAR(100);
define vNomarchSalida       CHAR(100);
define vRutaOriginales      CHAR(100);
define vNomarch_salida      CHAR(100);
define vArmaShellExt        CHAR(5000);
define v_ext_entrada        CHAR(10);
define v_ext_salida         CHAR(10);
define v_retorno_linea      CHAR(1);
define cPassphrase          CHAR(14);

define vfecha_hoy           DATE;
define vPri_dia_mes         DATE;
define vDia, vMes           CHAR(2);
define vAnio                CHAR(4);
define vBlinda              CHAR(50);

LET cMensajeRet             = 'Proceso Exitoso';
LET cMensajeRet2            = '';
LET vEmpresa                = '001';
LET iCodRet                 = 0;
LET cCodRet                 = '000000';
LET isam_err                = 0;
LET visam_err               = 0;
LET error_info              = '';
LET verror_info             = '';
LET vUsuario                = '';
LET vCodigo                 = '';
LET vLLave                  = '';
LET vNomarch                = '';
LET vRutaOrigen             = '';
LET vRutaDestino            = '';
LET vNomarchSalida          = '';
LET vfecha_hoy              = DATE(1);
LET vPri_dia_mes            = DATE(1);
LET vDia                    = '';
LET vMes                    = '';
LET vAnio                   = '';
LET vRutaOriginales         = '';
LET vNomarch_salida         = '';
LET vBlinda                 = '';
LET vArmaShellExt		        = '';
LET v_ext_entrada           = '';
LET v_ext_salida            = '';
LET v_retorno_linea         = '';
LET cPassphrase             = ' --passphrase ';  

--**************************** Control de errores ******************************
BEGIN
    ON EXCEPTION SET iCodRet, isam_err, error_info
    	IF iCodRet <> 0 then
          	LET cCodRet = iCodRet;
            LET visam_err = isam_err;
            LET verror_info = error_info;
            LET cMensajeRet =  visam_err || ' - ' || TRIM(verror_info);
                	
  			RETURN cCodRet,cMensajeRet ;
      END IF;
    END EXCEPTION;

  --SET DEBUG FILE TO "/resplogifx/archivoscartera/sp_descifra_archivo.out";
  --TRACE ON;

    LET vCodigo = TRIM(pCodigo);
    LET vBlinda = 'blinda_archivo_' || TRIM(vCodigo) || '.sh'; 

	FOREACH
		SELECT TRIM(usuario), TRIM(llave), TRIM(nomarch), TRIM(ruta_origen), TRIM(nomarch_salida),TRIM(ruta_destino), TRIM(ruta_originales), TRIM(ext_entrada),
		TRIM(ext_salida), TRIM(retorno_linea)
		INTO vUsuario, vLLave, vNomarch, vRutaOrigen, vNomarch_salida, vRutaDestino, vRutaOriginales, v_ext_entrada, v_ext_salida, v_retorno_linea
		FROM bdinteg:si_configura_pgp
		WHERE codigo = vCodigo
		ORDER BY secuencia

		IF vUsuario <>  user THEN
			LET cCodRet = '00200';
			LET cMensajeRet = 'Usuario para cifrado incorrecto';
			RETURN cCodRet,cMensajeRet;
		END IF;

		SYSTEM 'echo "export PATH=/usr/bin:/etc:/usr/sbin:/usr/ucb:/home/' || TRIM(vUsuario) ||'/bin:/usr/bin/X11:/sbin:.:/opt/pgp/bin:/informix/bin">' || TRIM(vRutaOrigen) || TRIM(vBlinda);
		SYSTEM 'echo "export HOME=/home/' || TRIM(vUsuario) || '">>' || TRIM(vRutaOrigen) || TRIM(vBlinda); 
		SYSTEM 'echo "/opt/pgp/bin/pgp --decrypt ' || TRIM(vRutaOrigen) || TRIM(vNomarch) || '.' || TRIM(v_ext_entrada) || cPassphrase || '''' ||TRIM(vLLave) || '''' || ' --output ' || TRIM(vRutaDestino) || '">>' || TRIM(vRutaOrigen) || TRIM(vBlinda);
		SYSTEM 'chmod 777 ' || TRIM(vRutaOrigen) || TRIM(vBlinda);   
		SYSTEM '/usr/bin/sh ' || TRIM(vRutaOrigen) || TRIM(vBlinda);
		
		SYSTEM 'mv ' || trim(vRutaOrigen) || trim(vNomarch) || '.' || TRIM(v_ext_entrada) || ' ' || vRutaOriginales;

	END FOREACH
    
	RETURN cCodRet,cMensajeRet;

END;
END PROCEDURE;