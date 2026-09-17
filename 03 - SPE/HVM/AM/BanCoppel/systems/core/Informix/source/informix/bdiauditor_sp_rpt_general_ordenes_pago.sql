CREATE PROCEDURE "informix".sp_rpt_general_ordenes_pago (pfecha_pago1 DATE, pfecha_pago2 DATE, ptipo_orden CHAR(03))


RETURNING 	 CHAR(08)						AS cod_ret
			,date							AS fecha_envio                    
			,datetime hour to fraction(3)   AS hora_envio
			,CHAR(08)						AS usuario_envio
			,char(20)                       AS num_control 
			,CHAR(120)						AS nom_ordenante
			,CHAR(80)						AS ordenante_direccion
			,char(20)                       AS ordenante_telefono
			,CHAR(04)						AS sucursal_numero_origen 
			,CHAR(40)						AS sucursal_nombre_origen
			,CHAR(85)						AS sucursal_localidad_origen
			,char(10)                       AS estatus
			,money(18,2)                    AS monto_total 
			,date                           AS fecha_pago                     
			,datetime hour to fraction(3)   AS hora_pago  
			,CHAR(08)						AS usuario_pago
			,CHAR(120)						AS nom_beneficiario
			,char(2)                        AS tipo_identificacion 
			,char(25)                       AS numero_identificacion
			,char(80)                       AS beneficiario_direccion
			,char(20)                       AS beneficiario_telefono 
			,char(4)                        AS sucursal_numero_pagadora
			,CHAR(40)						AS sucursal_nombre_pagadora
			,CHAR(85)						AS sucursal_localidad_pagadora
			  
			;

--variables de retorno	
	DEFINE	cod_ret						CHAR(08)						  ;
    DEFINE	vfecha_envio                    date							  ;
	DEFINE	vhora_envio                     datetime hour to fraction(3)      ;
	DEFINE	vusuario_envio                  CHAR(08)						  ;
	DEFINE	vnum_control                    char(20)                          ;
	DEFINE	vnom_ordenante                  CHAR(120)						  ;
	DEFINE	vordenante_direccion            CHAR(80)						  ;
	DEFINE	vordenante_telefono             char(20)                          ;
	DEFINE	vsucursal_numero_origen         CHAR(04)						  ;
	DEFINE	vsucursal_nombre_origen         CHAR(40)						  ;
	DEFINE	vsucursal_localidad_origen      CHAR(85)						  ;
	DEFINE	vestatus                        char(10)                          ;
	DEFINE	vmonto_total                    money(18,2)                       ;
	DEFINE	vfecha_pago                     date                              ;
	DEFINE	vhora_pago                      datetime hour to fraction(3)      ;
	DEFINE	vusuario_pago                   CHAR(08)						  ;
	DEFINE	vnom_beneficiario               CHAR(120)						  ;
	DEFINE	vtipo_identificacion            char(2)                           ;
	DEFINE	vnumero_identificacion          char(25)                          ;
	DEFINE	vbeneficiario_direccion         char(80)                          ;
	DEFINE	vbeneficiario_telefono          char(20)                          ;
	DEFINE	vsucursal_numero_pagadora       char(4)                           ;
	DEFINE	vsucursal_nombre_pagadora       CHAR(40)						  ;
	DEFINE	vsucursal_localidad_pagadora    CHAR(85)						  ;
		 
 
-- variables de control de errores
	DEFINE	iSqlErr           					INTEGER; 

