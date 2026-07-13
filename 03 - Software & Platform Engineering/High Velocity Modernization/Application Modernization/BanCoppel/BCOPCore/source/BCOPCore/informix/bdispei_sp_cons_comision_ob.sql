CREATE PROCEDURE "informix".sp_cons_comision_ob()
	returning char(5), money;

	--****************************************************************************************************
	-- DESCRIPCION:  Obtener la comision para cuentas de otros bancos
	-- AUTOR : Jesus Ferruzca Luna  - SOLSER
	-- FECHA : 02/Diciembre/2015
	-- BD: bdispei
	-- SOLICITADO POR: Alejandro Vazquez - Coordinación Internet - GM3 - BanCoppel
	-- Liberado a Produccion: 28 Enero 2016
	--****************************************************************************************************

	--Definicion de Variables
	DEFINE vCodRet char(5);
    DEFINE sql_err integer;
	DEFINE vMonto money;
    DEFINE iCont integer;
	
	--asigacion de valores a variables
	LET vCodRet='00000';
	LET vMonto=0;
    LET iCont = 0;
	
	
  BEGIN


   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let vCodRet = sql_err;
            RETURN vCodRet, vMonto;
      END IF ;
   END EXCEPTION ;
	
	SET LOCK MODE TO WAIT ;
	SET ISOLATION DIRTY READ ;
	
		
	FOREACH

        SELECT mnycomision
        INTO   vMonto
        FROM   bdispei:"informix".tblcomision
			
		LET iCont=1;
		LET vMonto = 0;
		
		RETURN vCodRet, NVL(vMonto,-1) WITH RESUME;
	END FOREACH;
	
	IF(iCont = 0) THEN
		LET vCodRet='00001';
		RETURN vCodRet, vMonto;
	END IF;
	END;
END PROCEDURE
;