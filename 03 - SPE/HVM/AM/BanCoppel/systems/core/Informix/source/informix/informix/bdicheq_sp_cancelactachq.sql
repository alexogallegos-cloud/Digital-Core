CREATE PROCEDURE "informix".sp_cancelactachq( pEmpresa  CHAR(3), 
                                              pCuenta   CHAR(20), 
                                              pMotivo   CHAR(2), 
                                              pPromotor CHAR(8), 
                                              pSucursal CHAR(4) )
RETURNING CHAR(5)  AS cCodRet,
          CHAR(5)  AS cCodRet2,
          CHAR(80) AS cMensajeRet,
          CHAR(22) AS FolioCancel;
    
    DEFINE cCodRet          CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE cMensajeRet      CHAR(80);
    DEFINE iSqlErr          INTEGER;
    DEFINE iIsamErr         INTEGER;
    DEFINE cErrorInfo       CHAR(80);
    DEFINE dFechaCancel     DATE;
    DEFINE cCuenta          CHAR(20);
    DEFINE cStatusCta       CHAR(1);
    DEFINE cProducto        CHAR(4);
    DEFINE cNumCte          CHAR(20);
    DEFINE mSdoAct          MONEY(14,2);
    DEFINE mSdoCong         MONEY(14,2);
    DEFINE mSdoRet          MONEY(14,2);
    DEFINE mCom_pendiente   MONEY(14,2);
    DEFINE mImp_chq_sbg     MONEY(14,2);
    DEFINE mImp_chq_sbc     MONEY(14,2);
    DEFINE mimp_sbg_ccc     MONEY(14,2);
    DEFINE vProdCanc        SMALLINT;
    DEFINE vCredAsoc        SMALLINT;
    DEFINE vCreditos        SMALLINT;
    DEFINE vCredCrd         SMALLINT;
    DEFINE vCtasProac       SMALLINT;
    DEFINE vPagares         SMALLINT;
    DEFINE vInvCrec         SMALLINT;
    DEFINE vAclara          SMALLINT;
	DEFINE vAnticipoNom		SMALLINT;
    DEFINE c_numtarjeta     CHAR(20); 
    DEFINE cCodProdTarjeta  CHAR(3);   
    DEFINE cCodRetIntCar    CHAR(3);
    DEFINE cMsjeIntCar      CHAR(80);
    DEFINE vcvepprog        CHAR(10);
    DEFINE vcanal           CHAR(2);
    DEFINE vmaxcvepp        INTEGER;
    DEFINE sCodRetCancProg  CHAR(5);
    DEFINE sDescRetCancProg CHAR(80);
    DEFINE cFolioCancel     CHAR(22);
    DEFINE dtHoraActual     DATETIME HOUR TO SECOND;
	DEFINE vmovs			INTEGER;
	DEFINE sCodRetCteesp    CHAR(5);
	DEFINE sDescRetcteesp   CHAR(80);
	DEFINE vtipo_sucursal	CHAR(2);
    DEFINE cSucursal        CHAR(4);
    DEFINE mint_acum        MONEY(14,2);
    DEFINE vhora            DATETIME HOUR TO FRACTION;
    DEFINE vfolio_suc       CHAR(16);
	
    LET cCodRet          = '';
    LET cCodRet2         = '';
    LET cMensajeRet      = '';
    LET iSqlErr          = 0;
    LET iIsamErr         = 0;
    LET cErrorInfo       = '';
    LET dFechaCancel     = '';
    LET cCuenta          = '';
    LET cStatusCta       = '';
    LET cProducto        = '';
    LET cNumCte          = '';
    LET mSdoAct          = '0.00';
    LET mSdoCong         = '0.00';
    LET mSdoRet          = '0.00';
    LET mCom_pendiente   = '0.00';
    LET mImp_chq_sbg     = '0.00';
    LET mImp_chq_sbc     = '0.00';
    LET mimp_sbg_ccc     = '0.00';
    LET vProdCanc        = 0;
    LET vCredAsoc        = 0;
    LET vCreditos        = 0;
    LET vCredCrd         = 0;
    LET vCtasProac       = 0;
    LET vPagares         = 0;
    LET vInvCrec         = 0;
    LET vAclara          = 0;  
	LET vAnticipoNom	 = 0;
    LET c_numtarjeta     = '';  
    LET cCodProdTarjeta  = '';  
    LET cCodRetIntCar    = '';
    LET cMsjeIntCar      = '';
    LET vcvepprog        = '';
    LET vcanal           = '';
    LET vmaxcvepp        = 0;
    LET sCodRetCancProg  = '00000';
    LET sDescRetCancProg = '';
    LET cFolioCancel     = '';
    LET dtHoraActual     = CURRENT HOUR TO FRACTION(3);
	LET vmovs	         = 0;
	LET sCodRetCteesp    = '';
	LET sDescRetcteesp   = '';
	LET vtipo_sucursal   = '';
    LET cSucursal        = '';
    LET mint_acum        = 0.00;
    LET vhora            = '';
    LET vfolio_suc       = '';
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cancelactachq.err";
        TRACE ON;
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;
            LET cCodRet2 = iIsamErr;
            LET cMensajeRet = cErrorInfo;
            RETURN cCodRet, cCodRet2, cMensajeRet, cFolioCancel;
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cancelactachq.out";
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ; 
    SET LOCK MODE TO WAIT 3;
    
    -- // SE VALIDAN LOS PARAMETROS DE ENTRADA
    IF ( pEmpresa  is null OR pEmpresa  = '' ) OR
       ( pCuenta   is null OR pCuenta   = '' ) OR
       ( pMotivo   is null OR pMotivo   = '' ) OR
       ( pPromotor is null OR pPromotor = '' ) OR
       ( pSucursal is null OR pSucursal = '' ) THEN
        LET cCodRet = '050';
        LET cCodRet2 = '343';
        LET cMensajeRet = '';
        RETURN cCodRet, cCodRet2, cMensajeRet, cFolioCancel;
    END IF;
    
    -- // OBTIENE LA FECHA DEL SISTEMA
    SELECT fecha_hoy 
      INTO dFechaCancel
      FROM bdicheq:"informix".sc_fechas
     WHERE empresa = pEmpresa;
     
    -- // OBTIENE DATOS DE LA CUENTA
    SELECT mae.cuenta, mae.status_cta, mae.producto, mae.num_cte, mae.sdo_actual, mae.sdo_cong, mae.sdo_retenido, 
           mae.com_pendiente, mae.imp_chq_sbg, mae.imp_chq_sbc, mae.imp_sbg_ccc, mae.sucursal, noc.int_acum
      INTO cCuenta, cStatusCta, cProducto, cNumCte, mSdoAct, mSdoCong, mSdoRet, 
           mCom_pendiente, mImp_chq_sbg, mImp_chq_sbc, mimp_sbg_ccc, cSucursal, mint_acum
      FROM bdicheq:"informix".sc_maechq mae,
           bdicheq:"informix".sc_maenoc noc
     WHERE mae.cuenta = pCuenta
       AND noc.cuenta = mae.cuenta;        
       
    -- // VALIDA QUE EL PRODUCTO PERMITA CANCELAR
    SELECT COUNT(*)
      INTO vProdCanc
      FROM bdicheq:"informix".sc_productonocancelacion
     WHERE producto = cProducto;
     
    IF vProdCanc > 0 THEN
        LET cCodRet = '056';
        LET cCodRet2 = '342';
        
        SELECT TRIM(descripcion)
          INTO cMensajeRet
          FROM bdinteg:"informix".si_codret
         WHERE sistema = '01'
           AND codigo_retorno = cCodRet;
        
        RETURN cCodRet, cCodRet2, cMensajeRet, cFolioCancel;
    END IF;
    
    -- // VALIDA EL STATUS DE LA CUENTA
    IF cStatusCta NOT IN('1','4','7') THEN
        LET cCodRet = '060';
        LET cCodRet2 = '326'; 
        
        SELECT TRIM(descripcion)
          INTO cMensajeRet
          FROM bdinteg:"informix".si_codret
         WHERE sistema = '01'
           AND codigo_retorno = cCodRet;
        
        RETURN cCodRet, cCodRet2, cMensajeRet, cFolioCancel;
    END IF;
    
    -- // VALIDA QUE NO TENGA SALDO SBC Ó SALDO CCC
    IF ( mImp_chq_sbc <>  0.00 OR mimp_sbg_ccc <>  0.00 ) THEN 
        LET cCodRet = '066';
        LET cCodRet2 = '328'; 
        
        SELECT TRIM(descripcion)
          INTO cMensajeRet
          FROM bdinteg:"informix".si_codret
         WHERE sistema = '01'
           AND codigo_retorno = cCodRet;
        
        RETURN cCodRet, cCodRet2, cMensajeRet, cFolioCancel;
    END IF;
    
    -- // VALIDA QUE NO TENGA SALDO CONGELADO Ó SALDO RETENIDO
    IF ( mSdoCong <>  0.00 OR mSdoRet <>  0.00 ) THEN 
        LET cCodRet = '067';
        LET cCodRet2 = '329';
            
        SELECT TRIM(descripcion)
          INTO cMensajeRet
          FROM bdinteg:"informix".si_codret
         WHERE sistema = '01'
           AND codigo_retorno = cCodRet;
        
        RETURN cCodRet, cCodRet2, cMensajeRet, cFolioCancel;
    END IF;
	
    /*  ********  SE AGREGA VALIDACION PARA QUE NO EXISTA SPEI EN PROCESO ******/ 
    SELECT COUNT(*) 
      INTO vmovs
      FROM bdicheq:"informix".sc_movdia dia
     WHERE dia.cuenta = pCuenta
       AND dia.transacc = '0274';

    IF vmovs > 0 THEN
        LET cCodRet = '072';
        LET cCodRet2 = '548'; --
        
        SELECT TRIM(descripcion)
          INTO cMensajeRet
          FROM bdinteg:"informix".si_codret
         WHERE sistema = '01'
           AND codigo_retorno = cCodRet;
        
        RETURN cCodRet, cCodRet2, cMensajeRet, cFolioCancel;
    END IF
	/*  ********  SE AGREGA VALIDACION PARA QUE NO EXISTA SPEI EN PROCESO ******/ 
	
    -- // VALIDA QUE NO TENGA COMISIONES PENDIENTES
    IF mCom_pendiente <>  0.00 THEN 
        LET cCodRet = '068';
        LET cCodRet2 = '330'; 
        
        SELECT TRIM(descripcion)
          INTO cMensajeRet
          FROM bdinteg:"informix".si_codret
         WHERE sistema = '01'
           AND codigo_retorno = cCodRet;
        
        RETURN cCodRet, cCodRet2, cMensajeRet, cFolioCancel;
    END IF;
    
    -- // VALIDA QUE NO TENGA SALDO SOBREGIRADO
    IF mImp_chq_sbg <> 0.00 THEN 
        LET cCodRet = '065';
        LET cCodRet2 = '331';
        
        SELECT TRIM(descripcion)
          INTO cMensajeRet
          FROM bdinteg:"informix".si_codret
         WHERE sistema = '01'
           AND codigo_retorno = cCodRet;
        
        RETURN cCodRet, cCodRet2, cMensajeRet, cFolioCancel;
    END IF;
    
    -- // VALIDA QUE NO TENGA SALDO DISPONIBLE
    IF mSdoAct <> 0.00 THEN  
        LET cCodRet = '064';
        LET cCodRet2 = '327'; 
        
        SELECT TRIM(descripcion)
          INTO cMensajeRet
          FROM bdinteg:"informix".si_codret
         WHERE sistema = '01'
           AND codigo_retorno = cCodRet;
        
        RETURN cCodRet, cCodRet2, cMensajeRet, cFolioCancel;        
    END IF;
    
    -- // VALIDA NO TENGA ASOCIADOS CREDITOS VIGENTES
    SELECT COUNT(*)
      INTO vCredAsoc
      FROM bdicred:"informix".sd_ctascarg
     WHERE num_cta = cCuenta
       AND naturaleza = naturaleza;
       
    IF vCredAsoc > 0 THEN
        SELECT COUNT(*)
          INTO vCreditos
          FROM bdicred:"informix".sd_maecred a,
               bdicred:"informix".sd_ctascarg b
         WHERE a.empresa = pEmpresa
           AND a.numcte = cNumCte
           AND b.num_credito = a.num_credito
           AND b.naturaleza = b.naturaleza
           AND b.num_cta = cCuenta
           AND a.status_cred NOT IN('FF', 'FI', 'CV');
           
        SELECT COUNT(*)
          INTO vCredCrd
          FROM bdicred:"informix".sd_maecredcrd a,
               bdicred:"informix".sd_ctascarg b
         WHERE a.empresa = pEmpresa
           AND a.numcte = cNumCte
           AND b.num_credito = a.num_credito
           AND b.naturaleza = b.naturaleza
           AND b.num_cta = cCuenta
           AND a.status_cred NOT IN('FF', 'FI', 'CV');
           
        IF ( vCreditos > 0 OR vCredCrd > 0 ) THEN
            LET cCodRet = '057';
            LET cCodRet2 = '332';
            
            SELECT TRIM(descripcion)
              INTO cMensajeRet
              FROM bdinteg:"informix".si_codret
             WHERE sistema = '01'
               AND codigo_retorno = cCodRet;  
            
            RETURN cCodRet, cCodRet2, cMensajeRet, cFolioCancel;
        END IF;
    END IF;

    -- // VALIDA QUE NO TENGA ANTICIPO DE NOMINA
	SELECT COUNT(*)
      INTO vAnticipoNom
      FROM bdicred:"informix".sd_maecred a,
           bdisolic:"informix".ss_adn_solicitudcuenta b, 
           bdicred:"informix".sd_maesdos c
     WHERE a.empresa = pEmpresa
       AND a.numcte = b.numcte
       AND b.cuenta_nomina = pCuenta
       AND a.numcte = cNumCte
       AND b.num_solicitud = a.num_credito
       AND b.num_solicitud = c.num_credito
       AND a.status_cred NOT IN('FF', 'FI', 'CV')
       AND c.sdo_cap_insoluto > 0;
		   
    IF vAnticipoNom > 0 THEN
        LET cCodRet = '049'; 
        LET cCodRet2 = '332';
        
        SELECT TRIM(descripcion)
          INTO cMensajeRet
          FROM bdinteg:"informix".si_codret
         WHERE sistema = '01'
           AND codigo_retorno = cCodRet;  
        
        RETURN cCodRet, cCodRet2, cMensajeRet, cFolioCancel;
    END IF;
        
    -- // VALIDA NO TENGA ASOCIADAS CUENTAS PROAC ACTIVAS
    SELECT COUNT(*)
      INTO vCtasProac
      FROM bdicheq:"informix".sc_proac
     WHERE cta_eje = cCuenta
       AND num_cte = cNumCte
       AND status_cta IN('1','3');
       
    IF vCtasProac > 0 THEN
        LET cCodRet = '058';
        LET cCodRet2 = '333';
        
        SELECT TRIM(descripcion)
          INTO cMensajeRet
          FROM bdinteg:"informix".si_codret
         WHERE sistema = '01'
           AND codigo_retorno = cCodRet;
        
        RETURN cCodRet, cCodRet2, cMensajeRet, cFolioCancel;
    END IF;
    
    -- // VALIDA NO TENGA ASOCIADOS PAGARES ACTIVOS
    SELECT COUNT(*)
      INTO vPagares
      FROM bdinvers:"informix".sv_maeinv
     WHERE status_cta = '1'
       AND num_cte = cNumCte
       AND cta_cheques = cCuenta;
       
    IF vPagares > 0 THEN
        LET cCodRet = '061';
        LET cCodRet2 = '334';
        
        SELECT TRIM(descripcion)
          INTO cMensajeRet
          FROM bdinteg:"informix".si_codret
         WHERE sistema = '01'
           AND codigo_retorno = cCodRet;
        
        RETURN cCodRet, cCodRet2, cMensajeRet, cFolioCancel;
    END IF;
       
    -- // VALIDA NO TENGA ASOCIADOS INVERSIONES CRECIENTEES ACTIVAS
    SELECT COUNT(*)
      INTO vInvCrec
      FROM bdicheq:"informix".sc_maechq mae,
           bdicheq:"informix".sc_maeinstrucc ins
     WHERE ins.cuentadep = cCuenta
       AND mae.cuenta = ins.cuenta --- ASH
       AND mae.status_cta IN('1','3','4','5','6');
       
    IF vInvCrec > 0 THEN
        LET cCodRet = '063';
        LET cCodRet2 = '336';
        
        SELECT TRIM(descripcion)
          INTO cMensajeRet
          FROM bdinteg:"informix".si_codret
         WHERE sistema = '01'
           AND codigo_retorno = cCodRet;
        
        RETURN cCodRet, cCodRet2, cMensajeRet, cFolioCancel;
    END IF;
           
    -- // VALIDA NO TENGA ACLARACIONES PENDIENTES
    SELECT COUNT(*) 
      INTO vAclara
      FROM bdiaclaracion:"informix".acl_producto pr,
           bdiaclaracion:"informix".acl_aclaracion ac
     WHERE pr.numero_cuenta = pCuenta
       AND pr.pky_producto = ac.fky_producto
       AND ac.fky_estatus_aclaracion = '2';
    
    IF vAclara > 0 THEN
        LET cCodRet = '071';
        LET cCodRet2 = '317';
        
        SELECT TRIM(descripcion)
          INTO cMensajeRet
          FROM bdinteg:"informix".si_codret
         WHERE sistema = '01'
           AND codigo_retorno = cCodRet;
        
        RETURN cCodRet, cCodRet2, cMensajeRet, cFolioCancel;
    END IF;
    
    -- // VERIFICA QUE NO TENGA PROVISION DE INTERESES 
    IF mint_acum > 0.00 THEN
        LET vhora = current hour to fraction;
        LET vfolio_suc = pPromotor||SUBSTR(vhora,1,2)||SUBSTR(vhora,4,2)||SUBSTR(vhora,7,2)||SUBSTR(vhora,10,2);
        
        INSERT INTO sc_movdia VALUES 
        ( 0, vfolio_suc, pSucursal, pPromotor, dFechaCancel, dFechaCancel, vhora, '3382', cSucursal, cProducto, pEmpresa, pCuenta, '', 0, 
          mint_acum, mint_acum, 0.00, 0.00, 0, '', cStatusCta, mSdoAct, '0000', 'DESPROVISION DE INTERESES', 0, '', '' , '', dFechaCancel);
    END IF;
    
    -- // ASIGNA MOTIVO POR TRASPASO A LA BENEFICENCIA
	IF cStatusCta = "7" THEN
		LET pMotivo = "14";
	END IF
	
    -- // CANCELA LA CUENTA
    UPDATE bdicheq:"informix".sc_maechq
       SET status_cta = '2', 
           motivo = pMotivo,
           fec_cancelac = dFechaCancel     
     WHERE empresa = pEmpresa
       AND cuenta = cCuenta;
    
    -- // CANCELA TARJETAS 
    FOREACH
        SELECT tar.num_tarjeta, tarj.codproductotarjeta 
          INTO c_numtarjeta, cCodProdTarjeta
          FROM bdicheq:"informix".sc_tarjeta tar,
               intercard: 'informix'.tarjeta tarj
         WHERE tar.empresa = pEmpresa
           AND tar.cuenta = cCuenta
           AND tar.status_tar <> 'C'
           AND tarj.numtarjeta = tar.num_tarjeta
        
        -- // EN INTERCARD
        EXECUTE PROCEDURE intercard:'informix'.sp_cancelacion_tarjeta(c_numtarjeta, cCodProdTarjeta, pPromotor)
        INTO cCodRetIntCar, cMsjeIntCar;
        
        -- // EN CHEQUES
        UPDATE bdicheq:"informix".sc_tarjeta
           SET status_tar = 'C'
         WHERE empresa = pEmpresa
           AND cuenta = cCuenta
           AND num_tarjeta = c_numtarjeta; 
    END FOREACH;
    
    -- // CANCELA LAS CHEQUERAS
    UPDATE bdicheq:"informix".sc_contch
       SET estado = 'C'
     WHERE empresa = pEmpresa
       AND cuenta = cCuenta
       AND estado = 'A';
    
    -- // CANCELA LOS PAGOS PROGRAMADOS
    FOREACH
        SELECT cve_pagoprog 
          INTO vcvepprog 
          FROM bdiprog:pp_pagoprog 
         WHERE num_cte = cNumCte 
           AND cuenta_origen = pCuenta 
           AND cve_estado = '01'
        
        IF vcvepprog is not null OR vcvepprog <> '' THEN
            SELECT DECODE(tpo_sucursal,"S","01","N","02","") 
              INTO vcanal 
              FROM bdinteg:si_sucursales 
             WHERE sucursal = pSucursal;

            EXECUTE PROCEDURE bdiprog:"informix".sp_cancelaprogramacion('02', cNumCte, vcanal,vcvepprog, vmaxcvepp, pPromotor)
            INTO sCodRetCancProg, sDescRetCancProg;
            
            IF sCodRetCancProg::INTEGER <> 0 THEN
                IF sCodRetCancProg::INTEGER <> 10052 THEN
                    LET cCodRet  = sCodRetCancProg;
                    LET cCodRet2 = sCodRetCancProg;
                    LET cMensajeRet = sDescRetCancProg;
                    RETURN cCodRet, cCodRet2, NVL(cMensajeRet,''), cFolioCancel;
                END IF
            END IF
        END IF 
    END FOREACH;
    
	SELECT tpo_sucursal 
	  INTO vtipo_sucursal  
	  FROM bdinteg:si_sucursales 
     WHERE sucursal = pSucursal;
	
	-- // AGREGA SITUACION ESPECIAL AL CLIENTE EN CASO DE MOTIVO CANCELACION 
	-- // POR FALLECIMIENTO O POR FRAUDE CONSUMADO
	IF pMotivo ='04' OR pMotivo ='08'  THEN
        EXECUTE PROCEDURE bdicheq:"informix".sp_ctes_sit_especial(cNumCte, pMotivo, pPromotor, pSucursal )
        INTO sCodRetCteesp,sCodRetCteesp, sDescRetcteesp;
	
        IF sCodRetCteesp::INTEGER <> 0 THEN
            LET cCodRet  = sCodRetCteesp;
            LET cCodRet2 = sCodRetCteesp;
            LET cMensajeRet = sDescRetcteesp;
            RETURN cCodRet, cCodRet2, NVL(cMensajeRet,''), cFolioCancel;
        END IF
	END IF
	
    -- // FOLIO DE CANCELACION
    LET cFolioCancel = LPAD(pPromotor,8,'0')||YEAR(dFechaCancel)||LPAD(MONTH(dFechaCancel),2,'0')||LPAD(DAY(dFechaCancel),2,'0')||LPAD(SUBSTR(dtHoraActual,1,2),2,'0')||LPAD(SUBSTR(dtHoraActual,4,2),2,'0')||LPAD(SUBSTR(dtHoraActual,7,2),2,'0');
                       
    -- // GUARDA REGISTRO DE CANCELACION    
    INSERT INTO bdicheq:"informix".sc_ctacancelada
    ( empresa, cuenta, folio_cancelacion, motivo, promotor_cancelo, sucursal, fecha_cancelacion )
    VALUES
    ( pEmpresa, pCuenta, cFolioCancel, pMotivo, pPromotor, pSucursal, dFechaCancel );
    
    LET cCodRet  = '069';
    LET cCodRet2 = '340';
        
    SELECT TRIM(descripcion)
      INTO cMensajeRet
      FROM bdinteg:"informix".si_codret
     WHERE sistema = '01'
       AND codigo_retorno = cCodRet;
    
    RETURN cCodRet, cCodRet2, cMensajeRet, cFolioCancel;
    
    END;
    
