CREATE PROCEDURE "informix".act_fecha()
RETURNING char(5);

DEFINE v_credito CHAR(20);
DEFINE v_fechas DATE;
DEFINE ax_codret CHAR(5);
DEFINE vsqlerr      INTEGER;
DEFINE v_mtooto MONEY(14,2);
DEFINE v_det    MONEY(14,2);
DEFINE v_dif    MONEY(14,2);
DEFINE v_cuota  MONEY(14,2);
DEFINE v_st     CHAR(1);

-- ASIGNA VALORES
LET ax_codret ="00000";
LET vsqlerr = 0;

-- CONTROL DE ERRORES
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET ax_codret=vsqlerr;
      RETURN ax_codret;
   END IF;
END EXCEPTION;




-- PROGRAMA PRINCIPAL

	FOREACH select num_credito, min(fecha_cuota)
		  INTO  v_credito,  v_fechas
		  from sd_amortiza_credito
                  where capital_status='2'
                  group by 1

         Update sd_maecredanexo set fecha_vencto = v_fechas
         where num_credito = v_credito;

	END FOREACH

END
	RETURN ax_codret;
END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".nivelavencido()
RETURNING CHAR(5);
 
 
DEFINE sql_err    SMALLINT;
DEFINE isam_err   SMALLINT;
DEFINE error_info CHAR(40);
DEFINE cod_ret    CHAR(5);
DEFINE vCred      CHAR(20);
DEFINE vFechaVencto DATE;
DEFINE vFechaCuota  DATE;
DEFINE vFechaPago   DATE;
DEFINE vCuotas      SMALLINT;
DEFINE vCcuotas     SMALLINT;
DEFINE vVencido     MONEY(14,2);
DEFINE vPVenc       MONEY(14,2);
DEFINE vFechaC      DATE;
DEFINE vFechaCR     DATE;
DEFINE vBegin       CHAR(1);
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
LET vBegin = "N";
 
-- **************************************************************************
-- *                      PROGRAMA PRINCIPAL                                *
-- **************************************************************************
 
 
FOREACH WITH HOLD
        SELECT a.num_credito, fecha_vencto,
               (SELECT MIN(fecha_cuota) FROM sd_amortiza_credito f
                 WHERE empresa ="001"
                   AND f.num_credito = a.num_credito
                   AND f.capital_status ="2"),
                (SELECT MAX(fecha_mov) FROM sd_movhis g
                  WHERE g.empresa ="001"
                    AND g.num_credito = a.num_credito
                    AND g.codigo_fun IN ("033", "334")
                    AND g.codigo_ref = 8),
                (SELECT COUNT(*) FROM sd_amortiza_credito h
                  WHERE h.empresa = "001"
                    AND h.num_credito = a.num_credito
                    AND h.capital_status ="2")
           INTO vCred, vFechaVencto, vFechaCuota, vFechaPago, vCuotas
           FROM sd_maecred a, sd_maecredanexo b
          WHERE a.empresa = "001"
            AND a.status_cred = "BT"
            AND b.empresa = a.empresa
            AND b.num_Credito = a.num_credito
            AND (SELECT MIN(fecha_cuota) FROM sd_amortiza_credito f
                 WHERE empresa ="001"
                   AND f.num_credito = a.num_credito
                   AND f.capital_status ="2") < fecha_vencto 
 
 
               SELECT MIN(fecha_cuota) INTO vFechaC
                 FROM sd_amortiza_credito 
                WHERE empresa = "001"
                  AND num_credito = vCred
                  AND capital_status = "5";
 
 
               UPDATE sd_amortiza_credito 
                  SET capital_pagado = capital_debe,
                      capital_status = "5"
                WHERE empresa = "001"
                  AND num_credito = vCred
                  AND fecha_cuota < vFechaC;
 
