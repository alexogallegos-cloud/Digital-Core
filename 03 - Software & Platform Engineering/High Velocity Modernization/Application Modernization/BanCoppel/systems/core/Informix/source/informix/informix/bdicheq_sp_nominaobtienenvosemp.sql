CREATE PROCEDURE "informix".sp_nominaobtienenvosemp(pfechainicial CHAR(10),pfechafinal CHAR(10))
	RETURNING CHAR(5), CHAR(20), CHAR(8), CHAR(40),CHAR(40),CHAR(40),CHAR(40);

---- VARIABLES  GENERALES---
DEFINE cSqlerr			 INTEGER;
DEFINE cCodret      	 CHAR(5);
DEFINE vsSQL    CHAR(100);
DEFINE cCuenta    CHAR(20);
DEFINE cNum_Empleado CHAR(8);
DEFINE cListadoProducto CHAR(50);
DEFINE cContador INTEGER;
DEFINE cApell_paterno  CHAR(40);
DEFINE cApell_materno CHAR(40);
DEFINE cNombre1 CHAR(40);
DEFINE cNombre2 CHAR(40);



--VALORES INICIALES
LET cSqlerr = '';
LET cCodret = '00000';
LET vsSQL    = '';
LET cCuenta  = '';
LET cNum_Empleado = '';
LET cListadoProducto = '';
LET cContador = 0;
LET cApell_paterno = '';
LET cApell_materno = '';
LET cNombre1 = '';
LET cNombre2 = '';


--SET debug FILE TO "/tmp/sp_NominaObtieneNvosEmp.out";
--Trace ON;

Begin
	------  Control de Errores no Controlados
    ON EXCEPTION SET cSqlerr
        IF cSqlerr <> 0 THEN
            Let cCodret = cSqlerr;    
            RETURN NVL(cCodret,''),NVL(cCuenta,''),NVL(cNum_Empleado,''),NVL(cApell_paterno,''),NVL(cApell_materno,''),NVL(cNombre1,''),NVL(cNombre2,'');
        END IF;
	END EXCEPTION;
	---VALIDAR SI SON NULLOS
	IF TRIM(pFechaInicial) = '' OR (pFechaInicial IS NULL) OR TRIM(pFechaFinal) = '' OR (pFechaFinal IS NULL) THEN
		--ERROR EN LOS PARAMETROS  SON NULLOS
		Let cCodret = '563';    
        RETURN NVL(cCodret,''),NVL(cCuenta,''),NVL(cNum_Empleado,''),NVL(cApell_paterno,''),NVL(cApell_materno,''),NVL(cNombre1,''),NVL(cNombre2,'');
	END IF;	
	--VALIDAR EL TAMAÑO
	IF LENGTH(TRIM(pFechaInicial)) <> 10 OR  LENGTH(TRIM(pFechaFinal)) <> 10 THEN
		--EL TAMAÑO DE LAS FECHAS NO ES EL CORRECTO
		Let cCodret = '562';    
        RETURN NVL(cCodret,''),NVL(cCuenta,''),NVL(cNum_Empleado,''),NVL(cApell_paterno,''),NVL(cApell_materno,''),NVL(cNombre1,''),NVL(cNombre2,'');
	END IF;	
	
	--SE OBTIENE LOS PRODUCTOS QUE ESTAN EN LA sc_nominaempresas 
	SELECT acepta_producto INTO cListadoProducto FROM Bdicheq:sc_nominaempresas WHERE codigo = '001';
	
	FOREACH WITH HOLD
		SELECT NVL(pf.numeric2,'0'), noc.cuenta,TRIM(apell_paterno),TRIM(apell_materno),TRIM(nombre1),TRIM(nombre2)
		INTO cNum_Empleado, cCuenta, cApell_paterno, cApell_materno, cNombre1, cNombre2
		FROM bdicheq:sc_maenoc AS noc
		INNER Join bdicheq:sc_maechq AS chq ON (chq.cuenta = noc.cuenta)
		INNER Join bdinteg:si_ctepf AS pf ON (chq.num_cte = pf.numcte)
		INNER Join bdinteg:si_cliente AS cte ON (chq.num_cte = cte.numcte)
		WHERE LPAD(pf.numeric1,3,'0') = '001'
		AND noc.fecha_alta >=  pFechaInicial
		AND noc.fecha_alta <=  pFechaFinal
		AND chq.empresa = '001'
		AND cListadoProducto LIKE '%'||chq.producto||'%'
		
		--validar que tengan numero de empleado sino no se mandan
		IF TRIM(cNum_Empleado) = '0' THEN
			CONTINUE FOREACH;
		END IF;
		LET cContador = cContador + 1;
		RETURN NVL(cCodret,''),NVL(cCuenta,''),NVL(cNum_Empleado,''),NVL(cApell_paterno,''),NVL(cApell_materno,''),NVL(cNombre1,''),NVL(cNombre2,'') WITH RESUME;
	END FOREACH;
	
	IF cContador = 0 THEN
		--NO HAY REGISTROS
		LET cCodret = '568';
		RETURN NVL(cCodret,''),NVL(cCuenta,''),cNum_Empleado,NVL(cApell_paterno,''),NVL(cApell_materno,''),NVL(cNombre1,''),NVL(cNombre2,'');
	END IF;
