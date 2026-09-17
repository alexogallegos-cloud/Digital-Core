CREATE PROCEDURE "informix".sp_reg_preg_bex(pNumCte char(20) ,pNumTel  char(20), pPreg integer, pResp varchar(200))

RETURNING 	INTEGER, INTEGER;
--DEFINICION DE VARIABLES
DEFINE iSqlErr 		INTEGER;
DEFINE vSesion 		varchar(5);
DEFINE vEncuentado 	INTEGER;
DEFINE desPreg 		VARCHAR(200);
DEFINE iCont		INTEGER;
DEFINE iCont1		INTEGER;
DEFINE iSesion		INTEGER;

--INICIALIZACION DE VARIABLES
LET iSqlErr 	 = 0;
LET vSesion 	 = '00000';
LET vEncuentado	 = 0;	
LET desPreg 	 = " ";
LET iCont 		 = 0;
LET iCont1 		 = 0;
LET iSesion		 = 0;	


--SET DEBUG FILE TO '/informix/ireb/bdibpi/sp_reg_preg_bex.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET vSesion = iSqlErr;			
			RETURN vSesion, vEncuentado;
		END IF;
	END EXCEPTION;	

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	SELECT COUNT(estatus) INTO iCont1 FROM bpi_cat_encuenta_bex WHERE estatus=1; --OBTIENE EL NUMERO DE PREGUNTAS
	
	SELECT COUNT (num_cte) INTO iCont FROM bpi_reg_encuesta_bex where num_cte=pNumCte and num_tel=pNumTel; --OBTIENE EL NUMERO DE REGISTRO
	
	SELECT encuestado INTO vEncuentado FROM bpi_reg_usuarioencuestados_bex where num_cte=pNumCte and num_tel=pNumTel; --VERIFICA QUE YA NO ESTE ENCUENTADO
	
	IF vEncuentado = 0 THEN 
		INSERT INTO bpi_reg_encuesta_bex(num_cte, num_tel, id_preg, respuesta, fecha, estatus   ) VALUES(pNumCte,pNumTel,pPreg,pResp,current ,'1');
				
		IF iCont>=iCont1-2 THEN 
			UPDATE bpi_reg_usuarioencuestados_bex SET  encuestado=1 WHERE num_cte=pNumCte and num_tel=pNumTel;
		END IF
	END IF	
	
RETURN vSesion, vEncuentado;
END;
END PROCEDURE;