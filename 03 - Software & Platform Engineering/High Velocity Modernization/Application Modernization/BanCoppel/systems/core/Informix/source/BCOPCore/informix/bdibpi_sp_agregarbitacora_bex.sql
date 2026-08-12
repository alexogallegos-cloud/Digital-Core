CREATE PROCEDURE "informix".sp_agregarbitacora_bex(
pFechaOper datetime year to second,
pNumTrans char(4),
pNumSuc char(4),
pIdUsuario integer,
pIpUsuario char(15),
pFechaApli date,
pCtaOrigen char(12),
pCtaDesti char(20),  --CAMBIA
pMonto money,
pSecTrans char(16),
pCgen1 char(100),  --CAMBIA
pCgen2 char(200),  --CAMBIA
pCgen3 char(60),  --CAMBIA
pCgen4 char(60),  --CAMBIA
pCgen5 char(60),  --NUEVO
pCgen6 char(100),  --NUEVO
pReferencia char(100),  --NUEVO
pFolio char(16),  --NUEVO
pDispositivo char(10) --NUEVO
)
 returning char(5);


 --DEFINICION DE VARIABLES
DEFINE cod_ret char(5);
DEFINE sql_err integer;
DEFINE vCtasFrec CHAR(1);
DEFINE vNumCte CHAR(10);
DEFINE vCveCaducidad CHAR(1);
DEFINE vClaveBanco CHAR(60);

--INICIALIZA VARIABLES
LET cod_ret  = '00000';
LET vClaveBanco = pCgen4;

--SET DEBUG FILE TO "/informix/ireb/bdibpi/bex/sp_agregarbitacora_bex.out";
--TRACE ON;

BEGIN
  ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
      END IF ;
   END EXCEPTION ;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

   /*
   IF pNumSuc <> '5011' THEN 
       LET  cod_ret  = 'NOVAL';
       RETURN cod_ret;
   END IF
   */

    /*
	IF(pNumTrans IN ('1011','1015','2015','2100') ) THEN
		SELECT FIRST 1 vchrnombrecorto
		INTO pCgen4
		FROM BDINTEG:"informix".si_bancos
		WHERE banco = TRIM(vClaveBanco);
	END IF;
    */

    /*
	INSERT INTO bdibpi:"informix".bpi_bitacora_bex(fecha_oper,
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
			     cgenerico4,
				 cgenerico5,
				 cgenerico6,
				 referencia,
				 folio,
				 dispositivo) VALUES (pFechaOper,
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
						  pCgen4,
						  pCgen5,
						  pCgen6,
						  pReferencia,
						  pFolio,
						  pDispositivo);
    */
	--RETURN cod_ret;


		--- SELECT ctas_frec INTO vCtasFrec FROM bdibpi:"informix".bpi_cat_operaciones WHERE id_oper = pNumTrans;
		 
        /*
		IF (vCtasFrec = '1') THEN --- Significa que son operaciones que involucran cuentas frecuentes

			SELECT numcliente INTO vNumCte FROM bdibpi:"informix".bpi_usuario WHERE id_usuario = pIdUsuario AND st_portal = 'activo';
			 
			SELECT cve_caducidad INTO vCveCaducidad FROM bdiprog:"informix".pp_ctasterceros WHERE cuenta = pCtaDesti AND num_cte = vNumCte;
			  
			IF (vCveCaducidad = '3') THEN
				UPDATE bdiprog:"informix".pp_ctasterceros SET fecha_movtos = today WHERE cuenta = pCtaDesti AND num_ctE = vNumCte;
				  
				RETURN cod_ret;
			ELSE
				RETURN cod_ret;
			END IF;

		END IF;
        */
		RETURN cod_ret;
	--END IF;
	--RETURN cod_ret;
END;
END PROCEDURE;