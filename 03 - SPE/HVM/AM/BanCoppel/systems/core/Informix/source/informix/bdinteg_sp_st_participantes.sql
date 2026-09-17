CREATE PROCEDURE "informix".sp_st_participantes
(
psCveSorteo			CHAR(5),
piIdElemento		INTEGER,
piTipoParticipa		INTEGER,
piValMax			INT8,
piValMin			INT8,
pdFechaIni			DATE,
pdFechaFin			DATE
)

RETURNING CHAR(5);

--****************************************************************************************************
-- DESCRIPCION: Resgistra participantes para sorteo.
-- AUTOR : Rochin Rocha Edgar Ivan
-- FECHA : 3/11/2009
-- BD: Bdinteg
-- SISTEMA : Sorteo
--****************************************************************************************************

DEFINE viSqlErr			INTEGER;
DEFINE vsCodRet			CHAR(5);

LET viSqlErr = 0;
LET vsCodRet = "";

--ET DEBUG FILE TO "/tmp/sorteo/sp_st_Participantes.out";
--TRACE ON;

BEGIN

ON EXCEPTION SET viSqlErr
	IF viSqlErr <> 0 THEN
		RETURN viSqlErr;
	END IF;
END EXCEPTION;

--Valida si no existe participante de sorteo.
IF NOT EXISTS(SELECT cve_sorteo, id_elemento, tipo_participa, val_max, val_min, f_ini, f_fin FROM bdinteg:si_participa 
			  WHERE cve_sorteo = psCveSorteo AND id_elemento = piIdElemento AND tipo_participa = piTipoParticipa)THEN
	--Inserta nuevo participante para sorteo correspondiente.
	INSERT INTO bdinteg:si_participa
	(
	cve_sorteo,
	id_elemento,
	tipo_participa,
	val_max,
	val_min,
	f_ini,
	f_fin
	)
	VALUES
	(
	psCveSorteo,
	piIdElemento,
	piTipoParticipa,
	piValMax,
	piValMin,
	pdFechaIni,
	pdFechaFin
	);
	--El participante ha sido registrado.
	LET vsCodRet = '00000';
--Valida si existe participante de sorteo.
ELSE
	--Actualiza participante modificado.
	UPDATE bdinteg:si_participa SET 
	cve_sorteo = psCveSorteo,
	id_elemento = piIdElemento,
	tipo_participa = piTipoParticipa,
	val_max = piValMax,
	val_min = piValMin,
	f_ini = pdFechaIni,
	f_fin = pdFechaFin 
	WHERE cve_sorteo = psCveSorteo AND id_elemento = piIdElemento AND tipo_participa = piTipoParticipa;
	--El participante ha sido modificado.
	LET vsCodRet = '00000';
END IF;

RETURN vsCodRet;

END
END PROCEDURE;