END PROCEDURE

DOCUMENT
'DESCRIPCION: Se genera el proceso para cancelar las cuentas de cheques en OFI/SIF',
'AUTOR: Jesus Antonio Bastidas Lopez',
'FECHA: 03/Agosto/2012',
'Version: 20120803.0928',
'BD: bdicheq',
'MODIFICACION: Se agrega validacion de Aclaracion pendiente y cancelacion de cheques en el caso de producto (1900)',
'MODIFICO: Sergio Fernandez Cordero',
'FECHA: 20/Septiembre/2012', 
'MODIFICACION: Reingenieria del proceso de cancelación',
'MODIFICO: Jorge Ivan Camacho Sánchez',
'FECHA: 30/Mayo/2013',
'MODIFICACION: se mejora modulo agregando situaciones especiales del cliente.',
'MODIFICO: Sergio Fernandez Cordero',
'FECHA: 15/Agosto/2013';

CREATE PROCEDURE "informix".sp_cancela_cuentas(pempresa CHAR(3))
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER;
    
    DEFINE vcodret1      CHAR(5);
    DEFINE vcodret2      CHAR(5);
    DEFINE vcodret3      CHAR(50);
    DEFINE sql_err       INTEGER;
    DEFINE isam_err      INTEGER;
    DEFINE desc_err      CHAR(50);
    DEFINE vcontador1    INTEGER;
    DEFINE vcontador2    INTEGER;
    DEFINE vcomienza     SMALLINT;
    DEFINE ven_transacc  SMALLINT;
    DEFINE vsql          CHAR(500);
    DEFINE vstmt         CHAR(250);
    DEFINE vcuenta       CHAR(20);
    DEFINE vmotivo       CHAR(2);    
    DEFINE vusuario      CHAR(8);
    DEFINE vsucursal     CHAR(4);
    DEFINE vcodretcan1   CHAR(5);
    DEFINE vcodretcan2   CHAR(5);
    DEFINE vmsjretcan    CHAR(80);
    DEFINE vfolioretcanc CHAR(22);
    
    LET vcodret1      = '000';
    LET vcodret2      = '000';
    LET vcodret3      = 'PROCESO CONCLUIDO SATISFACTORIAMENTE';
    LET sql_err	      = 0;
    LET isam_err      = 0;
    LET desc_err      = '';
    LET vcontador1    = 0;
    LET vcontador2    = 0;
    LET vcomienza     = -1;
    LET ven_transacc  = 0;
    LET vsql          = '';
    LET vstmt         = '';
    LET vcuenta       = '';
    LET vmotivo       = '';
    LET vusuario      = '';
    LET vsucursal     = '';
    LET vcodretcan1   = '';
    LET vcodretcan2   = '';
    LET vmsjretcan    = '';
    LET vfolioretcanc = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cancela_cuentas.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcodret3, vcontador1, vcontador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cancela_cuentas.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'cuentasxcancelar') THEN
        DROP TABLE "informix".cuentasxcancelar;
    END IF;
    
    CREATE TABLE "informix".cuentasxcancelar
      (
        cuenta   char(20) not null,
        motivo   char(2)  not null,
        usuario  char(8)  not null,
        sucursal char(4)  not null
      )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_ctaxcanc ON "informix".cuentasxcancelar(cuenta) ONLINE;
      
    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/cuentasxcancelar.unl DELIMITER ''","'' INSERT INTO cuentasxcancelar;" > /resplogifx/conciliachq/ctasxcanc.sql';
    SYSTEM vsql;
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctasxcanc.sql';
    SYSTEM vstmt;
    
    UPDATE STATISTICS MEDIUM FOR TABLE cuentasxcancelar;
    
    FOREACH WITH HOLD
        SELECT cuenta, motivo, usuario, sucursal
          INTO vcuenta, vmotivo, vusuario, vsucursal
          FROM cuentasxcancelar
        
        BEGIN WORK;
        LET ven_transacc = 1;
        LET vcontador1 = vcontador1 + 1;
        
        CALL sp_cancelactachq(pempresa, vcuenta, vmotivo, vusuario, vsucursal)
        RETURNING vcodretcan1, vcodretcan2, vmsjretcan, vfolioretcanc;
               
        IF vcodretcan1 = '000' THEN
            LET vcontador2 = vcontador2 + 1;
            COMMIT WORK;
            LET ven_transacc = 0;
        ELSE
            ROLLBACK WORK;
            LET ven_transacc = 0;
        END IF;
        
        LET vcuenta = '';
        LET vmotivo = '';
        LET vusuario = '';
        LET vsucursal = '';
        LET vcodretcan1 = '';
        LET vcodretcan2 = '';
        LET vmsjretcan = '';
        LET vfolioretcanc = '';
    END FOREACH;
    
    END;
    
    RETURN vcodret1, vcodret2, vcodret3, vcontador1, vcontador2;
    
END PROCEDURE;