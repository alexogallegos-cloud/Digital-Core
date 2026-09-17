CREATE PROCEDURE "informix".sp_buscar_movimientos_credito_dia3(p_sNumeroCuenta CHAR(30), p_sFechaInicial DATE, p_sFechaFinal DATE, p_sMonto money(14,2), p_skip INT, p_sTarjeta CHAR(30), ids_transacciones lvarchar, p_sNumeroEmpresa CHAR(3))

     RETURNING	DATE AS fechaMovimiento, DATETIME HOUR TO FRACTION(3) AS horaMovimiento , money(16,2) AS monto, CHAR(30) AS folioSuc, CHAR(4) AS sucursal, CHAR(30) AS nombre, CHAR(5) AS claveTipo, CHAR(40) AS tipo, CHAR(30) AS referencia23, CHAR(1) AS reversado, CHAR(40) AS refComercio,  DATE AS fechacConsumo, DATETIME HOUR TO FRACTION(3) AS horaConsumo;

	--definicion de variables--	    
	DEFINE resultado_fechaMovimiento    DATE;
	DEFINE resultado_monto				money(16,2);
	DEFINE saldo_favor    				money(16,2);
	DEFINE resultado_horaMovimiento		DATETIME HOUR TO FRACTION(3);
	DEFINE resultado_folioSuc			CHAR(30);
    DEFINE resultado_sucursal			CHAR(4);
    DEFINE resultado_nombre             CHAR(30);
   	DEFINE resultado_claveTipo          CHAR(5);
   	DEFINE resultado_tipo   			CHAR(40);
    DEFINE resultado_referencia23		CHAR(30);
    DEFINE resultado_reversado          CHAR(1);
	DEFINE resultado_refComercio        CHAR(40);
    DEFINE transacciones 				LIST(CHAR(4) NOT NULL);
    DEFINE iSqlErr                      INTEGER;
	DEFINE res_fechaMovimiento_ret    	DATE;
	DEFINE res_horaMovimiento_ret		DATETIME HOUR TO FRACTION(3);
	DEFINE res_fechaMovimiento_re1	 	DATE;
	DEFINE res_horaMovimiento_re1	 	DATETIME HOUR TO FRACTION(3);
	DEFINE bin_tdc_coppel_mc            CHAR(6);	--JLM/GIV/14092022
	
     -- Inicializacion de las variables.
	LET resultado_fechaMovimiento = '';
	LET resultado_monto = '';
	LET saldo_favor = '';
	LET resultado_horaMovimiento = TO_DATE("00:00","%H:%M");
	LET resultado_folioSuc = '';
    LET resultado_sucursal = '';
    LET resultado_nombre = '';
    LET resultado_claveTipo = '';
	LET resultado_tipo = '';
    LET resultado_referencia23 = '';
    LET resultado_reversado = '';
	LET resultado_refComercio = '';
    LET transacciones = 'LIST{' || ids_transacciones || '}';
	LET res_fechaMovimiento_ret = '';
	LET res_horaMovimiento_ret  = TO_DATE("00:00","%H:%M");
	LET res_fechaMovimiento_re1 = '';
	LET res_horaMovimiento_re1  = TO_DATE("00:00","%H:%M");
    LET bin_tdc_coppel_mc		 = '';  --JLM/GIV/14092022
   
	--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	-- SET DEBUG FILE TO "/pisa/sp_buscar_movimientos_credito_dia3.out";
	-- TRACE ON;
