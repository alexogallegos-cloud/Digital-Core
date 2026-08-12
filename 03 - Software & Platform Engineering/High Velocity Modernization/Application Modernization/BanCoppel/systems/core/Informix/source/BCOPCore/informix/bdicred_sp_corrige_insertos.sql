CREATE PROCEDURE "informix".sp_corrige_insertos(pEmpresa CHAR(3))
RETURNING 
          CHAR(5) AS resultado,
          CHAR(80) AS mensaje;

    DEFINE iSqlErr      	     INTEGER;
    DEFINE iIsamErr              INTEGER;
    DEFINE cErrorInfo            CHAR(80);
    DEFINE cCodRet               CHAR(5); 
    DEFINE cMensajeRet           CHAR(80);
    DEFINE cNumCredito           CHAR(20);
    DEFINE cInsertoNuevo         CHAR(15);
    DEFINE cFechaEmision         DATE;
    DEFINE cPosicion             CHAR(2);

    BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet= iSqlErr;
          LET cMensajeRet= cErrorInfo;
        RETURN cCodRet,cMensajeRet;
       END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "sp_corrige_insertos";
    --TRACE ON;
    LET iSqlErr=0;
    LET iIsamErr=0;
    LET cErrorInfo="";
    LET cCodRet= '00000';
    LET cMensajeRet= 'Se realizó la consulta correctamente';
    LET cNumCredito="";
    LET cInsertoNuevo='000000000000000';
    LET cFechaEmision=MDY('05','20','2009');
    LET cPosicion="";

    FOREACH
        SELECT num_credito,posicion
          INTO cNumCredito,cPosicion
          FROM bdicred:sd_marcaje 
         WHERE empresa=pEmpresa
           AND fecha_emision=date(0)

        IF cPosicion = '10' THEN
            LET cInsertoNuevo = '100000000000000';
        ELIF cPosicion = '00' THEN 
            LET cInsertoNuevo = '000100000000000';
        END IF;

        UPDATE bdicred:sd_marcaje
        SET fecha_emision=cFechaEmision,
            posicion=0,
            insertos=cInsertoNuevo
        WHERE empresa=pEmpresa
          AND num_credito=cNumCredito
          AND fecha_emision=date(0);

        UPDATE bdicred:sd_encabezado_edocta
        SET insertos=cInsertoNuevo
        WHERE num_credito=cNumCredito
          AND fecha_emision=cFechaEmision;
    END FOREACH;
  RETURN cCodRet,cMensajeRet;

END
END PROCEDURE;