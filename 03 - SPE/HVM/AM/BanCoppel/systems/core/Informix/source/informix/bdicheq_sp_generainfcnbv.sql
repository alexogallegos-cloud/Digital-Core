CREATE PROCEDURE "informix".sp_generainfcnbv( pEmpresa char(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER;
      
    DEFINE Sql_Err              INTEGER;
    DEFINE Isam_Err             INTEGER;
    DEFINE Desc_Err             CHAR(50);
    DEFINE vCodRet1             CHAR(5);
    DEFINE vCodRet2             CHAR(5);
    DEFINE vCodRet3             CHAR(50);
    DEFINE vComienza            INTEGER;
    DEFINE vEnTransacc          SMALLINT;
    DEFINE vContador1           INTEGER;
    DEFINE vsql                 CHAR(500);
    DEFINE vstmt                CHAR(200);
    DEFINE vfecha               CHAR(8);
    DEFINE vFechaHoy            DATE;
    DEFINE vFechaIni            DATE;
    DEFINE vFechaFin            DATE;
    DEFINE vEmpresa             CHAR(40);
    DEFINE vCuenta              CHAR(20);
    DEFINE vNumCte              CHAR(20);
    DEFINE vFechaAlta           DATE;
    DEFINE vNomProducto         CHAR(40);
    DEFINE vTipoPer             CHAR(2);
    DEFINE vFechaNac            DATE;
    DEFINE vFechaNacim          CHAR(10);
    DEFINE vRegFiscal           CHAR(1);
    DEFINE vTipoDepositante     CHAR(4);
    DEFINE vTipoCta             CHAR(2);
    DEFINE vExsiteBPI           SMALLINT;
    DEFINE vBPI                 CHAR(1);
    DEFINE vNomina              CHAR(1);
    DEFINE vDeposito            CHAR(1);
    DEFINE vCheques             CHAR(1);
    DEFINE vExistePag           SMALLINT;
    DEFINE vAhorro              CHAR(1);
    DEFINE vExisteCred          SMALLINT;
    DEFINE vCredito             CHAR(1);
    DEFINE vContCasaBolsa       CHAR(1);
    DEFINE vContCompensacion    CHAR(1);
    DEFINE vContCustodiaValores CHAR(1);
    DEFINE vExisteDispNom       SMALLINT;
    DEFINE vContDispNom         CHAR(1);
    DEFINE vContConcentracion   CHAR(1);
    DEFINE vContGestionTeso     CHAR(1);
    DEFINE vOtrosContratos      CHAR(1);
    DEFINE vFechaApertura       CHAR(10);
    DEFINE vAseguradoIPAB       CHAR(1);
    DEFINE vMoneda              CHAR(1);
    DEFINE vTipoTasaInt         CHAR(1);
    DEFINE vDepositos           DECIMAL(18,2);
    DEFINE vCargos              DECIMAL(18,2);
    DEFINE vSdoInicial          DECIMAL(18,2);
    DEFINE vSdoFinal            DECIMAL(18,2);
    DEFINE vTasa                DECIMAL(9,6);
    DEFINE vPeriodo             CHAR(6);
    DEFINE vTasaInteres         DECIMAL(8,2);
    DEFINE vFechaConsMovhis     CHAR(10);
    DEFINE vFechaConsMovhisOld  CHAR(10);
    DEFINE vFechaConsMovhisOld2 CHAR(10);
    DEFINE vFechaConsMovhisOld3 CHAR(10);
    DEFINE vDepositosOld        DECIMAL(18,2);
    DEFINE vDepositosOld2       DECIMAL(18,2);
    DEFINE vDepositosOld3       DECIMAL(18,2);
    DEFINE vCargosOld           DECIMAL(18,2);
    DEFINE vCargosOld2          DECIMAL(18,2);
    DEFINE vCargosOld3          DECIMAL(18,2);
    DEFINE vAnio                CHAR(4);
    DEFINE vMes                 CHAR(2);
    DEFINE vExisteInvCrec       INTEGER;
    DEFINE vExisteNomina        INTEGER;
    DEFINE vTasaOld3            DECIMAL(9,6);
    DEFINE vTasaOld2            DECIMAL(9,6);
    DEFINE vTasaOld             DECIMAL(9,6);
    DEFINE vNumero              INTEGER;
    DEFINE vSumaTasas           DECIMAL(8,2);
    DEFINE vCuantos             INTEGER;
    DEFINE vIndice              INTEGER;
    DEFINE vTasaa               DECIMAL(8,2);
    DEFINE vTasa1               DECIMAL(8,2);
    DEFINE vTasa2               DECIMAL(8,2);

    LET Sql_Err	             = 0;
    LET Isam_Err             = 0;
    LET Desc_Err             = '';
    LET vCodRet1             = '000';
    LET vCodRet2             = '000';
    LET vCodRet3             = 'PROCESO FINALIZADO CORRECTAMENTE';
    LET vComienza            = -1;
    LET vEnTransacc          = 0;
    LET vContador1           = 0;
    LET vsql                 = '';
    LET vstmt                = '';
    LET vfecha               = '';
    LET vFechaHoy            = '';
    LET vFechaIni            = '07/01/2009';
    LET vFechaFin            = '12/31/2011';
    LET vEmpresa             = '';
    LET vCuenta              = '';   
    LET vNumCte              = '';
    LET vFechaAlta           = '';
    LET vNomProducto         = '';
    LET vTipoPer             = '';
    LET vFechaNac            = '';
    LET vFechaNacim          = '';
    LET vRegFiscal           = '';
    LET vTipoDepositante     = '';
    LET vTipoCta             = 'CI';
    LET vExsiteBPI           = 0;
    LET vBPI                 = '';
    LET vNomina              = '';
    LET vDeposito            = '1';
    LET vCheques             = '0';
    LET vExistePag           = 0;
    LET vAhorro              = '';
    LET vExisteCred          = 0;
    LET vCredito             = '';
    LET vContCasaBolsa       = '0';
    LET vContCompensacion    = '0';
    LET vContCustodiaValores = '0';
    LET vExisteDispNom       = 0;
    LET vContDispNom         = '';
    LET vContConcentracion   = '0';
    LET vContGestionTeso     = '0';
    LET vOtrosContratos      = '0';
    LET vFechaApertura       = '';
    LET vAseguradoIPAB       = '1';
    LET vMoneda              = 'P';
    LET vTipoTasaInt         = 'F';
    LET vDepositos           = 0.00;
    LET vCargos              = 0.00;
    LET vSdoInicial          = 0.00;
    LET vSdoFinal            = 0.00;
    LET vTasa                = 0;
    LET vPeriodo             = '';
    LET vTasaInteres         = 0;
    LET vFechaConsMovhis     = '';
    LET vFechaConsMovhisOld  = '';
    LET vFechaConsMovhisOld2 = '';
    LET vFechaConsMovhisOld3 = ''; 
    LET vDepositosOld        = 0.00;
    LET vDepositosOld2       = 0.00;
    LET vDepositosOld3       = 0.00;
    LET vCargosOld           = 0.00;
    LET vCargosOld2          = 0.00;
    LET vCargosOld3          = 0.00;
    LET vAnio                = '';
    LET vMes                 = '';
    LET vExisteInvCrec       = 0;
    LET vExisteNomina        = 0;
    LET vTasaOld3            = 0;
    LET vTasaOld2            = 0;
    LET vTasaOld             = 0;
    LET vNumero              = 0;
    LET vSumaTasas           = 0;
    LET vCuantos             = 0;
    LET vIndice              = 0;
    LET vTasaa               = 0;
    LET vTasa1               = 0;
    LET vTasa2               = 0;
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_generainfcnbv.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            RETURN vCodRet1, vCodRet2, vCodRet3, vContador1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_generainfcnbv.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // TABLA PARA REPORTAR LAS CUENTAS POR INFORMAR
    CREATE TEMP TABLE repctasxinformar(
        empresa     char(30)    not null,
        num_cte     char(20)    not null,
        fecha_nac   char(10),    
        reg_fiscal  char(1),
        tpo_dep     char(4),
        tpo_cuenta  char(2),
        producto    char(40),
        bancaxint   char(1),
        nomina      char(1),
        deposito    char(1),
        cheques     char(1),
        ahorro      char(1),
        credito     char(1),
        bolsa       char(1),
        compensa    char(1),
        valores     char(1),
        dispersion  char(1),
        fondos      char(1),
        tesoreria   char(1),
        otros       char(1),
        fecha_alta  char(10),
        ipab        char(1),
        moneda      char(1),
        tasa        char(1) ) WITH NO LOG;
    CREATE INDEX idx_repctaxinf ON repctasxinformar(num_cte) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE repctasxinformar;
    
    -- // TABLA PARA REPORTAR LAS CUENTAS POR INFORMAR
    CREATE TEMP TABLE repsdosctasxinformar(
        periodo     char(6)     not null,
        empresa     char(40)    not null,
        num_cte     char(20)    not null,
        sdo_minimo  decimal(4,2),
        abonos      decimal(18,2),
        cargos      decimal(18,2),
        sdo_inicial decimal(18,2), 
        sdo_final   decimal(18,2),  
        tasa        decimal(6,2) ) WITH NO LOG;
    CREATE INDEX idx_repsdoctaxinf ON repsdosctasxinformar(num_cte) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE repsdosctasxinformar;
    
    -- // TABLA PARA REPORTAR LAS CUENTAS POR INFORMAR
    CREATE TEMP TABLE tmp_periodos( periodo char(6) not null ) WITH NO LOG;
    INSERT INTO tmp_periodos VALUES('200907'); INSERT INTO tmp_periodos VALUES('200908'); INSERT INTO tmp_periodos VALUES('200909'); 
    INSERT INTO tmp_periodos VALUES('200910'); INSERT INTO tmp_periodos VALUES('200911'); INSERT INTO tmp_periodos VALUES('200912'); 
    INSERT INTO tmp_periodos VALUES('201001'); INSERT INTO tmp_periodos VALUES('201002'); INSERT INTO tmp_periodos VALUES('201003'); 
    INSERT INTO tmp_periodos VALUES('201004'); INSERT INTO tmp_periodos VALUES('201005'); INSERT INTO tmp_periodos VALUES('201006');
    INSERT INTO tmp_periodos VALUES('201007'); INSERT INTO tmp_periodos VALUES('201008'); INSERT INTO tmp_periodos VALUES('201009'); 
    INSERT INTO tmp_periodos VALUES('201010'); INSERT INTO tmp_periodos VALUES('201011'); INSERT INTO tmp_periodos VALUES('201012'); 
    INSERT INTO tmp_periodos VALUES('201101'); INSERT INTO tmp_periodos VALUES('201102'); INSERT INTO tmp_periodos VALUES('201103'); 
    INSERT INTO tmp_periodos VALUES('201104'); INSERT INTO tmp_periodos VALUES('201105'); INSERT INTO tmp_periodos VALUES('201106');
    INSERT INTO tmp_periodos VALUES('201107'); INSERT INTO tmp_periodos VALUES('201108'); INSERT INTO tmp_periodos VALUES('201109'); 
    INSERT INTO tmp_periodos VALUES('201110'); INSERT INTO tmp_periodos VALUES('201111'); INSERT INTO tmp_periodos VALUES('201112');
    CREATE INDEX idx_periodoctaxinf ON tmp_periodos(periodo) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_periodos;
    
    -- // OBTINENE LA FECHA DE HOY
    SELECT fecha_hoy
      INTO vFechaHoy
      FROM bdicheq:"informix".sc_fechas
     WHERE empresa = pEmpresa;
     
    -- // OBTIENE EL NOMBRE DE LA EMPRESA
    SELECT razon_social
      INTO vEmpresa
      FROM bdinteg:"informix".si_empresas
     WHERE empresa = pEmpresa;
     
    -- // OBTIENE FECHAS PARA LAS CONSULTAS EN HISTORICOS
    SELECT valor
      INTO vFechaConsMovhis
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'fechcon_movhis';

    SELECT valor
      INTO vFechaConsMovhisOld
      FROM bdicheq:sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'FechIniCon_movhis_ol';

    SELECT valor
      INTO vFechaConsMovhisOld2
      FROM bdicheq:sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'FechaIniMovhisOld2';
       
    SELECT valor
      INTO vFechaConsMovhisOld3
      FROM bdicheq:sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'vfechconmovhisold3';
       
    FOREACH 
        SELECT ctes.num_cte, cte.tpo_persona, cte.fecha_insert, pf.fecha_nac 
          INTO vNumCte, vTipoPer, vFechaAlta, vFechaNac 
          FROM bdicheq:"informix".ctesxinformar ctes,
               bdinteg:"informix".si_cliente cte,
               bdinteg:"informix".si_ctepf pf
         WHERE ctes.num_cte = cte.numcte
           AND cte.numcte = pf.numcte
           
        -- // FECHA DE NACIMIENTO
        LET vFechaNacim = TO_CHAR(vFechaNac, '%Y%m%d');
        
        -- // FECHA DE ALTA
        LET vFechaApertura = TO_CHAR(vFechaAlta, '%Y%m%d');
        
        -- // REGIMEN FISCAL Y TIPO DE DEPOSITANTE
        IF vTipoPer IN('01') THEN
            LET vRegFiscal = 'F';
            LET vTipoDepositante = 'PF';
        ELIF vTipoPer IN('03') THEN
            LET vRegFiscal = 'F';
            LET vTipoDepositante = 'PFAE';
        ELIF vTipoPer IN('02') THEN
            LET vRegFiscal = 'M';
            LET vTipoDepositante = 'PyME';
        ELIF vTipoPer IN('04') THEN
            LET vRegFiscal = 'M';
            LET vTipoDepositante = 'PyME';
        END IF;
        
        -- // VALIDA CUAL ES EL NOMBRE DEL PRODUCTO
        SELECT COUNT(*)
          INTO vExisteInvCrec
          FROM bdicheq:"informix".sc_maechq mae,
               bdicheq:"informix".sc_maenoc noc
         WHERE mae.num_cte = vNumCte
           AND mae.producto = '1100'
           AND mae.fecultdep BETWEEN vFechaIni AND vFechaFin
           AND noc.empresa = mae.empresa
           AND noc.cuenta = mae.cuenta;
           
        IF vExisteInvCrec > 0 THEN
            LET vNomProducto = 'INVERSION CRECIENTE';
        ELSE
            LET vNomProducto = 'CUENTA EFECTIVA';
        END IF;
           
        -- // VALIDA DE TENIA SERVICIO POR INTERNET
        SELECT COUNT(*)
          INTO vExsiteBPI
          FROM bdinteg:"informix".si_bpiusuarios
         WHERE numcte = vNumCte
           AND f_registro BETWEEN vFechaIni AND vFechaFin;
         
        IF vExsiteBPI > 0 THEN
            LET vBPI = '1';
        ELSE
            LET vBPI = '0';
        END IF;
        
        -- // VERIFICA SI TIENE CUENTAS DE NOMINA
        SELECT COUNT(*)
          INTO vExisteNomina
          FROM bdicheq:"informix".sc_maechq mae,
               bdicheq:"informix".sc_maenoc noc
         WHERE mae.num_cte = vNumCte
           AND mae.producto = '1300'
           AND mae.status_cta NOT IN("4", "5")
           AND noc.empresa = mae.empresa
           AND noc.cuenta = mae.cuenta
           AND noc.fecha_alta BETWEEN vFechaIni AND vFechaFin;
         
        IF vExisteNomina > 0 THEN
            LET vNomina = '1';
            LET vNomProducto = 'NOMINA';
        ELSE
            LET vNomina = '0';
        END IF;
        
        -- // VALIDA SI TENIA PAGARES 
        SELECT COUNT(*)
          INTO vExistePag
          FROM bdinvers:"informix".sv_maeinv
         WHERE num_cte = vNumCte
           AND fecha_alta BETWEEN vFechaIni AND vFechaFin;
         
        IF vExistePag > 0 THEN
            LET vAhorro = '1';
        ELSE
            LET vAhorro = '0';
        END IF;
        
        -- // VALIDA SI TENIA CREDITOS
        SELECT COUNT(*)
          INTO vExisteCred
          FROM bdicred:"informix".sd_maecred
         WHERE numcte = vNumCte
           AND fecha_apertura BETWEEN vFechaIni AND vFechaFin;
         
        IF vExisteCred > 0 THEN
            LET vCredito = '1';
        ELSE
            LET vCredito = '0';
        END IF;
        
        -- // VALIDA SI TENIA CONTRATADO SERVICIO DE DISPERSION DE NOMINA
        SELECT COUNT(*)
          INTO vExisteDispNom  
          FROM bdicheq:"informix".sc_nominaempresas
         WHERE numcte = vNumCte;
         
        IF vExisteDispNom > 0 THEN
            LET vContDispNom = '1';
        ELSE
            LET vContDispNom = '0';
        END IF;
        
        CREATE TEMP TABLE tmp_ctasxinf ( cuenta char(20) not null ) WITH NO LOG;
        
        INSERT INTO tmp_ctasxinf
        SELECT mae.cuenta
          FROM bdicheq:"informix".sc_maechq mae,
               bdicheq:"informix".sc_maenoc noc
         WHERE mae.num_cte = vNumCte
           AND mae.status_cta NOT IN("4", "5")
           AND mae.producto IN('1200','1300','1600','2000')
           AND noc.empresa = mae.empresa
           AND noc.cuenta = mae.cuenta
           AND noc.fecha_alta BETWEEN vFechaIni AND vFechaFin;
        
        INSERT INTO tmp_ctasxinf
        SELECT mae.cuenta
          FROM bdicheq:"informix".sc_maechq mae,
               bdicheq:"informix".sc_maenoc noc
         WHERE mae.num_cte = vNumCte
           AND mae.producto = '1100'
           AND mae.fecultdep BETWEEN vFechaIni AND vFechaFin
           AND noc.empresa = mae.empresa
           AND noc.cuenta = mae.cuenta;
           
        CREATE INDEX idx_tmpctaxinform ON tmp_ctasxinf(cuenta) USING BTREE;
        UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctasxinf;
        
        FOREACH 
            SELECT periodo
              INTO vPeriodo
              FROM tmp_periodos
             ORDER BY periodo
                 
            LET vAnio = SUBSTR(vPeriodo, 1, 4);
            LET vMes  = SUBSTR(vPeriodo, 5, 2);
        
            IF vAnio = '2009' THEN
                IF vMes = '07' THEN
                    SELECT SUM(NVL(capvig30, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc2009 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '08' THEN
                    SELECT SUM(NVL(capvig31, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc2009 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '09' THEN
                    SELECT SUM(NVL(capvig31, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc2009 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '10' THEN
                    SELECT SUM(NVL(capvig30, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc2009 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '11' THEN
                    SELECT SUM(NVL(capvig31, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc2009 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '12' THEN
                    SELECT SUM(NVL(capvig30, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc2009 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                END IF;
            ELIF vAnio = '2010' THEN
                IF vMes = '01' THEN
                    SELECT SUM(NVL(capvig31, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc2009 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = '200912';
                ELIF vMes = '02' THEN
                    SELECT SUM(NVL(capvig31, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc2010 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '03' THEN
                    SELECT SUM(NVL(capvig28, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc2010 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '04' THEN
                    SELECT SUM(NVL(capvig31, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc2010 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '05' THEN
                    SELECT SUM(NVL(capvig30, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc2010 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '06' THEN
                    SELECT SUM(NVL(capvig31, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc2010 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '07' THEN
                    SELECT SUM(NVL(capvig30, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc2010 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '08' THEN
                    SELECT SUM(NVL(capvig31, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc2010 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '09' THEN
                    SELECT SUM(NVL(capvig31, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc2010 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '10' THEN
                    SELECT SUM(NVL(capvig30, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc2010 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '11' THEN
                    SELECT SUM(NVL(capvig31, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc2010 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '12' THEN
                    SELECT SUM(NVL(capvig30, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc2010 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                END IF;
            ELIF vAnio = '2011' THEN
                IF vMes = '01' THEN
                    SELECT SUM(NVL(capvig31, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc2010 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = '201012';
                ELIF vMes = '02' THEN
                    SELECT SUM(NVL(capvig31, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc_2011 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '03' THEN
                    SELECT SUM(NVL(capvig28, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc_2011 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '04' THEN
                    SELECT SUM(NVL(capvig31, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc_2011 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '05' THEN
                    SELECT SUM(NVL(capvig30, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc_2011 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '06' THEN
                    SELECT SUM(NVL(capvig31, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc_2011 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '07' THEN
                    SELECT SUM(NVL(capvig30, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc_2011 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '08' THEN
                    SELECT SUM(NVL(capvig31, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc_2011 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '09' THEN
                    SELECT SUM(NVL(capvig31, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc_2011 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '10' THEN
                    SELECT SUM(NVL(capvig30, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc_2011 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '11' THEN
                    SELECT SUM(NVL(capvig31, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc_2011 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '12' THEN
                    SELECT SUM(NVL(capvig30, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc_2011 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                END IF;
            END IF;
            
            IF vSdoInicial is null THEN
                LET vSdoInicial = 0;
            END IF;
           
            -- // ABONOS 
            SELECT NVL(SUM(a.monto_tot), 0)
              INTO vDepositosOld3
              FROM bdicheq:"informix".sc_movhis_old3 a,
                   bdinteg:"informix".si_transacc b
             WHERE a.empresa = pEmpresa
               AND a.cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
               AND a.fech_alt >= vFechaConsMovhisOld3
               AND a.fech_alt < vFechaConsMovhisOld2
               AND YEAR(a.fech_alt) = vAnio
               AND MONTH(a.fech_alt) = vMes
               AND a.cancelad <> 'S'
               AND a.transacc = b.numero
               AND b.se_emite_edocta = 'S'
               AND b.naturaleza = 'A'
               AND b.numero <> '0250';
               
            IF vDepositosOld3 is null THEN
                LET vDepositosOld3 = 0;
            END IF;
                   
            SELECT NVL(SUM(a.monto_tot), 0)
              INTO vDepositosOld2
              FROM bdicheq:"informix".sc_movhis_old2 a,
                   bdinteg:"informix".si_transacc b
             WHERE a.empresa = pEmpresa
               AND a.cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
               AND a.fech_alt >= vFechaConsMovhisOld2
               AND a.fech_alt < vFechaConsMovhisOld
               AND YEAR(a.fech_alt) = vAnio
               AND MONTH(a.fech_alt) = vMes
               AND a.cancelad <> 'S'
               AND a.transacc = b.numero
               AND b.se_emite_edocta = 'S'
               AND b.naturaleza = 'A'
               AND b.numero <> '0250';
               
            IF vDepositosOld2 is null THEN
                LET vDepositosOld2 = 0;
            END IF;
               
            SELECT NVL(SUM(a.monto_tot), 0)
              INTO vDepositosOld
              FROM bdicheq:"informix".sc_movhis_old a,
                   bdinteg:"informix".si_transacc b
             WHERE a.empresa = pEmpresa
               AND a.cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
               AND a.fech_alt >= vFechaConsMovhisOld
               AND a.fech_alt < vFechaFin
               AND YEAR(a.fech_alt) = vAnio
               AND MONTH(a.fech_alt) = vMes
               AND a.cancelad <> 'S'
               AND a.transacc = b.numero
               AND b.se_emite_edocta = 'S'
               AND b.naturaleza = 'A'
               AND b.numero <> '0250';
               
            IF vDepositosOld is null THEN
                LET vDepositosOld = 0;
            END IF;
            
            LET vDepositos = vDepositosOld + vDepositosOld2 + vDepositosOld3;
               
            -- // CARGOS 
            SELECT NVL(SUM(a.monto_tot), 0)
              INTO vCargosOld3
              FROM bdicheq:"informix".sc_movhis_old3 a,
                   bdinteg:"informix".si_transacc b
             WHERE a.empresa = pEmpresa
               AND a.cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
               AND a.fech_alt >= vFechaConsMovhisOld3
               AND a.fech_alt < vFechaConsMovhisOld2
               AND YEAR(a.fech_alt) = vAnio
               AND MONTH(a.fech_alt) = vMes
               AND a.cancelad <> 'S'
               AND a.transacc = b.numero
               AND b.se_emite_edocta = 'S'
               AND b.naturaleza = 'C'
               AND b.numero <> '0232';
               
            IF vCargosOld3 is null THEN
                LET vCargosOld3 = 0;
            END IF;
               
            SELECT NVL(SUM(a.monto_tot), 0)
              INTO vCargosOld2
              FROM bdicheq:"informix".sc_movhis_old2 a,
                   bdinteg:"informix".si_transacc b
             WHERE a.empresa = pEmpresa
               AND a.cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
               AND a.fech_alt >= vFechaConsMovhisOld2
               AND a.fech_alt < vFechaConsMovhisOld
               AND YEAR(a.fech_alt) = vAnio
               AND MONTH(a.fech_alt) = vMes
               AND a.cancelad <> 'S'
               AND a.transacc = b.numero
               AND b.se_emite_edocta = 'S'
               AND b.naturaleza = 'C'
               AND b.numero <> '0232';
               
            IF vCargosOld2 is null THEN
                LET vCargosOld2 = 0;
            END IF;
               
            SELECT NVL(SUM(a.monto_tot), 0)
              INTO vCargosOld
              FROM bdicheq:"informix".sc_movhis_old a,
                   bdinteg:"informix".si_transacc b
             WHERE a.empresa = pEmpresa
               AND a.cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
               AND a.fech_alt >= vFechaConsMovhisOld
               AND a.fech_alt < vFechaFin
               AND YEAR(a.fech_alt) = vAnio
               AND MONTH(a.fech_alt) = vMes
               AND a.cancelad <> 'S'
               AND a.transacc = b.numero
               AND b.se_emite_edocta = 'S'
               AND b.naturaleza = 'C'
               AND b.numero <> '0232';
               
            IF vCargosOld is null THEN
                LET vCargosOld = 0;
            END IF;
               
            LET vCargos = vCargosOld3 + vCargosOld2 + vCargosOld;
            LET vSdoFinal = ((vSdoInicial + vDepositos) - vCargos);
            
            CREATE TEMP TABLE tmp_tasas( numero integer not null, tasa decimal(6,2) not null ) WITH NO LOG;
            CREATE TEMP TABLE tmp_tasas2( numero integer not null, tasa decimal(6,2) not null ) WITH NO LOG;
            
            LET vNumero = 0;
            
            FOREACH
                SELECT cuenta
                  INTO vCuenta
                  FROM tmp_ctasxinf
                  
                SELECT NVL(SUM(tasa_aplicada), 0)
                  INTO vTasaOld3
                  FROM bdicheq:"informix".sc_movhis_old3
                 WHERE empresa = pEmpresa
                   AND cuenta = vCuenta
                   AND fech_alt >= vFechaConsMovhisOld3
                   AND fech_alt < vFechaConsMovhisOld2
                   AND YEAR(fech_alt) = vAnio
                   AND MONTH(fech_alt) = vMes
                   AND cancelad <> 'S'
                   AND transacc = '3276';
                   
                SELECT NVL(SUM(tasa_aplicada), 0)
                  INTO vTasaOld2
                  FROM bdicheq:"informix".sc_movhis_old2
                 WHERE empresa = pEmpresa
                   AND cuenta = vCuenta
                   AND fech_alt >= vFechaConsMovhisOld2
                   AND fech_alt < vFechaConsMovhisOld
                   AND YEAR(fech_alt) = vAnio
                   AND MONTH(fech_alt) = vMes
                   AND cancelad <> 'S'
                   AND transacc = '3276';
                   
                SELECT NVL(SUM(tasa_aplicada), 0)
                  INTO vTasaOld
                  FROM bdicheq:"informix".sc_movhis_old
                 WHERE empresa = pEmpresa
                   AND cuenta = vCuenta
                   AND fech_alt >= vFechaConsMovhisOld
                   AND fech_alt < vFechaFin
                   AND YEAR(fech_alt) = vAnio
                   AND MONTH(fech_alt) = vMes
                   AND cancelad <> 'S'
                   AND transacc = '3276';
                   
                IF vTasaOld3 is null THEN
                    LET vTasaOld3 = 0;
                END IF;
                
                IF vTasaOld2 is null THEN
                    LET vTasaOld2 = 0;
                END IF;
                
                IF vTasaOld is null THEN
                    LET vTasaOld = 0;
                END IF;
                   
                LET vTasa = vTasaOld3 + vTasaOld2 + vTasaOld;
                LET vTasa = vTasa * 100;
                LET vNumero = vNumero + 1;
                
                INSERT INTO tmp_tasas VALUES(vNumero, vTasa);
            END FOREACH;
            
            CREATE INDEX idx_tmptasauno ON tmp_tasas(numero) USING BTREE;
            UPDATE STATISTICS MEDIUM FOR TABLE tmp_tasas;
            
            SELECT SUM(tasa)
              INTO vSumaTasas
              FROM tmp_tasas;
                  
            SELECT COUNT(*)
              INTO vCuantos
              FROM tmp_tasas;
              
            LET vIndice = 1;
            
            WHILE vIndice <= vCuantos 
                SELECT tasa
                  INTO vTasaa
                  FROM tmp_tasas
                 WHERE numero = vIndice;
                
                IF vSumaTasas > 0 THEN
                    LET vTasa1 = vTasaa / vSumaTasas;
                ELSE
                    LET vTasa1 = 0;
                END IF;
                
                LET vTasa2 = vTasa1 * vIndice;
                INSERT INTO tmp_tasas2 VALUES(vIndice, vTasa2);
                LET vIndice = vIndice + 1;
            END WHILE; 
            
            CREATE INDEX idx_tmptasados ON tmp_tasas2(numero) USING BTREE;
            UPDATE STATISTICS MEDIUM FOR TABLE tmp_tasas2;
            
            SELECT SUM(tasa)
              INTO vTasaInteres
              FROM tmp_tasas2;
            
            INSERT INTO repsdosctasxinformar(periodo, empresa, num_cte, sdo_minimo, abonos, cargos, sdo_inicial, sdo_final,  tasa)
            VALUES(vPeriodo, vEmpresa, vNumCte, 0.00, vDepositos, vCargos, vSdoInicial, vSdoFinal, vTasaInteres);
            
            DROP TABLE tmp_tasas;
            DROP TABLE tmp_tasas2;
        END FOREACH;
            
        -- // GUARDA DATOS EN TABLA PARA DESCARGARLOS
        INSERT INTO repctasxinformar VALUES
        (vEmpresa, vNumCte, vFechaNacim, vRegFiscal, vTipoDepositante, vTipoCta, vNomProducto, vBPI, vNomina, vDeposito, vCheques, vAhorro, vCredito, vContCasaBolsa, 
         vContCompensacion, vContCustodiaValores, vContDispNom, vContConcentracion, vContGestionTeso, vOtrosContratos, vFechaApertura, vAseguradoIPAB, vMoneda, vTipoTasaInt);
         
        DROP TABLE tmp_ctasxinf;
        LET vContador1 = vContador1 + 1;
    END FOREACH;
    
    FOREACH
        SELECT ctes.num_cte, cte.tpo_persona, cte.fecha_insert, pm.fecha_constitct 
          INTO vNumCte, vTipoPer, vFechaAlta, vFechaNac 
          FROM bdicheq:"informix".ctesxinformar ctes,
               bdinteg:"informix".si_cliente cte,
               bdinteg:"informix".si_ctepm pm
         WHERE ctes.num_cte = cte.numcte
           AND cte.numcte = pm.numcte
        
        -- // FECHA DE NACIMIENTO
        IF vFechaNac IS NOT NULL THEN
            LET vFechaNacim = TO_CHAR(vFechaNac, '%Y%m%d');
        ELSE
            LET vFechaNacim = '';
        END IF;
        
        -- // FECHA DE ALTA
        LET vFechaApertura = TO_CHAR(vFechaAlta, '%Y%m%d');
        
        -- // REGIMEN FISCAL Y TIPO DE DEPOSITANTE
        IF vTipoPer IN('01') THEN
            LET vRegFiscal = 'F';
            LET vTipoDepositante = 'PF';
        ELIF vTipoPer IN('03') THEN
            LET vRegFiscal = 'F';
            LET vTipoDepositante = 'PFAE';
        ELIF vTipoPer IN('02') THEN
            LET vRegFiscal = 'M';
            LET vTipoDepositante = 'PyME';
        ELIF vTipoPer IN('04') THEN
            LET vRegFiscal = 'M';
            LET vTipoDepositante = 'PyME';
        END IF;
        
        -- // VALIDA CUAL ES EL NOMBRE DEL PRODUCTO
        SELECT COUNT(*)
          INTO vExisteInvCrec
          FROM bdicheq:"informix".sc_maechq mae,
               bdicheq:"informix".sc_maenoc noc
         WHERE mae.num_cte = vNumCte
           AND mae.producto = '1100'
           AND mae.fecultdep BETWEEN vFechaIni AND vFechaFin
           AND noc.empresa = mae.empresa
           AND noc.cuenta = mae.cuenta;
           
        IF vExisteInvCrec > 0 THEN
            LET vNomProducto = 'INVERSION CRECIENTE';
        ELSE
            LET vNomProducto = 'CUENTA EFECTIVA';
        END IF;
           
        -- // VALIDA DE TENIA SERVICIO POR INTERNET
        SELECT COUNT(*)
          INTO vExsiteBPI
          FROM bdinteg:"informix".si_bpiusuarios
         WHERE numcte = vNumCte
           AND f_registro BETWEEN vFechaIni AND vFechaFin;
         
        IF vExsiteBPI > 0 THEN
            LET vBPI = '1';
        ELSE
            LET vBPI = '0';
        END IF;
        
        -- // VERIFICA SI TIENE CUENTAS DE NOMINA
        SELECT COUNT(*)
          INTO vExisteNomina
          FROM bdicheq:"informix".sc_maechq mae,
               bdicheq:"informix".sc_maenoc noc
         WHERE mae.num_cte = vNumCte
           AND mae.producto = '1300'
           AND mae.status_cta NOT IN("4", "5")
           AND noc.empresa = mae.empresa
           AND noc.cuenta = mae.cuenta
           AND noc.fecha_alta BETWEEN vFechaIni AND vFechaFin;
         
        IF vExisteNomina > 0 THEN
            LET vNomina = '1';
            LET vNomProducto = 'NOMINA';
        ELSE
            LET vNomina = '0';
        END IF;
        
        -- // VALIDA SI TENIA PAGARES 
        SELECT COUNT(*)
          INTO vExistePag
          FROM bdinvers:"informix".sv_maeinv
         WHERE num_cte = vNumCte
           AND fecha_alta BETWEEN vFechaIni AND vFechaFin;
         
        IF vExistePag > 0 THEN
            LET vAhorro = '1';
        ELSE
            LET vAhorro = '0';
        END IF;
        
        -- // VALIDA SI TENIA CREDITOS
        SELECT COUNT(*)
          INTO vExisteCred
          FROM bdicred:"informix".sd_maecred
         WHERE numcte = vNumCte
           AND fecha_apertura BETWEEN vFechaIni AND vFechaFin;
         
        IF vExisteCred > 0 THEN
            LET vCredito = '1';
        ELSE
            LET vCredito = '0';
        END IF;
        
        -- // VALIDA SI TENIA CONTRATADO SERVICIO DE DISPERSION DE NOMINA
        SELECT COUNT(*)
          INTO vExisteDispNom  
          FROM bdicheq:"informix".sc_nominaempresas
         WHERE numcte = vNumCte;
         
        IF vExisteDispNom > 0 THEN
            LET vContDispNom = '1';
        ELSE
            LET vContDispNom = '0';
        END IF;
        
        CREATE TEMP TABLE tmp_ctasxinf( cuenta char(20) not null ) WITH NO LOG;
        
        INSERT INTO tmp_ctasxinf
        SELECT mae.cuenta
          FROM bdicheq:"informix".sc_maechq mae,
               bdicheq:"informix".sc_maenoc noc
         WHERE mae.num_cte = vNumCte
           AND mae.status_cta NOT IN("4", "5")
           AND mae.producto IN('1200','1300','1600','2000')
           AND noc.empresa = mae.empresa
           AND noc.cuenta = mae.cuenta
           AND noc.fecha_alta BETWEEN vFechaIni AND vFechaFin;
        
        INSERT INTO tmp_ctasxinf
        SELECT mae.cuenta
          FROM bdicheq:"informix".sc_maechq mae,
               bdicheq:"informix".sc_maenoc noc
         WHERE mae.num_cte = vNumCte
           AND mae.producto = '1100'
           AND mae.fecultdep BETWEEN vFechaIni AND vFechaFin
           AND noc.empresa = mae.empresa
           AND noc.cuenta = mae.cuenta;
           
        CREATE INDEX idx_tmpctaxinform ON tmp_ctasxinf(cuenta) USING BTREE;
        UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctasxinf;
        
        FOREACH 
            SELECT periodo
              INTO vPeriodo
              FROM tmp_periodos
             ORDER BY periodo
                 
            LET vAnio = SUBSTR(vPeriodo, 1, 4);
            LET vMes  = SUBSTR(vPeriodo, 5, 2);
        
            IF vAnio = '2009' THEN
                IF vMes = '07' THEN
                    SELECT SUM(NVL(capvig30, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc2009 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '08' THEN
                    SELECT SUM(NVL(capvig31, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc2009 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '09' THEN
                    SELECT SUM(NVL(capvig31, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc2009 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '10' THEN
                    SELECT SUM(NVL(capvig30, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc2009 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '11' THEN
                    SELECT SUM(NVL(capvig31, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc2009 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '12' THEN
                    SELECT SUM(NVL(capvig30, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc2009 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                END IF;
            ELIF vAnio = '2010' THEN
                IF vMes = '01' THEN
                    SELECT SUM(NVL(capvig31, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc2009 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = '200912';
                ELIF vMes = '02' THEN
                    SELECT SUM(NVL(capvig31, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc2010 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '03' THEN
                    SELECT SUM(NVL(capvig28, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc2010 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '04' THEN
                    SELECT SUM(NVL(capvig31, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc2010 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '05' THEN
                    SELECT SUM(NVL(capvig30, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc2010 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '06' THEN
                    SELECT SUM(NVL(capvig31, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc2010 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '07' THEN
                    SELECT SUM(NVL(capvig30, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc2010 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '08' THEN
                    SELECT SUM(NVL(capvig31, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc2010 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '09' THEN
                    SELECT SUM(NVL(capvig31, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc2010 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '10' THEN
                    SELECT SUM(NVL(capvig30, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc2010 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '11' THEN
                    SELECT SUM(NVL(capvig31, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc2010 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '12' THEN
                    SELECT SUM(NVL(capvig30, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc2010 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                END IF;
            ELIF vAnio = '2011' THEN
                IF vMes = '01' THEN
                    SELECT SUM(NVL(capvig31, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc2010 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = '201012';
                ELIF vMes = '02' THEN
                    SELECT SUM(NVL(capvig31, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc_2011 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '03' THEN
                    SELECT SUM(NVL(capvig28, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc_2011 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '04' THEN
                    SELECT SUM(NVL(capvig31, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc_2011 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '05' THEN
                    SELECT SUM(NVL(capvig30, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc_2011 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '06' THEN
                    SELECT SUM(NVL(capvig31, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc_2011 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '07' THEN
                    SELECT SUM(NVL(capvig30, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc_2011 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '08' THEN
                    SELECT SUM(NVL(capvig31, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc_2011 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '09' THEN
                    SELECT SUM(NVL(capvig31, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc_2011 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '10' THEN
                    SELECT SUM(NVL(capvig30, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc_2011 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '11' THEN
                    SELECT SUM(NVL(capvig31, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc_2011 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                ELIF vMes = '12' THEN
                    SELECT SUM(NVL(capvig30, 0))
                      INTO vSdoInicial
                      FROM bdicheq:"informix".sc_sdodiarioc_2011 
                     WHERE cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
                       AND aniomes = vPeriodo::integer - 1;
                END IF;
            END IF;
            
            IF vSdoInicial is null THEN
                LET vSdoInicial = 0;
            END IF;
           
            -- // ABONOS 
            SELECT NVL(SUM(a.monto_tot), 0)
              INTO vDepositosOld3
              FROM bdicheq:"informix".sc_movhis_old3 a,
                   bdinteg:"informix".si_transacc b
             WHERE a.empresa = pEmpresa
               AND a.cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
               AND a.fech_alt >= vFechaConsMovhisOld3
               AND a.fech_alt < vFechaConsMovhisOld2
               AND YEAR(a.fech_alt) = vAnio
               AND MONTH(a.fech_alt) = vMes
               AND a.cancelad <> 'S'
               AND a.transacc = b.numero
               AND b.se_emite_edocta = 'S'
               AND b.naturaleza = 'A'
               AND b.numero <> '0250';
               
            IF vDepositosOld3 is null THEN
                LET vDepositosOld3 = 0;
            END IF;
                   
            SELECT NVL(SUM(a.monto_tot), 0)
              INTO vDepositosOld2
              FROM bdicheq:"informix".sc_movhis_old2 a,
                   bdinteg:"informix".si_transacc b
             WHERE a.empresa = pEmpresa
               AND a.cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
               AND a.fech_alt >= vFechaConsMovhisOld2
               AND a.fech_alt < vFechaConsMovhisOld
               AND YEAR(a.fech_alt) = vAnio
               AND MONTH(a.fech_alt) = vMes
               AND a.cancelad <> 'S'
               AND a.transacc = b.numero
               AND b.se_emite_edocta = 'S'
               AND b.naturaleza = 'A'
               AND b.numero <> '0250';
               
            IF vDepositosOld2 is null THEN
                LET vDepositosOld2 = 0;
            END IF;
               
            SELECT NVL(SUM(a.monto_tot), 0)
              INTO vDepositosOld
              FROM bdicheq:"informix".sc_movhis_old a,
                   bdinteg:"informix".si_transacc b
             WHERE a.empresa = pEmpresa
               AND a.cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
               AND a.fech_alt >= vFechaConsMovhisOld
               AND a.fech_alt < vFechaFin
               AND YEAR(a.fech_alt) = vAnio
               AND MONTH(a.fech_alt) = vMes
               AND a.cancelad <> 'S'
               AND a.transacc = b.numero
               AND b.se_emite_edocta = 'S'
               AND b.naturaleza = 'A'
               AND b.numero <> '0250';
               
            IF vDepositosOld is null THEN
                LET vDepositosOld = 0;
            END IF;
            
            LET vDepositos = vDepositosOld + vDepositosOld2 + vDepositosOld3;
               
            -- // CARGOS 
            SELECT NVL(SUM(a.monto_tot), 0)
              INTO vCargosOld3
              FROM bdicheq:"informix".sc_movhis_old3 a,
                   bdinteg:"informix".si_transacc b
             WHERE a.empresa = pEmpresa
               AND a.cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
               AND a.fech_alt >= vFechaConsMovhisOld3
               AND a.fech_alt < vFechaConsMovhisOld2
               AND YEAR(a.fech_alt) = vAnio
               AND MONTH(a.fech_alt) = vMes
               AND a.cancelad <> 'S'
               AND a.transacc = b.numero
               AND b.se_emite_edocta = 'S'
               AND b.naturaleza = 'C'
               AND b.numero <> '0232';
               
            IF vCargosOld3 is null THEN
                LET vCargosOld3 = 0;
            END IF;
               
            SELECT NVL(SUM(a.monto_tot), 0)
              INTO vCargosOld2
              FROM bdicheq:"informix".sc_movhis_old2 a,
                   bdinteg:"informix".si_transacc b
             WHERE a.empresa = pEmpresa
               AND a.cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
               AND a.fech_alt >= vFechaConsMovhisOld2
               AND a.fech_alt < vFechaConsMovhisOld
               AND YEAR(a.fech_alt) = vAnio
               AND MONTH(a.fech_alt) = vMes
               AND a.cancelad <> 'S'
               AND a.transacc = b.numero
               AND b.se_emite_edocta = 'S'
               AND b.naturaleza = 'C'
               AND b.numero <> '0232';
               
            IF vCargosOld2 is null THEN
                LET vCargosOld2 = 0;
            END IF;
               
            SELECT NVL(SUM(a.monto_tot), 0)
              INTO vCargosOld
              FROM bdicheq:"informix".sc_movhis_old a,
                   bdinteg:"informix".si_transacc b
             WHERE a.empresa = pEmpresa
               AND a.cuenta IN(SELECT cuenta FROM tmp_ctasxinf)
               AND a.fech_alt >= vFechaConsMovhisOld
               AND a.fech_alt < vFechaFin
               AND YEAR(a.fech_alt) = vAnio
               AND MONTH(a.fech_alt) = vMes
               AND a.cancelad <> 'S'
               AND a.transacc = b.numero
               AND b.se_emite_edocta = 'S'
               AND b.naturaleza = 'C'
               AND b.numero <> '0232';
               
            IF vCargosOld is null THEN
                LET vCargosOld = 0;
            END IF;
               
            LET vCargos = vCargosOld3 + vCargosOld2 + vCargosOld;
            LET vSdoFinal = ((vSdoInicial + vDepositos) - vCargos);
            
            CREATE TEMP TABLE tmp_tasas( numero integer not null, tasa decimal(6,2) not null ) WITH NO LOG;
            CREATE TEMP TABLE tmp_tasas2( numero integer not null, tasa   decimal(6,2) not null ) WITH NO LOG;
            
            LET vNumero = 0;
            
            FOREACH
                SELECT cuenta
                  INTO vCuenta
                  FROM tmp_ctasxinf
                  
                SELECT NVL(SUM(tasa_aplicada), 0)
                  INTO vTasaOld3
                  FROM bdicheq:"informix".sc_movhis_old3
                 WHERE empresa = pEmpresa
                   AND cuenta = vCuenta
                   AND fech_alt >= vFechaConsMovhisOld3
                   AND fech_alt < vFechaConsMovhisOld2
                   AND YEAR(fech_alt) = vAnio
                   AND MONTH(fech_alt) = vMes
                   AND cancelad <> 'S'
                   AND transacc = '3276';
                   
                SELECT NVL(SUM(tasa_aplicada), 0)
                  INTO vTasaOld2
                  FROM bdicheq:"informix".sc_movhis_old2
                 WHERE empresa = pEmpresa
                   AND cuenta = vCuenta
                   AND fech_alt >= vFechaConsMovhisOld2
                   AND fech_alt < vFechaConsMovhisOld
                   AND YEAR(fech_alt) = vAnio
                   AND MONTH(fech_alt) = vMes
                   AND cancelad <> 'S'
                   AND transacc = '3276';
                   
                SELECT NVL(SUM(tasa_aplicada), 0)
                  INTO vTasaOld
                  FROM bdicheq:"informix".sc_movhis_old
                 WHERE empresa = pEmpresa
                   AND cuenta = vCuenta
                   AND fech_alt >= vFechaConsMovhisOld
                   AND fech_alt < vFechaFin
                   AND YEAR(fech_alt) = vAnio
                   AND MONTH(fech_alt) = vMes
                   AND cancelad <> 'S'
                   AND transacc = '3276';
                   
                IF vTasaOld3 is null THEN
                    LET vTasaOld3 = 0;
                END IF;
                
                IF vTasaOld2 is null THEN
                    LET vTasaOld2 = 0;
                END IF;
                
                IF vTasaOld is null THEN
                    LET vTasaOld = 0;
                END IF;
                   
                LET vTasa = vTasaOld3 + vTasaOld2 + vTasaOld;
                LET vTasa = vTasa * 100;
                LET vNumero = vNumero + 1;
                
                INSERT INTO tmp_tasas VALUES(vNumero, vTasa);
            END FOREACH;
            
            CREATE INDEX idx_tmptasauno ON tmp_tasas(numero) USING BTREE;
            UPDATE STATISTICS MEDIUM FOR TABLE tmp_tasas;
            
            SELECT SUM(tasa)
              INTO vSumaTasas
              FROM tmp_tasas;
                  
            SELECT COUNT(*)
              INTO vCuantos
              FROM tmp_tasas;
              
            LET vIndice = 1;
            
            WHILE vIndice <= vCuantos 
                SELECT tasa
                  INTO vTasaa
                  FROM tmp_tasas
                 WHERE numero = vIndice;
                
                IF vSumaTasas > 0 THEN
                    LET vTasa1 = vTasaa / vSumaTasas;
                ELSE
                    LET vTasa1 = 0;
                END IF;
                
                LET vTasa2 = vTasa1 * vIndice;
                INSERT INTO tmp_tasas2 VALUES(vIndice, vTasa2);
                LET vIndice = vIndice + 1;
            END WHILE; 
            
            CREATE INDEX idx_tmptasados ON tmp_tasas2(numero) USING BTREE;
            UPDATE STATISTICS MEDIUM FOR TABLE tmp_tasas2;
            
            SELECT SUM(tasa)
              INTO vTasaInteres
              FROM tmp_tasas2;
            
            INSERT INTO repsdosctasxinformar(periodo, empresa, num_cte, sdo_minimo, abonos, cargos, sdo_inicial, sdo_final,  tasa)
            VALUES(vPeriodo, vEmpresa, vNumCte, 0.00, vDepositos, vCargos, vSdoInicial, vSdoFinal, vTasaInteres);
            
            DROP TABLE tmp_tasas;
            DROP TABLE tmp_tasas2;
        END FOREACH;
            
        -- // GUARDA DATOS EN TABLA PARA DESCARGARLOS
        INSERT INTO repctasxinformar VALUES
        (vEmpresa, vNumCte, vFechaNacim, vRegFiscal, vTipoDepositante, vTipoCta, vNomProducto, vBPI, vNomina, vDeposito, vCheques, vAhorro, vCredito, vContCasaBolsa, 
         vContCompensacion, vContCustodiaValores, vContDispNom, vContConcentracion, vContGestionTeso, vOtrosContratos, vFechaApertura, vAseguradoIPAB, vMoneda, vTipoTasaInt);
         
        DROP TABLE tmp_ctasxinf;
        LET vContador1 = vContador1 + 1;
    END FOREACH;
    
    END;
    
    RETURN vCodRet1, vCodRet2, vCodRet3, vContador1;
    
END PROCEDURE;