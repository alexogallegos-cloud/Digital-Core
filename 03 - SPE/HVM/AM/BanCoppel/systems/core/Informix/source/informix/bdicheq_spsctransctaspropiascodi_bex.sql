CREATE PROCEDURE "informix".spsctransctaspropiascodi_bex( pEmpresa char(3),
                                                          pSucursal char(4),
                                                          pUsuario char(8),
                                                          pTransCargo char(4),
                                                          pTransAbono char(4),
                                                          pTransSuc char(4),
                                                          pFolioSuc char(16),
                                                          pNumCtaOrigen char(12),
                                                          pNumCtaDestino char(18),
                                                          pCheque integer,
                                                          pMonto money(14,2),
                                                          pMoneda char(2),
                                                          pReferencia char(40),
                                                          pReferenciaBe char(40),
                                                          pNumTarjetaOrigen char(16),
                                                          pNumTarjetaDestino char(16),
                                                          pUsuAutoriza char(8),
                                                          pMontoTotal money(14,2),
                                                          pMontoFirme money(14,2),
                                                          pMontoSBC money(14,2),
                                                          pMontoRem money(14,2),
                                                          pDiasRet smallint,
                                                          pDocto integer,
                                                          pchridmjc char(20),       
                                                          pchrfchmjc char(20),       
                                                          pchrconcepto char(50),       
                                                          pchrcveras char(30),       
                                                          pchrcelord char(10), 
                                                          pchrdiveord char(3), 
                                                          pchrbancoord char(5), 
                                                          pchrtpoctaord char(2),  
                                                          pchrnomord char(40),  
                                                          pchrcelbenf char(20), 
                                                          pchrdivebenf char(3), 
                                                          pchrbancobenf char(5), 
                                                          pchrtpoctabenf char(2), 
                                                          pchrnombenf char(40), 
                                                          pchrnumseriecert char(20))
