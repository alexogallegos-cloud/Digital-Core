CREATE PROCEDURE "informix".libromayor_historicos(v_empresa CHAR(4), 
                                        v_fechainicio DATE,
                                        v_fechafin DATE,
                                        v_ccmayor CHAR(10),
                                        v_ccsub CHAR(10),
                                        v_ccsubsub CHAR(10),
                                        v_ccssubsub CHAR(10),
                                        v_ccsssubsub CHAR(10),
                                        v_sector CHAR(10),
                                        v_cuenta CHAR(14),
                                        vusuario CHAR(10),
                                        v_idreporte INTEGER)

RETURNING VARCHAR(5), VARCHAR(255);

	DEFINE tfecha_valida	DATE;
	DEFINE tfecha_captura	DATE;
    DEFINE tmes_dia 		DATE;
	DEFINE tmes_dia_min		DATE;
	DEFINE tmes_dia_max		DATE;
	DEFINE tusuario			CHAR(8);
	DEFINE tnro_auxiliar	CHAR(12);	
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
	DEFINE tsaldo_inicial	MONEY(16, 2);
	DEFINE tsaldo_final		MONEY(16, 2);	

    DEFINE vb_saldos        BOOLEAN;
    DEFINE vb_monedas       BOOLEAN;
    DEFINE vb_sucursales    BOOLEAN;
    DEFINE vb_ciudades      BOOLEAN;
    DEFINE vb_parametros    BOOLEAN;
    DEFINE vb_minmaxfechasaldos BOOLEAN;
    DEFINE vb_saldosfinales BOOLEAN;
    DEFINE vb_historico     BOOLEAN;    
    DEFINE vsFlagEnTransaccion  CHAR(1);
    DEFINE viContadorRegistros  INTEGER;

    DEFINE cVarDataErr      VARCHAR(64);
    DEFINE iSqlErr          INTEGER;
    DEFINE iSamErr          INTEGER;
    DEFINE vCodret          CHAR(5);
    
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
    LET tmes_dia    	= "";
	LET tmes_dia_min	= "";
    LET tmes_dia_max	= "";
	LET v_regional		= "";
    LET cVarDataErr     = "PROCESO EXITOSO";
    LET iSqlErr         = 0;
    LET iSamErr         = 0;
    LET vCodret       = "000";
    LET vb_saldos       = 'F';
    LET vb_monedas      = 'F';
    LET vb_sucursales   = 'F';
    LET vb_ciudades     = 'F';
    LET vb_parametros   = 'F';
    LET vb_minmaxfechasaldos = 'F';
    LET vb_saldosfinales    = 'F';
    LET vb_historico         = 'F';
    LET vsFlagEnTransaccion = 'F';
    LET viContadorRegistros = 0;
                               
	--SET DEBUG FILE TO "/tmp/libromayaux_historicos.out";
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;

	BEGIN  --INICIO PROGRAMA		

    ON EXCEPTION
        SET iSqlErr, iSamErr, cVarDataErr
            IF iSqlErr <> 0 THEN
                IF vb_saldos = 'T' THEN
                    DROP TABLE bdicont:tmp_saldos;
                END IF
                IF vb_monedas = 'T' THEN
                    DROP TABLE bdicont:tmp_monedas;
                END IF
                IF vb_sucursales = 'T' THEN
                    DROP TABLE bdicont:tmp_sucursales;
                END IF
                IF vb_ciudades = 'T' THEN
                    DROP TABLE bdicont:tmp_ciudades;
                END IF
                IF vb_parametros = 'T' THEN
                    DROP TABLE bdicont:tmp_parametros;
                END IF
                IF vb_minmaxfechasaldos = 'T' THEN
                    DROP TABLE bdicont:tmp_minmaxfechasaldos;
                END IF
                IF vb_saldosfinales = 'T' THEN
                    DROP TABLE bdicont:tmp_saldosfinales;
                END IF
                IF vb_historico = 'T' THEN
                    DROP TABLE bdicont:tmp_historico;
                END IF
                LET vCodret=iSqlErr;
                RETURN vCodret, iSamErr || ' ' ||cVarDataErr;
            END IF
		END EXCEPTION;

