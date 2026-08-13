CREATE PROCEDURE "informix".sp_tarjeta_pendiente_web(cEmpresa CHAR(3), cSucursal CHAR(4), cNumeroTarjeta CHAR(9))

RETURNING CHAR(5) AS CODRET;

DEFINE cCodRetorno CHAR(5);
DEFINE iSqlErr     SMALLINT;

LET cCodRetorno = '00000';
LET iSqlErr     = 0;

--SET DEBUG FILE TO '/tmp/sp_tarjeta_pendiente.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRetorno = iSqlErr;
			RETURN cCodRetorno;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF(SELECT count(empresa) FROM bditarjcop:"informix".inventariotarcop WHERE empresa = cEmpresa) > 0 THEN
		--Verifica si la clave de sucursal proporcionada cuenta con un inventario de tarjetas.
		IF(SELECT count(cvesucursal) FROM bditarjcop:"informix".inventariotarcop WHERE empresa = cEmpresa AND cvesucursal = cSucursal) > 0 THEN
			--Si el tipo de tarjeta es numerada.
			--Verifica si existe el numero de tarjeta indicado.
			IF(SELECT count(numtarjeta) FROM bditarjcop:"informix".tarjetasnumtarcop 
				WHERE empresa = cEmpresa AND cvesucursal = cSucursal AND numtarjeta = cNumeroTarjeta) > 0 THEN
				--Verifica que el numero de tarjeta proporcionado se encuentre con estatus "P".
				IF(SELECT count(numtarjeta) FROM bditarjcop:"informix".tarjetasnumtarcop 
					WHERE empresa = cEmpresa AND cvesucursal = cSucursal AND numtarjeta = cNumeroTarjeta AND estatustarjeta = 'P') > 0 THEN
					--Marca como disponible el numero de tarjeta indicado.
					UPDATE bditarjcop:"informix".tarjetasnumtarcop SET estatustarjeta = 'N' 
					WHERE empresa = cEmpresa 
					AND cvesucursal = cSucursal
					AND numtarjeta = cNumeroTarjeta;
					--La operacion se realizo de manera exitosa.
					LET cCodRetorno = '00000';
				ELIF(SELECT count(numtarjeta) FROM bditarjcop:"informix".tarjetasnumtarcop 
					WHERE empresa = cEmpresa AND cvesucursal = cSucursal AND numtarjeta = cNumeroTarjeta AND estatustarjeta = 'E') > 0 THEN
					--Numero de tarjeta marcada como extraviada anteriormente.
					LET cCodRetorno = '00404';
				ELIF(SELECT count(numtarjeta) FROM bditarjcop:"informix".tarjetasnumtarcop 
					WHERE empresa = cEmpresa AND cvesucursal = cSucursal AND numtarjeta = cNumeroTarjeta AND estatustarjeta = 'A') > 0 THEN
					--Numero de tarjeta asignada anteriormente.
					LET cCodRetorno = '00405';
				END IF;
			ELSE
				--No se localizo el numero de tarjeta proporcionado.
				LET cCodRetorno = '00403';
			END IF;
		ELSE
		END IF;
	ELSE
	END IF;
	RETURN cCodRetorno;
END;
END PROCEDURE
DOCUMENT
'AUTOR: VICTOR HUGO NUÃEZ',
'Proyecto: Alta Unica',
'Descripcion: Establece en pendiente la tarjeta al abandonar la asignacion de tarjeta.',
'BD:bditarjcop',
'Fecha: 05/12/2012',
'Version: 20121205.1614',
'BD: bditarjcop';

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