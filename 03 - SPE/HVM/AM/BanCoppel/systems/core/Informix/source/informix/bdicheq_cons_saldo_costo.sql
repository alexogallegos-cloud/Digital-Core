create procedure "informix".cons_saldo_costo(pcuenta char(20))

returning char(5),money(16,2),char(1);

    define vcodret    char(5);
    define vsqlerr    integer;
    define vcuenta    char(20);
    define vsdodisp   money(16,2);
    define vstatuscta char(1);
    define vmotivo    char(2);
    define vcargo     char(1);
    define vabono     char(1);

    let vcodret    = "000";
    let vcuenta    = "";
    let vsdodisp   =  0;
    let vstatuscta = " ";
    
    begin
    
    on exception set vsqlerr
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            return vcodret,vsdodisp,vstatuscta;
        end if
    end exception;
    
    set isolation to dirty read;
    set lock mode to wait 3;

    --- // Valida que la Cuenta no sea Blanco
    if pcuenta = " " then
        let vcodret = "110";
        return vcodret,vsdodisp,vstatuscta;
    end if

    --- // Valida que Exista la Cuenta de Cheques
    --RQM 09 704. Se agrega el campo saldo_sbc al calculo del saldo disponible. EEAP
    select cuenta, sdo_actual - (sdo_retenido + sdo_cong + imp_sbg_ccc + saldo_sbc), status_cta, motivo
      into vcuenta, vsdodisp, vstatuscta, vmotivo
      from sc_maechq
     where cuenta = pcuenta;
     
    if vcuenta is null or vcuenta <> pcuenta then
        let vcodret = "100";
        return vcodret, vsdodisp,vstatuscta;
    end if

    if vstatuscta = "3" then
        select cargo, abono 
          into vcargo, vabono
          from sc_bloqueo
         where codigo = vmotivo;
         
        if vcargo = "S" or vabono = "S" then
            let vstatuscta = "1";
        end if
    end if
    
    return vcodret,vsdodisp,vstatuscta;
    
    end
    
end procedure

DOCUMENT 
'MODIFICO : Eric Emilio Armenta Perez',
'FECHA : 02-06-2025',
'MODIFICACION : Se modifica la formula del calculo de saldo disponible para considerar un nuevo campo',
'PROYECTO : RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdicheq',
'VER   : 1.2';

CREATE PROCEDURE "informix".spei_ctaspropiasdevcodi( pchridmjc CHAR(20), 
                                                     pchridmjcori CHAR(20),
                                                     pchrconcepto CHAR(50),
                                                     pMontoori DECIMAL(12,2),
                                                     pMonto DECIMAL(12,2),
                                                     pReferenciaBe CHAR(7),
                                                     pchrtpoaviso CHAR(2),
                                                     pchrnomord CHAR(40), 
                                                     pNumCtaOrigen CHAR(20), 
                                                     pchrbancoord CHAR(5),
                                                     pchrtpoctaord CHAR(2), 
                                                     pchrdiveord CHAR(3), 
                                                     pchraliasord CHAR(10),
                                                     pchrnombenf CHAR(40), 
                                                     pNumCtaDestino CHAR(20), 
                                                     pchrbancobenf CHAR(5),  
                                                     pchrtpoctabenf CHAR(2),
                                                     pchrdivebenf CHAR(3),
                                                     pchraliasben CHAR(20),
                                                     pchrfchmjc CHAR(20),
                                                     pchrtipopago CHAR(2),
                                                     pchrUsuario CHAR(8),
                                                     pintBancoDest INTEGER,
                                                     pchrFolioSuc CHAR(16),
                                                     pchrfchcaptura DATE,
                                                     pchrRFCBenef VARCHAR(18))
