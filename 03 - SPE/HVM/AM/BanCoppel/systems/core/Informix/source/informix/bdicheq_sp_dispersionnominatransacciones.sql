CREATE PROCEDURE "informix".sp_dispersionnominatransacciones( pTipEmpresa SMALLINT, pConcepto SMALLINT )
RETURNING CHAR(3), CHAR(3), CHAR(4), Money(16,2), CHAR(4), CHAR(4), CHAR(4), MONEY(16,2), MONEY(16,2), CHAR(4), MONEY(16,2); 
    
    DEFINE vCodRet          CHAR(3);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vCodRet3         CHAR(50);
    DEFINE iSqlErr          INTEGER;
    DEFINE iSamErr          INTEGER;
    DEFINE cDesErr          CHAR(50);
    DEFINE cTipoTransac     CHAR(3);
    DEFINE cTransaccion     CHAR(4);
    DEFINE cTransacAbono    CHAR(4);
    DEFINE cTransacCom      CHAR(4);
    DEFINE cTransacIva      CHAR(4);
    DEFINE cTransacCargo    CHAR(4);
    DEFINE mMontoFijo       MONEY(16,2);
    DEFINE mMontoCom        MONEY(16,2);
    DEFINE mMontoIva        MONEY(16,2);
    DEFINE mMontoComAper    MONEY(16,2);
    
    LET vCodRet       = "000";
    LET vCodRet2      = '';
    LET vCodRet3      = '';
    LET iSqlErr       = 0;
    LET iSamErr       = 0;
    LET cDesErr       = '';
    LET cTipoTransac  = "";
    LET cTransaccion  = "";
    LET cTransacAbono = "";
    LET cTransacCom   = "";
    LET cTransacIva   = "";
    LET cTransacCargo = "";
    LET mMontoFijo    = 0.00;
    LET mMontoCom     = 0.00;
    LET mMontoIva     = 0.00;
    LET mMontoComAper = 0.00;
    
    BEGIN
    
    ON EXCEPTION SET iSqlerr, iSamErr, cDesErr
        SET DEBUG FILE TO '/tmp/sp_dispersionnominatransacciones.err';
        TRACE ON;
        IF iSqlerr <> 0 THEN
            LET vCodRet  = iSqlerr; 
            LET vCodRet2 = iSamErr;
            LET vCodRet3 = cDesErr;
            RETURN vCodRet, cTipoTransac, cTransaccion, mMontoFijo, cTransacAbono, cTransacCargo, cTransacCom, mMontoCom, mMontoComAper, cTransacIva, mMontoIva;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ; 
    SET LOCK MODE TO WAIT 3; 
    
    --- SET DEBUG FILE TO '/tmp/sp_dispersionnominatransacciones.out';
    --- TRACE ON;
    
    /* EMPRESA EXTERNA */
    IF pTipEmpresa <> 2 THEN
        FOREACH
            SELECT nom.tipo_transaccion, nom.transacc, tran.monto_fijo 
              INTO cTipoTransac, cTransaccion, mMontoFijo
              FROM bdicheq:sc_nominatransacciones As nom,
                   bdinteg:si_transacc As tran
             WHERE nom.tipo_empresa = pTipEmpresa
               AND nom.tipo_codigo = pConcepto 
               AND nom.transacc = tran.numero
             ORDER BY nom.tipo_transaccion
            
            IF cTipoTransac   = '001'  THEN /* Aqui se traera el 0202 */
                LET cTransacAbono = cTransaccion;   
            ElIF cTipoTransac = '002'  THEN /* Aqui se traera el 0395 */
                LET cTransacCargo = cTransaccion;     
            ElIF cTipoTransac = '003'  THEN /* Aqui se traera el 0394 */
                LET cTransacCom = cTransaccion;   
                LET mMontoCom = mMontoFijo;
            ElIF cTipoTransac = '004'  THEN
                LET mMontoComAper = mMontoFijo;
            ElIF cTipoTransac = '005'  THEN /* Aqui se traera el 0396 */
                LET cTransacIva = cTransaccion;   
            ElIF cTipoTransac = '006'  THEN
                LET mMontoIva = mMontoFijo;
            END IF;
        END FOREACH;
        
        IF   ( cTransacAbono = "" Or cTransacAbono = " " Or cTransacAbono = "0" Or cTransacAbono Is Null ) THEN  /*  Transaccion Abono Invalida  */
            LET vCodRet = '840';  
        ElIF ( cTransacCargo = "" Or cTransacCargo = " " Or cTransacCargo = "0" Or cTransacCargo Is Null ) THEN  /*  Transaccion Cargo Invalida  */
            LET vCodRet = '845';  
        ElIF ( cTransacCom   = "" Or cTransacCom   = " " Or cTransacCom   = "0" Or cTransacCom   Is Null ) THEN  /*  Transaccion Comision Invalida  */
            LET vCodRet = '850';  
        ElIF ( cTransacIva   = "" Or cTransacIva   = " " Or cTransacIva   = "0" Or cTransacIva   Is Null ) THEN  /*  Transaccion Iva Invalida  */
            LET vCodRet = '855';  
        END IF;
    END IF;
    
    /* EMPRESA INTERNA O PROPIA */
    IF pTipEmpresa = 2 THEN
        SELECT nom.transacc 
          INTO cTransacAbono /* Aqui traera 0202 */
          FROM bdicheq:sc_nominatransacciones AS nom,
               bdinteg:si_transacc AS tran
         WHERE nom.tipo_empresa = pTipEmpresa
           AND nom.tipo_codigo = pConcepto 
           AND nom.tipo_transaccion = '001'
           AND nom.transacc = tran.numero;
        
        /*  Transaccion Abono Invalida  */
        IF ( cTransacAbono = "" OR cTransacAbono = " " OR cTransacAbono = "0" OR cTransacAbono IS NULL ) THEN
            LET vCodRet = '840';  
        END IF;
    END IF; 
    
    RETURN vCodRet, cTipoTransac, cTransaccion, mMontoFijo, cTransacAbono, cTransacCargo, cTransacCom, mMontoCom, mMontoComAper, cTransacIva, mMontoIva;
    
    END;
    
