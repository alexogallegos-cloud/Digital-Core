create procedure "informix".consultmovs_bf1(pempresa   char(3),
                                            pcuenta    char(20),
                                            psecuencia smallint)

returning char(5),date,char(40),money(14,2),money(14,2),money(14,2);

    define vtransacc        char(40);
    define vfecha           date;
    define vmonto           money(14,2);
    define vsdoactual       money(14,2);
    define vsdodisp         money(14,2);
    define vserial          integer;
    define vconta           smallint;
    define vciclo           smallint;
    define vcodret          char(5);
    define vsqlerr          integer;
    define vnaturaleza      char(1);
    define vultmovto        smallint;
    define cFech_param      CHAR(10);
    define cFech_param_ini  CHAR(10);
    --RQM 09 704. Se agregan las variables para el retorno de consulta de saldo. EEAP.
	  define cCodRetConsSdo		CHAR(5); --Codigo de retorno de SP de consulta de saldo.
	  define cMensajeRetConsSdo 	CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
	  --RQM 09 704. Se agregan las variables para la consulta de los campos en la maestra de cheques. EEAP.
    define mSdoRetenido  money(14,2);
    define mSdoCong      money(14,2);
    define mSaldoSbc     money(14,2);

    let vcodret    = "000";
    let vtransacc  = " ";
    let vfecha     = " ";
    let vmonto     = 0;
    let vsdoactual = 0;
    let vsdodisp   = 0;
    let vciclo     = 0;
    let vultmovto  = 5;
    --RQM 09 704. Se inicializan las variables para el retorno de consulta de saldo. EEAP.
	  let cCodRetConsSdo		= '00000';
	  let cMensajeRetConsSdo	= '';
	  --RQM 09 704. Se inicializan las variables los campos retornados de la maestra de cheques. EEAP.
    let mSdoRetenido  = 0.00;
    let mSdoCong      = 0.00;
    let mSaldoSbc     = 0.00;		

    begin
    
    on exception set vsqlerr
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            return vcodret, vfecha, vtransacc, vmonto, vsdoactual, vsdodisp;
        end if;
    end exception;
    
    SET ISOLATION TO DIRTY READ;

    --RQM 09 704. Se agrega el campo saldo_sbc en la consulta. EEAP.
    select mc.sdo_actual, mc.sdo_retenido, mc.sdo_cong, mc.saldo_sbc
      into vsdoactual, mSdoRetenido, mSdoCong, mSaldoSbc
      from sc_maechq mc
     where mc.empresa = pempresa 
       and mc.cuenta = pcuenta;
    
    --RQM 09 704. Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion. EEAP
    EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo('', vsdoactual, mSdoRetenido, mSdoCong, mSaldoSbc, null, null, null, 'F', 2) 
    INTO cCodRetConsSdo,cMensajeRetConsSdo,vsdodisp;

    -- RQM 09 704 Se agrega la validacion del codigo de retorno no exitoso(diferente de '00000')
    IF cCodRetConsSdo <> '00000' THEN
        let vsdoactual = 0;
        let vsdodisp = 0;
        let vcodret = '420';    -- Suma de montos erronea.
        return vcodret, vfecha, vtransacc, vmonto, vsdoactual, vsdodisp;
    END IF;  
       
    if vsdoactual is null then
        let vsdoactual = 0;
        let vsdodisp = 0;
        let vcodret = "100";
        return vcodret, vfecha, vtransacc, vmonto, vsdoactual, vsdodisp;
    end if;
    
    -- // Extrae los ultimos 5 movimientos
    foreach
        select md.fech_alt, md.num_serial, md.monto_tot, md.transacc||" "||tr.descripcion, tr.naturaleza
          into vfecha, vserial, vmonto, vtransacc, vnaturaleza
          from sc_movdia md,
               bdinteg:si_transacc tr
         where md.empresa = pempresa 
           and md.cuenta = pcuenta 
           and md.cancelad not in("V","S") 
           and tr.empresa = md.empresa 
           and tr.numero = md.transacc 
           and tr.se_emite_edocta = "S"
         order by fech_alt desc, num_serial desc
         
        let vciclo = vciclo + 1;
        
        if vciclo > vultmovto then
            exit foreach;
        end if;
        
        if vmonto < 0 then
            let vtransacc = "REV "||trim(vtransacc);
        end if;
        
        if vnaturaleza = "C" then
            let vmonto = (vmonto * (-1));
        end if;
        
        return vcodret, vfecha, vtransacc, vmonto, vsdoactual, vsdodisp with resume;
    end foreach;
    
    SELECT valor
      INTO cFech_param
      FROM bdicheq:sc_param
     WHERE empresa = pempresa
       AND codparam = 'fechcon_movhis';
       
    SELECT valor
      INTO cFech_param_ini
      FROM bdicheq:sc_param
     WHERE empresa = pempresa
       AND codparam = 'FechIniCon_movhis_ol';
    
    foreach
        select {+INDEX(bdicheq:sc_movhis idx_movhisnew4)}
               md.fech_alt, md.num_serial, md.monto_tot, md.transacc||" "||tr.descripcion, tr.naturaleza
          into vfecha,vserial,vmonto,vtransacc,vnaturaleza
          from sc_movhis md,
               bdinteg:si_transacc tr
         where md.empresa = pempresa 
           and md.cuenta = pcuenta 
           and md.fech_alt >= cFech_param
           and md.cancelad not in("V","S") 
           and md.transacc = tr.numero
           and tr.empresa = md.empresa 
           and tr.numero = md.transacc 
           and tr.se_emite_edocta = "S"
        union all
        select {+INDEX(bdicheq:sc_movhis_old movhis1)}
               md.fech_alt, md.num_serial, md.monto_tot, md.transacc||" "||tr.descripcion, tr.naturaleza
          from sc_movhis_old md,
               bdinteg:si_transacc tr
         where md.empresa = pempresa 
           and md.cuenta = pcuenta 
           and md.fech_alt >= cFech_param_ini
           and md.fech_alt < cFech_param
           and md.cancelad not in("V","S") 
           and md.transacc = tr.numero
           and tr.empresa = md.empresa 
           and tr.numero = md.transacc 
           and tr.se_emite_edocta = "S"
         order by md.fech_alt desc, md.num_serial desc
         
        let vciclo = vciclo + 1;
        
        if vciclo > vultmovto then
            exit foreach;
        end if;
        
        if vmonto < 0 then
            let vtransacc = "REV "||trim(vtransacc);
        end if;
        
        if vnaturaleza = "C" then
            let vmonto = (vmonto * (-1));
        end if;
        
        return vcodret, vfecha, vtransacc, vmonto, vsdoactual, vsdodisp with resume;
    end foreach;
    
    end;
    
end procedure

DOCUMENT
'MODIFICO : Eric Emilio Armenta Perez',
'FECHA : 09-07-2025',
'MODIFICACION : Se modifica la formula del calculo de saldo disponible para agregar',
'               en su lugar la ejecucion de un SPL que realiza el calculo de forma interna',
'               eviando como parametros los campos retornados en la consulta a la maestra de cheques',
'PROYECTO : RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdicheq',
'VER   : 1.2',
'MODIFIC0:      Donovan F. Torres Landeros',
'FECHA:         10-02-2026',
'MODIFICACION:  Se agrega la validacion de codigo de retorno para el SPL sp_cons_sdodisp_x_tpcalculo',
'               cuando el SPL retorne un codigo diferente a 00000.',
'PROYECTO:      RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD:            bdicheq',
'VER:           1.3';

