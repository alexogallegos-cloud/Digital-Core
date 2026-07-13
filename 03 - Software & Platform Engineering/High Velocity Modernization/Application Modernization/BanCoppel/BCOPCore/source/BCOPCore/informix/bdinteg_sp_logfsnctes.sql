CREATE PROCEDURE "informix".sp_logfsnctes(pUsuario CHAR(20),
										  pAbreAplic CHAR(2), 
										  pFusion CHAR(2), 
										  pFechaAbreApli DATETIME YEAR TO SECOND, 
										  pHraAbreApli DATETIME HOUR TO FRACTION(3), 
										  pFechaFus DATETIME YEAR TO SECOND,
										  pHraFus DATETIME HOUR TO FRACTION(3),
										  pUsNoAut CHAR(20), 
										  pCteTit CHAR(20), 
										  pCteTras CHAR(20), 
										  pStatus CHAR(100), 
										  pTipoRep CHAR(1),
										  pBandera CHAR(1))

RETURNING	CHAR(6) 	AS 	cCodRet


	--DECLARACIONES
    DEFINE cCodRet          CHAR(6);
    DEFINE iSqlErr          INTEGER;
    DEFINE iIsamErr         INTEGER;
    
	DEFINE iId		    	INTEGER;


    --INICIALIZACIONES
	LET cCodRet				= '000000';
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	
	LET iId					= 0;

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN TRIM(cCodRet);
		END IF;
    END EXCEPTION;

	--SET DEBUG FILE TO "/respaldosbd/hectorb/sp_logfsnctes.out";
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	--SE VALIDA QUE NO VENGA VACIO O NULO EL PARAMETRO
	IF  NVL(pBandera,'') = '' THEN
		LET cCodRet = '000001';
	END IF
	
	--SE INSERTA LA INFORMACION RECIBIDA EN LA TABLA CREANDO EL REGISTRO SIEMPRE Y CUANDO LA BANDERA SEA = 1	
	IF pBandera = '1' THEN
		INSERT INTO bdinteg:"informix".si_fusbitacora(usuario_sif, abre_aplicacion, fusion, fecha_abreaplicacion, hora_abreaplicacion, fecha_fusion, hora_fusion, usuario_no_autorizado, cliente_titular, cliente_traspasar, status, tipo_reporte)
		VALUES ( pUsuario, pAbreAplic, pFusion, pFechaAbreApli, pHraAbreApli, pFechaFus,  pHraFus, pUsNoAut, pCteTit, pCteTras, pStatus, pTipoRep);
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '000002';		
		END IF;
	
	--SE ACTUALIZA EL REGISTRO ANTES YA INSERTADO DEPENDIENDO LOS DATOS RECIBIDOS
	ELIF pBandera = '2' THEN
	
		UPDATE bdinteg:"informix".si_fusbitacora SET usuario_sif = pUsuario, abre_aplicacion = pAbreAplic, fusion = pFusion, fecha_fusion = pFechaFus, hora_fusion = pHraFus, usuario_no_autorizado = pUsNoAut, cliente_titular = pCteTit, cliente_traspasar = pCteTras, status = pStatus, tipo_reporte = pTipoRep
		WHERE id_log = ((SELECT MAX(id_log)
					   FROM bdinteg:"informix".si_fusbitacora
					   WHERE usuario_sif = pUsuario));
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '000003';		
		END IF;
	ELSE
		LET cCodRet = '000001';	 ----Parámetros de entrada incorrectos
	END IF
	
	RETURN TRIM(cCodRet);
	
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea procedimiento el cual inserta el registro del usuario al entrar al aplicativo y actualiza el mismo dependiendo la situacion del cliente.', 
'AUTOR: Armando Morales',
'FECHA: Octubre 2012',
'VERSION: 20121003.1100',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_obtinfofsnctes(pTipoRep CHAR(1), pFecha CHAR(10))
RETURNING
CHAR(6) 						AS 	cCodRet,
CHAR(20)						AS	USUARIO_SIF,
CHAR(2)							AS	ABRE_APLICACION,
CHAR(2)							AS	FUSION,
CHAR(10)						AS	FECHA_ABRE_APLIC,
DATETIME HOUR to FRACTION(3)	AS	HORA_ABRE_APLIC,
DATE							AS	FECHA_FUSION,
DATETIME HOUR to FRACTION(3)	AS	HORA_FUSION,
CHAR(20)						AS	USUARIO_NO_AUT, 
CHAR(20)						AS	CTE_TITULAR,
CHAR(20)						AS	CTE_TRASPASAR,
CHAR(100)						AS	STATUS;


	--DECLARACIONES
    DEFINE cCodRet          CHAR(6);
    DEFINE iSqlErr          INTEGER;
    DEFINE iIsamErr         INTEGER;
    
	DEFINE cUsuario	    	CHAR(20);
	DEFINE cAbreAplic    	CHAR(2);
	DEFINE cFusion	    	CHAR(2);
	DEFINE cFechaAplic    	DATE;
	DEFINE dHoraAplic    	DATETIME HOUR to FRACTION(3);
	DEFINE dFechaFus    	DATE;
	DEFINE dHoraFus	    	DATETIME HOUR to FRACTION(3);
	DEFINE cUsNoAut	    	CHAR(20);
	DEFINE cCteTit	    	CHAR(20);
	DEFINE cCteTras	    	CHAR(20);
	DEFINE cStatus	    	CHAR(100);
	


    --INICIALIZACIONES
	LET cCodRet				= '000000';
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	
	LET cUsuario	    	= '';
	LET cAbreAplic 		   	= '';
	LET cFusion	 		   	= '';
	LET cFechaAplic	    	= DATE(1);
	LET dHoraAplic  	  	= '';
	LET dFechaFus    		= DATE(1);
	LET dHoraFus	    	= '';
	LET cUsNoAut	    	= '';
	LET cCteTit	   		 	= '';
	LET cCteTras	    	= '';
	LET cStatus	    		= '';
	


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN TRIM(cCodRet), TRIM(cUsuario), TRIM(cAbreAplic), TRIM(cFusion), cFechaAplic, dHoraAplic, dFechaFus, dHoraFus, TRIM(cUsNoAut), TRIM(cCteTit), TRIM(cCteTras), TRIM(cStatus);
		END IF;
    END EXCEPTION;

	--SET DEBUG FILE TO "/home/sysifx/armandomorales/sp_obtinfofsnctes.out";
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	--SE VALIDA QUE LOS PARAMETROS NO VENGAN VACIOS O NULOS
	IF NVL(pTipoRep,'') = '' AND NVL(pFecha,'') = '' THEN
		LET cCodRet = '000001';
		RETURN TRIM(cCodRet), TRIM(cUsuario), TRIM(cAbreAplic), TRIM(cFusion), cFechaAplic, dHoraAplic, dFechaFus, dHoraFus,
		TRIM(cUsNoAut), TRIM(cCteTit), TRIM(cCteTras), TRIM(cStatus);
	END IF
	
	--SE OBTIENE LA INFORMACION DE LA TABLA DEPENDIENDO LA FECHA INGRESADA
	FOREACH
		SELECT usuario_sif, abre_aplicacion, fusion, fecha_abreaplicacion, hora_abreaplicacion, fecha_fusion, hora_fusion, usuario_no_autorizado, cliente_titular, cliente_traspasar, status
		INTO cUsuario, cAbreAplic, cFusion, cFechaAplic, dHoraAplic, dFechaFus, dHoraFus, cUsNoAut, cCteTit, cCteTras, cStatus
		FROM bdinteg:"informix".si_fusbitacora
		WHERE tipo_reporte = 1
		AND DATE(fecha_abreaplicacion) = pFecha
		ORDER BY hora_abreaplicacion
		
		RETURN TRIM(cCodRet), TRIM(cUsuario), TRIM(cAbreAplic), TRIM(cFusion), cFechaAplic, dHoraAplic, dFechaFus, dHoraFus, TRIM(cUsNoAut), TRIM(cCteTit), TRIM(cCteTras), TRIM(cStatus) WITH RESUME;
	END FOREACH
	
	 IF dbinfo("sqlca.sqlerrd2") = 0 THEN
        LET cCodRet = "000002";
        RETURN TRIM(cCodRet), TRIM(cUsuario), TRIM(cAbreAplic), TRIM(cFusion), cFechaAplic, dHoraAplic, dFechaFus, dHoraFus,TRIM(cUsNoAut), TRIM(cCteTit), TRIM(cCteTras), TRIM(cStatus);
    END IF;
	
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea procedimiento el cual obtiene la informacion de la tabla para llenar el reporte de fusion', 
'AUTOR: Armando Morales',
'FECHA: Octubre 2012',
'VERSION: 20121002.1100',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_vdactasbqdas(pNumCte CHAR(20))
RETURNING
CHAR(6) 	AS 	cCodRet,
CHAR(85)	AS  cMensajeRet


	--DECLARACIONES
    DEFINE cCodRet          CHAR(6);
    DEFINE iSqlErr          INTEGER;
    DEFINE iIsamErr         INTEGER;
	DEFINE cErrorInfo		CHAR(80);
    DEFINE cMensajeRet      CHAR(85);
    
	DEFINE cCuenta	    	CHAR(20);
	DEFINE cNumCred		    CHAR(20);


    --INICIALIZACIONES
	LET cCodRet				= '000000';
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	LET cErrorInfo			= '';
	LET cMensajeRet			= 'PROCESO EXITOSO';
	
	LET cCuenta				= '';
	LET cNumCred			= '';


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			RETURN TRIM(cCodRet), TRIM(cMensajeRet);
		END IF;
    END EXCEPTION;

	--SET DEBUG FILE TO "/home/sysifx/armandomorales/sp_vdactasbqdas.out";
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;	
	
		--SE VALIDA QUE NO VENGA VACIO O NULO EL PARAMETRO
		IF NVL(pNumCte,'') = '' THEN
			LET cCodRet = '000002';
			LET cMensajeRet = 'FALTAN PARAMETROS DE ENTRADA';
			RETURN TRIM(cCodRet), TRIM(cMensajeRet);
		END IF
			--OBTIENE EL NUMERO DE CUENTAS CON STATUS BLOQUEADA
			SELECT COUNT(cuenta)
			INTO cCuenta
			FROM bdicheq:"informix".sc_maechq   
			WHERE num_cte = pNumCte
			AND  status_cta = '3';
			
			--OBTIENE EL NUMERO DE CREDITOS QUE NO ESTEN ACTIVOS
			SELECT COUNT(num_credito)
			INTO cNumCred
			FROM bdicred:"informix".sd_maecred   
			WHERE numcte = pNumCte
			AND  id_unidad_prod IS NOT NULL;
				
			IF cNumCred > 0 OR cCuenta > 0 THEN
				LET cCodRet = '000001';
				LET cMensajeRet = 'EL CLIENTE TIENE CUENTAS BLOQUEADAS';
			END IF

		RETURN TRIM(cCodRet), TRIM(cMensajeRet);
		
	
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea procedimiento el cual valida que el cliente no tenga cuentas bloqueadas', 
'AUTOR: Armando Morales',
'FECHA: Octubre 2012',
'VERSION: 20121001.1100',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_fuscte_conscte(pNumCte CHAR(20))
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
			CHAR(1)   AS Sexo;

