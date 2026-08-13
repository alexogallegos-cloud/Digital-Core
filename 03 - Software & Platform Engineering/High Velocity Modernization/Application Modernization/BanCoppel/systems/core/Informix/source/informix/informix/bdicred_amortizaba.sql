CREATE PROCEDURE "informix".amortizaba()
RETURNING CHAR(5);
 
DEFINE sql_err    SMALLINT;
DEFINE isam_err   SMALLINT;
DEFINE error_info CHAR(40);
DEFINE cod_ret    CHAR(5);
DEFINE vCred      CHAR(20);
DEFINE vCapVig    DECIMAL(14,2);
DEFINE vCapIns    DECIMAL(14,2);
DEFINE vTrans     DECIMAL(14,2);
DEFINE vTabla     DECIMAL(14,2);
DEFINE vTrasp     DECIMAL(14,2);
DEFINE vCapTrasNo DECIMAL(14,2);
DEFINE vIntTrasNo DECIMAL(14,2);
DEFINE vBegin     CHAR(1);
DEFINE vPagado    DECIMAL(14,2);
DEFINE vFecha     DATE;
DEFINE vMinimo    DECIMAL(14,2);
DEFINE vTabasco   SMALLINT;
-- **************************************************************************
-- *                      CONTROL DE ERRORES                                *
-- **************************************************************************

   ON EXCEPTION SET sql_err, isam_err, error_info
      LET cod_ret = sql_err;
      IF vBegin = "S" THEN
         ROLLBACK WORK;
      END IF
      RETURN cod_ret;
   END EXCEPTION;

--set debug file to "amortizaba.out";
--trace on;
-- **************************************************************************
-- *                      ASIGNACION DE VARIABLES                           *
-- **************************************************************************

LET cod_ret    = "000";
LET vBegin     = "?";


-- Actualiza Tabla de Amortizacion por cuotas pagadas
UPDATE sd_amortiza_credito
   SET capital_status ="5"
 WHERE capital_debe <= capital_pagado
   AND capital_status <> "5"
   AND fecha_cuota < "02202008";  

-- Repara Moratorios
FOREACH SELECT num_credito, fecha_cuota
	  INTO vCred, vFecha
	  FROM sd_amortiza_credito
	 WHERE mora_provi_ordi < 0
	   

	UPDATE sd_amortiza_credito
	   SET mora_provi_ordi = 0
	 WHERE empresa = "001"
	   AND num_credito = vCred
	   AND fecha_cuota = vFecha;

END FOREACH


FOREACH SELECT num_credito, fecha_cuota
          INTO vCred, vFecha
          FROM sd_amortiza_credito
         WHERE mora_provi_cope < 0


        UPDATE sd_amortiza_credito
           SET mora_provi_cope = 0
         WHERE empresa = "001"
           AND num_credito = vCred
           AND fecha_cuota = vFecha;

END FOREACH

FOREACH SELECT num_credito, fecha_cuota
          INTO vCred, vFecha
          FROM sd_amortiza_credito
         WHERE mora_sdo_ordi < 0

          
        UPDATE sd_amortiza_credito 
           SET mora_sdo_ordi = 0
         WHERE empresa = "001" 
           AND num_credito = vCred
           AND fecha_cuota = vFecha;

END FOREACH

FOREACH SELECT num_credito, fecha_cuota
          INTO vCred, vFecha
          FROM sd_amortiza_credito
         WHERE mora_sdo_cope < 0
          
          
        UPDATE sd_amortiza_credito
           SET mora_sdo_cope = 0 
         WHERE empresa = "001" 
           AND num_credito = vCred
           AND fecha_cuota = vFecha;
           
END FOREACH


UPDATE sd_maesdos set sdo_moratorio = 0
where sdo_moratorio < 0;

UPDATE sd_maesdos set sdo_contab_mora = 0
where sdo_contab_mora < 0;


