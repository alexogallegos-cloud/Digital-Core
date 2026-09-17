CREATE PROCEDURE "informix".sp_genera_reporte_sms()
RETURNING 	VARCHAR(40) AS cMensaje, 
			VARCHAR(5) AS cCodRet;
		  
/*DEFINICION DE VARIABLES */
DEFINE  cSucursal         VARCHAR(10);
DEFINE  cCiudad           VARCHAR(60,1);
DEFINE  cNomCiudad		  VARCHAR(60,1);
DEFINE  cEstado           VARCHAR(30);
DEFINE  cNomEstado		  VARCHAR(30);
DEFINE  cSaldo            VARCHAR(10);
DEFINE  cPago             VARCHAR(10);
DEFINE  cInversion        VARCHAR(10);
DEFINE  cSolicitud		  VARCHAR(10);
DEFINE  cCelular		  VARCHAR(10);

DEFINE  cPrestamoMonto		INTEGER;
DEFINE  cPrestamoDisponible	INTEGER;
DEFINE  cPrestamoConsulta 	INTEGER;
DEFINE  cFlexibleMonto		INTEGER;
DEFINE  cFlexibleDisponible	INTEGER;
DEFINE  cFlexibleConsulta	INTEGER;
DEFINE  cIncremento			INTEGER;
DEFINE  cAnticipo			INTEGER;
DEFINE  cPagosFijosFolio	INTEGER;
DEFINE  cPagosFijosSaldo	INTEGER;

DEFINE  cDiferir 			VARCHAR(10);
DEFINE  cRobo	 			VARCHAR(10);
DEFINE  cExtravio 			VARCHAR(10);
DEFINE  cConfirma 			VARCHAR(10);
DEFINE  cAclaracion 		VARCHAR(10);

--DEFINE  cTotal			  VARCHAR(25);
DEFINE  cTotal			  INTEGER;
DEFINE 	cPais			  VARCHAR(4);
DEFINE 	cCodRet      	  VARCHAR(5);
DEFINE 	pFecha            DATE;
DEFINE 	vsDia             VARCHAR(2);
DEFINE 	vsMes 		      VARCHAR(2);
DEFINE 	vsAnio 		      VARCHAR(2);
DEFINE 	vsNombreArchivo   VARCHAR(50);
DEFINE  cSQL			  VARCHAR(250);
DEFINE  cSQL1			  LVARCHAR(500);
DEFINE  iCont			  VARCHAR(5);	
DEFINE  iSqlErr			  INTEGER;
DEFINE  cMensaje		  VARCHAR(40);

DEFINE  vFecha_Inicial 	DATE;
DEFINE  vFecha_Final 	DATE;
DEFINE  vFecha_Actual	DATE;
DEFINE  vMesAnterior   DATE;

DEFINE vDia_Anterior  DATETIME YEAR TO FRACTION;
DEFINE vDia_Actual  DATETIME YEAR TO FRACTION;

/*FIN DE DEFINICION DE VARIABLES*/
LET cCodRet   = 0;
LET cSucursal = '';
LET cCiudad   = '';
LET cEstado   = '';
LET cSaldo    = '';
LET cPago     = '';
LET cInversion = '';
LET cSolicitud = '';
LET cCelular   = '';

LET cPrestamoMonto      = '';
LET cPrestamoDisponible = '';
LET cPrestamoConsulta   = '';
LET cFlexibleMonto      = '';
LET cFlexibleDisponible = '';
LET cFlexibleConsulta   = '';
LET cIncremento      = '';
LET cAnticipo        = '';
LET cPagosFijosFolio = '';
LET cPagosFijosSaldo = '';

LET cDiferir 	= '';
LET cRobo 		= '';
LET cExtravio 	= '';
LET cConfirma 	= '';
LET cAclaracion = '';
				
