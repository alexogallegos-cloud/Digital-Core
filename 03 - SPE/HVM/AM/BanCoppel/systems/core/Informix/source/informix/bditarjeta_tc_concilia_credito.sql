CREATE PROCEDURE "informix".tc_concilia_credito
		(
		pEmpresa CHAR(16),
		pArchivo CHAR(12)
		)
		--El Archivo se estructura de la siguiente manera
		--	Tipo Archivo 3 caracter
		--	Consecutivo  1 caracter
		--  Fecha 		 8 caracter MMDDYYYY
		--	Ejemplo:	 ATM106121981
RETURNING CHAR(5);

	-- *************************************************************************
	-- *                      DEFINICION DE VARIABLES                          *
	-- *************************************************************************
	--------------------------------------------------------
	--	Variables de Control de Errores
	--------------------------------------------------------
	DEFINE cod_ret      CHAR(5);
	DEFINE sql_err      SMALLINT;
	--------------------------------------------------------
	--	Varibale de Control de Fecha Proceso
	--------------------------------------------------------
	DEFINE vFechaHoy	DATE;
	--------------------------------------------------------
	--	Varibale Proceso Conciliacion
	--------------------------------------------------------
	DEFINE v_cuenta				CHAR(20);
	DEFINE v_sucursal				CHAR(4);
	DEFINE v_usuario				CHAR(8);

	DEFINE v_tp_movto				CHAR(1);
	DEFINE v_tran_central			VARCHAR(4);
	DEFINE v_folio_mov			CHAR(16);
	DEFINE v_monto				DECIMAL(14,2);

	DEFINE v_moneda				CHAR(2);
	DEFINE v_referencia			VARCHAR	(40);
	DEFINE v_folio_original		VARCHAR	(16);
	DEFINE v_rfc_comer			VARCHAR	(20);
	DEFINE v_referencia23 		VARCHAR	(23);

	DEFINE v_archivo				VARCHAR(30);
	DEFINE v_consecutivo			INTEGER;
	DEFINE v_fecha				DATE;
	DEFINE v_tabla				VARCHAR	(40);


	DEFINE vBandera	      	CHAR(1);
	DEFINE v_NumTransacc	VARCHAR(4);
	DEFINE v_MontoConcilia	DECIMAL(14,2);
	DEFINE v_FormaAplica	CHAR(1);

	--------------------------------------------------------
	--	Variables ley de Transparencia
	--------------------------------------------------------

	DEFINE v_transparencia		VARCHAR(40);
	DEFINE v_divisa         	CHAR(3);
	DEFINE v_monto_divisa   	DECIMAL(12,2);
	DEFINE v_num_cajero     	CHAR(14);
	DEFINE v_forma_pago     	CHAR(1);
	DEFINE v_desc_forma_pago  VARCHAR(8);


	DEFINE v_codigo_fun				CHAR(3);
	DEFINE v_codigo_ref				INT;

  --//Variables para ubicar folio diferente transaccion en linea
    DEFINE vtamanio      SMALLINT;
    DEFINE vt_indicador  CHAR(1);
    DEFINE vt_newfolio   CHAR(16);
    DEFINE vt_folsucorig CHAR(16);
    DEFINE vg_estatus    VARCHAR(5);
    DEFINE v_MontoConcilia_sdofavor   DECIMAL(14,2);
  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************
	--------------------------------------------------------
	--	Variables de Control de Errores
	--------------------------------------------------------
	LET cod_ret       = "000";
	LET sql_err       = "";
	--------------------------------------------------------
	--	Varibale de Control de Fecha Proceso
	--------------------------------------------------------
	LET vFechaHoy	= " ";
	--------------------------------------------------------
	--	Varibale Proceso Conciliacion
	--------------------------------------------------------
	LET v_cuenta		= "";
	LET v_sucursal		= "";
	LET v_usuario		= "";

	LET v_tp_movto		= "";
	LET v_tran_central	= "";
	LET v_folio_mov		= "";
	LET v_monto			= 0;

	LET v_moneda			= "";
	LET v_referencia		= "";
	LET v_folio_original	= "";
	LET v_rfc_comer			= "";
	LET v_referencia23 		= "";

	LET v_archivo		= "";
	LET v_consecutivo	= 0;
	LET v_fecha			= " ";
	LET v_tabla			= "";


	LET vBandera	    = "C";
	LET v_NumTransacc	= "";
	LET v_MontoConcilia	= 0;
	LET v_FormaAplica	= "";
	--------------------------------------------------------
	--	Variables ley de Transparencia
	--------------------------------------------------------

	LET v_transparencia 			 = "";
	LET v_divisa               = "";
	LET v_monto_divisa         = 0;
	LET v_num_cajero           = "";
	LET v_forma_pago           = "";
	LET v_desc_forma_pago      = "";

	LET v_codigo_fun				= "";
	LET v_codigo_ref				= 0;
    LET v_MontoConcilia_sdofavor	 = 0;

