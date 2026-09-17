CREATE PROCEDURE "informix".sp_genarchivorepor(pdcve_sorteo char(5), pdFechaBusqueda DATE)
	RETURNING CHAR(5) AS CodRetorno,
              CHAR(5) AS Clave_Sorteo,
             CHAR(80) AS Mensaje;
	--DECLARACION
	DEFINE visqlerr INTEGER;
	DEFINE vsCodRetorno CHAR (5);
	DEFINE vsMensajeRetorno CHAR (80);
	DEFINE vsRepositorio CHAR (100);
	DEFINE vsCve_Sorteo CHAR (5);
	DEFINE vsFlagEsEmpleado CHAR (5);
	DEFINE vsArchTemporal CHAR (15);
	DEFINE vsNomArchivo CHAR (30);
	DEFINE vsSQL CHAR (1500);
	DEFINE vsSQL1 CHAR (200);
	DEFINE vsSQL2 CHAR (900);
	DEFINE vsSQL3 CHAR (200);
    DEFINE vi_valor CHAR (50);
    DEFINE pdrepositorio CHAR (50);
	DEFINE contfile INT;
	DEFINE numfile FLOAT;
	DEFINE numreg INT;
	DEFINE limitmin INT;
	DEFINE limitmax INT;
	--INICIALIZACION
