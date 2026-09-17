CREATE PROCEDURE "informix".sp_respalda_imagenes(pEmpresa CHAR(4), pNumCteCorrecto CHAR(20), pNumCteIncorrecto CHAR(20))

RETURNING CHAR(5)   AS  CodRetorno,
		  CHAR(50)  AS  Proceso;

--Definicion de Variables
DEFINE iSqlErr  	  	   INTEGER;
DEFINE iIsamErr     	   INTEGER;
DEFINE cDescErr     	   CHAR(50);
DEFINE cCodRet  	  	   CHAR(5);
DEFINE cCodRetSP 	       CHAR(5);
DEFINE cProceso 	  	   CHAR(50);
DEFINE iSam_Err 	       INTEGER;
DEFINE cDescripcion        CHAR(100);
DEFINE cRuta    	  	   CHAR(100);
DEFINE cImg     	  	   CHAR(100);
DEFINE cImg_His 	  	   CHAR(100);
DEFINE cIncorrecto 	  	   CHAR(4);
DEFINE cNomArchivo    	   CHAR(30);
DEFINE cNomArchivoDos 	   CHAR(30);
DEFINE sSecuenciaMax       SMALLINT;
DEFINE sSecuenciaM         SMALLINT;
DEFINE cCod_Doc		  	   CHAR(4);
DEFINE sSecuencia_Inc      SMALLINT;
DEFINE sSecuencia_Corr	   SMALLINT;
DEFINE cEmpresa 	  	   CHAR(3);
DEFINE cCliente 	  	   CHAR(20);
DEFINE cCuenta 		  	   CHAR(20);
DEFINE cProducto 	  	   CHAR(4);
DEFINE sSecuencia 	       SMALLINT;
DEFINE cCod_Docto 	  	   CHAR(4);
DEFINE cProd_nombre   	   CHAR(40);
DEFINE cDescrip2 	   	   CHAR(30);
DEFINE cUsuario_Alta  	   CHAR(8);
DEFINE dFecha_Alta 	 	   DATE;
DEFINE cUsuario_Modif 	   CHAR(8);
DEFINE dFecha_Modif   	   DATE;
DEFINE sSecuenciaMax_Img   SMALLINT;
DEFINE sSecuenciaM_Img     SMALLINT;
DEFINE cIncorrecto_Img 	   CHAR(4);
DEFINE cCod_Doc_Img	  	   CHAR(4);
DEFINE sSecuencia_Inc_Img  SMALLINT;
DEFINE sSecuenciaMax_Img2  SMALLINT;
DEFINE sSecuenciaM_Img2    SMALLINT;
DEFINE cIncorrecto_Img2    CHAR(4);
DEFINE cCod_Doc_Img2  	   CHAR(4);
DEFINE sSecuencia_Inc_Img2 SMALLINT;
DEFINE cTrama			   CHAR(200);
DEFINE cTramaSec		   CHAR(200);


--Inicializacion de Variables
LET iSqlErr  	        = 0;
LET iIsamErr    		= 0;
LET cDescErr    		= '';
LET cCodRet  	        = '00000';
LET cCodRetSP 	  	    = '00000';
LET cProceso 	        = '';
LET iSam_Err   	   	    = 0;
LET cDescripcion   	    = '';
LET cNomArchivo         = '';
LET cNomArchivoDos      = '';
LET cRuta    	        = '';
LET cImg     	        = '';
LET cImg_His 	        = '';
LET cIncorrecto         = '';
LET sSecuenciaMax  	    = 0;
LET sSecuenciaM  	    = 0;
LET cCod_Doc	        = '';
LET sSecuencia_Inc      = 0;
LET sSecuencia_Corr		= '';
LET cEmpresa            = '';
LET cCliente            = '';
LET cCuenta		        = '';
LET cProducto 	        = '';
LET cCod_Docto	        = '';
LET sSecuencia	 	    = 0;
LET cProd_Nombre        = '';
LET cDescrip2	        = '';
LET cUsuario_Alta       = '';
LET dFecha_Alta	        = DATE(1);
LET cUsuario_Modif      = '';
LET dFecha_Modif        = DATE(1);
LET sSecuenciaMax_Img   = 0;
LET sSecuenciaM_Img	    = 0;
LET cCod_Doc_Img   	    = '';
LET cIncorrecto_Img     = '';
LET sSecuencia_Inc_Img  = 0;
LET cIncorrecto_Img2    = '';
LET sSecuenciaMax_Img2  = 0;
LET sSecuenciaM_Img2    = 0;
LET cCod_Doc_Img2       = '';
LET sSecuencia_Inc_Img2 = 0;
LET cTrama 				= '';
LET cTramaSec 				= '';

	--SET DEBUG FILE TO '/informix/ArmandoM/FusionAutomatica/sp_respalda_imagenes.out';
	--TRACE ON;
BEGIN
	ON EXCEPTION
		SET iSqlErr, iIsamErr, cDescErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			LET cProceso = cDescErr;
			RETURN cCodRet,cProceso;
		END IF;
	END EXCEPTION;
	SET LOCK MODE TO WAIT 3;

	IF  NVL(pEmpresa, '') = '' OR
		NVL(pNumCteCorrecto, '') = '' OR
		NVL(pNumCteIncorrecto, '') = '' THEN
		LET cCodRet = '00001';
	ELSE
		FOREACH     --Respaldo para dg_expediente
			SELECT empresa,cliente,cuenta,producto,cod_docto,secuencia,prod_nombre,descrip2,usuario_alta,fecha_alta,usuario_modif,fecha_modif
			INTO cEmpresa,cCliente,cCuenta,cProducto,cCod_Docto,sSecuencia,cProd_Nombre,cDescrip2,cUsuario_Alta,dFecha_Alta,cUsuario_Modif,dFecha_Modif
			FROM bdidigital@coppelimg_crx:"informix".dg_expediente
			WHERE empresa = pEmpresa
			AND cliente = pNumCteIncorrecto

			INSERT INTO bdidigital@coppelimg_crx:dg_expediente_fus(empresa,cliente,cuenta,producto,cod_docto,secuencia,prod_nombre,descrip2,usuario_alta,fecha_alta,usuario_modif,fecha_modif) VALUES (cEmpresa,cCliente,cCuenta,cProducto,cCod_Docto,sSecuencia,cProd_Nombre,cDescrip2,cUsuario_Alta,dFecha_Alta,cUsuario_Modif,dFecha_Modif);
			INSERT INTO bdinteg:"informix".si_fusexpediente (empresa,cliente,cuenta,producto,cod_docto,secuencia,prod_nombre,descrip2,usuario_alta,fecha_alta,usuario_modif,fecha_modif) VALUES (cEmpresa,cCliente,cCuenta,cProducto,cCod_Docto,sSecuencia,cProd_Nombre,cDescrip2,cUsuario_Alta,dFecha_Alta,cUsuario_Modif,dFecha_Modif);
			
		END FOREACH;

		FOREACH
			SELECT DISTINCT cod_docto,secuencia
			INTO cIncorrecto,sSecuencia_Inc
			FROM bdidigital@coppelimg_crx: "informix".dg_expediente
			WHERE empresa = pEmpresa
			AND cliente =  pNumCteIncorrecto

			SELECT DISTINCT cod_docto, secuencia
			INTO cCod_Doc, sSecuencia_Corr
			FROM bdidigital@coppelimg_crx: "informix".dg_expediente
			WHERE empresa = pEmpresa
			AND cliente = pNumCteCorrecto
			AND secuencia = sSecuencia_Inc
			AND cod_docto = cIncorrecto;

			IF  cCod_Doc = cIncorrecto AND sSecuencia_Inc = sSecuencia_Corr  THEN
				SELECT MAX(secuencia)
				INTO sSecuenciaM
				FROM bdidigital@coppelimg_crx: "informix".dg_expediente
				WHERE cod_docto = cCod_Doc
				AND cliente = pNumCteCorrecto;

				LET sSecuenciaMax = sSecuenciaM + 1;
				LET cTramaSec = TRIM(pNumCteIncorrecto)||'|'||TRIM(cIncorrecto)||'|'||sSecuencia_Inc||'|'||sSecuenciaMax||'|IMAGEN ACTUALIZADA';

				UPDATE bdidigital@coppelimg_crx: "informix".dg_expediente SET cliente = pNumCteCorrecto,secuencia = sSecuenciaMax WHERE empresa = pEmpresa AND cliente = pNumCteIncorrecto AND cod_docto = cCod_Doc AND secuencia = sSecuencia_Inc;

				INSERT INTO "informix".log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
				VALUES('DG_EXPEDIENTE', 'dg_expediente', pNumCteCorrecto, pNumCteIncorrecto, cTramaSec, current  , 'infoaut', current);
				LET cCod_Doc = '';
			ELIF cCod_Doc = cIncorrecto OR cCod_Doc IS NULL AND sSecuencia_Inc <> sSecuencia_Corr OR sSecuencia_Corr IS NULL THEN
				LET cTrama = TRIM(pNumCteIncorrecto)||'|'||TRIM(cIncorrecto)||'|'||sSecuencia_Inc||'|'||sSecuencia_Inc||'|IMAGEN ACTUALIZADA';

				UPDATE bdidigital@coppelimg_crx: "informix".dg_expediente SET cliente = pNumCteCorrecto WHERE empresa = pEmpresa AND cliente = pNumCteIncorrecto AND cod_docto = cIncorrecto AND secuencia = sSecuencia_Inc;

				INSERT INTO "informix".log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
				VALUES('DG_EXPEDIENTE', 'dg_expediente', pNumCteCorrecto, pNumCteIncorrecto, cTrama, current  , 'infoaut', current);

				LET cIncorrecto = '';
			END IF;
		END FOREACH;

		--Respaldo para la tabla dg_expediente_img
		SELECT TRIM(valor)
		INTO cRuta
		FROM bdinteg: "informix".si_param
		WHERE cod_param = '122';

		SELECT TRIM(valor)
		INTO cImg
		FROM bdinteg: "informix".si_param
		WHERE cod_param = '180';

		SELECT TRIM(valor)
		INTO cImg_His
		FROM bdinteg: "informix".si_param
		WHERE cod_param = '181';

		LET cNomArchivo = TRIM(cImg)||'_'||TRIM(pNumCteIncorrecto)||'.unl' ;
		LET cNomArchivoDos = TRIM(cImg_His)||'_'||TRIM(pNumCteIncorrecto)||'.unl' ;

		EXECUTE PROCEDURE bdidigital@coppelimg_crx:"informix".sp_respalda_img(pNumCteIncorrecto, cNomArchivo, cRuta)
		INTO cCodRetSP,iSam_err,cDescripcion;
		IF cCodRetSP <> '00000' THEN
			LET cCodRet = cCodRetSP;
			LET cProceso = 'sp_respalda_img';
		END IF;

		EXECUTE PROCEDURE bdidigital@coppelimg_crx:"informix".sp_carga_img(pNumCteIncorrecto, cNomArchivo, cRuta)
		INTO cCodRetSP,iSam_err,cDescripcion;
		IF cCodRetSP <> '00000' THEN
			LET cCodRet = cCodRetSP;
			LET cProceso = 'sp_carga_img';
		END IF;
		
		--Respaldo de la tabla dg_expediente_img_his
		EXECUTE PROCEDURE bdidigital@coppelimghis_tcp:"informix".sp_respalda_img2(pNumCteIncorrecto, cNomArchivoDos, cRuta)
		INTO cCodRetSP,iSam_err,cDescripcion;
		IF cCodRetSP <> '00000' THEN
			LET cCodRet = cCodRetSP;
			LET cProceso = 'sp_respalda_img2';
		END IF;

		EXECUTE PROCEDURE bdidigital@coppelimg_crx:"informix".sp_carga_img2(pNumCteIncorrecto, cNomArchivoDos, cRuta)
		INTO cCodRetSP,iSam_err,cDescripcion;
		IF cCodRetSP <> '00000' THEN
			LET cCodRet = cCodRetSP;
			LET cProceso = 'sp_carga_img2';
		END IF;
		
		FOREACH
			SELECT DISTINCT cod_docto,secuencia
			INTO cIncorrecto_Img,sSecuencia_Inc_Img
			FROM bdidigital@coppelimg_crx: "informix".dg_expediente_img1
			--FROM BDIDIGITAL@COPPELIMG_TCP: "informix".dg_expediente_img
			--WHERE empresa = pEmpresa
			WHERE cliente = pNumCteIncorrecto

			SELECT DISTINCT cod_docto
			INTO cCod_Doc_Img
			FROM bdidigital@coppelimg_crx: "informix".dg_expediente_img1
			--FROM BDIDIGITAL@COPPELIMG_TCP: "informix".dg_expediente_img
			--WHERE empresa = pEmpresa
			WHERE cliente = pNumCteCorrecto
			AND cod_docto = cIncorrecto_Img;

			IF TRIM(cCod_Doc_Img) IS NOT NULL THEN
				SELECT MAX(secuencia)
				INTO sSecuenciaM_img
				--FROM BDIDIGITAL@COPPELIMG_TCP: "informix".dg_expediente_img
				FROM bdidigital@coppelimg_crx: "informix".dg_expediente_img1
				WHERE cod_docto = cCod_Doc_Img
				AND cliente = pNumCteCorrecto;

				LET sSecuenciaMax_Img = sSecuenciaM_Img + 1;

				--UPDATE BDIDIGITAL@COPPELIMG_TCP: "informix".dg_expediente_img SET cliente = pNumCteCorrecto, secuencia = sSecuenciaMax_img  WHERE empresa = pEmpresa AND cliente = pNumCteIncorrecto AND cod_docto = cCod_Doc_Img AND secuencia = sSecuencia_Inc_Img;
				--UPDATE bdidigital@coppelimg_tcp: "informix".dg_expediente_img1 SET cliente = pNumCteCorrecto, secuencia = sSecuenciaMax_img  WHERE empresa = pEmpresa AND cliente = pNumCteIncorrecto AND cod_docto = cCod_Doc_Img AND secuencia = sSecuencia_Inc_Img;
				UPDATE bdidigital@coppelimg_crx: "informix".dg_expediente_img1 SET cliente = pNumCteCorrecto, secuencia = sSecuenciaMax_img  WHERE cliente = pNumCteIncorrecto AND cod_docto = cCod_Doc_Img AND secuencia = sSecuencia_Inc_Img;
				LET cCod_Doc_Img = '';
			ELSE
				--UPDATE BDIDIGITAL@COPPELIMG_TCP: "informix".dg_expediente_img SET cliente = pNumCteCorrecto WHERE empresa = pEmpresa AND cliente = pNumCteIncorrecto AND cod_docto = cIncorrecto_Img;
				--UPDATE bdidigital@coppelimg_tcp: "informix".dg_expediente_img1 SET cliente = pNumCteCorrecto WHERE empresa = pEmpresa AND cliente = pNumCteIncorrecto AND cod_docto = cIncorrecto_Img;
				UPDATE bdidigital@coppelimg_crx: "informix".dg_expediente_img1 SET cliente = pNumCteCorrecto WHERE cliente = pNumCteIncorrecto AND cod_docto = cIncorrecto_Img;
				LET cIncorrecto_Img = '';
			END IF;
		END FOREACH;


		FOREACH
			SELECT DISTINCT cod_docto,secuencia
			INTO cIncorrecto_Img2,sSecuencia_Inc_Img2
			--FROM BDIDIGITAL@COPPELIMG_TCP: "informix".dg_expediente_img_his
			FROM bdidigital@coppelimghis_tcp:"informix".dg_expediente_img_his
			--WHERE empresa = pEmpresa
			WHERE cliente = pNumCteIncorrecto

			SELECT DISTINCT cod_docto
			INTO cCod_Doc_Img2
			--FROM BDIDIGITAL@COPPELIMG_TCP: "informix".dg_expediente_img_his
			FROM bdidigital@coppelimghis_tcp:"informix".dg_expediente_img_his
			--WHERE empresa = pEmpresa
			WHERE cliente = pNumCteCorrecto
			AND cod_docto = cIncorrecto_Img2;

			IF TRIM(cCod_Doc_Img2) IS NOT NULL THEN
				SELECT MAX(secuencia)
				INTO sSecuenciaM_Img2
				--FROM BDIDIGITAL@COPPELIMG_TCP:"informix".dg_expediente_img_his
				FROM bdidigital@coppelimghis_tcp:"informix".dg_expediente_img_his
				WHERE cod_docto = cCod_Doc_Img2
				AND cliente = pNumCteCorrecto;
				LET sSecuenciaMax_Img2 = sSecuenciaM_Img2 + 1;

				--UPDATE BDIDIGITAL@COPPELIMG_TCP:"informix".dg_expediente_img_his SET cliente = pNumCteCorrecto, secuencia = sSecuenciaMax_img2  WHERE empresa = pEmpresa AND cliente = pNumCteIncorrecto AND cod_docto = cCod_Doc_Img2 AND secuencia = sSecuencia_Inc_Img2;
				--UPDATE bdidigital@coppelimghis_tcp:"informix".dg_expediente_img_his SET cliente = pNumCteCorrecto, secuencia = sSecuenciaMax_img2  WHERE empresa = pEmpresa AND cliente = pNumCteIncorrecto AND cod_docto = cCod_Doc_Img2 AND secuencia = sSecuencia_Inc_Img2;
				UPDATE bdidigital@coppelimghis_tcp:"informix".dg_expediente_img_his SET cliente = pNumCteCorrecto, secuencia = sSecuenciaMax_img2  WHERE cliente = pNumCteIncorrecto AND cod_docto = cCod_Doc_Img2 AND secuencia = sSecuencia_Inc_Img2;
				LET cCod_Doc_Img2 = '';
			ELSE
				--UPDATE BDIDIGITAL@COPPELIMG_TCP:"informix".dg_expediente_img_his SET cliente = pNumCteCorrecto WHERE empresa = pEmpresa AND cliente = pNumCteIncorrecto AND cod_docto = cIncorrecto_Img2;
				--UPDATE bdidigital@coppelimghis_tcp:"informix".dg_expediente_img_his SET cliente = pNumCteCorrecto WHERE empresa = pEmpresa AND cliente = pNumCteIncorrecto AND cod_docto = cIncorrecto_Img2;
				UPDATE bdidigital@coppelimghis_tcp:"informix".dg_expediente_img_his SET cliente = pNumCteCorrecto WHERE cliente = pNumCteIncorrecto AND cod_docto = cIncorrecto_Img2;
				LET cIncorrecto_Img2 = '';
			END IF;
		END FOREACH;
		RETURN cCodRet,cProceso;
	END IF;
