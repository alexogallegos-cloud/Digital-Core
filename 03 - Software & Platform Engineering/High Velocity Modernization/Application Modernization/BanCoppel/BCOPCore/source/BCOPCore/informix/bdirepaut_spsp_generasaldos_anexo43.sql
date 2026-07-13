CREATE PROCEDURE "informix".spsp_generasaldos_anexo43(p_empresa CHAR(3), p_fechadia DATE,p_clavereporte      varchar(10), p_periodicidad VARCHAR(1))
RETURNING char(5), varchar(255);
    --Variables de Retorno
    DEFINE r_codret   char(5);
    DEFINE r_mensaje  varchar(255);	
    -- Variables para reportes
    DEFINE v_identautoridad    varchar(8);
    --DEFINE v_clavereporte      varchar(10);
    DEFINE v_claveperiodicidad varchar(2);
    DEFINE v_claveprioridad    smallint;
    DEFINE v_clavetiporep      varchar(2);
    --Variables de Control de Procesos
	
    DEFINE v_fechaproyec       date;
    DEFINE v_fechamesant       date;
    DEFINE v_fechadicant       date;
    DEFINE v_fechaanioant      date;
    DEFINE v_fechadiaanterior  date;
	
    --Variables Cambio Mes
    DEFINE v_aniocontable      smallint;
    DEFINE v_mescontable       smallint;
    DEFINE v_anioreporte       smallint;
    DEFINE v_mesreporte        smallint;
    DEFINE v_flag              char(1);
	DEFINE v_ultimodia		 smallint;
	DEFINE v_dias_hab		   char(2);
	DEFINE v_claveparam        char(15);
	
		--Variables Exception
	DEFINE iSqlErr          INTEGER;
	DEFINE iSamErr          INTEGER;
	DEFINE vDesErr          VARCHAR(60); 
	
	DEFINE vtbl               SMALLINT;
    DEFINE vempresa           CHAR(3);    
    DEFINE vccmayor           CHAR(4);    
    DEFINE vccsub             CHAR(2);    
    DEFINE vccsubsub          CHAR(2);    
    DEFINE vccssubsub         CHAR(2);    
    DEFINE vccsssubsub        CHAR(2);    
    DEFINE vsector            CHAR(2);    
    DEFINE vciudad            CHAR(3);    
    DEFINE vsucursal          CHAR(4);    
    DEFINE vmoneda            CHAR(2);    
    DEFINE vfecha             DATE; 
    DEFINE vauxiliar          CHAR(9);    
    DEFINE vcargos_dia        DECIMAL(18,2);
    DEFINE vabonos_dia        DECIMAL(18,2);
    DEFINE vnro_cargos_dia    INTEGER; 
    DEFINE vnro_abonos_dia    INTEGER; 
    DEFINE vdias_proyectado   INTEGER; 
    DEFINE vdias_acumulado    INTEGER; 
    DEFINE vsaldo_acumulado   DECIMAL(18,2);
    DEFINE vsaldo_inicio_dia  DECIMAL(18,2);
    DEFINE vsaldo_fin_de_dia  DECIMAL(18,2);
	DEFINE vfechamesant       DATE;
	DEFINE vfechadicant       DATE;
	DEFINE vfechaanioant 	  DATE;	
	DEFINE vfechamaxentrega   DATE; 	
	DEFINE vfechadiaanterior  DATE;	
	
	DEFINE vcontador          SMALLINT;

	ON EXCEPTION
        SET iSqlErr, iSamErr,vDesErr
        IF iSqlErr <> 0 THEN
            LET r_codret = iSqlErr;
			LET r_mensaje = vDesErr;
        END IF;
        RETURN r_codret, r_mensaje; 
    END EXCEPTION;  
    --set debug file to "/INFORMIXDUMP/spsp_generasaldosanexo43.out";
    --trace on;

    -- ********** Inicializacion de Variables **********
    LET r_codret = '000';
    LET r_mensaje = 'PROCESO SATISFACTORIO';
    LET v_flag 	   = '0';
	LET vcontador  = '0';
    LET vfechamesant      = '';	
	LET vfechadicant      = '';	
	LET vfechaanioant 	  = '';	
	LET vfechamaxentrega  = '';	
	LET vfechadiaanterior = '';		
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
   -- GENERA TABLA DE DIAS HABILES
   LET v_ultimodia = day(p_fechadia);
   --SELECT DISTINCT(MONTH(fechacaptura)) INTO v_dias_hab FROM tmp_weekday;
   --IF MONTH(p_fechadia) <> v_dias_hab OR v_dias_hab IS NULL THEN
	TRUNCATE TABLE tmp_weekday;
	FOREACH WITH HOLD 
		SELECT FIRST v_ultimodia claveparam INTO v_claveparam FROM sp_param
			INSERT INTO tmp_weekday
			SELECT first 1 weekday(MDY(MONTH(p_fechadia),v_ultimodia,YEAR(p_fechadia))),MDY(MONTH(p_fechadia),v_ultimodia,YEAR(p_fechadia)) FROM sp_param;
			LET v_ultimodia = v_ultimodia - 1;	
		CONTINUE FOREACH;
	END FOREACH	
   --END IF;   
   
   IF p_clavereporte = 'ANEX43PREV' THEN
   DELETE  FROM tmp_weekday 
   WHERE  fechacaptura = p_fechadia; 	
   END IF;
   
   IF p_clavereporte = 'ANEXO43' THEN
   DELETE  FROM tmp_weekday 
   WHERE  fechacaptura IN (SELECT fecha FROM bdinteg:si_feriado where (YEAR(fecha) = YEAR(p_fechadia) AND  MONTH(fecha)= MONTH(p_fechadia))) OR dia_sem in (6,0); 	
   END IF;
   
      IF  v_flag = '0'
       AND p_clavereporte     <> 'R040420'      AND p_clavereporte <> 'R040424'             
       AND p_clavereporte     <> 'CRII RANGO'   AND p_clavereporte <> 'R080818MN'           
       AND p_clavereporte     <> 'R080813MN'    AND p_clavereporte <> 'R242412'             
       AND p_clavereporte     <> 'R242411'      AND p_clavereporte <> 'R24D2441'            
	   AND p_clavereporte     <> 'R24D2442' 	AND p_clavereporte <> 'R15A1511'            
	   AND p_clavereporte 	  <> 'R15A1511pm'   AND p_clavereporte <> 'R15B1521'            
	   AND p_clavereporte 	  <> 'R15B1522'		AND p_clavereporte <> 'R28A2811'              
	   AND p_clavereporte 	  <> 'R24B2421'     AND p_clavereporte <> 'R24B2422'              
	   AND p_clavereporte 	  <> 'R24B2423' 	AND p_clavereporte <> 'R24E2450_1'          
	   AND p_clavereporte 	  <> 'R24E2450_2'   AND p_clavereporte <> 'R24E2450_3' 	        
	   AND p_clavereporte 	  <> 'R24E2452'		 	      
	   THEN
            --Elimina los datos de la tabla cuando es necesario y una vez solamente para hacer la carga de informacion.
            TRUNCATE sp_saldos_anexo;
			TRUNCATE sp_generaconsol_log;

            --Carga de las tablas de Saldos y Auxiliares
            IF p_periodicidad = 'D' OR p_periodicidad = 'S' OR p_periodicidad = 'Q' OR p_clavereporte = 'ANEXO43' OR p_clavereporte = 'ANEX43PREV' THEN
			
                --Obtiene Fecha de Contabilidad en anio y mes
                SELECT YEAR(fecha_hoy), MONTH(fecha_hoy)
                INTO   v_aniocontable,  v_mescontable
                FROM   bdicont:co_fechas
                WHERE  empresa = p_empresa;
                --Fecha Proceso en anio y mes
                LET v_anioreporte = YEAR(p_fechadia);
                LET v_mesreporte = MONTH(p_fechadia);

                --Si Contable y Proceso son Diferentes
                IF v_aniocontable != v_anioreporte OR v_mescontable != v_mesreporte THEN
					LET vcontador=1;

					FOREACH WITH HOLD --Sdos				  
                    SELECT 1 TBL,                empresa empresa,
                        ccmayor ccmayor,         ccsub ccsub,
                        ccsubsub ccsubsub,       ccssubsub ccssubsub,
                        ccsssubsub ccsssubsub,   sector sector,
                        ciudad ciudad,           sucursal sucursal,
                        moneda moneda,           mes_dia fecha,
                        '            ' auxiliar,
                        cargos_dia cargos_dia,
                        abonos_dia abonos_dia,
                        nro_cargos_dia nro_cargos_dia,
                        nro_abonos_dia nro_abonos_dia,
                        dias_proyectado dias_proyectado,
                        dias_acumulado dias_acumulado,
                        saldo_acumulado  saldo_acumulado,
                        saldo_inicio_dia saldo_inicio_dia,
                        saldo_fin_de_dia saldo_fin_de_dia
					INTO vtbl,vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,vsector,vciudad,vsucursal,vmoneda,
						vfecha,vauxiliar,vcargos_dia,vabonos_dia,vnro_cargos_dia,vnro_abonos_dia,vdias_proyectado,
						vdias_acumulado,vsaldo_acumulado,vsaldo_inicio_dia,vsaldo_fin_de_dia	
                    FROM   bdicont:co_histsdodias
                    WHERE  empresa = p_empresa
                    AND    mes_dia  IN (Select fechacaptura from tmp_weekday)  
                    
						IF vcontador=1 THEN
							BEGIN WORK;
						END IF
					
						INSERT INTO bdirepaut:sp_saldos_anexo
						VALUES(vtbl,vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,vsector,vciudad,vsucursal,vmoneda,          
							vfecha,vauxiliar,vcargos_dia,vabonos_dia,vnro_cargos_dia,vnro_abonos_dia,vdias_proyectado, 
							vdias_acumulado,vsaldo_acumulado,vsaldo_inicio_dia,vsaldo_fin_de_dia);
							
						IF vcontador >= 1000 then
							COMMIT WORK;
							LET vcontador=1;
						ELSE
							LET vcontador = vcontador + 1 ;
						END IF;
					
						CONTINUE FOREACH;
					END FOREACH;	
				
					IF vcontador > 1 THEN
						COMMIT WORK;
					END IF;
					
					UPDATE STATISTICS MEDIUM FOR TABLE bdirepaut:sp_saldos_anexo;
				
					LET vcontador=1;	
				
					--SodsNvos
					FOREACH WITH HOLD
                    SELECT 2 TBL,                   r.nv_empresa empresa,
                        r.nv_ccmayor ccmayor,       r.nv_ccsub ccsub,
                        r.nv_ccsubsub ccsubsub,     r.nv_ccssubsub ccssubsub,
                        r.nv_ccsssubsub ccsssubsub, r.nv_sector sector,
                        s.ciudad ciudad,            s.sucursal sucursal,
                        s.moneda moneda,            s.mes_dia fecha,
                        '            ' auxiliar,
                        SUM(s.cargos_dia)       cargos_dia,
                        SUM(s.abonos_dia)       abonos_dia,
                        SUM(s.nro_cargos_dia)            nro_cargos_dia,
                        SUM(s.nro_abonos_dia)            nro_abonos_dia,
                        s.dias_proyectado dias_proyectado,
                        s.dias_acumulado dias_acumulado,
                        SUM(s.saldo_acumulado)  saldo_acumulado,
                        SUM(s.saldo_inicio_dia) saldo_inicio_dia,
                        SUM(s.saldo_fin_de_dia) saldo_fin_de_dia
					INTO vtbl,vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,vsector,vciudad,vsucursal,vmoneda,
						vfecha,vauxiliar,vcargos_dia,vabonos_dia,vnro_cargos_dia,vnro_abonos_dia,vdias_proyectado,
						vdias_acumulado,vsaldo_acumulado,vsaldo_inicio_dia,vsaldo_fin_de_dia
                    FROM   bdicont:co_histsdodias s,
                            bdinteg:si_refcruzadacatal r
					WHERE  s.empresa = p_empresa
                    AND    s.mes_dia  IN (Select fechacaptura from tmp_weekday)
                    AND    r.empresa    = s.empresa
                    AND    r.ccmayor    = s.ccmayor
                    AND    r.ccsub      = s.ccsub
                    AND    r.ccsubsub   = s.ccsubsub
                    AND    r.ccssubsub  = s.ccssubsub
                    AND    r.ccsssubsub = s.ccsssubsub
                    AND    r.sector     = s.sector
                    GROUP  BY s.mes_dia,   s.moneda,
                            s.ciudad,       s.sucursal,
                            r.nv_empresa,   r.nv_ccmayor,
                            r.nv_ccsub,     r.nv_ccsubsub,
                            r.nv_ccssubsub, r.nv_ccsssubsub,
                            r.nv_sector,    s.dias_proyectado,
                            s.dias_acumulado
						
						IF vcontador=1 THEN
							BEGIN WORK;
						END IF
						
							INSERT INTO bdirepaut:sp_saldos_anexo
							VALUES(vtbl,vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,vsector,vciudad,vsucursal,vmoneda,          
								   vfecha,vauxiliar,vcargos_dia,vabonos_dia,vnro_cargos_dia,vnro_abonos_dia,vdias_proyectado, 
								   vdias_acumulado,vsaldo_acumulado,vsaldo_inicio_dia,vsaldo_fin_de_dia);
					
						IF vcontador >= 1000 then
							COMMIT WORK;
							LET vcontador=1;
						ELSE
							LET vcontador = vcontador + 1 ;
						END IF;
					
						CONTINUE FOREACH;
					END FOREACH;	

					IF vcontador > 1 THEN
						COMMIT WORK;
					END IF;

					UPDATE STATISTICS MEDIUM FOR TABLE bdirepaut:sp_saldos_anexo;

					LET vcontador=1;

						
                    --Aux1
                    FOREACH WITH HOLD
                    SELECT 3 TBL,                   empresa empresa,
                            ccmayor ccmayor,         ccsub ccsub,
                            ccsubsub ccsubsub,       ccssubsub ccssubsub,
                            ccsssubsub ccsssubsub,   sector sector,
                            ciudad ciudad,           sucursal sucursal,
                            moneda moneda,           mes_dia fecha,
                            auxiliar auxiliar,
                            cargos_dia cargos_dia,
                            abonos_dia abonos_dia,
                            nro_cargos_dia nro_cargos_dia,
                            nro_abonos_dia nro_abonos_dia,
                            dias_proyectado dias_proyectado,
                            dias_acumulados dias_acumulados,
                            saldo_acumulado saldo_acumulado,
                            saldo_inicio_dia saldo_inicio_dia,
                            saldo_fin_de_dia saldo_fin_de_dia
                    INTO vtbl,vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,vsector,vciudad,vsucursal,vmoneda,
						vfecha,vauxiliar,vcargos_dia,vabonos_dia,vnro_cargos_dia,vnro_abonos_dia,vdias_proyectado,
						vdias_acumulado,vsaldo_acumulado,vsaldo_inicio_dia,vsaldo_fin_de_dia
					FROM   bdicont:co_histdiasaux
                    WHERE  empresa = p_empresa
                    AND    mes_dia  IN (Select fechacaptura from tmp_weekday) 
					
					IF vcontador=1 THEN
						BEGIN WORK;
					END IF
						
							INSERT INTO bdirepaut:sp_saldos_anexo
							VALUES(vtbl,vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,vsector,vciudad,vsucursal,vmoneda,          
								   vfecha,vauxiliar,vcargos_dia,vabonos_dia,vnro_cargos_dia,vnro_abonos_dia,vdias_proyectado, 
								   vdias_acumulado,vsaldo_acumulado,vsaldo_inicio_dia,vsaldo_fin_de_dia);
					
						IF vcontador >= 1000 then
							COMMIT WORK;
							LET vcontador=1;
						ELSE
							LET vcontador = vcontador + 1 ;
						END IF;
					
						CONTINUE FOREACH;
					END FOREACH;	
					
					IF vcontador > 1 THEN
						COMMIT WORK;
					END IF;
				
					UPDATE STATISTICS MEDIUM FOR TABLE bdirepaut:sp_saldos_anexo;

					LET vcontador=1;
					
					
                    --Aux2
                    FOREACH WITH HOLD
                    SELECT 4 TBL,                   empresa empresa,
                            ccmayor ccmayor,         ccsub ccsub,
                            ccsubsub ccsubsub,       ccssubsub ccssubsub,
                            ccsssubsub ccsssubsub,   sector sector,
                            ciudad ciudad,           sucursal sucursal,
                            moneda moneda,           mes_dia fecha,
                            auxiliar auxiliar,
                            cargos_dia cargos_dia,
                            abonos_dia abonos_dia,
                            nro_cargos_dia nro_cargos_dia,
                            nro_abonos_dia nro_abonos_dia,
                            dias_proyectado dias_proyectado,
                            dias_acumulados dias_acumulados,
                            saldo_acumulado saldo_acumulado,
                            saldo_inicio_dia saldo_inicio_dia,
                            saldo_fin_de_dia saldo_fin_de_dia
                    INTO vtbl,vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,vsector,vciudad,vsucursal,vmoneda,
						vfecha,vauxiliar,vcargos_dia,vabonos_dia,vnro_cargos_dia,vnro_abonos_dia,vdias_proyectado,
						vdias_acumulado,vsaldo_acumulado,vsaldo_inicio_dia,vsaldo_fin_de_dia
					FROM   bdicont:co_histdiasaux
                    WHERE  empresa = p_empresa
                    AND    mes_dia  IN (Select fechacaptura from tmp_weekday) 
					
						IF vcontador=1 THEN
							BEGIN WORK;
						END IF
						
							INSERT INTO bdirepaut:sp_saldos_anexo
							VALUES(vtbl,vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,vsector,vciudad,vsucursal,vmoneda,          
								   vfecha,vauxiliar,vcargos_dia,vabonos_dia,vnro_cargos_dia,vnro_abonos_dia,vdias_proyectado, 
								   vdias_acumulado,vsaldo_acumulado,vsaldo_inicio_dia,vsaldo_fin_de_dia);
					
						IF vcontador >= 1000 then
							COMMIT WORK;
							LET vcontador=1;
						ELSE
							LET vcontador = vcontador + 1 ;
						END IF;
					
						CONTINUE FOREACH;
					END FOREACH;	
				
					IF vcontador > 1 THEN
						COMMIT WORK;
					END IF;				
				
					UPDATE STATISTICS MEDIUM FOR TABLE bdirepaut:sp_saldos_anexo;
				
                ELSE --Contable y Proceso son Iguales
				
                    LET vcontador=1;

					FOREACH WITH HOLD --Sdos
                    SELECT 1 TBL,                   empresa empresa,
                            ccmayor ccmayor,         ccsub ccsub,
                            ccsubsub ccsubsub,       ccssubsub ccssubsub,
                            ccsssubsub ccsssubsub,   sector sector,
                            ciudad ciudad,           sucursal sucursal,
                            moneda moneda,           mes_dia fecha,
                            '            ' auxiliar,
                            cargos_dia cargos_dia,
                            abonos_dia abonos_dia,
                            nro_cargos_dia nro_cargos_dia,
                            nro_abonos_dia nro_abonos_dia,
                            dias_proyectado dias_proyectado,
                            dias_acumulado dias_acumulado,
                            saldo_acumulado  saldo_acumulado,
                            saldo_inicio_dia saldo_inicio_dia,
                            saldo_fin_de_dia saldo_fin_de_dia
					INTO    vtbl,vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,vsector,vciudad,vsucursal,vmoneda,
						vfecha,vauxiliar,vcargos_dia,vabonos_dia,vnro_cargos_dia,vnro_abonos_dia,vdias_proyectado,
						vdias_acumulado,vsaldo_acumulado,vsaldo_inicio_dia,vsaldo_fin_de_dia
                    FROM   bdicont:co_sdodias
                    WHERE  empresa = p_empresa
                    AND    mes_dia IN (Select fechacaptura from tmp_weekday)   

					IF vcontador=1 THEN
						BEGIN WORK;
					END IF
						
							INSERT INTO bdirepaut:sp_saldos_anexo
							VALUES(vtbl,vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,vsector,vciudad,vsucursal,vmoneda,          
								   vfecha,vauxiliar,vcargos_dia,vabonos_dia,vnro_cargos_dia,vnro_abonos_dia,vdias_proyectado, 
								   vdias_acumulado,vsaldo_acumulado,vsaldo_inicio_dia,vsaldo_fin_de_dia);
					
						IF vcontador >= 1000 then
							COMMIT WORK;
							LET vcontador=1;
						ELSE
							LET vcontador = vcontador + 1 ;
						END IF;
					
						CONTINUE FOREACH;
					END FOREACH;	
				
					IF vcontador > 1 THEN
						COMMIT WORK;
					END IF;
					
					UPDATE STATISTICS MEDIUM FOR TABLE bdirepaut:sp_saldos_anexo;
				
					LET vcontador=1;					
					
                    --SodsNvos
                    FOREACH WITH HOLD
                    SELECT 2 TBL,                      r.nv_empresa empresa,
                            r.nv_ccmayor ccmayor,       r.nv_ccsub ccsub,
                            r.nv_ccsubsub ccsubsub,     r.nv_ccssubsub ccssubsub,
                            r.nv_ccsssubsub ccsssubsub, r.nv_sector sector,
                            s.ciudad ciudad,            s.sucursal sucursal,
                            s.moneda moneda,            s.mes_dia fecha,
                            '            ' auxiliar,
                            SUM(s.cargos_dia)       cargos_dia,
                            SUM(s.abonos_dia)       abonos_dia,
                            SUM(s.nro_cargos_dia)            nro_cargos_dia,
                            SUM(s.nro_abonos_dia)            nro_abonos_dia,
                            s.dias_proyectado dias_proyectado,
                            s.dias_acumulado dias_acumulado,
                            SUM(s.saldo_acumulado)  saldo_acumulado,
                            SUM(s.saldo_inicio_dia) saldo_inicio_dia,
                            SUM(s.saldo_fin_de_dia) saldo_fin_de_dia
					INTO    vtbl,vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,vsector,vciudad,vsucursal,vmoneda,
						vfecha,vauxiliar,vcargos_dia,vabonos_dia,vnro_cargos_dia,vnro_abonos_dia,vdias_proyectado,
						vdias_acumulado,vsaldo_acumulado,vsaldo_inicio_dia,vsaldo_fin_de_dia
                    FROM   bdicont:co_sdodias s,
                            bdinteg:si_refcruzadacatal r
                    WHERE  r.empresa    = s.empresa
                    AND    r.ccmayor    = s.ccmayor
                    AND    r.ccsub      = s.ccsub
                    AND    r.ccsubsub   = s.ccsubsub
                    AND    r.ccssubsub  = s.ccssubsub
                    AND    r.ccsssubsub = s.ccsssubsub
                    AND    r.sector     = s.sector
                    AND    s.empresa    = p_empresa
                    AND    s.mes_dia  IN (Select fechacaptura from tmp_weekday) 
                    GROUP  BY s.mes_dia,   s.moneda,
                            s.ciudad,       s.sucursal,
                            r.nv_empresa,   r.nv_ccmayor,
                            r.nv_ccsub,     r.nv_ccsubsub,
                            r.nv_ccssubsub, r.nv_ccsssubsub,
                            r.nv_sector,    s.dias_proyectado,
                            s.dias_acumulado  
						IF vcontador=1 THEN
							BEGIN WORK;
						END IF
						
							INSERT INTO bdirepaut:sp_saldos_anexo
							VALUES(vtbl,vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,vsector,vciudad,vsucursal,vmoneda,          
								   vfecha,vauxiliar,vcargos_dia,vabonos_dia,vnro_cargos_dia,vnro_abonos_dia,vdias_proyectado, 
								   vdias_acumulado,vsaldo_acumulado,vsaldo_inicio_dia,vsaldo_fin_de_dia);
					
						IF vcontador >= 1000 then
							COMMIT WORK;
							LET vcontador=1;
						ELSE
							LET vcontador = vcontador + 1 ;
						END IF;
					
						CONTINUE FOREACH;
					END FOREACH;	

					IF vcontador > 1 THEN
						COMMIT WORK;
					END IF;

					UPDATE STATISTICS MEDIUM FOR TABLE bdirepaut:sp_saldos_anexo;

					LET vcontador=1;		
                    --Aux1
                    FOREACH WITH HOLD
                    SELECT 3 TBL,                 empresa empresa,
                            ccmayor ccmayor,       ccsub ccsub,
                            ccsubsub ccsubsub,     ccssubsub ccssubsub,
                            ccsssubsub ccsssubsub, sector sector,
                            ciudad ciudad,         sucursal sucursal,
                            moneda moneda,         mes_dia fecha,
                            auxiliar auxiliar,
                            cargos_dia cargos_dia,
                            abonos_dia abonos_dia,
                            nro_cargos_dia nro_cargos_dia,
                            nro_abonos_dia nro_abonos_dia,
                            dias_proyectado dias_proyectado,
                            dias_acumulados dias_acumulados,
                            saldo_acumulado saldo_acumulado,
                            saldo_inicio_dia saldo_inicio_dia,
                            saldo_fin_de_dia saldo_fin_de_dia
					INTO    vtbl,vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,vsector,vciudad,vsucursal,vmoneda,
						vfecha,vauxiliar,vcargos_dia,vabonos_dia,vnro_cargos_dia,vnro_abonos_dia,vdias_proyectado,
						vdias_acumulado,vsaldo_acumulado,vsaldo_inicio_dia,vsaldo_fin_de_dia
                    FROM   bdicont:co_diasaux
                    WHERE  empresa = p_empresa
                    AND    mes_dia  IN (Select fechacaptura from tmp_weekday)   
					
						IF vcontador=1 THEN
							BEGIN WORK;
						END IF
						
							INSERT INTO bdirepaut:sp_saldos_anexo
							VALUES(vtbl,vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,vsector,vciudad,vsucursal,vmoneda,          
								   vfecha,vauxiliar,vcargos_dia,vabonos_dia,vnro_cargos_dia,vnro_abonos_dia,vdias_proyectado, 
								   vdias_acumulado,vsaldo_acumulado,vsaldo_inicio_dia,vsaldo_fin_de_dia);
					
						IF vcontador >= 1000 then
							COMMIT WORK;
							LET vcontador=1;
						ELSE
							LET vcontador = vcontador + 1 ;
						END IF;
					
						CONTINUE FOREACH;
					END FOREACH;	
					
					IF vcontador > 1 THEN
						COMMIT WORK;
					END IF;
				
					UPDATE STATISTICS MEDIUM FOR TABLE bdirepaut:sp_saldos_anexo;

					LET vcontador=1;
                    --Aux2
                    FOREACH WITH HOLD
                    SELECT 4 TBL,                 empresa empresa,
                            ccmayor ccmayor,       ccsub ccsub,
                            ccsubsub ccsubsub,     ccssubsub ccssubsub,
                            ccsssubsub ccsssubsub, sector sector,
                            ciudad ciudad,         sucursal sucursal,
                            moneda moneda,         mes_dia fecha,
                            auxiliar auxiliar,
                            cargos_dia cargos_dia,
                            abonos_dia abonos_dia,
                            nro_cargos_dia nro_cargos_dia,
                            nro_abonos_dia nro_abonos_dia,
                            dias_proyectado dias_proyectado,
                            dias_acumulados dias_acumulados,
                            saldo_acumulado saldo_acumulado,
                            saldo_inicio_dia saldo_inicio_dia,
                            saldo_fin_de_dia saldo_fin_de_dia
					INTO vtbl,vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,vsector,vciudad,vsucursal,vmoneda,
						vfecha,vauxiliar,vcargos_dia,vabonos_dia,vnro_cargos_dia,vnro_abonos_dia,vdias_proyectado,
						vdias_acumulado,vsaldo_acumulado,vsaldo_inicio_dia,vsaldo_fin_de_dia
                    FROM   bdicont:co_diasaux
                    WHERE  empresa = p_empresa
                    AND    mes_dia IN (Select fechacaptura from tmp_weekday)  
						IF vcontador >= 1000 then
							COMMIT WORK;
							LET vcontador=1;
						ELSE
							LET vcontador = vcontador + 1 ;
						END IF;
					
						CONTINUE FOREACH;
					END FOREACH;	
				
					IF vcontador > 1 THEN
						COMMIT WORK;
					END IF;				
				
					UPDATE STATISTICS MEDIUM FOR TABLE bdirepaut:sp_saldos_anexo;

				END IF;
			
            
            ELSE  --Reportes de Mas de un Mes
			
				LET vcontador=1;

				FOREACH WITH HOLD --Sdos
                SELECT 1 TBL,                    empresa empresa,
                        ccmayor ccmayor,         ccsub ccsub,
                        ccsubsub ccsubsub,       ccssubsub ccssubsub,
                        ccsssubsub ccsssubsub,   sector sector,
                        ciudad ciudad,           sucursal sucursal,
                        moneda moneda,           ano_mes fecha,
                        '            ' auxiliar,
                        cargos_mes cargos_dia,
                        abonos_mes abonos_dia,
                        nro_cargos_mes nro_cargos_dia,
                        nro_abonos_mes nro_abonos_dia,
                        dias_proyectado dias_proyectado,
                        dias_acumulado dias_acumulado,
                        saldo_acumulado  saldo_acumulado,
                        saldo_inicio_mes saldo_inicio_dia,
                        saldo_fin_de_mes saldo_fin_de_dia
				INTO    vtbl,vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,vsector,vciudad,vsucursal,vmoneda,
						vfecha,vauxiliar,vcargos_dia,vabonos_dia,vnro_cargos_dia,vnro_abonos_dia,vdias_proyectado,
						vdias_acumulado,vsaldo_acumulado,vsaldo_inicio_dia,vsaldo_fin_de_dia
                FROM  bdicont:co_sdomes
				WHERE ccmayor IS NOT NULL
				  AND ano_mes = EXTEND(MDY(MONTH(p_fechadia),1,YEAR(p_fechadia)),YEAR TO SECOND) 
				  
					IF vcontador=1 THEN
						BEGIN WORK;
					END IF
						
							INSERT INTO bdirepaut:sp_saldos_anexo
							VALUES(vtbl,vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,vsector,vciudad,vsucursal,vmoneda,          
								   vfecha,vauxiliar,vcargos_dia,vabonos_dia,vnro_cargos_dia,vnro_abonos_dia,vdias_proyectado, 
								   vdias_acumulado,vsaldo_acumulado,vsaldo_inicio_dia,vsaldo_fin_de_dia);
					
						IF vcontador >= 1000 then
							COMMIT WORK;
							LET vcontador=1;
					ELSE
						LET vcontador = vcontador + 1 ;
					END IF;
					
					CONTINUE FOREACH;
				END FOREACH;	
				
				IF vcontador > 1 THEN
					COMMIT WORK;
				END IF;
					
				UPDATE STATISTICS MEDIUM FOR TABLE bdirepaut:sp_saldos_anexo;
				
				LET vcontador=1;
				
                --SodsNvos
                FOREACH WITH HOLD
                SELECT 2 TBL,                      r.nv_empresa empresa,
                        r.nv_ccmayor ccmayor,       r.nv_ccsub ccsub,
                        r.nv_ccsubsub ccsubsub,     r.nv_ccssubsub ccssubsub,
                        r.nv_ccsssubsub ccsssubsub, r.nv_sector sector,
                        s.ciudad ciudad,            s.sucursal sucursal,
                        s.moneda moneda,            s.ano_mes fecha,
                        '            ' auxiliar,
                        SUM(s.cargos_mes) cargos_dia,
                        SUM(s.abonos_mes) abonos_dia,
                        SUM(s.nro_cargos_mes) nro_cargos_dia,
                        SUM(s.nro_abonos_mes) nro_abonos_dia,
                        s.dias_proyectado dias_proyectado,
                        s.dias_acumulado dias_acumulado,
                        SUM(s.saldo_acumulado)  saldo_acumulado,
                        SUM(s.saldo_inicio_mes) saldo_inicio_dia,
                        SUM(s.saldo_fin_de_mes) saldo_fin_de_dia
				INTO    vtbl,vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,vsector,vciudad,vsucursal,vmoneda,
						vfecha,vauxiliar,vcargos_dia,vabonos_dia,vnro_cargos_dia,vnro_abonos_dia,vdias_proyectado,
						vdias_acumulado,vsaldo_acumulado,vsaldo_inicio_dia,vsaldo_fin_de_dia
                FROM   bdicont:co_sdomes s,
                       bdinteg:si_refcruzadacatal r
                WHERE  r.empresa    = s.empresa
                AND    r.ccmayor    = s.ccmayor
                AND    r.ccsub      = s.ccsub
                AND    r.ccsubsub   = s.ccsubsub
                AND    r.ccssubsub  = s.ccssubsub
                AND    r.ccsssubsub = s.ccsssubsub
                AND    r.sector     = s.sector
                AND    s.empresa    = p_empresa
				AND    s.ano_mes = EXTEND(MDY(MONTH(p_fechadia),1,YEAR(p_fechadia)),YEAR TO SECOND) 
                GROUP  BY s.ano_mes,   s.moneda,
                        s.ciudad,       s.sucursal,
                        r.nv_empresa,   r.nv_ccmayor,
                        r.nv_ccsub,     r.nv_ccsubsub,
                        r.nv_ccssubsub, r.nv_ccsssubsub,
                        r.nv_sector,    s.dias_proyectado,
                        s.dias_acumulado  

					IF vcontador=1 THEN
						BEGIN WORK;
					END IF
						
							INSERT INTO bdirepaut:sp_saldos_anexo
							VALUES(vtbl,vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,vsector,vciudad,vsucursal,vmoneda,          
								   vfecha,vauxiliar,vcargos_dia,vabonos_dia,vnro_cargos_dia,vnro_abonos_dia,vdias_proyectado, 
								   vdias_acumulado,vsaldo_acumulado,vsaldo_inicio_dia,vsaldo_fin_de_dia);
					
						IF vcontador >= 1000 then
							COMMIT WORK;
							LET vcontador=1;
					ELSE
						LET vcontador = vcontador + 1 ;
					END IF;
					
					CONTINUE FOREACH;
				END FOREACH;	

				IF vcontador > 1 THEN
					COMMIT WORK;
				END IF;

				UPDATE STATISTICS MEDIUM FOR TABLE bdirepaut:sp_saldos_anexo;

				LET vcontador=1;
                --Aux1
                
				FOREACH WITH HOLD
                SELECT 3 TBL,                 empresa empresa,
                        ccmayor ccmayor,       ccsub ccsub,
                        ccsubsub ccsubsub,     ccssubsub ccssubsub,
                        ccsssubsub ccsssubsub, sector sector,
                        ciudad ciudad,         sucursal sucursal,
                        moneda moneda,         ano_mes fecha,
                        auxiliar auxiliar,
                        cargos_mes cargos_dia,
                        abonos_mes abonos_dia,
                        nro_cargos_mes nro_cargos_dia,
                        nro_abonos_mes nro_abonos_dia,
                        0 dias_proyectado,
                        dias_acumulados dias_acumulados,
                        saldo_acumulado saldo_acumulado,
                        saldo_inicio_mes saldo_inicio_dia,
                        saldo_fin_de_mes saldo_fin_de_dia
                INTO    vtbl,vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,vsector,vciudad,vsucursal,vmoneda,
						vfecha,vauxiliar,vcargos_dia,vabonos_dia,vnro_cargos_dia,vnro_abonos_dia,vdias_proyectado,
						vdias_acumulado,vsaldo_acumulado,vsaldo_inicio_dia,vsaldo_fin_de_dia
				FROM   bdicont:co_mesaux
                WHERE  empresa = p_empresa 
				  AND  ano_mes = EXTEND(MDY(MONTH(p_fechadia),1,YEAR(p_fechadia)),YEAR TO SECOND) 
                
					IF vcontador=1 THEN
						BEGIN WORK;
					END IF
						
							INSERT INTO bdirepaut:sp_saldos_anexo
							VALUES(vtbl,vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,vsector,vciudad,vsucursal,vmoneda,          
								   vfecha,vauxiliar,vcargos_dia,vabonos_dia,vnro_cargos_dia,vnro_abonos_dia,vdias_proyectado, 
								   vdias_acumulado,vsaldo_acumulado,vsaldo_inicio_dia,vsaldo_fin_de_dia);
					
						IF vcontador >= 1000 then
							COMMIT WORK;
							LET vcontador=1;
					ELSE
						LET vcontador = vcontador + 1 ;
					END IF;
					
					CONTINUE FOREACH;
				END FOREACH;	
					
				IF vcontador > 1 THEN
					COMMIT WORK;
				END IF;
				
				UPDATE STATISTICS MEDIUM FOR TABLE bdirepaut:sp_saldos_anexo;

				LET vcontador=1;
                --Aux2

				FOREACH WITH HOLD
                SELECT 4 TBL,                 empresa empresa,
                        ccmayor ccmayor,       ccsub ccsub,
                        ccsubsub ccsubsub,     ccssubsub ccssubsub,
                        ccsssubsub ccsssubsub, sector sector,
                        ciudad ciudad,         sucursal sucursal,
                        moneda moneda,         ano_mes fecha,
                        auxiliar auxiliar,
                        cargos_mes cargos_dia,
                        abonos_mes abonos_dia,
                        nro_cargos_mes nro_cargos_dia,
                        nro_abonos_mes nro_abonos_dia,
                        0 dias_proyectado,
                        dias_acumulados dias_acumulados,
                        saldo_acumulado saldo_acumulado,
                        saldo_inicio_mes saldo_inicio_dia,
                        saldo_fin_de_mes saldo_fin_de_dia
                INTO    vtbl,vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,vsector,vciudad,vsucursal,vmoneda,
						vfecha,vauxiliar,vcargos_dia,vabonos_dia,vnro_cargos_dia,vnro_abonos_dia,vdias_proyectado,
						vdias_acumulado,vsaldo_acumulado,vsaldo_inicio_dia,vsaldo_fin_de_dia
                FROM   bdicont:co_mesaux
                WHERE  empresa = p_empresa 
				  AND  ano_mes = EXTEND(MDY(MONTH(p_fechadia),1,YEAR(p_fechadia)),YEAR TO SECOND) 
				  
					IF vcontador=1 THEN
						BEGIN WORK;
					END IF
						
							INSERT INTO bdirepaut:sp_saldos_anexo
							VALUES(vtbl,vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,vsector,vciudad,vsucursal,vmoneda,          
								   vfecha,vauxiliar,vcargos_dia,vabonos_dia,vnro_cargos_dia,vnro_abonos_dia,vdias_proyectado, 
								   vdias_acumulado,vsaldo_acumulado,vsaldo_inicio_dia,vsaldo_fin_de_dia);
					
						IF vcontador >= 1000 then
							COMMIT WORK;
							LET vcontador=1;
					ELSE
						LET vcontador = vcontador + 1 ;
					END IF;
					
					CONTINUE FOREACH;
				END FOREACH;	
				
				IF vcontador > 1 THEN
					COMMIT WORK;
				END IF;				
				
				UPDATE STATISTICS MEDIUM FOR TABLE bdirepaut:sp_saldos_anexo;

            END IF;
			
			UPDATE STATISTICS MEDIUM FOR TABLE bdirepaut:sp_saldos_anexo;
						
       END IF
	   
    --Fin del Proceso
    LET r_codret = '000';
    LET r_mensaje = 'PROCESO SATISFACTORIO';
    RETURN r_codret, r_mensaje;

END PROCEDURE;