CREATE PROCEDURE "informix".respalda(pEmpresa    CHAR(3), 
                          tp_Respaldo CHAR(1))
RETURNing char(5);

   define CodRet      char(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   define v_directorio char(50);
   define v_dia        char(2);
   define v_mes        char(2);
   define v_ano        char(4);
   define v_tabla      char(20);
   define v_tablaid    integer;
   define v_colnomb    char(20);
   define v_sql        char(1000);
   define nomb_tabla   char(400);
   define v_proceso    char(10);
   define vfecha       DATE;
   define wdir         CHAR(2000);
   define v_numreg     integer;
   define v_hora_ini   datetime hour to fraction;
   DEFINE vMensaje     VARCHAR(100);

-- **************************************************************************
-- *                      CONTROL DE ERRORES                                *
-- **************************************************************************
   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "/respaldos/respalda.err";
      TRACE ON;

      LET CodRet = sql_err;
      LET wdir = wdir;
      LET v_sql = v_sql;
 
      UPDATE sd_contproc
         SET status_proc = 'C',
             hora_fin    = CURRENT,
             cod_ret     = CodRet,
             mensaje     = vMensaje
       WHERE empresa     = pEmpresa
         AND proceso     = 'RespaldoCred'
         AND fecha       = vFecha;

      UPDATE bdinteg:sx_contproc
         SET status_proc = 'C',
             hora_fin    = CURRENT,
             codret      = CodRet 
       WHERE empresa = pEmpresa
         AND proceso = 'RespaldoCred'
         AND fecha   = vFecha;

          RETURN CodRet;
 
   END EXCEPTION;


-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   LET CodRet         = "000";
   LET v_directorio    = " ";
   LET v_dia           = " ";
   LET v_mes           = " ";
   LET v_ano           = " ";
   LET v_tabla         = " ";
   LET v_tablaid       = 0;
   LET v_colnomb       = " ";
   LET v_sql           = " ";
   LET nomb_tabla      = " ";
   LET v_proceso       = "RespaldoCred";
   LET v_numreg        = 0;
   LET v_hora_ini      = current;
   LET vMensaje        = " ";
-- ***************************************************************************
-- Procesa Informacion
-- ***************************************************************************
   --SET DEBUG FILE TO "respalda.out";
   --TRACE ON;


   SELECT fecha_hoy
     INTO vFecha
     FROM sd_fechas
    WHERE empresa = pEmpresa;

   SELECT COUNT(*)
     INTO v_numreg
     FROM sd_contproc
    WHERE empresa = pEmpresa
      AND proceso = 'RespaldoCred'
      AND fecha   = vFecha;

    IF v_numreg = 0 THEN
	
      INSERT INTO sd_contproc VALUES
         (pEmpresa, 'RespaldoCred', vfecha, 'C', USER, CURRENT, CURRENT,
          CodRet, "No existe param. de ruta de respaldo");

	INSERT INTO bdinteg:sx_contproc
	 (empresa, proceso, fecha, sistema, status_proc,
        ejecutivo, hora_ini, hora_fin, codret)
	VALUES
	 (pEmpresa, 'RespaldoCred', vfecha, '06', 'C',
	  USER, CURRENT, NULL, '000');

    END IF

   SELECT valor
     INTO v_directorio
     FROM sd_param
    WHERE empresa = pempresa
      AND cod_param = '44';

   IF (v_directorio is null OR v_directorio = " ") THEN
      LET CodRet = "120";
      -- Actualiza control de procesos
     UPDATE sd_contproc
         SET status_proc = 'C',
             hora_fin    = CURRENT,
             cod_ret     = CodRet,
             mensaje     = vMensaje
       WHERE empresa     = pEmpresa
         AND proceso     = 'RespaldoCred'
         AND fecha       = vFecha;

      UPDATE bdinteg:sx_contproc
         SET status_proc = 'C',
             hora_fin    = CURRENT,
             codret      = CodRet
       WHERE empresa = pEmpresa
         AND proceso = 'RespaldoCred'
         AND fecha   = vFecha;

      RETURN CodRet;
   ELSE
      LET v_directorio = TRIM(v_directorio)||'/';
   END IF
   LET v_dia = DAY(vfecha);
   LET v_mes = MONTH(vfecha);
   LET v_ano = YEAR(vfecha);

   IF v_dia <= 9 THEN
      LET v_dia = "0" || v_dia;
   END IF

   IF v_mes <= 9 THEN
      LET v_mes = "0"||v_mes;
   END IF

   BEGIN
   ON EXCEPTION IN (-668) SET sql_err 
      SET DEBUG FILE TO TRIM(v_tabla) || " respalda.err";
      TRACE ON;
       LET CodRet = "000";
       LET wdir = wdir;
   END EXCEPTION WITH RESUME;
     --BORRA EL CONTENIDO DE LA CARPETA PARA EJEJCUTAR UN POSIBLE RESPALDO
     LET WDIR = 'rm ' || TRIM(v_directorio) || TRIM (tp_Respaldo) || TRIM(v_mes) ||
                TRIM(v_dia) || TRIM (v_ano) || '/sd_*';
     SYSTEM wdir;

     LET WDIR = 'rmdir -p ' || TRIM(v_directorio) || TRIM (tp_Respaldo) || TRIM(v_mes) ||
                TRIM(v_dia) || TRIM (v_ano);
     SYSTEM wdir;


   LET wdir = 'mkdir -p ' ||TRIM(v_directorio)||TRIM(tp_Respaldo)||TRIM(v_mes)||
              TRIM(v_dia)||TRIM(v_ano);
   SYSTEM wdir;
   END;

   SET ISOLATION TO DIRTY READ;
   FOREACH
      SELECT trim(nombre_tabla) INTO v_tabla
      FROM sd_tablas

      LET v_tabla = TRIM(v_tabla);

      SELECT tabid INTO v_tablaid
      FROM systables
      where tabname = v_tabla;

      -- Tabla no existe en la base de datos
      IF v_tablaid is null THEN
         LET CodRet = "121";
          -- Actualiza control de procesos
          INSERT INTO sd_contproc VALUES
                (pEmpresa, 'RespaldoCred', vfecha,
                'C', USER, CURRENT, CURRENT,
                 CodRet, "La Tabla no existe en la Base de Datos");

	    INSERT INTO bdinteg:sx_contproc
	       (empresa, proceso, fecha, sistema, status_proc,
              ejecutivo, hora_ini, hora_fin, codret)
	    VALUES
	       (pEmpresa, 'RespaldoCred', vfecha, '06', 'C',
	        USER, CURRENT, NULL, '000');

         RETURN CodRet;
      END IF

      LET nomb_tabla = TRIM(v_directorio)||
                       TRIM(tp_Respaldo)||TRIM(v_mes)||
                       TRIM(v_dia)||TRIM(v_ano)||'/'||
                       TRIM(v_tabla)||"."||
                       v_dia||v_mes||v_ano||
                       "a"||pempresa;

      LET nomb_tabla = TRIM(nomb_tabla);

      SELECT colname INTO v_colnomb
        FROM syscolumns
       WHERE tabid = v_tablaid
         AND colname = "empresa";

      IF v_colnomb IS NULL THEN
         LET v_sql = 'echo "             '||
              'SET ISOLATION TO DIRTY READ                   ; '||
              'UNLOAD TO ' || nomb_tabla ||' SELECT * FROM '||v_tabla ||';' ||
              '"' ||
              ' > querycred.sql';            
      ELSE
         LET v_sql = 'echo "             '||
              'SET ISOLATION TO DIRTY READ                   ; '||
              'UNLOAD TO ' || nomb_tabla ||' SELECT * FROM '||v_tabla ||';' ||
              '"' ||
              ' > querycred.sql';            
                     
      END IF

      SYSTEM v_sql;
      LET v_sql = "dbaccess bdicred querycred.sql ";
      SYSTEM v_sql;

   END FOREACH
    -- Actualiza control de procesos
   LET CodRet = TRIM(codret);
   IF CodRet = '000' THEN
        UPDATE sd_contproc 
           SET status_proc = 'F',
               hora_inicio = v_hora_ini,
               hora_fin = current,
               cod_ret  = CodRet
         WHERE proceso = 'RespaldoCred'
           AND fecha = vfecha
           AND empresa = pempresa;

        UPDATE bdinteg:sx_contproc
           SET status_proc = 'F',
               hora_fin    = CURRENT,
               codret      = CodRet
         WHERE empresa = pEmpresa
           AND proceso = 'RespaldoCred'
           AND fecha   = vFecha;

   ELSE
        UPDATE sd_contproc 
           SET status_proc = 'C',
               hora_inicio = v_hora_ini,
               hora_fin = current,
               cod_ret  = CodRet
         WHERE proceso = 'RespaldoCred'
           AND fecha = vfecha
           AND empresa = pempresa;

        UPDATE bdinteg:sx_contproc
           SET status_proc = 'C',
               hora_fin    = CURRENT,
               codret      = CodRet
         WHERE empresa = pEmpresa
           AND proceso = 'RespaldoCred'
           AND fecha   = vFecha;

   END IF;
   RETURN CodRet;
END procedure;