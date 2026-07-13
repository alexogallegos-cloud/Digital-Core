CREATE PROCEDURE "informix".actchequessbc( pempresa CHAR(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER;
    
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE desc_err     CHAR(50);
	DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(50);
    DEFINE vabierto     CHAR(1);
    DEFINE vcomienza    SMALLINT;
    DEFINE vcontador1   INTEGER;
    DEFINE vcontador2   INTEGER;
	DEFINE vcontador3   INTEGER;
    DEFINE vmonto       MONEY(14,2);
    DEFINE vreferencia  CHAR(40);
    DEFINE vdocto       INTEGER;
    DEFINE vcuenta      CHAR(20);
    DEFINE vfecha_alta  DATE;
    DEFINE vcvebconew   CHAR(3);
    DEFINE vrefnew      CHAR(20);
    DEFINE vcvebanco    CHAR(3);
    DEFINE vnumcuenta   CHAR(20);
    DEFINE vdctabco     DECIMAL(20,0);
    DEFINE vcctabco     CHAR(20);
    
    LET sql_err	   = 0;
    LET isam_err   = 0;
    LET desc_err   = '';
	LET vcodret1   = '';
    LET vcodret2   = '';
    LET vcodret3   = '';
    LET vabierto   = '0';
    LET vcomienza  = -1;
    LET vcontador1 = 0;
    LET vcontador2 = 0;
	LET vcontador3 = 0;
    LET vmonto       = 0.00;
    LET vreferencia  = '';
    LET vdocto       = 0;
    LET vcuenta      = '';
    LET vfecha_alta  = '';
    LET vcvebconew   = '';
    LET vrefnew      = '';
    LET vcvebanco    = '';
    LET vnumcuenta   = '';
    LET vdctabco = 0;
    LET vcctabco = '';
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/actchequessbc.err";
        TRACE ON;
        IF sql_err <> 0 THEN
			LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF vabierto = '1' THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcodret3, vcontador1, vcontador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/actchequessbc.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTIENE EL NUMERO TOTAL DE REGISTROS A DEPURAR
    SELECT COUNT(empresa)
      INTO vcontador1
      FROM sc_docret_sbc 
     WHERE siglas IN('SC','SD')  
       AND transacc IN('0250','6250')
       AND cancelado <> "T"
       AND NVL(banco,"") = ""
       AND NVL(numcuenta,"") = "";
    
    -- // DEPURA REGISTROS DE LA sc_docret_sbc
    FOREACH WITH HOLD 
        SELECT monto_ori, referencia, num_chq, cuenta, fecha_alta
          INTO vmonto, vreferencia, vdocto, vcuenta, vfecha_alta
          FROM sc_docret_sbc 
         WHERE siglas IN('SC','SD')  
           AND transacc IN('0250','6250')
           AND cancelado <> "T"
		   AND NVL(banco,"") = ""
           AND NVL(numcuenta,"") = ""
           
		IF vcontador3 = 0 THEN
			BEGIN WORK;
			LET vabierto = '1'; 
		END IF
        
        LET vcvebconew = vreferencia[1,3]; 
        LET vcvebconew = vcvebconew;
        
        LET vrefnew = vreferencia[6,25]; 
        LET vdctabco = vrefnew::decimal(20,0);
        let vcctabco = vdctabco;
        let vcctabco = trim(vcctabco);
        
        /*
        SELECT cvebanco, numcuenta
          INTO vcvebanco, vnumcuenta
          FROM bditef:cce_cheques_det
         WHERE fecha_alta = '10/11/2012'
           AND cvebanco = vcvebconew
           AND lpad(trim(numcuenta),20,"0") = vrefnew
           AND numcheque = vdocto
           AND monto = vmonto;
        */
           
        UPDATE sc_docret_sbc
           SET banco = vcvebconew,
               numcuenta = vcctabco
         WHERE empresa = pempresa
           AND cuenta = vcuenta
           AND fecha_alta = vfecha_alta
           AND referencia = vreferencia
           AND num_chq = vdocto
           AND monto_ori = vmonto;
        
        LET vcontador2 = vcontador2 + 1;

		LET vcontador3 = vcontador3 + 1;
        
		IF vcontador3 = 5000 THEN
			LET vabierto = '0';
			LET vcontador3 = 0;
			COMMIT WORK;
		END IF
        
        LET vmonto       = 0.00;
        LET vreferencia  = '';
        LET vdocto       = 0;
        LET vcuenta      = '';
        LET vfecha_alta  = '';
        LET vcvebconew   = '';
        LET vrefnew      = '';
        LET vcvebanco    = '';
        LET vnumcuenta   = '';
        LET vdctabco = 0;
        LET vcctabco = '';
    END FOREACH;
    
	IF vabierto = '1' THEN
		COMMIT WORK;
	END IF
	
    LET vcodret1 = '000';
    LET vcodret2 = '000';
    LET vcodret3 = 'PROCESO CONCLUIDO SATISFACTORIAMENTE';
    
    END;
    
    RETURN vcodret1, vcodret2, vcodret3, vcontador1, vcontador2;
    
END PROCEDURE;