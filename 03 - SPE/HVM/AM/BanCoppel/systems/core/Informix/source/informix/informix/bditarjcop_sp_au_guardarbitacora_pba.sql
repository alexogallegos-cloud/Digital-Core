CREATE PROCEDURE "informix".sp_au_guardarbitacora_pba(psEmpleado VARCHAR(8), psActividad VARCHAR(20), psNomArchivo VARCHAR(20), psCodRetorno VARCHAR(5))

RETURNING VARCHAR(5) AS Cod_Retorno;

--****************************************************************************************************
-- DESCRIPCION: GUARDA REGISTRO EN BITACORA
-- AUTOR : Casanova Edeza Hector Juan
-- FECHA : 26/12/2011
-- BD: bdiTarCop
-- SISTEMA : Inventario de Tarjetas Alta Unica.
--****************************************************************************************************

/*  DEFINICION DE VARIABLES */
DEFINE vsRutaAIX VARCHAR(90);
DEFINE vsRutaWIN VARCHAR(90);

DEFINE viSqlError INTEGER;

/* INICIALIZACION DE VARIABLES */
LET vsRutaAIX = '';
LET vsRutaWIN = '';

LET viSqlError = 0;

BEGIN

  ON EXCEPTION SET viSqlError    --cacha el error en caso de que exista y regresa un valor predeterminado

		RETURN viSqlError;

    END EXCEPTION;

	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	--GUARDA REGISTRO EN BITACORA
	INSERT INTO bdiTarjCop:"informix".BitacoraTarCop 
	(
		Empleado, 
		Fecha, 
		Actividad, 
		NomArchivo, 
		CodRetorno
	) 
	VALUES 
	(
		psEmpleado, 
		CURRENT, 
		psActividad,
		psNomArchivo, 
		psCodRetorno
	);
	
	
	
	RETURN '00000';

END

END PROCEDURE
DOCUMENT
'AUTOR: Casanova Edeza Hector Juan',
'Proyecto: Alta Única',
'Descripcion: GUARDA REGISTRO EN BITACORA.',
'Fecha: 2011/12/26',
'Version: 20111226.1554',
'BD: bditarjcop';

CREATE PROCEDURE "informix".sp_au_validanomarchivo_pba(psEmpresa VARCHAR(3), psNomArchivo VARCHAR(15) )

RETURNING VARCHAR(5) AS CodRetorno;

--****************************************************************************************************
-- DESCRIPCION: VALIDA EL NOMBRE DE ARCHIVO DE ENVIOS DE TARJETAS COPPEL
-- AUTOR : Casanova Edeza Hector Juan
-- FECHA : 23/12/2011
-- BD: bdiTarCop
-- SISTEMA : Inventario de Tarjetas Alta Unica.
--****************************************************************************************************

/*  DEFINICION DE VARIABLES */

DEFINE vsFlagSoloNumeros VARCHAR (1);
DEFINE vsCodRetorno VARCHAR (5);

DEFINE viSqlError INTEGER;

/* INICIALIZACION DE VARIABLES */
LET vsFlagSoloNumeros = '';
LET vsCodRetorno = '00000';

LET viSqlError = 0;

