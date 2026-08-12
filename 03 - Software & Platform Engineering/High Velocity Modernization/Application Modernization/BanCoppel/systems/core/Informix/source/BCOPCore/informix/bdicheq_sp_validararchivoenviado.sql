CREATE PROCEDURE "informix".sp_validararchivoenviado(pArchivo CHAR(50))
	RETURNING
		CHAR(6) 	AS CODRET;


		---DECLARACIONES
		DEFINE iSqlErr				INTEGER;
		DEFINE cCodRet         		CHAR(6);

		---INICIALIZACIONES
		LET iSqlErr            		= 0;
		LET cCodRet            		= '00000';

	BEGIN

		ON EXCEPTION SET iSqlErr
		   IF iSqlErr != 0 THEN
			  LET cCodRet = iSqlErr;
			  RETURN cCodRet;
		   END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--SET DEBUG FILE TO '/tmp/sp_validararchivoenviado.out';
		--TRACE ON;	

		IF EXISTS (SELECT nombre_archivo FROM bdicheq:"informix".sc_nominaencabezadosumario WHERE nombre_archivo = pArchivo
		UNION SELECT nombre_archivo FROM bdicheq:"informix".sc_nominaencabezadosumariohist WHERE nombre_archivo = pArchivo) THEN
            LET cCodRet = '00001';
        END IF;
        RETURN cCodRet;
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento que valida si ya se proseso archivos de dispercion en las tablas ',
'sc_nominaencabezadosumario y sc_nominaencabezadosumariohist ',
'AUTOR: Bernardo Carlos Báez Gozález ',
'FECHA: 20 de Octubre 2011',
'VERSION: 20111020.1152',
'BD: bdicheq',
'Paquete/Caso de Uso: PCU-bdicheq/CU-0161-ValidarArchivoEnviado-SPL',
'Se ejecuta desde la aplicacion: "validafondos" en el mensaje "validafondos00005.so"',
'mismo que se llama desde "DispersionNominaBanCoppel.exe"';

CREATE PROCEDURE "informix".sp_obtbines2(pBin char(6))
RETURNING CHAR(5),CHAR(3)


	------------------------------------------------------------------------------------------------------------------------
	--Elaboró:Francisco Rodríguez Ibarra.
	--Actividad:Se utiliza para obtener el banco  o generar los bines, debido a la migración de BD de postgres a informix
	--Solicito:Diana Castellanos
	--Fecha:21/10/2010
	------------------------------------------------------------------------------------------------------------------------
		------------------------------------------------------------------------------------------------------------------------
	--Elaboró:Francisco Rodríguez Ibarra.
	--Actividad:Se modificó para tomar la columna cve_banco en vez de la id_bco
	--Solicito:Diana Castellanos
	--Fecha:16/11/2010
	------------------------------------------------------------------------------------------------------------------------
	--DECLARACION DE VARIABLES
	DEFINE vCod_Ret CHAR(5);
	DEFINE sql_err INTEGER ;
	DEFINE vBanco CHAR(3);
	DEFINE vStipo CHAR(1);
	
	--INICIALIZAR VALORES A VARIABLES;
	LET vCod_Ret='00000';
	LET vBanco='';
	LET vStipo='';
	
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_Ret = sql_err;
				RETURN vCod_Ret,vBanco;
		  END IF ;
		END EXCEPTION ;
		
		
			
		SELECT creditodebito,cve_banco INTO vStipo,vBanco FROM  bdicheq:sc_bines WHERE bin= TRIM(pBIN);
		IF(vStipo<>'')THEN
			IF(vStipo='d')THEN
				LET vCod_Ret='00000';			END IF;
			IF(vStipo='c')THEN
				LET vCod_Ret='00001';			END IF;
			IF(vBanco='137')THEN
				LET vCod_Ret='00001';			END IF;
		ELSE
				LET vCod_Ret='00002'; --No existe el bin
		END IF
		
		
		RETURN vCod_Ret,vBanco;
		
	END;
END PROCEDURE;