CREATE PROCEDURE "informix".encabezado_edocta_web(pEmpresa CHAR(3), pTarjeta CHAR(20), pFechaEmision char(10))
	RETURNING CHAR(5), DATE, CHAR(20), CHAR(20), CHAR(20),
			  CHAR(150), CHAR(200), CHAR(120), CHAR(120), CHAR(120),
			  CHAR(120), CHAR(150), CHAR(20), DATE, CHAR(5),
			  CHAR(60), CHAR(13), CHAR(47), CHAR(40), CHAR(80);


	--****************************************************--
	-- MODIFICADO: J. Rodolfo Uriarte R.				**--
	--		FECHA: 24 de Diciembre de 2008				**--
	-- MODIFICACION: Se aumento la longitud del regreso	**--
	--				 de la variable v_cl_cobra			**--
	--				 de 51 a 60							**--
	--****************************************************--
	--------------------------------------------------------
	--	VARIABLES GENERACION ENCABEZADO EDO CUENTA
	--------------------------------------------------------
	DEFINE sql_err				SMALLINT;
	DEFINE sCodRet				CHAR(5);
	DEFINE v_fecha_emision		DATE ;
	DEFINE v_num_credito		CHAR(20);
	DEFINE v_numcte 			CHAR(20);
	DEFINE v_num_tarjeta		CHAR(20);
	DEFINE v_nombre_cte			CHAR(150);
	DEFINE v_direccion_cn		CHAR(200);
	DEFINE v_direccion_col		CHAR(120);
	DEFINE v_direccion_del		CHAR(120);
	DEFINE v_edo_cd 			CHAR(120);
	DEFINE v_sucursal_nombre	CHAR(120);
	DEFINE v_sucursal_gerente	CHAR(150);
	DEFINE v_sucursal_tel		CHAR(20);
	DEFINE v_fecha_corte		DATE;
	DEFINE v_cp					CHAR(5);
	DEFINE v_cl_cobra			CHAR(63);
	DEFINE v_rfc				CHAR(13);
	DEFINE v_ruta				CHAR(47);
	DEFINE v_entre_calles		CHAR(40);
	DEFINE v_observaciones		CHAR(80);
	--jom ini
	DEFINE vValor				CHAR(1);
	DEFINE vaniovalido			CHAR(4);
	DEFINE vmesvalido			CHAR(2);
	--jom fin


	--------------------------------------------------------
	--	VARIABLES GENERACION ENCABEZADO EDO CUENTA
	--------------------------------------------------------
	LET sql_err				= 0;
	LET sCodRet				= '00000';
	LET v_fecha_emision		= "";
	LET v_num_credito		= "";
	LET v_numcte			= "";
	LET v_num_tarjeta		= "";
	LET v_nombre_cte		= "";
	LET v_direccion_cn		= "";
	LET v_direccion_col		= "";
	LET v_direccion_del		= "";
	LET v_edo_cd			= "";
	LET v_sucursal_nombre	= "";
	LET v_sucursal_gerente	= "";
	LET v_sucursal_tel		= "";
	LET v_fecha_corte		= "";
	LET v_cp				= "";
	LET v_cl_cobra			= "";
	LET v_rfc				= "";
	LET v_ruta				= "";
	LET v_entre_calles		= "";
	LET v_observaciones		= "";
	--jom ini
	LET vValor				= "";
	LET vaniovalido			= "";
	LET vmesvalido			= "";
	--jom fin


	--SET DEBUG FILE TO "/informix/encabezado_edocta.out";
	--TRACE ON;


	BEGIN
		ON EXCEPTION SET sql_err
			LET sCodRet = sql_err;


			RETURN sCodRet, NVL(v_fecha_emision,date(1)), NVL(v_num_credito, ""), NVL(v_numcte, ""), NVL(v_num_tarjeta, ""),
				   NVL(v_nombre_cte, ""), NVL(v_direccion_cn, ""), NVL(v_direccion_col, ""), NVL(v_direccion_del, ""), NVL(v_edo_cd, ""),
				   NVL(v_sucursal_nombre, ""), NVL(v_sucursal_gerente, ""), NVL(v_sucursal_tel, ""), NVL(v_fecha_corte,date(1)), NVL(v_cp, ""),
				   NVL(v_cl_cobra, ""), NVL(v_rfc, ""), NVL(v_ruta, ""), NVL(v_entre_calles, ""), NVL(v_observaciones, "");
		END EXCEPTION;




		-------------------------------------------------------------
		--VALIDACION DE TARJETA
		-------------------------------------------------------------
		SELECT num_credito INTO v_num_credito
		FROM sd_tarjeta
		WHERE empresa = pEmpresa AND num_tarjeta = pTarjeta and tipo_tarjeta = 'T'; --AND status_tar = "A"; -- JOM INI


		LET pTarjeta= pTarjeta;


		IF v_num_credito IS NULL THEN
			LET sCodRet = "00186";


			RETURN sCodRet, NVL(v_fecha_emision,date(1)), NVL(v_num_credito, ""), NVL(v_numcte, ""), NVL(v_num_tarjeta, ""),
				   NVL(v_nombre_cte, ""), NVL(v_direccion_cn, ""), NVL(v_direccion_col, ""), NVL(v_direccion_del, ""), NVL(v_edo_cd, ""),
				   NVL(v_sucursal_nombre, ""), NVL(v_sucursal_gerente, ""), NVL(v_sucursal_tel, ""), NVL(v_fecha_corte,date(1)), NVL(v_cp, ""),
				   NVL(v_cl_cobra, ""), NVL(v_rfc, ""), NVL(v_ruta, ""), NVL(v_entre_calles, ""), NVL(v_observaciones, "");
		END IF;


		-- Mostrar edo. de cuenta si/no  ini


		SELECT SUBSTR(valor, 1, 1), SUBSTR(valor, 2, 4), SUBSTR(valor, 6, 2)
		INTO vValor, vaniovalido, vmesvalido
		FROM bdicred:sd_param WHERE cod_param = '80';


		IF (vValor = "1" AND vaniovalido = LPAD(YEAR(pFechaEmision), 4, '0') AND vmesvalido = LPAD(MONTH(pFechaEmision), 2, '0')) THEN
			LET sCodRet = "00185";


			RETURN sCodRet, NVL(v_fecha_emision,date(1)), NVL(v_num_credito, ""), NVL(v_numcte, ""), NVL(v_num_tarjeta, ""),
				   NVL(v_nombre_cte, ""), NVL(v_direccion_cn, ""), NVL(v_direccion_col, ""), NVL(v_direccion_del, ""), NVL(v_edo_cd, ""),
				   NVL(v_sucursal_nombre, ""), NVL(v_sucursal_gerente, ""), NVL(v_sucursal_tel, ""), NVL(v_fecha_corte,date(1)), NVL(v_cp, ""),
				   NVL(v_cl_cobra, ""), NVL(v_rfc, ""), NVL(v_ruta, ""), NVL(v_entre_calles, ""), NVL(v_observaciones, "");
		END IF;


		-- Mostrar edo. de cuenta si/no  fin


		-------------------------------------------------------------
		--GENERACION ENCABEZADO EDO CUENTA
		-------------------------------------------------------------
		SELECT
			fecha_emision, num_credito, numcte, num_tarjeta, nombre_cte,
			direccion_cn, direccion_col, direccion_del, edo_cd, sucursal_nombre,
			sucursal_gerente, sucursal_tel, fecha_corte, cp, cl_cobra,
			rfc, ruta, entre_calles, observaciones
		INTO
			v_fecha_emision, v_num_credito, v_numcte, v_num_tarjeta, v_nombre_cte,
			v_direccion_cn, v_direccion_col, v_direccion_del, v_edo_cd, v_sucursal_nombre,
			v_sucursal_gerente, v_sucursal_tel, v_fecha_corte, v_cp,v_cl_cobra ,
			v_rfc, v_ruta, v_entre_calles, v_observaciones
		 FROM bdicred:sd_encabezado_edocta
        WHERE fecha_emision = pFechaEmision AND num_credito = v_num_credito;