BEGIN

  ON EXCEPTION SET viSqlError    --cacha el error en caso de que exista y regresa un valor predeterminado

		RETURN viSqlError;

    END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/conciliacion/cargarsurt.txt";
	--TRACE ON;
    --set explain on;
	
	--S2011100301.dat
	
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	EXECUTE PROCEDURE BdiTarjCop:"informix".sp_EsNumerico (SUBSTR(psNomArchivo, 2,10)) INTO vsFlagSoloNumeros;


	IF (LENGTH ( TRIM(psNomArchivo)) <> 15 )  THEN --EL NOMBRE DEL ARCHIVO NO POSEE LA EXTENCION CORRESPONDIENTE
		LET vsCodRetorno = '00001';
		
	ELIF ((SUBSTRING ( UPPER( TRIM(psNomArchivo)) FROM 1 FOR 1) <> 'S') AND (SUBSTRING ( UPPER( TRIM(psNomArchivo)) FROM 1 FOR 1) <> 'G')) THEN -- NO ES ARCHIVO DE SURTIDO
		LET vsCodRetorno = '00002';
		
	ELIF ( vsFlagSoloNumeros <> 'V' ) THEN --VALIDA QUE LA FECHA DEL ARCHIVO CONTENGA UNICAMENTE NUMEROS
		LET vsCodRetorno = '00003';
	
	ELIF ((SUBSTR(psNomArchivo, 2,4)::INTEGER < 1900) OR (SUBSTR(psNomArchivo, 2,4)::INTEGER > 2900)) THEN --SE VALIDA QUE EL ANO SEA CORRECTO
		LET vsCodRetorno = '00004';	
	
	ELIF ((SUBSTR(psNomArchivo, 6,2)::INTEGER < 1) OR (SUBSTR(psNomArchivo, 6,2)::INTEGER > 12)) THEN --SE VALIDA QUE EL MES SEA CORRECTO
		LET vsCodRetorno = '00005';	
	
	ELIF  ((SUBSTR(psNomArchivo, 8,2)::INTEGER < 1) OR (SUBSTR(psNomArchivo, 8,2)::INTEGER > 31)) THEN --SE VALIDA QUE EL DIA SEA CORRECTO
		LET vsCodRetorno = '00006';

	ELIF (SUBSTRING ( UPPER( TRIM(psNomArchivo)) FROM 12 FOR 4) <> '.DAT') THEN -- NO ES ARCHIVO DE EXTENCION DAT
		LET vsCodRetorno = '00007';
	
	ELIF NOT EXISTS (SELECT Empresa FROM BdiTarjCop:"informix".InventarioTarCop WHERE Empresa = psEmpresa ) THEN  --NO EXISTE LA EMPRESA PROPORCIONADA
		LET vsCodRetorno = '00008';	
		
	ELIF EXISTS ( SELECT NomArchivo FROM BdiTarjCop:"informix".BitacoraTarCop WHERE NomArchivo = psNomArchivo AND CodRetorno = '00000') THEN --CHECA QUE EL ARCHIVO NO FUE PROCESADO ANTERIORMENTE.
		LET vsCodRetorno = '00009';
		
	ELSE --OK
		LET vsCodRetorno = '00000';
		
	END IF ;

	RETURN vsCodRetorno;

END

END PROCEDURE
DOCUMENT
'AUTOR: Casanova Edeza Hector Juan',
'Proyecto: Alta Única',
'Descripcion: VALIDA EL NOMBRE DE ARCHIVO DE ENVIOS DE TARJETAS COPPEL.',
'Fecha: 2011/12/23',
'Version: 20111223.1700',
'BD: bditarjcop';

CREATE PROCEDURE "informix".sp_reversatarjetascoppel(
cEmpresa CHAR(3),
cSucursal CHAR(4),
iNumEnvio INTEGER,
cTarjetaIni CHAR(16),
cTarjetaFin CHAR(16),
cTipoTarjeta CHAR(1)
)

RETURNING CHAR(5) AS cCodRet;


DEFINE iCantidadRec INTEGER;
DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE iCantRango INTEGER;
DEFINE dFechaActCU DATETIME YEAR TO FRACTION(1);
DEFINE dFechaActual DATETIME YEAR TO FRACTION(1); 


DEFINE cCvesucursal CHAR(4);
DEFINE cEnvioDisponible CHAR(1);
DEFINE iExistencia	INTEGER;
DEFINE cRangoIni	CHAR(16);
DEFINE cRangoFin	CHAR(16);
DEFINE iConsumo		INTEGER;

LET iCantidadRec = 0;
LET iSqlErr = 0;
LET cCodRet = '';
LET iCantRango = 0;
LET dFechaActCU = CURRENT;
LET dFechaActual = CURRENT;

LET cCvesucursal = '';
LET cEnvioDisponible = '';
LET iExistencia = 0;
LET cRangoIni = '';
LET cRangoFin = '';
LET iConsumo = 0;



