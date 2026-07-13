CREATE PROCEDURE "informix".arr_venc()
RETURNING CHAR(5);





-- DEFINICION DE VARIABLES
DEFINE vsqlerr INTEGER;
DEFINE ax_codret CHAR(5);
DEFINE ax_credito CHAR(20);
DEFINE ax_fecha DATE;

-- ASIGNACION DE VARIABLES
LET vsqlerr = 0;
LET ax_codret = "00000";
LET ax_fecha = "11/14/2004";

-- Control de Errores de INFORMIX
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      DROP TABLE venc_vig;
      LET ax_codret=vsqlerr;
      RETURN ax_codret;
   END IF;
END EXCEPTION;



-- PROGRAMA PRINCIPAL
        SELECT num_credito, SUM(monto_cuota - monto_real_pag) vencido
          FROM sd_pagocapit
         WHERE status_cuota IN ("7","2")       
         GROUP BY 1             
          INTO TEMP vencidos;

        SELECT a.num_credito, vencido,  SUM(monto_real_pag) adelantado
          FROM vencidos a, sd_pagocapit b       
         WHERE a.num_credito = b.num_credito   
           AND fecha_cuota > (SELECT MIN(fecha_cuota) FROM sd_pagocapit r
                               WHERE r.num_credito = a.num_credito
                                 AND status_cuota ="1")
         GROUP BY 1,2           
          INTO TEMP venc_vig;  

	FOREACH WITH HOLD 
		SELECT num_credito INTO ax_credito FROM venc_vig
		 WHERE vencido <= adelantado

		BEGIN WORK;

		EXECUTE PROCEDURE clasica_sdosp(ax_credito, ax_fecha)
		   INTO ax_codret;

		IF ax_codret <> "00000" THEN
			ROLLBACK WORK;
		ELSE
			COMMIT WORK;
		END IF

	END FOREACH

END
	RETURN ax_codret;
END PROCEDURE;