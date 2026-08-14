CREATE PROCEDURE "informix".clasica_sdoscuadra(enum_credito CHAR(20),
			      eult_mov   DATETIME YEAR TO MONTH,
			      econ_ajuste CHAR(1))
RETURNING CHAR(5);


-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret     CHAR(5);
DEFINE vsqlerr      INTEGER;
DEFINE v_diascap    SMALLINT;
DEFINE v_sdopag     MONEY(14,2);
DEFINE v_fechac     DATE;
DEFINE v_cuota      MONEY(14,2);
DEFINE vstatus      CHAR(2);
DEFINE vstatusint   CHAR(2);
DEFINE v_fvigente   DATE;
DEFINE vsaldo       MONEY(14,2);
DEFINE v_tpcuota    SMALLINT;
DEFINE v_codbase    CHAR(8);
DEFINE v_montootorg MONEY(14,2);
DEFINE v_tasainteres DECIMAL(9,6);
DEFINE vtasamora     DECIMAL(9,6);
DEFINE vcuotafija    DECIMAL(14,2);
DEFINE vdiasg        SMALLINT;
DEFINE v_fult_mov    DATETIME YEAR TO MONTH;
DEFINE v_fapert      CHAR(10);
DEFINE v_cten        INTEGER;
DEFINE v_tpc         CHAR(3);
DEFINE v_nropagos    SMALLINT;
DEFINE v_fechamax    DATE;

DEFINE v_pasom      MONEY(14,2);
DEFINE v_pasoc      CHAR(20);
define v_mensaje    CHAR(80);
DEFINE v_producto   CHAR(4);
DEFINE v_plazo      SMALLINT;
DEFINE v_montooto   MONEY(14,2);
DEFINE v_tasa       DECIMAL(9,6);
DEFINE efecha_mig   DATE;
DEFINE v_porc       MONEY(14,2);
DEFINE v_sdoinso_calc MONEY(14,2);
DEFINE v_tprod      CHAR(2);
DEFINE ax_fechaap   DATE;
DEFINE v_pagos1     MONEY(14,2);
DEFINE v_pagos2     MONEY(14,2);
DEFINE v_cliente    CHAR(9);
DEFINE v_abonocap   SMALLINT;
DEFINE v_fechapaso  DATE;
-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret     = "00000";
LET vsqlerr      = 0;
LET v_porc       = 0;

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      ROLLBACK WORK;
      RETURN scod_ret;
   END IF;
END EXCEPTION;