CREATE PROCEDURE "informix".sp_cobrosbg(pempresa CHAR(3))
RETURNING CHAR(5), CHAR(5), INTEGER, INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcomienza        SMALLINT;
    DEFINE ven_transacc     SMALLINT;
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vfecha           DATE;
    DEFINE vhora            CHAR(15);
    DEFINE vfolio           CHAR(16);
    DEFINE vcuenta          CHAR(20);
    DEFINE vsucursal        CHAR(4);  
    DEFINE vproducto        CHAR(4);
    DEFINE vsuc_cta         CHAR(4);
    DEFINE vsdo_actual      MONEY(18,2);    
    DEFINE vsdo_retenido    MONEY(18,2);    
    DEFINE vsdo_cong        MONEY(18,2);    
    DEFINE vimp_chq_sbg     MONEY(18,2);    
    DEFINE vsdo_disp        MONEY(18,2);
	DEFINE cCodRetIndicador	CHAR(6);
    DEFINE vstatus_cta      CHAR(1);
	DEFINE vfecha_operacion DATE;
	--RQM 09 704. Se agregan las variables para el llamado y retorno de consulta de saldo. DHG.
	DEFINE mSaldoSBC			MONEY(14,2); --Monto del saldo invomilizado (Salvo Buen Cobro).
	DEFINE cCodRetConsSdo		CHAR(5); --Codigo de retorno de SP de consulta de saldo.
	DEFINE cMensajeRetConsSdo 	CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
    
    LET vcodret1	 = '000';
    LET vcodret2     = '000';
    LET sql_err	     = 0;
    LET isam_err     = 0;
    LET vcomienza    = -1;
    LET ven_transacc = 0;
    LET vcontador1   = 0;
    LET vcontador2   = 0;
    LET vfecha  = '';
    LET vhora   = '';
    LET vfolio  = '';
    LET vcuenta       = '';
    LET vsucursal     = '9250';
    LET vproducto     = '';
    LEt vsuc_cta      = '';
    LET vsdo_actual   = 0.00;
    LET vsdo_retenido = 0.00;
    LET vsdo_cong     = 0.00;
    LET vimp_chq_sbg  = 0.00;
    LET vsdo_disp     = 0.00;
	LET cCodRetIndicador  = "000000";
    LET vstatus_cta = '';
	LET vfecha_operacion = TODAY;
	--RQM 09 704. Se inicializan las variables para el llamado y retorno de consulta de saldo. DHG.
	LET mSaldoSBC			= 0.00;
	LET cCodRetConsSdo		= '00000';
	LET cMensajeRetConsSdo	= '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cobrosbg.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcontador1, vcontador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cobrosbg.out";
    --- TRACE ON;
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy
      INTO vfecha
      FROM sc_fechas
     WHERE empresa = pempresa;
    
    LET vhora = CURRENT HOUR TO FRACTION;
    LET vfolio = 'informix'||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];
    
    FOREACH WITH HOLD
	--RQM 09 704.Se agrega la variable del saldo inmovilizado para el calculo del saldo disponible.DHG
        SELECT cuenta, producto, sucursal, sdo_actual, sdo_retenido, sdo_cong, saldo_sbc, imp_chq_sbg, status_cta
          INTO vcuenta, vproducto, vsuc_cta, vsdo_actual, vsdo_retenido, vsdo_cong , mSaldoSBC, vimp_chq_sbg, vstatus_cta
          FROM sc_maechq
         WHERE status_cta NOT IN('2','6','7','8')
           AND imp_chq_sbg > 0.00
        
        IF (vcomienza = -1) THEN
            LET vcomienza = 0;
            LET ven_transacc = 1;
            BEGIN WORK;
        END IF;
        
        LET vcontador1 = vcontador1 + 1;
        
		--RQM 09 704.Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion.DHG
		EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo('',vsdo_actual,vsdo_retenido,vsdo_cong,mSaldoSBC,0.00,0.00,0.00,'F',2) INTO cCodRetConsSdo,cMensajeRetConsSdo,vsdo_disp;
        --LET vsdo_disp = vsdo_actual - (vsdo_retenido + vsdo_cong);
        
		-- RQM 09 704 Se agrega la validacion del codigo de retorno no exitoso(diferente de '00000')
      	IF cCodRetConsSdo <> '00000' THEN
        	let vsdo_disp = 0;
            let vcodret1 = '420';    -- Suma de montos erronea.
            CONTINUE FOREACH;
      	END IF;  

        IF vsdo_disp > 0.00 THEN
        
            IF vsdo_disp >= vimp_chq_sbg THEN

                INSERT INTO sc_movdia VALUES
                ( 0, vfolio, vsucursal, "informix", vfecha, vfecha, vhora, '3247', vsuc_cta, vproducto, pempresa, vcuenta, 
                  " ", 0, vimp_chq_sbg, 0, 0, 0, 0, " ", vstatus_cta, vsdo_actual, '0000', "COBRO PENDIENTE DE SOBREGIRO", 0, " ", "informix", "", vfecha_operacion);
                  
                IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
                    IF ven_transacc = 1 THEN
                        ROLLBACK WORK;
                        BEGIN WORK;
                    ELSE
                        ROLLBACK WORK;
                    END IF;
                    CONTINUE FOREACH;
                END IF;
				
				-- LLAMADO AL SP QUE GENERA LOS INDICADORES DE CAPTACION
				EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(vsucursal,vcuenta,"3247",vimp_chq_sbg,vfecha,"C")
				INTO cCodRetIndicador;
                
                UPDATE sc_maechq
                   SET sdo_actual  = sdo_actual - vimp_chq_sbg,
                       imp_chq_sbg = 0.00
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta;
                
            ELIF vsdo_disp < vimp_chq_sbg THEN
            
                INSERT INTO sc_movdia VALUES
                ( 0, vfolio, vsucursal, "informix", vfecha, vfecha, vhora, '3247', vsuc_cta, vproducto, pempresa, vcuenta, 
                  " ", 0, vsdo_disp, 0, 0, 0, 0, " ", vstatus_cta, vsdo_actual, '0000', "COBRO PENDIENTE DE SOBREGIRO", 0, " ", "informix" , "", vfecha_operacion);
                  
                IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
                    IF ven_transacc = 1 THEN
                        ROLLBACK WORK;
                        BEGIN WORK;
                    ELSE
                        ROLLBACK WORK;
                    END IF;
                    CONTINUE FOREACH;
                END IF;
				
				-- LLAMADO AL SP QUE GENERA LOS INDICADORES DE CAPTACION
				EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(vsucursal,vcuenta,"3247",vsdo_disp,vfecha,"C")
				INTO cCodRetIndicador;
                
                UPDATE sc_maechq
                   SET sdo_actual  = sdo_actual - vsdo_disp,
                       imp_chq_sbg = imp_chq_sbg - vsdo_disp
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta;
                
            END IF;
        
            LET vcontador2 = vcontador2 + 1;
            
        END IF;
        
        COMMIT WORK;
        BEGIN WORK;
        
        LET vcuenta       = '';
        LET vproducto     = '';
        LEt vsuc_cta      = '';
        LET vsdo_actual   = 0.00;
        LET vsdo_retenido = 0.00;
        LET vsdo_cong     = 0.00;
        LET vimp_chq_sbg  = 0.00;
        LET vsdo_disp     = 0.00;
        LET vstatus_cta   = '';
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    END;

    RETURN vcodret1, vcodret2, vcontador1, vcontador2;

END PROCEDURE
DOCUMENT
'MODIFICO: Daniel Hernandez Garcia',
'FECHA: 11-06-2025',
'MODIFICACION: Se modifica la forma de calculo de saldo disponible para considerar un nuevo campo', 
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD: BDICHEQ',
'VERSION: 1.2',
'MODIFICO: Donovan Fernando Torres Landeros',
'FECHA: 09-09-2025',
'MODIFICACION: Se agrega la validacion del codigo de retorno no exitoso(diferente de 00000)', 
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD: BDICHEQ',
'VERSION: 1.3',
'MODIFIC0:      Donovan F. Torres Landeros',
'FECHA:         10-02-2026',
'MODIFICACION:  Se agrega la validacion de codigo de retorno para el SPL sp_cons_sdodisp_x_tpcalculo',
'               cuando el SPL retorne un codigo diferente a 00000.',
'PROYECTO:      RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD:            bdicheq',
'VER:           1.4';

