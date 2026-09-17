CREATE PROCEDURE "informix".sp_rptsporta(pempresa CHAR(3))
RETURNING CHAR(5);

	DEFINE vcodret1         	CHAR(5);
    DEFINE vcodret2         	CHAR(5);
    DEFINE vcodret3         	CHAR(50);
    DEFINE sql_err          	INTEGER;
    DEFINE isam_err         	INTEGER;
    DEFINE desc_err         	CHAR(50);
    DEFINE vcontador        	INTEGER;
    DEFINE ven_transacc     	SMALLINT; 
	DEFINE vsql             	CHAR(600);
    DEFINE vstmt            	CHAR(200);
		
	/* Definir Variables de reporte Tramite_Solicitud_Portabilidad_Sucursal_mes */
	
	DEFINE csucursal 			CHAR(4);
	DEFINE cnombresucursal		CHAR(40);
	DEFINE ccuenta_clabe		CHAR(18);
	DEFINE cproducto 			CHAR(40);
	DEFINE csentido 			CHAR(40);
	DEFINE cestatus				CHAR(50);
	DEFINE ccausa 				CHAR(50);
	DEFINE cperiodicidad		CHAR(60);
	DEFINE cfecha_solicitud		CHAR(10);
	DEFINE cbanco_receptor		CHAR(20);
	DEFINE crfc_empresa			CHAR(12);
	DEFINE cbanco_ordenante		CHAR(20);
	DEFINE cfecha_cancelacion	CHAR(8);
	
	DEFINE ccanal               CHAR(20);
	DEFINE cfolio_solicitud     CHAR(30);  
	DEFINE cnum_cte             CHAR(20);
	DEFINE cedad                CHAR(4);
    DEFINE ccta_receptora	    CHAR(20);
	DEFINE ccta_ordenante       CHAR(20); 
	DEFINE ctelefono            CHAR(20);
	DEFINE cfecha_respuesta     CHAR(10); 
	DEFINE csalario             CHAR(10);
	
	
	

	
	/*Definir Variables de reporte Tramite_Solicitud_Portabilidad_EnOtroBanco_mes */
	 
	 
	DEFINE ccanal_obco               CHAR(20);
	DEFINE cfolio_solicitud_obco     CHAR(30);  	  
	DEFINE cnum_cte_obco             CHAR(20);	  
	DEFINE cedad_obco                CHAR(4);	  
	DEFINE csalario_obco             CHAR(10);	  
	DEFINE ccta_receptora_obco	     CHAR(20);
	DEFINE ccta_ordenante_obco       CHAR(20); 	  
	DEFINE ctelefono_obco            CHAR(20);	  
	DEFINE cfecha_respuesta_obco     CHAR(10); 	  
	DEFINE crfc_empresa_obco	     CHAR(12);	  		  		 	  	
	DEFINE cpres_pers_obco 			 CHAR(20);
	DEFINE ctarj_cred_obco           CHAR(20);   
	DEFINE ccred_coppel_obco         CHAR(20); 
	DEFINE cant_nomina				 CHAR(20); 
	DEFINE cpres_dir_nomina_obco     CHAR(20);
	
	
	
	
	DEFINE	cperiodicidad_obco		CHAR(60);		
	DEFINE	cproducto_obco 		    CHAR(40);		
	DEFINE  csentido_obco 		    CHAR(40);		  
	DEFINE	cestatus_obco		    CHAR(50);		  
	DEFINE	ccausa_obco				CHAR(50);		  
	DEFINE	cbanco_receptor_obco 	CHAR(20);	  
	DEFINE	cbanco_ordenante_obco 	CHAR(20);	
	DEFINE cfecha_solicitud_obco	CHAR(10);
	DEFINE	cCodRet_msj             CHAR(5);
	

	/*Definir Variables de reporte Portabilidad_Sucursal_OrdenCancelacion_mesX */
	
	DEFINE can_ccanal               CHAR(20);
	DEFINE can_sucursal 			CHAR(4);
	DEFINE can_nombresucursal		CHAR(40);	
	DEFINE can_cfolio_cancelacion   CHAR(30);  
	DEFINE can_fecha_solicitud      CHAR(10);	
	
	DEFINE can_num_cliente 			CHAR(20);		
    DEFINE can_cedad                CHAR(4);
	DEFINE can_sueldo				CHAR(19);
    DEFINE can_periodicidad			CHAR(60);
	DEFINE can_cuenta_receptora		CHAR(18);
	DEFINE can_cuenta_ordenante 	CHAR(18);
	DEFINE can_producto 			CHAR(40);	
	DEFINE can_ctelefono            CHAR(20);
	DEFINE can_cestatus				CHAR(30);
    DEFINE can_banco_receptor    	CHAR(20);
	DEFINE can_rfc_empresa			CHAR(12);
    DEFINE can_banco_ordenante   	CHAR(20);

	
	
	/*Definir Variables de reporte Portabilidad_OrdenCancelacion_otrosbancos_mesX */
	
	DEFINE can_sucursal_otbco 			CHAR(4);
	DEFINE can_nombresucursal_otbco		CHAR(40);	
	DEFINE can_cfolio_otbco             CHAR(30);  
	DEFINE can_fecha_cancelacion_otbco  CHAR(10);
	DEFINE can_num_cliente_otbco 	    CHAR(20);
	DEFINE can_cedad_otbco              CHAR(4);
	DEFINE can_sueldo_otbco				CHAR(19);
	DEFINE can_periodicidad_otbco	    CHAR(60);
    DEFINE can_cuenta_receptora_otbco	CHAR(18);
	DEFINE can_producto_otbco 			CHAR(40);
	DEFINE can_ctelefono_otbco          CHAR(20);
	DEFINE can_cuenta_ordenante_otbco 	CHAR(18);
	DEFINE can_rfc_empresa_otbco		CHAR(12);
	DEFINE can_emp_cte_bcpl_otbco	    CHAR(20);
	DEFINE can_banco_ordenante_otbco   	CHAR(20);

	
	
	
	
	
	
	
	
	DEFINE ccontador_tar_credito	INTEGER;
	DEFINE can_sn_tarcred		    CHAR(2);
	DEFINE ccontador_pres_pers		INTEGER;
	DEFINE can_sn_pres_pers		    CHAR(2);
	DEFINE ccontador_pres_nomina 	INTEGER;
	DEFINE can_sn_pres_nomina		CHAR(2);
	DEFINE ccontador_cred_cop		INTEGER;
	DEFINE can_sn_cred_cop 			CHAR(2);	
	DEFINE can_sn_disp_nom			CHAR(2);	
	DEFINE can_cuenta				CHAR(20);
	
	

	/*Definir Variables " Para fechas" */
		
	DEFINE cdias_pasados			INTEGER;
	DEFINE vfecha_fin_mes 			DATE;
	DEFINE vfecha_inic_mes		    DATE;
	DEFINE vfecha_fin_aaaammdd		CHAR(8);
	DEFINE vfecha_ini_aaaammdd 		CHAR(8);
	DEFINE cMesPeriodo              CHAR(15);

	
	
	
	
	/*Definir Variables "Transferencia Portabilidad_OtrBcoaBancppel_mesX" */
	
	
	DEFINE tran_OtroaBan_sucursal 			CHAR(4);
	DEFINE tran_OtroaBan_nombresucursal		CHAR(40);
	DEFINE tran_OtroaBan_num_cliente			CHAR(20);
	DEFINE tran_OtroaBan_edad                CHAR(4);
	DEFINE tran_OtroaBan_sueldo				CHAR(19);
	DEFINE tran_OtroaBan_cuenta_ordenante 	CHAR(18);
	DEFINE tran_OtroaBan_cuenta_clabe_ordenante 	CHAR(18);
	DEFINE tran_OtroaBan_producto 			CHAR(40);
	DEFINE tran_OtroaBan_cuenta_receptora	CHAR(18);
	DEFINE tran_OtroaBan_banco_receptor    	CHAR(20);
	
	DEFINE tran_OtroaBan_pres_pers 			 CHAR(20);
	DEFINE tran_OtroaBan_tarj_cred            CHAR(20);   
	DEFINE tran_OtroaBan_cred_coppel          CHAR(20); 
	DEFINE tran_OtroaBan_pres_dir_nomina      CHAR(20);
	DEFINE tran_OtroaBan_ant_nomina			 CHAR(20); 
	
	 /*Definir Variables "Transferencia Portabilidad_BancoppelAOtrosBancos_mesX" */
	
	DEFINE tran_sucursal 			CHAR(4);
	DEFINE tran_nombresucursal		CHAR(40);
	DEFINE tran_num_cliente			CHAR(20);
	DEFINE tran_edad                CHAR(4);
	DEFINE tran_sueldo				CHAR(19);
	DEFINE tran_cuenta_ordenante 	CHAR(18);
	DEFINE tran_cuenta_clabe_ordenante 	CHAR(18);
	DEFINE tran_producto 			CHAR(40);
	DEFINE tran_cuenta_receptora	CHAR(18);
	DEFINE tran_banco_receptor    	CHAR(20);
	
	DEFINE tran_pres_pers 			 CHAR(20);
	DEFINE tran_tarj_cred            CHAR(20);   
	DEFINE tran_cred_coppel          CHAR(20); 
	DEFINE tran_pres_dir_nomina      CHAR(20);
	DEFINE tran_ant_nomina			 CHAR(20); 

	
	
		
	/* Inicializar Variables Generales y de errores */
	
	LET  vcodret1         		= '00000';
    LET  vcodret2         		= '000';
    LET  vcodret3         		= '';
    LET  sql_err	       		= 0 ;
    LET  isam_err         		= 0 ;
    LET  desc_err         		= '';
    LET  vcontador        		= 0 ;
    LET  ven_transacc     		= 0 ;
	LET  vsql             		= '';
    LET  vstmt            		= '';
	
	
	/* Inicializar Variables de reporte Tramite_Solicitud_Portabilidad_Sucursal_mes */
	
	LET csucursal 					= '';
	LET cnombresucursal				= '';
	LET ccuenta_clabe				= '';
	LET cproducto 					= '';
	LET csentido 					= '';
	LET cestatus					= '';
	LET ccausa 						= '';
	LET cperiodicidad				= '';
	LET cfecha_solicitud			= '';
	LET cbanco_receptor				= '';
	LET crfc_empresa				= '';
	LET cbanco_ordenante			= '';
	LET cfecha_cancelacion			= '';
	
	
	LET ccanal              	    = '';
	LET cfolio_solicitud            = '';  
	LET cnum_cte                    = '';
	LET cedad                       = '';
    LET ccta_receptora	            = '';
	LET ccta_ordenante              = '';
	LET ctelefono                   = '';
	LET cfecha_respuesta            = '';
	LET csalario                    = '';
	
	
	
	
	
	/* Inicializar Variables de reporte Tramite_Solicitud_Portabilidad_EnOtroBanco_mes */
		 
	LET ccanal_obco              = '';
	LET cfolio_solicitud_obco    = '';
	LET cnum_cte_obco            = '';
	LET cedad_obco               = '';
	LET csalario_obco            = '';
	LET ccta_receptora_obco	     = '';
	LET ccta_ordenante_obco      = '';
	LET ctelefono_obco           = '';
	LET cfecha_respuesta_obco    = '';
	LET crfc_empresa_obco	     = ''; 		 	  	
	LET cpres_pers_obco 		 = '';
	LET ctarj_cred_obco          = '';
	LET ccred_coppel_obco        = '';
	LET cant_nomina				 = '';
	LET cpres_dir_nomina_obco    = '';
	

	LET	  cproducto_obco 		= '';	  
	LET	  csentido_obco 		= '';	
	LET	  cestatus_obco			= '';
	LET	  ccausa_obco			= '';
	LET	  cperiodicidad_obco	= '';
	LET	  cfecha_solicitud_obco	= '';
	LET	  cbanco_receptor_obco 	= '';
	LET	  cbanco_ordenante_obco = '';
	LET	  cCodRet_msj           = '';
	
	
	/*Inicializar Variables de reporte Portabilidad_Sucursal_OrdenCancelacion_mesX */
	
	LET can_ccanal               = '';
	LET can_cfolio_cancelacion   = '';  
    LET can_cedad                = '';
	LET cedad                    = '';
	LET can_ctelefono			 = '';
	LET can_cestatus			 = '';
	LET can_banco_ordenante		 = '';
	
	
	LET can_sucursal 			= '';
	LET can_nombresucursal		= '';
	LET can_rfc_empresa			= '';
	LET can_cuenta_ordenante 	= '';
	LET can_producto 			= '';
	LET can_cuenta_receptora	= '';
	LET can_banco_receptor    	= '';
	LET can_periodicidad        = '';  
	LET ccontador_tar_credito	= 0;
	LET can_sn_tarcred		    = '';
	LET ccontador_pres_pers		= 0;
	LET can_sn_pres_pers	    = '';
	LET ccontador_pres_nomina 	= 0;
	LET can_sn_pres_nomina	    = '';
	LET ccontador_cred_cop		= 0;
	LET can_sn_cred_cop 	    = '';	
	LET can_fecha_solicitud		= '';
	LET can_sueldo				= '';
	LET can_sn_disp_nom			= '';
	LET can_num_cliente			= '';
	LET can_cuenta             = '';
	
	
	
		/*Definir Variables de reporte Portabilidad_OrdenCancelacion_otrosbancos_mesX */
	
	LET can_sucursal_otbco 			 = '';
	LET can_nombresucursal_otbco	 = '';
	LET can_cfolio_otbco             = '';
	LET can_fecha_cancelacion_otbco  = '';
	LET can_num_cliente_otbco 	     = '';
	LET can_cedad_otbco              = '';
	LET can_sueldo_otbco			 = '';
	LET can_periodicidad_otbco	     = '';
    LET can_cuenta_receptora_otbco	 = '';
	LET can_producto_otbco 			 = '';
	LET can_ctelefono_otbco          = '';
	LET can_cuenta_ordenante_otbco 	 = '';
	LET can_rfc_empresa_otbco		 = '';
	LET can_emp_cte_bcpl_otbco	     = '';
	LET can_banco_ordenante_otbco    = '';
	
	

	/*Inicializar Variables de REPORTE "Transferencia Portabilidad_OtrBcoaBancppel_mesX"  */
	
	LET tran_OtroaBan_sucursal 			= '';
	LET tran_OtroaBan_nombresucursal		= '';
	LET tran_OtroaBan_num_cliente			= '';
	LET tran_OtroaBan_edad               = '';
	LET tran_OtroaBan_sueldo				= '';
	LET tran_OtroaBan_cuenta_ordenante 	= '';
	LET tran_OtroaBan_cuenta_clabe_ordenante 	= '';
	LET tran_OtroaBan_producto 			= '';
	LET tran_OtroaBan_cuenta_receptora	= '';
	LET tran_OtroaBan_banco_receptor    	= '';
	
	LET tran_OtroaBan_pres_pers 			= '';
	LET tran_OtroaBan_tarj_cred            = '';  
	LET tran_OtroaBan_cred_coppel          = ''; 
	LET tran_OtroaBan_pres_dir_nomina      = '';
	LET tran_OtroaBan_ant_nomina			 = ''; 
	
	
	
	
	/*Inicializar Variables de REPORTE "Transferencia Portabilidad_BancoppelAOtrosBancos_mesX"  */
	LET tran_sucursal 			= '';
	LET tran_nombresucursal		= '';
	LET tran_num_cliente			= '';
	LET tran_edad                = '';
	LET tran_sueldo				= '';
	LET tran_cuenta_ordenante 	= '';
	LET tran_cuenta_clabe_ordenante 	= '';
	LET tran_producto 			= '';
	LET tran_cuenta_receptora	= '';
	LET tran_banco_receptor    	= '';
	
	LET tran_pres_pers 			 = '';
	LET tran_tarj_cred            = ''; 
	LET tran_cred_coppel          = '';
	LET tran_pres_dir_nomina     = '';
	LET tran_ant_nomina			 = '';



	    BEGIN
     ON EXCEPTION SET sql_err, isam_err, desc_err
      --  SET DEBUG FILE TO "/resplogifx/oper-prod/sp_rptsporta.err";
       -- TRACE ON;
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
	 
		-- SET DEBUG FILE TO "/informix/VILLELA/sp_rptsporta.out";
		-- TRACE ON;
	
	 SET ISOLATION TO DIRTY READ;
     SET LOCK MODE TO WAIT 3;
    
	
		-- dia del mes en que nos encontramos.
		select LPAD(DAY(fecha_hoy),2,0)
		INTO cdias_pasados
		from sc_fechas
		where empresa = 001;
			
			
		-- Fecha fin del mes anterior.
		select  fecha_hoy - cdias_pasados units day
		into vfecha_fin_mes
		from sc_fechas
		where empresa = 001;
	
	    
	
		--// PONE EN VARIABLES LA FECHA SOLICITADA (AAAAMMDD)
		LET vfecha_fin_aaaammdd = YEAR(vfecha_fin_mes)||LPAD(MONTH(vfecha_fin_mes),2,0)||LPAD(DAY(vfecha_fin_mes),2,0); 

	
		
		-- Fecha inicio del mes anterior.	
		select LPAD(MONTH(vfecha_fin_mes),2,0)||'/'||'01'||'/'||(YEAR(vfecha_fin_mes))
		into vfecha_inic_mes
		from sc_fechas
		where empresa = 001;
		
		--// PONE EN VARIABLES LA FECHA SOLICITADA (AAAAMMDD)
		LET vfecha_ini_aaaammdd = YEAR(vfecha_inic_mes)||LPAD(MONTH(vfecha_inic_mes),2,0)||LPAD(DAY(vfecha_inic_mes),2,0); 
	
		--//    
		
		LET vfecha_fin_mes = LPAD(MONTH(vfecha_fin_mes),2,0)||'/'||LPAD(DAY(vfecha_fin_mes),2,0)||'/'||(YEAR(vfecha_fin_mes)); 
		
		
		
	  LET cMesPeriodo = DECODE(LPAD(MONTH(vfecha_fin_mes),2,0), "01", "Enero", 
																"02", "Febrero",
																"03", "Marzo",
																"04", "Abril",
																"05", "Mayo",
																"06", "Junio",
																"07", "Julio",
																"08", "Agosto",
																"09", "Septiembre",
																"10", "Octubre",
																"11", "Noviembre",
																"12", "Diciembre");
																
																
																
																
										 --##########################################################
	 -- REPORTE "Tramite_Solicitud_Portabilidad_Sucursal_mes" 
	 --##########################################################
	 
	
     IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'sol_portabilidad_suc') THEN
        DROP TABLE bdicheq:"informix".sol_portabilidad_suc; 
     END IF;
	 
	 	CREATE TABLE bdicheq:"informix".sol_portabilidad_suc(  
	  
		  secuencia serial,	  
		  --canal--
		  canal               CHAR(20),
		  --Sucursal --
		  no_sucursal 				CHAR(15),
		  --Nombre de la sucursal --
		  nombre_sucursal 		CHAR(40),
		  --Folio Solicitud--
		  folio_solicitud     CHAR(30),
		    -- Fecha  de la solicitud --  
		  fecha_solicitud			CHAR(25),
		  -- numero de cliente --
		  num_cte             CHAR(20),
		  -- edad-
		  edad                CHAR(4),		
          -- Salario
		  salario              CHAR(10),		    
		  -- periodicidad con la que se recibe el pago --
		  periodicidad				CHAR(60),
		  --Numero de cuenta clabe receptora --
	 	  cuenta_receptora	    CHAR(20),		
		  --Numero de cuenta clabe ordenante --
		  cuenta_ordenante		  CHAR(20),
		  --tipo de producto--
		  producto 				CHAR(40),
		  --telefono--
		  telefono            CHAR(20),
		
		  --tipo de tramite--
		  sentido 				CHAR(40),
		   -- Fecha de respuesta --
		  fecha_respuesta     CHAR(10),
		  --estatus de portabilidad --
		  estatus				CHAR(50),
		  -- causa de aceptaciÃ³n o rechazo--
		  causa				CHAR(50),	
		  -- nombre corto del banco receptor --
		  banco_receptor 			CHAR(25),
		  --rfc de la empresa --
		  rfc_empresa 				CHAR(25),
		  -- nombre corto del banco ordenante --
		  banco_ordenante 			CHAR(25) )
		  
     EXTENT SIZE 3200 NEXT SIZE 320 LOCK MODE ROW;
	 
	 
	INSERT INTO "informix".sol_portabilidad_suc 
			( canal,no_sucursal,nombre_sucursal,folio_solicitud,fecha_solicitud ,num_cte,edad, salario ,periodicidad,cuenta_receptora, cuenta_ordenante ,producto,telefono ,sentido,fecha_respuesta,estatus, causa, banco_receptor, rfc_empresa, banco_ordenante)
	VALUES ('Canal','No. sucursal','Nombre sucursal','Folio Solicitud','Fecha de Solicitud','Num Cliente','Edad', 'Salario','Periodicidad','cuenta CLABE Receptora','cuenta CLABE Ordenante','Tipo de producto cta','Telefono','Tipo trÃ¡mite', 'Fecha de respuesta','Estatus','Causas de aceptaciÃ³n o rÃ©chazo','Banco receptor','RFC empresa','Banco ordenante');
	 
	 
	 FOREACH 
	   	      	   
	      --SCRIPT PARA  CUANDO SOMOS RECEPTORES   ORIGEN SUCURSAL-BANCA   Y  SENTIDO DE OTRO BANCO A BANCOPPEL.
   
		select trim(ori.origen),sol.sucursal,trim(suc.nombre), sol.folio_solicitud, 
		(SUBSTR(fecha_solicitud,7,2))||'/' ||(SUBSTR(fecha_solicitud,5,2))||'/' ||(SUBSTR(fecha_solicitud,1,4)) as fecha_sol,
        trim(sol.num_cte),(SELECT  YEAR(Fecha_hoy) FROM bdicheq:sc_fechas WHERE empresa = '001') - year(cte.fecha_nac) ,(select sum(monto_tot) from sc_movhis where cuenta = SUBSTR(sol.cta_receptora,7,11) and  fech_alt BETWEEN vfecha_inic_mes and vfecha_fin_mes and transacc='0273' and referencia like '%NNNN%') ,trim(sol.comentario) as periodicidad
        ,sol.cta_receptora,sol.cta_ordenante, trim(pro.nombre),(SELECT  telefono   FROM bdinteg:si_telefonos_actual WHERE numcte = sol.num_cte   and tipo_tel = '2'),
		trim(sen.sentido), (SUBSTR(sol.fecha_respuesta,7,2))||'/' ||(SUBSTR(sol.fecha_respuesta,5,2))||'/' ||(SUBSTR(sol.fecha_respuesta,1,4)) as fecha_resp ,trim(est.descripcion),trim(res.descripcion),
		(select vchrnombrecorto
		from bdinteg:si_bancos
		where cvecesif= bco_receptor),	
        sol.rfc_empresa,
		(select vchrnombrecorto
		from bdinteg:si_bancos
		where cvecesif= bco_ordenante)    
		INTO ccanal, csucursal, cnombresucursal,cfolio_solicitud, cfecha_solicitud ,cnum_cte,cedad, csalario ,cperiodicidad,ccta_receptora,ccta_ordenante,cproducto,ctelefono,csentido, cfecha_respuesta,cestatus,ccausa,cbanco_receptor,crfc_empresa,cbanco_ordenante											
		from bdicheq: 
        sc_portacec_solicitud sol,
        sc_portacec_origen ori,
        bdinteg: si_sucursales suc,
        sc_maechq  mae,
        sc_producto pro,
        sc_portacec_estatus_portabilidad est,
        sc_portacec_estatus_respuesta res,
        sc_portacec_sentido sen,
        bdinteg: si_ctepf cte
        where sol.clave_origen in (1,2)
        and fecha_solicitud BETWEEN vfecha_ini_aaaammdd and vfecha_fin_aaaammdd  
        and  sol.clave_origen= ori.clave_origen
        and sol.sucursal=suc.sucursal
        and SUBSTR(sol.cta_receptora,7,11)=mae.cuenta    
        and mae.producto=pro.producto
        and sol.estatus_portabilidad= est.estatus_portabilidad
        and res.estatus_respuesta = sol.estatus_respuesta
        and sol.clave_sentido= sen.clave_sentido
        and sol.num_cte= cte.numcte
					
		
		INSERT INTO "informix".sol_portabilidad_suc 
					( canal,no_sucursal,nombre_sucursal,folio_solicitud,fecha_solicitud ,num_cte,edad,salario,periodicidad,cuenta_receptora, cuenta_ordenante ,producto,telefono ,sentido,fecha_respuesta,estatus, causa, banco_receptor, rfc_empresa, banco_ordenante)
		VALUES 		(ccanal,csucursal, cnombresucursal,cfolio_solicitud,cfecha_solicitud,cnum_cte,cedad, csalario,cperiodicidad,ccta_receptora,ccta_ordenante,cproducto,ctelefono,csentido,cfecha_respuesta,cestatus,ccausa, cbanco_receptor, crfc_empresa,				
			cbanco_ordenante);
				
	 
	 END FOREACH;
	 
	 LET vsql = 'echo "set isolation to dirty read; unload to /resplogifx/conciliachq/Tramites_Solicitud_Portabilidad_enBCPL_mes'|| TRIM(cMesPeriodo) ||'.txt '||
                'select canal,no_sucursal,nombre_sucursal,folio_solicitud,fecha_solicitud ,num_cte,edad,salario,periodicidad,cuenta_receptora, cuenta_ordenante ,producto,telefono ,sentido,fecha_respuesta,estatus, causa, banco_receptor, rfc_empresa, banco_ordenante	 from sol_portabilidad_suc order by secuencia;" > /resplogifx/conciliachq/qwery_sol_port_suc.sql';
     SYSTEM vsql;
     LET vsql = '';
    
     --LET vstmt = "dbaccess bdicheq /informix/resplogifx/conciliachq/qwery_sol_port_suc.sql";    --Se activa para desarrollo
	 
	 LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/qwery_sol_port_suc.sql'; 
	 
	 
     SYSTEM vstmt;
     LET vstmt = '';		



 --#######################################################
	  -- REPORTE "Portabilidad_Sucursal_OrdenCancelacion_mesX" 
	  --#######################################################
	 	 
		IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'suc_ordencancelacion') THEN
        DROP TABLE bdicheq:"informix".suc_ordencancelacion; 
		END IF;
	 
		CREATE TABLE bdicheq:"informix".suc_ordencancelacion(
	 
		secuencia serial,	 	
		 --canal--
		  canal               CHAR(20),
		  --Sucursal --
		  sucursal 				CHAR(25),
	 	  --Nombre de la sucursal --
		  nombre_sucursal 		CHAR(40),
		  --Folio Solicitud--
		  folio_cancelacion    CHAR(30),
		     -- Fecha  de la solicitud --  
		  fecha_cancelacion			CHAR(25),	  
		   -- numero de cliente --
		  num_cte             CHAR(20),
		  -- edad-
		  edad                CHAR(4),		
          -- Salario
		  salario              CHAR(10),		  		  
		  -- periodicidad con la que se recibe el pago --
		  periodicidad				CHAR(60),
		  --Numero de cuenta clabe receptora --
	 	  cuenta_receptora	    CHAR(20),		
		  --Numero de cuenta clabe ordenante --
		  cuenta_ordenante		  CHAR(20),
		  --tipo de producto--
		  producto 				CHAR(40),
		  --telefono--
		  telefono            CHAR(20),			 
		  --estatus de portabilidad --
		  estatus				CHAR(50),
		  -- nombre corto del banco receptor --
		  banco_receptor 			CHAR(25),
		  --rfc de la empresa --
		  rfc_empresa 				CHAR(25),
		  -- nombre corto del banco ordenante --
		  banco_ordenante 			CHAR(25) )
		  
	
	 
	 EXTENT SIZE 3200 NEXT SIZE 320 LOCK MODE ROW;
	  
	 
	 INSERT INTO "informix".suc_ordencancelacion 
	   		( canal,sucursal,nombre_sucursal,folio_cancelacion,fecha_cancelacion ,num_cte,edad, salario ,periodicidad,cuenta_receptora, cuenta_ordenante ,producto,telefono, estatus, banco_receptor, rfc_empresa, banco_ordenante)
	VALUES ('Canal','No. sucursal','Nombre sucursal','Folio cancelacion','Fecha de cancelacion','Num Cliente','Edad', 'Salario','Periodicidad','cuenta CLABE Receptora','cuenta CLABE Ordenante','Tipo de producto cta','Telefono','Estatus','Banco receptor','RFC empresa','Banco ordenante');
	 
	 FOREACH
	  
        select trim(ori.origen) as canal, trim(sol.suc_cancela) as No_sucursal, trim(suc.nombre) as suc_nombre, sol.folio_cancelacion as folio_canc,
		(SUBSTR(fecha_solca_portabilidad,7,2))||'/' ||(SUBSTR(fecha_solca_portabilidad,5,2))||'/' ||(SUBSTR(fecha_solca_portabilidad,1,4)) as fecha_canc,
		trim(sol.num_cte) as num_cte,(SELECT  YEAR(Fecha_hoy)
        FROM bdicheq:sc_fechas WHERE empresa = '001') - year(cte.fecha_nac) as edad,
		(select sum(monto_tot) from sc_movhis where cuenta = SUBSTR(sol.cta_ordenante,7,11) and  fech_alt BETWEEN vfecha_inic_mes and vfecha_fin_mes and transacc in ('0287','0293')) ,trim(sol.comentario) as periodicidad, sol.cta_receptora, 
		sol.cta_ordenante , trim(pro.nombre) as tipo_producto,(SELECT  telefono   FROM bdinteg:si_telefonos_actual WHERE numcte = sol.num_cte   and tipo_tel = '2') as telefono,
		 trim(est.descripcion) as descripcion, 
		(select vchrnombrecorto
		from bdinteg:si_bancos
		where cvecesif= bco_receptor),	
        sol.rfc_empresa,
		(select vchrnombrecorto
		from bdinteg:si_bancos
		where cvecesif= bco_ordenante)
		INTO can_ccanal,can_sucursal,can_nombresucursal,can_cfolio_cancelacion,can_fecha_solicitud,can_num_cliente,can_cedad,can_sueldo,can_periodicidad,can_cuenta_receptora,can_cuenta_ordenante,
        can_producto,can_ctelefono,can_cestatus, can_banco_receptor, can_rfc_empresa, can_banco_ordenante  		
		from bdicheq:   sc_portacec_solicitud sol, 
		sc_portacec_origen ori,
		bdinteg: si_sucursales suc,
		bdinteg: si_ctepf cte,
		sc_maechq  mae,
		sc_producto pro,
		sc_portacec_sentido sen,
		sc_portacec_estatus_portabilidad est
		where sol.clave_sentido='0'
		and fecha_solca_portabilidad  BETWEEN vfecha_ini_aaaammdd and vfecha_fin_aaaammdd  
		and bco_ordenante ='40137'
		and  sol.clave_origen= ori.clave_origen  
		and sol.suc_cancela=suc.sucursal
		and sol.num_cte= cte.numcte
		and SUBSTR(sol.cta_ordenante,7,11)=mae.cuenta    
		and mae.producto=pro.producto
		and sol.clave_sentido= sen.clave_sentido
		and sol.estatus_portabilidad= est.estatus_portabilidad
		
	
			INSERT INTO "informix".suc_ordencancelacion 
			( canal,sucursal,nombre_sucursal,folio_cancelacion,fecha_cancelacion ,num_cte,edad, salario ,periodicidad,cuenta_receptora, cuenta_ordenante ,producto,telefono, estatus, banco_receptor, rfc_empresa, banco_ordenante)
			VALUES  (can_ccanal,can_sucursal,can_nombresucursal,can_cfolio_cancelacion,can_fecha_solicitud,can_num_cliente,can_cedad,can_sueldo,can_periodicidad,can_cuenta_receptora,can_cuenta_ordenante,
        can_producto,can_ctelefono,can_cestatus, can_banco_receptor, can_rfc_empresa, can_banco_ordenante );
	 
	 END FOREACH;
	  
	 	  	 LET vsql = 'echo "set isolation to dirty read; unload to /resplogifx/conciliachq/Portabilidad_OrdenCancelacion_enBCPL_mes'||TRIM(cMesPeriodo)||'.txt '||
                'select canal,sucursal,nombre_sucursal,folio_cancelacion,fecha_cancelacion ,num_cte,edad, salario ,periodicidad,cuenta_receptora, cuenta_ordenante ,producto,telefono, estatus, banco_receptor, rfc_empresa, banco_ordenante from suc_ordencancelacion order by secuencia;" > /resplogifx/conciliachq/qwery_ordencancelacion.sql';
		SYSTEM vsql;
		LET vsql = '';
    
		--LET vstmt = "dbaccess bdicheq /informix/resplogifx/conciliachq/qwery_ordencancelacion.sql"; --Se activa para desarrollo

		LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/qwery_ordencancelacion.sql';
		
		
		SYSTEM vstmt;
		LET vstmt = '';



  --#######################################################
	  -- REPORTE "Tramite_Portabilidad_OtroBancoaBancoppel" 
	  --#######################################################
	 
	 
	    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'sol_portabilidad_otrobco') THEN
        DROP TABLE bdicheq:"informix".sol_portabilidad_otrobco; 
		END IF;
	 
		CREATE TABLE bdicheq:"informix".sol_portabilidad_otrobco(
	 
		 	  secuencia serial,	  
		  --canal--
		  canal               CHAR(20),
		  --Folio Solicitud--
		  folio_Solicitud     CHAR(30),
		    -- Fecha  de la solicitud --  
		  fecha_solicitud		CHAR(25),
		  -- numero de cliente --
		  num_cte             CHAR(20),
		  -- edad-
		  edad                CHAR(4),		
          -- Salario
		  salario              CHAR(10),		    
		  -- periodicidad con la que se recibe el pago --
		  periodicidad				CHAR(60),
		  --Numero de cuenta clabe receptora --
	 	  cuenta_receptora	    CHAR(20),		
		  --Numero de cuenta clabe ordenante --
		  cuenta_ordenante		  CHAR(20),
		  --tipo de producto--
		  producto 				CHAR(40),
		  --telefono--
		  telefono            CHAR(20),
		  --tipo de tramite--
		  sentido 				CHAR(40),
		   -- Fecha de respuesta --
		  fecha_respuesta     CHAR(10),
		  --estatus de portabilidad --
		  estatus				CHAR(50),
		  -- causa de aceptaciÃ³n o rechazo--
		  causa				CHAR(50),	
		  -- nombre corto del banco receptor --
		  banco_receptor 			CHAR(25),
		  --rfc de la empresa --
		  rfc_empresa 				CHAR(25),
		  -- nombre corto del banco ordenante --
		  banco_ordenante 			CHAR(25), 
		  -- prestamo personal --
		  pres_pers    CHAR(25),
		 -- tarjeta de credito --
		  tar_cred 		CHAR(25), 	
		 -- credito coppel--
		  cred_copp 		CHAR(25), 	
		  -- anticipo de nomina--
		   ant_nom 		CHAR(25),
		  -- prestamo directo de nomina --
		  pres_nomina 		CHAR(25) ) 	
		  	 		  
     EXTENT SIZE 3200 NEXT SIZE 320 LOCK MODE ROW;
	 
 	 
	 	INSERT INTO "informix".sol_portabilidad_otrobco
		  ( canal,folio_Solicitud,fecha_solicitud ,num_cte,edad,salario ,periodicidad,cuenta_receptora, cuenta_ordenante ,producto,telefono,sentido,fecha_respuesta,estatus, causa, banco_receptor, rfc_empresa, banco_ordenante, pres_pers, tar_cred, cred_copp, ant_nom, pres_nomina  )
		VALUES 	('Canal','Folio solicitud','Fecha de solicitud','Num Cliente','Edad', 'Salario','Periodicidad','cuenta CLABE Receptora','cuenta CLABE Ordenante','Tipo de producto cta','Telefono','Tipo Tramite','Fecha de Respuesta','Estatus','Causa','Banco receptor','RFC empresa','Banco ordenante','Prestamo personal','Tarjeta de credito','Credito coppel','Anticipo de nomina','Prestamo directo nomina');




 	FOREACH




		  select 'Otro Banco',sol.folio_solicitud, (SUBSTR(fecha_solicitud,7,2))||'/' ||(SUBSTR(fecha_solicitud,5,2))||'/' ||(SUBSTR(fecha_solicitud,1,4)) as fecha_sol,
                sol.num_cte,(SELECT  YEAR(Fecha_hoy) FROM bdicheq:sc_fechas WHERE empresa = '001') - year(cte.fecha_nac),
                (select sum(monto_tot) from sc_movhis where cuenta = SUBSTR(sol.cta_ordenante,7,11) and  fech_alt BETWEEN  vfecha_inic_mes and vfecha_fin_mes  and transacc in ('0287','0293')),
                sol.comentario,sol.cta_receptora, sol.cta_ordenante, trim(pro.nombre), (SELECT  telefono   FROM bdinteg:si_telefonos_actual WHERE numcte = sol.num_cte   and tipo_tel = '2') as telefono,
                trim(sen.sentido), (SUBSTR(sol.fecha_respuesta,7,2))||'/' ||(SUBSTR( sol.fecha_respuesta,5,2))||'/' ||(SUBSTR( sol.fecha_respuesta,1,4)) as fecha_resp,trim(est.descripcion) as descripcion,
                res.descripcion,
                (select vchrnombrecorto
                from bdinteg:si_bancos
                where cvecesif= bco_receptor),	
                sol.rfc_empresa,
                (select vchrnombrecorto
                from bdinteg:si_bancos
                where cvecesif= bco_ordenante),
                (select num_credito from bdicred: sd_maecredcrd where status_cred  IN ('AA','E1') and num_producto='6300'
                and numcte=sol.num_cte
                and  numcte not in ( select numcte
               from bdicred: sd_maecredcrd  cred,
                sc_portacec_solicitud sol
               where status_cred IN ('AA','E1')
               and num_producto='6300'
               and cred.numcte= sol.num_cte
               GROUP BY numcte
               HAVING COUNT(*) > 1 )
                  ) as Prestamo_Personal,
                (select num_credito from bdicred: sd_maecred where status_cred  IN ('AA','E1') and num_producto='6001'
                and numcte=sol.num_cte
                and  numcte not in ( select numcte
               from bdicred: sd_maecred  cred,
                sc_portacec_solicitud sol
               where status_cred IN ('AA','E1')
               and num_producto='6001'
               and cred.numcte= sol.num_cte
               GROUP BY numcte
               HAVING COUNT(*) > 1 )) as Tarjeta_credito,
                (select ssol.num_solicitud
                from bdisolic: ss_solicitudes ssol,
                bdisolic:   ss_resum_scor_fin resu
                where ssol.numcte= sol.num_cte
                and ssol.num_solicitud=resu.num_solicitud
                and ssol.num_producto='6500'
                and resu.linea_tienda > 0) as Credito_Coppel,
                (select num_credito
                from bdicred: sd_maecredcrd        
                where status_cred  IN ('AA','E1')
                and num_producto='6400'
                and numcte=sol.num_cte
                and  numcte not in ( select numcte
               from bdicred: sd_maecredcrd  cred,
                sc_portacec_solicitud sol
               where status_cred IN ('AA','E1')
               and num_producto='6400'
               and cred.numcte= sol.num_cte
               GROUP BY numcte
               HAVING COUNT(*) > 1 )
               ) as Pres_dir_nom,
                (select num_credito
                from bdicred: sd_maecred  
                where status_cred IN ('AA','E1')
                and num_producto='7800'
                and numcte=sol.num_cte
                and  numcte not in ( select numcte
               from bdicred: sd_maecred  cred,
                sc_portacec_solicitud sol
               where status_cred IN ('AA','E1')
               and num_producto='7800'
               and cred.numcte= sol.num_cte
               GROUP BY numcte
               HAVING COUNT(*) > 1 )
                ) as Anticipo_nomina
               INTO ccanal_obco,cfolio_solicitud_obco,cfecha_solicitud_obco,cnum_cte_obco,cedad_obco,csalario_obco,cperiodicidad_obco,ccta_receptora_obco,ccta_ordenante_obco, 
                    cproducto_obco,ctelefono_obco,csentido_obco, cfecha_respuesta_obco, cestatus_obco, ccausa_obco,cbanco_receptor_obco,crfc_empresa_obco,cbanco_ordenante_obco,
                    cpres_pers_obco, ctarj_cred_obco, ccred_coppel_obco, cant_nomina, cpres_dir_nomina_obco					 
				from bdicheq: sc_portacec_solicitud sol, 
                                       sc_maechq mae,
                                bdinteg: si_ctepf cte,
                                      sc_producto pro,
                    sc_portacec_estatus_portabilidad est,
                  sc_portacec_sentido sen,
                sc_portacec_estatus_respuesta res
                where clave_origen='3'
                and sol.bco_ordenante='40137'
                and fecha_solicitud  BETWEEN vfecha_ini_aaaammdd and vfecha_fin_aaaammdd  
                and sol.clave_sentido not in('0')
                and SUBSTR(sol.cta_ordenante,7,11)=mae.cuenta    
                and tipo_cta_ordenante='40'
                and sol.num_cte=cte.numcte
                and mae.num_cte=cte.numcte
                and mae.producto=pro.producto
                and sol.estatus_portabilidad= est.estatus_portabilidad
                and sol.clave_sentido= sen.clave_sentido
                and sol.estatus_respuesta= res.estatus_respuesta

                union all



                select 'Otro Banco', sol.folio_solicitud, (SUBSTR(fecha_solicitud,7,2))||'/' ||(SUBSTR(fecha_solicitud,5,2))||'/' ||(SUBSTR(fecha_solicitud,1,4)) as fecha_sol,
                sol.num_cte, (SELECT  YEAR(Fecha_hoy) FROM bdicheq:sc_fechas WHERE empresa = '001') - year(cte.fecha_nac),
                (select sum(monto_tot) from sc_movhis where cuenta=tar.cuenta and  fech_alt BETWEEN vfecha_inic_mes and vfecha_fin_mes  and transacc in ('0287','0293')),
                sol.comentario, sol.cta_receptora, sol.cta_ordenante ,trim(pro.nombre), (SELECT  telefono   FROM bdinteg:si_telefonos_actual WHERE numcte = sol.num_cte   and tipo_tel = '2') as telefono,
                trim(sen.sentido), (SUBSTR(sol.fecha_respuesta,7,2))||'/' ||(SUBSTR( sol.fecha_respuesta,5,2))||'/' ||(SUBSTR( sol.fecha_respuesta,1,4)) as fecha_resp ,trim(est.descripcion) as descripcion,
                res.descripcion,
                (select vchrnombrecorto
                from bdinteg:si_bancos
                where cvecesif= bco_receptor),	
                sol.rfc_empresa,
                (select vchrnombrecorto
                from bdinteg:si_bancos
                where cvecesif= bco_ordenante),         
                (select num_credito from bdicred: sd_maecredcrd where status_cred  IN ('AA','E1') and num_producto='6300'
                and numcte=sol.num_cte
                and  numcte not in ( select numcte
               from bdicred: sd_maecredcrd  cred,
                sc_portacec_solicitud sol
               where status_cred IN ('AA','E1')
               and num_producto='6300'
               and cred.numcte= sol.num_cte
               GROUP BY numcte
               HAVING COUNT(*) > 1 )
                  ) as Prestamo_Personal,
                (select num_credito from bdicred: sd_maecred where status_cred  IN ('AA','E1') and num_producto='6001'
                and numcte=sol.num_cte
                and  numcte not in ( select numcte
               from bdicred: sd_maecred  cred,
                sc_portacec_solicitud sol
               where status_cred IN ('AA','E1')
               and num_producto='6001'
               and cred.numcte= sol.num_cte
               GROUP BY numcte
               HAVING COUNT(*) > 1 )) as Tarjeta_credito,
                (select ssol.num_solicitud
                from bdisolic: ss_solicitudes ssol,
                bdisolic:   ss_resum_scor_fin resu
                where ssol.numcte= sol.num_cte
                and ssol.num_solicitud=resu.num_solicitud
                and ssol.num_producto='6500'
                and resu.linea_tienda > 0) as Credito_Coppel,
                (select num_credito
                from bdicred: sd_maecredcrd        
                where status_cred  IN ('AA','E1')
                and num_producto='6400'
                and numcte=sol.num_cte
                and  numcte not in ( select numcte
               from bdicred: sd_maecredcrd  cred,
                sc_portacec_solicitud sol
               where status_cred IN ('AA','E1')
               and num_producto='6400'
               and cred.numcte= sol.num_cte
               GROUP BY numcte
               HAVING COUNT(*) > 1 )
               ) as Pres_dir_nom,
                (select num_credito
                from bdicred: sd_maecred  
                where status_cred IN ('AA','E1')
                and num_producto='7800'
                and numcte=sol.num_cte
                and  numcte not in ( select numcte
               from bdicred: sd_maecred  cred,
                sc_portacec_solicitud sol
               where status_cred IN ('AA','E1')
               and num_producto='7800'
               and cred.numcte= sol.num_cte
               GROUP BY numcte
               HAVING COUNT(*) > 1 )
                ) as Anticipo_nomina
                from bdicheq: sc_portacec_solicitud sol,
                                       sc_tarjeta tar,
                                       sc_maechq mae,
                               bdinteg: si_ctepf cte,
                                     sc_producto pro,
                sc_portacec_estatus_portabilidad est,
                  sc_portacec_sentido sen,
                sc_portacec_estatus_respuesta res
                where clave_origen='3'
                and sol.bco_ordenante='40137'
                and fecha_solicitud   BETWEEN vfecha_ini_aaaammdd and vfecha_fin_aaaammdd  
                and sol.clave_sentido not in('0')
                and tipo_cta_ordenante='03'
                and sol.cta_ordenante=tar.num_tarjeta
                and tar.cuenta=mae.cuenta
                and sol.num_cte= cte.numcte
                and mae.producto=pro.producto
                and sol.estatus_portabilidad= est.estatus_portabilidad
                and sol.clave_sentido= sen.clave_sentido
                and sol.estatus_respuesta= res.estatus_respuesta


		INSERT INTO "informix".sol_portabilidad_otrobco
			  ( canal,folio_Solicitud,fecha_solicitud ,num_cte,edad,salario ,periodicidad,cuenta_receptora, cuenta_ordenante ,producto,telefono,sentido,fecha_respuesta,estatus, causa, banco_receptor, rfc_empresa, banco_ordenante, pres_pers, tar_cred, cred_copp, ant_nom, pres_nomina  )
		VALUES 	(ccanal_obco,cfolio_solicitud_obco,cfecha_solicitud_obco,cnum_cte_obco,cedad_obco,csalario_obco,cperiodicidad_obco,ccta_receptora_obco,ccta_ordenante_obco, cproducto_obco,ctelefono_obco,csentido_obco, cfecha_respuesta_obco, cestatus_obco, ccausa_obco,cbanco_receptor_obco,crfc_empresa_obco,cbanco_ordenante_obco,
                 cpres_pers_obco, ctarj_cred_obco, ccred_coppel_obco, cant_nomina, cpres_dir_nomina_obco);

	    END FOREACH;
	 
	 	 LET vsql = 'echo "set isolation to dirty read; unload to /resplogifx/conciliachq/Tramite_Solicitud_Portabilidad_EnOtroBanco_mes'||TRIM(cMesPeriodo)||'.txt '||
                'select canal,folio_Solicitud,fecha_solicitud ,num_cte,edad,salario ,periodicidad,cuenta_receptora, cuenta_ordenante ,producto,telefono,sentido,fecha_respuesta,estatus, causa, banco_receptor, rfc_empresa, banco_ordenante, pres_pers, tar_cred, cred_copp, ant_nom, pres_nomina from sol_portabilidad_otrobco order by secuencia;" > /resplogifx/conciliachq/qwery_EnOtroBanco.sql';
          SYSTEM vsql;
          LET vsql = '';
     
        -- LET vstmt = "dbaccess bdicheq /informix/resplogifx/conciliachq/qwery_EnOtroBanco.sql";  --Se activa para desarrollo
 
	  LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/qwery_EnOtroBanco.sql'; 

	 
     SYSTEM vstmt;
     LET vstmt = '';



 		--#######################################################
		  -- REPORTE "Portabilidad_OrdenCancelacion_otros bancos_mesX" 
		  --#######################################################
	 
		    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'ordencancelacion_otrobco') THEN
  		    DROP TABLE bdicheq:"informix".ordencancelacion_otrobco; 
		    END IF; 	
		
		
		CREATE TABLE bdicheq:"informix".ordencancelacion_otrobco(
	 
		  secuencia serial,
	 
		  --Sucursal --
		  sucursal 				CHAR(25),
		 --Nombre de la sucursal --
		  nombre_sucursal 		CHAR(40),
		   --Folio Solicitud--
		  folio_Solicitud      CHAR(30),
		   -- fecha de solicitud--
		  fech_cancelacion     CHAR(25),
		    	  --numero cliente--
		  cliente 				CHAR(25),
		  	  -- edad-
		  edad                CHAR(4),		
                  -- Salario
		  salario              CHAR(10),		    
		  -- periodicidad con la que se recibe el pago --
		  periodicidad				CHAR(60),
		  --Numero de cuenta clabe receptora --
	 	  cuenta_receptora	    CHAR(20),		
		    --tipo de producto--
		  producto 				CHAR(40),
		  	--telefono--
		  telefono            CHAR(20),
		   --Numero de cuenta ordenante --
		  cta_ordenante 		CHAR(30),
		   --rfc de la empresa --
		  rfc_empresa 			CHAR(25),
		   --Emp cte. bancoppel
		  emp_cte_bancoppel 	CHAR(25),
		 -- nombre corto del banco receptor --
		  banco_ordenante 		CHAR(25))
		  

	           EXTENT SIZE 3200 NEXT SIZE 320 LOCK MODE ROW;
		
		
		     INSERT INTO "informix".ordencancelacion_otrobco 
	            (sucursal,nombre_sucursal,folio_Solicitud, fech_cancelacion ,cliente, edad ,salario, periodicidad, cuenta_receptora,producto,telefono,cta_ordenante, rfc_empresa, emp_cte_bancoppel, banco_ordenante)
	            VALUES ('No. Sucursal','Nombre Sucursal','No. Folio','Fecha cancelacion','No. cliente', 'Edad','Salario','Periodicidad','No cuenta receptora','Tipo de producto','Telefono','No cuenta ordenante','RFC empresa','Empresa cte BCPL','Banco Ordenante');
	  
		
	  	  FOREACH
		
		
			select  sol.sucursal,  trim(suc.nombre), sol.folio_solicitud,
			(SUBSTR(fecha_solca_portabilidad,7,2))||'/' ||(SUBSTR(fecha_solca_portabilidad,5,2))||'/' ||(SUBSTR(fecha_solca_portabilidad,1,4)),
			sol.num_cte, (SELECT  YEAR(Fecha_hoy) FROM bdicheq:sc_fechas WHERE empresa = '001') - year(cte.fecha_nac), 
			(select sum(monto_tot) from sc_movhis where cuenta = SUBSTR(sol.cta_receptora,7,11) and  fech_alt BETWEEN vfecha_inic_mes and vfecha_fin_mes and transacc='0273' and referencia like '%NNNN%') ,
			sol.comentario,sol.cta_receptora, trim(pro.nombre),  (SELECT  telefono   FROM bdinteg:si_telefonos_actual WHERE numcte = sol.num_cte   and tipo_tel = '2'), sol.cta_ordenante,
			sol.rfc_empresa,
			(select  nombre
			from bdicheq: sc_nominaempresas
			where numcte= sol.num_cte),
			(select vchrnombrecorto
			from bdinteg:si_bancos
			where cvecesif= sol.bco_ordenante)  
			INTO can_sucursal_otbco,can_nombresucursal_otbco,can_cfolio_otbco,can_fecha_cancelacion_otbco,can_num_cliente_otbco,can_cedad_otbco,             
				 can_sueldo_otbco,can_periodicidad_otbco,can_cuenta_receptora_otbco,can_producto_otbco,can_ctelefono_otbco,can_cuenta_ordenante_otbco, 	
				 can_rfc_empresa_otbco,can_emp_cte_bcpl_otbco,can_banco_ordenante_otbco   
			from bdicheq:  sc_portacec_solicitud sol,
				 bdinteg: si_sucursales suc,
				 bdinteg: si_ctepf cte,
						  sc_maechq  mae,
			sc_producto pro
			where clave_sentido='0'
			and suc_cancela='OTBN.' 
			and fecha_solca_portabilidad BETWEEN vfecha_ini_aaaammdd and vfecha_fin_aaaammdd 
			and sol.sucursal=suc.sucursal
			and sol.num_cte= cte.numcte
			and SUBSTR(sol.cta_receptora,7,11)=mae.cuenta  
			and mae.producto=pro.producto

			
			 INSERT INTO "informix".ordencancelacion_otrobco 
	     (sucursal,nombre_sucursal,folio_Solicitud, fech_cancelacion ,cliente, edad ,salario, periodicidad, cuenta_receptora,producto,telefono,cta_ordenante, rfc_empresa, emp_cte_bancoppel, banco_ordenante)
	    VALUES ( can_sucursal_otbco,can_nombresucursal_otbco,can_cfolio_otbco,can_fecha_cancelacion_otbco,can_num_cliente_otbco,can_cedad_otbco,             
				 can_sueldo_otbco,can_periodicidad_otbco,can_cuenta_receptora_otbco,can_producto_otbco,can_ctelefono_otbco,can_cuenta_ordenante_otbco, 	
				 can_rfc_empresa_otbco,can_emp_cte_bcpl_otbco,can_banco_ordenante_otbco );
	
		  END FOREACH;
		 
		 
		 LET vsql = 'echo "set isolation to dirty read; unload to /resplogifx/conciliachq/Portabilidad_OrdenCancelacion_otros_bancos_mes'||TRIM(cMesPeriodo)||'.txt '||
                'select sucursal,nombre_sucursal,folio_Solicitud, fech_cancelacion ,cliente, edad ,salario, periodicidad, cuenta_receptora,producto,telefono,cta_ordenante, rfc_empresa, emp_cte_bancoppel, banco_ordenante from ordencancelacion_otrobco order by secuencia;" > /resplogifx/conciliachq/qwery_ordencancelacion_otrobco.sql';
		SYSTEM vsql;
		LET vsql = '';
    
		--LET vstmt = "dbaccess bdicheq /informix/resplogifx/conciliachq/qwery_ordencancelacion_otrobco.sql"; --Se activa para desarrollo

		LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/qwery_ordencancelacion_otrobco.sql'; 

		
		SYSTEM vstmt;
		LET vstmt = '';





 
	  --#######################################################
	  -- REPORTE "Transferencia Portabilidad_BancoppelAOtrosBancos_mesX" 
	  --#######################################################
	 
		IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'trans_bancppelotrbco') THEN
      DROP TABLE bdicheq:"informix".trans_bancppelotrbco; 
		END IF;
	 
	 
	 CREATE TABLE bdicheq:"informix".trans_bancppelotrbco(
	 
		secuencia serial, 
		  --Sucursal --
		  sucursal 				CHAR(25),
		 --Nombre de la sucursal --
		  nombre_sucursal 		CHAR(40),
		 --numero de cliente --
		  no_cliente 			CHAR(25),
		   --edad
		  Edad 	CHAR(10),
		    --salario --
		  salario		CHAR(30),
		   --Numero de cuenta --
		  cuenta		CHAR(30),	  
		  	  --cuenta clabe--	  	 
		  cuenta_clabe 				CHAR(40),
		  	  --ntipo de producto-
		  producto 				CHAR(30),
		  --Numero de cuenta receptora --
		  cta_receptora 		CHAR(25),
		   -- nombre corto del banco receptor --
		  banco_receptor 		CHAR(25), 		  
		  	 -- prestamo personal --
		  pres_pers    CHAR(25),
		 -- tarjeta de credito --
		  tar_cred 		CHAR(25), 	
		 -- credito coppel--
		  cred_copp 		CHAR(25), 	
		  -- anticipo de nomina--
		   ant_nom 		CHAR(25),
		  -- prestamo directo de nomina --
		  pres_nomina 		CHAR(25)		
		  ) 						
		  
	  EXTENT SIZE 3200 NEXT SIZE 320 LOCK MODE ROW;
	  
	 
	 
	  INSERT INTO "informix".trans_bancppelotrbco 
	         (sucursal,nombre_sucursal,no_cliente, Edad ,salario, cuenta ,cuenta_clabe, producto, cta_receptora,banco_receptor, pres_pers, tar_cred, cred_copp, ant_nom ,pres_nomina)
	  VALUES ('No. Sucursal','Nombre Sucursal','No. cliente','Edad','salario', 'Cuenta Ordenante ','Cuenta Clabe Ordenante','Tipo de Producto','No cuenta receptora','Banco receptor','PrÃ©stamo Personal ','Tarjeta de CrÃ©dito','CrÃ©dito Coppel', 'Anticipo de NÃ²mina','Prestamo Directo NÃ³mina');
	
		
		
		set isolation to dirty read;		
		select * from bdispei: tblhistpago
		where  dtfechavalor BETWEEN vfecha_inic_mes and vfecha_fin_mes  
		and  chrsentidopago='E'
		INTO TEMP paso_porta WITH NO LOG;

		CREATE INDEX idx_paso_porta ON paso_porta(vchrcuentaord);
		UPDATE STATISTICS MEDIUM FOR TABLE paso_porta;
				
		
		set isolation to dirty read;
		select distinct(vchrcuentaord) as vchrcuentaord, vchrcuentabenef,
		(select vchrnombrecorto
		from bdinteg:si_bancos
		where cvecesif= cvecesifbcodest) as banco_rec
		from bdicheq: paso_porta 	
		where vchrconceptopago2 like '%PORTABILIDAD DE NOMINA%'
		and  chrsentidopago='E'
		and dtfechavalor BETWEEN vfecha_inic_mes and vfecha_fin_mes  
		INTO TEMP paso_porta2 WITH NO LOG;
				
		
		CREATE INDEX idx_paso_porta2 ON paso_porta2(vchrcuentaord);
		UPDATE STATISTICS MEDIUM FOR TABLE paso_porta2;
		
		
		
		set isolation to dirty read;
		select mae.cuenta,mae.sucursal,mae.producto ,mae.num_cte
		 from  BDICHEQ: paso_porta2 paso , 
		sc_maechq mae
		where mae.cuenta=SUBSTR(paso.vchrcuentaord,7,11)   
		INTO TEMP paso_maechq WITH NO LOG;


		CREATE INDEX idx_paso_maechq ON paso_maechq(cuenta);
		UPDATE STATISTICS MEDIUM FOR TABLE paso_maechq;

		
	
 	FOREACH	

							
				select mae.sucursal, trim(suc.nombre), mae.num_cte,
				(SELECT  YEAR(Fecha_hoy) FROM bdicheq:sc_fechas WHERE empresa = '001') - year(cte.fecha_nac),
				(select sum(monto_tot) from sc_movhis where cuenta = SUBSTR(paso.vchrcuentaord,7,11) and  fech_alt BETWEEN vfecha_inic_mes and vfecha_fin_mes  and transacc='0274' and referencia like '%NNNN%'),
				SUBSTR(paso.vchrcuentaord,7,11), paso.vchrcuentaord, trim(pro.nombre) ,paso.vchrcuentabenef, paso.banco_rec,
				(select num_credito from bdicred: sd_maecredcrd where status_cred  IN ('AA','E1') and num_producto='6300'
								and numcte=mae.num_cte
								and  numcte not in ( select numcte
							   from bdicred: sd_maecredcrd  cred,
								paso_maechq mae
							   where status_cred IN ('AA','E1')
							   and num_producto='6300'
							   and cred.numcte= mae.num_cte
							   GROUP BY numcte
							   HAVING COUNT(*) > 1 )
								  ) as Prestamo_Personal,
								(select num_credito from bdicred: sd_maecred where status_cred  IN ('AA','E1') and num_producto='6001'
								and numcte=mae.num_cte
								and  numcte not in ( select numcte
							   from bdicred: sd_maecred  cred,
								paso_maechq mae
							   where status_cred IN ('AA','E1')
							   and num_producto='6001'
							   and cred.numcte= mae.num_cte
							   GROUP BY numcte
							   HAVING COUNT(*) > 1 )) as Tarjeta_credito,
								(select ssol.num_solicitud
								from bdisolic: ss_solicitudes ssol,
								bdisolic:   ss_resum_scor_fin resu
								where ssol.numcte= mae.num_cte
								and ssol.num_solicitud=resu.num_solicitud
								and ssol.num_producto='6500'
								and resu.linea_tienda > 0) as Credito_Coppel,
								(select num_credito
								from bdicred: sd_maecredcrd        
								where status_cred  IN ('AA','E1')
								and num_producto='6400'
								and numcte=mae.num_cte
								and  numcte not in ( select numcte
							   from bdicred: sd_maecredcrd  cred,
								paso_maechq mae
							   where status_cred IN ('AA','E1')
							   and num_producto='6400'
							   and cred.numcte= mae.num_cte
							   GROUP BY numcte
							   HAVING COUNT(*) > 1 )
							   ) as Pres_dir_nom,
								(select num_credito
								from bdicred: sd_maecred  
								where status_cred IN ('AA','E1')
								and num_producto='7800'
								and numcte=mae.num_cte
								and  numcte not in ( select numcte
							   from bdicred: sd_maecred  cred,
								paso_maechq mae
							   where status_cred IN ('AA','E1')
							   and num_producto='7800'
							   and cred.numcte= mae.num_cte
							   GROUP BY numcte
							   HAVING COUNT(*) > 1 )
								) as Anticipo_nomina
				INTO tran_sucursal,tran_nombresucursal,tran_num_cliente,tran_edad,tran_sueldo,tran_cuenta_ordenante,tran_cuenta_clabe_ordenante,tran_producto,tran_cuenta_receptora,tran_banco_receptor,tran_pres_pers,tran_tarj_cred,tran_cred_coppel,tran_pres_dir_nomina,tran_ant_nomina
				from  BDICHEQ: paso_porta2  paso,
							  paso_maechq mae,
							 bdinteg: si_sucursales suc,
				  bdinteg: si_ctepf cte,
						 sc_producto pro
				where SUBSTR(paso.vchrcuentaord,7,11)=mae.cuenta   
				and mae.sucursal=suc.sucursal
				and mae.num_cte= cte.numcte
				and mae.producto=pro.producto
						
						
							INSERT INTO "informix".trans_bancppelotrbco
					   (sucursal,nombre_sucursal,no_cliente, Edad ,salario, cuenta ,cuenta_clabe, producto, cta_receptora,banco_receptor, pres_pers, tar_cred, cred_copp, ant_nom ,pres_nomina)
				VALUES (tran_sucursal,tran_nombresucursal,tran_num_cliente,tran_edad,tran_sueldo,tran_cuenta_ordenante,tran_cuenta_clabe_ordenante,tran_producto, 			
						tran_cuenta_receptora,tran_banco_receptor,tran_pres_pers,tran_tarj_cred,tran_cred_coppel,tran_pres_dir_nomina,tran_ant_nomina	 );	
				
	
						
			 END FOREACH;
		 
		 
		 LET vsql = 'echo "set isolation to dirty read; unload to /resplogifx/conciliachq/Portabilidad_BanCoppelAOtrosBancos_ACUM_mes'||TRIM(cMesPeriodo)||'.txt '||
                'select sucursal,nombre_sucursal,no_cliente, Edad ,salario, cuenta ,cuenta_clabe, producto, cta_receptora,banco_receptor, pres_pers, tar_cred, cred_copp, ant_nom ,pres_nomina from trans_bancppelotrbco order by secuencia;" > /resplogifx/conciliachq/qwery_transbcoppelotrbnc.sql';
		SYSTEM vsql;
		LET vsql = '';
    
		--LET vstmt = "dbaccess bdicheq /informix/resplogifx/conciliachq/qwery_transbcoppelotrbnc.sql"; --Se activa para desarrollo

		LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/qwery_transbcoppelotrbnc.sql'; 

		
		SYSTEM vstmt;
		LET vstmt = '';
		
					
			 --#######################################################
			 -- REPORTE "Transferencia Portabilidad_OtroBancoABancoppel_mesX" 
			 --#######################################################
				 
			IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'trans_otrbcoabancppel') THEN
			DROP TABLE bdicheq:"informix".trans_otrbcoabancppel; 
			END IF;
				 
				 
				 CREATE TABLE bdicheq:"informix".trans_otrbcoabancppel(
				 
						secuencia serial, 
						  --Sucursal --
						  sucursal 				CHAR(25),
						 --Nombre de la sucursal --
						  nombre_sucursal 		CHAR(40),
						 --numero de cliente --
						  no_cliente 			CHAR(25),
						   --edad
						  Edad 	CHAR(10),
							--salario --
						  salario		CHAR(30),
						   --Numero de cuenta --
						  cuenta		CHAR(30),	  
							  --cuenta clabe--	  	 
						  cuenta_clabe 				CHAR(40),
							  --ntipo de producto-
						  producto 				CHAR(30),
						  --Numero de cuenta receptora --
						  cta_receptora 		CHAR(25),
						   -- nombre corto del banco receptor --
						  banco_receptor 		CHAR(25), 		  
							 -- prestamo personal --
						  pres_pers    CHAR(25),
						 -- tarjeta de credito --
						  tar_cred 		CHAR(25), 	
						 -- credito coppel--
						  cred_copp 		CHAR(25), 	
						  -- anticipo de nomina--
						   ant_nom 		CHAR(25),
						  -- prestamo directo de nomina --
						  pres_nomina 		CHAR(25)		
						  ) 						
					  
				  EXTENT SIZE 3200 NEXT SIZE 320 LOCK MODE ROW;
				 

				  INSERT INTO "informix".trans_otrbcoabancppel 
				         (sucursal,nombre_sucursal,no_cliente, Edad ,salario, cuenta ,cuenta_clabe, producto, cta_receptora,banco_receptor, pres_pers, tar_cred, cred_copp, ant_nom ,pres_nomina)
	  VALUES ('No. Sucursal','Nombre Sucursal','No. cliente','Edad','salario', 'Cuenta Receptora','Cuenta Clabe Receptora','Tipo de Producto','No cuenta Ordenante','Banco Ordenante','PrÃ©stamo Personal ','Tarjeta de CrÃ©dito','CrÃ©dito Coppel', 'Anticipo de NÃ²mina','Prestamo Directo NÃ³mina');
	
					
					
					
					set isolation to dirty read;	
					select * from bdispei: tblhistpago
					where  dtfechavalor BETWEEN vfecha_inic_mes and vfecha_fin_mes 
					and  chrsentidopago='R'
					INTO TEMP paso_porta3 WITH NO LOG;

					CREATE INDEX idx_paso_porta3 ON paso_porta3(vchrcuentabenef);
					UPDATE STATISTICS MEDIUM FOR TABLE paso_porta3;
							
		
		
					set isolation to dirty read;
					select distinct(vchrcuentabenef) as vchrcuentabenef, vchrcuentaord,
					(select vchrnombrecorto
					from bdinteg:si_bancos
					where cvecesif= cvecesifbcoord) as banco_ord
					from bdicheq: paso_porta3 	
					where vchrconceptopago like '%PORTABILIDAD DE NOMINA%'
					and  chrsentidopago='R'
					and dtfechavalor BETWEEN vfecha_inic_mes and vfecha_fin_mes 
					INTO TEMP paso_porta4 WITH NO LOG;



					CREATE INDEX idx_paso_porta4 ON paso_porta4(vchrcuentabenef);
					UPDATE STATISTICS MEDIUM FOR TABLE paso_porta4;
					


					set isolation to dirty read;
					select mae.cuenta,mae.sucursal,mae.producto ,mae.num_cte
					 from  BDICHEQ: paso_porta4 paso , 
					sc_maechq mae
					where mae.cuenta=SUBSTR(paso.vchrcuentabenef,7,11)   
					INTO TEMP paso_maechq2 WITH NO LOG;


					CREATE INDEX idx_paso_maechq2 ON paso_maechq2(cuenta);
					UPDATE STATISTICS MEDIUM FOR TABLE paso_maechq2;



			FOREACH	
		
					select mae.sucursal, trim(suc.nombre), mae.num_cte,
						(SELECT  YEAR(Fecha_hoy) FROM bdicheq:sc_fechas WHERE empresa = '001') - year(cte.fecha_nac),
						(select sum(monto_tot) from sc_movhis where cuenta = SUBSTR(paso.vchrcuentabenef,7,11) and  fech_alt BETWEEN vfecha_inic_mes and vfecha_fin_mes  and transacc='0273' and referencia like '%NNNN%'),
						SUBSTR(paso.vchrcuentabenef,7,11), paso.vchrcuentabenef, trim(pro.nombre) ,paso.vchrcuentaord, paso.banco_ord,
						(select num_credito from bdicred: sd_maecredcrd where status_cred  IN ('AA','E1') and num_producto='6300'
										and numcte=mae.num_cte
										and  numcte not in ( select numcte
									   from bdicred: sd_maecredcrd  cred,
										paso_maechq2 mae
									   where status_cred IN ('AA','E1')
									   and num_producto='6300'
									   and cred.numcte= mae.num_cte
									   GROUP BY numcte
									   HAVING COUNT(*) > 1 )
										  ) as Prestamo_Personal,
										(select num_credito from bdicred: sd_maecred where status_cred  IN ('AA','E1') and num_producto='6001'
										and numcte=mae.num_cte
										and  numcte not in ( select numcte
									   from bdicred: sd_maecred  cred,
										paso_maechq2 mae
									   where status_cred IN ('AA','E1')
									   and num_producto='6001'
									   and cred.numcte= mae.num_cte
									   GROUP BY numcte
									   HAVING COUNT(*) > 1 )) as Tarjeta_credito,
										(select ssol.num_solicitud
										from bdisolic: ss_solicitudes ssol,
										bdisolic:   ss_resum_scor_fin resu
										where ssol.numcte= mae.num_cte
										and ssol.num_solicitud=resu.num_solicitud
										and ssol.num_producto='6500'
										and resu.linea_tienda > 0) as Credito_Coppel,
										(select num_credito
										from bdicred: sd_maecredcrd        
										where status_cred  IN ('AA','E1')
										and num_producto='6400'
										and numcte=mae.num_cte
										and  numcte not in ( select numcte
									   from bdicred: sd_maecredcrd  cred,
										paso_maechq2 mae
									   where status_cred IN ('AA','E1')
									   and num_producto='6400'
									   and cred.numcte= mae.num_cte
									   GROUP BY numcte
									   HAVING COUNT(*) > 1 )
									   ) as Pres_dir_nom,
										(select num_credito
										from bdicred: sd_maecred  
										where status_cred IN ('AA','E1')
										and num_producto='7800'
										and numcte=mae.num_cte
										and  numcte not in ( select numcte
									   from bdicred: sd_maecred  cred,
										paso_maechq2 mae
									   where status_cred IN ('AA','E1')
									   and num_producto='7800'
									   and cred.numcte= mae.num_cte
									   GROUP BY numcte
									   HAVING COUNT(*) > 1 )
										) as Anticipo_nomina
					    	INTO 	 tran_OtroaBan_sucursal,tran_OtroaBan_nombresucursal,tran_OtroaBan_num_cliente,tran_OtroaBan_edad,tran_OtroaBan_sueldo,tran_OtroaBan_cuenta_ordenante,tran_OtroaBan_cuenta_clabe_ordenante, 	
									tran_OtroaBan_producto,tran_OtroaBan_cuenta_receptora,tran_OtroaBan_banco_receptor,tran_OtroaBan_pres_pers,tran_OtroaBan_tarj_cred,tran_OtroaBan_cred_coppel,tran_OtroaBan_pres_dir_nomina,tran_OtroaBan_ant_nomina			 					
						from  BDICHEQ: paso_porta4  paso,
									  paso_maechq2 mae,
									 bdinteg: si_sucursales suc,
						  bdinteg: si_ctepf cte,
								 sc_producto pro
						where SUBSTR(paso.vchrcuentabenef,7,11)=mae.cuenta   
						and mae.sucursal=suc.sucursal
						and mae.num_cte= cte.numcte
						and mae.producto=pro.producto
					
					
						INSERT INTO "informix".trans_otrbcoabancppel 
				         (sucursal,nombre_sucursal,no_cliente, Edad ,salario, cuenta ,cuenta_clabe, producto, cta_receptora,banco_receptor, pres_pers, tar_cred, cred_copp, ant_nom ,pres_nomina)
						VALUES (tran_OtroaBan_sucursal,tran_OtroaBan_nombresucursal,tran_OtroaBan_num_cliente,tran_OtroaBan_edad,tran_OtroaBan_sueldo,tran_OtroaBan_cuenta_ordenante,tran_OtroaBan_cuenta_clabe_ordenante, 	
								tran_OtroaBan_producto,tran_OtroaBan_cuenta_receptora,tran_OtroaBan_banco_receptor,tran_OtroaBan_pres_pers,tran_OtroaBan_tarj_cred,tran_OtroaBan_cred_coppel,tran_OtroaBan_pres_dir_nomina,tran_OtroaBan_ant_nomina);
	

			 END FOREACH;
					
				
					 LET vsql = 'echo "set isolation to dirty read; unload to /resplogifx/conciliachq/Portabilidad_OtroBancoABancoppel_ACUM_mes'||TRIM(cMesPeriodo)||'.txt '||
                'select sucursal,nombre_sucursal,no_cliente, Edad ,salario, cuenta ,cuenta_clabe, producto, cta_receptora,banco_receptor, pres_pers, tar_cred, cred_copp, ant_nom ,pres_nomina  from trans_otrbcoabancppel order by secuencia;" > /resplogifx/conciliachq/qwery_otrbcoabancppel.sql';
		SYSTEM vsql;
		LET vsql = '';
    
		--LET vstmt = "dbaccess bdicheq /informix/resplogifx/conciliachq/qwery_otrbcoabancppel.sql";  --Se activa para desarrollo
		
		LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/qwery_otrbcoabancppel.sql'; 
			

		SYSTEM vstmt;
		LET vstmt = '';
	 	 			
																
      END;
    
    RETURN vcodret1;
    
	END PROCEDURE;