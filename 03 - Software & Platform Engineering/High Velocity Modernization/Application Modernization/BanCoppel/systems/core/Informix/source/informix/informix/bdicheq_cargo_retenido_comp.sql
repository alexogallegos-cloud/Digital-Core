CREATE PROCEDURE "informix".cargo_retenido_comp(pempresa char(3))
RETURNING CHAR(5), INTEGER;

    DEFINE vcodret          CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(50);
    DEFINE vfecha           DATE;
    DEFINE vhora            CHAR(15);
    DEFINE vsql             CHAR(200);
    DEFINE vfolio           CHAR(20);
    DEFINE vcuenta          CHAR(20);
    DEFINE vstatus          CHAR(1);
    DEFINE vimporte         MONEY(14,2);
    DEFINE vimport          MONEY(14,2);
    DEFINE vdisp            MONEY(14,2);
    DEFINE vsucursal        CHAR(4);
    DEFINE vtransacc        CHAR(4);
    DEFINE vfecha_cargo     DATE;
    DEFINE vdispo           MONEY(14,2);
    DEFINE vcargo           MONEY(14,2);
    DEFINE vdescripcion     CHAR(40);
    DEFINE vexiste          INTEGER;
    DEFINE nComit           INTEGER;
    DEFINE vcontador        INTEGER;
    DEFINE vfechades        CHAR(10);
    DEFINE vfechadescarga   CHAR(6);
    DEFINE vdia             CHAR(2);
    DEFINE vmes             CHAR(2);
    DEFINE vanio            CHAR(2);
    DEFINE vnombre          VARCHAR(40);
    DEFINE vcargado         MONEY(14,2);
    DEFINE whora1           CHAR(5);
    DEFINE whora2           CHAR(2);
    DEFINE whora3           CHAR(2);
    DEFINE whora            CHAR(4);
    DEFINE vnumcte          CHAR(20);
    DEFINE vctacte          CHAR(20);
    DEFINE vsuc_cta         CHAR(4);
    DEFINE vexiste_cta      CHAR(1);
    DEFINE vaceptab         CHAR(1);
    DEFINE vacepcargo       CHAR(1);
    DEFINE vimporte_cargo   MONEY(14,2);
    DEFINE vcargados        MONEY(14,2);
    DEFINE vdisponible      MONEY(14,2);
    DEFINE vcargo_cta       MONEY(14,2);
    DEFINE vfecha_oper      DATE;
    DEFINE vbloqueada       SMALLINT;
	--RQM 09 704.Se definen las variables requeridas para la consulta del saldo disponible.DHG
	DEFINE mSdoActual		MONEY(14,2); --Monto del saldo actual de la cuenta.
	DEFINE mSdoRetenido     MONEY(14,2); --Monto del saldo retenido de la cuenta.
	DEFINE mSdoCong	        MONEY(14,2); --Monto del saldo congelado de la cuenta.
	DEFINE mSaldoSBC        MONEY(14,2); --Monto del saldo inmovilizado (salvo buen cobro) de la cuenta.
	DEFINE cCodRetConsSdo		CHAR(5); --Codigo de retorno de SP de consulta de saldo.
	DEFINE cMensajeRetConsSdo 	CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
    
    LET vcodret = "000";
    LET vcodret2 = "";
    LET vcodret3 = '';
    LET sql_err = 0;
    LET isam_err = 0;
    LET desc_err = '';
    LET vfecha = '';
    LET vhora = '';
    LET vsql = '';
    LET vfolio = '';
    LET vcuenta = '';
    LET vstatus = '';
    LET vimporte = 0.00;
    LET vimport = 0.00;
    LET vdisp = 0.00;
    LET vsucursal = '';
    LET vtransacc = '';
    LET vfecha_cargo = '';
    LET vdispo = 0.00;
    LET vcargo = 0.00;
    LET vdescripcion = '';
    LET vexiste = 0;
    LET nComit = 0;
    LET vcontador = 0;
    LET vfechades = '';
    LET vfechadescarga = '';
    LET vdia = '';
    LET vmes = '';
    LET vanio = '';
    LET vnombre = '';
    LET vcargado = 0.00;
    LET whora1 = '';
    LET whora2 = '';
    LET whora3 = '';
    LET whora = '';
    LET vnumcte = '';
    LET vctacte = '';
    LET vsuc_cta = '';
    LET vexiste_cta = '';
    LET vaceptab = '';
    LET vacepcargo = '';
    LET vimporte_cargo = 0.00;
    LET vcargados = 0.00;
    LET vdisponible = 0.00;
    LET vcargo_cta = 0.00;
    LET vfecha_oper = '';
    LET vbloqueada = 0;
	--RQM 09 704. Se inicializan las variables para el llamado y retorno de consulta de saldo. DHG.
	LET mSdoActual			=0.00;	
	LET mSdoRetenido		=0.00;
	LET mSdoCong			=0.00;
	LET mSaldoSBC   		=0.00;
	LET cCodRetConsSdo		= '00000';
	LET cMensajeRetConsSdo	= '';

    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/cargo_retenido_comp.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF nComit = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret, vcontador;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/cargo_retenido_comp.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    SELECT fecha_hoy
      INTO vfecha
      FROM sc_fechas
     WHERE empresa = pempresa;

    LET vhora  = CURRENT HOUR TO FRACTION;
    LET vfolio = "informix"||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];
    
    TRUNCATE TABLE cargos;

    FOREACH WITH HOLD
        SELECT cuenta, importe, descripcion, fecha
          INTO vcuenta, vimporte, vdescripcion, vfecha_oper
          FROM cuentas
          
        BEGIN WORK;
        LET nComit = 1;

        --RQM 09 704.Se agregan las variables de saldo a la consulta para realizar posteriormente el calculo de saldo disponible.DHG
		SELECT sdo_actual,sdo_cong,sdo_retenido,saldo_sbc, sucursal, status_cta, num_cte
          INTO mSdoActual,mSdoCong,mSdoRetenido,mSaldoSBC, vsucursal, vstatus, vnumcte
          FROM sc_maechq
         WHERE cuenta = vcuenta;
         
		--RQM 09 704.Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion.DHG
		EXECUTE PROCEDURE bdicheq:sp_cons_sdodisp_x_tpcalculo('',mSdoActual,mSdoRetenido,mSdoCong,mSaldoSBC,0.00,0.00,0.00,'F',2) INTO cCodRetConsSdo,cMensajeRetConsSdo,vdisp;        
		
		 
        LET vbloqueada = 0;
           
        IF vdisp > 0.00 THEN
            IF vstatus = 3 THEN
                UPDATE sc_maechq
                   SET status_cta = "1",
                       motivo = "00"
                 WHERE cuenta = vcuenta;

                SELECT COUNT(*)
                  INTO vexiste
                  FROM sc_ctabloqueo
                 WHERE cuenta = vcuenta;

                IF vexiste <> 0 THEN
                    DELETE FROM sc_ctabloqueo
                     WHERE cuenta = vcuenta;
                END IF

                SELECT COUNT(*)
                  INTO vexiste
                  FROM sc_histbloq
                 WHERE cuenta = vcuenta
                   AND status_blo = "B"
                   AND tipo_mov = "B"
                   AND empresa = pempresa;

                IF vexiste <> 0 THEN
                    INSERT INTO sc_histbloq VALUES(pempresa, vcuenta, "D", "00", " ", 0.00, "informix", vfecha, current hour to fraction, "1111", "D", vfolio, " ", '', '', '', '');
                END IF
                
                LET vbloqueada = 0;
            END IF

            IF vdisp >= vimporte THEN
                CALL cargo_ref(pempresa, vsucursal, "informix", "0252", "0252", vfolio, vcuenta, 0, vimporte, "01", vdescripcion, '', "informix")
                RETURNING vcodret, vtransacc, vfecha_cargo, vdispo, vcargo;

                IF vcodret = "000" THEN
                    LET vcargo = vcargo;
                    LET vbloqueada = 0;
                ELSE
                    LET vcargo = 0;
                    
                    UPDATE sc_maechq
                       SET status_cta = "3",
                           motivo = "09"
                     WHERE cuenta = vcuenta;

                    SELECT COUNT(*)
                      INTO vexiste
                      FROM sc_ctabloqueo
                     WHERE cuenta = vcuenta;

                    IF vexiste = 0 THEN
                        INSERT INTO sc_ctabloqueo VALUES(vcuenta, "09", "3", '', '', '', '');
                    ELSE
                        UPDATE sc_ctabloqueo
                           SET clave = "09",
                               opcion = "3"
                         WHERE cuenta = vcuenta;
                    END IF

                    INSERT INTO sc_ctabloqueohist VALUES (vcuenta, "09", "3");
                    INSERT INTO sc_histbloq VALUES(pempresa,vcuenta,"B","09",3,0.00,"informix",vfecha,current hour to fraction,"1111","B",vfolio," ", '', '', '', '');
                    
                    LET vbloqueada = 1;
                END IF

                INSERT INTO cargos VALUES(vcuenta, vimporte, vcargo, vdescripcion, 'X', vfecha_oper);
            ELSE
                LET vimport = vdisp;

                CALL cargo_ref(pempresa, vsucursal, "informix", "0252", "0252", vfolio, vcuenta, 0, vimport, "01", vdescripcion, '', "informix")
                RETURNING vcodret, vtransacc, vfecha_cargo, vdispo, vcargo;

                IF vcodret = "000" THEN
                    LET vcargo = vcargo;
                ELSE
                    LET vcargo = 0;
                END IF
                
                UPDATE sc_maechq
                   SET status_cta = "3",
                       motivo = "09"
                 WHERE cuenta = vcuenta;

                SELECT COUNT(*)
                  INTO vexiste
                  FROM sc_ctabloqueo
                 WHERE cuenta = vcuenta;

                IF vexiste = 0 THEN
                    INSERT INTO sc_ctabloqueo VALUES(vcuenta, "09", "3", '', '', '', '');
                ELSE 
                    UPDATE sc_ctabloqueo
                       SET clave = "09",
                           opcion = "3"
                     WHERE cuenta = vcuenta;
                END IF

                INSERT INTO sc_ctabloqueohist VALUES (vcuenta, "09", "3");
                INSERT INTO sc_histbloq VALUES(pempresa,vcuenta,"B","09",3,0.00,"informix",vfecha, current hour to fraction,"1111","B",vfolio," ", '', '', '', '');
                
                INSERT INTO cargos VALUES(vcuenta, vimporte, vcargo, vdescripcion, 'X', vfecha_oper);
                
                LET vbloqueada = 1;
            END IF
        ELSE
            LET vcargo = 0;
            
            IF vstatus <> 3 THEN
                UPDATE sc_maechq
                   SET status_cta = "3",
                       motivo = "09"
                 WHERE cuenta = vcuenta;

                SELECT COUNT(*)
                  INTO vexiste
                  FROM sc_ctabloqueo
                 WHERE cuenta = vcuenta;

                IF vexiste = 0 THEN
                    INSERT INTO sc_ctabloqueo VALUES (vcuenta, "09", "3", '', '', '', '');
                ELSE 
                    UPDATE sc_ctabloqueo
                       SET clave = "09",
                           opcion = "3"
                     WHERE cuenta = vcuenta;
                END IF

                INSERT INTO sc_ctabloqueohist VALUES (vcuenta, "09", "3");
                INSERT INTO sc_histbloq VALUES(pempresa,vcuenta,"B","09",3,0.00,"informix",vfecha, current hour to fraction,"1111","B",vfolio," ", '', '', '', '');
            END IF
            
            INSERT INTO cargos VALUES(vcuenta,vimporte,vcargo,vdescripcion, 'X', vfecha_oper);
            
            LET vbloqueada = 1;
        END IF;
        
        -- // CARGO A CUENTAS RELACIONADAS DEL CLIENTE
        IF vimporte > vcargo THEN
            LET vimporte_cargo = vimporte - vcargo;
            
            FOREACH WITH HOLD
                --RQM 09 704.Se agregan las variables de saldo a la consulta para realizar posteriormente el calculo de saldo disponible.DHG
				SELECT cuenta, sucursal, sdo_actual,sdo_cong,sdo_retenido,saldo_sbc
                  INTO vctacte, vsuc_cta, mSdoActual,mSdoCong,mSdoRetenido,mSaldoSBC
                  FROM sc_maechq
                 WHERE num_cte = vnumcte
                   AND cuenta <> vcuenta
                   AND status_cta IN('1','4','5')
                   AND producto <> '1100'
                
				--RQM 09 704.Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion.DHG
				EXECUTE PROCEDURE bdicheq:sp_cons_sdodisp_x_tpcalculo('',mSdoActual,mSdoRetenido,mSdoCong,mSaldoSBC,0.00,0.00,0.00,'F',2) INTO cCodRetConsSdo,cMensajeRetConsSdo,vdisponible;        
		
				
                IF vdisponible > 0 THEN
                    IF vdisponible >= vimporte_cargo THEN
                        CALL cargo_ref(pempresa, vsuc_cta, "informix", "0252", "0252", vfolio, vctacte, 0, vimporte_cargo, "01", vdescripcion, '', "informix")
                        RETURNING vcodret, vtransacc, vfecha_cargo, vdispo, vcargo_cta;
                        
                        IF vcodret = '000' THEN
                            IF vimporte_cargo = vcargo_cta THEN
                                INSERT INTO cargos VALUES(vcuenta, vimporte_cargo, vcargo_cta, vdescripcion, vctacte, vfecha_oper);
                                
                                IF vbloqueada = 1 THEN
                                    UPDATE sc_maechq
                                       SET status_cta = '1',
                                           motivo = '00'
                                     WHERE cuenta = vcuenta;
                                     
                                    DELETE FROM sc_ctabloqueo
                                     WHERE cuenta = vcuenta;
                                     
                                    INSERT INTO sc_histbloq VALUES(pempresa, vcuenta, "D", "00", " ", 0.00, "informix", vfecha, current hour to fraction, "1111", "D", vfolio, " ", '', '', '', '');
                                END IF;                                 
                                
                                EXIT FOREACH;
                            ELIF vimporte_cargo > vcargo_cta THEN
                                INSERT INTO cargos VALUES(vcuenta, vimporte_cargo, vcargo_cta, vdescripcion, vctacte, vfecha_oper);
                                LET vimporte_cargo = vimporte_cargo - vcargo_cta;
                                CONTINUE FOREACH;
                            END IF
                        ELSE
                            CONTINUE FOREACH;
                        END IF
                    ELSE
                        CALL cargo_ref(pempresa, vsuc_cta, "informix", "0252", "0252", vfolio, vctacte, 0, vdisponible, "01", vdescripcion, '', "informix")
                        RETURNING vcodret, vtransacc, vfecha_cargo, vdispo, vcargo_cta;
                        
                        IF vcodret = '000' THEN
                            INSERT INTO cargos VALUES(vcuenta, vimporte_cargo, vcargo_cta, vdescripcion, vctacte, vfecha_oper);
                            LET vimporte_cargo = vimporte_cargo - vcargo_cta;
                            CONTINUE FOREACH;
                        ELSE
                            CONTINUE FOREACH;
                        END IF
                    END IF
                ELSE
                    CONTINUE FOREACH;
                END IF
            END FOREACH
        END IF
        
        LET vcontador = vcontador + 1;
        COMMIT WORK;
        LET nComit = 0;
    END FOREACH

    UPDATE STATISTICS MEDIUM FOR TABLE cuentas;
    UPDATE STATISTICS MEDIUM FOR TABLE cargos;

    LET whora1         = CURRENT HOUR TO MINUTE;
    LET whora2         = whora1[1,2];
    LET whora3         = whora1[4,5];
    LET whora          = whora2||whora3;
    LET vfechades      = TO_CHAR(vfecha, '%Y/%m/%d');
    LET vdia           = vfechades[9,10];
    LET vmes           = vfechades[6,7];
    LET vanio          = vfechades[3,4];
    LET vfechadescarga = vdia||vmes||vanio;
    LET vnombre        = 'aplicados_'||vfechadescarga||'_'||whora||'.txt';

    LET vsql = 'echo "UNLOAD TO /resplogifx/conciliachq/'||vnombre||' SELECT * FROM cargos" > /resplogifx/conciliachq/cargos.sql';
    SYSTEM vsql;
    
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/cargos.sql";
    SYSTEM vsql;
    
    TRUNCATE TABLE cuentas;
    
    FOREACH WITH HOLD
        SELECT cuenta, cargo, descripcion, fecha
          INTO vcuenta, vcargo, vdescripcion, vfecha_oper
          FROM cargos
         WHERE cuenta_rel = 'X'
        
        BEGIN WORK;
        
        SELECT SUM(cargado)
          INTO vcargado
          FROM cargos
         WHERE cuenta = vcuenta;
        
        LET vcargo = vcargo - vcargado;
          
        IF vcargo > 0 THEN
            INSERT INTO cuentas VALUES(vcuenta, vcargo, vdescripcion, vfecha_oper);
        END IF;
        
        COMMIT WORK;
    END FOREACH;

    END;

    RETURN vcodret, vcontador;

