CREATE PROCEDURE "informix".sp_encriptaarchivo(cUsuario CHAR(50), cRutaArchivoOrigen CHAR(100), cRutaArchivoDestino CHAR(100), cRutaRespaldo CHAR(100),cNombreArchivo CHAR(50), cLlave CHAR(200))
RETURNING CHAR(6), CHAR(100);

/*DEFINICION DE VARIABLES*/
DEFINE iSqlErr  INTEGER;
DEFINE cCodRet 	CHAR(6);
DEFINE cComando CHAR(600);
DEFINE cMensaje CHAR(100);
DEFINE iExisteSH SMALLINT;


/*INICIALIZACION DE VARIABLES*/
LET cCodRet = '000000';
LET cMensaje = 'ENCRIPTACION CORRECTA';
LET cComando = '';
LET iExisteSH = 0;
	--SET DEBUG FILE TO '/informix/sp_encriptaarchiv.out';
	--TRACE ON;
BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensaje = "ENCRIPTACION INCORRECTA";			
			IF iExisteSH = 1 THEN
				LET cComando = 'rm -f '|| TRIM(cRutaArchivoOrigen) || 'encriptaarchivo.sh';
				SYSTEM cComando;
			END IF;						
			RETURN cCodRet, cMensaje;
		END IF;
	END EXCEPTION;
	
	IF cUsuario = '' OR cRutaArchivoOrigen = '' OR cRutaArchivoDestino = '' OR cNombreArchivo = '' OR cLlave = '' OR cRutaRespaldo = '' THEN
		LET cCodRet = '000001';
		LET cMensaje = "PARAMETROS DE ENCRIPTACION INCOMPLETOS/INCORRECTOS";
	ELSE
		
		--Genera el archivo "encriptaarchivo.sh" en la ruta origen que se recibio como parametro en el cual escribe los comandos necesarios
		--para exportar las variables de ambiente PATH y HOME, que se necesitan para poder encriptar archivos con PGP
		LET cComando = 'echo "export PATH=/usr/bin:/etc:/usr/sbin:/usr/ucb:/home/' || TRIM(cUsuario) ||'/bin:/usr/bin/X11:/sbin:.:/opt/pgp/bin:/informix/bin">' || TRIM(cRutaArchivoOrigen) || 'encriptaarchivo.sh';
		SYSTEM cComando; 
		
		LET iExisteSH = 1;
		
		LET cComando = 'echo "export HOME=/home/' || TRIM(cUsuario) || '">>' || TRIM(cRutaArchivoOrigen) || 'encriptaarchivo.sh';
		SYSTEM cComando;
		
		--Escribe en "encriptaarchivo.sh" el comando para encriptar el archivo		
		LET cComando = 'echo "/opt/pgp/bin/pgp --encrypt -i ' || TRIM(cRutaArchivoOrigen) || TRIM(cNombreArchivo) || ' -r ' || '''' || TRIM(cllave) ||
		'''' ||" --armor --compression --output " || TRIM(cRutaArchivoDestino)||' ">>' || TRIM(cRutaArchivoOrigen) || 'encriptaarchivo.sh';
		SYSTEM cComando;
		
		--Asigna permisos a "encriptaarchivo.sh"
		LET cComando = 'chmod 777 ' || TRIM(cRutaArchivoOrigen) || 'encriptaarchivo.sh';   
		SYSTEM cComando;
		
		--Ejecuta el bash "encriptaarchivo.sh"
		LET cComando = '/usr/bin/sh ' || TRIM(cRutaArchivoOrigen) || 'encriptaarchivo.sh';
		--|| TRIM(cRutaArchivoOrigen) ||'salida.out 2>&1" sysafore';
		SYSTEM cComando;
		
		IF TRIM(cRutaArchivoOrigen) <> TRIM(cRutaRespaldo) THEN
			LET cComando = 'mv ' || TRIM(cRutaArchivoOrigen) || TRIM(cNombreArchivo) || ' ' || cRutaRespaldo; 
			SYSTEM cComando;
		END IF;
		
		--Elimina el bash "encriptaarchivo.sh"
		LET cComando = 'rm -f '|| TRIM(cRutaArchivoOrigen) || 'encriptaarchivo.sh';
		SYSTEM cComando;		
	END IF;
	RETURN cCodRet, cMensaje;