--DECLARACION DE VARIABLES
DEFINE vc_CodRet        CHAR(5);
DEFINE vc_ApellPaterno  CHAR(26);
DEFINE vc_ApellMaterno  CHAR(26);
DEFINE vc_Nombre1       CHAR(26);
DEFINE vc_Nombre2       CHAR(26);
DEFINE vc_Sucursal      CHAR(4);
DEFINE vc_RFC           CHAR(13);
DEFINE vc_StatusCte     CHAR(2);
DEFINE vd_FechaAlta     DATE;
DEFINE vd_FechaNac      DATE;
DEFINE vi_SqlErr        INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE vc_Cont          INTEGER;
DEFINE cSexo            CHAR(1);
DEFINE cTpoPers         CHAR(2);

--INICIALIZACION DE VARIABLES
LET vc_CodRet       = '00000';
LET vc_ApellPaterno = '';
LET vc_ApellMaterno = '';
LET vc_Nombre1      = '';
LET vc_Nombre2      = '';
LET vc_Sucursal     = '';
LET vc_RFC          = '';
LET vc_StatusCte    = '';
LET vd_FechaAlta    = DATE(1);
LET vd_FechaNac     = DATE(1);
LET vi_SqlErr       = 0;
LET iIsamErr        = 0 ;
LET vc_Cont         = 0;
LET cSexo           = '';
LET cTpoPers        = '';

	--SET DEBUG FILE TO "/informix/ArmandoM/sp_fuscte_conscte.out";
	--TRACE ON;