END PROCEDURE
    
DOCUMENT 
'DESCRIPCION: Retornar las transacciones a utilizar para la dispersion de nomina"', 
'AUTOR: Jesus Antonio Bastidas Lopez', 
'FECHA: Abril de 2009', 
'VERSION: 200904', 
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_consulta_nominatransacciones(pEmpresa char(3), pRegistros SMALLINT)
	returning char(5), char(3),integer, char(60);

	--****************************************************************************************************
	-- DESCRIPCION:  OBTIENE LA TRANSACCION PARA CONSULTAR EL CONCEPTO DE LA DISPERSION
	-- AUTOR : Francisco Rodríguez Ibarra
	-- FECHA : 26/08/2011
	-- BD: bdicheq
	-- SOLICITO :Mauricio León
	-- Modificado por: Berenice Noriega
	-- Fecha: 23 de Mayo 2014.
	-- Descripciòn: la busqueda de concepto se cambio por tipo de empresa en lugar de por cada empresa
	--****************************************************************************************************
	--DEFINICION DE VARIABLES
	DEFINE vCodRet char(5);
    DEFINE sql_err integer;
	DEFINE vTipoTran char(3);
	DEFINE iCodConcepto integer;
	DEFINE vDescripcion varchar(100);
	DEFINE iCont integer;
	DEFINE VTipEmpresa SMALLINT;
	
	
	--asigacion de valores a variables
	LET vCodRet='00000';
	LET vTipoTran='';
	LET vDescripcion='';
	LET iCont=0;
	LET iCodConcepto=0;
	LET VTipEmpresa=0;
	
	
	--*********************************************
	--- SET debug FILE TO "/home/informix/BereniceOut/sp_consulta_nominatransacciones.out";
	--- Trace ON;
	--*********************************************
	
	
	
  BEGIN


   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let vCodRet = sql_err;
            RETURN vCodRet, '',0, '';
      END IF ;
   END EXCEPTION ;
	
	SET LOCK MODE TO WAIT ;
	SET ISOLATION DIRTY READ ;
	
	
	
	---Sacar el tipo de empresa de la tabla -------------
	
	SELECT tipo_empresa 
	INTO VTipEmpresa
	FROM sc_nominaempresas
	WHERE codigo=pEmpresa;

	---Se buscan las transacciones/conceptos por tipo de empresa -------------
	
	FOREACH
		SELECT b.tipo_transaccion, a.codigoconcepto, a.descripcion INTO vTipoTran, iCodConcepto, vDescripcion
			FROM bdicheq:"informix".sc_nominaconceptos as a, bdicheq:"informix".sc_nominatransacciones as b
			WHERE b.tipo_empresa = VTipEmpresa 
			AND b.tipo_transaccion = '001'
			AND a.codigoconcepto = b.tipo_codigo
			
		LET iCont=1;
		
		RETURN vCodRet,vTipoTran,iCodConcepto,vDescripcion WITH RESUME;
	END FOREACH;
	
	IF(iCont=0) THEN
		LET vCodRet='00001';
		RETURN vCodRet,vTipoTran,iCodConcepto,vDescripcion;
	END IF;
	END;
END PROCEDURE
;