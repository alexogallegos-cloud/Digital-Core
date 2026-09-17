CREATE PROCEDURE "informix".sp_nominaencabezadosumarionvosemp(
				pEmpresa CHAR(3),
				pFecha_gen DATE,
				pFolio_archivo CHAR(4),
				pNombre_archivo CHAR(17),
				pSentido CHAR(1),
				pCuenta_cargo CHAR(20),
				pFecha_aplicacion DATE,
				pTotal_registros INTEGER,
				pImporte_tot CHAR(16),
				pStatus CHAR(1),
				pFecha_insert DATE
)
	RETURNING CHAR(5);

---- VARIABLES  GENERALES---
DEFINE cSqlerr			 INTEGER;
DEFINE cCodret      	 CHAR(5);
DEFINE vsSQL    CHAR(100);

--VALORES INICIALES
LET cSqlerr = '';
LET cCodret = '00000';
LET vsSQL    = '';

--SET debug FILE TO "/tmp/sp_NominaEncabezadoSumarioNvosEmp.out";
--Trace ON;

Begin
	------  Control de Errores no Controlados
    ON EXCEPTION SET cSqlerr
        IF cSqlerr <> 0 THEN
            Let cCodret = cSqlerr;    
            RETURN NVL(cCodret,'');
        END IF;
	END EXCEPTION;
	
	--VALIDAR QUE LA EMPRESAA SEA 001 PARA QUE NO VALIDE LA CUENTA CARGO
	IF TRIM(pEmpresa) = '001'  THEN
		--SE VALIDAN LOS PARAMETROS DE ENTRADA
		IF TRIM(pEmpresa) = '' OR (pEmpresa IS NULL) OR (pFecha_gen IS NULL) OR TRIM(pFolio_archivo) = '' OR (pFolio_archivo IS NULL) OR 
			TRIM(pNombre_archivo) = '' OR (pNombre_archivo IS NULL) OR TRIM(pSentido) = '' OR (pSentido IS NULL)  OR 
			(pFecha_aplicacion IS NULL) OR (pTotal_registros IS NULL) OR (pImporte_tot IS NULL) OR TRIM(pImporte_tot) = '' OR 
			TRIM(pStatus) = '' OR (pStatus IS NULL) OR (pFecha_insert IS NULL)  THEN
				--Error Un valor NULLOS En EL Archivo
				LET cCodret = '182';
				RETURN cCodret;
		END IF;
	ELSE
		--SE VALIDAN LOS PARAMETROS DE ENTRADA
		IF TRIM(pEmpresa) = '' OR (pEmpresa IS NULL) OR (pFecha_gen IS NULL) OR TRIM(pFolio_archivo) = '' OR (pFolio_archivo IS NULL) OR 
			TRIM(pNombre_archivo) = '' OR (pNombre_archivo IS NULL) OR TRIM(pSentido) = '' OR (pSentido IS NULL)  OR 
			TRIM(pCuenta_cargo) = '' OR (pCuenta_cargo IS NULL) OR (pFecha_aplicacion IS NULL) OR (pTotal_registros IS NULL) 
			OR (pImporte_tot IS NULL) OR TRIM(pImporte_tot) = '' OR TRIM(pStatus) = '' OR (pStatus IS NULL) OR (pFecha_insert IS NULL)  THEN
				--Error Un valor NULLOS En EL Archivo
				LET cCodret = '182';
				RETURN cCodret;
		END IF;
	END IF;
		
	--SE LIMPIAN LA TABLA TEMPORAL
	DELETE FROM BDICHEQ:sc_nominaencabezadosumariotemp WHERE nombre_archivo = pNombre_archivo;
	
	--SE VALIDA QUE SEAN ENTEROS LO QUE DEBEN SER
	--VALIDAR QUE LA EMPRESAA SEA 001 PARA QUE NO VALIDE LA CUENTA CARGO
	IF TRIM(pEmpresa) = '001'  THEN
		--Validar si son numericos 
		IF bdiprog:isnumeric(pEmpresa) <> '1' OR  bdiprog:isnumeric(pTotal_registros) <> '1' OR  bdiprog:isnumeric(pImporte_tot) <> '1' THEN
			--Error Un valor No Es  Numerico En Encabezado
			LET cCodret = '183';
			RETURN cCodret;
		END IF;
	ELSE
		--Validar si son numericos 
		IF bdiprog:isnumeric(pEmpresa) <> '1' OR bdiprog:isnumeric(pCuenta_cargo) <> '1' OR  bdiprog:isnumeric(pTotal_registros) <> '1' 
		   OR  bdiprog:isnumeric(pImporte_tot) <> '1'THEN
			--Error Un valor No Es  Numerico En Encabezado
			LET cCodret = '183';
			RETURN cCodret;
		END IF;
	END IF;
	--Validar si son cadenas
	IF bdiprog:isnumeric(pSentido) <> '0' THEN
		--Error Un valor Es  Numerico En Encabezado
		LET cCodret = '184';
		RETURN cCodret;
	END IF;
	--SE REALIZA EL INSERT
	
	INSERT INTO sc_nominaencabezadosumariotemp (empresa, fecha_gen, folio_archivo, nombre_archivo, sentido, cuenta_cargo, 
			fecha_aplicacion,total_registros, importe_tot, status, fecha_insert)
	VALUES (pEmpresa,pFecha_gen, pFolio_archivo,pNombre_archivo,pSentido,pCuenta_cargo,pFecha_aplicacion,pTotal_registros,
	        (pImporte_tot),pStatus,pFecha_insert);
	   RETURN NVL(cCodret,'');
