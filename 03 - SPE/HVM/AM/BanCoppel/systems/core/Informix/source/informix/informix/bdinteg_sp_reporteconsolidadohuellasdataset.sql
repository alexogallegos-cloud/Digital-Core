CREATE PROCEDURE "informix".sp_reporteconsolidadohuellasdataset(vpMes CHAR(2), vpAnio CHAR(4))

	RETURNING CHAR(16) AS Total_Carga,  CHAR(60) AS Descripcion, INTEGER AS Match_Ambos_dedos_Cliente;

		---**********************************************************
	-- Realizo   :Alejandro Osuna
	--Solicito : Jorge Nuñez
	-- Proyecto : Reporte Consolidado de Huellas
	-- Actividad : Obtiene el total de cada tipo de operacion.
	-- Fecha     :30 de  Marzo  de 2009
	-- Modificado: Edgar Ivan Rochin Rocha 28/05/2010
		---**********************************************************

	DEFINE v_sCodRet CHAR(5);
	DEFINE sql_err Integer;
	--DEFINE v_sTotalCarga CHAR(16);
	--DEFINE viTipo1 INTEGER;
	DEFINE v_sDescripcion CHAR(60);
	DEFINE v_sCiclo CHAR(1);

	DEFINE vdFechaIni DATETIME YEAR TO FRACTION(5);
	DEFINE vdFechaFin DATETIME YEAR TO FRACTION(5);
	DEFINE viTipo INTEGER;
	DEFINE vsTotalTipo INTEGER;

	DEFINE viTipo1 INTEGER;
	DEFINE viTipo2 INTEGER;
	DEFINE viTipo3 INTEGER;
	DEFINE viTipo4 INTEGER;
	DEFINE viTipo5 INTEGER;
	DEFINE viTipo8 INTEGER;
	DEFINE viTotalCarga INTEGER;
	DEFINE viTotReg INTEGER;

	DEFINE v_sDescripcion1 CHAR (60);
	DEFINE v_sDescripcion2 CHAR (60);
	DEFINE v_sDescripcion3 CHAR (60);
	DEFINE v_sDescripcion4 CHAR (60);
	DEFINE v_sDescripcion5 CHAR (60);
	DEFINE v_sDescripcion8 CHAR (60);

	LET v_sCodRet = '00000';
	LET v_sDescripcion = '';
	LET v_sCiclo = '1';

	--LET viTipo1 = 0;
	LET vdFechaIni = CURRENT;
	LET vdFechaFin = CURRENT;
	LET viTipo = 0;
	LET vsTotalTipo = 0;

	LET viTipo1 = 0;
	LET viTipo2 = 0;
	LET viTipo3 = 0;
	LET viTipo4 = 0;
	LET viTipo5 = 0;
	LET viTipo8 = 0;
	LET viTotalCarga = 0;
	LET viTotReg = 0;

	LET v_sDescripcion1 = '1.- Cte Banco vs MaeCoppel';
	LET v_sDescripcion2 = '2.- Cte Banco vs EmpCoppel';
	LET v_sDescripcion3 = '3.- Cte Banco vs MaeBanco';
	LET v_sDescripcion4 = '4.- Cte Banco vs EmpBanco';
	LET v_sDescripcion5 = '5.- Cte Banco Comparación Directa';
	LET v_sDescripcion8 = '8.- Cte No Match';

	BEGIN
		ON EXCEPTION SET  sql_err
			IF sql_err <> 0 THEN
				let v_sCodRet =  sql_err;
			RETURN viTotalCarga, v_sDescripcion,viTipo1;
			END IF;
		END EXCEPTION;

--		SET DEBUG FILE TO "/pisa/leo/tracehuellas.sql";
--		TRACE ON;
		
		
    	let vpMes = lpad(vpMes::char(2)::integer,2,0);

		LET vdFechaIni = vpAnio || '-' || vpMes || '-01 00:00:00';
		LET vdFechaFin = vdFechaIni + INTERVAL(1) MONTH TO MONTH;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		
		
		FOREACH
			SELECT coppel.tipo, COUNT(coppel.tipo)
			INTO viTipo, viTotReg
			FROM bdinteg:si_clientecomparacioncoppel AS coppel INNER JOIN  bdinteg:si_cliente AS cliente
			ON cliente.numcte = (LPAD(TRIM(coppel.numcte::CHAR(9)),9,'0'))
			WHERE coppel.tipo IS NOT NULL
			AND coppel.numcte IS NOT NULL
			AND coppel.fechamov BETWEEN vdFechaIni AND vdFechaFin
			GROUP BY coppel.tipo
			ORDER BY coppel.tipo

			IF (viTipo = 1) THEN
				LET viTipo1 = viTotReg;
			ELIF (viTipo = 2) THEN
				LET viTipo2 = viTotReg;
			ELIF (viTipo = 3) THEN
				LET viTipo3 = viTotReg;
			ELIF (viTipo = 4) THEN
				LET viTipo4 = viTotReg;
			ELIF (viTipo = 5) THEN
				LET viTipo5 = viTotReg;
			ELIF (viTipo = 8) THEN
				LET viTipo8 = viTotReg;
			END IF;
		END FOREACH;

		LET viTotalCarga = viTipo1 + viTipo2 + viTipo3 + viTipo4 + viTipo5 + viTipo8;

		RETURN viTotalCarga, v_sDescripcion1,viTipo1 WITH RESUME;
		RETURN '', v_sDescripcion2,viTipo2 WITH RESUME;
		RETURN '', v_sDescripcion3,viTipo3 WITH RESUME;
		RETURN '', v_sDescripcion4,viTipo4 WITH RESUME;
		RETURN '', v_sDescripcion5,viTipo5 WITH RESUME;
		RETURN '', v_sDescripcion8,viTipo8 WITH RESUME;

	END;
