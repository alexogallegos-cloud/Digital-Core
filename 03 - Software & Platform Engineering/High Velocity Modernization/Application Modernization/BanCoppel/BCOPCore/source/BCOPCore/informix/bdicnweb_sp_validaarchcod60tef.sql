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