END PROCEDURE
DOCUMENT
'MODIFICO: Daniel Hernandez Garcia',
'FECHA: 19-08-2025',
'MODIFICACION: Se modifica la forma de calculo de saldo disponible para considerar un nuevo campo', 
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD: BDICHEQ',
'VERSION: 1.1';

CREATE PROCEDURE "informix".sp_cargoxcomision_pm()
RETURNING CHAR(6) AS cod_ret
    
	---DECLARACIONES
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE cCodRet			CHAR(6);

	DEFINE pNumcte			CHAR(20);
	DEFINE pCuenta			CHAR(20);
	DEFINE pProducto		CHAR(4);
	DEFINE pTransacc		CHAR(4);
	DEFINE dSdoPromMen		DECIMAL(18,2);
	DEFINE dMontoAplica		MONEY;
	DEFINE dMtoAplicComis	MONEY;
	DEFINE cAnioMesAnte		CHAR(6);
	DEFINE mValorSdoPos		MONEY;
	DEFINE mDisponible      MONEY(14,2);
	DEFINE cCodRetGF		CHAR(3);
	DEFINE cFolioGF			CHAR(16);
	DEFINE cCodRetCR		CHAR(5);
	DEFINE cComisionCR		CHAR(4);
	DEFINE mIva				MONEY(14,2);
	DEFINE dValIva			DECIMAL(9,6);
	DEFINE mMontoPen		MONEY(14,2);
	DEFINE mMtoCom			MONEY(14,2);
	DEFINE cTranCom         CHAR(4);
	DEFINE vTranIva         CHAR(4);
	DEFINE mSdoPromMM		MONEY;
	DEFINE mComCgoNoSMM		MONEY;
	DEFINE cTpoPersona		CHAR(1);
	DEFINE mComInacCta		MONEY;
	DEFINE dtFecUltDep		DATE;
	DEFINE dtFecUltRet		DATE;
	DEFINE dtFecUltMov		DATE;

	DEFINE iDifDias			INT8;
	DEFINE sBandCtaNva		SMALLINT;
	DEFINE sBandCargo		SMALLINT;
	DEFINE cDescTranRef		CHAR(40);
	DEFINE cDescIvaRef		CHAR(40);
	DEFINE sFecComision		DATE;
	DEFINE mAcumSdoPos		MONEY;
	DEFINE iDiaSdoPos		SMALLINT;
	DEFINE dtFechaHoy		DATE;
	DEFINE dtFechaAlta		DATE;
	DEFINE mServAnualidad	MONEY;
	DEFINE mServAnualPrimCta	MONEY;
    DEFINE dtConsMovhis 	DATE;
    DEFINE dtConsMovhisold 	DATE;
    DEFINE dtConsMovhisold2 DATE;
	DEFINE sBandDetcomis	SMALLINT;
	DEFINE cTranSdoprommm	CHAR(4);
	DEFINE cTranInaccta		CHAR(4);
	DEFINE cTrananuaserv	CHAR(4);
	DEFINE cCtaCargoInaccta	CHAR(20);
	DEFINE cPrimerCta		CHAR(20);
	DEFINE mSaldoCta		MONEY;
	DEFINE iNumCtas			SMALLINT;
	DEFINE cBandCtaValida	CHAR(1);
	DEFINE cBandPrimCtaValida	CHAR(1);
	DEFINE sFecComBit		DATE;
	DEFINE sBandComBit		SMALLINT;
	DEFINE cCodRetCS		CHAR(5);
	DEFINE cStaCtaCS		CHAR(1);
    DEFINE iTransacc        SMALLINT;
    --RQM 09 704.Se definen las variables requeridas para la consulta del saldo disponible.DHG
	DEFINE mSdoActual		MONEY(14,2); --Monto del saldo actual de la cuenta.
	DEFINE mSdoRetenido     MONEY(14,2); --Monto del saldo retenido de la cuenta.
	DEFINE mSdoCong	        MONEY(14,2); --Monto del saldo congelado de la cuenta.
	DEFINE mSaldoSBC        MONEY(14,2); --Monto del saldo inmovilizado (salvo buen cobro) de la cuenta.
	DEFINE cCodRetConsSdo		CHAR(5); --Codigo de retorno de SP de consulta de saldo.
	DEFINE cMensajeRetConsSdo 	CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
	
	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cCodRet             = "000000";

	LET pNumcte				= "";
	LET pCuenta				= "";
	LET pProducto			= "";
	LET pTransacc			= "";
	LET dSdoPromMen			= 0.0;
	LET dMontoAplica		= 0.0;
	let dMtoAplicComis		= 0.0;
	LET cAnioMesAnte		= "";
	LET mValorSdoPos		= 0.0;
	LET mDisponible  		= 0;
	LET cCodRetGF			= "000";
	LET cFolioGF			= "";
	LET cCodRetCR			= "000";
	LET cComisionCR			= "";
	LET	mIva				= 0.0;
	LET dValIva				= 0.0;
	LET mMontoPen			= 0.0;
	LET mMtoCom             = 0.0;
	LET cTranCom         	= "";
	LET vTranIva         	= 0.0;
	LET mSdoPromMM			= 0.0;
	LET mComCgoNoSMM		= 0.0;
	LET cTpoPersona			= "";
	LET mComInacCta			= 0.0;
	LET dtFecUltDep			= NULL;
	LET dtFecUltRet			= NULL;
	LET dtFecUltMov			= NULL;
	LET iDifDias			= 0;
	LET sBandCtaNva			= NULL;
	LET sBandCargo			= 0;
	LET cDescTranRef		= "";
	LET cDescIvaRef			= "";
	LET sFecComision		= NULL;
	LET mAcumSdoPos			= 0.0;
	LET iDiaSdoPos			= 0;
	LET dtFechaHoy			= DATE(1);
	LET dtFechaAlta			= DATE(1);
	LET mServAnualidad		= 0.0;
	LET mServAnualPrimCta	= 0.0;
    LET dtConsMovhis 		= DATE(1);
    LET dtConsMovhisold 	= DATE(1);
    LET dtConsMovhisold2 	= DATE(1);
	LET sBandDetcomis		= 0;
	LET cTranSdoprommm		= "";
	LET cTranInaccta		= "";
	LET cTrananuaserv		= "";
	LET cCtaCargoInaccta	= "";
	LET mSaldoCta			= 0.0;
	LET cPrimerCta			= "";
	LET iNumCtas			= 0;
	LET cBandCtaValida		= "0";
	LET cBandPrimCtaValida	= 0;
	LET sFecComBit			= DATE(1);
	LET sBandComBit			= 0;
	LET cCodRetCS			= "000";
	LET cStaCtaCS			= "";
    LET iTransacc           = 0;
	--RQM 09 704. Se inicializan las variables para el llamado y retorno de consulta de saldo. DHG.
	LET mSdoActual			=0.00;	
	LET mSdoRetenido		=0.00;
	LET mSdoCong			=0.00;
	LET mSaldoSBC   		=0.00;
	LET cCodRetConsSdo		= '00000';
	LET cMensajeRetConsSdo	= '';

    BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--- SET DEBUG FILE TO '/informix/moha/sp_cargoxcomision_pm.out';
	--- TRACE ON;
    
	SELECT fecha_hoy
	INTO dtFechaHoy
	FROM "informix".sc_fechas
	WHERE empresa = "001";
    
	SELECT TRIM(valor)
	INTO cTranSdoprommm
	FROM sc_param
	WHERE empresa = "001"
	AND codparam = 'transdoprommm';
    
	SELECT TRIM(valor)
	INTO cTranInaccta
	FROM sc_param
	WHERE empresa = "001"
	AND codparam = 'transinaccta1';
    
	SELECT TRIM(valor)
	INTO cTrananuaserv
	FROM sc_param
	WHERE empresa = "001"
	AND codparam = 'transanuserven';
    
	--// OBTIENE EL VALOR DEL PARAMETRO DEL IVA
	SELECT TRIM(valor)
	INTO dValIva
	FROM bdinteg:"informix".si_param
	WHERE empresa = "001"
	AND cod_param = 47;
    
	-- CICLO DE LAS TRANSACCIONES
	FOREACH
		SELECT TRIM(valor)
		INTO pTransacc
		FROM "informix".sc_param
		WHERE empresa = "001"
		AND codparam IN ("transdoprommm","transinaccta1","transanuserven")

		--// OBTIENE EL VALOR DE LA COMISION A COBRAR DE LA TABLA sc_comisiones
		SELECT monto_aplica, transacc_com, transacc_iva
		INTO dMtoAplicComis, cTranCom, vTranIva
		FROM "informix".sc_comisiones
		WHERE empresa = "001"
		AND comision = pTransacc;

		LET dMtoAplicComis = NVL(dMtoAplicComis,0);
        LET iTransacc = 0;

		--// CICLO PRINCIPAL DONDE BARRE TODAS LAS CUENTAS DE PERSONA MORAL
		FOREACH
			SELECT mae.cuenta, mae.producto, mae.num_cte, fecultdep, fecultret, pro.sdoprommen, noc.fecha_alta
			INTO pCuenta, pProducto, pNumcte, dtFecUltDep, dtFecUltRet, dSdoPromMen, dtFechaAlta
			FROM "informix".sc_producto pro, "informix".sc_maechq mae, "informix".sc_maenoc noc
			WHERE pro.empresa = "001"
			AND pro.producto = mae.producto
			AND pro.pago_interes = 'M'
			AND mae.empresa = pro.empresa
			AND mae.producto = pro.producto
			AND pro.producto IN ("1200","2200")
			AND mae.status_cta IN ("1","4","5")
			AND noc.empresa = mae.empresa
			AND noc.cuenta = mae.cuenta
            
            -- // VALIDA SI YA SE APLICO LA TRANSACCION DE COMISION
            SELECT COUNT(*)
              INTO iTransacc
              FROM sc_movdia
             WHERE cuenta = pCuenta
               AND transacc = pTransacc
               AND cancelad <> 'S';
               
            IF iTransacc > 0 THEN
                CONTINUE FOREACH;
            END IF;

			LET sBandCargo = 0;

			IF pTransacc = cTranSdoprommm THEN
				--//////////////////////////////////////////////////////////--
				--// COMISION / CARGO POR NO TENER SALDO PROMEDIO MINIMO MENSUAL
				LET mSdoPromMM = 0.0;
				LET mComCgoNoSMM = 0.0;
				LET mAcumSdoPos	= 0.0;
				LET iDiaSdoPos = 0;

				--// OBTIENE EL SALDO PROMEDIO MENSUAL Y LA COMISION EN LA TABLA MAESTRA DE LAS COMISIONES DE LA CUENTAS DE PERSONAS MORALES
				SELECT FIRST 1 sdo_prom_mm, com_cgo_no_smm
				INTO mSdoPromMM, mComCgoNoSMM
				FROM "informix".sc_maecomtasserv_pm
				WHERE num_cte = pNumcte
				AND cuenta = pCuenta;

				IF mSdoPromMM IS NOT NULL THEN
					LET dSdoPromMen = mSdoPromMM;
				ELSE
					LET mSdoPromMM = 0;

				END IF

				IF mComCgoNoSMM IS NOT NULL THEN
					LET dMontoAplica = mComCgoNoSMM;
				ELSE
					LET dMontoAplica = dMtoAplicComis;
				END IF

				IF dMontoAplica = 0 THEN
					LET sBandCargo = 0;
				ELSE
					-- OBTIENE EL AÃO Y EL MES ANTERIOR
					LET cAnioMesAnte = YEAR(dtFechaHoy - 1 units MONTH) || LPAD(MONTH(dtFechaHoy - 1 units MONTH),2,"0");
					
                    --// OBTIENE EL VALOR ACUMULADO Y EL DIA DEL SALDO POS DE LA CUENTA
					SELECT acum_sdo_pos, dia_sdo_pos
					INTO mAcumSdoPos, iDiaSdoPos
					FROM "informix".sc_maehis
					WHERE aniomes = cAnioMesAnte
					AND cuenta = pCuenta;

					LET mAcumSdoPos = NVL(mAcumSdoPos, 0);
					LET iDiaSdoPos = NVL(iDiaSdoPos, 0);

					IF iDiaSdoPos = 0 THEN
						LET mValorSdoPos = 0;
					ELSE
						LET mValorSdoPos = mAcumSdoPos / iDiaSdoPos;
					END IF

					--// VALIDA SI EL SALDO POS ES MENOR AL SALDO PROMEDIO DE LA sc_producto
					IF mValorSdoPos < dSdoPromMen THEN
						LET sBandCargo = 1;
						LET cDescTranRef = "COMISION X NO TENER SALDO PROMEDIO MENS";
						LET cDescIvaRef = "IVA COMISION X NO TENER SALDO PROM MENS";
					END IF
				END IF
			ELIF pTransacc = cTranInaccta THEN
				--//////////////////////////////////////////////////////////--
				--// COMISION/CARGO POR INACTIVIDAD DE LA CUENTA DURANTE 1 AÃO
				LET mComInacCta = 0;
				LET dtFecUltMov	= NULL;

				SELECT FIRST 1 com_ina_cta
				INTO mComInacCta
				FROM "informix".sc_maecomtasserv_pm
				WHERE num_cte = pNumcte
				AND cuenta = pCuenta;

				IF mComInacCta IS NOT NULL THEN
					LET dMontoAplica = mComInacCta;
				ELSE
					LET mComInacCta = 0;
					LET dMontoAplica = dMtoAplicComis;
				END IF

				IF dMontoAplica = 0 THEN
					LET sBandCargo = 0;
				ELSE
					-- VALIDA QUE LA CUENTA TENGA POR LO MENOS UN AÃO DE VIDA
					IF (dtFechaHoy - dtFechaAlta) > 360 THEN

						IF dtFecUltDep IS NULL AND dtFecUltRet IS NULL THEN
							LET sBandCargo = 1;
						ELSE
							IF dtFecUltDep IS NOT NULL THEN
								LET dtFecUltMov = dtFecUltDep;
							END IF

							IF dtFecUltRet IS NOT NULL THEN
								IF dtFecUltRet > dtFecUltMov THEN
									LET dtFecUltMov = dtFecUltRet;
								END IF
							END IF

							IF (dtFechaHoy - dtFecUltMov) < 361 THEN
								LET sBandCargo = 0;
							ELSE
								LET sBandCargo = 1;
								LET cDescTranRef = "COMISION X INACTIVIDAD DE LA CTA 1 AÃO";
								LET cDescIvaRef = "IVA COMISION X INACT DE LA CTA 1 AÃO";
							END IF
						END IF
					END IF
				END IF
			ELIF pTransacc = cTrananuaserv THEN
				--//////////////////////////////////////////////////////////--
				--// COMISION/CARGO POR ANUALIDAD DEL SERVICIO DE EMPRESANET
				LET iDifDias = 0;
				LET sBandCtaNva = NULL;
				LET iNumCtas = 0;
				LET cBandCtaValida = "0";
				LET sFecComBit = DATE(1);
				LET sBandComBit	= 0;
				LET cPrimerCta = "";
				LET mServAnualPrimCta = 0.0;
				LET mServAnualidad = 0.0;
				LET mSaldoCta = 0.0;
				LET cCtaCargoInaccta = "";

				--// OBTIENE EL NUMERO DE DIAS DE LA FECHA ACTUAL RESPECTO A SU FECHA DE REGISTRO
				SELECT FIRST 1 dtFechaHoy - f_registro
				INTO iDifDias
				FROM bdibei: "informix".bei_contratacion
				WHERE empresa = "001"
				AND num_cliente = pNumcte
				AND status_contrato = '30';

				IF iDifDias IS NULL THEN
					LET sBandCargo = 0;
				ELSE
					IF iDifDias > 31 AND iDifDias < 361 THEN
						LET sBandCargo = 0;
					ELSE
						IF iDifDias < 32 THEN
							LET sBandCtaNva = 1;
						ELSE
							LET sBandCtaNva = 0;
						END IF

						LET iNumCtas = 0;
						LET cBandCtaValida = "0";
						LET iDifDias = 0;

						SELECT FIRST 1 MAX(fecha_gencom)
						INTO sFecComBit
						FROM "informix".sc_bitacora_compm
						WHERE tpo_com = cTrananuaserv
						AND num_cte = pNumcte;

						LET sBandComBit = 0;

						IF sFecComBit IS NOT NULL THEN
							LET iDifDias = dtFechaHoy - sFecComBit;
							IF sBandCtaNva = 1 THEN
								LET sBandComBit = 1;
							ELIF sBandCtaNva = 0 THEN
								IF iDifDias < 361 THEN
									LET sBandComBit = 1;
								END IF
							END IF
						END IF

						IF sBandComBit = 0 THEN
							FOREACH
								SELECT cuenta
								INTO cPrimerCta
								FROM bdicheq:"informix".sc_maechq
								WHERE empresa = "001"
								AND num_cte = pNumcte
								ORDER BY cuenta
							END FOREACH

							SELECT FIRST 1 serv_anualidad
							INTO mServAnualPrimCta
							FROM "informix".sc_maecomtasserv_pm
							WHERE cuenta = cPrimerCta;

							IF cPrimerCta IS NOT NULL THEN
								-- // OBTIENE EL SALDO DE LA CUENTA
								EXECUTE PROCEDURE "informix".cons_saldo(cPrimerCta)
								INTO cCodRetCS, mSaldoCta, cStaCtaCS;

								LET iNumCtas = 1;

								IF mServAnualPrimCta IS NOT NULL THEN
									LET dMontoAplica = mServAnualPrimCta;
								ELSE
									LET dMontoAplica = dMtoAplicComis;
								END IF

								IF mSaldoCta >= dMontoAplica THEN
									LET cBandPrimCtaValida = 1;
								END IF
							END IF

							IF cBandPrimCtaValida = 1 THEN
								LET pCuenta = cPrimerCta;
							ELSE
								--// SE BARREN LAS CUENTAS DE DEBITO DEL CTE
								FOREACH
									SELECT cuenta, saldo
									INTO cCtaCargoInaccta, mSaldoCta
									FROM
									(
										--RQM 09 704.Se agrega las variable de saldo inmovilizado al calculo de saldo disponible.DHG
										SELECT t1.cuenta, t1.sdo_actual - (t1.sdo_retenido + t1.sdo_cong + t1.imp_sbg_ccc + t1.saldo_sbc) AS saldo
										FROM "informix".sc_maechq t1, "informix".sc_maenoc t2
										WHERE t1.num_cte = pNumcte
										AND t1.cuenta = t2.cuenta
										AND t1.cuenta <> cPrimerCta
										AND t1.status_cta = "1"
										AND t1.producto IN ("1200","2200")
										ORDER BY t2.fecha_alta
									)

									LET pCuenta = cCtaCargoInaccta;

									LET iNumCtas = iNumCtas + 1;

									IF iNumCtas = 1 THEN
										LET cPrimerCta = cCtaCargoInaccta;
									END IF

									SELECT FIRST 1 serv_anualidad
									INTO mServAnualidad
									FROM "informix".sc_maecomtasserv_pm
									WHERE cuenta = pCuenta;

									IF mServAnualPrimCta IS NOT NULL THEN
										LET mServAnualidad = mServAnualPrimCta;
									ELSE
										LET mServAnualPrimCta = 0;
									END IF

									IF mServAnualidad IS NOT NULL THEN
										LET dMontoAplica = mServAnualidad;
									END IF

									IF dMontoAplica > mSaldoCta THEN
										CONTINUE FOREACH;
									ELSE
										LET cBandCtaValida = "1";
										EXIT FOREACH;
									END IF
								END FOREACH
							END IF

							-- VALIDA CUANDO NO HAY CUENTAS ACTIVAS PARA EL CLIENTE
							IF iNumCtas = 0 THEN
								LET sBandCargo = 0;
							ELSE
								IF dMontoAplica > 0 THEN
									LET sBandCargo = 1;
								END IF
							END IF
						END IF
					END IF
				END IF
			END IF

			--// VALIDA SI SE CUMPLEN LAS CONDICIONES PARA SEGUIR CON EL CARGO
			IF sBandCargo = 1 THEN
				LET mDisponible = 0;
				LET mMtoCom = 0.0;
				LET mMontoPen = 0.0;
				LET	mIva = 0.0;
				LET cCodRetGF = "000";
				LET cFolioGF = "";
				LET cCodRetCR = "000";
				LET cComisionCR = "";

				let dMontoAplica = dMontoAplica;

				IF pTransacc = cTrananuaserv THEN
					INSERT INTO "informix".sc_bitacora_compm (tpo_com, num_cte, num_cta, fecha_gencom)
					VALUES (cTrananuaserv, pNumcte, pCuenta, dtFechaHoy);
					LET cDescTranRef = "COMISION X ANUALIDAD SERVICIO EMPRESANET";
					LET cDescIvaRef = "IVA COMISION X ANUALIDAD SERV EMPRESANET";
				END IF

				-- // OBTIENE EL SALDO DE LA CUENTA
				EXECUTE	PROCEDURE "informix".cons_saldo(pCuenta)
				INTO cCodRetCS, mDisponible, cStaCtaCS;

				-- // Aplica Cargo por Comision
				IF mDisponible > 5 THEN
					--// VALIDA SI EL SALDO DISPONIBLE ALCANZA PARA HACER EL COBRO SINO RECALCULA LA COMISION Y EL IVA
					IF mDisponible < (dMontoAplica * (1 + dValIva)) THEN
						LET mMtoCom   = dMontoAplica;
						LET dMontoAplica = ROUND(mDisponible / (1 + dValIva),2);
						LET mMontoPen = mMtoCom - dMontoAplica;
						LET mIva = mDisponible - dMontoAplica;
					ELSE
						LET mIva = TRUNC((dMontoAplica * dValIva),2);
					END IF;
					--// GENERA EL FOLIO DEL MOVIMIENTO
					EXECUTE PROCEDURE "informix".sp_generafolionomina ("informix")
					INTO cCodRetGF, cFolioGF;
					IF cCodRetGF::INTEGER <> 0 THEN
						LET cCodRet = cCodRetGF;
						RETURN cCodRet;
					END IF
					--// GENERA EL CARGO POR EL VALOR DE LA COMISION
					EXECUTE PROCEDURE "informix".cargon_ref("001", "9250", "informix", cTranCom, "0000", cFolioGF, pCuenta, 0, dMontoAplica, "01", cDescTranRef,"","")
					INTO cCodRetCR, cComisionCR;
					IF cCodRetCR::INTEGER <> 0 THEN
						LET cCodRet = cCodRetCR;
						RETURN cCodRet;
					END IF
					--// GENERA EL CARGO POR EL VALOR DEL IVA DE LA COMISION
					EXECUTE PROCEDURE "informix".cargon_ref("001", "9250", "informix", vTranIva, "0000", cFolioGF, pCuenta, 0, mIva, "01", cDescIvaRef,"","")
					INTO cCodRetCR, cComisionCR;
					IF cCodRetCR::INTEGER <> 0 THEN
						LET cCodRet = cCodRetCR;
						RETURN cCodRet;
					END IF
					-- // Registra comision pendiente si es el caso
					IF mMontoPen > 0 THEN
						INSERT INTO "informix".sc_detcomis
						VALUES("001", pCuenta, cTranCom, mMontoPen  , 0, TODAY, "", "P", cFolioGF);

						UPDATE "informix".sc_maechq
						SET com_pendiente =  com_pendiente + mMontoPen
						WHERE empresa = "001"
						AND cuenta  = pCuenta;
					END IF;
				ELSE
					INSERT INTO "informix".sc_detcomis
					VALUES("001", pCuenta, cTranCom, dMontoAplica, 0, TODAY, "", "P", cFolioGF);

					UPDATE "informix".sc_maechq
					SET com_pendiente =  com_pendiente + dMontoAplica
					WHERE empresa = "001"
					AND cuenta  = pCuenta;
				END IF;
			END IF
		END FOREACH
	END FOREACH

	RETURN cCodRet;

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para el cargo parametrizado de comisiones para personas morales',
'BD: bdicheq',
'AUTOR: Mohamed CarreÃ³n ',
'FECHA: Octubre 2014',
'MODIFICO: Daniel Hernandez Garcia',
'FECHA: 19-08-2025',
'MODIFICACION: Se modifica la forma de calculo de saldo disponible para considerar un nuevo campo', 
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD: BDICHEQ',
'VERSION: 1.2';

