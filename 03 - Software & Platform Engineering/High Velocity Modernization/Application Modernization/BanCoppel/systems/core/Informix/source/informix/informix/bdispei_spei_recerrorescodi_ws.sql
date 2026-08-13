CREATE PROCEDURE "informix".spei_recerrorescodi_ws( pvchrcodretc    CHAR(5),       -- Codigo de error   
                                                    pcVarDataErr    CHAR(100),     -- Descripcion del error
                                                    pchrparti       CHAR(2),       -- Participante 'o' ÃÂ³  'b' ordenante/beneficiario   
                                                    pvchridmjc      CHAR(20),      -- Identificador del mensaje de cobro
                                                    pvchrfchmjc     CHAR(20),      -- Estampa de tiempo del cobro 
                                                    pvchrconcepto   CHAR(50),      -- Concepto
                                                    pmnyimporte     DECIMAL(12,2), -- Monto
                                                    ppvchrfchfinpro CHAR(20),      -- Estampa de tiempo de fin de procesamiento
                                                    pvchrcveras     CHAR(30),      -- Clave de rastreo    
                                                    pvchrrefnum     CHAR(7),       -- Referencia NumÃÂ©rica  del beneficiario                                                
                                                    pvchrcelord     CHAR(10),      -- NÃÂºmero de celular  ordenante 
                                                    pvchrdiveord    CHAR(3),       -- Digito verificador 
                                                    pvchrbancoord   CHAR(5),       -- Banco ord   
                                                    pvchrtpoctaord  CHAR(2),       -- Tipo de cuenta ordenante
                                                    pvchrctaord     CHAR(20),      -- Cuenta ordenante
                                                    pvchrnomord     CHAR(40),      -- Nombre ordenante
                                                    pvchrcelbenf    CHAR(20),      -- NÃÂºmero celular beneficiario
                                                    pvchrdivebenf   CHAR(3),       -- Digito verificador beneficiario
                                                    pvchrbancobenf  CHAR(5),       -- Banco beneficiario
                                                    pvchrtpoctabenf CHAR(2),       -- Tipo de cuenta beneficiario
                                                    pvchrctabenf    CHAR(20),      -- Cuenta  beneficiario
                                                    pvhrnombenf     CHAR(40),      -- Nombre Beneficiario 
                                                    pnumseriecert   CHAR(20) )     -- Numero se serie de certificado