BEGIN
    ON EXCEPTION SET vi_SqlErr, iIsamErr
        IF vi_SqlErr <> 0 THEN
            LET vc_CodRet = vi_SqlErr;
            RETURN TRIM(vc_CodRet), TRIM(NVL(vc_ApellPaterno, '')), TRIM(NVL(vc_ApellMaterno, '')), TRIM(NVL(vc_Nombre1, '')), TRIM(NVL(vc_Nombre2, '')), TRIM(NVL(vc_Sucursal, '')), TRIM(NVL(vc_RFC, '')), TRIM(NVL(vc_StatusCte,'')), NVL(vd_FechaAlta, DATE(1)), NVL(vd_FechaNac, DATE(1)), TRIM(NVL(cSexo, ''));
        END IF;
    END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	
	--SET DEBUG FILE TO '/home/sysifx/armandomorales/sp_fuscte_conscte.out';
	--TRACE ON;

		IF NVL(pNumCte, '') = '' THEN  --VALIDAMOS QUE EL PARAMETRO NO VENGA EN BLANCO
			LET vc_CodRet = '00100'; --PARAMETRO DE ENTRADA INVALIDO
			RETURN TRIM(vc_CodRet), TRIM(NVL(vc_ApellPaterno, '')), TRIM(NVL(vc_ApellMaterno, '')), TRIM(NVL(vc_Nombre1, '')), TRIM(NVL(vc_Nombre2, '')), TRIM(NVL(vc_Sucursal, '')), TRIM(NVL(vc_RFC, '')), TRIM(NVL(vc_StatusCte,'')), NVL(vd_FechaAlta, DATE(1)), NVL(vd_FechaNac, DATE(1)), TRIM(NVL(cSexo, ''));
		END IF;
	
		IF LENGTH(pNumCte)<> 9 THEN --VALIDAMOS QUE EL NO. DE CLIENTE VENGA CON EL FORMATO
			LET vc_CodRet = '00200'; --LONGITUD INVALIDA PARA EL PARAMETRO DE ENTRADA
			RETURN TRIM(vc_CodRet), TRIM(NVL(vc_ApellPaterno, '')), TRIM(NVL(vc_ApellMaterno, '')), TRIM(NVL(vc_Nombre1, '')), TRIM(NVL(vc_Nombre2, '')), TRIM(NVL(vc_Sucursal, '')), TRIM(NVL(vc_RFC, '')), TRIM(NVL(vc_StatusCte,'')), NVL(vd_FechaAlta, DATE(1)), NVL(vd_FechaNac, DATE(1)), TRIM(NVL(cSexo, ''));
		END IF;
	
		SELECT cte.tpo_persona, cte.apell_paterno, cte.apell_materno, cte.nombre1, cte.nombre2, cte.sucursal, cte.rfc, cte.status_cte, cte.fecha_alta 
		INTO    cTpoPers, vc_ApellPaterno, vc_ApellMaterno, vc_Nombre1, vc_Nombre2, vc_Sucursal, vc_RFC, vc_StatusCte, vd_FechaAlta 
		FROM bdinteg:'informix'.si_cliente cte
		WHERE cte.numcte = pNumCte;

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN --SI LA BUSQUEDA NO ARROJA RESULTADOS
			LET vc_CodRet = '00300'; --NUMERO DE CLIENTE NO EXISTE
			RETURN TRIM(vc_CodRet), TRIM(NVL(vc_ApellPaterno, '')), TRIM(NVL(vc_ApellMaterno, '')), TRIM(NVL(vc_Nombre1, '')), TRIM(NVL(vc_Nombre2, '')), TRIM(NVL(vc_Sucursal, '')), TRIM(NVL(vc_RFC, '')), TRIM(NVL(vc_StatusCte,'')), NVL(vd_FechaAlta, DATE(1)), NVL(vd_FechaNac, DATE(1)), TRIM(NVL(cSexo, ''));   
		END IF	 
		
		IF vc_StatusCte = 'FU' THEN
			LET vc_CodRet = '00600'; --CLIENTE FUSIONADO
			RETURN TRIM(vc_CodRet), TRIM(vc_ApellPaterno), TRIM(vc_ApellMaterno), TRIM(vc_Nombre1), TRIM(vc_Nombre2), TRIM(vc_Sucursal), TRIM(vc_RFC), TRIM(vc_StatusCte), NVL(vd_FechaAlta, DATE(1)), NVL(vd_FechaNac, DATE(1)), TRIM(cSexo); 
		ELIF vc_StatusCte = 'BA' THEN
			LET vc_CodRet = '00400'; --EL STATUS DEL CLIENTE INDICA QUE EL CLIENTE SE HA DADO DE BAJA O ESTA CANCELADO
			RETURN TRIM(vc_CodRet), TRIM(vc_ApellPaterno), TRIM(vc_ApellMaterno), TRIM(vc_Nombre1), TRIM(vc_Nombre2), TRIM(vc_Sucursal), TRIM(vc_RFC), TRIM(vc_StatusCte), NVL(vd_FechaAlta, DATE(1)), NVL(vd_FechaNac, DATE(1)), TRIM(cSexo);   
		END IF;
		
		IF cTpoPers = '01' THEN
			SELECT fecha_nac, sexo 
			INTO vd_FechaNac, cSexo
			FROM bdinteg:'informix'.si_ctepf WHERE numcte = pNumCte;
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET vc_CodRet = '00500'; --INCONGRUENCIA DE DATOS
					RETURN TRIM(vc_CodRet), TRIM(NVL(vc_ApellPaterno, '')), TRIM(NVL(vc_ApellMaterno, '')), TRIM(NVL(vc_Nombre1, '')), TRIM(NVL(vc_Nombre2, '')), TRIM(NVL(vc_Sucursal, '')), TRIM(NVL(vc_RFC, '')), TRIM(NVL(vc_StatusCte,'')), NVL(vd_FechaAlta, DATE(1)), NVL(vd_FechaNac, DATE(1)), TRIM(NVL(cSexo, ''));                
				END IF	 
		ELSE
			LET vc_CodRet = '00700'; --PERSONA MORAL
		END IF;	
 
		RETURN TRIM(vc_CodRet), TRIM(vc_ApellPaterno), TRIM(vc_ApellMaterno), TRIM(vc_Nombre1), TRIM(vc_Nombre2), TRIM(vc_Sucursal), TRIM(vc_RFC), TRIM(vc_StatusCte), NVL(vd_FechaAlta, DATE(1)), NVL(vd_FechaNac, DATE(1)), TRIM(cSexo);       
            
