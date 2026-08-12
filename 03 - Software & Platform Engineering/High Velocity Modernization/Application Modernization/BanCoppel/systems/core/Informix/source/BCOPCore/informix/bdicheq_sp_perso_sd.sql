CREATE PROCEDURE "informix".sp_perso_sd(pCuenta_eje	CHAR(20),pCuenta_sd	CHAR(20),pNombre_sd CHAR(18),pIcono CHAR(2),pColor CHAR(2))
							
	RETURNING   CHAR(5), --Codigo retorno
				CHAR(20),--cuenta_eje
				CHAR(20),--cuenta_sd
				CHAR(18),--nombre_sd
				CHAR(2), --icono
				CHAR(2); --color
		   
    DEFINE iIsamErr,vProducto,vEst_sd,vCant_sd SMALLINT;
	
	DEFINE vsqlerr          	INTEGER;
    DEFINE cErrorInfo       	CHAR(80);
	DEFINE vErrorInfo       	CHAR(80);
    DEFINE vCodRet         		CHAR(5);
	DEFINE vCuenta_sd			CHAR(20);
	DEFINE vNombre_sd			CHAR(18);
	DEFINE vNombreT_sd			CHAR(18);
	DEFINE vIcono				CHAR(2);
	DEFINE vColor				CHAR(2);
	DEFINE vCuenta_eje			CHAR(20);
	DEFINE vEst_cta				CHAR(1);

	
	LET vsqlerr					= 0; 
    LET iIsamErr				= 0;
    LET cErrorInfo				= '';   
	LET vErrorInfo        		= 'INICIO DEL PROCESO';
	LET vCodRet					= '00000';
	LET vNombre_sd				= '';
	LET vIcono					= '';
	LET vColor					= '';
	LET vProducto				= 0;
	LET vEst_cta				= '';
	LET vEst_sd					= 0;
	LET vCant_sd				= 0;
	LET vCuenta_sd				= TRIM(NVL(pCuenta_sd,''));
	LET vCuenta_eje            	= TRIM(NVL(pCuenta_eje,''));
	LET vNombreT_sd				= TRIM(NVL(pNombre_sd,''));
	LET pIcono					= TRIM(NVL(pIcono,''));
	LET pColor					= TRIM(NVL(pColor,''));
	
	BEGIN
		ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
			IF vsqlerr != 0 THEN
				--SET DEBUG FILE TO "/informix/c90186322/trace/sp_perso_sd_err.txt";
				--TRACE ON;
				LET vCodRet    = vsqlerr;
				LET vErrorInfo = cErrorInfo;
				LET vCuenta_eje= pCuenta_eje;
				RETURN vCodRet,vCuenta_eje,vCuenta_sd,vNombre_sd,vIcono,vColor;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/informix/c90186322/trace/sp_perso_sd.txt';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3; 
		
		--SE VALIDA QUE LA CUENTA EJE NO VENGA VACIO O NULO
		IF  vCuenta_eje = '' THEN
			LET  vCodRet='00001';			RETURN vCodRet,vCuenta_eje,vCuenta_sd,vNombre_sd,vIcono,vColor;
		END IF;
		
		
		--SE OPTIENE LOS VALORES DE LA CUENTA EJE	
		SELECT producto,  status_cta
		INTO   vProducto, vEst_cta
		FROM   "informix".sc_maechq
		WHERE  cuenta = pCuenta_eje;
			
		LET vEst_cta = TRIM(NVL(vEst_cta,''));
		LET vProducto = TRIM(NVL(vProducto,''));
				
			--SE VALIDA EL ESTATUS DE LA CUENTA QUE SEA ACTIVO
		IF vEst_cta <>  '1' THEN
			LET  vCodRet='00002';			RETURN vCodRet,vCuenta_eje,vCuenta_sd,vNombre_sd,vIcono,vColor;
		END IF;
		
		--SE VALIDA QUE EL PRODUCTO DE LA CUENTA EJE SEA VALIDO AL CATALOGO
		IF vProducto NOT IN (SELECT producto FROM sc_prodis_sd) THEN
			LET  vCodRet='00003';			RETURN vCodRet,vCuenta_eje,vCuenta_sd,vNombre_sd,vIcono,vColor;
		END IF;
		
		IF NOT EXISTS (SELECT 1 FROM "informix".sc_mae_sd WHERE cuenta_sd = pCuenta_sd AND cuenta_eje = pCuenta_eje AND estatus in (1,3)) THEN
			LET vCodRet='00010';			RETURN vCodRet,vCuenta_eje,vCuenta_sd,vNombre_sd,vIcono,vColor;
		END IF
		
		IF NOT EXISTS (SELECT 1 FROM "informix".sc_ico_sd WHERE id = pIcono)  THEN
			LET  vCodRet='00005';			RETURN vCodRet,vCuenta_eje,vCuenta_sd,vNombre_sd,'','';
		END IF;
		
		IF NOT EXISTS (SELECT 1 FROM "informix".sc_col_sd WHERE id = pColor) THEN
			LET  vCodRet='00006';			RETURN vCodRet,vCuenta_eje,vCuenta_sd,vNombre_sd,'','';
		END IF;
		
		--Actualiza los datos del sobre y valida que no venga vacio
		IF vNombreT_sd = '' THEN
			SELECT nombre_sd
			INTO vNombreT_sd
			FROM "informix".sc_mae_sd
			WHERE cuenta_sd = pCuenta_sd;
		END IF;

		UPDATE "informix".sc_mae_sd
		SET icono = pIcono,
			color = pColor,
			nombre_sd = vNombreT_sd
		WHERE cuenta_sd = pCuenta_sd;
		
		RETURN vCodRet,pCuenta_eje,pCuenta_sd,vNombreT_sd,pIcono,pColor;			
		
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: SE MODIFICA PROCEDIMIENTO PARA AGREGAR ESTATUS 3 DE FINALIZADO CUANDO SE CONSULTAN LOS APARTADOS POR CUENTA DE CAPTACION',
'AUTOR : 95358897 - ISARAI BOJORQUEZ',
'FECHA : 07/02/2023',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_valferiadobanca_exp(pEmpresa 	  		CHAR(3),
											   pPriDiaNaturalMes	DATE,
											   pDiasBloque       	INT,
											   pOperacion			CHAR(1))
