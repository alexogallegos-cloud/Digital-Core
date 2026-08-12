CREATE PROCEDURE "informix".sp_cancelactachq_web( pEmpresa  CHAR(3), pCuenta   CHAR(20), pMotivo   CHAR(2), pPromotor CHAR(8), pSucursal CHAR(4) )
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
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cancelactachq.err";
        --- TRACE ON;
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;
            LET cCodRet2 = iIsamErr;
            LET cMensajeRet = cErrorInfo;
            RETURN cCodRet, cCodRet2, cMensajeRet, cFolioCancel;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cancelactachq.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ; 
    SET LOCK MODE TO WAIT 3;
    
    -- // SE VALIDAN LOS PARAMETROS DE ENTRADA
    IF ( pEmpresa  is null OR pEmpresa  = '' ) OR
       ( pCuenta   is null OR pCuenta   = '' ) OR
       ( pMotivo   is null OR pMotivo   = '' ) OR
       ( pPromotor is null OR pPromotor = '' ) OR
       ( pSucursal is null OR pSucursal = '' ) THEN
        LET cCodRet = '00050';
        LET cCodRet2 = '00343';
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
        LET cCodRet = '00056';
        LET cCodRet2 = '00342';
        
        SELECT TRIM(descripcion)
          INTO cMensajeRet
          FROM bdinteg:"informix".si_codret
         WHERE sistema = '01'
           AND codigo_retorno = cCodRet;
        
        RETURN cCodRet, cCodRet2, cMensajeRet, cFolioCancel;
    END IF;
    
    -- // VALIDA EL STATUS DE LA CUENTA
    IF cStatusCta NOT IN('1','4','7') THEN
        LET cCodRet = '00060';
        LET cCodRet2 = '00326'; 
        
        SELECT TRIM(descripcion)
          INTO cMensajeRet
          FROM bdinteg:"informix".si_codret
         WHERE sistema = '01'
           AND codigo_retorno = cCodRet;
        
        RETURN cCodRet, cCodRet2, cMensajeRet, cFolioCancel;
    END IF;
    
    -- // VALIDA QUE NO TENGA SALDO SBC Ã SALDO CCC
    IF ( mImp_chq_sbc <>  0.00 OR mimp_sbg_ccc <>  0.00 ) THEN 
        LET cCodRet = '00066';
        LET cCodRet2 = '00328'; 
        
        SELECT TRIM(descripcion)
          INTO cMensajeRet
          FROM bdinteg:"informix".si_codret
         WHERE sistema = '01'
           AND codigo_retorno = cCodRet;
        
        RETURN cCodRet, cCodRet2, cMensajeRet, cFolioCancel;
    END IF;
    
    -- // VALIDA QUE NO TENGA SALDO CONGELADO Ã SALDO RETENIDO
    IF ( mSdoCong <>  0.00 OR mSdoRet <>  0.00 ) THEN 
        LET cCodRet = '00067';
        LET cCodRet2 = '00329';
            
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
        LET cCodRet = '00072';
        LET cCodRet2 = '00548'; --
        
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
        LET cCodRet = '00068';
        LET cCodRet2 = '00330'; 
        
        SELECT TRIM(descripcion)
          INTO cMensajeRet
          FROM bdinteg:"informix".si_codret
         WHERE sistema = '01'
           AND codigo_retorno = cCodRet;
        
        RETURN cCodRet, cCodRet2, cMensajeRet, cFolioCancel;
    END IF;
    
    -- // VALIDA QUE NO TENGA SALDO SOBREGIRADO
    IF mImp_chq_sbg <> 0.00 THEN 
        LET cCodRet = '00065';
        LET cCodRet2 = '00331';
        
        SELECT TRIM(descripcion)
          INTO cMensajeRet
          FROM bdinteg:"informix".si_codret
         WHERE sistema = '01'
           AND codigo_retorno = cCodRet;
        
        RETURN cCodRet, cCodRet2, cMensajeRet, cFolioCancel;
    END IF;
    
    -- // VALIDA QUE NO TENGA SALDO DISPONIBLE
    IF mSdoAct <> 0.00 THEN  
        LET cCodRet = '00064';
        LET cCodRet2 = '00327'; 
        
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
            LET cCodRet = '00057';
            LET cCodRet2 = '00332';
            
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
        LET cCodRet = '00049'; 
        LET cCodRet2 = '00332';
        
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
        LET cCodRet = '00058';
        LET cCodRet2 = '00333';
        
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
        LET cCodRet = '00061';
        LET cCodRet2 = '00334';
        
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
        LET cCodRet = '00063';
        LET cCodRet2 = '00336';
        
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
        LET cCodRet = '00071';
        LET cCodRet2 = '00317';
        
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
    
    LET cCodRet  = '00069';
    LET cCodRet2 = '00340';
        
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
'MODIFICACION: Reingenieria del proceso de cancelaciÃ³n',
'MODIFICO: Jorge Ivan Camacho SÃ¡nchez',
'FECHA: 30/Mayo/2013',
'MODIFICACION: se mejora modulo agregando situaciones especiales del cliente.',
'MODIFICO: Sergio Fernandez Cordero',
'FECHA: 15/Agosto/2013';

