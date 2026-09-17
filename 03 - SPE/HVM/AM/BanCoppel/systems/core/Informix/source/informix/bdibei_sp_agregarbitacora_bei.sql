CREATE PROCEDURE "informix".sp_agregarbitacora_bei(pFechaOper datetime year to second, pNumTrans char(4),
pNumSuc char(4),pIdUsuario integer,pIpUsuario char(15),pFechaApli date,pCtaOrigen char(12),pCtaDesti char(12),
pMonto money,pSecTrans char(16),pCgen1 char(40),pCgen2 char(40),pCgen3 char(40),pCgen4 char(40),
pCgen5 char(40),pCgen6 char(40),pCgen7 char(40),pCgen8 char(40),pCgen9 char(40))
 returning char(5);

-- ****************************************************************************************************
-- DESCRIPCION: Insercion en bitacora con los campos genericos extra (originalmente eran 4 y el 11/10/2017 se agregaron 5 campos genericos)
-- AUTOR : Lili PV
-- FECHA : 11/Oct/2017
-- BD: bdibei
-- FECHA DE LIBERACIÓN:
-- ****************************************************************************************************

 --DEFINICION DE VARIABLES
DEFINE cod_ret char(5);
DEFINE sql_err integer;
DEFINE cNumCliente CHAR(50);

--INICIALIZA VARIABLES
LET cod_ret  = "000";

BEGIN
    ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
      END IF ;
    END EXCEPTION ;

    IF  pIdUsuario IS NOT NULL THEN

        SELECT num_cliente
    	INTO cNumCliente
    	FROM bei_usuario
    	WHERE id_usuario=pIdUsuario;
	ELSE
		LET cod_ret = '000001';
		RETURN cod_ret;
    END IF


	INSERT INTO bdibei:"informix".bei_bitacora(fecha_oper,
			     id_operacion,
			     sucursal,
			     num_cliente,
			     id_usuario,
			     ipusuario,
			     fecha_aplic,
			     cuenta_origen,
			     destino,
			     monto_oper,
			     sec_transaccion,
			     cgenerico1,
			     cgenerico2,
			     cgenerico3,
                 cgenerico4,
                 cgenerico5,
                 cgenerico6,
                 cgenerico7,
                 cgenerico8,
			     cgenerico9) VALUES (pFechaOper,
			     		pNumTrans,
						  pNumSuc,
						  cNumCliente,
						  pIdUsuario,
						  pIpUsuario,
						  pFechaApli,
						  pCtaOrigen,
						  pCtaDesti,
						  pMonto,
						  pSecTrans,
						  pCgen1,
						  pCgen2,
						  pCgen3,
                          pCgen4,
                          pCgen5,
                          pCgen6,
                          pCgen7,
                          pCgen8,
						  pCgen9);
	RETURN cod_ret;

	END;
END PROCEDURE;