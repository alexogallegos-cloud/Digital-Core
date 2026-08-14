CREATE PROCEDURE "informix".sp_obtenerciudadesregion (pIdRegion SMALLINT, pTipo SMALLINT,pCiudad integer)
    RETURNING CHAR(60), SMALLINT, CHAR(50);

    --pIdRegion : Id de region.
    -- Tipo de filtro que se aplicara: 0 - Traer las ciudades que no pertenecen a la region recibida, 1 - Traer ciudades que  si pertenecen a la region indicada.
    --Autor: René Chiquete Elizalde
    --07-01-2010
    --Obtiene las ciudades dadas de alta y si pertenecen o no a la región indicada en el parametro recibido.

    DEFINE sCodRet CHAR(6);			--CODIGO DE RETORNO PERSONALIZADO
    DEFINE iCodRet INTEGER ;			--CODIGO DE RETORNO INTERNO
    DEFINE sErrorInfo CHAR(80);			--MENSAJE DE CODIGO DE RETORNO
    DEFINE cErrorInfo CHAR(80);			--MENSAJE DE CODIGO DE RETORNO
    DEFINE iIsamErr smallint;                       --VARIABLE PARA CACHAR EL CODIGO DE ERROR

    DEFINE vIdCiudad SMALLINT;                  --NUMERO DE IDENTIFICACION DE LA CIUDAD
    DEFINE vNombreIdIniciales CHAR(50);
	DEFINE iRegistros integer;

    LET sCodRet = "000";
    LET cErrorInfo="PROCESO EXITOSO";
    LET sErrorInfo="";
    LET	iCodRet=0;

    LET vIdCiudad = 0;
    LET vNombreIdIniciales  = "";
	LET iRegistros = 0;

--SET DEBUG FILE TO '/tmp/Rene/PRUEBA.out';
   -- TRACE ON;


    BEGIN
        ON EXCEPTION SET iCodRet, iIsamErr, sErrorInfo
            LET sCodRet = iCodRet;
                    LET cErrorInfo = sErrorInfo;
            RETURN sCodRet, vIdCiudad,vNombreIdIniciales;

        END Exception;

            --VALIDAMOS DATO DE ENTRADA
            IF nvl(pIdRegion,'')='' then
                    LET sCodRet='001';
                    LET cErrorInfo='DATO DE ENTRADA NO VALIDO';
                    RETURN sCodRet,vIdCiudad, vNombreIdIniciales;
            ELSE

                IF (pTipo = 0) THEN
                        FOREACH
                                SELECT { + INDEX (si_catciudades numerociudad)}  nvl(numerociudad,0) numero_ciudad, nvl(TRIM(nombreciudad),'') || ' - ' || nvl(numerociudad,0) || nvl(inicialciudad,'') nombre_id_inicial
                                INTO vIdCiudad, vNombreIdIniciales
                                FROM bdinteg:si_catciudades
                                WHERE nvl(numero_region,0) <> pIdRegion
                                AND numerociudad = CASE WHEN pCiudad = -1 THEN numerociudad ELSE pCiudad END
								--numerociudad = pCiudad
                                ORDER BY numerociudad

                                RETURN sCodRet,vIdCiudad, vNombreIdIniciales  WITH RESUME;
                        END FOREACH;
                ELIF (pTipo = 1) Then
                             FOREACH
                                    SELECT { + INDEX (si_catciudades numerociudad)}  nvl(numerociudad,0) numero_ciudad, nvl(TRIM(nombreciudad),'') || ' - ' || nvl(numerociudad,0) || nvl(inicialciudad,'') nombre_id_inicial
                                    INTO vIdCiudad, vNombreIdIniciales
                                    FROM bdinteg:si_catciudades
                                    WHERE nvl(numero_region,0) = pIdRegion
                                    --numerociudad = pCiudad
                                    ORDER BY numerociudad

                                    RETURN sCodRet,vIdCiudad, vNombreIdIniciales  WITH RESUME;
                            END FOREACH;
                END IF;
            END IF;
			LET iRegistros = DBINFO("sqlca.sqlerrd2");
			if iRegistros = 0 then
			 LET sCodRet='002';
                    LET cErrorInfo='NO HAY INFORMACION CON EL FILTRO INDICADO';
                    RETURN sCodRet,vIdCiudad, vNombreIdIniciales;
			END IF;
    END ;
END PROCEDURE
 DOCUMENT