CREATE PROCEDURE "informix".sp_corrige_isr( pEmpresa CHAR(3), pFecha DATE ) 
RETURNING CHAR(5), INTEGER, INTEGER;
    
    DEFINE cCodRet1         CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE cCodRet3         CHAR(50);
    DEFINE iSqlErr          INTEGER;
    DEFINE iSamErr          INTEGER;
    DEFINE cDesErr          CHAR(50);
    DEFINE iTransacc        SMALLINT;
    DEFINE iContador1       INTEGER;
    DEFINE iContador2       INTEGER;
    DEFINE dFechaHoy        DATE;
    DEFINE iAnio            INTEGER;
    DEFINE iResiduo         INTEGER;
    DEFINE iAnioBase        INTEGER;
    DEFINE dTasaISR         DECIMAL(9,6);
    DEFINE dTasa_ISR        DECIMAL(9,6);
    DEFINE cCuenta          CHAR(20);
    DEFINE cProducto        CHAR(4);
    DEFINE mSdoAcum         DECIMAL(18,2);
    DEFINE iDias            SMALLINT;
    DEFINE mIsrCobrado      DECIMAL(18,2);
    DEFINE mSdoPromedio     DECIMAL(18,2);
    DEFINE mBaseExenta      DECIMAL(18,2);
    DEFINE mBaseGravable    DECIMAL(18,2);
    DEFINE mISRCalculado    DECIMAL(14,2);
    DEFINE mDiferenciaISR   DECIMAL(14,2);
    DEFINE cHora            CHAR(15);
    DEFINE cFolio           CHAR(16);
    DEFINE cSucursal        CHAR(4);
    DEFINE cStatusCta       CHAR(1);
    DEFINE cMotivo          CHAR(2);
    DEFINE mSdoActual       DECIMAL(14,2);
    DEFINE mSdoRetenido     DECIMAL(14,2);
    DEFINE mSdoCongelado    DECIMAL(14,2);
    DEFINE mImpChqSbg       DECIMAL(14,2);
    DEFINE mSdoDisponible   DECIMAL(14,2);
    --RQM 09 704. Se agregan las variables para el retorno de consulta de saldo. EEAP.
    DEFINE cCodRetConsSdo   CHAR(5); --Codigo de retorno de SP de consulta de saldo.
    DEFINE cMensajeRetConsSdo   CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
    --RQM 09 704. Se agrega la variable mSaldoSbc para la consulta del campo en la maestra de cheques. EEAP.
    DEFINE mSaldoSbc            MONEY(14,2);
    
    LET cCodRet1        = '000';
    LET cCodRet2        = '';
    LET cCodRet3        = '';
    LET iSqlErr         = 0;
    LET iSamErr         = 0;
    LET cDesErr         = '';
    LET iTransacc       = 0;
    LET iContador1      = 0;
    LET iContador2      = 0;
    LET dFechaHoy       = '01/01/1900';
    LET iAnio           = 0;
    LET iResiduo        = 0;
    LET iAnioBase       = 0;
    LET dTasaISR        = 0.000000;
    LET dTasa_ISR       = 0.000000;
    LET cCuenta         = '';
    LET cProducto       = '';
    LET mSdoAcum        = 0.00;
    LET iDias           = 0;
    LET mIsrCobrado     = 0.00;
    LET mSdoPromedio    = 0.00;
    LET mBaseExenta     = 0.00;
    LET mBaseGravable   = 0.00;
    LET mISRCalculado   = 0.00;
    LET mDiferenciaISR  = 0.00;
    LET cHora           = '';
    LET cFolio          = '';
    LET cSucursal       = '';
    LET cStatusCta      = '';
    LET cMotivo         = '';
    LET mSdoActual      = 0.00;
    LET mSdoRetenido    = 0.00;
    LET mSdoCongelado   = 0.00;
    LET mImpChqSbg      = 0.00;
    LET mSdoDisponible  = 0.00;
    --RQM 09 704. Se inicializan las variables para el retorno de consulta de saldo. EEAP.
    LET cCodRetConsSdo    = '00000';
    LET cMensajeRetConsSdo  = '';
    --RQM 09 704. Se inicializa la variable mSaldoSbc para el campo retornado de la maestra de cheques. EEAP.
    LET mSaldoSbc           = 0.00;
  
  BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_corrige_isr.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            IF iTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN cCodRet1, iContador1, iContador2;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_corrige_isr.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy
      INTO dFechaHoy
      FROM sc_fechas
     WHERE empresa = pEmpresa;
    
    SELECT valor 
    INTO mBaseExenta
      FROM sc_param
   WHERE empresa = pempresa 
     AND codparam = "baseexenta"; 

  IF mBaseExenta is null THEN
    LET mBaseExenta = 0;
  END IF;
       
    LET iAnio = YEAR(pFecha);
    LET iResiduo = MOD(iAnio,4);
    
    IF iResiduo <> 0 THEN
        LET iAnioBase = 365;
    ELSE
        LET iAnioBase = 366;
    END IF;
    
    SELECT valor
      INTO dTasaISR
      FROM bdinteg:si_fechavalor
     WHERE empresa = pEmpresa 
       AND tasa = "I.S.R." 
       AND fecha = ( SELECT MAX(fecha) 
                       FROM bdinteg:si_fechavalor
                      WHERE empresa = pEmpresa 
                        AND tasa = "I.S.R."
                        AND fecha < pFecha );
                        
    LET cHora = CURRENT HOUR TO FRACTION;
    LET cFolio = 'informix'||cHora[1,2]||cHora[4,5]||cHora[7,8]||cHora[10,11];
    
    FOREACH WITH HOLD
        --RQM 09 704. Se agrega el campo saldo_sbc en la consulta. EEAP.
        SELECT {+INDEX(sc_maehis maehis_ffin)}
               his.cuenta, his.producto, his.acum_sdo_pos, his.dia_sdo_pos, his.totisrcobrado,
               mae.sucursal, mae.status_cta, mae.motivo, mae.sdo_actual, mae.sdo_retenido, mae.sdo_cong, mae.imp_chq_sbg, mae.saldo_sbc
          INTO cCuenta, cProducto,  mSdoAcum, iDias, mIsrCobrado,
               cSucursal, cStatusCta, cMotivo, mSdoActual, mSdoRetenido, mSdoCongelado, mImpChqSbg, mSaldoSbc
          FROM sc_maehis his,
               sc_maechq mae
         WHERE his.fechafin = pFecha
           AND his.cuenta = mae.cuenta
           AND his.totisrcobrado <> 0.00
           AND his.producto <> '1200'
           AND mae.cuenta NOT IN(SELECT cuenta FROM sc_movdia WHERE transacc = '3277')
           --- AND mae.status_cta in('1','3','4','5')
        
        BEGIN WORK;
        
        LET iTransacc = 1;
               
        LET mSdoPromedio = mSdoAcum / iDias;
        
        LET mBaseGravable = mSdoPromedio - mBaseExenta;
        
        LET dTasa_ISR = TRUNC( ( ( ( dTasaISR / 100 ) * iDias ) / iAnioBase ), 6 );
        
        --RQM 09 704. Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion. EEAP
        EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo('', mSdoActual, mSdoRetenido, mSdoCongelado, mSaldoSbc, mImpChqSbg, null, null, 'F', 1) INTO cCodRetConsSdo,cMensajeRetConsSdo,mSdoDisponible;
    
    -- RQM 09 704 Se agrega la validacion del codigo de retorno no exitoso(diferente de '00000')
        IF cCodRetConsSdo <> '00000' THEN
          ROLLBACK WORK; 
          LET iTransacc = 0;  
          CONTINUE FOREACH;
        END IF;  


        IF mBaseGravable > 0 THEN
        
            LET mISRCalculado = TRUNC( (mBaseGravable * dTasa_ISR ), 2);
            
            LET mDiferenciaISR = mISRCalculado - mIsrCobrado;
        
            IF ( mDiferenciaISR > 0 AND cStatusCta IN('1','4','5') AND ( mSdoDisponible >= mDiferenciaISR ) ) THEN
                INSERT INTO sc_movdia VALUES
                ( 0, cFolio, cSucursal, 'informix', dFechaHoy, dFechaHoy, current, '3277', cSucursal, cProducto, pEmpresa, cCuenta, '', 
                  0, mDiferenciaISR, mDiferenciaISR, 0.00, 0.00, 0, '', cStatusCta, mSdoActual, '0000', '', 0, '', '', '', dFechaHoy );
                  
                UPDATE sc_maechq
                   SET sdo_actual = sdo_actual - mDiferenciaISR,
                       imp_cgos_mes = imp_cgos_mes + mDiferenciaISR,
                       num_cgos_mes = num_cgos_mes + 1
                 WHERE cuenta = cCuenta;   
                
                LET iContador2 = iContador2 + 1;
            END IF;
            
            UPDATE sc_maehis
               SET totisrcobrado = mIsrCobrado + mDiferenciaISR
             WHERE empresa = pEmpresa
               AND cuenta = cCuenta
               AND fechafin = pFecha;
            
        ELIF mBaseGravable < 0 THEN
            
            LET mDiferenciaISR = mIsrCobrado;
            
            IF ( mDiferenciaISR > 0 AND cStatusCta IN('1','4','5') ) THEN
                INSERT INTO sc_movdia VALUES
                ( 0, cFolio, cSucursal, 'informix', dFechaHoy, dFechaHoy, current, '0242', cSucursal, cProducto, pEmpresa, cCuenta, '', 
                  0, mDiferenciaISR, mDiferenciaISR, 0.00, 0.00, 0, '', cStatusCta, mSdoActual, '0000', '', 0, '', '', '', dFechaHoy );
                  
                UPDATE sc_maechq
                   SET sdo_actual = sdo_actual + mDiferenciaISR,
                       imp_abonos_mes = imp_abonos_mes + mDiferenciaISR,
                       num_abonos_mes = num_abonos_mes + 1
                 WHERE cuenta = cCuenta;   
                
                LET iContador2 = iContador2 + 1;
            END IF;
            
            UPDATE sc_maehis
               SET totisrcobrado = mIsrCobrado - mDiferenciaISR
             WHERE empresa = pEmpresa
               AND cuenta = cCuenta
               AND fechafin = pFecha;
            
        END IF;
        
        LET iContador1 = iContador1 + 1;
        
        COMMIT WORK;
        
        LET iTransacc = 0;
        
        LET cCuenta         = '';
        LET cProducto       = '';
        LET mSdoAcum        = 0.00;
        LET iDias           = 0;
        LET mIsrCobrado     = 0.00;
        LET cSucursal       = '';
        LET cStatusCta      = '';
        LET cMotivo         = '';
        LET mSdoActual      = 0.00;
        LET mSdoRetenido    = 0.00;
        LET mSdoCongelado   = 0.00;
        LET mImpChqSbg      = 0.00;
        LET mSdoPromedio    = 0.00;
        LET mBaseGravable   = 0.00;
        LET dTasa_ISR       = 0.000000;
        LET mSdoDisponible  = 0.00;
        LET mISRCalculado   = 0.00;
        LET mDiferenciaISR  = 0.00;
    END FOREACH;
    
    END;
    
    RETURN cCodRet1, iContador1, iContador2;
    
END PROCEDURE

DOCUMENT 
'MODIFICO : Eric Emilio Armenta Perez',
'FECHA : 01-07-2025',
'MODIFICACION : Se modifica la formula del calculo de saldo disponible para agregar',
'               en su lugar la ejecucion de un SPL que realiza el calculo de forma interna',
'               eviando como parametros los campos retornados en la consulta a la maestra de cheques',
'PROYECTO : RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdicheq',
'VER   : 1.2',
'MODIFIC0:      Donovan F. Torres Landeros',
'FECHA:         10-02-2026',
'MODIFICACION:  Se agrega la validacion de codigo de retorno para el SPL sp_cons_sdodisp_x_tpcalculo',
'               cuando el SPL retorne un codigo diferente a 00000.',
'PROYECTO:      RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD:            bdicheq',
'VER:           1.3';

