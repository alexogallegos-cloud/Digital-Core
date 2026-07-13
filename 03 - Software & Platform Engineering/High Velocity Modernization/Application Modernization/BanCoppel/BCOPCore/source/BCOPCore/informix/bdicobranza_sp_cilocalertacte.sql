CREATE PROCEDURE "informix".sp_cilocalertacte(pNumCte CHAR(20) ,pSucursal CHAR(4), pOrigen INTEGER,pTpoDir CHAR(1))
RETURNING CHAR(5) AS CODIGORET1,CHAR(5) AS CODIGOret2;
				
--Declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			                INTEGER;
DEFINE isam_err 		                INTEGER;
DEFINE error_info		                CHAR(80);
DEFINE cCod_ret1                        CHAR(5);
DEFINE cCod_ret2                        CHAR(5);
DEFINE cSucursal						CHAR(4);
DEFINE iContador						INTEGER;
DEFINE vCont							INTEGER;
DEFINE iNumalerta						INTEGER;
DEFINE dtFecha							DATE;
DEFINE dtFechaActual					DATE;
DEFINE cSituacionEsp					CHAR(1);
DEFINE iCausa							SMALLINT;
DEFINE cAaccionOrigen					CHAR(4);
DEFINE cNumcte							CHAR(20);
DEFINE cMotivoDesmarcaje				CHAR(100);


