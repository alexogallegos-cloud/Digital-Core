CREATE PROCEDURE "informix".sp_ctanvl2_generapdf_pba(pNumCte CHAR(20),pNumCta CHAR(20))
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
	--- LET cRutaArchivo = '/tmp/mfinis/caratulasCuentaNivel2/';
    LET cRutaArchivo = '/RESPALDOSNEW/DoctosCtaNvl2/';
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
        SET DEBUG FILE TO '/resplogifx/conciliachq/sp_ctanvl2_generapdf_pba.err';
        TRACE ON;
        IF iSqlerr <> 0 THEN
            LET cCodRet  = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

    SET DEBUG FILE TO '/resplogifx/conciliachq/sp_ctanvl2_generapdf_pba.out';
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
    
    SELECT SUBSTR(valor,62,29) 
      INTO cRcan
      FROM bdinteg:si_param 
     WHERE cod_param = 486;
    
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
    --- LET cRutaArchivoImg = TRIM(cRutaArchivo)||'caratulasPDF';
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

CREATE PROCEDURE "informix".sp_insertarimg( pNumCte CHAR(20), pNumCta CHAR(20), pNumProd CHAR(4) )
RETURNING CHAR(5) AS codret;
    
	DEFINE cCodRet          CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE cCodRet3         CHAR(50);
	DEFINE iSqlErr          INTEGER;
	DEFINE iSamErr	        INTEGER;
	DEFINE cDesErr	        CHAR(50);
	DEFINE cCmd             CHAR(2000);
	DEFINE cScriptCarga     CHAR(600);
	DEFINE cRutaInformix    CHAR(100);
	DEFINE ven_transacc     SMALLINT;
	DEFINE bInTransaction   BOOLEAN;
	DEFINE cCampos          CHAR(1024);
	DEFINE cTablaDst        CHAR(150);
	DEFINE cBaseDatos       CHAR(50);
	DEFINE cUsrBin          CHAR(15);
	DEFINE cRuta            CHAR(100);
    DEFINE iId              INTEGER;
	
	LET cCodRet        = '00000';
	LET cCodRet2       = '';
    LET cCodRet3       = '';
	LET iSqlErr        = 0;
    LET iSamErr        = 0;
    LET cDesErr        = '';
	LET bInTransaction = 'f';
	LET ven_transacc   = 0;
	LET cCmd           = '';
	LET cScriptCarga   = '';
	LET cRutaInformix  = '/ifxsif01/bin/';
	LET cCampos        = '';
	LET cTablaDst      = 'si_ctanvl2_rutaimg';
	LET cBaseDatos     = 'bdinteg';
	LET cUsrBin        = '/usr/bin/';
	LET cRuta          = '';
    LET iId            = 0;
	
	BEGIN		
	
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO '/tmp/mfinis/caratulasCuentaNivel2/sp_insertarimg.err';
        TRACE ON;
        LET cCodRet  = iSqlErr;
        LET cCodRet2 = iSamErr;
        LET cCodRet3 = cDesErr;
        RETURN cCodRet;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO '/tmp/mfinis/caratulasCuentaNivel2/sp_insertarimg.out';
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    FOREACH
        --- Select substr(ruta, CHARINDEX('.',ruta)-1,1) as id, ruta 
        Select 1 as id, ruta 
          into iId, cRuta 
          from bdinteg:si_ctanvl2_rutaimg
         where ruta like '%Por%'
        
        /* ##############################################################################################################################################
        insert into bdidigital@coppelimg_crx:"informix".dg_expediente 
        ( empresa, cliente, cuenta, producto, cod_docto, secuencia, prod_nombre, descrip2, usuario_alta, fecha_alta, usuario_modif, fecha_modif ) 
        values 
        ( '001', TRIM(pNumCte), TRIM(pNumCta), TRIM(pNumProd), '168', iId, 'PORTADA CUENTA DIGITAL BANCOPPEL', ' ', 'informix', today, ' ', ' ' ); 
        
        EXECUTE PROCEDURE bdidigital@coppelimg_crx:"informix".sp_insertarimgdigital(TRIM(pNumCte), TRIM(cRuta), iId, '168') 
        into cCodret;
        ############################################################################################################################################## */
        
        insert into bdidigital@coppelimg_crx:dg_expediente 
        ( empresa, cliente, cuenta, producto, cod_docto, secuencia, prod_nombre, descrip2, usuario_alta, fecha_alta, usuario_modif, fecha_modif ) 
        values 
        ( '001', TRIM(pNumCte), TRIM(pNumCta), TRIM(pNumProd), '0168', iId, 'PORTADA CUENTA DIGITAL BANCOPPEL', ' ', 'informix', today, ' ', ' ' ); 
        
        INSERT INTO bdidigital@coppelimg_crx:dg_expediente_img1 
        ( empresa, cliente, cod_docto, secuencia, imagen, imagen_formato, observaciones, usuario_alta, fecha_alta, usuario_modif, fecha_modif ) 
        VALUES 
        ( '001', TRIM(pNumCte), '0168', iId, null, 'png', ' ', 'informix', CURRENT, ' ', ' ' ); 
        
        --- RETURN cCodret WITH RESUME;
    END FOREACH;

    FOREACH
        --- Select substr(ruta, CHARINDEX('.',ruta)-1,1) as id, ruta 
        Select 1 as id, ruta 
          into iId, cRuta 
          from bdinteg:si_ctanvl2_rutaimg
         where ruta like '%Car%'
        
        /* ##############################################################################################################################################
        insert into bdidigital@coppelimg_crx:"informix".dg_expediente 
        ( empresa, cliente, cuenta, producto, cod_docto, secuencia, prod_nombre, descrip2, usuario_alta, fecha_alta, usuario_modif, fecha_modif ) 
        values 
        ( '001', TRIM(pNumCte), TRIM(pNumCta), TRIM(pNumProd), '167', iId, 'CARATULA CUENTA DIGITAL BANCOPPEL', ' ', 'informix', today, '', '' );
        
        EXECUTE PROCEDURE bdidigital@coppelimg_crx:"informix".sp_insertarimgdigital(TRIM(pNumCte), TRIM(cRuta), iId, '167') 
        into cCodret;
        ############################################################################################################################################## */
        
        insert into bdidigital@coppelimg_crx:dg_expediente 
        ( empresa, cliente, cuenta, producto, cod_docto, secuencia, prod_nombre, descrip2, usuario_alta, fecha_alta, usuario_modif, fecha_modif ) 
        values 
        ( '001', TRIM(pNumCte), TRIM(pNumCta), TRIM(pNumProd), '0167', iId, 'CARATULA CUENTA DIGITAL BANCOPPEL', ' ', 'informix', today, '', '' );
        
        INSERT INTO bdidigital@coppelimg_crx:dg_expediente_img1 
        ( empresa, cliente, cod_docto, secuencia, imagen, imagen_formato, observaciones, usuario_alta, fecha_alta, usuario_modif, fecha_modif ) 
        VALUES 
        ( '001', TRIM(pNumCte), '0167', iId, null, 'png', ' ', 'informix', CURRENT, ' ', ' ' ); 
        
        --- RETURN cCodret WITH RESUME;
    END FOREACH;

    FOREACH
        --- Select substr(ruta, CHARINDEX('.',ruta)-1,1) as id, ruta 
        Select 1 as id, ruta 
          into iId, cRuta 
          from bdinteg:si_ctanvl2_rutaimg
         where ruta like '%Con%'
        
        /* ##############################################################################################################################################
        insert into bdidigital@coppelimg_crx:"informix".dg_expediente 
        ( empresa, cliente, cuenta, producto, cod_docto, secuencia, prod_nombre, descrip2, usuario_alta, fecha_alta, usuario_modif, fecha_modif ) 
        values 
        ( '001', TRIM(pNumCte), TRIM(pNumCta), TRIM(pNumProd), '166', iId, 'CONTRATO CUENTA DIGITAL BANCOPPEL', ' ', 'informix', today, ' ', ' ' ); 
        
        EXECUTE PROCEDURE bdidigital@coppelimg_crx:"informix".sp_insertarimgdigital(TRIM(pNumCte), TRIM(cRuta), iId, '166') 
        into cCodret;
        ############################################################################################################################################## */
        
        insert into bdidigital@coppelimg_crx:dg_expediente 
        ( empresa, cliente, cuenta, producto, cod_docto, secuencia, prod_nombre, descrip2, usuario_alta, fecha_alta, usuario_modif, fecha_modif ) 
        values 
        ( '001', TRIM(pNumCte), TRIM(pNumCta), TRIM(pNumProd), '0166', iId, 'CONTRATO CUENTA DIGITAL BANCOPPEL', ' ', 'informix', today, ' ', ' ' ); 
        
        INSERT INTO bdidigital@coppelimg_crx:dg_expediente_img1 
        ( empresa, cliente, cod_docto, secuencia, imagen, imagen_formato, observaciones, usuario_alta, fecha_alta, usuario_modif, fecha_modif ) 
        VALUES 
        ( '001', TRIM(pNumCte), '0166', iId, null, 'png', ' ', 'informix', CURRENT, ' ', ' ' ); 
        
        --- RETURN cCodret WITH RESUME;
    END FOREACH;
    
    RETURN cCodret;
    
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR:Daniel Reyes Guillen',
'FECHA: 05/04/2021',
'MODULO: ',
'FUNCIONALIDAD: ',
'DESCRIPCION:',
'BD: bdinteg';

