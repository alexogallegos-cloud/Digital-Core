CREATE PROCEDURE "informix".sp_doctos_previos_recontrata(pNumcte CHAR(20))
RETURNING CHAR(5) AS CodRet;


	--****************************************************************************************************
	-- DESCRIPCION: Actualiza el campo "cod_docto" de los registros de imagenes del Servicio de EmpresaNet,
	--				La solicitud del servicio, la identificación del Administrador uno y dos.
	--				Para categorizar como HISTORICO.
	-- AUTOR : Berenice Noriega Guevara
	-- FECHA : 21 Octubre 2014
	-- BD: bdidigital
	-- SOLICITO : BanCoppel
	-- Liberado a Producción: 23 Octubre 2014
	--***************************************************************************************************

	
-- DECLARACIÓN DE VARIABLES
DEFINE cCodRet		CHAR(5);
DEFINE cCuenta		CHAR(20);
DEFINE cProducto	CHAR(4);

DEFINE iSqlErr		INTEGER;


-- INICIALIZACIÓN DE VARIABLES
LET cCodRet			= "00000";
LET cCuenta			= "99999999999";
LET cProducto		= "2202";

LET iSqlErr			= 0;


BEGIN

	ON EXCEPTION SET iSqlErr
		LET cCodRet = iSqlErr;
		RETURN cCodRet;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	
	
	IF NVL(pNumcte, "") = "" THEN
		LET cCodRet = "00001"; -- DEBE ENVIAR OBLIGATORIAMENTE EL NUMERO DE CLIENTE.		
	END IF
		
	IF cCodRet <> "00000" THEN 
		LET cCodRet = "00001"; --PARAMETROS INVÁLIDOS.
		RETURN cCodRet;
	END IF	
	
	--bdidigital@coppelimgdn_tcp para el Produccion
	-------------------------------------------------------------------------------------------
	-- Cambia el codigo del documento en el expediente del cliente-----------------------------
	-------------------------------------------------------------------------------------------
		UPDATE bdidigital@coppelimg_tcp:"informix".dg_expediente 
		SET cod_docto='0202'
		WHERE cliente = pNumcte
	   	AND cuenta = cCuenta
		AND producto = cProducto
		AND cod_docto = '0118'
		AND empresa='001';
			  
		UPDATE bdidigital@coppelimg_tcp:"informix".dg_expediente 
		SET cod_docto='0203'
		WHERE cliente = pNumcte
		AND cuenta = cCuenta
		AND producto = cProducto
		AND cod_docto = '0119'
		AND empresa='001';
			  
		UPDATE bdidigital@coppelimg_tcp:"informix".dg_expediente 
		SET cod_docto='0204'
		WHERE cliente = pNumcte
		AND cuenta = cCuenta
		AND producto = cProducto
		AND cod_docto = '0148'
		AND empresa='001';
		
	-------------------------------------------------------------------------------------------			
	--Cambia codigo de documento en la tabla img para el cliente-------------------------------
	-------------------------------------------------------------------------------------------
		UPDATE bdidigital@coppelimg_tcp:"informix".dg_expediente_img
		SET cod_docto='0202'
		WHERE cliente = pNumcte
		AND cod_docto = '0118'
		AND empresa='001';
			
		UPDATE bdidigital@coppelimg_tcp:"informix".dg_expediente_img
		SET cod_docto='0203'
		WHERE cliente = pNumcte
		AND cod_docto = '0119'
		AND empresa='001';
			
		UPDATE bdidigital@coppelimg_tcp:"informix".dg_expediente_img
		SET cod_docto='0204'
		WHERE cliente = pNumcte
		AND cod_docto = '0148'
		AND empresa='001';
		
	-------------------------------------------------------------------------------------------			
	--Cambiar el codigo del documento para la tabla envio--------------------------------------
	-------------------------------------------------------------------------------------------
		UPDATE "informix".dg_expediente_envio
		SET cod_docto='0202'
		WHERE cliente = pNumcte
		AND cuenta = cCuenta
		AND producto = cProducto
		AND cod_docto = '0118'
		AND empresa='001';
			
		UPDATE "informix".dg_expediente_envio
		SET cod_docto='0203'
		WHERE cliente = pNumcte
		AND cuenta = cCuenta
		AND producto = cProducto
		AND cod_docto = '0119'
		AND empresa='001';
			
		UPDATE "informix".dg_expediente_envio
		SET cod_docto='0204'
		WHERE cliente = pNumcte
		AND cuenta = cCuenta
		AND producto = cProducto
		AND cod_docto = '0148'
		AND empresa='001';
		
	
	RETURN cCodRet;
	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: cambia el campo cod_docto por otro ID.',
