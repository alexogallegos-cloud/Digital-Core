Create Procedure "informix".sp_generaarchivocuentasnomina()
Returning Char(3), Char(18);
    
    Define siMes            Smallint ;
    Define siYear           Integer ;
    Define siDia            Smallint ;
    Define cCodRet          Char(3);
    Define cCodRet2         Char(5);
    Define cCodRet3         Char(50);
    Define dFechaActual     Date ;
    Define cSQL             Char(600);    
    Define cDirectorio      Char(100);
    Define cEmpresa         Char(3);
    Define cNombreArchivo   Char(18);
    Define cMes             Char(2);
    Define cDia             Char(2);
    Define dFechaAnterior   Date;
    Define v_iSqlErr        Integer;
    Define v_iSamErr        Integer;
    Define v_cDesErr        Char(50);
    Define bGrupCop         Integer;
	Define i 		        Integer;
	DEFINE cHoraAplicado    DateTime Hour to Second;
	DEFINE vnumeric1		Char(3);
	DEFINE vnumeric2		Char(10);
	DEFINE vcuenta			char(20);
	DEFINE vapell_paterno	char(26);
	DEFINE vapell_materno	char(26);
	DEFINE vnombre1			char(26);
	DEFINE vnombre2			char(26);
	DEFINE vrfc				Char(13);
	DEFINE vnum_tarjeta		char(20);
	DEFINE vcuenta_clabe	char(18);
	DEFINE vaempresa		char(3);
	DEFINE vanumero_empleado char(10);
	DEFINE vanumero_cuenta	char(20);
	DEFINE vafecha			DATE;
	DEFINE vaapell_paterno	char(26);
	DEFINE vaapell_materno	char(26);
	DEFINE vanombre1		char(26);
	DEFINE vanombre2		char(26);
	DEFINE varfc			Char(13);
	DEFINE vanum_tarjeta	char(20);
	DEFINE vacta_clabe		char(18);
    
    Let siMes          = 0;
    Let siYear         = 0;
    Let siDia          = 0;
    LET cCodRet        = '';
    LET cCodRet2       = '';
    LET cCodRet3       = '';
    Let cDirectorio    = "";
    Let cSQL           = "";
    Let dFechaActual   = '';
    Let cEmpresa       = '';
    Let cNombreArchivo = '';
    Let cMes           = '';
    Let cDia           = '';
    Let dFechaAnterior = '';
    Let v_iSqlErr      = 0;
    Let v_iSamErr      = 0;
    LET v_cDesErr      = '';
    Let bGrupCop       = 0;
	Let i		       = 0;
	LET cHoraAplicado  = current;
	LET vnumeric1		= '';
	LET vnumeric2		= '';
	LET vcuenta			= '';
	LET vapell_paterno	= '';
	LET vapell_materno	= '';
	LET vnombre1		= '';
	LET vnombre2		= '';
	LET vrfc			= '';
	LET vnum_tarjeta	= '';
	LET vcuenta_clabe	= '';
	LET vaempresa		= '';
	LET vanumero_empleado	= '';
	LET vanumero_cuenta	= '';
	LET vafecha			= '';
	LET vaapell_paterno	= '';
	LET vaapell_materno	= '';
	LET vanombre1		= '';
	LET vanombre2		= '';
	LET varfc			= '';
	LET vanum_tarjeta	= '';
	LET vacta_clabe		= '';
	
	--- Set debug file to "/tmp/sp_generaarchivocuentasnomina.out";
    --- Trace on;
    
    Begin
    
    -- // Controla algun posible error del procedimiento.
    ON EXCEPTION SET v_iSqlErr, v_iSamErr, v_cDesErr
        Set debug file to "/tmp/sp_generaarchivocuentasnomina.err";
        Trace on;
        IF v_iSqlErr <> 0 THEN
            LET cCodRet  = v_iSqlErr;
            LET cCodRet2 = v_iSamErr;
            LET cCodRet3 = v_cDesErr;
            RETURN cCodRet, cNombreArchivo;
        END IF;
    END EXCEPTION
	
    
	-- // Truncar tabla donde se guarda el nombre de archivo
	TRUNCATE TABLE bdicheq:sc_nominaresultadoscuentasnomina;

	SET ISOLATION TO DIRTY READ;
	
    -- // Realiza una consulta a la tabla de fechas donde saca los valores de fechas y los inserta en las variables.
    Select Year(fecha_hoy), Month(fecha_hoy), Day(fecha_hoy), fecha_hoy, fecha_hoy - Day(20)
      Into siYear, siMes, siDia, dFechaActual, dFechaAnterior
      From bdicheq:sc_fechas
     Where empresa = "001";
    
    -- // Saca las altasnuevas segun el rango de fechas  y las inserta en la tabla sc_nominarelacionnuevascuentas.
	Let i = -1;
	FOREACH WITH HOLD
		Select lpad(pf.numeric1,3,"0"), pf.numeric2, noc.cuenta, cte.apell_paterno, cte.apell_materno, cte.nombre1, cte.nombre2, cte.rfc, tar.num_tarjeta, chq.cuenta_clabe 
		into vnumeric1, vnumeric2, vcuenta, vapell_paterno, vapell_materno, vnombre1, vnombre2, vrfc, vnum_tarjeta, vcuenta_clabe
		From bdicheq:sc_maenoc as noc
		Inner Join bdicheq:sc_maechq as chq On ( chq.cuenta = noc.cuenta )
		Inner Join bdinteg:si_ctepf as pf On ( chq.num_cte = pf.numcte )
		Inner Join bdinteg:si_cliente as cte On ( chq.num_cte = cte.numcte )
			Left Outer Join bdicheq:sc_tarjeta as tar On ( chq.num_cte = tar.numcte and chq.cuenta = tar.cuenta and tar.Status_tar = 'A' and tar.tipo_tarjeta = 'T' )
			Left Outer Join intercard:tarjeta as card On ( tar.num_tarjeta = card.numtarjeta )
		Where chq.empresa = '001'
			And chq.status_cta = '1'
			And ( ( noc.fecha_alta >= dFechaAnterior And noc.fecha_alta < dFechaActual ) OR 
				( card.fechaasignacion::date >= dFechaAnterior AND card.fechaasignacion::date < dFechaActual ) ) 
			And chq.producto in('1300','1700')
			
        IF (i = -1) THEN
            BEGIN WORK;
			LET i = 0;
        END IF;
		 
		Insert Into bdicheq:sc_nominarelacionnuevascuentas
				( empresa, numero_empleado, numero_cuenta, apell_paterno, apell_materno, nombre1, nombre2, rfc, num_tarjeta, cta_clabe )
				VALUES (vnumeric1, vnumeric2, vcuenta, vapell_paterno, vapell_materno, vnombre1, vnombre2, vrfc, vnum_tarjeta, vcuenta_clabe);
							
		LET i = i + 1;
		IF i=1000 THEN
			COMMIT WORK;
			BEGIN WORK;
			let i = 0;
		END IF;
	END FOREACH;
	COMMIT WORK;
	
	   
    -- // Valida si existen altas nuevas
    If Exists ( Select empresa From bdicheq:sc_nominarelacionnuevascuentas ) Then
        -- // Si existen altas nuevas las guarda de manera historica en sc_nominarelacionnuevascuentashis.
		
        Let i = -1;
		FOREACH WITH HOLD
			Select empresa, numero_empleado, numero_cuenta, date(current), apell_paterno, apell_materno, nombre1, nombre2, rfc, num_tarjeta, cta_clabe
			Into vaempresa, vanumero_empleado, vanumero_cuenta, vafecha		, vaapell_paterno, vaapell_materno, vanombre1, vanombre2, varfc, vanum_tarjeta, vacta_clabe
			From bdicheq:sc_nominarelacionnuevascuentas
			
			IF (i = -1) THEN
				BEGIN WORK;
				LET i = 0;
			END IF;
			
			Insert Into bdicheq:sc_nominarelacionnuevascuentashis
			( empresa, numero_empleado, numero_cuenta, fecha_insercion, apell_paterno, apell_materno, nombre1, nombre2, rfc, num_tarjeta, cta_clabe )
			values (vaempresa, vanumero_empleado, vanumero_cuenta, vafecha, vaapell_paterno, vaapell_materno, vanombre1, vanombre2, varfc, vanum_tarjeta, vacta_clabe);
			
			LET i = i + 1;
			IF i=1000 THEN
				COMMIT WORK;
				BEGIN WORK;
				let i = 0;
			END IF;
		END FOREACH;
		COMMIT WORK;
        
        -- // Inicializa el codigo de retorno.
        Let cCodRet = '000';		
        Let cMes = LPAD(siMes,2,"0");
        Let cDia = LPAD(siDia,2,"0");
        Let cDirectorio = "/tmp/traspasobanco/archivosnomina/conciliacion/originales/altasnuevas.unl";
            
        -- // Entra a un ciclo foreach en donde el primer select separa las distintas empresas existentes.
        ForEach
            Select Distinct(empresa) 
              Into cEmpresa 
              From bdicheq:sc_nominarelacionnuevascuentas 
             Where empresa::integer > 10
            
            -- // Se genera el nombre del archivo lo compone la empresa, el a?o, mes, dia y un folio (01).			
            Let cNombreArchivo = Trim(cEmpresa)||siYear||cMes||cDia||"01"||".dat";          
            
            -- // Le agrega la "N" al nombre y le asigna un direntorio.
            Let cNombreArchivo = "N" || Trim(cNombreArchivo);			
            
            -- // Crea y le da contenido al archivo query.sql						
            Let cSQL = '';
            Let cSQL = 'echo "UNLOAD TO '||cDirectorio||' '||
                       'Select empresa, numero_empleado, numero_cuenta, apell_paterno, apell_materno, nombre1, nombre2, rfc, num_tarjeta, cta_clabe '||
                       'From bdicheq:sc_nominarelacionnuevascuentas '||
                       'Where empresa = '||cEmpresa||';" > /tmp/query_nomaltas.sql';
            System cSQL;	
            
            -- // IMPORTANTE: Favor de adaptar este directorio en base al funcionamiento de produccion.
            Let cSQL = ''; 	
            Let cSQL = "/ifxsif01/bin/dbaccess bdicheq /tmp/query_nomaltas.sql";        --- PRODUCCION
			--- Let cSQL = "/informix/bin/dbaccess bdicheq /tmp/query_nomaltas.sql";    --- DESARROLLO
            System cSQL;
            
            -- // Le quita el ultimo | al archivo altasnuevas.unl y se renombra con estandar de nombres
            LET cSql = "sed 's/|$//g' /tmp/traspasobanco/archivosnomina/conciliacion/originales/altasnuevas.unl > " ||
                       "/tmp/traspasobanco/archivosnomina/conciliacion/originales/"||cNombreArchivo;
			--- Let cSql = TRIM(cSql);
            SYSTEM cSql;		
        End ForEach
		
        IF ( cNombreArchivo != '' ) THEN
            INSERT INTO bdicheq:sc_nominaresultadoscuentasnomina
            ( nombre_archivo, hora_aplicado ) 
            VALUES
            ( cNombreArchivo||'.asc', cHoraAplicado );
        END IF;
            
        Let cNombreArchivo = '';
        
        If Exists ( Select empresa From bdicheq:sc_nominarelacionnuevascuentas Where empresa::integer <= 10 ) Then
            -- // Se genera el nombre del archivo lo compone la empresa, el a?o, mes, dia y un folio (01).			
            Let cNombreArchivo = 'N001'||siYear||cMes||cDia||"01"||".dat";          	

            -- // Crea y le da contenido al archivo query.sql						
            Let cSQL = '';
            Let cSQL = 'echo "UNLOAD TO '||cDirectorio||' '||
                       'Select empresa, numero_empleado, numero_cuenta, apell_paterno, apell_materno, nombre1, nombre2, rfc, num_tarjeta, cta_clabe '||
                       'From bdicheq:sc_nominarelacionnuevascuentas '||
                       'Where empresa::integer <= 10; " > /tmp/query_nomaltas.sql';
            System cSQL;	
            
            -- // IMPORTANTE: Favor de adaptar este directorio en base al funcionamiento de produccion.
            Let cSQL = ''; 	
            Let cSQL = "/ifxsif01/bin/dbaccess bdicheq /tmp/query_nomaltas.sql";        --- PRODUCCION
			--- Let cSQL = "/informix/bin/dbaccess bdicheq /tmp/query_nomaltas.sql";    --- DESARROLLO
            System cSQL;
            
            -- // Le quita el ultimo | al archivo altasnuevas.unl y se renombra con estandar de nombres
            LET cSql = "sed 's/|$//g' /tmp/traspasobanco/archivosnomina/conciliacion/originales/altasnuevas.unl > " ||
                       "/tmp/traspasobanco/archivosnomina/conciliacion/originales/"||cNombreArchivo;
            SYSTEM cSql;			
        End IF;				
    Else
        -- // NO EXISTEN DATOS NUEVOS
        Let cCodRet = "100";
    End If
    
	-- // Insertar en la tabla el nombre del archivo generado 
	IF ( cNombreArchivo != '' ) THEN
        INSERT INTO bdicheq:sc_nominaresultadoscuentasnomina 
        ( nombre_archivo, hora_aplicado ) 
        VALUES
        ( cNombreArchivo||'.asc', cHoraAplicado );
	END IF;
	
    -- // Borra las altas nuevas y deja la tabla disponible para el proximo llamado
    Delete From bdicheq:sc_nominarelacionnuevascuentas;
    
    -- // Regresa el valor del codigo de retorno al usuario.
    Return cCodRet, cNombreArchivo;
    
    End
        
