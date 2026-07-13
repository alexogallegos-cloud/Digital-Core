CREATE PROCEDURE "informix".sp_cnsif_monitorsucursales2_totales(cID_USUARIOC CHAR(8), cID_FUNCIONC CHAR(10), Tp_Busqueda CHAR(1), Id_Plaza CHAR(3))
	RETURNING CHAR(5) AS Cod_Retorno,
		INTEGER AS num_registros;

	DEFINE cCodRet        CHAR(5);
	DEFINE iSql_err       INT;    
	DEFINE IdPlaza        CHAR(3);
	DEFINE No_Sucursal    CHAR(4);
	DEFINE Nom_Sucursal   CHAR(40);
	DEFINE Gte_Sucursal   CHAR(40);
	DEFINE Tel_Sucursal   CHAR(14);
	DEFINE Estat_Suc      CHAR(8);
	DEFINE fechadia       DATE;
	DEFINE Flag_abrio     CHAR(1);
	DEFINE Flag_cerro     CHAR(1);
	DEFINE iCont          INT;
	--DEFINE cUsuario       CHAR(8);
	DEFINE Poliza_Suc     CHAR(2);
	DEFINE dFechaHora 	  DATETIME YEAR TO FRACTION(5);
	DEFINE iNumRegistros  INTEGER;
	DEFINE bEnTransaccion BOOLEAN;
	DEFINE iContador      INTEGER;
	DEFINE iMaxCommit 	  INTEGER;
	DEFINE cSucAbrio 	  CHAR(1);
	DEFINE cSucCerro 	  CHAR(1);
	DEFINE cPlaza         CHAR(3);
	DEFINE cSucursal 	  CHAR(4);
	DEFINE cNombre        CHAR(40);
	DEFINE cGerente       CHAR(40);
	DEFINE cTelefono1     CHAR(14);
	DEFINE cSuc_abrio     CHAR(1);
	DEFINE cSuc_cerro     CHAR(1);
	DEFINE cUsuario       CHAR(8);
	DEFINE iExistsUs      INTEGER;
	
	LET cCodRet           = "00000";
	LET iSql_err          = 0;
	LET IdPlaza           = '';
	LET No_Sucursal       = '';
	LET Nom_Sucursal      = '';
	LET Gte_Sucursal      = '';
	LET Tel_Sucursal      = '';
	LET Estat_Suc         = '';
	LET fechadia          = '01-01-1900';
	LET Flag_abrio        = '';
	LET Flag_cerro        = '';
	LET iCont             = 0;
	--LET cUsuario          = '';
	LET Poliza_Suc        = '';
	LET dFechaHora	 	  = CURRENT YEAR TO FRACTION(5);
	LET iNumRegistros 	  = 0;
	LET bEnTransaccion    = 'f';
	LET iContador         = 0;
	LET iMaxCommit        = 1000;
	LET cSucAbrio 		  = '';
	LET cSucCerro 		  = '';
	LET cPlaza            = '';
	LET cSucursal 	      = '';
	LET cNombre           = '';
	LET cGerente          = '';
	LET cTelefono1        = '';
	LET cSuc_abrio        = '';
	LET cSuc_cerro        = '';
	LET cUsuario          = '';
	LET iExistsUs         = 0;
	
	BEGIN
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				
				IF bEnTransaccion = 't' THEN
					ROLLBACK WORK;
				END IF;
				
				LET cCodRet = iSql_err;
				UPDATE bdinteg:"informix".sw_statusmonitorps
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario = cID_USUARIOC;
				RETURN cCodRet, iNumRegistros;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668, -535, -255)
			LET bEnTransaccion = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		-- Se mueve "SET ISOLATION" al principio de las ejecuciones de consultas
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		 -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(cID_USUARIOC,cID_FUNCIONC) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE bdinteg:"informix".sw_statusmonitorps
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario = cID_USUARIOC;
			RETURN cCodRet, iNumRegistros;
		END IF;

		-- SET DEBUG FILE TO "/tmp/mfinis/sp_cnsif_monitorsucursales2_totales.out";
		-- TRACE ON;
		
		-- SE LIMPIA TABLA POR USUARIO
		DELETE FROM bdinteg:"informix".sw_statusmonitorps WHERE usuario = cID_USUARIOC;
		-- Se quita invocaciÃ³n de INDEX por tema de directivas
		DELETE FROM bdinteg:"informix".sw_detallemonitorps WHERE ps_usuario_insert = cID_USUARIOC;
		
		-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
		INSERT INTO bdinteg:"informix".sw_statusmonitorps(usuario,status,num_registros,error_proceso,error)
		VALUES(cID_USUARIOC,'I',0,'',cCodRet);  	
		
		SELECT fecha_hoy INTO fechadia FROM bdinteg:"informix".si_fechas WHERE empresa = '001';
		
		IF Tp_Busqueda = '1' THEN
			--LET Estat_Suc = '';
			LET cSucAbrio = '';
			LET cSucCerro = '';
		ELIF Tp_Busqueda = '2' THEN
			--LET Estat_Suc = 'ABIERTA';
			LET cSucAbrio = '1';
			LET cSucCerro = '0';
		ELIF Tp_Busqueda = '3' THEN
			--LET Estat_Suc = 'CERRADA';
			LET cSucAbrio = '1';
			LET cSucCerro = '1';
		END IF;
		
		
		BEGIN WORK;
		LET bEnTransaccion = 't';
		
		-- Se divide consulta en 2 para usar el filtro por plaza, y bajar tanto costos como la omisiÃ³n de bÃºsquedas sequenciales, y se quita invocaciÃ³n de INDEX por tema de directivas
		IF Id_Plaza <> '' THEN
			FOREACH WITH HOLD
				SELECT
					A.plaza, A.sucursal, A.nombre, A.gerente, A.telefono1, 
					B.suc_abrio, B.suc_cerro, B.usuario
				INTO cPlaza,cSucursal,cNombre,cGerente,cTelefono1,cSuc_abrio,cSuc_cerro,cUsuario
				FROM bdinteg:"informix".si_sucursales A
				INNER JOIN bdisuc:"informix".ss_pase_sucursal B ON A.sucursal = B.sucursal 
																AND B.suc_abrio = (CASE WHEN cSucAbrio = '' THEN B.suc_abrio ELSE cSucAbrio END)
																AND B.suc_cerro = (CASE WHEN cSucCerro = '' THEN B.suc_cerro ELSE cSucCerro END)
																AND A.plaza = Id_Plaza
				WHERE 
					B.fecha_pase = fechadia 
				ORDER BY A.sucursal
				
				IF cSuc_abrio = '1' AND cSuc_cerro = '0' THEN 
					LET Estat_Suc = 'ABIERTA';
				ELSE
					IF cSuc_abrio = '1' AND cSuc_cerro = '1' THEN 
						LET Estat_Suc = 'CERRADA';
					ELSE
						LET Estat_Suc = 'NO ABRIO';
					END IF;
				END IF;
							
				SELECT COUNT(*) INTO iExistsUs FROM bdicont@coppelcont_tcp:"informix".co_detpol WHERE fecha_valida = fechadia AND usuario = cSucursal;
				
				IF NVL(iExistsUs,0) > 0 THEN
					LET Poliza_Suc = 'SI';
				ELSE
					LET Poliza_Suc = 'NO';
				END IF;
				
				LET iExistsUs = 0;
				LET iNumRegistros = iNumRegistros + 1;
				
				INSERT INTO bdinteg:"informix".sw_detallemonitorps(ps_usuario_insert,ps_fecha_hora_insert,
				ps_idplaza,ps_no_sucursal,ps_nom_sucursal,ps_gte_sucursal,ps_tel_sucursal,ps_suc_abrio,ps_suc_cerro,ps_estat_suc,ps_usuario_suc,ps_poliza_suc,ps_fecha_pase)
				VALUES(cID_USUARIOC,dFechaHora,cPlaza,cSucursal,cNombre,cGerente,cTelefono1,cSuc_abrio,cSuc_cerro,Estat_Suc,cUsuario,Poliza_Suc,fechadia);
				
				LET iContador = iContador + 1;
				IF iContador = iMaxCommit THEN
					COMMIT WORK;
					BEGIN WORK;
					LET iContador = 0;
				END IF;
			
			END FOREACH;
		ELSE
			FOREACH WITH HOLD
				SELECT 
					A.plaza, A.sucursal, A.nombre, A.gerente, A.telefono1, 
					B.suc_abrio, B.suc_cerro, B.usuario
				INTO cPlaza,cSucursal,cNombre,cGerente,cTelefono1,cSuc_abrio,cSuc_cerro,cUsuario
				FROM bdinteg:"informix".si_sucursales A
				INNER JOIN bdisuc:"informix".ss_pase_sucursal B ON A.sucursal = B.sucursal 
																AND B.suc_abrio = (CASE WHEN cSucAbrio = '' THEN B.suc_abrio ELSE cSucAbrio END)
																AND B.suc_cerro = (CASE WHEN cSucCerro = '' THEN B.suc_cerro ELSE cSucCerro END)
				WHERE 
					B.fecha_pase = fechadia 
				ORDER BY A.sucursal
				
				
				IF cSuc_abrio = '1' AND cSuc_cerro = '0' THEN 
					LET Estat_Suc = 'ABIERTA';
				ELSE
					IF cSuc_abrio = '1' AND cSuc_cerro = '1' THEN 
						LET Estat_Suc = 'CERRADA';
					ELSE
						LET Estat_Suc = 'NO ABRIO';
					END IF;
				END IF;
				
				SELECT COUNT(*) INTO iExistsUs FROM bdicont@coppelcont_tcp:"informix".co_detpol WHERE fecha_valida = fechadia AND usuario = cSucursal;
				--SELECT COUNT(*) INTO iExistsUs FROM bdicont:"informix".co_detpol WHERE fecha_valida = fechadia AND usuario = cSucursal; 
				IF NVL(iExistsUs,0) > 0 THEN
					LET Poliza_Suc = 'SI';
				ELSE
					LET Poliza_Suc = 'NO';
				END IF;
				
				LET iExistsUs = 0;
				LET iNumRegistros = iNumRegistros + 1;
				INSERT INTO bdinteg:"informix".sw_detallemonitorps(ps_usuario_insert,ps_fecha_hora_insert,
				ps_idplaza,ps_no_sucursal,ps_nom_sucursal,ps_gte_sucursal,ps_tel_sucursal,ps_suc_abrio,ps_suc_cerro,ps_estat_suc,ps_usuario_suc,ps_poliza_suc,ps_fecha_pase)
				VALUES(cID_USUARIOC,dFechaHora,cPlaza,cSucursal,cNombre,cGerente,cTelefono1,cSuc_abrio,cSuc_cerro,Estat_Suc,cUsuario,Poliza_Suc,fechadia);
				
				LET iContador = iContador + 1;
				IF iContador = iMaxCommit THEN
					COMMIT WORK;
					BEGIN WORK;
					LET iContador = 0;
				END IF;
			
			END FOREACH;	
		END IF;

		COMMIT WORK;
		IF bEnTransaccion = 't' THEN
			BEGIN WORK;
			LET bEnTransaccion = 'f';
			LET iContador = 0;
		END IF;
		
		IF NVL(iNumRegistros,0) = 0 THEN
			LET cCodRet = '00091'; 
			UPDATE bdinteg:"informix".sw_statusmonitorps
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario = cID_USUARIOC;
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		UPDATE bdinteg:"informix".sw_statusmonitorps
		SET status = 'T', error_proceso = 'N', num_registros = iNumRegistros WHERE usuario = cID_USUARIOC;
		COMMIT WORK;
		
		RETURN cCodRet, iNumRegistros;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 05/03/2018',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: MONITOR DE PASES CONTABLES DE SUCURSALES', 