-- Repara creditos vigentes
FOREACH SELECT a.num_credito, a.fecha_cuota
	  INTO vCred, vFecha
	  FROM sd_amortiza_credito a, sd_maecred b
	 WHERE b.empresa = "001"
	   AND b.status_cred = "AA"
	   AND a.empresa = b.empresa
	   AND a.num_credito = b.num_credito
	   AND a.capital_debe <> a.capital_pagado
	   AND a.capital_status <> "5"
	   AND a.fecha_cuota < "03202008"



	UPDATE sd_amortiza_credito
	   SET capital_pagado = capital_debe,
	       capital_status = "5"
	 WHERE empresa = "001"
	   AND num_credito = vCred
	   AND fecha_cuota = vFecha;


END FOREACH

 
-- Repara creditos en estatus vencido transitorio
FOREACH xx WITH HOLD FOR
 	select a.num_credito, sdo_capital, sdo_cap_insoluto, monto_vencido,
	       (select sum(capital_debe - capital_pagado)
 	          from sd_amortiza_credito c
 	         where c.empresa = "001"
	           and c.num_credito = a.num_credito
	           and capital_status = "7") dif,
 	       mto_venc_trasp, cap_tras_no_venci, int_tra_no_exig
	  INTO vCred, vCapVig, vCapIns, vTrans, vTabla, vTrasp, vCapTrasNo,
	       vIntTrasNo
	  from sd_maesdos a, sd_maecred b
	 where status_cred = "BA"
	   and a.num_credito = b.num_credito
	   And (monto_vencido  <>
	       (select sum(capital_debe - capital_pagado)
	          from sd_amortiza_credito c
	         where c.empresa = "001"
	           and c.num_credito = a.num_credito
	           and capital_status = "7"))
	   AND campo_trab1 = 0 
	   --AND a.num_credito = "600000005485"

	BEGIN WORK;
	LET vBegin = "S";

	-- Arregla Tabla Meses Anteriores
	UPDATE sd_amortiza_credito 
	   SET capital_status = "5",
	       interes_status = "5"
	 WHERE empresa = "001"
	   AND num_credito = vCred
	   AND fecha_cuota < "02202008";

        UPDATE sd_amortiza_credito 
           SET capital_pagado = capital_debe
         WHERE empresa = "001"
           AND num_credito = vCred
           AND fecha_cuota < "02202008"
	   AND capital_pagado < capital_debe;


	SELECT (capital_debe - capital_pagado) - vTrans
	  INTO vTrans
	  FROM sd_amortiza_credito
         WHERE empresa = "001"
           AND num_credito = vCred
	   AND fecha_cuota = "02202008";

	IF vTrans < 0 THEN
	   UPDATE sd_maesdos
	      SET monto_vencido = vTabla,
		  sdo_capital = sdo_cap_insoluto - vTabla
            WHERE num_credito = vCred
              AND empresa = "001";

	ELSE

        UPDATE sd_amortiza_credito
           SET capital_pagado = vTrans
         WHERE empresa = "001"
           AND num_credito = vCred
           AND fecha_cuota = "02202008";

	END IF

	UPDATE sd_maecred SET campo_trab1 = 7
         WHERE num_credito = vCred
           AND empresa = "001";

	COMMIT WORK;
        LET vBegin ="N";

END FOREACH	


-- Repara cuota de Diciembre por centavos
FOREACH SELECT a.num_credito, ROUND(capital_mto_cuota,-0)
	  INTO vCred, vMinimo
	  FROM sd_amortiza_credito a, sd_maecred b
	 WHERE a.fecha_cuota = "12202007"
	   AND a.capital_status = "2"
	   AND b.empresa = a.empresa
	   AND b.num_credito = a.num_credito
	--   AND b.id_unidad_prod IS NULL

	UPDATE sd_amortiza_credito
	   SET capital_mto_cuota = vMinimo,
	       capital_debe = vMinimo
	 WHERE empresa = "001"
	   AND num_credito = vCred
	   AND fecha_cuota = "12202007";

