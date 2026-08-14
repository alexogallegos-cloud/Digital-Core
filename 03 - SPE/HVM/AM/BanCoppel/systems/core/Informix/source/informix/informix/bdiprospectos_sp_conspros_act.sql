CREATE PROCEDURE "informix".sp_conspros_act(pId_Act CHAR(2), pId_SubAct CHAR(2))

RETURNING
	CHAR (6)  AS cCodRet,
	CHAR (80) AS Actividad,
	CHAR (80) AS Subactividad;

DEFINE cCodRet	      CHAR (6);
DEFINE iSqlErr 		  INTEGER;
DEFINE cDescripAct	  CHAR (80);
DEFINE cDescripSubAct CHAR (80);


LET cCodRet = '000002'; --INICIALIZADO CON BANDERA DE ERROR POR SI NO ENTRA AL SP CORRECTAMENTE.
LET iSqlErr = 0;
LET cDescripAct = '';
LET cDescripSubAct = '';

BEGIN
		-- ERRORES DE INFORMIX
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cDescripAct, cDescripSubAct;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO '/respaldosbd/antoniocebreros/1468/sp_conspros_act.out';
		--TRACE ON;

		 SET ISOLATION TO DIRTY READ;
		 SET LOCK MODE TO WAIT 3;

		 --VALIDAMOS QUE LOS PARAMETROS NO VENGAN NULOS
		IF NVL(pId_Act, '') = '' OR NVL(pId_SubAct, '') = '' THEN
			RETURN cCodRet, cDescripAct, cDescripSubAct;
		ELSE
			 --El procedimiento bdiprospectos:"informix".sp_conspros_ing retorna los datos de ingresos del cliente prospecto de la tabla pr_ingresos de dicha base de datos.
			 --El sp_conspros_ing solo retorna los id de la subactividad, no de la actividad.
			 --Obtenemos la descripcion de la subactividad del cliente.

			 SELECT descrip
			INTO cDescripAct
			FROM bdinteg:"informix".si_actsubact WHERE id_act = pId_Act AND id_subact = 0;
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodret = '000001'; --NO HAY RESULTADOS PARA LA CONSULTA.
					RETURN cCodRet, cDescripAct, cDescripSubAct;
				END IF;

			 SELECT descrip
			 INTO cDescripSubAct
			 FROM bdinteg:"informix".si_actsubact WHERE id_act = pId_Act AND id_subact = pId_SubAct;
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodret = '000001'; --NO HAY RESULTADOS PARA LA CONSULTA.
					RETURN cCodRet, cDescripAct, cDescripSubAct;
				END IF;

			----Obtenemos la descripcion de la actividad del cliente.

			LET cCodRet = '000000';
			RETURN cCodRet, cDescripAct, cDescripSubAct;
		END IF;

END
END PROCEDURE
