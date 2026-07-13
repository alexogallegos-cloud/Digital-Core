CREATE PROCEDURE "informix".ss_ins_cajagen_hist(pempresa   CHAR(3), pfecha_pase DATE)
RETURNING CHAR(5) 

	DEFINE cVarDataErr  VARCHAR(64);
	DEFINE iSqlErr      INTEGER;
	DEFINE iSamErr      INTEGER;
	DEFINE vCodRet      CHAR(5);

	--Manejo del error
	    ON EXCEPTION SET iSqlErr, iSamErr, cVarDataErr
		   IF iSqlErr <> 0 THEN
	          LET vCodret = iSqlErr;
		      RETURN vCodRet;
		   END IF;
		END EXCEPTION;

   --set debug file to "/tmp/ss_ins_cajagen_hist.out";
    --trace on;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	LET vcodret = "000";

	IF EXISTS (SELECT COUNT(cod_proveedor) 
			     FROM bdisuc:ss_cajageneral_hist 
                WHERE empresa = pempresa 
				  AND fecha = pfecha_pase) THEN

		DELETE FROM bdisuc:ss_cajageneral_hist 
              WHERE empresa = pempresa 
				AND fecha = pfecha_pase;

	END IF

    INSERT INTO bdisuc:ss_cajageneral_hist
	     SELECT empresa,cod_proveedor,divisa, pfecha_pase ,saldo_anterior,saldo_asignado,saldo_total,
				denominacion_1,denominacion_2,denominacion_3,denominacion_4,denominacion_5,denominacion_6,denominacion_7,denominacion_8,
				denominacion_9,denominacion_10,denominacion_11,denominacion_12,denominacion_13,denominacion_14,denominacion_15,     
			    cantidad_1,cantidad_1d,cantidad_2,cantidad_2d,cantidad_3,cantidad_3d,cantidad_4,cantidad_4d,cantidad_5,cantidad_5d,
				cantidad_6,cantidad_6d,cantidad_7,cantidad_7d,cantidad_8,cantidad_8d,cantidad_9,cantidad_9d,cantidad_10,cantidad_10d,     
			    cantidad_11,cantidad_11d,cantidad_12,cantidad_12d,cantidad_13,cantidad_13d,cantidad_14,cantidad_14d,cantidad_15,cantidad_15d    
		   FROM bdisuc:ss_cajageneral;

	UPDATE STATISTICS MEDIUM FOR TABLE bdisuc:ss_cajageneral_hist;

	RETURN vcodret;

END PROCEDURE;