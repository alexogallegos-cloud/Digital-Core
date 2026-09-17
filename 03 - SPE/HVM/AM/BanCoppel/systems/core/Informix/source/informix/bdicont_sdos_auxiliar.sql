CREATE PROCEDURE "informix".sdos_auxiliar(p_empresa CHAR(3))
   RETURNING CHAR(5);

   DEFINE codret                        CHAR(5);
   DEFINE sql_err                       SMALLINT;
   DEFINE isam_err                      SMALLINT;
   DEFINE error_info                    CHAR(40);

   DEFINE GLOBAL v_fecha_hoy            DATE DEFAULT "";
   DEFINE GLOBAL v_fecha_ant            DATE DEFAULT "";
   DEFINE GLOBAL v_prox_fecha           DATE DEFAULT "";
   DEFINE GLOBAL v_ccmayor              CHAR(10) DEFAULT "          ";
   DEFINE GLOBAL v_ccsub                CHAR(10) DEFAULT "          ";
   DEFINE GLOBAL v_ccsubsub             CHAR(10) DEFAULT "          ";
   DEFINE GLOBAL v_ccssubsub            CHAR(10) DEFAULT "          ";
   DEFINE GLOBAL v_ccsssubsub           CHAR(10) DEFAULT "          ";
   DEFINE GLOBAL v_sector               CHAR(10) DEFAULT "          ";
   DEFINE GLOBAL v_naturaleza_cta       CHAR(1) DEFAULT " ";
   DEFINE GLOBAL v_auxiliar             CHAR(1) DEFAULT " ";
   DEFINE GLOBAL v_ciudad               CHAR(3) DEFAULT "   ";
   DEFINE GLOBAL v_sucursal             CHAr(4) DEFAULT "   ";

   DEFINE lv_maxdia                     DATE;
   DEFINE lv_moneda                     CHAR(2);
   DEFINE lv_cargos_dia                 MONEY(14,2);
   DEFINE lv_abonos_dia                 MONEY(14,2);
   DEFINE lv_sdo_fin_de_dia             MONEY(14,2);
   DEFINE lv_nat_movto                  CHAR(1);
   DEFINE wsdo_fin_de_dia               MONEY(14,2);
   DEFINE lv_nroaux                     CHAR(12);
   DEFINE ccosto_institucional          CHAR(4);


   ON EXCEPTION SET sql_err, isam_err, error_info
      LET codret = sql_err;
      SET DEBUG FILE TO "Sdos_Auxiliar.err";
      TRACE sql_err||" * "||isam_err|| " * "||error_info;
      RETURN codret;
   END EXCEPTION;

   

   LET codret = "000";

   SELECT
      MAX(mes_dia)
   INTO
      lv_maxdia
   FROM
      co_diasaux
   WHERE
      empresa    = p_empresa
   AND
      ccmayor    = v_ccmayor
   AND
      ccsub      = v_ccsub
   AND
      ccsubsub   = v_ccsubsub
   AND
      ccssubsub  = v_ccssubsub
   AND
      ccsssubsub = v_ccsssubsub
   AND
      sector     = v_sector
   AND
      MONTH(mes_dia) = MONTH(v_fecha_hoy)
   AND
      YEAR(mes_dia)  = YEAR(v_fecha_hoy);


   FOREACH
      SELECT
         ciudad,
         sucursal,
         moneda,
         auxiliar,
         SUM(cargos_dia),
         SUM(abonos_dia),
         SUM(saldo_fin_de_dia)
      INTO
         v_ciudad,
         v_sucursal,
         lv_moneda,
         lv_nroaux,
         lv_cargos_dia,
         lv_abonos_dia,
         lv_sdo_fin_de_dia
      FROM
         co_diasaux
      WHERE
         empresa        = p_empresa
      AND
         ccmayor        = v_ccmayor
      AND
         ccsub          = v_ccsub
      AND
         ccsubsub       = v_ccsubsub
      AND
         ccssubsub      = v_ccssubsub
      AND
         ccsssubsub     = v_ccsssubsub
      AND
         sector         = v_sector
      AND
         MONTH(mes_dia) = MONTH(v_fecha_hoy)
      AND
         YEAR(mes_dia)  = YEAR(v_fecha_hoy)
      GROUP BY
         1,2,3,4
      ORDER BY
         1,2,3,4

      IF (v_naturaleza_cta = "D") THEN
         IF (lv_sdo_fin_de_dia > 0) THEN
            IF (v_sucursal IS NOT NULL) THEN
               LET lv_nat_movto = "C";
               INSERT INTO
                  co_cance
               VALUES
                  (p_empresa,
                   v_fecha_ant,
                   v_ccmayor,
                   v_ccsub,
                   v_ccsubsub,
                   v_ccssubsub,
                   v_ccsssubsub,
                   v_sector,
                   v_ciudad,
                   v_sucursal,
                   lv_moneda,
                   lv_nroaux,
                   lv_sdo_fin_de_dia,
                   0,
                   lv_sdo_fin_de_dia,
                   0);
            END IF ;
         ELSE
            IF (v_sucursal IS NOT NULL) THEN
               LET lv_nat_movto = "D";
               LET wsdo_fin_de_dia = lv_sdo_fin_de_dia * -1;
               INSERT INTO
                  co_cance
               VALUES
                  (p_empresa,
                   v_fecha_ant,
                   v_ccmayor,
                   v_ccsub,
                   v_ccsubsub,
                   v_ccssubsub,
                   v_ccsssubsub,
                   v_sector,
                   v_ciudad,
                   v_sucursal,
                   lv_moneda,
                   lv_nroaux,
                   lv_sdo_fin_de_dia,
                   wsdo_fin_de_dia,
                   0,
                   0);
            END IF;
         END IF;
      ELSE
         IF (lv_sdo_fin_de_dia > 0) THEN
            IF (v_sucursal IS NOT NULL) THEN
               LET lv_nat_movto = "C";
               INSERT INTO
                  co_cance
               VALUES
                  (p_empresa,
                   v_fecha_ant,
                   v_ccmayor,
                   v_ccsub,
                   v_ccsubsub,
                   v_ccssubsub,
                   v_ccsssubsub,
                   v_sector,
                   v_ciudad,
                   v_sucursal,
                   lv_moneda,
                   lv_nroaux,
                   lv_sdo_fin_de_dia,
                   0,
                   lv_sdo_fin_de_dia,
                   0);
            END IF ;
         ELSE
            IF (v_sucursal IS NOT NULL) THEN
               LET lv_nat_movto = "D";
               LET wsdo_fin_de_dia = lv_sdo_fin_de_dia * -1;
               INSERT INTO
                  co_cance
               VALUES
                  (p_empresa,
                   v_fecha_ant,
                   v_ccmayor,
                   v_ccsub,
                   v_ccsubsub,
                   v_ccssubsub,
                   v_ccsssubsub,
                   v_sector,
                   v_ciudad,
                   v_sucursal,
                   lv_moneda,
                   lv_nroaux,
                   lv_sdo_fin_de_dia,
                   wsdo_fin_de_dia,
                   0,
                   0);
            END IF;
         END IF;
      END IF;
   END FOREACH;
   RETURN codret;