BEGIN

ON EXCEPTION SET iSqlErr   --cacha el error en caso de que exista y regresa un valor predeterminado
    IF iSqlErr <> 0 THEN
	LET cCodRet = iSqlErr;
	RETURN cCodRet;
	END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/home/sysifx/Alexis/144/sp_reversatarjetascoppel.out";
--TRACE ON;


SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

--Obtiene fecha de activacion de sucursal que recibira lote
SELECT LIMIT 1 fechaactcu INTO dFechaActCU FROM bditarjcop:"informix".sucursalescajaunica WHERE empresa = cEmpresa AND cvesucursal = cSucursal;
--Obtiene fecha actual
SELECT LIMIT 1 CURRENT INTO dFechaActual FROM bditarjcop:"informix".sucursalescajaunica;
--Verifica que la fecha de activacion de sucursal sea menor o igual al a fecha actual.
IF(dFechaActCU <= dFechaActual)THEN
	--Verifica si existe la empresa proporcionada.
	SELECT LIMIT 1 empresa INTO cEmpresa FROM bditarjcop:"informix".inventariotarcop WHERE empresa = cEmpresa;
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				--La empresa proporcionada no existe.
				LET cCodRet = '00101';
	ELSE
		--Verifica si la clave de sucursal proporcionada cuenta con un inventario de tarjetas.
		SELECT LIMIT 1 cvesucursal INTO cCvesucursal FROM bditarjcop:"informix".inventariotarcop WHERE cvesucursal = cSucursal;
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				--La sucursal no cuenta con un inventario de tarjetas.
				LET cCodRet = '00102';
		ELSE
			--Verifica que exista un inventario correpondiente a la sucursal y al tipo de tarjeta proporcionados por el sistema Caja Ãnica de Sucursal.
			SELECT LIMIT 1 empresa, cvesucursal, consumo, existencia, tipotarjeta 
					INTO cEmpresa, cCvesucursal, iConsumo, iExistencia, cTipoTarjeta 
					FROM bditarjcop:"informix".inventariotarcop
					WHERE empresa = cEmpresa AND cvesucursal = cSucursal AND tipotarjeta = cTipoTarjeta;
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
					--No existe un inventario correpondiente a la sucursal y al tipo de tarjeta
					LET cCodRet = '00103';
			ELSE	
				LET iCantRango = (cTarjetaFin - cTarjetaIni) + 1;
				--Valida que la cantidad del rango de tarjetas corresponda con la cantidad de tarjetas recibidas.
				SELECT LIMIT 1 cantidadrec INTO iCantidadRec FROM bditarjcop:"informix".EnviosTarCop 
				WHERE cvesucursal = cSucursal AND numenvio = iNumEnvio AND rangoini = cTarjetaIni 
				AND rangofin = cTarjetaFin;
				
				IF(iCantRango = iCantidadRec)THEN
					--Verifica que el envio corresponda a la sucursal mediante la clave de la empresa, la clave de la sucursal, el numero del envio y tipo de tarjeta.
					SELECT LIMIT 1 empresa, cvesucursal, tipotarjeta, numenvio, cantidadrec, rangoini, rangofin 
					INTO cEmpresa, cCvesucursal, cTipoTarjeta, iNumEnvio, iCantidadRec, cRangoIni, cRangoFin
					FROM bditarjcop:"informix".EnviosTarCop WHERE empresa = cEmpresa AND cvesucursal = cSucursal
					AND tipotarjeta = cTipoTarjeta AND numenvio = iNumEnvio AND cantidadrec = iCantidadRec 
					AND rangoini = cTarjetaIni AND rangofin = cTarjetaFin;
					
					IF dbinfo("sqlca.sqlerrd2") = 0 THEN
						--El envio no corresponde a la sucursal y por lo tanto no puede ser aÃ±adido al inventario de esta.
						LET cCodRet = '00105';
					ELSE	
						--Verifica que el envio no se encuentre marcado como "Activo".
						SELECT LIMIT 1 EnvioDisponible INTO cEnvioDisponible FROM bditarjcop:"informix".EnviosTarCop WHERE cvesucursal = cSucursal AND numenvio = iNumEnvio AND EnvioDisponible = 'A' AND tipotarjeta = cTipoTarjeta AND rangoini = cTarjetaIni AND rangofin = cTarjetaFin;
						IF dbinfo("sqlca.sqlerrd2") = 0 THEN
							--El envio ya fue registrado anteriormente.
							LET cCodRet = '00106';
						ELSE	
							SELECT LIMIT 1 cantidadrec INTO iCantidadRec FROM bditarjcop:"informix".EnviosTarCop WHERE cvesucursal = cSucursal AND numenvio = iNumEnvio AND tipotarjeta = cTipoTarjeta AND rangoini = cTarjetaIni AND rangofin = cTarjetaFin;
							UPDATE bditarjcop:"informix".InventarioTarCop SET existencia = existencia - iCantidadRec WHERE tipotarjeta = cTipoTarjeta AND empresa = cEmpresa
							AND cvesucursal = cSucursal;
							UPDATE bditarjcop:"informix".EnviosTarCop SET EnvioDisponible = "P", FechaRec = CURRENT, empleadorec = "" WHERE numenvio = iNumEnvio
							AND tipotarjeta = cTipoTarjeta AND empresa = cEmpresa AND cvesucursal = cSucursal AND rangoini = cTarjetaIni AND rangofin = cTarjetaFin;
							--Exito de la recepcion del envio
							LET cCodRet = '00000';
						END IF;
					END IF;
				ELSE
					--La cantidad del rango de tarjetas no corresponde con la cantidad de tarjetas recibidas.
					LET cCodRet = '00104';
				END IF;
			END IF;
		END IF;
	END IF;
