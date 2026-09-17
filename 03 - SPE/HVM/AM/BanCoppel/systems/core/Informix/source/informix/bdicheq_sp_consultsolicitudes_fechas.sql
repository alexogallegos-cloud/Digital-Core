CREATE PROCEDURE "informix".sp_consultsolicitudes_fechas( pfecha_reg date, dtfecant date ,cod_oper integer, no_pag integer, pregistros integer)
RETURNING CHAR(3),
 integer, 
 CHAR(30),
 CHAR(10),
 CHAR(20),
 CHAR(30),
 integer;

---- VARIABLES  GENERALES---
DEFINE cSqlerr			 INTEGER;
DEFINE cCodret      	 CHAR(3);
DEFINE Cod_ret           CHAR(3);
DEFINE isolicitudes      INTEGER;
DEFINE cFolio            CHAR(30);
DEFINE cNumcte           CHAR(10);
DEFINE cBanco            CHAR(20);
DEFINE cEstatus          CHAR(30);
DEFINE vfechoy           CHAR(8); 
DEFINE vfecant           CHAR(8); 
DEFINE vsql              CHAR(400);
DEFINE pSalto		     INTEGER;
DEFINE vfecha_reg        CHAR(8);  
       

DEFINE cfolio_sol        CHAR(30);  
DEFINE cfech_sol         CHAR(8);
DEFINE cnomb_cte         CHAR(60); 
DEFINE crfc_cte          CHAR(13);
DEFINE ccta_recept       CHAR(20);
DEFINE ctipo_cta_rec     CHAR(2);
DEFINE cbco_receptor     CHAR(5);
DEFINE ccta_ordenante    CHAR(20);
DEFINE ctipo_cta_orden   CHAR(2);
DEFINE cbco_orden        CHAR(5);
DEFINE cnombco_orden     CHAR(20);
DEFINE cfecha_nac        DATE;
DEFINE crfc_emp          CHAR(12);
DEFINE cestatus_resp     CHAR(2);
DEFINE cfecha_resp       CHAR(8);
DEFINE ccurp_cte         CHAR(18);
DEFINE cnum_cte          CHAR(9); 
DEFINE dtFechaIni        DATE;
DEFINE dtFechaHoy        DATE;
DEFINE iRegistros		 INTEGER; 

--VALORES INICIALES
LET cSqlerr 			= 0;
LET cCodret 			= '';
LET Cod_ret             = '';
LET isolicitudes        = 0; 
LET cFolio              = '';
LET cNumcte             = '';     
LET cBanco              = '';
LET cEstatus            = ''; 
LET vfechoy             = ''; 
LET vfecant             = '';
LET vsql                = '';
LET pSalto              = 0;   
LET vfecha_reg          = ''; 

