CREATE PROCEDURE "informix".sp_ctepr_validavigencia()
RETURNING CHAR(6) AS CodRet;

---DECLARACIONES
DEFINE iSqlErr			INTEGER;
DEFINE iIsamErr			INTEGER;
DEFINE cCod_ret			CHAR(6);
DEFINE cNumcte_pros		CHAR(20);
DEFINE cStatus_cte		CHAR(2);
DEFINE dFecha_Ent		DATE;
DEFINE dFecha_Hoy		DATE;
DEFINE sDias_Vig		SMALLINT;
DEFINE cStatus_Fin		CHAR(2);
DEFINE cCausa_Pros		CHAR(3);
DEFINE cComentario		CHAR(100);
DEFINE cEjecutivo		CHAR(8);
DEFINE cCod_ret2		CHAR(6);

LET iSqlErr			= 0;
LET iIsamErr		= 0;
LET cCod_ret		= '000000';
LET cNumcte_pros	= "";
LET cStatus_cte		= "";
LET dFecha_Ent		=DATE(1);
LET dFecha_Hoy		=DATE(1);
LET sDias_Vig		= 0;
LET cStatus_Fin		= "";
LET cCausa_Pros		= "";
LET cComentario		= "";
LET cEjecutivo		= "";
LET cCod_ret2		= "";


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
       IF iSqlErr != 0 THEN
          LET cCod_ret = iSqlErr;
          RETURN cCod_ret;
       END IF;
    END EXCEPTION;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
	--SET DEBUG FILE TO "/respaldosbd/josue/sp_ctepr_validavigencia.out";
	--TRACE ON;
	
	--SE OBTIENE LA FECHA DE EL DIA
	SELECT fecha_hoy
	INTO dFecha_Hoy
	FROM bdinteg: "informix".si_fechas;

	FOREACH WITH HOLD
		-- SE OBTIENE EL CLIENTE, ESTATUS Y DIAS DE VIGENCIA QUE CUENTE CON UN ESTATUS DE pr_vigencia_sol_productos
		SELECT a.numcte_pros,a.status_numcte_pros
		INTO cNumcte_pros,cStatus_cte
		FROM "informix".pr_cliente a
		INNER JOIN "informix".pr_vigencia_sol_productos b ON (a.status_numcte_pros = b.status_prospecto)
		
		-- SI NO EXISTEN DATOS SE TERMINA EL CICLO Y SE TERMINA EL PRODECIMIENTO
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCod_ret = "000001";
			RETURN cCod_ret;
		ELSE
		
			-- SE OBTIENE EL TOTAL DE DIAS DE VIGENCIA MÁXIMO PARA UN CLIENTE EN ESE ESTATUS
			SELECT dias_vigencia 
			INTO sDias_Vig
			FROM  "informix".pr_vigencia_sol_productos 
			WHERE status_prospecto = cStatus_cte;
			
			-- SI EL ESTATUS CUANTA CON DIAS DE VIGENCIA SE OBTENDRAN LOS DATOS PARA CANCELAR EL CLIENTE
			IF NVL(sDias_Vig,0) > 0 THEN
				--SE OBTIENE LA FECHA EN QUE ENTRÓ EN ESE ESTATUS EL CLIENTE Y EL EJECUTIVO QUE REALIZÓ EL REGISTRO
				SELECT fecha_entrada,ejecutivo_auto
				INTO dFecha_Ent,cEjecutivo
				FROM  "informix".pr_autorizacion 
				WHERE num_solicitud = cNumcte_pros
				AND status_solicitud = cStatus_cte
				AND fecha_entrada =	(SELECT MAX(fecha_entrada) 
									FROM "informix".pr_autorizacion 
									WHERE num_solicitud = cNumcte_pros 
									AND status_solicitud = cStatus_cte);
				
				-- SI LA FECHA ACTUAL ES MAYOR O IGUAL A LA FECHA DE ENTRADA A ESE ESTATUS MÁS LOS DÍAS DE VIGENCIA
				IF dFecha_Hoy > (dFecha_Ent + sDias_Vig) THEN
					-- SE OBTIENE EL ESTATUS,CAUSA Y EL POR QUE DE EL CAMBIO DE ESTATUS DE EL CLIENTE PROSPECTO
					SELECT status_prospecto_final, causa_prospecto,descripcion
					INTO cStatus_Fin, cCausa_Pros, cComentario
					FROM  "informix".pr_vigencia_sol_productos 
					WHERE status_prospecto = cStatus_cte;
					
					-- SE CAMBIA EL ESTATUS DENTRO DE pr_autorizacion Y pr_cliente, SE REUTILIZA PRODECIMIENTO 
					EXECUTE PROCEDURE "informix".sp_ctepr_actualizastatus(cEjecutivo, cNumcte_pros,cStatus_Fin,cCausa_Pros,cComentario)
					INTO cCod_ret2;
					
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN
						LET cCod_ret = "000001";
					ELSE
						IF cCod_ret2 <> "000000"THEN
							LET cCod_ret = cCod_ret2;
						END IF;
					END IF;
				END IF;	
			ELSE
				-- SI EL ESTATUS DE EL CLIENTE NO EXISTE EN EL CATÁLAGO DE VIGENCIA SE PASA AL SIGUIENTE REGISTRO
				CONTINUE FOREACH;
			END IF;
		END IF;	
	END FOREACH
	
	RETURN cCod_ret;
END
END PROCEDURE
