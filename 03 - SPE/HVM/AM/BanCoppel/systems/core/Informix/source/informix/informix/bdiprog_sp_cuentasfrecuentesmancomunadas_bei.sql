CREATE PROCEDURE "informix".sp_cuentasfrecuentesmancomunadas_bei
(
    pcuenta_origen CHAR(20),
    pcuenta_destino CHAR(20),
    pimporte MONEY(14,2),
    preferencia CHAR(40),
    preferenciabe CHAR(40),
    pnombre_beneficiario VARCHAR(100),
    pid_usuario INTEGER,
    pid_cat_operacion INTEGER,
    pempresa CHAR(3),
    psucursal_virtual CHAR(4),
    pusuario_virtual CHAR(4),
    pclave_banco INTEGER,
    pnombre_usuario VARCHAR(40),
    prfc VARCHAR(18),
    ptipo_cuenta_beneficiario VARCHAR(40),
    pbanco_receptor VARCHAR(100),
    pcategoria  CHAR(2),
    pconvenio CHAR(3),
    preftelefono CHAR(20),
    prefverificador CHAR(20),
    pnumtransferenciacargo CHAR(4),
    pstatusoperacion CHAR(1),
    pid_cliente CHAR(9),
    cve_cuenta CHAR(2)
)
RETURNING CHAR(5),INTEGER;
--****************************************************************************************************
-- DESCRIPCION: Guardar la operaciÃ³n como pendiente para el alta/baja/edicion 
-- AUTOR : Jose Leon Arellano
-- FECHA : 15/Agosto/2016
-- BD: bdibei
--****************************************************************************************************

-- Variables para manejo de excepcion/resultado
    DEFINE sql_err INTEGER;
    DEFINE cod_ret CHAR(5);
    DEFINE sIdOper INTEGER;
	LET cod_ret  = '00000';
    LET sIdOper = 0;
	
	
BEGIN
    ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
          RETURN cod_ret,sIdOper;
      END IF ;
	END EXCEPTION;

    -- Validar datos de entrada
	IF NVL(pcuenta_destino,'')=='' THEN
		LET cod_ret = '00001';
		RETURN cod_ret,sIdOper;
	END IF;
	IF NVL(pimporte,'')=='' OR pimporte <= 0 THEN
		LET cod_ret = '00002';
		RETURN cod_ret,sIdOper;
	END IF;
	IF NVL(preferencia,'')=='' THEN
		LET cod_ret = '00003';
		RETURN cod_ret,sIdOper;
	END IF;
	IF NVL(pnombre_beneficiario,'')=='' THEN
		LET cod_ret = '00004';
		RETURN cod_ret,sIdOper;
	END IF;
	IF NVL(pid_usuario,'')=='' OR pid_usuario <= 0 THEN
		LET cod_ret = '00005';
		RETURN cod_ret,sIdOper;
	END IF;
	IF NVL(pid_cat_operacion,'')=='' OR pid_cat_operacion <= 0 THEN
		LET cod_ret = '00006';
		RETURN cod_ret,sIdOper;
	END IF;
	IF NVL(pempresa,'')=='' THEN
		LET cod_ret = '00007';
		RETURN cod_ret,sIdOper;
	END IF;
	IF NVL(psucursal_virtual,'')=='' THEN
		LET cod_ret = '00008';
		RETURN cod_ret,sIdOper;
	END IF;
	IF NVL(pusuario_virtual,'')=='' THEN
		LET cod_ret = '00009';
		RETURN cod_ret,sIdOper;
	END IF;
	IF NVL(pclave_banco,'')=='' OR pclave_banco <= 0 THEN
		LET cod_ret = '00010';
		RETURN cod_ret,sIdOper;
	END IF;
	IF NVL(pnombre_usuario,'')=='' THEN
		LET cod_ret = '00011';
		RETURN cod_ret,sIdOper;
	END IF;
	IF NVL(pbanco_receptor,'')=='' THEN
		LET cod_ret = '00012';
		RETURN cod_ret,sIdOper;
	END IF;
	IF NVL(pcategoria,'')=='' THEN
		LET cod_ret = '00013';
		RETURN cod_ret,sIdOper;
	END IF;
	IF NVL(pconvenio,'')=='' THEN
		LET cod_ret = '00014';
		RETURN cod_ret,sIdOper;
	END IF;
	IF NVL(pnumtransferenciacargo,'')=='' THEN
		LET cod_ret = '00015';
		RETURN cod_ret,sIdOper;
	END IF;
	IF NVL(pstatusoperacion,'')=='' THEN
		LET cod_ret = '00016';
		RETURN cod_ret,sIdOper;
	END IF;
    
	-- Ejecutar SP de mancomunidad en pendiente
	EXECUTE PROCEDURE bdibei:"informix".sp_insertaoperacionesmancomunadasoperador_bei('', pcuenta_origen, pcuenta_destino, pimporte, cve_cuenta, preferencia, preferenciabe, pnombre_beneficiario, sysdate, sysdate, pid_usuario, pid_cat_operacion, pempresa, psucursal_virtual, pusuario_virtual, pclave_banco, '', '', '', pnombre_usuario, prfc, ptipo_cuenta_beneficiario, '', '', pbanco_receptor, pnumtransferenciacargo, '', '', pcategoria, pconvenio, preftelefono, prefverificador, null, pstatusoperacion, '', '', '', '')
    INTO cod_ret,sIdOper;

    RETURN cod_ret,sIdOper;
END
END PROCEDURE;