/* Se modifica Sp para agregar en la busqueda de movimientos la transacción 7382 solicitada por el usario del area de aclaraciones 
el dia 21/09/2018*/
BEGIN

	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET resultado_fechaMovimiento = '';
			LET resultado_monto = '';
			LET saldo_favor = '';
			LET resultado_horaMovimiento = TO_DATE("00:00","%H:%M");
			LET resultado_folioSuc = '';
			LET resultado_sucursal = '';
			LET resultado_nombre = '';
			LET resultado_claveTipo = '';
			LET resultado_tipo = '';
			LET resultado_referencia23 = LPAD (resultado_referencia23,23,"0");
			LET resultado_reversado='';
			LET resultado_refComercio = '';
			LET res_fechaMovimiento_ret = '';
			LET res_horaMovimiento_ret  = TO_DATE("00:00","%H:%M");
			RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret;
		END IF;
	END EXCEPTION;

	--JLM/GIV/14092022
	SELECT bin into bin_tdc_coppel_mc FROM  intercard:binproducto WHERE idbinproducto = 174; -- bin= 514014
	
	IF SUBSTRING(p_sTarjeta FROM 1 FOR 6) = bin_tdc_coppel_mc THEN
		FOREACH		
		EXECUTE PROCEDURE bdinteg:"informix".sp_buscar_movimientos_credito_mc(p_sNumeroCuenta, p_sFechaInicial, p_sFechaFinal, p_sMonto, p_skip, p_sTarjeta, ids_transacciones, p_sNumeroEmpresa)
			INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret
		RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret WITH RESUME;
		END FOREACH;
	END IF;
	--JLM/GIV/14092022
	
	IF(ids_transacciones IS NOT NULL) THEN
		IF(p_sTarjeta IS NOT NULL AND p_sTarjeta <> '') THEN
			IF p_sMonto IS NULL OR p_sMonto = 0 THEN
				FOREACH       
					SELECT SKIP p_skip DISTINCT fecha_mov, hora_mov, monto, folio_suc, bdinteg:si_sucursales.sucursal, nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, LPAD (referencia23,23,"0"), reversado, referencia, fecha_mov, hora_mov
						INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret
					FROM bdicred:sd_movdia 
						LEFT JOIN bdicred:sd_transfun ON (bdicred:sd_movdia.codigo_fun = bdicred:sd_transfun.codigo_fun 
							and bdicred:sd_movdia.codigo_ref = bdicred:sd_transfun.codigo_ref) 
						LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa 
							AND bdinteg:si_sucursales.sucursal = bdicred:sd_movdia.sucursal) 
						LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.numero = bdicred:sd_transfun.transacc 
							AND bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdicred:sd_transfun.transacc <> '0801') 
					WHERE num_credito = p_sNumeroCuenta 
						AND fecha_mov <= p_sFechaFinal 
						AND fecha_mov >= p_sFechaInicial
						AND nro_tarjeta = p_sTarjeta --OR nro_tarjeta = '' OR nro_tarjeta IS NULL)
						AND bdicred:sd_transfun.transacc <> '0801'
						AND bdicred:sd_movdia.transacc_suc not in ('6801','7380','7381','7383','7384','7729','7730')
						AND bdicred:sd_transfun.transacc IN transacciones
						AND bdicred:sd_movdia.empresa = p_sNumeroEmpresa
						AND bdicred:sd_movdia.reversado <>'S'
					ORDER BY folio_suc ASC, fecha_mov ASC
					
					IF (resultado_claveTipo IN ('6900','6800','6871','6872','6873','6830','6887')) THEN
						select monto
							into saldo_favor
						FROM bdicred:sd_movdia 
						WHERE num_credito = p_sNumeroCuenta 
							AND fecha_mov <= p_sFechaFinal 
							AND fecha_mov >= p_sFechaInicial
							AND nro_tarjeta = p_sTarjeta --OR nro_tarjeta = '' OR nro_tarjeta IS NULL)
							AND bdicred:sd_movdia.empresa = p_sNumeroEmpresa
							AND folio_suc = resultado_folioSuc
							AND bdicred:sd_movdia.transacc_suc <> '6801'
							AND bdicred:sd_movdia.transacc_suc in ('7380','7381','7382','7383','7384','7729','7730');

						IF saldo_favor IS NULL THEN 
							let saldo_favor = 0;
						end if;
							
						let resultado_monto = resultado_monto + saldo_favor;
							
					END IF;
					
					LET res_fechaMovimiento_re1=res_fechaMovimiento_ret;
					LET res_horaMovimiento_re1=res_horaMovimiento_ret;								
					
					IF (resultado_claveTipo in ('6830','7729')) THEN 
						SELECT DISTINCT fecha_mov, hora_mov
							INTO res_fechaMovimiento_ret, res_horaMovimiento_ret
						FROM bdicred:sd_movdia
						WHERE bdicred:sd_movdia.empresa = p_sNumeroEmpresa 
							AND num_credito = p_sNumeroCuenta 
							AND fecha_mov <= p_sFechaFinal 
							AND fecha_mov >= p_sFechaInicial-30
							AND bdicred:sd_movdia.folio_suc=resultado_folioSuc	
							AND bdicred:sd_movdia.transacc_suc='6801';  
					END IF;
					
					-- Obtener la fecha de Retenido del movimiento
					IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
						IF (resultado_claveTipo in ('6830','7729')) THEN 
							SELECT DISTINCT fecha_mov, hora_mov
								INTO res_fechaMovimiento_ret, res_horaMovimiento_ret
							FROM bdicred:sd_movhis 
							WHERE bdicred:sd_movhis.empresa = p_sNumeroEmpresa 
								AND num_credito = p_sNumeroCuenta 
								AND fecha_mov <= p_sFechaFinal 
								AND fecha_mov >= p_sFechaInicial-30
								AND bdicred:sd_movhis.folio_suc=resultado_folioSuc	
								AND bdicred:sd_movhis.transacc_suc='6801';  
						END IF;
					END IF;
					
					IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
						LET res_fechaMovimiento_ret=res_fechaMovimiento_re1;
						LET res_horaMovimiento_ret=res_horaMovimiento_re1;							
					END IF;
					
					RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret WITH RESUME;
					
				END FOREACH;
			ELSE --IF p_sMonto IS NULL OR p_sMonto = 0 THEN
				FOREACH       
					SELECT SKIP p_skip DISTINCT fecha_mov, hora_mov, monto, folio_suc, bdinteg:si_sucursales.sucursal, nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, LPAD (referencia23,23,"0"), reversado, referencia, fecha_mov, hora_mov
						INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret
					FROM bdicred:sd_movdia 
						LEFT JOIN bdicred:sd_transfun ON (bdicred:sd_movdia.codigo_fun = bdicred:sd_transfun.codigo_fun 
							and bdicred:sd_movdia.codigo_ref = bdicred:sd_transfun.codigo_ref)  
						LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa 
							AND bdinteg:si_sucursales.sucursal = bdicred:sd_movdia.sucursal) 
						LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.numero = bdicred:sd_transfun.transacc 
								AND bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdicred:sd_transfun.transacc <> '0801')
					WHERE  num_credito = p_sNumeroCuenta 
						AND fecha_mov <= p_sFechaFinal 
						AND fecha_mov >= p_sFechaInicial 
						AND monto = p_sMonto
						AND nro_tarjeta = p_sTarjeta-- OR nro_tarjeta = '' OR nro_tarjeta IS NULL)
						AND bdicred:sd_transfun.transacc <> '0801'
						AND bdicred:sd_movdia.transacc_suc <> '6801'
						AND bdicred:sd_transfun.transacc IN transacciones
						AND bdicred:sd_movdia.empresa = p_sNumeroEmpresa
						AND bdicred:sd_movdia.reversado <>'S'
					ORDER BY folio_suc ASC, fecha_mov ASC
					-----------------AGREGADO-----------------------------------
					LET res_fechaMovimiento_re1=res_fechaMovimiento_ret;
					LET res_horaMovimiento_re1=res_horaMovimiento_ret;								
					
					IF (resultado_claveTipo in ('6830','7729')) THEN 
						SELECT DISTINCT fecha_mov, hora_mov
							INTO res_fechaMovimiento_ret, res_horaMovimiento_ret
						FROM bdicred:sd_movdia
						WHERE bdicred:sd_movdia.empresa = p_sNumeroEmpresa 
							AND num_credito = p_sNumeroCuenta 
							AND fecha_mov <= p_sFechaFinal 
							AND fecha_mov >= p_sFechaInicial-30
							AND bdicred:sd_movdia.folio_suc=resultado_folioSuc	
							AND bdicred:sd_movdia.transacc_suc='6801';  
					END IF;
					
					-- Obtener la fecha de Retenido del movimiento
					IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
						IF (resultado_claveTipo in ('6830','7729')) THEN 
							SELECT DISTINCT fecha_mov, hora_mov
								INTO res_fechaMovimiento_ret, res_horaMovimiento_ret
							FROM bdicred:sd_movhis 
							WHERE bdicred:sd_movhis.empresa = p_sNumeroEmpresa 
								AND num_credito = p_sNumeroCuenta 
								AND fecha_mov <= p_sFechaFinal 
								AND fecha_mov >= p_sFechaInicial-30
								AND bdicred:sd_movhis.folio_suc=resultado_folioSuc	
								AND bdicred:sd_movhis.transacc_suc='6801';  
						END IF;
					END IF;
					
					IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
						LET res_fechaMovimiento_ret=res_fechaMovimiento_re1;
						LET res_horaMovimiento_ret=res_horaMovimiento_re1;							
					END IF;
					----------TERMINO AGREGADO-------------
					RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret WITH RESUME;
					
				END FOREACH;
			END IF; --IF p_sMonto IS NULL OR p_sMonto = 0 THEN      
		ELSE --IF(p_sTarjeta IS NOT NULL AND p_sTarjeta <> '') THEN
			IF p_sMonto IS NULL OR p_sMonto = 0 THEN
				FOREACH       
					SELECT SKIP p_skip DISTINCT fecha_mov, hora_mov, monto, folio_suc, bdinteg:si_sucursales.sucursal, nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, LPAD (referencia23,23,"0"), reversado, referencia, fecha_mov, hora_mov
						INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio,res_fechaMovimiento_ret, res_horaMovimiento_ret
					FROM bdicred:sd_movdia 
						LEFT JOIN bdicred:sd_transfun ON (bdicred:sd_movdia.codigo_fun = bdicred:sd_transfun.codigo_fun 
							and bdicred:sd_movdia.codigo_ref = bdicred:sd_transfun.codigo_ref) 
						LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa 
							AND bdinteg:si_sucursales.sucursal = bdicred:sd_movdia.sucursal) 
						LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.numero = bdicred:sd_transfun.transacc 
								AND bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdicred:sd_transfun.transacc <> '0801') 
					WHERE num_credito = p_sNumeroCuenta 
						AND fecha_mov <= p_sFechaFinal 
						AND fecha_mov >= p_sFechaInicial
						--AND (nro_tarjeta = '' OR nro_tarjeta IS NULL)
						AND bdicred:sd_transfun.transacc <> '0801'
						AND bdicred:sd_movdia.transacc_suc not in ('6801','7380','7381','7383','7384','7729','7730')
						AND bdicred:sd_transfun.transacc IN transacciones
						AND bdicred:sd_movdia.empresa = p_sNumeroEmpresa
						AND bdicred:sd_movdia.reversado <>'S'
					ORDER BY folio_suc ASC, fecha_mov ASC
					
					IF (resultado_claveTipo IN ('6900','6800','6871','6872','6873','6830','6887')) THEN
						select monto
							into saldo_favor
						FROM bdicred:sd_movdia 
						WHERE num_credito = p_sNumeroCuenta 
							AND fecha_mov <= p_sFechaFinal 
							AND fecha_mov >= p_sFechaInicial
							--AND (nro_tarjeta = '' OR nro_tarjeta IS NULL)	
							AND bdicred:sd_movdia.empresa = p_sNumeroEmpresa
							AND folio_suc = resultado_folioSuc
							AND bdicred:sd_movdia.transacc_suc <> '6801'
							AND bdicred:sd_movdia.transacc_suc in ('7380','7381','7382','7383','7384','7729','7730');

						IF saldo_favor IS NULL THEN 
							let saldo_favor = 0;
						end if;
							
						let resultado_monto = resultado_monto + saldo_favor;
							
					END IF;
					-----------------AGREGADO-----------------------------------
					LET res_fechaMovimiento_re1=res_fechaMovimiento_ret;
					LET res_horaMovimiento_re1=res_horaMovimiento_ret;								
					
					IF (resultado_claveTipo in ('6830','7729')) THEN 
						SELECT DISTINCT fecha_mov, hora_mov
							INTO res_fechaMovimiento_ret, res_horaMovimiento_ret
						FROM bdicred:sd_movdia
						WHERE bdicred:sd_movdia.empresa = p_sNumeroEmpresa 
							AND num_credito = p_sNumeroCuenta 
							AND fecha_mov <= p_sFechaFinal 
							AND fecha_mov >= p_sFechaInicial-30
							AND bdicred:sd_movdia.folio_suc=resultado_folioSuc	
							AND bdicred:sd_movdia.transacc_suc='6801';  
					END IF;
					
					-- Obtener la fecha de Retenido del movimiento
					IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
						IF (resultado_claveTipo in ('6830','7729')) THEN 
							SELECT DISTINCT fecha_mov, hora_mov
								INTO res_fechaMovimiento_ret, res_horaMovimiento_ret
							FROM bdicred:sd_movhis 
							WHERE bdicred:sd_movhis.empresa = p_sNumeroEmpresa 
								AND num_credito = p_sNumeroCuenta 
								AND fecha_mov <= p_sFechaFinal 
								AND fecha_mov >= p_sFechaInicial-30
								AND bdicred:sd_movhis.folio_suc=resultado_folioSuc	
								AND bdicred:sd_movhis.transacc_suc='6801';  
						END IF;
					END IF;
					
					IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
						LET res_fechaMovimiento_ret=res_fechaMovimiento_re1;
						LET res_horaMovimiento_ret=res_horaMovimiento_re1;							
					END IF;
					----------TERMINO AGREGADO-------------

					RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret WITH RESUME;
					
				END FOREACH;
			ELSE --IF p_sMonto IS NULL OR p_sMonto = 0 THEN
				FOREACH       
					SELECT SKIP p_skip DISTINCT fecha_mov, hora_mov, monto, folio_suc, bdinteg:si_sucursales.sucursal, nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, LPAD (referencia23,23,"0"), reversado, referencia, fecha_mov, hora_mov
						INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio,res_fechaMovimiento_ret, res_horaMovimiento_ret
					FROM bdicred:sd_movdia 
						LEFT JOIN bdicred:sd_transfun ON (bdicred:sd_movdia.codigo_fun = bdicred:sd_transfun.codigo_fun 
							and bdicred:sd_movdia.codigo_ref = bdicred:sd_transfun.codigo_ref)  
						LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa 
								AND bdinteg:si_sucursales.sucursal = bdicred:sd_movdia.sucursal) 
						LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.numero = bdicred:sd_transfun.transacc
								AND bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdicred:sd_transfun.transacc <> '0801')
					WHERE  num_credito = p_sNumeroCuenta 
						AND fecha_mov <= p_sFechaFinal 
						AND fecha_mov >= p_sFechaInicial 
						--AND (nro_tarjeta = '' OR nro_tarjeta IS NULL)
						AND monto = p_sMonto
						AND bdicred:sd_transfun.transacc <> '0801'
						AND bdicred:sd_movdia.transacc_suc <> '6801'
						AND bdicred:sd_movdia.reversado <>'S'
						AND bdicred:sd_transfun.transacc IN transacciones
					ORDER BY folio_suc ASC, fecha_mov ASC
					-----------------AGREGADO-----------------------------------
					LET res_fechaMovimiento_re1=res_fechaMovimiento_ret;
					LET res_horaMovimiento_re1=res_horaMovimiento_ret;								
					
					IF (resultado_claveTipo in ('6830','7729')) THEN 
						SELECT DISTINCT fecha_mov, hora_mov
							INTO res_fechaMovimiento_ret, res_horaMovimiento_ret
						FROM bdicred:sd_movdia
						WHERE bdicred:sd_movdia.empresa = p_sNumeroEmpresa 
							AND num_credito = p_sNumeroCuenta 
							AND fecha_mov <= p_sFechaFinal 
							AND fecha_mov >= p_sFechaInicial-30
							AND bdicred:sd_movdia.folio_suc=resultado_folioSuc	
							AND bdicred:sd_movdia.transacc_suc='6801';  
					END IF;
					
					-- Obtener la fecha de Retenido del movimiento
					IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
						IF (resultado_claveTipo in ('6830','7729')) THEN 
							SELECT DISTINCT fecha_mov, hora_mov
								INTO res_fechaMovimiento_ret, res_horaMovimiento_ret
							FROM bdicred:sd_movhis 
							WHERE bdicred:sd_movhis.empresa = p_sNumeroEmpresa 
								AND num_credito = p_sNumeroCuenta 
								AND fecha_mov <= p_sFechaFinal 
								AND fecha_mov >= p_sFechaInicial-30
								AND bdicred:sd_movhis.folio_suc=resultado_folioSuc	
								AND bdicred:sd_movhis.transacc_suc='6801';  
						END IF;
					END IF;
					
					IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
						LET res_fechaMovimiento_ret=res_fechaMovimiento_re1;
						LET res_horaMovimiento_ret=res_horaMovimiento_re1;							
					END IF;
					----------TERMINO AGREGADO-------------

					RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret WITH RESUME;

				END FOREACH;
			END IF; --IF p_sMonto IS NULL OR p_sMonto = 0 THEN
		END IF; --IF(p_sTarjeta IS NOT NULL AND p_sTarjeta <> '') THEN
	
	ELSE --IF(ids_transacciones IS NOT NULL) THEN
	
		IF(p_sTarjeta IS NOT NULL AND p_sTarjeta <> '') THEN
			IF p_sMonto IS NULL OR p_sMonto = 0 THEN
				FOREACH       
					SELECT SKIP p_skip DISTINCT fecha_mov, hora_mov, monto, folio_suc, bdinteg:si_sucursales.sucursal, nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, LPAD (referencia23,23,"0"), reversado, referencia, fecha_mov, hora_mov
						INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret
					FROM bdicred:sd_movdia 
						LEFT JOIN bdicred:sd_transfun ON (bdicred:sd_movdia.codigo_fun = bdicred:sd_transfun.codigo_fun 
							and bdicred:sd_movdia.codigo_ref = bdicred:sd_transfun.codigo_ref) 
						LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa 
								AND bdinteg:si_sucursales.sucursal = bdicred:sd_movdia.sucursal) 
						LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.numero = bdicred:sd_transfun.transacc 
								AND bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdicred:sd_transfun.transacc <> '0801') 
					WHERE num_credito = p_sNumeroCuenta 
						AND fecha_mov <= p_sFechaFinal 
						AND fecha_mov >= p_sFechaInicial
						AND nro_tarjeta = p_sTarjeta-- OR nro_tarjeta = '' OR nro_tarjeta IS NULL)
						AND bdicred:sd_transfun.transacc <> '0801'
						AND bdicred:sd_movdia.reversado <>'S'
						AND bdicred:sd_movdia.transacc_suc not in ('6801','7380','7381','7383','7384','7729','7730')
					ORDER BY folio_suc ASC, fecha_mov ASC
					
					IF (resultado_claveTipo IN ('6900','6800','6871','6872','6873','6830','6887')) THEN
						select monto
							into saldo_favor
						FROM bdicred:sd_movdia 
						WHERE num_credito = p_sNumeroCuenta 
							AND fecha_mov <= p_sFechaFinal 
							AND fecha_mov >= p_sFechaInicial
							AND nro_tarjeta = p_sTarjeta --OR nro_tarjeta = '' OR nro_tarjeta IS NULL)
							AND bdicred:sd_movdia.empresa = p_sNumeroEmpresa
							AND folio_suc = resultado_folioSuc
							AND bdicred:sd_movdia.transacc_suc <> '6801'
							AND bdicred:sd_movdia.transacc_suc in ('7380','7381','7382','7383','7384','7729','7730');

						IF saldo_favor IS NULL THEN 
							let saldo_favor = 0;
						end if;
							
						let resultado_monto = resultado_monto + saldo_favor;
							
					END IF;
					-----------------AGREGADO-----------------------------------
					LET res_fechaMovimiento_re1=res_fechaMovimiento_ret;
					LET res_horaMovimiento_re1=res_horaMovimiento_ret;								
					
					IF (resultado_claveTipo in ('6830','7729')) THEN 
						SELECT DISTINCT fecha_mov, hora_mov
							INTO res_fechaMovimiento_ret, res_horaMovimiento_ret
						FROM bdicred:sd_movdia
						WHERE bdicred:sd_movdia.empresa = p_sNumeroEmpresa 
							AND num_credito = p_sNumeroCuenta 
							AND fecha_mov <= p_sFechaFinal 
							AND fecha_mov >= p_sFechaInicial-30
							AND bdicred:sd_movdia.folio_suc=resultado_folioSuc	
							AND bdicred:sd_movdia.transacc_suc='6801';  
					END IF;
					
					-- Obtener la fecha de Retenido del movimiento
					IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
						IF (resultado_claveTipo in ('6830','7729')) THEN 
							SELECT DISTINCT fecha_mov, hora_mov
								INTO res_fechaMovimiento_ret, res_horaMovimiento_ret
							FROM bdicred:sd_movhis 
							WHERE bdicred:sd_movhis.empresa = p_sNumeroEmpresa 
								AND num_credito = p_sNumeroCuenta 
								AND fecha_mov <= p_sFechaFinal 
								AND fecha_mov >= p_sFechaInicial-30
								AND bdicred:sd_movhis.folio_suc=resultado_folioSuc	
								AND bdicred:sd_movhis.transacc_suc='6801';  
						END IF;
					END IF;
					
					IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
						LET res_fechaMovimiento_ret=res_fechaMovimiento_re1;
						LET res_horaMovimiento_ret=res_horaMovimiento_re1;							
					END IF;
					----------TERMINO AGREGADO-------------

					RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret WITH RESUME;
					
				END FOREACH;
			ELSE --IF p_sMonto IS NULL OR p_sMonto = 0 THEN
				FOREACH       
					SELECT SKIP p_skip DISTINCT fecha_mov, hora_mov, monto, folio_suc, bdinteg:si_sucursales.sucursal, nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, LPAD (referencia23,23,"0"), reversado, referencia, fecha_mov, hora_mov
						INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret
					FROM bdicred:sd_movdia 
						LEFT JOIN bdicred:sd_transfun ON (bdicred:sd_movdia.codigo_fun = bdicred:sd_transfun.codigo_fun 
							and bdicred:sd_movdia.codigo_ref = bdicred:sd_transfun.codigo_ref)  
						LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa 
								AND bdinteg:si_sucursales.sucursal = bdicred:sd_movdia.sucursal) 
						LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.numero = bdicred:sd_transfun.transacc 
								AND bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdicred:sd_transfun.transacc <> '0801')
					WHERE  num_credito = p_sNumeroCuenta 
						AND fecha_mov <= p_sFechaFinal 
						AND fecha_mov >= p_sFechaInicial 
						AND monto = p_sMonto
						AND nro_tarjeta = p_sTarjeta --OR nro_tarjeta = '' OR nro_tarjeta IS NULL)
						AND bdicred:sd_transfun.transacc <> '0801'
						AND bdicred:sd_movdia.transacc_suc <> '6801'
						AND bdicred:sd_movdia.reversado <>'S'
					ORDER BY folio_suc ASC, fecha_mov ASC
					
					-----------------AGREGADO-----------------------------------
					LET res_fechaMovimiento_re1=res_fechaMovimiento_ret;
					LET res_horaMovimiento_re1=res_horaMovimiento_ret;								
					
					IF (resultado_claveTipo in ('6830','7729')) THEN 
						SELECT DISTINCT fecha_mov, hora_mov
							INTO res_fechaMovimiento_ret, res_horaMovimiento_ret
						FROM bdicred:sd_movdia
						WHERE bdicred:sd_movdia.empresa = p_sNumeroEmpresa 
							AND num_credito = p_sNumeroCuenta 
							AND fecha_mov <= p_sFechaFinal 
							AND fecha_mov >= p_sFechaInicial-30
							AND bdicred:sd_movdia.folio_suc=resultado_folioSuc	
							AND bdicred:sd_movdia.transacc_suc='6801';  
					END IF;
					
					-- Obtener la fecha de Retenido del movimiento
					IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
						IF (resultado_claveTipo in ('6830','7729')) THEN 
							SELECT DISTINCT fecha_mov, hora_mov
								INTO res_fechaMovimiento_ret, res_horaMovimiento_ret
							FROM bdicred:sd_movhis 
							WHERE bdicred:sd_movhis.empresa = p_sNumeroEmpresa 
								AND num_credito = p_sNumeroCuenta 
								AND fecha_mov <= p_sFechaFinal 
								AND fecha_mov >= p_sFechaInicial-30
								AND bdicred:sd_movhis.folio_suc=resultado_folioSuc	
								AND bdicred:sd_movhis.transacc_suc='6801';  
						END IF;
					END IF;
					
					IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
						LET res_fechaMovimiento_ret=res_fechaMovimiento_re1;
						LET res_horaMovimiento_ret=res_horaMovimiento_re1;							
					END IF;
					----------TERMINO AGREGADO-------------

					RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret WITH RESUME;

				END FOREACH;
			END IF; --IF p_sMonto IS NULL OR p_sMonto = 0 THEN       
		ELSE --IF(p_sTarjeta IS NOT NULL AND p_sTarjeta <> '') THEN
			IF p_sMonto IS NULL OR p_sMonto = 0 THEN
				FOREACH       
					SELECT SKIP p_skip DISTINCT fecha_mov, hora_mov, monto, folio_suc, bdinteg:si_sucursales.sucursal, nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, LPAD (referencia23,23,"0"), reversado, referencia, fecha_mov, hora_mov
						INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret
					FROM bdicred:sd_movdia 
						LEFT JOIN bdicred:sd_transfun ON (bdicred:sd_movdia.codigo_fun = bdicred:sd_transfun.codigo_fun 
							and bdicred:sd_movdia.codigo_ref = bdicred:sd_transfun.codigo_ref) 
						LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa 
							AND bdinteg:si_sucursales.sucursal = bdicred:sd_movdia.sucursal) 
						LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.numero = bdicred:sd_transfun.transacc 
							AND bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdicred:sd_transfun.transacc <> '0801') 
					WHERE num_credito = p_sNumeroCuenta 
						AND fecha_mov <= p_sFechaFinal 
						AND fecha_mov >= p_sFechaInicial
						--AND (nro_tarjeta = '' OR nro_tarjeta IS NULL)
						AND bdicred:sd_transfun.transacc <> '0801'
						AND bdicred:sd_movdia.reversado <>'S'
						AND bdicred:sd_movdia.transacc_suc not in ('6801','7380','7381','7383','7384','7729','7730')
					ORDER BY folio_suc ASC, fecha_mov ASC
					
					IF (resultado_claveTipo IN ('6900','6800','6871','6872','6873','6830','6887')) THEN
						select monto
							into saldo_favor
						FROM bdicred:sd_movdia
						WHERE num_credito = p_sNumeroCuenta 
							AND fecha_mov <= p_sFechaFinal 
							AND fecha_mov >= p_sFechaInicial
							--AND (nro_tarjeta = '' OR nro_tarjeta IS NULL)
							AND bdicred:sd_movdia.empresa = p_sNumeroEmpresa
							AND folio_suc = resultado_folioSuc
							AND bdicred:sd_movdia.transacc_suc <> '6801'
							AND bdicred:sd_movdia.transacc_suc in ('7380','7381','7382','7383','7384','7729','7730');

						IF saldo_favor IS NULL THEN 
							let saldo_favor = 0;
						end if;
							
						let resultado_monto = resultado_monto + saldo_favor;
					END IF;
					-----------------AGREGADO-----------------------------------
					LET res_fechaMovimiento_re1=res_fechaMovimiento_ret;
					LET res_horaMovimiento_re1=res_horaMovimiento_ret;								
					
					IF (resultado_claveTipo in ('6830','7729')) THEN 
						SELECT DISTINCT fecha_mov, hora_mov
							INTO res_fechaMovimiento_ret, res_horaMovimiento_ret
						FROM bdicred:sd_movdia
						WHERE bdicred:sd_movdia.empresa = p_sNumeroEmpresa 
							AND num_credito = p_sNumeroCuenta 
							AND fecha_mov <= p_sFechaFinal 
							AND fecha_mov >= p_sFechaInicial-30
							AND bdicred:sd_movdia.folio_suc=resultado_folioSuc	
							AND bdicred:sd_movdia.transacc_suc='6801';  
					END IF;
					
					-- Obtener la fecha de Retenido del movimiento
					IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
						IF (resultado_claveTipo in ('6830','7729')) THEN 
							SELECT DISTINCT fecha_mov, hora_mov
								INTO res_fechaMovimiento_ret, res_horaMovimiento_ret
							FROM bdicred:sd_movhis 
							WHERE bdicred:sd_movhis.empresa = p_sNumeroEmpresa 
								AND num_credito = p_sNumeroCuenta 
								AND fecha_mov <= p_sFechaFinal 
								AND fecha_mov >= p_sFechaInicial-30
								AND bdicred:sd_movhis.folio_suc=resultado_folioSuc	
								AND bdicred:sd_movhis.transacc_suc='6801';  
						END IF;
					END IF;
					
					IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
						LET res_fechaMovimiento_ret=res_fechaMovimiento_re1;
						LET res_horaMovimiento_ret=res_horaMovimiento_re1;							
					END IF;
					----------TERMINO AGREGADO-------------

					RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret WITH RESUME;

				END FOREACH;
			ELSE --IF p_sMonto IS NULL OR p_sMonto = 0 THEN
				FOREACH       
					SELECT SKIP p_skip DISTINCT fecha_mov, hora_mov, monto, folio_suc, bdinteg:si_sucursales.sucursal, nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, LPAD (referencia23,23,"0"), reversado, referencia, fecha_mov, hora_mov
						INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret
					FROM bdicred:sd_movdia 
						LEFT JOIN bdicred:sd_transfun ON (bdicred:sd_movdia.codigo_fun = bdicred:sd_transfun.codigo_fun 
							and bdicred:sd_movdia.codigo_ref = bdicred:sd_transfun.codigo_ref)  
						LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa 
							AND bdinteg:si_sucursales.sucursal = bdicred:sd_movdia.sucursal) 
						LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.numero = bdicred:sd_transfun.transacc 
							AND bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdicred:sd_transfun.transacc <> '0801')
					WHERE  num_credito = p_sNumeroCuenta 
						AND fecha_mov <= p_sFechaFinal 
						AND fecha_mov >= p_sFechaInicial 
						--AND (nro_tarjeta = '' OR nro_tarjeta IS NULL)
						AND monto = p_sMonto
						AND bdicred:sd_transfun.transacc <> '0801'
						AND bdicred:sd_movdia.transacc_suc <> '6801'
						AND bdicred:sd_movdia.reversado <>'S'
					ORDER BY folio_suc ASC, fecha_mov ASC
					-----------------AGREGADO-----------------------------------
					LET res_fechaMovimiento_re1=res_fechaMovimiento_ret;
					LET res_horaMovimiento_re1=res_horaMovimiento_ret;								
					
					IF (resultado_claveTipo in ('6830','7729')) THEN 
						SELECT DISTINCT fecha_mov, hora_mov
							INTO res_fechaMovimiento_ret, res_horaMovimiento_ret
						FROM bdicred:sd_movdia
						WHERE bdicred:sd_movdia.empresa = p_sNumeroEmpresa 
							AND num_credito = p_sNumeroCuenta 
							AND fecha_mov <= p_sFechaFinal 
							AND fecha_mov >= p_sFechaInicial-30
							AND bdicred:sd_movdia.folio_suc=resultado_folioSuc	
							AND bdicred:sd_movdia.transacc_suc='6801';  
					END IF;
					
					-- Obtener la fecha de Retenido del movimiento
					IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
						IF (resultado_claveTipo in ('6830','7729')) THEN 
							SELECT DISTINCT fecha_mov, hora_mov
								INTO res_fechaMovimiento_ret, res_horaMovimiento_ret
							FROM bdicred:sd_movhis 
							WHERE bdicred:sd_movhis.empresa = p_sNumeroEmpresa 
								AND num_credito = p_sNumeroCuenta 
								AND fecha_mov <= p_sFechaFinal 
								AND fecha_mov >= p_sFechaInicial-30
								AND bdicred:sd_movhis.folio_suc=resultado_folioSuc	
								AND bdicred:sd_movhis.transacc_suc='6801';  
						END IF;
					END IF;
					
					IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
						LET res_fechaMovimiento_ret=res_fechaMovimiento_re1;
						LET res_horaMovimiento_ret=res_horaMovimiento_re1;							
					END IF;
					----------TERMINO AGREGADO-------------

					RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret WITH RESUME;

				END FOREACH;
			END IF; --IF p_sMonto IS NULL OR p_sMonto = 0 THEN
		END IF; --IF(p_sTarjeta IS NOT NULL AND p_sTarjeta <> '') THEN
	END IF; --IF(ids_transacciones IS NOT NULL) THEN
