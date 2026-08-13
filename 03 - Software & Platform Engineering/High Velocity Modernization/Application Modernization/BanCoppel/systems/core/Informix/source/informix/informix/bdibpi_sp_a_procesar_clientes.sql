CREATE PROCEDURE "informix".sp_a_procesar_clientes()
returning varchar(5)

-- Realizó: Javier A. Chávez Trujillo
-- Solicitó: Mauricio León
-- Actividad: Genera archivos de clientes.
-- Fecha: 11-02-2010
--Modificó: Javier Chávez
--Modificacón: Se cambió el nombre de los archivos
--Fecha: 10-03-2010
--Modificó: Javier Calderón
--Modificacón: Se modifico para que la fecha inicial sea la ultima que se ejecuto el sp
--Fecha: 10-08-2010
--Modificó: Saul Ivanhoe Valdespino Hernandez
--Modificacón: Se modifico para que no ponga el caracter "\" al generar el archivo
--Fecha: 16-03-2011
--Modificó: Aìda Valenzuela Benitez
--Modificación: Se modificó para que cada campo este separado por un "|" (pipe) y se agrego el campo de estado
--Fecha: 19-02-2013

--DECLARA VARIABLES
DEFINE sql_err integer;
DEFINE cod_ret char(5);
DEFINE vDirectorio char(50);
DEFINE vNombreCliente char(20);
DEFINE vPeriodo char(12);
DEFINE vUnidadPeriodo integer;
DEFINE vsSQL1 char (100);
DEFINE vsSQL2 char (500);
DEFINE vsSQL3 char (100);
DEFINE vsSQL4 char (100);
DEFINE vsSQL char (900);
DEFINE vFechaHoy date;
DEFINE vFechaFinal date;
DEFINE vFechaInicial date;
DEFINE vFechaFinArchivo varchar(10);
DEFINE vFechaIniArchivo varchar(10);
DEFINE vsArchTemp char(20);
DEFINE vDia char(2);
DEFINE vMes char(2);
DEFINE vAnio char(4);
DEFINE vNumCte char(9);
DEFINE vFechaArchivo2 char(10);
DEFINE vFechaFinal2 char(10);
DEFINE vFechaFinalNueva char(10);
DEFINE vFechaAux date;
DEFINE vCondicion char(100);
DEFINE vFechaNueva date;
DEFINE vNombreNuevo char(20);
DEFINE vFechaMeses date;
DEFINE vBatch datetime year to second;
DEFINE viDiaMes INTEGER;
DEFINE viMes INTEGER;
DEFINE vdFechaMovil2 DATE;
DEFINe vcCodFechas CHAR(5);
DEFINE vdFechaDisponible1 DATE;
DEFINE vCont smallint;
DEFINE vDiaSemana smallint;
DEFINE vDiaInterAct smallint;
DEFINE vDiaInc smallint;
DEFINE vDiaExcepcion smallint;
DEFINE var1 CHAR(1);


--INICIA VARIABLES
LET vDirectorio = '';
LET cod_ret = "00008";
LET vNombreCliente = '';
LET vPeriodo = '';
LET vUnidadPeriodo = 0;
LET vFechaFinal = '01-01-1900';
LET vFechaInicial = '01-01-1900';
LET vFechaFinArchivo = '01-01-1900';
LET vFechaIniArchivo = '01-01-1900';
LET vFechaAux = '01-01-1900';
LET vsArchTemp = 'Temporal.txt';
LET vNumCte = '';
LET viDiaMes = 0;
LET viMes = 0;
LET vCont = 0;
LET vcCodFechas = '';
let var1='';