ELSE
	--La fecha de activacion de sucursal es mayor a la actual.
	LET cCodRet = '00100';
END IF;
RETURN cCodRet;

END;
END PROCEDURE

DOCUMENT
'DESCRIPCION: procedimiento para la reversiÃ³n del proceso de recepciÃ³n de tarjetas Coppel',
'ELABORO: OSCAR ALEXIS IBARRA VERDUGO',
'SOLICITO: Abraham Narvaez', 
'FECHA: 28/11/2016',
'BD: bditarjcop';

CREATE PROCEDURE "informix".sp_validastatustarjcoppel (pEmpresa char(3), 
											pNumTarjeta char(9), 
											pSucursal char(4), 
											pNumEnvio int )  

   -- DATOS A REGRESAR --
        RETURNING
        char(4),    -- Codigo de retorno
		char(1);    --status de la tarjeta
		
		    -- VARIABLES --
        DEFINE vCodRet  char(4);
		DEFINE Status   char(1);
		DEFINE iSqlErr  SMALLINT;
		
		
		     -- INICIALIZACION DE VARIABLES --
        LET vCodRet  = "0000";
        LET Status = "";
		LET iSqlErr = 0;
		
BEGIN
		
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				let vCodRet = iSqlErr;
				RETURN vCodRet,'';
			END IF ;
		END EXCEPTION 

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
    --set debug file to '/tmp/sp_validastatustarjcoppel.out';
    --trace on;

		
		IF(pEmpresa<>"" AND pNumTarjeta <> "" AND pSucursal<>"") THEN
		
				SELECT estatustarjeta  INTO  Status
				FROM bditarjcop: "informix".tarjetasnumtarcop 
				where empresa=pEmpresa and cvesucursal=pSucursal and numenvio=pNumEnvio and numtarjeta=pNumTarjeta;
				
				 IF DBINFO('sqlca.sqlerrd2') = 0 THEN
		          LET vCodRet = '1710'; -- tarjeta no existe
				 END IF
		Else
		  LET vCodRet  = "0001"; 
		End IF
		
		RETURN vCodRet, Ltrim(Status);
