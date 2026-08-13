CREATE PROCEDURE "informix".concilia_pendientes(pempresa CHAR(3),
					 	 parchivo VARCHAR(30,0),
						 pfecha DATE)
 RETURNING CHAR(5), INTEGER;

    -- ******************************
    -- *  DECLARACION DE VARIABLES  *
    -- ******************************
    DEFINE vcodret     		CHAR(5);
    DEFINE sql_err     		INTEGER;
    DEFINE vcontador		INTEGER;
    DEFINE vcuantos  		INTEGER;
    DEFINE vregistros		INTEGER;
    DEFINE vtp_movto		CHAR(1); 
    DEFINE vtran_central 	VARCHAR(4,0);
    DEFINE vtran_sucursal	CHAR(4); 
    DEFINE vfolio_mov		CHAR(16); 
    DEFINE vfolio_suc		CHAR(16); 
    DEFINE vcuenta		CHAR(20); 
    DEFINE vtran_secuencia 	VARCHAR(20,0);
    DEFINE vmonto		DECIMAL(14,2);
    DEFINE vmoneda		CHAR(2); 
    DEFINE vreferencia		VARCHAR(40,0); 
    DEFINE vrfc_comer		VARCHAR(20,1); 
    DEFINE vreferencia23	VARCHAR(23,1); 
    DEFINE vfecha_alta		DATE;
    DEFINE vexiste		CHAR(1);

    -- *********************************
    -- *  INICIALIZACION DE VARIABLES  *
    -- *********************************
    LET vcodret	= "000";
    LET sql_err	= 0;
    LET vcontador = -1;
    LET vcuantos = 0;

    BEGIN

    -- ************************
    -- *  MANEJA EXCEPCIONES  *
    -- ************************
    ON EXCEPTION
	SET sql_err
	IF sql_err <> 0 THEN
	    LET vcodret = sql_err;
            RETURN vcodret, vcuantos;
	END IF;
    END EXCEPTION;

    -- SET DEBUG FILE TO "./concilia_pendientes.out";
    -- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- ***********************************************************
    -- *  TABLA TEMPORAL PARA DETECTAR LAS TRANSACCIONES '0830'  *
    -- ***********************************************************
    SELECT TRIM(cuenta) || TRIM(folio_suc) AS llave,
           cuenta, fech_alt, monto_tot, folio_suc, cancelad
      FROM bdicheq:"informix".sc_movhis 
     WHERE transacc = "0830"
    UNION ALL
    SELECT TRIM(cuenta) || TRIM(folio_suc) as llave,
           cuenta, fech_alt, monto_tot, folio_suc, cancelad
      FROM bdicheq:"informix".sc_movhis_old 
     WHERE transacc = "0830"
      INTO TEMP tmp_0830 WITH NO LOG;
    CREATE INDEX idx_tmp_0830 
        ON tmp_0830 (llave) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_0830;

    -- ***********************************************************
    -- *  TABLA TEMPORAL PARA DETECTAR LAS TRANSACCIONES '0801'  *
    -- ***********************************************************
    SELECT {+INDEX (bdicheq:"informix".sc_docret idx_docret1)}
           TRIM(cuenta) || TRIM(folio_suc) as llave, * 
      FROM bdicheq:"informix".sc_docret
     WHERE empresa = pempresa
       AND cuenta IS NOT NULL
       AND transacc = "0801"
      INTO TEMP tmp_0801 WITH NO LOG;
    CREATE INDEX idx_tmp_0801
        ON tmp_0801 (llave) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_0801;

    -- ***********************************************************
    -- *  TABLA TEMPORAL PARA DETECTAR LAS TRANSACCIONES '0801'  *
    -- *  QUE NO TENGAN SU TRANSACCION '0830' CORRESPONDIENTE    *
    -- ***********************************************************
    SELECT *
      FROM tmp_0801
     WHERE llave NOT IN(SELECT llave FROM tmp_0830 WHERE llave IS NOT NULL)
      INTO TEMP tmp_0801sin0830 WITH NO LOG;
    CREATE INDEX idx_tmp_0801sin0830
        ON tmp_0801sin0830 (llave) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_0801sin0830;

    -- *****************************************************************
    -- *  TABLA TEMPORAL PARA DETECTAR LAS CUENTAS CON SALDO RETENIDO  *
    -- *****************************************************************
    SELECT a.cuenta, a.sdo_retenido,
           b.monto, b.fecha_alta, b.cancelado,
           c.cuenta AS num_tarjeta,  c.fecha, c.bandera_proceso,
           c.folio_mov, c.monto AS monto_conc, c.referencia, c.referencia23
      FROM bdicheq:"informix".sc_maechq a, 
           tmp_0801sin0830 b, 
           bditarjeta:"informix".td_conposvnd c,
           bdicheq:"informix".sc_tarjeta d
     WHERE a.empresa = pempresa
       AND a.empresa = b.empresa
       AND a.cuenta = b.cuenta
       AND a.sdo_retenido > 0
       AND b.llave IS NOT NULL
       AND b.cancelado <> "L"
       AND a.empresa = c.empresa
       AND c.archivo <> " "
       AND b.cuenta = d.cuenta
       AND d.num_tarjeta = c.cuenta
       AND b.folio_suc = c.folio_mov
       AND b.fecha_alta < "01012009"
      INTO TEMP tmp_detret WITH NO LOG;
    CREATE INDEX idx_tmp_detret
        ON tmp_detret (cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_detret;

    -- *************************************************************
    -- *  TABLA TEMPORAL QUE OBTIENE EL SALDO RETENIDO POR CUENTA  *
    -- *************************************************************
    SELECT cuenta, SUM(monto) AS sdo_retenido
      FROM tmp_detret
     WHERE cuenta IS NOT NULL
     GROUP BY cuenta
      INTO TEMP tmp_sdoret WITH NO LOG;
    CREATE INDEX idx_tmp_sdoret
        ON tmp_sdoret (cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_sdoret;

    -- ***************************************
    -- *  OBTIENE LOS REGISTROS A CONCILIAR  *
    -- ***************************************
    SELECT a.*
      FROM tmp_detret a, 
           tmp_sdoret b
     WHERE a.cuenta = b.cuenta 
       AND a.sdo_retenido = b.sdo_retenido
      INTO TEMP tmp_retxapli WITH NO LOG;
    CREATE INDEX idx_tmp_retxapli
        ON tmp_retxapli (cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_retxapli;

    -- ************************************************
    -- *  OBTIENE EL NUMERO DE REGISTROS A CONCILIAR  *
    -- ************************************************
    SELECT COUNT(cuenta)
      INTO vregistros
      FROM tmp_retxapli
     WHERE cuenta IS NOT NULL;

    -- ***************************************
    -- *  ACTUALIZA REGISTROS DEL sc_docret  *
    -- ***************************************
    FOREACH
        SELECT {+INDEX (bdicheq:"informix".sc_docret idx_docret1)}
	       cuenta, folio_suc, fecha_alta
    	  INTO vcuenta, vfolio_suc, vfecha_alta
          FROM bdicheq:"informix".sc_docret
     	 WHERE empresa = pempresa
           AND cuenta IS NOT NULL
           AND transacc = "0801"

	SELECT "1"
          INTO vexiste
	  FROM tmp_retxapli
	 WHERE cuenta = vcuenta
	   AND folio_mov = vfolio_suc
 	   AND fecha_alta = vfecha_alta;

    	IF vexiste = "1" THEN
	    UPDATE {+INDEX (bdicheq:"informix".sc_docret idx_docret1)} 
		   bdicheq:"informix".sc_docret
               SET cancelado = "P"
             WHERE empresa = pempresa 
               AND cuenta = vcuenta
               AND folio_suc = vfolio_suc
               AND fecha_alta = vfecha_alta;
        END IF;

    END FOREACH

    -- *********************************************
    -- *  INSERTA REGISTRO EN td_conciliaarchivos  *
    -- *********************************************
    SELECT FIRST 1 *
      FROM bditarjeta:"informix".td_conciliaarchivos
     WHERE empresa = pempresa
       AND archivo LIKE "VND%"
       AND fecha = pfecha
      INTO TEMP tmp_conciliaarchivos WITH NO LOG;

    UPDATE tmp_conciliaarchivos
       SET archivo           = parchivo,
           recibidos_total   = vregistros,
	   recibidos_cargo   = vregistros,
	   recibidos_abono   = 0,
	   recibidos_reversa = 0,
           procesados        = 0,
           cargo_concilia    = 0,
           cargo_aplica      = 0,
           cargo_error       = 0,
           abono_concilia    = 0,
           abono_aplica      = 0,
           abono_error       = 0,
           reversa_concilia  = 0,
           reversa_aplica    = 0,
           reversa_error     = 0,
           fecha_recepcion   = pfecha,
           bandera_procesa   = "0",
           usuario           = "intercar",
           sucursal          = "290",
           tipoarchivo       = "VND";

    INSERT INTO bditarjeta:"informix".td_conciliaarchivos
    SELECT * FROM tmp_conciliaarchivos;

    -- ************************ FOREACH PRINCIPAL ************************
    FOREACH WITH HOLD
        SELECT c.tp_movto, c.tran_central, c.tran_sucursal, c.folio_mov, 
               c.cuenta, c.tran_secuencia, c.monto, c.moneda, c.referencia, 
               c.rfc_comer, c.referencia23
          INTO vtp_movto, vtran_central, vtran_sucursal, vfolio_mov, 
               vcuenta, vtran_secuencia, vmonto, vmoneda, vreferencia, 
               vrfc_comer, vreferencia23      
	  FROM tmp_retxapli a,
	       bditarjeta:"informix".td_conposvnd c
	 WHERE c.cuenta = a.num_tarjeta
           AND c.folio_mov = a.folio_mov
           AND c.referencia = a.referencia 
           AND c.empresa = pempresa
           AND c.archivo IS NOT NULL
	 ORDER by a.cuenta, a.fecha_alta

        IF (vcontador = -1) THEN
            BEGIN WORK;
            LET vcontador = 0;
        END IF;

	INSERT INTO bditarjeta:"informix".td_conposvnd
           (empresa, archivo, fecha, consecutivo, tp_movto, tran_central,
            tran_sucursal, folio_mov, cuenta, tran_secuencia, monto, 
            moneda, referencia, folio_original, documento, cod_autorizacion, 
            campo_trabajo, rfc_comer, referencia23, bandera_proceso, 
            cod_retorno, divisa, monto_divisa, num_cajero, convenio,
	    tipo_tran_emp, monto_com_emp, forma_pago, fecha_aplica) 
        VALUES 
	   (pempresa, parchivo, pfecha, 0, vtp_movto, vtran_central, 
            vtran_sucursal, vfolio_mov, vcuenta, vtran_secuencia, vmonto, 
            vmoneda, vreferencia, "000000000000000", 0, "0000", 
            "0.00", vrfc_comer, vreferencia23, "0", 
            "000", "", 0.00, "", "", "", 0.00, "", pfecha);
	 
        LET vcontador = vcontador + 1;

	IF (vcontador >= 1000) THEN
            LET vcuantos = vcuantos + vcontador;
	    LET vcontador = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;

    END FOREACH;
    -- ************************* FOREACH PRINCIPAL *************************

    LET vcuantos = vcuantos + vcontador;

    IF (vcontador >= 0) THEN
        COMMIT WORK;
    END IF;

    END;

    RETURN vcodret, vcuantos;

END PROCEDURE;