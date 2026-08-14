CREATE PROCEDURE "informix".insertarcointegracion(p_cempresa CHAR(3), p_ccosto_orig CHAR(4), p_cusuario CHAR(8), p_cfecha_captura DATE,
			p_ccuenta CHAR(4), p_csubcta CHAR(2), p_csubsubcta CHAR(2), p_cssubsubcta CHAR(2), p_csssubsubcta CHAR(2), p_csector CHAR(2),
			p_cregional CHAR(3), p_csucursal CHAR(4), p_cnro_auxiliar CHAR(12), p_cfecha DATE, p_cmoneda CHAR(2), p_cnaturaleza CHAR(1),
			p_mimporte MONEY(18,2), p_cconcepto CHAR(80), p_cusuario_int CHAR(8))

    RETURNING CHAR(6);

    DEFINE     sql_err                  INTEGER;
    DEFINE     isam_err                 INTEGER;
    DEFINE     error_info               CHAR(40);
    DEFINE     cod_ret                  CHAR(6);

    SET LOCK MODE TO WAIT 10;

    BEGIN

        ON EXCEPTION SET sql_err, isam_err, error_info
            LET cod_ret = sql_err;
            SET DEBUG FILE TO "ErrPoliza.err";
            TRACE sql_err||" * "||isam_err|| " * "||error_info;
            RETURN cod_ret;
        END EXCEPTION;

        --*****************************************************************
        --Creado por Vladimir Félix Gálvez 15/May/2009       			--*
        --Debug del Procedure                                			--*
        --SET DEBUG FILE TO "/tmp/subir/insertarcointegracion.out";       --*
        --TRACE ON;                                                   --*
        --*****************************************************************

		--VALIDAR LOS PARAMETROS DE ENTRADA
		IF p_cempresa = '' OR p_ccosto_orig = '' OR p_cusuario = '' OR  p_cfecha_captura = '' THEN
			LET cod_ret = '001';
		END IF;

		IF p_ccuenta = '' OR p_csubcta = '' OR p_csubsubcta = '' OR  p_cssubsubcta = '' THEN
			LET cod_ret = '001';
		END IF;

		IF p_csssubsubcta = '' OR p_csector = '' OR p_cregional = '' OR  p_csucursal = '' THEN
			LET cod_ret = '001';
		END IF;

		IF p_cfecha = '' OR p_cmoneda = '' OR  p_cnaturaleza = '' THEN
			LET cod_ret = '001';
		END IF;

		IF (p_mimporte = '' OR p_mimporte IS NULL) OR (p_cusuario_int = '' OR p_cusuario_int IS NULL) THEN
			LET cod_ret = '001';
		END IF;

        LET cod_ret = "999";

			INSERT INTO bdicont:co_integracion (empresa,ccosto_orig,usuario,fecha_captura,cuenta,subcta,subsubcta,ssubsubcta,
			sssubsubcta,sector,regional,sucursal,nro_auxiliar,fecha,moneda,naturaleza,importe,concepto,usuario_int)
			VALUES (p_cempresa, p_ccosto_orig, p_cusuario, p_cfecha_captura, p_ccuenta, p_csubcta,p_csubsubcta, p_cssubsubcta,
			p_csssubsubcta, p_csector, p_cregional, p_csucursal, p_cnro_auxiliar, p_cfecha, p_cmoneda,p_cnaturaleza, p_mimporte,
			p_cconcepto, p_cusuario_int);

			LET cod_ret = "000";

		RETURN cod_ret;
    END
END PROCEDURE;