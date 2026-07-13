CREATE PROCEDURE "informix".sp_buscar_movimientos_inversiones_dia_corporativo(p_sNumeroCuenta CHAR(30), p_sFechaInicial DATE, p_sFechaFinal DATE, p_numeroCliente CHAR(20), p_skip INT, p_sEmpresa CHAR(4))

     RETURNING	DATE AS fechaMovimiento, DATETIME HOUR TO FRACTION(3) AS horaMovimiento , money(16,2) AS monto, 
                CHAR(30) AS folioSuc, CHAR(40) AS nombreSucursal, CHAR(40) AS tipo, 
                CHAR(1) AS reversado, CHAR(10) AS id, CHAR(20) AS cuenta, CHAR(1) AS naturaleza;

	--definicion de variables--	    
	DEFINE resultado_fechaMovimiento 	DATE;
	DEFINE resultado_monto              money(16,2);
	DEFINE resultado_horaMovimiento		DATETIME HOUR TO FRACTION(3);
	DEFINE resultado_folioSuc           CHAR(30);
    DEFINE resultado_nombreSucursal     CHAR(40);
    DEFINE resultado_tipo               CHAR(40);
    DEFINE resultado_reversado         	CHAR(1);
    DEFINE resultado_id                 CHAR(10);
    DEFINE resultado_cuenta             CHAR(20);
    DEFINE resultado_naturaleza         CHAR(1);
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
                    RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, 
                            resultado_folioSuc, resultado_nombreSucursal, resultado_tipo, 
                            resultado_reversado, resultado_id, resultado_cuenta,resultado_naturaleza;
                END IF;
        END EXCEPTION;

                IF (p_sNumeroCuenta IS NOT NULL AND p_sNumeroCuenta <> '') THEN
                    FOREACH       
                        SELECT SKIP p_skip DISTINCT fech_alt, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.nombre, bdinteg:si_transacc.descripcion, cancelad, transacc, cuenta,bdinteg:si_transacc.naturaleza
                          INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_nombreSucursal, resultado_tipo, resultado_reversado, resultado_id, resultado_cuenta,resultado_naturaleza
                          FROM bdinvers:sv_movdia
                            LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdinvers:sv_movdia.sucursal AND bdinteg:si_sucursales.empresa = p_sEmpresa) 
                            LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.numero = bdinvers:sv_movdia.transacc AND bdinteg:si_transacc.empresa = p_sEmpresa)
                          WHERE fech_alt <= p_sFechaFinal 
                            AND fech_alt >= p_sFechaInicial 
                            AND cuenta = p_sNumeroCuenta
                            AND bdinvers:sv_movdia.empresa = p_sEmpresa
                          ORDER BY folio_suc asC, fech_alt asC
                          RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_nombreSucursal, resultado_tipo, resultado_reversado, resultado_id, resultado_cuenta,resultado_naturaleza WITH RESUME;
                    END FOREACH;
                ELSE
                    FOREACH       
                        SELECT SKIP p_skip DISTINCT fech_alt, fech_hor, monto_tot, folio_suc, bdinteg:si_sucursales.nombre, bdinteg:si_transacc.descripcion, cancelad, transacc, bdinvers:sv_maeinv.cuenta,bdinteg:si_transacc.naturaleza
                          INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_nombreSucursal, resultado_tipo, resultado_reversado, resultado_id, resultado_cuenta,resultado_naturaleza
                          FROM bdinvers:sv_movdia
                            LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdinvers:sv_movdia.sucursal AND bdinteg:si_sucursales.empresa = p_sEmpresa) 
                            LEFT JOIN bdinteg:si_transacc ON (bdinteg:si_transacc.numero = bdinvers:sv_movdia.transacc AND bdinteg:si_transacc.empresa = p_sEmpresa)
                            LEFT JOIN bdinvers:sv_maeinv ON (bdinvers:sv_movdia.cuenta = bdinvers:sv_maeinv.cuenta AND bdinvers:sv_maeinv.empresa = p_sEmpresa)
                          WHERE fech_alt <= p_sFechaFinal 
                            AND fech_alt >= p_sFechaInicial 
                            AND num_cte = p_numeroCliente
                            AND bdinvers:sv_movdia.empresa = p_sEmpresa
                          ORDER BY folio_suc asC, fech_alt asC
                          RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_folioSuc, resultado_nombreSucursal, resultado_tipo, resultado_reversado, resultado_id, resultado_cuenta,resultado_naturaleza WITH RESUME;
                    END FOREACH;
                END IF;
	END 
END PROCEDURE;