CREATE PROCEDURE "informix".sp_reporte_diario_porta(pempresa CHAR(3))
RETURNING CHAR(5);

/* Definir Variables para captura error*/

	DEFINE vcodret1         	CHAR(5);
    DEFINE vcodret2         	CHAR(5);
    DEFINE vcodret3         	CHAR(50);
    DEFINE sql_err          	INTEGER;
    DEFINE isam_err         	INTEGER;
    DEFINE desc_err         	CHAR(50);
    DEFINE ven_transacc     	SMALLINT; 
	DEFINE vsql             	CHAR(700);
    DEFINE vstmt            	CHAR(200);

	
    /* Definir Variables de reporte Diario de Portabilidad*/
	
	DEFINE ccuenta_clabe		CHAR(18);
	DEFINE cproducto 			CHAR(40);
	DEFINE corigen              CHAR(50);   
	DEFINE csentido 			CHAR(40);
	DEFINE cestatus				CHAR(50);
	DEFINE cfecha_solicitud		CHAR(25);
	DEFINE ccliente 		    CHAR(20);
	DEFINE cfecha_estatus_portabilidad CHAR(25);
	DEFINE cfecha_solca_portabilidad CHAR(25);
    DEFINE csucursal                 CHAR(5);
	DEFINE cusuario                  CHAR(8);
		
	DEFINE vfechahoy			CHAR(8);
	DEFINE vfechant		 		CHAR(8);
	
	
	    /* Definir Variables de reporte Diario de Portabilidad*/
	
	DEFINE ccuenta_clabe_resp		CHAR(18);
	DEFINE cproducto_resp 			CHAR(40);
	DEFINE corigen_resp              CHAR(50);   
	DEFINE csentido_resp 			CHAR(40);
	DEFINE cestatus_resp				CHAR(50);
	DEFINE cfecha_solicitud_resp		CHAR(25);
	DEFINE ccliente_resp 		    CHAR(20);
	DEFINE cfecha_estatus_portabilidad_resp CHAR(25);
	DEFINE cfecha_solca_portabilidad_resp  CHAR(25);
    DEFINE csucursal_resp 					CHAR(8);
    DEFINE cuser_insert_resp				CHAR(8);
	
	
	
	
	/* Definir Variables de reporte Diario de Portabilidad*/
	
	DEFINE ccuenta_clabe_can		CHAR(18);
	DEFINE cproducto_can 			CHAR(40);
	DEFINE corigen_can              CHAR(50);   
	DEFINE csentido_can 			CHAR(40);
	DEFINE cestatus_can				CHAR(50);
	DEFINE cfecha_solicitud_can		CHAR(25);
	DEFINE ccliente_can 		    CHAR(20);
	DEFINE cfecha_estatus_portabilidad_can CHAR(25);
	DEFINE cfecha_solca_portabilidad_can  CHAR(25);
    DEFINE csucursal_can			CHAR(8);
	DEFINE cusuario_can 			CHAR(8);
	
	
	
	
	LET  vcodret1         		= '00000';
    LET  vcodret2         		= '000';
    LET  vcodret3         		= '';
    LET  sql_err	       		= 0 ;
    LET  isam_err         		= 0 ;
    LET  desc_err         		= '';
    LET  ven_transacc     		= 0 ;
	LET  vsql             		= '';
    LET  vstmt            		= '';
	LET cfecha_estatus_portabilidad = '';
	LET cfecha_solca_portabilidad = '';
	
	
		/* Inicializar Variables de reporte Tramite_Solicitud_Portabilidad_Sucursal_mes */
	
	LET ccuenta_clabe				= '';
	LET cproducto 					= '';
	LET csentido 					= '';
	LET cestatus					= '';
	LET cfecha_solicitud			= '';
	LET ccliente 		         	= '';
	LET vfechant					= '';
	LET corigen						= '';	
	LET vfechahoy					= '';	
    LET csucursal                   = '';
	LET cusuario                    = '';
	
	
	
	
			/* Inicializar Variables de reporte Respuestas */
	
	LET ccuenta_clabe_resp				= '';
	LET cproducto_resp 					= '';
	LET csentido_resp 					= '';
	LET cestatus_resp					= '';
	LET cfecha_solicitud_resp			= '';
	LET ccliente_resp 		         	= '';
	LET corigen_resp					= '';	
    LET csucursal_resp 					= '';
    LET cuser_insert_resp				= '';
	
	
	
	
				/* Inicializar Variables de reporte cancelaciones */
	
	LET ccuenta_clabe_can				= '';
	LET cproducto_can 					= '';
	LET csentido_can 					= '';
	LET cestatus_can					= '';
	LET cfecha_solicitud_can			= '';
	LET ccliente_can 		         	= '';
	LET corigen_can					= '';	
    LET cfecha_solca_portabilidad_can   = '';
	LET csucursal_can					= '';
	LET cusuario_can 					= '';

	

	
    BEGIN
     ON EXCEPTION SET sql_err, isam_err, desc_err
        --SET DEBUG FILE TO "/resplogifx/oper-prod/sp_reporte_diario_porta.err";
        --TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1;
        END IF;
     END EXCEPTION;
	 
		  --SET DEBUG FILE TO "/informix/oper-prod/sp_reporte_diario_porta.out";
		  --TRACE ON;
	
	 SET ISOLATION TO DIRTY READ;
     SET LOCK MODE TO WAIT 3;
	 	 
  
  	--/* Selecciona la fecha hoy  
		 
		select YEAR(fecha_hoy)||LPAD(MONTH(fecha_hoy),2,0)||LPAD(DAY(fecha_hoy),2,0)
		into vfechahoy
		from sc_fechas
		where empresa = 001;
  	 
		--/* Selecciona la fecha anterior  
		 
		select YEAR(fecha_ant)||LPAD(MONTH(fecha_ant),2,0)||LPAD(DAY(fecha_ant),2,0)
		into vfechant
		from sc_fechas
		where empresa = 001;
		 
		 
	  IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'rpt_portabilidad_diario') THEN
        DROP TABLE bdicheq:"informix".rpt_portabilidad_diario; 
     END IF;
	 
	 	CREATE TABLE bdicheq:"informix".rpt_portabilidad_diario(
	    
		  secuencia serial,		  	
	       -- Fecha  de la solicitud --  
		  fecha_solicitud			CHAR(25) ,
		   -- Sucursal --	
		  sucursal 	                CHAR(8) ,
		   -- Usuario --
		  user_insert               CHAR(8) ,
		   --numero cliente --
		  cliente 				CHAR(25),
		   -- Número de cuenta -- 	

		  cuenta_clabe 			CHAR(30),
		  --tipo de producto--
		  producto 				CHAR(40),		

		  --estatus de portabilidad --
		   estatus				CHAR(50),  
		  -- Origen de la solicitud --  
		  origen  CHAR(25) ,
		  --tipo de tramite--
		  sentido 	CHAR(40)
		)	
		  
		  
     EXTENT SIZE 3200 NEXT SIZE 320 LOCK MODE ROW;
	 
	 
		INSERT INTO "informix".rpt_portabilidad_diario VALUES 
			(0,'Fecha de Solicitud','Sucursal','Promotor','No Cliente Bancoppel','No. cta. Bancoppel','Producto','Estatus','Origen','Sentido');
	 
	 
			FOREACH 
	 
			 --##  Recopila información de solicitudes realizadas en sucursal con el sentido   Bancoppel  a OTRO BANCO	
				
				 select
                 SUBSTR(fecha_solicitud,7,2)||'/'||SUBSTR(fecha_solicitud,5,2)||'/'||SUBSTR(fecha_solicitud,1,4),
                 sol.sucursal, 
                 sol.user_insert,
                 sol.num_cte,
				 SUBSTR(sol.cta_ordenante,7,11),
				 mae.producto,								 


				 sol.estatus_portabilidad,
                 sol.clave_origen,
				 sol.clave_sentido		
				 INTO  cfecha_solicitud, csucursal, cusuario, ccliente, ccuenta_clabe, cproducto, cestatus, corigen, csentido					
				 from bdicheq: sc_portacec_solicitud sol,
				 bdicheq: sc_maechq  mae
				 WHERE SUBSTR(sol.cta_ordenante,7,11)=mae.cuenta
                 and sol.clave_origen in (1,2)
                 and sol.clave_sentido='1'
				 and sol.fecha_solicitud = vfechant	
				
				

				UNION ALL
										
			  --## Recopila información de solicitudes realizadas en sucursal con el sentido  OTRO BANCO  a Bancoppel.   		
										
				 select
				        
                 SUBSTR(fecha_solicitud,7,2)||'/'||SUBSTR(fecha_solicitud,5,2)||'/'||SUBSTR(fecha_solicitud,1,4),
                 sol. sucursal, 
                 sol.user_insert,
                 sol.num_cte,
				 SUBSTR(sol.cta_receptora,7,11),
				 mae.producto,


				 sol.estatus_portabilidad,								 
                sol.clave_origen,
				sol.clave_sentido			 
				from bdicheq: sc_portacec_solicitud sol,				
				bdicheq: sc_maechq  mae
				WHERE SUBSTR(sol.cta_receptora,7,11)=mae.cuenta
                and sol.clave_origen in (1,2)
                and sol.clave_sentido='2'				
				and sol.estatus_portabilidad='2'				
				and sol.fecha_solicitud = vfechant		
													
									
				UNION ALL			
				
			   --##  Recopila información de solicitudes en Otro banco con el sentido  Bancoppel a oro banco.  	 
	 
			 select
                  SUBSTR(fecha_solicitud,7,2)||'/'||SUBSTR(fecha_solicitud,5,2)||'/'||SUBSTR(fecha_solicitud,1,4),
                  sol. sucursal, 
                  sol.user_insert,
                  sol.num_cte,
				 SUBSTR(sol.cta_ordenante,7,11),
				mae.producto,		

				sol.estatus_portabilidad,
                sol.clave_origen,
				sol.clave_sentido				 
				from bdicheq: sc_portacec_solicitud sol,							
				bdicheq: sc_maechq  mae
				WHERE SUBSTR(sol.cta_ordenante,7,11)=mae.cuenta
                and sol.clave_origen='3'
                and sol.clave_sentido='1'		
                and sol.fecha_estatus_portabilidad = vfechant
            				
															
	
			INSERT INTO "informix".rpt_portabilidad_diario VALUES 
				(0,cfecha_solicitud, csucursal, cusuario, ccliente, ccuenta_clabe, cproducto, cestatus, corigen, csentido);
				
			END FOREACH;

		LET vsql = 'echo "set isolation to dirty read; unload to /resplogifx/conciliachq/Reporte_Diario_De_Solicitudes_Portabilidad_'||vfechahoy||'.txt '||
                'select fecha_solicitud, sucursal, user_insert, cliente, cuenta_clabe , producto , estatus , origen , sentido from  rpt_portabilidad_diario order by secuencia;" > /resplogifx/conciliachq/qwery_rpt_diario_Por.sql';
		SYSTEM vsql;
		LET vsql = '';
    
	    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/qwery_rpt_diario_Por.sql';
		--LET vstmt = "dbaccess bdicheq /informix/Reporte_Diario_Portabilidad/qwery_rpt_diario_Por.sql"; 
		SYSTEM vstmt;
		LET vstmt = ''; 
	 
	  
			--#######################################################
			-- REPORTE "RESPUESTAS DE LAS SOLICITUDES DE LOS OTROS BANCOS" 
			--#######################################################
	  
	 
	 IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'rpt_diario_resp_otrbco') THEN
        DROP TABLE bdicheq:"informix".rpt_diario_resp_otrbco; 
     END IF;
	 
	 CREATE TABLE bdicheq:"informix".rpt_diario_resp_otrbco(
	    
		  secuencia serial,
		  
	      --Fecha del estatus de portabilidad--
		  fecha_estatus_portabilidad CHAR(30),
		  -- Fecha  de la solicitud --  
		  fecha_solicitud			CHAR(25) ,
		  -- Sucursal --	
		  sucursal					CHAR(8) ,
		  --Usuario --
		  promotor 				 	CHAR(8) ,		
		  --numero cliente--
		  cliente 				CHAR(25),			
		  -- Numero de cuenta --	
		  cuenta_clabe 			CHAR(30),
		  --tipo de producto--
		  producto 				CHAR(40),			   



		  --estatus de portabilidad --
		   estatus				CHAR(50),  
		  -- Origen de la solicitud --  
		  origen  CHAR(25) ,
		  --tipo de tramite--
		  sentido 	CHAR(40) )	
		  
		  
     EXTENT SIZE 3200 NEXT SIZE 320 LOCK MODE ROW;
	 
	 
		INSERT INTO "informix".rpt_diario_resp_otrbco  VALUES 
			(0,'Fecha Estatus Portabilidad','Fecha de Solicitud','Sucursal','Promotor','No Cliente Bancoppel','No. cta. Bancoppel','Producto','Estatus','Origen','Sentido');
	 
		
		FOREACH 
	 
				--## Recopila información de las respuestas de las solicitudes en sucursal con el sentido  OTRO BANCO  a Bancoppel. 
				
				
	
                   select
                 SUBSTR(fecha_estatus_portabilidad,7,2)||'/'||SUBSTR(fecha_estatus_portabilidad,5,2)||'/'||SUBSTR(fecha_estatus_portabilidad,1,4),
                 SUBSTR(fecha_solicitud,7,2)||'/'||SUBSTR(fecha_solicitud,5,2)||'/'||SUBSTR(fecha_solicitud,1,4),		
                 sol. sucursal, 
                 sol.user_insert,
                 sol.num_cte,
				 SUBSTR(sol.cta_receptora,7,11),
				 mae.producto,				 				 


				 sol.estatus_portabilidad,
                 sol.clave_origen,
				 sol.clave_sentido				 	

	            into  cfecha_estatus_portabilidad_resp, cfecha_solicitud_resp, csucursal_resp, cuser_insert_resp, ccliente_resp, ccuenta_clabe_resp, cproducto_resp, cestatus_resp ,corigen_resp ,csentido_resp  					
				from bdicheq: sc_portacec_solicitud sol,			
				bdicheq: sc_maechq  mae			
				WHERE SUBSTR(sol.cta_receptora,7,11)=mae.cuenta
                and sol.clave_origen in (1,2)
                and sol.clave_sentido='2'					         
                and sol.fecha_estatus_portabilidad = vfechant   
	
	
			
					INSERT INTO "informix".rpt_diario_resp_otrbco VALUES 
				(0,cfecha_estatus_portabilidad_resp, cfecha_solicitud_resp, csucursal_resp, cuser_insert_resp, ccliente_resp, ccuenta_clabe_resp, cproducto_resp, cestatus_resp ,corigen_resp ,csentido_resp);

				END FOREACH;
	 

				LET vsql = 'echo "set isolation to dirty read; unload to /resplogifx/conciliachq/Reporte_Diario_De_Respuestas_OtrBco_'||vfechahoy||'.txt '||
                'select fecha_estatus_portabilidad, fecha_solicitud , sucursal , promotor , cliente, cuenta_clabe , producto, estatus, origen, sentido from  rpt_diario_resp_otrbco order by secuencia;" > /resplogifx/conciliachq/qwery_rpt_diario_resp_otrbco.sql';
				SYSTEM vsql;
				LET vsql = '';
                LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/qwery_rpt_diario_resp_otrbco.sql';
				--LET vstmt = "dbaccess bdicheq /informix/Reporte_Diario_Portabilidad/qwery_rpt_diario_resp_otrbco.sql"; 
				SYSTEM vstmt;
				LET vstmt = ''; 
			
			
			
					--#######################################################
					-- REPORTE "CANCELACIONES" 
					--#######################################################
			
				IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'rpt_diario_cancelaciones') THEN
				DROP TABLE bdicheq:"informix".rpt_diario_cancelaciones; 
				END IF;
			
				CREATE TABLE bdicheq:"informix".rpt_diario_cancelaciones(
	    
				secuencia serial,
				
				 --Fecha de cancelacion de portabilidad--
				 fecha_solca_portabilidad CHAR(30),
				 -- Fecha  de la solicitud --  
				 fecha_solicitud		  CHAR(25) ,
				 -- Sucursal --	
				 sucursal 				  CHAR(8) ,	
				 -- Promotor --
				 promotor 				  CHAR(8) ,
				  --numero cliente--
				  cliente 				CHAR(25),			 
				  --Numero de cuenta
				cuenta_clabe 			CHAR(30),
				--tipo de producto--
				  producto 				CHAR(40),				 

				--estatus de portabilidad --
				   estatus				CHAR(50),  
				-- Origen de la solicitud --  
				  origen  CHAR(25) ,
				--tipo de tramite--
				  sentido 	CHAR(40)  )
			 
		  		  
				EXTENT SIZE 3200 NEXT SIZE 320 LOCK MODE ROW;
				
			INSERT INTO "informix".rpt_diario_cancelaciones  VALUES 
			(0,'Fecha solicitud Cancelación','Fecha de Solicitud','Sucursal','Promotor','No Cliente Bancoppel','No. cta. Bancoppel','Producto','Estatus','Origen','Sentido');
	 	
					
				FOREACH 
														
				--## Recopila información de solicitudes de cancelación realizadas en sucursal. 	
							
				 select
                 SUBSTR(fecha_solca_portabilidad,7,2)||'/'||SUBSTR(fecha_solca_portabilidad,5,2)||'/'||SUBSTR(fecha_solca_portabilidad,1,4),
                 SUBSTR(fecha_solicitud,7,2)||'/'||SUBSTR(fecha_solicitud,5,2)||'/'||SUBSTR(fecha_solicitud,1,4),
				 sol. sucursal, 
                 sol.user_insert,
                 sol.num_cte,
                 SUBSTR(sol.cta_receptora,7,11),
				 mae.producto,				 				


				 sol.estatus_portabilidad,
                 sol.clave_origen,
				 sol.clave_sentido			 
				into  cfecha_solca_portabilidad_can, cfecha_solicitud_can, csucursal_can, cusuario_can, ccliente_can, ccuenta_clabe_can, cproducto_can , cestatus_can ,corigen_can ,csentido_can 					

				from bdicheq: sc_portacec_solicitud sol,		
				bdicheq: sc_maechq  mae
				WHERE SUBSTR(sol.cta_receptora,7,11)=mae.cuenta            
                and sol.clave_origen in (1,2)               
                and sol.clave_sentido='0'			
				and sol.fecha_solca_portabilidad=  vfechant	
				
				UNION ALL
				

		         select
                 SUBSTR(fecha_solca_portabilidad,7,2)||'/'||SUBSTR(fecha_solca_portabilidad,5,2)||'/'||SUBSTR(fecha_solca_portabilidad,1,4),
                 SUBSTR(fecha_solicitud,7,2)||'/'||SUBSTR(fecha_solicitud,5,2)||'/'||SUBSTR(fecha_solicitud,1,4),
                 sol. sucursal, 
                 sol.user_insert,
                 sol.num_cte,	
                 SUBSTR(sol.cta_ordenante,7,11),
				 mae.producto,				 				


				 sol.estatus_portabilidad,
                 sol.clave_origen,
				 sol.clave_sentido									

				from bdicheq: sc_portacec_solicitud sol,		
				bdicheq: sc_maechq  mae
				WHERE SUBSTR(sol.cta_ordenante,7,11)=mae.cuenta            
                and sol.clave_origen in (1,2)               
                and sol.clave_sentido='0'			
				and sol.fecha_solca_portabilidad=  vfechant	
				

	 
				INSERT INTO "informix".rpt_diario_cancelaciones VALUES 

				(0,cfecha_solca_portabilidad_can, cfecha_solicitud_can, csucursal_can, cusuario_can, ccliente_can, ccuenta_clabe_can, cproducto_can , cestatus_can ,corigen_can ,csentido_can);
				
				
				END FOREACH;
	 
	 
				LET vsql = 'echo "set isolation to dirty read; unload to /resplogifx/conciliachq/Reporte_Diario_De_Cancelaciones_'||vfechahoy||'.txt '||
                'select fecha_solca_portabilidad, fecha_solicitud, sucursal, promotor, cliente, cuenta_clabe , producto, estatus, origen, sentido   from  rpt_diario_cancelaciones order by secuencia;" > /resplogifx/conciliachq/qwery_rpt_diario_cancelaciones.sql';
				SYSTEM vsql;
				LET vsql = '';    
				LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/qwery_rpt_diario_cancelaciones.sql';
				--LET vstmt = "dbaccess bdicheq /informix/Reporte_Diario_Portabilidad/qwery_rpt_diario_cancelaciones.sql"; 
				SYSTEM vstmt;
				LET vstmt = ''; 
	 
	 
	 END;
    
     RETURN vcodret1;
    
	 END PROCEDURE;