End Procedure
    
DOCUMENT
'CAMBIO : Jesus Antonio Bastidas Lopez',
'DESCRIPCION: Se alter? la estructura de la tabla para generar el archivo con el nombre del cliente y rfc',
'Solicito: Jose Mendoza, Delia Borboa',
'FECHA : 23 de Abril de 2009',
'VERSION:20090423.1052',

'CAMBIO : César Valdéz Figueroa',
'DESCRIPCION: Se altero la estructura de las tablas sc_nominarelacionnuevascuentas y la sc_nominarelacionnuevascuentashis para generar el',
'             campo Num_tarjeta, ademas de modificar el select principal para que filtrara por la tarjeta titular del cliente con estado activo',
'FECHA : 02 de Noviembre de 2009',
'VERSION:20091106.1000',

'CAMBIO : Selene Campos',
'DESCRIPCION: Se modificó para insertar el nombre del archivo en la tabla sc_nominaresultadoscuentasnomina',
'FECHA : 28 de Agosto de 2014',

'CAMBIO : Jorge Ivan Camacho Sanchez',
'DESCRIPCION: Se modificó para obtener la cuenta clabe',
'FECHA : 04 de Abril de 2023';

CREATE PROCEDURE "informix".sp_calculagat_morales()

-- ******************************************************************************************
-- Realizo   : Daniel Perez
-- Proyecto  : RQM GAT Automatizada
-- Actividad : Calcular automaticamente la GAT para el producto 1200
--                 
-- Fecha     : 23 de Agosto de 2023
-- ******************************************************************************************

