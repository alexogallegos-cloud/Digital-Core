CREATE PROCEDURE "informix".sp_conciliarcatalogocalles()

RETURNING CHAR(6), CHAR(80);

------------------------------------------------------------
DEFINE sql_err 			                INTEGER;
DEFINE isam_err 		                INTEGER;
DEFINE error_info		                CHAR(80);
DEFINE cCod_ret                         CHAR(6);
DEFINE cMensaje                         CHAR(80);
DEFINE vnumerocalle                     INTEGER;
DEFINE vnombrecalle                     CHAR(30);
DEFINE v_numerocalle                    INTEGER;
DEFINE vfechahoy                        DATE;

DEFINE vdia                             DATE;
DEFINE vHora                            CHAR(8);
DEFINE vEmpresa                         CHAR(3);
DEFINE vProceso                         CHAR(30);
DEFINE vProcesoinicio                   CHAR(30);
------------------------------------------------------------
LET cCod_ret      = '00000';
LET sql_err       = 0;
LET cMensaje      = 'Proceso Exitoso';
LET vnumerocalle  = 0;
LET vnombrecalle  = '';
LET v_numerocalle = 0;

LET vEmpresa       = '001';
LET vProceso       = 'sp_conciliarcatalogocalles';
LET vProcesoinicio = 'PROCESO INICIALIZADO';
/*
Creado por José Almeida
Fecha de creacion 22 de octubre de 2009
Deberá instalarse en BDINTEG
Se creo para el conciliamiento de datos
de las calles que existen en el catalogo de coppel
con los de bancoopel, aquellas calles que existen en
coppel y no bancoppel seran insertadas en el catalogo
*/
      BEGIN
  
        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
            LET cMensaje = error_info;
            
            SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia FROM sysmaster:sysshmvals;
            SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vHora FROM sysmaster:sysshmvals;
           
            INSERT INTO bdicobranza:cb_bitacora_cob (proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert, num_ult_reg_proc)
            VALUES (vProceso, cCod_ret, cMensaje, user, vdia, vHora, null); 

            
			RETURN cCod_ret, cMensaje;
	    END EXCEPTION;
	    
        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia FROM sysmaster:sysshmvals;
        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vHora FROM sysmaster:sysshmvals;
        
        INSERT INTO bdicobranza:cb_bitacora_cob (proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert, num_ult_reg_proc)
        VALUES (vProceso,'11111' , vProcesoinicio, user, vdia, vHora, null); 

	    
        ---------------Obtenemos la fecha de Hoy-----------------
        SELECT fecha_hoy 
        INTO   vfechahoy
        FROM   bdinteg:si_fechas;
        
        ---------------Borramos los datos de la tabla para insertar nuevos conciliados--------
        DELETE si_catcalles_bcpl_cpl;
        
        --------------Obtenemos los datos de las dos tablas y cuando no existan en bancoopel-----
        --------------se insertaran en el catalogo de bancoopel-----------------------------------
     FOREACH 
        SELECT a.numerocalle, a.nombrecalle, b.numerocalle
        INTO   vnumerocalle, vnombrecalle, v_numerocalle
        FROM   BDINTEG:si_catcalles_coppel a  
        LEFT OUTER JOIN BDINTEG:si_catcalles b ON (a.numerocalle = b.numerocalle)
        
                    IF ( v_numerocalle IS NULL )  THEN
                            
        INSERT INTO BDINTEG:si_catcalles_bcpl_cpl (numerocalle, fecha_conciliacion, tipo_actualizacion) 
                                   VALUES (vnumerocalle, vfechahoy, 'I');
        
                          ---Agregar que inserte directamente en si_catcalles
                          INSERT INTO bdinteg:si_catcalles (numerocalle, nombrecalle, f_inserta)
                                      VALUES(vnumerocalle, vnombrecalle, vfechahoy);
                                   
        UPDATE     BDINTEG:si_catcalles_coppel SET b_conciliado = 'V' WHERE numerocalle = vnumerocalle;             
                                   
                     END IF;
                     
      END FOREACH;
        
        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia FROM sysmaster:sysshmvals;
        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vHora FROM sysmaster:sysshmvals;
        
        INSERT INTO bdicobranza:cb_bitacora_cob (proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert, num_ult_reg_proc)
            VALUES (vProceso, cCod_ret, cMensaje, user, vdia, vHora, null); 

      
                 RETURN cCod_ret, cMensaje;
        END;
        END PROCEDURE;