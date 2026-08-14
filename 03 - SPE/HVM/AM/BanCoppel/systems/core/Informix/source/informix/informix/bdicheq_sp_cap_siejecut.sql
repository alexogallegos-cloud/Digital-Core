CREATE PROCEDURE "informix".sp_cap_siejecut(pBandera CHAR(1), pUsuario CHAR(8), pPass_cod CHAR(40))
	RETURNING CHAR(5)  AS codret, 
			  CHAR(45)  AS nombre,
			  CHAR(3) As departamento,
			  CHAR(3)  AS empresa, 
			  CHAR(8) AS ejecutivo, 
			  CHAR(4) AS sucursal, 
			  CHAR(3) AS puesto,
			  VARCHAR(80) AS pas_cod,
			  DECIMAL(14,2) AS limaut_mn,
			  DECIMAL(14,2) AS limaut_dls,
			  DATE AS vigencia,
			  INTEGER AS perfil,
			  CHAR(30) AS user_insert,
			  DATE AS fecha_insert,
			  CHAR(40) AS password, 
			  CHAR(20) AS nombramiento, 
			  CHAR(10) AS asistente;
	
	DEFINE cCodRet				CHAR(5);
	DEFINE iSqlErr				INTEGER;	
	DEFINE cNombre	 			CHAR(45);
	DEFINE cDepartamento 		CHAR(3);
	DEFINE cEmpresa 			CHAR(3);
	DEFINE cEjecutivo 			CHAR(8);
	DEFINE cSucursal 			CHAR(4);
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
	DEFINE cRazon_social	 	CHAR(30);
	
	LET cCodRet = '000000';
	LET iSqlErr = 0;
	
	LET cNombre	 	        = '';
	LET cDepartamento       = '';
	LET cEmpresa 	        = '';
	LET cEjecutivo 	        = '';
	LET cSucursal 	        = '';
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
	LET cRazon_social		= '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNombre, cDepartamento, cEmpresa, cEjecutivo, 
			cSucursal, cPuesto, vSpAS_cod, dLimaut_mn, dLimaut_dls, cVigencia, iPerfil, cUser_insert, dFecha_insert, vSpASsword, cNombramiento, cAsistente;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cont_siejecut.out';
		--TRACE ON;

		--se valida si algun parametro viene vacio.
		IF pBandera = '' OR pUsuario = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNombre, cDepartamento, cEmpresa, cEjecutivo, 
			cSucursal, cPuesto, vSpAS_cod, dLimaut_mn, dLimaut_dls, cVigencia, iPerfil, cUser_insert, dFecha_insert, vSpASsword, cNombramiento, cAsistente;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pBandera = '1' THEN
			--Se define la consulta.		
			SELECT empresa, ejecutivo, nombre, sucursal, puesto, departamento, password, pass_cod, nombramiento, limaut_mn, limaut_dls, vigencia, perfil, 
			asistente, user_insert, fecha_insert  
			INTO cEmpresa, cEjecutivo, cNombre, cSucursal, cPuesto, cDepartamento, vSpASsword, vSpAS_cod, cNombramiento, dLimaut_mn, dLimaut_dls, cVigencia,
			iPerfil, cAsistente, cUser_insert, dFecha_insert
			FROM bdinteg:"informix".si_ejecut
			WHERE ejecutivo = pUsuario and pass_cod = pPass_cod;
			
		ELIF pBandera = '2' THEN
			SELECT nombre, departamento  
			INTO cNombre, cDepartamento
			FROM bdinteg:"informix".si_ejecut
			WHERE ejecutivo = pUsuario;
			
		ELIF pBandera = '3' THEN
			
			SELECT puesto, sucursal 
			INTO cPuesto, cSucursal
			FROM bdinteg:"informix".si_ejecut 
			WHERE ejecutivo = pUsuario AND puesto = (SELECT valor FROM bdinteg:"informix".si_vbparam  WHERE desc_campo='cve_admon');
			
		ELIF pBandera = '4' THEN
			
			SELECT nombre, sucursal 
			INTO cNombre, cSucursal 
			FROM bdinteg:"informix".si_ejecut  
			WHERE ejecutivo = pUsuario;
		
		ELSE
			SELECT asistente, password 
			INTO cAsistente, vSpASsword 
			FROM bdinteg:"informix".si_ejecut 
			WHERE ejecutivo = pUsuario;
		END IF;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet= '00017';
		END IF;
		
		RETURN cCodRet, cNombre, cDepartamento, cEmpresa, cEjecutivo, 
			cSucursal, cPuesto, vSpAS_cod, dLimaut_mn, dLimaut_dls, cVigencia, iPerfil, cUser_insert, dFecha_insert, vSpASsword, cNombramiento, cAsistente;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Antonio Contreras Sanchez',