CREATE PROCEDURE "informix".sp_portabregistrapagoprogramado(pUsuario CHAR(8))
RETURNING  CHAR(5);
    
    DEFINE cCodRet 							CHAR(5);
    DEFINE cCodRet2							CHAR(5);
    DEFINE iSqlErr							INTEGER;
    DEFINE cEmpresaEmpleado					CHAR(5);
    DEFINE cNumCliente						CHAR(20);
    DEFINE cCuentaOrigen					CHAR(20);
    DEFINE iSecuencia						INTEGER;
    DEFINE cBancoDestino					CHAR(3);
    DEFINE cCuentaDestino					CHAR(20);
    DEFINE cTarjetaDestino					CHAR(20);
    DEFINE cFechaDeposito					CHAR(60);
    DEFINE cEstatus							CHAR(2);
    DEFINE mMontoTotal						MONEY (16,2);
    DEFINE cFolioSuc						CHAR(16);
    DEFINE mSdoDisponible					MONEY (16,2);
    DEFINE dFechaHoy						DATE;
    DEFINE dFechaHoyMov						DATE;
    DEFINE dFechaHoyAnt						DATE;
    DEFINE cConsecutivoCentral				CHAR(8);
    DEFINE cFolioPortabilidad				CHAR(18);
    DEFINE cTransaccUsada					CHAR(4);
    DEFINE cMensaje							CHAR(100);
    DEFINE iCantidadFallos					INTEGER;
    DEFINE iCantidadTomados					INTEGER;
    DEFINE cHoraCierreSPEI					DATETIME HOUR TO SECOND;
    DEFINE cHoraActualServidor				DATETIME HOUR TO SECOND;
    DEFINE cMensajeProcesos					CHAR(250);
    DEFINE cIDClabeOTarjeta					CHAR(2);
    DEFINE cTelefonoCelCte					CHAR(13);
    DEFINE v_valida                         INTEGER;
    DEFINE v_estatus_portabilidad           CHAR (2);
    DEFINE v_fecha_estatus_portabilidad     CHAR(8);
    DEFINE v_clave_origen                   CHAR(1);
    DEFINE v_clave_sentido                  CHAR(1);
    DEFINE v_bco_ordenante                  CHAR(5);
    DEFINE v_total                          CHAR(2);
    DEFINE cCodRet3                         CHAR(3);
    DEFINE cCodRet_fech_lim 				DATE;
    DEFINE v_fecha_estatus_portabilidad_fin DATE;
    DEFINE v_fecha_insert                   VARCHAR(12);
    DEFINE v_fecha_insert_fin               VARCHAR(12);  
    DEFINE v_fecha_solicitud	            CHAR(8);
    DEFINE v_num_tarjeta                    CHAR(20);  
    DEFINE v_cuenta_clabe	                CHAR(18);
    DEFINE v_total_tajeta                   CHAR (2);
    DEFINE v_total_cveinter                 CHAR (2);
    DEFINE dFechaActual                     DATE;
	DEFINE v_folio_solicitud				CHAR (30); 		--Se agrega variable para el Folio de solicitud de la portabilidad de nomina 
	DEFINE v_bco_recep_solicitud			CHAR (5);		--Se agrega variable para la Clave CASFIN del banco donde se realiza la solicitud de portabilidad de nomina. 
	DEFINE cClaveBanCoppel					CHAR (5);		--Se agrega variable para la Clave CASFIN de Bancoppel.
	--RQM 09 704.Se definen las variables requeridas para la consulta del saldo disponible.DHG
	DEFINE cCodRetConsSdo		CHAR(5); --Codigo de retorno de SP de consulta de saldo.
	DEFINE cMensajeRetConsSdo 	CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
    
    LET cCodRet 			= '00000';
    LET cCodRet2 			= '00000';
    LET iSqlErr				= 0;
    LET cEmpresaEmpleado	= '';
    LET cNumCliente			= '';
    LET cCuentaOrigen		= '';
    LET iSecuencia			= 0;
    LET cBancoDestino		= '';
    LET cIDClabeOTarjeta	= '';
    LET cCuentaDestino		= '';
    LET cTarjetaDestino		= '';
    LET cFechaDeposito		= '';
    LET cEstatus			= '';
    LET mMontoTotal			= 0.00;
    LET cFolioSuc			= '';
    LET mSdoDisponible		= 0.00;
    LET dFechaHoy			= '';
    LET dFechaHoyMov		= '';
    LET dFechaHoyAnt		= '';
    LET cConsecutivoCentral	= '';
    LET cFolioPortabilidad	= '';
    LET cTransaccUsada		= '';
    LET cMensaje			= '';
    LET iCantidadFallos		= 0;
    LET iCantidadTomados	= 0;
    LET cHoraCierreSPEI		= '';
    LET cHoraActualServidor	= '';
    LET cMensajeProcesos	= '';
    LET cTelefonoCelCte		= '';
    LET v_valida            = 0;
    LET v_estatus_portabilidad       = '';
    LET v_fecha_estatus_portabilidad = '';
    LET v_clave_origen      = '';
    LET v_clave_sentido     = '';
    LET v_bco_ordenante     = '';
    LET v_total             = '';
    LET cCodRet3            = '';
    LET cCodRet_fech_lim    = '';
    LET v_fecha_estatus_portabilidad_fin = '';
    LET v_fecha_insert      = ''; 
    LET v_fecha_insert_fin  ='';
    LET v_num_tarjeta       = '';
    LET v_cuenta_clabe      ='';
    LET v_total_tajeta      = '';
    LET v_total_cveinter    = '';
    LET dFechaActual        = '';
	LET v_folio_solicitud		= '';		
	LET v_bco_recep_solicitud	= '';
	LET cClaveBanCoppel		= '40137';
    --RQM 09 704. Se inicializan las variables para el llamado y retorno de consulta de saldo. DHG.
	LET cCodRetConsSdo		= '00000';
	LET cMensajeRetConsSdo	= '';
	
    BEGIN
    
    ON EXCEPTION SET iSqlErr
        IF iSqlErr != 0 THEN
            LET cCodRet= iSqlErr;
            LET cMensaje = 'OCURRIO UN ERROR INESPERADO';
            IF cConsecutivoCentral IS NULL OR cConsecutivoCentral = '' THEN
                LET cConsecutivoCentral = '0';
            END IF;
            CALL bdicheq:sp_PortabRegistraEjecucion('sp_PortabRegistraPagoProgramado', dFechaHoyMov, cCodRet, cMensaje ,cConsecutivoCentral) 
            RETURNING cCodRet2,cMensajeProcesos;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;
    
    --SET DEBUG FILE TO "/ifxsif01/dhg/Ejecuciones/sp_portabregistrapagoprogramado.out";
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- Obtiene la fecha del sistema de cheques.
    SELECT fecha_hoy 
      INTO dFechaHoy
      FROM bdicheq:sc_fechas
     WHERE empresa = '001';
    
    LET dFechaHoyMov = dFechaHoy;
    LET dFechaActual = dFechaHoy;
    
    -- Valida que exista el usuario.
    IF NOT EXISTS (SELECT 1 FROM bdinteg:si_ejecut WHERE ejecutivo = pUsuario) THEN
        LET cCodRet = '00001';
        LET cMensaje = 'EL USUARIO NO SE ENCUENTRA REGISTRADO';
        IF cConsecutivoCentral IS NULL OR cConsecutivoCentral = '' THEN
            LET cConsecutivoCentral = '0';
        END IF;
        CALL bdicheq:sp_PortabRegistraEjecucion('sp_PortabRegistraPagoProgramado', dFechaHoyMov, cCodRet, cMensaje ,cConsecutivoCentral) 
        RETURNING cCodRet2,cMensajeProcesos;
        RETURN cCodRet;
    END IF;

	--RQI 61 1241.Daniel Hernandez Garcia. Modificacion realizada: Comentarizacion del proceso de revision de fecha habil con relacion a dias feriados, por ser innecesaria, debido a que ya se valida en otros lados.
    -- Valida si la fecha hoy es habil
	/* CALL bdidomi:sp_ValFeriadoBanca('001',dFechaHoy,0,'S') 
    RETURNING cCodRet2,dFechaHoyAnt;

    IF cCodRet2 <> 0 THEN
        Si no es habil asigna la siguiente fecha habil.
        CALL bdidomi:sp_ValFeriadoBanca('001',dFechaHoy,1,'S') --16/09/2023
        RETURNING cCodRet2,dFechaHoyAnt;
        
        IF cCodRet2 = 0 THEN
            LET dFechaHoy = dFechaHoyAnt;
        ELSE
            LET cCodRet = '00002';
            LET cMensaje = 'SE TUVO PROBLEMAS AL INTENTAR OBTENER LA FECHA PROXIMA';
            IF cConsecutivoCentral IS NULL OR cConsecutivoCentral = '' THEN
                LET cConsecutivoCentral = '0';
            END IF;
            CALL bdicheq:sp_PortabRegistraEjecucion('sp_PortabRegistraPagoProgramado', dFechaHoyMov, cCodRet, cMensaje ,cConsecutivoCentral) 
            RETURNING cCodRet2,cMensajeProcesos;
            RETURN cCodRet;
        END IF;
    END IF; */
    
	--RQI 61 1241. Daniel Hernandez Garcia. Modificacion realizada: Comentarizacion del proceso de validacion de la hora de cierre del SPEI, ya que actualmente la validacion no aporta nada al proceso.
    --Consulta la hora de cierre para SPEI.
    /*SELECT TRIM(valor)
      INTO cHoraCierreSPEI
      FROM bdicheq:sc_param
     WHERE codparam = 'PORTAHORACIERRE';
    
    LET cHoraActualServidor = CURRENT HOUR TO SECOND; 
    
    Si la hora es mayor a la parametrizada, se programa el pago al siguiente dia habil de lunes a viernes.
    IF cHoraActualServidor >= cHoraCierreSPEI THEN
        Si no es habil asigna la siguiente fecha habil.
        CALL bdidomi:sp_ValFeriadoBanca('001',dFechaHoy,1,'S') 
        RETURNING cCodRet2,dFechaHoyAnt;
        
        IF cCodRet2 = 0 THEN
            LET dFechaHoy = dFechaHoyAnt;
        ELSE
            LET cCodRet = '00002';
            LET cMensaje = 'SE TUVO PROBLEMAS AL INTENTAR OBTENER LA FECHA PROXIMA';
            IF cConsecutivoCentral IS NULL OR cConsecutivoCentral = '' THEN
                LET cConsecutivoCentral = '0';
            END IF;
            CALL bdicheq:sp_PortabRegistraEjecucion('sp_PortabRegistraPagoProgramado', dFechaHoyMov, cCodRet, cMensaje ,cConsecutivoCentral) 
            RETURNING cCodRet2,cMensajeProcesos;
            RETURN cCodRet;
        END IF;
    END IF; */

	--RQI 61 1241. Daniel Hernandez Garcia. Modificacion realizada: Se elimino la condicion "proceso = 'sp_PortabRegistraPagoProgramado'" dentro del SELECT a sc_portabitacora ya que este valor es constante en todos los registros de la tabla por lo que especificar este campo no es necesario. DHG
    -- Consulta si el proceso ya se ejecuto ya que este es diario y si no existe ejecucion registrada se inicializara.
	IF EXISTS (SELECT 1 FROM bdicheq:sc_portabitacora WHERE fecha_ejec = dFechaHoyMov ) THEN --MODIFICACIoN DHG 
        -- Asigna una referencia o clave.
        SELECT (TRIM(valor) + 1)::INTEGER
          INTO cConsecutivoCentral
          FROM bdicheq:sc_param
         WHERE codparam = 'PORTACONSEC';
        
        LET cConsecutivoCentral = LPAD(NVL(TRIM(cConsecutivoCentral),'0'),8,'0');
    ELSE
        -- Asigna una referencia o clave.
        LET cConsecutivoCentral = '00000001';	

        UPDATE bdicheq:sc_param 
           SET valor = cConsecutivoCentral
         WHERE codparam = 'PORTACONSEC';
    END IF;
    
    FOREACH WITH HOLD
        -- Consulta que existan cuentas con su portabilidad activa y Consulta el movimiento diario.
        SELECT {+AVOID_FULL("informix".sc_portabilidadnomina), AVOID_FULL("informix".sc_portaestatus), AVOID_FULL("informix".sc_movdia), AVOID_FULL("informix".sc_portatransacc)}
				PN.empresa, PN.cliente, PN.cuenta_abono, PN.secuencia, PN.banco_ref, PN.cuenta_ref, 
               PN.tarjeta_ref, PN.fecha_deposito, PN.estatus,MV.monto_tot, MV.folio_suc, MV.transacc, PN.fecha_insert
          INTO cEmpresaEmpleado, cNumCliente, cCuentaOrigen, iSecuencia, cBancoDestino, cCuentaDestino, 
               cTarjetaDestino, cFechaDeposito, cEstatus,mMontoTotal, cFolioSuc, cTransaccUsada,v_fecha_insert
          FROM bdicheq:sc_portabilidadnomina AS PN
         INNER JOIN bdicheq:sc_portaestatus AS PE ON (PN.estatus = PE.estatus)
         INNER JOIN bdicheq:sc_movdia AS MV ON (PN.cuenta_abono = MV.cuenta) AND (fech_alt = dFechaHoyMov)
         INNER JOIN bdicheq:sc_portatransacc AS PT ON (MV.transacc = PT.transacc)
         WHERE PN.estatus =  '01'
        
        LET iCantidadTomados = iCantidadTomados + 1;
        
        -- Si no se obtuvo el movimiento.
        IF  mMontoTotal IS NULL OR  cFolioSuc IS NULL OR cFolioSuc = '' OR cTransaccUsada IS NULL OR cTransaccUsada = '' THEN
            LET cMensaje = 'NO SE OBTUVO INFORMACIÃN DE LOS MOVIMIENTOS DIARIOS';
            LET iCantidadFallos = iCantidadFallos + 1;
            CONTINUE FOREACH;
        END IF;
        
        -- Consulta el saldo de la cuenta origen.
        /*SELECT sdo_actual - (sdo_cong + sdo_retenido)
          INTO mSdoDisponible
          FROM bdicheq:sc_maechq 
         WHERE cuenta = cCuentaOrigen;*/
		 
		--RQM 09 704.Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion.DHG
			EXECUTE PROCEDURE bdicheq:sp_cons_sdodisp_x_tpcalculo(cCuentaOrigen,0.00,0.00,0.00,0.00,0.00,0.00,0.00,'T',2) INTO cCodRetConsSdo,cMensajeRetConsSdo,mSdoDisponible;        		
        
        IF mMontoTotal < mSdoDisponible THEN
            LET mSdoDisponible = mMontoTotal;
        END IF;
        
        -- Obtiene la fecha del sistema de cheques.
        /* ##########################
        SELECT fecha_hoy 
          INTO dFechaHoy
          FROM bdicheq:sc_fechas
         WHERE empresa = '001';
        ########################## */
        
        LET dFechaHoy = dFechaActual;
		--RQI 61 1241. Daniel Hernandez Garcia. Modificacion realizada: Comentarizacion del proceso de validacion de la hora de cierre del SPEI, ya que actualmente la validacion no aporta nada al proceso.
        /*LET cHoraActualServidor = CURRENT HOUR TO SECOND;
         
		--Si la hora es mayor a la parametrizada, se programa el pago al siguiente dia habil de lunes a viernes.
        
		IF cHoraActualServidor >= cHoraCierreSPEI THEN
            Si no es habil asigna la siguiente fecha habil.
            CALL bdidomi:sp_ValFeriadoBanca('001',dFechaHoy,1,'S') 
            RETURNING cCodRet2,dFechaHoyAnt;

            IF cCodRet2 = 0 THEN
                LET dFechaHoy = dFechaHoyAnt;
            ELSE
                LET cCodRet = '00002';
                LET cMensaje = 'SE TUVO PROBLEMAS AL INTENTAR OBTENER LA FECHA PROXIMA';
                IF cConsecutivoCentral IS NULL OR cConsecutivoCentral = '' THEN
                    LET cConsecutivoCentral = '0';
                END IF;
                CALL bdicheq:sp_PortabRegistraEjecucion('sp_PortabRegistraPagoProgramado', dFechaHoyMov, cCodRet, cMensaje ,cConsecutivoCentral) 
                RETURNING cCodRet2,cMensajeProcesos;
                RETURN cCodRet;
            END IF;
        END IF;*/
		
        --RQM 10 1642. Daniel Hernandez Garcia. Modificacion realizada: Se agrega la columna 'folio_solicitud' y se elimina la columna 'clave_sentido'.
        --SELECT FIRST 1 b.estatus_portabilidad, b.fecha_estatus_portabilidad, b.clave_origen, b.clave_sentido, b.bco_ordenante, b.fecha_solicitud
          --INTO v_estatus_portabilidad, v_fecha_estatus_portabilidad, v_clave_origen, v_clave_sentido, v_bco_ordenante, v_fecha_solicitud
		SELECT FIRST 1 b.folio_solicitud,b.estatus_portabilidad, b.fecha_estatus_portabilidad, b.clave_origen, b.bco_ordenante, b.fecha_solicitud
          INTO v_folio_solicitud,v_estatus_portabilidad, v_fecha_estatus_portabilidad, v_clave_origen, v_bco_ordenante, v_fecha_solicitud
          FROM sc_portabilidadnomina AS a, 
               sc_portacec_solicitud AS b,  
               sc_movdia AS c
         WHERE a.cliente = b.num_cte
           AND a.cuenta_abono = c.cuenta  
           AND c.fech_alt = dFechaHoyMov 
           AND c.transacc IN('0287','0293')
           AND ( a.cuenta_ref = b.cta_receptora OR a.tarjeta_ref = b.cta_receptora )
           AND a.estatus = '01' 
           AND b.bco_ordenante = cClaveBanCoppel
           AND b.estatus_portabilidad = '1'
           AND a.cliente = cNumCliente;
        ---ORDER BY b.fecha_estatus_portabilidad DESC;
        
		----RQM 10 1642. Daniel Hernandez Garcia. Modificacion realizada: Se extrae la Clave CASFIN del banco donde se recepciono la solicitud.
		LET v_bco_recep_solicitud = SUBSTR(v_folio_solicitud,15,5);
		
        -- SE VALIDA QUE EL REGISTRO DE PORTABILIDAD TENGA UNA FECHA DE ESTATUS  
        IF v_fecha_estatus_portabilidad IS NULL OR v_fecha_estatus_portabilidad = ""  THEN 
            --SI LA FECHA DEL ESTATUS DE LA PORTABILIDAD ESTA EN NULLO O EN BLANCO CONSIDERAMOS LA FECHAS DE LA SOLICITUD
            LET v_fecha_estatus_portabilidad_fin = SUBSTR(v_fecha_solicitud,5,2)|| SUBSTR(v_fecha_solicitud,7,2)||SUBSTR(v_fecha_solicitud,0,4);
            
			--RQM 10 1642. Daniel Hernandez Garcia. Modificacion realizada: Se genera una nueva validacion para determinar si deben cumplirse 5 o 10 dÃ­as para la transferencia de fondos
			-- dependiendo del banco donde se recepciono la solicitud.
			--SI LA SOLICITUD SE REALIZO A TRAVES DE BANCOPPEL.
			IF v_bco_recep_solicitud = cClaveBanCoppel THEN 
                EXECUTE PROCEDURE sp_calFechAbil( v_fecha_estatus_portabilidad_fin, '5') 
                INTO  cCodRet3, cCodRet_fech_lim;
            ELSE 
				--SI LA SOLICITUD SE REALIZO DE OTRO BANCO A BANCOPPEL.
				EXECUTE PROCEDURE sp_calFechAbil( v_fecha_estatus_portabilidad_fin, '10') 
				INTO  cCodRet3, cCodRet_fech_lim;              
            END IF;
			
            --RQM 10 1642. Daniel Hernandez Garcia. Modificacion realizada: Se comenta la validacion anterior.
			--SI LA SOLICITUD ES DIRECTAMENTE EN BANCOPPEL
            /*IF v_clave_sentido = '1' THEN 
                EXECUTE PROCEDURE sp_calFechAbil( v_fecha_estatus_portabilidad_fin, '5') 
                INTO  cCodRet3, cCodRet_fech_lim;
            ELSE 
                -- SI LA SOLICITUD ES DE OTRO BANCO A BANCOPPEL
                IF  v_clave_sentido = '2' THEN 
                    EXECUTE PROCEDURE sp_calFechAbil( v_fecha_estatus_portabilidad_fin, '10') 
                    INTO  cCodRet3, cCodRet_fech_lim;
                END IF;
            END IF;*/
            
            -- SE VALIDA SI CUMPLE LAS REGLAS DEPENDIENDO EL SENTIDO 
            IF cCodRet_fech_lim >= dFechaHoy THEN 	 
                CONTINUE FOREACH;
            END IF;			
        ELSE 
            --EL CAMPO DE ESTATUS PORTABILIDAD SI TIENE FECHA ASIGNADA
            LET v_fecha_estatus_portabilidad_fin = SUBSTR(v_fecha_estatus_portabilidad,5,2)|| SUBSTR(v_fecha_estatus_portabilidad,7,2)||SUBSTR(v_fecha_estatus_portabilidad,0,4);
			
			--RQM 10 1642. Daniel Hernandez Garcia. Modificacion realizada: Se genera una nueva validacion para determinar si deben cumplirse 5 o 10 dÃ­as para la transferencia de fondos
			-- dependiendo del banco donde se recepciono la solicitud.
			--SI LA SOLICITUD SE REALIZO A TRAVES DE BANCOPPEL.
			IF v_bco_recep_solicitud = cClaveBanCoppel THEN 
                EXECUTE PROCEDURE sp_calFechAbil( v_fecha_estatus_portabilidad_fin, '5') 
                INTO  cCodRet3, cCodRet_fech_lim;
            ELSE 
				--SI LA SOLICITUD SE REALIZO DE OTRO BANCO A BANCOPPEL.
				EXECUTE PROCEDURE sp_calFechAbil( v_fecha_estatus_portabilidad_fin, '10') 
				INTO  cCodRet3, cCodRet_fech_lim;              
            END IF;
			
			--RQM 10 1642. Daniel Hernandez Garcia. Modificacion realizada: Se comenta la validacion anterior.
            --SI LA SOLICITUD ES DIRECTAMENTE EN BANCOPPEL
            /* IF   v_clave_sentido = '1' THEN 
                EXECUTE PROCEDURE sp_calFechAbil( v_fecha_estatus_portabilidad_fin, '5') 
                INTO  cCodRet3, cCodRet_fech_lim;
            ELSE 
                -- SI LA SOLICITUD ES DE OTRO BANCO A BANCOPPEL
                IF  v_clave_sentido  =  '2' THEN 
                    EXECUTE PROCEDURE sp_calFechAbil( v_fecha_estatus_portabilidad_fin, '10') 
                    INTO  cCodRet3, cCodRet_fech_lim;
                END IF;
            END IF; */
            
            -- SE VALIDA SI CUMPLE LAS REGLAS DEPENDIENDO EL SENTIDO 
            IF cCodRet_fech_lim >= dFechaHoy THEN 	 
                CONTINUE FOREACH;
            END IF; 
        END IF;
        
        -- Asignacion de referencia o folio.
        LET cFolioPortabilidad = 'PN' || LPAD(YEAR(dFechaHoy),4,'0')||LPAD(MONTH(dFechaHoy),2,'0')|| LPAD(DAY(dFechaHoy),2,'0')||cConsecutivoCentral;
        
        IF cCuentaDestino <> '' AND LENGTH(cCuentaDestino) = 18 AND  SUBSTR(cCuentaDestino,1,3) = cBancoDestino THEN
            LET cIDClabeOTarjeta = '02';
        ELIF cTarjetaDestino <> '' THEN
            LET cIDClabeOTarjeta = '03';
            LET cCuentaDestino = cTarjetaDestino;
        END IF;
        
        -- Obtiene el telefono celular del cliente.
        SELECT telefono 
          INTO cTelefonoCelCte 
          FROM bdinteg:si_telefonos_actual
         WHERE numcte = cNumCliente 
           AND tipo_tel = '2';
        
        -- Valida si el telefono se obtuvo si no se obtiene se envia un 0
        IF cTelefonoCelCte IS NULL OR cTelefonoCelCte = '' THEN
            LET cTelefonoCelCte = '0';
        END IF;
        
        /*
        -- Consulta que el movimiento no exista.
        IF EXISTS ( SELECT 1 FROM bdicheq:sc_portamovtos WHERE cliente = cNumCliente AND cuenta_cargo = cCuentaOrigen AND banco_ref = cBancoDestino AND transaccion = cTransaccUsada AND fecha_envio = dFechaHoy AND folio_suc = cFolioSuc ) THEN
            LET iCantidadFallos = iCantidadFallos + 1; 
            CONTINUE FOREACH;   
        END IF;
        */
        
        LET v_valida = 0;
        
        SELECT COUNT(*) 
          INTO v_valida
          FROM bdicheq:sc_portamovtos 
         WHERE cliente = cNumCliente 
           AND cuenta_cargo = cCuentaOrigen 
           AND banco_ref = cBancoDestino 
           AND transaccion = cTransaccUsada 
           AND fecha_envio = dFechaHoy 
           AND folio_suc = cFolioSuc;
        
        IF v_valida > 0 THEN 
            -- Consulta que el movimiento no exista.
            LET iCantidadFallos = iCantidadFallos + 1; 
            CONTINUE FOREACH; 
        END IF;
        
        -- Reliza la programacion de los pagos.
        CALL bdiprog:sp_altaprogramacion( cNumCliente, cFolioPortabilidad, '07', '01', cCuentaOrigen, cIDClabeOTarjeta, cCuentaDestino, cBancoDestino, cFolioPortabilidad,
                                          cConsecutivoCentral::INTEGER, '0', mSdoDisponible, '', '0.00', '01', 'PORTABILIDAD DE NÃMINA', dFechaHoy, '02', 1, dFechaHoy,
                                          '04', '00', '0', '0', '0', '0', '0', '0', '0', '0', '05', '00', '', '0', cTelefonoCelCte, '00', '', '0', '', '', '0', pUsuario )
        RETURNING cCodRet2,cMensajeProcesos;
        
        IF cCodRet2 = 0 THEN
            -- Registra el movimiento de portabilidad.		
            INSERT INTO bdicheq:sc_portamovtos 
            (referencia1,empresa,cliente,cuenta_cargo,banco_ref,cuenta_ref,tarjeta_ref,monto_enviar,monto_nomina,transaccion,fecha_envio,fecha_recibido,estatus,folio_suc,user_insert,fecha_insert)
            VALUES 	
            (cFolioPortabilidad,cEmpresaEmpleado,cNumCliente,cCuentaOrigen,cBancoDestino,cCuentaDestino,cTarjetaDestino,mSdoDisponible,mMontoTotal,cTransaccUsada,dFechaHoy,dFechaHoyMov,'01',cFolioSuc,pUsuario,dFechaHoyMov);
            
            -- Actualiza el parametro que utilizo
			UPDATE bdicheq:sc_param 
               SET valor = cConsecutivoCentral::INTEGER 
             WHERE codparam = 'PORTACONSEC';
           
		   --RQI 61 1241. Daniel Hernandez Garcia. Modificacion realizada: Comentarizacion del siguiente proceso ya que es innecesario.
            -- Obtiene el parametro.
            /*SELECT TRIM(valor) :: INTEGER + 1
              INTO cConsecutivoCentral
              FROM bdicheq:sc_param
            WHERE codparam = 'PORTACONSEC';
			*/
			
			--RQI 61 1241. Daniel Hernandez Garcia. Modificacion realizada: Modificacion de la siguiente linea con el fin de sustituir la consulta anterior.
			LET cConsecutivoCentral = LPAD(NVL(TRIM(cConsecutivoCentral),'0')::INTEGER + 1,8,'0'); --Adicion de '+ 1'
            LET cMensaje = 'PROCESO EXITOSO';
            
        -- Consulta si se obtuvo el saldo y si es menor a cero no se procesa la cuenta o si el proceso genero un error.
        ELIF cCodRet2 <> 0 OR mSdoDisponible IS NULL OR mSdoDisponible <= 0.00 THEN
            
            LET cMensaje = 'EN AL MENOS UNA CUENTA NO SE REALIZO SU PROGRAMACIÃN DE PAGOS';
            LET iCantidadFallos = iCantidadFallos + 1;
            
            -- ##########################################################---
            -- Registra el movimiento de portabilidad con error.	
            INSERT INTO bdicheq:sc_portamovtos_error 
            (referencia1,empresa,cliente,cuenta_cargo,banco_ref,cuenta_ref,tarjeta_ref,monto_enviar,monto_nomina,transaccion,fecha_envio,fecha_recibido,estatus,folio_suc,user_insert,fecha_insert,error)
            VALUES 	
            (cFolioPortabilidad,cEmpresaEmpleado,cNumCliente,cCuentaOrigen,cBancoDestino,cCuentaDestino,cTarjetaDestino,mSdoDisponible,mMontoTotal,cTransaccUsada,dFechaHoy,dFechaHoyMov,'01',cFolioSuc,pUsuario,dFechaHoyMov,cCodRet2);
            
            -- Registra el movimiento de portabilidad.	
            INSERT INTO bdicheq:sc_portamovtos 
            (referencia1,empresa,cliente,cuenta_cargo,banco_ref,cuenta_ref,tarjeta_ref,monto_enviar,monto_nomina,transaccion,fecha_envio,fecha_recibido,estatus,folio_suc,user_insert,fecha_insert)
            VALUES 	
            (cFolioPortabilidad,cEmpresaEmpleado,cNumCliente,cCuentaOrigen,cBancoDestino,cCuentaDestino,cTarjetaDestino,mSdoDisponible,mMontoTotal,cTransaccUsada,dFechaHoy,dFechaHoyMov,'01',cFolioSuc,pUsuario,dFechaHoyMov);
            
            -- Actualiza el parametro que utilizo
            UPDATE bdicheq:sc_param 
               SET valor = cConsecutivoCentral::INTEGER 
             WHERE codparam = 'PORTACONSEC';
            
		   --RQI 61 1241. Daniel Hernandez Garcia. Modificacion realizada: Comentarizacion del siguiente proceso ya que es innecesario.
            -- Obtiene el parametro.
			/* SELECT TRIM(valor) :: INTEGER + 1
              INTO cConsecutivoCentral
              FROM bdicheq:sc_param
             WHERE codparam = 'PORTACONSEC';*/
            
			--RQI 61 1241. Daniel Hernandez Garcia. Modificacion realizada: Modificacion de la siguiente linea con el fin de sustituir la consulta anterior.
			LET cConsecutivoCentral = LPAD(NVL(TRIM(cConsecutivoCentral),'0')::INTEGER + 1,8,'0');
            
            IF mSdoDisponible IS NULL OR mSdoDisponible <= 0.00 THEN
                LET cMensaje =  'EN AL MENOS UNA CUENTA TUVO PROBLEMAS EN SU SALDO';
            END IF;
            
            CONTINUE FOREACH;
        END IF;	
    END FOREACH
    
    IF iCantidadTomados - iCantidadFallos = 0 THEN
        LET cMensaje = 'NO SE ENCONTRO INFORMACIÃN POR PROCESAR';
        LET cConsecutivoCentral = 1;
    END IF;
    
    IF cConsecutivoCentral IS NULL OR cConsecutivoCentral = '' THEN
        LET cConsecutivoCentral = '1';
    END IF;
    
    CALL bdicheq:sp_PortabRegistraEjecucion('sp_PortabRegistraPagoProgramado', dFechaHoyMov, cCodRet, cMensaje ,cConsecutivoCentral - 1) 
    RETURNING cCodRet2,cMensajeProcesos;		
    
    RETURN cCodRet;
    
    END
    