END
END PROCEDURE
DOCUMENT
'PARAMETROS DE ENTRADA',
'cUsuario: Se refiere al usuario que se utilizara para encriptar el archivo, es necesario para cargar las variables de ambiente',
'cRutaArchivoOrigen: Se refiere a la ruta donde se encuentra el archivo que sera encriptado',
'cRutaArchivoDestino: Se refiere a la ruta donde sera depositado el archivo encriptado',
'cRutaRespaldo: Se refiere a la ruta donde se depositara el archivo original',
'cNombreArchivo: Se refiere al nombre del archivo <original> que sera encriptado',
'cLlave: Se refiere al USER ID o KEY ID de la llave que sera utilizada para encriptar el archivo',
'**********************************************************************************************',
'DESCRIPCION: Stored procedure para utilizar PGP encryption', 
'SOLICITO :Jaime Gonzalez',	
'AUTOR: Jose Angel Lopez Adams',
'FECHA: 29/05/2014',
'VERSION: 20140529.1151',
'BD: BDIPROG',
'VERSION: 20090616';

CREATE PROCEDURE "informix".sp_consultacuentasdestino_bpi_trans(p_NumCte CHAR(20), p_CvePago CHAR(2), p_Registros SMALLINT)
RETURNING
     CHAR(6)     as cod_ret, ---cod_ret
	 CHAR(20)    as cuenta, ---cuenta
	 CHAR(100)   as nombre, ---nombre
	 CHAR(50)    as banco, ---banco
	 CHAR(2)     as compcelular, ---compañia celular
	 CHAR(10)    as numcelular, ---numero celular
	 CHAR(40)    as correoelect, ---correo electronico
	 CHAR(2)     as cve_cuenta, ---cve cuenta
     CHAR(20)    as desc_cuenta, ---desc cuenta
     CHAR(13)    as rfc, ---rfc
	 MONEY(16,2) as monto_max, ---Monto Máximo
	 CHAR(1)     as cta_activa;    -- bandera de activación
		  
    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
    DEFINE vDesErr              CHAR(60);
	DEFINE v_CodDesc			CHAR(50);
	DEFINE v_CvePago			CHAR(2);
	DEFINE v_CtaDestino			CHAR(20);
	DEFINE v_Nombre				CHAR(100);
	DEFINE v_Banco				CHAR(50);
	DEFINE v_CompCel			CHAR(2);
	DEFINE v_NumCel				CHAR(10);
	DEFINE v_CorreoE			CHAR(40);
	DEFINE v_CveCuenta			CHAR(2);
	DEFINE v_ContReg			SMALLINT;
	DEFINE v_DescCta			CHAR(20);
    DEFINE v_Rfc                CHAR(13);
	DEFINE v_Canal				CHAR(2);
	DEFINE v_FechaInsert		DATE;
	DEFINE v_HoraInsert			DATETIME HOUR TO SECOND;
	DEFINE v_FechaHoraInsert	DATETIME YEAR TO FRACTION;
	DEFINE v_MontoMaximo		MONEY(16,2);
	DEFINE v_activo				CHAR(1);
	
	LET v_CodDesc			    = "";
	LET v_CvePago				= "";
	LET v_CtaDestino			= "";
	LET v_Nombre				= "";
	LET v_Banco					= "";
	LET v_CompCel				= "";
	LET v_NumCel				= "";
	LET v_CorreoE				= "";
	LET v_CveCuenta				= "";
	LET v_ContReg			 	= 0;
	LET v_DescCta				= "";
    LET v_Rfc                   = "";
	LET v_Canal					= "";
	LET v_MontoMaximo			= 0.00;
	LET v_activo				= "";
	
	SET LOCK MODE TO WAIT 10;

