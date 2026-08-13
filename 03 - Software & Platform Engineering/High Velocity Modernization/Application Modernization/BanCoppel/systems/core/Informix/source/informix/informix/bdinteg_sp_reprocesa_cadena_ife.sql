CREATE PROCEDURE "informix".sp_reprocesa_cadena_ife() RETURNING	 VARCHAR(5); --Codigo de Retorno

	DEFINE iSqlErr              INTEGER;
    DEFINE sErrParseo           CHAR(5);
    DEFINE iCantReg             INTEGER;
    DEFINE sNumCte              CHAR(9);    
    DEFINE sFecha               DATETIME YEAR TO FRACTION;
    DEFINE sResultado           CHAR(10);
    DEFINE UV_REFLECTANCE       CHAR(4); 
    DEFINE UV_SHAPE             CHAR(4); 
    DEFINE IR_INK               CHAR(4); 
    DEFINE UV_REFLECTANCE_REV   CHAR(4); 
    DEFINE IR_INK_REV           CHAR(4);

    LET iSqlErr             =  0;
    LET sErrParseo          = '';
    LET iCantReg            =  0;
    LET sNumCte             = '';
    LET sFecha              = '';
    LET sResultado          = '';
    LET UV_REFLECTANCE      = '';
    LET UV_SHAPE            = '';
    LET IR_INK              = '';
    LET UV_REFLECTANCE_REV  = '';
    LET IR_INK_REV          = '';

BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr;
			END IF;
		END EXCEPTION;
		
        --SET DEBUG FILE TO '/tmp/anj/sp_reprocesa_cadena_ife.sql';
		--TRACE OFF;

        SELECT trim(valor) INTO iCantReg 
            FROM si_param 
                WHERE cod_param='380';

        FOREACH 
            SELECT LIMIT iCantReg numcte, Fecha 
              INTO sNumCte, sFecha
                FROM si_bitacora_ife
                 where cod_resp_ife='' 
                 --WHERE numcte='038878773'--000001511'
                
--TRACE ON; sp_parsea_cadena_idbx_2
            EXECUTE PROCEDURE sp_parsea_cadena_idbx(sNumCte, sFecha) 
                INTO sErrParseo, sResultado, UV_REFLECTANCE, UV_SHAPE, IR_INK, UV_REFLECTANCE_REV, IR_INK_REV;
--TRACE OFF;
                IF sResultado='Verdadero' THEN
                    UPDATE si_bitacora_ife set cod_resp_ife='1', resultado='Verdadero', causa_rechazo='', test_uv_reflec_anv=UV_REFLECTANCE,
                        test_uv_shape_anv=UV_SHAPE,
                        test_ir_ink_anv=IR_INK,
                        test_uv_reflectance_rev=UV_REFLECTANCE_REV,
                        test_ir_ink_rev=IR_INK_REV
                        WHERE numcte=sNumCte and fecha=sFecha;
                ELIF sResultado='Falso' THEN
                    UPDATE si_bitacora_ife set cod_resp_ife='1', resultado='Falso', causa_rechazo='Menor cantidad de campos en OK', test_uv_reflec_anv=UV_REFLECTANCE,
                        test_uv_shape_anv=UV_SHAPE,
                        test_ir_ink_anv=IR_INK,
                        test_uv_reflectance_rev=UV_REFLECTANCE_REV,
                        test_ir_ink_rev=IR_INK_REV
                        WHERE numcte=sNumCte and fecha=sFecha;
                END IF;
            
        END FOREACH

	RETURN '00000';
END
END PROCEDURE;