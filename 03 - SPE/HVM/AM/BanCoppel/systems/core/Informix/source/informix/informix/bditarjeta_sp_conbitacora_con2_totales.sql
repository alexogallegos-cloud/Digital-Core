CREATE PROCEDURE "informix".sp_conbitacora_con2_totales(cTipo char(1),iElemento integer,dfecha_ini date,dfecha_fin date)
RETURNING VARCHAR(6) as Cod_ret, INTEGER as total_regitros;
        
        DEFINE  SQL_ERR          INTEGER;
        DEFINE  ISAM_ERR         INTEGER;
        DEFINE  ERROR_INFO       VARCHAR(80);
        DEFINE  P_COD_RET        VARCHAR(6);    
        DEFINE  P_MENSAJE        VARCHAR(80);
		DEFINE  i_NoRegistros    INTEGER;
        
		LET i_NoRegistros    = 0;
        
        --SET DEBUG FILE TO "/tmp/manuel/ejemplo_consarc";
        --TRACE ON;

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
                  
      RETURN P_COD_RET, i_NoRegistros;
                        
   END EXCEPTION;

--************************************************************
-- Creado por Manuel Osuna Valencia 
-- fecha : 19/10/2011
-- Funcion: Consulta de Bitacora de Conciliacion
--************************************************************

   LET P_COD_RET = '00000';   
   LET P_MENSAJE = 'PROCESO EXITOSO';
   
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
   
   IF (cTipo == 1) THEN --Consulta por Todos los Elementos

					SELECT COUNT(*) 
					INTO i_NoRegistros
					FROM bditarjeta:"informix".td_bitacora_conciliacion
					WHERE  date(fecha_hora) BETWEEN dfecha_ini AND dfecha_fin;                       
											
					RETURN P_COD_RET, i_NoRegistros;
                
        ELIF (cTipo == 2) THEN --Consulta un Elemento en Especifico
        
					SELECT COUNT(*)
					INTO i_NoRegistros
					FROM bditarjeta:"informix".td_bitacora_conciliacion
					WHERE  elemento = iElemento and date(fecha_hora) BETWEEN dfecha_ini AND dfecha_fin;                      
											
					RETURN P_COD_RET, i_NoRegistros;
   
        END IF;

END;
END PROCEDURE;