'FECHA: 30/08/2022',
'MODULO: CAPTACION',
'FUNCIONALIDAD: APLICATIVOS CAPTACION',
'DESCRIPCION: SPL encargado de recuperar la sucursal y el nombre mediante una consulta interna que obtiene el valor por el ejecutivo, tabla sucursales';

CREATE PROCEDURE "informix".sp_cce_consultar_cheques40(pEmpresa CHAR(3), pFecha DATE)
RETURNING
	CHAR(6) 		AS cod_ret,
	CHAR(3) 		AS banco,
	CHAR(40) 		AS desc_banco,
	CHAR(40) 		AS referencia,
	INTEGER 		AS num_cheque,
	DECIMAL(14,2) 	AS monto_orig,
	CHAR(20) 		AS num_cuenta,
	CHAR(44) 		AS sucursal,
	CHAR(4) 		AS transacc
	

	---DECLARACIONES
    DEFINE iSqlErr			INTEGER;
    DEFINE iIsamErr			INTEGER;
    DEFINE cErrorInfo		CHAR(80);
    DEFINE cCodRet			CHAR(6);
	
	DEFINE cBanco			CHAR(3);
	DEFINE cDescBanco		CHAR(40);
	DEFINE cReferencia		CHAR(40);
	DEFINE iNumCheque		INTEGER;
	DEFINE dMontoOrig		DECIMAL(14,2);
	DEFINE cNumCuenta		CHAR(20);
	DEFINE cSucursal		CHAR(44);
	DEFINE cTransacc		CHAR(4);


	---INICIALIZACIONES
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	LET cErrorInfo			= "";
	LET cCodRet				= "000000";
	
	LET cBanco				= "";
	LET cDescBanco			= "";
	LET cReferencia			= "";
	LET iNumCheque			= 0;
	LET dMontoOrig			= 0.0;
	LET cNumCuenta			= "";
	LET cSucursal			= "";
	LET cTransacc			= "";


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cBanco,cDescBanco,cReferencia,iNumCheque,dMontoOrig,cNumCuenta,cSucursal,cTransacc;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/respaldosbd/has/sp_cce_consultar_cheques40.out';
	--TRACE ON;
	
	IF NVL(pEmpresa,"") = "" OR NVL(pFecha,"") = "" THEN
        -- FALTAN LA EMPRESA O LA FECHA
        LET cCodRet = "000001";
		RETURN cCodRet,cBanco,cDescBanco,cReferencia,iNumCheque,dMontoOrig,cNumCuenta,cSucursal,cTransacc;
	ELSE
		FOREACH	WITH HOLD
			SELECT UNIQUE ba.banco, ba.descripcion, doc.numcuenta, doc.num_chq, doc.monto_ori,doc.cuenta, suc.sucursal || " " || suc.nombre,doc.transacc  
			INTO cBanco, cDescBanco, cReferencia, iNumCheque, dMontoOrig, cNumCuenta, cSucursal, cTransacc
			FROM bdicheq:sc_docret_sbc doc, bdinteg:si_bancos ba, bdinteg:si_sucursales suc, bditef:cce_cheques_det cce   
			WHERE doc.empresa = pEmpresa
			AND doc.banco = ba.banco
			AND doc.sucursal = suc.sucursal
			AND doc.transacc IN (SELECT transacc FROM bditef:cce_mapeo_cecoban)  
			AND doc.cancelado = "T"
			AND doc.banco = cce.cvebanco
			AND doc.numcuenta = cce.numcuenta
			AND doc.num_chq = cce.numcheque
			AND cce.fechapresenta = pFecha
			AND cce.presentado = "0"
			
			RETURN cCodRet,cBanco,cDescBanco,cReferencia,iNumCheque,dMontoOrig,cNumCuenta,cSucursal,cTransacc WITH RESUME;
		END FOREACH	
	END IF
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para obtener los datos de los cheques del cÃ³digo 40', 
'BD: bdicheq', 
'AUTOR: Mohamed CarreÃ³n ',
'FECHA: Octubre 2012',
'VERSION: 20121026.1305';