'AUTOR: Alejandro Osuna Iza',
'Proyecto: Administracion de Regiones',
'Solicito: Paul Quintero',
'Descripcion: Obtiene las ciudades de las regiones correspondietnes',
'Fecha: 2010/06/14',
'Version: 20100614.1156',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_reporteconsolidadohuellas(psTipo1 CHAR(1), psTipo2 CHAR(1), psTipo3 CHAR(1), psTipo4 CHAR(1), psTipo5 CHAR(1), psTipo8 CHAR(1), psMes CHAR(2), psAnio CHAR(4))
	RETURNING CHAR(5);
	---**********************************************************
	-- Realizo   :Alejandro Osuna 
	--Solicito : Jorge Nuñ	-- Proyecto : Reporte Consolidado de Huellas
	-- Actividad : Obtiene lso datos necesarios para los reportes.
	-- Fecha     :30 de  Marzo  de 2009
	--******************************************************
	--Definicion de variables
	DEFINE v_sCodRet CHAR(5);
	DEFINE visqlerr INTEGER;
	DEFINE v_stipo SMALLINT;
	DEFINE v_inumcte INTEGER;
	DEFINE v_isecuencia INTEGER;
	DEFINE v_sstatus CHAR(1);
	DEFINE v_ireferencia INTEGER;
	DEFINE v_dfechamov DATE;
	DEFINE v_ikeyxcoppel INTEGER;
	DEFINE v_ikeyx INTEGER;
	DEFINE v_isecuenref INTEGER;
	DEFINE v_sNumcte CHAR(9);
	DEFINE v_sNumCteCu INTEGER;
	DEFINE v_stpoPerso CHAR(2);
	DEFINE v_sNombre1 CHAR(26);
	DEFINE v_sNombre2 CHAR(26);
	DEFINE v_sApellidoPa CHAR(26);
	DEFINE v_sApellidoMa CHAR(26);
	DEFINE v_dFechaNac DATE;
	DEFINE v_sRFC CHAR(13);
	DEFINE v_sEjecutivo CHAR(8);
	DEFINE v_dFechaAlta DATE;
	DEFINE v_sSucursal CHAR(4);
	DEFINE v_sfechamov CHAR(10);
	DEFINE v_sFechaAlta CHAR(10);
	DEFINE v_sFechaNac CHAR(10);
	DEFINE v_sNomejecutivo CHAR(45);

	DEFINE v_Tipo_1 SMALLINT;
	DEFINE v_Tipo_2 SMALLINT;
	DEFINE v_Tipo_3 SMALLINT;
	DEFINE v_Tipo_4 SMALLINT;
	DEFINE v_Tipo_5 SMALLINT;
	DEFINE v_Tipo_8 SMALLINT;
	DEFINE vdFechaIni DATETIME YEAR TO FRACTION(5);
	DEFINE vdFechaFin DATETIME YEAR TO FRACTION(5);
	
	DEFINE vsfechainicio CHAR(25);
	DEFINE vsfechafin CHAR(25);
	DEFINE vsRepositorio CHAR(90);
	
	DEFINE vsFlagEntro CHAR(1);
	
	DEFINE vsSQL CHAR(800);
	DEFINE vsSQL1 CHAR(150);
	DEFINE vsSQL2 CHAR(500);
	DEFINE vsSQL3 CHAR(150);
	
	LET vsSQL = '';
	LET vsSQL1 = '';
	LET vsSQL2 = '';
	LET vsSQL3 = '';

	--Inicializacion de Variables
	LET v_sCodRet = '00000';
	LET v_sstatus = '';
	LET v_sNumcte = '';
	LET v_stpoPerso = '';
	LET v_sRFC = '';
	LET v_sEjecutivo = '';
	LET v_sNombre1  = '';
	LET v_sNombre2 = '';
	LET v_sApellidoPa = '';
	LET v_sApellidoMa = '';
	LET v_dFechaAlta = '01/01/1900';
	LET v_sfechamov = '';
	LET v_sFechaAlta = '';
	LET v_sFechaNac = '';

	LET v_sSucursal = '';
	LET v_isecuenref = 0;
	LET v_ikeyxcoppel = 0;
	LET v_ikeyx = 0;
	LET v_dFechaNac = '01/01/1900';
	LET v_sNumCteCu = 0;
	LET v_dfechamov = '01/01/1900';
	LET v_ireferencia = 0;
	LET v_inumcte = 0;
	LET v_isecuencia = 0;
	LET v_stipo = 0;
	LET v_sNomejecutivo	 = '';

	LET v_Tipo_1 = 0;
	LET v_Tipo_2 = 0;
	LET v_Tipo_3 = 0;
	LET v_Tipo_4 = 0;
	LET v_Tipo_5 = 0;
	LET v_Tipo_8 = 0;
	LET vdFechaIni = CURRENT;
	LET vdFechaFin = CURRENT;
	
	LET vsfechainicio = '';
	LET vsfechafin = '';
	LET vsRepositorio = '';
	
	LET vsFlagEntro = 'F';

