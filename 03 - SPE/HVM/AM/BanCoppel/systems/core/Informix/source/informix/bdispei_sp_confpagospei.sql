CREATE PROCEDURE "informix".sp_confpagospei(
                              --->p_sucursal CHAR(3),
                              p_sucursal CHAR(4),
                              p_usuario  CHAR(8),
			      p_folprom CHAR(16),
			      p_folliq  CHAR(16))
                              RETURNING CHAR(5);
{
CREADO POR : Arturo Salinas
FECHA CREACION : 23 de Septiembre del 2003
FUNCIONALIDAD : Liquidar el pago de SPEI con el folio 
   solicitado en la fecha de operacion.
MODIFICACION: Daniel Chirinos Lopez
              L-18/sep/2006
              - Se modifico la sucursal de char(3) a char(4)

}

-- ************* Definicion de Variables ************************************

DEFINE v_codret        CHAR(5);
DEFINE sql_err         INTEGER;
DEFINE v_hora datetime HOUR TO SECOND;
DEFINE v_importe       MONEY(14,2);
DEFINE v_ctapropia     CHAR(20);
DEFINE v_producto      CHAR(4);
DEFINE v_status        CHAR(1);
DEFINE vchrParametro   VARCHAR(255);
DEFINE vchrFechaHoy    VARCHAR(10);
DEFINE intTpoPago      INTEGER;
DEFINE chrAbonaChq     CHAR(1);
--->DEFINE chrSucursal     CHAR(3);
DEFINE chrSucursal     CHAR(4);
DEFINE intFolioLiq     INTEGER;
DEFINE chrCodSistema   CHAR(2);
DEFINE chrCodSisSPEI   CHAR(2);

-- **************************************************************************
DEFINE v_chrtransaccion CHAR(4);	-- Cve de transaccion de Cargo X SPEI
DEFINE v_mnymonto       MONEY;		-- Monto a cobrar de la comision
DEFINE v_chrtranret     CHAR(4);	-- Cve de transaccion retornada por cargo comision
DEFINE v_dteCobroCom    DATE;		-- Fecha retornada por el cobro de comision
DEFINE v_mnySdoDisp     MONEY;          -- Saldo disponible 
DEFINE v_mnyMontoRet    MONEY;		--  monto retenido en la cta X cobro comision


--     set debug file to "/tmp/liquida_pago.out";
--     trace on;

LET chrCodSisSPEI = '14';
LET chrCodSistema = chrCodSisSPEI;
LET v_codret = "000";
LET v_status ="";

BEGIN
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         LET v_codret = sql_err;
         RETURN v_codret;
      END IF
   END EXCEPTION;


   SELECT vchrvalor INTO vchrParametro FROM tblparametros 
     WHERE vchrcveparametro = 'FECHA_OPERACION';
        
   LET vchrFechaHoy = SUBSTR(vchrParametro,4,2) || '/' || 
     SUBSTR(vchrParametro,0,2) || '/' || SUBSTR(vchrParametro,7,4);

   SELECT vchrvalor INTO vchrParametro FROM tblparametros 
     WHERE vchrcveparametro = 'TRANS_COMISION';
   IF vchrParametro IS NULL OR vchrParametro = '' THEN
     RETURN '001';
   END IF;
   LET v_chrtransaccion = TRIM(vchrParametro);  
-- ************************************************************************

   --Valida que no se repita el folio de liquidacion en la fecha de proceso
   SELECT COUNT(*) INTO intFolioLiq FROM tblpago 
     WHERE chrfolioliqu = p_folliq AND dtfechavalor = vchrFechaHoy;
   IF intFolioLiq > 0 THEN 
     RETURN '016'; -- ya existe el folio de liquidacion para esa fecha
   END IF;  

   --Obtiene datos de pago y de la cuenta
   SELECT SUBSTR(a.vchrcuentaord,7,11), a.mnyimporte, b.producto,
          a.chrestatusenvio, a.intcvetipopago, b.sucursal
      INTO v_ctapropia, v_importe, v_producto, v_status, intTpoPago, chrSucursal
      FROM tblpago a, OUTER bdicheq:sc_maechq b
      WHERE a.chrfolioprom = p_folprom
      AND b.cuenta = SUBSTR(a.vchrcuentaord,7,11)
      AND dtfechavalor = vchrFechaHoy;
      
-- Si el status de la orden es "P" Pendiente de Liquidar, proceder con 
-- la liquidacion, caso contrario retornar error 145.
IF v_status = "P" THEN
   -- Cobro de comision de SPEI
   -- Obtener el importe y transaccion de la comision a cobrar
   SELECT mnycomision INTO v_mnymonto FROM tblcomision 
     WHERE mnymontomin <= v_importe AND mnymontomax >= v_importe
     AND tmhoramin <= CURRENT HOUR TO SECOND AND tmhoramax >= CURRENT HOUR TO SECOND;
   
   IF v_mnymonto IS NULL OR v_mnymonto <= 0 THEN
     --RETURN '015';
     LET v_mnymonto = 0;
   END IF;
   --Verifica si el tipo de pago permite el cargo a cheques
   SELECT chrDevabonachq INTO chrAbonaChq FROM tbltipopago WHERE intcvetipopago = intTpoPago;
   
   IF chrAbonaChq = '1' AND v_mnymonto > 0 THEN
   	-- Ejecutar cargo a cheques para la comision
    	
   	LET v_codret = "000";
   	LET chrCodSistema = '01';
   	FOREACH 
      	EXECUTE PROCEDURE bdicheq:cargo_ref(chrSucursal,p_usuario,v_chrtransaccion,
      	  v_chrtransaccion,p_folliq,v_ctapropia,0,v_mnymonto,"01","Rastreo: " ||p_folprom)
          INTO v_codret, v_chrtranret,v_dteCobroCom,v_mnySdoDisp,v_mnyMontoRet
          
     	END FOREACH   
        LET chrCodSistema = chrCodSisSPEI;
     	-- Valida si se pudo realizar el cargo de la comision e IVA
     	IF v_codret <> '000' THEN
      	  RETURN v_codret;
     	END IF;
     	-- Fin Cobro de comision del pago por SPEI
   END IF;

   -- Actualiza el pago como liquidado
   UPDATE tblpago SET chrestatusenvio = "N", chrfolioliqu = p_folliq
     WHERE chrfolioprom = p_folprom AND dtfechavalor = vchrFechaHoy;
ELSE
   LET v_codret = "145";
END IF;
RETURN v_codret;

-- ***********************************************************************
END
END PROCEDURE;