RETURNING char(5), char(5);

    -- SP de 23 registros
	--******************************************************

	DEFINE vcodret   char(5);
    DEFINE vcodretRev   char(5);
    DEFINE sql_err   integer;
    DEFINE vTrans    char(4);
	DEFINE vFechaHoy date;
	DEFINE vSdoDisp  money(14,2);
	DEFINE vMontoRet money(14,2);
	DEFINE vPasoCargo char(1);
	DEFINE vMensajeRet char(100);
	DEFINE vReferencia	char(40);
	DEFINE vTransCargo char(4);
	DEFINE vCliente1 CHAR(20);
	DEFINE vCuenta1 char(12);
	DEFINE vTransAbono CHAR(4);
    DEFINE cReferencia varchar(40);
    DEFINE aReferencia varchar(40);
	DEFINE vFechaProcesoOr date;
	DEFINE vFechaProcesoDe date;
	DEFINE vLogCta 			INTEGER;
	DEFINE vBin		varchar(8);
    DEFINE wvchrcodretcodi CHAR(5);
    DEFINE wreferencia    INTEGER;
    
	--// CADENA
	DEFINE vchridtpa char(2);
	DEFINE wvchrcode char(2);
	
	DEFINE vPasoAbono CHAR(1);
    DEFINE vtimestamp       LVARCHAR(20);
    DEFINE wtimestamp       CHAR(20);
    -- DEFINE vtimestamp       CHAR(13);
	  
	LET vReferencia ='' ;
   	LET vTransCargo = pTransCargo;
	LET vCliente1 ='';
	LET vCuenta1 ='';
	LET vTransAbono = pTransAbono;
	LET vPasoCargo = '0';
	LET vcodret = '00000	';
	LET vcodretRev = '000';
	LET vMensajeRet = '';
	LET cReferencia = '';
	LET aReferencia = '';
	LET vBin = '';
	LET vLogCta = LENGTH(pNumCtaDestino);
    LET wvchrcodretcodi = '00000';
	LET pchrcveras  = pFolioSuc;
    
	--// Cadena
	LET vchridtpa = '';
	LET wvchrcode = '';    
    LET vPasoAbono = '';
    LET vtimestamp = '';

	BEGIN
    
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
		    SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spsctransctaspropiascodi_bex.err";
			IF vPasoCargo = '1' THEN
				EXECUTE PROCEDURE bdicheq:reversion(pEmpresa, pSucursal, pUsuario, pFolioSuc, 'A') 
                INTO vcodretRev;
			END IF;
			IF vcodretRev = '000' THEN
				LET vcodretRev = '001';
			END IF;
			LET vcodret = sql_err;
			RETURN vcodret, vcodretRev;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/informix/Priscilla/spsctransctaspropiascodi_bex_pbe.out";
    --SET DEBUG FILE TO "/informix/ifg/spsctransctaspropiascodi_bex.out";
    --TRACE ON;
     
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    --//Se valida que los campos para el aviso de procesamiento sean correctos.
	
    IF (pchridmjc IS NULL OR pchridmjc = '' OR LENGTH(pchridmjc) <> 20) OR 
       (pchrfchmjc is null OR pchrfchmjc = '' OR LENGTH(pchrfchmjc) <> 20) THEN
     	LET wvchrcode = '10';
    END IF; 

    IF vLogCta <> 11 THEN
		IF vLogCta = 18 THEN
			SELECT cuenta 
              INTO pNumCtaDestino 
              FROM bdicheq:sc_maechq 
             WHERE cuenta_clabe = pNumCtaDestino;
		ELSE 
			IF vLogCta = 16 THEN
				LET vBin = LEFT(pNumCtaDestino, 8);
				IF vBin = '40081904' THEN 
					LET vcodret = '00001';
					LET vchridtpa = '22'; --Transf no liquidada por problemas del participante benf
					LET wvchrcode = '17'; --Numero de cuenta invalido (tarjeta,cuenta_clabe,cel,cuenta)
				ELSE
					SELECT cuenta 
                      INTO pNumCtaDestino 
                      FROM bdicheq:sc_tarjeta 
                     WHERE empresa = '001' 
                       AND num_tarjeta = pNumCtaDestino 
                       AND status_tar = 'A' 
                       AND tipo_tarjeta = 'T';
				END IF
			ELSE 
				IF vLogCta = 10 THEN	
					SELECT cuenta 
                      INTO pNumCtaDestino 
                      FROM bdicheq:sc_cuenta_telefono 
                     WHERE telefono = pNumCtaDestino;
				ELSE
					LET vcodret = '00001';
					LET vchridtpa = '22'; --Transf no liquidada por problemas del participante benf
					LET wvchrcode = '17'; --Numero de cuenta invalido (tarjeta,cuenta_clabe,cel,cuenta)
				END IF;
			END IF;			
		END IF;
		
		IF pNumCtaDestino IS NULL THEN
			LET vcodret = '00002';
			LET vchridtpa = '22'; --Transf no liquidada por problemas del participante benf
			LET wvchrcode = '17';		
		END IF;
	END IF;	

	LET wreferencia = pReferenciaBe::INTEGER;
	LET pReferenciaBe = wreferencia;
	
	---AsignaciÃÂÃÂÃÂÃÂ³n y concatenaciÃÂÃÂÃÂÃÂ³n de Cuenta del Cargo/Abono y la Referencia para el Estado de Cuenta
	LET cReferencia = TRIM(pNumCtaDestino) || ' ' ||substr(pchrconcepto,1,4) || ' ' || pReferencia; --cargo y la Referencia 
	LET aReferencia = TRIM(pNumCtaOrigen) || ' ' ||substr(pchrconcepto,1,4) || ' ' || pReferencia; --abono y la Referencia del Beneficiario

	--********************Valida las Fechas procesos*************************************************--
	IF vcodret = '00000' THEN
        SELECT fecha_proceso 
          INTO vFechaProcesoOr 
          FROM bdicheq:sc_maechq 
         WHERE cuenta = pNumCtaOrigen;
         
        SELECT fecha_proceso 
          INTO vFechaProcesoDe 
          FROM bdicheq:sc_maechq 
         WHERE cuenta = pNumCtaDestino;
        
        IF (vFechaProcesoOr <> vFechaProcesoDe) THEN
            LET vcodret = '00001';
        END IF;
    END IF
		
	IF vcodret = '00000'  THEN
        EXECUTE PROCEDURE bdicheq:cargo_ref(pEmpresa, pSucursal, pUsuario, vTransCargo, pTransSuc, pFolioSuc, pNumCtaOrigen,
                                            pCheque, pMonto, pMoneda, cReferencia, pNumTarjetaOrigen, pUsuAutoriza) 
        INTO vcodret, vTrans, vFechaHoy, vSdoDisp, vMontoRet;

        IF vcodret <> '000' THEN
            LET vchridtpa = '21'; --Transf no liquidada por problemas del participante ord
            IF vcodret IN ('962','100','777','404','200','614','400','300','951') THEN
                LET wvchrcode = '17'; 
            END IF;

            --// ejecuta el sp spei_recerrorescodi para el aviso de procesamiento
            LET vtimestamp    = dbinfo('utc_current') * 1000;
            LET wtimestamp    = vtimestamp;

            EXECUTE PROCEDURE bdispei:spei_recerrorescodi(wvchrcode, '','o',pchridmjc,pchrfchmjc,pchrconcepto,pMonto,wtimestamp,  
                      pchrcveras,pReferenciaBe,pchrcelord,pchrdiveord, pchrbancoord,pchrtpoctaord,  
                      pNumCtaOrigen,pchrnomord,pchrcelbenf,pchrdivebenf,pchrbancobenf,pchrtpoctabenf,  
                      pNumCtaDestino,pchrnombenf,pchrnumseriecert) 
              INTO wvchrcodretcodi;

            RETURN vcodret, vcodretRev;
        ELSE
            LET vPasoCargo = '1';
        END IF;

        EXECUTE PROCEDURE bdicheq:abono_ref(pEmpresa, pSucursal, pUsuario, vTransAbono, pTransSuc, pFolioSuc, pNumCtaDestino, pDocto,
                                            pMontoTotal, pMontoFirme, pMontoSBC, pMontoRem, pDiasRet, pMoneda, aReferencia, pNumTarjetaDestino, pUsuAutoriza) 
        INTO vcodret;

        IF vcodret <> '000' THEN
            EXECUTE PROCEDURE bdicheq:reversion(pEmpresa, pSucursal, pUsuario, pFolioSuc, 'A') 
            INTO vcodretRev;

            IF vcodretRev = '000' THEN
                LET vcodretRev = '001';
            END IF;

            LET vchridtpa = '22'; --Transf no liquidada por problemas del participante benf
            
            IF vcodret in ('999','100','40034','200','375','374','301') THEN
                LET wvchrcode = '17';
            ELSE
                IF vcodret in ('420','397','371','959','401') THEN
                    LET wvchrcode = '13';
                END IF;	
            END IF;	
            
            --// envia los campos para el aviso de procesamiento
            LET vtimestamp  = dbinfo('utc_current') * 1000;
            LET wtimestamp    = vtimestamp;

            EXECUTE PROCEDURE bdispei:spei_recerrorescodi(wvchrcode, '','b',pchridmjc,pchrfchmjc,pchrconcepto,pMonto,wtimestamp,  
                      pchrcveras,pReferenciaBe,pchrcelord,pchrdiveord, pchrbancoord,pchrtpoctaord,  
                      pNumCtaOrigen,pchrnomord,pchrcelbenf,pchrdivebenf,pchrbancobenf,pchrtpoctabenf, 
                      pNumCtaDestino,pchrnombenf,pchrnumseriecert) 
            INTO wvchrcodretcodi;
            
            RETURN vcodret, vcodretRev;
        ELSE
            LET vPasoAbono = '1';
        END IF;
	ELSE
		LET vtimestamp  = dbinfo('utc_current') * 1000;
    LET wtimestamp    = vtimestamp;

      EXECUTE PROCEDURE bdispei:spei_recerrorescodi(wvchrcode, '','b',pchridmjc,pchrfchmjc,pchrconcepto,pMonto,wtimestamp,  
                      pchrcveras,pReferenciaBe,pchrcelord,pchrdiveord, pchrbancoord,pchrtpoctaord,  
                      pNumCtaOrigen,pchrnomord,pchrcelbenf,pchrdivebenf,pchrbancobenf,pchrtpoctabenf, 
                      pNumCtaDestino,pchrnombenf,pchrnumseriecert) 
      INTO wvchrcodretcodi;
        
			RETURN vcodret, vcodretRev;
	END IF;
    
    IF vPasoCargo = '1' AND vPasoAbono = '1' THEN
        LET vchridtpa = '1';
        LET wvchrcode = '0';    
    
        LET vtimestamp  = dbinfo('utc_current') * 1000;
        LET wtimestamp    = vtimestamp;
		--//Aviso para el cargo
        EXECUTE PROCEDURE bdispei:spei_recerrorescodi(0, 'CARGO','o',pchridmjc,pchrfchmjc,pchrconcepto,pMonto,wtimestamp,  
                      pchrcveras,pReferenciaBe,pchrcelord,pchrdiveord, pchrbancoord,pchrtpoctaord,  
                      pNumCtaOrigen,pchrnomord,pchrcelbenf,pchrdivebenf,pchrbancobenf,pchrtpoctabenf,
                      pNumCtaDestino,pchrnombenf,pchrnumseriecert) 
        INTO wvchrcodretcodi;
		--//Aviso para el abono
        EXECUTE PROCEDURE bdispei:spei_recerrorescodi(wvchrcode, '','o',pchridmjc,pchrfchmjc,pchrconcepto,pMonto,wtimestamp,  
                      pchrcveras,pReferenciaBe,pchrcelord,pchrdiveord, pchrbancoord,pchrtpoctaord,  
                      pNumCtaOrigen,pchrnomord,pchrcelbenf,pchrdivebenf,pchrbancobenf,pchrtpoctabenf,
                      pNumCtaDestino,pchrnombenf,pchrnumseriecert) 
        INTO wvchrcodretcodi;
    END IF;

    END;
    
    RETURN vcodret, vcodretRev;