'DESCRIPCION: Se implementa el tratado de la informaciÃ³n en segundo plano (spl encargado de consultar el nÃºmero total de registros).',
'AUTOR: L. Montserrat Leon Amador',
'FECHA: 06/01/2020',
'DESCRIPCION: Se aplica optimizaciÃ³n de querys.',
'AUTOR: Jorge Alberto Garcia Lopez',
'FECHA: 21/05/2020',
'DESCRIPCION: Se aplica optimizaciÃ³n de querys.',
'MODIFICO    	:	Erick Huitzil Mirasol',
'MODIFICACIÃN	: 	Se realiza optimizaciÃ³n, se separa consulta para considerar el INDEX por plaza y se omiten INDEX por directivas.',
'FECHA			:	01/11/2023',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_guardar_facial_ine( pNumCliente CHAR(20), pSucursal CHAR(4), pEjecutivo CHAR(8),pTemplate CHAR(9000), pOpcion SMALLINT, pParte SMALLINT, pTemplate_procesado CHAR(1))
	RETURNING CHAR(5) AS CodigoRetorno;

-- *	DEFINICION DE VARIABLES		  
	DEFINE iSqlErr              INTEGER;
	DEFINE cCodRet              CHAR(5);
	DEFINE iSecuencia			INTEGER;
