CREATE PROCEDURE "informix".sp_domi_nombrearchi(pFechaHoy char(8), pCodigo CHAR(2))
	RETURNING CHAR(20); --regresa el nombre del archivo a procesar
	
	--DEfinicion de variables
	DEFINE v_cod_ret CHAR(20);
	DEFINE iSqlErr INTEGER;
	DEFINE v_nombre CHAR(15);
	DEFINE v_contador integer;
		DEFINE v_like CHAR(1);
	DEFINE v_consulta CHAR(18);
	DEFINE v_comilla CHAR(1);
	DEFINE v_Dia char(2);
	DEFINE v_mes CHAR(2);
	define v_ano CHAR(4);
	DEFINE vsCodRetorno CHAR(5);
	DEFINE v_sRetCodSP CHAR(5);
	DEFINE v_dFechaReSp date;
	DEFINE v_dFechaSp DATE;
	
	--Inicilizacion de variables
	LET v_cod_ret = "";
	LET v_nombre = "";
	LET v_like = "%";
	LET v_consulta = "";
	LET v_comilla = "'";
	LET v_Dia = "";
	LET v_mes = "";
	LET v_ano = "";
	LET vsCodRetorno = "";
	LET v_sRetCodSP  = "";
	
	
	
	--SET DEBUG FILE TO "/tmp/sp_domi_nombreArchi.out";
	--TRACE ON;
	BEGIN
		ON EXCEPTION
	        SET iSqlErr
	        IF iSqlErr <> 0 THEN
	            LET v_cod_ret = iSqlErr;
	        END IF;
			
			RETURN v_cod_ret;
		END EXCEPTION;
		--se valida qyue la fecha sea una fecha habil
		WHILE v_sRetCodSP <> '000'
			LET v_dFechaSp = substr(pFechaHoy,3,2)|| "/" || substr(pFechaHoy,1,2) || "/" ||  substr(pFechaHoy,5,4);
			--se valida que la fecha no sea un dia inabil
			IF pCodigo = "34" THEN 
				LET v_dFechaSp = v_dFechaSp + 1;
			END IF;
			EXECUTE FUNCTION bdinteg:splvalfecha('001',v_dFechaSp, 0 ) INTO v_sRetCodSP,v_dFechaReSp;
			IF v_sRetCodSP <> '000' then
				LET v_dFechaReSp = v_dFechaReSp + 1;
				let pFechaHoy = LPAD (DAY(v_dFechaReSp), 2, '0') || LPAD (MONTH(v_dFechaReSp), 2, '0') || LPAD (YEAR(v_dFechaReSp), 4, '0');
			end if;
			LET pFechaHoy =  LPAD (DAY(v_dFechaReSp), 2, '0') || LPAD (MONTH(v_dFechaReSp), 2, '0') || LPAD (YEAR(v_dFechaReSp), 4, '0');
		END WHILE;	

		
		LET v_Dia = substr(pFechaHoy,1,2);
		LET v_mes = substr(pFechaHoy,3,2);
		LET v_ano	= substr(pFechaHoy,5,4);
		LET v_nombre = "E" || "137" || v_Dia || v_mes || v_ano || "." || pCodigo;
		LET v_nombre = TRIM(v_nombre);
		--LET v_consulta = v_comilla || v_nombre || v_like || v_comilla;
		
		SELECT COUNT(nombre_arch) INTO v_contador 
		FROM bdidomi:dom_cce_archivos 
		WHERE substring (nombre_arch from 1 for 15) = v_nombre;
		IF v_contador = 0 THEN
			LET v_cod_ret =  trim(v_nombre) || '01';
		ELSE
			LET v_contador = v_contador + 1;
			LET v_cod_ret = trim(v_nombre) ||  lpad(TRIM((v_contador::integer)::char(2)),2,'0');
			--LET v_cod_ret =  trim(v_nombre) || LPAD ((v_contador + 1 ), 2, '0');
		END IF;	
		RETURN v_cod_ret;
	END;	
	
END PROCEDURE;