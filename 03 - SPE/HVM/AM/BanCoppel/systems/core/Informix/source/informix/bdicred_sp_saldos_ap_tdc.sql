CREATE PROCEDURE "informix".sp_saldos_ap_tdc(pEmpresa  CHAR (3),pNumcte CHAR (20))
  RETURNING CHAR (5), -- Codigo de retorno
            CHAR(40), -- Nombre producto
            CHAR(20), -- Numero credito
            CHAR(20), -- Numero tarjeta
            DECIMAL (14,2), -- 1 = Saldo al Cierre
            DECIMAL (14,2), -- 2 = Pago para no generar intereses
            DECIMAL (14,2), -- 3 = pago minimo al corte
            DECIMAL (14,2); -- 5 = Saldo actual TDC

 -- DEFINICION DE VARIABLES --
DEFINE sSqlErr SMALLINT;
DEFINE cCodRet CHAR(5);
DEFINE dSaldoCierre     DECIMAL (14,2);
DEFINE dPagonoInteres   DECIMAL (14,2);
DEFINE dMinimoCorte     DECIMAL (14,2);
DEFINE dSaldoActual     DECIMAL (14,2);
DEFINE nNumeroCredito   char(20);
DEFINE nNumeroTarjeta   char(20);
DEFINE cNombreProducto  char(40);
DEFINE cNumProducto     char(04);
DEFINE nContador        smallint;


LET sSqlErr = 0;
LET cCodRet = '00000';

LET dSaldoCierre    = 0;
LET dPagonoInteres  = 0;
LET dMinimoCorte    = 0;
LET dSaldoActual    = 0;
LET nNumeroCredito  = '';
LET nNumeroTarjeta  = '';
LET cNombreProducto = '';
LET cNumProducto    = '';
LET nContador       = 0;


BEGIN

    ON EXCEPTION SET sSqlErr
        LET cCodRet = sSqlErr;
        RETURN cCodRet, cNombreProducto, nNumeroCredito, nNumeroTarjeta, dSaldoCierre, dPagonoInteres, dMinimoCorte, dSaldoActual;
    END EXCEPTION;
	
	SET LOCK MODE TO wait 3;
	SET ISOLATION TO dirty READ;
	
	
    FOREACH 
        select num_credito, num_producto
          into nNumeroCredito, cNumProducto
          from bdicred:"informix".sd_maecred
         where numcte = pNumcte
           and status_cred in ('AA','BA','BT','E1','E2','E3')
           and num_producto in ('6001','6600','8100','7000','8500')

        let nContador = nContador + 1;

        select num_tarjeta
          into nNumeroTarjeta
          from bdicred:"informix".sd_tarjeta
         where num_credito = nNumeroCredito
           and tipo_tarjeta = 'T'
           and secuencia = (select max(secuencia) from bdicred:"informix".sd_tarjeta where num_credito = nNumeroCredito and tipo_tarjeta = 'T');

        select nombre_prod
          into cNombreProducto
          from bdicred:"informix".sd_definicion
         where num_producto = cNumProducto;

         let cNombreProducto = trim(cNombreProducto);

        execute procedure bdicred:sp_consultasaldocortemin(pEmpresa,nNumeroCredito,1) into cCodRet, dSaldoCierre;    --                1 = Saldo al Cierre
        execute procedure bdicred:sp_consultasaldocortemin(pEmpresa,nNumeroCredito,2) into cCodRet, dPagonoInteres;  --                2 = Pago para no generar intereses
        execute procedure bdicred:sp_consultasaldocortemin(pEmpresa,nNumeroCredito,3) into cCodRet, dMinimoCorte;    --                3 = pago minimo al corte
        execute procedure bdicred:sp_consultasaldocortemin(pEmpresa,nNumeroCredito,5) into cCodRet, dSaldoActual;    --                5 = Saldo actual TDC 

        RETURN cCodRet, cNombreProducto, nNumeroCredito, nNumeroTarjeta, dSaldoCierre, dPagonoInteres, dMinimoCorte, dSaldoActual WITH RESUME;
    END FOREACH;

    if (nContador = 0) then
       let cCodRet = '00001'; -- No cuenta con credito activos o asociados
       RETURN cCodRet, cNombreProducto, nNumeroCredito, nNumeroTarjeta, dSaldoCierre, dPagonoInteres, dMinimoCorte, dSaldoActual WITH RESUME;
    end if;

END;
END PROCEDURE;