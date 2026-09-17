CREATE PROCEDURE "informix".sp_domi_valida_cuentatarjeta(pNumCuentaTarjeta CHAR(18), p_sUserStatus CHAR(8))
	RETURNING	CHAR (5) 	AS CodRet, --Codigo de Retorno
				CHAR (2) 	AS TipoCuenta, --Tipo de cuenta
				CHAR (3) 	AS ClaveBanco, --Clave del banco
				CHAR (40) 	AS NombreBanco, --Descripcion del banco
				CHAR (40) 	AS NombreCortoBanco, -- Nombre de Banco
				CHAR (12)	AS CuentaCredito, -- Numero de cuenta o credito
				CHAR (16)	AS NumTarjeta, --Numero de tarjeta
				CHAR (18)	AS Clabe; -- CLABE Interbancaria de la cuenta
					
	--DECLARACION DE VARIABLES	
	DEFINE sql_err					INTEGER;
	DEFINE cCodret					CHAR(5);
	DEFINE cNumTarjeta				CHAR(16);
	DEFINE bCuenta					BOOLEAN;
	DEFINE cBIN						CHAR(6);
	DEFINE cTipoCuenta				CHAR(2);
	DEFINE cClaveBanco				CHAR(3);
	DEFINE cNombreBanco				CHAR(40);
	DEFINE cNombreCortoBanco		CHAR(40);
	DEFINE cIdTipoCuenta			CHAR(1);
	DEFINE cCuentaCredito			CHAR(12);
	DEFINE cClabe					CHAR(18);
	DEFINE cCodret2					CHAR(5);
	DEFINE cMensajeRespuesta 		CHAR (110);
	DEFINE cProducto 				CHAR (4);
	DEFINE cNumCte 					CHAR (9);

	
	--Inicializar Variables
	LET sql_err					= 0;
	LET cCodret					= '00000';
	LET cNumTarjeta				= '';
	LET bCuenta					= 'f';
	LET cBIN					= '';
	LET cTipoCuenta				= '';
	LET cClaveBanco				= '';
	LET cNombreBanco			= '';
	LET cNombreCortoBanco		= '';
	LET cIdTipoCuenta			= '';
	LET cCuentaCredito			= '';
	LET cClabe 					='';
	LET cCodret2				= '';
	LET cMensajeRespuesta		= '';
	LET cProducto				= '';
	LET cNumCte					= '';

	
	--SET DEBUG FILE TO "/tmp/sp_domi_valida_cuentatarjeta.out"
	--TRACE ON;
	
	BEGIN
			
		--Manejo de excepciones (errores)
		ON EXCEPTION SET sql_err 
			IF sql_err <> 0 THEN
				LET cCodret = sql_err;
				
				INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error, Hora_Error, Cod_Error, Nombre_Arch, Sp_Llamado, Mensaje_Error, User_Insert, Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_cuentatarjeta', trim(pNumCuentaTarjeta), p_sUserStatus, CURRENT);
				
				--Regresa Resultados
				RETURN cCodret, cTipoCuenta, cClaveBanco, cNombreBanco, cNombreCortoBanco, cCuentaCredito, cNumTarjeta, cClabe;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		
		-- Se valida el parametro de entrada
		IF NVL(pNumCuentaTarjeta, '') = '' OR NVL(p_sUserStatus, '') = '' THEN
			LET cCodret = '99939'; --Parametros de entrada estan en blanco.
			
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_cuentatarjeta', trim(pNumCuentaTarjeta) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
			 --Regresa Resultados
			RETURN cCodret, cTipoCuenta, cClaveBanco, cNombreBanco, cNombreCortoBanco, cCuentaCredito, cNumTarjeta, cClabe;
		END IF;
		

		IF LENGTH(pNumCuentaTarjeta) = 11 THEN
		-- Cuenta de debito
			LET bCuenta = 't'; -- El parametro de entrada pertenece a una cuenta
			
			SELECT producto INTO cProducto FROM bdicheq:"informix".sc_maechq WHERE cuenta = pNumCuentaTarjeta;
			
			IF NVL(cProducto, '') <> '1800' THEN
				IF EXISTS(
					SELECT DISTINCT 1 FROM bdicheq:"informix".sc_tarjeta
					WHERE cuenta = pNumCuentaTarjeta AND empresa = '001' AND tipo_tarjeta = 'T' 
					AND num_tarjeta <> '' 
				)
				THEN
					SELECT num_tarjeta 
					INTO cNumTarjeta
					FROM bdicheq:"informix".sc_tarjeta 
					WHERE cuenta = pNumCuentaTarjeta AND empresa = '001' AND tipo_tarjeta = 'T' AND num_tarjeta <> ''
					AND secuencia = (SELECT MAX(secuencia) FROM bdicheq:"informix".sc_tarjeta 
									 WHERE cuenta = pNumCuentaTarjeta AND tipo_tarjeta = 'T');
				END IF;
			END IF;
		
			SELECT cuenta, cuenta_clabe
			INTO cCuentaCredito, cClabe
			FROM bdicheq:"informix".sc_maechq 
			WHERE cuenta = pNumCuentaTarjeta 
			AND status_cta IN ('1','4','5')
			AND empresa = '001';
					
			--Se le asigna el numero de tarjeta al parametro de entrada para obtener el resto de informacion de retorno
			IF NVL(cNumTarjeta, '') != '' AND NVL(cClabe, '') != '' THEN
				LET pNumCuentaTarjeta = cClabe;
			ELIF NVL(cNumTarjeta, '') = '' AND NVL(cClabe, '') != '' AND NVL(cProducto, '') = '1800' THEN
				LET pNumCuentaTarjeta = cClabe;
			ELSE 
				LET cCodret = '99940'; --El numero de cuenta, tarjeta o clabe es incorrecto.
				LET cTipoCuenta = '';
				LET cClaveBanco = '';
				LET cNombreCortoBanco = '';
				
				EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
				INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_cuentatarjeta', trim(pNumCuentaTarjeta) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
				
				RETURN cCodret, cTipoCuenta, cClaveBanco, cNombreBanco, cNombreCortoBanco, cCuentaCredito, cNumTarjeta, cClabe;

			END IF;
		END IF;
		
		IF LENGTH(pNumCuentaTarjeta) = 18 THEN
		-- Clabe Interbancaria		
			LET cClaveBanco = SUBSTR(pNumCuentaTarjeta,1,3);
			LET cTipoCuenta = '40';
			
			SELECT cuenta, cuenta_clabe
			INTO cCuentaCredito, cClabe
			FROM bdicheq:"informix".sc_maechq 
			WHERE cuenta_clabe = pNumCuentaTarjeta 
			AND status_cta IN ('1','4','5')
			AND empresa = '001';
			
			SELECT descripcion, vchrnombrecorto
			INTO cNombreBanco, cNombreCortoBanco
			FROM bdinteg:"informix".si_bancos 
			WHERE banco = cClaveBanco  and 
			flg_domi_r='1';
			
			--Si el parametro de entrada era una cuenta se define como 01
			IF (bCuenta = 't') THEN
				LET cTipoCuenta = '01';
			END IF;
			
			IF NVL(cTipoCuenta, '') = '' OR NVL(cClaveBanco, '') = '' OR NVL(cNombreBanco, '') = '' OR NVL(cNombreCortoBanco, '') = '' OR NVL(cCuentaCredito, '') = '' THEN
				LET cCodret = '99940'; --El numero de cuenta, tarjeta o clabe es incorrecto.
				LET cTipoCuenta = '';
				LET cClaveBanco = '';
				LET cNombreCortoBanco = '';
				
				EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
				INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_cuentatarjeta', trim(pNumCuentaTarjeta) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
				
			END IF;
			
			RETURN cCodret, cTipoCuenta, cClaveBanco, cNombreBanco, cNombreCortoBanco, cCuentaCredito, cNumTarjeta, cClabe;
		END IF;

		IF LENGTH(pNumCuentaTarjeta) = 12 THEN
		--Numero de credito
			LET bCuenta = 't'; -- El parametro de entrada pertenece a una cuenta
			
			SELECT a.num_credito, a.cuenta_clabe, b.num_tarjeta
			INTO cCuentaCredito, cClabe, cNumTarjeta
			FROM bdicred:"informix".sd_maecred a
			INNER JOIN bdicred:"informix".sd_tarjeta b
			ON a.num_credito = b.num_credito
			WHERE a.status_cred IN('E1','E2','E3')
			AND a.num_credito = pNumCuentaTarjeta
			AND b.status_tar <> 'C'
			AND b.num_tarjeta <> ''
			AND b.tipo_tarjeta = 'T'
			AND b.secuencia = (SELECT MAX(secuencia) FROM bdicred:"informix".sd_tarjeta 
							   WHERE num_credito = pNumCuentaTarjeta AND tipo_tarjeta = 'T' AND status_tar <> 'C');
			
			--Se le asigna el numero de tarjeta al parametro de entrada para obtener el resto de informacion de retorno
			IF NVL(cNumTarjeta, '') != '' THEN
				LET pNumCuentaTarjeta = cNumTarjeta;
			ELSE 
				LET cCodret = '99940'; --El numero de cuenta, tarjeta o clabe es incorrecto.
				LET cTipoCuenta = '';
				LET cClaveBanco = '';
				LET cNombreCortoBanco = '';
				
				EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
				INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_cuentatarjeta', trim(pNumCuentaTarjeta) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
				
				RETURN cCodret, cTipoCuenta, cClaveBanco, cNombreBanco, cNombreCortoBanco, cCuentaCredito, cNumTarjeta, cClabe;

			END IF;
		END IF;
			
		IF LENGTH(pNumCuentaTarjeta) = 16 THEN
		--Tarjeta
			LET cBIN = SUBSTR(pNumCuentaTarjeta,1,6);
				
			SELECT banco.banco, upper(bin.creditodebito), banco.descripcion, banco.vchrnombrecorto
			INTO cClaveBanco, cIdTipoCuenta, cNombreBanco, cNombreCortoBanco
			FROM bdicheq:"informix".sc_bines bin
			INNER JOIN bdinteg:"informix".si_bancos banco
			  ON bin.cve_banco = banco.banco
			WHERE bin.bin = cBIN
			AND banco.flg_domi_r = '1'; 

			 IF cIdTipoCuenta = 'D' THEN 
				LET cTipoCuenta='03';

				SELECT a.cuenta, b.num_tarjeta, a.cuenta_clabe
				INTO cCuentaCredito, cNumTarjeta, cClabe 
				FROM bdicheq:"informix".sc_maechq a
				INNER JOIN bdicheq:"informix".sc_tarjeta b
				ON a.cuenta = b.cuenta
				INNER JOIN intercard:"informix".tarjeta c 
				ON c.numtarjeta = b.num_tarjeta
				WHERE b.num_tarjeta= pNumCuentaTarjeta  
				AND c.codstatusasignada = 'SIA'
				AND a.status_cta IN ('1','4','5')
				AND b.status_tar = 'A'
				AND a.empresa = '001'
				AND codstatustarjeta in ('ACT', 'BLT', 'BLO')
				AND c.titular = 'T';
				
			  ELIF cIdTipoCuenta = 'C' THEN 
				LET cTipoCuenta = '05';
				
				SELECT a.num_credito, b.num_tarjeta 
				INTO cCuentaCredito, cNumTarjeta
				FROM bdicred:"informix".sd_maecred a
				INNER JOIN bdicred:"informix".sd_tarjeta b
				ON a.num_credito=b.num_credito
				INNER JOIN intercard:"informix".tarjeta c 
				ON c.numtarjeta = b.num_tarjeta
				WHERE a.status_cred IN('E1','E2','E3')
				AND b.num_tarjeta = pNumCuentaTarjeta
				AND c.codstatusasignada = 'SIA'
				AND b.status_tar <> 'C'
				AND codstatustarjeta in ('ACT', 'BLT', 'BLO')
				AND c.titular = 'T';

			END IF;
			
			--Si el parametro de entrada era una cuenta se define como 01
			IF (bCuenta = 't') THEN
				LET cTipoCuenta = '01';
			END IF;
			
			IF NVL(cTipoCuenta, '') = '' OR NVL(cClaveBanco, '') = '' OR NVL(cNombreBanco, '') = '' OR NVL(cNombreCortoBanco, '') = '' OR NVL(cCuentaCredito, '') = '' OR NVL(cNumTarjeta, '') = '' THEN
				LET cCodret = '99940'; --El numero de cuenta, tarjeta o clabe es incorrecto.
				LET cTipoCuenta = '';
				LET cClaveBanco = '';
				LET cNombreCortoBanco = '';
				
				EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
				INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_cuentatarjeta', trim(pNumCuentaTarjeta) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
				
			END IF;
			
			RETURN cCodret, cTipoCuenta, cClaveBanco, cNombreBanco, cNombreCortoBanco, cCuentaCredito, cNumTarjeta, cClabe;
		ELSE
			LET cCodret = '99940'; --El numero de cuenta, tarjeta o clabe es incorrecto.
			
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
	
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_cuentatarjeta', trim(pNumCuentaTarjeta) || ' - ' || trim(cMensajeRespuesta), p_sUserStatus, CURRENT);
			
			RETURN cCodret, cTipoCuenta, cClaveBanco, cNombreBanco, cNombreCortoBanco, cCuentaCredito, cNumTarjeta, cClabe;

		END IF;
	END;
