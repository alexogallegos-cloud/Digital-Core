create procedure "informix".sp_domi_generafolio(pUsuario char(8),pFolioActivacion char(20))
returning char(16) as cFolio

--declaraciÃ³n de variables
DEFINE cFolio 		CHAR(16);
DEFINE cConsecutivo CHAR(3);
--valores iniciales
LET cFolio 		='';
LET cConsecutivo='000';

--**************************************************************
--SET DEBUG FILE TO "/tmp/sp_domi_generafolio.out";
--TRACE ON;
--**************************************************************

begin
	SET ISOLATION TO DIRTY READ;
	
	SELECT nvl(to_char((max(consec_folio)+1),"&&&"),'001') INTO cConsecutivo
    FROM bdidomi:"informix".dom_archivomanual WHERE folio_activacion = pFolioActivacion;
   
   	UPDATE bdidomi:"informix".dom_archivomanual SET consec_folio = cConsecutivo
    WHERE folio_activacion = pFolioActivacion and accion = 'A' and estatus='EP';

	LET cFolio = RPAD(TRIM(pUsuario),8,'0') || SUBSTR(TRIM(pFolioActivacion),10,5) || cConsecutivo;

end;
return cFolio;
end procedure;