RETURNING char(5), char(5);

    -- SP de 38 registros
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
    DEFINE vLogCta 		   INTEGER;
    DEFINE vBin		       varchar(8);
    DEFINE wvchrcodretcodi CHAR(5);
    DEFINE vLogCtaord 	   INTEGER;
    DEFINE vintoperaciones INTEGER;
	DEFINE vintoperacioneshist INTEGER;
	DEFINE vintdevo INTEGER;
	DEFINE vintdevohist INTEGER;
    --// CADENA
    DEFINE vvchridtpa char(2);
    DEFINE wvchrcode char(2);
	
    DEFINE vPasoAbono CHAR(1);
    DEFINE vtimestamp LVARCHAR(20);
    DEFINE wtimestamp CHAR(20);
	
    --// Campos para el cargo Ã³ abono
    DEFINE vchrEmpresa char(3);
    DEFINE vchrSucursal char(4);
    DEFINE vchrTransSuc char(4);
    DEFINE vchrMoneda char(2);
    DEFINE vintCheque integer;
    DEFINE vchrNumTarjetaOrigen char(16);
    DEFINE vchrNumTarjetaDestino char(16);
    DEFINE vchrUsuAutoriza char(8);
    DEFINE vMontoTotal money(14,2);
    DEFINE vMontoFirme money(14,2);
    DEFINE vMontoSBC money(14,2);
    DEFINE vMontoRem money(14,2);
    DEFINE vintDiasRet smallint;
    DEFINE vintDocto integer;
    DEFINE vvchrcveras char(30);
    DEFINE vchrnumseriecert char(20);
    DEFINE vchrReferenciaord char(7);
	DEFINE vchrid VARCHAR(2);
	DEFINE vchridhist VARCHAR(2);
	DEFINE vchrauxnombenf CHAR(40);
	DEFINE vchrauxnombenfhist CHAR(40);
	DEFINE vchrauxhistcveras CHAR(30);
	DEFINE vchrauxcveras CHAR(30);
	DEFINE vdecauxmonto DECIMAL(12,2);
	DEFINE vdecauxmontohist DECIMAL(12,2);
    DEFINE vchrnum_ctebenf char(20);
	DEFINE vauxserial INTEGER;
	DEFINE vauxhistserial INTEGER;
	DEFINE vchrNumCtaDestinoA CHAR(18);
	DEFINE vchrpNumCtaOrigenC CHAR(18);	
	
    LET vReferencia ='' ;
    LET vTransCargo = '0545';
    LET vCliente1 ='';
    LET vCuenta1 ='';
    LET vTransAbono = '0544';
    LET vPasoCargo = '0';
    LET vcodret = '00000	';
    LET vcodretRev = '000';
    LET vMensajeRet = '';
    LET cReferencia = '';
    LET aReferencia = '';
    LET vBin = '';
    LET vLogCta = LENGTH(pNumCtaDestino);
    LET vLogCtaord = LENGTH(pNumCtaOrigen);
    LET wvchrcodretcodi = '00000';
    LET vintoperaciones = 0;
	LET vintoperacioneshist =0;
	LET vintdevo = 0;
	LET vintdevohist = 0;
	
    
    --// Cadena
    LET vvchridtpa = '';
    LET wvchrcode = '';    
    LET vPasoAbono = '';
    LET vtimestamp = '';
	
    --// Campos para el cargo Ã³ abono
	
    LET vchrEmpresa = '001';
    LET vchrSucursal  = '5011';
    LET vchrTransSuc  = '';
    LET vintCheque = 0;
    LET vchrNumTarjetaOrigen = '';
    LET vchrNumTarjetaDestino = '';
    LET vchrUsuAutoriza = 'transBPI';
    LET vMontoTotal = pMonto; -- es el abono
    LET vMontoFirme = pMonto;
    LET vMontoSBC = 0;
    LET vMontoRem = 0;
    LET vintDiasRet = 0;
    LET vintDocto = 0;
    LET vvchrcveras = TRIM(pchrFolioSuc)||TRIM(pchridmjc);
    LET vchrnumseriecert = '';
    LET vchrReferenciaord  = '';
    LET vchrMoneda = '01';
    LET vchrnum_ctebenf  = '';
	LET vchrNumCtaDestinoA =pNumCtaDestino;
	LET vchrpNumCtaOrigenC=pNumCtaOrigen;
	

