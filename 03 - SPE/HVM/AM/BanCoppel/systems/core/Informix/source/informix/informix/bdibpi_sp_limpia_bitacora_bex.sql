CREATE PROCEDURE "informix".sp_limpia_bitacora_bex(p_fecha DATE)
RETURNING VARCHAR(5),VARCHAR(5), VARCHAR(50);

--******************
--Define Variables
--******************
-----------------------
--Variables de Proceso
-----------------------
DEFINE vcodret1         	VARCHAR(5);
DEFINE vcodret2         	VARCHAR(5);
DEFINE error_info			VARCHAR(50);
DEFINE sql_err          	INTEGER;
DEFINE isam_err         	INTEGER;
DEFINE vcontador1       	INTEGER;
DEFINE vfecha1				CHAR (21);
DEFINE vfecha2				CHAR (21);
---------------------------
--Variables de operaciones
---------------------------
DEFINE	v_fecha_oper     	DATETIME YEAR to SECOND;
DEFINE  v_id_operacion   	CHAR(4);
DEFINE  v_sucursal       	CHAR(4);
DEFINE  v_id_usuario     	INTEGER;
DEFINE  v_ipusuario      	CHAR(15);
DEFINE  v_fecha_aplic    	DATE;
DEFINE  v_cuenta_origen  	CHAR(12);
DEFINE  v_destino        	CHAR(18);
DEFINE  v_monto_oper     	DECIMAL(14,2);
DEFINE  v_sec_transaccion	VARCHAR(16);
DEFINE  v_cgenerico1     	LVARCHAR;
DEFINE  v_cgenerico2     	LVARCHAR;
DEFINE  v_cgenerico3     	LVARCHAR;
DEFINE  v_cgenerico4     	LVARCHAR;
DEFINE  v_cgenerico5     	LVARCHAR;
DEFINE  v_cgenerico6     	LVARCHAR;
DEFINE  v_referencia     	LVARCHAR;
DEFINE  v_folio          	LVARCHAR;
DEFINE  v_dispositivo    	CHAR(10); 


--*********************
--Inicializa variables
--*********************
-----------------------
--Variables de Proceso
-----------------------
LET vcodret1         = '00000';
LET vcodret2         = '00000';
LET error_info		 = 'INICIA PROCESO, SE CARGAN VARIABLES';
LET sql_err	         = 0;
LET isam_err         = 0;
LET vcontador1       = 0;
--LET vfecha1			 = substr(p_fecha, 1,2)||'-'||substr(p_fecha, 4,2)||'-'||substr(p_fecha, 7,4)||' 00:00:00';
--LET vfecha2			 = substr(p_fecha, 1,2)||'-'||substr(p_fecha, 4,2)||'-'||substr(p_fecha, 7,4)||' 23:59:59';
LET vfecha1			 = substr(p_fecha, 1,2)||'-'||substr(p_fecha, 4,2)||'-'||substr(p_fecha, 7,4)||" "||'00:00:00';
LET vfecha2			 = substr(p_fecha, 1,2)||'-'||substr(p_fecha, 4,2)||'-'||substr(p_fecha, 7,4)||" "||'23:59:59';


LET	 v_fecha_oper     	=	'';
LET  v_id_operacion   	=	'';
LET  v_sucursal       	=	'';
LET  v_id_usuario     	=	'';
LET  v_ipusuario      	=	'';
LET  v_fecha_aplic    	=	'';
LET  v_cuenta_origen  	=	'';
LET  v_destino        	=	'';
LET  v_monto_oper     	=	'';
LET  v_sec_transaccion	=	'';
LET  v_cgenerico1     	=	'';
LET  v_cgenerico2     	=	'';
LET  v_cgenerico3     	=	'';
LET  v_cgenerico4     	=	'';
LET  v_cgenerico5     	=	'';
LET  v_cgenerico6     	=	'';
LET  v_referencia     	=	'';
LET  v_folio          	=	'';
LET  v_dispositivo    	=	'';


BEGIN
 
	-------------------------
	--Manejo de excepciones--
	-------------------------
	ON EXCEPTION SET sql_err, isam_err, error_info
			IF sql_err <> 0 THEN
				LET vcodret1 = sql_err;
				LET vcodret2 = isam_err;
				LET error_info = error_info;
				COMMIT WORK;
			RETURN vcodret1,isam_err,error_info;
			END IF;
		END EXCEPTION;
	
	--//Inicia SPL
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		
--SET DEBUG FILE TO "/informix/Allan/sp_limpia_bitacora_bex.out"; --Se genera log en un archivo .out
--TRACE ON;
	
