CREATE PROCEDURE "informix".tc_concilia_debito(pEmpresa CHAR(16), pArchivo CHAR(12))
 	     	
RETURNING CHAR(5);

    --- El Archivo se estructura de la siguiente manera:
    ---	Tipo Archivo 3 caracter
    ---	Consecutivo  1 caracter
    --- Fecha 		 8 caracter MMDDYYYY
    ---	Ejemplo:	 ATM106121981

    -- // Variables Globales Conciliacion intercar
    DEFINE GLOBAL vg_estatus    VARCHAR(5)  DEFAULT " ";
    DEFINE GLOBAL vgrfc_comer   VARCHAR(20) DEFAULT " ";
    DEFINE GLOBAL vgreferencia  VARCHAR(40) DEFAULT " ";

    -- // Variables de Control de Errores
    DEFINE cod_ret      CHAR(5);
    DEFINE sql_err      SMALLINT;

    -- // Varibale de Control de Fecha Proceso
    DEFINE vFechaHoy	DATE;
    DEFINE vFech_param  DATE;

    -- // Varibale Proceso Conciliacion
    DEFINE v_cuenta				CHAR(20);
    DEFINE v_sucursal			CHAR(4);
    DEFINE v_usuario			CHAR(8);
    DEFINE v_tp_movto			CHAR(1);
    DEFINE v_tran_central		VARCHAR(4);
    DEFINE v_folio_mov			CHAR(16);
    DEFINE v_monto				DECIMAL(14,2);
    DEFINE v_moneda				CHAR(2);
    DEFINE v_referencia			VARCHAR	(40);
    DEFINE v_folio_original		VARCHAR	(16);
    DEFINE v_rfc_comer			VARCHAR	(20);
    DEFINE v_referencia23 		VARCHAR	(23);
    DEFINE v_archivo			VARCHAR(30);
    DEFINE v_consecutivo		INTEGER;
    DEFINE v_fecha				DATE;
    DEFINE v_tabla				VARCHAR	(40);
    DEFINE vBandera	            CHAR(1);

    -- // Variables ley de Transparencia
    DEFINE v_transparencia		VARCHAR(40);
    DEFINE v_divisa         	CHAR(3);
    DEFINE v_monto_divisa   	DECIMAL(12,2);
    DEFINE v_num_cajero     	CHAR(14);
    DEFINE v_forma_pago     	CHAR(1);
    DEFINE v_desc_forma_pago  VARCHAR(8);
    DEFINE v_cuenta_cliente		CHAR(20);

    -- // Variables de Control de Errores
    LET cod_ret = "000";
    LET sql_err = "";

    -- // Varibale de Control de Fecha Proceso
    LET vFechaHoy	= " ";
    LET vFech_param = " ";

    -- // Varibale Proceso Conciliacion
    LET v_cuenta		 = "";
    LET v_sucursal		 = "";
    LET v_usuario		 = "";
    LET v_tp_movto		 = "";
    LET v_tran_central	 = "";
    LET v_folio_mov		 = "";
    LET v_monto			 = 0;
    LET v_moneda		 = "";
    LET v_referencia	 = "";
    LET v_folio_original = "";
     LET v_rfc_comer	 = "";
    LET v_referencia23 	 = "";
    LET v_archivo		 = "";
    LET v_consecutivo	 = 0;
    LET v_fecha			 = " ";
    LET v_tabla			 = "";
    LET vBandera	     = "C";

    -- // Variables ley de Transparencia
    LET v_transparencia   = "";
    LET v_divisa          = "";
    LET v_monto_divisa    = 0;
    LET v_num_cajero      = "";
    LET v_forma_pago      = "";
    LET v_desc_forma_pago = "";
    LET v_cuenta_cliente  = "";

    BEGIN

    ON EXCEPTION SET sql_err
        LET cod_ret = sql_err;
        RETURN cod_ret;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/tmp/tc_concilia_debito.out";
    --- TRACE ON;
	
	--SET DEBUG FILE TO '/home/sysifx/conciliacion/TraceTARJETADEBITO.sql';
    --TRACE ON ;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;

    -- // Obtengo parametros
    SELECT fecha_hoy, fecha_hoy - 10 UNITS DAY
      INTO vFechaHoy, vFech_param
      FROM bdinteg:"informix".si_fechas
     WHERE empresa = pEmpresa;

    FOREACH WITH HOLD
        -- // VENTAS NACIONALES DEBITO
        SELECT a.cuenta, b.sucursal, b.usuario, a.tp_movto, a.tran_central, a.folio_mov, a.monto,
               a.moneda, a.referencia, a.folio_original, a.rfc_comer, a.referencia23,
               b.archivo, a.consecutivo, b.fecha, "td_conposvnd", a.divisa, a.monto_divisa, a.num_cajero, a.forma_pago
          INTO v_cuenta, v_sucursal, v_usuario, v_tp_movto, v_tran_central, v_folio_mov, v_monto,
               v_moneda, v_referencia, v_folio_original, v_rfc_comer, v_referencia23,
               v_archivo, v_consecutivo, v_fecha, v_tabla, v_divisa, v_monto_divisa, v_num_cajero, v_forma_pago
          FROM bditarjeta:"informix".td_conposvnd a,
               bditarjeta:"informix".td_conciliaarchivos b
         WHERE a.empresa = pEmpresa
           AND a.bandera_proceso = "0"
           AND b.empresa = a.empresa
           AND b.archivo = a.archivo
           AND b.fecha   = a.fecha
           AND b.archivo = pArchivo
        -- // VENTAS INTERNACIONALES DEBITO
        UNION ALL
        SELECT a.cuenta, b.sucursal, b.usuario, a.tp_movto, a.tran_central, a.folio_mov, a.monto,
               a.moneda, a.referencia, a.folio_original, a.rfc_comer, a.referencia23,
               b.archivo, a.consecutivo, b.fecha, "td_conposvid", a.divisa, a.monto_divisa, a.num_cajero, a.forma_pago
          FROM bditarjeta:"informix".td_conposvid a,
               bditarjeta:"informix".td_conciliaarchivos b
         WHERE a.empresa = pEmpresa
           AND a.bandera_proceso = "0"
           AND b.empresa = a.empresa
           AND b.archivo = a.archivo
           AND b.fecha   = a.fecha
           AND b.archivo = pArchivo
        -- // RETIROS DEBITO
        UNION ALL
        SELECT a.cuenta, b.sucursal, b.usuario, a.tp_movto, a.tran_central, a.folio_mov, a.monto,
               a.moneda, a.referencia, a.folio_original, a.rfc_comer, a.referencia23,
               b.archivo, a.consecutivo, b.fecha, "td_conatmd", a.divisa, a.monto_divisa, a.num_cajero, a.forma_pago
          FROM bditarjeta:"informix".td_conatmd a,
               bditarjeta:"informix".td_conciliaarchivos b
         WHERE a.empresa = pEmpresa
           AND a.bandera_proceso = "0"
           AND b.empresa = a.empresa
           AND b.archivo = a.archivo
           AND b.fecha   = a.fecha
           AND b.archivo = pArchivo

        LET v_sucursal  = "9290";
        LET v_usuario   = v_usuario;
        LET vg_estatus  = ' ';
        LET vgrfc_comer = v_rfc_comer;
        LET vgreferencia = v_referencia;
		
		--DEVOLUCIONES.. VALIDA SI EL REGISTRO ACTUAL ES UNA DEVOLUCION Y SI CUMPLE CON LOS REQUISITOS PARA SER APLICADA
		/*IF ( (v_tp_movto <> 'A') --EL RESTO DE LOS MOVIMIENTOS DE CARGOS
		OR ( (v_tp_movto = 'A') AND (v_tabla IN ('td_conposvnd', 'td_conposvid'))
		AND (EXISTS (SELECT NumTarjeta FROM BdiTarjeta:"informix".Td_DevolucionesPOS 
		WHERE FileName = pArchivo -- ARCHIVO
		AND NumTarjeta = v_cuenta --tarjeta
		AND SecuenciaAutArchivo <> '' --SUBSTR (v_folio_mov, 10, 6) --intercar2676640 / informix1676640
		AND Estado IN ('A', 'F') -- aplicar, forzar
		AND Aplicado = 'F'
		AND Referencia = v_referencia
		))) -- sin aplicar 
		)THEN*/

		--DEVOLUCIONES.. VALIDA SI EL REGISTRO ACTUAL ES UNA DEVOLUCION Y SI CUMPLE CON LOS REQUISITOS PARA SER APLICADA
		IF ((v_tp_movto <> 'A') OR    
		   (v_tp_movto = 'A' AND v_tabla IN ('td_conatmd')) OR 
		   ((v_tp_movto = 'A' AND v_tabla IN ('td_conposvnd', 'td_conposvid'))
		   AND (EXISTS (SELECT NumTarjeta FROM BdiTarjeta:"informix".Td_DevolucionesPOS 
				WHERE FileName = pArchivo -- ARCHIVO
				AND NumTarjeta = v_cuenta --tarjeta
				AND SecuenciaAutArchivo <> '' --SUBSTR (v_folio_mov, 10, 6) --intercar2676640 / informix1676640
				AND Estado IN ('A', 'F') -- aplicar, forzar
				AND Aplicado = 'F'
				AND Referencia = v_referencia)))) --sin aplicar 
		THEN 
			
		
			-- // Executa SPl de conciliacion de debito
			EXECUTE PROCEDURE bdicheq:"informix".conciliadebito(pEmpresa, v_cuenta, v_sucursal, v_usuario, v_tp_movto, v_tran_central, v_folio_mov,
													 v_monto, v_moneda, v_referencia, v_folio_original, v_rfc_comer, v_referencia23)
			INTO cod_ret, vBandera;

			-- // Actualiza ley de transparencia
			IF v_tabla IN ('td_conposvnd') THEN -- Compra en comercios nacionales VND
				LET v_transparencia = "";
			ELIF v_tabla IN ('td_conposvid')  THEN -- Compras en comercios internacionales VID
				LET v_transparencia = TRIM(v_monto_divisa::CHAR(15))||' '|| v_divisa;
			ELIF v_tabla IN ('td_conatmd')  THEN -- Retiros en Cajeros ATMC
				LET v_transparencia = v_num_cajero;
			END IF

			IF TRIM(v_transparencia) <> "" THEN
				IF vBandera = 'C' THEN
					SELECT cuenta
					  INTO v_cuenta_cliente
					  FROM bdicheq:"informix".sc_tarjeta
					 WHERE empresa = pEmpresa
					   AND num_tarjeta = v_cuenta;

					UPDATE bdicheq:"informix".sc_movhis
					   SET referencia = TRIM(referencia) ||' '|| v_transparencia
					 WHERE empresa = pEmpresa
					   AND cuenta = v_cuenta_cliente
					   AND fech_alt >= vFech_param
					   AND cancelad <> "S"
					   AND transacc = v_tran_central
					   AND folio_suc = v_folio_mov;
				ELIF vBandera = 'A' THEN
					UPDATE bdicheq:"informix".sc_movdia
					   SET referencia = TRIM(referencia) ||' '|| v_transparencia
					 WHERE empresa = pEmpresa
					   AND cuenta = v_cuenta_cliente
					   AND folio_suc = v_folio_mov;
				END IF
			END IF

			-- // Actualiza Registro de Control de Carga
			UPDATE bditarjeta:"informix".td_conciliaarchivos
			   SET procesados = NVL(procesados,0) + 1,
				   cargo_concilia = cargo_concilia + DECODE(v_tp_movto,'C',DECODE(vBandera,'C',1,0),0),
				   cargo_aplica = cargo_aplica + DECODE(v_tp_movto,'C',DECODE(vBandera,'A',1,0),0),
				   cargo_error = cargo_error + DECODE(v_tp_movto,'C',DECODE(vBandera,'E',1,0),0),
				   abono_concilia = abono_concilia + DECODE(v_tp_movto,'A',DECODE(vBandera,'C',1,0),0),
				   abono_aplica = abono_aplica + DECODE(v_tp_movto,'A',DECODE(vBandera,'A',1,0),0),
				   abono_error = abono_error + DECODE(v_tp_movto,'A',DECODE(vBandera,'E',1,0),0),
				   reversa_concilia=reversa_concilia + DECODE(v_tp_movto,'R',DECODE(vBandera,'C',1,0),0),
				   reversa_aplica = reversa_aplica + DECODE(v_tp_movto,'R',DECODE(vBandera,'A',1,0),0),
				   reversa_error = reversa_error + DECODE(v_tp_movto,'R',DECODE(vBandera,'E',1,0),0)
			 WHERE empresa = pEmpresa
			   AND archivo = v_archivo
			   AND fecha = v_fecha;

			-- // Actualiza Movimiento a Conciliar
			-- // POS
			IF v_tabla = "td_conposvnd" THEN -- VENTAS NACIONALES DEBITO
				UPDATE bditarjeta:"informix".td_conposvnd
				   SET bandera_proceso = vBandera,
					   cod_retorno = cod_ret,
					   fecha_aplica = vFechaHoy,
					   campo_trabajo = decode(vg_estatus," ",campo_trabajo,vg_estatus)
				 WHERE empresa = pEmpresa
				   AND archivo = v_archivo
				   AND fecha = v_fecha
				   AND consecutivo = v_consecutivo;
			ELIF  v_tabla = "td_conposvid" THEN -- VENTAS INTERNACIONALES DEBITO
				UPDATE bditarjeta:"informix".td_conposvid
				   SET bandera_proceso = vBandera,
					   cod_retorno = cod_ret,
					   fecha_aplica = vFechaHoy,
					   campo_trabajo = decode(vg_estatus," ","000",vg_estatus)
				 WHERE empresa = pEmpresa
				   AND archivo = v_archivo
				   AND fecha = v_fecha
				   AND consecutivo = v_consecutivo;
			-- // ATM
			ELIF  v_tabla = "td_conatmd" THEN -- VENTAS RETIROS DEBITO
				UPDATE bditarjeta:"informix".td_conatmd
				   SET bandera_proceso = vBandera,
					   cod_retorno = cod_ret,
					   fecha_aplica = vFechaHoy,
					   campo_trabajo = decode(vg_estatus," ",campo_trabajo,vg_estatus)
				 WHERE empresa = pEmpresa
				   AND archivo = v_archivo
				   AND fecha = v_fecha
				   AND consecutivo = v_consecutivo;
			END IF
			
		
			--ACTUALIZA EL REGISTRO DE LAS DEVOLUCIONES APLICADAS (CONCILIADAS Y FORZADAS)
			UPDATE BdiTarjeta:"informix".Td_DevolucionesPOS SET Aplicado =  (CASE WHEN vBandera IN ('A', 'C') THEN 'V' ELSE vBandera END)
			WHERE FileName = pArchivo -- ARCHIVO
			AND NumTarjeta = v_cuenta --tarjeta
			AND SecuenciaAutArchivo <> '' --SUBSTR (v_folio_mov, 10, 6) --intercar2676640 / informix1676640
			AND Estado IN ('A', 'F') -- aplicar, forzar
			AND Aplicado = 'F'
			AND Referencia = v_referencia;
			
		END IF; --DEVOLUCIONES
		
    END FOREACH;

    LET cod_ret = "000";

    RETURN cod_ret;

    END;

END PROCEDURE;