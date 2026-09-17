CREATE PROCEDURE "informix".sp_validarcta(p_empresa CHAR(3), p_smoneda CHAR(2), p_cuentamayor CHAR(4),
							p_ccsub CHAR(2), p_ccsubsub CHAR(2), p_ccssubsub CHAR(2),p_ccsssubsub CHAR(2),
							p_sector CHAR(2), p_usuario CHAR(8))

	RETURNING CHAR(6);

	--DEFINICIÓN DE VARIABLES
	--Variables de control de errores y de retorno.
	DEFINE sql_err                  INTEGER;
	DEFINE isam_err                 INTEGER;
	DEFINE error_info               CHAR(100);
	DEFINE cod_ret                  CHAR(6);

	--Variables de la cuenta de enlace
	DEFINE v_cuentacontable			CHAR(14);
	DEFINE v_cuentaenlace			CHAR(14);
	DEFINE v_ccmayorenl				CHAR(4);
	DEFINE v_ccsenl					CHAR(2);
	DEFINE v_ccssenl				CHAR(2);
	DEFINE v_ccsssenl				CHAR(2);
	DEFINE v_ccssssenl				CHAR(2);
	DEFINE v_ccsectorenl			CHAR(2);

	--Variables de control de la cuenta contable.
	DEFINE v_ccosto_orig            CHAR(4);
	DEFINE v_cta_restringida_orig	CHAR(1);
	DEFINE v_contadorcuenta			INTEGER;

	BEGIN

		--Manejador de errores de Informix
		ON EXCEPTION SET sql_err, isam_err, error_info
			LET cod_ret = sql_err;
			SET DEBUG FILE TO "ErrPoliza.err";
			TRACE sql_err||" * "||isam_err|| " * "||error_info;
			RETURN cod_ret;
		END EXCEPTION;

		--*********************************************************************
		--Creado por:			Vladimir Félix Gálvez						--*
		--Fecha de Creación:	03/Jun/2009       							--*
		--Descripción: Serie de Validaciones de la cuenta contable.			--*
		--*Valida que la Cuenta Contable sea Distinta a la Cuenta de Enlace	--*
		--*Valida que la Cuenta Contable exista.							--*
		--*Verifica si esta restringida en su centro de origen y sí esta	--*
		--*restringida verifica que este permitida para el centro de 		--*
		--*costos del usuario.												--*
		--DEBUG DEL PROCEDURE                                				--*
		--SET DEBUG FILE TO "/tmp/subir/validarcuentacontable.out";   		--*
		--TRACE ON;                                          				--*
		--Modificacion: Se cambió la firma del SP, de validarcuentacontable a --*
		--                    sp_validarcta
		--Modificó:       César Andrés De Anda Alcántara --*
		--Fecha:           17/06/2009
		--*********************************************************************

		---INICIALIZACION DE VARIABLES
        LET cod_ret                 = "000";
        LET error_info              = "";
        LET isam_err                = 0;
        LET sql_err                 = 0;
		LET v_contadorcuenta		= 0;
		LET v_ccmayorenl 			= "";
		LET v_ccsenl 				= "";
		LET v_ccssenl 				= "";
		LET v_ccsssenl 				= "";
		LET v_ccssssenl				= "";
		LET v_ccsectorenl			= "";
		LET v_ccosto_orig			= "";
		LET v_cta_restringida_orig	= "";
		--Concatena la Cuenta Contable
		LET v_cuentacontable        = p_cuentamayor||p_ccsub||p_ccsubsub||p_ccssubsub||p_ccsssubsub||p_sector;

		--Obtener la Cuenta de Enlance
		SELECT enl_cc_mayor,enl_cc_sub,enl_cc_ss,enl_cc_sss,enl_cc_ssss,enl_cc_sector
		INTO   v_ccmayorenl, v_ccsenl, v_ccssenl, v_ccsssenl, v_ccssssenl, v_ccsectorenl
		FROM   bdicont:co_param
		WHERE  empresa = p_empresa;

		--Concatena la Cuenta de Enlance
		LET v_cuentaenlace			= v_ccmayorenl||v_ccsenl||v_ccssenl||v_ccsssenl||v_ccssssenl||v_ccsectorenl;

		--Verifica que la Cuenta Contable sea Distinta a la Cuenta de Enlace
		IF v_cuentaenlace <> v_cuentacontable THEN

			--Obtencion del Centro de Costos del Usuario
			SELECT sucursal
			INTO   v_ccosto_orig
			FROM   bdinteg:si_ejecut
			WHERE  empresa = p_empresa
			AND    ejecutivo = p_usuario;

			--Obtener si existe la Cuenta Contable y si existe Obtener si la Cuenta Contable esta restringida.
			SELECT COUNT(*), cta_restringida_orig
			INTO   v_contadorcuenta, v_cta_restringida_orig
			FROM bdinteg:si_catalog
			WHERE empresa   = p_empresa
			AND (moneda = '3' OR moneda = p_smoneda)
			AND cancelacion = 'N'
			AND tipo_cuenta = 'D'
			AND ccmayor     = p_cuentamayor
			AND ccsub       = p_ccsub
			AND ccsubsub    = p_ccsubsub
			AND ccssubsub   = p_ccssubsub
			AND ccsssubsub  = p_ccsssubsub
			AND sector      = p_sector
			GROUP BY cta_restringida_orig;

			--Verificar si la cuenta Contable existe
			IF v_contadorcuenta > 0 THEN

				--Verificar que la Cuenta Contable no esta restringida
				IF v_cta_restringida_orig = 'S' THEN

					--Verificar si la Cuenta Contable esta permitida para el centro de costos del usuario.
					IF EXISTS(SELECT empresa FROM bdicont:co_cta_ccorig WHERE empresa = p_empresa AND ccmayor = p_cuentamayor
							  AND ccsub = p_ccsub AND ccsubsub = p_ccsubsub AND ccssubsub = p_ccssubsub
							  AND ccsssubsub = p_ccsssubsub AND sector = p_sector AND sucursal = v_ccosto_orig) THEN

						LET cod_ret = "000";
					ELSE

						LET cod_ret = "002";
					END IF;
				END IF;
			ELSE

				LET cod_ret = "001";
			END IF;
		ELSE

			LET cod_ret = "003";
		END IF;

		RETURN cod_ret;

	END;
END PROCEDURE;