CREATE PROCEDURE "informix".sp_obtenersubcta(p_empresa CHAR(3), p_smoneda CHAR(2), p_cuentamayor CHAR(4), p_usuario CHAR(8))

   RETURNING CHAR(6), CHAR(100);

   DEFINE sql_err                   INTEGER;
   DEFINE isam_err                  INTEGER;
   DEFINE error_info                CHAR(100);
   DEFINE cod_ret                   CHAR(6);

   DEFINE v_cnombre					CHAR(50);
   DEFINE v_ccsub                   CHAR(2);
   DEFINE v_ccsubsub                CHAR(2);
   DEFINE v_ccssubsub               CHAR(2);
   DEFINE v_ccsssubsub              CHAR(2);
   DEFINE v_sector                  CHAR(2);
   DEFINE v_sucursal                CHAR(4);
   DEFINE v_subcuenta				CHAR(100);

   DEFINE v_ccosto_orig             CHAR(4);
   DEFINE v_cta_restringida_orig	CHAR(1);

	BEGIN

		ON EXCEPTION SET sql_err, isam_err, error_info
			LET cod_ret = sql_err;
			SET DEBUG FILE TO "ErrPoliza.err";
			TRACE sql_err||" * "||isam_err|| " * "||error_info;
            RETURN cod_ret, error_info;
		END EXCEPTION;

		--******************************************************
		--Creado por Vladimir Félix Gálvez 12/May/2009       --*
		--Debug del Procedure                                --*
		--SET DEBUG FILE TO "/tmp/subir/obtenersubcuentas.out";   --*
		--TRACE ON;                                          --*
		--Modificacion. Se cambió la gfirma del SP, de obtenersubcuentas --*
		--                    a sp_obtenersubcta
		--******************************************************

		--****************************************************************************
		--OBTENCION DE INFORMACION GENERAL PARA EL PROCESO							**
		--****************************************************************************

		---INICIALIZACION DE VARIABLES
        LET cod_ret                 = "000";
        LET error_info              = "";
        LET isam_err                = 0;
        LET sql_err                 = 0;
		LET v_cnombre				= "";
		LET v_ccsub					= "";
		LET v_ccsubsub				= "";
		LET v_ccssubsub				= "";
		LET v_ccsssubsub			= "";
		LET v_sector				= "";
		LET v_sucursal				= "";
		LET v_subcuenta				= "";
		LET v_ccosto_orig			= "";
		LET v_cta_restringida_orig	= "";

		SELECT sucursal
		INTO   v_ccosto_orig
		FROM   bdinteg:si_ejecut
		WHERE  empresa = p_empresa
		AND    ejecutivo = p_usuario;

		FOREACH
			SELECT ccsub, ccsubsub, ccssubsub, ccsssubsub, sector, nombre, cta_restringida_orig
			INTO   v_ccsub, v_ccsubsub, v_ccssubsub, v_ccsssubsub, v_sector, v_cnombre, v_cta_restringida_orig
			FROM bdinteg:si_catalog
			WHERE empresa = p_empresa AND (moneda = '3' OR moneda = p_smoneda) AND cancelacion = 'N' AND tipo_cuenta = 'D' AND ccmayor = p_cuentamayor
			GROUP BY ccsub, ccsubsub, ccssubsub, ccsssubsub, sector, cta_restringida_orig,nombre
			ORDER BY ccsub, ccsubsub, ccssubsub, ccsssubsub, sector, cta_restringida_orig,nombre

			--Verificar que la cuenta no esta restringida
			IF v_cta_restringida_orig = 'N' THEN

				LET v_subcuenta = v_ccsub||'-'||v_ccsubsub||'-'||v_ccssubsub||'-'||v_ccsssubsub||'-'||v_sector||'_'||v_cnombre;
                RETURN cod_ret, v_subcuenta WITH RESUME;

			ELSE --Cuenta restringida, Verificar si es del c.c del usuario
				IF EXISTS(SELECT empresa FROM bdicont:co_cta_ccorig WHERE empresa = p_empresa AND ccmayor = p_cuentamayor
						  AND ccsub = v_ccsub AND ccsubsub = v_ccsubsub AND ccssubsub = v_ccssubsub
						  AND ccsssubsub = v_ccsssubsub AND sector = v_sector AND sucursal = v_ccosto_orig) THEN

					LET v_subcuenta = v_ccsub||'-'||v_ccsubsub||'-'||v_ccssubsub||'-'||v_ccsssubsub||'-'||v_sector||'_'||v_cnombre;
                    RETURN cod_ret, v_subcuenta WITH RESUME;

				END IF;
			END IF;
		END FOREACH;
	END
END PROCEDURE;