RETURNING
    VARCHAR(5),         -- CodigoRetorno
    DATE;               -- Fecha Habil del bloque

DEFINE cVarDataErr      	VARCHAR(64);
DEFINE iSqlErr          	INTEGER;
DEFINE iSamErr          	INTEGER;
DEFINE cCodRet          	CHAR(5);
DEFINE dFechaActual        	DATE;
DEFINE i              		INTEGER;
DEFINE j              		INTEGER;
DEFINE siFeriado        	INTEGER;
DEFINE cRespSP  			CHAR(5);
DEFINE dFechaSp 			DATE;
DEFINE sRetCodSP 			CHAR(5);
DEFINE dFechaReSp 			DATE;
DEFINE cDia 				CHAR(2);
DEFINE cMes 				CHAR(2);
DEFINE cAnio 				CHAR(4);
DEFINE cFechaFormat			CHAR(8);
DEFINE cFechaDiaLEN 		INTEGER;
DEFINE cFechaMesLEN 		INTEGER;
DEFINE cFechaAnioLEN 		INTEGER;


LET cCodRet					= '00000';
LET dFechaActual			= '';
LET cRespSP 				= '';
LET sRetCodSP 				= '';
LET cDia 					= '';
LET cMes 					= '';
LET cAnio 					= '';
LET siFeriado				= 0;
LET i 						= 0;
LET j 						= 0;	
LET cvardataerr				= '';	
LET cFechaFormat			= '';		

	--SET debug FILE TO "/tmp/domi/sp_valferiadobanca.out";
	--TRACE ON;
	
