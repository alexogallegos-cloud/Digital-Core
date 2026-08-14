CREATE PROCEDURE "informix".sp_consultaparametrosdigitalizacion(pEmpresa CHAR(3),pCodParam SMALLINT)
	RETURNING   CHAR(6) AS CODRET,
			  CHAR(100) AS VALOR,
			   CHAR(50) AS DESCRIPCION;

	--DECLARACION DE VARIABLES	    
	DEFINE cEmpresa			CHAR(3);
	DEFINE iSqlErr          INTEGER;
	DEFINE cCodRet          CHAR(6);
	DEFINE cValor           CHAR(100);
	DEFINE cDescripcion     CHAR(50);		
		
	--SET DEBUG FILE TO "/tmp/sp_ConsultaParametrosDigitalizacion.out";
	--TRACE ON;

	--INICIALIZACION DE  VARIABLES
	LET cEmpresa     = '';
	LET cCodRet      = '000000';
	LET cValor       = '';
	LET cDescripcion = '';

	BEGIN
	--CREA EL CONTROL DE ERRORES
		ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				RETURN cCodRet, cValor, cDescripcion;
			END IF;
		END EXCEPTION;

		--Validacion de parametros
        IF pEmpresa = '' or pEmpresa is null or length(pEmpresa) < 3 THEN
            LET cCodRet = '000001'; -- PARAMETRO EMPRESA VACIO
            RETURN cCodRet, cValor, cDescripcion;
        END IF;

        IF pCodParam < 0 THEN
            LET cCodRet = '000002'; -- LA CLAVE DE PARAMETRO NO ES POSITIVA
            RETURN cCodRet, cValor, cDescripcion;
        END IF;				
		

        --CONSULTO PARAMETROS DIGITALIZACION
		SELECT TRIM(NVL(valor, '')), TRIM(NVL(descripcion, ''))
		INTO cValor, cDescripcion
		FROM BDIDIGITAL:"informix".dg_params 
		WHERE empresa = pEmpresa 
		    AND cod_param = pCodParam;		
		
		IF cValor = '' OR cValor IS NULL THEN
			LET cCodRet = '000004';
		END IF;
		
		RETURN cCodRet,cValor,cDescripcion;
	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para la consulta de parametros en digitalizcion',
'AUTOR: Armando Mercado',
'FECHA: Mayo 2011',
'VERSION: 201105',
'BD: bdidigital';

CREATE PROCEDURE "informix".sp_dgactualizaetapaenvioenvio(pIdControl INTEGER, pValorCampo CHAR(50), pTipo SMALLINT)
	RETURNING CHAR(6);

	--DECLARACION DE VARIABLES		
		DEFINE iSqlErr              INTEGER;
		DEFINE cCodRet              CHAR(6);
        DEFINE iIdControl           INTEGER;		
	
	--Crea el archivo de monitoreo del proceso
	--SET DEBUG FILE TO "/tmp/SP_dgActualizaEtapaEnvioEnvio.out";
	--TRACE ON;

	--INICIALIZACION DE  VARIABLES		
		LET cCodRet= '000000';
		LET iIdControl= 0;
			
	BEGIN
	--CREA EL CONTROL DE ERRORES
		ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;        
		
		set isolation to dirty read;
		set lock mode to wait 3;
         
		IF pIdControl <= 0 THEN
            LET cCodRet = '000001'; -- PARAMETRO ID_CONTROL INVALIDO
            RETURN cCodRet;
        END IF;
		
		SELECT id_control
		INTO iIdControl
		FROM BDIDIGITAL:dg_expediente_envio
		WHERE id_control = pIdControl;

        IF iIdControl IS NULL OR iIdControl = '' THEN
            LET cCodRet = '000002'; -- ID_CONTROL NO EXISTE EN CATALOGO
            RETURN cCodRet;
        END IF;
		
        IF pValorCampo = '' THEN
            LET cCodRet = '000003'; -- PARAMETRO VALOR_CAMPO VIENE VACIO
            RETURN cCodRet;
        END IF;

        IF pTipo <> 1 AND pTipo <> 2 AND pTipo <> 3 AND pTipo <> 4 THEN
           LET cCodRet = '000004'; -- PARAMETRO TIPO NO VALIDO
		END IF
		        		        
		--ACTUALIZA LA SECUENCIA 
		IF pTipo = 1 THEN
		    UPDATE BDIDIGITAL:dg_expediente_envio SET secuencia =  pValorCampo::INTEGER --" & v_Secuencia 
	        WHERE id_control = pIdControl; --" & Val(t_ID)
		END IF
		
		--ACTUALIZAR CON EL NOMBRE DEL ZIP
		IF pTipo = 2 THEN
			UPDATE BDIDIGITAL:dg_expediente_envio SET ctl_archivo_zip = pValorCampo --'" & archivozip & "'" & _
			WHERE id_control = pIdControl; --" & Val(t_ID)
		END IF
		
		--ACTUALIZAR EL STATUS DE CTL_IMG_ENVIADA
		IF pTipo = 3 THEN
			UPDATE BDIDIGITAL:dg_expediente_envio SET ctl_img_enviada = pValorCampo
			WHERE id_control = pIdControl; --" & Val(t_ID)
		END IF
		
		--ACTUALIZAR EL STATUS DE CTL_PROCESADO
		IF pTipo = 4 THEN
			UPDATE BDIDIGITAL:dg_expediente_envio SET ctl_procesado = pValorCampo
			WHERE id_control = pIdControl; --" & Val(t_ID)
		END IF
					       
        RETURN cCodRet;
		
	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Actualiza en la tabla "dg_expediente_envio" ',
'tomando como parametro o dato de entrada, IdControl, CtlProcesado, ValorCampo y el Tipo',
'AUTOR: Guadalupe Payan',
'FECHA: Noviembre 2010',
'VERSION: 201004',
'BD: BDIDIGITAL';

CREATE PROCEDURE "informix".sp_dgconsultadefinicionesporproducto(pEmpresa CHAR(3),pCodSistema CHAR(2),pCodProducto CHAR(4))
	RETURNING CHAR(6),CHAR(3),CHAR(50);

	--DECLARACION DE VARIABLES	    
		DEFINE cEmpresa		CHAR(3);
		DEFINE iSqlErr      INTEGER;
		DEFINE cCodRet      CHAR(6);
		DEFINE cCodSistema  CHAR(2);
		DEFINE cCodProducto CHAR(4);
		DEFINE cCodDefinicion CHAR(3);
		DEFINE cProdNombre  CHAR(50);	
		
	--CREA EL ARCHIVO DE MONITOREO DEL PROCESO
	--SET DEBUG FILE TO "/tmp/sp_DgConsultaDefinicionesPorProducto.out";
	--TRACE ON;

	--INICIALIZACION DE  VARIABLES
		LET cEmpresa= '';
		LET cCodRet= '000000';
	    LET cCodSistema= '';
		LET cCodProducto= '';
		LET cCodDefinicion= '';
        LET cProdNombre= '';
		
	BEGIN
	--CREA EL CONTROL DE ERRORES
		ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				RETURN cCodRet,cCodDefinicion,cProdNombre;
			END IF;
		END EXCEPTION;
        
        set isolation to dirty read;
        set lock mode to wait 3;

        IF pEmpresa = '' THEN
            LET cCodRet = '000001'; -- PARAMETRO EMPRESA VACIO
            RETURN cCodRet,cCodDefinicion,cProdNombre;
        END IF;

        IF pCodSistema = ''  THEN
            LET cCodRet = '000002'; -- PARAMETRO CODIGO SISTEMA ESTA VACIO 
            RETURN cCodRet,cCodDefinicion,cProdNombre;
        END IF;
		
		IF pCodProducto = ''  THEN
            LET cCodRet = '000003'; -- PARAMETRO CODIGO PRODUCTO ESTA VACIO 
            RETURN cCodRet,cCodDefinicion,cProdNombre;
        END IF;
							       	
		IF LENGTH(pCodSistema) <> 2 THEN
            LET cCodRet = '000004'; -- PARAMETRO CODIGO SISTEMA NO VALIDO
            RETURN cCodRet,cCodDefinicion,cProdNombre;
        END IF;

        IF LENGTH(pCodProducto) <> 4 THEN
            LET cCodRet = '000005'; -- PARAMETRO CODIGO PRODUCTO NO VALIDO
            RETURN cCodRet,cCodDefinicion,cProdNombre;
        END IF;				
	    					
		SELECT empresa
		INTO cEmpresa
		FROM BDINTEG:si_empresas
		WHERE empresa = pEmpresa;
        IF cEmpresa IS NULL OR cEmpresa = '' THEN
            LET cCodRet = '000006'; -- EMPRESA NO EXISTE EN CATALOGO
            RETURN cCodRet,cCodDefinicion,cProdNombre;
        END IF;  
						 
		--CONSULTA PARAMETROS DIGITALIZACION
		
		SELECT cod_definicion,prod_nombre
		INSERT INTO cCodDefinicion,cProdNombre
		FROM BDIDIGITAL@COPPELIMG_TCP:dg_definicion 
		WHERE empresa = pEmpresa
		AND cod_sistema = pCodSistema --'" & Sistema & "' " & _
        AND cod_producto = pCodProducto; --'" & Producto & "'

		IF cCodDefinicion='' OR cCodDefinicion IS NULL THEN
		LET cCodRet = '000007';		END IF;			  
		
		RETURN cCodRet,cCodDefinicion,cProdNombre;
		
	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Genera una consulta en las tabla dg_definicion',
