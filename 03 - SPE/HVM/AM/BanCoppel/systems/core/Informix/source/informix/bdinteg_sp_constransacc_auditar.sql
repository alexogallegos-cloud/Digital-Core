CREATE PROCEDURE "informix".sp_constransacc_auditar(pTipo INTEGER, pEmpresa CHAR(3), pCodigo CHAR(4))
	
	RETURNING CHAR(5)   AS CodRetorno, 
			  CHAR(10)  AS Codigo,
			  CHAR(40)  AS Descripcion,
			  CHAR(300) AS NumTran;

--Definicion de Variables
DEFINE iSqlErr 		INTEGER;
DEFINE cCodRet 		CHAR(5);
DEFINE cCodigo 		CHAR(4);
DEFINE cDescripcion CHAR(40);
DEFINE cNumTran 	CHAR(300);
DEFINE iContador 	INTEGER;
DEFINE cCodTran 	CHAR(4);
DEFINE cReporte 	CHAR(4);


--Inicializacion de Variables
LET iSqlErr 	 = 0;
LET cCodRet 	 = '00000';
LET cCodigo 	 = '';
LET cDescripcion = '';
LET cNumTran 	 = '';
LET iContador 	 = 1;
LET cCodTran 	 = '';
LET cReporte 	 = '';


--SET DEBUG FILE TO '/home/tmp/leonardo/sp_ctes_modif.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCodigo, cDescripcion, cNumTran;
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF (pTipo = 0 OR pTipo > 2 OR pTipo IS NULL OR NVL (pTipo,'')= '') THEN
		LET cCodRet = '00001';	--El tipo de transaccion no existe	
		RETURN cCodRet, cCodigo, cDescripcion, cNumTran;
	ELSE
		--Consulta transacciones padres
		IF pTipo = 1 THEN
			IF (pEmpresa IS NULL OR NVL (pEmpresa,'')='' OR pEmpresa = '000') THEN
				LET cCodRet = '00002'; --Se introdujo un campo nulo o vacio
				
				RETURN cCodRet, cCodigo, cDescripcion, cNumTran;
			ELSE
				FOREACH 
					SELECT codigo, descripcion, reporte
					INTO cCodigo,cDescripcion,cReporte
					FROM bdinteg:"informix".si_transacciones_auditar
					WHERE empresa = pEmpresa
					
					
					RETURN cCodRet, cCodigo||cReporte , cDescripcion, cNumTran WITH RESUME;
				END FOREACH;								
			END IF;
		--Consulta transacciones hijas
		ELIF pTipo = 2 THEN
			IF (pEmpresa IS NULL OR NVL (pEmpresa,'')='' OR pEmpresa = '000') 
			OR (pCodigo IS NULL OR NVL (pCodigo,'')='' OR pCodigo = '0000') THEN
				LET cCodRet = '00003';	--Se introdujo un campo nulo o vacio

				RETURN cCodRet, cCodigo, cDescripcion, cNumTran;
			ELSE		
				FOREACH
					SELECT transaccion
					INTO cCodTran
					FROM bdinteg:"informix".si_transacciones_auditar_det
					WHERE empresa = pEmpresa 
					AND codigo = pCodigo
					
					IF iContador = 1 THEN
						LET	cNumTran = ''||TRIM(cCodTran)||'';
					ELSE
						LET cNumTran = ''||TRIM(cCodTran)||''||','||TRIM(cNumTran);						
					END IF;
					LET iContador = iContador + 1;					
				END FOREACH;				
				RETURN cCodRet, TRIM(cCodigo), TRIM(cDescripcion), TRIM(cNumTran);
			END IF;
		END IF;			
	END IF;	
END;

END PROCEDURE
DOCUMENT
'Folio: 1559',
'Autor: 93111207',
'Fecha: 22/10/2013',
'Modificación: Se realizó SP para Transacciones',
'Sustento: RQM 12 023-Consulta de Transacciones.doc (Página 6)',
'Solicita: Norberto Corona Berruecos',
'BD: BDINTEG',
'Folio: 1610',
'Autor: 95594213 Leonardo Plata',
'Fecha: 11/06/2014',
'Modificación: Se modifico sp para retornar en tipo 1 el reporte conncatenado con el codigo',
'Sustento: RQM 12 023-Consulta de Transacciones.doc (Página 6)',
'Solicita: Norberto Corona Berruecos',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_graba_logdesfusion(cProceso CHAR(50), cTabla CHAR(30),cClienteTit CHAR(20),cClienteTras CHAR(20),cDetalle_mov CHAR(200),cUsuario_insert CHAR(8))
RETURNING CHAR(6);

DEFINE iSql_err			INTEGER;
DEFINE cRetorno	CHAR(6);
LET cRetorno = '000000';
BEGIN
	--CONTROL DE ERRORES--
	ON EXCEPTION SET iSql_err 
		IF iSql_err <> 0 THEN
			LET cRetorno = iSql_err;
			RETURN cRetorno;
		END IF;
	END EXCEPTION;
	
	INSERT INTO "informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
	VALUES (cProceso,cTabla,cClienteTit,cClienteTras,cDetalle_mov,CURRENT HOUR TO FRACTION(4),cUsuario_insert,CURRENT::DATE);
	
	RETURN cRetorno;
END
END PROCEDURE;