RETURNING CHAR(5) AS codRet,
CHAR(100) AS gatNominal,
CHAR(100) AS gatReal;

-- DefiniciÃ³n de Variables
DEFINE SQL_ERR          		INTEGER;
DEFINE vValor 					DECIMAL(9,6);
DEFINE vGatReal					DECIMAL(9,6);
DEFINE vMedianaInflacion  		DECIMAL(9,6);
DEFINE vCadenaGatNominal        VARCHAR(100);
DEFINE vCadenaGatReal        	VARCHAR(100);
DEFINE vDelimitador				CHAR(1);
DEFINE vCodRet					CHAR(5);

-- Valores iniciales
LET vValor	 					= 0;
LET vGatReal					= 0;
LET vMedianaInflacion     		= 0;
LET vCadenaGatNominal 			= '';
LET vCadenaGatReal 				= '';
LET vDelimitador 				= '';
LET vCodRet           			= '00000';

BEGIN

	ON EXCEPTION SET SQL_ERR
		IF SQL_ERR <> 0 THEN
			LET vCodRet = SQL_ERR;
			RETURN vCodRet, vCadenaGatNominal, vCadenaGatReal;
		END IF;
	END EXCEPTION;
	--SET DEBUG FILE TO '/home/sysifx/Miguel/Captacion/sp_puebas/gat_automatizada/sp_crea_temp_morales.out';
    --TRACE ON;

	SELECT med_inflacion
		INTO vMedianaInflacion
		FROM sc_medianainflacion
		WHERE fecha_publicacion = (SELECT MAX(fecha_publicacion) FROM sc_medianainflacion);

	FOREACH 
	SELECT valor 
	INTO vValor
	FROM bdinteg:si_tasavlor 
	WHERE  tasa = 'EJEMP' AND valor <> 0 
	ORDER BY valor

		LET vCadenaGatNominal = vCadenaGatNominal || vDelimitador || TO_CHAR(vValor, "<<<.<<");

		IF vMedianaInflacion IS NOT NULL THEN
			LET vGatReal = ROUND(((((1 + (vValor/100)) / (1 + (vMedianaInflacion/100)))-1)*100),2);
			LET vCadenaGatReal = vCadenaGatReal || vDelimitador || TO_CHAR(vGatReal, "-&.<<");
		END IF;

		LET vDelimitador = '|';


	END FOREACH;

	RETURN vCodRet, vCadenaGatNominal, vCadenaGatReal;
	
