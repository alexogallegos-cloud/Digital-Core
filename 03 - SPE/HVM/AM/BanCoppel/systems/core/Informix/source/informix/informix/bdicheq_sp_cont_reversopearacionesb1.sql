CREATE PROCEDURE "informix".sp_cont_reversopearacionesb1(pBandera CHAR(1), pSBandera CHAR(1), pUsuario CHAR(8), pCodigo CHAR(5), pSucursal CHAR(4), pGrd_Det CHAR(12), pFolioSuc CHAR(16))
    RETURNING CHAR(5) AS codret,
			  CHAR(50) AS descripcion,
			  CHAR(4)  AS sucursal,
			  CHAR(45) AS nombre,
			  CHAR(12) AS numero,
			  CHAR(16)  AS folio_suc,
			  CHAR(4) AS transacc,
			  CHAR(20) AS cuenta,
			  INTEGER AS num_cheq,
			  MONEY AS monto_tot,
			  CHAR(1) AS cancelad,
			  INTEGER AS TotReg,
			  CHAR(10) AS fecha_hoy,
			  CHAR(40) AS nombre_sucursal,
			  CHAR(30) AS empresa,
			  CHAR(45) as nombre2;
			  
	
	DEFINE cCodRet 				CHAR(5);
	DEFINE iSqlErr 				INTEGER;
	DEFINE cDescripcion 		CHAR(50);
	DEFINE cSucursal 			CHAR(4);
	DEFINE cNombre	 			CHAR(40);
	DEFINE cNumero	 			CHAR(12);
	DEFINE cFolio_suc			CHAR(16);
	DEFINE cTransacc 			CHAR(4);
	DEFINE cCuenta	 			CHAR(20);
	DEFINE cNum_cheq	 		INTEGER;
	DEFINE cMonto_tot			MONEY;
	DEFINE cCancelad	 		CHAR(1);
	DEFINE iTotReg				INTEGER;
	DEFINE cFecha_hoy 			CHAR(10);
	DEFINE cNombre_sucursal 	CHAR(40);
	DEFINE cEmpresa 			CHAR(30);
	DEFINE cNombre2	 			CHAR(45);
	DEFINE cDepartamento 		CHAR(3);
	DEFINE cEjecutivo 			CHAR(8);
	--DEFINE cSucursal 			CHAR(4);
	DEFINE cPuesto 				CHAR(3);
	DEFINE vSpASsword           CHAR(40);
	DEFINE vSpAS_cod            CHAR(40);
	DEFINE dLimaut_mn           DECIMAL(14,2);
	DEFINE dLimaut_dls          DECIMAL(14,2);
	DEFINE cVigencia            DATE;
	DEFINE iPerfil            	INTEGER;
	DEFINE cUser_insert         CHAR(30);
	DEFINE dFecha_insert        DATE;
	DEFINE cNombramiento		CHAR(20);
	DEFINE cAsistente			CHAR(10);

	LET cCodRet				= '00000';
	LET iSqlErr				= 0;
	LET cDescripcion 		= '';
	LET cSucursal			= '';
	LET cNombre				= '';
	LET cNumero 			= '';
	LET cFolio_suc			= '';
	LET cTransacc 			= '';
	LET cCuenta	 			= '';
	LET cNum_cheq			= 0;
	LET cMonto_tot			= 0;
	LET cCancelad			= '';
	LET iTotReg				= 0;
	LET cFecha_hoy 			= '';
	LET cNombre_sucursal	= '';
	LET cEmpresa 			= '';
	LET cNombre2			= '';
	LET cDepartamento       = '';
	LET cEjecutivo 	        = '';
	LET cPuesto 		    = '';
	let vSpASsword			= '';
	LET vSpAS_cod           = '';
	LET dLimaut_mn          = '';
	LET dLimaut_dls         = '';
	LET cVigencia           = '';
	LET iPerfil             = 0;
	LET cUser_insert        = '';
	LET dFecha_insert       = '';
	LET cNombramiento 		= '';
	LET cAsistente			= '';

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;			
			RETURN cCodRet, cDescripcion, cSucursal, cNombre, cNumero, cFolio_suc, cTransacc, cCuenta, cNum_cheq, cMonto_tot, cCancelad, iTotReg, cFecha_hoy, cNombre_sucursal,cEmpresa,cNombre2;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cont_reporteconciliacionb2.out';
		--TRACE ON;
		
		IF pBandera = '' THEN	
			LET cCodRet = '00003';
			RETURN cCodRet, cDescripcion, cSucursal, cNombre, cNumero, cFolio_suc, cTransacc, cCuenta, cNum_cheq, cMonto_tot, cCancelad, iTotReg, cFecha_hoy, cNombre_sucursal,cEmpresa,cNombre2;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pBandera = '1' THEN --Revisado
			EXECUTE PROCEDURE "informix".sp_cap_conscodret(pSBandera, pCodigo)  
			INTO cCodRet, cDescripcion;
			
			RETURN cCodRet, cDescripcion, cSucursal, cNombre, cNumero, cFolio_suc, cTransacc, cCuenta, cNum_cheq, cMonto_tot, cCancelad, iTotReg, cFecha_hoy, cNombre_sucursal,cEmpresa,cNombre2;
			
		ELIF pBandera = '2' THEN
			EXECUTE PROCEDURE "informix".sp_cap_surcursalnombre(pSBandera, pUsuario, pSucursal, pGrd_Det) 
			INTO cCodRet, cSucursal, cNombre, cNumero;
			
			RETURN cCodRet, cDescripcion, cSucursal, cNombre, cNumero, cFolio_suc, cTransacc, cCuenta, cNum_cheq, cMonto_tot, cCancelad, iTotReg, cFecha_hoy, cNombre_sucursal,cEmpresa,cNombre2;
		
		ELIF pBandera = '3' THEN 
		FOREACH	
		
			SELECT folio_suc, transacc, descripcion, cuenta, num_cheq, monto_tot, cancelad, sucursal 
			INTO cFolio_suc, cTransacc, cDescripcion, cCuenta, cNum_cheq, cMonto_tot, cCancelad, cSucursal
			FROM bdicheq:sc_movdia m, bdinteg: si_transacc t
			WHERE m.empresa = '001' and m.empresa = t.empresa and folio_suc = pFolioSuc and transacc = numero
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet= '00017';
			END IF;
			
			RETURN cCodRet, cDescripcion, cSucursal, cNombre, cNumero, cFolio_suc, cTransacc, cCuenta, cNum_cheq, cMonto_tot, cCancelad, iTotReg, cFecha_hoy, cNombre_sucursal,cEmpresa,cNombre2 WITH RESUME;
		END FOREACH;
		
		ELIF pBandera = '4' THEN 
		
			EXECUTE PROCEDURE bdicheq:"informix".reversion('001', pUsuario, pSucursal, pFolioSuc, 'M')
			INTO cCodRet;
			
			IF cCodRet <> '000' THEN
				EXECUTE PROCEDURE "informix".sp_cap_conscodret('2', cCodRet)  
				INTO cCodRet, cDescripcion;
			END IF;
			
			IF cCodRet = '000' THEN
				LET cCodRet = '00000';
			END IF;
			
			RETURN cCodRet, cDescripcion, cSucursal, cNombre, cNumero, cFolio_suc, cTransacc, cCuenta, cNum_cheq, cMonto_tot, cCancelad, iTotReg, cFecha_hoy, cNombre_sucursal,cEmpresa,cNombre2;
		ELIF pBandera = '5' THEN
			SELECT LIMIT 1 Fecha_Hoy
			INTO cFecha_hoy
			FROM bdinteg:"informix".si_fechas where empresa = '001';
			RETURN cCodRet, cDescripcion, cSucursal, cNombre, cNumero, cFolio_suc, cTransacc, cCuenta, cNum_cheq, cMonto_tot, cCancelad, iTotReg, cFecha_hoy, cNombre_sucursal,cEmpresa,cNombre2;
		ELIF pBandera = '6' THEN
			SELECT nombre
			INTO cNombre_sucursal
			FROM bdinteg:"informix".si_sucursales
			WHERE empresa='001' AND sucursal = pSucursal;
			RETURN cCodRet, cDescripcion, cSucursal, cNombre, cNumero, cFolio_suc, cTransacc, cCuenta, cNum_cheq, cMonto_tot, cCancelad, iTotReg, cFecha_hoy, cNombre_sucursal,cEmpresa,cNombre2;
		ELIF pBandera = '7' THEN
			EXECUTE PROCEDURE "informix".sp_cap_razonsocialempresa1() INTO cCodRet, cEmpresa;
			RETURN cCodRet, cDescripcion, cSucursal, cNombre, cNumero, cFolio_suc, cTransacc, cCuenta, cNum_cheq, cMonto_tot, cCancelad, iTotReg, cFecha_hoy, cNombre_sucursal,cEmpresa,cNombre2;
		ELIF pBandera = '8' THEN
			EXECUTE PROCEDURE bdicheq:"informix".sp_cap_siejecut('4', pUsuario, '') 
			INTO cCodRet, cNombre2, cDepartamento, cEmpresa, cEjecutivo, cSucursal, cPuesto, vSpAS_cod, dLimaut_mn, dLimaut_dls, 
				cVigencia, iPerfil, cUser_insert, dFecha_insert, vSpASsword, cNombramiento, cAsistente;
				
			RETURN cCodRet, cDescripcion, cSucursal, cNombre, cNumero, cFolio_suc, cTransacc, cCuenta, cNum_cheq, cMonto_tot, cCancelad, iTotReg, cFecha_hoy, cNombre_sucursal,cEmpresa,cNombre2;
		END IF;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Antonio Contreras Sanchez',
