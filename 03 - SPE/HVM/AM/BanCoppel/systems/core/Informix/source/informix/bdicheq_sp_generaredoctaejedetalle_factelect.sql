CREATE PROCEDURE "informix".sp_generaredoctaejedetalle_factelect(pEmpresa CHAR(3), pCuenta CHAR(20), pFechaInicial DATE, pFechaFinal DATE)
RETURNING CHAR(5)     AS CodRet, 
          CHAR(180)   AS Descripcion, 
          MONEY(14,2) AS SaldoCuenta, 
          DATE        AS FechaAlt, 
          MONEY(14,2) AS Deposito, 
          MONEY(14,2) AS Retiro;
    
    DEFINE vcodret              CHAR(5);
    DEFINE vcodret2             CHAR(5);
    DEFINE vcodret3             CHAR(50);
    DEFINE vcodRetTipoCambio    CHAR(5);
    DEFINE vSqlErr              INTEGER;
    DEFINE vIsamErr             INTEGER;
    DEFINE vDescErr             CHAR(50);
    DEFINE vsucursal            CHAR(80);
    DEFINE vreferencia          CHAR(80);
    DEFINE vdescripcion         CHAR(180);
    DEFINE vDescripcionTipoCambio CHAR(180);
    DEFINE vcodRetspCortSig     CHAR(6);
    DEFINE cFech_param          CHAR(10);
    DEFINE cFech_param_ini      CHAR(10);
	DEFINE cFech_param_ini2     CHAR(10);
	DEFINE cFech_param_ini3     CHAR(10);
	DEFINE cFech_param_ini4     CHAR(10);
    DEFINE vfechealt            DATE;
	DEFINE vfechval	            DATE;
    DEFINE vmesAnt              DATE;
    DEFINE vsdocuenta           MONEY(18,2);
    DEFINE vsdocuentafin        MONEY(18,2);
    DEFINE vdeposito            MONEY(18,2);
    DEFINE vretiro              MONEY(18,2);
    DEFINE iTotalMovimientos    INTEGER;
    DEFINE vnum_serial          INTEGER;
    DEFINE vexistecta           INTEGER;	
	DEFINE vnum_tarjeta			CHAR(16);
	DEFINE vnum_cheq			INTEGER;
	DEFINE vfolio_suc			CHAR(16);
	DEFINE vnum_inv_cte			CHAR(20);
	DEFINE vnum_pagare			CHAR(20);
    DEFINE cTransaccion         CHAR(5);
    DEFINE cNaturaleza          CHAR(1);
    DEFINE cSucursal            CHAR(80);
    DEFINE dFechaMov1           DATE;
    DEFINE mMonto               MONEY(18, 2);
    DEFINE cDescripcion         CHAR(50);
	DEFINE vtransacc	       	CHAR(04);
	DEFINE vlinea2		       	CHAR(35);
	DEFINE vlinea3		       	CHAR(35);
	DEFINE vlinea4		       	CHAR(35);
	DEFINE vlinea5		       	CHAR(60);
	DEFINE vlinea5leyenda		CHAR(60);
	DEFINE vlinea6		       	CHAR(15);
	DEFINE vlinea7		       	CHAR(40);
	DEFINE vconcepto1		    CHAR(40);
	DEFINE vconcepto2	    	CHAR(40);
	DEFINE vsdocuenta2          MONEY(14,2);
    DEFINE vdeposito2           MONEY(14,2);
    DEFINE vretiro2             MONEY(14,2);
	DEFINE vfechealt2           DATE;
	DEFINE dFechaEmision        DATE;
	DEFINE vsecuencia           INTEGER;
    DEFINE vnlinea              INTEGER;
    DEFINE GLOBAL vidreg		INTEGER  DEFAULT 0;
    DEFINE cNombre              CHAR(60);
    DEFINE cNomSucursal         CHAR(130);
    DEFINE mRetiro              MONEY(18, 2);
    DEFINE mDeposito            MONEY(18, 2);
    DEFINE mSaldoActual         MONEY(18, 2);
    DEFINE vcomienza            INTEGER;
    DEFINE vAnioMes             CHAR(6);
	DEFINE vcortSig             CHAR(255);
	DEFINE vcortSig2            INTEGER;
    DEFINE vcontador1            INTEGER;
	DEFINE vUsuario             CHAR(8); -- Se agrego la variable vUsuario
    DEFINE vNum_serial_nuevo    BIGINT;
    	
    LET vcodret           = '000';
    LET vcodret2          = '';
    LET vcodret3          = '';
    LET vcodRetTipoCambio = '';
    LET vSqlErr           = 0;            
    LET vIsamErr          = 0;            
    LET vDescErr          = '';            
    LET vsucursal         = "";
    LET vreferencia       = "";
    LET vdescripcion      = "";
    LET vDescripcionTipoCambio = "";
    LET vcodRetspCortSig  = 0;    
    LET cFech_param       = "";
    LET cFech_param_ini   = "";
	LET cFech_param_ini2  = "";
	LET cFech_param_ini3  = "";
	LET cFech_param_ini4  = "";
    LET vfechealt         = "";
	LET vfechval          = "";
    LET vmesAnt           = "";
    LET vsdocuenta        = 0;
    LET vsdocuentafin     = 0;
    LET vdeposito         = 0;
    LET vretiro           = 0;
    LET iTotalMovimientos = 0;
    LET vnum_serial       = 0;
    LET vexistecta        = 0;
	LET vnum_tarjeta	= '';
	LET vnum_cheq		=  0;
	LET vfolio_suc		= '';
	LET vnum_inv_cte	= '';
	LET vnum_pagare		= '';
    LET cTransaccion  	= '';
    LET cNaturaleza   	= '';
    LET cSucursal     	= '';
    LET dFechaMov1    	= '';
    LET mMonto        	= 0;
    LET cDescripcion  	= '';
	LET vtransacc		= "";
	LET vlinea2		   	= "";
	LET vlinea3		   	= "";
	LET vlinea4		   	= "";
	LET vlinea5		   	= "";
	LET	vlinea5leyenda	= "";
	LET vlinea6		   	= "";
	LET vlinea7		   	= "";
	LET vconcepto1	   	= "";
	LET vconcepto2	   	= "";
	LET vretiro2 	  = 0;
    LET vdeposito2 	  = 0;
	LET vsdocuenta2   = 0;
	LET vfechealt2 	  = "";
	LET dFechaEmision = "";
	LET vsecuencia 	 = 0;
    LET vnlinea 	 = 0;  
    LET cNombre      = '';
    LET cNomSucursal = '';
    LET mRetiro      = 0;
    LET mDeposito    = 0;
    LET mSaldoActual = 0;
    LET vcomienza    = -1;
    LET vAnioMes     = '';
	LET vcortSig2 = 0;                              
    LET vcortSig = "";    
    LET vcontador1  = 0;		
    LET vUsuario = "";
    LET vNum_serial_nuevo = 0;
    
    BEGIN
    
    ON EXCEPTION SET vSqlErr, vIsamErr, vDescErr
        SET DEBUG FILE TO "/tmp/sp_generaredoctaejedetalle_factelect.err";
   		TRACE ON;
        IF vsqlerr != 0 THEN
            LET vcodret = vSqlErr;
            LET vcodret2 = vIsamErr;
            LET vcodret3 = vDescErr;
            RETURN vcodret, vdescripcion, vsdocuenta, vfechealt, vdeposito, vretiro;
        END IF;
    END EXCEPTION;
    
	--SET DEBUG FILE TO "/tmp/mfinis/sp_generaredoctaejedetalle_factelect.out";
	--TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( pEmpresa IS NULL OR pCuenta IS NULL OR pFechaInicial IS NULL OR pFechaFinal IS NULL ) THEN
        LET vcodret = '001'; 
        RETURN vcodret, vdescripcion, vsdocuenta, vfechealt, vdeposito, vretiro;
    END IF;
    
    -- // OBTIENE PARAMETROS DE FECHAS DE LOS HISTORICOS DE MOVIMIENTOS
    SELECT valor
    INTO cFech_param
    FROM sc_param
    WHERE empresa = pEmpresa
    AND codparam = 'fechcon_movhis';
       
    SELECT valor
    INTO cFech_param_ini
    FROM sc_param
    WHERE empresa = pEmpresa
    AND codparam = 'FechIniCon_movhis_ol';
	   
	SELECT valor
    INTO cFech_param_ini2
    FROM sc_param
    WHERE empresa = pEmpresa
    AND codparam = 'FechaIniMovhisOld2';
	   
	SELECT valor
    INTO cFech_param_ini3
    FROM sc_param
    WHERE empresa = pEmpresa
    AND codparam = 'vfechconmovhisold3';
	   
	SELECT valor
    INTO cFech_param_ini4
    FROM sc_param
    WHERE empresa = pEmpresa
    AND codparam = 'FechaIniMovhisOld4';
    
    -- // VALIDA LA CUENTA PARA EL TIPO DE EJECUCION
    SELECT COUNT(*)
    INTO vexistecta
    FROM sc_ctaedoesp 
    WHERE empresa = pEmpresa 
    AND cuenta = pCuenta;
       
	SELECT fecha_ant
    INTO dFechaEmision
    FROM sc_fechas
    WHERE empresa = pEmpresa;
    
    -- LET dFechaEmision = pFechaFinal;
    
    -- // CUENTAS CON TRATAMIENTO NORMAL
    IF vexistecta = 0 THEN
       
           FOREACH WITH HOLD
                SELECT CASE WHEN char_length(to_char(mov.num_serial)) < 8 THEN mov.num_serial + 2147483647
                    ELSE mov.num_serial
                END num_serial_nuevo,
                CASE WHEN trx.numero = "0274" AND mov.transacc_suc = "0331" THEN (SELECT descripcion FROM bdinteg: si_transacc WHERE numero = "0331")
                    ELSE trx.descripcion
                END AS DESCRIPCION, 
                CASE WHEN trx.naturaleza = 'C' THEN (mov.sdo_cuenta - mov.monto_tot)
                    WHEN trx.naturaleza IN ('A','R') THEN (mov.sdo_cuenta + mov.monto_tot) 
                    ELSE 0 
                END sdo_cta_final,
                mov.sdo_cuenta, mov.fech_alt,mov.referencia,
                CASE WHEN trx.naturaleza = 'C' THEN mov.monto_tot
                    ELSE 0 
                END AS RETIRO,
                CASE WHEN trx.naturaleza IN ('A','R') THEN mov.monto_tot
                    ELSE 0 
                END AS DEPOSITO,
                CASE WHEN trx.numero IN ('0202','0223','0250') THEN mov.sucursal||' - '||NVL(TRIM(su.nombre),'')||' - '||''||' - '|| NVL(TRIM(mov.fech_hor::CHAR(12)),'')
                    ELSE ''
                END  AS Sucursal,    --Se agrego el nombre del estado en estas transacciones.
                mov.transacc, mov.fech_val, mov.num_cheq, mov.num_tarjeta, mov.folio_suc, mov.usuario
                INTO vNum_serial_nuevo, vdescripcion, vsdocuentafin, vsdocuenta, vfechealt, vreferencia, vretiro, vdeposito, vsucursal, vtransacc, vfechval, vnum_cheq, vnum_tarjeta, vfolio_suc, vUsuario
                FROM sc_movhis mov,
                bdinteg:si_transacc trx,
                bdinteg:si_sucursales su				
                WHERE mov.empresa = pEmpresa
                AND mov.cuenta = pCuenta
                AND mov.fech_alt BETWEEN pFechaInicial AND pFechaFinal
                AND mov.fech_alt >= cFech_param
                AND mov.cancelad <> "S"
                AND mov.transacc = trx.numero
                AND trx.empresa = mov.empresa
                AND trx.numero = mov.transacc
                AND trx.se_emite_edocta = "S"
                AND trx.naturaleza IN ('C', 'R', 'A')
                AND su.sucursal = mov.sucursal
                AND su.empresa = mov.empresa
			    AND trx.sistema= '01'
                UNION ALL
                SELECT CASE WHEN char_length(to_char(mov.num_serial)) < 8 THEN mov.num_serial + 2147483647
                    ELSE mov.num_serial
                END num_serial_nuevo,
                CASE WHEN trx.numero = "0274" AND mov.transacc_suc = "0331" THEN (SELECT descripcion FROM bdinteg: si_transacc WHERE numero = "0331")
                    ELSE trx.descripcion 
                END AS DESCRIPCION, 
                CASE WHEN trx.naturaleza = 'C' THEN (mov.sdo_cuenta - mov.monto_tot)
                    WHEN trx.naturaleza IN ('A','R') THEN (mov.sdo_cuenta + mov.monto_tot) 
                    ELSE 0 
                END sdo_cta_final, mov.sdo_cuenta, mov.fech_alt,mov.referencia,
                CASE WHEN trx.naturaleza = 'C' THEN mov.monto_tot 
                    ELSE 0 
                END AS RETIRO,
                CASE WHEN trx.naturaleza IN ('A','R') THEN mov.monto_tot 
                    ELSE 0 
                END AS DEPOSITO,
                CASE WHEN trx.numero IN ('0202','0223','0250') THEN mov.sucursal||' - '||NVL(TRIM(su.nombre),'')||' - '||''||' - '||  NVL(TRIM(mov.fech_hor::CHAR(12)),'')
                    ELSE ''
                END  AS Sucursal,    --Se agrego el nombre del estado en estas transacciones.
                mov.transacc, mov.fech_val, mov.num_cheq, mov.num_tarjeta, mov.folio_suc, mov.usuario
                FROM sc_movhis_old mov,
                bdinteg:si_transacc trx,
                bdinteg:si_sucursales su
                WHERE mov.empresa = pEmpresa
                AND mov.cuenta = pCuenta
                AND mov.fech_alt BETWEEN pFechaInicial AND pFechaFinal
                AND mov.fech_alt >= cFech_param_ini
                AND mov.fech_alt < cFech_param
                AND mov.cancelad <> "S"
                AND mov.transacc = trx.numero
                AND trx.empresa = mov.empresa
                AND trx.numero = mov.transacc
                AND trx.se_emite_edocta = "S"
                AND trx.naturaleza IN ('C', 'R', 'A')
                AND su.sucursal = mov.sucursal
                AND su.empresa = mov.empresa
			    AND trx.sistema= '01'
                UNION ALL
                SELECT mov.num_serial as num_serial_nuevo,
                CASE WHEN trx.numero = "0274" AND mov.transacc_suc = "0331" THEN (SELECT descripcion FROM bdinteg: si_transacc WHERE numero = "0331")
                    ELSE trx.descripcion
                END AS DESCRIPCION,
                CASE WHEN trx.naturaleza = 'C' THEN (mov.sdo_cuenta - mov.monto_tot)
                    WHEN trx.naturaleza IN ('A','R') THEN (mov.sdo_cuenta + mov.monto_tot) 
                    ELSE 0 
                END sdo_cta_final, mov.sdo_cuenta, mov.fech_alt,mov.referencia,
                CASE WHEN trx.naturaleza = 'C' THEN mov.monto_tot 
                    ELSE 0
                END AS RETIRO,
                CASE WHEN trx.naturaleza IN ('A','R') THEN mov.monto_tot
                    ELSE 0
                END AS DEPOSITO,
                CASE WHEN trx.numero IN ('0202','0223','0250') THEN mov.sucursal||' - '||NVL(TRIM(su.nombre),'')||' - '||''||' - '|| NVL(TRIM(mov.fech_hor::CHAR(12)),'')
                    ELSE ''
                END  AS Sucursal,    --Se agrego el nombre del estado en estas transacciones.
                mov.transacc, mov.fech_val, mov.num_cheq, mov.num_tarjeta, mov.folio_suc, mov.usuario
                FROM sc_movhis_old2 mov,
                bdinteg:si_transacc trx,
                bdinteg:si_sucursales su
                WHERE mov.empresa = pEmpresa
                AND mov.cuenta = pCuenta
                AND mov.fech_alt BETWEEN pFechaInicial AND pFechaFinal
                AND mov.fech_alt >= cFech_param_ini2  
                AND mov.fech_alt < cFech_param_ini   
                AND mov.cancelad <> "S"
                AND mov.transacc = trx.numero
                AND trx.empresa = mov.empresa
                AND trx.numero = mov.transacc
                AND trx.se_emite_edocta = "S"
                AND trx.naturaleza IN ('C', 'R', 'A')
                AND su.sucursal = mov.sucursal
                AND su.empresa = mov.empresa
			    AND trx.sistema= '01'
		        UNION ALL
                SELECT mov.num_serial as num_serial_nuevo,
                CASE WHEN trx.numero = "0274" AND mov.transacc_suc = "0331" THEN (SELECT descripcion FROM bdinteg: si_transacc WHERE numero = "0331")
                    ELSE trx.descripcion
                END AS DESCRIPCION,
                CASE WHEN trx.naturaleza = 'C' THEN (mov.sdo_cuenta - mov.monto_tot)
                    WHEN trx.naturaleza IN ('A','R') THEN (mov.sdo_cuenta + mov.monto_tot) 
                    ELSE 0 
                END sdo_cta_final, mov.sdo_cuenta, mov.fech_alt,mov.referencia,
                CASE WHEN trx.naturaleza = 'C' THEN mov.monto_tot
                    ELSE 0
                END AS RETIRO,
                CASE WHEN trx.naturaleza IN ('A','R') THEN mov.monto_tot
                    ELSE 0
                END AS DEPOSITO,
                CASE WHEN trx.numero IN ('0202','0223','0250') THEN mov.sucursal||' - '||NVL(TRIM(su.nombre),'')||' - '||''||' - '|| NVL(TRIM(mov.fech_hor::CHAR(12)),'')
                    ELSE ''
                END  AS Sucursal,    --Se agrego el nombre del estado en estas transacciones.
                mov.transacc, mov.fech_val, mov.num_cheq, mov.num_tarjeta, mov.folio_suc, mov.usuario
                FROM sc_movhis_old3 mov,
                bdinteg:si_transacc trx,
                bdinteg:si_sucursales su
                WHERE mov.empresa = pEmpresa
                AND mov.cuenta = pCuenta
                AND mov.fech_alt BETWEEN pFechaInicial AND pFechaFinal
                AND mov.fech_alt >= cFech_param_ini3
                AND mov.fech_alt < cFech_param_ini2
                AND mov.cancelad <> "S"
                AND mov.transacc = trx.numero
                AND trx.empresa = mov.empresa
                AND trx.numero = mov.transacc
                AND trx.se_emite_edocta = "S"
                AND trx.naturaleza IN ('C', 'R', 'A')
                AND su.sucursal = mov.sucursal
                AND su.empresa = mov.empresa
			    AND trx.sistema= '01'
                ORDER BY fech_alt DESC, num_serial_nuevo DESC
			
            IF vtransacc IN ('0830') THEN
                EXECUTE PROCEDURE sp_obtener_descripcion_tipo_cambio(pEmpresa, vnum_tarjeta, vfolio_suc, vfechealt, vretiro)
                        INTO vcodRetTipoCambio, vDescripcionTipoCambio;

                IF vcodRetTipoCambio = '000' THEN
                    LET vreferencia = vDescripcionTipoCambio;
                END IF;
            END IF;	
			 
			-- // Se agrega a la descripcion 0283 el "ATM" cuando la transferencia prestamos coppel se hace en ATM
			IF (vtransacc = '0283') AND (vUsuario = '90034203') THEN

			    LET vdescripcion = (TRIM(vdescripcion)||' ATM');			 
			
            END IF;
            
            -- // Se agrega a la descripcion 0283 el "App BanCoppel" cuando la transferencia prestamos coppel se hace desde la APP Bancoppel
            IF (vtransacc = '0283') AND (vUsuario = '98882813') THEN
            
                LET vdescripcion = (TRIM(vdescripcion)||' App BanCoppel');           
            
                     END IF;
                     
                     -- // Se agrega a la descripcion 0283 el "App Coppel" cuando la transferencia prestamos coppel se hace en App Coppel
            IF (vtransacc = '0283') AND (vUsuario = '94059985') THEN
            
                LET vdescripcion = (TRIM(vdescripcion)||' App Coppel');          
            
                     END IF;
                     
                     -- // Se agrega a la descripcion 0283 el "Coppel.com" cuando la transferencia prestamos coppel se hace en Coppel.com
            IF (vtransacc = '0283') AND (vUsuario = '92873847') THEN
            
                LET vdescripcion = (TRIM(vdescripcion)||' Coppel.com');          
            
                     END IF;
                     
                      -- // Se agrega a la descripcion 0283 el "WhatsApp" cuando la transferencia prestamos coppel se hace en WhatsApp
            IF (vtransacc = '0283') AND (vUsuario = '95049126') THEN
            
                LET vdescripcion = (TRIM(vdescripcion)||' WhatsApp');        
            
                     END IF;
                     
                      -- // Se agrega a la descripcion 0283 el "Alta Unica" cuando la transferencia prestamos coppel se hace en Alta Unica
            IF (vtransacc = '0283') AND (vUsuario = '92652034') THEN
            
                LET vdescripcion = (TRIM(vdescripcion)||' Alta Unica');          
            
            END IF;	 
            -- // INICIA SELECCION DE INFORMACION SPEI		
            IF vtransacc IN ('0273', '0446') THEN
                
                SELECT First 1 'BANCO ORIGEN: '||NVL(TRIM(bn.vchrnombrecorto),''), --Linea 2
                       'FECHA TRANSFERENCIA: '||NVL(TRIM((LPAD(DAY(tb.dtfechacaptura),2,0)||'/'||LPAD(MONTH(tb.dtfechacaptura),2,0)||'/'||YEAR(tb.dtfechacaptura)) ),''), --Linea 3
                       'CLABE: '||NVL(TRIM(tb.vchrcuentaord),''), --Linea 4
                       'ORDENANTE: '||NVL(TRIM(tb.vchrnombreord),''), --Linea 5
                       'REF: '||NVL(TRIM(tb.intrefnumerica::CHAR(8)),''), --Linea 6
                       TRIM('CONCEPTO: '||(CASE WHEN vchrconceptopago IS NULL THEN '' ELSE vchrconceptopago END)||(CASE WHEN vchrconceptopago2 IS NULL THEN '' ELSE vchrconceptopago2 END)) AS CONCEPTO --Linea 7
                  INTO vlinea2, vlinea3, vlinea4, vlinea5, vlinea6, vlinea7						
                  FROM bdispei:tblhistpago tb, 
                       bdispei:tblbanco bn 
                 WHERE tb.dtfechacaptura = vfechealt
                   AND tb.vchrclaverastreo  = vreferencia
                   AND bn.cvecesif = tb.cvecesifbcoord;					
                
            ELIF vtransacc IN ('0274','0447') THEN
            
                SELECT First 1 'BANCO DESTINO: '||NVL(TRIM(bn.vchrnombrecorto),'') , --Linea 2
                       'FECHA TRANSFERENCIA: '||NVL(TRIM((LPAD(DAY(tb.dtfechacaptura),2,0)||'/'||LPAD(MONTH(tb.dtfechacaptura),2,0)||'/'||YEAR(tb.dtfechacaptura)) ),''), --Linea 3
                       'CLABE: '||NVL(TRIM(tb.vchrcuentabenef),''), --Linea 4
                       'BENEFICIARIO: '||NVL(TRIM(tb.vchrnombrebenef),''), --Linea 5
					   '(Dato no verificado por esta InstituciÃ³n) ', --Linea 5 Leyenda
                       'REF: '||NVL(TRIM(tb.intrefnumerica::CHAR(8)),''), --Linea 6
                       TRIM('CONCEPTO: '||(CASE WHEN vchrconceptopago IS NULL THEN '' ELSE vchrconceptopago END)||(CASE WHEN vchrconceptopago2 IS NULL THEN '' ELSE vchrconceptopago2 END)) AS CONCEPTO --Linea 7
                  INTO vlinea2, vlinea3, vlinea4, vlinea5, vlinea5leyenda, vlinea6, vlinea7
                  FROM bdispei:tblhistpago tb, 
                       bdispei:tblbanco bn 
                 WHERE tb.dtfechacaptura = vfechealt
                   AND tb.vchrclaverastreo = vreferencia
                   AND tb.chrestatusenvio IN ('L', 'E')
                   AND bn.cvecesif = tb.cvecesifbcodest;
                
            ELIF vtransacc IN ('0206','0207') THEN
            
                LET vreferencia = "PagarÃ© no."||' ' ||vreferencia;
            
            ELIF vtransacc = '0232' THEN
                
                LET vreferencia = "Cheque no."||' '||vnum_cheq||' '||"BANCO"||' ' ||SUBSTR(vreferencia ,1,3);
                
            ELIF vtransacc = '0269' THEN
                
                LET vreferencia = "Cheque no."||' '||vnum_cheq ;
                
            ELIF vtransacc IN ('3228','3246') THEN
                
                LET vreferencia = "Cheque no."||' '|| vnum_cheq;
                
            ELIF vtransacc IN ('0340','0342','0345') THEN
                
                LET vreferencia = "Folio de aclaraciÃ³n"||' '||vreferencia;
            
            ELIF vtransacc IN ('0343','0344')  THEN
                
                LET vreferencia = "Folio de aclaraciÃ³n"||' '||SUBSTR(vfolio_suc,7,16) ;
            
            ELIF vtransacc  = '1194' THEN
                
                LET vreferencia = "No.de TDC"||' '||vreferencia;
            
            ELIF vtransacc IN ('0313','1114') THEN
            
                LET vreferencia = "Cuenta origen no."||' '||vreferencia;
                
            ELIF vtransacc IN ('0309','1133') THEN
            
                LET vreferencia = "Cuenta destino no."||' '||vreferencia;
            
            ELIF vtransacc  IN ('0363','3259','3261' ) THEN
            
                LET vreferencia = "TD no. "||vnum_tarjeta;
            
            ELIF vtransacc  = '0251' THEN
                IF vfechealt >= cFech_param THEN
                
                    SELECT FIRST 1 cuenta 
                    INTO vnum_inv_cte 
                    FROM sc_movhis 
                    WHERE fech_alt >= cFech_param
                    AND cancelad <> 'S'
                    AND transacc = '0202' 
                    AND folio_suc = vfolio_suc; 
                                                
                    LET vreferencia = 'InversiÃ³n no. ' ||vnum_inv_cte;
                        
                ELSE
                    
                    SELECT FIRST 1 cuenta 
                    INTO vnum_inv_cte 
                    FROM sc_movhis_old 
                    WHERE fech_alt >= cFech_param_ini
                    AND fech_alt < cFech_param
                    AND cancelad <> 'S'
                    AND transacc = '0202' 
                    AND folio_suc = vfolio_suc;
                    
                END IF
                                        
                LET vreferencia = 'InversiÃ³n no. ' ||vnum_inv_cte;

            ELIF vtransacc  = '0235' THEN
                
                SELECT FIRST 1 cuenta 
                INTO vnum_pagare 
                FROM bdinvers:sv_movhis  
                WHERE transacc = '0500' 
                AND folio_suc = vfolio_suc;
                    
                LET vreferencia = 'PagarÃ© no. ' ||vnum_pagare;
				
                -----Agregadas 13/09/2016
			
				ELIF vtransacc IN ('1110','1140','1170') THEN
            
                LET vreferencia = "Remesa BTS no."||' ' ||vreferencia;
							
				ELIF vtransacc = '1131' THEN
            
                LET vreferencia = "NÃºmero de telÃ©fono."||' ' ||vreferencia;
				
				ELIF vtransacc = '1132' THEN
            
                LET vreferencia = "CrÃ©dito Coppel no."||' ' ||vreferencia;
							
				ELIF vtransacc IN ('1134', '1135', '1136') THEN
            
                LET vreferencia = "Orden de Pago no."||' ' ||vreferencia;
				
				ELIF vtransacc IN ('1137', '1138','1145','1146','1147','1154', '1184') THEN
            
                LET vreferencia = "no. de referencia"||' ' ||vreferencia;
				
				ELIF vtransacc = '1141' THEN
            
                LET vreferencia = "Cuenta que se pagarÃ¡ no."||' ' ||vreferencia;
				
				ELIF vtransacc = '1149' THEN
            
                LET vreferencia = "LÃ­nea de captura"||' ' ||vreferencia;
				
			    ELIF vtransacc IN ('1191', '1192') THEN
            
                LET vreferencia = "NÃºmero de clave de envÃ­o"||' ' ||vreferencia;
				
				ELIF vtransacc  = '0281' THEN
            
                LET vreferencia = "Tarjeta no. "||vnum_tarjeta||' '||vreferencia;
			
          
				 ELIF vtransacc IN ('0408','0409')  THEN
                
                LET vreferencia = "Folio de aclaraciÃ³n"||' '||"F"||SUBSTR(vfolio_suc,7,10) ;
            END IF;
            
            -- // sumar movimiento al contador
            LET iTotalMovimientos = iTotalMovimientos + 1; 
            LET vdescripcion = NVL(TRIM(vdescripcion), '') || ' ' || NVL(TRIM(vsucursal), '') || ' '|| NVL(TRIM(vreferencia), ''); 
            
			LET vsecuencia = vsecuencia + 1;
			LET vnlinea = 0;
			
			-- // Cortar los detalles en lineas
			FOREACH 
				EXECUTE PROCEDURE bdicred:corta_linea(vdescripcion, 40)
				INTO vcortSig, vcortsig2

				LET vnlinea = vnlinea + 1;

				IF vnlinea > 1 THEN
					LET vretiro = 0.00;
					LET vdeposito = 0.00;
					LET vsdocuenta = 0.00;
					LET vfechealt = '01-01-1900';
				END IF;

				INSERT INTO bdicheq:sc_detalle_edocta_factelect
				(idreg, fecha_emision, num_cuenta, secuencia, nlinea, fechamov, descripcion, retiro, deposito, saldo)
				VALUES
				(vidreg, dFechaEmision, pCuenta, vsecuencia, vnlinea, vfechealt, vcortSig, vretiro, vdeposito, vsdocuentafin);
			END FOREACH;
			
			
            -- // Inserta las lineas nuevas de SPEI en sc_detalle_edocta_factelect para el edo de cuenta	
            IF vtransacc IN('0273','0274','0446','0447') THEN
				LET vnlinea = vnlinea + 1;
                
                LET vretiro2 = 0.00;
                LET vdeposito2 = 0.00;
                LET vsdocuenta2 = 0.00;
                LET vfechealt2 = '01-01-1900';
                
				-- // INSERTA LINEA 2 CON DETALLE DE BANCO
                INSERT INTO sc_detalle_edocta_factelect
                (idreg, fecha_emision, num_cuenta, secuencia, nlinea, fechamov, descripcion, retiro, deposito, saldo)
                VALUES
                (vidreg, dFechaEmision, pCuenta, vsecuencia, vnlinea, vfechealt2, vlinea2, vretiro2, vdeposito2, vsdocuenta2);
				LET vnlinea = vnlinea + 1;
				
				-- // INSERTA LINEA 3 CON DETALLE DE FECHA DE TRANS
				INSERT INTO sc_detalle_edocta_factelect
                (idreg, fecha_emision, num_cuenta, secuencia, nlinea, fechamov, descripcion, retiro, deposito, saldo)
                VALUES
                (vidreg, dFechaEmision, pCuenta, vsecuencia, vnlinea, vfechealt2, vlinea3, vretiro2, vdeposito2, vsdocuenta2);
				LET vnlinea = vnlinea + 1;
				
				-- // INSERTA LINEA 4 CON DETALLE DE CTA CLABE				
				INSERT INTO sc_detalle_edocta_factelect
                (idreg, fecha_emision, num_cuenta, secuencia, nlinea, fechamov, descripcion, retiro, deposito, saldo)
                VALUES
                (vidreg, dFechaEmision, pCuenta, vsecuencia, vnlinea, vfechealt2, vlinea4, vretiro2, vdeposito2, vsdocuenta2);
				LET vnlinea = vnlinea + 1;
				
				-- // INSERTA LINEA 5 CON DETALLE DE CTA ORDENANTE/BENFICIARIA			
				INSERT INTO sc_detalle_edocta_factelect
                (idreg, fecha_emision, num_cuenta, secuencia, nlinea, fechamov, descripcion, retiro, deposito, saldo)
                VALUES
                (vidreg, dFechaEmision, pCuenta, vsecuencia, vnlinea, vfechealt2, vlinea5, vretiro2, vdeposito2, vsdocuenta2);
				LET vnlinea = vnlinea + 1;
				
				IF vtransacc IN ('0274','0447') THEN -- VALIDA SOLO 274
					-- // INSERTA LINEA 5 CON LA LEYENDA (Dato no verificado por esta InstituciÃ³n)
					INSERT INTO sc_detalle_edocta_factelect
					(idreg, fecha_emision, num_cuenta, secuencia, nlinea, fechamov, descripcion, retiro, deposito, saldo)
					VALUES
					(vidreg, dFechaEmision, pCuenta, vsecuencia, vnlinea, vfechealt2, vlinea5leyenda, vretiro2, vdeposito2, vsdocuenta2);
					LET vnlinea = vnlinea + 1;				
				END IF
				
				-- // INSERTA LINEA 6 CON DETALLE DE REFERENCIA NUMERICA				
				INSERT INTO sc_detalle_edocta_factelect
                (idreg, fecha_emision, num_cuenta, secuencia, nlinea, fechamov, descripcion, retiro, deposito, saldo)
                VALUES
                (vidreg, dFechaEmision, pCuenta, vsecuencia, vnlinea, vfechealt2, vlinea6, vretiro2, vdeposito2, vsdocuenta2);
				LET vnlinea = vnlinea + 1;
				
				-- // INSERTA LINEA 7 CON DETALLE DE CONCEPTO				
				INSERT INTO sc_detalle_edocta_factelect
                (idreg, fecha_emision, num_cuenta, secuencia, nlinea, fechamov, descripcion, retiro, deposito, saldo)
                VALUES
                (vidreg, dFechaEmision, pCuenta, vsecuencia, vnlinea, vfechealt2, vlinea7, vretiro2, vdeposito2, vsdocuenta2);
				
				LET vfechealt = vfechval;
            END IF
				
			  --RSV 
			 LET vcontador1 = vcontador1 + 1;
			   
			     IF (vcontador1 >= 1000) THEN
                    LET vcontador1 = 0;
                    COMMIT WORK;
                    BEGIN WORK;
                END IF;
			--RSV	
				
				
			RETURN vcodret, vdescripcion, vsdocuenta, vfechealt, vdeposito, vretiro WITH RESUME;
        END FOREACH;
        
    -- // CUENTAS CON TRATAMIENTO ESPECIAL (MUCHOS REGISTROS)
    ELSE
    
        FOREACH WITH HOLD
            SELECT mov.transacc, trx.naturaleza, mov.sucursal, mov.fech_alt, sum(mov.monto_tot)
            INTO cTransaccion, cNaturaleza, cSucursal, dFechaMov1, mMonto
            FROM sc_movhis mov, bdinteg:si_transacc trx 
            WHERE mov.empresa = pEmpresa
            AND mov.cuenta = pCuenta
            AND mov.fech_alt BETWEEN pFechaInicial AND pFechaFinal
            AND mov.fech_alt >= cFech_param
            AND mov.cancelad <> "S"
            AND mov.transacc = trx.numero
            AND trx.empresa = mov.empresa
            AND trx.numero = mov.transacc
            AND trx.se_emite_edocta = "S"
            AND trx.sistema = '01'
            GROUP BY mov.transacc, trx.naturaleza, mov.sucursal, mov.fech_alt
            UNION ALL
            SELECT mov.transacc, trx.naturaleza, mov.sucursal, mov.fech_alt, sum(mov.monto_tot)
            FROM sc_movhis_old mov, 
            bdinteg:si_transacc trx 
            WHERE mov.empresa = pEmpresa
            AND mov.cuenta = pCuenta
            AND mov.fech_alt BETWEEN pFechaInicial AND pFechaFinal
            AND mov.fech_alt >= cFech_param_ini
            AND mov.fech_alt < cFech_param
            AND mov.cancelad <> "S"
            AND mov.transacc = trx.numero
            AND trx.empresa = mov.empresa
            AND trx.numero = mov.transacc
            AND trx.se_emite_edocta = "S"
            AND trx.sistema = '01'
            GROUP BY mov.transacc, trx.naturaleza, mov.sucursal, mov.fech_alt
            ORDER BY fech_alt DESC, trx.naturaleza DESC, mov.sucursal ASC 
             
            IF vcomienza = -1 THEN
                LET vcomienza = 0;
                LET vAnioMes  = to_char(pFechaFinal, '%Y%m');
                
                SELECT sdo_actual
                INTO mSaldoActual
                FROM sc_maehis
                WHERE empresa = pEmpresa
                AND cuenta  = pCuenta
                AND aniomes = vAnioMes;
            END IF;
                
            -- // SE OBTIENE LA DESCRIPCION DE LA TRANSACCION Y LA NATURALEZA
            SELECT TRIM(descripcion) 
              INTO cDescripcion
              FROM bdinteg:si_transacc
             wHERE numero = cTransaccion
			   AND sistema= '01';
            -- // Se agrega a la descripcion 0283 el "ATM" cuando la transferencia prestamos coppel se hace en ATM
			IF (cTransaccion = '0283') AND (vUsuario = '90034203') THEN

			    LET cDescripcion = (TRIM(cDescripcion)||' ATM');			 
			
            END IF;

            -- // Se agrega a la descripcion 0283 el "App BanCoppel" cuando la transferencia prestamos coppel se hace desde la APP Bancoppel
            IF (vtransacc = '0283') AND (vUsuario = '98882813') THEN
            
                LET vdescripcion = (TRIM(vdescripcion)||' App BanCoppel');           
            
            END IF;
                     
                     -- // Se agrega a la descripcion 0283 el "App Coppel" cuando la transferencia prestamos coppel se hace en App Coppel
            IF (vtransacc = '0283') AND (vUsuario = '94059985') THEN
            
                LET vdescripcion = (TRIM(vdescripcion)||' App Coppel');          
            
            END IF;
                     
                     -- // Se agrega a la descripcion 0283 el "Coppel.com" cuando la transferencia prestamos coppel se hace en Coppel.com
            IF (vtransacc = '0283') AND (vUsuario = '92873847') THEN
            
                LET vdescripcion = (TRIM(vdescripcion)||' Coppel.com');          
            
            END IF;
                     
                      -- // Se agrega a la descripcion 0283 el "WhatsApp" cuando la transferencia prestamos coppel se hace en WhatsApp
            IF (vtransacc = '0283') AND (vUsuario = '95049126') THEN
            
                LET vdescripcion = (TRIM(vdescripcion)||' WhatsApp');        
            
            END IF;
                     
                      -- // Se agrega a la descripcion 0283 el "Alta Unica" cuando la transferencia prestamos coppel se hace en Alta Unica
            IF (vtransacc = '0283') AND (vUsuario = '92652034') THEN
            
                LET vdescripcion = (TRIM(vdescripcion)||' Alta Unica');          
            
            END IF;
            
            -- // OBTIENE EL NOMBRE DE LA SUCURSAL
            SELECT nombre
            INTO cNombre
            FROM bdinteg:si_sucursales
            WHERE sucursal = cSucursal;
            
            -- // SE OBTIENE LA CADENA CON EL NUMERO DE SUCURSAL, EL NOMBRE Y LA FECHA HORA DEL MOVIMIENTO
            LET cNomSucursal = TRIM(cDescripcion) || ' - ' || TRIM(cSucursal)  || ' - ' || NVL(TRIM(cNombre), '');
            LET mRetiro = 0;
            LET mDeposito = 0;
            
            -- // VALIDACION DE LOS MOVIMIENTOS, SI ES CARGO, ABONO O REGRESION
            IF cNaturaleza = 'C' THEN
                LET mRetiro = mMonto;
            ELIF cNaturaleza = 'A' THEN
                LET mDeposito = mMonto;
            END IF;
            
            -- // CALCULA EL SALDO DE LA CUENTA
            LET mSaldoActual = mSaldoActual - mDeposito + mRetiro;
             
            -- // sumar movimiento al contador
            LET iTotalMovimientos = iTotalMovimientos + 1;      
            LET vdescripcion = cNomSucursal;
            LET vsdocuenta = mSaldoActual;
            LET vfechealt = dFechaMov1;
            LET vdeposito = mDeposito;
            LET vretiro = mRetiro;
			
            -- // SE INICIALIZA LA LINEA A CERO
			LET vsecuencia = vsecuencia + 1;
			LET vnlinea = 0;
			-- // Cortar los detalles en lineas
			FOREACH 
				EXECUTE PROCEDURE bdicred:corta_linea(vdescripcion, 40)
				INTO vcortSig, vcortsig2

				LET vnlinea = vnlinea + 1;

				IF vnlinea > 1 THEN
					LET vretiro = 0.00;
					LET vdeposito = 0.00;
					LET vsdocuenta = 0.00;
                    LET vfechealt = '01-01-1900';
				END IF;

				INSERT INTO bdicheq:sc_detalle_edocta_factelect
				(idreg, fecha_emision, num_cuenta, secuencia, nlinea, fechamov, descripcion, retiro, deposito, saldo)
				VALUES
				(vidreg, dFechaEmision, pCuenta, vsecuencia, vnlinea, vfechealt, vcortSig, vretiro, vdeposito, vsdocuenta);
			END FOREACH;
            
				  --RSV 
			 LET vcontador1 = vcontador1 + 1;
			   
			     IF (vcontador1 >= 1000) THEN
                    LET vcontador1 = 0;
                    COMMIT WORK;
                    BEGIN WORK;
                END IF;
			--RSV	

			
            RETURN vcodret, vdescripcion, vsdocuenta, vfechealt, vdeposito, vretiro WITH RESUME;
        END FOREACH;
    
    END IF;
    
    -- // preguntar sino hubo movimientos
    IF iTotalMovimientos = 0 THEN
        LET vcodret = '002';                
        LET vdescripcion = ' ';
        LET vsdocuenta = null;
        LET vfechealt = null;
        LET vdeposito = null;
        LET vretiro = null;
        RETURN vcodret, vdescripcion, vsdocuenta, vfechealt, vdeposito, vretiro;
    END IF; 
        
    END;
    