BEGIN
    ON EXCEPTION
        SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodret=iSqlErr;
            RETURN cCodret,dFechaActual;
        END IF;
    END EXCEPTION;

	IF pOperacion = 'V' OR pDiasBloque = 0 THEN
		LET dFechaActual = pPriDiaNaturalMes; 
		
		IF (WEEKDAY(dFechaActual) >= 1 AND WEEKDAY(dFechaActual) <= 5) then
			SELECT COUNT(*) 
				INTO siFeriado       
			FROM bdinteg:si_feriado_banca
			WHERE fecha = dFechaActual
				AND pais = pEmpresa and laborable = "N";
			
			IF NOT siFeriado IS NULL AND siFeriado <> 0 THEN
				LET dFechaActual = '';
				LET cCodRet = "00008";			
			END IF;	
		ELSE
			LET dFechaActual = '';
			LET cCodRet = "00009";
		END IF;

	-- Se valida si la operacion elegida fue la suma de dias
	ELIF pOperacion = 'S' THEN
		WHILE i <= pDiasBloque 
			LET dFechaActual = pPriDiaNaturalMes + j;
			LET siFeriado = 0;
			--Valida los fines de semana.
			IF (WEEKDAY(dFechaActual) >= 1 AND WEEKDAY(dFechaActual) <= 5) then
				--Consulta si el dia es feria para la banca
				SELECT COUNT(*) 
					INTO siFeriado       
				FROM bdinteg:si_feriado_banca
				WHERE fecha = dFechaActual
					AND pais = pEmpresa and laborable = "N";
				--Si no es feriado aumenta el contador del ciclo
				IF siFeriado IS NULL OR siFeriado = 0 THEN
					LET i = i + 1;
				END IF;
			END IF;
			LET j = j + 1;
		END WHILE
	-- Se valida si la operacion elegida fue la resta de dias
	ELIF pOperacion = 'R' THEN
		WHILE i <= pDiasBloque
			LET dFechaActual = pPriDiaNaturalMes;
			LET dFechaActual = pPriDiaNaturalMes + j UNITS DAY;
			LET siFeriado = 0;
			--Valida los fines de semana.
			IF (WEEKDAY(dFechaActual) >= 1 AND WEEKDAY(dFechaActual) <= 5) then
				--Consulta si el dia es feria para la banca
				SELECT COUNT(*) 
					INTO siFeriado       
				FROM bdinteg:si_feriado_banca
				WHERE fecha = dFechaActual
					AND pais = pEmpresa and laborable = "N";
				 --Si no es feriado aumenta el contador del ciclo
				IF siFeriado IS NULL OR siFeriado = 0 THEN
					LET i = i + 1;
				END IF;
			END IF;
			LET j = j - 1;
		END WHILE
	ELSE
		--Si la operacion elegida fue distinta a "S" SUMA, "R" RESTA ó "V" Validacion de la fecha recibida.
		LET cCodRet = "00010";
	END IF;
	
   RETURN cCodRet,dFechaActual;
END
END PROCEDURE
DOCUMENT
'AUTOR : Antonio Bastidas',
'DESCRIPCION: Valida la cadena de fecha, con base a los dias de bloque y la operacion "S" = SUMA, "R"= RESTA',
' determina la fecha proxima segun el catalogo si_feriado_banca y tambien excluyendo los fines de semana.',
'FECHA : 21/04/2010',
'BD    : BDIDOMI',
'VER   : 20100422.0906';

