CREATE PROCEDURE "informix".sp_cobrautocrd(pempresa  char(3),pusuario char(8) )
RETURNING  CHAR(5)        AS cod_ret,       
           CHAR(125)      AS mens_ret

DEFINE iSqlErr                       INTEGER;
DEFINE iIsamErr                      INTEGER;
DEFINE cErrorInfo                    CHAR(80);
DEFINE cCodRet                       CHAR(5);
DEFINE cCodRetAux                    CHAR(3);
DEFINE cMensajeRet                   CHAR(125);
DEFINE DecAux                        DECIMAL(18,2);
DEFINE ChaAux                        CHAR(20);
DEFINE dMontoInt                     DECIMAL(18,2);
DEFINE dCuentaCap                    CHAR(20);
DEFINE dAplicaReverso                INTEGER;
DEFINE dSeAplicoReverso              INTEGER;
DEFINE dMontoPag                     DECIMAL(18,2);
DEFINE credcontproc                  CHAR(10);
DEFINE intecontproc                  CHAR(10);
DEFINE dtFechaHoy                    DATE;

----------------------- Datos General ------------------------------------------------------
DEFINE GLOBAL g_Empresa              CHAR(3)        DEFAULT "001";
DEFINE GLOBAL g_NumCred              CHAR(20)       DEFAULT "";
DEFINE GLOBAL g_Sucursal             CHAR(4)        DEFAULT "";
DEFINE GLOBAL g_NumProd              CHAR(4)        DEFAULT "";
DEFINE GLOBAL g_Divisa               CHAR(2)        DEFAULT "";
DEFINE GLOBAL g_dtFechaHoy           DATE           DEFAULT "";
DEFINE GLOBAL g_CodFun               CHAR(3)        DEFAULT "";
DEFINE GLOBAL g_Folio                CHAR(16)       DEFAULT "";
DEFINE GLOBAL g_TransaccSuc          CHAR(4)        DEFAULT "0000";
DEFINE GLOBAL g_ProvIntFinMes        DECIMAL(18,2)  DEFAULT 0;
DEFINE GLOBAL g_ProvIvaFinMes        DECIMAL(18,2)  DEFAULT 0;

DEFINE GLOBAL g_StatusCred           CHAR(2)        DEFAULT "";
DEFINE GLOBAL g_montofinanciado      MONEY(14,2)  DEFAULT 0;
DEFINE GLOBAL g_FechaApertura        DATE           DEFAULT "";
DEFINE GLOBAL g_FechaProxPago        DATE           DEFAULT "";
DEFINE GLOBAL g_MontoVencido         MONEY(14,2)  DEFAULT 0;
DEFINE GLOBAL g_SdoTrasp             DECIMAL(18,2)  DEFAULT 0;
DEFINE GLOBAL g_IvaSuc               DECIMAL(5,3)   DEFAULT 0;
DEFINE GLOBAL g_Cuentamens           INTEGER        DEFAULT 0;
DEFINE  dtFVenta                     DATE;
DEFINE g_campo_trab3                 CHAR(10);
DEFINE  vlFechaBaja                  DATE;
--------------------------------------------------------------------------------------------

LET iSqlErr               = 0;
LET iIsamErr              = 0;
LET cErrorInfo            = "";
LET cCodRet               = "00000";
LET cMensajeRet           = "Se realizÃÂÃÂ³ el pago correctamente";
LET cCodRetAux            = "000";
LET dCuentaCap            = "";
LET dAplicaReverso        = 0;
LET dSeAplicoReverso      = 0;
LET dMontoPag             = 0;
LET credcontproc          = " ";
LET intecontproc          = " ";
--
LET dtFVenta              = DATE(1);
LET g_campo_trab3         = '';
LET vlFechaBaja           = DATE(1);

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = cErrorInfo;
          UPDATE "informix".sd_contproc
             SET status_proc = "C",
                 hora_fin    = CURRENT,
                 cod_ret     = cCodRet,
                 mensaje     = cMensajeRet
           WHERE empresa     = pEmpresa
             AND proceso     = "CobroAutRe"
             AND fecha       = dtFechaHoy;

          UPDATE bdinteg:sx_contproc
             SET status_proc = "C",
                 hora_fin    = CURRENT,
                 codret      = cCodRet
           WHERE empresa     = pEmpresa
             AND proceso     = "CobroAutRe"
             AND fecha       = dtFechaHoy;
      RETURN cCodRet,cMensajeRet;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "sp_cobrautocrd.out";
