CREATE PROCEDURE "informix".sp_puntoscompromiso3(psProdInd VARCHAR(2), psIdPOSATM VARCHAR(19),
psGiro VARCHAR(4), psTarjetas CHAR(570), psModoCaptura VARCHAR(2), psCodigoIso VARCHAR(2),   pdtFechaIni DATE, pdtFechaFin DATE,pUsuario CHAR(8),pRuta CHAR(100),pTipoReporte SMALLINT)
	 RETURNING CHAR(5) AS codret,
        CHAR(100) AS ruta,
		CHAR(30)  AS nombreArchivo;

--****************************************************************************************************
-- DESCRIPCION:  REPORTES DE PUNTOS DE COMPROMISO POS Y ATM  --TEST
-- AUTOR : Casanova Edeza Hector Juan
-- FECHA : 26/11/2010
-- BD: INTERCARD
-- SISTEMA : FRAUDES
-- MODIFICADO :
---- NOMBRE                        FECHA                    DESCRIPCION
--   Juan Daniel Lazalde        03-10-2013      Se agrego consulta en las tablas tarjeta y lote y se cambio el orden de las variables retorno
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */
DEFINE viContador INTEGER;
DEFINE vsSecuencia VARCHAR(7);
DEFINE vsCodigoIso VARCHAR(2);
DEFINE vsNumTarjeta VARCHAR(16);
DEFINE vsReferencia VARCHAR(12);
DEFINE vmMonto MONEY (19,4);
DEFINE vsInfReceptor VARCHAR(40);
DEFINE vsIdReceptor VARCHAR(4);
DEFINE vsIdTerminal VARCHAR(16);
DEFINE vsMetodoCaptura VARCHAR(2);
DEFINE vsMotivo VARCHAR(70);
DEFINE vdtFechaHoraInAuth DATETIME YEAR TO FRACTION(5);
DEFINE vsSecuenciaExtendida VARCHAR(16);
DEFINE vsNumCuenta VARCHAR(13);
DEFINE vsCiudadComercio VARCHAR(50);
DEFINE vsGiroComercio VARCHAR(4);
DEFINE vsIdRetailer VARCHAR(19);
DEFINE dtFechaOperacion DATE;
DEFINE dtHoraOperacion DATETIME HOUR TO FRACTION(5);

DEFINE vdtFechaIni DATETIME YEAR TO FRACTION(5);
DEFINE vdtFechaFin DATETIME YEAR TO FRACTION(5);

DEFINE viSqlErr INTEGER;
DEFINE viSamErr INTEGER;

DEFINE vdtFechaAux DATETIME YEAR TO FRACTION(5);

DEFINE cNombreArchivo CHAR(30);

--
DEFINE vsStatusTarjeta VARCHAR(3);
DEFINE vsNumCliente VARCHAR(13);
DEFINE vsSucursal VARCHAR(5);
DEFINE viNumeroLote INTEGER;
DEFINE viPaso INTEGER;
DEFINE vLongitud INTEGER;
DEFINE vAprobadaRechazada CHAR(1); --T:Todas, A:Aprobadas, R:Rechazadas
DEFINE vTarjetas CHAR(1); --T:Todas, A:Una o más
DEFINE vGiro CHAR(1); --T:Todas, A:Solo un giro
DEFINE vModoCaptura CHAR(1); --T:Todas, A:Solo un método de entrada
DEFINE vTerminalRetailer CHAR(1); --T:IDTerminal de ATM, R:IDRetailer de POS
DEFINE vIDTerminalRetailer CHAR(1); --T:Todos, A:Solo un ID
DEFINE cCmd1 CHAR(2500);
DEFINE cSql    CHAR(2500);
DEFINE pRutaGra CHAR(100);
DEFINE vfecha_ini CHAR(10);
DEFINE vfecha_fin CHAR(10);
DEFINE cDelFile CHAR(200);
DEFINE bInTransaction BOOLEAN;
DEFINE ven_transacc SMALLINT;

/* INICIALIZACION DE VARIABLES */
LET viContador = 0;
LET vsSecuencia = '';
LET vsCodigoIso = '';
LET vsNumTarjeta = '';
LET vsReferencia = '';
LET vmMonto = 0.0;
LET vsInfReceptor = '';
LET vsIdReceptor = '';
LET vsIdTerminal = '';
LET vsMetodoCaptura = '';
LET vsMotivo = '';
LET vdtFechaHoraInAuth = CURRENT;
LET vsSecuenciaExtendida = '';