'FECHA: 26/09/2022',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: REPORTE CONCILIACION',
'DESCRIPCION: SPL Maestro encargado de ejecutar los procedimientos y consultas que ejecuta la funcionalidad';

CREATE PROCEDURE "informix".sp_cap_surcursalnombre(pBandera CHAR(1), pUsuario CHAR(8), pSucursal CHAR(4), pGrd_Det CHAR(12))
	RETURNING CHAR(5)  AS codret, 
	CHAR(3)  AS sucursal,
	CHAR(45) AS nombre,
	CHAR(12) AS numero;
			  
	DEFINE cCodRet 		CHAR(5);
	DEFINE iSqlErr 		INTEGER;
	DEFINE cEmpresa		CHAR(3);
	DEFINE cSucursal 	CHAR(4);
	DEFINE cNombre	 	CHAR(40);
	DEFINE cNumero	 	CHAR(12);
	
	LET cCodRet 	= '00000';
	LET iSqlErr 	= 0;	
	LET cEmpresa	= '001';
	LET cSucursal	= '';
	LET cNombre		= '';
	LET cNumero 	= '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cSucursal, cNombre, cNumero;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cont_surcursalnombre.out';
		--TRACE ON;

		--se valida si algun parametro viene vacio.
		IF pBandera = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cSucursal, cNombre, cNumero;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pBandera = '1' THEN
			--Se define la consulta.		
			SELECT sucursal, nombre 
			INTO cSucursal, cNombre
			FROM bdinteg:"informix".si_sucursales WHERE sucursal =(SELECT sucursal FROM bdinteg:si_ejecut WHERE ejecutivo = pUsuario);
			--Se valida que las variables al realizar la consulta no vengan vacias.
			IF NVL(cSucursal,'') = '' AND NVL(cNombre,'') = '' THEN
				LET cCodRet = '00017';
			END IF
		ELIF pBandera = '2' THEN
			SELECT i.sucursal, i.nombre, a.numero  
			INTO cSucursal, cNombre, cNumero
			FROM bdinteg:"informix".si_sucursales i, bdicont:"informix".co_auxiliar a 
			WHERE i.empresa = cEmpresa  AND i.sucursal = pSucursal AND a.numero = pGrd_Det;
			
		END IF;
		RETURN cCodRet, cSucursal, cNombre, cNumero;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Antonio Contreras Sanchez',