-----------------------------------------------------
LET cCod_ret1  = '00000';
LET cCod_ret2  = '00000';
LET sql_err   = 0;
LET iContador = 0;
LET vCont = 0;
LET iNumalerta = 0;
LET cSituacionEsp='';
LET iCausa = 0;
LET cAaccionOrigen = '';
LET cMotivoDesmarcaje = '';


  BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
		LET cCod_ret1 = sql_err;
		RETURN cCod_ret1,cCod_ret2;					
	END EXCEPTION;

	--SET DEBUG FILE TO "/home/sysifx/jesusm/sp_CiLocAlertaCte.out";
	--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
	
	IF pNumCte = ' ' OR pNumCte IS NULL THEN
		--numero de cliente invalido
		LET cCod_ret2 = '00001';
		RETURN cCod_ret1,cCod_ret2;	
	END IF
	
	SELECT numcte
	INTO cNumcte
    FROM bdinteg:si_cliente  
	WHERE numcte= pNumCte;
	
	LET vCont = dbinfo("sqlca.sqlerrd2");
	IF vCont = 0 THEN
	--indica  que el numero de cliente no existe
		LET cCod_ret2 = '00002';
		RETURN cCod_ret1,cCod_ret2;	
	END IF;
	
	IF pSucursal = '' OR pSucursal IS NULL THEN
		--numero de sucursal invalido
		LET cCod_ret2 = '00003';
		RETURN cCod_ret1,cCod_ret2;	
	END IF
	
	SELECT sucursal
	INTO cSucursal
    FROM bdinteg:si_sucursales  
	WHERE sucursal= pSucursal;
	
	LET vCont = dbinfo("sqlca.sqlerrd2");
	IF vCont = 0 THEN
	--indica  que el numero de sucursal no existe
		LET cCod_ret2 = '00004';
		RETURN cCod_ret1,cCod_ret2;	
	END IF;
	--Se realiza cambio para contemplar las nuevas definiciones del cliente sobre el origen.
	--solo se aceptan como datos de entrada para el dato origen  1 = CC, 2 = OFI,  3 = CAT, 4=WEB, 5=SIF
	IF pOrigen=1 THEN
		LET cAaccionOrigen='CC';
	ELIF pOrigen=2 THEN
		LET cAaccionOrigen='OFI';
	ELIF pOrigen=3 THEN
		LET cAaccionOrigen='CAT';
	ELIF pOrigen=4 THEN
		LET cAaccionOrigen='WEB';
	ELIF pOrigen=5 THEN
		LET cAaccionOrigen='SIF';
	ELSE
	--origen invalido 
		LET cCod_ret2 = '00005';
		RETURN cCod_ret1,cCod_ret2;		
	END IF;
	
	SELECT fecha_hoy 
      INTO dtFechaActual
      FROM bdicred:sd_fechas;
	
	LET vCont = 0; 

	SELECT situacion, causa, fchalta::DATE,NVL(motivo_desmarcaje,'')
	INTO cSituacionEsp, iCausa,dtFecha,cMotivoDesmarcaje
	FROM bdisitesp:se_ctessitespcte 
	WHERE  numcte=pNumcte
	AND situacion ='L'
	AND idmovto = ( SELECT MAX(idmovto )
                                FROM bdisitesp:se_ctessitespcte 
                                WHERE  numcte=pNumcte
                                 AND situacion ='L' );
	
	LET vCont = dbinfo("sqlca.sqlerrd2");
	IF vCont = 0 THEN
	--indica  que el numero de cliente no tiene una situacion especial L activa
		LET cCod_ret2 = '00000';
		RETURN cCod_ret1,cCod_ret2;	
	END IF;
	
	IF TRIM(cMotivoDesmarcaje) <> "" THEN
		--no es necesario enviar la alerta
		LET cCod_ret2 = '00000';
		RETURN cCod_ret1,cCod_ret2;	
	END IF
	
	SELECT NVL(numalerta,0)
	INTO iNumalerta
	FROM bdicobranza:cb_alerta_succliente 
	WHERE  numcte=pNumcte
	AND fecha BETWEEN dtFecha AND dtFechaActual
	AND tipo_domicilio=pTpoDir
	AND numalerta = (SELECT MAX(NVL(numalerta,0))
                         FROM bdicobranza:cb_alerta_succliente
						 WHERE  numcte=pNumcte
						 AND tipo_domicilio=pTpoDir
					     AND fecha BETWEEN dtFecha AND dtFechaActual)  ;
	LET vCont = dbinfo("sqlca.sqlerrd2");
	IF vCont = 0 THEN
		LET iNumalerta=0;
	END IF;
		SELECT count(m.numcte)
		INTO iContador
		FROM bdicobranza:cb_marcacliente  m, bdinteg:si_direcciones_loc d 
		WHERE m.numcte =  pNumcte
		AND m.tipo_marca = 'LV'
		AND m.estatus IN ('AT','SA')
		AND m.tipo_domicilio=pTpoDir
		AND m.fecha_insert BETWEEN dtFecha AND dtFechaActual
		AND d.numcte= m.numcte 
		AND d.tipo_dir=m.tipo_domicilio
		AND d.dom_verificado='S' 
		AND d.secuencia = (SELECT MAX(dir_aux.secuencia) 
						 FROM bdinteg:si_direcciones_loc dir_aux
						 WHERE dir_aux.numcte= m.numcte 
						 AND dir_aux.tipo_dir=pTpoDir
						 AND dir_aux.fecha_insert BETWEEN dtFecha AND dtFechaActual);
		
		IF iContador > 0 THEN
			--retorno indica que no es necesario enviar la alarma
			LET cCod_ret2  = '00000';
			RETURN cCod_ret1,cCod_ret2;	
		END IF;	
		
		INSERT INTO  bdicobranza:cb_alerta_succliente (numalerta, fecha, numcte, hora, tipo_alerta, estatus, sucursal, accion_origen, situacion, causa,origen,tipo_domicilio) 
		VALUES (iNumalerta+1, dtFechaActual, pNumcte, CURRENT HOUR TO FRACTION ,'CI', 'SA  ', pSucursal, cAaccionOrigen, cSituacionEsp,iCausa,pOrigen,pTpoDir);
			--insertar en la tabla de alertas
		LET cCod_ret2  = '00006';	
		RETURN cCod_ret1,cCod_ret2;		
	