END PROCEDURE
DOCUMENT
" Subrutina para la cencelacion de resultados para cuentas ",
" con auxiliar es llamada por el SPL",
" Cancela_Resultados                                                ",
" AUTOR : Raul Mendoza D'nes",
" Fecha : 18/Agosto/2001",
" Ver.  : 1.0 ",
" Mod.  : ",
" BD.   : bdicont",
"Llamado por : Cancela_Resultados",
"Param  : empresa";

CREATE PROCEDURE "informix".sdos_sin_auxiliar(p_empresa CHAR(3))
   RETURNING CHAR(5);

   DEFINE codret                        CHAR(5);
   DEFINE sql_err                       SMALLINT;
   DEFINE isam_err                      SMALLINT;
   DEFINE error_info                    CHAR(40);

   DEFINE GLOBAL v_fecha_hoy            DATE DEFAULT "";
   DEFINE GLOBAL v_fecha_ant            DATE DEFAULT "";
   DEFINE GLOBAL v_prox_fecha           DATE DEFAULT "";
   DEFINE GLOBAL v_ccmayor              CHAR(10) DEFAULT "          ";
   DEFINE GLOBAL v_ccsub                CHAR(10) DEFAULT "          ";
   DEFINE GLOBAL v_ccsubsub             CHAR(10) DEFAULT "          ";
   DEFINE GLOBAL v_ccssubsub            CHAR(10) DEFAULT "          ";
   DEFINE GLOBAL v_ccsssubsub           CHAR(10) DEFAULT "          ";
   DEFINE GLOBAL v_sector               CHAR(10) DEFAULT "          ";
   DEFINE GLOBAL v_naturaleza_cta       CHAR(1) DEFAULT " ";
   DEFINE GLOBAL v_auxiliar             CHAR(1) DEFAULT " ";

   DEFINE GLOBAL v_ciudad               CHAR(3) DEFAULT "   ";
   DEFINE GLOBAL v_sucursal             CHAr(4) DEFAULT "   ";

   DEFINE lv_maxdia                     DATE;
   DEFINE lv_moneda                     CHAR(2);
   DEFINE lv_cargos_dia                 MONEY(14,2);
   DEFINE lv_abonos_dia                 MONEY(14,2);
   DEFINE lv_sdo_fin_de_dia             MONEY(14,2);
   DEFINE lv_nat_movto                  CHAR(1);
   DEFINE wsdo_fin_de_dia               MONEY(14,2);



   ON EXCEPTION SET sql_err, isam_err, error_info
      LET codret = sql_err;
      SET DEBUG FILE TO "Sdos_Sin_Auxiliar.err";
      TRACE sql_err||" * "||isam_err|| " * "||error_info;
      RETURN codret;
   END EXCEPTION;

   

   LET codret = "000";

   SELECT
      MAX(mes_dia)
   INTO
      lv_maxdia
   FROM
      co_sdodias
   WHERE
      empresa    = p_empresa
   AND
      ccmayor    = v_ccmayor
   AND
      ccsub      = v_ccsub
   AND
      ccsubsub   = v_ccsubsub
   AND
      ccssubsub  = v_ccssubsub
   AND
      ccsssubsub = v_ccsssubsub
   AND
      sector     = v_sector
   AND
      MONTH(mes_dia) = MONTH(v_fecha_hoy)
   AND
      YEAR(mes_dia)  = YEAR(v_fecha_hoy);

   FOREACH
      SELECT
         ciudad,
         sucursal,
         moneda,
         SUM(cargos_dia),
         SUM(abonos_dia),
         SUM(saldo_fin_de_dia)
      INTO
         v_ciudad,
         v_sucursal,
         lv_moneda,
         lv_cargos_dia,
         lv_abonos_dia,
         lv_sdo_fin_de_dia
      FROM
         co_sdodias
      WHERE
         empresa        = p_empresa
      AND
         ccmayor        = v_ccmayor
      AND
         ccsub          = v_ccsub
      AND
         ccsubsub       = v_ccsubsub
      AND
         ccssubsub      = v_ccssubsub
      AND
         ccsssubsub     = v_ccsssubsub
      AND
         sector         = v_sector
      AND
         mes_dia        = lv_maxdia
      GROUP BY
         1,2,3
      ORDER BY
         1,2,3

      IF (v_naturaleza_cta = "D") THEN
         IF (lv_sdo_fin_de_dia > 0) THEN
            IF (v_sucursal IS NOT NULL) THEN
               LET lv_nat_movto = "C";
               INSERT INTO
                  co_cance
               VALUES
                  (p_empresa,
                   v_fecha_ant,
                   v_ccmayor,
                   v_ccsub,
                   v_ccsubsub,
                   v_ccssubsub,
                   v_ccsssubsub,
                   v_sector,
                   v_ciudad,
                   v_sucursal,
                   lv_moneda,
                   " ",
                   lv_sdo_fin_de_dia,
                   0,
                   lv_sdo_fin_de_dia,
                   0);

            END IF ;
         ELSE
            ---- saldo negativo ----
            IF (v_sucursal IS NOT NULL) THEN
               LET lv_nat_movto = "D";
               LET wsdo_fin_de_dia = lv_sdo_fin_de_dia * -1;
               INSERT INTO
                  co_cance
               VALUES
                  (p_empresa,
                   v_fecha_ant,
                   v_ccmayor,
                   v_ccsub,
                   v_ccsubsub,
                   v_ccssubsub,
                   v_ccsssubsub,
                   v_sector,
                   v_ciudad,
                   v_sucursal,
                   lv_moneda,
                   " ",
                   lv_sdo_fin_de_dia,
                   wsdo_fin_de_dia,
                   0,
                   0);
            END IF;
         END IF;
      ELSE
         IF (lv_sdo_fin_de_dia > 0) THEN
            IF (v_sucursal IS NOT NULL) THEN
               LET lv_nat_movto = "C";
               INSERT INTO
                  co_cance
               VALUES
                  (p_empresa,
                   v_fecha_ant,
                   v_ccmayor,
                   v_ccsub,
                   v_ccsubsub,
                   v_ccssubsub,
                   v_ccsssubsub,
                   v_sector,
                   v_ciudad,
                   v_sucursal,
                   lv_moneda,
                   " ",
                   lv_sdo_fin_de_dia,
                   lv_sdo_fin_de_dia,
                   0,
                   0);

            END IF ;
         ELSE
            IF (v_sucursal IS NOT NULL) THEN
               LET lv_nat_movto = "D";
               LET wsdo_fin_de_dia = lv_sdo_fin_de_dia * -1;
               INSERT INTO
                  co_cance
               VALUES
                  (p_empresa,
                   v_fecha_ant,
                   v_ccmayor,
                   v_ccsub,
                   v_ccsubsub,
                   v_ccssubsub,
                   v_ccsssubsub,
                   v_sector,
                   v_ciudad,
                   v_sucursal,
                   lv_moneda,
                   " ",
                   lv_sdo_fin_de_dia,
                   0,
                   wsdo_fin_de_dia,
                   0);
            END IF;
         END IF;
      END IF;
   END FOREACH;
   RETURN codret;

