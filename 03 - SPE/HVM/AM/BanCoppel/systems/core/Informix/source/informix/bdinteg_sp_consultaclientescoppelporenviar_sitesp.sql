CREATE PROCEDURE "informix".sp_consultaclientescoppelporenviar_sitesp(pEmpresa CHAR(3))

	RETURNING CHAR(6)	AS CodRet,		
	          CHAR(100)	AS UrL,		
	          CHAR(4)	AS Sucursal,
	          INTEGER	AS TipoOperacion,
	          CHAR(100)	AS Llave,
	          CHAR(100)	AS LlavePrivada,
	          INTEGER	AS IdTransaccion,
	          CHAR(20)	AS NumCliente,
	          CHAR(20)	AS Cliente,
	          CHAR(100)	AS EsperaConsulta;
			
	-----------------------------------------------------------------------------------------------------
	--	000000 = OperaciÃ³n Exitosa
	--	000001 = ParÃ¡metro de entrada vacÃ­os o Nulos
	--	000002 = No se encontraron registros para enviar al WS
	--	000003 = No se encontro la URL del WS
	--	000004 = No se encontrÃ³ el codigo de consulta para el WS al buscar en la si_param el codigo 349
	--	000005 = No se encontrÃ³ el Tipo Operacion al buscar en la el codigo 350
	--	000006 = No se econtrÃ³ la Llave al buscar en la  si_param el codigo 351
	--	000007 = No se encotrÃ³ el valor de Espera Consulta al buscar en la si_param el codigo 352
	--	000008 = No se encontrÃ³ el Id Transaccion al buscar en la  si_param el codigo 353
	--	000009 = No se encontrÃ³ la Llave Privada al buscar en la si_param el codigo 388
	--	000010 = No se encontrÃ³ ninguno de los cÃ³digos parametrizados en la tabla  si_param
	-----------------------------------------------------------------------------------------------------

	--DECLARACION
	DEFINE cCodRet 		CHAR(6);
	DEFINE iSqlErr 		INTEGER;
	DEFINE cCodWs 		CHAR(100);
	DEFINE cValor	 	CHAR(100);
	DEFINE cTipoOper 	CHAR(100);
	DEFINE cLlave	 	CHAR(100);
	DEFINE cConsulta 	CHAR(100);
	DEFINE iTrans	 	INTEGER;
	DEFINE cLlavePriv 	CHAR(100);
	DEFINE iRow		 	INTEGER;	
	DEFINE cUrlWS		CHAR(100);
	DEFINE cSucursal	CHAR(4);
	DEFINE cNumCteBcpl	CHAR(20);
	DEFINE cNumCteCpl	CHAR(20);	
	DEFINE iCodParam	INTEGER;	
	
	--INICIALIZACION
	LET cCodRet 		= '000000';
	LET iSqlErr 		= 0;
	LET cCodWs 	    	= '';
	LET cValor 	    	= '';
	LET cTipoOper   	= '';
	LET cLlave	    	= '';
	LET cConsulta   	= '';
	LET iTrans	    	= 0;
	LET cLlavePriv  	= '';
	LET iRow 			= 3;
	LET cUrlWS	 		= '';
	LET cSucursal		= '';
	LET cNumCteBcpl		= '';
	LET cNumCteCpl		= '';
	LET iCodParam		= 0;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET debug FILE TO '/tmp/sp_consultaclientescoppelporenviar_sitesp.out';
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
		   IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, '', '', '', '', '', '', '', '', '';
		   END IF;
		END EXCEPTION;
		
		IF NVL(pEmpresa,'') = '' THEN
			LET cCodRet = '000001';
			RETURN cCodRet, '', '', '', '', '', '', '', '', '';
		ELSE
		
			FOREACH			
			
				SELECT NVL(TRIM(valor),''),NVL(cod_param,0)
				INTO cValor,iCodParam
				FROM "informix".si_param 
				WHERE cod_param IN (349,350,351,352,388)
				AND empresa = pEmpresa
				ORDER by cod_param			
				
				LET iRow = iRow + 1;
				
				IF iCodParam = 349 AND iRow = 4 AND NVL(TRIM(cValor),'') <> '' THEN
					LET cCodWs = TRIM(cValor);
				ELIF iCodParam = 350 AND iRow = 5 AND NVL(cValor,'') <> '' THEN
					LET cTipoOper = TRIM(cValor);
				ELIF iCodParam = 351 AND iRow = 6 AND NVL(TRIM(cValor),'') <> '' THEN
					LET cLlave = TRIM(cValor);
				ELIF iCodParam = 352 AND iRow = 7 AND NVL(TRIM(cValor),'') <> '' THEN
					LET cConsulta = TRIM(cValor);
					LET iRow = iRow + 1;
				ELIF iCodParam = 388 AND iRow = 9 AND NVL(TRIM(cValor),'') <> '' THEN
					LET cLlavePriv = TRIM(cValor);
				ELSE
					LET cCodRet = '00000'||iRow;
					RETURN cCodRet, '', '', '', '', '', '', '', '', '';				
				END IF;
			
			END FOREACH;
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '000010';
				RETURN cCodRet, '', '', '', '', '', '', '', '', '';
			END IF;
			
			IF iRow = 8 THEN	--INDICA QUE EL FOREACH NO ENCONTRO EL ULTIMO REGISTRO
				LET cCodRet = '000009';
				RETURN cCodRet, '', '', '', '', '', '', '', '', '';
			END IF;
			
			LET iRow = 0;
			
			EXECUTE PROCEDURE BDISOLIC: "informix".sp_obtienenumeroconsultaws(353, pEmpresa) INTO cCodRet, iTrans;
			
			IF NVL(cCodRet,"")::INTEGER <>  0 OR NVL(iTrans,0) = 0 THEN
				LET cCodRet = '000008';
				RETURN cCodRet, '', '', '', '', '', '', '', '', '';
			END IF;
			
			SELECT 	NVL(url_webservice,'')
			INTO cUrlWS
			FROM "informix".mae_webservice
			WHERE empresa = pEmpresa  
			AND cod_ws = cCodWS;
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '000003';
				RETURN cCodRet, '', '', '', '', '', '', '', '', '';
			END IF;
			
			FOREACH
			
				SELECT NVL(sucursal,''), NVL(num_cte,''), NVL(cliente,'')
				INTO cSucursal, cNumCteBcpl, cNumCteCpl
				FROM bdisolic:"informix".ss_situaciones_especiales_cliente
				WHERE empresa = pEmpresa
				AND statusenvio in(0,2)	
				
				RETURN cCodRet, TRIM(cUrlWS), TRIM(cSucursal), TRIM(cTipoOper), TRIM(cLlave), TRIM(cLlavePriv), iTrans, TRIM(cNumCteBcpl), TRIM(cNumCteCpl), TRIM(cConsulta) WITH RESUME;
								
			END FOREACH;
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '000002';
				RETURN cCodRet, '', '', '', '', '', '', '', '', '';
			END IF;				
			
		END IF;				
	END;
	
