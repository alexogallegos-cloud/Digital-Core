CREATE PROCEDURE "informix".sp_altactascrece( /* parametros necesarios para cargo_ref */
                                                    pempresa            char(3),
                                                    psucursal           char(4),
                                                    pusuario            char(8),
                                                    ptransacc_cargo     char(4),
                                                    ptransuc_cargo      char(4),
                                                    pfolsuc             char(16),
                                                    pcuenta             char(20),
                                                    pcheque             integer,
                                                    pmonto              money(14,2),
                                                    pdivisa             char(2),
                                                    preferencia_cargo   char(40),
                                                    pnum_tarjeta        char(16),
                                                    pautoriza           char(8),
                                               /* Parametros necesarios para cuenta1 */
                                                    pproducto           CHAR(4),
                                                    pnum_cte            CHAR(20),
                                                    pclase_cta          CHAR(1),
                                                    preg_firmas         CHAR(1),
                                                    ptipo_bca           CHAR(3),
                                                    penvio_direcc       CHAR(1),
                                                    pcuenta1            CHAR(20),
                                                    pdirecc_envio       SMALLINT,
                                                    pinstcap            CHAR(2),
                                                    pcuentacap          CHAR(20),
                                                    pinstint            CHAR(2),
                                                    pcuentaint          CHAR(20),
                                                    pplazo              SMALLINT,
                                                    pcobraISr           CHAR(1),
                                                    pproced_aperturacta CHAR(2),
                                                    pproced_mantenercta CHAR(2),
                                                    pmonto_mensual      CHAR(2),
                                                    pdepositos_cantidad CHAR(2),
                                                    pdepositos_monto 	  CHAR(2),
                                                    pretiros_cantidad	  CHAR(2),
                                                    pretiros_monto      CHAR(2),
                                                    pformaapert         CHAR(2),
                                                    pmtoapertura        MONEY(14,2),
                                               /* Parametros necesarios para abono_ref */
                                                    ptransacc_abono     char(4),
                                                    ptransuc_abono      char(4),
                                                    pfolio_suc          char(16),
                                                    pdocto              integer,
                                                    pmto_tot            money(14,2),
                                                    pmto_firme          money(14,2),
                                                    pmto_sbc            money(14,2),
                                                    pmto_rem            money(14,2),
                                                    pdias_ret           smallint,
                                                    preferencia_abono   char(40) )
