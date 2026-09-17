CREATE PROCEDURE "informix".sp_repdiarioretencion()
    RETURNING
		CHAR(6) 		AS COD_RET,
		CHAR(80)		AS MENSAJE_RET;
    ---DECLARACIONES
		DEFINE iSqlErr			    INTEGER;
		DEFINE iIsamErr				INTEGER;
		DEFINE cTabla		      	CHAR(1);
		DEFINE v_empresa            CHAR(3);
		DEFINE cProceso             CHAR(4);
		DEFINE cCodRet,vvcCod_ret	CHAR(6);
		DEFINE cMensajeRet          CHAR(80);
		DEFINE cNombreArchivo       CHAR(80);
		DEFINE cRuta			    CHAR(80);
		DEFINE cConsulta		  	CHAR(2200);
		DEFINE cSql           		CHAR(1024);
		DEFINE dtFechaHoy           DATE;
		--DEFINE conDatos             INTEGER;
		---INICIALIZACIONES
		LET iSqlErr         = 0;   
		LET iIsamErr        = 0; 
		LET cCodRet         = "000000";
		LET cMensajeRet	    = "Proceso exitoso";
		LET cNombreArchivo 	= "Clientesretenidos_";   
		LET cTabla	        = "N"; 
		LET cConsulta		= ""; 
		LET cSql	        = ""; 
		LET cRuta	        = "";
		LET v_empresa       = '001';
		LET dtFechaHoy      = "";
		-- conDatos        = 0;
		
		BEGIN
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