END;

END PROCEDURE
DOCUMENT
'Folio: 1568 ',
'AUTOR : Leonardo Plata',
'FECHA : 18/12/2013',
'MODIFICACIÃÂN: Se crea sp para la finalidad de respaldar los documentos digitales.',
'SUSTENTO: RQM 61 071 FusiÃÂ³n AutomÃÂ¡tica de clientes.doc (Pagina 5,6,7,8)',
'SOLICITA: Jaime GonzÃÂ¡lez',
'AUTOR: JosÃÂ© CristÃÂ³bal HernÃÂ¡ndez Fierro',
'FECHA: 15/07/2014',
'MODIFICACIÃÂN: Se valida si cod_doc no es NULO para las tablas dg_expediente_img y dg_expediente_img_his',
'SUSTENTO: RQI 64 028 Modificacion FusiÃÂ³n ipab',
'----------------------------------------------',
'FECHA: 09/11/2015',
'MODIFICACIÃÂN: Se modifica para especificar instancia de imagenes correcta de acuerdo al tipo de imagen (historica o actual)',
'SUSTENTO: RQI 64 127 Separacion de imagenes',
'---------------------',
'SUSTENTA: INC 64 027',
'FECHA: 25/11/2015',
'MODIFICACIÃÂN: Se modifica para especificar correctamente la instancia donde reside el SP sp_carga_img2';

CREATE PROCEDURE "informix".sp_exporta_imagen_postgresql_encabezado(dFechaHoy date)
RETURNING  CHAR(5);

 DEFINE cCodret         CHAR(5);
 DEFINE iSql_err        	INT;  
 DEFINE iSam_err			INT; 
 DEFINE cSQL			CHAR(200);
 DEFINE cArchivo			CHAR(100);
 DEFINE cRuta			CHAR(100);
 DEFINE cRutaArchivo		CHAR(100);
 DEFINE cTotalAltas		CHAR(100);
 DEFINE cTotalImgs		CHAR(100);
 DEFINE cTotalTemps		CHAR(100);
 DEFINE cFecha			CHAR(8);
 
 LET cCodret = '';
 LET iSql_err = 0;
 LET iSam_err = 0;
 LET cSQL = '';
 LET cArchivo = '';
 LET cRuta = '';
 LET cRutaArchivo = '';
 LET cTotalAltas = 0;
 LET cTotalImgs = 0;
 LET cTotalTemps = 0;
 LET cFecha = '';
 
 BEGIN
 
 ON EXCEPTION SET iSql_err,iSam_err
      IF iSql_err <> 0 OR iSam_err <> 0 THEN
         let cCodret = iSql_err;
         RETURN cCodret;
      END IF;
   END EXCEPTION;
   
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
 
	--SET DEBUG FILE TO "/tmp/JesusRubio/PruebaJesus.txt";
	--TRACE ON;
	
	LET cFecha = LPAD(YEAR(dFechaHoy),4,'0') || LPAD(MONTH(dFechaHoy),2,'0') || LPAD(DAY(dFechaHoy),2,'0');
	
	SELECT valor INTO cRuta FROM bdirostros@coppelimghis_tcp:"informix".dg_params_rostros WHERE empresa = '001' AND cod_param = '1';
	
	SELECT valor INTO cArchivo FROM bdirostros@coppelimghis_tcp:"informix".dg_params_rostros WHERE empresa = '001' AND cod_param = '3';
	
	LET cArchivo = REPLACE(cArchivo,"aaaa",LPAD(YEAR(dFechaHoy),4,'0'));
	LET cArchivo = REPLACE(cArchivo,"mm",LPAD(MONTH(dFechaHoy),2,'0'));
	LET cArchivo = REPLACE(cArchivo,"dd",LPAD(DAY(dFechaHoy),2,'0'));
	
	
	LET cRutaArchivo = TRIM(cRuta) || TRIM(cArchivo);

	SELECT {+INDEX(si_cte_rostro idx_si_cte_rostro_bio)} count(DISTINCT(numcte))
	INTO cTotalAltas
	FROM bdinteg:"informix".si_cte_rostro 
	WHERE fecha_alta = dFechaHoy;
	
	SELECT {+INDEX(si_cte_rostro idx_si_cte_rostro_bio2)} COUNT(DISTINCT(numcte)) 
	INTO cTotalTemps
	FROM bdinteg:"informix".si_cte_rostro 
	WHERE template_procesado = 1 AND fecha_camb = dFechaHoy;		
	
	SELECT COUNT(cliente) 
	  INTO cTotalImgs
	  FROM bdirostros@coppelimghis_tcp:"informix".dg_expediente_img1 
         WHERE imagen IS NOT NULL 
           AND cod_docto = '0062' 
           AND fecha_alta = dFechaHoy;
	
	LET cSQL = 'echo "' || cFecha || '|' || TRIM(cTotalAltas) || '|' || TRIM(cTotalTemps) || '|' || TRIM(cTotalImgs) || '" > ' || TRIM(cRutaArchivo);
	System TRIM(cSQL);
		
 
END;    
END PROCEDURE
DOCUMENT
'Folio:58.3',
'Autor:97877352 Rubio Lugo Jesus Alberto',
'Fecha:29/09/2017',
'ModificaciÃÂ³n: Se crea procedimiento almacenado para Generar archivo plano con los Totales de Altas y Templetes para su posterior envio a BanCoppel.',
'Solicita: Abraham Narvaez Jacinto',
'Sustento: Biometria Facial Bancoppel Exportar Totales de templates a un archivo plano',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_cuentadoctos(pNumeroCliente CHAR(20),pTipo_cte SMALLINT)
RETURNING CHAR(5),INT,CHAR(100);
--DECLARACION DE VARIABLES
DEFINE vc_CodRet    CHAR(5);
DEFINE vi_SqlErr    INTEGER;
DEFINE v_contador        smallint;
DEFINE v_registro    INTEGER;
DEFINE vc_CodDocto  CHAR(4);
DEFINE vs_Secuencia SMALLINT;
DEFINE v_nomarch    CHAR(20);
DEFINE v_nomarch2    CHAR(20);
DEFINE v_ruta       CHAR(50);
DEFINE isam_err  INT;
DEFINE v_descripcion  CHAR(100);
DEFINE vc_aniomesI       CHAR(6);
DEFINE vc_aniomesF       CHAR(6);
DEFINE cFecha			CHAR(10);
--INICIALIZACION DE VARIABLES
LET vc_CodDocto = "";
LET vs_Secuencia = 0;
LET vc_CodRet = "00000";
LET vi_SqlErr = 0;
LET v_registro=0;
LET v_contador=0;
LET v_nomarch='img';
LET v_nomarch2="";
LET v_ruta="";
LET isam_err="0";
LET v_descripcion="PROCESO EJECUTADO CORRECTAMENTE";
LET vc_aniomesI="";
LET vc_aniomesF="";
LET cFecha="";

  --SET DEBUG FILE TO "/informix/VH/integ/sp_cuentadoctos.out";
  --TRACE ON;

--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN

  ON EXCEPTION SET vi_SqlErr
    IF vi_SqlErr <> 0 THEN
        let v_descripcion="ERROR EN EL PROCESO";
        LET vc_CodRet = vi_SqlErr;
        RETURN vc_CodRet,isam_err,v_descripcion;
    END IF;
  END EXCEPTION;

    IF pNumeroCliente IS NULL OR pNumeroCliente = "" THEN --PARAMETROS INVALIDOS
        LET vc_CodRet = "99999";
        RETURN vc_CodRet,isam_err,v_descripcion;
    END IF;

	SELECT fecha_hoy INTO cFecha from si_fechas;
	
	LET vc_aniomesI=SUBSTR(cFecha,7,4)||'01';
	LET vc_aniomesF=SUBSTR(cFecha,7,4)||'12';



    IF EXISTS (SELECT numcte FROM bdinteg:si_cliente WHERE (numcte = pNumeroCliente AND tpo_persona = "02")) THEN --CLIENTE PERSONA MORAL
        LET vc_CodRet = "00100"; 
        RETURN vc_CodRet,isam_err,v_descripcion;
    END IF;
    
    IF pTipo_cte=2 THEN
        IF EXISTS (SELECT num_cte FROM bdilide:sl_retlide WHERE num_cte = pNumeroCliente AND aniomes BETWEEN vc_aniomesI AND vc_aniomesF ) THEN --CLIENTE CON ADEUDO EN IDE, IMPOSIBLE REALIZAR TRASPASO DE CUENTAS
            LET vc_CodRet = "00200"; 
            RETURN vc_CodRet,isam_err,v_descripcion;
        END IF;
    END IF;

    IF pTipo_cte=2 THEN
        IF EXISTS (SELECT numcte FROM bdinteg:si_bpiusuarios WHERE numcte= pNumeroCliente AND servicio=2 AND empresa='001' AND id_status<>99) THEN --CLIENTE CON BANCA ELECTRONICA AVANZADA
            LET vc_CodRet = "00300"; 
            RETURN vc_CodRet,isam_err,v_descripcion;
        END IF;
    END IF;

    IF EXISTS (SELECT numcte FROM bdinteg:si_cliente WHERE numcte= pNumeroCliente AND status_cte="FU") THEN --CLIENTE FUSIONADO
        LET vc_CodRet = "00400";
        RETURN vc_CodRet,isam_err,v_descripcion; 
    END IF;

    SELECT TRIM(valor) INTO v_ruta FROM bdinteg:si_param WHERE cod_param=122;

    FOREACH
        SELECT cod_docto,secuencia
        INTO vc_CodDocto, vs_Secuencia
        FROM bdidigital@coppelimg_tcp:dg_expediente
        WHERE cliente = pNumeroCliente
        --WHERE cliente = pNumeroCliente AND empresa='001'

        SELECT nvl(count(*),0) INTO v_registro 
        --FROM bdidigital@coppelimg_tcp:dg_expediente_img
		FROM bdidigital@coppelimg_crx:dg_expediente_img1
        WHERE cliente = pNumeroCliente 
        AND cod_docto=vc_CodDocto AND secuencia=vs_Secuencia ;
        --AND cod_docto=vc_CodDocto AND secuencia=vs_Secuencia AND empresa='001';
		
		IF v_registro=0 THEN
			SELECT nvl(count(*),0) INTO v_registro 
			FROM bdidigital@coppelimghis_tcp:dg_expediente_img
			WHERE cliente = pNumeroCliente 
			AND cod_docto=vc_CodDocto AND secuencia=vs_Secuencia AND empresa='001';
			
			IF v_registro=0 THEN
				SELECT nvl(count(*),0) INTO v_registro 				
				FROM bdidigital@coppelimghis_tcp:dg_expediente_img_his
				WHERE cliente = pNumeroCliente 
				AND cod_docto=vc_CodDocto AND secuencia=vs_Secuencia AND empresa='001';
			END IF;
		END IF;
        
        IF v_registro=0 THEN
            INSERT INTO bdidigital@coppelimg_crx:dg_expediente_fus
            SELECT * FROM bdidigital@coppelimg_crx:dg_expediente WHERE cliente = pNumeroCliente AND cod_docto=vc_CodDocto AND secuencia=vs_Secuencia ;
            DELETE FROM bdidigital@coppelimg_crx:dg_expediente WHERE cliente = pNumeroCliente AND cod_docto=vc_CodDocto AND secuencia=vs_Secuencia ;
            --SELECT * FROM bdidigital@coppelimg_tcp:dg_expediente WHERE cliente = pNumeroCliente AND cod_docto=vc_CodDocto AND secuencia=vs_Secuencia AND empresa='001';
            --DELETE FROM bdidigital@coppelimg_tcp:dg_expediente WHERE cliente = pNumeroCliente AND cod_docto=vc_CodDocto AND secuencia=vs_Secuencia AND empresa='001';
        END IF
    END FOREACH;


    FOREACH
        SELECT cod_docto,secuencia
        INTO vc_CodDocto, vs_Secuencia
        --FROM bdidigital@coppelimg_tcp:dg_expediente_img
		FROM bdidigital@coppelimg_crx:dg_expediente_img1
        WHERE cliente = pNumeroCliente AND empresa='001'

        SELECT nvl(count(*),0) INTO v_registro 
        FROM bdidigital@coppelimg_crx:dg_expediente
        WHERE cliente = pNumeroCliente 
        AND cod_docto=vc_CodDocto AND secuencia=vs_Secuencia;
        --AND cod_docto=vc_CodDocto AND secuencia=vs_Secuencia AND empresa='001';
        
        IF v_registro=0 THEN
            LET v_nomarch2=trim(v_nomarch)||TRIM(pNumeroCliente)||'.unl';
            CALL bdidigital@coppelimg_crx:sp_resimgapl(pNumeroCliente,v_nomarch2,v_ruta,vc_CodDocto,vs_Secuencia) RETURNING vc_CodRet,isam_err,v_descripcion;
            CALL bdidigital@coppelimg_crx:sp_carga_img(pNumeroCliente,v_nomarch2,v_ruta) RETURNING vc_CodRet,isam_err,v_descripcion;
			IF vc_CodRet="00000" THEN
				--DELETE FROM bdidigital@coppelimg_tcp:dg_expediente_img WHERE cliente = pNumeroCliente AND cod_docto=vc_CodDocto AND secuencia=vs_Secuencia AND empresa='001';
				DELETE FROM bdidigital@coppelimg_crx:dg_expediente_img1 WHERE cliente = pNumeroCliente AND cod_docto=vc_CodDocto AND secuencia=vs_Secuencia AND empresa='001';
			END IF;
        END IF
    END FOREACH;

    FOREACH
        SELECT cod_docto,secuencia
        INTO vc_CodDocto, vs_Secuencia
		FROM bdidigital@coppelimghis_tcp:dg_expediente_img
        WHERE cliente = pNumeroCliente AND empresa='001'

        SELECT nvl(count(*),0) INTO v_registro 
        FROM bdidigital@coppelimg_crx:dg_expediente
        WHERE cliente = pNumeroCliente 
        AND cod_docto=vc_CodDocto AND secuencia=vs_Secuencia;
        --AND cod_docto=vc_CodDocto AND secuencia=vs_Secuencia AND empresa='001';
        
        IF v_registro=0 THEN
            LET v_nomarch2=trim(v_nomarch)||TRIM(pNumeroCliente)||'.unl';
            CALL bdidigital@coppelimghis_tcp:sp_resimgapl3(pNumeroCliente,v_nomarch2,v_ruta,vc_CodDocto,vs_Secuencia) RETURNING vc_CodRet,isam_err,v_descripcion;
            CALL bdidigital@coppelimg_crx:sp_carga_img3(pNumeroCliente,v_nomarch2,v_ruta) RETURNING vc_CodRet,isam_err,v_descripcion;
			IF vc_CodRet="00000" THEN
				DELETE FROM bdidigital@coppelimghis_tcp:dg_expediente_img WHERE cliente = pNumeroCliente AND cod_docto=vc_CodDocto AND secuencia=vs_Secuencia AND empresa='001';
			END IF;
        END IF
    END FOREACH;	

    FOREACH
        SELECT cod_docto,secuencia
        INTO vc_CodDocto, vs_Secuencia
        --FROM bdidigital@coppelimg_tcp:dg_expediente_img_his
		FROM bdidigital@coppelimghis_tcp:dg_expediente_img_his
        WHERE cliente = pNumeroCliente
        --WHERE cliente = pNumeroCliente AND empresa='001'

        SELECT nvl(count(*),0) INTO v_registro 
        FROM bdidigital@coppelimg_crx:dg_expediente
        WHERE cliente = pNumeroCliente 
        AND cod_docto=vc_CodDocto AND secuencia=vs_Secuencia ;
        --AND cod_docto=vc_CodDocto AND secuencia=vs_Secuencia AND empresa='001';
        
        IF v_registro=0 THEN
            LET v_nomarch2=trim(v_nomarch)||TRIM(pNumeroCliente)||'.unl';
            CALL bdidigital@coppelimghis_tcp:sp_resimgapl2(pNumeroCliente,v_nomarch2,v_ruta,vc_CodDocto,vs_Secuencia) RETURNING vc_CodRet,isam_err,v_descripcion;
            CALL bdidigital@coppelimg_crx:sp_carga_img2(pNumeroCliente,v_nomarch2,v_ruta) RETURNING vc_CodRet,isam_err,v_descripcion;
			IF vc_CodRet="00000" THEN
				--DELETE FROM bdidigital@coppelimg_tcp:dg_expediente_img_his WHERE cliente = pNumeroCliente AND cod_docto=vc_CodDocto AND secuencia=vs_Secuencia AND empresa='001';
				DELETE FROM bdidigital@coppelimghis_tcp:dg_expediente_img_his WHERE cliente = pNumeroCliente AND cod_docto=vc_CodDocto AND secuencia=vs_Secuencia AND empresa='001';
			END IF;
        END IF
    END FOREACH;

    RETURN vc_CodRet,isam_err,v_descripcion;