RETURNING char(5), char(20), char(18);
     
    /* 
        -- ********************************************************************
        -- sp_altactascrece
        -- Version              1.0.0
        -- Objetivo:            Ejecutar procedures alta de cuentas crecientes
        -- Supuestos:           Ninguno
        -- Creado por:
        -- ModIFicado por:      Alejandro Rueda Sanchez
        -- Ultima ModIFicacion: Septiembre - 2008
        --                      CreaciÃÂ³n de SPL
        -- ********************************************************************* 
    */
     
    /* Definicion de variables */
    DEFINE vcodret      CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(50);
    DEFINE vsqlerr      INTEGER;
    DEFINE visamerr     INTEGER;
    DEFINE vdescerr     CHAR(50);
    DEFINE vdummy       CHAR(100);
    DEFINE vctaclabe    CHAR(18);
    DEFINE vcuenta      CHAR(20);
    DEFINE vtransaccion INTEGER;
    DEFINE vproceso     SMALLINT;
    DEFINE vCodRetCargo CHAR(5);
    DEFINE vCodRetCta1  CHAR(5);
    DEFINE vCodRetAbono CHAR(5);
    DEFINE vCodRetRev   CHAR(5);
    DEFINE vind_dispon  CHAR(1);
     
    /* Inicializacion de variables */
    LET vcodret      = "000";
    LET vcodret2     = '';
    LET vcodret3     = '';
    LET vsqlerr      = 0;
    LET visamerr     = 0;
    LET vdescerr     = '';
    LET vctaclabe    = "";
    LET vcuenta      = "";
    LET vtransaccion = 0;
    LET vproceso     = 0;
    LET vCodRetCargo = '';
    LET vCodRetCta1  = '';
    LET vCodRetAbono = '';
    LET vCodRetRev   = '';
    LET vind_dispon  = '0';
    LET ptransacc_abono = '0419';

    
    BEGIN
    
    ON EXCEPTION SET vsqlerr, visamerr, vdescerr
        SET DEBUG FILE TO "/tmp/sp_altactascrece.err";
        TRACE ON;
        IF vsqlerr <> 0 then
            LET vcodret = vsqlerr;
            LET vcodret2 = visamerr;
            LET vcodret3 = vdescerr;
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF
            RETURN vcodret, "", "";
        END IF
    END EXCEPTION;
    
    ON EXCEPTION IN (-535)
        let vtransaccion = 1;
    END EXCEPTION WITH RESUME;
   
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;

     -- SET DEBUG FILE TO "/RESPALDOS/inver/sp_altactascrece.out";
     -- TRACE ON;
    
    IF vtransaccion = 1 THEN 
        COMMIT WORK;
        BEGIN WORK;
    ELSE     
        BEGIN WORK;
    END IF; 
    
    SELECT ind_disponible
      INTO vind_dispon
      FROM sc_fechas
     WHERE empresa = pempresa;
     
    IF ( vind_dispon = '0' ) THEN
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcodret = '004';
        RETURN vcodret, "", "";
    END IF;
    
    /* Realiza el cargo a la  cuenta de cheques */
    EXECUTE PROCEDURE cargo_ref(pempresa, psucursal, pusuario, ptransacc_cargo, ptransuc_cargo, pfolsuc, 
                                pcuenta, pcheque, pmonto, pdivisa, preferencia_cargo, pnum_tarjeta, pautoriza)
    INTO vCodRetCargo, vdummy, vdummy, vdummy, vdummy;

    IF vCodRetCargo <> "000" THEN        
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        
        EXECUTE PROCEDURE reversion(pempresa, psucursal, pusuario, pfolsuc, 'A')
        INTO vCodRetRev;
        
        LET vcodret = vCodRetCargo;
        RETURN vcodret, "", "";
    ELSE
        LET vproceso = 1;
    END IF
    
    IF vproceso = 1 THEN
        IF psucursal = '5011' THEN
            /* Realiza el alta de la cuenta */
            EXECUTE PROCEDURE cuenta1_app(pempresa, pusuario, psucursal, pproducto,pnum_cte, '00', pclase_cta, preg_firmas, ptipo_bca,
                                    pusuario, penvio_direcc, pcuenta1, pdirecc_envio, "", "", pinstcap, pcuentacap, pinstint,
                                    pcuentaint, pplazo, pcobraISr, pproced_aperturacta, pproced_mantenercta, pmonto_mensual, 
                                    pdepositos_cantidad, pdepositos_monto, pretiros_cantidad, pretiros_monto, pformaapert, pmtoapertura)
            INTO vCodRetCta1, vcuenta, vctaclabe;
        ELSE
            EXECUTE PROCEDURE cuenta1(pempresa, pusuario, psucursal, pproducto,pnum_cte, '00', pclase_cta, preg_firmas, ptipo_bca,
                                    pusuario, penvio_direcc, pcuenta1, pdirecc_envio, "", "", pinstcap, pcuentacap, pinstint,
                                    pcuentaint, pplazo, pcobraISr, pproced_aperturacta, pproced_mantenercta, pmonto_mensual, 
                                    pdepositos_cantidad, pdepositos_monto, pretiros_cantidad, pretiros_monto, pformaapert, pmtoapertura)
            INTO vCodRetCta1, vcuenta, vctaclabe;
        END IF;
        IF vCodRetCta1 <> "000" THEN
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            
            LET vcodret = vCodRetCta1;
            RETURN vcodret, "", "";
        ELSE 
            LET vproceso = 2;
        END IF;
    END IF;

    IF vproceso = 2 THEN
        /* Realiza el abono a la cuenta */
        EXECUTE PROCEDURE abono_ref(pempresa, psucursal, pusuario, ptransacc_abono, ptransuc_abono, pfolio_suc, vcuenta, pdocto, 
                                    pmto_tot, pmto_firme, pmto_sbc, pmto_rem, pdias_ret, pdivisa, preferencia_abono, "", pautoriza )
        INTO vCodRetAbono;
        IF vCodRetAbono <> "000" THEN
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            
            -- // REVERSA ABONO
            EXECUTE PROCEDURE reversion(pempresa, psucursal, pusuario, pfolio_suc, 'A')
            INTO vCodRetRev;
            -- // REVERSA CARGO
            IF vCodRetRev = '000' THEN
                EXECUTE PROCEDURE reversion(pempresa, psucursal, pusuario, pfolsuc, 'A')
                INTO vCodRetRev;
            END IF;
            
            LET vcodret = vCodRetAbono;
            RETURN vcodret, "", "";
        ELSE
            LET vproceso = 3;
        END IF
    END IF;

    /* Todo OK */
    IF vproceso = 3 THEN
        IF vtransaccion = 1 THEN
            COMMIT WORK;
            BEGIN WORK;
        ELSE
            COMMIT WORK;
        END IF;
    ELSE
        IF vtransaccion = 1 then
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
    END IF;

    RETURN vcodret, vcuenta, vctaclabe;
    
    END
    
