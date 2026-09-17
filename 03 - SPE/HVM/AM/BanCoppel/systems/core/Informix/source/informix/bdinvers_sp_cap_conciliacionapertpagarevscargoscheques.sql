CREATE PROCEDURE "informix".sp_cap_conciliacionapertpagarevscargoscheques(pFechaInicio DATE, pFechaFin DATE)
	RETURNING CHAR(5)	AS codigo_retorno,
			  CHAR(80)	AS mensaje_retorno;

	---DECLARACIONES   
	DEFINE cCodRet				CHAR(5); 
	DEFINE cMensajeRet			CHAR(80);	
	DEFINE iSqlErr				INTEGER;
	DEFINE iIsamErr				INTEGER;
	DEFINE cErrorInfo			CHAR(80);

	DEFINE vFolioSuc			VARCHAR(20);
	DEFINE iDupla				INTEGER;
	
	DEFINE dFecha				DATE;
	DEFINE vNoSerialAbono		VARCHAR(20);
	DEFINE vUsuarioAbono		VARCHAR(20);
	DEFINE vSucCtaAbono			VARCHAR(50);
	DEFINE vSucursalAbono		VARCHAR(20);
	DEFINE vNoCtaAbono			VARCHAR(20);
	DEFINE vTransaccAbono		VARCHAR(4);
	DEFINE vDesTransaccAbono	VARCHAR(50);
	DEFINE vDesProductoAbono	VARCHAR(50);
	DEFINE mMontoAbono			MONEY;
	
	DEFINE vNoCtaCargo			VARCHAR(20);
	DEFINE vTransaccCargo		VARCHAR(4);
	DEFINE vDesTransaccCargo	VARCHAR(50);
	DEFINE vDesProductoCargo	VARCHAR(50);
	DEFINE mMontoCargo			MONEY;
	
	DEFINE mDiferencia			MONEY;
	DEFINE vEmpresa				VARCHAR(3);
	

	---INICIALIZACIONES
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	LET cErrorInfo			= '';
	LET cCodRet				= '00000';
	LET cMensajeRet			= 'SE REALIZO EL MANTENIMIENTO CORRECTAMENTE';
	LET vFolioSuc			= '';
    LET iDupla				= 0;

	LET vNoSerialAbono		= '';
	LET vUsuarioAbono		= '';
	LET vSucCtaAbono		= '';
	LET vSucursalAbono		= '';
	LET vNoCtaAbono			= '';
	LET vTransaccAbono		= '';
	LET vDesTransaccAbono	= '';
	LET vDesProductoAbono	= '';
	LET mMontoAbono			= 0;
	
	LET vNoCtaCargo			= '';
	LET vTransaccCargo		= '';
	LET vDesTransaccCargo	= '';
	LET vDesProductoCargo	= '';
	LET mMontoCargo			= 0;
	
	LET mDiferencia			= 0;
	LET vEmpresa			= '001';
	LET dFecha				= DATE(1);
	
	BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
            LET cCodRet = iSqlErr;
            LET cMensajeRet = cErrorInfo;
            RETURN cCodRet, cMensajeRet;
    END EXCEPTION;
    
    --SET DEBUG FILE TO '/informix/c90021254/RQI112116/SP/bdinvers/sp_cap_conciliacionapertpagarevscargoscheques.out';
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- Se validan los parametros de entrada.
    IF pFechaInicio IS NULL OR pFechaFin IS NULL THEN
        LET cCodRet = '00001';
        LET cMensajeRet = 'FALTAN PARAMETROS PARA EJECUTAR EL PROCEDIMIENTO';
        RETURN cCodRet, cMensajeRet;
    END IF;
	
    SELECT {+INDEX(bdicheq:sc_movhis idx_cap_sc_movhis)} 
                        folio_suc, transacc
                   FROM bdicheq:"informix".sc_movhis
                  WHERE empresa = vEmpresa 
                    AND cancelad <> 'S' 
                    AND transacc = '0235' 
                    AND fech_alt BETWEEN pFechaInicio AND pFechaFin 
                    AND folio_suc NOT LIKE 'informix%'
                 UNION
                 SELECT {+INDEX(bdinvers:sv_movhis idx_cap_sv_movhis)} 
                        folio_suc, transacc
                   FROM bdinvers:"informix".sv_movhis
                  WHERE empresa = vEmpresa 
                    AND cancelad <> 'S' 
                    AND transacc = '0500' 
                    AND fech_alt BETWEEN pFechaInicio AND pFechaFin
					INTO TEMP tmp_sv_movhis_concilia WITH NO LOG;
					
    FOREACH
        SELECT COUNT(folio_suc), folio_suc 
          INTO iDupla, vFolioSuc 
          FROM tmp_sv_movhis_concilia
		  GROUP BY folio_suc
             
        LET dFecha				= DATE(1);
        LET vNoSerialAbono		= '';
        LET vUsuarioAbono		= '';
        LET vSucCtaAbono		= '';
        LET vSucursalAbono		= '';
        LET vNoCtaAbono			= '';
        LET vTransaccAbono		= '';
        LET vDesTransaccAbono	= '';
        LET mMontoAbono			= 0;
        LET vNoCtaCargo			= '';
        LET vTransaccCargo		= '';
        LET vDesTransaccCargo	= '';
        LET vDesProductoCargo	= '';
        LET mMontoCargo			= 0;
        LET mDiferencia 		= 0;
        
        SELECT a.cuenta, a.transacc, b.descripcion, d.nombre, a.monto_tot 
          INTO vNoCtaCargo, vTransaccCargo, vDesTransaccCargo, vDesProductoCargo, mMontoCargo
          FROM bdicheq:"informix".sc_movhis AS a 
         INNER JOIN bdinteg:"informix".si_transacc AS B ON ( b.empresa = a.empresa AND b.numero = a.transacc AND b.sistema = '01')
         INNER JOIN bdicheq:"informix".sc_producto AS d ON ( d.empresa = a.empresa AND d.producto = a.producto )
         WHERE a.folio_suc = vFolioSuc 
           AND a.empresa = vEmpresa
		   AND a.transacc = '0235'
		   AND a.fech_alt BETWEEN pFechaInicio AND pFechaFin;
        
        LET vNoCtaCargo		  = NVL(vNoCtaCargo,'');
        LET vTransaccCargo	  = NVL(vTransaccCargo,'');
        LET vDesTransaccCargo = NVL(vDesTransaccCargo,'');
        LET vDesProductoCargo = NVL(vDesProductoCargo,'');
        LET mMontoCargo		  = NVL(mMontoCargo,0);

        SELECT a.fech_alt, a.num_serial, a.usuario, a.cuenta, d.nombre, a.sucursal, a.transacc, b.descripcion, a.monto_tot 
          INTO dFecha, vNoSerialAbono, vUsuarioAbono, vNoCtaAbono, vSucCtaAbono, vSucursalAbono, vTransaccAbono, vDesTransaccAbono, mMontoAbono
          FROM bdinvers:"informix".sv_movhis AS a 
         INNER JOIN bdinteg:"informix".si_transacc AS B ON ( b.empresa = a.empresa AND b.numero = a.transacc AND b.sistema = '03' )
         INNER JOIN bdinteg:"informix".si_sucursales AS d ON ( d.empresa = a.empresa AND d.sucursal = a.suc_cuen )
         WHERE a.folio_suc = vFolioSuc 
           AND a.empresa = vEmpresa
		   AND a.transacc = '0500'
		   AND a.fech_alt BETWEEN pFechaInicio AND pFechaFin;
        
        LET dFecha			  = NVL(dFecha,DATE(1));
        LET vNoSerialAbono	  = NVL(vNoSerialAbono,'');
        LET vUsuarioAbono	  = NVL(vUsuarioAbono,'');
        LET vSucCtaAbono	  = NVL(vSucCtaAbono,'');
        LET vSucursalAbono	  = NVL(vSucursalAbono,'');
        LET vNoCtaAbono		  = NVL(vNoCtaAbono,'');
        LET vTransaccAbono	  = NVL(vTransaccAbono,'');
        LET vDesTransaccAbono = NVL(vDesTransaccAbono,'');
        LET mMontoAbono		  = NVL(mMontoAbono,0);        
        LET mDiferencia	      = mMontoCargo - mMontoAbono;

        IF iDupla = 1 THEN
            INSERT INTO bdinvers:"informix".sv_difer_concilia_cargos_apertura
            (fecha_alt, numero_serial, folio_suc, usuario, cuenta_apertura, suc_cuenta, sucursal, transacc_apert, descripcion_apert, cuenta_cargo, transacc_cargo, descripcion_cargo, producto_cargo, monto_apert, monto_cargo, diferencia)
            VALUES
            (dFecha, vNoSerialAbono, vFolioSuc, vUsuarioAbono, vNoCtaAbono, vSucCtaAbono, vSucursalAbono, vTransaccAbono, vDesTransaccAbono, vNoCtaCargo, vTransaccCargo, vDesTransaccCargo, vDesProductoCargo, mMontoAbono, mMontoCargo, mDiferencia);
        ELIF iDupla > 1 AND mDiferencia <> 0 THEN
            INSERT INTO bdinvers:"informix".sv_difer_concilia_cargos_apertura
            (fecha_alt, numero_serial, folio_suc, usuario, cuenta_apertura, suc_cuenta, sucursal, transacc_apert, descripcion_apert, cuenta_cargo, transacc_cargo, descripcion_cargo, producto_cargo, monto_apert, monto_cargo, diferencia) 
            VALUES
            (dFecha, vNoSerialAbono,vFolioSuc ,vUsuarioAbono , vNoCtaAbono, vSucCtaAbono, vSucursalAbono, vTransaccAbono, vDesTransaccAbono, vNoCtaCargo, vTransaccCargo, vDesTransaccCargo, vDesProductoCargo, mMontoAbono, mMontoCargo, mDiferencia);
        ELSE
            INSERT INTO bdinvers:"informix".sv_concilia_cargos_apertura
            (fecha_alt, numero_serial, folio_suc, usuario, cuenta_apert, suc_cuenta, sucursal, transacc_apert, descripcion_apert, cuenta_cargo, transacc_cargo, descripcion_cargo, producto_cargo, monto_apert, monto_cargo) 
            VALUES
            (dFecha, vNoSerialAbono, vFolioSuc,vUsuarioAbono , vNoCtaAbono, vSucCtaAbono, vSucursalAbono, vTransaccAbono, vDesTransaccAbono, vNoCtaCargo, vTransaccCargo, vDesTransaccCargo, vDesProductoCargo, mMontoAbono, mMontoCargo);
        END IF;

    END FOREACH;
	
    drop table tmp_sv_movhis_concilia;
    RETURN cCodRet, cMensajeRet;			 	
		
	END
    
END PROCEDURE