CREATE PROCEDURE "informix".sp_conscuenta_activa( pEmpresa CHAR(3), pNumCte CHAR(20), pProducto CHAR(4))

RETURNING CHAR(6)  AS Codigo,  				-- Codigo de Retorno
		  CHAR(20) AS CuentaCaptacion; 		-- CUENTA DE CAPTACION

-----------------------------------------------------------------------------------------------------------------
-- MODIFICO: Jose Luis Pulido Zepeda
-- Descripcion del cambio: Se agrego el codigo del producto como parametro de entrada para filtro que tome solo las cuentas que concuerden
--						 con el producto que se encuentra en la tabla bdisolic:ss_producto_credcap
-- Fecha: 2009/09/22
-- Version: 20090922.1540

-- MODIFICO: Jose Luis Pulido Zepeda
-- Descripcion del cambio: Se cambio la validacion de cuentas bloquedas con derecho a deposito, tambiÃ©n se cambio la validacion para verificar si
--						 existen cuentas de captacion activas.
-- Fecha: 2009/09/25
-- Version: 20090925.1252
-----------------------------------------------------------------------------------------------------------------
-- Nombre: Paul Ivan Quintero Varela.
-- Fecha: 07/10/2009 
-- Observaciones: Se modifica para que ademas de los bloqueos contemplados que son el 2 y 4 tampoco contemple
--                        las opciones 1 y 3 se anexa la descripciÃ³n de los bloqueos.
-- Tabla bdicheq:sc_opcionbloqueo.
-- 1	BLOQUEO DE IMPORTE DETERMINADO     
-- 2	BLOQUEO RECEPCION DE DEPOSITOS     
-- 3	BLOQUEO DE CARGOS                  
-- 4	BLOQUEO TOTAL DE CUENTA            
-- 0	CUENTA HABILITADA **
-----------------------------------------------------------------------------------------------------------------
-- Nombre: Paul Ivan Quintero Varela.
-- Fecha: 10/10/2009 
-- Observaciones: Se modifica para que solo contemple lo siguiente que se indica con el simbolo (**) :

-- Tabla bdicheq:sc_opcionbloqueo.
-- 0	CUENTA HABILITADA **
-- 1	BLOQUEO DE IMPORTE DETERMINADO     
-- 2	BLOQUEO RECEPCION DE DEPOSITOS     
-- 3	BLOQUEO DE CARGOS                  
-- 4	BLOQUEO TOTAL DE CUENTA            

-- Tabla bdicheq:sc_maechq
-- 1	ACTIVA **
-- 2	CANCELADA
-- 3	BLOQUEADA

-- Tabla bdicheq:sc_bloqueo
--00	DESBLOQUEO DE CUENTA               	S	S  **
--99	POR ORDEN JUDICIAL                 	N	S
--04	POR FALLECIMIENTO                  	N	N
--05	POR TRASPASO JURIDICO              	S	S
--02	PETICION DEL CLIENTE               	N	N
--03	POR EMBARGO                        	N	S
--07	POR CHEQUE DEVUELTO                	S	S
--08	POR ROBO O EXTRAVIO DE CHEQUE      	S	S
--09	BLOQUEO ADMINISTRATIVO             	N	N
--10	BLOQUEO POR CAMBIO DE CHEQUE       	S	S
--06	POR ROBO O EXTRAVIO DE TARJETA     	N	S

-----------------------------------------------------------------------------------------------------------------

		  
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************

DEFINE cCodRet     		CHAR(6); 	-- CODIGO DE RETORNO
DEFINE iSqlErr      	INTEGER; 	-- CODIGO DE ERROR DE INFORMIX
DEFINE cCuenta     		CHAR(20);	-- CUENTA DE CAPTACION
DEFINE iNumReg			INTEGER;	-- NUMERO DE REGISTROS

LET cCodRet		= "000000";
LET iSqlErr		= 0;
LET cCuenta		= "";
LET iNumReg		= 0;

BEGIN

	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0  THEN
			LET cCodRet  = iSqlErr;
			RETURN cCodRet,NVL(cCuenta,'');
		END IF;
	END EXCEPTION;
	
-- SET DEBUG FILE TO "/tmp/sp_conscuenta_activa.out";
-- TRACE ON;

	SET ISOLATION TO DIRTY READ; 
    SET LOCK MODE TO WAIT 3;
	
	-- SE VALIDA QUE LOS PARAMETROS DE ENTRADA SEAN CORRECTOS
	IF NVL(pEmpresa,"") = "" OR NVL(pNumCte,"") = "" THEN
		LET cCodRet = '000001';
		RETURN cCodRet,NVL(cCuenta,'');
	END IF;

