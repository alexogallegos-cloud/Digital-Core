CREATE PROCEDURE "informix".sp_conarchivos_con2(cparam1 char(1),cTipo char(3),dfecha_ini date,dfecha_fin date,cUsuario char(10),cNumEmpl varchar(9),pregistros INTEGER,precuperacion INTEGER)
RETURNING VARCHAR(6) as Cod_ret,VARCHAR(80) as Men_ret,
     char(23) as nombrearchivo,        
     char(3)  as archivo_origen,      
     date     as fecha_archivo, 
     integer  as num_registros325,
     money(16,2) as monto325,       
     date     as fecha_proceso,  
     datetime year to fraction(5)  as fecha_hora_transferencia,       
     datetime year to fraction(5)  as fecha_hora_ini_proceso,      
     datetime year to fraction(5)  as fecha_hora_carga_archivo,      
     datetime year to fraction(5)  as fecha_hora_carga_tabla,
     datetime year to fraction(5)  as fecha_hora_ini_concilia_reg,
     datetime year to fraction(5)  as fecha_hora_fin_concilia_reg,
     datetime year to fraction(5)  as fecha_hora_fin_proceso,
     datetime year to fraction(5)  as fecha_hora_gen_conadmin,
     char(1) as transferencia,
     char(1) as carga,
     char(1) as conadmin,
     integer as num_cargo,
     money(16,2)  as monto_cargo,
     integer as num_abono,
     money(16,2)  as monto_abono,
     char(1) as proceso;


	DEFINE  SQL_ERR          INTEGER;
	DEFINE  ISAM_ERR         INTEGER;
	DEFINE  ERROR_INFO       VARCHAR(80);
	DEFINE  P_COD_RET        VARCHAR(6);
	DEFINE  P_COD_RET2        VARCHAR(6);
	DEFINE  P_MENSAJE        VARCHAR(80);
	DEFINE c_nombrearchivo char(23);
	DEFINE c_archivo_origen char(3);
	DEFINE d_fecha_archivo date;
	DEFINE i_num_registros325 integer;
	DEFINE m_monto325 money(16,2);
	DEFINE d_fecha_proceso date;
	DEFINE d_fecha_hora_transferencia datetime year to fraction(5);
	DEFINE d_fecha_hora_ini_proceso datetime year to fraction(5);
	DEFINE d_fecha_hora_carga_archivo datetime year to fraction(5);
	DEFINE d_fecha_hora_carga_tabla datetime year to fraction(5);
	DEFINE d_fecha_hora_ini_concilia_reg datetime year to fraction(5);
	DEFINE d_fecha_hora_fin_concilia_reg datetime year to fraction(5);
	DEFINE d_fecha_hora_fin_proceso datetime year to fraction(5);
	DEFINE d_fecha_hora_gen_conadmin datetime year to fraction(5);
	DEFINE c_transferencia char(1);
	DEFINE c_carga char(1);
	DEFINE c_conadmin char(1);
	DEFINE i_num_cargo integer;
	DEFINE m_monto_cargo money(16,2);
	DEFINE i_num_abono integer;
	DEFINE m_monto_abono money(16,2);
	DEFINE c_proceso char(1);



	LET c_nombrearchivo = '';
	LET c_archivo_origen = '';
	LET d_fecha_archivo= '01-01-1900';
	LET i_num_registros325 = 0;
	LET m_monto325 = 0;
	LET d_fecha_proceso = '01-01-1900';
	LET d_fecha_hora_transferencia = '1900-01-01 00:00:00';
	LET d_fecha_hora_ini_proceso = '1900-01-01 00:00:00';
	LET d_fecha_hora_carga_archivo = '1900-01-01 00:00:00';
	LET d_fecha_hora_carga_tabla = '1900-01-01 00:00:00';
	LET d_fecha_hora_ini_concilia_reg = '1900-01-01 00:00:00';
	LET d_fecha_hora_fin_concilia_reg = '1900-01-01 00:00:00';
	LET d_fecha_hora_fin_proceso = '1900-01-01 00:00:00';
	LET d_fecha_hora_gen_conadmin = '1900-01-01 00:00:00';
	LET c_transferencia  = '';
	LET c_carga  = '';
	LET c_conadmin  = '';
	LET i_num_cargo  = 0;
	LET m_monto_cargo  = 0;
	LET i_num_abono  = 0;
	LET m_monto_abono  = 0;
	LET c_proceso  = '';
	
	--SET DEBUG FILE TO "/tmp/manuel/ejemplo_consarc";
	--TRACE ON;

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
	  
	  EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora('130','Error en sp_conarchivos_con ' || SQL_ERR || ' ' || P_MENSAJE,cNumEmpl) INTO P_COD_RET2;
      RETURN P_COD_RET,P_MENSAJE,c_nombrearchivo,c_archivo_origen,d_fecha_archivo,i_num_registros325,m_monto325,d_fecha_proceso,d_fecha_hora_transferencia,
				   d_fecha_hora_ini_proceso,d_fecha_hora_carga_archivo,d_fecha_hora_carga_tabla,d_fecha_hora_ini_concilia_reg,d_fecha_hora_fin_concilia_reg,
				   d_fecha_hora_fin_proceso,d_fecha_hora_gen_conadmin,c_transferencia,c_carga,c_conadmin,i_num_cargo,m_monto_cargo,i_num_abono,m_monto_abono,c_proceso;
   END EXCEPTION;