'AUTOR: Berenice Noriega',   
'FECHA DE CREACION: 20/08/2014',
'VERSION: 20140820.0820',
'BD: bdidigital';

CREATE PROCEDURE "informix".sp_verifica_ligadoife(pEmpresa CHAR(3), pNumCteTitular CHAR(20))
RETURNING CHAR(5);

	--DEFINICION DE VARIABLES
DEFINE iSqlErr 		INTEGER;
DEFINE cCodRet 		CHAR(5);

	--INICIALIZACION DE VARIABLES
LET iSqlErr 	= 0;
LET cCodRet 	= '00001';


	--SET DEBUG FILE TO '/respaldosbd/Leslie/sp_Verifica_ligadoife.out';
  -- TRACE ON;

BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;

	IF (SELECT COUNT(cod_docto) FROM  bdidigital@coppelimg_tcp:"informix".dg_expediente WHERE cod_docto ='0033' AND cliente=pNumCteTitular
		AND secuencia = '1' AND producto='9999' AND empresa = pEmpresa)>0 THEN
		
		IF (SELECT COUNT(cod_docto) FROM  bdidigital@coppelimg_tcp:"informix".dg_expediente_img WHERE cod_docto ='0033'
		AND cliente=pNumCteTitular AND secuencia = '1' AND empresa = pEmpresa) = 0 THEN
		
			LET cCodRet='00000';
		END IF
	
	END IF
		
RETURN cCodRet;

END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se valida sí la Credencial de Elector como Comp. de Domicilio', 
'fue ligada',
'REALIZO :Leslie Rendón',
'FECHA : 08/Octubre/2013',
'BD    : bdidigital';