CREATE PROCEDURE "informix".sp_marcactasinactivas_3anios( pEmpresa char(3) )
RETURNING CHAR(5)  AS vCodRet1, 
          CHAR(5)  AS vCodRet2, 
          CHAR(50) AS vCodRet3, 
          INTEGER  AS vContador1, 
          INTEGER  AS vContador2,  
          INTEGER  AS vContador3,
          INTEGER  AS vContador4;
      
    DEFINE Sql_Err          INTEGER;
    DEFINE Isam_Err         INTEGER;
    DEFINE Desc_Err         CHAR(50);
    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vCodRet3         CHAR(50);
    DEFINE vComienza        INTEGER;
    DEFINE vEnTransacc     SMALLINT;
    DEFINE vContador1       INTEGER;
    DEFINE vContador2       INTEGER;
    DEFINE vContador3       INTEGER;
    DEFINE vContador4       INTEGER;
    
    DEFINE vSql                 CHAR(500);
    DEFINE vStmt                CHAR(250);
    DEFINE vFechaHoy            DATE;
    DEFINE vDiasInformada       INTEGER;
    DEFINE vDiasConcentrada     INTEGER;
    DEFINE vDiasTraspasada      INTEGER;
    DEFINE vTrxCargoConcen      CHAR(4);
    DEFINE vTrxCargoTrasp       CHAR(4);
    DEFINE vTrxAbonoConcen      CHAR(4);
    DEFINE vCtaConcentradora    CHAR(20);
    DEFINE vCtaMinima           CHAR(20);
    DEFINE vCtaMaxima           CHAR(20);
    DEFINE vCuenta              CHAR(20);
    DEFINE vStatusCta           CHAR(1);
    DEFINE vSucursal            CHAR(4);
    DEFINE vSdoActual           DECIMAL(18,2);
    DEFINE vSdoRetenido         DECIMAL(18,2);
    DEFINE vSdoCongelado        DECIMAL(18,2);
    DEFINE vSdoSobregirado      DECIMAL(18,2);
    DEFINE vSdoDispCuenta       DECIMAL(18,2);
    DEFINE vFechaUltimoDep      DATE;
    DEFINE vFechaUltimoRet      DATE;
    DEFINE vFechaAlta           DATE;
    DEFINE vFechaCompara        DATE;
    DEFINE vDiasSinTransacc     INTEGER;
    DEFINE vHora                CHAR(15);
    DEFINE vFolio               CHAR(16);
    DEFINE vCodRetCargo         CHAR(5);
    DEFINE vCodRetAbono         CHAR(5);
    DEFINE vTransaccRetCargo    CHAR(4);
    DEFINE vFechaRetCargo       DATE;
    DEFINE vSdoDispCargo        DECIMAL(18,2);
    DEFINE vMontoRetCargo       DECIMAL(18,2);
    DEFINE vNomProducto         CHAR(40);
    DEFINE vNumCliente          CHAR(20);
    DEFINE vNumTarjeta          CHAR(16);
    DEFINE vNombreCliente       CHAR(104);
    
    -- RQM 09 704. Se agregan las variables para el retorno de consulta de saldo. LEOC.
    DEFINE cCodRetConsSdo               CHAR(5);    -- Codigo de retorno de SP de consulta de saldo.
    DEFINE cMensajeRetConsSdo           CHAR(50);   -- Mensaje de retorno de SP de consulta de saldo.
    DEFINE mSaldoSbc                    MONEY(14,2);    
    LET Sql_Err	     = 0;
    LET Isam_Err     = 0;
    LET Desc_Err     = '';
    LET vCodRet1     = '000';
    LET vCodRet2     = '000';
    LET vCodRet3     = '';
    LET vComienza    = -1;
    LET vEnTransacc = 0;
    LET vContador1   = 0;
    LET vContador2   = 0;
    LET vContador3   = 0;
    LET vContador4   = 0;
    
    LET vSql              = '';
    LET vStmt             = '';
    LET vFechaHoy         = '';
    LET vDiasInformada    = 0;
    LET vDiasConcentrada  = 0;
    LET vDiasTraspasada   = 0;
    LET vTrxCargoConcen   = '';
    LET vTrxCargoTrasp    = '';
    LET vTrxAbonoConcen   = '';
    LET vCtaConcentradora = '';
    LET vCtaMinima        = '';
    LET vCtaMaxima        = '';
    LET vCuenta           = '';   
    LET vStatusCta        = '';
    LET vSucursal         = '';
    LET vSdoActual        = 0.00;
    LET vSdoRetenido      = 0.00;
    LET vSdoCongelado     = 0.00;
    LET vSdoSobregirado   = 0.00;
    LET vSdoDispCuenta    = 0.00;
    LET vFechaUltimoDep   = '';
    LET vFechaUltimoRet   = '';
    LET vFechaAlta        = '';
    LET vFechaCompara     = '';
    LET vDiasSinTransacc  = 0;
    LET vHora             = '';
    LET vFolio            = '';
    LET vCodRetCargo      = '';
    LET vCodRetAbono      = '';
    LET vTransaccRetCargo = '';
    LET vFechaRetCargo    = '';
    LET vSdoDispCargo     = 0.00;
    LET vMontoRetCargo    = 0.00;
    LET vNomProducto      = '';
    LET vNumCliente       = '';
    LET vNumTarjeta       = '';
    LET vNombreCliente    = '';

    -- RQM 09 704. Se inicializan las variables para el retorno de consulta de saldo. LEOC.
    LET cCodRetConsSdo      = '00000';
    LET cMensajeRetConsSdo  = '';
    LET mSaldoSbc           =0.00;
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_marcactasinactivas_3anios.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vEnTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1, vCodRet2, vCodRet3, vContador1, vContador2, vContador3, vContador4;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_marcactasinactivas_3anios.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'ctasinactivas3anios') THEN
        DROP TABLE "informix".ctasinactivas3anios;
    END IF;
    
    CREATE TABLE "informix".ctasinactivas3anios
      (
        cuenta char(20) not null
      )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_ctainact ON "informix".ctasinactivas3anios(cuenta) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE ctasinactivas3anios;
    
    LET vSql = 'echo "LOAD FROM /resplogifx/conciliachq/ctasinactivas3anios.unl DELIMITER ''","'' INSERT INTO ctasinactivas3anios" > /resplogifx/conciliachq/cargactas.sql';
    SYSTEM vSql;
    LET vSql = '';
    
    LET vStmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/cargactas.sql';

    SYSTEM vStmt;
    LET vStmt = '';
    
    UPDATE STATISTICS MEDIUM FOR TABLE ctasinactivas3anios;
    
    -- // OBTINENE LA FECHA DE HOY
    SELECT fecha_hoy
      INTO vFechaHoy
      FROM bdicheq:"informix".sc_fechas
     WHERE empresa = pEmpresa;
     
    -- // OBTIENE EL NUMERO DE DIAS INICIALES PARA CUENTAS INFORMADAS
    SELECT valor::INT
      INTO vDiasInformada
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'DiasIniCtaInformada';
    
    -- // OBTIENE EL NUMERO DE DIAS INICIALES PARA CUENTAS CONCENTRADAS
    SELECT valor::INT
      INTO vDiasConcentrada
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'DiasIniCtaConcentrad';
       
    -- // OBTIENE EL NUMERO DE DIAS INICIALES PARA CUENTAS CONCENTRADAS
    SELECT valor::INT
      INTO vDiasTraspasada
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'DiasIniCtaTraspasada';
       
    -- // OBTIENE TRANSACCION PARA CUENTAS CONCENTRADAS
    SELECT valor
      INTO vTrxCargoConcen
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'TrxCgoCtaConcentrada';
       
    -- // OBTIENE TRANSACCION PARA CUENTAS CONCENTRADAS
    SELECT valor
      INTO vTrxCargoTrasp
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'TrxCgoCtaTraspasada';
        
    -- // OBTIENE TRANSACCION PARA CUENTAS CONCENTRADAS
    SELECT valor
      INTO vTrxAbonoConcen
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'TrxAboCtaConcentrada';
       
    -- // OBTIENE LA CUENTA CONCENTRADORA PARA TRASPASOS POR INACTIVIDAD
    SELECT valor
      INTO vCtaConcentradora
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'CtaConcentradorArt61';
       
    -- // OBTIENE EL NUMERO CUENTA MINIMA Y MAXIMA
    SELECT MIN(cuenta), MAX(cuenta)
      INTO vCtaMinima, vCtaMaxima
      FROM ctasinactivas3anios;

    FOREACH WITH HOLD
        SELECT cuenta
          INTO vCuenta
          FROM ctasinactivas3anios
         WHERE cuenta BETWEEN vCtaMinima AND vCtaMaxima
          
        IF vComienza = -1 THEN
            LET vComienza = 0;
            LET vEnTransacc = 1;
            BEGIN WORK;
        END IF;    
        
        LET vContador1 = vContador1 + 1;

        -- // OBTIENE INFORMACION DE LA CUENTA
        SELECT mae.status_cta, mae.sucursal, mae.sdo_actual, mae.sdo_retenido, mae.sdo_cong, 
               mae.imp_chq_sbg, mae.fecultdep, mae.fecultret, noc.fecha_alta, pro.nombre, mae.num_cte, mae.saldo_sbc
          INTO vStatusCta, vSucursal, vSdoActual, vSdoRetenido, vSdoCongelado, 
               vSdoSobregirado, vFechaUltimoDep, vFechaUltimoRet, vFechaAlta, vNomProducto, vNumCliente, mSaldoSbc
          FROM bdicheq:"informix".sc_maechq mae,
               bdicheq:"informix".sc_maenoc noc,
               bdicheq:"informix".sc_producto pro
         WHERE mae.empresa = pEmpresa
           AND mae.cuenta = vCuenta
           AND noc.empresa = mae.empresa
           AND noc.cuenta = mae.cuenta
           AND pro.empresa = mae.empresa
           AND pro.producto = mae.producto;
           
        -- // VALIDA EL STATSU DE LA CUENTA
        IF vStatusCta IN('2','3','5','6') THEN
            ROLLBACK WORK;
            BEGIN WORK;
            CONTINUE FOREACH;
        END IF;
        
        -- // OBTIENE  FECHA DE ULTIMO DEPOSITO
        IF vFechaUltimoDep is null OR vFechaUltimoDep = '' THEN
            LET vFechaUltimoDep = vFechaAlta;
        END IF;
        
        -- // OBTIENE  FECHA DE ULTIMO RETIRO
        IF vFechaUltimoRet is null OR vFechaUltimoRet = '' THEN
            LET vFechaUltimoRet = vFechaAlta;
        END IF;
        
        -- // OBTIENE FECHA MAS RECIENTE SIN TRANSACCIONAR
        IF vFechaUltimoRet >= vFechaUltimoDep THEN
            LET vFechaCompara = vFechaUltimoRet;
        ELSE
            LET vFechaCompara = vFechaUltimoDep;
        END IF;
        
        LET vDiasSinTransacc = vFechaHoy - vFechaCompara;
        
        -- // MARCA LA CUENTA DEPENDIENDO LA INACTIVIDAD DE LA MISMA
        IF ( vDiasSinTransacc < vDiasInformada ) THEN
        
            COMMIT WORK;
            BEGIN WORK;
            CONTINUE FOREACH;
           
        ELIF ( vDiasSinTransacc >= vDiasInformada AND vDiasSinTransacc < vDiasConcentrada ) THEN
        
            UPDATE bdicheq:"informix".sc_maechq
               SET status_cta = '5', motivo = '14'
             WHERE empresa = pEmpresa
               AND cuenta = vCuenta;
               
            LET vContador2 = vContador2 + 1;
            
            COMMIT WORK;
            BEGIN WORK;
            CONTINUE FOREACH;
            
        ELIF ( vDiasSinTransacc >= vDiasConcentrada AND vDiasSinTransacc < vDiasTraspasada ) THEN
        
            LET vHora = CURRENT HOUR TO FRACTION;
            LET vFolio = 'informix'||vHora[1,2]||vHora[4,5]||vHora[7,8]||vHora[10,11];
            -- LET vSdoDispCuenta = vSdoActual - (vSdoRetenido + vSdoCongelado + vSdoSobregirado);
            -- RQM 09 704. Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion. LEOC
            EXECUTE PROCEDURE bdicheq:"informix".sp_cons_sdodisp_x_tpcalculo(NULL, vSdoActual, vSdoRetenido, vSdoCongelado, mSaldoSbc, vSdoSobregirado, NULL, NULL, 'F', 1) INTO cCodRetConsSdo, cMensajeRetConsSdo, vSdoDispCuenta;

			      -- RQM 09 704 Se agrega la validacion del codigo de retorno no exitoso(diferente de '00000')
      		  IF cCodRetConsSdo <> '00000' THEN
         		   CONTINUE FOREACH;
      		  END IF;  
            
            IF vSdoDispCuenta > 0.00 THEN 
                CALL cargo_ref( pEmpresa, vSucursal, 'informix', vTrxCargoConcen, '0000', vFolio, 
                                vCuenta, 0, vSdoDispCuenta, '01', 'CARGO CUENTA CONCENTRADA', '', '' ) 
                RETURNING vCodRetCargo, vTransaccRetCargo, vFechaRetCargo, vSdoDispCargo, vMontoRetCargo;
                
                IF vCodRetCargo = '000' THEN
                    CALL abono_ref( pEmpresa, vSucursal, 'informix', vTrxAbonoConcen, '0000', vFolio, vCtaConcentradora, 0, 
                                    vSdoDispCuenta, vSdoDispCuenta, 0, 0, 0, '01', 'TRASPASO CTA CONCENTRADA '||vCuenta, '', '' )
                    RETURNING vCodRetAbono;
                    
                    IF vCodRetAbono = '000' THEN
                        
                    END IF;
                END IF;
            END IF;
            
            UPDATE bdicheq:"informix".sc_maechq
               SET status_cta = '6'
             WHERE empresa = pEmpresa
               AND cuenta = vCuenta; 
            
            SELECT NVL(num_tarjeta, ' ')
              INTO vNumTarjeta
              FROM bdicheq:"informix".sc_tarjeta
             WHERE empresa = pEmpresa
               AND cuenta = vCuenta
               AND tipo_tarjeta = 'T'
               AND status_tar = 'A'
               AND secuencia = (SELECT MAX(secuencia)
                                  FROM bdicheq:"informix".sc_tarjeta
                                 WHERE empresa = pEmpresa
                                   AND cuenta = vCuenta
                                   AND tipo_tarjeta = 'T'
                                   AND status_tar = 'A');
                                   
            SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno)
              INTO vNombreCliente
              FROM bdinteg:"informix".si_cliente
             WHERE numcte = vNumCliente;
               
            INSERT INTO bdicheq:"informix".sc_cuentas_concentradas
            (grupo, folio, producto, num_cte, cuenta, tarjeta, cliente, fech_ult_dep, fech_ult_ret, sdo_concentrado, fecha_concentra, int_sdo_concentra, pago_sdo_concentra, fecha_pago_concentra, int_trasp_beneficiencia, sdo_trasp_beneficiencia, fecha_trasp_benefic)
            VALUES
            (pEmpresa, vFolio, vNomProducto, vNumCliente, vCuenta, vNumTarjeta, vNombreCliente, vFechaUltimoDep, vFechaUltimoRet, vSdoDispCuenta, vFechaHoy, null, null, null, null, null, null);
            
            LET vContador3 = vContador3 + 1;
            
            COMMIT WORK;
            BEGIN WORK;
            CONTINUE FOREACH;
                    
        ELIF vDiasSinTransacc >= vDiasTraspasada THEN
        
            LET vHora = CURRENT HOUR TO FRACTION;
            LET vFolio = 'informix'||vHora[1,2]||vHora[4,5]||vHora[7,8]||vHora[10,11];
            -- LET vSdoDispCuenta = vSdoActual - (vSdoRetenido + vSdoCongelado + vSdoSobregirado);
            -- RQM 09 704. Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion. LEOC
            EXECUTE PROCEDURE bdicheq:"informix".sp_cons_sdodisp_x_tpcalculo(NULL, vSdoActual, vSdoRetenido, vSdoCongelado, mSaldoSbc, vSdoSobregirado, NULL, NULL, 'F', 1) INTO cCodRetConsSdo, cMensajeRetConsSdo, vSdoDispCuenta;
   
            -- RQM 09 704 Se agrega la validacion del codigo de retorno no exitoso(diferente de '00000')
      		IF cCodRetConsSdo <> '00000' THEN
         		CONTINUE FOREACH;
      		END IF;  


            UPDATE bdicheq:"informix".sc_maechq
               SET status_cta = '2', motivo = '14', fec_cancelac = vFechaHoy
             WHERE empresa = pEmpresa
               AND cuenta = vCuenta; 
            
            SELECT NVL(num_tarjeta, ' ')
              INTO vNumTarjeta
              FROM bdicheq:"informix".sc_tarjeta
             WHERE empresa = pEmpresa
               AND cuenta = vCuenta
               AND tipo_tarjeta = 'T'
               AND status_tar = 'A'
               AND secuencia = (SELECT MAX(secuencia)
                                  FROM bdicheq:"informix".sc_tarjeta
                                 WHERE empresa = pEmpresa
                                   AND cuenta = vCuenta
                                   AND tipo_tarjeta = 'T'
                                   AND status_tar = 'A');
                                   
            SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno)
              INTO vNombreCliente
              FROM bdinteg:"informix".si_cliente
             WHERE numcte = vNumCliente;
               
            INSERT INTO bdicheq:"informix".sc_cuentas_concentradas
            (grupo, folio, producto, num_cte, cuenta, tarjeta, cliente, fech_ult_dep, fech_ult_ret, sdo_concentrado, fecha_concentra, int_sdo_concentra, pago_sdo_concentra, fecha_pago_concentra, int_trasp_beneficiencia, sdo_trasp_beneficiencia, fecha_trasp_benefic)
            VALUES
            (pEmpresa, vFolio, vNomProducto, vNumCliente, vCuenta, vNumTarjeta, vNombreCliente, vFechaUltimoDep, vFechaUltimoRet, vSdoDispCuenta, vFechaHoy, null, null, null, null, null, null);
            
            LET vContador4 = vContador4 + 1;
            
            COMMIT WORK;
            BEGIN WORK;
            CONTINUE FOREACH;
            
        END IF;
        
        COMMIT WORK;
        BEGIN WORK;
    END FOREACH;
    
    IF vEnTransacc = 1 THEN
        LET vEnTransacc = 0;
        COMMIT WORK;
    END IF;
    
    END;
    
    RETURN vCodRet1, vCodRet2, vCodRet3, vContador1, vContador2, vContador3, vContador4;
    
