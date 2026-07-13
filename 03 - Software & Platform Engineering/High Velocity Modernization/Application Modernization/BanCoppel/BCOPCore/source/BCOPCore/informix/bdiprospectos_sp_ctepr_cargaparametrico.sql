CREATE PROCEDURE "informix".sp_ctepr_cargaparametrico(pEmpresa  CHAR(3), pTipoPersona CHAR(2))

RETURNING 		CHAR (6)	AS Cod_Ret,
			CHAR (1)	AS TipoSolicitud,
			CHAR (2)	AS TipoPersona,
			SMALLINT	AS Seccion,
			SMALLINT	AS Grupo,
			CHAR(80)	AS Descripcion,
			CHAR (1)	AS Requerido,
			CHAR (1)	AS Implicito,
			CHAR (1)	AS UtilizaRangos,
			INTEGER	AS OrdenPresentacion;


DEFINE	iSqlErr			INTEGER;
DEFINE	Cod_Ret			CHAR(6);
DEFINE	cTipoSolicitud		CHAR(1);
DEFINE	cTipoPersona		CHAR(2);
DEFINE	sSeccion			SMALLINT;
DEFINE	sGrupo			SMALLINT;
DEFINE	cDescripcion		CHAR(80);
DEFINE	cRequerido			CHAR(1);
DEFINE	cImplicito			CHAR(1);
DEFINE	cUtilizaRangos		CHAR(1);
DEFINE	iOrdenPresentacion	INTEGER;

LET	Cod_Ret = '000000';
LET	cTipoSolicitud = '';
LET	cTipoPersona = '';
LET	sSeccion = 0;
LET	sGrupo = 0;
LET	cDescripcion = '';
LET	cRequerido = '';
LET	cImplicito = '';
LET	cUtilizaRangos = '';
LET	iOrdenPresentacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET Cod_Ret = iSqlErr;
				 RETURN Cod_Ret, NVL(cTipoSolicitud,''), NVL(cTipoPersona,''), NVL(sSeccion,0), NVL(sGrupo,0), NVL(cDescripcion,''), NVL(cRequerido,''), NVL(cImplicito,''), NVL(cUtilizaRangos,''), NVL(iOrdenPresentacion,0);
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO "/respaldosbd/hugovaz/1900/sp_ctepr_cargaparametrico.out";
		--TRACE ON;

		IF (NVL(pEmpresa,'') = '' OR  NVL(pTipoPersona,'') = '') THEN
			LET Cod_Ret = '000001';
			RETURN Cod_Ret, NVL(cTipoSolicitud,''), NVL(cTipoPersona,''), NVL(sSeccion,0), NVL(sGrupo,0), NVL(cDescripcion,''), NVL(cRequerido,''), NVL(cImplicito,''), NVL(cUtilizaRangos,''), NVL(iOrdenPresentacion,0);
		END IF

		FOREACH

			SELECT DISTINCT(PC.tp_solicitud), PC.tpo_persona, PS.seccion, PG.grupo,
			PG.descripcion, PG.requerido, PG.implicito, PG.utiliza_rangos, PG.orden_presentacion
			INTO cTipoSolicitud, cTipoPersona, sSeccion, sGrupo, cDescripcion, cRequerido, cImplicito, cUtilizaRangos, iOrdenPresentacion
			FROM "informix".pr_scoring_grupo AS PG
			INNER JOIN "informix".pr_scoring_seccion AS PS ON (PG.empresa = PS.empresa AND PG.seccion = PS.seccion) 
			INNER JOIN "informix".pr_scoring_solic AS PC ON (PS.empresa = PC.empresa AND  PS.seccion = PC.seccion )
			WHERE  PC.tp_solicitud = 'T' AND PC.tpo_persona = pTipoPersona AND PC.seccion = 2 AND PG.mostrar_pantalla = '1' and PS.empresa = pEmpresa AND PG.grupo IN (4,41,6,8,9,11,21,39) ORDER BY PC.tp_solicitud, PC.tpo_persona, PS.seccion, PG.orden_presentacion

			RETURN Cod_Ret, NVL(cTipoSolicitud,''), NVL(cTipoPersona,''), NVL(sSeccion,0), NVL(sGrupo,0), NVL(cDescripcion,''), NVL(cRequerido,''), NVL(cImplicito,''), NVL(cUtilizaRangos,''), NVL(iOrdenPresentacion,0) WITH RESUME;

		END FOREACH

		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET Cod_Ret = '000002';
			RETURN Cod_Ret, NVL(cTipoSolicitud,''), NVL(cTipoPersona,''), NVL(sSeccion,0), NVL(sGrupo,0), NVL(cDescripcion,''), NVL(cRequerido,''), NVL(cImplicito,''), NVL(cUtilizaRangos,''), NVL(iOrdenPresentacion,0);

		END IF;

	END;
END PROCEDURE
