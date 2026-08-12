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