END;
END PROCEDURE
DOCUMENT
'----------------------------------------------',
'FECHA: 10/11/2015',
'MODIFICACIÃÂÃÂN: Se modifica para especificar instancia de imagenes correcta de acuerdo al tipo de imagen (historica o actual)',
'SUSTENTO: RQI 64 127 Separacion de imagenes',
'---------------------',
'SUSTENTA: INC 64 027',
'FECHA: 25/11/2015',
'MODIFICACIÃÂÃÂN: Se modifica para especificar correctamente la instancia donde reside el SP sp_carga_img2', 
'---------------------',
'SUSTENTA: RQI 64 132',
'FECHA: 07/12/2015',
'MODIFICACION: Se modifica para contemplar la depuracion de inconsistencias en la tabla dg_expediente_img de la instancia coppelimghis_tcp';

CREATE PROCEDURE "informix".sp_busca_producto_deb_inver_cuenta(p_sNumeroCuenta CHAR(20), p_sNumeroEmpresa CHAR(3))
     
     RETURNING	CHAR(6) AS numeroProducto,CHAR(60) AS nombreProducto, CHAR(30) AS numeroCuenta, CHAR(30) AS numeroTarjeta, CHAR(30) AS numeroCuentaInversion;
    
	--definicion de variables--	    
    DEFINE resultado_numeroProducto 		CHAR(6);
	DEFINE resultado_nombreProducto 		CHAR(60);
	DEFINE resultado_numeroCuenta			CHAR(30);
	DEFINE resultado_numeroTarjeta			CHAR(30);
    DEFINE resultado_numeroCuentaInversion	CHAR(30);
	DEFINE iSqlErr                      	INTEGER;
	
     -- Inicializacion de las variables.
    LET resultado_numeroProducto = '';
	LET resultado_nombreProducto = '';
	LET resultado_numeroCuenta = '';
	LET resultado_numeroTarjeta = '';
    LET resultado_numeroCuentaInversion = '';
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	BEGIN

        ON EXCEPTION
            SET iSqlErr
            	IF iSqlErr <> 0 THEN
                    LET resultado_numeroProducto = '';
                	LET resultado_nombreProducto = '';
                	LET resultado_numeroCuenta = '';
                	LET resultado_numeroTarjeta = '';
                    LET resultado_numeroCuentaInversion = '';
               		RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta, resultado_numeroCuentaInversion;
            	END IF;
        END EXCEPTION;

			SELECT DISTINCT '3000' as numeroProducto, nombre AS nombreProducto, cuenta AS cuentaProducto, cta_cheques AS cuentaInvCheques
			INTO resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroCuentaInversion
			FROM bdinvers:sv_maeinv 
               	LEFT JOIN bdinvers:sv_instrum ON (bdinvers:sv_maeinv.cod_instrum = bdinvers:sv_instrum.cod_instrum) 
            WHERE bdinvers:sv_maeinv.cuenta = p_sNumeroCuenta /*AND bdinvers:sv_maeinv.empresa = p_sNumeroEmpresa*/;
			RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta, resultado_numeroCuentaInversion;
	END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'ModificaciÃ³n	:	BanCoppel',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Diciembre/2019',
'Requerimiento	:	RQM 06 599',
'VERSION		: 	2.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".direcciones_sms_web( pEmpresa         CHAR(3),
                                         pFuncion         CHAR(1),
                                         pNumCte          CHAR(20),
                                         pSecuencia       SMALLINT,
                                         pTipoDir         CHAR(1),
                                         pCalle           CHAR(40),
                                         pColonia         CHAR(60),
                                         pMunicipio       CHAR(5),
                                         pEntre_Calles    CHAR(40),
                                         pPais            CHAR(3),
                                         pEntidad         CHAR(2),
                                         pLocalidad       CHAR(3),
                                         pCodPostal       CHAR(5),
                                         pTipoTel1        CHAR(1),
                                         pTelefono1       CHAR(13),
                                         pTipoTel2        CHAR(1),
                                         pTelefono2       CHAR(13),
                                         pTipoTel3        CHAR(1),
                                         pTelefono3       CHAR(13),
                                         pExtension       CHAR(5),
                                         pEstado_Inegi    CHAR(2),
                                         pMunicipio_Inegi CHAR(3),
                                         pLocalidad_Inegi CHAR(4),
                                         pNoCiudad        SMALLINT,
                                         pNoExt           CHAR(10),
                                         pNoInt           CHAR(10),
                                         pDepto           CHAR(6),
                                         pNoCalle         INTEGER,
                                         pNoColonia       INTEGER,
                                         pPuntoCar        CHAR(1),
                                         pUniHabi         CHAR(1),
                                         pManz            SMALLINT,
                                         pPOtros          SMALLINT,
                                         pAndador         SMALLINT,
                                         pEtapa           SMALLINT,
                                         pLote            SMALLINT,
                                         pEdif            SMALLINT,
                                         pEntrada         SMALLINT,
                                         pObserva         CHAR(80),
                                         pUser_Insert     CHAR(8),
                                         pFecha_Insert    DATE,
                                         cSucursal        CHAR(4),
                                         pCarrier         SMALLINT )
RETURNING CHAR(5);
    
    DEFINE v_CodRet             CHAR(5);
    DEFINE v_CodRet2            CHAR(5);
    DEFINE v_CodRet3            CHAR(50);
    DEFINE v_SqlErr             INTEGER;
    DEFINE v_IsamErr            INTEGER;
    DEFINE v_DescErr            CHAR(50);
    DEFINE v_NumCte             CHAR(20);
    DEFINE pcoincide_dir        SMALLINT;
    DEFINE o_tipo_dir       	CHAR(1);
    DEFINE o_calle          	CHAR(40);
    DEFINE o_colonia        	CHAR(60);
    DEFINE o_entre_calles   	CHAR(40);
    DEFINE o_pais           	CHAR(3);
    DEFINE o_estado         	CHAR(2);
    DEFINE o_ciudad         	CHAR(3);
    DEFINE o_municipio      	CHAR(5);
    DEFINE o_cod_postal     	CHAR(5);
    DEFINE o_apart_postal   	CHAR(11);
    DEFINE o_telefono1      	CHAR(13);
    DEFINE o_telefono2      	CHAR(13);
    DEFINE o_telefono3      	CHAR(13);
    DEFINE o_extension      	CHAR(5);
    DEFINE o_estado_inegi   	CHAR(2);
    DEFINE o_municipio_inegi	CHAR(3);
    DEFINE o_localidad_inegi    CHAR(4);
    DEFINE o_numerociudad   	SMALLINT;
    DEFINE o_numeroextcalle 	CHAR(10);
    DEFINE o_numerointcalle 	CHAR(10);
    DEFINE o_departamento   	CHAR(6);
    DEFINE o_numerocalle    	INTEGER;
    DEFINE o_numerocolonia  	INTEGER;
    DEFINE o_puntocardinal  	CHAR(1);
    DEFINE o_unidadhabitac  	CHAR(1);
    DEFINE o_manzana        	SMALLINT;
    DEFINE o_otros          	SMALLINT;
    DEFINE o_andador        	SMALLINT;
    DEFINE o_etapa          	SMALLINT;
    DEFINE o_lote           	SMALLINT;
    DEFINE o_edificio       	SMALLINT;
    DEFINE o_entrada        	SMALLINT;
    DEFINE o_observaciones  	CHAR(80);
    DEFINE v_CodRetTel          CHAR(5);
    DEFINE vTipoTel             SMALLINT;
    DEFINE vCanal               SMALLINT;
    DEFINE cSituacionEsp        CHAR(1);  --- VARIABLE DE SITUACION ESPECIAL
    DEFINE iCausa               INTEGER;  --- VARIABLE DE SITUACION ESPECIAL
	
	DEFINE correoCli            CHAR(100);   --vero
	DEFINE nomEstadoV           CHAR(50);
	DEFINE nomCiudadV           CHAR(50);
	DEFINE nomCalleV            CHAR(50);
	DEFINE nomEstadoN           CHAR(50);
	DEFINE nomCiudadN           CHAR(50);
	DEFINE nomCalleN            CHAR(50);
	DEFINE cCodRetSp1           CHAR(5);
	DEFINE cCodRetSp2           CHAR(5);
    
    LET v_CodRet          = '';
    LET v_CodRet2         = '';
    LET v_CodRet3         = '';
    LET v_SqlErr          = 0;
    LET v_IsamErr         = 0;
    LET v_DescErr         = '';
    LET v_NumCte          = '';
    LET pcoincide_dir     = 0;
    LET o_tipo_dir        = '';
    LET o_calle           = '';
    LET o_colonia         = '';
    LET o_entre_calles    = '';
    LET o_pais            = '';
    LET o_estado          = '';
    LET o_ciudad          = '';
    LET o_municipio       = '';
    LET o_cod_postal      = '';
    LET o_apart_postal    = '';
    LET o_telefono1       = '';
    LET o_telefono2       = '';
    LET o_telefono3       = '';
    LET o_extension       = '';
    LET o_estado_inegi    = '';
    LET o_municipio_inegi = '';
    LET o_localidad_inegi = '';
    LET o_numerociudad    = 0;
    LET o_numeroextcalle  = '';
    LET o_numerointcalle  = '';
    LET o_departamento    = '';
    LET o_numerocalle     = 0;
    LET o_numerocolonia   = 0;
    LET o_puntocardinal   = '';
    LET o_unidadhabitac   = '';
    LET o_manzana         = 0;
    LET o_otros           = 0;
    LET o_andador         = 0;
    LET o_etapa           = 0;
    LET o_lote            = 0;
    LET o_edificio        = 0;
    LET o_entrada         = 0;
    LET o_observaciones   = '';
    LET v_CodRetTel       = '';
    LET vTipoTel          = 0;
    LET vCanal            = 1;
    LET cSituacionEsp     = 'N'; --- VARIABLE DE SITUACION ESPECIAL
    LET iCausa            = 0;   --- VARIABLE DE SITUACION ESPECIAL
	
	LET correoCli         ='';
	LET nomEstadoV        ='';
	LET nomCiudadV        ='';
	LET nomCalleV         ='';
	LET nomEstadoN        ='';
	LET nomCiudadN        ='';
	LET nomCalleN         ='';
	LET cCodRetSp1        ='00000';
	LET cCodRetSp2        ='00000';
    
    --SET DEBUG FILE TO "/informix/LIP/direcciones_sms.out";
	--TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET v_SqlErr, v_IsamErr, v_DescErr
        --SET DEBUG FILE TO "/tmp/direcciones_carrier.err";
        --TRACE ON;
        IF v_SqlErr != 0 THEN
            LET v_CodRet = v_SqlErr;
            LET v_CodRet2 = v_IsamErr;
            LET v_CodRet3 = v_DescErr;
            RETURN v_CodRet;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    LET v_CodRet = "00000";
    LET pEntidad = CAST( LPAD (TRIM(pEntidad), 2 ,  "0") AS CHAR(2));

    SELECT numcte 
      INTO v_NumCte 
      FROM "informix".si_cliente
     WHERE numcte = pNumCte;
     
    IF v_NumCte IS NULL THEN
        LET v_CodRet = "00104";
        RETURN v_CodRet;
    END IF

    IF pFuncion = "C" THEN
        DELETE FROM "informix".si_direcciones
         WHERE numcte = pNumCte 
           AND secuencia = pSecuencia;
           
        DELETE FROM "informix".si_direcciones_actual
         WHERE numcte = pNumCte 
           AND secuencia = pSecuencia;
           
        LET pFuncion = "A";
    END IF

    IF pFuncion = "A" THEN
		-- // CGP SE TOMA LA SECUENCIA DE LA TABLA MAESTRA si_direcciones
        SELECT MAX(secuencia) 
          INTO pSecuencia
          FROM "informix".si_direcciones 
         WHERE numcte = pNumCte;
         
        IF pSecuencia IS NULL THEN
            LET pSecuencia = 1;
        ELSE
            LET pSecuencia = pSecuencia + 1;
            LET cSituacionEsp = 'S';
        END IF;
        
        -- // SE AGREGA VALIDACION PARA SI LA CLAVE DEL MUNICIPIO VIENE VACIO, LE ASIGNE  "00000".
        IF pMunicipio = "" OR pMunicipio is null THEN
            LET pMunicipio = LPAD(TRIM(NVL(pMunicipio,"00000")),5,"0");
        END IF;
        
        -- // VALIDA LA INFORMACION DE LA DIRECCION DEL CLIENTE
        SELECT tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal,
               estado_inegi, municipio_inegi, localidad_inegi, numerociudad, 
               numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, 
               puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones
          INTO o_tipo_dir, o_calle, o_colonia, o_entre_calles, o_pais, o_estado, o_ciudad, o_municipio, o_cod_postal, o_apart_postal,
               o_estado_inegi, o_municipio_inegi, o_localidad_inegi, o_numerociudad, 
               o_numeroextcalle, o_numerointcalle, o_departamento, o_numerocalle, o_numerocolonia, 
               o_puntocardinal, o_unidadhabitac, o_manzana, o_otros, o_andador, o_etapa, o_lote, o_edificio, o_entrada, o_observaciones
          FROM "informix".si_direcciones_actual
         WHERE numcte = pNumCte
           AND tipo_dir = pTipoDir;
           
        IF ( o_tipo_dir is not null 
             AND o_calle = pCalle 
             AND o_colonia = pColonia 
             AND o_entre_calles = pEntre_Calles 
             AND o_pais = pPais 
             AND o_estado = pEntidad  
             AND o_ciudad = pLocalidad  
             AND o_municipio = pMunicipio  
             AND o_cod_postal = pCodPostal 
             AND o_estado_inegi = pEstado_Inegi
             AND o_municipio_inegi = pMunicipio_Inegi
             AND o_localidad_inegi = pLocalidad_Inegi
             AND o_numerociudad = pNoCiudad
             AND o_numeroextcalle = pNoExt
             AND o_numerointcalle = pNoInt
             AND o_departamento = pDepto
             AND o_numerocalle = pNoCalle
             AND o_numerocolonia = pNoColonia
             AND o_puntocardinal = pPuntoCar
             AND o_unidadhabitac = pUniHabi
             AND o_manzana = pManz
             AND o_otros = pPOtros
             AND o_andador  = pAndador
             AND o_etapa = pEtapa
             AND o_lote = pLote
             AND o_edificio = pEdif
             AND o_entrada = pEntrada
             AND o_observaciones = pObserva ) THEN
            LET pcoincide_dir = 1;
        ELSE
            LET pcoincide_dir = 0;
        END IF;

        IF ( pcoincide_dir <= 0 ) THEN
            INSERT INTO "informix".si_direcciones
            ( numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal,
              estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, 
              departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, otros, 
              andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert )
            VALUES
            ( pNumCte, pSecuencia, pTipoDir, pCalle, pColonia, pEntre_Calles, pPais, pEntidad, pLocalidad, pMunicipio, pCodPostal, "",
              pEstado_Inegi, pMunicipio_Inegi, pLocalidad_Inegi, pNoCiudad, pNoExt, pNoInt,
              pDepto, pNoCalle, pNoColonia, pPuntoCar, pUniHabi, pManz, pPOtros,
              pAndador, pEtapa, pLote, pEdif, pEntrada, pObserva, pUser_Insert, pFecha_Insert );
			  
			  
			SELECT correo_elec --Obtiene el correo del cliente
			INTO correoCli 
			FROM bdinteg:"informix".si_correos 
			WHERE numcte=pNumCte AND tipo_correo=1 AND status_correo='A';				
			IF (correoCli <> '') OR (pTelefono2 <> '') THEN 
				IF (pSecuencia > 1 AND pTipoDir = 1) THEN
					SELECT est.nombre , ciu.nombre, ccall.nombrecalle 
					INTO nomEstadoV , nomCiudadV, nomCalleV 
					FROM bdinteg:"informix".si_estados est, bdinteg:"informix".si_ciudades ciu, bdinteg:"informix".si_catcalles ccall 
					WHERE ciu.pais = o_pais AND est.estado = o_estado AND ciu.estado = o_estado AND ciu.ciudad = o_ciudad AND ccall.numerocalle = o_numerocalle;
			
					SELECT est.nombre , ciu.nombre, ccall.nombrecalle 
					INTO nomEstadoN , nomCiudadN, nomCalleN 
					FROM bdinteg:"informix".si_estados est, bdinteg:"informix".si_ciudades ciu, bdinteg:"informix".si_catcalles ccall 
					WHERE ciu.pais = pPais and est.estado = pEntidad AND ciu.estado = pEntidad AND ciu.ciudad = pLocalidad AND ccall.numerocalle = pNoCalle;
				
					IF correoCli <> '' THEN 
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CUB_EMAIL','MAIL_DOM',TRIM(pNumCte),'','','1',TRIM(nomEstadoV),TRIM(nomEstadoN),
						TRIM(nomCiudadV),TRIM(nomCiudadN),TRIM(nomCalleV)||' '|| TRIM(o_numeroextcalle) ||' '|| TRIM(o_numerointcalle),
						TRIM(nomCalleN) ||' '|| TRIM(pNoExt) ||' '|| TRIM(pNoInt),'','','','',TRIM(correoCli),'',1,0,0,0,0,'','') INTO cCodRetSp1;
					ELSE 
						IF pTelefono2 <> '' THEN
							EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CUB_SMS','SMS_DOM',TRIM(pNumCte),'','','1','','','','','','','','','','',
							'',TRIM(pTelefono2),1,0,0,0,0,'','') INTO cCodRetSp2; 
						END IF;
					END IF;
				END IF;
			END IF;
        END IF;
        
        -- // VALIDA LA INFORMACION DE LOS TELEFONOS DEL CLIENTE
        SELECT telefono
          INTO o_telefono1
          FROM "informix".si_telefonos_actual
         WHERE numcte = pNumCte
           AND tipo_tel = 1;
           
        IF o_telefono1 is null THEN
            LET o_telefono1 = ' ';
        END IF;
           
        IF o_telefono1 <> pTelefono1 THEN
            IF cSucursal = '5002' THEN
                LET vCanal = 12;
            END IF;
              
            IF ( ( pTipoTel1 is not null AND pTipoTel1 <> '' ) AND ( pTelefono1 is not null AND pTelefono1 <> '' ) ) THEN
                LET vTipoTel = 1;
				
				
				CALL "informix".sp_registra_telefonos(pEmpresa, pNumCte, pTelefono1, vTipoTel, '', 0, vCanal, pUser_Insert) RETURNING v_CodRetTel;
				IF  v_CodRetTel <> 0 THEN --SE AGREGA VALIDACION PARA FOLIO 377
					RETURN v_CodRetTel;
				END IF;
            END IF;
        END IF;
           
        SELECT telefono
          INTO o_telefono2
          FROM "informix".si_telefonos_actual
         WHERE numcte = pNumCte
           AND tipo_tel = 2;

		
		IF o_telefono2 is null THEN
			LET o_telefono2 = ' ';
		END IF;
			   
		IF o_telefono2 <> pTelefono2 THEN
			IF cSucursal = '5002' THEN
				LET vCanal = 12;
			END IF;
			--TRACE ON;

			IF ( ( pTipoTel2 is not null AND pTipoTel2 <> '' ) AND ( pTelefono2 is not null AND pTelefono2 <> '' ) ) THEN
				LET vTipoTel = 2;
				CALL "informix".sp_registra_telefonos(pEmpresa, pNumCte, pTelefono2, vTipoTel, '', pCarrier, vCanal, pUser_Insert) RETURNING v_CodRetTel;
				IF  v_CodRetTel <> 0 THEN --SE AGREGA VALIDACION PARA FOLIO 377
					RETURN v_CodRetTel;
				END IF;
			END IF;
		ELSE --SE AGREGA VALIDACION PARA FOLIO 377
			IF ( ( pTipoTel2 is not null AND pTipoTel2 <> '' ) AND ( pTelefono2 is not null AND pTelefono2 <> '' ) ) THEN
				LET vTipoTel = 2;
				CALL "informix".sp_registra_telefonos(pEmpresa, pNumCte, pTelefono2, vTipoTel, '', pCarrier, vCanal, pUser_Insert) RETURNING v_CodRetTel;
				IF  v_CodRetTel <> 0 THEN --SE AGREGA VALIDACION PARA FOLIO 377
					RETURN v_CodRetTel;
				END IF;
			END IF;
		END IF;

		
        SELECT telefono, extension
          INTO o_telefono3, o_extension
          FROM "informix".si_telefonos_actual
         WHERE numcte = pNumCte
           AND tipo_tel = 3;
           
        IF o_telefono3 is null THEN
            LET o_telefono3 = ' ';
        END IF;
           
        IF o_telefono3 <> pTelefono3 THEN
            IF cSucursal = '5002' THEN
                LET vCanal = 12;
            END IF;
              
            IF ( ( pTipoTel3 is not null AND pTipoTel3 <> '' ) AND ( pTelefono3 is not null AND pTelefono3 <> '' ) ) THEN
                LET vTipoTel = 3;
				
				
				CALL "informix".sp_registra_telefonos(pEmpresa, pNumCte, pTelefono3, vTipoTel, pExtension, 0, vCanal, pUser_Insert) RETURNING v_CodRetTel;
				IF  v_CodRetTel <> 0 THEN --SE AGREGA VALIDACION PARA FOLIO 377
					RETURN v_CodRetTel;
				END IF;
            END IF;
        END IF;
        
        -- // VALIDACION ESPECIAL
        IF pTipoDir = '1' AND cSituacionEsp = 'S' THEN
            SELECT LIMIT 1 NVL(situacion,''), causa
              INTO cSituacionEsp, iCausa
              FROM bdisitesp:"informix".se_ctessitespcte
             WHERE numcte = pNumCte;

            IF cSituacionEsp = 'L' THEN
                DELETE FROM bdisitesp:"informix".se_ctessitespcte 
                 WHERE numcte = pNumCte 
                   AND situacion = 'L';

                INSERT INTO bdisitesp:"informix".se_ctessitespcte_his
                (empresa, sucursal, numcte, situacion, causa, tipomovto, empleadoefectuo, usralta, fchmodifica)
                VALUES
                (pEmpresa, cSucursal, pNumCte, cSituacionEsp, iCausa, 'B', pUser_Insert, pUser_Insert, pFecha_Insert);
            END IF;
        END IF;

        RETURN v_CodRetTel;
    END IF;
    END;
