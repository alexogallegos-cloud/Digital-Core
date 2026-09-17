CREATE PROCEDURE "informix".sp_trans_movs_principal( pFechaBusqInicial DATETIME YEAR to FRACTION(5), pFechaBusqFinal DATETIME YEAR to FRACTION(5) )
    RETURNING VARCHAR(5) as rCODIGO_RETORNO, VARCHAR (100) as rMENSAJE_RETORNO,
            DATETIME YEAR to FRACTION(5) as rFechaInicial, DATETIME YEAR to FRACTION(5) as rFechaFinal;	
    
    DEFINE SQLERR		INTEGER;
	DEFINE ISAM_ERR		INTEGER;
	DEFINE ERROR_INFO	VARCHAR(80);
    DEFINE RUTA_DESTINO VARCHAR(80);   
    DEFINE vFechaInicial DATETIME YEAR TO FRACTION (5);
	DEFINE vFechaFinal DATETIME YEAR TO FRACTION (5);    
    DEFINE vCodigoRetorno CHAR(5);				
    DEFINE vMensajeRetorno VARCHAR(100);    
    DEFINE vFechaHoyIntegral DATE; 
    DEFINE vFechaEjecucion	CHAR(8);
    
    LET SQLERR = '';
	LET ISAM_ERR = '';
	LET ERROR_INFO = '';
    LET RUTA_DESTINO = '/RESPALDOSNEW/';    
    LET vCodigoRetorno = '00000';
    LET vMensajeRetorno = 'PROCESO EXITOSO';
    LET vFechaHoyIntegral = '';
    LET vFechaEjecucion = '';
    LET vFechaInicial = '';
	LET vFechaFinal = '';
    
    --SET DEBUG FILE TO RUTA_DESTINO|| 'sp_trans_movs_principal.out';
    --TRACE ON;
    
	BEGIN
    
        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
            
            SET DEBUG FILE TO RUTA_DESTINO || "excep_sp_trans_movs_principal.err.out" WITH APPEND;
            TRACE ON;
            
            IF ( SQLERR <> 0 ) THEN
                LET vCodigoRetorno = SQLERR;
                LET vMensajeRetorno = ERROR_INFO;                
                RETURN vCodigoRetorno, vMensajeRetorno, vFechaInicial, vFechaFinal;
            END IF;
			
        END EXCEPTION;
		
        SET ISOLATION TO DIRTY READ; 
        SET LOCK MODE TO WAIT 3;
        
        LET vFechaInicial = pFechaBusqInicial;
        LET vFechaFinal = pFechaBusqFinal;

        EXECUTE PROCEDURE intercard:"informix".sp_trans_movs_unload_stat06(vFechaInicial, vFechaFinal)
            INTO vCodigoRetorno, vMensajeRetorno;
        
        IF ( vCodigoRetorno = '00001' ) THEN 
            --no hay informacion para ser procesada.
            LET vCodigoRetorno = '00000';            
            RETURN vCodigoRetorno, vMensajeRetorno, vFechaInicial, vFechaFinal;
        END IF
        
        IF ( vCodigoRetorno <> '00000' ) THEN 
            LET vMensajeRetorno = 'Error al obtener los movimientos del stat 06';
            RETURN vCodigoRetorno, vMensajeRetorno, vFechaInicial, vFechaFinal;
        END IF
        
        EXECUTE PROCEDURE intercard:"informix".sp_trans_movs_pivote_stat06(vFechaInicial, vFechaFinal)
            INTO vCodigoRetorno, vMensajeRetorno;
        
        IF ( vCodigoRetorno <> '00000' ) THEN 
            LET vMensajeRetorno = 'Error al registrar en la tabla pivote del stat 06';
            RETURN vCodigoRetorno, vMensajeRetorno, vFechaInicial, vFechaFinal;
        END IF
        
        EXECUTE PROCEDURE intercard:"informix".sp_trans_movs_depurar_stat06(vFechaInicial, vFechaFinal)
            INTO vCodigoRetorno, vMensajeRetorno;
        
        IF ( vCodigoRetorno <> '00000' ) THEN 
            LET vMensajeRetorno = 'Error al depurar en la tabla stat 06';
            RETURN vCodigoRetorno, vMensajeRetorno, vFechaInicial, vFechaFinal;
        END IF
        
        RETURN vCodigoRetorno, vMensajeRetorno, vFechaInicial, vFechaFinal;
    END