CREATE PROCEDURE "informix".sp_dgconsultadocumentossegundefinicion(pEmpresa CHAR(3),pCodDefinicion CHAR(3))
	RETURNING CHAR(6) AS CodRet,
			  SMALLINT AS Secuencia,
			  CHAR(4) AS Cod_Docto,
			  CHAR(50) AS DescDocto,
			  CHAR(3) AS CodGrupo,
			  CHAR(50) AS DescGrupo,
			  CHAR(1) AS MultiImagen,
			  INTEGER AS ImgTamMax,
			  CHAR(3) AS ImgFormato,
			  SMALLINT AS sImgCompresion,
			  DECIMAL AS ImgLargo,
			  DECIMAL AS ImgAncho,
			  SMALLINT AS ImgDPI,
			  CHAR(1) AS ImgColores,
			  CHAR(1) AS Generico,
			  CHAR(1) AS Ligar;
	
	
	--DECLARACION DE VARIABLES	    
	DEFINE cEmpresa	         CHAR(3);
	DEFINE iSqlErr           INTEGER;
	DEFINE cCodRet           CHAR(6);
	DEFINE sSecuencia        SMALLINT;
	DEFINE cCodDocto         CHAR(4);
	DEFINE cDescripDocto     CHAR(50);
	DEFINE cCodGrupo         CHAR(3);
	DEFINE cDescripGrup      CHAR(50);
	DEFINE cMultiImagen      CHAR(1);			   
	DEFINE iImagenTamMax     INTEGER;
	DEFINE cImagenFormato    CHAR(3);
	DEFINE sImagenCompresion SMALLINT;
	DEFINE dImagenLargo      DECIMAL;
	DEFINE dImagenAncho      DECIMAL;
	DEFINE sImagenDPI        SMALLINT;
	DEFINE cImagenColores    CHAR(1);
	DEFINE cGenerico         CHAR(1);
	DEFINE cLiga             CHAR(1);
	 
	 
	--INICIALIZACION DE  VARIABLES
		LET cEmpresa= '';
		LET cCodRet= '000000';		     
		LET	cCodDocto= '';
		LET	cDescripDocto= '';
		LET	cCodGrupo= '';
		LET	cDescripGrup= '';
		LET	cMultiImagen= '';	
		LET	cImagenFormato= '';
		LET	cImagenColores= '';
		LET	cGenerico= '';
		LET sImagenDPI= 0;
		LET dImagenAncho= 0;
		LET dImagenLargo= 0;
		LET sImagenCompresion= 0;
		LET iImagenTamMax= 0;
		LET sSecuencia= 0;
		LET cLiga = '';
		
		
	-- CREA EL ARCHIVO DE MONITOREO DEL PROCESO
	   -- SET DEBUG FILE TO "/home/sysifx/vlv/sp_DgConsultaDocumentosSegunDefinicion.out";
	   -- TRACE ON;
	
	
	BEGIN
	
	--CREA EL CONTROL DE ERRORES
		ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				RETURN cCodRet, sSecuencia, cCodDocto, cDescripDocto, cCodGrupo, cDescripGrup, cMultiImagen, iImagenTamMax, cImagenFormato,
					   sImagenCompresion, dImagenLargo, dImagenAncho, sImagenDPI, cImagenColores, cGenerico, cLiga;
			END IF;
		END EXCEPTION;
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
		
        IF pEmpresa = '' THEN
            LET cCodRet = '000001'; -- PARAMETRO EMPRESA VACIO
            RETURN cCodRet, sSecuencia, cCodDocto, cDescripDocto, cCodGrupo, cDescripGrup, cMultiImagen, iImagenTamMax, cImagenFormato,
				   sImagenCompresion, dImagenLargo, dImagenAncho, sImagenDPI, cImagenColores, cGenerico, cLiga;
        END IF;
		
        IF pCodDefinicion = ''  THEN
            LET cCodRet = '000002'; -- PARAMETRO CODIGO DEFINICION ESTA VACIO 
            RETURN cCodRet, sSecuencia, cCodDocto, cDescripDocto, cCodGrupo, cDescripGrup, cMultiImagen, iImagenTamMax, cImagenFormato,
				   sImagenCompresion, dImagenLargo, dImagenAncho, sImagenDPI, cImagenColores, cGenerico, cLiga;
        END IF;
		
		IF LENGTH(pCodDefinicion) <> 3 THEN
            LET cCodRet = '000003'; -- PARAMETRO CODIGO DEFINICION NO VALIDO
            RETURN cCodRet, sSecuencia, cCodDocto, cDescripDocto, cCodGrupo, cDescripGrup, cMultiImagen, iImagenTamMax, cImagenFormato,
				   sImagenCompresion, dImagenLargo, dImagenAncho, sImagenDPI, cImagenColores, cGenerico, cLiga;
        END IF;
       	
		SELECT empresa
		INTO cEmpresa
		FROM bdinteg:"informix".si_empresas
		WHERE empresa = pEmpresa;
		
        IF NVL(cEmpresa,'') = '' THEN
            LET cCodRet = '000004'; -- EMPRESA NO EXISTE EN CATALOGO
            RETURN cCodRet, sSecuencia, cCodDocto, cDescripDocto, cCodGrupo, cDescripGrup, cMultiImagen, iImagenTamMax, cImagenFormato,
				   sImagenCompresion, dImagenLargo, dImagenAncho, sImagenDPI, cImagenColores, cGenerico, cLiga;
        END IF;  
		
		--CONSULTA PARAMETROS DIGITALIZACION

		IF pCodDefinicion='061' THEN		
			FOREACH
				SELECT det.secuencia, det.cod_docto, td.descripcion, gp.cod_grupo, gp.descripcion, td.multi_imagen, td.imagen_tam_max, td.imagen_formato,
					td.imagen_compresion, td.imagen_largo, td.imagen_ancho, td.imagen_dpi, td.imagen_colores, td.generico, td.ligar
				INTO sSecuencia, cCodDocto, cDescripDocto, cCodGrupo, cDescripGrup, cMultiImagen, iImagenTamMax, cImagenFormato, sImagenCompresion,
					dImagenLargo, dImagenAncho, sImagenDPI, cImagenColores, cGenerico, cLiga
				FROM BDIDIGITAL@COPPELIMG_TCP:"informix".dg_definicion_det det
					INNER JOIN BDIDIGITAL@COPPELIMG_TCP:"informix".dg_tipodocumento td ON (det.cod_docto = td.cod_docto) 
					INNER JOIN BDIDIGITAL@COPPELIMG_TCP:"informix".dg_grupodocto gp ON (td.cod_grupo=gp.cod_grupo)
				WHERE det.empresa = pEmpresa
				AND det.cod_definicion = pCodDefinicion 
				AND td.cod_docto in('0096','0097','0098','0099','0100','0128','0129','0127','0101','0324')
				ORDER BY 1,4
			RETURN cCodRet, sSecuencia, cCodDocto, cDescripDocto, cCodGrupo, cDescripGrup, cMultiImagen, iImagenTamMax, cImagenFormato,
			       sImagenCompresion, dImagenLargo, dImagenAncho, sImagenDPI, cImagenColores, cGenerico, cLiga WITH resume;
			END FOREACH;
			
		ELSE
			FOREACH
				SELECT det.secuencia, det.cod_docto, td.descripcion, gp.cod_grupo, gp.descripcion, td.multi_imagen, td.imagen_tam_max, td.imagen_formato,
			       td.imagen_compresion, td.imagen_largo, td.imagen_ancho, td.imagen_dpi, td.imagen_colores, td.generico, td.ligar
				INTO sSecuencia, cCodDocto, cDescripDocto, cCodGrupo, cDescripGrup, cMultiImagen, iImagenTamMax, cImagenFormato, sImagenCompresion,
					dImagenLargo, dImagenAncho, sImagenDPI, cImagenColores, cGenerico, cLiga
				FROM BDIDIGITAL@COPPELIMG_TCP:"informix".dg_definicion_det det
					INNER JOIN BDIDIGITAL@COPPELIMG_TCP:"informix".dg_tipodocumento td ON (det.cod_docto = td.cod_docto) 
					INNER JOIN BDIDIGITAL@COPPELIMG_TCP:"informix".dg_grupodocto gp ON (td.cod_grupo=gp.cod_grupo)
				WHERE det.empresa = pEmpresa
				AND det.cod_definicion = pCodDefinicion 
				ORDER BY 1,4
			
			RETURN cCodRet, sSecuencia, cCodDocto, cDescripDocto, cCodGrupo, cDescripGrup, cMultiImagen, iImagenTamMax, cImagenFormato,
			       sImagenCompresion, dImagenLargo, dImagenAncho, sImagenDPI, cImagenColores, cGenerico, cLiga WITH resume;
			
			END FOREACH;
		END IF;
		
		IF NVL(cCodDocto,'') = '' THEN
		   LET cCodRet = '000005';	-- NO SE ENCUENTRAN REGISTROS DE ESA DEFINICION.
		END IF
		
	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Genera una consulta en las tabla dg_definicion, dg_tipodocumento y dg_grupodocto',