END 
END PROCEDURE
DOCUMENT
'Sp para búsqueda de movimientos de Crédito',
'Aclaraciones',
'Modifica : Rey David Zavala Garcia',
'Se agrega la Transaccion 7382 en busqueda de Movimientos',
'MODIFICA: Jorge Alberto Lara Mendoza',
'Se agrega la busqueda de movimientos correspondientes a Credito Coppel Masterd Card.',
'FECHA: 01/Septiembre/2022',
'Area: Sistemas Administrativos y Perifericos',
'Gerencia de Mtto y Soporte IV',
'Coordinador:Norberto Corona Berruecos',
'FECHA : 21/Septiembre/2018',
'VERSION: 1.0.2',
'BD    :  bdinteg';

CREATE PROCEDURE "informix".sp_buscar_movimientos_credito_his3(p_sNumeroCuenta CHAR(30), p_sFechaInicial DATE, p_sFechaFinal DATE, p_sMonto money(16,2), p_skip INT, p_sTarjeta CHAR(30), ids_transacciones lvarchar, p_sNumeroEmpresa CHAR(3))

     RETURNING	DATE AS fechaMovimiento, DATETIME HOUR TO FRACTION(3) AS horaMovimiento , money(16,2) AS monto, CHAR(30) AS folioSuc, CHAR(4) AS sucursal, CHAR(30) AS nombre, CHAR(5) AS claveTipo, CHAR(40) AS tipo, CHAR(30) AS referencia23, CHAR(1) AS reversado, CHAR(40) AS refComercio, DATE AS fechacConsumo, DATETIME HOUR TO FRACTION(3) AS horaConsumo;

	--definicion de variables--	    
	DEFINE resultado_fechaMovimiento    DATE;
	DEFINE resultado_monto				money(16,2);
    DEFINE saldo_favor    				money(16,2);
	DEFINE resultado_horaMovimiento		DATETIME HOUR TO FRACTION(3);
	DEFINE resultado_folioSuc			CHAR(30);
	DEFINE folio_operacion				CHAR(30);
    DEFINE resultado_sucursal			CHAR(4);
   	DEFINE resultado_nombre           	CHAR(30);
   	DEFINE resultado_claveTipo        	CHAR(5);
    DEFINE resultado_tipo   			CHAR(40);
    DEFINE resultado_referencia23		CHAR(30);
    DEFINE resultado_reversado			CHAR(1);
	DEFINE resultado_refComercio        CHAR(40);
    DEFINE transacciones 				LIST(CHAR(4) NOT NULL);
    DEFINE iSqlErr                  	INTEGER; 
	DEFINE vTransaccion					CHAR(5);
	DEFINE v_cont_tran					INTEGER;
	DEFINE folio_SAFA					CHAR(30);
	DEFINE folio_op_cor					CHAR(30);
	DEFINE res_fechaMovimiento_ret    	DATE;
	DEFINE res_horaMovimiento_ret		DATETIME HOUR TO FRACTION(3);
	DEFINE res_fechaMovimiento_re1	 	DATE;
	DEFINE res_horaMovimiento_re1	 	DATETIME HOUR TO FRACTION(3);	
	DEFINE bin_tdc_coppel_mc            CHAR(6);	--JLM/GIV/14092022
	
     -- Inicializacion de las variables.
	LET resultado_fechaMovimiento = '';
	LET resultado_monto = '';
    LET saldo_favor = '';
	LET resultado_horaMovimiento = TO_DATE("00:00","%H:%M");
	LET resultado_folioSuc = '';
	LET folio_operacion = '';
	LET folio_SAFA = '';
	LET folio_op_cor = '';
    LET resultado_sucursal = '';
    LET resultado_nombre = '';
    LET resultado_claveTipo = '';
	LET resultado_tipo = '';
    LET resultado_referencia23 = '';
    LET resultado_reversado = '';
	LET resultado_refComercio = '';
   	LET transacciones = 'LIST{' || ids_transacciones || '}';
	LET vTransaccion = '';
	LET res_fechaMovimiento_ret = '';
	LET res_horaMovimiento_ret  = TO_DATE("00:00","%H:%M");
	LET res_fechaMovimiento_re1 = '';
	LET res_horaMovimiento_re1  = TO_DATE("00:00","%H:%M");
	LET bin_tdc_coppel_mc		 = '';  --JLM/GIV/14092022
	