--FMV 17-FEB-2012: Si es credinomina, recupera la 1er. cuenta con la que calculo el promedio mensual
    IF pProducto = '6400' THEN
        LET cCuenta = '';
        SELECT max(cuenta)
          INTO cCuenta
		  FROM bdisolic:ss_solicitudes a,
               bdisolic:ss_sol_nomina b
		 WHERE a.empresa = pEmpresa         
		   AND a.empresa = b.empresa
		   AND a.num_solicitud = b.num_solicitud
		   AND a.numcte = pNumCte
           AND a.numcte = b.numcte
		   AND a.status_solicitud = 'AT'
		   AND a.num_producto = pProducto;
		   
		IF (cCuenta is null) THEN
			LET cCuenta = '';
		END IF;
		
        RETURN cCodRet,cCuenta;    
	ELSE
	-- SE OBTIENEN TODAS LAS CUENTAS DE CAPTACION ACTIVAS
		FOREACH
			  SELECT a.cuenta
				INTO cCuenta
				FROM bdicheq:sc_maechq a
		   LEFT JOIN bdicheq:sc_ctabloqueo b         ON (b.cuenta = a.cuenta)
		   LEFT JOIN bdicheq:sc_bloqueo c            ON (c.codigo = b.clave)
		  INNER JOIN bdisolic:ss_producto_credcap d  ON (d.empresa = a.empresa AND d.producto_cap = a.producto)
			   WHERE a.cuenta  = a.cuenta
				 AND a.empresa = pEmpresa 
				 AND a.num_cte = pNumCte 
				 AND d.num_producto = pProducto
				 AND NVL(opcion,'00') = '00'
				 AND NVL(c.codigo,'00') = '00'
				 AND a.status_cta = '1' 

				RETURN cCodRet,cCuenta WITH RESUME;
		END FOREACH;
		
		LET iNumReg = DBINFO("sqlca.sqlerrd2");
		
		IF (iNumReg = 0) THEN
			LET cCodRet = '000002';
			RETURN cCodRet,NVL(cCuenta,'');
		END IF
	END IF
		
end;
END PROCEDURE

DOCUMENT
'AUTOR: Jose Luis Pulido Zepeda',
'Descripcion: Regresa las cuentas de captacion activas de un cliente',
'Fecha: 2009/09/08',
'Version: 20090908.1636';