END PROCEDURE 
DOCUMENT
'AUTOR      : Edith Mendoza Barraza',
'DESCRIPCION: Se encarga de definir si se recibe cuenta, tarjeta o clabe asi como retornar la informacion del banco',
'FECHA      : 08/03/2022',
'BD         : BDIDOMI';

CREATE PROCEDURE "informix".sp_domi_generaarchivo(psNombreArchivo CHAR(20),psFechaPres CHAR(8),psId CHAR(2))
RETURNING CHAR(5) AS codret;

--****************************************************************************************************
-- DESCRIPCION: Guarda la estadística del consumo de la sucursal de manera mensual.
-- AUTOR : Rochin Rocha Edgar Ivan
-- FECHA : 16/07/2009
-- BD: bdidomi
-- SISTEMA : Domiciliacion
-- MODIFICADO : 05/08/2009 parametro recibido fecha insert reemplazado por fecha presentacion.
--****************************************************************************************************

DEFINE viSqlErr INTEGER;
DEFINE vsRepositorio CHAR(100);
DEFINE vsCodRet CHAR(5);
DEFINE vsSQL CHAR(2204);
--DEFINE vsSQL1 VARCHAR(100);
DEFINE vsSQL1 VARCHAR(255);
DEFINE vsSQL2 CHAR(2004);
DEFINE vsSQL3 CHAR(100);
DEFINE vsArchTemp CHAR(23);
DEFINE vsArchTemp1 CHAR(23);
DEFINE vsUsoFutBanc CHAR(12);
DEFINE cHora				CHAR(8);
DEFINE cFechaArchivoOUT		CHAR(15);
DEFINE iPaso				SMALLINT;

