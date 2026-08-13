CREATE PROCEDURE "informix".sp_cap_consultageneroisrfatca(pUsuario CHAR(8), pIdFuncion CHAR(10),pNumCliente CHAR(20), pNumCuenta CHAR(20), pEjercicio CHAR(4), pBandera CHAR(1))
		RETURNING CHAR(5) AS codret,
	  CHAR(20) AS num_cliente,
	  CHAR(20) AS num_cuenta,
	  CHAR(4) AS ejercicio,
	  CHAR(104) AS nom_completo;
				
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cNumCliente CHAR (20);
	DEFINE cNumCuenta CHAR(20);
	DEFINE cEjercicio CHAR(4);
	DEFINE cNomCompleto CHAR(104);
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE cNoCliente CHAR(20);
	DEFINE cTipoPer CHAR(2);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET iNoRegistros = 0;
	LET cNumCliente = '';
	LET cNumCuenta='';
	LET cEjercicio = '';
	LET cNomCompleto = '';
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET cNoCliente = '';
	LET cTipoPer = '';
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNumCliente,cNumCuenta,cEjercicio,cNomCompleto ;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_consultageneroisrfatca.out';
		--TRACE ON;
		
		IF pBandera = '1' THEN
			IF pUsuario = '' OR pIdFuncion = '' OR pNumCliente = '' OR pEjercicio = '' OR pBandera =''  THEN
				LET cCodRet = '00003';
				RETURN cCodRet,cNumCliente,cNumCuenta,cEjercicio,cNomCompleto ;
			END IF;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNumCliente,cNumCuenta,cEjercicio,cNomCompleto ;
		END IF;
		
		SET ISOLATION TO DIRTY READ;	
		SELECT numcte, tpo_persona
		INTO cNoCliente, cTipoPer
		FROM bdinteg:"informix".si_cliente 
		WHERE numcte = pNumCliente;
		
		IF cTipoPer = '01' THEN
			FOREACH SELECT  a.ejercicio, a.num_cte, a.cuenta, 
				TRIM(b.nombre1)||' '||TRIM(b.nombre2)||' '||TRIM(b.apell_paterno)||' '||TRIM( b.apell_materno)
				INTO cEjercicio,cNumCliente,cNumCuenta,cNomCompleto
				FROM bdicheq:"informix".sc_retenisr AS a, bdinteg:"informix".si_cliente AS b
				WHERE a.num_cte = b.numcte
				AND a.num_cte = pNumCliente
				AND a.ejercicio = pEjercicio
				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet,cNumCliente,cNumCuenta,cEjercicio,cNomCompleto WITH RESUME;		
			END FOREACH;
		ELIF cTipoPer = '02' THEN
			FOREACH SELECT  a.ejercicio, a.num_cte, a.cuenta, razon_social
				INTO cEjercicio,cNumCliente,cNumCuenta,cNomCompleto
				FROM bdicheq:"informix".sc_retenisr AS a, bdinteg:"informix".si_cliente AS b
				WHERE a.num_cte = b.numcte
				AND a.num_cte = pNumCliente
				AND a.ejercicio = pEjercicio
				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet,cNumCliente,cNumCuenta,cEjercicio,cNomCompleto WITH RESUME;		
			END FOREACH;
		END IF;		
			
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cNumCliente,cNumCuenta,cEjercicio,cNomCompleto;
		END IF;
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Julio Martinez Rugerio',
'FECHA: 08/02/2016',
'MODULO: DEBITO',
'FUNCIONALIDAD: GENERA XML PARA REPORTE FATCA. ',
'DESCRIPCION: SPL que realiza la consulta de clientes si es que genero ISR o no',
'AUTOR: M.D.S. Sandra Cano',
'FECHA: 27/05/2016',
'DESCRIPCION: Modificacion del SPL para retornar datos del Cliente Persona Moral',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_consultaparamarchivofatca(pUsuario CHAR(8), pIdFuncion CHAR(10), pBandera CHAR(2))
                RETURNING CHAR(5) AS codret,
                        SMALLINT AS cve_param,
                        CHAR(5) AS valor_param,
                        CHAR(200) AS valor,
                        CHAR(3) AS id_identificador,
                        CHAR(50) AS des_identificador;
                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE iNoRegistros INTEGER;
        DEFINE sCveParam SMALLINT;
        DEFINE cValorParam CHAR(5);
        DEFINE cValor CHAR(200);  
        DEFINE cIdIdentificador     CHAR(3);
        DEFINE cDesIdentificador CHAR(50);
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET iNoRegistros = 0;
        LET sCveParam   = 0;
        LET cValorParam = '';
        LET cValor          = '';
        LET cIdIdentificador    = '';
        LET cDesIdentificador   = '';
        
                
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, sCveParam, cValorParam, cValor, cIdIdentificador, cDesIdentificador;
                END EXCEPTION;
                
               -- SET DEBUG FILE TO '/INFORMIXDUMP/Malik/sp_cap_consultaparamarchivofatca.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR  pBandera = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, sCveParam, cValorParam, cValor, cIdIdentificador, cDesIdentificador;
                END IF;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, sCveParam, cValorParam, cValor, cIdIdentificador, cDesIdentificador;
                END IF;
                
                SET ISOLATION TO DIRTY READ; 
                
                IF pBandera = 1 THEN            
                        SELECT valor
                        INTO cValor
                        FROM bdilide:sl_ftc_prm  
                        WHERE cve_param = 5 
                        AND valor_param = 14; 
                        RETURN cCodRet, sCveParam, cValorParam, cValor, cIdIdentificador, cDesIdentificador;
                
                ELIF pBandera = 2 THEN
                        SELECT valor
                        INTO cValor
                        FROM bdilide:sl_ftc_prm 
                        WHERE cve_param = 2
                        AND valor_param = 3;
                        RETURN cCodRet, sCveParam, cValorParam, cValor, cIdIdentificador, cDesIdentificador;
                ELIF pBandera = 3 THEN
                        SELECT valor 
                        INTO cValor
                        FROM bdilide:'informix'.sl_ftc_prm 
                        WHERE cve_param = 4 
                        AND valor_param = 1;
                        RETURN cCodRet, sCveParam, cValorParam, cValor, cIdIdentificador, cDesIdentificador;
                
                ELIF pBandera = 4 THEN
                        SELECT valor 
                        INTO cValor
                        FROM bdilide:'informix'.sl_ftc_prm 
                        WHERE cve_param = 2 
                        AND valor_param = 4; 
                        RETURN cCodRet, sCveParam, cValorParam, cValor, cIdIdentificador, cDesIdentificador;
                                
                ELIF pBandera = 5 THEN
                        SELECT valor 
                        INTO cValor
                        FROM bdilide:'informix'.sl_ftc_prm 
                        WHERE cve_param = 5
                        AND valor_param = 1;    
                        RETURN cCodRet, sCveParam, cValorParam, cValor, cIdIdentificador, cDesIdentificador;
						
				ELIF pBandera = 6 THEN
                        SELECT valor 
                        INTO cValor
                        FROM bdilide:'informix'.sl_ftc_prm 
                        WHERE cve_param = 5
                        AND valor_param = 6;    
                        RETURN cCodRet, sCveParam, cValorParam, cValor, cIdIdentificador, cDesIdentificador;
						
				ELIF pBandera = 7 THEN
                        SELECT valor 
                        INTO cValor
                        FROM bdilide:'informix'.sl_ftc_prm 
                        WHERE cve_param = 5
                        AND valor_param = 7;    
                        RETURN cCodRet, sCveParam, cValorParam, cValor, cIdIdentificador, cDesIdentificador;
				
				ELIF pBandera = 8 THEN
                                      
                FOREACH
                SELECT  ID, identificador, valor
                INTO cIdIdentificador, cDesIdentificador, cValor
                FROM (
                SELECT 1 AS ID, 'VERSION' AS identificador, valor
                FROM bdilide:sl_ftc_prm
                WHERE cve_param = 5 
                AND valor_param = 5
                UNION 
                SELECT 2 AS ID, 'SENDINGCOMPANYIN' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm   
                WHERE cve_param = 5 
                AND valor_param = 2
                UNION
                SELECT 3 AS ID,'TRANSMITTINGCOUNTRY' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm   
                WHERE cve_param = 5 
                AND valor_param = 9
                UNION
                SELECT 4 AS ID, 'RECEIVINGCOUNTRY' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm   
                WHERE cve_param = 5 
                AND valor_param = 10
                UNION
                SELECT 5 AS ID, 'MESSAGETYPE' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm   
                WHERE cve_param = 5 
                AND valor_param = 11
                UNION
                SELECT 6 AS ID, 'MESSAGEREFID' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm   
                WHERE cve_param = 5 
                AND valor_param = 3
                UNION
                SELECT 7 AS ID, 'CORRMESSAGEREFID' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm   
                WHERE cve_param = 5 
                AND valor_param = 12
                UNION
                SELECT 8 AS ID, 'REPORTINGPERIOD' as identificador, SUBSTRING(valor FROM 7 FOR 4) || '-'|| SUBSTRING(valor FROM 4 FOR 2) || '-' ||SUBSTRING(valor FROM 1 FOR 2)
				FROM bdilide:'informix'.sl_ftc_prm   
				WHERE cve_param = 5 
				AND valor_param = 6
                UNION
                SELECT 9 AS ID, 'RESCOUNTRYCODE' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm   
                WHERE cve_param = 5 
                AND valor_param = 20
                UNION
                SELECT 10 AS ID, 'TINTYPE' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm   
                WHERE cve_param = 5 
                AND valor_param = 1
                UNION
                SELECT 11 AS ID, 'NAME' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm   
                WHERE cve_param = 5 
                AND valor_param = 14
                UNION
                SELECT 12 AS ID, 'COUNTRYCODE' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm   
                WHERE cve_param = 5 
                AND valor_param = 15
                UNION
                SELECT 13 AS ID, 'ADDRRESS FREE' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm   
                WHERE cve_param = 5 
                AND valor_param = 16
                UNION
                SELECT 14 AS ID, 'DOCTYPEINDIC' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm   
                WHERE cve_param = 5 
                AND valor_param = 18
                UNION
                SELECT 15 AS ID, 'DOCREFID' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm  
                WHERE cve_param = 5 
                AND valor_param = 17
                UNION
                SELECT 16 AS ID, 'CORRDOCREFID' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm     
                WHERE cve_param = 5 
                AND valor_param = 19
				UNION
                SELECT 17 AS ID, 'TIPO PAGO' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm     
                WHERE cve_param = 5 
                AND valor_param = 21
				UNION
                SELECT 18 AS ID, 'CODIGO MONEDA' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm     
                WHERE cve_param = 5 
                AND valor_param = 22
				UNION
                SELECT 19 AS ID, 'TIN ISSUEDBY' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm     
                WHERE cve_param = 5 
                AND valor_param = 23
				UNION
                SELECT 20 AS ID, 'ACCT HOLDERTYPE' as identificador, valor
                FROM bdilide:'informix'.sl_ftc_prm     
                WHERE cve_param = 5 
                AND valor_param = 24
                ORDER BY 1)
                LET iNoRegistros = iNoRegistros + 1;
                RETURN cCodRet, sCveParam, cValorParam, cValor, cIdIdentificador, cDesIdentificador WITH RESUME;
                END FOREACH;
            END IF;         
                
                IF DBINFO('sqlca.sqlerrd2') = 0 THEN
                        LET cCodRet = '00017';
                        RETURN cCodRet, sCveParam, cValorParam, cValor, cIdIdentificador, cDesIdentificador;
               END IF;                                
        END;    
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 09/02/2016',
'MODULO: FATCA',
'FUNCIONALIDAD: GENERACIÓN DE ARCHIVO XML CON INFORMACIÓN ANUAL PARA REPORTE FATCA ',
'DESCRIPCION:SPL que obtiene los parametros para el archivo XML Fatca.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_consultaparametrosfatca(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoParametro INTEGER, pRegistros INTEGER, pRecuperacion INTEGER)
            RETURNING CHAR(5) AS codret,
                CHAR(200) AS canal,
                CHAR(5) AS valor_param,
				CHAR(200) AS valor,
                CHAR(200) AS clasificacion,
                INTEGER AS id_clasificacion;              
                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cCanal CHAR(200);
        DEFINE cValorParam CHAR(5);
		DEFINE cValor CHAR(200);
        DEFINE cClasificacion CHAR(200);
        DEFINE cIdClasificacion INTEGER;
        DEFINE iNoRegistros INTEGER;
        DEFINE iRegistros INTEGER;
        DEFINE iRecuperacion INTEGER;
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCanal ='';
        LET cValorParam='';
        LET cClasificacion ='';
        LET cIdClasificacion=0;
        LET iNoRegistros = 0;
        LET iRegistros = 0;
        LET iRecuperacion = 0;
        
        BEGIN
        
			ON EXCEPTION SET iSqlErr
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cCanal, cValorParam,cValor, cClasificacion,cIdClasificacion;
			END EXCEPTION;
			
			--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_consultaparametrosfatca.out';
			--TRACE ON;
			
			IF pUsuario = '' OR pIdFuncion = '' OR pTipoParametro IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cCanal, cValorParam,cValor, cClasificacion,cIdClasificacion;
			END IF;
			
			-- VALIDACION DE LA PAGINACION
			IF pRegistros < 0 OR pRecuperacion < 0 THEN
				LET cCodRet = '00098';
				RETURN cCodRet, cCanal, cValorParam,cValor,cClasificacion,cIdClasificacion;
			END IF;
			
			-- VALIDACION DE ACCESO A LA FUNCIONALIDAD              
			EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
					RETURN cCodRet, cCanal, cValorParam, cValor,cClasificacion,cIdClasificacion;
			END IF;
			
			IF pTipoParametro = 1 OR  pTipoParametro = 5 THEN
					FOREACH 
						SELECT  SKIP pRegistros FIRST pRecuperacion a. desc_valor AS canal,  a.valor_param, a.valor, '-' as clasificacion,  valor_param as id_clasificacion
							INTO  cCanal, cValorParam,cValor, cClasificacion,cIdClasificacion
						FROM bdilide:sl_ftc_prm AS a, bdilide:sl_ftc_cat AS b
							WHERE a.cve_param = b.cve_param
							AND a.cve_param = pTipoParametro
							ORDER BY valor_param::INTEGER 
						LET iNoRegistros = iNoRegistros + 1;
						RETURN cCodRet, cCanal, cValorParam, cValor,cClasificacion,cIdClasificacion WITH RESUME;
					END FOREACH;
			ELIF pTipoParametro>=2 OR  pTipoParametro <= 4THEN
					FOREACH 
					SELECT  SKIP pRegistros FIRST pRecuperacion a. desc_valor AS canal, a.valor_param, a.valor, c.c_desc_vparam as clasificacion, a.valor_param::int as id_clasificacion
							INTO  cCanal, cValorParam,cValor, cClasificacion,cIdClasificacion
						FROM bdilide:sl_ftc_prm AS a
						INNER JOIN bdilide:sl_ftc_cat AS b ON a.cve_param = b.cve_param
						LEFT JOIN bdilide:sl_ftc_clas_cat as c ON a.valor_param::int = c.c_vparam
							WHERE  a.cve_param = pTipoParametro
							ORDER BY valor_param::DECIMAL 
						LET iNoRegistros = iNoRegistros + 1;
						RETURN cCodRet, cCanal, cValorParam,cValor,cClasificacion,cIdClasificacion WITH RESUME;
					END FOREACH;
			END IF; 
			
			IF iNoRegistros = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cCanal, cValorParam, cValor,cClasificacion,cIdClasificacion; 
			ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, cCanal, cValorParam,cValor, cClasificacion,cIdClasificacion; 
			END IF;
			
        END;    