Create Procedure "informix".sp_generaarchivocuentasnomina_exp()
Returning Char(3), Char(18);
    
    Define siMes            Smallint ;
    Define siYear           Integer ;
    Define siDia            Smallint ;
    Define cCodRet          Char(3);
    Define cCodRet2         Char(5);
    Define cCodRet3         Char(50);
    Define dFechaActual     Date ;
    Define cSQL             Char(600);    
    Define cDirectorio      Char(100);
    Define cEmpresa         Char(3);
    Define cNombreArchivo   Char(18);
    Define cMes             Char(2);
    Define cDia             Char(2);
    Define dFechaAnterior   Date;
    Define v_iSqlErr        Integer;
    Define v_iSamErr        Integer;
    Define v_cDesErr        Char(50);
    Define bGrupCop         Integer;
	DEFINE cHoraAplicado    DateTime Hour to Second;
    
    Let siMes          = 0;
    Let siYear         = 0;
    Let siDia          = 0;
    LET cCodRet        = '';
    LET cCodRet2       = '';
    LET cCodRet3       = '';
    Let cDirectorio    = "";
    Let cSQL           = "";
    Let dFechaActual   = '';
    Let cEmpresa       = '';
    Let cNombreArchivo = '';
    Let cMes           = '';
    Let cDia           = '';
    Let dFechaAnterior = '';
    Let v_iSqlErr      = 0;
    Let v_iSamErr      = 0;
    LET v_cDesErr      = '';
    Let bGrupCop       = 0;
	LET cHoraAplicado  = current;
    
    --- Set debug file to "/tmp/sp_generaarchivocuentasnomina.out";
    --- Trace on;
    
    Begin
    
    -- // Controla algun posible error del procedimiento.
    ON EXCEPTION SET v_iSqlErr, v_iSamErr, v_cDesErr
        Set debug file to "/tmp/sp_generaarchivocuentasnomina.err";
        Trace on;
        IF v_iSqlErr <> 0 THEN
            LET cCodRet  = v_iSqlErr;
            LET cCodRet2 = v_iSamErr;
            LET cCodRet3 = v_cDesErr;
            RETURN cCodRet, cNombreArchivo;
        END IF;
    END EXCEPTION
    
	-- // Truncar tabla donde se guarda el nombre de archivo
	TRUNCATE TABLE bdicheq:sc_nominaresultadoscuentasnomina;
	
    -- // Realiza una consulta a la tabla de fechas donde saca los valores de fechas y los inserta en las variables.
    Select Year(fecha_hoy), Month(fecha_hoy), Day(fecha_hoy), fecha_hoy, fecha_hoy - Day(20)
      Into siYear, siMes, siDia, dFechaActual, dFechaAnterior
      From bdicheq:sc_fechas
     Where empresa = "001";
    
    -- // Saca las altasnuevas segun el rango de fechas  y las inserta en la tabla sc_nominarelacionnuevascuentas.
    Insert Into bdicheq:sc_nominarelacionnuevascuentas
    ( empresa, numero_empleado, numero_cuenta, apell_paterno, apell_materno, nombre1, nombre2, rfc, num_tarjeta, cta_clabe )
    Select lpad(pf.numeric1,3,"0"), pf.numeric2, noc.cuenta, cte.apell_paterno, cte.apell_materno, cte.nombre1, cte.nombre2, cte.rfc, tar.num_tarjeta, chq.cuenta_clabe
      From bdicheq:sc_maenoc as noc
     Inner Join bdicheq:sc_maechq as chq On ( chq.cuenta = noc.cuenta )
     Inner Join bdinteg:si_ctepf as pf On ( chq.num_cte = pf.numcte )
     Inner Join bdinteg:si_cliente as cte On ( chq.num_cte = cte.numcte )
      Left Outer Join bdicheq:sc_tarjeta as tar On ( chq.num_cte = tar.numcte and chq.cuenta = tar.cuenta and tar.Status_tar = 'A' and tar.tipo_tarjeta = 'T' )
	  Left Outer Join intercard:tarjeta as card On ( tar.num_tarjeta = card.numtarjeta )
     Where chq.empresa = '001'
       And chq.status_cta = '1'
       And ( ( noc.fecha_alta >= dFechaAnterior And noc.fecha_alta < dFechaActual ) OR 
             ( card.fechaasignacion::date >= dFechaAnterior AND card.fechaasignacion::date < dFechaActual ) ) 
       And chq.producto in('1300','1700');
    
    -- // Valida si existen altas nuevas
    If Exists ( Select empresa From bdicheq:sc_nominarelacionnuevascuentas ) Then
        -- // Si existen altas nuevas las guarda de manera historica en sc_nominarelacionnuevascuentashis.
        Insert Into bdicheq:sc_nominarelacionnuevascuentashis
        ( empresa, numero_empleado, numero_cuenta, fecha_insercion, apell_paterno, apell_materno, nombre1, nombre2, rfc, num_tarjeta, cta_clabe )
        Select empresa, numero_empleado, numero_cuenta, date(current), apell_paterno, apell_materno, nombre1, nombre2, rfc, num_tarjeta, cta_clabe
          From bdicheq:sc_nominarelacionnuevascuentas;
        
        -- // Inicializa el codigo de retorno.
        Let cCodRet = '000';		
        Let cMes = LPAD(siMes,2,"0");
        Let cDia = LPAD(siDia,2,"0");
        Let cDirectorio = "/tmp/traspasobanco/archivosnomina/conciliacion/originales/altasnuevas.unl";
            
        -- // Entra a un ciclo foreach en donde el primer select separa las distintas empresas existentes.
        ForEach
            Select Distinct(empresa) 
              Into cEmpresa 
              From bdicheq:sc_nominarelacionnuevascuentas 
             Where empresa::integer > 10
            
            -- // Se genera el nombre del archivo lo compone la empresa, el a?o, mes, dia y un folio (01).			
            Let cNombreArchivo = Trim(cEmpresa)||siYear||cMes||cDia||"01"||".dat";          
            
            -- // Le agrega la "N" al nombre y le asigna un direntorio.
            Let cNombreArchivo = "N" || Trim(cNombreArchivo);			
            
            -- // Crea y le da contenido al archivo query.sql						
            Let cSQL = '';
            Let cSQL = 'echo "UNLOAD TO '||cDirectorio||' '||
                       'Select empresa, numero_empleado, numero_cuenta, apell_paterno, apell_materno, nombre1, nombre2, rfc, num_tarjeta, cta_clabe '||
                       'From bdicheq:sc_nominarelacionnuevascuentas '||
                       'Where empresa = '||cEmpresa||';" > /tmp/query_nomaltas.sql';
            System cSQL;	
            
            -- // IMPORTANTE: Favor de adaptar este directorio en base al funcionamiento de produccion.
            Let cSQL = ''; 	
            Let cSQL = "/ifxsif01/bin/dbaccess bdicheq /tmp/query_nomaltas.sql";        --- PRODUCCION
			--- Let cSQL = "/informix/bin/dbaccess bdicheq /tmp/query_nomaltas.sql";    --- DESARROLLO
            System cSQL;
            
            -- // Le quita el ultimo | al archivo altasnuevas.unl y se renombra con estandar de nombres
            LET cSql = "sed 's/|$//g' /tmp/traspasobanco/archivosnomina/conciliacion/originales/altasnuevas.unl > " ||
                       "/tmp/traspasobanco/archivosnomina/conciliacion/originales/"||cNombreArchivo;
			--- Let cSql = TRIM(cSql);
            SYSTEM cSql;		
        End ForEach
		
        IF ( cNombreArchivo != '' ) THEN
            INSERT INTO bdicheq:sc_nominaresultadoscuentasnomina
            ( nombre_archivo, hora_aplicado ) 
            VALUES
            ( cNombreArchivo||'.asc', cHoraAplicado );
        END IF;
            
        Let cNombreArchivo = '';
        
        If Exists ( Select empresa From bdicheq:sc_nominarelacionnuevascuentas Where empresa::integer <= 10 ) Then
            -- // Se genera el nombre del archivo lo compone la empresa, el a?o, mes, dia y un folio (01).			
            Let cNombreArchivo = 'N001'||siYear||cMes||cDia||"01"||".dat";          	

            -- // Crea y le da contenido al archivo query.sql						
            Let cSQL = '';
            Let cSQL = 'echo "UNLOAD TO '||cDirectorio||' '||
                       'Select empresa, numero_empleado, numero_cuenta, apell_paterno, apell_materno, nombre1, nombre2, rfc, num_tarjeta, cta_clabe '||
                       'From bdicheq:sc_nominarelacionnuevascuentas '||
                       'Where empresa::integer <= 10; " > /tmp/query_nomaltas.sql';
            System cSQL;	
            
            -- // IMPORTANTE: Favor de adaptar este directorio en base al funcionamiento de produccion.
            Let cSQL = ''; 	
            Let cSQL = "/ifxsif01/bin/dbaccess bdicheq /tmp/query_nomaltas.sql";        --- PRODUCCION
			--- Let cSQL = "/informix/bin/dbaccess bdicheq /tmp/query_nomaltas.sql";    --- DESARROLLO
            System cSQL;
            
            -- // Le quita el ultimo | al archivo altasnuevas.unl y se renombra con estandar de nombres
            LET cSql = "sed 's/|$//g' /tmp/traspasobanco/archivosnomina/conciliacion/originales/altasnuevas.unl > " ||
                       "/tmp/traspasobanco/archivosnomina/conciliacion/originales/"||cNombreArchivo;
            SYSTEM cSql;			
        End IF;				
    Else
        -- // NO EXISTEN DATOS NUEVOS
        Let cCodRet = "100";
    End If
    
	-- // Insertar en la tabla el nombre del archivo generado 
	IF ( cNombreArchivo != '' ) THEN
        INSERT INTO bdicheq:sc_nominaresultadoscuentasnomina 
        ( nombre_archivo, hora_aplicado ) 
        VALUES
        ( cNombreArchivo||'.asc', cHoraAplicado );
	END IF;
	
    -- // Borra las altas nuevas y deja la tabla disponible para el proximo llamado
    Delete From bdicheq:sc_nominarelacionnuevascuentas;
    
    -- // Regresa el valor del codigo de retorno al usuario.
    Return cCodRet, cNombreArchivo;
    
    End
        
