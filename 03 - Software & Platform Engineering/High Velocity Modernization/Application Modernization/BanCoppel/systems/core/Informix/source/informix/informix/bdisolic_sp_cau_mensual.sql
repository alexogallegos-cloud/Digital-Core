CREATE PROCEDURE "informix".sp_cau_mensual(piIdArchivo INTEGER)
RETURNING CHAR(5) AS vcCodRet, CHAR(100) AS vcMensajeRet;


--DeclaraciON de variables
DEFINE vcCodRet CHAR(5);
DEFINE vcMensajeRet CHAR(100);
DEFINE viSqlErr INTEGER;
DEFINE cErrorInfo VARCHAR(80);
DEFINE iIsamErr	INTEGER;
DEFINE vcRepositorio CHAR(50);


DEFINE vsSQL CHAR (6300) ;



--InicilizANDo variables
LET vcCodRet = '00000';
LET vcMensajeRet = 'PROCESO EXITOSO';
LET viSqlErr = '';
LET cErrorInfo = '';
LET iIsamErr = 0;
LET vcRepositorio = '';
LET vsSQL = '' ;



--SET DEBUG FILE TO "/tmp/Mensual/Reporte/sp_cau_genarchivosmensuales.out";
--TRACE ON;


BEGIN

ON EXCEPTION SET viSqlErr, iIsamErr, cErrorInfo
	IF (viSqlErr <> 0) THEN
		LET vcCodRet = viSqlErr;
		LET vcMensajeRet = cErrorInfo;
		RETURN vcCodRet, vcMensajeRet;
	END IF;
END EXCEPTION;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;


--LET vcRepositorio ='/informix/c92962301/archivos';
LET vcRepositorio ='/resplogifx/archivoscartera';


	LET vsSQL = TRIM(vcRepositorio) || '/' ||'cau_mensual.sh '||piIdArchivo;

	SYSTEM vsSQL;

				
		RETURN vcCodRet, vcMensajeRet;
	

END
END PROCEDURE;