END;
    
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se encarga de hacer el calculo de la GAT nominal y real para el producto 1200',
'AUTOR : Daniel Perez',
'FECHA : 23/Agosto/2023',
'BD    : BDICHEQ';

CREATE PROCEDURE "informix".sp_calculagat()

-- ******************************************************************************************
-- Realizo   : Roberto Castro
-- Proyecto  : RQM GAT Automatizada
-- Actividad : Calcular automaticamente la GAT para las cuentas de captacion
--             
--             
--             
--             
--             
--             
-- Fecha     : Abril de 2023
-- ******************************************************************************************

RETURNING CHAR(5);
--RETURNING DECIMAL(9,6);

-- // DefiniciÃ³n de Variables

-- // Variables del sp
DEFINE v_cCodRet			CHAR(5);
DEFINE v_cCodRetGatMorales 	CHAR(5);
DEFINE vsqlerr				INTEGER ;
DEFINE cProducto			CHAR(4);
DEFINE dTasa				DECIMAL(9,6);
DEFINE cPeriodo				CHAR(3);
DEFINE dMedInflacion		DECIMAL(9,6);
DEFINE cGatNominal			CHAR(100);
DEFINE cGatReal				CHAR(100);

-- // VALORES INICIALES
LET cProducto = '';
LET dTasa = 2;
LET cPeriodo = '0';
LET dMedInflacion = 0;