--TRACE ON;

-- Creo: Cristina Acosta Sotelo
-- Fecha: 20/04/21
-- Comentario: Se crea para separar el cobro normal del cobro automatico

    set isolation to dirty read;
    SET LOCK MODE TO WAIT 3;

    select fecha_hoy 
      into dtFechaHoy
      from sd_fechas
     where empresa=pempresa;

-- *******************************************************
--  INSERTA PARA EJECUCIÃÂÃÂN DE PROCESO                 *
-- *******************************************************
--INI CAS
        SELECT proceso  
        INTO intecontproc
        FROM bdinteg:sx_contproc
        WHERE fecha= dtFechaHoy and proceso ='CobroAutRe';

        SELECT proceso  
        INTO credcontproc
        FROM bdicred:sd_contproc
        WHERE fecha= dtFechaHoy and proceso ='CobroAutRe';

    IF (intecontproc = ' ' OR intecontproc  IS NULL)  AND (credcontproc = ' ' OR credcontproc  IS NULL) THEN
      INSERT INTO bdinteg:sx_contproc(empresa,proceso,fecha,sistema,status_proc,ejecutivo,hora_ini,hora_fin,codret) 
      VALUES ('001','CobroAutRe',dtFechaHoy,'06','I',pusuario,CURRENT,CURRENT,'000');

      INSERT INTO  sd_contproc(empresa,proceso,fecha,status_proc,ejecutivo,hora_inicio,hora_fin,cod_ret,mensaje)
      VALUES ('001','CobroAutRe',dtFechaHoy,'I',pusuario,CURRENT,CURRENT,'000','Iniciamos');
    else
        LET cMensajeRet="YA EJECUTADO ANTERIORMENTE";
        RETURN cCodRet,cMensajeRet;
    END IF;
--FIN CAS

     SELECT
         'cobroarr'||DAY(CURRENT)||MONTH(CURRENT)||SUBSTR(current,3,2)||
         SUBSTR(CURRENT,12,2)||substr(current,15,2)
         ||SUBSTR(current,18,2)
      INTO g_Folio
      FROM dual;

      LET g_Empresa = pempresa;

      DELETE FROM sd_log_cobroaut WHERE fecha_proceso=dtFechaHoy AND proceso='CobroAutRe';

    SELECT empresa,sucursal,iva FROM bdinteg:si_sucursales
     WHERE tpo_sucursal = "S"
      INTO TEMP pa_sucursales with no log;
    CREATE INDEX pasucursal on pa_sucursales (empresa, sucursal);
 