BEGIN
	ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr 
				,'01/01/1900'
				,CURRENT		
				,''			
				,''			
				,''			
				,''			
				,''			
				,''			
				,''			
				,''			
				,''			
				,0			
				,'01/01/1900'
				,CURRENT		
				,''			
				,''			
				,''			
				,''			
				,''			
				,''			
				,''			
				,''			
				,''			
				;
				
			END IF;
	END EXCEPTION;			

	--inicializacion de variables
	let	cod_ret					='00000000'	 ;
	let vfecha_envio                ='01/01/1900';
	let vhora_envio                 =CURRENT	 ;
	let vusuario_envio              =''			 ;
	let vnum_control                =''			 ;
	let vnom_ordenante              =''			 ;
	let vordenante_direccion        =''			 ;
	let vordenante_telefono         =''			 ;
	let vsucursal_numero_origen     =''			 ;
	let vsucursal_nombre_origen     =''			 ;
	let vsucursal_localidad_origen  =''			 ;
	let vestatus                    =''			 ;
	let vmonto_total                =0			 ;
	let vfecha_pago                 ='01/01/1900';
	let vhora_pago                  =CURRENT	 ;
	let vusuario_pago               =''			 ;
	let vnom_beneficiario           =''			 ;
	let vtipo_identificacion        =''			 ;
	let vnumero_identificacion      =''			 ;
	let vbeneficiario_direccion     =''			 ;
	let vbeneficiario_telefono      =''			 ;
	let vsucursal_numero_pagadora   =''			 ;
	let vsucursal_nombre_pagadora   =''			 ;
	let vsucursal_localidad_pagadora=''			 ;

	
				 
			SELECT * FROM bdisac:"informix".sac_pld_ordenes_pago 
				WHERE ((fecha_pago between pfecha_pago1 and pfecha_pago2 ) or (fecha_envio between pfecha_pago1 and pfecha_pago2)) and tipo_orden = ptipo_orden
				AND	estatus ='CANCELADA' OR  estatus ='REVERSADA'   
			INTO temp tablapld;
			
			
			INSERT INTO tablapld 
				SELECT * FROM  bdisac:"informix".sac_pld_ordenes_pago  
				WHERE ((fecha_pago between pfecha_pago1 and pfecha_pago2 ) or (fecha_envio between pfecha_pago1 and pfecha_pago2)) and tipo_orden = ptipo_orden
				AND estatus IN ('PAGADA') AND num_control NOT IN (SELECT num_control FROM tablapld);
		 
		 
			INSERT INTO tablapld 
				SELECT * FROM  bdisac:"informix".sac_pld_ordenes_pago 
				WHERE ((fecha_pago between pfecha_pago1 and pfecha_pago2) or (fecha_envio between pfecha_pago1 and pfecha_pago2)) and tipo_orden = ptipo_orden
				AND estatus IN ('ENVIADA') AND num_control NOT IN (SELECT num_control FROM tablapld);
	
	
		foreach cursor1 WITH HOLD for
		 
	 
			SELECT  fecha_envio                 
			       ,hora_envio
			       ,usuario_envio
			       ,num_control 
			       ,trim(ordenante_nombre1)||' '|| trim(ordenante_nombre2) ||' '|| trim(ordenante_appaterno)||' '|| trim(ordenante_apmaterno) as nombre_ordenante
			       ,ordenante_direccion
			       ,ordenante_telefono
			       ,sucursal_numero_origen 
			       ,(select nombre from bdinteg:si_sucursales suc where suc.sucursal = pg.sucursal_numero_origen ) as nombre_suc
			       ,(select trim(direccion1) ||' '|| trim(direccion2) from bdinteg:si_sucursales suc where suc.sucursal = pg.sucursal_numero_origen ) as direccion_suc
			       ,estatus
			       ,monto_total 
			       ,fecha_pago                  
			       ,hora_pago  
			       ,usuario_pago
			       ,trim(beneficiario_nombre1)||' '||trim(beneficiario_nombre2)||' '||trim(beneficiario_appaterno)||' '||trim(beneficiario_apmaterno ) as nom_beneficiario
			       ,tipo_identificacion 
			       ,numero_identificacion
			       ,beneficiario_direccion
			       ,beneficiario_telefono 
			       ,sucursal_pagadora
			       ,(select nombre from bdinteg:si_sucursales suc where suc.sucursal = pg.sucursal_pagadora ) as nombre_sucpag
			       ,(select trim(direccion1) ||' '|| trim(direccion2) from bdinteg:si_sucursales suc where suc.sucursal = pg.sucursal_pagadora ) as dir_sucpag
			
			INTO
				 vfecha_envio                
				,vhora_envio                 
				,vusuario_envio              
				,vnum_control                
				,vnom_ordenante              
				,vordenante_direccion        
				,vordenante_telefono         
				,vsucursal_numero_origen     
				,vsucursal_nombre_origen     
				,vsucursal_localidad_origen  
				,vestatus                    
				,vmonto_total                
				,vfecha_pago                 
				,vhora_pago                  
				,vusuario_pago               
				,vnom_beneficiario           
				,vtipo_identificacion        
				,vnumero_identificacion      
				,vbeneficiario_direccion     
				,vbeneficiario_telefono      
				,vsucursal_numero_pagadora   
				,vsucursal_nombre_pagadora   
				,vsucursal_localidad_pagadora
				
			FROM tablapld pg
			WHERE 	((fecha_pago between pfecha_pago1 and pfecha_pago2 ) or (fecha_envio between pfecha_pago1 and pfecha_pago2)) and 
					tipo_orden = ptipo_orden
			group by fecha_envio,hora_envio,usuario_envio,num_control,estatus,nombre_ordenante,ordenante_direccion,ordenante_telefono,sucursal_numero_origen,nombre_suc,
			direccion_suc,monto_total, fecha_pago, hora_pago,usuario_pago, nom_beneficiario, tipo_identificacion,numero_identificacion,beneficiario_direccion,
			beneficiario_telefono,sucursal_pagadora,nombre_sucpag,dir_sucpag

			RETURN cod_ret 				
				,vfecha_envio                
				,vhora_envio                 
				,vusuario_envio              
				,vnum_control                
				,vnom_ordenante              
				,vordenante_direccion        
				,vordenante_telefono         
				,vsucursal_numero_origen     
				,vsucursal_nombre_origen     
				,vsucursal_localidad_origen  
				,vestatus                    
				,vmonto_total                
				,vfecha_pago                 
				,vhora_pago                  
				,vusuario_pago               
				,vnom_beneficiario           
				,vtipo_identificacion        
				,vnumero_identificacion      
				,vbeneficiario_direccion     
				,vbeneficiario_telefono      
				,vsucursal_numero_pagadora   
				,vsucursal_nombre_pagadora   
				,vsucursal_localidad_pagadora
				
				with resume;
				
	     END foreach
		 
		 drop table tablapld; 
		 
END
END PROCEDURE;