-- *	ASIGNACION DE VARIABLES
	LET	iSqlErr 		= 0;
	LET cCodRet 		= '00000';
	LET iSecuencia 		= 0;
-- *	CONTROL DE ERRORES
BEGIN	
	ON EXCEPTION SET iSqlErr
	    IF iSqlErr <> 0 THEN
	        LET cCodRet = iSqlErr;
	        RETURN cCodRet;
	    END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/respaldosbd/Leslie/sp_guardar_rostro_cte.out';
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	
	--VALIDAR PARÃÂ METROS VACÃÂ OS O NULOS
	IF NVL(TRIM(pSucursal),'') = '' OR NVL(TRIM(pNumCliente),'') = '' 
		OR NVL(TRIM(pTemplate),'') = '' OR NVL(TRIM(pEjecutivo),'') = '' OR pOpcion IS NULL OR pParte IS NULL THEN
		LET cCodRet = '00002';
	END IF;
		
		SELECT MAX(secuencia)  
		INTO iSecuencia
		FROM bdinteg:"informix".si_facial_cliente_ine 
		WHERE numcte = LPAD(TRIM(pNumCliente),9,'0')
		AND estado = 'C'
		AND fecha_insert::DATE = CURRENT::DATE;
		
		IF NVL(iSecuencia,0) = 0 THEN
			LET iSecuencia = 1;
		END IF;
		
		IF pOpcion = 1 THEN
				
				IF NVL(pParte,0) = 1 THEN
					DELETE FROM bdinteg:"informix".si_facial_cliente_ine WHERE numcte = LPAD(TRIM(pNumCliente),9,'0');
					INSERT INTO bdinteg:"informix".si_facial_cliente_ine(numcte, secuencia, estado, sucursal, ejecutivo, fecha_insert, rmapa, rmapa2, rmapa3, template_procesado)
					VALUES(LPAD(TRIM(pNumCliente),9,'0'), iSecuencia, 'C', pSucursal, pEjecutivo, CURRENT, pTemplate,'','','');
					INSERT INTO bdinteg:"informix".si_bitacora_facial_cliente_ine(numcte, secuencia, estado, sucursal, ejecutivo, fecha_insert, rmapa, rmapa2, rmapa3, template_procesado)
					VALUES(LPAD(TRIM(pNumCliente),9,'0'), iSecuencia, 'C', pSucursal, pEjecutivo, CURRENT, pTemplate,'','','');
					LET cCodRet = '00000';
				ELIF NVL(pParte,0) = 2 THEN 
					UPDATE bdinteg:"informix".si_facial_cliente_ine
					SET rmapa2 = pTemplate
					WHERE numcte = LPAD(TRIM(pNumCliente),9,'0')
					  AND estado = 'C'
					  AND fecha_insert::DATE = CURRENT::DATE;
					  
					  UPDATE bdinteg:"informix".si_bitacora_facial_cliente_ine
					SET rmapa2 = pTemplate
					WHERE numcte = LPAD(TRIM(pNumCliente),9,'0')
					  AND estado = 'C'
					  AND fecha_insert::DATE = CURRENT::DATE;
					 
					LET cCodRet = '00000';
				ELIF NVL(pParte,0) = 3 THEN 
					UPDATE bdinteg:"informix".si_facial_cliente_ine
					SET rmapa3 = pTemplate
					WHERE numcte = LPAD(TRIM(pNumCliente),9,'0')
					  AND estado = 'C'
					  AND fecha_insert::DATE = CURRENT::DATE;
					  
					  UPDATE bdinteg:"informix".si_bitacora_facial_cliente_ine
					SET rmapa3 = pTemplate
					WHERE numcte = LPAD(TRIM(pNumCliente),9,'0')
					  AND estado = 'C'
					  AND fecha_insert::DATE = CURRENT::DATE;
					LET cCodRet = '00000';
				ELIF NVL(pParte,0) = 4 THEN 
					LET iSecuencia = iSecuencia + 1;
					INSERT INTO bdinteg:"informix".si_facial_cliente_ine(numcte, secuencia, estado, sucursal, ejecutivo, fecha_insert, rmapa, rmapa2, rmapa3, template_procesado)
					VALUES(LPAD(TRIM(pNumCliente),9,'0'), iSecuencia, 'C', pSucursal, pEjecutivo, CURRENT, pTemplate,'','','');
					
					INSERT INTO bdinteg:"informix".si_bitacora_facial_cliente_ine(numcte, secuencia, estado, sucursal, ejecutivo, fecha_insert, rmapa, rmapa2, rmapa3, template_procesado)
					VALUES(LPAD(TRIM(pNumCliente),9,'0'), iSecuencia, 'C', pSucursal, pEjecutivo, CURRENT, pTemplate,'','','');
					LET cCodRet = '00000';
				ELIF NVL(pParte,0) = 5 THEN 
					UPDATE bdinteg:"informix".si_facial_cliente_ine
					SET rmapa2 = pTemplate
					WHERE numcte = LPAD(TRIM(pNumCliente),9,'0')
					  AND estado = 'C'
					  AND secuencia = iSecuencia
					  AND fecha_insert::DATE = CURRENT::DATE;
					  
					  UPDATE bdinteg:"informix".si_bitacora_facial_cliente_ine
					SET rmapa2 = pTemplate
					WHERE numcte = LPAD(TRIM(pNumCliente),9,'0')
					  AND estado = 'C'
					  AND secuencia = iSecuencia
					  AND fecha_insert::DATE = CURRENT::DATE;
					LET cCodRet = '00000';
				ELIF NVL(pParte,0) = 6 THEN 
					UPDATE bdinteg:"informix".si_facial_cliente_ine
					SET rmapa3 = pTemplate
					WHERE numcte = LPAD(TRIM(pNumCliente),9,'0')
					  AND estado = 'C'
					  AND secuencia = iSecuencia
					  AND fecha_insert::DATE = CURRENT::DATE;
					  
					  UPDATE bdinteg:"informix".si_bitacora_facial_cliente_ine
					SET rmapa3 = pTemplate
					WHERE numcte = LPAD(TRIM(pNumCliente),9,'0')
					  AND estado = 'C'
					  AND secuencia = iSecuencia
					  AND fecha_insert::DATE = CURRENT::DATE;
					LET cCodRet = '00000';
				END IF;
		
		ELIF pOpcion = 2 THEN
		
			UPDATE bdinteg:"informix".si_facial_cliente_ine 
			SET estado = 'C' 
			WHERE numcte = LPAD(TRIM(pNumCliente),9,'0')
			AND estado = 'A';
			
			INSERT INTO bdinteg:"informix".si_facial_cliente_ine(numcte, secuencia, estado, sucursal, ejecutivo, fecha_insert, rmapa, rmapa2, rmapa3, template_procesado)
			VALUES(LPAD(TRIM(pNumCliente),9,'0'), iSecuencia,'A', pSucursal, pEjecutivo, CURRENT, pTemplate,'','','');
			
			UPDATE bdinteg:"informix".si_bitacora_facial_cliente_ine 
			SET estado = 'C' 
			WHERE numcte = LPAD(TRIM(pNumCliente),9,'0')
			AND estado = 'A';
			
			INSERT INTO bdinteg:"informix".si_bitacora_facial_cliente_ine(numcte, secuencia, estado, sucursal, ejecutivo, fecha_insert, rmapa, rmapa2, rmapa3, template_procesado)
			VALUES(LPAD(TRIM(pNumCliente),9,'0'), iSecuencia,'A', pSucursal, pEjecutivo, CURRENT, pTemplate,'','','');
						
			LET cCodRet = '00000';
			
		ELIF pOpcion = 3 THEN
			
			UPDATE  bdinteg:"informix".si_facial_cliente_ine
			SET estado ='A', template_procesado = '1'
			WHERE numcte = LPAD(TRIM(pNumCliente),9,'0')
			AND estado = 'C'
			AND fecha_insert::DATE = CURRENT::DATE;
			
			UPDATE  bdinteg:"informix".si_bitacora_facial_cliente_ine
			SET estado ='A', template_procesado = '1'
			WHERE numcte = LPAD(TRIM(pNumCliente),9,'0')
			AND estado = 'C'
			AND fecha_insert::DATE = CURRENT::DATE;
			
			LET cCodRet = '00000';
		
		END IF;
		
		
	RETURN cCodRet;