CREATE PROCEDURE "informix".sp_consultacuentasnominacliente_web(pEmpresa CHAR(3), pCliente CHAR(20), pNumRegistros SMALLINT)
RETURNING
	CHAR(5) AS cCodRet,
	CHAR(20) AS cNumCte,
	CHAR(26) AS cApPaterno,
	CHAR(26) AS cApMaterno,
	CHAR(26) AS cNombre1,
	CHAR(26) AS cNombre2,
	CHAR(13) AS cRFC,
    CHAR(20) AS cNumCta,
	CHAR(50) AS cNombre,
	CHAR(19) AS cCuentaClabe,
	CHAR(150) AS cEstatus,
	CHAR(8) AS cFechaSolicitud,
	CHAR(40) AS cInstFinanc,
	CHAR(150) AS cObservaciones,
	CHAR(8) AS cFechaRespSol,
	CHAR(8) AS cFechaNotificacion,
	CHAR(13) AS cRFCEmpresa,
	CHAR(8) AS cFechaCancelacion,
	CHAR(2) AS cEstatusPortabilidad,
	CHAR(1) AS cCveSentido,
	CHAR(5) AS cBcoOrdenante;

	--Declaracion de  Variables
	DEFINE cCodRet				  CHAR (5);
	DEFINE cSqlErr				  SMALLINT;
	DEFINE cCiclo				  SMALLINT;
	DEFINE cNumCte				  CHAR(20);
	DEFINE cApPaterno			  CHAR(26);
	DEFINE cApMaterno			  CHAR(26);
	DEFINE cNombre1				  CHAR(26);
	DEFINE cNombre2				  CHAR(26);
	DEFINE cRFC					  CHAR(13);
	DEFINE cNumCta				  CHAR(20) ;
	DEFINE cNombre				  CHAR(50);
	DEFINE cCuentaClabe			  CHAR(19);
    DEFINE cEstatus				  CHAR(150);
    DEFINE cFechaSolicitud		  CHAR(8);
    DEFINE cInstFinanc			  CHAR(40);
    DEFINE cObservaciones		  CHAR(150);
    DEFINE cFechaRespSol		  CHAR(8);
    DEFINE cFechaNotificacion	  CHAR(8);
    DEFINE cRFCEmpresa			  CHAR(13);
    DEFINE cFechaCancelacion	  CHAR(8);
    DEFINE cEstatusPortabilidad	  CHAR(2);
    DEFINE cCveSentido			  CHAR(1);
    DEFINE cBcoOrdenante		  CHAR(5);
    DEFINE cBcoReceptor			  CHAR(5);
    DEFINE cProducto			  CHAR(4);
    DEFINE cCta_ordenante		  CHAR(20);
    DEFINE cCta_receptora		  CHAR(20);
    DEFINE cClave_origen		  CHAR(1);
    DEFINE cEstatus_respuesta	  CHAR(2);
    DEFINE cEstatus_respuesta_res CHAR(2);
    DEFINE cfolio_solicitud       CHAR(30);

	--Inicializo Variables
	LET cCodRet					= '01285';
	LET cSqlErr					= 0;
	LET cCiclo					= 0;
	LET cNumCte					= '';
	LET cApPaterno				= '';
	LET cApMaterno				= '';
	LET cNombre1				= '';
	LET cNombre2				= '';
	LET cRFC					= '';
	LET cNumCta					= '';
	LET cNombre					= '';
	LET cEstatus				= '';
	LET cFechaSolicitud			= '';
	LET cInstFinanc				= '';
	LET cObservaciones			= '';
	LET cFechaRespSol			= '';
	LET cFechaNotificacion		= '';
	LET cRFCEmpresa				= '';
	LET cFechaCancelacion		= '';
	LET cCuentaClabe			= '';
	LET cEstatusPortabilidad	= '';
	LET cCveSentido				= '';
	LET cBcoOrdenante			= '';
	LET cBcoReceptor			= '';
	LET cProducto				= '';
	LET cCta_ordenante			= '';
	LET cCta_receptora			= '';
	LET cClave_origen			= '';
	LET cEstatus_respuesta		= '';
	LET cEstatus_respuesta_res	= '';
    LET cfolio_solicitud        = '';

	BEGIN	
	ON EXCEPTION SET cSqlErr
		IF cSqlErr <> 0 THEN
			let cCodRet = cSqlErr;
			RETURN cCodRet,cNumCte,cApPaterno,cApMaterno,cNombre1,cNombre2,cRFC,cNumCta,cNombre,cCuentaClabe,
                        cEstatus,NVL(cFechaSolicitud,''),NVL(cInstFinanc,''),NVL(cObservaciones,''),NVL(cFechaRespSol,''),NVL(cFechaNotificacion,''),NVL(cRFCEmpresa,''),NVL(cFechaCancelacion,''),NVL(cEstatusPortabilidad,''),NVL(cCveSentido,''),NVL(cBcoOrdenante,'');

		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/informix/sp_ConsultaCuentasNominaCliente.out";
	--TRACE ON; 

		 IF (SELECT 1 FROM "informix".sc_ctas_portab_temp WHERE num_cte = pCliente )> 0 THEN
			DELETE FROM "informix".sc_ctas_portab_temp WHERE num_cte = pCliente;
	     END IF;
		 
       INSERT INTO bdicheq:sc_ctas_portab_temp
        select max(folio_solicitud), cta_ordenante, num_cte from bdicheq:"informix".sc_portacec_solicitud
		 where num_cte =  pCliente
		 AND clave_sentido in ('1','0')
		 group by 2,3;
		 
	--Obtiene las cuentas del cliente
	IF (SELECT COUNT(numcte) FROM bdinteg:"informix".si_cliente WHERE numcte = pCliente) > 0 THEN
		IF (SELECT COUNT(num_cte) FROM bdicheq:"informix".sc_maechq WHERE num_cte = pCliente AND status_cta = '1') > 0 THEN
				
				FOREACH
				
                    SELECT si_cliente.numcte, si_cliente.apell_paterno, si_cliente.apell_materno, si_cliente.nombre1, si_cliente.nombre2,
                        si_cliente.rfc, scproducto.producto, scproducto.nombre, scmaechq.cuenta, scmaechq.cuenta_clabe,
                        cta_ordenante,cta_receptora,estatus_portabilidad,clave_sentido,clave_origen,bco_ordenante, folio_solicitud,
                        fecha_solicitud, estatus_respuesta, 
                        case when nvl(estatus_respuesta,'') = '' then estatus_cecoban else estatus_respuesta end, 
                        case when nvl(estatus_respuesta,'') = '' then fecha_estatus_cecoban else fecha_respuesta end,
                        fecha_presentacion, rfc_empresa, fecha_solca_portabilidad
    					INTO cNumCte, cApPaterno, cApMaterno, cNombre1, cNombre2, cRFC, cProducto, cNombre, cNumCta, cCuentaClabe,
                             cCta_ordenante,cCta_receptora,cEstatusPortabilidad,cCveSentido,cClave_origen,cBcoOrdenante, cfolio_solicitud,
                             cFechaSolicitud, cEstatus_respuesta_res, cEstatus_respuesta,cFechaRespSol,
                             cFechaNotificacion, cRFCEmpresa, cFechaCancelacion
                        FROM bdinteg:"informix".si_cliente AS si_cliente
                        LEFT OUTER JOIN bdicheq:"informix".sc_maechq AS scmaechq ON (si_cliente.numcte = scmaechq.num_cte)
                        LEFT OUTER JOIN bdicheq:"informix".sc_producto AS scproducto ON (scmaechq.producto = scproducto.producto)
                        LEFT OUTER JOIN bdicheq:"informix".sc_portacec_solicitud AS solicitudporta ON (scmaechq.empresa = solicitudporta.empresa 
                        AND si_cliente.numcte = solicitudporta.num_cte AND scmaechq.cuenta_clabe =  solicitudporta.cta_ordenante)
                        WHERE si_cliente.empresa = pEmpresa
                        AND si_cliente.numcte = pCliente
                        AND scmaechq.status_cta = '1'                  
                        AND scproducto.producto in ((Select producto from bdicheq:"informix".sc_producportab where producto = scmaechq.producto and  activo = 1)) 
                        AND folio_solicitud in  (select max(case when 
												(select max(folio_solicitud) from sc_portacec_solicitud WHERE empresa = pEmpresa AND num_cte = pCliente and estatus_portabilidad = '1' and (scmaechq.cuenta_clabe =  solicitudporta.cta_ordenante OR scmaechq.cuenta_clabe = solicitudporta.cta_receptora) AND clave_sentido in ('1','0')) is null then 
												(select max(folio_solicitud) from sc_portacec_solicitud WHERE empresa = pEmpresa AND num_cte = pCliente and (scmaechq.cuenta_clabe =  solicitudporta.cta_ordenante OR scmaechq.cuenta_clabe = solicitudporta.cta_receptora) AND clave_sentido in ('1','0')) else
												(select max(folio_solicitud) from sc_portacec_solicitud WHERE empresa = pEmpresa AND num_cte = pCliente and estatus_portabilidad = '1' and (scmaechq.cuenta_clabe =  solicitudporta.cta_ordenante OR scmaechq.cuenta_clabe = solicitudporta.cta_receptora) AND clave_sentido in ('1','0')) end)
												FROM bdicheq:"informix".sc_portacec_solicitud
												WHERE empresa = pEmpresa AND num_cte = pCliente and (scmaechq.cuenta_clabe =  solicitudporta.cta_ordenante OR scmaechq.cuenta_clabe = solicitudporta.cta_receptora)
												AND clave_sentido in ('1','0'))
												
                        UNION 
                        SELECT  si_cliente.numcte, si_cliente.apell_paterno, si_cliente.apell_materno, si_cliente.nombre1, si_cliente.nombre2,
                        si_cliente.rfc, scproducto.producto, scproducto.nombre, scmaechq.cuenta, scmaechq.cuenta_clabe,
                        cta_ordenante,cta_receptora,estatus_portabilidad,clave_sentido,clave_origen,bco_ordenante, folio_solicitud,
                        fecha_solicitud, estatus_respuesta, 
                        case when nvl(estatus_respuesta,'') = '' then estatus_cecoban 
                                                                else estatus_respuesta end, 
                        case when nvl(estatus_respuesta,'') = '' then fecha_estatus_cecoban 
                                                                else fecha_respuesta end,
                        fecha_presentacion, rfc_empresa, fecha_solca_portabilidad
                        FROM bdinteg:"informix".si_cliente AS si_cliente
                        LEFT OUTER JOIN bdicheq:"informix".sc_maechq AS scmaechq ON (si_cliente.numcte = scmaechq.num_cte)
                        LEFT OUTER JOIN bdicheq:"informix".sc_producto AS scproducto ON (scmaechq.producto = scproducto.producto)
                        LEFT OUTER JOIN bdicheq:"informix".sc_portacec_solicitud AS solicitudporta ON (scmaechq.empresa = solicitudporta.empresa 
                        AND si_cliente.numcte = solicitudporta.num_cte AND (scmaechq.cuenta_clabe =  solicitudporta.cta_ordenante 
                        OR scmaechq.cuenta_clabe = solicitudporta.cta_receptora))
                        WHERE si_cliente.empresa = pEmpresa
                        AND si_cliente.numcte = pCliente
                        AND scmaechq.status_cta = '1'                
                        AND scproducto.producto in ((Select producto from bdicheq:"informix".sc_producportab where producto = scmaechq.producto and  activo = 1))
                        AND clave_sentido = '2' 
                         UNION 
                        SELECT  si_cliente.numcte, si_cliente.apell_paterno, si_cliente.apell_materno, si_cliente.nombre1, si_cliente.nombre2,
                        si_cliente.rfc, scproducto.producto, scproducto.nombre, scmaechq.cuenta, scmaechq.cuenta_clabe,
                        cta_ordenante,cta_receptora,estatus_portabilidad,clave_sentido,clave_origen,bco_ordenante, folio_solicitud,
                        fecha_solicitud, estatus_respuesta, 
                        case when nvl(estatus_respuesta,'') = '' then estatus_cecoban 
                                                                else estatus_respuesta end, 
                        case when nvl(estatus_respuesta,'') = '' then fecha_estatus_cecoban
                                                                else fecha_respuesta end,
                        fecha_presentacion, rfc_empresa, fecha_solca_portabilidad

                        FROM bdinteg:"informix".si_cliente AS si_cliente
                        LEFT OUTER JOIN bdicheq:"informix".sc_maechq AS scmaechq ON (si_cliente.numcte = scmaechq.num_cte)
                        LEFT OUTER JOIN bdicheq:"informix".sc_producto AS scproducto ON (scmaechq.producto = scproducto.producto)
                        LEFT OUTER JOIN bdicheq:"informix".sc_portacec_solicitud AS solicitudporta ON (scmaechq.empresa = solicitudporta.empresa 
                        AND si_cliente.numcte = solicitudporta.num_cte AND (scmaechq.cuenta_clabe =  solicitudporta.cta_ordenante 
                        OR scmaechq.cuenta_clabe = solicitudporta.cta_receptora))
                        WHERE si_cliente.empresa = pEmpresa
                        AND si_cliente.numcte = pCliente
                        AND scmaechq.status_cta = '1'
                        AND scproducto.producto in ((Select producto from bdicheq:"informix".sc_producportab where producto = scmaechq.producto and  activo = 1))
                        AND clave_sentido is null
                        ORDER BY scmaechq.cuenta_clabe, clave_sentido,estatus_portabilidad ASC, folio_solicitud DESC
                              
                        LET cCiclo = cCiclo + 1;
                        IF cCiclo <= pNumRegistros THEN
                            CONTINUE FOREACH;
                        END IF;

						--Obtiene ESTATUS
						LET cEstatus = '';
						IF NVL(cCta_ordenante,'') <> '' OR NVL(cCta_receptora,'') <> '' THEN
							SELECT descripcion INTO cEstatus
							FROM bdicheq:"informix".sc_relacion_estatus
							WHERE estatus_portabilidad = cEstatusPortabilidad
							AND clave_sentido = cCveSentido AND clave_origen = cClave_origen;
						END IF;


						--Obtiene INSTITUCION FINANCIERA
						LET cInstFinanc = '';

						IF NVL(cClave_origen,'') = '1' OR NVL(cClave_origen,'') = '2' THEN
							SELECT descripcion INTO cInstFinanc FROM bdinteg:"informix".si_bancos
							WHERE banco = '137';
						ELSE
							IF NVL(cCta_ordenante,'') <> '' THEN
								SELECT descripcion INTO cInstFinanc FROM bdinteg:"informix".si_bancos
								WHERE banco = cBcoOrdenante;
							ELIF NVL(cCta_receptora,'') <> '' THEN
								SELECT descripcion INTO cInstFinanc FROM bdinteg:"informix".si_bancos
								WHERE banco = cBcoReceptor;
							END IF;
						END IF;

						IF NVL(cEstatus_respuesta_res,'') = '' THEN

							--Obtiene OBSERVACIONES
							SELECT descripcion INTO cObservaciones
							FROM bdicheq:"informix".sc_portacec_estatus_cecoban
							WHERE estatus_cecoban = cEstatus_respuesta;

						ELSE
							--Obtiene OBSERVACIONES
							SELECT descripcion INTO cObservaciones
							FROM bdicheq:"informix".sc_portacec_estatus_respuesta
							WHERE estatus_respuesta = cEstatus_respuesta;

						END IF;


						IF NVL(cRFCEmpresa,'') = '' THEN
							LET cRFCEmpresa = '';
						END IF;

						LET cCodRet = '00000'; 
						RETURN cCodRet,cNumCte,cApPaterno,cApMaterno,cNombre1,cNombre2,cRFC,cNumCta,cNombre,cCuentaClabe,
                        cEstatus,NVL(cFechaSolicitud,''),NVL(cInstFinanc,''),NVL(cObservaciones,''),NVL(cFechaRespSol,''),NVL(cFechaNotificacion,''),NVL(cRFCEmpresa,''),NVL(cFechaCancelacion,''),NVL(cEstatusPortabilidad,''),NVL(cCveSentido,''),NVL(cBcoOrdenante,'') WITH RESUME;

				END FOREACH;
		ELSE
			LET cCodRet = '00001';
		END IF;
	ELSE
		LET cCodRet = '00037';
	END IF;

	IF cCodRet <> '00000' THEN
		RETURN cCodRet,cNumCte,cApPaterno,cApMaterno,cNombre1,cNombre2,cRFC,cNumCta,cNombre,cCuentaClabe,
                        cEstatus,NVL(cFechaSolicitud,''),NVL(cInstFinanc,''),NVL(cObservaciones,''),NVL(cFechaRespSol,''),NVL(cFechaNotificacion,''),NVL(cRFCEmpresa,''),NVL(cFechaCancelacion,''),NVL(cEstatusPortabilidad,''),NVL(cCveSentido,''),NVL(cBcoOrdenante,'');

	END IF;