END
END PROCEDURE
DOCUMENT
'AUTOR :César Valdéz Figueroa',
'DESCRIPCION:  Este procedimioento guarda los datos que se pasan por parametro  en la tabla sc_nominaencabezadosumariotemp',
'              ademas de validar que no este vacios ni nullos',
'FECHA : Septiembre de 2009',
'BD    : BDICHEQ',
'VERSION: 20090929.0210';

CREATE PROCEDURE "informix".sp_nominageneranombrearchivo(pempresa CHAR(3))
	RETURNING CHAR(5),CHAR(13);

---- VARIABLES  GENERALES---
DEFINE cSqlerr			INTEGER;
DEFINE cCodret      	CHAR(5);
DEFINE vsSQL    		CHAR(100);
DEFINE cNombreArch    	CHAR(13);
DEFINE cConsecutivo    	INTEGER;
DEFINE pFecha_Hoy       DATE;

--VALORES INICIALES
LET cSqlerr = '';
LET cCodret = '00000';
LET vsSQL    = '';
LET cNombreArch   = '';
LET cConsecutivo  = '';
LET pFecha_Hoy = CURRENT;
--SET debug FILE TO "/tmp/sp_NominaGeneraNombreArchivo.out";
--Trace ON;

Begin
	------  Control de Errores no Controlados
    ON EXCEPTION SET cSqlerr
        IF cSqlerr <> 0 THEN
            Let cCodret = cSqlerr;    
            RETURN NVL(cCodret,''),NVL(cNombreArch,'');
        END IF;
	END EXCEPTION;
	--VALIDAR QUE LOS PARAMETROS NO SEAN NUMERICOS
	IF bdiprog:isnumeric(pEmpresa) <> '1' THEN
		--EL PARAMETRO EMPRESA NO ES NUMERICO
		Let cCodret = '564';    
		RETURN NVL(cCodret,''),NVL(cNombreArch,'');
	END IF;
	---VALIDAR SI SON NULLOS
	IF TRIM(pEmpresa) = '' OR (pEmpresa IS NULL) THEN
		--ERROR EN LOS PARAMETROS  SON NULLOS
		Let cCodret = '563';    
		RETURN NVL(cCodret,''),NVL(cNombreArch,'');
	END IF;	
	--VALIDAR EL TAMAÑO de la empresa
	IF LENGTH(TRIM(pEmpresa)) <> 3 THEN
		--EL TAMAÑO DE LA EMPRESA NO ES EL CORRECTO
		Let cCodret = '565';    
        RETURN NVL(cCodret,''),NVL(cNombreArch,'');
	END IF;	
	--SELECCIONAR LA FECHA HOY
	SELECT fecha_hoy  INTO pFecha_Hoy FROM bdicheq:sc_fechas WHERE empresa = '001';
	--OBTENER EL CONSECUTIVO
	SELECT NVL(MAX(folio_archivo),'89') INTO cConsecutivo FROM BDICHEQ:sc_nominaencabezadosumario WHERE fecha_gen = pFecha_Hoy;
	IF cConsecutivo < 90 THEN
		LET cConsecutivo = 90;
	ELSE
		LET cConsecutivo = cConsecutivo + 1;
	END IF;
	IF cConsecutivo > 99 THEN
		--ERROR NO SE PUEDEN FORMAQR MAS DE 10 ARCHIVOS
		LET cCodret = '005';
		RETURN NVL(cCodret,''),NVL(cNombreArch,'');
	END IF;
	--FORMAR EL NOMBRE DEL ARCHIVO  --0012008063001.dat
	LET cNombreArch = pEmpresa || LPAD(YEAR(pFecha_Hoy),4,'0') || LPAD(MONTH(pFecha_Hoy),2,'0') || LPAD(DAY(pFecha_Hoy),2,'0') || LPAD(cConsecutivo,2,'0');
	RETURN NVL(cCodret,''),NVL(cNombreArch,'');
