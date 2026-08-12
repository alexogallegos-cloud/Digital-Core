CREATE PROCEDURE "informix".sp_agregarbitacora_bei(pFechaOper datetime year to second, pNumTrans char(4),pNumSuc char(4),pIdUsuario integer,pIpUsuario char(15),pFechaApli date,pCtaOrigen char(12),pCtaDesti char(12),pMonto money,pSecTrans char(16),pCgen1 char(40),pCgen2 char(40),pCgen3 char(40),pCgen4 char(40))
 returning char(5);

    -- Realizó   : Mauricio León
    -- Actividad : Graba Bitacora para EmpresaNET
    -- Fecha     : 30/09/2011

 --DEFINICION DE VARIABLES
DEFINE cod_ret char(5);
DEFINE sql_err integer;

--INICIALIZA VARIABLES
LET cod_ret  = "000";

BEGIN
    ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
      END IF ;
    END EXCEPTION ;

	INSERT INTO bdinteg:"informix".si_bpibitacorapm(fecha_oper,
			     id_operacion,
			     sucursal,
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
			     cgenerico4) VALUES (pFechaOper,
						  pNumTrans,
						  pNumSuc,
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
						  pCgen4);
	RETURN cod_ret;

	END;
END PROCEDURE;