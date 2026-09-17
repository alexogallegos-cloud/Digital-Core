CREATE PROCEDURE "informix".sp_envia_sms_actualiza_sol(pempresa CHAR(3), 
                                                    pproducto CHAR(8), 
                                                    pnum_solicitud CHAR(20),
                                                    pnumcte CHAR(20),
                                                    pstatus CHAR(2));

    -- DEFINE VARIABLES
    DEFINE sCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;

    DEFINE vApellidoPaterno CHAR (80);
    DEFINE vStatusTelefono  CHAR(2);
    DEFINE vNumeroCelular CHAR(15);
    DEFINE vSecuenciaTelAct INTEGER;
    DEFINE vBanderaSms  CHAR(100);
    DEFINE vContSol INT;

    -- ASIGNA VARIABLES
    LET sCodRet = '00001';
    LET iSqlErr = 0;

    LET vApellidoPaterno='';
    LET vStatusTelefono = '';
    LET vNumeroCelular = '';
    LET vSecuenciaTelAct = 0;
    LET vBanderaSms = '0';
    LET vContSol = 0;

    --SET DEBUG FILE TO "/home/e90317801/adriandiaz/logs/sp_envia_sms_actualiza_sol.out";
	--TRACE ON;

BEGIN
-- EXCEPTION
ON EXCEPTION SET iSqlErr
   IF iSqlErr != 0 THEN
      -- INSERTA EN LA BITACORA EL ERROR QUE ARROJÃÂ
      INSERT INTO "informix".ss_bitacora_sms_actualiza_sol (empresa, num_producto, num_solicitud, numcte, status_solicitud, respuesta_sms)
        VALUES (pempresa, pproducto, pnum_solicitud, pnumcte, pstatus, iSqlErr);

   END IF;
END EXCEPTION;
	
	-- respuesta_sms: 
    -- 00001:   NO ENCONTRO TELEFONO DISPONIBLE
    -- 00002:   TELEFONO CON STATUS DIFERENTE DE A
    
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    -- CONSULTA LA BANDERA DEL SMS
    SELECT  NVL(valor,0)
    INTO    vBanderaSms
    FROM    "informix".ss_param 
    WHERE   secuencia = 371;

    LET vBanderaSms = TRIM(vBanderaSms);
    
    -- SI ES DIFERENTE DE 1, TERMINA EL PROCESO
    IF (vBanderaSms != '1') THEN
        RETURN;
    END IF;
    
    -- VALIDA QUE NO TENGA REGISTROS EN LA BITACORA
    SELECT COUNT(num_solicitud) INTO vContSol
    FROM "informix".ss_bitacora_sms_actualiza_sol
    WHERE num_solicitud = pnum_solicitud;
    
    IF (vContSol > 0) THEN
        RETURN;
    END IF;

    -- CONSULTA EL ÃÂLTIMO REGISTRO DE LA SI_TELEFONOS_ACTUAL CON TIPO_TEL EN 2
    SELECT MAX(secuencia)
    INTO vSecuenciaTelAct
    FROM bdinteg:'informix'.si_telefonos_actual 
    WHERE tipo_tel = '2' 
    AND numcte = pnumcte;
    
    -- CONSULTA EL NÃÂMERO DE TELÃÂFONO Y EL STATUS DEL TELÃÂFONO CON EL VERIFICADO EN V Y EL NÃÂMERO DE SECUENCIA	
	SELECT NVL(telefono,''), NVL(status_tel,'')
	INTO vNumeroCelular, vStatusTelefono
	FROM bdinteg:'informix'.si_telefonos_actual 
	WHERE numcte = pnumcte
	AND tipo_tel = '2' 
	AND secuencia = vSecuenciaTelAct
	AND tel_confirmado = 1;

    -- VALIDA QUE EL STATUS DEL TELÃÂFONO SEA A
    IF vStatusTelefono ='A' THEN

        -- EJECUTA EL SP_REGISTRA_EVENTO DEPENDIENDO SI ES AT O RT EL NUEVO STATUS
        IF pstatus = 'AT' THEN
            -- CONSULTA EL APELLIDO PATERNO
            SELECT apell_paterno
            INTO vApellidoPaterno
            FROM bdinteg:'informix'.si_cliente
            WHERE numcte = pnumcte;
            
            EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','CRED_SMS','SOL_OA_AT','000000000','','','2',trim(vApellidoPaterno),'','','','','','','','','','',vNumeroCelular, 0, 0, 0, 0, 0, current, current) INTO sCodRet;
        ELIF pstatus = 'RT' THEN
            EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','SMS_97000','PPF_SMS_ER','000000000','', '','1', '', '', '', '', '', '', '', '', '', '', '',vNumeroCelular, 0, 0, 0, 0, 0, current, current) INTO sCodRet;
        END IF;

        INSERT INTO "informix".ss_bitacora_sms_actualiza_sol (empresa, num_producto, num_solicitud, numcte, status_solicitud, respuesta_sms)
        VALUES (pempresa, pproducto, pnum_solicitud, pnumcte, pstatus, sCodRet);
		
	ELIF vStatusTelefono = '' THEN
        INSERT INTO "informix".ss_bitacora_sms_actualiza_sol (empresa, num_producto, num_solicitud, numcte, status_solicitud, respuesta_sms)
        VALUES (pempresa, pproducto, pnum_solicitud, pnumcte, pstatus, '00001');

    ELSE
        INSERT INTO "informix".ss_bitacora_sms_actualiza_sol (empresa, num_producto, num_solicitud, numcte, status_solicitud, respuesta_sms)
        VALUES (pempresa, pproducto, pnum_solicitud, pnumcte, pstatus, '00002');
		
    END IF;

END
END PROCEDURE
