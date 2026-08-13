CREATE PROCEDURE "informix".sp_obtener_primer_deposito_sc_movhis()
RETURNING
	CHAR(6) 	AS cod_ret,
	CHAR(80)	AS desc_ret

	---DECLARACIONES
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE cErrorInfo		CHAR(80);
	DEFINE cCodRet			CHAR(6);
	DEFINE cDescRet			CHAR(80);

	DEFINE vabierto     	CHAR(1);
	DEFINE vcontador3   	INTEGER;
	DEFINE cCuenta     		CHAR(20);
	DEFINE cCuenta2     	CHAR(20);
	DEFINE dFech_alt   		DATE;
	DEFINE dFechPrimDep 	DATE;
	DEFINE mMonto_tot   	MONEY;
	DEFINE iNumSerie    	INT8;
	
	
	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cErrorInfo          = "";
	LET cCodRet             = "000000";
	LET cDescRet			= "PROCESO EXITOSO";

	LET vabierto   			= '0';
	LET vcontador3 			= 0;
	LET cCuenta    			= "";
	LET cCuenta2    		= "";
	LET dFech_alt  			= DATE(1);
	LET dFechPrimDep 		= DATE(1);
	LET mMonto_tot  		= 0.0;
	LET iNumSerie   		= 0;
	
	
BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cDescRet = cErrorInfo;
            IF vabierto = '1' THEN
                ROLLBACK WORK;
            END IF;
			RETURN cCodRet, cDescRet;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/informix/moha/sp_obtener_primer_deposito_sc_movhis.out';
	--TRACE ON;
	
	FOREACH WITH HOLD
		SELECT cuenta, MIN(num_serial)
		INTO cCuenta, iNumSerie
		FROM "informix".sc_movhis t2
		WHERE empresa = "001"
		AND fech_alt > MDY(1,9,2014)
		AND transacc in ("0202","0282","0273","0329","0205") 
		GROUP BY cuenta

		IF vcontador3 = 0 THEN
			BEGIN WORK;
			LET vabierto = '1'; 
		END IF
		
		SELECT fech_alt, monto_tot
		INTO dFech_alt, mMonto_tot
		FROM "informix".sc_movhis t1
		WHERE empresa = "001"
		AND num_serial = iNumSerie
		AND cuenta = cCuenta;

		SELECT cuenta, fec_prim_deposito_orig
		INTO cCuenta2, dFechPrimDep
		FROM "informix".sc_indicadores 
		WHERE cuenta = cCuenta;
		
		IF NVL(cCuenta2,"") <> "" THEN
			IF dFechPrimDep IS NULL THEN		
				UPDATE "informix".sc_indicadores 
				SET fec_prim_deposito_orig = dFech_alt, imp_prim_deposito_orig = mMonto_tot
				WHERE cuenta = cCuenta;
			END IF
		END IF
	
		LET vcontador3 = vcontador3 + 1;
		
		IF vcontador3 = 5000 THEN
			LET vabierto = '0';
			LET vcontador3 = 0;
			COMMIT WORK;
		END IF
		
	END FOREACH
	
	IF vcontador3 > 0 THEN
		COMMIT WORK;
	END IF	

	RETURN cCodRet, cDescRet;
    
	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para obtener los primeros depositos de la tabla sc_movhis',
'BD: bdicheq', 
'AUTOR: Mohamed Carreón ',
'FECHA: Febrero 2014';