RETURNING CHAR(5),          -- codigo de retorno
          INTEGER,          -- num_serial_codi
          CHAR(2),          -- tipo_aviso_proc_codi
          CHAR(2),          -- codigo_codi
          CHAR(20),         -- identificador_mensaje_codi
          CHAR(20),         -- fecha_mensaje_cobro_codi
          CHAR(50),         -- concepto_pago_codi
          DECIMAL(12,2),    -- importe_pago_codi
          CHAR(23),         -- fecha_procesamiento_pago_codi
          CHAR(30),         -- clave_rastreo_codi
          CHAR(7),          -- referencia_numerica_codi
          CHAR(10),         -- alias_ordenante_codi
          CHAR(3),          -- digito_verificador_ordenante_codi
          CHAR(5),          -- banco_ordenante_codi
          CHAR(2),          -- tipo_cuenta_ordenante_codi
          CHAR(20),         -- cuenta_ordenante_codi
          CHAR(40),         -- nombre_ordenante_codi
          CHAR(20),         -- alias_beneficiario_codi
          CHAR(3),          -- digito_verificador_beneficiario_codi
          CHAR(5),          -- banco_beneficiario_codi
          CHAR(2),          -- tipo_cuenta_beneficiario_codi
          CHAR(20),         -- cuenta_beneficiario_codi
          CHAR(40);         -- nombre_beneficiario_codi
    
    DEFINE vcodret      char(5);
    DEFINE vcodret2     char(5);
    DEFINE vcodret3     char(50);
    DEFINE sql_err      integer;
    DEFINE isam_err     integer;
    DEFINE desc_err     char(80);
    
    DEFINE vchrcode         CHAR(2);
    DEFINE vchrfchfinpro    CHAR(23);
    DEFINE vchrcvespeienva  CHAR(5);
    DEFINE vchrfchenvpro    CHAR(23);
    DEFINE vchridtpa        CHAR(2);
    DEFINE vtimestamp       CHAR(13);
    DEFINE vnumserial       INTEGER;

    -- // FIRMA
    DEFINE ret						INTEGER;
    DEFINE wvchrfirma 			    CHAR(512);
    DEFINE wchrcadena_00			CHAR(3000);
    DEFINE wchrcadena_01			CHAR(200);
    DEFINE wchrcadena_02			CHAR(200);
    DEFINE wchrcadena_03			CHAR(200);	
    
    LET vcodret  = '00000';
    LET vcodret2 = '';
    LET vcodret3 = '';
    LET sql_err  = 0;
    LET isam_err = 0;
    LET desc_err = '';
    
    LET vchrcode = '';
    LET vchrfchfinpro = '';
    LET vchrcvespeienva = '';
    LET vchrfchenvpro = '';
    LET vchridtpa = '-';
    LET vtimestamp = '';
    LET vnumserial = 0;

    -- // FIRMA
    LET ret           = 0;
    LET wvchrfirma    = '';
    LET wchrcadena_00 = '';
    LET wchrcadena_01 = '';
    LET wchrcadena_02 = '';
    LET wchrcadena_03 = '';
	
	BEGIN
    
	ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spei_recerrorescodi_ws.err";
        TRACE ON;
		IF sql_err <> 0 THEN
            LET vcodret  = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
			RETURN vcodret, vnumserial, vchridtpa, vchrcode, pvchridmjc, pvchrfchmjc, pvchrconcepto, pmnyimporte, vtimestamp, pvchrcveras, pvchrrefnum, 
                   pvchrcelord, pvchrdiveord, pvchrbancoord, pvchrtpoctaord, pvchrctaord, pvchrnomord, 
                   pvchrcelbenf, pvchrdivebenf, pvchrbancobenf, pvchrtpoctabenf, pvchrctabenf, pvhrnombenf;
		END IF;
	END EXCEPTION;
	
    --- SET DEBUG FILE TO '/resplogifx/conciliachq/spei/spei_recerrorescodi_ws.out';
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
    
    LET vchrfchfinpro = CURRENT;
	
    --//No existen errores
    IF pvchrcodretc = '0' THEN
        --//Validar si el aviso viene de regordenctecte_bexcodi o ctas propias
        IF pcVarDataErr = 'CARGO' THEN
            LET vchridtpa = '0';
            LET vchrcode = '0';
        ELSE
            LET vchridtpa = '1';
            LET vchrcode = '0';
        END IF;
    END IF;

    --//Existen campos vienen vacios
    IF pvchrcodretc IN('11','110') AND pchrparti = 'o' THEN
        LET vchridtpa = '21';
        LET vchrcode = '8';
    END IF;

    IF pvchrcodretc = '11' AND pchrparti = 'b' THEN
        LET vchridtpa = '22';
        LET vchrcode = '8';
    END IF;

    --//Problemas en regordenctecte_bex_codi
    IF pvchrcodretc = '011' AND pchrparti = 'o' THEN
        LET vchridtpa = '21';
        LET vchrcode = '7';
    END IF;	
	
    IF pvchrcodretc = '018' AND pchrparti = 'b' THEN
        LET vchridtpa = '21';
        LET vchrcode = '3';
    END IF;

    IF pvchrcodretc = '021' AND pchrparti = 'b' THEN
        LET vchridtpa = '21';
        LET vchrcode = '16';
    END IF;	

    --//Problemas con la cuenta,tarjeta,cuenta clabe,celular ordenante
    IF pvchrcodretc IN ('501','004','019','021','020','200','100','614','122','211') AND pchrparti = 'o'THEN
        LET vchridtpa = '21';
        LET vchrcode = '17';
    END IF;

     --//Problemas con la cuenta,tarjeta,cuenta clabe,celular beneficiario
    IF pvchrcodretc IN ('020','025') AND pchrparti = 'b' THEN
        LET vchridtpa = '22';
        LET vchrcode = '17';
    END IF;
    --//Problemas con la clave de rastreo
    IF pvchrcodretc = '024' AND pchrparti <> 'i' THEN
        LET vchridtpa = '21';
        LET vchrcode = '21';
    END IF;

    --// Problemas con el monto
    IF pvchrcodretc = '035' AND pchrparti <> 'i' THEN
        LET vchridtpa = '21';
        LET vchrcode = '13';
    END IF;

    --//cancelaciÃÂ³n
    IF pvchrcodretc = '22' AND pchrparti = 'b' THEN
        LET vchridtpa = '22';
        LET vchrcode = '3';
    END IF;

    --// problemas con el abono
    IF pvchrcodretc IN ('16','00') AND pchrparti = 'b' THEN
        LET vchridtpa = '32';
        LET vchrcode = '3';
    END IF;
    IF pvchrcodretc ='02' AND pchrparti = 'o' THEN
        LET vchridtpa = '32';
        LET vchrcode = '17';
    END IF;
    IF pvchrcodretc ='01' AND pchrparti = 'b' THEN
        LET vchridtpa = '32';
        LET vchrcode = '24';
    END IF;

    --//Problemas cuentas propias
    IF pvchrcodretc ='10' AND pchrparti = 'b' THEN
        LET vchridtpa = '21';
        LET vchrcode = '8';
    END IF;
    IF pvchrcodretc ='17' AND pchrparti = 'b' THEN
        LET vchridtpa = '22';
        LET vchrcode = '17';
    END IF;
    IF pvchrcodretc ='13' AND pchrparti = 'b' THEN
        LET vchridtpa = '22';
        LET vchrcode = '13';
    END IF;
    IF pvchrcodretc ='17' AND pchrparti = 'o' THEN
        LET vchridtpa = '21';
        LET vchrcode = '17';
    END IF;
    
    LET vchrfchenvpro = CURRENT;
    LET vtimestamp  = dbinfo('utc_current') * 1000;
	
    --//ValidaciÃÂ³n para el aviso de procesamiento y cadena  para que no lleve blancos o nulos
    IF pvchrconcepto IS NULL OR pvchrconcepto = '' THEN
       LET pvchrconcepto = '-';
    END IF;

    IF pvchrcveras IS NULL OR pvchrcveras = '' THEN
       LET pvchrcveras = '-';
    END IF;

    IF pvchrrefnum IS NULL OR pvchrrefnum = '' OR pvchrrefnum = '-'  OR pvchrrefnum = 'null'  OR pvchrrefnum = 'NULL'THEN
       LET pvchrrefnum = '0';
    END IF;

    IF pvchrcelord IS NULL OR pvchrcelord = '' THEN
       LET pvchrcelord = '-';
    END IF;

    IF pvchrdiveord IS NULL OR pvchrdiveord = '' THEN
       LET pvchrdiveord = '-';
    END IF;

    IF pvchrbancoord IS NULL  THEN
       LET pvchrbancoord = 0;
    END IF;

    IF pvchrtpoctaord IS NULL OR pvchrtpoctaord = '' THEN
       LET pvchrtpoctaord = '-';
    END IF;

    IF pvchrctaord IS NULL OR pvchrctaord = '' THEN
       LET pvchrctaord = '-';
    END IF;

    IF pvchrnomord IS NULL OR pvchrnomord = '' THEN
       LET pvchrnomord = '-';
    END IF;

    IF pvchrcelbenf IS NULL OR pvchrcelbenf = '' THEN
       LET pvchrcelbenf = '-';
    END IF;

    IF pvchrdivebenf IS NULL OR pvchrdivebenf = '' THEN
       LET pvchrdivebenf = '-';
    END IF;

    IF pvchrbancobenf IS NULL  THEN
       LET pvchrbancobenf = 0;
    END IF;

    IF pvchrtpoctabenf IS NULL OR pvchrtpoctabenf = '' THEN
       LET pvchrtpoctabenf = '-';
    END IF;

    IF pvchrctabenf IS NULL OR pvchrctabenf = '' THEN
       LET pvchrctabenf = '-';
    END IF;

    IF pvhrnombenf IS NULL OR pvhrnombenf = '' THEN
       LET pvhrnombenf = '-';
    END IF;	

    /*generaciÃÂ³n de firma*/
	LET wchrcadena_01 = TRIM(vchridtpa)||'|'||TRIM(vchrcode)||'|'|| pvchridmjc||'|'||TRIM(pvchrfchmjc)||'|'|| TRIM(pvchrconcepto)||'|'|| pmnyimporte||'|'|| TRIM(vtimestamp);
	LET wchrcadena_02 = '|'||TRIM(pvchrcveras)||'|'|| TRIM(pvchrrefnum)||'|'||pvchrcelord||'|'||TRIM(pvchrdiveord)||'|'|| pvchrbancoord||'|'||TRIM(pvchrtpoctaord)||'|'||TRIM(pvchrctaord);
	LET wchrcadena_03 = '|'||TRIM(pvchrnomord)||'|'||TRIM(pvchrcelbenf)||'|'||TRIM(pvchrdivebenf)||'|'||pvchrbancobenf||'|'||TRIM(pvchrtpoctabenf)||'|'|| TRIM(pvchrctabenf)||'|'|| pvhrnombenf;
	LET wchrcadena_00 = TRIM(wchrcadena_01)||TRIM(wchrcadena_02)||TRIM(wchrcadena_03);
	
	LET wvchrfirma = space(512);
	
	EXECUTE function bdispei:syn_sign2(TRIM(wchrcadena_00), wvchrfirma, 21) 
	INTO ret;
	
	LET wvchrfirma = wvchrfirma;
    
    INSERT INTO tbl_stsprocodi VALUES
    ( 0, 'E', vchridtpa, vchrcode, pvchridmjc, pvchrfchmjc, pvchrconcepto, pmnyimporte, vtimestamp, pvchrcveras, pvchrrefnum, pvchrcelord, pvchrdiveord, pvchrbancoord, 
      pvchrtpoctaord, pvchrctaord, pvchrnomord, pvchrcelbenf, pvchrdivebenf, pvchrbancobenf, pvchrtpoctabenf, pvchrctabenf, pvhrnombenf, pnumseriecert, wvchrfirma, current );
      
    SELECT num_serial
      INTO vnumserial
      FROM tbl_stsprocodi
     WHERE vstatenv = 'E'
       AND mnyimporte = pmnyimporte
       AND vchrcveras = pvchrcveras;
    
    RETURN vcodret, vnumserial, vchridtpa, vchrcode, pvchridmjc, pvchrfchmjc, pvchrconcepto, pmnyimporte, vtimestamp, pvchrcveras, pvchrrefnum, 
           pvchrcelord, pvchrdiveord, pvchrbancoord, pvchrtpoctaord, pvchrctaord, pvchrnomord, 
           pvchrcelbenf, pvchrdivebenf, pvchrbancobenf, pvchrtpoctabenf, pvchrctabenf, pvhrnombenf;
    
    END;
    
END PROCEDURE;