END;

END PROCEDURE
DOCUMENT
'DescripciÃ³n: SP que guarda el template procesado y lo divide en 4 partes',
'AUTOR : Eduardo Ãvila PÃ©rez Tagle',
'Gerencia de Mtto y Soporte IV',
'Fecha: 17/Octubre/2023',
'Version: 1.0.0',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_batch_recupera_facial_ine(pParte CHAR(1), pNumcte CHAR(20))
RETURNING CHAR(5),CHAR(9000)
    
    DEFINE 	v_CodRet        CHAR(5);
    DEFINE 	v_CodRet2       CHAR(5);
    DEFINE 	v_CodRet3       CHAR(50);
    DEFINE 	v_SqlErr        INTEGER;
    DEFINE 	v_IsamErr       INTEGER;
    DEFINE 	v_DescErr       CHAR(50);
    
	DEFINE	v_Template		CHAR(9000);
    
    LET v_CodRet          = '00000';
    LET v_CodRet2         = '';
    LET v_CodRet3         = '';
    LET v_SqlErr          = 0;
    LET v_IsamErr         = 0;
    LET v_DescErr         = '';
    
	LET v_Template      = '';
    
    
BEGIN
    
    ON EXCEPTION SET v_SqlErr, v_IsamErr, v_DescErr
        --SET DEBUG FILE TO "/tmp/direcciones_carrier.err";
        --TRACE ON;
        IF v_SqlErr != 0 THEN
            LET v_CodRet = v_SqlErr;
            LET v_CodRet2 = v_IsamErr;
            LET v_CodRet3 = v_DescErr;
            RETURN v_CodRet, TRIM(v_Template);
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "/informix/LIP/sp_batch_facial_ine.out";
	--TRACE ON;


    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	
	IF(pParte = '1') THEN
		
		SELECT rmapa
		INTO v_Template
		FROM bdinteg:"informix".si_facial_cliente_ine
		WHERE numcte = pNumcte AND secuencia = '1' AND estado = 'A';

    ELIF (pParte = '2') THEN
		
		SELECT rmapa2
		INTO v_Template
		FROM bdinteg:"informix".si_facial_cliente_ine
		WHERE numcte = pNumcte AND secuencia = '1' AND estado = 'A';

    ELIF (pParte = '3') THEN
		
		SELECT rmapa3
		INTO v_Template
		FROM bdinteg:"informix".si_facial_cliente_ine
		WHERE numcte = pNumcte AND secuencia = '1' AND estado = 'A';

    ELIF (pParte = '4') THEN
		
		SELECT rmapa
		INTO v_Template
		FROM bdinteg:"informix".si_facial_cliente_ine
		WHERE numcte = pNumcte AND secuencia = '2' AND estado = 'A';
		
    END IF;
	
	
	RETURN v_CodRet,TRIM(v_Template);

END;
    
END PROCEDURE

DOCUMENT
'DescripciÃ³n: SP que recupera las 4 partes del template del cliente a partir del nÃºmero de cliente',
'AUTOR : Eduardo Ãvila PÃ©rez Tagle',
'Gerencia de Mtto y Soporte IV',
'Fecha: 17/Octubre/2023',
'Version: 1.0.0',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_batch_facial_ine(pBandera CHAR(1), pNumCte CHAR(20), pNombre CHAR(200), pApellido CHAR(200), pCelular CHAR(15))
RETURNING CHAR(5) AS codRet
,VARCHAR(20) AS numCte
,VARCHAR(26) AS apell_paterno
,VARCHAR(26) AS apell_materno
,VARCHAR(26) AS nombre1
,VARCHAR(26) AS nombre2
,VARCHAR(32) AS clave_elector
,VARCHAR(32) AS anio_registro
,VARCHAR(32) AS anio_emision
,VARCHAR(32) AS numero_emision
,VARCHAR(32) AS curp
,VARCHAR(32) AS ocr
,VARCHAR(32) AS cic
,VARCHAR(15) AS celular
    
    DEFINE 	v_CodRet        CHAR(5);
    DEFINE 	v_CodRet2       CHAR(5);
    DEFINE 	v_CodRet3       CHAR(50);
    DEFINE 	v_SqlErr        INTEGER;
    DEFINE 	v_IsamErr       INTEGER;
    DEFINE 	v_DescErr       CHAR(50);
    
	DEFINE 	v_NumCte        VARCHAR(20);
	
	DEFINE 	v_Apell_paterno   VARCHAR(26);
	DEFINE 	v_Apell_materno   VARCHAR(26);
	DEFINE 	v_Nombre1         VARCHAR(26);
	DEFINE 	v_Nombre2         VARCHAR(26);

	DEFINE	v_Clave_elector	VARCHAR(32);
	DEFINE	v_Anio_registro	VARCHAR(32);
	DEFINE	v_Anio_emision	VARCHAR(32);
	DEFINE	v_Numero_emision_credencial	VARCHAR(32);
	DEFINE	v_Curp			VARCHAR(32);
	DEFINE	v_Ocr			VARCHAR(32);
	DEFINE	v_Cic			VARCHAR(32);
	DEFINE	v_fecha_actual	DATE;
	DEFINE v_celular	CHAR(15);
    
    LET v_CodRet          = '00000';
    LET v_CodRet2         = '';
    LET v_CodRet3         = '';
    LET v_SqlErr          = 0;
    LET v_IsamErr         = 0;
    LET v_DescErr         = '';
    
	LET v_NumCte          = '';

	LET v_Apell_paterno   = '';
	LET v_Apell_materno   = '';
	LET v_Nombre1         = '';
	LET v_Nombre2         = '';
	LET v_Clave_elector   = '';
	LET v_Anio_registro   = '';
	LET v_Anio_emision    = '';
	LET v_Numero_emision_credencial	= '';
	LET v_Curp          = '';
	LET v_Ocr           = '';
	LET v_Cic           = '';
	LET v_fecha_actual	= CURRENT;
	LET v_celular = '';
    
    
