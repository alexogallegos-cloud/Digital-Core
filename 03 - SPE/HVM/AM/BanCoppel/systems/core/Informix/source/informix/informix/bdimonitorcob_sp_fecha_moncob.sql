CREATE PROCEDURE "informix".sp_fecha_moncob(v_anio INTEGER, v_mes INTEGER, p_origen INTEGER)
       RETURNING DATE, DATE, CHAR(8);

DEFINE sql_err            INTEGER;
DEFINE isam_err           INTEGER;
DEFINE error_info         CHAR(150);
DEFINE cMensaje           CHAR(150);
DEFINE cCod_ret           CHAR(6);
DEFINE vfch_inicio        DATE;
DEFINE vfch_fin           DATE;
DEFINE p_anio             INTEGER;
DEFINE p_mes              INTEGER;
DEFINE vmes_ejecut        CHAR(8);
DEFINE v_fecha_inicial    CHAR(10);
DEFINE d                  DATE;

--SET DEBUG FILE TO '/home/syscobra/cat/envios/sp_fecha_moncob.out';
--TRACE ON;

    LET cCod_ret    = '000000';
	LET sql_err     = 0;
	LET isam_err    = 0;
	LET error_info  = '';
	LET cMensaje    = 'PROCESO EXITOSO';
    LET vfch_fin    = '';
    LET vfch_inicio = '';
    LET vmes_ejecut = '';
         
  BEGIN
    ON EXCEPTION SET sql_err, isam_err, error_info
	  LET cCod_ret = sql_err;
	  LET cMensaje = error_info;
      RETURN vfch_inicio, vfch_fin, vmes_ejecut;
  END EXCEPTION;


  IF p_origen = 1 THEN
        
        IF  v_mes = 1 THEN

            LET v_mes= 12;
            LET v_anio = v_anio - 1;
            LET vfch_inicio =   v_mes || '-' || '21' || '-' || v_anio ;         ------CAMBIOS
            LET d = DATE(vfch_inicio);

        ELSE

           LET vfch_inicio =   v_mes - 1 || '-' || '21' || '-' || v_anio ;         ------CAMBIOS
           LET d = DATE(vfch_inicio);
           
        END IF;

  ELSE

        SELECT pri_dia_mes INTO vfch_inicio FROM bdinteg:si_fechas;
        LET vfch_inicio = vfch_inicio - 2 UNITS MONTH;
        LET vfch_inicio = vfch_inicio + 20 units day;

  END IF;


  CALL    bdicred:monthadd(vfch_inicio, 1)
  RETURNING vfch_fin;

  LET vfch_fin    = vfch_fin - 1 UNITS DAY;
  LET p_anio      = year  (vfch_fin);
  LET p_mes       = month (vfch_fin);
  LET vmes_ejecut = p_mes || '-' || p_anio;
                    
    RETURN vfch_inicio, vfch_fin, vmes_ejecut;

	END;
END PROCEDURE;