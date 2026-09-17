CREATE PROCEDURE "informix".trans_prestamo( pc_costos CHAR(4),
                                            pusuario CHAR(8),
                                            pfolio CHAR(16),
                                            pcuenta CHAR(20),
                                            pnum_tarjeta CHAR(16),
                                            pfecha DATE,
                                            pmto_tot DECIMAL(14,2),
                                            pmoneda CHAR(3),
                                            preferencia CHAR(40) )
RETURNING CHAR(5), CHAR(11);
    
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    
    DEFINE vfecha_hoy       DATE;
    DEFINE vfecha_tpcambio  DATE;
    DEFINE vprecio_udi      DECIMAL(14,6);
    DEFINE vmonto_udi       DECIMAL(18,6);
    DEFINE vmtoacumcta      DECIMAL(18,6);
    DEFINE vmtopagosudi     DECIMAL(18,6);
    DEFINE vlim_cuenta      DECIMAL(18,6);
    DEFINE vporcapcorres    DECIMAL(9,6);
    DEFINE vmtoglobcap      DECIMAL(20,6);
    DEFINE vmtomensacum     DECIMAL(20,6);
    DEFINE vexiste          CHAR(20);
    DEFINE vtransaccion     SMALLINT;
    DEFINE vtranprestcoppel CHAR(4);
    DEFINE vnomaxudis       SMALLINT;
    DEFINE vhoramax         datetime hour to minute;
    DEFINE wcuenta          CHAR(20);
    DEFINE vstatus_tar      CHAR(1);
    DEFINE vproceso         CHAR(1);
    DEFINE vind_cierre      CHAR(1);
    DEFINE vind_dispon      CHAR(1);
    DEFINE vexiste_hoy      SMALLINT;
    DEFINE vexiste_mes      SMALLINT;
    DEFINE vtrx_dia         SMALLINT;
    DEFINE vtrx_mes         SMALLINT;
    DEFINE vnumcte          CHAR(20);
    DEFINE vtranabono  		CHAR(4);
    DEFINE vmto_perm        DECIMAL(14,2);
    
    LET sql_err  = 0;
    LET isam_err = 0;
    LET vcodret1 = '000';
    LET vcodret2 = '000';
    LET vproceso = '0';
    
    LET vfecha_hoy       = '';
    LET vfecha_tpcambio  = '';
    LET vprecio_udi      = 0.00;
    LET vmonto_udi       = 0.00;
    LET vmtoacumcta      = 0.00;
    LET vmtopagosudi     = 0.00;
    LET vlim_cuenta      = 0.00;
    LET vporcapcorres    = 0.00;
    LET vmtoglobcap      = 0.00;
    LET vmtomensacum     = 0.00;
    LET vexiste          = '';
    LET vtransaccion     = 0;
    LET vnomaxudis       = 0;
    LET vhoramax         = '';
    LET vtranprestcoppel = '';
    LET wcuenta          = '';
    LET vstatus_tar      = '';
    LET vind_cierre      = '0';
    LET vind_dispon      = '0';
    LET vexiste_hoy      = 0;
    LET vexiste_mes      = 0;
    LET vtrx_dia         = 0;
    LET vtrx_mes         = 0;
    LET vnumcte          = '';
    LET vtranabono    	 = '';
    LET vmto_perm        = 0.00;
    
    --- SET DEBUG FILE TO "trans_prestamo.out";
    --- TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err
        -- SET DEBUG FILE TO "/resplogifx/conciliachq/trans_prestamo.err";
        -- TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            IF vproceso = '1' THEN
                LET vcodret1 = '000';
            END IF;
            RETURN vcodret1, TRIM(pcuenta);
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // Obtiene fechas del sistema de cheques
    SELECT fecha_hoy, ind_cierre, ind_disponible
      INTO vfecha_hoy, vind_cierre, vind_dispon
      FROM bdicheq:sc_fechas 
     WHERE empresa = '001';
     
    IF ( vind_cierre = '0' OR vind_dispon = '0' ) THEN
        LET vcodret1 = '004';
        RETURN vcodret1, TRIM(pcuenta);
    END IF;
    
    -- // VALIDACION DE PARAMETROS
    LET pmto_tot = pmto_tot / 100;
    
    IF ( pc_costos is null OR pc_costos = '' OR LENGTH(pc_costos) <> 4 ) OR 
       ( pusuario is null OR pusuario = '' OR LENGTH(pusuario) <> 8 ) OR
       ( pfolio is null OR pfolio = '' OR LENGTH(pfolio) <> 16 ) OR
       ( ( pcuenta is null OR pcuenta = '' OR LENGTH(pcuenta) <> 11 ) AND ( pnum_tarjeta is null OR pnum_tarjeta = '' OR LENGTH(pnum_tarjeta) <> 16 ) ) OR
       ( pfecha is null OR pfecha = '' ) OR
       ( pmto_tot is null OR pmto_tot <= 0.00 ) OR
       ( pmoneda is null OR pmoneda = '' OR LENGTH(pmoneda) <> 03 ) THEN
        LET vcodret1 = '110';
        RETURN vcodret1, TRIM(pcuenta);
    END IF;
    
    IF LENGTH(pmoneda) = 03 THEN
        LET pmoneda = pmoneda[2,3];
    END IF;
    
    -- // OBTIENE DATOS DE LA CUENTA DE CHEQUES
    IF pcuenta is null OR pcuenta = '' THEN
        SELECT cuenta, status_tar, numcte
          INTO pcuenta, vstatus_tar, vnumcte
          FROM bdicheq:sc_tarjeta
         WHERE empresa = '001'
           AND num_tarjeta = pnum_tarjeta;
           
        IF vstatus_tar <> 'A' THEN
            LET vcodret1 = '200';
            RETURN vcodret1, TRIM(pcuenta);
        END IF;
    END IF;

    IF pnum_tarjeta is null OR pnum_tarjeta = '' THEN
        SELECT num_tarjeta, numcte
          INTO pnum_tarjeta, vnumcte
          FROM bdicheq:sc_tarjeta
         WHERE empresa = '001'
           AND cuenta = pcuenta
           AND secuencia = (SELECT max(secuencia)
                              FROM bdicheq:sc_tarjeta
                             WHERE empresa = '001'
                               AND cuenta = pcuenta)
           AND status_tar = 'A';
           
        IF pnum_tarjeta is null THEN
            LET pnum_tarjeta = '';
        END IF;
    END IF;
    
    -- // VALIDA EL NUMERO DE CLIENTE
    IF vnumcte is null OR vnumcte = '' THEN
        SELECT num_cte
          INTO vnumcte
          FROM bdicheq:sc_maechq
         WHERE empresa = '001'
           AND cuenta = pcuenta;
    END IF;
    
    -- // VALIDA TRANSACCIONES PERMITIDAS POR DIA
    SELECT valor::int
      INTO vtrx_dia
      FROM bdicheq:sc_param
     WHERE empresa = '001'
       AND codparam = 'NoTrxsDiaTranPres';
       
    SELECT COUNT(*)
      INTO vexiste_hoy
      FROM bdicheq:sc_acumtrapres
     WHERE numcte = vnumcte
       AND fecha = vfecha_hoy;
       
    IF vexiste_hoy >= vtrx_dia THEN
        LET vcodret1 = '302';
        RETURN vcodret1, TRIM(pcuenta);
    END IF;
    
    -- // VALIDA TRANSACCIONESPOR PERMITIDAS POR MES
    SELECT valor::int
      INTO vtrx_mes
      FROM bdicheq:sc_param
     WHERE empresa = '001'
       AND codparam = 'NoTrxsMesTranPres';
    
    SELECT COUNT(*)
      INTO vexiste_mes
      FROM bdicheq:sc_acumtrapres
     WHERE numcte = vnumcte;
       
    IF vexiste_mes >= vtrx_mes THEN
        LET vcodret1 = '302';
        RETURN vcodret1, TRIM(pcuenta);
    END IF;
    
    -- // OBTIENE NUMERO DE TRANSACCION
    SELECT TRIM(valor)
      INTO vtranprestcoppel
      FROM bdicheq:sc_param
     WHERE empresa = '001'
       AND codparam = "tranprestcoppel";
    
    IF vtranprestcoppel is null OR vtranprestcoppel = '' THEN
        LET vcodret1 = '110';
        RETURN vcodret1, TRIM(pcuenta);
    END IF;
    
    -- // VALIDA MONTO PERMITIDO PARA PRESTAMOS
	SELECT trans
	  INTO vtranabono
	  FROM bditrapres:sc_tipo_trans
	 WHERE clave = '20';
    
    IF vtranabono = vtranprestcoppel THEN
        SELECT valor::decimal(14,2)
          INTO vmto_perm
          FROM bdicheq:sc_param
         WHERE empresa = '001'
           AND codparam = 'MtoPermitidoTranPres';

        IF pmto_tot > vmto_perm THEN
            LET vcodret1 = '302';
            RETURN vcodret1, TRIM(pcuenta);
        END IF;
    END IF;
    
    -- // APLICA TRANSACCION DE ABONO EN LA CUENTA DE CHEQUES
    EXECUTE PROCEDURE bdicheq:abono_ref( "001",             --- empresa
                                         pc_costos,         --- sucursal
                                         pusuario,          --- usuario
                                         vtranprestcoppel,  --- transaccion
                                         "0000",            --- transaccion suc
                                         pfolio,            --- folio suc
                                         pcuenta,           --- cuenta
                                         0,                 --- cheque
                                         pmto_tot,          --- monto total
                                         pmto_tot,          --- monto firme
                                         0,                 --- monto SBC
                                         0,                 --- monto REM
                                         0,                 --- dias ret
                                         pmoneda,           --- divisa
                                         preferencia,       --- referencia
                                         pnum_tarjeta,      --- no. tarjeta
                                         " " )              --- usuario autoriza
    INTO vcodret1;
    
    IF vcodret1 = '000' THEN
        LET vproceso = '1';
        
        INSERT INTO bdicheq:sc_acumtrapres VALUES
        ( pcuenta, pfolio, pmto_tot, vfecha_hoy, vnumcte );
    ELSE
        IF vcodret1 = '110' OR
           vcodret1 = '106' OR
           vcodret1 = '420' OR
           vcodret1 = '552' OR
           vcodret1 = '959' OR
           vcodret1 = '956' OR
           vcodret1 = '401' OR
           vcodret1 = '549' THEN
            LET vcodret1 = '110';
        END IF;

        IF vcodret1 = '100' THEN
            LET vcodret1 = '100';
        END IF;

        IF vcodret1 = '200' THEN
            LET vcodret1 = '200';
        END IF;

        IF vcodret1 = '951' THEN
            LET vcodret1 = '951';
        END IF;

        IF vcodret1 = '301' THEN
            LET vcodret1 = '302';
        END IF;

        RETURN vcodret1, TRIM(pcuenta);
    END IF;

    RETURN vcodret1, TRIM(pcuenta);

    END;

END PROCEDURE;