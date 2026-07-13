CREATE PROCEDURE "informix".sp_diashabilesbanco(pFecha date,pDias integer)
RETURNING char(6),char(80),date;

DEFINE i integer;
DEFINE iContador integer;
DEFINE vcodRet char(6); 	 --CODIGO DE RETORNO
DEFINE vsqlerr integer;		 --VARIABLE PARA CACHAR EL CODIGO DE ERRORDEFINE vsqlerr integer;
DEFINE iIsamErr smallint;	 --VARIABLE PARA CACHAR EL CODIGO DE ERROR
DEFINE cErrorInfo char(80);  --VARIABLE PARA CACHAR LA DESCRIPCION DEL ERROR
DEFINE vErrorInfo char(80);	 --VARIABLE PARA RETORNAR EL MENSAJE DE ERROR O MENSAJE DE EXITO
DEFINE dfecha date; 		 --FECHA 
DEFINE dfechaAux date; 		 --FECHA 
DEFINE sDia smallint;		 --DIA

LET i = 0;
LET iContador = 0;
LET vcodRet = '000';
LET vsqlerr = 0;
LET iIsamErr = 0;
LET cErrorInfo = "";
LET vErrorInfo = "PROCESO EXITOSO";
LET dfecha = DATE(1);

begin

	ON EXCEPTION  SET vsqlerr, iIsamErr, cErrorInfo
		IF vsqlerr <> 0  THEN
			LET  vCodRet  = vsqlerr;
			LET vErrorInfo = cErrorInfo;
			RETURN vCodRet, vErrorInfo,dfecha;
		END IF;
	END  EXCEPTION
/*
 set debug file to "/tmp/Pulido/PRUEBAPUL.out";
 trace on;
*/
	
	LET dfechaAux = pFecha;
	while icontador<pdias
		if not exists (select fecha from bdinteg:si_feriado where fecha=dfechaAux) then
			select decode (weekday(dfechaAux),1,1,2,1,3,1,4,1,5,1,6,0,7,0,0) into sDia from bdicheq:sc_fechas;
			LET iContador = iContador + sDia;
		end if;
		LET dfechaAux=dfechaAux+1 units day;
	END while;
	
	if exists (select fecha from bdinteg:si_feriado where fecha=dfechaAux) then
		LET dfechaAux=dfechaAux+1 units day;
	else
		select decode (weekday(dfechaAux),6,2,0,1,0) into sDia from bdicheq:sc_fechas;
		LET dfechaAux=dfechaAux+sdia units day;
	end if;
	
	LET dfecha = dfechaAux;
	return vCodRet, vErrorInfo,dfecha;
	
end;
END PROCEDURE;