CREATE PROCEDURE "informix".sp_importa_catcentrosimp()
--EXECUTE PROCEDURE sp_importa_catcentrosimp();
RETURNING CHAR(6), CHAR(80);

-- Declaracion de variables
DEFINE sql_err 			        INTEGER;
DEFINE isam_err 		        INTEGER;
DEFINE error_info		        CHAR(80);
DEFINE cCod_ret                 CHAR(6);
DEFINE cMensaje                 CHAR(80);

DEFINE v_sql                  	CHAR(500);
DEFINE vRuta                    CHAR(60);
DEFINE vFecha					CHAR(06);
DEFINE cNombreArch				CHAR(50);
DEFINE totalCI					INTEGER;

LET sql_err   = 0;
LET cCod_ret  = '00000';
LET cMensaje  = 'Proceso Exitoso';
LET v_sql     = '';
LET vRuta     = ''; -- '/resplogifx/archivoscartera/'
LET vFecha	  = '';
LET cNombreArch = 'centros_impresion_coppel';
LET totalCI		= 0;

--SET DEBUG FILE TO '/informix/ulises/edc/Cat_CI/sp_importarcataloci.out';
--TRACE ON;

BEGIN
  
        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
            LET cMensaje = error_info;
			RETURN cCod_ret, cMensaje;
	    END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- Recupera la fecha con la que se va a generar el archivo
		SELECT LPAD(MONTH(fecha_hoy),2,0)||YEAR(fecha_hoy)
		INTO vFecha
		FROM bdicred:sd_fechas
		WHERE empresa = '001';
		
		--LET vFecha = '09'||'2021'; --para pruebas
		
		-- Obtiene la ruta donde se realiza la descarga del archivo.
		SELECT TRIM(valor) INTO vRuta FROM sd_param WHERE empresa = '001' AND cod_param = '033';
		
		--LET vRuta = '/informix/ulises/RQI/25_183/OLTP/'; -- PARA PRUEBAS
		
		IF trim(vRuta) = "" THEN
			LET cCod_ret= '00001';
			LET cMensaje= 'No existe la ruta /resplogifx/archivoscartera/';
			RETURN cCod_ret, cMensaje;
		END IF;
		
		-- Realiza validacion de que la tabla exista
		IF EXISTS(SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'sd_centrosimpresion_coppel'  AND dbsname = 'bdicred') THEN
                    truncate table bdicred:"informix".sd_centrosimpresion_coppel; -- borra la informacion de la tabla.
		else
				LET cCod_ret= '00002';
				LET cMensaje= 'No existe la tabla sd_centrosimpresion_coppel ';
				RETURN cCod_ret, cMensaje;
		END IF;	
		
/*		SELECT COUNT(*) INTO totalCI FROM "informix".sd_centrosimpresion_coppel;
			
		IF  totalCI > 0 THEN
			truncate table bdicred:"informix".sd_centrosimpresion_coppel;
		END IF;
*/			
		-- Realiza la insercion de los datos del archivo a la tabla bdicred:sd_centrosimpresion_coppel
		LET v_sql = '';	
		LET v_sql ='gunzip '||trim(vRuta) ||'centros_impr_coppel'|| trim(vFecha)||'.txt.gz';
		system v_sql;	
		
		LET v_sql = '';	
		LET v_sql ="sed 's/.$//g' "||trim(vRuta) ||'centros_impr_coppel' ||trim(vFecha)|| '.txt > ' ||trim(vRuta) ||TRIM(cNombreArch)||trim(vFecha)||'.unl';
		system v_sql;
		
		LET v_sql = '';		
		LET v_sql = ' echo "FILE '|| trim(vRuta) ||TRIM(cNombreArch)||trim(vFecha)||'.unl DELIMITER '''||'|'||''' 3; INSERT INTO "informix".sd_centrosimpresion_coppel; " > '|| trim(vRuta) ||'queryCargaCentroImpr.sql';
		system v_sql;							

		LET v_sql = '';	
		LET v_sql = 'dbload -d bdicred -c '|| trim(vRuta) ||'queryCargaCentroImpr.sql -l '|| trim(vRuta) ||'sd_centrosimpresion_coppel.log -n 1000 -k';
		system v_sql;
		
		LET v_sql = '';
		LET v_sql = 'gzip ' ||trim(vRuta) ||'centros_impr_coppel'|| trim(vFecha)||'.txt';
		system v_sql;
		
		LET v_sql = '';
		LET v_sql = 'rm ' || TRIM(vRuta) || 'sd_centrosimpresion_coppel.log';
		system v_sql;
		
		LET v_sql = '';
		LET v_sql = 'rm ' || TRIM(vRuta) || 'queryCargaCentroImpr.sql';
		system v_sql;
		
		LET v_sql = '';
		LET v_sql = 'rm ' || TRIM(vRuta) || TRIM(cNombreArch)||trim(vFecha)||'.unl';
		system v_sql;
		
RETURN cCod_ret, cMensaje;

END;
END PROCEDURE;