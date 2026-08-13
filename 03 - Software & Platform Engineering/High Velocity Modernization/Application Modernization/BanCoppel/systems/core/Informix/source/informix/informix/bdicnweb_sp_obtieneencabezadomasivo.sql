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