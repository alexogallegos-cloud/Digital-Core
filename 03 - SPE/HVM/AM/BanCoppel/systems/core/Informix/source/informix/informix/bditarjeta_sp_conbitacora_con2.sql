CREATE PROCEDURE "informix".sp_conbitacora_con2(cTipo char(1),iElemento integer,dfecha_ini date,dfecha_fin date,iregistros integer,irecuperacion integer)
RETURNING VARCHAR(6) as Cod_ret,VARCHAR(80) as Men_ret,
     integer as elemento,        
     datetime year to fraction(5)  as fecha_hora,      
     varchar(250) as actividad,
     varchar(10) as cve_usuario;
        
        DEFINE  SQL_ERR          INTEGER;
        DEFINE  ISAM_ERR         INTEGER;
        DEFINE  ERROR_INFO       VARCHAR(80);
        DEFINE  P_COD_RET        VARCHAR(6);    
        DEFINE  P_MENSAJE        VARCHAR(80);
        DEFINE  i_Elemento       INTEGER;
        DEFINE  d_Fecha_hora     datetime year to fraction(5);
        DEFINE  c_Actividad      varchar(250);
        DEFINE  c_Cve_usuario    varchar(10);
        

        LET c_Actividad = '';
        LET c_Cve_usuario = ''; 
        LET i_Elemento = 0;     
        LET d_Fecha_hora = '1900-01-01 00:00:00';
        
        --SET DEBUG FILE TO "/tmp/manuel/ejemplo_consarc";
        --TRACE ON;

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
                  
      RETURN P_COD_RET,P_MENSAJE,i_Elemento,d_Fecha_hora,c_Actividad,c_Cve_usuario;
                        
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

                FOREACH
                                                                        
                        SELECT SKIP iregistros FIRST irecuperacion elemento,fecha_hora,actividad,cve_usuario 
                        INTO i_Elemento,d_Fecha_hora,c_Actividad,c_Cve_usuario
                        FROM bditarjeta:"informix".td_bitacora_conciliacion
                        WHERE  date(fecha_hora) BETWEEN dfecha_ini AND dfecha_fin                       
                                                
                        RETURN P_COD_RET,P_MENSAJE,i_Elemento,d_Fecha_hora,c_Actividad,c_Cve_usuario with resume;                       
                                                                                                        
                END FOREACH;
                
        ELIF (cTipo == 2) THEN --Consulta un Elemento en Especifico
        
                FOREACH
                                                
                        SELECT SKIP iregistros FIRST irecuperacion elemento,fecha_hora,actividad,cve_usuario 
                        INTO i_Elemento,d_Fecha_hora,c_Actividad,c_Cve_usuario
                        FROM bditarjeta:"informix".td_bitacora_conciliacion
                        WHERE  elemento = iElemento and date(fecha_hora) BETWEEN dfecha_ini AND dfecha_fin                      
                                                
                        RETURN P_COD_RET,P_MENSAJE,i_Elemento,d_Fecha_hora,c_Actividad,c_Cve_usuario with resume;                               
                END FOREACH;
   
        END IF;

END;
END PROCEDURE;