END PROCEDURE
DOCUMENT
"Folio: 1744",
"Autor: 95281495 Ernesto Aguilera",
"Fecha: 04/08/2015",
"Detalle: Se crea SP para obtener detalle de la estructura de el xml  que se enviara mediante un web service.",
"Solicita:  Rodolfo Gomez ",
"BD: bdinteg";

CREATE PROCEDURE "informix".sp_insertacteporenviar(
                        pEmpresa CHAR(3),
                        pSucursal CHAR(4),
                        pNumCte CHAR(20),
                        pNumSolicitud CHAR(20),
						pErrorDevuelto CHAR(6),
						pEstatus CHAR(1),
						pFechaInserta DATETIME YEAR TO SECOND,
						pFechaActualiza DATETIME YEAR TO SECOND)
	RETURNING CHAR(5);
	--Declaracion de variables
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;

	--Inicializacion de variables
	LET cCodRet = '00000';

	--SET debug FILE TO '/tmp/sp_insertacteporenviar.out';
	--TRACE ON;
	--SET DEBUG FILE TO '/respaldosbd/Carolina/sp_insertacteporenviar .out';
	--TRACE ON;
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		INSERT INTO "informix".si_clientescoppelporenviar(empresa, sucursal, numcte, num_solicitud, error_devuelto, status, fecha_inserta, fecha_actualiza)
		VALUES(pEmpresa, pSucursal, pNumCte, pNumSolicitud, pErrorDevuelto, pEstatus, pFechaInserta, pFechaActualiza);
	
	--IF pSucursal='0318' OR pSucursal='0371' OR pSucursal='0905' OR pSucursal='0170' OR pSucursal='0249' OR pSucursal='0250' OR pSucursal='0253' OR pSucursal='0254' OR pSucursal='0255' OR pSucursal='0310' OR pSucursal='0332' OR pSucursal='0357' 	OR pSucursal='0358' OR pSucursal='0455' OR pSucursal='0814' OR pSucursal='0907' OR pSucursal='0933' OR pSucursal='0983' OR pSucursal='0255' OR pSucursal='1016'	OR pSucursal='1088' OR pSucursal='1203' OR pSucursal='1214' OR pSucursal='1405' THEN
		INSERT INTO bdinteg: "informix".si_situaciones_clientescoppel_porenviar (empresa,sucursal,numcte,cliente,idusituacion,resultados,status,mensaje,ctl_enviado,empleado,fecha_insert,fecha_modificacion)
		VALUES (pEmpresa,pSucursal,pNumCte,'',0,0,0,'',"0", '', CURRENT,'');		
	--END IF;



		RETURN cCodRet;
	END;