END PROCEDURE

DOCUMENT
"Alta de direcciones del cliente",
"Autor : Procesamiento Interactivo S.A. de C.V.",
"MODIFICO : Manuel HernAndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1",
"MODIFICO : Hector Bojorquez",
"FECHA : 17/Junio/2009",
"MODIFICACION: En la actualizacion de domicilios se identifica si el cliente",
"              tiene una situacion especial L, de ser asi lo desmarca",
"Ver.  : 1.2",
"MODIFICO : Frank Gaxiola Gaxiola",
"FECHA : 28/Octubre/2009",
"MODIFICACION: Se quita funcionalidad de desmarcaje L, solicitado por Alfonso",
"              Velazquez",
"Ver.  : 1.3",
"MODIFICO : Rodolfo Tortolero Varela",
"FECHA : 06/Abril/2010",
"MODIFICACION: Se implementa validacion para formatear el campo municipio con",
"                             0 cuando este sea vacio o null, para que no inserte nuevo registro.",
"solicitado por Daniel Zambada",
"Ver.  : 1.4",
"MODIFICO : Rodolfo Gondez",
"FECHA : Mayo/2010",
"MODIFICACION: Se optimiza sp guardando la direccion del cliente en variables",
"              para la comparacion del cliente",
"Ver.  : 1.5",
"MODIFICO : Marco A. Campos",
"FECHA: 08-Ago-2011",
"MODIFICACION: Reactivar funcionalidad de desmarcaje situacion especial L.";

CREATE PROCEDURE "informix".sp_consulta_divisas_bym_web(pEmpresa CHAR(3), pCodDivisa CHAR(2))
RETURNING   CHAR(5)  AS CodRet,
			CHAR(4)  AS Sigla,
			CHAR(3)  AS Cve_intl,
			CHAR(3)  AS Cve_oficial,
			CHAR(30) AS Descripcion;
			
-- ****************************************************************************
-- Declarar variables
-- ****************************************************************************
DEFINE iSql_err       INTEGER;
DEFINE cCodRet        CHAR(5);
DEFINE cSigla         CHAR(4);
DEFINE cCve_intl      CHAR(3);
DEFINE cCve_oficial   CHAR(3);
DEFINE cDescripcion   CHAR(30);
DEFINE iBandera       INTEGER;


-- ****************************************************************************
-- Inicializar variables
-- ****************************************************************************
LET iSql_err		 = 0;
LET cCodRet          = '00000';
LET cSigla		     = '';
LET cCve_intl        = '';
LET cCve_oficial     = '';
LET cDescripcion     = '';
LET iBandera         = 0;

 --SET DEBUG FILE TO "/respaldosbd/felipe/Sps/sp_consulta_divisas_bym.out";
 --TRACE ON;

BEGIN

	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = CAST(iSql_err AS CHAR(5));
			RETURN cCodRet, cSigla, cCve_intl, cCve_oficial, cDescripcion WITH RESUME;
		END IF;
	END EXCEPTION;
	
	SET ISOLATION DIRTY READ ;
	SET LOCK MODE TO WAIT 3;
	
	IF TRIM(NVL(pEmpresa,'')) <> '' AND TRIM(NVL(pCodDivisa,'')) <> '' THEN 
		
			SELECT sigla, cve_intl, cve_oficial, descripcion
			INTO cSigla, cCve_intl, cCve_oficial, cDescripcion 
			FROM bdinteg:"informix".si_divisas
			WHERE divisa = pCodDivisa 
			AND	empresa = pEmpresa;
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00002';
			END IF;			
			
	ELSE
		LET cCodRet = '00001';
	END IF;
	
	RETURN cCodRet, cSigla, cCve_intl, cCve_oficial, cDescripcion WITH RESUME;
	
END;    
END PROCEDURE
DOCUMENT
'REALIZO: 98640909 - LUIS BELTRAN',
'FECHA: 13-11-2019',
'DESCRIPCION:Consulta los registros de la tabla si_divisas de acuerdo a un cÃ³digo en espeÃ­fico.',
'DESCRIPCION: SE MODIFICA CLON DEL sp_consulta_divisas_bym MODIFICANDO EL CODRET A CHAR(5)',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_guardabitacora_operaciones_noine(pEmpresa char(3), pSucursal char(4), pUsuario char(8),pNombreProceso char(25), pSecuencia char(8),pTransaccion_suc char(4), pMonto money(14,2), pNumcte char(20), pIdentificacion1 char(50), pNumero_identificacion1 char(20), pIdentificacion2 char(50),pNumero_identificacion2 char(20))
	RETURNING CHAR(5) AS cCodRet;
    
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE iSamErr INTEGER;
    DEFINE cDesErr CHAR(50);	

    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET iSamErr = 0;
    LET cDesErr = '';   

BEGIN
	
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;
    
     --SET DEBUG FILE TO "/home/sysifx/mario/sp_guardabitacora_operaciones_noine.out";
	 --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	IF NVL(pEmpresa,'') = ''         AND NVL(pSucursal,'') = '' AND NVL(pUsuario,'') = ''         AND NVL(pSecuencia,'') = '' AND
       NVL(pTransaccion_suc,'') = '' AND NVL(pMonto,'')         AND NVL(pNumcte,'') = ''          AND NVL(pIdentificacion1,'') = '' AND 
	   NVL(pNumero_identificacion1,'') = ''                     AND NVL(pIdentificacion2,'') = '' AND NVL(pNumero_identificacion2,'') = '' AND
	   NVL(pNombreProceso,'') = ''
	THEN	   
        LET cCodRet = '00001';
	ELSE
		INSERT INTO bdinteg:"informix".si_bitacora_operaciones_no_ine (empresa,sucursal,usuario,nombreproceso,secuencia,transaccion_suc,monto,numcte,identificacion1,numero_identificacion1,identificacion2,numero_identificacion2,fecha,hora_insert) 
		VALUES (pEmpresa, pSucursal, pUsuario,pNombreProceso, pSecuencia, pTransaccion_suc, pMonto, pNumcte, pIdentificacion1, pNumero_identificacion1, pIdentificacion2, pNumero_identificacion2, CURRENT, CURRENT);	
    END IF;  
       
    RETURN cCodRet;
	
END;    
END PROCEDURE
DOCUMENT
'Autor: 95142134 Mario Gallardo',
'Folio: ',
'Fecha: ',
'ModificaciÃ³n: ',
'Sustento: ',
'Solicita: ',
'Base de datos: bdinteg';

CREATE PROCEDURE "informix".sp_sucursal_atm(pempresa      CHAR(3),
                                           psucursal     CHAR(4))


       returning CHAR(3),CHAR(40);


define vcodret char(5);
define vsqlerr integer;

define vplaza char(3);
define vnombre char(40);

let vcodret = "000";
let  vsqlerr = 0;

let vplaza = "";
let vnombre ="";

--SET debug file to "/pisa/pisabanco/pisa_ftes/sucursal/spl/sp_monitor.out";
--trace on;

begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         return vplaza,vnombre;

      end if;
   end exception;

   if psucursal != '' and pempresa != '' then
			SELECT plaza_cajagen, nombre INTO vplaza,vnombre FROM si_sucursales WHERE empresa = pempresa AND sucursal = psucursal;
   end if;

   return vplaza,vnombre;
end
end procedure
DOCUMENT
'MODIFICÓ:    	Jesus Moreno',
'FECHA:       	28/10/2019',
'DESCRIPCIÓN: 	Se valida que exista la sucursal atm en la tabla si_sucursales',
'BASE DE DATOS: bdinteg',
'FOLIO:628',
'Llamado desde:Generepo.exe';

CREATE PROCEDURE "informix".sp_extrae_info_transacc()

		RETURNING CHAR(40), CHAR(80);
	--DeclaraciÃ³n de Variables
        DEFINE v_codret         	CHAR(40);
        DEFINE v_ruta_unl       	CHAR(50);
        DEFINE v_id_tabla       	CHAR(60);
        DEFINE v_msj_ret        	CHAR(80);
        DEFINE v_sql            	CHAR(1100);
        DEFINE v_fec_hoy        	DATE;
        DEFINE sql_err          	INTEGER;
		DEFINE isam_err          	INTEGER;
        DEFINE error_info       	CHAR(80);
		DEFINE v_fec_ant        	DATE;
		DEFINE v_fecha_upd_com  	DATE;
		DEFINE v_dia               	CHAR(2);
		DEFINE v_mes                CHAR(2);
		DEFINE v_anio 				CHAR(4);
		DEFINE v_fecha 				CHAR(10);
		DEFINE v_dia2               CHAR(2);
		DEFINE v_mes2               CHAR(2);
		DEFINE v_anio2 				CHAR(4);
		DEFINE vCliente    			CHAR(20);
		DEFINE vFolio				CHAR(16);
		DEFINE vFecha               DATE;
		DEFINE vCuenta              CHAR(20);
		DEFINE vMonto               CHAR(17);
		DEFINE vHora                CHAR(12);
		DEFINE vUsuario				CHAR(8);
		DEFINE vTransacc			CHAR(4);
		DEFINE vSaldo               CHAR(17);
		DEFINE vSucursal			CHAR(4);
		DEFINE vBanco				CHAR(20);
		DEFINE vCuentachq		    CHAR(20);
		DEFINE vNumchq              CHAR(11);
		DEFINE vTransacc_suc		CHAR(4);
		DEFINE vNumtarjeta			CHAR(20);
		--DEFINE iLinea				INTEGER;
		DEFINE vFolio_s				CHAR(10);
		DEFINE vReferencia 			CHAR(40);
		DEFINE vPri_nom_ben			CHAR(30);
		DEFINE vSeg_nom_ben			CHAR(30);
		DEFINE vApell_pat_ben		CHAR(30);
		DEFINE vApell_mat_ben		CHAR(30);
		DEFINE vFirstName			CHAR(30);
		DEFINE vMiddleName			CHAR(30);
		DEFINE vLastName 			CHAR(30);
		DEFINE vMotherName			CHAR(30);  
		DEFINE vFechaMax            DATE;
		DEFINE vPri_nom_ben_alt		CHAR(30);
		DEFINE vSeg_nom_ben_alt		CHAR(30);
		DEFINE vApell_pat_ben_alt	CHAR(30);
		DEFINE vApell_mat_ben_alt	CHAR(30);
		DEFINE vBeneficiario		CHAR(104);
		DEFINE vBeneficiario2		CHAR(104);
		DEFINE vIdentificacion 		CHAR(2);
		DEFINE vIdentificacion2		CHAR(2);
		DEFINE vNumId				CHAR(25);
		DEFINE vNumId2				CHAR(25);
		DEFINE vFormapago			CHAR(15);
		DEFINE vNumOrden			CHAR(20);
		DEFINE vClaveConf			CHAR(20);
		DEFINE vFechamin            DATE;
		DEFINE pFechaIni			DATE;
		DEFINE pFechaFin			DATE;
		DEFINE v_fecha_upd_eje		DATE;
		DEFINE iMesActual           INTEGER;
		DEFINE iMes					INTEGER;
		DEFINE iAnio				INTEGER;
		DEFINE vReversado			CHAR(1);
		DEFINE dFecha_borrado       DATE;
		DEFINE iMes_borrado         INTEGER;
		DEFINE vSaltaTransaccion	INTEGER;
		DEFINE vProcesosEjecutados	INTEGER;
		DEFINE vBorraInfo			INTEGER;
		DEFINE vProceso				CHAR(8);
		DEFINE iContador			INTEGER;

	--Inicializacion de Variables
	LET iContador 				= 0;
	LET v_codret   				= '';
	LET v_ruta_unl 	    		= '';
	LET v_id_tabla 				= '';
	LET v_msj_ret 				= '';
	LET v_sql 					= '';
	LET v_dia 					= '';
	LET v_mes 					= '';
	LET v_anio 					= '';
	LET v_fecha 				= '';
	LET v_dia2  				= '';
	LET v_mes2      			= '';
	LET v_anio2 				= '';
	LET vCliente    	        = '';
	LET vFolio					= '';
	LET vFecha       			= DATE(1);
	LET vCuenta      			= '';
	LET vMonto       			= '';
	LET vHora                   = '';
	LET vUsuario				= '';
	LET vTransacc				= '';
	LET vSaldo       			= '';
	LET vSucursal				= '';
	LET vBanco					= '';
	LET vCuentachq				= '';
	LET vNumchq      			= '';
	LET vTransacc_suc           = '';
	LET vNumtarjeta				= '';
	--LET iLinea                  = 0;
	LET vFolio_s                = '';
	LET vReferencia 			= '';
	LET vPri_nom_ben		    = '';
	LET vSeg_nom_ben		    = '';
	LET vApell_pat_ben		    = '';
	LET vApell_mat_ben		    = '';
	LET vPri_nom_ben_alt	    = '';
	LET vSeg_nom_ben_alt	    = '';
	LET vApell_pat_ben_alt	    = '';
	LET vApell_mat_ben_alt	    = '';
	LET vFirstName			 	= '';
	LET vMiddleName				= '';
	LET vLastName 				 = '';
	LET vMotherName				 = '';
	LET vFechaMax              	=DATE(1);
	LET vBeneficiario		   	= '';
	LET vBeneficiario2			= '';
	LET vIdentificacion			= '';
	LET vIdentificacion2		= '';
	LET vNumId					= '';
	LET vNumId2					= '';
	LET vFormapago				= '';
	LET vNumOrden 				= '';
	LET vClaveConf              = '';
	LET vFechamin            	= DATE(1);
	LET pFechaIni			    = DATE(1);
	LET pFechaFin			    = DATE(1);
	LET v_fecha_upd_eje			= DATE(1);
	LET iMesActual				= 0;
	LET	iMes					= 0;
	LET iAnio 					= 0;
	LET vReversado				= '';
	LET dFecha_borrado          = DATE(1);
    LET iMes_borrado            = 0;
	LET vSaltaTransaccion		= Null;
	LET vProcesosEjecutados		= 0;
	LET vBorraInfo				= Null;
	LET vProceso				= '';