FOREACH WITH HOLD
    SELECT a.num_credito,a.status_cred,a.sucursal,a.num_producto, a.divisa, c.fecha_proceso,
           b.monto_financiado,a.fecha_apertura,c.prox_fecha_pago,(b.monto_vencido + b.mto_venc_trasp),cap_tras_no_venci,
           provision_normal,sdo_global_int , a.campo_trab3
      INTO g_NumCred, g_StatusCred, g_Sucursal, g_NumProd, g_Divisa, g_dtFechaHoy,
           g_montofinanciado,g_FechaApertura,g_FechaProxPago,g_MontoVencido,g_SdoTrasp,
           g_ProvIntFinMes, g_ProvIvaFinMes, g_campo_trab3
           
      FROM "informix".sd_maecredcrd a,
           "informix".sd_maesdoscrd b,
           "informix".sd_maecredanexocrd c
     WHERE a.empresa       = g_Empresa
       AND a.status_cred   NOT IN ('FF','FC','CV')
       AND b.empresa       = a.empresa
       AND b.num_credito   = a.num_credito
       AND c.num_credito   = b.num_credito
       AND c.empresa       = b.empresa
       AND a.num_producto  IN ('6011','8600')
	   AND b.monto_financiado > 0

        /*IF (g_montofinanciado <= 0 and dATR <= 0) THEN
           CONTINUE FOREACH;
        END IF;*/

        IF g_campo_trab3 = 'BAJA' THEN 
          SELECT max(Fecha_baja) 
            INTO vlFechaBaja
            FROM bdicobranza:cb_rep_cart_quebrantar
           WHERE num_credito = g_NumCred
             AND Fecha_baja is not null;   --fmv 26feb14
          IF ( nvl(vlFechaBaja, date(1)) = dtFechaHoy   ) THEN
            CONTINUE FOREACH;
          END IF;
        END IF;

             LET dAplicaReverso = 0;
             LET dMontoPag      = 0;
             LET cCodRetAux     = '000';

                SELECT iva INTO g_IvaSuc
                  FROM pa_sucursales
                 WHERE empresa=g_Empresa
                   AND sucursal=g_Sucursal;

            SELECT SUM(interes_debe - interes_pagado + iva_debe - iva_pagado + mora_sdo_ordi - mora_sdo_ordi_pag + mora_sdo_cope - mora_sdo_cope_pag) + 
                   (sum( mora_sdo_ordi - mora_sdo_ordi_pag + mora_sdo_cope - mora_sdo_cope_pag)*g_IvaSuc),count(*)
              INTO dMontoInt,g_Cuentamens         
              FROM "informix".sd_amortiza_creditocrd
             WHERE empresa     = g_Empresa
               AND num_credito = g_NumCred
               AND capital_status IN ('2','7','1','6');
               
            LET g_montofinanciado = g_montofinanciado + dMontoInt;

           IF g_montofinanciado > 0 and g_Cuentamens > 0 THEN

                EXECUTE PROCEDURE "informix".sp_principal_rr(g_Empresa, g_NumCred, 2, g_montofinanciado, pusuario, '9290', g_Folio, '7432')
                INTO cCodRet,cMensajeRet,DecAux,DecAux,DecAux,DecAux, DecAux, DecAux, DecAux, DecAux, DecAux, DecAux, dMontoPag,dCuentaCap, DecAux, DecAux, ChaAux;

                IF cCodRet <> "00000" THEN 

                   select aplica_reverso
                     into dAplicaReverso
                     from sd_reversa_error
                     where num_producto=g_NumProd
                       and codigo=cCodRet;

                    IF dAplicaReverso>0 THEN
                       EXECUTE PROCEDURE bdicheq:reversion (g_Empresa,'9290',pusuario, g_Folio,"A")
                       INTO cCodRetAux;
                       IF cCodRetAux<>"000" THEN
                          LET dSeAplicoReverso = 0;
                       ELSE
                          LET dSeAplicoReverso = 1;
                       END IF;
                    END IF;
               END IF;

               Insert into "informix".sd_log_cobroaut 
               (sistema,proceso,fecha_proceso,hora_proceso,usuario_proceso,num_credito,cuenta,reverso_cap,folio,monto,codretcred,codretcheq,descripcion)
               values ('06','CobroAutRe',dtFechaHoy,current,pusuario,g_NumCred,dCuentaCap,dSeAplicoReverso,g_Folio,dMontoPag,cCodRet,cCodRetAux,cMensajeRet);

           END IF;
     
END FOREACH;

    drop table pa_sucursales;

    LET cCodRet               = "000";
    LET cMensajeRet           = "Se realizo el pago correctamente";

   UPDATE "informix".sd_contproc
       SET status_proc = "F",
           hora_fin    = CURRENT,
           cod_ret     = cCodRet,
           mensaje     = cMensajeRet
     WHERE empresa     = pempresa
       AND proceso     = "CobroAutRe"
       AND fecha       = dtFechaHoy;

    UPDATE bdinteg:sx_contproc
       SET status_proc = "F",
           hora_fin    = CURRENT,
           codret      = cCodRet
     WHERE empresa     = pempresa
       AND proceso     = "CobroAutRe"
       AND fecha       = dtFechaHoy;

  RETURN cCodRet,cMensajeRet;

END
END PROCEDURE;