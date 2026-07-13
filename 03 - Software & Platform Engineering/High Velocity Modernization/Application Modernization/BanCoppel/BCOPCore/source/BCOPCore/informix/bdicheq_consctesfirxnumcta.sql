CREATE PROCEDURE "informix".consctesfirxnumcta(pEmpresa CHAR(3), pNumeroCuenta CHAR(20), pNumeroCliente CHAR(20))
	-- DATOS A REGRESAR --
	RETURNING
	CHAR(5),     -- Codigo de retorno
	CHAR(20),    -- # Cliente
	CHAR(26),    -- Apellido paterno
	CHAR(26),    -- Apellido materno
	CHAR(26),    -- Nombre 1
	CHAR(26),    -- Nombre 2
	CHAR(13),    -- RFC
	CHAR(16),    -- # Tarjeta
	DATE,    	 --	Expiracion
	CHAR(4),     -- Producto tarjeta
	MONEY(14,2), -- Limite de retiro maximo por mes
	CHAR(1),     -- Status tarjeta
	CHAR(8),     -- Tipo de cliente
	CHAR(10),    -- Fecha de Nacimiento
	CHAR(4),     -- Producto de la cuenta
	CHAR(2);     -- Parentesco

	-- VARIABLES --
	DEFINE vCodRet  	CHAR(5);
	DEFINE iSqlErr 		INTEGER;
	DEFINE vTipCte  	CHAR(1);
	DEFINE vNumCte		CHAR(20);
	DEFINE vApePat  	CHAR(26);
	DEFINE vApeMat  	CHAR(26);
	DEFINE vNombre1 	CHAR(26);
	DEFINE vNombre2 	CHAR(26);
	DEFINE vRFC     	CHAR(13);
	DEFINE vNumTarj 	CHAR(16);
	DEFINE Vexpiracion  DATE;
	DEFINE Vprodtarjeta CHAR(4);
	DEFINE vLimTar  	MONEY(14,2);
	DEFINE vTipoCte 	CHAR(8);
	DEFINE vStatTjt 	CHAR(1);
	DEFINE vFechaNac 	CHAR(10);
	DEFINE vProductoCuenta CHAR(4);
	DEFINE vCantReg 	SMALLINT;
	DEFINE vParentesco 	CHAR(2);

	-- INICIALIZACION DE VARIABLES --
	LET vCodRet  		= "000";
	LET iSqlErr   		= 0;
	LET vCantReg 		= 0;
	LET vTipCte 		= "";
	LET vNumCte 		= "";
	LET vApePat 		= "";
	LET vApeMat 		= "";
	LET vNombre1 		= "";
	LET vNombre2 		= "";
	LET vRFC 			= "";
	LET vNumTarj 		= "";
	LET Vexpiracion 	= "";
	LET Vprodtarjeta 	= "";
	LET vLimTar 		= "";
	LET vTipoCte 		= "";
	LET vStatTjt 		= "";
	LET vFechaNac 		= "";
	LET vProductoCuenta = "";
	LET vParentesco 	= "";

	--SET DEBUG FILE TO "/respaldosbd/Daniela/consctesfirxnumcta.out";
	--TRACE ON;
	
	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET vCodRet = iSqlErr;
				RETURN vCodRet, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vNumTarj, Vexpiracion, 
						Vprodtarjeta, vLimTar, vStatTjt, vTipoCte, vFechaNac, vProductoCuenta, vParentesco;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;


		-- CICLO PARA OBTENER A LOS FIRMANTES Y LAS TARJETAS DE DEBITO EN CASO DE QUE TENGAN --

		FOREACH
		
			SELECT DISTINCT
				si_cte.numcte, si_cte.apell_paterno, si_cte.apell_materno, si_cte.nombre1, si_cte.nombre2, si_cte.rfc, 
				'Firmante' AS tipo_cliente, si_pf.fecha_nac, sc_mcq.producto, sc_fir.parentesco
			INTO
				vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vTipoCte, vFechaNac, vProductoCuenta, vParentesco
			FROM
				bdicheq:"informix".sc_maechq sc_mcq,
				bdicheq:"informix".sc_firmantes AS sc_fir,
				bdinteg:"informix".si_cliente AS si_cte,
				bdinteg:"informix".si_ctepf AS si_pf
			WHERE sc_fir.empresa =  pEmpresa 
			  AND sc_fir.cuenta =  pNumeroCuenta 
			  AND sc_fir.numcte != pNumeroCliente 
			  AND sc_fir.numcte = si_cte.numcte 
			  AND si_cte.empresa = pEmpresa 
			  AND sc_fir.numcte = si_pf.numcte
			  AND sc_mcq.empresa = pEmpresa 
			  AND sc_mcq.cuenta = pNumeroCuenta


			-- OBTENER LA TARJETA DEL FIRMANTE --

			SELECT DISTINCT
				sc_tjt.expiracion, sc_tjt.prodtarjeta, sc_tjt.num_tarjeta, sc_tjt.limite_aut, sc_tjt.status_tar
			INTO
				Vexpiracion, Vprodtarjeta, vNumTarj, vLimTar, vStatTjt
			FROM
				bdicheq:"informix".sc_tarjeta AS sc_tjt
			WHERE sc_tjt.empresa = pEmpresa 
			  AND sc_tjt.cuenta = pNumeroCuenta
			  AND sc_tjt.numcte = vNumCte
			  AND sc_tjt.tipo_tarjeta = 'A'
			  AND sc_tjt.status_tar = 'A' --DSB 27/06/2012
			  AND sc_tjt.secuencia = (
					SELECT MAX(secuencia) 
					  FROM bdicheq:sc_tarjeta 
					 WHERE sc_tjt.empresa = empresa 
					   AND sc_tjt.cuenta = cuenta 
					   AND sc_tjt.numcte = numcte
					   AND sc_tjt.tipo_tarjeta = 'A');

			IF vNumTarj IS NULL THEN
				LET vNumTarj = "Sin tarjeta";
				LET vLimTar = 0;
				LET vStatTjt = "";
			END IF

			LET vCantReg = vCantReg + 1;

			RETURN vCodRet, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vNumTarj, Vexpiracion, 
					Vprodtarjeta, vLimTar, vStatTjt, vTipoCte, vFechaNac, vProductoCuenta, vParentesco WITH RESUME;
		
		END FOREACH;

		IF vCantReg = 0 THEN
			LET vCodRet  	 = "000";
			LET vNumCte  	 = "";
			LET vApePat  	 = "";
			LET vApeMat  	 = "";
			LET vNombre1 	 = "";
			LET vNombre2 	 = "";
			LET vRFC     	 = "";
			LET vNumTarj 	 = "";
			LET Vexpiracion  = "";
			LET Vprodtarjeta = "";
			LET vLimTar  	 = 0;
			LET vStatTjt 	 = "";
			LET vTipoCte 	 = "";
			LET vFechaNac 	 = "";
			LET vParentesco	 = "";

			RETURN vCodRet, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vNumTarj, Vexpiracion, 
					Vprodtarjeta, vLimTar, vStatTjt, vTipoCte, vFechaNac, vProductoCuenta, vParentesco;
		
		END IF;
	
	END 
	