/*----------------*----------------*----------------*----------------*----------------*------------*
/ Se crea procedimiento almacenado para extraer la informaciÃ³n requerida para la generaciÃ³n        /
/ de los reportes de auditoria desde la aplicaciÃ³n "Consulta de Transacciones"                     /
/ Elaborado por: Adilene Lara                                                                      /
/ Fecha: 20/11/2014                                                                                /
/ Modificado: Victor Mendoza 23/12/14                                                              /
/ Modificado: Victor Mendoza 09/10/15 Se agrega indice en borrado de la tabla si_rptcaja_aud       /
/ Modificado: Victor Mendoza 17/01/15 Se agregan condiciones para identificar si ya se ejecutÃ³     /
/		previamente un proceso y saltarlo, de igual manera se valida si existe informaciÃ³n en 	   /
/		las tablas y se elimina en caso de ser necesario; se optimiza la bÃºsqueda de Cheques SBC   /
/ Solicitado por: Norberto Corona                                                                  /
*----------------*----------------*----------------*----------------*----------------*------------*/

BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info

		IF sql_err <> 0 THEN
			LET v_codret = 'sql_err: ' || sql_err;
		    LET v_msj_ret = 'Error No Controlado, ' || nvl(vProcesosEjecutados,'') || ' Procesos Ejecutados; Proceso: ' || vProceso;
			RETURN v_codret, v_msj_ret;
		END IF;
	END EXCEPTION;

	 ON EXCEPTION IN (-535)
			  --ROLLBACK WORK;
			  LET v_codret = 'sql_err: ' || sql_err;
			  LET v_msj_ret = 'Error No Controlado, ' || nvl(vProcesosEjecutados,'') || ' Procesos Ejecutados; Proceso: ' || vProceso;
			  COMMIT WORK;
			  RETURN v_codret, v_msj_ret;
     END EXCEPTION;
	
   --SET DEBUG FILE TO '/ifxsif01/PLL/RQI_315/sp_extrae_info_transacc_0023.out';
   --TRACE ON;
	--SET DEBUG FILE TO "/informix/VJMP/extraeinfo/extrae_info_new.out"; --> TRACE DESDE APP217
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;						 

	SELECT fecha_hoy INTO v_fec_hoy FROM bdinteg:"informix".si_fechas;
	SELECT MONTH (fecha_hoy), YEAR (fecha_hoy) INTO iMesActual, iAnio FROM bdinteg:"informix".si_fechas; --Obtener mes y aÃ±o actual

	LET pFechaFin = DATE(iMesActual || '/01/' || iAnio) - DAY (1); --Asignamos Fecha final para periodo de consulta

	IF (iMesActual = 1) THEN --Si mes Actual es enero el mes a consultar debera ser Diciembre del aÃ±o anterior
		LET iMes = 12;
		LET iAnio = iAnio - 1;
	ELSE
		LET iMes = iMesActual - 1;
	END IF;

	IF iMes < 10 THEN
		LET pFechaIni = DATE('0' || iMes || '/01/' || iAnio);
	ELSE
		LET pFechaIni = DATE(iMes || '/01/' || iAnio);
	END IF;

	SELECT MAX (fecha_upd)
    INTO v_fecha_upd_eje
    FROM bdinteg:"informix".si_param_extr
    WHERE ruta_unl = 'info_transacciones';

	
   --INSERT INTO bdinteg:"informix".tiempo  
   --SELECT DBINFO("utc_to_datetime", sh_curtime) AS TIEMPO, 'Inicio' AS NOMBRE from sysmaster:sysshmvals;
	

-- // ----> Descarga de informaciÃ³n para consulta de transacciones - INICIO <----
 -- AsignaciÃ³n de Inicio de proceso, sin Finalizar
    LET v_codret = '00001';
    LET v_msj_ret = 'Inicio de proceso, sin Finalizar';

    --INSERT INTO bdinteg:"informix".tiempo  
	--SELECT DBINFO("utc_to_datetime", sh_curtime) AS TIEMPO, 'Consulta 1' AS NOMBRE from sysmaster:sysshmvals;
	
	-------> Descarga de informaciÃ³n de Cheques Devueltos <-------

	LET vProceso = 'CHQ_DEV';
	SELECT 1
		INTO vSaltaTransaccion
	FROM bdinteg:"informix".si_param_extr
	WHERE fecha_ant = pFechaFin
		and ruta_unl = 'info_transacciones'
		and id_tabla = 'cheques_devueltos';

	IF vSaltaTransaccion is NULL THEN

		--Identifica si es necesario Eliminar la informaciÃ³n de la tabla previo a su ejecuciÃ³n
		LET vBorraInfo = NULL;

		--SELECT FIRST 1 1
		--	INTO vBorraInfo
		--FROM bdinteg:"informix".si_rptcaja_aud
		--WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0001') --Cheques Devueltos
		--	AND fecha BETWEEN pFechaIni AND pFechaFin;
			
		SELECT FIRST 1 1	
        INTO vBorraInfo		
		FROM bdinteg:"informix".si_rptcaja_aud a
        INNER JOIN bdinteg:"informix".si_transacciones_auditar_det d on (a.cod_transacc = d.transaccion AND d.codigo ='0001') --Cheques Devueltos
     	WHERE A.fecha BETWEEN pFechaIni AND pFechaFin;
       

		IF vBorraInfo IS NOT NULL THEN
		
			DELETE {+INDEX (bdinteg:"informix".informix.idx3_si_rptcaja_aud)} FROM bdinteg:"informix".si_rptcaja_aud
			WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0001') --Cheques Devueltos
			AND fecha BETWEEN pFechaIni AND pFechaFin;
		         	
		
		END IF;
		
		--Se elimina la Tabla Temporal en caso de que Exista
		DROP TABLE IF EXISTS temp_cheques_devueltos;
		--DROP TABLE IF EXISTS temp_reversos_deb_final;

		-- Se crea Tabla Temporal
		CREATE TEMP TABLE temp_cheques_devueltos
			(folio_suc		CHAR(16),
			fech_alt		DATE,
			cuenta			CHAR(20),
			monto_tot		MONEY,
			fech_hor		DATETIME HOUR TO FRACTION(3),
			usuario			CHAR(8),
			transacc		CHAR(4),
			sdo_cuenta		MONEY,
			sucursal		CHAR(4),
			num_cheq		INTEGER,
			transacc_suc	CHAR(4),
			cancelad		CHAR(1)) with no log;
		
		
			INSERT INTO temp_cheques_devueltos
			SELECT a.folio_suc, a.fech_alt, a.cuenta,a.monto_tot,a.fech_hor, a.usuario, a.transacc, a.sdo_cuenta, a.sucursal, a.num_cheq, a.transacc_suc,a.cancelad
			FROM bdicheq:"informix".sc_movhis a
			WHERE a.fech_alt BETWEEN pFechaIni AND pFechaFin
			AND a.transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0001') --Cheques Devueltos
			AND a.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S')
			AND a.empresa = '001'
			AND a.cancelad <> 'S';
			
			INSERT INTO temp_cheques_devueltos
			SELECT a.folio_suc, a.fech_alt, a.cuenta,a.monto_tot,a.fech_hor, a.usuario, a.transacc, a.sdo_cuenta, a.sucursal, a.num_cheq, a.transacc_suc,a.cancelad
			FROM bdicheq:"informix".sc_movhis_old a
			WHERE a.fech_alt BETWEEN pFechaIni AND pFechaFin
			AND a.transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0001') --Cheques Devueltos
			AND a.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S')
			AND a.empresa = '001'
			AND a.cancelad <> 'S';
		
		LET iContador = 0;
		BEGIN WORK;
		FOREACH WITH HOLD
			SELECT Distinct b.num_cte,a.folio_suc, a.fech_alt, a.cuenta,  a.monto_tot,a.fech_hor, a.usuario, a.transacc, a.sdo_cuenta, a.sucursal, d.cvebanco, d.numcuenta, a.num_cheq, a.transacc_suc, c.num_tarjeta, a.cancelad
			INTO vCliente, vFolio, vFecha, vCuenta, vMonto, vHora, vUsuario, vTransacc, vSaldo, vSucursal, vBanco, vCuentachq, vNumchq,  vTransacc_suc, vNumtarjeta, vReversado
			FROM temp_cheques_devueltos a,bdicheq:"informix".sc_maechq b, OUTER bdicheq:"informix".sc_tarjeta c,
			bditef:"informix".cce_cheques_dev d
				WHERE  d.numcte = b.num_cte
				AND d.numcte = c.numcte
				AND b.cuenta = a.cuenta
				AND c.cuenta = a.cuenta
				AND c.status_tar = 'A'
				AND c.expiracion > today
				AND d.numcheque = a.num_cheq
				AND d.fecha_alta = a.fech_alt
			
				INSERT INTO bdinteg:"informix".si_rptcaja_aud (empresa, cod_transacc, fecha_insert, cliente, folio, fecha, cuenta, monto, hora, usuario, transaccion, saldo, sucursal, banco, cuenta_banco, cheque, transacc_suc, tarjeta, reversado)
				VALUES ('001',vTransacc, today, vCliente, vFolio, vFecha, vCuenta, vMonto, vHora, vUsuario, vTransacc, vSaldo, vSucursal, vBanco, vCuentachq, vNumchq, vTransacc_suc, vNumtarjeta, vReversado);
				
				LET iContador = iContador + 1;
				IF iContador = 1000 THEN
				COMMIT WORK;
				LET iContador = 0;
				BEGIN WORK;
				END IF; 
		
		END FOREACH;
		COMMIT WORK;
		DROP TABLE IF EXISTS temp_cheques_devueltos;

		INSERT INTO bdinteg:"informix".si_param_extr (empresa, fecha_ant, ruta_unl, id_tabla, usuario_upd, fecha_upd)
		VALUES('001', pFechaFin, 'info_transacciones', 'cheques_devueltos', user, today);

		LET v_codret    = '00000';
		LET v_msj_ret   = 'Proceso Finalizado Correctamente';
		LET vProcesosEjecutados = vProcesosEjecutados + 1;
	ELSE
		LET vSaltaTransaccion = NULL;
	END IF;

	--INSERT INTO bdinteg:"informix".tiempo  
   --SELECT DBINFO("utc_to_datetime", sh_curtime) AS TIEMPO, 'Consulta 2' AS NOMBRE from sysmaster:sysshmvals;
   
	
	-------> Descarga de informaciÃ³n de Cheques propios <-------
	LET vProceso = 'CHQ_PRO';
	LET v_codret = '00001';
    LET v_msj_ret = 'Inicio de proceso, sin Finalizar';

	SELECT 1
		INTO vSaltaTransaccion
	FROM bdinteg:"informix".si_param_extr
	WHERE fecha_ant = pFechaFin
		and ruta_unl = 'info_transacciones'
		and id_tabla = 'cheques_propios';

	IF vSaltaTransaccion is NULL THEN
		--LET iLinea = 0;

		--Identifica si es necesario Eliminar la informaciÃ³n de la tabla previo a su ejecuciÃ³n
		LET vBorraInfo = NULL;
		
		
		SELECT FIRST 1 1
			INTO vBorraInfo
		FROM bdinteg:"informix".si_rptcaja_aud
		WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0002') --Cheques propios
			AND fecha BETWEEN pFechaIni AND pFechaFin;

		IF vBorraInfo IS NOT NULL THEN
			DELETE FROM bdinteg:"informix".si_rptcaja_aud
			WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0002') --Cheques propios
				AND fecha BETWEEN pFechaIni AND pFechaFin;
		END IF;
		
		
		--Se elimina la Tabla Temporal en caso de que Exista
		DROP TABLE IF EXISTS temp_cheques_propios;
		--DROP TABLE IF EXISTS temp_reversos_deb_final;

		-- Se crea Tabla Temporal
		CREATE TEMP TABLE temp_cheques_propios
			(folio_suc		CHAR(16),
			fech_alt		DATE,
			cuenta			CHAR(20),
			monto_tot		MONEY,
			fech_hor		DATETIME HOUR TO FRACTION(3),
			usuario			CHAR(8),
			transacc		CHAR(4),
			sdo_cuenta		MONEY,
			sucursal		CHAR(4),
			num_cheq		INTEGER,
			transacc_suc	CHAR(4),
			cancelad		CHAR(1)) with no log;
	    
		INSERT INTO temp_cheques_propios
		SELECT a.folio_suc, a.fech_alt, a.cuenta, a.monto_tot, a.fech_hor, a.usuario, a.transacc, a.sdo_cuenta, a.sucursal, a.num_cheq, a.transacc_suc, a.cancelad 
		FROM bdicheq:"informix".sc_movhis a
		WHERE a.empresa = '001'
				AND a.transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0002') --Cheques Propios
				AND a.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S')
				AND a.cancelad <> 'S';
				
				
		INSERT INTO temp_cheques_propios
		SELECT a.folio_suc, a.fech_alt, a.cuenta, a.monto_tot, a.fech_hor, a.usuario, a.transacc, a.sdo_cuenta, a.sucursal, a.num_cheq, a.transacc_suc, a.cancelad 
		FROM bdicheq:"informix".sc_movhis_old a
				WHERE a.fech_alt BETWEEN pFechaIni AND pFechaFin
				AND a.empresa = '001'
				AND a.transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0002') --Cheques Propios
				AND a.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S')
				AND a.cancelad <> 'S';
		
		
		BEGIN WORK;
		FOREACH WITH HOLD
			SELECT Distinct b.num_cte, a.folio_suc, a.fech_alt, a.cuenta, a.monto_tot, a.fech_hor, a.usuario, a.transacc, a.sdo_cuenta, a.sucursal, a.num_cheq, a.transacc_suc, c.num_tarjeta, a.cancelad
			INTO vCliente, vFolio, vFecha, vCuenta, vMonto, vHora, vUsuario, vTransacc, vSaldo, vSucursal, vNumchq,  vTransacc_suc, vNumtarjeta, vReversado
			FROM temp_cheques_propios a
			Inner Join bdicheq:"informix".sc_maechq b on a.cuenta = b.cuenta
			Left Outer Join bdicheq:"informix".sc_tarjeta c on a.cuenta = c.cuenta AND b.num_cte = c.numcte AND c.cuenta = b.cuenta AND c.status_tar = 'A' and c.expiracion > today
				WHERE a.fech_alt BETWEEN pFechaIni AND pFechaFin

				INSERT INTO bdinteg:"informix".si_rptcaja_aud (empresa, cod_transacc, fecha_insert, cliente, folio, fecha, cuenta, monto, hora, usuario, transaccion, saldo, sucursal,  cheque, transacc_suc, tarjeta, reversado)
				VALUES ('001',vTransacc, today, vCliente, vFolio, vFecha, vCuenta, vMonto, vHora, vUsuario, vTransacc, vSaldo, vSucursal,  vNumchq, vTransacc_suc, vNumtarjeta, vReversado);
			
				LET iContador = iContador + 1;
				IF iContador = 1000 THEN
				COMMIT WORK;
				LET iContador = 0;
				BEGIN WORK;
				END IF; 
			
			
		END FOREACH;
		COMMIT WORK;
		DROP TABLE IF EXISTS temp_cheques_propios;
		
		INSERT INTO bdinteg:"informix".si_param_extr (empresa, fecha_ant, ruta_unl, id_tabla, usuario_upd, fecha_upd)
		VALUES('001', pFechaFin, 'info_transacciones', 'cheques_propios', user, today);

		LET v_codret    = '00000';
		LET v_msj_ret   = 'Proceso Finalizado Correctamente';
		LET vProcesosEjecutados = vProcesosEjecutados + 1;
	ELSE
		LET vSaltaTransaccion = NULL;
	END IF;
    
	
	--INSERT INTO bdinteg:"informix".tiempo  
	--SELECT DBINFO("utc_to_datetime", sh_curtime) AS TIEMPO, 'Consulta 3' AS NOMBRE FROM  sysmaster:sysshmvals;
		
	-------> Descarga de informaciÃ³n de ConcentraciÃ³n de Efectivo <-------
	LET vProceso = 'CON_EFE';
	LET v_codret = '00001';
    LET v_msj_ret = 'Inicio de proceso, sin Finalizar';

	SELECT 1
		INTO vSaltaTransaccion
	FROM bdinteg:"informix".si_param_extr
	WHERE fecha_ant = pFechaFin
		and ruta_unl = 'info_transacciones'
		and id_tabla = 'concentracion_efe';

	IF vSaltaTransaccion is NULL THEN
		
		--Identifica si es necesario Eliminar la informaciÃ³n de la tabla previo a su ejecuciÃ³n
		LET vBorraInfo = NULL;

		SELECT FIRST 1 1
			INTO vBorraInfo
		FROM bdinteg:"informix".si_rptcaja_aud
		WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0004') --ConcentraciÃÂ³n de Efectivo
			AND fecha BETWEEN pFechaIni AND pFechaFin;

		IF vBorraInfo IS NOT NULL THEN
			DELETE FROM bdinteg:"informix".si_rptcaja_aud
			WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0004') --ConcentraciÃÂ³n de Efectivo
				AND fecha BETWEEN pFechaIni AND pFechaFin;
		END IF;

		BEGIN WORK;
		FOREACH WITH HOLD
			SELECT Distinct a.fecha_operacion,  b.hora_solicitud, a.folio_sucursal, a.usuario, a.sucursal, a.monto, a.cod_trans, b.folio_servicio, a.reversado
			INTO vFecha, vHora, vFolio, vUsuario, vSucursal, vMonto, vTransacc, vFolio_s, vReversado
			FROM bdisuc:"informix".ss_operaciones a
			Inner Join bdisuc:"informix".ss_mae_entradasalida b On a.folio_oper = b.folio_oper
			WHERE a.fecha_operacion BETWEEN pFechaIni AND pFechaFin
			AND a.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S')
			AND a.cod_trans  IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0004') --ConcentraciÃÂ³n de Efectivo
			AND a.reversado = '0'

			INSERT INTO bdinteg:"informix".si_rptcaja_aud (empresa, cod_transacc, fecha_insert, fecha, hora, folio, usuario, sucursal, monto, transaccion, folio_oper, reversado)
			VALUES ('001',vTransacc, today, vFecha, vHora, vFolio, vUsuario, vSucursal, vMonto, vTransacc, vFolio_s, vReversado);
				
			LET iContador = iContador + 1;
			IF iContador = 1000 THEN
			COMMIT WORK;
			LET iContador = 0;
			BEGIN WORK;
			END IF; 	
			
		END FOREACH;
		COMMIT WORK;

			INSERT INTO bdinteg:"informix".si_param_extr (empresa, fecha_ant, ruta_unl, id_tabla, usuario_upd, fecha_upd)
			VALUES('001', pFechaFin, 'info_transacciones', 'concentracion_efe', user, today);

		LET v_codret    = '00000';
		LET v_msj_ret   = 'Proceso Finalizado Correctamente';
		LET vProcesosEjecutados = vProcesosEjecutados + 1;
	ELSE
		LET vSaltaTransaccion = NULL;
	END IF;
	
