CREATE PROCEDURE "informix".sp_eoetarjetadebito_2200()
RETURNING CHAR(4);

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
    DEFINE  vcProceso       CHAR(10);
    DEFINE viDepositoEfect  CHAR(4);
    DEFINE vcTpoPersona     CHAR(2);
    DEFINE vcStatusExento   CHAR(1);
    DEFINE vSucursal        char(4);
    DEFINE vTranCentral     CHAR(4);
	DEFINE pCve_Usuario     CHAR(10);

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
    LET vcProceso	    = "";
    LET vcRfc2 		    = '';
    LET viDepositoEfect = '';
    LET vcTpoPersona    ='';
    LET vcStatusExento  = '';
    Let vSucursal       = '';
    LET vTranCentral    = '';
	LET pCve_Usuario    = 'informix';

    BEGIN
    
    ON EXCEPTION  SET vsqlerr
        IF vsqlerr <> 0  THEN
            LET  v_cCod_Ret  = vsqlerr;
            RETURN v_cCod_Ret;
        END IF;
    END  EXCEPTION;

    --- SET DEBUG FILE TO '/tmp/sp_EOETarjeasDebito.out';
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    LET v_cAniomes = '201301';
		
    -- // Obteniendo parámetro de la tabla de parametros lide.
    FOREACH  
        SELECT valor 
          INTO viDepositoEfect 
          FROM bdilide:sl_parametros 
         WHERE cve_param = "03"

        IF	viDepositoEfect IS NOT NULL AND viDepositoEfect <> "" THEN
            -- // extraer todos los mivimientos de deposito en efectivo con tarjeta de débito
            FOREACH  
                SELECT maechq.num_cte, movhis.num_serial, cliente.rfc, movhis.cuenta, movhis.fech_alt, movhis.monto_tot, cliente.tpo_persona, 
			           movhis.sucursal, movhis.transacc
                  INTO v_cNumCte,  v_iSerial,v_cRfc,v_cCuenta,v_dFecha, v_mMontoTot, vcTpoPersona, vSucursal, vTranCentral
                  FROM bdicheq:sc_movhis movhis,
                       bdicheq:sc_maechq maechq,
                       bdinteg:si_cliente cliente
                 WHERE movhis.fech_alt >= '01012013'
			       AND movhis.fech_alt <= '01212013'
				   AND movhis.folio_suc IS NOT NULL
                   AND movhis.monto_tot > 0
                   AND movhis.cancelad <> 'S'
                   AND movhis.transacc_suc = viDepositoEfect 
                   AND maechq.cuenta = movhis.cuenta
                   AND cliente.numcte = maechq.num_cte
                   AND movhis.producto = '2200'					   
                       
                    -- // Checa si el cliente no esta exento o si el status está en cero.
                IF vcTpoPersona <> '01' THEN
                   SELECT {+INDEX(sl_exentos idx_exentos)} status 
                     INTO vcStatusExento 
                     FROM bdilide:sl_exentos 
                    WHERE num_cte = v_cNumCte
                      AND status = status;
                                              
                    IF (vcStatusExento IS NULL) OR ( vcStatusExento = '0') THEN
                       INSERT INTO bdilide:sl_movefec
                       (aniomes,num_cte,num_serial,rfc,ref_ret,tipo_cta,num_cta,fecha_mov,tran_central,imp_tot_dep,imp_ide,user_insert,fecha_insert, sucursal)
                       VALUES
                       (v_cAniomes,v_cNumCte,v_iSerial,v_cRfc,"","D",v_cCuenta,v_dFecha,vTranCentral,v_mMontoTot,v_mMontoTot,pCve_Usuario, CURRENT ::DATE, vSucursal);
                    END IF;
                ELSE
                   INSERT INTO bdilide:sl_movefec(aniomes,num_cte,num_serial,rfc,ref_ret,tipo_cta,num_cta,fecha_mov,tran_central,imp_tot_dep,imp_ide,user_insert,fecha_insert, sucursal)
                   VALUES(v_cAniomes,v_cNumCte,v_iSerial,v_cRfc,"","D",v_cCuenta,v_dFecha,vTranCentral,v_mMontoTot,v_mMontoTot,pCve_Usuario, CURRENT ::DATE, vSucursal);
                END IF;
            END FOREACH;
        ELSE
            LET v_cCod_Ret = "222";
            RETURN v_cCod_Ret;
        END IF;

    END FOREACH;
END;

RETURN v_cCod_Ret;

END PROCEDURE
;