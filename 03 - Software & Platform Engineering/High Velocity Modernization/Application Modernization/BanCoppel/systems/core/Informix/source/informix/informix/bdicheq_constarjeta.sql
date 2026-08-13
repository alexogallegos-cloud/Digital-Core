CREATE PROCEDURE "informix".constarjeta(pEmpresa char(3), pTarjeta  char(20))
	-- DATOS A REGRESAR --
	RETURNING
	char(5),    -- Codigo de retorno
	char(20),   -- Numero Cuenta
	char(20),   -- # Cliente
	char(26),   -- Apellido paterno
	char(26),   -- Apellido materno
	char(26),   -- Nombre 1
	char(26),   -- Nombre 2
	char(13),   -- RFC
	money(14,2), -- Limite de retiro maximo por mes
	char(1),    -- Status tarjeta
	char(8);    -- Tipo de cliente

	-- VARIABLES --
	DEFINE vCodRet  char(5);
	DEFINE vTipCte  char(1);
	DEFINE vNumCta  char(20);
	DEFINE vNumCte	char(20);
	DEFINE vApePat  char(26);
	DEFINE vApeMat  char(26);
	DEFINE vNombre1 char(26);
	DEFINE vNombre2 char(26);
	DEFINE vRFC     char(13);
	DEFINE vNumTarj char(16);
	DEFINE vLimTar  money(14,2);
	DEFINE vTipoCte char(8);
	DEFINE vStatTjt char(1);
	DEFINE vCantReg smallint;
	DEFINE vRFC_alterno char(13);
	DEFINE cProductoTarjeta CHAR(4);
	DEFINE iSqlErr INTEGER;


	-- INICIALIZACION DE VARIABLES --
	LET vCodRet  = "000";
	LET vCantReg = 0;
	LET vRFC_alterno = "";
	LET cProductoTarjeta = "";
	LET iSqlErr = 0;
	LET vNumCte  = "";
	LET vNumCta  = "";
	LET vApePat  = "";
	LET vApeMat  = "";
	LET vNombre1 = "";
	LET vNombre2 = "";
	LET vRFC     = "";
	LET vNumTarj = "";
	LET vLimTar  = 0;
	LET vStatTjt = "";
	LET vTipoCte = "";

	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
			    LET vCodRet = iSqlErr; 
				
				RETURN vCodRet, vNumcta, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC,  vLimTar, vStatTjt, vTipoCte WITH RESUME;	
			END IF;
		END EXCEPTION;
		
	--SET DEBUG FILE TO '/home/tmp/jairo/constarjeta.out';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	-- BUSCAR QUE TIPO DE CLIENTE ES [ TITULAR O FIRMANTE] --
	LET	vTipCte = "";

	SELECT
		'T' AS tipo_tarjeta, sc_mcq.numcte
	INTO
		vTipCte, vNumCte
	FROM
		bdicheq:"informix".sc_tarjeta AS sc_mcq
	WHERE
		sc_mcq.empresa = pEmpresa AND
		sc_mcq.num_tarjeta  = pTarjeta;
		
		
			SELECT prodtarjeta
			INTO cProductoTarjeta
			FROM bdicheq:"informix".sc_tarjeta
            WHERE  empresa = pEmpresa
            AND num_tarjeta = pTarjeta;
			
			IF NVL(cProductoTarjeta, "") = "8000" THEN
				LET vCodRet= '00858';
				RETURN NVL(vCodRet,""), NVL(vNumcta,""), NVL(vNumCte,""), NVL(vApePat,""), NVL(vApeMat,""), NVL(vNombre1,""), NVL(vNombre2,""), NVL(vRFC,""),  NVL(vLimTar,""), NVL(vStatTjt,""), NVL(vTipoCte,"");
			END IF;

		
	IF vTipCte = 'T' THEN
		-- CICLO PARA OBTENER AL TITULAR Y LOS FIRMANTES Y LAS TARJETAS DE CREDITO EN CASO DE QUE TENGAN --
		FOREACH
			SELECT DISTINCT
				sc_mcq.cuenta, si_cte.numcte, si_cte.apell_paterno, si_cte.apell_materno, si_cte.nombre1, si_cte.nombre2, si_cte.rfc, si_cte.rfc_alterno,'Titular' AS tipo_cliente
			FROM
				bdicheq:"informix".sc_tarjeta AS sc_mcq,
				bdinteg:"informix".si_cliente AS si_cte
			WHERE
				sc_mcq.empresa = pEmpresa AND sc_mcq.num_tarjeta =  pTarjeta AND
				sc_mcq.numcte = si_cte.numcte AND  si_cte.empresa = pEmpresa

			UNION ALL

			SELECT DISTINCT
				sc_fir.cuenta, si_cte.numcte, si_cte.apell_paterno, si_cte.apell_materno, si_cte.nombre1, si_cte.nombre2, si_cte.rfc, si_cte.rfc_alterno,'Firmante' AS tipo_cliente
			INTO
				vNumCta, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vRFC_alterno, vTipoCte
			FROM
				bdicheq:"informix".sc_tarjeta AS sc_fir,
				bdinteg:"informix".si_cliente AS si_cte
			WHERE
				sc_fir.empresa =  pEmpresa AND sc_fir.num_tarjeta =  pTarjeta AND sc_fir.numcte != vNumCte AND
				sc_fir.numcte = si_cte.numcte AND si_cte.empresa = pEmpresa

			IF vRFC_alterno IS NOT NULL AND vRFC_alterno <> "" THEN
               LET vRFC = vRFC_alterno;
            END IF;		
			
			-- OBTENER LA TARJETA DEL TITULAR O FIRMANTE --
			SELECT
				sc_tjt.num_tarjeta, sc_tjt.limite_aut, sc_tjt.status_tar
			INTO
				vNumTarj, vLimTar, vStatTjt
			FROM
				bdicheq:"informix".sc_tarjeta AS sc_tjt
			WHERE
				sc_tjt.empresa = pEmpresa AND
				sc_tjt.num_tarjeta = pTarjeta AND
				sc_tjt.numcte = vNumCte AND
				sc_tjt.secuencia = (SELECT MAX(sc_tjt.secuencia) FROM bdicheq:"informix".sc_tarjeta AS sc_tjt WHERE sc_tjt.empresa = pEmpresa AND sc_tjt.num_tarjeta = pTarjeta AND sc_tjt.numcte = vNumCte);

			
			IF vNumTarj IS NULL THEN
				LET vNumTarj = "Sin tarjeta";
				LET vLimTar = 0;
				LET vStatTjt = "";
			END IF

			LET vCantReg = vCantReg + 1;
			
			RETURN vCodRet, vNumCta, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC,  vLimTar, vStatTjt, vTipoCte WITH RESUME;
		END FOREACH;
	ELSE
		-- OBTENER LAS TARJETAS DEL FIRMANTE
		SELECT DISTINCT
			sc_fir.cuenta, si_cte.numcte, si_cte.apell_paterno, si_cte.apell_materno, si_cte.nombre1, si_cte.nombre2, si_cte.rfc, si_cte.rfc_alterno, 'Firmante' AS tipo_cliente
		INTO
			vNumCta, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vRFC_alterno, vTipoCte
		FROM
			bdicheq:"informix".sc_tarjeta AS sc_fir,
			bdinteg:"informix".si_cliente AS si_cte
		WHERE
			sc_fir.empresa =  pEmpresa AND sc_fir.num_tarjeta =  pTarjeta AND 
			sc_fir.numcte = si_cte.numcte AND si_cte.empresa = pEmpresa;

		
		-- OBTENER LA TARJETA DEL FIRMANTE --
		SELECT DISTINCT
			sc_tjt.num_tarjeta, sc_tjt.limite_aut, sc_tjt.status_tar
		INTO
			vNumTarj, vLimTar, vStatTjt
		FROM
			bdicheq:"informix".sc_tarjeta AS sc_tjt
		WHERE
			sc_tjt.empresa = pEmpresa AND
			sc_tjt.num_tarjeta = pTarjeta AND
			sc_tjt.numcte = vNumCte AND
			sc_tjt.secuencia = (SELECT MAX(sc_tjt.secuencia) FROM bdicheq:"informix".sc_tarjeta AS sc_tjt WHERE sc_tjt.empresa = pEmpresa AND sc_tjt.num_tarjeta = pTarjeta AND sc_tjt.numcte = vNumCte);

		IF vRFC_alterno IS NOT NULL AND vRFC_alterno <> "" THEN
           LET vRFC = vRFC_alterno;
        END IF;			
			
		IF vNumTarj IS NULL THEN
			LET vNumTarj = "Sin tarjeta";
			LET vLimTar = 0;
			LET vStatTjt = "";
		END IF

		LET vCantReg = vCantReg + 1;
			
		RETURN vCodRet, vNumcta, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC,  vLimTar, vStatTjt, vTipoCte WITH RESUME;
	END IF

	IF vCantReg = 0 THEN
		LET vCodRet  = "101";
		LET vNumCte  = "";
		LET vApePat  = "";
		LET vApeMat  = "";
		LET vNombre1 = "";
		LET vNombre2 = "";
		LET vRFC     = "";
		LET vNumTarj = "";
		LET vLimTar  = 0;
		LET vStatTjt = "";
		LET vTipoCte = "";

		RETURN vCodRet, vNumCta, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vLimTar, vStatTjt, vTipoCte;
	END IF
