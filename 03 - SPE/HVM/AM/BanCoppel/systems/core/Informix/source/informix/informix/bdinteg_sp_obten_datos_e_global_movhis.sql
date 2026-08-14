CREATE PROCEDURE "informix".sp_obten_datos_e_global_movhis(p_tarjeta CHAR(20), p_secuenciaExtendida CHAR(20), p_debito CHAR(1), p_cuenta CHAR(20), p_empresa CHAR(3))

     RETURNING	DATETIME YEAR TO SECOND As fechaMovimiento, CHAR(20) As iso41, CHAR (20) As iso37, CHAR(4) As idReceptor, CHAR(6) As horaMovimiento, money(16,2) As resultado_monto_comision, CHAR(1) As resultado_codigo, CHAR(7) AS secuencia;

	--definicion de variables--	    
	DEFINE resultado_fechaMovimiento            DATETIME YEAR TO SECOND;
    DEFINE resultado_iso41                  	CHAR(20);
    DEFINE resultado_iso37                  	CHAR(20);
    DEFINE resultado_idReceptor             	CHAR(4);
    DEFINE resultado_horaMovimiento         	CHAR(6);
    DEFINE resultado_monto_comision             money(16,2);
    DEFINE resultado_codigo                 	CHAR(1);
    DEFINE var_secuencia                    	CHAR(7);
    DEFINE var_fechaAut                         DATETIME YEAR TO SECOND;
    DEFINE iSqlErr                          	INTEGER;
     
     -- InicializaciÃ³n de las variables.
    LET resultado_fechaMovimiento = '';
	LET resultado_iso41  = '';
    LET resultado_iso37  = '';
	LET resultado_idReceptor = '';
    LET resultado_horaMovimiento = '';
    LET resultado_monto_comision = '';
    LET resultado_codigo = '';
    LET var_secuencia = '';
    LET var_fechaAut = null;

    SET ISOLATION TO DIRTY READ;

--   SET DEBUG FILE TO "/pisa/sp_obten_datos_e_global_movhis.out";
--   TRACE ON;

	BEGIN

        ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET resultado_fechaMovimiento = '';
                    LET resultado_iso41  = '';
                    LET resultado_iso37  = '';
                    LET resultado_idReceptor = '';
                    LET resultado_horaMovimiento = '';
                    LET resultado_monto_comision = '';
                    LET resultado_codigo = '';
                    LET var_secuencia = '';
                    LET var_fechaAut = '';
                    RETURN resultado_fechaMovimiento, resultado_iso41, resultado_iso37, resultado_idReceptor, resultado_horaMovimiento, resultado_monto_comision, resultado_codigo, var_secuencia;
                END IF;
        END EXCEPTION;
     
        IF(p_debito == '1') THEN
            --Busqueda en movdia
            SELECT DISTINCT fech_alt 
            INTO var_fechaAut
            FROM bdicheq:sc_movdia WHERE 
                empresa = p_empresa
                AND cuenta = p_cuenta
                AND transacc in ('0800','0830','0857','0859','0871','0873','0874','0876','0887')
                AND folio_suc = 'i' || p_secuenciaExtendida;
                --Busqueda en his
                IF(var_fechaAut IS NULL OR var_fechaAut == '') THEN
                    SELECT DISTINCT fech_alt 
                    INTO var_fechaAut
                    FROM bdicheq:sc_movhis WHERE 
                        empresa = p_empresa
                        AND cuenta = p_cuenta
                        AND transacc in ('0800','0830','0857','0859','0871','0873','0874','0876','0887')
                        AND folio_suc = 'i' || p_secuenciaExtendida;
                        --Busqueda en his old (08-06-2011 - emanuelvn)
                        IF(var_fechaAut IS NULL OR var_fechaAut == '') THEN
                            SELECT DISTINCT fech_alt 
                            INTO var_fechaAut
                            FROM bdicheq:sc_movhis_old WHERE 
                                empresa = p_empresa
                                AND cuenta = p_cuenta
                                AND transacc in ('0800','0830','0857','0859','0871','0873','0874','0876','0887')
                                AND folio_suc = 'i' || p_secuenciaExtendida;
                        END IF;
                END IF;
        ELSE
         SELECT DISTINCT fecha_mov
            INTO var_fechaAut
            FROM bdicred:sd_movdia  
            LEFT JOIN bdicred:sd_transfun ON (bdicred:sd_movdia.codigo_fun = bdicred:sd_transfun.codigo_fun AND bdicred:sd_movdia.codigo_ref = bdicred:sd_transfun.codigo_ref) 
            WHERE
                bdicred:sd_movdia.empresa = p_empresa
                AND num_credito = p_cuenta                
                AND transacc in ('4002','6260','6261','6280','6800','6830','6859','6871','6873','6876','6887','6890','6893','6901','7381','7382','7384','9033','9061','993','994','995','996')
                AND folio_suc = 'i' || p_secuenciaExtendida;
            IF(var_fechaAut IS NULL OR var_fechaAut == '') THEN
                SELECT DISTINCT fecha_mov 
                INTO var_fechaAut
                FROM bdicred:sd_movhis 
                LEFT JOIN bdicred:sd_transfun ON (bdicred:sd_movhis.codigo_fun = bdicred:sd_transfun.codigo_fun AND bdicred:sd_movhis.codigo_ref = bdicred:sd_transfun.codigo_ref) 
                where
                    bdicred:sd_movhis.empresa = p_empresa
                    AND num_credito = p_cuenta
                    AND transacc in ('4002','6260','6261','6280','6800','6830','6859','6871','6873','6876','6887','6890','6893','6901','7381','7382','7384','9033','9061','993','994','995','996')
                    AND folio_suc = 'i' || p_secuenciaExtendida;
            END IF;
        END IF;


        SELECT DISTINCT fechahorainauth, idterminal, referencia, idreceptor, horalocaltransaccion, montosurcharge, secuencia
		INTO resultado_fechaMovimiento, resultado_iso41, resultado_iso37, resultado_idReceptor, resultado_horaMovimiento, resultado_monto_comision, var_secuencia
		FROM intercard:movimientohistorico
        WHERE numtarjeta = p_tarjeta
            AND secuenciaextendida LIKE (SUBSTRING (p_secuenciaExtendida FROM 1 FOR 8) || '_' || SUBSTRING(p_secuenciaExtendida FROM 10 FOR 15))
            AND DATE (fechahorainauth) = var_fechaAut;
                        
            SELECT DISTINCT codreversa
            INTO resultado_codigo
            FROM intercard:movimientohistorico
            WHERE numtarjeta = p_tarjeta
            AND secuenciaorig = var_secuencia
            AND DATE (fechahorainauth) = var_fechaAut;


-- LET resultado_codigo = 1;

            RETURN resultado_fechaMovimiento, resultado_iso41, resultado_iso37, resultado_idReceptor, resultado_horaMovimiento, resultado_monto_comision, resultado_codigo, var_secuencia;
    END 
END PROCEDURE;