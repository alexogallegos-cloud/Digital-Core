CREATE PROCEDURE "informix".sp_obtener_info_repaut_establecimiento()
    RETURNING CHAR(5) as rCODIGO_RETORNO, CHAR(80) as rMENSAJE_RESPUESTA;

    DEFINE SQL_ERR   INTEGER;
    DEFINE ISAM_ERR   INTEGER;
    DEFINE ERROR_INFO  CHAR(80);    
    DEFINE CODIGO_RETORNO CHAR(5);
    DEFINE MENSAJE_RESPUESTA VARCHAR(80);
    DEFINE RUTA_UNLOAD_RESPALDOS VARCHAR(80);
    DEFINE SCRIPT_TRUNC_R026_EST CHAR(25);    
    DEFINE SCRIPT_UPDTE_R026_EST CHAR(25);    
    DEFINE CONTADOR_TRANSACCIONES SMALLINT;    
    DEFINE PREFIJO_ARCHIVOS CHAR(9);
    DEFINE vCountRegEstablecimiento INTEGER;
    DEFINE vExecuteSQL LVARCHAR(8000);    
    
    LET SQL_ERR	 = 0;
    LET ISAM_ERR = 0;
    LET ERROR_INFO = '';
    LET CODIGO_RETORNO = '00000';
    LET CONTADOR_TRANSACCIONES = 1000;
    LET RUTA_UNLOAD_RESPALDOS = '/RESPALDOSNEW/';    
    LET MENSAJE_RESPUESTA  =  'La actualizacion ha finalizado exitosamente.';
    LET SCRIPT_TRUNC_R026_EST = 'script_trun_paso_r026.sql';
    LET SCRIPT_UPDTE_R026_EST = 'script_updt_paso_r026.sql';
    LET PREFIJO_ARCHIVOS = 'scpt_rep_';
    LET vExecuteSQL = '';    
    LET vCountRegEstablecimiento = 0;
    
    --SET DEBUG FILE TO RUTA_UNLOAD_RESPALDOS||'sp_obtener_info_repaut_establecimiento.out';
    --TRACE ON;
    
    BEGIN

        ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO        
            SET DEBUG FILE TO RUTA_UNLOAD_RESPALDOS || "excepcion_sp_obtener_info_repaut_establecimiento.err.out";
            TRACE ON;            
            IF ( SQL_ERR <> 0 ) THEN
                LET CODIGO_RETORNO = SQL_ERR;
                LET MENSAJE_RESPUESTA = ERROR_INFO;
                RETURN CODIGO_RETORNO, MENSAJE_RESPUESTA;
            END IF;            
        END EXCEPTION;
   
    
        --Limpieza de la tabla para nueva carga de informacion.
        --NOTA: El truncate table no lleva punto y coma al final para que la cadena se almacene en el archivo.
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'echo TRUNCATE TABLE intercard:"informix".tbl_paso_repaut_r026_establecimiento >'||RUTA_UNLOAD_RESPALDOS||PREFIJO_ARCHIVOS||SCRIPT_TRUNC_R026_EST;
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' dbaccess intercard '||RUTA_UNLOAD_RESPALDOS||PREFIJO_ARCHIVOS||SCRIPT_TRUNC_R026_EST;
        SYSTEM vExecuteSQL;        
        
        ---Obtener toda la informacion registrada        
        LET vExecuteSQL  = '';
        LET vExecuteSQL  = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||RUTA_UNLOAD_RESPALDOS||PREFIJO_ARCHIVOS||'info_establecimientos_mc.unl ' ||
        ' SELECT * ' ||
        '   FROM bdirepaut@coppelcont_tcp:\"informix\".sp_r026_establecimiento ' ||
        '     WHERE corresp_mc <> \" \" ' ||
         ' "> '||RUTA_UNLOAD_RESPALDOS||PREFIJO_ARCHIVOS||'descargar_tcp_r026_establecimiento.sql';
        SYSTEM vExecuteSQL;

        LET vExecuteSQL = '';
        LET vExecuteSQL = ' dbaccess intercard '||RUTA_UNLOAD_RESPALDOS||PREFIJO_ARCHIVOS||'descargar_tcp_r026_establecimiento.sql';
        SYSTEM vExecuteSQL;        
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = "echo "||'"'|| "file '"||RUTA_UNLOAD_RESPALDOS||PREFIJO_ARCHIVOS||'info_establecimientos_mc.unl'|| "' delimiter '|' "|| '10'||
                          "; INSERT INTO tbl_paso_repaut_r026_establecimiento" || ";"||'"'||' > '||RUTA_UNLOAD_RESPALDOS||PREFIJO_ARCHIVOS||'reg_info_establecimiento_026.txt';
        SYSTEM vExecuteSQL;
        
        --Se ejecuta el dbload en intercard porque ahi esta creada la tabla tbl_paso_repaut_r026_establecimiento
        LET vExecuteSQL = '';
        LET vExecuteSQL = "dbload -d intercard -c "||RUTA_UNLOAD_RESPALDOS||PREFIJO_ARCHIVOS||"reg_info_establecimiento_026.txt -l "||RUTA_UNLOAD_RESPALDOS||PREFIJO_ARCHIVOS||"err_info_estab_026.log -n "||CONTADOR_TRANSACCIONES||" -k";
        SYSTEM vExecuteSQL;
    
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'echo UPDATE STATISTICS MEDIUM FOR TABLE intercard:"informix".tbl_paso_repaut_r026_establecimiento > '||RUTA_UNLOAD_RESPALDOS||PREFIJO_ARCHIVOS||SCRIPT_UPDTE_R026_EST;
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' dbaccess intercard '||RUTA_UNLOAD_RESPALDOS||PREFIJO_ARCHIVOS||SCRIPT_UPDTE_R026_EST;
        SYSTEM vExecuteSQL; 
            
            
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' rm -f '||RUTA_UNLOAD_RESPALDOS||PREFIJO_ARCHIVOS||'*';
        SYSTEM vExecuteSQL;
        
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3; 
        
        SELECT COUNT(*) 
            INTO vCountRegEstablecimiento 
        FROM intercard:"informix".tbl_paso_repaut_r026_establecimiento;
        
        IF( vCountRegEstablecimiento = 0 ) THEN
            LET CODIGO_RETORNO = '00001';
            LET MENSAJE_RESPUESTA = 'No hay informacion disponible en la tabla r026 establecimiento';
            RETURN CODIGO_RETORNO, MENSAJE_RESPUESTA;
        END IF
        
        LET CODIGO_RETORNO = '00000';
        LET MENSAJE_RESPUESTA = 'Finalizada la carga de informacion.';

    END

    RETURN CODIGO_RETORNO, MENSAJE_RESPUESTA;

