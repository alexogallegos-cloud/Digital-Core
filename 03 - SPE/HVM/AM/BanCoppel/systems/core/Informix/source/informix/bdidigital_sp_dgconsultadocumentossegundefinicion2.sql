CREATE PROCEDURE "informix".sp_dgconsultadocumentossegundefinicion2(pEmpresa CHAR(3),pCodDefinicion CHAR(3),pProducto CHAR(4))
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
		
		

	 -- SET DEBUG FILE TO "/informix/vamilan/sp_dgconsultadocumentossegundefinicion2.out";
	--  TRACE ON;
	
	
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
			--1200-018, 1600-023 2800-086  --PRODUCTOS PARAMETRIZADOS
			IF EXISTS(SELECT noproducto FROM bdicnweb:"informix".productos WHERE  activa = 1 AND noproducto = pProducto) THEN
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
					AND det.cod_docto <> '0051'
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
'BD: BDIDIGITAL',
'AUTOR MODIFICACION: Uriel Caamaño Mejia',
'BD: bdidigital',
'FECHA: 01/12/2017',
'DESCRIPCION: Se clona el SPL y se agregan nuevas reglas de negocio para el comportamiento de los productos';

CREATE PROCEDURE "informix".sp_consultarmaxsecuenciadocumento(pEmpresa CHAR(3),pCliente CHAR(20),pCodDocto CHAR(4),pCuenta CHAR(11))
RETURNING CHAR(6),
          SMALLINT;

--Declaracion de varibales
DEFINE cCodRet  CHAR(6);
DEFINE iMaxSec  SMALLINT;
DEFINE sql_err  INT;  

ON EXCEPTION SET sql_err
    LET cCodRet = sql_err;
    RETURN  cCodRet, iMaxSec;
END EXCEPTION;

--Inicualizacion de variables.
LET cCodRet='000000'; 
LET iMaxSec = 0;

--SET DEBUG FILE TO "/home/sysifx/vlv/sp_consultarmaxsecuenciadocumento.out";
--TRACE ON;

BEGIN

--Verifica que no contenga parametros nulos
IF pEmpresa <> '' AND pCliente <> '' AND pCodDocto <> '' THEN
    
	--Cosulta la maxima secuencia del documento que se quiere consultar.
	SELECT MAX(Secuencia) INTO iMaxSec 
	FROM bdidigital@coppelimg_tcp:"informix".dg_expediente
	-----WHERE empresa = pEmpresa
	WHERE cliente = pCliente
	  AND cod_docto = pCodDocto
      AND cuenta=pCuenta;
	
	IF iMaxSec = '' OR iMaxSec IS NULL THEN
	   LET cCodRet = '000001';  --No se encuentran los registros.
	END IF;
	
ELSE
    LET cCodRet = '000002'; --Contiene parametros nulos o vacios
END IF;

RETURN  cCodRet, iMaxSec;

END;
END PROCEDURE
DOCUMENT
'AUTOR: Valentin Lopez',
'FECHA: 16 de Mayo del 2011',
'DESCRIPCION: Obtiene la maxima secuencia del documento que se quiere consultar.',
'VERSION: 20110516.1039',
'BD: bdidigital';

create procedure "informix".cons_sec_expendiente(pempresa char(3), pcliente	char(20),pcod_docto char(4))
			RETURNING char(5), smallint;


   DEFINE v_codret          char(5);
   DEFINE sql_err,isam_err  int;
   DEFINE v_secuencia smallint;

-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

   LET v_codret     = "000";
   LET v_secuencia = 0;

BEGIN
   on exception set sql_err,isam_err
      if sql_err <> 0 or isam_err <> 0 then
         let v_codret = sql_err;
         RETURN v_codret,v_secuencia;
      end if;
   end exception;


-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************
  SET ISOLATION TO DIRTY READ;

	IF  	pempresa is null or pcliente is null or pcod_docto is null then
	   -- datos de entrada incompletos
	   let v_codret = '110';
	   RETURN v_codret,v_secuencia;
	END IF;


-- ****************************************************************************
-- devuelve la secuencia
-- ****************************************************************************
        select max(secuencia) into v_secuencia 
        from bdidigital@coppelimg_tcp:dg_expediente
        --from bdidigital@coppelimgdn_tcp:dg_expediente_img
        -----where empresa   = pempresa
        where cliente   = trim(pcliente)
        and cod_docto   = pcod_docto;

        IF v_secuencia is null then
                LET v_secuencia = 1;
        ELSE
                LET v_secuencia = v_secuencia +1;
        END IF;

	RETURN v_codret,v_secuencia;

END;
END PROCEDURE;