END;
END PROCEDURE
DOCUMENT
'REALIZÓ: AYMME OSUNA PERAZA',
'FECHA:   23-01-2009',
'DESCRIPCIÓN: ESTE PROCEDIMIENTO SE ENCARGA DE OBTENER LOS DATOS PERSONALES DEL CLIENTES,LOS CUALES SON REQUERIDOS PARA EL LLENADO DE LA PANTALLA DE FUSION DE CLIENTES, ANTERIORMENTE SE UTILIZABA EL SP CONSNUMCTE PERO DEBIDO A QUE SE REQUIERE VALIDAR EL ESTATUS DEL CLIENTE Y OBTENER MAS DATOS SE DECIDIO ELABORAR UN SP INDEPENDIENTE.',
'MODIFICÓ: Armando Morales',
'DESCRIPCION: Se modifica procedimiento para que valide primero si el cliente es moral y sino verificar si hay datos o no', 
'FECHA: Octubre 2012',
'VERSION: 20121018.1100',
'BD: bdinteg',
'MODIFICÓ: Carlos Ochoa Valenzuela',
'DESCRIPCION: Se elimina validaciones innecesarias y se agrega TRIM y NVL a returns', 
'FECHA: 12 de Diciembre 2012',
'VERSION: 20121212.1227',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_sepomexconscatalogos( pTipo SMALLINT, pDatoConsulta CHAR(30), pNumEstado SMALLINT, pCiudad CHAR(35),
													pNumCiudad SMALLINT, pFlagModificacion SMALLINT)
	RETURNING
		CHAR(6) 	AS CodRet,
		CHAR(2)  	AS cCveEstado,
		CHAR(30)    AS cNomEstado,
		CHAR(3)     AS cCveCiudad,
		CHAR(60)    AS cNombreCiudad,
		CHAR(5)     AS cCodPostal,
		CHAR(60)    AS cAsenta,
		SMALLINT    AS sNumColonia,
		CHAR(32)    AS cNombreZona,
		CHAR(40)    AS cMunicipio;
		
					     
	--DECLARACION DE VARIABLES.
	DEFINE iSqlErr					INTEGER;	
	DEFINE iIsamErr					INTEGER;	
	DEFINE cErrorInfo				CHAR(80);
	DEFINE cCodRet					CHAR(6);			
	DEFINE cCveEstado				CHAR(2);					
	DEFINE cNomEstado               CHAR(30);
	DEFINE cCveCiudad				CHAR(3);					
	DEFINE cNombreCiudad			CHAR(60);					
	DEFINE cCodPostal				CHAR(5);
	DEFINE cAsenta					CHAR(60);								
	DEFINE sNumColonia				SMALLINT;	
	DEFINE cNombreZona              CHAR(32);
	DEFINE cMunicipio               CHAR(40);
	DEFINE ibanderadatos            INTEGER;	
	
	--INICIALIZACION DE VARIABLES.
	LET iSqlErr						= 0;	
	LET iIsamErr					= 0;	
	LET cErrorInfo					= '';
	LET cCodRet						= '000000';	
	LET cCveEstado					= '';
	LET cNomEstado               	= '';
	LET cCveCiudad					= '';
	LET cNombreCiudad				= '';
	LET cCodPostal					= '';
	LET cAsenta						= '';
	LET sNumColonia					= 0;
	LET cNombreZona              	= '';
	LET cMunicipio               	= '';
	LET ibanderadatos 				= 1;
		
	BEGIN
				
		ON EXCEPTION SET iSqlErr,iIsamErr,cErrorInfo
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;	
				RETURN cCodRet, cCveEstado, cNomEstado, cCveCiudad, cNombreCiudad, cCodPostal, cAsenta,
						sNumColonia, cNombreZona, cMunicipio;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO "/informix/ALL/sp_sepomexconscatalogos.out";
		--TRACE ON;	

		SET LOCK MODE TO WAIT 3;		
		SET ISOLATION TO DIRTY READ;
		
        IF pTipo = 1 THEN
            IF pDatoConsulta <> "" THEN
				FOREACH 			
					SELECT estado,nombre 
					INTO cCveEstado,cNomEstado
					FROM bdinteg:"informix".si_estados 
					WHERE estado = estado
					AND nombre LIKE "%" || TRIM(pDatoConsulta) || "%" 
					ORDER BY 2
					
					RETURN cCodRet, cCveEstado, cNomEstado, cCveCiudad, cNombreCiudad, cCodPostal, cAsenta, sNumColonia, cNombreZona,
					cMunicipio  WITH RESUME; 
				
				END FOREACH;				
            ELSE
				FOREACH 			
					SELECT estado,nombre 
					INTO cCveEstado,cNomEstado
					FROM bdinteg:"informix".si_estados 
					WHERE estado = estado
					ORDER BY 2
					
					RETURN cCodRet, cCveEstado, cNomEstado, cCveCiudad, cNombreCiudad, cCodPostal, cAsenta, sNumColonia, cNombreZona,
					cMunicipio  WITH RESUME; 
				
				END FOREACH;				
            END IF;
        ELIF pTipo = 2 THEN
            IF pDatoConsulta <> "" THEN
				FOREACH 			
					SELECT a.ciudad, a.nombre
					INTO cCveCiudad, cNombreCiudad
					FROM bdinteg:"informix".si_ciudades a, bdinteg:"informix".si_estados b 
					WHERE a.estado = b.estado AND b.estado = pNumEstado
					AND a.d_ciudad IS NOT NULL
					AND  a.nombre LIKE "%" || TRIM(pDatoConsulta) || "%"
					ORDER BY 2
					
					RETURN cCodRet, cCveEstado, cNomEstado, cCveCiudad, cNombreCiudad, cCodPostal, cAsenta, sNumColonia, cNombreZona,
					cMunicipio  WITH RESUME; 
				
				END FOREACH;				
            ELSE
				FOREACH 			
					SELECT a.ciudad, a.nombre
					INTO cCveCiudad, cNombreCiudad
					FROM bdinteg:"informix".si_ciudades a, bdinteg:"informix".si_estados b 
					WHERE a.estado = b.estado 
					AND b.estado = pNumEstado 
					AND a.d_ciudad IS NOT NULL
					ORDER BY 2
					
					RETURN cCodRet, cCveEstado, cNomEstado, cCveCiudad, cNombreCiudad, cCodPostal, cAsenta, sNumColonia, cNombreZona,
					cMunicipio  WITH RESUME; 
				
				END FOREACH;				
            END IF;
        ELIF pTipo = 3 THEN
            IF pFlagModificacion <> 1 THEN
                IF pDatoConsulta <> "" THEN
					FOREACH 				
						SELECT {+INDEX(bdinteg:"informix".si_catsepomex sicatsepomex)}
							d_codigo, d_asenta
						INTO cCodPostal, cAsenta
						FROM bdinteg:"informix".si_catsepomex 
						WHERE d_codigo = d_codigo
						AND UPPER(TRIM(d_ciudad)) = UPPER(TRIM((pCiudad))) 
						AND c_estado =  pNumEstado  
						AND UPPER (d_asenta)LIKE  "%" || UPPER(TRIM(pDatoConsulta)) || "%"
						ORDER BY d_asenta ASC						
						
						RETURN cCodRet, cCveEstado, cNomEstado, cCveCiudad, cNombreCiudad, cCodPostal, cAsenta, sNumColonia, cNombreZona,
						cMunicipio  WITH RESUME; 
							
					END FOREACH;					
                ELSE
					FOREACH 				
						SELECT {+INDEX(bdinteg:"informix".si_catsepomex sicatsepomex)}
								d_codigo, d_asenta
						INTO cCodPostal, cAsenta
						FROM bdinteg:"informix".si_catsepomex 
						WHERE d_codigo = d_codigo
						AND UPPER(TRIM(d_ciudad)) = UPPER(TRIM((pCiudad))) 
						AND c_estado = pNumEstado 
						ORDER BY d_asenta ASC
						
						RETURN cCodRet, cCveEstado, cNomEstado, cCveCiudad, cNombreCiudad, cCodPostal, cAsenta, sNumColonia, cNombreZona,
						cMunicipio  WITH RESUME; 
