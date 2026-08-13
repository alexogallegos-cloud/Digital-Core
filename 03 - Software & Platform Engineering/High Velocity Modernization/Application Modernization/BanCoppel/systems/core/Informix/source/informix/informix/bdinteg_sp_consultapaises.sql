CREATE PROCEDURE "informix".sp_consultapaises(pNumeroPagina INTEGER, pCantidadRegistros INTEGER)

--ENTRADAS:
--pNumeroPagina			= Número de página del segmento, iniciando en 0, 1, 2 hasta que se terminen los datos de la tablas.
--pCantidadRegistros	= Número de registros por segmentos, si es 0 tomará 16 como defecto.

--RETORNOS:
--000000 = Éxitoso.
--000001 = No hay registros para esos parámetros.
--000002 = Parámetros Negativos.

--DATOS DE RETORNO
RETURNING
CHAR(06) AS codRet,
CHAR(03) AS idPais,
CHAR(30) AS nombrePais;
		
--DEFINICIÓN DE VARIABLES
DEFINE iSqlErr     INTEGER;
DEFINE cCodRet     CHAR(06);
DEFINE cIdPais		CHAR(03);
DEFINE cNombrePais	CHAR(30);
DEFINE iNumeroPag	INTEGER;
DEFINE iCantidadRe	INTEGER;

--INICIALIZACIÓN DE VARIABLES
LET iSqlErr		= 0;
LET cCodRet		= '000000';
LET cIdPais		= '';
LET cNombrePais	= '';
LET iNumeroPag	= 0;
LET iCantidadRe	= 0;
	
	--SET DEBUG FILE TO "";
	--TRACE ON;
	
-- INICIO DEL PROCEDIMIENTO
	BEGIN
		-- MANEJADOR DE ERRORES
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cIdPais,cNombrePais;
			END IF;
		END EXCEPTION;	
			
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--VALIDAR PARÁMETROS NULOS O NEGATIVOS
		IF NVL(pNumeroPagina, 0) < 0 OR NVL(pCantidadRegistros, 0) < 0 THEN
			LET cCodRet = '000002';
			LET cNombrePais = 'Parámetros en cero o negativos';
			RETURN cCodRet, cIdPais, cNombrePais;
		END IF
		
		--ESTABLECER VALORES POR DEFECTO
		IF pCantidadRegistros = 0 THEN
			LET iCantidadRe = 16;
		ELSE
			LET iCantidadRe = pCantidadRegistros;
		END IF
		LET iNumeroPag = pNumeroPagina * iCantidadRe;
	
		FOREACH
			--CONSULTAR LA TABLA si_paisnacion
			SELECT SKIP iNumeroPag FIRST iCantidadRe id_pais, nombre 
			INTO cIdPais, cNombrePais
			FROM bdinteg:"informix".si_paisnacion
			ORDER BY nombre

			RETURN cCodRet, cIdPais, cNombrePais WITH RESUME;
		END FOREACH;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '000001';
			LET cNombrePais = 'Sin Datos';
			RETURN cCodRet, cIdPais, cNombrePais;
		END IF
			
	END
END PROCEDURE
DOCUMENT
"Folio:			1693",
"Proyecto:		MTTO-OFI_PAIS_NACION",
"Asunto:		Requerimiento",
"Autor: 		95579737 - José Ernesto Raygoza Villa",
"Fecha: 		03/Mayo/2016",
"Sustento:		peticiones pendientes de desarrollo bancoppel",
"Solicita:		Gisela Rivera",
"Descripción:	Creación de SP que consulta el catálogo de paises por segmentos",
"BD: 			bdinteg",
"Etiqueta:		DSB230162JERV1694";

CREATE PROCEDURE "informix".sp_valida_curp(			    pcTipo 		CHAR(1),
														pcNumCte	CHAR(10),
														pcCurp		CHAR(18),
														pcSexo		CHAR(1),
														pcApePat	CHAR(50),
														pcApeMat	CHAR(50),
														pcNombres 	CHAR(50),
														pcFecNac 	CHAR(10),
														pcEntidad   INTEGER,
														pcLimit 	INTEGER,
														pcMensajeR	CHAR(100),
														pcStatus	CHAR(2),
														pcTrans		CHAR(6))
														
														  	  
RETURNING 	CHAR(5) AS cCodRet,CHAR(20) AS cNumCte,CHAR(1) AS pcSexo,CHAR(50) AS cNombres,
			CHAR(50) AS cApePat,CHAR(50) AS cApeMat,CHAR(50) AS cCurp,
			CHAR (10) AS cFecNac,CHAR(2) AS cEntFed;
			
	          