CREATE PROCEDURE "informix".sp_cce_consultar_cheques46( pEmpresa CHAR(3), 
                                                        pFecha   DATE )
RETURNING CHAR(6) 		AS cod_ret,
          CHAR(3) 		AS banco,
          CHAR(40) 		AS desc_banco,
          CHAR(40) 		AS referencia,
          INTEGER 		AS num_cheque,
          DECIMAL(14,2) AS monto_orig,
          CHAR(20) 		AS num_cuenta,
          CHAR(44) 		AS sucursal,
          CHAR(4) 		AS transacc,
          CHAR(37)		AS cod_desc_dev;
    
	--- DECLARACIONES
    DEFINE iSqlErr		INTEGER;
    DEFINE iIsamErr		INTEGER;
    DEFINE cErrorInfo	CHAR(80);
    DEFINE cCodRet		CHAR(6);
    DEFINE cCodRet2     CHAR(6);
    DEFINE cCodRet3     CHAR(80);
	
	DEFINE cBanco		CHAR(3);
	DEFINE cDescBanco	CHAR(40);
	DEFINE cReferencia	CHAR(40);
	DEFINE iNumCheque	INTEGER;
	DEFINE dMontoOrig	DECIMAL(14,2);
	DEFINE cNumCuenta	CHAR(20);
	DEFINE cSucursal	CHAR(44);
	DEFINE cTransacc	CHAR(4);
	DEFINE cCodDevo		CHAR(2);
	DEFINE cCodDescDevo CHAR(37);
    DEFINE cNumCheque   CHAR(7);
    DEFINE cNumCte      CHAR(20);
    DEFINE cCuenta      CHAR(20);
    DEFINE iTransacc    SMALLINT;
    DEFINE iExisteCta   SMALLINT;
    DEFINE iExisteChq   SMALLINT;
    
	--- INICIALIZACIONES
	LET iSqlErr    = 0;
	LET iIsamErr   = 0;
	LET cErrorInfo = "";
	LET cCodRet    = "000000";
    LET cCodRet2   = "";
    LET cCodRet3   = "";
    
	LET cBanco       = "";
	LET cDescBanco   = "";
	LET cReferencia  = "";
	LET iNumCheque   = 0;
	LET dMontoOrig   = 0.0;
	LET cNumCuenta   = "";
	LET cSucursal    = "";
	LET cTransacc    = "";
	LET cCodDevo     = "";
	LET cCodDescDevo = "";
    LET cNumCheque   = '';
    LET cNumCte      = '';
    LET cCuenta      = '';
    LET iTransacc    = 1;
    LET iExisteCta   = 0;
    LET iExisteChq   = 0;
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        IF iSqlErr != 0 THEN
            LET cCodRet  = iSqlErr;
            LET cCodRet2 = iIsamErr;
            LET cCodRet3 = cErrorInfo;
           --IF iTransacc = 1 THEN
             --   ROLLBACK WORK;
            --END IF;
            RETURN cCodRet, cBanco, cDescBanco, cReferencia, iNumCheque, dMontoOrig, cNumCuenta, cSucursal, cTransacc, cCodDescDevo;
		END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/tmp/mfinis/sp_cce_consultar_cheques60.out';
	--TRACE ON;
	
    -- // VALIDA PARAMETROS DE ENTRADA
	IF NVL(pEmpresa,"") = "" OR NVL(pFecha,"") = "" THEN
        LET cCodRet = "000001";
		RETURN cCodRet, cBanco, cDescBanco, cReferencia, iNumCheque, dMontoOrig, cNumCuenta, cSucursal, cTransacc, cCodDescDevo;
    END IF;
    
    FOREACH WITH HOLD
        SELECT det.cvebanco, det.numcuenta, det.numcheque, mae.num_cte, doc.cuenta, doc.monto_ori, doc.sucursal
          INTO cBanco, cNumCuenta, cNumCheque, cNumCte, cCuenta, dMontoOrig, cSucursal
          FROM bdicheq:sc_maechq mae,
               bdicheq:sc_docret_sbc doc,
               bditef:cce_cheques_det det
         WHERE mae.cuenta = doc.cuenta
           AND doc.banco = det.cvebanco
           AND doc.numcuenta = det.numcuenta
           AND doc.num_chq = det.numcheque
           AND doc.cancelado = 'T'
           AND doc.transacc IN( SELECT transacc FROM bditef:cce_mapeo_cecoban )
           AND det.fechapresenta = pFecha
           AND det.monto > 0
           AND det.empresa = doc.empresa
           AND det.presentado = '1'
           
      --  BEGIN WORK;
        --LET iTransacc = 1;
           
        SELECT COUNT(*)
          INTO iExisteCta
          FROM bdicheq:sc_cuentas_pld
         WHERE banco = cBanco
           AND numcuenta = cNumCuenta;
           
        IF iExisteCta > 0 THEN
            SELECT COUNT(*)
              INTO iExisteChq
              FROM bditef:cce_cheques_revisados
             WHERE empresa = pEmpresa
               AND cvebanco = cBanco
               AND numcheque = cNumCheque
               AND numcuenta = cNumCuenta
               AND fechapresenta = pFecha;
               
            IF iExisteChq > 0 THEN
                UPDATE bditef:cce_cheques_revisados
                   SET motivo = '18', 
                       devuelto = '1' 
                 WHERE empresa = pEmpresa
                   AND cvebanco = cBanco
                   AND numcheque = cNumCheque
                   AND numcuenta = cNumCuenta
                   AND fechapresenta = pFecha;
            ELSE
                INSERT INTO bditef:cce_cheques_revisados VALUES
                ( pEmpresa, cBanco, cNumCuenta, cNumCheque, pFecha, cNumCte, cCuenta, dMontoOrig, 
                  cSucursal, '18', 'informix', pFecha, '00:00:00', '00:00:00', '00:00:00', '1', '1' );
            END IF;
        END IF;
        
       -- COMMIT WORK;
        LET iTransacc = 0;
        
        LET cBanco     = '';
        LET cNumCuenta = '';
        LET cNumCheque = '';
        LET cNumCte    = '';
        LET cCuenta    = '';
        LET dMontoOrig = 0;
        LET cSucursal  = '';
        LET iExisteCta = 0;
        LET iExisteChq = 0;
    END FOREACH;
	
    FOREACH	WITH HOLD 
        SELECT ba.banco, ba.descripcion, doc.numcuenta, doc.num_chq, doc.monto_ori,
               doc.cuenta, suc.sucursal||' '||suc.nombre, doc.transacc, ccecr.motivo
          INTO cBanco, cDescBanco, cReferencia, iNumCheque, dMontoOrig, 
               cNumCuenta, cSucursal, cTransacc, cCodDevo
          FROM bdicheq:sc_docret_sbc doc, 
               bdinteg:si_bancos ba, 
               bdinteg:si_sucursales suc, 
               bditef:cce_cheques_det cce,  
               bditef:cce_cheques_revisados ccecr
         WHERE doc.empresa = pEmpresa
           AND doc.banco = ba.banco
           AND doc.sucursal = suc.sucursal
           AND doc.transacc IN( SELECT transacc FROM bditef:cce_mapeo_cecoban )
           AND doc.cancelado = "T"
           AND doc.banco = cce.cvebanco
           AND doc.numcuenta = cce.numcuenta
           AND doc.num_chq = cce.numcheque
           AND cce.fechapresenta = pFecha
           AND cce.monto > 0
           AND cce.empresa = doc.empresa
           AND cce.presentado = "1"
           AND doc.banco = ccecr.cvebanco
           AND doc.numcuenta = ccecr.numcuenta
           AND doc.num_chq = ccecr.numcheque
           AND ccecr.empresa = doc.empresa
           AND ccecr.fechapresenta = cce.fechapresenta
           AND ccecr.devuelto = '1' 
           AND ccecr.fecha_revision = pFecha
        
        SELECT TRIM(codigo)||' '||TRIM(descripcion) 
          INTO cCodDescDevo 
          FROM bdinteg:si_coddevcam 
         WHERE codigo = TRIM(cCodDevo); 
        
        RETURN cCodRet, cBanco, cDescBanco, cReferencia, iNumCheque, dMontoOrig, cNumCuenta, cSucursal, cTransacc, cCodDescDevo WITH RESUME;
        
        LET cBanco       = '';
        LET cDescBanco   = '';
        LET cReferencia  = '';
        LET iNumCheque   = 0;
        LET dMontoOrig   = 0.00;
        LET cNumCuenta   = '';
        LET cSucursal    = '';
        LET cTransacc    = '';
        LET cCodDevo     = '';
        LET cCodDescDevo = '';
    END FOREACH;
    
    END;
    