--SET DEBUG FILE TO "/bitacoras/sorteEfectivo/sp_sorteo_efectivo_pbades5.out"; --Se genera log en un archivo .out
--TRACE ON;	
		
	
FOREACH WITH HOLD 		
		
	SELECT fecha_oper, id_operacion, sucursal, id_usuario, ipusuario, fecha_aplic, cuenta_origen
	,destino, monto_oper, sec_transaccion, cgenerico1, cgenerico2, cgenerico3, cgenerico4
	,cgenerico5, cgenerico6, referencia, folio, dispositivo 

	INTO  

	v_fecha_oper, v_id_operacion, v_sucursal, v_id_usuario, v_ipusuario, v_fecha_aplic, v_cuenta_origen
	,v_destino, v_monto_oper, v_sec_transaccion, v_cgenerico1, v_cgenerico2, v_cgenerico3, v_cgenerico4
	,v_cgenerico5, v_cgenerico6, v_referencia, v_folio, v_dispositivo

	FROM bdibpi:bpi_bitacora_bex
	where fecha_oper between to_date (vfecha1, "%m-%d-%Y %H:%M:%S")  and to_date(vfecha2, "%m-%d-%Y %H:%M:%S")
	--where fecha_oper::date = p_fecha	
		
	--/CADA 5000 REGISTROS ACTUALIZADOS SE TERMINA EL TRABAJO E INICA DE NUEVO
  	
  		IF vcontador1 = 0 THEN  --Inicia el trabajo 
  				BEGIN WORK;
  			END IF; 
  				
		
		
	INSERT INTO bdibpi:bpi_bitacora_bex_his (fecha_oper, id_operacion, sucursal, id_usuario, ipusuario, fecha_aplic, cuenta_origen
	, destino, monto_oper, sec_transaccion, cgenerico1, cgenerico2, cgenerico3, cgenerico4
	, cgenerico5, cgenerico6, referencia, folio, dispositivo) 
	VALUES(v_fecha_oper, v_id_operacion, v_sucursal, v_id_usuario, v_ipusuario, v_fecha_aplic, v_cuenta_origen
	,v_destino, v_monto_oper, v_sec_transaccion, v_cgenerico1, v_cgenerico2, v_cgenerico3, v_cgenerico4
	,v_cgenerico5, v_cgenerico6, v_referencia, v_folio, v_dispositivo);

	
		
	DELETE FROM bdibpi:bpi_bitacora_bex
	WHERE fecha_oper 	= v_fecha_oper
	and id_operacion  	= v_id_operacion
	and sucursal 		= v_sucursal
	and id_usuario 		= v_id_usuario;
	--and ipusuario 		= v_ipusuario
	--and fecha_aplic 	= v_fecha_aplic
	--and cuenta_origen 	= v_cuenta_origen
	--and destino 		= v_destino
	--and monto_oper 		= v_monto_oper
	--and sec_transaccion = v_sec_transaccion
	--and cgenerico1 		= v_cgenerico1
	--and cgenerico2 		= v_cgenerico2
	--and cgenerico3 		= v_cgenerico3
	--and cgenerico4 		= v_cgenerico4
	--and cgenerico5 		= v_cgenerico5
	--and cgenerico6 		= v_cgenerico6
	--and referencia 		= v_referencia
	--and folio 			= v_folio
	--and dispositivo 	= v_dispositivo;
	
	
	
		LET vcontador1 = vcontador1 + 1; --contador de registros
  			
  			IF vcontador1 = 5000 THEN  --reinicia el contador cada 5000 registros
  				LET vcontador1 = 0;
  				COMMIT WORK; 
  			END IF; 
   
    
   END FOREACH;
   
  

 --Termina el trabajo en caso de no llegar a los 5000 registros para no bloquear las tablas.
  IF (vcontador1 > 0) THEN		
			COMMIT WORK;
		END IF;
	
	

  --valores de salida
  --LET error_info = 'TOTAL DE REGISTROS RESPALDADOS DEL DIA '||substr(p_fecha, 4,2) || '/'|| substr(p_fecha, 1,2) || '/'|| substr(p_fecha, 7,4);
  LET error_info = 'Ejecucion Exitosa';
  RETURN vcodret1,vcodret2,error_info;
  
  
END;
END PROCEDURE

DOCUMENT
'CREADO POR: JONATHAN RUIZ',
'FECHA DE CREACION: 08 DE AGOSTO DEL 2018',
'OBJETIVO: SE CREA PROCESO PARA lIMPIAR bpi_bitacora_bex',
'          TRANSFIERE REGISTROS A bpi_bitacora_bex_his AL TODAY-1',
'          Y ELIMINA REGISTROS DE bpi_bitacora_bex ',
'BD: BDIBPI';

