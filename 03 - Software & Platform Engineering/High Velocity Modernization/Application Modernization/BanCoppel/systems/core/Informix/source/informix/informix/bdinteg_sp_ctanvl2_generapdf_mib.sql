CREATE PROCEDURE "informix".sp_ctanvl2_generapdf_mib(pNumCte CHAR(20),pNumCta CHAR(20))
	RETURNING CHAR(5);

	DEFINE iSqlErr INTEGER;
    DEFINE iSamErr INTEGER;
    DEFINE cDesErr CHAR(50);
	DEFINE cCommand CHAR(500);
	DEFINE cSQL CHAR(500);
	DEFINE cRutaInformix CHAR(100);
	DEFINE cUsrBin CHAR(100);
	DEFINE cCodRet CHAR(5);
    DEFINE cCodRet2 CHAR(5);
    DEFINE cCodRet3 CHAR(50);
	DEFINE cRutaArchivo CHAR(100);
	DEFINE cNomReporte CHAR(40);
	--- DEFINE cComponente CHAR(20);
	DEFINE cCmd1 CHAR(500);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cFechaHr CHAR(14);
	DEFINE cNomPortada CHAR(40);
	DEFINE cNomPortadaB CHAR(40);
	DEFINE cNomContrato CHAR(40);
	DEFINE cNomCaratura CHAR(40);

	DEFINE cProducto CHAR(40);
	DEFINE cNombreCte CHAR(107);
	DEFINE cFechaNac CHAR(10);
	DEFINE cRfc CHAR(13);
	DEFINE cSucursal CHAR(50);
	DEFINE cOperacion CHAR(30);
	DEFINE cFechaOpe CHAR(30);
	DEFINE cFolioOpe CHAR(20);
	DEFINE cCuenta CHAR(20);
	DEFINE cCtaClabe CHAR(20);
	DEFINE cTitular CHAR(104);
	DEFINE cAutorizaRevoc CHAR(2);
	DEFINE cReca CHAR(100);
	DEFINE cNombreBenef CHAR(104);
	DEFINE cPorcentaje CHAR(10);
	DEFINE cParentesco CHAR(40);
	DEFINE cProdCap CHAR(100);
	DEFINE cProdNom CHAR(100);
	DEFINE cProdGen CHAR(100);
	DEFINE cFecha CHAR(10);
	DEFINE cProd CHAR(4);
	DEFINE cNumCta CHAR(20);
	DEFINE cRutaArchivoImg CHAR(200);
	DEFINE cNombreArchivoImg CHAR(200);
    DEFINE cCorreoElec CHAR(50);
	DEFINE iCounter INTEGER;
	DEFINE cRcan CHAR(50);
	DEFINE cVar1 CHAR(50);
	DEFINE cVar2 CHAR(50);
	DEFINE cVar3 CHAR(50);
	DEFINE cVar4 CHAR(50);
	DEFINE cVar5 CHAR(50);
	DEFINE cVar6 CHAR(80);

	LET iSqlErr = 0;
    LET iSamErr = 0;
    LET cDesErr = '';
	LET cCommand = '';
	LET cSQL = '';
	LET cRutaInformix = '/ifxsif01/bin/';
	LET cUsrBin = '/usr/bin/';
	LET cCodRet = '000';
    LET cCodRet2 = '';
    LET cCodRet3 = '';
	LET cRutaArchivo = '/tmp/mfinis/caratulasCuentaNivel2/';
	LET cNomReporte = '';
	--- LET cComponente = '';
	LET cCmd1 = '';
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cFechaHr = TO_CHAR(CURRENT, '%Y%m%d%H%M%S');
	LET cNomPortada = '';
	LET cNomPortadaB = '';
	LET cNomContrato = '';
	LET cNomCaratura = '';

	LET cProducto = '';
	LET cNombreCte = '';
	LET cFechaNac = '';
	LET cRfc = '';
	LET cSucursal = '';
	LET cOperacion = ' ';
	LET cFechaOpe = '';
	LET cFolioOpe = '';
	LET cCuenta = '';
	LET cCtaClabe = '';
	LET cTitular = '';
	LET cAutorizaRevoc = '';
	LET cReca = '';
	LET cNombreBenef = '';
	LET cPorcentaje = '';
	LET cParentesco = '';
	LET cProdCap = '';
	LET cProdNom = '';
	LET cProdGen = '';
	LET cFecha = '';
	LET cProd = '';
	LET cNumCta =pNumCta;
	LET cRutaArchivoImg = '';
	LET cNombreArchivoImg = '';
    LET cCorreoElec = '';
	LET iCounter = 0;
	LET cRcan = '';
	LET cVar1 = '';
	LET cVar2 = '';
	LET cVar3 = '';
	LET cVar4 = '';
	LET cVar5 = '';
	LET cVar6 = '';
	
	BEGIN

    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO '/tmp/mfinis/caratulasCuentaNivel2/sp_ctanvl2_generapdf.err';
        TRACE ON;
        IF iSqlerr <> 0 THEN
            LET cCodRet  = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

    SET DEBUG FILE TO '/tmp/sp_ctanvl2_generapdf.out';
    TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- // VALIDA CAMPOS REQUERIDOS
    IF pNumCte IS NULL OR pNumCte = '' OR pNumCta IS NULL OR pNumCta = '' THEN
        LET cCodRet = '110';
        RETURN cCodRet;
    END IF;
    
    /* ###################################################################
    SELECT {+INDEX (bdinteg:"informix".si_param ix_si_param)} valor 
      INTO cRutaArchivo
      FROM bdinteg:"informix".si_param 
     WHERE cod_param = 487;
    ################################################################### */

    -- // SE DEFINE NOMENCLATURA DEL REPORTE
    LET cNomReporte = 'reportes'||TRIM(pNumCte)||'_'||TRIM(cFechaHr)||'.txt';
    LET cCommand = 'rm -rf '||TRIM(cRutaArchivo)||TRIM(cNomReporte);
    SYSTEM TRIM(cCommand);

    -- // EJECUTA PORTADA
    EXECUTE PROCEDURE bdinteg:"informix".sp_ctanvl2_genportada(pNumCte,pNumCta)
    INTO cCodRetSp,cProducto,cNombreCte,cFechaNac,cRfc,cSucursal,cOperacion,cFechaOpe,cFolioOpe,cCuenta,cCtaClabe,cTitular,cAutorizaRevoc,cReca,cProd;

    LET iCodRetSp = cCodRetSp::INTEGER;
    
    IF iCodRetSp < 0 THEN
        RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_ctanvl2_genportada';
    ELIF iCodRetSp = 0 THEN

        DELETE FROM bdinteg:"informix".si_ctanvl2_retornos;
        IF DBINFO('sqlca.sqlerrd2') = 0 THEN
            --- LET cCodRet = '00862';
        END IF;

        LET cNomPortada = 'portada'||TRIM(pNumCte)||'_'||TRIM(cFechaHr)||'.txt';
        LET cCommand = 'rm -rf '||TRIM(cRutaArchivo)||TRIM(cNomPortada);
        SYSTEM TRIM(cCommand);

        INSERT INTO bdinteg:"informix".si_ctanvl2_retornos
        (producto,nombre_cte,fecha_nac,rfc,sucursal,operacion,fecha_ope,folio_ope,cuenta,cta_clabe,titular,autoriza_revoc,reca)
        VALUES
        (cProducto,cNombreCte,cFechaNac,cRfc,cSucursal,cOperacion,cFechaOpe,cFolioOpe,cCuenta,cCtaClabe,cTitular,cAutorizaRevoc,cReca);

        LET cCmd1 ="";
        LET cCmd1 ="SELECT producto,nombre_cte,fecha_nac,rfc,sucursal,operacion,fecha_ope,folio_ope,cuenta,cta_clabe,titular,autoriza_revoc,reca";
        LET cCmd1 =""||TRIM(cCmd1)||" FROM bdinteg:""informix"".si_ctanvl2_retornos;";

        SYSTEM TRIM('echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaArchivo)||TRIM(cNomPortada)||' ' || TRIM(cCmd1)||'" | '||TRIM(cRutaInformix)||'dbaccess bdinteg > /dev/null 2>&1');

        DELETE FROM bdinteg:"informix".si_ctanvl2_retornosbenef;
        IF DBINFO('sqlca.sqlerrd2') = 0 THEN
            --- LET cCodRet = '00862';
        END IF;

        LET cNomPortadaB = 'portadabenef'||TRIM(pNumCte)||'_'||TRIM(cFechaHr)||'.txt';
        LET cCommand = 'rm -rf '||TRIM(cRutaArchivo)||TRIM(cNomPortadaB);
        SYSTEM TRIM(cCommand);

        FOREACH
            EXECUTE PROCEDURE bdinteg:"informix".sp_ctanvl2_genportada_benef(pNumCte,pNumCta)
            INTO cCodRetSp,cNombreBenef,cPorcentaje,cParentesco

            LET iCodRetSp = cCodRetSp::INTEGER;
            IF iCodRetSp < 0 THEN
                RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_ctanvl2_genportada_benef';
            ELIF iCodRetSp = 0 THEN
                INSERT INTO bdinteg:"informix".si_ctanvl2_retornosbenef
                (nombre_benef,porcentaje,parentesco)
                VALUES
                (cNombreBenef,cPorcentaje,cParentesco);
                
                LET iCounter = iCounter + 1;
            END IF;
        END FOREACH;


        IF iCounter > 0 THEN
            LET cCmd1 ="";
            LET cCmd1 ="SELECT nombre_benef,porcentaje,parentesco";
            LET cCmd1 =""||TRIM(cCmd1)||" FROM bdinteg:""informix"".si_ctanvl2_retornosbenef;";
            SYSTEM TRIM('echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaArchivo)||TRIM(cNomPortadaB)||' ' || TRIM(cCmd1)||'" | '||TRIM(cRutaInformix)||'dbaccess bdinteg > /dev/null 2>&1');
        END IF;
    END IF;

    -- // EJECUTA CONTRATO
    EXECUTE PROCEDURE bdinteg:"informix".sp_ctanvl2_gencontrato(pNumCte,pNumCta)
    INTO cCodRetSp,cProdCap,cProdNom,cProdGen,cNombreCte,cFecha,cSucursal,cProducto;

    LET iCodRetSp = cCodRetSp::INTEGER;
    
    IF iCodRetSp < 0 THEN
        RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_ctanvl2_gencontrato';
    ELIF iCodRetSp = 0 THEN
        DELETE FROM bdinteg:"informix".si_ctanvl2_retornos;
        IF DBINFO('sqlca.sqlerrd2') = 0 THEN
            --- LET cCodRet = '00862';
        END IF;

        LET cNomContrato = 'contrato'||TRIM(pNumCte)||'_'||TRIM(cFechaHr)||'.txt';
        LET cCommand = 'rm -rf '||TRIM(cRutaArchivo)||TRIM(cNomContrato);
        SYSTEM TRIM(cCommand);

        INSERT INTO bdinteg:"informix".si_ctanvl2_retornos
        (prod_cap,prod_nom,prod_gen,nombre_cte,fecha,sucursal,producto)
        VALUES
        (cProdCap,cProdNom,cProdGen,cNombreCte,cFecha,cSucursal,cProducto);

        LET cCmd1 ="";
        LET cCmd1 ="SELECT prod_cap,prod_nom,prod_gen,nombre_cte,fecha,sucursal,producto";
        LET cCmd1 =""||TRIM(cCmd1)||" FROM bdinteg:""informix"".si_ctanvl2_retornos;";

        SYSTEM TRIM('echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaArchivo)||TRIM(cNomContrato)||' ' || TRIM(cCmd1)||'" | '||TRIM(cRutaInformix)||'dbaccess bdinteg > /dev/null 2>&1');
    END IF;

    -- // EJECUTA CARATULA
    EXECUTE PROCEDURE bdinteg:"informix".sp_ctanvl2_gencaratula(pNumCte,pNumCta)
    INTO cCodRetSp,cProducto;

    LET iCodRetSp = cCodRetSp::INTEGER;
    
    IF iCodRetSp < 0 THEN
        RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_ctanvl2_gencaratula';
    ELIF iCodRetSp = 0 THEN
        DELETE FROM bdinteg:"informix".si_ctanvl2_retornos;
        IF DBINFO('sqlca.sqlerrd2') = 0 THEN
            --- LET cCodRet = '00862';
        END IF;

        LET cNomCaratura = 'caratula'||TRIM(pNumCte)||'_'||TRIM(cFechaHr)||'.txt';
        LET cCommand = 'rm -rf '||TRIM(cRutaArchivo)||TRIM(cNomCaratura);
        SYSTEM TRIM(cCommand);

        INSERT INTO bdinteg:"informix".si_ctanvl2_retornos
        (producto)
        VALUES
        (cProducto);

        LET cCmd1 ="";
        LET cCmd1 ="SELECT producto";
        LET cCmd1 =""||TRIM(cCmd1)||" FROM bdinteg:""informix"".si_ctanvl2_retornos;";

        SYSTEM TRIM('echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaArchivo)||TRIM(cNomCaratura)||' ' || TRIM(cCmd1)||'" | '||TRIM(cRutaInformix)||'dbaccess bdinteg > /dev/null 2>&1');
    END IF;

    SELECT correo_elec 
      INTO cCorreoElec
      FROM bdinteg:"informix".si_correos 
     WHERE empresa = '001' 
       AND numcte = pNumCte 
       AND status_correo = 'A';
    
    SELECT valor 
      INTO cRcan
      FROM bdinteg:si_param 
     WHERE cod_param = 487;
    
    SELECT valor 
      INTO cVar1
      FROM bdinteg:si_param 
     WHERE cod_param = 496;
    
    SELECT valor 
      INTO cVar2
      FROM bdinteg:si_param 
     WHERE cod_param = 497;
    
    SELECT valor 
      INTO cVar3
      FROM bdinteg:si_param 
     WHERE cod_param = 498;
    
    SELECT valor 
      INTO cVar4
      FROM bdinteg:si_param 
     WHERE cod_param = 499;
    
    SELECT valor 
      INTO cVar5
      FROM bdinteg:si_param 
     WHERE cod_param = 500;
    
    SELECT valor 
      INTO cVar6
      FROM bdinteg:si_param 
     WHERE cod_param = 504;

    -- // java7 ---> java8
    --- LET cCommand = "/usr/java7/bin/java -jar /tmp/mfinis/caratulasCuentaNivel2/componente/Caratulas.jar '"||TRIM(pNumCte)||"' '"|| TRIM(pNumCta)||"' > /tmp/mfinis/caratulasCuentaNivel2/reportes.txt";
    LET cCommand = "/usr/java8/bin/java -jar "||TRIM(cRutaArchivo)||"componente/Caratulas.jar '"||TRIM(pNumCte)||"' '"|| TRIM(pNumCta)||"' '"|| TRIM(cNomPortada)||"' '"|| TRIM(cNomPortadaB)||"' '"|| TRIM(cNomContrato)||"' '"|| TRIM(cNomCaratura)||"' '"|| TRIM(cRutaArchivo)||"' '"||TRIM(cNomReporte)||"' '"||TRIM(cCorreoElec)||"' '"||TRIM(cRcan)||"'";
    SYSTEM(cCommand);

    --- LET cCommand = TRIM(cUsrBin)||'chmod 777 '||TRIM(cRutaArchivo)||TRIM(cNomReporte);
    --- SYSTEM(cCommand);

    LET cCommand = 'echo "SET ISOLATION TO DIRTY READ; LOAD FROM '||TRIM(cRutaArchivo)||TRIM(cNomReporte)||' DELIMITER ''|'' INSERT INTO si_ctanvl2_ctrlrep(nom_reporte,fecha_gen,error,archivo_log)"  > '||TRIM(cRutaArchivo)||'reportesPDF_'||TRIM(cNomReporte)||'.sql';
    SYSTEM cCommand;

    LET cRutaArchivoImg = TRIM(cRutaArchivo)||'caratulasPDF/imagenes';
    LET cRutaArchivoImg = TRIM(cRutaArchivoImg);

    LET cNombreArchivoImg = TRIM(pNumCte)||'_'|| TRIM(cNumCta)||'.txt';
    LET cNombreArchivoImg = TRIM(cNombreArchivoImg);

    LET cCommand = TRIM(cUsrBin)||'chmod 777 '||TRIM(cRutaArchivo)||'reportesPDF_'||TRIM(cNomReporte)||'.sql';
    SYSTEM(cCommand);

    LET cSQL = TRIM(cRutaInformix)||'dbaccess bdinteg '||TRIM(cRutaArchivo)||'reportesPDF_'||TRIM(cNomReporte)||'.sql';
    SYSTEM cSQL;

    EXECUTE PROCEDURE bdinteg:"informix".sp_insertarimgleerarchivo(cRutaArchivoImg, cNombreArchivoImg) 
    INTO cCodRetSp;

    EXECUTE PROCEDURE bdinteg:"informix".sp_insertarimg(pNumCte, cNumCta, cProd) 
    INTO cCodRetSp;
    
    -- // ---> java8
    LET cCommand = "/usr/java8/bin/java -jar "||TRIM(cRutaArchivo)||"componente/EnvioImagenes.jar '"||TRIM(cRutaArchivoImg)||"' '"|| TRIM(cNombreArchivoImg)||"' '"|| TRIM(cVar6)||"' '"|| TRIM(cVar1)||"' '"|| TRIM(cVar2)||"' '"|| TRIM(cVar3)||"' '"|| TRIM(cVar4)||"' '"||TRIM(cVar5)||"'";
    SYSTEM(cCommand);
    
    RETURN cCodRet;

	END;
    
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 20/07/2020',
'DESCRIPCION: SPL encargado de realizar la ejecucion del componente Caratulas.jar para la generacion de los reportes en formato PDF.',
'BD: bdinteg',
'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 17/08/2020',
'DESCRIPCION: Se modifica para proporcionar correo electronico al componente de caratulas.jar.',
'BD: bdinteg',
'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 12/11/2021',
'DESCRIPCION: Se modifica para implementar el servicio web de insersion de imagen',
'BD: bdinteg';

CREATE PROCEDURE "informix".cierrechqcomp2(pempresa CHAR(3))
RETURNING CHAR(5);

    --- ################################################################################
    --- ##  Nombre:              cierrechqcomp2                                       ##
    --- ##  Version:             1.0.0                                                ##
    --- ##  Objetivo:            Programa complemento del cierre diario de captacion  ##
    --- ##  Creado por:                                                               ##
    --- ##  ModIFicado por:      JICS                                                 ##
    --- ##  Ultima Modificacion: Marzo 2011                                           ##
    --- ################################################################################

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
    DEFINE vinicio_cierre               DATE;
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

    LET vcodret    = "000";
    LET vcodret2   = "000";
    LET vcodret3   = "000";
    LET vsqlerr    = 0;
    LET isam_err   = 0;
    LET error_info = '';
    LET vfechahora = " ";
    LET vsql       = '';
    LET vstmt      = '';
    LET vsistema   = "01";
    LET vproceso   = "cierrechqcomp2";
    LET vstatuscierreinv     = '';
    LET vstatuscobroreestruc = '';
    LET vProdChequeras  = '';
    LET vexiste         = '';
    LET vexiste2        = 0;
    LET vexistefin      = 0;
    LET vinicio_cierre  = '';
    LEt vdias           = 0;
    LET vregproc        = 0;
    LET vporcentajerror = 0;
    LET vfcuenta        = '';
    LET FechaProc       = '';
    LET vProducto       = '';
    LET vSdoActual      = 0.00;
    LET vSucursal       = '';
    LET vcontvalcie     = 0;
    LET vregistros      = 0;
    LET vcuenta         = '';

    BEGIN

    ON EXCEPTION SET vsqlerr, isam_err, error_info
        SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechqcomp2.err";
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
                       'AND sistema   = '''||vsistema||''';" > /tmp/horascierre.sql';
            SYSTEM vsql;

            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horascierre.sql';
            SYSTEM vstmt;

            RETURN vcodret;
        END IF;
    END EXCEPTION;

    	--SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechqcomp2.out";
    	--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    ---SET PDQPRIORITY 20; HMD-INCIDENCIA-20220224

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
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horascierre.sql';
        SYSTEM vsql;

        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horascierre.sql';
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
                       'AND sistema   = '''||vsistema||''';" > /tmp/horascierre.sql';
            SYSTEM vsql;

            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horascierre.sql';
            SYSTEM vstmt;
        ELSE
            LET vcodret = "966";

            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vgusuario||''','||
                       'status_proc   = '''||'F'||''','||
                       'codret        = '''||vcodret||''','||
                       'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vgfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horascierre.sql';
            SYSTEM vsql;

            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horascierre.sql';
            SYSTEM vstmt;
        END IF
    END IF;

    SELECT 1
      INTO vexiste
      FROM sc_contproc
     WHERE empresa = pempresa
       AND proceso = "cierrecomp2"
       AND fecha = vgfecha_hoy;

    IF vexiste = "1" THEN
        LET vcodret = "966";
        RETURN vcodret;
    END IF

    -- // VALIDA QUE EL CIERRE PRINCIPAL HAYA COMENZADO A PROCESAR CUENTAS
    SELECT fecha
      INTO vinicio_cierre
      FROM sc_contproc
     WHERE empresa = pempresa
       AND proceso = 'inicio_cierre';

    IF vinicio_cierre <> vgfecha_hoy OR vinicio_cierre is null THEN
        LET vcodret = "972";

        LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                   'SET ejecutivo = '''||vgusuario||''','||
                   'status_proc   = '''||'C'||''','||
                   'codret        = '''||vcodret||''','||
                   'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                   'WHERE empresa = '''||pempresa||''' '||
                   'AND proceso   = '''||vproceso||''' '||
                   'AND fecha     = '''||vgfecha_hoy||''' '||
                   'AND sistema   = '''||vsistema||''';" > /tmp/horascierre.sql';
        SYSTEM vsql;

        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horascierre.sql';
        SYSTEM vstmt;

        RETURN vcodret;
    END IF;

    -- // OBTIENE NUMERO DE DIAS A PROCESAR
    IF vgfecha_hoy = vgult_hab_mes THEN
        LET vdias = vgult_dia_mes - vgfecha_hoy + 1;

        IF vgprox_fecha > vgult_dia_mes THEN
            LET vdias = vdias + ((vgprox_fecha-1) - vgult_dia_mes);
        END IF
    ELSE
        LET vdias = vgprox_fecha - vgfecha_hoy;
    END IF

    -- // OBTIENE NUMERO DE REGISTROS A PROCESAR
    SELECT COUNT(*)
      INTO vregproc
      FROM sc_maechq
     WHERE status_cta not in("0","2","8","9","5")
       AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vgfecha_hoy);

    -- // Obtiene parametro de porcentajes de error por proceso
    SELECT ROUND(valor)
      INTO vporcentajerror
      FROM sc_param
     WHERE empresa  = pempresa
       AND codparam = "porcentajerror";

    -- // FOREACH PRINCIPAL DEL CIERRE DE CAPTACION
    FOREACH principal WITH HOLD FOR
        SELECT cuenta, fecha_proceso, producto, sdo_actual, status_cta, sucursal
          INTO vfcuenta, FechaProc, vProducto, vSdoActual, vgstatus_cta, vSucursal
          FROM sc_maechq
         WHERE producto <> '2000'
           AND status_cta not in("0","2","8","9","5")
           AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vgfecha_hoy)

        -- // Omite procesar las cuentas de chequeras - Gpo PISA Mayo 2010
        IF vproducto = vProdChequeras THEN
            CONTINUE FOREACH;
        END IF;

        IF vproducto = vgProdCreciente THEN
            -- // Obtiene instrucciones de la inversión creciente
            SELECT instrucc, cuentadep
              INTO vginstrucc, vgcuentadep
              FROM sc_maeinstrucc
             WHERE empresa = pempresa
               AND cuenta = vfcuenta;

            IF FechaProc IS NULL THEN
                IF vSdoActual = 0 THEN
                    UPDATE sc_maechq
                       SET status_cta = "2",
                           fecha_proceso = vgfecha_hoy
                     WHERE empresa = pempresa
                       AND cuenta = vfcuenta;

                    LET vcodret = "000";

                    CONTINUE FOREACH;
                ELSE
                    CALL creciente_proy_cierre(pempresa, vfcuenta, vProducto, vSdoActual, vginstrucc)
                    RETURNING vcodret;

                    IF vcodret <> "000" THEN
                        CONTINUE FOREACH;
                    END IF
                END IF
            END IF

            -- // Verifica Fecha de Vencimiento para cuentas crecientes
            SELECT nvl(fecha_mod, vgfecha_hoy), nvl(fecha_alta, vgfecha_hoy)
              INTO vgfecha_mod, vgfecha_alta
              FROM sc_maenoc
             WHERE empresa = pempresa
               AND cuenta = vfcuenta;

            -- // Actualiza la fecha como ya procesado si vencio su plazo
            IF vgfecha_mod < vgfecha_hoy THEN
                UPDATE sc_maechq
                   SET fecha_proceso = vgprox_fecha
                 WHERE empresa = pempresa
                   AND cuenta = vfcuenta;

                CONTINUE FOREACH;
            END IF
        END IF

        CALL cierrechq_reg (pempresa, vdias, vfcuenta, vProducto, vSdoActual, vSucursal)
        RETURNING vcodret;

        IF vcodret <> "000" THEN
            -- // Conteo de Errores generados por el cierre
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
                           'AND sistema   = '''||vsistema||''';" > /tmp/horascierre.sql';
                SYSTEM vsql;

                LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horascierre.sql';
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
        LET vgfecha_mod  = ' ';
        LET vgfecha_alta = ' ';
        LET vcontvalcie  = 0;
        LET vregistros   = 0;
        LET vginstrucc   = '';
        LET vgcuentadep  = '';
    END FOREACH;

    -- // Actualiza Cuentas Crecientes Canceladas en el Dia
    FOREACH
        SELECT a.cuenta, a.sdo_actual, b.fecha_alta
          INTO vfcuenta, vSdoActual, FechaProc
          FROM sc_maechq a,
               sc_maenoc b
         WHERE a.empresa = pempresa
           AND a.status_cta = "2"
           AND a.producto = vgProdCreciente
           AND (a.fecha_proceso = vgfecha_hoy OR a.fecha_proceso IS NULL)
           AND b.empresa = a.empresa
           AND b.cuenta = a.cuenta

        IF FechaProc IS NULL THEN
           UPDATE sc_maechq
              SET fecha_proceso = vgfecha_hoy
            WHERE empresa = pempresa
              AND cuenta = vfcuenta;
	    END IF;

        LET vfcuenta   = '';
        LET vSdoActual = 0.00;
        LET FechaProc  = '';
    END FOREACH

    -- // Actualiza saldo de cuentas inactivas
    FOREACH
        SELECT cuenta, producto
          INTO vcuenta, vproducto
          FROM sc_maechq
         WHERE status_cta = '4'
           AND fecha_proceso < vgfecha_hoy

        IF vproducto = vProdChequeras THEN
            CONTINUE FOREACH;
        END IF;

        UPDATE sc_maechq
           SET sdo_dia_ant = sdo_actual
         WHERE empresa = pempresa
           AND cuenta = vcuenta;

        LET vcuenta   = '';
        LET vproducto = '';
    END FOREACH

    -- // Registra fin de cierre
    LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
               'SET status_proc   = '''||'F'||''','||
               'codret        = '''||vcodret||''','||
               'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
               'WHERE empresa = '''||pempresa||''' '||
               'AND proceso   = '''||vproceso||''' '||
               'AND fecha     = '''||vgfecha_hoy||''' '||
               'AND sistema   = '''||vsistema||''';" > /tmp/horascierre.sql';
    SYSTEM vsql;

    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horascierre.sql';
    SYSTEM vstmt;

    UPDATE sc_contproc
       SET fecha = vgfecha_hoy
     WHERE empresa = pempresa
       AND proceso = "cierrecomp2";

    SET LOCK MODE TO NOT WAIT;

    RETURN vcodret;

    END

END PROCEDURE

DOCUMENT
'DESCRIPCION: Programa complementario del cierre diario de las cuenta de captacion',
'EJECUTADO O LLAMADO POR: VB',
'AUTOR: JICS',
'FECHA: 10/Marzo/2011',
'VERSION: 1.00.0000',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_calcularrfc(pApellidoPaterno CHAR(26), pApellidoMaterno CHAR(26), pNombre CHAR(55), pFechaNacimiento DATE)
        RETURNING CHAR(5) AS codret,
                        CHAR(13) AS rfc;

        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cRfc CHAR(13);
        DEFINE cCaracter CHAR(1);
        DEFINE i SMALLINT;
        DEFINE bBoolValue BOOLEAN;
        DEFINE lPalabra LVARCHAR;
        DEFINE bSalirBucle BOOLEAN;
        -- Variables de RFC
        DEFINE cPrimerLetraApellidoPaterno CHAR(1);
        DEFINE cVocalApellidoPaterno CHAR(1);
        DEFINE cPrimerLetraApellidoMaterno CHAR(1);
        DEFINE cPrimerLetraNombre CHAR(1);
        DEFINE cFechaNacimientos CHAR(6);
        DEFINE cHomoclave CHAR(2);
        DEFINE cDigitoVerificador CHAR(2);
		DEFINE cApellidoMaterno CHAR(26);

    DEFINE iCont INTEGER;
    DEFINE lPalabra2 LVARCHAR;
    LET iCont=0;
    LET lPalabra2 = '';

        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cRfc = '';
        LET cCaracter = '';
        LET bBoolValue = 'f';
        LET lPalabra = '';
        LET bSalirBucle = 'f';
        LET cPrimerLetraApellidoPaterno = '';
        LET cVocalApellidoPaterno = '';
        LET cPrimerLetraApellidoMaterno = 'X';
        LET cPrimerLetraNombre = '';
        LET cFechaNacimientos = '';
        LET cHomoclave = '';
        LET cDigitoVerificador = '';
		LET cApellidoMaterno = pApellidoMaterno;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
        BEGIN

                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cRfc;
                END EXCEPTION;

                --SET DEBUG FILE TO '/tmp/mfinis/sp_calcularrfc.out';
                --TRACE ON;

                IF pNombre = '' OR pFechaNacimiento IS NULL THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, cRfc;
                END IF;

                IF pApellidoPaterno = '' AND pApellidoMaterno = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, cRfc;
                END IF;

                LET pApellidoPaterno = UPPER(pApellidoPaterno);
                LET pApellidoMaterno = UPPER(pApellidoMaterno);
                LET pNombre = UPPER(pNombre);

                FOR i = 0 TO LENGTH(TRIM(pApellidoPaterno))
                        LET cCaracter = SUBSTR(TRIM(pApellidoPaterno), i, 1);
                        EXECUTE FUNCTION  bdinteg:"informix".sp_sololetrasnumeros(cCaracter) INTO bBoolValue;

                        IF NOT bBoolValue THEN
                                LET cCodRet = '00221'; -- CARACTER RARO EN EL APELLIDO PATERNO
                                RETURN cCodRet, cRfc;
                        END IF;
                END FOR;

                FOR i = 0 TO LENGTH(TRIM(pApellidoMaterno))
                        LET cCaracter = SUBSTR(TRIM(pApellidoMaterno), i, 1);
                        EXECUTE FUNCTION  bdinteg:"informix".sp_sololetrasnumeros(cCaracter) INTO bBoolValue;

                        IF NOT bBoolValue THEN
                                LET cCodRet = '00222'; -- CARACTER RARO EN EL APELLIDO MATERNO
                                RETURN cCodRet, cRfc;
                        END IF;
                END FOR;

                FOR i = 0 TO LENGTH(TRIM(pNombre))
                        LET cCaracter = SUBSTR(TRIM(pNombre), i, 1);
                        EXECUTE FUNCTION  bdinteg:"informix".sp_sololetrasnumeros(cCaracter) INTO bBoolValue;

                        IF NOT bBoolValue THEN
                                LET cCodRet = '00223'; -- CARACTER RARO EN EL NOMBRE
                                RETURN cCodRet, cRfc;
                        END IF;
                END FOR;

                -- SI SOLO TIENE UN APELLIDO TOMARLO COMO PATERNO
                IF TRIM(pApellidoPaterno) = '' AND TRIM(pApellidoMaterno) <> '' THEN
                        LET pApellidoPaterno = pApellidoMaterno;
                        LET pApellidoMaterno = '';
                END IF;

                -- Se Obtiene la primera letra y la primer vocal del apellido
                IF TRIM(pApellidoPaterno) <> '' THEN
						--CONTADOR DE APELLIDO
						FOREACH EXECUTE FUNCTION  bdinteg:"informix".sp_split_cadena(pApellidoPaterno, ' ') INTO lPalabra2
							Let iCont=iCont+1;
							--RETURN iCont, 'CONTADOR';
						END FOREACH;


                        FOREACH EXECUTE FUNCTION  bdinteg:"informix".sp_split_cadena(pApellidoPaterno, ' ') INTO lPalabra

                                -- Verificar que el apellido no este abreviado
                                EXECUTE FUNCTION "informix".sp_esnombre_apellido_abreviado(lPalabra) INTO bBoolValue;
                                IF bBoolValue THEN -- EL APELLIDO ESTA ABREVIADO
                                        LET cCodRet = '00224'; -- APELLIDO PATERNO ABREVIADO
                                        RETURN cCodRet, cRfc;
                                ELSE -- EL APELLIDO PATERNO NO ESTA ABREVIADO
                                        -- SE VALIDA QUE SEA UN APELLIDO VALIDO
								IF iCont>1 THEN
									EXECUTE FUNCTION  bdinteg:"informix".sp_esapellido_valido(lPalabra) INTO bBoolValue;
								ELSE
									LET bBoolValue='t';
								END IF;

                                        IF bBoolValue THEN
                                                LET cPrimerLetraApellidoPaterno = SUBSTR(TRIM(lPalabra), 1, 1);
                                                -- SE BUSCA LA PRIMERA VOCAL DEL APELLIDO
                                                IF LENGTH(TRIM(lPalabra)) > 1 THEN
                                                        FOR i = 2 TO LENGTH(TRIM(lPalabra))
                                                                LET cCaracter = SUBSTR(TRIM(lPalabra), i, 1);
                                                                EXECUTE FUNCTION  bdinteg:"informix".sp_esvocal(cCaracter) INTO bBoolValue;
                                                                IF bBoolValue THEN
                                                                        LET cVocalApellidoPaterno = cCaracter;
                                                                        LET bSalirBucle = 't';
                                                                        EXIT FOR;
                                                                --ELSE
                                                                --      LET cVocalApellidoPaterno = 'X';
                                                                END IF;
                                                        END FOR;
                                                        LET bSalirBucle = 't';
                                                ELSE
                                                        LET bSalirBucle = 't';
                                                END IF;

                                                IF bSalirBucle THEN
                                                        EXIT FOREACH;
                                                END IF;
                                        END IF;

                                END IF;

                        END FOREACH;
                END IF;
                LET bSalirBucle = 'f';

                -- Se Obtiene la primera letra apellido materno
                IF TRIM(pApellidoMaterno) <> '' THEN
                        FOREACH EXECUTE FUNCTION  bdinteg:"informix".sp_split_cadena(pApellidoMaterno, ' ') INTO lPalabra

                                -- Verificar que el apellido no este abreviado
                                EXECUTE FUNCTION  bdinteg:"informix".sp_esnombre_apellido_abreviado(lPalabra) INTO bBoolValue;
                                IF bBoolValue THEN -- EL APELLIDO ESTA ABREVIADO
                                        LET cCodRet = '00225'; -- APELLIDO MATERNO ABREVIADO
                                        RETURN cCodRet, cRfc;
                                ELSE -- EL APELLIDO MATERNO NO ESTA ABREVIADO
                                        -- SE VALIDA QUE SEA UN APELLIDO VALIDO
                                        EXECUTE FUNCTION  bdinteg:"informix".sp_esapellido_valido(lPalabra) INTO bBoolValue;

                                        IF bBoolValue THEN
                                                LET cPrimerLetraApellidoMaterno = SUBSTR(TRIM(lPalabra), 1, 1);
                                                EXIT FOREACH;
                                        END IF;

                                END IF;

                        END FOREACH;
                END IF;

				--TRACE '-----------------------------------------------------';
				--TRACE '>>>>>'||cPrimerLetraApellidoPaterno||cVocalApellidoPaterno||cPrimerLetraApellidoMaterno||cPrimerLetraNombre;

                -- Se obtiene la primer letra del nombre
                IF TRIM(pNombre) <> '' THEN

                        FOREACH EXECUTE FUNCTION bdinteg:"informix".sp_split_cadena(pNombre, ' ') INTO lPalabra

                                -- Revisar que el nombre no este abreviado
                                EXECUTE FUNCTION  bdinteg:"informix".sp_esnombre_apellido_abreviado(lPalabra) INTO bBoolValue;
                                IF bBoolValue THEN
                                        LET cCodRet = '00226'; -- NOMBRE ABREVIADO
                                        RETURN cCodRet, cRfc;
                                ELSE
                                        EXECUTE FUNCTION  bdinteg:"informix".sp_esnombre_valido(TRIM(lPalabra)) INTO bBoolValue;

                                        IF bBoolValue THEN
												--TRACE '*********************************';
                                                IF cVocalApellidoPaterno = '' THEN
                                                        LET cVocalApellidoPaterno = cPrimerLetraApellidoMaterno;
                                                        LET cPrimerLetraApellidoMaterno = SUBSTR(TRIM(lPalabra), 1, 1);
                                                        LET cPrimerLetraNombre = SUBSTR(TRIM(lPalabra), 2, 1);
                                                ELSE
                                                        IF TRIM(pApellidoMaterno) = '' THEN
                                                                LET cPrimerLetraApellidoMaterno = SUBSTR(TRIM(lPalabra), 1, 1);
                                                                LET cPrimerLetraNombre = SUBSTR(TRIM(lPalabra), 2, 1);
                                                        ELSE
                                                                LET cPrimerLetraNombre = SUBSTR(TRIM(lPalabra), 1, 1);
                                                        END IF;
                                                END IF;
                                                EXIT FOREACH;
                                        ELSE
                                                IF TRIM(lPalabra) = 'MARIA' OR TRIM(lPalabra) = 'JOSE' OR TRIM(lPalabra) = 'MA' OR TRIM(lPalabra) = 'M' OR TRIM(lPalabra) = 'J' THEN
                                                        IF cVocalApellidoPaterno = '' THEN
                                                                LET cVocalApellidoPaterno = cPrimerLetraApellidoMaterno;
																LET pApellidoMaterno = '';
                                                                LET cPrimerLetraApellidoMaterno = SUBSTR(TRIM(lPalabra), 1, 1);
                                                                LET cPrimerLetraNombre = SUBSTR(TRIM(lPalabra), 2, 1);
                                                        ELSE
                                                                LET cPrimerLetraNombre = SUBSTR(TRIM(lPalabra), 1, 1);
                                                        END IF;
                                                END IF;
                                        END IF;

                                END IF;

                        END FOREACH;

                END IF;

				LET pApellidoMaterno = cApellidoMaterno;

                LET cRfc = cPrimerLetraApellidoPaterno||cVocalApellidoPaterno||cPrimerLetraApellidoMaterno||cPrimerLetraNombre;
                -- Busqueda de palabra Altisonante
                EXECUTE FUNCTION  bdinteg:"informix".sp_espalabra_altisonante(TRIM(cRfc)) INTO bBoolValue;
                IF bBoolValue THEN
                        LET cPrimerLetraNombre = 'X';
                END IF;

                LET cFechaNacimientos = TO_CHAR(pFechaNacimiento, '%y%m%d');
                LET cRfc =      cPrimerLetraApellidoPaterno||cVocalApellidoPaterno||cPrimerLetraApellidoMaterno||cPrimerLetraNombre||cFechaNacimientos;

                -- ObtenciÃ³n de la homoclave
                LET lPalabra = UPPER(TRIM(pApellidoPaterno))||' '||UPPER(TRIM(pApellidoMaterno))||' '||UPPER(TRIM(pNombre));
                EXECUTE FUNCTION  bdinteg:"informix".sp_obtenerhomoclave(lPalabra) INTO cHomoclave;

                -- ObtenciÃ³n del digito verificador
                LET cRfc = TRIM(cRfc)||cHomoclave;
                EXECUTE FUNCTION  bdinteg:"informix".sp_obtienedigitoverificador_rfc(TRIM(cRfc)) INTO cDigitoVerificador;

                LET cRfc =      cPrimerLetraApellidoPaterno||cVocalApellidoPaterno||cPrimerLetraApellidoMaterno||cPrimerLetraNombre||cFechaNacimientos||cHomoclave||cDigitoVerificador;
                RETURN cCodRet, cRfc;
        END;

END PROCEDURE
DOCUMENT
'AUTOR: Oscar Flores Conde',
'FECHA: 05/12/2013',
'DESCRIPCION: Funcion que genera el RFC de un cliente';

CREATE PROCEDURE "informix".sp_pay_depuracion_pba()
RETURNING VARCHAR(10), VARCHAR(255);


	DEFINE vcod_ret         		VARCHAR(10); 
	DEFINE sql_err          		INTEGER;
	DEFINE isam_err         		INTEGER;
	DEFINE error_info       		CHAR(40);
	
	DEFINE vdia_cte					INTEGER;
	DEFINE vdif_cte					INTEGER;
	DEFINE vfec_depuracion_cte		DATE;
	DEFINE vfecha_hoy				DATE;
	
	DEFINE vdia_dir					INTEGER;
	DEFINE vdif_dir					INTEGER;
	DEFINE vfec_depuracion_dir		DATE;

	DEFINE vdia_cta					INTEGER;
	DEFINE vdif_cta					INTEGER;
	DEFINE vfec_depuracion_cta		DATE;

	DEFINE vdia_tar					INTEGER;
	DEFINE vdif_tar					INTEGER;
	DEFINE vfec_depuracion_tar 		DATE;
	
	
	--Manejo del error
       ON EXCEPTION
		SET sql_err, isam_err, error_info
		
           IF sql_err <> 0 THEN
            LET vcod_ret=sql_err;
            RETURN vcod_ret, isam_err||' ' ||error_info;
			
           END IF;
       END EXCEPTION;
	   
	set debug file to "/tmp/costo/costo/20220324/bdichq/sp_pay_depuracion";
	TRACE ON;	   
	 
	LET vcod_ret = '000';          
	LET sql_err = 0;          
	LET isam_err = 0;        
	LET error_info = '';
	
	
	LET vfecha_hoy = '';
	LET vdia_cte = 0;				
	LET vdif_cte = 0;				
	LET vfec_depuracion_cte = '';	
				
	
	LET vdia_dir = 0;				
	LET vdif_dir = 0;				
	LET vfec_depuracion_dir = '';	
	
	LET vdia_cta = 0;				
	LET vdif_cta = 0;				
	LET vfec_depuracion_cta = '';
	
	LET vdia_tar = 0;
	LET vdif_tar = 0;
	LET vfec_depuracion_tar = '';

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;	
	   
	SELECT fecha_depuracion, dia
		INTO vfec_depuracion_cte, vdia_cte
		FROM bdinteg:si_pyt_depuracion
		WHERE id_tabla = 1;
		
	SELECT fecha_depuracion, dia
		INTO vfec_depuracion_dir, vdia_dir
		FROM bdinteg:si_pyt_depuracion
		WHERE id_tabla = 2;

	SELECT fecha_depuracion, dia
		INTO vfec_depuracion_cta, vdia_cta
		FROM bdinteg:si_pyt_depuracion
		WHERE id_tabla = 3;	

	SELECT fecha_depuracion, dia
		INTO vfec_depuracion_tar, vdia_tar
		FROM bdinteg:si_pyt_depuracion
		WHERE id_tabla = 4;	

	LET vfecha_hoy = TODAY;
	
	LET vdif_cte = vfecha_hoy - vfec_depuracion_cte;
	LET vdif_dir = vfecha_hoy - vfec_depuracion_dir;
	LET vdif_cta = vfecha_hoy - vfec_depuracion_cta;
	LET vdif_tar = vfecha_hoy - vfec_depuracion_tar;
	
	-- Depuracion de Cliente
	IF( vdif_cte = vdia_cte ) THEN
	
		TRUNCATE bdinteg:info_clientes_pyt;
		
		UPDATE bdinteg:si_pyt_depuracion 
		   SET (fecha_depuracion, ind_dep) = (TODAY, '1')
		  WHERE id_tabla = 1;
	ELSE 
		UPDATE bdinteg:si_pyt_depuracion 
		   SET ind_dep = '0'
		 WHERE id_tabla = 1;
	END IF			

	-- Depuracion de Direccion
	IF(vdif_dir = vdia_dir ) THEN
	
		TRUNCATE bdinteg:info_direccion_pyt;
	
		UPDATE bdinteg:si_pyt_depuracion 
		   SET (fecha_depuracion, ind_dep) = (TODAY, '1')
		  WHERE id_tabla = 2;
				
	ELSE 
			UPDATE bdinteg:si_pyt_depuracion 
			  SET ind_dep = '0'
			WHERE id_tabla = 2;
	END IF	
	
	--Depuracion de Cuenta
	IF(vdif_cta = vdia_cta) THEN

		TRUNCATE bdinteg:info_cuenta_pyt;
		
		UPDATE bdinteg:si_pyt_depuracion 
		   SET (fecha_depuracion, ind_dep) = (TODAY, '1')
		 WHERE id_tabla = 3;
				
	ELSE 
		UPDATE bdinteg:si_pyt_depuracion SET ind_dep = '0'
				WHERE id_tabla = 3;
				
	END IF

	-- Depuracion de Tarjeta
	IF( vdif_tar = vdia_tar ) THEN
		-- Pendiente
	END IF			
	
	RETURN vcod_ret, 'PROCESO EXITOSO';
END PROCEDURE;