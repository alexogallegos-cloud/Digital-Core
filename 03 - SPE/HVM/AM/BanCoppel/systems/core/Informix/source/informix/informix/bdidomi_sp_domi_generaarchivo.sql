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