END PROCEDURE
DOCUMENT
'AUTOR      : N/A',
'BD         : BDICHEQ',
'MODIFICO   : Luis Enrique Orozco Cosme',
'FECHA      : 7 de julio de 2025',
'MODIFICACION: Se modifica el calculo de saldo disponible para homologarlo con el llamado a un nuevo spl sp_cons_sdodisp_x_tpcalculo',
'PROYECTO   : RQM 09 704 Cobranza Automatica en Cuentas de Captacion',
'BD         : BDICHEQ',
'VERSION    : 1.0.1',
'MODIFIC0:      Donovan F. Torres Landeros',
'FECHA:         10-02-2026',
'MODIFICACION:  Se agrega la validacion de codigo de retorno para el SPL sp_cons_sdodisp_x_tpcalculo',
'               cuando el SPL retorne un codigo diferente a 00000.',
'PROYECTO:      RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD:            bdicheq',
'VER:           1.0.2';

Create Procedure "informix".sp_proac_redondeoporcompra()
   returning Char(5), Char(50);

--//Definicion de variables
Define cMensajeRetRet char(50);
Define cCodRet        char(5);
Define isqlerr        integer;
Define iIsamErr       integer;
Define cErrorInfo     char(5);
Define cCuenta_eje    char(20);
Define cCuenta        char(20);
Define dFecha_hoy     date;
Define cMensajeRet    char(50);
Define cTransacCompra char(4);
DEFINE cTransacCompra2 char(4);
Define mMontoCompra   money(14,2);
Define mDecimal       money(18,5);
Define mExcedente     money(18,5);
Define cStatusEje     char(1);
Define mSaldoEje      money(14,2);
Define mRedondeo      money(18,5);
Define cStatusProac   char(1);
Define cTransacCargo  char(4);
Define cTransacAbono  char(4);
Define cSucursal      char(4);
Define cNumeroFolio   char(16);
Define cAceptab       char(1);
Define vusuario       char(8);
Define mSdodisp       money(14,2);
Define cCodRet_sp     char(5);
Define dUltima_ejec   Date;
Define cFolioRev      char(16);
Define cMontoMin      char(4);
Define dFechacargo    date;
--RQM 09 704. Se agregan las variables para el retorno de consulta de saldo. EEAP.
Define cCodRetConsSdo		CHAR(5); --Codigo de retorno de SP de consulta de saldo.
Define cMensajeRetConsSdo 	CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
--RQM 09 704. Se agregan las variables para la consulta de los campos en la maestra de cheques. EEAP.
Define mSdoActual	 money(14,2);
Define mSdoRetenido  money(14,2);
Define mSdoCong      money(14,2);
Define mSaldoSbc     money(14,2);
 