--SET DEBUG FILE TO '/home/informix/ivonne/sp_calculagat.out';
--TRACE ON;

BEGIN

	ON EXCEPTION SET vsqlerr
		IF vsqlerr <> 0 THEN
			LET v_cCodRet = vsqlerr;
			RETURN v_cCodRet;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO CURSOR STABILITY;
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 5;
	
	--GAT NOMINAL
	update bdicheq:sc_gat
		set gat_nominal = ROUND((POW((1 + ((tasa/100)/periodo)),periodo) - 1) * 100, 2),
			fecha_publicacion = TODAY;
	
	--PAGARE
	update bdinvers:sv_gat
		set gat_nomina = ROUND((POW((1 + ((tasa/100)/periodo)),periodo) - 1) * 100, 2),
			fecha_publicacion = TODAY;
		
	IF EXISTS (SELECT med_inflacion FROM sc_medianainflacion) THEN
		
		SELECT (med.med_inflacion/100) INTO dMedInflacion 
		FROM sc_medianainflacion med 
		WHERE med.fecha_publicacion = (SELECT MAX(fecha_publicacion) FROM sc_medianainflacion);

		update bdicheq:sc_gat
			set gat_real = ROUND(((((1 + (gat_nominal/100)) / (1 + dMedInflacion))-1)*100),2);
		
		update bdinvers:sv_gat
			set gat_real = ROUND(((((1 + (gat_nomina/100)) / (1 + dMedInflacion))-1)*100),2);
		
		LET v_cCodRet = '00000';
	ELSE
		LET v_cCodRet = '00001'; --No existe mediana Inflacion
	END IF;

	EXECUTE PROCEDURE bdicheq:sp_calculagat_morales()
		INTO v_cCodRetGatMorales, cGatNominal, cGatReal;

	IF v_cCodRetGatMorales = '00000' THEN 
		IF v_cCodRet <> '00001' THEN 
			UPDATE bdicnweb:sw_infocaratula SET gat_nominal = cGatNominal, gat_real = cGatReal WHERE num_producto = 1200;
		ELSE 
			UPDATE bdicnweb:sw_infocaratula SET gat_nominal = cGatNominal WHERE num_producto = 1200;
		END IF;
	END IF;

	RETURN v_cCodRet;
    
    END;
    
END PROCEDURE
DOCUMENT
'DESCRIPCION: Calcula automaticamente la GAT para las cuentas de captacion',
'AUTOR : Roberto Castro',
'FECHA : Abril de 2023',
'BD    : BDICHEQ',
'MODIFICACION: Se agrega llamado al procedimiento sp_calculagat_morales, ',
' se actualizan los campos para la sw_infocaratula',
' y se actualizan las fechas de publicacion',
'MODIFICO : Daniel Perez.',
'FECHA : 23/Agosto/2023',
'BD    : BDICHEQ';