SET ISOLATION TO DIRTY READ;
--SET ISOLATION TO COMMITTED READ ;
SET LOCK MODE TO WAIT 3;

     --SET DEBUG FILE TO "/resplogifx/VJMP/Diversos/skip_cred/trace/sp_buscar_movimientos_credito_his3_vjmp_"||trim(p_sNumeroCuenta)||".out";
     --TRACE ON;
     
/* Se modifica Sp para agregar en la busqueda de movimientos la transacción 7382 solicitada por el usario del area de aclaraciones 
el dia 21/09/2018*/

	BEGIN

        ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET resultado_fechaMovimiento = '';
                    LET resultado_monto = '';
                    LET saldo_favor = '';
                    LET resultado_horaMovimiento = TO_DATE("00:00","%H:%M");
                    LET resultado_folioSuc = '';
                    LET resultado_sucursal = '';
                    LET resultado_nombre = '';
                    LET resultado_claveTipo = '';
                    LET resultado_tipo = '';
                    LET resultado_referencia23 = LPAD (resultado_referencia23,23,"0");
                    LET resultado_reversado = '';
					LET resultado_refComercio = '';
					LET res_fechaMovimiento_ret = '';
					LET res_horaMovimiento_ret  = TO_DATE("00:00","%H:%M");					
                    RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret;
                END IF;
        END EXCEPTION;

		--JLM/GIV/14092022
		
		SELECT bin into bin_tdc_coppel_mc FROM  intercard:binproducto WHERE idbinproducto = 174; -- bin= 514014
		
		IF SUBSTRING(p_sTarjeta FROM 1 FOR 6) = bin_tdc_coppel_mc THEN
			FOREACH		
				EXECUTE PROCEDURE bdinteg:"informix".sp_buscar_movimientos_his_credito_mc(p_sNumeroCuenta, p_sFechaInicial, p_sFechaFinal, p_sMonto, p_skip, p_sTarjeta, ids_transacciones, p_sNumeroEmpresa)
				INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret
				RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret WITH RESUME;
			END FOREACH;
	    END IF;
		--JLM/GIV/14092022
		
        IF(ids_transacciones IS NOT NULL) THEN
			
        	IF(p_sTarjeta IS NOT NULL AND p_sTarjeta <> '') THEN
				IF (p_sMonto IS NULL OR p_sMonto = 0 OR p_sMonto ='') THEN
					FOREACH				     	
					SELECT SKIP p_skip DISTINCT fecha_mov, hora_mov, monto, folio_suc, bdinteg:si_sucursales.sucursal, nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, LPAD (referencia23,23,"0"), reversado, referencia, fecha_mov, hora_mov
				          INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret
				          FROM bdicred:sd_movhis 
	                        LEFT JOIN bdicred:sd_transfun ON (bdicred:sd_transfun.empresa = p_sNumeroEmpresa AND bdicred:sd_movhis.codigo_fun = bdicred:sd_transfun.codigo_fun AND bdicred:sd_movhis.codigo_ref = bdicred:sd_transfun.codigo_ref) 
	                        LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa AND bdinteg:si_sucursales.sucursal = bdicred:sd_movhis.sucursal) 
	                        LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdinteg:si_transacc.numero = bdicred:sd_transfun.transacc AND bdicred:sd_transfun.transacc <> '0801') 
				          WHERE num_credito = p_sNumeroCuenta 
	                        AND fecha_mov <= p_sFechaFinal 
	                        AND fecha_mov >= p_sFechaInicial
                            AND (nro_tarjeta = p_sTarjeta OR nro_tarjeta = '' OR nro_tarjeta IS NULL)
	                        AND bdicred:sd_transfun.transacc <> '0801'
							AND bdicred:sd_movhis.reversado <>'S'
							AND bdicred:sd_movhis.transacc_suc not in ('6801','7380','7381','7383','7384','6881')
                            AND bdicred:sd_movhis.empresa = p_sNumeroEmpresa
							ORDER BY folio_suc,fecha_mov
							
						 SELECT count(bdicred:sd_movhis.transacc_suc) 
							INTO  v_cont_tran
						 FROM bdicred:sd_movhis
						 WHERE empresa='001'
							AND num_credito=p_sNumeroCuenta
							AND fecha_mov between p_sFechaInicial and p_sFechaFinal
							AND folio_suc=resultado_folioSuc
							AND transacc_suc in ('6900','6800','6871','6872','6873','6830','7729','7730','7380','7381','7382','7383','7384','6887') 
							AND transacc_suc not in ('6801','0801');
						 
						 LET folio_operacion=resultado_folioSuc;
						 LET folio_op_cor=substr(resultado_folioSuc, 0,9)||substr(resultado_folioSuc, 11,6);
						 
						 
						-- Para consideraciones de movimientos con sólo saldo a favor
							IF (v_cont_tran=1 ) THEN
			
							SELECT SKIP 0 DISTINCT fecha_mov, hora_mov, monto, folio_suc, bdinteg:si_sucursales.sucursal, nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, LPAD (referencia23,23,"0"), reversado, referencia, fecha_mov, hora_mov
								INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret
							FROM bdicred:sd_movhis 
								LEFT JOIN bdicred:sd_transfun ON (bdicred:sd_transfun.empresa = p_sNumeroEmpresa AND bdicred:sd_movhis.codigo_fun = bdicred:sd_transfun.codigo_fun AND bdicred:sd_movhis.codigo_ref = bdicred:sd_transfun.codigo_ref) 
								LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa AND bdinteg:si_sucursales.sucursal = bdicred:sd_movhis.sucursal) 
								LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdinteg:si_transacc.numero = bdicred:sd_transfun.transacc AND bdicred:sd_transfun.transacc <> '0801') 
							WHERE num_credito = p_sNumeroCuenta 
								AND fecha_mov <= p_sFechaFinal 
								AND fecha_mov >= p_sFechaInicial
								AND (nro_tarjeta = p_sTarjeta OR nro_tarjeta = '' OR nro_tarjeta IS NULL)
								AND bdicred:sd_transfun.transacc <> '0801'
								AND bdicred:sd_transfun.transacc <> '6801'
								AND bdicred:sd_movhis.transacc_suc in ('7380','7381','7382','7383','7384','7729','7730')
								AND bdicred:sd_transfun.transacc IN transacciones
								AND bdicred:sd_movhis.empresa = p_sNumeroEmpresa
								AND bdicred:sd_movhis.reversado <>'S'
								AND bdicred:sd_movhis.folio_suc=folio_operacion;
								
								LET res_fechaMovimiento_re1=res_fechaMovimiento_ret;
								LET res_horaMovimiento_re1=res_horaMovimiento_ret;								
								
								-- Obtener la fecha de Retenido del movimiento
								IF (resultado_claveTipo in ('6830','7729')) THEN 
								SELECT DISTINCT fecha_mov, hora_mov
									INTO res_fechaMovimiento_ret, res_horaMovimiento_ret
								FROM bdicred:sd_movhis 
								WHERE bdicred:sd_movhis.empresa = p_sNumeroEmpresa 
									AND num_credito = p_sNumeroCuenta 
									AND fecha_mov <= p_sFechaFinal 
									AND fecha_mov >= p_sFechaInicial-30
									AND bdicred:sd_movhis.folio_suc=resultado_folioSuc	
									AND bdicred:sd_movhis.transacc_suc='6801';  
								END IF;	 
							
								IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
									LET res_fechaMovimiento_ret=res_fechaMovimiento_re1;
									LET res_horaMovimiento_ret=res_horaMovimiento_re1;							
								END IF;
							
								IF 	(resultado_folioSuc is not null AND resultado_claveTipo not in ('8071','8072') )	THEN
								RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret WITH RESUME;
								END IF;
							
							END IF;
							
							
						IF ( folio_SAFA<>folio_op_cor ) THEN 
						
						FOREACH
						SELECT /*SKIP p_skip*/ DISTINCT fecha_mov, hora_mov, monto, folio_suc, bdinteg:si_sucursales.sucursal, nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, LPAD (referencia23,23,"0"), reversado, referencia, fecha_mov, hora_mov
				          INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret 
				        FROM bdicred:sd_movhis 
	                      LEFT JOIN bdicred:sd_transfun ON (bdicred:sd_transfun.empresa = p_sNumeroEmpresa AND bdicred:sd_movhis.codigo_fun = bdicred:sd_transfun.codigo_fun AND bdicred:sd_movhis.codigo_ref = bdicred:sd_transfun.codigo_ref) 
	                      LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa AND bdinteg:si_sucursales.sucursal = bdicred:sd_movhis.sucursal) 
	                      LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdinteg:si_transacc.numero = bdicred:sd_transfun.transacc AND bdicred:sd_transfun.transacc <> '0801') 
						WHERE num_credito = p_sNumeroCuenta 
	                      AND fecha_mov <= p_sFechaFinal 
	                      AND fecha_mov >= p_sFechaInicial
	                      AND (nro_tarjeta = p_sTarjeta OR nro_tarjeta = '' OR nro_tarjeta IS NULL)
	                      AND bdicred:sd_transfun.transacc <> '0801'
	                      AND bdicred:sd_movhis.transacc_suc not in ('6801','7380','7381','7384','7729','7730','6881') -- Se agregó 6881
	                      AND bdicred:sd_transfun.transacc IN transacciones
                          AND bdicred:sd_movhis.empresa = p_sNumeroEmpresa
						  AND bdicred:sd_movhis.reversado <>'S'
						  AND substr(bdicred:sd_movhis.folio_suc, 0,9)||substr(bdicred:sd_movhis.folio_suc, 11,6)=folio_op_cor							
	                    ORDER BY folio_suc ASC, fecha_mov ASC
						  
						  
							IF (resultado_claveTipo IN ('6900','6800','6871','6872','6873','6830','6887')) THEN  -- se agrego 6887
								SELECT monto
									INTO saldo_favor
                                FROM bdicred:sd_movhis 
                                WHERE num_credito = p_sNumeroCuenta 
									AND fecha_mov <= p_sFechaFinal 
									AND fecha_mov >= p_sFechaInicial
									AND (nro_tarjeta = p_sTarjeta OR nro_tarjeta = '' OR nro_tarjeta IS NULL)
									AND bdicred:sd_movhis.empresa = p_sNumeroEmpresa
									AND folio_suc = resultado_folioSuc
									AND bdicred:sd_movhis.transacc_suc <> '6801'
									AND bdicred:sd_movhis.transacc_suc in ('7380','7381','7382','7383','7384','7729','7730');

                                IF (saldo_favor IS NULL) THEN 
                                    let saldo_favor = 0;
                                end if;
                                
                                let resultado_monto = resultado_monto + saldo_favor;
                               
							END IF;

							LET res_fechaMovimiento_re1=res_fechaMovimiento_ret;
							LET res_horaMovimiento_re1=res_horaMovimiento_ret;							
								-- Obtener la fecha de Retenido del movimiento
								IF (resultado_claveTipo in ('6830','7729')) THEN 
								SELECT DISTINCT fecha_mov, hora_mov
									INTO res_fechaMovimiento_ret, res_horaMovimiento_ret
								FROM bdicred:sd_movhis 
								WHERE bdicred:sd_movhis.empresa = p_sNumeroEmpresa 
									AND num_credito = p_sNumeroCuenta 
									AND fecha_mov <= p_sFechaFinal 
									AND fecha_mov >= p_sFechaInicial-30
									AND bdicred:sd_movhis.folio_suc=resultado_folioSuc	
									AND bdicred:sd_movhis.transacc_suc='6801';  
								END IF;	
								
							IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
								LET res_fechaMovimiento_ret=res_fechaMovimiento_re1;
								LET res_horaMovimiento_ret=res_horaMovimiento_re1;							
							END IF;
						  
						IF (resultado_folioSuc is not null AND resultado_claveTipo not in ('8071','8072')) THEN	
							RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret WITH RESUME;
						END IF;	
						
						LET folio_SAFA=substr(resultado_folioSuc, 0,9)||substr(resultado_folioSuc, 11,6);
						
						END FOREACH;
						
						END IF;						
							
					
					END FOREACH;
				ELSE
				IF (p_sMonto IS NOT NULL OR p_sMonto <>0 OR p_sMonto<>'') THEN
				
					FOREACH       
				     	SELECT SKIP p_skip DISTINCT fecha_mov, hora_mov, monto, folio_suc, bdinteg:si_sucursales.sucursal, nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, LPAD (referencia23,23,"0"), reversado, referencia, fecha_mov, hora_mov
				          INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret 
				          FROM bdicred:sd_movhis 
	                        LEFT JOIN bdicred:sd_transfun ON (bdicred:sd_transfun.empresa = p_sNumeroEmpresa AND bdicred:sd_movhis.codigo_fun = bdicred:sd_transfun.codigo_fun AND bdicred:sd_movhis.codigo_ref = bdicred:sd_transfun.codigo_ref)  
	                        LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa AND bdinteg:si_sucursales.sucursal = bdicred:sd_movhis.sucursal) 
	                        LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdinteg:si_transacc.numero = bdicred:sd_transfun.transacc AND bdicred:sd_transfun.transacc <> '0801')
							WHERE num_credito = p_sNumeroCuenta 
	                        AND fecha_mov <= p_sFechaFinal 
	                        AND fecha_mov >= p_sFechaInicial 
	                        AND monto = p_sMonto							
	                        AND (nro_tarjeta = p_sTarjeta OR nro_tarjeta = '' OR nro_tarjeta IS NULL)
	                        AND bdicred:sd_transfun.transacc <> '0801'
							AND bdicred:sd_movhis.transacc_suc <> '6801'
	                        AND bdicred:sd_transfun.transacc IN transacciones
                            AND bdicred:sd_movhis.empresa = p_sNumeroEmpresa
							AND bdicred:sd_movhis.reversado <>'S'
							ORDER BY folio_suc ASC, fecha_mov ASC
							
							LET vTransaccion = resultado_claveTipo;
													
						IF (vTransaccion IN ( '6900', '6800' , '6871' , '6872', '6873','6830','6887')) THEN
						FOREACH
							SELECT SKIP p_skip DISTINCT fecha_mov, hora_mov, monto, folio_suc, bdinteg:si_sucursales.sucursal, nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, LPAD (referencia23,23,"0"), reversado, referencia, fecha_mov, hora_mov
							INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret 
							FROM bdicred:sd_movhis 
	                        LEFT JOIN bdicred:sd_transfun ON (bdicred:sd_transfun.empresa = p_sNumeroEmpresa AND bdicred:sd_movhis.codigo_fun = bdicred:sd_transfun.codigo_fun AND bdicred:sd_movhis.codigo_ref = bdicred:sd_transfun.codigo_ref)  
	                        LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa AND bdinteg:si_sucursales.sucursal = bdicred:sd_movhis.sucursal) 
	                        LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdinteg:si_transacc.numero = bdicred:sd_transfun.transacc AND bdicred:sd_transfun.transacc <> '0801')
							WHERE num_credito = p_sNumeroCuenta 
							AND fecha_mov <= p_sFechaFinal 
	                        AND fecha_mov >= p_sFechaInicial
							AND bdicred:sd_movhis.transacc_suc <> '6801'
							AND bdicred:sd_movhis.reversado <>'S'
						    AND substr(folio_suc, 0,9)= substr(resultado_folioSuc, 0,9) 
							AND substr(folio_suc, 11,6)= substr(resultado_folioSuc, 11,6)						
			
							LET res_fechaMovimiento_re1=res_fechaMovimiento_ret;
							LET res_horaMovimiento_re1=res_horaMovimiento_ret;
			
							IF (trim(resultado_claveTipo) in ('6830','7729')) THEN 
								SELECT fecha_mov, hora_mov
									INTO res_fechaMovimiento_ret, res_horaMovimiento_ret
								FROM bdicred:sd_movhis 
								WHERE bdicred:sd_movhis.empresa = p_sNumeroEmpresa 
									AND num_credito = p_sNumeroCuenta 
									AND fecha_mov <= p_sFechaFinal 
									AND fecha_mov >= p_sFechaInicial
									AND substr(folio_suc, 0,9)= substr(resultado_folioSuc, 0,9) 
									AND substr(folio_suc, 11,6)= substr(resultado_folioSuc, 11,6)
									AND bdicred:sd_transfun.transacc='6801';
								END IF;						
							
								-- Obtener la fecha de Retenido del movimiento
								IF (resultado_claveTipo in ('6830','7729')) THEN 
								SELECT DISTINCT fecha_mov, hora_mov
									INTO res_fechaMovimiento_ret, res_horaMovimiento_ret
								FROM bdicred:sd_movhis 
								WHERE bdicred:sd_movhis.empresa = p_sNumeroEmpresa 
									AND num_credito = p_sNumeroCuenta 
									AND fecha_mov <= p_sFechaFinal 
									AND fecha_mov >= p_sFechaInicial-30
									AND bdicred:sd_movhis.folio_suc=resultado_folioSuc	
									AND bdicred:sd_movhis.transacc_suc='6801';  
								END IF;	
							
							IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
								LET res_fechaMovimiento_ret=res_fechaMovimiento_re1;
								LET res_horaMovimiento_ret=res_horaMovimiento_re1;							
							END IF;	

							
							IF (resultado_folioSuc is not null AND resultado_claveTipo not in ('8071','8072')) THEN	
							RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret WITH RESUME;
							END IF;
						END FOREACH;
						END IF;
												
						END FOREACH;
				END IF;
              END IF;
	       ELSE
		      IF (p_sMonto IS NULL OR p_sMonto = 0 OR p_sMonto='') THEN
					FOREACH       
				     	SELECT SKIP p_skip DISTINCT fecha_mov, hora_mov, monto, folio_suc, bdinteg:si_sucursales.sucursal, nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, LPAD (referencia23,23,"0"), reversado, referencia, fecha_mov, hora_mov
				          INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret 
				          FROM bdicred:sd_movhis 
	                        LEFT JOIN bdicred:sd_transfun ON (bdicred:sd_transfun.empresa = p_sNumeroEmpresa AND bdicred:sd_movhis.codigo_fun = bdicred:sd_transfun.codigo_fun AND bdicred:sd_movhis.codigo_ref = bdicred:sd_transfun.codigo_ref) 
	                        LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa AND bdinteg:si_sucursales.sucursal = bdicred:sd_movhis.sucursal) 
	                        LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdinteg:si_transacc.numero = bdicred:sd_transfun.transacc AND bdicred:sd_transfun.transacc <> '0801') 
				          WHERE num_credito = p_sNumeroCuenta 
	                        AND fecha_mov <= p_sFechaFinal 
	                        AND fecha_mov >= p_sFechaInicial
                            AND (nro_tarjeta = '' OR nro_tarjeta IS NULL)	
	                        AND bdicred:sd_transfun.transacc <> '0801'
	                        AND bdicred:sd_movhis.transacc_suc not in ('6801','7380','7381','7383','7384','7729','7730','6881')
	                        AND bdicred:sd_transfun.transacc IN transacciones
                            AND bdicred:sd_movhis.empresa = p_sNumeroEmpresa
							AND bdicred:sd_movhis.reversado <>'S'
	                      ORDER BY folio_suc ASC, fecha_mov ASC

                          IF (resultado_claveTipo IN ('6900','6800','6871','6872','6873','6830','6887')) THEN
                              select monto
                                into saldo_favor
                                FROM bdicred:sd_movhis 
                                WHERE num_credito = p_sNumeroCuenta 
                                AND fecha_mov <= p_sFechaFinal 
                                AND fecha_mov >= p_sFechaInicial
                                AND (nro_tarjeta = '' OR nro_tarjeta IS NULL)	
                                AND bdicred:sd_movhis.empresa = p_sNumeroEmpresa
                                AND folio_suc = resultado_folioSuc
								AND bdicred:sd_movhis.transacc_suc <> '6801'
                                AND bdicred:sd_movhis.transacc_suc in ('7380','7381','7382','7383','7384','7729','7730');

                                IF (saldo_favor IS NULL) THEN 
                                    let saldo_favor = 0;
                                end if;
                                
                                let resultado_monto = resultado_monto + saldo_favor;
							END IF;

							LET res_fechaMovimiento_re1=res_fechaMovimiento_ret;
							LET res_horaMovimiento_re1=res_horaMovimiento_ret;							
							
								-- Obtener la fecha de Retenido del movimiento
								IF (resultado_claveTipo in ('6830','7729')) THEN 
								SELECT DISTINCT fecha_mov, hora_mov
									INTO res_fechaMovimiento_ret, res_horaMovimiento_ret
								FROM bdicred:sd_movhis 
								WHERE bdicred:sd_movhis.empresa = p_sNumeroEmpresa 
									AND num_credito = p_sNumeroCuenta 
									AND fecha_mov <= p_sFechaFinal 
									AND fecha_mov >= p_sFechaInicial-30
									AND bdicred:sd_movhis.folio_suc=resultado_folioSuc	
									AND bdicred:sd_movhis.transacc_suc='6801';  
								END IF;	
								
							IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
								LET res_fechaMovimiento_ret=res_fechaMovimiento_re1;
								LET res_horaMovimiento_ret=res_horaMovimiento_re1;							
							END IF;
							
						IF (resultado_folioSuc is not null AND resultado_claveTipo not in ('8071','8072')) THEN	
							RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret WITH RESUME;
						END IF;	
						
					END FOREACH;
				ELSE
				IF (p_sMonto IS NOT NULL OR p_sMonto <>0 OR p_sMonto<>'') THEN
				
					FOREACH       
				     	SELECT SKIP p_skip DISTINCT fecha_mov, hora_mov, monto, folio_suc, bdinteg:si_sucursales.sucursal, nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, LPAD (referencia23,23,"0"), reversado, referencia, fecha_mov, hora_mov
				          INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret 
				          FROM bdicred:sd_movhis 
	                        LEFT JOIN bdicred:sd_transfun ON (bdicred:sd_transfun.empresa = p_sNumeroEmpresa AND bdicred:sd_movhis.codigo_fun = bdicred:sd_transfun.codigo_fun AND bdicred:sd_movhis.codigo_ref = bdicred:sd_transfun.codigo_ref)  
	                        LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa AND bdinteg:si_sucursales.sucursal = bdicred:sd_movhis.sucursal) 
	                        LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdinteg:si_transacc.numero = bdicred:sd_transfun.transacc AND bdicred:sd_transfun.transacc <> '0801')
				          WHERE  num_credito = p_sNumeroCuenta 
	                        AND fecha_mov <= p_sFechaFinal 
	                        AND fecha_mov >= p_sFechaInicial 
							AND monto = p_sMonto
                            AND (nro_tarjeta = '' OR nro_tarjeta IS NULL)
	                        AND bdicred:sd_transfun.transacc <> '0801'
	                        AND bdicred:sd_movhis.transacc_suc <> '6801'
	                        AND bdicred:sd_transfun.transacc IN transacciones
                            AND bdicred:sd_movhis.empresa = p_sNumeroEmpresa
							AND bdicred:sd_movhis.reversado <>'S'
	                      ORDER BY folio_suc ASC, fecha_mov ASC
						  
						LET vTransaccion = resultado_claveTipo;
						
											
						IF (vTransaccion IN ( '6900', '6800' , '6871' , '6872', '6873','6830','6887')) THEN
						FOREACH
							SELECT SKIP p_skip DISTINCT fecha_mov, hora_mov, monto, folio_suc, bdinteg:si_sucursales.sucursal, nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, LPAD (referencia23,23,"0"), reversado, referencia, fecha_mov, hora_mov
							INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret 
							FROM bdicred:sd_movhis 
	                        LEFT JOIN bdicred:sd_transfun ON (bdicred:sd_transfun.empresa = p_sNumeroEmpresa AND bdicred:sd_movhis.codigo_fun = bdicred:sd_transfun.codigo_fun AND bdicred:sd_movhis.codigo_ref = bdicred:sd_transfun.codigo_ref)  
	                        LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa AND bdinteg:si_sucursales.sucursal = bdicred:sd_movhis.sucursal) 
	                        LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdinteg:si_transacc.numero = bdicred:sd_transfun.transacc AND bdicred:sd_transfun.transacc <> '0801')
							WHERE num_credito = p_sNumeroCuenta 
							AND fecha_mov <= p_sFechaFinal 
	                        AND fecha_mov >= p_sFechaInicial
							AND bdicred:sd_movhis.transacc_suc <> '6801'
							AND substr(folio_suc, 0,9)= substr(resultado_folioSuc, 0,9) 
							AND substr(folio_suc, 11,6)= substr(resultado_folioSuc, 11,6)
							
						IF (resultado_folioSuc is not null AND resultado_claveTipo not in ('8071','8072')) THEN	
							RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret WITH RESUME;
						END IF;	
							END FOREACH;
						END IF;					
						
					END FOREACH;
				END IF;
	       END IF;
		END IF;
		END IF; 
	END 
