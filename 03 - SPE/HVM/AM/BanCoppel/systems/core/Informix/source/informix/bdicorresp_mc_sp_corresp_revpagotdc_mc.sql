CREATE PROCEDURE "informix".sp_corresp_revpagotdc_mc( pNombreCorresponsal VARCHAR(9), pusuario char(8), pfolio char(16) )

    RETURNING CHAR(5)  as CODIGO_RETORNO, DATE as vFechaCentralHoy, MONEY(14,2) as vSaldoDisp, VARCHAR(80) as MENSAJE_RESPUESTA;

    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE CODIGO_RETORNO   CHAR(5);
    DEFINE RUTA_ORIGEN          VARCHAR(80);
    DEFINE cod_ret2         CHAR(5);
    DEFINE vtransaccion     INTEGER;
    DEFINE vreversado       SMALLINT;
    DEFINE vFechaCentralHoy DATE;
    DEFINE MENSAJE_RESPUESTA VARCHAR(80);
    DEFINE vSaldoDisp     MONEY(14,2);
    DEFINE vNumCredito    VARCHAR(13);
    DEFINE cCondCentroDeCostos VARCHAR(20);
    DEFINE vCentroCostos CHAR(4);
    DEFINE CORRESPONSAL_OXXO CHAR(9);
    DEFINE CORRESPONSAL_SEVEN_ELEVEN CHAR(9);
    DEFINE vNombreCorresponsal CHAR(9);
    
    LET sql_err  = 0;
    LET isam_err = 0;
    LET CODIGO_RETORNO = "00000";
    LET cod_ret2 = "000";
    LET vtransaccion = 0;
    LET vreversado = 0;
    LET vFechaCentralHoy = '';
    LET MENSAJE_RESPUESTA = 'Ejecucion exitosa';
    LET vSaldoDisp = 0.00;
    LET vNumCredito = '';
    LET vCentroCostos= NULL;
    LET RUTA_ORIGEN = '/RESPALDOSNEW/';
    LET CORRESPONSAL_OXXO = 'OXXO';
    LET CORRESPONSAL_SEVEN_ELEVEN = 'SEVEN';
    LET vNombreCorresponsal = TRIM(pNombreCorresponsal);
    
    --SET DEBUG FILE TO RUTA_ORIGEN||'debug_sp_corresp_revpagotdc_mc_'||LOWER(TRIM(vNombreCorresponsal))||'.out';
    --TRACE ON;

    BEGIN
    
        ON EXCEPTION SET sql_err, isam_err
            IF (sql_err <> 0) THEN
            
                SET DEBUG FILE TO RUTA_ORIGEN||'excep_sp_corresp_revpagotdc_mc_'||LOWER(TRIM(vNombreCorresponsal))||'.err.out' WITH APPEND;
                TRACE ON;
                LET CODIGO_RETORNO = sql_err;
                LET cod_ret2 = isam_err;                
                LET MENSAJE_RESPUESTA = 'Error|excepcion_sp_corresp_revpagotdc_mc';
                IF vtransaccion = 1 then
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF
                RETURN CODIGO_RETORNO, vFechaCentralHoy, vSaldoDisp, MENSAJE_RESPUESTA;
            END IF;
        END EXCEPTION;

        ON EXCEPTION IN (-535)
            LET vtransaccion = 1;
        END EXCEPTION WITH resume;

        IF vtransaccion = 1 THEN
            COMMIT WORK;
            BEGIN WORK;
        ELSE
            BEGIN WORK;
        END IF;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
    
        IF (vNombreCorresponsal is null OR vNombreCorresponsal = '') OR
           (pusuario is null OR pusuario = '' OR LENGTH(pusuario) <> 8) OR
           (pfolio is null OR pfolio = '' OR LENGTH(pfolio) < 15) THEN
            
            LET CODIGO_RETORNO = '00010';
            LET MENSAJE_RESPUESTA = 'Parametros incorrectos.';
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            
            RETURN CODIGO_RETORNO, vFechaCentralHoy, vSaldoDisp, MENSAJE_RESPUESTA;
        ELSE
            SELECT COUNT(*)
              INTO vreversado
              FROM bdicred:"informix".sd_movdia
             WHERE folio_suc = pfolio
               AND reversado = 'S';
           
            SELECT fecha_hoy
                INTO vFechaCentralHoy
            FROM bdicred:sd_fechas 
            WHERE empresa = '001';
                
            IF vreversado > 0 THEN
                LET CODIGO_RETORNO = '000';
                LET MENSAJE_RESPUESTA = 'El movimiento ya habia sido reversado';
            ELSE
            
                ---Obtener el centro de costos
                IF ( vNombreCorresponsal = CORRESPONSAL_OXXO ) THEN
                    LET cCondCentroDeCostos = 'ccostos_oxxo'; --20
                ELIF (vNombreCorresponsal = CORRESPONSAL_SEVEN_ELEVEN ) THEN
                    LET cCondCentroDeCostos = 'ccostos_seven'; --20            
                END IF
                
                SELECT TRIM(valor)
                    INTO vCentroCostos
                FROM bdicheq:sc_param
                    WHERE empresa = '001'
                        AND codparam = cCondCentroDeCostos;  
                        
                EXECUTE PROCEDURE bdicred:reversion('001', vCentroCostos, pusuario, pfolio, 'A')
                    INTO CODIGO_RETORNO;
                
                --EL sp de reversion regresa codigo de retorno con 3 digitos.
                --Para la respuesta hacia el autorizador deben entregarse 5 digitos.
                
                IF CODIGO_RETORNO <> '000' THEN
                    IF CODIGO_RETORNO = '431' THEN
                        LET CODIGO_RETORNO = '00431'; --5 digitos de retorno al autorizador
                        LET MENSAJE_RESPUESTA = 'Error|sp_bdicred_reversion';
                    END IF;
                    
                    IF vtransaccion = 1 THEN
                        ROLLBACK WORK;
                        BEGIN WORK;
                    ELSE
                        ROLLBACK WORK;
                    END IF;
                    
                    RETURN CODIGO_RETORNO, vFechaCentralHoy, vSaldoDisp, MENSAJE_RESPUESTA;
                END IF
             END IF
        END IF

        LET CODIGO_RETORNO = "00000";
        
        SELECT FIRST 1 num_credito
            INTO vNumCredito
        FROM bdicred:sd_movdia
            WHERE folio_suc = pfolio;
         
        SELECT (NVL(monto_otorgado,0) - NVL(sdo_cap_insoluto,0) - NVL(sdo_retenido,0)) as saldo_disponible 
            INTO vSaldoDisp
        FROM bdicred:sd_maesdos 
            WHERE num_credito = vNumCredito;
        
        IF vtransaccion = 1 THEN
            COMMIT WORK;
            BEGIN WORK;
        ELSE
            COMMIT WORK;
        END IF;
        
        RETURN CODIGO_RETORNO, vFechaCentralHoy, vSaldoDisp, MENSAJE_RESPUESTA;

    END

END PROCEDURE
DOCUMENT
'Base de datos: bdicorresp_mc',
'Autor: Armando García Ortiz',
' #1',
' Fecha de creacion: 27 de julio del 2018',
'-RQM 10 976 RQM 10 887',
' Implementacion para transaccionar con oxxo y mastercard el reverso del pago de tarjeta de credito.',
' Se agregan validaciones de no permitir transacciones que tienen un producto de cuenta de nomina.',
' Se actualiza el codigo_fun 701 correspondiente al centro de costos y transaccion.',
'#2 ',
'Fecha de modificacion: 26 de febrero del 2021',
'Implementacion de funcionalidad para Corresponsalía con 7Eleven.',
'Se agrega variable de RUTA_ORIGEN'
;