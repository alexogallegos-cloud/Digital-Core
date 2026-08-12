CREATE PROCEDURE "informix".sp_armatramaconsulta_aidaban_sitesp(pTimestamp CHAR(29), pIDtransaccion CHAR(100),pFirma CHAR(40),pNumCte CHAR(20))

	RETURNING CHAR(6) AS CodRet,    	--Codigo Retorno
              CHAR(2050) AS TramaXML; 	--Trama XML
	-----------------------------------------------------------------------------------------------------
	--	000000 = Operación Exitosa
	--	000001 = Parámetro de entrada vacíos o Nulos
	--	000002 = No se encontraron registros de Sucursal o Empresa para enviar al WS
	--	000003 = Fallo en la ejecución del sp_obtienedetalle_xml
	--	000004 = No se encontró el codigo de consulta para el WS al buscar en la si_param el codigo 365
	--	000005 = No se encontró el Tipo Operacion al buscar en la el codigo 350
	--	000006 = No se econtró la Llave al buscar en la  si_param el codigo 351
	--	000007 = No se encotró el valor de Espera Consulta al buscar en la si_param el codigo 352
	--	000008 = No se encotraron los parámetros (365,350,351,352)en la tabla si_param
	-----------------------------------------------------------------------------------------------------

	--DECLARACION
	DEFINE cCodRet 		CHAR(6);
	DEFINE iSqlErr 		INTEGER;
	DEFINE cCodWs 		CHAR(100);
	DEFINE cUrlWS		CHAR(100);
	DEFINE cSoapAction	CHAR(30);
	DEFINE cTipoXML		CHAR(4);
	DEFINE cInicioTag	CHAR(25);
	DEFINE cValorTag	CHAR(100); 
	DEFINE cCierreTag	CHAR(25);
	DEFINE cNombre_webservice	CHAR(55);
	DEFINE cNodeResponse	CHAR(30);
	DEFINE cNumretornos	CHAR(2);
	DEFINE iUltimoregistro   SMALLINT;
	DEFINE iReg         SMALLINT;
	DEFINE cCod_ret		CHAR(6);
	DEFINE sEstructuraXML    LVARCHAR(2050); 
	DEFINE iSecuencia  INTEGER;
	DEFINE iCodParam	INTEGER;	
	DEFINE cValor	 	CHAR(100);
	DEFINE cEmpresa     CHAR(3);
	DEFINE cSucursal    CHAR(4);
	DEFINE iRow         SMALLINT;
	DEFINE cTipoOper 	CHAR(100);
	DEFINE cLlave	 	CHAR(100);
	DEFINE cConsulta 	CHAR(100);
	DEFINE cParam       CHAR(100);
	
	--INICIALIZACION
	LET cCodRet 		= '000000';
	LET iSqlErr 		= 0;
	LET cCodWs 	    	= '';
	LET cUrlWS	 		= '';
	LET cSoapAction		= '';
	LET cTipoXML		= '';
	LET cInicioTag		= '';
	LET cValorTag		= '';
	LET cCierreTag		= '';
	LET cNombre_webservice	= '';
	LET cNodeResponse	= '';
	LET cNumretornos	= '';
	LET iUltimoregistro = '';
	LET iReg            = 0;
	LET cCod_ret        = '';
	LET sEstructuraXML  = '';
	LET iSecuencia      = 0;
	LET iCodParam	    = 0;	
	LET cValor	    	= '';
	LET cEmpresa        = '';
	LET cSucursal       = '';
	LET iRow            = 0;
	LET cTipoOper   	= '';
	LET cLlave	    	= '';
	LET cConsulta   	= '';
	LET cParam          = '';
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET debug FILE TO '/home/tmp/MireyaR/sp_armatramaconsulta_aidaban_sitesp.out';
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
		   IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, '';
		   END IF;
		END EXCEPTION;
		
		IF NVL(pTimestamp,'') = '' OR  NVL(pIDtransaccion,'') = '' OR NVL(pFirma,'') = '' OR NVL(pNumCte,'') = '' THEN
				LET cCodRet = '000001';
		ELSE
			SELECT FIRST 1 empresa, sucursal 
			INTO cEmpresa, cSucursal
			FROM bdisolic: "informix".ss_situaciones_especiales_cliente
			WHERE cliente = TRIM(NVL(pNumCte,''));
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '000002';
			END IF;
		END IF;
		IF cCodRet = '000000' THEN
				--LET dTimestamp = CURRENT;
			FOREACH
					SELECT NVL(valor,''), NVL(cod_param,'')
					INTO cValor, iCodParam
					FROM "informix".si_param 
					WHERE cod_param IN (365,350,351,352)
					AND empresa = cEmpresa
					
					LET iRow = iRow + 1;
					
					IF iCodParam = 365 AND iRow = 1 THEN
						IF NVL(cValor,'') <> '' THEN
						   LET cCodWs = cValor;
						ELSE
							LET cCodRet = '000004';
						END IF;	
					ELIF iCodParam = 350 AND iRow = 2 THEN
						IF NVL(cValor,'') <> '' THEN
						   LET cTipoOper = cValor;
						ELSE
							LET cCodRet = '000005';
						END IF;	
					ELIF iCodParam = 351 AND iRow = 3 THEN
						IF NVL(cValor,'') <> '' THEN
						   LET cLlave = cValor;
						ELSE
							LET cCodRet = '000006';
						END IF;	
					ELIF iCodParam = 352 AND iRow = 4 THEN
						IF NVL(cValor,'') <> '' THEN
						   LET cConsulta = cValor;
						ELSE
							LET cCodRet = '000007';
						END IF;	
					ELSE
						IF iRow = 1 THEN
								LET cCodRet = '000004';
						ELIF iRow = 2 THEN
								LET cCodRet = '000005';
						ELIF iRow = 3 THEN
								LET cCodRet = '000006';
						ELIF iRow = 4 THEN
								LET cCodRet = '000007';
						END IF;
					END IF;
				
			END FOREACH;
					IF iRow = 3 AND cConsulta = '' THEN
						LET cCodRet = '000007';
					END IF
					IF DBINFO('sqlca.sqlerrd2') = 0 THEN
						LET cCodRet = '000008';
					END IF;
				IF cCodRet = '000000' THEN
					FOREACH
						EXECUTE PROCEDURE bdinteg: "informix".sp_obtienedetalle_xml(cEmpresa, cCodWs,0)
						INTO cCod_ret,cNombre_webservice,cUrlWS,cSoapAction,cNodeResponse,cNumretornos,iSecuencia,cTipoXml,cInicioTag,cValorTag,cCierreTag,iUltimoregistro
						
						IF cCod_ret = "000000" THEN
							IF TRIM(cTipoXml) = 'IN' THEN
								IF TRIM(NVL(cInicioTag,'')) <> '' AND TRIM(NVL(cCierreTag,'')) <> '' THEN
									LET iReg = iReg + 1;
									LET cParam = 'VALOR';
									LET cValorTag = TRIM(NVL(cParam,'')) || iReg;
								END IF
							END IF 
							IF TRIM(cTipoXml) <> 'OUT' THEN
								LET sEstructuraXML = TRIM(NVL(sEstructuraXML,'')) || TRIM(NVL(cInicioTag,'')) || TRIM(cValorTag) || TRIM(NVL(cCierreTag,''));
							END IF
						ELSE
							LET cCodRet = '000003';
						END IF;
					END FOREACH;
				
					IF DBINFO('sqlca.sqlerrd2') = 0 THEN
						LET cCodRet = '000003';
					END IF;
					LET sEstructuraXML = REPLACE(TRIM(sEstructuraXML),'VALOR1',TRIM(cSucursal));	
					LET sEstructuraXML = REPLACE(TRIM(sEstructuraXML),'VALOR2',TRIM(cTipoOper));	
					LET sEstructuraXML = REPLACE(TRIM(sEstructuraXML),'VALOR3',TRIM(cLlave));	
					LET sEstructuraXML = REPLACE(TRIM(sEstructuraXML),'VALOR4',TRIM(pTimestamp));	
					LET sEstructuraXML = REPLACE(TRIM(sEstructuraXML),'VALOR5',TRIM(pIDtransaccion));	
					LET sEstructuraXML = REPLACE(TRIM(sEstructuraXML),'VALOR6',TRIM(pFirma));	
					LET sEstructuraXML = REPLACE(TRIM(sEstructuraXML),'VALOR7',TRIM(pNumCte));	
					LET sEstructuraXML = REPLACE(TRIM(sEstructuraXML),'VALOR8',TRIM(cConsulta));
				END IF;
		END IF;
		
		RETURN cCodRet, TRIM(NVL(sEstructuraXML,''));
	END;
END PROCEDURE
DOCUMENT
"Folio: 1744",
"Autor: Isarai Bojorquez",
"Fecha: 21/08/2015",
"Detalle: Se crea SP para obtener detalle de la estructura de el xml  que se enviara mediante un web service.",
"Solicita:  Rodolfo Gomez ",
"BD: bdinteg";

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