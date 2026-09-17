CREATE PROCEDURE "informix".sp_domi_procesarch_hilo4()
 returning CHAR(5) AS Codigo_Respuesta,CHAR (100) AS Mensaje_Respuesta;

	DEFINE	v_cod_ret CHAR(5);
	DEFINE	sql_err INTEGER;
	DEFINE v_cRespSP  CHAR(5);
	DEFINE v_dFechaSp DATE;
	DEFINE v_sRetCodSP CHAR(5);
	DEFINE v_nombre_arch30 CHAR(20);
    DEFINE vsFecha_Presentacion CHAR(8);
	DEFINE vsNomArchivo31 CHAR (20);
    DEFINE vsNomArchivo32 CHAR (20);
	DEFINE valor1 INTEGER;
	DEFINE valor2 INTEGER;
	DEFINE v_user_insert CHAR(9);
	DEFINE v_fecha_insert DATE;
	DEFINE vsMensaje_Respuesta CHAR (100);
	

	LET v_cod_ret = '00000';
	LET v_cRespSP = "";
	LET v_sRetCodSP = "";
	LET v_nombre_arch30 = "";
	LET vsFecha_Presentacion = "";
    LET vsNomArchivo31 = "";
	LET vsNomArchivo32 = "";
	LET valor1 = 0;
	LET valor2 = 0;
	LET v_user_insert = "";
	LET v_fecha_insert = "";
	LET vsMensaje_Respuesta = '';
	
	BEGIN
		ON EXCEPTION SET sql_err
		    if sql_err <> 0 then
				let v_cod_ret = sql_err;
				LET vsMensaje_Respuesta = 'ERROR NO CONTROLADO';
				RETURN v_cod_ret,vsMensaje_Respuesta;
		    end if;
		END EXCEPTION;
		
		SELECT FIRST 1 nombre_arch30,fecha_presentacion,nombre_arch31,nombre_arch32,rango1,rango2,user_insert,fecha_insert INTO v_nombre_arch30,vsFecha_Presentacion,vsNomArchivo31,vsNomArchivo32,valor1,valor2,v_user_insert,v_fecha_insert FROM bdidomi:dom_cce_control_hilos WHERE nombre_procesarch=TRIM('sp_domi_procesararch30_4');
		
		EXECUTE PROCEDURE "informix".sp_domi_procesararch30_3(TRIM(v_nombre_arch30),TRIM(vsNomArchivo31),TRIM(vsNomArchivo32),TRIM(v_user_insert),valor1,valor2,7000000) INTO v_cod_ret;
		
		IF (v_cod_ret = '00000') THEN
			LET vsMensaje_Respuesta = 'GENERAL PROCESO EXITOSO';
		ELSE
			LET vsMensaje_Respuesta = 'ERROR EN PROCESO';
		END IF;
		
		RETURN v_cod_ret,vsMensaje_Respuesta;
	END;
END PROCEDURE;