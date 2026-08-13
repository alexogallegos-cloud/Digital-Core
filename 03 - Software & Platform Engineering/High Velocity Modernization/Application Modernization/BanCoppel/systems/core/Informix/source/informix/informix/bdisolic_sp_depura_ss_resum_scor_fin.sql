CREATE PROCEDURE "informix".sp_depura_ss_resum_scor_fin()
RETURNING 
CHAR(5) AS cCodRet ,
CHAR(100) AS cMensajeREt;


DEFINE cCodRet		CHAR(5);
DEFINE cMensajeREt	CHAR(100);
DEFINE cSql         CHAR(6000);
DEFINE iSqlErr      INTEGER;
DEFINE Cnumcredito		CHAR(20);
DEFINE Cnumcretmp		CHAR(20);
DEFINE Clugar_nac	CHAR(2);
DEFINE Clugar_nac_new CHAR(2);


LET cCodRet ='00000';
LET cMensajeREt ='Proceso Exitoso';
LET iSqlErr = 0;
LET cSql = '';
LET Cnumcredito	='';
LET Cnumcretmp ='';

--SET DEBUG FILE TO "/informix/c92962301/eje_dep_resum.out";
--TRACE ON;
BEGIN

ON EXCEPTION SET iSqlErr
				IF iSqlErr !=0 THEN
					 LET cCodRet = iSqlErr;
					 LET cMensajeRet = "Ocurrio un Error";
					  RETURN cCodRet,cMensajeRet;
				END IF;
			END EXCEPTION;
				

SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
					
		--Se optiene el numero de cliente de la tabla pivote
		SELECT num_credito INTO Cnumcretmp FROM bdicred:"informix".sd_param_movhis_dep WHERE proceso ='6';
				
	
	FOREACH  WITH HOLD
	

		SELECT a.num_solicitud 
		INTO Cnumcredito
		FROM bdisolic:ss_resum_scor_fin a
		INNER JOIN bdisolic:ss_solicitudes b ON a.num_solicitud = b.num_solicitud
		LEFT JOIN bdicred:sd_maecred c ON a.num_solicitud = c.num_credito
		LEFT JOIN bdicred:sd_maecredcrd d ON a.num_solicitud = d.num_credito
		WHERE a.empresa ='001'
		AND b.fecha_insert <='12-31-2014'
		AND c.num_credito IS NULL
		AND d.num_credito IS NULL
		AND a.num_solicitud > Cnumcretmp
		ORDER BY a.num_solicitud ASC																														
																														

 
 
		BEGIN;	
		--Se elimina el registro de la tabla ss_resum_scor_fin 
		DELETE FROM  bdisolic:ss_resum_scor_fin where num_solicitud = Cnumcredito;
		
		--Se actualiza el dato en la tabla pivote 
		UPDATE  bdicred:"informix".sd_param_movhis_dep SET num_credito = Cnumcredito WHERE proceso ='6';
		
		COMMIT;
 
 
	END FOREACH;	

			
			RETURN cCodRet,cMensajeRet;
				
END;
END PROCEDURE

;