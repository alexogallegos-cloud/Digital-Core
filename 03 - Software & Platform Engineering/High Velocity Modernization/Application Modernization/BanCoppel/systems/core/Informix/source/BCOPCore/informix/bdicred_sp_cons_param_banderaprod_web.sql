CREATE PROCEDURE "informix".sp_cons_param_banderaprod_web (  pEmpresa CHAR(3), pUsuario CHAR(8), pTipoBandera CHAR(1), pBandera CHAR(50), pNum_Producto CHAR(4), pcve_canal SMALLINT)			 
		RETURNING CHAR(5) AS codret,
				  CHAR(100) AS descodret,
				  CHAR (1) AS banderaactydesact,
				  CHAR (1) AS numobligados,
				  CHAR (1) AS capturaobligada,
				  CHAR (1) AS idgarantia,
				  CHAR (16) AS aforogarantia,
				  CHAR (20) AS cuenta_concentradora;
	--*TIPOS DE EJECUCIÃN**************
	--* 1 - Bandera Documentos a imprimir
	--*	2 - Bandera Mensajes a activar
	--* 3 - Bandera Canal de Operacion por producto
	--* 4 - Bandera Obligado Solidario
	--* 5 - Bandera Garantias
	--* 6 - Bandera Cuenta Concentradora
	--* 7 - Bandera Activos Prestamo
	--* 8 - Bandera Activos Lineas Prestamo
	--* 9 - Bandera Activos Tarjetas de CrÃ©dito

	-- ****************************************************************************
	-- *                        DEFINICION DE VARIABLES                           *
	-- ****************************************************************************
	DEFINE cCodRet 						CHAR(5);
	DEFINE cdesc_codret					CHAR(100);
	DEFINE iSqlErr 						INTEGER;	
	DEFINE iIsamErr     				INTEGER;
	DEFINE cErrorInfo   				VARCHAR(255,1);	
	DEFINE cEmpresa         			CHAR(3);
	DEFINE cUsuario						CHAR(8);
	DEFINE cBandera 					CHAR(50);
	DEFINE iBandera						INTEGER;
	DEFINE cTipoBandera 				CHAR(1);
    DEFINE cNum_Producto    			CHAR(4);
	DEFINE v_ya_existe 					SMALLINT;
	DEFINE sbanderaactydesact			SMALLINT;
    DEFINE cnum_obligados             	CHAR(1);
    DEFINE ccaptura_obligatoria       	CHAR(1);
	DEFINE scve_canal 					SMALLINT;
	DEFINE sid_evento 					SMALLINT;	
    DEFINE sidgarantia                	SMALLINT;
    DEFINE dporcentajeaforo           	DECIMAL(14,2);	
	DEFINE cidcta_concentradora 		CHAR(1);
	DEFINE ccta_concentradora 			CHAR(20);	
		-----------


	
	-- ****************************************************************************
	-- *                        ASIGNACION DE VARIABLES                           *
	-- ****************************************************************************	

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIsamErr        		= 0;
	LET cErrorInfo      		= "";	
	LET cdesc_codret = '';
	LET cEmpresa = pEmpresa;        	
	LET cUsuario = pUsuario;
	LET cBandera = pBandera;
	LET cTipoBandera = pTipoBandera;	
	LET cNum_Producto = pNum_Producto;  
	LET v_ya_existe			 = 0;
	LET sbanderaactydesact   = 0;
    LET cnum_obligados              = '';
    LET ccaptura_obligatoria        = '';
	LET scve_canal  = pcve_canal;
	LET sid_evento = 0;	
    LET sidgarantia                 = 0;
    LET dporcentajeaforo            = 0;
	LET cidcta_concentradora = '';
	LET ccta_concentradora = '';		 
	-------	
	 
	BEGIN
		-- 
		ON EXCEPTION SET iSqlErr, iIsamErr,cErrorInfo
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;	
				LET cdesc_codret = cErrorInfo;			
				RETURN cCodRet,cdesc_codret,sbanderaactydesact, cnum_obligados, ccaptura_obligatoria, sidgarantia, dporcentajeaforo, ccta_concentradora;
	
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/sp_cons_param_banderaprod.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pEmpresa = '' OR pTipoBandera = '' OR (pBandera = '' AND cTipoBandera NOT IN('4','6','7','8','9')) OR pUsuario = '' OR pNum_Producto = '' OR (pcve_canal = '' AND cTipoBandera IN('2','3')) THEN
			LET cCodRet = '00001';
			LET cdesc_codret = 'Faltan parÃ¡metros de Entrada';	
			RETURN cCodRet,cdesc_codret,sbanderaactydesact, cnum_obligados, ccaptura_obligatoria, sidgarantia, dporcentajeaforo, ccta_concentradora;
		END IF;
		
		-- Bandera Documentos a imprimir
		IF cTipoBandera = '1' THEN 
			LET iBandera = cBandera::INTEGER;
			SELECT count(cod_docto) INTO v_ya_existe
			FROM bdicred:"informix".sd_doctosimprimexproducto WHERE num_producto = cNum_Producto AND cod_docto::INTEGER = iBandera;
			
			IF NVL(v_ya_existe,0) = 1 THEN
				SELECT cantidad INTO sidgarantia --copias de documento
				FROM bdicred:"informix".sd_doctosimprimexproducto WHERE num_producto = cNum_Producto AND cod_docto::INTEGER = iBandera;
			
				LET sbanderaactydesact = v_ya_existe;
			ELSE 
				LET sbanderaactydesact = 0;
			END IF;
		END IF;
		-- Bandera Mensajes a activar
		IF cTipoBandera = '2' THEN 
			LET sid_evento = cBandera::SMALLINT;
			SELECT count(id_evento) INTO v_ya_existe
			FROM bdicred:"informix".sd_activacion_sms_email WHERE num_producto = cNum_Producto AND cve_canal = scve_canal AND id_evento = sid_evento;
			
			IF NVL(v_ya_existe,0) >= 1 THEN
				LET sbanderaactydesact = 1;
			ELSE 
				LET sbanderaactydesact = 0;
			END IF;  							
		END IF;
		-- Bandera Canal de Operacion por producto
		IF cTipoBandera = '3' THEN 
			LET iBandera = cBandera::INTEGER;
			SELECT count(cod_operaciones) INTO v_ya_existe
			FROM bdicred:"informix".sd_operaciones_canal WHERE num_producto = cNum_Producto AND cve_canal = scve_canal AND cod_operaciones = iBandera;

			IF NVL(v_ya_existe,0) >= 1 THEN
				LET sbanderaactydesact = 1;
			ELSE 
				LET sbanderaactydesact = 0;
			END IF; 										
			
		END IF;
		-- Bandera Obligado solidario
		IF cTipoBandera = '4' THEN 
			SELECT count(num_producto) 
			INTO v_ya_existe
			FROM "informix".sd_definicion
			WHERE num_producto = cNum_Producto;
			
			IF v_ya_existe = 1 THEN
			
				SELECT obligado_solidario, num_obligados, captura_obligatoria 
				INTO sbanderaactydesact, cnum_obligados, ccaptura_obligatoria
				FROM "informix".sd_definicion
				WHERE num_producto = cNum_Producto;
			ELSE 
				SELECT count(num_producto) 
				INTO v_ya_existe
				FROM "informix".sd_subproducto
				WHERE substr(num_producto,1,2) = substr(cNum_Producto,1,2) AND id_subproducto = substr(cNum_Producto,3,2);	
				IF v_ya_existe = 1 THEN
					SELECT obligado_solidario, num_obligados, captura_obligatoria 
					INTO sbanderaactydesact, cnum_obligados, ccaptura_obligatoria
					FROM "informix".sd_subproducto
					WHERE substr(num_producto,1,2) = substr(cNum_Producto,1,2) AND id_subproducto = substr(cNum_Producto,3,2);					
				END IF;
			
			END IF;  
		END IF;
		-- Bandera GarantÃ­as
		IF cTipoBandera = '5' THEN 		
			SELECT count(num_producto) 
			INTO v_ya_existe
			FROM "informix".sd_definicion
			WHERE num_producto = cNum_Producto;
			
			IF v_ya_existe = 1 THEN
			
				SELECT garantias, idgarantia, porcentajeaforo 
				INTO sbanderaactydesact, sidgarantia, dporcentajeaforo
				FROM "informix".sd_definicion
				WHERE num_producto = cNum_Producto;
				
			ELSE 
				SELECT count(num_producto) 
				INTO v_ya_existe
				FROM "informix".sd_subproducto
				WHERE substr(num_producto,1,2) = substr(cNum_Producto,1,2) AND id_subproducto = substr(cNum_Producto,3,2);	
				IF v_ya_existe = 1 THEN
					SELECT garantias, idgarantia, porcentajeaforo 
					INTO sbanderaactydesact, sidgarantia, dporcentajeaforo
					FROM "informix".sd_subproducto
					WHERE substr(num_producto,1,2) = substr(cNum_Producto,1,2) AND id_subproducto = substr(cNum_Producto,3,2);					
				END IF;
			
			END IF;  
		END IF;	
		-- Bandera Cta Concentradora
		IF cTipoBandera = '6' THEN 
			SELECT count(num_producto) 
			INTO v_ya_existe
			FROM "informix".sd_definicion
			WHERE num_producto = cNum_Producto;
			
			IF v_ya_existe = 1 THEN
			
				SELECT NVL(idcta_concentradora,'0'), NVL(cta_concentradora,'') 
				INTO sbanderaactydesact, ccta_concentradora
				FROM "informix".sd_definicion
				WHERE num_producto = cNum_Producto;
				
			ELSE 
				SELECT count(num_producto) 
				INTO v_ya_existe
				FROM "informix".sd_subproducto
				WHERE substr(num_producto,1,2) = substr(cNum_Producto,1,2) AND id_subproducto = substr(cNum_Producto,3,2);	
				IF v_ya_existe = 1 THEN
					SELECT NVL(idcta_concentradora,'0'), NVL(cta_concentradora,'') 
					INTO sbanderaactydesact, ccta_concentradora
					FROM "informix".sd_subproducto
					WHERE substr(num_producto,1,2) = substr(cNum_Producto,1,2) AND id_subproducto = substr(cNum_Producto,3,2);					
				END IF;
			END IF;									
		END IF;	
		-- Bandera si pertenece a Familia PrÃ©stamo
		IF cTipoBandera = '7' THEN 
			SELECT count(num_producto) 
			INTO v_ya_existe
			FROM "informix".sd_definicion
			WHERE familia = '002' AND num_producto = cNum_Producto;
			
			IF v_ya_existe = 1 THEN		
				LET sbanderaactydesact = v_ya_existe;
			END IF;									
		END IF;			
		-- Bandera si pertenece a Familia LÃ­nea de CrÃ©dito
		IF cTipoBandera = '8' THEN 
			SELECT count(num_producto) 
			INTO v_ya_existe
			FROM "informix".sd_definicion
			WHERE familia = '003' AND num_producto = cNum_Producto;
			
			IF v_ya_existe = 1 THEN		
				/*SELECT plazo_linea
				INTO sidgarantia
				FROM "informix".sd_definicion
				WHERE familia = '003' AND num_producto = cNum_Producto;	*/
				
				LET sbanderaactydesact = v_ya_existe;
			END IF;									
		END IF;		
		-- Bandera si pertenece a Familia Tarjetas de CrÃ©dito
		IF cTipoBandera = '9' THEN 
			SELECT count(num_producto) 
			INTO v_ya_existe
			FROM "informix".sd_definicion
			WHERE familia = '001' AND num_producto = cNum_Producto;
			
			IF v_ya_existe = 1 THEN		
				LET sbanderaactydesact = v_ya_existe;
			END IF;									
		END IF;	 		
		RETURN cCodRet,cdesc_codret,NVL(sbanderaactydesact,0), NVL(cnum_obligados,'0'), NVL(ccaptura_obligatoria,'0'), NVL(sidgarantia::CHAR(1),'0'), NVL(dporcentajeaforo::CHAR(16),'0.0'), NVL(ccta_concentradora,'');
	END;
END PROCEDURE;