CREATE PROCEDURE "informix".sp_histmovcheq(pempresa CHAR(3))
RETURNING CHAR(5)  AS vcodret1, 
          CHAR(5)  AS vcodret2, 
          CHAR(50) AS vcodret3;

    DEFINE vcodret1      CHAR(5);
    DEFINE vcodret2      CHAR(5);
    DEFINE vcodret3      CHAR(50);
    DEFINE sql_err       INTEGER;
    DEFINE isam_err      INTEGER;
    DEFINE desc_err      CHAR(50);
    DEFINE vcomienza     SMALLINT;
    DEFINE ventransacc   SMALLINT;
    DEFINE vcontador     INTEGER;
    DEFINE vfecha_ant    DATE;
    DEFINE vfecha_hoy    DATE;
    DEFINE vpasomovshist DATE;
    DEFINE vsistema      CHAR(2);
    DEFINE vfecha        CHAR(8);
    DEFINE vsql          CHAR(2000);
    DEFINE vstmt         CHAR(100);
    DEFINE vcodretparam  CHAR(5);
    DEFINE vinicio_proceso SMALLINT;
	DEFINE vcuenta_fin   CHAR(20);
    
    LET vcodret1      = '000';
    LET vcodret2      = '000';
    LET vcodret3      = 'PROCESO REALIZADO SATISFACTORIAMENTE';
    LET sql_err	      = 0;
    LET isam_err      = 0;
    LET desc_err      = ''; 
    LET vcomienza     = -1;
    LET ventransacc   = 0;
    LET vcontador     = 0;
    LET vfecha_ant    = '';
    LET vfecha_hoy    = '';
    LET vpasomovshist = '';
    LET vsistema      = '01';
    LET vfecha        = ''; 
    LET vsql          = '';
    LET vstmt         = '';
    LET vcodretparam  = '';
    LET vinicio_proceso = 0;
	LET vcuenta_fin   = '';
    
    BEGIN

    ON EXCEPTION
        SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_histmovcheq.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1, vcodret2, vcodret3;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_histmovcheq.out";
    --- TRACE ON;
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_ant, fecha_hoy
      INTO vfecha_ant, vfecha_hoy
      FROM sc_fechas
     WHERE empresa = pempresa;
     
    -- // VERIFICA SE HAYA EFECTUADO EL PASO DE MOVS A HISTORICO
    SELECT fecha 
      INTO vpasomovshist
      FROM sc_contproc
     WHERE empresa = pempresa 
       AND proceso = "pasomovshist";

    IF vpasomovshist <> vfecha_ant THEN
        LET vcodret1 = "953";
        LET vcodret2 = "953";
        
        SELECT descripcion
          INTO vcodret3
          FROM bdinteg:si_codret
         WHERE sistema = vsistema
           AND codigo_retorno = vcodret1;
        
        RETURN vcodret1, vcodret2, vcodret3;
    END IF;
    
    -- // LLAMA AL PROCESO PARA EL RANGO DE CUENTAS
    CALL sp_actparamhistmovchq(pempresa)
    RETURNING vcodretparam;
    
    IF vcodretparam = '000' THEN
        UPDATE sc_contproc
           SET fecha = vfecha_hoy
         WHERE empresa = pempresa
           AND proceso = 'inicio_histmovcheq';
    END IF;
	
	SELECT valor 
      INTO vcuenta_fin
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'CtaIniRepHisChqComp1';
    
    
    LET vfecha = TO_CHAR(vfecha_ant, '%d%m%Y');
    
    -- // DESCARGA MOVIMIENTOS POS - BANCO
	    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/histmovcheq_aplicados_POS7_'||vfecha||'.txt '||
               'SELECT mov.cuenta, mov.sucursal, mae.num_cte, mov.monto_tot, mov.transacc, trx.descripcion, trx.se_contabiliza, '||
               'TRIM(pro.c_ccmayor)||TRIM(pro.c_ccsub)||TRIM(pro.c_ccsubsub)||TRIM(pro.c_ccsssub)||TRIM(pro.c_ccssssub)||TRIM(cte.sector), '||
               'TRIM(pro.a_ccmayor)||TRIM(pro.a_ccsub)||TRIM(pro.a_ccsubsub)||TRIM(pro.a_ccsssub)||TRIM(pro.a_ccssssub)||TRIM(cte.sector), '||
			   'mov.fech_alt, mov2.secuenciaextendida, mov2.idterminal, mov2.referencia, mov2.fechahorainauth, mov2.secuencia, mov2.secuenciaorig, mov.num_tarjeta, mae.producto '||
               'FROM bdicheq:sc_movdia_concil mov '||
               'INNER JOIN bdicheq:sc_maechq mae ON ( mov.empresa = mae.empresa AND mov.cuenta = mae.cuenta ) '||
               'INNER JOIN bdinteg:si_prodtran pro ON ( mov.producto = pro.producto AND mov.transacc = pro.transaccion ) '||
               'INNER JOIN bdinteg:si_cliente cte ON ( cte.numcte = mae.num_cte ) '||
               'INNER JOIN bdinteg:si_transacc trx ON ( mov.empresa = trx.empresa AND mov.transacc = trx.numero AND trx.sistema = "01" ) '||
			   'LEFT OUTER JOIN intercard:movimiento mov2 ON ( mov2.numtarjeta = mov.num_tarjeta AND SUBSTR(mov2.secuenciaextendida,10,6) = SUBSTR(mov.folio_suc,11,6) AND mov2.prodind = "01" AND mov.transacc IN("0952", "0479") AND (date(mov2.fechahorainauth) = mov.fech_oper OR date(mov2.fechahoraoutauth) = mov.fech_oper)) '||
               'WHERE mov.transacc in(''0801'', ''0952'', ''0479'') and mov.fech_alt = '''||vfecha_ant||''' AND mov.cancelad != ''S'' ' ||
			   'AND mov.cuenta < '''||vcuenta_fin||''';" > /resplogifx/conciliachq/histmovcheq_POS7.sql';

	SYSTEM vsql;
    
    LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/histmovcheq_POS7.sql"; 
    SYSTEM vstmt;
    
    
    LET vsql = '';
    LET vstmt = '';
/*    
    -- // DESCARGA MOVIMIENTOS POS - TRANSFER
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/histmovcheq_aplicados_transfer_POS_'||vfecha||'.txt '||
               'SELECT mov.cuenta, mov.sucursal, mae.numcte_tf, mov.monto_tot, mov.transacc, trx.descripcion, trx.se_contabiliza, '||
               'CASE WHEN EXISTS( SELECT numcte FROM bdinteg:si_cliente WHERE numcte = mae.numcte ) THEN '||
               'TRIM(pro.c_ccmayor)||TRIM(pro.c_ccsub)||TRIM(pro.c_ccsubsub)||TRIM(pro.c_ccsssub)||TRIM(pro.c_ccssssub)||TRIM(cte.sector) '||
               'ELSE TRIM(pro.c_ccmayor)||TRIM(pro.c_ccsub)||TRIM(pro.c_ccsubsub)||TRIM(pro.c_ccsssub)||TRIM(pro.c_ccssssub)||TRIM(pro.c_sector) END, '||
               'CASE WHEN EXISTS( SELECT numcte FROM bdinteg:si_cliente WHERE numcte = mae.numcte ) THEN '||
               'TRIM(pro.a_ccmayor)||TRIM(pro.a_ccsub)||TRIM(pro.a_ccsubsub)||TRIM(pro.a_ccsssub)||TRIM(pro.a_ccssssub)||TRIM(cte.sector) '||
               'ELSE TRIM(pro.a_ccmayor)||TRIM(pro.a_ccsub)||TRIM(pro.a_ccsubsub)||TRIM(pro.a_ccsssub)||TRIM(pro.a_ccssssub)||TRIM(pro.a_sector) END, '||
			   'mov.fech_alt, mov2.secuenciaextendida, mov2.idterminal, mov2.referencia, mov2.fechahorainauth, mov2.secuencia, mov2.secuenciaorig, mov.num_tarjeta, mae.producto '||
               'FROM bdicheq:sc_movdia_concil mov '||
               'INNER JOIN bditransfer:tf_maecte mae ON ( mov.cuenta = mae.cuenta_tf ) '||
               'INNER JOIN bdinteg:si_prodtran pro ON ( mov.producto = pro.producto AND mov.transacc = pro.transaccion ) '||
               'INNER JOIN bdinteg:si_transacc trx ON ( mov.empresa = trx.empresa AND mov.transacc = trx.numero AND trx.sistema = "01" ) '||
               'LEFT OUTER JOIN bdinteg:si_cliente cte ON ( cte.numcte = mae.numcte ) '||
			   'LEFT OUTER JOIN intercard:movimiento mov2 ON ( mov2.numtarjeta = mov.num_tarjeta AND SUBSTR(mov2.secuenciaextendida,10,6) = SUBSTR(mov.folio_suc,11,6) AND mov2.prodind = "01" AND mov.transacc IN("0952", "0479") AND (date(mov2.fechahorainauth) = mov.fech_oper OR date(mov2.fechahoraoutauth) = mov.fech_oper)) '||
               'WHERE mov.transacc in(''0801'', ''0952'', ''0479'') and mov.fech_alt = '''||vfecha_ant||''' AND mov.cancelad != ''S'';" > /resplogifx/conciliachq/histmovcheqtrf_POS.sql';
    SYSTEM vsql;
    
    LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/histmovcheqtrf_POS.sql"; 
    SYSTEM vstmt;
    
    
    -- // DESCARGA MOVIMIENTOS TRANSFER
    LET vsql = '';
    LET vstmt = '';
    
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/histmovcheq_aplicados_transfer_'||vfecha||'.txt '||
               'SELECT mov.cuenta, mov.sucursal, mae.numcte_tf, mov.monto_tot, mov.transacc, trx.descripcion, trx.se_contabiliza, '||
               'CASE WHEN EXISTS( SELECT numcte FROM bdinteg:si_cliente WHERE numcte = mae.numcte ) THEN '||
               'TRIM(pro.c_ccmayor)||TRIM(pro.c_ccsub)||TRIM(pro.c_ccsubsub)||TRIM(pro.c_ccsssub)||TRIM(pro.c_ccssssub)||TRIM(cte.sector) '||
               'ELSE TRIM(pro.c_ccmayor)||TRIM(pro.c_ccsub)||TRIM(pro.c_ccsubsub)||TRIM(pro.c_ccsssub)||TRIM(pro.c_ccssssub)||TRIM(pro.c_sector) END, '||
               'CASE WHEN EXISTS( SELECT numcte FROM bdinteg:si_cliente WHERE numcte = mae.numcte ) THEN '||
               'TRIM(pro.a_ccmayor)||TRIM(pro.a_ccsub)||TRIM(pro.a_ccsubsub)||TRIM(pro.a_ccsssub)||TRIM(pro.a_ccssssub)||TRIM(cte.sector) '||
               'ELSE TRIM(pro.a_ccmayor)||TRIM(pro.a_ccsub)||TRIM(pro.a_ccsubsub)||TRIM(pro.a_ccsssub)||TRIM(pro.a_ccssssub)||TRIM(pro.a_sector) END, '||
			   'mov.fech_alt, mov2.secuenciaextendida, mov2.idterminal, mov2.referencia, mov2.fechahorainauth, mov2.secuencia, mov2.secuenciaorig, mov.num_tarjeta, mae.producto '||
               'FROM bdicheq:sc_movdia_concil mov '||
               'INNER JOIN bditransfer:tf_maecte mae ON ( mov.cuenta = mae.cuenta_tf ) '||
               'INNER JOIN bdinteg:si_prodtran pro ON ( mov.producto = pro.producto AND mov.transacc = pro.transaccion ) '||
               'INNER JOIN bdinteg:si_transacc trx ON ( mov.empresa = trx.empresa AND mov.transacc = trx.numero AND trx.sistema = "01" ) '||
               'LEFT OUTER JOIN bdinteg:si_cliente cte ON ( cte.numcte = mae.numcte ) '||
			   'LEFT OUTER JOIN intercard:movimiento mov2 ON ( mov2.numtarjeta = mov.num_tarjeta AND SUBSTR(mov2.secuenciaextendida,10,6) = SUBSTR(mov.folio_suc,11,6) AND mov2.prodind = "01" AND mov.transacc IN ("0800","0871","0873","0890","0893","0952","0479") AND (date(mov2.fechahorainauth) = mov.fech_oper OR date(mov2.fechahoraoutauth) = mov.fech_oper)) '||
               'WHERE mov.fech_alt = '''||vfecha_ant||''' AND mov.cancelad != ''S'';" > /resplogifx/conciliachq/histmovcheqtrf.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '';
    LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/histmovcheqtrf.sql"; 
	
	
    SYSTEM vstmt;
    LET vstmt = '';
*/
    END;

    RETURN vcodret1, vcodret2, vcodret3;

END PROCEDURE;