BEGIN

   ON EXCEPTION
        SET iSqlErr, iSamErr, vDesErr
        IF iSqlErr <> 0 THEN
                LET v_cod_ret = iSqlErr;
                --EXECUTE PROCEDURE bdinteg:sp_desc_ret(20, v_cod_ret)
                --INTO v_cod_ret, vDesErr;
        END IF;
        RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
    END EXCEPTION;

	--SET DEBUG FILE TO "/home/informix/raldana/RQI10664TranfBanc/bdiprog/sp_ConsultaCuentasDestino.out";
	--TRACE ON;

	SELECT cod_ret
	INTO v_cod_ret
	FROM  bdiprog:"informix".PP_MENSAJES
	WHERE cve_mensaje = "00";

	select banco || " " ||
		(CASE
			WHEN TRIM(vchrnombrecorto) = ''
				THEN descripcion
			ELSE
				vchrnombrecorto
		END) 
	INTO v_Banco
	FROM bdinteg:"informix".si_bancos
	WHERE banco = "137";

	IF (p_NumCte <> "" AND p_NumCte IS NOT NULL) AND (p_CvePago <> "" AND p_CvePago IS NOT NULL)  THEN
 		IF EXISTS (SELECT ct.cuenta FROM bdiprog:"informix".pp_ctasterceros ct, bdiprog:"informix".pp_cuentapago cp WHERE ct.num_cte = p_NumCte AND ct.cve_cuenta = cp.cve_cuenta)  THEN
                FOREACH
                    SELECT ct.cuenta, ct.nombre, b.banco|| "  " ||
					(CASE
						WHEN TRIM(vchrnombrecorto) = ''
						THEN descripcion
					ELSE
					vchrnombrecorto
					END), ct.cve_compania, ct.no_celular, ct.direc_correo, ct.cve_cuenta,ct.descrip_cta, ct.rfc, ct.canal_alta, ct.fecha_insert, ct.hora_insert, NVL(ct.monto_maximo,0)
                    INTO v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta, v_Rfc, v_Canal, v_FechaInsert, v_HoraInsert, v_MontoMaximo
                    FROM bdiprog:"informix".pp_ctasterceros ct, bdinteg:"informix".si_bancos b, bdiprog:"informix".pp_cuentapago cp
                    WHERE ct.num_cte = p_NumCte
                    AND ct.cve_banco = b.banco
                    AND ct.cve_cuenta = cp.cve_cuenta
                    AND cp.cve_pago = p_CvePago
                    AND ct.cve_estado = '01'   
					ORDER BY ct.descrip_cta, ct.nombre
				
					-- Si el canal es de internet, devolvera solo los registros que tengan 30 minutos o mas transcurridos despues de su alta
					IF v_Canal = '03' THEN
						LET v_FechaHoraInsert = ( YEAR(v_FechaInsert) || '-' || MONTH(v_FechaInsert) || '-' || DAY(v_FechaInsert) || ' ' || v_HoraInsert)::DATETIME YEAR TO FRACTION;
						IF (current - v_FechaHoraInsert) < '0 00:30:00' THEN
							LET v_activo = '0';														
						ELSE 
							LET v_activo = '1';																				
						END IF;
					END IF;
					
                    LET v_ContReg = v_ContReg + 1;

                    IF v_ContReg <= p_Registros THEN -- Si el registro no es mayor al numero de registro recibido, no regresa nada y continua con el siguiente registro
                        CONTINUE FOREACH;
                    END IF;					
                    RETURN v_cod_ret, v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta,v_Rfc, v_MontoMaximo,v_activo  WITH RESUME;
					
                END FOREACH;
		END IF
	ELSE
		SELECT cod_ret
		INTO v_cod_ret
		FROM  BDIPROG:"informix".PP_MENSAJES
		WHERE cve_mensaje = "01";

        RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
	END IF
END;
--##############################################################################
--## Procedimiento   : sp_consultacuentasdestino_bpi_trans
--## Version         : 1.0
--## Fecha creacion  : Diciembre de 2015
--## Descripcion     : Consulta las cuentas frecuente transfer de un cliente
--##############################################################################
END PROCEDURE;