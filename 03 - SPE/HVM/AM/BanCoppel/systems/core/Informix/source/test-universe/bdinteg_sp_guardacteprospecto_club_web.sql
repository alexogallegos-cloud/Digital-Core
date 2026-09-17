CREATE PROCEDURE "informix".sp_guardacteprospecto_club_web
(
	pEmpresa 			CHAR(03),
	pCteBanCpl			CHAR(20),
	pCteCplTitular		CHAR(20),
	pCteCplProspecto	CHAR(20)
)

	RETURNING
	CHAR(05) AS cCodRet

	--VARIABLES
	DEFINE vcCodRet		CHAR(05);
	DEFINE vcCteBanCpl	CHAR(20);
	DEFINE iSql_err		INTEGER;

	--INICIALIZACIÃ?N
	LET vcCodRet	= '00000';
	LET vcCteBanCpl	= '';
	LET iSql_err 	= 0;

	--SET DEBUG FILE TO '/respaldosbd/Ernesto/out/sp_guardacteprospecto_club_out.sql';
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET vcCodRet = iSql_err;
				RETURN vcCodRet;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 4;
		
		--VALIDAR PARAMETROS VACIOS Y NULOS
		IF NVL(TRIM(pEmpresa), '') = '' OR NVL(TRIM(pCteBanCpl), '') = '' OR NVL(TRIM(pCteCplTitular), '') = '' THEN
			LET vcCodRet = '00001';
			RETURN vcCodRet;
		END IF;
		
		--BUSQUEDA DE DATOS
		SELECT ctebancpl
		INTO vcCteBanCpl
		FROM "informix".si_club_hiscteprospecto
		WHERE empresa = pEmpresa AND ctebancpl = pCteBanCpl;
		
		--SI NO REGRESA DATOS
		--IF DBINFO("sqlca.sqlerrd2") = 1 THEN
		IF TRIM(vcCteBanCpl) = '' OR vcCteBanCpl IS NULL THEN
			INSERT INTO "informix".si_club_hiscteprospecto(empresa, ctebancpl, ctecpltitular, ctecplprospecto)
			VALUES (pEmpresa, pCteBanCpl, pCteCplTitular, pCteCplProspecto);
			RETURN vcCodRet;
		ELSE
			LET vcCodRet = '00002';
			RETURN vcCodRet;
		END IF;
	END;
END PROCEDURE
DOCUMENT
'Folio:			1630',
'Autor: 		95579737 - JosÃ© Ernesto Raygoza Villa',
'Fecha: 		08/08/2014',
'Sustento:		Anexo al RQM 10 297 Venta de Club de Proteccion Coppel en BanCoppel',
'Solicita		Rodolfo Gomez',
'Descripcion:	Guarda la relacion del cliente bancoppel con el clinente Coppel titular y prospecto',
'BD: 			bdinteg';

CREATE PROCEDURE "informix".sp_guardarhistcomphuellas_web(p_sNoEmpleado CHAR(8), p_sSucursal CHAR(4), p_sNoCteBancoppel CHAR(20), p_sTipoProducto CHAR(4))
RETURNING	 VARCHAR(5) --Codigo de Retorno

	DEFINE iSqlErr			INTEGER;

	-----------------------------------------------------------------------------------------------------
	-- AUTOR: Erick Zamora
	-- FECHA: 13-03-2009
	-- Guarda en la tabla bdinteg:si_histcomhuellas los datos los empleados que hayan 
	--	validado un cliente con su propia huella
	-- SET DEBUG FILE TO "/tmp/sp_guardarhistcomphuellas.out;
	-- TRACE ON;
	------------------------------------------------------------------------------------------------------
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr;
			END IF;
		END EXCEPTION;
				
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		INSERT INTO bdinteg:si_histcomphuellas VALUES(p_sNoEmpleado, p_sSucursal, CURRENT, LPAD(TRIM(p_sNoCteBancoppel),9,'0'), p_sTipoProducto);
		RETURN '00000';
	END
END PROCEDURE;