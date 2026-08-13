CREATE PROCEDURE "informix".arrpagoint_18082010(pempresa CHAR(3))
RETURNING CHAR(5);

   -- ************* DECLARACION DE VARIABLES *******************
    DEFINE vcodret		CHAR(5);
    DEFINE vsqlerr		INTEGER;
    DEFINE contador		INTEGER;
    DEFINE vt_cuantos  		INTEGER;
    DEFINE vhoraw       		CHAR(15);
    DEFINE vhora        		DATETIME HOUR TO FRACTION;
    DEFINE vfolio_suc   		CHAR(16);
    DEFINE vfecha_hoy		DATE;

    DEFINE vcuenta		CHAR(20);
    DEFINE venvio_direcc		CHAR(1);
    DEFINE vacum_sdo_int		MONEY(14,2);
    DEFINE vdias_acum_int	INTEGER;
    DEFINE vint_acum		MONEY(14,2);
    DEFINE visr_acum		MONEY(14,2);
    DEFINE vnum_cte		CHAR(20);
    DEFINE vstatus		CHAR(1);
    DEFINE vmotivo		CHAR (2);
    DEFINE vcuenta_clabe		CHAR(18);
    DEFINE vdirecc_envio		INTEGER;
    DEFINE vsdo_actual		MONEY(14,2);
    DEFINE vlim_sbg_ccc		MONEY(14,2);
    DEFINE vimp_sbg_ccc		MONEY(14,2);
    DEFINE vimp_chq_sbg		MONEY(14,2);
    DEFINE vsaldo_sbc		MONEY(14,2);
    DEFINE vsdo_mes_ant		MONEY(14,2);
    DEFINE vret_mes_ant		MONEY(14,2);
    DEFINE vcong_mes_ant		MONEY(14,2);
    DEFINE vsucursal		CHAR(4);
    DEFINE vproducto		CHAR(4);
    DEFINE vtotdepositos		MONEY(16,2);
    DEFINE vtotretiros		MONEY(16,2);
    DEFINE vtotintpag		MONEY(16,2);
    DEFINE vtotcomcobrada	MONEY(16,2);
    DEFINE vtotivacobrado	MONEY(16,2);
    DEFINE vtotisrcobrado	MONEY(16,2);
    DEFINE vacum_sdo_pos		MONEY(14,2);
    DEFINE vdia_sdo_pos		INTEGER;
    DEFINE vmonto_tot		MONEY(14,2);
    DEFINE vtarjeta		CHAR(16);	
    DEFINE vtasa			DECIMAL(9,6);
    DEFINE vsdo_promedio 	MONEY(14,2);
    DEFINE vaniomes          CHAR(6);   

    -- *************** INICIALIZACION DE VARIABLES ******************
    LET vcodret = "000";
    LET contador = -1;
    LET vt_cuantos = 0;
    LET vsdo_promedio = 0;   

    LET vhora = current hour to fraction;
    LET vhoraw = vhora;
    LET vhoraw = vhoraw[1,2]||vhoraw[4,5]||vhoraw[7,8]||vhoraw[10,11];
    LET vfolio_suc = "informix"||vhoraw[1,8];  

    --- SET DEBUG FILE TO "arrpagoint.out";
    --- TRACE ON;

    BEGIN
    
    ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            RETURN vcodret;
        END IF;
    END EXCEPTION;

    SELECT fecha_hoy 
      INTO vfecha_hoy
      FROM sc_fechas
     WHERE empresa = pempresa;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- ********************** FOREACH PRINCIPAL *************************
    FOREACH WITH HOLD
        SELECT noc.cuenta, noc.envio_direcc, noc.acum_sdo_int,
               noc.dias_acum_int, noc.int_acum, noc.isr_acum,
               chq.num_cte, chq.status_cta, chq.motivo, chq.cuenta_clabe,
               chq.direcc_envio, chq.sdo_actual, chq.lim_sbg_ccc,
               chq.imp_sbg_ccc, chq.imp_chq_sbg, chq.saldo_sbc,
               cont.sucursal, cont.producto, cont.totdepositos,
               cont.totretiros, cont.totintpag, cont.totcomcobrada, 
               cont.totivacobrado, cont.totisrcobrado, cont.acum_sdo_pos,
               cont.dia_sdo_pos, cont.aniomes
          INTO vcuenta, venvio_direcc, vacum_sdo_int,
               vdias_acum_int, vint_acum, visr_acum,
               vnum_cte, vstatus, vmotivo, vcuenta_clabe,
               vdirecc_envio, vsdo_actual, vlim_sbg_ccc,
               vimp_sbg_ccc, vimp_chq_sbg, vsaldo_sbc,
               vsucursal, vproducto, vtotdepositos,
               vtotretiros, vtotintpag, vtotcomcobrada,
               vtotivacobrado, vtotisrcobrado, vacum_sdo_pos,
               vdia_sdo_pos, vaniomes
          FROM sc_maenoc noc,
               sc_maechq chq,
               sc_maehis cont
         WHERE noc.empresa = pempresa
           AND noc.cuenta = chq.cuenta
           AND DAY(noc.fecha_alta) = '19'
           AND chq.empresa = noc.empresa
           AND chq.cuenta = noc.cuenta
           AND cont.empresa = noc.empresa
           AND cont.cuenta = noc.cuenta
           AND cont.aniomes > '000000'
           AND cont.fechaini = "07/19/2010"
           AND cont.fechafin = "08/18/2010"
           AND cont.acum_sdo_pos / cont.dia_sdo_pos > 200.00
           AND cont.tasabruta = 0

        IF (contador = -1) THEN
            BEGIN WORK;
            LET contador = 0;
        END IF;

        LET vsdo_promedio = vacum_sdo_pos / vdia_sdo_pos;
        LET vmonto_tot = 0;
        LET vtasa = 0;

        IF vsdo_promedio > 200.00 AND vsdo_promedio <= 5000.00 THEN
            LET vtasa = 1.00 / 100;
        END IF;

        IF vsdo_promedio > 5000.00 AND vsdo_promedio <= 20000.00 THEN
            LET vtasa = 1.00 / 100;
        END IF;

        IF vsdo_promedio > 20000.00 AND vsdo_promedio <= 100000.00 THEN
            LET vtasa = 1.50 / 100;
        END IF;

        IF vsdo_promedio > 100000.00 AND vsdo_promedio <= 500000.00 THEN
            LET vtasa = 3.00 /100;
        END IF;

        IF vsdo_promedio > 500000.00 THEN
            LET vtasa = 4.00 / 100;
        END IF;

        LET vmonto_tot = (((vsdo_promedio * vtasa) / 360) * vdia_sdo_pos);

        IF vmonto_tot > 0.00 THEN
            INSERT INTO sc_movdia VALUES( 0, vfolio_suc, vsucursal, "informix",
            vfecha_hoy, vfecha_hoy, vhora, "3381", vsucursal, vproducto,
            pempresa, vcuenta, "", 0, vmonto_tot, vmonto_tot, 0, 0, 0,
            "", vstatus, vsdo_actual, "0000", "", vtasa, "", "");

            INSERT INTO sc_movdia VALUES( 0, vfolio_suc, vsucursal, "informix",
            vfecha_hoy, vfecha_hoy, vhora, "3276", vsucursal, vproducto,
            pempresa, vcuenta, "", 0, vmonto_tot, vmonto_tot, 0, 0, 0,
            "", vstatus, vsdo_actual, "0000", "", vtasa, "", "");

            UPDATE sc_maehis 
               SET tasabruta = vtasa
             WHERE empresa = pempresa
               AND cuenta = vcuenta
               AND aniomes = vaniomes;

            UPDATE sc_maechq 
               SET sdo_actual = sdo_actual + vmonto_tot
             WHERE empresa = pempresa
               AND cuenta = vcuenta;
        END IF;

        LET contador = contador + 1;
        LET vt_cuantos = vt_cuantos + contador;
        
        COMMIT WORK;
        BEGIN WORK;

        { *****************************************
        IF (contador >= 1) THEN
            LET vt_cuantos = vt_cuantos + contador;
            LET contador = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        ****************************************** }

    END FOREACH;
    -- ********************** FOREACH PRINCIPAL *************************

    LET vt_cuantos = vt_cuantos + contador;

    IF (contador >= 0) THEN
        COMMIT WORK;
    END IF;

    END;

    RETURN vcodret;

END PROCEDURE;