LET vdtFechaIni = CURRENT;
LET vdtFechaFin = CURRENT;

LET viSqlErr = 0;
LET viSamErr = 0;

LET vsStatusTarjeta = '';
LET vsNumCliente = '';
LET vsSucursal = '';
LET viNumeroLote = 0;

LET vsNumCuenta = '';
LET vsCiudadComercio = '';
LET vsGiroComercio = '';
LET vsIdRetailer = '';
LET dtFechaOperacion = TODAY;
LET dtHoraOperacion = TODAY;

LET viPaso = 0;
LET vLongitud = 0;
LET vAprobadaRechazada = '';
LET vTarjetas = '';
LET vGiro = '';
LET vModoCaptura = '';
LET vTerminalRetailer = '';
LET vIDTerminalRetailer = '';
LET cNombreArchivo = '';
LET cCmd1='';
LET cSql='';
LET pRutaGra='';
LET vfecha_ini='';
LET vfecha_fin='';
LET cDelFile='';
LET bInTransaction = 'f';
LET ven_transacc = 0;

BEGIN
	 ON EXCEPTION

		SET viSqlErr, viSamErr
		
		IF ven_transacc = 1 THEN
			ROLLBACK WORK; --		
		END IF;
		RETURN viSqlErr,NULL,NULL;

	END EXCEPTION;

	ON EXCEPTION IN (-668, -535, -255)
		LET bInTransaction = 't';
		COMMIT WORK;
		BEGIN WORK;
	END EXCEPTION WITH RESUME;
		
	--SET DEBUG FILE TO "/tmp/mfinis/sp_puntoscompromiso3.out";
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;


	--DROP TABLE IF EXISTS intercard:"informix".temp_Tarjetas4;
	DELETE FROM bdicnweb:"informix".sw_con_puntoscompromisos WHERE us_insert=pUsuario;
	DELETE FROM bdicnweb:"informix".sw_con_pcompromisostarjetas WHERE us_insert=pUsuario;
	--create temp table temp_Tarjetas4(
	--	     tt_numtarjeta CHAR(16)) with no log;


	LET psProdInd = trim(psProdInd);
	LET psIdPOSATM = trim(psIdPOSATM);
    LET psGiro = trim(psGiro);
	LET psTarjetas = trim(psTarjetas);
	LET psModoCaptura = trim(psModoCaptura);
 	LET psCodigoIso = trim(psCodigoIso);
	--// PONE EN VARIABLES LA FECHA SOLICITADA (DDMMYYYY)
	LET vfecha_ini = LPAD(DAY(pdtFechaIni),2,0)||LPAD(MONTH(pdtFechaIni),2,0)||YEAR(pdtFechaIni);
	LET vfecha_fin = LPAD(DAY(pdtFechaFin),2,0)||LPAD(MONTH(pdtFechaFin),2,0)||YEAR(pdtFechaFin);

	 IF(psProdInd = '01') THEN
		LET vTerminalRetailer = 'T'; --ATM
		LET cNombreArchivo = REPLACE(('ATM_'||vfecha_ini||'_'||vfecha_fin||'.txt'),' ','');
	 ELSE
        LET vTerminalRetailer = 'R'; --POS
		LET cNombreArchivo = REPLACE(('POS_'||vfecha_ini||'_'||vfecha_fin||'.txt'),' ','');
     END IF;

	 IF(psIdPOSATM = '') THEN
		LET vIDTerminalRetailer = 'T'; --ATM
	 ELSE
        LET vIDTerminalRetailer = 'A'; --POS
     END IF;

	 IF(psGiro = '') THEN
		LET vGiro = 'T';
	 ELSE
        LET vGiro = 'A';
     END IF;

	 IF(psModoCaptura = '') THEN
		LET vModoCaptura = 'T';
	 ELSE
	 	LET vModoCaptura = 'A';
     END IF;

	 IF(psCodigoIso = '') THEN
			 LET vAprobadaRechazada = 'T'; --Todas
		 ELIF(psCodigoIso = '99') THEN
		     LET vAprobadaRechazada = 'R'; --Solo Rechazadas
		 ELIF(psCodigoIso = '00') THEN
		     LET vAprobadaRechazada = 'A'; --Solo Aprobadas
     END IF;

	IF(psTarjetas = '') THEN
		LET vTarjetas = 'T';
	ELSE
		LET vTarjetas = 'A';
		LET viPaso = 1;
		LET vLongitud = length(psTarjetas);
		WHILE viPaso < vLongitud
			insert into bdicnweb:"informix".sw_con_pcompromisostarjetas (tt_numtarjeta,us_insert,fecha_insert) values(substring(psTarjetas from viPaso for (viPaso + 16)), pUsuario, current);
			LET viPaso = viPaso + 17;
		END WHILE;
    END IF;

	IF (NVL(psProdInd,'00') <> '01') AND (NVL(psProdInd,'00') <> '02') THEN --ERROR

		RETURN '00001',NULL,NULL;

		--ATM 01   POS 02
	ELIF (((psProdInd = '01') AND (LENGTH(NVL(psIdPOSATM, '')) > 16) AND (NVL(psIdPOSATM, '') <> ''))
		OR ((psProdInd = '02') AND (LENGTH(NVL(psIdPOSATM, '')) > 19) AND (NVL(psIdPOSATM, '') <> ''))) THEN


		RETURN '00002',NULL,NULL;

	ELIF (pdtFechaIni IS NULL) OR  (pdtFechaFin IS NULL) THEN --ERROR


		RETURN '00003',NULL,NULL;

	ELSE

		LET vdtFechaIni = pdtFechaIni;
		LET vdtFechaIni = SUBSTRING(vdtFechaIni FROM 1 FOR 10) || ' 00:00:00';

		LET vdtFechaFin = pdtFechaFin;
		LET vdtFechaFin = SUBSTRING(vdtFechaFin FROM 1 FOR 10) || ' 23:59:59';

		LET vdtFechaAux = CURRENT;

		--OBTIENE LA FECHA MINIMA DE LA TABLA DE MOVIMIENTOS
		SELECT {+INDEX(intercard:"informix".movimiento "informix".idx_fechahorainauth)} MIN(FechaHoraInAuth)
		INTO vdtFechaAux
		FROM intercard:"informix".movimiento;

		SET ISOLATION TO DIRTY READ;
		
		IF ((pdtFechaIni BETWEEN vdtFechaAux::DATE AND CURRENT::DATE)
				OR  (pdtFechaFin BETWEEN vdtFechaAux::DATE AND CURRENT::DATE) )THEN --VALIDA SI EL RANGO DE BUSQUEDA ESTA DENTRO DE LA TABLA DE MOVIMIENTOS
				LET viPaso = 1;
				INSERT INTO bdicnweb:"informix".sw_con_puntoscompromisos (codstatustarjeta,numcliente,clave_sucursal,numtarjeta,infreceptor,fechahora,monto,
				idterminal,idreceptor,metodocaptura,codigoiso,motivo,numerolote,secuencia,referencia,numcuenta,cdcomercio,
				codgironeg,idretailer,fecha,hora,us_insert,fecha_insert)
				SELECT {+INDEX(intercard:"informix".movimiento "informix".idx_movimientonew4a)} 
					t.codstatustarjeta, t.numcliente, l.clave_sucursal, m.NumTarjeta, m.InfReceptor, m.FechaHoraInAuth AS fechahora, m.Monto, m.IdTerminal, m.IdReceptor, m.MetodoCaptura, m.CodigoIso, m.Motivo, t.numerolote, m.Secuencia, m.Referencia,
					r.numcuenta, '' AS cdcomercio, m.codgironeg AS giro, m.idretailer as idcomercio, m.fechahorainauth::date as fceha, substr(m.fechahorainauth,12,8) as hora, pUsuario, CURRENT
					FROM intercard:"informix".movimiento m
					LEFT JOIN intercard:"informix".tarjeta t on t.numtarjeta = m.NumTarjeta
					LEFT JOIN intercard:"informix".lote l on l.numerolote = t.numerolote
					LEFT JOIN intercard:"informix".tarjetacuenta r on r.numtarjeta = m.Numtarjeta
					WHERE m.FechaHoraInAuth BETWEEN vdtFechaIni AND vdtFechaFin
					AND m.ProdInd = psProdInd
					AND((vTerminalRetailer = 'T' AND vIDTerminalRetailer = 'A' AND m.IdTerminal = psIdPOSATM) OR
						(vTerminalRetailer = 'T' AND vIDTerminalRetailer = 'T' AND 1=1) OR
						(vTerminalRetailer = 'R' AND vIDTerminalRetailer = 'A' AND m.IdRetailer = psIdPOSATM) OR
						(vTerminalRetailer = 'R' AND vIDTerminalRetailer = 'T' AND 1=1))
					AND((vModoCaptura = 'A' AND m.metodocaptura = psModoCaptura) OR
						(vModoCaptura = 'T' AND 1 = 1))
					AND((vGiro = 'A' AND m.codgironeg = psGiro) OR
						(vGiro = 'T' AND 1 = 1))
					AND ((vTarjetas = 'A' AND m.numtarjeta in(select tt_numtarjeta from bdicnweb:"informix".sw_con_pcompromisostarjetas WHERE us_insert=pUsuario)) OR
						 (vTarjetas = 'T' AND 1=1 ))
					AND((vAprobadaRechazada = 'T' AND 1=1) OR
						(vAprobadaRechazada = 'A' AND m.codigoiso = '00') OR
						(vAprobadaRechazada = 'R' AND m.codigoiso <> '00'))
					ORDER BY m.FechaHoraInAuth DESC;
		
		END IF;

		IF ((pdtFechaIni BETWEEN '01/01/1900' AND (vdtFechaAux::DATE + 1))
			OR  (pdtFechaFin BETWEEN '01/01/1900' AND (vdtFechaAux::DATE + 1))) THEN --VALIDA SI EL RANGO DE BUSQUEDA ESTA DENTRO DE LA TABLA DE MOVIMIENTOHISTORICO
				LET viPaso = 2;

				INSERT INTO bdicnweb:"informix".sw_con_puntoscompromisos (codstatustarjeta,numcliente,clave_sucursal,numtarjeta,infreceptor,fechahora,monto,
							idterminal,idreceptor,metodocaptura,codigoiso,motivo,numerolote,secuencia,referencia,numcuenta,cdcomercio,
							codgironeg,idretailer,fecha,hora,us_insert,fecha_insert)
				SELECT t.codstatustarjeta, t.numcliente, l.clave_sucursal, m.NumTarjeta, m.InfReceptor, m.FechaHoraInAuth AS fechahora, m.Monto, m.IdTerminal, m.IdReceptor, m.MetodoCaptura, m.CodigoIso, m.Motivo, t.numerolote, m.Secuencia, m.Referencia,
					r.numcuenta, '' AS cdcomercio, m.codgironeg AS giro, m.idretailer AS idcomercio, m.fechahorainauth::date AS fecha, substr(m.fechahorainauth,12,8) AS hora, pUsuario, CURRENT
					FROM intercard:"informix".movimientohistorico m
					LEFT JOIN intercard:"informix".tarjeta t on t.numtarjeta = m.NumTarjeta
					LEFT JOIN intercard:"informix".lote l on l.numerolote = t.numerolote
					LEFT JOIN intercard:"informix".tarjetacuenta r on r.numtarjeta = m.Numtarjeta
					WHERE m.FechaHoraInAuth BETWEEN vdtFechaIni AND vdtFechaFin
					AND m.ProdInd = psProdInd
					AND((vTerminalRetailer = 'T' AND vIDTerminalRetailer = 'A' AND m.IdTerminal = psIdPOSATM) OR
						(vTerminalRetailer = 'T' AND vIDTerminalRetailer = 'T' AND 1=1) OR
						(vTerminalRetailer = 'R' AND vIDTerminalRetailer = 'A' AND m.IdRetailer = psIdPOSATM) OR
						(vTerminalRetailer = 'R' AND vIDTerminalRetailer = 'T' AND 1=1))
					AND((vModoCaptura = 'A' AND m.metodocaptura = psModoCaptura) OR
						(vModoCaptura = 'T' AND 1 = 1))
					AND((vGiro = 'A' AND m.codgironeg = psGiro) OR
						(vGiro = 'T' AND 1 = 1))
					AND ((vTarjetas = 'A' AND m.numtarjeta in(select tt_numtarjeta from bdicnweb:"informix".sw_con_pcompromisostarjetas WHERE us_insert=pUsuario)) OR
						(vTarjetas = 'T' AND 1=1 ))
					AND((vAprobadaRechazada = 'T' AND 1=1) OR
						(vAprobadaRechazada = 'A' AND m.codigoiso = '00') OR
						(vAprobadaRechazada = 'R' AND m.codigoiso <> '00'))
					ORDER BY m.FechaHoraInAuth DESC;
			
			END IF;

			LET cSql='rm -f '||TRIM(pRuta)||'ATM_*.txt';
			SYSTEM TRIM(cSql);
			LET cSql='rm -f '||TRIM(pRuta)||'POS_*.txt';
			SYSTEM TRIM(cSql);
			
			LET pRutaGra = TRIM(pRuta)||TRIM(cNombreArchivo);
			
			BEGIN WORK;
			LET ven_transacc = 1;
			
			IF(pTipoReporte=1) THEN --FORMATO CORTO
				LET cCmd1 ="  "|| "SELECT ROW_NUMBER() OVER(ORDER BY fechahora DESC) AS consecutivo,codstatustarjeta,numcliente,clave_sucursal,numtarjeta, ";
				LET cCmd1 =""||TRIM(cCmd1)||"infreceptor,TO_CHAR(fechahora, '%d/%m/%Y %I:%M:%S %p'),monto,idterminal,idreceptor,metodocaptura,codigoiso,motivo,numerolote,secuencia,referencia ";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:sw_con_puntoscompromisos WHERE us_insert="||pUsuario;

			ELSE 					--FORMATO LARGO
				LET cCmd1 ="  "|| "SELECT ROW_NUMBER() OVER(ORDER BY fechahora DESC) AS consecutivo,codstatustarjeta,numcliente,clave_sucursal, ";
				LET cCmd1 =""||TRIM(cCmd1)||"numtarjeta,infreceptor,TO_CHAR(fechahora, '%d/%m/%Y %I:%M:%S %p'),monto,idterminal,idreceptor,metodocaptura,codigoiso,motivo,numerolote,secuencia, ";
				LET cCmd1 =""||TRIM(cCmd1)||"NVL(referencia,'') AS referencia,NVL(numcuenta,'') AS numcuenta,NVL(cdcomercio,'') AS cdcomercio,NVL(codgironeg,'') AS codgironeg,NVL(idretailer,'') AS idretailer,fecha, hora";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:sw_con_puntoscompromisos WHERE us_insert="||pUsuario;
			END IF;

			LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(pRutaGra)||' '||TRIM(cCmd1)||' " > '||TRIM(pRuta)||'query07.sql';
			--COMMIT WORK;
			SYSTEM TRIM(cSql);
			--BEGIN WORK;
			
			LET  cDelFile = '/usr/bin/chmod 777 '||TRIM(pRuta)||'query07.sql';
			SYSTEM TRIM(cDelFile);

			LET cSql = '';
			--LET cSql = '/informix/bin/dbaccess bdicnweb '||TRIM(pRuta)||'query07.sql'; -- desarrollo
			LET cSql = '/ifxsif01/bin/dbaccess bdicnweb '||TRIM(pRuta)||'query07.sql'; --produccion
			SYSTEM TRIM(cSql);

			LET cSql = '';
			LET cSql = '/usr/bin/rm -rf '||TRIM(pRuta)||'query07.sql';
			SYSTEM TRIM(cSql);

	END IF;

	COMMIT WORK;
	
	LET ven_transacc = 0;
	IF bInTransaction = 't' THEN
		BEGIN WORK;
	END IF;
	
	RETURN  '00000', pRuta, cNombreArchivo;