'tomando como parametro o dato de entrada, la Empresa,el Codigo de Sistema,el Codigo de Producto',
'para obtener los Parametros necesarios para ejecutar la aplicacion',
'AUTOR: Guadalupe Payan',
'FECHA: Octubre 2010',
'VERSION: 201027',
'BD: BDIDIGITAL';

CREATE PROCEDURE "informix".sp_dgconsultadocumentosdijotraercliente(pEmpresa CHAR(3),pCuenta CHAR(20),pProducto CHAR(4),pAccion CHAR(1))
	RETURNING CHAR(6),CHAR(100),CHAR(8),DATE;

	--DECLARACION DE VARIABLES	    
		DEFINE cEmpresa		CHAR(3);
		DEFINE iSqlErr      INTEGER;
		DEFINE cCodRet      CHAR(6);
		DEFINE vParametros  CHAR(100);
		DEFINE cProducto    CHAR(4);
		DEFINE cCodUsuario  CHAR(8);
		DEFINE dFechaAlta   DATE;
			
	--CREA EL ARCHIVO DE MONITOREO DEL PROCESO
	--SET DEBUG FILE TO "/tmp/sp_DgConsultaDocumentosDijoTraerCliente.out";
	--TRACE ON;

	--INICIALIZACION DE  VARIABLES
		LET cEmpresa= '';
		LET cCodRet= '000000';
	    LET vParametros= '';
		LET cProducto= '';
        LET cCodUsuario= '';
		LET dFechaAlta= '';
	BEGIN
	--CREA EL CONTROL DE ERRORES
		ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				RETURN cCodRet,vParametros,cCodUsuario,dFechaAlta;
			END IF;
		END EXCEPTION;
        
        set isolation to dirty read;
        set lock mode to wait 3;

        IF pEmpresa = '' THEN
            LET cCodRet = '000001'; -- PARAMETRO EMPRESA VACIO
            RETURN cCodRet,vParametros,cCodUsuario,dFechaAlta;
        END IF;

        IF pCuenta = ''  THEN
            LET cCodRet = '000002'; -- LA CUENTA ESTA VACIO 
            RETURN cCodRet,vParametros,cCodUsuario,dFechaAlta;
        END IF;
		
		IF pProducto = ''  THEN
            LET cCodRet = '000003'; -- EL PRODUCTO ESTA VACIO 
            RETURN cCodRet,vParametros,cCodUsuario,dFechaAlta;
        END IF;
		
		IF pAccion = ''  THEN
            LET cCodRet = '000004'; -- ACCION ESTA VACIO 
            RETURN cCodRet,vParametros,cCodUsuario,dFechaAlta;
        END IF;
				
        --LET pProducto = pProducto;
        --LET cProducto = LENGTH(pProducto);
       		
		IF LENGTH(pProducto) <> 4 THEN
            LET cCodRet = '000005'; -- PARAMETRO CODIGO DE PRODUCTO NO VALIDO
            RETURN cCodRet,vParametros,cCodUsuario,dFechaAlta;
        END IF;

        IF LENGTH(pAccion) <> 1 THEN
            LET cCodRet = '000006'; -- PARAMETRO ACCION NO VALIDO
            RETURN cCodRet,vParametros,cCodUsuario,dFechaAlta;
        END IF;				
	    					
		SELECT empresa
		INTO cEmpresa
		FROM bdinteg:si_empresas
		WHERE empresa = pEmpresa;

        IF cEmpresa IS NULL OR cEmpresa = '' THEN
            LET cCodRet = '000007'; -- EMPRESA NO EXISTE EN CATALOGO
            RETURN cCodRet,vParametros,cCodUsuario,dFechaAlta;
        END IF;  
		
		IF pAccion = 'C' THEN 			  
			--CONSULTA PARAMETROS DIGITALIZACION
			SELECT parametros,cod_usuario,fecha_alta 
			INTO vParametros,cCodUsuario,dFechaAlta
			FROM BDIDIGITAL:dg_pasoparam 				
			WHERE empresa = pEmpresa  
				  AND cuenta = pCuenta -- v_Cta 
				  AND producto = pProducto; --v_Prod 	
			
			IF vParametros='' OR vParametros IS NULL THEN
				LET cCodRet = '000008';			END IF;			  
		ELIF pAccion = 'B' THEN 
			DELETE FROM BDIDIGITAL:dg_pasoparam 
			WHERE empresa = pEmpresa
				  AND cuenta = pCuenta --" & v_Cta & "' 
				  AND producto = pProducto; --" & v_Prod & "' 
		ELSE 
			LET cCodRet = '000009'; -- EL TIPO DE ACCION ES INVALIDA
		END IF
		RETURN cCodRet,vParametros,cCodUsuario,dFechaAlta;
		
	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Genera una consulta en las tabla dg_pasoparam',
'tomando como parametro o dato de entrada, la Empresa,la Cuenta,el Producto y al Accion a Realizar',
'para obtener los Parametros necesarios para ejecutar la aplicacion',
'AUTOR: Guadalupe Payan',
'FECHA: Octubre 2010',
'VERSION: 201027',
'BD: BDIDIGITAL';

CREATE PROCEDURE "informix".sp_dgconsultaparametrosdigitalizacion(pEmpresa CHAR(3),pCodParam SMALLINT)
	RETURNING CHAR(6),CHAR(100),CHAR(50);

	--DECLARACION DE VARIABLES	    
		DEFINE cEmpresa		CHAR(3);
		DEFINE iSqlErr          INTEGER;
		DEFINE cCodRet          CHAR(6);
		DEFINE cValor           CHAR(100);
		DEFINE cDescripcion     CHAR(50);		
			
	--CREA EL ARCHIVO DE MONITOREO DEL PROCESO
	--SET DEBUG FILE TO "/tmp/sp_DgConsultaParametrosDigitalizacion.out";
	--TRACE ON;

	--INICIALIZACION DE  VARIABLES
		LET cEmpresa= '';
		LET cCodRet= '000000';
		LET cValor= '';
		LET cDescripcion= '';

	BEGIN
	--CREA EL CONTROL DE ERRORES
		ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				RETURN cCodRet,cValor,cDescripcion;
			END IF;
		END EXCEPTION;
        
        set isolation to dirty read;
        set lock mode to wait 3;

        IF pEmpresa = '' THEN
            LET cCodRet = '000001'; -- PARAMETRO EMPRESA VACIO
            RETURN cCodRet,cValor,cDescripcion;
        END IF;

        IF pCodParam <0 THEN
            LET cCodRet = '000002'; -- LA CLAVE DE PARAMETRO NO ES POSITIVA
            RETURN cCodRet,cValor,cDescripcion;
        END IF;
					
		SELECT empresa
		INTO cEmpresa
		FROM bdinteg:si_empresas
		WHERE empresa = pEmpresa;

        IF cEmpresa IS NULL OR cEmpresa = '' THEN
            LET cCodRet = '000003'; -- EMPRESA NO EXISTE EN CATALOGO
            RETURN cCodRet,cValor,cDescripcion;
        END IF;

        --CONSULTO PARAMETROS DIGITALIZACION
		SELECT	valor,descripcion
		INTO cValor,cDescripcion
		FROM BDIDIGITAL:dg_params 
		WHERE empresa = pEmpresa 
		      AND cod_param = pCodParam;		
		
		IF cValor='' OR cValor IS NULL THEN
			LET cCodRet = '000004';		END IF;
		RETURN cCodRet,cValor,cDescripcion;
	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Genera una consulta en las tabla dg_params',
'tomando como parametro o dato de entrada, la Empresa y la Clave de Parametro',
'para obtener los Parametros necesarios para ejecutar la aplicacion',
'AUTOR: Guadalupe Payan',
'FECHA: Octubre 2010',
'VERSION: 201026',
'BD: BDIDIGITAL';