LET cTotal     = '';
LET pFecha     = TODAY;
LET vsDia      = '';
LET vsMes      = '';
LET vsAnio     = '';
LET vsNombreArchivo = '';
LET cPais 	   = '';
LET cNomCiudad = '';
LET cNomEstado = '';
LET cSQL	   = '';
LET cSQL1	   = '';	  
LET iCont	   = '0';	  
LET cMensaje   = '';
LET iSqlErr    = 0;

--LET vPrimer_Dia_Mes = extend(extend(TODAY - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY); 
--LET vUltimo_Dia_Mes = extend(extend(vfecha_hoy - 0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);

LET vFecha_Actual = TODAY;

LET vDia_Anterior =  EXTEND(TODAY-1); 
LET vDia_Actual =  EXTEND(TODAY); 

/*FIN DE INICIALIZACION*/

---SET DEBUG FILE TO "/informix/ragomez/reporte_sms/sp_genera_reporte_sms.out";
---TRACE ON;

BEGIN
	
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN -- manejador de errores
			LET cCodRet = iSqlErr;
			LET cMensaje  = 'ERROR AL GENERAR REPORTE';
			
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF DAY(vFecha_Actual) <= 15 THEN
		LET vMesAnterior = vFecha_Actual - 1 UNITS MONTH;
		LET vFecha_Inicial = MDY(MONTH(vMesAnterior), 16, YEAR(vMesAnterior));
		LET vFecha_Final = LAST_DAY(vMesAnterior);
	ELSE
		LET vFecha_Inicial = MDY(MONTH(vFecha_Actual), 1, YEAR(vFecha_Actual));
		LET vFecha_Final = MDY(MONTH(vFecha_Actual), 15, YEAR(vFecha_Actual));
	END IF;
	
	TRUNCATE bdimnsj:"informix".mnsjr_reporte_sms;
	
	--Nombre del archivo
	LET vsNombreArchivo = '/RESPALDOSNEW/REPORTE_SMS'||'_'||YEAR(TODAY)||LPAD(MONTH(TODAY),2,'0')||LPAD(DAY(TODAY),2,'0')||'.csv';
						
	INSERT INTO bdimnsj:"informix".mnsjr_reporte_sms(sucursal, ciudad, estado, saldo, pago, inversion, solicitud, celular, 
			prestamo_monto, prestamo_disponible, prestamo_consulta, flexible_monto, flexible_disponible, flexible_consulta, 
			incremento, anticipo, pagosfijos_folio, pagosfijos_saldo, diferir, robo, extravio, confirma, aclaracion, total, fechainsert)
		VALUES('Sucursal', 'Ciudad', 'Estado', 'Saldo', 'Pago', 'Inversion', 'Solicitud', 'Celular', 
				'Prestamo #', 'Prestamo Disponible', 'Prestamo Consulta', 'Flexible #', 'Flexible Disponible', 'Flexible Consulta', 
				'Incremento', 'Anticipo', 'PagosFijos', 'PagosFijos Saldo', 'Diferir', 'Robo', 'Extravio', 'Confirma', 'Aclaracion', 'Total de SMS Solicitados', CURRENT);
	
	SET LOCK MODE TO WAIT 3;
      SELECT {+AVOID_FULL(mnsjr_bitacora_sms)} * FROM mnsjr_bitacora_sms WHERE fechasolicitud >= vDia_Anterior AND fechasolicitud < vDia_Actual AND sucursal <> ''
	  INTO TEMP temp_mnsjr_bit_sms WITH NO LOG; 
      CREATE INDEX temp_mnsjr_bit_sms_idx ON temp_mnsjr_bit_sms (sucursal,fechasolicitud) using btree ;
      UPDATE STATISTICS MEDIUM FOR TABLE temp_mnsjr_bit_sms; 
	FOREACH	WITH HOLD
		
		SELECT
		{+INDEX(mnsjr_bitacora_sms,idx01_sucur)}
		a.sucursal,
		SUM(CASE WHEN a.param1 = 'SALDO' THEN 1 ELSE 0 END) AS saldo,
		SUM(CASE WHEN a.param1 = 'PAGO' THEN 1 ELSE 0 END) AS pago,
		SUM(CASE WHEN a.param1 = 'INVERSION' THEN 1 ELSE 0 END) AS inversion,
		SUM(CASE WHEN a.param1 = 'CELULAR' THEN 1 ELSE 0 END) AS celular,
		SUM(CASE WHEN a.param1 = 'SOLICITUD' THEN 1 ELSE 0 END) AS solicitud,
		
		SUM(CASE WHEN a.param1 = 'PRESTAMO' THEN 1 ELSE 0 END) AS prestamo_monto,
		SUM(CASE WHEN a.param1 = 'PRESTAMO' AND param2 = 'DISPONIBLE' THEN 1 ELSE 0 END) AS prestamo_disponible,
		SUM(CASE WHEN a.param1 = 'PRESTAMO' AND param2 = 'CONSULTA' THEN 1 ELSE 0 END) AS prestamo_consulta,
		
		SUM(CASE WHEN a.param1 = 'FLEXIBLE' THEN 1 ELSE 0 END) AS flexible_monto,
		SUM(CASE WHEN a.param1 = 'FLEXIBLE' AND param2 = 'DISPONIBLE' THEN 1 ELSE 0 END) AS flexible_disponible,
		SUM(CASE WHEN a.param1 = 'FLEXIBLE' AND param2 = 'CONSULTA' THEN 1 ELSE 0 END) AS flexible_consulta,
		
		SUM(CASE WHEN a.param1 = 'INCREMENTO' THEN 1 ELSE 0 END) AS incremento,
		SUM(CASE WHEN a.param1 = 'ANTICIPO' THEN 1 ELSE 0 END) AS anticipo,
		
		SUM(CASE WHEN a.param1 = 'PAGOSFIJOS' THEN 1 ELSE 0 END) AS pagosfijos_folio,
		SUM(CASE WHEN a.param1 = 'PAGOSFIJOS' AND param2 = 'SALDO' THEN 1 ELSE 0 END) AS pagosfijos_saldo,
		
		SUM(CASE WHEN a.param1 = 'DIFERIR' THEN 1 ELSE 0 END) AS diferir,
		
		SUM(CASE WHEN a.param1 = 'ROBO' THEN 1 ELSE 0 END) AS robo,
		SUM(CASE WHEN a.param1 = 'EXTRAVIO' THEN 1 ELSE 0 END) AS extravio,
		
		SUM(CASE WHEN a.param1 = 'CONFIRMA' THEN 1 ELSE 0 END) AS confirma,
		SUM(CASE WHEN a.param1 = 'ACLARACION' THEN 1 ELSE 0 END) AS aclaracion
		
		INTO cSucursal, cSaldo, cPago, cInversion, cCelular, cSolicitud, 
			cPrestamoMonto, cPrestamoDisponible, cPrestamoConsulta, 
			cFlexibleMonto, cFlexibleDisponible, cFlexibleConsulta, 
			cIncremento, cAnticipo, cPagosFijosFolio, cPagosFijosSaldo , cDiferir, cRobo, cExtravio, cConfirma, cAclaracion --, cTotal
		FROM temp_mnsjr_bit_sms a JOIN bdinteg:si_sucursales b ON a.sucursal = b.sucursal 
		---FROM mnsjr_bitacora_sms a JOIN bdinteg:si_sucursales b ON a.sucursal = b.sucursal 
		--WHERE a.fechasolicitud BETWEEN vFecha_Inicial AND vFecha_Final -- AND a.sucursal <> '' --IS NOT NULL
		--WHERE a.fechasolicitud::date = vFecha_Actual -- AND a.sucursal <> '' --IS NOT NULL
		WHERE a.fechasolicitud >= vDia_Anterior AND a.fechasolicitud < vDia_Actual AND a.sucursal <> ''
		GROUP BY a.sucursal
		
		/*SELECT pais, estado, ciudad INTO cPais, cEstado, cCiudad 
		FROM bdinteg:si_sucursales 
		WHERE sucursal = cSucursal;*/
   
    SELECT cve_pais, cve_estado, cve_ciudad INTO cPais, cEstado, cCiudad 
		FROM bdinteg:si_ptf 
		WHERE id_ptf = cSucursal and tipo = 'S';
		
		SELECT nombre INTO cNomCiudad 
		FROM bdinteg:si_ciudades 
		WHERE pais = cPais AND estado = cEstado AND ciudad = cCiudad;
		
		SELECT nombre INTO cNomEstado 
		FROM bdinteg:si_estados 
		WHERE pais = cPais AND estado = cEstado;
		
		LET cPrestamoMonto = cPrestamoMonto - cPrestamoDisponible - cPrestamoConsulta;
		LET cFlexibleMonto = cFlexibleMonto - cFlexibleDisponible - cFlexibleConsulta;
		
		LET cPagosFijosFolio = cPagosFijosFolio - cPagosFijosSaldo;
		
		LET cTotal = cSaldo + cPago + cInversion + cCelular + cSolicitud + cPrestamoMonto + cPrestamoDisponible + cPrestamoConsulta + cDiferir + cRobo + cExtravio +cConfirma + cAclaracion;
		LET cTotal = cTotal + cFlexibleMonto + cFlexibleDisponible + cFlexibleConsulta + cIncremento + cAnticipo + cPagosFijosFolio + cPagosFijosSaldo;
		
		INSERT INTO bdimnsj:"informix".mnsjr_reporte_sms(sucursal, ciudad, estado, saldo, pago, inversion, solicitud, celular, 
			prestamo_monto, prestamo_disponible, prestamo_consulta, flexible_monto, flexible_disponible, flexible_consulta, 
			incremento, anticipo, pagosfijos_folio, pagosfijos_saldo, diferir, robo, extravio, confirma, aclaracion, total, fechainsert)
		VALUES(cSucursal, cNomCiudad, cNomEstado, cSaldo, cPago, cInversion, cSolicitud, cCelular, 
				cPrestamoMonto, cPrestamoDisponible, cPrestamoConsulta, cFlexibleMonto, cFlexibleDisponible, cFlexibleConsulta, 
				cIncremento, cAnticipo, cPagosFijosFolio, cPagosFijosSaldo, cDiferir, cRobo, cExtravio, cConfirma, cAclaracion, cTotal, CURRENT);
		
		LET iCont=iCont+1;
		
	END FOREACH; 
		
	LET cSQL1 = 'echo "UNLOAD TO '||TRIM(vsNombreArchivo)||' DELIMITER '','' SELECT sucursal, ciudad, estado, saldo, pago, inversion, solicitud, celular, prestamo_monto, prestamo_disponible, prestamo_consulta, flexible_monto, flexible_disponible, flexible_consulta, incremento, anticipo, pagosfijos_folio, pagosfijos_saldo, diferir, robo, extravio, confirma, aclaracion, total from bdimnsj:"informix".mnsjr_reporte_sms " > /RESPALDOSNEW/Ejecuta_reporte_sms.sql';
	SYSTEM cSQL1;

	LET cSQL='dbaccess bdimnsj /RESPALDOSNEW/Ejecuta_reporte_sms.sql';
	SYSTEM cSQL;
	
	IF NVL(iCont,'0') > 0 THEN
		
		LET cMensaje  = 'REPORTE GENERADO CORRECTAMENTE';
		LET cCodRet = '00000';
	ELSE
		
		LET cMensaje  = 'NO SE ENCONTRARON REGISTROS';
		LET cCodRet = '00001';
	END IF;		
	RETURN cMensaje, cCodRet;
END;
END PROCEDURE;