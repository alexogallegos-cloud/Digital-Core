CREATE PROCEDURE "informix".sp_desbctasfus(pNumeroCliente CHAR(20), pCuentaOcredito CHAR(20), pUsuario CHAR(10))
RETURNING CHAR(5);


--DEFINICION DE VARIABLES
DEFINE cCodRet        	CHAR(5);
DEFINE iSqlErr        	INTEGER;
DEFINE dFecha         	DATE;
DEFINE cTemp		  	CHAR(80);		--DSB20130806
DEFINE cTmpCod		  	CHAR(6);		--DSB20130806
DEFINE cValidaNumCte	CHAR(20);		--DSB20130911
DEFINE iValidaIdUniPro	INTEGER;		--DSB20130911
DEFINE iNumRows			INTEGER;		--DSB20130911
DEFINE cTotalCta        CHAR(20);
DEFINE sdoc_w			MONEY(14,2);


--INICIALIZACION DE VARIABLES
LET cCodRet   			= '00000';
LET iSqlErr   			= 0;
LET dFecha    			= '';
LET cTemp	  			= '';			--DSB20130806
LET cTmpCod				= '000000';		--DSB20130806
LET cValidaNumCte		= '';			--DSB20130911
LET iValidaIdUniPro 	= 0;			--DSB20130911
LET iNumRows			= 0;			--DSB20130911
LET cTotalCta           = '';
LET sdoc_w				=0;

	--SET DEBUG FILE TO '/informix/ArmandoM/sp_desbctasfus.out';
	--TRACE ON;
	
BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;
	
	--SET LOCK MODE TO WAIT 3;
	--SET ISOLATION TO DIRTY READ;
	
	SELECT fecha_hoy INTO dFecha
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = '001';


	-- Débito
    SELECT FIRST 1 num_cte, sdo_cong 
	INTO cValidaNumCte, sdoc_w															
    FROM bdicheq:"informix".sc_maechq																	
    WHERE num_cte = pNumeroCliente AND cuenta = pCuentaOcredito AND status_cta =3 AND motivo = '09';	
    LET iNumRows = DBINFO("sqlca.sqlerrd2");
    IF(iNumRows > 0) THEN	
		
		IF  sdoc_w=0  THEN
			EXECUTE PROCEDURE bdicheq:bloqueo_cta('001',pCuentaOcredito,000.00,'00','0',dFecha,pUsuario,'', '11','S','12','Z')							--DSB20130806
			INTO cTmpCod, cTemp;

			IF TRIM(cTmpCod) = '000' THEN
				SELECT cuenta  INTO cTotalCta FROM bdinteg:"informix".si_fusbitacoradesbloqueo WHERE cuenta = pCuentaOcredito;		
				LET iNumRows = DBINFO("sqlca.sqlerrd2");
					IF iNumRows = 0 THEN
						INSERT INTO bdinteg:"informix".si_fusbitacoradesbloqueo (id_log,cuenta,usuario,fecha,hora) VALUES (0,pCuentaOcredito,pUsuario,dFecha,CURRENT);
						LET cCodRet = '00000';
					END IF;
			ELSE
				LET cCodRet = '00002';
			END IF;
			
		ELSE
			LET cCodRet = '00004';
		END IF;	
		
	ELSE
		SELECT FIRST 1 num_cte INTO cValidaNumCte															--DSB20130911{
		FROM bdicheq:"informix".sc_maechq																	
		WHERE num_cte = pNumeroCliente AND cuenta = pCuentaOcredito AND status_cta =3 AND (motivo <> '09' OR motivo IS NULL OR motivo='');	
		LET iNumRows = DBINFO("sqlca.sqlerrd2");
		IF(iNumRows > 0) THEN	
			LET cCodRet= '00005';	
			ELSE
			LET cCodRet= '00001';
		END IF;
    END IF;
	
	--Crédito
	SELECT FIRST 1 id_unidad_prod INTO cValidaNumCte																		--DSB20130911{
	FROM bdicred:"informix".sd_maecred																				
	WHERE numcte = pNumeroCliente AND num_credito = pCuentaOcredito AND id_unidad_prod = 3 AND cod_caract_2 = '09';	
	LET iNumRows = DBINFO("sqlca.sqlerrd2");
	IF(iNumRows > 0) THEN																									--DSB20130911}
		EXECUTE PROCEDURE bdicred:"informix".sp_desbloqueocuenta ('001', pCuentaOcredito,pUsuario,1)												--DSB20130806
		INTO cTmpCod, cTemp;
		
		IF TRIM(cTmpCod) = '000000' THEN
			SELECT cuenta  INTO cTotalCta FROM bdinteg:"informix".si_fusbitacoradesbloqueo WHERE cuenta = pCuentaOcredito;		
			LET iNumRows = DBINFO("sqlca.sqlerrd2");
				IF iNumRows = 0 THEN
					INSERT INTO bdinteg:"informix".si_fusbitacoradesbloqueo (id_log,cuenta,usuario,fecha,hora) VALUES (0,pCuentaOcredito,pUsuario,dFecha,CURRENT);
					LET cCodRet = '00000';
				END IF;
		ELSE
			LET cCodRet = '00003';
		END IF;
	END IF;


RETURN cCodRet;

END;
END PROCEDURE
DOCUMENT
'ELABORO: Josue Zepeda',
'FECHA: 14/05/2013',
'DESCRIPCION: PROCESO QUE SE ENCARGA DE DESBLOQUEAR LAS CUENTAS QUE LE PERTENECEN A UN DETERMINADO CLIENTE',
'BD: bdinteg',
'Fecha:			06-08-2013	DSB20130806',
'Modifico:		Jesus Horacio Lopez Gonzalez - 95526749',
'Modificacion:	Se modifica para que ejecute los procedimientos para desbloquear cuentas de clientes bloqueadas por fusion dependiendo si es de debito o de credito.',
'ASUNTO:		Modificación',
'ELABORÓ: 		95579737 José Ernesto Raygoza Villa',
'DESCRIPCIÓN: 	Se genera algunas variables en donde se les asigna la consulta que tienen la instrucción IF EXIST para validarlo con el número de registros que arroja el dbinfo.',
'FECHA: 		11/09/2013 DSB20130911',
'Folio:1302',
'Autor:92474934-Marcos Cuevas',
'Fecha: 26/09/2013',
'Modificación:Se añade validacion para que no guarde dos veces en la tabla de log',
'Sustento: comentarios 02-09-2013 RQM 06 246',
'Solicita:Armando Morales',
'BD:bdinteg';

CREATE PROCEDURE "informix".sp_desbctasfus_conscte(pNumCte CHAR(20),pAnalista CHAR(20))
RETURNING   CHAR(5)   AS CodigoRetorno,
			CHAR(26)  AS  ApellPaterno,
			CHAR(26)  AS ApellMaterno,
			CHAR(26)  AS Nombre,
			CHAR(26)  AS Nombre2 ,
			CHAR(4)   AS Sucursal,
			CHAR(13)  AS RFC,
			CHAR(2)   AS StatusCte,
			DATE      AS FechaAlta,
			DATE      AS FechaNac,
			CHAR(1)   AS Sexo,
			CHAR(26)  AS ApellPaternoCteI,
			CHAR(26)  AS ApellMaternoCteI,
			CHAR(26)  AS NombreCteI,
			CHAR(26)  AS Nombre2CteI ,
			CHAR(4)   AS SucursalCteI,
			CHAR(13)  AS RFCCteI,
			CHAR(2)   AS StatusCteCteI,
			DATE      AS FechaAltaCteI,
			DATE      AS FechaNacCteI,
			CHAR(1)   AS SexoCteI,
			CHAR(20)  AS NumCteI;

--DECLARACION DE VARIABLES
DEFINE cCodRet        		CHAR(5);
DEFINE cApellPaterno  		CHAR(26);
DEFINE cApellMaterno  		CHAR(26);
DEFINE cNombre1       		CHAR(26);
DEFINE cNombre2       		CHAR(26);
DEFINE cSucursal      		CHAR(4);
DEFINE cRFC          		CHAR(13);
DEFINE cStatusCte     		CHAR(2);
DEFINE dFechaAlta     		DATE;
DEFINE dFechaNac     		DATE;
DEFINE iSqlErr       		INTEGER;
DEFINE iIsamErr       		INTEGER;
DEFINE iCont         		INTEGER;
DEFINE cSexo         		CHAR(1);
DEFINE cTpoPers      		CHAR(2);
DEFINE cNumCteTras	  		CHAR(20);
DEFINE cApellPaternoCteI  	CHAR(26);
DEFINE cApellMaternoCteI  	CHAR(26);
DEFINE cNombre1CteI      	CHAR(26);
DEFINE cNombre2CteI      	CHAR(26);
DEFINE cSucursalCteI    	CHAR(4);
DEFINE cRFCCteI         	CHAR(13);
DEFINE cStatusCteCteI   	CHAR(2);
DEFINE dFechaAltaCteI   	DATE;
DEFINE dFechaNacCteI    	DATE;
DEFINE cSexoCteI        	CHAR(1);
DEFINE cTpoPersCteI     	CHAR(2);
DEFINE cValidaCteTit		CHAR(20);		--DSB20130911
DEFINE iNumRows				INTEGER;		--DSB20130911
DEFINE dFechaInsert			DATE;
DEFINE dtHora				DATETIME YEAR TO FRACTION(3);

--INICIALIZACION DE VARIABLES
LET cCodRet       			= '00000';
LET cApellPaterno 			= '';
LET cApellMaterno			= '';
LET cNombre1     			= '';
LET cNombre2     			= '';
LET cSucursal    			= '';
LET cRFC         			= '';
LET cStatusCte    			= '';
LET dFechaAlta    			= DATE(1);
LET dFechaNac    			= DATE(1);
LET iSqlErr      			= 0;
LET iIsamErr      			= 0 ;
LET cSexo         			= '';
LET cTpoPers      			= '';

LET cApellPaternoCteI 		= '';
LET cApellMaternoCteI 		= '';
LET cNombre1CteI      		= '';
LET cNombre2CteI      		= '';
LET cSucursalCteI     		= '';
LET cRFCCteI          		= '';
LET cStatusCteCteI    		= '';
LET dFechaAltaCteI    		= DATE(1);
LET dFechaNacCteI     		= DATE(1);
LET cSexoCteI         		= '';
LET cTpoPersCteI      		= '';
LET cNumCteTras 	  		= '';
LET cValidaCteTit	  		= '';			--DSB20130911
LET iNumRows				= 0;			--DSB20130911
LET dFechaInsert			= DATE(1);
LET dtHora					= CURRENT;

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
			RETURN TRIM(cCodRet), TRIM(NVL(cApellPaterno, '')), TRIM(NVL(cApellMaterno, '')), TRIM(NVL(cNombre1, '')),
			TRIM(NVL(cNombre2, '')), TRIM(NVL(cSucursal, '')), TRIM(NVL(cRFC, '')), TRIM(NVL(cStatusCte,'')), NVL(dFechaAlta, DATE(1)),
			NVL(dFechaNac, DATE(1)), TRIM(NVL(cSexo, '')), TRIM(NVL(cApellPaternoCteI, '')), TRIM(NVL(cApellMaternoCteI, '')), TRIM(NVL(cNombre1CteI, '')), TRIM(NVL(cNombre2CteI, '')), TRIM(NVL(cSucursalCteI, '')), TRIM(NVL(cRFCCteI, '')), TRIM(NVL(cStatusCteCteI,'')), NVL(dFechaAltaCteI, DATE(1)), NVL(dFechaNacCteI, DATE(1)), TRIM(NVL(cSexoCteI, '')), TRIM(NVL(cNumCteTras, ''));
        END IF;
    END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	--SET DEBUG FILE TO '/informix/ArmandoM/sp_desbctasfus_conscte.out';
	--TRACE ON;

	IF NVL(pNumCte, '') = '' THEN  	--VALIDAMOS QUE EL PARAMETRO NO VENGA EN BLANCO
		LET cCodRet = '00100'; 		--PARAMETRO DE ENTRADA INVALIDO
	ELIF LENGTH(pNumCte)<> 9 THEN 	--VALIDAMOS QUE EL NO. DE CLIENTE VENGA CON EL FORMATO
		LET cCodRet = '00200'; 		--LONGITUD INVALIDA PARA EL PARAMETRO DE ENTRADA
	ELSE
		SELECT FIRST 1 cliente_tit INTO cValidaCteTit							--DSB20130911{
		FROM bdinteg:"informix".log_fusionclientes
		WHERE cliente_tit = pNumCte;
		LET iNumRows = DBINFO("sqlca.sqlerrd2");
		IF(iNumRows > 0) THEN
			SELECT FIRST 1 cliente_tit INTO cValidaCteTit
			FROM bdinteg:"informix".log_fusionclientes
			WHERE cliente_tit = pNumCte AND user_insert = pAnalista;
			LET iNumRows = DBINFO("sqlca.sqlerrd2");
			IF(iNumRows = 0) THEN												--DSB20130911}
				LET cCodRet = '00001';
			ELSE
				SELECT tpo_persona, apell_paterno, apell_materno, nombre1, nombre2, sucursal, rfc, status_cte, fecha_alta
				INTO cTpoPers, cApellPaterno, cApellMaterno, cNombre1, cNombre2, cSucursal, cRFC, cStatusCte, dFechaAlta
				FROM bdinteg:"informix".si_cliente
				WHERE numcte = pNumCte;
				LET iNumRows = DBINFO("sqlca.sqlerrd2");						--DSB20130911
				IF(iNumRows = 0) THEN											--DSB20130911
					LET cCodRet = '00300'; 		--NUMERO DE CLIENTE NO EXISTE
				ELSE
					IF cStatusCte = 'BA' THEN
						LET cCodRet = '00400'; 	--EL STATUS DEL CLIENTE INDICA QUE EL CLIENTE SE HA DADO DE BAJA O ESTA CANCELADO
					ELSE
						IF cTpoPers = '01' THEN
							SELECT fecha_nac, sexo
							INTO dFechaNac, cSexo
							FROM bdinteg:"informix".si_ctepf WHERE numcte = pNumCte;
							LET iNumRows = DBINFO("sqlca.sqlerrd2");														--DSB20130911
							IF(iNumRows = 0) THEN																			--DSB20130911
									LET cCodRet = '00500'; 	--INCONGRUENCIA DE DATOS
								END IF
						ELSE
							LET cCodRet = '00700'; 			--PERSONA MORAL
						END IF;
					END IF;

					SELECT DISTINCT(cliente_tras) INTO cNumCteTras FROM bdinteg:"informix".log_fusionclientes WHERE cliente_tit = pNumCte 
					AND fecha_insert =(SELECT MAX(fecha_insert )FROM bdinteg:"informix".log_fusionclientes WHERE cliente_tit = pNumCte)
					AND fecha_hora =(SELECT MAX(fecha_hora )FROM bdinteg:"informix".log_fusionclientes WHERE cliente_tit = pNumCte);
					LET iNumRows = DBINFO("sqlca.sqlerrd2");	
					IF iNumRows=0 THEN
						SELECT DISTINCT(cliente_tras) INTO cNumCteTras FROM bdinteg:"informix".log_fusionclientes WHERE cliente_tit = pNumCte 
						AND fecha_insert =(SELECT MAX(fecha_insert )FROM bdinteg:"informix".log_fusionclientes WHERE cliente_tit = pNumCte);
					END IF;

					SELECT tpo_persona, apell_paterno, apell_materno, nombre1, nombre2, sucursal, rfc, status_cte, fecha_alta
					INTO cTpoPers, cApellPaternoCteI, cApellMaternoCteI, cNombre1CteI, cNombre2CteI, cSucursalCteI, cRFCCteI, cStatusCteCteI, dFechaAltaCteI
					FROM bdinteg:"informix".si_fuscliente
					WHERE numcte = cNumCteTras;
					LET iNumRows = DBINFO("sqlca.sqlerrd2");																	--DSB20130911
					IF(iNumRows = 0) THEN																						--DSB20130911
						LET cCodRet = '00300'; 				--NUMERO DE CLIENTE NO EXISTE
					ELSE
						IF cStatusCte = 'BA' THEN
							LET cCodRet = '00400'; 			--EL STATUS DEL CLIENTE INDICA QUE EL CLIENTE SE HA DADO DE BAJA O ESTA CANCELADO
						ELSE
							IF cTpoPers = '01' THEN
								SELECT fecha_nac, sexo
								INTO dFechaNacCteI, cSexoCteI
								FROM bdinteg:"informix".si_fusctepf WHERE numcte = cNumCteTras;
								LET iNumRows = DBINFO("sqlca.sqlerrd2");														--DSB20130911
								IF(iNumRows = 0) THEN																			--DSB20130911
									LET cCodRet = '00500'; 	--INCONGRUENCIA DE DATOS
								END IF
							ELSE
								LET cCodRet = '00700'; 		--PERSONA MORAL
							END IF;
						END IF;
					END IF;
				END IF;
			END IF;
		ELSE
			LET cCodRet = '00300';
		END IF;
	END IF;
	RETURN TRIM(cCodRet), TRIM(NVL(cApellPaterno, '')), TRIM(NVL(cApellMaterno, '')), TRIM(NVL(cNombre1, '')),
	TRIM(NVL(cNombre2, '')), TRIM(NVL(cSucursal, '')), TRIM(NVL(cRFC, '')), TRIM(NVL(cStatusCte,'')), NVL(dFechaAlta, DATE(1)),
	NVL(dFechaNac, DATE(1)), TRIM(NVL(cSexo, '')), TRIM(NVL(cApellPaternoCteI, '')), TRIM(NVL(cApellMaternoCteI, '')), TRIM(NVL(cNombre1CteI, '')), TRIM(NVL(cNombre2CteI, '')), TRIM(NVL(cSucursalCteI, '')), TRIM(NVL(cRFCCteI, '')), TRIM(NVL(cStatusCteCteI,'')), NVL(dFechaAltaCteI, DATE(1)), NVL(dFechaNacCteI, DATE(1)), TRIM(NVL(cSexoCteI, '')), TRIM(NVL(cNumCteTras, ''));
END
END PROCEDURE
DOCUMENT
'ELABORO: Marcos Cuevas',
'FECHA: 20/06/2013',
'DESCRIPCIÓN: ESTE PROCEDIMIENTO SE ENCARGA DE OBTENER LOS DATOS PERSONALES DEL CLIENTES,LOS CUALES SON REQUERIDOS PARA EL LLENADO DE LA PANTALLA DE DESBLOQUEO DE CLIENTES',
'BD: bdinteg',
'MODIFICO: Josue Zepeda',
'FECHA: 23/08/2013',
'DESCRIPCIÓN: se modifica para que tome de log_fusionclientes el cliente_tras con la fecha_insert maxima',
'BD: bdinteg',
'ASUNTO:		Modificación',
'ELABORÓ: 		José Ernesto Raygoza Villa',
'DESCRIPCIÓN: 	Se genera algunas variables en donde se les asigna la consulta que tienen la instrucción IF EXIST para validarlo directamente de la variable y no de la instucción IF EXIST',
'FECHA: 		04/09/2013 DSB20130911';

CREATE PROCEDURE "informix".sp_altamasivaempnet_alta( pCodEmpresa CHAR(3), pNombreArchivo CHAR(18), pRegistros INTEGER, pStatus CHAR(1))
RETURNING CHAR(5) as vCodRet1,
		  CHAR(100) as vMensaje,
		  CHAR(20) as vnombre_archivo,
		  CHAR(1) as vstatus;

    DEFINE Sql_Err          INTEGER;
    DEFINE Isam_Err         INTEGER;
    DEFINE Desc_Err         CHAR(50);
    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2			CHAR(5);
	DEFINE vMensaje			CHAR(100);
	
	DEFINE vNomArchivo		CHAR(20);
	DEFINE vStatus			CHAR(1);
	DEFINE vNumEmp			CHAR(3);
	
    LET Sql_Err	    = 0;
    LET Isam_Err    = 0;
    LET Desc_Err    = '';
    LET vCodRet1    = '000';
	LET vCodRet2 = '';
	LET vMensaje = '';

    LET vNomArchivo	= '';
	LET vStatus		= '';
	LET vNumEmp		= '';
    
  BEGIN
    
    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/altamasempnet/sp_altamasivaempnet_consecutivo.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vMensaje = Desc_Err;
            RETURN vCodRet1, vMensaje, vNomArchivo,vstatus;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/altamasempnet/sp_altamasivaempnet_carga.out";
    --- TRACE ON;
    
    SET LOCK MODE TO WAIT 5;
    
	---/// VALIDA QUE LOS CAMPOS NO VENGAN VACIOS
	IF TRIM(pCodEmpresa) = '' OR TRIM(pNombreArchivo) = '' OR NVL(pRegistros,0) = 0 OR TRIM(pStatus) = '' THEN
	    LET vCodRet1 = '00001';
		LET vMensaje = 'FALTAN DATOS DE ENTRADA';
		RETURN vCodRet1, vMensaje, vNomArchivo,vStatus;
	END IF;
	
	    -- // VALIDA EL NUMERO DE EMPRESA
    LET vNumEmp  = SUBSTR(pNombreArchivo, 2, 3);
        
    IF pCodEmpresa <> vNumEmp THEN
        LET vCodRet1 = '00002';
		LET vMensaje = 'EL CODIGO DE EMPRESA NO COINCIDE CON EL NOMBRE DEL ARCHIVO';
		RETURN vCodRet1, vMensaje, vNomArchivo,vStatus;
    END IF;
	
	---/// VALIDA LONGITUD DEL NOMBRE DEL ARCHIVO
	IF LENGTH( TRIM(pNombreArchivo) ) <> 18 THEN
        LET vCodRet1 = '00003';
		LET vMensaje = 'LA LONGITUD DEL NOMBRE DEL ARCHIVO ES INCORRECTA, DEBE SER DE 18 CARACTERES';
		RETURN vCodRet1, vMensaje, vNomArchivo,vStatus;
	END IF;
	
	--- /// VALIDA QUE EL ARCHIVO NO ESTE CARGADO
	--LET vNomArchivo = "%" || SUBSTR(pNombreArchivo,1,12) || "%";
	
	SELECT TRIM(NVL(nombre_archivo,'')), status INTO vNomArchivo, vStatus
	FROM bdinteg:"informix".si_altamasivaempnet_ctrl 
	WHERE cod_empresa = pCodEmpresa AND nombre_archivo = TRIM(pNombreArchivo);
	
	IF vNomArchivo <> '' THEN 
		LET vCodRet1 = '00004';
		LET vMensaje = 'EL ARCHIVO YA ESTA REGISTRADO';
	ELSE
		INSERT INTO bdinteg:"informix".si_altamasivaempnet_ctrl 
		(cod_empresa,nombre_archivo,fecha_genera,hora_genera,total_registros,status)
		VALUES(pCodEmpresa,pNombreArchivo,TODAY,CURRENT,pRegistros, pStatus);
		
		SELECT TRIM(NVL(nombre_archivo,'')), status INTO vNomArchivo, vStatus
		FROM bdinteg:"informix".si_altamasivaempnet_ctrl 
		WHERE cod_empresa = pCodEmpresa AND nombre_archivo = TRIM(pNombreArchivo);
		
		LET vCodRet1 = '00000';
		LET vMensaje = 'ARCHIVO REGISTRADO';
	END IF;	
	
	RETURN vCodRet1, vMensaje, vNomArchivo,vStatus;
	
  END;
    
END PROCEDURE;