CREATE PROCEDURE "informix".sp_dgconsultaparametrosdigitalizacionlike(pEmpresa CHAR(3),pCodParamIni SMALLINT,pCodParamFin SMALLINT)
	RETURNING CHAR(6),SMALLINT,CHAR(100),CHAR(50);

	--DECLARACION DE VARIABLES	    
		DEFINE cEmpresa		CHAR(3);
		DEFINE iSqlErr          INTEGER;
		DEFINE cCodRet          CHAR(6);
		DEFINE cValor           CHAR(100);
		DEFINE cDescripcion	CHAR(50);	
		DEFINE cCodParam     SMALLINT;
        
			
	--CREA EL ARCHIVO DE MONITOREO DEL PROCESO
	--SET DEBUG FILE TO "/tmp/sp_DgConsultaParametrosDigitalizacionLike.out";
	--TRACE ON;

	--INICIALIZACION DE  VARIABLES
		LET cEmpresa= '';
		LET cCodRet= '000000';
		LET cValor= '';
		LET cCodParam= '';
		LET cDescripcion= '';

	BEGIN
	--CREA EL CONTROL DE ERRORES
		ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				RETURN cCodRet,cCodParam,cValor,cDescripcion;
			END IF;
		END EXCEPTION;
        
        set isolation to dirty read;
        set lock mode to wait 3;

        IF pEmpresa = '' THEN
            LET cCodRet = '000001'; -- PARAMETRO EMPRESA VACIO
            RETURN cCodRet,cCodParam,cValor,cDescripcion;
        END IF;

        IF pCodParamIni <0 THEN
            LET cCodRet = '000002'; -- LA CLAVE DE PARAMETRO INICIAL NO ES POSITIVA 
            RETURN cCodRet,cCodParam,cValor,cDescripcion;
        END IF;
		
		IF pCodParamFin <0 THEN
            LET cCodRet = '000003'; -- LA CLAVE DE PARAMETRO FINAL NO ES POSITIVA
            RETURN cCodRet,cCodParam,cValor,cDescripcion;
        END IF;
	    
        IF pCodParamIni > pCodParamFin THEN
            LET cCodRet = '000004'; -- LA CLAVE DE PARAMETRO INICIAL ES MAYOR QUE LA FINAL
            RETURN cCodRet,cCodParam,cValor,cDescripcion;
        END IF;		
	
						
		SELECT empresa
		INTO cEmpresa
		FROM bdinteg:si_empresas
		WHERE empresa = pEmpresa;
        IF cEmpresa IS NULL OR cEmpresa = '' THEN
            LET cCodRet = '000005'; -- EMPRESA NO EXISTE EN CATALOGO
            RETURN cCodRet,cCodParam,cValor,cDescripcion;
        END IF;
		
        FOREACH
	        --CONSULTA PARAMETROS DIGITALIZACION
			SELECT cod_param,valor,descripcion 
			INTO cCodParam,cValor,cDescripcion
			FROM bdidigital:dg_params 
			WHERE empresa = '001' 		      
	              AND cod_param >= pCodParamIni AND cod_param <= pCodParamFin					
			RETURN cCodRet,cCodParam,cValor,cDescripcion WITH resume;
		END FOREACH
		
		IF cCodParam='' OR cCodParam IS NULL THEN
		   LET cCodRet = '000006';		END IF;
	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Genera una consulta en las tabla dg_params',
'tomando como parametro o dato de entrada, la Empresa,la Clave de Parametro inicial y Final',
'para obtener los Parametros necesarios para ejecutar la aplicacion',
'AUTOR: Guadalupe Payan',
'FECHA: Octubre 2010',
'VERSION: 201027',
'BD: BDIDIGITAL';

CREATE PROCEDURE "informix".sp_dgconsultapendientesenvio(pEmpresa CHAR(3),pCtlProcesado CHAR(1),pCtlLigado CHAR(1),pMacaddressLocal CHAR(17))
	RETURNING CHAR(6),INTEGER,CHAR(20),CHAR(20),CHAR(4),CHAR(4),INTEGER,CHAR(40),CHAR(25),CHAR(50),CHAR(1),CHAR(1),CHAR(1),
	          CHAR(150),CHAR(8),CHAR(35),CHAR(30);

	--DECLARACION DE VARIABLES
		DEFINE cEmpresa		    	CHAR(3);
		DEFINE iSqlErr              INTEGER;
		DEFINE cCodRet              CHAR(6);
		DEFINE iIdControl       	INTEGER ;
		DEFINE cCliente    			CHAR(20);
		DEFINE cCuenta 				CHAR(20);
		DEFINE cProducto 			CHAR(4);
		DEFINE cCodDocto 			CHAR(4);
		DEFINE iSecuencia 			INTEGER;
		DEFINE cProdNombre 			CHAR(40);
		DEFINE vCtlArchivoLocal 	CHAR(25);
		DEFINE vCtlArchivoZip 		CHAR(50);
		DEFINE cCtlImgEnviada 		CHAR(1);
		DEFINE cCtlProcesado 		CHAR(1);
		DEFINE cCtlLigado 			CHAR(1);
		DEFINE vCtlArchivoLocalRuta CHAR(150);
		DEFINE cUsuarioAlta  		CHAR(8);
		DEFINE vDescripcion 		CHAR(35);
		DEFINE cDescrip2 			CHAR(30);
	
	--CREA EL ARCHIVO DE MONITOREO DEL PROCESO
	--SET DEBUG FILE TO "/tmp/SP_dgConsultaPendientesEnvio.out";
	--TRACE ON;

	--INICIALIZACION DE  VARIABLES
		LET cEmpresa= '';
		LET cCodRet= '000000';
		LET	iIdControl= 0;
		LET	cCliente= '';
		LET	cCuenta= '';
		LET	cProducto= '';
		LET	cCodDocto= '';
		LET	iSecuencia= 0;
		LET	cProdNombre= '';
		LET	vCtlArchivoLocal= '';
		LET	vCtlArchivoZip= '';
		LET	cCtlImgEnviada= '';
		LET	cCtlProcesado= '';
		LET	cCtlLigado= '';
		LET	vCtlArchivoLocalRuta= '';
		LET	cUsuarioAlta= '';
		LET	vDescripcion= '';
		LET	cDescrip2= '';

	BEGIN
	--CREA EL CONTROL DE ERRORES
		ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				RETURN cCodRet,iIdControl,cCliente,cCuenta,cProducto,cCodDocto,iSecuencia,cProdNombre,vCtlArchivoLocal,
				       vCtlArchivoZip,cCtlImgEnviada,cCtlProcesado,cCtlLigado,vCtlArchivoLocalRuta,cUsuarioAlta,vDescripcion,cDescrip2;
			END IF;
		END EXCEPTION;
        
        set isolation to dirty read;
        set lock mode to wait 3;

        IF pEmpresa = '' THEN
            LET cCodRet = '000001'; -- PARAMETRO EMPRESA VACIO
            RETURN cCodRet,iIdControl,cCliente,cCuenta,cProducto,cCodDocto,iSecuencia,cProdNombre,vCtlArchivoLocal,
				       vCtlArchivoZip,cCtlImgEnviada,cCtlProcesado,cCtlLigado,vCtlArchivoLocalRuta,cUsuarioAlta,vDescripcion,cDescrip2;
        END IF;

        IF pCtlProcesado = '' THEN
            LET cCodRet = '000002'; -- PARAMETRO CTL_PROCESADO VIENE VACIO
            RETURN cCodRet,iIdControl,cCliente,cCuenta,cProducto,cCodDocto,iSecuencia,cProdNombre,vCtlArchivoLocal,
				       vCtlArchivoZip,cCtlImgEnviada,cCtlProcesado,cCtlLigado,vCtlArchivoLocalRuta,cUsuarioAlta,vDescripcion,cDescrip2;
        END IF;
		
		IF pCtlLigado = '' THEN
            LET cCodRet = '000003'; -- PARAMETRO CTL_LIGADO VIENE VACIO
            RETURN cCodRet,iIdControl,cCliente,cCuenta,cProducto,cCodDocto,iSecuencia,cProdNombre,vCtlArchivoLocal,
				       vCtlArchivoZip,cCtlImgEnviada,cCtlProcesado,cCtlLigado,vCtlArchivoLocalRuta,cUsuarioAlta,vDescripcion,cDescrip2;
        END IF;
		
		IF pMacaddressLocal = '' THEN
            LET cCodRet = '000004'; -- PARAMETRO MACADDRESS_LOCAL VIENE VACIO
            RETURN cCodRet,iIdControl,cCliente,cCuenta,cProducto,cCodDocto,iSecuencia,cProdNombre,vCtlArchivoLocal,
				       vCtlArchivoZip,cCtlImgEnviada,cCtlProcesado,cCtlLigado,vCtlArchivoLocalRuta,cUsuarioAlta,vDescripcion,cDescrip2;
        END IF;
		
		
        IF pCtlProcesado <> 1 AND pCtlProcesado <> 0 THEN		
            LET cCodRet = '000005'; -- PARAMETRO CTL_PROCESADO NO VALIDO
            RETURN cCodRet,iIdControl,cCliente,cCuenta,cProducto,cCodDocto,iSecuencia,cProdNombre,vCtlArchivoLocal,
				       vCtlArchivoZip,cCtlImgEnviada,cCtlProcesado,cCtlLigado,vCtlArchivoLocalRuta,cUsuarioAlta,vDescripcion,cDescrip2;
        END IF;
		
		IF pCtlLigado <> 1 AND pCtlLigado <> 0 THEN		
            LET cCodRet = '000006'; -- PARAMETRO CTL_LIGADO NO VALIDO
            RETURN cCodRet,iIdControl,cCliente,cCuenta,cProducto,cCodDocto,iSecuencia,cProdNombre,vCtlArchivoLocal,
				       vCtlArchivoZip,cCtlImgEnviada,cCtlProcesado,cCtlLigado,vCtlArchivoLocalRuta,cUsuarioAlta,vDescripcion,cDescrip2;
        END IF;
        
        IF LENGTH(pCtlProcesado) <> 1 THEN		
            LET cCodRet = '000007'; -- PARAMETRO CTL_PROCESADO NO VALIDO
            RETURN cCodRet,iIdControl,cCliente,cCuenta,cProducto,cCodDocto,iSecuencia,cProdNombre,vCtlArchivoLocal,
				       vCtlArchivoZip,cCtlImgEnviada,cCtlProcesado,cCtlLigado,vCtlArchivoLocalRuta,cUsuarioAlta,vDescripcion,cDescrip2;
        END IF;
		
		IF LENGTH(pCtlLigado) <> 1 THEN		
            LET cCodRet = '000008'; -- PARAMETRO CTL_LIGADO NO VALIDO
            RETURN cCodRet,iIdControl,cCliente,cCuenta,cProducto,cCodDocto,iSecuencia,cProdNombre,vCtlArchivoLocal,
				       vCtlArchivoZip,cCtlImgEnviada,cCtlProcesado,cCtlLigado,vCtlArchivoLocalRuta,cUsuarioAlta,vDescripcion,cDescrip2;
        END IF;
        SELECT empresa
		INTO cEmpresa
		FROM BDINTEG:si_empresas
		WHERE empresa = pEmpresa;

        IF cEmpresa IS NULL OR cEmpresa = '' THEN
            LET cCodRet = '000009'; -- EMPRESA NO EXISTE EN CATALOGO
            RETURN cCodRet,iIdControl,cCliente,cCuenta,cProducto,cCodDocto,iSecuencia,cProdNombre,vCtlArchivoLocal,
				       vCtlArchivoZip,cCtlImgEnviada,cCtlProcesado,cCtlLigado,vCtlArchivoLocalRuta,cUsuarioAlta,vDescripcion,cDescrip2;
        END IF;

        --OBTENGO LOS DOCUMENTOS PENDIENTES DE ENVIAR
	    FOREACH 		 
			SELECT d.id_control,d.cliente,d.cuenta,d.producto,d.cod_docto,d.secuencia,d.prod_nombre,
					d.ctl_archivo_local,d.ctl_archivo_zip,d.ctl_img_enviada,d.ctl_procesado,d.ctl_ligado,
					d.ctl_archivo_local_ruta,d.usuario_alta,t.descripcion,d.descrip2
			INTO iIdControl,cCliente,cCuenta,cProducto,cCodDocto,iSecuencia,cProdNombre,vCtlArchivoLocal,
					vCtlArchivoZip,cCtlImgEnviada,cCtlProcesado,cCtlLigado,vCtlArchivoLocalRuta,cUsuarioAlta,
					vDescripcion,cDescrip2
			FROM BDIDIGITAL:dg_expediente_envio d INNER JOIN BDIDIGITAL@COPPELIMG_TCP:dg_tipodocumento t ON (d.cod_docto = t.cod_docto)
			WHERE d.empresa = pEmpresa
				AND  d.ctl_procesado = pCtlProcesado 
				AND d.ctl_ligado = pCtlLigado 
				AND d.macaddress_local = pMacaddressLocal --'" & strMacLocal & "' 
			ORDER BY 1
	       
           RETURN cCodRet,iIdControl,cCliente,cCuenta,cProducto,cCodDocto,iSecuencia,cProdNombre,vCtlArchivoLocal,
				       vCtlArchivoZip,cCtlImgEnviada,cCtlProcesado,cCtlLigado,vCtlArchivoLocalRuta,cUsuarioAlta,
					   vDescripcion,cDescrip2 WITH resume;	       
		END FOREACH
		
		IF iIdControl='' OR iIdControl IS NULL THEN
	            LET cCodRet = '000010';				RETURN cCodRet,iIdControl,cCliente,cCuenta,cProducto,cCodDocto,iSecuencia,cProdNombre,vCtlArchivoLocal,
				       vCtlArchivoZip,cCtlImgEnviada,cCtlProcesado,cCtlLigado,vCtlArchivoLocalRuta,cUsuarioAlta,vDescripcion,cDescrip2;
	    END IF;
	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Genera una consulta en las tablas dg_expediente_envio,dg_tipodocumento',
