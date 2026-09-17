CREATE PROCEDURE "informix".sp_domi_moverarchivos(psNomArchivo CHAR(20),pRutaInicio CHAR(2), pRutaFin CHAR(2))
	returning char(5);

	DEFINE	v_cod_ret CHAR(5);
	DEFINE	sql_err INTEGER;
	DEFINE 	v_RutaInicio CHAR(50);
	DEFINE 	v_RutaFin CHAR(50);
	DEFINE 	v_sSQL CHAR(120);

	LET v_cod_ret = '00000';
	LET v_sSQL = "";
	
	--SET debug FILE TO "/home/sysdomi/traceSp_Domi_MoverArchivos.out";
    --Trace ON;
	BEGIN
		on exception set sql_err
		    if sql_err <> 0 then
				let v_cod_ret = sql_err;
				return v_cod_ret;
		    end if;
		end exception;

		--se obtienen los parametros de rutas
		SELECT valor INTO v_RutaInicio FROM bdidomi:dom_parametros WHERE cod_param = pRutaInicio;
		SELECT valor INTO v_RutaFin FROM bdidomi:dom_parametros WHERE cod_param = pRutaFin;
		
		LET v_sSQL  = 'cp' || ' ' || TRIM(v_RutaInicio) || TRIM(psNomArchivo) || ' ' || TRIM(v_RutaFin) || TRIM(psNomArchivo);
		SYSTEM v_sSQL;

		LET v_sSQL  = 'chmod 666 ' || ' ' || TRIM(v_RutaFin) || TRIM( psNomArchivo);
        SYSTEM v_sSQL;		

		LET v_sSQL  = 'rm -f ' || ' ' || TRIM(v_RutaInicio) || TRIM(psNomArchivo);
		SYSTEM v_sSQL;

		--LET v_sSQL  = 'chmod 666 ' || ' ' || TRIM(v_RutaFin) || TRIM(psNomArchivo);
		return v_cod_ret;
	END;

END PROCEDURE;