--		 WHERE fecha_emision = pFechaEmision AND num_tarjeta = pTarjeta; -- JOM INI


        let v_num_tarjeta = pTarjeta;

		IF v_num_credito IS NULL THEN
			LET sCodRet = "00185";


			RETURN sCodRet, NVL(v_fecha_emision,date(1)), NVL(v_num_credito, ""), NVL(v_numcte, ""), NVL(v_num_tarjeta, ""),
				   NVL(v_nombre_cte, ""), NVL(v_direccion_cn, ""), NVL(v_direccion_col, ""), NVL(v_direccion_del, ""), NVL(v_edo_cd, ""),
				   NVL(v_sucursal_nombre, ""), NVL(v_sucursal_gerente, ""), NVL(v_sucursal_tel, ""), NVL(v_fecha_corte,date(1)), NVL(v_cp, ""),
				   NVL(v_cl_cobra, ""), NVL(v_rfc, ""), NVL(v_ruta, ""), NVL(v_entre_calles, ""), NVL(v_observaciones, "");
		END IF;


		RETURN sCodRet, NVL(v_fecha_emision,''), NVL(v_num_credito, ""), NVL(v_numcte, ""), NVL(v_num_tarjeta, ""),
			   NVL(v_nombre_cte, ""), NVL(v_direccion_cn, ""), NVL(v_direccion_col, ""), NVL(v_direccion_del, ""), NVL(v_edo_cd, ""),
			   NVL(v_sucursal_nombre, ""), NVL(v_sucursal_gerente, ""), NVL(v_sucursal_tel, ""), NVL(v_fecha_corte,''), NVL(v_cp, ""),
			   NVL(v_cl_cobra, ""), NVL(v_rfc, ""), NVL(v_ruta, ""), NVL(v_entre_calles, ""), NVL(v_observaciones, "");
	END;