'FECHA: 30/08/2022',
'MODULO: CAPTACION',
'FUNCIONALIDAD: APLICATIVOS CAPTACION',
'DESCRIPCION: SPL encargado de recuperar la sucursal y el nombre mediante una consulta interna que obtiene el valor por el ejecutivo, tabla sucursales';

CREATE PROCEDURE "informix".sp_desbloq_ctas(pempresa CHAR(3))
RETURNING CHAR(5), CHAR(5), INTEGER, INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(50);
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE ven_transacc     SMALLINT;
    DEFINE vsql             CHAR(500);
    DEFINE vstmt            CHAR(250);
    DEFINE vcuenta          CHAR(20);
    
    LET vcodret1     = '000';
    LET vcodret2     = '000';
    LET vcodret3     = '';
    LET sql_err	     = 0;
    LET isam_err     = 0;
    LET desc_err     = '';
    LET vcontador1   = 0;
    LET vcontador2   = 0;
    LET ven_transacc = 0;
    LET vsql         = '';
    LET vstmt        = '';
    LET vcuenta      = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_desbloq_ctas.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcontador1, vcontador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_desbloq_ctas.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'cuentasxdesbloq') THEN
        DROP TABLE "informix".cuentasxdesbloq;
    END IF;
    
    CREATE TABLE "informix".cuentasxdesbloq
      (
        cuenta char(20) not null
      )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_cuentaxdesbloq ON "informix".cuentasxdesbloq(cuenta) ONLINE;
      
    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/ctasxdesbloq.csv INSERT INTO cuentasxdesbloq" > /resplogifx/conciliachq/ctas_desbloq.sql';
    SYSTEM vsql;
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctas_desbloq.sql';
    SYSTEM vstmt;
    
    UPDATE STATISTICS MEDIUM FOR TABLE cuentasxdesbloq;
    
    FOREACH WITH HOLD
        SELECT cuenta
          INTO vcuenta
          FROM cuentasxdesbloq
          
        LET vcontador1 = vcontador1 + 1;
        
        BEGIN WORK;
        LET ven_transacc = 1;
        
        DELETE FROM cuentas
         WHERE cuenta = vcuenta;
         
        DELETE FROM sc_ctabloqueo
         WHERE cuenta = vcuenta;
         
        UPDATE sc_maechq
           SET status_cta = '1',
               motivo = ''
         WHERE cuenta = vcuenta;
         
        IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
            LET vcontador2 = vcontador2 + 1;
        END IF;
        
        COMMIT WORK;
        LET ven_transacc = 0;
        
        LET vcuenta = '';
    END FOREACH;
    
    END;

    RETURN vcodret1, vcodret2, vcontador1, vcontador2;

END PROCEDURE;