BEGIN
    
    ON EXCEPTION SET v_SqlErr, v_IsamErr, v_DescErr
        --SET DEBUG FILE TO "/tmp/direcciones_carrier.err";
        --TRACE ON;
        IF v_SqlErr != 0 THEN
            LET v_CodRet = v_SqlErr;
            LET v_CodRet2 = v_IsamErr;
            LET v_CodRet3 = v_DescErr;
            RETURN v_CodRet, v_NumCte,TRIM(v_Apell_paterno),TRIM(v_Apell_materno),TRIM(v_Nombre1),TRIM(v_Nombre2),TRIM(v_Clave_elector),v_Anio_registro,v_Anio_emision,v_Numero_emision_credencial,TRIM(v_Curp),TRIM(v_Ocr),TRIM(v_Cic), v_celular;
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "/informix/LIP/sp_batch_facial_ine.out";
	--TRACE ON;


    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	IF pBandera = '1' THEN
		FOREACH 
	
			SELECT DISTINCT cte.numCte,apell_paterno,apell_materno,nombre1,nombre2,clave_elector,anio_registro,anio_emision,numero_emision_credencial,curp,ocr,cic
			INTO v_NumCte,v_Apell_paterno,v_Apell_materno,v_Nombre1,v_Nombre2,v_Clave_elector,v_Anio_registro,v_Anio_emision,v_Numero_emision_credencial,v_Curp,v_Ocr,v_Cic
			FROM bdinteg:"informix".si_cliente cte
			INNER JOIN bdinteg:"informix".si_bitacora_facial_ine bitac
				ON cte.numcte = bitac.numcte
			INNER JOIN bdinteg:"informix".si_facial_cliente_ine_estatus estatus ON cte.numcte = estatus.numcte
			WHERE estatus.validado_ine = 0 AND estatus.fecha = v_fecha_actual
		

			RETURN v_CodRet, v_NumCte,TRIM(v_Apell_paterno),TRIM(v_Apell_materno),TRIM(v_Nombre1),TRIM(v_Nombre2),TRIM(v_Clave_elector),v_Anio_registro,v_Anio_emision,v_Numero_emision_credencial,TRIM(v_Curp),TRIM(v_Ocr),TRIM(v_Cic), v_celular WITH RESUME;

		END FOREACH;
	ELIF pBandera = '2' THEN
		SELECT telefono
		INTO v_celular
		FROM bdinteg:"informix".si_telefonos_actual 
		WHERE numcte = pNumCte AND tipo_tel = 2;
		RETURN v_CodRet, v_NumCte,TRIM(v_Apell_paterno),TRIM(v_Apell_materno),TRIM(v_Nombre1),TRIM(v_Nombre2),TRIM(v_Clave_elector),v_Anio_registro,v_Anio_emision,v_Numero_emision_credencial,TRIM(v_Curp),TRIM(v_Ocr),TRIM(v_Cic), v_celular;
	ELIF pBandera = '3' THEN
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento
('2','CUB_SMS','VAL_INE',pNumCte,'','','1',pNombre,pApellido,'','','','','','','','','',pCelular,1,0,0,0,0,'','')

		INTO v_CodRet;
		RETURN v_CodRet, v_NumCte,TRIM(v_Apell_paterno),TRIM(v_Apell_materno),TRIM(v_Nombre1),TRIM(v_Nombre2),TRIM(v_Clave_elector),v_Anio_registro,v_Anio_emision,v_Numero_emision_credencial,TRIM(v_Curp),TRIM(v_Ocr),TRIM(v_Cic), v_celular;		
	END IF;
	
	
END;
    
END PROCEDURE
DOCUMENT
'DescripciÃ³n: SP que muestra los clientes que se quedaron con situaciÃ³n especial P115 (Rostro pendiente de validar ante el INE) y que la fecha corresponde a la fecha donde se realiza la consulta',
'AUTOR : Eduardo Ãvila PÃ©rez Tagle',
'Gerencia de Mtto y Soporte IV',
'Fecha: 17/Octubre/2023',
'Version: 1.0.0',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_conscatregimenfiscal(pTipoPer CHAR(1))
RETURNING CHAR(5)	AS CodRetorno,
		  CHAR(3)	AS CodRegFiscal,
		  CHAR(150)	AS Descrip;

--Definicion de Variables
DEFINE iSqlErr 	     INTEGER;
DEFINE cCodRet		 CHAR(5);
DEFINE cRegimenFiscal	 CHAR(3);
DEFINE cDescripcion  CHAR(150);

--Inicializacion de Variables
LET iSqlErr 		= 0;
LET cCodRet 		= '00000';
LET cRegimenFiscal 	= '';
LET cDescripcion 	= '';

