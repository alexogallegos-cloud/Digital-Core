CREATE PROCEDURE "informix".sp_generaredoctaejedetalle_factelect_esp(pEmpresa CHAR(3), pCuenta CHAR(20), pFechaInicial DATE, pFechaFinal DATE, pOpcion SMALLINT)
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
	DEFINE dFechaEmision_esp_det  DATE;
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
    DEFINE vUsuario             CHAR(8); 
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
	LET dFechaEmision_esp_det = '01012010';	
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
        SET DEBUG FILE TO "/tmp/sp_generaredoctaejedetalle_factelect_esp.err";
   		TRACE ON;
        IF vsqlerr != 0 THEN
            LET vcodret = vSqlErr;
            LET vcodret2 = vIsamErr;
            LET vcodret3 = vDescErr;
            RETURN vcodret, vdescripcion, vsdocuenta, vfechealt, vdeposito, vretiro;
        END IF;
    END EXCEPTION;
    
	--SET DEBUG FILE TO "/tmp/mfinis/sp_generaredoctaejedetalle_factelect_esp.out";
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
	 
    IF pOpcion = 1 THEN
    
	    LET dFechaEmision = pFechaFinal;

    ELSE

        LET dFechaEmision = dFechaEmision_esp_det; 

    END IF;
    
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
                mov.transacc, mov.fech_val,mov.num_cheq,mov.num_tarjeta,mov.folio_suc
                INTO vNum_serial_nuevo, vdescripcion, vsdocuentafin, vsdocuenta, vfechealt, vreferencia, vretiro, vdeposito, vsucursal,vtransacc,vfechval,vnum_cheq,vnum_tarjeta,vfolio_suc
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
                mov.transacc, mov.fech_val,mov.num_cheq,mov.num_tarjeta,mov.folio_suc
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
                mov.transacc, mov.fech_val,mov.num_cheq,mov.num_tarjeta,mov.folio_suc
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
                mov.transacc, mov.fech_val,mov.num_cheq,mov.num_tarjeta,mov.folio_suc
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

            -- // INICIA SELECCION DE INFORMACION SPEI		
            IF vtransacc IN ('0273', '0446') THEN
                
                SELECT FIRST 1 
                'BANCO ORIGEN: '||NVL(TRIM(bn.vchrnombrecorto),''), --Linea 2
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
            
                SELECT FIRST 1 
                'BANCO DESTINO: '||NVL(TRIM(bn.vchrnombrecorto),'') , --Linea 2
                'FECHA TRANSFERENCIA: '||NVL(TRIM((LPAD(DAY(tb.dtfechacaptura),2,0)||'/'||LPAD(MONTH(tb.dtfechacaptura),2,0)||'/'||YEAR(tb.dtfechacaptura)) ),''), --Linea 3
                'CLABE: '||NVL(TRIM(tb.vchrcuentabenef),''), --Linea 4
                'BENEFICIARIO: '||NVL(TRIM(tb.vchrnombrebenef),''), --Linea 5
                '(Dato no verificado por esta Institucion) ', --Linea 5 Leyenda
                'REF: '||NVL(TRIM(tb.intrefnumerica::CHAR(8)),''), --Linea 6
                TRIM('CONCEPTO: '||(CASE WHEN vchrconceptopago IS NULL THEN '' ELSE vchrconceptopago END)||(CASE WHEN vchrconceptopago2 IS NULL THEN '' ELSE vchrconceptopago2 END)) AS CONCEPTO --Linea 7
                INTO vlinea2, vlinea3, vlinea4, vlinea5, vlinea5leyenda, vlinea6, vlinea7
                FROM bdispei:tblhistpago tb, 
                bdispei:tblbanco bn 
                WHERE tb.dtfechacaptura >= vfechealt
                AND tb.vchrclaverastreo = vreferencia
                AND tb.chrestatusenvio IN('L','E')
                AND bn.cvecesif = tb.cvecesifbcodest;
                
            ELIF vtransacc IN ('0206','0207') THEN
            
                LET vreferencia = "PagarÃÂ© no."||' ' ||vreferencia;
            
            ELIF vtransacc = '0232' THEN
                
                LET vreferencia = "Cheque no."||' '||vnum_cheq||' '||"BANCO"||' ' ||SUBSTR(vreferencia ,1,3);
                
            ELIF vtransacc = '0269' THEN
                
                LET vreferencia = "Cheque no."||' '||vnum_cheq ;
                
            ELIF vtransacc IN ('3228','3246') THEN
                
                LET vreferencia = "Cheque no."||' '|| vnum_cheq;
                
            ELIF vtransacc IN ('0340','0342','0345') THEN
                
                LET vreferencia = "Folio de aclaraciÃÂ³n"||' '||vreferencia;
            
            ELIF vtransacc IN ('0343','0344')  THEN
                
                LET vreferencia = "Folio de aclaraciÃÂ³n"||' '||SUBSTR(vfolio_suc,7,16) ;
            
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
                                                
                    LET vreferencia = 'InversiÃÂ³n no. ' ||vnum_inv_cte;
                        
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
                                        
                LET vreferencia = 'InversiÃÂ³n no. ' ||vnum_inv_cte;

            ELIF vtransacc  = '0235' THEN
                
                SELECT FIRST 1 cuenta 
                INTO vnum_pagare 
                FROM bdinvers:sv_movhis  
                WHERE transacc = '0500' 
                AND folio_suc = vfolio_suc;
                    
                LET vreferencia = 'PagarÃÂ© no. ' ||vnum_pagare;
				
                -----Agregadas 13/09/2016
			
				ELIF vtransacc IN ('1110','1140','1170') THEN
            
                    LET vreferencia = "Remesa BTS no."||' ' ||vreferencia;
							
				ELIF vtransacc = '1131' THEN
            
                    LET vreferencia = "NÃÂºmero de telÃÂ©fono."||' ' ||vreferencia;
				
				ELIF vtransacc = '1132' THEN
            
                    LET vreferencia = "CrÃÂ©dito Coppel no."||' ' ||vreferencia;
				
				ELIF vtransacc IN ('1134', '1135', '1136') THEN
            
                    LET vreferencia = "Orden de Pago no."||' ' ||vreferencia;
				
				ELIF vtransacc IN ('1137', '1138','1145','1146','1147','1154', '1184') THEN
            
                    LET vreferencia = "no. de referencia"||' ' ||vreferencia;
				
				ELIF vtransacc = '1141' THEN
            
                    LET vreferencia = "Cuenta que se pagarÃÂ© no."||' ' ||vreferencia;
				
				ELIF vtransacc = '1149' THEN
            
                    LET vreferencia = "LÃÂ­nea de captura"||' ' ||vreferencia;
				
			    ELIF vtransacc IN ('1191', '1192') THEN
            
                    LET vreferencia = "NÃÂºmero de clave de envÃÂ­o"||' ' ||vreferencia;
				
				ELIF vtransacc  = '0281' THEN
            
                    LET vreferencia = "Tarjeta no. "||vnum_tarjeta||' '||vreferencia;
			        
                ELIF vtransacc IN ('0408','0409')  THEN
                
                    LET vreferencia = "Folio de aclaraciÃÂ³n"||' '||"F"||SUBSTR(vfolio_suc,7,10) ;

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

                    -- // INSERTA LINEA 5 CON LA LEYENDA (Dato no verificado por esta InstituciÃÂÃÂ³n)
                    INSERT INTO sc_detalle_edocta_factelect
                    (idreg, fecha_emision, num_cuenta, secuencia, nlinea, fechamov, descripcion, retiro, deposito, saldo)
                    VALUES
                    (vidreg, dFechaEmision, pCuenta, vsecuencia, vnlinea, vfechealt2, vlinea5leyenda, vretiro2, vdeposito2, vsdocuenta2);
                    LET vnlinea = vnlinea + 1;	

                END IF;
				
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

            END IF;
				
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
            WHERE numero = cTransaccion;
            
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
"FUNCIONAMIENTO: Reverso version anterior para los movimientos en el tratamiento especial, se agrega el ajuste para el seria",
"FECHA : 03-03-2023";