--A.L.L SE CONSULTA POR MUNICIPIO EN CASO DE NO ENCONTRAR POR EL CAMPO D_CIUDAD						
						--LET ibanderadatos = 1;
					END FOREACH;
					IF ibanderadatos = 1 THEN
					--IF pDatoConsulta <> "" THEN
					
						FOREACH 				
							SELECT {+INDEX(bdinteg:"informix".si_catsepomex sicatsepomex)}
								d_codigo, d_asenta
							INTO cCodPostal, cAsenta
							FROM bdinteg:"informix".si_catsepomex 
							WHERE d_codigo = d_codigo
							AND UPPER(TRIM(d_mnpio)) = UPPER(TRIM((pCiudad))) 
							AND c_estado =  pNumEstado  
							AND UPPER (d_asenta)LIKE  "%" || UPPER(TRIM(pDatoConsulta)) || "%"
							ORDER BY d_asenta ASC						
						
							RETURN cCodRet, cCveEstado, cNomEstado, cCveCiudad, cNombreCiudad, cCodPostal, cAsenta, sNumColonia, cNombreZona,
							cMunicipio  WITH RESUME; 
							
						END FOREACH;
					ELSE
						FOREACH 				
							SELECT {+INDEX(bdinteg:"informix".si_catsepomex sicatsepomex)}
									d_codigo, d_asenta
							INTO cCodPostal, cAsenta
							FROM bdinteg:"informix".si_catsepomex 
							WHERE d_codigo = d_codigo
							AND UPPER(TRIM(d_mnpio)) = UPPER(TRIM((pCiudad))) 
							AND c_estado = pNumEstado 
							ORDER BY d_asenta ASC
							
							RETURN cCodRet, cCveEstado, cNomEstado, cCveCiudad, cNombreCiudad, cCodPostal, cAsenta, sNumColonia, cNombreZona,
							cMunicipio  WITH RESUME;
						
						END FOREACH;
					--end if;	
					end if;
                END IF;
            ELSE
				IF pDatoConsulta <> "" THEN
					FOREACH 			 
						SELECT  numerocolonia, nombrezona 
						INTO sNumColonia, cNombreZona
						FROM bdinteg:"informix".si_catzonas 
						WHERE numerociudad = pNumCiudad
						AND UPPER (nombrezona)LIKE UPPER ("%" || TRIM(pDatoConsulta) || "%")
						ORDER BY  numerocolonia ASC

						RETURN cCodRet, cCveEstado, cNomEstado, cCveCiudad, cNombreCiudad, cCodPostal, cAsenta, sNumColonia, cNombreZona,
						cMunicipio  WITH RESUME; 
						
					END FOREACH;					
                ELSE
					
					FOREACH 				
						SELECT  numerocolonia, nombrezona 
						INTO sNumColonia, cNombreZona
						FROM bdinteg:"informix".si_catzonas 
						WHERE numerociudad = pNumCiudad
						ORDER BY  numerocolonia ASC
						
						RETURN cCodRet, cCveEstado, cNomEstado, cCveCiudad, cNombreCiudad, cCodPostal, cAsenta, sNumColonia, cNombreZona,
						cMunicipio  WITH RESUME; 
					END FOREACH;					
					
				END IF;
            END IF;
        ELIF pTipo = 4 THEN
            IF pDatoConsulta <> "" THEN
				FOREACH 
					SELECT{+INDEX(bdinteg:"informix".si_catsepomex sicatsepomex)} DISTINCT d_mnpio 
					INTO cMunicipio
					FROM bdinteg:"informix".si_catsepomex 
					WHERE d_codigo = d_codigo
					AND d_ciudad = d_ciudad
					AND c_estado = pNumEstado
					AND UPPER (d_mnpio)LIKE UPPER ("%" || TRIM(pDatoConsulta) || "%") 
					ORDER BY d_mnpio ASC
					
					RETURN cCodRet, cCveEstado, cNomEstado, cCveCiudad, cNombreCiudad, cCodPostal, cAsenta, sNumColonia, cNombreZona,
						cMunicipio  WITH RESUME; 
					
				END FOREACH;
            ELSE
				FOREACH         
					SELECT{+INDEX(bdinteg:"informix".si_catsepomex sicatsepomex)} DISTINCT d_mnpio 
					INTO cMunicipio
					FROM bdinteg:"informix".si_catsepomex 
					WHERE d_codigo = d_codigo
					AND d_ciudad = d_ciudad
					AND c_estado = pNumEstado
					ORDER BY d_mnpio ASC
					
					RETURN cCodRet, cCveEstado, cNomEstado, cCveCiudad, cNombreCiudad, cCodPostal, cAsenta, sNumColonia, cNombreZona,
					cMunicipio  WITH RESUME; 
					
				END FOREACH;
            END IF;
		END IF;
							
	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento que obtiene la informacion de los estados, ciudades, municipios, y zonas de acuerdo al filtro requerido', 
