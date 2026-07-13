CREATE PROCEDURE "informix".sp_reproceso_rcda_emergente(pfecha DATE)
RETURNING	CHAR(08)	AS	cod_ret,
			CHAR(80)	AS	mensaje;
			
--variables de retorno
	DEFINE	cod_ret		CHAR(08);
	DEFINE	mensaje		CHAR(80);

--variables de control de errores
	DEFINE	iSqlErr 		INTEGER;
	DEFINE	iIsamErr		INTEGER;
	DEFINE	vErrorInfo		VARCHAR(80);
	DEFINE	vpaso			INTEGER;	
	
BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, vErrorInfo
		IF iSqlErr <> 0 OR iIsamErr <> 0 THEN
			LET cod_ret = iSqlErr;
			LET mensaje = vErrorInfo;			
			RETURN cod_ret, 'iIsamErr: '|| iIsamErr || ' ERR_DES ' || mensaje || ' EN PASO: ' || vpaso; 
		END IF;
	END EXCEPTION;
	
	
	LET vpaso = 1;
	EXECUTE PROCEDURE "informix".sp_rcda_extrac_movhis(pfecha)
	INTO cod_ret, mensaje;
	IF cod_ret <> '000' THEN
	
		RETURN cod_ret, mensaje;
	
	END IF
	
	LET	vpaso = 2;
	BEGIN WORK;
		UPDATE "informix".mi_fechas SET fecha_ant =pfecha  WHERE empresa ='001';
	COMMIT WORK;
	
	LET	vpaso = 3;
	EXECUTE PROCEDURE "informix".sp_rcda_incremento_saldo()
	INTO cod_ret, mensaje;
	IF cod_ret <> '00000' THEN
	
		RETURN cod_ret, mensaje;
	
	END IF
	
	LET	vpaso = 4;
	EXECUTE  PROCEDURE "informix".sp_rcda_apert()
	INTO cod_ret, mensaje;
	IF cod_ret <> '00000' THEN
	
		RETURN cod_ret, mensaje;
	
	END IF
	
	LET	vpaso = 5;
	EXECUTE PROCEDURE "informix".sp_rcda_integra()
	INTO cod_ret, mensaje;
	IF cod_ret <> '00000' THEN
	
		RETURN cod_ret, mensaje;
	
	END IF
	
	BEGIN WORK;
		UPDATE "informix".mi_fechas SET fecha_ant =today -1  WHERE empresa ='001';
	COMMIT WORK;
	
	RETURN '00000000','Y ES CORRECTO';

END
END PROCEDURE;