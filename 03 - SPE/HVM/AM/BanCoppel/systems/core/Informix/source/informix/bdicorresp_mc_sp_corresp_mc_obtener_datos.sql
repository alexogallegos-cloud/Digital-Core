CREATE PROCEDURE "informix".sp_corresp_mc_obtener_datos( pNombreCorresponsal VARCHAR(9), pTipoTarjeta CHAR(1) )
    RETURNING 
        CHAR(5) as CODIGO_RETORNO, VARCHAR(80) as MENSAJE_RESPUESTA,
            VARCHAR(25) as rProdNoPermitidos, VARCHAR(10) as rNumeroMaximoUDIS, 
                CHAR(4) as rNumTransaccCorresp, CHAR(7) as rCentroCostos,
                    SMALLINT as rTipoCorresponsal, VARCHAR(4) as rCodigoFun,
                        CHAR(1) as rHabComision, CHAR(1) as rCorresponsalDisponible;
    
    DEFINE SQLERR		INTEGER;
    DEFINE ISAM_ERR		INTEGER;
    DEFINE ERROR_INFO	VARCHAR(80);
    
    DEFINE CODIGO_RETORNO CHAR(5);
    DEFINE MENSAJE_RESPUESTA VARCHAR(80);
    DEFINE RUTA_ORIGEN VARCHAR(100);
    DEFINE TIPO_DEBITO CHAR(1);
    DEFINE TIPO_CREDITO CHAR(1);    
    DEFINE CORRESPONSAL_OXXO CHAR(9);
    DEFINE CORRESPONSAL_SEVEN_ELEVEN CHAR(9);
    
    DEFINE cCondProdNoPermitidos VARCHAR(25);
    DEFINE cCondParamNumMaxUDIS VARCHAR(25);
    DEFINE cCondNumTransaccCorresp VARCHAR(25);
    DEFINE cCondIndicadorServicioCorresp VARCHAR(20);
    DEFINE cCondCentroDeCostos VARCHAR(20);
    DEFINE cCondIDCorresponsalMC VARCHAR(20);
    DEFINE cCondCodigoFun  VARCHAR(20);
    DEFINE cCondHabComision  VARCHAR(20);

    DEFINE vProdNoPermitidos VARCHAR(25);
    DEFINE vNumeroMaximoUDIS SMALLINT;
    DEFINE vNumTransaccCorresp CHAR(4);
    DEFINE vCentroCostos CHAR(4);
    DEFINE vNombreCorresponsal VARCHAR(9);
    DEFINE vValidarCorresponsal CHAR(1);    
    DEFINE vTipoCorresponsal    SMALLINT;
    DEFINE vUdisPermitidas      SMALLINT;
    DEFINE vNombreCorresponsalDisponible  CHAR(1);
    DEFINE vIDCorresponsalMC  VARCHAR(2);
    DEFINE vCodigoFunMC  VARCHAR(4);    
    DEFINE vHabilitarComision CHAR(1);
    
    LET CODIGO_RETORNO = "00000";
    LET MENSAJE_RESPUESTA = '';
    LET RUTA_ORIGEN = '/RESPALDOSNEW/';
    LET TIPO_DEBITO = 'D';
    LET TIPO_CREDITO = 'C';    
    LET CORRESPONSAL_OXXO = 'OXXO';
    LET CORRESPONSAL_SEVEN_ELEVEN = 'SEVEN';
    
    LET vProdNoPermitidos = NULL;
    LET vNumeroMaximoUDIS = NULL;
    LET vNumTransaccCorresp = NULL;
    LET vTipoCorresponsal = '';
    LET vUdisPermitidas   = NULL;
    LET vCentroCostos = NULL;
    LET vNombreCorresponsal = TRIM(pNombreCorresponsal);
    LET vValidarCorresponsal = NULL;
    LET vNombreCorresponsalDisponible  = NULL;
    LET vIDCorresponsalMC  = NULL;
    
    LET cCondIndicadorServicioCorresp = NULL;
    LET cCondIDCorresponsalMC = NULL;    
    LET cCondCodigoFun = '';
    LET cCondHabComision = '';
    LET vCodigoFunMC = '0000';
    LET vHabilitarComision = NULL;
    
    BEGIN

        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
        
            SET DEBUG FILE TO RUTA_ORIGEN || 'excep_sp_obt_datos_corresp_mc_'||LOWER(vNombreCorresponsal)||'.err.out' WITH APPEND;
            TRACE ON;
            
            IF ( SQLERR <> 0 ) THEN
                LET CODIGO_RETORNO = SQLERR;
                LET MENSAJE_RESPUESTA = ERROR_INFO;
                RETURN CODIGO_RETORNO, MENSAJE_RESPUESTA, vProdNoPermitidos, vNumeroMaximoUDIS, vNumTransaccCorresp, vCentroCostos, 
                        vTipoCorresponsal,  vCodigoFunMC, vHabilitarComision, vNombreCorresponsalDisponible;
            END IF;
            
        END EXCEPTION;
        
        --SET DEBUG FILE TO RUTA_ORIGEN||'sp_obtener_datos_corresp_mc_'||LOWER(vNombreCorresponsal)||'.out';
        --TRACE ON;    
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;        
        
        IF ( vNombreCorresponsal = CORRESPONSAL_OXXO AND  pTipoTarjeta = TIPO_DEBITO  ) THEN

            LET cCondProdNoPermitidos = 'prodcorrespchqoxxo'; --18
            LET cCondParamNumMaxUDIS = 'NUMMAX_UDIS_CHQ_OXXO'; --20
            LET cCondNumTransaccCorresp = 'trancorrespchqoxxo'; --18
            LET cCondIndicadorServicioCorresp = 'IND_SERV_DEB_OXXO'; --20
            LET cCondCentroDeCostos = 'ccostos_oxxo'; --20
            LET cCondIDCorresponsalMC = 'NUMCORRESP_OXXO'; --20            
            LET cCondHabComision = 'hab_com_oxxo'; --20

        ELIF ( vNombreCorresponsal = CORRESPONSAL_OXXO AND  pTipoTarjeta = TIPO_CREDITO ) THEN
            
            LET cCondProdNoPermitidos = 'prodcorrespcredoxxo'; --18
            LET cCondParamNumMaxUDIS = 'NUMMAX_UDISCRED_OXXO'; --20
            LET cCondNumTransaccCorresp = 'trancorrespcredoxxo'; --18
            LET cCondIndicadorServicioCorresp = 'IND_SERV_CRED_OXXO'; --20
            LET cCondCentroDeCostos = 'ccostos_oxxo'; --20
            LET cCondIDCorresponsalMC = 'NUMCORRESP_OXXO'; --20
            LET cCondCodigoFun = 'codfun_oxxo';            

        ELIF (vNombreCorresponsal = CORRESPONSAL_SEVEN_ELEVEN AND  pTipoTarjeta = TIPO_DEBITO  ) THEN

            LET cCondProdNoPermitidos = 'prodcorreschqseven'; --18
            LET cCondParamNumMaxUDIS = 'NUMMAX_UDISCHQ_SEVEN'; --20
            LET cCondNumTransaccCorresp = 'trancorrespchqseven'; --18
            LET cCondIndicadorServicioCorresp = 'IND_SERV_DEB_SEVEN'; --20
            LET cCondCentroDeCostos = 'ccostos_seven'; --20
            LET cCondIDCorresponsalMC = 'NUMCORRESP_SEVEN'; --20
            LET cCondHabComision = 'hab_com_seven'; --20
            
        ELIF (vNombreCorresponsal = CORRESPONSAL_SEVEN_ELEVEN AND  pTipoTarjeta = TIPO_CREDITO  ) THEN
            
            LET cCondProdNoPermitidos = 'prodcorrescredseven'; --18
            LET cCondParamNumMaxUDIS = 'NUMMAX_UDISCRD_SEVEN'; --20
            LET cCondNumTransaccCorresp = 'trancorrespcredseven'; --18
            LET cCondIndicadorServicioCorresp = 'IND_SERV_CRED_SEVEN'; --20
            LET cCondCentroDeCostos = 'ccostos_seven'; --20
            LET cCondIDCorresponsalMC = 'NUMCORRESP_SEVEN'; --20
            LET cCondCodigoFun = 'codfun_seven';
            
        END IF

        --solo en credito
        IF ( pTipoTarjeta = TIPO_CREDITO ) THEN
            SELECT valor
                INTO vCodigoFunMC
                FROM bdicheq:sc_param 
            WHERE codparam = cCondCodigoFun;
        END IF            
            
        ---Identificador del corresponsal
        SELECT valor
            INTO vIDCorresponsalMC 
        FROM bdicheq:sc_param_corresp
            WHERE codparam = cCondIDCorresponsalMC
        AND empresa = '001';        

        ---Disponibilidad del corresponsal
        SELECT valor
            INTO vValidarCorresponsal 
        FROM bdicheq:sc_param_corresp
            --WHERE codparam = 'prodcorrespchqoxxo'  ----CHAR(20)
            WHERE codparam = cCondIndicadorServicioCorresp
        AND empresa = '001';
        
        IF (vIDCorresponsalMC IS NULL OR vIDCorresponsalMC = '') OR        
            (vValidarCorresponsal IS NULL OR vValidarCorresponsal = '' OR vValidarCorresponsal = '0') THEN        
            LET vNombreCorresponsalDisponible = vValidarCorresponsal;
            
            LET CODIGO_RETORNO = '08007';
            LET MENSAJE_RESPUESTA = 'Corresponsal inactivo ' || vNombreCorresponsal ||' '||pTipoTarjeta;          
            RETURN CODIGO_RETORNO, MENSAJE_RESPUESTA, vProdNoPermitidos, vNumeroMaximoUDIS, vNumTransaccCorresp, vCentroCostos, 
                vTipoCorresponsal,  vCodigoFunMC, vHabilitarComision, vNombreCorresponsalDisponible;
        END IF
        
        ---Asignacion de los valores del corresponsal.
        LET vNombreCorresponsalDisponible = vValidarCorresponsal;
        LET vTipoCorresponsal = vIDCorresponsalMC;        
        
        SELECT valor
            INTO vProdNoPermitidos 
        FROM bdicheq:sc_param
            --WHERE codparam = 'prodcorrespchqoxxo'  ----CHAR(20)
            WHERE codparam = cCondProdNoPermitidos
        AND empresa = '001';
        
        -- // OBTIENE EL VALOR MAXIMO DE UDIS PARA CAPTACION
        SELECT valor
            INTO vNumeroMaximoUDIS
        FROM bdicheq:sc_param_corresp
            --WHERE codparam = 'NUMMAX_UDIS_CHQ_OXXO' ------CHAR(20),
            WHERE codparam = cCondParamNumMaxUDIS
        AND empresa = '001';        
        
        -- // OBTIENE NUMERO DE TRANSACCION
        SELECT TRIM(valor) 
            INTO vNumTransaccCorresp
        FROM bdicheq:sc_param
            WHERE empresa = '001'
            AND codparam = cCondNumTransaccCorresp; 
            --AND codparam = "trancorrespchqoxxo"; ---------CHAR(20)
        
        ---Obtener el centro de costos
        SELECT TRIM(valor)
            INTO vCentroCostos
        FROM bdicheq:sc_param
            WHERE empresa = '001'
                AND codparam = cCondCentroDeCostos;
        
        LET vHabilitarComision = 'N';
        IF ( pTipoTarjeta = TIPO_DEBITO ) THEN
        
            SELECT TRIM(valor)
                INTO vHabilitarComision
            FROM bdicheq:sc_param
                WHERE empresa = '001'
                    AND codparam = cCondHabComision;
        END IF

        IF (vProdNoPermitidos IS NULL OR vProdNoPermitidos = '') OR
           (vNumeroMaximoUDIS IS NULL OR vNumeroMaximoUDIS = '') OR
           (vNumTransaccCorresp IS NULL OR vNumTransaccCorresp = '') OR
           (vNombreCorresponsalDisponible IS NULL OR vNombreCorresponsalDisponible = '0') OR
           (vCentroCostos IS NULL OR LENGTH(vCentroCostos) <> 4) OR
           (vHabilitarComision IS NULL) THEN
        
            LET CODIGO_RETORNO = '08000';
            LET MENSAJE_RESPUESTA = 'Faltan Parametros Corresponsal ' ||vNombreCorresponsal ||' '||pTipoTarjeta;
            
            RETURN CODIGO_RETORNO, MENSAJE_RESPUESTA, vProdNoPermitidos, vNumeroMaximoUDIS, vNumTransaccCorresp, vCentroCostos, 
                    vTipoCorresponsal,  vCodigoFunMC, vHabilitarComision, vNombreCorresponsalDisponible;
        
        END IF        

        LET MENSAJE_RESPUESTA = 'Ejecucion exitosa '||vNombreCorresponsal||' '||pTipoTarjeta;
        
        RETURN CODIGO_RETORNO, MENSAJE_RESPUESTA, vProdNoPermitidos, vNumeroMaximoUDIS, vNumTransaccCorresp, vCentroCostos, 
                vTipoCorresponsal,  vCodigoFunMC, vHabilitarComision, vNombreCorresponsalDisponible;
        
    END
    
END PROCEDURE
DOCUMENT
'Base de datos: bdicorresp_mc',
' Proyecto: Transaccionalidad con corresponsalía con OXXO y 7Eleven mediante Mastercard (MIP)',
' Fecha de creacion: 20 de enero del 2021',
' Fecha de actualizacion: 26 de febrero del 2021',
' Descripcion: Consultar las tablas que tiene registrados los parámetros por cada corresponsal',
' y se regresan como datos de entrada para los depósitos y pagos de tarjeta de crédito',
' EXECUTE PROCEDURE "informix".sp_corresp_mc_obtener_datos("OXXO", "D"); ',
' EXECUTE PROCEDURE "informix".sp_corresp_mc_obtener_datos("OXXO", "C"); ', 
' EXECUTE PROCEDURE "informix".sp_corresp_mc_obtener_datos("SEVEN", "D"); ',
' EXECUTE PROCEDURE "informix".sp_corresp_mc_obtener_datos("SEVEN", "C"); '
;