BEGIN


   -- *************************************************************************
   -- *                      CONTROL DE ERRORES                               *
   -- *************************************************************************
   ON EXCEPTION SET sql_err
      LET cod_ret = sql_err;
      RETURN cod_ret;
   END EXCEPTION;

 --SET DEBUG FILE TO "tc_concilia_credito";
 --TRACE ON;

  SET LOCK MODE TO WAIT 3;
  SET ISOLATION TO DIRTY READ ;

-- ****************************************************************************
-- *                 	INICA PROGRAMA PRINCIPAL                              *
-- ****************************************************************************
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- Obtengo parametros
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	SELECT fecha_hoy 		INTO vFechaHoy
	FROM bdinteg:"informix".si_fechas WHERE empresa = pEmpresa;

	LET v_divisa               = "";
	LET v_monto_divisa         = 0;
	LET v_num_cajero           = "";
	LET v_forma_pago           = "";

	FOREACH WITH HOLD
			-- PAGOS NACIONALES INTERBANCARIOS
			SELECT 						a.cuenta,		b.sucursal,			b.usuario,
					a.tp_movto,			a.tran_central, a.folio_mov,		a.monto,
					a.moneda,			a.referencia,	a.folio_original,	a.rfc_comer,
		           	a.referencia23,
		           	b.archivo,			a.consecutivo,	b.fecha,			"td_conpospnc",
		           	a.divisa	, a.monto_divisa,	a.num_cajero,	a.forma_pago
			INTO 						v_cuenta,		v_sucursal,			v_usuario,
					v_tp_movto,			v_tran_central, v_folio_mov,		v_monto,
					v_moneda,			v_referencia,	v_folio_original,	v_rfc_comer,
		           	v_referencia23,
		           	v_archivo,			v_consecutivo,	v_fecha,			v_tabla,
		           	v_divisa,		v_monto_divisa,		v_num_cajero,		v_forma_pago
		    FROM BdiTarjeta:"informix".td_conpospnc a, BdiTarjeta:"informix".td_conciliaarchivos b
			WHERE a.empresa = pEmpresa	AND a.bandera_proceso ="0"
			  AND b.empresa = a.empresa AND b.archivo = a.archivo
			  AND b.fecha   = a.fecha	AND b.archivo = pArchivo

		  	-- VENTAS NACIONALES CREDITO
		  	UNION ALL
			SELECT 						a.cuenta,		b.sucursal,			b.usuario,
					a.tp_movto,			a.tran_central, a.folio_mov,		a.monto,
					a.moneda,			a.referencia,	a.folio_original,	a.rfc_comer,
		           	a.referencia23,
		           	b.archivo,			a.consecutivo,	b.fecha,			"td_conposvnc",
		           	a.divisa	, a.monto_divisa,	a.num_cajero,	a.forma_pago
		    FROM BdiTarjeta:"informix".td_conposvnc a, BdiTarjeta:"informix".td_conciliaarchivos b
			WHERE a.empresa = pEmpresa	AND a.bandera_proceso ="0"
			  AND b.empresa = a.empresa AND b.archivo = a.archivo
			  AND b.fecha   = a.fecha	AND b.archivo = pArchivo

		  	-- VENTAS INTERNACIONALES CREDITO
		  	UNION ALL
			SELECT 						a.cuenta,		b.sucursal,			b.usuario,
					a.tp_movto,			a.tran_central, a.folio_mov,		a.monto,
					a.moneda,			a.referencia,	a.folio_original,	a.rfc_comer,
		           	a.referencia23,
		           	b.archivo,			a.consecutivo,	b.fecha,			"td_conposvic",
		           	a.divisa	, a.monto_divisa,	a.num_cajero,	a.forma_pago
		    FROM BdiTarjeta:"informix".td_conposvic a, BdiTarjeta:"informix".td_conciliaarchivos b
			WHERE a.empresa = pEmpresa	AND a.bandera_proceso ="0"
			  AND b.empresa = a.empresa AND b.archivo = a.archivo
			  AND b.fecha   = a.fecha	AND b.archivo = pArchivo

		  	-- RETIROS CREDITO
		  	UNION ALL
			SELECT 						a.cuenta,		b.sucursal,			b.usuario,
					a.tp_movto,			a.tran_central, a.folio_mov,		a.monto,
					a.moneda,			a.referencia,	a.folio_original,	a.rfc_comer,
		           	a.referencia23,
		           	b.archivo,			a.consecutivo,	b.fecha,			"td_conatmc",
		           	a.divisa	, a.monto_divisa,	a.num_cajero,	a.forma_pago
		    FROM BdiTarjeta:"informix".td_conatmc a, BdiTarjeta:"informix".td_conciliaarchivos b
			WHERE a.empresa = pEmpresa	AND a.bandera_proceso ="0"
			  AND b.empresa = a.empresa AND b.archivo = a.archivo
			  AND b.fecha   = a.fecha	AND b.archivo = pArchivo



			LET v_sucursal = "9290";
			LET v_usuario = USER;

			--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			-- Busca Movimiento para Conciliacion
			--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

			IF LENGTH(TRIM(v_tran_central)) > 3 THEN
				LET v_NumTransacc = "6" || v_tran_central[2,4];
			ELSE
				LET v_NumTransacc = "6" || v_tran_central;
			END IF


			IF v_NumTransacc IN ("6802", "6850") THEN

				SELECT monto INTO v_MontoConcilia
				FROM bdicred:"informix".sd_movhis a, bdicred:"informix".sd_transfun b,
					 bdicred:"informix".sd_fechas c, bdicred:"informix".sd_tarjeta d
				WHERE b.transacc IN ("6802", "6850")
					AND d.empresa = b.empresa
					AND d.num_tarjeta = v_cuenta
					AND a.empresa = b.empresa
					AND a.num_credito = d.num_credito
					AND a.codigo_fun = b.codigo_fun
					AND a.codigo_ref = b.codigo_ref
					AND a.fecha_mov BETWEEN c.fecha_hoy -9  AND c.fecha_hoy
					AND a.reversado = "N"
					AND a.folio_suc = v_folio_mov;

			ELSE

				SELECT monto INTO v_MontoConcilia
				FROM bdicred:"informix".sd_movhis a, bdicred:"informix".sd_transfun b,
				  bdicred:"informix".sd_fechas c, bdicred:"informix".sd_tarjeta d
				WHERE b.transacc = v_NumTransacc
					AND d.empresa = b.empresa
					AND d.num_tarjeta = v_cuenta
					AND a.empresa = b.empresa
					AND a.num_credito = d.num_credito
					AND a.codigo_fun = b.codigo_fun
					AND a.codigo_ref = b.codigo_ref
					AND a.fecha_mov BETWEEN c.fecha_hoy -9  AND c.fecha_hoy
					AND a.reversado = "N"
					AND a.folio_suc = v_folio_mov;


                      IF  (v_NumTransacc IN ("6800","6871","6872","6873") AND v_MontoConcilia <> v_monto)  THEN
                             SELECT SUM(monto) INTO v_MontoConcilia_sdofavor
                             FROM bdicred:"informix".sd_movhis a, bdicred:"informix".sd_transfun b,
                             bdicred:"informix".sd_fechas c, bdicred:"informix".sd_tarjeta d
                             WHERE b.transacc IN ("7381","7382","7383","7384")
                             AND d.empresa = b.empresa
                             AND d.num_tarjeta = v_cuenta
                             AND a.empresa = b.empresa
                             AND a.num_credito = d.num_credito
                             AND a.codigo_fun = b.codigo_fun
                             AND a.codigo_ref = b.codigo_ref
                             AND a.fecha_mov BETWEEN c.fecha_hoy -9  AND c.fecha_hoy
                             AND a.reversado = "N"
                             AND a.folio_suc = v_folio_mov;

                              IF (v_MontoConcilia_sdofavor IS NOT NULL AND v_MontoConcilia_sdofavor > 0) THEN
                               LET v_MontoConcilia = v_MontoConcilia + v_MontoConcilia_sdofavor;
                              ELSE
                               LET v_MontoConcilia = v_MontoConcilia;
                               END IF
                         END IF



                        IF v_MontoConcilia IS NULL THEN
              		     	    SELECT monto INTO v_MontoConcilia
                     		    FROM   bdicred:"informix".sd_movhis a,
                     			   bdicred:"informix".sd_fechas c, bdicred:"informix".sd_tarjeta d
                     		    WHERE  d.empresa = pEmpresa
                      		    AND    d.num_tarjeta = v_cuenta
                    		    AND    a.empresa = pEmpresa
                      		    AND    a.num_credito = d.num_credito
                      		    AND    a.fecha_mov BETWEEN c.fecha_hoy -9  AND c.fecha_hoy
                      		    AND    a.reversado = "N"
                      		    AND    a.folio_suc = v_folio_mov
                                AND    a.monto = v_monto;
                  		END IF

			END IF



            --//Extrae el indicador, para revisar si viene con 1
                LET vtamanio = length(v_folio_mov);
                LET v_folio_mov = trim(v_folio_mov);
                LET vt_folsucorig = trim(v_folio_mov);
                LET vt_indicador = substr(v_folio_mov,(vtamanio -6),1);

               --//No encontro el folio en movhis
            IF v_MontoConcilia IS NULL THEN
                   IF vt_indicador = '2' AND v_folio_mov[1,8] = "intercar" THEN --//Cambio el indicador por 1
                      LET vt_newfolio = substr(v_folio_mov,1,vtamanio -7);
                      LET vt_newfolio = trim(vt_newfolio)||"1"||substr(v_folio_mov,vtamanio -5,vtamanio);
                      LET v_folio_mov = trim(vt_newfolio);
                 
                      --//Realiza la busqueda con el nuevo folio 
       		      IF v_NumTransacc IN ("6802", "6850") THEN
       		         
                        SELECT monto INTO v_MontoConcilia
                        FROM bdicred:"informix".sd_movhis a, bdicred:"informix".sd_transfun b,
                        bdicred:"informix".sd_fechas c, bdicred:"informix".sd_tarjeta d
                        WHERE b.transacc IN ("6802", "6850")
                        AND d.empresa = b.empresa
                        AND d.num_tarjeta = v_cuenta
                        AND a.empresa = b.empresa
                        AND a.num_credito = d.num_credito
                        AND a.codigo_fun = b.codigo_fun
                        AND a.codigo_ref = b.codigo_ref
                        AND a.fecha_mov BETWEEN c.fecha_hoy -9  AND c.fecha_hoy
                        AND a.reversado = "N"
                        AND a.folio_suc = v_folio_mov;
               
       		      ELSE
       		         
                        SELECT monto INTO v_MontoConcilia
                        FROM bdicred:"informix".sd_movhis a, bdicred:"informix".sd_transfun b,
                        bdicred:"informix".sd_fechas c, bdicred:"informix".sd_tarjeta d
                        WHERE b.transacc = v_NumTransacc
                        AND d.empresa = b.empresa
                        AND d.num_tarjeta = v_cuenta
                        AND a.empresa = b.empresa
                        AND a.num_credito = d.num_credito
                        AND a.codigo_fun = b.codigo_fun
                        AND a.codigo_ref = b.codigo_ref
                        AND a.fecha_mov BETWEEN c.fecha_hoy -9  AND c.fecha_hoy
                        AND a.reversado = "N"
                        AND a.folio_suc = v_folio_mov;

      
                        IF (v_NumTransacc IN ("6800","6871","6872","6873") AND v_MontoConcilia <> v_monto)  THEN 
                             SELECT SUM(monto) INTO v_MontoConcilia_sdofavor
                             FROM bdicred:"informix".sd_movhis a, bdicred:"informix".sd_transfun b,
                             bdicred:"informix".sd_fechas c, bdicred:"informix".sd_tarjeta d
                             WHERE b.transacc IN ("7381","7382","7383","7384")
                             AND d.empresa = b.empresa
                             AND d.num_tarjeta = v_cuenta
                             AND a.empresa = b.empresa
                             AND a.num_credito = d.num_credito
                             AND a.codigo_fun = b.codigo_fun
                             AND a.codigo_ref = b.codigo_ref
                             AND a.fecha_mov BETWEEN c.fecha_hoy -9  AND c.fecha_hoy
                             AND a.reversado = "N"
                             AND a.folio_suc = v_folio_mov;
       
                             IF (v_MontoConcilia_sdofavor IS NOT NULL AND v_MontoConcilia_sdofavor > 0) THEN
                                LET v_MontoConcilia = v_MontoConcilia + v_MontoConcilia_sdofavor;
                             ELSE
                                LET v_MontoConcilia = v_MontoConcilia;
                             END IF
                        END IF
       
                        IF v_MontoConcilia IS NULL THEN 

                             SELECT monto INTO v_MontoConcilia
                     		 FROM   bdicred:"informix".sd_movhis a,
                     		 bdicred:"informix".sd_fechas c, bdicred:"informix".sd_tarjeta d
                     		 WHERE  d.empresa = pEmpresa
                      		 AND    d.num_tarjeta = v_cuenta
                    		 AND    a.empresa = pEmpresa
                      		 AND    a.num_credito = d.num_credito
                      		 AND    a.fecha_mov BETWEEN c.fecha_hoy -9  AND c.fecha_hoy
                      		 AND    a.reversado = "N"
                      		 AND    a.folio_suc = v_folio_mov
                             AND    a.monto = v_monto;

                        END IF
		      END IF

                      IF v_MontoConcilia IS NULL THEN --//Forzada no encontrada como 2 ni 1...
                         LET vg_estatus = "3";
                         LET v_folio_mov = vt_folsucorig;
                      ELSE --//Forzada encontrada como 1..
                         LET vg_estatus = "2";
                      END IF
                   ELSE --//Normal no encontrada....
                      LET vg_estatus = "1";
                   END IF
                ELSE --//Si encontro el folio en docret...
                    IF vt_indicador = '1' THEN
                       LET vg_estatus = "0"; --//Mismo folio que transaccion en linea..
                    ELIF vt_indicador = '2' THEN
                       LET vg_estatus = "4";
                    ELSE
                       LET vg_estatus = "99";
                    END IF
                END IF

                --//Clasifica el Movimiento a aplicar
			IF v_MontoConcilia IS NULL THEN
				LET v_FormaAplica = "A";	-- Aplica Movto
			ELIF v_MontoConcilia <> v_monto THEN
				LET v_FormaAplica = "X"; 	-- Aplica Rev. y Movto
                   LET vg_estatus = vg_estatus::smallint + 10;
                   IF v_monto > v_MontoConcilia THEN
                      LET vg_estatus = vg_estatus::smallint + 10;
                   END IF
			ELIF v_MontoConcilia = v_monto THEN
				LET v_FormaAplica = "B"; 	-- Concilia Movto
			END IF


			LET cod_ret = '000';
			LET vBandera = '0';
			
				
			--DEVOLUCIONES.. VALIDA SI EL REGISTRO ACTUAL ES UNA DEVOLUCION Y SI CUMPLE CON LOS REQUISITOS PARA SER APLICADA
			IF ( ((v_tp_movto <> 'A') --EL RESTO DE LOS MOVIMIENTOS DE CARGOS
			OR (v_tabla IN ('td_conpospnc')) --SON ARCHIVOS DE PNC
			OR ((v_tp_movto = 'A') AND (v_tabla IN ('td_conatmc')))) --O ATM reversados como Abonos
			OR ((v_tp_movto = 'A') AND (v_tabla IN ('td_conposvnc', 'td_conposvic'))
			AND (EXISTS (SELECT NumTarjeta FROM BdiTarjeta:"informix".Td_DevolucionesPOS 
			WHERE FileName = pArchivo -- ARCHIVO
			AND NumTarjeta = v_cuenta --tarjeta
			AND SecuenciaAutArchivo <> '' --SUBSTR (v_folio_mov, 10, 6) --intercar2676640 / informix1676640
			AND Estado IN ('A', 'F') -- aplicar, forzar
			AND Aplicado = 'F'
			AND Referencia = v_referencia
			))) -- sin aplicar 
			)THEN 
			
			
				--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
				-- Executa SPl de conciliacion de credito
				--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

				EXECUTE PROCEDURE bdicred:"informix".conciliatc
					  (
						pEmpresa, 		v_cuenta, 		v_sucursal, 		v_usuario,
						v_tp_movto,		v_NumTransacc,  v_folio_mov,    	v_monto,
						v_moneda,  		v_referencia,   v_folio_original, 	v_FormaAplica,
						v_rfc_comer, 	v_referencia23)
					INTO cod_ret, vBandera;

				--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
				-- Ley de Tranparencia
				--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

				--Compra en comercios nacionales  VNC
				IF v_tabla IN ('td_conposvnc') THEN
					LET v_transparencia = "";

				--Compras en comercios internacionales VIC
				ELIF v_tabla IN ('td_conposvic')  THEN
					LET v_transparencia = TRIM(v_monto_divisa::CHAR(15)) ||' '|| v_divisa;

				--Retiros en Cajeros  ATMC
				ELIF v_tabla IN ('td_conatmc')  THEN
					LET v_transparencia = v_num_cajero;

				END IF


				IF TRIM(v_transparencia) <> "" THEN
					IF vBandera = 'C' THEN

						SELECT codigo_fun, codigo_ref INTO  v_codigo_fun, v_codigo_ref
						FROM bdicred:"informix".sd_transfun WHERE transacc  = v_NumTransacc;

						UPDATE bdicred:"informix".sd_movhis SET referencia = TRIM(referencia) ||' '|| v_transparencia
						WHERE codigo_fun = v_codigo_fun AND codigo_ref = v_codigo_ref
						AND folio_suc = v_folio_mov;

					ELIF vBandera = 'A' THEN

						UPDATE bdicred:"informix".sd_movdia SET referencia = TRIM(referencia) ||' '|| v_transparencia
						WHERE sucursal <> "0000" AND folio_suc  = v_folio_mov ;

					END IF
				END IF

				--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
				-- Actualiza Registro de Control de Carga
				--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
				UPDATE BdiTarjeta:"informix".td_conciliaarchivos
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
					
				--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
				-- Actualiza Movimiento a Conciliar
				--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
				--------------------------------------------------------
				--	POS
				--------------------------------------------------------
				-- PAGOS NACIONALES INTERBANCARIOS
				IF  v_tabla = "td_conpospnc" THEN
					UPDATE BdiTarjeta:"informix".td_conpospnc
					SET bandera_proceso = vBandera,cod_retorno = cod_ret,
						fecha_aplica = vFechaHoy,
						campo_trabajo = decode(vg_estatus," ","000",vg_estatus)
					WHERE empresa = pEmpresa	AND archivo = v_archivo
					AND fecha = v_fecha	AND consecutivo = v_consecutivo;
				-- VENTAS NACIONALES CREDITO
				ELIF  v_tabla = "td_conposvnc" THEN
					UPDATE BdiTarjeta:"informix".td_conposvnc
					SET bandera_proceso = vBandera,cod_retorno = cod_ret,
						fecha_aplica = vFechaHoy,
						campo_trabajo = decode(vg_estatus," ","000",vg_estatus)
					WHERE empresa = pEmpresa	AND archivo = v_archivo
					AND fecha = v_fecha	AND consecutivo = v_consecutivo;
				-- VENTAS INTERNACIONALES CREDITO
				ELIF  v_tabla = "td_conposvic" THEN
					UPDATE BdiTarjeta:"informix".td_conposvic
					SET bandera_proceso = vBandera,cod_retorno = cod_ret,
						fecha_aplica = vFechaHoy,
						campo_trabajo = decode(vg_estatus," ","000",vg_estatus)
					WHERE empresa = pEmpresa	AND archivo = v_archivo
					AND fecha = v_fecha	AND consecutivo = v_consecutivo;

				--------------------------------------------------------
				--	ATM
				--------------------------------------------------------
				-- RETIROS CREDITO
				ELIF  v_tabla = "td_conatmc" THEN
					UPDATE BdiTarjeta:"informix".td_conatmc
					SET bandera_proceso = vBandera,cod_retorno = cod_ret,
						fecha_aplica = vFechaHoy,
						campo_trabajo = decode(vg_estatus," ","000",vg_estatus)
					WHERE empresa = pEmpresa	AND archivo = v_archivo
					AND fecha = v_fecha	AND consecutivo = v_consecutivo;
				
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
			
			--IF cod_ret::INTEGER < 0 THEN
			--	EXIT FOREACH;
			--END IF
	END FOREACH;

	--IF cod_ret::INTEGER > 0 THEN
	--	LET cod_ret = "000";
	--END IF
	LET cod_ret = "000";
	
	RETURN cod_ret;
-- ****************************************************************************
-- *                 FINALIZA PROGRAMA PRINCIPAL                              *
-- ****************************************************************************
END;

END PROCEDURE;