LET viSqlErr = 0;
LET vsRepositorio = '';
LET vsCodRet = '';
LET vsSQL = '';
LET vsSQL1 = '';
LET vsSQL2 = '';
LET vsSQL3 = '';
LET vsArchTemp = '';
LET vsArchTemp1 = '';
LET vsUsoFutBanc = '';

LET cHora	= TO_CHAR(EXTEND(CURRENT, HOUR TO SECOND),'%H:%M:%S');
LET cFechaArchivoOUT	= YEAR(CURRENT::DATE)||LPAD(MONTH(CURRENT::DATE),2,'0')||LPAD(DAY(CURRENT::DATE),2,'0')||SUBSTR(cHora,1,2)||SUBSTR(cHora,4,2)||SUBSTR(cHora,7,2)||'_';
LET iPaso	= 0;

BEGIN

ON EXCEPTION SET viSqlErr   --Cacha el error en caso de que exista y regresa un valor predeterminado.
        IF viSqlErr <> 0 THEN
        RETURN viSqlErr;
        END IF;
END EXCEPTION;
ON EXCEPTION IN(-668) SET viSqlErr	
	IF iPaso NOT IN(5,8,9,10,11,12) THEN 
		LET vsCodRet = viSqlErr;
		RETURN vsCodRet;
	END IF;
