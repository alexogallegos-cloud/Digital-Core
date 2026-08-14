CREATE PROCEDURE "informix".sp_concorresponsales(
psArchivoOrigen CHAR(3),
pdFecha DATE
)

RETURNING	CHAR(4) AS idterminal,
			DATETIME YEAR TO FRACTION(5) AS fechamov, 
			MONEY(16,6) AS monto,
			MONEY(16,6) AS comision, 
			MONEY(16,6) AS comisioniva,
			MONEY(16,6) AS idtpooperacion;

--****************************************************************************************************
-- DESCRIPCION: Consulta de administracion de corresponsales, obtiene informacion de tabla conarchcomisiones.
-- AUTOR : Rochin Rocha Edgar Ivan
-- FECHA : 04/22/2010
-- BD: Intercard
-- SISTEMA : Conciliacion Automatica
--****************************************************************************************************
--DECLARA VARIABLES
DEFINE vsarchivoorigen		CHAR(3);
DEFINE vsidterminal			CHAR(4);
DEFINE vdfechamov			DATETIME YEAR TO FRACTION(5);
DEFINE vmmonto				MONEY(16,6);
DEFINE vmcomision			MONEY(16,6);
DEFINE vmcomisioniva		MONEY(16,6);
DEFIne vmidtpooperacion     MONEY(16,6);

DEFINE viSqlErr				INTEGER;

--INICIA VARIABLES
LET vsarchivoorigen = '';
LET vsidterminal = '';
LET vdfechamov = CURRENT;
LET vmmonto = 0.0;
LET vmcomision = 0.0;
LET vmcomisioniva = 0.0;
LET vmidtpooperacion = 0.0;

LET viSqlErr = 0;

--SET DEBUG FILE TO "/home/sysifx/conciliacion/corresponsales/sp_concorresponsales.out";
--TRACE ON;

BEGIN

ON EXCEPTION SET viSqlErr   --cacha el error en caso de que exista y regresa un valor predeterminado
	IF viSqlErr <> 0 THEN
		RETURN  NVL(vsidterminal,''), 
				NVL(vdfechamov,CURRENT),
				NVL(vmmonto,0.0), 
				NVL(vmcomision,0.0), 
				NVL(vmcomisioniva ,0.0), 
				NVL(vmidtpooperacion,0.0)
		WITH RESUME;
	END IF;
END EXCEPTION ;

SET ISOLATION TO DIRTY READ ;
SET LOCK MODE TO WAIT 3;
--Verifica si el parametro archivo origen fue proporcionado en blanco o nulo.
IF(psArchivoOrigen = "") OR (psArchivoOrigen IS NULL)THEN
	--El campo archivo origen esta en blanco o nulo.
	LET vsarchivoorigen = '001';
	RETURN  NVL(vsidterminal,''), 
				NVL(vdfechamov,CURRENT),
				NVL(vmmonto,0.0), 
				NVL(vmcomision,0.0), 
				NVL(vmcomisioniva ,0.0), 
				NVL(vmidtpooperacion,0.0)
		WITH RESUME;
--Verifica si el parametro fecha fue proporcionado en blanco o nulo.
ELIF(pdFecha = "") OR (pdFecha IS NULL)THEN
	--El campo fecha esta en blanco o nulo.
	LET vsarchivoorigen = '002';
	RETURN  NVL(vsidterminal,''), 
				NVL(vdfechamov,CURRENT),
				NVL(vmmonto,0.0), 
				NVL(vmcomision,0.0), 
				NVL(vmcomisioniva ,0.0), 
				NVL(vmidtpooperacion,0.0)
		WITH RESUME;