-- Inicio Proceso Saldos
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

    UPDATE STATISTICS MEDIUM FOR TABLE bdicont:tmp_saldos;

    LET vb_saldos = 'T';

	FOREACH
       SELECT sucursal, moneda, '001',sum(NVL(saldo_inicio_dia,0)),sum(NVL(saldo_fin_de_dia,0)),mes_dia
		INTO tsucursal_sdo, tmoneda_sdo, tciudad_sdo, tsaldo_inicial, tsaldo_final, tmes_dia
		FROM bdicont:"informix".co_histsdodias
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
        GROUP BY 1,2,3,6
        ORDER BY 2,3,1,6

		LET v_regional= tciudad_sdo;

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

    UPDATE STATISTICS MEDIUM FOR TABLE tmp_monedas;

    LET vb_monedas = 'T';

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

    UPDATE STATISTICS MEDIUM FOR TABLE tmp_sucursales;

    LET vb_sucursales = 'T';

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

    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ciudades;

    LET vb_ciudades = 'T';

    CREATE TEMP TABLE bdicont:tmp_parametros (sucursal CHAR(4),
                                              ciudad CHAR(3),
                                              moneda CHAR(2)) WITH NO LOG;
    CREATE INDEX idxtmp_parametros ON tmp_parametros (sucursal,ciudad,moneda);

    UPDATE STATISTICS MEDIUM FOR TABLE tmp_parametros;

    LET vb_parametros = 'T';            

    LET tmoneda_sdo = '';
	LET tciudad_sdo = ''; 
    LET tauxiliar_sdo = '';
    LET tsucursal_sdo = '';

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
	LET vb_monedas = 'F';

    DROP TABLE bdicont:tmp_sucursales;
	LET vb_sucursales = 'F';

    DROP TABLE bdicont:tmp_ciudades;
	LET vb_ciudades = 'F';


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

    UPDATE STATISTICS MEDIUM FOR TABLE bdicont:tmp_minmaxfechasaldos;

    LET vb_minmaxfechasaldos = 'T';

    FOREACH
        SELECT {+INDEX(tmp_parametros idxtmp_parametros)} sucursal,ciudad,moneda
        INTO tsucursal_sdo,tciudad_sdo,tmoneda_sdo
        FROM bdicont:tmp_parametros
        WHERE sucursal IS NOT NULL
            AND ciudad IS NOT NULL
            AND moneda IS NOT NULL
		GROUP BY sucursal,ciudad,moneda
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
        FROM bdicont:tmp_minmaxfechasaldos
        WHERE 1 = 1
		GROUP BY sucursal,ciudad,moneda
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

    UPDATE STATISTICS MEDIUM FOR TABLE bdicont:tmp_saldosfinales;

    LET vb_saldosfinales = 'T';

    FOREACH
        SELECT {+INDEX(tmp_minmaxfechasaldos idx01tmp_minmaxfechasaldos)} sucursal,ciudad,moneda,mes_dia_min,mes_dia_max
        INTO tsucursal_sdo,tciudad_sdo,tmoneda_sdo,tmes_dia_min,tmes_dia_max
        FROM bdicont:tmp_minmaxfechasaldos
        WHERE 1 = 1

        SELECT {+INDEX(tmp_saldos idx01tmp_saldos)} region, NVL(saldo_inicio_dia,0.00)
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

        SELECT {+INDEX(tmp_saldos idx01tmp_saldos)} NVL(saldo_fin_de_dia,0.00)
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

    DROP TABLE bdicont:tmp_minmaxfechasaldos;
	LET vb_minmaxfechasaldos = 'F';

    LET tsucursal_sdo = '';
    LET tmoneda_sdo = '';
    LET tauxiliar_sdo = '';
    LET tsaldo_inicial = 0.00;
    LET tsaldo_final = 0.00;
    LET tciudad = '';

    FOREACH WITH HOLD
        SELECT cuenta,sucursal,region,moneda,NVL(saldo_inicial,0),NVL(saldo_final,0)
        INTO tcuenta_sdo,tsucursal_sdo,tciudad,tmoneda_sdo,tsaldo_inicial,tsaldo_final
		FROM bdicont:tmp_saldosfinales
		WHERE 1 = 1
        ORDER BY cuenta,sucursal,region,moneda

        --ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
        IF (vsFlagEnTransaccion = 'F') THEN
            BEGIN WORK;
            LET vsFlagEnTransaccion = 'V';
        END IF;

        INSERT INTO bdicont:"informix".co_libsdoaux (empresa, cuenta, ccmayor, ccsub, ccsubsub,ccssubsub, ccsssubsub, sector, ciudad, sucursal,
                                                     moneda, fecha_valida, usuario, control_poliza, secuencia,nro_auxiliar, naturaleza, saldo_inicial, monto, saldo_final,
                                                     descripcion_det, fecha_captura, ccosto_orig, id_reporte)
        VALUES(v_empresa, tcuenta_sdo, v_ccmayor, v_ccsub, v_ccsubsub,v_ccssubsub, v_ccsssubsub, v_sector, tciudad, tsucursal_sdo,
			   tmoneda_sdo, v_fechainicio, vusuario, 0, 0,'', '', tsaldo_inicial, 0, tsaldo_final,'', v_fechafin, '0000',v_idreporte);

        LET viContadorRegistros = viContadorRegistros + 1;

        --TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
        IF (viContadorRegistros = 1000) THEN --VERIFICA SI ALCANZO EL MAXIMO DE TRANSACCIONES POR BLOQUE
            COMMIT WORK;
            LET vsFlagEnTransaccion = 'F';
            LET viContadorRegistros = 0;
            CONTINUE FOREACH;
        END IF;
    END FOREACH;

    -- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
    IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
        COMMIT WORK;
        LET vsFlagEnTransaccion = 'F';
    END IF;

    DROP TABLE bdicont:tmp_parametros;
	LET vb_parametros = 'F';

