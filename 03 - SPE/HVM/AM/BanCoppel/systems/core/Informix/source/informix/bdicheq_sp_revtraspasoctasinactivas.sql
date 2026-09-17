CREATE PROCEDURE "informix".sp_revtraspasoctasinactivas( pEmpresa char(3) )
RETURNING CHAR(5), INTEGER, INTEGER, INTEGER;      
	
	-- // DECLARACION DE VARIABLES.
    DEFINE vSqlErr          	INTEGER;
    DEFINE vIsamErr         	INTEGER;
    DEFINE vDescErr         	CHAR(50);
    DEFINE vCodRet1         	CHAR(5);
    DEFINE vCodRet2         	CHAR(5);
    DEFINE vCodRet3         	CHAR(50);    
    DEFINE vContador1           INTEGER;
    DEFINE vContador2           INTEGER;
	DEFINE vContador3           INTEGER;
	DEFINE vTrxAbierta          CHAR(1);
    DEFINE vFechaHoy            DATE;
    DEFINE vCuenta              CHAR(20);
        
    -- // INICIALIZACION DE VARIABLES.
	LET vSqlErr	     	  = 0;
    LET vIsamErr     	  = 0;
    LET vDescErr     	  = '';
    LET vCodRet1     	  = '000';
    LET vCodRet2     	  = '000';
    LET vCodRet3     	  = '';    
    LET vContador1        = 0;
    LET vContador2        = 0;
	LET vContador3        = 0;
    LET vTrxAbierta       = '0';
	LET vFechaHoy         = '';
    LET vCuenta           = '';
    
    BEGIN
    
    ON EXCEPTION SET vSqlErr, vIsamErr, vDescErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_revtraspasoctasinactivas.err";
        TRACE ON;
        IF vSqlErr <> 0 THEN
            LET vCodRet1 = vSqlErr;
            LET vCodRet2 = vIsamErr;
            LET vCodRet3 = vDescErr;	
            IF vTrxAbierta = '1' THEN
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1, vContador1, vContador2, vContador3;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_revtraspasoctasinactivas.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTIENE LA FECHA DE HOY
    SELECT fecha_hoy
      INTO vFechaHoy
      FROM sc_fechas
     WHERE empresa = pEmpresa;
     
    -- // DESMARCA CUENTAS TRASPASADAS A LA BENEFICENCIA
	FOREACH WITH HOLD
		SELECT cuenta
		  INTO vCuenta
		  FROM sc_cuentas_traspbenef
		 WHERE fecha_traspaso = vFechaHoy
		   
		BEGIN WORK;
		LET vTrxAbierta = '1';
		
		LET vContador1 = vContador1 + 1;
		
		UPDATE sc_movdia
		   SET cancelad = 'S'
		 WHERE cuenta = vCuenta
		   AND transacc = '0322';
		   
		UPDATE sc_cuentas_concentradas
		   SET sdo_trasp_beneficiencia = null,
			   int_trasp_beneficiencia = null,
			   fecha_trasp_benefic = ''
		 WHERE cuenta = vCuenta;
		 
		UPDATE sc_maechq
		   SET status_cta = '6', 
			   motivo = '', 
			   fec_cancelac = ''
		 WHERE cuenta = vCuenta;
		 
		DELETE FROM sc_cuentas_traspbenef
		 WHERE cuenta = vCuenta
		   AND fecha_traspaso = vFechaHoy;
		
		IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
			LET vContador2 = vContador2 + 1;
			COMMIT WORK;
		ELSE
			ROLLBACK WORK;
		END IF;
		
		LET vTrxAbierta = '0';
	END FOREACH;
	
	-- // ELIMINA REGISTRO DE CUENTAS NO TRASPASADAS POR EXCEDER EL MONTO PERMITIDO
	SELECT COUNT(*)
	  INTO vContador3
	  FROM sc_cuentas_notraspbenef
	 WHERE fecha_traspaso = vFechaHoy;
	 
    DELETE FROM sc_cuentas_notraspbenef
	 WHERE fecha_traspaso = vFechaHoy;
       
    END;
    
    RETURN vCodRet1, vContador1, vContador2, vContador3;
    
END PROCEDURE;