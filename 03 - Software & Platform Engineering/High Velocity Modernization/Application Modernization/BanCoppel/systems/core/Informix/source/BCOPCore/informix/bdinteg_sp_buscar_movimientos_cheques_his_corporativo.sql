CREATE PROCEDURE "informix".sp_buscar_movimientos_cheques_his_corporativo(p_sNumeroCuenta CHAR(30), p_sFechaInicial DATE, p_sFechaFinal DATE, p_numeroCliente CHAR(20), p_skip INT, p_sTarjeta CHAR(30), p_sEmpresa CHAR(4))

     RETURNING	DATE AS fechaMovimiento, DATETIME HOUR to FRACTION(3) AS horaMovimiento , money(16,2) AS monto, 
                CHAR(30) AS folioSuc, CHAR(40) AS nombreSucursal, CHAR(40) AS tipo, CHAR(1) AS reversado, CHAR(10) AS id, 
                CHAR(20) AS cuenta, CHAR(1) AS naturaleza,CHAR(40) AS referencia, CHAR(20) AS tarjeta;

	--definicion de variables--	    
	DEFINE resultado_fechaMovimiento    DATE;
	DEFINE resultado_monto			money(16,2);
	DEFINE resultado_horaMovimiento		DATETIME HOUR to FRACTION(3);
	DEFINE resultado_folioSuc			CHAR(30);
	DEFINE resultado_nombreSucursal     CHAR(40);
	DEFINE resultado_tipo   			CHAR(40);
	DEFINE resultado_reversado          CHAR(1);
	DEFINE resultado_id                 CHAR(10);
	DEFINE resultado_cuenta             CHAR(20);
	DEFINE resultado_naturaleza         CHAR(1);
	DEFINE resultado_referencia         CHAR(40);
	DEFINE resultado_tarjeta            CHAR(20);
	DEFINE cuenta_temp                  CHAR(20);
	DEFINE iSqlErr                      INTEGER;
	
	/*VJMP Cuenta Transfer*/
	DEFINE cuenta_temp_tf              	CHAR(20);
     
     -- InicializaciÃ?Â³n de las variables.
	LET resultado_fechaMovimiento = '';
	LET resultado_monto = '';
	LET resultado_horaMovimiento = TO_DATE("00:00","%H:%M");
	LET resultado_folioSuc = '';
    LET resultado_nombreSucursal = '';
	LET resultado_tipo = '';
    LET resultado_reversado = '';
    LET resultado_id = '';
    LET resultado_cuenta = '';    
    LET resultado_naturaleza = '';
    LET resultado_referencia = '';
    LET resultado_tarjeta = '';

    SET ISOLATION TO DIRTY READ;

	BEGIN

        ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET resultado_fechaMovimiento = '';
                    LET resultado_monto = '';
                    LET resultado_horaMovimiento = TO_DATE("00:00","%H:%M");
                    LET resultado_folioSuc = '';
                    LET resultado_nombreSucursal = '';
                    LET resultado_tipo = '';
                    LET resultado_reversado = '';
                    LET resultado_id = '';
                    LET resultado_cuenta = '';
                    LET resultado_naturaleza = '';
                    LET resultado_referencia = '';
                    LET resultado_tarjeta = '';
                    RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_nombreSucursal, resultado_tipo, resultado_reversado, resultado_id, resultado_cuenta,resultado_naturaleza,resultado_referencia, resultado_tarjeta;
                END IF;
        END EXCEPTION;

            IF(p_sTarjeta IS NOT NULL AND p_sTarjeta <> '') THEN
					
				/*Elimina Movimientos TRANSFER Tarjeta VJMP Inicio*/
				Select mc.cuenta_tf
					INTO cuenta_temp_tf
					From bditransfer:tf_maecte mc
					Inner Join bdicheq:sc_tarjeta t ON ( t.cuenta = mc.cuenta_tf)
					where t.num_tarjeta = p_sTarjeta;
				
				IF cuenta_temp_tf IS NULL Or cuenta_temp_tf = '' THEN
				/*Elimina Movimientos TRANSFER Tarjeta VJMP Fin*/
                    select distinct numcuenta
                    into cuenta_temp
                    from intercard:tarjetacuenta 
                    where numtarjeta = p_sTarjeta;

                    FOREACH       
                        SELECT SKIP p_skip DISTINCT fech_val, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.nombre, bdinteg:si_transacc.descripcion, cancelad, transacc, cuenta,bdinteg:si_transacc.naturaleza,referencia, num_tarjeta
                          INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_nombreSucursal, resultado_tipo, resultado_reversado, resultado_id, resultado_cuenta, resultado_naturaleza,resultado_referencia,resultado_tarjeta
                          FROM bdicheq:sc_movhis 
                            LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdicheq:sc_movhis.sucursal AND bdinteg:si_sucursales.empresa = p_sEmpresa) 
                            LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.numero = bdicheq:sc_movhis.transacc AND bdinteg:si_transacc.empresa = p_sEmpresa)
                          WHERE bdicheq:sc_movhis.empresa = p_sEmpresa
                            AND cuenta = cuenta_temp
                            AND fech_val <= p_sFechaFinal 
                            AND fech_val >= p_sFechaInicial 
                            AND num_tarjeta = p_sTarjeta
                          ORDER BY folio_suc asC, fech_val asC
                          RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_nombreSucursal, resultado_tipo, resultado_reversado, resultado_id, resultado_cuenta,resultado_naturaleza,resultado_referencia, resultado_tarjeta WITH RESUME;
                    END FOREACH;
				End If;
            ELSE
				/*Movimientos TRANSFER Cuenta VJMP Inicio*/
				Select cuenta_tf
					INTO cuenta_temp_tf
					from bditransfer:tf_maecte 
					where cuenta_tf = p_sNumeroCuenta;
				
				IF cuenta_temp_tf IS NULL Or cuenta_temp_tf = '' THEN
				/*Elimina Movimientos TRANSFER Cuenta VJMP Fin*/
				
					IF (p_sNumeroCuenta IS NOT NULL AND p_sNumeroCuenta <> '') THEN
						FOREACH       
							SELECT SKIP p_skip DISTINCT fech_val, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.nombre, bdinteg:si_transacc.descripcion, cancelad, transacc, cuenta,bdinteg:si_transacc.naturaleza,referencia, num_tarjeta
							  INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_nombreSucursal, resultado_tipo, resultado_reversado, resultado_id, resultado_cuenta,resultado_naturaleza,resultado_referencia, resultado_tarjeta
							  FROM bdicheq:sc_movhis
								LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdicheq:sc_movhis.sucursal AND bdinteg:si_sucursales.empresa = p_sEmpresa) 
								LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.numero = bdicheq:sc_movhis.transacc AND bdinteg:si_transacc.empresa = p_sEmpresa)
							  WHERE cuenta = p_sNumeroCuenta
								AND bdicheq:sc_movhis.empresa = p_sEmpresa
								AND fech_val >= p_sFechaInicial 
								AND fech_val <= p_sFechaFinal 
							  ORDER BY folio_suc asC, fech_val asC
							  RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_nombreSucursal, resultado_tipo, resultado_reversado, resultado_id, resultado_cuenta,resultado_naturaleza,resultado_referencia, resultado_tarjeta WITH RESUME;
						END FOREACH;
					ELSE
						FOREACH       
							SELECT SKIP p_skip DISTINCT fech_val, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.nombre, bdinteg:si_transacc.descripcion, cancelad, transacc, bdicheq:sc_maechq.cuenta,bdinteg:si_transacc.naturaleza,referencia, num_tarjeta
							  INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_nombreSucursal, resultado_tipo, resultado_reversado, resultado_id, resultado_cuenta,resultado_naturaleza,resultado_referencia, resultado_tarjeta
							  FROM bdicheq:sc_movhis 
								LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdicheq:sc_movhis.sucursal AND bdinteg:si_sucursales.empresa = p_sEmpresa) 
								LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.numero = bdicheq:sc_movhis.transacc AND bdinteg:si_transacc.empresa = p_sEmpresa)
								LEFT JOIN bdicheq:sc_maechq ON (bdicheq:sc_movhis.cuenta = bdicheq:sc_maechq.cuenta AND bdicheq:sc_maechq.empresa = p_sEmpresa)
							  WHERE num_cte = p_numeroCliente
								AND bdicheq:sc_movhis.empresa = p_sEmpresa
								AND fech_val >= p_sFechaInicial 
								AND fech_val <= p_sFechaFinal 
							  ORDER BY folio_suc asC, fech_val asC
							  RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_nombreSucursal, resultado_tipo, resultado_reversado, resultado_id, resultado_cuenta, resultado_naturaleza,resultado_referencia,resultado_tarjeta WITH RESUME;
						END FOREACH;
					END IF;
				End If;
           END IF;
	END 
END PROCEDURE;