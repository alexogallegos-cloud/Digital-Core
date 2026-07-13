CREATE PROCEDURE "informix".sp_buscar_movimientos_cheques_dia3(p_sNumeroCuenta CHAR(30), p_sFechaInicial DATE, p_sFechaFinal DATE, p_sMonto money(14,2), p_skip INT, p_sTarjeta CHAR(30), ids_transacciones lvarchar, p_sNumeroEmpresa CHAR(3))

     RETURNING	DATE AS fechaMovimiento, DATETIME HOUR to FRACTION(3) AS horaMovimiento , money(16,2) AS monto, CHAR(30) AS folioSuc, CHAR(4) AS sucursal, CHAR(30) AS nombre, CHAR(5) AS claveTipo, CHAR(40) AS tipo, CHAR(1) AS reversado, CHAR(40) AS refComercio, DATE AS fechaConsumo, DATETIME HOUR to FRACTION(3) AS horaConsumo;

	-- Definicion de variables    
	DEFINE resultado_fechaMovimiento 	DATE;
	DEFINE resultado_monto              money(16,2);
	DEFINE monto_cashback    			money(16,2);
	DEFINE resultado_horaMovimiento		DATETIME HOUR TO FRACTION(3);
	DEFINE resultado_folioSuc           CHAR(30);
	DEFINE resultado_sucursal           CHAR(4);
	DEFINE resultado_nombre             CHAR(30);
    DEFINE resultado_claveTipo          CHAR(5);
    DEFINE resultado_tipo               CHAR(40);
    DEFINE resultado_reversado          CHAR(1);
	DEFINE resultado_refComercio        CHAR(40);
    DEFINE transacciones                LIST(CHAR(4) NOT NULL);
    DEFINE iSqlErr                      INTEGER;
	DEFINE v_tabla						CHAR (4);
	DEFINE res_fechaMovimiento_ret	 	DATE;
	DEFINE res_horaMovimiento_ret	 	DATETIME HOUR TO FRACTION(3);
	DEFINE res_fechaMovimiento_re1	 	DATE;
	DEFINE res_horaMovimiento_re1	 	DATETIME HOUR TO FRACTION(3);
     
    -- Inicializaci n de las variables.
	LET resultado_fechaMovimiento 		= '';
	LET resultado_monto 				= '';
	LET monto_cashback					= '';
	LET resultado_horaMovimiento 		= TO_DATE("00:00","%H:%M");
	LET resultado_folioSuc 				= '';
    LET resultado_sucursal 				= '';
   	LET resultado_nombre 				= '';
    LET resultado_claveTipo 			= '';
	LET resultado_tipo 					= '';
    LET resultado_reversado 			= '';
	LET resultado_refComercio 			= '';
    LET transacciones 					= 'LIST{' || ids_transacciones || '}';
	LET v_tabla 						= '';
	LET res_fechaMovimiento_ret = '';
	LET res_horaMovimiento_ret  = TO_DATE("00:00","%H:%M");
	LET res_fechaMovimiento_re1 = '';
	LET res_horaMovimiento_re1  = TO_DATE("00:00","%H:%M");
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Actualizaciones Optimizaci n de SPs II 05/03/2013
-- Cambio para que en un s lo SP se realicen todas las consultas que correspan.
-- Se cambia el nombre para la identificaci n correcta de los SPs del sistema.
-- SADVC 
	
      SET ISOLATION TO DIRTY READ;
	   -- SET DEBUG FILE TO "/aplicacion/pisabanco/pisa_ftes/syndein/img/InterAct/cfg/sp_vjmp.out";
     -- TRACE ON;

	BEGIN

        ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET resultado_fechaMovimiento 	= '';
				LET resultado_monto 			= '';
				LET resultado_horaMovimiento 	= TO_DATE("00:00","%H:%M");
				LET resultado_folioSuc 			= '';
				LET resultado_sucursal 			= '';
				LET resultado_nombre 			= '';
				LET resultado_claveTipo 		= '';
				LET resultado_tipo 				= '';
				LET resultado_reversado 		= '';
				LET resultado_refComercio 		= '';
				LET res_fechaMovimiento_ret 	= '';
				LET res_horaMovimiento_ret  = TO_DATE("00:00","%H:%M");
				
				RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret;
			
			END IF;
        END EXCEPTION;
	
        IF(ids_transacciones IS NOT NULL) THEN
	
			-- PRUEBA LMLA 17/10/2023 **** (Se validan transacciones x TRASPASO)
		
			IF(ids_transacciones   = '0239,0289,0300,0309,0403,0445,1302') THEN
				LET p_sTarjeta = '';
			END IF;
			
			IF(ids_transacciones   = '0239,0289,0300,0309,0403,0445,1194,1302') THEN
				LET p_sTarjeta = '';
			END IF;
			
		
		
			-- PRUEBA LMLA 03/08/2023 ****
            IF(p_sTarjeta IS NOT NULL AND p_sTarjeta <> '') THEN
			--IF(p_sTarjeta IS NOT NULL) THEN
				IF (year(p_sFechaInicial)<year(today)) THEN
					FOREACH 		
						SELECT SKIP p_skip DISTINCT fech_val, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, bdinteg:si_sucursales.nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad, CASE transacc_suc WHEN '0280' THEN '' ELSE referencia END AS ref_comercio, 'O', fech_val, fech_hor
							INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_reversado, resultado_refComercio, v_tabla, res_fechaMovimiento_ret, res_horaMovimiento_ret
						FROM bdicheq:sc_movhis_old2 
							LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdicheq:sc_movhis_old2.sucursal AND bdinteg:si_sucursales.empresa = p_sNumeroEmpresa) 
							LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdinteg:si_transacc.numero = bdicheq:sc_movhis_old2.transacc AND bdicheq:sc_movhis_old2.transacc <> '0801' AND bdicheq:sc_movhis_old2.transacc_suc <> '6801')
						WHERE bdicheq:sc_movhis_old2.empresa= p_sNumeroEmpresa
							AND cuenta = p_sNumeroCuenta 
							AND fech_val BETWEEN p_sFechaInicial AND p_sFechaFinal 
							AND cancelad <> "S"
							AND bdicheq:sc_movhis_old2.transacc IN transacciones
							AND se_emite_edocta = "S"
							AND (num_tarjeta = p_sTarjeta or num_tarjeta = '' or num_tarjeta IS NULL)
						ORDER BY folio_suc ASC, fech_val ASC
						  
						IF (resultado_claveTipo ='0830') THEN 
							SELECT monto_tot
								INTO monto_cashback 
							FROM bdicheq:sc_movhis_old2
							WHERE empresa= p_sNumeroEmpresa
								AND cuenta=p_sNumeroCuenta
								AND fech_val BETWEEN p_sFechaInicial AND p_sFechaFinal
								AND folio_suc = resultado_folioSuc
								AND transacc='0832';
							
							IF monto_cashback IS NULL THEN 
								LET monto_cashback =0;
							END IF;
							
							let resultado_monto = resultado_monto + monto_cashback;
							
						END IF; --IF (resultado_claveTipo ='0830') THEN 
						
						LET res_fechaMovimiento_re1=res_fechaMovimiento_ret;
						LET res_horaMovimiento_re1=res_horaMovimiento_ret;
						
						IF (resultado_claveTipo in ('0830', '0832')) THEN
							SELECT  fech_val, fech_hor
								INTO res_fechaMovimiento_ret,  res_horaMovimiento_ret
							FROM bdicheq:sc_movhis_old2
							WHERE empresa= p_sNumeroEmpresa
								AND cuenta=p_sNumeroCuenta
								AND fech_val BETWEEN p_sFechaInicial-31 AND p_sFechaFinal
								AND folio_suc = resultado_folioSuc
								AND transacc='0801';
							
								/*Si no encontr  fecha y hora para retenido, pone datos de liberacion*/
							IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
								LET res_fechaMovimiento_ret=res_fechaMovimiento_re1;
								LET res_horaMovimiento_ret=res_horaMovimiento_re1;							
							END IF;
								
						END IF;
						  
						RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret WITH RESUME;
						
					END FOREACH;
                
				END IF;	--IF (year(p_sFechaInicial)<year(today)) THEN
				------------------------------
				--------------------------------
				IF p_sMonto IS NULL OR p_sMonto = 0 THEN
				
					FOREACH       
						SELECT SKIP p_skip DISTINCT fech_val, fech_hor, monto_tot, folio_suc, sucursal,nombre,numero,descripcion, cancelad, ref_comercio, 'H', fech_val, fech_hor
							INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_reversado, resultado_refComercio, v_tabla, res_fechaMovimiento_ret, res_horaMovimiento_ret
						FROM table 
							(multiset (
								SELECT /*SKIP p_skip*/ DISTINCT fech_val, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, bdinteg:si_sucursales.nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad, CASE transacc_suc WHEN '0280' THEN '' ELSE referencia END AS ref_comercio, 'D', fech_val, fech_hor
								FROM bdicheq:sc_movdia 
									LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa AND bdinteg:si_sucursales.sucursal = bdicheq:sc_movdia.sucursal) 
									LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdicheq:sc_movdia.transacc <> '0801' AND bdinteg:si_transacc.numero = bdicheq:sc_movdia.transacc)
								WHERE cuenta = p_sNumeroCuenta 
								   AND fech_val <= p_sFechaFinal 
								   AND fech_val >= p_sFechaInicial 
								   AND (num_tarjeta = p_sTarjeta OR num_tarjeta = '' OR num_tarjeta IS NULL)
								   AND bdicheq:sc_movdia.transacc <> '0801'
								   AND bdicheq:sc_movdia.transacc_suc <> '6801'
								   AND bdicheq:sc_movdia.transacc IN transacciones
								   AND bdicheq:sc_movdia.empresa = p_sNumeroEmpresa
							
								UNION ALL

								SELECT /*SKIP p_skip*/ DISTINCT fech_val, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, bdinteg:si_sucursales.nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad, CASE transacc_suc WHEN '0280' THEN '' ELSE referencia END AS ref_comercio, 'H', fech_val, fech_hor
								FROM bdicheq:sc_movhis 
									LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdicheq:sc_movhis.sucursal AND bdinteg:si_sucursales.empresa = p_sNumeroEmpresa) 
									LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdinteg:si_transacc.numero = bdicheq:sc_movhis.transacc AND bdicheq:sc_movhis.transacc <> '0801')
								WHERE bdicheq:sc_movhis.empresa= p_sNumeroEmpresa
									AND cuenta = p_sNumeroCuenta 
									AND fech_val <= p_sFechaFinal 
									AND fech_val >= p_sFechaInicial
									AND (num_tarjeta = p_sTarjeta or num_tarjeta = '' or num_tarjeta IS NULL)
									AND bdicheq:sc_movhis.transacc <> '0801'
									AND bdicheq:sc_movhis.transacc_suc <> '6801'
									AND bdicheq:sc_movhis.transacc IN transacciones

								UNION ALL
								   
								SELECT {+INDEX(sc_movhis_old idx_movhiso1)} /*SKIP p_skip*/ DISTINCT fech_val, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, bdinteg:si_sucursales.nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad, CASE transacc_suc WHEN '0280' THEN '' ELSE referencia END AS ref_comercio, 'O', fech_val, fech_hor
								FROM bdicheq:sc_movhis_old 
									LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdicheq:sc_movhis_old.sucursal AND bdinteg:si_sucursales.empresa = p_sNumeroEmpresa) 
									LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdinteg:si_transacc.numero = bdicheq:sc_movhis_old.transacc AND bdicheq:sc_movhis_old.transacc <> '0801' AND bdicheq:sc_movhis_old.transacc_suc <> '6801')
								WHERE bdicheq:sc_movhis_old.empresa= p_sNumeroEmpresa
									AND cuenta = p_sNumeroCuenta 
									AND fech_val BETWEEN p_sFechaInicial AND p_sFechaFinal 
									AND cancelad <> "S"
									AND bdicheq:sc_movhis_old.transacc IN transacciones
									AND se_emite_edocta = "S"
									AND (num_tarjeta = p_sTarjeta or num_tarjeta = '' or num_tarjeta IS NULL)
							))   
						ORDER BY folio_suc ASC, fech_val ASC
						  
						IF (resultado_claveTipo ='0830') THEN 
							SELECT monto_tot
								INTO monto_cashback 
							FROM bdicheq:sc_movhis
							WHERE empresa= p_sNumeroEmpresa
								AND cuenta=p_sNumeroCuenta
								AND fech_val BETWEEN p_sFechaInicial AND p_sFechaFinal
								AND folio_suc = resultado_folioSuc
								AND transacc='0832';
							
							IF monto_cashback IS NULL THEN 
								SELECT monto_tot
									INTO monto_cashback 
								FROM bdicheq:sc_movhis_old
								WHERE empresa= p_sNumeroEmpresa
									AND cuenta=p_sNumeroCuenta
									AND fech_val BETWEEN p_sFechaInicial AND p_sFechaFinal
									AND folio_suc = resultado_folioSuc
									AND transacc='0832';
							END IF;
							
							IF monto_cashback IS NULL THEN 
								LET monto_cashback =0;
							END IF;
							
							let resultado_monto = resultado_monto + monto_cashback;
							
						END IF;	--IF (resultado_claveTipo ='0830') THEN 	

						LET res_fechaMovimiento_re1=res_fechaMovimiento_ret;
						LET res_horaMovimiento_re1=res_horaMovimiento_ret;
						
						IF (resultado_claveTipo in ('0830', '0832')) THEN
							SELECT  fech_val, fech_hor
								INTO res_fechaMovimiento_ret,  res_horaMovimiento_ret
							FROM bdicheq:sc_movhis
							WHERE empresa= p_sNumeroEmpresa
								AND cuenta=p_sNumeroCuenta
								AND fech_val BETWEEN p_sFechaInicial-31 AND p_sFechaFinal
								AND folio_suc = resultado_folioSuc
								AND transacc='0801';
								
							IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
								SELECT  fech_val, fech_hor
									INTO res_fechaMovimiento_ret,  res_horaMovimiento_ret
								FROM bdicheq:sc_movhis_old
								WHERE empresa= p_sNumeroEmpresa
									AND cuenta=p_sNumeroCuenta
									AND fech_val BETWEEN p_sFechaInicial-31 AND p_sFechaFinal
									AND folio_suc = resultado_folioSuc
									AND transacc='0801';
							END IF;
								
							IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
								SELECT  fech_val, fech_hor
									INTO res_fechaMovimiento_ret,  res_horaMovimiento_ret
								FROM bdicheq:sc_movhis_old2
								WHERE empresa= p_sNumeroEmpresa
									AND cuenta=p_sNumeroCuenta
									AND fech_val BETWEEN p_sFechaInicial-31 AND p_sFechaFinal
									AND folio_suc = resultado_folioSuc
									AND transacc='0801';
							END IF;	
							
							IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
								LET res_fechaMovimiento_ret=res_fechaMovimiento_re1;
								LET res_horaMovimiento_ret=res_horaMovimiento_re1;							
							END IF;
								
						END IF;	--IF (resultado_claveTipo in ('0830', '0832')) THEN					  
						  
						RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret WITH RESUME;
						   
					END FOREACH;
				
				ELSE--IF p_sMonto IS NULL OR p_sMonto = 0 THEN
                    FOREACH   
						SELECT SKIP p_skip DISTINCT fech_val, fech_hor, monto_tot, folio_suc, sucursal,nombre,numero,descripcion, cancelad, ref_comercio, 'H', fech_val, fech_hor
							INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_reversado, resultado_refComercio, v_tabla, res_fechaMovimiento_ret, res_horaMovimiento_ret
						FROM table 
							(multiset (					
								SELECT /*SKIP p_skip */ DISTINCT fech_val, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, bdinteg:si_sucursales.nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad, CASE transacc_suc WHEN '0280' THEN '' ELSE referencia END AS ref_comercio, 'D', fech_val, fech_hor
								FROM bdicheq:sc_movdia 
									LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa AND bdinteg:si_sucursales.sucursal = bdicheq:sc_movdia.sucursal) 
									LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdicheq:sc_movdia.transacc <> '0801' AND bdinteg:si_transacc.numero = bdicheq:sc_movdia.transacc)
								WHERE cuenta = p_sNumeroCuenta 
									AND fech_val <= p_sFechaFinal 
									AND fech_val >= p_sFechaInicial 
									AND monto_tot = p_sMonto
									AND (num_tarjeta = p_sTarjeta OR num_tarjeta = '' OR num_tarjeta IS NULL)
									AND bdicheq:sc_movdia.transacc <> '0801'
									AND bdicheq:sc_movdia.transacc_suc <> '6801'
									AND bdicheq:sc_movdia.transacc IN transacciones
									AND bdicheq:sc_movdia.empresa = p_sNumeroEmpresa
								   
								UNION ALL 
								   
								SELECT /*SKIP p_skip*/ DISTINCT fech_val, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, bdinteg:si_sucursales.nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad, CASE transacc_suc WHEN '0280' THEN '' ELSE referencia END AS ref_comercio, 'H', fech_val, fech_hor
								FROM bdicheq:sc_movhis 
									LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdicheq:sc_movhis.sucursal AND bdinteg:si_sucursales.empresa = p_sNumeroEmpresa) 
									LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdinteg:si_transacc.numero = bdicheq:sc_movhis.transacc AND bdicheq:sc_movhis.transacc <> '0801')
								WHERE bdicheq:sc_movhis.empresa= p_sNumeroEmpresa
									AND cuenta = p_sNumeroCuenta    
									AND fech_val <= p_sFechaFinal 
									AND fech_val >= p_sFechaInicial 
									AND monto_tot = p_sMonto
									AND (num_tarjeta = p_sTarjeta or num_tarjeta = '' or num_tarjeta IS NULL)
									AND bdicheq:sc_movhis.transacc <> '0801'
									AND bdicheq:sc_movhis.transacc_suc <> '6801'
									AND bdicheq:sc_movhis.transacc IN transacciones
								   
								UNION ALL
							
								SELECT {+INDEX(sc_movhis_old idx_movhiso1)} /*SKIP p_skip */ DISTINCT fech_val, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, bdinteg:si_sucursales.nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad, CASE transacc_suc WHEN '0280' THEN '' ELSE referencia END AS ref_comercio, 'O', fech_val, fech_hor
								FROM bdicheq:sc_movhis_old 
									LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdicheq:sc_movhis_old.sucursal AND bdinteg:si_sucursales.empresa = p_sNumeroEmpresa) 
									LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdinteg:si_transacc.numero = bdicheq:sc_movhis_old.transacc AND bdicheq:sc_movhis_old.transacc <> '0801' AND bdicheq:sc_movhis_old.transacc_suc <> '6801')
								WHERE bdicheq:sc_movhis_old.empresa= p_sNumeroEmpresa
									AND cuenta = p_sNumeroCuenta    
									AND cancelad <> "S"
									AND se_emite_edocta = "S"
									AND bdicheq:sc_movhis_old.transacc IN transacciones
									AND monto_tot = p_sMonto
									AND fech_val BETWEEN p_sFechaInicial AND p_sFechaFinal 
									AND (num_tarjeta = p_sTarjeta or num_tarjeta = '' or num_tarjeta IS NULL)
							))
							ORDER BY folio_suc ASC, fech_val ASC
						  
						IF (resultado_claveTipo ='0830') THEN 
							SELECT monto_tot
								INTO monto_cashback 
								FROM bdicheq:sc_movhis
							WHERE empresa= p_sNumeroEmpresa
								AND cuenta=p_sNumeroCuenta
								AND fech_val BETWEEN p_sFechaInicial AND p_sFechaFinal
								AND folio_suc = resultado_folioSuc
								AND transacc='0832';
							
							IF monto_cashback IS NULL THEN 
								SELECT monto_tot
									INTO monto_cashback 
									FROM bdicheq:sc_movhis_old
								WHERE empresa= p_sNumeroEmpresa
									AND cuenta=p_sNumeroCuenta
									AND fech_val BETWEEN p_sFechaInicial AND p_sFechaFinal
									AND folio_suc = resultado_folioSuc
									AND transacc='0832';
							END IF;
							
							IF monto_cashback IS NULL THEN 
								LET monto_cashback =0;
							END IF;
							
							let resultado_monto = resultado_monto + monto_cashback;
							
						END IF;	--IF (resultado_claveTipo ='0830') THEN 
						
						LET res_fechaMovimiento_re1=res_fechaMovimiento_ret;
						LET res_horaMovimiento_re1=res_horaMovimiento_ret;
						
						IF (resultado_claveTipo in ('0830', '0832')) THEN
							SELECT  fech_val, fech_hor
								INTO res_fechaMovimiento_ret,  res_horaMovimiento_ret
							FROM bdicheq:sc_movhis
							WHERE empresa= p_sNumeroEmpresa
								AND cuenta=p_sNumeroCuenta
								AND fech_val BETWEEN p_sFechaInicial-31 AND p_sFechaFinal
								AND folio_suc = resultado_folioSuc
								AND transacc='0801';
								
							IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
								SELECT  fech_val, fech_hor
									INTO res_fechaMovimiento_ret,  res_horaMovimiento_ret
								FROM bdicheq:sc_movhis_old
								WHERE empresa= p_sNumeroEmpresa
									AND cuenta=p_sNumeroCuenta
									AND fech_val BETWEEN p_sFechaInicial-31 AND p_sFechaFinal
									AND folio_suc = resultado_folioSuc
									AND transacc='0801';
							END IF;
								
							IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
								SELECT  fech_val, fech_hor
									INTO res_fechaMovimiento_ret,  res_horaMovimiento_ret
								FROM bdicheq:sc_movhis_old2
								WHERE empresa= p_sNumeroEmpresa
									AND cuenta=p_sNumeroCuenta
									AND fech_val BETWEEN p_sFechaInicial-31 AND p_sFechaFinal
									AND folio_suc = resultado_folioSuc
									AND transacc='0801';
							END IF;							
								
							IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
								LET res_fechaMovimiento_ret=res_fechaMovimiento_re1;
								LET res_horaMovimiento_ret=res_horaMovimiento_re1;							
							END IF;
								
						END IF;	--IF (resultado_claveTipo in ('0830', '0832')) THEN
						
						RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret WITH RESUME;
                    
					END FOREACH;
					
                END IF;
				
            ELSE--IF(p_sTarjeta IS NOT NULL) THEN
			
                IF p_sMonto IS NULL OR p_sMonto = 0 THEN
                    FOREACH    
						SELECT SKIP p_skip DISTINCT fech_val, fech_hor, monto_tot, folio_suc, sucursal,nombre,numero,descripcion, cancelad, ref_comercio, 'H', fech_val, fech_hor
							INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_reversado, resultado_refComercio, v_tabla, res_fechaMovimiento_ret, res_horaMovimiento_ret
						FROM table 
							(multiset (					
								SELECT /*SKIP p_skip*/ DISTINCT fech_val, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, bdinteg:si_sucursales.nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad, CASE transacc_suc WHEN '0280' THEN '' ELSE referencia END AS ref_comercio, 'D', fech_val, fech_hor
								FROM bdicheq:sc_movdia 
									LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa AND bdinteg:si_sucursales.sucursal = bdicheq:sc_movdia.sucursal) 
									LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdicheq:sc_movdia.transacc <> '0801' AND bdinteg:si_transacc.numero = bdicheq:sc_movdia.transacc)
								WHERE cuenta = p_sNumeroCuenta 
									AND fech_val <= p_sFechaFinal 
									AND fech_val >= p_sFechaInicial
									--AND (num_tarjeta = '' OR num_tarjeta IS NULL)
									AND bdicheq:sc_movdia.transacc <> '0801'
									AND bdicheq:sc_movdia.transacc_suc <> '6801'
									AND bdicheq:sc_movdia.transacc IN transacciones
									AND bdicheq:sc_movdia.empresa = p_sNumeroEmpresa                      
								
								UNION ALL					  
								
								SELECT /*SKIP p_skip*/ DISTINCT fech_val, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, bdinteg:si_sucursales.nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad, CASE transacc_suc WHEN '0280' THEN '' ELSE referencia END AS ref_comercio, 'H', fech_val, fech_hor
								FROM bdicheq:sc_movhis 
									LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdicheq:sc_movhis.sucursal AND bdinteg:si_sucursales.empresa = p_sNumeroEmpresa) 
									LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdinteg:si_transacc.numero = bdicheq:sc_movhis.transacc AND bdicheq:sc_movhis.transacc <> '0801')
								WHERE bdicheq:sc_movhis.empresa= p_sNumeroEmpresa
									AND cuenta = p_sNumeroCuenta 
									AND fech_val <= p_sFechaFinal 
									AND fech_val >= p_sFechaInicial
									--AND (num_tarjeta = '' or num_tarjeta IS NULL)
									AND bdicheq:sc_movhis.transacc <> '0801'
									AND bdicheq:sc_movhis.transacc_suc <> '6801'
									AND bdicheq:sc_movhis.transacc IN transacciones					  
								
								UNION ALL					  
								
								SELECT {+INDEX(sc_movhis_old idx_movhiso1)} /*SKIP p_skip*/ DISTINCT fech_val, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, bdinteg:si_sucursales.nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad, CASE transacc_suc WHEN '0280' THEN '' ELSE referencia END AS ref_comercio, 'O', fech_val, fech_hor
								FROM bdicheq:sc_movhis_old 
									LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdicheq:sc_movhis_old.sucursal AND bdinteg:si_sucursales.empresa = p_sNumeroEmpresa) 
									LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdinteg:si_transacc.numero = bdicheq:sc_movhis_old.transacc AND bdicheq:sc_movhis_old.transacc <> '0801' AND bdicheq:sc_movhis_old.transacc_suc <> '6801')
								WHERE bdicheq:sc_movhis_old.empresa= p_sNumeroEmpresa
									AND cuenta = p_sNumeroCuenta
									AND cancelad <> "S"
									AND se_emite_edocta = "S"
									AND bdicheq:sc_movhis_old.transacc IN transacciones
									AND fech_val BETWEEN p_sFechaInicial AND p_sFechaFinal 
									--AND (num_tarjeta = '' or num_tarjeta IS NULL)
							))		 
						ORDER BY folio_suc ASC, fech_val ASC
						  
						  LET res_fechaMovimiento_re1=res_fechaMovimiento_ret;
						  LET res_horaMovimiento_re1=res_horaMovimiento_ret;
						IF (resultado_claveTipo in ('0830', '0832')) THEN
							SELECT  fech_val, fech_hor
								INTO res_fechaMovimiento_ret,  res_horaMovimiento_ret
							FROM bdicheq:sc_movhis
							WHERE empresa= p_sNumeroEmpresa
								AND cuenta=p_sNumeroCuenta
								AND fech_val BETWEEN p_sFechaInicial-31 AND p_sFechaFinal
								AND folio_suc = resultado_folioSuc
								AND transacc='0801';
								
							IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
								SELECT  fech_val, fech_hor
									INTO res_fechaMovimiento_ret,  res_horaMovimiento_ret
								FROM bdicheq:sc_movhis_old
								WHERE empresa= p_sNumeroEmpresa
									AND cuenta=p_sNumeroCuenta
									AND fech_val BETWEEN p_sFechaInicial-31 AND p_sFechaFinal
									AND folio_suc = resultado_folioSuc
									AND transacc='0801';
							END IF;
								
							IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
								SELECT  fech_val, fech_hor
									INTO res_fechaMovimiento_ret,  res_horaMovimiento_ret
								FROM bdicheq:sc_movhis_old2
								WHERE empresa= p_sNumeroEmpresa
									AND cuenta=p_sNumeroCuenta
									AND fech_val BETWEEN p_sFechaInicial-31 AND p_sFechaFinal
									AND folio_suc = resultado_folioSuc
									AND transacc='0801';
							END IF;							
								
							IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
								LET res_fechaMovimiento_ret=res_fechaMovimiento_re1;
								LET res_horaMovimiento_ret=res_horaMovimiento_re1;							
							END IF;
								
						END IF;	--IF (resultado_claveTipo in ('0830', '0832')) THEN
						
						RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret WITH RESUME;
                    
					END FOREACH;
                
				ELSE--IF p_sMonto IS NULL OR p_sMonto = 0 THEN
                    
					FOREACH   
						SELECT SKIP p_skip DISTINCT fech_val, fech_hor, monto_tot, folio_suc, sucursal,nombre,numero,descripcion, cancelad, ref_comercio, 'H', fech_val, fech_hor
							INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_reversado, resultado_refComercio, v_tabla, res_fechaMovimiento_ret, res_horaMovimiento_ret
						FROM table 
							(multiset (					
								SELECT /*SKIP p_skip*/ DISTINCT fech_val, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, bdinteg:si_sucursales.nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad, CASE transacc_suc WHEN '0280' THEN '' ELSE referencia END AS ref_comercio, 'D', fech_val, fech_hor
								FROM bdicheq:sc_movdia 
									LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa AND bdinteg:si_sucursales.sucursal = bdicheq:sc_movdia.sucursal) 
									LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdicheq:sc_movdia.transacc <> '0801' AND bdinteg:si_transacc.numero = bdicheq:sc_movdia.transacc)
								WHERE cuenta = p_sNumeroCuenta 
									AND fech_val <= p_sFechaFinal 
									AND fech_val >= p_sFechaInicial 
									AND monto_tot = p_sMonto
									--AND (num_tarjeta = '' OR num_tarjeta IS NULL)
									AND bdicheq:sc_movdia.transacc <> '0801'
									AND bdicheq:sc_movdia.transacc_suc <> '6801'
									AND bdicheq:sc_movdia.transacc IN transacciones
									AND bdicheq:sc_movdia.empresa = p_sNumeroEmpresa                      
								
								UNION ALL					  
							  
								SELECT /*SKIP p_skip*/ DISTINCT fech_val, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, bdinteg:si_sucursales.nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad, CASE transacc_suc WHEN '0280' THEN '' ELSE referencia END AS ref_comercio, 'H', fech_val, fech_hor				         -- INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_reversado, resultado_refComercio, v_tabla				          
								FROM bdicheq:sc_movhis 
									LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdicheq:sc_movhis.sucursal AND bdinteg:si_sucursales.empresa = p_sNumeroEmpresa) 
									LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdinteg:si_transacc.numero = bdicheq:sc_movhis.transacc AND bdicheq:sc_movhis.transacc <> '0801')
								WHERE bdicheq:sc_movhis.empresa= p_sNumeroEmpresa
									AND cuenta = p_sNumeroCuenta    
									AND fech_val <= p_sFechaFinal 
									AND fech_val >= p_sFechaInicial 
									AND monto_tot = p_sMonto
									--AND (num_tarjeta = '' or num_tarjeta IS NULL)
									AND bdicheq:sc_movhis.transacc <> '0801'
									AND bdicheq:sc_movhis.transacc_suc <> '6801'
									AND bdicheq:sc_movhis.transacc IN transacciones
									
								UNION ALL					  
								
								SELECT {+INDEX(sc_movhis_old idx_movhiso1)} /*SKIP p_skip*/ DISTINCT fech_val, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, bdinteg:si_sucursales.nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad, CASE transacc_suc WHEN '0280' THEN '' ELSE referencia END AS ref_comercio, 'O', fech_val, fech_hor
								FROM bdicheq:sc_movhis_old 
									LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdicheq:sc_movhis_old.sucursal AND bdinteg:si_sucursales.empresa = p_sNumeroEmpresa) 
									LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdinteg:si_transacc.numero = bdicheq:sc_movhis_old.transacc AND bdicheq:sc_movhis_old.transacc <> '0801' AND bdicheq:sc_movhis_old.transacc_suc <> '6801')
								WHERE bdicheq:sc_movhis_old.empresa= p_sNumeroEmpresa
									AND cuenta = p_sNumeroCuenta    
									AND cancelad <> "S"
									AND se_emite_edocta = "S"
									AND bdicheq:sc_movhis_old.transacc IN transacciones
									AND monto_tot = p_sMonto
									AND fech_val BETWEEN p_sFechaInicial AND p_sFechaFinal
									--AND (num_tarjeta = '' or num_tarjeta IS NULL)
							))
						ORDER BY folio_suc ASC, fech_val ASC
						  
						
						  LET res_fechaMovimiento_re1=res_fechaMovimiento_ret;
						  LET res_horaMovimiento_re1=res_horaMovimiento_ret;
						IF (resultado_claveTipo in ('0830', '0832')) THEN
							SELECT  fech_val, fech_hor
								INTO res_fechaMovimiento_ret,  res_horaMovimiento_ret
							FROM bdicheq:sc_movhis
							WHERE empresa= p_sNumeroEmpresa
								AND cuenta=p_sNumeroCuenta
								AND fech_val BETWEEN p_sFechaInicial-31 AND p_sFechaFinal
								AND folio_suc = resultado_folioSuc
								AND transacc='0801';
								
							IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
								SELECT  fech_val, fech_hor
									INTO res_fechaMovimiento_ret,  res_horaMovimiento_ret
								FROM bdicheq:sc_movhis_old
								WHERE empresa= p_sNumeroEmpresa
									AND cuenta=p_sNumeroCuenta
									AND fech_val BETWEEN p_sFechaInicial-31 AND p_sFechaFinal
									AND folio_suc = resultado_folioSuc
									AND transacc='0801';
							END IF;
								
							IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
								SELECT  fech_val, fech_hor
									INTO res_fechaMovimiento_ret,  res_horaMovimiento_ret
								FROM bdicheq:sc_movhis_old2
								WHERE empresa= p_sNumeroEmpresa
									AND cuenta=p_sNumeroCuenta
									AND fech_val BETWEEN p_sFechaInicial-31 AND p_sFechaFinal
									AND folio_suc = resultado_folioSuc
									AND transacc='0801';
							END IF;							
								
							IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
								LET res_fechaMovimiento_ret=res_fechaMovimiento_re1;
								LET res_horaMovimiento_ret=res_horaMovimiento_re1;							
							END IF;
								
						END IF;	--IF (resultado_claveTipo in ('0830', '0832')) THEN
						
						RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret WITH RESUME;
					END FOREACH;
				END IF;
		    END IF;
        --- Si el ID de transacciones no es nulo   
    	ELSE--IF(ids_transacciones IS NOT NULL) THEN
			
    		IF(p_sTarjeta IS NOT NULL AND p_sTarjeta <> '') THEN
                IF p_sMonto IS NULL OR p_sMonto = 0 THEN
                    FOREACH       
                    	SELECT SKIP p_skip DISTINCT fech_val, fech_hor, monto_tot, folio_suc, sucursal,nombre,numero,descripcion, cancelad, ref_comercio, 'H', fech_val, fech_hor
							INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_reversado, resultado_refComercio, v_tabla, res_fechaMovimiento_ret, res_horaMovimiento_ret
						FROM table 
							(multiset (
								SELECT /*SKIP p_skip*/ DISTINCT fech_val, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, bdinteg:si_sucursales.nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad, CASE transacc_suc WHEN '0280' THEN '' ELSE referencia END AS ref_comercio, 'D', fech_val, fech_hor
								FROM bdicheq:sc_movdia 
									LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa AND bdinteg:si_sucursales.sucursal = bdicheq:sc_movdia.sucursal) 
									LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdicheq:sc_movdia.transacc <> '0801' AND bdinteg:si_transacc.numero = bdicheq:sc_movdia.transacc)
								WHERE cuenta = p_sNumeroCuenta 
									AND fech_val <= p_sFechaFinal 
									AND fech_val >= p_sFechaInicial 
									--AND monto_tot = p_sMonto
									AND num_tarjeta = p_sTarjeta --OR num_tarjeta = '' OR num_tarjeta IS NULL)
									AND bdicheq:sc_movdia.transacc <> '0801'
									AND bdicheq:sc_movdia.transacc_suc <> '6801'
									AND bdicheq:sc_movdia.empresa = p_sNumeroEmpresa						   
								
								UNION ALL						   
								
								SELECT /*SKIP p_skip*/ DISTINCT fech_val, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, bdinteg:si_sucursales.nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad, CASE transacc_suc WHEN '0280' THEN '' ELSE referencia END AS ref_comercio, 'H', fech_val, fech_hor
								FROM bdicheq:sc_movhis 
									LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdicheq:sc_movhis.sucursal AND bdinteg:si_sucursales.empresa = p_sNumeroEmpresa) 
									LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdinteg:si_transacc.numero = bdicheq:sc_movhis.transacc AND bdicheq:sc_movhis.transacc <> '0801')
								WHERE bdicheq:sc_movhis.empresa= p_sNumeroEmpresa
									AND cuenta = p_sNumeroCuenta    
									AND fech_val <= p_sFechaFinal 
									AND fech_val >= p_sFechaInicial 
									--AND monto_tot = p_sMonto
									AND num_tarjeta = p_sTarjeta --or num_tarjeta = '' or num_tarjeta IS NULL)
									AND bdicheq:sc_movhis.transacc <> '0801'
									AND bdicheq:sc_movhis.transacc_suc <> '6801'
								
								UNION ALL
								
								SELECT {+INDEX(sc_movhis_old idx_movhiso1)} /*SKIP p_skip*/ DISTINCT fech_val, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, bdinteg:si_sucursales.nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad, CASE transacc_suc WHEN '0280' THEN '' ELSE referencia END AS ref_comercio, 'O', fech_val, fech_hor
								FROM bdicheq:sc_movhis_old 
									LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdicheq:sc_movhis_old.sucursal AND bdinteg:si_sucursales.empresa = p_sNumeroEmpresa) 
									LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdinteg:si_transacc.numero = bdicheq:sc_movhis_old.transacc AND bdicheq:sc_movhis_old.transacc <> '0801'AND bdicheq:sc_movhis_old.transacc_suc <> '6801')
								WHERE bdicheq:sc_movhis_old.empresa= p_sNumeroEmpresa
									AND cuenta = p_sNumeroCuenta    
									AND cancelad <> "S"
									AND se_emite_edocta = "S"
									----AND monto_tot = p_sMonto
									AND fech_val <= p_sFechaFinal 
									AND fech_val >= p_sFechaInicial 
									AND num_tarjeta = p_sTarjeta --or num_tarjeta = '' or num_tarjeta IS NULL)
							))   
						ORDER BY folio_suc ASC, fech_val ASC
			  						
						  LET res_fechaMovimiento_re1=res_fechaMovimiento_ret;
						  LET res_horaMovimiento_re1=res_horaMovimiento_ret;
						IF (resultado_claveTipo in ('0830', '0832')) THEN
							SELECT  fech_val, fech_hor
								INTO res_fechaMovimiento_ret,  res_horaMovimiento_ret
							FROM bdicheq:sc_movhis
							WHERE empresa= p_sNumeroEmpresa
								AND cuenta=p_sNumeroCuenta
								AND fech_val BETWEEN p_sFechaInicial-31 AND p_sFechaFinal
								AND folio_suc = resultado_folioSuc
								AND transacc='0801';
								
							IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
								SELECT  fech_val, fech_hor
									INTO res_fechaMovimiento_ret,  res_horaMovimiento_ret
								FROM bdicheq:sc_movhis_old
								WHERE empresa= p_sNumeroEmpresa
									AND cuenta=p_sNumeroCuenta
									AND fech_val BETWEEN p_sFechaInicial-31 AND p_sFechaFinal
									AND folio_suc = resultado_folioSuc
									AND transacc='0801';
							END IF;
								
							IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
								SELECT  fech_val, fech_hor
									INTO res_fechaMovimiento_ret,  res_horaMovimiento_ret
								FROM bdicheq:sc_movhis_old2
								WHERE empresa= p_sNumeroEmpresa
									AND cuenta=p_sNumeroCuenta
									AND fech_val BETWEEN p_sFechaInicial-31 AND p_sFechaFinal
									AND folio_suc = resultado_folioSuc
									AND transacc='0801';
							END IF;							
								
							IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
								LET res_fechaMovimiento_ret=res_fechaMovimiento_re1;
								LET res_horaMovimiento_ret=res_horaMovimiento_re1;							
							END IF;
								
						END IF;	--IF (resultado_claveTipo in ('0830', '0832')) THEN
						
						RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret WITH RESUME;
						
					END FOREACH;
                
				ELSE--IF p_sMonto IS NULL OR p_sMonto = 0 THEN
                    
					FOREACH       
                    	SELECT SKIP p_skip DISTINCT fech_val, fech_hor, monto_tot, folio_suc, sucursal,nombre,numero,descripcion, cancelad, ref_comercio, 'H', fech_val, fech_hor
							INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_reversado, resultado_refComercio, v_tabla, res_fechaMovimiento_ret, res_horaMovimiento_ret
						FROM table 
							(multiset (
								SELECT /*SKIP p_skip*/ DISTINCT fech_val, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, bdinteg:si_sucursales.nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad, CASE transacc_suc WHEN '0280' THEN '' ELSE referencia END AS ref_comercio, 'D', fech_val, fech_hor
								FROM bdicheq:sc_movdia 
									LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa AND bdinteg:si_sucursales.sucursal = bdicheq:sc_movdia.sucursal) 
									LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdicheq:sc_movdia.transacc <> '0801' AND bdinteg:si_transacc.numero = bdicheq:sc_movdia.transacc)
								WHERE cuenta = p_sNumeroCuenta 
									AND fech_val <= p_sFechaFinal 
									AND fech_val >= p_sFechaInicial 
									AND monto_tot = p_sMonto
									AND num_tarjeta = p_sTarjeta --OR num_tarjeta = '' OR num_tarjeta IS NULL)
									AND bdicheq:sc_movdia.transacc <> '0801'
									AND bdicheq:sc_movdia.transacc_suc <> '6801'
									AND bdicheq:sc_movdia.empresa = p_sNumeroEmpresa						   
								
								UNION ALL						   
								
								SELECT /*SKIP p_skip*/ DISTINCT fech_val, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, bdinteg:si_sucursales.nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad, CASE transacc_suc WHEN '0280' THEN '' ELSE referencia END AS ref_comercio, 'H', fech_val, fech_hor
								FROM bdicheq:sc_movhis 
									LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdicheq:sc_movhis.sucursal AND bdinteg:si_sucursales.empresa = p_sNumeroEmpresa) 
									LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdinteg:si_transacc.numero = bdicheq:sc_movhis.transacc AND bdicheq:sc_movhis.transacc <> '0801')
								WHERE bdicheq:sc_movhis.empresa= p_sNumeroEmpresa
									AND cuenta = p_sNumeroCuenta    
									AND fech_val <= p_sFechaFinal 
									AND fech_val >= p_sFechaInicial 
									AND monto_tot = p_sMonto
									AND num_tarjeta = p_sTarjeta --or num_tarjeta = '' or num_tarjeta IS NULL)
									AND bdicheq:sc_movhis.transacc <> '0801'
									AND bdicheq:sc_movhis.transacc_suc <> '6801'
								
								UNION ALL
								
								SELECT {+INDEX(sc_movhis_old idx_movhiso1)} /*SKIP p_skip*/ DISTINCT fech_val, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, bdinteg:si_sucursales.nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad, CASE transacc_suc WHEN '0280' THEN '' ELSE referencia END AS ref_comercio, 'O', fech_val, fech_hor
								FROM bdicheq:sc_movhis_old 
									LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdicheq:sc_movhis_old.sucursal AND bdinteg:si_sucursales.empresa = p_sNumeroEmpresa) 
									LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdinteg:si_transacc.numero = bdicheq:sc_movhis_old.transacc AND bdicheq:sc_movhis_old.transacc <> '0801'AND bdicheq:sc_movhis_old.transacc_suc <> '6801')
								WHERE bdicheq:sc_movhis_old.empresa= p_sNumeroEmpresa
									AND cuenta = p_sNumeroCuenta    
									AND cancelad <> "S"
									AND se_emite_edocta = "S"
									AND monto_tot = p_sMonto
									AND fech_val BETWEEN p_sFechaInicial AND p_sFechaFinal 
									AND num_tarjeta = p_sTarjeta --or num_tarjeta = '' or num_tarjeta IS NULL)
							))   
						ORDER BY folio_suc ASC, fech_val ASC
					  
						  LET res_fechaMovimiento_re1=res_fechaMovimiento_ret;
						  LET res_horaMovimiento_re1=res_horaMovimiento_ret;
						IF (resultado_claveTipo in ('0830', '0832')) THEN
							SELECT  fech_val, fech_hor
								INTO res_fechaMovimiento_ret,  res_horaMovimiento_ret
							FROM bdicheq:sc_movhis
							WHERE empresa= p_sNumeroEmpresa
								AND cuenta=p_sNumeroCuenta
								AND fech_val BETWEEN p_sFechaInicial-31 AND p_sFechaFinal
								AND folio_suc = resultado_folioSuc
								AND transacc='0801';
								
							IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
								SELECT  fech_val, fech_hor
									INTO res_fechaMovimiento_ret,  res_horaMovimiento_ret
								FROM bdicheq:sc_movhis_old
								WHERE empresa= p_sNumeroEmpresa
									AND cuenta=p_sNumeroCuenta
									AND fech_val BETWEEN p_sFechaInicial-31 AND p_sFechaFinal
									AND folio_suc = resultado_folioSuc
									AND transacc='0801';
							END IF;
								
							IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
								SELECT  fech_val, fech_hor
									INTO res_fechaMovimiento_ret,  res_horaMovimiento_ret
								FROM bdicheq:sc_movhis_old2
								WHERE empresa= p_sNumeroEmpresa
									AND cuenta=p_sNumeroCuenta
									AND fech_val BETWEEN p_sFechaInicial-31 AND p_sFechaFinal
									AND folio_suc = resultado_folioSuc
									AND transacc='0801';
							END IF;							
								
							IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
								LET res_fechaMovimiento_ret=res_fechaMovimiento_re1;
								LET res_horaMovimiento_ret=res_horaMovimiento_re1;							
							END IF;
								
						END IF;	--IF (resultado_claveTipo in ('0830', '0832')) THEN 
				
                        RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret WITH RESUME;
					END FOREACH;
				END IF;
				
            ELSE--IF(p_sTarjeta IS NOT NULL AND p_sTarjeta <> '') THEN
			  -- inicia flujo para sin numero de tarjeta 
                IF p_sMonto IS NULL OR p_sMonto = 0 THEN
                    FOREACH
						
						SELECT SKIP p_skip DISTINCT fech_val, fech_hor, monto_tot, folio_suc, sucursal,nombre,numero,descripcion, cancelad, ref_comercio, 'H', fech_val, fech_hor
							INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret
						FROM table 
							(multiset (
								SELECT /*SKIP p_skip*/ DISTINCT fech_val, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, bdinteg:si_sucursales.nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad, CASE transacc_suc WHEN '0280' THEN '' ELSE referencia END AS ref_comercio, 'D', fech_val, fech_hor
								FROM bdicheq:sc_movdia 
									LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa AND bdinteg:si_sucursales.sucursal = bdicheq:sc_movdia.sucursal) 
									LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdicheq:sc_movdia.transacc <> '0801' AND bdinteg:si_transacc.numero = bdicheq:sc_movdia.transacc)
								WHERE cuenta = p_sNumeroCuenta 
									AND fech_val <= p_sFechaFinal 
									AND fech_val >= p_sFechaInicial
									--AND (num_tarjeta = '' OR num_tarjeta IS NULL)
									AND bdicheq:sc_movdia.transacc <> '0801'
									AND bdicheq:sc_movdia.transacc_suc <> '6801'
									AND bdicheq:sc_movdia.empresa = p_sNumeroEmpresa

								UNION ALL
					   
								SELECT /*SKIP p_skip*/ DISTINCT fech_val, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, bdinteg:si_sucursales.nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad, CASE transacc_suc WHEN '0280' THEN '' ELSE referencia END AS ref_comercio, 'H', fech_val, fech_hor
								FROM bdicheq:sc_movhis 
									LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdicheq:sc_movhis.sucursal AND bdinteg:si_sucursales.empresa = p_sNumeroEmpresa) 
									LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdinteg:si_transacc.numero = bdicheq:sc_movhis.transacc AND bdicheq:sc_movhis.transacc <> '0801')
								WHERE bdicheq:sc_movhis.empresa = p_sNumeroEmpresa
									AND cuenta = p_sNumeroCuenta 
									AND fech_val <= p_sFechaFinal 
									AND fech_val >= p_sFechaInicial
									--AND (num_tarjeta = '' or num_tarjeta IS NULL)
									AND bdicheq:sc_movhis.transacc <> '0801'
									AND bdicheq:sc_movhis.transacc_suc <> '6801'
					   
								UNION ALL
								
								-- PRUEBA LMLA 03/08/2023 ****
								SELECT {+INDEX(sc_movhis_old idx_movhiso1)} /*SKIP p_skip*/ DISTINCT fech_val, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, bdinteg:si_sucursales.nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad, CASE transacc_suc WHEN '0280' THEN '' ELSE referencia END AS ref_comercio, 'O', fech_val, fech_hor
								--SELECT {+INDEX(sc_movhis_old idx_movhiso1)} /*SKIP p_skip*/ DISTINCT fech_val, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, bdinteg:si_sucursales.nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad, CASE transacc_suc WHEN '0280' THEN '' ELSE referencia END AS ref_comercio, fech_val, fech_hor
								FROM bdicheq:sc_movhis_old 
									LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdicheq:sc_movhis_old.sucursal AND bdinteg:si_sucursales.empresa = p_sNumeroEmpresa) 
									LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdinteg:si_transacc.numero = bdicheq:sc_movhis_old.transacc AND bdicheq:sc_movhis_old.transacc <> '0801' AND bdicheq:sc_movhis_old.transacc_suc <> '6801')
								WHERE bdicheq:sc_movhis_old.empresa = p_sNumeroEmpresa
									AND cuenta = p_sNumeroCuenta 
									AND cancelad <> "S"
									AND se_emite_edocta = "S"
									AND fech_val BETWEEN p_sFechaInicial AND p_sFechaFinal 
									--AND (num_tarjeta = '' or num_tarjeta IS NULL)
							))   
						ORDER BY folio_suc ASC, fech_val ASC

						IF (resultado_claveTipo ='0830') THEN 
							SELECT monto_tot
								INTO monto_cashback 
							FROM bdicheq:sc_movhis
							WHERE empresa= p_sNumeroEmpresa
								AND cuenta=p_sNumeroCuenta
								AND fech_val BETWEEN p_sFechaInicial AND p_sFechaFinal
								AND folio_suc = resultado_folioSuc
								AND transacc='0832';
							
							IF monto_cashback IS NULL THEN 
								SELECT monto_tot
									INTO monto_cashback 
								FROM bdicheq:sc_movhis_old
								WHERE empresa= p_sNumeroEmpresa
									AND cuenta=p_sNumeroCuenta
									AND fech_val BETWEEN p_sFechaInicial AND p_sFechaFinal
									AND folio_suc = resultado_folioSuc
									AND transacc='0832';
							END IF;
							
							IF monto_cashback IS NULL THEN 
								LET monto_cashback =0;
							END IF;
							
							let resultado_monto = resultado_monto + monto_cashback;
							
						END IF;
						
						RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret WITH RESUME;
                    END FOREACH;					
                ELSE--IF p_sMonto IS NULL OR p_sMonto = 0 THEN				
                    FOREACH					
						SELECT SKIP p_skip DISTINCT fech_val, fech_hor, monto_tot, folio_suc, sucursal,nombre,numero,descripcion, cancelad, ref_comercio, 'H', fech_val, fech_hor
							INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_reversado, resultado_refComercio, v_tabla, res_fechaMovimiento_ret, res_horaMovimiento_ret
						FROM table 
							(multiset (
							SELECT /*SKIP p_skip*/ DISTINCT fech_val, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, bdinteg:si_sucursales.nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad, CASE transacc_suc WHEN '0280' THEN '' ELSE referencia END AS ref_comercio, 'D', fech_val, fech_hor
								FROM bdicheq:sc_movdia 
									LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.empresa = p_sNumeroEmpresa AND bdinteg:si_sucursales.sucursal = bdicheq:sc_movdia.sucursal) 
									LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdicheq:sc_movdia.transacc <> '0801' AND bdinteg:si_transacc.numero = bdicheq:sc_movdia.transacc)
								WHERE cuenta = p_sNumeroCuenta 
									AND fech_val BETWEEN p_sFechaInicial AND p_sFechaFinal
									AND monto_tot = p_sMonto
									--AND (num_tarjeta = '' OR num_tarjeta IS NULL)
									AND bdicheq:sc_movdia.transacc <> '0801'
									AND bdicheq:sc_movdia.transacc_suc <> '6801'
									AND bdicheq:sc_movdia.empresa = p_sNumeroEmpresa
								UNION ALL

								SELECT /*SKIP p_skip*/ DISTINCT fech_val, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, bdinteg:si_sucursales.nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad, CASE transacc_suc WHEN '0280' THEN '' ELSE referencia END AS ref_comercio, 'H', fech_val, fech_hor
								FROM bdicheq:sc_movhis 
									LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdicheq:sc_movhis.sucursal AND bdinteg:si_sucursales.empresa = p_sNumeroEmpresa) 
									LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdinteg:si_transacc.numero = bdicheq:sc_movhis.transacc AND bdicheq:sc_movhis.transacc <> '0801')
								WHERE bdicheq:sc_movhis.empresa= p_sNumeroEmpresa
									AND cuenta = p_sNumeroCuenta    
									AND fech_val BETWEEN p_sFechaInicial AND p_sFechaFinal
									AND monto_tot = p_sMonto
									--AND (num_tarjeta = '' or num_tarjeta IS NULL)
									AND bdicheq:sc_movhis.transacc <> '0801'
									AND bdicheq:sc_movhis.transacc_suc <> '6801'

								UNION ALL
								   
								SELECT {+INDEX(sc_movhis_old idx_movhiso1)} /*SKIP p_skip*/ DISTINCT fech_val, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.sucursal, bdinteg:si_sucursales.nombre, bdinteg:si_transacc.numero, bdinteg:si_transacc.descripcion, cancelad, CASE transacc_suc WHEN '0280' THEN '' ELSE referencia END AS ref_comercio, 'O', fech_val, fech_hor
								FROM bdicheq:sc_movhis_old 
									LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdicheq:sc_movhis_old.sucursal AND bdinteg:si_sucursales.empresa = p_sNumeroEmpresa) 
									LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.empresa = p_sNumeroEmpresa AND bdinteg:si_transacc.numero = bdicheq:sc_movhis_old.transacc AND bdicheq:sc_movhis_old.transacc <> '0801' AND bdicheq:sc_movhis_old.transacc_suc <> '6801')
								WHERE bdicheq:sc_movhis_old.empresa= p_sNumeroEmpresa
									AND cuenta = p_sNumeroCuenta
									AND cancelad <> "S"
									AND se_emite_edocta = "S"
									AND monto_tot = p_sMonto
									AND fech_val BETWEEN p_sFechaInicial AND p_sFechaFinal
									--AND (num_tarjeta = '' or num_tarjeta IS NULL)
							))
						ORDER BY folio_suc ASC, fech_val ASC
						  LET res_fechaMovimiento_re1=res_fechaMovimiento_ret;
						  LET res_horaMovimiento_re1=res_horaMovimiento_ret;
						IF (resultado_claveTipo in ('0830', '0832')) THEN
							SELECT  fech_val, fech_hor
								INTO res_fechaMovimiento_ret,  res_horaMovimiento_ret
							FROM bdicheq:sc_movhis
							WHERE empresa= p_sNumeroEmpresa
								AND cuenta=p_sNumeroCuenta
								AND fech_val BETWEEN p_sFechaInicial-31 AND p_sFechaFinal
								AND folio_suc = resultado_folioSuc
								AND transacc='0801';
								
							IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
								SELECT  fech_val, fech_hor
									INTO res_fechaMovimiento_ret,  res_horaMovimiento_ret
								FROM bdicheq:sc_movhis_old
								WHERE empresa= p_sNumeroEmpresa
									AND cuenta=p_sNumeroCuenta
									AND fech_val BETWEEN p_sFechaInicial-31 AND p_sFechaFinal
									AND folio_suc = resultado_folioSuc
									AND transacc='0801';
							END IF;
								
							IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
								SELECT  fech_val, fech_hor
									INTO res_fechaMovimiento_ret,  res_horaMovimiento_ret
								FROM bdicheq:sc_movhis_old2
								WHERE empresa= p_sNumeroEmpresa
									AND cuenta=p_sNumeroCuenta
									AND fech_val BETWEEN p_sFechaInicial-31 AND p_sFechaFinal
									AND folio_suc = resultado_folioSuc
									AND transacc='0801';
							END IF;							
								
							IF (res_fechaMovimiento_ret is null  OR res_fechaMovimiento_ret='') THEN 
								LET res_fechaMovimiento_ret=res_fechaMovimiento_re1;
								LET res_horaMovimiento_ret=res_horaMovimiento_re1;							
							END IF;
								
						END IF;	--IF (resultado_claveTipo in ('0830', '0832')) THEN
							
							--IF monto_cashback IS NULL THEN 
								--LET monto_cashback =0;
							--END IF;
							
						--	let resultado_monto = resultado_monto + monto_cashback;						
						
						
						RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_sucursal, resultado_nombre, resultado_claveTipo, resultado_tipo, resultado_reversado, resultado_refComercio, res_fechaMovimiento_ret, res_horaMovimiento_ret WITH RESUME;
										
					END FOREACH;                
				END IF;
			END IF;
    	END IF;
	END 
	
END PROCEDURE;