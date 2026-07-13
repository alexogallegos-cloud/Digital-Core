CREATE PROCEDURE "informix".sp_cargadatostpconsultarrepsuptel(pcEmpresa CHAR(3),pcOpcion CHAR(2))
RETURNING CHAR(6),VARCHAR(4),VARCHAR(250,1);
-------------------------------------------------------
-- Opciones para la ejecución del procedimiento: 
--      01 - Estado
--      02 - Ciudad
--      03 - Región Cobranza
--      04 - Sucursal
--      05 - Productos de Crédito
-------------------------------------------------------
--Declaracion de variables
DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(6);
DEFINE cDescripcion VARCHAR(200,1);
DEFINE cElemento VARCHAR(4);
-- Iniciacion de variables
LET iSqlErr = 0;
LET cCodRet = '000000';
LET cDescripcion = '';
LET cElemento = "";

BEGIN
	-- Manejador de errores
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet= iSqlErr;
			RETURN cCodRet,cElemento,cDescripcion;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/sp_cargadatostpconsultarrepsuptel.txt";
	--TRACE ON;

	-- Valida que los parametros sean correctos
	IF NVL(pcEmpresa,'') = '' OR NVL(pcOpcion,'') = '' THEN
		LET cCodRet = '000001';
	END IF;

	IF pcOpcion NOT IN ('01','02','03','04','05') THEN
		LET cCodRet = '000002';
	END IF;
	-- Elige la opcion a consultar
	IF cCodRet <> '000000' THEN
		RETURN cCodRet,cElemento,cDescripcion;
	ELSE
		IF pcOpcion = "01" THEN
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			FOREACH WITH HOLD
				SELECT estado, nombre 
				INTO cElemento,cDescripcion              
				FROM bdinteg:"informix".si_estados
				ORDER BY estado
				RETURN cCodRet,cElemento,cDescripcion WITH RESUME;
			END FOREACH;
		ELIF pcOpcion = "02" THEN
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			FOREACH WITH HOLD
				SELECT cd.ciudad, TRIM(cd.nombre)||' ('|| TRIM(edo.nombre) ||' ' ||TRIM(cd.estado) ||')'
				INTO cElemento,cDescripcion
				FROM bdinteg:"informix".si_ciudades cd,bdinteg:"informix".si_estados edo
				WHERE cd.pais = edo.pais
				AND cd.estado = edo.estado
				ORDER BY cd.nombre
				RETURN cCodRet,cElemento,cDescripcion WITH RESUME;
			END FOREACH;
		ELIF pcOpcion = "03" THEN
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			FOREACH WITH HOLD
				SELECT numero_region, nombre_region
				INTO cElemento, cDescripcion
				FROM bdinteg:"informix".si_regiones
				ORDER BY numero_region
				RETURN cCodRet,cElemento,cDescripcion WITH RESUME;           
			END FOREACH;
		ELIF pcOpcion = "04" THEN
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			FOREACH WITH HOLD
				SELECT sucursal, nombre
				INTO cElemento, cDescripcion              
				FROM bdinteg:"informix".si_sucursales
				WHERE empresa = pcEmpresa
				AND tpo_sucursal = 'S' 
				ORDER BY sucursal
				RETURN cCodRet,cElemento,cDescripcion WITH RESUME;
			END FOREACH;
		ELIF pcOpcion = "05" THEN
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			FOREACH WITH HOLD
				SELECT abrevia_prod,descrip_prod
				INTO cElemento,cDescripcion              
				FROM bdicred:"informix".sd_tipprod
				WHERE empresa = pcEmpresa
				AND cod_prod IN ("T","P")
				ORDER BY abrevia_prod
				RETURN cCodRet,cElemento,cDescripcion WITH RESUME;
			END FOREACH;
		END IF;
	END IF;
END
END PROCEDURE
