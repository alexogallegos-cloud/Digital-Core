CREATE PROCEDURE "informix".sp_obtbines(pBin char(6))
RETURNING CHAR(5),CHAR(3)


	------------------------------------------------------------------------------------------------------------------------
	--Elaboró:Francisco Rodríguez Ibarra.
	--Actividad:Se utiliza para obtener el banco  o generar los bines, debido a la migración de BD de postgres a informix
	--Solicito:Diana Castellanos
	--Fecha:21/10/2010
	------------------------------------------------------------------------------------------------------------------------
		------------------------------------------------------------------------------------------------------------------------
	--Elaboró:Francisco Rodríguez Ibarra.
	--Actividad:Se modificó para tomar la columna cve_banco en vez de la id_bco
	--Solicito:Diana Castellanos
	--Fecha:16/11/2010
	------------------------------------------------------------------------------------------------------------------------
	--DECLARACION DE VARIABLES
	DEFINE vCod_Ret CHAR(5);
	DEFINE sql_err INTEGER ;
	DEFINE vBanco CHAR(3);
	DEFINE vStipo CHAR(1);
	
	--INICIALIZAR VALORES A VARIABLES;
	LET vCod_Ret='00000';
	LET vBanco='';
	LET vStipo='';
	
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_Ret = sql_err;
				RETURN vCod_Ret,vBanco;
		  END IF ;
		END EXCEPTION ;
		
		
			
		SELECT creditodebito,cve_banco INTO vStipo,vBanco FROM  bdicheq:sc_bines WHERE bin= TRIM(pBIN);
		IF(vStipo<>'')THEN
			IF(vStipo='d')THEN
				LET vCod_Ret='00000';			END IF;
			IF(vStipo='c')THEN
				LET vCod_Ret='00001';			END IF;
		ELSE
				LET vCod_Ret='00002'; --No existe el bin
		END IF
		
		
		RETURN vCod_Ret,vBanco;
		
	END;
END PROCEDURE;