'AUTOR: Héctor Manuel Bojorquez Ruelas',
'FECHA DE CREACION: 6 de Marzo del 2012',
'VERSION: 20120206.1116',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_alteratipodatotelefonos()
RETURNING CHAR(5) AS CodRet;

    -- // Definicion de Variables
    DEFINE iSqlErr      INTEGER;
    DEFINE iIsamErr     INTEGER;
    DEFINE cDescErr     CHAR(50);
    DEFINE cCodRet      CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(50);
    DEFINE vabierto     CHAR(1);
    DEFINE cNumCte      CHAR(20);
    DEFINE cTelefono    CHAR(13);
    DEFINE siTipoTel    SMALLINT;
    DEFINE siSecuencia  SMALLINT;
    DEFINE cFechaHora   CHAR(23);
    DEFINE vcomienza    SMALLINT;
    DEFINE vcontador    INTEGER;

    -- // Inicializacion de Variables
    LET iSqlErr     = 0;
    LET iIsamErr    = 0;
    LET cDescErr    = '';
    LET cCodRet     = '000';
    LET cCodRet2    = '';
    LET cCodRet3    = '';
    LET vabierto    = '0';
    LET cNumCte     = '';
    LET cTelefono   = '';
    LET siTipoTel   = 0;
    LET siSecuencia = 0;
    LET cFechaHora  = '';
    LET vcomienza   = -1;
    LET vcontador   = 0;

    --- SET DEBUG FILE TO '/tmp/sp_alteratipodatotelefonos.out';
    --- TRACE ON;

    BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, cDescErr
        SET DEBUG FILE TO '/tmp/sp_alteratipodatotelefonos.err';
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            LET cCodRet2 = iIsamErr;
            LET cCodRet3 = cDescErr;
            IF vabierto = '1' THEN
                ROLLBACK WORK;
            END IF;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- // MODIFICACION EN si_telefonos
    ALTER TABLE "informix".si_telefonos ADD fecha_completa DATETIME YEAR TO SECOND BEFORE user_insert;

    FOREACH WITH HOLD
        SELECT numcte, telefono, tipo_tel, secuencia, fecha_hora
          INTO cNumCte, cTelefono, siTipoTel, siSecuencia, cFechaHora
          FROM "informix".si_telefonos
         WHERE tipo_tel IN(1, 2, 3, 4)
         
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET vabierto = '1';
            BEGIN WORK;
        END IF;

        IF LENGTH(cFechaHora) = "23" THEN
            LET cFechaHora = SUBSTR(cFechaHora,1,19);
        ELIF LENGTH(cFechaHora) = "10" THEN
            LET cFechaHora = SUBSTR(TRIM(cFechaHora),7,10) || "-" || SUBSTR(TRIM(cFechaHora),1,2) || "-" || SUBSTR(TRIM(cFechaHora),4,5);
            LET cFechaHora = SUBSTR(cFechaHora,1,10) || " 00:00:00";
        END IF;
        
        LET cFechaHora = TRIM(cFechaHora);

        UPDATE "informix".si_telefonos 
           SET fecha_completa = cFechaHora 
         WHERE numcte = cNumCte 
           AND telefono = cTelefono 
           AND tipo_tel = siTipoTel 
           AND secuencia = siSecuencia;
           
        LET vcontador = vcontador + 1;
           
        IF vcontador >= 10000 THEN
            LET vcontador = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET cNumCte     = '';
        LET cTelefono   = '';
        LET siTipoTel   = 0;
        LET siSecuencia = 0;
        LET cFechaHora  = '';
    END FOREACH;
    
    IF vabierto = '1' THEN
        LET vabierto = '0';
        COMMIT WORK;
    END IF;
    
    LET vcomienza = -1;
    LET vcontador = 0;
    
    -- // MODIFICACION EN si_telefonos_actual
    ALTER TABLE "informix".si_telefonos_actual ADD fecha_completa DATETIME YEAR TO SECOND BEFORE user_insert;
    
    FOREACH WITH HOLD
        SELECT numcte, telefono, tipo_tel, secuencia, fecha_hora
          INTO cNumCte, cTelefono, siTipoTel, siSecuencia, cFechaHora
          FROM "informix".si_telefonos_actual
         WHERE tipo_tel IN(1, 2, 3, 4)
         
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET vabierto = '1';
            BEGIN WORK;
        END IF;
        
        IF LENGTH(cFechaHora) = "23" THEN
            LET cFechaHora = SUBSTR(cFechaHora,1,19);
        ELIF LENGTH(cFechaHora) = "10" THEN
            LET cFechaHora = SUBSTR(TRIM(cFechaHora),7,10) || "-" || SUBSTR(TRIM(cFechaHora),1,2) || "-" || SUBSTR(TRIM(cFechaHora),4,5);
            LET cFechaHora = SUBSTR(cFechaHora,1,10) || " 00:00:00";
        END IF;
        
        LET cFechaHora = TRIM(cFechaHora);
        
        UPDATE "informix".si_telefonos_actual 
           SET fecha_completa = cFechaHora 
         WHERE numcte = cNumCte 
           AND telefono = cTelefono 
           AND tipo_tel = siTipoTel 
           AND secuencia = siSecuencia;
           
        LET vcontador = vcontador + 1;
           
        IF vcontador >= 10000 THEN
            LET vcontador = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET cNumCte     = '';
        LET cTelefono   = '';
        LET siTipoTel   = 0;
        LET siSecuencia = 0;
        LET cFechaHora  = '';
    END FOREACH;
    
    IF vabierto = '1' THEN
        LET vabierto = '0';
        COMMIT WORK;
    END IF;
    
    ALTER TABLE "informix".si_telefonos DROP fecha_hora;
    RENAME COLUMN "informix".si_telefonos.fecha_completa TO fecha_hora;
    
    ALTER TABLE "informix".si_telefonos_actual DROP fecha_hora;
    RENAME COLUMN "informix".si_telefonos_actual.fecha_completa TO fecha_hora;
    
    RETURN cCodRet;
    
    END;
    