END;
END PROCEDURE
DOCUMENT
'AUTOR: JESUS MANUEL AGUILAR HEREDIA',
'DESCRIPCION: VALIDA SI EL CLIENTE ESTA EN SITUACION ESPECIAL L, Y NO TENGA UNA ALERTA REGISTRADA, ENVIA UN CODIGO PARA INDICAR QUE NECESITA ENVIARSE UNA ALERTA',
'CASO QUE SI EXISTA UNA ALERTA, VALIDA SI YA REALIZO EL CAMBIO DE DOMICILIO, PARA NO ENVIAR LA ALERTA.',
'BD: BDICOBRANZA',
'VERSION: 20100831.1127',
'MODIFICÓ: MARIA ELENA ANGULO AISPURO',
'MODIFICACIÓN: SE REALIZA CAMBIO PARA CONTEMPLAR LAS NUEVAS DEFINICIONES DEL CLIENTE CON RESPECTO AL ORIGEN DEL MARCAJE',
'VERSION: 20110218.1612';

CREATE PROCEDURE "informix".sp_cilocobteninfociloc(pcNumCte CHAR(20),pcTipoDir CHAR(1))
		RETURNING   
					CHAR(5) AS Codigo,	--codret
					CHAR(26) AS ApellPaterno,--Apellido Paterno
					CHAR(26) AS ApellMaterno,--Apellido Materno
					CHAR(26) AS Nombre1, --Primer nombre de cliente
					CHAR(26) AS Nombre2, --Segundo nombre de cliente
					DATE AS FechaNac,--Fecha de nacimiento
					VARCHAR(60) AS Calle,--Calle
					CHAR(10) AS Numero,--Numero
					VARCHAR(60) AS NomColonia,--Colonia
					VARCHAR(60) AS NomCiudad,--Ciudad
					CHAR(27) AS NomMunicipio,--Municipio
					CHAR(5) AS CodPostal, --Codigo Postal
					CHAR(30) as Estado ; -- Estado
					
		
	--Se definen las variables.
	DEFINE cCodRet 			CHAR(5);
	DEFINE iSqlErr 			INTEGER; 
	DEFINE cApellPaterno	CHAR(26); 
	DEFINE cApellMaterno	CHAR(26);
	DEFINE cNombre1			CHAR(26);
	DEFINE cNombre2			CHAR(26);
	DEFINE dFecha_nac		DATE;
	DEFINE cNumCalle 		CHAR(10);
	DEFINE cNomCalle		VARCHAR(60);
	DEFINE cNumColonia 		CHAR(60);
	DEFINE cNomColonia		VARCHAR(60);
	DEFINE cNumCiudad		CHAR(3);
	DEFINE cNumEstado		CHAR(3);
	DEFINE cNomCiudad		VARCHAR(60);
	DEFINE cNomMunicipio    CHAR(27);
	DEFINE cCodPostal		CHAR(5);
	DEFINE cEstado			CHAR(30);
	DEFINE iCont			INTEGER;
	DEFINE cNumextCalle 		CHAR(10);
	-- Se inicializan las variables.
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cApellPaterno=''; 
	LET cApellMaterno='';
	LET cNombre1='';
	LET cNombre2='';
	LET dFecha_nac = date(1);
	LET cNumCalle ='';
	LET cNomCalle ='';
	LET cNumColonia ='';
	LET cNomColonia='';
	LET cNumCiudad ='';
	LET cNumEstado ='';
	LET cNomCiudad ='';
	LET cNomMunicipio ='';
	LET cCodPostal	= '';
	LET cEstado ='';
	LET iCont=0;
	LET cNumextCalle = '';
	--------------------------------------------------------------------------
	--SET DEBUG FILE TO '/home/sysifx/Malena/sp_CiLocObtenInfoCiLoc.out';
	--TRACE ON;
	--------------------------------------------------------------------------
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cApellPaterno,cApellMaterno,cNombre1,cNombre2,dFecha_nac,cNomCalle,cNumCalle,cNomColonia,cNomCiudad,cNomMunicipio,cCodPostal,cEstado;
		END EXCEPTION;		
		
	
	set isolation to dirty read; -- Lectura de tablas bloqueadas.
	
	-->>>Tipos de domicilio
	--1--Domicilio particular
	--2--Domicilio Trabajo
	--3--Domicilio Referencia
		-- SE CHECA SI EL CLIENTE EXISTE
	IF NOT EXISTS (SELECT SIC.numcte FROM bdinteg:si_cliente AS SIC
					INNER JOIN bdinteg:si_ctepf AS SCT ON (SIC.numcte=SCT.numcte)
					WHERE SIC.numcte=pcNumCte) THEN
		LET cCodret='00001'; --'EL CLIENTE NO ESTA DADO DE ALTA';
		RETURN cCodRet,NVL(cApellPaterno,''),NVL(cApellMaterno,''),NVL(cNombre1,''),NVL(cNombre2,''),dFecha_nac,NVL(cNomCalle,''),NVL(cNumCalle,''),NVL(cNomColonia,''),NVL(cNomCiudad,''),NVL(cNomMunicipio,''),NVL(cCodPostal,''), NVL(cEstado,'');	
	END IF;
	
		IF NOT EXISTS(SELECT numcte FROM bdisitesp:se_ctessitespcte WHERE numcte=pcNumCte and situacion='L') THEN 
			LET cCodret='00002'; --'El cliente no tiene situacion especial L por lo tanto no se le puede realizar ninguna marca';
		END IF;
				--Checa si existe cliente en la Si direcciones_loc
					IF EXISTS(SELECT numcte FROM bdinteg:si_direcciones_loc WHERE numcte=pcNumCte AND  tipo_dir=pcTipoDir) THEN 
							--Se obtienen los datos del cliente.
							SELECT NVL(SIC.apell_paterno,''),NVL(SIC.apell_materno,''),NVL(SIC.nombre1,''),NVL(SIC.nombre2,''),NVL(SCT.fecha_nac,''),NVL(SID.numerocalle,''),NVL(SID.numerocolonia,''),NVL(SID.ciudad,''),NVL(SID.estado,''),NVL(SID.cod_postal,''),NVL(SID.numeroextcalle,'')
							INTO cApellPaterno,cApellMaterno,cNombre1,cNombre2,dFecha_nac,cNumCalle,cNumColonia,cNumCiudad,cNumEstado,cCodPostal,cNumextCalle
							FROM bdinteg:si_direcciones_loc AS SID 
							INNER JOIN bdinteg:si_cliente AS SIC ON SID.numcte=SIC.numcte
							INNER JOIN bdinteg:si_ctepf AS SCT ON SIC.numcte=SCT.numcte
							WHERE SID.numcte=pcNumCte AND SID.tipo_dir=pcTipoDir AND SID.secuencia=(SELECT MAX(secuencia)
																									 FROM bdinteg:si_direcciones_loc 
																									 WHERE tipo_dir=pcTipoDir AND numcte=pcNumCte);
																									 						
					ELIF EXISTS(SELECT numcte FROM bdinteg:si_direcciones_actual WHERE numcte=pcNumCte AND  tipo_dir=pcTipoDir) THEN--SI NO EXISTE EN LA si_direcciones_loc SE CONSULTA EN LA si_direcciones
							--Se obtienen los datos del cliente.			
							SELECT NVL(SIC.apell_paterno,''),NVL(SIC.apell_materno,''),NVL(SIC.nombre1,''),NVL(SIC.nombre2,''),SCT.fecha_nac,NVL(SID.numerocalle,''),NVL(SID.numerocolonia,''),NVL(SID.numerociudad,''),NVL(SID.estado,''),NVL(SID.cod_postal,''),NVL(SID.numeroextcalle,'') 
							INTO cApellPaterno,cApellMaterno,cNombre1,cNombre2,dFecha_nac,cNumCalle,cNumColonia,cNumCiudad,cNumEstado,cCodPostal,cNumextCalle 
							FROM bdinteg:si_direcciones_actual AS SID 
							INNER JOIN bdinteg:si_cliente AS SIC ON SID.numcte=SIC.numcte
							INNER JOIN bdinteg:si_ctepf AS SCT ON SIC.numcte=SCT.numcte
							WHERE SID.numcte=pcNumCte AND SID.tipo_dir=pcTipoDir;
				
					ELIF iCont == 0 THEN 
							LET cCodret='00003'; --'EL CLIENTE AUN NO TIENE DADA DE ALTA UNA DIRECCION ';
					END IF;
						--Se obtiene el nombre de la ciudad.																			 																		 
						SELECT NVL(nombre,'')
						INTO cNomCiudad
						FROM bdinteg:si_ciudades 
						WHERE ciudad_coppel=cNumCiudad AND estado=cNumEstado;
						
						--- Se obtienen el nombre de la colonia y nombre del municipio
						SELECT NVL(nombrezona,''),NVL(municipiozona,'')
						INTO cNomColonia,cNomMunicipio
						FROM bdinteg:si_catzonas 
						WHERE numerociudad = cNumCiudad 
						AND numerocolonia = cNumColonia;
				
						--Se obtiene el nombre de la calle
						SELECT NVL(nombrecalle,'')
						INTO cNomCalle
						FROM bdinteg:si_catcalles 
						WHERE numerocalle =cNumCalle;
						
						--Se obtiene el nombre del estado
						Select NVL(nombre,'')
						INTO cEstado 
						FROM bdinteg:si_estados 
						WHERE pais = '001' 
						AND estado = cNumEstado;
	
			RETURN cCodRet,NVL(cApellPaterno,''),NVL(cApellMaterno,''),NVL(cNombre1,''),NVL(cNombre2,''),dFecha_nac,NVL(cNomCalle,''),NVL(cNumextCalle,''),NVL(cNomColonia,''),NVL(cNomCiudad,''),NVL(cNomMunicipio,''),NVL(cCodPostal,''), NVL(cEstado,'') WITH RESUME;
	END;
