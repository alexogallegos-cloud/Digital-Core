CREATE PROCEDURE "informix".generainf_perfis( pFechaIni DATE, pFechaFin DATE ) 
RETURNING CHAR(5), CHAR(5), INTEGER;
    
    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE vsql_err         INTEGER;
    DEFINE visam_err        INTEGER;
    DEFINE vdesc_err        CHAR(50);
    DEFINE vcontador        INTEGER;
    DEFINE nComit           SMALLINT;
    
    DEFINE vctemin          CHAR(20);
    DEFINE vctemax          CHAR(20);
    DEFINE cNumCliente      CHAR(20);
    DEFINE cRfc             CHAR(13);      
    DEFINE cApellido1       CHAR(26);
    DEFINE cApellido2       CHAR(26);
    DEFINE cNombre1         CHAR(26);
    DEFINE cNombre2         CHAR(26);
    DEFINE cNacionalidad    CHAR(3);
    DEFINE dFechaNac        DATE;
    DEFINE dFechaInsert     DATE;
    DEFINE cNombreCalle     CHAR(30);
    DEFINE cNumExtCalle     CHAR(10);
    DEFINE cNumIntCalle     CHAR(10);
    DEFINE cColonia         CHAR(32); 
    DEFINE cCodPostal       CHAR(5);  
    DEFINE cMunicipio       CHAR(27);  
    DEFINE cNomCiudadCte    CHAR(30);       
    DEFINE cNoEstado        CHAR(2);       
    DEFINE cActividad       CHAR(3);
    DEFINE cSubActividad    CHAR(3);
    DEFINE cRiesgo          CHAR(4);
    DEFINE cNumCuenta       CHAR(20);
    DEFINE cNumProducto     CHAR(4);
    DEFINE cSucursal        CHAR(4);      
    DEFINE cStatusCta       CHAR(2);
    DEFINE cNombreSuc       CHAR(40);
    DEFINE cEstadoSuc       CHAR(2);
    DEFINE vsql             CHAR(300); 
    DEFINE vstmt            CHAR(200);
    
    LET vcodret1         = '000';
    LET vcodret2         = '000';
    LET vcodret3         = '';
    LET vsql_err         = 0;
    LET visam_err        = 0;
    LET vdesc_err        = '';
    LET vcontador        = 0;
    LET nComit           = 0;
    
    LET vctemin          = '';
    LET vctemax          = '';
    LET cNumCliente      = '';
    LET cRfc             = '';  
    LET cApellido1       = '';
    LET cApellido2       = '';
    LET cNombre1         = '';
    LET cNombre2         = '';
    LET cNacionalidad    = '';
    LET dFechaNac        = '';
    LET dFechaInsert     = '';
    LET cNombreCalle     = '';
    LET cNumExtCalle     = '';
    LET cNumIntCalle     = '';
    LET cColonia         = '';
    LET cCodPostal       = '';
    LET cMunicipio       = '';
    LET cNomCiudadCte    = '';      
    LET cNoEstado        = ''; 
    LET cActividad       = '';
    LET cSubActividad    = '';
    LET cRiesgo          = '';
    LET cNumCuenta       = '';
    LET cNumProducto     = '';
    LET cSucursal        = ''; 
    LET cStatusCta       = '';
    LET cNombreSuc       = '';
    LET cEstadoSuc       = '';
    
    LET vstmt   = '';
    LET vsql    = '';
    
    --- SET DEBUG FILE TO '/resplogifx/conciliachq/generainf_perfis.out';
    --- TRACE ON;
    
    BEGIN

    ON EXCEPTION SET vsql_err, visam_err, vdesc_err
        SET DEBUG FILE TO '/resplogifx/conciliachq/generainf_perfis.err';
        TRACE ON;
        LET vcodret1  = vsql_err;
        LET vcodret2 = visam_err;
        LET vcodret3 = vdesc_err;
        IF nComit = 1 THEN
            ROLLBACK WORK;
        END IF;
        RETURN vcodret1, vcodret2, vcontador;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    CREATE TEMP TABLE tmp_ctes
      (
        numcte CHAR(20)
      ) 
    WITH NO LOG;
    
    INSERT INTO tmp_ctes
    SELECT mae.num_cte
      FROM bdicheq:sc_maechq mae,
           bdicheq:sc_maenoc noc
     WHERE mae.empresa = noc.empresa
       AND mae.cuenta = noc.cuenta
       AND mae.producto <> '1100'
       AND noc.fecha_alta <= pFechaFin
       AND ( ( mae.status_cta != '2' AND mae.fecha_proceso >= pFechaIni ) OR 
             ( mae.status_cta  = '2' AND mae.fec_cancelac  >= pFechaIni ) OR 
             ( mae.status_cta  = '2' AND mae.fecha_proceso >= pFechaIni ) );
             
    INSERT INTO tmp_ctes
    SELECT mae.num_cte
      FROM bdicheq:sc_maechq mae,
           bdicheq:sc_maenoc noc
     WHERE mae.empresa = noc.empresa
       AND mae.cuenta = noc.cuenta
       AND mae.producto = '1100'
       AND mae.fecultdep <= pFechaFin
       AND ( ( mae.status_cta != '2' ) OR
             ( mae.status_cta  = '2' AND mae.fecha_proceso >= pFechaIni ) OR
             ( mae.status_cta  = '2' AND mae.fecha_proceso is null AND mae.fec_ult_mov >= pFechaIni ) );
             
    INSERT INTO tmp_ctes
    SELECT num_cte
      FROM bdinvers:sv_maeinv
     WHERE fecha_alta <= pFechaFin
       AND fecha_venc >= pFechaIni;
       
    INSERT INTO tmp_ctes
    SELECT mae.numcte
      FROM bdicred:sd_maesdoscont dos,
           bdicred:sd_maecred mae
     WHERE dos.num_credito = mae.num_credito
       AND dos.empresa = mae.empresa
       AND dos.fecha BETWEEN pFechaIni AND pFechaFin
       AND mae.fecha_apertura <= pFechaFin;
       
    INSERT INTO tmp_ctes
    SELECT mae.numcte
      FROM bdicred:sd_maesdoscontcrd dos,
           bdicred:sd_maecredcrd mae
     WHERE dos.num_credito = mae.num_credito
       AND dos.empresa = mae.empresa
       AND dos.fecha BETWEEN pFechaIni AND pFechaFin
       AND mae.fecha_apertura <= pFechaFin;
       
    CREATE INDEX idx_cte_tmp ON tmp_ctes(numcte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctes;
       
    SELECT UNIQUE numcte
      FROM tmp_ctes
    INTO TEMP tmp_clientes WITH NO LOG;
    CREATE INDEX idx_cliente_tmp ON tmp_clientes(numcte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_clientes;
    
    SELECT MIN(numcte), MAX(numcte)
      INTO vctemin, vctemax
      FROM tmp_clientes; 

    -- // FOREACH CLIENTES
    FOREACH WITH HOLD
        SELECT numcte
          INTO cNumCliente
          FROM tmp_clientes
         WHERE numcte BETWEEN vctemin AND vctemax
           AND numcte NOT IN( SELECT numcte FROM sc_cuentas_perfis )

        BEGIN WORK;
        LET nComit = 1;
        
        -- // DATOS PERSONALES DEL CLIENTE
        SELECT TRIM(cte.rfc) AS rfc,     
               TRIM(cte.apell_paterno) AS apellpaterno,
               TRIM(cte.apell_materno) AS apellmaterno,    
               TRIM(cte.nombre1) AS nombre1,
               TRIM(cte.nombre2) AS nombre2,
               ctepf.nacionalidad, ctepf.fecha_nac, ctepf.fecha_insert
          INTO cRfc, cApellido1, cApellido2, cNombre1, cNombre2,
               cNacionalidad, dFechaNac, dFechaInsert
          FROM bdinteg:si_cliente cte
          LEFT OUTER JOIN bdinteg:si_ctepf ctepf ON (ctepf.numcte = cte.numcte)
         WHERE cte.numcte = cNumCliente;
         
        -- // DIRECCIÓN PERSONAL DEL CLIENTE 
        SELECT FIRST 1 calle.nombrecalle, dir.numeroextcalle, dir.numerointcalle, zona.nombrezona, dir.cod_postal, zona.municipiozona, cd.nombreciudad, edo.estado
          INTO cNombreCalle, cNumExtCalle, cNumIntCalle, cColonia, cCodPostal, cMunicipio, cNomCiudadCte, cNoEstado
          FROM bdinteg:si_direcciones_actual dir 
          LEFT OUTER JOIN bdinteg:si_catcalles calle ON ( calle.numerocalle = dir.numerocalle )
          LEFT OUTER JOIN bdinteg:si_catzonas zona ON ( zona.numerociudad = dir.numerociudad AND zona.numerocolonia = dir.numerocolonia )
          LEFT OUTER JOIN bdinteg:si_catciudades cd ON ( cd.numerociudad = dir.numerociudad )
          LEFT OUTER JOIN bdinteg:si_estados edo ON ( edo.estado = dir.estado )
         WHERE dir.numcte = cNumCliente
           AND dir.tipo_dir = '1';
           
        IF ( cNombreCalle is null OR cNombreCalle = '' ) OR 
           ( cColonia is null OR cColonia = '' ) OR 
           ( cMunicipio is null OR cMunicipio = '' ) OR 
           ( cNomCiudadCte is null OR cNomCiudadCte = '' ) THEN
           
            -- // DIRECCIÓN TRABAJO DEL CLIENTE 
            SELECT FIRST 1 calle.nombrecalle, dir.numeroextcalle, dir.numerointcalle, zona.nombrezona, dir.cod_postal, zona.municipiozona, cd.nombreciudad, edo.estado
              INTO cNombreCalle, cNumExtCalle, cNumIntCalle, cColonia, cCodPostal, cMunicipio, cNomCiudadCte, cNoEstado
              FROM bdinteg:si_direcciones_actual dir 
              LEFT OUTER JOIN bdinteg:si_catcalles calle ON ( calle.numerocalle = dir.numerocalle )
              LEFT OUTER JOIN bdinteg:si_catzonas zona ON ( zona.numerociudad = dir.numerociudad AND zona.numerocolonia = dir.numerocolonia )
              LEFT OUTER JOIN bdinteg:si_catciudades cd ON ( cd.numerociudad = dir.numerociudad )
              LEFT OUTER JOIN bdinteg:si_estados edo ON ( edo.estado = dir.estado )
             WHERE dir.numcte = cNumCliente
               AND dir.tipo_dir = '2';
        END IF;
        
        SELECT FIRST 1 id_act, id_subact
          INTO cActividad, cSubActividad
          FROM bdinteg:si_bitacoraapertura
         WHERE numcte = cNumCliente
           AND id_pregunta = 6
           AND id_secuencia = ( SELECT MAX(id_secuencia) FROM bdinteg:si_bitacoraapertura WHERE numcte = cNumCliente AND id_pregunta = 6 );
           
        IF cNumCliente IN('000791268','003258205','004986287','002352685','002970192','003680088','005146171','003070142','004224021',
                          '004960008','004970453','006521251','006529614','004496044','006731430','007224164','007316157','007318616',
                          '007336087','007833235','008173185','008581661','008854140','009011413','009089393','009489206','009768896',
                          '009794650','010141322','012440037','012914300','012940427','013313607','014860531','017132825','004399443',
                          '002976751','004092791','004397682','004762510','005716130','006293282','006862956','007316041','008475874',
                          '008694524','008855299','009962331','010353413','011484079','012098379','013156056','013259153','013398135',
                          '014156310','014273866','014564689','016058293','016245536','016276998','016780102') THEN 
            LET cRiesgo = 'ALTO';
        ELSE
            LET cRiesgo = 'BAJO';
        END IF;
         
        -- // CUENTAS DE CHEQUES
        FOREACH
            SELECT mae.cuenta, mae.producto, mae.sucursal, mae.status_cta
              INTO cNumCuenta, cNumProducto, cSucursal, cStatusCta
              FROM bdicheq:sc_maechq mae,
                   bdicheq:sc_maenoc noc
             WHERE mae.num_cte = cNumCliente
               AND noc.empresa = mae.empresa
               AND noc.cuenta = mae.cuenta
               AND mae.producto <> '1100'
               AND noc.fecha_alta <= pFechaFin
               AND ( ( mae.status_cta != '2' AND mae.fecha_proceso >= pFechaIni ) OR 
                     ( mae.status_cta  = '2' AND mae.fec_cancelac  >= pFechaIni ) OR 
                     ( mae.status_cta  = '2' AND mae.fecha_proceso >= pFechaIni ) )
                     
           /* SELECT FIRST 1 suc.nombre, edo.estado
              INTO cNombreSuc, cEstadoSuc
              FROM bdinteg:si_sucursales suc,
                   bdinteg:si_estados edo
             WHERE suc.sucursal = cSucursal
               AND edo.estado = suc.estado;*/

			   
			  SELECT FIRST 1 {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf)}suc.nombre,ptf.cve_estado
			  INTO cNombreSuc, cEstadoSuc
			  FROM bdinteg:si_ptf  ptf,
			       bdinteg:si_sucursales suc
              where ptf.id_ptf=suc.sucursal
              and ptf.id_ptf = cSucursal 
              and ptf.tipo='S';		
   
			   
            INSERT INTO sc_cuentas_perfis VALUES
            ( cNumCliente, cNumCuenta, cApellido1, cApellido2, cNombre1, cNombre2, 'F', cNacionalidad, cActividad, cSubActividad, cRiesgo, cNumProducto, cNombreCalle, cNumExtCalle, 
              cNumIntCalle, cColonia, cCodPostal, cMunicipio, cNomCiudadCte, cNoEstado, dFechaNac, cRfc, '', dFechaInsert, cStatusCta, cSucursal, cNombreSuc, cEstadoSuc );
        END FOREACH;
        
        -- // INVERSIONES CRECIENTES
        FOREACH
            SELECT cuenta, producto, sucursal, status_cta
              INTO cNumCuenta, cNumProducto, cSucursal, cStatusCta
              FROM bdicheq:sc_maechq 
             WHERE num_cte = cNumCliente
               AND producto = '1100'
               AND fecultdep <= pFechaFin
               AND ( ( status_cta != '2' ) OR
                     ( status_cta  = '2' AND fecha_proceso >= pFechaIni ) OR
                     ( status_cta  = '2' AND fecha_proceso is null AND fec_ult_mov >= pFechaIni ) )
                     
           /* SELECT FIRST 1 suc.nombre, edo.estado
              INTO cNombreSuc, cEstadoSuc
              FROM bdinteg:si_sucursales suc,
                   bdinteg:si_estados edo
             WHERE suc.sucursal = cSucursal
               AND edo.estado = suc.estado;*/

			   
			  SELECT FIRST 1 {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf)}suc.nombre,ptf.cve_estado
			  INTO cNombreSuc, cEstadoSuc
			  FROM bdinteg:si_ptf  ptf,
			       bdinteg:si_sucursales suc
              where ptf.id_ptf=suc.sucursal
              and ptf.id_ptf = cSucursal 
              and ptf.tipo='S';	
			   
			   
            INSERT INTO sc_cuentas_perfis VALUES
            ( cNumCliente, cNumCuenta, cApellido1, cApellido2, cNombre1, cNombre2, 'F', cNacionalidad, cActividad, cSubActividad, cRiesgo, cNumProducto, cNombreCalle, cNumExtCalle, 
              cNumIntCalle, cColonia, cCodPostal, cMunicipio, cNomCiudadCte, cNoEstado, dFechaNac, cRfc, '', dFechaInsert, cStatusCta, cSucursal, cNombreSuc, cEstadoSuc );
        END FOREACH;
        
        -- // PAGARES
        FOREACH
            SELECT cuenta, cod_instrum, sucursal, status_cta
              INTO cNumCuenta, cNumProducto, cSucursal, cStatusCta
              FROM bdinvers:sv_maeinv
             WHERE num_cte = cNumCliente
               AND fecha_alta <= pFechaFin 
               AND fecha_venc >= pFechaIni
                     
            /*SELECT FIRST 1 suc.nombre, edo.estado
              INTO cNombreSuc, cEstadoSuc
              FROM bdinteg:si_sucursales suc,
                   bdinteg:si_estados edo
             WHERE suc.sucursal = cSucursal
               AND edo.estado = suc.estado;*/
			   
			   
			  SELECT FIRST 1 {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf)}suc.nombre,ptf.cve_estado
			  INTO cNombreSuc, cEstadoSuc
			  FROM bdinteg:si_ptf  ptf,
			       bdinteg:si_sucursales suc
              where ptf.id_ptf=suc.sucursal
              and ptf.id_ptf = cSucursal 
              and ptf.tipo='S';
			   		  			   

            INSERT INTO sc_cuentas_perfis VALUES
            ( cNumCliente, cNumCuenta, cApellido1, cApellido2, cNombre1, cNombre2, 'F', cNacionalidad, cActividad, cSubActividad, cRiesgo, cNumProducto, cNombreCalle, cNumExtCalle, 
              cNumIntCalle, cColonia, cCodPostal, cMunicipio, cNomCiudadCte, cNoEstado, dFechaNac, cRfc, '', dFechaInsert, cStatusCta, cSucursal, cNombreSuc, cEstadoSuc );
        END FOREACH;
        
        -- // TARJETA DE CREDITO
        FOREACH
            SELECT UNIQUE mae.num_credito, mae.num_producto, mae.sucursal, mae.status_cred
              INTO cNumCuenta, cNumProducto, cSucursal, cStatusCta
              FROM bdicred:sd_maesdoscont dos,
                   bdicred:sd_maecred mae
             WHERE mae.numcte = cNumCliente
               AND dos.num_credito = mae.num_credito
               AND dos.empresa = mae.empresa
               AND dos.fecha BETWEEN pFechaIni AND pFechaFin
               AND mae.fecha_apertura <= pFechaFin
                     
           /* SELECT FIRST 1 suc.nombre, edo.estado
              INTO cNombreSuc, cEstadoSuc
              FROM bdinteg:si_sucursales suc,
                   bdinteg:si_estados edo
             WHERE suc.sucursal = cSucursal
               AND edo.estado = suc.estado;*/
			   
			  SELECT FIRST 1 {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf)}suc.nombre,ptf.cve_estado
			  INTO cNombreSuc, cEstadoSuc
			  FROM bdinteg:si_ptf  ptf,
			       bdinteg:si_sucursales suc
              where ptf.id_ptf=suc.sucursal
              and ptf.id_ptf = cSucursal 
              and ptf.tipo='S';
			   


            INSERT INTO sc_cuentas_perfis VALUES
            ( cNumCliente, cNumCuenta, cApellido1, cApellido2, cNombre1, cNombre2, 'F', cNacionalidad, cActividad, cSubActividad, cRiesgo, cNumProducto, cNombreCalle, cNumExtCalle, 
              cNumIntCalle, cColonia, cCodPostal, cMunicipio, cNomCiudadCte, cNoEstado, dFechaNac, cRfc, '', dFechaInsert, cStatusCta, cSucursal, cNombreSuc, cEstadoSuc );
        END FOREACH;
        
        -- // PRESTAMOS
        FOREACH
            SELECT UNIQUE mae.num_credito, mae.num_producto, mae.sucursal, mae.status_cred
              INTO cNumCuenta, cNumProducto, cSucursal, cStatusCta
              FROM bdicred:sd_maesdoscontcrd dos,
                   bdicred:sd_maecredcrd mae
             WHERE mae.numcte = cNumCliente
               AND dos.num_credito = mae.num_credito
               AND dos.empresa = mae.empresa
               AND dos.fecha BETWEEN pFechaIni AND pFechaFin
               AND mae.fecha_apertura <= pFechaFin
                     
            /*SELECT FIRST 1 suc.nombre, edo.estado
              INTO cNombreSuc, cEstadoSuc
              FROM bdinteg:si_sucursales suc,
                   bdinteg:si_estados edo
             WHERE suc.sucursal = cSucursal
               AND edo.estado = suc.estado;*/
			   
			  SELECT FIRST 1 {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf)}suc.nombre,ptf.cve_estado
			  INTO cNombreSuc, cEstadoSuc
			  FROM bdinteg:si_ptf  ptf,
			       bdinteg:si_sucursales suc
              where ptf.id_ptf=suc.sucursal
              and ptf.id_ptf = cSucursal 
              and ptf.tipo='S';
			   		   
			   
            INSERT INTO sc_cuentas_perfis VALUES
            ( cNumCliente, cNumCuenta, cApellido1, cApellido2, cNombre1, cNombre2, 'F', cNacionalidad, cActividad, cSubActividad, cRiesgo, cNumProducto, cNombreCalle, cNumExtCalle, 
              cNumIntCalle, cColonia, cCodPostal, cMunicipio, cNomCiudadCte, cNoEstado, dFechaNac, cRfc, '', dFechaInsert, cStatusCta, cSucursal, cNombreSuc, cEstadoSuc );
        END FOREACH;
        
        LET vcontador = vcontador + 1;
        
        COMMIT WORK;
        LET nComit = 0;
    END FOREACH;
    
    UPDATE STATISTICS MEDIUM FOR TABLE sc_cuentas_perfis;
    
    -- // DESCARGA LA INFORMACION
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /RESPALDOS/cuentas_perfis.txt SELECT * FROM sc_cuentas_perfis;" > /resplogifx/conciliachq/ctas_perfis.sql';
    SYSTEM vsql;
    
    LET vstmt = '';
    LET vstmt = "/ifxsif01/bin/dbaccess bdinteg /resplogifx/conciliachq/ctas_perfis.sql"; 
    SYSTEM vstmt;
    
    RETURN vcodret1, vcodret2, vcontador;
    
    END;
    
END PROCEDURE;