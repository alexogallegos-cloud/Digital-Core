CREATE PROCEDURE "informix".sp_depura_tbl_si_cambiostcte_total(pfechaini date,pfechafin date )
RETURNING CHAR(5), INTEGER, CHAR(100);
---------------------------------------------------------------------------------
-- Procedimiento   : sp_depura_tbl_si_cambiostcte_total
-- Version         : 1.0
-- Fecha creacion  : Abril 2015
-- Descripcion     : Depura la información de la tabla bpi_bitacora
-----------------------------------------------------------------------------------
--Definicion de variables del proceso, operaciones con fechas y manejo de errores--
-----------------------------------------------------------------------------------
    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
	DEFINE error_info		CHAR(100);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcontador1       INTEGER;
	DEFINE vcontador2       INTEGER;
	DEFINE vcomienza        SMALLINT;
    DEFINE vabierto         SMALLINT;
	DEFINE vf_depura        DATE;
	DEFINE vf_oper          DATE;
	DEFINE vf_ultdiames     DATE;
	DEFINE vrow      		INTEGER;
	DEFINE vrownew      	INTEGER;
	DEFINE vtable			CHAR(50);
	DEFINE vtbl				CHAR(20);
	DEFINE vfecha_oper     	DATE;         
	DEFINE vid_operacion   	CHAR(4);      
	DEFINE vsucursal       	CHAR(4);      
	DEFINE vid_usuario     	INTEGER;      
	DEFINE vipusuario      	CHAR(15);     
	DEFINE vfecha_aplic    	DATE;         
	DEFINE vcuenta_origen  	CHAR(12);     
	DEFINE vdestino        	CHAR(18);     
	DEFINE vmonto_oper     	DECIMAL(14,2);
	DEFINE vsec_transaccion	CHAR(16);     
	DEFINE vcgenerico1     	CHAR(100);    
	DEFINE vcgenerico2     	CHAR(100);    
	DEFINE vcgenerico3     	CHAR(200);    
	DEFINE vcgenerico4     	CHAR(40);     
	DEFINE vcgenerico5     	CHAR(60);     
	DEFINE vcgenerico6     	CHAR(100);    
	DEFINE vreferencia     	CHAR(100);    
	DEFINE vfolio          	CHAR(16);     
	DEFINE vsql             CHAR(4000);
	DEFINE cRuta			CHAR(200);
	DEFINE pfecha1          CHAR(4);
	DEFINE pfecha2          CHAR(4);
	DEFINE vfecha_cambio	DATE;
	