END PROCEDURE
DOCUMENT
"DB: bdicheq",
"FUNCIONAMIENTO: ModificaciÃ³n para mostrar el saldo actual en los movimientos en el tratamiento especial",
"FECHA : 03-03-2023";

CREATE PROCEDURE "informix".calc_tasa( pempresa CHAR(3),
                                       ptasa    CHAR(8),
                                       ptip_per CHAR(2),
                                       pmonto   MONEY(14,2) )
RETURNING CHAR(5), DECIMAL(9,6), DECIMAL(14,2);
    
    -- *************************************************************
    -- calc_tasa
    -- Version              1.0.0
    -- Obejtivo:            Calcula la tasa a aplicar
    -- Creado por:          Alejandro Rueda Sanchez
    -- ModIFicado por:
    -- Ultima ModIFicacion: Mayo-2008
    --                      Creaciï¿½n de SPL
    -- *************************************************************
    
    DEFINE GLOBAL vgTasaVar        CHAR(1)      DEFAULT "";
    DEFINE GLOBAL vgcuenta         CHAR(20)     DEFAULT " ";
    DEFINE GLOBAL vgfecha_hoy      DATE         DEFAULT " ";
    
    DEFINE valor_pond   DECIMAL(9,6);
    DEFINE vcodigo      CHAR(8);
    DEFINE vtasareferen CHAR(8);
    DEFINE vrangofecha  CHAR(1);
    DEFINE vcodret      CHAR(5);
    DEFINE vfecha_rec   DATE;
    DEFINE vfecha_refer DATE;
    DEFINE valor_tasa,
           vvalor,
           porcentaje,
           puntos       DECIMAL(9,6);
    DEFINE vrangomin,
           vrangomax    DECIMAL(14,2);
    DEFINE sql_err      INTEGER;
    DEFINE vMtoInt      DECIMAL(14,2);
    
    BEGIN
    
    ON EXCEPTION SET sql_err
        set debug file to "/resplogifx/conciliachq/calc_tasa.err";
        trace on;
        IF sql_err <> 0 THEN
            LET vcodret = sql_err;
            RETURN vcodret,valor_pond, vMtoInt;
        END IF;
    END EXCEPTION;
    
    LET vcodret    = "000";
    LET valor_pond = 0;
    LET porcentaje = 0;
    LET puntos     = 0;
    LET vMtoInt    = 0;
    
    --- set debug file to "/resplogifx/conciliachq/calc_tasa.out";
    --- trace on;
    
    SET ISOLATION TO DIRTY READ;

    SELECT tasa, rangofecha, tasareferen
      INTO vcodigo, vrangofecha, vtasareferen
      FROM bdinteg:si_tiptasa
     WHERE empresa = pempresa
       AND tasa = ptasa;

    IF vcodigo IS NULL THEN
        LET vcodret = "901";
        RETURN vcodret, valor_pond, vMtoInt;
    END IF

    IF vgTasaVar = "N" THEN
        IF vrangofecha = "F" THEN
            SELECT MAX(fecha) 
              INTO vfecha_rec
              FROM bdinteg:si_fechavalor
             WHERE empresa = pempresa
               AND tasa = vcodigo
               AND fecha <= vgfecha_hoy;

            SELECT valor 
              INTO valor_tasa
              FROM bdinteg:si_fechavalor
             WHERE empresa = pempresa
               AND tasa = vcodigo
               AND fecha = vfecha_rec;

            LET valor_pond = valor_tasa;
        ELIF vrangofecha = "R" THEN
            SELECT MAX(fecha) 
              INTO vfecha_refer
              FROM bdinteg:si_fechavalor
             WHERE empresa = pempresa
               AND tasa = vtasareferen;

            SELECT valor 
              INTO vvalor
              FROM bdinteg:si_fechavalor
             WHERE empresa = pempresa
               AND tasa = vtasareferen
               AND fecha = vfecha_refer;

            IF ptip_per = "F" THEN
                SELECT rangomin, rangomax, valor, sobretasafis
                  INTO vrangomin, vrangomax, porcentaje, puntos
                  FROM bdinteg:si_tasavlor
                 WHERE empresa = pempresa
                   AND tasa = ptasa
                   AND rangomin <= pmonto
                   AND rangomax >= pmonto;
            ELSE
                SELECT rangomin, rangomax, valor, sobretasamor
                  INTO vrangomin, vrangomax, porcentaje, puntos
                  FROM bdinteg:si_tasavlor
                 WHERE empresa = pempresa
                   AND tasa = ptasa
                   AND rangomin <= pmonto
                   AND rangomax >= pmonto;
            END IF
            
            LET valor_pond = porcentaje + puntos;
        END IF

        IF valor_pond IS NULL THEN
            LET valor_pond = 0;
        END IF
    ELSE
        LET vgcuenta = vgcuenta;
        
        -- // Busca el valor de la tasa, tomando como periodo base la fecha inicio de proceso
        SELECT NVL(a.valor_tasa,0), int_acum 
          INTO valor_pond, vMtoInt
          FROM sc_tasa_variable a
         WHERE empresa = pempresa
           AND cuenta = vgcuenta
           AND vgfecha_hoy between inicio_periodo AND fin_periodo -1
           AND tipo_tasa = "M";

        -- // Si no existe el valor de la tasa, se incluye la fecha final de ultimo periodo
        IF valor_pond is null or valor_pond = 0 THEN
            SELECT NVL(a.valor_tasa,0), int_acum 
              INTO valor_pond, vMtoInt
              FROM sc_tasa_variable a
             WHERE empresa = pempresa
               AND cuenta = vgcuenta
               AND vgfecha_hoy between inicio_periodo AND fin_periodo
               AND tipo_tasa = "M";
        END IF

        IF valor_pond is null THEN
            LET valor_pond = 0;
        END IF      
    END IF

    RETURN vcodret, valor_pond, vMtoInt;
    
    END;
    
END PROCEDURE;