--	SET DEBUG FILE TO "/pisa/leo/tracehuellas.sql";
--	TRACE ON;
	
	BEGIN
		ON EXCEPTION SET  visqlerr
			IF visqlerr <> 0 THEN
				LET v_sCodRet = visqlerr;
				RETURN v_sCodRet;
			END IF;
		END EXCEPTION;

		IF (NVL(psTipo1, '') = '') THEN 
			LET psTipo1 = '-1';
		END IF;
		
		IF (NVL(psTipo2, '') = '') THEN 
			LET psTipo2 = '-1';
		END IF;
		
		IF (NVL(psTipo3, '') = '') THEN 
			LET psTipo3 = '-1';
		END IF;
		
		IF (NVL(psTipo4, '') = '') THEN 
			LET psTipo4 = '-1';
		END IF;
		
		IF (NVL(psTipo5, '') = '') THEN 
			LET psTipo5 = '-1';
		END IF;
		
		IF (NVL(psTipo8, '') = '') THEN 
			LET psTipo8 = '-1';
		END IF;
		
		LET v_Tipo_1 = psTipo1;
		LET v_Tipo_2 = psTipo2;
		LET v_Tipo_3 = psTipo3;
		LET v_Tipo_4 = psTipo4;
		LET v_Tipo_5 = psTipo5;
		LET v_Tipo_8 = psTipo8;
		
		LET vdFechaIni = psAnio || '-' ||  psMes || '-01 00:00:00';
		LET vdFechaFin = vdFechaIni + INTERVAL(1) MONTH TO MONTH;
		LET vsFlagEntro = 'F';
		
		LET vsfechainicio = vdFechaIni;
		LET vsfechafin = vdFechaFin;
		
		IF EXISTS(SELECT Valor FROM bdicred:sd_param WHERE Descripcion = "REPOSITORIOHUELLAS") THEN
			SELECT Valor INTO vsRepositorio FROM bdicred:sd_param WHERE Descripcion = "REPOSITORIOHUELLAS";
			IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'tmp_si_repconhue') THEN
					DROP TABLE tmp_si_repconhue;
			END IF;
			CREATE TABLE tmp_si_repconhue
			(
			keyx1		SERIAL,
			tipo		CHAR(4),
			numcte		CHAR(10),
			secuencia	CHAR(10),
			status		CHAR(6),
			referencia	CHAR(10),
			fechamov	CHAR(10),
			keyxcoppel	CHAR(10),
			keyx		CHAR(10),
			secuenref	CHAR(10),
			apellidopa	CHAR(26),
			apellidoma	CHAR(26),
			nombre1		CHAR(26),
			nombre2		CHAR(26),
			RFC			CHAR(13),
			sucursal	CHAR(4),
			fechaalta	CHAR(10),
			ejecutivo	CHAR(8),
			fechanac	CHAR(10),
			nomejecutivo CHAR(45)
			);
			
			INSERT INTO bdinteg:tmp_si_repconhue
			(tipo, numcte, secuencia, status, referencia, fechamov, keyxcoppel, keyx, secuenref, apellidopa, apellidoma, nombre1, nombre2, RFC, sucursal, 
			fechaalta, ejecutivo, fechanac, nomejecutivo)
			VALUES
			('', '', '', '', 'Fecha Ini', vsfechainicio, '', '', '', '', '', '', '', '', '', 
			'', '', '', '');
			INSERT INTO bdinteg:tmp_si_repconhue
			(tipo, numcte, secuencia, status, referencia, fechamov, keyxcoppel, keyx, secuenref, apellidopa, apellidoma, nombre1, nombre2, RFC, sucursal, 
			fechaalta, ejecutivo, fechanac, nomejecutivo)
			VALUES
			('', '', '', '', 'Fecha Fin', vsfechafin, '', '', '', '', '', '', '', '', '', 
			'', '', '', '');
			INSERT INTO bdinteg:tmp_si_repconhue
			(tipo, numcte, secuencia, status, referencia, fechamov, keyxcoppel, keyx, secuenref, apellidopa, apellidoma, nombre1, nombre2, RFC, sucursal, 
			fechaalta, ejecutivo, fechanac, nomejecutivo)
			VALUES
			('', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '');
			INSERT INTO bdinteg:tmp_si_repconhue
			(tipo, numcte, secuencia, status, referencia, fechamov, keyxcoppel, keyx, secuenref, apellidopa, apellidoma, nombre1, nombre2, RFC, sucursal, 
			fechaalta, ejecutivo, fechanac, nomejecutivo)
			VALUES
			('tipo', 'numcte', 'secuencia', 'status', 'referencia', 'fechamov', 'keyxcoppel', 'keyx', 'secuenref', 'apellidopa', 'apellidoma', 'nombre1', 'nombre2', 'RFC', 'sucursal', 
			'fechaalta', 'ejecutivo', 'fechanac', 'nomejecutivo');
			
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			FOREACH
				SELECT
				coppel.tipo,
				(LPAD(TRIM(coppel.numcte::CHAR(9)),9,'0')),
				TRIM(NVL(coppel.secuencia, '')),
				TRIM(NVL(coppel.status, '')),
				(RPAD(TRIM(coppel.referencia::CHAR(10)),10, ' ')),
				NVL(coppel.fechamov::DATE, '01/01/1900'),
				(RPAD(TRIM(coppel.keyxcoppel::CHAR(10)),10, ' ')),
				(RPAD(TRIM(coppel.keyx::CHAR(10)),10, ' ')),
				TRIM(NVL(coppel.secuenciareferencia, '')),
				(RPAD(TRIM(NVL(cliente.apell_paterno, '')),26, ' ')),
				(RPAD(TRIM(NVL(cliente.apell_materno, '')),26, ' ')),
				(RPAD(TRIM(NVL(cliente.nombre1, '')),26, ' ')),
				(RPAD(TRIM(NVL(cliente.nombre2, '')),26, ' ')),
				(RPAD(TRIM(NVL(cliente.rfc, '')),13, ' ')),
				(RPAD(TRIM(NVL(cliente.sucursal, '')),4, ' ')),
				TRIM(NVL(cliente.fecha_alta, '01/01/1900')), 
				(RPAD(TRIM(NVL(cliente.ejecutivo, '')),8, ' ')),
				TRIM(NVL(cte.fecha_nac, '01/01/1900')),
				(RPAD(TRIM(NVL(ejec.nombre, '')),45, ' '))
				
				INTO
				v_stipo,
				v_sNumcte,
				v_isecuencia,
				v_sstatus,
				v_ireferencia,
				v_dfechamov,
				v_ikeyxcoppel,
				v_ikeyx,
				v_isecuenref,
				v_sApellidoPa,
				v_sApellidoMa,
				v_sNombre1,
				v_sNombre2,
				v_sRFC, 
				v_sSucursal, 
				v_dFechaAlta, 
				v_sEjecutivo,
				v_dFechaNac,
				v_sNomejecutivo

				FROM ((bdinteg:si_clientecomparacioncoppel AS coppel INNER JOIN bdinteg:si_cliente AS cliente 
				ON cliente.numcte = (LPAD(TRIM(coppel.numcte::CHAR(9)),9,'0'))) LEFT JOIN bdinteg:si_ctepf  AS cte ON cte.numcte = cliente.numcte)
				LEFT JOIN bdinteg:si_ejecut AS ejec ON ejec.ejecutivo = cliente.ejecutivo
				WHERE coppel.tipo IN (v_Tipo_1, v_Tipo_2, v_Tipo_3, v_Tipo_4, v_Tipo_5, v_Tipo_8)
				AND coppel.numcte IS NOT NULL
				AND coppel.fechamov BETWEEN vdFechaIni AND vdFechaFin
				ORDER BY coppel.tipo
				
				INSERT INTO bdinteg:tmp_si_repconhue
				(
				tipo,
				numcte,
				secuencia,
				status,
				referencia,
				fechamov,
				keyxcoppel,
				keyx,
				secuenref,
				apellidopa,
				apellidoma,
				nombre1,
				nombre2,
				RFC, 
				sucursal, 
				fechaalta, 
				ejecutivo,
				fechanac,
				nomejecutivo
				)
				VALUES
				(
				v_stipo,
				v_sNumcte,
				v_isecuencia,
				v_sstatus,
				v_ireferencia,
				v_dfechamov,
				v_ikeyxcoppel,
				v_ikeyx,
				v_isecuenref,
				v_sApellidoPa,
				v_sApellidoMa,
				v_sNombre1,
				v_sNombre2,
				v_sRFC, 
				v_sSucursal, 
				v_dFechaAlta, 
				v_sEjecutivo,
				v_dFechaNac,
				v_sNomejecutivo
				);
				
			END FOREACH;
			
			LET vsSQL1 = 'echo "UNLOAD TO ' || TRIM(vsRepositorio) || '/' || 'ReporteConsolidadoHuellas' || psMes || psAnio || '.xls' || ' DELIMITER ' || '''	''';
			LET vsSQL2 = " SELECT tipo, numcte, secuencia, status, referencia, fechamov, keyxcoppel, keyx, secuenref," 
					  || " apellidopa, apellidoma, nombre1, nombre2, RFC, sucursal, fechaalta, fechanac, ejecutivo, nomejecutivo" 
					  || " FROM bdinteg:tmp_si_repconhue";
			
			LET vsSQL3 = ' " > '|| TRIM(vsRepositorio) || '/control_reporte.sql';
			LET vsSQL1 = TRIM(vsSQL1);
			LET vsSQL3 = TRIM(vsSQL3);
			LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;
			
			--Verifica que la consulta no este vacia.
			IF ( vsSQL <> '' ) THEN 
				SYSTEM vsSQL;
				--Permiso para la creacion de archivo.
				LET vsSQL = '' ;
				LET vsSQL = 'chmod 666 ' || TRIM(vsRepositorio) || '/control_reporte.sql' ;
				LET vsSQL = '' ;
				LET vsSQL = 'dbaccess bdinteg ' || TRIM(vsRepositorio) || '/control_reporte.sql' ;
				SYSTEM vsSQL ;
				--Borra el archivo de control.
				LET vsSQL = '' ;
				LET vsSQL = 'rm ' || TRIM(vsRepositorio) || '/control_reporte.sql';
				SYSTEM vsSQL ; 
				
				LET v_sCodRet = '00000';
			ELSE
				-- Consulta Vacia
				LET v_sCodRet = '00002';
			END IF;
			
			DROP TABLE tmp_si_repconhue;
		ELSE
			--Valor Repositorio no existe en la tabla parametros.
			LET v_sCodRet = '00001';
		END IF;
		
		RETURN v_sCodRet;
		
	END
