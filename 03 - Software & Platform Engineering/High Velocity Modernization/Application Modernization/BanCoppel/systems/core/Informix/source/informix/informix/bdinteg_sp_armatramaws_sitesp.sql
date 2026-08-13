CREATE PROCEDURE "informix".sp_armatramaws_sitesp(pTimestamp CHAR(27),pIDusituacion integer, pIDtransaccion CHAR(100),pFirma CHAR(40),pNumCte CHAR(20),pOpcion CHAR(1))

	RETURNING CHAR(6) AS CodRet,    	--Codigo Retorno
              CHAR(2050) AS TramaXML; 	--Trama XMl


	--DECLARACION
	DEFINE cCodRet 		CHAR(6);
	DEFINE iSqlErr 		INTEGER;
	DEFINE sEstructuraXML    LVARCHAR(2050); 
	
	
	--INICIALIZACION
	LET cCodRet 		= '000012';
	LET iSqlErr 		= 0;
	LET sEstructuraXML  = '';
	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET debug FILE TO '/tmp/Yadira/sp_armatramaalta_aidaban_sitesp.out';
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
		   IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, '';
		   END IF;
		END EXCEPTION;
		
	IF NVL(pTimestamp,'') = '' OR  NVL(pIDtransaccion,'') = '' OR NVL(pFirma,'') = '' OR NVL(pNumCte,'') = '' OR NVL(pOpcion,'') = '' THEN
			LET cCodRet = '000011';
			
	ELSE
			
	    IF pOpcion = '1'	 THEN
		
		
			EXECUTE PROCEDURE bdinteg: "informix".sp_armatramaconsulta_aidaban_sitesp (pTimestamp,pIDtransaccion,pFirma,pNumCte) INTO cCodRet, sEstructuraXML;
		
				
		ELIF  pOpcion = '2' THEN
		
	    EXECUTE PROCEDURE bdinteg: "informix".sp_armatramaalta_aidaban_sitesp (pTimestamp,pIDusituacion,pIDtransaccion,pFirma,pNumCte)INTO cCodRet, sEstructuraXML;
		
		     		
	     END IF;
	END IF;
	
	RETURN cCodRet, sEstructuraXML;
	
	END;
	
END PROCEDURE
DOCUMENT
"Folio: 1744",
"Autor: ",
"Fecha: 04/08/2015",
"Detalle: Se crea SP para obtener detalle de la estructura de el xml  que se enviara mediante un web service.",
"Solicita:  Rodolfo Gomez ",
"BD: bdinteg";

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