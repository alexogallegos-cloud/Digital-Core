CREATE PROCEDURE "informix".sp_consencabezadoslotes(pIdUsuario CHAR(8), pIdFuncion CHAR(10), pIdFuncionPadre CHAR(10), pArchDescarga char(150), pLote int, pFechaInicial date, pFechaFinal date, pUsuario CHAR(8))
        RETURNING CHAR(5) AS codret;
                        
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INT;
        DEFINE cSelectQry CHAR(1500);
        DEFINE cCmd1 CHAR(1500);

        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cSelectQry = '';
        LET cCmd1 = '';
        
        BEGIN
                
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet;
                END EXCEPTION;
                
                IF pIdUsuario = '' OR pIdFuncion = '' OR pIdFuncionPadre = '' OR pArchDescarga = '' OR pFechaInicial = '' OR pFechaFinal = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet;
                END IF;
                
                --SET DEBUG FILE TO '/tmp/sp_consencabezadoslotesOUT.sql';
                --TRACE ON;
                
                EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pIdUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet;
                END IF;
                LET cSelectQry = "select id_lote, to_char(fecha_carga, "||'"%d/%m/%Y"'||") as fecha_carga, total_registros, trim(nvl(to_char(total_monto, "||'"#,###,###,###,##&.&&"), "'||""")), registros_aceptados, registros_rechazados from bdicnweb:sw_tr_totales_masivo where ";
                
                IF pFechaInicial IS NULL THEN
                        SELECT FIRST 1 CURRENT
                        INTO pFechaInicial
                        FROM systables;
                        --WHERE id_lote <> '';
                        
                        LET pFechaFinal =  pFechaInicial;
                END IF;
                
                LET cSelectQry = TRIM(cSelectQry)||' id_funcion = "'||TRIM(pIdFuncionPadre)||'" AND DATE(fecha_carga) BETWEEN "'||pFechaInicial||'" AND "'||pFechaFinal||'"';
                
                IF pLote IS NOT NULL THEN
                        LET cSelectQry = TRIM(cSelectQry)||" AND id_lote = "||pLote;
                END IF;
                
                IF pUsuario IS NOT NULL AND TRIM(pUsuario) <> '' THEN
                        LET cSelectQry = TRIM(cSelectQry)||' AND usuario = "'||TRIM(pUsuario)||'"';
                END IF;

		LET cCmd1 = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; UNLOAD TO "||TRIM(pArchDescarga)||" "||TRIM(cSelectQry)||" order by id_lote;' | /ifxsif01/bin/dbaccess bdicnweb > /dev/null 2>&1";
                SYSTEM TRIM(cCmd1);
				
				-- LLAMADO AL SP PARA LOS ENCABEZADOS DE LOS TOTALES
				EXECUTE PROCEDURE bdicnweb:"informix".sp_obtieneencabezadototalesmasivo(pIdFuncionPadre, pArchDescarga) INTO cCodRet;
                
                RETURN cCodRet;
        
        END;
                        
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA ACTUALIZACION: 21/08/2013",
"DESCRIPCION: Procedimietno que crea el reporte de los encabezados de los lotes que incluye el numero de lote, feca de carga, toal de regitros cargados, total registros rechazados, total de regitros aceptados, el monto total del lote";

CREATE PROCEDURE "informix".sp_consencabezadoslotesreversos(pIdUsuario CHAR(8), pIdFuncion CHAR(10), pIdFuncionPadre CHAR(10), pArchDescarga char(150), pLote int, pFechaInicial date, pFechaFinal date, pUsuario CHAR(8))
        RETURNING CHAR(5) AS codret;
                        
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INT;
        DEFINE cSelectQry CHAR(1500);
        DEFINE cCmd1 CHAR(1500);

        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cSelectQry = '';
        LET cCmd1 = '';
        
        BEGIN
                
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet;
                END EXCEPTION;
                
                IF pIdUsuario = '' OR pIdFuncion = '' OR pIdFuncionPadre = '' OR pArchDescarga = '' OR pFechaInicial = '' OR pFechaFinal = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet;
                END IF;
                
                --SET DEBUG FILE TO '/tmp/sp_consencabezadoslotesreversosOUT.sql';
                --TRACE ON;
                
                EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pIdUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet;
                END IF;
                
                LET cSelectQry = "select id_lote, to_char(fecha_carga, "||'"%d/%m/%Y"'||') as fecha_carga, total_reversos, nvl(trim(to_char(monto_reversos, "#,###,###,###,##&.&&")), "") as total_monto, reversos_aceptados, reversos_rechazados from bdicnweb:"informix".sw_tr_totales_reversos where ';
                
                IF pFechaInicial IS NULL THEN
                        SELECT {+INDEX (bdicnweb:sw_tr_totales_masivo idx_sw_tr_totales_masivo)} FIRST 1 CURRENT
                        INTO pFechaInicial
                        FROM bdicnweb:"informix".sw_tr_totales_masivo;
                        
                        LET pFechaFinal =  pFechaInicial;
                END IF;
                
                LET cSelectQry = TRIM(cSelectQry)||' id_funcion = "'||TRIM(pIdFuncionPadre)||'" AND DATE(fecha_carga) BETWEEN "'||pFechaInicial||'" AND "'||pFechaFinal||'"';
                
                IF pLote IS NOT NULL THEN
                        LET cSelectQry = TRIM(cSelectQry)||" AND id_lote = "||pLote;
                END IF;
                
                IF pUsuario IS NOT NULL AND TRIM(pUsuario) <> '' THEN
                        LET cSelectQry = TRIM(cSelectQry)||' AND usuario = "'||TRIM(pUsuario)||'"';
                END IF;

		LET cCmd1 = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; UNLOAD TO "||TRIM(pArchDescarga)||" "||TRIM(cSelectQry)||" order by id_lote;' | /ifxsif01/bin/dbaccess bdicnweb > /dev/null 2>&1";
                SYSTEM TRIM(cCmd1);
				
				EXECUTE PROCEDURE bdicnweb:"informix".sp_obtieneencabezadototalesmasivo(pIdFuncionPadre, pArchDescarga) INTO cCodRet;
                
                RETURN cCodRet;
        
        END;
                        
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 09/08/2013",
"DESCRIPCION: GeneraciÃÂ³n del reporte de encabezados de los lotes que fueron reversados de la aplicaciÃÂ³n CNWEB";

CREATE PROCEDURE "informix".sp_obtieneencabezadomasivo(pIdFuncion CHAR(10), pArchivoDescarga CHAR(150))
        RETURNING CHAR(5) AS codret;
        
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cEncabezados CHAR(5000);
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cEncabezados = '';
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet;
                END EXCEPTION;
                
                SET ISOLATION TO DIRTY READ;

                LET cEncabezados = 'SELECT NVL(encabezados, ''SIN ENCABEZADOS'') FROM bdicnweb:sw_tr_encabezados_columnas_masivos WHERE id_funcion = '''||TRIM(pIdFuncion)||'''" | /ifxsif01/bin/dbaccess bdicnweb > /dev/null 2>&1';
                
                -- Se descarga el encabezado
                SYSTEM '/usr/bin/echo "UNLOAD TO '||TRIM(pArchivoDescarga)||'.tmp DELIMITER ''#'' '||TRIM(cEncabezados);
                SYSTEM '/usr/bin/awk ''{sub(/#/, ""); print }'' '||TRIM(pArchivoDescarga)||'.tmp > '||TRIM(pArchivoDescarga)||'.h';
                
                -- Cambio de nombre del archivo
                SYSTEM '/usr/bin/mv '||TRIM(pArchivoDescarga)||' '||TRIM(pArchivoDescarga)||'.do';
				
				-- Se procesa el archivo para que no lleve slashes
				SYSTEM '/usr/bin/awk ''{gsub(/\\ /, ""); print }'' '||TRIM(pArchivoDescarga)||'.do > '||TRIM(pArchivoDescarga)||'.d';
                
                -- ConcatenaciÃ³n de los archivos
                SYSTEM '/usr/bin/cat '||TRIM(pArchivoDescarga)||'.h '||TRIM(pArchivoDescarga)||'.d > '||TRIM(pArchivoDescarga);
                
                SYSTEM '/usr/bin/rm -rf '||TRIM(pArchivoDescarga)||'.tmp';
                SYSTEM '/usr/bin/rm -rf '||TRIM(pArchivoDescarga)||'.h';
				SYSTEM '/usr/bin/rm -rf '||TRIM(pArchivoDescarga)||'.do';
                SYSTEM '/usr/bin/rm -rf '||TRIM(pArchivoDescarga)||'.d';
                RETURN cCodRet;
        END;
        
END PROCEDURE;