END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".sp_creacta_inv(pempresa char(3),pnum_cte char(20),pproducto char(4),pcuenta char(20),vlongcta smallint,vdiferencia smallint,vidcta char(1))
RETURNING char(5),char(20);

DEFINE vcodret char(5);
DEFINE vsignumcta integer;
DEFINE sql_err integer;
DEFINE vparamsigcta char(20);
DEFINE icuenta int;
DEFINE i SMALLINT;
DEFINE vdigverif char(1);

	BEGIN
		ON EXCEPTION SET sql_err
			LET vcodret = sql_err; 
			RETURN vcodret,pcuenta;
		END EXCEPTION;
		ON EXCEPTION IN (-235,-239,-268)
			let icuenta = 0;
		END EXCEPTION WITH RESUME;
		
		set isolation to dirty read;	
		SET LOCK MODE TO WAIT 15;  

		-- SET DEBUG FILE TO "/informix/FAOC/Debug/Inv/sp_creacta_inv.out";
		-- TRACE ON;

		LET vsignumcta = 0;
		LET sql_err = 0;
		LET vcodret = '00000';
		LET vparamsigcta = '';
		LET icuenta = 0;
		
		-- ******************************************
		-- Extra consecutivo de acuerdo al producto *
		-- ******************************************
		IF pproducto <= '2000' THEN
			LET vparamsigcta = "signumcta" || TRIM(vidcta);
		ELSE
			LET vparamsigcta = "signumcta" || SUBSTR(pproducto, 1, 2);
		END IF;
		
		WHILE icuenta = 0
		
			SELECT valor
			INTO vsignumcta
			FROM bdicheq:"informix".sc_param
			WHERE empresa = pempresa
			AND codparam = TRIM(vparamsigcta);
			IF vsignumcta IS NULL THEN
				LET vcodret = "933";
				RETURN vcodret,pcuenta;
			END IF;

			LET pcuenta = vsignumcta;

			UPDATE bdicheq:"informix".sc_param
			SET valor = vsignumcta + 1
			WHERE empresa = pempresa
			AND codparam =  TRIM(vparamsigcta);
			
			LET vdiferencia = vlongcta - LENGTH(pcuenta) - 3;

			IF vdiferencia > 0 THEN
				FOR i = 1 TO vdiferencia
					LET pcuenta = "0" || pcuenta;
				END FOR;
			END IF

			IF pproducto <= '2000' THEN
				LET pcuenta = "1" || TRIM(vidcta) || TRIM(pcuenta);
				ELSE
						LET pcuenta = SUBSTR(pproducto, 1, 2) || TRIM(pcuenta);
			END IF;	

			CALL "informix".digver11(pcuenta)
			RETURNING vcodret,vdigverif;
			LET pcuenta = TRIM(pcuenta)||vdigverif;

			IF NOT EXISTS (SELECT 1 FROM bdicheq:"informix".sc_maechq WHERE empresa = pempresa AND cuenta = pcuenta) THEN
				LET icuenta = 1;
				INSERT INTO bdicheq:"informix".sc_maechq(empresa, cuenta, producto, num_cte, status_cta)
				VALUES (pempresa,pcuenta,pproducto,pnum_cte,"1");
			END IF;
		END WHILE;
		RETURN vcodret,pcuenta;
	END;
END PROCEDURE;