CREATE PROCEDURE "informix".sp_registrabitacora_ppc
(
   pSucursal CHAR(4),
   pNumCte CHAR(20),
   pEjecutivo CHAR(20),
   pNumCteCoppel CHAR(20),
   pEnvio CHAR(5000),
   pRespuesta CHAR(5000),
   pId CHAR(20),
   pFecha CHAR(21),
   pOpcion CHAR(1)
 )
RETURNING CHAR(6) AS CodRet;
		  

DEFINE	cCodRet CHAR(6);
DEFINE	iSql_err INTEGER;
DEFINE  cFechaInsert CHAR(19);


LET cCodRet = '000000';
LET iSql_err = 0;
LET cFechaInsert = '';

BEGIN

    ON EXCEPTION SET iSql_err
        IF iSql_err <> 0 THEN
            LET cCodRet = iSql_err;
           RETURN cCodRet;
        END IF;

    END EXCEPTION;

   
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	     IF pOpcion='1' THEN
	
			IF NVL(pNumCte,'') <> '' AND NVL(pEnvio,'') <> '' THEN
			
				LET cFechaInsert = CURRENT YEAR TO SECOND;
				LET cFechaInsert= TRIM(cFechaInsert);
				Insert into bitacora_pcc(sucursal, numcte, numcte_coppel, ejecutivo, envio, fecha, respuesta, id)
								  values(pSucursal, pNumCte, pNumCteCoppel, pEjecutivo, pEnvio,cFechaInsert,pRespuesta, pId);
			ELSE
				LET cCodRet = '000001'; 
			END IF;	 
		
		ELSE
		       IF pOpcion='2' THEN
			   
			     LET pFecha=trim(pFecha);
		   
				 UPDATE bitacora_pcc SET respuesta = pRespuesta WHERE sucursal= pSucursal and  numcte =pNumCte and ejecutivo= pEjecutivo and id= pId and date(fecha)= pFecha;
				 
			   END IF
		END IF
	
	
	RETURN cCodRet;
END;
END PROCEDURE
;