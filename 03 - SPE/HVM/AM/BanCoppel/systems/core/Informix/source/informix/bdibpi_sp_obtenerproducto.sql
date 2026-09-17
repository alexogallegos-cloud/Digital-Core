CREATE PROCEDURE "informix".sp_obtenerproducto(pIdOper CHAR(4),pRegistros SMALLINT)
RETURNING CHAR(5),CHAR(4)

	------------------------------------------------------------------------------------------------------------------------
	--Elaboró:Francisco Rodríguez Ibarra.
	--Actividad:Se utiliza para obtener el producto, debido a la migración de BD de postgres a informix
	--Solicito:Diana Castellanos
	--Fecha:21/10/2010
	------------------------------------------------------------------------------------------------------------------------


	--DECLARACION DE VARIABLES
	DEFINE vCod_Ret CHAR(5);
	DEFINE sql_err INTEGER ;
	DEFINE vProducto CHAR(4);
	DEFINE vIcont    SMALLINT;
		
	--INICIALIZAR VALORES A VARIABLES;
	LET vCod_Ret='00000';
	LET vProducto='';
	LET vIcont=0;
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_Ret = sql_err;
				RETURN vCod_Ret,vProducto;
		  END IF ;
		END EXCEPTION ;
		
		FOREACH
			SELECT SKIP pRegistros FIRST 10  producto  INTO vProducto FROM bdibpi:bpi_pprod where id_oper=TRIM(pIdOper)
			
			IF (vProducto <>'' OR vProducto IS NOT NULL) THEN
				LET vIcont=1;
				RETURN vCod_Ret,vProducto WITH RESUME;
			END IF;
			
		END FOREACH;
		
		IF (vIcont=0) THEN
			LET vCod_Ret='00001';			
			RETURN vCod_Ret,vProducto;
			
		END IF;
		
	END;
END PROCEDURE;