'tomando como parametro o dato de entrada, la Empresa,el Codigo Definicion',
'para obtener los Parametros necesarios para ejecutar la aplicacion',
'AUTOR: Guadalupe Payan',
'FECHA: Octubre 2010',
'VERSION: 201027',
'BD: BDIDIGITAL',
'MODIFICO: Valentin Lòpez',
'DESCRIPCION: Se agrego que muestre el valor del campo ligar para saber si se puede ligar o no un documento.',
'FECHA: Marzo 2012',
'VERSION: 20120312',
'BD: BDIDIGITAL';

CREATE PROCEDURE "informix".sp_dgconsultadefinicionesporproducto_soc(pEmpresa CHAR(3),pCodSistema CHAR(2),pCodProducto CHAR(4))
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
		
		SELECT FIRST 1 cod_definicion,prod_nombre
		INSERT INTO cCodDefinicion,cProdNombre
		FROM BDIDIGITAL@COPPELIMG_TCP:dg_definicion 
		WHERE empresa = pEmpresa
		AND cod_sistema = pCodSistema 
        AND cod_producto = pCodProducto; 

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

create procedure "informix".consnomcte(pempresa char(3),pnumcte char(20))
       returning char(5),char(60),char(13),char(20);

define vcodret char(5);
define vesfisica char(1);
define vpaterno char(15);
define vmaterno char(15);
define vnombre1 char(15);
define vnombre2 char(15);
define vrazon_social char(60);
define vnomcte char(60);
define vsqlerr integer;
define vtpo_persona char(2);
define vrfc char(13);
define vcurp char(20);

let vnomcte = " ";
let vcodret = "000";
let vrfc = " ";
let vcurp = " ";

set lock mode  to wait 3;
set  isolation to dirty read;
begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         RETURN vcodret, vnomcte, vrfc, vcurp;
      end if
   end exception;

   SELECT tpo_persona,nvl(apell_paterno," "),nvl(apell_materno," "),
          nvl(nombre1," "),nvl(nombre2," "),nvl(razon_social," "),
          rfc
      into vtpo_persona,vpaterno,vmaterno,vnombre1,vnombre2,vrazon_social,vrfc
      FROM bdinteg:si_cliente
      WHERE empresa = pempresa and numcte = pnumcte;

   if vtpo_persona = " " or vtpo_persona is null then
      let vcodret = "800";
      RETURN vcodret, vnomcte, vrfc, vcurp;
   else
      select es_fisica into vesfisica from bdinteg:si_tipper
         where tpo_persona = vtpo_persona;
      if vesfisica <> "S" then
         let vnomcte = trim(vrazon_social);
      else
         let vnomcte = trim(vnombre1)||" "||trim(vnombre2)||" "||
                       trim(vpaterno)||" "||trim(vmaterno);
      end if;
   end if

   IF vesfisica="S" then
   	SELECT nvl(curp," ")
   	INTO vcurp
      	FROM bdinteg:si_ctepf
      	WHERE empresa = pempresa and numcte = pnumcte;
   END IF

   RETURN vcodret, vnomcte, vrfc, vcurp;

end
end procedure;