BEGIN
    
    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spsctransctaspropiascodi_bex.err";
            TRACE ON;
            IF vPasoCargo = '1' THEN
                EXECUTE PROCEDURE bdicheq:reversion(vchrEmpresa, vchrSucursal, pchrUsuario, pchrFolioSuc, 'A') 
                INTO vcodretRev;
            END IF;
            IF vcodretRev = '000' THEN
                LET vcodretRev = '001';
            END IF;
            LET vcodret = sql_err;
            RETURN vcodret, vcodretRev;
        END IF;
    END EXCEPTION;
	
    --SET DEBUG FILE TO "/resplogifx/conciliachq/spei/bdicheq_spei_ctaspropiasdevcodi.out";
    --SET DEBUG FILE TO "/informix/Priscilla/spei_ctaspropiasdevcodi.out";c--comentado
    --SET DEBUG FILE TO "/informix/ifg/spei_ctaspropiasdevcodi.out";
    --TRACE ON;
     
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;  

    --//Valida el tipo de cuenta
    IF vLogCta <> 11 THEN
  		  IF vLogCta = 18 AND pchrtpoctabenf='40' THEN
  			  SELECT cuenta,num_cte,cuenta_clabe
                  INTO pNumCtaDestino, vchrnum_ctebenf,vchrNumCtaDestinoA
                  FROM bdicheq:sc_maechq 
                 WHERE cuenta_clabe = pNumCtaDestino;
  		  ELSE 
  			  IF (vLogCta = 16 AND pchrtpoctabenf='3') OR (vLogCta = 16 AND pchrtpoctabenf='03') THEN
  				  LET vBin = LEFT(pNumCtaDestino, 8);
  				  IF vBin = '40081904' THEN 
  					  LET vcodret = '00001';
  					  LET wvchrcode = '17'; --Numero de cuenta invalido (tarjeta,cuenta_clabe,cel,cuenta)
  				  ELSE
  					  SELECT cuenta,num_tarjeta
                          INTO pNumCtaDestino,vchrNumCtaDestinoA 
                          FROM bdicheq:sc_tarjeta 
                         WHERE empresa = '001' 
                           AND num_tarjeta = pNumCtaDestino 
                           AND status_tar = 'A' 
                           AND tipo_tarjeta = 'T';
  				  END IF
  			  ELSE 
  				  IF vLogCta = 10 AND pchrtpoctabenf='10' THEN	
  					  SELECT cuenta,telefono 
                          INTO pNumCtaDestino,vchrNumCtaDestinoA 
                          FROM bdicheq:sc_cuenta_telefono 
                         WHERE telefono = pNumCtaDestino;
  				  ELSE
  					  LET vcodret = '00001';
  					  LET wvchrcode = '17'; --Numero de cuenta invalido (tarjeta,cuenta_clabe,cel,cuenta)
  				  END IF;
  			  END IF;			
  		  END IF;
  		
  		  IF pNumCtaDestino IS NULL THEN
  			  LET vcodret = '00002';
  			  LET wvchrcode = '17';		
          END IF;
	ELSE
  		  IF vLogCta = 11 AND pchrtpoctabenf='40' THEN
  			  SELECT cuenta,num_cte,cuenta_clabe
                INTO pNumCtaDestino, vchrnum_ctebenf,vchrNumCtaDestinoA
              FROM bdicheq:sc_maechq 
              WHERE cuenta_clabe = pNumCtaDestino;
		  ELSE
			  LET vcodret = '00001';
			  LET wvchrcode = '17'; --Numero de cuenta invalido (tarjeta,cuenta_clabe,cel,cuenta)
          END IF;				 
    END IF;	

	IF vLogCta = 11 THEN
		SELECT num_cte INTO vchrnum_ctebenf
		 FROM bdicheq:sc_maechq
		WHERE cuenta = pNumCtaDestino;
	END IF;
	
	--//Se obtiene el RFC del beneficiario
	SELECT rfc  INTO pchrRFCBenef
	  FROM bdinteg:si_cliente
	WHERE numcte  = vchrnum_ctebenf;
	

	--Obtener la cuenta correspondiente al tipo de cuenta del ordenante
	IF pchrtpoctaord = '40' AND vLogCtaord =18 THEN
	    SELECT cuenta,cuenta_clabe 
            INTO pNumCtaOrigen,vchrpNumCtaOrigenC
            FROM bdicheq:sc_maechq 
        WHERE cuenta_clabe = pNumCtaOrigen;
	ELSE 
	    IF pchrtpoctaord = '10' AND vLogCtaord =10 THEN
		    SELECT telefono
			  INTO vchrpNumCtaOrigenC
			  FROM bdicheq:sc_cuenta_telefono 
			 WHERE telefono = pNumCtaOrigen;
		ELSE
			IF pchrtpoctaord = '3' AND vLogCtaord =16 THEN
				SELECT num_tarjeta 
				  INTO vchrpNumCtaOrigenC 
				  FROM bdicheq:sc_tarjeta 
				 WHERE empresa = '001' 
				   AND num_tarjeta = pNumCtaOrigen 
				   AND status_tar = 'A' 
				   AND tipo_tarjeta = 'T';
			ELSE
				IF pchrtpoctaord='03' AND vLogCtaord=11 THEN
             	    SELECT cuenta,cuenta_clabe 
						INTO pNumCtaOrigen,vchrpNumCtaOrigenC
						FROM bdicheq:sc_maechq 
					WHERE cuenta = pNumCtaOrigen;     
					LET pchrtpoctaord='40';
				END IF;
			END IF;
		END IF;
	END IF;	

	IF vchrpNumCtaOrigenC IS NULL THEN
		LET vcodret = '00002';		LET wvchrcode = '17';		
	END IF;	
    
	--//Se valida que los campos para el aviso de procesamiento sean correctos.
    IF (pchridmjc IS NULL OR pchridmjc = '' OR LENGTH(pchridmjc) <> 20) OR 
       (pchrfchmjc is null OR pchrfchmjc = '' ) THEN
        LET vcodret  = '00007'; 
        LET wvchrcode = '10';
		LET vtimestamp  = dbinfo('utc_current') * 1000;
        LET wtimestamp    = vtimestamp;

        EXECUTE PROCEDURE bdispei:spei_recerrorescodi(wvchrcode,'D','o',pchridmjc,pchrfchmjc,pchrconcepto,pMonto,wtimestamp,
					  vvchrcveras,pReferenciaBe,pchraliasben,pchrdivebenf,pchrbancobenf,pchrtpoctabenf,
					  vchrNumCtaDestinoA,pchrnombenf,pchraliasord,pchrdiveord,pchrbancoord,pchrtpoctaord,
					  vchrpNumCtaOrigenC,pchrnomord,vchrnumseriecert)
        INTO wvchrcodretcodi;
        
		RETURN vcodret, vcodretRev;		
    END IF; 
	--// Se obtiene el nombre completo del beneficiario y la clave de rastreo para el aviso de procesamiento
	LET pchridmjc = TRIM(pchridmjc);
	SELECT count(vchrnomord) INTO vintoperaciones
		FROM bdispei:tbl_stsprocodi
	WHERE vchridmjc = pchridmjc AND vchridtpa  = '1';
	
	SELECT count(vchrnomord) INTO vintoperacioneshist
		FROM bdispei:tbl_histstsprocodi
	WHERE vchridmjc = pchridmjc AND vchridtpa  = '1';
	
    --//Valida si existe una devolucion
    SELECT count(vchrnomord) INTO vintdevo
		FROM bdispei:tbl_stsprocodi
	WHERE vchridmjc = pchridmjc AND vchridtpa  = '61';
	
	SELECT count(vchrnomord) INTO vintdevohist
		FROM bdispei:tbl_histstsprocodi
	WHERE vchridmjc = pchridmjc AND vchridtpa  = '61';
	
    IF (vintdevo > 0) OR (vintdevohist > 0) THEN
         LET vcodret = '00012';
		 LET wvchrcode = '17';
		 LET vtimestamp    = dbinfo('utc_current') * 1000;
         LET wtimestamp    = vtimestamp;
		 EXECUTE PROCEDURE bdispei:spei_recerrorescodi(wvchrcode, 'D','o',pchridmjc,pchrfchmjc,pchrconcepto,pMonto,wtimestamp,
					  vvchrcveras,pReferenciaBe,pchraliasben,pchrdivebenf,pchrbancobenf,pchrtpoctabenf,
					  vchrNumCtaDestinoA,pchrnombenf,pchraliasord,pchrdiveord, pchrbancoord,pchrtpoctaord,
					  vchrpNumCtaOrigenC,pchrnomord,vchrnumseriecert)
            INTO wvchrcodretcodi;
		
		RETURN vcodret, vcodretRev;
    END IF;
	
	IF (vintoperaciones > 1) OR (vintoperacioneshist > 1) THEN
	    --//No se puede devolver porque hay dos operaciones con el mismo idmc y mismo id de aviso
		 LET vcodret = '00013';
		 LET wvchrcode = '17';
		 LET vtimestamp    = dbinfo('utc_current') * 1000;
         LET wtimestamp    = vtimestamp;
		 EXECUTE PROCEDURE bdispei:spei_recerrorescodi(wvchrcode, 'D','o',pchridmjc,pchrfchmjc,pchrconcepto,pMonto,wtimestamp,
					  vvchrcveras,pReferenciaBe,pchraliasben,pchrdivebenf,pchrbancobenf,pchrtpoctabenf,
					  vchrNumCtaDestinoA,pchrnombenf,pchraliasord,pchrdiveord, pchrbancoord,pchrtpoctaord,
					  vchrpNumCtaOrigenC,pchrnomord,vchrnumseriecert)
            INTO wvchrcodretcodi;
		RETURN vcodret, vcodretRev;
	END IF;
	
	--//Obtiene el ultimo registro
    SELECT MAX(num_serial) INTO vauxserial
    FROM bdispei:tbl_stsprocodi 
    WHERE vchridmjc = pchridmjc AND vchridtpa IN ('1','21','22','23','24','31','32');  
      
	SELECT MAX(num_serial) INTO vauxhistserial
    FROM bdispei:tbl_histstsprocodi 
    WHERE vchridmjc = pchridmjc AND vchridtpa IN ('1','21','22','23','24','31','32'); 
	
	--//Valida que exista la operacion original
	SELECT FIRST 1 vchridtpa,mnyimporte,TRIM(vchrnomord),vchrcveras  INTO vchrid,vdecauxmonto,vchrauxnombenf,vchrauxcveras
	  FROM bdispei:tbl_stsprocodi
	WHERE vchridmjc = pchridmjc AND vchridtpa IN ('1','21','22','23','24','31','32') AND num_serial = vauxserial;
	
	
	
	SELECT FIRST 1 vchridtpa,mnyimporte,TRIM(vchrnomord),vchrcveras  INTO vchridhist,vdecauxmontohist,vchrauxnombenfhist,vchrauxhistcveras
	  FROM bdispei:tbl_histstsprocodi
	WHERE vchridmjc = pchridmjc AND vchridtpa IN ('1','21','22','23','24','31','32') AND num_serial = vauxhistserial;
	
	IF (vchrid IS NULL ) AND (vchridhist IS NULL) THEN
		 LET vcodret = '00008';		 LET wvchrcode = '17';
		 LET vtimestamp    = dbinfo('utc_current') * 1000;
         LET wtimestamp    = vtimestamp;
		 EXECUTE PROCEDURE bdispei:spei_recerrorescodi(wvchrcode, 'D','o',pchridmjc,pchrfchmjc,pchrconcepto,pMonto,wtimestamp,
					  vvchrcveras,pReferenciaBe,pchraliasben,pchrdivebenf,pchrbancobenf,pchrtpoctabenf,
					  vchrNumCtaDestinoA,pchrnombenf,pchraliasord,pchrdiveord, pchrbancoord,pchrtpoctaord,
					  vchrpNumCtaOrigenC,pchrnomord,vchrnumseriecert)
            INTO wvchrcodretcodi;
		RETURN vcodret, vcodretRev;	
	ELSE
       IF(vchrid <> '1') AND (vchridhist <> '1') THEN
		   LET vcodret = '00008';		   LET wvchrcode = '17';
		   LET vtimestamp    = dbinfo('utc_current') * 1000;
           LET wtimestamp    = vtimestamp;
		   EXECUTE PROCEDURE bdispei:spei_recerrorescodi(wvchrcode, 'D','o',pchridmjc,pchrfchmjc,pchrconcepto,pMonto,wtimestamp,
					  vvchrcveras,pReferenciaBe,pchraliasben,pchrdivebenf,pchrbancobenf,pchrtpoctabenf,
					  vchrNumCtaDestinoA,pchrnombenf,pchraliasord,pchrdiveord, pchrbancoord,pchrtpoctaord,
					  vchrpNumCtaOrigenC,pchrnomord,vchrnumseriecert)
              INTO wvchrcodretcodi;
		   RETURN vcodret, vcodretRev;		   
       END IF;	   
	END IF;
	
	IF vchrauxnombenfhist IS NULL OR vchrauxnombenfhist = '' THEN
	    LET pchrnombenf = vchrauxnombenf;
	ELSE
		LET pchrnombenf = vchrauxnombenfhist;
	END IF;
	

	--// Valida el monto original de la operaciÃ³n
	IF vdecauxmonto > pMonto AND  vdecauxmontohist >pMonto THEN
		 LET vcodret = '00009';
		 LET wvchrcode = '17';
		 LET vtimestamp    = dbinfo('utc_current') * 1000;
         LET wtimestamp    = vtimestamp;
		 EXECUTE PROCEDURE bdispei:spei_recerrorescodi(wvchrcode, 'D','o',pchridmjc,pchrfchmjc,pchrconcepto,pMonto,wtimestamp,
					  vvchrcveras,pReferenciaBe,pchraliasben,pchrdivebenf,pchrbancobenf,pchrtpoctabenf,
					  vchrNumCtaDestinoA,pchrnombenf,pchraliasord,pchrdiveord, pchrbancoord,pchrtpoctaord,
					  vchrpNumCtaOrigenC,pchrnomord,vchrnumseriecert)
            INTO wvchrcodretcodi;
		RETURN vcodret, vcodretRev;	
	END IF;	
	
	---Asignacion y concatenacion de Cuenta del Cargo/Abono y la Referencia para el Estado de Cuenta
	LET cReferencia = TRIM(pNumCtaDestino) || ' ' || vchrReferenciaord; --cargo y la Referencia 
	LET aReferencia = TRIM(pNumCtaOrigen) || ' ' || pReferenciaBe; --abono y la Referencia del Beneficiario

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
            LET vcodret = '00006'; ---Las fechas proceso de cuentas beneficiario y ordenante no estan actualizadas
			LET wvchrcode = '00006';
			LET vtimestamp    = dbinfo('utc_current') * 1000;
            LET wtimestamp    = vtimestamp;
		    EXECUTE PROCEDURE bdispei:spei_recerrorescodi(wvchrcode, 'D','o',pchridmjc,pchrfchmjc,pchrconcepto,pMonto,wtimestamp,
					  vvchrcveras,pReferenciaBe,pchraliasben,pchrdivebenf,pchrbancobenf,pchrtpoctabenf,
					  vchrNumCtaDestinoA,pchrnombenf,pchraliasord,pchrdiveord, pchrbancoord,pchrtpoctaord,
					  vchrpNumCtaOrigenC,pchrnomord,vchrnumseriecert)
                INTO wvchrcodretcodi;
		    RETURN vcodret, vcodretRev;
        END IF;
    END IF
	--//Valida qe existan las cuentas
	IF vFechaProcesoOr IS NULL OR vFechaProcesoOr = ''THEN
	    LET vcodret = '00010';		LET wvchrcode = '17';
		LET vtimestamp    = dbinfo('utc_current') * 1000;
        LET wtimestamp    = vtimestamp;
		EXECUTE PROCEDURE bdispei:spei_recerrorescodi(wvchrcode, 'D','o',pchridmjc,pchrfchmjc,pchrconcepto,pMonto,wtimestamp,
					  vvchrcveras,pReferenciaBe,pchraliasben,pchrdivebenf,pchrbancobenf,pchrtpoctabenf,
					  vchrNumCtaDestinoA,pchrnombenf,pchraliasord,pchrdiveord, pchrbancoord,pchrtpoctaord,
					  vchrpNumCtaOrigenC,pchrnomord,vchrnumseriecert)
            INTO wvchrcodretcodi;
		RETURN vcodret, vcodretRev;
	ELSE
	    IF vFechaProcesoDe IS NULL OR vFechaProcesoDe = ''THEN
			LET vcodret = '00011';			LET wvchrcode = '17';
			LET vtimestamp    = dbinfo('utc_current') * 1000;
			LET wtimestamp    = vtimestamp;
			EXECUTE PROCEDURE bdispei:spei_recerrorescodi(wvchrcode, 'D','b',pchridmjc,pchrfchmjc,pchrconcepto,pMonto,wtimestamp,
						  vvchrcveras,pReferenciaBe,pchraliasben,pchrdivebenf,pchrbancobenf,pchrtpoctabenf,
						  vchrNumCtaDestinoA,pchrnombenf,pchraliasord,pchrdiveord, pchrbancoord,pchrtpoctaord,
						  vchrpNumCtaOrigenC,pchrnomord,vchrnumseriecert)
				INTO wvchrcodretcodi;
			RETURN vcodret, vcodretRev;		
		END IF;
	END IF;
	
	--//Validar que transaccion pertenece a esta devolucion
	IF pchrtipopago in('17') THEN
	   LET vTransCargo = '0545'; --- Por lo mientras sera esta transacciÃ³n hasta que las den de alta pruebas
	ELIF  pchrtipopago = ('18') THEN
	   LET vTransCargo = '0545'; --- Por lo mientras sera esta transacciÃ³n hasta que las den de alta pruebas
	END IF;
	
	
	IF vcodret = '00000'  THEN
        EXECUTE PROCEDURE bdicheq:cargo_ref(vchrEmpresa, vchrSucursal, pchrUsuario, vTransCargo, vchrTransSuc, pchrFolioSuc, pNumCtaOrigen,
                                            vintCheque, pMonto, vchrMoneda, cReferencia, vchrNumTarjetaOrigen, vchrUsuAutoriza) 
        INTO vcodret, vTrans, vFechaHoy, vSdoDisp, vMontoRet;

        IF vcodret <> '000' THEN
            LET vvchridtpa = '21'; --Transf no liquidada por problemas del participante ord
            IF vcodret IN ('962','100','777','404','200','614','400','300') THEN
				LET vcodret = '00004';
                LET wvchrcode = '17'; 
            END IF;
            
			IF vcodret = '549' THEN
			    LET vcodret ='00006';				LET wvchrcode = '17'; 
			END IF;
            --// ejecuta el sp spei_recerrorescodi para el aviso de procesamiento
            LET vtimestamp    = dbinfo('utc_current') * 1000;
            LET wtimestamp    = vtimestamp;

            EXECUTE PROCEDURE bdispei:spei_recerrorescodi(wvchrcode, 'D','b',pchridmjc,pchrfchmjc,pchrconcepto,pMonto,wtimestamp,
					  vvchrcveras,pReferenciaBe,pchraliasben,pchrdivebenf,pchrbancobenf,pchrtpoctabenf,
					  vchrNumCtaDestinoA,pchrnombenf,pchraliasord,pchrdiveord, pchrbancoord,pchrtpoctaord,
					  vchrpNumCtaOrigenC,pchrnomord,vchrnumseriecert)
            INTO wvchrcodretcodi;

            RETURN vcodret, vcodretRev;
        ELSE
            LET vPasoCargo = '1';
        END IF;

        EXECUTE PROCEDURE bdicheq:abono_ref(vchrEmpresa, vchrSucursal, pchrUsuario, vTransAbono, vchrTransSuc, pchrFolioSuc, pNumCtaDestino, vintDocto,
                                            vMontoTotal, vMontoFirme, vMontoSBC, vMontoRem, vintDiasRet, vchrMoneda, aReferencia, vchrNumTarjetaDestino, vchrUsuAutoriza) 
        INTO vcodret;

        IF vcodret <> '000' THEN
            EXECUTE PROCEDURE bdicheq:reversion(vchrEmpresa, vchrSucursal, pchrUsuario, pchrFolioSuc, 'A') 
            INTO vcodretRev;

            IF vcodretRev = '000' THEN
                LET vcodretRev = '001';
            END IF;

            LET vvchridtpa = '22'; --Transf no liquidada por problemas del participante benf
            
            IF vcodret in ('999','100','40034','200','375','374','301') THEN
				LET vcodret = '00005';
                LET wvchrcode = '17';
            ELSE
                IF vcodret in ('420','397','371','959','401') THEN
				    LET vcodret = '00005';
                    LET wvchrcode = '13';
                END IF;	
            END IF;	
            
            --// envia los campos para el aviso de procesamiento
            LET vtimestamp  = dbinfo('utc_current') * 1000;
            LET wtimestamp    = vtimestamp;

            EXECUTE PROCEDURE bdispei:spei_recerrorescodi(wvchrcode, 'D','o',pchridmjc,pchrfchmjc,pchrconcepto,pMonto,wtimestamp,
				      vvchrcveras,pReferenciaBe,pchraliasben,pchrdivebenf,pchrbancobenf,pchrtpoctabenf,
					  vchrNumCtaDestinoA,pchrnombenf,pchraliasord,pchrdiveord, pchrbancoord,pchrtpoctaord,
					  vchrpNumCtaOrigenC,pchrnomord,vchrnumseriecert)
            INTO wvchrcodretcodi;
            
            RETURN vcodret, vcodretRev;
        ELSE
            LET vPasoAbono = '1';
        END IF;
	ELSE
		LET vtimestamp  = dbinfo('utc_current') * 1000;
        LET wtimestamp    = vtimestamp;

        EXECUTE PROCEDURE bdispei:spei_recerrorescodi(wvchrcode,'D','o',pchridmjc,pchrfchmjc,pchrconcepto,pMonto,wtimestamp,
					  vvchrcveras,pReferenciaBe,pchraliasben,pchrdivebenf,pchrbancobenf,pchrtpoctabenf,
					  vchrNumCtaDestinoA,pchrnombenf,pchraliasord,pchrdiveord,pchrbancoord,pchrtpoctaord,
					  vchrpNumCtaOrigenC,pchrnomord,vchrnumseriecert)
        INTO wvchrcodretcodi;
        
		RETURN vcodret, vcodretRev;
	END IF;
  
    IF vPasoCargo = '1' AND vPasoAbono = '1' THEN
        LET vvchridtpa = '1';
        LET wvchrcode = '0';    
  
        LET vtimestamp  = dbinfo('utc_current') * 1000;
        LET wtimestamp    = vtimestamp;
        --//Para cargo
	    EXECUTE PROCEDURE bdispei:spei_recerrorescodi('61','D','b',pchridmjc,pchrfchmjc,pchrconcepto,pMonto,wtimestamp,
				      vvchrcveras,pReferenciaBe,pchraliasben,pchrdivebenf,pchrbancobenf,pchrtpoctabenf,
					  vchrNumCtaDestinoA,pchrnombenf,pchraliasord,pchrdiveord,pchrbancoord,pchrtpoctaord,
					  vchrpNumCtaOrigenC,pchrnomord,vchrnumseriecert) 
        INTO wvchrcodretcodi;
	    --//Para abono
        EXECUTE PROCEDURE bdispei:spei_recerrorescodi(wvchrcode,'D','b',pchridmjc,pchrfchmjc,pchrconcepto,pMonto,wtimestamp,
				      vvchrcveras,pReferenciaBe,pchraliasben,pchrdivebenf,pchrbancobenf,pchrtpoctabenf,
					  vchrNumCtaDestinoA,pchrnombenf,pchraliasord,pchrdiveord,pchrbancoord,pchrtpoctaord,
					  vchrpNumCtaOrigenC,pchrnomord,vchrnumseriecert) 
        INTO wvchrcodretcodi;



        --VALIDACION 61 1
        EXECUTE PROCEDURE bdispei:spei_recerrorescodi('61_1','D','b',pchridmjc,pchrfchmjc,pchrconcepto,pMonto,wtimestamp,
				      vvchrcveras,pReferenciaBe,pchraliasben,pchrdivebenf,pchrbancobenf,pchrtpoctabenf,
					  vchrNumCtaDestinoA,pchrnombenf,pchraliasord,pchrdiveord,pchrbancoord,pchrtpoctaord,
					  vchrpNumCtaOrigenC,pchrnomord,vchrnumseriecert) 
        INTO wvchrcodretcodi;
	--VALIDACION 61 1


    END IF;