--************************************************************
-- Creado por Manuel Osuna Valencia 
-- fecha : 19/10/2011
-- Funcion: Consulta de Archivos de conciliaciÃ³n por fecha
--************************************************************

   LET P_COD_RET = '00000';
   LET P_COD_RET2 = '00000';
   LET P_MENSAJE = 'PROCESO EXITOSO';
   
   	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
   
   IF (cparam1 == 1) THEN --Consulta por Todos los archivos 

		FOREACH
						
			SELECT SKIP pregistros FIRST precuperacion nombrearchivo,archivo_origen,fecha_archivo,num_registros325,monto325,fecha_proceso,fecha_hora_transferencia,
					fecha_hora_ini_proceso,fecha_hora_carga_archivo,fecha_hora_carga_tabla,fecha_hora_ini_concilia_reg,fecha_hora_fin_concilia_reg,
					fecha_hora_fin_proceso,fecha_hora_gen_conadmin,transferencia,carga,conadmin,num_cargo,monto_cargo,num_abono,monto_abono,proceso						
			INTO c_nombrearchivo,c_archivo_origen,d_fecha_archivo,i_num_registros325,m_monto325,d_fecha_proceso,d_fecha_hora_transferencia,
				 d_fecha_hora_ini_proceso,d_fecha_hora_carga_archivo,d_fecha_hora_carga_tabla,d_fecha_hora_ini_concilia_reg,d_fecha_hora_fin_concilia_reg,
				 d_fecha_hora_fin_proceso,d_fecha_hora_gen_conadmin,c_transferencia,c_carga,c_conadmin,i_num_cargo,m_monto_cargo,i_num_abono,m_monto_abono,c_proceso		
			FROM bditarjeta:"informix".td_archivos_conciliacion
			WHERE fecha_proceso BETWEEN dfecha_ini AND dfecha_fin
			
			
			RETURN P_COD_RET,P_MENSAJE,c_nombrearchivo,c_archivo_origen,d_fecha_archivo,i_num_registros325,m_monto325,d_fecha_proceso,d_fecha_hora_transferencia,
				   d_fecha_hora_ini_proceso,d_fecha_hora_carga_archivo,d_fecha_hora_carga_tabla,d_fecha_hora_ini_concilia_reg,d_fecha_hora_fin_concilia_reg,
				   d_fecha_hora_fin_proceso,d_fecha_hora_gen_conadmin,c_transferencia,c_carga,c_conadmin,i_num_cargo,m_monto_cargo,i_num_abono,m_monto_abono,c_proceso	with resume;	
								
		END FOREACH;
		
	ELIF (cparam1 == 2) THEN --Consulta un Archivo en especifico
	
		FOREACH
						
			SELECT SKIP pregistros FIRST precuperacion nombrearchivo,archivo_origen,fecha_archivo,num_registros325,monto325,fecha_proceso,fecha_hora_transferencia,
					fecha_hora_ini_proceso,fecha_hora_carga_archivo,fecha_hora_carga_tabla,fecha_hora_ini_concilia_reg,fecha_hora_fin_concilia_reg,
					fecha_hora_fin_proceso,fecha_hora_gen_conadmin,transferencia,carga,conadmin,num_cargo,monto_cargo,num_abono,monto_abono,proceso						
			INTO c_nombrearchivo,c_archivo_origen,d_fecha_archivo,i_num_registros325,m_monto325,d_fecha_proceso,d_fecha_hora_transferencia,
				 d_fecha_hora_ini_proceso,d_fecha_hora_carga_archivo,d_fecha_hora_carga_tabla,d_fecha_hora_ini_concilia_reg,d_fecha_hora_fin_concilia_reg,
				 d_fecha_hora_fin_proceso,d_fecha_hora_gen_conadmin,c_transferencia,c_carga,c_conadmin,i_num_cargo,m_monto_cargo,i_num_abono,m_monto_abono,c_proceso		
			FROM bditarjeta:"informix".td_archivos_conciliacion
			WHERE 	archivo_origen = trim(cTipo)  
					and fecha_proceso BETWEEN dfecha_ini AND dfecha_fin 
			
			
			RETURN P_COD_RET,P_MENSAJE,c_nombrearchivo,c_archivo_origen,d_fecha_archivo,i_num_registros325,m_monto325,d_fecha_proceso,d_fecha_hora_transferencia,
				   d_fecha_hora_ini_proceso,d_fecha_hora_carga_archivo,d_fecha_hora_carga_tabla,d_fecha_hora_ini_concilia_reg,d_fecha_hora_fin_concilia_reg,
				   d_fecha_hora_fin_proceso,d_fecha_hora_gen_conadmin,c_transferencia,c_carga,c_conadmin,i_num_cargo,m_monto_cargo,i_num_abono,m_monto_abono,c_proceso	with resume;	
								
		END FOREACH;
		
	
 	
   
	END IF;

     
	
  
END;
END PROCEDURE
DOCUMENT
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Luis Gomez Santiago',
'Descripcion: SE MODIFICA EL FILTRO DE LA CONSULTA PARA UTILIZAR EL CAMPO DE FECHA PROCESO EN LUGAR DE FECHA ARCHIVO',
'Fecha: 2012/10/08',
'Version: 20121008.1830',
'BD: BdiTarjeta';

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