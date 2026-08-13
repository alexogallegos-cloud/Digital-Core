CREATE PROCEDURE "informix".sp_cargaparametrico_web(pEmpresa  CHAR(3), pTipoPersona CHAR(2), pTipoCte CHAR(2))

RETURNING 	CHAR (5)	AS Cod_Ret,
			CHAR (1)	AS TipoSolicitud,
			CHAR (2)	AS TipoPersona,
			CHAR (2)	AS Seccion,
			CHAR (2)	AS Grupo,
			CHAR(80)	AS Descripcion,
			CHAR (1)	AS Requerido,
			CHAR (1)	AS Implicito,
			CHAR (1)	AS UtilizaRangos,
			INTEGER	AS OrdenPresentacion;


DEFINE	iSqlErr             INTEGER;
DEFINE	Cod_Ret             CHAR(5);
DEFINE	cTipoSolicitud		CHAR(1);
DEFINE	cTipoPersona		CHAR(2);
DEFINE	sSeccion			CHAR(2);
DEFINE	sGrupo              CHAR(2);
DEFINE	cDescripcion		CHAR(80);
DEFINE	cRequerido			CHAR(1);
DEFINE	cImplicito			CHAR(1);
DEFINE	cUtilizaRangos		CHAR(1);
DEFINE	iOrdenPresentacion	INTEGER;

LET	Cod_Ret                = '00000';
LET	cTipoSolicitud         = '';
LET	cTipoPersona           = '';
LET	sSeccion               = '';
LET	sGrupo                 = '';
LET	cDescripcion           = '';
LET	cRequerido             = '';
LET	cImplicito             = '';
LET	cUtilizaRangos         = '';
LET	iOrdenPresentacion     = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET Cod_Ret = iSqlErr;
				 RETURN Cod_Ret, NVL(cTipoSolicitud,''), NVL(cTipoPersona,''), NVL(sSeccion,''), NVL(sGrupo,''), NVL(cDescripcion,''), NVL(cRequerido,''), NVL(cImplicito,''), NVL(cUtilizaRangos,''), NVL(iOrdenPresentacion,0);
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF (NVL(pEmpresa,'') = '' OR  NVL(pTipoPersona,'') = '') THEN
			LET Cod_Ret = '00001';
			RETURN Cod_Ret, NVL(cTipoSolicitud,''), NVL(cTipoPersona,''), NVL(sSeccion,''), NVL(sGrupo,''), NVL(cDescripcion,''), NVL(cRequerido,''), NVL(cImplicito,''), NVL(cUtilizaRangos,''), NVL(iOrdenPresentacion,0);
		END IF

		FOREACH

			SELECT DISTINCT(PC.tp_solicitud), PC.tpo_persona, PS.seccion, PG.grupo,
			PG.descripcion, PG.requerido, PG.implicito, PG.utiliza_rangos, PG.orden_presentacion
			INTO cTipoSolicitud, cTipoPersona, sSeccion, sGrupo, cDescripcion, cRequerido, cImplicito, cUtilizaRangos, iOrdenPresentacion
			FROM ss_scoring_grupo AS PG
			INNER JOIN ss_scoring_seccion AS PS ON (PG.empresa = PS.empresa AND PG.seccion = PS.seccion) 
			INNER JOIN ss_scoring_solic AS PC ON (PS.empresa = PC.empresa AND  PS.seccion = PC.seccion )
			WHERE  PC.tp_solicitud = 'T' AND PC.tpo_persona = pTipoPersona AND PC.seccion = 2 AND PG.mostrar_pantalla = '1' and PS.empresa = pEmpresa ORDER BY PC.tp_solicitud, PC.tpo_persona, PS.seccion, PG.orden_presentacion

			RETURN Cod_Ret, NVL(cTipoSolicitud,''), NVL(cTipoPersona,''), NVL(sSeccion,''), NVL(sGrupo,''), NVL(cDescripcion,''), NVL(cRequerido,''), NVL(cImplicito,''), NVL(cUtilizaRangos,''), NVL(iOrdenPresentacion,0) WITH RESUME;

		END FOREACH

		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET Cod_Ret = '00002';
			RETURN Cod_Ret, NVL(cTipoSolicitud,''), NVL(cTipoPersona,''), NVL(sSeccion,''), NVL(sGrupo,''), NVL(cDescripcion,''), NVL(cRequerido,''), NVL(cImplicito,''), NVL(cUtilizaRangos,''), NVL(iOrdenPresentacion,0);

		END IF;

	END;
END PROCEDURE;