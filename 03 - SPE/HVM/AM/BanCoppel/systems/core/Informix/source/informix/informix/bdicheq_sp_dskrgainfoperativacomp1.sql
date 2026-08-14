CREATE PROCEDURE "informix".sp_dskrgainfoperativacomp1( pempresa CHAR(3) )
RETURNING CHAR(5); 
      
    DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(50);
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE desc_err     CHAR(50);
    
    DEFINE vsql                 CHAR(1200);
    DEFINE vstmt                CHAR(250);
    DEFINE vfecha1              CHAR(8);
    DEFINE vfecha2              CHAR(8);
    DEFINE vfecha_hoy           DATE;
    DEFINE vfecha_ant           DATE;
    DEFINE vpri_hab_mes         DATE;
    DEFINE vproceso             CHAR(18);
    DEFINE vsistema             CHAR(2);
    DEFINE vexiste              INTEGER;
    DEFINE vexistefin           INTEGER;
    DEFINE vusuario             CHAR(10);
    DEFINE vfechaprocsdo        DATE;
    DEFINE vaniomes             CHAR(6);
    DEFINE vcodret4             CHAR(5);
	DEFINE vcodret8             CHAR(5);
	DEFINE vcodret5             CHAR(5);
	DEFINE vcodret6             CHAR(5);
	DEFINE vcodret7             CHAR(5);
	DEFINE vcodret9             CHAR(5);
    DEFINE vcodret10            CHAR(5);
    DEFINE vcodret11            CHAR(5);
	DEFINE vdia        		    CHAR(2);
	DEFINE vpri_mes_ant 	    DATE;
	DEFINE vult_mes_ant 	    DATE;
	DEFINE vaniomespas		    CHAR(6);
	DEFINE vmesaniopas		    CHAR(6);
    DEFINE dFechaIniMovHis      DATE;
    DEFINE dFechaIniMovHisOld   DATE;
    DEFINE vRepCtasInac         CHAR(5);
    DEFINE vConsecutivo         CHAR(7);
    DEFINE vfolio               CHAR(23);
    DEFINE vnombre_archivo      CHAR(30);
    DEFINE vtot_regs            INTEGER;
    DEFINE vtotal_registros     CHAR(20);
    DEFINE vfecha_solicitud     CHAR(10);
    
    LET vcodret1     = '000';
    LET vcodret2     = '000';
    LET vcodret3     = '';
    LET sql_err	     = 0;
    LET isam_err     = 0;
    LET desc_err     = '';
    
    LET vsql               = '';
    LET vstmt              = '';
    LET vfecha1            = '';
    LET vfecha2            = '';
    LET vfecha_hoy         = ''; 
    LET vfecha_ant         = '';
    LET vpri_hab_mes       = '';
    LET vproceso           = 'dskrgainfoperativacom1';
    LET vsistema           = '01';
    LET vexiste            = 0;
    LET vexistefin         = 0;
    LET vusuario           = user;
    LET vfechaprocsdo      = '';
    LET vaniomes           = '';
    LET vcodret4           = '';
	LET vcodret8           = '';
	LET vcodret5           = '';
	LET vcodret6           = '';
	LET vcodret7           = '';
	LET vcodret9           = '';
    LET vcodret10          = '';
    LET vcodret11          = '';
	LET vdia       	       = '';
	LET vpri_mes_ant       = '';
	LET vult_mes_ant       = '';
	LET vaniomespas        = '';
	LET vmesaniopas        = '';
    LET dFechaIniMovHis    = '';
    LET dFechaIniMovHisOld = '';
    LET vRepCtasInac       = '';
    LET vConsecutivo       = '';
    LET vfolio             = '';
    LET vnombre_archivo    = '';
    LET vtot_regs          = 0;
    LET vtotal_registros   = '';
    LET vfecha_solicitud   = '';
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/dskrgainfoperativacom1.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            LET vsql = '';
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vusuario||''','||
                       'status_proc   = '''||'E'||''','||
                       'codret        = '''||vcodret1||''','||
                       'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horasinfoperComp1.sql';
            SYSTEM vsql;
            LET vsql = '';
            LET vstmt = '';
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horasinfoperComp1.sql';
            SYSTEM vstmt;
            LET vstmt = '';
            RETURN vcodret1;
        END IF;
    END EXCEPTION;
    
    ON EXCEPTION IN (-668)
        LET vcodret1 = '668';
    END EXCEPTION WITH RESUME;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/dskrgainfoperativacom1.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTIENE LAS FECHAS DEL SISTEMA
    SELECT fecha_hoy, fecha_ant, pri_hab_mes, pri_dia_mes - 1 units day , pri_dia_mes - 1 units month
      INTO vfecha_hoy, vfecha_ant, vpri_hab_mes, vult_mes_ant, vpri_mes_ant
      FROM sc_fechas
     WHERE empresa = pempresa;
	 
    -- // VERIFICA SE HAYA ACTUALIZADO LA TABLA DE SALDOS DIARIOS (SEGUNDA PARTE)
    select fecha 
     into vfechaprocsdo
      from bdinteg:sx_contproc
     where empresa = pempresa 
      and proceso = "sdoschqdes"
       and fecha   = vfecha_hoy
       and sistema = vsistema
       and status_proc = 'F';

    if vfechaprocsdo is null then
        let vcodret1 = "950";        
        return vcodret1;
    end if;
    
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
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horasinfoperComp1.sql';
        SYSTEM vsql;
        LET vsql = '';
        
        LET vstmt = '';
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horasinfoperComp1.sql';
        SYSTEM vstmt;
        LET vstmt = '';
    else
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
                   'AND sistema   = '''||vsistema||''';" > /tmp/horasinfoperComp1.sql';
        SYSTEM vsql;
        LET vsql = '';
        
        LET vstmt = '';
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horasinfoperComp1.sql';
        SYSTEM vstmt;
        LET vstmt = '';
    end if;
    
    -- // OBTIENE PARAMETROS PARA BUSQUEDAS EN HISTORICOS DE MOVIMIENTOS
    SELECT valor
      INTO dFechaIniMovHis
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'fechcon_movhis';
        
    SELECT valor
      INTO dFechaIniMovHisOld
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'FechIniCon_movhis_ol';

    -- // ####################################################################   REPORTES DIARIOS   ####################################################################
    
    LET vfecha1 = TO_CHAR(vfecha_hoy, '%d%m%Y');
    LET vfecha2 = TO_CHAR(vfecha_ant, '%d%m%Y');
    
 
    -- // MOVIMIENTOS CUENTA COPPEL 16000000012
    SELECT LPAD(CAST(COUNT(num_cliente)+1 AS INTEGER),7,0) 
      INTO vConsecutivo
      FROM bdibei:bei_consulta_mov
     WHERE num_cliente = '000516399';
    
    LET vfolio = TO_CHAR(vfecha_ant, '%d%m%Y')||'00000000'||vConsecutivo;
    LET vnombre_archivo = vfolio||'.txt';
    
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
               'UNLOAD TO /home/sysemnet/movempresanet/'||TRIM(vnombre_archivo)||' '||
               'SELECT mov.folio_suc, mov.fech_alt, mov.transacc, trx.naturaleza, mov.sdo_cuenta, mov.monto_tot, trx.descripcion, mov.referencia, mov.cuenta '||
               'FROM bdicheq:sc_movdia_concil mov, bdinteg:si_transacc trx '||
               'WHERE mov.cuenta = ''16000000012'' AND mov.fech_alt = '''||vfecha_ant||''' AND mov.cancelad != ''S'' AND trx.numero = mov.transacc AND trx.sistema = ''01'' '||
               'ORDER BY mov.num_serial DESC;" > /resplogifx/conciliachq/movscoppel.sql';
    SYSTEM vsql;
    LET vsql = '';
  
    LET vstmt = '';
    LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/movscoppel.sql"; 
    SYSTEM vstmt;
    LET vstmt = '';
      
    SELECT COUNT(*)
      INTO vtot_regs
      FROM bdicheq:sc_movdia_concil mov, 
           bdinteg:si_transacc trx 
     WHERE mov.cuenta = '16000000012' 
       AND mov.fech_alt = vfecha_ant
       AND mov.cancelad != 'S' 
       AND trx.numero = mov.transacc
       AND trx.sistema = '01';
       
    LET vtotal_registros = vtot_regs;
    LET vfecha_solicitud = TO_CHAR(vfecha_ant, '%d/%m/%Y');
       
    INSERT INTO bdibei:bei_consulta_mov
    ( id_consulta, empresa, folio, num_cliente, cuenta, id_usuario, f_solicitud_arch, h_solicitud_arch, f_inicial, f_final, status_arch, fh_status_arch, total_registros, nombre )
    VALUES
    ( 0, '001', vfolio, '000516399', '16000000012', '2215', vfecha_solicitud, '00:00:00', vfecha_ant, vfecha_ant, '04', to_char(current), vtotal_registros, vnombre_archivo );
    
    /*
    -- // CUENTAS SOBREGIRADAS DEL SISTEMA DE CHEQUES 
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
               'UNLOAD TO /resplogifx/conciliachq/conciliachqctassbg_'||vfecha1||'.txt '||
               'SELECT cuenta, status_cta, sucursal, sdo_dia_ant, imp_chq_sbg '||
               'FROM sc_maechq '||
               'WHERE status_cta != ''2'' '||
               'AND imp_chq_sbg != 0.00;" > /resplogifx/conciliachq/ctassbg.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '';
    LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctassbg.sql"; 
    SYSTEM vstmt;
    LET vstmt = '';
    
    -- // LLENA TABLAS PARA CONSULTAS SOC - TASF
    INSERT INTO sc_cuentassbg
    SELECT {+INDEX(sc_maechq idx_sc_maechq2)}
           b.fecha_hoy, a.cuenta, a.status_cta, a.sucursal, a.sdo_dia_ant, a.imp_chq_sbg
      FROM sc_maechq a,
           sc_fechas b
     WHERE a.status_cta <> '2'
       AND a.imp_chq_sbg <> 0.00
       AND b.empresa = a.empresa;
	
    -- // CUENTAS CON SALDO NEGATIVO DEL SISTEMA DE CHEQUES 
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
               'UNLOAD TO /resplogifx/conciliachq/conciliachqctasdoneg_'||vfecha1||'.txt '||
               'SELECT cuenta, status_cta, sucursal, sdo_dia_ant, imp_chq_sbg '||
               'FROM sc_maechq '||
               'WHERE status_cta != ''2'' '||
               'AND sdo_dia_ant < 0.00;" > /resplogifx/conciliachq/ctasneg.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '';
    LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctasneg.sql"; 
    SYSTEM vstmt;
    LET vstmt = '';
    
    -- // LLENA TABLAS PARA CONSULTAS SOC - TASF
    INSERT INTO sc_cuentassdoneg
    SELECT {+INDEX(sc_maechq idx_sc_maechq2)}
           b.fecha_hoy, a.cuenta, a.status_cta, a.sucursal, a.sdo_dia_ant, a.imp_chq_sbg
      FROM sc_maechq a,
           sc_fechas b
     WHERE a.status_cta <> '2'
       AND a.sdo_dia_ant < 0.00
       AND b.empresa = a.empresa;
    
    -- // SE AGREGA REPORTE DE INVERSIONES CRECIENTES CANCELADAS
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
               'UNLOAD TO /resplogifx/conciliachq/inv_crec_canceladas_'||vfecha2||'.unl '||
               'select a.cuenta, a.fecha_proceso, b.fecha_alta, b.fecha_mod, a.sucursal, b.int_acum '||
               'from bdicheq:sc_maechq a, bdicheq:sc_maenoc b '||
               'where a.empresa = b.empresa '||
			   'and a.cuenta = b.cuenta '||
			   'and a.producto = ''"1100"'' '||
			   'and a.fecha_proceso = '''||vfecha_ant||''' '||
               'and b.int_acum > 0;" > /resplogifx/conciliachq/inv_crec_cancel.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '';
    LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/inv_crec_cancel.sql"; 
    SYSTEM vstmt;
    LET vstmt = '';
    
	-- // SE AGREGA OBTIENEN RETIROS MAYORES A 150 000
	LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
               'UNLOAD TO /resplogifx/conciliachq/retiros_'||vfecha2||'.unl '||
               'SELECT cuenta, sucursal, fech_hor, monto_tot '||
               'FROM bdicheq:sc_movdia_concil '||
               'WHERE fech_alt = '''||vfecha_ant||''' '||
			   'AND transacc = "0223" '||
			   'AND monto_tot >= 150000.00 '||
               'AND cancelad <> ''"S"'';" > /resplogifx/conciliachq/ret_may_150mil.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '';
    LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ret_may_150mil.sql"; 
    SYSTEM vstmt;
    LET vstmt = '';
    
    -- // LLENA TABLAS PARA CONSULTAS SOC - TASF
    INSERT INTO sc_retirosmayores
    SELECT {+INDEX(sc_movdia_concil idx_movdiaconc_1)}
           fech_alt, cuenta, sucursal, fech_hor, monto_tot
      FROM sc_movdia_concil
     WHERE fech_alt = vfecha_ant
       AND cancelad <> 'S'
       AND transacc = '0223'
       AND monto_tot >= 150000.00;
    
    -- // GENERA ARCHIVO DE CUENTAS CON MESIVERSARIO AL DIA ANTERIOR DEL SISTEMA DE CHEQUES
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
               'UNLOAD TO /resplogifx/conciliachq/ctasmesiversario_'||vfecha2||'.txt '||
               'SELECT {+INDEX(sc_maehis maehis_ffin)} '||
               'cuenta, acum_sdo_pos, dia_sdo_pos, ROUND(acum_sdo_pos/dia_sdo_pos, 2), tasabruta, totintpag, totisrcobrado, fechafin '||
               'FROM sc_maehis '||
               'WHERE fechafin = '''||vfecha_ant||''' '||
               'AND dia_sdo_pos > 0;" > /resplogifx/conciliachq/ctasmesiv.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '';
    LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctasmesiv.sql"; 
    SYSTEM vstmt;
    LET vstmt = '';
	
	-- // DESCARGA ARCHIVO DE MOVIMIENTOS DIARIOS DE DEPOSITOS EN EFECTIVO
	EXECUTE PROCEDURE "informix".sp_repdepefectivo(pempresa)
	INTO vcodret7; */
 
    -- // SE GENERA ARCHIVO DE LA TRANSACCION 2402 
    select transaccion
      from bdinteg:si_prodtran
     where sistema = "01"
       and (c_ccmayor = '2402' or a_ccmayor = '2402')
       and (c_ccsub in("90", "93") or a_ccsub in("90", "93"))
    into temp tmp_transacc with no log;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'tmp_mov') THEN
        DROP TABLE bdicheq:tmp_mov;        
    END IF;
        
    CREATE RAW TABLE tmp_mov 
      ( 
        aniomes      	CHAR(6) NOT NULL,
        num_serial   	SERIAL NOT NULL,
        folio_suc    	CHAR(16),
        sucursal     	CHAR(4),
        usuario      	CHAR(8),
        fech_alt     	DATE,
        fech_val     	DATE,
        fech_hor     	DATETIME HOUR to FRACTION(3),
        transacc     	CHAR(4),
        suc_cuen     	CHAR(4),
        producto     	CHAR(4),
        empresa      	CHAR(3),
        cuenta       	CHAR(20),
        causa_dev    	CHAR(2),
        num_cheq     	INTEGER,
        monto_tot    	MONEY,
        firme        	MONEY,
        en_sbc       	MONEY,
        remesas      	MONEY,
        dias_ret     	SMALLINT,
        cancelad     	CHAR(1),
        edo_cta      	CHAR(1),
        sdo_cuenta   	MONEY,
        transacc_suc 	CHAR(4),
        referencia   	CHAR(40),
        tasa_aplicada	DECIMAL(9,6),
        num_tarjeta  	CHAR(16),
        usuautoriza  	CHAR(8), 
        referencia_23   CHAR(23),
		fech_oper		DATE,
        descripcion		CHAR(50),
        cuenta_cargo	CHAR(60),
        cuenta_abono	CHAR(60)
      )
    EXTENT SIZE 7536 NEXT SIZE 752 LOCK MODE ROW;
    
    LET vaniomes = TO_CHAR(vfecha_ant, '%Y%m');
    
    INSERT INTO tmp_mov
    select {+INDEX(sc_movhis idx_movhisnew1)}
           vaniomes, mov.*, tra.descripcion,
           case when prod.c_ccmayor >= '2402' then c_ccmayor || c_ccsub || c_ccsubsub || c_ccsssub || c_ccssssub || c_sector else "" end as Cuenta_Cargo,
           case when prod.a_ccmayor >= '2402' then a_ccmayor || a_ccsub || a_ccsubsub || a_ccsssub || a_ccssssub || a_sector else "" end as Cuenta_Abono
      from bdicheq:sc_movdia_concil mov,
           bdinteg:si_transacc tra,
           bdinteg:si_prodtran prod
     where mov.empresa = '001'
       and mov.cuenta > "10000000000"
       and mov.fech_alt = vfecha_ant 
       and mov.cancelad <> "S"
       and mov.transacc in(select transaccion from tmp_transacc)
       and tra.numero = mov.transacc
       and tra.sistema = '01'
       and mov.empresa = tra.empresa
       and mov.empresa = prod.empresa
       and prod.transaccion = tra.numero
       and mov.producto = prod.producto;
    
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
               'UNLOAD TO /resplogifx/conciliachq/movs_2402_'||vfecha2||'.unl '||
               'select a.*, '' '' archivo_vnd, '' '' archivo_atmd '||
               'from tmp_mov a;" > /resplogifx/conciliachq/obt_movs_2402.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '';
    LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/obt_movs_2402.sql"; 
    SYSTEM vstmt;
    LET vstmt = '';
      
    -- // LLENA TABLAS PARA CONSULTAS SOC - TASF
	/* #########################################################################################################################
    INSERT INTO sc_movs2402
    SELECT a.fech_alt, a.aniomes, a.num_serial, a.folio_suc, a.sucursal, a.usuario, a.fech_alt, a.fech_val, a.fech_hor,
           a.transacc, a.suc_cuen, a.producto, a.empresa, a.cuenta, a.causa_dev, a.num_cheq, a.monto_tot, a.firme,
           a.en_sbc, a.remesas, a.dias_ret, a.cancelad, a.edo_cta, a.sdo_cuenta, a.transacc_suc, a.referencia,
           a.tasa_aplicada, a.num_tarjeta, a.usuautoriza, a.referencia_23, a.descripcion, a.cuenta_cargo, a.cuenta_abono,
           ' ' archivo_vnd, ' ' archivo_atmd
      FROM tmp_mov a; 
	######################################################################################################################### */    
	--- RSV	
    --	EXECUTE PROCEDURE "informix".sp_consulta_info_soc_tasf(pempresa)
	--INTO vcodret5;
	
    -- // ####################################################################   REPORTES DIARIOS   ####################################################################
    -- // EJECUCIÃÂN DE SP QUE GENERA LOS REPORTES DIARIOS DE PORTABILIDAD DE NOMINA  
	--EXECUTE PROCEDURE "informix".sp_reporte_diario_porta(pempresa)
    --INTO vcodret8; */
	
    -- // ####################################################################   REPORTES SEMANALES   ####################################################################
    IF WEEKDAY(vfecha_hoy) = 0 THEN  --- DEPOSITOS EN EFECTIVO
        EXECUTE PROCEDURE sp_rptdepefectivo(pempresa)
        INTO vcodret4;
    ELIF WEEKDAY(vfecha_hoy) = 1 THEN  --- DEPOSITOS EN EFECTIVO
        EXECUTE PROCEDURE bditransfer:sp_dskrga_arch_transfer()
        INTO vcodret4;
    END IF;
    
    -- // REPORTE IVR BANCOPPEL 
    LET vaniomes = TO_CHAR(vfecha_hoy, '%m%d%y');	
        
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
               'UNLOAD TO /resplogifx/conciliachq/ivr_bitacora_'||vfecha1||'.txt '||
			   'SELECT TO_CHAR(fecha_oper,'''||'%d/%m/%Y %H:%M'||'''), secuencia, operacion, SUBSTR(num_tarjeta, 1, 4) || '''|| 'XXXXXXXX' ||''' || SUBSTR(num_tarjeta, 13, 16), numcte, telefono, opcion_acceso, sucursal '||
			   'from bdinteg:si_bitacora_ivr '||
               'where fecha_oper::date = '''||vfecha_ant||''' '||                      
               'order by fecha_oper ASC;" > /resplogifx/conciliachq/rptivrdiario.sql';
    SYSTEM vsql;	
    LET vsql = '';
        
    LET vstmt = '';
	LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/rptivrdiario.sql"; 
    SYSTEM vstmt;
    LET vstmt = '';
	LET vaniomes = '';
    
    -- // ####################################################################   REPORTES MENSUALES   ####################################################################
    -- // 50 CUENTAS CON MAYOR SALDO DE CHEQUES E INVERSIONES  
    IF vpri_hab_mes = vfecha_hoy THEN    
        -- // CHEQUES
        ---SELECT {+ INDEX(sc_maechq mae1)} num_cte, cuenta, sdo_dia_ant as saldo
        SELECT {+INDEX(sc_maechq idx_sc_maechq2)}
               num_cte, cuenta, sdo_dia_ant as saldo
          FROM sc_maechq
         WHERE status_cta != '2'
        INTO TEMP ctaschq1 WITH NO LOG;
		
        CREATE INDEX idxctaschq1 ON ctaschq1(num_cte) online;
        UPDATE STATISTICS MEDIUM FOR TABLE ctaschq1;
         
        SELECT FIRST 50 num_cte, cuenta, saldo
          FROM ctaschq1
         ORDER BY saldo DESC
          INTO TEMP ctaschq2 WITH NO LOG;
		
        CREATE INDEX idxctaschq2 ON ctaschq2(num_cte) online;
	    UPDATE STATISTICS MEDIUM FOR TABLE ctaschq2;
          
        IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'ctassdosmaychq') THEN
            DROP TABLE bdicheq:ctassdosmaychq;        
        END IF;
        
        CREATE RAW TABLE ctassdosmaychq
          (
            nombre  char(104),
            numcte  char(20),
            cuenta  char(20),
            saldo   decimal(16,2),
            prov    decimal(16,2),
            sdoprov decimal (16,2)
          )
        EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
        
        INSERT INTO ctassdosmaychq
        SELECT TRIM(c.nombre1)||" "||TRIM(c.nombre2)||" "||TRIM(c.apell_paterno)||" "||TRIM(c.apell_materno) AS nombre,
               a.num_cte, a.cuenta, a.saldo, NVL(b.monto_tot, 0.00) AS provision, a.saldo + NVL(b.monto_tot, 0.00) AS sdo_prov
          FROM ctaschq2 a
          LEFT OUTER JOIN sc_movhis b ON ( b.empresa = '001' AND
                                           b.cuenta = a.cuenta AND 
                                           b.fech_alt = vfecha_ant AND 
                                           b.cancelad != 'S' AND 
                                           b.transacc = '3381' )
         INNER JOIN bdinteg:si_cliente c ON (c.numcte = a.num_cte);
        CREATE INDEX idxctassdosmaychq ON ctassdosmaychq(saldo) online;
	    UPDATE STATISTICS MEDIUM FOR TABLE ctassdosmaychq;
         
        LET vsql = '';
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
                   'UNLOAD TO /resplogifx/conciliachq/ctassdosmayores_'||vfecha2||'.txt '||
                   'SELECT * '||
                   'FROM ctassdosmaychq '||
                   'ORDER BY saldo DESC;" > /resplogifx/conciliachq/ctasmaychq.sql';
        SYSTEM vsql;
        LET vsql = '';
        
        LET vstmt = '';
        LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctasmaychq.sql"; 
        SYSTEM vstmt;
        LET vstmt = '';
        
        -- // LLENA TABLAS PARA CONSULTAS SOC - TASF
        INSERT INTO sc_ctassdosmayores
        SELECT {+INDEX(ctassdosmaychq idxctassdosmaychq)}
               b.fecha_ant, a.numcte, a.nombre, a.cuenta, a.saldo, a.prov, a.sdoprov
          FROM ctassdosmaychq a
          LEFT OUTER JOIN sc_fechas b ON (b.empresa = '001');
        
        -- // INVERSIONES 
        SELECT num_cte, fecha_alta, fecha_venc, cuenta, capital
          FROM bdinvers:sv_maeinv
         WHERE status_cta = '1'
        INTO TEMP ctaspag1 WITH NO LOG;
        CREATE INDEX idxctaspag1 ON ctaspag1(num_cte) online;
	   UPDATE STATISTICS MEDIUM FOR TABLE ctaspag1;
        
        SELECT FIRST 50 num_cte, fecha_alta, fecha_venc, cuenta, capital
          FROM ctaspag1
         ORDER BY capital DESC
          INTO TEMP ctaspag2 WITH NO LOG;
        CREATE INDEX idxctaspag2 ON ctaspag2(num_cte) online;
	   UPDATE STATISTICS MEDIUM FOR TABLE ctaspag2;
          
        IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'ctassdosmaypag') THEN
            DROP TABLE bdicheq:ctassdosmaypag;        
        END IF;
        
        CREATE RAW TABLE ctassdosmaypag
          (
            nombre     char(104),
            numcte     char(20),
            fecha_alta date,
            fecha_venc date,
            cuenta     char(20),
            saldo      decimal(18,2),
            prov       decimal(14,2),
            sdoprov    decimal (18,2)
          )
        EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
        
        INSERT INTO ctassdosmaypag
        SELECT FIRST 50 TRIM(c.nombre1)||" "||TRIM(c.nombre2)||" "||TRIM(c.apell_paterno)||" "||TRIM(c.apell_materno) AS nombre,
               a.num_cte, a.fecha_alta, a.fecha_venc, a.cuenta, a.capital, NVL(b.monto_tot, 0.00) AS provision, a.capital + NVL(b.monto_tot, 0.00) AS sdo_prov
          FROM ctaspag2 a
          LEFT OUTER JOIN bdinvers:sv_movhis b ON ( b.empresa = '001' AND 
                                                    b.cuenta = a.cuenta AND 
                                                    b.fech_alt = vfecha_ant AND 
                                                    b.cancelad != 'S' AND 
                                                    b.transacc = '0510' )
         INNER JOIN bdinteg:si_cliente c ON ( c.numcte = a.num_cte );
        CREATE INDEX idxctassdosmaypag ON ctassdosmaypag(saldo) online;
        UPDATE STATISTICS MEDIUM FOR TABLE ctassdosmaypag;
        
        LET vsql = '';
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
                   'UNLOAD TO /resplogifx/conciliachq/pagaresdosmayores_'||vfecha2||'.txt '||
                   'SELECT * '||
                   'FROM ctassdosmaypag '||
                   'ORDER BY saldo DESC;" > /resplogifx/conciliachq/ctasmayinv.sql';
        SYSTEM vsql;
        LET vsql = '';
        
        LET vstmt = '';
        LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctasmayinv.sql"; 
        SYSTEM vstmt;
        LET vstmt = '';
        
        -- // LLENA TABLAS PARA CONSULTAS SOC - TASF
        INSERT INTO bdinvers:sv_pagaresdosmayores
        SELECT {+INDEX(ctassdosmaypag idxctassdosmaypag)}
               b.fecha_ant, a.numcte, a.nombre, a.fecha_alta, a.fecha_venc, a.cuenta, a.saldo, a.prov, a.sdoprov
          FROM ctassdosmaypag a
          LEFT OUTER JOIN sc_fechas b ON (b.empresa = '001');
          
        -- // R2124 CONTABILIDAD CUENTAS INACTIVAS ART 61 LIC
        LET vaniomes = TO_CHAR(vfecha_ant, '%Y%m');
        
        LET vsql = '';
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/ctasconcentradas_al_'||vfecha2||'.txt '||
                   'SELECT mae.sucursal, mae.producto, '||
                   'CASE WHEN ( SELECT COUNT(*) FROM bdinteg:si_ctepf WHERE numcte = mae.num_cte ) > 0 THEN '||
                   '( SELECT sexo FROM bdinteg:si_ctepf WHERE numcte = mae.num_cte ) ELSE ''E'' END, '||
                   'COUNT(*), SUM(con.sdo_concentrado) '||
                   'FROM sc_cuentas_concentradas con, sc_maechq mae '||
                   'WHERE mae.cuenta = con.cuenta AND ( ( mae.status_cta = ''6'' AND con.fecha_concentra <= '''||vfecha_ant||''' ) OR '||
                   '( mae.status_cta = ''7'' AND con.fecha_trasp_benefic > '''||vfecha_ant||''' ) OR '||
                   '( mae.status_cta = ''8'' AND con.fecha_concentra <= '''||vfecha_ant||''' AND con.fecha_pago_concentra > '''||vfecha_ant||''' ) ) '||
                   'GROUP BY 1, 2, 3 ORDER BY 1, 2, 3;" > /resplogifx/conciliachq/r2124.sql';
        SYSTEM vsql;
        
        LET vstmt = '';
        LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/r2124.sql"; 
        SYSTEM vstmt;
        
        LET vsql = '';
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/ctasconcentradas_durante_'||vaniomes||'.txt '||
                   'SELECT mae.sucursal, mae.producto, '||
                   'CASE WHEN ( SELECT COUNT(*) FROM bdinteg:si_ctepf WHERE numcte = mae.num_cte ) > 0 THEN '||
                   '( SELECT sexo FROM bdinteg:si_ctepf WHERE numcte = mae.num_cte ) ELSE ''E'' END, '||
                   'COUNT(*), SUM(con.sdo_concentrado) '||
                   'FROM sc_cuentas_concentradas con, sc_maechq mae '||
                   'WHERE mae.cuenta = con.cuenta AND con.fecha_concentra BETWEEN '''||vpri_mes_ant||''' and '''||vult_mes_ant||''' '||
                   'GROUP BY 1, 2, 3 ORDER BY 1, 2, 3;" > /resplogifx/conciliachq/r2124.sql';
        SYSTEM vsql;
        
        LET vstmt = '';
        LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/r2124.sql"; 
        SYSTEM vstmt;
        
        LET vsql = '';
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/ctasdesconcentradas_durante_'||vaniomes||'.txt '||
                   'SELECT mae.sucursal, mae.producto, '||
                   'CASE WHEN ( SELECT COUNT(*) FROM bdinteg:si_ctepf WHERE numcte = mae.num_cte ) > 0 THEN '||
                   '( SELECT sexo FROM bdinteg:si_ctepf WHERE numcte = mae.num_cte ) ELSE ''E'' END, '||
                   'COUNT(*), SUM(con.sdo_concentrado) '||
                   'FROM sc_cuentas_concentradas con, sc_maechq mae '||
                   'WHERE mae.cuenta = con.cuenta AND con.fecha_pago_concentra BETWEEN '''||vpri_mes_ant||''' and '''||vult_mes_ant||''' '||
                   'GROUP BY 1, 2, 3 ORDER BY 1, 2, 3;" > /resplogifx/conciliachq/r2124.sql';
        SYSTEM vsql;
        
        LET vstmt = '';
        LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/r2124.sql"; 
        SYSTEM vstmt;
        
        LET vsql = '';
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/ctastraspbeneficencia_'||vaniomes||'.txt '||
                   'SELECT mae.sucursal, mae.producto, '||
                   'CASE WHEN ( SELECT COUNT(*) FROM bdinteg:si_ctepf WHERE numcte = mae.num_cte ) > 0 THEN '||
                   '( SELECT sexo FROM bdinteg:si_ctepf WHERE numcte = mae.num_cte ) ELSE ''E'' END, '||
                   'COUNT(*), SUM(con.sdo_concentrado) '||
                   'FROM sc_cuentas_concentradas con, sc_maechq mae '||
                   'WHERE mae.cuenta = con.cuenta AND con.fecha_trasp_benefic BETWEEN '''||vpri_mes_ant||''' and '''||vult_mes_ant||''' '||
                   'AND mae.status_cta = ''7'' GROUP BY 1, 2, 3 ORDER BY 1, 2, 3;" > /resplogifx/conciliachq/r2124.sql';
        SYSTEM vsql;
        
        LET vstmt = '';
        LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/r2124.sql"; 
        SYSTEM vstmt;         
          
        -- // GENERA REPORTE - RQM 10 335  
        select {+INDEX(sc_maechq idxscmaechqpba)}
               num_cte, producto
          from sc_maechq
         where producto in("2000", "1100")
           and status_cta not in("2", "6", "7", "8")
        into temp tmp_ctas_esp with no log;
        create index idxtmp_maechq1 on tmp_ctas_esp(num_cte, producto) online;
        update statistics medium for table tmp_ctas_esp;
        
        select num_cte, count(*) cuantos, CASE WHEN producto = "2000" THEN "EFECTIVA" ELSE "INVERSION" END producto
          from tmp_ctas_esp
         group by num_cte, producto
        into temp cheques_10335 with no log;
        create index idx_cheques_10335 on cheques_10335(num_cte) online;
        update statistics medium for table cheques_10335;
          
        select num_cte, count(*) cuantos, "PAGARE" producto
          from bdinvers:sv_maeinv
         where status_cta = "1"
         group by 1
        into temp pagares_10335 with no log;
        create index idx_pagare_10335 on pagares_10335(num_cte) online;
        update statistics medium for table pagares_10335;
        
        select {+index(bdicred:sd_maecredcrd idx_sd_maecredcrd2)}
               numcte, count(*) cuantos, "PRESTAMO PERSONAL" producto
          from bdicred:sd_maecredcrd
         where fecha_apertura = fecha_apertura
           and num_credito = num_credito
           and num_producto = "6300"
           and status_cred in("AA", "BA", "BT", "E1","E2","E3")
         group by 1
        into temp prestamos_10335 with no log;
        create index idx_prestamos_10335 on prestamos_10335(numcte) online;
        update statistics medium for table prestamos_10335;
          
        select {+INDEX(bdicred:sd_maecred idx_sd_maecred4)} 
               numcte, count(*) cuantos, "TARJETA DE CREDITO" producto
          from bdicred:sd_maecred
         where num_producto = "6001"
           and status_cred in("AA", "BA", "BT", "E1","E2","E3")
         group by 1
        into temp tarjetascrd_10335 with no log;
        create index idx_tarjetacrd_10335 on tarjetascrd_10335(numcte) online;
        update statistics medium for table tarjetascrd_10335;
        
        IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'cuentas_10335') THEN
            DROP TABLE bdicheq:cuentas_10335;        
        END IF; 
        
        create raw table cuentas_10335
          (
            numcte          char(20),
            nombre1         char(52),
            nombre2         char(52),
            apell_paterno   char(52),
            apell_materno   char(52),
            correo_elec     char(50),
            prod1           char(20),
            cuantos1        integer,
            prod2           char(20),
            cuantos2        integer,
            prod3           char(20),
            cuantos3        integer,
            prod4           char(20),
            cuantos4        integer,
            prod5           char(20),
            cuantos5        integer
          )
        extent size 1000000 next size 1000000 lock mode row;
        
        insert into cuentas_10335
        select a.numcte, a.nombre1, a.nombre2, a.apell_paterno, a.apell_materno, g.correo_elec,
               b.producto, b.cuantos,
               c.producto, c.cuantos,
               d.producto, d.cuantos,
               e.producto, e.cuantos,
               f.producto, f.cuantos
          from bdinteg:si_cliente a,
         outer (cheques_10335 b),
         outer (cheques_10335 c),
         outer (pagares_10335 d),
         outer (prestamos_10335 e),
         outer (tarjetascrd_10335 f),
               bdinteg:si_correos g,
			   bdinteg:si_ctepf h
		where a.numcte = b.num_cte
           and a.numcte = c.num_cte
           and a.numcte = d.num_cte
           and a.numcte = e.numcte
           and a.numcte = f.numcte
           and a.numcte = g.numcte
		   and a.numcte = h.numcte
           and g.status_correo = "A"
           and b.producto = "EFECTIVA"
           and c.producto = "INVERSION"
		   and h.string1 = "S";
        
        create index idx_cuentas_10335 on cuentas_10335(numcte) online;
	    update statistics medium for table cuentas_10335;
        
        LET vaniomes = TO_CHAR(vfecha_hoy, '%Y%m');
        
        LET vsql = '';
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
                   'UNLOAD TO /resplogifx/conciliachq/rqm10355_'||vaniomes||'.txt '||
                   'SELECT a.numcte, a.nombre1, a.nombre2, a.apell_paterno, a.apell_materno, a.correo_elec, z.nombre, y.nombre, x.cod_postal, '||
                   'a.prod1, a.cuantos1, a.prod2, a.cuantos2, a.prod3, a.cuantos3, a.prod4, a.cuantos4, a.prod5, a.cuantos5 '||
                   'FROM cuentas_10335 a, bdinteg:si_direcciones_actual x, bdinteg:si_ciudades z, bdinteg:si_estados y '||
                   'WHERE (a.cuantos1 > 0 OR a.cuantos2 > 0 OR a.cuantos3 > 0 OR a.cuantos4 > 0 OR a.cuantos5 > 0) '||
                   'AND a.numcte = x.numcte AND x.ciudad = z.ciudad AND x.estado = z.estado AND x.estado = y.estado AND x.tipo_dir = 1; " > /resplogifx/conciliachq/10335.sql';
        SYSTEM vsql;
        LET vsql = '';
        
        LET vstmt = '';
        LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/10335.sql"; 
        SYSTEM vstmt;
        LET vstmt = '';
    END IF;
    
    -- // CUENTAS COPPEL CADA DIA 2 
	IF LPAD(DAY(vfecha_hoy),2,'0') = '02' THEN
        LET vaniomespas = TO_CHAR(vult_mes_ant, '%Y%m');	
        
        LET vsql = '';
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
                   'UNLOAD TO /resplogifx/conciliachq/resumen_cta_coppel_'||vaniomespas||'.unl '||
                   'select CASE WHEN(referencia is not null and referencia <> ''" "'') THEN substr(referencia, 1, 4) ELSE sucursal END  AS sucursal, '||
                   'fech_alt, count(*), transacc, sum(monto_tot) from sc_movhis_old '||
                   'where empresa = ''"001"'' '||
                   'and cuenta in(''"16000000012"'',''"16000000250"'') '||
                   'and fech_alt >= '''||vpri_mes_ant||''' '||
                   'and fech_alt <= '''||vult_mes_ant||''' '||
                   'and fech_alt >= '''||dFechaIniMovHisOld||''' '||
                   'and fech_alt < '''||dFechaIniMovHis||''' '||
                   'and cancelad <> ''"S"'' '||
                   'and transacc = ''"0202"'' '||
                   'group by 1, 2, 4 '||
                   'UNION ALL '||
                   'select CASE WHEN(referencia is not null and referencia <> ''" "'') THEN substr(referencia, 1, 4) ELSE sucursal END  AS sucursal, '||
                   'fech_alt, count(*), transacc, sum(monto_tot) from sc_movhis '||
                   'where empresa = ''"001"'' '||
                   'and cuenta in(''"16000000012"'',''"16000000250"'') '||
                   'and fech_alt >= '''||vpri_mes_ant||''' '||
                   'and fech_alt <= '''||vult_mes_ant||''' '||
                   'and fech_alt >= '''||dFechaIniMovHis||''' '||
                   'and cancelad <> ''"S"'' '||
                   'and transacc = ''"0202"'' '||
                   'group by 1, 2, 4 '||
                   'order by 1, 2 ;" > /resplogifx/conciliachq/dep_cta_coppel.sql';
        SYSTEM vsql;
        LET vsql = '';
		
        LET vstmt = '';
        LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/dep_cta_coppel.sql"; 
        SYSTEM vstmt;
        LET vstmt = '';
        	
        -- SE AGREGA REPORTE MENSUAL DE CUENTAS CANCELADAS POR PRODUCTO.
		LET vaniomes = TO_CHAR(vfecha_hoy, '%Y%m');
		
		LET vsql = '';
		LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
				   'UNLOAD TO /resplogifx/conciliachq/rptctascancel'||vaniomes||'.txt '||
				   'select producto, count(*) from bdicheq:sc_maechq '||
				   'where fec_cancelac >= '''||vpri_mes_ant||''' and fec_cancelac <='''||vult_mes_ant||''' '||
				   'group by 1 order by 1;" > /resplogifx/conciliachq/rptctascancel.sql';
		
		SYSTEM vsql;
        LET vsql = '';
        
        LET vstmt = '';
		LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/rptctascancel.sql"; 
        SYSTEM vstmt;
        LET vstmt = '';
		LET vaniomes = '';
	END IF;
	
	-- // CUENTAS COPPEL "16000000012" Y "16000000071" CADA DIA 3 
	IF LPAD(DAY(vfecha_hoy),2,'0') = '03' THEN
        -- // CUENTA COPPEL "16000000012"	  
        LET vmesaniopas = TO_CHAR(vult_mes_ant, '%m%Y');	

        IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'tmp_transaccion1') THEN
            DROP TABLE bdicheq:tmp_transaccion1;        
        END IF;	

        CREATE RAW TABLE tmp_transaccion1
          (
            transacc char(4),
            monto    money(14,2)
          )
        EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;

        INSERT INTO tmp_transaccion1
        select transacc, sum(monto_tot) monto 
          from sc_movhis
         where empresa = "001"
           and cuenta = "16000000012"
           and fech_alt between vpri_mes_ant and vult_mes_ant
           and fech_alt >= dFechaIniMovHis
           and cancelad <> "S"
         group by 1;

        INSERT INTO tmp_transaccion1
        select transacc, sum(monto_tot) monto 
          from sc_movhis_old
         where empresa = "001"
           and cuenta = "16000000012"
           and fech_alt between vpri_mes_ant and vult_mes_ant
           and fech_alt >= dFechaIniMovHisOld
           and fech_alt < dFechaIniMovHis
           and cancelad <> "S"
         group by 1;

        LET vsql = '';
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
                   'UNLOAD TO /resplogifx/conciliachq/movtos_coppel_12_'||vmesaniopas||'.unl '||
                   'select transacc, descripcion, naturaleza, sum(monto) '||
                   'from tmp_transaccion1, bdinteg:si_transacc '||
                   'where transacc = numero '||
                   'group by 1, 2, 3 '||
                   'order by 1 '||
                   ';" > /resplogifx/conciliachq/movs_cta_coppel_12.sql';
        SYSTEM vsql;
        LET vsql = '';

        LET vstmt = '';
        LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/movs_cta_coppel_12.sql"; 
        SYSTEM vstmt;
        LET vstmt = '';

        -- // CUENTA COPPEL "16000000071"	  
        IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'tmp_transaccion') THEN
            DROP TABLE bdicheq:tmp_transaccion;        
        END IF;	

        CREATE RAW TABLE tmp_transaccion
          (
            transacc char(4),
            monto    money(14,2)
          )
        EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;

        INSERT INTO tmp_transaccion
        select transacc, sum(monto_tot) monto 
          from sc_movhis
         where empresa = "001"
           and cuenta = "16000000071"
           and fech_alt between vpri_mes_ant and vult_mes_ant
           and fech_alt >= dFechaIniMovHis
           and cancelad <> "S"
         group by 1;

        INSERT INTO tmp_transaccion
        select transacc, sum(monto_tot) monto 
         from sc_movhis_old
         where empresa = "001"
           and cuenta = "16000000071"
           and fech_alt between vpri_mes_ant and vult_mes_ant
           and fech_alt >= dFechaIniMovHisOld
           and fech_alt < dFechaIniMovHis
           and cancelad <> "S"
         group by 1;

        LET vsql = '';
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
                   'UNLOAD TO /resplogifx/conciliachq/movtos_coppel_71_'||vmesaniopas||'.unl '||
                   'select transacc, descripcion, naturaleza, sum(monto) '||
                   'from tmp_transaccion, bdinteg:si_transacc '||
                   'where transacc = numero '||
                   'group by 1, 2, 3 '||
                   'order by 1 '||
                   ';" > /resplogifx/conciliachq/movs_cta_coppel_71.sql';
        SYSTEM vsql;
        LET vsql = '';

        LET vstmt = '';
        LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/movs_cta_coppel_71.sql"; 
        SYSTEM vstmt;
        LET vstmt = '';	
        
        -- // DESCARGA CUENTAS INACTIVAS MAYORES A 5,000.00
        CALL sp_reportactasinactivas()
        RETURNING vRepCtasInac;
		
        -- // RQM 10 669 Reportes de portabilidad en sucursal
		EXECUTE PROCEDURE "informix".sp_rptsporta(pempresa)
		INTO vcodret9;	
		
		-- // RQM 10 1164
		SELECT valor
		  INTO dFechaIniMovHis
		  FROM bdicheq:"informix".sc_param
		 WHERE empresa = pEmpresa
		   AND codparam = 'fechcon_movhis';
			
		SELECT valor
		  INTO dFechaIniMovHisOld
		  FROM bdicheq:"informix".sc_param
		 WHERE empresa = pEmpresa
		   AND codparam = 'FechIniCon_movhis_ol';
		
		LET vsql = '';
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
                   'UNLOAD TO /resplogifx/conciliachq/movs_corresponsales_0402_'||vmesaniopas||'.txt '||
                   'select substr(folio_suc,1,4), referencia, count(*) '||
                   'from sc_movhis '||
                   'where transacc = ''0402'' '||
				   'and cancelad <> ''S'' '||
				   'and fech_alt >= '''||dFechaIniMovHis||''' '||
				   'and fech_alt between '''||vpri_mes_ant||''' and '''||vult_mes_ant||''' '||
                   'group by 1, 2 '||
				   'union '||
				   'select substr(folio_suc,1,4), referencia, count(*) '||
                   'from sc_movhis_old '||
                   'where transacc = ''0402'' '||
				   'and cancelad <> ''S'' '||
				   'and fech_alt >= '''||dFechaIniMovHisOld||''' '||
				   'and fech_alt <  '''||dFechaIniMovHis||''' '||
				   'and fech_alt between '''||vpri_mes_ant||''' and '''||vult_mes_ant||''' '||
                   'group by 1, 2;" > /resplogifx/conciliachq/movs_0402.sql';
        SYSTEM vsql;
        LET vsql = '';

        LET vstmt = '';
        LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/movs_0402.sql"; 
        SYSTEM vstmt;
        LET vstmt = '';	
	END IF; 
    
    -- // REPORTE MENSUAL DE PAGO DE INTS Y COBRO DE ISR (DIA 04 DE CADA MES)
    IF LPAD(DAY(vfecha_hoy),2,'0') = '04' THEN
		/* ###########################################################################################################################################
        -- // MOVIMIENTOS DE PAGO DE INTERESES DEL SISTEMA DE CHEQUES
        IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'movs_3276') THEN
            DROP TABLE movs_3276;        
        END IF;
        
        CREATE TABLE movs_3276( cuenta char(20), monto_tot decimal(18,2) ) 
        EXTENT SIZE 1000 NEXT SIZE 100 LOCK MODE ROW;
        
        insert into movs_3276
        select cuenta, monto_tot
          from sc_movhis_old 
         where fech_alt between vpri_mes_ant and vult_mes_ant
           and fech_alt >= dFechaIniMovHisOld
           and fech_alt < dFechaIniMovHis
           and transacc = '3276'
           and cancelad <> 'S';
         
        insert into movs_3276
        select cuenta, monto_tot
          from sc_movhis     
         where fech_alt between vpri_mes_ant and vult_mes_ant
           and fech_alt >= dFechaIniMovHis
           and transacc = '3276'
           and cancelad <> 'S';
           
        create index idxtmp_mov3276 on movs_3276(cuenta) online;
        update statistics high for table movs_3276;
        
        
        IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'movs_int') THEN
            DROP TABLE movs_int;        
        END IF;
        
        CREATE TABLE movs_int( cuenta char(20), monto_int decimal(18,2) )
        EXTENT SIZE 1000 NEXT SIZE 100 LOCK MODE ROW;
         
        insert into movs_int
        select cuenta, sum(monto_tot) monto_int
          from movs_3276
         group by 1;
        
        create index idxtmp_movint on movs_int(cuenta) online;
        update statistics high for table movs_int;
        ########################################################################################################################################### */
		
		--- RSV
		EXECUTE PROCEDURE "informix".sp_cons_info_cobro_isr('001')
		INTO vcodret6;
		
        -- // MOVIMIENTOS DE COBRO DE ISR DEL SISTEMA DE CHEQUES
        IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'movs_3277') THEN
            DROP TABLE movs_3277;        
        END IF;
        
        CREATE TABLE movs_3277( cuenta char(20), monto_tot decimal(18,2) )
        EXTENT SIZE 1000 NEXT SIZE 100 LOCK MODE ROW;
        
        insert into movs_3277   
        select cuenta, monto_tot
          from sc_movhis_old
         where fech_alt between vpri_mes_ant and vult_mes_ant
           and fech_alt >= dFechaIniMovHisOld
           and fech_alt < dFechaIniMovHis
           and transacc = '3277'
           and cancelad <> 'S';

        insert into movs_3277   
        select cuenta, monto_tot
          from sc_movhis
         where fech_alt between vpri_mes_ant and vult_mes_ant
           and fech_alt >= dFechaIniMovHis
           and transacc = '3277'
           and cancelad <> 'S';
           
        create index idxtmp_mov3277 on movs_3277(cuenta) online;
        update statistics high for table movs_3277;
        
        IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'movs_isr') THEN
            DROP TABLE movs_isr;        
        END IF;
        
        CREATE TABLE movs_isr( cuenta char(20), monto_isr decimal(18,2) )
        EXTENT SIZE 1000 NEXT SIZE 100 LOCK MODE ROW;
        
        insert into movs_isr
        select cuenta, sum(monto_tot) monto_isr
          from movs_3277
         group by 1;

        create index idxtmp_movisr on movs_isr(cuenta) online;
        update statistics high for table movs_isr;
        
        -- // DESCARGA INFORMACION DEL SISTEMA DE CHEQUES
        LET vaniomes = TO_CHAR(vult_mes_ant, '%Y%m');
        
        LET vsql = '';
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/intsisrs_cheques_'||vaniomes||'.txt '||
                   'SELECT mae.num_cte, mae.cuenta, mae.producto, mae.fechaini, mae.fechafin, '||
                   'mae.sdo_actual, mae.acum_sdo_pos, mae.dia_sdo_pos, mae.tasabruta, '||
                   'nvl(ints.monto_int, 0.00), nvl(isrs.monto_isr, 0.00) '||
                   'FROM sc_maehis mae '||
                   'LEFT OUTER JOIN movs_int ints on (ints.cuenta = mae.cuenta) '||
                   'LEFT OUTER JOIN movs_isr isrs on (isrs.cuenta = mae.cuenta) '||
                   'WHERE mae.fechafin BETWEEN '''||vpri_mes_ant||''' AND '''||vult_mes_ant||''' '||
                   'AND ( mae.totintpag > 0.00 or mae.totisrcobrado > 0.00 ); " > /resplogifx/conciliachq/intsisrchq.sql';
        SYSTEM vsql;
        
        LET vstmt = '';
        LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/intsisrchq.sql"; 
        SYSTEM vstmt;
        
        LET vsql = '';
        LET vsql = '/usr/bin/split -1000000 /resplogifx/conciliachq/intsisrs_cheques_'||vaniomes||'.txt /resplogifx/conciliachq/intsisrs_cheques_'||vaniomes||'.txt.';
        SYSTEM vsql;
        
        -- // PAGARES VENCIDOS DURANTE EL MES DEL SISTEMA DE INVERSIONES
        IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'pags_venc') THEN
            DROP TABLE pags_venc;        
        END IF;
        
        CREATE TABLE pags_venc( cuenta char(20), secuencia smallint, num_cte char(20), capital decimal(14,2), fecha_alta date, fecha_venc date, plazo smallint, tasa decimal(9,6) ) 
        EXTENT SIZE 1000 NEXT SIZE 100 LOCK MODE ROW;
        
        INSERT INTO pags_venc
        select cuenta, secuencia, num_cte, capital, fecha_alta, fecha_venc, plazo, tasa
          from bdinvers:sv_maeinv
         where empresa = '001'
           and cuenta > '30000000000'
           and fecha_venc between vpri_mes_ant and vult_mes_ant;    
           
        create index idxtmp_pagsvenc on pags_venc(cuenta, secuencia) online;
        update statistics high for table pags_venc;
           
        -- // MOVIMIENTOS DE INTERESES DEL SISTEMA DE INVERSIONES
        IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'movs_ints') THEN
            DROP TABLE movs_ints;        
        END IF;
        
        CREATE TABLE movs_ints( cuenta char(20), secuencia smallint, monto_tot decimal(14,2) ) 
        EXTENT SIZE 1000 NEXT SIZE 100 LOCK MODE ROW;
        
        INSERT INTO movs_ints
        select cuenta, secuencia, nvl(monto_tot, 0.00) 
          from bdinvers:sv_movhis
          where empresa = '001'
            and cuenta > '30000000000'
            and fech_alt between vpri_mes_ant and vult_mes_ant
            and cancelad <> 'S'
            and transacc = '0517';
            
        create index idxtmp_movsints on movs_ints(cuenta, secuencia) online;
        update statistics high for table movs_ints;
            
        -- // MOVIMIENTOS DE ISR DEL SISTEMA DE INVERSIONES
        IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'movs_isrs') THEN
            DROP TABLE movs_isrs;        
        END IF;
        
        CREATE TABLE movs_isrs( cuenta char(20), secuencia smallint, monto_tot decimal(14,2) ) 
        EXTENT SIZE 1000 NEXT SIZE 100 LOCK MODE ROW;
        
        INSERT INTO movs_isrs
        select cuenta, secuencia, nvl(monto_tot, 0.00) 
          from bdinvers:sv_movhis
          where empresa = '001'
            and cuenta > '30000000000'
            and fech_alt between vpri_mes_ant and vult_mes_ant
            and cancelad <> 'S'
            and transacc = '0516';
            
        create index idxtmp_movsisrs on movs_isrs(cuenta, secuencia) online;
        update statistics high for table movs_isrs;
            
        -- // DESCARGA INFORMACION DEL SISTEMA DE INVERSIONES
        LET vaniomes = TO_CHAR(vult_mes_ant, '%Y%m');
        
        LET vsql = '';
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/intsisrs_pagares_'||vaniomes||'.txt '||
                   'select veto.cuenta, veto.secuencia, veto.num_cte, veto.capital, veto.fecha_alta, '||
                   'veto.fecha_venc,  veto.plazo, veto.tasa, ints.monto_tot, isrs.monto_tot '||
                   'from pags_venc veto '||
                   'left outer join movs_ints ints on( ints.cuenta = veto.cuenta and ints.secuencia = veto.secuencia ) '||
                   'left outer join movs_isrs isrs on( isrs.cuenta = veto.cuenta and isrs.secuencia = veto.secuencia ) '||
                   'where isrs.monto_tot > 0.00;" > /resplogifx/conciliachq/intsisrpag.sql';
        SYSTEM vsql;
        
        LET vstmt = '';
        LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/intsisrpag.sql"; 
        SYSTEM vstmt;
    END IF;
    
    /* ##########################################################
    IF LPAD(DAY(vfecha_hoy),2,'0') = '05' THEN
        EXECUTE PROCEDURE sp_rptctasempresariales(pempresa)
        INTO vcodret11;
    END IF;
    ########################################################## */
    
    IF ( LPAD(DAY(vfecha_hoy),2,'0') = '05' AND LPAD(MONTH(vfecha_hoy),2,'0') IN('01','04','07','10') ) THEN
        -- // REPORTE TRIMESTRAL - CLIENTES LARGOS
        EXECUTE PROCEDURE "informix".sp_rptclienteslargos(pempresa)
        INTO vcodret10;
    END IF;
    -- // ####################################################################   REPORTES MENSUALES   ####################################################################
    
    --EXECUTE PROCEDURE sp_rptctasempresariales(pempresa)
    --INTO vcodret11;
    
    -- // GUARDA HORA FINAL DEL PROCESO
    IF vcodret1 = '000' THEN
        LET vsql = '';
        LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                   'SET ejecutivo = '''||vusuario||''','||
                   'status_proc   = '''||'F'||''','||
                   'codret        = '''||vcodret1||''','||
                   'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                   'WHERE empresa = '''||pempresa||''' '||
                   'AND proceso   = '''||vproceso||''' '||
                   'AND fecha     = '''||vfecha_hoy||''' '||
                   'AND sistema   = '''||vsistema||''';" > /tmp/horasinfoper.sql';
        SYSTEM vsql;
		LET vcodret1 = '000';
        LET vsql = '';
        
        LET vstmt = '';
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horasinfoper.sql';
        SYSTEM vstmt;
		LET vcodret1 = '000';
        LET vstmt = '';
    ELSE
        LET vsql = '';
        LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                   'SET ejecutivo = '''||vusuario||''','||
                   'status_proc   = '''||'C'||''','||
                   'codret        = '''||vcodret1||''','||
                   'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                   'WHERE empresa = '''||pempresa||''' '||
                   'AND proceso   = '''||vproceso||''' '||
                   'AND fecha     = '''||vfecha_hoy||''' '||
                   'AND sistema   = '''||vsistema||''';" > /tmp/horasinfoper.sql';
        SYSTEM vsql;
		LET vcodret1 = '000';
        LET vsql = '';
        
        LET vstmt = '';
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horasinfoper.sql';
        SYSTEM vstmt;
		LET vcodret1 = '000';
        LET vstmt = '';   
    END IF;
    
    END;

    RETURN vcodret1;

END PROCEDURE;