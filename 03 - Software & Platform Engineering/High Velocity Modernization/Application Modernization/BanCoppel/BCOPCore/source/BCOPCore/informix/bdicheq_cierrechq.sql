CREATE PROCEDURE "informix".cierrechq(pempresa CHAR(3))
RETURNING CHAR(5);
    
    --- ############################################################################
    --- ##  Nombre:              cierrechq                                        ##
    --- ##  Version:             1.0.1                                            ##
    --- ##  Objetivo:            Programa inicial del cierre diario de captacion  ##
    --- ##  Creado por:                                                           ##
    --- ##  ModIFicado por:      JICS                                             ##
    --- ##  Ultima Modificacion: Marzo 2011                                       ##
    --- ############################################################################

    DEFINE GLOBAL vgusuario             CHAR(8)         DEFAULT " ";
    DEFINE GLOBAL vgfecha_hoy           DATE            DEFAULT " ";
    DEFINE GLOBAL vgpri_dia_mes         DATE            DEFAULT " ";
    DEFINE GLOBAL vgpri_hab_mes         DATE            DEFAULT " ";
    DEFINE GLOBAL vgult_dia_mes         DATE            DEFAULT " ";
    DEFINE GLOBAL vgult_hab_mes         DATE            DEFAULT " ";
    DEFINE GLOBAL vgprox_fecha          DATE            DEFAULT " ";
    DEFINE GLOBAL vgtrans_pag_int       CHAR(4)         DEFAULT " ";
    DEFINE GLOBAL vgtransisr            CHAR(4)         DEFAULT " ";
    DEFINE GLOBAL vgtranprov            CHAR(4)         DEFAULT " ";
    DEFINE GLOBAL vgtranrevprov         CHAR(4)         DEFAULT " ";
    DEFINE GLOBAL vgtranabotrasp        CHAR(4)         DEFAULT " ";
    DEFINE GLOBAL vgtranrecrece         CHAR(4)         DEFAULT " ";
    DEFINE GLOBAL vgProdCreciente       CHAR(4)         DEFAULT " ";
    DEFINE GLOBAL vgstatus_cta          CHAR(1)         DEFAULT " ";

    DEFINE vcodret                      CHAR(5);
    DEFINE vcodret2                     CHAR(5);
    DEFINE vcodret3                     CHAR(40);
    DEFINE vsqlerr                      INTEGER;
    DEFINE isam_err                     INTEGER;
    DEFINE error_info                   CHAR(40);
    DEFINE vfechahora                   CHAR(40);
    DEFINE vcomienza                    SMALLINT;
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
    DEFINE vcontvalcie                  INTEGER;
    DEFINE vcuenta                      CHAR(20);
    DEFINE vfolio_suc                   CHAR(16);
    DEFINE vsdo_cuenta                  MONEY(18,2);
    DEFINE vmto_pag_int                 MONEY(14,2);
    DEFINE vdias                        INTEGER;
    DEFINE vcontprocie                  CHAR(1);
    DEFINE vregproc                     INTEGER;
    DEFINE vporcentajerror              INTEGER;
    DEFINE vcuentafin                   CHAR(20);
    DEFINE vfcuenta                     CHAR(20);
    DEFINE FechaProc                    DATE;
    DEFINE vProducto                    CHAR(4);
    DEFINE vSdoActual                   DECIMAL(14,2);
    DEFINE vSucursal                    CHAR(4);
    DEFINE vregistros                   INTEGER;
    DEFINE vfecha_alta                  DATE;
    DEFINE vpago_interes                CHAR(1);
    DEFINE vdia                         CHAR(2);
    DEFINE vfecha_pago                  DATE;
    DEFINE vnumdias                     SMALLINT;
    DEFINE vProdChequerasPM             CHAR(4);
	DEFINE vProdefechqnostro            CHAR(4);
	DEFINE vProdEfePla                  CHAR(4);
    DEFINE vProdCtaEfec                 CHAR(4);
    DEFINE vProdNomGC                   CHAR(4);
    DEFINE vProdBasNom                  CHAR(4);
    DEFINE vProdCtaNvl2                 CHAR(4);
	DEFINE iNum_renglon					INTEGER;
	DEFINE vNum_producto                VARCHAR(4);
     
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
    LET vcodret    = "000";
    LET vcodret2   = "000";
    LET vcodret3   = "000";
    LET vsqlerr    = 0;
    LET isam_err   = 0;
    LET error_info = '';
    LET vfechahora = " ";
    LET vcomienza  = -1;
    LET vsql       = '';
    LET vstmt      = '';
    LET vsistema   = "01";
    LET vproceso   = "cierrechq";
    LET vstatuscierreinv     = '';
    LET vstatuscobroreestruc = '';
    LET vProdChequeras  = '';
    LET vexiste         = '';
    LET vexiste2        = 0;
    LET vexistefin      = 0;
    LET vcontvalcie     = 0;
    LET vcuenta         = '';
    LET vfolio_suc      = '';
    LET vsdo_cuenta     = 0.00;
    LET vmto_pag_int    = 0.00;
    LET vdias           = 0;
    LET vcontprocie     = '';
    LET vregproc        = 0;
    LET vporcentajerror = 0;
    LET vcuentafin      = '';
    LET vfcuenta        = '';
    LET FechaProc       = '';
    LET vProducto       = '';
    LET vSdoActual      = 0.00;
    LET vSucursal       = '';
    LET vregistros      = 0;
    LET vfecha_alta     = '';
    LET vpago_interes   = '';
    LET vdia            = '';
    LET vfecha_pago     = '';
    LET vnumdias        = 0;
    LET vProdChequerasPM = '';
    LET vProdefechqnostro = '';
	LET vProdEfePla     = '';
    LET vProdCtaEfec    = '2000';
    LET vProdNomGC      = '1300';
    LET vProdBasNom     = '1700';
    LET vProdCtaNvl2    = '2900';
	LET iNum_renglon 	= 0;
    LET vNum_producto   = '';
	
	
    BEGIN

    ON EXCEPTION SET vsqlerr, isam_err, error_info
        SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechq.err";
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
                       'AND sistema   = '''||vsistema||''';" > /tmp/horacierre.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre.sql';
            SYSTEM vstmt;
            RETURN vcodret;
        END IF;
    END EXCEPTION;

    ---	SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechq.out";
    ---	TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // ##################################### //
    -- // #  FECHAS DEL SISTEMA DE CAPTACION  # //
    -- // ##################################### //
    SELECT fecha_hoy, pri_dia_mes, pri_hab_mes, ult_dia_mes, ult_hab_mes, prox_fecha
      INTO vgfecha_hoy, vgpri_dia_mes, vgpri_hab_mes, vgult_dia_mes, vgult_hab_mes, vgprox_fecha
      FROM sc_fechas
     WHERE empresa = pempresa;
    
    -- // #################################### // 
    -- // # TRANSACCION DE PAGO DE INTERESES # //
    -- // #################################### // 
    SELECT valor
      INTO vgtrans_pag_int
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranpagint";
    
    -- // ############################### //
    -- // # TRANSACCION DE COBRO DE ISR # //
    -- // ############################### //
    SELECT valor
      INTO vgtransisr
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranisr";
    
    -- // ######################################### //
    -- // # TRANSACCION DE PROVISION DE INTERESES # //
    -- // ######################################### //
    SELECT valor
      INTO vgtranprov
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranprov";
    
    -- // ############################################ //
    -- // # TRANSACCION DE DESPROVISION DE INTERESES # //
    -- // ############################################ //
    SELECT valor
      INTO vgtranrevprov
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranrevprov";
    
    -- // ###################################### //
    -- // # TRANSACCION DE ABONO PARA TRASPASO # //
    -- // ###################################### //
    SELECT valor
      INTO vgtranabotrasp
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranabotrasp";
    
    -- // ########################################### //
    -- // # TRANSACCION DE REINVERSION DE INVS CREC # //
    -- // ########################################### //
    SELECT valor
      INTO vgtranrecrece
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "trenocre";
       
    -- // ################################ //
    -- // # Producto Inversion Creciente # //
    -- // ################################ //
    SELECT valor
      INTO vgProdCreciente
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "PRODCREC";
       
    -- // ######################### //
    -- // # Producto de Chequeras # //
    -- // ######################### //
    SELECT valor
      INTO vProdChequeras
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "prodefechq";
       
    -- // ##################################### //
    -- // # Producto de Chequeras Empresarial # //
    -- // ##################################### //
    SELECT valor
      INTO vProdChequerasPM
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "prodefechqpm";   
       
    -- // ################################ //
    -- // # Producto de Chequeras NOSTRO # //
    -- // ################################ //
    SELECT valor
      INTO vProdefechqnostro
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "prodefechqnostro";
      
    -- // ############################## //
    -- // # Producto Chequeras PLATINO # //
    -- // ############################## //
    SELECT valor
      INTO vprodefepla
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = "prodefepla";

    -- // ####################### //
    -- // # Productos de Nomina # //
    -- // ####################### //
    SELECT valor
      INTO vProdNomGC
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = "PRODNOMI";
       
    SELECT valor
      INTO vProdBasNom
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = "PRODNOMBA";
       
    -- // ########################### //
    -- // # Producto Cuenta Nivel 2 # //
    -- // ########################### //
    SELECT valor
      INTO vProdCtaNvl2
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = "PRODCTANIVEL2";
    
        
    -- // ############################################################ //
    -- // # VALIDA QUE NO SE HAYA REALIZADO EL CIERRE DEL DIA ACTUAL # //
    -- // ############################################################ //
    SELECT count(*)
      INTO vexiste2 -- 0
      FROM bdinteg:sx_contproc
     WHERE empresa = pempresa
       AND proceso = vproceso
       AND fecha   = vgfecha_hoy
       AND sistema = vsistema;

    IF vexiste2 = 0 THEN
        LET vsql = 'echo " INSERT INTO bdinteg:sx_contproc VALUES '||
                   '('''||pempresa||''', '''||vproceso||''', '''||vgfecha_hoy||''', '''||vsistema||''', '''||'I'||''', '''||vgusuario||''','||
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horacierre.sql';
        SYSTEM vsql;
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre.sql';
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
                       'AND sistema   = '''||vsistema||''';" > /tmp/horacierre.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre.sql';
            SYSTEM vstmt;
        ELSE
            SELECT 1
              INTO vexiste
              FROM sc_contproc
             WHERE empresa = pempresa
               AND proceso = "cierre"
               AND fecha = vgfecha_hoy;

            IF vexiste = "1" THEN
                LET vcodret = "966";
                RETURN vcodret;
            END IF
        END IF
    END IF;
    
    -- // ############################################################# //
    -- // # VALIDA SE HAYA REALIZADO EL RESPALDO DE TABLAS DE CHEQUES # //
    -- // ############################################################# //
    SELECT 1
      INTO vexiste
      FROM sc_contproc
     WHERE empresa = pempresa
       AND proceso = "respacie"
       AND fecha = vgfecha_hoy;

    IF vexiste is null THEN
        LET vcodret = "965";
        LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                   'SET ejecutivo = '''||vgusuario||''','||
                   'status_proc   = '''||'C'||''','||
                   'codret        = '''||vcodret||''','||
                   'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                   'WHERE empresa = '''||pempresa||''' '||
                   'AND proceso   = '''||vproceso||''' '||
                   'AND fecha     = '''||vgfecha_hoy||''' '||
                   'AND sistema   = '''||vsistema||''';" > /tmp/horacierre.sql';
        SYSTEM vsql;
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre.sql';
        SYSTEM vstmt;
        RETURN vcodret;
    END IF
    
    -- // ###################################################### //
    -- // # VERIFICA MESIVERSARIO CUENTAS STATUS 4 (INACTIVAS) # //
    -- // ###################################################### //
    TRUNCATE TABLE sc_ctasinact_cobro_comision;
    
	
	--Contamos el nÃºmero de productos
	/*SELECT COUNT(*) 
	INTO iConta_productos
	FROM tbl_prod_cierrechq ;*/

	--LET iNum_renglon = 0;
	--LET vNum_producto = '';

	--Buscamos el saldo mayor a '0' del Mes
	--WHILE ( iNum_renglon <=iConta_productos - 1) LOOP
		
				/*SELECT SKIP iNum_renglon FIRST 1 producto
				INTO vNum_producto
				FROM tbl_prod_cierrechq;*/
		

	FOREACH
		SELECT  mae.cuenta, mae.producto, noc.fecha_alta, pro.pago_interes
		  INTO vcuenta, vproducto, vfecha_alta, vpago_interes
		  FROM sc_maechq mae,
			   sc_maenoc noc,
			   sc_producto pro,
			   sc_productos_inactivos prod
		 WHERE mae.status_cta = '4'
		   AND mae.sdo_actual > 0.00
		   --AND mae.producto NOT IN( vgProdCreciente, vProdChequeras, vProdChequerasPM, vProdefechqnostro, vProdEfePla )
		                  --NOT IN( '1100'         ,'1900'         ,'2200'           ,'2700'            ,'2400')
			AND mae.producto in ('1200','1300','1400','1500','1600','1700','1800','2000','2100','2300','2500','2600','2800','2900','3100','5000','8000','9900','9901''9999') 
		   AND noc.cuenta = mae.cuenta
		   AND pro.producto = mae.producto
		   AND prod.producto = mae.producto
		
		LET vdia = DAY(vfecha_alta);
		
		CALL calcula_fechapago(vgfecha_hoy, 0, vdia)
		RETURNING vcodret, vfecha_pago, vnumdias;
		
		IF vdia = 1 THEN
			CALL monthadd(vfecha_pago, 1)
			RETURNING vfecha_pago;
		ELIF vdia = 2 AND vgfecha_hoy = '12'||'31'||YEAR(vgfecha_hoy) THEN
			CALL monthadd(vfecha_pago, 1)
			RETURNING vfecha_pago;
		ELSE
			LET vfecha_pago = vgfecha_hoy + vnumdias;
		END IF;

		IF NOT(vdia > DAY(vgult_dia_mes) OR vdia < 1) THEN
			LET vfecha_pago = vfecha_pago - 1;
		END IF
		
		IF ( vpago_interes = "M" AND vgfecha_hoy = vgult_hab_mes ) OR 
		   ( ( vpago_interes = "V" AND vfecha_pago >= vgfecha_hoy AND vfecha_pago < vgprox_fecha ) AND ( vfecha_alta <> vgfecha_hoy ) ) THEN
			INSERT INTO sc_ctasinact_cobro_comision VALUES(vcuenta);
		END IF;
		
		LET vcuenta = '';
		LET vproducto = '';
		LET vfecha_alta = '';
		LET vpago_interes = '';
		LET vdia = '';
		LET vcodret = '';
		LET vfecha_pago = '';
		LET vnumdias = 0;
	END FOREACH;
	
		--		LET iNum_renglon = iNum_renglon + 1;
				
	--END LOOP;
    
    -- // ##################################### //
    -- // # OBTIENE NUMERO DE DIAS A PROCESAR # //
    -- // ##################################### //
    IF vgfecha_hoy = vgult_hab_mes THEN
        LET vdias = vgult_dia_mes - vgfecha_hoy + 1;

        IF vgprox_fecha > vgult_dia_mes THEN
            LET vdias = vdias + ((vgprox_fecha-1) - vgult_dia_mes);
        END IF
    ELSE
        LET vdias = vgprox_fecha - vgfecha_hoy;
    END IF
    
    -- // ########################################## //
    -- // #                                        # //
    -- // ########################################## //
    SELECT control
      INTO vcontprocie
      FROM sc_folsuc
     WHERE empresa = pempresa
       AND control = "2";

    IF vcontprocie is null THEN
        INSERT INTO sc_folsuc values(pempresa,"2","1");
        LET vcontprocie = "1";
    END IF

    IF vcontprocie = "1" THEN
        UPDATE sc_folsuc
           SET control = "2"
         WHERE empresa = pempresa;
    END IF
    
    -- // ########################################## //
    -- // # OBTIENE NUMERO DE REGISTROS A PROCESAR # //
    -- // ########################################## //
    SELECT COUNT(*)
      INTO vregproc
      FROM sc_maechq
     WHERE producto NOT IN( vgProdCreciente, vProdChequeras, vProdChequerasPM, vProdefechqnostro, vProdEfePla )
       AND status_cta not in("2","7","8")
       AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vgfecha_hoy);
    
    -- // ######################################################### //
    -- // # Obtiene parametro de porcentajes de error por proceso # //
    -- // ######################################################### //
    SELECT ROUND(valor)
      INTO vporcentajerror
      FROM sc_param
     WHERE empresa  = pempresa
       AND codparam = "porcentajerror";
       
    -- // ####################################### //
    -- // # ACTUALIZA BANDERA PARA COMPLEMENTOS # //
    -- // ####################################### //
    UPDATE sc_contproc
       SET fecha = vgfecha_hoy
     WHERE empresa = pempresa
       AND proceso = 'inicio_cierre';
    
    -- // ############################################# //
    -- // # FOREACH PRINCIPAL DEL CIERRE DE CAPTACION # //
    -- // ############################################# //
    
	FOREACH principal WITH HOLD FOR   
        SELECT cuenta, fecha_proceso, producto, sdo_actual, status_cta, sucursal
          INTO vfcuenta, FechaProc, vProducto, vSdoActual, vgstatus_cta, vSucursal
          FROM sc_maechq
         --WHERE producto NOT IN( vgProdCreciente, vProdChequeras, vProdChequerasPM, vProdefechqnostro, vProdEfePla, vProdCtaEfec, vProdNomGC, vProdBasNom, vProdCtaNvl2 )
		 --where producto not in('1100','1900','2200','2700','2400','2000','1300','1700','2900')
		 WHERE  producto  IN ('2800','2600','9900','9901','1600','1200','2300','1500','1800','2500')
           --AND status_cta not in("2","7","8")
		  AND status_cta  in("1","3","4","5","6") 
          AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vgfecha_hoy)

        IF vcomienza = -1 THEN
            LET vcomienza = 0;
        END IF; 
        
        CALL cierrechq_reg (pempresa, vdias, vfcuenta, vProducto, vSdoActual, vSucursal)
        RETURNING vcodret;

        IF vcodret <> "000" THEN
            -- // ############################################# //
            -- // # Conteo de Errores generados por el cierre # //
            -- // ############################################# //
            SELECT COUNT(*)
              INTO vcontvalcie
              FROM sc_valcierre
             WHERE empresa = pempresa
               AND cuenta <> '';
            
            LET vregistros = ROUND(vregproc * vporcentajerror / 100);
            
            IF vcontvalcie <= vregistros THEN
                CONTINUE FOREACH;
            ELSE
                LET vcodret = "997";
                LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                           'SET ejecutivo = '''||vgusuario||''','||
                           'status_proc   = '''||'C'||''','||
                           'codret        = '''||vcodret||''','||
                           'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                           'WHERE empresa = '''||pempresa||''' '||
                           'AND proceso   = '''||vproceso||''' '||
                           'AND fecha     = '''||vgfecha_hoy||''' '||
                           'AND sistema   = '''||vsistema||''';" > /tmp/horacierre.sql';
                SYSTEM vsql;
                LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre.sql';
                SYSTEM vstmt;
                RETURN vcodret;
            END IF;
        END IF;
        
        LET vfcuenta     = '';
        LET FechaProc    = '';
        LET vProducto    = '';
        LET vSdoActual   = 0.00;
        LET vgstatus_cta = ' ';
        LET vSucursal    = '';
        LET vcontvalcie  = 0;
        LET vregistros   = 0;
    END FOREACH;
	
	
    
    -- // ########################## //
    -- // # Registra fin de cierre # //
    -- // ########################## //
    LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
               'SET status_proc   = '''||'F'||''','||
               'codret        = '''||vcodret||''','||
               'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
               'WHERE empresa = '''||pempresa||''' '||
               'AND proceso   = '''||vproceso||''' '||
               'AND fecha     = '''||vgfecha_hoy||''' '||
               'AND sistema   = '''||vsistema||''';" > /tmp/horacierre.sql';
    SYSTEM vsql;
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre.sql';
    SYSTEM vstmt;
    
    UPDATE sc_contproc
       SET fecha = vgfecha_hoy
     WHERE empresa = pempresa
       AND proceso = "cierre";
    
    RETURN vcodret;
    
    END
    
END PROCEDURE

DOCUMENT
'DESCRIPCION:   Programa inicial del cierre diario de las cuenta de captacion',
'EJECUTADO POR: Control-M',
'AUTOR:         Antonio Ruiz Mtz.',
'MODIF:         Jorge Ivan Camacho Sanchez',
'FECHA:         04/Junio/2018',
'VERSION:       1.00.0000',
'Base de Datos: BDICHEQ';

CREATE PROCEDURE "informix".cierrechq__1(pempresa CHAR(3))
RETURNING CHAR(5);
    
    --- ############################################################################
    --- ##  Nombre:              cierrechq                                        ##
    --- ##  Version:             1.0.1                                            ##
    --- ##  Objetivo:            Programa inicial del cierre__1 diario de captacion  ##
    --- ##  Creado por:                                                           ##
    --- ##  ModIFicado por:      JICS                                             ##
    --- ##  Ultima Modificacion: Marzo 2011                                       ##
    --- ############################################################################

    DEFINE GLOBAL vgusuario             CHAR(8)         DEFAULT " ";
    DEFINE GLOBAL vgfecha_hoy           DATE            DEFAULT " ";
    DEFINE GLOBAL vgpri_dia_mes         DATE            DEFAULT " ";
    DEFINE GLOBAL vgpri_hab_mes         DATE            DEFAULT " ";
    DEFINE GLOBAL vgult_dia_mes         DATE            DEFAULT " ";
    DEFINE GLOBAL vgult_hab_mes         DATE            DEFAULT " ";
    DEFINE GLOBAL vgprox_fecha          DATE            DEFAULT " ";
    DEFINE GLOBAL vgtrans_pag_int       CHAR(4)         DEFAULT " ";
    DEFINE GLOBAL vgtransisr            CHAR(4)         DEFAULT " ";
    DEFINE GLOBAL vgtranprov            CHAR(4)         DEFAULT " ";
    DEFINE GLOBAL vgtranrevprov         CHAR(4)         DEFAULT " ";
    DEFINE GLOBAL vgtranabotrasp        CHAR(4)         DEFAULT " ";
    DEFINE GLOBAL vgtranrecrece         CHAR(4)         DEFAULT " ";
    DEFINE GLOBAL vgProdCreciente       CHAR(4)         DEFAULT " ";
    DEFINE GLOBAL vgstatus_cta          CHAR(1)         DEFAULT " ";

    DEFINE vcodret                      CHAR(5);
    DEFINE vcodret2                     CHAR(5);
    DEFINE vcodret3                     CHAR(40);
    DEFINE vsqlerr                      INTEGER;
    DEFINE isam_err                     INTEGER;
    DEFINE error_info                   CHAR(40);
    DEFINE vfechahora                   CHAR(40);
    DEFINE vcomienza                    SMALLINT;
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
    DEFINE vcontvalcie                  INTEGER;
    DEFINE vcuenta                      CHAR(20);
    DEFINE vfolio_suc                   CHAR(16);
    DEFINE vsdo_cuenta                  MONEY(18,2);
    DEFINE vmto_pag_int                 MONEY(14,2);
    DEFINE vdias                        INTEGER;
    DEFINE vcontprocie                  CHAR(1);
    DEFINE vregproc                     INTEGER;
    DEFINE vporcentajerror              INTEGER;
    DEFINE vcuentafin                   CHAR(20);
    DEFINE vfcuenta                     CHAR(20);
    DEFINE FechaProc                    DATE;
    DEFINE vProducto                    CHAR(4);
    DEFINE vSdoActual                   DECIMAL(14,2);
    DEFINE vSucursal                    CHAR(4);
    DEFINE vregistros                   INTEGER;
    DEFINE vfecha_alta                  DATE;
    DEFINE vpago_interes                CHAR(1);
    DEFINE vdia                         CHAR(2);
    DEFINE vfecha_pago                  DATE;
    DEFINE vnumdias                     SMALLINT;
    DEFINE vProdChequerasPM             CHAR(4);
	DEFINE vProdefechqnostro            CHAR(4);
	DEFINE vProdEfePla                  CHAR(4);
    DEFINE vProdCtaEfec                 CHAR(4);
    DEFINE vProdNomGC                   CHAR(4);
    DEFINE vProdBasNom                  CHAR(4);
    DEFINE vProdCtaNvl2                 CHAR(4);
	DEFINE iNum_renglon					INTEGER;
	DEFINE vNum_producto                VARCHAR(4);
	DEFINE vinicio_cierre           SMALLINT;
     
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
    LET vcodret    = "000";
    LET vcodret2   = "000";
    LET vcodret3   = "000";
    LET vsqlerr    = 0;
    LET isam_err   = 0;
    LET error_info = '';
    LET vfechahora = " ";
    LET vcomienza  = -1;
    LET vsql       = '';
    LET vstmt      = '';
    LET vsistema   = "01";
    LET vproceso   = "cierrechq__1";
    LET vstatuscierreinv     = '';
    LET vstatuscobroreestruc = '';
    LET vProdChequeras  = '';
    LET vexiste         = '';
    LET vexiste2        = 0;
    LET vexistefin      = 0;
    LET vcontvalcie     = 0;
    LET vcuenta         = '';
    LET vfolio_suc      = '';
    LET vsdo_cuenta     = 0.00;
    LET vmto_pag_int    = 0.00;
    LET vdias           = 0;
    LET vcontprocie     = '';
    LET vregproc        = 0;
    LET vporcentajerror = 0;
    LET vcuentafin      = '';
    LET vfcuenta        = '';
    LET FechaProc       = '';
    LET vProducto       = '';
    LET vSdoActual      = 0.00;
    LET vSucursal       = '';
    LET vregistros      = 0;
    LET vfecha_alta     = '';
    LET vpago_interes   = '';
    LET vdia            = '';
    LET vfecha_pago     = '';
    LET vnumdias        = 0;
    LET vProdChequerasPM = '';
    LET vProdefechqnostro = '';
	LET vProdEfePla     = '';
    LET vProdCtaEfec    = '2000';
    LET vProdNomGC      = '1300';
    LET vProdBasNom     = '1700';
    LET vProdCtaNvl2    = '2900';
	LET iNum_renglon 	= 0;
    LET vNum_producto   = '';
	LET vinicio_cierre  = 0;
	
	
    BEGIN

    ON EXCEPTION SET vsqlerr, isam_err, error_info
        SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechq__1.err";
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
                       'AND sistema   = '''||vsistema||''';" > /tmp/horacierre__1.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre__1.sql';
            SYSTEM vstmt;
            RETURN vcodret;
        END IF;
    END EXCEPTION;

    ---	SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechq__1.out";
    ---	TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // ##################################### //
    -- // #  FECHAS DEL SISTEMA DE CAPTACION  # //
    -- // ##################################### //
    SELECT fecha_hoy, pri_dia_mes, pri_hab_mes, ult_dia_mes, ult_hab_mes, prox_fecha
      INTO vgfecha_hoy, vgpri_dia_mes, vgpri_hab_mes, vgult_dia_mes, vgult_hab_mes, vgprox_fecha
      FROM sc_fechas
     WHERE empresa = pempresa;
    
    -- // #################################### // 
    -- // # TRANSACCION DE PAGO DE INTERESES # //
    -- // #################################### // 
    SELECT valor
      INTO vgtrans_pag_int
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranpagint";
    
    -- // ############################### //
    -- // # TRANSACCION DE COBRO DE ISR # //
    -- // ############################### //
    SELECT valor
      INTO vgtransisr
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranisr";
    
    -- // ######################################### //
    -- // # TRANSACCION DE PROVISION DE INTERESES # //
    -- // ######################################### //
    SELECT valor
      INTO vgtranprov
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranprov";
    
    -- // ############################################ //
    -- // # TRANSACCION DE DESPROVISION DE INTERESES # //
    -- // ############################################ //
    SELECT valor
      INTO vgtranrevprov
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranrevprov";
    
    -- // ###################################### //
    -- // # TRANSACCION DE ABONO PARA TRASPASO # //
    -- // ###################################### //
    SELECT valor
      INTO vgtranabotrasp
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranabotrasp";
    
    -- // ########################################### //
    -- // # TRANSACCION DE REINVERSION DE INVS CREC # //
    -- // ########################################### //
    SELECT valor
      INTO vgtranrecrece
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "trenocre";
       
    -- // ################################ //
    -- // # Producto Inversion Creciente # //
    -- // ################################ //
    SELECT valor
      INTO vgProdCreciente
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "PRODCREC";
       
    -- // ######################### //
    -- // # Producto de Chequeras # //
    -- // ######################### //
    SELECT valor
      INTO vProdChequeras
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "prodefechq";
       
    -- // ##################################### //
    -- // # Producto de Chequeras Empresarial # //
    -- // ##################################### //
    SELECT valor
      INTO vProdChequerasPM
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "prodefechqpm";   
       
    -- // ################################ //
    -- // # Producto de Chequeras NOSTRO # //
    -- // ################################ //
    SELECT valor
      INTO vProdefechqnostro
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "prodefechqnostro";
      
    -- // ############################## //
    -- // # Producto Chequeras PLATINO # //
    -- // ############################## //
    SELECT valor
      INTO vprodefepla
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = "prodefepla";

    -- // ####################### //
    -- // # Productos de Nomina # //
    -- // ####################### //
    SELECT valor
      INTO vProdNomGC
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = "PRODNOMI";
       
    SELECT valor
      INTO vProdBasNom
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = "PRODNOMBA";
       
    -- // ########################### //
    -- // # Producto Cuenta Nivel 2 # //
    -- // ########################### //
    SELECT valor
      INTO vProdCtaNvl2
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = "PRODCTANIVEL2";
    
	
	WHILE vinicio_cierre = 0 
        SELECT COUNT(*)
          INTO vinicio_cierre
          FROM sc_contproc
         WHERE empresa = pempresa
           AND proceso = 'inicio_cierre'
           AND fecha = vgfecha_hoy;
    END WHILE;
        
    -- // ############################################################ //
    -- // # VALIDA QUE NO SE HAYA REALIZADO EL CIERRE DEL DIA ACTUAL # //
    -- // ############################################################ //
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
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horacierre__1.sql';
        SYSTEM vsql;
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre__1.sql';
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
                       'AND sistema   = '''||vsistema||''';" > /tmp/horacierre__1.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre__1.sql';
            SYSTEM vstmt;
        ELSE
            SELECT 1
              INTO vexiste
              FROM sc_contproc
             WHERE empresa = pempresa
               AND proceso = "cierre__1"
               AND fecha = vgfecha_hoy;

            IF vexiste = "1" THEN
                LET vcodret = "966";
                RETURN vcodret;
            END IF
        END IF
    END IF;
    
    -- // ##################################### //
    -- // # OBTIENE NUMERO DE DIAS A PROCESAR # //
    -- // ##################################### //
    IF vgfecha_hoy = vgult_hab_mes THEN
        LET vdias = vgult_dia_mes - vgfecha_hoy + 1;

        IF vgprox_fecha > vgult_dia_mes THEN
            LET vdias = vdias + ((vgprox_fecha-1) - vgult_dia_mes);
        END IF
    ELSE
        LET vdias = vgprox_fecha - vgfecha_hoy;
    END IF
    
    -- // ########################################## //
    -- // # OBTIENE NUMERO DE REGISTROS A PROCESAR # //
    -- // ########################################## //
    SELECT COUNT(*)   --REVISAR CON JORGE CAMACHO
      INTO vregproc
      FROM sc_maechq
     WHERE producto NOT IN( vgProdCreciente, vProdChequeras, vProdChequerasPM, vProdefechqnostro, vProdEfePla )
       AND status_cta not in("2","7","8")
       AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vgfecha_hoy);
    
    -- // ######################################################### //
    -- // # Obtiene parametro de porcentajes de error por proceso # //
    -- // ######################################################### //
    SELECT ROUND(valor)
      INTO vporcentajerror
      FROM sc_param
     WHERE empresa  = pempresa
       AND codparam = "porcentajerror";
    
    -- // ############################################# //
    -- // # FOREACH PRINCIPAL DEL CIERRE DE CAPTACION # //
    -- // ############################################# //
	FOREACH principal WITH HOLD FOR    --236471
        SELECT cuenta, fecha_proceso, producto, sdo_actual, status_cta, sucursal
          INTO vfcuenta, FechaProc, vProducto, vSdoActual, vgstatus_cta, vSucursal
          FROM sc_maechq
		 WHERE producto  IN ('1400','5000')
		   AND status_cta  in("1","3","4","5","6")
		   AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vgfecha_hoy)

        IF vcomienza = -1 THEN
            LET vcomienza = 0;
        END IF; 
        
        CALL cierrechq_reg (pempresa, vdias, vfcuenta, vProducto, vSdoActual, vSucursal)
        RETURNING vcodret;

        IF vcodret <> "000" THEN
            -- // ############################################# //
            -- // # Conteo de Errores generados por el cierre # //
            -- // ############################################# //
            SELECT COUNT(*)
              INTO vcontvalcie
              FROM sc_valcierre
             WHERE empresa = pempresa
               AND cuenta <> '';
            
            LET vregistros = ROUND(vregproc * vporcentajerror / 100);
            
            IF vcontvalcie <= vregistros THEN  --REVISAR CON JORGE CAMACHO
                CONTINUE FOREACH;
            ELSE
                LET vcodret = "997";
                LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                           'SET ejecutivo = '''||vgusuario||''','||
                           'status_proc   = '''||'C'||''','||
                           'codret        = '''||vcodret||''','||
                           'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                           'WHERE empresa = '''||pempresa||''' '||
                           'AND proceso   = '''||vproceso||''' '||
                           'AND fecha     = '''||vgfecha_hoy||''' '||
                           'AND sistema   = '''||vsistema||''';" > /tmp/horacierre__1.sql';
                SYSTEM vsql;
                LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre__1.sql';
                SYSTEM vstmt;
                RETURN vcodret;
            END IF;
        END IF;
        
        LET vfcuenta     = '';
        LET FechaProc    = '';
        LET vProducto    = '';
        LET vSdoActual   = 0.00;
        LET vgstatus_cta = ' ';
        LET vSucursal    = '';
        LET vcontvalcie  = 0;
        LET vregistros   = 0;
    END FOREACH;
	
    
    -- // ########################## //
    -- // # Registra fin de cierre # //
    -- // ########################## //
    LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
               'SET status_proc   = '''||'F'||''','||
               'codret        = '''||vcodret||''','||
               'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
               'WHERE empresa = '''||pempresa||''' '||
               'AND proceso   = '''||vproceso||''' '||
               'AND fecha     = '''||vgfecha_hoy||''' '||
               'AND sistema   = '''||vsistema||''';" > /tmp/horacierre__1.sql';
    SYSTEM vsql;
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre__1.sql';
    SYSTEM vstmt;
    
    UPDATE sc_contproc
       SET fecha = vgfecha_hoy
     WHERE empresa = pempresa
       AND proceso = "cierre__1";
    
    RETURN vcodret;
    
    END
    
END PROCEDURE

DOCUMENT
'DESCRIPCION:   Programa inicial del cierre diario de las cuenta de captacion',
'EJECUTADO POR: Control-M',
'AUTOR:         Antonio Ruiz Mtz.',
'MODIF:         Jorge Ivan Camacho Sanchez',
'FECHA:         04/Junio/2018',
'VERSION:       1.00.0000',
'Base de Datos: BDICHEQ';

CREATE PROCEDURE "informix".cierrechq__2(pempresa CHAR(3))
RETURNING CHAR(5);
    
    --- ############################################################################
    --- ##  Nombre:              cierrechq                                        ##
    --- ##  Version:             1.0.1                                            ##
    --- ##  Objetivo:            Programa inicial del cierre diario de captacion  ##
    --- ##  Creado por:                                                           ##
    --- ##  ModIFicado por:      JICS                                             ##
    --- ##  Ultima Modificacion: Marzo 2011                                       ##
    --- ############################################################################

    DEFINE GLOBAL vgusuario             CHAR(8)         DEFAULT " ";
    DEFINE GLOBAL vgfecha_hoy           DATE            DEFAULT " ";
    DEFINE GLOBAL vgpri_dia_mes         DATE            DEFAULT " ";
    DEFINE GLOBAL vgpri_hab_mes         DATE            DEFAULT " ";
    DEFINE GLOBAL vgult_dia_mes         DATE            DEFAULT " ";
    DEFINE GLOBAL vgult_hab_mes         DATE            DEFAULT " ";
    DEFINE GLOBAL vgprox_fecha          DATE            DEFAULT " ";
    DEFINE GLOBAL vgtrans_pag_int       CHAR(4)         DEFAULT " ";
    DEFINE GLOBAL vgtransisr            CHAR(4)         DEFAULT " ";
    DEFINE GLOBAL vgtranprov            CHAR(4)         DEFAULT " ";
    DEFINE GLOBAL vgtranrevprov         CHAR(4)         DEFAULT " ";
    DEFINE GLOBAL vgtranabotrasp        CHAR(4)         DEFAULT " ";
    DEFINE GLOBAL vgtranrecrece         CHAR(4)         DEFAULT " ";
    DEFINE GLOBAL vgProdCreciente       CHAR(4)         DEFAULT " ";
    DEFINE GLOBAL vgstatus_cta          CHAR(1)         DEFAULT " ";

    DEFINE vcodret                      CHAR(5);
    DEFINE vcodret2                     CHAR(5);
    DEFINE vcodret3                     CHAR(40);
    DEFINE vsqlerr                      INTEGER;
    DEFINE isam_err                     INTEGER;
    DEFINE error_info                   CHAR(40);
    DEFINE vfechahora                   CHAR(40);
    DEFINE vcomienza                    SMALLINT;
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
    DEFINE vcontvalcie                  INTEGER;
    DEFINE vcuenta                      CHAR(20);
    DEFINE vfolio_suc                   CHAR(16);
    DEFINE vsdo_cuenta                  MONEY(18,2);
    DEFINE vmto_pag_int                 MONEY(14,2);
    DEFINE vdias                        INTEGER;
    DEFINE vcontprocie                  CHAR(1);
    DEFINE vregproc                     INTEGER;
    DEFINE vporcentajerror              INTEGER;
    DEFINE vcuentafin                   CHAR(20);
    DEFINE vfcuenta                     CHAR(20);
    DEFINE FechaProc                    DATE;
    DEFINE vProducto                    CHAR(4);
    DEFINE vSdoActual                   DECIMAL(14,2);
    DEFINE vSucursal                    CHAR(4);
    DEFINE vregistros                   INTEGER;
    DEFINE vfecha_alta                  DATE;
    DEFINE vpago_interes                CHAR(1);
    DEFINE vdia                         CHAR(2);
    DEFINE vfecha_pago                  DATE;
    DEFINE vnumdias                     SMALLINT;
    DEFINE vProdChequerasPM             CHAR(4);
	DEFINE vProdefechqnostro            CHAR(4);
	DEFINE vProdEfePla                  CHAR(4);
    DEFINE vProdCtaEfec                 CHAR(4);
    DEFINE vProdNomGC                   CHAR(4);
    DEFINE vProdBasNom                  CHAR(4);
    DEFINE vProdCtaNvl2                 CHAR(4);
	DEFINE iNum_renglon					INTEGER;
	DEFINE vNum_producto                VARCHAR(4);
	DEFINE vinicio_cierre           SMALLINT;
     
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
    LET vcodret    = "000";
    LET vcodret2   = "000";
    LET vcodret3   = "000";
    LET vsqlerr    = 0;
    LET isam_err   = 0;
    LET error_info = '';
    LET vfechahora = " ";
    LET vcomienza  = -1;
    LET vsql       = '';
    LET vstmt      = '';
    LET vsistema   = "01";
    LET vproceso   = "cierrechq__2";
    LET vstatuscierreinv     = '';
    LET vstatuscobroreestruc = '';
    LET vProdChequeras  = '';
    LET vexiste         = '';
    LET vexiste2        = 0;
    LET vexistefin      = 0;
    LET vcontvalcie     = 0;
    LET vcuenta         = '';
    LET vfolio_suc      = '';
    LET vsdo_cuenta     = 0.00;
    LET vmto_pag_int    = 0.00;
    LET vdias           = 0;
    LET vcontprocie     = '';
    LET vregproc        = 0;
    LET vporcentajerror = 0;
    LET vcuentafin      = '';
    LET vfcuenta        = '';
    LET FechaProc       = '';
    LET vProducto       = '';
    LET vSdoActual      = 0.00;
    LET vSucursal       = '';
    LET vregistros      = 0;
    LET vfecha_alta     = '';
    LET vpago_interes   = '';
    LET vdia            = '';
    LET vfecha_pago     = '';
    LET vnumdias        = 0;
    LET vProdChequerasPM = '';
    LET vProdefechqnostro = '';
	LET vProdEfePla     = '';
    LET vProdCtaEfec    = '2000';
    LET vProdNomGC      = '1300';
    LET vProdBasNom     = '1700';
    LET vProdCtaNvl2    = '2900';
	LET iNum_renglon 	= 0;
    LET vNum_producto   = '';
	LET vinicio_cierre  = 0;
	
	
    BEGIN

    ON EXCEPTION SET vsqlerr, isam_err, error_info
        SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechq__2.err";
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
                       'AND sistema   = '''||vsistema||''';" > /tmp/horacierre__2.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre__2.sql';
            SYSTEM vstmt;
            RETURN vcodret;
        END IF;
    END EXCEPTION;

    ---	SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechq__2.out";
    ---	TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // ##################################### //
    -- // #  FECHAS DEL SISTEMA DE CAPTACION  # //
    -- // ##################################### //
    SELECT fecha_hoy, pri_dia_mes, pri_hab_mes, ult_dia_mes, ult_hab_mes, prox_fecha
      INTO vgfecha_hoy, vgpri_dia_mes, vgpri_hab_mes, vgult_dia_mes, vgult_hab_mes, vgprox_fecha
      FROM sc_fechas
     WHERE empresa = pempresa;
    
    -- // #################################### // 
    -- // # TRANSACCION DE PAGO DE INTERESES # //
    -- // #################################### // 
    SELECT valor
      INTO vgtrans_pag_int
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranpagint";
    
    -- // ############################### //
    -- // # TRANSACCION DE COBRO DE ISR # //
    -- // ############################### //
    SELECT valor
      INTO vgtransisr
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranisr";
    
    -- // ######################################### //
    -- // # TRANSACCION DE PROVISION DE INTERESES # //
    -- // ######################################### //
    SELECT valor
      INTO vgtranprov
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranprov";
    
    -- // ############################################ //
    -- // # TRANSACCION DE DESPROVISION DE INTERESES # //
    -- // ############################################ //
    SELECT valor
      INTO vgtranrevprov
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranrevprov";
    
    -- // ###################################### //
    -- // # TRANSACCION DE ABONO PARA TRASPASO # //
    -- // ###################################### //
    SELECT valor
      INTO vgtranabotrasp
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranabotrasp";
    
    -- // ########################################### //
    -- // # TRANSACCION DE REINVERSION DE INVS CREC # //
    -- // ########################################### //
    SELECT valor
      INTO vgtranrecrece
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "trenocre";
       
    -- // ################################ //
    -- // # Producto Inversion Creciente # //
    -- // ################################ //
    SELECT valor
      INTO vgProdCreciente
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "PRODCREC";
       
    -- // ######################### //
    -- // # Producto de Chequeras # //
    -- // ######################### //
    SELECT valor
      INTO vProdChequeras
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "prodefechq";
       
    -- // ##################################### //
    -- // # Producto de Chequeras Empresarial # //
    -- // ##################################### //
    SELECT valor
      INTO vProdChequerasPM
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "prodefechqpm";   
       
    -- // ################################ //
    -- // # Producto de Chequeras NOSTRO # //
    -- // ################################ //
    SELECT valor
      INTO vProdefechqnostro
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "prodefechqnostro";
      
    -- // ############################## //
    -- // # Producto Chequeras PLATINO # //
    -- // ############################## //
    SELECT valor
      INTO vprodefepla
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = "prodefepla";

    -- // ####################### //
    -- // # Productos de Nomina # //
    -- // ####################### //
    SELECT valor
      INTO vProdNomGC
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = "PRODNOMI";
       
    SELECT valor
      INTO vProdBasNom
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = "PRODNOMBA";
       
    -- // ########################### //
    -- // # Producto Cuenta Nivel 2 # //
    -- // ########################### //
    SELECT valor
      INTO vProdCtaNvl2
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = "PRODCTANIVEL2";
    
	
	WHILE vinicio_cierre = 0 
        SELECT COUNT(*)
          INTO vinicio_cierre
          FROM sc_contproc
         WHERE empresa = pempresa
           AND proceso = 'inicio_cierre'
           AND fecha = vgfecha_hoy;
    END WHILE;
        
    -- // ############################################################ //
    -- // # VALIDA QUE NO SE HAYA REALIZADO EL CIERRE DEL DIA ACTUAL # //
    -- // ############################################################ //
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
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horacierre__2.sql';
        SYSTEM vsql;
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre__2.sql';
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
                       'AND sistema   = '''||vsistema||''';" > /tmp/horacierre__2.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre__2.sql';
            SYSTEM vstmt;
        ELSE
            SELECT 1
              INTO vexiste
              FROM sc_contproc
             WHERE empresa = pempresa
               AND proceso = "cierre__2"
               AND fecha = vgfecha_hoy;

            IF vexiste = "1" THEN
                LET vcodret = "966";
                RETURN vcodret;
            END IF
        END IF
    END IF;
    
    -- // ##################################### //
    -- // # OBTIENE NUMERO DE DIAS A PROCESAR # //
    -- // ##################################### //
    IF vgfecha_hoy = vgult_hab_mes THEN
        LET vdias = vgult_dia_mes - vgfecha_hoy + 1;

        IF vgprox_fecha > vgult_dia_mes THEN
            LET vdias = vdias + ((vgprox_fecha-1) - vgult_dia_mes);
        END IF
    ELSE
        LET vdias = vgprox_fecha - vgfecha_hoy;
    END IF
    
    -- // ########################################## //
    -- // # OBTIENE NUMERO DE REGISTROS A PROCESAR # //
    -- // ########################################## //
    SELECT COUNT(*)   --REVISAR CON JORGE CAMACHO
      INTO vregproc
      FROM sc_maechq
     WHERE producto NOT IN( vgProdCreciente, vProdChequeras, vProdChequerasPM, vProdefechqnostro, vProdEfePla )
       AND status_cta not in("2","7","8")
       AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vgfecha_hoy);
    
    -- // ######################################################### //
    -- // # Obtiene parametro de porcentajes de error por proceso # //
    -- // ######################################################### //
    SELECT ROUND(valor)
      INTO vporcentajerror
      FROM sc_param
     WHERE empresa  = pempresa
       AND codparam = "porcentajerror";
       
    -- // ############################################# //
    -- // # FOREACH PRINCIPAL DEL CIERRE DE CAPTACION # //
    -- // ############################################# //	
	FOREACH principal WITH HOLD FOR    --236471
        SELECT cuenta, fecha_proceso, producto, sdo_actual, status_cta, sucursal
          INTO vfcuenta, FechaProc, vProducto, vSdoActual, vgstatus_cta, vSucursal
          FROM sc_maechq
		 WHERE  producto  IN ('2100')
		   AND status_cta  in("1","3","4","5","6")
		   AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vgfecha_hoy)

        IF vcomienza = -1 THEN
            LET vcomienza = 0;
        END IF; 
        
        CALL cierrechq_reg (pempresa, vdias, vfcuenta, vProducto, vSdoActual, vSucursal)
        RETURNING vcodret;

        IF vcodret <> "000" THEN
            -- // ############################################# //
            -- // # Conteo de Errores generados por el cierre # //
            -- // ############################################# //
            SELECT COUNT(*)
              INTO vcontvalcie
              FROM sc_valcierre
             WHERE empresa = pempresa
               AND cuenta <> '';
            
            LET vregistros = ROUND(vregproc * vporcentajerror / 100);
            
            IF vcontvalcie <= vregistros THEN  --REVISAR CON JORGE CAMACHO
                CONTINUE FOREACH;
            ELSE
                LET vcodret = "997";
                LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                           'SET ejecutivo = '''||vgusuario||''','||
                           'status_proc   = '''||'C'||''','||
                           'codret        = '''||vcodret||''','||
                           'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                           'WHERE empresa = '''||pempresa||''' '||
                           'AND proceso   = '''||vproceso||''' '||
                           'AND fecha     = '''||vgfecha_hoy||''' '||
                           'AND sistema   = '''||vsistema||''';" > /tmp/horacierre__2.sql';
                SYSTEM vsql;
                LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre__2.sql';
                SYSTEM vstmt;
                RETURN vcodret;
            END IF;
        END IF;
        
        LET vfcuenta     = '';
        LET FechaProc    = '';
        LET vProducto    = '';
        LET vSdoActual   = 0.00;
        LET vgstatus_cta = ' ';
        LET vSucursal    = '';
        LET vcontvalcie  = 0;
        LET vregistros   = 0;
    END FOREACH;
	
    
    -- // ########################## //
    -- // # Registra fin de cierre # //
    -- // ########################## //
    LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
               'SET status_proc   = '''||'F'||''','||
               'codret        = '''||vcodret||''','||
               'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
               'WHERE empresa = '''||pempresa||''' '||
               'AND proceso   = '''||vproceso||''' '||
               'AND fecha     = '''||vgfecha_hoy||''' '||
               'AND sistema   = '''||vsistema||''';" > /tmp/horacierre__2.sql';
    SYSTEM vsql;
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horacierre__2.sql';
    SYSTEM vstmt;
    
    UPDATE sc_contproc
       SET fecha = vgfecha_hoy
     WHERE empresa = pempresa
       AND proceso = "cierre__2";
    
    RETURN vcodret;
    
    END
    
END PROCEDURE

DOCUMENT
'DESCRIPCION:   Programa inicial del cierre diario de las cuenta de captacion',
'EJECUTADO POR: Control-M',
'AUTOR:         Antonio Ruiz Mtz.',
'MODIF:         Jorge Ivan Camacho Sanchez',
'FECHA:         04/Junio/2018',
'VERSION:       1.00.0000',
'Base de Datos: BDICHEQ';

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