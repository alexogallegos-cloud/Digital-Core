CREATE PROCEDURE "informix".sp_selcatcontable(p_sEmpresa CHAR(3))
	
    RETURNING CHAR(5) as codigo, 
            CHAR(4) as ccmayor, 
            CHAR(2) as ccsub, 
            CHAR(2) as ccsubsub, 
            CHAR(2) as ccssubsub, 
            CHAR(2) as ccsssubsub, 
            CHAR(2) as sector, 
            CHAR(50) as nombre, 
            CHAR(1) as naturaleza, 
            CHAR(1) as auxiliar, 
            CHAR(1) as tipo_cuenta;		  
	--DEFINICION DE VARIABLES
	DEFINE vCodret 				CHAR(5);
	DEFINE iSqlErr          	INTEGER;
	DEFINE v_sccmayor			CHAR(4);
	DEFINE v_sccsub				CHAR(2);
	DEFINE v_sccsubsub			CHAR(2);
	DEFINE v_sccssubsub			CHAR(2);
	DEFINE v_sccsssubsub		CHAR(2);
	DEFINE v_ssector			CHAR(2);
	DEFINE v_snombrecuenta		CHAR(50);
	DEFINE v_snaturaleza		CHAR(1);
	DEFINE v_sauxiliar			CHAR(1);
	DEFINE v_stipo_cuenta		CHAR(1);
	
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	--CREADO POR: VLADIMIR FÉLIX GÁLVEZ 8/JULIO/2009
	--Sp que obtiene las cuentas contables que no manejan auxiliares
	--que sean cuentas de detalle
	--DEBUG DEL PROCEDURE
	--SET DEBUG FILE TO "/tmp/sp_consultarcatcontable.out";
	--TRACE ON;
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	
	BEGIN
		ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET vCodret = iSqlErr;
                RETURN vCodret,'','','','','','','','','','';
            END IF;
        END EXCEPTION;
		
		IF (p_sEmpresa = '' OR p_sEmpresa IS NULL) THEN
			LET vCodret = '001';
			RETURN vCodret,'','','','','','','','','','';
		END IF;
		
		LET vCodret = '000';
		
		FOREACH
			SELECT ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector,nombre, naturaleza_cta, auxiliar, tipo_cuenta
			INTO v_sccmayor, v_sccsub, v_sccsubsub, v_sccssubsub, v_sccsssubsub, v_ssector, v_snombrecuenta, v_snaturaleza, v_sauxiliar, v_stipo_cuenta
			FROM bdinteg:"informix".si_catalog
			WHERE empresa = p_sEmpresa
			ORDER BY 1,2,3,4,5,6
			
			RETURN vCodret, v_sccmayor, v_sccsub, v_sccsubsub, v_sccssubsub, v_sccsssubsub, v_ssector, v_snombrecuenta, v_snaturaleza, v_sauxiliar, v_stipo_cuenta WITH RESUME;
			
		END FOREACH;
	END;
END PROCEDURE;