CREATE PROCEDURE "informix".cargo_retenido_cong(pempresa char(3))

RETURNING CHAR(5), CHAR(5), INTEGER, INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE nComit           SMALLINT;
    DEFINE vcuantos         INTEGER;
    DEFINE vcargados        INTEGER;
    
    DEFINE vfecha_hoy       DATE;
    DEFINE vhora            CHAR(15);
    DEFINE vsql             CHAR(200);
    DEFINE vfolio           CHAR(20);
    DEFINE vcuenta          CHAR(20);
    DEFINE vstatus          CHAR(1);
    DEFINE vimporte         MONEY(18,2);
    DEFINE vsdo_cong        MONEY(18,2);
    DEFINE vmaxsec          SMALLINT;
    DEFINE vtarjeta         CHAR(16);
    DEFINE vsucursal        CHAR(4);
    DEFINE vexiste          INTEGER;
    DEFINE vmotivo          CHAR(2);
    DEFINE vproducto        CHAR(4);
    DEFINE vsdo_actual      MONEY(18,2);
    DEFINE vsdo_cong_res    MONEY(18,2);
    DEFINE vsdo_disponible  MONEY(18,2);
    DEFINE vreferencia      CHAR(40);
    DEFINE vimporte_ori     MONEY(18,2);
    DEFINE vfechadescarga   CHAR(8);
    DEFINE vnombre          VARCHAR(50);
    --RQM 09 704. Se agregan las siguientes variable DFTL 
    DEFINE vsdo_retenido    MONEY(18,2);
    DEFINE mSaldoSbc        MONEY(18,2);
    DEFINE cCodRetConsSdo       CHAR(5); --Codigo de retorno de SP de consulta de saldo.
    DEFINE cMensajeRetConsSdo   CHAR(50); --Mensaje de retorno de SP de consulta de saldo.

    BEGIN

    ON EXCEPTION SET sql_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/cargo_retenido_cong.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            IF nComit = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcuantos, vcargados;
        END IF;
    END EXCEPTION;

    ---  SET DEBUG FILE TO "/home/c90402536/Traza/cargo_retenido_cong_modif.out";
    ---  TRACE ON; 

    LET vcodret1  = "000";
    LET vcodret2  = "000";
    LET sql_err   = 0;
    LET isam_err  = 0;
    LET nComit    = 0;
    LET vcuantos  = -1;
    LET vcargados = -1;
    
    LET vfecha_hoy      = '';
    LET vhora           = '';
    LET vfolio          = '';
    LET vcuenta         = ''; 
    LET vimporte        = 0.00;
    LET vsdo_cong       = 0.00;
    LET vsucursal       = '';
    LET vstatus         = '';
    LET vmaxsec         = '';
    LET vtarjeta        = '';
    LET vexiste         = '';
    LET vmotivo         = '';
    LET vproducto       = '';
    LET vsdo_actual     = 0.00;
    LET vsdo_cong_res   = 0.00;
    LET vsdo_disponible = 0.00;
    LET vreferencia     = '';
    LET vimporte_ori    = 0.00;
    --RQM 09 704. Se agregan las siguientes variable DFTL 
    LET vsdo_retenido    = 0.00;
    LET mSaldoSbc        = 0.00;
    LET cCodRetConsSdo      = '00000';
    LET cMensajeRetConsSdo  = '';
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS(SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'cuentas_cong') THEN
        DROP TABLE "informix".cuentas_cong;
    END IF;
    
    CREATE TABLE "informix".cuentas_cong(
        cuenta      char(20) not null,
        importe     money(14,2) not null,
        referencia  char(40) )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_ctascong ON cuentas_cong(cuenta) USING BTREE;   
    
    LET vsql = '';
    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/congeladas_ref_aplicar.unl DELIMITER ''","'' INSERT INTO cuentas_cong" > /resplogifx/conciliachq/ctasxret.sql';
    SYSTEM vsql;
    LET vsql = '';
    LET vsql = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctasxret.sql';
    --- LET vsql = 'dbaccess bdicheq /resplogifx/conciliachq/ctasxret.sql';
    SYSTEM vsql;
    
    UPDATE STATISTICS MEDIUM FOR TABLE cuentas_cong;
    
    IF EXISTS(SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'cargos_cong') THEN
        DROP TABLE "informix".cargos_cong;
    END IF;
    
    CREATE TABLE "informix".cargos_cong(
        cuenta char(20) not null,
        importe money(14,2)not null,
        referencia  char(40),
        cargado money(14,2)not null )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_cgocong ON cargos_cong(cuenta) USING BTREE;            
    
    UPDATE STATISTICS MEDIUM FOR TABLE cargos_cong;

    SELECT fecha_hoy
      INTO vfecha_hoy
      FROM sc_fechas
     WHERE empresa = pempresa;

    LET vhora = CURRENT HOUR TO FRACTION;
    LET vfolio = "informix"||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];
    
    FOREACH WITH HOLD
        SELECT cuenta, importe, referencia
          INTO vcuenta, vimporte, vreferencia
          FROM cuentas_cong
           
        IF vcuantos = -1 THEN
            LET nComit = 1;
            LET vcuantos = 0;
            LET vcargados = 0;
            BEGIN WORK;
        END IF;
        
        SELECT sdo_actual, sdo_cong, sdo_cong - vimporte, sdo_retenido, saldo_sbc,
               sucursal, status_cta, motivo, producto
          INTO vsdo_actual, vsdo_cong, vsdo_cong_res, vsdo_retenido, mSaldoSbc,
               vsucursal, vstatus, vmotivo, vproducto
          FROM sc_maechq
         WHERE empresa = pempresa
           AND cuenta = vcuenta;
           
        SELECT MAX(secuencia)
          INTO vmaxsec
          FROM sc_tarjeta
         WHERE empresa = pempresa
           AND cuenta = vcuenta
           AND tipo_tarjeta = 'T';

        SELECT num_tarjeta
          INTO vtarjeta
          FROM sc_tarjeta
         WHERE empresa = pempresa
           AND cuenta = vcuenta
           AND secuencia = vmaxsec;
        
        IF vsdo_cong >= vimporte THEN
        
            INSERT INTO sc_movdia VALUES
            (0, vfolio, '9290', 'intercar', vfecha_hoy, vfecha_hoy, vhora, '0830', 
             vsucursal, vproducto, pempresa, vcuenta, null, 0, vimporte, 0.00, 0.00, 
             0.00, 0, null, null, vsdo_actual, '0830', vreferencia, 0, vtarjeta, null, "");
             
            IF vsdo_cong_res = 0.00 THEN 
                UPDATE sc_maechq
                   SET sdo_actual = sdo_actual - vimporte,
                       sdo_cong = 0.00,
                       status_cta = '1',
                       motivo = null
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta;
                   
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
                   AND status_blo = 'B'
                   AND tipo_mov = 'B'
                   AND empresa = pempresa;

                IF vexiste <> 0 THEN
                    INSERT INTO sc_histbloq VALUES
                    (pempresa, vcuenta, 'D', '00', null, 0.00, 'informix', 
                     vfecha_hoy, current hour to fraction, 'infor', 'D', vfolio, ' ');
                END IF;
            ELSE 
                UPDATE sc_maechq
                   SET sdo_actual = sdo_actual - vimporte,
                       sdo_cong = vsdo_cong_res,
                       status_cta = '3',
                       motivo = '09'
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta;
                
                SELECT COUNT(*)
                  INTO vexiste
                  FROM sc_ctabloqueo
                 WHERE cuenta = vcuenta;
                 
                IF vexiste = 0 THEN 
                    INSERT INTO sc_ctabloqueo VALUES(vcuenta, '09', '1');
                ELSE 
                    UPDATE sc_ctabloqueo
                       SET clave = '09',
                           opcion = '1'
                     WHERE cuenta = vcuenta;
                END IF;
                
                INSERT INTO sc_ctabloqueohist VALUES (vcuenta, '09', '1');

                SELECT COUNT(*)
                  INTO vexiste
                  FROM sc_histbloq
                 WHERE cuenta = vcuenta
                   AND status_blo = 'B'
                   AND tipo_mov = 'B'
                   AND empresa = pempresa;

                IF vexiste <> 0 THEN
                    INSERT INTO sc_histbloq VALUES
                    (pempresa, vcuenta, 'D', '00', null, 0.00, 'informix', 
                     vfecha_hoy, current hour to fraction, 'infor', 'D', vfolio, ' ');
                END IF;
                 
                INSERT INTO sc_histbloq VALUES
                (pempresa, vcuenta, 'B', '09', 1, vsdo_cong_res, 'informix',
                 vfecha_hoy, current hour to fraction, 'infor', 'B', vfolio, " ");
            END IF;    
            
            INSERT INTO cargos_cong VALUES (vcuenta, vimporte, vreferencia, vimporte);
            
            LET vcargados = vcargados + 1;
        ELSE    
            EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo('', vsdo_actual, vsdo_retenido, null, mSaldoSbc, null, null, null, 'F', '3') 
            INTO cCodRetConsSdo, cMensajeRetConsSdo, vsdo_disponible;

            
            IF vsdo_disponible > 0.00 THEN 
            
                IF vsdo_disponible >= vimporte THEN
                
                    INSERT INTO sc_movdia VALUES
                    (0, vfolio, '9290', 'intercar', vfecha_hoy, vfecha_hoy, vhora, '0830', 
                     vsucursal, vproducto, pempresa, vcuenta, null, 0, vimporte, 0.00, 0.00, 
                     0.00, 0, null, null, vsdo_actual, '0830', vreferencia, 0, vtarjeta, null, "");

                    UPDATE sc_maechq
                       SET sdo_actual = sdo_actual - vimporte,
                           sdo_cong = 0.00,
                           status_cta = '1',
                           motivo = null
                     WHERE empresa = pempresa
                       AND cuenta = vcuenta;
                       
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
                       AND status_blo = 'B'
                       AND tipo_mov = 'B'
                       AND empresa = pempresa;

                    IF vexiste <> 0 THEN
                        INSERT INTO sc_histbloq VALUES
                        (pempresa, vcuenta, 'D', '00', null, 0.00, 'informix', 
                         vfecha_hoy, current hour to fraction, 'infor', 'D', vfolio, ' ');
                    END IF;
                       
                    INSERT INTO cargos_cong VALUES (vcuenta, vimporte, vreferencia, vimporte);
                    
                    LET vcargados = vcargados + 1;
                ELSE 
                    LET vimporte_ori = vimporte;
                    LET vimporte = vsdo_disponible;
                
                    INSERT INTO sc_movdia VALUES
                    (0, vfolio, '9290', 'intercar', vfecha_hoy, vfecha_hoy, vhora, '0830', 
                     vsucursal, vproducto, pempresa, vcuenta, null, 0, vimporte, 0.00, 0.00, 
                     0.00, 0, null, null, vsdo_actual, '0830', vreferencia, 0, vtarjeta, null, "");

                
                    UPDATE sc_maechq
                       SET sdo_actual = sdo_actual - vimporte,
                           sdo_cong = 0.00,
                           status_cta = '3',
                           motivo = '09'
                     WHERE empresa = pempresa
                       AND cuenta = vcuenta;
                    
                    SELECT COUNT(*)
                      INTO vexiste
                      FROM sc_ctabloqueo
                     WHERE cuenta = vcuenta;
                     
                    IF vexiste = 0 THEN 
                        INSERT INTO sc_ctabloqueo VALUES(vcuenta, '09', '3');
                    ELSE 
                        UPDATE sc_ctabloqueo
                           SET clave = '09',
                               opcion = '3'
                         WHERE cuenta = vcuenta;
                    END IF;
                    
                    INSERT INTO sc_ctabloqueohist VALUES (vcuenta, '09', '3');

                    SELECT COUNT(*)
                      INTO vexiste
                      FROM sc_histbloq
                     WHERE cuenta = vcuenta
                       AND status_blo = 'B'
                       AND tipo_mov = 'B'
                       AND empresa = pempresa;

                    IF vexiste <> 0 THEN
                        INSERT INTO sc_histbloq VALUES
                        (pempresa, vcuenta, 'D', '00', null, 0.00, 'informix', 
                         vfecha_hoy, current hour to fraction, 'infor', 'D', vfolio, ' ');
                    END IF;
                     
                    INSERT INTO sc_histbloq VALUES
                    (pempresa, vcuenta, 'B', '09', 3, 0.00, 'informix',
                     vfecha_hoy, current hour to fraction, 'infor', 'B', vfolio, " ");
                
                    INSERT INTO cargos_cong VALUES (vcuenta, vimporte_ori, vreferencia, vimporte);
                    
                    LET vcargados = vcargados + 1;
                END IF;
            ELSE 
                INSERT INTO cargos_cong VALUES (vcuenta, vimporte, vreferencia, 0.00);
            END IF;
        END IF;    
        
        LET vcuantos = vcuantos + 1;
        
        COMMIT WORK;
        BEGIN WORK;
        
        LET vcuenta         = ''; 
        LET vimporte        = 0.00;
        LET vsdo_cong       = 0.00;
        LET vsucursal       = '';
        LET vstatus         = '';
        LET vmaxsec         = '';
        LET vtarjeta        = '';
        LET vexiste         = '';
        LET vmotivo         = '';
        LET vproducto       = '';
        LET vsdo_actual     = 0.00;
        LET vsdo_cong_res   = 0.00;
        LET vsdo_disponible = 0.00;
        LET vreferencia     = '';
        LET vimporte_ori    = 0.00;
        
    END FOREACH;

    IF nComit = 1 THEN
        COMMIT WORK;
        LET nComit = 0;
    END IF;

    UPDATE STATISTICS MEDIUM FOR TABLE cargos_cong;

    LET vfechadescarga = TO_CHAR(vfecha_hoy, '%d%m%Y');
    LET vnombre = 'recup_cong_'||vfechadescarga||'.txt';

    LET vsql = "";
    LET vsql = 'echo "UNLOAD TO /resplogifx/conciliachq/'||vnombre||' SELECT * FROM cargos_cong" > /resplogifx/conciliachq/cargos.sql';
    SYSTEM vsql;
    LET vsql = "";
    --- LET vsql = "dbaccess bdicheq /resplogifx/conciliachq/cargos.sql";
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/cargos.sql";
    SYSTEM vsql;
    LET vsql = "";
    --- LET vsql = 'chmod 664 /resplogifx/conciliachq/'||vnombre;
    LET vsql = '/usr/bin/chmod 664 /resplogifx/conciliachq/'||vnombre;
    SYSTEM vsql;
    LET vsql = "";

    END;

    RETURN vcodret1, vcodret2, vcuantos, vcargados;

