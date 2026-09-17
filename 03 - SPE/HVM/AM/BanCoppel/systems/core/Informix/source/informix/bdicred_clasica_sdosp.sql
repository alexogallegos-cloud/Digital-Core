CREATE PROCEDURE "informix".clasica_sdosp(enum_credito CHAR(20),
			      efecha_mig   DATE)
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
DEFINE v_fult_mov    DATE;
DEFINE v_fapert      CHAR(10);
DEFINE v_cten        INTEGER;
-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret     = "00000";
LET vsqlerr      = 0;

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
 --     ROLLBACK WORK;
      RETURN scod_ret;
   END IF;
END EXCEPTION;


-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
--	BEGIN WORK;

	SELECT dias_trasp_cap, a.cod_tasa_base, tasa_interes, 
               tasa_moratorios/100,
	       campo_trab1 , NVL(gracia_calc_mora,0), fecha_apertura
	  INTO v_diascap, v_codbase, v_tasainteres , vtasamora, vcuotafija,
	       vdiasg, v_fapert
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


	LET v_cten = SUBSTR(enum_credito,2,8);
	-- Lee fecha de Ultimo Mov
	SELECT SUBSTR(alta,5,2) || "/" || SUBSTR(alta,7,2) || "/" ||
	       SUBSTR(alta,1,4)
	  INTO v_fult_mov
	  FROM axcredrepro:loan
	 WHERE fecha = SUBSTR(v_fapert,7) || SUBSTR(v_fapert,1,2) || 
  		       SUBSTR(v_fapert,4,2)
	   AND cliente = v_cten;

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
		   AND fecha_cuota <= v_fult_mov
		 ORDER BY fecha_cuota

		IF v_sdopag = 0 THEN
			EXIT FOREACH;
		END IF

		IF v_cuota <= v_sdopag THEN
			LET v_sdopag = v_sdopag - v_cuota;
			LET vstatus = "5";
			LET vstatusint = "5";
		ELSE
			--LET v_cuota = v_sdopag;
			--LET v_sdopag = 0;
			--LET vstatus = "1";
			--LET vstatusint = "5";
			EXIT FOREACH;
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
		UPDATE sd_maecred SET status_cred = "AA"
	 	 WHERE num_credito = enum_credito
		   AND empresa = '001';
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
--	COMMIT WORK;

END
	RETURN scod_ret;
END PROCEDURE;