END PROCEDURE
DOCUMENT
'CREADO POR: PRISCILLA BENITO',
'OBJETIVO: PROCESAR LOS PAGOS Y COBROS CODI INTRABANCARIOS',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_alertas_codi() 
RETURNING CHAR(5), CHAR(150); 
    
    DEFINE Sql_Err     INTEGER;
    DEFINE Isam_Err    INTEGER;
    DEFINE Desc_Err    CHAR(50);
    DEFINE cCodRet1    CHAR(5);
    DEFINE cCodRet2    CHAR(5);
    DEFINE cCodRet3    CHAR(50);
    DEFINE iContador1  INTEGER;
    DEFINE iContador2  INTEGER;
    DEFINE iContador3  INTEGER;
    DEFINE iComienza   SMALLINT;
    DEFINE cAbierto    CHAR(1);
    DEFINE iOperAbono  INTEGER;
    DEFINE vintabonos  INTEGER;
    DEFINE iOperCargo  INTEGER;
    DEFINE vintcargos  INTEGER;
    DEFINE cMensaje    CHAR(150);
    
    LET Sql_Err	    = 0;
    LET Isam_Err    = 0;
    LET Desc_Err    = '';
    LET cCodRet1    = '000';
    LET cCodRet2    = '';
    LET cCodRet3    = '';  
    LET iContador1  = 0;
    LET iContador2  = 0;
    LET iContador3  = 0;
    LET iComienza   = -1;
    LET cAbierto    = '0';
    LET iOperAbono  = 0;
    LET vintabonos  = 0;
    LET iOperCargo  = 0;
    LET vintcargos  = 0;
    LET cMensaje    = '';
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_alertas_codi.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET cCodRet1 = Sql_Err;
            LET cCodRet2 = Isam_Err;
            LET cCodRet3 = Desc_Err;
            RETURN cCodRet1, cMensaje;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_alertas_codi.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTIENE PARAMETROS DE UMBRALES
    SELECT vchrvalor::INT
      INTO vintabonos
      FROM bdispei:tblparametros
     WHERE vchrcveparametro = 'OPER_ABOSCODI_NUMERO';
     
    SELECT vchrvalor::INT
      INTO vintcargos
      FROM bdispei:tblparametros
     WHERE vchrcveparametro = 'OPER_CGOSCODI_NUMERO';
    
    -- // VALIDA OPERACIONES CODI DE ABONO
    SELECT COUNT(*)
      INTO iOperAbono
      FROM sc_movdia
     WHERE transacc = '0446'
       AND fech_alt = today
       AND cancelad <> 'S';
       
    IF iOperAbono is null THEN
        LET iOperAbono = 0;
    END IF;
    
    -- // VALIDA OPERACIONES CODI DE CARGO
    SELECT COUNT(*)
      INTO iOperCargo
      FROM sc_movdia
     WHERE transacc = '0447'
       AND fech_alt = today
       AND cancelad <> 'S';
       
    IF iOperCargo is null THEN
        LET iOperCargo = 0;
    END IF;
    
    IF iOperAbono < vintabonos AND iOperCargo < vintcargos THEN
        LET cCodRet1 = '000';
        LET cMensaje = '';
    ELIF iOperAbono >= vintabonos AND iOperCargo < vintcargos THEN
        LET cCodRet1 = '111';
        LET cMensaje = 'NO. ABONOS CODI SE HA REBASADO, LIMITE: '||vintabonos||', ABONOS: '||iOperAbono||'.';
    ELIF iOperAbono < vintabonos AND iOperCargo >= vintcargos THEN
        LET cCodRet1 = '111';
        LET cMensaje = 'NO. CARGOS CODI SE HA REBASADO, LIMITE: '||vintcargos||', CARGOS: '||iOperCargo||'.';
    ELIF iOperAbono >= vintabonos AND iOperCargo >= vintcargos THEN
        LET cCodRet1 = '111';
        LET cMensaje = 'ABONOS Y CARGOS CODI SE HA REBASADO, LIMITE ABONOS: '||vintabonos||', LIMITE CARGOS: '||vintcargos||', ABONOS: '||iOperAbono||' CARGOS: '||iOperCargo||' ';
    END IF;
    
    END; 
    
    RETURN cCodRet1, cMensaje;
    
END PROCEDURE;