'tomando como parametro o dato de entrada, la Empresa, CtlProcesado, CtlLigado y MacaddressLocal',
'AUTOR: Guadalupe Payan',
'FECHA: Noviembre 2010',
'VERSION: 201004',
'BD: BDIDIGITAL';

CREATE PROCEDURE "informix".sp_dgconsultapendientesenvioporcliente(pEmpresa CHAR(3),pCliente CHAR(20),pCodDocto CHAR(4),pSecuencia INTEGER,pMacaddressLocal CHAR(17))
	RETURNING CHAR(6),SMALLINT;

	--DECLARACION DE VARIABLES		
		DEFINE cEmpresa		    	CHAR(3);
		DEFINE iSqlErr              INTEGER;
		DEFINE cCodRet              CHAR(6);
        DEFINE cCodDocto		    CHAR(4);
		DEFINE iSecuencia           INTEGER;
	    DEFINE cMacaddressLocal     CHAR(17);
		DEFINE sRegLigSecIncorreta  SMALLINT;
		
	--CREA EL ARCHIVO DE MONITOREO DEL PROCESO
	--SET DEBUG FILE TO "/tmp/SP_dgConsultaPendientesEnvioPorCliente.out";
	--TRACE ON;

	--INICIALIZACION DE  VARIABLES	
        LET cEmpresa = ''; 	
		LET cCodRet = '000000';
		LET cCodDocto = '';
		LET iSecuencia = 0;
		LET cMacaddressLocal = '';
		LET sRegLigSecIncorreta = 0;
			
	BEGIN
	--CREA EL CONTROL DE ERRORES
		ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				RETURN cCodRet,sRegLigSecIncorreta;
			END IF;
		END EXCEPTION;
        
        set isolation to dirty read;
        set lock mode to wait 3;
				
		IF pEmpresa = '' THEN
            LET cCodRet = '000001'; -- PARAMETRO EMPRESA VACIO
            RETURN cCodRet,sRegLigSecIncorreta;
        END IF;     

		 IF pCliente = '' THEN
            LET cCodRet = '000002'; -- PARAMETRO CLIENTE VIENE VACIO
            RETURN cCodRet,sRegLigSecIncorreta;
        END IF;
		
		IF pCodDocto = '' THEN
            LET cCodRet = '000003'; -- PARAMETRO CODIGO_DOCUMENTO VIENE VACIO
            RETURN cCodRet,sRegLigSecIncorreta;
        END IF;
		
		IF LENGTH(pCodDocto) <> 4 THEN		
            LET cCodRet = '000004'; -- PARAMETRO COD_DOCTO NO VALIDO
            RETURN cCodRet,sRegLigSecIncorreta;
        END IF;
        		
		IF pMacaddressLocal = '' THEN
            LET cCodRet = '000005'; -- PARAMETRO MACADDRESS_LOCAL VIENE VACIO
            RETURN cCodRet,sRegLigSecIncorreta;
        END IF;
		
		SELECT empresa
		INTO cEmpresa
		FROM BDINTEG:si_empresas
		WHERE empresa = pEmpresa;
        IF cEmpresa IS NULL OR cEmpresa = '' THEN
            LET cCodRet = '000006'; -- EMPRESA NO EXISTE EN CATALOGO
            RETURN cCodRet,sRegLigSecIncorreta;
        END IF;
       	--OBTIENE TOTAL DE REGISTROS LIGADOS CON SECUENCIA INCORRECTA	        		        
		SELECT count(cuenta)
		INTO sRegLigSecIncorreta
		FROM BDIDIGITAL:dg_expediente_envio
		WHERE empresa = pEmpresa AND cliente = pCliente --" & Trim(t_Cte) & "' 
			AND cod_docto= pCodDocto  --" & Trim(t_Cod_Docto) & "' 
			AND ctl_ligado='1' 
			AND secuencia = pSecuencia --" & Val(t_sec_vieja) 
			AND macaddress_local = pMacaddressLocal; --" & strMacLocal & "'"
					       
        RETURN cCodRet,sRegLigSecIncorreta;
		
	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Consulta en la tabla dg_expediente_envio ',