END EXCEPTION WITH RESUME;

SET ISOLATION DIRTY READ;
SET LOCK MODE TO wait 3;

--Se le quitan espacion en blanco a nombre de archivo
LET psNombreArchivo = TRIM(psNombreArchivo);

IF EXISTS(SELECT nombre_arch FROM bdidomi:dom_cce_encabezado_paso WHERE nombre_arch = psNombreArchivo)THEN
        IF EXISTS(SELECT cod_param FROM bdidomi:dom_parametros WHERE cod_param = psId)THEN
			--Selecciona el repositorio del archivo a generar.
			SELECT valor INTO vsRepositorio FROM bdidomi:dom_parametros WHERE cod_param = psId;
            --Genera archivo.
            LET vsArchTemp = cFechaArchivoOUT||'tmp1.txt';
            LET vsArchTemp1 = cFechaArchivoOUT||'tmp2.txt';
			
			LET iPaso = 1;
            LET vsSQL1 = 'echo "UNLOAD TO ' || TRIM(vsRepositorio) || TRIM (vsArchTemp) || ' DELIMITER ' || '''£''' || ' " > '|| TRIM(vsRepositorio) || cFechaArchivoOUT||'.sql';
			LET vsSQL1 = TRIM(vsSQL1);
			SYSTEM vsSQL1;
                
				
				
				LET vsSQL2 = 'echo "SELECT tpo_registro || num_secuencia || cod_operacion || cve_banco || sentido || servicio || num_bloque || fecha_presentacion ||'
                || " cod_divisa || cve_rechazo_bl || modalidad || '                                                                                                                                                                                                                                                                                                                                                                                                  Ø' FROM bdidomi:dom_cce_encabezado_paso WHERE nombre_arch = '"||psNombreArchivo||"' AND fecha_presentacion = '"||psFechaPres||"'"
                || " UNION"
                || " SELECT tipo_registro || num_secuencia || cod_operacion || cod_divisa || fecha_trans || banco_presentador || banco_receptor || importe ||"
                || " uso_futuro_ccen || tipo_operacion || fecha_aplica || tipo_cta_ord || num_cta_ord || nombre_ord || rfc_ord || tipo_cta_rec || num_cta_rec ||"
                || " nombre_rec || rfc_rec || ref_servicio || nombre_titular_serv || importe_iva || ref_numerica || ref_leyenda || clave_rastreo || motivo_dev || fecha_pres_ini ||"
                || " '            Ø' FROM bdidomi:dom_cce_detalle_paso WHERE nombre_arch = '"||psNombreArchivo||"' AND fecha_presentacion = '"||psFechaPres||"'"
                || " UNION"
                || " SELECT tipo_registro || num_secuencia || cod_operacion || num_bloque || num_operaciones ||"
                || " imp_operaciones || '                                                                                                                                                                                                                                                                                                                                                                                           Ø' FROM bdidomi:dom_cce_sumario_paso WHERE nombre_arch = '"||psNombreArchivo||"' AND fecha_presentacion = '"||psFechaPres||"'";

                LET vsSQL3 = ' " >> '|| TRIM(vsRepositorio) || cFechaArchivoOUT||'.sql';
                LET vsSQL3 = TRIM(vsSQL3);
                LET vsSQL = vsSQL2 || vsSQL3;
                --Verifica que no este vacia la consulta.
                IF ( vsSQL <> '' ) THEN
					SYSTEM vsSQL;
					--Permiso para la creacion de archivo.
					LET iPaso = 2;
					--Produccion
					LET vsSQL = '/ifxsif01/bin/dbaccess bdidomi ' || TRIM(vsRepositorio) || cFechaArchivoOUT||'.sql>> '||TRIM(vsRepositorio)||TRIM(cFechaArchivoOUT)||'.out 2>&1';
					
					
					
					--Desarrollo
					--LET vsSQL = '/informix/bin/dbaccess bdidomi ' || TRIM(vsRepositorio) || cFechaArchivoOUT||'.sql > '||TRIM(vsRepositorio)||TRIM(cFechaArchivoOUT)||'.out 2>&1';
					SYSTEM vsSQL ;
											
					--Elimina el caracter delimitador '?'.
					LET iPaso = 3;
					LET vsSQL =  "sed 's/£$//g' " || TRIM(vsRepositorio) || TRIM (vsArchTemp) || " > " || TRIM(vsRepositorio) || TRIM (vsArchTemp1);
					SYSTEM vsSQL;
					--Elimina el caracter delimitador 'x'.
					LET iPaso = 4;
					LET vsSQL =  "sed 's/Ø$//g' " || TRIM(vsRepositorio) || TRIM (vsArchTemp1) || " > " || TRIM(vsRepositorio) || TRIM (psNombreArchivo);
					SYSTEM vsSQL;

					--Operacion exitosa "Archivo Generado".
					--se dan permiso a todos para el archivo 
					LET iPaso = 5;
					--LET vsSQL = 'chmod 666 ' || TRIM(vsRepositorio) || TRIM (psNombreArchivo);
					LET vsSQL = 'chmod 777 ' || TRIM(vsRepositorio) || TRIM (psNombreArchivo);
					SYSTEM vsSQL ;
										
					LET iPaso = 6;
					LET vsSQL = 'cp ' || TRIM(vsRepositorio) || TRIM (psNombreArchivo)  ||' '|| TRIM(vsRepositorio)|| TRIM (psNombreArchivo)  ||'.resp';
					SYSTEM vsSQL;	
					
					--Borrar diagonales del archivo.
					LET iPaso = 7;
					LET vsSQL = 'grep -lr -e "1" ' || TRIM(vsRepositorio) || TRIM (psNombreArchivo)  ||'.resp | xargs sed ''s/\\\\/\\/g'' > '|| TRIM(vsRepositorio) || 
					TRIM (psNombreArchivo);
					SYSTEM vsSQL;
					
					LET iPaso = 8;
					LET vsSQL = 'rm '|| TRIM(vsRepositorio) || TRIM (psNombreArchivo)  ||'.resp';
					SYSTEM vsSQL;
					
					--Borra el archivo temporal.
					LET iPaso = 9;
					LET vsSQL = 'rm ' || TRIM(vsRepositorio) || TRIM(vsArchTemp);
					SYSTEM vsSQL;
					
					--Borra el archivo temporal1.
					LET iPaso = 10;
					LET vsSQL = 'rm ' || TRIM(vsRepositorio) || TRIM(vsArchTemp1);
					SYSTEM vsSQL;

					--Borra el archivo de control.
					LET iPaso = 11;
					LET vsSQL = 'rm ' || TRIM(vsRepositorio) || cFechaArchivoOUT||'.sql';
					SYSTEM vsSQL;
					
					LET iPaso = 12;
					LET vsSQL = 'rm ' || TRIM(vsRepositorio) || cFechaArchivoOUT||'.out';
					SYSTEM vsSQL;
					LET vsCodRet = '00000';
                ELSE
                        --No fue posible generar el archivo.
                    LET vsCodRet = '01002';
                END IF ;
        ELSE
        --El Id proporcionado no fue localizado.
        LET vsCodRet = '01001';
        END IF;
ELSE
        --El nombre del archivo proporcionado no fue localizado.
        LET vsCodRet = '01000';
END IF;

RETURN vsCodRet;

END;
END PROCEDURE;