END PROCEDURE
DOCUMENT
"CREO  : Frank Gaxiola Gaxiola",
"FECHA : 05/Septiembre/2012",
"Ver.  : 1.1",
"BD    : bdinteg",
"MODIFICO : Carolina Verdugo",
"FECHA : 18/08/2015",
"FOLIO: 1743",
"DESCRIPCION : Se agrega insert a la tabla si_situaciones_clientescoppel_porenviar",
"SOLICITA:  Rodolfo Gomez ",
"BD: bdinteg";

CREATE PROCEDURE "informix".validafechadireccioncte(cNumcte char(20))
RETURNING CHAR(5),DATE;

    -- *************************************************************************
    -- | Procedimiento   : validafechadireccioncte
    -- | Versión                :1.0
    -- | Creado por         : Martha Aguirre
    -- | Fecha creacion  : Abril de 2010
    -- | Descripción        : Extrae la fecha de alta de direcciòn de cliente.
    -- *************************************************************************
    
    DEFINE dFechaInsert      DATE;
    DEFINE cCodRet           CHAR(5);
    
    LET dFechaInsert = date(1);
    LET cCodRet = '00000';
    
    --- SET DEBUG FILE TO '/tmp/validafechadireccioncte.out';
    --- TRACE ON;
    
    BEGIN
    
    SET ISOLATION TO DIRTY READ;
	
	if cNumcte = '' then
		
		LET cCodRet = '00001'; --- PARAMETRO VACIO
        LET dFechaInsert = date(1);	
		RETURN cCodRet, dFechaInsert;
		
	end if;
    
    SELECT {+INDEX(si_direcciones_actual idx_diract_ctetpo)}
           fecha_insert 
      into dFechaInsert  
      FROM si_direcciones_actual 
     where numcte = cNumcte
       AND tipo_dir = '1';
       
    if dFechaInsert is not null or dFechaInsert <> '' then
        
    else
        LET cCodRet = '00001'; --- FECHA DE INSERCION NO EXISTE
        LET dFechaInsert = date(1);
    END IF;

    RETURN cCodRet, dFechaInsert;
    
    END;
    
END PROCEDURE;