--SET DEBUG FILE TO "/informix/ifg/salida/sp_genarchivorepor.out";
--TRACE ON;
	LET vsCodRetorno = '00000';
	LET vsMensajeRetorno = '';
	LET vsRepositorio = '';
	LET vsCve_Sorteo = '';
	LET vsFlagEsEmpleado = '';
	LET vsArchTemporal = '';
	LET vsNomArchivo = '';
	LET vsSQL = '';
	LET vsSQL1 = '';
	LET vsSQL2 = '';
	LET vsSQL3 = '';
	LET visqlerr = 0;
	LET contfile = 0;
    --FMV 19-OCT-2010: El parametro fecha de ejecucion del archivo sera hoy menos 1 dia,
    --                 ya que los procesos de traslado y detalle de boletos 
    --                 se ejecutan 1 dia despues de la fecha proceso
 
     LET pdFechaBusqueda = (pdFechaBusqueda - 1 units day);

	BEGIN
		ON EXCEPTION SET visqlerr --Control de errores.
			LET vsMensajeRetorno = 'ERROR NO CONTROLADO: ' || visqlerr ;
			RETURN visqlerr, '00000', vsMensajeRetorno;
		END EXCEPTION;
        IF EXISTS (SELECT {+index (si_sorteo idx_si_sorteo_cve)} flag_sort
                     FROM bdinteg:si_sorteo 
                    WHERE cve_sorteo = pdcve_sorteo AND pdFechaBusqueda BETWEEN  f_ini AND f_fin AND flag_sort = 2) THEN
					  -- FMV 26-AGO-2010: Se adiciona parametro 112
					 SELECT {+index (si_param 194_429)}  --FMV: 10-SEP-10 OPTIMIZADO
							   valor
					   INTO vi_valor
					   FROM si_param
					   WHERE empresa = '001'
						 AND cod_param = '112';
						IF NOT EXISTS (SELECT {+index (si_param 194_429)} valor
										 FROM si_param
										WHERE empresa = '001' AND cod_param = '112')
						  THEN
								LET vsCodRetorno = "00042";
								LET vsMensajeRetorno = "Error: No Existe ruta de deposito!";
							RETURN vsCodRetorno, pdcve_sorteo, vsMensajeRetorno;
						END IF;
					  LET pdrepositorio = vi_valor;
					--se valida lso datos de entradas
					IF (pdcve_sorteo =  '') or (pdcve_sorteo is null) THEN
						LET vsCodRetorno = '00002';
						LET vsMensajeRetorno = 'NUMERO DE SORTEO INVALIDO';
						RETURN vsCodRetorno, pdcve_sorteo, vsMensajeRetorno;
					END IF;
					IF EXISTS (select {+index (si_boleto_temp idx_si_boleto_temp)}
									   Boleto from bdinteg:si_boleto_temp
											 where cve_sorteo = pdcve_sorteo
											   and fecha between pdFechaBusqueda and pdFechaBusqueda )THEN
					ELSE
						LET vsCodRetorno = '00004';
						LET vsMensajeRetorno = 'NO EXISTEN DATOS CON LOS PARAMETROS DADOS';
						RETURN vsCodRetorno, pdcve_sorteo, vsMensajeRetorno;
					END IF;
					SELECT MAX(consecutivo)
					INTO numreg
					 FROM si_boleto_temp;
					LET numfile = numreg /450000;
					LET limitmin = 0;
					LET limitmax = 0;
					IF (numfile < 1)  THEN 
						LET numfile = 1;
					END IF;
					
					
					 IF (contfile <  numfile) or (contfile = numfile) THEN
							LET contfile = contfile + 1;
							LET limitmin = limitmin + 1;
							LET limitmax = numreg;
							
							LET vsArchTemporal = 'temporal.txt';
							LET vsNomArchivo = 'BANCOPPELSORTEO_' || SUBSTRING (pdFechaBusqueda FROM 9 FOR 2) || SUBSTRING (pdFechaBusqueda FROM 1 FOR 2) || SUBSTRING (pdFechaBusqueda FROM 4 FOR 2) ||'_'||contfile|| '.txt' ;
							--GENERA EL ARCHIVO DE INTERCAMBIO
							LET vsSQL1 = 'echo "UNLOAD TO ' || TRIM(pdrepositorio) || '/' || TRIM(vsArchTemporal) || ' DELIMITER ' || '''?''';
							
							
							LET vsSQL2 = "SELECT {+ INDEX (bdinteg:si_boleto_temp)idx_si_boleto_temp} ( NVL(Boleto, 0) ||'|'|| NVL(Estado, 0) ||'|'|| NVL(TRIM(ciudad), '')||'|'|| NVL(TRIM(Sucursal), '') ||'|'|| NVL(TRIM(Area), '')||'|'|| NVL(Caja, 0) ||'|'|| "
							|| "NVL(TRIM(TipoMov), '') ||'|'|| NVL(TRIM(SUBSTRING ( FolioSuc FROM 9 FOR 8)), '') ||'|'|| NVL(TRIM(NumCte), '') ||'|'||  NVL(Importe::INTEGER, 0) ||'|'|| NVL(TRIM(Telefono1), '') ||'|'|| NVL(TRIM(Telefono2), '') ||'|'||"
							|| "NVL(TRIM(Nombre), '') ||'|'|| NVL(TRIM(Domicilio), '') ||'|'|| NVL(f_registro, CURRENT) ||'|'|| NVL(TRIM(Origen), '') ||'|'|| NVL(Secuencia, 0) ||'|'|| NVL(TRIM(ent_fed), '')) "
							|| "FROM bdinteg:si_boleto_temp "
							|| "WHERE ciudad <> '' AND domicilio <> '' AND ent_fed <> '' AND Cve_Sorteo = '" || pdcve_sorteo ||	"'AND NumCte <> '' AND Estado <> 101 AND  consecutivo BETWEEN "|| limitmin || " AND " || limitmax 
							|| " AND Fecha = '" || pdFechaBusqueda || "' ;";
							
							LET vsSQL3 = ' " > '|| TRIM(pdrepositorio) || '/control_reporte.sql';
							LET vsSQL1 = TRIM(vsSQL1);
							LET vsSQL2 = TRIM(vsSQL2);
							LET vsSQL3 = TRIM(vsSQL3);
							LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;
							LET vsSQL = TRIM(vsSQL); 
							--CHECA QUE NO ESTE VACIA LA CONSULTA
							IF ( vsSQL <> '' ) THEN
								SYSTEM vsSQL ;
								--Permiso para la creacion de archivo.
								LET vsSQL = '' ;
								LET vsSQL = 'chmod 666 ' || TRIM(pdrepositorio) || '/control_reporte.sql' ;
								LET vsSQL = '' ;
								LET vsSQL = 'dbaccess BdInteg ' || TRIM(pdrepositorio) || '/control_reporte.sql' ;
								SYSTEM vsSQL ;
								--Borra el archivo de control.
								LET vsSQL = '' ;
								LET vsSQL = 'rm ' || TRIM(pdrepositorio) || '/control_reporte.sql';
								SYSTEM vsSQL ;
								--Elimina el caracter delimitador '?'.
								LET vsSQL = '' ;
								LET vsSQL =  "sed 's/?$//g' " || TRIM(pdrepositorio) || '/' || TRIM (vsArchTemporal) || " > " || TRIM(pdrepositorio) || '/' ||
								TRIM (vsNomArchivo);
								SYSTEM vsSQL;
								--Borra el archivo de control.
								LET vsSQL = '' ;
								LET vsSQL = 'rm ' || TRIM(pdrepositorio) || '/' || TRIM (vsArchTemporal);
								SYSTEM vsSQL ;
								LET vsMensajeRetorno = 'GENERACION DEL ARCHIVO ' || vsNomArchivo || ' FINALIZADA';
								--RETURN vsCodRetorno, pdcve_sorteo, vsMensajeRetorno;

							
							END IF;
							--LET limitmin = limitmin + limitmax;
							--LET limitmax = limitmax + limitmax;
					END IF;
					RETURN vsCodRetorno, pdcve_sorteo, vsMensajeRetorno;
		ELSE
		LET vsCodRetorno = "22222";
        LET vsMensajeRetorno = "ÃÂ¡EL SORTEO NAVIDEÃO NO ESTA ACTIVO!";
		RETURN vsCodRetorno, pdcve_sorteo, vsMensajeRetorno;
	END IF;	
	END;