END PROCEDURE
DOCUMENT 'AUTOR: Julio Martinez Rugerio',
'FECHA: 08/02/2016',
'MODULO: DEBITO',
'FUNCIONALIDAD: PARAMETROS FATCA. ',
'DESCRIPCION: SPL que realiza la consulta de para llenado del grid principal de parametros Fatca',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_consultaparametrosfatca_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoParametro INTEGER)
		RETURNING CHAR(5) AS codret,
				  INTEGER AS num_registros;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_consultaparametrosfatca.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoParametro IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		IF pTipoParametro = 1 OR  pTipoParametro = 5 THEN
			SELECT  count(*)
					INTO  iNoRegistros
					FROM bdilide:sl_ftc_prm AS a, bdilide:sl_ftc_cat AS b
					WHERE a.cve_param = b.cve_param
					AND a.cve_param = pTipoParametro;							
		ELIF pTipoParametro >= 2 OR  pTipoParametro <= 4 THEN
			SELECT  count(*)
					INTO  iNoRegistros
					FROM bdilide:sl_ftc_prm AS a
					INNER JOIN bdilide:sl_ftc_cat AS b ON a.cve_param = b.cve_param
					LEFT JOIN bdilide:sl_ftc_clas_cat as c ON a.valor_param::int = c.c_vparam
					WHERE  a.cve_param = pTipoParametro;						
		END IF;	
		
				IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iNoRegistros;
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Julio Martinez Rugerio',
'FECHA: 08/02/2016',
'MODULO: DEBITO',
'FUNCIONALIDAD: PARAMETROS FATCA. ',
'DESCRIPCION: SPL que realiza la consulta de totales para llenado del grid principal de parametros Fatca',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_limpiaconsultasfatca(pUsuario CHAR(8), pIdFuncion CHAR(10), pEjercicio CHAR(4))
		RETURNING CHAR(5) AS codret;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistrosdet INTEGER;
	DEFINE iNoRegistroscte INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistrosdet = 0;
	LET iNoRegistroscte = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_limpiaconsultasfatca.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pEjercicio = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		
		SELECT COUNT (*)
		INTO iNoRegistrosdet
		FROM bdilide:'informix'.sl_ftc_det
		WHERE ejercicio = pEjercicio;
		
		IF (iNoRegistrosdet > 0) THEN 			
		DELETE 
		FROM bdilide:'informix'.sl_ftc_det
		WHERE ejercicio = pEjercicio;
		END IF;
		
		
		SELECT COUNT (*)
		INTO iNoRegistroscte
		FROM bdilide:'informix'.sl_ftc_cte
		WHERE ejercicio = pEjercicio;
		
		IF (iNoRegistroscte > 0 ) THEN 
		DELETE 
		FROM bdilide:'informix'.sl_ftc_cte
		WHERE ejercicio = pEjercicio;
		END IF;
		
		IF iNoRegistroscte  = 0  OR iNoRegistrosdet = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet;
		END IF;		
			
		RETURN cCodRet;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 04/03/2016',