END
END PROCEDURE
DOCUMENT
'AUTOR :César Valdéz Figueroa',
'DESCRIPCION:  Procedimiento que obtiene las cuentas de la empresa 001-BanCoppel, cuentas de nomina que se dieron de alta en un rango de fechas.',
'FECHA : Octubre de 2009',
'BD    : BDICHEQ',
'VERSION: 20091014.0630',

'MODIFICO :César Valdéz Figueroa',
'DESCRIPCION:  Se modifico el procedimiento agregando un filtro al select principal, tambien se filtrara por el producto permitido el cual',
'              se obtiene de la tabla sc_nominaempresas.',
'FECHA : Octubre de 2009',
'BD    : BDICHEQ',
'VERSION: 20091020.0520';

CREATE PROCEDURE "informix".sp_obtienedatoscte(pcuenta CHAR(11))
RETURNING CHAR(5), CHAR(10), CHAR(30), CHAR(20), CHAR(30);

--declaracion de variables
DEFINE sql_err 			  INTEGER;
DEFINE isam_err 		  INTEGER;
DEFINE error_info		  CHAR(80);
DEFINE cMensaje 		  CHAR(80); 
DEFINE cCod_ret           CHAR(5);
DEFINE cNumEmp			  CHAR(10);
DEFINE cNombres			  CHAR(30);
DEFINE cApellidoPat	      CHAR(30);
DEFINE cApellidoMat		  CHAR(20);
DEFINE cNumCte			  CHAR (11);


--SET DEBUG FILE TO '/tmp/sp_ObtieneDatosCte.out';
--TRACE ON;
	
	--inicializacion de variables
	LET cCod_ret      = '00000';
	LET sql_err       = 0;
	LET isam_err      = 0;
	LET error_info    = ''; 	
	LET cMensaje      = '';
	LET cNumEmp	      =	'';
	LET cNombres	  =	'';
	LET cApellidoPat  =	'';   
	LET cApellidoMat  =	'';	 
	LET cNumCte		  = '';

	BEGIN
	    ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
	        LET cMensaje = error_info;
		RETURN cCod_ret, cNumEmp, cApellidoPat, cApellidoMat, cNombres;			
	    END EXCEPTION;			

		SELECT m.num_cte, TRIM(c.nombre1) || " " || TRIM(c.nombre2),  TRIM(apell_paterno), TRIM(apell_materno), f.numeric2
		INTO cNumCte, cNombres, cApellidoPat, cApellidoMat, cNumEmp
		FROM Bdinteg:si_cliente c,Bdinteg:si_ctepf f, Bdicheq:sc_maechq m, Bdicheq:sc_nominaempresas e
		WHERE m.cuenta = pCuenta
		AND m.num_cte = c.numcte
		AND c.numcte = f.numcte
		AND m.empresa ='001'
		AND m.empresa = e.codigo
		AND e.acepta_producto LIKE '%'||m.producto||'%';

		--No es empleado de la empresa 001
		IF cNumEmp IS NULL OR cNumEmp ='' THEN
			LET cCod_ret = '10000';
		END IF;
			
		RETURN cCod_ret, cNumEmp, cApellidoPat, cApellidoMat, cNombres;			

	END;
