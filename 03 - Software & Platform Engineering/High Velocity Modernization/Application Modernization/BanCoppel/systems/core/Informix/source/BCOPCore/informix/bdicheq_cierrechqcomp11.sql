CREATE PROCEDURE "informix".cierrechqcomp11( pEmpresa CHAR(3) )
RETURNING CHAR(5);
       
    DEFINE GLOBAL vgtrans_pag_int   CHAR(4)     DEFAULT " ";
    DEFINE GLOBAL vgtransisr        CHAR(4)     DEFAULT " ";
    DEFINE GLOBAL vgnum_tarjeta     CHAR(20)    DEFAULT " ";
    
    DEFINE viSqlErr         INTEGER;
    DEFINE viIsamErr        INTEGER;
    DEFINE vcDescErr        CHAR(50);
    DEFINE vcCodRet         CHAR(5);
    DEFINE vcCodRet2        CHAR(5);
    DEFINE vcCodRet3        CHAR(50);
    DEFINE vcTrxAbierta     CHAR(1);
    DEFINE viContador1      INTEGER;
    DEFINE viContador2      INTEGER;
    DEFINE vdFechaHoy       DATE;
    DEFINE vdProxFecha      DATE;
    DEFINE vdUltHabMes      DATE;
    DEFINE vcCuenta         CHAR(20);
    DEFINE vcNumCte         CHAR(20);
    DEFINE vcProducto       CHAR(4);
    DEFINE vdFechaAlta      DATE;
    DEFINE vcPagoInteres    CHAR(1);
    DEFINE vcDia            CHAR(2);
    DEFINE vcCodRetFecha    CHAR(5);
    DEFINE vdFechaPago      DATE;
    DEFINE viNumDias        SMALLINT;
    DEFINE vcCodRetCrea     CHAR(5);
    
    DEFINE vcUsuario        CHAR(8);
    DEFINE vcSistema        CHAR(2);
    DEFINE vcProceso        CHAR(20);
    DEFINE viExiste         INTEGER;
    DEFINE viExisteFin      INTEGER;
    DEFINE vcExiste         CHAR(1);
    DEFINE viInicioCierre   SMALLINT;
    DEFINE vsql             CHAR(600);
    DEFINE vstmt            CHAR(250);
	DEFINE iNum_Cuentas     BIGINT;
	DEFINE v_c_vcomienza    SMALLINT;
	DEFINE ven_transacc     SMALLINT;
	DEFINE v_c_vcontador    INTEGER;
    
    LET viSqlErr       = 0;
    LET viIsamErr      = 0;
    LET vcDescErr      = '';
    LET vcCodRet       = '000';
    LET vcCodRet2      = '';
    LET vcCodRet3      = '';
    LET vcTrxAbierta   = '0';
    LET viContador1    = 0;
    LET viContador2    = 0;
    LET vdFechaHoy     = '';
    LET vdProxFecha    = '';
    LET vdUltHabMes    = '';
    LET vcCuenta       = '';
    LET vcNumCte       = '';
    LET vcProducto     = '';
    LET vdFechaAlta    = '';
    LET vcPagoInteres  = '';
    LET vcDia          = '';
    LET vcCodRetFecha  = '';
    LET vdFechaPago    = '';
    LET viNumDias      = 0;
    LET vcCodRetCrea   = '';
    
    LET vcUsuario      = USER;
    LET vcSistema      = '01';
    LET vcProceso      = 'cierrechqcomp11';
    LET viExiste       = 0;
    LET viExisteFin    = 0;
    LET vcExiste       = '';
    LET viInicioCierre = 0;
    LET vsql           = '';
    LET vstmt          = '';
	LET v_c_vcomienza  = -1;
	LET ven_transacc   = 0;
	LET v_c_vcontador  = 0;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/altamasempnet/cierrechqcomp11.out";
    --- TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET viSqlErr, viIsamErr, vcDescErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/altamasempnet/cierrechqcomp11.err";
        TRACE ON;
        IF viSqlErr <> 0 THEN
            LET vcCodRet = viSqlErr;
            LET vcCodRet2 = viIsamErr;
            LET vcCodRet3 = vcDescErr;
            
            IF vcTrxAbierta = '1' THEN
                ROLLBACK WORK;
            END IF;
            
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vcUsuario||''','||
                       'status_proc   = '''||'C'||''','||
                       'codret        = '''||vcCodRet||''','||
                       'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pEmpresa||''' '||
                       'AND proceso   = '''||vcProceso||''' '||
                       'AND fecha     = '''||vdFechaHoy||''' '||
                       'AND sistema   = '''||vcSistema||''';" > /tmp/horacierre11.sql';
            SYSTEM vsql;
            
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre11.sql';
            SYSTEM vstmt;
            
            RETURN vcCodRet;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy, prox_fecha, ult_hab_mes
      INTO vdFechaHoy, vdProxFecha, vdUltHabMes
      FROM sc_fechas
     WHERE empresa = pEmpresa;
     
    SELECT valor
      INTO vgtrans_pag_int
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'tranpagint';
       
    SELECT valor
      INTO vgtransisr
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'tranisr';
       
    -- // ############################################################ //
    -- // # VALIDA QUE NO SE HAYA REALIZADO EL CIERRE DEL DIA ACTUAL # //
    -- // ############################################################ //
    SELECT count(*)
      INTO viExiste
      FROM bdinteg:sx_contproc
     WHERE empresa = pEmpresa
       AND proceso = vcProceso
       AND fecha   = vdFechaHoy
       AND sistema = vcSistema;

    IF viExiste = 0 THEN
        LET vsql = 'echo " INSERT INTO bdinteg:sx_contproc VALUES '||
                   '('''||pEmpresa||''', '''||vcProceso||''', '''||vdFechaHoy||''', '''||vcSistema||''', '''||'I'||''', '''||vcUsuario||''','||
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horacierre11.sql';
        SYSTEM vsql;
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre11.sql';
        SYSTEM vstmt;
    ELSE
        SELECT count(*)
          INTO viExisteFin
          FROM bdinteg:sx_contproc
         WHERE empresa = pEmpresa
           AND proceso = vcProceso
           AND fecha   = vdFechaHoy
           AND sistema = vcSistema
           AND status_proc = 'F';

        IF viExisteFin = 0 THEN
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vcUsuario||''','||
                       'status_proc   = '''||'I'||''','||
                       'codret        = '''||' '||''','||
                       'hora_ini      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pEmpresa||''' '||
                       'AND proceso   = '''||vcProceso||''' '||
                       'AND fecha     = '''||vdFechaHoy||''' '||
                       'AND sistema   = '''||vcSistema||''';" > /tmp/horacierre11.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre11.sql';
            SYSTEM vstmt;
        ELSE
            SELECT 1
              INTO vcExiste
              FROM sc_contproc
             WHERE empresa = pEmpresa
               AND proceso = 'cierrecomp11'
               AND fecha = vdFechaHoy;

            IF vcExiste = '1' THEN
                LET vcCodRet = '966';
                RETURN vcCodRet;
            END IF
        END IF
    END IF;
    
    -- // #################################################################### //
    -- // # VALIDA QUE EL CIERRE PRINCIPAL HAYA COMENZADO A PROCESAR CUENTAS # //
    -- // #################################################################### //
    WHILE viInicioCierre = 0 
        SELECT COUNT(*)
          INTO viInicioCierre
          FROM sc_contproc
         WHERE empresa = pEmpresa
           AND proceso = 'inicio_cierre'
           AND fecha = vdFechaHoy;
    END WHILE;
    
	LET iNum_Cuentas = 0;
	
	DROP TABLE IF EXISTS sc_uni_reg;
	
	--//Obtener el Universo
	CREATE TABLE sc_uni_reg
      (
        cuenta CHAR(20),
        num_cte CHAR(20),
        producto CHAR(4),
        fecha_alta DATE,
        pago_interes CHAR(1) 
      ) 
    IN datos00;
		
    FOREACH WITH HOLD
        SELECT mae.cuenta, mae.num_cte, mae.producto, noc.fecha_alta, pro.pago_interes
          INTO vcCuenta, vcNumCte, vcProducto, vdFechaAlta, vcPagoInteres
          FROM sc_maechq mae,
               sc_maenoc noc,
               sc_producto pro
         WHERE mae.status_cta IN('4','5')
           AND mae.fecha_proceso < vdFechaHoy
           AND noc.empresa = mae.empresa
           AND noc.cuenta = mae.cuenta
           AND pro.empresa = mae.empresa
           AND pro.producto = mae.producto
           AND pro.pago_interes != 'M'

        IF (v_c_vcomienza = -1) THEN
            LET v_c_vcomienza = 0;
            LET ven_transacc = 1;
            BEGIN WORK;
        END IF;
    
        INSERT INTO sc_uni_reg
        (cuenta,num_cte,producto,fecha_alta,pago_interes)
        values
        (vcCuenta, vcNumCte, vcProducto, vdFechaAlta, vcPagoInteres);
            
        -- // REALIZA COMMIT CADA 100000 REGISTROS 
        LET v_c_vcontador = v_c_vcontador + 1;
        
        IF (v_c_vcontador >= 100000) THEN
            LET v_c_vcontador = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
    END FOREACH;
    
    -- // SI LA TRANSACCION ESTA ABIERTA REALIZA EL COMMIT
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    UPDATE sc_contproc 
       SET fecha = vdFechaHoy
     WHERE proceso ='tblcomp11';
    
    -- // crear el index
    CREATE INDEX "informix".idx_sc_uni_reg ON sc_uni_reg(cuenta) ONLINE;
    
    LET vcCuenta = '';
    LET vcNumCte = '';
    LET vcProducto ='';
    LET vdFechaAlta = '';
    LET vcPagoInteres ='';
    
    FOREACH WITH HOLD
        SELECT FIRST 8000000 
               cuenta,num_cte,producto,fecha_alta,pago_interes
          INTO vcCuenta, vcNumCte, vcProducto, vdFechaAlta, vcPagoInteres
          FROM sc_uni_reg
         ORDER BY cuenta

        BEGIN WORK;
        LET vcTrxAbierta = '1';
           
        LET vcDia = DAY(vdFechaAlta);
        
        CALL calcula_fechapago(vdFechaHoy, 0, vcDia)
        RETURNING vcCodRetFecha, vdFechaPago, viNumDias;
        
        IF vcDia = 1 THEN
            CALL monthadd(vdFechaPago, 1)
            RETURNING vdFechaPago;
        ELIF vcDia = 2 AND vdFechaHoy = '12'||'31'||YEAR(vdFechaHoy) THEN
            CALL monthadd(vdFechaPago, 1)
            RETURNING vdFechaPago;
        ELSE
            LET vdFechaPago = vdFechaHoy + viNumDias;
        END IF;

        IF NOT(vcDia > DAY(vdUltHabMes) OR vcDia < 1) THEN
            LET vdFechaPago = vdFechaPago - 1;
        END IF
        
        IF ( ( vcPagoInteres = "M" AND vdFechaHoy = vdUltHabMes ) OR 
             ( ( vcPagoInteres = "V" AND vdFechaPago >= vdFechaHoy AND vdFechaPago < vdProxFecha ) AND ( vdFechaAlta <> vdFechaHoy ) ) ) THEN
            SELECT NVL(num_tarjeta, ' ')
              INTO vgnum_tarjeta
              FROM sc_tarjeta
             WHERE numcte = vcNumCte
               AND cuenta = vcCuenta
               AND secuencia = ( SELECT MAX(secuencia) FROM sc_tarjeta WHERE numcte = vcNumCte AND cuenta = vcCuenta );
           
            CALL crea_maehis( pEmpresa, vcCuenta, vdFechaPago, vdFechaAlta, 0.00, 0 )
            RETURNING vcCodRetCrea;
            
            IF vcCodRetCrea = '000' THEN
                LET viContador2 = viContador2 + 1;
            END IF;
        END IF;
        
        COMMIT WORK;
        LET vcTrxAbierta = '0';
        
        LET viContador1 = viContador1 + 1;
        
        LET vcCuenta      = '';
        LET vcNumCte      = '';
        LET vcProducto    = '';
        LET vdFechaAlta   = '';
        LET vcPagoInteres = '';
        LET vcDia         = '';
        LET vcCodRetFecha = '';
        LET vdFechaPago   = '';
        LET viNumDias     = 0;
        LET vgnum_tarjeta = '';
    END FOREACH;
    
    -- // ########################## //
    -- // # Registra fin de cierre # //
    -- // ########################## //
    LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
               'SET status_proc   = '''||'F'||''','||
               'codret        = '''||vcCodRet||''','||
               'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
               'WHERE empresa = '''||pEmpresa||''' '||
               'AND proceso   = '''||vcProceso||''' '||
               'AND fecha     = '''||vdFechaHoy||''' '||
               'AND sistema   = '''||vcSistema||''';" > /tmp/horacierre11.sql';
    SYSTEM vsql;
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre11.sql';
    SYSTEM vstmt;

    UPDATE sc_contproc
       SET fecha = vdFechaHoy
     WHERE empresa = pEmpresa
       AND proceso = 'cierrecomp11';
    
    RETURN vcCodRet;

    END;

END PROCEDURE;