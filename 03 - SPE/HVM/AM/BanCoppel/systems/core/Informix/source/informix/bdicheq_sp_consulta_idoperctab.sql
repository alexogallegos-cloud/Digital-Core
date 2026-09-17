CREATE PROCEDURE "informix".sp_consulta_idoperctab(pTipoEmp SMALLINT, pConcepto SMALLINT, pTipoTransac char(3))
	returning char(5), char(4);

	--****************************************************************************************************
	-- DESCRIPCION:  Obtiene el ID de la operacion para Otros Bancos
	-- AUTOR : Jesus Ferruzca Luna - SOLSER
	-- FECHA : 02/Diciembre/2015
	-- BD: bdicheq
	-- SOLICITADO POR: Alejandro Vazquez - Coordinación Internet - GM3  - BanCoppel
	-- Liberado a produccion: 28 Enero 2016
	--****************************************************************************************************

	--Definicion de Variables
	DEFINE vCodRet char(5);
    DEFINE sql_err integer;
	DEFINE vTransaccion char(4);
    DEFINE iCont integer;
	
	--asigacion de valores a variables
	LET vCodRet='00000';
	LET vTransaccion='';
    LET iCont = 0;
	
	
  BEGIN


   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let vCodRet = sql_err;
            RETURN vCodRet, vTransaccion;
      END IF ;
   END EXCEPTION ;
	
	SET LOCK MODE TO WAIT ;
	SET ISOLATION DIRTY READ ;
	
		
	FOREACH
                
        SELECT  transacc
        INTO    vTransaccion
        FROM    "informix".sc_nominatransacciones
        WHERE   tipo_empresa = pTipoEmp
        AND     tipo_codigo = pConcepto
        AND     tipo_transaccion = pTipoTransac
			
		LET iCont=1;
		
		RETURN vCodRet, NVL(vTransaccion,'') WITH RESUME;
	END FOREACH;
	
	IF(iCont = 0) THEN
		LET vCodRet='00001';
		RETURN vCodRet, vTransaccion;
	END IF;
	END;
END PROCEDURE
;