--//Asignacion de variables
Let isqlerr = 0;
Let iIsamErr = 0;
Let cErrorInfo = '';
Let cCuenta_eje  = '';
Let cCuenta = '';
Let dFecha_hoy = '';
Let cMensajeRet = '';
Let cTransacCompra = '';
LET cTransacCompra2 = '';
Let mMontoCompra = 0;
Let mDecimal = 0;
Let mExcedente = 0;
Let cStatusEje = '';
Let mSaldoEje = 0;
Let mRedondeo = 0;
Let cStatusProac = '';
Let cTransacCargo = '';
Let cTransacAbono = '';
Let cSucursal = '';
Let cNumeroFolio = '';
let cAceptab = '' ;
let vusuario = user;
Let mSdodisp = 0;
Let cMensajeRetRet = '';
Let cCodRet = '';
Let cCodRet_sp = '000';
Let dUltima_ejec = '';
Let cFolioRev = '';
Let cMontoMin = '';
Let dFechacargo = '';
--RQM 09 704. Se inicializan las variables para el retorno de consulta de saldo. EEAP.
Let cCodRetConsSdo		= '00000';
Let cMensajeRetConsSdo	= '';
--RQM 09 704. Se inicializan las variables los campos retornados de la maestra de cheques. EEAP.
Let mSdoActual	  = 0.00;
Let mSdoRetenido  = 0.00;
Let mSdoCong      = 0.00;
Let mSaldoSbc     = 0.00;	

--Set debug file to "/tmp/sp_PROAC_RedondeoPorCompra.out";
--trace on;

Begin

	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr != 0 THEN
			LET cCodRet_sp= iSqlErr;
			LET cMensajeRetRet= cErrorInfo;
			ROLLBACK WORK;
			RETURN cCodRet_sp,cMensajeRetRet;
		END IF;
	END EXCEPTION;

	Let cCodRet_sp = '000';
	Let cMensajeRetRet = 'Proceso se ejecuto con exito: ';

	Select fecha_hoy
	Into dFecha_hoy
	From sc_fechas;

	--Valida que proceso no se ejecuto hoy
	If Exists(Select 1 from sc_proacprocesos where fecha_ejec = dfecha_hoy and proceso = 'Redondeo' ) then
		Let cCodRet_sp = '00100';
		Let cMensajeRet = 'Proceso ya ejecutado en fecha: ' || dfecha_hoy;
		Return cCodRet_sp, cMensajeRet;
	End if

	--Transac de Compra conciliada
	Select valor
	Into cTransacCompra
	From sc_param
	Where codparam = 'PROACTRANSCCOMPCONC';
    
    Select valor
	Into cTransacCompra2
	From sc_param
	Where codparam = 'PROACTRANSCCOMPINTE';

	--transac de cargo
	Select valor
	Into cTransacCargo
	From sc_param
	Where codparam = 'PROACTRANSACCCARGO';

	--transac de abono
	Select valor
	Into cTransacAbono
	From sc_param
	Where codparam = 'PROACTRANSACCABONO';
	
	-- monto minimo de compra
	Select valor
	Into cMontoMin
	From sc_param
	Where codparam = 'PROACCOMMAYOR'; 

	--Busca todas las cuentas existentes del programa
	FOREACH WITH HOLD
		Select cta_eje, cuenta, status_cta, sucursal
		Into cCuenta_eje, cCuenta, cStatusProac, cSucursal
		From sc_proac
		Where status_cta = '1'

		Let mMontoCompra = 0;

		--Busca todos los movimientos de la cuenta
		FOREACH WITH HOLD
			Select monto_tot
			Into mMontoCompra
			From sc_movdia
			Where empresa = '001'              --Index idx_movdia1a
			And cuenta = cCuenta_eje            			
			And transacc IN(cTransacCompra, cTransacCompra2)
		
			
			IF mMontoCompra <= cMontoMin then 
				Continue Foreach;			
			END IF		

			--Calculo Redondeo
			Let mRedondeo = 0;
			Let mRedondeo = mMontoCompra / 10;
			--'Let mMontoCompraEntero =  Round (mRedondeo -5); '
			Let mDecimal = trunc (mRedondeo, 5) - trunc (mRedondeo, 0);
			Let mExcedente = mDecimal * 100;
			Let mRedondeo = 100 - mExcedente;
			Let mRedondeo =  mRedondeo / 10;

			--Obtengo el saldo disponible
			--RQM 09 704. Se agrega el campo saldo_sbc en la consulta. EEAP.
			Select sdo_actual, sdo_cong, sdo_retenido, saldo_sbc, status_cta
			Into mSdoActual, mSdoCong, mSdoRetenido, mSaldoSbc, cStatusEje
			From sc_maechq
			Where empresa = '001'
			And Cuenta = cCuenta_eje;	

			--RQM 09 704. Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion. EEAP
    		EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo('', mSdoActual, mSdoRetenido, mSdoCong, mSaldoSbc, null, null, null, 'F', 2) 
    		INTO cCodRetConsSdo,cMensajeRetConsSdo,mSdodisp;	

			-- RQM 09 704 Se agrega la validacion del codigo de retorno no exitoso(diferente de '00000')
      		IF cCodRetConsSdo <> '00000' THEN
         		CONTINUE FOREACH;
      		END IF;  

			If cStatusEje <> 1 Or cStatusProac <> 1 Or mSdodisp < mRedondeo Then
				Continue Foreach;
			End if;

			--Obtengo folio
			Call sp_generafolionomina ("informix") Returning cCodRet, cNumeroFolio;

			--Cargo (eje)
			Call cargo_ref('001', cSucursal, "informix", cTransacCargo, '0250', cNumeroFolio, cCuenta_eje, 0, mRedondeo, '01', 'Cargo x Redondeo ', '','')
			returning cCodRet,cTransacCargo,dFechacargo,mSaldoEje,mRedondeo ;
			
			Let cFolioRev = cNumeroFolio;

			If cCodRet  = '000'  Then
				--Obtengo folio
				Call sp_generafolionomina ("informix") Returning cCodRet, cNumeroFolio;

				--Abono (proac)
				Call abono_ref ('001', cSucursal, "informix", cTransacAbono,'0250', cNumeroFolio, cCuenta, 0 ,mRedondeo, mRedondeo, 0, 0, 0, '01', 'Abono x Redondeo', '0','')
				returning cCodRet;

				Let cMensajeRetRet = 'Proceso se ejecutado con exito: ';

				If cCodRet  <> '000'  Then
					--Reversion al cargo sp reverso();
					Call reversion ('001', cSucursal, "informix",cFolioRev, "C") Returning cCodRet;
					Call reversion ('001', cSucursal, "informix",cNumeroFolio, "C") Returning cCodRet;
					Continue foreach;
				End If

				--obtengo saldo de proac de maestro
				Select nvl(sdo_actual, 0)
				Into mSaldoEje
				From sc_maechq
				Where Cuenta = cCuenta;

				--actualizo nuevo saldo proac  con el del maestro
				Update sc_proac					
				Set saldo = mSaldoEje
				Where cta_eje = cCuenta_eje
				And status_cta = '1';				

			End If;
		End Foreach;
	End Foreach;

	-- Inserta registro de ejecusion
	Insert into sc_proacprocesos (proceso, status, fecha_ejec, hora_ejec) Values ('Redondeo','1',dFecha_hoy, current hour to fraction);
	RETURN cCodRet_sp,cMensajeRetRet;
	
End;
End Procedure
DOCUMENT
'AUTOR		: Yahaira Corona, Carmen orozco Ibarria',
'DESCRIPCION: Genera el proceso de redondeo en las cuentas afiliadas al PROAC',
'FECHA		: Febrero de 2009',
'VERSION	: 20090212',
'BD			: BDICHEQ',
'ModificÃ³	: Abigail Vasavilbazo CaÃ±edo',
'DESCRIPCION: Se cambio la variable para el redondeo',
'FECHA		: Marzo 2009',
'VERSION	: 200903',
'BD			: BDICHEQ',
'ModificÃ³	: Armando Mercado Figueroa',
'DESCRIPCION: Se cambio la consulta a los movimientos de la tabla historica por la tabla de movimientos del dia',
'FECHA		: Abril 2009',
'VERSION	: 200904',
'BD			: BDICHEQ',
'MODIFICO : Eric Emilio Armenta Perez',
'FECHA : 09-07-2025',
'MODIFICACION : Se modifica la formula del calculo de saldo disponible para agregar',
'               en su lugar la ejecucion de un SPL que realiza el calculo de forma interna',
'               eviando como parametros los campos retornados en la consulta a la maestra de cheques',
'PROYECTO : RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdicheq',
'VER   : 1.2',
'MODIFIC0:      Donovan F. Torres Landeros',
'FECHA:         10-02-2026',
'MODIFICACION:  Se agrega la validacion de codigo de retorno para el SPL sp_cons_sdodisp_x_tpcalculo',
'               cuando el SPL retorne un codigo diferente a 00000.',
'PROYECTO:      RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD:            bdicheq',
'VER:           1.3';

