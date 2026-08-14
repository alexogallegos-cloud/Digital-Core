CREATE PROCEDURE "informix".sp_buscar_movimientos_credito_his_corporativo(p_sNumeroCuenta CHAR(30), p_sFechaInicial DATE, p_sFechaFinal DATE, p_numeroCliente CHAR(20), p_skip INT, p_sTarjeta CHAR(30), p_sEmpresa CHAR(4))

     RETURNING	DATE AS fechaMovimiento, DATETIME HOUR TO FRACTION(3) AS horaMovimiento , money(16,2) AS monto, 
                CHAR(30) AS folioSuc, CHAR(40) AS nombreSucursal, CHAR(40) AS tipo, CHAR(1) AS reversado, 
                CHAR(10) AS id, CHAR(20) AS cuenta,CHAR(1) AS naturaleza,CHAR(40) AS referencia, CHAR(20) AS tarjeta;

	--definicion de variables--	    
	DEFINE resultado_fechaMovimiento 	DATE;
	DEFINE resultado_monto				money(16,2);
	DEFINE resultado_horaMovimiento		DATETIME HOUR TO FRACTION(3);
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
     
     	-- InicializaciÃÂ³n de las variables.
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
                    RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, 
                            resultado_nombreSucursal, resultado_tipo, resultado_reversado, resultado_id, 
                            resultado_cuenta,resultado_naturaleza,resultado_referencia, resultado_tarjeta;
                END IF;
        END EXCEPTION;

            IF(p_sTarjeta IS NOT NULL AND p_sTarjeta <> '') THEN
                	SELECT DISTINCT numcuenta
                    	INTO cuenta_temp
                   	FROM intercard:tarjetacuenta 
                   	WHERE numtarjeta = p_sTarjeta;

                    FOREACH       
                        SELECT SKIP p_skip DISTINCT fecha_mov, hora_mov, monto, folio_suc, bdinteg:si_sucursales.nombre, bdinteg:si_transacc.descripcion, reversado, transacc_suc, num_credito, bdinteg:si_transacc.naturaleza,referencia,nro_tarjeta
                          INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_nombreSucursal, resultado_tipo, resultado_reversado, resultado_id, resultado_cuenta, resultado_naturaleza,resultado_referencia,resultado_tarjeta
                          FROM bdicred:sd_movhis 
                            LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdicred:sd_movhis.sucursal AND bdinteg:si_sucursales.empresa = p_sEmpresa) 
                            LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.numero = bdicred:sd_movhis.transacc_suc AND bdinteg:si_transacc.empresa = p_sEmpresa)
                          WHERE fecha_mov <= p_sFechaFinal 
                            AND fecha_mov >= p_sFechaInicial 
                            AND nro_tarjeta = p_sTarjeta
                            AND bdicred:sd_movhis.empresa = p_sEmpresa
                            AND num_credito = cuenta_temp
                          ORDER BY folio_suc asC, fecha_mov asC
                          RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_nombreSucursal, resultado_tipo, resultado_reversado, resultado_id, resultado_cuenta,resultado_naturaleza,resultado_referencia, resultado_tarjeta WITH RESUME;
                    END FOREACH;
            ELSE
                IF (p_sNumeroCuenta IS NOT NULL AND p_sNumeroCuenta <> '') THEN
                    FOREACH       
                        SELECT SKIP p_skip DISTINCT fecha_mov, hora_mov, monto, folio_suc, bdinteg:si_sucursales.nombre, bdinteg:si_transacc.descripcion, reversado, transacc_suc, num_credito, bdinteg:si_transacc.naturaleza,referencia,nro_tarjeta
                          INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_nombreSucursal, resultado_tipo, resultado_reversado, resultado_id, resultado_cuenta, resultado_naturaleza,resultado_referencia,resultado_tarjeta
                          FROM bdicred:sd_movhis
                            LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdicred:sd_movhis.sucursal AND bdinteg:si_sucursales.empresa = p_sEmpresa) 
                            LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.numero = bdicred:sd_movhis.transacc_suc AND bdinteg:si_transacc.empresa = p_sEmpresa)
                          WHERE fecha_mov <= p_sFechaFinal 
                            AND fecha_mov >= p_sFechaInicial 
                            AND num_credito = p_sNumeroCuenta
                            AND bdicred:sd_movhis.empresa = p_sEmpresa
                          ORDER BY folio_suc asC, fecha_mov asC
                          RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_nombreSucursal, resultado_tipo, resultado_reversado, resultado_id, resultado_cuenta,resultado_naturaleza,resultado_referencia, resultado_tarjeta WITH RESUME;
                    END FOREACH;
                ELSE
                    FOREACH       
                        SELECT SKIP p_skip DISTINCT fecha_mov, hora_mov, monto, folio_suc, bdinteg:si_sucursales.nombre, bdinteg:si_transacc.descripcion, reversado, transacc_suc, bdicred:sd_movhis.num_credito, bdinteg:si_transacc.naturaleza,referencia,nro_tarjeta
                          INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_nombreSucursal, resultado_tipo, resultado_reversado, resultado_id, resultado_cuenta,resultado_naturaleza,resultado_referencia, resultado_tarjeta
                          FROM bdicred:sd_movhis
                            LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdicred:sd_movhis.sucursal AND bdinteg:si_sucursales.empresa = p_sEmpresa) 
                            LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.numero = bdicred:sd_movhis.transacc_suc AND bdinteg:si_transacc.empresa = p_sEmpresa)
                            LEFT JOIN bdicred:sd_maecred ON (bdicred:sd_movhis.num_credito = bdicred:sd_maecred.num_credito AND bdicred:sd_maecred.empresa = p_sEmpresa)
                          WHERE fecha_mov <= p_sFechaFinal 
                            AND fecha_mov >= p_sFechaInicial 
                            AND numcte = p_numeroCliente
                            AND bdicred:sd_movhis.empresa = p_sEmpresa
                          ORDER BY folio_suc asC, fecha_mov asC
                          RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_nombreSucursal, resultado_tipo, resultado_reversado, resultado_id, resultado_cuenta,resultado_naturaleza,resultado_referencia, resultado_tarjeta WITH RESUME;
                    END FOREACH;
                END IF;
           END IF;
	END 
END PROCEDURE;