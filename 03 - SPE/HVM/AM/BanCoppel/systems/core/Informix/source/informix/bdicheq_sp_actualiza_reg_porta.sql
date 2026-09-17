CREATE PROCEDURE "informix".sp_actualiza_reg_porta(pempresa CHAR(3))
RETURNING CHAR(5);


	/*Definir Variables " Para fechas" */
		
	DEFINE cdias_pasados			INTEGER;
	DEFINE vfecha_fin_mes 			DATE;
	DEFINE vfecha_inic_mes		    DATE;
	DEFINE vfecha_fin_aaaammdd		CHAR(8);
	DEFINE vfecha_ini_aaaammdd 		CHAR(8);
	DEFINE cMesPeriodo              CHAR(15);
    DEFINE cfecha_hoy               CHAR(10);
	DEFINE vfecha_tres_meses		DATE;
		
		
		
	/*Definir Variables " Errores" */	
	
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
	
	/*Definir Variables " para reporte" */
	
	DEFINE cfecha_solicitud                 CHAR(10);
	DEFINE cfolio_solicitud 	            CHAR(30);
	DEFINE csucursal  			            CHAR(10);
	DEFINE cnum_cte                          CHAR(10);
	DEFINE cnombre                          CHAR(60);
	DEFINE ccta_ordenante                   CHAR(20);
	DEFINE ccta_receptora                   CHAR(20);
	DEFINE cfecha_estatus_portabilidad      CHAR(10); 
	DEFINE cfecha_solca_portabilidad        CHAR(10);
	DEFINE cfolio_cancelacion               CHAR(30);  
	DEFINE cestatus_respuesta               CHAR(10);
	DEFINE cmnyimporte                      CHAR(10);
	DEFINE cdtfechacaptura                  CHAR(10);   
	DEFINE cvchrclaverastreo                CHAR(40); 
	DEFINE cvchrconceptopago                CHAR(40);
	
	
	
	
	
	
	LET cdias_pasados		    = 0;
	LET vfecha_fin_mes  	    = '';
	LET vfecha_inic_mes  		= '';
	LET	vfecha_fin_aaaammdd		= '';
	LET vfecha_ini_aaaammdd     = '';
	LET cMesPeriodo             = '';
    LET cfecha_hoy				= '';
	LET vfecha_tres_meses		= '';
	
	
	
	LET  vcodret1         		= '000';
    LET  vcodret2         		= '000';
    LET  vcodret3         		= '';
    LET  sql_err	       		= 0 ;
    LET  isam_err         		= 0 ;
    LET  desc_err         		= '';
    LET  vcontador        		= 0 ;
    LET  ven_transacc     		= 0 ;
	LET  vsql             		= '';
    LET  vstmt            		= '';

	
    LET cfecha_solicitud                 = '';
	LET cfolio_solicitud 	             = '';
	LET csucursal  			             = '';
	LET cnum_cte                          = '';
	LET cnombre                          = '';
	LET ccta_ordenante                   = '';
	LET ccta_receptora                   = '';
	LET cfecha_estatus_portabilidad      = '';
	LET cfecha_solca_portabilidad        = '';
	LET cfolio_cancelacion               = ''; 
	LET cestatus_respuesta               = '';
	LET cmnyimporte                      = '';
	LET cdtfechacaptura                  = '';   
	LET cvchrclaverastreo                = '';
	LET cvchrconceptopago                = '';
	
	
	    BEGIN
     ON EXCEPTION SET sql_err, isam_err, desc_err
      -- SET DEBUG FILE TO "/informix/VILLELA/sp_actualiza_reg_porta.out";
		-- TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;			
			
			INSERT INTO "informix".sc_bit_regis_portab
			  (fecha, error)
			 VALUES (cfecha_hoy,vcodret1); 
			
			LET  vcodret1 = '000';
            RETURN vcodret1;
        END IF;
     END EXCEPTION;
	 
	     --SET DEBUG FILE TO "/informix/VILLELA/sp_actualiza_reg_porta.out";
		 --TRACE ON;
	
	 SET ISOLATION TO DIRTY READ;
     SET LOCK MODE TO WAIT 3;
    
	   -- dia del mes en que nos encontramos.
		select fecha_hoy
		INTO cfecha_hoy
		from sc_fechas
		where empresa = 001;
			

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
				
        select fecha_hoy - 3 units month 
		into vfecha_tres_meses
		from bdicheq: sc_fechas
        where empresa = 001;
		
		
		LET vfecha_ini_aaaammdd = YEAR(vfecha_tres_meses)||LPAD(MONTH(vfecha_tres_meses),2,0)||LPAD(DAY(vfecha_tres_meses),2,0); 
	
	

		
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
																

			set isolation to dirty read;
	        select * from bdispei: tblhistpago
            where  dtfechavalor BETWEEN  vfecha_inic_mes and vfecha_fin_mes 
            and  chrsentidopago='R'
            INTO TEMP paso_porta_reg WITH NO LOG;


			   --##########################################################
				 -- REPORTE "Reporte_regis_actual_Porta_mes" 
				 --##########################################################
				 			
				 IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'tbl_tem_porta') THEN
					DROP TABLE bdicheq:"informix".tbl_tem_porta; 
				 END IF;
						
			
				CREATE TABLE bdicheq:"informix".tbl_tem_porta(  
				  
					  secuencia serial,	  
					  --fecha_solicitud--
					  fecha_solicitud               CHAR(20),
					  --folio_solicitud --
					  folio_solicitud 				CHAR(30),
					  -- sucursal --
					  sucursal 		CHAR(40),
					  --num_cte--
					  num_cte     CHAR(10),
						-- Nombre --  
					  nombre			CHAR(60),
					  -- cta_ordenante --
					  cta_ordenante             CHAR(20),
					  -- cta_receptora-
					  cta_receptora                CHAR(20),		
					  -- fecha_estatus_portabilidad
					  fecha_estatus_portabilidad              CHAR(20),		    
					  -- fecha_solca_portabilidad --
					  fecha_solca_portabilidad				CHAR(60),
					  --folio_cancelacion --
					  folio_cancelacion	    CHAR(20),		
					  --estatus_respuesta --
					  estatus_respuesta		  CHAR(20),
					  --mnyimporte--
					  mnyimporte 				CHAR(40),
					  --dtfechacaptura--
					  dtfechacaptura            CHAR(20),		
					  --vchrclaverastreo--
					  vchrclaverastreo 				CHAR(40),
					   -- vchrconceptopago --
					  vchrconceptopago     CHAR(30) )
					  
				 EXTENT SIZE 3200 NEXT SIZE 320 LOCK MODE ROW;
			 
			 
				INSERT INTO "informix".tbl_tem_porta 
						(fecha_solicitud,folio_solicitud,sucursal,num_cte,nombre,cta_ordenante,cta_receptora,fecha_estatus_portabilidad,fecha_solca_portabilidad,folio_cancelacion,estatus_respuesta,mnyimporte,dtfechacaptura,vchrclaverastreo,vchrconceptopago)
				VALUES ('fecha_solicitud','folio_solicitud','sucursal','num_cte','nombre','cta_ordenante','cta_receptora','fecha_estatus_portabilidad','fecha_solca_portabilidad','folio_cancelacion','estatus_respuesta','mnyimporte','dtfechacaptura','vchrclaverastreo','vchrconceptopago');
						
			
			FOREACH 
			  				
					select sc.fecha_solicitud, sc.folio_solicitud, sc.sucursal ,sc.num_cte, (select trim(apell_paterno)||' ' ||trim(apell_materno)||' ' ||trim(nombre1)||' ' ||trim(nombre2)
					from bdinteg: si_cliente
					where numcte= sc.num_cte), cta_ordenante, cta_receptora, fecha_estatus_portabilidad, fecha_solca_portabilidad, folio_cancelacion, estatus_respuesta,
					mnyimporte, dtfechacaptura, vchrclaverastreo,vchrconceptopago
                    INTO cfecha_solicitud,cfolio_solicitud,csucursal,cnum_cte,cnombre,ccta_ordenante,ccta_receptora,cfecha_estatus_portabilidad,cfecha_solca_portabilidad,
					cfolio_cancelacion,cestatus_respuesta,cmnyimporte,cdtfechacaptura,cvchrclaverastreo,cvchrconceptopago
					from sc_portacec_solicitud sc
					inner join bdispei: paso_porta_reg tb
					on sc.cta_ordenante = tb.vchrcuentaord
					where fecha_solicitud between vfecha_ini_aaaammdd and vfecha_fin_aaaammdd 
					and dtfechavalor BETWEEN  vfecha_inic_mes and vfecha_fin_mes 
					and cod_operacion='21'
					and estatus_respuesta <>'00'
					and vchrconceptopago='PORTABILIDAD DE NOMINA'


					INSERT INTO "informix".tbl_tem_porta 
					          ( fecha_solicitud,folio_solicitud,sucursal,num_cte,nombre,cta_ordenante,cta_receptora,fecha_estatus_portabilidad,fecha_solca_portabilidad,folio_cancelacion,estatus_respuesta,mnyimporte,dtfechacaptura,vchrclaverastreo,vchrconceptopago)
		            VALUES 	(cfecha_solicitud,cfolio_solicitud,csucursal,cnum_cte,cnombre,ccta_ordenante,ccta_receptora,cfecha_estatus_portabilidad,cfecha_solca_portabilidad,cfolio_cancelacion,cestatus_respuesta,cmnyimporte,cdtfechacaptura,cvchrclaverastreo,cvchrconceptopago );
			
			END FOREACH;
	 
			 LET vsql = 'echo "set isolation to dirty read; unload to /resplogifx/conciliachq/Reg_Actualizados_Portab_mes'|| TRIM(cMesPeriodo) ||'.txt '||
						'select fecha_solicitud,folio_solicitud,sucursal,num_cte,nombre,cta_ordenante,cta_receptora,fecha_estatus_portabilidad,fecha_solca_portabilidad,folio_cancelacion,estatus_respuesta,mnyimporte,dtfechacaptura,vchrclaverastreo,vchrconceptopago	 from tbl_tem_porta order by secuencia;" > /resplogifx/conciliachq/qwery_reg_port.sql';
			 SYSTEM vsql;
			 LET vsql = '';
			
			 --LET vstmt = "dbaccess bdicheq /informix/resplogifx/conciliachq/qwery_reg_port.sql";    --Se activa para desarrollo
			 
			 LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/qwery_reg_port.sql'; 
			 
			 
			 SYSTEM vstmt;
			 LET vstmt = '';		
	 
			 
			 update "informix".sc_portacec_solicitud
			 set estatus_respuesta='00', estatus_portabilidad='1'
			 where  folio_solicitud in 
			 (select folio_solicitud from bdicheq: tbl_tem_porta);
			 
			 
			 INSERT INTO "informix".sc_bit_regis_portab 
			        (fecha, error)
			 VALUES (cfecha_hoy,vcodret1); 
																
	END;
    
    RETURN vcodret1;
    
	END PROCEDURE;