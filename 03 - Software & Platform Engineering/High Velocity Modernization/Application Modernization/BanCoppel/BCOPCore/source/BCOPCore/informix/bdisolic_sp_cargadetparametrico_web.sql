CREATE PROCEDURE "informix".sp_cargadetparametrico_web(pEstadoCivil CHAR (2),
                                                        v_Edad CHAR(5),
                                                        pProfesion INTEGER,
                                                        pGrupo CHAR (3), 
                                                        pSeccion CHAR (3), 
                                                        pPaginado SMALLINT)

RETURNING CHAR (5)	AS CodRet,
		CHAR (5) 	AS Grupo,
		CHAR (5)	AS Seccion,
		CHAR(80)	AS Descripcion,
		CHAR(20)	AS Orden_Presentacion;

DEFINE	iSqlErr				INTEGER;
DEFINE	cCodRet				CHAR (5);
DEFINE	cDescripcion		CHAR(80);
DEFINE 	sOrdenPresentacion 	SMALLINT;
DEFINE 	iTrabaja			INTEGER;


LET	cCodRet 			= '00000';
LET	cDescripcion 		= '';
LET sOrdenPresentacion 	= 0;
LET	iTrabaja 			= 0;

--SET DEBUG FILE TO '/informix/sp_cargadetparametrico_web.out';
--TRACE ON;

BEGIN
	
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			 RETURN cCodRet, pGrupo, pSeccion,  cDescripcion,  sOrdenPresentacion;
		END IF;
	END EXCEPTION;

    IF pGrupo IS NULL OR Trim(pGrupo) = '' THEN
       LET cCodRet = '00001';
	   RETURN cCodRet, pGrupo, pSeccion,  cDescripcion,  sOrdenPresentacion;
    END IF;

    IF pSeccion IS NULL OR Trim(pSeccion) = '' THEN
       LET cCodRet = '00001';
	   RETURN cCodRet, pGrupo, pSeccion,  cDescripcion,  sOrdenPresentacion;
    END IF;

	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
    IF pGrupo = '7' THEN
			IF TO_NUMBER(v_Edad) < 20 THEN
                IF pEstadoCivil = 'S' THEN
				    FOREACH
                            SELECT SKIP pPaginado descripcion, orden_presentacion
                            INTO cDescripcion , sOrdenPresentacion
                            FROM "informix".ss_scoring_element WHERE grupo = pGrupo AND seccion = pSeccion AND activa = '1'
                            AND elemento NOT IN ('9','12','17')
                            ORDER BY orden_presentacion
                            RETURN cCodRet, pGrupo, pSeccion,  cDescripcion,  sOrdenPresentacion WITH RESUME;
                        END FOREACH;
                  END IF  
                ELSE
                     IF pEstadoCivil = 'S' THEN
                      FOREACH
                            SELECT SKIP pPaginado descripcion, orden_presentacion
                            INTO cDescripcion , sOrdenPresentacion
                            FROM "informix".ss_scoring_element WHERE grupo = pGrupo AND seccion = pSeccion AND activa = '1'
                            AND elemento NOT IN ('12')
                            ORDER BY orden_presentacion
                            RETURN cCodRet, pGrupo, pSeccion,  cDescripcion,  sOrdenPresentacion WITH RESUME;
                        END FOREACH;
                   ELSE
                         FOREACH
                            SELECT SKIP pPaginado descripcion, orden_presentacion
                            INTO cDescripcion , sOrdenPresentacion
                            FROM "informix".ss_scoring_element WHERE grupo = pGrupo AND seccion = pSeccion AND activa = '1'
                            AND elemento NOT IN ('9','17')
                            ORDER BY orden_presentacion
                            RETURN cCodRet, pGrupo, pSeccion,  cDescripcion,  sOrdenPresentacion WITH RESUME;
                  END FOREACH;
         END IF
      END IF
END IF

	IF pGrupo = '14' AND TO_NUMBER(v_Edad) < 18 THEN
            FOREACH
					SELECT descripcion, orden_presentacion
					INTO cDescripcion, sOrdenPresentacion
					FROM "informix".ss_scoring_element
                    WHERE grupo = pGrupo 
                    AND seccion = pSeccion 
                    AND activa = '1'
					AND elemento = '3' 
					ORDER BY orden_presentacion
					RETURN cCodRet, pGrupo, pSeccion,  cDescripcion, sOrdenPresentacion WITH RESUME;
			END FOREACH;
  END IF
	
   IF pGrupo = '21' THEN 
        FOREACH
			SELECT SKIP pPaginado descripcion, orden_presentacion
			INTO cDescripcion, sOrdenPresentacion
			FROM "informix".ss_scoring_element WHERE grupo = pGrupo AND seccion = pSeccion AND activa = '1'
			ORDER BY orden_presentacion
			RETURN cCodRet, pGrupo, pSeccion,  cDescripcion, sOrdenPresentacion WITH RESUME;
			END FOREACH;
    END IF

     IF pGrupo = '22' THEN 
            FOREACH
				SELECT SKIP pPaginado descripcion, orden_presentacion
				INTO cDescripcion, sOrdenPresentacion
				FROM "informix".ss_scoring_element WHERE grupo = pGrupo AND seccion = pSeccion AND activa = '1'
				ORDER BY orden_presentacion
				RETURN cCodRet, pGrupo, pSeccion,  cDescripcion, sOrdenPresentacion WITH RESUME;
				END FOREACH;
  END IF  
		
    IF pGrupo = '38' THEN 
            FOREACH
       				SELECT SKIP pPaginado descripcion, orden_presentacion
                    INTO cDescripcion, sOrdenPresentacion
					FROM "informix".ss_scoring_element  
                    WHERE seccion = pSeccion
                    AND grupo = pGrupo
                    AND activa  = '1'
                     AND elemento NOT IN(SELECT elemento 
                                         FROM ss_gpo_cte_doc  
                                         WHERE grupo = pGrupo
                                         AND activo = '1'
                                         AND gpo_excluyente = pGrupo) 
                        ORDER BY orden_presentacion
                     RETURN cCodRet, pGrupo, pSeccion,  cDescripcion, sOrdenPresentacion WITH RESUME;
                END FOREACH;
    END IF
	
    IF pGrupo = '39' THEN 
            FOREACH
        	    	SELECT SKIP pPaginado descripcion, orden_presentacion
                    INTO cDescripcion, sOrdenPresentacion
				    FROM "informix".ss_scoring_element  
                    WHERE seccion = pSeccion
                    AND grupo = pGrupo
                    AND activa  = '1'
                    ORDER BY orden_presentacion
                    RETURN cCodRet, pGrupo, pSeccion,  cDescripcion, sOrdenPresentacion WITH RESUME;
                END FOREACH;
    END IF
        
    IF pGrupo = '2' OR pGrupo = '3' OR pGrupo = '5' OR pGrupo = '10' OR pGrupo = '16' THEN 
           FOREACH               
                    SELECT SKIP pPaginado descripcion , orden_presentacion
                    INTO cDescripcion, sOrdenPresentacion                
                    FROM "informix".ss_scoring_element 
                    WHERE seccion = pSeccion AND grupo = pGrupo AND activa = '1'
                    ORDER BY orden_presentacion
                    RETURN cCodRet, pGrupo, pSeccion, cDescripcion, sOrdenPresentacion WITH RESUME;
        END FOREACH;
   END IF
END;
END PROCEDURE;