END PROCEDURE
DOCUMENT
" Subrutina para la cencelacion de resultados, es llamada por el SPL",
" Cancela_Resultados                                                ",
" AUTOR : Raul Mendoza D'nes",
" Fecha : 18/Agosto/2001",
" Ver.  : 1.0 ",
" Mod.  : ",
" BD.   : bdicont",
"Llamado por : Cancela_Resultados",
"Param  : empresa";

CREATE PROCEDURE "informix".sp_actualiza_fechas_incidencia()

RETURNING
          CHAR (5) ,
	  CHAR(20) ,
          INTEGER  ;

--##############################################################################
--## Procedimiento       : sp_actualiza_fechas_incidencia
--## Version             : 1.0.0
--## Objetivo            : Actualiza los registros que tienen fecha 2010-12-08 a 2010-08-12
--## Base Datos          : bicont
--## Supuestos           :
--## Valores Retorno     : CodRet -->   Código de Retorno.
--##                       Desc   -->   Descricpion del Error
--##                       Registros->  Cantidad de Registros
--## Creado por          : Fermin Ramos
--## Fecha creacion      : Agosto de 2010
--##############################################################################


    DEFINE cod_ret                char(5);
    DEFINE iSqlErr                integer;

    DEFINE cCodErr                CHAR(5);
    DEFINE vDesErr                VARCHAR(60);

    DEFINE cursor_actfecha        INTEGER;

    DEFINE vsecuencia	          INTEGER;

    DEFINE vsFlagEnTransaccion    CHAR (1);

    --Variables de retorno
    DEFINE v_registros            INTEGER;

    ON EXCEPTION
        SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cod_ret = iSqlErr;
        END IF;
        RETURN cod_ret, vDesErr, NULL;

    END EXCEPTION;

        --	SET debug file TO "/tmp/sp_actualiza_fechas_incidencia.out";
	--	TRACE ON;

    LET cod_ret = "000";
    LET vDesErr = "";
    LET v_registros = 0;
    --LET vnumsecuencia = 1;
    LET vsFlagEnTransaccion = 'F';

    --// ********************************************************************
    --// Obtiene Registros de la tabla bdicont:co_detpol
    --// ********************************************************************



	SET ISOLATION TO DIRTY READ;
		FOREACH WITH HOLD