ELSE
	--Se formatea el parametro fecha para realizar la consulta
	LET pdFecha = MDY(MONTH(pdFecha), DAY(pdFecha), YEAR(pdFecha)) -1 UNITS DAY;
	--Verifica si el archivoorigen proporcionado corresponde al archivo comisiones interrredes.
	IF((psArchivoOrigen = 'ACI') OR (psArchivoOrigen = 'ACC') OR (psArchivoOrigen = 'ACT'))THEN
		FOREACH
		SELECT idterminal, fechamov, monto, comision, comisioniva, idtpooperacion
		INTO   vsidterminal, vdfechamov, vmmonto, vmcomision, vmcomisioniva, vmidtpooperacion
		FROM   intercard:"informix".conarchcomisiones
		WHERE  archivoorigen = psArchivoOrigen AND fechamov::DATE = pdFecha ORDER BY keyx ASC
		RETURN  NVL(vsidterminal,''), 
				NVL(vdfechamov,CURRENT),
				NVL(vmmonto,0.0), 
				NVL(vmcomision,0.0), 
				NVL(vmcomisioniva ,0.0), 
				NVL(vmidtpooperacion,0.0)
		WITH RESUME;
		END FOREACH
	END IF;
END IF;

END
END PROCEDURE
/*DOCUMENT
'AUTOR: Rochin Rocha Edgar Ivan',
'Proyecto: Conciliacion Automatica',
'Descripcion: Consulta de administracion de corresponsales, obtiene informacion de tabla conarchcomisiones.',
'Fecha: 04/22/2010',
'Version: 20100422.1025',
'BD: Intercard',
'AUTOR: Edgar Ivan Rochin Rocha',
'MODIFICACION: Se modifica para que tome en cuenta las TRANSFERENCIAS DE PRESTAMOS.',
'Fecha: 31/05/2011',
'VERSION: 20110531.1747';,
'',
'Modifico:  L.I.A. Ricardo Reséndiz Martínez'
'Modificacion: SE modifica retorno para agregar campo de que almacena los tipos de identificadores de las operaciones por nuevo archivo de corresponsales.',
'Solicito: Jose Luis Puebla Salinas'
'Fecha: 14/10/2015',
'VERSION: 20151014.1747'; */                                                      ;

CREATE PROCEDURE "informix".sp_calcula_tarjetasbanda()
RETURNING 	  char (5) AS COD_RET,
			  char(150) AS MENSAJE;
			  

DEFINE cVarDataErr      CHAR(150);
DEFINE cCodret          CHAR(5);
DEFINE CMENSAJE			CHAR(150);

--

DEFINE vtipo3	INTEGER;
DEFINE Vtipo4	INTEGER;
DEFINE vtipo5	INTEGER;
DEFINE vtipo6	INTEGER;
DEFINE vtipo7	INTEGER;
DEFINE vtipo12	INTEGER;
DEFINE vtotalb	INTEGER;
DEFINE vtotalc	INTEGER;
DEFINE vtnxtipo3	INTEGER;
DEFINE vstnxtipo3	INTEGER; 
DEFINE vtnxtipo4	INTEGER;
DEFINE vstnxtipo4	INTEGER;
DEFINE vtotaltnx	INTEGER;
DEFINE vdebtotal	INTEGER;

--Variables de porcentajes

DEFINE vportipo3	DECIMAL(12,2);
DEFINE vportnxtipo3 	DECIMAL(12,2);
DEFINE vporstnxtipo3	DECIMAL(12,2);
DEFINE vportipo4	DECIMAL(12,2);
DEFINE vportnxtipo4	DECIMAL(12,2);
DEFINE vporstnxtipo4	DECIMAL(12,2);
DEFINE vportipo5	DECIMAL(12,2);
DEFINE vportipo6	DECIMAL(12,2);
DEFINE vportipo7	DECIMAL(12,2);
DEFINE vportipo12	DECIMAL(12,2);
DEFINE vportotalb	DECIMAL(12,2);
DEFINE vportotaltnx	DECIMAL(12,2);
DEFINE vportotalc	DECIMAL(12,2);
DEFINE vpordebtotal	DECIMAL(12,2);

