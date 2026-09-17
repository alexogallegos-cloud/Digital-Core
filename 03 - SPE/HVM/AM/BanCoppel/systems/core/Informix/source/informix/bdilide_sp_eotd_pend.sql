CREATE PROCEDURE "informix".sp_eotd_pend(pEmpresa CHAR(3), pFechaProceso DATE, pCve_Usuario CHAR(8))

RETURNING CHAR(4);

    -- "999" significa que el proceso se había ejecutado anteriormente.
    -- "000" significa que el proceso se ejecuto correctamente.
    -- "555" significa que la pFechaProceso que recibió.
    -- "222" significa que el parametro que identifica una transacción de depósito en efectivo con tarjeta de débito no se encontró en la tabla de parámetros LIDE.
    -- "333" significa que la fecha que se recibió como parámetro No es menor a la fecha actual.

    DEFINE v_cCod_Ret       CHAR(4);
    DEFINE v_cStatus        CHAR(1);
    DEFINE vsqlerr          INTEGER ;
    DEFINE v_cAniomes       CHAR(6);
    DEFINE v_cNumCte        CHAR(20);
    DEFINE v_iSerial        INTEGER ;
    DEFINE v_cRfc           CHAR(13);
    DEFINE v_dFecha         DATE ;
    DEFINE v_mMontoTot      MONEY(10,2);
    DEFINE v_cCuenta        CHAR(20);
    DEFINE vcRfc2           CHAR(13);
    DEFINE  vcProceso       CHAR(15);
    DEFINE viDepositoEfect  CHAR(4);
    DEFINE vcTpoPersona     CHAR(2);
    DEFINE vcStatusExento   CHAR(1);
    DEFINE vSucursal        char(4);

    LET v_cCod_Ret      = "000";
    LET v_cStatus 	    = "";
    LET vsqlerr 	    = 0;
    LET v_cAniomes 	    = "";
    LET v_cNumCte 	    = "";
    LET v_iSerial 	    = 0;
    LET v_cRfc 		    = "";
    LET v_dFecha 	    = "";
    LET v_mMontoTot     = 0.00;
    LET v_cCuenta	    = "";
    LET vcProceso	    ="";
    LET vcRfc2 		    = '';
    LET viDepositoEfect = '';
    LET vcTpoPersona    ='';
    LET vcStatusExento  = '';
    Let vSucursal       = '';

    BEGIN
    
    ON EXCEPTION  SET vsqlerr
        IF vsqlerr <> 0  THEN
            LET  v_cCod_Ret  = vsqlerr;
            RETURN v_cCod_Ret;
        END IF;
    END  EXCEPTION;

    LET pFechaProceso = CURRENT ::DATE;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    IF pFechaProceso IS NOT NULL THEN
        SELECT {+INDEX(sl_procesos idx_procesos)}
               status, proceso  
          INTO v_cStatus, vcProceso 
          FROM bdilide:sl_procesos  
         WHERE proceso = "extoptar_pp" 
           AND fech_proceso = pFechaProceso
           AND status = status;

        IF  vcProceso = "extoptar_pp"   THEN
            IF v_cStatus = "1"  THEN
                -- // proceso se ejecuto anteriromente
                LET v_cCod_Ret = "999";
                RETURN v_cCod_Ret;
            ELSE
                -- // borra  los movimientos de esa fecha de cuando es tipo de cuenta el producto es 1500, 1700, 1800
                DELETE {+INDEX(sl_movefec i_101)}
                  FROM bdilide:sl_movefec 
                 WHERE tipo_cta = 'D' 
                   AND fecha_mov <= '10-19-2008'
                   AND (num_cta like '18%' OR num_cta like '17%' OR num_cta like '15%');
            END IF;
        ELSE
            -- // Insertar en tabla de Procesos
            INSERT INTO bdilide:sl_procesos (proceso,fech_proceso,status,user_insert,fecha_insert) 
            VALUES("extoptar_pp",pFechaProceso,"0", pCve_Usuario,CURRENT ::DATE);
        END IF;

        LET v_cAniomes = REPLACE( SUBSTRING(pFechaProceso  from 7 for 4),'/','')  || SUBSTRING(pFechaProceso  from 1 for 2);

        FOREACH
            -- // Obteniendo parámetro de la tabla de parametros lide.
            SELECT valor 
              INTO viDepositoEfect 
              FROM bdilide:sl_parametros 
             WHERE cve_param = "03"

            IF	viDepositoEfect IS NOT NULL  AND viDepositoEfect <> "" THEN
                -- // extraer todos los mivimientos de deposito en efectivo con tarjeta de débito
                FOREACH
                    SELECT maechq.num_cte,movdia.num_serial,cliente.rfc,movdia.cuenta,movdia.fech_alt,movdia.monto_tot, cliente.tpo_persona, movdia.sucursal
                      INTO v_cNumCte,  v_iSerial,v_cRfc,v_cCuenta,v_dFecha, v_mMontoTot, vcTpoPersona, vSucursal
                      FROM bdicheq:sc_movhis movdia,
                           bdicheq:sc_maechq maechq,
                           bdinteg:si_cliente cliente,
                           bdilide:sl_prodlide prodlide
                 --- INNER JOIN bdicheq:sc_maechq maechq ON maechq.cuenta = movdia.cuenta
                 --- INNER JOIN bdinteg:si_cliente cliente ON cliente.numcte = maechq.num_cte
                 --- INNER JOIN bdilide:sl_prodlide prodlide ON prodlide.producto = movdia.producto
                     WHERE movdia.fech_alt >= '01-19-2008' 
                       AND movdia.fech_alt <= '10-19-2008'
                       AND movdia.folio_suc IS NOT NULL
                       AND movdia.monto_tot > 0
                       AND movdia.transacc_suc = viDepositoEfect 
                       AND movdia.cancelad <> 'S' 
                       AND (movdia.producto='1800' OR movdia.producto='1700' OR movdia.producto='1500')
                       AND maechq.cuenta = movdia.cuenta
                       AND cliente.numcte = maechq.num_cte
                       AND prodlide.producto = movdia.producto
                       AND prodlide.aplica_lide = 'S'                       

                    IF vcTpoPersona = '02' THEN
                        -- // Checa si el cliente no esta exento o si el status está en cero.
                        SELECT {+INDEX(sl_exentos idx_exentos)} status 
                          INTO vcStatusExento 
                          FROM bdilide:sl_exentos 
                         WHERE num_cte = v_cNumCte
                           AND status = status;

                        IF (vcStatusExento IS NULL) OR ( vcStatusExento = '0') THEN
                            INSERT INTO bdilide:sl_movefec(aniomes,num_cte,num_serial,rfc,ref_ret,tipo_cta,num_cta,fecha_mov,imp_tot_dep,imp_ide,user_insert,fecha_insert, sucursal)
                            VALUES(v_cAniomes,v_cNumCte,v_iSerial,v_cRfc,"","D",v_cCuenta,v_dFecha,v_mMontoTot,v_mMontoTot,pCve_Usuario, CURRENT ::DATE, vSucursal);
                        END IF;
                    ELSE
                        INSERT INTO bdilide:sl_movefec(aniomes,num_cte,num_serial,rfc,ref_ret,tipo_cta,num_cta,fecha_mov,imp_tot_dep,imp_ide,user_insert,fecha_insert, sucursal)
                        VALUES(v_cAniomes,v_cNumCte,v_iSerial,v_cRfc,"","D",v_cCuenta,v_dFecha,v_mMontoTot,v_mMontoTot,pCve_Usuario, CURRENT ::DATE, vSucursal);
                    END IF;
                END FOREACH;
            ELSE
                LET v_cCod_Ret = "222";
                RETURN v_cCod_Ret;
            END IF;

        END FOREACH;

        UPDATE {+INDEX(sl_procesos idx_procesos)} 
               bdilide:sl_procesos 
           SET status = "1"  
         WHERE proceso = "extoptar_pp" 
           AND fech_proceso =  pFechaProceso
           AND status = status;
    ELSE
        LET v_cCod_Ret = "555";
    END IF; 

    END;

    RETURN v_cCod_Ret;

END PROCEDURE;