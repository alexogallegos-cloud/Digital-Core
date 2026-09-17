CREATE PROCEDURE "informix".sp_carga_resultado_cat( pNomArch CHAR(30))
RETURNING CHAR(6), CHAR(80);

--Declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			                INTEGER;
DEFINE isam_err 		                INTEGER;
DEFINE error_info		                CHAR(80);
DEFINE cCod_ret                     CHAR(6);
DEFINE cMensaje                     CHAR(80);

DEFINE cCadena                      CHAR(500);
DEFINE vPath                        CHAR(50);

------------------------------------------------------------
-- Creado: Maria Elizabeth anzures
-- Fecha: 01 agosto 2011
-- Crear en BDICOBRANZA

LET cCod_ret  = '00000';
LET sql_err   = 0;
LET cMensaje  = 'Proceso Exitoso';
LET cCadena   = '';
LET vPath     = '';

      BEGIN
  
        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
          LET cMensaje = error_info;
			    RETURN cCod_ret, cMensaje;
	    END EXCEPTION;

  --SET DEBUG FILE TO "/home/informix/Elizabeth/importa.out";
  --TRACE ON;
	
            select valor_alfabetico into vPath 
            from bdicobranza:cb_param_campania
            where empresa = '001'
            and tipo_campania = 1
            and grupo_parametro = 'ARCHIVOS'
            and num_parametro = 29;

          LET cCadena = 'echo "load from ' || SUBSTR(vPath,1,LENGTH(vPath)) || SUBSTR(pNomArch,1,
		  LENGTH(pNomArch))  || ' insert into bdicobranza:cb_registro_llamadas" >' || SUBSTR(vPath,1,LENGTH(vPath)) || 'importa_llamadas.sql';
          System SUBSTR(cCadena,1,LENGTH(cCadena));
          let cCadena = 'dbaccess bdicobranza ' || SUBSTR(vPath,1,LENGTH(vPath)) || 'importa_llamadas.sql';
          System SUBSTR(cCadena,1,LENGTH(cCadena));
          let cCadena = 'rm ' || SUBSTR(vPath,1,LENGTH(vPath)) || 'importa_llamadas.sql';
          System SUBSTR(cCadena,1,LENGTH(cCadena));
		  
		  
		
  


RETURN cCod_ret, cMensaje;

END;
END PROCEDURE;