'MODULO: FATCA',
'FUNCIONALIDAD: GENERACIÓN DE ARCHIVO XML CON INFORMACIÓN ANUAL PARA REPORTE FATCA ',
'DESCRIPCION:SPL que realiza la limpieza de tablas dependiendo su ejercicio.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ccl_consaldosdiariospagare(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret, 
		DATE AS fecha,
		CHAR (4) AS sucursal,
		CHAR (20) AS cuenta,
		CHAR (20) AS num_cte,
		DATE AS fech_cap,
		DECIMAL (18,2) AS capital,
		DECIMAL (18,2) AS interes,
		SMALLINT AS secuencia;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE dFecha DATE;
	DEFINE cSucursal CHAR (4);
	DEFINE cCuenta CHAR (20);
	DEFINE cNumCte CHAR (20);
	DEFINE dFechCap DATE;
	DEFINE dCapital DECIMAL (18,2);
	DEFINE dInteres DECIMAL (18,2);
	DEFINE sSecuencia SMALLINT;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET dFecha = '';
	LET cSucursal = '';
	LET cCuenta = '';
	LET cNumCte = '';
	LET dFechCap = '';
	LET dCapital = 0.00;
	LET dInteres = 0.00;
	LET sSecuencia = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dFecha, cSucursal, cCuenta, cNumCte, dFechCap, dCapital, dInteres, sSecuencia;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_ccl_consaldosdiariospagare.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pFechaInicio IS NULL OR pFechaFin IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFecha, cSucursal, cCuenta, cNumCte, dFechCap, dCapital, dInteres, sSecuencia;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, dFecha, cSucursal, cCuenta, cNumCte, dFechCap, dCapital, dInteres, sSecuencia;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dFecha, cSucursal, cCuenta, cNumCte, dFechCap, dCapital, dInteres, sSecuencia;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH 
			SELECT SKIP pRegistros FIRST pRecuperacion fecha, sucursal, cuenta, num_cte, fech_cap, capital, interes, secuencia
			INTO dFecha, cSucursal, cCuenta, cNumCte, dFechCap, dCapital, dInteres, sSecuencia 
			FROM bdinvers:"informix".sv_sdosdiarios
			WHERE fecha >= pFechaInicio 
				AND fecha <= pFechafin
			
			LET iNoRegistros = iNoRegistros + 1;
			
			RETURN cCodRet, dFecha, cSucursal, cCuenta, cNumCte, dFechCap, dCapital, dInteres, sSecuencia WITH RESUME;
		END FOREACH;
		
		IF iNoRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, dFecha, cSucursal, cCuenta, cNumCte, dFechCap, dCapital, dInteres, sSecuencia;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, dFecha, cSucursal, cCuenta, cNumCte, dFechCap, dCapital, dInteres, sSecuencia;
		END IF;	
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe AngÃ©lica HernÃ¡ndez PÃ©rez',
'FECHA: 28/06/2016',
'MODULO: CONCILIACIONES',
'FUNCIONALIDAD: SALDOS DIARIOS DEL SISTEMA DE INVERSIONES (PAGARE)',
'DESCRIPCION: Spl que realiza la consulta de los saldos diarios del sistema de inversiones de los pagares.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ccl_consaldosdiariospagare_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE)
		RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;	
		
	DEFINE cCodRet 		CHAR(5);
	DEFINE iSqlErr 		INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ccl_consaldosdiariospagare_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		SELECT COUNT(*) 
		INTO iNoRegistros 
		FROM bdinvers:"informix".sv_sdosdiarios
		WHERE fecha >= pFechaInicio
			AND fecha <= pFechaFin;
					
		RETURN cCodRet, iNoRegistros;
	
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iNoRegistros;
		END IF;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angélica Hernández Pérez',
