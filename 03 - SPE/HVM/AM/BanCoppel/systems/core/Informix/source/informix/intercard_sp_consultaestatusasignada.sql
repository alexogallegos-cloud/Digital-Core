CREATE PROCEDURE "informix".sp_consultaestatusasignada(pEmpresa CHAR(3),pTarjeta CHAR(20))
							 RETURNING CHAR(5) AS codigo_retorno, CHAR(3) AS estatus_tar;
							 
DEFINE  iSqlerr  INTEGER;
DEFINE  cCodret  CHAR(5);
DEFINE  cEstatus CHAR(3);
DEFINE  ctarjeta char(20);

LET     iSqlerr = 0;                    
LET 	cCodret = "00000";                     
LET 	cEstatus = "";                     
LET     ctarjeta="";

 --SET DEBUG FILE TO "/tmp/sp_consultaestatusasignada.out";
 --TRACE ON;


	BEGIN
		ON EXCEPTION SET iSqlerr
				IF iSqlerr <> 0  THEN
						LET cCodret = iSqlerr;
						RETURN cCodret, cEstatus; 
				END IF;
				
		END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	
	Let ctarjeta=TRIM(pTarjeta);
	
	IF TRIM(NVL(pTarjeta,"")) <> "" THEN

		SELECT  NVL(codstatusasignada,"")
		INTO cEstatus
		FROM "informix".tarjeta
		WHERE numtarjeta =ctarjeta;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN  
			LET cCodret = "00002"; --TARJETA NO EXISTE
		end if;
	ELSE
		LET cCodret = "00001"; --PARAMETRO DE ENTRADA VACIO
	END IF;
	
	RETURN cCodret, cEstatus;

	END;

END PROCEDURE;