End Procedure
    
DOCUMENT
'CAMBIO : Jesus Antonio Bastidas Lopez',
'DESCRIPCION: Se alter? la estructura de la tabla para generar el archivo con el nombre del cliente y rfc',
'Solicito: Jose Mendoza, Delia Borboa',
'FECHA : 23 de Abril de 2009',
'VERSION:20090423.1052',

'CAMBIO : César Valdéz Figueroa',
'DESCRIPCION: Se altero la estructura de las tablas sc_nominarelacionnuevascuentas y la sc_nominarelacionnuevascuentashis para generar el',
'             campo Num_tarjeta, ademas de modificar el select principal para que filtrara por la tarjeta titular del cliente con estado activo',
'FECHA : 02 de Noviembre de 2009',
'VERSION:20091106.1000',

'CAMBIO : Selene Campos',
'DESCRIPCION: Se modificó para insertar el nombre del archivo en la tabla sc_nominaresultadoscuentasnomina',
'FECHA : 28 de Agosto de 2014',

'CAMBIO : Jorge Ivan Camacho Sanchez',
'DESCRIPCION: Se modificó para obtener la cuenta clabe',
'FECHA : 04 de Abril de 2023';

CREATE PROCEDURE "informix".sp_ws_coppel_bcpl_tar2( pcAgent_trans_type_code CHAR(10),
											  pcAgent_cd CHAR(3),
											  pcUsuario CHAR(8),
											  pcPassword CHAR(8),
											  pcIp_origen CHAR(15),
											  pcSession_id CHAR(30),
											  pcFecha_peticion CHAR(8),
											  pcHora_peticion CHAR(6),
											  pcTipoEje CHAR(1),
											  pcNumCteNumTar CHAR(20) )

