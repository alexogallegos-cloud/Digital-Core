CREATE PROCEDURE "informix".contcie2(pempresa char(3),pfecha_hoy date)
RETURNING char(5);

   DEFINE cod_ret      char(5);
   DEFINE cod_reti     char(5);
   DEFINE v_mc1        char(2);
   DEFINE v_mc2        char(2);
   DEFINE v_ano        char(4);
   DEFINE v_ctaingini  char(10);
   DEFINE v_ctaingfin  char(10);
   DEFINE v_ctagtoini  char(10);
   DEFINE v_ctagtofin  char(10);
   DEFINE v_perganmay  char(10);
   DEFINE v_pergansub  char(10);
   DEFINE v_perganss   char(10);
   DEFINE v_pergansss  char(10);
   DEFINE v_perganssss char(10);
   DEFINE v_pergansect char(10);
   DEFINE v_canret     char(15);
   DEFINE v_prihabmes  date;
   DEFINE v_ulthabmes  date;
   DEFINE v_fecha_ant  date;
   DEFINE v_sql        char(500);
   DEFINE v_proceso    char(10);
   DEFINE GLOBAL v_hora_inicio CHAR(12) DEFAULT "";
   DEFINE GLOBAL v_hora_fin    CHAR(12) DEFAULT "";
   DEFINE GLOBAL v_fecha_proceso DATE DEFAULT "";

   -- **************************************************************************
   -- ************************ INICIALIZA VARIABLES ****************************
   -- **************************************************************************

   LET v_hora_inicio = CURRENT HOUR TO FRACTION(3);
   LET cod_ret = "000";
   LET cod_reti = "000";
   LET v_ano = year(pfecha_hoy);
   LET v_mc1        = " ";
   LET v_mc2        = " ";
   LET v_ctaingini  = " ";
   LET v_ctaingfin  = " ";
   LET v_ctagtoini  = " ";
   LET v_ctagtofin  = " ";
   LET v_perganmay  = " ";
   LET v_pergansub  = " ";
   LET v_perganss   = " ";
   LET v_pergansss  = " ";
   LET v_perganssss = " ";
   LET v_pergansect = " ";
   LET v_canret     = " ";
   LET v_proceso = "cierre";
   LET v_fecha_proceso = pfecha_hoy;

   -- **************************************************************************
   -- ********************** COMIENZA EL PROCESO DE CIERRE *********************
   -- **************************************************************************

	--SET DEBUG FILE TO '/tmp/contcie2.out';
	--TRACE ON;
      
   DELETE FROM co_cierre_cif 
	     WHERE (cierre_fecha= v_fecha_proceso
		   AND codigo_retorno != '000')
			OR cierre_fecha != v_fecha_proceso ;

   LET v_hora_inicio = CURRENT HOUR TO FRACTION(3);
   EXECUTE PROCEDURE pase_movtos(pempresa,pfecha_hoy) into cod_ret;
   LET v_hora_fin = CURRENT HOUR TO FRACTION(3);

   IF NOT cod_ret = '999' THEN
	   EXECUTE PROCEDURE inserta_estatus_cierre(pempresa,pfecha_hoy,"PASE_MOVTOS",
													 "EFECTUADO",cod_ret,0,0,
													 v_hora_inicio,v_hora_fin) into cod_reti;
	ELSE
		LET cod_ret = "000";
	END IF

   SELECT pri_hab_mes,ult_hab_mes,fecha_ant
   INTO   v_prihabmes,v_ulthabmes,v_fecha_ant
   FROM   co_fechas
   WHERE  empresa = pempresa;

   SELECT mescierre1,   mescierre2,    cta_ing_inic,  cta_ing_final,
          cta_gto_inic, cta_gto_final, per_gan_mayor, per_gan_sub,
          per_gan_ss,   per_gan_sss,   per_gan_ssss,  per_gan_sect
   INTO   v_mc1,        v_mc2,         v_ctaingini,   v_ctaingfin,
          v_ctagtoini,  v_ctagtofin,   v_perganmay,   v_pergansub,
          v_perganss,   v_pergansss,   v_perganssss,  v_pergansect
   FROM co_param
   WHERE empresa = pempresa;

   IF v_mc1 IS NULL or v_mc1 = " " or
      v_mc2 IS NULL or v_mc2 = " " or
      v_ctaingini  IS NULL or v_ctaingini  = " " or
      v_ctaingfin  IS NULL or v_ctaingfin  = " " or
      v_ctagtoini  IS NULL or v_ctagtoini  = " " or
      v_ctagtofin  IS NULL or v_ctagtofin  = " " or
      v_perganmay  IS NULL or v_perganmay  = " " or
      v_pergansub  IS NULL or v_pergansub  = " " or
      v_perganss   IS NULL or v_perganss   = " " or
      v_pergansss  IS NULL or v_pergansss  = " " or
      v_perganssss IS NULL or v_perganssss = " " or
      v_pergansect IS NULL or v_pergansect = " " THEN

      LET cod_ret = "123";

      EXECUTE PROCEDURE contproc(pempresa,pfecha_hoy,v_proceso,cod_ret);

      LET v_hora_fin = CURRENT HOUR TO FRACTION(3);
      EXECUTE PROCEDURE inserta_estatus_cierre(pempresa,pfecha_hoy,"VALIDA NULL",
                                 "CIERRE NO EFECTUADO",cod_ret,0,0,
                                  v_hora_inicio,v_hora_fin) into cod_reti ;

    ELSE
	      -- Limpia tabla de movtos. a cuentas de resultados retroactivos del dia
	      LET v_canret = "co_canret";

	      DELETE FROM co_canret
	      WHERE  empresa = pempresa
	      AND    fecha_captura = pfecha_hoy;

	      -- Verifica si ejecuta proceso de cierre_anual limpia todos los registros
	      -- de movtos a cuentas de resultados del ejercicio contable
	      IF  month(pfecha_hoy) = v_mc2 AND pfecha_hoy  = v_prihabmes  THEN
	           DELETE FROM co_canret
	           WHERE empresa    = pempresa
	           AND year(fecha)  = year(v_fecha_ant)
	           AND month(fecha) = month(v_fecha_ant);
	      END IF

	    IF pfecha_hoy = v_ulthabmes THEN
			IF NOT EXISTS (SELECT codigo_retorno FROM co_cierre_cif 
					                    WHERE cierre_fecha = v_fecha_proceso
	                                      AND descripcion_cierre="CIERRE_MENSUAL"
										  AND codigo_retorno = '000') THEN

			    LET v_hora_inicio = CURRENT HOUR TO FRACTION(3);
		        EXECUTE PROCEDURE cierre_mensual(pempresa,pfecha_hoy) into cod_ret;
			    LET v_hora_fin = CURRENT HOUR TO FRACTION(3);

				IF NOT cod_ret = '999' THEN
					EXECUTE PROCEDURE inserta_estatus_cierre(pempresa,pfecha_hoy,"CIERRE_MENSUAL",
															 "EFECTUADO",cod_ret,0,0,
															 v_hora_inicio,v_hora_fin) into cod_reti;
				ELSE
					LET cod_ret = "000";
				END IF
			END IF
		ELSE
			IF NOT EXISTS (SELECT codigo_retorno FROM co_cierre_cif 
					                    WHERE cierre_fecha = v_fecha_proceso
	                                      AND descripcion_cierre="CIERRE_DIARIO"
										  AND codigo_retorno = '000') THEN

			    LET v_hora_inicio = CURRENT HOUR TO FRACTION(3);
		        EXECUTE PROCEDURE cierre_diario(pempresa,pfecha_hoy) into cod_ret;
			    LET v_hora_fin = CURRENT HOUR TO FRACTION(3);

				IF NOT cod_ret = '999' THEN
					EXECUTE PROCEDURE inserta_estatus_cierre(pempresa,pfecha_hoy,"CIERRE_DIARIO",
															 "EFECTUADO",cod_ret,0,0,
															 v_hora_inicio,v_hora_fin) into cod_reti;
				ELSE
					LET cod_ret = "000";
				END IF

			END IF
	    END IF

		IF cod_ret = "000" THEN
			IF NOT EXISTS (SELECT codigo_retorno FROM co_cierre_cif 
					                    WHERE cierre_fecha = v_fecha_proceso
	                                      AND descripcion_cierre="DEPURA_CTAS"
										  AND codigo_retorno = '000') THEN

			    LET v_hora_inicio = CURRENT HOUR TO FRACTION(3);
			    EXECUTE PROCEDURE depura_ctas(pempresa) into cod_ret;
				LET v_hora_fin = CURRENT HOUR TO FRACTION(3);   

				IF NOT cod_ret = '999' THEN
					EXECUTE PROCEDURE inserta_estatus_cierre(pempresa,pfecha_hoy,"DEPURA_CTAS",
															 "EFECTUADO",cod_ret,0,0,
															 v_hora_inicio,v_hora_fin) into cod_reti;
				ELSE
					LET cod_ret = "000";
				END IF
			END IF
	    END IF
	END IF

   EXECUTE PROCEDURE contproc(pempresa,pfecha_hoy,v_proceso,cod_ret);
   LET v_hora_fin = CURRENT HOUR TO FRACTION(3);
   EXECUTE PROCEDURE inserta_estatus_cierre(pempresa,pfecha_hoy,"CIERRE CONTABLE",
                           "CIERRE EFECTUADO",cod_ret,0,0,
                            v_hora_inicio,v_hora_fin) into cod_reti; 

RETURN cod_ret;
END PROCEDURE;