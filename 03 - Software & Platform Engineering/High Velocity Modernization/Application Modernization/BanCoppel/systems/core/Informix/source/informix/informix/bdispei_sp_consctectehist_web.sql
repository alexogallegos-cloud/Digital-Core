CREATE PROCEDURE "informix".sp_consctectehist_web( pSucursal     CHAR(4),
                                                       pFechaInicial CHAR(10),
                                                       pFechaFinal   CHAR(10),
                                                       pContador 	 INTEGER )

    RETURNING CHAR(5), CHAR(100), CHAR(40), CHAR(20), CHAR(20), CHAR(40),
              CHAR(20), CHAR(18), CHAR(40), DECIMAL(10,0), INTEGER, CHAR(20),
              CHAR(20), CHAR(30), CHAR(20), CHAR(20), CHAR(255), DECIMAL(14,2),
              CHAR(10), CHAR(8), DECIMAL(14,2), DECIMAL(14,2);

    DEFINE cCodRet 	  		CHAR(5);
    DEFINE cCodRet2	  		CHAR(5);
    DEFINE cCodRet3	  		CHAR(50);
    DEFINE iSql_Err         INTEGER;
    DEFINE iIsam_Err        INTEGER;
    DEFINE cDesc_Err        CHAR(50);
    DEFINE cDataErr        	CHAR(100);
    
    DEFINE cNombreOrd      	CHAR(40);
    DEFINE cCuentaOrd      	CHAR(20);
    DEFINE cCteOrd         	CHAR(20);
    DEFINE cNombreBenef    	CHAR(40);
    DEFINE cCuentaBenef    	CHAR(20);
    DEFINE cRFCBenef       	CHAR(18);
    DEFINE cConceptoPago2  	CHAR(40);
    DEFINE iRefNumerica     DECIMAL(10,0);
    DEFINE vcveCesifbcodest INTEGER;
    DEFINE cNombrecorto    	CHAR(20);
    DEFINE cEstatusenvio   	CHAR(20);
    DEFINE cClaverastreo   	CHAR(30);
    DEFINE cHoraCargo      	CHAR(20);
    DEFINE cHoraCancela     CHAR(20);
    DEFINE cMotivodev      	CHAR(255);
    DEFINE lcta             SMALLINT;
    DEFINE btipo            SMALLINT;
    DEFINE icontador        INTEGER;
    DEFINE dMonto           DECIMAL(14,2);
    DEFINE dMontoComis      DECIMAL(14,2);
    DEFINE dMontoIva        DECIMAL(14,2);
    DEFINE iCausaDev        INTEGER;
    DEFINE cDesCausaDev     CHAR(100);
    DEFINE dFechaHoy        DATE;
    DEFINE cFechaValor      CHAR(10);
    DEFINE cUsuario         CHAR(8);
    DEFINE cCuenta          CHAR(20);
    DEFINE cTranComis       CHAR(4);
    DEFINE cTranIva         CHAR(4);
    
    DEFINE vcEstatusenvio   CHAR(1);
    DEFINE vdfechavalor     DATE;
    
    LET cCodRet 	       	= '00000';
    LET cCodRet2	       	= '';
    LET cCodRet3	       	= '';
    LET iSql_Err            = 0;
    LET iIsam_Err           = 0;
    LET cDesc_Err           = '';
    LET cDataErr        	= '';
    LET cNombreOrd     		= '';
    LET cCuentaOrd     		= '';
    LET cCteOrd        		= '';
    LET cNombreBenef   		= '';
    LET cCuentaBenef   		= '';
    LET cRFCBenef      		= '';
    LET cConceptoPago2 		= '';
    LET iRefNumerica    	= 0;
    LET vcveCesifbcodest  	= 0;
    LET cNombrecorto   		= '';
    LET cEstatusenvio  		= '';
    LET cClaverastreo  		= '';
    LET cHoraCargo      	= CURRENT::CHAR(25);
    LET cHoraCancela    	= CURRENT::CHAR(25);
    LET cMotivodev     		= '';
    LET lcta               	= 0;
    LET btipo              	= 0;
    LET icontador       	= 0;
    LET dMonto             	= 0;
    LET dMontoComis        	= 0;
    LET dMontoIva          	= 0;
    LET iCausaDev          	= 0;
    LET cDesCausaDev       	= "";
    LET cFechaValor        	= "";
    LET cUsuario           	= "";
    LET cCuenta            	= "";
    LET cTranComis         	= "";
    LET cTranIva           	= "";

    LET cHoraCargo 	 = SUBSTR(cHoraCargo,12,8);
    LET cHoraCancela = SUBSTR(cHoraCancela,12,8);
    
    LET vcEstatusenvio = '';
    LET vdfechavalor   = "";

    BEGIN
    
        ON EXCEPTION SET iSql_Err, iIsam_Err, cDesc_Err
            SET DEBUG FILE TO "/tmp/sp_consctectehist.err";
            TRACE ON;
            IF iSql_Err <>  0 THEN
                LET cCodRet  = iSql_Err;
                LET cCodRet2 = iIsam_Err;
                LET cCodRet3 = cDesc_Err;
                RETURN cCodRet, cDataErr, cNombreOrd, cCuentaOrd, cCteOrd, cNombreBenef, cCuentaBenef, cRFCBenef, cConceptoPago2, iRefNumerica, vcveCesifbcodest, 
                    cNombrecorto, cEstatusenvio, cClaverastreo, cHoraCargo, cHoraCancela, cMotivodev, dMonto, cFechaValor, cUsuario, dMontoComis, dMontoIva;
            END IF
        END EXCEPTION;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

        -- // validar si se reciven los parametros
        -- // Por Sucursal
        IF pSucursal <> '' THEN 
            LET bTipo = 3;
        END IF;

        -- // Faltan parametros
        IF TRIM(pSucursal) = '' OR TRIM(pFechaInicial) = '' OR TRIM(pFechaFinal) = '' OR pSucursal IS NULL OR pFechaInicial IS NULL OR pFechaFinal IS NULL THEN 
            LET cCodRet = '00001';
            LET cDataErr = 'Faltan parametros';
            
            RETURN cCodRet, cDataErr, cNombreOrd, cCuentaOrd, cCteOrd, cNombreBenef, cCuentaBenef, cRFCBenef, cConceptoPago2, iRefNumerica, vcveCesifbcodest, 
                cNombrecorto, cEstatusenvio, cClaverastreo, cHoraCargo, cHoraCancela, cMotivodev, dMonto, cFechaValor, cUsuario, dMontoComis, dMontoIva;
        END IF;

        -- // Carga los Codigos de la Transaccion de Comision e IVA 
        -- // Trae la transaccion de la Comision
        SELECT vchrValor 
        INTO cTranComis 
        FROM tblparametros 
        WHERE vchrcveparametro = 'TRANSACC_COMISION';
        
        -- // Valida si falta parametro de transaccion comision.
        IF cTranComis IS NULL OR cTranComis = '' THEN
            LET cTranComis = '0000'; 
        END IF;
            
        -- // Trae la transaccion del IVA de la Comision
        SELECT vchrValor 
          INTO cTranIva 
          FROM tblparametros 
         WHERE vchrcveparametro = 'TRANSACC_IVACOM';
        
        -- // Valida si Falta parametro de transaccion iva.
        IF cTranIva IS NULL OR cTranIva = '' THEN
            LET cTranIva = '0000'; 
        END IF;

        -- // SE OBTIENE LA INFORMACION DE LA SUCURSAL
        IF bTipo = 3 THEN

            FOREACH

                SELECT DISTINCT pago.vchrNombreOrd, 
                       (CASE WHEN pago.intcvetipoctaord = '40' 
                             THEN SUBSTR(pago.vchrCuentaOrd,7,11) 
                             ELSE pago.vchrCuentaOrd 
                        END) cuenta,
                        pago.vchrNombreBenef, 
                        pago.vchrCuentaBenef, 
                        pago.vchrRFCBenef, 
                        pago.vchrConceptoPago2, 
                        pago.intRefNumerica, 
                        pago.cvecesifbcodest, 
                        bco.vchrnombrecorto, 
                        pago.mnyimporte, 
                        pago.chrestatusenvio, 
                        pago.vchrclaverastreo, 
                        nvl(pago.dtmhoracargo::char(20),''),
                        nvl(pago.dtmhoracancela::char(20),''), 
                        nvl(pago.vchrmotivodev,''), 
                        nvl(pago.intcvecausadev,0), 
                        pago.chrusuarioprom, 
                        pago.dtfechacaptura,
                        CASE pago.chrestatusenvio 
                            WHEN 'L' THEN 'LIQUIDADO'
                            WHEN 'A' THEN 'ABONADO' 
                            WHEN 'D' THEN 'DEVUELTO' 
                            WHEN 'E' THEN 'ENVIADO' 
                            WHEN 'R' THEN 'RECIBIDO' 
                            WHEN 'N' THEN 'PENDIENTE ENVIO' 
                            WHEN 'C' THEN 'CANCELADO' 
                            ELSE 'OTRO'
                        END estatusenvio
                   INTO cNombreOrd, cCuentaOrd,  cNombreBenef, cCuentaBenef, cRFCBenef, cConceptoPago2, 
                        iRefNumerica, vcveCesifbcodest, cNombrecorto, dMonto, vcEstatusenvio, cClaverastreo, cHoraCargo, 
                        cHoraCancela, cMotivodev, iCausaDev, cUsuario, vdfechavalor, 
                        cEstatusenvio
                   FROM (SELECT DISTINCT empresa, cuenta, clave_rastreo FROM tbldetranpago WHERE fech_alt = pFechaInicial AND sucursal = pSucursal) AS det 
             INNER JOIN tblpago pago ON pago.dtfechacaptura = pFechaInicial
                                    AND pago.chrsentidopago = 'E'
                                    AND pago.intcvetipopago = 1
                                    AND pago.vchrclaverastreo = det.clave_rastreo 
             INNER JOIN tblbanco bco ON pago.cvecesifbcodest = bco.cvecesif
              UNION ALL
                 SELECT DISTINCT pago.vchrNombreOrd, 
                       (CASE WHEN pago.intcvetipoctaord = '40' 
                             THEN SUBSTR(pago.vchrCuentaOrd,7,11) 
                             ELSE pago.vchrCuentaOrd 
                        END) cuenta,
                        pago.vchrNombreBenef, 
                        pago.vchrCuentaBenef, 
                        pago.vchrRFCBenef, 
                        pago.vchrConceptoPago2, 
                        pago.intRefNumerica, 
                        pago.cvecesifbcodest, 
                        bco.vchrnombrecorto, 
                        pago.mnyimporte, 
                        pago.chrestatusenvio, 
                        pago.vchrclaverastreo, 
                        nvl(pago.dtmhoracargo::char(20),''),
                        nvl(pago.dtmhoracancela::char(20),''), 
                        nvl(pago.vchrmotivodev,''), 
                        nvl(pago.intcvecausadev,0), 
                        pago.chrusuarioprom, 
                        pago.dtfechacaptura,
                        CASE pago.chrestatusenvio 
                            WHEN 'L' THEN 'LIQUIDADO'
                            WHEN 'A' THEN 'ABONADO' 
                            WHEN 'D' THEN 'DEVUELTO' 
                            WHEN 'E' THEN 'ENVIADO' 
                            WHEN 'R' THEN 'RECIBIDO' 
                            WHEN 'N' THEN 'PENDIENTE ENVIO' 
                            WHEN 'C' THEN 'CANCELADO' 
                            ELSE 'OTRO'
                        END estatusenvio
                   FROM (SELECT DISTINCT empresa, cuenta, clave_rastreo FROM tblhistdetranpago WHERE fech_alt = pFechaInicial AND sucursal = pSucursal) AS det 
             INNER JOIN tblhistpago pago ON pago.dtfechacaptura = pFechaInicial
                                        AND pago.chrsentidopago = 'E'
                                        AND pago.intcvetipopago = 1
                                        AND pago.vchrclaverastreo = det.clave_rastreo 
             INNER JOIN tblbanco bco ON pago.cvecesifbcodest = bco.cvecesif
               ORDER BY pago.dtfechacaptura, pago.vchrclaverastreo

                /*************************************************************/
  
                IF LENGTH(TRIM(cCuentaOrd)) > 10 THEN
                    SELECT num_cte 
                      INTO cCteOrd
                      FROM bdicheq:sc_maechq 
                     WHERE empresa='001' 
                       AND cuenta = cCuentaOrd;
                ELSE
                    SELECT num_cte 
                      INTO cCteOrd
                      FROM bdicheq:sc_cuenta_telefono
                     WHERE telefono =  cCuentaOrd;
                END IF;
               
               /*
                IF vcEstatusenvio = 'L' THEN LET cEstatusenvio = 'LIQUIDADO';
                    ELIF vcEstatusenvio = 'A' THEN LET cEstatusenvio = 'ABONADO';
                    ELIF vcEstatusenvio = 'D' THEN LET cEstatusenvio = 'DEVUELTO';
                    ELIF vcEstatusenvio = 'E' THEN LET cEstatusenvio = 'ENVIADO';
                    ELIF vcEstatusenvio = 'R' THEN LET cEstatusenvio = 'RECIBIDO';
                    ELIF vcEstatusenvio = 'N' THEN LET cEstatusenvio = 'PENDIENTE ENVIO';
                    ELIF vcEstatusenvio = 'C' THEN LET cEstatusenvio = 'CANCELADO';
                    ELSE                           LET cEstatusenvio = 'OTRO'; 
                END IF;
                */
                
                LET cFechaValor = TO_CHAR(vdfechavalor, '%d/%m/%Y');
            
                IF NOT (iCausaDev IS NULL OR iCausaDev = 0) THEN
                    SELECT vchrdescripcion 
                      INTO cDesCausaDev
                      FROM tblcausadev AS t
                     WHERE t.intcvecausadev = iCausaDev;
                
                    IF TRIM(cDesCausaDev) != "" THEN
                        LET cMotivodev = TRIM(cDesCausaDev);
                    END IF;
                END IF;
            
                LET cHoraCargo = substr(cHoraCargo,12,8);
                LET cHoraCancela = substr(cHoraCancela,12,8);

                SELECT NVL(monto_tot,0) 
                  INTO dMontoComis
                  FROM tblhistdetranpago AS t
                 WHERE t.clave_rastreo = cClaverastreo
                   AND t.transacc = cTranComis;

                SELECT NVL(monto_tot,0) 
                  INTO dMontoIva
                  FROM tblhistdetranpago AS t
                 WHERE t.clave_rastreo = cClaverastreo
                   AND t.transacc = cTranIva;

                LET icontador = icontador + 1;
            
                IF icontador <= pContador THEN
                    CONTINUE FOREACH;
                ELSE
                    RETURN cCodRet, cDataErr, cNombreOrd, cCuentaOrd, cCteOrd, cNombreBenef, cCuentaBenef, cRFCBenef, cConceptoPago2, iRefNumerica, vcveCesifbcodest, 
                           cNombrecorto, cEstatusenvio, cClaverastreo, cHoraCargo, cHoraCancela, cMotivodev, dMonto, cFechaValor, cUsuario, dMontoComis, dMontoIva 
                    WITH RESUME;
                END IF

                /*************************************************************/

            END FOREACH;

        END IF;

    END;

END PROCEDURE;