END
END PROCEDURE                                                     
DOCUMENT
'AUTOR: ???',
'DESCRIPCION: Se añade validacion para el producto 8000 transfer y mande retorno 858',
'FECHA: 28/08/2014',
'MODIFICO: Jairo Valdez Gonzalez',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_conciliachqtf( pempresa CHAR(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER;
    
    DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(50);
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE desc_err     CHAR(50);
    DEFINE vcont1       INTEGER;
    DEFINE vcont2       INTEGER;
    DEFINE ven_trx      SMALLINT;
    DEFINE vsql         CHAR(600);
    DEFINE vstmt        CHAR(250);
    DEFINE vfecha_hoy   DATE;
    DEFINE vfecha_ant   DATE;
    DEFINE vproceso     CHAR(14);
    DEFINE vsistema     CHAR(2);
    DEFINE vexiste      INTEGER;
    DEFINE vexisfin     INTEGER;
    DEFINE vusuario     CHAR(10);
    DEFINE vcuenta      CHAR(20);
    DEFINE vnum_cte     CHAR(20);
    DEFINE vsucursal    CHAR(4);
    DEFINE vejecutivo   CHAR(8);
    DEFINE vproducto    CHAR(4);
    DEFINE vcap_ant     MONEY(18,2);
    DEFINE vcap_cal     MONEY(18,2);
    DEFINE vmovs_cgo    MONEY(18,2);
    DEFINE vmovs_abo    MONEY(18,2);
    DEFINE vcap_act     MONEY(18,2);
    DEFINE vdif_cap     MONEY(18,2);
    DEFINE vcta_cgo     CHAR(12);  
    DEFINE vcta_abo     CHAR(12);  
    DEFINE vmonto       MONEY(14,2);
    DEFINE vcta         SMALLINT;
    DEFINE vinteres     MONEY(14,2);
    DEFINE vfecha       CHAR(8);
    
    LET vcodret1   = '000';
    LET vcodret2   = '000';
    LET vcodret3   = 'PROCESO CONCLUIDO SATISFACTORIAMENTE';
    LET sql_err	   = 0;
    LET isam_err   = 0;
    LET desc_err   = '';
    LET vcont1     = 0;
    LET vcont2     = 0;
    LET ven_trx    = 0; 
    LET vsql       = '';
    LET vstmt      = '';
    LET vfecha_hoy = ''; 
    LET vfecha_ant = '';
    LET vproceso   = 'conciliachqtf';
    LET vsistema   = '01';
    LET vexiste    = 0;
    LET vexisfin   = 0;
    LET vusuario   = user;
    LET vcuenta    = ''; 
    LET vproducto  = '';
    LET vnum_cte   = '';
    LET vsucursal  = '5001';
    LET vejecutivo = '';
    LET vcap_ant   = 0.00;
    LET vcap_cal   = 0.00;
    LET vmovs_cgo  = 0.00;
    LET vmovs_abo  = 0.00;
    LET vcap_act   = 0.00;
    LET vdif_cap   = 0.00;
    LET vcta_cgo   = '';
    LET vcta_abo   = '';
    LET vmonto     = 0.00;
    LET vcta       = 0;
    LET vinteres   = 0.00;
    LET vfecha     = '';
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_conciliachqtf.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_trx = 1 THEN
                ROLLBACK WORK;
            END IF;
            LET vsql = '';
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vusuario||''','||
                       'status_proc   = '''||'C'||''','||
                       'codret        = '''||vcodret1||''','||
                       'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horasconcilchqtf.sql';
            SYSTEM vsql;
            LET vstmt = '';
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horasconcilchqtf.sql';
            SYSTEM vstmt;
            RETURN vcodret1, vcodret2, vcodret3, vcont1, vcont2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_conciliachqtf.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTIENE LAS FECHAS DEL SISTEMA
    SELECT fecha_hoy, fecha_ant
      INTO vfecha_hoy, vfecha_ant
      FROM sc_fechas
     WHERE empresa = pempresa;
    
    -- // VALIDA LA FECHA DE AYER
    LET vfecha_hoy = vfecha_hoy - 1 UNITS DAY;
    
    CALL sp_valfechabil(vfecha_hoy, '-') 
    RETURNING vcodret1, vfecha_hoy;
    
    -- // VALIDA LA FECHA DE ANTIER
    LET vfecha_ant = vfecha_ant - 1 UNITS DAY;
    
    CALL sp_valfechabil(vfecha_ant, '-') 
    RETURNING vcodret1, vfecha_ant;
     
    -- // GUARDA REGISTRO DE CONTROL EN TABLA DE INTEGRAL
    select count(*)
      into vexiste
      from bdinteg:sx_contproc
     where empresa = pempresa
       and proceso = vproceso
       and fecha   = vfecha_hoy
       and sistema = vsistema;
    
    if vexiste = 0 then
        LET vsql = '';
        LET vsql = 'echo " INSERT INTO bdinteg:sx_contproc VALUES '||
                   '('''||pempresa||''', '''||vproceso||''', '''||vfecha_hoy||''', '''||vsistema||''', '''||'I'||''', '''||vusuario||''','||
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horasconcilchqtf.sql';
        SYSTEM vsql;
        
        LET vstmt = '';
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horasconcilchqtf.sql';
        SYSTEM vstmt;
    else
        SELECT count(*)
          INTO vexisfin
          FROM bdinteg:sx_contproc
         WHERE empresa     = pempresa
           AND proceso     = vproceso
           AND fecha       = vfecha_hoy
           AND sistema     = vsistema
           AND status_proc = "F";
           
        IF vexisfin = 0 THEN
            LET vsql = '';
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vusuario||''','||
                       'status_proc   = '''||'I'||''','||
                       'codret        = '''||' '||''','||
                       'hora_fin      = '''||' '||''','||
                       'hora_ini      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horasconcilchqtf.sql';
            SYSTEM vsql;
            
            LET vstmt = '';
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horasconcilchqtf.sql';
            SYSTEM vstmt;
        ELSE
            LET vcodret1 = "958";
            LET vcodret2 = "958";
            
            SELECT descripcion
              INTO vcodret3
              FROM bdinteg:si_codret
             WHERE sistema = vsistema
               AND codigo_retorno = vcodret1;
            
            RETURN vcodret1, vcodret2, vcodret3, vcont1, vcont2;
        END IF;
    end if;
    
    -- // ELIMINACION DE TABLAS
    if exists( select dbsname, tabname from sysmaster:systabnames where partnum > 0 and tabname = 'conciliachqtf') then 
        drop table bdicheq:"informix".conciliachqtf;
    end if;
    
    if exists( select dbsname, tabname from sysmaster:systabnames where partnum > 0 and tabname = 'conciliachqtf_dif') then
        drop table bdicheq:"informix".conciliachqtf_dif;
    end if
    
    -- // CREACION DE TABLAS
    create table bdicheq:"informix".conciliachqtf
      (
        fecha                   date,
        cuenta                  char(20),
        producto                char(4),
        num_cte                 char(20),
        sucursal                char(4),
        ejecutivo               char(8),
        capital_anterior        money(18,2),
        movs_cargo              money(18,2),
        movs_abono              money(18,2),
        capital_calculado       money(18,2),
        capital_actual          money(18,2),
        diferencia_capital      money(18,2)
      )    
    extent size 1024 next size 128 lock mode row;
        
    create table bdicheq:"informix".conciliachqtf_dif
      ( 
        fecha                   date,   
        cuenta                  char(20),
        producto                char(4),    
        num_cte                 char(20),   
        sucursal                char(4),    
        ejecutivo               char(8),    
        capital_anterior        money(18,2),
        movs_cargo              money(18,2),
        movs_abono              money(18,2),
        capital_calculado       money(18,2),
        capital_actual          money(18,2),
        diferencia_capital      money(18,2)
      )
    extent size 1024 next size 128 lock mode row;
    
    -- // CREACION DE INDICES
    create index "informix".idx_conciliachqtf_fecha on bdicheq:"informix".conciliachqtf(fecha) in datos03 online;
    create index "informix".idx_conciliachqtf_cuenta on bdicheq:"informix".conciliachqtf(cuenta) in datos03 online;
    create index "informix".idx_conciliachqtfdif_fecha on bdicheq:"informix".conciliachqtf_dif(fecha) in datos03 online;
    create index "informix".idx_conciliachqtfdif_cuenta on bdicheq:"informix".conciliachqtf_dif(cuenta) in datos03 online;
    
    -- // ACTUALIZA ESTADISTICAS
    update statistics medium for table conciliachqtf;
    update statistics medium for table conciliachqtf_dif;
    
    -- // CREACION DE TABLA TEMPORAL DE MOVIMIENTOS
    SELECT { +INDEX(sc_movdia_concil idx_movdiaconc_1), +INDEX(bdinteg:si_transacc idx_si_transacc4), +INDEX(bdinteg:si_prodtran idx01_prodtran) } 
           mov.cuenta, mov.transacc, mov.monto_tot,
           TRIM(prod.c_ccmayor)||TRIM(prod.c_ccsub)||TRIM(prod.c_ccsubsub)||TRIM(prod.c_ccsssub)||TRIM(prod.c_ccssssub) AS cta_cargo,
           TRIM(prod.a_ccmayor)||TRIM(prod.a_ccsub)||TRIM(prod.a_ccsubsub)||TRIM(prod.a_ccsssub)||TRIM(prod.a_ccssssub) AS cta_abono
      FROM sc_movdia_concil mov,
           bdinteg:si_transacc tran,
           bdinteg:si_prodtran prod
     WHERE mov.fech_alt = vfecha_hoy
       AND mov.cancelad != 'S'
       AND mov.cuenta LIKE '8%'
       AND mov.producto = '8000'
       AND tran.empresa = mov.empresa
       AND tran.numero = mov.transacc
       AND tran.se_contabiliza = 'S'
       AND tran.sistema = '01'
       AND prod.transaccion = tran.numero
       AND prod.producto = mov.producto
       AND prod.sistema = tran.sistema
      INTO TEMP tmp_movs_transfer WITH NO LOG;
      
    -- // CREACION DE INDICES
    CREATE INDEX idxtmp_movstrf_cta ON tmp_movs_transfer(cuenta) ONLINE;
    CREATE INDEX idxtmp_movstrf_ctacgo ON tmp_movs_transfer(cuenta, cta_cargo) ONLINE;
    CREATE INDEX idxtmp_movstrf_ctaabo ON tmp_movs_transfer(cuenta, cta_abono) ONLINE;
    
    -- // ACTUALIZA ESTADISTICAS
    UPDATE STATISTICS HIGH FOR TABLE tmp_movs_transfer(cuenta, cta_cargo, cta_abono);
    
    -- // FOREACH CUENTAS TRANSFER
    FOREACH WITH HOLD
        SELECT cuenta_tf, producto, numcte, ejecutivo
          INTO vcuenta, vproducto, vnum_cte, vejecutivo
          FROM bditransfer:tf_maecte 
         WHERE ( telefono is not null OR telefono <> '' )
           AND empresa = '001'
           AND ( status_cta = '1' OR fec_cancelac >= vfecha_hoy )
           
        BEGIN WORK;
        LET ven_trx = 1; 
        
        -- // OBTIENE SALDOS ANTERIORES
        EXECUTE PROCEDURE sp_capintafecha(vcuenta, vfecha_ant) 
        INTO vcodret1, vcap_ant, vinteres;
        
        IF vcodret1 = '100' THEN
            LET vcodret1 = '000';
            LET vcap_ant = 0.00;
        END IF;
        
        LET vcap_cal = vcap_ant;
        
        -- // OBTIENE LOS MOVIMIENTOS DE CAPITAL 
        FOREACH
            SELECT {+INDEX(tmp_movs_transfer idxtmp_movstrf_cta)} 
                   cta_cargo, cta_abono, monto_tot
              INTO vcta_cgo, vcta_abo, vmonto
              FROM tmp_movs_transfer
             WHERE cuenta = vcuenta
             
            IF vcta_cgo IN( SELECT cta_contable FROM sc_ctascontchq WHERE producto = vproducto AND tipo = 'CAPITAL' ) THEN
                LET vcap_cal = vcap_cal - vmonto;
                LET vmovs_cgo = vmovs_cgo + vmonto;
            END IF;
                    
            IF vcta_abo IN( SELECT cta_contable FROM sc_ctascontchq WHERE producto = vproducto AND tipo = 'CAPITAL' ) THEN
                LET vcap_cal = vcap_cal + vmonto;
                LET vmovs_abo = vmovs_abo + vmonto;
            END IF;
            
            LET vcta_cgo   = '';
            LET vcta_abo   = '';
            LET vmonto     = 0.00;
        END FOREACH;
        
        -- // OBTIENE SALDOS ACTUALES
        EXECUTE PROCEDURE sp_capintafecha(vcuenta, vfecha_hoy) 
        INTO vcodret1, vcap_act, vinteres;
        
        IF vcodret1 = '100' THEN
            LET vcodret1 = '000';
            LET vcap_act = 0.00;
        END IF;
        
        -- // OBTIENE DIFERENCIAS
        LET vdif_cap = vcap_act - vcap_cal;
        
        -- // INSERTA EN TABLA DE TODAS LAS CUENTAS
        SELECT COUNT(*)
          INTO vcta
          FROM conciliachqtf
         WHERE cuenta = vcuenta;
         
        IF vcta > 0 THEN
            UPDATE conciliachqtf
               SET fecha              = vfecha_hoy,
                   capital_anterior   = vcap_ant,
                   movs_cargo         = vmovs_cgo,
                   movs_abono         = vmovs_abo,
                   capital_calculado  = vcap_cal,
                   capital_actual     = vcap_act,
                   diferencia_capital = vdif_cap
             WHERE cuenta = vcuenta;
        ELSE
            INSERT INTO conciliachqtf VALUES
            (vfecha_hoy, vcuenta, vproducto, vnum_cte, vsucursal, vejecutivo,
             vcap_ant, vmovs_cgo, vmovs_abo, vcap_cal, vcap_act, vdif_cap);
        END IF;
        
        -- // INSERTA EN TABLA DE DIFERENCIAS
        IF ( vdif_cap <> 0.00 ) THEN
            INSERT INTO conciliachqtf_dif VALUES
            (vfecha_hoy, vcuenta, vproducto, vnum_cte, vsucursal, vejecutivo,
             vcap_ant, vmovs_cgo, vmovs_abo, vcap_cal, vcap_act, vdif_cap); 
             
            LET vcont2 = vcont2 + 1;
        END IF;
        
        LET vcont1 = vcont1 + 1;
        
        COMMIT WORK;
        LET ven_trx = 0;
        
        LET vcuenta    = ''; 
        LET vproducto  = '';
        LET vnum_cte   = '';
        LET vejecutivo = '';
        LET vcap_ant   = 0.00;
        LET vcap_cal   = 0.00;
        LET vmovs_cgo  = 0.00;
        LET vmovs_abo  = 0.00;
        LET vcap_act   = 0.00;
        LET vdif_cap   = 0.00;
        LET vcta       = 0;
        LET vinteres   = 0.00;
    END FOREACH;
    
    IF ven_trx = 1 THEN
        LET ven_trx = 0;
        COMMIT WORK;
    END IF;
    
    -- // ACTUALIZA ESTADISTICAS
    UPDATE STATISTICS MEDIUM FOR TABLE conciliachqtf;
    UPDATE STATISTICS MEDIUM FOR TABLE conciliachqtf_dif;
    
    LET vfecha = TO_CHAR(vfecha_hoy, '%d%m%Y');
    
    -- // GENERA EL ARCHIVO DE TODAS LAS CUENTAS
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/conciliachqtf_'||vfecha||'.txt '||
               ' SELECT * FROM conciliachqtf WHERE fecha = '''||vfecha_hoy||''' ORDER BY cuenta" > /resplogifx/conciliachq/conciliatf.sql';
    SYSTEM vsql;
    
    LET vstmt = '';
    LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/conciliatf.sql"; 
    SYSTEM vstmt;
    
    -- // GENERA EL ARCHIVO DE DIFERENCIAS
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/conciliachqtfdif_'||vfecha||'.txt '||
               ' SELECT * FROM conciliachqtf_dif WHERE fecha = '''||vfecha_hoy||''' ORDER BY cuenta" > /resplogifx/conciliachq/conciliatf.sql';
    SYSTEM vsql;
    
    LET vstmt = '';
    LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/conciliatf.sql"; 
    SYSTEM vstmt;
    
    -- // GENERA ARCHIVO DE GLOBALES POSITIVOS
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/conciliachqtfglob_'||vfecha||'.txt '||
               'SELECT producto, COUNT(*), SUM(capital_anterior), SUM(capital_calculado), SUM(capital_actual) '||
               'FROM conciliachqtf WHERE fecha = '''||vfecha_hoy||''' AND capital_actual >= 0 GROUP BY producto " > /resplogifx/conciliachq/conciliatf.sql';
    SYSTEM vsql;
    
    LET vstmt = '';
    LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/conciliatf.sql"; 
    SYSTEM vstmt;
    
    -- // GENERA ARCHIVO DE GLOBALES NEGATIVOS
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/conciliachqtfglobneg_'||vfecha||'.txt '||
               'SELECT producto, COUNT(*), SUM(capital_anterior), SUM(capital_calculado), SUM(capital_actual) '||
               'FROM conciliachqtf WHERE fecha = '''||vfecha_hoy||''' AND capital_actual < 0 GROUP BY producto " > /resplogifx/conciliachq/conciliatf.sql';
    SYSTEM vsql;
    
    LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/conciliatf.sql"; 
    SYSTEM vsql;
    
    -- // GUARDA HORA FINAL DEL PROCESO
    LET vsql = '';
	LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
               'SET ejecutivo = '''||vusuario||''','||
               'status_proc   = '''||'F'||''','||
               'codret        = '''||vcodret1||''','||
               'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
               'WHERE empresa = '''||pempresa||''' '||
               'AND proceso   = '''||vproceso||''' '||
               'AND fecha     = '''||vfecha_hoy||''' '||
               'AND sistema   = '''||vsistema||''';" > /tmp/horasconcilchqtf.sql';
    SYSTEM vsql;
    
    LET vstmt = '';
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horasconcilchqtf.sql';
    SYSTEM vstmt;
           
    END;
    
    RETURN vcodret1, vcodret2, vcodret3, vcont1, vcont2;
    
END PROCEDURE;