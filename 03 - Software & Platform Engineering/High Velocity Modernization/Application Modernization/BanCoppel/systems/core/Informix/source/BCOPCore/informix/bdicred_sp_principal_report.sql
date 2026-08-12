CREATE PROCEDURE "informix".sp_principal_report(p_Empresa CHAR(03))


   DEFINE CodRet      CHAR(03);
   DEFINE sql_err     SMALLINT;
   DEFINE v_ruta      CHAR(100);
   DEFINE v_sql       CHAR(1000);

   DEFINE v_fecha_hoy	           DATE;
   DEFINE v_ult_dia_mes          DATE;

   LET  CodRet = 0;
   LET v_ruta  = '';
   LET v_sql   = '';

   LET v_fecha_hoy            = ' ';
   LET v_ult_dia_mes          = ' ';

   BEGIN
           ON EXCEPTION SET sql_err
              IF sql_err <> 0  THEN
                 LET CodRet = sql_err;
                 ROLLBACK WORK;
              END IF
           END EXCEPTION;
   END;


   --SET DEBUG FILE TO "/ids10_uc9/raul/pisa/sp_principal.out";
   --TRACE ON;

   SET ISOLATION TO DIRTY READ;

    SELECT TRIM(valor)
    INTO v_ruta
    FROM sd_param
    WHERE cod_param ='47';



   CALL sp_general_aperturas(p_Empresa)
   RETURNING CodRet;

   IF  CodRet <> "000"  THEN
       LET CodRet = CodRet;
        BEGIN
            ON EXCEPTION IN (-668) SET sql_err
                LET CodRet = "000";
            END EXCEPTION WITH RESUME;
            LET v_sql = 'echo ' || '>>' ||TRIM(v_ruta)|| 'Error_En_SPL_sp_general_aperturas Error : '|| CodRet || ' DIA ' ||TODAY;
            SYSTEM trim(v_sql);
         END ;
   END IF;


   CALL sp_movtos_cobranza(p_Empresa)
   RETURNING CodRet;

   IF  CodRet <> "000"  THEN
       LET CodRet = CodRet;
        BEGIN
            ON EXCEPTION IN (-668) SET sql_err
                LET CodRet = "000";
            END EXCEPTION WITH RESUME;
            LET v_sql = 'echo ' || '>>' ||TRIM(v_ruta)|| 'Error_En_SPL_sp_movtos_cobranza Error : '|| CodRet || ' DIA ' ||TODAY;
            SYSTEM trim(v_sql);
         END ;
   END IF;

   CALL sp_movtos_contab(p_Empresa)
   RETURNING CodRet;
   IF  CodRet <> "000"  THEN
       LET CodRet = CodRet;
        BEGIN
            ON EXCEPTION IN (-668) SET sql_err
                LET CodRet = "000";
            END EXCEPTION WITH RESUME;
            LET v_sql = 'echo ' || '>>' ||TRIM(v_ruta)|| 'Error_En_SPL_sp_movtos_contab Error : '|| CodRet || ' DIA ' ||TODAY;
            SYSTEM trim(v_sql);
         END ;
   END IF;

   CALL sp_sucursales_banco(p_Empresa)
   RETURNING CodRet;

   IF  CodRet <> "000"  THEN
       LET CodRet = CodRet;
        BEGIN
            ON EXCEPTION IN (-668) SET sql_err
                LET CodRet = "000";
            END EXCEPTION WITH RESUME;
            LET v_sql = 'echo ' || '>>' ||TRIM(v_ruta)|| 'Error_En_SPL_sp_sucursales_banco Error : '|| CodRet || ' DIA ' ||TODAY;
            SYSTEM trim(v_sql);
         END ;
   END IF;
   
      SELECT {+INDEX (sd_fechas idx_sdfechas)}
             fecha_hoy, ult_dia_mes
        INTO v_fecha_hoy, v_ult_dia_mes
        FROM sd_fechas
       WHERE empresa = p_empresa;

          IF (v_ult_dia_mes - 3 = v_fecha_hoy) OR (v_ult_dia_mes - 2 = v_fecha_hoy) THEN
              IF MONTH (v_ult_dia_mes) < '12' THEN
                     CALL sp_vencimientos(p_Empresa)
                          RETURNING CodRet;

                       IF  CodRet <> "000"  THEN
                           LET CodRet = CodRet;
                            BEGIN
                                ON EXCEPTION IN (-668) SET sql_err
                                    LET CodRet = "000";
                                END EXCEPTION WITH RESUME;
                                LET v_sql = 'echo ' || '>>' ||TRIM(v_ruta)|| 'Error_En_SPL_sp_vencimientos Error : '|| CodRet || ' DIA ' ||TODAY;
                                SYSTEM trim(v_sql);
                            END ;
                       END IF;
              END IF;
          ELIF (DAY (v_fecha_hoy) = '12') OR (DAY (v_fecha_hoy) = '13') THEN
                     CALL sp_vencimientos(p_Empresa)
                          RETURNING CodRet;

                       IF  CodRet <> "000"  THEN
                           LET CodRet = CodRet;
                            BEGIN
                                ON EXCEPTION IN (-668) SET sql_err
                                    LET CodRet = "000";
                                END EXCEPTION WITH RESUME;
                                LET v_sql = 'echo ' || '>>' ||TRIM(v_ruta)|| 'Error_En_SPL_sp_vencimientos Error : '|| CodRet || ' DIA ' ||TODAY;
                                SYSTEM trim(v_sql);
                            END ;
                       END IF;
          END IF;
                    
   CALL sp_maestro_saldos(p_Empresa)
   RETURNING CodRet;

   IF  CodRet <> "000"  THEN
       LET CodRet = CodRet;
        BEGIN
            ON EXCEPTION IN (-668) SET sql_err
                LET CodRet = "000";
            END EXCEPTION WITH RESUME;
            LET v_sql = 'echo ' || '>>' ||TRIM(v_ruta)|| 'Error_En_SPL_sp_maestro_saldos Error : '|| CodRet || ' DIA ' ||TODAY;
            SYSTEM trim(v_sql);
         END ;
   END IF;

END PROCEDURE
;