END FOREACH
 
-- Repara Credito en estatus vencido traspasado
FOREACH trasp WITH HOLD FOR
   select a.num_credito, sdo_capital, sdo_cap_insoluto, monto_vencido,
          mto_venc_trasp,    
          (select sum(capital_debe - capital_pagado)
             from sd_amortiza_credito c
            where c.empresa = "001" 
              and c.num_credito = a.num_credito
              and capital_status = "2") dif,
          cap_tras_no_venci, int_tra_no_exig
     INTO vCred, vCapVig, vCapIns, vTrans, vTrasp, vTabla, vCapTrasNo,
          vIntTrasNo
     from sd_maesdos a, sd_maecred b
    where status_cred = "BT"
      and a.num_credito = b.num_credito
      And (mto_venc_trasp  <>
          (select sum(capital_debe - capital_pagado)
             from sd_amortiza_credito c
            where c.empresa = "001"
              and c.num_credito = a.num_credito
              and capital_status = "2"))
      AND campo_trab1 = 0
   --     AND b.num_credito = "600000238607"

	IF vCapIns < 0 THEN
		CONTINUE FOREACH;
	END IF

      BEGIN WORK;
      LET vBegin = "S";


      IF vTabla > vTrasp THEN

	SELECT COUNT(*) INTO vTabasco
	  FROM sd_amortiza_credito
	 WHERE empresa = "001"
	   AND num_credito = vCred
	   AND capital_status ="2";

	IF vTabasco = 2 THEN
		UPDATE sd_amortiza_credito
		   SET capital_pagado = capital_debe,
		       capital_status = "5"
		 WHERE empresa = "001"
		   AND num_credito = vCred
		   AND fecha_cuota < "12202007";


		UPDATE sd_amortiza_credito 
		   SET capital_debe = ROUND(capital_debe,-0),
		       capital_mto_cuota = ROUND(capital_mto_cuota,-0)
		 WHERE empresa = "001"
		   AND num_credito = vCred
		   AND fecha_cuota BETWEEN "12202007" AND "02202008";
	END IF


        SELECT MAX(fecha_cuota) INTO vFecha
          FROM sd_amortiza_credito
         WHERE empresa = "001"
           AND num_credito = vCred
           AND capital_status = "5";

        UPDATE sd_amortiza_credito
           SET capital_status = "5",
	       capital_pagado = capital_debe
         WHERE empresa = "001"
           AND num_credito = vCred
           AND fecha_cuota < vFecha;
	
	SELECT MIN(fecha_cuota) INTO vFecha
	  FROM sd_amortiza_credito
	 WHERE empresa = "001"
	   AND num_credito = vCred
	   AND capital_status = "2";


	UPDATE sd_amortiza_credito
	   SET capital_status = "2"
	 WHERE empresa = "001"
	   AND num_credito = vCred
	   AND fecha_cuota BETWEEN vFecha AND "02202008";

	FOREACH SELECT ROUND(cap_tras_no_venci/10,-0), fecha_cuota,
		       id_unidad_prod
		  INTO vMinimo, vFecha, vTabasco
		  FROM sd_amortiza_credito a, sd_maesdoshist b,
		       sd_maecred c
		 WHERE a.empresa = "001"
		   AND a.num_credito = vCred
		   AND a.capital_status = "2"
		   AND a.capital_debe = 0
		   AND b.fecha = a.fecha_cuota
		   AND b.empresa = "001"
		   AND b.num_credito = a.num_credito
		   AND c.num_credito = a.num_credito
		   AND c.empresa = a.empresa

		IF vTabasco = 0 THEN
		   LET vMinimo = vTrasp / 2;	
		END IF
		
		UPDATE sd_amortiza_credito
		   SET capital_mto_cuota = vMinimo,
		       capital_debe = vMinimo
		 WHERE empresa = "001"
		   AND num_credito = vCred
		   AND fecha_cuota = vFecha;

	END FOREACH


	SELECT fecha_cuota INTO vFecha
	  FROM sd_amortiza_credito
	 WHERE empresa = "001"
	   AND num_credito = vCred
	   AND capital_status = "2"
	   AND capital_debe <= capital_pagado;

	IF NOT vFecha IS NULL THEN
		UPDATE sd_amortiza_credito
		   SET capital_pagado = capital_debe,
		       capital_status = "5"
	         WHERE empresa = "001"
	           AND num_credito = vCred
	           AND fecha_cuota < vFecha 
		   AND capital_status = "2";

		UPDATE sd_amortiza_credito
		   SET capital_pagado = 0
	         WHERE empresa = "001"
	           AND num_credito = vCred
	           AND fecha_cuota = vFecha ;
	END IF

        select sum(capital_debe - capital_pagado)
	     INTO vTabla
             from sd_amortiza_credito c
            where c.empresa = "001"
              and c.num_credito = vCred
              and capital_status = "2"; 

	LET vTabla = vTabla - vTrasp;


        FOREACH SELECT fecha_cuota, capital_debe - capital_pagado
	 	INTO vFecha, vPagado
		FROM sd_amortiza_credito
	       WHERE empresa ="001"
		 AND num_credito = vCred
		 AND capital_status = "2"


		IF vTabla >= vPagado THEN

		   UPDATE sd_amortiza_credito 
		      SET capital_pagado = capital_debe,
			  capital_status = "5"
		    WHERE empresa = "001"
		      AND num_credito = vCred
		      AND fecha_cuota = vFecha;

		   LET vTabla = vTabla - vPagado;
		ELSE
		   UPDATE sd_amortiza_credito 
		      SET capital_pagado = capital_pagado + vTabla
		    WHERE empresa = "001"
		      AND num_credito = vCred
		      AND fecha_cuota = vFecha;

		   LET vTabla = 0;
		
		END IF
	
		IF vTabla = 0 THEN
		  EXIT FOREACH;
		END IF
        END FOREACH

        UPDATE sd_maecred SET campo_trab1 = 2
         WHERE num_credito = vCred
           AND empresa = "001";


     ELSE
	FOREACH SELECT fecha_cuota, capital_debe
		  INTO vFecha, vPagado
		  FROM sd_amortiza_credito
		 WHERE empresa ="001"
		   AND num_credito = vCred
		   AND fecha_cuota < "03202008" 
		 ORDER BY 1 DESC

                IF vTrasp  = 0 THEN
                        UPDATE sd_amortiza_credito
                           SET capital_pagado = capital_debe,
                               capital_status = "5"
                         WHERE empresa = "001"
                           AND num_credito = vCred
                           AND fecha_cuota = vFecha;

			CONTINUE FOREACH;

                END IF


		IF vPagado < vTrasp THEN
			LET vTrasp = vTrasp - vPagado;
                        UPDATE sd_amortiza_credito
                           SET capital_pagado = 0,
			       capital_status = "2"
                         WHERE empresa = "001"
                           AND num_credito = vCred
                           AND fecha_cuota = vFecha;

		ELSE
			LET vPagado = vPagado - vTrasp;
			UPDATE sd_amortiza_credito
			   SET capital_pagado = vPagado,
			       capital_status = "2"
			 WHERE empresa = "001"
			   AND num_credito = vCred
			   AND fecha_cuota = vFecha;
			LET vTrasp = 0;
		END IF

	END FOREACH

        UPDATE sd_maecred SET campo_trab1 = 2
         WHERE num_credito = vCred
           AND empresa = "001";


     END IF


     COMMIT WORK;
     LET vBegin ="N";




END FOREACH

RETURN cod_ret;

END PROCEDURE

;