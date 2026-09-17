CREATE PROCEDURE "informix".spsp_generasaldos(p_empresa CHAR(3), p_fechadia DATE, p_periodicidad VARCHAR(1))
RETURNING char(5), varchar(255);
    --Variables de Retorno
    DEFINE r_codret   char(5);
    DEFINE r_mensaje  varchar(255);	
    -- Variables para reportes
    DEFINE v_identautoridad    varchar(8);
    DEFINE v_clavereporte      varchar(10);
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
	
    --set debug file to "/INFORMIXDUMP/spsp_generasaldos.out";
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
	
	-- Deshabilita Generación de Saldos
	SELECT nvl(valorparam,0) INTO v_flag
	  FROM bdirepaut:sp_param
     WHERE claveparam ='10'
	   AND empresa='001';

    --Ciclo para Obtener Los Reportes
    FOREACH WITH HOLD 
        SELECT r.identautoridad,    r.clavereporte,
               r.claveperiodicidad, r.claveprioridad,
               r.clavetiporep,
               p.fechaproyec,       p.fechamesant,
               p.fechadicant,       p.fechaanioant,
               p.fechadiaanterior
        INTO   v_identautoridad,    v_clavereporte,
               v_claveperiodicidad, v_claveprioridad,
               v_clavetiporep,
               v_fechaproyec,       v_fechamesant,
               v_fechadicant,       v_fechaanioant,
               v_fechadiaanterior 
        FROM   bdirepaut:sp_controlproceso p, bdirepaut:sp_clavesreportes r
        WHERE  r.identautoridad = p.identautoridad
        AND    r.empresa = p.empresa
        AND    r.clavereporte = p.clavereporte
        AND    p.statusproceso IN ('P','R')
        AND    p.fechacontroldia = p_fechadia
        AND   (r.claveperiodicidad = p_periodicidad OR p_periodicidad = '')
        AND    r.clavetiporep IN ('C', 'N')
        ORDER  BY 1, 2
		

		
       IF  v_flag = '0'
       AND v_clavereporte     <> 'R040420'      AND v_clavereporte <> 'R040424'             
       AND v_clavereporte     <> 'CRII RANGO'   AND v_clavereporte <> 'R080818MN'           
       AND v_clavereporte     <> 'R080813MN'    AND v_clavereporte <> 'R242412'             
       AND v_clavereporte     <> 'R242411'      AND v_clavereporte <> 'R24D2441'            
	   AND v_clavereporte     <> 'R24D2442' 	AND v_clavereporte <> 'R15A1511'            
	   AND v_clavereporte 	  <> 'R15A1511pm'   AND v_clavereporte <> 'R15B1521'            
	   AND v_clavereporte 	  <> 'R15B1522'		AND v_clavereporte <> 'R28A2811'              
	   AND v_clavereporte 	  <> 'R24B2421'     AND v_clavereporte <> 'R24B2422'              
	   AND v_clavereporte 	  <> 'R24B2423' 	AND v_clavereporte <> 'R24E2450_1'          
	   AND v_clavereporte 	  <> 'R24E2450_2'   AND v_clavereporte <> 'R24E2450_3' 	        
	   AND v_clavereporte 	  <> 'R24E2452'		 	      
	   THEN
            --Elimina los datos de la tabla cuando es necesario y una vez solamente para hacer la carga de informacion.
            TRUNCATE sp_saldos;
			TRUNCATE sp_generaconsol_log;															   		
		IF  v_clavereporte = 'ANEXO43' OR v_clavereporte = 'ANEX43PREV'  THEN 		
			EXECUTE PROCEDURE spsp_generasaldos_anexo43(p_empresa, p_fechadia,v_clavereporte, p_periodicidad )
            INTO r_codret, r_mensaje;	
			
			DELETE FROM bdirepaut:sp_filtroreporte_anexo
			WHERE clavereporte = v_clavereporte
			   AND fecha <= p_fechadia;
		ELSE 
            --Carga de las tablas de Saldos y Auxiliares
            IF p_periodicidad = 'D' OR p_periodicidad = 'S' OR p_periodicidad = 'Q' THEN
			
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
				
                    --Sdos      
                    INSERT INTO sp_saldos
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
                        FROM   bdicont:co_histsdodias
                        WHERE  empresa = p_empresa
                        AND    mes_dia = p_fechadia  ;  
                    
					--SodsNvos
                    INSERT INTO sp_saldos
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
                    FROM   bdicont:co_histsdodias s,
                            bdinteg:si_refcruzadacatal r
                    WHERE  s.empresa = p_empresa
                    AND    s.mes_dia = p_fechadia
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
                            s.dias_acumulado;
							
                    --Aux1
                    INSERT INTO sp_saldos
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
                    FROM   bdicont:co_histdiasaux
                    WHERE  empresa = p_empresa
                    AND    mes_dia = p_fechadia ; 
                    --Aux2
                    INSERT INTO sp_saldos
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
                    FROM   bdicont:co_histdiasaux
                    WHERE  empresa = p_empresa
                    AND    mes_dia = p_fechadia ; 
				
                ELSE --Contable y Proceso son Iguales
				
                    --Sdos
                    INSERT INTO sp_saldos
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
                    FROM   bdicont:co_sdodias
                    WHERE  empresa = p_empresa
                    AND    mes_dia = p_fechadia  ;   
					
                    --SodsNvos
                    INSERT INTO sp_saldos
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
                    AND    s.mes_dia    = p_fechadia  
                    GROUP  BY s.mes_dia,   s.moneda,
                            s.ciudad,       s.sucursal,
                            r.nv_empresa,   r.nv_ccmayor,
                            r.nv_ccsub,     r.nv_ccsubsub,
                            r.nv_ccssubsub, r.nv_ccsssubsub,
                            r.nv_sector,    s.dias_proyectado,
                            s.dias_acumulado  ;
							
                    --Aux1
                    INSERT INTO sp_saldos
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
                    FROM   bdicont:co_diasaux
                    WHERE  empresa = p_empresa
                    AND    mes_dia = p_fechadia ;  
					
                    --Aux2
                    INSERT INTO sp_saldos
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
                    FROM   bdicont:co_diasaux
                    WHERE  empresa = p_empresa
                    AND    mes_dia = p_fechadia ; 
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
						
							INSERT INTO bdirepaut:sp_saldos
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
					
				UPDATE STATISTICS MEDIUM FOR TABLE bdirepaut:sp_saldos;
				
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
						
							INSERT INTO bdirepaut:sp_saldos
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

				UPDATE STATISTICS MEDIUM FOR TABLE bdirepaut:sp_saldos;

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
						
							INSERT INTO bdirepaut:sp_saldos
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
				
				UPDATE STATISTICS MEDIUM FOR TABLE bdirepaut:sp_saldos;

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
						
							INSERT INTO bdirepaut:sp_saldos
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
				
				UPDATE STATISTICS MEDIUM FOR TABLE bdirepaut:sp_saldos;

            END IF;
			
			UPDATE STATISTICS MEDIUM FOR TABLE bdirepaut:sp_saldos;
								   
		END IF; 
	   END IF;
       --Actualiza saldos a Cero para Cuenta Totalizadora
       
	   IF  v_clavereporte = 'ANEXO43' OR v_clavereporte = 'ANEX43PREV'  THEN	
	   --IF (v_clavereporte = 'ANEXO43' ) THEN		   
	   		UPDATE bdirepaut:sp_filtroreporte_anexo
			SET    saldocontable = 0,
					saldonacional = 0,
					saldocifra = 0
			WHERE  identautoridad = v_identautoridad
			AND    empresa        = p_empresa
			AND    clavereporte   = v_clavereporte
			AND    unicatotal     = 'T';
	   
	   ELSE 
			UPDATE bdirepaut:sp_filtroreporte
			SET    saldocontable = 0,
					saldonacional = 0,
					saldocifra = 0
			WHERE  identautoridad = v_identautoridad
			AND    empresa        = p_empresa
			AND    clavereporte   = v_clavereporte
			AND    unicatotal     = 'T';
		END IF;
		
	   IF  v_clavereporte <> 'R040420'     AND v_clavereporte <> 'R040424' 	   
	   AND v_clavereporte <> 'CRII RANGO'  AND v_clavereporte <> 'R080818MN'	   
	   AND v_clavereporte <> 'R080813MN'   AND v_clavereporte <> 'R242412'       
	   AND v_clavereporte <> 'R242411'     AND v_clavereporte <> 'R24D2441'       
	   AND v_clavereporte <> 'R24D2442'    AND v_clavereporte <> 'R15A1511'         
	   AND v_clavereporte <> 'R15B1521'    AND v_clavereporte <> 'R15B1522'         
	   AND v_clavereporte <> 'R28A2811'	   AND v_clavereporte <> 'R24B2421'	   
	   AND v_clavereporte <> 'R24B2422'	   AND v_clavereporte <> 'R24B2423'	     
	   AND v_clavereporte <> 'R15A1511pm'  AND v_clavereporte <> 'R24E2450_1'	    
	   AND v_clavereporte <> 'R24E2450_2'  AND v_clavereporte <> 'R24E2450_3'	     
	   AND v_clavereporte <> 'R24E2452'	   
	   --AND v_clavereporte <> 'ANEXO43'    AND v_clavereporte <> 'ANEX43PREV'	   
	   THEN

            --Ejecuta el consolidado Actualizando filtroreporte
            EXECUTE PROCEDURE SPSP_GENERACONSOL(v_identautoridad,  p_empresa,
                                                v_clavereporte,    p_fechadia,
                                                v_fechaproyec,     v_fechamesant,
                                                v_fechadicant,     v_fechaanioant,
                                                v_fechadiaanterior)
            INTO r_codret, r_mensaje;
			
            IF r_codret <> '000' THEN
                LET r_mensaje = 'ERR. CONSOLIDADO : ' || r_codret || ' ' || r_mensaje;
                LET r_codret = '001';
                RETURN r_codret, r_mensaje;
            END IF;
			
       END IF

       --Ejecuta Carga de Resumenes Actualiza filtroresumen


      --Ejecuta Carga de Resumenes DE FILTRORESUMEN a RESUMENFILTRO
      --Proceso Temporal En lo que se pasa Macros Excel a Codigo
      IF  v_clavereporte = 'ANEXO43' OR v_clavereporte = 'ANEX43PREV'  THEN	
	  --IF  (v_clavereporte = 'ANEXO43' ) THEN		
	    EXECUTE PROCEDURE SPSP_RESUMEN_ANEXO(v_identautoridad,  p_empresa,
                                      v_clavereporte,    v_claveperiodicidad,
                                      v_claveprioridad)
       INTO r_codret, r_mensaje;
	   
		IF r_codret <> '000' THEN
			LET r_mensaje = 'ERR. RESUMEN : ' || r_codret || ' ' || r_mensaje;
			LET r_codret = '002';
			RETURN r_codret, r_mensaje;
		END IF;
	  
	  	EXECUTE PROCEDURE SPSP_PASOINFO_ANEXO(v_identautoridad,  p_empresa,
                                      v_clavereporte,    v_claveperiodicidad)
		INTO r_codret, r_mensaje;
	  ELSE 
	  
	    EXECUTE PROCEDURE SPSP_RESUMEN(v_identautoridad,  p_empresa,
                                      v_clavereporte,    v_claveperiodicidad,
                                      v_claveprioridad)
       INTO r_codret, r_mensaje;
	   
		IF r_codret <> '000' THEN
			LET r_mensaje = 'ERR. RESUMEN : ' || r_codret || ' ' || r_mensaje;
			LET r_codret = '002';
			RETURN r_codret, r_mensaje;
		END IF;
		EXECUTE PROCEDURE SPSP_PASOINFO(v_identautoridad,  p_empresa,
                                      v_clavereporte,    v_claveperiodicidad)
		INTO r_codret, r_mensaje;
	  END IF 	
	  
    IF r_codret <> '000' THEN
         LET r_mensaje = 'ERR. PASOINFO : ' || r_codret || ' ' || r_mensaje;
         LET r_codret = '003';
         RETURN r_codret, r_mensaje;
    END IF;
	  
 		

    IF v_clavereporte = 'CRII RANGO' THEN
        EXECUTE PROCEDURE spsp_crii(p_empresa, p_fechadia)
        INTO r_codret;
        IF r_codret <> '000' THEN
            RETURN r_codret, r_mensaje;
        END IF
		
		
	ELIF v_clavereporte = 'R24B2421' THEN
		EXECUTE PROCEDURE spsp_r2421(p_empresa, p_fechadia)
		INTO r_codret, r_mensaje;
		IF r_codret <> '000' THEN
			RETURN r_codret, r_mensaje;
		END IF	
		
		
	ELIF v_clavereporte = 'R24B2422' THEN
		EXECUTE PROCEDURE sp_r24b2422(p_empresa, p_fechadia)
		INTO r_codret, r_mensaje;
		IF r_codret <> '000' THEN
			RETURN r_codret, r_mensaje;
		END IF	

	ELIF v_clavereporte = 'R24C2431' THEN
		EXECUTE PROCEDURE spsp_r24C2431(p_empresa, p_fechadia)
		INTO r_codret, r_mensaje;
		IF r_codret <> '000' THEN
			RETURN r_codret, r_mensaje;
	  END IF	

	ELIF v_clavereporte = 'R24D2441' OR v_clavereporte = 'R24D2442' THEN
		EXECUTE PROCEDURE spsp_r24d2441(p_empresa, p_fechadia)
		INTO r_codret, r_mensaje;
		IF r_codret <> '000' THEN
			RETURN r_codret, r_mensaje;
	    END IF	
	  

	ELIF v_clavereporte = 'R026' THEN
		EXECUTE PROCEDURE spsp_r026(p_empresa, p_fechadia)
		INTO r_codret, r_mensaje;
		IF r_codret <> '000' THEN
			RETURN r_codret, r_mensaje;
		END IF
		
	ELIF v_clavereporte = 'R027' THEN
		EXECUTE PROCEDURE spsp_r027(p_empresa, p_fechadia)
		INTO r_codret, r_mensaje;
		IF r_codret <> '000' THEN
			RETURN r_codret, r_mensaje;
		END IF		
	
		
	ELIF v_clavereporte = 'CRII' THEN
		EXECUTE PROCEDURE sp_crii_calcsaldos(p_empresa, p_fechadia)
		INTO r_codret;
		IF r_codret <> '000' THEN
			RETURN r_codret, r_mensaje;
		END IF

    ELIF v_clavereporte = 'R080811MN' THEN
        EXECUTE PROCEDURE spsp_calcula_saldos(p_fechadia,p_empresa)
        INTO r_codret,r_mensaje;
        IF r_codret <> '000' THEN
            RETURN r_codret, r_mensaje;
        END IF

    ELIF v_clavereporte = 'R080813MN' THEN
        EXECUTE PROCEDURE r08a0813(p_empresa, p_fechadia)
        INTO r_codret;
        IF r_codret <> '000' THEN
            RETURN r_codret, r_mensaje;
        END IF
      
    ELIF v_clavereporte = 'R080818MN' THEN
        EXECUTE PROCEDURE r08a0818(p_empresa, p_fechadia)
        INTO r_codret;
        IF r_codret <> '000' THEN
            RETURN r_codret, r_mensaje;
        END IF
      
    ELIF v_clavereporte = 'R040420' THEN
        EXECUTE PROCEDURE R04A0420(p_empresa, p_fechadia)
        INTO r_codret,r_mensaje;
        IF r_codret <> '000' THEN
           RETURN r_codret, r_mensaje;
        END IF
      
    ELIF v_clavereporte = 'R040424' THEN
        EXECUTE PROCEDURE R04A0424(p_empresa, p_fechadia)
        INTO r_codret,r_mensaje;
        IF r_codret <> '000' THEN
            RETURN r_codret, r_mensaje;
        END IF
      
    ELIF v_clavereporte = 'R05' THEN
         EXECUTE PROCEDURE spsp_obten_r05(p_fechadia,p_empresa)
         INTO r_codret,r_mensaje;
         IF r_codret <> '000' THEN
            RETURN r_codret,r_mensaje;
         END IF

    ELIF v_clavereporte = 'RLIF' THEN
         EXECUTE PROCEDURE spsp_anexo38a1(p_fechadia,p_empresa)
         INTO r_codret,r_mensaje;
         IF r_codret <> '000' THEN
            RETURN r_codret,r_mensaje;
         END IF

    ELIF v_clavereporte = 'RLIP' THEN
         EXECUTE PROCEDURE spsp_anexo38c1(p_fechadia,p_empresa)
         INTO r_codret,r_mensaje;
         IF r_codret <> '000' THEN
            RETURN r_codret,r_mensaje;
         END IF
      
    ELIF v_clavereporte = 'R242411' THEN
        EXECUTE PROCEDURE r24a(p_fechadia,p_empresa) INTO r_codret,r_mensaje;
        IF r_codret <> '000' THEN
            RETURN r_codret,r_mensaje;
        END IF
      
    ELIF v_clavereporte = 'R15A1511' THEN
        EXECUTE PROCEDURE r15a1511(p_fechadia,p_empresa) INTO r_codret,r_mensaje;
        IF r_codret <> '000' THEN
            RETURN r_codret,r_mensaje;    
        ELSE
            EXECUTE PROCEDURE r15a1511respaldo(p_fechadia,p_empresa,v_clavereporte) INTO r_codret,r_mensaje;
            IF r_codret <> '000' THEN
                RETURN r_codret,r_mensaje;
			END IF;	
        END IF;			    				
    ELIF v_clavereporte = 'R15A1511pm' THEN
        EXECUTE PROCEDURE r15a1511pm(p_fechadia,p_empresa) INTO r_codret,r_mensaje;
        IF r_codret <> '000' THEN
            RETURN r_codret,r_mensaje;
        ELSE
            EXECUTE PROCEDURE r15a1511respaldo(p_fechadia,p_empresa,v_clavereporte) INTO r_codret,r_mensaje;
            IF r_codret <> '000' THEN
                RETURN r_codret,r_mensaje;
			END IF;
         END IF;			     		
	ELIF v_clavereporte = 'R15B1521' THEN 
	   EXECUTE PROCEDURE "informix".spsp_r15b1521( p_empresa, p_fechadia ) INTO r_codret,r_mensaje;
	    IF r_codret <> '000' THEN
            RETURN r_codret,r_mensaje;
        END IF  
	ELIF v_clavereporte = 'R15B1522' THEN 	                                
	   EXECUTE PROCEDURE "informix".spsp_r15b1522( p_empresa, p_fechadia ) INTO r_codret,r_mensaje;
	    IF r_codret <> '000' THEN
            RETURN r_codret,r_mensaje;
        END IF  		
	ELIF v_clavereporte = 'R28A2811'	THEN 	
			EXECUTE PROCEDURE "informix".sp_r28a2811( p_empresa,p_fechadia ) INTO r_codret,r_mensaje;
			IF r_codret <> '000' THEN
                RETURN r_codret,r_mensaje;
			END IF;	
  	ELIF v_clavereporte = 'R24B2423'	THEN 	
			EXECUTE PROCEDURE "informix".sp_r24b2423( p_empresa,p_fechadia ) INTO r_codret,r_mensaje;
			IF r_codret <> '000' THEN
                RETURN r_codret,r_mensaje;
			END IF;	    
  	ELIF v_clavereporte = 'R24E2450_1'	 THEN 	
             
			EXECUTE PROCEDURE "informix".sp_r24e2450_01(p_empresa,p_fechadia)	 INTO r_codret,r_mensaje;
			IF r_codret <> '000' THEN
               RETURN r_codret,r_mensaje;
			END IF;	    	
                  
	ELIF   v_clavereporte = 'R24E2450_2' THEN 						
			EXECUTE PROCEDURE "informix".sp_r24e2450_02(p_empresa,p_fechadia)	 INTO r_codret,r_mensaje;
			IF r_codret <> '000' THEN
               RETURN r_codret,r_mensaje;			
			END IF;	    			

	ELIF  v_clavereporte = 'R24E2450_3' THEN 						
			EXECUTE PROCEDURE "informix".sp_r24e2450_03(p_empresa,p_fechadia)	 INTO r_codret,r_mensaje;
			
			IF r_codret <> '000' THEN
               RETURN r_codret,r_mensaje;
			ELIF r_codret = '000' THEN							
			
				IF NOT EXISTS (SELECT clavereporte FROM bdirepaut:sp_controlproceso WHERE clavereporte = 'R24E2450' AND fechacontroldia = p_fechadia) THEN 					
									
					SELECT fechamesant, fechadicant, fechaanioant, fechamaxentrega, fechadiaanterior
					  INTO vfechamesant, vfechadicant, vfechaanioant, vfechamaxentrega, vfechadiaanterior
					  FROM bdirepaut:sp_controlproceso 
				     WHERE clavereporte = 'R24E2450_3'
					   AND fechacontroldia = p_fechadia;
			
				    INSERT INTO  bdirepaut:sp_controlproceso(identautoridad, empresa, clavereporte, fechacontroldia, fechaproyec, fechamesant, fechadicant, fechaanioant, fechamaxentrega, fechadiaanterior, prioridadgen, statusproceso)
				    VALUES('CNBV', '001', 'R24E2450', p_fechadia, p_fechadia, vfechamesant, vfechadicant, vfechaanioant, vfechamaxentrega, vfechadiaanterior, 1, 'S');				   
				ELSE 	
					UPDATE bdirepaut:sp_controlproceso
					   SET statusproceso = 'S'
					 WHERE identautoridad = 'CNBV'
					   AND clavereporte = 'R24E2450'
					   AND fechacontroldia = p_fechadia
					   AND statusproceso IN ('P','R');					
				END IF	
			END IF;		   
	ELIF v_clavereporte = 'R24E2452'	THEN 						
			EXECUTE PROCEDURE "informix".spsp_r24e2452(p_empresa,p_fechadia)	 INTO r_codret,r_mensaje;
			IF r_codret <> '000' THEN
                RETURN r_codret,r_mensaje;
			ELIF 	 r_codret = '000' THEN
			IF NOT EXISTS (SELECT clavereporte FROM bdirepaut:sp_controlproceso WHERE clavereporte = 'R24E2451' AND fechacontroldia = p_fechadia) THEN 					
									
					SELECT fechamesant, fechadicant, fechaanioant, fechamaxentrega, fechadiaanterior
					  INTO vfechamesant, vfechadicant, vfechaanioant, vfechamaxentrega, vfechadiaanterior
					  FROM bdirepaut:sp_controlproceso 
				     WHERE clavereporte = 'R24E2452'
					   AND fechacontroldia = p_fechadia;
			
				    INSERT INTO  bdirepaut:sp_controlproceso(identautoridad, empresa, clavereporte, fechacontroldia, fechaproyec, fechamesant, fechadicant, fechaanioant, fechamaxentrega, fechadiaanterior, prioridadgen, statusproceso)
				    VALUES('CNBV', '001', 'R24E2451', p_fechadia, p_fechadia, vfechamesant, vfechadicant, vfechaanioant, vfechamaxentrega, vfechadiaanterior, 1, 'S');				   
				ELSE 	
					UPDATE bdirepaut:sp_controlproceso
					   SET statusproceso = 'S'
					 WHERE identautoridad = 'CNBV'
					   AND clavereporte = 'R24E2451'
					   AND fechacontroldia = p_fechadia;					
				END IF		
			END IF;	    
	END IF	
	
	
	IF v_clavereporte = 'R24D2441' OR v_clavereporte = 'R24D2442' THEN	
		--Actualiza El Control a Satisfecho
			UPDATE bdirepaut:sp_controlproceso
			SET    statusproceso = 'S'
			WHERE  identautoridad  = v_identautoridad
			AND    empresa         = p_empresa
			AND    clavereporte    IN ('R24D2441','R24D2442')
			AND    fechacontroldia = p_fechadia;
	ELIF v_clavereporte = 'R24E2452' THEN	
			--Actualiza El Control a Satisfecho
			UPDATE bdirepaut:sp_controlproceso
			SET    statusproceso = 'S'
			WHERE  identautoridad  = v_identautoridad
			AND    empresa         = p_empresa
			AND    clavereporte    IN ('R24E2451','R24E2452')
			AND    fechacontroldia = p_fechadia;	
	ELSE
      --Actualiza El Control a Satisfecho
      UPDATE bdirepaut:sp_controlproceso
      SET    statusproceso = 'S'
      WHERE  identautoridad  = v_identautoridad
      AND    empresa         = p_empresa
      AND    clavereporte    = v_clavereporte
      AND    fechacontroldia = p_fechadia;
	END IF
	
	   
    END FOREACH;

    --Actualiza la Fecha de Parametros
    UPDATE bdirepaut:sp_param
    SET valorparam = SUBSTR('0' || DAY(p_fechadia),
        LENGTH('0' || DAY(p_fechadia)) - 1, 2) || '/' ||
        SUBSTR('0' || MONTH(p_fechadia),
        LENGTH('0' || MONTH(p_fechadia)) - 1, 2) || '/' ||
        YEAR(p_fechadia)
    WHERE claveparam = 5 AND empresa = p_empresa;

    --Fin del Proceso
    LET r_codret = '000';
    LET r_mensaje = 'PROCESO SATISFACTORIO';
    RETURN r_codret, r_mensaje;

END PROCEDURE;