'tomando como parametro o dato de entrada, la Empresa, el Cliente, el Codigo Documento,la Secuencia,y la MacaddressLocal',
'AUTOR: Guadalupe Payan',
'FECHA: Noviembre 2010',
'VERSION: 201004',
'BD: BDIDIGITAL';

CREATE PROCEDURE "informix".sp_diginsertadoctopendienteimagen(pEmpresa CHAR(3),pCliente CHAR(20),pCuenta CHAR(20),pProducto CHAR(4),
                                                   pCodDocto CHAR(4),pProdNombre CHAR(40),pSecuencia INTEGER,
												   pCtlArchivoLocal CHAR(25),pCtlArchivoLocalRuta CHAR(150),pCtlImgEnviada CHAR(1),
												   pCtlProcesado CHAR(1),pCtlLigado CHAR(1),pMacaddressLocal CHAR(17),
												   pDescrip2 CHAR(30),pUsuarioAlta CHAR(8),pFechaAlta DATE)
	RETURNING CHAR(6);

	--Declaracion de variables		
		DEFINE cEmpresa		    	CHAR(3);
		DEFINE iSqlErr              INTEGER;
		DEFINE cCodRet              CHAR(6);		
      		
	--Crea el archivo de monitoreo del proceso
	--SET DEBUG FILE TO "/tmp/sp_DigInsertaDoctoPendienteImagen.out";
	--TRACE ON;

	--inicializacion de  variables	
        LET cEmpresa = ''; 	
		LET cCodRet = '000000';		
		
	BEGIN
	--Crea el control de errores
		ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
        
        set isolation to dirty read;
        set lock mode to wait 3;

		IF pEmpresa = '' THEN
            LET cCodRet = '000001'; -- PARAMETRO EMPRESA VACIO
            RETURN cCodRet;
        END IF;     

		IF pCliente = '' THEN
            LET cCodRet = '000002'; -- PARAMETRO CLIENTE VIENE VACIO
            RETURN cCodRet;
        END IF;
		
		 IF pCuenta = '' THEN
            LET cCodRet = '000003'; -- PARAMETRO CUENTA VIENE VACIO
            RETURN cCodRet;
        END IF;
		IF pProducto = '' THEN
            LET cCodRet = '000004'; -- PARAMETRO PRODUCTO VIENE VACIO
            RETURN cCodRet;
        END IF;
        
		IF pCodDocto = '' THEN
            LET cCodRet = '000005'; -- PARAMETRO  COD_DOCTO VIENE VACIO
            RETURN cCodRet;
        END IF;
		
	    IF LENGTH(pCodDocto) <> 4 THEN		
            LET cCodRet = '000006'; -- PARAMETRO COD_DOCTO NO VALIDO
            RETURN cCodRet;
        END IF;
		
		IF pProdNombre = '' THEN
            LET cCodRet = '000007'; -- PARAMETRO PROD_NOMBRE  VIENE VACIO
            RETURN cCodRet;
        END IF;
				
		IF pCtlImgEnviada = '' THEN
            LET cCodRet = '000010'; -- PARAMETRO CTL_IMG_ENVIADA VIENE VACIO
            RETURN cCodRet;
        END IF;
		
		IF pCtlImgEnviada <> 1 AND pCtlImgEnviada <> 0 THEN
		    LET cCodRet = '000011'; -- PARAMETRO CTL_IMG_ENVIADA NO VALIDO
            RETURN cCodRet;
        END IF;
		
		IF pCtlProcesado= '' THEN
            LET cCodRet = '000012'; -- PARAMETRO CTL_PROCESADO VIENE VACIO
            RETURN cCodRet;
        END IF;
		
		 IF pCtlProcesado <> 1 AND pCtlProcesado <> 0 THEN		
            LET cCodRet = '000013'; -- PARAMETRO CTL_PROCESADO NO VALIDO
            RETURN cCodRet;
        END IF;
		
		IF pCtlLigado = '' THEN
            LET cCodRet = '000014'; -- PARAMETRO CTL_LIGADO VIENE VACIO
            RETURN cCodRet;
        END IF;
		
		IF pCtlLigado <> 1 AND pCtlLigado <> 0 THEN		
            LET cCodRet = '000015'; -- PARAMETRO CTL_LIGADO NO VALIDO
            RETURN cCodRet;
        END IF;
		
		IF pMacaddressLocal = '' THEN
            LET cCodRet = '000016'; -- PARAMETRO MACADDRESS_LOCAL VIENE VACIO
            RETURN cCodRet;
        END IF;
					
		IF pUsuarioAlta = '' THEN
            LET cCodRet = '000018'; -- PARAMETRO PUSUARIOALTA VIENE VACIO
            RETURN cCodRet;
        END IF;
		
		SELECT empresa
		INTO cEmpresa
		FROM BDINTEG:si_empresas
		WHERE empresa = pEmpresa;
        IF cEmpresa IS NULL OR cEmpresa = '' THEN
            LET cCodRet = '000019'; -- EMPRESA NO EXISTE EN CATALOGO
            RETURN cCodRet;
        END IF;
		
		--INSERTA REGISTRO DE DOCUMENTOS PENDIENTES DE ENVIAR IMAGEN.
		INSERT INTO BDIDIGITAL:dg_expediente_envio (empresa,cliente,cuenta,producto,cod_docto,prod_nombre,secuencia,ctl_archivo_local,
					                                 ctl_archivo_local_ruta,ctl_img_enviada,ctl_procesado,ctl_ligado,macaddress_local,
													 descrip2,usuario_alta,fecha_alta)
		VALUES(pEmpresa,pCliente,pCuenta,pProducto,pCodDocto,pProdNombre,pSecuencia,pCtlArchivoLocal,pCtlArchivoLocalRuta,
		       pCtlImgEnviada,pCtlProcesado,pCtlLigado,pMacaddressLocal,pDescrip2,pUsuarioAlta,pFechaAlta);
					       
        RETURN cCodRet;		
	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Inserta en la tabla dg_expediente_envio ',
'tomando como parametro o dato de entrada, la Empresa, cliente,cuenta,producto,cod_docto,prod_nombre,secuencia,ctl_archivo_local',
'ctl_archivo_local_ruta,ctl_img_enviada,ctl_procesado,ctl_ligado,macaddress_local,descrip2,usuario_alta y fecha_alta',
'AUTOR: Guadalupe Payan',
'FECHA: Noviembre 2010',
'VERSION: 201004',
'BD: BDIDIGITAL';

CREATE PROCEDURE "informix".consnomctefusion(pEmpresa CHAR(3),pNumcte CHAR(20))

	-- DATOS A REGRESAR --
	RETURNING 
	   CHAR(5),  -- Codigo de retorno
	   CHAR(60), -- Nombre Completo
	   CHAR(13), -- RFC
	   CHAR(20); -- Curp

	-- DECLARACIÓN DE VARIABLES --
	DEFINE cCodret		 CHAR(5);
	DEFINE cEsfisica	 CHAR(1);
	DEFINE cPaterno 	 CHAR(15);
	DEFINE cMaterno 	 CHAR(15);
	DEFINE cNombre1		 CHAR(15);
	DEFINE cNombre2 	 CHAR(15);
	DEFINE cRazon_social CHAR(60);
	DEFINE cNomcte 		 CHAR(60);
	DEFINE iSqlerr 		 INTEGER;
	DEFINE cTpo_persona  CHAR(2);
	DEFINE cRfc 		 CHAR(13);
	DEFINE cCurp 		 CHAR(20);
	
	-- INICIALIZACIÓN DE VARIABLES --
	LET cNomcte = " ";
	LET cCodret = "000";
	LET cRfc    = " ";
	LET cCurp   = " ";
	
	--SET DEBUG FILE TO "/respaldosbd/Daniela/consnomctefusion.out";
	--TRACE ON;
	
	BEGIN
	
		ON EXCEPTION SET iSqlerr
		
			IF iSqlerr <> 0 THEN
			
				LET cCodret = iSqlerr;
				
				RETURN cCodret, cNomcte, cRfc, cCurp;
				
			END IF
			
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		
		SELECT {+INDEX (bdinteg:si_fuscliente idx_fcte)} tpo_persona,NVL(apell_paterno," "),NVL(apell_materno," "),NVL(nombre1," "),NVL(nombre2," "),
			   NVL(razon_social," "),rfc
		  INTO cTpo_persona,cPaterno,cMaterno,cNombre1,cNombre2,cRazon_social,cRfc
		  FROM bdinteg:"informix".si_fuscliente
		 WHERE empresa = pEmpresa AND numcte = pNumcte;
		 
		IF cTpo_persona = " " OR cTpo_persona IS NULL THEN
		
			LET cCodret = "800";
			
			RETURN cCodret, cNomcte, cRfc, cCurp;
			
		ELSE
		
			SELECT {+INDEX (bdinteg:si_tipper ix193_1)} es_fisica
			  INTO cEsfisica
			  FROM bdinteg:"informix".si_tipper
			 WHERE tpo_persona = cTpo_persona;
			
			IF cEsfisica <> "S" THEN
			
				LET cNomcte = TRIM(cRazon_social);
				
			ELSE
			
				LET cNomcte = TRIM(cNombre1)||" "||TRIM(cNombre2)||" "||TRIM(cPaterno)||" "||trim(cMaterno);
				
			END IF;
			
		END IF
		
		IF cEsfisica = "S" THEN
		
			SELECT NVL(curp," ")
			  INTO cCurp
			  FROM bdinteg:"informix".si_fusctepf
			 WHERE empresa = pEmpresa and numcte = pNumcte;
			 
		END IF
		
		RETURN cCodret,cNomcte,cRfc,cCurp;
		
	END
	
