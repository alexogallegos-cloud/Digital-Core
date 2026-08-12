CREATE PROCEDURE "informix".sp_repmensualnomina( pEmpresa CHAR(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50);

    DEFINE vStatusDisp          CHAR(1);
    DEFINE vcTipoEmp            CHAR(2);
    DEFINE vMes                 CHAR(2);
    DEFINE vCodigoEmp           CHAR(3);
    DEFINE vProducto            CHAR(4);
    DEFINE vSucursal            CHAR(4);
    DEFINE vProdDisp            CHAR(4);
    DEFINE vCodRet1             CHAR(5);
    DEFINE vCodRet2             CHAR(5);
    DEFINE vFechaDesc           CHAR(6);
    DEFINE vStatusEmpNet        CHAR(8);
    DEFINE vStatusNomina        CHAR(8);
    DEFINE vServEmpNet          CHAR(10);
    DEFINE vServicioNomina      CHAR(10);
    DEFINE vNumCte              CHAR(20);
    DEFINE vNombreArch          CHAR(20);
    DEFINE vCuenta              CHAR(20);
    DEFINE vCtaDisp             CHAR(20);
    DEFINE vTipoPer             CHAR(25);
    DEFINE vEstado              CHAR(30);
    DEFINE vCiudad              CHAR(30);
    DEFINE vNombreProd          CHAR(40);
    DEFINE vNombreSuc           CHAR(40);
    DEFINE vNombProdDisp        CHAR(40);
    DEFINE vErrorDesc           CHAR(50);
    DEFINE vCodRet3             CHAR(50);
    DEFINE vNombreEmp           CHAR(50);
    DEFINE vRazonSocial         CHAR(60);
    DEFINE vQrySql              CHAR(200);
    DEFINE vQryStmt             CHAR(800);
    DEFINE vFechaHoy            DATE;
    DEFINE vPriDiaMes           DATE;
    DEFINE vUltDiaMes           DATE;
    DEFINE vFechaIni            DATE;
    DEFINE vFechaFin            DATE;
    DEFINE vFechaApli           DATE;
    DEFINE vFechAltaCte         DATE;
    DEFINE vFechAltaEmpNet      DATE;
    DEFINE vFechAltaNomina      DATE;
    DEFINE vExisteProc          SMALLINT;
    DEFINE vExisteFin           SMALLINT;
    DEFINE vAnio                SMALLINT;
    DEFINE vExistEmpNet         SMALLINT;
    DEFINE vExistServNomina     SMALLINT;
    DEFINE vStatEmpNet          SMALLINT;
    DEFINE vNoDispMes           SMALLINT;
    DEFINE vTipoEmp             SMALLINT;
    DEFINE vNoDispMesCta        SMALLINT;
    DEFINE vErrorSql            INTEGER;
    DEFINE vErrorIsam           INTEGER;
    DEFINE vNoCtasBco           INTEGER;
    DEFINE vNoCtasBcoApli       INTEGER;
    DEFINE vNoCtasBcoNoApli     INTEGER;
    DEFINE vNoCtasOBco          INTEGER;
    DEFINE vNoCtasOBcoApli      INTEGER;
    DEFINE vNoCtasOBcoNoApli    INTEGER;
    DEFINE vComDisp             DECIMAL(16,2);
    DEFINE vComDisp1            DECIMAL(16,2);
    DEFINE vComDisp2            DECIMAL(16,2);
    DEFINE vMtoDisp             DECIMAL(16,2);
    DEFINE vSdoFinMes           DECIMAL(16,2);
    DEFINE vComEmpNet           DECIMAL(16,2);
    DEFINE vComEmpNet1          DECIMAL(16,2);
    DEFINE vComEmpNet2          DECIMAL(16,2);
    DEFINE vComNomina           DECIMAL(16,2);
    DEFINE vMtoCtasBco          DECIMAL(18,2);
    DEFINE vMtoCtasBcoApli      DECIMAL(18,2);
    DEFINE vMtoCtasBcoNoApli    DECIMAL(18,2);
    DEFINE vMtoCtasOBco         DECIMAL(18,2);
    DEFINE vMtoCtasOBcoApli     DECIMAL(18,2);
    DEFINE vMtoCtasOBcoNoApli   DECIMAL(18,2);
    DEFINE vFechConMovHis       DATE;
    DEFINE vFechConMovHisOld    DATE;
    DEFINE vFolioDisp           CHAR(16);
	DEFINE cCodigoEmpresa		CHAR(3);
	DEFINE dComSdoprom          DECIMAL(16,2);
	DEFINE mValorSdoPos			MONEY;
	DEFINE mAcumSdoPos			MONEY;
	DEFINE iDiaSdoPos			SMALLINT;
	DEFINE cAnioMesAnte			CHAR(6);
	DEFINE vfoliocontra			INTEGER;

    LET vStatusDisp         = '';
    LET vcTipoEmp           = '';
    LET vMes                = '';
    LET vCodigoEmp          = '';
    LET vProducto           = '';
    LET vSucursal           = '';
    LET vProdDisp           = '';
    LET vCodRet1            = '';
    LET vCodRet2            = '';
    LET vFechaDesc          = '';
    LET vStatusEmpNet       = '';
    LET vStatusNomina       = '';
    LET vServEmpNet         = '';
    LET vServicioNomina     = '';
    LET vNumCte             = '';
    LET vNombreArch         = '';
    LET vCuenta             = '';
    LET vCtaDisp            = '';
    LET vTipoPer            = '';
    LET vEstado             = '';
    LET vCiudad             = '';
    LET vNombreProd         = '';
    LET vNombreSuc          = '';
    LET vNombProdDisp       = '';
    LET vErrorDesc          = '';
    LET vCodRet3            = '';
    LET vNombreEmp          = '';
    LET vRazonSocial        = '';
    LET vQrySql             = '';
    LET vQryStmt            = '';
    LET vFechaHoy           = '';
    LET vPriDiaMes          = '';
    LET vUltDiaMes          = '';
    LET vFechaIni           = '';
    LET vFechaFin           = '';
    LET vFechaApli          = '';
    LET vFechAltaCte        = '';
    LET vFechAltaEmpNet     = '';
    LET vFechAltaNomina     = '';
    LET vExisteProc         = 0;
    LET vExisteFin          = 0;
    LET vAnio               = 0;
    LET vExistEmpNet        = 0;
    LET vExistServNomina    = 0;
    LET vStatEmpNet         = 0;
    LET vNoDispMes          = 0;
    LET vTipoEmp            = 0;
    LET vNoDispMesCta       = 0;
    LET vErrorSql           = 0;
    LET vErrorIsam          = 0;
    LET vNoCtasBco          = 0;
    LET vNoCtasBcoApli      = 0;
    LET vNoCtasBcoNoApli    = 0;
    LET vNoCtasOBco         = 0;
    LET vNoCtasOBcoApli     = 0;
    LET vNoCtasOBcoNoApli   = 0;
    LET vComDisp            = 0.00;
    LET vComDisp1           = 0.00;
    LET vComDisp2           = 0.00;
    LET vMtoDisp            = 0.00;
    LET vSdoFinMes          = 0.00;
    LET vComEmpNet          = 0.00;
    LET vComEmpNet1         = 0.00;
    LET vComEmpNet2         = 0.00;
    LET vComNomina          = 0.00;
    LET vMtoCtasBco         = 0.00;
    LET vMtoCtasBcoApli     = 0.00;
    LET vMtoCtasBcoNoApli   = 0.00;
    LET vMtoCtasOBco        = 0.00;
    LET vMtoCtasOBcoApli    = 0.00;
    LET vMtoCtasOBcoNoApli  = 0.00;
    LET vFechConMovHis      = '';
    LET vFechConMovHisOld   = '';
    LET vFolioDisp          = '';
	LET cCodigoEmpresa		= '';
	LET dComSdoprom         = 0.0;
	LET mValorSdoPos		= 0.0;
	LET mAcumSdoPos			= 0.0;
	LET iDiaSdoPos			= 0;
	LET cAnioMesAnte		= "";

    BEGIN

    ON EXCEPTION SET vErrorSql, vErrorIsam, vErrorDesc
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_repmensualnomina.err";
        TRACE ON;
        IF vErrorSql <> 0 THEN
			LET vCodRet1 = vErrorSql;
            LET vCodRet2 = vErrorIsam;
            LET vCodRet3 = vErrorDesc;
            LET vQryStmt = 'echo "UPDATE sx_contproc SET ejecutivo = ''informix'', status_proc = '''||'E'||''', codret = '''||vCodRet1||''', hora_fin = current WHERE sistema = ''01'' AND proceso = ''GenInfMenNomina'' AND fecha = '''||vFechaHoy||''';" > /resplogifx/conciliachq/infmennomina.sql';
            SYSTEM vQryStmt;
            LET vQrySql = '/ifxsif01/bin/dbaccess bdinteg /resplogifx/conciliachq/infmennomina.sql';
			--LET vQrySql = 'dbaccess bdinteg /resplogifx/conciliachq/infmennomina.sql';
            SYSTEM vQrySql;
            RETURN vCodRet1, vCodRet2, vCodRet3;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_repmensualnomina.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	IF (pEmpresa is null OR pEmpresa = '' OR LENGTH(pEmpresa) <> 3) THEN
        LET pEmpresa = '001';
    END IF;

    SELECT fecha_hoy, pri_dia_mes, ult_dia_mes
      INTO vFechaHoy, vPriDiaMes, vUltDiaMes
      FROM sc_fechas
     WHERE empresa = pEmpresa;
	 
	-- VALIDA SI LA FECHA DEL PRIMER DIA DEL MES NO COMIENZA CON EL DIA PRIMERO
	WHILE DAY(vPriDiaMes) > 1
		LET vPriDiaMes = vPriDiaMes - 1 UNITS DAY;
	END WHILE

    LET vFechaIni = vPriDiaMes - 1 UNITS MONTH;
    LET vFechaFin = vPriDiaMes - 1 UNITS DAY;

    SELECT COUNT(*)
      INTO vExisteProc
      FROM bdinteg:sx_contproc
     WHERE empresa = pEmpresa
       AND proceso = 'GenInfMenNomina'
       AND sistema = '01'
       AND fecha >= vPriDiaMes;

    IF vExisteProc = 0 THEN
        LET vQryStmt = 'echo "INSERT INTO sx_contproc VALUES('''||pEmpresa||''',''GenInfMenNomina'','''||vFechaHoy||''',''01'','''||'I'||''',''informix'', current, null, null);" > /resplogifx/conciliachq/infmennomina.sql';
        SYSTEM vQryStmt;
        LET vQrySql = '/ifxsif01/bin/dbaccess bdinteg /resplogifx/conciliachq/infmennomina.sql';
		--LET vQrySql = 'dbaccess bdinteg /resplogifx/conciliachq/infmennomina.sql';
        SYSTEM vQrySql;
    ELSE
        SELECT COUNT(*)
          INTO vExisteFin
          FROM bdinteg:sx_contproc
         WHERE empresa = pEmpresa
           AND proceso = 'GenInfMenNomina'
           AND sistema = '01'
           AND status_proc = 'F'
           AND fecha >= vPriDiaMes;

        IF vExisteFin = 0 THEN
            LET vQryStmt = 'echo "UPDATE sx_contproc SET ejecutivo = ''informix'', status_proc = '''||'I'||''', codret = null, hora_ini = current, hora_fin = null WHERE sistema = ''01'' AND proceso = ''GenInfMenNomina'' AND fecha = '''||vFechaHoy||''';" > /resplogifx/conciliachq/infmennomina.sql';
            SYSTEM vQryStmt;
            LET vQrySql = '/ifxsif01/bin/dbaccess bdinteg /resplogifx/conciliachq/infmennomina.sql';
			--LET vQrySql = 'dbaccess bdinteg /resplogifx/conciliachq/infmennomina.sql';
            SYSTEM vQrySql;
        ELSE
            LET vCodRet1 = "958";
            LET vCodRet2 = "958";

            SELECT descripcion
              INTO vCodRet3
              FROM bdinteg:si_codret
             WHERE sistema = '01'
               AND codigo_retorno = "958";

            RETURN vCodRet1, vCodRet2, vCodRet3;
        END IF;
    END IF;

    SELECT valor
      INTO vFechConMovHis
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'fechcon_movhis';

    SELECT valor
      INTO vFechConMovHisOld
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'FechIniCon_movhis_ol';

    TRUNCATE TABLE sc_repmensualnomina;

    FOREACH
        SELECT UNIQUE emp.codigo, emp.numcte, emp.nombre, emp.tipo_empresa
          INTO vCodigoEmp, vNumCte, vNombreEmp, vTipoEmp
          FROM sc_nominaempresas emp,
               sc_nominaencabezadosumariohist enc
         WHERE emp.numcte IS NOT NULL
           AND emp.codigo = enc.empresa
           AND enc.fecha_aplicacion BETWEEN vFechaIni AND vFechaFin

        LET vcTipoEmp = LPAD(vTipoEmp, 2, '0');

        SELECT TRIM(tpo_persona)||' '||TRIM(descripcion)
          INTO vTipoPer
          FROM bdinteg:si_tipper
         WHERE tpo_persona = vcTipoEmp;

        FOREACH
            SELECT nombre_archivo, comision, fecha_aplicacion, folio_dispersion
              INTO vNombreArch, vComDisp, vFechaApli, vFolioDisp
              FROM sc_nominaencabezadosumariohist
             WHERE empresa = vCodigoEmp
               AND fecha_aplicacion BETWEEN vFechaIni AND vFechaFin

            SELECT SUM(monto_tot)
              INTO vComDisp1
              FROM sc_movhis_old
             WHERE folio_suc = vFolioDisp
               AND cancelad <> 'S'
               AND transacc IN('3254','3255','3257')
               AND fech_alt >= vFechConMovHisOld
               AND fech_alt < vFechConMovHis;

            SELECT SUM(monto_tot)
              INTO vComDisp2
              FROM sc_movhis
             WHERE folio_suc = vFolioDisp
               AND cancelad <> 'S'
               AND transacc IN('3254','3255','3257')
               AND fech_alt >= vFechConMovHis;

            IF vComDisp1 is null THEN
                LET vComDisp1 = 0.00;
            END IF;

            IF vComDisp2 is null THEN
                LET vComDisp2 = 0.00;
            END IF;

            LET vComDisp = vComDisp1 + vComDisp2;

            FOREACH
                SELECT cuenta_abono, importe, status
                  INTO vCuenta, vMtoDisp, vStatusDisp
                  FROM sc_nominamovimientoshist
                 WHERE nombre_archivo = vNombreArch

                IF LENGTH(vCuenta) = 11 THEN
                    LET vNoCtasBco = vNoCtasBco + 1;
                    LET vMtoCtasBco = vMtoCtasBco + vMtoDisp;

                    IF vStatusDisp = '1' THEN
                        LET vNoCtasBcoApli = vNoCtasBcoApli + 1;
                        LET vMtoCtasBcoApli = vMtoCtasBcoApli + vMtoDisp;
                    ELSE
                        LET vNoCtasBcoNoApli = vNoCtasBcoNoApli + 1;
                        LET vMtoCtasBcoNoApli = vMtoCtasBcoNoApli + vMtoDisp;
                    END IF;
                ELSE
                    LET vNoCtasOBco = vNoCtasOBco + 1;
                    LET vMtoCtasOBco = vMtoCtasOBco + vMtoDisp;

                    IF vStatusDisp = '1' THEN
                        LET vNoCtasOBcoApli = vNoCtasOBcoApli + 1;
                        LET vMtoCtasOBcoApli = vMtoCtasOBcoApli + vMtoDisp;
                    ELSE
                        LET vNoCtasOBcoNoApli = vNoCtasOBcoNoApli + 1;
                        LET vMtoCtasOBcoNoApli = vMtoCtasOBcoNoApli + vMtoDisp;
                    END IF;
                END IF;

                LET vCuenta = '';
                LET vMtoDisp = 0.00;
                LET vStatusDisp = '';
            END FOREACH;

            IF vComDisp           is null THEN LET vComDisp           = 0; END IF;
            IF vNoCtasBcoApli     is null THEN LET vNoCtasBcoApli     = 0; END IF;
            IF vMtoCtasBcoApli    is null THEN LET vMtoCtasBcoApli    = 0; END IF;
            IF vNoCtasBcoNoApli   is null THEN LET vNoCtasBcoNoApli   = 0; END IF;
            IF vMtoCtasBcoNoApli  is null THEN LET vMtoCtasBcoNoApli  = 0; END IF;
            IF vNoCtasOBcoApli    is null THEN LET vNoCtasOBcoApli    = 0; END IF;
            IF vMtoCtasOBcoApli   is null THEN LET vMtoCtasOBcoApli   = 0; END IF;
            IF vNoCtasOBcoNoApli  is null THEN LET vNoCtasOBcoNoApli  = 0; END IF;
            IF vMtoCtasOBcoNoApli is null THEN LET vMtoCtasOBcoNoApli = 0; END IF;

            INSERT INTO sc_repmensualnomina VALUES
            ( vNumCte, vNombreEmp, vTipoPer, vNombreArch, vFechaApli, vComDisp,
              'PAGADO', vNoCtasBcoApli, vMtoCtasBcoApli, 'NO PAGADO', vNoCtasBcoNoApli, vMtoCtasBcoNoApli,
              'PAGADO', vNoCtasOBcoApli, vMtoCtasOBcoApli, 'NO PAGADO', vNoCtasOBcoNoApli, vMtoCtasOBcoNoApli,
              'PAGADO', (vNoCtasBcoApli + vNoCtasOBcoApli), (vMtoCtasBcoApli + vMtoCtasOBcoApli),
              'NO PAGADO', (vNoCtasBcoNoApli + vNoCtasOBcoNoApli), (vMtoCtasBcoNoApli + vMtoCtasOBcoNoApli) );

            LET vNombreArch        = '';
            LET vComDisp           = 0.00;
            LET vComDisp1          = 0.00;
            LET vComDisp2          = 0.00;
            LET vFechaApli         = '';
            LET vNoCtasBco         = 0;
            LET vMtoCtasBco        = 0.00;
            LET vNoCtasBcoApli     = 0;
            LET vMtoCtasBcoApli    = 0.00;
            LET vNoCtasBcoNoApli   = 0;
            LET vMtoCtasBcoNoApli  = 0.00;
            LET vNoCtasOBco        = 0;
            LET vMtoCtasOBco       = 0.00;
            LET vNoCtasOBcoApli    = 0;
            LET vMtoCtasOBcoApli   = 0.00;
            LET vNoCtasOBcoNoApli  = 0;
            LET vMtoCtasOBcoNoApli = 0.00;
        END FOREACH;

        LET vCodigoEmp = '';
        LET vNumCte    = '';
        LET vNombreEmp = '';
        LET vTipoEmp   = 0;
        LET vcTipoEmp  = '';
        LET vTipoPer   = '';
    END FOREACH;

    UPDATE STATISTICS MEDIUM FOR TABLE sc_repmensualnomina;

    LET vFechaDesc = TO_CHAR(vFechaFin, '%Y%m');

    LET vQryStmt = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/repmensualnominadetalle_'||vFechaDesc||'.txt '||
                   'SELECT * FROM sc_repmensualnomina WHERE fecha_disp BETWEEN '''||vFechaIni||''' AND '''||vFechaFin||''' '||
                   'ORDER BY numcte, fecha_disp, nombre_archivo;" > /resplogifx/conciliachq/repmennomdet.sql';
    SYSTEM vQryStmt;
    LET vQrySql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/repmennomdet.sql";
	--LET vQrySql = "dbaccess bdicheq /resplogifx/conciliachq/repmennomdet.sql";
    SYSTEM vQrySql;

    LET vQryStmt = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/repmensualnominaresumen_'||vFechaDesc||'.txt '||
                   'SELECT b.codigo, a.numcte, b.nombre, '||
                   'SUM(a.regsaplibco), SUM(a.impregsaplibco), SUM(a.comision_disp), '||
                   'SUM(a.regsapliobco), SUM(a.impregsapliobco), SUM(a.comision_disp), '||
                   'SUM(a.regsnoaplibco), SUM(a.impregsnoaplibco), SUM(a.comision_disp), '||
                   'SUM(a.regsnoapliobco), SUM(a.impregsnoapliobco), SUM(a.comision_disp), '||
                   'SUM(a.regsaplibco + a.regsnoaplibco ), SUM(a.impregsaplibco + a.impregsnoaplibco), SUM(a.comision_disp), '||
                   'SUM(a.regsapliobco + a.regsnoapliobco ), SUM(a.impregsapliobco + a.impregsnoapliobco), SUM(a.comision_disp) '||
                   'FROM sc_repmensualnomina a, sc_nominaempresas b '||
                   'WHERE a.numcte = b.numcte '||
                   'GROUP BY 1, 2, 3 '||
                   'ORDER BY 1;" > /resplogifx/conciliachq/repmennomres.sql';
    SYSTEM vQryStmt;
    LET vQrySql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/repmennomres.sql";
	--LET vQrySql = "dbaccess bdicheq /resplogifx/conciliachq/repmennomres.sql";
    SYSTEM vQrySql;

    -- // RQM 10 438-2 REPORTE MENSUAL DEL SERVICIO DE NOMINA BANCOPPEL
    TRUNCATE TABLE sc_repmensualempnetnomina;

    FOREACH
        SELECT cte.numcte, cte.fecha_insert, cte.razon_social, mae.cuenta, mae.producto, pro.nombre, mae.sucursal
          INTO vNumCte, vFechAltaCte, vRazonSocial, vCuenta, vProducto, vNombreProd, vSucursal
          FROM bdinteg:si_cliente cte,
               bdinteg:si_ctepm pm,
               sc_maechq mae,
               sc_producto pro
         WHERE cte.numcte = pm.numcte
           AND mae.num_cte = cte.numcte
           AND mae.status_cta NOT IN('2','6','7','8')
           AND pro.producto = mae.producto
           AND pro.producto IN('1200','1600','2200','2600','2700','2800','9900','9901')

        SELECT est.nombre, ciu.nombreciudad
          INTO vEstado, vCiudad
          FROM bdinteg:"informix".si_direcciones_actual dir
          LEFT OUTER JOIN bdinteg:"informix".si_catciudades ciu ON (ciu.numerociudad = dir.numerociudad)
          LEFT OUTER JOIN bdinteg:"informix".si_estados est ON (est.estado = dir.estado)
         WHERE dir.numcte = vNumCte
           AND dir.tipo_dir = 1;

        -- // VERIFICA SI TIENE CONTRATADO EMPRESANET
        SELECT COUNT(*)
          INTO vExistEmpNet
          FROM bdibei:bei_contratacion
         WHERE empresa = pEmpresa
		 AND num_cliente = vNumCte;

        IF vExistEmpNet = 0 THEN
            LET vServEmpNet = 'NO';
            LET vFechAltaEmpNet = '';
            LET vStatusEmpNet = 'INACTIVO';
        ELSE
            LET vServEmpNet = 'SI';
			 
			SELECT MAX(folio_contrato)
			  INTO vfoliocontra
			  FROM bdibei:bei_contratacion
			  WHERE empresa = pEmpresa
               AND num_cliente = vNumCte;
			   
            SELECT f_registro, status_contrato
			INTO vFechAltaEmpNet, vStatEmpNet
              FROM bdibei:bei_contratacion
			  WHERE empresa = pEmpresa
               AND num_cliente = vNumCte
			   AND folio_contrato = vfoliocontra;

            IF vStatEmpNet = 30 THEN
                LET vStatusEmpNet = 'ACTIVO';
            ELSE
                LET vStatusEmpNet = 'INACTIVO';
            END IF;

            SELECT SUM(monto_tot)
              INTO vComEmpNet1
              FROM sc_movhis_old
             WHERE empresa = pEmpresa
               AND cuenta = vCuenta
               AND fech_alt BETWEEN vFechaIni AND vFechaFin
               AND cancelad <> 'S'
               AND transacc = '3292'
               AND fech_alt >= vFechConMovHisOld
               AND fech_alt < vFechConMovHis;

            SELECT SUM(monto_tot)
              INTO vComEmpNet2
              FROM sc_movhis
             WHERE empresa = pEmpresa
               AND cuenta = vCuenta
               AND fech_alt BETWEEN vFechaIni AND vFechaFin
               AND cancelad <> 'S'
               AND transacc = '3292'
               AND fech_alt >= vFechConMovHis;

            IF vComEmpNet1 is null THEN
                LET vComEmpNet1 = 0.00;
            END IF;

            IF vComEmpNet2 is null THEN
                LET vComEmpNet2 = 0.00;
            END IF;

            LET vComEmpNet = vComEmpNet1 + vComEmpNet2;
        END IF;

        -- // VERIFICA SI TIENE CONTRATADO EL SERVCIO DE NOMINA
        SELECT COUNT(*)
          INTO vExistServNomina
          FROM sc_nominaempresas
         WHERE numcte = vNumCte;

        IF vExistServNomina = 0 THEN
            LET vServicioNomina = 'NO';
            LET vFechAltaNomina = '';
            LET vStatusNomina = 'INACTIVO';
        ELSE
            LET vServicioNomina = 'SI';
            LET vFechAltaNomina = vFechAltaCte;
            LET vStatusNomina = 'ACTIVO';

            SELECT SUM(monto_tot)
              INTO vComDisp1
              FROM sc_movhis_old
             WHERE empresa = pEmpresa
               AND cuenta = vCuenta
               AND fech_alt BETWEEN vFechaIni AND vFechaFin
               AND cancelad <> 'S'
               AND transacc IN('3254','3255','3257')
               AND fech_alt >= vFechConMovHisOld
               AND fech_alt < vFechConMovHis;

            SELECT SUM(monto_tot)
              INTO vComDisp2
              FROM sc_movhis
             WHERE empresa = pEmpresa
               AND cuenta = vCuenta
               AND fech_alt BETWEEN vFechaIni AND vFechaFin
               AND cancelad <> 'S'
               AND transacc IN('3254','3255','3257')
               AND fech_alt >= vFechConMovHis;

            IF vComDisp1 is null THEN
                LET vComDisp1 = 0.00;
            END IF;

            IF vComDisp2 is null THEN
                LET vComDisp2 = 0.00;
            END IF;

            LET vComNomina = vComDisp1 + vComDisp2;
        END IF;
		--// OBTIENE EL CODIGO DE LA EMPRESA
		SELECT codigo
		INTO cCodigoEmpresa
		FROM sc_nominaempresas
		WHERE numcte = vNumCte;
		--// OBTIENE EL ACUMULADO DE LAS COMISION POR NO TENER SALDO PROMEDIO
		SELECT SUM(monto_tot)
		INTO dComSdoprom
		FROM sc_movhis
		WHERE empresa = pEmpresa
		AND cuenta = vCuenta
		AND fech_alt BETWEEN vFechaIni AND vFechaFin
		AND cancelad <> 'S'
		AND transacc = '3290'
		AND fech_alt >= vFechConMovHis;
		
		LET cAnioMesAnte = YEAR(vFechaHoy - 1 units MONTH) || LPAD(MONTH(vFechaHoy - 1 units MONTH),2,"0");
		
		SELECT acum_sdo_pos, dia_sdo_pos
		INTO mAcumSdoPos, iDiaSdoPos
		FROM "informix".sc_maehis
		WHERE aniomes = cAnioMesAnte
		AND cuenta = vCuenta;
		
		LET mAcumSdoPos = NVL(mAcumSdoPos, 0);
		LET iDiaSdoPos = NVL(iDiaSdoPos, 0);

		IF iDiaSdoPos = 0 THEN
			LET mValorSdoPos = 0;
		ELSE
			LET mValorSdoPos = mAcumSdoPos / iDiaSdoPos;
		END IF
		   
		LET cCodigoEmpresa = NVL(cCodigoEmpresa,"");
		LET dComSdoprom = NVL(dComSdoprom, 0.0);
		LET mValorSdoPos = NVL(mValorSdoPos, 0.0);
		
        INSERT INTO sc_repmensualempnetnomina VALUES
        ( vNumCte, vFechAltaCte, vRazonSocial, vCuenta, vProducto, vNombreProd, vSucursal, vEstado, vCiudad,
          vServEmpNet, vFechAltaEmpNet, vStatusEmpNet, vComEmpNet, vServicioNomina, vFechAltaNomina, cCodigoEmpresa, 
		  vStatusNomina, vComNomina, dComSdoprom,  mValorSdoPos);

        LET vNumCte         = '';
        LET vRazonSocial    = '';
        LET vFechAltaCte    = '';
        LET vCuenta         = '';
        LET vServEmpNet     = 0;
        LET vFechAltaEmpNet = '';
        LET vComEmpNet      = 0.00;
        LET vComEmpNet1     = 0.00;
        LET vComEmpNet2     = 0.00;
        LET vServicioNomina = 0;
        LET vFechAltaNomina = '';
        LET vComNomina      = 0.00;
        LET vComDisp1       = 0.00;
        LET vComDisp2       = 0.00;
		LET dComSdoprom		= 0.00;
    END FOREACH;

    UPDATE STATISTICS MEDIUM FOR TABLE sc_repmensualempnetnomina;

    LET vQryStmt = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/repmensualnominaempnet_'||vFechaDesc||'.txt '||
                   'SELECT * FROM sc_repmensualempnetnomina ORDER BY numcte, cuenta_eje;" > /resplogifx/conciliachq/repmennom.sql';
    SYSTEM vQryStmt;
    LET vQrySql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/repmennom.sql";
	--LET vQrySql = "dbaccess bdicheq /resplogifx/conciliachq/repmennom.sql";
    SYSTEM vQrySql;

    TRUNCATE TABLE sc_repmensualdispnomina;

    FOREACH
        SELECT cte.numcte, cte.fecha_insert, cte.razon_social, cte.sucursal, suc.nombre, mae.cuenta, mae.producto, pro.nombre
          INTO vNumCte, vFechAltaCte, vRazonSocial, vSucursal, vNombreSuc, vCuenta, vProducto, vNombreProd
          FROM bdinteg:si_cliente cte,
               bdinteg:si_ctepm pm,
               sc_maechq mae,
               sc_producto pro,
               bdinteg:si_sucursales suc
         WHERE cte.numcte = pm.numcte
           AND mae.num_cte = cte.numcte
           AND mae.status_cta NOT IN('2','6','7','8')
           AND pro.producto = mae.producto
           AND pro.producto IN('1200','1600','2200','2600','2700','2800','9900','9901')
           AND suc.sucursal = cte.sucursal

        SELECT est.nombre, ciu.nombreciudad
          INTO vEstado, vCiudad
          FROM bdinteg:"informix".si_direcciones_actual dir
          LEFT OUTER JOIN bdinteg:"informix".si_catciudades ciu ON (ciu.numerociudad = dir.numerociudad)
          LEFT OUTER JOIN bdinteg:"informix".si_estados est ON (est.estado = dir.estado)
         WHERE dir.numcte = vNumCte
           AND dir.tipo_dir = 1;

        -- // VERIFICA SI TIENE CONTRATADO EL SERVICIO DE NOMINA
        SELECT COUNT(*)
          INTO vExistServNomina
          FROM sc_nominaempresas
         WHERE numcte = vNumCte;

        IF vExistServNomina = 0 THEN
            LET vServicioNomina = 'NO';
            LET vFechAltaNomina = '';
            LET vStatusNomina = 'INACTIVO';
        ELSE
            LET vServicioNomina = 'SI';
            LET vFechAltaNomina = vFechAltaCte;
            LET vStatusNomina = 'ACTIVO';
        END IF;

        -- // NUMERO DE DISPERSIONES AL MES DE LA CUENTA
        SELECT COUNT(*)
          INTO vNoDispMes
          FROM sc_nominaempresas emp,
               sc_nominaencabezadosumariohist enc
         WHERE emp.numcte = vNumCte
           AND emp.codigo = enc.empresa
           AND enc.fecha_aplicacion BETWEEN vFechaIni AND vFechaFin
           AND enc.cuenta_cargo = vCuenta;

        IF vNoDispMes > 0 THEN
            SELECT SUM(monto_tot)
              INTO vComDisp1
              FROM sc_movhis_old
             WHERE empresa = pEmpresa
               AND cuenta = vCuenta
               AND fech_alt BETWEEN vFechaIni AND vFechaFin
               AND cancelad <> 'S'
               AND transacc IN('3254','3255','3257')
               AND fech_alt >= vFechConMovHisOld
               AND fech_alt < vFechConMovHis;

            SELECT SUM(monto_tot)
              INTO vComDisp2
              FROM sc_movhis
             WHERE empresa = pEmpresa
               AND cuenta = vCuenta
               AND fech_alt BETWEEN vFechaIni AND vFechaFin
               AND cancelad <> 'S'
               AND transacc IN('3254','3255','3257')
               AND fech_alt >= vFechConMovHis;

            IF vComDisp1 is null THEN
                LET vComDisp1 = 0.00;
            END IF;

            IF vComDisp2 is null THEN
                LET vComDisp2 = 0.00;
            END IF;

            LET vComDisp = vComDisp1 + vComDisp2;

            FOREACH
                SELECT UNIQUE emp.codigo, emp.nombre
                  INTO vCodigoEmp, vNombreEmp
                  FROM sc_nominaempresas emp,
                       sc_nominaencabezadosumariohist enc
                 WHERE emp.numcte = vNumCte
                   AND emp.codigo = enc.empresa
                   AND enc.fecha_aplicacion BETWEEN vFechaIni AND vFechaFin
                   AND enc.cuenta_cargo = vCuenta

                FOREACH
                    SELECT b.cuenta_abono, COUNT(*)
                      INTO vCtaDisp, vNoDispMesCta
                      FROM sc_nominaencabezadosumariohist a,
                           sc_nominamovimientoshist b
                     WHERE a.empresa = vCodigoEmp
                       AND a.fecha_aplicacion BETWEEN vFechaIni AND vFechaFin
                       AND a.nombre_archivo = b.nombre_archivo
                     GROUP BY 1

                    SELECT a.producto, b.nombre
                      INTO vProdDisp, vNombProdDisp
                      FROM sc_maechq a,
                           sc_producto b
                     WHERE a.cuenta = vCtaDisp
                       AND b.producto = a.producto;

                    INSERT INTO sc_repmensualdispnomina VALUES
                    ( vNumCte, vFechAltaCte, vRazonSocial, vSucursal, vNombreSuc, vEstado, vCiudad, vCuenta, vProducto, vNombreProd,
                      vStatusNomina, vNoDispMes, vCtaDisp, vProdDisp, vNombProdDisp, vNoDispMesCta, vNombreEmp, vComDisp );

                    LET vCtaDisp      = '';
                    LET vNoDispMesCta = 0;
                    LET vProdDisp     = '';
                    LET vNombProdDisp = '';
                END FOREACH;

                LET vCodigoEmp = '';
                LET vNombreEmp = '';
            END FOREACH;
        END IF;

        LET vNumCte       = '';
        LET vFechAltaCte  = '';
        LET vRazonSocial  = '';
        LET vSucursal     = '';
        LET vNombreSuc    = '';
        LET vEstado       = '';
        LET vCiudad       = '';
        LET vCuenta       = '';
        LET vProducto     = '';
        LET vNombreProd   = '';
        LET vStatusNomina = '';
        LET vNoDispMes    = 0;
        LET vComDisp      = 0.00;
        LET vComDisp1     = 0.00;
        LET vComDisp2     = 0.00;
    END FOREACH;

    UPDATE STATISTICS MEDIUM FOR TABLE sc_repmensualdispnomina;

    LET vQryStmt = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/repmensualnominaempnet_detalle_'||vFechaDesc||'.txt '||
                   'SELECT * FROM sc_repmensualdispnomina ORDER BY numcte, cuenta_eje;" > /resplogifx/conciliachq/repmennomidet.sql';
    SYSTEM vQryStmt;
    LET vQrySql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/repmennomidet.sql";
	--LET vQrySql = "dbaccess bdicheq /resplogifx/conciliachq/repmennomidet.sql";
    SYSTEM vQrySql;
 
    LET vCodRet1 = '000';
    LET vCodRet2 = '000';
    LET vCodRet3 = 'PROCESO REALIZADO SATISFACTORIAMENTE';

    -- // REGISTRA LA FINALIZACION DEL PROCESO
    LET vQryStmt = 'echo "UPDATE sx_contproc SET status_proc = '''||'F'||''', codret = '''||vCodRet1||''', hora_fin = current WHERE sistema = ''01'' AND proceso = ''GenInfMenNomina'' AND fecha = '''||vFechaHoy||''';" > /resplogifx/conciliachq/infmennomina.sql';
    SYSTEM vQryStmt;
    LET vQrySql = '/ifxsif01/bin/dbaccess bdinteg /resplogifx/conciliachq/infmennomina.sql';
	--LET vQrySql = 'dbaccess bdinteg /resplogifx/conciliachq/infmennomina.sql';
    SYSTEM vQrySql;

	END;

    RETURN vCodRet1, vCodRet2, vCodRet3;

END PROCEDURE;