'FECHA: 28/06/2016',
'MODULO: CONCILIACIONES',
'FUNCIONALIDAD: SALDOS DIARIOS DEL SISTEMA DE INVERSIONES (PAGARE)',
'DESCRIPCION: Spl que realiza la consulta de totales para los saldos diarios del sistema de inversiones de los pagares.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_conscedulasccl(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaCcl DATE, pTipo SMALLINT,pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
		CHAR(40) AS nombre, 
		CHAR(14) AS cta_contable, 
		DECIMAL(16,2) AS Saldo_cheques, 
		DECIMAL(16,2) AS saldo_contab, 
		DECIMAL(16,2) AS dif_saldos,  
		CHAR(255) AS observaciones, 
		CHAR(1) AS editable;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cNombre CHAR(40);
    DEFINE cCtaContable CHAR(14);
    DEFINE dSdoCheques DECIMAL(16,2);
    DEFINE dSdoContab DECIMAL(16,2);
    DEFINE dDifSaldos DECIMAL(16,2);
    DEFINE cObservaciones CHAR(255);
    DEFINE cEditable CHAR(1);
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
			
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET cNombre        = '';
    LET cCtaContable   = '';
    LET dSdoCheques    = 0.00;
    LET dSdoContab     = 0.00;
    LET dDifSaldos     = 0.00;
    LET cObservaciones = '';
    LET cEditable      = '';
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNombre, cCtaContable, dSdoCheques, dSdoContab, dDifSaldos, cObservaciones, cEditable;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_conscedulasccl.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaCcl = '' OR pTipo IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNombre, cCtaContable, dSdoCheques, dSdoContab, dDifSaldos, cObservaciones, cEditable;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNombre, cCtaContable, dSdoCheques, dSdoContab, dDifSaldos, cObservaciones, cEditable;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNombre, cCtaContable, dSdoCheques, dSdoContab, dDifSaldos, cObservaciones, cEditable;
		END IF;
		
		SET ISOLATION TO DIRTY READ;		
		FOREACH
			EXECUTE PROCEDURE bdicheq:"informix".sp_consultacedulas2(pFechaCcl, pTipo, pRegistros, pRecuperacion)
			INTO cCodRetSp, cNombre, cCtaContable, dSdoCheques, dSdoContab, dDifSaldos, cObservaciones, cEditable		
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicnweb:sp_consultacedulas2 ";
			ELIF cCodRetSp::INTEGER = 110  THEN
				LET cCodRet = '00003';
			ELIF cCodRetSp::INTEGER = 100  THEN
				LET cCodRet = '00017';
			END IF;
			LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet, UPPER(TRIM(cNombre)), cCtaContable, dSdoCheques, dSdoContab, dDifSaldos, UPPER(TRIM(cObservaciones)), UPPER(TRIM(cEditable)) WITH RESUME;		
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNombre, cCtaContable, dSdoCheques, dSdoContab, dDifSaldos, cObservaciones, cEditable;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cNombre, cCtaContable, dSdoCheques, dSdoContab, dDifSaldos, cObservaciones, cEditable;
		END IF;
	
	END;