--SET DEBUG FILE TO '/tmp/sp_conscatregimenfiscal.out';
--TRACE ON;

    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                RETURN cCodRet,'','';
            END IF;
        END EXCEPTION;

        SET LOCK MODE TO WAIT 3;


        IF NVL(pTipoPer,'') = '' THEN
                LET cCodRet = '00001';
                RETURN cCodRet,'','';
        ELSE
            FOREACH 
                SELECT c_regimenfiscal, descripcion
                INTO cRegimenFiscal, cDescripcion
                FROM bdinteg:"informix".si_regimen_fiscal
                WHERE tipo=pTipoPer

                LET cCodRet = iSqlErr;
                RETURN cCodRet, NVL(cRegimenFiscal,''), NVL(cdescripcion,'') WITH resume;

            END FOREACH
            RETURN;
        END IF;

    END;
END PROCEDURE
DOCUMENT
'Descripcion : Se consulta el catalogo de regimen fiscal',
'Etiqueta    : CFDI 4.0',
'Modifico    : Maria de los Angeles Perez Rios',
'Fecha       : 10/11/2023',
'VERSION     : 20231110.01',
'BD          : BDINTEG';

CREATE PROCEDURE "informix".sp_consctemttorfcalterno_cfdi(pEmpresa CHAR(4),
													 pNumCte  CHAR(20),
													 pTarjeta CHAR(20),
													 pCuenta  CHAR(20))
RETURNING CHAR(5)   AS CodRetorno,
		  CHAR(20)  AS NumCte,
		  CHAR(26)  AS Nombre1,
		  CHAR(26)  AS Nombre2,
		  CHAR(26)  AS ApPaterno,
		  CHAR(26)  AS ApMaterno,
		  CHAR(13)  AS RFC,
		  CHAR(13)  AS RFC_Alterno,
		  INTEGER   AS iNumeric,
		  CHAR(100) AS Descripcion,
		  DATE      AS Fecha_Nac,
		  SMALLINT  AS Dependientes,
          --CFDI 4.0
          CHAR(5)   AS CodPostal,
          CHAR(3)   AS RegimFis;


--Definicion de Variables
DEFINE iSqlErr 	     INTEGER;
DEFINE cCodRet		 CHAR(5);
DEFINE cNumCte		 CHAR(20);
DEFINE cNombre1		 CHAR(26);
DEFINE cNombre2 	 CHAR(26);
DEFINE cApPaterno 	 CHAR(26);
DEFINE cApMaterno 	 CHAR(26);
DEFINE cRFC 		 CHAR(13);
DEFINE cRFCAlt 		 CHAR(13);
DEFINE cCuenta       CHAR(20);
DEFINE cBin          CHAR(6);
DEFINE cCredDeb      CHAR(1);
DEFINE cStatus       CHAR(2);
DEFINE cDescripcion  CHAR(100);
DEFINE dFechNacm     DATE;
DEFINE sDependientes SMALLINT;
DEFINE iNumeric      INTEGER;
--CFDI 4.0
DEFINE cCodPostal    CHAR(5);
DEFINE cRFC_fis      CHAR(13);
DEFINE cRegimFis     CHAR(3);

--Inicializacion de Variables
LET iSqlErr 		= 0;
LET cCodRet 		= '00000';
LET cNumCte 		= '';
LET cNombre1 		= '';
LET cNombre2 		= '';
LET cApPaterno 		= '';
LET cApMaterno 		= '';
LET cRFC 			= '';
LET cRFCAlt 		= '';
LET cCuenta         = '';
LET cBin         	= '';
LET cCredDeb     	= '';
LET cStatus         = '';
LET cDescripcion 	= '';
LET dFechNacm 		= DATE(1);
LET sDependientes   = '0';
LET iNumeric 		= 0;
--CFDI 4.0
LET cCodPostal      = '';
LET cRFC_fis        = '';
LET cRegimFis       = '';


