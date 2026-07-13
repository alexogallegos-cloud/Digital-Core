CREATE PROCEDURE "informix".sp_obtienetarjtaslote(Lotet CHAR(11))
   RETURNING CHAR(5),  CHAR(6), CHAR(16), CHAR(16);
      
   DEFINE cCodRet             CHAR(5);
   DEFINE iSqlErr             INTEGER;
   DEFINE cNoLote              CHAR(6);
   DEFINE cTarjetaIni          CHAR(16);
   DEFINE cTarjetaFin          CHAR(16);
     
   LET cCodRet        ='00000';   
   LET cNoLote		  ='000000';
   LET cTarjetaIni	  ='0000000000000000';
   LET cTarjetaFin    ='0000000000000000';
         
BEGIN
                  ON EXCEPTION SET iSqlErr
                      IF iSqlErr <> 0 THEN
                         LET cCodRet = iSqlErr;
                                                               
                         RETURN cCodRet, cNoLote, cTarjetaIni, cTarjetaFin;
                      END IF;
                  END EXCEPTION;
                
                SET LOCK MODE TO WAIT 3;
                SET ISOLATION TO DIRTY READ;

         FOREACH
		   SELECT first 1 numlote, numtarjeta INTO cNoLote, cTarjetaIni
		   FROM intercard:detalle_maquila
		   WHERE numlote = Lotet
		   ORDER BY numtarjeta ASC                                      
        
            FOREACH
               SELECT first 1 numtarjeta  INTO cTarjetaFin
               FROM intercard:detalle_maquila
               WHERE numlote = Lotet
               ORDER BY numtarjeta DESC
               
            END FOREACH

		END FOREACH  

           IF cTarjetaIni IS NULL or cTarjetaFin IS NULL THEN
              LET  cCodRet = '00001';
           END IF;

           RETURN cCodRet, cNoLote, cTarjetaIni, cTarjetaFin;

END;
END PROCEDURE

;