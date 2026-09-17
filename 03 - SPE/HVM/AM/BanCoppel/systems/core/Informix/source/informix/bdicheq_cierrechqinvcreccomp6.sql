CREATE PROCEDURE "informix".cierrechqinvcreccomp6(pempresa CHAR(3)) 
RETURNING CHAR(5);
     
    DEFINE GLOBAL vgusuario             CHAR(8)     DEFAULT " ";
    DEFINE GLOBAL vgfecha_hoy           DATE        DEFAULT " ";
    DEFINE GLOBAL vgpri_dia_mes         DATE        DEFAULT " ";
    DEFINE GLOBAL vgpri_hab_mes         DATE        DEFAULT " ";
    DEFINE GLOBAL vgult_dia_mes         DATE        DEFAULT " ";
    DEFINE GLOBAL vgult_hab_mes         DATE        DEFAULT " ";
    DEFINE GLOBAL vgprox_fecha          DATE        DEFAULT " ";
    DEFINE GLOBAL vgtrans_pag_int       CHAR(4)     DEFAULT " ";
    DEFINE GLOBAL vgtransisr            CHAR(4)     DEFAULT " ";
    DEFINE GLOBAL vgtranprov            CHAR(4)     DEFAULT " ";
    DEFINE GLOBAL vgtranrevprov         CHAR(4)     DEFAULT " ";
    DEFINE GLOBAL vgtranabotrasp        CHAR(4)     DEFAULT " ";
    DEFINE GLOBAL vgtranrecrece         CHAR(4)     DEFAULT " ";
    DEFINE GLOBAL vgProdCreciente       CHAR(4)     DEFAULT " ";
    DEFINE GLOBAL vgstatus_cta          CHAR(1)     DEFAULT " ";
    DEFINE GLOBAL vgfecha_mod           DATE        DEFAULT " ";
    DEFINE GLOBAL vgfecha_alta          DATE        DEFAULT " ";
    DEFINE GLOBAL vginstrucc            CHAR(2)     DEFAULT " ";
    DEFINE GLOBAL vgcuentadep           CHAR(20)    DEFAULT " ";

    DEFINE vcodret                      CHAR(5);
    DEFINE vcodret2                     CHAR(5);
    DEFINE vcodret3                     CHAR(40);
    DEFINE vsqlerr                      INTEGER;
    DEFINE isam_err                     INTEGER;
    DEFINE error_info                   CHAR(40);
    DEFINE vfechahora                   CHAR(40);
    DEFINE vsql                         CHAR(600);
    DEFINE vstmt                        CHAR(250);
    DEFINE vsistema                     CHAR(2);
    DEFINE vproceso                     CHAR(20);
    DEFINE vstatuscierreinv             CHAR(1);
    DEFINE vstatuscobroreestruc         CHAR(1);
    DEFINE vProdChequeras               CHAR(4);
    DEFINE vexiste                      CHAR(1);
    DEFINE vexiste2                     INTEGER;
    DEFINE vexistefin                   INTEGER;
    DEFINE vdias                        INTEGER;
    DEFINE vregproc                     INTEGER;
    DEFINE vporcentajerror              INTEGER;
    DEFINE vfcuenta                     CHAR(20);
    DEFINE FechaProc                    DATE;
    DEFINE vProducto                    CHAR(4);
    DEFINE vSdoActual                   DECIMAL(14,2);
    DEFINE vSucursal                    CHAR(4);
    DEFINE vcontvalcie                  INTEGER;
    DEFINE vregistros                   INTEGER;
    DEFINE vcuenta                      CHAR(20);
    DEFINE vProdChequerasPM             CHAR(4);
    DEFINE vdia                         CHAR(2);
    DEFINE vfecha_pago                  DATE;
    DEFINE vnumdias                     SMALLINT;
    DEFINE vexiste_cta                  SMALLINT;
    DEFINE vhora            		    DATETIME HOUR TO FRACTION;
    DEFINE vfolio_suc       		    CHAR(16);
    DEFINE vint_acum                    MONEY(14,2);
    DEFINE vfecultdep                   DATE;
    DEFINE vdiasinact                   INTEGER;
    DEFINE vabierto                     CHAR(1);
    DEFINE vaniomes                     CHAR(6);
    DEFINE vexiste_proy                 SMALLINT;
    DEFINE vtotsuc                      INTEGER;
    DEFINE vcontproc                    INTEGER;
    DEFINE vtfechaxxx                   DATE;
    DEFINE vnum_cte                     CHAR(20);
    DEFINE vfecha_alta                  DATE;
    DEFINE vhoraw           		    CHAR(15);
    DEFINE vfecha_mod                   DATE;
    DEFINE vinicio_cierre               SMALLINT;
    DEFINE vProdPROAC                   CHAR(4);
    DEFINE vcuentaini                   CHAR(20);
    DEFINE vcuentafin                   CHAR(20);
    DEFINE vfecha_operacion             DATE;

    LET vgusuario       = USER;
    LET vgfecha_hoy     = ' ';
    LET vgpri_dia_mes   = ' ';
    LET vgpri_hab_mes   = ' ';
    LET vgult_dia_mes   = ' ';
    LET vgult_hab_mes   = ' ';
    LET vgprox_fecha    = ' ';
    LET vgtrans_pag_int = ' ';
    LET vgtransisr      = ' ';
    LET vgtranprov      = ' ';
    LET vgtranrevprov   = ' ';
    LET vgtranabotrasp  = ' ';
    LET vgtranrecrece   = ' ';
    LET vgProdCreciente = ' ';
    LET vgstatus_cta    = ' ';
    LET vgfecha_mod     = ' ';
    LET vgfecha_alta    = ' ';

    LET vcodret              = "000";
    LET vcodret2             = "000";
    LET vcodret3             = "000";
    LET vsqlerr              = 0;
    LET isam_err             = 0;
    LET error_info           = '';
    LET vfechahora           = " ";
    LET vsql                 = '';
    LET vstmt                = '';
    LET vsistema             = "01";
    LET vproceso             = "cierrechqinvcrecomp6";
    LET vstatuscierreinv     = '';
    LET vstatuscobroreestruc = '';
    LET vProdChequeras       = '';
    LET vexiste              = '';
    LET vexiste2             = 0;
    LET vexistefin           = 0;
    LEt vdias                = 0;
    LET vregproc             = 0;
    LET vporcentajerror      = 0;
    LET vfcuenta             = '';
    LET FechaProc            = '';
    LET vProducto            = '';
    LET vSdoActual           = 0.00;
    LET vSucursal            = '';
    LET vcontvalcie          = 0;
    LET vregistros           = 0;
    LET vcuenta              = '';
    LET vProdChequerasPM     = '';
    LET vdia                 = '';
    LET vfecha_pago          = '';
    LET vnumdias             = 0;
    LET vexiste_cta          = 0;
    LET vhora                = '';
    LET vfolio_suc           = '';
    LET vint_acum            = 0.00;
    LET vfecultdep           = '';
    LET vdiasinact           = 0;
    LET vabierto             = '0';
    LET vaniomes             = '';
    LET vexiste_proy         = 0;
    LET vtotsuc              = 0;
    LET vcontproc            = 0;
    LET vtfechaxxx           = '';
    LET vnum_cte             = '';
    LET vfecha_alta          = '';
    LET vhoraw               = '';
    LET vfecha_mod           = '';
    LET vinicio_cierre       = 0;
    LET vProdPROAC           = '';
    LET vcuentaini           = '';
    LET vcuentafin           = '';
    LET vfecha_operacion     = TODAY;

    BEGIN

    ON EXCEPTION SET vsqlerr, isam_err, error_info
        SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechqinvcreccomp6.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET vcodret2 = isam_err;
            LET vcodret3 = error_info;
            LET vfechahora = CURRENT;
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vgusuario||''','||
                       'status_proc   = '''||'C'||''','||
                       'codret        = '''||vcodret||''','||
                       'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vgfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horacierrecrec6.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierrecrec6.sql';
            SYSTEM vstmt;
            IF vabierto = '1' THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret;
        END IF;
    END EXCEPTION;

    ---	SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechqinvcreccomp6.out";
    ---	TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    --- SET PDQPRIORITY 10;
    
    -- // FECHAS DEL SISTEMA DE CAPTACION  
    SELECT fecha_hoy, pri_dia_mes, pri_hab_mes, ult_dia_mes, ult_hab_mes, prox_fecha
      INTO vgfecha_hoy, vgpri_dia_mes, vgpri_hab_mes, vgult_dia_mes, vgult_hab_mes, vgprox_fecha
      FROM sc_fechas
     WHERE empresa = pempresa;
    
    -- // TRANSACCION DE PAGO DE INTERESES  
    SELECT valor
      INTO vgtrans_pag_int
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranpagint";
    
    -- // TRANSACCION DE COBRO DE ISR 
    SELECT valor
      INTO vgtransisr
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranisr";
    
    -- // TRANSACCION DE PROVISION DE INTERESES  
    SELECT valor
      INTO vgtranprov
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranprov";
    
    -- // TRANSACCION DE DESPROVISION DE INTERESES  
    SELECT valor
      INTO vgtranrevprov
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranrevprov";
    
    -- // TRANSACCION DE ABONO PARA TRASPASO  
    SELECT valor
      INTO vgtranabotrasp
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranabotrasp";
    
    -- // TRANSACCION DE REINVERSION DE INVS CREC  
    SELECT valor
      INTO vgtranrecrece
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "trenocre";
    
    -- // Producto Inversion Creciente  
    SELECT valor
      INTO vgProdCreciente
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "PRODCREC";
    
    -- // Producto de Chequeras 
    SELECT valor
      INTO vProdChequeras
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "prodefechq";
       
    -- // Producto de Chequeras Empresarial  
    SELECT valor
      INTO vProdChequerasPM
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "prodefechqpm"; 
    
    -- // Producto Programa Ahorre su Cambio  
    SELECT valor
      INTO vProdPROAC
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "PROACPRODUCTO";   
    
    
    -- // VALIDA QUE NO SE HAYA REALIZADO EL CIERRE DEL DIA ACTUAL  
    SELECT count(*)
      INTO vexiste2
      FROM bdinteg:sx_contproc
     WHERE empresa = pempresa
       AND proceso = vproceso
       AND fecha   = vgfecha_hoy
       AND sistema = vsistema;

    IF vexiste2 = 0 THEN
        LET vsql = 'echo " INSERT INTO bdinteg:sx_contproc VALUES '||
                   '('''||pempresa||''', '''||vproceso||''', '''||vgfecha_hoy||''', '''||vsistema||''', '''||'I'||''', '''||vgusuario||''','||
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horacierrecrec6.sql';
        SYSTEM vsql;
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierrecrec6.sql';
        SYSTEM vstmt;
    ELSE
        SELECT count(*)
          INTO vexistefin
          FROM bdinteg:sx_contproc
         WHERE empresa = pempresa
           AND proceso = vproceso
           AND fecha   = vgfecha_hoy
           AND sistema = vsistema
           AND status_proc = "F";

        IF vexistefin = 0 THEN
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vgusuario||''','||
                       'status_proc   = '''||'I'||''','||
                       'codret        = '''||' '||''','||
                       'hora_ini      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vgfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horacierrecrec6.sql';
            SYSTEM vsql; 
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierrecrec6.sql';
            SYSTEM vstmt;
        ELSE
            SELECT 1
              INTO vexiste
              FROM sc_contproc
             WHERE empresa = pempresa
               AND proceso = 'cierreinvcreccomp6'
               AND fecha = vgfecha_hoy;

            IF vexiste = "1" THEN
                LET vcodret = "966";
                RETURN vcodret;
            END IF            
        END IF
    END IF;
    
    
    -- // VALIDA QUE EL CIERRE PRINCIPAL HAYA COMENZADO A PROCESAR CUENTAS 
    WHILE vinicio_cierre = 0 
        SET ISOLATION TO DIRTY READ;
        
        SELECT COUNT(*)
          INTO vinicio_cierre
          FROM sc_contproc
         WHERE empresa = pempresa
           AND proceso = 'inicio_cierreinvcrec'
           AND fecha = vgfecha_hoy;
    END WHILE;
    
    /*
    -- // OBTIENE NUMERO DE DIAS A PROCESAR  
    IF vgfecha_hoy = vgult_hab_mes THEN
        LET vdias = vgult_dia_mes - vgfecha_hoy + 1;

        IF vgprox_fecha > vgult_dia_mes THEN
            LET vdias = vdias + ((vgprox_fecha-1) - vgult_dia_mes);
        END IF
    ELSE
        LET vdias = vgprox_fecha - vgfecha_hoy;
    END IF
    */
    /*
    -- // OBTIENE NUMERO DE REGISTROS A PROCESAR  
    SELECT COUNT(*)
      INTO vregproc
      FROM sc_maechq
     WHERE producto = vgProdCreciente
       AND status_cta not in("2","6","7","8")
       AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vgfecha_hoy);
    */
    /*
    -- // Obtiene parametro de porcentajes de error por proceso  
    SELECT ROUND(valor)
      INTO vporcentajerror
      FROM sc_param
     WHERE empresa  = pempresa
       AND codparam = "porcentajerror";
    */
    
    SELECT MIN(cuenta), MAX(cuenta)
      INTO vcuentaini, vcuentafin
      FROM sc_maechq
     WHERE producto = '1100'
       AND cuenta LIKE '11%';
       
    
    -- // Actualiza Cuentas Crecientes Canceladas en el Dia  
    FOREACH
        SELECT a.cuenta, b.fecha_alta
          INTO vfcuenta, FechaProc
          FROM sc_maechq a,
               sc_maenoc b
         WHERE a.empresa = pempresa
           AND a.status_cta = "2"
           AND a.producto = vgProdCreciente
           AND (a.fecha_proceso = vgfecha_hoy OR a.fecha_proceso IS NULL)
           AND a.cuenta >= vcuentaini
           AND a.cuenta <= vcuentafin
           AND b.empresa = a.empresa
           AND b.cuenta = a.cuenta
           AND a.fec_cancelac = vgfecha_hoy

        IF FechaProc IS NULL THEN
           UPDATE sc_maechq
              SET fecha_proceso = vgfecha_hoy
            WHERE empresa = pempresa
              AND cuenta = vfcuenta;
	    END IF;

        LET vfcuenta   = '';
        LET FechaProc  = '';
    END FOREACH;
    
    
    -- // Desprovisiona Cuentas Crecientes Canceladas en el Dia  
    LET vhora = current hour to fraction;
    LET vhoraw = vhora;
    LET vfolio_suc = 'informix'||vhoraw[1,2]||vhoraw[4,5]||vhoraw[7,8]||vhoraw[10,11];
    LET vaniomes = YEAR(vgfecha_hoy)||LPAD(MONTH(vgfecha_hoy),2,'0');
    
    FOREACH
        SELECT a.cuenta, a.sucursal, a.producto, a.status_cta, b.int_acum
          INTO vcuenta, vSucursal, vProducto, vgstatus_cta, vint_acum
          FROM sc_maechq a,
               sc_maenoc b
         WHERE a.empresa = pempresa
           AND a.status_cta = '2'
           AND a.producto = vgProdCreciente
           AND a.fecha_proceso = vgfecha_hoy
           AND a.cuenta >= vcuentaini
           AND a.cuenta <= vcuentafin
           AND b.empresa = a.empresa
           AND b.cuenta = a.cuenta
           
        IF vint_acum > 0 THEN
            INSERT INTO sc_movdia VALUES
            ( 0, vfolio_suc, vSucursal, 'informix', vgfecha_hoy, vgfecha_hoy, vhora, vgtranrevprov, vSucursal, vProducto, 
              pempresa, vcuenta, '', 0, vint_acum, vint_acum, 0, 0, 0, '', vgstatus_cta, 0, '0000', ' ', 0, ' ', '', '', vfecha_operacion);
        END IF;
        
        SELECT COUNT(*)
          INTO vexiste_proy
          FROM sc_tasa_variable
         WHERE empresa = pempresa
           AND cuenta = vcuenta
           AND tipo_tasa IN('M','P');
           
        IF vexiste_proy > 0 THEN
            INSERT INTO sc_tasa_var_hist 
            SELECT vaniomes, var.*
              FROM sc_tasa_variable var
             WHERE var.empresa = pempresa
               AND var.cuenta = vcuenta
               AND var.tipo_tasa IN('M','P');
               
            DELETE FROM sc_tasa_variable
             WHERE empresa = pempresa
               AND cuenta = vcuenta
               AND tipo_tasa IN('M','P');
        END IF;
	    
        LET vcuenta      = '';
        LET vSucursal    = '';
        LET vProducto    = '';
        LET vgstatus_cta = '';
        LET vint_acum    = 0.00;
        LET vexiste_proy = 0;
    END FOREACH;  
    
    
    -- // Registra fin de cierre  
    LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
               'SET status_proc   = '''||'F'||''','||
               'codret        = '''||vcodret||''','||
               'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
               'WHERE empresa = '''||pempresa||''' '||
               'AND proceso   = '''||vproceso||''' '||
               'AND fecha     = '''||vgfecha_hoy||''' '||
               'AND sistema   = '''||vsistema||''';" > /tmp/horacierrecrec6.sql';
    SYSTEM vsql;

    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierrecrec6.sql';
    SYSTEM vstmt;

    UPDATE sc_contproc
       SET fecha = vgfecha_hoy
     WHERE empresa = pempresa
       AND proceso = "cierreinvcreccomp6";

    SET LOCK MODE TO NOT WAIT;

    RETURN vcodret;

    END;

END PROCEDURE

DOCUMENT
'DESCRIPCION:   Complemento 6 Cierre Diario del Producto de Inversion Creciente de Captacion ',
'EJECUTADO POR: Control-M',
'AUTOR:         JICS',
'FECHA:         04/Noviembre/2025',
'VERSION:       1.00.0000',
'Base de Datos: bdicheq';

CREATE PROCEDURE "informix".consultmovs_web(pempresa   CHAR(3),
                                 pcuenta    CHAR(20),
                                 psecuencia SMALLINT)

RETURNING CHAR(5),DATE,CHAR(40),MONEY(14,2),MONEY(14,2),MONEY(14,2), CHAR(200);

   DEFINE vtransacc        		VARCHAR(40);
   DEFINE vfecha           		DATE;
   DEFINE vmonto           		MONEY(14,2);
   DEFINE vsdoactual       		MONEY(14,2);
   DEFINE vsdodisp         		MONEY(14,2);
   DEFINE vserial          		INTEGER;
   DEFINE vconta           		SMALLINT;
   DEFINE vciclo           		SMALLINT;
   DEFINE vcodret          		CHAR(5);
   DEFINE vsqlerr          		INTEGER;
   DEFINE vnaturaleza      		CHAR(1);
   DEFINE vultmovto        		SMALLINT;
   DEFINE cFech_param      		CHAR(10);
   DEFINE cFech_param_ini  		CHAR(10);
   DEFINE vdescripcion     		VARCHAR(200);
   DEFINE vConceptospei1		VARCHAR(40);
   DEFINE vConceptospei2   		VARCHAR(33);
   DEFINE dFechaVal				DATE;
   DEFINE vConceptospei3		VARCHAR(32);
   DEFINE vConceptospei4   		VARCHAR(28);
   DEFINE vConceptospei5		VARCHAR(52);
   DEFINE vConceptospei6		VARCHAR(13);
   DEFINE cReferen         		VARCHAR(40);
   DEFINE cTransacc				CHAR(4);
   DEFINE cConcepto        		VARCHAR(50);
   DEFINE cConcepto2       		VARCHAR(50);
   DEFINE cReferencia      		VARCHAR(40);
   DEFINE cFechaTrn				CHAR(10);
   DEFINE vTipoCta		    	VARCHAR(9);
   DEFINE vLeyOutBeneficiario	VARCHAR(41);
   
   LET vcodret    				= "00000";
   LET vtransacc  				= " ";
   LET vfecha     				= " ";
   LET vmonto     				= 0;
   LET vsdoactual 				= 0;
   LET vsdodisp   				= 0;
   LET vciclo     				= 0;
   LET vultmovto  				= 5;
   LET vConceptospei1			= "";
   LET vConceptospei2			= "";
   LET dFechaVal				= "";
   LET vConceptospei3			= "";
   LET vConceptospei4			= "";
   LET vConceptospei5			= "";
   LET vConceptospei6			= "";
   LET cReferen					= "";
   LET cTransacc				="";
   LET cConcepto				="";
   LET cConcepto2				="";
   LET cReferencia				="";
   LET vdescripcion				="";
   LET cFechaTrn				="";
   LET vTipoCta					= "";
   LET vLeyOutBeneficiario 		= '(Dato no verificado por esta institucion)';

    BEGIN
    
    ON EXCEPTION SET vsqlerr
		IF vsqlerr <> 0 THEN
			LET vcodret = vsqlerr;
			RETURN vcodret, vfecha, vtransacc, vmonto, vsdoactual, vsdodisp, vdescripcion;
		END IF;
    END EXCEPTION;
	
	--Set Debug File To '/home/c90301007/Traza/consultmovs_web_modf.out';
    --Trace On;
	
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO wait 3;

    SELECT mc.sdo_actual, (mc.sdo_actual - mc.sdo_retenido - mc.sdo_cong - mc.saldo_sbc)
    INTO vsdoactual, vsdodisp
    FROM bdicheq:sc_maechq mc
    WHERE mc.cuenta = pcuenta;
       
    IF vsdoactual IS NULL THEN
        LET vsdoactual = 0;
        LET vsdodisp = 0;
        LET vcodret = "100";
        RETURN vcodret, vfecha, vtransacc, vmonto, vsdoactual, vsdodisp, vdescripcion;
    END IF;
    
    FOREACH
        SELECT md.fech_alt, md.num_serial, md.monto_tot, md.transacc||" "||tr.descripcion, tr.naturaleza,  md.referencia
          INTO vfecha, vserial, vmonto, vtransacc, vnaturaleza, cReferen
          FROM bdicheq:sc_movdia md,
               bdinteg:si_transacc tr
        WHERE md.empresa = pempresa 
           AND md.cuenta = pcuenta 
           AND md.cancelad <> "S"
           AND tr.empresa = md.empresa 
           AND tr.numero = md.transacc 
           AND tr.se_emite_edocta = "S"   
	       AND tr.sistema = "01"
        ORDER BY fech_alt DESC, num_serial DESC
		 
		IF trim(substr(vtransacc,1,4)) = '0274' THEN

            SELECT NVL(vchrconceptopago,''),NVL(vchrconceptopago2,''), NVL(vchrnombrecorto,''), NVL(vchrcuentaord,''), NVL(vchrnombreord,''), NVL(intrefnumerica,'')
				INTO cConcepto,cConcepto2, vConceptospei2, vConceptospei4, vConceptospei5, vConceptospei6
				FROM bdispei:tblpago pgo 
            INNER JOIN bdispei:tblbanco bco ON ( pgo.cvecesifbcodest = bco.cvecesif AND bco.intindice = bco.intindice )
            WHERE vchrclaverastreo = cReferen
				AND dtfechavalor = vfecha
				AND intcvetipopago <> 0;

            LET cFechaTrn = TO_CHAR(vfecha, '%d/%m/%Y');
  
            IF LENGTH(TRIM(vConceptospei4)) = 18 THEN
               LET vTipoCta = '|CLABE: ';
            ELIF  LENGTH(TRIM(vConceptospei4)) = 16 THEN
			   LET vTipoCta = '|DEBITO: ';
            ELSE
               LET vTipoCta = '|CELULAR: ';
            END IF;
			
			LET vConceptospei1 = TRIM(vdescripcion) || ' ' || cReferen;
			LET cReferen = vConceptospei1;
			
			LET vdescripcion = "";
			
			LET vConceptospei2 = 'BANCO DESTINO: ' || TRIM(vConceptospei2);
			LET vdescripcion = TRIM(vConceptospei2);
			
			LET vConceptospei3 = '|FECHA TRANSFERENCIA: ' || cFechaTrn;
			LET vdescripcion = TRIM(vdescripcion) || TRIM(vConceptospei3);
			
			LET vConceptospei4 = vTipoCta || TRIM(vConceptospei4);
			LET vdescripcion = TRIM(vdescripcion) || TRIM(vConceptospei4);
			
			LET vConceptospei5 = '|BENEFICIARIO: ' || TRIM(vConceptospei5);
			LET vdescripcion = TRIM(vdescripcion) || TRIM(vConceptospei5) || vLeyOutBeneficiario;
			
			LET vConceptospei6 = '|REF: ' || TRIM(vConceptospei6);
			LET vdescripcion = TRIM(vdescripcion) || TRIM(vConceptospei6);
			
			IF SUBSTR(cReferen,1, 9) = 'BANCOPPEL' THEN
				LET cConcepto = '|CONCEPTO: ' || SUBSTR(cConcepto,1,40);
				LET vdescripcion = TRIM(vdescripcion) || TRIM(cConcepto);
            ELSE   
				LET cConcepto2 = '|CONCEPTO: ' || SUBSTR(cConcepto2,1,40);
				LET vdescripcion = TRIM(vdescripcion) || TRIM(cConcepto2);
		    END IF;				
		END IF;
         
        LET vciclo = vciclo + 1;
        
        IF vciclo > vultmovto THEN
            exit FOREACH;
        END IF;
        
        IF vmonto < 0 THEN
            LET vtransacc = "REV "||trim(vtransacc);
        END IF;
        
        IF vnaturaleza = "C" THEN
            LET vmonto = (vmonto * (-1));
        END IF;
        
        RETURN vcodret, vfecha, vtransacc, vmonto, vsdoactual, vsdodisp , vdescripcion with resume;
    END FOREACH;
    
    SELECT valor
      INTO cFech_param
      FROM bdicheq:sc_param
     WHERE empresa = pempresa
       AND codparam = 'fechcon_movhis';
       
    SELECT valor
      INTO cFech_param_ini
      FROM bdicheq:sc_param
     WHERE empresa = pempresa
       AND codparam = 'FechIniCon_movhis_ol';
    
    FOREACH
	    
        SELECT md.fech_alt, md.fech_val, md.num_serial, md.monto_tot, md.transacc||" "||tr.descripcion, tr.naturaleza, md.referencia
          INTO vfecha,dFechaVal,vserial,vmonto,vtransacc,vnaturaleza,cReferen
          FROM bdicheq:sc_movhis md,
               bdinteg:si_transacc tr
         WHERE md.empresa = pempresa 
           AND md.cuenta = pcuenta 
           AND md.fech_alt >= cFech_param
           AND md.cancelad not in("V","S") 
           AND md.transacc = tr.numero
           AND tr.empresa = md.empresa 
           AND tr.numero = md.transacc 
           AND tr.se_emite_edocta = "S"
		   AND tr.sistema = "01"
        UNION ALL	
        SELECT md.fech_alt, md.fech_val, md.num_serial, md.monto_tot, md.transacc||" "||tr.descripcion, tr.naturaleza, md.referencia
          FROM bdicheq:sc_movhis_old md,
               bdinteg:si_transacc tr
         WHERE md.empresa = pempresa 
           AND md.cuenta = pcuenta 
           AND md.fech_alt >= cFech_param_ini
           AND md.fech_alt < cFech_param
           AND md.cancelad not in("V","S") 
           AND md.transacc = tr.numero
           AND tr.empresa = md.empresa 
           AND tr.numero = md.transacc 
           AND tr.se_emite_edocta = "S"
		   AND tr.sistema = "01"
         ORDER BY md.fech_alt DESC, md.num_serial DESC
		 
		 LET vdescripcion="";
		 LET cTransacc=SUBSTR(TRIM(vtransacc),1,4);
		 
		 IF cTransacc = '0273' THEN

			 SELECT NVL(vchrconceptopago,''), NVL(vchrnombrecorto,''), NVL(vchrcuentaord,''), NVL(vchrnombreord,''), NVL(intrefnumerica,'')
			  INTO cConcepto, vConceptospei2, vConceptospei4, vConceptospei5, vConceptospei6
			  FROM bdispei:tblhistpago pgo 
              INNER JOIN bdispei:tblbanco bco ON ( pgo.cvecesifbcoord = bco.cvecesif AND bco.intindice = bco.intindice )
			 WHERE vchrclaverastreo = cReferen
			   AND dtfechavalor = dFechaVal
			   AND intcvetipopago <> 0;

			LET cFechaTrn=TO_CHAR(vfecha, '%d/%m/%Y');

            IF LENGTH(TRIM(vConceptospei4))=18 THEN
               LET vTipoCta='|CLABE: ';
            ELIF  LENGTH(TRIM(vConceptospei4))=16 THEN
			   LET vTipoCta='|DEBITO: ';
            ELSE
               LET vTipoCta='|CELULAR: ';
            END IF;

			LET vConceptospei1=SUBSTR(TRIM(vtransacc),5,11) || ' ' || cReferen;
			LET cReferencia=vConceptospei1;
			
			LET vdescripcion="";
			
			LET vConceptospei2= 'BANCO ORIGEN: ' || TRIM(vConceptospei2);
			LET vdescripcion=TRIM(vConceptospei2);
			
			LET vConceptospei3='|FECHA TRANSFERENCIA: ' || cFechaTrn;
			LET vdescripcion=TRIM(vdescripcion) || TRIM(vConceptospei3);
			
			LET vConceptospei4=vTipoCta || TRIM(vConceptospei4);
			LET vdescripcion=TRIM(vdescripcion) || TRIM(vConceptospei4);
			
			LET vConceptospei5='|ORDENANTE: ' || TRIM(vConceptospei5);
			LET vdescripcion=TRIM(vdescripcion) || TRIM(vConceptospei5);
			
			LET vConceptospei6='|REF: ' || TRIM(vConceptospei6);
			LET vdescripcion=TRIM(vdescripcion) || TRIM(vConceptospei6);
			
			LET cConcepto='|CONCEPTO: ' || SUBSTR(cConcepto,1,40);
			LET vdescripcion=TRIM(vdescripcion) || TRIM(cConcepto);
			
			LET vfecha= '';
			LET vfecha= dFechaVal;
			
		END IF;

	    IF cTransacc = '0274' THEN

                SELECT NVL(vchrconceptopago,''), NVL(vchrconceptopago2,''), NVL(vchrnombrecorto,''), NVL(vchrcuentaord,''), NVL(vchrnombreord,''), NVL(intrefnumerica,'')
                  INTO cConcepto, cConcepto2,  vConceptospei2, vConceptospei4, vConceptospei5, vConceptospei6
				FROM bdispei:tblhistpago pgo 
				INNER JOIN bdispei:tblbanco bco
					ON ( pgo.cvecesifbcodest = bco.cvecesif AND bco.intindice = bco.intindice )
					WHERE vchrclaverastreo = cReferen
					AND dtfechavalor = dFechaVal
					AND intcvetipopago <> 0;

            LET cFechaTrn=TO_CHAR(vfecha, '%d/%m/%Y');
  
            IF LENGTH(TRIM(vConceptospei4))=18 THEN
               LET vTipoCta='|CLABE: ';
            ELIF  LENGTH(TRIM(vConceptospei4))=16 THEN
			   LET vTipoCta='|DEBITO: ';
            ELSE
               LET vTipoCta='|CELULAR: ';
            END IF;
			
			LET vConceptospei1=TRIM(vdescripcion) || ' ' || cReferen;
			LET cReferen=vConceptospei1;
			
			LET vdescripcion="";
			
			LET vConceptospei2= 'BANCO DESTINO: ' || TRIM(vConceptospei2);
			LET vdescripcion=TRIM(vConceptospei2);
			
			LET vConceptospei3='|FECHA TRANSFERENCIA: ' || cFechaTrn;
			LET vdescripcion=TRIM(vdescripcion) || TRIM(vConceptospei3);
			
			LET vConceptospei4=vTipoCta || TRIM(vConceptospei4);
			LET vdescripcion=TRIM(vdescripcion) || TRIM(vConceptospei4);
			
			LET vConceptospei5='|BENEFICIARIO: ' || TRIM(vConceptospei5);
			LET vdescripcion=TRIM(vdescripcion) || TRIM(vConceptospei5)|| vLeyOutBeneficiario;
			
			LET vConceptospei6='|REF: ' || TRIM(vConceptospei6);
			LET vdescripcion=TRIM(vdescripcion) || TRIM(vConceptospei6);
			
			IF SUBSTR(cReferen,1, 9) = 'BANCOPPEL' THEN

				LET cConcepto='|CONCEPTO: ' || SUBSTR(cConcepto,1,40);
				LET vdescripcion=TRIM(vdescripcion) || TRIM(cConcepto);

		    ELSE 

				LET cConcepto2='|CONCEPTO: ' || SUBSTR(cConcepto2,1,40);
				LET vdescripcion=TRIM(vdescripcion) || TRIM(cConcepto2);

            END IF;
			LET vfecha= '';
			LET vfecha= dFechaVal;
			
		END IF;
		 
        LET vciclo = vciclo + 1;
        
        IF vciclo > vultmovto THEN
            exit FOREACH;
        END IF;
        
        IF vmonto < 0 THEN
            LET vtransacc = "REV "||trim(vtransacc);
        END IF;
        
        IF vnaturaleza = "C" THEN
            LET vmonto = (vmonto * (-1));
        END IF;
        
        RETURN vcodret, vfecha, vtransacc, vmonto, vsdoactual, vsdodisp ,  NVL(vdescripcion,'|||||') with resume;
    END FOREACH;
    
    END;   
END PROCEDURE
DOCUMENT
'MODIFICO :     Ezequiel Moreno Paredes',
'BD :     		bdicheq',
'FECHA :        09-06-2025',
'MODIFICACION : Se modifica la formula de calculo de saldo disponible para considerar un nuevo campo llamado saldo_sbc',
'PROYECTO :     RQM 09 704 Cobranza Automatica en cuentas de captacion',
'VERSION :      1.0.1';

CREATE PROCEDURE "informix".sp_bitacoramtu_bpi(pFechaMov DATETIME YEAR TO SECOND,
                                    pMtuActual   DECIMAL(14,2),
                                    pNumCteOrigen CHAR(20),
                                    pDescripcion  CHAR(60),
                                    pMonto        DECIMAL(14,2),
                                    pCodOperacion CHAR(2),
                                    pCanal     CHAR(4), 
                                    pFolioSuc  CHAR(16),
                                    pFolioBPI  CHAR(24))
RETURNING CHAR(5), CHAR(60);
    
    DEFINE vCodRet          CHAR(5);
    DEFINE vDescripcion     CHAR(60);
    DEFINE sql_err         SMALLINT;
    DEFINE isam_err         SMALLINT;
    DEFINE error_info       CHAR(50);
   
    LET vCodRet = '00000';

    BEGIN 
    
        ON EXCEPTION SET sql_err
            --SET DEBUG FILE TO "/tmp/sp_bitacoramtu_bpi.err";
            --TRACE ON;
            IF sql_err <> 0 THEN
                LET vcodret = '00002';
                LET vdescripcion = 'Ocurrio un error al registrar el movimiento';
                RETURN vcodret,vDescripcion;
            END IF;
        END EXCEPTION;
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
        
        --SET debug file to "/home/c90324512/sp_bitacoramtu_bpi.out";
        --TRACE on;
        
        IF pCanal <> '' OR pCanal IS NOT NULL THEN
        
            IF pCanal = '5003' THEN
       
                IF pFechaMov = '' or pFechaMov IS NULL OR 
                    pMtuActual = '' or pMtuActual IS NULL OR
                    pNumCteOrigen = '' or pNumCteOrigen IS NULL OR 
                    pDescripcion = '' or pDescripcion IS NULL OR
                    pMonto = '' or pMonto IS NULL OR 
                    pCodOperacion = '' or pCodOperacion IS NULL OR
                    pFolioBPI = '' or pFolioBPI IS NULL
                    THEN
        
                    LET vcodret = "00001";
                    LET vDescripcion = "Uno o mas parametros estan vacios";
                    RETURN vcodret, vDescripcion;
                END IF;
                
            ELSE 
            
                IF pFechaMov = '' or pFechaMov IS NULL OR 
                    pMtuActual = '' or pMtuActual IS NULL OR
                    pNumCteOrigen = '' or pNumCteOrigen IS NULL OR 
                    pDescripcion = '' or pDescripcion IS NULL OR
                    pMonto = '' or pMonto IS NULL OR 
                    pCodOperacion = '' or pCodOperacion IS NULL OR
                    pCanal = '' or pCanal IS NULL OR 
                    ( (pFolioSuc = '' or pFolioSuc IS NULL) AND (pFolioBPI = '' or pFolioBPI IS NULL) )
                    THEN
        
                    LET vcodret = "00001";
                    LET vDescripcion = "Uno o mas parametros estan vacios";
                    RETURN vcodret, vDescripcion;
                END IF;
            END IF;  
             
        ELSE
            LET vcodret = "00002";
            LET vDescripcion = "El canal esta vacio";
            RETURN vcodret, vDescripcion;
        END IF;
    
        INSERT INTO bdicheq:sc_bitacoramtu(fecha_oper,
			     mtuactual,
			     numcte,
			     descripcion,
			     monto,
			     codigooperacion,
			     canal,
			     folio_suc,
			     folio_bpi) VALUES (pFechaMov,
						  pMtuActual,
						  pNumCteOrigen,
						  pDescripcion,
						  pMonto,
						  pCodOperacion,
						  pCanal,
						  pFolioSuc,
						  pFolioBPI);
						  
        LET  vDescripcion = 'Se registro correctamente';                
        RETURN vCodRet, vDescripcion;
    
    END;

END PROCEDURE
DOCUMENT
'Modifico: BCPL',
'Fecha: 23/06/2025',
'BDD: bdicheq',
'Descripcion: Bitacora de movimientos sobre el MTU del cliente';

CREATE PROCEDURE "informix".gen_archsdos_ant() 
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER;
     
    DEFINE vcodret1         char(5);
    DEFINE vcodret2         char(5);
    DEFINE vcodret3         char(50);
    DEFINE sql_err          integer;
    DEFINE isam_err         integer;
    DEFINE desc_err         char(50);
    DEFINE vcontador1       integer;
    DEFINE vcontador2       integer;
    DEFINE ven_transacc     smallint;
    DEFINE vcomienza        smallint;
    DEFINE vexiste          smallint;
    DEFINE vexistefin       smallint;
    DEFINE vexisteproc      char(12);
    DEFINE vsql             char(600);
    DEFINE vstmt            char(300);
    DEFINE vfecha_hoy       date;
    DEFINE vfecha_ant       date;
    DEFINE vfecha_proceso   date;
    DEFINE vfec_ult_mov     date;
    DEFINE vaniomes         char(6);
    DEFINE vaniomes2        char(6);
    DEFINE vempresa         char(3);
    DEFINE vstatus_cta      char(1);
    DEFINE vproceso         char(10);
    DEFINE vusuario         char(10);
    DEFINE vanio            char(4);
    DEFINE vsucursal        char(4);
    DEFINE vprodcrec        char(4);
    DEFINE vtrancobsbg      char(4);
    DEFINE vproducto        char(4);
    DEFINE vcuenta          char(20);
    DEFINE vmin_cta         char(20);
    DEFINE vmax_cta         char(20);
    DEFINE vmes_actual      char(2);
    DEFINE vmes_siguiente   char(2);
    DEFINE vdia             char(2);
    DEFINE vdia2            char(2);
    DEFINE vmes             char(2);
    DEFINE vsistema         char(2);
    DEFINE vsdo_dia_ant     decimal(18,2);
    DEFINE vimp_chq_sbg     decimal(18,2);
    DEFINE vint_acum        decimal(18,2);
    DEFINE vacum_sdo_int    decimal(18,2);
    DEFINE vsdo_actual      decimal(18,2);
    DEFINE vexistecobsbg    integer;
    DEFINE vmonto_sbg       decimal(18,2);
    DEFINE vcuentaini       char(20);
    DEFINE vcuentafin       char(20);
    DEFINE vnum_cte         char(20);
    DEFINE vejecutivo       char(8);
    DEFINE vgenero          char(1);
    DEFINE vpri_hab_mes     date;
    
    LET vcodret1       = "000";               
    LET vcodret2       = '000';
    LET vcodret3       = 'PROCESO CONCLUIDO SATISFACTORIAMENTE';
    LET sql_err        = 0;                   
    LET isam_err       = 0;
    LET desc_err       = '';
    LET vcontador1     = 0;                   
    LET vcontador2     = 0;
    LET ven_transacc   = 0;                   
    LET vcomienza      = -1;  
    LET vexiste        = 0;                   
    LET vexistefin     = 0;    
    LET vexisteproc    = '';
    LET vsql           = '';                  
    LET vstmt          = '';
    LET vfecha_hoy     = '';                  
    LET vfecha_ant     = '';                    
    LET vmes_actual    = 0;                   
    LET vmes_siguiente = 0;                 
    LET vaniomes       = '';   
    LET vaniomes2      = '';    
    LET vdia           = '';     
    LET vdia2          = '';     
    LET vmes           = '';                  
    LET vanio          = '';    
    LET vprodcrec      = '';    
    LET vtrancobsbg    = '';
    LET vproceso       = 'sdoschqant';        
    LET vsistema       = '01';                
    LET vusuario       = user;                
    LET vmin_cta       = '';                  
    LET vmax_cta       = '';  
    LET vempresa       = '001';             
    LET vcuenta        = '';                  
    LET vsucursal      = '';                
    LET vsdo_dia_ant   = 0.00;                
    LET vimp_chq_sbg   = 0.00;              
    LET vint_acum      = 0.00;                
    LET vacum_sdo_int  = 0.00;              
    LET vproducto      = '';
    LET vstatus_cta    = '';                
    LET vfecha_proceso = '';
    LET vsdo_actual    = 0.00;              
    LET vfec_ult_mov   = '';
    LET vexistecobsbg  = 0;
    LET vmonto_sbg     = 0.00;
    LET vcuentaini     = '';
    LET vcuentafin     = '';
    LET vnum_cte       = '';
    LET vejecutivo     = '';
    LET vgenero        = '';
    LET vpri_hab_mes   = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/gen_archsdos_ant.err";
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
                       'WHERE empresa = '''||vempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horassdosdia.sql';
            SYSTEM vsql;
            
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horassdosdia.sql';
            SYSTEM vstmt;
            RETURN vcodret1, vcodret2, vcodret3, vcontador1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/gen_archsdos_ant.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // Obtiene fechas del sistema
    SELECT fecha_hoy, fecha_ant, pri_hab_mes
      INTO vfecha_hoy, vfecha_ant, vpri_hab_mes
      FROM sc_fechas
     WHERE empresa = vempresa;
     
    -- // VALIDA HAYA FINALIZADO CIERRE DE CAPTACION
    SELECT proceso
      INTO vexisteproc
      FROM sc_contproc
     WHERE empresa = vempresa
       AND proceso = 'cierre'
       AND fecha = vfecha_ant;
    
    IF vexisteproc is null OR vexisteproc = '' THEN
        LET vcodret1 = "962";        
        LET vcodret2 = "962";        
        
        SELECT descripcion
          INTO vcodret3
          FROM bdinteg:si_codret
         WHERE sistema = vsistema
           AND codigo_retorno = vcodret1;
           
        RETURN vcodret1, vcodret2, vcodret3, vcontador1;
    END IF
     
    -- // Guarda proceso en tabla de control de proceso de integral
    SELECT count(*)
      INTO vexiste
      FROM bdinteg:sx_contproc
     WHERE empresa = vempresa
       AND proceso = vproceso
       AND fecha   = vfecha_hoy
       AND sistema = vsistema;

    IF vexiste = 0 THEN
        LET vsql = 'echo "INSERT INTO bdinteg:sx_contproc VALUES '||
                   '('''||vempresa||''', '''||vproceso||''', '''||vfecha_hoy||''', '''||vsistema||''', '''||'I'||''', '''||vusuario||''', '||
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horassdosdia.sql';
        SYSTEM vsql;
        
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horassdosdia.sql';
        SYSTEM vstmt;
    ELSE
        SELECT count(*)
          INTO vexistefin
          FROM bdinteg:sx_contproc
         WHERE empresa     = vempresa
           AND proceso     = vproceso
           AND fecha       = vfecha_hoy
           AND sistema     = vsistema
           AND status_proc = "F";

        IF vexistefin = 0 THEN
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vusuario||''','||
                       'status_proc   = '''||'I'||''','||
                       'codret        = '''||' '||''','||
                       'hora_ini      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||vempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horassdosdia.sql';
            SYSTEM vsql;
            
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horassdosdia.sql';
            SYSTEM vstmt;
        ELSE
            LET vcodret1 = "958";                           
            LET vcodret2 = "958";
            
            SELECT descripcion
              INTO vcodret3
              FROM bdinteg:si_codret
             WHERE sistema = vsistema
               AND codigo_retorno = vcodret1;
            
            RETURN vcodret1, vcodret2, vcodret3, vcontador1;
        END IF;
    END IF;
    
    LET vmes_actual    = LPAD(MONTH(vfecha_ant), 2, '0');
    LET vmes_siguiente = LPAD(MONTH(vfecha_hoy), 2, '0');
    LET vaniomes       = YEAR(vfecha_ant)||LPAD(MONTH(vfecha_ant), 2, '0');
    LET vdia           = DAY(vfecha_ant);
    LET vmes           = LPAD(MONTH(vfecha_ant), 2, '0');
    LET vanio          = YEAR(vfecha_ant);
    LET vaniomes2      = YEAR(vfecha_ant - 1 UNITS DAY)||LPAD(MONTH(vfecha_ant - 1 UNITS DAY), 2, '0');
    LET vdia2          = DAY(vfecha_ant - 1 UNITS DAY);
    
    SELECT valor
      INTO vprodcrec
      FROM sc_param
     WHERE empresa = vempresa
       AND codparam = 'PRODCREC';
       
    SELECT valor
      INTO vtrancobsbg
      FROM sc_param
     WHERE empresa = vempresa
       AND codparam = 'tranpagosbg';
    
    SELECT MIN(cuenta)
      INTO vcuentaini
      FROM sc_maechq;
      
    SELECT valor
      INTO vcuentafin
      FROM sc_param
     WHERE empresa = vempresa
       AND codparam = 'CtaIniActuaSdosComp1';
       
       
    SELECT cuenta, monto_tot
      FROM sc_movdia
     WHERE empresa = vempresa
       AND cuenta >= vcuentaini
       AND cuenta < vcuentafin
       AND cancelad <> 'S'
       AND transacc = vtrancobsbg
       AND fech_alt = vfecha_hoy
       AND producto != vprodcrec 
    INTO TEMP tmp_movs_sbg WITH NO LOG;
    CREATE INDEX idxtmp_movs_sbg ON tmp_movs_sbg(cuenta) ONLINE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_movs_sbg;
    
    /*
    SELECT chq.cuenta, chq.sucursal, chq.sdo_dia_ant, chq.imp_chq_sbg, noc.int_acum, noc.acum_sdo_int,
           chq.producto, chq.status_cta, chq.fecha_proceso, chq.fec_ult_mov, chq.sdo_actual, chq.num_cte, noc.ejecutivo
      FROM sc_maechq chq, 
           sc_maenoc noc
     WHERE chq.cuenta >= vcuentaini
       AND chq.cuenta < vcuentafin
       AND chq.producto != vprodcrec 
       AND noc.cuenta = chq.cuenta
       AND noc.fecha_alta < vfecha_hoy
       AND ( chq.status_cta NOT IN('2','7') OR ( chq.status_cta = '2' AND fec_cancelac = vfecha_hoy ) )
     INTO TEMP tmp_ctas_sdos WITH NO LOG;
    CREATE INDEX idxtmp_ctas_sdos ON tmp_ctas_sdos(cuenta) ONLINE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctas_sdos;
    */    
       
    IF vfecha_hoy = vpri_hab_mes THEN
    
        FOREACH WITH HOLD
            SELECT chq.cuenta, chq.sucursal, chq.sdo_dia_ant, chq.imp_chq_sbg, noc.int_acum, noc.acum_sdo_int,
                   chq.producto, chq.status_cta, chq.fecha_proceso, chq.fec_ult_mov, chq.sdo_actual, chq.num_cte, noc.ejecutivo
              INTO vcuenta, vsucursal, vsdo_dia_ant, vimp_chq_sbg, vint_acum, vacum_sdo_int,
                   vproducto, vstatus_cta, vfecha_proceso, vfec_ult_mov, vsdo_actual, vnum_cte, vejecutivo
              FROM sc_maechq chq, 
                   sc_maenoc noc
             WHERE chq.cuenta >= vcuentaini
               AND chq.cuenta < vcuentafin
               AND chq.producto != vprodcrec 
               AND noc.cuenta = chq.cuenta
               AND noc.fecha_alta < vfecha_hoy
               AND ( chq.status_cta NOT IN('2','7') OR ( chq.status_cta = '2' AND fec_cancelac = vfecha_hoy ) )
               
            IF vcomienza = -1 THEN
                LET vcomienza = 0;
                LET ven_transacc = 1; 
                BEGIN WORK;
            END IF;
               
            SELECT SUM(monto_tot)
              INTO vmonto_sbg
              FROM tmp_movs_sbg
             WHERE cuenta = vcuenta;
             
            IF vmonto_sbg is null THEN
                LET vmonto_sbg = 0.00;
            END IF;
               
            LET vimp_chq_sbg = vimp_chq_sbg + vmonto_sbg;
            
            IF vimp_chq_sbg < 0 THEN
                LET vimp_chq_sbg = vimp_chq_sbg * -1;
            END IF
            
            LET vsdo_dia_ant = vsdo_dia_ant - vimp_chq_sbg;
            
            IF ( vproducto = vprodcrec AND vstatus_cta = '2' AND vfecha_proceso = vfecha_ant ) OR
               ( vproducto = vprodcrec AND vstatus_cta = '2' AND vfecha_proceso is null AND vfec_ult_mov = vfecha_ant ) THEN
                LET vsdo_dia_ant = vsdo_actual;
            END IF;
            
            -- // Actualiza tabla de saldos diarios y provisiones no capitalizadas..        
            CALL sp_actsdodiarioc(vcuenta, vaniomes, vsucursal, vsdo_dia_ant, vint_acum, vdia, vaniomes2, vdia2, vstatus_cta) 
            RETURNING vcodret1;
            
            /* ##########################################################################################
            -- // Actualiza tabla de saldos mensuales y provisiones no capitalizadas..
            IF vmes_actual <> vmes_siguiente THEN
                CALL sp_actsdomensualc(vcuenta, vsucursal, vsdo_dia_ant, vacum_sdo_int, vanio, vmes) 
                RETURNING vcodret1;
                
                CALL sp_actsdotrimestralc(vcuenta, vsucursal, vanio, vmes)
                RETURNING vcodret1;
            END IF;
            ########################################################################################## */
            
            SELECT sexo
              INTO vgenero
              FROM bdinteg:si_ctepf 
             WHERE numcte = vnum_cte;
             
            IF vgenero is null OR vgenero = '' OR vgenero NOT IN('F','M') THEN
                LET vgenero = 'E';
            END IF;
            
            -- // INSERTA EN TABLAS DE LA CONCILIAION DE SALDOS E INTERESES
            INSERT INTO conciliachq VALUES
            ( vfecha_hoy, vcuenta, vproducto, vnum_cte, vgenero, vsucursal, vejecutivo, 
              0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00 );
              
            LET vcontador1 = vcontador1 + 1;
            LET vcontador2 = vcontador2 + 1;

            IF (vcontador2 >= 1000) THEN
                LET vcontador2 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF;
            
            LET vcuenta        = '';
            LET vsucursal      = '';
            LET vsdo_dia_ant   = 0.00;
            LET vimp_chq_sbg   = 0.00;
            LET vint_acum      = 0.00;
            LET vacum_sdo_int  = 0.00;
            LET vproducto      = '';
            LET vstatus_cta    = '';                
            LET vfecha_proceso = '';
            LET vsdo_actual    = 0.00;
            LET vfec_ult_mov   = '';
            LET vexistecobsbg  = 0;
            LET vmonto_sbg     = 0.00;
            LET vgenero        = '';
        END FOREACH;
        
    ELSE
    
        FOREACH WITH HOLD
            SELECT chq.cuenta, chq.sucursal, chq.sdo_dia_ant, chq.imp_chq_sbg, noc.int_acum, noc.acum_sdo_int,
                   chq.producto, chq.status_cta, chq.fecha_proceso, chq.fec_ult_mov, chq.sdo_actual, chq.num_cte, noc.ejecutivo
              INTO vcuenta, vsucursal, vsdo_dia_ant, vimp_chq_sbg, vint_acum, vacum_sdo_int,
                   vproducto, vstatus_cta, vfecha_proceso, vfec_ult_mov, vsdo_actual, vnum_cte, vejecutivo
              FROM sc_maechq chq, 
                   sc_maenoc noc
             WHERE chq.cuenta >= vcuentaini
               AND chq.cuenta < vcuentafin
               AND chq.producto != vprodcrec 
               AND noc.cuenta = chq.cuenta
               AND noc.fecha_alta < vfecha_hoy
               AND ( chq.status_cta NOT IN('2','7') OR ( chq.status_cta = '2' AND fec_cancelac = vfecha_hoy ) )
               
            IF vcomienza = -1 THEN
                LET vcomienza = 0;
                LET ven_transacc = 1; 
                BEGIN WORK;
            END IF;

            SELECT SUM(monto_tot)
              INTO vmonto_sbg
              FROM tmp_movs_sbg
             WHERE cuenta = vcuenta;
             
            IF vmonto_sbg is null THEN
                LET vmonto_sbg = 0.00;
            END IF;
               
            LET vimp_chq_sbg = vimp_chq_sbg + vmonto_sbg;
            
            IF vimp_chq_sbg < 0 THEN
                LET vimp_chq_sbg = vimp_chq_sbg * -1;
            END IF
            
            LET vsdo_dia_ant = vsdo_dia_ant - vimp_chq_sbg;
            
            IF ( vproducto = vprodcrec AND vstatus_cta = '2' AND vfecha_proceso = vfecha_ant ) OR
               ( vproducto = vprodcrec AND vstatus_cta = '2' AND vfecha_proceso is null AND vfec_ult_mov = vfecha_ant ) THEN
                LET vsdo_dia_ant = vsdo_actual;
            END IF;
            
            -- // Actualiza tabla de saldos diarios y provisiones no capitalizadas..        
            CALL sp_actsdodiarioc(vcuenta, vaniomes, vsucursal, vsdo_dia_ant, vint_acum, vdia, vaniomes2, vdia2, vstatus_cta) 
            RETURNING vcodret1;
            
            /* ##########################################################################################
            -- // Actualiza tabla de saldos mensuales y provisiones no capitalizadas..
            IF vmes_actual <> vmes_siguiente THEN
                CALL sp_actsdomensualc(vcuenta, vsucursal, vsdo_dia_ant, vacum_sdo_int, vanio, vmes) 
                RETURNING vcodret1;
                
                CALL sp_actsdotrimestralc(vcuenta, vsucursal, vanio, vmes)
                RETURNING vcodret1;
            END IF;
            ########################################################################################## */
            
            -- // INSERTA EN TABLAS DE LA CONCILIAION DE SALDOS E INTERESES
            INSERT INTO conciliachq VALUES
            ( vfecha_hoy, vcuenta, vproducto, vnum_cte, vgenero, vsucursal, vejecutivo, 
              0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00 );
              
            LET vcontador1 = vcontador1 + 1;
            LET vcontador2 = vcontador2 + 1;

            IF (vcontador2 >= 1000) THEN
                LET vcontador2 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF;
            
            LET vcuenta        = '';
            LET vsucursal      = '';
            LET vsdo_dia_ant   = 0.00;
            LET vimp_chq_sbg   = 0.00;
            LET vint_acum      = 0.00;
            LET vacum_sdo_int  = 0.00;
            LET vproducto      = '';
            LET vstatus_cta    = '';                
            LET vfecha_proceso = '';
            LET vsdo_actual    = 0.00;
            LET vfec_ult_mov   = '';
            LET vexistecobsbg  = 0;
            LET vmonto_sbg     = 0.00;
            LET vgenero        = '';
        END FOREACH;
    
    END IF;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
               'SET ejecutivo = '''||vusuario||''','||
               'status_proc   = '''||'F'||''','||
               'codret        = '''||vcodret1||''','||
               'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
               'WHERE empresa = '''||vempresa||''' '||
               'AND proceso   = '''||vproceso||''' '||
               'AND fecha     = '''||vfecha_hoy||''' '||
               'AND sistema   = '''||vsistema||''';" > /tmp/horassdosdia.sql';
    SYSTEM vsql;
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horassdosdia.sql';
    SYSTEM vstmt;
    
    END;

    RETURN vcodret1, vcodret2, vcodret3, vcontador1;

END PROCEDURE;