END;
    
    RETURN vcodret, vcodretRev;

END PROCEDURE
DOCUMENT
'MODIFICADO POR: MARIO GONZALEZ VAZQUEZ',
'FECHA DE MODIFICACION: 27 ENERO 2026 LIBERACION',
'OBJETIVO: GENERAR FIRMA EN MENSAJES DE COBRO 61 1',
'CoDi(R)',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".auditor(pempresa char(3))
       returning char(5);

   DEFINE vc_tipo_cuenta char(1);
   DEFINE vsqlerr     integer;
   DEFINE vcodret     VARCHAR(5);
   DEFINE vcodretg    VARCHAR(5);
   DEFINE vempresa    char(3);
   DEFINE vccmayor    VARCHAR(10);
   DEFINE vccsub      VARCHAR(10);
   DEFINE vccsubsub   VARCHAR(10);
   DEFINE vccssubsub  VARCHAR(10);
   DEFINE vccsssubsub VARCHAR(10);
   DEFINE vsector     VARCHAR(10);
   DEFINE vauxiliar   VARCHAR(9);
   DEFINE vproducto   VARCHAR(4);
   DEFINE vtransacc   VARCHAR(4);
   DEFINE vmonto_tot  money(14,2);
   DEFINE vexiste     char(1);
   DEFINE vcomienza1  SMALLINT;
   DEFINE ven_transacc1 SMALLINT;
   DEFINE vconta        INTEGER;
   
   LET vcomienza1 	  = -1;
   LET ven_transacc1  = 0;
   LET vconta         = 0;
   LET vcodretg = "000";