END PROCEDURE
DOCUMENT
'DESCRIPCION: Cambia el tipo de dato al campo fecha_hora de la tabla si_telefonos',
'AUTOR: Iris Arias Zazueta',
'FECHA: 07-01-2013',
'VERSION: 1.0',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_desbloquearresetearbmovil(cNumCte CHAR(20), cStatus CHAR(2))

    --DATOS A REGRESAR
    RETURNING
    CHAR(5);   -- Codigo de Retorno

    --DEFINICION DE VARIABLES
    DEFINE sql_err      INT;
    DEFINE cCodRet      CHAR(5);

     --INICIALIZACION DE VARIABLES
    LET sql_err = 0;
    LET cCodRet =   '00000';

	--SET DEBUG FILE TO '/home/informix/ivonne/sp_desbloquearresetearbmovil.out';
	--TRACE ON;

	BEGIN

		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET cCodRet = sql_err;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;

		IF cCodRet = '00000'  THEN
		
			IF cStatus in ('95','90','85') THEN
			
				UPDATE bdinteg:"informix".si_bm_usuarios
				SET id_status = '30'
				WHERE numcte = cNumCte;
			
			END IF;

		ELSE
			LET cCodRet =   '00001';
		 END IF;

		RETURN cCodRet;

	END

END PROCEDURE

DOCUMENT
"Actualiza el estatus del cliente en Banca Móvil",
"Autor : Martha Aguirre",
"FECHA : 2011/09/13",
"BD    : bdinteg",
"VER   : 1.0",
"Se modifica para que se actualice a estatus 30 en cualquier desbloqueo o reseteo",
"Bibiana Gaxiola Verdugo",
"09/01/2013";

CREATE PROCEDURE "informix".sp_constelefonofechaact(pEmpresa CHAR(3), pNumcte CHAR(20))
	RETURNING 	CHAR(5) AS retorno;
	
	-- DEFINICION DE VARIABLES
	DEFINE iSqlErr			INTEGER;
	DEFINE cCodRet  		CHAR(5);
	DEFINE cFechaHr         CHAR(23);
	DEFINE dFechaHoy        DATE;
	
	--INICIALIZACION DE VARIABLES       
	LET cCodRet         = '00001';
	LET iSqlErr         = 0;
	LET cFechaHr        = '';
    LET dFechaHoy       =CURRENT;
	
	--SET DEBUG FILE TO "/respaldosbd/jasmin/sp_constelefonofechaact.out"; 
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO wait 3;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
			    LET cCodRet =  iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		
		IF NVL(pEmpresa,'') <> '' AND NVL(pNumcte,'') <>'' THEN
		
			IF EXISTS (SELECT numcte FROM "informix".si_telefonos WHERE empresa = pEmpresa AND numcte =pNumCte)THEN
				 SELECT MAX(fecha_hora) 
				 INTO cFechaHr 
				 FROM "informix".si_telefonos 
				 WHERE empresa = pEmpresa 
				 AND numcte = pNumCte;
				 
				LET cFechaHr = SUBSTRING(cFechaHr FROM 6 FOR 2) || "/" || SUBSTRING(cFechaHr FROM 9 FOR 2) || "/" || SUBSTRING(cFechaHr FROM 1 FOR 4);
				
				SELECT fecha_hoy 
				INTO dFechaHoy
				FROM "informix".si_fechas 
				WHERE empresa = pEmpresa;
				
				
			   IF dFechaHoy = cFechaHr THEN
					LET cCodRet = '00002';
			   ELSE 
					LET cCodRet = '00000';
				
			   END IF;
			ELSE
			  LET cCodRet = '00000';	
			END IF;
		
		END IF;
		
		RETURN cCodRet;
	END
END PROCEDURE             
DOCUMENT
'Creado: Jasmin Soto F.',
'Fecha: 13/11/2012',
'Descripcion: Se crea para capturar numero de telefono del cliente seleccionado',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_guarda_telefonos(pEmpresa CHAR(3), 
													    pNumcte CHAR (20), 
													    pTelcasa CHAR (10), 
													    pTelcelular CHAR (10), 
													    pTeloficina CHAR (10),
													    pTelotro CHAR (10),
													    pCarrier SMALLINT,
													    pExtension CHAR(5),
													    pUserInsert  CHAR(8))
	RETURNING CHAR(5) AS CodRetorno;

--Definicion de Variables
DEFINE iSqlErr 		   INTEGER;
DEFINE cCodRet 		   CHAR(5);

