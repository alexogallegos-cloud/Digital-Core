CREATE PROCEDURE "informix".sp_cau_descargaarchivo(pcConsulta CHAR(6000), pcNombreArchivo CHAR(21), pcRepositorio CHAR(50), pcTipo INT DEFAULT 1)
RETURNING CHAR(5) AS codret, CHAR(100) AS mensajeret;
/*
Autor Modificación: Daniel Lazalde
Fecha Modificación: 25-Feb-2013
Observación: Se agregó un parametro pcTipo para determinar el tipo de extension; 
si es uno guarda el archivo con extensión 'txt' en caso contrario en formato excel 'xls'
*/

--Declaracion de variables
DEFINE vcCodRet CHAR(5);
DEFINE vcMensajeRet CHAR(100);
DEFINE viSqlErr INTEGER;
DEFINE vsNomArchivoTmp CHAR (32);
DEFINE vsNomArchivoCtrl CHAR (32);
DEFINE vsSQL CHAR (6300) ;
DEFINE vsSQL1 CHAR (150);
DEFINE vsSQL2 CHAR (6000) ;
DEFINE vsSQL3 CHAR (150) ;
DEFINE vcNombreArchivo CHAR(21);

--Inicilizando variables
LET vcCodRet = '00000';
LET vcMensajeRet = '';
LET viSqlErr = 0;
LET vsNomArchivoTmp = '';
LET vsSQL = '' ;
LET vsSQL1 = '' ;
LET vsSQL2 = '' ;
LET vsSQL3 = '' ;
LET vcNombreArchivo = '';
LET vsNomArchivoCtrl = '';

--SET DEBUG FILE TO "/dbexport/AltaUnica/sp_cau_descargaarchivo.out";
--TRACE ON;

BEGIN

ON EXCEPTION SET viSqlErr
	IF (viSqlErr <> 0) THEN
		LET vcCodRet = viSqlErr;
		RETURN vcCodRet, vcMensajeRet;
	END IF;
END EXCEPTION;

		LET vcNombreArchivo = TRIM(pcNombreArchivo);
		LET vsNomArchivoTmp = 'tmp'||TRIM(vcNombreArchivo)||'.txt';
		LET vsNomArchivoCtrl = 'ctrl'||TRIM(vcNombreArchivo)||'.sql';
		IF pcTipo = 1 THEN
			LET pcNombreArchivo = TRIM(pcNombreArchivo) || '.txt' ;
		ELSE 	
			LET pcNombreArchivo = TRIM(pcNombreArchivo) || '.xls' ;
		END IF;
		
		--GENERA EL ARCHIVO DE INTERCAMBIO
		LET vsSQL1 = 'echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(pcRepositorio) || '/' || TRIM (vsNomArchivoTmp) || ' DELIMITER ' || '''?''';

		LET vsSQL2 = pcConsulta;

		LET vsSQL3 = ' " > '|| TRIM(pcRepositorio) ||'/' ||vsNomArchivoCtrl;
		LET vsSQL1 = TRIM(vsSQL1);
		LET vsSQL3 = TRIM(vsSQL3);
		LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;

		--CHECA QUE NO ESTE VACIA LA CONSULTA
		IF ( vsSQL <> '' ) THEN
			SYSTEM vsSQL ;
			--Permiso para la creacion de archivo.
			LET vsSQL = '' ;
			LET vsSQL = 'chmod 666 ' || TRIM(pcRepositorio) ||'/' ||vsNomArchivoCtrl ;
			LET vsSQL = '' ;
			LET vsSQL = 'dbaccess bdisolic ' || TRIM(pcRepositorio) || '/' ||vsNomArchivoCtrl ;
			SYSTEM vsSQL ;
			--Borra el archivo de control.
			LET vsSQL = '' ;
			LET vsSQL = 'rm ' || TRIM(pcRepositorio) ||'/' ||vsNomArchivoCtrl;
			SYSTEM vsSQL ;

			--Elimina el caracter delimitador '?'.
			LET vsSQL = '' ;
			LET vsSQL =  "sed 's/?$//g' " || TRIM(pcRepositorio) || '/' || TRIM(vsNomArchivoTmp) || " > " || TRIM(pcRepositorio) || '/' || TRIM(pcNombreArchivo);
			SYSTEM vsSQL;

			--Borra el archivo de control.
			LET vsSQL = '' ;
			LET vsSQL = 'rm ' || TRIM(pcRepositorio) || '/' || TRIM(vsNomArchivoTmp);
			SYSTEM vsSQL ;

			LET vcCodRet = '00000';
		ELSE 
			-- CONSULTA VACIA
			LET vcCodRet = '01000';
		END IF ;
		
		RETURN vcCodRet, vcMensajeRet;
END
END PROCEDURE