END PROCEDURE

DOCUMENT
'Consulta datos del cliente fusionado',
'Autor :Daniela Ramírez',
'FECHA : 04/Octubre/2011',
'BD: bdidigital';

CREATE PROCEDURE "informix".sp_dgconsultadocumentoespecifico(pEmpresa CHAR(3),pCod_Doc CHAR(4))
	RETURNING CHAR(6) AS CodRet,
			  CHAR(4) AS CodDocto,
			  CHAR(35) AS DescDocto,
			  CHAR(3) AS CodGrupo,
			  CHAR(30) AS DescGrupo,
			  CHAR(1) AS MultiImg,
			  INTEGER AS ImgTamMax,
			  CHAR(3) AS ImgFormato,
			  SMALLINT AS ImgCompresion,
			  DECIMAL AS ImgLargo,
			  DECIMAL AS ImgAncho,
			  SMALLINT AS ImgDPI,
			  CHAR(1) AS ImgColores,
			  CHAR(1) AS Generico,
			  CHAR(1) AS Ligar;
		
		
	 -- DECLARACION DE VARIABLES
		DEFINE cEmpresa		        CHAR(3);
		DEFINE iSqlErr              INTEGER;
		DEFINE cCodRet              CHAR(6);
		DEFINE cCodDoc              CHAR(4);
		DEFINE cDescripDoc          CHAR(35);
		DEFINE cCodGrup             CHAR(3);
		DEFINE cDescripGrup         CHAR(30);
		DEFINE cMultiImg            CHAR(1);
		DEFINE iImgTamMax           INTEGER;
		DEFINE cImgFormato          CHAR(3);
		DEFINE sImgCompresion       SMALLINT;
		DEFINE dImgLargo            DECIMAL;
		DEFINE dImgAncho            DECIMAL;
		DEFINE sImgDPI              SMALLINT;
		DEFINE cImgColores          CHAR(1);
		DEFINE cGenerico            CHAR(1);
		DEFINE cLiga	            CHAR(1);
	
	 -- INICIALIZACION DE  VARIABLES
		LET cEmpresa                = '';
		LET cCodRet					= '000000';
		LET cCodDoc					= '';
		LET cDescripDoc				= '';
		LET cCodGrup				= '';
		LET cDescripGrup			= '';
		LET cMultiImg				= '';
		LET iImgTamMax				= 0;
		LET cImgFormato				= '';
		LET sImgCompresion			= 0;
		LET dImgLargo				= 0;
		LET dImgAncho				= 0;
		LET sImgDPI					= 0;
		LET cImgColores				= '';
		LET cGenerico				= '';		
		LET cLiga					= '';		
		
	-- CREA EL ARCHIVO DE MONITOREO DEL PROCESO
	-- SET DEBUG FILE TO "/home/sysifx/vlv/sp_DgConsultaDocumentoEspecifico.out";
	-- TRACE ON;
		
		
	BEGIN
	
	 -- CREA EL CONTROL DE ERRORES
		ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				RETURN cCodRet, cCodDoc, cDescripDoc, cCodGrup, cDescripGrup, cMultiImg, iImgTamMax, cImgFormato, sImgCompresion,
					   dImgLargo, dImgAncho, sImgDPI, cImgColores, cGenerico, cLiga;
			END IF;
		END EXCEPTION;
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

        IF pEmpresa = '' THEN
            LET cCodRet = '000001'; -- PARAMETRO EMPRESA VACIO
            RETURN cCodRet, cCodDoc, cDescripDoc, cCodGrup, cDescripGrup, cMultiImg, iImgTamMax, cImgFormato, sImgCompresion,
				   dImgLargo, dImgAncho, sImgDPI, cImgColores, cGenerico, cLiga;
        END IF;

        IF pCod_Doc = '' THEN
            LET cCodRet = '000002'; -- PARAMETRO CODIGO DE DOCUMENTO VIENE VACIO
            RETURN cCodRet, cCodDoc, cDescripDoc, cCodGrup, cDescripGrup, cMultiImg, iImgTamMax, cImgFormato, sImgCompresion,
				   dImgLargo, dImgAncho, sImgDPI, cImgColores, cGenerico, cLiga;
	    END IF;

        IF LENGTH(pCod_Doc) <> 4 THEN		
            LET cCodRet = '000003'; -- PARAMETRO CODIGO DE DOCUMENTO NO VALIDO
            RETURN cCodRet, cCodDoc, cDescripDoc, cCodGrup, cDescripGrup, cMultiImg, iImgTamMax, cImgFormato, sImgCompresion,
				   dImgLargo, dImgAncho, sImgDPI, cImgColores, cGenerico, cLiga;
        END IF;

        SELECT empresa
		INTO cEmpresa
		FROM bdinteg:"informix".si_empresas
		WHERE empresa = pEmpresa;

        IF NVL(cEmpresa,'') = '' THEN
            LET cCodRet = '000004'; -- EMPRESA NO EXISTE EN CATALOGO
            RETURN cCodRet, cCodDoc, cDescripDoc, cCodGrup, cDescripGrup, cMultiImg, iImgTamMax, cImgFormato, sImgCompresion,
				   dImgLargo, dImgAncho, sImgDPI, cImgColores, cGenerico, cLiga;
        END IF;
		
        -- OBTENGO DOCUMENTO ESPECIFICO
	    FOREACH 
		   
	       SELECT td.cod_docto, td.descripcion, gp.cod_grupo, gp.descripcion, td.multi_imagen, td.imagen_tam_max, td.imagen_formato, 
				  td.imagen_compresion, td.imagen_largo, td.imagen_ancho, td.imagen_dpi, td.imagen_colores, td.generico, td.ligar
	         INTO cCodDoc, cDescripDoc, cCodGrup, cDescripGrup, cMultiImg, iImgTamMax, cImgFormato, sImgCompresion, dImgLargo, dImgAncho, 
			      sImgDPI, cImgColores, cGenerico, cLiga
	        FROM BDIDIGITAL@COPPELIMG_TCP:"informix".dg_tipodocumento td 
				 INNER JOIN BDIDIGITAL@COPPELIMG_TCP:"informix".dg_grupodocto gp ON (td.cod_grupo = gp.cod_grupo )
	        WHERE gp.empresa = pEmpresa --vpEmpresa
              AND td.cod_docto = pCod_Doc --TipoDocto	     
			
	        RETURN cCodRet, cCodDoc, cDescripDoc, cCodGrup, cDescripGrup, cMultiImg, iImgTamMax, cImgFormato, sImgCompresion, dImgLargo, dImgAncho,
		           sImgDPI,cImgColores,cGenerico, cLiga WITH RESUME;       
				   
		END FOREACH
		
		IF NVL(cCodDoc,'') = '' THEN
		   LET cCodRet = '000005';	    -- NO SE ENCUENTRAN REGISTROS DE ESTE DOCUMENTO.
		END IF;
END
	
END PROCEDURE
DOCUMENT
'DESCRIPCION: Genera una consulta en las tablas dg_tipodocumento, dg_grupodocto',
'tomando como parametro o dato de entrada, la Empresa y el  Codigo de Documento para obtener el Documento Especifico',
'AUTOR: Guadalupe Payan',
'FECHA: Octubre 2010',
'VERSION: 201026',
'BD: BDIDIGITAL',
'MODIFICO: Valentin Lòpez',
'DESCRIPCION: Se agrego que muestre el valor del campo ligar para saber si se puede ligar o no un documento.',
'FECHA: Marzo 2012',
'VERSION: 20120314',
'BD: BDIDIGITAL';

