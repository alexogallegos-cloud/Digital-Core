CREATE PROCEDURE "informix".sp_valida_sms_cte( pNumCte CHAR(9))
 RETURNING CHAR(3) as CodRet ,
		  SMALLINT  as valido,
		  CHAR(13) as telefono;

DEFINE cCodret   CHAR(3);
DEFINE iSql_err  INTEGER;
DEFINE iValido  INTEGER;
DEFINE cTel  CHAR(13);

LET cCodret     = '000';
LET iSql_err    = 0;
LET iValido    = 0;
LET cTel    = '';

BEGIN
	ON EXCEPTION SET iSql_err
		--LET cCodret = CAST(iSql_err AS CHAR);
		IF iSql_err <> 0 THEN
			LET cCodret = iSql_err;
			RETURN cCodret,iValido,cTel;
		END IF;
	END EXCEPTION;	
	
	--SET DEBUG FILE TO '/informix/jesus/sp_valida_sms_cte.sql';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    
	IF (SELECT COUNT(b.numcte)
		FROM bdinteg:"informix".si_telefonos_actual a
		LEFT JOIN bdinteg:"informix".si_bitsmstels b ON a.numcte=b.numcte AND a.telefono=b.telefono AND  b.bandera='t' AND  b.fecha::DATE = TODAY		
		WHERE a.numcte=pNumCte
		AND a.tipo_tel=2 AND a.status_tel='A'
		and fecha = (SELECT max(fecha) from bdinteg:"informix".si_bitsmstels c 
                        where c.numcte=a.numcte AND a.telefono=a.telefono 
                        AND  c.fecha::DATE = TODAY)
		) 
 > 0 THEN		
			LET iValido =1;
		
	END IF 
    
SELECT  LIMIT 1 telefono
INTO cTel
FROM bdinteg:"informix".si_telefonos_actual a
WHERE a.numcte=pNumCte
AND a.tipo_tel=2 AND a.status_tel='A';
		
	RETURN cCodret,iValido, cTel;

END;
END PROCEDURE
DOCUMENT
'Autor:	JESUS MANUEL AGUILAR HEREDIA',
'FECHA:	30/SEP/2016',
'DESCRIPCION: se crea procedimiento para ser usado en el flujo de 2 credito.',
'BD: BDINTEG';

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