CREATE PROCEDURE "informix".sp_co_integracion(p_empresa CHAR(3), p_costo_orig CHAR(4), p_usuario CHAR(8), p_fecha_captura DATE,
			p_cuenta CHAR(4), p_subcta CHAR(2), p_subsubcta CHAR(2), p_ssubsubcta CHAR(2), p_sssubsubcta CHAR(2), p_sector CHAR(2),
			p_regional CHAR(3), p_costo_dest CHAR(4), p_nro_auxiliar CHAR(12), p_fecha_valida DATE, p_moneda CHAR(2), p_naturaleza CHAR(1),
			p_monto MONEY(18,2), p_descripcion CHAR(80), p_usuario_int CHAR(8) )
    RETURNING CHAR(5), VARCHAR(255)

	--Variables Exception
	DEFINE cVarDataErr							VARCHAR(64);
	DEFINE iSqlErr								INTEGER;
	DEFINE iSamErr								INTEGER;
	DEFINE cod_ret								CHAR(5);

	SET LOCK MODE TO WAIT 6;
	SET ISOLATION TO DIRTY READ;

	LET cod_ret = "000";

    BEGIN
    --Manejo del error
		ON EXCEPTION
			SET iSqlErr, iSamErr, cVarDataErr
			IF iSqlErr <> 0 THEN
				LET cod_ret=iSqlErr;
				RETURN cod_ret, iSamErr || ' ' ||cVarDataErr;
			END IF;
		END EXCEPTION;
    

		LET p_regional = '900';

		--VALIDAR LOS PARAMETROS DE ENTRADA
		IF p_empresa = '' OR p_costo_orig = '' OR p_usuario = '' OR  p_fecha_captura = '' THEN
			LET cod_ret = '175';
		END IF;

		IF p_cuenta = '' OR p_subcta = '' OR p_subsubcta = '' OR  p_ssubsubcta = '' THEN
			LET cod_ret = '175';
		END IF;

		IF p_sssubsubcta = '' OR p_sector = '' OR p_regional = '' OR  p_costo_dest = '' THEN
			LET cod_ret = '175';
		END IF;

		IF p_fecha_valida = '' OR p_moneda = '' OR  p_naturaleza = '' THEN
			LET cod_ret = '175';
		END IF;

		IF (p_monto = '' OR p_monto IS NULL OR p_monto=0) OR (p_usuario_int = '' OR p_usuario_int IS NULL) THEN
			LET cod_ret = '175';
		END IF;

		IF cod_ret = '175' THEN
	
			INSERT INTO bdicont:"informix".co_auditerr(usuario,control_poliza,fecha_captura,secuencia,
												       empresa,ccmayor,ccsub,ccsubsub,ccssubsub,
													   ccsssubsub,sector,auxiliar,cod_ret)
            VALUES (p_usuario, 0, p_fecha_captura, 0,
                    p_empresa, p_cuenta, p_subcta, p_subsubcta, p_ssubsubcta, p_sssubsubcta,p_sector,p_moneda,cod_ret);

 
			RETURN cod_ret,'CAMPO VACIO O NULO';

		END IF

		INSERT INTO bdicont:co_integracion (empresa,ccosto_orig,usuario,fecha_captura,cuenta,subcta,subsubcta,ssubsubcta,
			                                sssubsubcta,sector,regional,sucursal,nro_auxiliar,fecha,moneda,naturaleza,
										    importe,concepto,usuario_int)
		                            VALUES (p_empresa, p_costo_orig, p_usuario,p_fecha_captura, p_cuenta, p_subcta,
                                            p_subsubcta, p_ssubsubcta,p_sssubsubcta, p_sector, p_regional, p_costo_dest, 
											p_nro_auxiliar, p_fecha_valida, p_moneda,p_naturaleza, p_monto, p_descripcion, p_usuario_int);

		RETURN cod_ret,'REGISTRO INSERTADO SATISFACTORIAMENTE';

    END

END PROCEDURE;