END
END PROCEDURE
DOCUMENT
'AUTOR :César Valdéz Figueroa',
'DESCRIPCION:  Este procedimiento se encarga de generar el nombre del archivo de nomina de lso empleados nuevos  recibiendo como.',
'              parametro de entrada la empresa y validando el tamaño, que sean numeros y que no sea nulla.',
'FECHA : Octubre de 2009',
'BD    : BDICHEQ',
'VERSION: 20091001.1324';

CREATE PROCEDURE "informix".sp_nominaobtieneerror(pcodret CHAR(5))
	RETURNING CHAR(5), CHAR(50);

---- VARIABLES  GENERALES---
DEFINE cSqlerr			 INTEGER;
DEFINE cCodret      	 CHAR(5);
DEFINE vsSQL    		 CHAR(100);
DEFINE cMensaje    		 CHAR(50);

--VALORES INICIALES
LET cSqlerr = '';
LET cCodret = '00000';
LET vsSQL    = '';
LET cMensaje    = '';

--SET debug FILE TO "/tmp/sp_NominaObtieneError.out";
--Trace ON;

Begin
	------  Control de Errores no Controlados
    ON EXCEPTION SET cSqlerr
        IF cSqlerr <> 0 THEN
            Let cCodret = cSqlerr;    
            RETURN NVL(cCodret,''),NVL(cMensaje,'');
        END IF;
	END EXCEPTION;
	---VALIDAR SI SON NULLOS
	IF TRIM(pCodret) = '' OR (pCodret IS NULL) THEN
		--ERROR EN LOS PARAMETROS  SON NULLOS
		Let cCodret = '563';    
	END IF;	
	--OBTENER LA DESCRIPCION DEL CODIGO DE RETORNO
	SELECT DESCRIPCION INTO cMensaje FROM bdinteg:si_codret WHERE sistema = '01' AND codigo_retorno = TRIM(pCodret);
	--VALIDAR SI SE ENCONTRO LA DESCRIPCION
	IF (cMensaje IS NULL) THEN
		--CODIGO DE RETORNO DESCONOCIDO
		SELECT NVL(DESCRIPCION,'0') INTO cMensaje FROM bdinteg:si_codret WHERE sistema = '01' AND codigo_retorno = '561';
	END IF;
	RETURN NVL(cCodret,''),NVL(cMensaje,'');
END
END PROCEDURE
DOCUMENT
'AUTOR :César Valdéz Figueroa',
'DESCRIPCION: Obtiene las descripciones de los mensajes de error, recibiendo por parametro el codigo de retorno ',
'			  buscando la descripcion del mensaje en la tabla bdinteg:si_codret',
'FECHA : Octubre de 2009',
'BD    : BDICHEQ',
'VERSION: 20091001.0530';

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