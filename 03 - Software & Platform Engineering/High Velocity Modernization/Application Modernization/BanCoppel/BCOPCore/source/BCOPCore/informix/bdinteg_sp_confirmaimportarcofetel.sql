CREATE PROCEDURE "informix".sp_confirmaimportarcofetel()
RETURNING CHAR(5)

------------------------------------------------------------
-- REALIZO: Mohamed Carreón
-- FECHA:      2009-02-14
--FUNCION: Carga el archivo de la COFETEL a
--                    la tabla  si_cattelefonos
-------------------------------------------------------------

--Definición de variables
DEFINE cCodret CHAR(5) ;
DEFINE iSqlErr INTEGER ;
DEFINE cSql CHAR(200);

--Inicializaciòn de variables
LET cCodret ='000';
LET iSqlErr = 0;
LET cSql = '';

--	SET DEBUG FILE TO "/tmp/has/sp_ConfirmaImportarCofetel.out";
--	TRACE ON;

BEGIN

ON EXCEPTION SET iSqlErr
    IF iSqlErr <> 0 THEN
        LET cCodret = iSqlErr;
        RETURN cCodret;
    END IF;
END EXCEPTION;

    DELETE FROM bdinteg:si_cattelefono;

	INSERT INTO bdinteg: si_cattelefono(clavecensal, poblacion, municipio, estado, presuscripcion, region, asl, nir, serie, numeracion_inicial, numeracion_final, ocupacion, tipored, modalidad, razonsocial, fecha_asignacion, fecha_consolidacion, fecha_migracion, nir_anterior)
	SELECT clavecensal, poblacion, municipio, estado, presuscripcion, region, asl, nir, serie, numeracion_inicial, numeracion_final, ocupacion, tipored, modalidad, razonsocial, fecha_asignacion, fecha_consolidacion, fecha_migracion, nir_anterior  
	FROM bdinteg: tmp_si_cattelefono;

RETURN cCodret;

END;
END PROCEDURE;