CREATE PROCEDURE "informix".sp_consulta_dispo_bpi(pNumTel CHAR(10),pCte VARCHAR(20), pUdid CHAR(150),pImei CHAR(150))
       RETURNING CHAR(5) AS Cod_ret, CHAR(50) AS mensaje, CHAR(50) AS usuario, CHAR(10) AS telefono, CHAR(2) AS dispo_act, CHAR(150) AS imei, CHAR(150) AS udid, smallint AS status 

       --Definimos variables
       DEFINE sql_err  		INTEGER;
       DEFINE vCod_ret 		CHAR(5);
       DEFINE vMensaje 		CHAR(50);
       DEFINE vUsuario 		CHAR(50);
       DEFINE vNumcte  		CHAR(11);
       DEFINE vTelefono 	CHAR(10);
       DEFINE vDispositivo 	CHAR(2);
       DEFINE vImei 		CHAR(150);
       DEFINE vIdui 		CHAR(150);
       DEFINE vContador		INTEGER;
       DEFINE sIdStatus 	smallint ;
	   
       /*
       DEFINE pNumTel1		CHAR(10);	
       DEFINE pCte1 		CHAR(20);	
       DEFINE pUdid1		CHAR(150);	
       DEFINE pImei1		CHAR(150);	
       */

       LET vCod_ret 		= '00001';
       LET vMensaje 		= 'ERROR';
       LET vUsuario			= '';
       LET vNumcte  		= '';
       LET vTelefono		= '';
       LET vDispositivo		= '';
       LET vImei			= '';
       LET vIdui			= '';
       LET sIdStatus		= 0;	
       LET vContador		= 0;


       BEGIN
        ON EXCEPTION SET sql_err
                IF sql_err <> 0 THEN
                        LET vCod_ret = sql_err;
                        RETURN vCod_ret,vMensaje,vUsuario, vTelefono, vDispositivo, vImei, vIdui, sIdStatus;
                END IF;
        END EXCEPTION;

        SET LOCK MODE TO WAIT 3;
        SET ISOLATION TO DIRTY READ;


        --valida servicio de BPI
        SELECT a.usuario,b.id_status INTO vUsuario,sIdStatus FROM bdibpi:bpi_usuario a
        INNER JOIN bdinteg:si_bpiusuarios b ON a.numcliente = b.numcte WHERE numcliente =  pCte AND st_portal = 'activo';

        IF NVL(vUsuario,'')=''  THEN
            LET vCod_ret = '00002';
            LET vMensaje = 'SIN BPI';
            RETURN vCod_ret,vMensaje,vUsuario, vTelefono, vDispositivo, vImei, vIdui, sIdStatus;
        END IF

		
		--Actualiza dispositivo
		SELECT count(num_cliente ) INTO vContador
		FROM bpi_reg_dispo_apps  where num_cliente = pCte and dispo_act = '1' and udid=imei and imei=pUdid AND modelo = 'Android';

		IF vContador = 1 THEN
			UPDATE bpi_reg_dispo_apps SET imei=pImei  WHERE  num_cliente = pCte and dispo_act = '1' AND modelo = 'Android';
		END IF;
				
		
        IF NVL(vUsuario,'') <> '' THEN
            SELECT  no_celular,dispo_act,imei,udid
            INTO vTelefono, vDispositivo, vImei, vIdui
            FROM bdibpi:bpi_usuario a 
            INNER JOIN bdibpi:bpi_reg_dispo_apps c ON a.numcliente=c.num_cliente
            INNER JOIN bdinteg:si_bpiusuarios b on a.numcliente = b.numcte
            WHERE  st_portal = 'activo' AND numcliente= pCte and dispo_act='1';
        END IF	

        IF NVL(vDispositivo,'') = '' THEN 
            LET vCod_ret = '00003';
            LET vMensaje = 'CLIENTE SIN ACTUALIZAR';
            RETURN vCod_ret,vMensaje,vUsuario, vTelefono, vDispositivo, vImei, vIdui, sIdStatus;
        END IF

        IF NVL(vDispositivo,'') <> '' THEN 
            LET vCod_ret = '00000';
            LET vMensaje = 'CLIENTE ACTUALIZADO';
            RETURN vCod_ret,vMensaje,vUsuario, vTelefono, vDispositivo, vImei, vIdui, sIdStatus;
        END IF

    END

    END PROCEDURE;