END PROCEDURE
DOCUMENT
'AUTOR       : Maria Elena Angulo Aispuro',
'DESCRIPCION : Se devuelve un registro con la información referente al numero de cliente y el tipo de domicilio a consultar por el usuario',
'Se modifica para que regrese el nombre del estado',
'FECHA       : 23 de Agosto de 2010',
'VERSION     : 20100917.1837',
'MODIFICO    : Jesús Antonio Bastidas López',
'DESCRIPCION : Se agrega el campo estado a la consulta y retorno de proceso, se modifica al campo numerocalle y numerocolonia',
'FECHA       : 17/03/2011',
'VERSION     : 20110317.1315',
'BD          : BDICOBRANZA';

CREATE PROCEDURE "informix".sp_cilocconsultasituacionesespeciales()
		RETURNING   CHAR(5) as Codigo,	--codret
					CHAR(40) as Situacion; --situacion
					
	DEFINE cCodRet 			CHAR(5);
	DEFINE iCont            INTEGER;
	DEFINE iSqlErr 			INTEGER;
	DEFINE cSituacion    CHAR(40);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET icont=0;
	LET cSituacion = '';
	--------------------------------------------------------------------------
	--SET DEBUG FILE TO '/home/sysifx/Malena/sp_CiLocConsultaSituacionesEspeciales.out';
	--TRACE ON;
	--------------------------------------------------------------------------
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			LET cSituacion = 'Error de Informix';
			RETURN cCodRet,cSituacion;
		END EXCEPTION;		
		
	--Se realiza consulta a la tabla se_catsitesp para obtener las situaciones especiales.	
	
	set isolation to dirty read; -- Lectura de tablas bloqueadas.
	
		FOREACH   
			SELECT {+FULL} distinct(situacion)
			INTO  cSituacion
			FROM bdisitesp:se_catsitesp
			LET icont=icont+1;
            RETURN cCodret,cSituacion WITH RESUME;
		END FOREACH;		
		
        IF icont == 0 THEN 
			LET cCodret='00001'; 
			LET cSituacion='No hay Informacion en la tabla';
            RETURN cCodret,cSituacion WITH RESUME;
        END IF;

	END;
