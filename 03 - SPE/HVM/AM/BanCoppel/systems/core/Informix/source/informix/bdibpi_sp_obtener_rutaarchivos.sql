CREATE PROCEDURE "informix".sp_obtener_rutaarchivos()
	RETURNING CHAR(5),CHAR(50),CHAR(50),CHAR(50),CHAR(50),CHAR(50),CHAR(50);
	--*******************************************
	--sp_obtener_rutaArchivos
	--Objetivo: Obtiene de la tkn_patramtreos los valores de la rutas de la donde se encuentran los archivos
	--Autor: Francisco Rodriguez Ibarra
	--Fecha: 05 Enero 2010
	--*********************************************
	--Modificación: Se modifica para poder obtener los comentarios.
	--Autor: Walber Castro
	--Fecha: 01 Febrero 2012
	--*********************************************
	--Declaracion de variables
	DEFINE vsCodRet  		CHAR(5);
	DEFINE vParam			CHAR(3);
	DEFINE vValor			CHAR(50);
	DEFINE vAProcesar   	CHAR(50);
	DEFINE vProcesados		CHAR(50);
	DEFINE vComentarios		CHAR(50);
	DEFINE vRutaProcesar    CHAR(50);
	DEFINE vRutaProcesados	CHAR(50);
	DEFINE vRutaComentarios	CHAR(50);
	DEFINE vSqlErr 		 INTEGER;
	
	--Asignacion de Valores a Variables
	LET vsCodRet='00000';
	LET vSqlErr = 0;
	LET vValor='';
	LET vParam='';
	LET vAProcesar='';
	LET vProcesados='';
	LET vComentarios='';
	LET vRutaProcesar='';
	LET vRutaProcesados='';
	LET vRutaComentarios='';
	
	SET LOCK MODE TO WAIT 10;
	
	BEGIN
	
		ON EXCEPTION SET vSqlErr
	      IF vSqlErr <> 0 THEN
	            let vsCodRet = vSqlErr;
				--ROLLBACK WORK;
				RETURN vsCodRet,vAProcesar,vProcesados,vRutaProcesar,vRutaProcesados,vComentarios,vRutaComentarios;
				
	    END IF;
		END EXCEPTION;
		
		FOREACH
			SELECT id_param,valor 
			INTO vParam,vValor
			FROM bdibpi:"informix".tkn_parametros
			WHERE id_param='13'  OR id_param='14' OR id_param='24' OR id_param='25' OR id_param='53' OR id_param='54'
			IF (vParam=='13') THEN
				LET vAProcesar=vValor;
			END IF
			IF (vParam=='14') THEN
				LET vProcesados=vValor;
			END IF
			IF (vParam=='24') THEN
				LET vRutaProcesar=vValor;
			END IF
			IF (vParam=='25') THEN
				LET vRutaProcesados=vValor;
			END IF
			IF (vParam=='53') THEN
				LET vComentarios=vValor;
			END IF
			IF (vParam=='54') THEN
				LET vRutaComentarios=vValor;
			END IF
			
		END FOREACH;
		IF (vAProcesar IS NULL OR vAProcesar='') THEN
			LET vsCodRet='00001';
			LET vAProcesar='';
			LET vProcesados='';
			LET vComentarios='';
			LET vRutaProcesar='';
			LET vRutaProcesados='';
			LET vRutaComentarios='';
		END IF
		IF (vProcesados IS NULL OR vProcesados='') THEN
			LET vsCodRet='00001';
			LET vAProcesar='';
			LET vProcesados='';
			LET vComentarios='';
			LET vRutaProcesar='';
			LET vRutaProcesados='';
			LET vRutaComentarios='';
		END IF
		IF (vRutaProcesar IS NULL OR vRutaProcesar='') THEN
			LET vsCodRet='00001';
			LET vAProcesar='';
			LET vProcesados='';
			LET vComentarios='';
			LET vRutaProcesar='';
			LET vRutaProcesados='';
			LET vRutaComentarios='';
		END IF
		IF (vRutaProcesados IS NULL OR vRutaProcesados='') THEN
			LET vsCodRet='00001';
			LET vAProcesar='';
			LET vProcesados='';
			LET vComentarios='';
			LET vRutaProcesar='';
			LET vRutaProcesados='';
			LET vRutaComentarios='';
		END IF
		RETURN vsCodRet,vAProcesar,vProcesados,vRutaProcesar,vRutaProcesados,vComentarios,vRutaComentarios;
	END;
END PROCEDURE;