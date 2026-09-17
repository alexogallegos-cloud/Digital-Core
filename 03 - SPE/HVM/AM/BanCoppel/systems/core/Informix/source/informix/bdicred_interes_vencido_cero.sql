CREATE PROCEDURE "informix".interes_vencido_cero(pempresa CHAR(3))
RETURNING CHAR(6)


----definicion de variables 
    DEFINE cCodRet          CHAR(6);
    DEFINE iSqlErr          INTEGER;
    DEFINE cMensaje         CHAR(250);
    DEFINE v_folio	        CHAR(16);
    DEFINE vcredito         CHAR(20);
    DEFINE vestatus         CHAR(2);
    DEFINE interes_vencido  DECIMAL(18,2);
    DEFINE iva_vencido      DECIMAL(18,2);
    DEFINE vsucursal        CHAR(4);
    DEFINE vcodigo_fun      CHAR(3);
    DEFINE vcodigo_ref      INTEGER;

        ON EXCEPTION SET iSqlErr
           IF iSqlErr != 0 THEN
              ROLLBACK;
              LET cCodRet=iSqlErr;
              RETURN cCodRet;
           END IF;
        END EXCEPTION;

  --      SET DEBUG FILE TO "condona_interes.out";
  --      TRACE ON;

----inicializacion

    LET cCodRet='000000';
    LET vcodigo_fun='005';

	set isolation to dirty read;
	set lock mode to wait 5;

    FOREACH WITH HOLD 
        select a.num_credito, status_cred, int_tra_no_exig,
        (select sum(iva_debe - iva_pagado) from bdicred:sd_amortiza_credito 
         where a.empresa = empresa and a.num_credito = num_credito 
         and fecha_cuota < mdy('02','20','2009')),a.sucursal
         into vcredito, vestatus,interes_vencido,iva_vencido,vsucursal
        from bdicred:sd_maecred a,
             bdicred:sd_maesdos b
        where a.empresa=pempresa
          and a.empresa = b.empresa
          and a.num_credito = b.num_credito
          and a.status_cred in ('AA','BA')
          and int_tra_no_exig > 0

    BEGIN WORK;

        UPDATE bdicred:sd_maesdos
        SET int_tra_no_exig=0
        WHERE empresa=pempresa
        AND num_credito=vcredito;

        LET v_folio='ints'||vcredito;
        LET vcodigo_ref=13;

        EXECUTE PROCEDURE GENMOV( pempresa         , vcredito,
                                  ''       ,vcodigo_ref,
                                  vcodigo_fun      , today,
                                  interes_vencido    , v_folio,
                                  vsucursal        ,'',
                                  "0000")
        INTO cCodRet,cMensaje;


        UPDATE bdicred:sd_amortiza_credito
        SET interes_pagado=interes_debe,
            iva_pagado=iva_debe,
            interes_status= (case when interes_status='3' then '5' else interes_status end),
	        campo_trabajo2= (case when interes_status='3' then 1 else 0 end),
            campo_trabajo3= interes_pagado,
            campo_trabajo4= iva_pagado
        WHERE empresa=pempresa
        AND num_credito=vcredito
        AND fecha_cuota<mdy('02','20','2009')
        and ( interes_pagado<>interes_debe or iva_pagado<>iva_debe);

        LET v_folio='ivav'||vcredito;
        LET vcodigo_ref=14;

        EXECUTE PROCEDURE GENMOV( pempresa         , vcredito,
                                  ''       ,vcodigo_ref,
                                  vcodigo_fun     , today,
                                  iva_vencido    , v_folio,
                                  vsucursal        ,'',
                                  "0000")
        INTO cCodRet,cMensaje;

    COMMIT WORK;

    END FOREACH;
     RETURN cCodRet;
END PROCEDURE;