END;
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 16/02/2016',
'MODULO: CONSULTAS > APOYO',
'FUNCIONALIDAD: CONSULTAS DE PUNTOS COMPROMISOS',
'DESCRIPCION:SPL Intermedio que consulta la informacion para ser exportada en un archivo -Puntos Compromisos',
'AUTOR: L. Montserrat León Amador',
'FECHA: 24/03/2017',
'DESCRIPCION: Se modifica spl para homologar que la recuperación de la informacion sea por el usuario en sesión.',
'AUTOR: L. Montserrat León Amador',
'FECHA: 01/06/2017',
'DESCRIPCION: Se modifica spl para eliminar la sentencia sequence y en su lugar hacer uso de ROW_NUMBER.',
'BD: intercard';

CREATE PROCEDURE "informix".sp_solicitudes_reposiciones_tarjetas()
RETURNING VARCHAR(5), VARCHAR(255);  

--*************************************************************************************************************************************^***
 -- DESCRIPCIÓN: Reporte de solicitudes y reposiciones de tarjetas personalizadas.                                                                          *
 -- AUTOR : Esmeralda J. Figueroa Acosta                                                                                                  *
 -- FECHA : 08/Agosto/2017                                                                                                          *
 -- BD: intercard                                                                                                                         *
--*****************************************************************************************************************************************
	
 
-- VARIABLES PARA EL CONTROL DE ERRORES

	DEFINE  vsql_err             INTEGER;
	DEFINE  visam_err           INTEGER;
	DEFINE  verror_info          VARCHAR(80);
	DEFINE  p_cod_ret            VARCHAR(6);
	DEFINE  p_mensaje            VARCHAR(80);
	