---Variables de archivo

DEFINE vNombreArchivo	VARCHAR (50);
DEFINE vsql 			CHAR (2304);

---variables de control de errores
 
DEFINE	iSqlErr 		INTEGER;
DEFINE	iIsamErr		INTEGER;
DEFINE	vErrorInfo		VARCHAR(80);
DEFINE	vpaso			INTEGER;

---Variables de fecha

DEFINE vfecha_hoy		DATE;
DEFINE vano         	SMALlINT;
DEFINE vexp            	VARCHAR(4);
DEFINE vmes            	VARCHAR(2);
DEFINE vaniomes        	VARCHAR(6);
DEFINE ultimo_dia_mes 	DATE;
DEFINE ultimo_dia_mes_hora	DATETIME YEAR TO FRACTION(5);
DEFINE primer_dia_mes 	DATE;
DEFINE primer_dia_mes_hora	DATETIME YEAR TO FRACTION(5);


	/*SET DEBUG FILE TO "/informix/analy/sp_calcula_tarjetasbanda.out";
	TRACE ON; */

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, vErrorInfo
	IF iSqlErr <> 0 OR iIsamErr <> 0 THEN
			LET cCodret = iSqlErr;
			LET CMENSAJE = vErrorInfo;			
			RETURN cCodret, 'iIsamErr: '|| iIsamErr  || ' EN PASO: ' || vpaso|| ' ERR_DES ' || CMENSAJE ;
		END IF;
	END EXCEPTION;
	
---Inicializando variables
	
	let vtipo3 = 0;
	let vtipo4 = 0;
	let vtipo5 = 0;
	let vtipo6 = 0;
	let vtipo7 = 0;
	let vtipo12 = 0;
	let vtotalb	= 0;
	let vtotalc	= 0;
	let vtnxtipo3 = 0;
	let vstnxtipo3 = 0;
	let vtnxtipo4 = 0;
	let vstnxtipo4 = 0;
	let vtotaltnx = 0;
	let vdebtotal = 0;
	let vsql = '';
	
---inicializando variables de porcentajes

	let vportipo3 = 0;
	let vportnxtipo3 = 0;
	let vporstnxtipo3 = 0;
	let vportipo4 = 0;
	let vportnxtipo4 = 0;
	let vporstnxtipo4 = 0;
	let vportipo5 = 0;
	let vportipo6 = 0;
	let vportipo7 = 0;
	let vportipo12 = 0;
	let vportotalb = 0;
	let vportotaltnx = 0; 
	let vportotalc = 0;
	let vpordebtotal = 0;	
	
	let vmes='';
	let vpaso= 01;
	
	
---------se valida que la tmp1 no exista
	
	IF (SELECT COUNT(*) FROM sysmaster:systabnames WHERE tabname = 'tdschip1') > 0 THEN
		DROP TABLE tdschip1;
	END IF ;
	
--------se valida que la tmp2 no exista
	
	IF (SELECT COUNT(*) FROM sysmaster:systabnames WHERE tabname = 'tdschip2') > 0 THEN
	DROP TABLE tdschip2;
	END IF ;

--------se valida que la tmp3 no exista
	
	IF (SELECT COUNT(*) FROM sysmaster:systabnames WHERE tabname = 'tdschip3') > 0 THEN
	DROP TABLE tdschip3;
	END IF ;
	
	--se crea tmp3
	
	CREATE TABLE intercard:tdschip3(
    anioexp integer,
	mesexp  integer,
    codstatustarjeta varchar(3),
    cantidad integer);
	
