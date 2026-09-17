CREATE PROCEDURE "informix".sp_insert_bitacorappmas ( pNumcteCoppel CHAR (20), pNumClienteBanco CHAR (20),  pMostroMensaje INTEGER, pAceptoMensaje INTEGER   )
RETURNING
    CHAR(6) AS cCodRet;

    --DEFINICION DE VARIABLES DE ERROR
    DEFINE iSqlErr         INTEGER;
    DEFINE iIsamErr        INTEGER;
    DEFINE cCodRet         CHAR(6);
    DEFINE cConteoCliente  INTEGER;

    --DECLARACION DE VARIABLES DE ERROR
    LET iSqlErr  = 0;
    LET iIsamErr = 0;
    LET cCodRet  ="000000";
    LET cConteoCliente = 0;

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          RETURN cCodRet;
       END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    --SET debug file to '/home/sysifx/OscarOjeda/sp_insert_bitacorappmas.out';
    --TRACE ON; 

    IF NVL(pNumClienteBanco,"") = ""  THEN
          LET cCodRet = "000001"; -- Parametros de entrada insuficiontes
    ELSE

        -- Cuenta si existe algun registro previo condicionando cliente coppel y cliente banco
        SELECT  COUNT(*)
        INTO    cConteoCliente
        FROM    bdisolic:"informix".bitacorappmas
        WHERE   numcte_coppel = pNumcteCoppel
        AND     numcte_banco = pNumClienteBanco;

        -- Si existe, realiza actualizacion del registro en la bitacora.
        IF cConteoCliente > 0 THEN

            UPDATE  bdisolic:"informix".bitacorappmas
            SET     mostro_mensaje = pMostroMensaje,
                    acepto_mensaje = pAceptoMensaje,
                    fecha_update = CURRENT YEAR TO SECOND
            WHERE   numcte_coppel = pNumcteCoppel
            AND     numcte_banco = pNumClienteBanco;
        
        ELSE
        -- Si no existe, inserta el registro en la bitacora.
            INSERT INTO  bdisolic:"informix".bitacorappmas (numcte_coppel, numcte_banco, mostro_mensaje, acepto_mensaje, fecha_mensaje)
            VALUES  (pNumcteCoppel , pNumClienteBanco, pMostroMensaje , pAceptoMensaje, current );
        END IF;

    END IF;    

    RETURN cCodRet; 
END
END PROCEDURE