END PROCEDURE
---Coordinación de Tarjetas e Interfaces Transaccionales | Gerencia Mantenimiento I
---Fecha de creacion: 24 de abril del 2020
---Base de datos: bdicheq
---Este proceso corresponde al job 750
---Este procedimiento almacenado descarga la informacion de la tabla establecimiento del repaut.
---EXECUTE PROCEDURE "informix".sp_obtener_info_repaut_establecimiento();
;

CREATE PROCEDURE "informix".sp_generar_acum_corresponsal_mc(pEmpresa CHAR(3), pTipoCorresponsal CHAR(2))
    RETURNING CHAR(5) as vCodigoRetorno1, CHAR(50) as vCodigoRetorno2, CHAR(80) as vCodigoRetorno3;

    DEFINE SQL_ERR   INTEGER;
    DEFINE ISAM_ERR   INTEGER;
    DEFINE ERROR_INFO  CHAR(80);    
    DEFINE CODIGO_RETORNO CHAR(5);
    DEFINE MENSAJE_RESPUESTA VARCHAR(80);
    DEFINE RUTA_ORIGEN VARCHAR(80);
    DEFINE RUTA_UNLOAD_RESPALDOS VARCHAR(80);
    DEFINE ABREVIATURA_CREDITO CHAR(1);
    DEFINE ABREVIATURA_DEBITO  CHAR(1);
    DEFINE CONTADOR_TRANSACCIONES SMALLINT;
    
    DEFINE vFechaRegistroHoy  DATE;
    DEFINE vFechaRegistroAnterior DATE;
    DEFINE vPrimerDiaMes DATE;
    DEFINE vFechaRegistroInicial DATE;
    DEFINE vFechaRegistroFinal DATE;
    DEFINE vFechaRegistroProceso DATE;
    DEFINE vTienda  CHAR(20);
    DEFINE vTipoCorresponsal  CHAR(2);
    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(50);
    DEFINE vcodret3         CHAR(80);

    DEFINE vFechaRegistro  DATE;
    DEFINE vNumTransacciones INTEGER;
    DEFINE vMontoTotal       DECIMAL(18,2);
    DEFINE vTotalTrxs         INTEGER;
    DEFINE vMonto           DECIMAL(18,2);
    DEFINE vCrPlazaCrTienda       CHAR(12);
    DEFINE vCiudadTienda          CHAR(60);    
    DEFINE vExisteTienda      INTEGER;
    DEFINE vAnyoMes         CHAR(6);
    DEFINE vExecuteSQL      LVARCHAR(4000);
    DEFINE vconmovhis       CHAR(10);
    DEFINE vFechaRegistro_ejecucion DATE;
    DEFINE vfechconmovhisold CHAR(10);

    ----construcción del archivo
    DEFINE PREFIJO_ARCHIVO VARCHAR(12);
    DEFINE NOMBRE_ARCHIVO_CAPT VARCHAR(80);
    DEFINE NOMBRE_ARCHIVO_CRED VARCHAR(80);
    DEFINE SCRIPT_EJECUCION_CPT VARCHAR(50);
    DEFINE SCRIPT_EJECUCION_CRED VARCHAR(50);
    

    LET SQL_ERR	 = 0;
    LET ISAM_ERR = 0;
    LET ERROR_INFO = '';
    LET CODIGO_RETORNO = '00000';    
    LET RUTA_ORIGEN = '/RESPALDOSNEW/';
    LET RUTA_UNLOAD_RESPALDOS = '/RESPALDOSNEW/';
    LET ABREVIATURA_CREDITO = 'C';
    LET ABREVIATURA_DEBITO  = 'D';
    LET vTipoCorresponsal = pTipoCorresponsal;
    LET CONTADOR_TRANSACCIONES = 1000;
    
    ---construccion del archivo
    
    LET PREFIJO_ARCHIVO = 'movs_reg_';
    LET NOMBRE_ARCHIVO_CAPT = 'file_movs_regu_capt';
    LET NOMBRE_ARCHIVO_CRED = 'file_movs_regu_cred';
    LET SCRIPT_EJECUCION_CPT = 'script_movs_reg_cpt.sql';
    LET SCRIPT_EJECUCION_CRED = 'script_movs_reg_cred.sql';
    
    LET vcodret1 = '00000';
    LET vcodret2 = '00000';
    LET vcodret3 = '';
    
    LET vFechaRegistroHoy   = ''; 
    LET vFechaRegistroAnterior   = ''; 
    LET vPrimerDiaMes = '';
    LET vFechaRegistroProceso   = '';
    LET vFechaRegistroInicial   = '';
    LET vFechaRegistroFinal   = '';    
    
    LET vTienda    = '';
    LET vFechaRegistro       = '';
    LET vNumTransacciones = 0;
    LET vMontoTotal   = 0.00;
    LET vTotalTrxs     = 0;
    LET vMonto       = 0.00;
    LET vCrPlazaCrTienda   = '';
    LET vCiudadTienda      = '';
    
    LET vExisteTienda = 0;
    LET vAnyoMes  = '';
    LET vExecuteSQL  = '';
    
    LET vconmovhis   = '';
    LET vFechaRegistro_ejecucion = '';
    LET vfechconmovhisold = '';
    
    --SET DEBUG FILE TO RUTA_ORIGEN||'sp_generar_acum_corresponsal_mc.out';
    --TRACE ON;
    
    BEGIN

        ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO        
            SET DEBUG FILE TO RUTA_UNLOAD_RESPALDOS || "excepcion_sp_generar_acum_corresponsal_mc.err.out";
            TRACE ON;            
            IF ( SQL_ERR <> 0 ) THEN
                LET CODIGO_RETORNO = SQL_ERR;
                LET MENSAJE_RESPUESTA = ERROR_INFO || vcodret3;
                RETURN CODIGO_RETORNO, MENSAJE_RESPUESTA, vcodret3;
            END IF;            
        END EXCEPTION;

        ON EXCEPTION IN (-696)
            LET CODIGO_RETORNO = '00001';
            LET MENSAJE_RESPUESTA = 'Validar los valores de las fechas asignadas';
        END EXCEPTION WITH resume;
    
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;    
        
        --Iniicializar tablas y carga de informacion de establecimientos bdirepaut
        TRUNCATE TABLE bdicheq:"informix".sc_movs_capt_corresp_mc;
        TRUNCATE TABLE bdicheq:"informix".sc_movs_cred_corresp_mc;
            
        ----Obtener la informacion registrada en el repaut
        EXECUTE PROCEDURE bdicheq:"informix".sp_obtener_info_repaut_establecimiento()
            INTO vcodret1, MENSAJE_RESPUESTA;
        
        IF (vcodret1 <> '00000') THEN
            LET vcodret1 = '00001';
            LET vcodret2 = '00009';
            LET vcodret3 = MENSAJE_RESPUESTA;
            RETURN vcodret1, vcodret2, vcodret3;
        END IF         
        
        
        SELECT fecha_hoy, fecha_ant, pri_dia_mes
            INTO vFechaRegistroHoy, vFechaRegistroAnterior, vPrimerDiaMes
        --FROM intercard:si_fechas_temp
        FROM bdicheq:sc_fechas
            WHERE empresa = pempresa;
     
        LET vFechaRegistroInicial = vPrimerDiaMes - 1 UNITS MONTH;
        LET vFechaRegistroFinal = vPrimerDiaMes - 1 UNITS DAY;        
        --LET vFechaRegistroFinal = vPrimerDiaMes + 9 UNITS DAY;        
    
        -- // VERIFICA QUE NO SE HAYA EJECUTADO EL PROCESO PARA ESTE PERIODO
        SELECT fecha
            INTO vFechaRegistro_ejecucion
        FROM bdicheq:sc_contproc_corresp
            WHERE empresa = pempresa
        AND proceso = 'movs_corresp_oxxo';
       
        IF ( vFechaRegistro_ejecucion >= vPrimerDiaMes ) THEN
        
            LET vcodret1 = '00001';
            LET vcodret2 = '00001';
            
            SELECT descripcion
                INTO vcodret3
            FROM bdinteg:si_codret
                WHERE codigo_retorno = '958'
            AND sistema = '01';
               
            RETURN vcodret1, vcodret2, vcodret3;
        END IF;     

        
        -- // Verifica se haya efectuado el paso de movs a historico
        SELECT fecha 
                INTO vFechaRegistroProceso
        FROM bdicheq:sc_contproc
            WHERE empresa = pempresa 
                AND proceso = "pasomovshist"
                    AND fecha = vFechaRegistroAnterior;
       
        IF ( vFechaRegistroProceso IS NULL ) THEN
        
            LET vcodret1 = '00002';
            LET vcodret2 = '00002';
            
            SELECT descripcion
                INTO vcodret3
            FROM bdinteg:si_codret
                WHERE codigo_retorno = '953'
                    AND sistema = '01';
               
            RETURN vcodret1, vcodret2, vcodret3;
            
        END IF;
    
        SELECT valor
                INTO vconmovhis
        FROM bdicheq:sc_param
            WHERE empresa = pEmpresa
                AND codparam = 'fechcon_movhis';

        SELECT valor 
                INTO vfechconmovhisold
        FROM bdicheq:sc_param
            WHERE empresa = pEmpresa
                AND codparam = 'FechIniCon_movhis_ol';

        LET vTienda = '';
        LET vFechaRegistro = '';
        LET vNumTransacciones = 0;
        LET vMontoTotal = 0.00;    

        --#1 --Obtener y guardar informacion de débito
        
        LET vExecuteSQL	= '';
        LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||RUTA_UNLOAD_RESPALDOS||NOMBRE_ARCHIVO_CAPT||'.unl'||
            ' SELECT \"'||ABREVIATURA_DEBITO||'\" as abreviatura,SUBSTR(referencia,2,20) as tienda, COUNT(*) as num_trxs_tienda, SUM(monto_tot) as monto_total, fech_alt, '||pTipoCorresponsal||
            '   FROM bdicheq:sc_movhis_old     ' ||            
            '  WHERE fech_alt  BETWEEN '''||vFechaRegistroInicial||''' AND '''||vFechaRegistroFinal||''' '||
            '   AND empresa = \"'||pEmpresa||'\"'||
            '      AND cancelad <> \"S\"  '||
            '   AND transacc = \"0482\" '||
            ' GROUP BY referencia, fech_alt '||            
            
            'UNION ALL '||
            
            ' SELECT \"'||ABREVIATURA_DEBITO||'\" as abreviatura,SUBSTR(referencia,2,20) as tienda, COUNT(*) as num_trxs_tienda, SUM(monto_tot) as monto_total, fech_alt, '||pTipoCorresponsal||
            '   FROM bdicheq:sc_movhis    ' ||            
            '  WHERE fech_alt  BETWEEN '''||vFechaRegistroInicial||''' AND '''||vFechaRegistroFinal||''' '||
            '   AND empresa = \"'||pEmpresa||'\"'||
            '      AND cancelad <> \"S\"  '||
            '   AND transacc = \"0482\" '||
            ' GROUP BY referencia, fech_alt '||            
            
            '" >'||RUTA_ORIGEN||SCRIPT_EJECUCION_CPT;            
        SYSTEM vExecuteSQL;    
            
        LET vExecuteSQL   =   '';
        LET vExecuteSQL   =   'dbaccess bdicheq '||RUTA_ORIGEN||SCRIPT_EJECUCION_CPT;
        SYSTEM vExecuteSQL;

        LET vExecuteSQL = '';
        LET vExecuteSQL = "echo "||'"'|| "file '"||RUTA_UNLOAD_RESPALDOS||NOMBRE_ARCHIVO_CAPT||'.unl'|| "' delimiter '|' "|| '6'||                          
                          "; INSERT INTO sc_movs_capt_corresp_mc" || ";"||'"'||' > '||RUTA_ORIGEN||PREFIJO_ARCHIVO||'registrar_movs_captacion.txt';
        SYSTEM vExecuteSQL;
        
        --Se ejecuta el dbload en bdicheq porque ahi esta creada la tabla sc_movs_capt_corresp_mc
        LET vExecuteSQL = '';
        LET vExecuteSQL = "dbload -d bdicheq -c "||RUTA_ORIGEN||PREFIJO_ARCHIVO||"registrar_movs_captacion.txt -l "||RUTA_ORIGEN||PREFIJO_ARCHIVO||"err_carga_capt.log -n "||CONTADOR_TRANSACCIONES||" -k";
        SYSTEM vExecuteSQL;
        
        
        --#2 --Obtener y guardar informacion de crédito
        LET vExecuteSQL	= '';
        LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||RUTA_UNLOAD_RESPALDOS||NOMBRE_ARCHIVO_CRED||'.unl'||
            ' SELECT \"'||ABREVIATURA_CREDITO||'\" as abreviatura,SUBSTR(referencia,2,20) as tienda, COUNT(*) as num_trxs_tienda, SUM(monto) as monto_total, fecha_mov, '||pTipoCorresponsal||
            '   FROM bdicred:sd_movhis     ' ||            
            '  WHERE empresa = \"'||pEmpresa||'\"'||
            '   AND reversado = \"N\" ' ||
            '  AND fecha_mov  BETWEEN '''||vFechaRegistroInicial||''' AND '''||vFechaRegistroFinal||''' '||
            '   AND codigo_fun = \"701\" ' ||
            '   AND transacc_suc = \"6283\" ' ||
            '   AND referencia IS NOT NULL ' ||            
            ' GROUP BY referencia, fecha_mov '||
            '" >'||RUTA_ORIGEN||SCRIPT_EJECUCION_CRED;            
        SYSTEM vExecuteSQL; 
        
        LET vExecuteSQL   =   '';
        LET vExecuteSQL   =   'dbaccess bdicheq '||RUTA_ORIGEN||SCRIPT_EJECUCION_CRED;
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = "echo "||'"'|| "file '"||RUTA_UNLOAD_RESPALDOS||NOMBRE_ARCHIVO_CRED||'.unl'|| "' delimiter '|' "|| '6'||                          
                          "; INSERT INTO sc_movs_cred_corresp_mc" || ";"||'"'||' > '||RUTA_ORIGEN||PREFIJO_ARCHIVO||'registrar_movs_credito.txt';
        SYSTEM vExecuteSQL;
        
        --Se ejecuta el dbload en bdicheq porque ahi esta creada la tabla sc_movs_cred_corresp_mc
        LET vExecuteSQL = '';
        LET vExecuteSQL = "dbload -d bdicheq -c "||RUTA_ORIGEN||PREFIJO_ARCHIVO||"registrar_movs_credito.txt -l "||RUTA_ORIGEN||PREFIJO_ARCHIVO||"err_carga_credito.log -n "||CONTADOR_TRANSACCIONES||" -k";
        SYSTEM vExecuteSQL;
        
        
        --Borrado de todos los archivos generados en el proceso
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' rm -f '||RUTA_ORIGEN||SCRIPT_EJECUCION_CRED||'*';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' rm -f '||RUTA_ORIGEN||SCRIPT_EJECUCION_CPT||'*';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' rm -f '||RUTA_ORIGEN||PREFIJO_ARCHIVO||'*';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' rm -f '||RUTA_UNLOAD_RESPALDOS||NOMBRE_ARCHIVO_CAPT||'*';
        SYSTEM vExecuteSQL;        
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' rm -f '||RUTA_UNLOAD_RESPALDOS||NOMBRE_ARCHIVO_CRED||'*';
        SYSTEM vExecuteSQL;
                

        ---Inician las inserciones de lo acumulado de captación y crédito
        LET vTienda = '';
        LET vTotalTrxs = 0;
        LET vMonto = 0.00;
        LET vFechaRegistro = '';
        LET vExisteTienda = 0;
    
        FOREACH regs_acumulado_capt WITH HOLD FOR
        
            SELECT tienda, num_movs_capt, monto_capt, fecha, corresponsal
                INTO vTienda, vTotalTrxs, vMonto, vFechaRegistro, vTipoCorresponsal
            FROM bdicheq:sc_movs_capt_corresp_mc
                WHERE tipo_mov = ABREVIATURA_DEBITO
                    AND corresponsal = vTipoCorresponsal

            SELECT COUNT(*)
                INTO vExisteTienda
            FROM bdicheq:sc_movs_corresp_mc
                WHERE corresponsal  = vTipoCorresponsal          
                    AND tienda = vTienda
                        AND fecha = vFechaRegistro;

            BEGIN;
            
                IF (vExisteTienda = 0) THEN
                    INSERT INTO bdicheq:sc_movs_corresp_mc(tienda, clave_estado, fecha, num_movs_capt, monto_capt, num_movs_cred, monto_cred, corresponsal)
                        VALUES(vTienda, NULL, vFechaRegistro, vTotalTrxs, vMonto, 0, 0.00, vTipoCorresponsal);
                ELSE
                    UPDATE bdicheq:sc_movs_corresp_mc
                        SET num_movs_capt = vTotalTrxs,
                                monto_capt = vMonto
                        WHERE fecha = vFechaRegistro
                            AND tienda = vTienda
                        AND corresponsal  = vTipoCorresponsal;
                END IF;
            
            COMMIT;
            
            LET vTienda = '';
            LET vTotalTrxs = 0;
            LET vMonto = 0.00;
            LET vFechaRegistro = '';
            LET vExisteTienda = 0;
            
        END FOREACH;

        
        -- // INSERTA MOVIMIENTOS DE CRÉDITO
        LET vTienda = '';
        LET vTotalTrxs = 0;
        LET vMonto = 0.00;
        LET vFechaRegistro = '';
        LET vExisteTienda = 0;
    
        UPDATE STATISTICS MEDIUM FOR TABLE bdicheq: "informix".sc_movs_corresp_mc;
    
        FOREACH regs_acumulado_cred WITH HOLD FOR
        
            SELECT tienda, num_movs_cred, monto_cred, fecha, corresponsal
              INTO vTienda, vTotalTrxs, vMonto, vFechaRegistro, vTipoCorresponsal
              FROM bdicheq:sc_movs_cred_corresp_mc         
                WHERE tipo_mov = ABREVIATURA_CREDITO
                    AND corresponsal = vTipoCorresponsal                    
                    
            SELECT COUNT(*)
                INTO vExisteTienda
            FROM bdicheq:sc_movs_corresp_mc
                WHERE corresponsal  = vTipoCorresponsal          
                    AND tienda = vTienda
                        AND fecha = vFechaRegistro;                
            
            BEGIN;

                IF (vExisteTienda = 0) THEN                   
                        
                    INSERT INTO bdicheq:sc_movs_corresp_mc(tienda, clave_estado, fecha, num_movs_capt, monto_capt, num_movs_cred, monto_cred, corresponsal)
                        VALUES(vTienda, NULL, vFechaRegistro, 0, 0.00, vTotalTrxs, vMonto, vTipoCorresponsal);
                ELSE
                    UPDATE bdicheq:sc_movs_corresp_mc
                       SET num_movs_cred = vTotalTrxs,
                           monto_cred = vMonto
                     WHERE fecha = vFechaRegistro
                       AND tienda = vTienda
                       AND corresponsal  = vTipoCorresponsal;
                END IF;
                
            COMMIT;
            
            LET vTienda = '';
            LET vTotalTrxs = 0;
            LET vMonto = 0.00;
            LET vFechaRegistro = '';
            LET vExisteTienda = 0;
            
        END FOREACH;

        UPDATE STATISTICS MEDIUM FOR TABLE bdicheq: "informix".sc_movs_corresp_mc;
        
        --LET vcodret1 = '90000';
        --LET vcodret2 = '90000';
        --LET vcodret3 = '90000';
        
        -- //Busca la clave del estado para cada una de las tiendas del corresponsal.
        EXECUTE PROCEDURE bdicheq:"informix".sp_obtener_info_regulacion_r026( pEmpresa , pTipoCorresponsal )
            INTO  vcodret1, vcodret2;


        -- // DESCARGA EL ARCHIVO DE INFORMACIÓN
        LET vAnyoMes = TO_CHAR(vFechaRegistroFinal, '%Y%m');
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'echo "SET ISOLATION DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||RUTA_UNLOAD_RESPALDOS||'rpt_corresp_acum_oxxo_'||vAnyoMes||'.txt '||                   
                   ' SELECT tienda, clave_estado, num_movs_capt::INTEGER, monto_capt, num_movs_cred::INTEGER, monto_cred, TO_CHAR(fecha, '''||'%d%m%Y'||''')'||
                   '       FROM bdicheq:sc_movs_corresp_mc WHERE fecha BETWEEN '''||vFechaRegistroInicial||''' AND '''||vFechaRegistroFinal||''' ORDER BY fecha, tienda" > '||RUTA_UNLOAD_RESPALDOS||'sc_rpt_acum_corresp.sql';
        SYSTEM vExecuteSQL;
    
        LET vExecuteSQL = '';
        LET vExecuteSQL = "dbaccess bdicheq "||RUTA_UNLOAD_RESPALDOS||"sc_rpt_acum_corresp.sql";
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' rm -f '||RUTA_UNLOAD_RESPALDOS||'sc_rpt_acum_corresp.sql';
        SYSTEM vExecuteSQL;


        IF ( vcodret1 = '00000') THEN
            
            BEGIN;
                UPDATE bdicheq:sc_contproc_corresp
                   SET fecha = vFechaRegistroHoy
                 WHERE empresa = pempresa
                   AND proceso = 'movs_corresp_oxxo';           
            COMMIT;           
            
        END IF

        LET vcodret3 = 'EL PROCESO SE REALIZO SATISFACTORIAMENTE';

    END;


    RETURN vcodret1, vcodret2, vcodret3;

END PROCEDURE
---Coordinación de Tarjetas e Interfaces Transaccionales | Gerencia Mantenimiento I
---Fecha de creacion: 18 de septiembre del 2019
---Fecha de modificación  03 de marzo del 2020
---#2. Fecha de modificación  20 de mayo del 2020
--- Se agrega condicion del campo referencia en la tabla de credito
---Base de datos: bdicheq
---Este proceso corresponde al job 750
----EXECUTE PROCEDURE "informix".sp_generar_acum_corresponsal_mc('001', '2');
;

CREATE PROCEDURE "informix".sp_descifra_respuesta_isa( pCodigo CHAR(20) ) 
RETURNING CHAR(6);
    
    DEFINE cCodRet          CHAR(6);
    DEFINE cCodRet2         CHAR(5);
    DEFINE cCodRet3	        CHAR(50);
    DEFINE iSqlErr          INTEGER;
    DEFINE iSamErr          INTEGER;
    DEFINE cDesErr	        CHAR(150);
    DEFINE vUsuario         CHAR(20);
    DEFINE vLLave           CHAR(200);
    DEFINE vNomarch         CHAR(100);
    DEFINE vRutaOrigen      CHAR(100);
    DEFINE vRutaDestino     CHAR(100);
    DEFINE vNomarchSalida   CHAR(100);
    DEFINE vRutaOriginales  CHAR(100);
    DEFINE vNomarch_salida  CHAR(100);
    
    
    LET cCodRet         = '';
    LET cCodRet2        = 0;
    LET cCodRet3        = '';
    LET iSqlErr         = 0;
    LET iSamErr         = 0;
    LET cDesErr         = '';
    LET vUsuario        = '';
    LET vLLave          = '';
    LET vNomarch        = '';
    LET vRutaOrigen     = '';
    LET vRutaDestino    = '';
    LET vNomarchSalida  = '';
    LET vRutaOriginales = '';
    LET vNomarch_salida = '';
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/ArchivosRespuestaIsa/sp_descifra_respuesta_isa.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;
    
     --SET DEBUG FILE TO "/resplogifx/conciliachq/ArchivosRespuestaIsa/sp_descifra_respuesta_isa.out";
     --TRACE ON;
    
    FOREACH
        SELECT TRIM(usuario), TRIM(llave), TRIM(nomarch), TRIM(ruta_origen), TRIM(nomarch_salida), TRIM(ruta_destino), TRIM(ruta_originales)
          INTO vUsuario, vLLave, vNomarch, vRutaOrigen, vNomarch_salida, vRutaDestino, vRutaOriginales    
          FROM bdinteg:si_configura_pgp_chq
         WHERE codigo = pCodigo
         ORDER BY secuencia
        
        IF vUsuario <> user THEN
            LET cCodRet = '200';
            RETURN cCodRet;
        END IF;
        
		
			   
        SYSTEM 'echo "export PATH=/usr/bin:/etc:/usr/sbin:/usr/ucb:/home/'||TRIM(vUsuario)||'/bin:/usr/bin/X11:/sbin:.:/opt/pgp/bin:/informix/bin" > '||TRIM(vRutaOrigen)||'blinda_respuesta.sh';
        SYSTEM 'echo "export HOME=/home/'||TRIM(vUsuario)||'" >> '||TRIM(vRutaOrigen)||'blinda_respuesta.sh';
        
		SYSTEM '/usr/bin/rm '||TRIM(vRutaOrigen)||TRIM(vNomarch)||'txt'; 
		
        SYSTEM 'echo "/opt/pgp/bin/pgp --decrypt ' ||TRIM(vRutaOrigen)||TRIM(vNomarch)||' --passphrase '||''''||TRIM(vLLave)||'''" >> '||TRIM(vRutaOrigen)||'blinda_respuesta.sh';
		
        SYSTEM '/usr/bin/chmod 777 '||TRIM(vRutaOrigen)||'blinda_respuesta.sh';   
        SYSTEM '/usr/bin/sh '||TRIM(vRutaOrigen)||'blinda_respuesta.sh';
        
        --SYSTEM '/usr/bin/mv '||TRIM(vRutaOrigen)||TRIM(vNomarch)||' '||vRutaDestino; 
        SYSTEM '/usr/bin/mv '||TRIM(vRutaOrigen)||TRIM(vNomarch)||'pgp'||' '||vRutaDestino; 
    END FOREACH;
    
    LET cCodRet = '000000';
    
    RETURN cCodRet;
    
    END;
    
END PROCEDURE;