END PROCEDURE

DOCUMENT
'AUTOR      : ABIGAIL VASAVILBAZO CAÑEDO',
'DESCRIPCION: OBTIENE NUMERO DE EMPLEADO, NOMBRES Y APELLIDOS POR MEDIO DE LA CUENTA ',
'FECHA      : SEPTIEMBRE 2009',
'VERSION    : 20090930.1114',
'BD         : BDICHEQ';

CREATE PROCEDURE "informix".sp_registraprocesoarch(pnombrearch CHAR(20),pfolioarch CHAR(20), pusuario CHAR(8))

RETURNING CHAR(5);

DEFINE vcodret 			 CHAR(5);
DEFINE vsqlerr, visamerr INTEGER;
DEFINE dFecha_hoy 		 DATE; 
DEFINE cHora			 CHAR(8);

LET vcodret    = "00000";
LET dFecha_hoy = '';
LET cHora      = '';


	BEGIN
	ON EXCEPTION SET vsqlerr, visamerr
	IF vsqlerr != 0 THEN
		LET vcodret=vsqlerr;
		RETURN vcodret;
	END IF;
	END EXCEPTION;

	--set debug file to "/tmp/sp_RegistraProcesoArch.out";
	--trace on;

	SELECT fecha_hoy
	INTO dFecha_hoy
	FROM Bdicheq:sc_fechas
	WHERE empresa = "001";	
	
	INSERT INTO bdicheq:sc_NominaArchCargados(nombre_arch,folio,fecha_insert,hora_insert, user_insert)
	VALUES (pNombreArch, pFolioArch, dFecha_hoy,CURRENT HOUR TO SECOND, pUsuario);

	RETURN vcodret;	
END;
END PROCEDURE

DOCUMENT 
'AUTOR      : ABIGAIL VASAVILBAZO CAÑEDO',
'DESCRIPCION: REGISTRA LOS ARCHIVOS CARGADOS DE NOMINA ',
'FECHA      : SEPTIEMBRE 2009',
'VERSION    : 20090907.1550',
'BD         : BDICHEQ';

