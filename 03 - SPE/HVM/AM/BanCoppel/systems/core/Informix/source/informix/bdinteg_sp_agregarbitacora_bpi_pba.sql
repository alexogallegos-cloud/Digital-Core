CREATE PROCEDURE "informix".sp_agregarbitacora_bpi_pba(
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
pFolio char(16)  --NUEVO
)
 returning char(5);

    -- Realizo   : Javier Alonso Chávez Trujillo
    -- Actividad : Agrega Bitacora
    -- Solicitó  : Mauricio Leon
    -- Fecha     : 25/11/2008
	--//////////////////////////////////////////
	-- Realizo   : Walber Castro
	-- Actividad : se modifica el tipo de dato del parametro de entrada Monto ya que redondeaba las cifras grandes.
	-- Solicitó  : Mauricio Leon
	-- Fecha     : 23/08/2010
	-- ////////////////////////////////////////
	-- Bibiana Gaxiola Verdugo
	-- Se agrega la actualización del movimiento en la tabla de cuentas frecuentes para la caducidad de las mismas.
	-- 21/01/2013
	-- ING. ALFONSO CRUZ
	-- Modificacion en la bitacora en la que se agregaron parametros a la misma.
	-- 08/07/2013
	-- ////////////////////////////////////////
	-- Realizo	 : L.I. Manuel Ramos Figueroa
	-- Actividad : Se aumento a 100 el tamaño del parametro pCgen6
	-- Solicitó  : Bibiana Gaxiola Verdugo
	-- Fecha	 : 16/01/2014
	--//////////////////////////////////////////
	-- Realizo	 : L.I. Manuel Ramos Figueroa
	-- Actividad : Se aumento a 200 el tamaño del parametro pCgen2
	-- Solicitó  : Bibiana Gaxiola Verdugo
	-- Fecha	 : 06/02/2014

 --DEFINICION DE VARIABLES
DEFINE cod_ret char(5);
DEFINE sql_err integer;
DEFINE vCtasFrec CHAR(1);
DEFINE vNumCte CHAR(10);
DEFINE vCveCaducidad CHAR(1);
DEFINE vClaveBanco CHAR(60);

--INICIALIZA VARIABLES
LET cod_ret  = "000";
LET vClaveBanco = pCgen4;

--SET DEBUG FILE TO "/home/informix/bibiana/sp_agregarbitacora_bpi.out";
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
						  pFolio);
	--RETURN cod_ret;


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