END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".sp_consultar_param_web(pCod_param CHAR(3))

RETURNING CHAR(5)       AS codigo_error,
          CHAR(80)      AS mensaje_error,
          CHAR(100)     AS periodo;

DEFINE iSqlErr          INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cCodRet          CHAR(5);
DEFINE cMensajeRet      CHAR(80);
DEFINE cValor           CHAR(100);

--INICIALIZO VARIABLES
LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = "";
LET cMensajeRet     = "Exito";


 --SET DEBUG FILE TO "sp_consultar_param.out";
 --TRACE ON;

BEGIN

  ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet= iSqlErr;
          LET cMensajeRet= cErrorInfo;
          RETURN cCodRet, cMensajeRet, cValor;
       END IF;
  END EXCEPTION; 

   LET cCodRet = "00000";

   SELECT valor
     INTO cValor
	 FROM "informix".sd_param
	WHERE cod_param = pCod_param;

IF cValor  IS NULL THEN
    LET cCodRet     = '00002';
    LET cMensajeRet = 'ParÃ¡metro no existe';
END IF;

RETURN cCodRet, cMensajeRet, cValor;

END;
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para obtener',
'el valor de un parÃ¡metro dentro de la tabla sd_param',
'AUTOR : Roque Enrique Solis C.',
'FECHA : 17/Diciembre/2009',
'BD    : BDICRED';

CREATE PROCEDURE  "informix".sp_obtenproductocredito_web()

RETURNING CHAR(6) AS Codigo_de_Retorno,
		  CHAR(6) AS Numero_de_Producto,
		  CHAR(50) AS Nombre_Producto,
		  CHAR(1) AS Tp_Solicitud

--definicion de variables
	DEFINE sql_err 			INTEGER;
	DEFINE cCodret 			CHAR(5);
	DEFINE cNum_Producto	CHAR(6);
	DEFINE cNombre_Producto	CHAR(50);
	DEFINE cTipo 			CHAR(1);
--Asignacion de variables
    LET sql_err 			= 0;
	LET cCodret				= "00000";
	LET cNum_Producto		= "";
	LET cNombre_Producto	= "";
	LET cTipo 				= "";
	BEGIN
			--Manejo de excepciones (errores)
			ON EXCEPTION SET sql_err
				IF sql_err <> 0 THEN
					let cCodret = sql_err;
					RETURN cCodret, "","","";
				END IF;
			END EXCEPTION;

			/*SET DEBUG FILE TO "/tmp/sp_ObtenProductoCredito.out";
			TRACE ON;*/
			--Este Procedimiento se utiliza en CARATARJ.exe para Obtener los productos de crÃ©dito que se podrÃ¡ imprimir la reimpresion
			FOREACH
				SELECT a.num_producto,a.nombre_prod,b.tp_solicitud  
				INTO cNum_Producto, cNombre_Producto, cTipo
				FROM bdicred:sd_definicion a 
				LEFT JOIN  bdisolic:ss_solic_producto b ON(a.num_producto = b.num_producto) 
				WHERE a.maneja_pago_sost = 'N'
				RETURN cCodret,cNum_Producto,cNombre_Producto,cTipo WITH RESUME;
			END FOREACH;
	END;