-- control_poliza, fecha_captura, empresa, sucursal, naturaleza
		select {INDEX (bdicont:co_detpol 386_2288 ) } secuencia
			into vsecuencia
			from co_detpol
			where
			fecha_captura = '12082010'
			and empresa = '001'
			and control_poliza = '169075'
			and usuario = 'chqinfor'

		--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION:
		IF (vsFlagEnTransaccion = 'F') THEN
			BEGIN WORK;
				LET vsFlagEnTransaccion = 'V';
		END IF;

		UPDATE {INDEX (bdicont:co_detpol 386_2288 ) } co_detpol
		SET
			fecha_captura = '08162010',
			fecha_valida = '08122010',
			usuario = '92536921'
			where
			fecha_captura = '12082010'
			and empresa = '001'
			and control_poliza = '169075'
			and usuario = 'chqinfor'
			and secuencia = vsecuencia;

			IF (v_registros = 1000) THEN --	VERIFICA SI ALCANZO EL MAXIMO DE TRANSACCIONES POR BLOQUE.
				COMMIT WORK;
				LET vsFlagEnTransaccion = 'F';
				LET v_registros = 0;
				CONTINUE FOREACH;
			END IF;
		LET v_registros = v_registros + 1;
	END FOREACH;

	-- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE:
	IF ((v_registros > 0) OR (vsFlagEnTransaccion = 'V')) THEN -- VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE.
		COMMIT WORK;
		LET vsFlagEnTransaccion = 'F';
	END IF;

	RETURN cod_ret, vDesErr, v_registros;

END PROCEDURE;