-- Fin Proceso Saldos

    LET vsFlagEnTransaccion = 'F';
    LET viContadorRegistros = 0;
    LET tsucursal_sdo = '';
    LET tmoneda_sdo = '';
    LET tciudad_sdo = '';

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

    UPDATE STATISTICS MEDIUM FOR TABLE tmp_historico;

    LET vb_historico = 'T';

    FOREACH
        SELECT {+INDEX(co_historico inx_cohistoricon)} usuario,control_poliza,fecha_captura,secuencia,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector,
                       ciudad,sucursal,naturaleza,nro_auxiliar,monto,descripcion,fecha_valida,moneda,ccosto_orig
        INTO tusuario, tcontrol_poliza, tfecha_captura, tsecuencia, tccmayor, tccsub, tccsubsub, tccssubsub, tccsssubsub, tsector,
             tciudad, tsucursal, tnaturaleza, tnro_auxiliar, tmonto, tdescripcion, tfecha_valida, tmoneda, tccosto_orig
        FROM bdicont:"informix".co_historico
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
               '001',tsucursal,tnaturaleza,tnro_auxiliar,tmonto,tdescripcion,tfecha_valida,tmoneda,tccosto_orig);

    END FOREACH;

        FOREACH WITH HOLD
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

			LET v_regional = tciudad;

            --ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
            IF (vsFlagEnTransaccion = 'F') THEN
                 BEGIN WORK;
                 LET vsFlagEnTransaccion = 'V';
            END IF;

            INSERT INTO bdicont:"informix".co_libmadet(empresa,cuenta,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector,ciudad,sucursal,moneda,fecha_valida,
                                                        usuario,control_poliza,secuencia,nro_auxiliar,naturaleza, saldo_inicial, monto, saldo_final,
                                                        descripcion_det, fecha_captura, ccosto_orig, usuario_rep, id_reporte)
            VALUES (v_empresa, v_cuenta, tccmayor, tccsub, tccsubsub, tccssubsub, tccsssubsub, tsector, '001', tsucursal,
                    tmoneda, tfecha_valida, tusuario, tcontrol_poliza, tsecuencia, tnro_auxiliar, tnaturaleza, 0, tmonto, 0,
                    tdescripcion, tfecha_captura, tccosto_orig, vusuario, v_idreporte);

            LET viContadorRegistros = viContadorRegistros + 1;

            --TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
            IF (viContadorRegistros = 1000) THEN --VERIFICA SI ALCANZO EL MAXIMO DE TRANSACCIONES POR BLOQUE
                COMMIT WORK;
                LET vsFlagEnTransaccion = 'F';
                LET viContadorRegistros = 0;
                CONTINUE FOREACH;
            END IF;
        END FOREACH;

        -- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
        IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
            COMMIT WORK;
            LET vsFlagEnTransaccion = 'F';
        END IF;

		FOREACH 
            SELECT sucursal,region,moneda 
            INTO tsucursal_sdo,tciudad,tmoneda_sdo
			FROM bdicont:tmp_saldosfinales
			WHERE 1 = 1
            ORDER BY cuenta,sucursal,region,moneda

			SELECT COUNT(*)
			INTO tmovimientos 
			FROM bdicont:co_libmadet 
			WHERE empresa = v_empresa
 			  AND ccmayor = v_ccmayor
			  AND ccsub = v_ccsub
			  AND ccsubsub = v_ccsubsub
			  AND ccssubsub = v_ccssubsub
			  AND ccsssubsub = v_ccsssubsub
			  AND sector = v_sector
			  AND ciudad = tciudad
			  AND sucursal = tsucursal_sdo
			  AND moneda = tmoneda_sdo
			  AND usuario_rep = vusuario
			  AND id_reporte = v_idreporte;

			IF tmovimientos = 0 THEN
				INSERT INTO bdicont:"informix".co_libmadet(empresa, cuenta, ccmayor, ccsub, ccsubsub,ccssubsub, ccsssubsub, sector, ciudad, sucursal,
							moneda, fecha_valida, usuario, control_poliza, secuencia,nro_auxiliar, naturaleza, saldo_inicial, monto, saldo_final,
							descripcion_det, fecha_captura, ccosto_orig, usuario_rep, id_reporte)
				VALUES(v_empresa, v_cuenta, v_ccmayor, v_ccsub, v_ccsubsub,v_ccssubsub, v_ccsssubsub, v_sector, '001', tsucursal_sdo,
					tmoneda_sdo, v_fechainicio, '', 0, 0,tauxiliar_sdo, '', 0, 0, 0, 'SIN MOVIMIENTOS', v_fechafin, '', vusuario, v_idreporte);
			END IF

		END FOREACH;

        DROP TABLE bdicont:tmp_saldosfinales;
		LET vb_saldosfinales = 'F';        

		DROP TABLE bdicont:tmp_saldos;
		LET vb_saldos = 'F';

        DROP TABLE bdicont:tmp_historico;             
		LET vb_historico = 'F';

        RETURN vCodret,cVarDataErr;
    END;
END PROCEDURE;