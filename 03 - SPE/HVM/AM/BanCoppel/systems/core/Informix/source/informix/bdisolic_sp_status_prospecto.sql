CREATE PROCEDURE "informix".sp_status_prospecto()
REFERENCING NEW AS n FOR ss_autorizacion;

--DECLARACION DE VARIABLES--
DEFINE iSql_err		    INTEGER;
DEFINE cCodret		    CHAR(6); --SE DEJA LA VARIABLE ES DE UTILIDAD PARA EL DEBUG.
DEFINE cStatus_Cte		CHAR(2);

--INICIALIZACION DE VARIABLES--
LET iSql_err		     = 0;
LET cCodret		         = '000000';
LET cStatus_Cte          = '';

BEGIN

	--CONTROL DE ERRORES
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodret = iSql_err;
			RETURN ;
		END IF;
	END EXCEPTION;

	
	--SET DEBUG FILE TO '/pisa/pisabanco/sp_status_prospecto.out';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	--SE VERIFICA SI EL num_solicitud o numcte EXISTE EN LAS TABLAS


	IF EXISTS(SELECT a.numcte FROM bdisolic:'informix'.ss_solicitudes a
		JOIN bdiprospectos:'informix'.pr_cliente b ON a.numcte = b.numcte
		JOIN bdiprospectos:'informix'.pr_autorizacion c ON b.numcte_pros = c.num_solicitud
		WHERE a.num_solicitud = n.num_solicitud
		AND c.status_solicitud = n.status_solicitud) THEN

		IF EXISTS(SELECT a.numcte
		FROM bdisolic:'informix'.ss_solicitudes a
		JOIN bdiprospectos:'informix'.pr_cliente b ON a.numcte = b.numcte
		WHERE a.num_solicitud = n.num_solicitud
		AND b.status_numcte_pros NOT IN ('CM','RT','CN')) THEN
			IF (SELECT COUNT(num_solicitud) FROM bdisolic: ss_autorizacion where num_solicitud = n.num_solicitud AND status_solicitud = n.status_solicitud) > 1 THEN
			--IF EXISTS(SELECT num_solicitud FROM bdisolic: ss_autorizacion where num_solicitud = n.num_solicitud AND status_solicitud = 'OA') THEN
				LET n.cliente_pros = '1';
			ELSE
                IF (EXISTS(SELECT num_solicitud FROM bdisolic: ss_autorizacion where num_solicitud = n.num_solicitud AND status_solicitud = 'OA'))
					AND (n.status_solicitud in ('EE','OS')) THEN
                    LET n.cliente_pros = '1';
                ELSE
                    LET n.cliente_pros = '2';
				END IF;
			END IF;
		END IF;
		RETURN;

	ELIF EXISTS(SELECT a.numcte FROM bdisolic:'informix'.ss_solicitudes a
			JOIN bdiprospectos:'informix'.pr_cliente b ON a.numcte = b.numcte
			WHERE a.num_solicitud = n.num_solicitud) THEN

			IF EXISTS( SELECT a.numcte
			FROM bdisolic:'informix'.ss_solicitudes a
			JOIN bdiprospectos:'informix'.pr_cliente b ON a.numcte = b.numcte
			WHERE a.num_solicitud = n.num_solicitud
			AND b.status_numcte_pros NOT IN ('CM','RT','CN')) THEN
				LET n.cliente_pros = '1';
			END IF;
			RETURN;

	END IF;
   RETURN;
END;
END PROCEDURE