CREATE PROCEDURE "c92357113".sp_dgconsultadocumentosnoobligadigitalizar(pEmpresa CHAR(3),pCodDefinicion CHAR(3))
	RETURNING CHAR(6),
			  CHAR(3),
			  CHAR(50),
			  CHAR(1);

	--DECLARACION DE VARIABLES	    
	DEFINE cEmpresa	         CHAR(3);
	DEFINE iSqlErr           INTEGER;
	DEFINE cCodRet           CHAR(6);
	DEFINE cCodGrupo         CHAR(3);
	DEFINE cDescripcion      CHAR(50);
	DEFINE cElemNoTiene      CHAR(1);
	
	--CREA EL ARCHIVO DE MONITOREO DEL PROCESO
	--SET DEBUG FILE TO "/tmp/sp_DgConsultaDocumentosNoObligaDigitalizar.out";
	--TRACE ON;
	
	--INICIALIZACION DE  VARIABLES
		LET cEmpresa= '';
		LET cCodRet= '000000';		     		
		LET cCodGrupo= '';
        LET cDescripcion= '';
		LET cElemNoTiene= '';
		
	BEGIN
	--CREA EL CONTROL DE ERRORES
		ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				RETURN cCodRet,cCodGrupo,cDescripcion,cElemNoTiene;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
        IF pEmpresa = '' THEN
            LET cCodRet = '000001'; -- PARAMETRO EMPRESA VACIO
            RETURN cCodRet,cCodGrupo,cDescripcion,cElemNoTiene;
        END IF;
		
        IF pCodDefinicion = ''  THEN
            LET cCodRet = '000002'; -- PARAMETRO CODIGO DEFINICION ESTA VACIO 
            RETURN cCodRet,cCodGrupo,cDescripcion,cElemNoTiene;
        END IF;
		
		IF LENGTH(pCodDefinicion) <> 3 THEN
            LET cCodRet = '000003'; -- PARAMETRO CODIGO DEFINICION NO VALIDO
            RETURN cCodRet,cCodGrupo,cDescripcion,cElemNoTiene;
        END IF;
       	
		SELECT empresa
		INTO cEmpresa
		FROM BDINTEG:si_empresas
		WHERE empresa = pEmpresa;		
		
        IF cEmpresa IS NULL OR cEmpresa = '' THEN
            LET cCodRet = '000004'; -- EMPRESA NO EXISTE EN CATALOGO
            RETURN cCodRet,cCodGrupo,cDescripcion,cElemNoTiene;
        END IF;  
		
		--CONSULTA PARAMETROS DIGITALIZACION
		FOREACH
			SELECT gp.cod_grupo,gp.descripcion,gp.elem_no_tiene 
			INTO cCodGrupo,cDescripcion,cElemNoTiene
			FROM BDIDIGITAL@COPPELIMG_TCP:"informix".dg_definicion_det det 
			     INNER JOIN BDIDIGITAL@COPPELIMG_TCP:"informix".dg_tipodocumento td ON (det.cod_docto=td.cod_docto)
			     INNER JOIN BDIDIGITAL@COPPELIMG_TCP:"informix".dg_grupodocto gp ON (td.cod_grupo = gp.cod_grupo)
			WHERE det.empresa = pEmpresa 
			  AND det.cod_definicion = pCodDefinicion 
			  AND gp.elem_no_tiene = '1'
			GROUP BY gp.cod_grupo, gp.descripcion, gp.elem_no_tiene
			ORDER BY gp.cod_grupo
			
			RETURN cCodRet,cCodGrupo,cDescripcion,cElemNoTiene WITH RESUME;
		END FOREACH
		
		IF NVL(cCodGrupo,'') = '' THEN
		    LET cCodRet = '000005';
		    RETURN cCodRet,cCodGrupo,cDescripcion,cElemNoTiene;
		END IF;
		
	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Genera una consulta en las tabla dg_definicion, dg_tipodocumento y dg_grupodocto',
'tomando como parametro o dato de entrada, la Empresa,el Codigo Definicion',
'para obtener los Parametros necesarios para ejecutar la aplicacion',
'AUTOR: Guadalupe Payan',
'FECHA: Octubre 2010',
'VERSION: 201028',
'BD: BDIDIGITAL',
'DESCRIPCION: Se cambio la varible de retorno cDescripcion CHAR(30) por cDescripcion CHAR(50)',
'y la variable de retorno a CHAR(50)',
'MODIFICO: Valentin Lopez',
'FECHA: Marzo 2012',
'VERSION: 20120328';

create procedure "informix".cons_val_exp(pempresa char(3), pcliente    char(20))
            RETURNING
            char(5),char(1),char(1);

   DEFINE v_codret          char(5);
   DEFINE v_cuenta          char(20);
   DEFINE v_prod_nombre     char(40);
   DEFINE v_cod_docto       char(4);
   DEFINE v_fecha_alta      date;
   DEFINE v_cod_grupo       char(3);
   DEFINE v_descrip_gpo     char(30);
   DEFINE v_descrip_docto   char(35);
   DEFINE v_descrip2        char(30);
   DEFINE v_multi_img       char(1);
   DEFINE v_secuencia       smallint;
   DEFINE v_contador        smallint;
   DEFINE sql_err,isam_err  int;
   DEFINE cod_ret			char(5);
   DEFINE v_nomcte          char(104);
   DEFINE v_edad	        smallint;
   DEFINE v_codrespalda		char(5);
   DEFINE v_grupo_uno		char(1);
   DEFINE v_grupo_dos		char(1);
   DEFINE v_existe, v_nro_rows int;


-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

        LET v_codret            = "000";
        let v_cod_docto         = " ";
        let v_cod_grupo         = " ";
		let v_multi_img         = " ";
        let v_secuencia         = 0;
        let v_contador          = 0;
		let cod_ret				= "000";
		let v_nomcte			= " ";
		let v_edad				= 0;
		let v_codrespalda       = "000";
		let v_grupo_uno			= '0';
		let v_grupo_dos			= '0';
		let v_existe			= 0;
		let v_nro_rows			= 0;

--set debug file to "/informix/cons_rgh.txt";
--trace on;

BEGIN
   on exception set sql_err,isam_err
      if sql_err <> 0 or isam_err <> 0 then
         let v_codret = sql_err;
         RETURN v_codret,v_grupo_uno,v_grupo_dos;
      end if;
   end exception;

-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

    IF  pempresa is null or
        pcliente is null then
       -- datos de entrada incompletos
       let v_codret = 110;
       RETURN v_codret,v_grupo_uno,v_grupo_dos;
    END IF;

-- ****************************************************************************
-- obtener edad
-- ****************************************************************************

	EXECUTE PROCEDURE bdinteg:consedadcte(pempresa,  pcliente)
	INTO cod_ret, v_nomcte, v_edad;

	if cod_ret <> '000' then
       let v_codret = '002';
                return v_codret,v_grupo_uno,v_grupo_dos;
	end if