--SET DEBUG FILE TO '/tmp/sp_consctemttorfcalterno_cfdi.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			--RETURN cCodRet,'','','','','','','','','','','';
            --CFDI 4.0
            RETURN cCodRet,'','','','','','','','','','','','','';
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa,'') = '' THEN
			LET cCodRet = '372';
			--RETURN cCodRet,'','','','','','','','','','','';
            --CFDI
            RETURN cCodRet,'','','','','','','','','','','','','';
	ELIF NVL(pNumCte,'') = '' AND (NVL(pCuenta,'') = '' AND NVL(pTarjeta,'') = '') THEN
		LET cCodRet = '372';
		--RETURN cCodRet,'','','','','','','','','','','';		
        --CFDI
        RETURN cCodRet,'','','','','','','','','','','','','';		
	ELSE
		IF pCuenta <> '' THEN
			SELECT num_cte,cuenta 
			INTO cNumCte,cCuenta 
			FROM bdicheq:"informix".sc_maechq 
			WHERE cuenta = pCuenta
			AND status_cta  = '1';
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
				SELECT numcte,num_credito,status_cred 
				INTO cNumCte,cCuenta,cStatus 
				FROM bdicred:"informix".sd_maecred 
				WHERE num_credito = pCuenta;
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN
					SELECT numcte,num_credito,status_cred 
					INTO cNumCte,cCuenta,cStatus 
					FROM bdicred:"informix".sd_maecredcrd 
					WHERE num_credito = pCuenta;
					
					IF dbinfo("sqlca.sqlerrd2") = 0 THEN
						LET cCodRet = '00346';
						--RETURN cCodRet,'','','','','','','','','','','';
                        --CFDI
                        RETURN cCodRet,'','','','','','','','','','','','','';
					ELSE
						IF cStatus IN ('CV', 'FF', 'FC') THEN
							LET cCodRet = '00346';
							--RETURN cCodRet,'','','','','','','','','','','';
                            --CFDI
                            RETURN cCodRet,'','','','','','','','','','','','','';
						END IF;
					END IF;
				ELSE
					IF cStatus IN ('CV', 'FF', 'FC') THEN
						LET cCodRet = '00346';
						--RETURN cCodRet,'','','','','','','','','','','';
                        --CFDI
                        RETURN cCodRet,'','','','','','','','','','','','','';
					END IF;
				END IF;
			END IF;
			
		ELIF pTarjeta <> '' THEN
			LET cBin = SUBSTR(pTarjeta,0,6);
			
			SELECT creditodebito 
			INTO cCredDeb
			FROM intercard:"informix".bines 
			WHERE bin = cBin;
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
				LET cCodRet = '00347';
				--RETURN cCodRet,'','','','','','','','','','','';
                --CFDI
                RETURN cCodRet,'','','','','','','','','','','','','';
			ELSE
				IF cCredDeb = "C" THEN
					SELECT numcte,num_credito 
					INTO cNumCte,cCuenta 
					FROM bdicred:"informix".sd_tarjeta 
					WHERE num_tarjeta = pTarjeta;
					
					IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
						LET cCodRet = '00347';
						--RETURN cCodRet,'','','','','','','','','','','';
                        --CFDI
                        RETURN cCodRet,'','','','','','','','','','','','','';
					END IF;
				ELIF  cCredDeb = "D" THEN
					SELECT numcte,cuenta
					INTO cNumCte,cCuenta 
					FROM bdicheq:"informix".sc_tarjeta 
					WHERE empresa = "001"
					AND num_tarjeta = pTarjeta;
					
					IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
						LET cCodRet = '00347';
						--RETURN cCodRet,'','','','','','','','','','','';
                        --CFDI
                        RETURN cCodRet,'','','','','','','','','','','','','';
					END IF;
				END IF;
			END IF;
		ELIF pNumCte <> '' THEN
			LET cNumCte = pNumCte;
		END IF;
            /*
			SELECT a.numcte,a.nombre1,a.nombre2,a.apell_paterno,a.apell_materno,a.rfc,a.rfc_alterno,a.numeric2,b.descripcioncorta,c.fecha_nac,c.dependientes
			INTO cNumCte, cNombre1,cNombre2,cApPaterno,cApMaterno,cRFC,cRFCAlt,iNumeric,cDescripcion,dFechNacm,sDependientes
			FROM bdinteg:"informix".si_cliente a, bdinteg:"informix".si_catcterelacionado b, bdinteg:"informix".si_ctepf c
			WHERE a.numcte = cNumCte
			AND b.clavetipo = a.numeric2
			AND c.numcte = a.numcte;*/

            --consulta si existe el registro en la nueva tabla y es persona física
            IF EXISTS (select a.numcte from bdinteg:"informix".si_fiscal a, bdinteg:"informix".si_cliente b where a.numcte = b.numcte and a.numcte = cNumCte) THEN
                SELECT e.numcte,e.nombre1,e.nombre2,e.apell_paterno,e.apell_materno,a.rfc,a.rfc_alterno,a.numeric2,b.descripcioncorta,c.fecha_nac,c.dependientes,
                e.cod_postal, e.rfc, e.regim_fiscal
                INTO cNumCte, cNombre1,cNombre2,cApPaterno,cApMaterno,cRFC,cRFCAlt,iNumeric,cDescripcion,dFechNacm,sDependientes,cCodPostal,cRFC_fis,cRegimFis
                FROM bdinteg:si_fiscal e --ON e.numcte = a.numcte
                inner join bdinteg:"informix".si_ctepf c on (c.numcte = e.numcte)
                inner join bdinteg:"informix".si_direcciones_actual d on (d.numcte = e.numcte)
                LEFT JOIN bdinteg:"informix".si_cliente a on (e.numcte = a.numcte)
                inner join bdinteg:"informix".si_catcterelacionado b on (b.clavetipo = a.numeric2)
                where e.numcte = cNumCte
                and d.tipo_dir = '1';
                
                LET cRFCAlt = cRFC_fis;
            ELSE
                SELECT a.numcte,a.nombre1,a.nombre2,a.apell_paterno,a.apell_materno,a.rfc,a.rfc_alterno,a.numeric2,b.descripcioncorta,c.fecha_nac,c.dependientes,
                d.cod_postal, a.rfc, e.regim_fiscal
                INTO cNumCte, cNombre1,cNombre2,cApPaterno,cApMaterno,cRFC,cRFCAlt,iNumeric,cDescripcion,dFechNacm,sDependientes,cCodPostal,cRFC_fis,cRegimFis
                FROM bdinteg:"informix".si_cliente a
                inner join bdinteg:"informix".si_catcterelacionado b on (b.clavetipo = a.numeric2)
                inner join bdinteg:"informix".si_ctepf c on (c.numcte = a.numcte)
                inner join bdinteg:"informix".si_direcciones_actual d on (d.numcte = a.numcte)
                LEFT JOIN bdinteg:si_fiscal e ON e.numcte = a.numcte
                where a.numcte = cNumCte
                and d.tipo_dir = '1';
             END IF;
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
				LET cCodRet = '00345';
				--RETURN cCodRet,'','','','','','','','','','','';
				--CFDI
                RETURN cCodRet,'','','','','','','','','','','','','';
			END IF;
			--RETURN cCodRet,cNumCte,cNombre1,cNombre2,cApPaterno,cApMaterno,cRFC,NVL(cRFCAlt,''),iNumeric,cDescripcion,dFechNacm,sDependientes;	
            --CFDI
            RETURN cCodRet,cNumCte,cNombre1,cNombre2,cApPaterno,cApMaterno,cRFC,NVL(cRFCAlt,''),iNumeric,cDescripcion,dFechNacm,sDependientes,NVL(cCodPostal,''),NVL(cRegimFis,'');
	END IF;	
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea Procedimiento Almacenado para la Consulta del RFC Alterno en Sucursal ',
'AUTOR : Martín Eduardo Miranda',
'FECHA : 02 Agosto 2012',
'VERSION: 20120802.01',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_grabarfcalternobitacoramtto(pEmpresa CHAR(4),
														   pNumCte  CHAR(20),
														   pRFCAnt  CHAR(13),
														   pRFCAlt  CHAR(13),
														   pUserInsert CHAR(8),
                                                           --CFDI
                                                           pSucursal CHAR(4),
                                                           pNombre1 CHAR(26),
                                                           pNombre2 CHAR(26),
                                                           pApell_paterno CHAR(26),
                                                           pApell_materno CHAR(26),
                                                           pCod_postal CHAR(5),
                                                           pRegimen CHAR(3))
RETURNING CHAR(5)  AS CodRetorno;

--Definicion de Variables
DEFINE iSqlErr 	     INTEGER;
DEFINE cCodRet		 CHAR(5);
DEFINE sSecuencia    SMALLINT;
DEFINE dFechaHoy     DATE;

--Inicializacion de Variables
LET iSqlErr 		= 0;
LET cCodRet 		= '00000';
LET sSecuencia      = '0';
LET dFechaHoy 		= DATE(1);


--SET DEBUG FILE TO '/tmp/sp_grabarfcalternobitacoramtto.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa,'') = '' THEN
			LET cCodRet = '373';
			RETURN cCodRet;
	ELIF NVL(pRFCAlt,'') = '' THEN
		LET cCodRet = '373';
		RETURN cCodRet;
	ELIF NVL(pUserInsert,'')=''THEN
		LET cCodRet = '373';
		RETURN cCodRet;	
    --CFDI 4.0
	ELIF NVL(pSucursal,'')=''THEN
		LET cCodRet = '373';
		RETURN cCodRet;	
	ELIF NVL(pNombre1,'')=''THEN
		LET cCodRet = '373';
		RETURN cCodRet;	
	ELIF NVL(pApell_paterno,'')=''THEN
		LET cCodRet = '373';
		RETURN cCodRet;	