END PROCEDURE
DOCUMENT
'Sp para búsqueda de movimientos de Crédito',
'Aclaraciones',
'Modifica : Rey David Zavala Garcia',
'Se agrega la Transaccion 7382 en busqueda de Movimientos',
'MODIFICA: Jorge Alberto Lara Mendoza',
'Se agrega la busqueda de movimientos correspondientes a Credito Coppel Masterd Card.',
'FECHA: 01/Septiembre/2022',
'Area: Sistemas Administrativos y Perifericos',
'Gerencia de Mtto y Soporte IV',
'Coordinador:Norberto Corona Berruecos',
'FECHA : 21/Septiembre/2018',
'MODIFICA: Mario Gonzalez Vazquez',
'Se modfica consulta de la linea 193 ya que se detecto que la consulta presentaba error en ciertos casos al paginar y no devolvia la infrmacion correctamente',
'FECHA: 27/Junio/2024',
'VERSION: 1.0.2',
'BD    :  bdinteg';

CREATE PROCEDURE "informix".sp_buscar_movimientos_creditocrd_his(p_sNumeroCuenta CHAR(30), p_sFechaInicial DATE, p_sFechaFinal DATE, p_sMonto money(16,2), p_skip INT, p_sTarjeta CHAR(30), ids_transacciones lvarchar, p_sNumeroEmpresa CHAR(3))

     RETURNING	DATE AS fechaMovimiento, DATETIME HOUR TO FRACTION(3) AS horaMovimiento , money(16,2) AS monto, CHAR(30) AS folioSuc, CHAR(4) AS sucursal, CHAR(30) AS nombre, CHAR(5) AS claveTipo, CHAR(40) AS tipo, CHAR(30) AS referencia23, CHAR(1) AS reversado, CHAR(40) AS refComercio, DATE AS fechacConsumo, DATETIME HOUR TO FRACTION(3) AS horaConsumo;

	--definicion de variables--	    
	DEFINE resultado_fechaMovimiento    DATE;
	DEFINE resultado_monto				money(16,2);
    DEFINE saldo_favor    				money(16,2);
	DEFINE resultado_horaMovimiento		DATETIME HOUR TO FRACTION(3);
	DEFINE resultado_folioSuc			CHAR(30);
	DEFINE folio_operacion				CHAR(30);
    DEFINE resultado_sucursal			CHAR(4);
   	DEFINE resultado_nombre           	CHAR(30);
   	DEFINE resultado_claveTipo        	CHAR(5);
    DEFINE resultado_tipo   			CHAR(40);
    DEFINE resultado_referencia23		CHAR(30);
    DEFINE resultado_reversado			CHAR(1);
	DEFINE resultado_refComercio        CHAR(40);
    DEFINE transacciones 				LIST(CHAR(4) NOT NULL);
    DEFINE iSqlErr                  	INTEGER; 
	DEFINE vTransaccion					CHAR(5);
	DEFINE v_cont_tran					INTEGER;
	DEFINE folio_SAFA					CHAR(30);
	DEFINE folio_op_cor					CHAR(30);
	DEFINE res_fechaMovimiento_ret    	DATE;
	DEFINE res_horaMovimiento_ret		DATETIME HOUR TO FRACTION(3);
	DEFINE res_fechaMovimiento_re1	 	DATE;
	DEFINE res_horaMovimiento_re1	 	DATETIME HOUR TO FRACTION(3);	
	
	
     -- Inicializacion de las variables.
	LET resultado_fechaMovimiento = '';
	LET resultado_monto = '';
    LET saldo_favor = '';
	LET resultado_horaMovimiento = TO_DATE("00:00","%H:%M");
	LET resultado_folioSuc = '';
	LET folio_operacion = '';
	LET folio_SAFA = '';
	LET folio_op_cor = '';
    LET resultado_sucursal = '';
    LET resultado_nombre = '';
    LET resultado_claveTipo = '';
	LET resultado_tipo = '';
    LET resultado_referencia23 = '';
    LET resultado_reversado = '';
	LET resultado_refComercio = '';
   	LET transacciones = 'LIST{' || ids_transacciones || '}';
	LET vTransaccion = '';
	LET res_fechaMovimiento_ret = '';
	LET res_horaMovimiento_ret  = TO_DATE("00:00","%H:%M");
	LET res_fechaMovimiento_re1 = '';
	LET res_horaMovimiento_re1  = TO_DATE("00:00","%H:%M");
	
