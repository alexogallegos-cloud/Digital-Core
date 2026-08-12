CREATE PROCEDURE "informix".sp_corresp_reverso_deposito_mc( pNombreCorresponsal VARCHAR(9), pusuario char(8), pfolio char(16) )
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
    DEFINE vCuenta CHAR(13);    
    DEFINE vCentroCostos CHAR(4);
    DEFINE cCondCentroDeCostos VARCHAR(20);
    DEFINE CORRESPONSAL_OXXO CHAR(9);
    DEFINE CORRESPONSAL_SEVEN_ELEVEN CHAR(9);
    --RQM 09 704. Se agregan las variables para el retorno de consulta de saldo. EEAP.
    DEFINE cCodRetConsSdo		CHAR(5); --Codigo de retorno de SP de consulta de saldo.
    DEFINE cMensajeRetConsSdo 	CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
    
    LET sql_err = 0;
    LET isam_err = 0;
    LET CODIGO_RETORNO = "00000";
    LET cod_ret2 = "000";
    LET vtransaccion = 0;
    LET vreversado = 0;
    LET vFechaCentralHoy = '';
    LET MENSAJE_RESPUESTA = 'Ejecucion exitosa';
    LET vSaldoDisp = 0.00;
    LET vCuenta = '';    
    LET vCentroCostos = NULL;
    LET cCondCentroDeCostos = '';
    LET RUTA_ORIGEN   = '/RESPALDOSNEW/';
    LET CORRESPONSAL_OXXO = 'OXXO';
    LET CORRESPONSAL_SEVEN_ELEVEN = 'SEVEN';
    --RQM 09 704. Se inicializan las variables para el retorno de consulta de saldo. EEAP.
    LET cCodRetConsSdo		= '00000';
    LET cMensajeRetConsSdo	= '';
    
    
    BEGIN
    
        ON EXCEPTION SET sql_err, isam_err
            IF (sql_err <> 0) THEN
                SET DEBUG FILE TO RUTA_ORIGEN||'excepcion_reverso_deposito_mc'||LOWER(TRIM(pNombreCorresponsal))||'.out' WITH APPEND;
                TRACE ON;
                LET CODIGO_RETORNO = sql_err;
                LET cod_ret2 = isam_err;
                LET MENSAJE_RESPUESTA = 'Error | Excepcion';
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
    
        --SET DEBUG FILE TO RUTA_ORIGEN||'ejec_sp_corresp_reverso_deposito_mc'||LOWER(TRIM(pNombreCorresponsal))||'.out';
        --TRACE ON;
        
        IF (vtransaccion = 1) THEN
            COMMIT WORK;
            BEGIN WORK;
        ELSE
            BEGIN WORK;
        END IF;
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

    
        LET pNombreCorresponsal = TRIM(pNombreCorresponsal);
        
        IF (  ( pNombreCorresponsal IS NULL OR pNombreCorresponsal = '') OR 
           (pusuario is null OR pusuario = '' OR LENGTH(pusuario) <> 8) OR
           (pfolio is null OR pfolio = '' OR LENGTH(pfolio) < 15 ) ) THEN
            
            LET CODIGO_RETORNO = '00010';
            LET MENSAJE_RESPUESTA = 'Parametros incorrectos.';
            IF (vtransaccion = 1) THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            
            RETURN CODIGO_RETORNO, vFechaCentralHoy, vSaldoDisp, MENSAJE_RESPUESTA;
        ELSE
            SELECT COUNT(*)
              INTO vreversado
              FROM bdicheq:"informix".sc_movdia
             WHERE cancelad = 'S'
               AND folio_suc = pfolio;
               
           SELECT fecha_hoy
                INTO vFechaCentralHoy
            FROM bdicheq:sc_fechas 
            WHERE empresa = '001';

               -- Ya fue reversado el movimiento.
            IF vreversado > 0 THEN
                LET CODIGO_RETORNO = '00000';
                LET MENSAJE_RESPUESTA = 'El movimiento ya habia sido reversado';
            ELSE
                         
                
            IF ( pNombreCorresponsal = CORRESPONSAL_OXXO ) THEN
                LET cCondCentroDeCostos = 'ccostos_oxxo'; --20                
            ELIF (pNombreCorresponsal = CORRESPONSAL_SEVEN_ELEVEN ) THEN
                LET cCondCentroDeCostos = 'ccostos_seven'; --20            
            ELSE
                    LET CODIGO_RETORNO = '00020';
                    LET MENSAJE_RESPUESTA = 'Corresponsal incorrecto.';
                    IF (vtransaccion = 1) THEN
                        ROLLBACK WORK;
                        BEGIN WORK;
                    ELSE
                        ROLLBACK WORK;
                    END IF;
            
                    RETURN CODIGO_RETORNO, vFechaCentralHoy, vSaldoDisp, MENSAJE_RESPUESTA;
            
            END IF

                
                SELECT TRIM(valor)
                    INTO vCentroCostos
                FROM bdicheq:sc_param
                    WHERE empresa = '001'
                        AND codparam = cCondCentroDeCostos;            
                
                EXECUTE PROCEDURE bdicheq:"informix".reversion('001', vCentroCostos, pusuario, pfolio, 'A')
                    INTO CODIGO_RETORNO;
                --EL sp de reversion regresa codigo de retorno con 3 digitos.
                --Para la respuesta hacia el autorizador deben entregarse 5 digitos.
                IF (CODIGO_RETORNO <> '000') THEN
                    IF CODIGO_RETORNO = '00413' THEN
                        LET CODIGO_RETORNO = '00413';
                        LET MENSAJE_RESPUESTA = 'Error| sp_reversion';
                    END IF;
                    
                    IF vtransaccion = 1 THEN
                        ROLLBACK WORK;
                        BEGIN WORK;
                    ELSE
                        ROLLBACK WORK;
                    END IF;
                    
                    RETURN CODIGO_RETORNO, vFechaCentralHoy, vSaldoDisp, MENSAJE_RESPUESTA;
                END IF;
            END IF;
        END IF;
    
        SELECT FIRST 1 cuenta
              INTO vCuenta
          FROM bdicheq:"informix".sc_movdia
         WHERE folio_suc = pfolio;
               
        --RQM 09 704. Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion. EEAP
    	EXECUTE PROCEDURE bdicheq:sp_cons_sdodisp_x_tpcalculo(vCuenta, null, null, null, null, null, null, null, 'T', 2) 
    	INTO cCodRetConsSdo,cMensajeRetConsSdo,vSaldoDisp;
          
        LET CODIGO_RETORNO = '00000';
        
        IF vtransaccion = 1 THEN
            COMMIT WORK;
            BEGIN WORK;
        ELSE
            COMMIT WORK; 
        END IF;
        
        RETURN CODIGO_RETORNO, vFechaCentralHoy, vSaldoDisp, MENSAJE_RESPUESTA;

    END

END PROCEDURE
---Base de datos: bdicorresp_mc
---Autor: Armando Garcia Ortiz
--- #1
--- Fecha de creacion: 27 de julio del 2018
--- RQM 10 976 RQM 10 887
--- Implementacion para transaccionar con oxxo y mastercard el reverso de deposito a cuenta en efectivo.
--- Se agregan validaciones de no permitir transacciones que tienen un producto de cuenta de nomina.
---#2 --- Fecha de modificacion: 26 de fenbrero del 2021
---Implementacion de funcionalidad para Corresponsalia con 7Eleven.
---Se agrega variable de RUTA_ORIGEN
---
---'FECHA : 15-07-2025',
---'MODIFICACION : Se modifica la formula del calculo de saldo disponible para agregar',
---'               en su lugar la ejecucion de un SPL que realiza el calculo de forma interna',
---'               eviando como parametros la cuenta del cliente y el tipo de calculo a realizar',
---'PROYECTO : RQM 09 704 Cobranza Automatica en cuentas de captacion',
---'BD    : bdicorresp_mc',
---'VER   : 1.2';;