END PROCEDURE

DOCUMENT
'AUTOR       : Maria Elena Angulo Aispuro',
'DESCRIPCION : Devuelve un listado de las situaciones especiales existentes en la tabla se_catsitesp',
'FECHA       : 13 de Agosto de 2010',
'VERSION     : 20100813.0430',
'BD          : BDICOBRANZA',
'MODIFICACION: Volver a crear SP con usuario informix.',
'AUTOR: Marco A. Campos 2012-02-21';

CREATE PROCEDURE "informix".sp_cat_ivr_gen_arcctesexcluidos(pEmpresa  CHAR(3),
                                                           pFecha_ex DATE)
RETURNING CHAR(6) AS codigo_retorno;


-- 'AUTOR : Abrham Lopez Lopez.', 'FECHA : 22/JUNIO/2010', 'BD    : BDICOBRANZA';
-- 'El SP genera un archivo que extrae información de los clientes excluidos para campaña IVR',
-- Modificado por: MAHR. Abril 2012. Se asigna proceso: 2002, a fin de no repetir numero asignado con otros proceso.

          
DEFINE cCodRet             CHAR(6); 
DEFINE cMensajeRet         CHAR(80);
DEFINE iSqlErr             INTEGER;
DEFINE iIsamErr            INTEGER;
DEFINE cErrorInfo          CHAR(80);
DEFINE cSql                CHAR(2204);
DEFINE cNombreArchivo1     CHAR(50);
DEFINE cNombreArchivo      CHAR(50);
DEFINE cRuta               CHAR(100);
DEFINE iNumreg             INTEGER;
DEFINE iDatos              INTEGER;
DEFINE cEmpresa            CHAR(3);
DEFINE cNombre             CHAR(100);
DEFINE cdelimitador        CHAR(1);
DEFINE cValor_status       CHAR(20);
DEFINE cHora               CHAR(8);
DEFINE cUsuario            CHAR(8);
DEFINE cSql1               CHAR(100);
DEFINE cSql2               CHAR(2004);
DEFINE cSql3               CHAR(100);
DEFINE dDia                DATE;
DEFINE cFechaGenArchivo    CHAR(8);
DEFINE cCodRetIB           CHAR(6);
DEFINE cMensaje            CHAR(80);
DEFINE cProceso            CHAR(4);