--SET ISOLATION TO COMMITTED READ ;
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

    -- SET DEBUG FILE TO "/informix/BB/SAF/sp_buscar_movimientos_credito_his3_"||trim(p_sNumeroCuenta)||".out";
    -- TRACE ON;

	BEGIN

        ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET resultado_fechaMovimiento = '';
                    LET resultado_monto = '';
                    LET saldo_favor = '';
                    LET resultado_horaMovimiento = TO_DATE("00:00","%H:%M");
                    LET resultado_folioSuc = '';
                    LET resultado_sucursal = '';
                    LET resultado_nombre = '';
                    LET resultado_claveTipo = '';
                    LET resultado_tipo = '';
                    LET resultado_referencia23 = LPAD (resultado_referencia23,23,"0");
                    LET resultado_reversado = '';
					LET resultado_refComercio = '';
					LET res_fechaMovimiento_ret = '';
					LET res_horaMovimiento_ret  = TO_DATE("00:00","%H:%M");					
                    RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret;
                END IF;
        END EXCEPTION;

		
        IF(ids_transacciones IS NOT NULL) THEN
			
        	IF(p_sTarjeta IS NOT NULL AND p_sTarjeta <> '') THEN
				IF (p_sMonto IS NULL OR p_sMonto = 0 OR p_sMonto ='') THEN
					FOREACH				     	
					SELECT SKIP p_skip DISTINCT fecha_mov, hora_mov, monto, folio_suc, bdinteg:si_sucursales.sucursal, nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, LPAD (referencia23,23,"0"), reversado, referencia, fecha_mov, hora_mov
				          INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret
				          FROM bdicred:sd_movhiscrd 
	                        LEFT JOIN bdicred:sd_transfun ON (bdicred:sd_transfun.empresa = p_sNumeroEmpresa AND bdicred:sd_movhiscrd.codigo_fun = bdicred:sd_transfun.codigo_fun AND bdicred:sd_movhiscrd.codigo_ref = bdicred:sd_transfun.codigo_ref) 
	                        LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa AND bdinteg:si_sucursales.sucursal = bdicred:sd_movhiscrd.sucursal) 
	                        LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdinteg:si_transacc.numero = bdicred:sd_transfun.transacc AND bdicred:sd_transfun.transacc <> '0801') 
				          WHERE num_credito = p_sNumeroCuenta 
	                        AND fecha_mov <= p_sFechaFinal 
	                        AND fecha_mov >= p_sFechaInicial
                            AND (nro_tarjeta = p_sTarjeta OR nro_tarjeta = '' OR nro_tarjeta IS NULL)
	                        AND bdicred:sd_transfun.transacc <> '0801'
							AND bdicred:sd_movhiscrd.reversado <>'S'
							AND bdicred:sd_movhiscrd.transacc_suc not in ('6801','7380','7381','7383','7384','6881')
                            AND bdicred:sd_movhiscrd.empresa = p_sNumeroEmpresa
							ORDER BY folio_suc,fecha_mov
							
						 SELECT count(bdicred:sd_movhiscrd.transacc_suc) 
							INTO  v_cont_tran
						 FROM bdicred:sd_movhiscrd
						 WHERE empresa='001'
							AND num_credito=p_sNumeroCuenta
							AND fecha_mov between p_sFechaInicial and p_sFechaFinal
							AND folio_suc=resultado_folioSuc
							AND transacc_suc in ('6900','6800','6871','6872','6873','6830','7729','7730','7380','7381','7382','7383','7384','6887') 
							AND transacc_suc not in ('6801','0801');
						 
						 LET folio_operacion=resultado_folioSuc;
						 LET folio_op_cor=substr(resultado_folioSuc, 0,9)||substr(resultado_folioSuc, 11,6);
						 
						 
						-- Para consideraciones de movimientos con sólo saldo a favor
							IF (v_cont_tran=1 ) THEN
			
							SELECT SKIP p_skip DISTINCT fecha_mov, hora_mov, monto, folio_suc, bdinteg:si_sucursales.sucursal, nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, LPAD (referencia23,23,"0"), reversado, referencia, fecha_mov, hora_mov
								INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret
							FROM bdicred:sd_movhiscrd 
								LEFT JOIN bdicred:sd_transfun ON (bdicred:sd_transfun.empresa = p_sNumeroEmpresa AND bdicred:sd_movhiscrd.codigo_fun = bdicred:sd_transfun.codigo_fun AND bdicred:sd_movhiscrd.codigo_ref = bdicred:sd_transfun.codigo_ref) 
								LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa AND bdinteg:si_sucursales.sucursal = bdicred:sd_movhiscrd.sucursal) 
								LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdinteg:si_transacc.numero = bdicred:sd_transfun.transacc AND bdicred:sd_transfun.transacc <> '0801') 
							WHERE num_credito = p_sNumeroCuenta 
								AND fecha_mov <= p_sFechaFinal 
								AND fecha_mov >= p_sFechaInicial
								AND (nro_tarjeta = p_sTarjeta OR nro_tarjeta = '' OR nro_tarjeta IS NULL)
								AND bdicred:sd_transfun.transacc <> '0801'
								AND bdicred:sd_transfun.transacc <> '6801'
								AND bdicred:sd_movhiscrd.transacc_suc in ('7380','7381','7382','7383','7384','7729','7730')
								AND bdicred:sd_transfun.transacc IN transacciones
								AND bdicred:sd_movhiscrd.empresa = p_sNumeroEmpresa
								AND bdicred:sd_movhiscrd.reversado <>'S'
								AND bdicred:sd_movhiscrd.folio_suc=folio_operacion;
								
								LET res_fechaMovimiento_re1=res_fechaMovimiento_ret;
								LET res_horaMovimiento_re1=res_horaMovimiento_ret;								
								
								-- Obtener la fecha de Retenido del movimiento
								IF (resultado_claveTipo in ('6830','7729')) THEN 
								SELECT DISTINCT fecha_mov, hora_mov
									INTO res_fechaMovimiento_ret, res_horaMovimiento_ret
								FROM bdicred:sd_movhiscrd 
								WHERE bdicred:sd_movhiscrd.empresa = p_sNumeroEmpresa 
									AND num_credito = p_sNumeroCuenta 
									AND fecha_mov <= p_sFechaFinal 
									AND fecha_mov >= p_sFechaInicial-30
									AND bdicred:sd_movhiscrd.folio_suc=resultado_folioSuc	
									AND bdicred:sd_movhiscrd.transacc_suc='6801';  
								END IF;	 
							
								IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
									LET res_fechaMovimiento_ret=res_fechaMovimiento_re1;
									LET res_horaMovimiento_ret=res_horaMovimiento_re1;							
								END IF;
							
								IF 	(resultado_folioSuc is not null AND resultado_claveTipo not in ('8071','8072') )	THEN
								RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret WITH RESUME;
								END IF;
							
							END IF;
							
							
						IF ( folio_SAFA<>folio_op_cor ) THEN 
						
						FOREACH
						SELECT SKIP p_skip DISTINCT fecha_mov, hora_mov, monto, folio_suc, bdinteg:si_sucursales.sucursal, nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, LPAD (referencia23,23,"0"), reversado, referencia, fecha_mov, hora_mov
				          INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret 
				        FROM bdicred:sd_movhiscrd 
	                      LEFT JOIN bdicred:sd_transfun ON (bdicred:sd_transfun.empresa = p_sNumeroEmpresa AND bdicred:sd_movhiscrd.codigo_fun = bdicred:sd_transfun.codigo_fun AND bdicred:sd_movhiscrd.codigo_ref = bdicred:sd_transfun.codigo_ref) 
	                      LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa AND bdinteg:si_sucursales.sucursal = bdicred:sd_movhiscrd.sucursal) 
	                      LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdinteg:si_transacc.numero = bdicred:sd_transfun.transacc AND bdicred:sd_transfun.transacc <> '0801') 
						WHERE num_credito = p_sNumeroCuenta 
	                      AND fecha_mov <= p_sFechaFinal 
	                      AND fecha_mov >= p_sFechaInicial
	                      AND (nro_tarjeta = p_sTarjeta OR nro_tarjeta = '' OR nro_tarjeta IS NULL)
	                      AND bdicred:sd_transfun.transacc <> '0801'
	                      AND bdicred:sd_movhiscrd.transacc_suc not in ('6801','7380','7381','7383','7384','7729','7730','6881') -- Se agregó 6881
	                      AND bdicred:sd_transfun.transacc IN transacciones
                          AND bdicred:sd_movhiscrd.empresa = p_sNumeroEmpresa
						  AND bdicred:sd_movhiscrd.reversado <>'S'
						  AND substr(bdicred:sd_movhiscrd.folio_suc, 0,9)||substr(bdicred:sd_movhiscrd.folio_suc, 11,6)=folio_op_cor							
	                    ORDER BY folio_suc ASC, fecha_mov ASC
						  
						  
							IF (resultado_claveTipo IN ('6900','6800','6871','6872','6873','6830','6887')) THEN  -- se agrego 6887
								SELECT monto
									INTO saldo_favor
                                FROM bdicred:sd_movhiscrd 
                                WHERE num_credito = p_sNumeroCuenta 
									AND fecha_mov <= p_sFechaFinal 
									AND fecha_mov >= p_sFechaInicial
									AND (nro_tarjeta = p_sTarjeta OR nro_tarjeta = '' OR nro_tarjeta IS NULL)
									AND bdicred:sd_movhiscrd.empresa = p_sNumeroEmpresa
									AND folio_suc = resultado_folioSuc
									AND bdicred:sd_movhiscrd.transacc_suc <> '6801'
									AND bdicred:sd_movhiscrd.transacc_suc in ('7380','7381','7382','7383','7384','7729','7730');

                                IF (saldo_favor IS NULL) THEN 
                                    let saldo_favor = 0;
                                end if;
                                
                                let resultado_monto = resultado_monto + saldo_favor;
                               
							END IF;

							LET res_fechaMovimiento_re1=res_fechaMovimiento_ret;
							LET res_horaMovimiento_re1=res_horaMovimiento_ret;							
								-- Obtener la fecha de Retenido del movimiento
								IF (resultado_claveTipo in ('6830','7729')) THEN 
								SELECT DISTINCT fecha_mov, hora_mov
									INTO res_fechaMovimiento_ret, res_horaMovimiento_ret
								FROM bdicred:sd_movhiscrd 
								WHERE bdicred:sd_movhiscrd.empresa = p_sNumeroEmpresa 
									AND num_credito = p_sNumeroCuenta 
									AND fecha_mov <= p_sFechaFinal 
									AND fecha_mov >= p_sFechaInicial-30
									AND bdicred:sd_movhiscrd.folio_suc=resultado_folioSuc	
									AND bdicred:sd_movhiscrd.transacc_suc='6801';  
								END IF;	
								
							IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
								LET res_fechaMovimiento_ret=res_fechaMovimiento_re1;
								LET res_horaMovimiento_ret=res_horaMovimiento_re1;							
							END IF;
						  
						IF (resultado_folioSuc is not null AND resultado_claveTipo not in ('8071','8072')) THEN	
							RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret WITH RESUME;
						END IF;	
						
						LET folio_SAFA=substr(resultado_folioSuc, 0,9)||substr(resultado_folioSuc, 11,6);
						
						END FOREACH;
						
						END IF;						
							
					
					END FOREACH;
				ELSE
				IF (p_sMonto IS NOT NULL OR p_sMonto <>0 OR p_sMonto<>'') THEN
				
					FOREACH       
				     	SELECT SKIP p_skip DISTINCT fecha_mov, hora_mov, monto, folio_suc, bdinteg:si_sucursales.sucursal, nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, LPAD (referencia23,23,"0"), reversado, referencia, fecha_mov, hora_mov
				          INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret 
				          FROM bdicred:sd_movhiscrd 
	                        LEFT JOIN bdicred:sd_transfun ON (bdicred:sd_transfun.empresa = p_sNumeroEmpresa AND bdicred:sd_movhiscrd.codigo_fun = bdicred:sd_transfun.codigo_fun AND bdicred:sd_movhiscrd.codigo_ref = bdicred:sd_transfun.codigo_ref)  
	                        LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa AND bdinteg:si_sucursales.sucursal = bdicred:sd_movhiscrd.sucursal) 
	                        LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdinteg:si_transacc.numero = bdicred:sd_transfun.transacc AND bdicred:sd_transfun.transacc <> '0801')
							WHERE num_credito = p_sNumeroCuenta 
	                        AND fecha_mov <= p_sFechaFinal 
	                        AND fecha_mov >= p_sFechaInicial 
	                        AND monto = p_sMonto							
	                        AND (nro_tarjeta = p_sTarjeta OR nro_tarjeta = '' OR nro_tarjeta IS NULL)
	                        AND bdicred:sd_transfun.transacc <> '0801'
							AND bdicred:sd_movhiscrd.transacc_suc <> '6801'
	                        AND bdicred:sd_transfun.transacc IN transacciones
                            AND bdicred:sd_movhiscrd.empresa = p_sNumeroEmpresa
							AND bdicred:sd_movhiscrd.reversado <>'S'
							ORDER BY folio_suc ASC, fecha_mov ASC
							
							LET vTransaccion = resultado_claveTipo;
													
						IF (vTransaccion IN ( '6900', '6800' , '6871' , '6872', '6873','6830','6887')) THEN
						FOREACH
							SELECT SKIP p_skip DISTINCT fecha_mov, hora_mov, monto, folio_suc, bdinteg:si_sucursales.sucursal, nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, LPAD (referencia23,23,"0"), reversado, referencia, fecha_mov, hora_mov
							INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret 
							FROM bdicred:sd_movhiscrd 
	                        LEFT JOIN bdicred:sd_transfun ON (bdicred:sd_transfun.empresa = p_sNumeroEmpresa AND bdicred:sd_movhiscrd.codigo_fun = bdicred:sd_transfun.codigo_fun AND bdicred:sd_movhiscrd.codigo_ref = bdicred:sd_transfun.codigo_ref)  
	                        LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa AND bdinteg:si_sucursales.sucursal = bdicred:sd_movhiscrd.sucursal) 
	                        LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdinteg:si_transacc.numero = bdicred:sd_transfun.transacc AND bdicred:sd_transfun.transacc <> '0801')
							WHERE num_credito = p_sNumeroCuenta 
							AND fecha_mov <= p_sFechaFinal 
	                        AND fecha_mov >= p_sFechaInicial
							AND bdicred:sd_movhiscrd.transacc_suc <> '6801'
							AND bdicred:sd_movhiscrd.reversado <>'S'
						    AND substr(folio_suc, 0,9)= substr(resultado_folioSuc, 0,9) 
							AND substr(folio_suc, 11,6)= substr(resultado_folioSuc, 11,6)						
			
							LET res_fechaMovimiento_re1=res_fechaMovimiento_ret;
							LET res_horaMovimiento_re1=res_horaMovimiento_ret;
			
							IF (trim(resultado_claveTipo) in ('6830','7729')) THEN 
								SELECT fecha_mov, hora_mov
									INTO res_fechaMovimiento_ret, res_horaMovimiento_ret
								FROM bdicred:sd_movhiscrd 
								WHERE bdicred:sd_movhiscrd.empresa = p_sNumeroEmpresa 
									AND num_credito = p_sNumeroCuenta 
									AND fecha_mov <= p_sFechaFinal 
									AND fecha_mov >= p_sFechaInicial
									AND substr(folio_suc, 0,9)= substr(resultado_folioSuc, 0,9) 
									AND substr(folio_suc, 11,6)= substr(resultado_folioSuc, 11,6)
									AND bdicred:sd_transfun.transacc='6801';
								END IF;						
							
								-- Obtener la fecha de Retenido del movimiento
								IF (resultado_claveTipo in ('6830','7729')) THEN 
								SELECT DISTINCT fecha_mov, hora_mov
									INTO res_fechaMovimiento_ret, res_horaMovimiento_ret
								FROM bdicred:sd_movhiscrd 
								WHERE bdicred:sd_movhiscrd.empresa = p_sNumeroEmpresa 
									AND num_credito = p_sNumeroCuenta 
									AND fecha_mov <= p_sFechaFinal 
									AND fecha_mov >= p_sFechaInicial-30
									AND bdicred:sd_movhiscrd.folio_suc=resultado_folioSuc	
									AND bdicred:sd_movhiscrd.transacc_suc='6801';  
								END IF;	
							
							IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
								LET res_fechaMovimiento_ret=res_fechaMovimiento_re1;
								LET res_horaMovimiento_ret=res_horaMovimiento_re1;							
							END IF;	

							
							IF (resultado_folioSuc is not null AND resultado_claveTipo not in ('8071','8072')) THEN	
							RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret WITH RESUME;
							END IF;
						END FOREACH;
						END IF;
												
						END FOREACH;
				END IF;
              END IF;
	       ELSE
		      IF (p_sMonto IS NULL OR p_sMonto = 0 OR p_sMonto='') THEN
					FOREACH       
				     	SELECT SKIP p_skip DISTINCT fecha_mov, hora_mov, monto, folio_suc, bdinteg:si_sucursales.sucursal, nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, LPAD (referencia23,23,"0"), reversado, referencia, fecha_mov, hora_mov
				          INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret 
				          FROM bdicred:sd_movhiscrd 
	                        LEFT JOIN bdicred:sd_transfun ON (bdicred:sd_transfun.empresa = p_sNumeroEmpresa AND bdicred:sd_movhiscrd.codigo_fun = bdicred:sd_transfun.codigo_fun AND bdicred:sd_movhiscrd.codigo_ref = bdicred:sd_transfun.codigo_ref) 
	                        LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa AND bdinteg:si_sucursales.sucursal = bdicred:sd_movhiscrd.sucursal) 
	                        LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdinteg:si_transacc.numero = bdicred:sd_transfun.transacc AND bdicred:sd_transfun.transacc <> '0801') 
				          WHERE num_credito = p_sNumeroCuenta 
	                        AND fecha_mov <= p_sFechaFinal 
	                        AND fecha_mov >= p_sFechaInicial
                            AND (nro_tarjeta = '' OR nro_tarjeta IS NULL)	
	                        AND bdicred:sd_transfun.transacc <> '0801'
	                        AND bdicred:sd_movhiscrd.transacc_suc not in ('6801','7380','7381','7383','7384','7729','7730','6881')
	                        AND bdicred:sd_transfun.transacc IN transacciones
                            AND bdicred:sd_movhiscrd.empresa = p_sNumeroEmpresa
							AND bdicred:sd_movhiscrd.reversado <>'S'
	                      ORDER BY folio_suc ASC, fecha_mov ASC

                          IF (resultado_claveTipo IN ('6900','6800','6871','6872','6873','6830','6887')) THEN
                              select monto
                                into saldo_favor
                                FROM bdicred:sd_movhiscrd 
                                WHERE num_credito = p_sNumeroCuenta 
                                AND fecha_mov <= p_sFechaFinal 
                                AND fecha_mov >= p_sFechaInicial
                                AND (nro_tarjeta = '' OR nro_tarjeta IS NULL)	
                                AND bdicred:sd_movhiscrd.empresa = p_sNumeroEmpresa
                                AND folio_suc = resultado_folioSuc
								AND bdicred:sd_movhiscrd.transacc_suc <> '6801'
                                AND bdicred:sd_movhiscrd.transacc_suc in ('7380','7381','7382','7383','7384','7729','7730');

                                IF (saldo_favor IS NULL) THEN 
                                    let saldo_favor = 0;
                                end if;
                                
                                let resultado_monto = resultado_monto + saldo_favor;
							END IF;

							LET res_fechaMovimiento_re1=res_fechaMovimiento_ret;
							LET res_horaMovimiento_re1=res_horaMovimiento_ret;							
							
								-- Obtener la fecha de Retenido del movimiento
								IF (resultado_claveTipo in ('6830','7729')) THEN 
								SELECT DISTINCT fecha_mov, hora_mov
									INTO res_fechaMovimiento_ret, res_horaMovimiento_ret
								FROM bdicred:sd_movhiscrd 
								WHERE bdicred:sd_movhiscrd.empresa = p_sNumeroEmpresa 
									AND num_credito = p_sNumeroCuenta 
									AND fecha_mov <= p_sFechaFinal 
									AND fecha_mov >= p_sFechaInicial-30
									AND bdicred:sd_movhiscrd.folio_suc=resultado_folioSuc	
									AND bdicred:sd_movhiscrd.transacc_suc='6801';  
								END IF;	
								
							IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
								LET res_fechaMovimiento_ret=res_fechaMovimiento_re1;
								LET res_horaMovimiento_ret=res_horaMovimiento_re1;							
							END IF;
							
						IF (resultado_folioSuc is not null AND resultado_claveTipo not in ('8071','8072')) THEN	
							RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret WITH RESUME;
						END IF;	
						
					END FOREACH;
				ELSE
				IF (p_sMonto IS NOT NULL OR p_sMonto <>0 OR p_sMonto<>'') THEN
				
					FOREACH       
				     	SELECT SKIP p_skip DISTINCT fecha_mov, hora_mov, monto, folio_suc, bdinteg:si_sucursales.sucursal, nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, LPAD (referencia23,23,"0"), reversado, referencia, fecha_mov, hora_mov
				          INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret 
				          FROM bdicred:sd_movhiscrd 
	                        LEFT JOIN bdicred:sd_transfun ON (bdicred:sd_transfun.empresa = p_sNumeroEmpresa AND bdicred:sd_movhiscrd.codigo_fun = bdicred:sd_transfun.codigo_fun AND bdicred:sd_movhiscrd.codigo_ref = bdicred:sd_transfun.codigo_ref)  
	                        LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa AND bdinteg:si_sucursales.sucursal = bdicred:sd_movhiscrd.sucursal) 
	                        LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdinteg:si_transacc.numero = bdicred:sd_transfun.transacc AND bdicred:sd_transfun.transacc <> '0801')
				          WHERE  num_credito = p_sNumeroCuenta 
	                        AND fecha_mov <= p_sFechaFinal 
	                        AND fecha_mov >= p_sFechaInicial 
							AND monto = p_sMonto
                            AND (nro_tarjeta = '' OR nro_tarjeta IS NULL)
	                        AND bdicred:sd_transfun.transacc <> '0801'
	                        AND bdicred:sd_movhiscrd.transacc_suc <> '6801'
	                        AND bdicred:sd_transfun.transacc IN transacciones
                            AND bdicred:sd_movhiscrd.empresa = p_sNumeroEmpresa
							AND bdicred:sd_movhiscrd.reversado <>'S'
	                      ORDER BY folio_suc ASC, fecha_mov ASC
						  
						LET vTransaccion = resultado_claveTipo;
						
											
						IF (vTransaccion IN ( '6900', '6800' , '6871' , '6872', '6873','6830','6887')) THEN
						FOREACH
							SELECT SKIP p_skip DISTINCT fecha_mov, hora_mov, monto, folio_suc, bdinteg:si_sucursales.sucursal, nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, LPAD (referencia23,23,"0"), reversado, referencia, fecha_mov, hora_mov
							INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret 
							FROM bdicred:sd_movhiscrd 
	                        LEFT JOIN bdicred:sd_transfun ON (bdicred:sd_transfun.empresa = p_sNumeroEmpresa AND bdicred:sd_movhiscrd.codigo_fun = bdicred:sd_transfun.codigo_fun AND bdicred:sd_movhiscrd.codigo_ref = bdicred:sd_transfun.codigo_ref)  
	                        LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa AND bdinteg:si_sucursales.sucursal = bdicred:sd_movhiscrd.sucursal) 
	                        LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdinteg:si_transacc.numero = bdicred:sd_transfun.transacc AND bdicred:sd_transfun.transacc <> '0801')
							WHERE num_credito = p_sNumeroCuenta 
							AND fecha_mov <= p_sFechaFinal 
	                        AND fecha_mov >= p_sFechaInicial
							AND bdicred:sd_movhiscrd.transacc_suc <> '6801'
							AND substr(folio_suc, 0,9)= substr(resultado_folioSuc, 0,9) 
							AND substr(folio_suc, 11,6)= substr(resultado_folioSuc, 11,6)
							
						IF (resultado_folioSuc is not null AND resultado_claveTipo not in ('8071','8072')) THEN	
							RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_referencia23, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret WITH RESUME;
						END IF;	
							END FOREACH;
						END IF;					
						
					END FOREACH;
				END IF;
	       END IF;
		END IF;
		END IF; 
	END 