-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
	BEGIN WORK;

	  SELECT fecha_hoy INTO efecha_mig FROM sd_fechas;

          SELECT num_producto, plazo, monto_otorgado, tasa_interes,
                 (SELECT a.monto_cuota + b.monto_cuota
                    FROM sd_pagocapit a, sd_paginter b
                   WHERE a.num_credito = b.num_credito
                     AND a.fecha_cuota = b.fecha_cuota
                     AND a.num_credito = enum_credito
                     AND a.fecha_cuota =
                        (SELECT MIN(fecha_cuota) FROM sD_pagocapit r
                          WHERE r.num_credito = enum_credito))
            INTO v_producto, v_plazo, v_montooto, v_tasa, v_cuota
            FROM sd_maecred f, sd_maesdos g
           WHERE f.num_credito = g.num_credito
             AND f.num_credito = enum_credito;

         SELECT NVL(count(*), 0)
           INTO v_abonocap
           FROM sd_pagocapit
          WHERE sd_pagocapit.num_credito = enum_credito
            AND monto_cuota = 0;

         IF v_abonocap = 0 THEN
            LET v_abonocap = 0;
            SELECT  NVL(COUNT(*), 0)
              INTO  v_abonocap
              FROM  sd_movdia
              WHERE num_credito = enum_credito
              AND   transacc_suc = "0601";

            IF v_abonocap = 0 THEN
	       --LET v_cuota = 0;
               EXECUTE PROCEDURE renivela_ax("001"
                                       ,v_producto
                                       ,v_plazo
                                       ,v_montooto
                                       ,v_tasa
                                       ,enum_credito
                                       ,v_cuota)
                  INTO scod_ret, v_pasom, v_pasom, v_pasom,
                       v_pasoc, v_pasoc, v_pasom;

               IF scod_ret <> "00000" THEN
	          ROLLBACK WORK;
		  RETURN scod_ret;
	       END IF;
            END IF;
         END IF;

	SELECT SUBSTR(a.num_producto,2),
               dias_trasp_cap, a.cod_tasa_base, tasa_interes,
               tasa_moratorios/100,
	       campo_trab1 , NVL(gracia_calc_mora,0), fecha_apertura,
	       numcte
	  INTO v_tpc,
               v_diascap, v_codbase, v_tasainteres , vtasamora, vcuotafija,
	       vdiasg, v_fapert, v_cliente
	  FROM sd_maecred a, bdicred:sd_definicion b
	 WHERE b.num_producto = a.num_producto
	   AND b.empresa = a.empresa
	   AND a.num_credito = enum_credito
	   AND a.empresa ='001';

	SELECT (monto_otorgado - sdo_cap_insoluto), monto_otorgado
	  INTO v_sdopag , v_montootorg
	  FROM sd_maesdos
	 WHERE num_credito = enum_credito
	   AND empresa ='001';


       -- Recalcula Capital Insoluto para comparar
       LET ax_fechaap = v_fapert;
       SELECT NVL(SUM(monto),0) INTO v_pagos1
	 FROM sd_movdia a
        WHERE a.num_credito = enum_credito
          AND codigo_fun IN ("033","333")
          AND codigo_ref IN (7,8,10)
          AND reversado ="N";

       SELECT NVL(SUM(monto),0) INTO v_pagos2
	 FROM sd_movdia b
        WHERE b.num_credito = enum_credito
          AND codigo_fun ="046"
          AND codigo_ref IN (1,3);

	IF ax_fechaap < "11/01/2004" THEN
		IF v_producto = "411" THEN
			LET v_tprod ="09";
		ELSE
			LET v_tprod = SUBSTR(TRIM(v_producto),2,2);
		END IF

		SELECT NVL(saldo,0) INTO v_sdoinso_calc
		  FROM saldos_ini
		 WHERE cliente like "%" || substr(v_cliente,2) || "%"
		   AND segmento = "4"
		   AND tipo =  v_tprod
		   AND fecha = ax_fechaap;
	ELSE
		SELECT NVL(monto_otorgado,0) INTO v_sdoinso_calc
		  FROM sd_maesdos
		 WHERE num_credito = enum_credito;
	END IF

	LET v_sdoinso_calc = v_sdoinso_calc - (v_pagos1 + v_pagos2);
	LET v_sdopag = v_montootorg - v_sdoinso_calc;


	-- Recalcula nva fecha de ultimo movimiento
	SELECT COUNT(*) INTO v_nropagos FROM sd_movdia
	 WHERE num_credito = enum_credito
	   AND transacc_suc = "0601";


	IF v_nropagos = 0 THEN
		SELECT NVL(MAX(fecha_pago),'01/01/1800')
	          INTO v_fechapaso
		  FROM sd_pagocapit
		 WHERE num_credito = enum_credito;

		IF v_fechapaso <> "01/01/1800" THEN
			SELECT MAX(fecha_cuota) INTO eult_mov
			  FROM sd_pagocapit
			 WHERE num_credito = enum_credito
			   AND fecha_pago = v_fechapaso;
		ELSE

			LET eult_mov = efecha_mig;
		END IF

		--LET eult_mov = eult_mov + v_nropagos UNITS MONTH;
	ELSE
		LET scod_ret = "0507";
		ROLLBACK WORK;
		RETURN scod_ret;

	END IF


	-- Clasifica Saldos
	SELECT MIN(fecha_cuota) INTO v_fvigente
	  FROM sd_pagocapit
	 WHERE num_credito = enum_credito
	   AND fecha_cuota >= efecha_mig
           AND empresa = '001';

	-- Inicializa a 1 para iniciar la distribucion
	UPDATE sd_pagocapit set status_cuota ="1", monto_real_pag =0
	 WHERE num_credito = enum_credito;

	UPDATE sd_paginter SET status_cuota ="1", monto_real_pag =0
	 WHERE num_credito = enum_credito;

	-- Limpia Moaratorios
	DELETE FROM sd_detmora
	 WHERE num_credito = enum_credito;

	-- Pone en Cero las columnas importante de maesdos
	update sd_maesdos set sdo_no_exig =0, sdo_exig_int=0,
                      sdo_moratorio=0, sdo_capital=0,
                      sdo_cap_insoluto=0, monto_vencido=0,
                      mto_venc_trasp=0, mto_venc_int=0,
                      mto_venc_tra_int=0,
		      monto_financiado = 0,
         	      monto_reservado  = 0,
		      mto_ministra_cap   = monto_otorgado,
         	      abonos_mes_cap = 0,
         	      provision_normal = 0,
         	      sdo_global_int   = 0,
         	      sdo_intereses    = 0,
         	      int_tra_no_exig  = 0,
         	      sdo_trab4        =0
	where num_credito = enum_credito;


	IF v_fvigente IS NULL THEN
		SELECT MAX(fecha_cuota) INTO v_fvigente
	  	  FROM sd_pagocapit
	 	 WHERE num_credito = enum_credito
           	   AND empresa = '001';
	END IF

	-- Determina lo pagado
	FOREACH SELECT fecha_cuota, saldo_cuota
		  INTO v_fechac,    v_cuota
		  FROM sd_pagocapit
		 WHERE num_credito = enum_credito
		   AND empresa = '001'
		   AND EXTEND(fecha_cuota,YEAR TO MONTH) <= eult_mov
		 ORDER BY fecha_cuota

		IF v_sdopag = 0 THEN
			EXIT FOREACH;
		END IF

		IF v_cuota <= v_sdopag THEN
			LET v_sdopag = v_sdopag - v_cuota;
			LET vstatus = "5";
			LET vstatusint = "5";
		ELSE
			LET v_cuota  = v_sdopag;
			LET v_sdopag = 0;
			LET vstatus = "1";
			LET vstatusint = "5";
		END IF

                   UPDATE sd_pagocapit SET monto_real_pag = v_cuota,
                                           status_cuota = vstatus
                    WHERE num_credito = enum_credito
                      AND fecha_cuota = v_fechac
                      AND empresa = '001';

                   UPDATE sd_paginter SET monto_real_pag = monto_cuota,
                                          monto_financiado = v_cuota,
                                          status_cuota   = vstatusint
                    WHERE num_credito = enum_credito
                      AND fecha_cuota = v_fechac
                      AND empresa = '001';


		IF v_sdopag < 1 THEN
			EXIT FOREACH;
		END IF
	END FOREACH

	-- Verifica por si hay pagos Adelantados o sobrantes
	IF v_sdopag > 0 THEN
		FOREACH SELECT fecha_cuota, saldo_cuota
		          INTO v_fechac,    v_cuota
		          FROM sd_pagocapit
		         WHERE num_credito = enum_credito
		           AND empresa = '001'
		         ORDER BY fecha_cuota DESC

			IF v_cuota <= v_sdopag THEN
				LET v_sdopag = v_sdopag - v_cuota;
				LET vstatus = "5";
			ELSE
				LET v_cuota = v_sdopag;
				LET v_sdopag = 0;
				LET vstatus = "1";
			END IF

			UPDATE sd_pagocapit SET monto_real_pag = v_cuota,
					 status_cuota = vstatus
		 	 WHERE num_credito = enum_credito
		   	   AND fecha_cuota = v_fechac
                   	   AND empresa = '001';

			IF vstatus = 5 THEN
				UPDATE sd_paginter
			   	   SET monto_cuota = 0,
				       monto_real_pag = 0,
			       	       monto_financiado = 0,
			       	       status_cuota   = "5"
		 	 	 WHERE num_credito = enum_credito
		           	   AND fecha_cuota = v_fechac
		           	   AND empresa = '001';
			END IF

			IF v_sdopag = 0 THEN
				EXIT FOREACH;
			END IF

		END FOREACH

	END IF

	-- Clasifica Saldos
	SELECT MIN(fecha_cuota) INTO v_fvigente
	  FROM sd_pagocapit
	 WHERE num_credito = enum_credito
	   AND fecha_cuota >= efecha_mig
           AND empresa = '001';

	UPDATE sd_pagocapit SET status_cuota = "7"
	 WHERE num_credito = enum_credito
	   AND fecha_cuota <=  efecha_mig
	   AND status_cuota <> "5";

	UPDATE sd_pagocapit SET status_cuota = "2"
	 WHERE num_credito = enum_credito
	   AND efecha_mig - fecha_cuota  >= v_diascap
	   AND status_cuota <> "5";

	SELECT COUNT(*) INTO v_tpcuota
	  FROM sd_pagocapit
	 WHERE num_credito = enum_credito
	   AND status_cuota = "2";
	IF v_tpcuota > 0 THEN
		UPDATE sd_pagocapit
		   SET status_cuota ="2"
		 WHERE num_credito = enum_credito
		   AND status_cuota ="7";
	END IF

	FOREACH SELECT fecha_cuota, status_cuota INTO v_fechac, vstatus
		  FROM sd_pagocapit
		 WHERE num_credito = enum_credito
		   AND empresa = '001'

		UPDATE sd_paginter SET status_cuota = vstatus
		 WHERE num_credito= enum_credito
		   AND fecha_cuota = v_fechac
		   AND empresa = '001'
		   AND status_cuota <> "5";

	END FOREACH

	UPDATE sd_maesdos SET sdo_capital = 0, sdo_cap_insoluto = 0,
			       monto_vencido = 0, mto_venc_trasp = 0,
			       sdo_no_exig = 0, sdo_exig_int = 0,
			       mto_venc_int = 0, mto_venc_tra_int = 0,
			       sdo_moratorio =0
	 WHERE num_credito = enum_credito
	   AND empresa = '001';

	-- Actualiza MAESDOS
	FOREACH SELECT status_cuota, sum(saldo_cuota - monto_real_pag)
		  INTO vstatus, vsaldo
	  	  FROM sd_pagocapit
	 	 WHERE num_credito = enum_credito
		   AND empresa = '001'
		   AND status_cuota <> "5"
	 	 GROUP BY 1

		IF vstatus = "1" THEN
			UPDATE sd_maesdos SET sdo_capital = vsaldo,
					       sdo_cap_insoluto =
					       sdo_cap_insoluto + vsaldo
		 	 WHERE num_credito = enum_credito
			   AND empresa = '001';
		ELIF vstatus = "7" THEN
			UPDATE sd_maesdos SET monto_vencido = vsaldo,
					       sdo_cap_insoluto =
					       sdo_cap_insoluto + vsaldo
		 	 WHERE num_credito = enum_credito
			   AND empresa = '001';
		ELSE
			UPDATE sd_maesdos SET mto_venc_trasp = vsaldo,
					       sdo_cap_insoluto =
					       sdo_cap_insoluto + vsaldo
		 	 WHERE num_credito = enum_credito
			   AND empresa = '001';
		END IF

	END FOREACH

	FOREACH SELECT status_cuota, sum(monto_cuota - monto_real_pag)
		  INTO vstatus, vsaldo
	  	  FROM sd_paginter
	 	 WHERE num_credito = enum_credito
		   AND empresa = '001'
		   AND status_cuota <> "5"
	 	 GROUP BY 1

		IF vstatus = "1" THEN
			UPDATE sd_maesdos SET sdo_no_exig = vsaldo
		 	 WHERE num_credito = enum_credito
			   AND empresa = '001';
		ELIF vstatus = "7" THEN
			UPDATE sd_maesdos SET mto_venc_int = vsaldo,
					       sdo_exig_int   =
					       sdo_exig_int + vsaldo
		 	 WHERE num_credito = enum_credito
			   AND empresa = '001';
		ELSE
			UPDATE sd_maesdos SET mto_venc_tra_int = vsaldo,
					       sdo_exig_int   =
					       sdo_exig_int + vsaldo
		 	 WHERE num_credito = enum_credito
			   AND empresa = '001';
		END IF
	END FOREACH

	-- Genera Moratorio
	LET vsaldo = vcuotafija * vtasamora;
	FOREACH SELECT fecha_cuota INTO v_fechac
		  FROM sd_paginter
		 WHERE num_credito = enum_credito
		   AND empresa = '001'
		   AND status_cuota IN ("2", "7")
		   AND monto_real_pag = 0

		IF v_fechac + vdiasg UNITS DAY <= efecha_mig THEN
			INSERT INTO sd_detmora
		 	 VALUES("001", enum_credito, v_fechac, "P", 0, 0, 0,
				0, 0, vsaldo, 0);

			UPDATE sd_pagocapit SET monto_moratorio = vsaldo,
			      		 	 status_moratorio = "2"
	  	 	 WHERE num_credito = enum_credito
		   	   AND empresa = '001'
		   	   AND fecha_cuota = v_fechac;
		END IF

	END FOREACH
	SELECT SUM(sdo_mora_ordi) INTO vsaldo
	  FROM sd_detmora
	 WHERE num_credito = enum_credito
	   AND empresa = '001';

	IF vsaldo IS NULL THEN
		LET vsaldo = 0;
	END IF

	UPDATE sd_maesdos SET sdo_moratorio = vsaldo
	 WHERE num_credito = enum_credito
	   AND empresa = '001';

	-- Actualiza Maecred
	SELECT COUNT(*) INTO v_tpcuota
	  FROM sd_pagocapit
	 WHERE num_credito = enum_credito
	   AND empresa = '001'
	   AND status_cuota IN ("2","7");

	IF v_tpcuota = 0 THEN
		SELECT COUNT(*) INTO v_cten
	 	  FROM bdicred:sd_movdia
		 WHERE num_credito = enum_credito
		   AND codigo_fun ="046"
		   AND reversado ="N";

		IF v_cten > 0 THEN
			UPDATE sd_maecred SET status_cred = "FC"
	 	 	 WHERE num_credito = enum_credito
		   	   AND empresa = '001';
		ELSE
			SELECT COUNT(*) INTO v_cten
			  FROM sd_movdia
			 WHERE num_credito = enum_credito		
			   AND transacc_suc = "0604";

			SELECT sdo_cap_insoluto INTO vsaldo
			  FROM bdicred:sd_maesdos
			 WHERE num_credito = enum_credito;
			IF vsaldo <= 0 OR v_cten > 0 THEN
				UPDATE sd_maecred SET status_cred = "FF"
	 	 	 	 WHERE num_credito = enum_credito
		   	   	   AND empresa = '001';
			ELSE
				UPDATE sd_maecred SET status_cred = "AA"
	 	 		 WHERE num_credito = enum_credito
		   		   AND empresa = '001';
			END IF
		END IF
	ELSE
		SELECT COUNT(*) INTO v_tpcuota
	  	  FROM sd_pagocapit
	 	 WHERE num_credito = enum_credito
	 	   AND empresa = '001'
	   	   AND status_cuota IN ("2");
		IF v_tpcuota = 0 THEN
			UPDATE sd_maecred SET status_cred = "BA"
	 	 	 WHERE num_credito = enum_credito
			   AND empresa = '001';
		ELSE
			UPDATE sd_maecred SET status_cred = "BT"
	 	 	 WHERE num_credito = enum_credito
			   AND empresa = '001';
		END IF
	END IF
{
	-- Verifica por si hay que ajustar
	SELECT sdo_cap_insoluto - (SELECT SUM(monto_cuota - monto_real_pag)
				     FROM sd_pagocapit b
				WHERE b.num_credito = a.num_credito )
	  INTO vsaldo
	  FROM sd_maesdos a
	 WHERE a.num_credito = enum_credito
	   AND a.empresa = '001';
	IF vsaldo <> 0 THEN
		SELECT MAX(fecha_cuota) INTO v_fechac
		  FROM dm_pagocapit
		 WHERE num_credito = enum_credito
		   AND empresa = '001'
		   AND status_cuota <> "5";
	END IF
	IF vsaldo > 0 then

		UPDATE sdm_pagocapit
	   	   SET monto_cuota = monto_cuota - vsaldo,
	               saldo_cuota = saldo_cuota - vsaldo
	         WHERE num_credito = enum_credito
		   AND fecha_cuota = v_fechac
		   AND empresa     = '001';

		UPDATE sdm_maesdos
		   SET sdo_capital = sdo_capital - vsaldo,
		       sdo_cap_insoluto = sdo_cap_insoluto - vsaldo
		 WHERE num_credito = enum_credito
		   AND empresa = '001';
	END IF
}
   COMMIT WORK;

END
	RETURN scod_ret;
END PROCEDURE;