END PROCEDURE

DOCUMENT
'DESCRIPCION: Se modifica para que consulte todos los status de tarjetas',
'             incluyendo las tarjetas canceladas',
'EJECUTADO O LLAMADO POR: AsigAdic.exe',
'AUTOR : Martin Eduardo Miranda Miranda',
'FECHA : 14/Septiembre/2010',
'BD    : BDICHEQ',

'DESCRIPCION: Se agrega filtro para obtener datos de tajertas unicamente Activas',
'EJECUTADO O LLAMADO POR: AsigAdic.exe',
'AUTOR : Daniela Ramírez',
'FECHA : 27/Junio/2012',
'BD    : BDICHEQ';

CREATE PROCEDURE "informix".sp_consprodxctaedad(pEmpresa CHAR(3), pNumCuenta CHAR(20), pTipo CHAR(1))

	--DATOS A REGRESAR--
	RETURNING CHAR(5) AS CodigoRetorno, 
			  CHAR(4) AS Producto;
			  
	--DEFINICION DE VARIABLES--
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRet CHAR(5);
	DEFINE cProducto CHAR(4);
	
	--INICIALIZACION DE VARIABLES--
	LET iSqlErr   = 0;
	LET cCodRet   = '00000';
	LET cProducto = '0';

	--SET DEBUG FILE TO "/respaldosbd/Daniela/sp_consprodxctaedad.out";
	--TRACE ON;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cProducto;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;

		IF(pEmpresa is NULL) OR (pNumCuenta IS NULL) OR (pTipo IS NULL) THEN
			RETURN "00001", 'Err';
		END IF;
		
		--Se obtiene el producto al que pertenece la cuenta
		
		IF pTipo = "1" THEN --Productos de Débito
		
			IF LENGTH(pNumCuenta) = 11 THEN
				SELECT producto INTO cProducto FROM bdicheq:"informix".sc_maechq WHERE cuenta = pNumCuenta;
			ELSE
				SELECT b.producto INTO cProducto FROM bdicheq:"informix".sc_tarjeta a, bdicheq:"informix".sc_maechq b
				WHERE a.num_tarjeta = pNumCuenta AND a.cuenta = b.cuenta;
			END IF;
			
		ELIF pTipo = "2" THEN --Productos de Inversión
		
			SELECT cod_instrum INTO cProducto FROM bdinvers:"informix".sv_maeinv WHERE cuenta = pNumCuenta;
			
		ELIF pTipo = "3" THEN --Productos de Crédito Bancoppel
		
			SELECT b.num_producto INTO cProducto FROM bdicred:"informix".sd_tarjeta a, bdicred:"informix".sd_maecred b
			WHERE a.num_tarjeta = pNumCuenta AND a.num_credito = b.num_credito;
			
		ELIF pTipo = "4" THEN --Producto de Crédito Coppel
		
			LET cProducto = "6500";
			
		END IF;

		
		RETURN cCodRet, cProducto;

	END
	