END
END PROCEDURE
DOCUMENT  "Version 1.00.000",
'NOMBRE: Alvarado Verdugo Jesus Alberto',
'Folio:  RQM 06 220-2 - ADEMDUM- Control y Registro de tarjetas en Sucursal',
'DESCRIPCION: te regresa el status de tarjetas coppel para actualizar la tabla Vtarjetas ',   
'Peticiones involucradas: 144 - ControlRegistrTarjetasSucursal',     
'FECHA: 06-02-2018',
'BD: BDITARJCOP';

CREATE PROCEDURE  "informix".sp_consultarangotarjetascoppel(cEmpresa CHAR(3),cSucursal CHAR(4),iEnvio INTEGER,cTarjetaini CHAR(16),cTarjetafin CHAR(16),iCuantos SMALLINT)
RETURNING 	CHAR (5) AS codRet, CHAR(9) AS numTarjeta;
		
	DEFINE cCodRetorno CHAR(5);
	DEFINE cNumTarjeta CHAR(9);
	DEFINE iSqlErr INTEGER;
	
	LET cCodRetorno = '00000';
	LET cNumTarjeta = '';

	BEGIN
		
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				let cCodRetorno = iSqlErr;
				RETURN cCodRetorno,'';
			END IF ;
		END EXCEPTION ;
		
		--SET DEBUG FILE TO "/respaldosbd/Ismael/sp_conssolicitudescredito2.out";
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
	
		IF (cEmpresa = '' AND cSucursal = '' AND iEnvio = 0 AND cTarjetaini = '' AND cTarjetafin = '') THEN
			--cuando los valores estan vacios mando codigo de retorno 00001
			LET cCodRetorno = '00001';
			RETURN cCodRetorno,'';			
		ELSE
			---consulta de paginado
			FOREACH
				SELECT skip iCuantos numtarjeta
				INTO cNumTarjeta
				FROM bditarjcop: "informix".tarjetasnumtarcop
				WHERE empresa = cEmpresa AND cvesucursal = cSucursal AND numenvio = iEnvio AND numtarjeta BETWEEN cTarjetaini AND cTarjetafin
						
				RETURN cCodRetorno,cNumTarjeta WITH RESUME;
			END FOREACH;
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodRetorno = '00002';
				RETURN cCodRetorno, '';
			END IF;
		END IF;
	END
END PROCEDURE
DOCUMENT
'Autor: 97343331 Ismael Lizarraga',
'Folio: 144 - ControlRegistrTarjetasSucursal',
'Fecha: 29-11-2016',
'ModificaciÃ³n: Se crea procedimiento para consultar rango de tarjetas Coppel recibidas',
'Sustento: 144.1 RQM 06 220 Control y Registro de Tarjetas en Sucursal-Contrato',
'Solicita: Abraham Narvaez',
'Base de datos: Intercard';

CREATE PROCEDURE "informix".sp_esnumerico (psCadena CHAR (20))
	RETURNING CHAR (1) AS Munerico;

--****************************************************************************************************
-- DESCRIPCION:  VERIFICA QUE LA CADENA DE ENTRADA SOLAMENTE CONTENGA NUMEROS
-- AUTOR :Martha Aguirre
-- FECHA : 19/08/2008
-- BD: bdinteg
--***************************************************************************************************

	/*  DEFINICION DE VARIABLES */
	DEFINE vsRespuesta CHAR (1);
	DEFINE visqlerr INTEGER;
	
	/* INICIALIZACION DE VARIABLES */
	LET vsRespuesta = 'F';
	LET visqlerr = 0;
	
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		ON EXCEPTION SET visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado
			IF visqlerr = -1213 THEN
				LET vsRespuesta = 'F'; 
			ELSE
				LET vsRespuesta = ' '; 
			END IF;
			RETURN vsRespuesta;
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/tmp/sp_esnumerico.out";
		--TRACE ON;
		
		IF (psCadena >= 0) THEN 
			LET vsRespuesta = 'V';
		ELSE
			LET vsRespuesta = 'F';
		END IF  ;
		
		RETURN vsRespuesta ;
		
	END
END PROCEDURE;