END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 07/10/2015',
'MODULO: CONCILIACIONES  ',
'FUNCIONALIDAD: CONCILIACIÓN SALDOS CAPTACIÓN',
'DESCRIPCION:SPL que consulta el detalle de los datos utilizados en la pantalla',
'BD: bdicnweb',
'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 29/08/2016',
'DESCRIPCION:Se realiza una modificación a la base que pertenece el productivo',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_conscedulasccl_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaCcl DATE, pTipo SMALLINT)
		RETURNING CHAR(5) AS codret,		
		INTEGER AS num_registros;

	DEFINE cCodRet 					CHAR(5);
	DEFINE cCodRetSp 				CHAR(6);
	DEFINE cDescCodRet 				CHAR(100);
	DEFINE iCodRetSp				INTEGER;
	DEFINE iSqlErr 					INTEGER;	
	DEFINE iNumRegistros 			INTEGER;
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET cDescCodRet = '';
	LET iCodRetSp = 0;
	LET iSqlErr = 0;
	LET iNumRegistros = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNumRegistros;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_conscedulasccl_totales.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaCcl = '' OR pTipo IS NULL  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		EXECUTE PROCEDURE bdicheq:"informix".sp_consultacedulas2_totales(pFechaCcl, pTipo)
		INTO cCodRetSp,iNumRegistros;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bditarjeta:sp_consultacedulas2_totales';
		END IF;
		
		IF iNumRegistros = 0 THEN
			LET cCodRet = '00017';		
		END IF;
        
		RETURN cCodRet, iNumRegistros;
		
	END;