begin
   
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodretg = vsqlerr;
         return vcodretg;
      end if;
   end exception;

	--Se cambia por un Truncate, ya que el filtro hace borrado de todos los registros.
   /*delete {+INDEX(sc_auditerr idx_auditerr1)} from sc_auditerr
      where empresa = pempresa;*/
	  	
	Truncate table bdicheq:sc_auditerr;
	
   /*foreach --Exiten 13994770
	  --Se quita Directiva
      --select {+INDEX(aux_auditerr idx_aux_auditerr)} 
	  select empresa,mayor,sub,subsub,ssubsub,
	     sssubsub,sector,auxiliar,producto,transacc,
		 sum(monto_tot)
        into vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,vsector,vauxiliar,vproducto,vtransacc,vmonto_tot
         from bdicheq:aux_auditerr
         where empresa = pempresa
         group by 1,2,3,4,5,6,7,8,9,10
         order by 1,2,3,4,5,6,7,8,9,10

      -- Valida la cuenta contable contra el catalogo contable
      select tipo_cuenta 
	     into vc_tipo_cuenta
         from bdinteg:si_catalog
         where empresa    = vempresa     and
               ccmayor    = vccmayor     and
	           ccsub      = vccsub       and
	           ccsubsub   = vccsubsub    and
	           ccssubsub  = vccssubsub   and
	           ccsssubsub = vccsssubsub  and
	           sector     = vsector;
      if vc_tipo_cuenta is null then
         let vcodretg = "964";
	     let vcodret  = "601";
         insert into sc_auditerr
            values(vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,
               vsector,vauxiliar,vproducto,vtransacc,vcodret,vmonto_tot);
         continue foreach;
      end if
      -- Valida la cuenta no sea de Encabezado o Totalizador
      if vc_tipo_cuenta = "E" or vc_tipo_cuenta = "T" then
         let vcodretg = "964";
	 let vcodret  = "602";
         insert into sc_auditerr
            values(vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,
               vsector,vauxiliar,vproducto,vtransacc,vcodret,vmonto_tot);
         continue foreach;
      end if
      -- Valida el numero de auxiliar
      if vc_tipo_cuenta = "A" then  -- and vauxiliar > "0" then
         select 1 into vexiste
            from bdicont:co_auxiliar
            where empresa = pempresa and numero   = vauxiliar;
         if vexiste is null then
            let vcodretg = "964";
	    let vcodret  = "603";
            insert into sc_auditerr
               values(vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,
                  vsector,vauxiliar,vproducto,vtransacc,vcodret,vmonto_tot);
            continue foreach;
         end if
      end if
   end foreach;*/
   
	--Exiten 13,994,770 de registros
	--Se genera FOREACH con 'Commits'
    FOREACH cursor_auditor WITH HOLD FOR
	  --Se quita Directiva
	  --select {+INDEX(aux_auditerr idx_aux_auditerr)} 
	  select empresa,mayor,sub,subsub,ssubsub,
		 sssubsub,sector,auxiliar,producto,transacc,
		 sum(monto_tot)
		 into vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,
		 vccsssubsub,vsector,vauxiliar,vproducto,vtransacc,
		 vmonto_tot
		 from bdicheq:aux_auditerr
		 where empresa = pempresa
		 group by 1,2,3,4,5,6,7,8,9,10
		 order by 1,2,3,4,5,6,7,8,9,10

	  -- Valida la cuenta contable contra el catalogo contable
	  select tipo_cuenta 
		 into vc_tipo_cuenta
		 from bdinteg:si_catalog
		 where empresa    = vempresa     and
			   ccmayor    = vccmayor     and
			   ccsub      = vccsub       and
			   ccsubsub   = vccsubsub    and
			   ccssubsub  = vccssubsub   and
			   ccsssubsub = vccsssubsub  and
			   sector     = vsector;
			   
			   
	  -- Abre la transaccion
	   IF (vcomienza1 = -1) THEN
		  LET vcomienza1 = 0;
		  LET ven_transacc1 = 1;
		  BEGIN WORK;
	   END IF;
			   
	  if vc_tipo_cuenta is null then
		 let vcodretg = "964";
		 let vcodret  = "601";
		 insert into sc_auditerr
			values(vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,
			   vsector,vauxiliar,vproducto,vtransacc,vcodret,vmonto_tot);
		 continue foreach;
	  end if
	  -- Valida la cuenta no sea de Encabezado o Totalizador
	  if vc_tipo_cuenta = "E" or vc_tipo_cuenta = "T" then
		 let vcodretg = "964";
	 let vcodret  = "602";
		 insert into bdicheq:sc_auditerr
			values(vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,
			   vsector,vauxiliar,vproducto,vtransacc,vcodret,vmonto_tot);
		 continue foreach;
	  end if
	  -- Valida el numero de auxiliar
	  if vc_tipo_cuenta = "A" then  -- and vauxiliar > "0" then
		 select 1 into vexiste
			from bdicont:co_auxiliar
			where empresa = pempresa and numero   = vauxiliar;
		 if vexiste is null then
			let vcodretg = "964";
		let vcodret  = "603";
			insert into bdicheq:sc_auditerr
			   values(vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,
				  vsector,vauxiliar,vproducto,vtransacc,vcodret,vmonto_tot);
			continue foreach;
		 end if
	  end if
	  
	  LET vconta = vconta + 1;

	   --Commit cada 10000 registros
	   IF (vconta >= 10000) THEN
		  LET vconta = 0;
		  COMMIT WORK;
		  BEGIN WORK;
	   END IF;
	  
    END FOREACH;
   
	   IF (ven_transacc1 = 1) THEN
		  LET ven_transacc1 = 0;
		  COMMIT WORK;
	   END IF;
   
   
   return vcodretg;
end
end procedure;