CREATE PROCEDURE "informix".sp_rptmensualproac( pempresa char(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50);
     
    DEFINE vcodret1             char(5);
    DEFINE vcodret2             char(5);
    DEFINE vcodret3             char(50);
    DEFINE sql_err              integer;
    DEFINE isam_err             integer;
    DEFINE desc_err             char(50);
    DEFINE vcontador1           integer;
    DEFINE vcontador2           integer;
    DEFINE vcontador3           integer;
    DEFINE ven_transacc         smallint;
    DEFINE vcomienza            smallint;
    
    DEFINE vfecha_hoy           date;
    DEFINE vfecha_ant           DATE;
    DEFINE vpri_dia_mes         DATE;
    DEFINE vfecha_ini           DATE;
    DEFINE vfecha_fin           DATE;
    DEFINE vfecha_ejecucion     DATE;
    DEFINE vfechaproc           DATE;
    DEFINE vfechconmovhis       char(10);
    DEFINE vfechconmovhisold    char(10);
    
    DEFINE vsucursal            char(4);
    DEFINE vproducto            char(4);
    DEFINE vno_ctes             integer;
    DEFINE vno_ctas             integer;
    DEFINE vsdo_fin_mes         decimal(18,2);
    DEFINE vno_compras          integer;
    DEFINE vmonto_compras       decimal(18,2);
    
    DEFINE vsql                 CHAR(500);
    DEFINE vfechades            CHAR(6);

    LET vcodret1     = "000";               
    LET vcodret2     = '000';
    LET vcodret3     = 'PROCESO CONCLUIDO SATISFACTORIAMENTE';
    LET sql_err      = 0;                   
    LET isam_err     = 0;
    LET desc_err     = '';
    LET vcontador1   = 0;                   
    LET vcontador2   = 0;
    LET vcontador3   = 0;
    LET ven_transacc = 0;                   
    LET vcomienza    = -1;  
       
    LET vfecha_hoy              = ''; 
    LET vfecha_ant              = '';
    LET vpri_dia_mes            = '';
    LET vfecha_ini              = '';
    LET vfecha_fin              = '';
    LET vfecha_ejecucion        = '';
    LET vfechaproc              = '';
    LET vfechconmovhis          = '';
    LET vfechconmovhisold       = '';
    
    LET vsucursal      = '';
    LET vproducto      = '';
    LET vno_ctes       = 0;
    LET vno_ctas       = 0;
    LET vsdo_fin_mes   = 0.00;
    LET vno_compras    = 0;
    LET vmonto_compras = 0.00;
    
    LET vsql      = '';
    LET vfechades = '';

    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_rptmensualproac.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcodret3;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_rptmensualproac.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    SELECT fecha_hoy, fecha_ant, pri_dia_mes
      INTO vfecha_hoy, vfecha_ant, vpri_dia_mes
      FROM sc_fechas
     WHERE empresa = pempresa;
     
    LET vfecha_ini = vpri_dia_mes - 1 UNITS MONTH;
    LET vfecha_fin = vpri_dia_mes - 1 UNITS DAY;
    
    -- // VERIFICA QUE NO SE HAYA EJECUTADO EL PROCESO PARA ESTE PERIODO
    SELECT fecha
      INTO vfecha_ejecucion
      FROM sc_contproc_proac
     WHERE proceso = 'rptmensualproac'
       AND empresa = pempresa;
       
    IF vfecha_ejecucion = vfecha_hoy THEN
        LET vcodret1 = '958';
        LET vcodret2 = '958';
        
        SELECT descripcion
          INTO vcodret3
          FROM bdinteg:si_codret
         WHERE codigo_retorno = vcodret1
           AND sistema = '01';
           
        RETURN vcodret1, vcodret2, vcodret3;
    END IF;
	
	IF lpad(day(vfecha_hoy), 2, '0') <> '04' THEN
        LET vcodret1 = '958';
        LET vcodret2 = '958';
        
        SELECT descripcion
          INTO vcodret3
          FROM bdinteg:si_codret
         WHERE codigo_retorno = vcodret1
           AND sistema = '01';
           
        RETURN vcodret1, vcodret2, vcodret3;
    END IF;
    
    -- // Verifica se haya efectuado el paso de movs a historico
    SELECT fecha 
      INTO vfechaproc
      FROM sc_contproc
     WHERE empresa = pempresa 
       AND proceso = "pasomovshist"
       AND fecha = vfecha_ant;
       
    IF vfechaproc is null THEN
        LET vcodret1 = '953';
        LET vcodret2 = '953';
        
        SELECT descripcion
          INTO vcodret3
          FROM bdinteg:si_codret
         WHERE codigo_retorno = vcodret1
           AND sistema = '01';
           
        RETURN vcodret1, vcodret2, vcodret3;
    END IF;

    -- // PARAMETROS DE CONSULTA PARA MOVIMIENTOS HISTORICOS
    SELECT valor 
      INTO vfechconmovhis
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'fechcon_movhis';
       
    SELECT valor 
      INTO vfechconmovhisold
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'FechIniCon_movhis_ol';
       
    -- // TABLA TEMPORAL DE MOVIMIENTOS DEL MES
    SELECT *
      FROM sc_movhis_old  
     WHERE fech_alt BETWEEN vfecha_ini and vfecha_fin
       AND fech_alt >= vfechconmovhisold
       AND fech_alt < vfechconmovhis
       AND transacc IN('0830','0887')
       AND cancelad <> 'S'
    UNION ALL
    SELECT *
      FROM sc_movhis
     WHERE fech_alt BETWEEN vfecha_ini AND vfecha_fin
       AND fech_alt >= vfechconmovhis
       AND transacc IN('0830','0887')
       AND cancelad <> 'S'
    INTO TEMP tmp_movs WITH NO LOG;
    CREATE INDEX idx_tmpmovs1 ON tmp_movs(suc_cuen, producto);
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_movs;
       
    -- // TABLAS PARA REPORTE
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'sc_rptmensualproac') THEN
        DROP TABLE "informix".sc_rptmensualproac;        
    END IF;
    
    CREATE TABLE "informix".sc_rptmensualproac
      ( 
        sucursal            CHAR(4), 
        producto            CHAR(4), 
        no_clientes         INTEGER,
        no_cuentas          INTEGER,
        sdo_fin_mes         DECIMAL(18,2),
        no_compras_td       INTEGER,
        monto_compras_td    DECIMAL(18,2)
      ) 
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_rptmenproac ON "informix".sc_rptmensualproac(sucursal);
    UPDATE STATISTICS MEDIUM FOR TABLE "informix".sc_rptmensualproac;
    
    FOREACH WITH HOLD
        SELECT sucursal
          INTO vsucursal
          FROM sc_sucsrptsproac
          
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET ven_transacc = 1;
            BEGIN WORK;
        END IF;
          
        FOREACH
            SELECT producto
              INTO vproducto
              FROM sc_prodproac
             
            SELECT NVL(COUNT(UNIQUE num_cte),0)
              INTO vno_ctes
              FROM sc_maechq
             WHERE sucursal = vsucursal
               AND producto = vproducto
               AND status_cta <> '2';
               
            SELECT NVL(COUNT(*),0)
              INTO vno_ctas
              FROM sc_maechq
             WHERE sucursal = vsucursal
               AND producto = vproducto
               AND status_cta <> '2';
               
            SELECT NVL(SUM(sdo_dia_ant),0.00)
              INTO vsdo_fin_mes
              FROM sc_maechq
             WHERE sucursal = vsucursal
               AND producto = vproducto
               AND status_cta <> '2';
               
            SELECT NVL(COUNT(*),0)
              INTO vno_compras
              FROM tmp_movs
             WHERE suc_cuen = vsucursal
               AND producto = vproducto;
               
            SELECT NVL(SUM(monto_tot),0.00)
              INTO vmonto_compras
              FROM tmp_movs
             WHERE suc_cuen = vsucursal
               AND producto = vproducto;
               
            INSERT INTO sc_rptmensualproac(sucursal, producto, no_clientes, no_cuentas, sdo_fin_mes, no_compras_td, monto_compras_td)
            VALUES(vsucursal, vproducto, vno_ctes, vno_ctas, vsdo_fin_mes, vno_compras, vmonto_compras);
            
            LET vproducto      = '';
            LET vno_ctes       = 0;
            LET vno_ctas       = 0;
            LET vsdo_fin_mes   = 0.00;
            LET vno_compras    = 0;
            LET vmonto_compras = 0.00;
        END FOREACH;
        
        COMMIT WORK;
        BEGIN WORK;
        
        LET vsucursal = '';
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    UPDATE STATISTICS MEDIUM FOR TABLE "informix".sc_rptmensualproac;
    
    -- // DESCARGA EL ARCHIVO DE INFORMACIÓN
    LET vfechades = TO_CHAR(vfecha_fin, '%Y%m');
    
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/rptmensualproac_'||vfechades||'.txt '||
               ' SELECT * FROM sc_rptmensualproac ORDER BY sucursal, producto;" > /resplogifx/conciliachq/rptproac1.sql';
    SYSTEM vsql;
    
    LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/rptproac1.sql"; 
    SYSTEM vsql;
    
    UPDATE sc_contproc_proac
       SET fecha = vfecha_hoy
     WHERE proceso = 'rptmensualproac'
       AND empresa = pempresa;
    
    END;

    RETURN vcodret1, vcodret2, vcodret3;

END PROCEDURE;