END PROCEDURE
Document
'DESCRIPCION: Proceso que registra la programacion de los pagos con base a un movimiento diario,', 
'			  registra el pago programado y genera el movimiento de portabilidad.',
'AUTOR: Antonio Bastidas',
'FECHA: 08/06/2010',
'VERSION: 20100618.1855',
'BD: BDICHEQ',
'MODIFICO: Daniel Hernandez Garcia',
'FECHA: 19-08-2025',
'MODIFICACION: Se modifica la forma de calculo de saldo disponible para considerar un nuevo campo', 
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD: BDICHEQ',
'VERSION: 1.2';

CREATE PROCEDURE "informix".sp_cargoxcomision_pm_esp()
RETURNING
	CHAR(6)		AS cod_ret

	---DECLARACIONES
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE cCodRet			CHAR(6);

	DEFINE pNumcte			CHAR(20);
	DEFINE pCuenta			CHAR(20);
	DEFINE pProducto		CHAR(4);
	DEFINE pTransacc		CHAR(4);
	DEFINE dSdoPromMen		DECIMAL(18,2);
	DEFINE dMontoAplica		MONEY;
	DEFINE dMtoAplicComis	MONEY;
	DEFINE cAnioMesAnte		CHAR(6);
	DEFINE mValorSdoPos		MONEY;
	DEFINE mDisponible      MONEY(14,2);
	DEFINE cCodRetGF		CHAR(3);
	DEFINE cFolioGF			CHAR(16);
	DEFINE cCodRetCR		CHAR(5);
	DEFINE cComisionCR		CHAR(4);
	DEFINE mIva				MONEY(14,2);
	DEFINE dValIva			DECIMAL(9,6);
	DEFINE mMontoPen		MONEY(14,2);
	DEFINE mMtoCom			MONEY(14,2);
	DEFINE cTranCom         CHAR(4);
	DEFINE vTranIva         CHAR(4);
	DEFINE mSdoPromMM		MONEY;
	DEFINE mComCgoNoSMM		MONEY;
	DEFINE cTpoPersona		CHAR(1);
	DEFINE mComInacCta		MONEY;
	DEFINE dtFecUltDep		DATE;
	DEFINE dtFecUltRet		DATE;
	DEFINE dtFecUltMov		DATE;

	DEFINE iDifDias			INT8;
	DEFINE sBandCtaNva		SMALLINT;
	DEFINE sBandCargo		SMALLINT;
	DEFINE cDescTranRef		CHAR(40);
	DEFINE cDescIvaRef		CHAR(40);
	DEFINE sFecComision		DATE;
	DEFINE mAcumSdoPos		MONEY;
	DEFINE iDiaSdoPos		SMALLINT;
	DEFINE dtFechaHoy		DATE;
	DEFINE dtFechaAlta		DATE;
	DEFINE mServAnualidad	MONEY;
	DEFINE mServAnualPrimCta	MONEY;
    DEFINE dtConsMovhis 	DATE;
    DEFINE dtConsMovhisold 	DATE;
    DEFINE dtConsMovhisold2 DATE;
	DEFINE sBandDetcomis	SMALLINT;
	DEFINE cTranSdoprommm	CHAR(4);
	DEFINE cTranInaccta		CHAR(4);
	DEFINE cTrananuaserv	CHAR(4);
	DEFINE cCtaCargoInaccta	CHAR(20);
	DEFINE cPrimerCta		CHAR(20);
	DEFINE mSaldoCta		MONEY;
	DEFINE iNumCtas			SMALLINT;
	DEFINE cBandCtaValida	CHAR(1);
	DEFINE cBandPrimCtaValida	CHAR(1);
	DEFINE sFecComBit		DATE;
	DEFINE sBandComBit		SMALLINT;
	DEFINE cCodRetCS		CHAR(5);
	DEFINE cStaCtaCS		CHAR(1);




	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cCodRet             = "000000";

	LET pNumcte				= "";
	LET pCuenta				= "";
	LET pProducto			= "";
	LET pTransacc			= "";
	LET dSdoPromMen			= 0.0;
	LET dMontoAplica		= 0.0;
	let dMtoAplicComis		= 0.0;
	LET cAnioMesAnte		= "";
	LET mValorSdoPos		= 0.0;
	LET mDisponible  		= 0;
	LET cCodRetGF			= "000";
	LET cFolioGF			= "";
	LET cCodRetCR			= "000";
	LET cComisionCR			= "";
	LET	mIva				= 0.0;
	LET dValIva				= 0.0;
	LET mMontoPen			= 0.0;
	LET mMtoCom             = 0.0;
	LET cTranCom         	= "";
	LET vTranIva         	= 0.0;
	LET mSdoPromMM			= 0.0;
	LET mComCgoNoSMM		= 0.0;
	LET cTpoPersona			= "";
	LET mComInacCta			= 0.0;
	LET dtFecUltDep			= NULL;
	LET dtFecUltRet			= NULL;
	LET dtFecUltMov			= NULL;
	LET iDifDias			= 0;
	LET sBandCtaNva			= NULL;
	LET sBandCargo			= 0;
	LET cDescTranRef		= "";
	LET cDescIvaRef			= "";
	LET sFecComision		= NULL;
	LET mAcumSdoPos			= 0.0;
	LET iDiaSdoPos			= 0;
	LET dtFechaHoy			= DATE(1);
	LET dtFechaAlta			= DATE(1);
	LET mServAnualidad		= 0.0;
	LET mServAnualPrimCta	= 0.0;
    LET dtConsMovhis 		= DATE(1);
    LET dtConsMovhisold 	= DATE(1);
    LET dtConsMovhisold2 	= DATE(1);
	LET sBandDetcomis		= 0;
	LET cTranSdoprommm		= "";
	LET cTranInaccta		= "";
	LET cTrananuaserv		= "";
	LET cCtaCargoInaccta	= "";
	LET mSaldoCta			= 0.0;
	LET cPrimerCta			= "";
	LET iNumCtas			= 0;
	LET cBandCtaValida		= "0";
	LET cBandPrimCtaValida	= 0;
	LET sFecComBit			= DATE(1);
	LET sBandComBit			= 0;
	LET cCodRetCS			= "000";
	LET cStaCtaCS			= "";


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/informix/moha/sp_cargoxcomision_pm_esp.out';
	--TRACE ON;

	SELECT fecha_hoy
	INTO dtFechaHoy
	FROM "informix".sc_fechas
	WHERE empresa = "001";

	SELECT TRIM(valor)
	INTO cTranSdoprommm
	FROM sc_param
	WHERE empresa = "001"
	AND codparam = 'transdoprommm';

	SELECT TRIM(valor)
	INTO cTranInaccta
	FROM sc_param
	WHERE empresa = "001"
	AND codparam = 'transinaccta1';

	SELECT TRIM(valor)
	INTO cTrananuaserv
	FROM sc_param
	WHERE empresa = "001"
	AND codparam = 'transanuserven';

	--// OBTIENE EL VALOR DEL PARAMETRO DEL IVA
	SELECT TRIM(valor)
	INTO dValIva
	FROM bdinteg:"informix".si_param
	WHERE empresa = "001"
	AND cod_param = 47;

	-- CICLO DE LAS TRANSACCIONES
	FOREACH
		SELECT TRIM(valor)
		INTO pTransacc
		FROM "informix".sc_param
		WHERE empresa = "001"
		AND codparam IN ("transdoprommm","transinaccta1","transanuserven")

		--// OBTIENE EL VALOR DE LA COMISION A COBRAR DE LA TABLA sc_comisiones
		SELECT monto_aplica, transacc_com, transacc_iva
		INTO dMtoAplicComis, cTranCom, vTranIva
		FROM "informix".sc_comisiones
		WHERE empresa = "001"
		AND comision = pTransacc;

		LET dMtoAplicComis = NVL(dMtoAplicComis,0);

		--// CICLO PRINCIPAL DONDE BARRE TODAS LAS CUENTAS DE PERSONA MORAL
		FOREACH
			SELECT mae.cuenta, mae.producto, mae.num_cte, fecultdep, fecultret, pro.sdoprommen, noc.fecha_alta
			INTO pCuenta, pProducto, pNumcte, dtFecUltDep, dtFecUltRet, dSdoPromMen, dtFechaAlta
			FROM "informix".sc_producto pro, "informix".sc_maechq mae, "informix".sc_maenoc noc
			WHERE pro.empresa = "001"
			AND pro.producto = mae.producto
			AND pro.pago_interes = 'M'
			AND mae.empresa = pro.empresa
			AND mae.producto = pro.producto
			AND pro.producto IN ("1600","1200","2200")
			AND mae.status_cta IN ("1","4","5")
			AND noc.empresa = mae.empresa
			AND noc.cuenta = mae.cuenta

			LET sBandCargo = 0;

			IF pTransacc = cTranSdoprommm THEN
				--//////////////////////////////////////////////////////////--
				--// COMISION / CARGO POR NO TENER SALDO PROMEDIO MINIMO MENSUAL
				LET mSdoPromMM = 0.0;
				LET mComCgoNoSMM = 0.0;
				LET mAcumSdoPos	= 0.0;
				LET iDiaSdoPos = 0;

				--// OBTIENE EL SALDO PROMEDIO MENSUAL Y LA COMISION EN LA TABLA MAESTRA DE LAS COMISIONES DE LA CUENTAS DE PERSONAS MORALES
				SELECT sdo_prom_mm, com_cgo_no_smm
				INTO mSdoPromMM, mComCgoNoSMM
				FROM "informix".sc_maecomtasserv_pm
				WHERE num_cte = pNumcte
				AND cuenta = pCuenta;

				IF mSdoPromMM IS NOT NULL THEN
					LET dSdoPromMen = mSdoPromMM;
				ELSE
					LET mSdoPromMM = 0;

				END IF

				IF mComCgoNoSMM IS NOT NULL THEN
					LET dMontoAplica = mComCgoNoSMM;
				ELSE
					LET dMontoAplica = dMtoAplicComis;
				END IF

				IF dMontoAplica = 0 OR pCuenta IN ("12000000602","12000001102","12000000270","12000000963") THEN
					LET sBandCargo = 0;
				ELSE
					-- OBTIENE EL AÃO Y EL MES ANTERIOR
					LET cAnioMesAnte = YEAR(dtFechaHoy - 1 units MONTH) || LPAD(MONTH(dtFechaHoy - 1 units MONTH),2,"0");
					--// OBTIENE EL VALOR ACUMULADO Y EL DIA DEL SALDO POS DE LA CUENTA
					SELECT acum_sdo_pos, dia_sdo_pos
					INTO mAcumSdoPos, iDiaSdoPos
					FROM "informix".sc_maehis
					WHERE aniomes = cAnioMesAnte
					AND cuenta = pCuenta;

					LET mAcumSdoPos = NVL(mAcumSdoPos, 0);
					LET iDiaSdoPos = NVL(iDiaSdoPos, 0);

					IF iDiaSdoPos = 0 THEN
						LET mValorSdoPos = 0;
					ELSE
						LET mValorSdoPos = mAcumSdoPos / iDiaSdoPos;
					END IF

					--// VALIDA SI EL SALDO POS ES MENOR AL SALDO PROMEDIO DE LA sc_producto
					IF mValorSdoPos < dSdoPromMen THEN
						LET sBandCargo = 1;
						LET cDescTranRef = "COMISION X NO TENER SALDO PROMEDIO MENS";
						LET cDescIvaRef = "IVA COMISION X NO TENER SALDO PROM MENS";
					END IF
				END IF
			ELIF pTransacc = cTranInaccta THEN
				--//////////////////////////////////////////////////////////--
				--// COMISION/CARGO POR INACTIVIDAD DE LA CUENTA DURANTE 1 AÃO
				LET mComInacCta = 0;
				LET dtFecUltMov	= NULL;

				SELECT com_ina_cta
				INTO mComInacCta
				FROM "informix".sc_maecomtasserv_pm
				WHERE num_cte = pNumcte
				AND cuenta = pCuenta;

				IF mComInacCta IS NOT NULL THEN
					LET dMontoAplica = mComInacCta;
				ELSE
					LET mComInacCta = 0;
					LET dMontoAplica = dMtoAplicComis;
				END IF

				IF dMontoAplica = 0 THEN
					LET sBandCargo = 0;
				ELSE
					-- VALIDA QUE LA CUENTA TENGA POR LO MENOS UN AÃO DE VIDA
					IF (dtFechaHoy - dtFechaAlta) > 360 THEN

						IF dtFecUltDep IS NULL AND dtFecUltRet IS NULL THEN
							LET sBandCargo = 1;
						ELSE
							IF dtFecUltDep IS NOT NULL THEN
								LET dtFecUltMov = dtFecUltDep;
							END IF

							IF dtFecUltRet IS NOT NULL THEN
								IF dtFecUltRet > dtFecUltMov THEN
									LET dtFecUltMov = dtFecUltRet;
								END IF
							END IF

							IF (dtFechaHoy - dtFecUltMov) < 361 THEN
								LET sBandCargo = 0;
							ELSE
								LET sBandCargo = 1;
								LET cDescTranRef = "COMISION X INACTIVIDAD DE LA CTA 1 AÃO";
								LET cDescIvaRef = "IVA COMISION X INACT DE LA CTA 1 AÃO";
							END IF
						END IF
					END IF
				END IF
			ELIF pTransacc = cTrananuaserv THEN
				--//////////////////////////////////////////////////////////--
				--// COMISION/CARGO POR ANUALIDAD DEL SERVICIO DE EMPRESANET
				LET iDifDias = 0;
				LET sBandCtaNva = NULL;
				LET iNumCtas = 0;
				LET cBandCtaValida = "0";
				LET sFecComBit = DATE(1);
				LET sBandComBit	= 0;
				LET cPrimerCta = "";
				LET mServAnualPrimCta = 0.0;
				LET mServAnualidad = 0.0;
				LET mSaldoCta = 0.0;
				LET cCtaCargoInaccta = "";

				--// OBTIENE EL NUMERO DE DIAS DE LA FECHA ACTUAL RESPECTO A SU FECHA DE REGISTRO
				SELECT dtFechaHoy - f_registro
				INTO iDifDias
				FROM bdibei: "informix".bei_contratacion
				WHERE empresa = "001"
				AND num_cliente = pNumcte
				AND status_contrato = '30';

				IF iDifDias IS NULL THEN
					LET sBandCargo = 0;
				ELSE
					IF iDifDias > 31 AND iDifDias < 361 THEN
						LET sBandCargo = 0;
					ELSE
						IF iDifDias < 32 THEN
							LET sBandCtaNva = 1;
						ELSE
							LET sBandCtaNva = 0;
						END IF

						LET iNumCtas = 0;
						LET cBandCtaValida = "0";
						LET iDifDias = 0;

						SELECT MAX(fecha_gencom)
						INTO sFecComBit
						FROM "informix".sc_bitacora_compm
						WHERE tpo_com = cTrananuaserv
						AND num_cte = pNumcte;

						LET sBandComBit = 0;

						IF sFecComBit IS NOT NULL THEN
							LET iDifDias = dtFechaHoy - sFecComBit;
							IF sBandCtaNva = 1 THEN
								LET sBandComBit = 1;
							ELIF sBandCtaNva = 0 THEN
								IF iDifDias < 361 THEN
									LET sBandComBit = 1;
								END IF
							END IF
						END IF

						IF sBandComBit = 0 THEN
							FOREACH
								SELECT LIMIT 1 cuenta
								INTO cPrimerCta
								FROM bdicheq:"informix".sc_maechq
								WHERE empresa = "001"
								AND num_cte = pNumcte
								ORDER BY cuenta
							END FOREACH

							SELECT serv_anualidad
							INTO mServAnualPrimCta
							FROM "informix".sc_maecomtasserv_pm
							WHERE cuenta = cPrimerCta;

							IF cPrimerCta IS NOT NULL THEN
								-- // OBTIENE EL SALDO DE LA CUENTA
								EXECUTE PROCEDURE "informix".cons_saldo(cPrimerCta)
								INTO cCodRetCS, mSaldoCta, cStaCtaCS;

								LET iNumCtas = 1;

								IF mServAnualPrimCta IS NOT NULL THEN
									LET dMontoAplica = mServAnualPrimCta;
								ELSE
									LET dMontoAplica = dMtoAplicComis;
								END IF

								IF mSaldoCta >= dMontoAplica THEN
									LET cBandPrimCtaValida = 1;
								END IF
							END IF

							IF cBandPrimCtaValida = 1 THEN
								LET pCuenta = cPrimerCta;
							ELSE
								--// SE BARREN LAS CUENTAS DE DEBITO DEL CTE
								FOREACH
									SELECT cuenta, saldo
									INTO cCtaCargoInaccta, mSaldoCta
									FROM
									(
										--RQM 09 704. Se agrega el campo de saldo inmovilizado en el calculo de saldo disponible.DHG
										SELECT t1.cuenta, t1.sdo_actual - (t1.sdo_retenido + t1.sdo_cong + t1.imp_sbg_ccc + t1.saldo_sbc) AS saldo
										FROM "informix".sc_maechq t1, "informix".sc_maenoc t2
										WHERE t1.num_cte = pNumcte
										AND t1.cuenta = t2.cuenta
										AND t1.cuenta <> cPrimerCta
										AND t1.status_cta = "1"
										AND t1.producto IN ("1600","1200","2200")
										ORDER BY t2.fecha_alta
									)

									LET pCuenta = cCtaCargoInaccta;

									LET iNumCtas = iNumCtas + 1;

									IF iNumCtas = 1 THEN
										LET cPrimerCta = cCtaCargoInaccta;
									END IF

									SELECT serv_anualidad
									INTO mServAnualidad
									FROM "informix".sc_maecomtasserv_pm
									WHERE cuenta = pCuenta;

									IF mServAnualPrimCta IS NOT NULL THEN
										LET mServAnualidad = mServAnualPrimCta;
									ELSE
										LET mServAnualPrimCta = 0;
									END IF

									IF mServAnualidad IS NOT NULL THEN
										LET dMontoAplica = mServAnualidad;
									END IF

									IF dMontoAplica > mSaldoCta THEN
										CONTINUE FOREACH;
									ELSE
										LET cBandCtaValida = "1";
										EXIT FOREACH;
									END IF
								END FOREACH
							END IF

							-- VALIDA CUANDO NO HAY CUENTAS ACTIVAS PARA EL CLIENTE
							IF iNumCtas = 0 THEN
								LET sBandCargo = 0;
							ELSE
								IF dMontoAplica > 0 THEN
									LET sBandCargo = 1;
								END IF
							END IF
						END IF
					END IF
				END IF
			END IF

			--// VALIDA SI SE CUMPLEN LAS CONDICIONES PARA SEGUIR CON EL CARGO
			IF sBandCargo = 1 THEN
				LET mDisponible = 0;
				LET mMtoCom = 0.0;
				LET mMontoPen = 0.0;
				LET	mIva = 0.0;
				LET cCodRetGF = "000";
				LET cFolioGF = "";
				LET cCodRetCR = "000";
				LET cComisionCR = "";

				let dMontoAplica = dMontoAplica;

				IF pTransacc = cTrananuaserv THEN
					INSERT INTO "informix".sc_bitacora_compm (tpo_com, num_cte, num_cta, fecha_gencom)
					VALUES (cTrananuaserv, pNumcte, pCuenta, dtFechaHoy);
					LET cDescTranRef = "COMISION X ANUALIDAD SERVICIO EMPRESANET";
					LET cDescIvaRef = "IVA COMISION X ANUALIDAD SERV EMPRESANET";
				END IF

				-- // OBTIENE EL SALDO DE LA CUENTA
				EXECUTE	PROCEDURE "informix".cons_saldo(pCuenta)
				INTO cCodRetCS, mDisponible, cStaCtaCS;

				-- // Aplica Cargo por Comision
				IF mDisponible > 5 THEN
					--// VALIDA SI EL SALDO DISPONIBLE ALCANZA PARA HACER EL COBRO SINO RECALCULA LA COMISION Y EL IVA
					IF mDisponible < (dMontoAplica * (1 + dValIva)) THEN
						LET mMtoCom   = dMontoAplica;
						LET dMontoAplica = ROUND(mDisponible / (1 + dValIva),2);
						LET mMontoPen = mMtoCom - dMontoAplica;
						LET mIva = mDisponible - dMontoAplica;
					ELSE
						LET mIva = TRUNC((dMontoAplica * dValIva),2);
					END IF;
					--// GENERA EL FOLIO DEL MOVIMIENTO
					EXECUTE PROCEDURE "informix".sp_generafolionomina ("informix")
					INTO cCodRetGF, cFolioGF;
					IF cCodRetGF::INTEGER <> 0 THEN
						LET cCodRet = cCodRetGF;
						RETURN cCodRet;
					END IF
					--// GENERA EL CARGO POR EL VALOR DE LA COMISION
					EXECUTE PROCEDURE "informix".cargon_ref("001", "9250", "informix", cTranCom, "0000", cFolioGF, pCuenta, 0, dMontoAplica, "01", cDescTranRef,"","")
					INTO cCodRetCR, cComisionCR;
					IF cCodRetCR::INTEGER <> 0 THEN
						LET cCodRet = cCodRetCR;
						RETURN cCodRet;
					END IF
					--// GENERA EL CARGO POR EL VALOR DEL IVA DE LA COMISION
					EXECUTE PROCEDURE "informix".cargon_ref("001", "9250", "informix", vTranIva, "0000", cFolioGF, pCuenta, 0, mIva, "01", cDescIvaRef,"","")
					INTO cCodRetCR, cComisionCR;
					IF cCodRetCR::INTEGER <> 0 THEN
						LET cCodRet = cCodRetCR;
						RETURN cCodRet;
					END IF
					-- // Registra comision pendiente si es el caso
					IF mMontoPen > 0 THEN
						INSERT INTO "informix".sc_detcomis
						VALUES("001", pCuenta, cTranCom, mMontoPen  , 0, TODAY, "", "P", cFolioGF);

						UPDATE "informix".sc_maechq
						SET com_pendiente =  com_pendiente + mMontoPen
						WHERE empresa = "001"
						AND cuenta  = pCuenta;
					END IF;
				ELSE
					INSERT INTO "informix".sc_detcomis
					VALUES("001", pCuenta, cTranCom, dMontoAplica, 0, TODAY, "", "P", cFolioGF);

					UPDATE "informix".sc_maechq
					SET com_pendiente =  com_pendiente + dMontoAplica
					WHERE empresa = "001"
					AND cuenta  = pCuenta;
				END IF;
			END IF
		END FOREACH
	END FOREACH

	RETURN cCodRet;

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para el cargo parametrizado de comisiones para personas morales',
'BD: bdicheq',
'AUTOR: Mohamed CarreÃ³n ',
'FECHA: Octubre 2014',
'MODIFICO: Daniel Hernandez Garcia',
'FECHA: 26-08-2025',
'MODIFICACION: Se modifica la forma de calculo de saldo disponible para considerar un nuevo campo', 
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD: BDICHEQ',
'VERSION: 1.0.1';