-- ****************************************************************************
-- es mayor de edad verificar que por lo menos exista un registro si no no hay expediente
-- ****************************************************************************

	if v_edad >= 18 then

						select count(*)
						into v_existe
						from 	bdidigital@coppelimg_tcp:dg_expediente a,
								bdidigital@coppelimg_tcp:dg_tipodocumento d
						where a.cliente = pcliente
						and d.cod_docto = a.cod_docto
						and d.cod_grupo  in ('002','001')
						and a.producto = '9999';
						--group by  a.cod_docto, d.multi_imagen;

                       if not exists (select a.cod_docto, d.multi_imagen from 	bdidigital@coppelimg_tcp:dg_expediente a,
                                                  bdidigital@coppelimg_tcp:dg_tipodocumento d where a.cliente = pcliente
                                                  and d.cod_docto = a.cod_docto and d.cod_grupo  = '002' and a.producto = '9999'
                                                  group by  a.cod_docto, d.multi_imagen) then
                                LET v_codret = '000';
					   			LET v_grupo_dos = '1';
                       end if;

                       if not exists (select a.cod_docto, d.multi_imagen from 	bdidigital@coppelimg_tcp:dg_expediente a,
                                                  bdidigital@coppelimg_tcp:dg_tipodocumento d where a.cliente = pcliente
                                                  and d.cod_docto = a.cod_docto and d.cod_grupo  = '001' and a.producto = '9999'
                                                  group by  a.cod_docto, d.multi_imagen) then
                                LET v_codret = '000';
					   			LET v_grupo_uno = '1';
                       end if;



						if v_existe > 0 then

							FOREACH

								select a.cod_docto, d.multi_imagen
								into v_cod_docto, v_multi_img
								from 	bdidigital@coppelimg_tcp:dg_expediente a,
										bdidigital@coppelimg_tcp:dg_tipodocumento d
								where a.cliente = pcliente
								and d.cod_docto = a.cod_docto
								and d.cod_grupo  = '002'
								and a.producto = '9999'
								group by  a.cod_docto, d.multi_imagen

							if v_multi_img >= 1 then

								let v_contador = 0;

								FOREACH

									select 1
									into v_secuencia
									from bdidigital@coppelimg_tcp:dg_expediente
									where cliente = pcliente
									and cod_docto = v_cod_docto
									and fecha_alta in (select max(fecha_alta)
														from bdidigital@coppelimg_tcp:dg_expediente
														where cliente = pcliente
														and cod_docto = v_cod_docto)

									let v_contador = v_contador +1;

								CONTINUE FOREACH;

								END FOREACH

									if v_contador > 1 then
										LET v_codret = '000';
										LET v_grupo_dos = '0';
									else
										LET v_codret = '001';
										call bdidigital@coppelimg_tcp:resp_elim_imagenes(pempresa, pcliente, v_cod_docto)
										RETURNING v_codrespalda;

										if v_codrespalda = '000' then
											let v_codret = v_codret;
											let v_grupo_dos = '1';
										else
											let v_codret = v_codrespalda;
											let v_grupo_dos = '1';
										end if;
									end if;
							else
									IF EXISTS (SELECT *	FROM bdidigital@coppelimg_tcp:dg_expediente WHERE empresa = pempresa AND cliente = pCliente AND cod_docto = v_cod_docto AND producto = '9999') THEN

										LET v_codret = '000';
										LET v_grupo_dos = '0';

									else
										LET v_codret = '001';
										call bdidigital@coppelimg_tcp:resp_elim_imagenes(pempresa, pcliente, v_cod_docto)
										RETURNING v_codrespalda;

										if v_codrespalda = '000' then
											let v_codret = v_codret;
											let v_grupo_dos = '1';
										else
											let v_codret = v_codrespalda;
											let v_grupo_dos = '1';
										end if;

									end if;

							end if;

						CONTINUE FOREACH;

					END FOREACH

					FOREACH

						select a.cod_docto, d.multi_imagen
						into v_cod_docto, v_multi_img
						from 	bdidigital@coppelimg_tcp:dg_expediente a,
								bdidigital@coppelimg_tcp:dg_tipodocumento d
						where a.cliente = pcliente
						and d.cod_docto = a.cod_docto
						and d.cod_grupo  in ('001')
						and a.producto = '9999'
						group by  a.cod_docto, d.multi_imagen

							if v_multi_img >= 1 then

							let v_contador = 0;

							FOREACH

								select 1
								into v_secuencia
								from bdidigital@coppelimg_tcp:dg_expediente
								where cliente = pcliente
								and cod_docto = v_cod_docto
								and fecha_alta in (select max(fecha_alta)
													from bdidigital@coppelimg_tcp:dg_expediente
													where cliente = pcliente
													and cod_docto = v_cod_docto)

								let v_contador = v_contador +1;

							CONTINUE FOREACH;

							END FOREACH

									if v_contador > 1 then
										LET v_codret = '000';
										LET v_grupo_uno = '0';
									else
										LET v_codret = '001';
										call bdidigital@coppelimg_tcp:resp_elim_imagenes(pempresa, pcliente, v_cod_docto)
										RETURNING v_codrespalda;

										if v_codrespalda = '000' then
											LET v_codret = v_codret;
											LET v_grupo_uno = '1';
										else
											LET v_codret = v_codrespalda;
											LET v_grupo_uno = '1';
										end if
									end if;

							else

									IF EXISTS (SELECT *	FROM bdidigital@coppelimg_tcp:dg_expediente WHERE empresa = pempresa AND cliente = pCliente AND cod_docto = v_cod_docto AND producto = '9999') THEN

										LET v_codret = '000';
										LET v_grupo_dos = '0';

									else
										LET v_codret = '001';
										call bdidigital@coppelimg_tcp:resp_elim_imagenes(pempresa, pcliente, v_cod_docto)
										RETURNING v_codrespalda;

										if v_codrespalda = '000' then
											let v_codret = v_codret;
											let v_grupo_dos = '1';
										else
											let v_codret = v_codrespalda;
											let v_grupo_dos = '1';
										end if;

									end if;

							end if;


						CONTINUE FOREACH;

					END FOREACH

					else
										LET v_codret = '001';
										LET v_grupo_uno = '1';
										LET v_grupo_dos = '1';

					end if;
-- ****************************************************************************
-- es menor de edad verificar que por lo menos exista un registro si no no hay expediente
-- ****************************************************************************
	else

		select count(*)
		into v_existe
		from 	bdidigital@coppelimg_tcp:dg_expediente a,
				bdidigital@coppelimg_tcp:dg_tipodocumento d
		where a.cliente = pcliente
		and d.cod_docto = a.cod_docto
		and d.cod_grupo  in ('002','045')
		and a.producto = '6501';
		--group by  a.cod_docto, d.multi_imagen;

		if v_existe > 0 then

				FOREACH

					select 	a.cod_docto, d.multi_imagen
					into 	v_cod_docto, v_multi_img
					from 	bdidigital@coppelimg_tcp:dg_expediente a,
							bdidigital@coppelimg_tcp:dg_tipodocumento d
					where 	a.cliente = pcliente
					and 	d.cod_docto = a.cod_docto
					and 	d.cod_grupo  = '002'
					and 	a.producto = '6501'
					group by  a.cod_docto, d.multi_imagen

						if v_multi_img >= 1 then

						let v_contador = 0;

						FOREACH

							select 1
							into v_secuencia
							from bdidigital@coppelimg_tcp:dg_expediente
							where cliente = pcliente
							and cod_docto = v_cod_docto
							and fecha_alta in (select max(fecha_alta)
													from bdidigital@coppelimg_tcp:dg_expediente
													where cliente = pcliente
													and cod_docto = v_cod_docto)

							let v_contador = v_contador +1;

							CONTINUE FOREACH;

							END FOREACH

								if v_contador > 1 then
									LET v_codret = '000';
									LET v_grupo_dos = '0';
								else
										LET v_codret = '001';
										call bdidigital@coppelimg_tcp:resp_elim_imagenes(pempresa, pcliente, v_cod_docto)
										RETURNING v_codrespalda;

										if v_codrespalda = '000' then
											LET v_codret = v_codret;
											LET v_grupo_dos = '1';
										else
											LET v_codret = v_codrespalda;
											LET v_grupo_dos = '1';
										end if;
								end if;
						else

								IF EXISTS (SELECT *	FROM bdidigital@coppelimg_tcp:dg_expediente WHERE empresa = pempresa AND cliente = pCliente AND cod_docto = v_cod_docto AND producto = '6501') THEN

									LET v_codret = '000';
									LET v_grupo_dos = '0';

								ELSE

									LET v_codret = '001';
									call bdidigital@coppelimg_tcp:resp_elim_imagenes(pempresa, pcliente, v_cod_docto)
									RETURNING v_codrespalda;

									if v_codrespalda = '000' then
										let v_codret = v_codret;
										let v_grupo_dos = '1';
									else
										let v_codret = v_codrespalda;
										let v_grupo_dos = '1';
									end if;

								END IF;

						end if;

					CONTINUE FOREACH;

				END FOREACH

				FOREACH

					select 	a.cod_docto, d.multi_imagen
					into 	v_cod_docto, v_multi_img
					from 	bdidigital@coppelimg_tcp:dg_expediente a,
							bdidigital@coppelimg_tcp:dg_tipodocumento d
					where 	a.cliente = pcliente
					and 	d.cod_docto = a.cod_docto
					and 	d.cod_grupo  in ('045')
					and 	a.producto = '6501'
					group by  a.cod_docto, d.multi_imagen

						if v_multi_img >= 1 then

						let v_contador = 0;

						FOREACH

							select 1
							into v_secuencia
							from bdidigital@coppelimg_tcp:dg_expediente
							where cliente = pcliente
							and cod_docto = v_cod_docto
							and fecha_alta in (select max(fecha_alta)
												from bdidigital@coppelimg_tcp:dg_expediente
												where cliente = pcliente
												and cod_docto = v_cod_docto)

							let v_contador = v_contador +1;

						CONTINUE FOREACH;

						END FOREACH

								if v_contador >= 1 then
									LET v_codret = '000';
									LET v_grupo_uno = '0';
								else
										LET v_codret = '001';
										call bdidigital@coppelimg_tcp:resp_elim_imagenes(pempresa, pcliente, v_cod_docto)
										RETURNING v_codrespalda;

										if v_codrespalda = '000' then
											LET v_codret = v_codret;
											LET v_grupo_uno = '1';
										else
											LET v_codret = v_codrespalda;
											LET v_grupo_uno = '1';
										end if
								end if;
						else

								IF EXISTS (SELECT *	FROM bdidigital@coppelimg_tcp:dg_expediente WHERE empresa = pempresa AND cliente = pCliente AND cod_docto = v_cod_docto AND producto = '6501') THEN

									LET v_codret = '000';
									LET v_grupo_dos = '0';

								ELSE

									LET v_codret = '001';
									call bdidigital@coppelimg_tcp:resp_elim_imagenes(pempresa, pcliente, v_cod_docto)
									RETURNING v_codrespalda;

									if v_codrespalda = '000' then
										let v_codret = v_codret;
										let v_grupo_dos = '1';
									else
										let v_codret = v_codrespalda;
										let v_grupo_dos = '1';
									end if;

								END IF;

						end if;


					CONTINUE FOREACH;

				END FOREACH

		else
							LET v_codret = '001';
							LET v_grupo_uno = '1';
							LET v_grupo_dos = '1';

		end if;


	end if;

	RETURN v_codret,v_grupo_uno,v_grupo_dos;

END;
END PROCEDURE;