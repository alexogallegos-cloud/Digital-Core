CREATE PROCEDURE "informix".actualiza_institucion2()

RETURNING CHAR(5);

DEFINE scod_ret               CHAR(5);
DEFINE vsqlerr                INTEGER;
DEFINE csolicitud             CHAR(20);
DEFINE ccontador              INTEGER;

LET scod_ret     = "000";
LET vsqlerr      = 0;
LET ccontador    = 1;


BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret;
   END IF;
END EXCEPTION;

-- SET DEBUG FILE TO "actualiza_institucion.out";
-- TRACE ON;

   FOREACH WITH HOLD 
         select num_solicitud 
         into csolicitud
         from br_traslado 
         where institucion is null

        IF ccontador=1 then
          BEGIN WORK;
        END IF;
         
         update br_traslado set institucion = 'CC' where num_solicitud=csolicitud;

         IF ccontador>=70000 THEN
            COMMIT WORK;
            ---update statistics medium for table bdiburo:br_traslado;
            LET ccontador=1;
         ELSE
            LET ccontador=ccontador+1;
         END IF;

    END FOREACH; 

  IF ccontador > 1 THEN
        COMMIT WORK; 
  END IF;

    LET ccontador = 1;


    FOREACH WITH HOLD 
         select num_solicitud 
         into csolicitud
         from sb_regreso 
         where institucion is null

        IF ccontador=1 then
          BEGIN WORK;
        END IF;
         
         update sb_regreso set institucion = 'CC' where num_solicitud=csolicitud;

         IF ccontador>=70000 THEN
            COMMIT WORK;
            ---update statistics medium for table bdiburo:sb_regreso;
            LET ccontador=1;
         ELSE
            LET ccontador=ccontador+1;
         END IF;

    END FOREACH;  

          IF ccontador > 1 THEN
                COMMIT WORK; 
          END IF;

            LET ccontador = 1;


    FOREACH WITH HOLD 
         select solicitud 
         into csolicitud
         from br_auditor 
         where institucion is null


        IF ccontador=1 then
          BEGIN WORK;
        END IF;
         
         update br_auditor set institucion = 'CC' where solicitud=csolicitud;

         IF ccontador>=70000 THEN
            COMMIT WORK;
            ---update statistics medium for table bdiburo:br_auditor;
            LET ccontador=1;
         ELSE
            LET ccontador=ccontador+1;
         END IF;

    END FOREACH;  

          IF ccontador > 1 THEN
                COMMIT WORK; 
          END IF;

            LET ccontador = 1;

--- FOREACH WITH HOLD 
---      select num_cliente 
---      into csolicitud
---      from br_cadena_error 
---      where institucion is null
---
---     IF ccontador=1 then
---       BEGIN WORK;
---     END IF;
---      
---      update br_cadena_error set institucion = 'CC' where num_cliente=csolicitud;
---
---      IF ccontador>=70000 THEN
---         COMMIT WORK;
            ---update statistics medium for table bdiburo:br_cadena_error;
---         LET ccontador=1;
---      ELSE
---         LET ccontador=ccontador+1;
---      END IF;
---
--- END FOREACH;  
---
---       IF ccontador > 1 THEN
---             COMMIT WORK; 
---       END IF;
---
---         LET ccontador = 1;

    FOREACH WITH HOLD 
         select num_cliente 
         into csolicitud
         from br_iq 
         where institucion is null

        IF ccontador=1 then
          BEGIN WORK;
        END IF;
         
         update br_iq set institucion = 'CC' where num_cliente=csolicitud;

         IF ccontador>=70000 THEN
            COMMIT WORK;
            ---update statistics medium for table bdiburo:br_iq;
            LET ccontador=1;
         ELSE
            LET ccontador=ccontador+1;
         END IF;

    END FOREACH;  

          IF ccontador > 1 THEN
                COMMIT WORK; 
          END IF;

            LET ccontador = 1;

    FOREACH WITH HOLD 
         select num_cliente 
         into csolicitud
         from br_pa 
         where institucion is null

        IF ccontador=1 then
          BEGIN WORK;
        END IF;
         
         update br_pa set institucion = 'CC' where num_cliente=csolicitud;

         IF ccontador>=70000 THEN
            COMMIT WORK;
            ---update statistics medium for table bdiburo:br_pa;
            LET ccontador=1;
         ELSE
            LET ccontador=ccontador+1;
         END IF;

    END FOREACH;  

          IF ccontador > 1 THEN
                COMMIT WORK; 
          END IF;

            LET ccontador = 1;


    FOREACH WITH HOLD 
         select num_cliente 
         into csolicitud
         from br_pe 
         where institucion is null

        IF ccontador=1 then
          BEGIN WORK;
        END IF;
         
         update br_pe set institucion = 'CC' where num_cliente=csolicitud;

         IF ccontador>=70000 THEN
            COMMIT WORK;
            ---update statistics medium for table bdiburo:br_pe;
            LET ccontador=1;
         ELSE
            LET ccontador=ccontador+1;
         END IF;

    END FOREACH;  

          IF ccontador > 1 THEN
                COMMIT WORK; 
          END IF;

            LET ccontador = 1;

    FOREACH WITH HOLD 
         select num_cliente 
         into csolicitud
         from br_pn 
         where institucion is null

        IF ccontador=1 then
          BEGIN WORK;
        END IF;
         
         update br_pn set institucion = 'CC' where num_cliente=csolicitud;

         IF ccontador>=70000 THEN
            COMMIT WORK;
            ---update statistics medium for table bdiburo:br_pn;
            LET ccontador=1;
         ELSE
            LET ccontador=ccontador+1;
         END IF;

    END FOREACH;  

          IF ccontador > 1 THEN
                COMMIT WORK; 
          END IF;

            LET ccontador = 1;

    FOREACH WITH HOLD 
         select num_cliente 
         into csolicitud
         from br_tl 
         where institucion is null

        IF ccontador=1 then
          BEGIN WORK;
        END IF;
         
         update br_tl set institucion = 'CC' where num_cliente=csolicitud;

         IF ccontador>=70000 THEN
            COMMIT WORK;
            ---update statistics medium for table bdiburo:br_tl;
            LET ccontador=1;
         ELSE
            LET ccontador=ccontador+1;
         END IF;

    END FOREACH;  

          IF ccontador > 1 THEN
                COMMIT WORK; 
          END IF;

            LET ccontador = 1;

 RETURN scod_ret;
END
END PROCEDURE;