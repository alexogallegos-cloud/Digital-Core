CREATE PROCEDURE "informix".sp_ingresos_movil(pNumSolic char(12))
RETURNING CHAR(5) as codret,
          CHAR(4) as tipo_ing,
          CHAR(4) as periodicidad,
          CHAR(10) as monto

DEFINE iSqlErr		INTEGER;
DEFINE sTipoIng         CHAR(4);
DEFINE sPeriodicidad    CHAR(4);
DEFINE sMonto           CHAR(10);


LET iSqlErr		=0;
LET sTipoIng            ='';
LET sPeriodicidad       ='';
LET sMonto              ='';

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			RETURN iSqlErr, sTipoIng, sPeriodicidad, sMonto;
		END IF;
	END EXCEPTION;


        SELECT tp_ingreso, periodo_ingreso, ingreso_mensual
        INTO sTipoIng, sPeriodicidad, sMonto
        FROM bdisolic:ss_resum_scor_fin 
        WHERE num_solicitud=pNumSolic;
      --AND sec_ingreso =(SELECT MAX(sec_ingreso) FROM bdinteg:si_ingresos WHERE numcte=pNumCte);
              
	RETURN '00000', sTipoIng, sPeriodicidad, sMonto;

END
END PROCEDURE;