END PROCEDURE
DOCUMENT
'Base de datos: intercard',
'Fecha de creacion: 15 de abril del 2021',
'Armando Garcia Ortiz',
'Coordinacion de Tarjetas - Gerencia I',
'Descripcion: Componente principal ejecutado por '
;

CREATE PROCEDURE "informix".sp_trans_bitac_envios_principal( pFechaBusqInicial DATETIME YEAR TO SECOND, pFechaBusqFinal DATETIME YEAR TO SECOND )
    RETURNING VARCHAR(5) as rCODIGO_RETORNO, VARCHAR (100) as rMENSAJE_RETORNO,
            DATETIME YEAR TO SECOND as rFechaInicial, DATETIME YEAR TO SECOND as rFechaFinal;	
    
    DEFINE SQLERR		INTEGER;
	DEFINE ISAM_ERR		INTEGER;
	DEFINE ERROR_INFO	VARCHAR(80);
    DEFINE RUTA_DESTINO VARCHAR(80);   
    DEFINE vFechaInicial DATETIME YEAR TO FRACTION (5);
	DEFINE vFechaFinal DATETIME YEAR TO FRACTION (5);    
    DEFINE vCodigoRetorno CHAR(5);				
    DEFINE vMensajeRetorno VARCHAR(100);    
    DEFINE vFechaHoyIntegral DATE; 
    DEFINE vFechaEjecucion	CHAR(8);
    DEFINE vAnio CHAR(4);
    
    LET SQLERR = '';
	LET ISAM_ERR = '';
	LET ERROR_INFO = '';
    LET RUTA_DESTINO = '/RESPALDOSNEW/';    
    LET vCodigoRetorno = '00000';
    LET vMensajeRetorno = 'PROCESO EXITOSO';
    LET vFechaHoyIntegral = '';
    LET vFechaEjecucion = '';
    LET vFechaInicial = '';
	LET vFechaFinal = '';
	LET vAnio = '';
    
    --SET DEBUG FILE TO RUTA_DESTINO|| 'sp_trans_bitac_envios_principal.out';
    --TRACE ON;
    
	BEGIN
    
        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
            
            SET DEBUG FILE TO RUTA_DESTINO || "excep_sp_trans_bitac_envios_principal.err.out" WITH APPEND;
            TRACE ON;
            
            IF ( SQLERR <> 0 ) THEN
                LET vCodigoRetorno = SQLERR;
                LET vMensajeRetorno = ERROR_INFO;                
                RETURN vCodigoRetorno, vMensajeRetorno, vFechaInicial, vFechaFinal;
            END IF;
			
        END EXCEPTION;
		
        SET ISOLATION TO DIRTY READ; 
        SET LOCK MODE TO WAIT 3;
        
        LET vAnio = YEAR(pFechaBusqInicial);
        
        LET vFechaInicial = pFechaBusqInicial;
        LET vFechaFinal = pFechaBusqFinal;

        EXECUTE PROCEDURE intercard:"informix".sp_trans_bitac_envios_unload(vFechaInicial, vFechaFinal, vAnio)
            INTO vCodigoRetorno, vMensajeRetorno;
        
        IF ( vCodigoRetorno = '00001' ) THEN 
            --no hay informacion para ser procesada.
            LET vCodigoRetorno = '00000';            
            RETURN vCodigoRetorno, vMensajeRetorno, vFechaInicial, vFechaFinal;
        END IF
        
        IF ( vCodigoRetorno <> '00000' ) THEN 
            LET vMensajeRetorno = 'Error al obtener los movimientos de la bitacora de envios';
            RETURN vCodigoRetorno, vMensajeRetorno, vFechaInicial, vFechaFinal;
        END IF        
        
        EXECUTE PROCEDURE intercard:"informix".sp_trans_bitac_envios_pivote(vFechaInicial, vFechaFinal, vAnio)
            INTO vCodigoRetorno, vMensajeRetorno;
        
        IF ( vCodigoRetorno <> '00000' ) THEN 
            LET vMensajeRetorno = 'Error al registrar en la tabla pivote de la bitacora de envios';
            RETURN vCodigoRetorno, vMensajeRetorno, vFechaInicial, vFechaFinal;
        END IF
        
        EXECUTE PROCEDURE intercard:"informix".sp_trans_bitac_envios_depurar(vFechaInicial, vFechaFinal, vAnio)
            INTO vCodigoRetorno, vMensajeRetorno;
        
        IF ( vCodigoRetorno <> '00000' ) THEN 
            LET vMensajeRetorno = 'Error al depurar en la tabla bitacora de envios';
            RETURN vCodigoRetorno, vMensajeRetorno, vFechaInicial, vFechaFinal;
        END IF
        
        RETURN vCodigoRetorno, vMensajeRetorno, vFechaInicial, vFechaFinal;
    END