END PROCEDURE
DOCUMENT
'AUTOR: Alejandro Osuna Iza',
'Descripcion: Generar archivo de boletos asignados para Coppel',
'Fecha: 2009/11/11',
'Version: 20091111.1757',
'BD: BdInteg',
'Modifico :Fabio Torres',
'Descripcion: Generar archivo de boletos asignados para Coppel',
'Fecha: 2009/11/26',
'BD: BdInteg',
'Modifico :Francisco Martinez Viveros',
'Descripcion: Generar archivo de boletos asignados para Coppel',
'Fecha: 2010/AGO/26',
'Ult. Modificacion: 2010/OCT/19',
'BD: BdInteg',
'MODIFICADO POR: ISRAEL FLORES GONZÃLEZ',
'FECHA DE MODIFICACION: 03 OCTUBRE DE 2013',
'OBJETIVO: SE GUARDA EL CAMPO DEL NOMBRE DEL ESTADO',
'          PARA QUE SE ENVIEN CON ESE DATO A TOMBOLA',
'BD: BdInteg',
'MODIFICADO POR: ISRAEL FLORES GONZÃLEZ',
'FECHA DE MODIFICACION: 02 DICIEMBRE DE 2015',
'OBJETIVO: DISCRIMINA DATOS BLANCOS EN LAS ',
'          DIRECCIONES DE CLIENTES EN LOS CAMPOS',
'          CIUDAD, DIRECCIÃN Y ENTIDAD FEDERATIVA',
'BD: BdInteg';

CREATE PROCEDURE "informix".sp_upd_emp_gc3()
				returning CHAR(5) AS Cod_Retorno;


DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;
--SISTEMA DE CUENTA 01 VARIABLES
DEFINE cTicket			CHAR(20);
DEFINE cEmpleado		CHAR(10);
DEFINE cEmpresa			CHAR(4);
DEFINE cNumcte			CHAR(20);
DEFINE cParam			CHAR(50);
DEFINE cRuta			CHAR(100);
DEFINE cCmd1 			CHAR(500);
DEFINE cCmd2 			CHAR(500);
DEFINE dFecha			CHAR(100);
DEFINE dHora			CHAR(100);
DEFINE iCampos			INT;

--inicializando variables
LET cCodRet = "00000";
LET iSql_err = 0 ;
LET cTicket = "" ;
LET cEmpleado = "" ;
LET cEmpresa = "" ;
LET cNumcte="";
LET cParam = "" ;
LET cCmd1 	 = '';
LET cCmd2 	 = '';
LET cRuta	 = '/RESPALDOSNEW/procesomasivo/';
LET dFecha	 ='date="$(date +"%x")"';
LET dHora	 ='hora="$(date +"%T")"';
LET iCampos=7;


BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/informix/CHVN/tmp/sp_upd_emp_gc.out";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
	SELECT valor INTO cParam
	FROM "informix".si_param
	WHERE cod_param = 308;		

	