END;
END PROCEDURE
DOCUMENT
'Elaboro:Armida Pazos Chavez',
'Fecha: 20100525',
'Proyecto: Habilitar y Deshabilitar la Portabilidad de Nomina.',
'-----------------------------------------------------------------------',
'Folio: 1748',
'Autor: Claudio Almodovar',
'Fecha: 31/08/2015',
'Modificacion: Se modifica SP para portabilidad de nomina de otros bancos a bancoppel',
'Solicita: Rodolfo Gomez ',
'BD: bdicheq';

create procedure "informix".abono_web(pempresa   char(3), psucursal  char(4), pusuario   char(8), ptransacc  char(4), ptransuc   char(4), pfolio_suc char(16), pcuenta    char(20), pdocto     integer, pmto_tot   money(14,2), pmto_firme money(14,2), pmto_sbc   money(14,2), pmto_rem   money(14,2), pdias_ret  smallint, pdivisa    char(2))
   returning char(5);

   define vcodret char(5);
   define vsqlerr integer;
   define vsuccta char(4);
   define vproducto char(4);
   define vgencom,vcobracom,vvaldoc,vnat,vstatus,vaceptab char(1);
   define vmotivo  char(2);
   define vmoneda char(2);
   define vmontotran,vsdo_actual,vimpsbg,
          vtotal_sbc,vdepinic money(14,2);
   define vfecha_hoy,vfecha_prox date;
   define vhora datetime hour to fraction(3);
   define vusuario char(8);
   define vtasa_aplicada decimal(9,6);
   define vmarca_ret char(1);
   define vdepinicial,vmtominape,vdepminini money(14,2);
   define vacepta_depositos,vper_depositos char(1);
   define vdiasultdep,vdiasdep smallint;
   define vfecultmov,vfecultdep,vfecultret date;
   define vtranpagint,vtranusoccc,vtranusosbg,vtranabocol char(4);
   define preferencia char(30);
   define vfecha_operacion date;

   set isolation to cursor stability;
   set lock mode to wait 3;

   let vusuario = user;
   let preferencia = "";
   let vfecha_operacion = today;								

   if vusuario = "cs2" then
      commit work;
      begin work;
   end if;

   let preferencia = " ";
   let vcodret = "00000";
   let vtasa_aplicada = 0;
   let vgencom = 0;
   let vcobracom = "0";


begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
       if vusuario = "cs2" then
          rollback work;
          begin work;
       end if;
       return vcodret;
      end if
   end exception;

-- Valida la informacion de entrada
if psucursal  = "" or
   pusuario   = "" or
   ptransacc  = "" or
   pfolio_suc = "" or
   pcuenta    = "" or
   pmto_tot   = 0     or
   pmto_firme < 0     or
   pmto_sbc   < 0     or
   pmto_rem   < 0     or
   pdias_ret  < 0 then
   let vcodret = 00110;
   if vusuario = "cs2" then
      rollback work;
      begin work;
   end if;
   return vcodret;
 end if;

set isolation to dirty read;
select ejecutivo into vusuario
   from bdinteg:si_ejecut
   where ejecutivo = pusuario;
if vusuario <> pusuario or vusuario is null then
   let vcodret = "00106";
   if vusuario = "cs2" then
       rollback work;
       begin work;
   end if;
   return vcodret;
end if

-- Valida la suma de los montos
let vmontotran = pmto_firme + pmto_sbc + pmto_rem;
if vmontotran != pmto_tot or pmto_tot =0 then
   let vcodret = "00420";
   if vusuario = "cs2" then
      rollback work;
      begin work;
   end if;
   return vcodret;
end if;

-- Valida exista la transaccion
set isolation to dirty read;
select naturaleza,valida_docto,dias_ret
   into vnat,vvaldoc,pdias_ret
   from bdinteg:si_transacc
   where empresa = pempresa and numero = ptransacc;
