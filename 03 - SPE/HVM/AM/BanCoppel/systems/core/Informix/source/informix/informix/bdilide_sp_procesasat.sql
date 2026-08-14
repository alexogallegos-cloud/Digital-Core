create procedure "informix".sp_procesasat(pUsuario CHAR(8),cNomArchivo VARCHAR (20), cArchivoControl VARCHAR (20))
--*******************************************************************************************************
-- Realizo   :Alejandro Osuna
-- Proyecto :  Excencion de personas morales
-- Actividad :Se procesa la informiacion, se cambia el status en las tablas correspondientes
-- Fecha     :11 de  septiembre de 2008
--*******************************************************************************************************
RETURNING CHAR(4);

DEFINE cCodRet CHAR(4);
DEFINE sql_err  integer;
DEFINE cRfc CHAR(13);
DEFINE cEstado CHAR(1);
DEFINE cFechaSer CHAR (12);
DEFINE cNumCte  CHAR(20);
DEFINE cStatus CHAR(1);
DEFINE vsSQLC CHAR(50);
DEFINE sRutaArchivo CHAR(20);
DEFINE sConsulRfc CHAR(13);
DEFINE cPrefijo CHAR(2);
DEFINE cPrefijoControl CHAR(2);
DEFINE cNombre CHAR(20);
DEFINE cNombreControl CHAR(20);
DEFINE cNombreRechazo CHAR(20);
DEFINE cPrefijoLetra char(2);
                --MANEJADOR DE EXEPCIONES
   ON EXCEPTION SET sql_err
                     LET cCodRet = sql_err;
                 IF cCodRet  <> '0' THEN
                      RETURN cCodRet;
               END IF;
     END EXCEPTION;

let cCodRet = '';
let sql_err = 0;
let cRfc = '';
let cEstado = '';
LET cFechaSer = '';
LET cNumCte = '';
LET cStatus = '';
LET vsSQLC = "";
LET sRutaArchivo = "";
LET sConsulRfc = '';
LET cPrefijo = '';
LET cPrefijoControl =  '';
LET cNombreRechazo= "";
LET cPrefijoLetra = '';

       --SET DEBUG FILE TO "/tmp/sp_procesasat.out";
     --	TRACE ON;

	BEGIN

             --Validacion de datos
            IF (pUsuario = '' Or pUsuario IS NULL)  THEN
                   LET cCodRet = '001';
                   RETURN  cCodRet;
            END IF;

                         SELECT trim(desc_valor) INTO sRutaArchivo      FROM bdilide:sl_parametros WHERE cve_param = '25' and valor = '06';
                         SELECT  fecha_hoy
                          INTO cFechaSer
                          FROM bdinteg:si_fechas
                          WHERE empresa = '001';

                       -- SELECT COUNT(rfc) INTO cContador  FROM bdilide:sl_archivossatresp;
                            FOREACH
                                    SELECT rfc,estado
                                    INTO cRfc, cEstado
                                    FROM bdilide:sl_archivossatresp

                                    UPDATE  bdilide:sl_consat  SET estado = cEstado  WHERE rfc = cRfc;
                                    IF cEstado = '1'THEN
                                            UPDATE bdilide:sl_consat SET exento = '1' where rfc = cRfc;
                                            IF EXISTS(SELECT num_cte   FROM bdilide:sl_exentos WHERE rfc = cRfc ) THEN
                                                             UPDATE  bdilide:sl_exentos SET status = '1'  WHERE rfc = cRfc;

                                            ELSE
                                                            LET cStatus = '1';
                                                            FOREACH
                                                                SELECT  numcte INTO cNumCte FROM  bdinteg:si_cliente WHERE rfc = cRfc
                                                                INSERT INTO bdilide:sl_exentos (num_cte,rfc,status,fech_cambio,user_insert,fecha_insert)
                                                                VALUES (cNumCte,cRfc,cStatus,cFechaSer,pUsuario,cFechaSer);
                                                            END FOREACH
                                            END IF;
                                   ELSE
                                                UPDATE bdilide:sl_consat SET exento = '0' where rfc = cRfc;
                                    END IF;

                                    IF cEstado = '4' THEN
                                        UPDATE  bdilide:sl_exentos SET status = '0'  WHERE rfc = cRfc;
                                    END IF;
                            END FOREACH

                            LET cPrefijoLetra  = SUBSTR(cNomArchivo,1,1);
                            IF cPrefijoLetra = 'C' THEN
                                LET cPrefijo = 'CC';
                            ELSE
                                LET cPrefijo = 'IC';
                            END IF;

                           LET cNombre = SUBSTR(cNomArchivo,3,20);
                           LET cNombre = cPrefijo || cNombre;
                           LET cNombre = TRIM(cNombre);

                           LET cPrefijoLetra = '';
                           LET cPrefijoLetra  = SUBSTR(cArchivoControl,1,1);
                            IF cPrefijoLetra = 'C' THEN
                                LET cPrefijoControl = 'CT';
                            ELSE
                                LET cPrefijoControl = 'IT';
                            END IF;

                           LET cNombreControl = SUBSTR(cArchivoControl,3,20);
                           LET cNombreControl = cPrefijoControl || cNombreControl;
                           LET cNombreControl = TRIM(cNombreControl);

                           LET vsSQLC = '';
                           LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  trim(cNomArchivo);
                           SYSTEM vsSQLC;

                           LET vsSQLC = '';
                           LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  trim(cArchivoControl);
                           SYSTEM vsSQLC;

                           LET vsSQLC = '';
                           LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  trim(cNombre);
                           SYSTEM vsSQLC;

                           LET vsSQLC = '';
                           LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  trim(cNombreControl);
                           SYSTEM vsSQLC;
	END;

END PROCEDURE;