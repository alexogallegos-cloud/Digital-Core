CREATE PROCEDURE "informix".sp_altainversion_web(
-- APERTINV
    pempresa 	  	CHAR(3),
    pnum_cte        CHAR(20),
    ppromotor       CHAR(8),
    psucursal       CHAR(4),
    ptipo_banca     CHAR(3),
    preg_firmas     CHAR(1),
    penvio          CHAR(1),
    pdirecc_envio   SMALLINT,
    pcobraisr       CHAR(1),
-- Instrumento
    pinstrumento    CHAR(4),
    popcion_ret     CHAR(2),
    pespecial       CHAR(1),
    pnum_autorizac  CHAR(13),
    pdias           SMALLINT,
    pfecha_venc     DATE,
    pcapital        MONEY(14,2),
    pper_acred      CHAR(1),
    ptasa_instrum   CHAR(8),
    pdeposito       CHAR(1),
    pcta_cheques    CHAR(20),
    pcuenta         CHAR(20),
    pptos_adicional DECIMAL(6,4),
-- Instrucciones Capital
    pinst_vento1    CHAR(2),
    pnro_cuenta1    CHAR(20),
-- Instrucciones Intereses
    pinst_vento2    CHAR(2),
    pnro_cuenta2    CHAR(20),
-- Beneficiarios 1
    pnombre1        CHAR(20),
    pparentesco1    CHAR(2),
    pporcentaje1    DECIMAL(9,6),
-- Beneficiarios 2
    pnombre2        CHAR(20),
    pparentesco2    CHAR(2),
    pporcentaje2    DECIMAL(9,6),
-- Beneficiarios 3
    pnombre3        CHAR(20),
    pparentesco3    CHAR(2),
    pporcentaje3    DECIMAL(9,6),
-- Beneficiarios 4
    pnombre4        CHAR(20),
    pparentesco4    CHAR(2),
    pporcentaje4    DECIMAL(9,6),
-- Cotitular 1
    pnombrecot1     CHAR(20),
    pparentesco5    CHAR(2),
-- Cotitular 2
    pnombrecot2     CHAR(20),
    pparentesco6    CHAR(2),
-- Movimiento
    pfolio_suc      CHAR(16),
    pdivisa         CHAR(2),
    ptranCgo        CHAR(4))


    RETURNING CHAR(5),CHAR(20),SMALLINT,SMALLINT,DATE,MONEY(10,2),
    MONEY(14,2),DECIMAL(9,6),DECIMAL(9,6),DECIMAL (9,6);
    


    DEFINE v_codret CHAR(5);
    DEFINE v_secuencia,v_dias SMALLINT;
    DEFINE v_inversion CHAR(20);
    DEFINE v_isr MONEY(10,2);
    DEFINE v_rendimiento MONEY(14,2);
    DEFINE v_fecha_venc DATE;
    DEFINE v_fecha_hoy DATE;
    DEFINE v_bruta,v_tasa_isr,v_neta DECIMAL(9,6); 
    DEFINE vpaso CHAR(10);
    DEFINE vsqlerr INTEGER;
    define vtransaccion INTEGER;

    LET vtransaccion = 0;
    LET v_neta = 0;
    LET v_tasa_isr = 0;
    LET v_bruta = 0;
    LET v_rendimiento = 0;
    LET v_isr = 0;
    LET v_fecha_venc = "";
    LET v_dias = 0;
    LET v_secuencia = 0;
    LET v_inversion = "";

BEGIN
    
    ON EXCEPTION SET vsqlerr
		IF vsqlerr <> 0  then
			let v_codret = vsqlerr;
			IF vtransaccion = 1 THEN
				ROLLBACK WORK;
				BEGIN WORK;
			ELSE
				ROLLBACK WORK;
			END IF
			
			RETURN  v_codret,v_inversion,v_secuencia,v_dias,v_fecha_venc,v_isr,
					v_rendimiento,v_bruta,v_tasa_isr,v_neta;
		END IF;
    END EXCEPTION;



    ON EXCEPTION IN (-535)
        LET vtransaccion = 1;
    END EXCEPTION WITH resume;


	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;


-- set debug file to "/tmp/sp_altainversion.out";
-- trace on;
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;

    -- lanzar cargo
    
    CALL bdicheq:cargo_ref(pempresa, psucursal, ppromotor, ptranCgo,
               "0000", pfolio_suc, pcta_cheques, 0,
               pcapital, pdivisa, "", "", "")
    RETURNING v_codret, vpaso, vpaso, vpaso, vpaso;
    
    IF v_codret <> "000" THEN
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
		LET v_codret = "00550";				 
        RETURN  v_codret,v_inversion,v_secuencia,v_dias,v_fecha_venc,
                v_isr,v_rendimiento,v_bruta,v_tasa_isr,v_neta;
    END IF;    
    
    -- lanzar apertura
    
    CALL apertinv(
    pempresa,
    pnum_cte,
    ppromotor,
    psucursal,
    ptipo_banca,
    preg_firmas,
    penvio,
    pdirecc_envio,
    pcobraisr,
    pinstrumento,
    popcion_ret,
    pespecial,
    pnum_autorizac,
    pdias,pfecha_venc,
    pcapital,
    pper_acred,
    ptasa_instrum,
    pdeposito,
    pcta_cheques,
    pcuenta,
    pptos_adicional,
    pinst_vento1,
    pnro_cuenta1,
    pinst_vento2,
    pnro_cuenta2,
    pnombre1,
    pparentesco1,
    pporcentaje1,
    pnombre2,
    pparentesco2,
    pporcentaje2,
    pnombre3,
    pparentesco3,
    pporcentaje3,
    pnombre4,
    pparentesco4,
    pporcentaje4,
    pnombrecot1,
    pparentesco5,
    pnombrecot2,
    pparentesco6,
    pfolio_suc,
    pdivisa)
    RETURNING   v_codret,v_inversion,v_secuencia,v_dias,v_fecha_venc,
                v_isr,v_rendimiento,v_bruta,v_tasa_isr,v_neta;
    
    IF v_codret <> "000" THEN
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
		LET v_codret = "00550";				 
        RETURN  v_codret,v_inversion,v_secuencia,v_dias,v_fecha_venc,
                v_isr,v_rendimiento,v_bruta,v_tasa_isr,v_neta;
    END IF;
    
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK;
    END IF;
   
	LET v_codret = "00000";					
    RETURN  v_codret,v_inversion,v_secuencia,v_dias,v_fecha_venc,
            v_isr,v_rendimiento,v_bruta,v_tasa_isr,v_neta;
   
END
END PROCEDURE;