END PROCEDURE
DOCUMENT
"MODIFICADO:            Donovan F. Torres Landeros",
"ULTIMA MODIFICACION:   2025/12/20",
"RAZON:                 Se agrega la nueva variable sdo_sbc (saldo buen cobro)",
"                       a la operacion aritmetica para el nuevo calculo de",
"                       saldo disponible.",
"PROYECTO: RQM 09 704   Cobranza Automatica en cuentas de captacion",
"BD:                    bdicheq",
"VER:                   1.2";

create procedure "informix".cargon_ref_mx1(pempresa     char(3),
                                       psucursal    char(4),
                                       pusuario     char(8),
                                       ptransacc    char(4),
                                       ptransuc     char(4),
                                       pfolsuc      char(16),
                                       pcuenta      char(20),
                                       pcheque      integer,
                                       pmonto       money(14,2),
                                       pdivisa      char(2),
                                       preferencia  char(40),
                                       pnum_tarjeta char(16),
                                       pusuautoriza char(8))
returning char(5),char(4);

    define vfecha_hoy       date;
    define vfecha_proc      date;
    define vchrFechaValor   date;
    define vfechacalendario date;
    define vfecultmov       date;
    define vfechaccc        date;
    define vFechaDev        date;
    define vvaldoc          char(1);
    define vnaturaleza      char(1);
    define vval_chequeras   char(1);
    define vexiste          char(1);
    define vaceptab         char(1);
    define vstatus_cta      char(1);
    define vacepcargo       char(1);
    define vestado          char(1);
    define vcolat           char(1);
    define vsobregira       char(1);
    define vacepta_retpar   char(1);
    define vacepta_retiros  char(1);
    define vper_retiros     char(1);
    define vcancelacta      char(1);
    define vCobComChqExp    char(1);
    define vind_dispon      char(1);
    define vmoneda          char(2);
    define vmotivo          char(2);
    define vtipo_tran       char(2);
    define vsuccta          char(4);
    define vproducto        char(4);
    define vtrancancta      char(4);
    define vtrancomcan      char(4);
    define vtranretpar      char(4);
    define vtranret         char(4);
    define vtrandevobco     char(4);
    define vtrandevbcoop    char(4);
    define vComxChqExp      char(4);
    define vTrxCargoConcen  char(4);
    define vcodret          char(5);
    define vcodret2         char(5);
    define cCodRetIndicador	char(6);
    define vusuario         char(8); 
    define vctacol          char(20);
    define vdescerr         char(50);
    define vcodret3         char(50);
    define vsqlerr          integer;
    define visamerr         integer;
    define vcheque          integer;
    define vultche          integer;
    define vchqexp          smallint;
    define vtotcol          smallint;
    define vdiasret         smallint;
    define vdiasultret      smallint;
    define vChqExpMes       smallint;
    define vChqsLibCom      smallint;
    define vIntChqDev       smallint;
    define vChqDev          smallint;
    define vexistlimsbg     smallint;
    define vmonto           money(14,2);
    define vimpsbg          money(14,2);
    define vimpccc          money(14,2);
    define vabono_eje       money(14,2);
    define vsaldo_fin       money(14,2);
    define vsaldo_col       money(14,2);
    define vsdorestar       money(14,2);
    define vsdo_actual      money(14,2);
    define vdisponible      money(14,2);
    define vretenido        money(14,2);
    define vcongelado       money(14,2);
    define vlimccc          money(14,2);
    define vdispccc         money(14,2);
    define vreqccc          money(14,2);
    define vutilccc         money(14,2);
    define vsdodisp         money(14,2);
    define vlimite_sbg      money(14,2);
    define vimp_acum_sbg    money(14,2);
    define vtasa_aplicada   decimal(9,6);
    define vfecha_operacion date; 
	define vcodret1         CHAR(5);
	define vfechaHabil		DATE;
    define vnum_cte         char(20);
    define vchrFechaVal     char(10);
	--RQM 09 704. Se crea la siguiente variable.
	DEFINE cCodRet			CHAR(5);
	DEFINE cMensajeRet		CHAR(50);
	DEFINE mSdoSbc			MONEY(14,2);
	DEFINE mSaldoDispo		MONEY(14,2);
    
    let vfecha_hoy       = '';
    let vfecha_proc      = '';
    let vchrFechaValor   = '';
    let vfechacalendario = '';
    let vfecultmov       = '';
    let vfechaccc        = '';
    let vFechaDev        = '';
    let vvaldoc          = '';
    let vnaturaleza      = '';
    let vval_chequeras   = '';
    let vexiste          = '';
    let vaceptab         = '';
    let vstatus_cta      = '';
    let vacepcargo       = '';
    let vestado          = '';
    let vcolat           = '';
    let vsobregira       = '';
    let vacepta_retpar   = '';
    let vacepta_retiros  = '';
    let vper_retiros     = '';
    let vcancelacta      = '';
    let vCobComChqExp    = '';
    let vind_dispon      = '';
    let vmoneda          = '';
    let vmotivo          = '';
    let vtipo_tran       = '';
    let vsuccta          = '';
    let vproducto        = '';
    let vtrancancta      = '';
    let vtrancomcan      = '';
    let vtranretpar      = '';
    let vtranret         = '';
    let vtrandevobco     = '';
    let vtrandevbcoop    = '';
    let vComxChqExp      = '';
    let vTrxCargoConcen  = '';
    let vcodret          = '';
    let vcodret2         = '';
    let cCodRetIndicador = '';
    let vusuario         = '';
    let vctacol          = '';
    let vdescerr         = '';
    let vcodret3         = '';
    let vsqlerr          = 0;
    let visamerr         = 0;
    let vcheque          = 0;
    let vultche          = 0;
    let vchqexp          = 0;
    let vtotcol          = 0;
    let vdiasret         = 0;
    let vdiasultret      = 0;
    let vChqExpMes       = 0;
    let vChqsLibCom      = 0;
    let vIntChqDev       = 0;
    let vChqDev          = 0;
    let vexistlimsbg     = 0;
    let vmonto           = 0;
    let vimpsbg          = 0;
    let vimpccc          = 0;
    let vabono_eje       = 0;
    let vsaldo_fin       = 0;
    let vsaldo_col       = 0;
    let vsdorestar       = 0;
    let vsdo_actual      = 0;
    let vdisponible      = 0;
    let vretenido        = 0;
    let vcongelado       = 0;
    let vlimccc          = 0;
    let vdispccc         = 0;
    let vreqccc          = 0;
    let vutilccc         = 0;
    let vsdodisp         = 0;
    let vlimite_sbg      = 0;
    let vimp_acum_sbg    = 0;
    let vtasa_aplicada   = 0;
	let vfecha_operacion = TODAY;
    LET vcodret1         = "00000";
    let vnum_cte         = '';
    let vchrFechaVal     = '';
	--RQM 09 704. Se define la siguiente variable.
	LET cCodRet		= '00000';
	LET cMensajeRet	= '';
	LET mSdoSbc		= 0.0;
	LET mSaldoDispo = 0.0;
	
    begin

    on exception set vsqlerr, visamerr, vdescerr
        set debug file to "/tmp/cargon_ref.err";
        trace on;
        if vsqlerr <> 0  then
            let vcodret = vsqlerr;
            let vcodret2 = visamerr;
            let vcodret3 = vdescerr;
            return vcodret, vtranret;
        end if;
    end exception;
    
    --Set Debug File To '/home/c90301007/Traza/cargon_ref_mx1_MODF.out';
    --Trace On;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    let vreqccc          = 0;
    let vcodret          = '000';
    let vtranret         = ptransacc;
    let vtipo_tran       = '';
    let vind_dispon      = '0';
    let vtasa_aplicada   = 0.000000;
    let cCodRetIndicador = '000000';

    if ( ( psucursal is null or psucursal = " " ) or 
         ( pusuario  is null or pusuario  = " " ) or 
         ( ptransacc is null or ptransacc = " " ) or
         ( pcuenta   is null or pcuenta   = " " ) or 
         ( pfolsuc   is null or pfolsuc   = " " ) or 
         ( pcheque   is null or pcheque   < 0   ) or
         ( pmonto    is null or pmonto    = 0   ) ) then
        let vcodret = '110';
        return vcodret, vtranret;
    end if;
    
    if psucursal <> "5005" then -- SI LA SUCURSAL ES CORRESPONSALES NO VALIDA EL USUARIO
        select ejecutivo 
          into vusuario
          from bdinteg:si_ejecut
         where ejecutivo = pusuario;
   
        if vusuario <> pusuario or vusuario is null then
            let vcodret = "106";
            return vcodret,vtranret;
        end if
    end if

    select numero,naturaleza,valida_docto,sobregira, tipo_tran
      into vtranret,vnaturaleza,vvaldoc,vsobregira, vtipo_tran
      from bdinteg:si_transacc
     where empresa = pempresa 
       and numero = ptransacc
       and sistema = '01'
       and naturaleza = 'C';

    if ptransacc != vtranret or vtranret is null then
        let vcodret = "550";
        return vcodret,vtranret;
    end if;

    if vnaturaleza != "C" then
        let vcodret = "560";
        return vcodret,vtranret;
    end if;

    if vvaldoc = "S" and (pcheque is null or pcheque = 0) then
        let vcodret = "110";
        return vcodret,vtranret;
    end if;

    select valor 
      into vtranretpar
      from sc_param
     where empresa = pempresa 
       and codparam = "tranretpar";
   
    select valor
      into vTrxCargoConcen
      from sc_param
     where empresa = pempresa
       and codparam = 'TrxCgoCtaConcentrada';

    select fecha_hoy, ind_disponible 
      into vfechacalendario,  vind_dispon 
      from sc_fechas 
     where empresa = pempresa;
     
    if vind_dispon = '0' then
        let vcodret = "004";
        return vcodret,vtranret;
    end if;

    select fecha_proceso, status_cta, producto
      into vfecha_hoy, vstatus_cta, vproducto
      from sc_maechq
     where cuenta = pcuenta;
    
    if vproducto = "1300" or vproducto = "1400" or vproducto = "1700" or vproducto = "2700" then
        if (ptransacc = "3220" or ptransacc = "0260") and (pmonto is null or pmonto = 0) then
            let vcodret = "000";
            return vcodret,vtranret;
        end if;
    end if;  

    if vproducto in("1100", "2300") and ptransacc = "0223" then
        let vcodret = "962";
        return vcodret,vtranret;
    end if;
	
	if vproducto in("1100", "2300") and ptransacc = "0402" then
        let vcodret = "100";
        return vcodret,vtranret;
    end if;
  
   	if vproducto = '2300' and ptransacc = '0239' and ptransuc <> '0000' then
	   let vcodret = "962";
       return vcodret, vtranret;
    end if    
  
    if (vfecha_hoy is null or vstatus_cta = '4' or vstatus_cta = '8' or vstatus_cta = '5') then
        let vfecha_hoy = vfechacalendario;
    end if

    if (vfecha_hoy < vfechacalendario ) then
        let vcodret = "549";
        return  vcodret,vtranret;
    end if
  
    if vstatus_cta in ("2","6","7") then
        let vcodret = "200";
        return vcodret,vtranret;
    end if;
    
    -- OBTIENE LA FECHA SPEI PARA TRANSACCION 0274
    if ptransacc = '0274' then
		IF CURRENT HOUR TO fraction > '17:58:00' AND CURRENT HOUR TO fraction < '18:05:00' THEN
			CALL bdispei:"informix".sp_validafecha(pEmpresa, vfecha_hoy)
			RETURNING vcodret1, vfechaHabil;
			LET vchrFechaValor = to_char(vfechaHabil, '%m/%d/%Y');
		ELSE
			SELECT vchrvalor
		      INTO vchrFechaVal
			  FROM bdispei:tblparametros
			WHERE vchrcveparametro = 'FECHA_OPERACION';
            
            LET vchrFechaValor = SUBSTR(vchrFechaVal,4,2)||'/'||SUBSTR(vchrFechaVal,1,2)||'/'||SUBSTR(vchrFechaVal,7,4);
		END IF;
    else
        LET vchrFechaValor= vfecha_hoy;
	end if;
   
    -- VALIDACION PARA CUENTAS CON STATUS 8 - ART 61 LIC
    if ( vstatus_cta = '8' and ptransacc not in('0223','0320','0270', '0252','0402') ) then
        let vcodret = "200";
        return vcodret,vtranret;
    end if;
    
    foreach
		-- RQM 09 704. Se agrega el campos saldo_sbc para considerarlo en los SP.
		select sucursal,producto,ult_chq,colateral,status_cta,motivo,sdo_actual,lim_sbg_ccc,imp_sbg_ccc,
               fech_venc_ccc,sdo_retenido,sdo_cong,fec_ult_mov, chq_exp_mes, fecha_proceso, num_cte, saldo_sbc
          into vsuccta,vproducto,vultche,vcolat,vstatus_cta,vmotivo,vsdo_actual,vlimccc,vutilccc,
               vfechaccc,vretenido,vcongelado,vfecultmov, vChqExpMes, vfecha_proc, vnum_cte, mSdoSbc
          from sc_maechq
         where cuenta = pcuenta
         
        if vretenido < 0 then
            let vretenido = vretenido * -1;
        end if;
        
        if vcongelado < 0 then
            let vcongelado = vcongelado * -1;
        end if;
        
        if vsuccta is null then
            let vcodret = "100";
            return vcodret,vtranret;
        end if;

        if vstatus_cta in ("2","6","7") then
            let vcodret = "200";
            return vcodret,vtranret;
        elif vstatus_cta = '5' then
            SELECT cargo 
              INTO vacepcargo 
              FROM sc_bloqueo
             WHERE codigo = vmotivo;

            IF vacepcargo = "N" THEN
                LET vcodret = "300";
                RETURN vcodret,vtranret;
            END IF;
        else
            -- Verifica el tipo de bloqueo de la cuenta.....
            IF vstatus_cta = "3" THEN
                IF ptransacc <> '0830' AND ptransacc <> '0887' THEN
                    SELECT "1" 
                      INTO vexiste
                      FROM sc_ctabloqueo 
                     WHERE cuenta = pcuenta;

                    IF vexiste = "1" THEN      
                        SELECT opcion 
                          INTO vaceptab
                          FROM sc_ctabloqueo 
                         WHERE cuenta = pcuenta;

                        IF vaceptab = 4 OR vaceptab = 3 THEN
                            LET vcodret = "300";
                            RETURN vcodret,vtranret;
                        END IF;
                    ELSE
                        SELECT cargo 
                          INTO vacepcargo 
                          FROM sc_bloqueo
                         WHERE codigo = vmotivo;

                        IF vacepcargo = "N" THEN
                            LET vcodret = "300";
                            RETURN vcodret,vtranret;
                        END IF;
                    END IF;
                END IF;
            END IF;
        end if;
        
        select divisa,val_chequeras,acepta_retiros,per_retiros[1,1],per_retiros[3,5],acepta_retpar, cancelacta
          into vmoneda,vval_chequeras,vacepta_retiros,vper_retiros,vdiasret, vacepta_retpar,vcancelacta
          from sc_producto
         where empresa = pempresa 
           and producto = vproducto;

        if vmoneda != pdivisa then
            let vcodret = "951";
            return vcodret,vtranret;
        end if;

        if vacepta_retiros = "N" then
            select valor 
              into vtrancancta
              from sc_param
             where empresa = pempresa 
               and codparam = "trancancta";           

            select valor 
              into vtrancomcan
              from sc_param
             where empresa = pempresa 
               and codparam = "trancomcan";
      
            select valor 
              into vtrandevobco
              from sc_param
             where empresa = pempresa 
               and codparam = "trandevobco";
             
            select valor 
              into vtrandevbcoop
              from sc_param
             where empresa = pempresa 
               and codparam = "trandevbcoop";
             
            if ( ( ptransacc <> vtranretpar   or vtranretpar   is null ) and
                 ( ptransacc <> vtrancancta   or vtrancancta   is null ) and
                 ( ptransacc <> vtrandevobco  or vtrandevobco  is null ) and
                 ( ptransacc <> vtrandevbcoop or vtrandevbcoop is null ) and
                 ( ptransacc <> vtrancomcan   or vtrancomcan   is null ) ) then
                let vcodret = '957';
                return vcodret, vtranret;
            end if
        else
			-- RQM 09 704. Se agrega el SP calcular el saldo disponible tomando en cuenta el saldo_sbc.
			EXECUTE PROCEDURE bdicheq:"informix".sp_cons_sdodisp_x_tpcalculo
			('', vsdo_actual, vretenido, vcongelado, mSdoSbc, '', '', '', 'F', '2') INTO cCodRet, cMensajeRet, mSaldoDispo;
			
            IF vper_retiros = "U" AND pmonto <> mSaldoDispo then
                let vcodret = "420";
                return vcodret,vtranret;
            END IF
			-- RQM 09 704. Se agrega el resultado del saldo disponible que considerado el saldo sbc.
            if ( vstatus_cta = '8' and pmonto <> mSaldoDispo ) then
                let vcodret = "420";
                return vcodret,vtranret;
            end if
         
            let vdiasultret = vfecha_hoy - vfecultmov;
          
            if vdiasultret < 0 then
                let vdiasultret = 0;
            end if
           
            if vdiasultret < vdiasret then
                let vcodret = "957";
                return vcodret,vtranret;
            end if
        end if

        if vval_chequeras = "S" and vvaldoc = "S" then
            if pcheque > vultche then
                let vcodret = "520";
                return vcodret,vtranret;
            end if;
        end if;
      
        -- Inicia Validaciones de Chequeras Gpo PISA 270110 --
        IF vvaldoc = "S" then
            SELECT valor 
              INTO vCobComChqExp 
              FROM sc_param
             WHERE empresa = pempresa
               AND codparam = "cobcomchqexp";

            select valor
              into vChqsLibCom
              from bdicntchq:sq_param
             where cod_param = 1; 

            SELECT valor 
              INTO vComxChqExp 
              FROM sc_param
             WHERE empresa = pempresa
               AND codparam = "comxchqexp";
             
            SELECT valor 
              INTO vIntChqDev 
              FROM sc_param
             WHERE empresa = pempresa
               AND codparam = "intentoschqdev";

            IF vCobComChqExp NOT IN ('S','N') OR vCobComChqExp IS NULL THEN
                LET vcodret = "705";
                LET vtranret = ptransacc;
                RETURN vcodret,vtranret;
            END IF

            SELECT {+INDEX(sc_contch idx_contch2)}
                   numero,estado
              INTO vcheque,vestado
              FROM sc_contch
             WHERE empresa = pempresa
               AND cuenta = pcuenta
               AND numero = pcheque;

            IF dbinfo("sqlca.sqlerrd2") = 0 THEN
                LET vcodret = "500";
                LET vtranret = ptransacc;
                RETURN vcodret,vtranret;
            END IF
          
            IF ( vestado = 'P' ) then -- Pagado
                LET vcodret = '600';
                LET vtranret = ptransacc;
                RETURN vcodret, vtranret;
            ELIF ( vestado = 'E' OR vestado = 'S' ) THEN -- Cheque No Activado
                LET vcodret = '500';
                LET vtranret = ptransacc;
                RETURN vcodret, vtranret;
            ELIF ( vestado = 'R' ) THEN -- Revocado (Suspendido)
                LET vcodret = '700';
                LET vtranret = ptransacc;
                RETURN vcodret, vtranret;
            ELIF ( vestado = 'J' ) THEN -- Bloqueado Judicial
                LET vcodret = '701';
                LET vtranret = ptransacc;
                RETURN vcodret, vtranret;
            ELIF ( vestado = 'B' ) THEN -- Bloqueado Autoridades
                LET vcodret = '702';
                LET vtranret = ptransacc;
                RETURN vcodret, vtranret;
            ELIF ( vestado = 'F' ) THEN -- Fraudulento
                LET vcodret = '703';
                LET vtranret = ptransacc;
                RETURN vcodret, vtranret;
            ELIF ( vestado = 'C' ) THEN -- Cancelado
                LET vcodret = '704';
                LET vtranret = ptransacc;
                RETURN vcodret, vtranret;
            END IF;
        END IF; -- Termina Validaciones para chequeras

        let vdispccc = vlimccc - vutilccc;
      
        if vfechaccc < vfecha_hoy or vdispccc is null then
            let vdispccc = 0;
        end if
		
		-- RQM 09 704. Se agrega el SP calcular el saldo disponible tomando en cuenta el saldo_sbc.
		EXECUTE PROCEDURE bdicheq:"informix".sp_cons_sdodisp_x_tpcalculo
		('', vsdo_actual, vretenido, vcongelado, mSdoSbc, '', '', '', 'F', '2') INTO cCodRet, cMensajeRet, vdisponible;
		
		--let vdisponible = vsdo_actual - vretenido - vcongelado + vdispccc;
		let vdisponible = vdisponible + vdispccc;
		
        if vdisponible < 0 then
            let vdisponible = 0.00;
        end if;

        if vsdo_actual = pmonto and ptransacc = vtranretpar then
            let vcodret = "002";
            let vtranret = ptransacc;
            return vcodret,vtranret;
        end if

        if vsobregira = "S"  and pmonto > vdisponible then
            select count(*)
              into vexistlimsbg
              from sc_limite_sbg
             where cuenta = pcuenta;
             
            if ( vexistlimsbg > 0 ) then
                select limite_sbg, imp_acum_sbg
                  into vlimite_sbg, vimp_acum_sbg
                  from sc_limite_sbg
                 where cuenta = pcuenta;
                 
                if ( ( pmonto + vimp_acum_sbg ) > ( vdisponible + vlimite_sbg ) ) then
                    let vcodret = '400';
                    let vtranret = ptransacc;
                    return vcodret, vtranret;
                end if;
            end if;
            
			let vreqccc = pmonto - (vsdo_actual - vretenido - vcongelado);          
            
            if vdispccc >= vreqccc then
                let vimpccc = vreqccc;
                let vimpsbg = 0;
            else
                let vimpccc = vdispccc;
                let vimpsbg = vreqccc - vdispccc;
            end if
          
            if vimpccc > 0 then
                insert into sc_movdia values
                (0,pfolsuc,psucursal,pusuario,vfecha_hoy,vchrFechaValor,current hour to fraction(3),"3240",vsuccta,vproducto,pempresa,pcuenta,"  ",
                 pcheque,vimpccc,vimpccc,0,0,0," ",vstatus_cta,vsdo_actual,ptransuc,preferencia,vtasa_aplicada,pnum_tarjeta,pusuautoriza,"",vfecha_operacion);
				 
				EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(psucursal,pcuenta,"3240",vimpccc,vfecha_hoy,"A")
				INTO cCodRetIndicador;
            end if
          
            if vimpsbg > 0 then
                insert into sc_movdia values
                (0,pfolsuc,psucursal,pusuario,vfecha_hoy,vchrFechaValor,current hour to fraction(3),"3357",vsuccta,vproducto,pempresa,pcuenta,"  ",
                 pcheque,vimpsbg,vimpsbg,0,0,0," ",vstatus_cta,vsdo_actual,ptransuc,preferencia,vtasa_aplicada,pnum_tarjeta,pusuautoriza,"",vfecha_operacion);
                 
                update sc_limite_sbg
                   set imp_acum_sbg = imp_acum_sbg + vimpsbg
                 where cuenta = pcuenta;
				 
				EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(psucursal,pcuenta,"3357",vimpsbg,vfecha_hoy,"A")
				INTO cCodRetIndicador;
            end if               

            insert into sc_movdia values
            (0,pfolsuc,psucursal,pusuario,vfecha_hoy,vchrFechaValor,current hour to fraction(3),ptransacc,vsuccta,vproducto,pempresa,pcuenta,"  ",
             pcheque,pmonto,0,0,0,0," ",vstatus_cta,vsdo_actual,ptransuc,preferencia,vtasa_aplicada,pnum_tarjeta,pusuautoriza,"",vfecha_operacion);
           
            if vvaldoc = "S" then
                update {+INDEX(sc_contch idx_contch2)} sc_contch
                   set estado = "P",
                       fecha_alta = vfecha_hoy,
                       importe = pmonto
                 where empresa = pempresa 
                   and cuenta = pcuenta 
                   and numero = pcheque;
                 
                let vchqexp = 1;
            else
                let vchqexp = 0; 
            end if
            
            if (vtipo_tran in('00','30') and ptransacc <> vTrxCargoConcen) then
                update sc_maechq
                   set sdo_actual     = sdo_actual - vdisponible + vdispccc,
                       imp_sbg_ccc    = imp_sbg_ccc + vimpccc,
                       imp_chq_sbg    = imp_chq_sbg + vimpsbg,
                       imp_cgos_mes   = imp_cgos_mes + pmonto,
                       num_cgos_mes   = num_cgos_mes + 1,
                       imp_abonos_mes = imp_abonos_mes + vreqccc,
                       num_abonos_mes = num_abonos_mes + 1,
                       chq_exp_mes    = chq_exp_mes + vchqexp,
                       fec_ult_mov    = vfecha_hoy,
                       fecultret      = vfecha_hoy
                 where cuenta = pcuenta;
            else
                update sc_maechq
                   set sdo_actual     = sdo_actual - vdisponible + vdispccc,
                       imp_sbg_ccc    = imp_sbg_ccc + vimpccc,
                       imp_chq_sbg    = imp_chq_sbg + vimpsbg,
                       imp_cgos_mes   = imp_cgos_mes + pmonto,
                       num_cgos_mes   = num_cgos_mes + 1,
                       imp_abonos_mes = imp_abonos_mes + vreqccc,
                       num_abonos_mes = num_abonos_mes + 1,
                       chq_exp_mes    = chq_exp_mes + vchqexp,
                       fec_ult_mov    = vfecha_hoy
                 where cuenta = pcuenta;
            end if;
     
            -- Actualiza Cuentas Inactivas e Informadas (Status 4 y 5)
            IF ( vstatus_cta IN('4','5') AND vtipo_tran in('00','30') ) THEN
                UPDATE sc_maechq
                   SET status_cta = '1',
                       fecha_proceso = vfecha_hoy
                 WHERE cuenta = pcuenta;
            END IF;

            -- Valida Comision por Cheque Expedido Gpo PISA 270110 --
            IF vvaldoc = "S" then
                IF vCobComChqExp = "S" THEN
                    IF vChqsLibCom < vChqExpMes + 1 THEN
                        CALL cargo_comisiones(pempresa, pcuenta, vComxChqExp, pmonto, pfolsuc, psucursal, pusuario, pcheque, pdivisa, vfecha_hoy)
                        RETURNING vcodret;
                       
                        IF vcodret <> "000" THEN
                            LET vtranret = ptransacc;
                            RETURN vcodret,vtranret;
                        END IF
                    END IF
                END IF
            END IF

            let vtranret = ptransacc;
            let vcodret = "000";
			
			-- LLAMADO AL SP QUE GENERA LOS INDICADORES DE CAPTACION
			EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(psucursal,pcuenta,ptransacc,pmonto,vfecha_hoy,"C")
			INTO cCodRetIndicador;
			
            return vcodret,vtranret;
        end if

        if pmonto > vdisponible then        
           
            if vvaldoc = "S" then
                -- Siempre se cobra la comision
                call gencomdev(pempresa,pcuenta,ptransacc,pcheque,pfolsuc,pmonto,"1",psucursal,pusuario,pdivisa)
                returning vcodret;

                IF vcodret = "000" THEN
                    LET vcodret = "400"; --Debe retornar forndos insuficientes
                END IF

                -- Valida Comision por Cheque Expedido Axl'10 270110 --
                IF vvaldoc = "S" then
                    IF vCobComChqExp = "S" THEN
                        IF vChqsLibCom < vChqExpMes + 1 THEN
                            CALL cargo_comisiones(pempresa, pcuenta, vComxChqExp, pmonto, pfolsuc, psucursal, pusuario, pcheque, pdivisa, vfecha_hoy)
                            RETURNING vcodret;
                            
                            IF vcodret <> "000" THEN
                                LET vtranret = ptransacc;
                                RETURN vcodret,vtranret;
                            END IF
                        END IF
                    END IF
                END IF
                      
                SELECT COUNT(*), MAX(fecha)
                  INTO vChqDev, vFechaDev
                  FROM sc_chequedev
                 WHERE empresa = pempresa
                   AND cuenta = pcuenta
                   AND fecha <= vfecha_hoy
                   AND numerochq = pcheque;

                IF (vChqDev +1) > vIntChqDev THEN
                    LET vcodret = "400";
                    LET vtranret = ptransacc;
                    RETURN vcodret,vtranret;
                END IF

                IF vFechaDev = vfecha_hoy  THEN
                    LET vcodret = "400";
                    LET vtranret = ptransacc;
                    RETURN vcodret,vtranret;
                END IF
            end if

            IF vcodret = "000" THEN --Fondos Insuficientes
                let vcodret = "400";
            END IF
               
            let vtranret = ptransacc;
            return vcodret,vtranret;
            
        else
            
            insert into sc_movdia values
            (0,pfolsuc,psucursal,pusuario,vfecha_hoy,vchrFechaValor,current hour to fraction(3),ptransacc,vsuccta,vproducto,pempresa,pcuenta," ",
             pcheque,pmonto,0,0,0,0," ",vstatus_cta,vsdo_actual,ptransuc,preferencia,vtasa_aplicada,pnum_tarjeta,pusuautoriza,"",vfecha_operacion);
             
            if ptransacc = '0223' then
                insert into sc_retirosefectivo values
                (vfecha_hoy, current hour to fraction(3), pfolsuc, ptransacc, vnum_cte, pcuenta, psucursal, vsuccta, pmonto);
            end if
           
            if vvaldoc = "S" then
                let vchqexp = 1;    
                    
                update {+INDEX(sc_contch idx_contch2)} sc_contch
                   set estado  = "P",
                       fecha_alta = vfecha_hoy,
                       importe = pmonto
                 where empresa = pempresa 
                   and cuenta = pcuenta 
                   and numero = pcheque;
            else
                let vchqexp = 0;
            end if
           
            if (vtipo_tran in('00','30') and ptransacc <> vTrxCargoConcen) then
                update sc_maechq
                   set sdo_actual     = sdo_actual - pmonto + vreqccc,
                       imp_sbg_ccc    = imp_sbg_ccc + vreqccc,
                       imp_cgos_mes   = imp_cgos_mes + pmonto,
                       num_cgos_mes   = num_cgos_mes + 1,
                       imp_abonos_mes = imp_abonos_mes + vreqccc,
                       num_abonos_mes = num_abonos_mes + 1,
                       fec_ult_mov    = vfecha_hoy,
                       chq_exp_mes    = chq_exp_mes + vchqexp,
                       fecultret      = vfecha_hoy
                 where cuenta = pcuenta;
            else
                update sc_maechq
                   set sdo_actual     = sdo_actual - pmonto + vreqccc,
                       imp_sbg_ccc    = imp_sbg_ccc + vreqccc,
                       imp_cgos_mes   = imp_cgos_mes + pmonto,
                       num_cgos_mes   = num_cgos_mes + 1,
                       imp_abonos_mes = imp_abonos_mes + vreqccc,
                       num_abonos_mes = num_abonos_mes + 1,
                       fec_ult_mov    = vfecha_hoy,
                       chq_exp_mes    = chq_exp_mes + vchqexp
                 where cuenta = pcuenta;
            end if;
            
            -- Actualiza Cuentas Inactivas e Informadas (Status 4 y 5)
            IF ( vstatus_cta IN('4','5') AND vtipo_tran in('00','30') ) THEN
                UPDATE sc_maechq
                   SET status_cta = '1',
                       fecha_proceso = vfecha_hoy
                 WHERE cuenta = pcuenta;
            END IF;

            -- Valida Comision por Cheque Expedido Axl'10 270110 --
            IF vvaldoc = "S" then
                IF vCobComChqExp = "S" THEN
                    IF vChqsLibCom < vChqExpMes + 1 THEN
                        CALL cargo_comisiones(pempresa, pcuenta, vComxChqExp, pmonto, pfolsuc, psucursal, pusuario, pcheque, pdivisa, vfecha_hoy)
                        RETURNING vcodret;
                    
                        IF vcodret <> "000" THEN
                            LET vtranret = ptransacc;
                            RETURN vcodret,vtranret;
                        END IF
                    END IF
                END IF
            END IF
            
        end if;

        -- Para acumular en sc_tarjeta
        update {+INDEX(sc_tarjeta ix_tarjeta3)} sc_tarjeta
           set disp_mes = nvl(disp_mes,0) + pmonto
         where empresa = pempresa
           and cuenta  = pcuenta
           and num_tarjeta = pnum_tarjeta;

        -- Cancela la cuenta al retiro del monto
        IF ( vper_retiros = 'U' AND vcancelacta = 'S' ) OR ( vstatus_cta  = '8' AND ptransacc IN('0223','0270', '0252', '0402') ) THEN
            UPDATE sc_maechq
               SET status_cta = '2', 
                   fec_cancelac = vfechacalendario, 
                   motivo = '02'
             WHERE cuenta = pcuenta;
        END IF
    end foreach
    
    let vcodret = "000";
    let vtranret = ptransacc;

	-- LLAMADO AL SP QUE GENERA LOS INDICADORES DE CAPTACION
	EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(psucursal,pcuenta,ptransacc,pmonto,vfecha_hoy,"C")
	INTO cCodRetIndicador;
	
    return vcodret, vtranret;

    end;