END PROCEDURE
DOCUMENT
'Sp para búsqueda de movimientos de Crédito',
'Aclaraciones',
'Modifica : Rey David Zavala Garcia',
'Se agrega la Transaccion 7382 en busqueda de Movimientos',
'Area: Sistemas Administrativos y Perifericos',
'Gerencia de Mtto y Soporte IV',
'Coordinador:Norberto Corona Berruecos',
'FECHA : 21/Septiembre/2018',
'VERSION: 1.0.2',
'BD    :  bdinteg';

CREATE PROCEDURE "informix".sp_buscar_movimientos_inversion_dia2(p_sNumeroCuenta CHAR(30), p_sFechaInicial DATE, p_sFechaFinal DATE, p_sMonto money(14,2), p_skip INT, ids_transacciones lvarchar, p_sNumeroEmpresa CHAR(3))

     RETURNING	DATE AS fechaMovimiento, DATETIME HOUR TO FRACTION(3) AS horaMovimiento , money(16,2) AS monto, CHAR(30) AS folioSuc, CHAR(4) AS sucursal, CHAR(30) AS nombre, CHAR(5) AS claveTipo, CHAR(40) AS tipo, CHAR(1) AS reversado;

	-- Definición de variables	    
	DEFINE resultado_fechaMovimiento 		DATE;
	DEFINE resultado_monto					money(16,2);
	DEFINE resultado_horaMovimiento			DATETIME HOUR TO FRACTION(3);
	DEFINE resultado_folioSuc				CHAR(30);
    DEFINE resultado_sucursal				CHAR(4);
    DEFINE resultado_nombre            		CHAR(30);
    DEFINE resultado_claveTipo         		CHAR(5);
    DEFINE resultado_tipo   				CHAR(40);
    DEFINE resultado_reversado				CHAR(1);
    DEFINE transacciones 					LIST(CHAR(4) NOT NULL);
    DEFINE iSqlErr                      	INTEGER;
	DEFINE v_tabla							CHAR(4);
	
    -- Inicialización de las variables.
	LET resultado_fechaMovimiento 	= '';
	LET resultado_monto 			= '';
	LET resultado_horaMovimiento 	= TO_DATE("00:00","%H:%M");
	LET resultado_folioSuc 			= '';
    LET resultado_sucursal 			= '';
    LET resultado_nombre 			= '';
   	LET resultado_claveTipo 		= '';
	LET resultado_tipo 				= '';
    LET resultado_reversado 		= '';
	LET transacciones 				= 'LIST{' || ids_transacciones || '}';
	LET v_tabla 					= '';

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Actualizaciones Optimización de SP´s II 05/03/2013
-- Cambio para que en un sólo SP se realicen todas las consultas que correspan.
-- Se cambia el nombre para la identificación correcta de los SP´s del sistema.
-- SADVC 
	
    SET ISOLATION TO DIRTY READ;