LET cfolio_sol        = '';  
LET cfech_sol         = '';
LET cnomb_cte         = ''; 
LET crfc_cte          = '';
LET ccta_recept       = '';
LET ctipo_cta_rec     = '';
LET cbco_receptor     = '';
LET ccta_ordenante    = '';
LET ctipo_cta_orden   = '';
LET cbco_orden        = '';
LET cnombco_orden     = '';
LET cfecha_nac        = ''; 
LET crfc_emp          = '';
LET cestatus_resp     = '';
LET cfecha_resp       = '';
LET ccurp_cte         = '';
LET cnum_cte          = '';
LET dtFechaIni  = DATE(1);
LET dtFechaHoy  = DATE(1);
LET iRegistros		  = 0;


	BEGIN
	
	------  Control de Errores no Controlados
		ON EXCEPTION SET cSqlerr
        IF cSqlerr <> 0 THEN
            Let cCodret = cSqlerr;    
            RETURN cCodret, isolicitudes, cFolio,cNumcte,cnombco_orden,cEstatus, iRegistros;
        END IF;
		END EXCEPTION;
	
		--SET DEBUG FILE TO "/informix/VILLELA/sp_consultsolicitudes_fechas.out";
		--TRACE ON;
  
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
  
	-- //  ENVIA CODIGO DE ERROR SI EXISTE UN PARAMETRO NULO
  
		IF NVL(pfecha_reg, "") = "" OR NVL(cod_oper,"") = "" OR NVL(no_pag,"") = "" OR NVL(pregistros,"") = ""  THEN
			LET cCodRet = "002";	
			RETURN cCodret, isolicitudes, cfolio_sol,cNumcte,cnombco_orden,cEstatus, iRegistros;
		END IF;
  
	
	--// PONE EN VARIABLES LA FECHA SOLICITADA Y EL DIA ANTERIOR DE LA MISMA
	
			LET vfecha_reg = YEAR(pfecha_reg)||LPAD(MONTH(pfecha_reg),2,0)||LPAD(DAY(pfecha_reg),2,0); 
						
				
			LET vfecant=   YEAR(dtfecant)||LPAD(MONTH(dtfecant),2,0)||LPAD(DAY(dtfecant),2,0);
					
						 		
			IF cod_oper=20  THEN

				IF no_pag =0  THEN
			
					-- //LIMPIAR LAS TABLAS TEMPORALES
					DELETE FROM sc_portacec_archivotemp;
                    CREATE sequence myseq;

                    INSERT into  sc_portacec_archivotemp (secuencia,folio_solicitud,fecha_solicitud,nombre_cte,rfc_cte,cta_receptora,tipo_cta_receptora,bco_receptor,cta_ordenante,tipo_cta_ordenante,bco_ordenante,fecha_nacimiento,rfc_empresa,estatus_respuesta,fecha_respuesta,curp_cte)
                    SELECT myseq.nextval, folio_solicitud,fecha_solicitud, 
						(SELECT trim (apell_paterno)||' '||trim(apell_materno)||' '||trim(nombre1)||' '||trim(nombre2) 
						FROM bdinteg:si_cliente cte
						where cte.numcte =  ps.num_cte) as nombre_cte, 
						(SELECT rfc
						FROM bdinteg:si_cliente cte
						where cte.numcte =  ps.num_cte) as rfc_cte, 	
						cta_receptora,tipo_cta_receptora,bco_receptor,cta_ordenante,tipo_cta_ordenante,bco_ordenante,
						(select YEAR(fecha_nac)||LPAD(MONTH(fecha_nac),2,0)||LPAD(DAY(fecha_nac),2,0)
						from bdinteg:si_ctepf cte
						where cte.numcte =  ps.num_cte) as fecha_nacimiento, 
						rfc_empresa,'00' as estatus_respuesta, '00000000' as fecha_respuesta,
						(select curp
						from bdinteg:si_ctepf cte
						where cte.numcte =  ps.num_cte) as curp_cte
						from sc_portacec_solicitud ps
					    WHERE (fecha_solicitud	BETWEEN vfecant and vfecha_reg			 
						and estatus_portabilidad='2'
						and clave_sentido='2')
						and (fecha_presentacion='' OR fecha_presentacion IS null) 						
						and estatus_cecoban is not null		
						and (fecha_respuesta =  '' OR fecha_respuesta IS null);
					 
                     
                        SELECT COUNT(*) INTO iRegistros 
					    FROM sc_portacec_archivotemp;    

                    DROP sequence myseq;
				
					foreach 
					
						select SKIP no_pag FIRST pregistros folio_solicitud,fecha_solicitud, 
						(SELECT trim (apell_paterno)||' '||trim(apell_materno)||' '||trim(nombre1)||' '||trim(nombre2) 
						FROM bdinteg:si_cliente cte
						where cte.numcte =  ps.num_cte) as nombre_cte, 
						(SELECT rfc
						FROM bdinteg:si_cliente cte
						where cte.numcte =  ps.num_cte) as rfc, 
						num_cte,	
						cta_receptora,tipo_cta_receptora,bco_receptor,cta_ordenante,tipo_cta_ordenante,bco_ordenante,
						(select vchrnombrecorto
						from bdinteg:si_bancos
						where cvecesif= bco_ordenante) as bco_ordenante,
						(select fecha_nac
						from bdinteg:si_ctepf cte
						where cte.numcte =  ps.num_cte) as fec_nac, 
						rfc_empresa,
						(select curp
						from bdinteg:si_ctepf cte
						where cte.numcte =  ps.num_cte) as curp_cte	
						into cfolio_sol,cfech_sol,cnomb_cte,crfc_cte,cNumcte,ccta_recept,ctipo_cta_rec,cbco_receptor,ccta_ordenante, ctipo_cta_orden, cbco_orden, cnombco_orden,cfecha_nac, crfc_emp,ccurp_cte
						from sc_portacec_solicitud ps
						where (fecha_solicitud BETWEEN vfecant and vfecha_reg
						and estatus_portabilidad='2'
						and clave_sentido='2')
						and (fecha_presentacion='' OR fecha_presentacion IS null) 						
						and (estatus_cecoban is not null		
						and estatus_portabilidad='2'
						and clave_sentido='2')
                        and (fecha_respuesta =  '' OR fecha_respuesta IS null)
			
                        
			
						LET isolicitudes= isolicitudes+1;
						if isolicitudes <>0 then
							LET cCodret='000';	
						end if	
			
						RETURN cCodret, isolicitudes, cfolio_sol,cNumcte,cnombco_orden,cEstatus, iRegistros WITH RESUME;
					end foreach
				
			
				ELSE 

                    SELECT COUNT(*) INTO iRegistros 
					FROM sc_portacec_archivotemp;    
				
					foreach 		
						select SKIP no_pag FIRST pregistros folio_solicitud,fecha_solicitud, 
						(SELECT trim (apell_paterno)||' '||trim(apell_materno)||' '||trim(nombre1)||' '||trim(nombre2) 
						FROM bdinteg:si_cliente cte
						where cte.numcte =  ps.num_cte) as nombre_cte, 
						(SELECT rfc
						FROM bdinteg:si_cliente cte
						where cte.numcte =  ps.num_cte) as rfc, 
						num_cte,	
						cta_receptora,tipo_cta_receptora,bco_receptor,cta_ordenante,tipo_cta_ordenante,bco_ordenante,
						(select vchrnombrecorto
						from bdinteg:si_bancos
						where cvecesif= bco_ordenante) as bco_ordenante,
						(select fecha_nac
						from bdinteg:si_ctepf cte
						where cte.numcte =  ps.num_cte) as fec_nac, 
						rfc_empresa,
						(select curp
						from bdinteg:si_ctepf cte
						where cte.numcte =  ps.num_cte) as curp_cte	
						into cfolio_sol,cfech_sol,cnomb_cte,crfc_cte,cNumcte,ccta_recept,ctipo_cta_rec,cbco_receptor,ccta_ordenante, ctipo_cta_orden, cbco_orden, cnombco_orden,cfecha_nac, crfc_emp,ccurp_cte
						from sc_portacec_solicitud ps
						where fecha_solicitud BETWEEN vfecant and vfecha_reg
						and estatus_portabilidad='2'
						and clave_sentido='2'
						and (fecha_presentacion='' OR fecha_presentacion IS null)
                        and (fecha_respuesta =  '' OR fecha_respuesta IS null)
						
						LET isolicitudes=isolicitudes + (no_pag +1 );
						if isolicitudes <>0 then
							LET cCodret='000';	
						end if
                         
                        LET no_pag=0;
												
						RETURN cCodret, isolicitudes, cfolio_sol,cNumcte,cnombco_orden,cEstatus, iRegistros WITH RESUME;
					end foreach
				end if

			ELIF cod_oper=21  THEN

                SELECT COUNT(*) INTO iRegistros 
				FROM sc_portacec_solicitud 
				WHERE fecha_estatus_portabilidad IN (vfecha_reg) AND cod_operacion='21';    

				foreach 		
					select SKIP no_pag FIRST pregistros folio_solicitud, 
					num_cte, vchrnombrecorto, pr.descripcion
					into cfolio_sol,cNumcte, cnombco_orden, cEstatus
					from sc_portacec_solicitud ps 
                    inner join bdinteg:si_bancos  on cvecesif= bco_ordenante
                    inner join sc_portacec_estatus_respuesta pr on ps.estatus_respuesta=pr.estatus_respuesta
					where fecha_estatus_portabilidad IN (vfecha_reg)
					and cod_operacion='21'

				
					LET isolicitudes= isolicitudes+1;
					if isolicitudes <>0 then
						LET cCodret='000';	
					end if
												
					RETURN cCodret, isolicitudes, cfolio_sol,cNumcte,cnombco_orden,cEstatus, iRegistros WITH RESUME;
				end foreach

			ELSE
                LET cCodRet = '004';    --CODIGO DE OPERACION INVALIDO

				RETURN cCodret, isolicitudes, cfolio_sol,cNumcte,cnombco_orden,cEstatus, iRegistros;
										
			END IF

					--// NO EXISTEN DATOS
				IF isolicitudes = 0 THEN
					LET cCodRet = '001';
				RETURN cCodret, isolicitudes, cfolio_sol,cNumcte,cnombco_orden,cEstatus, iRegistros;
				END IF
			
			
	END
	END PROCEDURE;