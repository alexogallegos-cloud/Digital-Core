CREATE PROCEDURE "informix".sp_agregarbitacora_bpi_app(
pFechaOper datetime year to second,
pNumTrans char(4),
pNumSuc char(4),
pIdUsuario integer,
pIpUsuario char(15),
pFechaApli date,
pCtaOrigen char(12),
pCtaDesti char(20),  
pMonto money,
pSecTrans char(16),
pCgen1 char(100),  
pCgen2 char(200),  
pCgen3 char(60),  
pCgen4 char(60),  
pCgen5 char(60),  
pCgen6 char(100),  
pReferencia char(100),  
pFolio char(16),  
pDispositivo char(10)
)
 returning char(5);

	-- Realizo	 : IREB
	-- Actividad : Copia del SPL sp_agregarbitacora_bpi que apunta a la bitacora en la tabla de bdibpi
	-- Solicitó  : IREB
	-- Fecha	 : Junio/2015
--------------------------------------
    --127.0.0.01 : Android
    --127.0.0.02 : IOS
    --127.0.0.03 : WebApp
--------------------------------------
 --DEFINICION DE VARIABLES
DEFINE cod_ret char(5);
DEFINE sql_err integer;
DEFINE vCtasFrec CHAR(1);
DEFINE vNumCte CHAR(10);
DEFINE vCveCaducidad CHAR(1);
DEFINE vClaveBanco CHAR(60);
DEFINE vIp CHAR(10);

--INICIALIZA VARIABLES
LET cod_ret  = "000";
LET vClaveBanco = pCgen4;

IF pDispositivo = '01' THEN --Android
  LET vIp = '127.0.0.1';
END IF;

IF pDispositivo = '02' THEN --IOS
    LET vIp = '127.0.0.2';
END IF;

IF pDispositivo = '03' THEN --Tablet  
    LET vIp='127.0.0.3';
END IF;


--SET DEBUG FILE TO "/informix/ifg/sp_agregarbitacora_bpi_app.out";
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

	IF(pNumTrans IN ('1011','1015','2015','2100') ) THEN
		SELECT FIRST 1 vchrnombrecorto
		INTO pCgen4
		FROM BDINTEG:"informix".si_bancos
		WHERE banco = TRIM(vClaveBanco);
	END IF;

	
	INSERT INTO bdibpi:"informix".bpi_bitacora(fecha_oper,
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
				 folio) VALUES (pFechaOper,
						  pNumTrans,
						  pNumSuc,
						  pIdUsuario,
						  vIp,
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
						  pFolio);	

 	/*
	INSERT INTO si_bpibitacora(fecha_oper,
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
						  vIp,
						  pFechaApli,
						  pCtaOrigen,
						  pCtaDesti,
						  pMonto,
						  pSecTrans,
						  pCgen1,
						  pCgen2,
						  pCgen3,
						  pCgen4);
	*/

		SELECT ctas_frec INTO vCtasFrec FROM bdibpi:"informix".bpi_cat_operaciones WHERE id_oper = pNumTrans;

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
		RETURN cod_ret;
	--END IF;
	--RETURN cod_ret;
END;
END PROCEDURE;