BEGIN

	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cod_ret = sql_err;
			SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME YEAR TO SECOND INTO vBatch FROM sysmaster:sysshmvals;
			INSERT INTO tkn_batch (id_proceso,f_proceso,descripcion,f_registro) VALUES (sql_err,vBatch,'Error informix',current);
			return cod_ret;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO  "/home/informix/ivonne/sp_a_procesar_clientes.out";
	--TRACE ON;

	--Inserta en bitacora el inicio.
	SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME YEAR TO SECOND INTO vBatch FROM sysmaster:sysshmvals;
	INSERT INTO tkn_batch (id_proceso,f_proceso,descripcion,f_registro) VALUES (10,vBatch,'Inicio de proceso',vBatch);
	--Trae los datos necesarios
	SELECT date(valor) INTO  vFechaFinal FROM tkn_parametros WHERE id_param = '17';
	LET vFechaHoy = date(current);

	--Si las fechas coinciden y hay registros crea el archivo
	IF ( vFechaHoy = vFechaFinal)	THEN
		SELECT valor INTO vDirectorio FROM tkn_parametros WHERE id_param = '13';
		SELECT COUNT(*), valor INTO vCont, vNombreCliente FROM tkn_parametros WHERE id_param = '18' GROUP BY valor;
		SELECT date(valor) INTO  vFechaInicial FROM tkn_parametros WHERE id_param = '40';
		LET vDia = LPAD(day(vFechaInicial),2,'0');
		LET vMes = LPAD(MONTH(vFechaInicial),2,'0');
		LET vAnio = YEAR(vFechaInicial);
		LET vFechaIniArchivo = vAnio||'-'||LPAD(vMes,2,'0')||'-'||LPAD(vDia,2,'0');
		LET vDia = LPAD(day(vFechaFinal),2,'0');
		LET vMes = LPAD(MONTH(vFechaFinal),2,'0');
		LET vAnio = YEAR(vFechaFinal);
		LET vFechaFinArchivo = vAnio||'-'||LPAD(vMes,2,'0')||'-'||LPAD(vDia,2,'0');
		LET vFechaArchivo2 = vAnio||LPAD(vMes,2,'0')||LPAD(vDia,2,'0');
		--Verifica el tipo de periodo que es y formatea las fechas
		
		SELECT LIMIT 1 numcte INTO vNumCte FROM  tkn_agendacte WHERE substring(f_registro::varchar(23) from 1 for 10) BETWEEN vFechaIniArchivo AND vFechaFinArchivo;
		LET vCondicion = " between '"||vFechaIniArchivo||"' AND '" ||vFechaFinArchivo||"'";
			
		IF (vNumCte	 <> '' OR vNumCte IS NOT NULL) THEN
			IF (vCont <> 0) THEN
				LET vNombreCliente = 'CTE' || TRIM(vFechaArchivo2) || '.txt';
				UPDATE tkn_parametros SET valor = vNombreCliente WHERE id_param = '18';
			ELSE
				LET vNombreCliente = 'CTE' || TRIM(vFechaArchivo2) || '.txt';
				INSERT INTO tkn_parametros(id_param,valor,descripcion,f_inicio,f_fin) VALUES('18',vNombreCliente,'Nombre del archivo de cliente','2010-01-01 00:00:00','9999-01-01 00:00:00');
			END IF;
			
			           
					           
            			
			LET vsSQL1 = 'echo "UNLOAD TO ' || TRIM(vDirectorio) ||  TRIM(vsArchTemp)|| ' DELIMITER ' || '''*''';
			LET vsSQL2 = " SELECT  numcte,'ABC',SUBSTR(razon_social,0,30),email,'|MX',destinatario,direccion,dir_com,SUBSTR(colonia,0,30),cp,SUBSTR(tel_cte,0,10),SUBSTR(tel_cte,12,20),SUBSTR(del_mpio,0,30),estado FROM bdibpi:tkn_agendacte WHERE substring(f_registro::varchar(23) from 1 for 10) "  || vCondicion  ;  
			LET vsSQL3 = '">' || TRIM(vDirectorio) || 'clientes.sql';
				
			

			LET vsSQL1 = TRIM(vsSQL1);
			LET vsSQL3 = TRIM(vsSQL3);	 
			LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3; 

			IF ( vsSQL <> '' ) THEN
				SYSTEM vsSQL ;
				LET vsSQL4 = '' ;
				LET vsSQL4 = 'dbaccess bdibpi ' || TRIM(vDirectorio) || 'clientes.sql';
				SYSTEM vsSQL4 ;
									
				LET vsSQL = '' ;
				LET vsSQL =  "sed 's/\*/\|/g;s/.$//g;s/\| |/\||/g;s/| |/||/g' " || TRIM(vDirectorio) || TRIM (vsArchTemp) || " > " || TRIM(vDirectorio) ||  TRIM (vNombreCliente);
				SYSTEM vsSQL ;

				LET vsSQL = '' ;
				LET vsSQL = 'rm ' || TRIM(vDirectorio) || TRIM(vsArchTemp);
				SYSTEM vsSQL;

				LET vsSQL = '' ;
				LET vsSQL = 'rm ' || TRIM(vDirectorio) || 'clientes.sql';
				SYSTEM vsSQL;

				LET cod_ret = '00000';
				SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME YEAR TO SECOND INTO vBatch FROM sysmaster:sysshmvals;
				INSERT INTO tkn_batch (id_proceso,f_proceso,descripcion,f_registro) VALUES (11,vBatch,'Creacion de nuevo archivo',vBatch);

			END IF;
		ELSE
			LET cod_ret = '00002';
			SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME YEAR TO SECOND INTO vBatch FROM sysmaster:sysshmvals;
			INSERT INTO tkn_batch (id_proceso,f_proceso,descripcion,f_registro) VALUES (11,vBatch,'No se encontraron registros',vBatch);

		END IF;
			
	ELSE

		LET cod_ret = '00001';
		SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME YEAR TO SECOND INTO vBatch FROM sysmaster:sysshmvals;
		INSERT INTO tkn_batch (id_proceso,f_proceso,descripcion,f_registro) VALUES (11,vBatch,'No concuerdan las fechas',vBatch);
	END IF;
	
		SELECT valor INTO vPeriodo FROM tkn_parametros WHERE id_param = '15';
		SELECT valor::INTEGER INTO vUnidadPeriodo FROM tkn_parametros WHERE id_param = '20';
		IF (UPPER(vPeriodo) = 'SEMANAL') THEN
			LET vFechaNueva = vFechaFinal + 7 * vUnidadPeriodo UNITS DAY;
			
		ELIF (UPPER(vPeriodo) = 'ANUAL') THEN
		-----------------------------------------------------
			LET viDiaMes   = DAY(vFechaFinal);
			LET viMes = MONTH(vFechaFinal);
			IF viMes = 2 AND viDiaMes = 29 THEN
				LET vFechaFinal = vFechaFinal - INTERVAL(1) DAY TO DAY;
			END IF;
			LET vFechaNueva = vFechaFinal + vUnidadPeriodo UNITS YEAR;
		ELIF (UPPER(vPeriodo) = 'DIARIO') THEN

			LET vFechaNueva = vFechaFinal + vUnidadPeriodo UNITS DAY;

		ELIF (UPPER(vPeriodo) = 'MENSUAL') THEN
		-----------------------------------------------------
			LET viDiaMes   = DAY(vFechaFinal);
			LET viMes = MONTH(vFechaFinal);
			LET vFechaAux = date(LPAD(viMes,2,'0') || '-' || '01' || '-' || YEAR(vFechaFinal)) + 1 UNITS MONTH;
			LET vFechaAux = vFechaAux - INTERVAL(1) DAY TO DAY;
			IF viDiaMes = DAY(vFechaAux) THEN
				LET vFechaNueva = date(LPAD(viMes,2,'0') || '-' || '01' || '-' || YEAR(vFechaFinal)) + vUnidadPeriodo + 1 UNITS MONTH;
				LET vFechaNueva = vFechaNueva - INTERVAL(1) DAY TO DAY;
			ELSE
				IF viDiaMes > 28 THEN
					LET vFechaAux = date(LPAD(viMes,2,'0') || '-' || '01' || '-' || YEAR(vFechaFinal)) + vUnidadPeriodo UNITS MONTH;
					IF MONTH(vFechaAux) = 2 THEN
						LET vFechaNueva = date(LPAD(viMes,2,'0') || '-' || '01' || '-' || YEAR(vFechaFinal)) + vUnidadPeriodo + 1 UNITS MONTH;
						LET vFechaNueva = vFechaNueva - INTERVAL(1) DAY TO DAY;
					ELSE
						LET vFechaNueva = vFechaFinal + vUnidadPeriodo UNITS MONTH;
					END IF;
				ELSE
					LET vFechaNueva = vFechaFinal + vUnidadPeriodo UNITS MONTH;
				END IF;
			END IF;
		ELIF (UPPER(vPeriodo) = 'INTERSEMANAL') THEN
			
			LET vDiaSemana = WEEKDAY(vFechaFinal);
			IF (vDiaSemana = 1) THEN
				LET vDiaExcepcion = 35;
			ELIF (vDiaSemana = 2) THEN
				LET vDiaExcepcion = 36;
			ELIF (vDiaSemana = 3) THEN
				LET vDiaExcepcion = 37;
			ELIF (vDiaSemana = 4) THEN
				LET vDiaExcepcion = 38;
			ELIF (vDiaSemana = 5) THEN
				LET vDiaExcepcion = 39;
			END IF;
			
			SELECT NVL(MIN(id_param::smallint),0)
			INTO vDiaInterAct 
			FROM tkn_parametros	
			WHERE id_param::smallint > vDiaExcepcion AND id_param::smallint <= 39 AND valor IN ('T');
			
			IF vDiaInterAct = 0 THEN
				SELECT NVL(MIN(id_param::smallint),0)
				INTO vDiaInterAct 
				FROM tkn_parametros	
				WHERE id_param::smallint >= 35 AND id_param::smallint < vDiaExcepcion AND valor IN ('T');
			END IF;
			
			IF vDiaInterAct <> 0 AND vDiaInterAct > vDiaExcepcion THEN
				LET vDiaInc = vDiaInterAct - vDiaExcepcion;
			ELIF vDiaInterAct <> 0 AND vDiaInterAct < vDiaExcepcion THEN
				LET vDiaInc = (vDiaInterAct - vDiaExcepcion) + 7;
			ELSE 
				LET vDiaInc = 7;
			END IF;
			
			LET vFechaNueva = vFechaFinal + vDiaInc UNITS DAY;
		END IF;

		LET vDia = LPAD(day(vFechaNueva),2,'0');
		LET vMes = LPAD(MONTH(vFechaNueva),2,'0');
		LET vAnio = YEAR(vFechaNueva);
		UPDATE tkn_parametros SET valor = 'CTE'||vAnio||vMes||vDia||'.txt'  WHERE id_param = '18';
		UPDATE tkn_parametros SET valor = vFechaNueva::varchar(10) WHERE id_param = '17';
		UPDATE tkn_parametros SET valor = vFechaHoy::varchar(10) WHERE id_param = '40';

	
	
	SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME YEAR TO SECOND INTO vBatch FROM sysmaster:sysshmvals;
	INSERT INTO tkn_batch (id_proceso,f_proceso,descripcion,f_registro) VALUES (12,vBatch,'Fin de proceso',vBatch);
	return cod_ret;
END;
END PROCEDURE;