END PROCEDURE
DOCUMENT
'Base de datos: intercard',
'Fecha de creacion: 15 de abril del 2021',
'Armando Garcia Ortiz',
'Coordinacion de Tarjetas - Gerencia I',
'Descripcion: Componente principal ejecutado por '
;

CREATE PROCEDURE "informix".sp_trans_bitac_envios_depurar( pFechaBusqInicial DATETIME YEAR TO SECOND, pFechaBusqFinal DATETIME YEAR TO SECOND, pAnio CHAR(4) )
    RETURNING CHAR(5), INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE error_info CHAR(50);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vRegistros               INTEGER;
    DEFINE vId                              INTEGER;
    DEFINE vfecha_oper      DATE;
    DEFINE vSecuencial INTEGER;
    DEFINE vIdProceso VARCHAR(50) ;
    DEFINE vNumTarjeta VARCHAR(16);
    DEFINE vFechaInsert DATETIME YEAR to SECOND;    
    
    
    LET vcodret1        = '00000';
    LET sql_err             = 0;
    LET isam_err        = 0;
    LET vcontador1      = -1;
    LET vcontador2      = 0;
    LET vRegistros      = 0;
    LET vId                         = 0;
    LET vIdProceso      ='';
    LET vNumTarjeta     ='';
    LET vFechaInsert ='';
    LET vSecuencial = 0;
    

    BEGIN

        ON EXCEPTION SET sql_err, isam_err
            SET DEBUG FILE TO "/RESPALDOSNEW/exc_sp_trans_bitac_envios_depurar.err.out";
            TRACE ON;
            
            IF vcontador1 > -1 THEN
                COMMIT WORK;
            END IF
        
                IF sql_err <> 0 THEN
                        LET vcodret1 = sql_err;
                        LET vcontador1 = isam_err;
                        RETURN vcodret1, vcontador1;
                END IF
        END EXCEPTION

        --SET DEBUG FILE TO "/RESPALDOSNEW/sp_trans_bitac_envios_depurar.out";
        --TRACE ON;
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 4;
        
        FOREACH curIterarSTAT WITH HOLD FOR

            SELECT secuencial, id_proceso, tarjeta, fecha_insert
                INTO vSecuencial, vIdProceso, vNumTarjeta, vFechaInsert
            FROM intercard:"informix".tbl_bit_envios_pivote  
            WHERE numero = 0
            ORDER BY secuencial

            IF vcontador1 = -1 THEN
                    LET vcontador1 = 0;
                    BEGIN WORK;
            END IF;

            DELETE FROM intercard:"informix".bitacoraenvios_tjts 
                    WHERE secuencial = vSecuencial
                AND id_proceso = vIdProceso 
                    AND tarjeta = vNumTarjeta 
                AND fecha_insert BETWEEN pFechaBusqInicial AND pFechaBusqFinal;
                    --AND fechaconciliacion BETWEEN pFechaBusqInicial AND pFechaBusqFinal;                       
                    --AND fechaconciliacion BETWEEN '2019-10-01 00:00:00.00000' AND '2019-10-31 23:59:59.99999';                       

            UPDATE intercard:"informix".tbl_bit_envios_pivote 
                SET numero = 1 
            WHERE secuencial = vSecuencial
                AND id_proceso = vIdProceso 
                    AND tarjeta = vNumTarjeta                
                AND fecha_insert = vFechaInsert;
                --BETWEEN pFechaBusqInicial AND pFechaBusqFinal;
                    
            LET vcontador1 = vcontador1 + 1;
            LET vcontador2 = vcontador2 + 1;

             IF vcontador2 >= 1000 THEN
                    LET vcontador2 = 0;
                    COMMIT WORK;
                    BEGIN WORK;
             END IF;

            COMMIT WORK;
            BEGIN WORK;

        END FOREACH;
        
        IF vcontador1 > -1 THEN
                COMMIT WORK;
        END IF

        RETURN vcodret1, vcontador1;
    END;
END PROCEDURE;