END PROCEDURE
DOCUMENT
'AUTOR      : Cristian Valentina Aguilar',
'DESCRIPCION: Es procedimiento obtiene los productos de credito manejados por el banco',
'FECHA      : 12-10-2009',
'VERSION    : 20091012.1745',
'BD         : BDICRED',
'AUTOR      : Noel Eleazar Gerardo Garcia',
'DESCRIPCION: ModificaciÃ³n se agrego el retorno del tipo de producto para la reeimpresion de caratula',
'FECHA      : 08-12-2009',
'VERSION    : 20091208.1617',
'BD         : BDICRED';

CREATE PROCEDURE "informix".sp_registrarbitacora_ofi_web(pEmpresa CHAR (3), pNumCredito CHAR(20),pSucursal CHAR (4))
RETURNING CHAR(5)  AS codigo_retorno,
		  CHAR(80) AS mensaje_retorno; 
		  
---DECLARACIONES         
DEFINE cCodRet               CHAR(5); 
DEFINE cMensajeRet           CHAR(80);
DEFINE iSqlErr      	     INTEGER;
DEFINE iIsamErr              INTEGER;
DEFINE cErrorInfo            CHAR(80);
DEFINE cNumCte              CHAR(20);
DEFINE cRiesgo      	   	CHAR(2);
DEFINE dMontoOtor          	DECIMAL(18,2);
DEFINE cNumprod        	    CHAR(4);   
DEFINE cUser        	    CHAR(20);
---INICIALIZACIONES
LET iSqlErr              = 0;
LET iIsamErr             = 0;
LET cErrorInfo           = "";
LET cCodRet              = "00000";
LET cMensajeRet          = "PROCESO EXITOSO";
LET cNumCte 			 = "";
LET cRiesgo      	 	 = "";
LET dMontoOtor        	 = 0;
LET cNumprod        	 = "";  
LET cUser                = USER;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
     LET cCodRet     = iSqlErr;
	 LET cMensajeRet = cErrorInfo;
     RETURN cCodRet,cMensajeRet;
   END IF;	
END EXCEPTION;

--SET DEBUG FILE TO 'sp_registrarbitacora_ofi.out';
--TRACE ON;

