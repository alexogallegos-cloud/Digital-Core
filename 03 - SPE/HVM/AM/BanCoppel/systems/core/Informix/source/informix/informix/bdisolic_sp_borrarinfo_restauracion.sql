CREATE PROCEDURE "informix".sp_borrarinfo_restauracion(pTipoOpcion CHAR(1), pNumCte CHAR(20), pProducto CHAR(6), pSucursal CHAR(4), pEmpresa CHAR(3))

RETURNING CHAR(5) AS CodRet;

-- ***************************************************************************
-- *                         DEFINICION DE VARIABLES                         *
-- ***************************************************************************
DEFINE cCodRet 		CHAR(5);
DEFINE iSqlErr 		INTEGER;
DEFINE dFechaHoy 	DATE;

-- ***************************************************************************
-- *                     ASIGNACION DE VALORES A VARIABLES                   *
-- ***************************************************************************
LET cCodRet 	= "00000";
LET iSqlErr 	= 0;
LET dFechaHoy 	= DATE(1);

BEGIN
   ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO '/informix/sp_borrarinfo_restauracion.out';
	--TRACE ON;
	/*
	-- SE VALIDA QUE LOS PARAMETROS DE ENTRADA TIPO OPCION, SUCURSAL Y EMPRESA NO ESTEN NULOS O VACIOS
	IF (pTipoOpcion IS NULL OR pTipoOpcion = "") OR (pSucursal IS NULL OR pSucursal = "") OR (pEmpresa IS NULL OR pEmpresa = "") THEN
		LET cCodRet = "00001";
		
	ELSE
		-- SE VALIDA SI SE ACCEDE POR TIPO OPCION IGUAL A 1
		IF pTipoOpcion = "1" THEN
			-- SE VALIDA QUE LOS PARAMETROS DE ENTRADA NUMERO DE CLIENTE Y PRODUCTO NO ESTEN NULOS O VACIOS
			IF (pNumCte IS NULL OR pNumCte = "") OR (pProducto IS NULL OR pProducto = "") THEN
				LET cCodRet = "00001";
			ELSE
				-- SE ELIMINA LA INFORMACION RESPALDADA PARA EL CLIENTE EN TABLAS DE RESTAURACION
				DELETE FROM bdisolic:"informix".ss_procesos_restauracion WHERE numcte = pNumCte AND producto = pProducto AND empresa = pEmpresa;
				
				DELETE FROM bdisolic:"informix".ss_infodatempleo_restauracion WHERE numcte = pNumCte AND producto = pProducto AND empresa = pEmpresa;
				
				DELETE FROM bdisolic:"informix".ss_refcliente_restauracion WHERE numcte = pNumCte AND producto = pProducto AND empresa = pEmpresa;
				
				DELETE FROM bdisolic:"informix".ss_pregscoring_restauracion WHERE numcte = pNumCte AND producto = pProducto AND empresa = pEmpresa;			
			END IF;
		
		-- SE VALIDA SI SE ACCEDE POR TIPO OPCION IGUAL A 2
		ELIF pTipoOpcion = "2" THEN
			-- SE ELIMINA LA INFORMACION POR SUCURSAL EN TABLAS DE RESTAURACION
			DELETE FROM bdisolic:"informix".ss_procesos_restauracion WHERE sucursal = pSucursal AND empresa = pEmpresa;
			
			DELETE FROM bdisolic:"informix".ss_infodatempleo_restauracion WHERE sucursal = pSucursal AND empresa = pEmpresa;
			
			DELETE FROM bdisolic:"informix".ss_refcliente_restauracion WHERE sucursal = pSucursal AND empresa = pEmpresa;
			
			DELETE FROM bdisolic:"informix".ss_pregscoring_restauracion WHERE sucursal = pSucursal AND empresa = pEmpresa;
		END IF;
	END IF;
	*/
RETURN cCodRet;

END;
END PROCEDURE