CREATE PROCEDURE "informix".sp_verifctasdesconcentradas( pEmpresa char(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER;
       
    DEFINE Sql_Err              INTEGER;
    DEFINE Isam_Err             INTEGER;
    DEFINE Desc_Err             CHAR(50);
    DEFINE vCodRet1             CHAR(5);
    DEFINE vCodRet2             CHAR(5);
    DEFINE vCodRet3             CHAR(50);
    DEFINE vTrxAbierta          SMALLINT;
    DEFINE vContador1           INTEGER;
    DEFINE vContador2           INTEGER;
    DEFINE vFechaHoy            DATE;
    DEFINE vTrxCargo            CHAR(4);
    DEFINE vTrxAbono            CHAR(4);
    DEFINE vCtaNostro           CHAR(20);
    DEFINE vDiasDesConcentra    INTEGER;
    DEFINE vCuenta              CHAR(20);
    DEFINE vStatusCta           CHAR(1);
    DEFINE vSucursal            CHAR(4);
    DEFINE vNumCliente          CHAR(20);
    DEFINE vProducto            CHAR(4);
    DEFINE vSdoActual           DECIMAL(18,2);
    DEFINE vSdoRetenido         DECIMAL(18,2);
    DEFINE vSdoCongelado        DECIMAL(18,2);
    DEFINE vSdoSobregirado      DECIMAL(18,2);
    DEFINE vFechaUltimoDep      DATE;
    DEFINE vFechaUltimoRet      DATE;
    DEFINE vFechaDesConcentra   DATE;
    DEFINE vDiasSinTransacc     INTEGER;    
    DEFINE vSdoDispCuenta       DECIMAL(18,2);
    DEFINE vHora                CHAR(15);
    DEFINE vFolio               CHAR(16);
    DEFINE vHoraTrx             CHAR(15);
    DEFINE vProdNostro          CHAR(4);
    DEFINE vSucNostro           CHAR(4);
    DEFINE vSdoNostro           DECIMAL(18,2);
    DEFINE vInsTrxCargo         CHAR(1);
    DEFINE vUpdTrxCargo         CHAR(1);
    DEFINE vInsTrxAbono         CHAR(1);
    DEFINE vUpdTrxAbono         CHAR(1);
    DEFINE vUpdCuenta           CHAR(1);
    DEFINE vUpdConcen           CHAR(1);
    DEFINE vUpdCtaDesc          CHAR(1);
	DEFINE vFechaOperacion   	DATE;
    --RQM 09 704. Se agregan las variables para el retorno de consulta de saldo. EEAP.
    DEFINE cCodRetConsSdo		CHAR(5); --Codigo de retorno de SP de consulta de saldo.
    DEFINE cMensajeRetConsSdo 	CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
    --RQM 09 704. Se agrega la variable mSaldoSbc para la consulta del campo en la maestra de cheques. EEAP.
    DEFINE mSaldoSbc            MONEY(14,2);

    
    LET Sql_Err	            = 0;
    LET Isam_Err            = 0;
    LET Desc_Err            = '';
    LET vCodRet1            = '000';
    LET vCodRet2            = '000';
    LET vCodRet3            = '';
    LET vTrxAbierta         = 0;
    LET vContador1          = 0;
    LET vContador2          = 0;
    LET vFechaHoy           = '';
    LET vTrxCargo           = '';
    LET vTrxAbono           = '';
    LET vCtaNostro          = '';
    LET vDiasDesConcentra   = 0;
    LET vCuenta             = '';   
    LET vStatusCta          = '';
    LET vSucursal           = '';
    LET vNumCliente         = '';
    LET vProducto           = '';
    LET vSdoActual          = 0.00;
    LET vSdoRetenido        = 0.00;
    LET vSdoCongelado       = 0.00;
    LET vSdoSobregirado     = 0.00;
    LET vFechaUltimoDep     = '';
    LET vFechaUltimoRet     = '';
    LET vFechaDesConcentra  = '';
    LET vDiasSinTransacc    = 0;
    LET vSdoDispCuenta      = 0.00;
    LET vHora               = '';
    LET vFolio              = '';
    LET vHoraTrx            = '';
    LET vProdNostro         = '';
    LET vSucNostro          = '';
    LET vSdoNostro          = 0.00;
    LET vInsTrxCargo        = '0';
    LET vUpdTrxCargo        = '0';
    LET vInsTrxAbono        = '0';
    LET vUpdTrxAbono        = '0';
    LET vUpdCuenta          = '0';
    LET vUpdConcen          = '0';
    LET vUpdCtaDesc         = '0';
	LET vFechaOperacion   	= TODAY;
    --RQM 09 704. Se inicializan las variables para el retorno de consulta de saldo. EEAP.
    LET cCodRetConsSdo		= '00000';
    LET cMensajeRetConsSdo	= '';
    --RQM 09 704. Se inicializa la variable mSaldoSbc para el campo retornado de la maestra de cheques. EEAP.
    LET mSaldoSbc           = 0.00;
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_verifctasdesconcentradas.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vTrxAbierta = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1, vCodRet2, vCodRet3, vContador1, vContador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_verifctasdesconcentradas.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    -- // OBTINENE LA FECHA DE HOY
    SELECT fecha_hoy
      INTO vFechaHoy
      FROM sc_fechas
     WHERE empresa = pEmpresa;
     
    -- // OBTIENE TRANSACCION DE CARGO PARA CUENTAS CONCENTRADAS
    SELECT valor
      INTO vTrxCargo
      FROM sc_param
     WHERE empresa = pEmpresa
      AND codparam = 'TrxCgoCtaConcentrada';

    -- // OBTIENE TRANSACCION DE ABONO PARA CUENTAS CONCENTRADAS
    SELECT valor
      INTO vTrxAbono
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'TrxAboCtaConcentrada';

    -- // OBTIENE LA CUENTA CONCENTRADORA PARA TRASPASOS POR INACTIVIDAD
    SELECT valor
      INTO vCtaNostro
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'CtaConcentradorArt61';
     
    -- // OBTIENE EL NUMERO DE DIAS PARA VOLVER A CONCENTRAR
    SELECT valor::INT
      INTO vDiasDesConcentra
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'DiasCtasDesConcentra';
    
    FOREACH WITH HOLD
        -- // OBTIENE DATOS DE LA CUENTA A CONCENTRAR
        --RQM 09 704. Se agrega el campo saldo_sbc en la consulta. EEAP.
		SELECT mae.cuenta, mae.status_cta, mae.sucursal, mae.num_cte, mae.producto, 
               mae.sdo_actual, mae.sdo_retenido, mae.sdo_cong, mae.imp_chq_sbg, 
               mae.fecultdep, mae.fecultret, con.fecha_pago_concentra, mae.saldo_sbc
          INTO vCuenta, vStatusCta, vSucursal, vNumCliente, vProducto, 
               vSdoActual, vSdoRetenido, vSdoCongelado, vSdoSobregirado, 
               vFechaUltimoDep, vFechaUltimoRet, vFechaDesConcentra, mSaldoSbc
          FROM sc_maechq mae,
               sc_cuentas_concentradas con
         WHERE mae.empresa = pEmpresa
           AND mae.status_cta = '8'
           AND con.cuenta = mae.cuenta
    
        BEGIN WORK;
        LET vTrxAbierta = 1;
        
        LET vContador1 = vContador1 + 1;
        
        LET vDiasSinTransacc = 0;
        LET vSdoDispCuenta   = 0;
        LET vInsTrxCargo     = '0';
        LET vUpdTrxCargo     = '0';
        LET vInsTrxAbono     = '0';
        LET vUpdTrxAbono     = '0';
        LET vUpdCuenta       = '0';
        LET vUpdConcen       = '0';
        LET vUpdCtaDesc      = '0';
        
        LET vDiasSinTransacc = vFechaHoy - vFechaDesConcentra;
        
		IF ( vDiasSinTransacc > vDiasDesConcentra ) THEN
            --RQM 09 704. Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion. EEAP
            EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo('', vSdoActual, vSdoRetenido, vSdoCongelado, mSaldoSbc, vSdoSobregirado, null, null, 'F', 1) INTO cCodRetConsSdo,cMensajeRetConsSdo,vSdoDispCuenta;
			
            -- RQM 09 704 Se agrega la validacion del codigo de retorno no exitoso(diferente de '00000')
      		IF cCodRetConsSdo <> '00000' THEN
                ROLLBACK WORK;
                LET vTrxAbierta = 0;
         		CONTINUE FOREACH;
      		END IF;  
            
			IF vSdoDispCuenta > 0.00 THEN 
				LET vHora = CURRENT HOUR TO FRACTION;
				LET vFolio = 'informix'||vHora[1,2]||vHora[4,5]||vHora[7,8]||vHora[10,11];
			
				LET vHoraTrx = CURRENT HOUR TO FRACTION(3);
            
                INSERT INTO sc_movdia VALUES
                ( 0, vFolio, '9250' , 'informix', vFechaHoy, vFechaHoy, vHoraTrx, vTrxCargo, vSucursal, vProducto, pEmpresa, vCuenta, '', 0, 
                  vSdoDispCuenta, 0.00, 0.00, 0.00, 0, '', '', vSdoActual, '0000' , 'CONCENTRACION POR INACTIVIDAD ART 61 LIC', 0, '', '', '', vFechaOperacion);
                  
                IF dbinfo('sqlca.sqlerrd2') > 0 THEN
                    LET vInsTrxCargo = '1';
                END IF;
                
                UPDATE sc_maechq
                   SET sdo_actual   = sdo_actual - vSdoDispCuenta,
                       imp_cgos_mes = imp_cgos_mes + vSdoDispCuenta,
                       num_cgos_mes = num_cgos_mes + 1,
                       fec_ult_mov  = vFechaHoy
                 WHERE empresa = pEmpresa
                   AND cuenta = vCuenta; 
                   
                IF dbinfo('sqlca.sqlerrd2') > 0 THEN
                    LET vUpdTrxCargo = '1';
                END IF;
                
                IF vInsTrxCargo = '1' AND vUpdTrxCargo = '1' THEN
                    SELECT producto, sucursal, sdo_actual
                      INTO vProdNostro, vSucNostro, vSdoNostro
                      FROM sc_maechq 
                     WHERE empresa = pEmpresa
                       AND cuenta = vCtaNostro;
                       
                    LET vHoraTrx = CURRENT HOUR TO FRACTION(3);
                    
                    INSERT INTO sc_movdia VALUES
                    ( 0, vFolio, '9250', 'informix', vFechaHoy, vFechaHoy, vHoraTrx, vTrxAbono, vSucNostro, vProdNostro, pEmpresa, vCtaNostro, '', 0, 
                      vSdoDispCuenta, vSdoDispCuenta, 0.00, 0.00, 0, '', '', vSdoNostro, '0000', 'ABONO X CONCENTRACION DE CTA '||TRIM(vCuenta), 0, '', '', '', vFechaOperacion);
                              
                    IF dbinfo('sqlca.sqlerrd2') > 0 THEN 
                        LET vInsTrxAbono = '1'; 
                    END IF;
                    
                    UPDATE sc_maechq
                       SET sdo_actual = sdo_actual + vSdoDispCuenta,
                           imp_abonos_mes = imp_abonos_mes + vSdoDispCuenta, 
                           num_abonos_mes = num_abonos_mes + 1,
                           fec_ult_mov = vFechaHoy,
                           fecultdep = vFechaHoy
                     WHERE empresa = pEmpresa 
                       AND cuenta = vCtaNostro;
                                   
                    IF dbinfo('sqlca.sqlerrd2') > 0 THEN 
                        LET vUpdTrxAbono = '1'; 
                    END IF;
                    
                    IF vInsTrxAbono = '1' AND vUpdTrxAbono = '1' THEN
                        UPDATE sc_cuentas_concentradas
                           SET folio = vFolio,
                               sdo_concentrado = vSdoDispCuenta
                         WHERE cuenta = vCuenta;
                        
                        IF dbinfo('sqlca.sqlerrd2') > 0 THEN
                            LET vUpdConcen = '1';
                        END IF;
                        
                        UPDATE sc_maechq
						   SET status_cta = '6'
						 WHERE empresa = pEmpresa
						   AND cuenta = vCuenta; 
                           
                        IF dbinfo('sqlca.sqlerrd2') > 0 THEN
                            LET vUpdCuenta = '1';
                        END IF;
                        
                        INSERT INTO sc_ctasdescon_concentradas
                        ( num_cte, producto, cuenta, status_cta, sdo_actual, fech_ult_dep, fech_ult_ret, fecha_desmar, fecha_marc )
                        VALUES
                        ( vNumCliente, vProducto, vCuenta, vStatusCta, vSdoActual, vFechaUltimoDep, vFechaUltimoRet, vFechaDesConcentra, vFechaHoy );
                        
                        IF dbinfo('sqlca.sqlerrd2') > 0 THEN
                            LET vUpdCtaDesc = '1';
                        END IF;
                        
                        IF vUpdConcen = '1' AND vUpdCuenta = '1' AND vUpdCtaDesc = '1' THEN
                            LET vContador2 = vContador2 + 1;
                        ELSE
                            ROLLBACK WORK;
                            LET vTrxAbierta = '0';
                            CONTINUE FOREACH;
                        END IF;
                    ELSE
                        ROLLBACK WORK;
                        LET vTrxAbierta = '0';
                        CONTINUE FOREACH;
                    END IF;
                ELSE
                    ROLLBACK WORK;
                    LET vTrxAbierta = '0';
                    CONTINUE FOREACH;
                END IF;
            ELSE
                ROLLBACK WORK;
                LET vTrxAbierta = '0';
                CONTINUE FOREACH;
            END IF;
        ELSE
            ROLLBACK WORK;
            LET vTrxAbierta = '0';
            CONTINUE FOREACH;
        END IF; 
        
        COMMIT WORK;
        LET vTrxAbierta = '0';
    END FOREACH;
    
    END;
     
    RETURN vCodRet1, vCodRet2, vCodRet3, vContador1, vContador2;
     
END PROCEDURE

DOCUMENT 
'MODIFICO : Eric Emilio Armenta Perez',
'FECHA : 01-07-2025',
'MODIFICACION : Se modifica la formula del calculo de saldo disponible para agregar',
'               en su lugar la ejecucion de un SPL que realiza el calculo de forma interna',
'               eviando como parametros los campos retornados en la consulta a la maestra de cheques',
'PROYECTO : RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdicheq',
'VER   : 1.2',
'MODIFIC0:      Donovan F. Torres Landeros',
'FECHA:         10-02-2026',
'MODIFICACION:  Se agrega la validacion de codigo de retorno para el SPL sp_cons_sdodisp_x_tpcalculo',
'               cuando el SPL retorne un codigo diferente a 00000.',
'PROYECTO:      RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD:            bdicheq',
'VER:           1.3';

CREATE PROCEDURE "informix".sp_actparampasecheq(pempresa CHAR(3))
RETURNING CHAR(5);
    
    --- ################################################################################
    --- ##  Nombre:              sp_actparampasecheq                                  ##
    --- ##  Version:             2.0                                                  ##
    --- ##  Objetivo:            Programa del pase contable de captacion              ##
    --- ##  Creado por:                                                               ##
    --- ##  Modificado por:      Ivan Escorza                                         ##
    --- ##  Ultima Modificacion: Marzo 2026                                           ##
    --- ################################################################################

    DEFINE vcodret       CHAR(5);
    DEFINE vcodret2      CHAR(5);
    DEFINE vcodret3      VARCHAR(50);
    DEFINE vsqlerr       INTEGER;
    DEFINE isam_err      INTEGER;
    DEFINE error_info    VARCHAR(50);
    DEFINE vpromedio     INTEGER;
    DEFINE vcont         SMALLINT;
    DEFINE vbrinca       INTEGER;
    DEFINE vserial       INTEGER;
    DEFINE vparam_serial VARCHAR(60);
    
    LET vcodret          = "000";
    LET vcodret2         = "000";
    LET vcodret3         = " ";
    LET vsqlerr          = 0;
    LET isam_err         = 0;
    LET error_info       = '';
    LET vpromedio        = 0;
    LET vcont            = 0;
    LET vbrinca          = 0;
    LET vserial          = 0;
    LET vparam_serial    = '';
    
    BEGIN

    ON EXCEPTION SET vsqlerr, isam_err, error_info
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actparampasecheq.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET vcodret2 = isam_err;
            LET vcodret3 = error_info;
            RETURN vcodret;
        END IF;
    END EXCEPTION;

    ---	SET DEBUG FILE TO "/home/c98789058/SPL_ACCENTURE/sp_actparampasecheq.out";
    ---	TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

     SELECT ROUND(COUNT(*)/6)
      INTO vpromedio
      FROM bdicheq:sc_movdia_concil
	  WHERE num_serial > 0;  

    LET vcont = 1;  
    
    WHILE vcont <= 5         
        IF vcont = 1 THEN
            LET vbrinca = vpromedio;

            FOREACH CurIni WITH HOLD FOR
				--Se quita el filtro de campo 'empresa', se tiene INDEX PATH
                SELECT SKIP vbrinca FIRST 1 num_serial
                  INTO vserial
                  FROM bdicheq:sc_movdia_concil
                 WHERE num_serial > 0
                 ORDER BY num_serial 

                LET vparam_serial = vserial;
                
                UPDATE bdicheq:sc_param
                   SET valor = vparam_serial
                 WHERE codparam = 'SerialIniPaseChqCom1';

            END FOREACH;

        ELIF vcont = 2 THEN
            LET vbrinca = vpromedio * 2;

            FOREACH CurIni WITH HOLD FOR
				--Se quita el filtro de campo 'empresa', se tiene INDEX PATH
                SELECT SKIP vbrinca FIRST 1 num_serial
                  INTO vserial
                  FROM bdicheq:sc_movdia_concil
                 WHERE num_serial > 0 
                 ORDER BY num_serial
 
                LET vparam_serial = vserial;
                 
                 UPDATE bdicheq:sc_param
                   SET valor = vparam_serial
                 WHERE codparam = 'SerialIniPaseChqCom2';
 
            END FOREACH;

        ELIF vcont = 3 THEN
            LET vbrinca = vpromedio * 3;

            FOREACH CurIni WITH HOLD FOR
				--Se quita el filtro de campo 'empresa', se tiene INDEX PATH
                SELECT SKIP vbrinca FIRST 1 num_serial
                  INTO vserial
                  FROM bdicheq:sc_movdia_concil
                 WHERE num_serial > 0
                 ORDER BY num_serial

                LET vparam_serial = vserial;
    
                UPDATE bdicheq:sc_param
                   SET valor = vparam_serial
                 WHERE codparam = 'SerialIniPaseChqCom3';
  
            END FOREACH;

        ELIF vcont = 4 THEN
            LET vbrinca = vpromedio * 4;

            FOREACH CurIni WITH HOLD FOR
				--Se quita el filtro de campo 'empresa', se tiene INDEX PATH
                SELECT SKIP vbrinca FIRST 1 num_serial
                  INTO vserial
                  FROM bdicheq:sc_movdia_concil
                 WHERE num_serial > 0 
                 ORDER BY num_serial
 
                LET vparam_serial = vserial;
     
                UPDATE bdicheq:sc_param
                   SET valor = vparam_serial
                 WHERE codparam = 'SerialIniPaseChqCom4';

            END FOREACH;

        ELIF vcont = 5 THEN
            LET vbrinca = vpromedio * 5;

            FOREACH CurIni WITH HOLD FOR
				--Se quita el filtro de campo 'empresa', se tiene INDEX PATH
                SELECT SKIP vbrinca FIRST 1 num_serial
                  INTO vserial
                  FROM bdicheq:sc_movdia_concil
                 WHERE num_serial > 0 
                 ORDER BY num_serial

                LET vparam_serial = vserial;
                 
                UPDATE bdicheq:sc_param
                   SET valor = vparam_serial
                 WHERE codparam = 'SerialIniPaseChqCom5'; 
            END FOREACH;
        END IF;
        LET vcont = vcont + 1;  
        LET vserial = 0;
        LET vparam_serial = '';
    END WHILE;    

    RETURN vcodret;

    END;

END PROCEDURE;