CREATE PROCEDURE "informix".limpia_cadenaweb(Ccadena CHAR(100)) 
    returning CHAR(100);
    
    define i integer;
    define Cregreso CHAR(100);
    
    LET i = 0;
    LET Cregreso = '';           
    BEGIN
   
     --SET DEBUG FILE TO "/informix/vic/limpia_cadena_web.out";
     --TRACE ON;
    
        LET Ccadena = trim(Ccadena);
        LET Ccadena = replace(Ccadena,'ÃÂ','A');
        LET Ccadena = replace(Ccadena,'ÃÂ','E');
        LET Ccadena = replace(Ccadena,'ÃÂ','I');
        LET Ccadena = replace(Ccadena,'ÃÂ','O');
        LET Ccadena = replace(Ccadena,'ÃÂ','U');
			
        LET Ccadena = replace(Ccadena,'á','A');
        LET Ccadena = replace(Ccadena,'é','E');
        LET Ccadena = replace(Ccadena,'í','I');
        LET Ccadena = replace(Ccadena,'ó','O');
        LET Ccadena = replace(Ccadena,'ú','U');
        
        LET Ccadena = replace(Ccadena,'Á','A');
        LET Ccadena = replace(Ccadena,'É','E');
        LET Ccadena = replace(Ccadena,'Í','I');
        LET Ccadena = replace(Ccadena,'Ó','O');
        LET Ccadena = replace(Ccadena,'Ú','U');
		
        LET Ccadena = replace(Ccadena,'¾','N');        
        LET Ccadena = replace(Ccadena,'¡','I');
        LET Ccadena = replace(Ccadena,'¤','N');
        LET Ccadena = replace(Ccadena,'§','5');
        LET Ccadena = replace(Ccadena,'ª','A');
        LET Ccadena = replace(Ccadena,'°','RO');
        LET Ccadena = replace(Ccadena,'´',' ');
        LET Ccadena = replace(Ccadena,'·','A');
        LET Ccadena = replace(Ccadena,'ê','U');
        LET Ccadena = replace(Ccadena,'Ñ','N');
        LET Ccadena = replace(Ccadena,'ñ','N');
        LET Ccadena = replace(Ccadena,'Ô','I');
        LET Ccadena = replace(Ccadena,'Ö','E');
        LET Ccadena = replace(Ccadena,'Ü','U');
        LET Ccadena = replace(Ccadena,'Þ','I');
        LET Ccadena = replace(Ccadena,'?','U');
        LET Ccadena = replace(Ccadena,'µ','A');
        LET Ccadena = replace(Ccadena,'¢','O');
        LET Ccadena = replace(Ccadena,'£','U');
        LET Ccadena = replace(Ccadena,'¦','A');
        LET Ccadena = replace(Ccadena,'¥','N');        
                
        
        
        --LET Ccadena = replace(Ccadena,'#','Ã?Ã?');
		--LET Ccadena = trim(Ccadena); -- mover tempo Aqui
		
        For i=1 to length(Ccadena)
        
            IF upper(substr(Ccadena, i,1)) between chr(65) and chr(90) THEN
                continue;
            ELIF upper(substr(Ccadena, i,1)) between chr(48) and chr(57) THEN
                continue;
           -- ELIF upper(substr(Ccadena, i,1)) IN (chr(58),chr(44),chr(45),chr(46),chr(40),chr(41),chr(32),chr(164),chr(165),chr(209),chr(241), chr(13)) THEN
            ELIF upper(substr(Ccadena, i,1)) IN (chr(58),chr(44),chr(45),chr(46),chr(40),chr(41),chr(32),chr(164),chr(165),chr(209),chr(241)) THEN
                continue;
            ELSE
               LET Ccadena = replace(Ccadena,substr(Ccadena,i,1),'');
            END IF;
           
        End For;
        
        LET Ccadena = replace(Ccadena,chr(165),chr(35));
        LET Ccadena = replace(Ccadena,chr(164),chr(35));
        LET Ccadena = replace(Ccadena,chr(209),chr(35));
        LET Ccadena = replace(Ccadena,chr(241),chr(35));
        --LET Ccadena = replace(Ccadena,chr(46),chr(35)); --MACF
        --LET Ccadena = replace(Ccadena,chr(177),chr(35)); --MACF
        
            
        --LET Cregreso = substr(Ccadena, i-1, 1);
        return trim(Ccadena);
    END;
    
END PROCEDURE;