CREATE PROCEDURE "informix".sp_buscatemporal(pTabla Char(50))

RETURNING
          CHAR (5) ,   
	  CHAR(20) ,
          INTEGER  ;


--##############################################################################
--## Procedimiento       : sp_buscatemporal
--## Version             : 1.0.0
--## Objetivo            : Valida si existe una temporal
--## Base Datos          : bicheq
--## Supuestos           :
--## Valores Entrada     : pTabla -->   Nombre de la tabla
--## Valores Retorno     : CodRet -->   Código de Retorno.
--##                       Desc   -->   Descricpion del Error
--##                       Registros->  Cantidad de Registros
--## Creado por          : Alejandro Rueda Sanchez
--## Fecha creacion      : Enero de 2007
--##############################################################################


    DEFINE cod_ret                char(5);
    DEFINE iSqlErr                integer;

    DEFINE cCodErr                CHAR(5);
    DEFINE vDesErr                VARCHAR(60);

    --Variables de retorno
    DEFINE v_registros             INTEGER;

    ON EXCEPTION
        SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cod_ret = iSqlErr;
        END IF;
        RETURN cod_ret, vDesErr, NULL;

    END EXCEPTION;



    LET cod_ret = "000";
    LET vDesErr = "";
    LET v_registros = 0;

    --// ********************************************************************
    --// Obtiene Registros de la tabla 
    --// ********************************************************************

    IF pTabla = 'temp_sc_movhis' THEN --//Conciliacion de saldos.
       SELECT  count(*) INTO v_registros  FROM temp_sc_movhis;
    END IF
    IF pTabla = 'his1' THEN --//Pase contabilidad.
       SELECT  count(*) INTO v_registros  FROM his1;
    END IF
    IF pTabla = 'temp_sconcilia' THEN --//Conciliacion ctas enlace.
       SELECT  count(*) INTO v_registros  FROM temp_sconcilia;
    END IF
 
    IF pTabla = 'tmp_concilia_chq' THEN --//Conciliacion cta contable.
       SELECT  count(*) INTO v_registros  FROM tmp_concilia_chq;
    END IF

    IF pTabla = 'tmp_rconciliacentral' THEN --//Conciliacion cta contable.
       SELECT  count(*) INTO v_registros  FROM tmp_rconciliacentral;
    END IF

    IF pTabla = 'tmp_rconciliasucursal' THEN --//Conciliacion cta contable.
       SELECT  count(*) INTO v_registros  FROM tmp_rconciliasucursal;
    END IF

    RETURN cod_ret, vDesErr, v_registros;
END PROCEDURE DOCUMENT "Version: 1.00.000";

CREATE PROCEDURE "informix".sp_co_erro_integra(p_usuario CHAR(8), p_fecha_captura DATE)
    RETURNING INTEGER, INTEGER , CHAR(10) ,CHAR(10) ,CHAR(10), CHAR(10), CHAR(10), CHAR(10) ,CHAR(12) ,CHAR(3)                                                 
	
    DEFINE vcontrol_poliza  INTEGER;
    DEFINE vsecuencia       INTEGER;
    DEFINE vccmayor         CHAR(10);
    DEFINE vccsub           CHAR(10);
    DEFINE vccsubsub        CHAR(10);
    DEFINE vccssubsub       CHAR(10);
    DEFINE vccsssubsub      CHAR(10);
    DEFINE vsector          CHAR(10);
    DEFINE vauxiliar        CHAR(12);
    DEFINE vcod_ret         CHAR(3);

	SET ISOLATION TO DIRTY READ;

	FOREACH
		SELECT control_poliza,secuencia,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,
			   sector,auxiliar,cod_ret
		  INTO vcontrol_poliza,vsecuencia,vccmayor,vccsub,vccsubsub,vccssubsub,
			   vccsssubsub,vsector,vauxiliar,vcod_ret
	      FROM bdicont:co_auditerr 
		 WHERE fecha_captura = p_fecha_captura AND usuario = p_usuario

		RETURN vcontrol_poliza,vsecuencia,vccmayor,vccsub,vccsubsub,vccssubsub,
			   vccsssubsub,vsector,vauxiliar,vcod_ret WITH RESUME;
	
	END FOREACH;

END PROCEDURE;