CREATE PROCEDURE "informix".cuadra_invcrec19(pempresa char(3))
RETURNING CHAR(5);

    DEFINE vcodret          CHAR(5);
    DEFINE vsqlerr          INTEGER;
    DEFINE vfecha_hoy		DATE;
    DEFINE vcuenta          CHAR(20);
    DEFINE vsdo_actual		DECIMAL(14,2);
    DEFINE vsdo_nuevo		DECIMAL(14,2);
    DEFINE vint_acum		DECIMAL(14,2);
    DEFINE visr             DECIMAL(14,2);
    DEFINE vintereses		DECIMAL(14,2);
    DEFINE vmonto_apertura	DECIMAL(14,2);
    DEFINE vhoraw       	CHAR(15);
    DEFINE vhora        	DATETIME HOUR TO FRACTION;
    DEFINE vfolio_suc   	CHAR(16);
    DEFINE vsucursal		CHAR(4);
    DEFINE vproducto		CHAR(4);
    DEFINE vstatus          CHAR(1);
    DEFINE vdiferencia		DECIMAL(14,2);
    DEFINE vexiste1         INTEGER;
    DEFINE vexiste2         INTEGER;
    DEFINE vsql             CHAR(500);
    DEFINE vfecha           CHAR(10);
    DEFINE vfechades        CHAR(6);
    DEFINE vdia             CHAR(2);
    DEFINE vmes             CHAR(2);
    DEFINE vanio            CHAR(2);
    DEFINE vnombre          VARCHAR(50);

    LET vcodret = "000";
    LET vhora = current hour to fraction;
    LET vhoraw = vhora;
    LET vhoraw = vhoraw[1,2]||vhoraw[4,5]||vhoraw[7,8]||vhoraw[10,11];
    LET vfolio_suc = "informix" ||vhoraw[1,8];

    --- SET DEBUG FILE TO "calsdoinvcrec";
    --- TRACE ON;

    BEGIN
    ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            RETURN vcodret;
        END IF;
    END EXCEPTION;

    IF EXISTS (SELECT tabname FROM sysmaster:systabnames
                WHERE partnum BETWEEN (SELECT MIN(partnum) FROM sysmaster:systabnames) AND
                                      (SELECT MAX(partnum) FROM sysmaster:systabnames)
                  AND tabname = 'cuentas_crecientes') THEN
        DROP TABLE cuentas_crecientes;
        CREATE RAW TABLE cuentas_crecientes(
            cuenta          CHAR(20),
            sdo_actual      MONEY(18,2),
            sdo_calculado   MONEY(18,2),
            diferencia      MONEY(18,2));
    ELSE
        CREATE RAW TABLE cuentas_crecientes(
            cuenta          CHAR(20),
            sdo_actual      MONEY(18,2),
            sdo_calculado   MONEY(18,2),
            diferencia      MONEY(18,2));
    END IF;

    SELECT {+INDEX(sc_movhis idxmovhistranspba)} cuenta 
      FROM sc_movhis_old
     WHERE transacc IN("3280","0270","0239","0223","0205")
       AND producto = "1100"
       AND cancelad <> "S"
       AND empresa = pempresa
    UNION ALL
    SELECT {+INDEX(sc_movhis idx_movhisnew3)} cuenta 
      FROM sc_movhis
     WHERE transacc IN("3280","0270","0239","0223","0205")
       AND producto = "1100"
       AND cancelad <> "S"
       AND empresa = pempresa
      INTO TEMP tmp_movhis WITH NO LOG;
    CREATE INDEX idx_tmp ON tmp_movhis(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_movhis;

    SELECT {+INDEX(sc_fechas idx_fechas1)}
           fecha_hoy
      INTO vfecha_hoy
      FROM sc_fechas
     WHERE empresa = pempresa;

    FOREACH
        SELECT {+INDEX(sc_maechq idxscmaechqpba)}
               mae.cuenta,mae.imp_chq_rem,mae.sdo_actual,
               mae.sucursal,mae.producto,mae.status_cta
          INTO vcuenta,vmonto_apertura,vsdo_actual,
               vsucursal,vproducto,vstatus
          FROM sc_maechq mae
         WHERE mae.producto = '1100'
           AND mae.status_cta IN('1','3')
           AND mae.cuenta NOT IN(SELECT cuenta 
                                   FROM tmp_movhis 
                                  WHERE cuenta = mae.cuenta)
           AND mae.cuenta NOT IN('11000067794','11000067905','11000068090','11000068103',
                                 '11000068138','11000068154','11002412758','11003026819')
		   AND day(mae.fecultdep) = "19"	

        IF vsdo_actual is NULL THEN
            LET vsdo_actual = 0.00;
        END IF

        -- // INVERSION PASADA
        LET vintereses = 0.00;
        LET vsdo_nuevo = 0.00;
        LET vint_acum  = 0.00;
        LET visr       = 0.00;
        LET vexiste1   = 0;
        
        SELECT COUNT(*)
          INTO vexiste1
          FROM sc_tasa_var_hist
         WHERE empresa = pempresa
           AND cuenta = vcuenta
           AND inicio_periodo < vfecha_hoy
           AND tipo_tasa in("M","P");
        
        IF vexiste1 > 0 THEN
            SELECT SUM(int_acum), SUM(isr)
              INTO vint_acum, visr
              FROM sc_tasa_var_hist
             WHERE empresa = pempresa
               AND cuenta = vcuenta
               AND inicio_periodo < vfecha_hoy
               AND tipo_tasa in("M","P");
        END IF

        IF vint_acum is null THEN
            LET vint_acum = 0.00;
        END IF

        IF visr is null THEN
            LET visr = 0.00;
        END IF

        LET vintereses = vint_acum - visr;
        
        -- // INVERSION ACTUAL
        LET vint_acum  = 0.00;
        LET visr       = 0.00;
        LET vexiste2   = 0;
        
        SELECT COUNT(*)
          INTO vexiste2
          FROM sc_tasa_variable
         WHERE empresa = pempresa
           AND cuenta = vcuenta
           AND inicio_periodo < vfecha_hoy
           AND tipo_tasa in("M","P")
           AND fin_periodo < vfecha_hoy;
           
        IF vexiste2 > 0 THEN
            SELECT SUM(int_acum), SUM(isr)
              INTO vint_acum, visr
              FROM sc_tasa_variable
             WHERE empresa = pempresa
               AND cuenta = vcuenta
               AND inicio_periodo < vfecha_hoy
               AND tipo_tasa in("M","P")
               AND fin_periodo < vfecha_hoy;
        END IF

        IF vint_acum is null THEN
            LET vint_acum = 0.00;
        END IF

        IF visr is null THEN
            LET visr = 0.00;
        END IF

        LET vintereses = vintereses + (vint_acum - visr);

        LET vsdo_nuevo = vmonto_apertura + vintereses;
        LET vdiferencia = 0.00;

        IF vsdo_nuevo <> vsdo_actual THEN
        
            LET vdiferencia = vsdo_nuevo - vsdo_actual;

            IF vdiferencia > 0.00 THEN
            
                INSERT INTO cuentas_crecientes 
                VALUES(vcuenta, vsdo_actual, vsdo_nuevo, vdiferencia);
                
            END IF
            
            UPDATE sc_maechq
               SET sdo_actual = vsdo_nuevo
             WHERE empresa = pempresa 
               AND cuenta = vcuenta;
            
        END IF
        
    END FOREACH

    UPDATE STATISTICS MEDIUM FOR TABLE cuentas_crecientes;

    LET vfecha = TO_CHAR(vfecha_hoy, '%Y/%m/%d');
    LET vdia = vfecha[9,10];
    LET vmes = vfecha[6,7];
    LET vanio = vfecha[3,4];
    LET vfechades = vdia||vmes||vanio;
    LET vnombre = 'rptinvcrec_'||vfechades||'.txt';

    -- // GENERA EL ARCHIVO DE DESCARGA
    LET vsql = '';
    -- LET vsql = 'echo "UNLOAD TO /home/informix/jivan/invcrec/'||vnombre||' SELECT * FROM cuentas_crecientes" > /home/informix/jivan/invcrec/rptinvcrec.sql';
    LET vsql = 'echo "UNLOAD TO /resplogifx/conciliachq/'||vnombre||' SELECT * FROM cuentas_crecientes" > /resplogifx/conciliachq/rptinvcrec.sql';
    SYSTEM vsql;
    LET vsql = '';
    -- LET vsql = "dbaccess bdicheq /home/informix/jivan/invcrec/rptinvcrec.sql"; 
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/rptinvcrec.sql"; 
    SYSTEM vsql;
    LET vsql = '';
    -- LET vsql = 'chmod 664 /home/informix/jivan/invcrec/'||vnombre;
    LET vsql = 'chmod 664 /resplogifx/conciliachq/'||vnombre;
    SYSTEM vsql;
    LET vsql = "";

    END;

    RETURN vcodret;

END PROCEDURE;