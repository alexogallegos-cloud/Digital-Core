CREATE PROCEDURE "informix".sp_consmotdevolucion_tef(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
				CHAR(2) AS idDevolucion,
				CHAR(70) AS descipcionMotivo;


	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cIdDevolucion CHAR(2);
	DEFINE cDescipcionMotivo CHAR(70);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cIdDevolucion = '';
	LET cDescipcionMotivo = '';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdDevolucion, cDescipcionMotivo;
		END EXCEPTION;

		-- SET DEBUG FILE TO '/tmp/mfinis/sp_consmotdevolucion_tef.out';
		-- TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdDevolucion, cDescipcionMotivo;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdDevolucion, cDescipcionMotivo;
		END IF;

		FOREACH	SELECT id_devolucion, descipcion_motivo_devolucion
			INTO cIdDevolucion, cDescipcionMotivo
			FROM bdicnweb:"informix".sw_tf_motivos_devolucion
			RETURN cCodRet, cIdDevolucion, cDescipcionMotivo WITH RESUME;
		END FOREACH;

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017'; --NO SE ENCONTRARON RESULTADOS
			RETURN cCodRet, cIdDevolucion, UPPER(cDescipcionMotivo);
		END IF;
	END;

END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martín',
'FECHA: 04/08/2014',
'DESCRIPCION: sp que consulta los motivos de devolución, para TEF',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultadevexttef(pUsuario CHAR(8), pIdFuncion CHAR(10),pTipoOperacion CHAR(1), pFechaArch CHAR(8), pRegistros INT, pRecuperacion INT)
		RETURNING CHAR(5) AS codret,
					INT AS idx,
	                CHAR(8) AS fechaAbono,
					CHAR(20) AS cuenta,
					CHAR(18) AS referencia,
					CHAR(40) AS banco,
					CHAR(30) AS importe,
					CHAR(10) AS estatus,
					CHAR(1) AS confirmado,
					CHAR(7) AS numSecuencia,
					CHAR(30) AS claveRastreo,
					CHAR(2) AS cveStatus,
					CHAR(2) AS motDev,
					CHAR(1) AS estatusReg;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iNoRegistrosC INTEGER;
	DEFINE iIdx INTEGER;
	DEFINE vsFechaAbono CHAR(8);
	DEFINE vsCuenta CHAR(20);
	DEFINE vsReferencia CHAR(18);
	DEFINE vsBanco CHAR(40);
	DEFINE vsImporte CHAR(30);
	DEFINE vsEstatus CHAR(10);
	DEFINE vsConfirmado CHAR(1);
	DEFINE vsNumSecuencia CHAR(7);
	DEFINE vsClaveRastreo CHAR(30);
	DEFINE vsCveStatus CHAR(2);
	DEFINE vsMotDev CHAR(2);
	DEFINE vsEstatusReg CHAR(1);
	
	LET cCodRet = '00000';
	LET cCodRetSp= '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET iNoRegistrosC = 0;
	LET iIdx =  0;
	LET vsFechaAbono = "";
	LET vsCuenta = "";
	LET vsReferencia = "";
	LET vsBanco = "";
	LET vsImporte = "";
	LET vsEstatus = "";
	LET vsConfirmado = "";
	LET vsNumSecuencia = "";
	LET vsClaveRastreo = "";
	LET vsCveStatus = "";
	LET vsMotDev = '';
	LET vsEstatusReg = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdx, vsFechaAbono, vsCuenta, vsReferencia, vsBanco, vsImporte, vsEstatus, vsConfirmado, vsNumSecuencia, vsClaveRastreo, vsCveStatus, vsMotDev, vsEstatusReg;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_consultadevexttef.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaArch = '' OR pRegistros = '' OR pRecuperacion = '' OR pTipoOperacion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdx, vsFechaAbono, vsCuenta, vsReferencia, vsBanco, vsImporte, vsEstatus, vsConfirmado, vsNumSecuencia, vsClaveRastreo, vsCveStatus, vsMotDev, vsEstatusReg;
		END IF;
		
		IF pTipoOperacion NOT IN('1','2') THEN
			LET cCodRet = '00102';
			RETURN cCodRet, iIdx, vsFechaAbono, vsCuenta, vsReferencia, vsBanco, vsImporte, vsEstatus, vsConfirmado, vsNumSecuencia, vsClaveRastreo, vsCveStatus, vsMotDev, vsEstatusReg;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdx, vsFechaAbono, vsCuenta, vsReferencia, vsBanco, vsImporte, vsEstatus, vsConfirmado, vsNumSecuencia, vsClaveRastreo, vsCveStatus, vsMotDev, vsEstatusReg;
		END IF;
		
		IF pTipoOperacion = '1' THEN
			--DEPURACION TABLA TEMP
			IF pRegistros = 0 THEN
				SET LOCK MODE TO WAIT 3;
				DELETE FROM bdicnweb:"informix".sw_tf_consdevext_tef
				WHERE fecha_abono = pFechaArch;
			END IF;
			
			---	EJECUCION SP PRODUCTIVO
			IF pRegistros = 0 THEN
				SET ISOLATION TO DIRTY READ;
				FOREACH	EXECUTE PROCEDURE bditef:sp_consdevext_tef('1' , pFechaArch , '', '', '', '')
					INTO cCodRetSp, vsFechaAbono, vsCuenta, vsReferencia, vsBanco, vsImporte, vsEstatus, vsConfirmado, vsNumSecuencia, vsClaveRastreo, vsCveStatus 
					INSERT INTO bdicnweb:"informix".sw_tf_consdevext_tef(fecha_abono,cuenta,referencia,banco,importe,estatus,confirmado,num_secuencia,clave_rastreo,cve_status,motivo_devolucion,estatus_reg)
					VALUES (vsFechaAbono, vsCuenta, vsReferencia, vsBanco, vsImporte, vsEstatus, vsConfirmado, vsNumSecuencia, vsClaveRastreo, vsCveStatus,'',DECODE(vsCveStatus, '02', 'E', '03', 'E', 'P'));
					LET iNoRegistros = iNoRegistros + DBINFO('sqlca.sqlerrd2');	
				END FOREACH;
				
				IF iNoRegistros = 0 THEN
					LET cCodRet='00017'; ---NO SE OBTUVIERON RESULTADOS
					RETURN cCodRet, 0, '', '', '', '', '', '', '', '', '', '', '', '';
				END IF;
			END IF;
		END IF;	
		
		---CONSULTA DE DATOS
		SET ISOLATION TO DIRTY READ;
		FOREACH SELECT SKIP pRegistros FIRST pRecuperacion idx, fecha_abono, cuenta, referencia, banco, importe, estatus, confirmado, num_secuencia, clave_rastreo, cve_status, motivo_devolucion, estatus_reg
			INTO iIdx, vsFechaAbono, vsCuenta, vsReferencia, vsBanco, vsImporte, vsEstatus, vsConfirmado, vsNumSecuencia, vsClaveRastreo, vsCveStatus, vsMotDev, vsEstatusReg
			FROM bdicnweb:"informix".sw_tf_consdevext_tef WHERE fecha_abono = pFechaArch ORDER BY idx
			LET iNoRegistrosC = iNoRegistrosC +	1;
			RETURN cCodRet, iIdx, vsFechaAbono, vsCuenta, vsReferencia, vsBanco, vsImporte, vsEstatus, vsConfirmado, vsNumSecuencia, vsClaveRastreo, vsCveStatus, vsMotDev, vsEstatusReg with resume;
		END FOREACH;
		
		IF pRegistros > 0 AND iNoRegistrosC = 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, 0, '', '', '', '', '', '', '', '', '', '', '', '';
				
		END IF;
		
		IF iNoRegistrosC = 0 THEN
			LET cCodRet = '00017'; ---NO SE OBTUVIERON RESULTADOS
			RETURN cCodRet, 0, '', '', '', '', '', '', '', '', '', '', '', '';
		END IF;		
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 04/08/2015',
'DESCRIPCION: pTipoOperacion: 1=consulta, 2=exportado ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultaestatusdevext_tef(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaArch CHAR(8))
		RETURNING CHAR(5) AS codret,
				  CHAR(1) AS estatus_proceso;		

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE vsEstatusProceso CHAR(1);
	DEFINE vsTotalEnProceso INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET vsEstatusProceso = '';
	LET vsTotalEnProceso = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, vsEstatusProceso;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_consultaestatusdevext_tef.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaArch = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, vsEstatusProceso;
		END IF;
		
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, vsEstatusProceso;
		END IF;

		---CONSULTA TOTAL DE REGISTROS EN PROCESO
		SET ISOLATION TO DIRTY READ;
		SELECT COUNT(*) INTO vsTotalEnProceso FROM bdicnweb:"informix".sw_tf_consdevext_tef 
		WHERE fecha_abono  = pFechaArch 
		AND motivo_devolucion !='' 
		AND estatus_reg = 'P';
		
		IF vsTotalEnProceso > 0 THEN
			LET vsEstatusProceso = '1';
		ELSE
			LET vsEstatusProceso = '0';
		END IF;
		
		RETURN cCodRet, vsEstatusProceso;			
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 07/08/2015',
'DESCRIPCION: Consulta si hay registros de devolucion en ejecucion del dia consultado',
'1 = archivos en proceso, 0 = archivos en No proceso ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultainfsdostef(pUsuario CHAR(8), pIdFuncion CHAR(10), pCuenta CHAR(20), pNumTarjeta CHAR(16))	
		RETURNING CHAR(5) AS codret,           
			CHAR(20) AS cCuenta,               
		    CHAR(20) AS cNoCliente,            
		    CHAR(26) AS cApPaterno,            
		    CHAR(26) AS cApMaterno,            
		    CHAR(26) AS cNombre1,              
		    CHAR(26) AS cNombre2,              
		    CHAR(60) AS cRazonSocial,          
		    CHAR(1) AS cStatusCuenta,          
		    MONEY(14,2) AS mSaldoDisponible,   
		    MONEY(14,2) AS mSaldoRetenido,     
		    MONEY(14,2) AS mSaldoCCC,          
		    MONEY(14,2) AS mSaldoCCCDisp,      
		    MONEY(14,2) AS mSaldoCuenta,       
		    CHAR(1) AS cTipoLinea,             
		    CHAR(40) AS cDescripcion1,         
		    CHAR(40) AS cDescripcion2,         
		    MONEY(14,2) AS mSaldoT1,           
		    MONEY(14,2) AS mSaldoCongelado,    
		    MONEY(14,2) AS mSaldoSBC,          
		    CHAR(8) AS cUsuarioBloqueo,        
		    DATE AS dFechaBloqueo,             
		    CHAR(16) AS cNoTarjeta,            
		    CHAR(18) AS cCuentaClabe,          
		    DATE AS dFechaExpTarjeta,          
			CHAR(4) AS cProducto;              

		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE cCodRetSp2 CHAR(5);
		DEFINE cDescCodRet CHAR(100);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;	
		DEFINE cEmpresa CHAR(3);
		DEFINE cCuenta CHAR(20);
		DEFINE cNoCliente CHAR(20);
		DEFINE cApPaterno CHAR(26);
		DEFINE cApMaterno CHAR(26);
		DEFINE cNombre1 CHAR(26); 
		DEFINE cNombre2 CHAR(26); 
		DEFINE cRazonSocial CHAR(60);
		DEFINE cStatusCuenta CHAR(1);
		DEFINE mSaldoDisponible MONEY(14,2);  
		DEFINE mSaldoRetenido MONEY(14,2);  
		DEFINE mSaldoCCC MONEY(14,2);  
		DEFINE mSaldoCCCDisp MONEY(14,2);  
		DEFINE mSaldoCuenta MONEY(14,2);  
		DEFINE cTipoLinea CHAR(1);     
		DEFINE cDescripcion1 CHAR(40);   
		DEFINE cDescripcion2 CHAR(40);   
		DEFINE mSaldoT1 MONEY(14,2);
		DEFINE mSaldoCongelado MONEY(14,2); 
		DEFINE mSaldoSBC MONEY(14,2);
		DEFINE cUsuarioBloqueo CHAR(8);     
		DEFINE dFechaBloqueo DATE;       
		DEFINE cNoTarjeta CHAR(16);  
		DEFINE cCuentaClabe CHAR(18);
		DEFINE dFechaExpTarjeta DATE;   
		DEFINE cProducto CHAR(4);
		DEFINE cFechaHoy CHAR(10);
		DEFINE cHora CHAR(10);
		DEFINE iNoRegistros INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET cCodRetSp2 = '';
		LET cDescCodRet = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;	
		LET cEmpresa = '001';
		LET cCuenta = '';
		LET cNoCliente = '';
		LET cApPaterno = '';
		LET cApMaterno = '';
		LET cNombre1 = ''; 
		LET cNombre2 = ''; 
		LET cRazonSocial = '';
		LET cStatusCuenta = '';
		LET mSaldoDisponible = 0.00;  
		LET mSaldoRetenido = 0.00;  
		LET mSaldoCCC = 0.00;   
		LET mSaldoCCCDisp = 0.00;  
		LET mSaldoCuenta = 0.00;   
		LET cTipoLinea = ''; 
		LET cDescripcion1 = '';   
		LET cDescripcion2 = '';   
		LET mSaldoT1 = 0.00;  
		LET mSaldoCongelado = 0.00;  
		LET mSaldoSBC = 0.00;  
		LET cUsuarioBloqueo = '';  
		LET dFechaBloqueo = '';     
		LET cNoTarjeta = '';
		LET cCuentaClabe = '';
		LET dFechaExpTarjeta = '';
		LET cProducto = '';
		LET cFechaHoy = '';
		LET cHora = '';
		LET iNoRegistros = 0;
		

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet, cCuenta, cNoCliente, cApPaterno, cApMaterno, cNombre1, cNombre2, cRazonSocial, cStatusCuenta,
				mSaldoDisponible, mSaldoRetenido, mSaldoCCC, mSaldoCCCDisp, mSaldoCuenta, cTipoLinea, cDescripcion1, cDescripcion2,   
				mSaldoT1, mSaldoCongelado, mSaldoSBC, cUsuarioBloqueo, dFechaBloqueo, cNoTarjeta, cCuentaClabe, dFechaExpTarjeta, cProducto;
			END EXCEPTION;
            
            -- SET DEBUG FILE TO '/tmp/mfinis/sp_consultainfsdostef.out';
            -- TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cCuenta, cNoCliente, cApPaterno, cApMaterno, cNombre1, cNombre2, cRazonSocial, cStatusCuenta,
				mSaldoDisponible, mSaldoRetenido, mSaldoCCC, mSaldoCCCDisp, mSaldoCuenta, cTipoLinea, cDescripcion1, cDescripcion2,   
				mSaldoT1, mSaldoCongelado, mSaldoSBC, cUsuarioBloqueo, dFechaBloqueo, cNoTarjeta, cCuentaClabe, dFechaExpTarjeta, cProducto;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, cCuenta, cNoCliente, cApPaterno, cApMaterno, cNombre1, cNombre2, cRazonSocial, cStatusCuenta,
				mSaldoDisponible, mSaldoRetenido, mSaldoCCC, mSaldoCCCDisp, mSaldoCuenta, cTipoLinea, cDescripcion1, cDescripcion2,   
				mSaldoT1, mSaldoCongelado, mSaldoSBC, cUsuarioBloqueo, dFechaBloqueo, cNoTarjeta, cCuentaClabe, dFechaExpTarjeta, cProducto;
			END IF;
		 
			SET ISOLATION TO DIRTY READ;
		
			IF NVL(pCuenta,'') = '' THEN
				LET pCuenta = '00000000000';
			END IF;
			IF NVL(pNumTarjeta,'') = '' THEN
				LET pNumTarjeta = '0000000000000000';
			END IF;
			
			EXECUTE PROCEDURE bdicheq:"informix".cons_sdos2(cEmpresa,pCuenta,pNumTarjeta)
			INTO cCodRetSp, cCuenta, cNoCliente, cApPaterno, cApMaterno, cNombre1, cNombre2, cRazonSocial, cStatusCuenta,
			mSaldoDisponible, mSaldoRetenido, mSaldoCCC, mSaldoCCCDisp, mSaldoCuenta, cTipoLinea, cDescripcion1, cDescripcion2,   
			mSaldoT1, mSaldoCongelado, mSaldoSBC, cUsuarioBloqueo, dFechaBloqueo, cNoTarjeta, cCuentaClabe, dFechaExpTarjeta;
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicheq:cons_sdos2';
			ELIF cCodRetSp::INTEGER = 100 THEN
				
				IF pCuenta::BIGINT > 0 THEN
					LET cCodRet = '00009'; --EL NUMERO DE CUENTA NO EXISTE
					RETURN cCodRet, cCuenta, cNoCliente, cApPaterno, cApMaterno, cNombre1, cNombre2, cRazonSocial, cStatusCuenta,
					mSaldoDisponible, mSaldoRetenido, mSaldoCCC, mSaldoCCCDisp, mSaldoCuenta, cTipoLinea, cDescripcion1, cDescripcion2,   
					mSaldoT1, mSaldoCongelado, mSaldoSBC, cUsuarioBloqueo, dFechaBloqueo, cNoTarjeta, cCuentaClabe, dFechaExpTarjeta, cProducto;
				ELIF pNumTarjeta::BIGINT > 0 THEN
					LET cCodRet = '00029'; --EL NUMERO DE TARJETA NO EXISTE
					RETURN cCodRet, cCuenta, cNoCliente, cApPaterno, cApMaterno, cNombre1, cNombre2, cRazonSocial, cStatusCuenta,
					mSaldoDisponible, mSaldoRetenido, mSaldoCCC, mSaldoCCCDisp, mSaldoCuenta, cTipoLinea, cDescripcion1, cDescripcion2,   
					mSaldoT1, mSaldoCongelado, mSaldoSBC, cUsuarioBloqueo, dFechaBloqueo, cNoTarjeta, cCuentaClabe, dFechaExpTarjeta, cProducto;
				END IF;
				
			ELIF cCodRetSp::INTEGER = 104 THEN
				LET cCodRet = '00564'; --HAY INCONGRUENCIA DE INFORMACIÃN CON EL NÃMERO DE CLIENTE, VERIFIQUE
				RETURN cCodRet, cCuenta, cNoCliente, cApPaterno, cApMaterno, cNombre1, cNombre2, cRazonSocial, cStatusCuenta,
				mSaldoDisponible, mSaldoRetenido, mSaldoCCC, mSaldoCCCDisp, mSaldoCuenta, cTipoLinea, cDescripcion1, cDescripcion2,   
				mSaldoT1, mSaldoCongelado, mSaldoSBC, cUsuarioBloqueo, dFechaBloqueo, cNoTarjeta, cCuentaClabe, dFechaExpTarjeta, cProducto;
			ELIF cCodRetSp::INTEGER = 110 THEN
				LET cCodRet = '00565'; --DEBE INGRESAR AL MENOS UN NÃMERO DE CUENTA O UN NÃMERO DE TARJETA VÃLIDO
				RETURN cCodRet, cCuenta, cNoCliente, cApPaterno, cApMaterno, cNombre1, cNombre2, cRazonSocial, cStatusCuenta,
				mSaldoDisponible, mSaldoRetenido, mSaldoCCC, mSaldoCCCDisp, mSaldoCuenta, cTipoLinea, cDescripcion1, cDescripcion2,   
				mSaldoT1, mSaldoCongelado, mSaldoSBC, cUsuarioBloqueo, dFechaBloqueo, cNoTarjeta, cCuentaClabe, dFechaExpTarjeta, cProducto;
			ELIF cCodRetSp::INTEGER = 122 THEN
				LET cCodRet = '00566'; --LA TARJETA DE DÃBITO NO ESTÃ ACTIVA, VERIFIQUE
				RETURN cCodRet, cCuenta, cNoCliente, cApPaterno, cApMaterno, cNombre1, cNombre2, cRazonSocial, cStatusCuenta,
				mSaldoDisponible, mSaldoRetenido, mSaldoCCC, mSaldoCCCDisp, mSaldoCuenta, cTipoLinea, cDescripcion1, cDescripcion2,   
				mSaldoT1, mSaldoCongelado, mSaldoSBC, cUsuarioBloqueo, dFechaBloqueo, cNoTarjeta, cCuentaClabe, dFechaExpTarjeta, cProducto;
			ELIF cCodRetSp::INTEGER = 855 THEN
				LET cCodRet = '00567'; --TRANSACCIÃN NO PERMITIDA CON PRODUCTO 8000-TRANSFER
				RETURN cCodRet, cCuenta, cNoCliente, cApPaterno, cApMaterno, cNombre1, cNombre2, cRazonSocial, cStatusCuenta,
				mSaldoDisponible, mSaldoRetenido, mSaldoCCC, mSaldoCCCDisp, mSaldoCuenta, cTipoLinea, cDescripcion1, cDescripcion2,   
				mSaldoT1, mSaldoCongelado, mSaldoSBC, cUsuarioBloqueo, dFechaBloqueo, cNoTarjeta, cCuentaClabe, dFechaExpTarjeta, cProducto;
			END IF;

			IF cCodRetSp::INTEGER = 0 THEN
				IF NVL(cDescripcion1,'') <> '' THEN
					LET cProducto = SUBSTRING (TRIM(cDescripcion1) FROM 1 FOR 5);
				END IF;
				LET iNoRegistros = iNoRegistros + 1;
			END IF;
			
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cCuenta, cNoCliente, cApPaterno, cApMaterno, cNombre1, cNombre2, cRazonSocial, cStatusCuenta,
				mSaldoDisponible, mSaldoRetenido, mSaldoCCC, mSaldoCCCDisp, mSaldoCuenta, cTipoLinea, cDescripcion1, cDescripcion2,   
				mSaldoT1, mSaldoCongelado, mSaldoSBC, cUsuarioBloqueo, dFechaBloqueo, cNoTarjeta, cCuentaClabe, dFechaExpTarjeta, cProducto;
			ELSE	
				RETURN cCodRet, cCuenta, cNoCliente, UPPER(cApPaterno), UPPER(cApMaterno), UPPER(cNombre1), UPPER(cNombre2), UPPER(cRazonSocial), cStatusCuenta,
				mSaldoDisponible, mSaldoRetenido, mSaldoCCC, mSaldoCCCDisp, mSaldoCuenta, cTipoLinea, UPPER(cDescripcion1), UPPER(cDescripcion2),   
				mSaldoT1, mSaldoCongelado, mSaldoSBC, cUsuarioBloqueo, dFechaBloqueo, cNoTarjeta, cCuentaClabe, dFechaExpTarjeta, cProducto;
			END IF;
			
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 30/07/2015',
'DESCRIPCION: SPL que consulta la informaciÃ³n del cliente respecto al nÃºmero de cuenta o nÃºmero de tarjeta ingresado.',
'FUNCIONALIDAD: Captura de Operaciones TEF', 
'MODULO: TEF',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultanombrearchivotef(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta INTEGER)
		RETURNING CHAR(5) AS codret,
			CHAR(20) AS nom_archivo;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE cNomArchivo CHAR(20);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET cNomArchivo = '';
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;			
			RETURN cCodRet, cNomArchivo;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_consultanombrearchivotef.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNomArchivo;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNomArchivo;
		END IF;
	
		FOREACH		
			EXECUTE PROCEDURE bditef:"informix".sp_obtenernomarch_tef(pIdConsulta)
			INTO cCodRetSp, cNomArchivo
		    
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bditef:sp_obtenernomarch_tef';
			--ELIF cCodRetSp::INTEGER = 1 THEN
			--	LET cCodRet = ''; -- Valida Fecha
			--	RETURN cCodRet, cNomArchivo;
			END IF;
			
			IF cCodRetSp::INTEGER = 0 AND NVL(cNomArchivo,'') <> '' THEN
				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet, UPPER(cNomArchivo) WITH RESUME;
			END IF;
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNomArchivo;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 09/07/2015',
'DESCRIPCION: SPL que realiza el armado de los nombres de los archivos correspondientes para su carga, proceso y generación manual.',
'FUNCIONALIDAD: Generación Manual de Archivos TEF', 
'MODULO: TEF',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultaparametrosgenerales(pUsuario CHAR(8), pIdFuncion CHAR(10), pWhere CHAR(15), pIdParametro CHAR(15))
		RETURNING CHAR(5) AS codret,
				  CHAR(100) AS valor;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cValor CHAR(100);
	DEFINE cQuery CHAR(500);
	DEFINE sIdFuncion CHAR(10);
	DEFINE sNombreBase CHAR(12);
	DEFINE sNmbreTabla CHAR(40);
	DEFINE sCampo CHAR(20);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cValor = '';
	LET cQuery = '';
	LET sIdFuncion = '';
	LET sNombreBase = '';
	LET sNmbreTabla = '';
	LET sCampo = '';


	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cValor;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultaparametrosgenerales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pWhere = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cValor;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cValor;
		END IF;

			IF pWhere <> '' THEN
				
				IF pIdParametro = '' THEN
					LET cCodRet = '00003';
					RETURN cCodRet, cValor;
				END IF;
				
				SELECT id_funcion, nombre_base, nombre_tabla, nombre_campo
				INTO  sIdFuncion, sNombreBase, sNmbreTabla, sCampo
				FROM bdicnweb:"informix".sw_parametros_generales 
				WHERE id_funcion = pIdFuncion 
				AND id_parametro = pIdParametro;

				IF NVL(sIdFuncion,'') = '' OR NVL(sNombreBase,'') = '' OR NVL(sNmbreTabla,'') = '' OR NVL(sCampo,'') = '' THEN
					LET cCodRet = '00190'; --NO EXISTE VALOR PARA ESTE PARAMETRO
					RETURN cCodRet, cValor;			
				END IF;
			
				LET cQuery = "SELECT" || " "||TRIM(sCampo) || " " ||"FROM" || " " || TRIM(sNombreBase) || ":" ||"'informix'."||TRIM(sNmbreTabla)|| " " ||
				"WHERE" || " " || TRIM(pWhere) || " " ||"=" || " '" || TRIM(pIdParametro) ||"';";
				
				PREPARE countQry FROM TRIM(cQuery);
				DECLARE countcur CURSOR FOR countQry;
				OPEN countcur;
				FETCH countcur INTO cValor;
				IF (SQLCODE = 100) THEN
					LET cCodRet = '00190'; --NO EXISTE VALOR PARA ESTE PARAMETRO
					RETURN cCodRet, cValor;
				END IF;
				WHILE(SQLCODE = 0)
					RETURN cCodRet, cValor WITH RESUME;
					FETCH countcur INTO cValor;
				END WHILE
				CLOSE countcur;
				FREE countcur;
				FREE countQry;
				
			END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 08/07/2015',
'DESCRIPCION: SPL que realiza la consulta de algun parametro de acuerdo a los datos insertados.',
'Donde: pWhere se refiere al nombre del campo a comparar y pIdParametro al valor del parametro a comparar.',
'FUNCIONALIDAD: Envío/Recepción Archivos Bancoppel - Cecoban', 
'MODULO: TEF',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultarchivosafore(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(30), pRegistros INTEGER, pRecuperacion INTEGER)
			
		RETURNING CHAR(5) AS codret,  			
			CHAR(1) 	  AS cTipoRegistro,
			CHAR(10)	  AS cNoContratoEmpresa,
			DATE 		  AS dFechaGen,
			DATE 		  AS dFechaInicialInformacion,
			DATE 		  AS dFechaFinalInformacion,
			CHAR(9) 	  AS cNoMovimientosContenidos,
			CHAR(232)	  AS cFiller,
			CHAR(2)   	  AS cFinLinea,
			CHAR(11) 	  AS cNSS,
			CHAR(40) 	  AS cNombreBeneficiario,
			CHAR(40) 	  AS cApellidoPaternoBeneficiario,
			CHAR(40) 	  AS cApellidoMaternoBeneficiario,
			CHAR(1)  	  AS cFormasPago,
			CHAR(18) 	  AS cCLABE,
			DATE     	  AS dFechaCaptura,
			CHAR(15) 	  AS cImporteDocumentoNetoPagar,
			CHAR(15) 	  AS cImporteDocumentoAntesImpuesto,
			CHAR(11) 	  AS cImpuestoRetenido,
			CHAR(8)  	  AS cNumeroFolioServicio,
			CHAR(4)  	  AS cNumeroTienda,
			CHAR(3)  	  AS cTipoRetiro,
			CHAR(10) 	  AS cConsecutivoRetiro,
			CHAR(18) 	  AS cCURP,
			CHAR(10) 	  AS cRFC,
			CHAR(16) 	  AS cFolio_suc,
			CHAR(2)  	  AS cNumeroTotalMovimientosContenidos,
			CHAR(17) 	  AS cImporteTotalNeto,
			CHAR(17) 	  AS cImporteTotalAntesImpuesto,
			CHAR(17) 	  AS cImporteRetenido,
			CHAR(17) 	  AS cImporteTotalRetirosPagadosEfectivo,
			CHAR(17) 	  AS cImporteTotalRetirosPagadosDeposito,
			DATE     	  AS dFechaMovimientos,
			CHAR(2)  	  AS cEstatus,
			INTEGER  	  AS iSumaMov,
			MONEY(10,2)   AS mMonto,
			MONEY(12,2)   AS mSumaMonto;
			
		DEFINE cCodRet							   CHAR(5);
		DEFINE cCodRetSp 						   CHAR(6);
        DEFINE iSqlErr 							   INTEGER;	
		DEFINE cMensajeRet 						   CHAR(200); 			
		DEFINE cTipoRegistro                       CHAR(1); 	  
		DEFINE cNoContratoEmpresa                  CHAR(10);	  
		DEFINE dFechaGen                           DATE; 		  
		DEFINE dFechaInicialInformacion            DATE; 		  
		DEFINE dFechaFinalInformacion              DATE; 		  
		DEFINE cNoMovimientosContenidos            CHAR(9); 	  
		DEFINE cFiller                             CHAR(232);	  
		DEFINE cFinLinea                           CHAR(2);   	  
		DEFINE cNSS                                CHAR(11); 	  
		DEFINE cNombreBeneficiario                 CHAR(40); 	  
		DEFINE cApellidoPaternoBeneficiario        CHAR(40); 	  
		DEFINE cApellidoMaternoBeneficiario        CHAR(40); 	  
		DEFINE cFormasPago                         CHAR(1); 	  
		DEFINE cCLABE                              CHAR(18); 	  
		DEFINE dFechaCaptura                       DATE; 	  
		DEFINE cImporteDocumentoNetoPagar          CHAR(15); 	  
		DEFINE cImporteDocumentoAntesImpuesto      CHAR(15); 	  
		DEFINE cImpuestoRetenido                   CHAR(11); 	  
		DEFINE cNumeroFolioServicio                CHAR(8); 	  
		DEFINE cNumeroTienda                       CHAR(4); 	  
		DEFINE cTipoRetiro                         CHAR(3); 	  
		DEFINE cConsecutivoRetiro                  CHAR(10); 	  
		DEFINE cCURP                               CHAR(18); 	  
		DEFINE cRFC                                CHAR(10); 	  
		DEFINE cFolio_suc                          CHAR(16); 	  
		DEFINE cNumeroTotalMovimientosContenidos   CHAR(2); 	  	
		DEFINE cImporteTotalNeto                   CHAR(17); 	  
		DEFINE cImporteTotalAntesImpuesto          CHAR(17); 	  
		DEFINE cImporteRetenido                    CHAR(17); 	  
		DEFINE cImporteTotalRetirosPagadosEfectivo CHAR(17); 	  
		DEFINE cImporteTotalRetirosPagadosDeposito CHAR(17); 	  
		DEFINE dFechaMovimientos                   DATE; 	  
		DEFINE cEstatus                            CHAR(2); 	  
		DEFINE iSumaMov                            INTEGER; 	  
		DEFINE mMonto                              MONEY(10,2);   
		DEFINE mSumaMonto                          MONEY(12,2);  
		DEFINE pTipoArchivo 					   CHAR(1);
		DEFINE iRecuperacion 					   INTEGER;
		
		DEFINE cNoContratoEmpresaTmp               CHAR(10);	  
		DEFINE dFechaGenTmp                        DATE; 		  
		DEFINE dFechaInicialInformacionTmp         DATE; 		  
		DEFINE dFechaFinalInformacionTmp           DATE; 		  
		DEFINE cNoMovimientosContenidosTmp         CHAR(9);
		DEFINE dFecha_Hoy						   DATE;
		
		DEFINE bConsultaTerminada 				   BOOLEAN;
		DEFINE iSpSkip                             INTEGER;
		DEFINE iSpSkipInc                          SMALLINT;
		DEFINE iNoRegistros 					   INTEGER;
		DEFINE totalInserts						   INTEGER;		
		DEFINE cNombre                             CHAR(30);
		DEFINE iMaximo							   INTEGER;
		DEFINE iMinimo                             INTEGER;
		
		LET cCodRet 							   = '00000';
		LET cCodRetSp 							   = '';
        LET iSqlErr 							   = 0;	
		LET cMensajeRet 						   = ''; 			
		LET cTipoRegistro                          = '';	  
		LET cNoContratoEmpresa                     = '';	  
		LET dFechaGen                              = ''; 		  
		LET dFechaInicialInformacion               = ''; 		  
		LET dFechaFinalInformacion                 = ''; 		  
		LET cNoMovimientosContenidos               = '';	  
		LET cFiller                                = '';	  
		LET cFinLinea                              = ''; 	  
		LET cNSS                                   = '';	  
		LET cNombreBeneficiario                    = '';	  
		LET cApellidoPaternoBeneficiario           = '';	  
		LET cApellidoMaternoBeneficiario           = '';	  
		LET cFormasPago                            = '';	  
		LET cCLABE                                 = '';	  
		LET dFechaCaptura                          = ''; 	  
		LET cImporteDocumentoNetoPagar             = ''; 	  
		LET cImporteDocumentoAntesImpuesto         = ''; 	  
		LET cImpuestoRetenido                      = ''; 	  
		LET cNumeroFolioServicio                   = '';	  
		LET cNumeroTienda                          = '';	  
		LET cTipoRetiro                            = '';	  
		LET cConsecutivoRetiro                     = ''; 	  
		LET cCURP                                  = ''; 	  
		LET cRFC                                   = ''; 	  
		LET cFolio_suc                             = ''; 	  
		LET cNumeroTotalMovimientosContenidos      = '';	  	
		LET cImporteTotalNeto                      = ''; 	  
		LET cImporteTotalAntesImpuesto             = ''; 	  
		LET cImporteRetenido                       = ''; 	  
		LET cImporteTotalRetirosPagadosEfectivo    = ''; 	  
		LET cImporteTotalRetirosPagadosDeposito    = ''; 	  
		LET dFechaMovimientos                      = ''; 	  
		LET cEstatus                               = ''; 	  
		LET iSumaMov                               = 0; 	  
		LET mMonto                                 = '';  
		LET mSumaMonto                             = '';   
		LET pTipoArchivo 						   = '';
		LET iRecuperacion 						   = 0;
	  
		LET cNoContratoEmpresaTmp                  = '';	  
		LET dFechaGenTmp                           = ''; 		  
		LET dFechaInicialInformacionTmp            = ''; 		  
		LET dFechaFinalInformacionTmp              = ''; 		  
		LET cNoMovimientosContenidosTmp            = '';
		LET dFecha_Hoy							   = '';
		
		LET bConsultaTerminada                     = 'f';
		LET iSpSkip                                = 0;
		LET iSpSkipInc                             = 10;
		LET iNoRegistros                           = 0;
		LET totalInserts                           = 0;
		LET cNombre                                = '';
		LET iMaximo								   = 0;
		LET iMinimo                                = 0;
		
		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet, cTipoRegistro, cNoContratoEmpresa, dFechaGen, dFechaInicialInformacion, dFechaFinalInformacion, 
						cNoMovimientosContenidos, cFiller, cFinLinea, cNSS, cNombreBeneficiario, cApellidoPaternoBeneficiario, 
						cApellidoMaternoBeneficiario, cFormasPago, cCLABE, dFechaCaptura, cImporteDocumentoNetoPagar, 
						cImporteDocumentoAntesImpuesto, cImpuestoRetenido, cNumeroFolioServicio, cNumeroTienda, cTipoRetiro, 
						cConsecutivoRetiro, cCURP, cRFC, cFolio_suc, cNumeroTotalMovimientosContenidos, cImporteTotalNeto, 
						cImporteTotalAntesImpuesto, cImporteRetenido, cImporteTotalRetirosPagadosEfectivo, 
						cImporteTotalRetirosPagadosDeposito, dFechaMovimientos, cEstatus, iSumaMov, mMonto, mSumaMonto;
			END EXCEPTION;
			
			ON EXCEPTION IN (-958)
			END EXCEPTION WITH RESUME;
			
			ON EXCEPTION IN (-206)
			END EXCEPTION WITH RESUME;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_consultarchivosafore.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pNombreArchivo = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cTipoRegistro, cNoContratoEmpresa, dFechaGen, dFechaInicialInformacion, dFechaFinalInformacion, 
						cNoMovimientosContenidos, cFiller, cFinLinea, cNSS, cNombreBeneficiario, cApellidoPaternoBeneficiario, 
						cApellidoMaternoBeneficiario, cFormasPago, cCLABE, dFechaCaptura, cImporteDocumentoNetoPagar, 
						cImporteDocumentoAntesImpuesto, cImpuestoRetenido, cNumeroFolioServicio, cNumeroTienda, cTipoRetiro, 
						cConsecutivoRetiro, cCURP, cRFC, cFolio_suc, cNumeroTotalMovimientosContenidos, cImporteTotalNeto, 
						cImporteTotalAntesImpuesto, cImporteRetenido, cImporteTotalRetirosPagadosEfectivo, 
						cImporteTotalRetirosPagadosDeposito, dFechaMovimientos, cEstatus, iSumaMov, mMonto, mSumaMonto;
            END IF;
            
			-- VALIDACION DE LOS DATOS DE PAGINACION
            IF pRegistros < 0 THEN
				LET cCodRet = '00098';
				RETURN cCodRet, cTipoRegistro, cNoContratoEmpresa, dFechaGen, dFechaInicialInformacion, dFechaFinalInformacion, 
						cNoMovimientosContenidos, cFiller, cFinLinea, cNSS, cNombreBeneficiario, cApellidoPaternoBeneficiario, 
						cApellidoMaternoBeneficiario, cFormasPago, cCLABE, dFechaCaptura, cImporteDocumentoNetoPagar, 
						cImporteDocumentoAntesImpuesto, cImpuestoRetenido, cNumeroFolioServicio, cNumeroTienda, cTipoRetiro, 
						cConsecutivoRetiro, cCURP, cRFC, cFolio_suc, cNumeroTotalMovimientosContenidos, cImporteTotalNeto, 
						cImporteTotalAntesImpuesto, cImporteRetenido, cImporteTotalRetirosPagadosEfectivo, 
						cImporteTotalRetirosPagadosDeposito, dFechaMovimientos, cEstatus, iSumaMov, mMonto, mSumaMonto;
            END IF;
			
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, cTipoRegistro, cNoContratoEmpresa, dFechaGen, dFechaInicialInformacion, dFechaFinalInformacion, 
						cNoMovimientosContenidos, cFiller, cFinLinea, cNSS, cNombreBeneficiario, cApellidoPaternoBeneficiario, 
						cApellidoMaternoBeneficiario, cFormasPago, cCLABE, dFechaCaptura, cImporteDocumentoNetoPagar, 
						cImporteDocumentoAntesImpuesto, cImpuestoRetenido, cNumeroFolioServicio, cNumeroTienda, cTipoRetiro, 
						cConsecutivoRetiro, cCURP, cRFC, cFolio_suc, cNumeroTotalMovimientosContenidos, cImporteTotalNeto, 
						cImporteTotalAntesImpuesto, cImporteRetenido, cImporteTotalRetirosPagadosEfectivo, 
						cImporteTotalRetirosPagadosDeposito, dFechaMovimientos, cEstatus, iSumaMov, mMonto, mSumaMonto;
			END IF;
			
			-- VALIDA NOMENCLATURA			
			IF SUBSTRING(pNombreArchivo FROM 15 FOR 2) = 'OB' OR SUBSTRING(pNombreArchivo FROM 5 FOR 2) = 'OB' THEN 
				LET pTipoArchivo = '2';
			ELSE 
				LET pTipoArchivo = '1';
			END IF;
			
			-- ELIMINACIÃN DE TABLA TEMPORAL SI EXISTE
			DROP TABLE sw_af_registros_tmp;
			
			-- CREACION DE TABLA TEMPORAL
			CREATE TEMP TABLE IF NOT EXISTS sw_af_registros_tmp(consecutivo SERIAL, usuario_tmp CHAR(20), cNSS_tmp CHAR(11), cNombreBeneficiario_tmp CHAR(40), 
			cApellidoPaternoBeneficiario_tmp CHAR(40), cApellidoMaternoBeneficiario_tmp CHAR(40), cFormasPago_tmp CHAR(1), cCLABE_tmp CHAR(18), 
			dFechaCaptura_tmp DATE, cImporteDocumentoNetoPagar_tmp CHAR(15), cImporteDocumentoAntesImpuesto_tmp CHAR(15), cImpuestoRetenido_tmp CHAR(11), 
			cNumeroFolioServicio_tmp CHAR(8), cNumeroTienda_tmp CHAR(4), cTipoRetiro_tmp CHAR(3), cConsecutivoRetiro_tmp CHAR(10), 
			cCURP_tmp CHAR(18), cRFC_tmp CHAR(10), cEstatus_tmp CHAR(2), cFolio_suc_tmp CHAR(16), cMonto_tmp MONEY(10,2), iSumaMov_tmp INTEGER) WITH NO LOG;
			DELETE FROM sw_af_registros_tmp WHERE usuario_tmp = pUsuario;
			
			SET LOCK MODE TO WAIT 3; 
		 
				FOREACH
				
					EXECUTE PROCEDURE bdiprog:"informix".sp_aforeconsultaarchivos(pNombreArchivo, pTipoArchivo) 
					INTO cCodRetSp, cTipoRegistro, cNoContratoEmpresaTmp, dFechaGenTmp, dFechaInicialInformacionTmp, dFechaFinalInformacionTmp, 
					cNoMovimientosContenidosTmp, cFiller, cFinLinea, cNSS, cNombreBeneficiario, cApellidoPaternoBeneficiario, 
					cApellidoMaternoBeneficiario, cFormasPago, cCLABE, dFechaCaptura, cImporteDocumentoNetoPagar, 
					cImporteDocumentoAntesImpuesto, cImpuestoRetenido, cNumeroFolioServicio, cNumeroTienda, cTipoRetiro, 
					cConsecutivoRetiro, cCURP, cRFC, cFolio_suc, cNumeroTotalMovimientosContenidos, cImporteTotalNeto, 
					cImporteTotalAntesImpuesto, cImporteRetenido, cImporteTotalRetirosPagadosEfectivo, 
					cImporteTotalRetirosPagadosDeposito, dFechaMovimientos, cEstatus, iSumaMov, mMonto, mSumaMonto
					
					IF cCodRetSp::INTEGER < 0 THEN
						RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃÂN DEL SP bdiprog:sp_aforeconsultaarchivos';					 
					ELIF cCodRetSp::INTEGER = 10000 THEN	
						LET cCodRet = '00481'; 
						RETURN cCodRet, cTipoRegistro, cNoContratoEmpresa, dFechaGen, dFechaInicialInformacion, dFechaFinalInformacion, 
						cNoMovimientosContenidos, cFiller, cFinLinea, cNSS, cNombreBeneficiario, cApellidoPaternoBeneficiario, 
						cApellidoMaternoBeneficiario, cFormasPago, cCLABE, dFechaCaptura, cImporteDocumentoNetoPagar, 
						cImporteDocumentoAntesImpuesto, cImpuestoRetenido, cNumeroFolioServicio, cNumeroTienda, cTipoRetiro, 
						cConsecutivoRetiro, cCURP, cRFC, cFolio_suc, cNumeroTotalMovimientosContenidos, cImporteTotalNeto, 
						cImporteTotalAntesImpuesto, cImporteRetenido, cImporteTotalRetirosPagadosEfectivo, 
						cImporteTotalRetirosPagadosDeposito, dFechaMovimientos, cEstatus, iSumaMov, mMonto, mSumaMonto;
					END IF;

					INSERT INTO sw_af_registros_tmp(usuario_tmp, cNSS_tmp, cNombreBeneficiario_tmp, cApellidoPaternoBeneficiario_tmp, cApellidoMaternoBeneficiario_tmp, 
					cFormasPago_tmp, cCLABE_tmp, dFechaCaptura_tmp, cImporteDocumentoNetoPagar_tmp, cImporteDocumentoAntesImpuesto_tmp, cImpuestoRetenido_tmp, 
					cNumeroFolioServicio_tmp, cNumeroTienda_tmp, cTipoRetiro_tmp, cConsecutivoRetiro_tmp, cCURP_tmp, cRFC_tmp, cEstatus_tmp, cFolio_suc_tmp, cMonto_tmp, iSumaMov_tmp) 
					VALUES (pUsuario, cNSS, cNombreBeneficiario, cApellidoPaternoBeneficiario, cApellidoMaternoBeneficiario, cFormasPago, cCLABE, 
					dFechaCaptura, cImporteDocumentoNetoPagar, cImporteDocumentoAntesImpuesto, cImpuestoRetenido, cNumeroFolioServicio,
					cNumeroTienda, cTipoRetiro, cConsecutivoRetiro, cCURP, cRFC, cEstatus, cFolio_suc, mMonto, iSumaMov);
					
					IF DBINFO('sqlca.sqlerrd2') = 1 THEN
						LET iNoRegistros = iNoRegistros + 1;
					END IF;
					
				END FOREACH;
			
			SET ISOLATION TO DIRTY READ;
			LET iNoRegistros = 0;
			
			SELECT MIN(consecutivo)
			INTO iMinimo FROM sw_af_registros_tmp;

			SELECT MAX(consecutivo)
			INTO iMaximo FROM sw_af_registros_tmp;
			
			FOREACH --WITH HOLD
				
				SELECT SKIP pRegistros FIRST pRecuperacion cNSS_tmp, cNombreBeneficiario_tmp, cApellidoPaternoBeneficiario_tmp, cApellidoMaternoBeneficiario_tmp, 
				cFormasPago_tmp, cCLABE_tmp, dFechaCaptura_tmp, cImporteDocumentoNetoPagar_tmp, cImporteDocumentoAntesImpuesto_tmp, cImpuestoRetenido_tmp, 
				cNumeroFolioServicio_tmp, cNumeroTienda_tmp, cTipoRetiro_tmp, cConsecutivoRetiro_tmp, cCURP_tmp, cRFC_tmp, cEstatus_tmp, cFolio_suc_tmp, cMonto_tmp, iSumaMov_tmp
				INTO cNSS, cNombreBeneficiario, cApellidoPaternoBeneficiario, cApellidoMaternoBeneficiario, cFormasPago, cCLABE, 
				dFechaCaptura, cImporteDocumentoNetoPagar, cImporteDocumentoAntesImpuesto, cImpuestoRetenido, cNumeroFolioServicio,
				cNumeroTienda, cTipoRetiro, cConsecutivoRetiro, cCURP, cRFC, cEstatus, cFolio_suc, mMonto, iSumaMov--cNumeroTotalMovimientosContenidos
				FROM sw_af_registros_tmp
				WHERE consecutivo NOT IN (iMaximo,iMinimo) 
				AND usuario_tmp = pUsuario
				
				-- DATOS DEL ENCABEZADO	
				IF pNombreArchivo LIKE 'PAGOS%' OR pNombreArchivo LIKE 'CONF%' THEN 
					IF pNombreArchivo LIKE 'CONF%' THEN
						IF pTipoArchivo = '1' THEN  
							LET cNombre = 'PAGOS'||SUBSTR(pNombreArchivo,5,9)||'A'||SUBSTR(pNombreArchivo,15,30);
						ELIF pTipoArchivo = '2' THEN
							LET cNombre = 'PAGOS' || SUBSTR(pNombreArchivo,7,9) || 'OBA' || SUBSTR(pNombreArchivo,17,30);
						END IF; 
					ELSE
						LET cNombre = pNombreArchivo;
					END IF;
					
					SELECT contrato, fecha_gen, fecha_ini, fecha_fin, no_mov
					INTO cNoContratoEmpresa, dFechaGen, dFechaInicialInformacion, dFechaFinalInformacion, cNoMovimientosContenidos
					FROM bdiprog:pp_Encabezado WHERE nombre_arch = cNombre; 
				ELSE 
					--DATOS DEL ENCABEZADO
					LET cTipoRegistro = 'E';
		
					SELECT fecha_hoy INTO dFecha_Hoy FROM Bdinteg:si_fechas;
					LET dFechaGen = dFecha_Hoy;
					LET dFechaMovimientos = dFecha_Hoy;
				END IF;
				
				RETURN 	cCodRet, NVL(UPPER(cTipoRegistro),''), NVL(cNoContratoEmpresa,''), NVL(dFechaGen,''), NVL(dFechaInicialInformacion,''), NVL(dFechaFinalInformacion,''), 
				NVL(cNoMovimientosContenidos,''), NVL(cFiller,''), NVL(cFinLinea,''), NVL(cNSS,''), NVL(UPPER(cNombreBeneficiario),''), NVL(UPPER(cApellidoPaternoBeneficiario),''), 
				NVL(UPPER(cApellidoMaternoBeneficiario),''), NVL(cFormasPago,''), NVL(cCLABE,''), NVL(dFechaCaptura,''), NVL(cImporteDocumentoNetoPagar,0), 
				NVL(cImporteDocumentoAntesImpuesto,0), NVL(cImpuestoRetenido,0), NVL(cNumeroFolioServicio,''), NVL(cNumeroTienda,''), NVL(cTipoRetiro,''), 
				NVL(cConsecutivoRetiro,''), NVL(UPPER(cCURP),''), NVL(UPPER(cRFC),''), NVL(cFolio_suc,''), NVL(cNumeroTotalMovimientosContenidos,''), NVL(cImporteTotalNeto,0), 
				NVL(cImporteTotalAntesImpuesto,0), NVL(cImporteRetenido,0), NVL(cImporteTotalRetirosPagadosEfectivo,0), 
				NVL(cImporteTotalRetirosPagadosDeposito,0), NVL(dFechaMovimientos,''), NVL(cEstatus,''), NVL(iSumaMov,0), NVL(mMonto,0), NVL(mSumaMonto,0) WITH RESUME;
				LET iNoRegistros = iNoRegistros + 1;
			END FOREACH;
			
			IF iNoRegistros = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017'; 
				RETURN cCodRet, cTipoRegistro, cNoContratoEmpresa, dFechaGen, dFechaInicialInformacion, dFechaFinalInformacion, 
						cNoMovimientosContenidos, cFiller, cFinLinea, cNSS, cNombreBeneficiario, cApellidoPaternoBeneficiario, 
						cApellidoMaternoBeneficiario, cFormasPago, cCLABE, dFechaCaptura, cImporteDocumentoNetoPagar, 
						cImporteDocumentoAntesImpuesto, cImpuestoRetenido, cNumeroFolioServicio, cNumeroTienda, cTipoRetiro, 
						cConsecutivoRetiro, cCURP, cRFC, cFolio_suc, cNumeroTotalMovimientosContenidos, cImporteTotalNeto, 
						cImporteTotalAntesImpuesto, cImporteRetenido, cImporteTotalRetirosPagadosEfectivo, 
						cImporteTotalRetirosPagadosDeposito, dFechaMovimientos, cEstatus, iSumaMov, mMonto, mSumaMonto;
			ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, cTipoRegistro, cNoContratoEmpresa, dFechaGen, dFechaInicialInformacion, dFechaFinalInformacion, 
						cNoMovimientosContenidos, cFiller, cFinLinea, cNSS, cNombreBeneficiario, cApellidoPaternoBeneficiario, 
						cApellidoMaternoBeneficiario, cFormasPago, cCLABE, dFechaCaptura, cImporteDocumentoNetoPagar, 
						cImporteDocumentoAntesImpuesto, cImpuestoRetenido, cNumeroFolioServicio, cNumeroTienda, cTipoRetiro, 
						cConsecutivoRetiro, cCURP, cRFC, cFolio_suc, cNumeroTotalMovimientosContenidos, cImporteTotalNeto, 
						cImporteTotalAntesImpuesto, cImporteRetenido, cImporteTotalRetirosPagadosEfectivo, 
						cImporteTotalRetirosPagadosDeposito, dFechaMovimientos, cEstatus, iSumaMov, mMonto, mSumaMonto;
			END IF;	
			
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 03/06/2015',
'DESCRIPCION: SPL encargado de consultar los archivos de pagos, confirmacion y control Afore.',
'FUNCIONALIDAD: Consulta de Archivos - Proceso AFORE', 
'MODULO: AFORE',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 22/10/2015',
'DESCRIPCION: Se realizÃ³ la modificaciÃ³n para el llenado del detalle de los encabezados y el detalle de los registros a mostrar en el grid',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_devolucionextemporanea_tef(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaArch CHAR(8), pPlantilla CHAR(25), pTituloPlantilla CHAR(255))
	RETURNING CHAR(5) AS codret,
			INTEGER AS registros_procesados;
		
	DEFINE cCodRet		CHAR(5);
	DEFINE cCodRetSp	CHAR(5);
	DEFINE iSqlErr		INTEGER;
	DEFINE iNoRegs		INTEGER;
	DEFINE iInTrans		INTEGER;
	DEFINE iTotalRegs	INTEGER;
	DEFINE mTotalMonto	MONEY(14,2);
	DEFINE dFechaMail	DATETIME YEAR TO SECOND;
	----R
	DEFINE cValorSucContTef CHAR(100);
	DEFINE cValorTransacCargoTef CHAR(100);
	DEFINE cNumeroFolio CHAR(16);
	DEFINE iIdx INTEGER;
	DEFINE vsFechaAbono CHAR(8);
	DEFINE vsCuenta CHAR(20);
	DEFINE vsReferencia CHAR(18);
	DEFINE vsBanco CHAR(40);
	DEFINE vsImporte CHAR(30);
	DEFINE vsEstatus CHAR(10);
	DEFINE vsConfirmado CHAR(1);
	DEFINE vsNumSecuencia CHAR(7);
	DEFINE vsClaveRastreo CHAR(30);
	DEFINE vsCveStatus CHAR(2);
	DEFINE vsMotDev CHAR(2);
	DEFINE vsEstatusReg CHAR(1);
	DEFINE vsAuxCta CHAR(11);
	DEFINE vsAuxTarjeta CHAR(16);
	DEFINE vsImporteAux CHAR(30);
	DEFINE vTranret CHAR(4);
	DEFINE vFechoy DATE;
	DEFINE vSdodisp MONEY(14,2);
	DEFINE vMontoret MONEY(14,2);
	
	LET iSqlErr = 0;
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iNoRegs = 0;
	LET iInTrans = 0;
	LET iTotalRegs = 0;
	LET mTotalMonto	= NULL;	
	----R
	LET cValorSucContTef = '';
	LET cValorTransacCargoTef = '';
	LET cNumeroFolio = '';
	LET iIdx =  0;
	LET vsFechaAbono = "";
	LET vsCuenta = "";
	LET vsReferencia = "";
	LET vsBanco = "";
	LET vsImporte = "";
	LET vsEstatus = "";
	LET vsConfirmado = "";
	LET vsNumSecuencia = "";
	LET vsClaveRastreo = "";
	LET vsCveStatus = "";
	LET vsMotDev = '';
	LET vsEstatusReg = '';
	LET vsAuxCta = '';
	LET vsAuxTarjeta = '';
	LET vsImporteAux = '';
	LET vTranret = '';
	LET vFechoy = NULL;
	LET vSdodisp = 0;
	LET vMontoret = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			IF iInTrans = 1 THEN
				BEGIN WORK;
			END IF;
			RETURN cCodRet, iNoRegs;				
		END EXCEPTION;

		ON EXCEPTION IN(-535)
			LET iInTrans = 1;
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		--
		--ON EXCEPTION IN(-255)
		--	LET iInTrans = 1;
		--	COMMIT WORK;
		--	BEGIN WORK;
		--END EXCEPTION WITH RESUME;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_devolucionextemporanea_tef.out';
		-- TRACE ON;
				
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaArch = '' OR pPlantilla = '' OR pTituloPlantilla = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegs;
		END IF;
		
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegs;
		END IF;
		
		BEGIN WORK;
		--	
		--IF iInTrans = 0 THEN
		--	COMMIT WORK;
		--END IF
			
		--Consulta de parametros
		SET ISOLATION TO DIRTY READ;
		SELECT FIRST 1 valor 
		INTO cValorSucContTef
		FROM bditef:tef_parametros 
		WHERE cod_param = '77';
		
		SET ISOLATION TO DIRTY READ;
		SELECT FIRST 1 valor 
		INTO cValorTransacCargoTef
		FROM bditef:tef_parametros 
		WHERE cod_param = '78';
		
		--Consulta de folio nomina
		EXECUTE FUNCTION bdicheq:"informix".sp_generafolionomina(pUsuario) INTO cCodRetSp , cNumeroFolio;
		IF cCodRetSp::INTEGER > 0 THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegs;
		END IF;
				
		-- Se recorre la tabla
		SET ISOLATION TO DIRTY READ;
		FOREACH WITH HOLD SELECT idx, fecha_abono, cuenta, referencia, banco, importe, estatus, confirmado, num_secuencia, clave_rastreo, cve_status, motivo_devolucion, estatus_reg
			INTO iIdx, vsFechaAbono, vsCuenta, vsReferencia, vsBanco, vsImporte, vsEstatus, vsConfirmado, vsNumSecuencia, vsClaveRastreo, vsCveStatus, vsMotDev, vsEstatusReg
			FROM bdicnweb:"informix".sw_tf_consdevext_tef
			WHERE motivo_devolucion != '' and estatus_reg = 'P'

			LET vsAuxTarjeta = '';
			LET vsAuxCta = '';
			LET cCodRetSp = '';
			LET vsImporteAux = '';

			LET vsImporteAux = SUBSTRING(TRIM(vsImporte) FROM 1 FOR (LENGTH(vsImporte)-2)) ||'.'||SUBSTRING(TRIM(vsImporte) FROM (LENGTH(vsImporte)-1) FOR  2);
			
			IF SUBSTRING(TRIM(vsCuenta) FROM  1 FOR 4) = '0000' THEN
				LET vsAuxTarjeta = SUBSTRING(TRIM(vsCuenta) FROM  5 FOR 16);
			ELIF SUBSTRING(TRIM(vsCuenta) FROM  1 FOR 2) = '00' THEN
				LET vsAuxCta = SUBSTRING(TRIM(vsCuenta) FROM  9 FOR 11);
			END IF;
			
			IF vsAuxCta = '' AND vsAuxTarjeta !='' THEN 
				EXECUTE FUNCTION bdicheq:"informix".sp_obtener_cta_con_num_tar('001', vsAuxTarjeta) INTO cCodRetSp, vsAuxCta;
			END IF;
			
			---genera cargo
			EXECUTE FUNCTION bdicheq:"informix".cargo_ref('001', cValorSucContTef, pUsuario, cValorTransacCargoTef, '0000', cNumeroFolio, vsAuxCta, 0, vsImporteAux, '01', vsClaveRastreo, vsAuxTarjeta, pUsuario) INTO cCodRetSp, vTranret, vFechoy, vSdodisp, vMontoret;

			IF cCodRetSp::INTEGER > 0 OR cCodRetSp::INTEGER < 0 THEN 
				--Graba error
				SET LOCK MODE TO WAIT 3;
				INSERT INTO bditef:"informix".tef_errores (fecha_error, hora_error, cod_error, nombre_arch, sp_llamado, mensaje_error, user_insert, fecha_insert)
				VALUES (CURRENT::DATE, CURRENT, cCodRetSp, '','bdicheq:cargo_ref','', pUsuario, CURRENT::DATE);
			ELSE 
				FOREACH EXECUTE FUNCTION bditef:"informix".sp_consdevext_tef('2', vsFechaAbono, vsMotDev , vsNumSecuencia, vsCuenta , vsReferencia)
					INTO cCodRetSp, vsFechaAbono, vsCuenta, vsReferencia, vsBanco, vsImporte, vsEstatus, vsConfirmado, vsNumSecuencia, vsClaveRastreo, vsCveStatus
				END FOREACH;
				LET iNoRegs = iNoRegs + 1;
			END IF;
			
			SET LOCK MODE TO WAIT 3;
			UPDATE bdicnweb:"informix".sw_tf_consdevext_tef
			SET estatus_reg = 'E', motivo_devolucion = ''
			WHERE idx = iIdx;		
			
			--IF iInTrans=1 THEN
			--	COMMIT WORK;
			--	BEGIN WORK;
			--END IF;
			
			--COMMIT WORK;
			
			IF iInTrans = 1 THEN
				COMMIT;
				BEGIN WORK;
			ELSE
				COMMIT WORK;
			END IF;
			
			CONTINUE FOREACH;
			
		END FOREACH;
		
	--r	-- Notificación de correo electronico
	--r	SELECT total_registros, total_monto
	--r	INTO iTotalRegs, mTotalMonto
	--r	FROM sw_tr_totales_masivo
	--r	WHERE id_funcion = pIdFuncion AND id_lote = pLote;
	--r	
	--r	LET dFechaMail = current;
	--r	EXECUTE FUNCTION bdimnsj:"informix".sp_registra_evento
	--r		('1'
	--r		, TRIM(pPlantilla)
	--r		, TRIM(pPlantilla)			
	--r		, pUsuario
	--r		,''
	--r		,''
	--r		,'1'
	--r		, pLote
	--r		,NVL(iTotalRegs, 0)
	--r		,TRIM(TO_CHAR(NVL(mTotalMonto, 0.00), "#,###,###,###,###.##"))
	--r		,''
	--r		,''
	--r		,''
	--r		,''
	--r		,''
	--r		,''
	--r		, TRIM(pTituloPlantilla)
	--r		,''
	--r		,''
	--r		,'0'
	--r		,'0'
	--r		,'0'
	--r		,'0'
	--r		,'0'
	--r		,dFechaMail
	--r		,dFechaMail) INTO cCodRetSp;
	--r	
		--IF iInTrans = 1 THEN
		--	BEGIN WORK;
		--END IF;
		
		RETURN cCodRet, iNoRegs;
	END;
	
END PROCEDURE
DOCUMENT "AUTOR: Rodolfo Conde Flores",
"FECHA: 09/08/2013",
"DESCRIPCION: Realiza las devoluciones extemporaneas Tef SOCWEB",
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dispersionafore(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(30))
					
		RETURNING CHAR(5) AS codret;
			
		DEFINE cCodRet CHAR(5);
		DEFINE cCodRetSp CHAR(6);
        DEFINE iSqlErr INTEGER;	
		DEFINE cHoraProceso CHAR(21);
		DEFINE cHoraServidor CHAR(21);
		DEFINE pTipoArchivo CHAR(1);
		DEFINE cMensajeRet CHAR(50);
		DEFINE iRecuperacion INTEGER;
		DEFINE bInTrans BOOLEAN;
		
		LET cCodRet = '00000';
		LET cCodRetSp = '';
        LET iSqlErr = 0;	
		LET cHoraProceso = '';
		LET cHoraServidor = '';
		LET pTipoArchivo = '';
		LET cMensajeRet = '';
		LET iRecuperacion = 0;
		LET bInTrans = 'f';

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END EXCEPTION;
			
			ON EXCEPTION IN (-535)
				LET bInTrans = 't';
				COMMIT WORK;
			END EXCEPTION WITH RESUME;
            
            -- SET DEBUG FILE TO '/tmp/mfinis/sp_dispersionafore.out';
            -- TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet;
			END IF;
			
			-- CONSULTA El LIMITE DE HORARIO PERMITIDO
			SELECT valor INTO cHoraProceso FROM bdisac:"informix".sac_param WHERE cod_param = '6036';
			IF cHoraProceso = '' OR cHoraProceso IS NULL THEN
				LET cCodRet = '00515'; --NO SE PUDO OBTENER LA HORA DEL SERVIDOR
				RETURN cCodRet;
			END IF;
			
			-- CONSULTA LA HR DEL SERVIDOR
			EXECUTE PROCEDURE bdiprog:"informix".sp_validahoraejec('001') INTO cCodRetSp, cHoraServidor;
			IF cCodRetSp::INTEGER < 0 THEN
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdiprog:sp_validahoraejec';
			ELIF cCodRetSp::INTEGER > 0 THEN
				LET cCodRet = '00515'; --NO SE PUDO OBTENER LA HORA DEL SERVIDOR
				RETURN cCodRet;
			END IF;
			
			-- VALIDA NOMENCLATURA		
			IF SUBSTRING(pNombreArchivo FROM 15 FOR 2) = 'OB' THEN 
				IF (cHoraServidor > cHoraProceso) THEN
					LET cCodRet = '00434';
					RETURN cCodRet;
				ELSE
					LET pTipoArchivo = '2';
				END IF;
			ELSE 
				LET pTipoArchivo = '1';
			END IF;
		 
			-- GENERA EL LLAMADO AL PROCESO DE PAGOS DE ARCHIVOS
			BEGIN WORK;
			IF bInTrans = 'f' THEN
				COMMIT WORK;
			END IF;
			
			EXECUTE PROCEDURE bdiprog:"informix".sp_afore_dispersion(pNombreArchivo, pUsuario, pTipoArchivo) 
			INTO cCodRetSp, cMensajeRet;
			
			IF bInTrans = 't' THEN
				BEGIN WORK;
			END IF;
			
			IF cCodRetSp::INTEGER < 0 THEN
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdiprog:sp_afore_dispersion';
			ELIF cCodRetSp::INTEGER = 10000 THEN
				LET cCodRet = '00481'; 
			ELIF cCodRetSp::INTEGER = 10001 THEN	
				LET cCodRet = '00482'; 
			ELIF cCodRetSp::INTEGER = 10002 THEN
				LET cCodRet = '00483'; 
			ELIF cCodRetSp::INTEGER = 10003 THEN	
				LET cCodRet = '00484'; 
			ELIF cCodRetSp::INTEGER = 10004 THEN
				LET cCodRet = '00485'; 
			ELIF cCodRetSp::INTEGER = 10005 THEN	
				LET cCodRet = '00486'; 
			ELIF cCodRetSp::INTEGER = 10006 THEN
				LET cCodRet = '00487';
			ELIF cCodRetSp::INTEGER = 10007 THEN
				LET cCodRet = '00488';
			ELIF cCodRetSp::INTEGER = 10008 THEN
				LET cCodRet = '00489'; 
			ELIF cCodRetSp::INTEGER = 10009 THEN	
				LET cCodRet = '00490'; 
			ELIF cCodRetSp::INTEGER = 10010 THEN	
				LET cCodRet = '00491';
			ELIF cCodRetSp::INTEGER = 10011 THEN
				LET cCodRet = '00492'; 
			ELIF cCodRetSp::INTEGER = 10012 THEN
				LET cCodRet = '00493'; 
			ELIF cCodRetSp::INTEGER = 10013 THEN	
				LET cCodRet = '00494';
			ELIF cCodRetSp::INTEGER = 10014 THEN	
				LET cCodRet = '00438'; 
			ELIF cCodRetSp::INTEGER = 10015 THEN
				LET cCodRet = '00495';
			ELIF cCodRetSp::INTEGER = 10016 THEN
				LET cCodRet = '00496'; 
			ELIF cCodRetSp::INTEGER = 10017 THEN
				LET cCodRet = '00497';
			ELIF cCodRetSp::INTEGER = 10018 THEN	
				LET cCodRet = '00498'; 
			ELIF cCodRetSp::INTEGER = 10019 THEN	
				LET cCodRet = '00499';
			ELIF cCodRetSp::INTEGER = 10020 THEN	
				LET cCodRet = '00500'; 
			ELIF cCodRetSp::INTEGER = 10021 THEN
				LET cCodRet = '00501'; 
			ELIF cCodRetSp::INTEGER = 10022 THEN	
				LET cCodRet = '00496'; 
			ELIF cCodRetSp::INTEGER = 10023 THEN
				LET cCodRet = '00502'; 
			ELIF cCodRetSp::INTEGER = 10024 THEN	
				LET cCodRet = '00503';
			ELIF cCodRetSp::INTEGER = 10025 THEN	
				LET cCodRet = '00504'; 
			ELIF cCodRetSp::INTEGER = 10026 THEN	
				LET cCodRet = '00505'; 
			ELIF cCodRetSp::INTEGER = 10027 THEN	
				LET cCodRet = '00017'; 
			ELIF cCodRetSp::INTEGER = 10028 THEN
				LET cCodRet = '00506'; 
			ELIF cCodRetSp::INTEGER = 10029 THEN
				LET cCodRet = '00507'; 
			ELIF cCodRetSp::INTEGER = 10030 THEN
				LET cCodRet = '00508'; 
			ELIF cCodRetSp::INTEGER = 10031 THEN	
				LET cCodRet = '00509';
			ELIF cCodRetSp::INTEGER = 10032 THEN	
				LET cCodRet = '00510';
			ELIF cCodRetSp::INTEGER = 10549 THEN
				LET cCodRet = '00511'; 
			ELIF cCodRetSp::INTEGER = 10034 THEN
				LET cCodRet = '00512';
			ELIF cCodRetSp::INTEGER = 10035 THEN
				LET cCodRet = '00513'; 
			ELIF cCodRetSp::INTEGER = 10036 THEN
				LET cCodRet = '00514';
			END IF;
				
			RETURN cCodRet;
			
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 27/05/2015',
'DESCRIPCION: SPL encargado de generar el pago de las cuentas de afore segÃºn el archivo y sus importes.',
'FUNCIONALIDAD: EjecuciÃ³n de Pagos Pendientes â Procesos AFORE', 
'MODULO: AFORE',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genreportealtaoptef(pUsuario CHAR(8), pIdFuncion CHAR(10), pClaveRastreo CHAR(30))
		RETURNING CHAR(5) AS codret,
			DATE 	  AS fecha_trans,
			CHAR(30)  AS clave_rastreo,
			CHAR(10)  AS importe_tef,
			DATE 	  AS fecha_programacion,
			CHAR(45)  AS nombre_usuario,
			CHAR(16)  AS folio_suc,
			CHAR(30)  AS nombre_cte_ord,
			CHAR(20)  AS num_cte_ord,
			CHAR(20)  AS num_cta_ord,
			CHAR(30)  AS tipo_cta_ord_desc,
			CHAR(5)	  AS comision_tef,
			CHAR(5)	  AS iva_tef,
			CHAR(30)  AS nombre_ben,
			CHAR(30)  AS tipo_cta_ben_desc,
			CHAR(20)  AS num_cuenta_tarj_ben,
			CHAR(15)  AS rfc_ben,
			CHAR(50)  AS concepto_pago,
			CHAR(7)	  AS ref_num,
			CHAR(8)   AS hora_trans;

		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE cCodRetSp2 CHAR(5);
		DEFINE cDescCodRet CHAR(100);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
		DEFINE cEmpresa CHAR(3);
		DEFINE dFechaTrans DATE;
		DEFINE cClaveRastreo CHAR(30);
		DEFINE cImporteTef CHAR(10);
		DEFINE dFechaProgramacion DATE;
		DEFINE cNombreUsuario CHAR(45);
		DEFINE cFolioSuc CHAR(16);
		DEFINE cNombreCteOrd CHAR(30);
		DEFINE cNumCteOrd CHAR(20);
		DEFINE cNumCtaOrd CHAR(20);
		--DEFINE cTipoCtaOrd CHAR(2);
		DEFINE cTipoCtaOrdDesc CHAR(30);
		DEFINE cComisionTef CHAR(5);
		DEFINE cIvaTef CHAR(5);
		DEFINE cNombreBen CHAR(30);
		--DEFINE cTipoCtaBen CHAR(2);
		DEFINE cTipoCtaBenDes CHAR(30);
		DEFINE cNumCtaTarjBen CHAR(20);
		DEFINE cRfcBen CHAR(15);
		DEFINE cConceptoPago CHAR(50);
		DEFINE cRefNum CHAR(7);
		--DEFINE cUsuario CHAR(8);
		DEFINE cHoraTrans CHAR(8);
		DEFINE iNoRegistros INTEGER;

		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET cCodRetSp2 = '';
		LET cDescCodRet = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		LET cEmpresa = '001';
		LET dFechaTrans = '';
		LET cClaveRastreo = '';
		LET cImporteTef = '';
		LET dFechaProgramacion = '';
		LET cNombreUsuario = '';
		LET cFolioSuc = '';
		LET cNombreCteOrd = '';
		LET cNumCteOrd = '';
		LET cNumCtaOrd = '';
		--LET cTipoCtaOrd = '';
		LET cTipoCtaOrdDesc = '';
		LET cComisionTef = '';
		LET cIvaTef = '';
		LET cNombreBen = '';
		--LET cTipoCtaBen = '';
		LET cTipoCtaBenDes = '';
		LET cNumCtaTarjBen = '';
		LET cRfcBen = '';
		LET cConceptoPago = '';
		LET cRefNum = '';
		--LET cUsuario = '';
		LET cHoraTrans = '';
		LET iNoRegistros = 0;

		BEGIN

			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet, dFechaTrans, cClaveRastreo, cImporteTef, dFechaProgramacion, cNombreUsuario, cFolioSuc, cNombreCteOrd,
			           cNumCteOrd, cNumCtaOrd, cTipoCtaOrdDesc, cComisionTef, cIvaTef, cNombreBen, cTipoCtaBenDes, cNumCtaTarjBen,
			           cRfcBen, cConceptoPago, cRefNum, cHoraTrans;
			END EXCEPTION;

            -- SET DEBUG FILE TO '/tmp/mfinis/sp_genreportealtaoptef.out';
            -- TRACE ON;

            IF pUsuario = '' OR pIdFuncion = '' OR pClaveRastreo = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, dFechaTrans, cClaveRastreo, cImporteTef, dFechaProgramacion, cNombreUsuario, cFolioSuc, cNombreCteOrd,
			           cNumCteOrd, cNumCtaOrd, cTipoCtaOrdDesc, cComisionTef, cIvaTef, cNombreBen, cTipoCtaBenDes, cNumCtaTarjBen,
			           cRfcBen, cConceptoPago, cRefNum, cHoraTrans;
            END IF;

            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, dFechaTrans, cClaveRastreo, cImporteTef, dFechaProgramacion, cNombreUsuario, cFolioSuc, cNombreCteOrd,
			           cNumCteOrd, cNumCtaOrd, cTipoCtaOrdDesc, cComisionTef, cIvaTef, cNombreBen, cTipoCtaBenDes, cNumCtaTarjBen,
			           cRfcBen, cConceptoPago, cRefNum, cHoraTrans;
			END IF;

			SET ISOLATION TO DIRTY READ;
            SET LOCK MODE TO WAIT 3;

			EXECUTE PROCEDURE bditef:"informix".sp_tef_obtinforpt(pClaveRastreo)
			INTO cCodRetSp, cDescCodRet, dFechaTrans, cClaveRastreo, cImporteTef, dFechaProgramacion, cNombreUsuario, cFolioSuc,
				 cNombreCteOrd, cNumCteOrd, cNumCtaOrd, cTipoCtaOrdDesc, cComisionTef, cIvaTef, cNombreBen, cTipoCtaBenDes,
				 cNumCtaTarjBen, cRfcBen, cConceptoPago, cRefNum, cHoraTrans;

			IF cCodRetSp::INTEGER < 0 THEN
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bditef:sp_tef_obtinforpt';
			ELIF cCodRetSp::INTEGER = 1 THEN
				LET cCodRet = '00003';
				RETURN cCodRet, dFechaTrans, cClaveRastreo, cImporteTef, dFechaProgramacion, cNombreUsuario, cFolioSuc, cNombreCteOrd,
			           cNumCteOrd, cNumCtaOrd, cTipoCtaOrdDesc, cComisionTef, cIvaTef, cNombreBen, cTipoCtaBenDes, cNumCtaTarjBen,
			           cRfcBen, cConceptoPago, cRefNum, cHoraTrans;
			ELIF cCodRetSp::INTEGER = 2 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, dFechaTrans, cClaveRastreo, cImporteTef, dFechaProgramacion, cNombreUsuario, cFolioSuc, cNombreCteOrd,
			           cNumCteOrd, cNumCtaOrd, cTipoCtaOrdDesc, cComisionTef, cIvaTef, cNombreBen, cTipoCtaBenDes, cNumCtaTarjBen,
			           cRfcBen, cConceptoPago, cRefNum, cHoraTrans;
			END IF;

			IF cCodRetSp::INTEGER = 0 THEN
				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet, dFechaTrans, UPPER(cClaveRastreo), cImporteTef, dFechaProgramacion, UPPER(cNombreUsuario), cFolioSuc, UPPER(cNombreCteOrd),
			           cNumCteOrd, cNumCtaOrd, UPPER(cTipoCtaOrdDesc), cComisionTef, cIvaTef, UPPER(cNombreBen), UPPER(cTipoCtaBenDes), cNumCtaTarjBen,
			           UPPER(cRfcBen), UPPER(cConceptoPago), cRefNum, cHoraTrans;
			END IF;

			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, dFechaTrans, cClaveRastreo, cImporteTef, dFechaProgramacion, cNombreUsuario, cFolioSuc, cNombreCteOrd,
			           cNumCteOrd, cNumCtaOrd, cTipoCtaOrdDesc, cComisionTef, cIvaTef, cNombreBen, cTipoCtaBenDes, cNumCtaTarjBen,
			           cRfcBen, cConceptoPago, cRefNum, cHoraTrans;
			END IF;

		END;

END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 05/08/2015',
'DESCRIPCION: SPL que se encarga de obtener la informacion para visualizar el reporte de alta operaciones TEF.',
'FUNCIONALIDAD: Captura de Operaciones TEF',
'MODULO: TEF',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genreportepagdiariosafore(pUsuario CHAR(8),pIdFuncion CHAR(10),pFechaConsulta DATE, pRegistros INTEGER, pRecuperacion INTEGER)
					
		RETURNING CHAR(5) AS codret,
			CHAR(18) AS clabe,
			CHAR(40) AS tipo_cuenta,
			CHAR(120) AS nombre_cliente,
			MONEY(17,2) AS importe,
			MONEY(17,2) AS comision,
			DECIMAL(18,2) AS iva,
			CHAR(30) AS estados_pago,
			CHAR(2) AS estado,
			DATE AS fecha_hoy,
			INTEGER AS num_total_pagados,
			MONEY(17,2) AS imp_total_pagados,
			INTEGER AS num_total_no_pagados,
			MONEY(17,2) AS imp_total_no_pagados,
			CHAR(1) AS tipo_archivo;
		
			
		DEFINE cCodRet 			   CHAR(5);
		DEFINE cCodRetSp           CHAR(6);
        DEFINE iSqlErr             INTEGER;
		DEFINE cCLABE              CHAR(18);
		DEFINE cTipoCuenta         CHAR(40);
		DEFINE cNombreCliente      CHAR(120);
		DEFINE mImporte            MONEY(17,2);
		DEFINE mComision           MONEY(17,2);
		DEFINE dIVA                DECIMAL(18,2);
		DEFINE cEstadosPago        CHAR(30);
		DEFINE cEstado             CHAR(2);
		DEFINE dFechaHoy           DATE;
		DEFINE iNumTotalPagados    INTEGER;
		DEFINE mImpTotalPagados    MONEY(17,2);
		DEFINE iNumTotalNoPagados  INTEGER;
		DEFINE mImpTotalNoPagados  MONEY(17,2);
		DEFINE cTipoArchivo        CHAR(1);
		DEFINE iRecuperacion       INTEGER;
		
		LET cCodRet 		       = '00000';
		LET cCodRetSp              = '';
        LET iSqlErr                = 0;	
		LET cCLABE                 = '';
		LET cTipoCuenta            = '';
		LET cNombreCliente         = '';
		LET mImporte               = 0.00;
		LET mComision              = 0.00;
		LET dIVA                   = 0.00;
		LET cEstadosPago           = '';
		LET cEstado                = '';
		LET dFechaHoy              = '';
		LET iNumTotalPagados       = 0;
		LET mImpTotalPagados       = 0.00;
		LET iNumTotalNoPagados     = 0;
		LET mImpTotalNoPagados     = 0.00;
		LET cTipoArchivo           = '';
		LET iRecuperacion          = 0;
		

		BEGIN		
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet,cCLABE,cTipoCuenta,cNombreCliente,mImporte,mComision,dIVA,cEstadosPago,
					   cEstado,dFechaHoy,iNumTotalPagados,mImpTotalPagados,iNumTotalNoPagados,mImpTotalNoPagados,cTipoArchivo;
			END EXCEPTION;
            
            -- SET DEBUG FILE TO '/tmp/mfinis/sp_genreportepagdiariosafore.out';
            -- TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pFechaConsulta IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet,cCLABE,cTipoCuenta,cNombreCliente,mImporte,mComision,dIVA,cEstadosPago,
					   cEstado,dFechaHoy,iNumTotalPagados,mImpTotalPagados,iNumTotalNoPagados,mImpTotalNoPagados,cTipoArchivo;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet,cCLABE,cTipoCuenta,cNombreCliente,mImporte,mComision,dIVA,cEstadosPago,
					   cEstado,dFechaHoy,iNumTotalPagados,mImpTotalPagados,iNumTotalNoPagados,mImpTotalNoPagados,cTipoArchivo;
			END IF;
			
			FOREACH
				EXECUTE PROCEDURE bdiprog:"informix".sp_aforegenerarreportedetallepagosdiarios2(pFechaConsulta, pRegistros, pRecuperacion) 
				INTO cCodRetSp,cCLABE,cTipoCuenta,cNombreCliente,mImporte,mComision,dIVA,cEstadosPago,
					 cEstado,dFechaHoy,iNumTotalPagados,mImpTotalPagados,iNumTotalNoPagados,mImpTotalNoPagados,cTipoArchivo
				
				IF cCodRetSp::INTEGER < 0 THEN
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdiprog:sp_aforegenerarreportedetallepagosdiarios';
				ELIF cCodRetSp::INTEGER = 10010 THEN	
					LET cCodRet = '00491'; 
					RETURN cCodRet,cCLABE,cTipoCuenta,cNombreCliente,mImporte,mComision,dIVA,cEstadosPago,
						   cEstado,dFechaHoy,iNumTotalPagados,mImpTotalPagados,iNumTotalNoPagados,mImpTotalNoPagados,cTipoArchivo;
				ELSE
					IF cCLABE <> "" AND cTipoCuenta <> "" AND cNombreCliente <> ""  AND cEstadosPago <> "" AND cEstado <> "" THEN
						LET iRecuperacion = iRecuperacion + 1;
						RETURN cCodRet,cCLABE,UPPER(cTipoCuenta),UPPER(cNombreCliente),mImporte,mComision,dIVA,UPPER(cEstadosPago),
							   cEstado,dFechaHoy,iNumTotalPagados,mImpTotalPagados,iNumTotalNoPagados,mImpTotalNoPagados,cTipoArchivo WITH RESUME;
					END IF;
				END IF;
			END FOREACH;

			IF iRecuperacion = 0 THEN
				IF pRegistros = 0 THEN
					LET cCodRet = '00017'; 
				ELIF pRegistros > 0 THEN
					LET cCodRet = '1001'; 
				END IF;
				RETURN cCodRet,cCLABE,cTipoCuenta,cNombreCliente,mImporte,mComision,dIVA,cEstadosPago,
			   cEstado,dFechaHoy,iNumTotalPagados,mImpTotalPagados,iNumTotalNoPagados,mImpTotalNoPagados,cTipoArchivo;
			END IF;
		END;
END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 04/06/2015',
'DESCRIPCION: SPL que realiza la consulta para obtener el detalle de pagos diarios afore.',
'AUTOR: Esparza Brenis Fernando Martín',
'FECHA: 28/09/2015',
'DESCRIPCION: Se modifica el SPL para que no regrese registros en blanco y se agrega paginado',
'FUNCIONALIDAD: Reportes de Pagos de Afore  Procesos AFORE', 
'MODULO: AFORE',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genreporteresumpagafore(pUsuario CHAR(8),pIdFuncion CHAR(10),pFechaConsulta DATE, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret, 
			DATE AS fecha_hoy,
			DATE AS fecha_pago,
			INTEGER AS num_operacion,
			DECIMAL(16, 2) AS comision,
			DECIMAL(16, 2) AS total_iva,
			DECIMAL(16, 2) AS total,
			CHAR(1) AS tipo_archivo;
		

		DEFINE cCodRet 			CHAR(5);
		DEFINE cCodRetSp        CHAR(6);
        DEFINE iSqlErr          INTEGER;
		DEFINE dFechaHoy        DATE;
		DEFINE dFechaPago       DATE;
		DEFINE iNumOperacion    INTEGER;
		DEFINE dComision        DECIMAL(16, 2); 
		DEFINE dTotalIva        DECIMAL(16, 2); 
		DEFINE dTotal           DECIMAL(16, 2); 
		DEFINE cTipoArchivo     CHAR(1);
		DEFINE iRecuperacion    INTEGER;
		
		LET cCodRet 		    = '00000';
		LET cCodRetSp           = '';
        LET iSqlErr             = 0;	
		LET dFechaHoy           = '';
		LET dFechaPago          = '';
		LET iNumOperacion       = 0;
		LET dComision           = 0.00; 
		LET dTotalIva           = 0.00; 
		LET dTotal              = 0.00; 
		LET cTipoArchivo        = '';
		LET iRecuperacion       = 0;
		
		BEGIN		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet, dFechaHoy, dFechaPago, iNumOperacion, dComision, dTotalIva, dTotal, cTipoArchivo;
			END EXCEPTION;
            
            -- SET DEBUG FILE TO '/tmp/mfinis/sp_genreporteresumpagafore.out';
            -- TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pFechaConsulta IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, dFechaHoy, dFechaPago, iNumOperacion, dComision, dTotalIva, dTotal, cTipoArchivo;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, dFechaHoy, dFechaPago, iNumOperacion, dComision, dTotalIva, dTotal, cTipoArchivo;
			END IF;
			
			FOREACH
				EXECUTE PROCEDURE bdiprog:"informix".sp_aforegenerarreporteresumpagproc2(pFechaConsulta, pRegistros, pRecuperacion) 
				INTO cCodRetSp, dFechaHoy, dFechaPago, iNumOperacion, dComision, dTotalIva, dTotal, cTipoArchivo
				
				IF cCodRetSp::INTEGER < 0 THEN
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdiprog:sp_aforegenerarreporteresumpagproc';
				ELIF cCodRetSp::INTEGER = 10015 THEN	
					LET cCodRet = '00003'; 
					RETURN cCodRet, dFechaHoy, dFechaPago, iNumOperacion, dComision, dTotalIva, dTotal, cTipoArchivo;
				ELSE
					IF dFechaPago IS NOT NULL THEN 
						LET iRecuperacion = iRecuperacion + 1;
						RETURN cCodRet, dFechaHoy, dFechaPago, iNumOperacion, dComision, dTotalIva, dTotal, cTipoArchivo WITH RESUME;
					END IF;
				END IF;
			END FOREACH;
			
			IF iRecuperacion = 0 THEN
				IF pRegistros = 0 THEN
					LET cCodRet = '00017'; 
				ELIF pRegistros > 0 THEN
					LET cCodRet = '1001'; 
				END IF;
				RETURN cCodRet, dFechaHoy, dFechaPago, iNumOperacion, dComision, dTotalIva, dTotal, cTipoArchivo;
			END IF;
		END;
END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat León Amador', 
'FECHA: 04/06/2015',
'DESCRIPCION: SPL que realiza la consulta para obtener el resumen de pagos mensuales, totalizados por día.',
'Mostrando así la cantidad de pagos que fueron procesados diariamente, el detalle diario de las comisiones a cobrar,',
'el iva total calculado en base al total de la comision en el mes y el total de comisión más iva en el mes.',
'AUTOR: Esparza Brenis Fernando Martín', 
'FECHA: 30/09/2015',
'DESCRIPCION: Se le agrega paginado.',
'FUNCIONALIDAD: Reportes de Pagos de Afore  Procesos AFORE', 
'MODULO: AFORE',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_grabaoperaciontef(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipo CHAR(1), pNumeroCtaOrd CHAR(20),
	pTipoCtaOrd CHAR(2), pFechaProg DATE, pCveRastreo CHAR(30), pNombreCteOrd CHAR(30), pRfcCteOrd CHAR(15), pImpTef CHAR(10),
	pComisionTef CHAR(5), pIvaTef CHAR(5), pImpTotTef CHAR(10), pTipoCtaBen CHAR(2), pNombreBen CHAR(30), pNumCtaTarjBen CHAR(20),
	pCveBancoRec CHAR(3), pRfcBen CHAR(15), pConceptoPago CHAR(50), pRefNum CHAR(7), pReferencia CHAR(40), pNumCuenta CHAR(20))
	
		RETURNING CHAR(5) AS codret,
			CHAR(5) AS codret_reversion;
		
		DEFINE cCodRet CHAR(5);
		DEFINE cCodRetOpTef CHAR(5);
		DEFINE cCodRetRev CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE cCodRetSp2 CHAR(5);
		DEFINE cDescCodRet CHAR(100);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
		DEFINE cFechaHoy CHAR(10);
		DEFINE cHoraFolio CHAR(10);
		DEFINE cFolioSucursal CHAR(16);
		DEFINE cEmpresa CHAR(3);
		DEFINE cSucursal CHAR(4);
		DEFINE cTipoOperacion CHAR(2);
		DEFINE cCveCanal CHAR(2);
		DEFINE cMotivoDev CHAR(2);
		DEFINE cDivisa CHAR(2);
		DEFINE cTransacSuc CHAR(4);
		DEFINE cNumeroCtaOrd CHAR(20);
		DEFINE cNumTarjeta CHAR(16);
		DEFINE iNoRegistros INTEGER;
		DEFINE bInTrans BOOLEAN;
		
		LET cCodRet = '00000';
		LET cCodRetOpTef = '00000';
		LET cCodRetRev = '00000';
        LET cCodRetSp = '';
		LET cCodRetSp2 = '';
		LET cDescCodRet = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;	
		LET cFechaHoy = '';
		LET cHoraFolio = '';
		LET cFolioSucursal = '';
		LET cEmpresa = '001';
		LET cSucursal = '9250';
		LET cTipoOperacion = '01';
		LET cCveCanal = '02';
		LET cMotivoDev = '00';
		LET cDivisa = '01';
		LET cTransacSuc = '0000';
		LET cNumeroCtaOrd = '';
		LET cNumTarjeta = ''; 
		LET iNoRegistros = 0;
		LET bInTrans = 'f';

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet,cCodRetRev;
			END EXCEPTION;
			
            -- SET DEBUG FILE TO '/tmp/mfinis/sp_grabaoperaciontef.out';
            -- TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pTipo = '' OR pNumeroCtaOrd = '' OR pTipoCtaOrd = '' OR pFechaProg IS NULL OR pCveRastreo = '' 
			OR pNombreCteOrd = '' OR pRfcCteOrd = '' OR pImpTef = '' OR pComisionTef = '' OR pIvaTef = '' OR pImpTotTef = '' OR pTipoCtaBen = '' 
			OR pNombreBen = '' OR pNumCtaTarjBen = '' OR pConceptoPago = '' OR pRefNum = '' OR pReferencia = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet,cCodRetRev;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet,cCodRetRev;
			END IF;
		 
			SET ISOLATION TO DIRTY READ;
			
			-- CONSULTA FECHA ACTUAL
			SELECT fecha_hoy INTO cFechaHoy FROM bdinvers:"informix".sv_fechas WHERE empresa = '001';	
			
			-- CONSULTA HORA
			LET cHoraFolio = TO_CHAR(CURRENT,'%H%M%S%F');
			IF NVL(cHoraFolio,'') = '' THEN
				LET cCodRet = '00573';
				RETURN cCodRet,cCodRetRev;
			ELSE
				LET cFolioSucursal = TRIM(pUsuario) || TRIM(cHoraFolio);
			END IF;
			
			IF pTipoCtaOrd = '40' THEN        --CUENTA
				LET cNumeroCtaOrd = pNumeroCtaOrd;
				LET cNumTarjeta = '';
			ELSE --pTipoCtaOrd = '03' THEN    --TARJETA
				LET cNumeroCtaOrd = pNumCuenta; 
				LET cNumTarjeta = pNumeroCtaOrd;
			END IF;
			
			
			BEGIN -- Bloque de la primera ejecuciÃ³n
				-- EJECUTA pTipo = '1'
				
				ON EXCEPTION IN (-255)
				END EXCEPTION WITH RESUME;
				
				ON EXCEPTION IN (-535)
					COMMIT WORK;
					LET bInTrans = 't';
					BEGIN WORK;
				END EXCEPTION WITH RESUME;
				
				BEGIN WORK;
					EXECUTE PROCEDURE bditef:"informix".sp_tef_grabaoperacion(pTipo,cEmpresa,cFechaHoy,cFolioSucursal,cSucursal,cNumeroCtaOrd,
						pTipoCtaOrd,pFechaProg,cTipoOperacion,pCveRastreo,TRIM(pNombreCteOrd),pRfcCteOrd,pImpTef,pComisionTef,pIvaTef,
						pImpTotTef,pTipoCtaBen,TRIM(pNombreBen),pNumCtaTarjBen,pCveBancoRec,pRfcBen,TRIM(pConceptoPago),pRefNum,
						TRIM(pReferencia),cCveCanal,cMotivoDev,cDivisa,cTransacSuc,cNumTarjeta,pUsuario)
					INTO cCodRetSp, cDescCodRet;
				COMMIT;
				
				IF bInTrans = 't' THEN
					BEGIN WORK;
				END IF;
				
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bditef:sp_tef_grabaoperacion';
				ELIF cCodRetSp::INTEGER = 1 THEN
					LET cCodRet = '00574'; 
				ELIF cCodRetSp::INTEGER = 2 THEN
					LET cCodRet = '00562';
				ELIF cCodRetSp::INTEGER = 3 THEN
					LET cCodRet = '00563'; 
				ELIF cCodRetSp::INTEGER = 4 THEN
					LET cCodRet = '00003'; 
				ELIF cCodRetSp::INTEGER = 5 THEN
					LET cCodRet = '00575'; 
				ELIF cCodRetSp::INTEGER = 6 THEN
					LET cCodRet = '00576'; 
				ELIF cCodRetSp::INTEGER = 11 THEN
					LET cCodRet = '00577'; 
				ELIF cCodRetSp::INTEGER = 13 THEN
					LET cCodRet = '00578'; 
				ELIF cCodRetSp::INTEGER = 100 THEN
					LET cCodRet = '00121';
				ELIF cCodRetSp::INTEGER = 106 THEN
					LET cCodRet = '00581'; 
				ELIF cCodRetSp::INTEGER = 110 THEN
					LET cCodRet = '00582'; 
				ELIF cCodRetSp::INTEGER = 200 THEN
					LET cCodRet = '00456'; 
				ELIF cCodRetSp::INTEGER = 211 THEN
					LET cCodRet = '00105'; 
				ELIF cCodRetSp::INTEGER = 300 THEN
					LET cCodRet = '00392'; 
				ELIF cCodRetSp::INTEGER = 400 THEN
					LET cCodRet = '00460'; 
				ELIF cCodRetSp::INTEGER = 420 THEN
					LET cCodRet = '00118'; 
				ELIF cCodRetSp::INTEGER = 500 THEN
					LET cCodRet = '00583'; 
				ELIF cCodRetSp::INTEGER = 520 THEN
					LET cCodRet = '00584';
				ELIF cCodRetSp::INTEGER = 549 THEN
					LET cCodRet = '00457'; 
				ELIF cCodRetSp::INTEGER = 550 THEN
					LET cCodRet = '00458'; 
				ELIF cCodRetSp::INTEGER = 560 THEN
					LET cCodRet = '00585';
				ELIF cCodRetSp::INTEGER = 600 THEN
					LET cCodRet = '00586'; 
				ELIF cCodRetSp::INTEGER = 700 THEN
					LET cCodRet = '00587';
				ELIF cCodRetSp::INTEGER = 701 THEN
					LET cCodRet = '00588'; 
				ELIF cCodRetSp::INTEGER = 702 THEN
					LET cCodRet = '00589'; 
				ELIF cCodRetSp::INTEGER = 703 THEN
					LET cCodRet = '00590'; 
				ELIF cCodRetSp::INTEGER = 704 THEN
					LET cCodRet = '00591';
				ELIF cCodRetSp::INTEGER = 705 THEN
					LET cCodRet = '00592'; 
				ELIF cCodRetSp::INTEGER = 777 THEN
					LET cCodRet = '00459'; 
				ELIF cCodRetSp::INTEGER = 951 THEN
					LET cCodRet = '00127'; 
				ELIF cCodRetSp::INTEGER = 957 THEN
					LET cCodRet = '00593'; 
				ELIF cCodRetSp::INTEGER = 962 THEN
					LET cCodRet = '00455'; 
				ELIF cCodRetSp::INTEGER = 999 THEN
					LET cCodRet = '00454'; 
				END IF;
				
				IF cCodRet <> '00000' THEN
					EXECUTE PROCEDURE bdicheq:"informix".reversion(cEmpresa,'9250',pUsuario,cFolioSucursal,'')
					INTO cCodRetSp;
					
					IF cCodRetSp::INTEGER < 0 THEN 
						RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicheq:reversion';
					ELIF cCodRetSp::INTEGER = 170 THEN
						LET cCodRetRev = '00112'; 
					ELIF cCodRetSp::INTEGER = 413 THEN
						LET cCodRetRev = '00113'; 
					ELIF cCodRetSp::INTEGER = 999 THEN
						LET cCodRetRev = '00454'; 
					END IF;
					
					RETURN cCodRet,cCodRetRev;
					
				END IF;
				
			END; -- Fin del primer bloque de ejecuciÃ³n
			
			BEGIN -- Bloque de la segundo ejecuciÃ³n
				-- EJECUTA pTipo = '1'
				
				ON EXCEPTION IN (-255)
				END EXCEPTION WITH RESUME;
				
				ON EXCEPTION IN (-535)
					COMMIT WORK;
					LET bInTrans = 't';
					BEGIN WORK;
				END EXCEPTION WITH RESUME;
				
				
				LET pTipo = 2;
				BEGIN WORK;
					EXECUTE PROCEDURE bditef:"informix".sp_tef_grabaoperacion(pTipo,cEmpresa,cFechaHoy,cFolioSucursal,cSucursal,cNumeroCtaOrd,
						pTipoCtaOrd,pFechaProg,cTipoOperacion,pCveRastreo,TRIM(pNombreCteOrd),pRfcCteOrd,pImpTef,pComisionTef,pIvaTef,
						pImpTotTef,pTipoCtaBen,TRIM(pNombreBen),pNumCtaTarjBen,pCveBancoRec,pRfcBen,TRIM(pConceptoPago),pRefNum,
						TRIM(pReferencia),cCveCanal,cMotivoDev,cDivisa,cTransacSuc,cNumTarjeta,pUsuario)
					INTO cCodRetSp, cDescCodRet;
				COMMIT;
				
				IF bInTrans = 't' THEN
					BEGIN WORK;
				END IF;
				
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bditef:sp_tef_grabaoperacion';
				ELIF cCodRetSp::INTEGER = 1 THEN
					LET cCodRet = '00574'; 
				ELIF cCodRetSp::INTEGER = 2 THEN
					LET cCodRet = '00562';
				ELIF cCodRetSp::INTEGER = 3 THEN
					LET cCodRet = '00563'; 
				ELIF cCodRetSp::INTEGER = 4 THEN
					LET cCodRet = '00003'; 
				ELIF cCodRetSp::INTEGER = 5 THEN
					LET cCodRet = '00575'; 
				ELIF cCodRetSp::INTEGER = 6 THEN
					LET cCodRet = '00576'; 
				ELIF cCodRetSp::INTEGER = 11 THEN
					LET cCodRet = '00577'; 
				ELIF cCodRetSp::INTEGER = 13 THEN
					LET cCodRet = '00578'; 
				ELIF cCodRetSp::INTEGER = 100 THEN
					LET cCodRet = '00121';
				ELIF cCodRetSp::INTEGER = 106 THEN
					LET cCodRet = '00581'; 
				ELIF cCodRetSp::INTEGER = 110 THEN
					LET cCodRet = '00582'; 
				ELIF cCodRetSp::INTEGER = 200 THEN
					LET cCodRet = '00456'; 
				ELIF cCodRetSp::INTEGER = 211 THEN
					LET cCodRet = '00105'; 
				ELIF cCodRetSp::INTEGER = 300 THEN
					LET cCodRet = '00392'; 
				ELIF cCodRetSp::INTEGER = 400 THEN
					LET cCodRet = '00460'; 
				ELIF cCodRetSp::INTEGER = 420 THEN
					LET cCodRet = '00118'; 
				ELIF cCodRetSp::INTEGER = 500 THEN
					LET cCodRet = '00583'; 
				ELIF cCodRetSp::INTEGER = 520 THEN
					LET cCodRet = '00584';
				ELIF cCodRetSp::INTEGER = 549 THEN
					LET cCodRet = '00457'; 
				ELIF cCodRetSp::INTEGER = 550 THEN
					LET cCodRet = '00458'; 
				ELIF cCodRetSp::INTEGER = 560 THEN
					LET cCodRet = '00585';
				ELIF cCodRetSp::INTEGER = 600 THEN
					LET cCodRet = '00586'; 
				ELIF cCodRetSp::INTEGER = 700 THEN
					LET cCodRet = '00587';
				ELIF cCodRetSp::INTEGER = 701 THEN
					LET cCodRet = '00588'; 
				ELIF cCodRetSp::INTEGER = 702 THEN
					LET cCodRet = '00589'; 
				ELIF cCodRetSp::INTEGER = 703 THEN
					LET cCodRet = '00590'; 
				ELIF cCodRetSp::INTEGER = 704 THEN
					LET cCodRet = '00591';
				ELIF cCodRetSp::INTEGER = 705 THEN
					LET cCodRet = '00592'; 
				ELIF cCodRetSp::INTEGER = 777 THEN
					LET cCodRet = '00459'; 
				ELIF cCodRetSp::INTEGER = 951 THEN
					LET cCodRet = '00127'; 
				ELIF cCodRetSp::INTEGER = 957 THEN
					LET cCodRet = '00593'; 
				ELIF cCodRetSp::INTEGER = 962 THEN
					LET cCodRet = '00455'; 
				ELIF cCodRetSp::INTEGER = 999 THEN
					LET cCodRet = '00454'; 
				END IF;
				
				IF cCodRet <> '00000' THEN
					EXECUTE PROCEDURE bdicheq:"informix".reversion(cEmpresa,'9250',pUsuario,cFolioSucursal,'')
					INTO cCodRetSp;
					
					IF cCodRetSp::INTEGER < 0 THEN 
						RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicheq:reversion';
					ELIF cCodRetSp::INTEGER = 170 THEN
						LET cCodRetRev = '00112'; 
					ELIF cCodRetSp::INTEGER = 413 THEN
						LET cCodRetRev = '00113'; 
					ELIF cCodRetSp::INTEGER = 999 THEN
						LET cCodRetRev = '00454'; 
					END IF;
					
					RETURN cCodRet,cCodRetRev;
				ELSE
					LET iNoRegistros = iNoRegistros + 1;
				END IF;

			END; -- Fin del segundo bloque de ejecuciÃ³n

			IF iNoRegistros = 0 THEN
				LET cCodRet = '00236'; --'ERROR AL PROCESAR LA SOLICITUD'
			END IF;	
			
			RETURN cCodRet,cCodRetRev;	
			
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 04/08/2015',
'DESCRIPCION: SPL que se encarga de realizar el alta de operaciones TEF en central.',
'FUNCIONALIDAD: Captura de Operaciones TEF', 
'MODULO: TEF',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_obtienecverastreotef(pUsuario CHAR(8), pIdFuncion CHAR(10))	
		RETURNING CHAR(5) AS codret,          
			CHAR(30) AS clave_rastreo;
		
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE cCodRetSp2 CHAR(5);
		DEFINE cDescCodRet CHAR(100);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;	
		DEFINE cEmpresa CHAR(3);
		DEFINE cCveRastreo CHAR(30);		
		DEFINE iNoRegistros INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET cCodRetSp2 = '';
		LET cDescCodRet = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;	
		LET cEmpresa = '001';
		LET cCveRastreo = '';
		LET iNoRegistros = 0;

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet, cCveRastreo;
			END EXCEPTION;
            
            -- SET DEBUG FILE TO '/tmp/mfinis/sp_obtienecverastreotef.out';
            -- TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cCveRastreo;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, cCveRastreo;
			END IF;
		 
			SET ISOLATION TO DIRTY READ;
			
			EXECUTE PROCEDURE bditef:"informix".sp_obtienecveratreo('9250',pUsuario)
			INTO cCodRetSp, cCveRastreo;
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bditef:sp_obtienecveratreo';
			ELIF cCodRetSp::INTEGER = 3 THEN
				LET cCodRet = '00003'; 
				RETURN cCodRet, cCveRastreo;
			ELIF cCodRetSp::INTEGER = 4 THEN
				LET cCodRet = '00572'; --EL NÃMERO CONSECUTIVO TEF ESTÃ VACÃO
				RETURN cCodRet, cCveRastreo;
			END IF;

			IF cCodRetSp::INTEGER = 0 THEN	
				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet, UPPER(cCveRastreo);
			END IF;
			
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00579'; --NO FUE POSIBLE OBTENER LA CLAVE DE RASTREO, VERIFIQUE
				RETURN cCodRet, cCveRastreo;		
			END IF;
			
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 31/07/2015',
'DESCRIPCION: SPL que se encarga de obtener la clave de rastreo para las operaciones TEF.',
'FUNCIONALIDAD: Captura de Operaciones TEF', 
'MODULO: TEF',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_totalesarchivosprocesarafore(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoBusqueda CHAR(1),
		pTipoArchivo CHAR(1), pNombreArchivo CHAR(30), pFechaInicial DATE, pFechaFinal DATE, pEstatus CHAR(2))
					
		RETURNING CHAR(5) AS codret,  
			INTEGER AS totalRegistros; 		  
			
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
		DEFINE cEmpresa CHAR(3);
		DEFINE iTotalRegistros INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		LET cEmpresa = '001';
		LET iTotalRegistros = 0;

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet, iTotalRegistros; 
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_totalesarchivosprocesarafore.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pTipoBusqueda = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iTotalRegistros; 
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, iTotalRegistros;  
			END IF;
				
			-- VALIDA TIPO DE BUSQUEDA
			IF pTipoBusqueda = '1' THEN
			
				LET pTipoArchivo = 'P';
				LET pNombreArchivo = '';
				LET pFechaInicial = DATE(CURRENT);
				LET pFechaFinal = DATE(CURRENT);
				LET pEstatus = '19';
				
			ELIF pTipoBusqueda = '2' THEN	
				
				IF NVL(pFechaInicial, '') = '' AND NVL(pFechaFinal, '') = '' THEN
					LET pFechaInicial = MDY(1,1,1900);
					LET pFechaFinal = MDY(1,1,1900);
                END IF
			
			END IF;
			
			FOREACH
				EXECUTE PROCEDURE bdiprog:"informix".sp_aforebuscararchivosprocesar2_totales(pTipoArchivo,pNombreArchivo,pFechaInicial,pFechaFinal,pEstatus) 
				INTO cCodRetSp,iTotalRegistros				 
					 
				IF cCodRetSp::INTEGER < 0 THEN
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdiprog:sp_aforebuscararchivosprocesar2_totales';
				END IF;
			END FOREACH;
				
			IF iTotalRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iTotalRegistros;
			ELSE
				RETURN cCodRet, iTotalRegistros;
			END IF;	

		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 10/06/2015',
'DESCRIPCION: SPL que obtiene el numero total de archivos (de pago, confirmaciÃ³n y/o cifras de control) enviados por afore coppel.', 
'FUNCIONALIDAD: EjecuciÃ³n de Pagos Pendientes â Procesos AFORE', 
'MODULO: AFORE',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_totalesconsultarchivosafore(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(30))
			
		RETURNING CHAR(5) AS codret,  
			INTEGER AS totalRegistros; 
			
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
		DEFINE cEmpresa CHAR(3);
		DEFINE pTipoArchivo CHAR(1);
		DEFINE iTotalRegistros INTEGER;
		
		DEFINE cTipoRegistro                       CHAR(1); 	
		DEFINE cNoContratoEmpresaTmp               CHAR(10);	  
		DEFINE dFechaGenTmp                        DATE; 		  
		DEFINE dFechaInicialInformacionTmp         DATE; 		  
		DEFINE dFechaFinalInformacionTmp           DATE; 		  
		DEFINE cNoMovimientosContenidosTmp         CHAR(9); 	  
		DEFINE cFiller                             CHAR(232);	  
		DEFINE cFinLinea                           CHAR(2);   	  
		DEFINE cNSS                                CHAR(11); 	  
		DEFINE cNombreBeneficiario                 CHAR(40); 	  
		DEFINE cApellidoPaternoBeneficiario        CHAR(40); 	  
		DEFINE cApellidoMaternoBeneficiario        CHAR(40); 	  
		DEFINE cFormasPago                         CHAR(1); 	  
		DEFINE cCLABE                              CHAR(18); 	  
		DEFINE dFechaCaptura                       DATE; 	  
		DEFINE cImporteDocumentoNetoPagar          CHAR(15); 	  
		DEFINE cImporteDocumentoAntesImpuesto      CHAR(15); 	  
		DEFINE cImpuestoRetenido                   CHAR(11); 	  
		DEFINE cNumeroFolioServicio                CHAR(8); 	  
		DEFINE cNumeroTienda                       CHAR(4); 	  
		DEFINE cTipoRetiro                         CHAR(3); 	  
		DEFINE cConsecutivoRetiro                  CHAR(10); 	  
		DEFINE cCURP                               CHAR(18); 	  
		DEFINE cRFC                                CHAR(10); 	  
		DEFINE cFolio_suc                          CHAR(16); 	  
		DEFINE cNumeroTotalMovimientosContenidos   CHAR(2); 	  	
		DEFINE cImporteTotalNeto                   CHAR(17); 	  
		DEFINE cImporteTotalAntesImpuesto          CHAR(17); 	  
		DEFINE cImporteRetenido                    CHAR(17); 	  
		DEFINE cImporteTotalRetirosPagadosEfectivo CHAR(17); 	  
		DEFINE cImporteTotalRetirosPagadosDeposito CHAR(17); 	  
		DEFINE dFechaMovimientos                   DATE; 	  
		DEFINE cEstatus                            CHAR(2); 	  
		DEFINE iSumaMov                            INTEGER; 	  
		DEFINE mMonto                              MONEY(10,2);   
		DEFINE mSumaMonto                          MONEY(12,2);  
		DEFINE iNoRegistros 					   INTEGER;	
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		LET cEmpresa = '001';
		LET pTipoArchivo = '';
		LET iTotalRegistros = 0;
		
		LET cTipoRegistro                          = '';	
		LET cNoContratoEmpresaTmp                  = '';	  
		LET dFechaGenTmp                           = ''; 		  
		LET dFechaInicialInformacionTmp            = ''; 		  
		LET dFechaFinalInformacionTmp              = ''; 		  
		LET cNoMovimientosContenidosTmp            = '';	  
		LET cFiller                                = '';	  
		LET cFinLinea                              = ''; 	  
		LET cNSS                                   = '';	  
		LET cNombreBeneficiario                    = '';	  
		LET cApellidoPaternoBeneficiario           = '';	  
		LET cApellidoMaternoBeneficiario           = '';	  
		LET cFormasPago                            = '';	  
		LET cCLABE                                 = '';	  
		LET dFechaCaptura                          = ''; 	  
		LET cImporteDocumentoNetoPagar             = ''; 	  
		LET cImporteDocumentoAntesImpuesto         = ''; 	  
		LET cImpuestoRetenido                      = ''; 	  
		LET cNumeroFolioServicio                   = '';	  
		LET cNumeroTienda                          = '';	  
		LET cTipoRetiro                            = '';	  
		LET cConsecutivoRetiro                     = ''; 	  
		LET cCURP                                  = ''; 	  
		LET cRFC                                   = ''; 	  
		LET cFolio_suc                             = ''; 	  
		LET cNumeroTotalMovimientosContenidos      = '';	  	
		LET cImporteTotalNeto                      = ''; 	  
		LET cImporteTotalAntesImpuesto             = ''; 	  
		LET cImporteRetenido                       = ''; 	  
		LET cImporteTotalRetirosPagadosEfectivo    = ''; 	  
		LET cImporteTotalRetirosPagadosDeposito    = ''; 	  
		LET dFechaMovimientos                      = ''; 	  
		LET cEstatus                               = ''; 	  
		LET iSumaMov                               = 0; 	  
		LET mMonto                                 = '';  
		LET mSumaMonto                             = '';  
		LET iNoRegistros                           = 0;
		
		
		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet, iTotalRegistros; 
			END EXCEPTION;
            
			ON EXCEPTION IN (-206)
			END EXCEPTION WITH RESUME;
		
            --SET DEBUG FILE TO '/tmp/mfinis/sp_totalesconsultarchivosafore.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pNombreArchivo = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iTotalRegistros; 
            END IF;
			
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, iTotalRegistros; 
			END IF;
			
			-- VALIDA NOMENCLATURA			
			IF SUBSTRING(pNombreArchivo FROM 15 FOR 2) = 'OB' OR SUBSTRING(pNombreArchivo FROM 5 FOR 2) = 'OB' THEN 
				LET pTipoArchivo = '2';
			ELSE 
				LET pTipoArchivo = '1';
			END IF;
			
			SET LOCK MODE TO WAIT 3; 
		 
				FOREACH
				
					EXECUTE PROCEDURE bdiprog:"informix".sp_aforeconsultaarchivos(pNombreArchivo, pTipoArchivo) 
					INTO cCodRetSp, cTipoRegistro, cNoContratoEmpresaTmp, dFechaGenTmp, dFechaInicialInformacionTmp, dFechaFinalInformacionTmp, 
					cNoMovimientosContenidosTmp, cFiller, cFinLinea, cNSS, cNombreBeneficiario, cApellidoPaternoBeneficiario, 
					cApellidoMaternoBeneficiario, cFormasPago, cCLABE, dFechaCaptura, cImporteDocumentoNetoPagar, 
					cImporteDocumentoAntesImpuesto, cImpuestoRetenido, cNumeroFolioServicio, cNumeroTienda, cTipoRetiro, 
					cConsecutivoRetiro, cCURP, cRFC, cFolio_suc, cNumeroTotalMovimientosContenidos, cImporteTotalNeto, 
					cImporteTotalAntesImpuesto, cImporteRetenido, cImporteTotalRetirosPagadosEfectivo, 
					cImporteTotalRetirosPagadosDeposito, dFechaMovimientos, cEstatus, iSumaMov, mMonto, mSumaMonto
					
					IF cCodRetSp::INTEGER < 0 THEN
						RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdiprog:sp_aforeconsultaarchivos';					 
					ELIF cCodRetSp::INTEGER = 10000 THEN	
						LET cCodRet = '00481'; 
						RETURN cCodRet, iTotalRegistros;
					END IF;
					
					IF DBINFO('sqlca.sqlerrd2') = 1 THEN
						LET iNoRegistros = iNoRegistros + 1;
					END IF;
					
				END FOREACH;
			
			LET iTotalRegistros = iNoRegistros - 2;
			
			IF iTotalRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iTotalRegistros;
			ELSE 
				RETURN cCodRet, iTotalRegistros;
			END IF;	
			
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 03/06/2015',
'DESCRIPCION: SPL que obtiene el nÃºmero total de archivos de pagos, confirmacion y control Afore.',
'FUNCIONALIDAD: Consulta de Archivos - Proceso AFORE', 
'MODULO: AFORE',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 22/10/2015',
'DESCRIPCION: Se hizo la modificaciÃ³n al calculo del nÃºmero total de registros, ya que 2 de los registros a retornar,',
'corresponden: el primero al encabezado y el Ãºltimo al sumario.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_validaarchcod60tef(pUsuario CHAR(8), pIdFuncion CHAR(10))	
		RETURNING CHAR(5) AS codret,
			CHAR(1) AS cTipo_Proc,
			CHAR(10) AS cFecha_Proc,
			CHAR(20) AS cClave_Proc,
			CHAR(60) AS cDescripcion_Proc,
			CHAR(1) AS  cEstatus_Proc;
			
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE cDescCodRet CHAR(100);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;	
		DEFINE cTipoProceso CHAR(1); 
		DEFINE dFechaProceso CHAR(10);
		DEFINE cClaveProceso CHAR(20);
		DEFINE cDescripcion CHAR(60);
		DEFINE cEstatus CHAR(1);
		DEFINE iNoRegistros INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET cDescCodRet = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;	
		LET cTipoProceso = '';
		LET dFechaProceso = '';
		LET cClaveProceso = '';
		LET cDescripcion = '';
		LET cEstatus = '';
		LET iNoRegistros = 0;
		

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet, cTipoProceso, dFechaProceso, cClaveProceso, cDescripcion, cEstatus;
			END EXCEPTION;
            
            -- SET DEBUG FILE TO '/tmp/mfinis/sp_validaarchcod60tef.out';
            -- TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cTipoProceso, dFechaProceso, cClaveProceso, cDescripcion, cEstatus;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, cTipoProceso, dFechaProceso, cClaveProceso, cDescripcion, cEstatus; 
			END IF;
			
			SET ISOLATION TO DIRTY READ;
			
			-- VALIDA ARCHIVO 60
			FOREACH
				EXECUTE PROCEDURE bditef:"informix".sp_tef_validarchcod60('','GENARCH_60.01')
				INTO cCodRetSp, cTipoProceso, dFechaProceso, cClaveProceso, cDescripcion, cEstatus
				
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bditef:sp_tef_validarchcod60';
				ELIF cCodRetSp::INTEGER = 1	THEN
					LET cCodRet = '00335'; --'SOLAMENTE DEBE ENVIAR UN SOLO PARAMETRO'
					RETURN cCodRet, cTipoProceso, dFechaProceso, cClaveProceso, cDescripcion, cEstatus;
				ELIF cCodRetSp::INTEGER = 2	THEN
					LET cCodRet = '00563'; --NO ES POSIBLE REGISTRAR LA OPERACIÃN TEF, EL PROCESO DE GENERACIÃN DE ARCHIVOS YA HA INICIADO
					RETURN cCodRet, cTipoProceso, dFechaProceso, cClaveProceso, cDescripcion, cEstatus;
				END IF;
				
				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet, UPPER(cTipoProceso), dFechaProceso, UPPER(cClaveProceso), UPPER(cDescripcion), cEstatus WITH RESUME;
			END FOREACH;
			
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cTipoProceso, dFechaProceso, cClaveProceso, cDescripcion, cEstatus;
			END IF;
			
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 29/07/2015',
'DESCRIPCION: SPL que valida si ya inicio o no la generaciÃ³n del Archivo CÃ³digo 60 TEF.',
'FUNCIONALIDAD: Captura de Operaciones TEF', 
'MODULO: TEF',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_validactabeneficiariotef(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoCuenta CHAR(2), pNumCuenta CHAR(20))	
		RETURNING CHAR(5) AS codret,          
			CHAR(3) AS clave_banco,  
			CHAR(1) AS digito_verificador;
		
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE cCodRetSp2 CHAR(5);
		DEFINE cDescCodRet CHAR(100);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;	
		DEFINE cEmpresa CHAR(3);
		DEFINE iTipo INTEGER;
		DEFINE cTarjeta CHAR(20);
		DEFINE cClaveBanco CHAR(3);
		DEFINE cCtaClabe CHAR(20);
		DEFINE cDigito CHAR(1);
		DEFINE cDigVerificador CHAR(1);
		DEFINE iNoRegistros INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET cCodRetSp2 = '';
		LET cDescCodRet = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;	
		LET cEmpresa = '001';
		LET iTipo = 0;
		LET cTarjeta = '';
		LET cClaveBanco = '';
		LET cCtaClabe = '';
		LET cDigito = '';
		LET cDigVerificador = '';
		LET iNoRegistros = 0;

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet, cClaveBanco, cDigito;
			END EXCEPTION;
            
            -- SET DEBUG FILE TO '/tmp/mfinis/sp_validactabeneficiariotef.out';
            -- TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pTipoCuenta = '' OR pNumCuenta = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cClaveBanco, cDigito;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, cClaveBanco, cDigito;
			END IF;
		 
			IF pTipoCuenta = '40' THEN
				LET iTipo = 3;
			ELIF pTipoCuenta = '03' THEN
				LET iTipo = 2;
			ELIF pTipoCuenta = '11' OR pTipoCuenta = '12' OR pTipoCuenta = '13' THEN
				LET iTipo = 1;
			END IF;	
		
			SET ISOLATION TO DIRTY READ;
			
			IF pTipoCuenta = '03' THEN
				
				LET cTarjeta = SUBSTRING (TRIM(pNumCuenta) FROM 1 FOR 6);
				
				-- VALIDA BIN
				EXECUTE PROCEDURE bditef:"informix".sp_obtbines_sif(cTarjeta)
				INTO cCodRetSp, cDescCodRet, cClaveBanco;
			
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bditef:sp_obtbines_sif';
				ELIF cCodRetSp::INTEGER = 1 THEN
					LET cCodRet = '00003'; 
					RETURN cCodRet, cClaveBanco, cDigito;
				ELIF cCodRetSp::INTEGER = 2 THEN
					LET cCodRet = '00569'; --TARJETA INVALIDA, VERIFIQUE
					RETURN cCodRet, cClaveBanco, cDigito;
				ELIF cCodRetSp::INTEGER = 3 THEN
					LET cCodRet = '00526'; 
					RETURN cCodRet, cClaveBanco, cDigito;
				ELIF cCodRetSp::INTEGER = 4 THEN
					LET cCodRet = '00570'; --El BIN NO PERTENECE A LA TARJETA DE DÃBITO, VERIFIQUE
					RETURN cCodRet, cClaveBanco, cDigito;
				END IF;
			
			ELIF pTipoCuenta = '40' THEN
				
				LET cCtaClabe = SUBSTRING (TRIM(pNumCuenta) FROM 1 FOR 17);
				LET cDigVerificador = SUBSTRING (TRIM(pNumCuenta) FROM 17 FOR 1);
				
				-- VALIDA DÃGITO
				EXECUTE PROCEDURE bdicheq:"informix".digverclabe(cCtaClabe)
				INTO cCodRetSp, cDigito;
			
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicheq:digverclabe';
				END IF;
				
				IF NVL(cDigito,'') <> NVL(cDigVerificador,'') OR (NVL(cDigito,'') = '' OR NVL(cDigVerificador,'') = '') THEN 
					LET cCodRet = '00240'; 
					RETURN cCodRet, cClaveBanco, cDigito;
				END IF;
				
			END IF;
			
			IF cCodRetSp::INTEGER = 0 THEN 
			
				-- VALIDA RECEPCIÃN
				EXECUTE PROCEDURE bditef:"informix".sp_tef_validarecepcion(iTipo,pNumCuenta)
				INTO cCodRetSp, cDescCodRet;
				
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bditef:sp_tef_validarecepcion';
				ELIF cCodRetSp::INTEGER = 1 THEN
					LET cCodRet = '00003'; 
					RETURN cCodRet, cClaveBanco, cDigito;
				ELIF cCodRetSp::INTEGER = 2 THEN
					LET cCodRet = '00431'; 
					RETURN cCodRet, cClaveBanco, cDigito;
				ELIF cCodRetSp::INTEGER = 3 THEN
					LET cCodRet = '00571'; --TRANSFERENCIAS BANCOPPEL NO OPERAN TEF, VERIFIQUE
					RETURN cCodRet, cClaveBanco, cDigito;
				END IF;
				
				IF cCodRetSp::INTEGER = 0 THEN 
					LET iNoRegistros = iNoRegistros + 1;
					RETURN cCodRet, cClaveBanco, cDigito;
				END IF;
				
			END IF;
			
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cClaveBanco, cDigito;			
			END IF;
			
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 03/08/2015',
'DESCRIPCION: SPL que se encarga de validar que la cuenta sea valida para la recepcion de operaciones TEF en central.',
'Y dependiendo del tipo de cuenta realiza las siguientes validaciones:',
'Si pTipoCuenta = 03, valida el bin de la tarjeta y obtiene la clave del banco.',
'Si pTipoCuenta = 40, valida que el dÃ­gito verificador sea correcto.',
'FUNCIONALIDAD: Captura de Operaciones TEF', 
'MODULO: TEF',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_validahrfechaprocaptef(pUsuario CHAR(8), pIdFuncion CHAR(10))
					
		RETURNING CHAR(5) AS codret;
			
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE cCodRetSp2 CHAR(5);
		DEFINE cDescCodRet CHAR(100);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;	
		DEFINE cFechaHoy CHAR(10);
		DEFINE cHora CHAR(10);
		DEFINE iNoRegistros INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET cCodRetSp2 = '';
		LET cDescCodRet = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;	
		LET cFechaHoy = '';
		LET cHora = '';
		LET iNoRegistros = 0;
		

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END EXCEPTION;
            
            -- SET DEBUG FILE TO '/tmp/mfinis/sp_validahrfechaprocaptef.out';
            -- TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet; 
			END IF;
			
			-- CONSULTA FECHA ACTUAL
			SELECT fecha_hoy INTO cFechaHoy FROM bdinvers:"informix".sv_fechas WHERE empresa = '001';	
		 
			SET ISOLATION TO DIRTY READ;
			
			-- VALIDA DÃA HÃBIL
			EXECUTE PROCEDURE bditef:"informix".sp_validadiahabiltef(cFechaHoy)
			INTO cCodRetSp,cCodRetSp2;
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bditef:sp_validadiahabiltef';
			ELIF cCodRetSp2::INTEGER = 1	THEN
				LET cCodRet = '00003';
				RETURN cCodRet;
			ELIF cCodRetSp2::INTEGER = 2	THEN
				LET cCodRet = '00561'; --NO ES POSIBLE REGISTRAR LA OPERACIÃN TEF, DÃA INVÃLIDO
				RETURN cCodRet;
			END IF;

			IF cCodRetSp::INTEGER = 0 AND cCodRetSp2::INTEGER = 0 THEN
				
				LET cHora = TO_CHAR(CURRENT,'%H:%m');
				
				-- VALIDA HORARÃO
				EXECUTE PROCEDURE bditef:"informix".sp_tef_validahorario(cHora)
				INTO cCodRetSp, cDescCodRet;
				
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bditef:sp_tef_validahorario';
				ELIF cCodRetSp::INTEGER = 1	THEN
					LET cCodRet = '00562'; --NO ES POSIBLE REGISTRAR LA OPERACIÃN TEF, EL HORARIO EXCEDE DEL TIEMPO MÃXIMO ESTABLECIDO
					RETURN cCodRet;
				END IF;
				
				IF cCodRetSp::INTEGER = 0 THEN
					LET iNoRegistros = iNoRegistros + 1;
				END IF;
				
			END IF;
			
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet;
			ELSE	
				RETURN cCodRet;
			END IF;
			
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 29/07/2015',
'DESCRIPCION: SPL que verificar si la fecha de ejecuciÃ³n corresponde a un dÃ­a hÃ¡bil bancario y',
'si la hora de ejecuciÃ³n se encuentra dentro del horario permitido para poder realizar las operaciones TEF en central.',
'FUNCIONALIDAD: Captura de Operaciones TEF', 
'MODULO: TEF',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_validaproductotef(pUsuario CHAR(8), pIdFuncion CHAR(10), pProducto CHAR(4), pNumCliente CHAR(9))	
		RETURNING CHAR(5) AS codret,          
			DECIMAL(6,2) AS imp_comision,              
		    CHAR(13) AS rfc,
			CHAR(50) AS descripcion_iva,
			CHAR(100) AS valor_iva;
		
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE cCodRetSp2 CHAR(5);
		DEFINE cDescCodRet CHAR(100);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;	
		DEFINE cEmpresa CHAR(3);
		DEFINE dImpComision DECIMAL(6,2);
		DEFINE cRFC CHAR(13);
		DEFINE cDescripcionIva CHAR(50);
		DEFINE cValorIva CHAR(100);		
		DEFINE iNoRegistros INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET cCodRetSp2 = '';
		LET cDescCodRet = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;	
		LET cEmpresa = '001';
		LET dImpComision = 0.00;
		LET cRFC = '';
		LET cDescripcionIva = '';
		LET cValorIva = '';
		LET iNoRegistros = 0;

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet, dImpComision, cRFC, cDescripcionIva, cValorIva;
			END EXCEPTION;
            
            -- SET DEBUG FILE TO '/tmp/mfinis/sp_validaproductotef.out';
            -- TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pProducto = '' OR pNumCliente = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, dImpComision, cRFC, cDescripcionIva, cValorIva;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, dImpComision, cRFC, cDescripcionIva, cValorIva;
			END IF;
		 
			SET ISOLATION TO DIRTY READ;
			
			EXECUTE PROCEDURE bditef:"informix".sp_validaproductopermitido(pProducto,pNumCliente)
			INTO cCodRetSp, dImpComision, cRFC;
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bditef:sp_validaproductopermitido';
			ELIF cCodRetSp::INTEGER = 1 THEN
				LET cCodRet = '00003'; 
				RETURN cCodRet, dImpComision, cRFC, cDescripcionIva, cValorIva;
			ELIF cCodRetSp::INTEGER = 2 THEN
				LET cCodRet = '00568'; --NO ES PRODUCTO PERMITIDO, VERIFIQUE
				RETURN cCodRet, dImpComision, cRFC, cDescripcionIva, cValorIva;
			END IF;

			IF cCodRetSp::INTEGER = 0 THEN				
				
				-- CONSULTA VALOR IVA
				FOREACH
					EXECUTE PROCEDURE bdinteg:"informix".sp_obtenerparametros(47,'001')
					INTO cDescripcionIva, cValorIva
					
					IF cCodRetSp::INTEGER < 0 THEN 
						RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdinteg:sp_obtenerparametros';
					ELIF cCodRetSp::INTEGER = 0 THEN					
						LET iNoRegistros = iNoRegistros + 1;
						RETURN cCodRet, NVL(dImpComision,0), UPPER(cRFC), UPPER(cDescripcionIva), NVL(cValorIva,'') WITH RESUME;
					END IF; 
					
				END FOREACH
				
			END IF;
			
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, dImpComision, cRFC, cDescripcionIva, cValorIva;				
			END IF;
			
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 31/07/2015',
'DESCRIPCION: SPL que se encarga de validar si el producto es permitido, y si cobra comision.',
'Regresa la cantidad cobrada, el RFC del cliente, y el valor de IVA.',
'FUNCIONALIDAD: Captura de Operaciones TEF', 
'MODULO: TEF',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_validarcargarchivoafore(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(30))
		RETURNING CHAR(5) AS codret;
		
		DEFINE cCodRet CHAR(5);
		DEFINE cCodRetSp CHAR(6);
        DEFINE iSqlErr INTEGER;	
		DEFINE cHoraProceso CHAR(21);
		DEFINE cHoraServidor CHAR(21);
		DEFINE pTipoArchivo CHAR(1);
		DEFINE cMensajeRet CHAR(200);
		DEFINE iRecuperacion INTEGER;
		
		LET cCodRet = '00000';
		LET cCodRetSp = '';
        LET iSqlErr = 0;	
		LET cHoraProceso = '';
		LET cHoraServidor = '';
		LET pTipoArchivo = '';
		LET cMensajeRet = '';
		LET iRecuperacion = 0;

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END EXCEPTION;
			
            -- SET DEBUG FILE TO '/tmp/mfinis/sp_validarcargarchivoafore.out';
            -- TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pNombreArchivo = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet;
			END IF;
			
			-- CONSULTA El LIMITE DE HORARIO PERMITIDO
			SELECT valor INTO cHoraProceso FROM bdisac:"informix".sac_param WHERE cod_param = '6036';
			IF cHoraProceso = '' OR cHoraProceso IS NULL THEN
				LET cCodRet = '00515'; --NO SE PUDO OBTENER LA HORA DEL SERVIDOR
				RETURN cCodRet;
			END IF;
			
			-- CONSULTA LA HR DEL SERVIDOR
			EXECUTE PROCEDURE bdiprog:"informix".sp_validahoraejec('001') INTO cCodRetSp, cHoraServidor;
			IF cCodRetSp::INTEGER < 0 THEN
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdiprog:sp_validahoraejec';
			ELIF cCodRetSp::INTEGER > 0 THEN
				LET cCodRet = '00515'; --NO SE PUDO OBTENER LA HORA DEL SERVIDOR
				RETURN cCodRet;
			END IF;
			
			-- VALIDA NOMENCLATURA
			IF SUBSTRING(pNombreArchivo FROM 15 FOR 2) = 'OB' THEN 
				IF (cHoraServidor > cHoraProceso) THEN
					LET cCodRet = '00434';
					RETURN cCodRet;
				ELSE
					LET pTipoArchivo = '2';
				END IF;
			ELSE 
				LET pTipoArchivo = '1';
			END IF;
		 
			-- GENERA EL LLAMADO AL PROCESO DE RECEPCION DE ARCHIVOS
			EXECUTE PROCEDURE bdiprog:"informix".sp_aforevalidacargaarchivo(pNombreArchivo, pUsuario, pTipoArchivo) 
			INTO cCodRetSp, cMensajeRet;
			
			IF cCodRetSp::INTEGER < 0 THEN
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdiprog:sp_aforevalidacargaarchivo';
			ELIF cCodRetSp::INTEGER = 10000 THEN	
				LET cCodRet = '00481'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10001 THEN	
				LET cCodRet = '00482'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10002 THEN	
				LET cCodRet = '00483'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10003 THEN	
				LET cCodRet = '00484'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10004 THEN	
				LET cCodRet = '00485'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10005 THEN	
				LET cCodRet = '00486'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10006 THEN	
				LET cCodRet = '00487';
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10007 THEN	
				LET cCodRet = '00488';
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10008 THEN	
				LET cCodRet = '00489'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10009 THEN	
				LET cCodRet = '00490'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10010 THEN	
				LET cCodRet = '00491';
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10011 THEN	
				LET cCodRet = '00492'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10012 THEN	
				LET cCodRet = '00493'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10013 THEN	
				LET cCodRet = '00494';
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10014 THEN	
				LET cCodRet = '00438'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10015 THEN	
				LET cCodRet = '00495';
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10016 THEN	
				LET cCodRet = '00496'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10017 THEN	
				LET cCodRet = '00497';
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10018 THEN	
				LET cCodRet = '00498'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10019 THEN	
				LET cCodRet = '00499';
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10020 THEN	
				LET cCodRet = '00500'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10021 THEN	
				LET cCodRet = '00501'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10022 THEN	
				LET cCodRet = '00496'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10023 THEN	
				LET cCodRet = '00502'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10024 THEN	
				LET cCodRet = '00503';
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10025 THEN	
				LET cCodRet = '00504'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10026 THEN	
				LET cCodRet = '00505'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10027 THEN	
				LET cCodRet = '00017'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10028 THEN	
				LET cCodRet = '00506'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10029 THEN	
				LET cCodRet = '00507'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10030 THEN	
				LET cCodRet = '00508'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10031 THEN	
				LET cCodRet = '00509';
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10032 THEN	
				LET cCodRet = '00510';
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10549 THEN
				LET cCodRet = '00511'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10034 THEN
				LET cCodRet = '00512';
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10035 THEN
				LET cCodRet = '00513'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10036 THEN
				LET cCodRet = '00514';
				RETURN cCodRet;
			ELSE					 
				RETURN cCodRet;
			END IF;
			
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 02/06/2015',
'DESCRIPCION: SPL que recibe y obtiene toda la informacion de un archivo enviado por afore coppel.',
'Se valida la informacion contenida en el archivo, y se almacena en la base de datos.',
'FUNCIONALIDAD: RecepciÃ³n de Archivos de Afore Coppel â Procesos AFORE', 
'MODULO: AFORE',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_sw_ro_consctascteparticipacion(pUsuario char(8), pIdFuncion char(10), pIdOficio int, pIdBusqueda int, pIdCliente int, pNumCliente char(20), 
				pRecuperacion int, pIp char(15), pMacAddress char(12))
	returning char(5) as codret
	
	define cCodRet char(5);
	define iSqlErr int;
	define cSitemaCuentaConsulta char(2);
	-- Parametros de salida del SP de consprodcte
	define cIndicadorChequera char(1);
	define cSistemaCuenta char(2);
	define cNoCuenta char(20);
	define cClaveProducto char(4);
	define cNombreProducto char(40);
	define dFechaApertura date;
	define cStatusCuenta char(60);
	define dFechaStatusCuenta date;
	define cClaveSucursal char(4);
	define cEjecutivoAperturaCuenta char(8);
	define mSaldoActual money(14,2);
	define cNumTarjeta char(20);
	define cStatusTarjeta char(15);
	define cCuentaClabe char(18);
	define dFechaAperturaOriginal date;
	define cCodRetSp char(5);
	define iRegistros int;
	define iDiaCorte int;
	define cTipoParticipacion char(1);
	define iExiste int;
	define cNumCuentaParticipe char(20);
	define cStatusBloq char(1);
	define dFechaBloqueo date;
	define cMotivoBloqueo char(40);
	define dFechaCancelacion date;
	define cCodEstatusCta char(2);
	
	let cCodRet = '00000';
	let cCodRetSp = '00000';
	let iSqlErr = 0;
	let cSitemaCuentaConsulta = '00'; -- Todas la cuentas
	-- Parametros de salida del SP de consprodcte
	let cIndicadorChequera = '';
	let cSistemaCuenta = '';
	let cNoCuenta = '';
	let cClaveProducto = '';
	let cNombreProducto = '';
	let dFechaApertura = null;
	let cStatusCuenta = '';
	let dFechaStatusCuenta = null;
	let cClaveSucursal = '';
	let cEjecutivoAperturaCuenta = '';
	let mSaldoActual = null;
	let cNumTarjeta = '';
	let cStatusTarjeta = '';
	let cCuentaClabe = '';
	let dFechaAperturaOriginal = '';
	let iRegistros = 0;
	let iDiaCorte = 0;
	let cTipoParticipacion = '';
	let iExiste = 0;
	let cNumCuentaParticipe = '';
	let cStatusBloq = '0';
	let dFechaBloqueo = null;
	let cMotivoBloqueo = '';
	let dFechaCancelacion = '';
	let cCodEstatusCta = '';
	
	begin
	
		on exception set iSqlErr
			if iSqlErr <> 0 then
				let cCodRet = iSqlErr;
				return cCodRet;
			end if;
		end exception;
		
		-- Cuentas del cliente titular
		let cTipoParticipacion = 'T'; -- en estas cuentas el cliente es titular
		
		while cCodRetSp = '00000'
			set isolation to dirty read;
			foreach execute procedure bdinteg:"informix".sp_cnsif_consprodcte(pUsuario, pIdFuncion, pNumCliente, cSitemaCuentaConsulta, iRegistros, pRecuperacion)
				into cCodRetSp, cIndicadorChequera, cSistemaCuenta, cNoCuenta, cClaveProducto, cNombreProducto, dFechaApertura, 
					cStatusCuenta, dFechaStatusCuenta, cClaveSucursal, cEjecutivoAperturaCuenta, mSaldoActual, cNumTarjeta, cStatusTarjeta, 
					cCuentaClabe, dFechaAperturaOriginal, iDiaCorte, dFechaCancelacion, cCodEstatusCta
				
				if cCodRetSp = '00000' then
				
					-- Se agrega el campo de bloqueo de la cuenta
					let cStatusBloq = '0';
					let dFechaBloqueo = null;
					let cMotivoBloqueo = '';
					
					if iDiaCorte is null then
						let iDiaCorte = 1;
					end if;
					
					execute procedure "informix".sp_sw_ro_consstatusbloqueo(pUsuario, pIdFuncion, cSistemaCuenta, cNoCuenta)
						into cStatusBloq, cMotivoBloqueo, dFechaBloqueo;
					
					insert into "informix".sw_ro_ctascliente_temp(id_oficio, id_busqueda,	id_resulcte, tipo_cuenta, cuenta, clave_producto, nombre_producto, fecha_apertura, 
												status_cuenta, fecha_status_cuenta, clave_suc_apertura,	ejecutivo_apertura,	saldo_actual, num_tarjeta, status_tarjeta,
												cuenta_clabe, fecha_original_apertura, ind_cuenta_ya_bloqueada, motivo_bloqueo, fecha_bloqueo, dia_corte)
					values(pIdOficio, pIdBusqueda, pIdCliente, cSistemaCuenta, cNoCuenta, cClaveProducto, cNombreProducto, dFechaApertura, 
									cStatusCuenta, dFechaStatusCuenta, cClaveSucursal, cEjecutivoAperturaCuenta, mSaldoActual, cNumTarjeta, cStatusTarjeta,
									cCuentaClabe, dFechaAperturaOriginal, cStatusBloq, cMotivoBloqueo, dFechaBloqueo, iDiaCorte);
					--return dbinfo('sqlca.sqlerrd1') with resume;
				end if;
				
			end foreach;
			let iRegistros = iRegistros + pRecuperacion;
			
		end while;
		
		-- Se insertan los registros de las cuentas en las tabla de ctecta
		set isolation to dirty read;
		insert into "informix".sw_ro_ctecta(id_oficio, id_busqueda, id_resulcte, numcte, cuenta, id_tipo_participe, tipo_participe, 
								tipo_cuenta, producto, nombre_producto, status_cuenta, fecha_apertura, sucursal,
								sdo_actual, user_insert, ip_insert, mac_insert, fecha_apertura_original, cuenta_clabe,
								ejecutivo, ind_cuenta_ya_bloqueada, motivo_bloqueo, fecha_bloqueo, dia_corte)
		select distinct id_oficio, id_busqueda, id_resulcte, pNumCliente, cuenta, '1', 'TITULAR',
						tipo_cuenta, clave_producto, nombre_producto, status_cuenta, fecha_apertura, clave_suc_apertura,
						saldo_actual, pUsuario, pIp, pMacAddress, fecha_original_apertura, cuenta_clabe, 
						ejecutivo_apertura, ind_cuenta_ya_bloqueada, motivo_bloqueo, fecha_bloqueo, dia_corte
		from "informix".sw_ro_ctascliente_temp where id_oficio = pIdOficio and id_busqueda = pIdBusqueda and id_resulcte = pIdCliente;
		
		
		-- Se consultan las tarjetas del cliente
		let pRecuperacion = iRegistros + pRecuperacion;
		execute procedure "informix".sp_sw_ro_tarjetascte(pUsuario, pIdFuncion, pIdOficio, pIdBusqueda, pIdCliente, pNumCliente, 0, pRecuperacion) into cCodRetSp;
		
		-- Busca la participaciÃ³n en las cuentas
		execute procedure "informix".sp_sw_ro_buscaparticipacion(pUsuario, pIdOficio, pIdBusqueda, pIdCliente, pNumCliente, pIp, pMacAddress) into cCodRet;
		
		return cCodRet;
		
	end;
end procedure;