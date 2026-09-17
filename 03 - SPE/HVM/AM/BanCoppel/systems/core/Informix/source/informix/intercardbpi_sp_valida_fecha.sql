create procedure "informix".sp_valida_fecha(p_cFecha CHAR(8))
 returning char(5);
	--Elaboró: Alejandro Osuna Iza
	--Actividad: Valida que la fecha sea la correcta
	--Solicito: Hector Casanova
	--Fecha: 14 de julio de 2009

	DEFINE	v_cod_ret CHAR(5);
	DEFINE	sql_err INTEGER;
	DEFINE v_cRespSP  CHAR(5);
	DEFINE v_dFechaSp DATE;
	DEFINE v_sRetCodSP CHAR(5);
	DEFINE v_dFechaReSp DATE;
	DEFINE v_fecha_dia CHAR(2);
	DEFINE v_fecha_mes CHAR(2);
	DEFINE v_fecha_ano CHAR(4);
	DEFINE v_fecha_dia_len integer;
	DEFINE v_fecha_mes_len integer;
	DEFINE v_fecha_ano_len integer;

	LET v_cod_ret = '00000';
	LET v_cRespSP = "";
	LET v_sRetCodSP = "";
	LET v_fecha_dia = "";
	LET v_fecha_mes = "";
	LET v_fecha_ano = "";

	--Se valida la fecha de presentacion
	--primero se valida que sea numerico la cadena
	begin
		on exception set sql_err
		    if sql_err <> 0 then
				let v_cod_ret = sql_err;
				IF v_cod_ret = -1218 THEN
					let v_cod_ret = '00001';
					return v_cod_ret;
				END IF;
				return v_cod_ret;
		    end if;
		end exception;

--SET DEBUG FILE TO "/tmp/sp_valida_fecha.out";
	--    TRACE ON;
		execute PROCEDURE intercard:sp_valida_cadena(p_cFecha,'N') INTO v_cRespSP;
		IF v_cRespSP <> "00000" THEN
			LET v_cod_ret = "00001";
			return v_cod_ret;
		ELSE

			LET v_fecha_dia  = (Substr(p_cFecha,7,2));
			LET v_fecha_dia_len = LENGTH(v_fecha_dia);
			IF v_fecha_dia_len <> 2 THEN
				LET v_cod_ret = "00001";
				return v_cod_ret;
			END IF;
			LET v_fecha_dia = v_fecha_dia::integer;

			LET v_fecha_mes  = (Substr(p_cFecha,5,2));
			LET v_fecha_mes_len = LENGTH(v_fecha_mes);
			IF v_fecha_mes_len <> 2 THEN
				LET v_cod_ret = "00001";
				return v_cod_ret;
			END IF;
			LET v_fecha_mes = v_fecha_mes::integer;

			LET v_fecha_ano  = (Substr(p_cFecha,1,4));
			LET v_fecha_ano_len = LENGTH(v_fecha_ano);
			IF v_fecha_ano_len <> 4 THEN
				LET v_cod_ret = "00001";
				return v_cod_ret;
			END IF;
			LET v_fecha_ano = v_fecha_ano::integer;


			--Se valida que el dia sea correcto
			IF  (v_fecha_dia < 1) OR (v_fecha_dia > 31) THEN
				LET v_cod_ret = "00001";
				return v_cod_ret;
			END IF;
			--Se valida que el mes sea correcto
			IF  (v_fecha_mes < 1) OR (v_fecha_mes > 12) THEN
				LET v_cod_ret = "00001";
				return v_cod_ret;
			END IF;
			--Se valida que el ano sea correcto
			IF  (v_fecha_ano < 1900) OR (v_fecha_ano > 2900) THEN
				LET v_cod_ret = "00001";
				return v_cod_ret;
			END IF;
			---se valida qyue la fecha sea una fecha habil
			LET v_dFechaSp = Substr(p_cFecha,5,2) || "/" || Substr(p_cFecha,7,2) || "/" || Substr(p_cFecha,1,4);
			--se valida que la fecha no sea un dia inabil
			--EXECUTE FUNCTION bdinteg:splvalfecha('001', v_dFechaSp, 0 ) INTO v_sRetCodSP,v_dFechaReSp;
			--Se valida que la fecha de proceso sea igual fehca habil
			--IF NOT v_dFechaSp = v_dFechaReSp THEN
			--	LET v_cod_ret = "00002";
			--	return v_cod_ret;
			--END IF;
		END IF;
		return v_cod_ret;
	END;
END PROCEDURE;