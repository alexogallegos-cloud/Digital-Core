CREATE PROCEDURE "informix".sp_complivaintvenci(pempresa CHAR(3))
RETURNING CHAR(6)


----definicion de variables 
    DEFINE cCodRet              CHAR(6);
    DEFINE iSqlErr              INTEGER;
    DEFINE cMensaje             CHAR(250);
    DEFINE v_folio              CHAR(16);
    DEFINE vcredito             CHAR(20);
    DEFINE vfechacuota          DATE;
    DEFINE interes_vencido      DECIMAL(18,2);
    DEFINE iva_vencido_ant      DECIMAL(18,2);
    DEFINE cinteres_grav        DECIMAL(18,2);
    DEFINE iva_vencido_new      DECIMAL(18,2);
    DEFINE comple_iva           DECIMAL(18,2);
    DEFINE iva_total            DECIMAL(18,2);
    DEFINE vsucursal            CHAR(4);
    DEFINE NumProducto          CHAR(4);
    DEFINE v_plaza              VARCHAR(3);

        ON EXCEPTION SET iSqlErr
           IF iSqlErr != 0 THEN
              ROLLBACK;
              LET cCodRet=iSqlErr;
              RETURN cCodRet;
           END IF;
        END EXCEPTION;

      --  SET DEBUG FILE TO "iva_interes.out";
      --  TRACE ON;

----inicializacion

    LET cCodRet='000000';
    LET iva_total=0;
    LET comple_iva=0;
    LET cinteres_grav=0;
    LET iva_vencido_new=0;
    LET iva_vencido_ant=0;

   SELECT plaza
   INTO   v_plaza
   FROM   bdinteg:si_sucursales
   WHERE  empresa  = pempresa
   AND    sucursal = '9250';


	set isolation to dirty read;
	set lock mode to wait 3;

    FOREACH WITH HOLD 
        select num_credito,sucursal,num_producto
         into vcredito,vsucursal,NumProducto
        from bdicred:sd_maecred 
        where empresa=pempresa
          and status_cred ='BT'
  --        and sucursal='0002'


       BEGIN WORK;

          FOREACH
            select iva_debe-iva_pagado,fecha_cuota
             into iva_vencido_ant,vfechacuota
            from bdicred:sd_amortiza_credito
            where empresa=pempresa
              and num_credito = vcredito
              and capital_status = '2'
              and (iva_debe-iva_pagado)>0
 
              LET cinteres_grav = iva_vencido_ant/0.15;
              LET iva_vencido_new = cinteres_grav * 0.16;
              LET comple_iva = iva_vencido_new-iva_vencido_ant;

                UPDATE bdicred:sd_amortiza_credito
                SET iva_debe = iva_debe+comple_iva,
                    campo_trabajo2 = comple_iva
                WHERE empresa=pempresa
                AND num_credito=vcredito
                AND fecha_cuota=vfechacuota;
                
               LET iva_total=iva_total+comple_iva;

          END FOREACH;

          LET v_folio='ivac'||vcredito;
          
          IF iva_total>0 THEN
            CALL genmovcierre_movdia(pEmpresa, vcredito, NumProducto,22,
                      340, mdy('01','02','2010'), iva_total, v_folio,
                        vsucursal, '01', "0000",v_plaza)
             RETURNING cCodRet,cMensaje;
          END IF;

        LET iva_total=0;
        LET comple_iva=0;

    COMMIT WORK;

    END FOREACH;
     RETURN cCodRet;
END PROCEDURE;