-- VARIABLES DE OPERACIÓN(FECHAS)

	DEFINE vultimo_dia_mes 		DATE;
	DEFINE vprimer_dia_mes 		DATE;
	DEFINE vfecha_hoy              DATE;
	DEFINE vsql						CHAR(1000);					

    --SET DEBUG FILE TO "/informix/Esmeralda/SpSolicitudes/trace.out";
    --TRACE ON;	

BEGIN
		ON EXCEPTION SET vsql_err, visam_err, verror_info
			LET p_cod_ret    = vsql_err;
			LET p_mensaje  = verror_info;
			
			RETURN 	p_cod_ret,p_mensaje;
			
		END EXCEPTION; 
		
		
		-- OBTENER FECHA ACTUAL
		SET ISOLATION TO DIRTY READ;
		SELECT fecha_hoy INTO vfecha_hoy FROM  bdinteg:si_fechas;	

		-- OBTENER EL ULTIMO DÍA DEL MES ANTERIOR A LA EJECUCIÓN
		LET vultimo_dia_mes = extend(extend(vfecha_hoy -0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY;
		-- OBTENER EL PRIMER DÍA DEL MES ANTERIOR A LA EJECUCIÓN
		LET vprimer_dia_mes = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);
		                                      
		LET vsql	=	'';
		LET vsql	=	'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 4; UNLOAD TO /resplogifx/rpt_solicitudes_reposiciones_'||SUBSTR(vfecha_hoy,4,2)||SUBSTR(vfecha_hoy,1,2)||SUBSTR(vfecha_hoy,7,4)||'.unl' ||
		'	SELECT ' ||
		'	DATE(fecha_generacion) as fecha, ' ||
		'	clave_sucursal as sucursal, ' ||
		'	SUBSTRING(numtarjeta from 1 for 6) as bin, ' ||
		'	SUBSTRING(numtarjeta from 7 for 2) as subbin, ' ||
		'	numlote as lote, numguia as guia, ' ||
		'	tipomaquila, id_diseno as iddiseno, count(*) ' ||
		'FROM intercard:detalle_maquila ' ||
		'WHERE ' ||
		'	fecha_generacion::DATE >= ''"'||vprimer_dia_mes||'"'' AND '||                     
		'	fecha_generacion::DATE <= ''"'||vultimo_dia_mes||'"'' AND '||                                       
		'	tipomaquila in (''"'||'E'||'"'',''"'||'N'||'"'',''"'||'S'||'"'') AND' ||
		'	SUBSTRING(numtarjeta from 1 for 6) = ''"'||'416916'||'"'' AND '||
		'	SUBSTRING(numtarjeta from 7 for 2) in(''"'||'03'||'"'',''"'||'05'||'"'',''"'||'05'||'"'')' ||
		'GROUP BY 1,2,3,4,5,6,7,8 ' ||
		'ORDER BY 1,2,3,4,5,6,7,8; ">/resplogifx/rpt_solicitudes_reposiciones_base.sql ';
				           
		SYSTEM vsql;
		LET vsql	=	'';
		LET vsql	=	'dbaccess intercard /resplogifx/rpt_solicitudes_reposiciones_base.sql';
		SYSTEM vsql;
		LET vsql	=	'rm /resplogifx/rpt_solicitudes_reposiciones_base.sql';
		SYSTEM vsql;	
		
		
		LET	p_cod_ret 	=	'00000';
		LET p_mensaje	=	'Reporte generado exitosamente';
	    RETURN p_cod_ret,p_mensaje; 
END;  
END PROCEDURE;