END PROCEDURE
DOCUMENT
'Modificado: Edgar Ivan Rochin Rocha',
'Proyecto: Reporte de Huellas',
'Solicito: ',
'Descripcion: Se modifico el tipo de consulta para que la ejecucion de este procedimiento sea mas rapido.',
'Fecha: 2010/05/28',
'Version: 20100528.1640',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_reporteconsolidadohuellasdataset(vpMes CHAR(2), vpAnio CHAR(4))

	RETURNING CHAR(16) AS Total_Carga,  CHAR(60) AS Descripcion, INTEGER AS Match_Ambos_dedos_Cliente;

		---**********************************************************
	-- Realizo   :Alejandro Osuna
	--Solicito : Jorge Nuñez
	-- Proyecto : Reporte Consolidado de Huellas
	-- Actividad : Obtiene el total de cada tipo de operacion.
	-- Fecha     :30 de  Marzo  de 2009
	-- Modificado: Edgar Ivan Rochin Rocha 28/05/2010
		---**********************************************************

	DEFINE v_sCodRet CHAR(5);
	DEFINE sql_err Integer;
	--DEFINE v_sTotalCarga CHAR(16);
	--DEFINE viTipo1 INTEGER;
	DEFINE v_sDescripcion CHAR(60);
	DEFINE v_sCiclo CHAR(1);

	DEFINE vdFechaIni DATETIME YEAR TO FRACTION(5);
	DEFINE vdFechaFin DATETIME YEAR TO FRACTION(5);
	DEFINE viTipo INTEGER;
	DEFINE vsTotalTipo INTEGER;

	DEFINE viTipo1 INTEGER;
	DEFINE viTipo2 INTEGER;
	DEFINE viTipo3 INTEGER;
	DEFINE viTipo4 INTEGER;
	DEFINE viTipo5 INTEGER;
	DEFINE viTipo8 INTEGER;
	DEFINE viTotalCarga INTEGER;
	DEFINE viTotReg INTEGER;

	DEFINE v_sDescripcion1 CHAR (60);
	DEFINE v_sDescripcion2 CHAR (60);
	DEFINE v_sDescripcion3 CHAR (60);
	DEFINE v_sDescripcion4 CHAR (60);
	DEFINE v_sDescripcion5 CHAR (60);
	DEFINE v_sDescripcion8 CHAR (60);

	LET v_sCodRet = '00000';
	LET v_sDescripcion = '';
	LET v_sCiclo = '1';

	--LET viTipo1 = 0;
	LET vdFechaIni = CURRENT;
	LET vdFechaFin = CURRENT;
	LET viTipo = 0;
	LET vsTotalTipo = 0;

	LET viTipo1 = 0;
	LET viTipo2 = 0;
	LET viTipo3 = 0;
	LET viTipo4 = 0;
	LET viTipo5 = 0;
	LET viTipo8 = 0;
	LET viTotalCarga = 0;
	LET viTotReg = 0;

	LET v_sDescripcion1 = '1.- Cte Banco vs MaeCoppel';
	LET v_sDescripcion2 = '2.- Cte Banco vs EmpCoppel';
	LET v_sDescripcion3 = '3.- Cte Banco vs MaeBanco';
	LET v_sDescripcion4 = '4.- Cte Banco vs EmpBanco';
	LET v_sDescripcion5 = '5.- Cte Banco Comparación Directa';
	LET v_sDescripcion8 = '8.- Cte No Match';

	BEGIN
		ON EXCEPTION SET  sql_err
			IF sql_err <> 0 THEN
				let v_sCodRet =  sql_err;
			RETURN viTotalCarga, v_sDescripcion,viTipo1;
			END IF;
		END EXCEPTION;