--INSERT INTO bdinteg:"informix".tiempo  
	    --SELECT DBINFO("utc_to_datetime", sh_curtime) AS TIEMPO, 'Consulta 4' AS NOMBRE from sysmaster:sysshmvals;
		
	-------> Descarga de informaciÃ³n de DotaciÃ³n de Efectivo <-------
	LET vProceso = 'DOT_EFE';
	LET v_codret = '00001';
    LET v_msj_ret = 'Inicio de proceso, sin Finalizar';

	SELECT 1
		INTO vSaltaTransaccion
	FROM bdinteg:"informix".si_param_extr
	WHERE fecha_ant = pFechaFin
		and ruta_unl = 'info_transacciones'
		and id_tabla = 'dotacion_efe';

	IF vSaltaTransaccion is NULL THEN
		--LET iLinea = 0;

		--Identifica si es necesario Eliminar la informaciÃ³n de la tabla previo a su ejecuciÃ³n
		LET vBorraInfo = NULL;

		SELECT FIRST 1 1
			INTO vBorraInfo
		FROM bdinteg:"informix".si_rptcaja_aud
		WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0005') --DotaciÃ³n de Efectivo
			AND fecha BETWEEN pFechaIni AND pFechaFin;

		IF vBorraInfo IS NOT NULL THEN
			DELETE FROM bdinteg:"informix".si_rptcaja_aud
			WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0005') --DotaciÃ³n de Efectivo
				AND fecha BETWEEN pFechaIni AND pFechaFin;
		END IF;

		BEGIN WORK;
		FOREACH WITH HOLD
			SELECT Distinct a.fecha_operacion,  b.hora_solicitud, a.folio_sucursal, a.usuario, a.sucursal, a.monto, a.cod_trans, b.folio_servicio, a.reversado
			INTO vFecha, vHora, vFolio, vUsuario, vSucursal, vMonto, vTransacc, vFolio_s, vReversado
			FROM bdisuc:"informix".ss_operaciones a
			Inner Join  bdisuc:"informix".ss_mae_entradasalida b on a.folio_oper = b.folio_oper
			WHERE a.fecha_operacion BETWEEN pFechaIni AND pFechaFin
			AND a.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S')
			AND a.cod_trans IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0005') --DotaciÃ³n de Efectivo
			AND a.reversado = '0'

		
			INSERT INTO bdinteg:"informix".si_rptcaja_aud (empresa, cod_transacc, fecha_insert, fecha, hora, folio, usuario, sucursal, monto, transaccion, folio_oper, reversado)
			VALUES ('001',vTransacc, today, vFecha, vHora, vFolio, vUsuario, vSucursal, vMonto, vTransacc, vFolio_s, vReversado);
				
			LET iContador = iContador + 1;
			IF iContador = 1000 THEN
			COMMIT WORK;
			LET iContador = 0;
			BEGIN WORK;
			END IF; 
			
		END FOREACH;
		COMMIT WORK;

		INSERT INTO bdinteg:"informix".si_param_extr (empresa, fecha_ant, ruta_unl, id_tabla, usuario_upd, fecha_upd)
		VALUES('001', pFechaFin, 'info_transacciones', 'dotacion_efe', user, today);

		LET v_codret    = '00000';
		LET v_msj_ret   = 'Proceso Finalizado Correctamente';
		LET vProcesosEjecutados = vProcesosEjecutados + 1;
	ELSE
		LET vSaltaTransaccion = NULL;
	END IF;

	
	
	--INSERT INTO bdinteg:"informix".tiempo  
	--SELECT DBINFO("utc_to_datetime", sh_curtime) AS TIEMPO, 'Consulta 5' AS NOMBRE from sysmaster:sysshmvals;
	-------> Descarga de informaciÃ³n de Orden de pago <-------
	LET vProceso = 'O_PAGO';
	LET v_codret = '00001';
    LET v_msj_ret = 'Inicio de proceso, sin Finalizar';

	SELECT 1
		INTO vSaltaTransaccion
	FROM bdinteg:"informix".si_param_extr
	WHERE fecha_ant = pFechaFin
		and ruta_unl = 'info_transacciones'
		and id_tabla = 'orden_pago';

	IF vSaltaTransaccion is NULL THEN
		--LET iLinea = 0;

		--Identifica si es necesario Eliminar la informaciÃ³n de la tabla previo a su ejecuciÃ³n
		LET vBorraInfo = NULL;

		SELECT FIRST 1 1
			INTO vBorraInfo
		FROM bdinteg:"informix".si_rptcaja_aud
		WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0007') 
		AND fecha BETWEEN pFechaIni AND pFechaFin;

		IF vBorraInfo IS NOT NULL THEN
			DELETE {+INDEX (bdinteg:"informix".informix.idx2_si_rptcaja_aud)}  FROM bdinteg:"informix".si_rptcaja_aud WHERE fecha BETWEEN pFechaIni AND pFechaFin 		AND cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0007');
		END IF;

		
		-- Se Elimna Tabla Temporal
		DROP TABLE IF EXISTS tabtemp_orden_pago;
		
			-- Se crea Tabla Temporal
		CREATE TEMP TABLE tabtemp_orden_pago
		(fech_alt		DATE,
		 fech_hor		DATETIME HOUR TO FRACTION(3),
		 folio_suc		CHAR(16),
		 usuario		CHAR(8),
		 sucursal		CHAR(4),
		 monto_tot		MONEY,
		 transacc		CHAR(4),
		 transacc_suc	CHAR(4),
		 cancelad		CHAR(1)) with no log;
		
		--Se almacena en la Tabla Temporal todos los movimientos de las transacciones correspondientes
		INSERT INTO tabtemp_orden_pago
			Select {+ INDEX(bdicheq:"informix".sc_movhis idx_movhisnew3)} a.fech_alt, a.fech_hor, a.folio_suc, a.usuario, a.sucursal, a.monto_tot, a.transacc,a.transacc_suc, a.cancelad  FROM bdicheq:"informix".sc_movhis a
			WHERE a.fech_alt BETWEEN pFechaIni AND pFechaFin
				AND a.empresa = '001'
				AND a.transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0007') --Orden de Pago
				AND a.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S')
				AND a.cancelad <> 'S';
				
			INSERT INTO tabtemp_orden_pago
			Select a.fech_alt, a.fech_hor, a.folio_suc, a.usuario, a.sucursal, a.monto_tot, a.transacc,a.transacc_suc, a.cancelad  
			FROM bdicheq:"informix".sc_movhis_old a		
			WHERE a.fech_alt BETWEEN pFechaIni AND pFechaFin
				AND a.empresa = '001'
				AND a.transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0007') --Orden de Pago
				AND a.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S')
				AND a.cancelad <> 'S';
				
		
		BEGIN WORK;
		FOREACH  WITH HOLD
			SELECT Distinct a.fech_alt, a.fech_hor, a.folio_suc, a.usuario, a.sucursal, a.monto_tot, a.transacc, b.referencia1,d.pri_nom_ben,d.seg_nom_ben,d.apell_pat_ben,d.apell_mat_ben,c.pri_nom_ben,c.seg_nom_ben,c.apell_pat_ben,c.apell_mat_ben,d.identificacion,c.identificacion,d.num_ident,c.num_ident,b.forma_pago,b.cuenta_cargo,a.transacc_suc, a.cancelad
			   INTO vFecha, vHora, vFolio, vUsuario, vSucursal, vMonto, vTransacc, vNumOrden, vPri_nom_ben,vSeg_nom_ben,vApell_pat_ben,vApell_mat_ben,vPri_nom_ben_alt,vSeg_nom_ben_alt,vApell_pat_ben_alt,vApell_mat_ben_alt, vIdentificacion, vIdentificacion2, vNumId, vNumId2,vFormapago, vCuenta, vTransacc_suc, vReversado
				FROM bdinteg:"informix".tabtemp_orden_pago a
				Inner Join bdisac: "informix". sac_movimientoshistorial b on b.folio_suc = a.folio_suc AND a.fech_alt = b.fecha_pago AND b.id_sucursal = a.sucursal
				Left outer Join bdisac: "informix".sac_enviosdineroya c on b.referencia1 = c.no_control
				Left outer Join bdisac: "informix".sac_enviosdineroyahis d on b.referencia1 = d.no_control
				
			
				-- Formateo de datos --
				 LET vBeneficiario = '';
				 
				
				 IF (vPri_nom_ben) IS NOT NULL THEN 
				 LET vBeneficiario = Trim(vPri_nom_ben) ||' '||NVL(Trim(vSeg_nom_ben),'')||' '||Trim(vApell_pat_ben)||' '||NVL(Trim(vApell_mat_ben),'');
				 LET vIdentificacion = TRIM(vIdentificacion);
				 LET vNumId = TRIM(vNumId);
				 ELSE 
				 LET vBeneficiario =  Trim(vPri_nom_ben_alt) ||' '||NVL(Trim(vSeg_nom_ben_alt),'')||' '||Trim(vApell_pat_ben_alt)||' '||NVL(Trim(vApell_mat_ben_alt),'');
				 LET vIdentificacion = TRIM(NVL(vIdentificacion2,''));
				 LET vNumId = TRIM(NVL(vNumId2,''));
		         END IF;
											
				 CASE vFormapago
				   WHEN '1' THEN LET vFormapago  = 'EFECTIVO';
				   WHEN '2' THEN LET vFormapago  = 'CARGO EN CUENTA';
				   WHEN '3' THEN LET vFormapago  = 'PAGO MIXTO';  
				   WHEN '4' THEN LET vFormapago  = 'ABONO EN CUENTA';  
				   WHEN '5' THEN LET vFormapago  = 'CARGO EN TDC';  
				   WHEN NULL THEN LET vFormapago = '';
				   ELSE LET vFormapago = vFormapago;
				 END CASE;
				 
				 LET vNumOrden = TRIM(NVL(vNumOrden,''));
				
				
				INSERT INTO bdinteg:"informix".si_rptcaja_aud (empresa, cod_transacc, fecha_insert, fecha, hora, folio, usuario, sucursal, monto, transaccion, num_orden, beneficiario, identificacion, folio_identif, referencia, cuenta, transacc_suc, reversado)
				VALUES ('001',vTransacc, today, vFecha, vHora, vFolio, vUsuario, vSucursal, vMonto, vTransacc,vNumOrden, vBeneficiario, vIdentificacion, vNumId,vFormapago, vCuenta, vTransacc_suc, vReversado );
				
				LET iContador = iContador + 1;
				IF iContador = 1000 THEN
				COMMIT WORK;
				LET iContador = 0;
				BEGIN WORK;
				END IF; 
			
		END FOREACH;
		COMMIT WORK;
	    DROP TABLE IF EXISTS tabtemp_orden_pago;
		
		INSERT INTO bdinteg:"informix".si_param_extr (empresa, fecha_ant, ruta_unl, id_tabla, usuario_upd, fecha_upd)
		VALUES('001', pFechaFin, 'info_transacciones', 'orden_pago', user, today);

		LET v_codret    = '00000';
		LET v_msj_ret   = 'Proceso Finalizado Correctamente';
		LET vProcesosEjecutados = vProcesosEjecutados + 1;
	ELSE
		LET vSaltaTransaccion = NULL;
	END IF;
	
	

    --INSERT INTO bdinteg:"informix".tiempo  
	--SELECT DBINFO("utc_to_datetime", sh_curtime) AS TIEMPO, 'Consulta 6' AS NOMBRE from sysmaster:sysshmvals;
		


	-------> Descarga de informaciÃ³n de Remesas BTS <-------
	LET vProceso = 'REM_BTS';
	LET v_codret = '00001';
    LET v_msj_ret = 'Inicio de proceso, sin Finalizar';

	SELECT 1
		INTO vSaltaTransaccion
	FROM bdinteg:"informix".si_param_extr
	WHERE fecha_ant = pFechaFin
		and ruta_unl = 'info_transacciones'
		and id_tabla = 'remesas_bts';

	IF vSaltaTransaccion is NULL THEN
		--LET iLinea = 0;

		--Identifica si es necesario Eliminar la informaciÃ³n de la tabla previo a su ejecuciÃ³n
		LET vBorraInfo = NULL;

		SELECT FIRST 1 1
			INTO vBorraInfo
		FROM bdinteg:"informix".si_rptcaja_aud
		WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0008') --Remesas BTS
			AND fecha BETWEEN pFechaIni AND pFechaFin;

		IF vBorraInfo IS NOT NULL THEN
			DELETE {+INDEX (bdinteg:"informix".informix.idx2_si_rptcaja_aud)} FROM bdinteg:"informix".si_rptcaja_aud
			WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0008') --Remesas BTS
				AND fecha BETWEEN pFechaIni AND pFechaFin;
		END IF;
		
		-- Se Elimna Tabla Temporal
		DROP TABLE IF EXISTS tabtem_remesas_bts;
		--DROP TABLE IF EXISTS tabtem_remesas_final;
		
			-- Se crea Tabla Temporal
		CREATE TEMP TABLE tabtem_remesas_bts
		(fech_alt		DATE,
		 fech_hor		DATETIME HOUR TO FRACTION(3),
		 folio_suc		CHAR(16),
		 usuario		CHAR(8),
		 sucursal		CHAR(4),
		 monto_tot		MONEY,
		 transacc		CHAR(4),
		 transacc_suc	CHAR(4),
		 cancelad		CHAR(1)) with no log;
		 
		
		 -- Se crea Tabla Temporal
		CREATE TEMP TABLE tabtem_remesas_bts_final
		(fech_alt		DATE,
		 fech_hor		DATETIME HOUR TO FRACTION(3),
		 folio_suc		CHAR(16),
		 usuario		CHAR(8),
		 sucursal		CHAR(4),
		 monto_tot		MONEY,
		 transacc		CHAR(4),
		 transacc_suc	CHAR(4),
		 cancelad		CHAR(1)) with no log;
		
		--Se almacena en la Tabla Temporal todos los movimientos de las transacciones correspondientes
		INSERT INTO tabtem_remesas_bts
			Select {+ INDEX(bdicheq:"informix".sc_movhis idx_movhisnew3)} a.fech_alt, a.fech_hor, a.folio_suc, a.usuario, a.sucursal, a.monto_tot, a.transacc,a.transacc_suc, a.cancelad 
			FROM bdicheq:"informix".sc_movhis a
			WHERE a.fech_alt BETWEEN pFechaIni AND pFechaFin
				AND  a.empresa = '001'
				AND a.transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0008') --Remesas BTS
				AND a.cancelad <> 'S'
				AND a.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S');
				
			INSERT INTO tabtem_remesas_bts
			Select a.fech_alt, a.fech_hor, a.folio_suc, a.usuario, a.sucursal, a.monto_tot, a.transacc,a.transacc_suc, a.cancelad  
			FROM bdicheq:"informix".sc_movhis_old a
				WHERE a.fech_alt BETWEEN pFechaIni AND pFechaFin
				AND a.empresa = '001'
				AND a.transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0008') --Remesas BTS
				AND a.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S')
				AND a.cancelad <> 'S';
		   
			--INSERT INTO tabtem_remesas_bts_final
			--Select a.fech_alt, a.fech_hor, a.folio_suc, a.usuario, a.sucursal, a.monto_tot, --a.transacc,a.transacc_suc, a.cancelad  --Remesas BTS
			--FROM tabtem_remesas_bts a
			--WHERE a.fech_alt BETWEEN pFechaIni AND pFechaFin;
			
		
	BEGIN WORK;	
	FOREACH WITH HOLD
	
	SELECT Distinct a.fech_alt, a.fech_hor, a.folio_suc, a.usuario,a.sucursal,a.monto_tot,a.transacc,b.referencia1 as Referencia1,
			'' as Beneficiario,b.forma_pago,b.cuenta_cargo, a.transacc_suc, a.cancelad
			    INTO vFecha, vHora, vFolio, vUsuario, vSucursal, vMonto, vTransacc, vClaveConf, vBeneficiario,vFormapago, vCuenta, vTransacc_suc, vReversado
				FROM tabtem_remesas_bts a
				Inner Join bdisac: "informix". sac_movimientoshistorial b on (b.folio_suc = a.folio_suc AND b.id_sucursal = a.sucursal 
				and b.fecha_pago = a.fech_alt)
				WHERE b.status_cancelado ='N'
			
				
				
				CASE vFormapago
				   WHEN '1' THEN LET vFormapago  = 'EFECTIVO';
				   WHEN '2' THEN LET vFormapago  = 'CARGO EN CUENTA';
				   WHEN '3' THEN LET vFormapago  = 'PAGO MIXTO';  
				   WHEN '4' THEN LET vFormapago  = 'ABONO EN CUENTA';  
				   WHEN '5' THEN LET vFormapago  = 'CARGO EN TDC';  
				   WHEN NULL THEN LET vFormapago = '';
				   ELSE LET vFormapago = vFormapago;
				 END CASE;
				
                LET vClaveConf = TRIM(vClaveConf);							
				
				-- Obtener Beneficiaio  query optimizado. 
				SELECT MAX(fecha_insert)
				INTO vFechaMax
				FROM   bdisac: "informix".sac_bts_qryi 
				WHERE  confirmation_nm = vClaveConf
				AND txn_status = 'A';
			
				SELECT  r_first_name ,  r_middle_name , r_last_name ,r_mother_m_name
				INTO    vFirstName,vMiddleName,vLastName,vMotherName
				FROM   	bdisac: "informix".sac_bts_qryi 
				WHERE  	confirmation_nm = vClaveConf
				AND  	fecha_insert = vFechaMax
				AND 	txn_status = 'A';
				
				
				SELECT LIMIT 1 MAX(fecha_insert) ,p.r_identif_type , p.r_identif_nm
				INTO vFechaMax,vIdentificacion, vNumId
				FROM bdisac: "informix".sac_bts_payi p 
				WHERE confirmation_nm = vClaveConf
				AND txn_status = 'A'
				GROUP BY p.r_identif_type , p.r_identif_nm;
				-- Formato del beneficiario -- 
				 LET vBeneficiario = TRIM(NVL(NVL(trim(vFirstName),'') ||' '||NVL(trim(vMiddleName),'')||' '||NVL(trim(vLastName),'')||' '||NVL(trim(vMotherName),''),''));
			
						
				INSERT INTO bdinteg:"informix".si_rptcaja_aud (empresa, cod_transacc, fecha_insert, fecha, hora, folio, usuario, sucursal, monto, transaccion, clave_confir,  beneficiario, identificacion, folio_identif, referencia, cuenta, transacc_suc , reversado)
				VALUES ('001',vTransacc, today, vFecha, vHora, vFolio, vUsuario, vSucursal, vMonto, vTransacc, vClaveConf, vBeneficiario, vIdentificacion, vNumId,vFormapago, vCuenta, vTransacc_suc, vReversado );
				
				LET iContador = iContador + 1;
				IF iContador = 1000 THEN
				COMMIT WORK;
				LET iContador = 0;
				BEGIN WORK;
				END IF; 
		
		END FOREACH;
		COMMIT WORK;
		DROP TABLE IF EXISTS tabtem_remesas_bts;

		INSERT INTO bdinteg:"informix".si_param_extr (empresa, fecha_ant, ruta_unl, id_tabla, usuario_upd, fecha_upd)
		VALUES('001', pFechaFin, 'info_transacciones', 'remesas_bts', user, today);

		LET v_codret    = '00000';
		LET v_msj_ret   = 'Proceso Finalizado Correctamente';
		LET vProcesosEjecutados = vProcesosEjecutados + 1;
	ELSE
		LET vSaltaTransaccion = NULL;
	END IF;
    
		
	--INSERT INTO bdinteg:"informix".tiempo  
    --SELECT DBINFO("utc_to_datetime", sh_curtime) AS TIEMPO, 'Consulta 7' AS NOMBRE from sysmaster:sysshmvals;
	

	-------> Descarga de informaciÃ³n de Reversos CrÃ©dito <-------
	LET vProceso = 'REV_CRE';
	LET v_codret = '00001';
    LET v_msj_ret = 'Inicio de proceso, sin Finalizar';

	SELECT 1
		INTO vSaltaTransaccion
	FROM bdinteg:"informix".si_param_extr
	WHERE fecha_ant = pFechaFin
		and ruta_unl = 'info_transacciones'
		and id_tabla = 'reversos_cre';

	IF vSaltaTransaccion is NULL THEN
		--LET iLinea = 0;

		--Identifica si es necesario Eliminar la informaciÃ³n de la tabla previo a su ejecuciÃ³n
		LET vBorraInfo = NULL;

		SELECT FIRST 1 1
			INTO vBorraInfo
		FROM bdinteg:"informix".si_rptcaja_aud
		WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0012') --Reversos CrÃ©dito
			AND fecha BETWEEN pFechaIni AND pFechaFin;

		IF vBorraInfo IS NOT NULL THEN
			DELETE FROM bdinteg:"informix".si_rptcaja_aud
			WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0012') --Reversos CrÃ©dito
				AND fecha BETWEEN pFechaIni AND pFechaFin;
		END IF;

		BEGIN WORK;	
		FOREACH WITH HOLD
			SELECT Distinct b.numcte, a.folio_suc, a.usuario, a.fecha_mov, a.hora_mov, a.num_credito, a.monto, a.transacc_suc, c.sdo_capital, a.sucursal, a.transacc_suc, a.referencia, a.nro_tarjeta, a.reversado
			INTO vCliente, vFolio, vUsuario, vFecha, vHora, vCuenta, vMonto, vTransacc, vSaldo, vSucursal, vTransacc_suc, vReferencia, vNumTarjeta, vReversado
			FROM bdicred:"informix".sd_movhis a
			Inner Join bdicred:"informix".sd_maecred b On b.num_credito = a.num_credito
			Inner Join bdicred:"informix".sd_maesdos c On c.num_credito = a.num_credito
				WHERE a.fecha_mov BETWEEN pFechaIni AND pFechaFin
				AND a.empresa = '001'
				AND a.transacc_suc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0012')	--Reversos CrÃ©dito
				AND a.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S')
				AND a.reversado = 'S'

		
				INSERT INTO bdinteg:"informix".si_rptcaja_aud (empresa, cod_transacc, fecha_insert, cliente, folio, usuario, fecha, hora, cuenta, monto, transaccion, saldo, sucursal, transacc_suc, referencia, tarjeta, reversado)
				VALUES ('001', vTransacc, today, vcliente, vFolio, vUsuario, vFecha, vHora, vCuenta, vMonto, vTransacc, vSaldo, vSucursal, vTransacc_suc, vReferencia, vNumTarjeta, vReversado);
				
				LET iContador = iContador + 1;
				IF iContador = 1000 THEN
				COMMIT WORK;
				LET iContador = 0;
				BEGIN WORK;
				END IF; 
				
								
		END FOREACH;
		COMMIT WORK;

			INSERT INTO bdinteg:"informix".si_param_extr (empresa, fecha_ant, ruta_unl, id_tabla, usuario_upd, fecha_upd)
			VALUES('001', pFechaFin, 'info_transacciones', 'reversos_cre', user, today);

		LET v_codret    = '00000';
		LET v_msj_ret   = 'Proceso Finalizado Correctamente';
		LET vProcesosEjecutados = vProcesosEjecutados + 1;
	ELSE
		LET vSaltaTransaccion = NULL;
	END IF;

	
	--INSERT INTO bdinteg:"informix".tiempo  
	--SELECT DBINFO("utc_to_datetime", sh_curtime) AS TIEMPO, 'Consulta 8' AS NOMBRE from sysmaster:sysshmvals;
	
	-------> Descarga de informaciÃ³n de Reversos DÃ©bito <-------
	LET vProceso = 'REV_DEB';
	LET v_codret = '00001';
    LET v_msj_ret = 'Inicio de proceso, sin Finalizar';

	SELECT 1
		INTO vSaltaTransaccion
	FROM bdinteg:"informix".si_param_extr
	WHERE fecha_ant = pFechaFin
		and ruta_unl = 'info_transacciones'
		and id_tabla = 'reversos_deb';

	IF vSaltaTransaccion is NULL THEN
		--LET iLinea = 0;

		--Identifica si es necesario Eliminar la informaciÃ³n de la tabla previo a su ejecuciÃ³n
		LET vBorraInfo = NULL;

		SELECT FIRST 1 1
			INTO vBorraInfo
		FROM bdinteg:"informix".si_rptcaja_aud
		WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0009') --Reversos DÃ©bito
			AND fecha BETWEEN pFechaIni AND pFechaFin;

		IF vBorraInfo IS NOT NULL THEN
			DELETE FROM bdinteg:"informix".si_rptcaja_aud
			WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0009') --Reversos DÃ©bito
			AND fecha BETWEEN pFechaIni AND pFechaFin;
		END IF;
		
		--Se elimina la Tabla Temporal en caso de que Exista
		DROP TABLE IF EXISTS temp_reversos_deb;
		--DROP TABLE IF EXISTS temp_reversos_deb_final;

		-- Se crea Tabla Temporal
		CREATE TEMP TABLE temp_reversos_deb
			(folio_suc		CHAR(16),
			usuario		CHAR(8),
			fech_alt		DATE,
			fech_hor		DATETIME HOUR TO FRACTION(3),
			cuenta			CHAR(20),
			monto_tot		MONEY,
			transacc		CHAR(4),
			sdo_cuenta		MONEY,
			sucursal		CHAR(4),
			transacc_suc	CHAR(4),
			referencia 		CHAR(40),
			cancelad		CHAR(1)) with no log;
		
	      INSERT INTO temp_reversos_deb
		    SELECT b.folio_suc, b.usuario, b.fech_alt, b.fech_hor,b.cuenta, b.monto_tot, b.transacc, b.sdo_cuenta, b.sucursal, b.transacc_suc, b.referencia, b.cancelad
	        FROM bdicheq:"informix".sc_movhis b
			WHERE b.fech_alt BETWEEN pFechaIni AND pFechaFin
				AND b.empresa ='001'
				AND b.transacc_suc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0009') --Reversos DÃ©bito
				AND b.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S')
				AND b.cancelad = 'S';
	      
			INSERT INTO temp_reversos_deb
			SELECT b.folio_suc, b.usuario, b.fech_alt, b.fech_hor,b.cuenta, b.monto_tot, b.transacc, b.sdo_cuenta, b.sucursal, b.transacc_suc, b.referencia, b.cancelad
			FROM bdicheq:"informix".sc_movhis_old b
			WHERE b.fech_alt BETWEEN pFechaIni AND pFechaFin
				AND b.empresa ='001'
				AND b.transacc_suc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0009') --Reversos DÃ©bito
				AND b.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S')
				AND b.cancelad = 'S';
	
	
		BEGIN WORK;
		FOREACH  WITH HOLD
			SELECT DISTINCT c.num_cte, b.folio_suc, b.usuario, b.fech_alt, b.fech_hor,b.cuenta, b.monto_tot, b.transacc, b.sdo_cuenta, b.sucursal, b.transacc_suc, b.referencia, d.num_tarjeta, b.cancelad
			INTO vCliente, vFolio, vUsuario, vFecha, vHora, vCuenta, vMonto, vTransacc, vSaldo, vSucursal, vTransacc_suc, vReferencia, vNumTarjeta, vReversado
			FROM temp_reversos_deb b
			Inner Join  bdicheq:"informix".sc_maechq c on c.cuenta = b.cuenta
			Left Outer Join bdicheq:"informix".sc_tarjeta d on b.cuenta = d.cuenta and c.num_cte = d.numcte AND d.status_tar = 'A' and d.expiracion > today
				
			INSERT INTO bdinteg:"informix".si_rptcaja_aud (empresa, folio_oper, fecha_insert, cliente, folio, usuario, fecha, hora, cuenta, monto, transaccion, saldo, sucursal, transacc_suc, referencia, tarjeta, reversado)
			VALUES ('001', vTransacc_suc, today, vcliente, vFolio, vUsuario, vFecha, vHora, vCuenta, vMonto, vTransacc, vSaldo, vSucursal, vTransacc_suc, vReferencia, vNumTarjeta, vReversado);
				
				LET iContador = iContador + 1;
				IF iContador = 1000 THEN
				COMMIT WORK;
				LET iContador = 0;
				BEGIN WORK;
				END IF; 
		
		END FOREACH;
		COMMIT WORK;
		DROP TABLE IF EXISTS temp_reversos_deb;
		
		LET vCliente = TRIM(vCliente);

		INSERT INTO bdinteg:"informix".si_param_extr (empresa, fecha_ant, ruta_unl, id_tabla, usuario_upd, fecha_upd)
		VALUES('001', pFechaFin, 'info_transacciones', 'reversos_deb', user, today);

		LET v_codret    = '00000';
		LET v_msj_ret   = 'Proceso Finalizado Correctamente';
		LET vProcesosEjecutados = vProcesosEjecutados + 1;
	ELSE
		LET vSaltaTransaccion = NULL;
	END IF;
    
	--INSERT INTO bdinteg:"informix".tiempo  
	--SELECT DBINFO("utc_to_datetime", sh_curtime) AS TIEMPO, 'Consulta 9' AS NOMBRE from sysmaster:sysshmvals;
	
	-------> Descarga de informaciÃ³n de Pagos Reversados <-------
	LET vProceso = 'PAG_REV';
	LET v_codret = '00001';
    LET v_msj_ret = 'Inicio de proceso, sin Finalizar';

	SELECT 1
		INTO vSaltaTransaccion
	FROM bdinteg:"informix".si_param_extr
	WHERE fecha_ant = pFechaFin
		and ruta_unl = 'info_transacciones'
		and id_tabla = 'pagos_reversados';

	IF vSaltaTransaccion is NULL THEN
		--LET iLinea = 0;

		--Identifica si es necesario Eliminar la informaciÃ³n de la tabla previo a su ejecuciÃ³n
		LET vBorraInfo = NULL;

		SELECT FIRST 1 1
			INTO vBorraInfo
		FROM bdinteg:"informix".si_rptcaja_aud
		WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0013') --Pagos Reversados
			AND fecha BETWEEN pFechaIni AND pFechaFin;

		IF vBorraInfo IS NOT NULL THEN
			DELETE  FROM bdinteg:"informix".si_rptcaja_aud
			WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0013') --Pagos Reversados
				AND fecha BETWEEN pFechaIni AND pFechaFin;
		END IF;

		
		--Se elimina la Tabla Temporal en caso de que Exista
		DROP TABLE IF EXISTS temp_pagos_reversados;
		--DROP TABLE IF EXISTS temp_reversos_deb_final;

		-- Se crea Tabla Temporal
		CREATE TEMP TABLE temp_pagos_reversados
			(folio_suc		CHAR(16),
			usuario		CHAR(8),
			fech_alt		DATE,
			fech_hor		DATETIME HOUR TO FRACTION(3),
			cuenta			CHAR(20),
			monto_tot		MONEY,
			transacc		CHAR(4),
			sdo_cuenta		MONEY,
			sucursal		CHAR(4),
			transacc_suc	CHAR(4),
			referencia 		CHAR(40),
			num_tarjeta		CHAR(20),
			cancelad		CHAR(1)) with no log;
		
		
			INSERT INTO temp_pagos_reversados
		    SELECT  b.folio_suc, b.usuario, b.fech_alt, b.fech_hor,b.cuenta, b.monto_tot, b.transacc, b.sdo_cuenta, b.sucursal, b.transacc_suc, b.referencia, b.num_tarjeta, b.cancelad
			FROM bdicheq:"informix".sc_movhis b
			WHERE b.fech_alt BETWEEN pFechaIni AND pFechaFin
				AND b.empresa = '001'
				AND b.transacc_suc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0013') --Pagos Reversados
				AND b.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S')
				AND b.cancelad = 'S';
				
			INSERT INTO temp_pagos_reversados
		    SELECT  b.folio_suc, b.usuario, b.fech_alt, b.fech_hor,b.cuenta, b.monto_tot, b.transacc, b.sdo_cuenta, b.sucursal, b.transacc_suc, b.referencia, b.num_tarjeta, b.cancelad
			FROM bdicheq:"informix".sc_movhis_old b
			WHERE b.fech_alt BETWEEN pFechaIni AND pFechaFin
				AND b.empresa = '001'
				AND b.transacc_suc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0013') --Pagos Reversados
				AND b.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S')
				AND b.cancelad = 'S';
			
		BEGIN WORK;
		FOREACH  WITH HOLD
			SELECT Distinct c.num_cte, b.folio_suc, b.usuario, b.fech_alt, b.fech_hor,b.cuenta, b.monto_tot, b.transacc, b.sdo_cuenta, b.sucursal, b.transacc_suc, b.referencia, b.num_tarjeta, b.cancelad
			INTO vCliente, vFolio, vUsuario, vFecha, vHora, vCuenta, vMonto, vTransacc, vSaldo, vSucursal, vTransacc_suc, vReferencia, vNumTarjeta, vReversado
			FROM temp_pagos_reversados b
			Inner Join bdicheq:"informix".sc_maechq c on c.cuenta = b.cuenta
				
			LET vCliente = TRIM(vCliente);
			
				INSERT INTO bdinteg:"informix".si_rptcaja_aud (empresa, cod_transacc, fecha_insert, cliente, folio, usuario, fecha, hora, cuenta, monto, transaccion, saldo, sucursal, transacc_suc, referencia, tarjeta, reversado)
				VALUES ('001', vTransacc_suc, today, vcliente, vFolio, vUsuario, vFecha, vHora, vCuenta, vMonto, vTransacc, vSaldo, vSucursal, vTransacc_suc, vReferencia, vNumTarjeta, vReversado);
				
				LET iContador = iContador + 1;
				IF iContador = 1000 THEN
				COMMIT WORK;
				LET iContador = 0;
				BEGIN WORK;
				END IF; 
			
		END FOREACH;
		COMMIT WORK;
		DROP TABLE IF EXISTS temp_pagos_reversados;

		INSERT INTO bdinteg:"informix".si_param_extr (empresa, fecha_ant, ruta_unl, id_tabla, usuario_upd, fecha_upd)
		VALUES('001', pFechaFin, 'info_transacciones', 'pagos_reversados', user, today);

		LET v_codret    = '00000';
		LET v_msj_ret   = 'Proceso Finalizado Correctamente';
		LET vProcesosEjecutados = vProcesosEjecutados + 1;
	ELSE
		LET vSaltaTransaccion = NULL;
	END IF;
    
	--INSERT INTO bdinteg:"informix".tiempo  
	--SELECT DBINFO("utc_to_datetime", sh_curtime) AS TIEMPO, 'Consulta10' AS NOMBRE from sysmaster:sysshmvals;
	-------> Descarga de informaciÃ³n de movimientos SPEI <-------
	LET vProceso = 'SPEI';
	LET v_codret = '00001';
    LET v_msj_ret = 'Inicio de proceso, sin Finalizar';

	SELECT 1
		INTO vSaltaTransaccion
	FROM bdinteg:"informix".si_param_extr
	WHERE fecha_ant = pFechaFin
		and ruta_unl = 'info_transacciones'
		and id_tabla = 'spei';

	IF vSaltaTransaccion is NULL THEN
		--LET iLinea = 0;

		--Identifica si es necesario Eliminar la informaciÃ³n de la tabla previo a su ejecuciÃ³n
		LET vBorraInfo = NULL;

		SELECT FIRST 1 1
			INTO vBorraInfo
		FROM bdinteg:"informix".si_rptcaja_aud
		WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0011')
			AND fecha BETWEEN pFechaIni AND pFechaFin;

		IF vBorraInfo IS NOT NULL THEN
			DELETE FROM bdinteg:"informix".si_rptcaja_aud
			WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0011') --SPEI
				AND fecha BETWEEN pFechaIni AND pFechaFin;
		END IF;

		
		--Se elimina la Tabla Temporal en caso de que Exista
		DROP TABLE IF EXISTS temp_spei;
		--DROP TABLE IF EXISTS temp_reversos_deb_final;

		-- Se crea Tabla Temporal
		
			CREATE TEMP TABLE temp_spei
			(folio_suc		CHAR(16),
			fech_alt		DATE,
			cuenta			CHAR(20),
			monto_tot		MONEY,
			fech_hor		DATETIME HOUR TO FRACTION(3),
			sucursal		CHAR(4),
			sdo_cuenta		MONEY,
			transacc		CHAR(4),
			referencia 		CHAR(40),
			transacc_suc	CHAR(4),
			usuario			CHAR(8),
			cancelad		CHAR(1)) with no log;
	    
		
		INSERT INTO temp_spei
		SELECT  a.folio_suc, a.fech_alt, a.cuenta, a.monto_tot, a.fech_hor, a.sucursal, a.sdo_cuenta, a.transacc, a.referencia, a.transacc_suc, a.cancelad, a.usuario
		 	FROM bdicheq:"informix".sc_movhis a
				WHERE a.transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0011') --SPEI
				AND a.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S')
				AND a.empresa = '001'
				AND a.cancelad <> 'S';
				
				
		INSERT INTO temp_spei 		
		SELECT  a.folio_suc, a.fech_alt, a.cuenta, a.monto_tot, a.fech_hor, a.sucursal, a.sdo_cuenta, a.transacc, a.referencia, a.transacc_suc, a.cancelad, a.usuario
		FROM bdicheq:"informix".sc_movhis_old a
				WHERE a.fech_alt BETWEEN pFechaIni AND pFechaFin
				AND a.empresa = '001'
				AND a.transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0011') --SPEI
				AND a.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S')
				AND a.cancelad <> 'S';
		
		BEGIN WORK;
		FOREACH  WITH HOLD
			SELECT Distinct b.num_cte, a.folio_suc, a.fech_alt, a.cuenta, a.monto_tot, a.fech_hor, a.sucursal, a.sdo_cuenta, a.transacc, a.referencia, a.transacc_suc, a.cancelad, a.usuario
			INTO vCliente, vFolio, vFecha, vCuenta, vMonto, vHora, vSucursal, vSaldo, vTransacc, vReferencia,  vTransacc_suc, vReversado, vUsuario
			FROM temp_spei a
			Inner join bdicheq:"informix".sc_maechq b on b.cuenta = a.cuenta
								
				LET vCliente = TRIM(vCliente);

				INSERT INTO bdinteg:"informix".si_rptcaja_aud (empresa, cod_transacc, fecha_insert, cliente, folio, fecha, cuenta, monto, hora,  sucursal, saldo, transaccion, transacc_suc, referencia, reversado, usuario)
				VALUES ('001', vTransacc, today, vCliente, vFolio, vFecha, vCuenta, vMonto, vHora, vSucursal, vSaldo, vTransacc, vTransacc_suc, vReferencia, vReversado, vUsuario);
				
				LET iContador = iContador + 1;
				IF iContador = 1000 THEN
				COMMIT WORK;
				LET iContador = 0;
				BEGIN WORK;
				END IF; 
		
		END FOREACH;
		COMMIT WORK;
		DROP TABLE IF EXISTS temp_spei;

		INSERT INTO bdinteg:"informix".si_param_extr (empresa, fecha_ant, ruta_unl, id_tabla, usuario_upd, fecha_upd)
		VALUES('001', pFechaFin, 'info_transacciones', 'spei', user, today);

		LET v_codret    = '00000';
		LET v_msj_ret   = 'Proceso Finalizado Correctamente';
		LET vProcesosEjecutados = vProcesosEjecutados + 1;
	ELSE
		LET vSaltaTransaccion = NULL;
	END IF;

    
	--INSERT INTO bdinteg:"informix".tiempo   
	--SELECT DBINFO("utc_to_datetime", sh_curtime) AS TIEMPO, 'Consulta11' AS NOMBRE from sysmaster:sysshmvals;
	
	-------> Descarga de informaciÃ³n de Cheques SBC <-------
	LET vProceso = 'CHQ_SBC';
	LET v_codret = '00001';
    LET v_msj_ret = 'Inicio de proceso, sin Finalizar';

	SELECT 1
		INTO vSaltaTransaccion
	FROM bdinteg:"informix".si_param_extr
	WHERE fecha_ant = pFechaFin
		and ruta_unl = 'info_transacciones'
		and id_tabla = 'cheques_sbc';

	IF vSaltaTransaccion is NULL THEN
		--LET iLinea = 0;
		LET vBorraInfo = NULL;

		SELECT FIRST 1 1
			INTO vBorraInfo
		FROM bdinteg:"informix".si_rptcaja_aud
		WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0003')--Cheques SBC
			AND fecha BETWEEN pFechaIni AND pFechaFin;

		IF vBorraInfo IS NOT NULL THEN
			DELETE FROM bdinteg:"informix".si_rptcaja_aud
			WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0003')--Cheques SBC
				AND fecha BETWEEN pFechaIni AND pFechaFin;
		END IF;

		--Se elimina la Tabla Temporal en caso de que Exista
		DROP TABLE IF EXISTS tabtemp_cheques_sbc;

		-- Se crea Tabla Temporal
		CREATE TEMP TABLE tabtemp_cheques_sbc
			(num_cte 		CHAR(20),
			folio_suc		CHAR(16),
			fech_alt		DATE,
			cuenta			CHAR(20),
			monto_tot		MONEY,
			fech_hor		DATETIME HOUR TO FRACTION(3),
			usuario			CHAR(8),
			transacc		CHAR(4),
			sdo_cuenta		MONEY,
			sucursal		CHAR(4),
			num_cheq		INTEGER,
			transacc_suc	CHAR(4),
			num_tarjeta		CHAR(20),
			cancelad		CHAR(1)) with no log;

		--Se almacena en la Tabla Temporal todos los movimientos de las transacciones correspondientes

		INSERT INTO tabtemp_cheques_sbc  			
				SELECT b.num_cte, a.folio_suc, a.fech_alt, a.cuenta, a.monto_tot, a.fech_hor, a.usuario, a.transacc, a.sdo_cuenta, a.sucursal,
						a.num_cheq, a.transacc_suc, c.num_tarjeta, a.cancelad
				FROM bdicheq:"informix".sc_movhis a
					Inner Join bdicheq:"informix".sc_maechq b on a.cuenta = b.cuenta
					Left Join bdicheq:"informix".sc_tarjeta c on a.cuenta = c.cuenta and b.num_cte = c.numcte AND c.status_tar = 'A' and c.expiracion > today
				WHERE a.fech_alt BETWEEN pFechaIni AND pFechaFin
					AND a.empresa = '001'
					AND a.transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0003') --Cheques SBC
					AND a.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S')
					AND a.cancelad <> 'S';

		INSERT INTO tabtemp_cheques_sbc  		
				SELECT b.num_cte, a.folio_suc, a.fech_alt, a.cuenta, a.monto_tot, a.fech_hor, a.usuario, a.transacc, a.sdo_cuenta, a.sucursal,
						a.num_cheq, a.transacc_suc, c.num_tarjeta, a.cancelad
				FROM bdicheq:"informix".sc_movhis_old a
					Inner Join bdicheq:"informix".sc_maechq b on a.cuenta = b.cuenta
					Left Join bdicheq:"informix".sc_tarjeta c on a.cuenta = c.cuenta and b.num_cte = c.numcte AND c.status_tar = 'A' and c.expiracion > today
				WHERE a.fech_alt BETWEEN pFechaIni AND pFechaFin
					AND a.empresa = '001'
					AND a.transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0003') --Cheques SBC
					AND a.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S')
					AND a.cancelad <> 'S';

		BEGIN WORK;
		FOREACH WITH HOLD

			SELECT Distinct
				num_cte, folio_suc, fech_alt, cuenta, monto_tot, fech_hor, usuario, transacc, sdo_cuenta, sucursal,
				cc.bco_receptor, cc.num_cuenta, num_cheq, transacc_suc, num_tarjeta, cancelad
			INTO vCliente, vFolio, vFecha, vCuenta, vMonto, vHora, vUsuario, vTransacc, vSaldo, vSucursal,
				vBanco, vCuentachq, vNumchq,  vTransacc_suc, vNumtarjeta, vReversado
			FROM tabtemp_cheques_sbc tt
				INNER JOIN bditef:"informix".cce_detalle cc on cc.cuenta_dep = tt.cuenta AND cc.num_cheque = tt.num_cheq
					AND cc.importe = tt.monto_tot

			LET vNumtarjeta = TRIM(vNumtarjeta);		
					
			
			INSERT INTO bdinteg:"informix".si_rptcaja_aud (empresa, cod_transacc, fecha_insert, cliente, folio, fecha, cuenta, monto, hora, usuario, transaccion, saldo, sucursal, banco, cuenta_banco, cheque, transacc_suc, tarjeta, reversado)
				VALUES ('001',vTransacc, today, vCliente, vFolio, vFecha, vCuenta, vMonto, vHora, vUsuario, vTransacc, vSaldo, vSucursal, vBanco, vCuentachq, vNumchq, vTransacc_suc,vNumtarjeta, vReversado);
			
			LET iContador = iContador + 1;
			IF iContador = 1000 THEN
			COMMIT WORK;
			LET iContador = 0;
			BEGIN WORK;
			END IF; 
			
		END FOREACH;
		COMMIT WORK;
		DROP TABLE IF EXISTS tabtemp_cheques_sbc; 
		 
		INSERT INTO bdinteg:"informix".si_param_extr (empresa, fecha_ant, ruta_unl, id_tabla, usuario_upd, fecha_upd)
		VALUES('001', pFechaFin, 'info_transacciones', 'cheques_sbc', user, today);

		LET v_codret    = '00000';
		LET v_msj_ret   = 'Proceso Finalizado Correctamente';
		LET vProcesosEjecutados = vProcesosEjecutados + 1;
	ELSE
		LET vSaltaTransaccion = NULL;
	END IF;
  
	--INSERT INTO bdinteg:"informix".tiempo   
	--SELECT DBINFO("utc_to_datetime", sh_curtime) AS TIEMPO, 'Elimiar historico' AS NOMBRE from sysmaster:sysshmvals;
	
	--ValidaciÃ³n de Procesos Ejecutados:
	IF vProcesosEjecutados = 11 THEN
		LET v_codret    = '00000';
		LET v_msj_ret   = 'Proceso Finalizado Correctamente';
	ELIF vProcesosEjecutados = 0 THEN
		LET v_codret    = '00002';
		LET v_msj_ret   = 'Descarga de informaciÃ³n previamente ejecutada';
	ELSE
		LET v_codret    = '00003';
		LET v_msj_ret   = 'Proceso Ejecutado Parcialmente: ' || nvl(vProcesosEjecutados,'') || ' procesos ejecutados';
	END IF;
	-------> DepuraciÃ³n de InformaciÃ³n con antigÃ¼edad mayor a 6 meses <-------
		IF iMesActual > 1 and iMesActual < 7 then
			Let iAnio = iAnio - 1;
		End IF;
	IF (iMes > 5 ) THEN
			LET iMes_borrado = iMes - 5;
			LET dFecha_borrado = DATE('0' || iMes_borrado  || '/01/' || iAnio) - DAY (1);
				DELETE {+INDEX (bdinteg:"informix".informix.idx2_si_rptcaja_aud)} FROM bdinteg:"informix".si_rptcaja_aud WHERE fecha <= dFecha_borrado;  --Victor Mendoza 09/10/15
		ELSE
			LET iMes_borrado =  iMes + 12 - 5;
			IF (iMes_borrado < 10 ) THEN
				LET dFecha_borrado = DATE('0' || iMes_borrado || '/01/' || iAnio) - DAY(1);
			ELSE
				LET dFecha_borrado = DATE(iMes_borrado || '/01/' || iAnio) - DAY (1);
			END IF;

			DELETE {+INDEX (bdinteg:"informix".informix.idx2_si_rptcaja_aud)} FROM bdinteg:"informix".si_rptcaja_aud WHERE fecha <= dFecha_borrado;  --Victor Mendoza 09/10/15
		END IF;
      	 
	--INSERT INTO bdinteg:"informix".tiempo   
	--SELECT DBINFO("utc_to_datetime", sh_curtime) AS TIEMPO, 'Elimiar historico' AS NOMBRE from sysmaster:sysshmvals;

		RETURN v_codret, v_msj_ret;
END
END PROCEDURE;