LET iSqlErr                = 0;
LET iIsamErr               = 0;
LET cErrorInfo             = "";
LET cCodRet                = "000000";
LET cRuta                  = "";
LET cNombreArchivo1        = "";
LET cNombreArchivo         = "";
LET iNumreg                = 0;
LET iDatos                 = 0;
LET cEmpresa               = "";
LET cNombre                = '';
LET cdelimitador           = '';
LET cSql                   = "";
LET cValor_status          = "";
LET cHora                  = "";
LET dDia                   = DATE(1);
LET cMensajeRet            = 'PROCESO EXITOSO';
LET cProceso               = '2002';
LET cUsuario               = USER;
LET cSql1                  = "";
LET cSql2                  = "";
LET cSql3                  = "";
LET cFechaGenArchivo       = "";
LET cCodRetIB              = "000000";
LET cMensaje               = "";

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        IF iSqlErr != 0 THEN
            LET cCodRet     = iSqlErr;
            LET cMensajeRet = cErrorInfo;
            EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,cProceso,cCodRet,cMensajeRet,"02")
                     INTO cCodRetIB;
            RETURN cCodRet; 
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    --SET DEBUG FILE TO '/home/syscobra/cat/envios/sp_ctbcpl_gen_arcctesexcluidos.out';
    --TRACE ON;

    -- Inserta bitacora de procesos
    EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,cProceso,"","","01")
             INTO cCodRetIB;
        
    -- Validacion de los datos de entrada
    IF NVL(pEmpresa,"") = "" THEN
        LET cCodRet     = "104007";
        SELECT descripcion
            INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen        = 3
            AND codigo_error    = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,cProceso,cCodRet,cMensaje,"02")
                 INTO cCodRetIB;
        RETURN cCodRet;
    END IF;
    
    SELECT empresa
        INTO cEmpresa 
        FROM bdinteg:si_empresas
        WHERE empresa = pEmpresa;
    
    IF NVL(cEmpresa,"")= "" then
        LET cCodRet = "104002";
        SELECT descripcion
            INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen       = 3
            AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,cProceso,cCodRet,cMensaje,"02")
                 INTO cCodRetIB;
        RETURN cCodRet;
    END IF;

    IF NVL(pFecha_ex,"") = "" THEN
        LET cCodRet     = "104008";
        SELECT descripcion
            INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen       = 3
            AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,cProceso,cCodRet,cMensaje,"02")
                 INTO cCodRetIB;
        RETURN cCodRet;
    END IF;

    -- obtener la ruta donde se almacenara el archivo que sera enviado a buro de credito
    SELECT valor_alfabetico 
        INTO cRuta
        FROM bdicobranza:cb_param_campania
        WHERE empresa         = pEmpresa
        AND tipo_campania   = '1'
        AND grupo_parametro = 'ARCHIVOS'
        AND num_parametro   = 3;
        
    IF NVL(cRuta,"")    = "" THEN
        LET cCodRet     = "104005";
        SELECT descripcion
            INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen       = 3
            AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,cProceso,cCodRet,cMensaje,"02")
                  INTO cCodRetIB;
        RETURN cCodRet;
    END IF;

    -- Se obtiene del nombre del archivo
    SELECT valor_alfabetico 
        INTO cNombre
        FROM bdicobranza:cb_param_campania
        WHERE empresa         = pEmpresa
        AND tipo_campania   = '1'
        AND grupo_parametro = 'ARCHIVOS'
        AND num_parametro   = 28;

    IF NVL(cNombre,"") = "" THEN
        LET cCodRet = "104006";
        SELECT descripcion
            INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen       = 3
            AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,cProceso,cCodRet,cMensaje,"02")
                     INTO cCodRetIB;
        RETURN cCodRet;
    END IF;


    --Obtener caracter delimitador
    SELECT trim(valor_alfabetico)
        INTO cdelimitador
        FROM bdicobranza:cb_param_campania
        WHERE empresa = pempresa
        AND tipo_campania = 1
        AND grupo_parametro = 'ARCHIVOS'
        AND num_parametro = 25;
    
	IF NVL(cdelimitador,"") = "" THEN
        LET cCodRet     = "104004";
        SELECT descripcion
            INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen       = 3
            AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,cProceso,cCodRet,cMensaje,"02")
                     INTO cCodRetIB;
        RETURN cCodRet;
    END IF;
     
	LET cNombreArchivo1 = 'prueba.txt';
    LET cNombreArchivo  = TRIM(cNombre) || LPAD(TRIM(DAY(pFecha_ex)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(pFecha_ex)::CHAR(2)),2,'0') || YEAR(pFecha_ex) || '.txt';
   
    FOREACH
        SELECT trim(valor_alfabetico)
	    INTO cValor_status
		FROM bdicobranza:cb_param_campania
		WHERE empresa         = pEmpresa
		AND tipo_campania   = '1'
        AND grupo_parametro = 'STATARCHCE'
        AND valor_alfabetico IN ('EX','IN', 'AC')  -- mahr. solo se contemplan estos status para CAT
     
		SELECT COUNT (numcte)
            INTO iNumreg
			FROM bdicobranza:cb_cat_directorio_cte
			WHERE status_cliente       = cValor_status
			AND fecha_modificacion   = pFecha_ex
		    AND empresa              = pEmpresa
            AND tipo_cobranza        = 'P';

        IF iNumreg = 0 THEN
            CONTINUE FOREACH;
        END IF;

		LET iDatos = iDatos + 1;
			
		--se ejecuta para ponerle el encabezado
		let cSql='';
		let csql = 'echo "cliente'||','||'nombre'||','||'tipoproducto'||','||'telcasa'||','||'telcelular'||','||
				 'fechalimitepago'||','||'fechacorte'||'">'||TRIM(cruta)|| cNombreArchivo;   
		system csql; 

        -- para generar el archivo 
		LET cSql1 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || TRIM (cNombreArchivo1) || " DELIMITER '" || cdelimitador || "'";
				
		LET cSql2 = " select  a.numcte as cliente , "
				|| " trim (h.apell_paterno) ||' '|| trim (h.apell_materno)||' '|| trim(h.nombre1) ||' '|| trim(h.nombre2) as nombre , "
				|| " f.num_producto as tipoproducto, " 
				|| " nvl(b.telefono,' ') as telcasa, "
				|| " nvl((case when d.numero_carrier = 1 then 6 || d.telefono  when d.numero_carrier = 2 then 7 || d.telefono  else 7 || d.telefono end),' ') as telcelular ,1, "
				|| " (e.prox_fecha_pago) as fechalimitepago, "
				|| " (day(e.prox_fecha_pago+4 units day))||'/'||lpad(month(e.prox_fecha_pago),2,'0')||'/'||(year(e.prox_fecha_pago-1 units month))fechacorte "
				|| " from bdicobranza:cb_cat_directorio_cte  a "
				|| " join bdicred:sd_maecred f  on (a.empresa = f.empresa and a.numcte = f.numcte ) "
				|| " join bdinteg:si_cliente h on (h.empresa = a.empresa and h.numcte = a.numcte) "    
				|| " left outer join bdicobranza:cb_telefonos b on ( b.empresa = a.empresa and b.numcte = a.numcte and b.tipo_telefono = 1) "
				|| " left outer join bdicobranza:cb_telefonos d on ( d.empresa = a.empresa and d.numcte = a.numcte and d.tipo_telefono = 2) "
				|| " join bdicred:sd_maecredanexo e   on (e.empresa= a.empresa and e.num_credito = a.num_credito) "
				|| " where a.empresa = '001' "
				|| " and a.tipo_cobranza = 'P' "
                || " and a.status_cliente = '" || trim(cValor_status) || "'"   --  IN ('EX','IN') " -- MAHR
                || " and a.fecha_modificacion  = '" || pFecha_ex || "'"
				|| " and ((nvl(b.telefono,'')<> '') or (nvl(d.telefono,'') <> '')) ";
						
        LET cSql3 = ' " > '|| TRIM(cRuta) || 'Ejecuta_GenArchivoTelefonos.sql';
            
        LET cSql1 = TRIM(cSql1);
        LET cSql3 = TRIM(cSql3);
            
        LET cSql = cSql1 || cSql2 || cSql3;
			
		SYSTEM cSQL;
		--Permiso para la creacion de archivo.
		LET cSQL = '' ;
		LET cSQL = 'chmod 666 ' || TRIM(cRuta) || 'Ejecuta_GenArchivoTelefonos.sql' ;
		LET cSQL = '' ;
		LET cSQL = 'dbaccess bdicobranza ' || TRIM(cRuta) || 'Ejecuta_GenArchivoTelefonos.sql';
		SYSTEM cSQL;
			
		LET cSql = "sed 's/"||cdelimitador||"$//g' "|| TRIM(cRuta) || cNombreArchivo1 || " >> " || TRIM(cRuta) || cNombreArchivo;
        SYSTEM cSql;

		--Borra el archivo de control.
		LET cSQL = '' ;
		LET cSQL = 'rm ' || TRIM(cRuta) || 'Ejecuta_GenArchivoTelefonos.sql';
		SYSTEM cSQL;

		LET cSQL = '' ;
		LET cSQL = 'rm ' || TRIM(cRuta) || cNombreArchivo1;
		SYSTEM cSQL;
		
    END FOREACH;

    -- Por si el archivo no  se genera 
    IF iDatos = 0 THEN
        LET cCodRet = '104009';
        SELECT descripcion
            INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen       = 3
            AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,cProceso,cCodRet,cMensaje,"02")
                 INTO cCodRetIB;
        RETURN cCodRet;
    END IF;

    EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,cProceso,cCodRet,cMensajeRet,"03")
             INTO cCodRetIB;

    RETURN cCodRet;

END
END PROCEDURE;