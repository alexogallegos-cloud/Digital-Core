CREATE PROCEDURE "informix".sp_agregarbitacora_bpipba(pFechaOper datetime year to second, pNumTrans char(4),pNumSuc char(4),pIdUsuario integer,pIpUsuario char(15),pFechaApli date,pCtaOrigen char(12),pCtaDesti char(18),pMonto money,pSecTrans char(16),pCgen1 char(40),pCgen2 char(40),pCgen3 char(40),pCgen4 char(40))
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
 
 --DEFINICION DE VARIABLES
DEFINE cod_ret char(5);
DEFINE sql_err integer;
DEFINE vCtasFrec CHAR(1);
DEFINE vNumCte CHAR(10);
DEFINE vCveCaducidad CHAR(1);

--INICIALIZA VARIABLES
LET cod_ret  = "000";

--SET DEBUG FILE TO "/home/informix/bibiana/sp_agregarbitacora_bpi.out";
--TRACE ON;

BEGIN
  ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
      END IF ;
   END EXCEPTION ;
   
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
	--RETURN cod_ret;

		
		SELECT ctas_frec INTO vCtasFrec FROM bdibpi:"informix".bpi_cat_operaciones WHERE id_oper = pNumTrans;
		
		IF (vCtasFrec = '1') THEN --- Significa que son operaciones que involucran cuentas frecuentes
		
			SELECT numcliente INTO vNumCte FROM bdibpi:"informix".bpi_usuario WHERE id_usuario = pIdUsuario AND st_portal = 'activo';
		
			IF (pNumTrans IN ('1016','2100','2017','2020','2021','2022','2023')) THEN
				SELECT cve_caducidad INTO vCveCaducidad FROM bdiprog:"informix".pp_ctasterceros WHERE cuenta = pCtaDesti AND num_cte = vNumCte;

				IF (vCveCaducidad = '3') THEN
					UPDATE bdiprog:"informix".pp_ctasterceros SET fecha_movtos = today WHERE cuenta = pCtaDesti AND num_ctE = vNumCte;
					RETURN cod_ret;
				ELSE
					RETURN cod_ret;
				END IF;
			ELSE
			--IN ('1015','1017','1020','1021','1022','1023','1024','1025')) THEN 
				SELECT cve_caducidad INTO vCveCaducidad FROM bdiprog:"informix".pp_ctasterceros WHERE cuenta = pCgen2 AND num_cte = vNumCte;
			
				IF (vCveCaducidad = '3') THEN
					UPDATE bdiprog:"informix".pp_ctasterceros SET fecha_movtos = today WHERE cuenta = pCgen2 AND num_ctE = vNumCte;
					RETURN cod_ret;
				ELSE
					RETURN cod_ret;
				END IF;
			END IF;
			
		END IF;
		RETURN cod_ret;
	--END IF;
	--RETURN cod_ret;
END;
END PROCEDURE;