END PROCEDURE
DOCUMENT
'Modificado: Edgar Ivan Rochin Rocha',
'Proyecto: Reporte de Huellas',
'Solicito: ',
'Descripcion: Se modifico el tipo de consulta para que la ejecucion de este procedimiento sea mas rapido.',
'Fecha: 2010/05/28',
'Version: 20100528.1640',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_depura_limites_x(p_fecha_hoy  date)

    RETURNING CHAR(5)  AS Codigo_retorno, 
              CHAR(80) AS Mensaje,
              CHAR(1)  AS Reverso,
              CHAR(25) AS StorePro;


   DEFINE p_mensaje   varchar(80);  
   DEFINE isam_err    smallint;
   DEFINE error_info  char(40);  
 

   DEFINE v_f_respeta    DATE;
   DEFINE v_f_depura     DATE;   
   DEFINE vi_valor    INTEGER;

   DEFINE v_codigo_retorno  CHAR(5);
   DEFINE v_mensaje	    CHAR(80);
   DEFINE v_reverso         CHAR(1);
   DEFINE v_store_pro       CHAR(25);
  
   DEFINE vsqlerr      INTEGER;

   DEFINE vrowid       INTEGER;     
	
	--*********************************************************--
	-- Creado por: Francisco Martinez Viveros	
	--Fecha: 07/JULIO/2010
    --Modificacion: 21/JULIO/2010
	--Objetivo: Diariamente depure la tabla si_limite_diario, 
    --de modo que conserve únicamente los últimos 15 días de información 
    --(con base en el campo f_operacion). 
	--*********************************************************--
      
   --    SET debug file TO "/tmp/depura_limite_x.out";
   --    TRACE ON;
              
            LET v_codigo_retorno = "00000";
            LET v_mensaje = "Proceso Inicio Correctamente!";
            LET v_reverso = '0';
            LET v_store_pro = 'sp_depura_limites_x';

        SET ISOLATION TO dirty READ;
        SET LOCK MODE TO wait 3;

    BEGIN
       ON EXCEPTION SET vsqlerr        
          IF vsqlerr <> 0 THEN      
               LET v_codigo_retorno = "00030";
               LET v_mensaje = "Se Genero Error de Exceptio, Verifique Datos SQL!";
               LET v_reverso = '1';
               LET v_store_pro = 'sp_depura_limites_x';              
             RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;            
          END IF;
       END EXCEPTION;


         SELECT valor
           INTO vi_valor
           FROM si_param
           WHERE empresa = '001'
             AND cod_param = '111';
            IF NOT EXISTS (SELECT valor FROM si_param WHERE empresa = '001' AND cod_param = '111')
              THEN 
                    LET vi_valor = 15;
                    LET v_codigo_retorno = "00032";
                    LET v_mensaje = "Se Genero Error en si_param, No Existe Parametro 111!";
                    LET v_reverso = '1';
                    LET v_store_pro = 'sp_depura_limites_x';                 
            END IF;   


           LET vrowid      = 0;
           LET v_f_respeta = (p_fecha_hoy - vi_valor units day);
           LET v_f_depura  = (v_f_respeta);


          IF (p_fecha_hoy is null) then
                    LET v_codigo_retorno = "00030";
                    LET v_mensaje = "Se genero error de Ejecucion, Fecha Nula!";
                    LET v_reverso = '1';
                    LET v_store_pro = 'sp_depura_limites_x';
                RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
          END IF;

          IF (p_fecha_hoy <> today) then
                    LET v_codigo_retorno = "00031";
                    LET v_mensaje = "Se genero error de Ejecucion, Diferente de Hoy!";
                    LET v_reverso = '1';
                    LET v_store_pro = 'sp_depura_limites_x';
                RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
          END IF;

 
               FOREACH cursor_borra WITH HOLD FOR
                SELECT {+index (si_limite_diario idx_limite_ope)} rowid 
                  INTO vrowid  
                  FROM bdinteg:si_limite_diario
                 WHERE f_operacion <= v_f_depura  
                

                BEGIN WORK;
                   DELETE FROM {+index (si_limite_diario idx_limite_dia)}
                     bdinteg:si_limite_diario WHERE 
                    CURRENT OF cursor_borra;                                                                             
               COMMIT WORK;
             END FOREACH;  

                IF (v_reverso <> '0') THEN
                   RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
                 END IF;                 
               
                  LET v_codigo_retorno = "00000";
                  LET v_mensaje = "Proceso de Depuracion, Termino Correctamente!";
                  LET v_reverso = '0';
                  LET v_store_pro = 'sp_depura_limites_x';                                

    END;   --begin        
  RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;

END PROCEDURE;