END PROCEDURE 
DOCUMENT 'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 07/10/2015',
'MODULO: CONCILIACIONES  ',
'FUNCIONALIDAD: CONCILIACIÓN SALDOS CAPTACIÓN',
'DESCRIPCION:SPL que consulta el total de los datos utilizados en la pantalla',
'BD: bdicnweb',
'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 29/08/2016',
'DESCRIPCION:Se realiza una modificación a la base que pertenece el spl productivo',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultacedulas( pFechaConcil DATE, pTipo SMALLINT )
RETURNING CHAR(5), CHAR(40), CHAR(14), DECIMAL(18,2), DECIMAL(18,2), DECIMAL(18,2), CHAR(255), CHAR(1);
    
    DEFINE cCodRet1         CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE cCodRet3         CHAR(50);
    DEFINE iSqlErr          INTEGER;
    DEFINE iSamErr          INTEGER;
    DEFINE cDesErr          CHAR(50);
    DEFINE iExiste          SMALLINT;
    DEFINE cNombre          CHAR(40);
    DEFINE cCtaContable     CHAR(14);
    DEFINE mSdoCheques      DECIMAL(18,2);
    DEFINE mSdoContab       DECIMAL(18,2);
    DEFINE mDifSaldos       DECIMAL(18,2);
    DEFINE cObservaciones   CHAR(255);
    DEFINE cEditable        CHAR(1);
    
    LET cCodRet1       = '000';
    LET cCodRet2       = '';
    LET cCodRet3       = '';
    LET iSqlErr	       = 0;
    LET iSamErr        = 0;
    LET cDesErr        = '';
    LET iExiste        = 0;
    LET cNombre        = '';
    LET cCtaContable   = '';
    LET mSdoCheques    = 0.00;
    LET mSdoContab     = 0.00;
    LET mDifSaldos     = 0.00;
    LET cObservaciones = '';
    LET cEditable      = '';
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/tmp/sp_consultacedulas.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_consultacedulas.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( ( pFechaConcil is null OR pFechaConcil = '' ) OR
         ( pTipo is null OR pTipo NOT IN(1, 2, 3, 4, 5) ) ) THEN
        LET cCodRet1 = '110';
        RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable;
    END IF;
    
    IF pTipo = 1 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'CAPITAL';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT nombre, cta_contable, sdo_sistema, sdo_balanza, dif_saldos, observaciones, editable
                  INTO cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable
                  FROM bdicheq:sc_cedulacontable
                 WHERE fecha_concil = pFechaConcil
                   AND concepto = 'CAPITAL'
                   
                RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable WITH RESUME;
                
                LET cNombre = '';
                LET cCtaContable = '';
                LET mSdoCheques = 0.00;
                LET mSdoContab = 0.00;
                LET mDifSaldos = 0.00;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable;
        END IF;
    ELIF pTipo = 2 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'INTERES';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT nombre, cta_contable, sdo_sistema, sdo_balanza, dif_saldos, observaciones, editable
                  INTO cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable
                  FROM bdicheq:sc_cedulacontable
                 WHERE fecha_concil = pFechaConcil
                   AND concepto = 'INTERES'
                   
                RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable WITH RESUME;
                
                LET cNombre = '';
                LET cCtaContable = '';
                LET mSdoCheques = 0.00;
                LET mSdoContab = 0.00;
                LET mDifSaldos = 0.00;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable;
        END IF;
    ELIF pTipo = 3 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'SOBREGIRO';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT nombre, cta_contable, sdo_sistema, sdo_balanza, dif_saldos, observaciones, editable
                  INTO cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable
                  FROM bdicheq:sc_cedulacontable
                 WHERE fecha_concil = pFechaConcil
                   AND concepto = 'SOBREGIRO'
                   
                RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable WITH RESUME;
                
                LET cNombre = '';
                LET cCtaContable = '';
                LET mSdoCheques = 0.00;
                LET mSdoContab = 0.00;
                LET mDifSaldos = 0.00;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable;
        END IF;
    ELIF pTipo = 4 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'PAGARE';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT nombre, cta_contable, sdo_sistema, sdo_balanza, dif_saldos, observaciones, editable
                  INTO cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable
                  FROM bdicheq:sc_cedulacontable
                 WHERE fecha_concil = pFechaConcil
                   AND concepto = 'PAGARE'
                   
                RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable WITH RESUME;
                
                LET cNombre = '';
                LET cCtaContable = '';
                LET mSdoCheques = 0.00;
                LET mSdoContab = 0.00;
                LET mDifSaldos = 0.00;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable;
        END IF;
    ELIF pTipo = 5 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'INT PAGARE';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT nombre, cta_contable, sdo_sistema, sdo_balanza, dif_saldos, observaciones, editable
                  INTO cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable
                  FROM bdicheq:sc_cedulacontable
                 WHERE fecha_concil = pFechaConcil
                   AND concepto = 'INT PAGARE'
                   
                RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable WITH RESUME;
                
                LET cNombre = '';
                LET cCtaContable = '';
                LET mSdoCheques = 0.00;
                LET mSdoContab = 0.00;
                LET mDifSaldos = 0.00;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable;
        END IF;
    END IF;
     
    END;
    
END PROCEDURE;