--		SET DEBUG FILE TO "/pisa/leo/tracehuellas.sql";
--		TRACE ON;
		
		
    	let vpMes = lpad(vpMes::char(2)::integer,2,0);

		LET vdFechaIni = vpAnio || '-' || vpMes || '-01 00:00:00';
		LET vdFechaFin = vdFechaIni + INTERVAL(1) MONTH TO MONTH;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		
		
		FOREACH
			SELECT coppel.tipo, COUNT(coppel.tipo)
			INTO viTipo, viTotReg
			FROM bdinteg:si_clientecomparacioncoppel AS coppel INNER JOIN  bdinteg:si_cliente AS cliente
			ON cliente.numcte = (LPAD(TRIM(coppel.numcte::CHAR(9)),9,'0'))
			WHERE coppel.tipo IS NOT NULL
			AND coppel.numcte IS NOT NULL
			AND coppel.fechamov BETWEEN vdFechaIni AND vdFechaFin
			GROUP BY coppel.tipo
			ORDER BY coppel.tipo

			IF (viTipo = 1) THEN
				LET viTipo1 = viTotReg;
			ELIF (viTipo = 2) THEN
				LET viTipo2 = viTotReg;
			ELIF (viTipo = 3) THEN
				LET viTipo3 = viTotReg;
			ELIF (viTipo = 4) THEN
				LET viTipo4 = viTotReg;
			ELIF (viTipo = 5) THEN
				LET viTipo5 = viTotReg;
			ELIF (viTipo = 8) THEN
				LET viTipo8 = viTotReg;
			END IF;
		END FOREACH;

		LET viTotalCarga = viTipo1 + viTipo2 + viTipo3 + viTipo4 + viTipo5 + viTipo8;

		RETURN viTotalCarga, v_sDescripcion1,viTipo1 WITH RESUME;
		RETURN '', v_sDescripcion2,viTipo2 WITH RESUME;
		RETURN '', v_sDescripcion3,viTipo3 WITH RESUME;
		RETURN '', v_sDescripcion4,viTipo4 WITH RESUME;
		RETURN '', v_sDescripcion5,viTipo5 WITH RESUME;
		RETURN '', v_sDescripcion8,viTipo8 WITH RESUME;

	END;