CREATE PROCEDURE "informix".reverprov(pempresa  char(3),
                                      psucursal char(4),
                                      pusuario  char(8),
                                      pfolio    char(16),
                                      ptiporev  char(1),
				      pcuenta   char(20))

   RETURNING char(5);

   DEFINE sql_err             integer;
   DEFINE isam_err            integer;
   DEFINE cod_ret             char(5);
   DEFINE contador            smallint;
   DEFINE wcompend            money(14,2);
   DEFINE wtiptran            char(2);
   DEFINE wnum_serial         integer;
   DEFINE wtransacc           char(4);
   DEFINE wcuenta             char(20);
   DEFINE wmonto_tot          money(14,2);
   DEFINE wmonto_tot1         money(14,2);
   DEFINE montoaux            money(14,2);
   DEFINE wfirme              money(14,2);
   DEFINE wen_sbc             money(14,2);
   DEFINE wremesas            money(14,2);
   DEFINE wdias_ret           smallint;
   DEFINE wnum_cheq           integer;
   DEFINE wimp_sbg_ccc        money(14,2);
   DEFINE wimp_chq_sbg        money(14,2);
   DEFINE wimp_int_ccc        money(14,2);
   DEFINE wimp_int_sbg        money(14,2);
   DEFINE wchq_exp_mes        smallint;
   DEFINE wnaturaleza         char(1);
   DEFINE wvalida_docto       char(1);
   DEFINE wtipo               char(1);
   DEFINE wsaldo_cuenta       money(14,2);
   DEFINE wsdo_actual         money(14,2);
   DEFINE wsdo_retenido       money(14,2);
   DEFINE wsdo_cong           money(14,2);
   DEFINE wmontoaux           money(14,2);
   DEFINE wlim_chq_sbc        money(14,2);
   DEFINE wimp_chq_sbc        money(14,2);
   DEFINE wlim_chq_rem        money(14,2);
   DEFINE wimp_chq_rem        money(14,2);
   DEFINE wreferencia         char(40);
   DEFINE wstatus_envio       char(1);
   DEFINE wrowid              integer;
   DEFINE wfechoy             date;
   DEFINE pfolio1             char(16);
   DEFINE wtpcheque           char(2);
   DEFINE wfechahora          datetime hour to fraction(3);
   DEFINE vtranusoccc         char(4);
   DEFINE vtrancancta         char(4);
   DEFINE vtranintccc         char(4);
   DEFINE vtranusosbg         char(4);
   DEFINE vtranintsbg         char(4);
   DEFINE wcomision           char(4);
   DEFINE wsuc_cuen           char(4);
   DEFINE wproducto           char(4);
   define vnum_tarjeta        char(16);
   define vmaxsec             smallint;
   DEFINE vProdCrec           CHAR(4);
   define vanio               char(6);
   --RQM 09 704. Se agregan las siguientes variable DFTL 
   define mSaldoSbc       MONEY(14,2);
   define cCodRetConsSdo       CHAR(5); --Codigo de retorno de SP de consulta de saldo.
   define cMensajeRetConsSdo   CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
   

   LET sql_err = 0;
   LET cod_ret = "000";
   --RQM 09 704. Se agregan las siguientes variable DFTL
   LET mSaldoSbc           = 0;
   LET cCodRetConsSdo      = '00000';
   LET cMensajeRetConsSdo  = '';


   BEGIN
      ON EXCEPTION
         SET sql_err, isam_err
         IF (sql_err <> 0) THEN
            SET DEBUG FILE TO "reversionch.err";
            TRACE sql_err || " * " || isam_err;
            LET cod_ret = sql_err;
            RETURN cod_ret;
         END IF;
      END EXCEPTION;

      SELECT fecha_hoy into wfechoy
         FROM sc_fechas where empresa = pempresa;

      SELECT TRIM(valor)
        INTO vProdCrec
        FROM sc_param
       WHERE empresa = pempresa
         AND codparam ="PRODCREC";


      SELECT COUNT(*) INTO contador
         FROM sc_movhis m, bdinteg:si_transacc t
         WHERE m.empresa = pempresa and m.cuenta = pcuenta
	       and fech_alt ="01/02/2008"
	       and folio_suc = pfolio and
	       m.cuenta = pcuenta and
               m.empresa = t.empresa and m.transacc = t.numero and
               reversable = "S" and cancelad <> "S";

      IF (contador = 0) THEN
         SELECT COUNT(*) INTO contador
            FROM  sc_docret
            WHERE empresa = pempresa and folio_suc = pfolio and
                  fecha_alta = wfechoy;
         IF (contador = 0) THEN
            RETURN cod_ret;
         ELSE
            update sc_docret
               set cancelado = "S"
               WHERE empresa = pempresa and folio_suc = pfolio and
                     fecha_alta = wfechoy;
            RETURN cod_ret;
         end if
      end if

      select valor into vtrancancta
         from sc_param
         where empresa = pempresa and codparam = "trancancta";

      select valor into vtranusoccc
         from sc_param
         where empresa = pempresa and codparam = "tranusoccc";

      select valor into vtranintccc
         from sc_param
         where empresa = pempresa and codparam = "tranintccc";

      select valor into vtranusosbg
         from sc_param
         where empresa = pempresa and codparam = "tranusosbg";

      select valor into vtranintsbg
         from sc_param
         where empresa = pempresa and codparam = "tranintsbg";

      FOREACH
         select num_serial,transacc,cuenta,monto_tot,firme,en_sbc,remesas,
                md.dias_ret,num_cheq,naturaleza,valida_docto,tr.tipo_tran,
                referencia,suc_cuen,producto, aniomes
            into wnum_serial,wtransacc,wcuenta,wmonto_tot,wfirme,wen_sbc,
                 wremesas,wdias_ret,wnum_cheq,wnaturaleza,wvalida_docto,
                 wtiptran,wreferencia,wsuc_cuen,wproducto, vanio
            FROM sc_movhis md, bdinteg:si_transacc tr
            WHERE md.empresa = pempresa and folio_suc = pfolio and
		  md.cuenta = pcuenta
                  AND cancelad <> "S" and reversable = "S"
                  AND md.empresa = tr.empresa and numero = transacc
	--	  and transacc in ("3276", "3381")
            ORDER BY naturaleza desc
         select max(secuencia) into vmaxsec
            from sc_tarjeta
            where empresa = pempresa and cuenta = wcuenta and
                  tipo_tarjeta = "T";
         select num_tarjeta into vnum_tarjeta
            from sc_tarjeta
            where empresa = pempresa and cuenta = wcuenta and
                  secuencia = vmaxsec;
         LET wimp_sbg_ccc = 0;
         LET wimp_chq_sbg = 0;
         LET wimp_int_ccc = 0;
         LET wimp_int_sbg = 0;
         LET wchq_exp_mes = 0;
         let wcompend = 0;

         IF wtiptran = "01" THEN
            LET wchq_exp_mes  = 1;
         ELIF wtransacc = vtranusoccc THEN
            LET wimp_sbg_ccc = wmonto_tot;
         ELIF wtransacc = vtranusosbg THEN
            LET wimp_chq_sbg = wmonto_tot;
         ELIF wtransacc = vtranintccc THEN
            LET wimp_int_ccc = wmonto_tot;
         ELIF wtransacc = vtranintsbg THEN
            LET wimp_int_sbg = wmonto_tot;
         ELIF wtiptran = "05" THEN
            LET wcompend = wmonto_tot;
            let wcomision = trim(wreferencia);
         END IF;
         select sdo_actual into wsdo_actual
            from sc_maechq
            where empresa = pempresa and cuenta = wcuenta;

         IF wnaturaleza = "C" THEN
            UPDATE sc_maechq
               SET sdo_actual = sdo_actual + wmonto_tot,
                   imp_cgos_mes = imp_cgos_mes - wmonto_tot,
                   num_cgos_mes = num_cgos_mes - 1,
                   chq_exp_mes = chq_exp_mes - wchq_exp_mes,
                   imp_sbg_ccc = imp_sbg_ccc + wimp_sbg_ccc,
                   imp_int_ccc = imp_int_ccc + wimp_int_ccc,
                   imp_chq_sbg = imp_chq_sbg + wimp_chq_sbg,
                   imp_int_sbg = imp_int_sbg + wimp_int_sbg,
                   com_pendiente = com_pendiente + wcompend
               WHERE empresa = pempresa and cuenta = wcuenta;
            if wtransacc = vtrancancta then
               update sc_maechq
                  set status_cta = "1",
                      fec_cancelac = "",
                      motivo = " "
                  WHERE empresa = pempresa and cuenta = wcuenta;
            end if
            if wtiptran = "05" then
               update sc_detcomis
                  set pago_com = pago_com - wmonto_tot,
                      estado_com = "P"
                  where empresa = pempresa and cuenta = wcuenta and
                        comision = wcomision and fecult_pago = wfechoy;
            end if;
            if ptiporev = "A" then
               delete from sc_movhis
                  where num_serial = wnum_serial;
            else
               UPDATE sc_movhis
                  SET cancelad = "S"
                  WHERE num_serial = wnum_serial;
               INSERT INTO sc_movhis
                  VALUES(0,pfolio,psucursal,pusuario,wfechoy,wfechoy,
                      current hour to fraction(3),wtransacc,wsuc_cuen,
                      wproducto,pempresa,wcuenta," ",wnum_cheq,
                      wmonto_tot * -1,0,0,0,0,"S"," ",wsdo_actual,"0000",
                      "REV",0,vnum_tarjeta,"","");
            end if
            IF wtiptran = "01" THEN
               UPDATE sc_contch
                  SET estado = "N",
                      importe = 0
                  WHERE empresa = pempresa and cuenta = wcuenta AND
                        numero = wnum_cheq;
               UPDATE sc_histch
                  SET estado = "N",
                      importe = 0
                  WHERE empresa = pempresa and cuenta = wcuenta AND
                        numero = wnum_cheq;
            END IF;
         ELSE
            IF (wnaturaleza = "A") THEN
               LET wsaldo_cuenta       = 0;
               LET wsdo_actual         = 0;
               LET wsdo_retenido       = 0;
               LET wsdo_cong           = 0;

               SELECT sdo_actual, sdo_retenido, sdo_cong, saldo_sbc
                  INTO wsdo_actual,wsdo_retenido,wsdo_cong, mSaldoSbc
                  FROM sc_maechq
                  WHERE empresa = pempresa and cuenta = wcuenta;

               --RQM 09 704. Se ejecuta el siguiente SP para el calculo del saldo disponible DFTL 
               EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo('', wsdo_actual, wsdo_retenido, null, mSaldoSbc, null, null, null, 'F', 3)     
               INTO cCodRetConsSdo, cMensajeRetConsSdo, wsaldo_cuenta;

               IF wsaldo_cuenta < wfirme THEN
                  LET cod_ret = "413";
                  RETURN cod_ret;
               END IF;
               UPDATE sc_maechq
                  SET sdo_actual = sdo_actual - wmonto_tot,
                      sdo_retenido= sdo_retenido - wen_sbc,
                      imp_sbg_ccc = imp_sbg_ccc - wimp_sbg_ccc,
                      imp_chq_sbg = imp_chq_sbg - wimp_chq_sbg,
                      num_abonos_mes = num_abonos_mes - 1,
                      imp_abonos_mes = imp_abonos_mes - wmonto_tot
                  WHERE  empresa = pempresa and cuenta = wcuenta;
               if wen_sbc > 0 then
                  update sc_docret
                     set cancelado = "S"
                     where empresa = pempresa and cuenta = wcuenta
                           and folio_suc = pfolio
                           and fecha_alta = wfechoy;
               end if;

	       IF vProdCrec = wproducto THEN
		 UPDATE sc_maechq
		    SET marca_ret = "0"
		  WHERE empresa = pempresa
		    AND cuenta = wcuenta;
	       END IF

               IF (cod_ret = "000") THEN
                  if ptiporev = "A" then
                     delete from sc_movhis
                        where num_serial = wnum_serial;
                  else
                     {UPDATE sc_movhis
                        SET cancelad = "S"
			WHERE cuenta = pcuenta
			  AND fech_alt = "01/02/2008"
                          AND num_serial = wnum_serial;}
                     INSERT INTO sc_movhistmp
                        VALUES(vanio, 0,pfolio,psucursal,pusuario,wfechoy,
			       wfechoy,
                           current hour to fraction(3),wtransacc,wsuc_cuen,
                           wproducto,pempresa,wcuenta," ",wnum_cheq,
                           wmonto_tot * -1,0,0,0,0,"S"," ",wsdo_actual,"0000",
                           "REV",0,vnum_tarjeta,"");
                  end if
               END IF;
            END IF;
         END IF;
      END FOREACH;
   END;
   RETURN cod_ret;