--Definicion de Variables
DEFINE iSqlErr 		  	INTEGER;
DEFINE cCodRet 		  	CHAR(5);  
DEFINE cnumcte        	CHAR(15);   
DEFINE capell_paterno 	CHAR(50);    
DEFINE capell_materno 	CHAR(50);    
DEFINE cnombre1       	CHAR(50);    
DEFINE cnombre2       	CHAR(50);    
DEFINE cfecha_nac     	CHAR(10);  
DEFINE cEntFed		  	CHAR(2);  
DEFINE cCurp		  	CHAR(18);
DEFINE cidsession		CHAR(30);
DEFINE csexo			CHAR(1);
DEFINE cFecNac			CHAR(10);
DEFINE iEntidad			INTEGER;
DEFINE fecha_inicio     DATE;
--Inicializacion de Variables
LET iSqlErr 		= 0;
LET cCodRet 		= '0';
LET cnumcte        	= '';    
LET capell_paterno 	= '';    
LET capell_materno 	= '';    
LET cnombre1       	= '';    
LET cnombre2       	= '';    
LET cfecha_nac     	= '';    
LET cEntFed			= '';
LET cCurp			= '';
LET cidsession		= '';
LET csexo			= '';
LET cFecNac			= '';
LET iEntidad		= 0 ;
LET fecha_inicio    =MDY(12,8,2018);
BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, '','','','','','','','';
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/informix/mijail/sp_valida_curp.out';
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
	
	IF 	pcTipo = '0' THEN-- Obtener los clientes o empleados a consultar en coppel
		FOREACH WITH HOLD
		
			SELECT first pcLimit {INDEX ("informix".si_ctepf idx_validacurp)}
               
			D.numcte,P.sexo,D.apell_paterno,D.apell_materno,D.nombre1,D.nombre2,P.fecha_nac,P.lugar_nac,P.curp 
			INTO cnumcte,csexo,capell_paterno,capell_materno,cnombre1,cnombre2,cfecha_nac,cEntFed,ccurp
			FROM "informix".si_ctepf P
			LEFT JOIN "informix".si_cliente D
			ON D.numcte=P.numcte
			--LEFT JOIN "informix".si_estados E
			--ON P.lugar_nac=E.estado 
			WHERE
			P.lugar_nac in (SELECT {INDEX ("informix".si_estados inx_estado)} estado FROM "informix".si_estados WHERE estado=estado) AND --D.fecha_insert >= MDY(12,08,2015) AND ESTO SE COMENTA PARA PRUEBAS
			P.curp=P.curp AND  P.validacurp IS NULL  		
			AND D.fecha_insert >= MDY(12,08,2015) --D.fecha_insert = TODAY-1  -- ESTO SE PONE PARA PRUEBAS
			 -- AND ESTO SE COMENTA PARA PRUEBAS
			
			
			LET cFecNac = YEAR(cfecha_nac)||'/'||LPAD(MONTH(cfecha_nac),2,'0')||'/'||LPAD(DAY(cfecha_nac),2,'0');
			
			
			RETURN cCodret,trim(cnumcte),csexo,trim(trim(cnombre1)||' '||trim(cnombre2)),capell_paterno,capell_materno,NVL(ccurp,''),cFecNac,cEntFed WITH RESUME;
			
		END FOREACH;
		
	ELIF pcTipo = '1' THEN  -- Actualizar validacurp=1 consulta exitosa renapo y se actualiza curp
		IF (pcNumCte IS NULL OR pcNumCte = '') THEN
			LET cCodRet = '00001'; --El cliente is null cuando validacurp=1
		ELSE
			UPDATE "informix".si_ctepf
			SET validaCurp= '1',curp=pcCurp
			WHERE numcte=pcNumCte;
		END IF;
		RETURN cCodRet,pcNumCte,'','','','','','','';
		
	ELIF pcTipo = '2' THEN  -- Actualizar solo validacurp=2 La curp no existe en la base de datos Renapo.
		IF (pcNumCte IS NULL OR pcNumCte = '') THEN
			LET cCodRet = '00002'; --El cliente is null cuando validacurp=2
		ELSE	
			UPDATE "informix".si_ctepf
			SET validaCurp= '2'
			WHERE numcte=pcNumCte;
		END IF;
		RETURN cCodRet, '','','','','','','','';
		
	ELIF pcTipo = '3' THEN  --Actualizar solo validacurp=3 El cliente cuenta con mas de un curp
		IF (pcNumCte IS NULL OR pcNumCte = '') THEN
			LET cCodRet = '00003'; --El cliente is null cuando validacurp=3
		ELSE

			UPDATE "informix".si_ctepf 
			SET validacurp ='3'
			WHERE numcte=pcNumCte;
		END IF;
		RETURN cCodRet,'','','','','','','','';

	ELIF pcTipo = '4' THEN  -- Actualizar registros exitosos
		IF (pcNumCte IS NULL OR pcNumCte = '' )THEN
			LET cCodRet = '00004'; --Valor de parametros nulos o no valido
		ELSE
			UPDATE "informix".si_ctepf 
			SET validacurp ='4', lugar_nac = pcEntidad
			WHERE numcte=pcNumCte;
		END IF;
		RETURN cCodRet,pcNumCte,'','','','','','','';	
		
	ELIF pcTipo = '5' THEN  --Actualizar solo validacurp=5 Ocurrio un error no controlado
		IF (pcNumCte IS NULL OR pcNumCte = '') THEN
			LET cCodRet = '00005'; --El cliente is null cuando validacurp=3
		ELSE

			UPDATE "informix".si_ctepf 
			SET validacurp ='5'
			WHERE numcte=pcNumCte;
		END IF;
		RETURN cCodRet,'','','','','','','','';
		
	ELIF pcTipo = '9' THEN
		IF (pcNumCte IS NULL OR pcNumCte = '') THEN
			LET cCodRet='00010';
		ELSE

			INSERT INTO "informix".si_bitacora_renapob(numcte,fecha_insert,mensaje_resp,status,transacc)
			VALUES (pcNumCte,CURRENT,pcMensajeR,pcStatus,pcTrans);
			
		END IF;
		RETURN cCodRet,'','','','','','','','';
		
	ELSE
		LET cCodRet = '00069';	--El valor de pTipo no coincide con ninguno del sps
	RETURN cCodRet, '','','','','','','','';
	
	END IF;
END;
END PROCEDURE;