END PROCEDURE
DOCUMENT
'Modificado: Edgar Ivan Rochin Rocha',
'Proyecto: Reporte de Huellas',
'Solicito: ',
'Descripcion: Se modifico el tipo de consulta para que la ejecucion de este procedimiento sea mas rapido.',
'Fecha: 2010/05/28',
'Version: 20100528.1640',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_depura_limites_x(p_fecha_hoy  date)

    RETURNING CHAR(5)  AS Codigo_retorno, 
              CHAR(80) AS Mensaje,
              CHAR(1)  AS Reverso,
              CHAR(25) AS StorePro;


   DEFINE p_mensaje   varchar(80);  
   DEFINE isam_err    smallint;
   DEFINE error_info  char(40);  
 

   DEFINE v_f_respeta    DATE;
   DEFINE v_f_depura     DATE;   
   DEFINE vi_valor    INTEGER;

   DEFINE v_codigo_retorno  CHAR(5);
   DEFINE v_mensaje	    CHAR(80);
   DEFINE v_reverso         CHAR(1);
   DEFINE v_store_pro       CHAR(25);
  
   DEFINE vsqlerr      INTEGER;

   DEFINE vrowid       INTEGER;     
	
	--*********************************************************--
	-- Creado por: Francisco Martinez Viveros	
	--Fecha: 07/JULIO/2010
    --Modificacion: 21/JULIO/2010
	--Objetivo: Diariamente depure la tabla si_limite_diario, 
    --de modo que conserve únicamente los últimos 15 días de información 
    --(con base en el campo f_operacion). 
	--*********************************************************--
      
   --    SET debug file TO "/tmp/depura_limite_x.out";
   --    TRACE ON;
              
            LET v_codigo_retorno = "00000";
            LET v_mensaje = "Proceso Inicio Correctamente!";
            LET v_reverso = '0';
            LET v_store_pro = 'sp_depura_limites_x';

        SET ISOLATION TO dirty READ;
        SET LOCK MODE TO wait 3;

    BEGIN
       ON EXCEPTION SET vsqlerr        
          IF vsqlerr <> 0 THEN      
               LET v_codigo_retorno = "00030";
               LET v_mensaje = "Se Genero Error de Exceptio, Verifique Datos SQL!";
               LET v_reverso = '1';
               LET v_store_pro = 'sp_depura_limites_x';              
             RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;            
          END IF;
       END EXCEPTION;


         SELECT valor
           INTO vi_valor
           FROM si_param
           WHERE empresa = '001'
             AND cod_param = '111';
            IF NOT EXISTS (SELECT valor FROM si_param WHERE empresa = '001' AND cod_param = '111')
              THEN 
                    LET vi_valor = 15;
                    LET v_codigo_retorno = "00032";
                    LET v_mensaje = "Se Genero Error en si_param, No Existe Parametro 111!";
                    LET v_reverso = '1';
                    LET v_store_pro = 'sp_depura_limites_x';                 
            END IF;   


           LET vrowid      = 0;
           LET v_f_respeta = (p_fecha_hoy - vi_valor units day);
           LET v_f_depura  = (v_f_respeta);


          IF (p_fecha_hoy is null) then
                    LET v_codigo_retorno = "00030";
                    LET v_mensaje = "Se genero error de Ejecucion, Fecha Nula!";
                    LET v_reverso = '1';
                    LET v_store_pro = 'sp_depura_limites_x';
                RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
          END IF;

          IF (p_fecha_hoy <> today) then
                    LET v_codigo_retorno = "00031";
                    LET v_mensaje = "Se genero error de Ejecucion, Diferente de Hoy!";
                    LET v_reverso = '1';
                    LET v_store_pro = 'sp_depura_limites_x';
                RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
          END IF;

 
               FOREACH cursor_borra WITH HOLD FOR
                SELECT {+index (si_limite_diario idx_limite_ope)} rowid 
                  INTO vrowid  
                  FROM bdinteg:si_limite_diario
                 WHERE f_operacion <= v_f_depura  
                

                BEGIN WORK;
                   DELETE FROM {+index (si_limite_diario idx_limite_dia)}
                     bdinteg:si_limite_diario WHERE 
                    CURRENT OF cursor_borra;                                                                             
               COMMIT WORK;
             END FOREACH;  

                IF (v_reverso <> '0') THEN
                   RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
                 END IF;                 
               
                  LET v_codigo_retorno = "00000";
                  LET v_mensaje = "Proceso de Depuracion, Termino Correctamente!";
                  LET v_reverso = '0';
                  LET v_store_pro = 'sp_depura_limites_x';                                

    END;   --begin        
  RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;

END PROCEDURE;