--COMPARACION NOMBRES
		
	LET cCmd1 = "/usr/bin/echo '" || "SET ISOLATION TO DIRTY READ; UNLOAD TO '"|| TRIM(cRuta) ||"tmp_funciones.unl' "||" SELECT {+AVOID_FULL(si_funciones )}emp, nombre FROM si_funciones;" ||
	"' | /ifxsif01/bin/dbaccess bdinteg > /dev/null 2>&1";
	SYSTEM TRIM(cCmd1);

	LET cCmd1 = 'SELECT {+AVOID_FULL(si_cliente)} cte.numcte, TRIM(TRIM(cte.apell_paterno) ||" "|| TRIM(cte.apell_materno) ||" "|| TRIM(cte.nombre1) ||" "|| TRIM(cte.nombre2)) FROM si_cliente AS cte';
	LET cCmd1 = TRIM(cCmd1)|| ' WHERE cte.tpo_persona = "01" AND cte.tipo_cliente = 1 AND cte.fecha_alta >= "'||TRIM(cParam)||'"';
	LET cCmd1 = TRIM(cCmd1)|| ' AND NOT EXISTS (SELECT 1 FROM si_empleado_cliente_coppel AS ecc WHERE ecc.numcte=cte.numcte);';

	LET cCmd2 = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; UNLOAD TO '"||TRIM(cRuta)||"tmp_clientes.unl' "
	||TRIM(cCmd1)||"' | /ifxsif01/bin/dbaccess bdinteg > /dev/null 2>&1";
	SYSTEM TRIM(cCmd2);
	
	LET cCmd1 = "/usr/bin/awk -v "||TRIM(dFecha)||" -v "||TRIM(dHora)||" -v OFS='|' -F '|' 'NR==FNR{a[$2]=$1;next } $2 in a {print $1,a[$2],'3','0',date,hora,'1'}";
	LET cCmd2 = "' "||TRIM(cRuta)||"tmp_funciones.unl "||TRIM(cRuta)||"tmp_clientes.unl > "||TRIM(cRuta)||"tmp_compara.unl";
	SYSTEM TRIM(cCmd1)||TRIM(cCmd2);


	--Arma cargardatos_si_empleado_cliente_coppel.sh.sh
	LET cCmd1 = 'echo "FILE ' ||''''||TRIM(cRuta)||'tmp_compara.unl'||''''||' DELIMITER '||'''|'' '||iCampos ||';" > '||TRIM(cRuta)||'cargardatos_si_empleado_cliente_coppel.sh';
	SYSTEM cCmd1;
	LET cCmd1 = 'echo "INSERT INTO '||'''informix''.si_empleado_cliente_coppel;" >> '||TRIM(cRuta)||'cargardatos_si_empleado_cliente_coppel.sh';
	SYSTEM cCmd1;
	LET cCmd1 = 'chmod 755 '||TRIM(cRuta)||'cargardatos_si_empleado_cliente_coppel.sh';
	SYSTEM cCmd1;

	--Arma dbload_si_empleado_cliente_coppel.sh
	LET cCmd1 ='echo "nice -n -30 dbload -d bdinteg -c '||TRIM(cRuta)||'cargardatos_si_empleado_cliente_coppel.sh -n 5000 -l '||TRIM(cRuta)||'dbload_si_empleado_cliente_coppel.log" > '||TRIM(cRuta)||'dbload_si_empleado_cliente_coppel.sh';
	SYSTEM TRIM(cCmd1);
	
	LET cCmd1 = 'chmod 755 '||TRIM(cRuta)||'dbload_si_empleado_cliente_coppel.sh';
	SYSTEM cCmd1;
	
	--ejecuta dbload_si_empleado_cliente_coppel.sh
	LET cCmd1 = TRIM(cRuta)||'dbload_si_empleado_cliente_coppel.sh > dbload_si_empleado_cliente_coppel.log';
	SYSTEM cCmd1;
	
	
	SYSTEM '/usr/bin/rm -rf '||TRIM(cRuta)||'tmp_funciones.unl ' ||TRIM(cRuta)||'tmp_clientes.unl ' ||TRIM(cRuta)||'tmp_compara.unl';
				
	UPDATE si_param set valor = TODAY WHERE cod_param = 308;

	RETURN cCodRet;
END
END PROCEDURE;