CREATE PROCEDURE "informix".sp_cuentas_por_borrar_barredora()
RETURNING CHAR(5), CHAR(5), INTEGER;

    --- Se declaran las variables  
    DEFINE vcodret1     CHAR(5);
	DEFINE vcodret2	    CHAR(5);
    DEFINE vcodret3	    CHAR(50);
	DEFINE sql_err	    INTEGER;
	DEFINE isam_err     INTEGER;
    DEFINE desc_err     CHAR(50);
	DEFINE vcontador1   INTEGER;
    DEFINE ven_transacc SMALLINT;
	DEFINE vsql         CHAR(500);
    DEFINE vstmt        CHAR(250);
    DEFINE vcuenta      CHAR(20);
       
    --- Se inicializan las varibles
    Let vcodret1     = '000'; 
	LET vcodret2     = '000';
    LET vcodret3     = '';
    LET sql_err	     = 0;
    LET isam_err     = 0;
    LET desc_err     = '';
    LET vcontador1   = 0;
    LET ven_transacc = 0;
    LET vsql         = '';
    LET vstmt        = '';
    LET vcuenta      = '';
    
	BEGIN
	
	ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cuentas_por_borrar_barredora.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcontador1;
        END IF;	
	end exception;
	
	 --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cuentas_por_borrar_barredora.out";
     --- TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'ctasxborrar' ) THEN
        DROP TABLE "informix".ctasxborrar;
    END IF;
	
    --- 1. Se crea tabla para insertar los 5544 registros.
	CREATE TABLE "informix".ctasxborrar
	  (
        cuenta char(20) not null
      )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_ctasxborrar_cta ON "informix".ctasxborrar(cuenta) ONLINE;
	  
    --- 1. Se crea la instruccion y se guarda en archivo ctasxborrar.sql para cargar la informacion en la tabla.	
	LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/cuentasxborrar.unl INSERT INTO ctasxborrar" > /resplogifx/conciliachq/ctasxborrar.sql';
    SYSTEM vsql;
    LET vsql = '';
	
    --- 1.1 Se ejecuta la instruccion que se almaceno en el archivo ctasxborrar.sql para cargar la informacion en la tabla.
	LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctasxborrar.sql';
    SYSTEM vstmt;
    LET vstmt = '';
	
	UPDATE STATISTICS MEDIUM FOR TABLE ctasxborrar;
	
	FOREACH WITH HOLD
        SELECT cuenta
          INTO vcuenta 
          FROM ctasxborrar
          
        LET vcontador1 = vcontador1 + 1;
          
        BEGIN WORK;
        LET ven_transacc = 1;
    
        --- 2.Eliminar de la tabla "cuentas" de la base de datos bdicheq, las 5544 cuentas.
        DELETE FROM cuentas
         WHERE cuenta = vcuenta;
            
        --- 3.Eliminar de la tabla "sc_ctabloqueo" de la base de datos bdicheq, las 5544 cuentas.        
        DELETE FROM sc_ctabloqueo
         WHERE cuenta = vcuenta;
            
        --- 4.Insertar en la tabla "sc_histbloq" de la base de datos bdicheq, 1 registro de desbloqueo para cada una de las 5544 cuentas.		
        INSERT INTO sc_histbloq 
        ( empresa, cuenta, tipo_mov, motivo, opcion, importe, usuario, fecha, hora, clave, status_blo, folio_suc, referencia, cve_area, cod_area, cve_tipobloq, cod_tipobloq )
        VALUES 
        ( '001', vcuenta, 'D', '00', '', 0.00, 'informix', today, '21:00:00.000', '0000', 'D', 'informix12345678', 'Desbloqueo de Cuenta', '', '', '', '' );
        
        --- 5.Actualizar en la tabla "sc_maechq" de la base de datos bdicheq, los campos (status_cta = "1") y (motivo = "00"), por cada una de las 5544 cuentas.
        UPDATE sc_maechq 
           SET status_cta = '1',
               motivo = '00'
         WHERE cuenta = vcuenta;
        
        COMMIT WORK;
        LET ven_transacc = 0;
        
        LET vcuenta = '';
	END FOREACH;
	
	END;
	
    RETURN vcodret1, vcodret2, vcontador1;
    
END PROCEDURE;