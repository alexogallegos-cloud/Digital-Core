create procedure "informix".sp_generaarchivosat(cTipoArchivo CHAR(2), pUsuario CHAR(8),cNomArchivo VARCHAR (20), cArchivoControl VARCHAR (20))
--*******************************************************************************************************
-- Realizo   :Alejandro Osuna
-- Proyecto :  Excencion de personas morales
-- Actividad :Se crean los diferentes archivos de envio al SAT
-- Fecha     :08 de  septiembre de 2008
--*******************************************************************************************************
--Datos de retorno
RETURNING  CHAR(6), CHAR(20), CHAR(1), CHAR(40),CHAR(200), CHAR(1);
--Definicion de variables
DEFINE vsqlerr                     INTEGER;
DEFINE cCodRet                     CHAR(6);
DEFINE pTipoError                  CHAR(1);
DEFINE pSpLlamado                  CHAR(40);
DEFINE pMostrado                   CHAR(1);
DEFINE tHora                       CHAR (25);
DEFINE cHora                       CHAR (2);
DEFINE cNumArchivo                 CHAR(1);
DEFINE cPrefijo                    CHAR(2);
DEFINE cClaveBan                   CHAR(5);
DEFINE cFechaArc                   CHAR(8);
DEFINE cFechaSer                   CHAR(10);
DEFINE cNombre                     CHAR(16);
DEFINE sRuta                       CHAR(90);
DEFINE sRutaFinal                  CHAR(90);
DEFINE vsSQL                       CHAR (1000) ;
DEFINE vsSQL1                      CHAR (300);
DEFINE vsSQL2                      CHAR (400) ;
DEFINE vsSQL3                      CHAR (150);
DEFINE vsSQLC                      CHAR (1000) ;
DEFINE vsSQL1C                     CHAR (300);
DEFINE vsSQL2C                     CHAR (400) ;
DEFINE vsSQL3C                     CHAR (150);
DEFINE cFechaRes                   DATE;
DEFINE cStatus                     CHAR(1);
DEFINE iNoRegistro                 INT;
DEFINE cCodEnvio                   CHAR(1);
DEFINE cNumSele                    CHAR(1);
DEFINE pMensaje                    CHAR(200);
DEFINE cPrefijoControl             CHAR(2);
DEFINE cNombreControl              CHAR(16);
DEFINE cRegistroControl            CHAR(1000);
DEFINE iRegistro                   INT;
DEFINE iRegistroResp               INT;
DEFINE iRegistroTotal              INT;
DEFINE iRegistrosRfcResp           INT;
DEFINE iEstado                     INT;
DEFINE  iretorno                   INTEGER;
DEFINE cRuta_Repositorio 		   CHAR(90);
DEFINE cRuta_Procesos              CHAR(90);
DEFINE cUsuarioRemoto 			   CHAR(20);
DEFINE cPassWord     			   CHAR(15);
DEFINE cIpRuta            		   CHAR(15);
DEFINE cEnviaArchivo  			   CHAR(300);
DEFINE sRutaArchivo                CHAR(30);
DEFINE sRutaCopia                  CHAR(30);
DEFINE cNombreError                CHAR(20);
DEFINE cControlError               CHAR(20);
DEFINE cErrorSP                    CHAR(6);
DEFINE cNombreAcuse                CHAR(20);
DEFINE cNombreControlAcuse         CHAR(20);
DEFINE cPrefijoDatos 			   CHAR(2);
DEFINE cDatoAcuse 				   CHAR(2);
DEFINE cStatusAcuse 			   CHAR(1);
DEFINE cEstado    				   CHAR(1);
DEFINE cRfc 					   CHAR(13);
DEFINE cNombreRechazo              CHAR(20);
DEFINE  cNombreControlstatus       CHAR(20);
DEFINE vIpDest 					   CHAR(30);
DEFINE vUsuarioDestino 			   CHAR(30);
DEFINE sBanderaError               CHAR(2);
DEFINE cClave 					   CHAR(5);
DEFINE cFecha 					   CHAR(8);
DEFINE cClaveRe 				   CHAR(5);
DEFINE cFechaRe 				   CHAR(8);
DEFINE cEliminarNombre 			   CHAR(20);
DEFINE  cEliminarControl 		   CHAR(20);
DEFINE iRegistrosRespuesta			integer;
--- inicializacion de variables
LET cCodRet = "";
LET pTipoError = "";
LET  pSpLlamado  = "";
LET pMostrado = "";
LET cNombre = "";
LET tHora = "";
LET cHora = "";
LET cNumArchivo = "";
LET cPrefijo = "";
LET cClaveBan = '';
LET cFechaSer = "";
LET cFechaArc = "";
LET vsqlerr = "";
LET sRuta  = "";
LET sRutaFinal = "";
LET vsSQL = '' ;
LET vsSQL1 = '' ;
LET vsSQL2 = '' ;
LET vsSQL3 = '' ;
LET vsSQLC = '' ;
LET vsSQL1C = '' ;
LET vsSQL2C = '' ;
LET vsSQL3C = '' ;
LET cStatus = '';
LET iNoRegistro = '0';
LET cCodEnvio   = '';
LET cRegistroControl = '0';
LET cNombreAcuse  = '0';
LET iRegistroTotal = '0';
LET iEstado = '0';
LET  iretorno = 0;
LET cRuta_Repositorio = "";
LET cRuta_Procesos = "";
LET  cUsuarioRemoto = "";
LET cPassWord   = "";
LET cIpRuta = "";
LET cEnviaArchivo = "";
LET sRutaArchivo = "";
LET sRutaCopia    = "";
LET cNombreError = "";
LET cControlError  = "";
LET pMensaje = "";
LET cErrorSP = "";
LET cNombreControlAcuse = "";
LET cPrefijoDatos  = "";
LET cDatoAcuse = "";
LET cStatusAcuse = "";
LET cNombreError = "";
let cEstado = '';
LET cRfc = "";
LET cNombreRechazo = "";
LET cNombreControlstatus = "";
LET iRegistrosRfcResp = "";
LET vIpDest = '';
LET vUsuarioDestino = '';
LET sBanderaError = '';
LET cClave = '';
LET cFecha = '';
LET cClaveRe = '';
LET cFechaRe = '';
LET cEliminarNombre = '';
LET cEliminarControl = '';

	--SET DEBUG FILE TO "/home/informix/sp_generaarchivosat_dos.out";
	--TRACE ON;
	BEGIN
		ON EXCEPTION  SET vsqlerr
            IF vsqlerr <> 0  THEN
                    LET pTipoError = 'P';
                    LET pSpLLamado = 'sp_generaarchivosat';
                    LET pMostrado = 'N';
                    LET  cCodRet  = vsqlerr;

                    IF (cNombreError = '') or (cNombreError is null) THEN
                      LET  cNombreError = 'GENERICO';
                    END IF;
                     IF (pMensaje = '') or (pMensaje is null) THEN
                       LET  pMensaje = 'Error de Informix';
                    END IF;
                    IF cTipoArchivo = '01' THEN
                            --UPDATE bdilide:sl_consat SET estado = 'E'  WHERE nombre_arch = cNombre;

                            IF (sBanderaError = 3) or (sBanderaError = 4) THEN
									UPDATE bdilide:sl_archsat SET status = 'E'  WHERE nombre_arch = cNombre;
                                    UPDATE bdilide:sl_consat SET estado = 'E'  WHERE estado = 'P' ;
                                    LET  cNomArchivo = cNombre;
                            END IF;
                            IF (sBanderaError = 5) or (sBanderaError = 6) or (sBanderaError = 7) THEN
                                    UPDATE bdilide:sl_archsat SET status = 'E' WHERE nombre_arch = cNombre;
                                    UPDATE bdilide:sl_archsat SET status = 'E' WHERE nombre_arch = cNombreControl;
                                    UPDATE bdilide:sl_consat SET estado = 'E'  WHERE nombre_arch = cNombre;
                                    UPDATE bdilide:sl_consat SET estado = 'E'  WHERE estado = 'P' ;
                                    LET cArchivoControl = cNombreControl;
                                    LET  cNomArchivo = cNombre;
                            END IF;
                            execute procedure bdilide:sp_grabarErrores(cNombreError, cCodRet, pTipoError, pSpLLamado, pMensaje, pMostrado)  into cErrorSP;
                            execute procedure bdilide:sp_eliminaarchivo(cTipoArchivo,pUsuario,cNomArchivo,cArchivoControl) into cErrorSP;
                            COMMIT WORK;
                            RETURN cCodRet, cNombreError,  pTipoError, pSpLLamado, pMensaje, pMostrado;
                    END IF;
                     IF cTipoArchivo = '02' THEN
                            IF sBanderaError = 1 THEN
                                    UPDATE bdilide:sl_archsat SET status = 'E' WHERE nombre_arch = cNomArchivo;
                                    UPDATE bdilide:sl_archsat SET status = 'E' WHERE nombre_arch = cArchivoControl;
                                    execute procedure bdilide:sp_grabarErrores(cNombreError, cCodRet, pTipoError, pSpLLamado, pMensaje, pMostrado)  into cErrorSP;
                                    LET cTipoArchivo = '06';
				     execute procedure bdilide:sp_eliminaarchivo(cTipoArchivo,pUsuario,cNomArchivo,cArchivoControl) into cErrorSP;
                                     Commit work;
                                     RETURN cCodRet, cNombreError,  pTipoError, pSpLLamado, pMensaje, pMostrado;
                           END IF;
                            IF sBanderaError = 0 THEN
                                UPDATE bdilide:sl_archsat SET status = 'E' WHERE nombre_arch = cNomArchivo;
                                UPDATE bdilide:sl_archsat SET status = 'E' WHERE nombre_arch = cArchivoControl;
                            end IF;
                            IF (sBanderaError  >  2) AND (sBanderaError <  10 )THEN
                                UPDATE bdilide:sl_archsat SET status = 'E' WHERE nombre_arch = cNomArchivo;
                                UPDATE bdilide:sl_archsat SET status = 'E' WHERE nombre_arch = cArchivoControl;
                                UPDATE bdilide:sl_archsat SET status = 'E' WHERE nombre_arch = cNombreControl;
                            END IF;
                                                       
                            execute procedure bdilide:sp_eliminaarchivo(cTipoArchivo,pUsuario,cNomArchivo,cArchivoControl) into cErrorSP;
                            execute procedure bdilide:sp_grabarErrores(cNombreError, cCodRet, pTipoError, pSpLLamado, pMensaje, pMostrado)  into cErrorSP;
                            
                    END IF;
					LET pTipoError = 'P';
					LET pSpLLamado = 'sp_generaarchivosat';
					LET pMostrado = 'N';
                    Commit work;
					execute procedure bdilide:sp_grabarErrores(cNombreError, cCodRet, pTipoError, pSpLLamado, pMensaje, pMostrado)  into cErrorSP;
					RETURN cCodRet, cNombreError,  pTipoError, pSpLLamado, pMensaje, pMostrado;
                   
            END IF;
        END  EXCEPTION;
        LET pTipoError = 'P';
        LET pSpLLamado = 'sp_generaarchivosat';
        LET pMostrado = 'N';
         --Validacion del tipo de archivo
		IF cTipoArchivo = "" or cTipoArchivo is NULL THEN
			LET cCodRet = '001';
			LET pMensaje = 'Validacion de tipo de archivo';

			execute procedure bdilide:sp_grabarErrores(cNombreError, cCodRet, pTipoError, pSpLLamado, pMensaje, pMostrado)  into cErrorSP;
			Commit work;
			RETURN cCodRet, cNombreError,  pTipoError, pSpLLamado, pMensaje, pMostrado;
		END IF;
        --Parametros necesarios
        SELECT TRIM(desc_valor) INTO vIpDest FROM bdilide:sl_parametros WHERE cve_param = '25' and valor = '01';
        SELECT  TRIM(desc_valor) INTO vUsuarioDestino FROM bdilide:sl_parametros WHERE cve_param = '25' and valor = '02';
        SELECT trim(desc_valor) INTO sRutaArchivo      FROM bdilide:sl_parametros WHERE cve_param = '25' and valor = '06';
        SELECT TRIM(desc_valor) INTO cClaveBan  FROM bdilide:sl_parametros WHERE cve_param = '25' AND valor = '07';

		--Toma de fecha a la tabla bdinteg, para el archivo
		SELECT  fecha_hoy
		INTO cFechaSer
		FROM bdinteg:si_fechas
		WHERE empresa = '001';

		LET cFechaArc = SUBSTR(cFechaSer,7,10) || SUBSTR(cFechaSer,1,2) || SUBSTR(cFechaSer,4,5);
		-- Se genera el archivo de consulta al SAT
		IF cTipoArchivo = '01' THEN
            Begin WORK;
                    --- Se pregunta si existen clientes con estatus pendiete
                   IF EXISTS (SELECT rfc FROM bdilide:sl_consat WHERE estado = 'P') THEN
                            --se verifica que no existan mas de 10 archivos al dia
                            IF((SELECT COUNT (nombre_arch) FROM  bdilide:sl_archsat  WHERE fecha_genera = cFechaSer AND nombre_arch LIKE 'CC%') > 9) THEN
								LET cCodRet = '002';
								LET pMensaje = 'Generacion invalida del decimo archivo';
								LET  cNombreError = 'GENERICO';
								commit  WORK;
								execute procedure bdilide:sp_grabarErrores(cNombreError, cCodRet, pTipoError, pSpLLamado, pMensaje, pMostrado)  into cErrorSP;
                                RETURN cCodRet, cNombreError,  pTipoError, pSpLLamado, pMensaje, pMostrado;
                            ELSE
                                IF NOT EXISTS (SELECT nombre_arch  FROM  bdilide:sl_archsat WHERE fecha_genera = cFechaSer) THEN
                                    -- se asigna el numero al archivo
                                    LET cNumArchivo= '0';
                                    LET cStatus = '';
                                    LET cCodEnvio = '';
								ELSE
									SELECT COUNT(*)
                                    INTO cNumSele
                                    FROM bdilide:sl_archsat
                                    WHERE fecha_genera = cFechaSer
                                    AND nombre_arch LIKE 'CC%';
                                    LET cNumArchivo = cNumSele;
                                    LET cStatus = '';
                                    LET cCodEnvio = '';
								END IF;
							END IF;
                                                        SELECT COUNT (rfc)
							INTO iNoRegistro
							FROM  bdilide:sl_consat
							WHERE estado = 'P';
							LET cPrefijo = 'CC';
                            LET cNombre = cPrefijo || cNumArchivo || cClaveBan || cFechaArc;
                            LET cNombre = TRIM(cNombre);
                            LET cStatus = 'P';
                            INSERT INTO bdilide:sl_procesos(proceso, fech_proceso,status,user_insert,fecha_insert)
                            VALUES(cNombre,cFechaSer,'0',pUsuario, current hour to fraction(3));
                            INSERT INTO bdilide:sl_archsat (nombre_arch,fecha_genera,fecha_respuesta,status,no_registros,cod_envio,user_insert,fecha_insert)
                            VALUES(cNombre, cFechaSer,' ',cStatus,iNoRegistro,cCodEnvio,pUsuario, current hour to fraction(3));
                            -- se cargan los datos al archivo
                            LET pMensaje = 'Error en la generacion del archivo ' || TRIM(cNombre);
                            LET cNombreError = cNombre;
                            LET sBanderaError  = '3';
						    LET vsSQL1 = 'echo "SET LOCK MODE TO WAIT; SET ISOLATION TO DIRTY READ; UNLOAD TO ' || trim(sRutaArchivo) || TRIM(cNombre)  || ' DELIMITER ' || '''|''';
                            LET vsSQL2 = ' select rfc,0 from bdilide:sl_consat where estado = ''P'';' ;
                            LET vsSQL3 = ' " > '|| TRIM(sRutaArchivo) || 'tmp_SAT.sql';
                            LET vsSQL1 = TRIM(vsSQL1);
                            LET vsSQL3 = TRIM(vsSQL3);
                            LET vsSQL = TRIM(vsSQL1) || ' ' ||  TRIM(vsSQL2) || TRIM(vsSQL3);
                            IF ( vsSQL <> '' ) THEN
								SYSTEM vsSQL ;
								LET vsSQL = '' ;
								LET vsSQL = 'dbaccess bdilide ' || TRIM(sRutaArchivo) || 'tmp_SAT.sql';
								SYSTEM vsSQL ;
                            End IF;
                            --se envia el archivo de AIX a Windows
                            LET sBanderaError  = '4';
                            LET pMensaje = 'Error en el envio de AIX a Windows  del archivo ' || TRIM(cNombre);
                            LET cNombreError = cNombre;
                            LET vsSQL = '';
                            LET vsSQL  = 'chmod 666 ' || ' ' || TRIM(sRutaArchivo) || TRIM( cNombre);
                            SYSTEM vsSQL;
							LET vsSQL = '';
							LET vsSQL  = 'scp' || ' ' || TRIM(sRutaArchivo) || TRIM( cNombre) || ' ' || TRIM(vIpDest) || TRIM(vUsuarioDestino) || TRIM(cNombre);
							SYSTEM vsSQL;
			   
							--- se graba y se actualizan los datos necesarios
							
                            UPDATE bdilide:sl_archsat  SET status = '0' where nombre_arch = cNombre;

                            --se elimina la tabla de control de consulta
							IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'sl_controlconsulta') THEN
                                DELETE sl_controlconsulta;
							ELSE
								CREATE TABLE sl_controlconsulta(clave CHAR(5), fecha CHAR(8), registro int);
							END IF;
							LET cPrefijoControl = 'CT';
							LET cNombreControl = cPrefijoControl || cNumArchivo || cClaveBan || cFechaArc;
                            LET  cNombreError =  cNombreControl;
							INSERT INTO bdilide:sl_controlconsulta(clave,fecha,registro)
							VALUES (cClaveBan, cFechaArc, iNoRegistro );
                            INSERT INTO bdilide:sl_procesos(proceso, fech_proceso,status,user_insert,fecha_insert)
                            VALUES(cNombreControl,cFechaSer,'0',pUsuario, current hour to fraction(3));
                            INSERT INTO sl_archsat (nombre_arch,fecha_genera,fecha_respuesta,status,no_registros,cod_envio,user_insert,fecha_insert)
                            VALUES(cNombreControl, cFechaSer,' ','P',iNoRegistro,cCodEnvio,pUsuario, current hour to fraction(3));
                            --Creacion del archivo de control
                            LET sBanderaError  = '5';
                            LET pMensaje = 'Error en la creacion del archivo  ' || TRIM(cNombreControl);
                            LET cNombreError = cNombreControl;
							LET vsSQL1C = 'echo " SET LOCK MODE TO WAIT; SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(sRutaArchivo) || TRIM(cNombreControl)  || ' DELIMITER ' || '''|''';
							LET vsSQL2C = ' select clave,fecha,registro from bdilide:sl_controlconsulta;' ;
							LET vsSQL3C = ' " > '|| TRIM(sRutaArchivo) || 'tmp_SAT_control.sql';
							LET vsSQL1C = TRIM(vsSQL1C);
							LET vsSQL3C = TRIM(vsSQL3C);
							LET vsSQLC = TRIM(vsSQL1C) || ' ' ||  TRIM(vsSQL2C) || TRIM(vsSQL3C);
							IF ( vsSQLC <> '' ) THEN
                                SYSTEM vsSQLC ;
								let vsSQLC = '' ;
								let vsSQLC = 'dbaccess bdilide ' || TRIM(sRutaArchivo) || 'tmp_SAT_control.sql';
                                SYSTEM vsSQLC ;
							End IF;

                            LET sBanderaError  = '6';
                            LET pMensaje = 'Error en el envio de AIX a Windows del archivo  ' || TRIM(cNombreControl);
                            LET cNombreError = cNombreControl;
                            LET vsSQL = '';
                            LET vsSQL  = 'chmod 666 ' || ' ' || TRIM(sRutaArchivo) || TRIM( cNombreControl);
                            SYSTEM vsSQL;
							LET vsSQL = '';
							LET vsSQL  = 'scp' || ' ' || TRIM(sRutaArchivo) || TRIM( cNombreControl) || ' ' || TRIM(vIpDest) || TRIM(vUsuarioDestino) || TRIM(cNombreControl);
							SYSTEM vsSQL;                             
                            UPDATE bdilide:sl_archsat  SET status = '0' where nombre_arch = cNombreControl;
                            UPDATE bdilide:sl_consat  SET nombre_arch = cNombre WHERE estado = 'P';
                            UPDATE bdilide:sl_consat SET estado = '0'  WHERE nombre_arch = cNombre;
                            LET sBanderaError  = '7';
                            LET cNombreError = cNombreControl;
                            LET pMensaje = 'Error al eliminar archivos temporales';
                            LET vsSQLC = '';
                            LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'tmp_SAT_control.sql';
                            SYSTEM vsSQLC;
                            LET vsSQLC = '';
                            LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'tmp_SAT.sql';
                            SYSTEM vsSQLC;
					ELSE
                    END IF;
		END IF;  --ARchivo de Acuse

        IF cTipoArchivo = '02' THEN
            Begin WORK;
                    --- se Validan los parametros
                    IF (cNomArchivo = "" OR cNomArchivo IS NULL)  OR ( cArchivoControl = "" OR cArchivoControl IS NULL) THEN
                            LET cCodRet = '006';
                            LET pMensaje = 'Validacion de tipo de archivo';
                            LET cNombreError = cNombre;
                            commit work;
                            execute procedure bdilide:sp_grabarErrores(cNombreError, cCodRet, pTipoError, pSpLLamado, pMensaje, pMostrado)  into cErrorSP;
                            RETURN cCodRet, cNombreError,  pTipoError, pSpLLamado, pMensaje, pMostrado;
                    END IF;
                    --- se crea el archivo enviado de consulta
                    LET cPrefijo = "CC";
                    LET cNombre = SUBSTR(cNomArchivo,3,20);
                    LET cNombre = cPrefijo || TRIM(cNombre);
                    LET cNombre = TRIM(cNombre);
                    LET cEliminarNombre = TRIM(cNombre);

                    --- se monta el archivo enviado de control
                    LET cPrefijoControl = 'CT';
                    LET cNombreControl = SUBSTR(cNomArchivo,3,20);
                    LET cNombreControl = cPrefijoControl || TRIM(cNombreControl);
                    LET cNombreControl = TRIM(cNombreControl);
                    LET cNombreControlstatus = cNombreControl;
                    LET cEliminarControl = cNombreControl;
                    LET sBanderaError  = '1';
                    LET pMensaje = 'Error en la carga de archivos para su comparcion ' || ',' || TRIM(cNomArchivo) || ',' || TRIM(cArchivoControl);
                    LET cNombreError = cNomArchivo;
                    IF EXISTS(SELECT status FROM bdilide:sl_archsat  WHERE nombre_arch = cNombre )   or (SELECT status FROM bdilide:sl_archsat  WHERE nombre_arch = cNombreControl ) THEN
                        IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'sl_archivoscontrolsatresp') THEN
							DELETE bdilide:sl_archivoscontrolsatresp;
					ELSE
							CREATE TABLE bdilide:sl_archivoscontrolsatresp(clave CHAR(5), fecha CHAR(8), registro int);
					END IF;
					--CREA ARCHIOVO DE INSTRUCCION DE CARGA.
					LET vsSQL = 'echo " SET LOCK MODE TO WAIT; SET ISOLATION TO DIRTY READ; LOAD FROM ''' || TRIM(sRutaArchivo) || '/' || TRIM(cArchivoControl) || "'" || ' INSERT INTO sl_archivoscontrolsatresp" > ' || TRIM(sRutaArchivo) ||  'load_control_resp.sql';
					IF ( vsSQL <> '' ) THEN
						SYSTEM vsSQL ;
						let vsSQL = '' ;
						LET vsSQL = 'dbaccess bdilide ' || TRIM(sRutaArchivo) ||  'load_control_resp.sql';
						SYSTEM vsSQL;
					End IF;
					LET vsSQLC = '';
					LET vsSQL  = 'chmod 666 ' || ' ' || TRIM(sRutaArchivo) ||  'load_control_resp.sql';
					SYSTEM vsSQL;
	
					IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'sl_archivossatresp') THEN
						DELETE bdilide:sl_archivossatresp;
					ELSE
						CREATE TABLE bdilide:sl_archivossatresp(rfc CHAR(13), estado CHAR(1));
					END IF;	
	
					--CREA ARCHIOVO DE INSTRUCCION DE CARGA.
					LET vsSQL = 'echo " SET LOCK MODE TO WAIT; SET ISOLATION TO DIRTY READ; LOAD FROM ''' || TRIM(sRutaArchivo) || '/' || TRIM(cNomArchivo) || "'" || ' INSERT INTO bdilide:sl_archivossatresp" > ' || TRIM(sRutaArchivo) ||  'load_sat_resp.sql;';
					--CARGA EL ARCHIVO ORIGINAL A LA TABLA TEMPORAL
					IF ( vsSQL <> '' ) THEN
						SYSTEM vsSQL;
						LET vsSQL = "";
						LET vsSQL = 'dbaccess bdilide ' || TRIM(sRutaArchivo) ||  'load_sat_resp.sql';
						SYSTEM vsSQL;
					End IF;
					LET vsSQLC = '';
					LET vsSQL  = 'chmod 666 ' || ' ' || TRIM(sRutaArchivo) || 'load_sat_resp.sql';
					SYSTEM vsSQL;	
	
					LET sBanderaError  = '0';
					LET pMensaje = 'Error en la carga de archivos para su comparcion ' || ',' || TRIM(cNombre) || ',' || TRIM(cNombreControl);
					LET cNombreError = cNombre;
	
					IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'sl_archivoscontrolsat') THEN
							DELETE bdilide:sl_archivoscontrolsat;
					ELSE
							CREATE TABLE bdilide:sl_archivoscontrolsat(clave CHAR(5), fecha CHAR(8), registro int);
					END IF;
					--CREA ARCHIOVO DE INSTRUCCION DE CARGA.
					LET vsSQL= 'echo " SET LOCK MODE TO WAIT; SET ISOLATION TO DIRTY READ; LOAD FROM ''' || TRIM(sRutaArchivo) || '/' || TRIM(cNombreControl) || "'" || ' INSERT INTO sl_archivoscontrolsat" > ' || TRIM(sRutaArchivo) ||  'load_archivo_sat.sql';
					--CARGA EL ARCHIVO ORIGINAL A LA TABLA TEMPORAL
					IF ( vsSQL <> '' ) THEN
						SYSTEM vsSQL;
						let vsSQL = '' ;
						LET vsSQL = 'dbaccess bdilide ' || TRIM(sRutaArchivo) ||  'load_archivo_sat.sql';
						SYSTEM vsSQL;
					End IF;
					LET vsSQLC = '';
					LET vsSQL  = 'chmod 666 ' || ' ' || TRIM(sRutaArchivo) || 'load_archivo_sat.sql';
					SYSTEM vsSQL;
		
					IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'sl_archivossat') THEN
						DELETE bdilide:sl_archivossat;
					ELSE
						CREATE TABLE bdilide:sl_archivossat(rfc CHAR(13), estado CHAR(1));
					END IF;
	
					--CREA ARCHIOVO DE INSTRUCCION DE CARGA.
					LET vsSQL = "";
					LET vsSQL = 'echo " SET LOCK MODE TO WAIT; SET ISOLATION TO DIRTY READ; LOAD FROM ''' || TRIM(sRutaArchivo) || '/' || TRIM(cNombre) || "'" || ' INSERT INTO bdilide:sl_archivossat" > ' || TRIM(sRutaArchivo) ||  'load_archivo_sat.sql;';
					IF ( vsSQL <> '' ) THEN
						SYSTEM vsSQL ;
						LET vsSQL = "";
						LET vsSQL = 'dbaccess bdilide ' || TRIM(sRutaArchivo) ||  'load_archivo_sat.sql';
						SYSTEM vsSQL;
					End IF;
					LET vsSQLC = '';
					LET vsSQL  = 'chmod 666 ' || ' ' || TRIM(sRutaArchivo) ||  'load_archivo_sat.sql';
					SYSTEM vsSQL;
                            SELECT registro,clave,fecha
							INTO iRegistroResp,cClave,cFecha
							FROM bdilide:sl_archivoscontrolsatresp;
							SELECT registro,clave,fecha
							INTO iRegistro,cClaveRe,cFechaRe
							FROM bdilide:sl_archivoscontrolsat;
							select count(rfc) INTO iRegistrosRespuesta FROM bdilide:sl_archivossatresp;
							UPDATE bdilide:sl_archsat SET no_registros = iRegistrosRespuesta WHERE nombre_arch = cNomArchivo;
							UPDATE bdilide:sl_archsat SET no_registros = iRegistrosRespuesta WHERE nombre_arch = cArchivoControl;
                            ---Valida que  los datos  sean iguales el archivo de control de datos con el arcchivo de respuesta de datos
                            IF (iRegistroResp = iRegistro) and (cClave = cClaveRe) and (cFecha  = cFechaRe) THEN
                                    ---Valida que  el estado sea un dato correcto
                                    IF EXISTS (select rfc  from sl_archivossatresp  where estado <> '1' and estado <> '2' and estado <> '3') THEN

                                        IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'sl_acuse') THEN
                                            DELETE bdilide:sl_acuse;
                                        ELSE
                                            CREATE TABLE bdilide:sl_acuse(clave CHAR(5), fecha CHAR(8), registro int, estado int);
                                        END IF;

                                        LET cPrefijoControl = 'RN';
                                        LET iEstado = '1';
                                        LET cNombreControl = SUBSTR(cNombreControl,3,20);
                                        LET cNombreControl = cPrefijoControl || TRIM(cNombreControl);
                                        LET iNoRegistro = iRegistroResp;
                                        INSERT INTO bdilide:sl_procesos(proceso, fech_proceso,status,user_insert,fecha_insert)
                                        VALUES(cNombreControl,cFechaSer,'0',pUsuario, current hour to fraction(3));
                                        INSERT INTO bdilide:sl_acuse(clave,fecha,registro, estado)
                                        VALUES (cClaveBan, cFechaArc, iNoRegistro,iEstado );
                                        LET sBanderaError  = '2';
                                        LET pMensaje = 'Error en la creacion del archivo '  ||  TRIM(cArchivoControl);
                                        LET cNombreError = cArchivoControl;
                                        LET vsSQL1C = 'echo " SET LOCK MODE TO WAIT; SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(sRutaArchivo) || TRIM(cNombreControl)  || ' DELIMITER ' || '''|''';
                                        LET vsSQL2C = ' select clave,fecha,registro,estado from bdilide:sl_acuse;' ;
                                        LET vsSQL3C = ' " > '|| TRIM(sRutaArchivo) || 'tmp_SAT_acuse.sql;';
                                        LET vsSQL1C = TRIM(vsSQL1C);
                                        LET vsSQL3C = TRIM(vsSQL3C);
                                        LET vsSQLC = TRIM(vsSQL1C) || ' ' ||  TRIM(vsSQL2C) || TRIM(vsSQL3C);
                                        IF ( vsSQLC <> '' ) THEN
                                            SYSTEM vsSQLC ;
                                            let vsSQLC = '' ;
                                            let vsSQLC = 'dbaccess bdilide ' || TRIM(sRutaArchivo) || 'tmp_SAT_acuse.sql';
                                            SYSTEM vsSQLC ;
                                        END IF;
                                        LET vsSQL = '';
                                        LET vsSQL  = 'chmod 666 ' || ' ' || TRIM(sRutaArchivo) || 'tmp_SAT_acuse.sql';
                                        SYSTEM vsSQL;
                                        
										LET vsSQL = '';
										LET vsSQL  = 'chmod 666 ' || ' ' || TRIM(sRutaArchivo) || TRIM(cNombreControl);
										SYSTEM vsSQL;
                                        LET sBanderaError  = '3';
                                        LET pMensaje = 'Error en el envio de AIX a Windows  '  ||  TRIM(cArchivoControl);
                                        LET cNombreError = cArchivoControl;
                                        LET vsSQL = '';
                                        LET vsSQL  = 'scp' || ' ' || TRIM(sRutaArchivo) || TRIM( cNombreControl) || ' ' || TRIM(vIpDest) || TRIM(vUsuarioDestino) || TRIM(cNombreControl);
                                        SYSTEM vsSQL;

                                        INSERT INTO sl_archsat (nombre_arch,fecha_genera,fecha_respuesta,status,no_registros,cod_envio,user_insert,fecha_insert)
                                        VALUES(cNombreControl, cFechaSer,' ','0',iNoRegistro,cCodEnvio,pUsuario, current hour to fraction(3));
                                        UPDATE sl_archsat SET status = 'E'  WHERE nombre_arch = cNomArchivo;
                                        UPDATE sl_archsat SET status = 'E'  WHERE nombre_arch = cArchivoControl;
                                        LET vsSQLC = '';
                                        LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'tmp_SAT_acuse.sql;';
                                        SYSTEM vsSQLC;
                                        LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  trim(cNomArchivo);
                                        SYSTEM vsSQLC;
                                        LET vsSQLC = '';
                                        LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  trim(cArchivoControl);
                                        SYSTEM vsSQLC;
                                        LET vsSQLC = '';
                                        LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  trim(cNombreControl);
                                        SYSTEM vsSQLC;
                                        UPDATE bdilide:sl_procesos SET status = '1' WHERE proceso = cNombreControl;
                                        UPDATE bdilide:sl_procesos SET status = '1' WHERE proceso = cArchivoControl;
                                        UPDATE bdilide:sl_procesos SET status = '1' WHERE proceso = cNomArchivo;

                                        LET cCodRet = '008';
                                        LET pMensaje = 'Los datos del Archivo de datos  ' || cNomArchivo || ' no son correctos, dado que el estado es diferente de 1,2,3' ;
                                        LET cNombreError = cNomArchivo;
                                        COMMIT WORK;
                                        execute procedure bdilide:sp_grabarErrores(cNombreError, cCodRet, pTipoError, pSpLLamado, pMensaje, pMostrado)  into cErrorSP;
                                        RETURN cCodRet, cNombreError,  pTipoError, pSpLLamado, pMensaje, pMostrado;
                                    --END IF;
									ELSE
                                        SELECT COUNT(a.rfc )
										INTO iRegistroTotal
										FROM sl_archivossat a
										INNER JOIN sl_archivossatresp b ON a.rfc = b.rfc;
										
										-- si son los mismos archivos enviados que recividos se crea el archivo de acuse afirmativo
										IF iRegistro = iRegistroTotal THEN
											SELECT  clave, fecha
											INTO cClaveBan, cFechaArc
											FROM bdilide:sl_archivoscontrolsat;

											IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'sl_acuse') THEN
												DELETE bdilide:sl_acuse;
											ELSE
												CREATE TABLE bdilide:sl_acuse(clave CHAR(5), fecha CHAR(8), registro int, estado int);
											END IF;

											LET cNombreControl = SUBSTR(cNomArchivo,1,1);
											IF cNombreControl = 'R' THEN
												LET cPrefijoControl = 'RA';
											END IF;
											IF cNombreControl = 'I' THEN
												LET cPrefijoControl = 'IA';
											END IF;
											LET iEstado = '0';
											LET cNombreControl = SUBSTR(cNomArchivo,3,20);
											LET cNombreControl = cPrefijoControl || TRIM(cNombreControl);
											LET iNoRegistro = iRegistroResp;
											LET cStatus = '0';
											LET sBanderaError  = '4';
											LET pMensaje = 'Error en la creacion del archivo  '  ||  TRIM(cNombreControl);
											LET cNombreError = cArchivoControl;
											INSERT INTO bdilide:sl_acuse(clave,fecha,registro, estado)
											VALUES (cClaveBan,cFechaArc,iNoRegistro,iEstado);
											IF EXISTS( SELECT status FROM bdilide:sl_archsat  WHERE nombre_arch = cNombreControl and status = 'E' ) or ( SELECT status FROM bdilide:sl_procesos  WHERE proceso = cNombreControl and status = '0' )  THEN
												UPDATE 	bdilide:sl_archsat  SET status = '0' where nombre_arch = cNombreControl;
											ELSE
												Insert into bdilide:sl_archsat(nombre_arch,fecha_genera,fecha_respuesta,status,no_registros,user_insert,fecha_insert)
												values(cNombreControl,cFechaSer,'','0',iRegistroResp,pUsuario, current hour to fraction(3));
												INSERT INTO bdilide:sl_procesos(proceso, fech_proceso,status,user_insert,fecha_insert)
												VALUES(cNombreControl,cFechaSer,cStatus,pUsuario, current hour to fraction(3));
											END IF;
											LET vsSQL1C = 'echo " SET LOCK MODE TO WAIT; SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(sRutaArchivo) || TRIM(cNombreControl)  || ' DELIMITER ' || '''|''';
											LET vsSQL2C = ' select clave,fecha,registro,estado from bdilide:sl_acuse;' ;
											LET vsSQL3C = ' " > '|| TRIM(sRutaArchivo) || '/tmp_SAT_acuse.sql';
											LET vsSQL1C = TRIM(vsSQL1C);
											LET vsSQL3C = TRIM(vsSQL3C);
											LET vsSQLC = TRIM(vsSQL1C) || ' ' ||  TRIM(vsSQL2C) || TRIM(vsSQL3C);
											IF ( vsSQLC <> '' ) THEN
												SYSTEM vsSQLC ;
												let vsSQLC = '' ;
												let vsSQLC = 'dbaccess bdilide ' || TRIM(sRutaArchivo) || 'tmp_SAT_acuse.sql';
												SYSTEM vsSQLC ;
											END IF;
											LET vsSQL = '';
											LET vsSQL  = 'chmod 666 ' || ' ' || TRIM(sRutaArchivo) || 'tmp_SAT_acuse.sql';
											SYSTEM vsSQL;
                                                                                        LET vsSQL = '';
                                                                                        LET vsSQL  = 'chmod 666 ' || ' ' || TRIM(sRutaArchivo) || TRIM(cNombreControl);
                                                                                        SYSTEM vsSQL;
											LET sBanderaError  = '5';
											LET pMensaje = 'Error en el envio de AIX a Windows del archivo   '  ||  TRIM(cNombreControl);
											LET cNombreError = cNombreControl;
											LET vsSQL = '';
											LET vsSQL  = 'scp' || ' ' || TRIM(sRutaArchivo) || TRIM( cNombreControl) || ' ' || TRIM(vIpDest) || TRIM(vUsuarioDestino) || TRIM(cNombreControl);
											SYSTEM vsSQL;

											COMMIT WORK;
											BEGIN WORK;
											execute procedure bdilide:sp_procesasat(pUsuario,cNomArchivo, cArchivoControl) into cErrorSP;
											IF cErrorSP <> '000' THEN
												ROLLBACK WORK;
												BEGIN WORK;
												LET cCodRet = cErrorSP;
												LET pSpLLamado = 'sp_procesasat';
												LET pMensaje = 'Error en la ejacucion del sp_procesasat';
												LET   cNombreError = cNombreControl;
                                                                                                COMMIT WORK;
												execute procedure bdilide:sp_grabarErrores(cNombreError, cCodRet, pTipoError, pSpLLamado, pMensaje, pMostrado)  into cErrorSP;
												RETURN cCodRet, cNombreError,  pTipoError, pSpLLamado, pMensaje, pMostrado;
											END IF;
											UPDATE bdilide:sl_archsat SET status = '5' where nombre_arch = cEliminarControl;
											UPDATE bdilide:sl_archsat SET status = '5' where nombre_arch = cEliminarNombre;
											UPDATE bdilide:sl_archsat SET status = '5' where nombre_arch = cNomArchivo;
											UPDATE bdilide:sl_archsat SET status = '5' where nombre_arch = cArchivoControl;
											update bdilide:sl_procesos SET status  = '1' where proceso  = cNombreControl;
                                            update bdilide:sl_procesos SET status  = '1' where proceso  = cNomArchivo;
											UPDATE bdilide:sl_archsat SET fecha_respuesta = current::date where nombre_arch = cEliminarControl;
											UPDATE bdilide:sl_archsat SET fecha_respuesta = current::date  where nombre_arch = cEliminarNombre;
											LET vsSQLC = '';
											LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  trim(cEliminarControl);
											SYSTEM vsSQLC;
											LET vsSQLC = '';
											LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  trim(cEliminarNombre);
											SYSTEM vsSQLC;
											LET vsSQL = '';
											LET vsSQL  = 'chmod 666 ' || ' ' || TRIM(sRutaArchivo) || TRIM( cNombreControl);
											SYSTEM vsSQL;
											LET vsSQLC = '';
											LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  trim(cNomArchivo);
											SYSTEM vsSQLC;
											LET vsSQLC = '';
											LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  trim(cArchivoControl);
											SYSTEM vsSQLC;
                                            LET vsSQLC = '';
                                            LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  trim(cNombreControl);
                                            SYSTEM vsSQLC;

											LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'load_sat_resp.sql';
											SYSTEM vsSQLC;
											LET vsSQLC = '';
											LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'load_archivo_sat.sql';
											SYSTEM vsSQLC;
											LET vsSQLC = '';
											LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'load_control_resp.sql';
											SYSTEM vsSQLC;
											LET vsSQLC = '';
											LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'load_sat_resp.sql';
											SYSTEM vsSQLC;
											LET vsSQLC = '';
											LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'tmp_SAT_acuse.sql';
											SYSTEM vsSQLC;
										ELSE
											IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'sl_acuse') THEN
												DELETE bdilide:sl_acuse;
											ELSE
												CREATE TABLE bdilide:sl_acuse(clave CHAR(5), fecha CHAR(8), registro int, estado int);
											END IF;
											LET cPrefijoControl = 'RN';
											LET iEstado = '1';
											LET cNombreControl = SUBSTR(cNombreControl,3,20);
											LET cNombreControl = cPrefijoControl || TRIM(cNombreControl);
											LET iNoRegistro = "0";
											--LET  cClaveBan = "0";
											LET sBanderaError  = '6';
											LET pMensaje = 'Error en la creacion del archivo   '  ||  TRIM(cNombreControl);
											LET cNombreError = cNombreControl;
											INSERT INTO bdilide:sl_procesos(proceso, fech_proceso,status,user_insert,fecha_insert)
											VALUES(cNombreControl,cFechaSer,'0',pUsuario, current hour to fraction(3));
											INSERT INTO bdilide:sl_acuse(clave,fecha,registro, estado)
											VALUES (cClaveBan, cFechaArc, iNoRegistro,iEstado );
											LET vsSQL1C = 'echo " SET LOCK MODE TO WAIT; SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(sRutaArchivo) || TRIM(cNombreControl)  || ' DELIMITER ' || '''|''';
											LET vsSQL2C = ' select clave,fecha,registro,estado from bdilide:sl_acuse;' ;
											LET vsSQL3C = ' " > '|| TRIM(sRutaArchivo) || 'tmp_SAT_acuse.sql;';
											LET vsSQL1C = TRIM(vsSQL1C);
											LET vsSQL3C = TRIM(vsSQL3C);
											LET vsSQLC = TRIM(vsSQL1C) || ' ' ||  TRIM(vsSQL2C) || TRIM(vsSQL3C);
											IF ( vsSQLC <> '' ) THEN
												SYSTEM vsSQLC ;
												let vsSQLC = '' ;
												let vsSQLC = 'dbaccess bdilide ' || TRIM(sRutaArchivo) || 'tmp_SAT_acuse.sql;';
												SYSTEM vsSQLC ;
											END IF;
                                                                                         
			                                LET vsSQL = '';
			                                LET vsSQL  = 'chmod 666 ' || ' ' || TRIM(sRutaArchivo) || TRIM(cNombreControl);
			                                SYSTEM vsSQL;
                                            LET vsSQL = '';
                                            LET vsSQL  = 'chmod 666 ' || ' ' || TRIM(sRutaArchivo) || 'tmp_SAT_acuse.sql;';
                                            SYSTEM vsSQL;
											LET sBanderaError  = '7';
											LET pMensaje = 'Error en el envio de AIX a Windows del archivo    '  ||  TRIM(cNombreControl);
											LET cNombreError = cNombreControl;
											LET vsSQLC = '';
											LET vsSQL  = 'scp' || ' ' || TRIM(sRutaArchivo) || TRIM( cNombreControl) || ' ' || TRIM(vIpDest) || TRIM(vUsuarioDestino) || TRIM(cNombreControl);
											SYSTEM vsSQL;
											INSERT INTO sl_archsat (nombre_arch,fecha_genera,fecha_respuesta,status,no_registros,cod_envio,user_insert,fecha_insert)
											VALUES(cNombreControl, cFechaSer,' ','0',iNoRegistro,cCodEnvio,pUsuario, current hour to fraction(3));
											UPDATE sl_archsat SET status = 'E'  WHERE nombre_arch = cNomArchivo;
											UPDATE sl_archsat SET status = 'E'  WHERE nombre_arch = cArchivoControl;
											LET vsSQLC = '';
											LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'tmp_SAT_acuse.sql;';
											SYSTEM vsSQLC;
											LET vsSQLC = '';
											LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  trim(cNomArchivo);
											SYSTEM vsSQLC;
											LET vsSQLC = '';
											LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  trim(cArchivoControl);
											SYSTEM vsSQLC;
                                            LET vsSQLC = '';
                                            LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  trim(cNombreControl);
                                            SYSTEM vsSQLC;
											LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'load_sat_resp.sql';
											SYSTEM vsSQLC;
											LET vsSQLC = '';
											LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'load_archivo_sat.sql';
											SYSTEM vsSQLC;
											LET vsSQLC = '';
											LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'load_control_resp.sql';
											SYSTEM vsSQLC;
											LET vsSQLC = '';
											LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'load_sat_resp.sql';
											SYSTEM vsSQLC;

											LET cCodRet = '007';
											LET pMensaje = 'Los datos del Archivo de datos  ' || cNombre || ' no concuerda con los datos del  ' ||cNomArchivo;
											LET cNombreError = cNombre;
                                            COMMIT WORK;
											execute procedure bdilide:sp_grabarErrores(cNombreError, cCodRet, pTipoError, pSpLLamado, pMensaje, pMostrado)  into cErrorSP;
											
											RETURN cCodRet, cNombreError,  pTipoError, pSpLLamado, pMensaje, pMostrado;
										END IF;
									END IF;
                            ELSE --Else da la validacion de datos del archivo de control vs los datos del archivo de control del SAT
                                IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'sl_acuse') THEN
									DELETE bdilide:sl_acuse;
                                ELSE
                                    CREATE TABLE bdilide:sl_acuse(clave CHAR(5), fecha CHAR(8), registro int, estado int);
                                END IF;
                                LET cPrefijoControl = 'RN';
                                LET iEstado = '1';
                                LET cNombreControl = SUBSTR(cNombreControl,3,20);
                                LET cNombreControl = cPrefijoControl || TRIM(cNombreControl);
                                LET iNoRegistro = "0";
                                LET sBanderaError  = '6';
                                LET pMensaje = 'Error en la creacion del archivo   '  ||  TRIM(cNombreControl);
                                LET cNombreError = cNombreControl;
                                INSERT INTO bdilide:sl_procesos(proceso, fech_proceso,status,user_insert,fecha_insert)
                                VALUES(cNombreControl,cFechaSer,'0',pUsuario, current hour to fraction(3));
                                INSERT INTO bdilide:sl_acuse(clave,fecha,registro, estado)
                                VALUES (cClaveBan, cFechaArc, iNoRegistro,iEstado );
                                LET vsSQL1C = 'echo " SET LOCK MODE TO WAIT; SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(sRutaArchivo) || TRIM(cNombreControl)  || ' DELIMITER ' || '''|''';
                                LET vsSQL2C = ' select clave,fecha,registro,estado from bdilide:sl_acuse;' ;
                                LET vsSQL3C = ' " > '|| TRIM(sRutaArchivo) || 'tmp_SAT_acuse.sql;';
                                LET vsSQL1C = TRIM(vsSQL1C);
                                LET vsSQL3C = TRIM(vsSQL3C);
                                LET vsSQLC = TRIM(vsSQL1C) || ' ' ||  TRIM(vsSQL2C) || TRIM(vsSQL3C);
                                IF ( vsSQLC <> '' ) THEN
									SYSTEM vsSQLC ;
                                    let vsSQLC = '' ;
                                    let vsSQLC = 'dbaccess bdilide ' || TRIM(sRutaArchivo) || 'tmp_SAT_acuse.sql;';
                                    SYSTEM vsSQLC ;
                                END IF;
                                 LET vsSQL = '';
                                 LET vsSQL  = 'chmod 666 ' || ' ' || TRIM(sRutaArchivo) || TRIM(cNombreControl);
                                 SYSTEM vsSQL;
                                 LET vsSQL = '';
                                 LET vsSQL  = 'chmod 666 ' || ' ' || TRIM(sRutaArchivo) || 'tmp_SAT_acuse.sql;';
                                 SYSTEM vsSQL;

                                LET sBanderaError  = '7';
                                LET pMensaje = 'Error en el envio de AIX a Windows del archivo    '  ||  TRIM(cNombreControl);
                                LET cNombreError = cNombreControl;
                                LET vsSQLC = '';
                                LET vsSQL  = 'scp' || ' ' || TRIM(sRutaArchivo) || TRIM( cNombreControl) || ' ' || TRIM(vIpDest) || TRIM(vUsuarioDestino) || TRIM(cNombreControl);
                                SYSTEM vsSQL;
                                INSERT INTO sl_archsat (nombre_arch,fecha_genera,fecha_respuesta,status,no_registros,cod_envio,user_insert,fecha_insert)
                                VALUES(cNombreControl, cFechaSer,' ','0',iNoRegistro,cCodEnvio,pUsuario, current hour to fraction(3));
                                UPDATE sl_archsat SET status = 'E'  WHERE nombre_arch = cNomArchivo;
                                UPDATE sl_archsat SET status = 'E'  WHERE nombre_arch = cArchivoControl;
                                LET vsSQLC = '';
                                LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'tmp_SAT_acuse.sql;';
                                SYSTEM vsSQLC;
                                LET vsSQLC = '';
                                LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  trim(cNomArchivo);
                                SYSTEM vsSQLC;
                                LET vsSQLC = '';
                                LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  trim(cArchivoControl);
                                SYSTEM vsSQLC;
                                LET vsSQLC = '';
                                LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  trim(cNombreControl);
                                SYSTEM vsSQLC;
                               LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'load_sat_resp.sql';
								SYSTEM vsSQLC;
								LET vsSQLC = '';
								LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'load_archivo_sat.sql';
								SYSTEM vsSQLC;
								LET vsSQLC = '';
								LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'load_control_resp.sql';
								SYSTEM vsSQLC;
								LET vsSQLC = '';
								LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'load_sat_resp.sql';
								SYSTEM vsSQLC;
                                LET cCodRet = '007';
                                LET pMensaje = 'Los datos del Archivo de control  ' || cNombreControl || ' no concuerda con los datos del  ' ||cArchivoControl;
                                LET cNombreError = 'GENERICO';
                                COMMIT WORK;
                                execute procedure bdilide:sp_grabarErrores(cNombreError, cCodRet, pTipoError, pSpLLamado, pMensaje, pMostrado)  into cErrorSP;
                               
                                RETURN cCodRet, cNombreError,  pTipoError, pSpLLamado, pMensaje, pMostrado;
                            END IF;
                    ELSE --ELse de la validacion de existencia del par correspondiente a los RT y

                        IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'sl_acuse') THEN
							DELETE bdilide:sl_acuse;
						ELSE
							CREATE TABLE bdilide:sl_acuse(clave CHAR(5), fecha CHAR(8), registro int, estado int);
						END IF;
                        LET cPrefijoControl = 'RN';
                        LET iEstado = '1';
						LET cNombreControl = SUBSTR(cNombreControl,3,20);
						LET cNombreControl = cPrefijoControl || TRIM(cNombreControl);
						LET iNoRegistro = "0";
                        LET sBanderaError  = '8';
                        LET pMensaje = 'Error en la creacion del archivo   '  ||  TRIM(cNombreControl);
                        LET cNombreError = cNombreControl;
                        INSERT INTO bdilide:sl_procesos(proceso, fech_proceso,status,user_insert,fecha_insert)
                        VALUES(cNombreControl,cFechaSer,'0',pUsuario, current hour to fraction(3));
                        INSERT INTO bdilide:sl_acuse(clave,fecha,registro, estado)
						VALUES (cClaveBan, cFechaArc, iNoRegistro,iEstado );
						LET vsSQL1C = 'echo " SET LOCK MODE TO WAIT; SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(sRutaArchivo) || TRIM(cNombreControl)  || ' DELIMITER ' || '''|''';
						LET vsSQL2C = ' select clave,fecha,registro,estado from bdilide:sl_acuse;' ;
						LET vsSQL3C = ' " > '|| TRIM(sRutaArchivo) || 'tmp_SAT_acuse.sql;';
						LET vsSQL1C = TRIM(vsSQL1C);
						LET vsSQL3C = TRIM(vsSQL3C);
						LET vsSQLC = TRIM(vsSQL1C) || ' ' ||  TRIM(vsSQL2C) || TRIM(vsSQL3C);
						IF ( vsSQLC <> '' ) THEN
							SYSTEM vsSQLC ;
							let vsSQLC = '' ;
							let vsSQLC = 'dbaccess bdilide ' || TRIM(sRutaArchivo) || 'tmp_SAT_acuse.sql;';
							SYSTEM vsSQLC ;
						END IF;
                                                   LET vsSQL = '';
                                 LET vsSQL  = 'chmod 666 ' || ' ' || TRIM(sRutaArchivo) || TRIM(cNombreControl);
                                 SYSTEM vsSQL;
                                    LET vsSQL = '';
                                 LET vsSQL  = 'chmod 666 ' || ' ' || TRIM(sRutaArchivo) || 'tmp_SAT_acuse.sql;';
                                 SYSTEM vsSQL;
                        LET sBanderaError  = '9';
                        LET pMensaje = 'Error en el envio de AIX a Windows del archivo    '  ||  TRIM(cNombreControl);
                        LET cNombreError = cNombreControl;
						LET vsSQLC = '';
						LET vsSQL  = 'scp' || ' ' || TRIM(sRutaArchivo) || TRIM( cNombreControl) || ' ' || TRIM(vIpDest) || TRIM(vUsuarioDestino) || TRIM(cNombreControl);
						SYSTEM vsSQL;

						INSERT INTO sl_archsat (nombre_arch,fecha_genera,fecha_respuesta,status,no_registros,cod_envio,user_insert,fecha_insert)
                        VALUES(cNombreControl, cFechaSer,' ','0',iNoRegistro,cCodEnvio,pUsuario, current hour to fraction(3));
                        UPDATE sl_archsat SET status = 'E'  WHERE nombre_arch = cNomArchivo;
                        UPDATE sl_archsat SET status = 'E'  WHERE nombre_arch = cArchivoControl;
                        LET vsSQLC = '';
						LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'tmp_SAT_acuse.sql;';
						SYSTEM vsSQLC;
						LET vsSQLC = '';
						LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  trim(cNomArchivo);
						SYSTEM vsSQLC;
						LET vsSQLC = '';
						LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  trim(cArchivoControl);
						SYSTEM vsSQLC;
                        LET vsSQLC = '';
                        LET vsSQLC = '';
                        LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  trim(cNombreControl);
                        SYSTEM vsSQLC;
                        LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'load_sat_resp.sql';
						SYSTEM vsSQLC;
						LET vsSQLC = '';
						LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'load_archivo_sat.sql';
						SYSTEM vsSQLC;
						LET vsSQLC = '';
						LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'load_control_resp.sql';
						SYSTEM vsSQLC;
						LET vsSQLC = '';
						LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'load_sat_resp.sql';
						SYSTEM vsSQLC;
                        LET cCodRet = '006';
                        LET pMensaje = 'No existe el par correspondiente de alguno de estos archivos  ' || cNomArchivo || ', ' ||cArchivoControl;
                        LET cNombreError = 'GENERICO';
                        COMMIT WORK;
                        execute procedure bdilide:sp_grabarErrores(cNombreError, cCodRet, pTipoError, pSpLLamado, pMensaje, pMostrado)  into cErrorSP;                      
                        RETURN cCodRet, cNombreError,  pTipoError, pSpLLamado, pMensaje, pMostrado;
                    END IF;
        END IF;
        LET cCodRet = '000';
        LET pMensaje = 'Proceso realizado satifactoriamente';
        COMMIT WORK;
        RETURN cCodRet, cNombreError,  pTipoError, pSpLLamado, pMensaje, pMostrado;
	END;
END PROCEDURE;