-----SE OBTIENEN FECHAS
	
	let vpaso= 01;

	SET ISOLATION TO DIRTY READ;
	SELECT fecha_hoy INTO vfecha_hoy FROM  bdinteg:si_fechas; 

		LET vano = YEAR(vfecha_hoy);
		LET vmes = LPAD(MONTH(vfecha_hoy), 2,"0");
		LET vaniomes = vano||vmes;
		LET vaniomes = vaniomes;
		LET vexp = SUBSTR (vaniomes,3,4);

	 ----operaciones de fechas today-1
     LET ultimo_dia_mes = extend(extend(vfecha_hoy - 0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY;
     LET ultimo_dia_mes_hora = extend(extend(vfecha_hoy - 0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY;
     LET ultimo_dia_mes_hora = SUBSTRING(ultimo_dia_mes_hora FROM  1 FOR 10) || ' 23:59:59';
     --OBTIENE EL PRIMER DIA DEL MES
     LET primer_dia_mes = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);
     LET primer_dia_mes_hora = extend(extend(vfecha_hoy - 1 units MONTH ,YEAR TO MONTH)||"-01",YEAR TO DAY);
     LET primer_dia_mes_hora= SUBSTRING(primer_dia_mes_hora FROM  1 FOR 10) || ' 00:00:00';	
	
	
	
/*::::::::::::::::::::::::::::::::::::Reporte de Migración de Banda a Chip::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	              Se obtiene la cantidad e tarjetas existentes sin expirar y se inserta dentro de la tabla tdschip1*/
	
	--
	let vpaso= 1;

	SET ISOLATION TO dirty READ;
	SELECT lte.clave_tipotarjeta, substring(tjt.numtarjeta from 1 for 6) as bin, tjt.codstatustarjeta,count(*) as cantidad_tipo
	FROM intercard:tarjeta tjt, intercard:lote lte
	where tjt.numerolote = lte.numerolote and
		  lte.clave_tipotarjeta in (3,4,5,6,7,12) and
		  tjt.codstatustarjeta in('ACT','BLO','BLT') and
		  tjt.codstatusasignada = 'SIA' and   
		  lte.fechageneracion <= ultimo_dia_mes_hora and   --tarjetas generadas hasta el último día del mes
		  tjt.fechaexp >= vexp  --tarjetas que aún no han expirado al cierre del mes
	group by 1,2,3 INTO temp tdschip1 with no log;
	
	
	---guarda dentro de las variables
	
	SET ISOLATION TO dirty READ;
		SELECT sum(tipo3) as tipo3, sum(tipo4) as tipo4, sum(tipo5) as tipo5, sum(tipo6) as tipo6, sum(tipo7) as tipo7, sum(tipo12) as tipo12
		INTO vtipo3, vtipo4, vtipo5, vtipo6, vtipo7, vtipo12
		FROM 
		TABLE(MULTISET(
		SELECT 
			CASE WHEN clave_tipotarjeta = '3' THEN SUM(cantidad_tipo) ELSE 0 END AS tipo3,
			CASE WHEN clave_tipotarjeta = '4' THEN SUM(cantidad_tipo) ELSE 0 END AS tipo4,
			CASE WHEN clave_tipotarjeta = '5' THEN SUM(cantidad_tipo) ELSE 0 END AS tipo5,
			CASE WHEN clave_tipotarjeta = '6' THEN SUM(cantidad_tipo) ELSE 0 END AS tipo6,
			CASE WHEN clave_tipotarjeta = '7' THEN SUM(cantidad_tipo) ELSE 0 END AS tipo7,
			CASE WHEN clave_tipotarjeta = '12' THEN SUM(cantidad_tipo) ELSE 0 END AS tipo12
		FROM tdschip1
		GROUP BY clave_tipotarjeta));
	
	let vtotalb	= vtipo3 + vtipo4;
	let vtotalc	= vtipo5 + vtipo6 + vtipo7 + vtipo12;
	
		DROP TABLE tdschip1;
	
	
	let vpaso= 2;
	
	--movimiento  historico
	SET ISOLATION TO dirty READ;
		select distinct(tjt.numtarjeta), lte.clave_tipotarjeta
		from intercard:tarjeta tjt, intercard:lote lte, intercard:movimientohistorico mv
		where tjt.codstatustarjeta = 'ACT' and
			  tjt.numerolote = lte.numerolote and
			  lte.clave_tipotarjeta in(3,4) and
			  mv.numtarjeta = tjt.numtarjeta and
			  mv.codigoiso = '00' and
			  mv.transaccionorigen = '1234' and
			  mv.fechahorainauth >= primer_dia_mes_hora and
			  mv.fechahorainauth <= ultimo_dia_mes_hora
		group by 1,2 into temp tdschip2 with no log;

	
	let vpaso= 3;
	
	--movimiento
	SET ISOLATION TO dirty READ;
		insert into tdschip2 (numtarjeta, clave_tipotarjeta)
		select distinct(tjt.numtarjeta), lte.clave_tipotarjeta
		from intercard:tarjeta tjt, intercard:lote lte, intercard:movimiento mvs
		where tjt.codstatustarjeta = 'ACT' and
			  tjt.numerolote = lte.numerolote and
			  lte.clave_tipotarjeta in(3,4) and
			  mvs.numtarjeta = tjt.numtarjeta and
			  mvs.codigoiso = '00' and
			  mvs.transaccionorigen = '1234' and
			  mvs.fechahorainauth >= primer_dia_mes_hora and
			  mvs.fechahorainauth <= ultimo_dia_mes_hora
		group by 1,2;

	let vpaso= 4;
	
	--Cuenta tarjetas por clave de tarjeta
	SET ISOLATION TO dirty READ;
		SELECT sum(cant3), sum(cant4)
		INTO vtnxtipo3, vtnxtipo4
		FROM 
		TABLE(MULTISET(
			SELECT 
				CASE WHEN clave_tipotarjeta = '3' THEN  count(distinct numtarjeta) ELSE 0 END AS cant3,
				CASE WHEN clave_tipotarjeta = '4' THEN  count(distinct numtarjeta) ELSE 0 END AS cant4
			FROM tdschip2
		GROUP BY clave_tipotarjeta));
	
	
	let vpaso= 5;
	
	let vstnxtipo3 = vtipo3 - vtnxtipo3;
	let vstnxtipo4 = vtipo4 - vtnxtipo4;
	let vtotaltnx = vtnxtipo3 + vtnxtipo4;
	let vdebtotal =  vtotalb + vtotalc;
	
	---porcentajes

	let vportipo3 = round((vtipo3 / vdebtotal) * 100, 3);
	let vportnxtipo3 = round((vtnxtipo3 / vdebtotal) * 100,3);
	let vporstnxtipo3 = round((vstnxtipo3 / vdebtotal) * 100,3);
	let vportipo4 = round((vtipo4 / vdebtotal) * 100,3);
	let vportnxtipo4 = round((vtnxtipo4 / vdebtotal) * 100,3);
	let vporstnxtipo4 = round((vstnxtipo4 / vdebtotal) * 100,3);

	let vportipo5 = round((vtipo5 / vdebtotal) * 100,3);
	let vportipo6 = round((vtipo6 / vdebtotal) * 100,3);
	let vportipo7 = round((vtipo7 / vdebtotal) * 100,3);
	let vportipo12 = round((vtipo12 / vdebtotal) * 100,3);

	------------porcentajes de los totales

	let vportotalb = round(vportipo3  + vportipo4,3);
	let vportotaltnx =round((vtotaltnx / vdebtotal) * 100,3) ;
	let vportotalc = round(vportipo5 + vportipo6  + vportipo7 + vportipo12,3);
	let vpordebtotal = round(vportotalb + vportotalc,3);
	
	DROP TABLE tdschip2;
		
/*:::::::::::::::::::::::::::::::::::::::::::Reporte de Expiración de Tarjetas de Banda::::::::::::::::::::::::::::::::::::::::::::::*/
		
	let vpaso= 6;
	

	set isolation to dirty read;
		insert into intercard:tdschip3(anioexp, mesexp, codstatustarjeta, cantidad)
		select substring(tjt.fechaexp from 1 for 2) as anioexp,
			   substring(tjt.fechaexp from 3 for 4) as mesexp,
			   tjt.codstatustarjeta,
			   count(*) 
		from intercard:tarjeta tjt, intercard:tipotarjeta tpo, intercard:lote lte
		where tjt.numerolote = lte.numerolote and
			  tpo.clave_tipotarjeta = lte.clave_tipotarjeta and
			  lte.clave_tipotarjeta in(3,4) and
			  tjt.codstatustarjeta in ('ACT','BLO','BLT') and
			  tjt.fechaexp >= vexp 
		group by 1,2,3;
	

/*
:::::::::::::::::::::::::::::::::::::::::::Genera Reporte de Migración de Banda a Chip:::::::::::::::::::::::::::::::::::::::::::
*/
	--
	let vpaso= 7;
	
	LET vNombreArchivo = 'Avance_TDD_SChip'||YEAR ( ultimo_dia_mes )||LPAD ( MONTH ( ultimo_dia_mes ), 2, '0')|| LPAD ( DAY ( ultimo_dia_mes ), 2, '0')||'.txt';
	--LET vNombreArchivo = 'Avance_TDD_SChip'||LPAD ( DAY ( ultimo_dia_mes ), 2, '0')||LPAD ( MONTH ( today ), 2, '0')|| YEAR ( today )||'.txt';
	
	--Se crea archivo con encabezados.
	
	let vsql = ' echo "BIN|TIPO|IMAGEN|CHIP|No.|%">/resplogifx/'||TRIM(vNombreArchivo)||'';	
	
	--se crea el cuerpo del reporte uno por uno
	
	system vsql;
    let vsql = '';
    let vsql = ' echo "400819|3|Coppel|No|'||vtipo3||'|'||vportipo3||'% ">/resplogifx/archivo_fin1.txt';  	
	system vsql;
	let vsql ='';
	let vsql = ' echo "|||Con transaccionalidad en el mes:|'||vtnxtipo3||'|'||vportnxtipo3||'% ">/resplogifx/archivo_fin2.txt';  	
	system vsql;
	let vsql ='';
	let vsql = ' echo "|||Sin transaccionalidad en el mes:|'||vstnxtipo3||'|'||vporstnxtipo3||'% ">/resplogifx/archivo_fin3.txt';  	
	system vsql;
	let vsql ='';
	let vsql = ' echo "400819|4|BanCoppel|No|'||vtipo4||'|'||vportipo4||'% ">/resplogifx/archivo_fin4.txt';  	
	system vsql;
	let vsql ='';
	let vsql = ' echo "|||Con transaccionalidad en el mes:|'||vtnxtipo4||'|'||vportnxtipo4||'% ">/resplogifx/archivo_fin5.txt';  	
	system vsql;
	let vsql ='';
	let vsql = ' echo "|||Sin transaccionalidad en el mes:|'||vstnxtipo4||'|'||vporstnxtipo4||'% ">/resplogifx/archivo_fin6.txt';  	
	system vsql;
	let vsql ='';
	let vsql = ' echo "416916|5|BanCoppel|Si|'||vtipo5||'|'||vportipo5||'% ">/resplogifx/archivo_fin7.txt';  	
	system vsql;
	let vsql ='';
	let vsql = ' echo "400819|6|BanCoppel|Si|'||vtipo6||'|'||vportipo6||'% ">/resplogifx/archivo_fin8.txt';
	system vsql;
	let vsql ='';
	let vsql = ' echo "416916|7|Coppel|Si|'||vtipo7||'|'||vportipo7||'% ">/resplogifx/archivo_fin9.txt';
	system vsql;
	let vsql ='';
	let vsql = ' echo "416916|12|Coppel|Si|'||vtipo12||'|'||vportipo12||'% ">/resplogifx/archivo_fin10.txt';
	system vsql;
	let vsql ='';
	let vsql = ' echo "|||Total tarjetas débito banda:|'||vtotalb||'|'||vportotalb||'% ">/resplogifx/archivo_fin11.txt';
	system vsql; 
	let vsql ='';
	let vsql = ' echo "|||Total tarjetas débito banda con Txn en el mes:|'||vtotaltnx||'|'||vportotaltnx||'% ">/resplogifx/archivo_fin12.txt';
	system vsql;
	let vsql ='';
	let vsql = ' echo "|||Total tarjetas débito chip:|'||vtotalC||'|'||vportotalC||'% ">/resplogifx/archivo_fin13.txt';
	system vsql; 
	let vsql ='';
	let vsql = ' echo "|||TOTAL TARJETAS DE DEBITO:|'||vdebtotal||'|'||vpordebtotal||'% ">/resplogifx/archivo_fin14.txt';
	system vsql; 
	let vsql ='';
	
	
	--
	let vpaso= 8;
	
	--se van insertando los renglones dentro del archivo final
	
	let vsql ='';
    let vsql = "sed 's/|$//g' /resplogifx/archivo_fin1.txt >>/resplogifx/"||vNombreArchivo;       
    system vsql;
	let vsql ='';
    let vsql = "sed 's/|$//g' /resplogifx/archivo_fin2.txt >>/resplogifx/"||vNombreArchivo;       
    system vsql;
	let vsql ='';
    let vsql = "sed 's/|$//g' /resplogifx/archivo_fin3.txt >>/resplogifx/"||vNombreArchivo;       
    system vsql;
	let vsql ='';
    let vsql = "sed 's/|$//g' /resplogifx/archivo_fin4.txt >>/resplogifx/"||vNombreArchivo;       
    system vsql;
	let vsql ='';
    let vsql = "sed 's/|$//g' /resplogifx/archivo_fin5.txt >>/resplogifx/"||vNombreArchivo;       
    system vsql;
	let vsql ='';
    let vsql = "sed 's/|$//g' /resplogifx/archivo_fin6.txt >>/resplogifx/"||vNombreArchivo;       
    system vsql;
	let vsql ='';
    let vsql = "sed 's/|$//g' /resplogifx/archivo_fin7.txt >>/resplogifx/"||vNombreArchivo;       
    system vsql;
	let vsql ='';
    let vsql = "sed 's/|$//g' /resplogifx/archivo_fin8.txt >>/resplogifx/"||vNombreArchivo;       
    system vsql;
	let vsql ='';
    let vsql = "sed 's/|$//g' /resplogifx/archivo_fin9.txt >>/resplogifx/"||vNombreArchivo;       
    system vsql;
	let vsql ='';
    let vsql = "sed 's/|$//g' /resplogifx/archivo_fin10.txt >>/resplogifx/"||vNombreArchivo;       
    system vsql;
	let vsql ='';
    let vsql = "sed 's/|$//g' /resplogifx/archivo_fin11.txt >>/resplogifx/"||vNombreArchivo;       
    system vsql;
	let vsql ='';
    let vsql = "sed 's/|$//g' /resplogifx/archivo_fin12.txt >>/resplogifx/"||vNombreArchivo;       
    system vsql;
	let vsql ='';
    let vsql = "sed 's/|$//g' /resplogifx/archivo_fin13.txt >>/resplogifx/"||vNombreArchivo;       
    system vsql;
	let vsql ='';
    let vsql = "sed 's/|$//g' /resplogifx/archivo_fin14.txt >>/resplogifx/"||vNombreArchivo;       
    system vsql;
	
	--
	let vpaso= 9;	
	
	--se eliminan los archivos que forman el cuerpo
	
	LET vsql = '';
	LET vsql= 'rm -f /resplogifx/archivo_fin1.txt';
	SYSTEM vsql;
	LET vsql = '';
	LET vsql= 'rm -f /resplogifx/archivo_fin2.txt';
	SYSTEM vsql;
	LET vsql = '';
	LET vsql= 'rm -f /resplogifx/archivo_fin3.txt';
	SYSTEM vsql;
	LET vsql = '';
	LET vsql= 'rm -f /resplogifx/archivo_fin4.txt';
	SYSTEM vsql;
	LET vsql = '';
	LET vsql= 'rm -f /resplogifx/archivo_fin5.txt';
	SYSTEM vsql;
	LET vsql = '';
	LET vsql= 'rm -f /resplogifx/archivo_fin6.txt';
	SYSTEM vsql;
	LET vsql = '';
	LET vsql= 'rm -f /resplogifx/archivo_fin7.txt';
	SYSTEM vsql;
	LET vsql = '';
	LET vsql= 'rm -f /resplogifx/archivo_fin8.txt';
	SYSTEM vsql;
	LET vsql = '';
	LET vsql= 'rm -f /resplogifx/archivo_fin9.txt';
	SYSTEM vsql;
	LET vsql = '';
	LET vsql= 'rm -f /resplogifx/archivo_fin10.txt';
	SYSTEM vsql;
	LET vsql = '';
	LET vsql= 'rm -f /resplogifx/archivo_fin11.txt';
	SYSTEM vsql;
	LET vsql = '';
	LET vsql= 'rm -f /resplogifx/archivo_fin12.txt';
	SYSTEM vsql;
	LET vsql = '';
	LET vsql= 'rm -f /resplogifx/archivo_fin13.txt';
	SYSTEM vsql;
	LET vsql = '';
	LET vsql= 'rm -f /resplogifx/archivo_fin14.txt';
	SYSTEM vsql;
	
		
/*
::::::::::::::::::::::::::::::::::::::::Genera Reporte de Expiración de Tarjetas de Banda::::::::::::::::::::::::::::::::::::::::
*/	
	let vpaso= 10;	
	let vNombreArchivo='';
	LET vNombreArchivo = 'Vencim_TDD_SChip'||YEAR ( ultimo_dia_mes )||LPAD ( MONTH ( ultimo_dia_mes ), 2, '0')|| LPAD ( DAY ( ultimo_dia_mes ), 2, '0')||'.txt';
		
	--Se crea archivo con encabezados.
	
	let vpaso= 11;	
	let vsql = ' echo "AÑO|MES|ESTATUS TARJETA|CANTIDAD">/resplogifx/'||TRIM(vNombreArchivo)||'';	
	SYSTEM vsql; 
	
	let vpaso= 12;	
	LET vsql = 'echo "UNLOAD TO /resplogifx/archivofin15.txt select * from tdschip3 order by 1,2 " >/resplogifx/load_archivo.sql';             
	SYSTEM vsql;

	let vpaso= 13;
	
    LET vsql = '';
	LET vsql = 'dbaccess intercard /resplogifx/load_archivo.sql';
	SYSTEM vsql;
	
	--borra archivo
	
	LET vsql = '';
	LET vsql= 'rm -f /resplogifx/load_archivo.sql';
	SYSTEM vsql;

	--
	let vpaso= 14;	
	LET vsql = '';
	LET vsql= "sed 's/|$//g' /resplogifx/archivofin15.txt >>/resplogifx/"||TRIM(vNombreArchivo);
	SYSTEM vsql;
	
	--borra archivo
	
	LET vsql = '';
	LET vsql= 'rm /resplogifx/archivofin15.txt';
	SYSTEM vsql;
	

	let cCodret = '0000';
	let cVarDataErr = 'Reportes generados correctamente';
	
	DROP TABLE tdschip3;
	RETURN cCodret,cVarDataErr;
	
END	
END PROCEDURE
	
;