END FOREACH
 
 
FOREACH WITH HOLD 
            SELECT a.num_credito, fecha_vencto, 
                   (SELECT MIN(fecha_cuota) FROM sd_amortiza_credito f
                         WHERE empresa ="001"
                           AND f.num_credito = a.num_credito
                           AND f.capital_status ="2"),
                        (SELECT MAX(fecha_mov) FROM sd_movhis g
                          WHERE g.empresa ="001"
                            AND g.num_credito = a.num_credito
                            AND g.codigo_fun IN ("033", "334")
                            AND g.codigo_ref = 8),
                        (SELECT COUNT(*) FROM sd_amortiza_credito h
                          WHERE h.empresa = "001"
                            AND h.num_credito = a.num_credito
                            AND h.capital_status ="2")
               INTO vCred, vFechaVencto, vFechaCuota, vFechaPago, vCuotas
               FROM sd_maecred a, sd_maecredanexo b
              WHERE a.empresa = "001"
                AND a.status_cred = "BT"
                AND a.campo_trab1 <> 8
                AND b.empresa = a.empresa 
                AND b.num_Credito = a.num_credito
                AND fecha_vencto <>  
               (SELECT MIN(fecha_cuota) FROM sd_amortiza_credito f
                 WHERE empresa ="001"
                   AND f.num_credito = a.num_credito
                   AND f.capital_status ="2")
    --and a.num_credito = "600000013224" 
 
               IF vFechaCuota < vFechaVencto THEN
                        CONTINUE FOREACH;
               END IF
 
            LET vBegin = "S";
            BEGIN WORK;
 
            IF vFechaVencto <> vFechaCuota THEN
 
               IF NOT vFechaPago IS NULL THEN
                        SELECT UNIQUE(monto_financiado) INTO vVencido
                          FROM sd_maesdoshist 
                         WHERE fecha = vFechaVencto
                           AND empresa = "001"
                           AND num_credito = vCred;
 
                        SELECT NVL(SUM(monto),0) INTO vPVenc
                          FROM sd_movhis
                         WHERE empresa = "001"
                           AND num_credito = vCred
                           AND codigo_fun IN ("033", "334")
                           AND codigo_ref = 8 
                           AND fecha_mov >= vFechaVencto;
 
                        LET vPVenc = vPVenc / vVencido ;
                        IF vPVenc < 1 THEN
                                   LET vPVenc = 0;
                        END IF
                SELECT SUM(capital_debe - capital_pagado)
                  INTO vVencido
                  FROM sd_amortiza_credito
                 WHERE empresa = "001"
                   AND num_credito = vCred
                   AND capital_status = "2"
                   AND fecha_cuota = (SELECT MIN(fecha_cuota)
                                        FROM sd_amortiza_credito
                                       WHERE empresa ="001"
                                         AND num_credito = vCred
                                         AND capital_status = "2");
 
                        LET vCcuotas = ROUND((("04202008" - vFechaVencto) /30),-0);
                        IF vCcuotas < 1 THEN
                           LET vCcuotas = 0;
                        END IF
                        LET vPVenc = ROUND(vPVenc, -0);
                        LET vCcuotas = vCcuotas - vPVenc;
                        LET vCuotas = vCcuotas - vCuotas;
            
                        IF vCuotas > 0 THEN 
 
                           LET vVencido = vVencido / (vCuotas + 1);
 
                   SELECT fecha_cuota, capital_pagado 
                     INTO vFechaCR, vPVenc
                     FROM sd_amortiza_credito
                    WHERE empresa = "001"
                      AND num_credito = vCred
                      AND capital_status IN ("2")  
                              AND fecha_cuota = (SELECT MIN(fecha_cuota)
                                                          FROM sd_amortiza_credito
                                                             WHERE empresa = "001"
                                                               AND num_credito = vCred
                                                               AND capital_status = "2");
 
                           FOREACH SELECT fecha_cuota INTO vFechaC
                                        FROM sd_amortiza_credito
                                       WHERE empresa = "001"
                                         AND num_credito = vCred
                                         AND capital_status IN ("5")
                                       ORDER BY 1 DESC
 
                                       UPDATE sd_amortiza_credito      
                                          SET capital_debe = vVencido,
                                                  capital_mto_cuota = vVencido       ,
                                                  capital_pagado = 0,
                                                  capital_status = "2"
                                        WHERE empresa = "001"
                                          AND num_credito = vCred
                                          AND fecha_cuota = vFechaC;
 
                                       LET vCuotas = vCuotas - 1;
                                       IF vCuotas <= 0 THEN
                                               EXIT FOREACH;
                                       END IF
 
                           END FOREACH
                          
                           UPDATE sd_amortiza_credito       
                              SET capital_debe = vVencido,
                                     capital_mto_cuota = vVencido,
                                     capital_pagado = 0
                    WHERE empresa = "001"
                      AND num_credito = vCred
                              AND fecha_cuota = vFechaCR;
 
                   {SELECT MIN(fecha_cuota)
                     INTO vFechaCR
                     FROM sd_amortiza_credito
                    WHERE empresa = "001"
                      AND num_credito = vCred
                      AND capital_status IN ("2");
 
                           UPDATE sd_amortiza_credito 
                              SET capital_debe = capital_debe + vPVenc,
                                  capital_mto_cuota = capital_mto_cuota + vPVenc,
                                  capital_pagado = vPVenc
                    WHERE empresa = "001"
                      AND num_credito = vCred
                              AND fecha_cuota = vFechaCR;}
                             
                   SELECT mto_venc_trasp -
                          (SELECT sum(capital_debe - capital_pagado)
                             FROM sd_amortiza_credito
                            WHERE empresa = "001"
                              AND num_credito = vCred
                              AND capital_status = "2")
                      INTO vVencido
                      FROM sd_maesdos
                     WHERE empresa = "001"
                       AND num_credito = vCred;
 
                   IF vVencido > 0 THEN
                        SELECT MIN(fecha_cuota) INTO vFechaC
                          FROM sd_amortiza_credito
                         WHERE empresa = "001"
                           AND num_credito = vCred
                           AND capital_status = "2";
 
                        UPDATE sd_amortiza_credito
                           SET capital_debe = capital_debe + vVencido,
                               capital_mto_cuota = capital_mto_cuota + vVencido
                         WHERE empresa = "001"
                           AND num_credito = vCred
                           AND fecha_cuota = vFechaC;
                   ELIF vVencido < 0 THEN
                        SELECT MIN(fecha_cuota) INTO vFechaC
                          FROM sd_amortiza_credito
                         WHERE empresa = "001"
                           AND num_credito = vCred
                           AND capital_status = "2";
 
                        UPDATE sd_amortiza_credito
                           SET capital_debe = capital_debe + vVencido,
                               capital_mto_cuota = capital_mto_cuota + vVencido
                         WHERE empresa = "001"
                           AND num_credito = vCred
                           AND fecha_cuota = vFechaC;
                            END IF
 
 
                        END IF
 
 
               ELSE
                        
                        LET vCcuotas = ROUND(((vFechaVencto - vFechaCuota) /30),-0);
                        IF vCcuotas > 0 THEN
                           LET vCuotas = vCuotas - vCcuotas;
                           SELECT FIRST vCcuotas SUM(capital_debe - capital_pagado)
                             INTO vVencido
                             FROM sd_amortiza_credito 
                            WHERE empresa = "001"
                              AND num_credito = vCred
                              AND capital_status = "2";
 
                           FOREACH SELECT fecha_cuota INTO vFechaC
                                        FROM sd_amortiza_credito
                                       WHERE empresa = "001"
                                         AND num_credito = vCred
                                         AND capital_status = "2"
 
                                   UPDATE sd_amortiza_credito 
                                      SET capital_pagado = capital_debe
                                    WHERE empresa = "001"
                                      AND num_credito = vCred
                                      AND fecha_cuota = vFechaC;
 
                                   LET vCcuotas = vCcuotas - 1;
                                   IF vCcuotas <= 0 THEN
                                      EXIT FOREACH;
                                   END IF
                           END FOREACH
 
                           SELECT MIN(fecha_cuota) INTO vFechaC
                             FROM sd_amortiza_credito
                            WHERE empresa = "001"
                              AND num_credito = vCred
                              AND capital_status = "2";
                                   
                           UPDATE sd_amortiza_credito
                              SET capital_debe = capital_debe + vVencido,
                                     capital_mto_cuota = capital_mto_cuota + vVencido
                            WHERE empresa = "001"
                              AND num_credito = vCred
                              AND fecha_cuota = vFechaC;
 
                        ELSE
                           LET vCcuotas = vCcuotas * -1;
                   SELECT fecha_cuota, (capital_debe - capital_pagado )
                     INTO vFechaC, vVencido
                     FROM sd_amortiza_credito
                    WHERE empresa = "001"
                      AND num_credito = vCred
                      AND capital_status = "2"
                              AND fecha_cuota = (SELECT MIN(fecha_cuota)
                                                              FROM sd_amortiza_credito
                                                             WHERE empresa ="001"
                                                               AND num_credito = vCred
                                                               AND capital_status = "2");
 
 
                           LET vVencido = vVencido / (vCcuotas+1);                          
 
                           UPDATE sd_amortiza_credito
                              SET capital_debe = vVencido,
                                     capital_mto_cuota = vVencido,
                                     capital_pagado = 0
                    WHERE empresa = "001"
                      AND num_credito = vCred
                              AND fecha_cuota = vFechaC;
                        
 
                           FOREACH SELECT FIRST vCcuotas fecha_cuota
                                        INTO vFechaC
                                        FROM sd_amortiza_credito
                                       WHERE empresa = "001"
                                         AND num_credito = vCred
                                         AND capital_status = "5"
                                       ORDER BY 1 DESC
 
 
                                   UPDATE sd_amortiza_credito          
                                      SET capital_debe = vVencido,
                                          capital_mto_cuota = vVencido,
                                          capital_pagado = 0,
                                          capital_status = "2"
                                       WHERE empresa = "001"
                                         AND num_credito = vCred
                                         AND fecha_cuota = vFechaC;
                                   
                           END FOREACH
 
                           {SELECT MIN(fecha_cuota) INTO vFechaC
                             FROM sd_amortiza_credito 
                            WHERE empresa = "001"
                              AND num_credito = vCred
                              AND capital_status = "2";
 
 
                           UPDATE sd_amortiza_credito                   
                              SET capital_debe = capital_debe + vPVenc,
                                  capital_mto_cuota = capital_mto_cuota + vPVenc,
                                     capital_pagado = vPvenc
                            WHERE empresa = "001"
                              AND num_credito = vCred
                              AND fecha_cuota = vFechaC;}
 
 
                           SELECT mto_venc_trasp -
                                     (SELECT sum(capital_debe - capital_pagado)
                                        FROM sd_amortiza_credito
                                       WHERE empresa = "001"
                                         AND num_credito = vCred
                                         AND capital_status = "2")
                              INTO vVencido
                              FROM sd_maesdos
                             WHERE empresa = "001"
                               AND num_credito = vCred;
 
                           IF vVencido > 0 THEN
                                   SELECT MIN(fecha_cuota) INTO vFechaC
                                     FROM sd_amortiza_credito 
                                    WHERE empresa = "001"
                                      AND num_credito = vCred
                                      AND capital_status = "2";
 
                                   UPDATE sd_amortiza_credito          
                                      SET capital_debe = capital_debe + vVencido,
                                          capital_mto_cuota = capital_mto_cuota + vVencido
                                    WHERE empresa = "001"
                                      AND num_credito = vCred
                                      AND fecha_cuota = vFechaC;
                           ELIF vVencido < 0 THEN
                        SELECT MIN(fecha_cuota) INTO vFechaC
                          FROM sd_amortiza_credito 
                         WHERE empresa = "001"
                           AND num_credito = vCred
                           AND capital_status = "2";
 
                        UPDATE sd_amortiza_credito      
                           SET capital_debe = capital_debe + vVencido,
                               capital_mto_cuota = capital_mto_cuota + vVencido
                         WHERE empresa = "001"
                           AND num_credito = vCred
                           AND fecha_cuota = vFechaC;
 
                           END IF
 
                        END IF
 
 
                        IF vCuotas < 0 THEN
 
 
                        END IF
 
            
               END IF
            ELSE
                        
 
            END IF
 
            UPDATE sd_maecred SET campo_trab1 = 8
             WHERE empresa ="001"
               AND num_credito = vCred;
 
            COMMIT WORK;
            LET vBegin = "N";
 
 
END FOREACH
 
 
            RETURN cod_ret;
 
 
END PROCEDURE
 
;