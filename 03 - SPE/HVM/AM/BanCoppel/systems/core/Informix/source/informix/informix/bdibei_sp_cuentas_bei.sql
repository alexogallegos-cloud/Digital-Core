CREATE PROCEDURE "informix".sp_cuentas_bei(pempresa CHAR(3),pnum_cte CHAR(20),pRegistros smallint)
   returning char(5) as vCodRet, char(20) as vCuenta,char(4) as vProducto,
	     char(40) as vProdNom;


	--****************************************************************************************************
	-- DESCRIPCION:  OBTIENE LOS DATOS DE LAS CUENTAS
	-- AUTOR : SOLSER
	-- FECHA : 05/06/2013
	-- BD: bdicheq
	--***************************************************************************************************


-- DefiniciÃ?n de variables
   define vCodRet              char(5);
   define vCuenta              char(20);
   define vProducto            char(4);
   define vProdNom             char(40);
   define iCont                integer;
   define sql_err              integer;


--- Inicializa Variables de Salida
    let vCodRet   = "000";
    let vCuenta    = "";
    let vProducto = " ";
    let vProdNom = " ";


BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         let vCodRet = sql_err;
         RETURN vCodRet, vCuenta, vProducto,vProdNom ;
      END IF ;
   END EXCEPTION ;


--- Valida que el cliente no sea Blanco
   IF pnum_cte = "000000000" THEN
      let vCodRet = "110";
       RETURN vCodRet, vCuenta, vProducto,vProdNom ;
    END IF ;

		SET LOCK MODE TO WAIT ;
		SET ISOLATION DIRTY READ ;

---consulta cuentas efectivas
	FOREACH
            SELECT  mc.cuenta, mc.producto, pr.nombre
                  INTO vCuenta, vProducto, vProdNom
                FROM bdicheq:"informix".sc_maechq as mc, bdicheq:"informix".sc_producto as pr
                WHERE mc.num_cte = pnum_cte
                AND mc.status_cta not in (2,5)
                AND pr.empresa = mc.empresa
                AND pr.producto = mc.producto


            LET iCont = iCont + 1;
            RETURN vCodRet, vCuenta, vProducto,vProdNom  WITH RESUME;
	END FOREACH;

	IF ( iCont = 0 ) THEN
		LET vCodRet = '101'; --Cliente No tiene cuentas de cheques
		 RETURN vCodRet, vCuenta, vProducto,vProdNom ;
	END IF



END
END PROCEDURE ;