END PROCEDURE

DOCUMENT
'Conocer el tipo de producto al que pertenece la cuenta del cliente',
'Autor : Daniela Ramírez',
'FECHA : 22/05/2012',
'BD:     bdicheq';

CREATE PROCEDURE "informix".sp_conciliachqcomp1_pba( pempresa CHAR(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER;
        
    DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(50);
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE desc_err     CHAR(50);
    DEFINE vcontador1   INTEGER;
    DEFINE vcontador2   INTEGER;
    DEFINE vcontador3   INTEGER;
    DEFINE vcomienza1   SMALLINT;
    DEFINE vcomienza2   SMALLINT;
    DEFINE ven_transacc SMALLINT;
    
    DEFINE vsql          CHAR(600);
    DEFINE vstmt         CHAR(250);
    DEFINE vfecha        CHAR(8);
    DEFINE vfecha_hoy    DATE;
    DEFINE vfecha_ant    DATE;
    DEFINE vpri_hab_mes  DATE;
    DEFINE vfecha_actual DATE;
    DEFINE vproceso      CHAR(16);
    DEFINE vsistema      CHAR(2);
    DEFINE vexiste       INTEGER;
    DEFINE vexistefin    INTEGER;
    DEFINE vusuario      CHAR(10);
    DEFINE vfechaproc    DATE;
    DEFINE vfechaprocsdo DATE;
    
    DEFINE vminaniomes  CHAR(6);
    DEFINE vmaxaniomes  CHAR(6);
    DEFINE vcuenta      CHAR(20);
    DEFINE vnum_cte     CHAR(20);
    DEFINE vsucursal    CHAR(4);
    DEFINE vejecutivo   CHAR(8);
    DEFINE vproducto    CHAR(4);
    DEFINE wproducto    CHAR(4);
    
    DEFINE vcapital_anterior    MONEY(18,2);
    DEFINE vcapital_calculado   MONEY(18,2);
    DEFINE vmovs_cargo_capital  MONEY(18,2);
    DEFINE vmovs_abono_capital  MONEY(18,2);
    DEFINE vcapital_actual      MONEY(18,2);
    DEFINE vdiferencia_capital  MONEY(18,2);

    DEFINE vinteres_anterior    MONEY(18,2);
    DEFINE vinteres_calculado   MONEY(18,2);
    DEFINE vmovs_cargo_interes  MONEY(18,2);
    DEFINE vmovs_abono_interes  MONEY(18,2);
    DEFINE vinteres_actual      MONEY(18,2);
    DEFINE vdiferencia_interes  MONEY(18,2);
    
    DEFINE vcuentaini           CHAR(20);
    DEFINE vcuentafin           CHAR(20);
    
    LET vcodret1     = '000';
    LET vcodret2     = '000';
    LET vcodret3     = 'PROCESO CONCLUIDO SATISFACTORIAMENTE';
    LET sql_err	     = 0;
    LET isam_err     = 0;
    LET desc_err     = '';
    LET vcontador1   = 0;
    LET vcontador2   = 0;
    LET vcontador3   = 0;
    LET vcomienza1   = -1;
    LET vcomienza2   = -1;
    LET ven_transacc = 0; 
    
    LET vsql          = '';
    LET vstmt         = '';
    LET vfecha        = '';
    LET vfecha_hoy    = ''; 
    LET vfecha_ant    = '';
    LET vpri_hab_mes  = '';
    LET vfecha_actual = '';
    LET vproceso      = 'conciliachqcomp1';
    LET vsistema      = '01';
    LET vexiste       = 0;
    LET vexistefin    = 0;
    LET vusuario      = user;
    LET vfechaproc    = '';
    LET vfechaprocsdo = '';
    
    LET vminaniomes  = '';
    LET vmaxaniomes  = '';
    LET vcuenta      = ''; 
    LET vproducto    = '';
    LET wproducto    = '';
    LET vnum_cte     = '';
    LET vsucursal    = '';
    LET vejecutivo   = '';
    
    LET vcapital_anterior   = 0.00;
    LET vcapital_calculado  = 0.00;
    LET vmovs_cargo_capital = 0.00;
    LET vmovs_abono_capital = 0.00;
    LET vcapital_actual     = 0.00;
    LET vdiferencia_capital = 0.00;
    
    LET vinteres_anterior   = 0.00;
    LET vinteres_calculado  = 0.00;
    LET vmovs_cargo_interes = 0.00;
    LET vmovs_abono_interes = 0.00;
    LET vinteres_actual     = 0.00;
    LET vdiferencia_interes = 0.00;
    
    LET vcuentaini = '';
    LET vcuentafin = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_conciliachqcomp1.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vusuario||''','||
                       'status_proc   = '''||'C'||''','||
                       'codret        = '''||vcodret1||''','||
                       'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horasconcilchq1.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horasconcilchq1.sql';
            SYSTEM vstmt;
            RETURN vcodret1, vcodret2, vcodret3, vcontador1, vcontador2;
        END IF;
    END EXCEPTION;
    
    ON EXCEPTION IN (-668)
        LET vcodret1 = '668';
        LET vcodret2 = '668';
        LET vcodret3 = 'PROBLEMAS EN LA DESCARGA DE ARCHIVOS VERIFIQUE';
    END EXCEPTION WITH RESUME;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_conciliachqcomp1.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    -- // OBTIENE LAS FECHAS DEL SISTEMA
    SELECT fecha_hoy, fecha_ant, pri_hab_mes, fecha_hoy
      INTO vfecha_hoy, vfecha_ant, vpri_hab_mes, vfecha_actual
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
    
    -- // VERIFICA SE HAYA EFECTUADO EL PASO DE MOVS A HISTORICO
    select fecha 
      into vfechaproc
      from sc_contproc
     where empresa = pempresa 
       and proceso = "pasomovshist"
       and fecha   = vfecha_hoy;

    if vfechaproc is null then
        let vcodret1 = "953";
        let vcodret2 = "953";
        
        SELECT descripcion
          INTO vcodret3
          FROM bdinteg:si_codret
         WHERE sistema = vsistema
           AND codigo_retorno = vcodret1;
        
        return vcodret1, vcodret2, vcodret3, vcontador1, vcontador2;
    end if;
    
    -- // VERIFICA SE HAYA ACTUALIZADO LA TABLA DE SALDOS DIARIOS (SEGUNDA PARTE)
    select fecha 
      into vfechaprocsdo
      from bdinteg:sx_contproc
     where empresa = pempresa 
       and proceso = "sdoschqdes"
       and fecha   = vfecha_actual
       and sistema = vsistema
       and status_proc = 'F';

    if vfechaprocsdo is null then
        let vcodret1 = "950";
        let vcodret2 = "950";
        
        SELECT descripcion
          INTO vcodret3
          FROM bdinteg:si_codret
         WHERE sistema = vsistema
           AND codigo_retorno = vcodret1;
        
        return vcodret1, vcodret2, vcodret3, vcontador1, vcontador2;
    end if;
    
    -- // Verifica se haya iniciado el proceso principal
    select {+INDEX (bdicheq:sc_contproc idx_contproc2)} fecha 
      into vfechaproc
      from sc_contproc
     where empresa = pempresa 
       and proceso = "inicio_conciliachq";
       
    if vfechaproc <> vfecha_hoy then
        let vcodret1 = "977";        
        return vcodret1, vcodret2, vcodret3, vcontador1, vcontador2;
    end if
     
    -- // GUARDA REGISTRO DE CONTROL EN TABLA DE INTEGRAL
    select count(*)
      into vexiste
      from bdinteg:sx_contproc
     where empresa = pempresa
       and proceso = vproceso
       and fecha   = vfecha_hoy
       and sistema = vsistema;

    if vexiste = 0 then
        LET vsql = 'echo " INSERT INTO bdinteg:sx_contproc VALUES '||
                   '('''||pempresa||''', '''||vproceso||''', '''||vfecha_hoy||''', '''||vsistema||''', '''||'I'||''', '''||vusuario||''','||
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horasconcilchq1.sql';
        SYSTEM vsql;
        
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horasconcilchq1.sql';
        SYSTEM vstmt;
    else
        SELECT count(*)
          INTO vexistefin
          FROM bdinteg:sx_contproc
         WHERE empresa     = pempresa
           AND proceso     = vproceso
           AND fecha       = vfecha_hoy
           AND sistema     = vsistema
           AND status_proc = "F";
           
        IF vexistefin = 0 THEN
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vusuario||''','||
                       'status_proc   = '''||'I'||''','||
                       'codret        = '''||' '||''','||
                       'hora_fin      = '''||' '||''','||
                       'hora_ini      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horasconcilchq1.sql';
            SYSTEM vsql;
            
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horasconcilchq1.sql';
            SYSTEM vstmt;
        ELSE
            LET vcodret1 = "958";
            LET vcodret2 = "958";
            
            SELECT descripcion
              INTO vcodret3
              FROM bdinteg:si_codret
             WHERE sistema = vsistema
               AND codigo_retorno = vcodret1;

            RETURN vcodret1, vcodret2, vcodret3, vcontador1, vcontador2;
        END IF;
    end if;
    
    -- // OBTIENE EL RANGO DE CUENTAS A PROCESAR
    SELECT valor
      INTO vcuentaini
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'CtaIniConcilChqComp1'; 
       
    SELECT valor
      INTO vcuentafin
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'CtaIniConcilChqComp2'; 
    
    -- // TABLA TEMPORAL DE MOVIMIENTOS
    ---SELECT {+INDEX(sc_movhis idx_movhisnew6), +INDEX(bdinteg:si_transacc idx_si_transacc4), +INDEX(bdinteg:si_prodtran idx01_prodtran)} 
    SELECT {+INDEX(sc_movhis idx_movhisnew4), +INDEX(bdinteg:si_transacc idx_si_transacc4), +INDEX(bdinteg:si_prodtran idx01_prodtran)} 
           mov.cuenta, mov.transacc, mov.monto_tot,
           TRIM(prod.c_ccmayor)||TRIM(prod.c_ccsub)||TRIM(prod.c_ccsubsub)||TRIM(prod.c_ccsssub)||TRIM(prod.c_ccssssub) AS cta_cargo,
           TRIM(prod.a_ccmayor)||TRIM(prod.a_ccsub)||TRIM(prod.a_ccsubsub)||TRIM(prod.a_ccsssub)||TRIM(prod.a_ccssssub) AS cta_abono
      FROM sc_movhis mov,
           bdinteg:si_transacc tran,
           bdinteg:si_prodtran prod
     ---WHERE mov.fech_alt = vfecha_hoy
     WHERE mov.empresa = '001'
       AND mov.fech_alt = vfecha_hoy
       AND mov.cancelad != 'S'
       AND mov.cuenta BETWEEN vcuentaini and vcuentafin
       ---AND mov.cuenta >= vcuentaini
       ---AND mov.cuenta < vcuentafin
       AND mov.producto <> '1100'
       AND tran.empresa = mov.empresa
       AND tran.numero = mov.transacc
       AND tran.se_contabiliza = 'S'
       AND tran.sistema = '01'
       AND prod.transaccion = tran.numero
       AND prod.producto = mov.producto
       AND prod.sistema = tran.sistema
      INTO TEMP tmp_concilia WITH NO LOG;
      
    ---CREATE INDEX idx_concilia ON tmp_concilia(cuenta) ONLINE;
    CREATE INDEX idx_concilia2 ON tmp_concilia(cuenta, cta_cargo) ONLINE;
    CREATE INDEX idx_concilia3 ON tmp_concilia(cuenta, cta_abono) ONLINE;
    
    ---UPDATE STATISTICS HIGH FOR TABLE tmp_concilia(cuenta, cta_cargo, cta_abono);
    
    -- // FOREACH CUENTAS 
    FOREACH WITH HOLD
        SELECT {+INDEX(sc_maechq idx_sc_maechq), +INDEX(sc_maenoc idx_sc_maenoc2)} chq.cuenta, chq.producto, chq.num_cte, chq.sucursal, noc.ejecutivo
          INTO vcuenta, vproducto, vnum_cte, vsucursal, vejecutivo
          FROM sc_maechq chq,
               sc_maenoc noc
         ---WHERE chq.empresa = pempresa
         WHERE chq.cuenta BETWEEN vcuentaini and vcuentafin
           ---AND chq.cuenta >= vcuentaini
           ---AND chq.cuenta < vcuentafin
           AND chq.producto <> '1100'
           AND ( chq.status_cta <> '2' OR chq.fecha_proceso >= vfecha_hoy )
           AND noc.empresa = chq.empresa
           AND noc.cuenta = chq.cuenta
           AND noc.fecha_alta < vfecha_actual
           
        IF vcomienza1 = -1 THEN
            LET vcomienza1 = 0;
            LET ven_transacc = 1; 
            BEGIN WORK;
        END IF;

        -- // OBTIENE SALDOS ANTERIORES
        EXECUTE PROCEDURE sp_capintafecha(vcuenta, vfecha_ant) 
        INTO vcodret1, vcapital_anterior, vinteres_anterior;
        
        IF vcodret1 = '100' THEN
            LET vcapital_anterior = 0.00;
            LET vinteres_anterior = 0.00;
            LET vcodret1 = '000';
        END IF;
        
        LET vcapital_calculado = vcapital_anterior;
        LET vinteres_calculado = vinteres_anterior;
        
        -- // RESTA CAPITAL 
        SELECT {+INDEX(tmp_concilia idx_concilia2)} 
               NVL(SUM(tmp.monto_tot),0.00)
          INTO vmovs_cargo_capital
          FROM tmp_concilia tmp
         WHERE tmp.cuenta = vcuenta
           AND tmp.cta_cargo IN( SELECT {+INDEX(sc_ctascontchq idx_ctascont)} 
                                        cta_contable 
                                   FROM sc_ctascontchq 
                                  WHERE tipo IN('CAPITAL', 'SOBREGIRO') );

        LET vcapital_calculado = vcapital_calculado - vmovs_cargo_capital;
        
        -- // SUMA CAPITAL 
        SELECT {+INDEX(tmp_concilia idx_concilia3)} 
               NVL(SUM(tmp.monto_tot),0.00)
          INTO vmovs_abono_capital
          FROM tmp_concilia tmp
         WHERE tmp.cuenta = vcuenta
           AND tmp.cta_abono IN( SELECT {+INDEX(sc_ctascontchq idx_ctascont)} 
                                        cta_contable 
                                   FROM sc_ctascontchq 
                                  WHERE tipo IN('CAPITAL', 'SOBREGIRO') );

        LET vcapital_calculado = vcapital_calculado + vmovs_abono_capital;
        
        -- // RESTA INTERES
        SELECT {+INDEX(tmp_concilia idx_concilia2)} 
               NVL(SUM(tmp.monto_tot),0.00)
          INTO vmovs_cargo_interes
          FROM tmp_concilia tmp
         WHERE tmp.cuenta = vcuenta
           AND tmp.cta_cargo IN( SELECT {+INDEX(sc_ctascontchq idx_ctascont)} 
                                        cta_contable 
                                   FROM sc_ctascontchq 
                                  WHERE tipo = 'INTERES' );

        LET vinteres_calculado = vinteres_calculado - vmovs_cargo_interes;
        
        -- // SUMA INTERES
        SELECT {+INDEX(tmp_concilia idx_concilia3)} 
               NVL(SUM(tmp.monto_tot),0.00)
          INTO vmovs_abono_interes
          FROM tmp_concilia tmp
         WHERE tmp.cuenta = vcuenta
           AND tmp.cta_abono IN( SELECT {+INDEX(sc_ctascontchq idx_ctascont)} 
                                        cta_contable 
                                   FROM sc_ctascontchq 
                                  WHERE tipo = 'INTERES' );

        LET vinteres_calculado = vinteres_calculado + vmovs_abono_interes;
        
        -- // OBTIENE SALDOS ACTUALES
        EXECUTE PROCEDURE sp_capintafecha(vcuenta, vfecha_hoy) 
        INTO vcodret1, vcapital_actual, vinteres_actual;
        
        IF vcodret1 = '100' THEN
            LET vcapital_actual = 0.00;
            LET vinteres_actual = 0.00;
            LET vcodret1 = '000';
        END IF;
        
        -- // OBTIENE DIFERENCIAS
        LET vdiferencia_capital = vcapital_actual - vcapital_calculado;
        LET vdiferencia_interes = vinteres_actual - vinteres_calculado;
        
        -- // LLENA TABLA DE TODAS LAS CUENTAS
        INSERT INTO conciliachq VALUES
        (vfecha_hoy, vcuenta, vproducto, vnum_cte, vsucursal, vejecutivo,
         vcapital_anterior, vmovs_cargo_capital, vmovs_abono_capital, vcapital_calculado, vcapital_actual, vdiferencia_capital, 
         vinteres_anterior, vmovs_cargo_interes, vmovs_abono_interes, vinteres_calculado, vinteres_actual, vdiferencia_interes);
        
        -- // LLENA TABLA DE DIFERENCIAS
        IF (vdiferencia_capital != 0.00 OR vdiferencia_interes != 0.00) THEN
            INSERT INTO conciliachq_dif VALUES
            (vfecha_hoy, vcuenta, vproducto, vnum_cte, vsucursal, vejecutivo,
             vcapital_anterior, vmovs_cargo_capital, vmovs_abono_capital, vcapital_calculado, vcapital_actual, vdiferencia_capital, 
             vinteres_anterior, vmovs_cargo_interes, vmovs_abono_interes, vinteres_calculado, vinteres_actual, vdiferencia_interes); 
             
            LET vcontador2 = vcontador2 + 1;
        END IF;
        
        LET vcontador1 = vcontador1 + 1;
        LET vcontador3 = vcontador3 + 1;
        
        IF vcontador3 >= 5000 THEN
            LET vcontador3 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET vcuenta      = ''; 
        LET vproducto    = '';
        LET vnum_cte     = '';
        LET vsucursal    = '';
        LET vejecutivo   = '';
        
        LET vcapital_anterior   = 0.00;
        LET vcapital_calculado  = 0.00;
        LET vmovs_cargo_capital = 0.00;
        LET vmovs_abono_capital = 0.00;
        LET vcapital_actual     = 0.00;
        LET vdiferencia_capital = 0.00;
        
        LET vinteres_anterior   = 0.00;
        LET vinteres_calculado  = 0.00;
        LET vmovs_cargo_interes = 0.00;
        LET vmovs_abono_interes = 0.00;
        LET vinteres_actual     = 0.00;
        LET vdiferencia_interes = 0.00;
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
               'SET ejecutivo = '''||vusuario||''','||
               'status_proc   = '''||'F'||''','||
               'codret        = '''||vcodret1||''','||
               'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
               'WHERE empresa = '''||pempresa||''' '||
               'AND proceso   = '''||vproceso||''' '||
               'AND fecha     = '''||vfecha_hoy||''' '||
               'AND sistema   = '''||vsistema||''';" > /tmp/horasconcilchq1.sql';
    SYSTEM vsql;
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horasconcilchq1.sql';
    SYSTEM vstmt;
           
    END;

    RETURN vcodret1, vcodret2, vcodret3, vcontador1, vcontador2;

END PROCEDURE;