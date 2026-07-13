CREATE PROCEDURE "informix".sp_eoetarjetacredito( pEmpresa CHAR(3), pFechaProceso DATE, pCveUsuario CHAR(8) )
RETURNING CHAR(4);
     
    -- "999" significa que el proceso ya se ha ejecutado
    -- "000" significa que el proceso se ejecuto correctamente
    -- "110" Significa Parametro Transacc_suc No Existe
    -- "100" Indica que el proceso EOTD aun no se ha ejecutado
    -- "200" Indica que la fecha que se recibio como parametro de entrada es nula.
    -- "300" Indica que el Parametro codigo_fun No Existe
    -- "400" Indica que el Parametro Codigo_ref No Existe
    -- "500" Indica que la fecha es mayor a la fecha actual
    
    DEFINE vmSalDisp        DECIMAL(14,2);
    DEFINE vcCodRet         CHAR(5);
    DEFINE vcAnioMes        CHAR(6);
    DEFINE vcNumCte         CHAR(20);
    DEFINE viNumSerial      INTEGER ;
    DEFINE vcRfc            CHAR(13);
    DEFINE vcTipoCta        CHAR(1);
    DEFINE vcNumCta         CHAR(20);
    DEFINE vdFechaMov       DATE ;
    DEFINE vmImpTotDep      MONEY(10,2);
    DEFINE vmImpIde         MONEY(10,2);
    DEFINE vcStatus         CHAR(1);
    DEFINE vcProceso        CHAR(10);
    DEFINE vmSaldo          MONEY(10,2);
    DEFINE vmSaldoAnt       MONEY(10,2);
    DEFINE vmNumTarjeta     CHAR(12);
    DEFINE vsqlerr          INTEGER ;
    DEFINE vcTransaccSuc    CHAR(4);
    DEFINE vcCodigoFun      CHAR(4);
    DEFINE viCodigoRef      INTEGER;
    DEFINE vcTpoPersona     CHAR(2);
    DEFINE vcCodFun         CHAR(6);
    DEFINE vcCodRef         CHAR(6);
    DEFINE vcEmpresa        CHAR(3);
    DEFINE vcAplicaLide     CHAR(1);
    DEFINE vSucursal        CHAR(4);
    DEFINE vcFlagCommit     CHAR(1);
    DEFINE vcStatusExento   CHAR(1);

    LET vmSalDisp       = 0.00;
    LET vcCodRet        = "000";
    LET vcAnioMes       = '';
    LET vcNumCte        = '';
    LET viNumSerial     = 0;
    LET vcRfc           = '';
    LET vcTipoCta       = '';
    LET vdFechaMov      = '';
    LET vmImpTotDep     = 0.00;
    LET vmImpIde        = 0.00;
    LET vcStatus        = '';
    LET vcProceso       = '';
    LET vmSaldo         = 0.00;
    LET vmSaldoAnt      = 0.00;
    LET vmNumTarjeta    = '';
    LET vsqlerr         = 0;
    LET vcTransaccSuc   = "";
    LET vcCodigoFun     = "";
    LET viCodigoRef     = 0;
    LET vcTpoPersona    = "";
    LET vcCodFun        = "";
    LET vcEmpresa       = "001";
    LET vcAplicaLide    = "S";
    LET vcFlagCommit    = "";
    LET vSucursal       = "";
    LET vcStatusExento  = '';
    
    BEGIN
    
    ON EXCEPTION  SET vsqlerr
        IF vsqlerr <> 0  THEN
            LET  vcCodRet  = vsqlerr;
            IF vcFlagCommit = "S" THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcCodRet;
        END IF;
    END  EXCEPTION;
    
    --- SET DEBUG FILE TO "/tmp/sp_EOETarjetasCredito.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF pFechaProceso IS NULL  OR pFechaProceso = ""  then
        RETURN  "200" ;
    END IF;
    
    IF pFechaProceso > CURRENT::DATE THEN
        RETURN "500";
    END IF;
    
    /* ####################################################################
    -- // Valida que se haya ejecutado el proceso "EOTD"
    SELECT {+INDEX(sl_procesos idx_procesos)} status
      INTO vcStatus
      FROM bdilide:sl_procesos
     WHERE proceso = "extoptar_d"
       AND fech_proceso = pFechaProceso
       AND status = status;

    IF vcStatus = "0" OR vcStatus IS NULL OR vcStatus = "" THEN
        LET vcCodRet = "100"; -- El proceso de EOTD no se ha ejecutado
        RETURN vcCodRet;
    END IF;
    #################################################################### */
    
    LET vcStatus = "";
    
    SELECT {+INDEX(sl_procesos idx_procesos)} proceso, status
      INTO vcProceso, vcStatus
      FROM bdilide:sl_procesos
     WHERE proceso = "extoptar_c"
       AND fech_proceso = pFechaProceso
       AND status = status;

    IF vcProceso = "extoptar_c" THEN
        IF vcStatus = '1' THEN
            -- // proceso ya se ejecutó anteriormente
            RETURN "999";
        ELSE
        -- // borra  los movimientos de esa fecha de cuando es tipo de cuenta Crédito
            DELETE {+INDEX(sl_movefec i_101)}
              FROM bdilide:sl_movefec
             WHERE tipo_cta = 'C'
               AND fecha_mov = pFechaProceso;
        END IF ;
    ELSE
        -- // Se inserta el proceso de deposito en efectivo
        INSERT INTO bdilide:sl_procesos VALUES( "extoptar_c",pFechaProceso,'0',pCveUsuario,CURRENT::DATE);
    END IF ;

    LET vcAniomes = SUBSTRING(pFechaProceso from 7 for 10) || SUBSTRING(pFechaProceso  from 1 for 2);

	SELECT {+INDEX(bdicred:sd_maesdos idx_sd_maesdos)}
           num_credito, (sdo_capital + monto_vencido + mto_venc_trasp + cap_tras_no_venci) AS SalDisp
      FROM bdicred:sd_maesdos
     WHERE num_credito IS NOT NULL
       AND empresa = pEmpresa
       AND (sdo_capital + monto_vencido + mto_venc_trasp + cap_tras_no_venci) < 0
      INTO TEMP tmp_sdofavor WITH NO LOG;

    FOREACH WITH HOLD  -- // Obtener los parametros para extraer las operaciones de crédito
        SELECT valor
          INTO vcTransaccSuc
          FROM bdilide:sl_parametros
         WHERE cve_param = "10"

        IF vcTransaccSuc = ""  OR vcTransaccSuc IS NULL THEN
            LET vcCodRet = "110";
            RETURN vcCodRet;
        ELSE
            LET vcCodFun = trim(vcTransaccSuc)||''||"11";

            SELECT valor
              INTO vcCodigoFun
              FROM bdilide:sl_parametros
             WHERE cve_param = vcCodFun;

            IF vcCodigoFun = "" OR vcCodigoFun IS NULL THEN
                LET vcCodRet = "300";
                RETURN vcCodRet;
            ELSE
                LET vcCodRef = trim(vcTransaccSuc)||''||"12";

                SELECT valor
                  INTO viCodigoRef
                  FROM bdilide:sl_parametros
                 WHERE cve_param = vcCodRef;

                IF viCodigoRef = 0  OR viCodigoRef  IS NULL THEN
                    LET vcCodRet = "400";
                    RETURN vcCodRet;
                END IF;
            END IF;
        END IF;

        FOREACH WITH HOLD
            SELECT num_credito, SalDisp
              INTO vcNumCta, vmSalDisp
              FROM tmp_sdofavor

            SELECT {+INDEX(bdicred:sd_movdia mov3)}
                   mov.num_credito, mov.fecha_mov, SUM( nvl(mov.monto, 0))
              INTO vcNumCta, vdFechaMov, vmImpTotDep
              FROM bdicred:sd_movdia mov
             WHERE mov.empresa      = pEmpresa
               AND mov.num_credito  = vcNumCta
               AND mov.fecha_mov    = pFechaProceso
               AND mov.transacc_suc = vcTransaccSuc
               AND mov.codigo_fun   = vcCodigoFun
               AND mov.codigo_ref   = viCodigoRef
               AND mov.reversado    <> 'S'
             GROUP BY mov.num_credito, mov.fecha_mov; 

            LET vmImpIde = 0.00;

            IF vdFechaMov <> "" OR vdFechaMov IS NOT NULL THEN
                LET vmSaldo = vmSalDisp  * -1;

                IF vmSaldo >= vmImpTotDep THEN
                    LET vmImpIde = vmImpTotDep;
                ELIF vmSaldo < vmImpTotDep THEN
                    LET vmImpIde = vmSaldo;
                END IF;
            ELSE
                CONTINUE FOREACH;
            END IF;

            BEGIN WORK;
            LET vcFlagCommit = 'S';

            SELECT Maecred.numcte
              INTO vcNumCte
              FROM bdicred:sd_maecred Maecred
             WHERE Maecred.empresa = vcEmpresa
               AND Maecred.num_credito = vcNumCta;

            SELECT Cliente.rfc, Cliente.tpo_persona
              INTO vcRfc, vcTpoPersona
              FROM bdinteg:si_cliente Cliente
             WHERE Cliente.empresa = vcEmpresa
               AND Cliente.numcte = vcNumCte;

            SELECT {+INDEX(bdicred:sd_movdia mov3)}
                   MAX(secuencia)
              INTO viNumSerial
              FROM bdicred:sd_movdia
             WHERE empresa = pEmpresa
               AND num_credito = vcNumCta
               AND fecha_mov = pFechaProceso
               AND transacc_suc = vcTransaccSuc
               AND codigo_fun = vcCodigoFun
               AND codigo_ref = viCodigoRef
               AND reversado <> 'S';

            SELECT {+INDEX(bdicred:sd_movdia mov3)}
                   sucursal
              INTO vSucursal
              FROM bdicred:sd_movdia
             WHERE empresa = vcEmpresa
               AND num_credito = vcNumCta
               AND secuencia = viNumSerial;

            IF vSucursal is null then
                Let vSucursal = '';
            End if;

            IF vcTpoPersona <> "01" THEN
                SELECT {+INDEX(sl_exentos idx_exentos)} status
                  INTO vcStatusExento
                  FROM bdilide:sl_exentos
                 WHERE num_cte = v_cNumCte
                   AND status = status;
                
                IF (vcStatusExento IS NULL) OR ( vcStatusExento = '0') THEN
                    INSERT INTO bdilide:sl_movefec
                    (aniomes,num_cte,num_serial,rfc,ref_ret,tipo_cta,num_cta,fecha_mov,tran_central,imp_tot_dep,imp_ide,user_insert,fecha_insert, sucursal)
                    VALUES
                    (vcAnioMes,vcNumCte,viNumSerial,vcRfc,'','C',vcNumCta,vdFechaMov,vcTransaccSuc,vmImpTotDep,vmImpIde,pCveUsuario, CURRENT ::DATE, vSucursal);
                END IF ;
            ELSE
                INSERT INTO bdilide:sl_movefec
                (aniomes,num_cte,num_serial,rfc,ref_ret,tipo_cta,num_cta,fecha_mov,tran_central,imp_tot_dep,imp_ide,user_insert,fecha_insert, sucursal)
                VALUES
                (vcAnioMes,vcNumCte,viNumSerial,vcRfc,'','C',vcNumCta,vdFechaMov,vcTransaccSuc,vmImpTotDep,vmImpIde,pCveUsuario, CURRENT ::DATE, vSucursal);
            END IF;

            COMMIT WORK;
            LET vcFlagCommit = '';

        END FOREACH;

    END FOREACH;

    DROP TABLE tmp_sdofavor;

    IF vcCodRet <> "000" THEN
        RETURN vcCodRet;
    ELSE
        BEGIN WORK;
        LET vcFlagCommit = 'S';

        -- // Se actualiza el estado de 0 en 1 para indicar que se ejecutó el proceso completamente
        UPDATE {+INDEX(sl_procesos idx_procesos)}
               bdilide:sl_procesos
           SET status = '1'
         WHERE proceso = "extoptar_c"
           AND fech_proceso  = pFechaProceso
           AND status = status;

        -- // Inserta en la tabla de procesos
        INSERT INTO bdinteg:sx_contproc(empresa, proceso,fecha,sistema,status_proc,ejecutivo,hora_ini,hora_fin,codret)
        VALUES(pEmpresa,'Eocrlide',pFechaProceso,'23','F',pCveUsuario,current hour to fraction(3),current hour to fraction(3),vcCodRet);

        COMMIT WORK;
    END IF;

    END;

    RETURN vcCodRet;

END PROCEDURE;