end procedure
DOCUMENT
'MODIFICO :     Ezequiel Moreno Paredes',
'BD :     		bdicheq',
'FECHA :        02-07-2025',
'MODIFICACION : Se modifica la formula de calculo de saldo disponible para considerar un nuevo campo llamado saldo_sbc',
'PROYECTO :     RQM 09 704 Cobranza Automatica en cuentas de captacion',
'VERSION :      1.0.1';

create procedure "informix".cierre_diario(pempresa char(3), pdias integer, pcuenta char(20))
returning char(5);
    
    -- ***********************************************************************
    -- * cierre_diario                                                       *
    -- * Version              1.0.0                                          *
    -- * Obejtivo:            Calcula saldos acumulados para cierre diario   *
    -- * Creado por:                                                         *
    -- * ModIFicado por:      Alejandro Rueda Sanchez                        *
    -- * Ultima Modificacion: Septiembre 2009                                *
    -- *                     Creacion de SPL                                 *
	-- * MODIFICO :		Ezequiel Moreno Paredes									*
	-- * FECHA : 		19-06-2025												*
	-- * MODIFICACION : Se modifica la formula de calculo de saldo disponible	*
	-- *                para considerar un nuevo campo llamado saldo_sbc	 	*
	-- * PROYECTO :     RQM 09 704 Cobranza Automatica en cuentas de captacion	*
	-- * VERSION :      1.0.1												 	*
	-- * BD: 			bdicheq													*
	-- *                     				                                 	*
    -- ***********************************************************************
    
    DEFINE global vgcuenta          char(20)        default " ";
    DEFINE global vgsucursal        char(4)         default " ";
    DEFINE global vgsdo_actual      money(14,2)     default 0;
    DEFINE global vgacum_sdo_pos    money(14,2)     default 0;
    DEFINE global vgdia_sdo_pos     smallint        default 0;
    DEFINE global vgproducto        char(4)         default " ";
    DEFINE global vgstatus_cta      char(1)         default " ";
    DEFINE global vgpaga_interes    char(1)         default " ";
    DEFINE global vgmto_pag_int     money(14,2)     default 0;
    DEFINE global vgtasa            char(8)         default " ";
    DEFINE global vgsobretasa       decimal(9,6)    default 0;
    DEFINE global vgtp_moneda       char(2)         default " ";
    DEFINE global vges_fisica       char(1)         default " ";
    DEFINE global vgexento_isr      char(1)         default " ";
    DEFINE global vgtipo_dias_calc  char(1)         default " ";
    DEFINE global vgpago_interes    char(1)         default " ";
    DEFINE global vgtipo_anio_calc  char(1)         default " ";
    DEFINE global vgfecha_hoy       date            default " ";
    DEFINE global vgfecha_pago      date            default " ";
    DEFINE global vgnum_cte         char(20)        default " ";
    DEFINE global vgdias_acum_int   integer         default 0;
    DEFINE global vgacum_sdo_int    money(14,2)     default 0;
    DEFINE global vgfecha_alta      date            default "";
    DEFINE GLOBAL vgTasaVar         CHAR(1)         DEFAULT "";
    DEFINE GLOBAL vgFechaProc       DATE	        DEFAULT "";
    DEFINE GLOBAL vgProdCreciente   CHAR(4)         DEFAULT " ";
    DEFINE GLOBAL vgint_acum        DECIMAL(14,2)   DEFAULT 0;
    DEFINE GLOBAL vgsdo_disp        DECIMAL(14,2)   DEFAULT 0;
    DEFINE GLOBAL vgpri_hab_mes     DATE            DEFAULT " ";
    DEFINE GLOBAL vgpri_dia_mes     DATE            DEFAULT " ";
    DEFINE GLOBAL vgfecha_mod       DATE            DEFAULT " ";
    DEFINE GLOBAL vgsdo_retenido    DECIMAL(14,2)   DEFAULT 0;
    DEFINE GLOBAL vgsdo_cong        DECIMAL(14,2)   DEFAULT 0;
    DEFINE GLOBAL vginstrucc        CHAR(2)         DEFAULT " ";
    DEFINE GLOBAL vgcuentadep       CHAR(20)        DEFAULT " ";
	--RQM 09 704. Se agregan las variables para el retorno de consulta de saldo.
	DEFINE mSaldoSBC	   MONEY(14,2); 

    DEFINE vsdo_prom     money(14,2);
    DEFINE vcodret       char(5);
    DEFINE vcodret2      char(5);
    DEFINE vcodret3      char(40);
    DEFINE vsqlerr       integer;
    DEFINE vcobraisr     char(1);
    DEFINE vfecpagoint   datetime month to day;
    DEFINE vultpagoint   date;
    DEFINE isam_err      INTEGER;
    DEFINE error_info    CHAR(40);
    DEFINE vmotivo       CHAR(2);
    DEFINE vfechahora    CHAR(40);

    let vcodret  = "000";
    let vcodret2 = "000";
    let vcodret3 = "000";
    LET vfechahora = " ";
	--RQM 09 704. Se inicializan la variable para el retorno de consulta de saldo.
    LET mSaldoSBC		= 0.0;

    begin

    on exception 
        set vsqlerr, isam_err, error_info
        SET DEBUG FILE TO "cierrediario.err";
        TRACE ON;
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            let vcodret2 = isam_err;
            let vcodret3 = error_info;
            LET vfechahora = CURRENT;
            return vcodret;
        end if;
    end exception;

    set isolation to dirty read;
    SET LOCK MODE TO WAIT 3;
	--RQM 09 704. Se agrega la variable mSaldoSBC para almacenar el dato de la columna saldo_sbc
    select mae.cuenta, mae.num_cte, mae.sucursal, mae.status_cta, mae.motivo, mae.producto, mae.fecha_proceso, 
           mae.sdo_actual, mae.sdo_cong, mae.sdo_retenido, mae.ultpagoint, mae.cobraisr, 
           noc.fecha_alta, noc.acum_sdo_pos, noc.dia_sdo_pos, noc.int_acum, noc.acum_sdo_int, noc.dias_acum_int,
           pro.paga_interes, pro.tasa, pro.sobretasa, pro.divisa, pro.tipo_dias_calc, pro.pago_interes, 
           pro.tipo_anio_calc, pro.mto_pag_int, pro.fecpagoint, pro.paga_dividendo,
           tip.es_fisica, tip.exento_isr, mae.saldo_sbc
      into vgcuenta, vgnum_cte, vgsucursal, vgstatus_cta, vmotivo, vgproducto, vgFechaProc,
           vgsdo_actual, vgsdo_cong, vgsdo_retenido, vultpagoint, vcobraisr, 
           vgfecha_alta, vgacum_sdo_pos, vgdia_sdo_pos, vgint_acum, vgacum_sdo_int, vgdias_acum_int, 
           vgpaga_interes, vgtasa, vgsobretasa, vgtp_moneda, vgtipo_dias_calc, vgpago_interes, 
           vgtipo_anio_calc, vgmto_pag_int, vfecpagoint, vgTasaVar, 
           vges_fisica, vgexento_isr, mSaldoSBC
      from sc_maechq mae,
           sc_maenoc noc,
           sc_producto pro,
           bdinteg:si_cliente cte,
           bdinteg:si_tipper tip
     where mae.empresa = pempresa 
	   and mae.cuenta = pcuenta
       and mae.status_cta not in("2","7","8")
       and noc.empresa = mae.empresa
       and noc.cuenta = mae.cuenta
       and pro.empresa = mae.empresa
       and pro.producto = mae.producto
       and cte.numcte = mae.num_cte
       and tip.tpo_persona = cte.tpo_persona;

    if vcobraisr <> "" then
        if vcobraisr = "S" then
            let vgexento_isr = "N";
        else
            let vgexento_isr = "S";
        end if
    end if

    if vgpaga_interes is null then
        let vgpaga_interes = "N";
    end if

    if vgmto_pag_int is null then
        let vgmto_pag_int = 0;
    end if

    /* VERIFICA SI ES EL PRIMER DIA DEL MES, INICIALIZA SALDO INTERES ACUMULADO */
    IF DAY(vgpri_hab_mes) = DAY(vgfecha_hoy) THEN
        LET vgdias_acum_int = pdias;
        LET vgint_acum = vgacum_sdo_int;
        LET vgacum_sdo_int = 0;
        LET vgdia_sdo_pos = vgdia_sdo_pos + pdias;
        LET vgacum_sdo_pos = vgacum_sdo_pos + vgsdo_actual * pdias;
    /* DIAS DEL ACUMULADO DE INTERESES */
    ELSE 
        LET vgdias_acum_int = vgdias_acum_int + pdias;
        LET vgdia_sdo_pos = vgdia_sdo_pos + pdias;
        LET vgacum_sdo_pos = vgacum_sdo_pos + vgsdo_actual * pdias;
    END IF

    /* SI LA CUENTA ES EMPRESARIAL ESPECIAL, TOMA EL SALDO DISPONIBLE COMPLETO */
	--RQM 09 704. Se agrega la variable mSaldoSBC para almacenar el dato de la columna saldo_sbc
    IF vmotivo = '99' THEN
        let vgsdo_disp = vgsdo_actual - vgsdo_retenido - mSaldoSBC;
    ELSE
        let vgsdo_disp = vgsdo_actual - vgsdo_retenido - vgsdo_cong - mSaldoSBC;
    END IF
    
    LET vsdo_prom = vgacum_sdo_pos/vgdia_sdo_pos;
    
    /* SI EL PROMEDIO CERO LE PASO EL SALDO ACTUAL SI SON CEROS ESTA BIEN MEL */
    IF vsdo_prom = 0 THEN
        LET vsdo_prom = vgsdo_actual;
    END IF;
    
    if vgpaga_interes = "S" then
        call calcula_int(pempresa,pdias,vsdo_prom) 
        returning vcodret;
        
        if vcodret <> "000" then
            return vcodret;
        end if
    end if
    
    update sc_maenoc
       set dia_sdo_pos   = vgdia_sdo_pos,
           acum_sdo_pos  = vgacum_sdo_pos,
           dias_acum_int = vgdias_acum_int,
           acum_sdo_int  = vgacum_sdo_int,
           int_acum      = vgint_acum
     where empresa = pempresa
       and cuenta = vgcuenta;
    
    return vcodret;
    
    end
    
end procedure;