--	ELIF NVL(pCod_postal,'')=''THEN
--		LET cCodRet = '373';
--		RETURN cCodRet;	
    --End CFDI 4.0
	ELSE
		UPDATE bdinteg:"informix".si_cliente 
		SET rfc_alterno= pRFCAlt
		WHERE empresa = pEmpresa 
		AND numcte = pNumCte;
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
			LET cCodRet = '373';
			RETURN cCodRet;
		ELSE
			SELECT fecha_hoy 
			INTO dFechaHoy
			FROM bdinteg:"informix".si_fechas
			WHERE empresa = pEmpresa;
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
				LET cCodRet = '373';
				RETURN cCodRet;
			ELSE
				SELECT NVL(MAX(Secuencia),'0')
				INTO sSecuencia
				FROM bdinteg:"informix".si_bitacora_rfcalterno 
				WHERE empresa = pEmpresa 
				AND numcte = pNumCte;

				LET sSecuencia = sSecuencia + 1;
				
				INSERT INTO bdinteg:"informix".si_bitacora_rfcalterno (empresa,numcte,secuencia,rfcalt_org,rfcalt_nvo,usert_insert,fecha_insert) 
				VALUES (pEmpresa,pNumCte,sSecuencia,pRFCAnt,pRFCAlt,pUserInsert,dFechaHoy);
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
					LET cCodRet = '374';
					RETURN cCodRet;
                ELSE
                    --CFDI
                    IF EXISTS (select numcte from bdinteg:"informix".si_fiscal where numcte = pNumCte) THEN
                        UPDATE bdinteg:"informix".si_fiscal 
                        SET sucursal= pSucursal,
                        ejecutivo = pUserInsert,
                        apell_paterno = pApell_paterno,
                        apell_materno = pApell_materno,
                        nombre1 = pNombre1,
                        nombre2 = pNombre2,
                        cod_postal = pCod_postal,
						rfc = pRFCAlt,
                        regim_fiscal = pRegimen,
						fecha_hora = current
                        WHERE empresa = pEmpresa 
                        AND numcte = pNumCte;

                        IF dbinfo("sqlca.sqlerrd2") = 0 THEN
                            LET cCodRet = '00375';
                            RETURN cCodRet;	
                        ELSE
                        	RETURN cCodRet;
                        END IF;
                    ELSE
                        INSERT INTO bdinteg:"informix".si_fiscal(empresa,numcte,sucursal,ejecutivo,apell_paterno,apell_materno,nombre1,nombre2,nom_razon_soc,cod_postal,rfc,regim_fiscal,fecha_hora,canal)
                        VALUES(pEmpresa,pNumCte,pSucursal,pUserInsert,pApell_paterno,pApell_materno,pNombre1,pNombre2,'',pCod_postal,pRFCAlt,pRegimen,current,'1');

                        IF dbinfo("sqlca.sqlerrd2") = 0 THEN
                            LET cCodRet = '00376';
                            RETURN cCodRet;	
                        ELSE
                        	RETURN cCodRet;
                        END IF;
                    END IF;

                END IF;
--
			END IF;
		END IF;
	END IF;	
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea Procedimiento Almacenado para grabar el RFC Alterno en una bitacora, además de actualizarlo en la tabla si_cliente',
'AUTOR : Martín Eduardo Miranda',
'FECHA : 02 Agosto 2012',
'VERSION: 20120802.01',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_buscaregimenfiscal(pRegFiscal CHAR(3))
RETURNING CHAR(5)	AS CodRetorno,
		  CHAR(3)	AS CodRegFiscal,
		  CHAR(150)	AS Descrip;

--Definicion de Variables
DEFINE iSqlErr 	     INTEGER;
DEFINE cCodRet		 CHAR(5);
DEFINE cRegimenFiscal	 CHAR(3);
DEFINE cDescripcion  CHAR(150);

--Inicializacion de Variables
LET iSqlErr 		= 0;
LET cCodRet 		= '00000';
LET cRegimenFiscal 	= '';
LET cDescripcion 	= '';

--SET DEBUG FILE TO '/tmp/sp_buscaregimenfiscal.out';
--TRACE ON;

    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                RETURN cCodRet,'','';
            END IF;
        END EXCEPTION;

        SET LOCK MODE TO WAIT 3;


        IF NVL(pRegFiscal,'') = '' THEN
                LET cCodRet = '00001';
                RETURN cCodRet,'','';
        ELSE
                SELECT c_regimenfiscal, descripcion
                INTO cRegimenFiscal, cDescripcion
                FROM bdinteg:"informix".si_regimen_fiscal
                WHERE c_regimenfiscal=pRegFiscal;

                LET cCodRet = iSqlErr;
                RETURN cCodRet, NVL(cRegimenFiscal,''), NVL(cdescripcion,'');

        END IF;

    END;
END PROCEDURE
DOCUMENT
'Descripcion : Consulta el regimen fiscal del cliente',
'Etiqueta    : CFDI 4.0',
'Modifico    : Maria de los Angeles Perez Rios',
'Fecha       : 10/11/2023',
'VERSION     : 20231110.01',
'BD          : BDINTEG';

CREATE PROCEDURE "informix".sp_bitacora_mant_cte (pSuc CHAR(4), pGte CHAR(8), pUsuario CHAR(8), pNumcte CHAR(9), pFecha DATE, pIp CHAR(16))
       RETURNING CHAR(5) as codret;

DEFINE vcodret CHAR(5);
DEFINE vsqlerr INTEGER;


LET vcodret = '00000';
LET vsqlerr = 0;

BEGIN
        ON EXCEPTION SET vsqlerr
			IF vsqlerr <> 0 THEN
				LET vcodret = vsqlerr;
				RETURN vcodret;
			END IF
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
	
	if pNumcte <>'' then
	   INSERT INTO informix.bitacora_mantenimiento(sucursal, gerente, usuario_modifica, numcte, fecha_modifica, ip_maquina) 
              VALUES(pSuc, pGte, pUsuario, pNumcte, CURRENT, pIp);

	   LET vcodret='00000';
       RETURN vcodret;
	else
	  LET vcodret='00001';
      RETURN vcodret;
	end if;
END;
END PROCEDURE;