--Inicializacion de Variables
LET iSqlErr 		= 0;
LET cCodRet 		= '00000';

	--SET DEBUG FILE TO "/respaldosbd/jasmin/sp_guarda_telefonos.out"; 
	--TRACE ON; 

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
	IF NVL(pEmpresa,'') <> '' AND NVL(pNumcte,'') <> '' AND (NVL(pTelcasa, '') <> '' OR NVL(pTelcelular, '') <> '' OR NVL(pTeloficina, '') <> '' OR NVL(pTelotro, '') <> '') THEN
		
		IF pTelcasa <> '' THEN
			
			EXECUTE PROCEDURE "informix".sp_registra_telefonos (pEmpresa, pNumcte, pTelcasa, 1, '', 0, 1, pUserInsert) INTO cCodRet;
		
		END IF;
		IF cCodRet::INT = 0 OR cCodRet= '999' THEN
		
			IF pTelcelular <> '' THEN 
				
				EXECUTE PROCEDURE "informix".sp_registra_telefonos (pEmpresa, pNumcte, pTelcelular, 2, '', pCarrier, 1, pUserInsert) INTO cCodRet;
			
			END IF;
			IF cCodRet::INT = 0 OR cCodRet= '999' THEN
			 
				IF pTeloficina <> '' THEN
			
					EXECUTE PROCEDURE "informix".sp_registra_telefonos (pEmpresa, pNumcte, pTeloficina, 3, pExtension, 0, 1, pUserInsert) INTO cCodRet;
			
				END IF;
				
				IF cCodRet::INT = 0 OR cCodRet= '999' THEN
					IF pTelotro <> '' THEN 
						EXECUTE PROCEDURE "informix".sp_registra_telefonos (pEmpresa, pNumcte, pTelotro, 4, '', 0, 1, pUserInsert) INTO cCodRet;
			
					END IF;	
				END IF;
				 
			END IF;
		END IF;
	ELSE 
		LET cCodRet = '00001';	
	END IF;
	
RETURN cCodRet;

END;
END PROCEDURE

DOCUMENT
'DESCRIPCION: Se crea SP para registrar cada telefono del cliente',
'AUTOR : Jasmin Soto F. ',
'FECHA : 20/11/2012',
'VERSION: 1.0',
'BD: bdinteg';

create procedure "informix".cons_dir_cte_esp( pcliente char(20), pnum_regs smallint )
RETURNING char(5), char(50), char(10), char(10), char(10), char(30), char(60), char(30), 
          char(80), char(40), char(100), char(100), char(13), char(13), char(10), char(10), char(10);
    
    DEFINE v_codret      char(5);
    DEFINE v_calle		 char(30);
    DEFINE v_numext	     char(10);
    DEFINE v_numint      char(10);
    DEFINE v_depto	     char(6);
    DEFINE v_colonia     char(30);
    DEFINE v_ciudad	     char(60);
    DEFINE v_estado      char(30);
    DEFINE v_obs         char(80);   
    DEFINE v_entrecalles char(40);   
    DEFINE v_cp          char(5);   
    DEFINE v_tel1   	 char(13);   
    DEFINE v_tel2   	 char(13);   
    DEFINE v_tel3   	 char(13);   
    DEFINE v_ext 	  	 char(10);
    DEFINE v_tpdir 	  	 char(1);
    DEFINE v_tipodir  	 char(10);
    DEFINE v_fechacap  	 char(10);
    DEFINE v_contador    smallint;
    DEFINE sql_err       int;
    DEFINE isam_err      int;   
    
    LET v_codret = "000";
    
    BEGIN
    
    on exception set sql_err,isam_err
        if sql_err <> 0 or isam_err <> 0 then
            let v_codret = sql_err;
            RETURN v_codret, v_calle, v_numext, v_numint, v_depto, v_colonia, v_ciudad, v_estado, 
                   v_obs, v_entrecalles, v_cp, v_tel1, v_tel2, v_tel3, v_ext, v_fechacap, v_tipodir;
        end if;
    end exception;
    
    -- ****************************************************************************
    -- Valida la informacion de entrada
    -- ****************************************************************************
    IF pcliente is null then
        LET v_codret = 110;  -- datos de entrada incompletos	   
        RETURN v_codret, v_calle, v_numext, v_numint, v_depto, v_colonia, v_ciudad, v_estado,
               v_obs, v_entrecalles, v_cp, v_tel1, v_tel2, v_tel3, v_ext, v_fechacap, v_tipodir;
    END IF;
    
    -- ****************************************************************************
    -- Inicializar variables
    -- ****************************************************************************
    let v_contador = 0;
    let v_ciudad   = " ";
    
    -- ****************************************************************************
    -- obtener registros
    -- ****************************************************************************
    FOREACH  -- direcciones completas del cliente
        select cal.nombrecalle as calle, dir.numeroextcalle, dir.numerointcalle, dir.departamento,
               zon.nombrezona as colonia, nvl(cds.nombre," ") as cd, edo.nombre as edo, dir.cod_postal, dir.observaciones, dir.entre_calles,
               tel1.telefono, tel2.telefono, tel3.telefono, tel3.extension, decode(tel1.tipo_tel,'1','Particular'), dir.fecha_insert
          into v_calle, v_numext, v_numint, v_depto, v_colonia, v_ciudad, v_estado,
               v_cp, v_obs, v_entrecalles, v_tel1, v_tel2, v_tel3, v_ext, v_tipodir, v_fechacap
          from bdinteg:si_direcciones dir
          left outer join bdinteg:si_estados edo on(edo.estado = dir.estado)
          left outer join bdinteg:si_ciudades cds on(cds.ciudad = dir.ciudad and cds.estado = dir.estado and cds.pais = 1)
          left outer join bdinteg:si_catzonas zon on (zon.numerociudad = dir.numerociudad and zon.numerocolonia = dir.numerocolonia)
          left outer join bdinteg:si_catcalles cal on(cal.numerocalle = dir.numerocalle)
          left outer join bdinteg:si_telefonos_actual tel1 on (tel1.numcte = dir.numcte and tel1.tipo_tel = 1)
          left outer join bdinteg:si_telefonos_actual tel2 on (tel2.numcte = dir.numcte and tel2.tipo_tel = 2)
          left outer join bdinteg:si_telefonos_actual tel3 on (tel3.numcte = dir.numcte and tel3.tipo_tel = 3)
         where dir.numcte = pcliente
         order by dir.secuencia
         
    LET v_contador = v_contador +1;
    
    IF v_contador < pnum_regs then
        CONTINUE FOREACH;
    END IF;    
    
    RETURN v_codret, v_calle, v_numext, v_numint, v_depto, v_colonia, v_ciudad, v_estado,
           v_cp, v_obs, v_entrecalles, v_tel1, v_tel2, v_tel3, v_ext, v_tipodir, v_fechacap WITH resume;
    
    END FOREACH		
    
    END;    
    
END PROCEDURE;