--se validan los parametros de entrada.
	IF NVL(pEmpresa,"") = "" THEN
		LET cCodRet = "00001";
		LET cMensajeRet = "Falta parÃ¡metro de empresa";
	ELIF NVL(pNumCredito,"") = "" THEN
		LET cCodRet = "00002";
		LET cMensajeRet = "Falta parÃ¡metro requerido de numero de credito para realizar la consulta";
	ELSE 
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		SELECT a.numcte, b.monto_otorgado, a.num_producto
	      INTO  cNumCte, dMontoOtor, cNumprod
		  FROM bdicred:"informix".sd_maecred a 
		  INNER JOIN bdicred:"informix".sd_maesdos b ON a.empresa = b.empresa AND a.num_credito = b.num_credito
		  WHERE a.empresa     = pEmpresa
	       AND a.num_credito = pNumCredito;
			
	        INSERT INTO bdicred:"informix".sd_bitacora_aumlincred
			(empresa, num_solicitud, numcte, num_producto, status, causa_status, fecha_status, hora_status, sucursal,lincred_actual,origen, user_insert, fecha_insert) 
	        VALUES(pEmpresa, pNumCredito, cNumCte, cNumprod, "AN",'',CURRENT, CURRENT,pSucursal, dMontoOtor,"S", cUser, CURRENT);
	        
			INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred
			(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
	        VALUES(pEmpresa, pNumCredito, "AN", '', cUser, CURRENT, CURRENT, 0);		

	END IF;
	RETURN cCodRet, cMensajeRet; 		
END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para realizar registro de anulacion de la solicitud en bitacora.',
'AUTOR : Maria Elena Angulo Aispuro,JesÃºs Manuel Aguilar Heredia',
'FECHA : 10/Oct/2011',
'BD    : BDICRED',
'Version: 20111010.1051';

CREATE PROCEDURE "informix".sp_reverapercrd_web(P_EMPRESA   CHAR(3),
                                            P_SOLICITUD CHAR(20))
RETURNING VARCHAR(5),    --CodRet
          VARCHAR(80);   --Mensaje

                             --Variables

  DEFINE P_ERROR       VARCHAR(5);
  DEFINE P_MENSAJE     VARCHAR(80);
  DEFINE V_FOLIO       VARCHAR(16);
  DEFINE v_folio_old   VARCHAR(16);
  DEFINE v_credito_old VARCHAR(20);
  DEFINE vnum_credito  CHAR(20);
  DEFINE vlongcred     SMALLINT;
  DEFINE vusuario      CHAR(8);
  DEFINE vsucursal     CHAR(4);





BEGIN

      --Set debug file to '/tmp/rever.out';
      --trace on;

      LET P_ERROR      = '00000';
      LET P_MENSAJE    = 'PROCESO EXITOSO';
      LET vnum_credito = P_SOLICITUD;

      SELECT UNIQUE FOLIO_SUC,usuario,sucursal
      INTO V_FOLIO,vusuario,vsucursal
      FROM sd_movdia
      WHERE empresa = P_EMPRESA
      AND num_credito = P_SOLICITUD
      AND codigo_fun = "001";

                           --** Reversion De Cheques

      EXECUTE PROCEDURE BDICHEQ:REVERSION(P_EMPRESA, "001", vusuario, V_FOLIO,"B")
      INTO P_ERROR;

      IF P_ERROR="000" THEN
          LET P_ERROR="00000";
      ELSE
         LET P_ERROR="00001";
      END IF

      IF P_ERROR <> "00000" THEN
	LET P_MENSAJE = "REVERSION DE AHORROS";
	RETURN P_ERROR, P_MENSAJE;
      END IF

                      --** Reversion De Credito Liquidacion



      EXECUTE PROCEDURE reversioncrd(P_EMPRESA,vsucursal,vusuario,v_FOLIO,'B')
      INTO P_ERROR;

      IF P_ERROR="000" THEN
          LET P_ERROR="00000";
      ELSE 
         LET P_ERROR="00001";
      END IF

      IF P_ERROR <> "00000" THEN
	LET P_MENSAJE = "REVERSION DE CREDITO";
	RETURN P_ERROR, P_MENSAJE;
      END IF



      LET P_ERROR   = '00000';


      DELETE FROM SD_AMORTIZA_CREDITOCRD
      WHERE  NUM_CREDITO = vnum_credito
      AND    EMPRESA     = P_EMPRESA;

      DELETE FROM SD_MAESDOSCRD
       where empresa     = P_EMPRESA
         and num_credito = vnum_credito;

      DELETE FROM SD_MAECREDCRD
      WHERE  NUM_CREDITO = vnum_credito
      AND    EMPRESA     = P_EMPRESA;

      DELETE FROM SD_MAECREDANEXOCRD
      WHERE  NUM_CREDITO = vnum_credito
      AND    EMPRESA     = P_EMPRESA;

      DELETE FROM SD_MOVDIA
      WHERE  NUM_CREDITO = vnum_credito
      AND    EMPRESA     = P_EMPRESA;

      UPDATE BDISOLIC:SS_SOLICITUDES
             SET status_solicitud = 'CF'
      WHERE num_solicitud =  vnum_credito
      AND empresa  = P_EMPRESA;

      UPDATE BDISOLIC:SS_SOLICITUDES
             SET status_solicitud = 'CC'
      WHERE num_solicitud =  vnum_credito
      AND empresa  = P_EMPRESA;

   RETURN P_ERROR,P_MENSAJE;

   BEGIN
     ON EXCEPTION
         ROLLBACK WORK;
         RETURN P_ERROR,P_MENSAJE;
     END EXCEPTION;
   END;
END;
END PROCEDURE;