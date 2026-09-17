CREATE PROCEDURE "informix".sp_dskrgactasinform3anios( pEmpresa char(3) )
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
    DEFINE vFechaHoy            DATE;
    DEFINE vCuenta              CHAR(15);
    DEFINE vStatusCta           CHAR(1);
    DEFINE vSdoActual           DECIMAL(18,2);
    DEFINE vFechaUltimoDep      DATE;
    DEFINE vFechaUltimoRet      DATE;
    DEFINE vFechaAlta           DATE;
    DEFINE vNomProducto         CHAR(40);
	DEFINE vNumProducto         CHAR(40);
	DEFINE vNombre_produc       CHAR(40);
	DEFINE vNumCliente          CHAR(10);
    DEFINE vNumTarjeta          CHAR(20);
    DEFINE vNombreCliente       CHAR(100);
    DEFINE vDireccion           CHAR(200);
    DEFINE cCalle               CHAR(40); 
    DEFINE cNumExt              CHAR(10); 
    DEFINE cNumInt              CHAR(10); 
    DEFINE cDepart              CHAR(10); 
    DEFINE cColonia             CHAR(40); 
    DEFINE cMunicipio           CHAR(30); 
    DEFINE cCiudad              CHAR(20); 
    DEFINE cEdo                 CHAR(10); 
    DEFINE cCodPos              CHAR(10);
    DEFINE vsql                 CHAR(600);
    DEFINE vstmt                CHAR(250);
    DEFINE vfecha               CHAR(8);
    DEFINE vaniomes             CHAR(6);
    DEFINE vFechaInactividad    DATE;
    DEFINE vSucursal            CHAR(4);
    DEFINE vDatosSucursal       CHAR(140);
	DEFINE vnombre1             CHAR(26);
	DEFINE vnombre2             CHAR(26);
	DEFINE vapell_paterno       CHAR(26);
	DEFINE vapell_materno       CHAR(26);
	
    DEFINE vId_ptf              VARCHAR(6); 
    DEFINE vsuc_Nombre          VARCHAR(40); 
    DEFINE vciu_Nombre          VARCHAR(61);  
    DEFINE vedo_Nombre          VARCHAR(30); 


	DEFINE vcuenta_inf          CHAR(15);
	DEFINE vpridia_ant          DATE;
	DEFINE vultdia_ant          DATE;	
		
    
    LET Sql_Err	          = 0;
    LET Isam_Err          = 0;
    LET Desc_Err          = '';
    LET vCodRet1          = '000';
    LET vCodRet2          = '000';
    LET vCodRet3          = '';
    LET vComienza         = -1;
    LET vEnTransacc       = 0;
    LET vContador1        = 0;
    LET vFechaHoy         = '';
    LET vCuenta           = '';   
    LET vStatusCta        = '';
    LET vSdoActual        = 0.00;
    LET vFechaUltimoDep   = '';
    LET vFechaUltimoRet   = '';
    LET vFechaAlta        = '';
    LET vNomProducto      = '';
	LET vNumProducto      = '';
	LET vNombre_produc    = '';
    LET vNumCliente       = '';
    LET vNumTarjeta       = '';
    LET vNombreCliente    = '';
    LET vDireccion        = '';
    LET cCalle            = '';
    LET cNumExt           = '';
    LET cNumInt           = '';
    LET cDepart           = '';
    LET cColonia          = '';
    LET cMunicipio        = '';
    LET cCiudad           = '';
    LET cEdo              = '';
    LET cCodPos           = '';
    LET vsql              = '';
    LET vstmt             = '';
    LET vfecha            = '';
    LET vaniomes          = '';
    LET vFechaInactividad = '';
    LET vSucursal         = '';
    LET vDatosSucursal    = '';
    LET vnombre1          = '';
	LET vnombre2          = '';
	LET vapell_paterno    = '';
	LET vapell_materno    = '';
	
	LET vId_ptf           = '';   
    LET vsuc_Nombre       = '';
    LET vciu_Nombre       = '';
    LET vedo_Nombre       = '';
	
	LET vcuenta_inf       = ''; 
	
	--SET DEBUG FILE TO '/informix/PRISCILLA/sp_dskrgactasinform3anios.out';
    --trace on;

    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
         IF Sql_Err <> 0 THEN
		 SET DEBUG FILE TO "/resplogifx/conciliachq/sp_dskrgactasinform3anios.err";
         TRACE ON;
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
			LET vCuenta  = vCuenta;
            IF vEnTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1, vCodRet2, vCodRet3, vContador1;
        END IF;
    END EXCEPTION;
    
	
    ---SET DEBUG FILE TO "/resplogifx/conciliachq/sp_dskrgactasinform3anios.out";
	--SET DEBUG FILE TO "/informix/rsv/ART61/dsk3/sp_dskrgactasinform3anios.out";
    --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
  
	    -- // OBTINENE LA FECHA DE HOY    --RSV SE AGREGARON ALGUNAS FECHAS
    SELECT fecha_hoy, DATE(pri_dia_mes - 1 UNITS MONTH),DATE(pri_dia_mes - 1  UNITS DAY)
      INTO vFechaHoy, vpridia_ant,                      vultdia_ant
      FROM bdicheq:"informix".sc_fechas
     WHERE empresa = pEmpresa;
	
	
    FOREACH WITH HOLD
	
	
		 -- RSV SE AGREGO UNA CONSULTA PARA EXTRAER INFORMACION DEL MES ANTERIOR 	
	     SELECT ---{+INDEX(sc_ctasinformadas idx_ctainform_fecha_marc)}
		        a.cuenta 
		   INTO vcuenta_inf
		   FROM sc_ctasinformadas AS a, 
                sc_maechq         AS b
          WHERE a.cuenta = b.cuenta 
            AND a.fecha_marc BETWEEN vpridia_ant AND  vultdia_ant
            AND b.sdo_actual > 0
            AND b.status_cta = '5'
	
        SELECT mae.cuenta, mae.num_cte, mae.status_cta, mae.sdo_actual, mae.fecultdep,   mae.fecultret,   noc.fecha_alta, mae.producto, pro.nombre,     NVL(tar.num_tarjeta, ' '), cte.nombre1, cte.nombre2, cte.apell_paterno, cte.apell_materno, mae.sucursal
          INTO vCuenta,    vNumCliente, vStatusCta,     vSdoActual,     vFechaUltimoDep, vFechaUltimoRet, vFechaAlta,     vNumProducto, vNombre_produc, vNumTarjeta,               vnombre1,    vnombre2,    vapell_paterno,    vapell_materno,    vSucursal
          FROM bdicheq:"informix".sc_maechq mae
         INNER JOIN bdicheq:"informix".sc_maenoc noc ON ( noc.empresa = mae.empresa AND noc.cuenta = mae.cuenta )
         INNER JOIN bdicheq:"informix".sc_producto pro ON ( pro.empresa = mae.empresa AND pro.producto = mae.producto )
         INNER JOIN bdinteg:"informix".si_cliente cte ON ( cte.numcte = mae.num_cte )
          LEFT OUTER JOIN bdicheq:"informix".sc_tarjeta tar ON ( tar.empresa = mae.empresa AND 
                                                                 tar.cuenta = mae.cuenta AND 
                                                                 tar.tipo_tarjeta = 'T' AND
                                                                 tar.status_tar = 'A' AND 
                                                                 tar.secuencia = ( SELECT MAX(secuencia)
                                                                                     FROM bdicheq:"informix".sc_tarjeta
                                                                                    WHERE empresa = pEmpresa
                                                                                      AND cuenta = mae.cuenta
                                                                                      AND tipo_tarjeta = 'T'
                                                                                      AND status_tar = 'A' ) )
         WHERE mae.empresa = pEmpresa
           AND mae.status_cta = '5'
           AND mae.producto <> '1100'
           AND mae.sdo_actual > 0.00
		   AND mae.cuenta = vcuenta_inf;   ---RSV PARA QUE TOME SOLO CUENTAS QUE ESTAMOS ASIGANDO EN LOS RANGOS DE FECHAS
		              
		    LET vNomProducto   = TRIM(NVL(vNumProducto,' '))||' '||TRIM(NVL(vNombre_produc,' '));
		    LET vNombreCliente = TRIM(NVL(vnombre1,' ')) ||' '|| TRIM(NVL(vnombre2,' ')) ||' '|| TRIM(NVL(vapell_paterno,' ')) ||' '|| TRIM(NVL(vapell_materno,' '));
		   
		   
		   
        /*SELECT mae.cuenta, mae.num_cte, mae.status_cta, mae.sdo_actual, mae.fecultdep, mae.fecultret, noc.fecha_alta, mae.producto||' '||TRIM(NVL(pro.nombre,' ')),
               NVL(tar.num_tarjeta, ' '), TRIM(cte.nombre1)||' '||TRIM(cte.nombre2)||' '||TRIM(cte.apell_paterno)||' '||TRIM(cte.apell_materno), mae.sucursal
          INTO vCuenta, vNumCliente, vStatusCta, vSdoActual, vFechaUltimoDep, vFechaUltimoRet, vFechaAlta, vNomProducto, vNumTarjeta, vNombreCliente, vSucursal
          FROM bdicheq:"informix".sc_maechq mae
         INNER JOIN bdicheq:"informix".sc_maenoc noc ON ( noc.empresa = mae.empresa AND noc.cuenta = mae.cuenta )
         INNER JOIN bdicheq:"informix".sc_producto pro ON ( pro.empresa = mae.empresa AND pro.producto = mae.producto )
         INNER JOIN bdinteg:"informix".si_cliente cte ON ( cte.numcte = mae.num_cte )
         LEFT OUTER JOIN bdicheq:"informix".sc_tarjeta tar ON ( tar.empresa = mae.empresa AND 
                                                                 tar.cuenta = mae.cuenta AND 
                                                                 tar.tipo_tarjeta = 'T' AND
                                                                 tar.status_tar = 'A' AND 
                                                                 tar.secuencia = ( SELECT MAX(secuencia)
                                                                                     FROM bdicheq:"informix".sc_tarjeta
                                                                                    WHERE empresa = pEmpresa
                                                                                      AND cuenta = mae.cuenta
                                                                                      AND tipo_tarjeta = 'T'
                                                                                      AND status_tar = 'A' ) )
         WHERE mae.empresa = pEmpresa
           AND mae.status_cta = '5'
		   AND mae.producto <> '1100'
           AND mae.sdo_actual > 0.00*/
          
        IF vComienza = -1 THEN
            LET vComienza = 0;
        END IF;    
        
        BEGIN WORK;
        LET vEnTransacc = 1;
        
        -- // OBTIENE LA FECHA DE INACTIVIDAD
        IF vFechaUltimoDep is null OR vFechaUltimoDep = '' THEN
            LET vFechaUltimoDep = vFechaAlta;
        END IF;
        
        IF vFechaUltimoRet is null OR vFechaUltimoRet = '' THEN
            LET vFechaUltimoRet = vFechaAlta;
        END IF;
        
        IF vFechaUltimoRet >= vFechaUltimoDep THEN
            LET vFechaInactividad = vFechaUltimoRet;
        ELSE
            LET vFechaInactividad = vFechaUltimoDep;
        END IF;
        
        LET vFechaInactividad = vFechaInactividad + 3 UNITS YEAR;
        
        -- // OBTIENE LA INFORMACION DEL DOMICILIO DEL CLIENTE
        SELECT calle.nombrecalle, 
               dir.numeroextcalle,
               dir.numerointcalle,
               dir.departamento,  
               zona.nombrezona,   
               zona.municipiozona,
               ciu.nombreciudad,  
               ciu.inicialestado, 
               dir.cod_postal    
          INTO cCalle, cNumExt, cNumInt, cDepart, cColonia, cMunicipio, cCiudad, cEdo, cCodPos
          FROM bdinteg:"informix".si_direcciones_actual dir
          LEFT OUTER JOIN bdinteg:"informix".si_catcalles calle ON (calle.numerocalle = dir.numerocalle)
          LEFT OUTER JOIN bdinteg:"informix".si_catzonas zona   ON (zona.numerociudad = dir.numerociudad AND zona.numerocolonia = dir.numerocolonia)
          LEFT OUTER JOIN bdinteg:"informix".si_catciudades ciu ON (ciu.numerociudad = dir.numerociudad)
         WHERE dir.numcte = vNumCliente
           AND dir.tipo_dir = '1';

		   LET vDireccion = TRIM(NVL(cCalle,' ')) ||' '|| TRIM(NVL(cNumExt,' ')) ||' '|| TRIM(NVL(cNumInt,' '))||' '||TRIM(NVL(cDepart,' '))||' '||TRIM(NVL(cColonia,' '))||' '||TRIM(NVL(cMunicipio,' '))||' '||TRIM(NVL(cCiudad,' '))||' '||TRIM(NVL(cEdo,' '))||' '||TRIM(NVL(cCodPos,' '));                                                
    		   		   
        /*SELECT TRIM(NVL(calle.nombrecalle,  ' ')) ||' '|| 
               TRIM(NVL(dir.numeroextcalle, ' ')) ||' '|| 
               TRIM(NVL(dir.numerointcalle, ' ')) ||' '|| 
               TRIM(NVL(dir.departamento,   ' ')) ||' '||
               TRIM(NVL(zona.nombrezona,    ' ')) ||' '|| 
               TRIM(NVL(zona.municipiozona, ' ')) ||' '|| 
               TRIM(NVL(ciu.nombreciudad,   ' ')) ||' '|| 
               TRIM(NVL(ciu.inicialestado,  ' ')) ||' '||
               TRIM(NVL(dir.cod_postal,     ' ')),
               TRIM(NVL(calle.nombrecalle,  ' ')),
               TRIM(NVL(dir.numeroextcalle, ' ')),
               TRIM(NVL(dir.numerointcalle, ' ')),
               TRIM(NVL(dir.departamento,   ' ')),
               TRIM(NVL(zona.nombrezona,    ' ')),
               TRIM(NVL(zona.municipiozona, ' ')),
               TRIM(NVL(ciu.nombreciudad,   ' ')),
               TRIM(NVL(ciu.inicialestado,  ' ')),
               TRIM(NVL(dir.cod_postal,     ' '))
          INTO vDireccion, cCalle, cNumExt, cNumInt, cDepart, cColonia, cMunicipio, cCiudad, cEdo, cCodPos
          FROM bdinteg:"informix".si_direcciones_actual dir
          LEFT OUTER JOIN bdinteg:"informix".si_catcalles calle ON (calle.numerocalle = dir.numerocalle)
          LEFT OUTER JOIN bdinteg:"informix".si_catzonas zona   ON (zona.numerociudad = dir.numerociudad AND zona.numerocolonia = dir.numerocolonia)
          LEFT OUTER JOIN bdinteg:"informix".si_catciudades ciu ON (ciu.numerociudad = dir.numerociudad)
         WHERE dir.numcte = vNumCliente
           AND dir.tipo_dir = '1';*/
           
        IF vDireccion is null OR vDireccion = '' THEN
            SELECT calle.nombrecalle, 
                   dir.numeroextcalle,
                   dir.numerointcalle,
                   dir.departamento,  
                   zona.nombrezona,   
                   zona.municipiozona,
                   ciu.nombreciudad,  
                   ciu.inicialestado, 
                   dir.cod_postal   
              INTO cCalle, cNumExt, cNumInt, cDepart, cColonia, cMunicipio, cCiudad, cEdo, cCodPos
              FROM bdinteg:"informix".si_direcciones_actual dir
              LEFT OUTER JOIN bdinteg:"informix".si_catcalles calle ON (calle.numerocalle = dir.numerocalle)
              LEFT OUTER JOIN bdinteg:"informix".si_catzonas zona   ON (zona.numerociudad = dir.numerociudad AND zona.numerocolonia = dir.numerocolonia)
              LEFT OUTER JOIN bdinteg:"informix".si_catciudades ciu ON (ciu.numerociudad = dir.numerociudad)
             WHERE dir.numcte = vNumCliente
               AND dir.tipo_dir = '2';
		   		   
		       LET vDireccion = TRIM(NVL(cCalle,' ')) ||' '|| TRIM(NVL(cNumExt,' ')) ||' '|| TRIM(NVL(cNumInt,' '))||' '||TRIM(NVL(cDepart,' '))||' '||TRIM(NVL(cColonia,' '))||' '||TRIM(NVL(cMunicipio,' '))||' '||TRIM(NVL(cCiudad,' '))||' '||TRIM(NVL(cEdo,' '))||' '||TRIM(NVL(cCodPos,' '));                                                
		   
          /*SELECT TRIM(calle.nombrecalle)  ||' '|| 
                   TRIM(dir.numeroextcalle) ||' '|| 
                   TRIM(dir.numerointcalle) ||' '|| 
                   TRIM(dir.departamento)   ||' '||
                   TRIM(zona.nombrezona)    ||' '||
                   TRIM(zona.municipiozona) ||' '||
                   TRIM(ciu.nombreciudad)   ||' '||
                   TRIM(ciu.inicialestado)  ||' '||
                   TRIM(dir.cod_postal),
                   TRIM(NVL(calle.nombrecalle,  ' ')),
                   TRIM(NVL(dir.numeroextcalle, ' ')),
                   TRIM(NVL(dir.numerointcalle, ' ')),
                   TRIM(NVL(dir.departamento,   ' ')),
                   TRIM(NVL(zona.nombrezona,    ' ')),
                   TRIM(NVL(zona.municipiozona, ' ')),
                   TRIM(NVL(ciu.nombreciudad,   ' ')),
                   TRIM(NVL(ciu.inicialestado,  ' ')),
                   TRIM(NVL(dir.cod_postal,     ' '))     
              INTO vDireccion, cCalle, cNumExt, cNumInt, cDepart, cColonia, cMunicipio, cCiudad, cEdo, cCodPos
              FROM bdinteg:"informix".si_direcciones_actual dir
              LEFT OUTER JOIN bdinteg:"informix".si_catcalles calle ON (calle.numerocalle = dir.numerocalle)
              LEFT OUTER JOIN bdinteg:"informix".si_catzonas zona   ON (zona.numerociudad = dir.numerociudad AND zona.numerocolonia = dir.numerocolonia)
              LEFT OUTER JOIN bdinteg:"informix".si_catciudades ciu ON (ciu.numerociudad = dir.numerociudad)
             WHERE dir.numcte = vNumCliente
               AND dir.tipo_dir = '2';*/
               
         IF vDireccion is null OR vDireccion = '' THEN
                SELECT calle.nombrecalle, 
                       dir.numeroextcalle,
                       dir.numerointcalle,
                       dir.departamento,  
                       zona.nombrezona,   
                       zona.municipiozona,
                       ciu.nombreciudad,  
                       ciu.inicialestado, 
                       dir.cod_postal   
                  INTO cCalle, cNumExt, cNumInt, cDepart, cColonia, cMunicipio, cCiudad, cEdo, cCodPos
                  FROM bdinteg:"informix".si_direcciones_actual dir
                  LEFT OUTER JOIN bdinteg:"informix".si_catcalles calle ON (calle.numerocalle = dir.numerocalle)
                  LEFT OUTER JOIN bdinteg:"informix".si_catzonas zona   ON (zona.numerociudad = dir.numerociudad AND zona.numerocolonia = dir.numerocolonia)
                  LEFT OUTER JOIN bdinteg:"informix".si_catciudades ciu ON (ciu.numerociudad = dir.numerociudad)
                 WHERE dir.numcte = vNumCliente
                   AND dir.tipo_dir = '3';
		   		   
		           LET vDireccion = TRIM(NVL(cCalle,' ')) ||' '|| TRIM(NVL(cNumExt,' ')) ||' '|| TRIM(NVL(cNumInt,' '))||' '||TRIM(NVL(cDepart,' '))||' '||TRIM(NVL(cColonia,' '))||' '||TRIM(NVL(cMunicipio,' '))||' '||TRIM(NVL(cCiudad,' '))||' '||TRIM(NVL(cEdo,' '))||' '||TRIM(NVL(cCodPos,' '));                                                
             
			 /*SELECT TRIM(calle.nombrecalle)  ||' '|| 
                       TRIM(dir.numeroextcalle) ||' '|| 
                       TRIM(dir.numerointcalle) ||' '|| 
                       TRIM(dir.departamento)   ||' '||
                       TRIM(zona.nombrezona)    ||' '||
                       TRIM(zona.municipiozona) ||' '||
                       TRIM(ciu.nombreciudad)   ||' '||
                       TRIM(ciu.inicialestado)  ||' '||
                       TRIM(dir.cod_postal),
                       TRIM(NVL(calle.nombrecalle,  ' ')),
                       TRIM(NVL(dir.numeroextcalle, ' ')),
                       TRIM(NVL(dir.numerointcalle, ' ')),
                       TRIM(NVL(dir.departamento,   ' ')),
                       TRIM(NVL(zona.nombrezona,    ' ')),
                       TRIM(NVL(zona.municipiozona, ' ')),
                       TRIM(NVL(ciu.nombreciudad,   ' ')),
                       TRIM(NVL(ciu.inicialestado,  ' ')),
                       TRIM(NVL(dir.cod_postal,     ' '))      
                  INTO vDireccion, cCalle, cNumExt, cNumInt, cDepart, cColonia, cMunicipio, cCiudad, cEdo, cCodPos
                  FROM bdinteg:"informix".si_direcciones_actual dir
                  LEFT OUTER JOIN bdinteg:"informix".si_catcalles calle ON (calle.numerocalle = dir.numerocalle)
                  LEFT OUTER JOIN bdinteg:"informix".si_catzonas zona   ON (zona.numerociudad = dir.numerociudad AND zona.numerocolonia = dir.numerocolonia)
                  LEFT OUTER JOIN bdinteg:"informix".si_catciudades ciu ON (ciu.numerociudad = dir.numerociudad)
                 WHERE dir.numcte = vNumCliente
                   AND dir.tipo_dir = '3';*/
                   
                IF vDireccion is null OR vDireccion = '' THEN
                    LET vDireccion = 'DIRECCION NO ENCONTRADA';
                END IF;
            END IF;
        END IF;
        
        SELECT ptf.id_ptf, suc.nombre,  ciu.nombre,  edo.nombre
		  INTO vId_ptf,    vsuc_Nombre, vciu_Nombre, vedo_Nombre
          FROM bdinteg:"informix".si_ptf ptf,
               bdinteg:"informix".si_sucursales suc,
               bdinteg:"informix".si_ciudades ciu,
               bdinteg:"informix".si_estados edo
         WHERE ptf.id_ptf = vSucursal
           AND ptf.id_ptf = suc.sucursal 
           AND ptf.tipo   = suc.tipo
           AND ptf.tipo <> 'C'
           AND ciu.ciudad = ptf.cve_ciudad
           AND ciu.estado = edo.estado
           AND edo.estado = ptf.cve_estado;

		   LET vDatosSucursal = TRIM(NVL(vId_ptf,' '))||' '||TRIM(NVL(vsuc_Nombre,' '))||' '||TRIM(NVL(vciu_Nombre,' '))||' '||TRIM(NVL(vedo_Nombre,' ')); 

        /*SELECT suc.sucursal||' '||TRIM(suc.nombre)||' '||TRIM(ciu.nombre)||' '||TRIM(edo.nombre)
          INTO vDatosSucursal
          FROM bdinteg:"informix".si_sucursales suc,
               bdinteg:"informix".si_ciudades ciu,
               bdinteg:"informix".si_estados edo
         WHERE suc.sucursal = vSucursal
           AND ciu.ciudad = suc.ciudad
           AND ciu.estado = edo.estado
           AND edo.estado = suc.estado;*/
		   
        INSERT INTO bdicheq:"informix".sc_ctasinactinfor3anios 
        ( num_cte, cliente, producto, cuenta, status_cta, sdo_actual, num_tarjeta, fech_ult_dep, fech_ult_ret, fech_inactividad, 
          domicilio, fecha_rep, calle, no_ext, no_int, depto, colonia, municipio, ciudad, estado, codpos, sucursal )
        VALUES
        ( vNumCliente, vNombreCliente, vNomProducto, vCuenta, vStatusCta, vSdoActual, vNumTarjeta, vFechaUltimoDep, vFechaUltimoRet, vFechaInactividad, 
          vDireccion, vFechaHoy, cCalle, cNumExt, cNumInt, cDepart, cColonia, cMunicipio, cCiudad, cEdo, cCodPos, vDatosSucursal );
           
        LET vContador1 = vContador1 + 1;
        
        COMMIT WORK;
        LET vEnTransacc = 0;
    END FOREACH;
    
    -- // GENERA EL ARCHIVO DE TODAS LAS CUENTAS PARA OPERACIONES
    LET vfecha = TO_CHAR(vFechaHoy, '%d%m%Y');
     
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/originales/CuentasInactivas3anios_'||vfecha||'.txt '||
               'SELECT producto, num_cte, num_tarjeta, cuenta, trim(sucursal), trim(cliente), sdo_actual, fech_inactividad, '||
               'to_char(fech_ult_dep,'''||'%d/%m/%Y'||'''), to_char(fech_ult_ret,'''||'%d/%m/%Y'||'''), '||
               'trim(domicilio), trim(calle), trim(no_ext), trim(no_int), trim(depto), trim(colonia), trim(municipio), trim(ciudad), trim(estado), codpos '||
               'FROM sc_ctasinactinfor3anios WHERE fecha_rep = '''||vFechaHoy||''' " > /resplogifx/conciliachq/originales/ctasinact3.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '';
    LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/originales/ctasinact3.sql"; 
    SYSTEM vstmt;
    LET vstmt = '';

    -- // GENERA LOS ARCHIVOS PARA CORRESPONDENCIA COPPEL PARA EL ENVIO DE CARTAS
    LET vaniomes = TO_CHAR(vFechaHoy, '%Y%m');
    

    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/originales/CtasInactivas3anios_'||vaniomes||'.txt '||
               'SELECT producto, num_cte, num_tarjeta, cuenta, substr(cuenta, length(cuenta) -3, 4), cliente, '||
               'lpad(sdo_actual::varchar(20), 20, '' ''), calle, no_ext, no_int, depto, colonia, ciudad, estado, codpos, to_char(fech_inactividad, ''%Y-%m-%d'') '||
               'FROM sc_ctasinactinfor3anios WHERE fecha_rep = '''||vFechaHoy||''' " > /resplogifx/conciliachq/originales/ctasinact3.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '';
    LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/originales/ctasinact3.sql"; 
    SYSTEM vstmt;
    LET vstmt = '';
   
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/originales/CtasInactivas3anios_CifrasCtrl_'||vaniomes||'.txt '||
               'SELECT lpad((count(*)::integer)::varchar(20), 20, '' ''), lpad((SUM(sdo_actual::decimal(18,2)))::varchar(20), 20, '' '') '|| 
               'FROM sc_ctasinactinfor3anios WHERE fecha_rep = '''||vFechaHoy||''' " > /resplogifx/conciliachq/originales/ctasinact3.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '';
    LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/originales/ctasinact3.sql"; 
    SYSTEM vstmt;
    LET vstmt = '';
 
    END; 
    
    RETURN vCodRet1, vCodRet2, vCodRet3, vContador1;
    
END PROCEDURE;