-- SET DEBUG FILE TO "/informix/SD/Optimizacion_sps_root_II/sp_buscar_movimientos_inversion_dia2.out";
-- TRACE ON;

	BEGIN

        ON EXCEPTION
                
				SET iSqlErr
        
				IF iSqlErr <> 0 THEN
                    LET resultado_fechaMovimiento = '';
                    LET resultado_monto = '';
                    LET resultado_horaMovimiento = TO_DATE("00:00","%H:%M");
                    LET resultado_folioSuc = '';
                    LET resultado_sucursal = '';
                    LET resultado_nombre = '';
                    LET resultado_claveTipo = '';
                    LET resultado_tipo = '';
					LET resultado_reversado = '';
                    
					RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_reversado;
                
				END IF;
        
		END EXCEPTION;

        IF(ids_transacciones IS NOT NULL) THEN
        
			IF p_sMonto IS NULL OR p_sMonto = 0 THEN
			
				FOREACH
					SELECT SKIP p_skip fech_alt, fech_hor, monto_tot, folio_suc, sucursal, nombre, numero, descripcion, cancelad 
					INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_reversado
					FROM ( SELECT DISTINCT fech_alt, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad, 'D'
			          FROM bdinvers:sv_movdia 
                 LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa AND bdinteg:si_sucursales.sucursal = bdinvers:sv_movdia.sucursal) 
                 LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.numero = bdinvers:sv_movdia.transacc AND bdinvers:sv_movdia.transacc <> '0801')
				     WHERE cuenta = p_sNumeroCuenta 
                       AND fech_alt <= p_sFechaFinal 
                       AND fech_alt >= p_sFechaInicial
                       AND bdinvers:sv_movdia.transacc <> '0801'
                       AND bdinvers:sv_movdia.transacc_suc <> '6801'
                       AND bdinvers:sv_movdia.transacc IN transacciones
            
					UNION ALL 
				
					SELECT DISTINCT fech_alt, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad, 'H'
			          FROM bdinvers:sv_movhis 
                 LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa AND bdinteg:si_sucursales.sucursal = bdinvers:sv_movhis.sucursal) 
                 LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdinteg:si_transacc.numero = bdinvers:sv_movhis.transacc AND bdinvers:sv_movhis.transacc <> '0801')
			         WHERE cuenta = p_sNumeroCuenta 
                       AND fech_alt <= p_sFechaFinal 
                       AND fech_alt >= p_sFechaInicial
                       AND bdinvers:sv_movhis.transacc <> '0801'
                       AND bdinvers:sv_movhis.transacc_suc <> '6801'
                       AND bdinvers:sv_movhis.transacc IN transacciones
                       AND bdinvers:sv_movhis.empresa = p_sNumeroEmpresa
					)
					ORDER BY folio_suc asC, fech_alt asC
			          RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_reversado WITH RESUME;
				
				END FOREACH;
			
			ELSE
			
				FOREACH
					SELECT SKIP p_skip fech_alt, fech_hor, monto_tot, folio_suc, sucursal, nombre, numero, descripcion, cancelad 
					INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_reversado
					FROM ( SELECT DISTINCT fech_alt, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad, 'D'
			          FROM bdinvers:sv_movdia 
                        LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa AND bdinteg:si_sucursales.sucursal = bdinvers:sv_movdia.sucursal) 
                        LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.numero = bdinvers:sv_movdia.transacc AND bdinvers:sv_movdia.transacc <> '0801')
			          WHERE cuenta = p_sNumeroCuenta 
                        AND fech_alt <= p_sFechaFinal 
                        AND fech_alt >= p_sFechaInicial 
                        AND monto_tot = p_sMonto
                        AND bdinvers:sv_movdia.transacc <> '0801'
                        AND bdinvers:sv_movdia.transacc_suc <> '6801'
                        AND bdinvers:sv_movdia.transacc IN transacciones
            
					UNION ALL
					
				    SELECT DISTINCT fech_alt, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad, 'H'
			          FROM bdinvers:sv_movhis 
                        LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa AND bdinteg:si_sucursales.sucursal = bdinvers:sv_movhis.sucursal) 
                        LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdinteg:si_transacc.numero = bdinvers:sv_movhis.transacc AND bdinvers:sv_movhis.transacc <> '0801')
			          WHERE cuenta = p_sNumeroCuenta 
                        AND fech_alt <= p_sFechaFinal 
                        AND fech_alt >= p_sFechaInicial 
                        AND monto_tot = p_sMonto
                        AND bdinvers:sv_movhis.transacc <> '0801'
                        AND bdinvers:sv_movhis.transacc_suc <> '6801'
                        AND bdinvers:sv_movhis.transacc IN transacciones
                        AND bdinvers:sv_movhis.empresa = p_sNumeroEmpresa
						)
					  ORDER BY folio_suc asC, fech_alt asC
			          RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_reversado WITH RESUME;
				
				END FOREACH;
			
			END IF;
		
		ELSE
		
			IF p_sMonto IS NULL OR p_sMonto = 0 THEN
			
				FOREACH
				SELECT SKIP p_skip fech_alt, fech_hor, monto_tot, folio_suc, sucursal, nombre, numero, descripcion, cancelad 
				INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_reversado
			    FROM ( 	SELECT DISTINCT fech_alt, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad 
			           FROM bdinvers:sv_movdia 
                        LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa AND bdinteg:si_sucursales.sucursal = bdinvers:sv_movdia.sucursal) 
                        LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.numero = bdinvers:sv_movdia.transacc AND bdinvers:sv_movdia.transacc <> '0801')
						WHERE cuenta = p_sNumeroCuenta 
                        AND fech_alt <= p_sFechaFinal 
                        AND fech_alt >= p_sFechaInicial
                        AND bdinvers:sv_movdia.transacc <> '0801'
                        AND bdinvers:sv_movdia.transacc_suc <> '6801'
           
					UNION ALL
					  
					SELECT DISTINCT fech_alt, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad 
			          FROM bdinvers:sv_movhis 
                 LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa AND bdinteg:si_sucursales.sucursal = bdinvers:sv_movhis.sucursal) 
                 LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdinteg:si_transacc.numero = bdinvers:sv_movhis.transacc AND bdinvers:sv_movhis.transacc <> '0801')
			         WHERE cuenta = p_sNumeroCuenta 
                       AND fech_alt <= p_sFechaFinal 
                       AND fech_alt >= p_sFechaInicial
                       AND bdinvers:sv_movhis.transacc <> '0801'
                       AND bdinvers:sv_movhis.transacc_suc <> '6801'
                       AND bdinvers:sv_movhis.empresa = p_sNumeroEmpresa
					  )
					  ORDER BY folio_suc asC, fech_alt asC
			          RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_reversado WITH RESUME;
				
				END FOREACH;
			
			ELSE
				
				FOREACH
			     	SELECT SKIP p_skip fech_alt, fech_hor, monto_tot, folio_suc, sucursal, nombre, numero, descripcion, cancelad 
				INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_reversado
					FROM (SELECT DISTINCT fech_alt, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad 
			          FROM bdinvers:sv_movdia 
                        LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa AND bdinteg:si_sucursales.sucursal = bdinvers:sv_movdia.sucursal) 
                        LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.numero = bdinvers:sv_movdia.transacc AND bdinvers:sv_movdia.transacc <> '0801')
						WHERE cuenta = p_sNumeroCuenta 
                        AND fech_alt <= p_sFechaFinal 
                        AND fech_alt >= p_sFechaInicial 
                        AND monto_tot = p_sMonto
                        AND bdinvers:sv_movdia.transacc <> '0801'
                        AND bdinvers:sv_movdia.transacc_suc <> '6801'
                      
					UNION ALL
					
					SELECT DISTINCT fech_alt, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad 
			           FROM bdinvers:sv_movhis 
                 LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa AND bdinteg:si_sucursales.sucursal = bdinvers:sv_movhis.sucursal) 
                 LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdinteg:si_transacc.numero = bdinvers:sv_movhis.transacc AND bdinvers:sv_movhis.transacc <> '0801')
			         WHERE cuenta = p_sNumeroCuenta 
                       AND fech_alt <= p_sFechaFinal 
                       AND fech_alt >= p_sFechaInicial 
                       AND monto_tot = p_sMonto
                       AND bdinvers:sv_movhis.transacc <> '0801'
                       AND bdinvers:sv_movhis.transacc_suc <> '6801'
                       AND bdinvers:sv_movhis.empresa = p_sNumeroEmpresa
					  )
					  ORDER BY folio_suc asC, fech_alt asC
			          RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_reversado WITH RESUME;
				
				END FOREACH;
			
			END IF;
		
		END IF;
	
	END 
	
END PROCEDURE;