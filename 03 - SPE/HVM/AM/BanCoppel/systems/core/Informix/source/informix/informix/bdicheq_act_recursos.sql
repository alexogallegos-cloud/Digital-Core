CREATE PROCEDURE "informix".act_recursos(pEmpresa char(3), pNumeroCuenta char(20),pProc_aper char(2),
                                         pProc_man char(2),pMonto_men char(2),pDep_cant char (2),
                                         pDep_mon char(2),pRet_cant char(2),pRet_mon char(2))

        -- DATOS A REGRESAR --
        RETURNING
        char(5);    -- Codigo de retorno

        --DEFINICION DE VARIABLES --
        DEFINE  vcodret char(5);

        -- INICIALIZACION DE VARIABLES --

        LET vcodret  ="";

        if exists (select cuenta from bdicheq:sc_maechq where cuenta = pNumeroCuenta) Then

           update bdicheq:sc_maechq
           set proced_aperturacta = pProc_aper,proced_mantenercta =pProc_man ,monto_mensual=pMonto_men,
               depositos_cantidad=pDep_cant,depositos_monto=pDep_mon,retiros_cantidad=pRet_cant,retiros_monto =pRet_mon
           where cuenta = pNumeroCuenta;

         let vcodret = "134";
         RETURN vCodRet;

       end if;

END PROCEDURE
;