END PROCEDURE DOCUMENT "Version 1.00.000",
'MODIFICADO:            Donovan F. Torres Landeros',
'ULTIMA MODIFICACION:   2025/07/07',
'RAZON:                 Se agrega la nueva variable sdo_sbc (saldo buen cobro)',
'                       a la operacion aritmetica para el nuevo calculo de',
'                       saldo disponible.',
'PROYECTO:              RQM 09 704   Cobranza Automatica en cuentas de captacion',
'BD:                    bdicheq',
'VER:                   1.2';

CREATE PROCEDURE "informix".sp_prog_cierre()
    RETURNING CHAR(5) AS vCodRet1, CHAR(1000) AS vCodRet2, CHAR(1000) AS vCodRet3;

    DEFINE Sql_Err         INTEGER;
    DEFINE Isam_Err        INTEGER;
    DEFINE vCodRet1        CHAR(5);
    DEFINE vCodRet2        CHAR(1000);
    DEFINE vCodRet3        CHAR(1000);
    DEFINE vFechaHoy       DATE;
    DEFINE vTotal          INTEGER;
    DEFINE vOrigen         CHAR(4);
    DEFINE vDestino        CHAR(4);
	DEFINE vOrigen_c       CHAR(4);
    DEFINE vDestino_c      CHAR(4);
    DEFINE vestatus1       INTEGER;
    DEFINE vestatus0       INTEGER;
    DEFINE v_contador      INT;
    DEFINE v_contador2      INT;
    DEFINE iIsamErr        SMALLINT;
    DEFINE cDescErr        CHAR(80);
    DEFINE vsqlerr         INTEGER;
	DEFINE vErrorInfo      CHAR(80);
	DEFINE vstatus		   INTEGER;

    -- Retorno de SP interno
    DEFINE vRetCod         CHAR(5);
    DEFINE vRetMsg         CHAR(1000);
    DEFINE vRetDetalle     CHAR(1000);
    DEFINE vLog            CHAR(1000);
    DEFINE cErrorInfo      CHAR(80);
	DEFINE vstatus_maximo  CHAR(1);

    -- Acumulador de mensajes
    LET Sql_Err    = 0;
    LET Isam_Err   = 0;
    LET vCodRet1   = '00000';
    LET vCodRet2   = 'OPERACION EXITOSA';
    LET vCodRet3   = '';
    LET vLog       = 'No hay sucursales por procesar No hay registros con estatus 0 ni 1.';
    LET vestatus0  = 0;
    LET vestatus1  = 1;
    LET v_contador = 0;
    LET v_contador2 = 0;
    LET iIsamErr   = 0; 
    LET vsqlerr    = 0; 
    LET vErrorInfo = "INICIO DEL PROCESO";
    LET cErrorInfo = "";   


    BEGIN


        ON EXCEPTION SET vsqlerr, iIsamErr, cDescErr
            SET DEBUG FILE TO "/RESPALDOSNEW/sp_control_cierre_sucursal.err";
            TRACE ON;
            IF vsqlerr <> 0 THEN
                LET vCodRet1   = vsqlerr;
                LET vErrorInfo = cErrorInfo;
             RETURN vCodRet1, vCodRet2, vCodRet3;
            END IF;
        END EXCEPTION;

		--SET DEBUG FILE TO "/RESPALDOSNEW/sp_cierre_reproceso.out";
		--TRACE ON;

   
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

        SELECT fecha_hoy INTO vFechaHoy
        FROM informix.sc_fechas
        WHERE empresa = '001';
		
		--LET vFechaHoy = '07082025';

        -- Validar si hay registros con estatus 0 o 1
        SELECT COUNT(*) INTO vTotal
        FROM sc_prog_cierre
        WHERE estatus IN (0,1);

        IF vTotal = 0 THEN
            LET vCodRet3 = vLog;
			RETURN vCodRet1, vCodRet2, vCodRet3;
        END IF;

        -- Procesar estatus 0 y fecha = hoy
        SELECT COUNT(*) INTO vTotal
        FROM sc_prog_cierre
        WHERE estatus = 0 AND fecha_proceso = vFechaHoy;

        IF vTotal > 0 THEN
            FOREACH c0 WITH HOLD FOR
                SELECT origen, destino
                INTO vOrigen, vDestino
                FROM sc_prog_cierre
                WHERE estatus = 0 AND fecha_proceso = vFechaHoy

                CALL sp_control_cierre_sucursal(vOrigen, vDestino)
                RETURNING vRetCod,vRetDetalle;
                
                --LET vRetCod = '00000';

                IF vRetCod <> '00000' THEN
					
					IF  vRetCod = -668 THEN
					    
						UPDATE sc_prog_cierre
						SET estatus = '0'
						WHERE origen = vOrigen
						AND destino = vDestino 
						AND fecha_proceso = vFechaHoy;
						
						
						UPDATE bdicheq:sc_ctrl_cierre_suc
						SET 
						extrae_cuentas = '0'  -- Nuevo valor para el campo extrae_cuentas
						WHERE sucursal_origen = vOrigen
						AND sucursal_destino = vDestino;
					
					END  IF;
				
				
					LET vCodRet1 =  vRetCod;
                    LET vCodRet2 = 'DESCRIPCION  cierres con estatus 0 ' || vRetDetalle;
					
                    RETURN vCodRet1, vCodRet2, vCodRet3;
					
                END IF;
                 LET v_contador = v_contador + 1;
            END FOREACH;
            LET vLog =   'Procesados cierres con estatus 0. ' || v_contador;
			
			UPDATE bdicheq:sc_prog_cierre
			SET 
			estatus = '2'  -- se cambia el estatus a 2 si el proceso corrio exitosamente
			WHERE origen = vOrigen
			AND destino = vDestino
			AND fecha_proceso = vFechaHoy;
			
        END IF;

        -- Procesar estatus 1 y fecha = hoy (reproceso)
        SELECT COUNT(*) INTO vTotal
        FROM sc_prog_cierre
        WHERE estatus = 1 AND fecha_proceso = vFechaHoy;

        IF vTotal > 0 THEN
 
			SELECT origen, destino
            INTO vOrigen, vDestino
            FROM sc_prog_cierre
            WHERE estatus = 1 AND fecha_proceso = vFechaHoy;
				
			SELECT 
				MAX(GREATEST(
					NVL(extrae_cuentas, 0),
					NVL(ejecuta_bdicheq, 0),
					NVL(ejecuta_bdibpi, 0),
					NVL(ejecuta_bdicred, 0),
					NVL(ejecuta_bdicred_crd, 0),
					NVL(ejecuta_bdinteg, 0),
					NVL(ejecuta_bdinvers, 0),
					NVL(ejecuta_bdisolic, 0),
					NVL(ejecuta_bdicheq_comp, 0)
				))  AS status_maximo
			INTO vstatus_maximo
			FROM sc_ctrl_cierre_suc
			WHERE sucursal_origen = vOrigen 
    		AND sucursal_destino = vDestino;

			
            LET v_contador = 0;
			
            FOREACH c1 WITH HOLD FOR
                SELECT origen, destino
                INTO vOrigen, vDestino
                FROM sc_prog_cierre
                WHERE estatus = 1 AND fecha_proceso = vFechaHoy
				
                CALL sp_cierre_reproceso(vOrigen, vDestino,vstatus_maximo)
                RETURNING vRetCod, vRetMsg, vRetDetalle, vstatus;

                --LET vRetCod = '00000';

                IF vRetCod <> '00000' THEN

					IF  vRetCod = -668 THEN
					    
						UPDATE sc_prog_cierre
						SET estatus = '0'
						WHERE origen = vOrigen
						AND destino = vDestino 
						AND fecha_proceso = vFechaHoy;

						UPDATE bdicheq:sc_ctrl_cierre_suc
						SET 
						extrae_cuentas = '0'  -- Nuevo valor para el campo extrae_cuentas
						WHERE sucursal_origen = vOrigen
						AND sucursal_destino = vDestino;
					
					END  IF;
					
                    LET vCodRet1 =  vRetCod;
                    LET vCodRet2 = 'DESCRIPCION Reprocesados cierres con estatus 1' || vRetDetalle;
                    LET vCodRet3 = 'Error en el bloque: ' || vstatus;
					
                    RETURN vCodRet1, vCodRet2, vCodRet3;
                END IF;
                LET v_contador = v_contador + 1;
            END FOREACH;
			
			UPDATE bdicheq:sc_prog_cierre
			SET 
			estatus = '2'  -- se cambia el estatus a 2 si el proceso corrio exitosamente 
			WHERE origen = vOrigen
			AND destino = vDestino
			AND fecha_proceso = vFechaHoy;
			
            LET vLog =  'Reprocesados cierres con estatus 1 : ' || v_contador;
        END IF;

        
        -- Resultado final
        LET vCodRet1 = '00000';
        LET vCodRet2 = 'EJECUCION COMPLETA';
        LET vCodRet3 = vLog;

        RETURN vCodRet1, vCodRet2, vCodRet3;

    END;

END PROCEDURE;