CREATE PROCEDURE "informix".sp_interpreta_respuesta_bc(pempresa char(03), pFechaHoyAumlincred date)
RETURNING CHAR(6)  AS Codigo_Retorno,
          CHAR(80) AS Mensaje_Retorno; 

DEFINE pInstitucion     CHAR(2);
DEFINE pnum_cliente     CHAR(20);
DEFINE pnum_solicitud   varchar(20);
DEFINE itamamax         INTEGER;
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(100);
DEFINE cCodRet          CHAR(6);
DEFINE cMensajeRet    	CHAR(80);
DEFINE error            CHAR(6); 
DEFINE Mensaje          CHAR(80);
DEFINE solicitud        CHAR(20);
DEFINE t_procesados     INTEGER;
DEFINE t_rechazos       INTEGER;
DEFINE t_registros      INTEGER;
DEFINE sql_err          INTEGER;

--define pFechaHoy date;
LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
let pnum_cliente    = "";
LET itamamax        = 0;
LET cMensajeRet     = "";
LET t_procesados    = 0;
LET t_rechazos      = 0;
LET t_registros     = 0;

--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
SET ISOLATION COMMITTED READ;


BEGIN
--Errores no controlados.
ON EXCEPTION SET iSqlErr, iIsamErr , cErrorInfo
    LET cCodRet= iSqlErr;
    LET cMensajeRet= cErrorInfo;  
    RETURN cCodRet, cMensajeRet;
END EXCEPTION;

--set debug file to 'sp_interresp_bc_univ.out';
--trace on;

SELECT institucion,numcte, num_solicitud,length(regreso) AS tamamax
FROM bdiburo:br_respuesta_bc
WHERE fecha_insert =pFechaHoyAumlincred                                              
AND numcte IS NOT NULL
--and num_solicitud in ( '600007644997','600060006365','600066347128','600038388671')
INTO TEMP univ_sols WITH NO LOG;

FOREACH WITH HOLD

    SELECT institucion,numcte, num_solicitud,tamamax
      INTO pInstitucion,pnum_cliente,pnum_solicitud,itamamax
      FROM univ_sols

    LET t_registros = t_registros +1;

    EXECUTE PROCEDURE bdiburo:"informix".sp_procesa_resp_bc(pFechaHoyAumlincred,pnum_solicitud,pInstitucion,pnum_cliente,itamamax)  INTO  error, solicitud;

    IF error <> '000000' THEN
        INSERT INTO br_respuesta_inconsis_bc VALUES (solicitud,t_registros,error,pFechaHoyAumlincred);
        LET t_rechazos = t_rechazos +1;
    ELSE
        LET t_procesados = t_procesados +1;
    END IF
END FOREACH;

LET cCodRet = '000000';
LET cMensajeRet = 'Registros procesados: '|| t_procesados ||' Registros rechazados: '||t_rechazos  ;
RETURN cCodRet, cMensajeRet ;
END;
end procedure
;