END PROCEDURE 
DOCUMENT 
'DESCRIPCION: Proceso para obtener los datos de los cheques del c digo 60', 
'BD: bdicheq', 
'AUTOR: Mohamed Carre n ',
'FECHA: Octubre 2012',
'MODIFICO: Daniel Lazalde',
'FECHA MODIFICACION: Diciembre 2014',
'DESCRIPCION: Se agrego en la consulta la tabla bditef:"informix".cce_cheques_revisados relacionado con los campos cvebanco, numcuenta, numcheque',
'donde devuelto sea igual a uno y fecha revision a la fecha de entrada del sp',
'VERSION: 20121026.1305',
'FECHA MODIFICACION: Febrero 2017',
'MODIFICO: Jorge I. Camacho S.',
'DESCRIPCION: Se incluye en la busqueda las cuentas que se encuentren en la tabla bdicheq:sc_cuentas_pld',
'VERSION: 20180213.1300';

CREATE PROCEDURE "informix".sp_cont_descargaarchivosgeneralcaptacion(pBandera CHAR(2), pSubBandera CHAR(1), pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codret,
    CHAR(100) AS archivo_generado,
	INTEGER AS total_archivos,
	CHAR(11) AS fecha_generacion,
	CHAR(5) AS hora_generacion;

	DEFINE cCodRet 					CHAR(5);
	DEFINE iSqlErr 					INTEGER;
	DEFINE cNombreArchivo 			CHAR(100);
	DEFINE iTotales					INTEGER;
	DEFINE iRecuperacion			INTEGER;
	DEFINE cFechaGeneracion			CHAR(11);
	DEFINE cHoraGeneracion			CHAR(5);

		
	LET cCodRet 					= '00000';
	LET iSqlErr 					= 0;
	LET cNombreArchivo 				= '';
	LET iTotales 					= 0;
	LET cFechaGeneracion			= '';
	LET cHoraGeneracion				= '';
	
	BEGIN

		ON EXCEPTION SET iSqlErr
            LET cCodRet = iSqlErr;
			
			RETURN cCodRet, cNombreArchivo, iTotales, cFechaGeneracion, cHoraGeneracion;
        END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/tmp/mfinis/ROMAN/sp_cont_descargaArchivosGeneralcaptacion.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pBandera = '' THEN
			LET cCodRet = '00003';		
			
	       RETURN cCodRet, cNombreArchivo, iTotales, cFechaGeneracion, cHoraGeneracion;
    	END IF;	
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			 RETURN cCodRet, cNombreArchivo, iTotales, cFechaGeneracion, cHoraGeneracion;
		END IF;
		
		IF pBandera = '1' THEN--REALIZARÃ LA CONSULTA CORRESPONDIENTE AL MODULO DE CANCELACIÃN CUENTAS CAPTACIÃN
			IF pSubBandera = '1' THEN--TOTALES
				SELECT COUNT (*) 
					INTO iTotales 
				FROM sw_ctrlgenreportesctascancelcap 
				WHERE usuario_insert = pUsuario;
				
				IF NVL(iTotales, 0) = 0 THEN
					LET cCodRet = '00017';
				END IF;
				
				RETURN cCodRet, cNombreArchivo, iTotales, cFechaGeneracion, cHoraGeneracion;
			ELSE--RESULTADOS
				FOREACH
					SELECT SKIP pRegistros FIRST pRecuperacion DISTINCT nombre_reporte, fecha_reporte, TO_CHAR(hr_reporte,'%H:%M') AS cHoraConv
						INTO cNombreArchivo, cFechaGeneracion, cHoraGeneracion 
					FROM sw_ctrlgenreportesctascancelcap 
					WHERE usuario_insert = pUsuario 
					ORDER BY cHoraConv
					
					LET cFechaGeneracion = LPAD(DAY(cFechaGeneracion),2,0) || '/' || LPAD(MONTH(cFechaGeneracion),2,0) || '/' || YEAR(cFechaGeneracion);
					
					RETURN cCodRet, cNombreArchivo, iTotales, cFechaGeneracion, cHoraGeneracion WITH RESUME;
				END FOREACH;
			END IF;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT  
'AUTOR: Juan RomÃ¡n VelÃ¡zquez Toledo',
'FECHA: 07/02/2023',
'DESCRIPCION: SPL que recupera los archivos generados por usuario dependiendo la funcionalidad',
'BD: bdicont';

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