if vnat is null then
   let vcodret = "00552";
   if vusuario = "cs2" then
      rollback work;
      begin work;
   end if;
   return vcodret;
end if;
if vnat != "A" then
   let vcodret = "00552";
   if vusuario = "cs2" then
      rollback work;
      begin work;
   end if;
   return vcodret;
end if;
if pdias_ret is null then
   let pdias_ret = 0;
end if;

select fecha_hoy,prox_fecha into vfecha_hoy,vfecha_prox
   from sc_fechas where empresa = pempresa;

-- Valida exista la cuenta
select status_cta into vstatus
   from sc_maechq
   where empresa = pempresa and cuenta = pcuenta;
if vstatus is null then
   let vcodret = "00100";
   if vusuario = "cs2" then
      rollback work;
      begin work;
   end if;
   return vcodret;
end if
if vstatus = "2" then
   let vcodret = "00200";
   if vusuario = "cs2" then
      rollback work;
      begin work;
   end if;
   return vcodret;
end if

-- Extrae los datos de la cuenta de cheques
set isolation to dirty read;
foreach abono_cursor for
   select status_cta,motivo,sucursal,producto,sdo_actual,marca_ret,
          fec_ult_mov,fecultdep,fecultret,imp_chq_sbg+imp_sbg_ccc
      into vstatus,vmotivo,vsuccta,vproducto,vsdo_actual,vmarca_ret,
          vfecultmov,vfecultdep,vfecultret,vimpsbg
      from sc_maechq
      where empresa = pempresa and cuenta = pcuenta

   set isolation to dirty read;
   select divisa,acepta_depositos,mtominape,
          per_depositos[1,1],per_depositos[3,5]
      into vmoneda,vacepta_depositos,vmtominape,
          vper_depositos,vdiasdep
      from sc_producto
      where empresa = pempresa and producto = vproducto;
   if vmoneda!= pdivisa then
      let vcodret="00951";
      if vusuario = "cs2" then
         rollback work;
         begin work;
      end if;
      return vcodret;
   end if;

   if vmarca_ret = "0" then   -- deposito inicial
      let vdepinicial = vsdo_actual + pmto_tot;
      if vdepinicial > vmtominape then
         if vacepta_depositos = "N" then
            let vcodret="00956";
            if vusuario = "cs2" then
               rollback work;
               begin work;
            end if;
            return vcodret;
         end if;
      end if
      if vdepinicial >= vmtominape then
         let vmarca_ret = "1";
      end if;
   else
      if vacepta_depositos = "N" then
         let vcodret="00956";
         if vusuario = "cs2" then
            rollback work;
            begin work;
         end if;
         return vcodret;
      else
         let vdiasultdep = vfecha_hoy - vfecultdep;
         if vdiasultdep < vdiasdep then
            let vcodret="00956";
            if vusuario = "cs2" then
               rollback work;
               begin work;
            end if;
            return vcodret;
         end if;
      end if;
   end if

   if vstatus = 3 then
        set isolation to dirty read;
        select abono into vaceptab
           from sc_bloqueo where codigo = vmotivo;
        if vaceptab = "N" then
           let vcodret = "00301";
           if vusuario = "cs2" then
             rollback work;
             begin work;
           end if;
           return vcodret;
        end if;
   end if;

   let vhora = current hour to fraction;
   select 1 into vgencom
      from sc_transcomis
      where empresa = pempresa and transacc = ptransacc;
   if vgencom is null then
      let vgencom = 0;
      let vcobracom = "0";
   end if

   if pmto_sbc > 0 then
      select sum(monto) into vtotal_sbc
         from sc_docret
         where empresa = pempresa and cuenta = pcuenta and
               folio_suc = pfolio_suc and fecha_alta = vfecha_hoy and
               siglas = "SC";
      if vtotal_sbc <> pmto_sbc then
         let vcodret="00401";
         if vusuario = "cs2" then
            rollback work;
            begin work;
         end if;
         return vcodret;
      end if;
   end if;

   insert into sc_movdia
      values(0,pfolio_suc,psucursal,pusuario,vfecha_hoy,vfecha_hoy,
             vhora,ptransacc,vsuccta,vproducto,pempresa,pcuenta,"",0,
             pmto_tot,pmto_firme,pmto_sbc,pmto_rem,pdias_ret,"","",
             vsdo_actual,ptransuc,preferencia,vtasa_aplicada,"","","",vfecha_operacion);

   -- Actualizacion al Maestro de Cheques
   update sc_maechq
      set fec_ult_mov = vfecha_hoy,
          num_abonos_mes = num_abonos_mes + 1,
          imp_abonos_mes = imp_abonos_mes + pmto_tot,
          sdo_actual = sdo_actual + pmto_tot,
	  sdo_retenido = sdo_retenido + pmto_sbc,
	  saldo_sbc = saldo_sbc + pmto_sbc,
          marca_ret = vmarca_ret,
          fecultdep = vfecha_hoy
      where empresa = pempresa and cuenta = pcuenta;

   -- Genera comision por transaccion
   if vgencom = "1" then
      call gencomtran(pempresa,pcuenta,ptransacc,pmto_tot,pfolio_suc,
                      psucursal,pusuario)
           returning vcodret;
      let vcobracom = "1";
   end if

   select valor into vtranpagint
      from sc_param
      where empresa = pempresa and codparam = "tranpagint";

   select valor into vtranusoccc
      from sc_param
      where empresa = pempresa and codparam = "tranusoccc";

   select valor into vtranabocol
      from sc_param
      where empresa = pempresa and codparam = "tranabocol";

   select valor into vtranusosbg
      from sc_param
      where empresa = pempresa and codparam = "tranusosbg";
{
   -- Cobra comisiones pendientes
   if ptransacc = vtranpagint or ptransacc = vtranabocol or
      ptransacc = vtranusoccc or ptransacc = vtranusosbg then
      let vcobracom = "0";
   else
      if vimpsbg > 0 then
         let vcobracom = "1";
      end if
      if vcobracom = "0" then
         select unique 1 into vcobracom
            from sc_detcomis
            where empresa = pempresa and cuenta = pcuenta and estado_com = "P";
         if vcobracom is null then
            let vcobracom = "0";
         else
            let vcobracom = "1";
         end if
      end if
   end if
   if vcobracom = "1" then
      call cobintcomsbg(pempresa,pcuenta,pfolio_suc,pusuario,psucursal)
           returning vcodret;
   end if
}
end foreach;

if vusuario = "cs2" then
   if vcodret = "00000" then
      commit work;
   else
      rollback work;
   end if
   begin work;
end if;

return vcodret;

end;

end procedure;