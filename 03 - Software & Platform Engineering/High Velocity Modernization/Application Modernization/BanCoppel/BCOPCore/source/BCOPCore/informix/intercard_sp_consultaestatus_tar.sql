CREATE PROCEDURE "informix".sp_consultaestatus_tar(pEmpresa CHAR(3),pTarjeta CHAR(20))
							 RETURNING CHAR(5) AS codigo_retorno, CHAR(3) AS estatus_tar;
							 
DEFINE  iSqlerr  INTEGER;
DEFINE  cCodret  CHAR(5);
DEFINE  cEstatus CHAR(3);

LET     iSqlerr = 0;                    
LET 	cCodret = "00000";                     
LET 	cEstatus = "";                     


 --SET DEBUG FILE TO "/respaldosbd/mireya/sp_consultaestatus_tar.out";
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
	
	IF TRIM(NVL(pTarjeta,"")) <> "" THEN

		SELECT  NVL(codstatustarjeta,"")
		INTO cEstatus
		FROM "informix".tarjeta
		WHERE numtarjeta = TRIM(pTarjeta);
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN  
			LET cCodret = "00002"; --TARJETA NO EXISTE
		end if;
	ELSE
		LET cCodret = "00001"; --PARAMETRO DE ENTRADA VACIO
	END IF;
	
	RETURN cCodret, cEstatus;

	END;

END PROCEDURE;