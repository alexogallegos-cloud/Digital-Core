CREATE PROCEDURE "informix".sp_genera_archivosbatch_se(pempresa CHAR(3), pFechaAct DATE)
RETURNING char(5) ;
--as cod_ejemplo,


--DECLARACIÓN DE VARIABLES.
DEFINE cCodRet      	CHAR(5);
--DEFINE cCod_err	CHAR(5);
DEFINE iSqlErr     INTEGER;

--INICIALIZACIÓN DE VARIABLES
LET cCodRet 	= '00000';


--SET DEBUG FILE TO '/respaldosbd/OmarGamez/sp_genera_archivosbatch.out';
--SET DEBUG FILE TO '/pisa/pisabanco/sp_genera_archivosbatch.out';
--TRACE ON;
begin
	on exception set iSqlErr
			if iSqlErr <> 0 then
				let cCodRet= iSqlErr ;
				return trim(NVL(cCodRet,""));
			end if;
	end exception;


	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	call sp_genera_archivosbatch_situaciones( pempresa, pFechaAct ) returning cCodRet;
	if cCodRet::integer < 0 then
		return cCodRet;
	end if

	call sp_totalesmovimientoscoppelbatch_situaciones( pempresa, '', pFechaAct ) returning cCodRet;
	if cCodRet::integer < 0 then
		return cCodRet;
	end if
	
	call sp_generararchivoplanobatch_situaciones( '', pFechaAct ) returning cCodRet;
	if cCodRet::integer < 0 then
		return cCodRet;
	end if
	
	call sp_generararchivoplanobatch_situaciones('TO', pFechaAct ) returning cCodRet;
	if cCodRet::integer < 0 then
		return cCodRet;
	end if
	return cCodRet;

end;
end procedure;