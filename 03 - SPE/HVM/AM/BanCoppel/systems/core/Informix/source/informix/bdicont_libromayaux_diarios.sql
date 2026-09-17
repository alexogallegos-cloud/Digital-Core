CREATE PROCEDURE "informix".libromayaux_diarios(v_empresa CHAR(4), 
                                        v_fechainicio DATE,
                                        v_fechafin DATE,
                                        v_ccmayor CHAR(10),
                                        v_ccsub CHAR(10),
                                        v_ccsubsub CHAR(10),
                                        v_ccssubsub CHAR(10),
                                        v_ccsssubsub CHAR(10),
                                        v_sector CHAR(10),
                                        v_cuenta CHAR(14),
                                        vusuario CHAR(10))

	DEFINE tfecha_valida	DATE;
	DEFINE tfecha_captura	DATE;
    DEFINE tmes_dia 		DATE;
	DEFINE tmes_dia_min		DATE;
	DEFINE tmes_dia_max		DATE;
	DEFINE tusuario			CHAR(8);
	DEFINE tnro_auxiliar	CHAR(12);	
	DEFINE auxiliar_cta		CHAR(12);
	DEFINE tcontrol_poliza	INTEGER;
	DEFINE tsecuencia		INTEGER;
	DEFINE tsucursal		CHAR(4);
	DEFINE tccosto_orig		CHAR(4);
	DEFINE tmonto			MONEY(16, 2);
	DEFINE tmoneda			CHAR(2);
	DEFINE tnaturaleza		CHAR(1);
	DEFINE tdescripcion		CHAR(50);
	DEFINE tciudad			CHAR(3);
	DEFINE tmoneda_sdo		CHAR(2);
	DEFINE tsucursal_sdo	CHAR(4);
	DEFINE tauxiliar_sdo	CHAR(12);
	DEFINE tciudad_sdo		CHAR(3);
	DEFINE tccmayor			CHAR(10);
	DEFINE tccsub			CHAR(10);
	DEFINE tccsubsub		CHAR(10);
	DEFINE tccssubsub		CHAR(10);
	DEFINE tccsssubsub		CHAR(10);
	DEFINE tsector			CHAR(10);
	DEFINE v_regional		CHAR(3);
	DEFINE tmovimientos		INTEGER;
    DEFINE tcuenta_sdo      CHAR(14);
	DEFINE v_fechahoy		DATE;
	DEFINE tsaldo_inicial	MONEY(16, 2);
	DEFINE tsaldo_final		MONEY(16, 2);	
    DEFINE v_rangoini		INTEGER;
	DEFINE v_rangofin		INTEGER;
    
	LET tfecha_valida	= CURRENT;
	LET tfecha_captura	= CURRENT;
    LET tmovimientos = 0;
	LET tusuario		= "";
	LET tnro_auxiliar	= "";
	LET tcontrol_poliza	= 0;
	LET tsecuencia		= 0;
	LET tsucursal		= "";
	LET tccosto_orig	= "";
	LET tmonto			= 0.00;
	LET tmoneda			= "";
	LET tnaturaleza		= "";
	LET tdescripcion	= "";
	LET tciudad			= "";
	LET tccmayor		= "";
	LET tccsub			= "";
	LET tccsubsub		= "";
	LET tccssubsub		= "";
	LET tccsssubsub		= "";
	LET tsector			= "";
    LET tcuenta_sdo     = "";
	LET tsaldo_inicial	= 0.00;
	LET tsaldo_final	= 0.00;
	LET v_rangoini		= 0;
	LET v_rangofin		= 0;
    LET tmes_dia    	= "";
	LET tmes_dia_min	= "";
    LET tmes_dia_max	= "";
	LET v_regional		= "";

                               
	--SET DEBUG FILE TO "/home/informix/mmeses/libro/libromayaux_diarios.out";
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;

	BEGIN  --INICIO PROGRAMA		
        CREATE TEMP TABLE bdicont:tmp_saldos (ccmayor CHAR(4),
                                              ccsub CHAR(2),
                                              ccsubsub CHAR(2),
                                              ccssubsub CHAR(2),
                                              ccsssubsub CHAR(2),
                                              sector CHAR(2),
                                              sucursal CHAR(4),
                                              moneda CHAR(2),
                                              ciudad CHAR(3),
                                              saldo_inicio_dia MONEY(16, 2),
                                              saldo_fin_de_dia MONEY(16, 2),
                                              mes_dia DATE,
                                              region CHAR(3)) WITH NO LOG;
        CREATE INDEX idx01tmp_saldos ON bdicont:tmp_saldos(ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector,sucursal,ciudad,mes_dia,moneda);
        UPDATE STATISTICS HIGH FOR TABLE bdicont:tmp_saldos;

        FOREACH
            SELECT sucursal, moneda, ciudad,NVL(saldo_inicio_dia,0),NVL(saldo_fin_de_dia,0),mes_dia
			INTO tsucursal_sdo, tmoneda_sdo, tciudad_sdo, tsaldo_inicial, tsaldo_final, tmes_dia
			FROM bdicont:"informix".co_sdodias
			WHERE empresa = v_empresa
                AND ccmayor = v_ccmayor
                AND ccsub = v_ccsub
                AND ccsubsub = v_ccsubsub
                AND ccssubsub = v_ccssubsub
                AND ccsssubsub = v_ccsssubsub
                AND sector = v_sector
                AND ciudad IS NOT NULL
                AND sucursal IS NOT NULL
                AND moneda IS NOT NULL
                AND mes_dia BETWEEN v_fechainicio AND v_fechafin
            ORDER BY moneda,ciudad,sucursal,mes_dia                        

            SELECT regional
            INTO v_regional --LET tciudad = v_regional;
            FROM bdinteg:si_plazas
            WHERE plaza IN(SELECT plaza FROM bdinteg:si_sucursales WHERE sucursal = tsucursal_sdo AND empresa = v_empresa);

            INSERT INTO bdicont:tmp_saldos (ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector,sucursal,moneda,ciudad,saldo_inicio_dia,saldo_fin_de_dia,mes_dia,region)
            VALUES (v_ccmayor,v_ccsub,v_ccsubsub,v_ccssubsub,v_ccsssubsub,v_sector,tsucursal_sdo,tmoneda_sdo,tciudad_sdo,tsaldo_inicial,tsaldo_final,tmes_dia,v_regional);
        END FOREACH;

       SELECT {+INDEX(tmp_saldos idx01tmp_saldos)} DISTINCT moneda
       FROM bdicont:tmp_saldos
       WHERE ccmayor = v_ccmayor
            AND ccsub = v_ccsub
            AND ccsubsub = v_ccsubsub
            AND ccssubsub = v_ccssubsub
            AND ccsssubsub = v_ccsssubsub
            AND sector = v_sector
            AND sucursal IS NOT NULL
            AND ciudad IS NOT NULL
            AND mes_dia BETWEEN v_fechainicio AND v_fechafin
            AND moneda IS NOT NULL
        INTO TEMP tmp_monedas WITH NO LOG;
        CREATE INDEX idxtmp_monedas ON tmp_monedas (moneda);
        UPDATE STATISTICS HIGH FOR TABLE tmp_monedas;

        SELECT {+INDEX(tmp_saldos idx01tmp_saldos)} DISTINCT sucursal
        FROM bdicont:tmp_saldos
        WHERE ccmayor = v_ccmayor
            AND ccsub = v_ccsub
            AND ccsubsub = v_ccsubsub
            AND ccssubsub = v_ccssubsub
            AND ccsssubsub = v_ccsssubsub
            AND sector = v_sector
            AND sucursal IS NOT NULL
            AND ciudad IS NOT NULL
            AND mes_dia BETWEEN v_fechainicio AND v_fechafin
            AND moneda IS NOT NULL
        INTO TEMP tmp_sucursales WITH NO LOG;
        CREATE INDEX idxtmp_sucursales ON tmp_sucursales (sucursal);
        UPDATE STATISTICS HIGH FOR TABLE tmp_sucursales;

        SELECT {+INDEX(tmp_saldos idx01tmp_saldos)} DISTINCT ciudad
        FROM bdicont:tmp_saldos
        WHERE ccmayor = v_ccmayor
            AND ccsub = v_ccsub
            AND ccsubsub = v_ccsubsub
            AND ccssubsub = v_ccssubsub
            AND ccsssubsub = v_ccsssubsub
            AND sector = v_sector
            AND sucursal IS NOT NULL
            AND ciudad IS NOT NULL
            AND mes_dia BETWEEN v_fechainicio AND v_fechafin
            AND moneda IS NOT NULL
        INTO TEMP tmp_ciudades WITH NO LOG;
        CREATE INDEX idxtmp_ciudades ON tmp_ciudades (ciudad);
        UPDATE STATISTICS HIGH FOR TABLE tmp_ciudades;

        CREATE TEMP TABLE bdicont:tmp_parametros (sucursal CHAR(4),
                                                  ciudad CHAR(3),
                                                  moneda CHAR(2)) WITH NO LOG;
        CREATE INDEX idxtmp_parametros ON tmp_parametros (sucursal,ciudad,moneda);
        UPDATE STATISTICS HIGH FOR TABLE tmp_parametros;                   

        FOREACH
            SELECT {+INDEX(tmp_monedas idxtmp_monedas)} moneda INTO tmoneda_sdo FROM bdicont:tmp_monedas ORDER BY moneda
            FOREACH
                SELECT {+INDEX(tmp_ciudades idxtmp_ciudades)}ciudad INTO tciudad_sdo FROM bdicont:tmp_ciudades ORDER BY ciudad
                FOREACH
                    SELECT {+INDEX(tmp_sucursales idxtmp_sucursales)} sucursal INTO tsucursal_sdo  FROM bdicont:tmp_sucursales ORDER BY sucursal

                    INSERT INTO tmp_parametros(sucursal,ciudad,moneda)
                    VALUES(tsucursal_sdo,tciudad_sdo,tmoneda_sdo);

                END FOREACH --ciudades
            END FOREACH --sucursales
        END FOREACH; --moneda

        LET tmoneda_sdo = '';
        LET tsucursal_sdo = '';
        LET tciudad_sdo = '';

        DROP TABLE bdicont:tmp_monedas;
        DROP TABLE bdicont:tmp_sucursales;
        DROP TABLE bdicont:tmp_ciudades;

        CREATE TEMP TABLE bdicont:tmp_minmaxfechasaldos (ccmayor CHAR(4),
                                                            ccsub CHAR(2),
                                                            ccsubsub CHAR(2),
                                                            ccssubsub CHAR(2),
                                                            ccsssubsub CHAR(2),
                                                            sector CHAR(2),
                                                            sucursal CHAR(4),
                                                            ciudad CHAR(3),
                                                            moneda CHAR(2),
                                                            mes_dia_min DATE,
                                                            mes_dia_max DATE) WITH NO LOG;
        CREATE INDEX idx01tmp_minmaxfechasaldos ON bdicont:tmp_minmaxfechasaldos(ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector,sucursal,ciudad,moneda);
        UPDATE STATISTICS HIGH FOR TABLE bdicont:tmp_minmaxfechasaldos;

        FOREACH
            SELECT {+INDEX(tmp_parametros idxtmp_parametros)} sucursal,ciudad,moneda
            INTO tsucursal_sdo,tciudad_sdo,tmoneda_sdo
            FROM bdicont:tmp_parametros
            WHERE sucursal IS NOT NULL
                AND ciudad IS NOT NULL
                AND moneda IS NOT NULL
            ORDER BY sucursal,ciudad,moneda

            SELECT {+INDEX(tmp_saldos idx01tmp_saldos)} MIN(mes_dia)
            INTO tmes_dia_min
            FROM bdicont:tmp_saldos
            WHERE ccmayor = v_ccmayor
                AND ccsub = v_ccsub
                AND ccsubsub = v_ccsubsub
                AND ccssubsub = v_ccssubsub
                AND ccsssubsub = v_ccsssubsub
                AND sector = v_sector
                AND sucursal = tsucursal_sdo
                AND ciudad = tciudad_sdo
                AND mes_dia BETWEEN v_fechainicio AND v_fechafin
                AND moneda = tmoneda_sdo;
               
            IF (tmes_dia_min IS NOT NULL) THEN
                INSERT INTO bdicont:tmp_minmaxfechasaldos(ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector,sucursal,ciudad,moneda,mes_dia_min,mes_dia_max)
                VALUES(v_ccmayor,v_ccsub,v_ccsubsub,v_ccssubsub,v_ccsssubsub,v_sector,tsucursal_sdo,tciudad_sdo,tmoneda_sdo,tmes_dia_min,tmes_dia_max);
            END IF               
        END FOREACH;

        LET tmoneda_sdo = '';
        LET tsucursal_sdo = '';
        LET tciudad_sdo = '';  

        FOREACH
            SELECT {+INDEX(tmp_parametros idxtmp_parametros)} sucursal,ciudad,moneda
            INTO tsucursal_sdo,tciudad_sdo,tmoneda_sdo
            FROM bdicont:tmp_parametros
            WHERE sucursal IS NOT NULL
                AND ciudad IS NOT NULL
                AND moneda IS NOT NULL
            ORDER BY sucursal,ciudad,moneda

            SELECT {+INDEX(tmp_saldos idx01tmp_saldos)} MAX(mes_dia)
            INTO tmes_dia_max
            FROM bdicont:tmp_saldos
            WHERE ccmayor = v_ccmayor
                AND ccsub = v_ccsub
                AND ccsubsub = v_ccsubsub
                AND ccssubsub = v_ccssubsub
                AND ccsssubsub = v_ccsssubsub
                AND sector = v_sector   
                AND sucursal = tsucursal_sdo
                AND ciudad = tciudad_sdo
                AND mes_dia BETWEEN v_fechainicio AND v_fechafin
                AND moneda = tmoneda_sdo;

            IF (tmes_dia_max IS NOT NULL) THEN
                UPDATE {+INDEX(tmp_minmaxfechasaldos idx01tmp_minmaxfechasaldos)} bdicont:tmp_minmaxfechasaldos
                SET mes_dia_max = tmes_dia_max
                WHERE ccmayor = v_ccmayor
                    AND ccsub = v_ccsub
                    AND ccsubsub = v_ccsubsub
                    AND ccssubsub = v_ccssubsub
                    AND ccsssubsub = v_ccsssubsub
                    AND sector = v_sector
                    AND sucursal = tsucursal_sdo
                    AND ciudad = tciudad_sdo
                    AND moneda = tmoneda_sdo;
            END IF
        END FOREACH;

        LET tsucursal_sdo = '';
        LET tmoneda_sdo = '';
        LET tciudad_sdo = '';
        LET tsaldo_inicial = 0.00;
        LET tsaldo_final = 0.00;
        LET tmes_dia_min = '';
        LET tmes_dia_max = '';

        CREATE TEMP TABLE bdicont:tmp_saldosfinales (cuenta CHAR(60),
                                                    sucursal CHAR(4),
                                                    region CHAR(3),
                                                    moneda CHAR(2),
                                                    saldo_inicial MONEY(16,2),
                                                    saldo_final MONEY(16,2)) WITH NO LOG;
        CREATE INDEX idx01tmp_saldosfinales ON bdicont:tmp_saldosfinales(sucursal,region,cuenta,moneda);
        UPDATE STATISTICS HIGH FOR TABLE bdicont:tmp_saldosfinales;

        FOREACH
            SELECT {+INDEX(tmp_minmaxfechasaldos idx01tmp_minmaxfechasaldos)} sucursal,ciudad,moneda,mes_dia_min,mes_dia_max
            INTO tsucursal_sdo,tciudad_sdo,tmoneda_sdo,tmes_dia_min,tmes_dia_max
            FROM bdicont:tmp_minmaxfechasaldos
            WHERE ccmayor = v_ccmayor
                AND ccsub = v_ccsub
                AND ccsubsub = v_ccsubsub
                AND ccssubsub = v_ccssubsub
                AND ccsssubsub = v_ccsssubsub
                AND sector = v_sector
                AND sucursal IS NOT NULL
                AND ciudad IS NOT NULL
                AND moneda IS NOT NULL

            SELECT {+INDEX(tmp_saldos idx01tmp_saldos)} region, NVL(saldo_inicio_dia,0)
			INTO tciudad,tsaldo_inicial
			FROM bdicont:tmp_saldos
			WHERE ccmayor = v_ccmayor
                AND ccsub = v_ccsub
                AND ccsubsub = v_ccsubsub
                AND ccssubsub = v_ccssubsub
                AND ccsssubsub = v_ccsssubsub
                AND sector = v_sector
                AND sucursal = tsucursal_sdo
                AND ciudad = tciudad_sdo                         
                AND mes_dia = tmes_dia_min
                AND moneda = tmoneda_sdo;

            SELECT {+INDEX(tmp_saldos idx01tmp_saldos)} NVL(saldo_fin_de_dia,0)
			INTO tsaldo_final
			FROM bdicont:tmp_saldos
			WHERE ccmayor = v_ccmayor
                AND ccsub = v_ccsub
                AND ccsubsub = v_ccsubsub
                AND ccssubsub = v_ccssubsub
                AND ccsssubsub = v_ccsssubsub
                AND sector = v_sector 
                AND sucursal = tsucursal_sdo
                AND ciudad = tciudad_sdo                        
                AND mes_dia = tmes_dia_max
                AND moneda = tmoneda_sdo;

            INSERT INTO bdicont:tmp_saldosfinales(cuenta,sucursal,region,moneda,saldo_inicial,saldo_final)
            VALUES(v_cuenta,tsucursal_sdo,tciudad,tmoneda_sdo,tsaldo_inicial,tsaldo_final);                        
        END FOREACH

        LET tsucursal_sdo = '';
        LET tmoneda_sdo = '';
        LET tsaldo_inicial = 0.00;
        LET tsaldo_final = 0.00;
        LET tciudad = '';

        DROP TABLE bdicont:tmp_minmaxfechasaldos;

        FOREACH
            SELECT cuenta,sucursal,region,moneda,sum(NVL(saldo_inicial,0)),sum(NVL(saldo_final,0))
            INTO tcuenta_sdo,tsucursal_sdo,tciudad,tmoneda_sdo,tsaldo_inicial,tsaldo_final
			FROM bdicont:tmp_saldosfinales
			WHERE sucursal IS NOT NULL
                AND region IS NOT NULL
                AND cuenta = v_cuenta
                AND moneda IS NOT NULL
            GROUP BY cuenta,sucursal,region,moneda
            ORDER BY cuenta,sucursal,region,moneda

            INSERT INTO bdicont:"informix".co_libsdoaux (empresa, cuenta, ccmayor, ccsub, ccsubsub,ccssubsub, ccsssubsub, sector, ciudad, sucursal,
                                              moneda, fecha_valida, usuario, control_poliza, secuencia,nro_auxiliar, naturaleza, saldo_inicial, monto, saldo_final,
                                              descripcion_det, fecha_captura, ccosto_orig)
            VALUES(v_empresa, tcuenta_sdo, v_ccmayor, v_ccsub, v_ccsubsub,v_ccssubsub, v_ccsssubsub, v_sector, tciudad, tsucursal_sdo,
				   tmoneda_sdo, v_fechainicio, vusuario, '0', '0','', '', tsaldo_inicial, '0', tsaldo_final,'', v_fechafin, '0000');
        END FOREACH;

        LET tsucursal_sdo = '';
        LET tmoneda_sdo = '';
        LET tciudad_sdo = '';

        DROP TABLE bdicont:tmp_parametros;

        CREATE TEMP TABLE tmp_historico (usuario CHAR(8),
                                         control_poliza INTEGER,
                                         fecha_captura DATE,
                                         secuencia INTEGER,
                                         ccmayor CHAR(4),
                                         ccsub CHAR(2),
                                         ccsubsub CHAR(2),
                                         ccssubsub CHAR(2),
                                         ccsssubsub CHAR(2),
                                         sector CHAR(2),
                                         ciudad CHAR(3),
                                         sucursal CHAR(4),
                                         naturaleza CHAR(1),
                                         nro_auxiliar CHAR(12),
                                         monto MONEY(16, 2),
                                         descripcion CHAR(20),
                                         fecha_valida DATE,
                                         moneda CHAR(2),                                                             
                                         ccosto_orig CHAR(4)) WITH NO LOG;
        CREATE INDEX idx01tmp_historico ON tmp_historico(ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector,sucursal,nro_auxiliar,ciudad,fecha_valida,moneda);
        UPDATE STATISTICS HIGH FOR TABLE tmp_historico;

        DROP TABLE bdicont:tmp_saldosfinales;

        FOREACH
            SELECT {+INDEX(co_mensual inx_comensual)} usuario,control_poliza,fecha_captura,secuencia,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector,
                           ciudad,sucursal,naturaleza,nro_auxiliar,monto,descripcion,fecha_valida,moneda,ccosto_orig
            INTO tusuario, tcontrol_poliza, tfecha_captura, tsecuencia, tccmayor, tccsub, tccsubsub, tccssubsub, tccsssubsub, tsector,
                 tciudad, tsucursal, tnaturaleza, tnro_auxiliar, tmonto, tdescripcion, tfecha_valida, tmoneda, tccosto_orig
            FROM bdicont:"informix".co_mensual
            WHERE empresa = v_empresa 
                AND ccmayor = v_ccmayor 
                AND ccsub = v_ccsub 
                AND ccsubsub = v_ccsubsub 
                AND ccssubsub = v_ccssubsub 
                AND ccsssubsub = v_ccsssubsub 
                AND sector = v_sector 
                AND ciudad IS NOT NULL
                AND sucursal IS NOT NULL
                AND nro_auxiliar IS NOT NULL
                AND	fecha_valida BETWEEN v_fechainicio AND v_fechafin
                AND moneda IS NOT NULL

            INSERT INTO tmp_historico(usuario,control_poliza,fecha_captura,secuencia,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector,
                                      ciudad,sucursal,naturaleza,nro_auxiliar,monto,descripcion,fecha_valida,moneda,ccosto_orig)
            VALUES(tusuario,tcontrol_poliza,tfecha_captura,tsecuencia,tccmayor,tccsub,tccsubsub,tccssubsub,tccsssubsub,tsector,
                   tciudad,tsucursal,tnaturaleza,tnro_auxiliar,tmonto,tdescripcion,tfecha_valida,tmoneda,tccosto_orig);                   
        END FOREACH;

        LET tusuario = ''; 
        LET tcontrol_poliza = 0;
        LET tfecha_captura = '' ;
        LET tsecuencia = '';
        LET tccmayor = '';
        LET tccsub = '';
        LET tccsubsub = '';
        LET tccssubsub = '';
        LET tccsssubsub = '';
        LET tsector = '';
        LET tciudad = '';
        LET tsucursal = '';
        LET tnaturaleza = '';
        LET tnro_auxiliar = '';
        LET tmonto = 0.00;
        LET tdescripcion = '';
        LET tfecha_valida = '';
        LET tmoneda = '';
        LET tccosto_orig = '';
        LET v_regional = '';
        LET v_cuenta = '';

        FOREACH
            SELECT {+INDEX(tmp_historico idx01tmp_historico)} usuario,control_poliza,fecha_captura,secuencia,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector,
                   ciudad,sucursal,naturaleza,nro_auxiliar,monto,descripcion,fecha_valida,moneda,ccosto_orig
            INTO tusuario, tcontrol_poliza, tfecha_captura, tsecuencia, tccmayor, tccsub, tccsubsub, tccssubsub, tccsssubsub, tsector,
                 tciudad, tsucursal, tnaturaleza, tnro_auxiliar, tmonto, tdescripcion, tfecha_valida, tmoneda, tccosto_orig
            FROM tmp_historico
            WHERE ccmayor = v_ccmayor 
                AND ccsub = v_ccsub 
                AND ccsubsub = v_ccsubsub 
                AND ccssubsub = v_ccssubsub 
                AND ccsssubsub = v_ccsssubsub 
                AND sector = v_sector
                AND sucursal IS NOT NULL
                AND nro_auxiliar IS NOT NULL
                AND ciudad IS NOT NULL
                AND fecha_valida IS NOT NULL
                AND moneda IS NOT NULL                         
            ORDER BY ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector,moneda,ciudad,sucursal,usuario,control_poliza,secuencia

            LET v_cuenta = TRIM(tccmayor) || TRIM(tccsub) || TRIM(tccsubsub)|| TRIM(tccssubsub) || TRIM(tccsssubsub) || TRIM(tsector);
                        
            SELECT regional
            INTO v_regional --LET tciudad = v_regional;
            FROM bdinteg:"informix".si_plazas
            WHERE plaza IN(SELECT plaza FROM bdinteg:"informix".si_sucursales WHERE sucursal = tsucursal AND empresa = v_empresa);

			INSERT INTO bdicont:"informix".co_libmadet(empresa,cuenta,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector,ciudad,sucursal,moneda,fecha_valida,
                                            usuario,control_poliza,secuencia,nro_auxiliar,naturaleza, saldo_inicial, monto, saldo_final,
                                            descripcion_det, fecha_captura, ccosto_orig, usuario_rep)
			VALUES (v_empresa, v_cuenta, tccmayor, tccsub, tccsubsub, tccssubsub, tccsssubsub, tsector, v_regional, tsucursal,
					tmoneda, tfecha_valida, tusuario, tcontrol_poliza, tsecuencia, tnro_auxiliar, tnaturaleza, '0', tmonto, '0',
					tdescripcion, tfecha_captura, tccosto_orig, vusuario);

            LET tmovimientos = tmovimientos + 1;
		END FOREACH;

		IF tmovimientos = 0 THEN
            INSERT INTO bdicont:"informix".co_libmadet(empresa, cuenta, ccmayor, ccsub, ccsubsub,ccssubsub, ccsssubsub, sector, ciudad, sucursal,
						moneda, fecha_valida, usuario, control_poliza, secuencia,nro_auxiliar, naturaleza, saldo_inicial, monto, saldo_final,
						descripcion_det, fecha_captura, ccosto_orig, usuario_rep)
            VALUES(v_empresa, v_cuenta, v_ccmayor, v_ccsub, v_ccsubsub,v_ccssubsub, v_ccsssubsub, v_sector, tciudad, tsucursal_sdo,
				   tmoneda_sdo, v_fechainicio, '', '0', '0','', '', '0', '0','0','SIN MOVIMIENTOS', v_fechafin, '', vusuario);
        END IF;    

        DROP TABLE bdicont:tmp_saldos;
        DROP TABLE bdicont:tmp_historico;                

    END;
END PROCEDURE;