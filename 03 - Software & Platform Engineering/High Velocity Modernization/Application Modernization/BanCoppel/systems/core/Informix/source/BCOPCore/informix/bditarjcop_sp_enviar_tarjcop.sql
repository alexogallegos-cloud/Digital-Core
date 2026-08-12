CREATE PROCEDURE "informix".sp_enviar_tarjcop (pEmpresa CHAR(3))

RETURNING CHAR(5);

--Declaracion de Variables.
DEFINE cCodRet CHAR(5);
DEFINE visqlerr INTEGER;
DEFINE dFechaHoy date;
	DEFINE vsRepositorio CHAR (100);
	DEFINE vsArchTemporal CHAR (15);
	DEFINE vsNomArchivo CHAR (30);
	DEFINE vsSQL CHAR (1500);
	DEFINE vsSQL1 CHAR (200);
	DEFINE vsSQL2 CHAR (900);
	DEFINE vsSQL3 CHAR (200);
    DEFINE vi_valor CHAR (50);
    DEFINE pdrepositorio CHAR (50);

--Asignacion de Variables.
	LET cCodRet = "";
	LET dFechaHoy = "";
	LET vsRepositorio = '';
	LET vsArchTemporal = '';
	LET vsNomArchivo = '';
	LET vsSQL = '';
	LET vsSQL1 = '';
	LET vsSQL2 = '';
	LET vsSQL3 = '';
	LET visqlerr = 0;

--SET DEBUG FILE TO "/informix/sp_enviar_tarjcop.out";	
--TRACE ON;													

BEGIN
	ON EXCEPTION SET visqlerr --Control de errores.
			RETURN visqlerr;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;								
	SET LOCK MODE TO WAIT 3;
	
	 SELECT {+index (si_param 194_429)}  
							   valor
	 INTO vi_valor
	 FROM bdinteg:si_param
	 WHERE empresa = '001'
	 AND cod_param = '348';
						
	 IF NOT EXISTS (SELECT {+index (si_param 194_429)} valor
										 FROM bdinteg:si_param
										WHERE empresa = '001' AND cod_param = '348')
     THEN
		LET cCodRet = "00002";   --No Existe ruta de deposito
		RETURN cCodRet;
	 END IF;
	 
	 LET pdrepositorio = vi_valor;
	 
	
	SELECT date(fecha_hoy)
	INTO dFechaHoy
	FROM bdinteg:"informix".si_fechas
	WHERE empresa = pEmpresa;
	
	LET vsArchTemporal = 'temporal.txt';
	LET vsNomArchivo = 'tarj_cop_' || SUBSTRING (dFechaHoy FROM 9 FOR 2) || SUBSTRING (dFechaHoy FROM 1 FOR 2) || SUBSTRING (dFechaHoy FROM 4 FOR 2) || '.txt' ;
		--GENERA EL ARCHIVO DE INTERCAMBIO
	LET vsSQL1 = 'echo "UNLOAD TO ' || TRIM(pdrepositorio) || '/' || TRIM(vsArchTemporal) || ' DELIMITER ' || '''?''';
							
							
	LET vsSQL2 = "SELECT NVL(TRIM(cvesucursal), '') ||'|'|| NVL(tipotarjeta, '')||'|'|| NVL(numenvio, '') ||'|'|| NVL(fechasurt, '')||'|'|| NVL(cantidadrec, '') ||'|'|| "
	|| "NVL(rangoini, '') ||'|'|| NVL(rangofin, '') ||'|'|| NVL(fecharec, '') "
	|| "FROM bditarjcop:enviostarcop "
	|| "WHERE date(fecharec) = '" || dFechaHoy || "' ;";
	
	LET vsSQL3 = ' " > '|| TRIM(pdrepositorio) || '/control_reporte.sql';
	LET vsSQL1 = TRIM(vsSQL1);
	LET vsSQL2 = TRIM(vsSQL2);
	LET vsSQL3 = TRIM(vsSQL3);
	LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;
	LET vsSQL = TRIM(vsSQL); 
	
	IF ( vsSQL <> '' ) THEN
		SYSTEM vsSQL ;
		--Permiso para la creacion de archivo.
		LET vsSQL = '' ;
		LET vsSQL = 'chmod 666 ' || TRIM(pdrepositorio) || '/control_reporte.sql' ;
		LET vsSQL = '' ;
		LET vsSQL = 'dbaccess bditarjcop ' || TRIM(pdrepositorio) || '/control_reporte.sql' ;
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
		--LET vsMensajeRetorno = 'GENERACION DEL ARCHIVO ' || vsNomArchivo || ' FINALIZADA';
		
		LET cCodRet = '00000';
		RETURN cCodRet;

							
	END IF;
	
		
	
RETURN cCodRet;
END
END PROCEDURE
;