--		SET DEBUG FILE TO "/informix/German/sp_repDiarioRetencion.out";
--		TRACE ON;
		--SE BORRAN LAS TABLAS TEMPORALES SI EXISTEN.
		--IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_detallerepdiario" AND dbsname= "bdicred" AND partnum >1048577) THEN
		IF (SELECT COUNT(tabname) FROM sysmaster:systabnames WHERE tabname = "tmp_detallerepdiario" AND dbsname= "bdicred" AND partnum >1048577) > 0 THEN
			DROP  TABLE tmp_detallerepdiario;
		END IF;	
		
		--SE OBTIENE LA RUTA DE SI_PARAM.
        SELECT valor 
		INTO cRuta
		FROM bdinteg:"informix".si_param 
		WHERE cod_param = 503;
        --SE DEFINE EL NOMBRE DEL ARCHIVO EXCEL
        LET  cRuta = "/RESPALDOS" || cRuta || '/';
         --LET  cRuta = '/informix/resplogifx/archivoscredito/';

		--DETERMINACION DE FECHA CORTE:
		SELECT fecha_hoy
		  INTO dtFechaHoy
		  FROM bdicred:"informix".sd_fechas
          WHERE empresa = v_empresa;
		
        select distinct(trim(sic.nombre1) || ' ' || trim(sic.nombre2) || ' ' || trim(sic.apell_paterno) || ' ' || trim(sic.apell_materno)) nombre
            , sdbr.numcte numcte, sdbr.num_credito numcredito, sdbr.motivo_cancelacion motivo, sit.telefono celular, sico.correo_elec correo, 
            (to_char(sdbr.fecha,  '%d/%m/%y') ||' '||sdbr.hora_fin) fechahora
        from sd_bitacora_retencion sdbr, bdinteg: si_cliente sic, bdinteg: si_telefonos_actual sit,
            bdinteg:si_correos sico
        where sdbr.numcte = sic.numcte 
        and sic.numcte = sit.numcte 
        and sic.numcte = sico.numcte
        and sit.tipo_tel = 2
        and sdbr.acepta_recompensa = 't'
        and sdbr.fecha = dtFechaHoy
        into tmp_detallerepdiario; 
        
        --SE VALIDA QUE LA TABLA TEMPORAL SE HAYA CARGADO CON LOS DATOS
       -- select count(*) 
        --into conDatos
        --from tmp_detallerepdiario;
        
       -- if conDatos > 0 then
            LET cNombreArchivo = TRIM(cNombreArchivo)||YEAR(dtFechaHoy)||LPAD(MONTH(dtFechaHoy),2,0)||LPAD(DAY(dtFechaHoy),2,0);
            LET cConsulta = "SELECT nombre, numcte, numcredito, motivo, celular, correo, fechahora FROM tmp_detallerepdiario";		
            LET cSql = '';
            LET cSql = 'echo "UNLOAD TO ' ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.xls'|| ' DELIMITER '|| '''	'''||' '||TRIM(cConsulta)||'" > '|| TRIM(cRuta) ||'query1.sql';
            --LET cSql = 'echo "UNLOAD TO ' ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.xls'|| ' DELIMITER '|| '''	'''||' '||TRIM(cConsulta);
            SYSTEM TRIM(cSql);
            
            LET cSql = '';
            LET cSql = "dbaccess bdicred " ||TRIM(cRuta)||'query1.sql';
            SYSTEM cSql;
            LET cSql = '';
            LET cSQL = "rm " ||TRIM(cRuta)||'query1.sql';	
            SYSTEM cSql; 
            --let cTabla = 'S';
		--else
		  --  let cCodRet = '00001';
		  --  let cMensajeRet = 'NO HAY DATOS GENERADOS ESTE DIA ' + dtFechaHoy;
		    --return cCodRet, cMensajeRet;
		--end if;
		IF cTabla="S" THEN
				DROP TABLE bdicobranza:"informix".tmp_detallerepdiario;
		END IF;
		LET cMensajeRet = TRIM(cNombreArchivo)||'.xls';
		
    RETURN cCodRet, cMensajeRet;
		
	END;
END PROCEDURE
DOCUMENT
"Procedimiento para generacion de archivo excel con recompensas aceptadas cedula de retencion",
"Creado por Luis GermÃ¡n Viveros Andrade 2022-02-22";

CREATE PROCEDURE "informix".respaldacredito()
   RETURNING CHAR(5);   --CodRet
                                                                                
                                                                                
   DEFINE CodRet              CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE nrows               SMALLINT;
   DEFINE Mensaje             CHAR(80);
   --AAME INC 27 108
   DEFINE cnumcredito             CHAR(20);
                                                                                
   DEFINE wSecuenciaPago      LIKE sd_secpago.secuencia;                        
                                                                                
   DEFINE GLOBAL g_Empresa    CHAR(3)  DEFAULT ' ';                             
   DEFINE GLOBAL g_NumCredito CHAR(20) DEFAULT ' ';                             
   DEFINE GLOBAL g_Folio      CHAR(16) DEFAULT ' ';                             
                                                                                
   LET CodRet = "000";  
	--AAME INC 27 108   
   LET cnumcredito = '';
   
   	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ; 
	
	
   SELECT MAX(secuencia)                                                        
     INTO wSecuenciaPago                                                        
     FROM sd_secpago                                                            
    WHERE empresa = g_Empresa                                                   
      AND num_credito = g_NumCredito; 

--set debug file to "respaldacredito.out";
--trace on;
  
                                                                                
   IF(wSecuenciaPago = 0 OR wSecuenciaPago IS NULL) THEN                        
      LET wSecuenciaPago = 0;                                                   
   END IF;                                                                      
                                                                                
   LET wSecuenciaPago = wSecuenciaPago + 1;                                     
	--AAME INC 27 108 Se agrega validacion para que inserte siempre y cuando no se tenga ya el respaldo del folio a consultar
	SELECT count(num_credito) INTO cnumcredito FROM "informix".sd_secpago WHERE num_credito = g_NumCredito AND folio_suc = g_Folio;
	IF cnumcredito = 0 THEN
	   INSERT INTO                                                                  
		  sd_secpago (empresa, num_credito, folio_suc, secuencia)                   
	   VALUES                                                                       
		  (g_empresa, g_NumCredito, g_Folio, wSecuenciaPago);                       
																			
	-------------------------------------------------------                         
	--    RESPALDO DE MAECRED                            --                         
	-------------------------------------------------------                         
	   INSERT INTO                                                                  
		  sd_maecredrev                                                             
			(empresa,                                                               
			 num_credito,                                                           
			 folio,                                                                 
			 num_producto,                                                          
			 ejecutivo,                                                             
			 numcte,                                                                
			 divisa,                                                                
			 sucursal,                                                              
			 id_origen,                                                             
			 origen,                                                                
			 cod_tipo_linea,                                                        
			 cod_linea,                                                             
			 porc_rec_prop,                                                         
			 status_cred,                                                           
			 bandera_renovac,                                                       
			 bandera_prorroga,                                                      
			 periodo_plazo,                                                         
			 plazo,                                                                 
			 fecha_apertura,                                                        
			 fecha_vencim,                                                          
			 period_pago_cap,                                                       
			 period_pag_int,                                                        
			 dias_trasp_cap,                                                        
			 dias_trasp_int,                                                        
			 tasa_fija_o_var,                                                       
			 cod_tasa_base,                                                         
			 factor_sobretasa,                                                      
			 sobretasa,                                                             
			 tasa_interes,                                                          
			 cod_tasa_mora,                                                         
			 sobretasa_mora,                                                        
			 fact_sobret_mora,                                                      
			 tasa_moratorios,                                                       
			 fecha_pago_cap,                                                        
			 fecha_pago_int,                                                        
			 es_fisica,                                                             
			 bandera_fi_fo,                                                         
			 codigo_pro,                                                            
			 superficie,                                                            
			 actividad,                                                             
			 cal_edos_fin,                                                          
			 tipo_calculo,                                                          
			 admite_tlp,                                                            
			 rel_garcred,                                                           
			 id_unidad_prod,                                                        
			 num_aper_ant,                                                          
			 rev_tasa_var_per,                                                      
			 dia_para_revisar,                                                      
			 cod_prod,                                                              
			 bandera_ministra,                                                      
			 num_fideicomiso,                                                       
			 credito_externo,                                                       
			 gracia_capital,                                                        
			 diferimiento_int,                                                      
			 fecha_fin_prorrateo,                                                   
			 campo_trab1,                                                           
			 campo_trab2,                                                           
			 campo_trab3,                                                           
			 campo_trab4,                                                           
			 calificacion_riesgo,                                                   
			 cod_agricola,                                                          
			 tasa_base_piso,                                                        
			 sobretasa_piso,                                                        
			 factor_piso,                                                           
			 tasa_piso,                                                             
			 tasa_base_techo,                                                       
			 sobretasa_techo,                                                       
			 factor_techo,                                                          
			 tasa_techo,
			 cod_caract,
			 cod_caract_2
			 ,cuenta_clabe)                                                            
	   SELECT                                                                       
			empresa,                                                                
			 num_credito,                                                           
			 g_folio,                                                               
			 num_producto,                                                          
			 ejecutivo,                                                             
			 numcte,                                                                
			 divisa,                                                                
			 sucursal,                                                              
			 id_origen,                                                             
			 origen,                                                                
			 cod_tipo_linea,                                                        
			 cod_linea,                                                             
			 porc_rec_prop,                                                         
			 status_cred,                                                           
			 bandera_renovac,                                                       
			 bandera_prorroga,                                                      
			 periodo_plazo,                                                         
			 plazo,                                                                 
			 fecha_apertura,                                                        
			 fecha_vencim,                                                          
			 period_pago_cap,                                                       
			 period_pag_int,                                                        
			 dias_trasp_cap,                                                        
			 dias_trasp_int,                                                        
			 tasa_fija_o_var,                                                       
			 cod_tasa_base,                                                         
			 factor_sobretasa,                                                      
			 sobretasa,                                                             
			 tasa_interes,                                                          
			 cod_tasa_mora,                                                         
			 sobretasa_mora,                                                        
			 fact_sobret_mora,                                                      
			 tasa_moratorios,                                                       
			 fecha_pago_cap,                                                        
			 fecha_pago_int,                                                        
			 es_fisica,                                                             
			 bandera_fi_fo,                                                         
			 codigo_pro,                                                            
			 superficie,                                                            
			 actividad,                                                             
			 cal_edos_fin,                                                          
			 tipo_calculo,                                                          
			 admite_tlp,                                                            
			 rel_garcred,                                                           
			 id_unidad_prod,                                                        
			 num_aper_ant,                                                          
			 rev_tasa_var_per,                                                      
			 dia_para_revisar,                                                      
			 cod_prod,                                                              
			 bandera_ministra,                                                      
			 num_fideicomiso,                                                       
			 credito_externo,                                                       
			 gracia_capital,                                                        
			 diferimiento_int,                                                      
			 fecha_fin_prorrateo,                                                   
			 campo_trab1,                                                           
			 campo_trab2,                                                           
			 campo_trab3,                                                           
			 campo_trab4,                                                           
			 calificacion_riesgo,                                                   
			 cod_agricola,                                                          
			 tasa_base_piso,                                                        
			 sobretasa_piso,                                                        
			 factor_piso,                                                           
			 tasa_piso,                                                             
			 tasa_base_techo,                                                       
			 sobretasa_techo,                                                       
			 factor_techo,                                                          
			 tasa_techo,         
			 cod_caract,
			 cod_caract_2  
			 ,cuenta_clabe			 
	   FROM                                                                         
		sd_maecred                                                                  
	   WHERE                                                                        
		 num_credito = g_NumCredito                                                 
	   AND                                                                          
		 empresa = g_Empresa;                                                       
																					
	----------------------------------------------------------                      
	--            RESPALDO DE MAESDOS                                               
	----------------------------------------------------------                      
	   INSERT INTO                                
		  sd_maesdosrev                           
			 (empresa,                            
			  num_credito,                        
			  folio,                              
			  fecha_ult_mov,                      
			  sdo_int_anticip,                    
			  sdo_int_ant_dev,                    
			  sdo_intereses,                      
			  sdo_dia_ant_int,                    
			  sdo_mes_ant_int,                    
			  sdo_acum_mes_int,                   
			  sdo_retenido,                       
			  sdo_acum_cap_int,                   
			  sdo_exig_int,                       
			  sdo_no_exig,                        
			  provision_normal,                                                     
			  dias_acum_int,                                                        
			  sdo_moratorio,                                                        
			  sdo_dia_ant_mor,                                                      
			  sdo_mes_ant_mor,                                                      
			  sdo_contab_mora,                                                      
			  dias_acum_mora,                                                       
			  sdo_capital,                                                          
			  sdo_cap_insoluto,                                                     
			  sdo_dia_ant_cap,                                                      
			  sdo_mes_ant_cap,                                                      
			  sdo_acum_mes_cap,                                                     
			  mto_capitalizado,                                                     
			  mto_ministra_cap,                                                     
			  cargos_dia_cap,                                                       
			  abonos_dia_cap,                                                       
			  cargos_mes_cap,                                                       
			  abonos_mes_cap,                                                       
			  dias_acum_cap,                                                        
			  monto_vencido,                                                        
			  mto_venc_trasp,                                                       
			  monto_financiado,                                                     
			  monto_reservado,                                                      
			  sdo_acum_vencido,                                                     
			  dias_acum_intper,                                                     
			  sdo_global_int,                                                       
			  sdo_acum_intper,                                                      
			  monto_otorgado,                                                       
			  provi_venc_normal,                                                    
			  provi_venc_anticip,                                                   
			  cap_tras_no_venci,                                                    
			  mto_venc_int,                                                         
			  mto_venc_tra_int,                                                     
			  mto_finan_vdo,                                                        
			  mto_reser_int,                                                        
			  mto_fin_ven_trasp,                                                    
			  mto_fin_vig_trasp,                                                    
			  int_tra_no_exig,                                                      
			  sdo_trab4,
			  act)                                                            
	   SELECT                                                                       
			  empresa,                                                              
			  num_credito,                                                          
			  g_Folio,                                                              
			  fecha_ult_mov,                                                        
			  sdo_int_anticip,                                                      
			  sdo_int_ant_dev,                                                      
			  sdo_intereses,                                                        
			  sdo_dia_ant_int,                                                      
			  sdo_mes_ant_int,                                                      
			  sdo_acum_mes_int,                                                     
			  sdo_retenido,                                                         
			  sdo_acum_cap_int,                                                     
			  sdo_exig_int,                                                         
			  sdo_no_exig,                                                          
			  provision_normal,                                                     
			  dias_acum_int,                                                        
			  sdo_moratorio,                                                        
			  sdo_dia_ant_mor,                                                      
			  sdo_mes_ant_mor,                                                      
			  sdo_contab_mora,                                                      
			  dias_acum_mora,                                                       
			  sdo_capital,                                                          
			  sdo_cap_insoluto,                                                     
			  sdo_dia_ant_cap,                                                      
			  sdo_mes_ant_cap,                                                      
			  sdo_acum_mes_cap,                                                     
			  mto_capitalizado,                                                     
			  mto_ministra_cap,                                                     
			  cargos_dia_cap,                                                       
			  abonos_dia_cap,                                                       
			  cargos_mes_cap,                                                       
			  abonos_mes_cap,                                                       
			  dias_acum_cap,                                                        
			  monto_vencido,                                                        
			  mto_venc_trasp,                                                       
			  monto_financiado,                                                     
			  monto_reservado,                                                      
			  sdo_acum_vencido,                                                     
			  dias_acum_intper,                                                     
			  sdo_global_int,                                                       
			  sdo_acum_intper,                                                      
			  monto_otorgado,                                                       
			  provi_venc_normal,                                                    
			  provi_venc_anticip,                                                   
			  cap_tras_no_venci,                                                    
			  mto_venc_int,                                                         
			  mto_venc_tra_int,                                                     
			  mto_finan_vdo,                                                        
			  mto_reser_int,                                                        
			  mto_fin_ven_trasp,                                                    
			  mto_fin_vig_trasp,                                                    
			  int_tra_no_exig,                                                      
			  sdo_trab4,
			  act                                                           
	   FROM sd_maesdos                                                              
	   WHERE empresa     = g_Empresa                                                
	   AND num_credito = g_NumCredito;                                              
																					
																					
	-------------------------------------                                           
	-- Inicia respaldo de sd_pagocapit --                                           
	-------------------------------------                                           
	   INSERT INTO                                                                  
		  sd_pagocapitrev                                                           
			 (empresa,                                                              
			  num_credito,                                                          
			  folio,                                                                
			  fecha_cuota,                                                          
			  cuota_rec,                                                            
			  monto_cuota,                                                          
			  saldo_cuota,                                                          
			  imp_capitalizado,                                                     
			  factor_ajuste,                                                        
			  monto_real_pag,                                                       
			  fecha_pago,                                                           
			  factor_moratorio,                                                     
			  monto_moratorio,                                                      
			  fecha_moratorio,                                                      
			  dias_moratorios,                                                      
			  status_moratorio,                                                     
			  num_pagares,                                                          
			  porc_pago,                                                            
			  bandera_ministra,                                                     
			  status_cuota)                                                         
	   SELECT                                                                       
			  empresa,                                                              
			  num_credito,                                                          
			  g_Folio,                                                              
			  fecha_cuota,                                                          
			  cuota_rec,                                                            
			  monto_cuota,                                                          
			  saldo_cuota,                                                          
			  imp_capitalizado,                                                     
			  factor_ajuste,                                                        
			  monto_real_pag,                                                       
			  fecha_pago,                                                           
			  factor_moratorio,                                                     
			  monto_moratorio,                                                      
			  fecha_moratorio,                                                      
			  dias_moratorios,                                                      
			  status_moratorio,                                                     
			  num_pagares,                                                          
			  porc_pago,                                                            
			  bandera_ministra,                                                     
			  status_cuota                                                          
	   FROM                                                                         
			 sd_pagocapit                                                           
	   WHERE                                                                        
			 empresa = g_Empresa                                                    
	   AND                                                                          
			 num_credito = g_NumCredito;                                            
																					
																					
	-------------------------------------                                           
	--Inicia Respaldo de sd_paginter   --                                           
	-------------------------------------                                           
	   INSERT INTO                                                                  
		  sd_paginterrev                                                            
			 (empresa,                                                              
			  num_credito,                                                          
			  folio,                                                                
			  fecha_cuota,                                                          
			  cuota_rec,                                                            
			  monto_cuota,                                                          
			  monto_real_pag,                                                       
			  fecha_pag,                                                            
			  factor_moratorio,                                                     
			  monto_moratorio,                                                      
			  fecha_moratorio,                                                      
			  dias_moratorio,                                                       
			  status_moratorio,                                                     
			  bonifi_int_mora,                                                      
			  porc_pago,                                                            
			  status_cuota,                                                         
			  monto_financiado)                                                     
	   SELECT                                                                       
			  empresa,                                                              
			  num_credito,                                                          
			  g_Folio,                                                              
			  fecha_cuota,                                                          
			  cuota_rec,                                                            
			  monto_cuota,                                                          
			  monto_real_pag,                                                       
			  fecha_pag,                                                            
			  factor_moratorio,                                                     
			  monto_moratorio,                                                      
			  fecha_moratorio,                                                      
			  dias_moratorio,                                                       
			  status_moratorio,                                                     
			  bonifi_int_mora,                                                      
			  porc_pago,                                                            
			  status_cuota,                                                         
			  monto_financiado                                                      
	   FROM                                                                         
			  sd_paginter                                                           
	   WHERE                                                                        
			  empresa = g_Empresa                                                   
	   AND                                                                          
			  num_credito = g_NumCredito;                                           
	-----------------------------------                                             
	-- Inicia Respaldo de sd_detmora --                                             
	-----------------------------------                                             
	   {INSERT INTO                                                                 
		  sd_detmorarev                                                             
			  (empresa, num_credito, folio, fecha_cuota, identifi_rec,              
			   sdo_acum_mes_mora, tasa_ordinaria, provi_mora_ordi,                  
			   tasa_copete, provi_mora_cope, sdo_mora_ordi, sdo_mora_cope)          
	   SELECT                                                                       
			   empresa, num_credito, g_Folio, fecha_cuota, identifi_rec,            
			   sdo_acum_mes_mora, tasa_ordinaria, provi_mora_ordi, tasa_copete,     
			   provi_mora_cope, sdo_mora_ordi, sdo_mora_cope                        
		 FROM sd_detmora                                                            
		WHERE empresa = g_Empresa                                                   
		 AND num_credito = g_NumCredito;        
	-----------------------------------                                             
	-- Inicia Respaldo de sd_detcomi --                                             
	-----------------------------------                                             
			INSERT INTO sd_detcomirev                                               
					(empresa, folio, cod_comis, num_credito, fecha_alta, secuencia, 
					 fecha_pago, monto_com, monto_pag, apli_factor,                 
					 estado_com, num_solicitud, user_insert, fecha_insert)          
			SELECT empresa, g_Folio, cod_comis, num_credito, fecha_alta, secuencia, 
					 fecha_pago, monto_com, monto_pag, apli_factor,                 
					 estado_com, num_solicitud, user_insert, fecha_insert           
			 FROM sd_detcomi                                                        
			WHERE empresa = g_Empresa                                               
			  AND num_credito = g_NumCredito;  }                                    
																					
	----------------------------------------                                        
	-- Inicia Respaldo de sd_maecredanexo --                                        
	----------------------------------------                                        
	INSERT INTO sd_maecredanexorev                                                  
			(empresa,              num_credito,         folio,                    
			 dia_corte,            dias_gracia_mora,    tp_dias_calc_mora,
			 dias_fecha_max_pago,  tp_dias_fecha_pago,  cod_tasa_base_cte,
			 factor_sobretasa_cte, sobretasa_cte,       tasa_interes_cte,
			 fecha_vencto,         prox_fecha_pago,     fecha_proceso, 
			 fecha_ult_pago  )
	SELECT empresa,              num_credito,         g_Folio,                      
		   dia_corte,            dias_gracia_mora,    tp_dias_calc_mora,
		   dias_fecha_max_pago,  tp_dias_fecha_pago,  cod_tasa_base_cte,
		   factor_sobretasa_cte, sobretasa_cte,       tasa_interes_cte,
		   fecha_vencto,         prox_fecha_pago,     fecha_proceso, 
		   fecha_ult_pago  
	  FROM sd_maecredanexo                                                          
	 WHERE empresa = g_Empresa                                                      
	   AND num_credito = g_NumCredito;                                              
	-----------------------------------                                             
	-- Inicia Respaldo de sd_escrow --                                              
	-----------------------------------                                             
	{       INSERT INTO sd_escrowrev                                                
					(empresa, num_credito, folio, fecha_venc_seg, cod_comis,        
					 monto_poliza, monto_mensual, plazo, saldo, texto)              
			SELECT empresa, num_credito, g_Folio, fecha_venc_seg, cod_comis,        
					 monto_poliza, monto_mensual, plazo, saldo, texto               
			 FROM sd_escrow                                                         
			WHERE empresa = g_Empresa                                               
			  AND num_credito = g_NumCredito;                                       
	}                                                                               
																					
	-- ---------------------------------------------------------------------        


	---------------------------------------------
	--Inicia Respaldo de sd_amortiza_credito --
	---------------------------------------------
	INSERT INTO sd_amortiza_creditorev(
		   empresa                ,
		   folio                  ,
		   num_credito            ,
		   fecha_cuota            ,
		   tipo_cuota             ,
		   capital_mto_cuota      ,
		   capital_debe           ,
		   capital_pagado         ,
		   capital_status         ,
		   capital_status_ant     ,
		   capital_fecha_pago     ,
		   interes_debe           ,
		   interes_pagado         ,
		   interes_status         ,
		   interes_status_ant     ,
		   interes_fecha_pago     ,
		   iva_debe               ,
		   iva_pagado             ,
		   iva_status             ,
		   iva_status_ant         ,
		   iva_fecha_pago         ,
		   mora_provi_ordi        ,
		   mora_provi_cope        ,
		   mora_sdo_ordi          ,
		   mora_sdo_ordi_pag      ,
		   mora_sdo_cope          ,
		   mora_sdo_cope_pag      ,
		   mora_bonificado        ,
		   mora_status            ,
		   mora_iva_debe          ,
		   mora_iva_pagado        ,
		   mora_iva_status        ,
		   mora_iva_fecha_pago    ,
		   num_pago               ,
		   campo_trabajo1         ,
		   campo_trabajo2         ,
		   campo_trabajo3         ,
		   campo_trabajo4   )
	SELECT 
		   empresa                ,
		   g_folio                ,
		   num_credito            ,
		   fecha_cuota            ,
		   tipo_cuota             ,
		   capital_mto_cuota      ,
		   capital_debe           ,
		   capital_pagado         ,
		   capital_status         ,
		   capital_status_ant     ,
		   capital_fecha_pago     ,
		   interes_debe           ,
		   interes_pagado         ,
		   interes_status         ,
		   interes_status_ant     ,
		   interes_fecha_pago     ,
		   iva_debe               ,
		   iva_pagado             ,
		   iva_status             ,
		   iva_status_ant         ,
		   iva_fecha_pago         ,
		   mora_provi_ordi        ,
		   mora_provi_cope        ,
		   mora_sdo_ordi          ,
		   mora_sdo_ordi_pag      ,
		   mora_sdo_cope          ,
		   mora_sdo_cope_pag      ,
		   mora_bonificado        ,
		   mora_status            ,
		   mora_iva_debe          ,
		   mora_iva_pagado        ,
		   mora_iva_status        ,
		   mora_iva_fecha_pago    ,
		   num_pago               ,
		   campo_trabajo1         ,
		   campo_trabajo2         ,
		   campo_trabajo3         ,
		   campo_trabajo4
	 FROM sd_amortiza_credito
	 WHERE empresa     = g_empresa
	   and Num_credito = g_numcredito;
	--------------------------------------
	END IF;
   RETURN CodRet;

END PROCEDURE                                                                   
DOCUMENT
'Este SPL realiza el respaldo de las tablas de Credito involucradas',
'En el pago, para poder efectuar su reversion',
'AUTOR : Raul Mendoza D nes',
'FECHA : 20/Octubre/2003',
'BD    : BDICRED';

CREATE PROCEDURE "informix".principalrefer(p_Empresa  CHAR(3),
                           p_NumCredito             CHAR(20),
                           p_TpPago                 SMALLINT, 
                           p_Tarjeta                CHAR(20),
                           p_Usuario                CHAR(8),
                           p_Sucursal               CHAR(4),
                           p_Folio                  LIKE sd_movdia.Folio_Suc,
                           p_Transacc               LIKE sd_movdia.Transacc_Suc,
                           p_MontoSBC               MONEY(14,2),
                           p_MontoEfe               MONEY(14,2),
                           p_referencia             char(40))
  --Valores a Regresar
      RETURNING CHAR(5),     -- Codigo de Retorno
             MONEY(14,2), -- Remanente
             MONEY(14,2), -- Interes Moratorio Cobrado
             MONEY(14,2), -- Interes Vencido Cobrado
             MONEY(14,2), -- Capital Vencido Cobrado
             MONEY(14,2), -- Interes Vigente Cobrado
             MONEY(14,2), -- Capital Vigente Cobrado
             MONEY(14,2), -- Impuesto Cobrado
             MONEY(14,2), -- Comisiones Cobradas
             MONEY(14,2)  -- Seguro Cobrado

 DEFINE GLOBAL g_sistema       CHAR(2)     DEFAULT '06';

   DEFINE CodRet                CHAR(5);
   DEFINE sql_err               SMALLINT;
   DEFINE isam_err              SMALLINT;
   DEFINE error_info            CHAR(40);
   DEFINE nRows                 SMALLINT;
   DEFINE Mensaje               CHAR(80);
   DEFINE wBegin                CHAR(1);
   DEFINE vfecha_hoy            DATE;
   
   DEFINE g_IntMoraCob   MONEY(14,2);
   DEFINE g_IntVencCob   MONEY(14,2);
   DEFINE g_CapVencCob   MONEY(14,2);
   DEFINE g_IntVigCob    MONEY(14,2);
   DEFINE g_CapVigCob    MONEY(14,2);
   DEFINE g_Impuesto     MONEY(14,2);
   DEFINE g_Comision     MONEY(14,2);
   DEFINE g_Seguro       MONEY(14,2);
   DEFINE g_Remanente    MONEY(14,2);
   DEFINE g_NumProducto   CHAR(4);
   DEFINE g_NumCte        CHAR(20);
   DEFINE v_NumCredito    CHAR(20);
   DEFINE vSdoTdc_Crds 	  		DECIMAL(14,2);	-- Cobro sdo a favor para pago PFSI
   DEFINE dFechaCreds	  		DATE;
   DEFINE cNum_Credisol	  		CHAR(20);
   DEFINE dCap_Credisol	  		DECIMAL(14,2);
   DEFINE dMntoPagoCredis 		DECIMAL(14,2);
   DEFINE cNumCredito_Crds		CHAR(20);
   DEFINE cCta_Eje_Crds        	CHAR(20);
   DEFINE cProducto_Crds       	CHAR(40);
   DEFINE cNum_Cte_Crds        	CHAR(20);
   DEFINE cNom_Cte_Crds        	CHAR(150);
   DEFINE dPago_Efec_Crds      	DECIMAL(18,2);
   DEFINE dPago_Cta_Crds       	DECIMAL(18,2);
   DEFINE dMonto_Op_Crds     	DECIMAL(18,2);
   DEFINE dSaldo_Actual_Crds   	DECIMAL(18,2);
   DEFINE cStatus_Actual_Crds  	CHAR(60);
   DEFINE dFecha_ProxPago_Crds	DATE;									  
									        

   ON EXCEPTION SET sql_err, isam_err, error_info
      LET CodRet = sql_err;
      LET Mensaje = error_info;
      ROLLBACK WORK;
      IF (wBegin = "S") THEN
         BEGIN WORK;
      END IF;
      RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob,
	     g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
   END EXCEPTION;

   ON EXCEPTION IN (-535)
      LET wBegin = "S";
      --ROLLBACK WORK;
      COMMIT WORK;
      BEGIN WORK;
   END EXCEPTION WITH RESUME;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

   
    --SET DEBUG FILE TO "/informix/mahr/principalrefer-"||p_Transacc||".out";     
    --TRACE ON;

   LET wBegin = "N";
   LET vSdoTdc_Crds 	= 0;
   LET dFechaCreds		= DATE(1);
   LET cNum_Credisol 	= '';
   LET dCap_Credisol 	= 0;   
   LET dMntoPagoCredis	= 0;
   
   LET cNumCredito_Crds		= '';
   LET cCta_Eje_Crds        = '';
   LET cProducto_Crds       = '';
   LET cNum_Cte_Crds        = '';
   LET cNom_Cte_Crds        = '';
   LET dPago_Efec_Crds      = 0;
   LET dPago_Cta_Crds       = 0;
   LET dMonto_Op_Crds     	= 0;
   LET dSaldo_Actual_Crds   = 0;
   LET cStatus_Actual_Crds  = '';
   LET dFecha_ProxPago_Crds	= DATE(1);

   BEGIN WORK;

   LET CodRet = "000";
   LET v_NumCredito = "";
   LET vfecha_hoy = "";
   LET g_Seguro =0;
   
   SELECT descripcion
     INTO Mensaje
     FROM bdinteg:"informix".si_codret
    WHERE sistema = g_sistema
      AND codigo_retorno = CodRet;
	  
   SELECT fecha_hoy INTO vfecha_hoy FROM "informix".sd_fechas;

   LET p_Empresa     = p_Empresa;
   LET g_Remanente   = 0;
   LET g_IntMoraCob  = 0;
   LET g_IntVencCob  = 0;
   LET g_CapVencCob  = 0;
   LET g_IntVigCob   = 0;
   LET g_CapVigCob   = 0;
   LET g_Impuesto    = 0;
   LET g_Comision    = 0;
   LET g_Seguro      = 0;   
   LET nRows         = 0;
   
   --**Se selecciona el producto
   IF length(p_NumCredito) = 16 THEN
      LET p_Tarjeta = p_NumCredito;

      SELECT num_credito 
        INTO v_NumCredito
        FROM "informix".sd_tarjeta
       WHERE num_tarjeta = p_NumCredito
         AND empresa     = p_Empresa; 
   ELSE
      LET v_NumCredito = p_NumCredito;
   END IF

   --Pago de TDC por Efectivo
    IF p_MontoEfe < 1 and p_Transacc = '0600' THEN
		if p_MontoEfe > 0 THEN 
			let CodRet = '399';
		ELSE
			let CodRet = '284';
		END IF;
    ELSE
      if p_MontoEfe > 0 then
            CALL "informix".Principal(
                p_Empresa,
                v_NumCredito,
                p_TpPago,
                p_MontoEfe,
                p_Usuario,
                p_Sucursal,
                p_Folio,
                p_Transacc
            )
            returning CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob,
                   g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;

            IF (CodRet <> "000") THEN
                SELECT descripcion
                INTO   Mensaje
                FROM   bdinteg:"informix".si_codret
                WHERE  sistema        = "06"
                AND    codigo_retorno = CodRet;
                ROLLBACK WORK;
                IF (wBegin = "S") THEN
                   BEGIN WORK;
                END IF;
            ELSE
				if ( p_Transacc = '8324') then  --Se graba clave de rastreo para movimientos de credito SPEI
                    UPDATE "informix".sd_movdia
                       SET referencia = p_referencia
                     WHERE folio_suc = p_folio
                       AND sucursal = p_Sucursal; 
                elif ( p_Transacc = '6246') then  -- Graba referencia saldo buen cobro            
                    UPDATE "informix".sd_movdia
                       SET referencia23 = p_referencia,
                           nro_tarjeta = p_Tarjeta
                     WHERE folio_suc = p_folio
                       AND sucursal = p_Sucursal; 
                else
                    UPDATE "informix".sd_movdia
                       SET nro_tarjeta = p_Tarjeta
                     WHERE folio_suc = p_folio
                       AND sucursal = p_Sucursal; 
                end if;
				
				-- Pago de TDC termina correctamente. Realiza el cobro del saldo a favor si existe un PFSI activo (Sdo Inmediato - Apoyo 2020)
				SELECT sdo_cap_insoluto INTO vSdoTdc_Crds FROM bdicred:"informix".sd_maesdos WHERE empresa = p_Empresa AND num_credito = v_NumCredito;
				
				--IF vSdoTdc_Crds < -1 AND p_Transacc = '0600' THEN -- Solo entre cuando venga de pago tdc
				IF vSdoTdc_Crds < -1 THEN -- Solo entre cuando venga de pago tdc

					SELECT count(num_credito) INTO nRows FROM bdicred:sd_promocion_credito WHERE num_credito = v_NumCredito AND tipo_contrato = '3' AND status = 2;
					IF nRows > 0 THEN	-- Existe credisolucion vigente relacionado a la TDC
				  
						SELECT max(fecha) INTO dFechaCreds FROM bdicred:sd_promocion_credito WHERE num_credito = v_NumCredito AND tipo_contrato = '3' AND status = 2;
						SELECT num_sol_prestamo INTO cNum_Credisol FROM bdicred:sd_promocion_credito WHERE num_credito = v_NumCredito AND fecha = dFechaCreds AND tipo_contrato = '3' AND status = 2;
						SELECT nvl(sdo_cap_insoluto,0) INTO dCap_Credisol FROM bdicred:sd_maesdoscrd WHERE num_credito = cNum_Credisol;
						
						IF dCap_Credisol > 1 THEN	-- Aun se tiene deuda del credito 6900 y no vuelva a entrar en la 2da ejecucion del principalrefer 	
							IF abs(vSdoTdc_Crds) < dCap_Credisol THEN	-- El saldo excedente es menor que el monto de la deuda total del credito 6900. El excedente solo cubre parte del monto de deuda 6900
								LET dMntoPagoCredis = abs(vSdoTdc_Crds);
							ELSE										-- Parte del excedente cubre la deuda total del credito 6900
								LET dMntoPagoCredis = dCap_Credisol;
							END IF;
							
							-- Elimina el pago previo para casos iterativos y asÃÂ­ no sume el monto de ambos pagos a cargar a la tdc.
							SELECT count(folio) INTO nRows FROM bdicred:"informix".sd_montopagcrd WHERE folio = p_Folio;
							IF nRows > 0 THEN
								DELETE bdicred:"informix".sd_montopagcrd WHERE folio = p_Folio;
								LET nRows = 0;
							END IF;

							--EXECUTE PROCEDURE bdicred:sp_cs_pago_anticipado(p_Empresa, cNum_Credisol, '6900', dMntoPagoCredis, 0, p_Usuario, p_Sucursal, p_Folio, '618')
							BEGIN WORK;
							EXECUTE PROCEDURE bdicred:sp_cs_pago_anticipado(p_Empresa, cNum_Credisol, '6900', dMntoPagoCredis, 0, p_Usuario, p_Sucursal, p_Folio, '8654')
							   INTO CodRet, Mensaje, cNumCredito_Crds, cCta_Eje_Crds, cProducto_Crds, cNum_Cte_Crds, cNom_Cte_Crds, dPago_Efec_Crds, dPago_Cta_Crds, 
									  dMonto_Op_Crds, dSaldo_Actual_Crds, cStatus_Actual_Crds, dFecha_ProxPago_Crds;
							IF CodRet::SMALLINT = 0 THEN
								-- Se actualiza remanente
								LET g_Remanente = g_Remanente;
								LET CodRet = "000";
							END IF;										
							
						END IF;
					END IF;  
					LET nRows = 0;
				END IF;    
				
           END IF
      END IF
	END IF;
/*
--jom ini
   else
	if p_MontoEfe > 0 THEN 
	        let CodRet = '399';
	ELSE
		let CodRet = '284';
	end if;
--jom fin
   END IF;
*/
   --Pago de TDC por Cheque
   IF p_MontoSBC > 0 THEN
   	--realiza la grabacion del Movimiento

      SELECT num_producto
        INTO g_NumProducto
        FROM "informix".sd_maecred
       WHERE empresa     = p_Empresa
         AND num_credito = v_NumCredito
		 AND status_cred      not in ('CV','FC','FF','FI')	
         AND (id_unidad_prod is null or id_unidad_prod <> 1);
		      
	 --2012-09-18 se valida que el credino no este marcado para venta en pago SBC.
	LET nrows = dbinfo("sqlca.sqlerrd2");
   IF (nrows = 0) THEN   
       LET CodRet = "008";     
    ELSE
	
		CALL "informix".Genmovref(
		p_Empresa,
		v_NumCredito,
		g_NumProducto,
		p_MontoSBC,
		p_Folio ,
		p_Sucursal,
        p_Tarjeta,
		p_referencia)

		RETURNing CodRet;
		
    END IF;          	
	
      
  	IF (CodRet <> "000") THEN
   	    SELECT descripcion
            INTO   Mensaje
       	    FROM   bdinteg:"informix".si_codret
       	    WHERE  sistema        = "06"
             AND   codigo_retorno = CodRet;
       	     ROLLBACK WORK;
       	     IF (wBegin = "S") THEN
                 BEGIN WORK;
       	     END IF;
        END IF
   END IF;

   RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob,
               g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
END PROCEDURE;