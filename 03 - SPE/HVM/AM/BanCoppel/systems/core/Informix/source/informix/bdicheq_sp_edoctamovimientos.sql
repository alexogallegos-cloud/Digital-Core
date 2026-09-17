CREATE PROCEDURE "informix".sp_edoctamovimientos(pEmpresa CHAR(3), 
                                                 pCuenta CHAR(20), 
                                                 pFechaInicial DATE, 
                                                 pFechaFinal DATE, 
                                                 pRegistro INTEGER,
                                                 pUsuario char(10), 
                                                 pOrigen CHAR(1) )

RETURNING CHAR(5), CHAR(10), CHAR(40), CHAR(50), 
          MONEY(14, 2), MONEY(14, 2), MONEY(14, 2),CHAR(50);

    DEFINE vCodRet          CHAR(5);
    DEFINE cProducto        CHAR(4);
    DEFINE cNaturaleza      CHAR(1);
    DEFINE cNumTarjeta      CHAR(16);
    DEFINE cReferencia      CHAR(40);
    DEFINE cDescripcion     CHAR(50);
    DEFINE cSucursal        CHAR(50);
    DEFINE dFechaMov        CHAR(10);
    DEFINE cFech_param      CHAR(10);
    DEFINE cFech_param_ini  CHAR(10);
    DEFINE vCiclo           SMALLINT;
    DEFINE vSqlErr          INTEGER;
    DEFINE vIsamErr         INTEGER; 
    DEFINE iAux             INTEGER;
    DEFINE dFechaMov1       DATE;
    DEFINE mRetiro          MONEY(18, 2);
    DEFINE mDeposito        MONEY(18, 2);
    DEFINE mSaldo           MONEY(18, 2);
    DEFINE mMonto           MONEY(18, 2);
    DEFINE cTransacc        CHAR(4);
    DEFINE cConcepto        CHAR(40);
    DEFINE cReferen         CHAR(40);
    
    LET vCodRet      = "000";
    LET dFechaMov    = "";
    LET creferencia  = "";
    LET cDescripcion = "";
    LET mRetiro      = 0;
    LET mDeposito    = 0;
    LET mSaldo       = 0;
    LET vCiclo       = 0;
    LET cSucursal    = "";
    LET dFechaMov1   = "";
    LET pCuenta      = TRIM(pCuenta);
    LET cProducto    = '';
    LET cTransacc    = '';
    LET cConcepto    = '';
    LET cReferen     = '';

    BEGIN
    
    ON EXCEPTION SET vSqlErr, vIsamErr
        IF vSqlErr != 0 THEN
            LET vCodRet = vSqlErr;

            RETURN vCodRet, dFechaMov, cReferencia, cDescripcion, mRetiro,
            mDeposito, mSaldo,cSucursal;
        END IF;
    END EXCEPTION;

    --- Set Debug File To '/tmp/sp_edoctamovimientos.out';
    --- Trace On;

    -- // ORIGEN  1 CENTRAL, 2 SUCURSAL, 3 BANCA POR INTERNET

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 2;
    
    SELECT valor
      INTO cFech_param
      FROM bdicheq:sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'fechcon_movhis';
       
    SELECT valor
      INTO cFech_param_ini
      FROM bdicheq:sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'FechIniCon_movhis_ol';

    IF pOrigen = '1' THEN
        -- // Obtengo el Numero de producto
        SELECT producto 
          into cProducto
          FROM sc_maechq
         WHERE empresa = '001'
           AND cuenta = pCuenta;

        -- // Limpio tabla para reg. nuevos
        DELETE FROM vedoctamov
         WHERE cod_usuario= pUsuario;
    END IF;
    
    -- // Se obtienen los movimientos de las tablas sc_movdia, sc_movhis y sc_movhis_old
    FOREACH
        SELECT mm.num_serial, mm.fech_alt, mm.transacc, TRIM(tr.descripcion) AS descripcion, 
               NVL(replace(mm.referencia,"'"," "), '') AS referencia, NVL(mm.referencia, '') AS referen,
               NVL(mm.num_tarjeta, '') AS num_tarjeta, mm.monto_tot, tr.naturaleza, mm.sdo_cuenta,
               CASE WHEN tr.numero in (0202,0223) THEN mm.sucursal||' - '||NVL(TRIM(su.nombre),'')||' - '||SUBSTR(fech_hor,1,8) ELSE '' END AS Sucursal
          INTO iAux, dFechaMov1, cTransacc,
               cDescripcion, 
               cReferencia, cReferen,
               cNumTarjeta, 
               mMonto, cNaturaleza, mSaldo, 
               cSucursal
          FROM bdicheq:sc_movdia AS mm,
               bdinteg:si_transacc AS tr,
         Outer bdinteg:si_sucursales  su
         WHERE mm.empresa = pEmpresa 
           AND mm.cuenta = pCuenta 
           AND mm.fech_alt BETWEEN pFechaInicial AND pFechaFinal 
           AND mm.cancelad <> "S"
		   AND mm.transacc = tr.numero
           AND tr.sistema = '01'		   
           AND tr.empresa = mm.empresa 
           AND tr.numero = mm.transacc
           AND tr.se_emite_edocta = "S" 
           AND su.sucursal = mm.sucursal 
           AND su.empresa = tr.empresa
        UNION ALL
        SELECT {+INDEX(bdicheq:sc_movhis idx_movhisnew4)}
               mm.num_serial, mm.fech_alt, mm.transacc, TRIM(tr.descripcion) AS descripcion, 
               NVL(replace(mm.referencia,"'"," "), '') AS referencia, NVL(mm.referencia, '') AS referen,
               NVL(mm.num_tarjeta, '') AS num_tarjeta, mm.monto_tot, tr.naturaleza, mm.sdo_cuenta,
               CASE WHEN tr.numero in (0202,0223) THEN mm.sucursal||' - '||NVL(TRIM(su.nombre),'')||' - '||SUBSTR(fech_hor,1,8) ELSE '' END AS Sucursal
          FROM bdicheq:sc_movhis AS mm,
               bdinteg:si_transacc AS tr,
         Outer bdinteg:si_sucursales  su
         WHERE mm.empresa = pEmpresa 
           AND mm.cuenta = pCuenta 
           AND mm.fech_alt BETWEEN pFechaInicial AND pFechaFinal 
           AND mm.fech_alt >= cFech_param
           AND mm.cancelad <> "S" 
           AND mm.transacc = tr.numero
           AND tr.sistema = '01'			   
           AND tr.empresa = mm.empresa 
           AND tr.numero = mm.transacc
           AND tr.se_emite_edocta = "S" 
           AND su.sucursal = mm.sucursal 
           AND su.empresa = tr.empresa
        UNION ALL
        SELECT {+INDEX(bdicheq:sc_movhis_old movhis1)}
               mm.num_serial, mm.fech_alt, mm.transacc, TRIM(tr.descripcion) AS descripcion, 
               NVL(replace(mm.referencia,"'"," "), '') AS referencia, NVL(mm.referencia, '') AS referen,
               NVL(mm.num_tarjeta, '') AS num_tarjeta, mm.monto_tot, tr.naturaleza, mm.sdo_cuenta,
               CASE WHEN tr.numero in (0202,0223) THEN mm.sucursal||' - '||NVL(TRIM(su.nombre),'')||' - '||SUBSTR(fech_hor,1,8) ELSE '' END AS Sucursal
          FROM bdicheq:sc_movhis_old AS mm,
               bdinteg:si_transacc AS tr,
         Outer bdinteg:si_sucursales  su
         WHERE mm.empresa = pEmpresa 
           AND mm.cuenta = pCuenta 
           AND mm.fech_alt BETWEEN pFechaInicial AND pFechaFinal 
           AND mm.fech_alt >= cFech_param_ini
           AND mm.fech_alt < cFech_param 
           AND mm.cancelad <> "S" 
           AND mm.transacc = tr.numero
           AND tr.sistema = '01'			   
           AND tr.empresa = mm.empresa 
           AND tr.numero = mm.transacc 
           AND tr.se_emite_edocta = "S" 
           AND su.sucursal = mm.sucursal 
           AND su.empresa = tr.empresa
         ORDER BY mm.fech_alt DESC, mm.num_serial DESC
         
        IF cTransacc = '0273' THEN
			SELECT vchrconceptopago
			  INTO cConcepto
			  FROM bdispei:tblhistpago
			 WHERE vchrclaverastreo = cReferen
			   AND dtfechavalor = dFechaMov1
			   AND intcvetipopago <> 0;
               
            IF cConcepto is null OR cConcepto = '' THEN
                LET cDescripcion = TRIM(cDescripcion);
            ELSE
                LET cDescripcion = TRIM(cDescripcion) ||' '|| TRIM(cConcepto);
            END IF;
		END IF;

	    IF cTransacc = '0274' THEN
            IF SUBSTR(cReferen,1, 9) = 'BANCOPPEL' THEN
                SELECT vchrconceptopago
                  INTO cConcepto
                  FROM bdispei:tblhistpago
                 WHERE vchrclaverastreo = cReferen
                   AND dtfechavalor = dFechaMov1
                   AND intcvetipopago <> 0;
            ELSE
                SELECT vchrconceptopago2
                  INTO cConcepto
                  FROM bdispei:tblhistpago
                 WHERE vchrclaverastreo = cReferen
                   AND dtfechavalor = dFechaMov1
                   AND intcvetipopago <> 0;
            END IF;
            
            IF cConcepto is null OR cConcepto = '' THEN
                LET cDescripcion = TRIM(cDescripcion);
            ELSE
                LET cDescripcion = TRIM(cDescripcion) ||' '|| TRIM(cConcepto);
            END IF;
		END IF;

        LET mRetiro = 0;
        LET mDeposito = 0;
        
        -- // Valida si es un Cargo
        IF cNaturaleza = 'C' THEN
            LET mRetiro = mMonto;
        END IF;
        
        -- // Valida si es un abono
        IF cNaturaleza = 'A' OR cNaturaleza = 'R' THEN
            LET mDeposito = mMonto;
        END IF;

        LET vCiclo = vCiclo + 1;

        -- // PAGINACION
        IF vciclo <= pRegistro THEN
            CONTINUE FOREACH;
        END IF;

        LET dfechamov = SUBSTR(dFechaMov1, 7, 10) || "/" ||SUBSTR(dFechaMov1, 1, 2) || "/" ||SUBSTR(dFechaMov1, 4, 5);

        -- // Valida si el procedimiento fue mandado llamar por central
        IF pOrigen = '1' THEN   
            -- // Valida que el producto es cuenta eje empresarial (cuenta coppel) 
            -- // para no mostrar la informacion en pantalla, envia directamente a reporte
            IF cProducto = '1600' then  
                INSERT INTO vedoctamov 
                (empresa, cod_usuario, secuencia, cuenta, fechamov, referencia, descripcion, retiro, deposito,
                 saldo, generico_1, generico_2, generico_3, generico_4, generico_5, generico_6)
                VALUES 
                ('001', pUsuario, vCiclo, pCuenta, dFechaMov1, '', '', mRetiro, mDeposito,
                 mSaldo, cDescripcion, cReferencia, '', '', '', '');
            -- // De no ser el producto 1600 regresa informacion.
            ELSE 
                RETURN TRIM(vCodRet), dFechaMov, cReferencia, cDescripcion, mRetiro, mDeposito, mSaldo, cSucursal WITH RESUME;
            END IF;
        ELSE
            RETURN TRIM(vCodRet), dFechaMov, cReferencia, cDescripcion, mRetiro, mDeposito, mSaldo, cSucursal WITH RESUME;
        END IF;

    END FOREACH;
    
    -- // Si el procedimiento llamado por central al ultimo registro le asignara un codigo de retorno 100 como indicador.
    IF pOrigen = '1' THEN     
        LET vCodRet = '100';
        RETURN vCodRet, dFechaMov, cReferencia, cDescripcion, mRetiro, mDeposito, mSaldo, cSucursal WITH RESUME;
    END IF;
    
    END;
    
END PROCEDURE

DOCUMENT
'CAPTACION',
'MODIFICÓ: ABIGAIL VASAVILBAZO CAÑEDO',
'DESCRIPCIÓN: SE UNIFICAN LOS PROCEDIMIENTOS DE GENERACION DE MOVTOS DE EDO DE CTA DE SUCURSAL, CENTRAL Y BPI',
'FECHA: 23/11/09',
'VERSION: 20091130.1109',
'Modificó: Diego Guerra Atienzo',
'Descripción: Se realiza modificación para eliminar los apostrofes en las referencias de los movimientos',
'Fecha: 30/08/11';

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