RETURNING
 CHAR(5) AS ccCodRetorno,
 CHAR(4)  AS cCodRet,
 CHAR(100) AS mensaje,
 CHAR(8)  AS cFecha_proceso,
 CHAR(6)  AS cHora_proceso,
 CHAR(20) AS ClienteBancoppel,
 CHAR(20) AS ClienteCoppel,
 CHAR(20) AS NumTarjeta,
 CHAR(10) AS FechaAsignacion,
 CHAR(1)  AS EstatusTarjeta,
 CHAR(1)  AS IndicadorTarjeta;

	--VARIABLES DE RETORNO
	DEFINE ccCodRetorno 			CHAR(5);
	DEFINE cCodRet					CHAR(4);
	DEFINE mensaje					CHAR(100);
	DEFINE cFecha_proceso 			CHAR(8);
	DEFINE cHora_proceso 			CHAR(6);
	DEFINE cOpcode 					CHAR(4);
	DEFINE cDescr_completa_mensaje 	CHAR(100);
	DEFINE cNombre_proceso			CHAR(17);
	DEFINE cCadena_ent				CHAR(100);

	DEFINE cCodigoError 			CHAR(5);
	DEFINE cDescripcion 			CHAR(40);
	DEFINE cClienteBancoppel 		CHAR(20);
	DEFINE cClienteCoppel 			CHAR(20);
	DEFINE cNumTarjeta 				CHAR(20);
	DEFINE cFechaAsignacion 		CHAR(20);
	DEFINE cEstatusTarjeta 			CHAR(1);
	DEFINE cIndicadorTarjeta 		CHAR(1);
	DEFINE iContador 				INTEGER;
	DEFINE cNumTarjetas 			CHAR(20); --Variable Nueva
	DEFINE cReturnProc				CHAR(3);

	--VARIABLES DE CONTROL DE ERRORES
	DEFINE	iSqlErr 				INTEGER;
	DEFINE	iIsamErr				INTEGER;
	DEFINE	vErrorInfo				VARCHAR(80);
	DEFINE  iIsamError 				INTEGER;

	---INICIALIZAR VARIABLES
	LET ccCodRetorno  				= '00000';
	LET cCodRet 					= '0000';
	LET mensaje 					= 'Consulta Exitosa';
	LET cFecha_proceso 				= TRIM(YEAR(CURRENT::DATE) || LPAD(MONTH(CURRENT::DATE),2,'0') || LPAD(DAY(CURRENT::DATE),2,'0'));
	LET cHora_proceso				= REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
	LET cOpcode 					= '0000';
	LET cDescr_completa_mensaje 	= 'Consulta Exitosa.';
	LET cNombre_proceso				= 'sp_ws_coppel_bcpl_tar2';
	LET cCadena_ent 				= TRIM(NVL(pcAgent_trans_type_code,'NULL')) || '|' || TRIM(NVL(pcAgent_cd,'NULL')) || '|' || TRIM(NVL(pcUsuario,'NULL')) || '|' || TRIM(NVL(pcIp_origen,'NULL'));

	LET iIsamError = 0;

	LET cCodigoError 		= "00000";
	LET cDescripcion 		= "CONSULTA EXITOSA";
	LET cClienteCoppel 		= "";
	LET cClienteBancoppel 	= "";
	LET cNumTarjeta 		= "";
	LET cFechaAsignacion 	= "";
	LET cEstatusTarjeta 	= "";
	LET cIndicadorTarjeta 	= "";
	LET iSqlErr 			= 0;
	LET iContador 			= 0;
	LET cNumTarjetas        = "";
	LET cReturnProc  		= "";

	--SET DEBUG FILE TO '/home/sysifx/respaldosbd/Adrian/577/sp_ws_coppel_bcpl_tar2.out';
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, vErrorInfo
			IF iSqlErr <> 0 OR iIsamErr <> 0 THEN
				IF iSqlErr = '-1213' THEN
					LET cCodRet = '0001';
					LET cOpcode = cCodRet;
					
					SELECT NVL(opcode, ''),NVL(opcode_sd, ''),NVL(opcode_ds, '')
					INTO cOpcode,mensaje,cDescr_completa_mensaje
					FROM bdisac:"informix".sac_ws_catmensajes
					WHERE agent_trans_type_code = pcAgent_trans_type_code AND opcode = cCodRet;
					
					EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_proceso, cCodRet, mensaje, '', '', cCadena_ent, pcUsuario,cFecha_proceso,cHora_proceso)
					INTO ccCodRetorno;
					
					IF cOpcode IS NULL THEN
						LET cOpcode = cCodRet;
						LET mensaje = 'Codigo no registrado en catalogo.';
						LET cDescr_completa_mensaje = 'Codigo no registrado en catalogo.';
					END IF;
				ELSE
					LET cCodRet = iSqlErr;
					LET cOpcode = cCodRet;
					LET mensaje = '';
					LET cDescr_completa_mensaje = '';
					
					--Se inserta el error generado en la tabla sac_ws_errores Y Se actualiza la tabla sac_ws_procesos con el codigo de error generado
					EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_proceso, cCodRet, mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario,cFecha_proceso,cHora_proceso)
					INTO ccCodRetorno;
				END IF;
				
				INSERT INTO bdicheq:"informix".sc_ws_coppel_bcpl_tar(agent_cd, user_request, password, ip_origen, id_sesion, date_request, time_request, numcte_numtar, cod_error, descr_message, cte_ban, cte_cop, num_tarjeta, fecha_asi, estatus_tar, ind_tar, datetimeinsert)
				VALUES(pcAgent_cd, pcUsuario, pcPassword, pcIp_origen, pcSession_id, pcFecha_peticion, pcHora_peticion, pcNumCteNumTar, cCodRet, mensaje, cClienteBancoppel, cClienteCoppel, cNumTarjeta, cFechaAsignacion, cEstatusTarjeta, cIndicadorTarjeta, CURRENT);
				
				DROP TABLE IF EXISTS tmp_si_clientetarjetas;
				
				--RETURN cCodRet, mensaje, cClienteBancoppel, cClienteCoppel, cNumTarjeta, cFechaAsignacion, cEstatusTarjeta, cIndicadorTarjeta;
				RETURN cCodRet, cOpcode, cDescr_completa_mensaje, cFecha_proceso, cHora_proceso, cClienteBancoppel, cClienteCoppel, cNumTarjeta, cFechaAsignacion, cEstatusTarjeta, cIndicadorTarjeta;
			END IF;
		END EXCEPTION;

		-- VALIDACION DE PARAMETROS
		IF  NVL(pcAgent_cd,'?') <> 'TDA' OR NVL(pcAgent_trans_type_code,'?') <> 'BCPL_TAR2' OR NVL(pcUsuario,'?')= '?'
			OR NVL(pcPassword,'?')= '?' OR NVL(pcFecha_peticion,'?')= '?' OR NVL(pcHora_peticion,'?')= '?'
			OR NVL(pcIp_origen,'')= '' OR NVL(pcSession_id,'')=''
			OR NVL(pcTipoEje,'?')= '?' OR NVL(pcNumCteNumTar,'?')= '?' THEN
			
			LET cCodRet ='9996';
		ELSE
			EXECUTE PROCEDURE bdisac:"informix".sp_valida_session(pcAgent_trans_type_code, pcAgent_cd, pcUsuario, pcPassword, pcIp_origen, pcSession_id)
			INTO cCodRet, mensaje;

			IF cCodRet = '0000' THEN
				IF( pcTipoEje IN( 1, 2 ) AND pcNumCteNumTar != '' ) THEN
						SET LOCK MODE TO WAIT 3;
						SET ISOLATION TO DIRTY READ;

						DROP TABLE IF EXISTS tmp_si_clientetarjetas;
						DROP TABLE IF EXISTS tmp_si_tarjetas;
						
						LET pcNumCteNumTar = TRIM( pcNumCteNumTar );

						IF TRIM( NVL(pcTipoEje, "") ) = "1" THEN

							SELECT a.numcte AS numctebancoppel, {+INDEX (bdinteg:"informix".idx_numcte_ref)} a.numcte_ref AS numctecoppel, b.numtarjeta, NVL( SUBSTR( DATE( b.fechaasignacion ), 1, 10), '1900-01-01' ) AS fechaasignacion, SPACE(1) AS statustarjeta, 'D' AS indicadortarjeta
							FROM bdinteg:"informix".si_cliente a JOIN intercard:"informix".tarjeta b
							ON a.numcte = b.numcliente
							JOIN bdicheq:"informix".sc_tarjeta c
							ON b.numtarjeta = c.num_tarjeta
							WHERE a.numcte_ref = pcNumCteNumTar
							AND c.status_tar = 'A'
							AND a.empresa = '001'
							INTO TEMP tmp_si_clientetarjetas with no log;

						ELSE

							SELECT a.numcte AS numctebancoppel, a.numcte_ref AS numctecoppel, {+INDEX (intercard:tarjeta idx_tarjeta1)} b.numtarjeta AS numtarjeta, NVL( SUBSTR( DATE( b.fechaasignacion ), 1, 10), '1900-01-01' ) AS fechaasignacion, c.status_tar AS statustarjeta, c.tipo_tarjeta AS indicadortarjeta
							FROM bdinteg:"informix".si_cliente a JOIN intercard:"informix".tarjeta b
							ON a.numcte = b.numcliente
							JOIN bdicheq:"informix".sc_tarjeta c
							ON b.numtarjeta = c.num_tarjeta
							WHERE b.numtarjeta = pcNumCteNumTar
							AND a.empresa = '001'
							INTO TEMP tmp_si_clientetarjetas with no log;

						END IF;

						CREATE TEMP TABLE tmp_si_tarjetas(numtarj VARCHAR(16)) WITH NO LOG;

						SELECT FIRST 1 numctebancoppel
						INTO cClienteBancoppel
						FROM tmp_si_clientetarjetas;

						FOREACH
							EXECUTE PROCEDURE bditrapres:"informix".sp_consulta_tarjetas_dep(cClienteBancoppel) INTO cReturnProc, cNumTarjetas
							INSERT INTO tmp_si_tarjetas(numtarj) VALUES(cNumTarjetas);
						END FOREACH;

						FOREACH sal_cursor FOR
							SELECT numctebancoppel, numctecoppel, numtarjeta, fechaasignacion, statustarjeta, indicadortarjeta
							INTO cClienteBancoppel, cClienteCoppel, cNumTarjeta, cFechaAsignacion, cEstatusTarjeta, cindicadorTarjeta
							FROM tmp_si_clientetarjetas a JOIN tmp_si_tarjetas c
							ON a.numtarjeta = c.numtarj

							LET iContador = iContador + 1;

							--RETURN cCodigoError, cDescripcion, cClienteBancoppel, cClienteCoppel, cNumTarjeta, cFechaAsignacion, cEstatusTarjeta, cIndicadorTarjeta WITH RESUME;
							RETURN cCodRet, cOpcode, cDescr_completa_mensaje, cFecha_proceso, cHora_proceso, cClienteBancoppel, cClienteCoppel, cNumTarjeta, cFechaAsignacion, cEstatusTarjeta, cIndicadorTarjeta WITH RESUME;

						END FOREACH;
				END IF;
			END IF;
		END IF;

		DROP TABLE IF EXISTS tmp_si_clientetarjetas;
		DROP TABLE IF EXISTS tmp_si_tarjetas;

		IF cCodRet <> '0000' THEN
			--Se obtienen los mensajes de error asi como el codigo del mensaje
			SELECT NVL(opcode, ''),NVL(opcode_sd, ''),NVL(opcode_ds, '')
			INTO cOpcode,mensaje,cDescr_completa_mensaje
			FROM bdisac:"informix".sac_ws_catmensajes WHERE agent_trans_type_code = pcAgent_trans_type_code AND opcode = cCodRet;

			--En caso de que no exista el codigo del mensaje se les asigna otros valores
			IF cOpcode IS NULL THEN
				LET cOpcode = cCodRet;
				LET mensaje = 'Codigo no registrado en catalogo.';
				LET	cDescr_completa_mensaje = 'Codigo no registrado en catalogo.';
			END IF;

			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_proceso,cCodRet, mensaje, '', '', cCadena_ent, pcUsuario,cFecha_proceso,cHora_proceso)
			INTO ccCodRetorno;

		END IF;

		INSERT INTO bdicheq:"informix".sc_ws_coppel_bcpl_tar(agent_cd, user_request, password, ip_origen, id_sesion, date_request, time_request, numcte_numtar, cod_error, descr_message, cte_ban, cte_cop, num_tarjeta, fecha_asi, estatus_tar, ind_tar, datetimeinsert)
		VALUES(pcAgent_cd, pcUsuario, pcPassword, pcIp_origen, pcSession_id, pcFecha_peticion, pcHora_peticion, pcNumCteNumTar, cCodRet, cDescr_completa_mensaje, cClienteBancoppel, cClienteCoppel, cNumTarjeta, cFechaAsignacion, cEstatusTarjeta, cIndicadorTarjeta, CURRENT);

		IF  iContador = 0 THEN
			RETURN cCodRet, cOpcode, cDescr_completa_mensaje, cFecha_proceso, cHora_proceso, cClienteBancoppel, cClienteCoppel, cNumTarjeta, cFechaAsignacion, cEstatusTarjeta, cIndicadorTarjeta;
		END IF;

	END
END PROCEDURE;