---------------------------
--Inicializando variables--
---------------------------
	--SET DEBUG FILE TO "/informix/ireb/sp_depura_tbl_si_cambiostcte_total.out"; --Se genera log en un archivo .out
	--TRACE ON;
	
		LET error_info		= '';
		LET vcodret1        = '00000';
		LET vcodret2        = '00000';
		LET sql_err	        = 0;
		LET isam_err        = 0;
		LET vcontador1      = 0;
		LET vcontador2      = 0;
		LET vcomienza       = -1;
		LET vabierto        = 0;
		LET vrow			= 0;
		LET vrownew			= 0;
		LET cRuta 			= '/respaldos/bpi/';
		LET vtbl			= '';
		

	/*Incia SP*/
	BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
		IF sql_err <> 0 THEN
			LET vcodret1 = sql_err;
			LET vcodret2 = isam_err;
			LET error_info = error_info;
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;

	LET pfecha1	= TO_CHAR (pfechaini,'%Y');
	LET pfecha2	= TO_CHAR (pfechafin,'%Y');
	
	IF pfecha1 = pfecha2 THEN
	
		--OBTIENE REGISTROS
		SELECT COUNT(*) INTO vrow FROM bdinteg:si_cambiostcte WHERE fecha_cambio::DATE BETWEEN pfechaini AND pfechafin;
		
		--VALIDACION DE LA TABLA
		LET vtable = 'si_cambiostctehis'||pfecha1;
		SELECT tabname INTO vtbl FROM sysmaster:systabnames WHERE dbsname = 'bdinteg' and tabname = vtable;
		
		IF vtbl IS NULL  THEN

			--CREA TABLA
			LET vsql="";
			LET vsql = 'echo "CREATE TABLE bdinteg:si_cambiostctehis'|| pfecha1 ||' (numcliente CHAR(9),id_statusanterior SMALLINT,id_statusactual SMALLINT, ipusuario CHAR(15), fecha_cambio DATETIME YEAR to SECOND, suc_cambio CHAR(4), usuario_cambio CHAR(8));'||
			'CREATE INDEX informix.idx_cambiostcte1_'|| pfecha1 ||' ON informix.si_cambiostctehis'|| pfecha1 ||'(numcliente);" > '|| SUBSTR(cRuta,1,LENGTH(cRuta)) ||'createtbl.sql';
			SYSTEM TRIM(vsql);
					
			--EJECUCIÓN DEL ARCHIVO PARA CREAR TABLA
			LET vsql = "";
			LET vsql = 'dbaccess bdinteg '|| SUBSTR(cRuta,1,LENGTH(cRuta)) ||'createtbl.sql';
			SYSTEM TRIM(vsql);

			--SE ELIMINA EL ARCHIVO ARCHIVO PARA CREAR TABLA
			LET vsql = "";
			LET vsql = 'rm ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'createtbl.sql';
			SYSTEM TRIM(vsql);

			LET vcodret1 = '00000';
			LET error_info	= 'FINALIZO CON EXITO, DEPURANDO '||vrow||' REGISTROS';
			
		ELSE		
		
			LET vcodret1 = '00001';
			LET error_info = 'ERROR AL CREAR TABLA' ;
		
		END IF;
			
		IF vrow > 0 THEN
			
			--INSERTA REGISTROS A LA TABLA HISTORICA			
			LET vsql="";
			LET vsql = 'echo "INSERT INTO bdinteg:si_cambiostctehis'|| pfecha1 ||' (numcliente, id_statusanterior, id_statusactual, ipusuario, fecha_cambio, suc_cambio, usuario_cambio) SELECT numcliente, id_statusanterior, id_statusactual, ipusuario, fecha_cambio, suc_cambio, usuario_cambio FROM bdinteg:si_cambiostcte WHERE fecha_cambio::DATE BETWEEN '''||pfechaini||''' AND '''||pfechafin||''';" > '|| SUBSTR(cRuta,1,LENGTH(cRuta)) ||'pasobitacora.sql';
			SYSTEM TRIM(vsql);
			
			--EJECUCIÓN DEL ARCHIVO PARA INSERTAR REGISTROS
			LET vsql = "";
			LET vsql = 'dbaccess bdinteg '|| SUBSTR(cRuta,1,LENGTH(cRuta)) ||'pasobitacora.sql';
			SYSTEM TRIM(vsql);
		
			--SE ELIMINA EL ARCHIVO 
			LET vsql = "";
			LET vsql = 'rm ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'pasobitacora.sql';
			SYSTEM TRIM(vsql);
		
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
		
			--ELIMINA REGISTROS DE LA TABLA si_cambiostcte 
			FOREACH cursor_borra WITH HOLD FOR
				SELECT fecha_cambio
				  INTO vfecha_cambio
				  FROM bdinteg:si_cambiostcte
				 WHERE fecha_cambio::DATE BETWEEN pfechaini AND pfechafin

				IF vcomienza = -1 THEN
					LET vcomienza = 0;
					BEGIN WORK;
					LET vabierto = 1;
				END IF;

				DELETE FROM bdinteg:si_cambiostcte
				 WHERE CURRENT OF cursor_borra;

				LET vcontador1 = vcontador1 + 1;
				LET vcontador2 = vcontador2 + 1;

				IF vcontador2 >= 1000 THEN
					LET vcontador2 = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
			END FOREACH;	
			
			IF vabierto = 1 THEN
				COMMIT WORK;
			END IF;
				
			LET error_info	= 'FINALIZO CON EXITO, DEPURANDO '||vrow||' REGISTROS';
			LET vcodret1 = '00000';
			
		ELSE 
			
			LET vcodret1 = '00002';
			LET error_info = 'NO EXISTEN REGISTROS' ;
				
		END IF;
				
	ELSE
		
		LET vcodret1 = '00003';
		LET error_info = 'NO SE PUEDE DEPURAR CON LAS FECHAS ESTABLECIDAS' ;
	
	END IF;
	
		RETURN vcodret1, vcontador1, error_info;	
	END;
END PROCEDURE
;