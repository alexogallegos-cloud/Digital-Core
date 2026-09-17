CREATE PROCEDURE "informix".sp_domi_consultaservicios ()
	Returning 	CHAR (5), 	--Codigo de Retorno
				CHAR (18),	--RFC
				CHAR (60),	--Razon Social
				CHAR (20), 	--Nombre corto razon social
				CHAR (1), 	--convenio
				CHAR (2), 	--cve_canal
				CHAR (1), 	--presentador
				CHAR (20), 	--num_cte
				CHAR (20), 	--num_reintentos
				CHAR (20), 	--comision
				CHAR (20), 	--comision_dev
				CHAR (20), 	--cuenta_cargo_comision			
				CHAR (1),	--layout_especial
				CHAR (4),	--cod_grupo_act
				CHAR (4),	--cod_grupo_des
				CHAR (4);	--cod_grupo_react
	
	--Declaracion de  Variables
	DEFINE sql_err         INTEGER;
	DEFINE cCodret         CHAR(5);
	DEFINE cRfc            CHAR (18);
	DEFINE cRazon_social   CHAR (60);
	DEFINE iContador       SMALLINT;
	DEFINE cNombre_corto   CHAR(20);
	DEFINE cCodGrupoAct    CHAR(4);
	DEFINE cCodGrupoDes	   CHAR(4);
	DEFINE cCodGrupoReact  CHAR(4);	
	DEFINE cConvenio	   CHAR(1);
	DEFINE cCve_canal	   CHAR(2);
	DEFINE cPresentador    CHAR(1);
	DEFINE cNum_cte		   CHAR(20);
	DEFINE cNum_reintentos CHAR(20);
	DEFINE cComision	   CHAR(20);
	DEFINE cComision_dev   CHAR(20);
	DEFINE cCuenta_cargo_comision CHAR(20);
	DEFINE cLayout_especial CHAR(1);
	
	--Inicializo Variables
	LET sql_err            = 0;
	LET cCodret            = "00000";
	LET cRazon_social      = "";
	LET cRfc               = "";
	LET iContador          = 0;
	LET cNombre_corto	   = "";
	LET cCodGrupoAct       = "";
	LET cCodGrupoDes	   = "";
	LET cCodGrupoReact     = "";
	LET cConvenio		   = "";
	LET cCve_canal		   = "";
	LET cPresentador 	   = "";
	LET cNum_cte		   = "";
	LET cNum_reintentos	   = "";
	LET cComisioN		   = "";
	LET cComision_dev      = "";
	LET cCuenta_cargo_comision = "";
	LET cLayout_especial   = "";

	BEGIN 
	--Manejo de excepciones (errores)
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			let cCodret = sql_err;
			RETURN cCodret, cRfc, cRazon_social,cNombre_corto,cConvenio,cCve_canal,cPresentador,cNum_cte,cNum_reintentos,cComision,cComision_dev,cCuenta_cargo_comision,cLayout_especial,cCodGrupoAct,cCodGrupoDes,cCodGrupoReact; --Regresa Resultados
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/sp_Domi_ConsultaServicios.out";
	--TRACE ON;  

	FOREACH --Realiza una consulta donde obtiene los servicios 
		SELECT rfc,razon_social, nombre_corto,convenio,cve_canal,presentador,num_cte,num_reintentos,comision,comision_dev,cuenta_cargo_comision,layout_especial,cod_grupo_act,cod_grupo_des,cod_grupo_react
		INTO cRfc,cRazon_social, cNombre_corto,cConvenio,cCve_canal,cPresentador,cNum_cte,cNum_reintentos,cComision,cComision_dev,cCuenta_cargo_comision,cLayout_especial,cCodGrupoAct,cCodGrupoDes,cCodGrupoReact
		FROM bdidomi:dom_cat_servicios
		ORDER BY razon_social
		
		LET iContador = iContador + 1; --Se incrementa el contador 
		
		RETURN cCodret, cRfc, cRazon_social,cNombre_corto,cConvenio,cCve_canal,cPresentador,cNum_cte,cNum_reintentos,cComision,cComision_dev,cCuenta_cargo_comision,cLayout_especial,cCodGrupoAct,cCodGrupoDes,cCodGrupoReact WITH RESUME; --Regresa Resultados
	END FOREACH;
	IF iContador = 0 THEN  --Valida si se encontraron registros
		LET iContador = '00001';
		RETURN cCodret, cRfc, cRazon_social,cNombre_corto,cConvenio,cCve_canal,cPresentador,cNum_cte,cNum_reintentos,cComision,cComision_dev,cCuenta_cargo_comision,cLayout_especial,cCodGrupoAct,cCodGrupoDes,cCodGrupoReact WITH RESUME; --Regresa Resultados
	END IF;
	END;
END PROCEDURE
DOCUMENT
'AUTOR      : César Valdéz Figueroa',
'DESCRIPCION: Este procedimiento se encarga de Obtener los servicios que se pueden domiciliar.',
'			  obteniendo los datos de la tabla dom_cat_servicios',  	
'FECHA      : 2009/10/12',
'VERSION    : 20091012.1130',
'BD         : BDIDOMI';

CREATE PROCEDURE "informix".sp_domi_genrep10(pNomArchivo CHAR(20), pTpoProc INTEGER, pfecini CHAR(10), pfecfin CHAR(10))
RETURNING
         CHAR(5),       -- 001.- Codigo de Retorno
		 CHAR(130),     -- 002.- Descripcion del Error
		 CHAR(10),      -- 01.- Fecha Presentacion
		 CHAR(20),      -- 02.- Nombre Archivo
		 MONEY(15, 2),  -- 03.- Importe
		 CHAR(7),       -- 04.- Sec
		 CHAR(20),      -- 05.- Cuenta Origen
		 CHAR(20),      -- 06.- Cuenta Destino
		 CHAR(20),      -- 07.- Tipo de Cuenta
		 CHAR(20),      -- 08.- Banco Destino
		 CHAR(20),      -- 09.- Estatus
		 CHAR(2),       -- 10.- Codigo de Respuesta
		 CHAR(60),      -- 11.- Causa Rechazo
		 CHAR(2);		-- 12.- Clave del estatus

-- Declaracion de Variables
DEFINE iSQLerr        INTEGER;
DEFINE cCodRet        CHAR(5);       -- 001
DEFINE cDescError     CHAR(130);      -- 002
DEFINE cFechPresFinR  CHAR(10);      -- 01
DEFINE cNomArch       CHAR(20);      -- 02
DEFINE mImp2          MONEY(15, 2);  -- 03
DEFINE cSec           CHAR(7);       -- 04
DEFINE cCtaOrigen     CHAR(20);      -- 05
DEFINE cCtaDest       CHAR(20);      -- 06
DEFINE cTpoCta        CHAR(20);      -- 07
DEFINE cBancDest      CHAR(20);      -- 08
DEFINE cStatus        CHAR(20);      -- 09
DEFINE cCodResp       CHAR(2);       -- 10
DEFINE cCausaRech     CHAR(60);      -- 11
DEFINE cFechPresS	  CHAR(8);
DEFINE cFecInicioW    CHAR(8);
DEFINE cFecFinW       CHAR(8);
DEFINE cTipoP         CHAR(1);
DEFINE cStat_val      CHAR(2);
DEFINE cImp           CHAR(15);
DEFINE cTipoCtaCod    CHAR(30);
DEFINE cCodRet2       CHAR(5);
DEFINE iTipoOp        INTEGER;
DEFINE cClave_rastreo  CHAR(30);


ON EXCEPTION SET iSQLerr
	IF iSQLerr <> 0 THEN
		LET cCodRet = iSQLerr;
		EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
		RETURN cCodRet, cDescError, cFechPresS, cNomArch, cImp, cSec, cCtaOrigen, cCtaDest, cTpoCta, cBancDest, cStatus, cCodResp, cCausaRech,cStat_val;
	END IF;
END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/sp_domi_genrep10.out";
	--TRACE ON;

-- Inicializacion de Variables
LET iSQLerr        = 0;
LET cCodRet        = "00000"; -- 00
LET cFechPresFinR  = "";      -- 01
LET cNomArch       = "";      -- 02
LET cImp           = "";      -- 04
LET cSec           = "";      -- 05
LET cCtaOrigen     = "";      -- 06
LET cCtaDest       = "";      -- 07
LET cTpoCta        = "";      -- 08
LET cBancDest      = "";      -- 09
LET cStatus        = "";      -- 10
LET cCodResp       = "";      -- 11
LET cCausaRech     = "";      -- 12
LET cFechPresS	   = "";
LET cFecInicioW    = "";
LET cFecFinW       = "";
LET cTipoP         = "";
LET cStat_val      = "";
LET mImp2          = 0.00;
LET cTipoCtaCod    = "";
LET cCodRet2       = "";
LET cDescError     = "";
LET iTipoOp        = 0;
LET cClave_rastreo = '';

BEGIN

	IF pfecini = "01/01/1900" OR pfecfin = "01/01/1900" THEN
		LET pfecini = "";
		LET pfecfin = "";
	END IF;

	IF ((pTpoProc = "") OR (pTpoProc IS NULL)) THEN
		LET iTipoOp = -1;
	ELSE
		LET iTipoOp = pTpoProc;
	END IF;

	IF ((pfecini IS NULL) OR (pfecfin IS NULL)) THEN
		LET pfecini = "";
		LET pfecfin = "";
	ELSE
		LET pfecini = pfecini;
		LET pfecfin = pfecfin;
	END IF;

	SET ISOLATION DIRTY READ;
	SET LOCK MODE TO wait 4;

	IF pNomArchivo = "" AND iTipoOp = -1 THEN
		LET cCodRet = "02600"; -- FALTAN PARAMETROS: NOMBRE DEL ARCHIVO O TIPO DE PROCESO
		EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
		RETURN cCodRet, cDescError, cFechPresS, cNomArch, cImp, cSec, cCtaOrigen, cCtaDest, cTpoCta, cBancDest, cStatus, cCodResp, cCausaRech,cStat_val;
	END IF;

	IF (pNomArchivo <> "") AND (iTipoOp >= 0) THEN -- CON EL NOMBRE DEL ARCHIVO Y  TIPO DE PROCESO
		LET cCodRet = "02601"; -- ERROR EN LA ASIGNACION DE PARAMETROS: NO SE PUEDE GENERAR POR NOMBRE + TIPO DE PROCESO
		EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
		RETURN cCodRet, cDescError, cFechPresS, cNomArch, cImp, cSec, cCtaOrigen, cCtaDest, cTpoCta, cBancDest, cStatus, cCodResp, cCausaRech,cStat_val;
	END IF;

	IF pNomArchivo <> "" AND iTipoOp = -1 THEN -- CONSULTA POR NOMBRE DEL ARCHIVO
		IF pfecini = "" AND pfecfin = "" THEN
			IF (SUBSTR(pNomArchivo, 1, 1) = 'E' AND SUBSTR(pNomArchivo, 14, 2) = 10 AND LENGTH(pNomArchivo) = 17) OR
			   (SUBSTR(pNomArchivo, 1, 1) = 'S' AND SUBSTR(pNomArchivo, 11, 2) = 10 AND LENGTH(pNomArchivo) = 16) THEN

				IF NOT EXISTS (SELECT 1 FROM bdidomi:dom_cce_detalle WHERE nombre_arch = pNomArchivo) THEN
						LET cCodRet = "02602"; -- EL ARCHIVO NO EXISTE
						EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
						RETURN cCodRet, cDescError, cFechPresS, cNomArch, cImp, cSec, cCtaOrigen, cCtaDest, cTpoCta, cBancDest, cStatus, cCodResp, cCausaRech,cStat_val;
				END IF;

				FOREACH WITH HOLD

					SELECT
						 TRIM(det.fecha_presentacion), TRIM(det.importe), TRIM(det.num_secuencia),
						 CASE WHEN SUBSTR(nombre_arch, 1,1) = 'E' THEN TRIM(det.num_cta_rec) ELSE TRIM(det.num_cta_ord) END,
						 CASE WHEN SUBSTR(nombre_arch, 1,1) = 'E' THEN TRIM(det.num_cta_ord) ELSE TRIM(det.num_cta_rec) END,
						 CASE WHEN SUBSTR(nombre_arch, 1,1) = 'E' THEN TRIM(det.tipo_cta_rec) ELSE TRIM(det.tipo_cta_ord) END,
						 TRIM(ban.vchrnombrecorto), TRIM(stap.descripcion), TRIM(dev.descripcion), TRIM(det.cve_estatus),det.clave_rastreo
					INTO cFechPresS, cImp, cSec,
						 cCtaDest, cCtaOrigen, cTipoCtaCod,
						 cBancDest, cStatus, cCausaRech, cStat_val,cClave_rastreo
					FROM bdidomi:dom_cce_detalle det
					INNER JOIN bdidomi:dom_cat_devoluciones dev ON det.motivo_dev = dev.motivo_dev
					INNER JOIN bdidomi:dom_status_pago stap ON det.cve_estatus = stap.cve_status
					INNER JOIN bdinteg:si_bancos ban ON det.banco_receptor = ban.banco
					WHERE nombre_arch = pNomArchivo
					AND cod_operacion = '10'

					SELECT descripcion
					INTO cTpoCta
					FROM bdidomi:dom_tipo_cta
					WHERE tipo_cta = cTipoCtaCod;

					IF cStat_val <> "03" THEN
						LET cCausaRech = "";
					END IF;
					--si es rechazado  colocar la causa de rechazo del codigo 11
					IF cStat_val = "02" THEN
					
						SELECT dev.descripcion 
						INTO cCausaRech 
						FROM bdidomi:dom_cce_detalle det
						INNER JOIN bdidomi:dom_cat_devoluciones dev ON det.motivo_dev = dev.motivo_dev
						WHERE cod_operacion = '11'
						AND clave_rastreo = cClave_rastreo;

					END IF;
					IF cStat_val = '00' THEN
						LET cCodResp = '';
					ELSE
						LET cCodResp = '11';
					END IF;
				
					LET mImp2 = cImp / 100;
					LET	cFechPresFinR = TRIM(SUBSTR(cFechPresS, 7, 2) || '/' || SUBSTR(cFechPresS, 5, 2) || '/' || SUBSTR(cFechPresS, 1, 4));

					RETURN cCodRet, TRIM(cDescError), cFechPresFinR, pNomArchivo, mImp2, cSec, cCtaOrigen, cCtaDest, cTpoCta, cBancDest, cStatus, cCodResp, cCausaRech,cStat_val WITH RESUME;

				END FOREACH;
			ELSE
				LET cCodRet = "02604"; -- ERROR EN LA ESTRUCTURA DEL NOMBRE DEL ARCHIVO
				EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
				RETURN cCodRet, cDescError, cFechPresS, cNomArch, cImp, cSec, cCtaOrigen, cCtaDest, cTpoCta, cBancDest, cStatus, cCodResp, cCausaRech,cStat_val;
			END IF;

		ELSE
			LET cCodRet = "02605"; -- ERROR EN LA ASIGNACION DE PARAMETROS: NO SE PUEDE GENERAR POR ARCHIVO + FECHA(S) -- no se puede ejecutar nombre de archivo con fechaS
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
			RETURN cCodRet, cDescError, cFechPresS, cNomArch, cImp, cSec, cCtaOrigen, cCtaDest, cTpoCta, cBancDest, cStatus, cCodResp, cCausaRech,cStat_val;
		END IF;


	ELIF iTipoOp = 0 OR iTipoOp = 3 THEN -- CONSULTA POR NOMBRE DEL PROCESO
		IF pfecini <> "" AND pfecfin <> "" THEN

			-- SE FORMATEAN LAS FECHAS RECIBIDAS PARA CAMBIARLAS A 'YYYYMMDD' (SIN DIAGONALES) PARA INCLUIRLAS EN EL WHERE
			LET cFecInicioW = SUBSTR(pfecini, 7, 4) || SUBSTR(pfecini, 1, 2) || SUBSTR(pfecini, 4, 2);
			LET cFecFinW = SUBSTR(pfecfin, 7, 4) || SUBSTR(pfecfin, 1, 2) || SUBSTR(pfecfin, 4, 2);

			IF iTipoOp = 0 THEN -- REPORTE PRESENTADO
				LET cTipoP = 'E';
			ELIF iTipoOp = 3 THEN -- REPORTE RECIBIDO
				LET cTipoP = 'S';
			END IF;

			IF NOT EXISTS (SELECT 1 FROM bdidomi:dom_cce_detalle WHERE cod_operacion = '10' AND fecha_presentacion BETWEEN cFecInicioW AND cFecFinW
																						    AND nombre_arch LIKE cTipoP || '%') THEN
				LET cCodRet = "02603"; -- EL ARCHIVO NO EXISTE
				EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
				RETURN cCodRet, cDescError, cFechPresS, cNomArch, cImp, cSec, cCtaOrigen, cCtaDest, cTpoCta, cBancDest, cStatus, cCodResp, cCausaRech,cStat_val;
			END IF;

			FOREACH WITH HOLD

				SELECT
					 TRIM(det.fecha_presentacion), TRIM(nombre_arch), TRIM(det.importe), TRIM(det.num_secuencia),
					 CASE WHEN SUBSTR(nombre_arch, 1,1) = 'E' THEN TRIM(det.num_cta_rec) ELSE TRIM(det.num_cta_rec) END,
					 CASE WHEN SUBSTR(nombre_arch, 1,1) = 'E' THEN TRIM(det.num_cta_ord) ELSE TRIM(det.num_cta_ord) END,
					 CASE WHEN SUBSTR(nombre_arch, 1,1) = 'E' THEN TRIM(det.tipo_cta_rec) ELSE TRIM(det.tipo_cta_ord) END,
					 TRIM(ban.vchrnombrecorto), TRIM(stap.descripcion), TRIM(dev.descripcion), TRIM(det.cve_estatus),det.clave_rastreo
				INTO cFechPresS, cNomArch, cImp, cSec,
					  cCtaDest, cCtaOrigen, cTipoCtaCod,
					  cBancDest, cStatus, cCausaRech, cStat_val,cClave_rastreo
				FROM bdidomi:dom_cce_detalle det
				INNER JOIN bdidomi:dom_cat_devoluciones dev ON det.motivo_dev = dev.motivo_dev
				INNER JOIN bdidomi:dom_status_pago stap ON det.cve_estatus = stap.cve_status
				INNER JOIN bdinteg:si_bancos ban ON det.banco_receptor = ban.banco
				WHERE cod_operacion = '10'
				AND fecha_presentacion BETWEEN cFecInicioW AND cFecFinW
				AND nombre_arch LIKE cTipoP || '%'

				SELECT TRIM(descripcion)
				INTO cTpoCta
				FROM bdidomi:dom_tipo_cta
				WHERE tipo_cta = cTipoCtaCod;

				IF cStat_val <> "03" THEN
					LET cCausaRech = "";
				END IF;
				--si es rechazado  colocar la causa de rechazo del codigo 11
				IF cStat_val = "02" THEN
				
					SELECT dev.descripcion 
					INTO cCausaRech 
					FROM bdidomi:dom_cce_detalle det
					INNER JOIN bdidomi:dom_cat_devoluciones dev ON det.motivo_dev = dev.motivo_dev
					WHERE cod_operacion = '11'
					AND clave_rastreo = cClave_rastreo
					AND fecha_presentacion BETWEEN cFecInicioW AND cFecFinW;

					
				END IF;
				IF cStat_val = '00' THEN
					LET cCodResp = '';
				ELSE
					LET cCodResp = '11';
				END IF;
				
				LET mImp2 = cImp / 100;
				LET	cFechPresFinR = TRIM(SUBSTR(cFechPresS, 7, 2) || '/' || SUBSTR(cFechPresS, 5, 2) || '/' || SUBSTR(cFechPresS, 1, 4));

				RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, mImp2, cSec, cCtaOrigen, cCtaDest, cTpoCta, cBancDest, cStatus, cCodResp, cCausaRech,cStat_val WITH RESUME;

			END FOREACH;
		ELSE
			LET cCodRet = '02606'; -- ERROR EN LA GENERACION DEL REPORTE POR TIPO DE PROCESO: FALTAN FECHA INICIO Y/O FECHA FINAL
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
			RETURN cCodRet, cDescError, cFechPresS, cNomArch, cImp, cSec, cCtaOrigen, cCtaDest, cTpoCta, cBancDest, cStatus, cCodResp, cCausaRech,cStat_val;
		END IF;
	ELSE
		LET cCodRet = '02607'; -- TIPO DE OPERACION NO VALIDA PARA LA GENERACION DE REPORTES ARCHIVO 10 - VALORES 0 o 3
		EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
		RETURN cCodRet, cDescError, cFechPresS, cNomArch, cImp, cSec, cCtaOrigen, cCtaDest, cTpoCta, cBancDest, cStatus, cCodResp, cCausaRech,cStat_val;
	END IF;
END
END PROCEDURE
DOCUMENT
'AUTOR: Clemente Angulo Ballardo',
'DESCRIPCION: Procedimiento que genera el reporte de los archivos codigo 10, ya sean presentados o recibidos',
'FECHA: 11/08/2009',
'VERSION: 20090811.1800',
'BD: Bdidomi',
'Modifico: César Valdéz Figueroa',
'Descripcion: Se modificaron para a gregar el mensaje causa de rechazo cuando se requiera, ademas de que cuando ',
'			  no se reciba respuesta en 11 no se muestra el codigo de respuesta',
'Fecha: 2009/09/28',
'Version: 20090929.1000',
'BD: BDIDOMI';

CREATE PROCEDURE "informix".sp_domi_genrep34(pNomArchivo CHAR(20), pTpoProc INTEGER, pfecini CHAR(10), pfecfin CHAR(10))
RETURNING
         CHAR(5),       -- 001.- Codigo de Retorno
		 CHAR(65),      -- 002.- Descripcion del Error
		 CHAR(10),      -- 01.- Fecha Presentacion
		 CHAR(20),      -- 02.- Nombre Archivo
		 CHAR(40),      -- 03.- Nombre Ordenante
		 CHAR(60),      -- 04.- Servicio
		 CHAR(7),       -- 05.- Referencia Numerica
		 MONEY(15, 2),  -- 06.- Importe
		 CHAR(20),      -- 07.- Cuenta Destino
		 CHAR(7),       -- 08.- Sec
		 CHAR(20),      -- 09.- Tipo de Cuenta
		 CHAR(20),      -- 10.- Banco Destino
		 CHAR(10),      -- 11.- Fecha Origen
		 CHAR(20),      -- 12.- Estatus
		 CHAR(4);       -- 13.- Sucursal

-- Declaracion de Variables
DEFINE iSQLerr        INTEGER;
DEFINE cCodRet        CHAR(5);        -- 001
DEFINE cDescError     CHAR(95);       -- 002
DEFINE cFechPresFinR  CHAR(10);       -- 01
DEFINE cNomArch       CHAR(20);       -- 02
DEFINE cNomOrd        CHAR(40);       -- 03
DEFINE cServ          CHAR(60);       -- 04
DEFINE cRef           CHAR(7);        -- 05
DEFINE mImp2          MONEY(15, 2);   -- 06
DEFINE cCtaDest       CHAR(20);       -- 07
DEFINE cSec           CHAR(7);        -- 08
DEFINE cTpoCta        CHAR(20);       -- 09
DEFINE cBancDest      CHAR(20);       -- 10
DEFINE cFechOrig      CHAR(10);       -- 11
DEFINE cStatus        CHAR(20);       -- 12
DEFINE cImp           CHAR(15);
DEFINE cFechPresS	  CHAR(8);
DEFINE cFecInicioW    CHAR(8);
DEFINE cFecFinW       CHAR(8);
DEFINE cFechIniS      CHAR(8);
DEFINE cTipoP         CHAR(1);
DEFINE cStat_val      CHAR(2);
DEFINE cTipoCtaCod    CHAR(30);
DEFINE cCodRet2       CHAR(5);
DEFINE cBancDestCod   CHAR(3);
DEFINE cSucursal	  CHAR(4);
DEFINE cTipo_registro CHAR(2);
DEFINE cNum_secuencia CHAR(7);
DEFINE iTipoOp        INTEGER;
DEFINE cMensaje    CHAR(300);

ON EXCEPTION SET iSQLerr
	IF iSQLerr <> 0 THEN
		LET cCodRet = iSQLerr;
		EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
		RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, mImp2, cCtaDest, cSec, cTpoCta, cBancDest, cFechOrig, cStatus,cSucursal;
	END IF;
END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/sp_domi_genrep34.out";
	--TRACE ON;

-- Inicializacion de Variables
LET iSQLerr        = 0;
LET cCodRet        = "00000"; -- 001
LET cDescError     = "";      -- 002
LET cFechPresFinR  = "";      -- 01
LET cNomArch       = "";      -- 02
LET cNomOrd        = "";      -- 03
LET cServ          = "";      -- 04
LET cRef           = "";      -- 05
LET mImp2          = 0.00;    -- 06
LET cCtaDest       = "";      -- 07
LET cSec           = "";      -- 08
LET cTpoCta        = "";      -- 09
LET cBancDest      = "";      -- 10
LET cStatus        = "";      -- 11
LET cImp           = "";
LET cFechPresS	   = "";
LET cFecInicioW    = "";
LET cFecFinW       = "";
LET cFechIniS      = "";
LET cFechOrig      = "";
LET cTipoP         = "";
LET cStat_val      = "";
LET cTipoCtaCod    = "";
LET cCodRet2       = "";
LET cDescError     = "";
LET cBancDestCod   = "";
LET cSucursal	   = "";
LET cTipo_registro = "";
LET cNum_secuencia = "";
LET iTipoOp        = 0;

BEGIN

	IF pfecini = "01/01/1900" OR pfecfin = "01/01/1900" THEN
		LET pfecini = "";
		LET pfecfin = "";
	END IF;

	IF ((pTpoProc = "") OR (pTpoProc IS NULL)) THEN
		LET iTipoOp = -1;
	ELSE
		LET iTipoOp = pTpoProc;
	END IF;

	IF ((pfecini IS NULL) OR (pfecfin IS NULL)) THEN
		LET pfecini = "";
		LET pfecfin = "";
	ELSE
		LET pfecini = pfecini;
		LET pfecfin = pfecfin;
	END IF;

	SET ISOLATION DIRTY READ;
	SET LOCK MODE TO wait 4;

	IF pNomArchivo = "" AND iTipoOp = -1 THEN
		LET cCodRet = "02600"; -- FALTAN PARAMETROS: NOMBRE DEL ARCHIVO O TIPO DE PROCESO
		EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
		RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, mImp2, cCtaDest, cSec, cTpoCta, cBancDest, cFechOrig, cStatus,cSucursal;
	END IF;

	IF (pNomArchivo <> "") AND (iTipoOp >= 0) THEN -- CON EL NOMBRE DEL ARCHIVO Y  TIPO DE PROCESO
		LET cCodRet = "02601"; -- ERROR EN LA ASIGNACION DE PARAMETROS: NO SE PUEDE GENERAR POR NOMBRE + TIPO DE PROCESO
		EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
		RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, mImp2, cCtaDest, cSec, cTpoCta, cBancDest, cFechOrig, cStatus,cSucursal;
	END IF;

	IF pNomArchivo <> "" AND iTipoOp = -1 THEN -- CONSULTA POR NOMBRE DEL ARCHIVO
		IF pfecini = "" AND pfecfin = "" THEN
			IF (SUBSTR(pNomArchivo, 1, 1) = 'E' AND SUBSTR(pNomArchivo, 14, 2) = 34 AND LENGTH(pNomArchivo) = 17) OR
			   (SUBSTR(pNomArchivo, 1, 1) = 'S' AND SUBSTR(pNomArchivo, 11, 2) = 34 AND LENGTH(pNomArchivo) = 16) THEN

				IF NOT EXISTS (SELECT 1 FROM bdidomi:dom_cce_detalle WHERE nombre_arch = pNomArchivo) THEN
					LET cCodRet = "02602"; -- EL ARCHIVO NO EXISTE
					EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
					RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, mImp2, cCtaDest, cSec, cTpoCta, cBancDest, cFechOrig, cStatus,cSucursal;
				END IF;

				FOREACH WITH HOLD

					SELECT
						 TRIM(det.fecha_presentacion),
						 CASE WHEN SUBSTR(pNomArchivo, 1,1) = 'E' THEN TRIM(det.nombre_ord) ELSE TRIM(det.nombre_rec) END,
						 TRIM(ser.razon_social), TRIM(det.ref_numerica), TRIM(det.importe),  
					     CASE WHEN SUBSTR(nombre_arch, 1,1) = 'E' THEN TRIM(det.num_cta_ord) ELSE TRIM(det.num_cta_rec) END,
						 TRIM(det.num_secuencia), TRIM(det.tipo_cta_rec),
						 CASE WHEN SUBSTR(nombre_arch, 1,1) = 'E' THEN TRIM(det.banco_receptor) ELSE TRIM(det.banco_receptor) END,
						 TRIM(det.fecha_pres_ini), TRIM(stap.descripcion), TRIM(det.cve_estatus),det.tipo_registro,det.num_secuencia,
						 TRIM(det.nombre_arch)
					INTO cFechPresS,
					     cNomOrd,
						 cServ, cRef, cImp, cCtaDest, cSec, cTipoCtaCod,
						 cBancDestCod,
						 cFechIniS, cStatus, cStat_val,cTipo_registro,cNum_secuencia,cNomArch
					FROM bdidomi:dom_cce_detalle det
					INNER JOIN bdidomi:dom_cat_servicios ser ON det.rfc_ord = ser.rfc
					INNER JOIN bdidomi:dom_status_pago stap ON det.cve_estatus = stap.cve_status
					WHERE det.nombre_arch = pNomArchivo
					AND cod_operacion = '34'

					SELECT TRIM(descripcion)
					INTO cTpoCta
					FROM bdidomi:dom_tipo_cta
					WHERE tipo_cta = cTipoCtaCod;

					SELECT TRIM(sucursal_sol)
					INTO cSucursal
					FROM bdidomi:dom_reversos
					WHERE nom_archivo_rev = cNomArch 
						AND fecha_presentacion_rev = cFechPresS
						AND tipo_registro = cTipo_registro
						AND num_secuencia = cNum_secuencia;

					SELECT TRIM(vchrnombrecorto)
					INTO cBancDest
					FROM bdinteg:si_bancos
					WHERE banco = cBancDestCod;

					LET mImp2 = cImp / 100;
					LET cFechOrig = TRIM(SUBSTR(cFechIniS, 7, 2) || '/' || SUBSTR(cFechIniS, 5, 2) || '/' || SUBSTR(cFechIniS, 1, 4));
					LET	cFechPresFinR = TRIM(SUBSTR(cFechPresS, 7, 2) || '/' || SUBSTR(cFechPresS, 5, 2) || '/' || SUBSTR(cFechPresS, 1, 4));

					RETURN cCodRet, TRIM(cDescError), cFechPresFinR, pNomArchivo, cNomOrd, cServ, cRef, mImp2, cCtaDest, cSec, cTpoCta, cBancDest, cFechOrig, cStatus,cSucursal WITH RESUME;

				END FOREACH;
			ELSE
				LET cCodRet = "02604"; -- ERROR EN LA ESTRUCTURA DEL NOMBRE DEL ARCHIVO
				EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
				RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, mImp2, cCtaDest, cSec, cTpoCta, cBancDest, cFechOrig, cStatus,cSucursal;
			END IF;
		ELSE
			LET cCodRet = "02605"; -- ERROR EN LA ASIGNACION DE PARAMETROS: NO SE PUEDE GENERAR POR ARCHIVO + FECHA(S) -- no se puede ejecutar nombre de archivo con fechaS
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
			RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, mImp2, cCtaDest, cSec, cTpoCta, cBancDest, cFechOrig, cStatus,cSucursal;
		END IF;

	ELIF iTipoOp = 2 OR iTipoOp = 5 THEN -- CONSULTA POR NOMBRE DEL PROCESO
		IF pfecini <> "" AND pfecfin <> "" THEN

			-- SE FORMATEAN LAS FECHAS RECIBIDAS PARA CAMBIARLAS A 'YYYYMMDD' (SIN DIAGONALES) PARA INCLUIRLAS EN EL WHERE
			LET cFecInicioW = SUBSTR(pfecini, 7, 4) || SUBSTR(pfecini, 1, 2) || SUBSTR(pfecini, 4, 2);
			LET cFecFinW = SUBSTR(pfecfin, 7, 4) || SUBSTR(pfecfin, 1, 2) || SUBSTR(pfecfin, 4, 2);

			IF pTpoProc = 2 THEN -- REPORTE PRESENTADO
				LET cTipoP = 'E';
			ELIF pTpoProc = 5 THEN -- REPORTE RECIBIDO
				LET cTipoP = 'S';
			END IF;

			IF NOT EXISTS (SELECT 1 FROM bdidomi:dom_cce_detalle WHERE cod_operacion = '30' AND fecha_presentacion BETWEEN cFecInicioW AND cFecFinW
																						    AND nombre_arch LIKE cTipoP || '%') THEN
				LET cCodRet = "02603"; -- EL ARCHIVO NO EXISTE
				EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
				RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, mImp2, cCtaDest, cSec, cTpoCta, cBancDest, cFechOrig, cStatus,cSucursal;
			END IF;
--det.num_cta_rec
			FOREACH WITH HOLD

				SELECT
					 TRIM(det.fecha_presentacion), TRIM(det.nombre_arch),
					 CASE WHEN SUBSTR(nombre_arch, 1,1) = 'E' THEN TRIM(det.nombre_ord) ELSE TRIM(det.nombre_rec) END,
					 TRIM(ser.razon_social), TRIM(det.ref_numerica), TRIM(det.importe), 
					 CASE WHEN SUBSTR(nombre_arch, 1,1) = 'E' THEN TRIM(det.num_cta_ord) ELSE TRIM(det.num_cta_rec) END,
					 TRIM(det.num_secuencia), TRIM(det.tipo_cta_rec),
					 CASE WHEN SUBSTR(nombre_arch, 1,1) = 'E' THEN TRIM(det.banco_receptor) ELSE TRIM(det.banco_receptor) END,
					 TRIM(det.fecha_pres_ini), TRIM(stap.descripcion), TRIM(det.cve_estatus),det.tipo_registro,det.num_secuencia
				INTO cFechPresS, cNomArch,
				     cNomOrd,
					 cServ, cRef, cImp, cCtaDest, cSec, cTipoCtaCod,
					 cBancDestCod,
					 cFechIniS, cStatus, cStat_val,cTipo_registro,cNum_secuencia
				FROM bdidomi:dom_cce_detalle det
				INNER JOIN bdidomi:dom_cat_servicios ser ON det.rfc_ord = ser.rfc
				INNER JOIN bdidomi:dom_status_pago stap ON det.cve_estatus = stap.cve_status
				WHERE cod_operacion = '34'
				AND fecha_presentacion BETWEEN cFecInicioW AND cFecFinW
				AND det.nombre_arch LIKE cTipoP || '%'

				SELECT TRIM(descripcion)
				INTO cTpoCta
				FROM bdidomi:dom_tipo_cta
				WHERE tipo_cta = cTipoCtaCod;
				
				SELECT TRIM(sucursal_sol)
				INTO cSucursal
				FROM bdidomi:dom_reversos
				WHERE nom_archivo_rev = cNomArch 
					AND fecha_presentacion_rev = cFechPresS
					AND tipo_registro = cTipo_registro
					AND num_secuencia = cNum_secuencia;

				SELECT TRIM(vchrnombrecorto)
				INTO cBancDest
				FROM bdinteg:si_bancos
				WHERE banco = cBancDestCod;

				LET mImp2 = cImp / 100;
				LET cFechOrig = TRIM(SUBSTR(cFechIniS, 7, 2) || '/' || SUBSTR(cFechIniS, 5, 2) || '/' || SUBSTR(cFechIniS, 1, 4));
				LET	cFechPresFinR = TRIM(SUBSTR(cFechPresS, 7, 2) || '/' || SUBSTR(cFechPresS, 5, 2) || '/' || SUBSTR(cFechPresS, 1, 4));

				RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, mImp2, cCtaDest, cSec, cTpoCta, cBancDest, cFechOrig, cStatus,cSucursal WITH RESUME;

			END FOREACH;

		ELSE
			LET cCodRet = '02606'; -- ERROR EN LA GENERACION DEL REPORTE POR TIPO DE PROCESO: FALTAN FECHA INICIO Y/O FECHA FINAL
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
			RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, mImp2, cCtaDest, cSec, cTpoCta, cBancDest, cFechOrig, cStatus,cSucursal;
		END IF;
	ELSE
		LET cCodRet = '02609'; -- TIPO DE OPERACION NO VALIDA PARA LA GENERACION DE REPORTES ARCHIVO 34 - VALORES 2 o 5
		EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
		RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, mImp2, cCtaDest, cSec, cTpoCta, cBancDest, cFechOrig, cStatus,cSucursal;
	END IF;
END
END PROCEDURE
DOCUMENT
'AUTOR: Clemente Angulo Ballardo',
'DESCRIPCION: Procedimiento que genera el reporte de los archivos codigo 34, ya sean presentados o recibidos',
'FECHA: 14/08/2009',
'VERSION: 20090814.1640',
'BD: Bdidomi',
'MODIFICO: Antonio Bastidas',
'DESCRIPCION: Se agrego el parametro de sucursal obtenido de la dom_reversos',
'FECHA: 24/08/2009',
'VERSION: 20090824.1115',
'BD: Bdidomi',
'Modifico: César Valdéz Figueroa',
'Descripcion: Se modificaron los filtros de obtenian la sucursal, ademas que se intercambiaron unos datos como banco ordenate por receptor',
'Fecha: 2009/09/27',
'Version: 20090929.1000',
'BD: BDIDOMI';

CREATE PROCEDURE "informix".sp_domi_genrepservicios (pServicio char(18),pSucursal char(4),pFechaIni char(10),pFechaFin char(10))
RETURNING char(6),char(80),char(10),char(20),char(80),char(20),char(60),char(4),char(20),money(16,2),smallint;
--RETURNING char(6),char(80),char(10),char(20),char(80),char(20),char(20),char(4),char(20),money(16,2),integer,integer,char(2);

-- VARIABLES PARA MANEJO DE ERRORES
DEFINE vcodRet 				char(6); 	 		-- CODIGO DE RETORNO
DEFINE vsqlerr 				integer;		 	-- VARIABLE PARA CACHAR EL CODIGO DE ERRORDEFINE vsqlerr integer;
DEFINE iIsamErr 			smallint;	 		-- VARIABLE PARA CACHAR EL CODIGO DE ERROR
DEFINE cErrorInfo 			char(80);  			-- VARIABLE PARA CACHAR LA DESCRIPCION DEL ERROR
DEFINE vErrorInfo 			char(80);	 		-- VARIABLE PARA RETORNAR EL MENSAJE DE ERROR O MENSAJE DE EXITO
DEFINE cCodRetMensaje		char(6);			-- CODIGO DE ERROR QUE REGRESA EL SP sp_obtenermensajeerror

-- VARIABLES PARA RETORNAR LOS VALORES
DEFINE cFechaAplica			char(10);			-- FECHA DE APLICACION
DEFINE cNumCte				char(20);			-- NUMERO DE CLIENTE
DEFINE cNomCte				char(80);			-- NOMBRE DEL CLIENTE
DEFINE cCuenta				char(20);			-- CUENTA
DEFINE cServicio			char(60);			-- SERVICIO
DEFINE cSucursal			char(4);			-- SUCURSAL
DEFINE cEstatus				char(20);			-- ESTATUS DEL SERVICIO
DEFINE mMontoMaximo			money(16,2);		-- MONTO MAXIMO
DEFINE cRFC					char(20);			-- RFC
DEFINE cMensaje				char(200);			-- RFC

-- VARIABLES DE AYUDA
DEFINE sNumReg				smallint;			-- PARA VER SI EXISTEN REGISTROS
DEFINE cFechaAux			char(10);			-- FECHA AUXILIAR
DEFINE sNumCve				smallint;			-- PARA CONTABILIZAR LOS REGISTROS EN EL REPORTE

LET vcodRet 				= '00000';
LET vsqlerr 				= 0;
LET iIsamErr 				= 0;
LET cErrorInfo 				= "";
LET vErrorInfo 				= "PROCESO EXITOSO";
LET cCodRetMensaje			= "";

LET cFechaAplica			= "";
LET cNumCte					= "";
LET cNomCte					= "";
LET cCuenta					= "";
LET cServicio				= "";
LET cSucursal				= "";
LET cEstatus				= "";
LET mMontoMaximo			= 0;

LET sNumReg					= 0;
LET cFechaAux				= "";
LET sNumCve					= 0;
LET cRFC					= '';

begin

	ON EXCEPTION  SET vsqlerr, iIsamErr, cErrorInfo
		IF vsqlerr <> 0  THEN
			LET  vCodRet  = vsqlerr;
			LET vErrorInfo = cErrorInfo;
			RETURN vCodRet, vErrorInfo,cFechaAplica,cNumCte,cNomCte,cCuenta,cServicio,cSucursal,cEstatus,mMontoMaximo,sNumCve;
		END IF;
	END  EXCEPTION


 --set debug file to "/tmp/Pulido/PRUEBAPUL.out";
 --trace on;


	SET ISOLATION DIRTY READ;
	SET LOCK MODE TO wait 4;
	
	if pServicio = "" or pSucursal = "" then
		LET vCodRet = '02611';
		CALL sp_obtenermensajeerror (vCodRet) RETURNING cCodRetMensaje,vErrorInfo;
		RETURN vCodRet, vErrorInfo,cFechaAplica,cNumCte,cNomCte,cCuenta,cServicio,cSucursal,cEstatus,mMontoMaximo,sNumCve;
	end if
	
	-- SE VALIDA SI SERVICIO Y SUCURSAL TRAEN EL VALOR "TODOS" ENTONCES SOLO SE FILTRA POR EL RANGO DE FECHAS
	if pServicio = "1" and pSucursal = "0000" then
		-- SE VALIDA SI EXISTEN REGISTROS EN LA TABLA CON LOSFILTROS SELECCIONADOS
		SELECT limit 1 fecha_estatus into cFechaAux from bdidomi:dom_autorizaciones where fecha_estatus between pFechaIni and pFechaFin;
		LET sNumReg=dbinfo("sqlca.sqlerrd2");
		if sNumReg > 0 then
			FOREACH
				select a.fecha_estatus,a.num_cte,trim(c.nombre1) || ' ' || trim(c.nombre2) || ' ' || trim(c.apell_paterno) || ' ' || trim(c.apell_materno) as Cliente,
					a.cuenta,nvl(s.razon_social,'') as servicio,a.cve_sucursal,
					(select descripcion from bdidomi:dom_cat_estatusaut where cve_estatus=a.cve_estatus) as Estatus,a.imp_maximo,1
				into cFechaAplica,cNumCte,cNomCte,cCuenta,cServicio,cSucursal,cEstatus,mMontoMaximo,sNumCve	
				from bdidomi:dom_autorizaciones a
					inner join bdinteg:si_cliente c on c.numcte=a.num_cte
					left join bdidomi:dom_cat_servicios s on s.rfc=a.rfc
				where a.fecha_estatus between pFechaIni and pFechaFin
				order by a.fecha_estatus
				
				RETURN vCodRet, vErrorInfo,cFechaAplica,cNumCte,cNomCte,cCuenta,cServicio,cSucursal,cEstatus,mMontoMaximo,sNumCve WITH RESUME;
				
			END FOREACH;
		else
			LET vCodRet = '02610';
			CALL sp_obtenermensajeerror (vCodRet) RETURNING cCodRetMensaje,vErrorInfo;
			RETURN vCodRet, vErrorInfo,cFechaAplica,cNumCte,cNomCte,cCuenta,cServicio,cSucursal,cEstatus,mMontoMaximo,sNumCve;
		
		end if;
		
		
	-- SE VALIDA SI SERVICIO ES DIFERENTE DE "TODOS" Y SUCURSAL TRAE EL VALOR "TODOS" ENTONCES SE FILTRA POR SERVICIO y RANGO DE FECHAS
	elif pServicio <> "1" and pSucursal = "0000" then
		--SE OBTIENE EL RFC DEL NOMBRE CORTO QUE SE RECIBE
		SELECT limit 1 rfc  INTO cRFC FROM bdidomi:dom_cat_servicios WHERE razon_social = TRIM(pServicio);
		-- SE VALIDA SI EXISTEN REGISTROS EN LA TABLA CON LOSFILTROS SELECCIONADOS
		SELECT limit 1 fecha_estatus into cFechaAux from bdidomi:dom_autorizaciones 
		where rfc = TRIM(cRFC) and fecha_estatus between pFechaIni and pFechaFin;
		LET sNumReg=dbinfo("sqlca.sqlerrd2");
		if sNumReg > 0 then
			FOREACH
				select a.fecha_estatus,a.num_cte,trim(c.nombre1) || ' ' || trim(c.nombre2) || ' ' || trim(c.apell_paterno) || ' ' || trim(c.apell_materno) as Cliente,
					a.cuenta,nvl(s.razon_social,'') as servicio,a.cve_sucursal,
					(select descripcion from bdidomi:dom_cat_estatusaut where cve_estatus=a.cve_estatus) as Estatus,a.imp_maximo,1
				into cFechaAplica,cNumCte,cNomCte,cCuenta,cServicio,cSucursal,cEstatus,mMontoMaximo,sNumCve
				from bdidomi:dom_autorizaciones a
					inner join bdinteg:si_cliente c on c.numcte=a.num_cte
					left join bdidomi:dom_cat_servicios s on s.rfc=a.rfc
				where s.rfc = TRIM(cRFC) and a.fecha_estatus between pFechaIni and pFechaFin
				order by a.fecha_estatus
				
				RETURN vCodRet, vErrorInfo,cFechaAplica,cNumCte,cNomCte,cCuenta,cServicio,cSucursal,cEstatus,mMontoMaximo,sNumCve WITH RESUME;
				
			END FOREACH;
		else
			LET vCodRet = '02610';
			CALL sp_obtenermensajeerror (vCodRet) RETURNING cCodRetMensaje,vErrorInfo;
			RETURN vCodRet, vErrorInfo,cFechaAplica,cNumCte,cNomCte,cCuenta,cServicio,cSucursal,cEstatus,mMontoMaximo,sNumCve;
		end if;
	-- SE VALIDA SI SUCURSAL ES DIFERENTE AL VALOR "TODOS" Y SERVICIO TRAE EL VALOR "TODOS" ENTONCES SE FILTRA POR SUCURSAL y RANGO DE FECHAS
	elif pServicio = "1" and pSucursal <> "0000" then
		-- SE VALIDA SI EXISTEN REGISTROS EN LA TABLA CON LOSFILTROS SELECCIONADOS
		SELECT limit 1 fecha_estatus into cFechaAux from bdidomi:dom_autorizaciones 
		where cve_sucursal = pSucursal and fecha_estatus between pFechaIni and pFechaFin;
		LET sNumReg=dbinfo("sqlca.sqlerrd2");
		if sNumReg > 0 then
			FOREACH
				select a.fecha_estatus,a.num_cte,trim(c.nombre1) || ' ' || trim(c.nombre2) || ' ' || trim(c.apell_paterno) || ' ' || trim(c.apell_materno) as Cliente,
					a.cuenta,nvl(s.razon_social,'') as servicio,a.cve_sucursal,
					(select descripcion from bdidomi:dom_cat_estatusaut where cve_estatus=a.cve_estatus) as Estatus,a.imp_maximo,1
				into cFechaAplica,cNumCte,cNomCte,cCuenta,cServicio,cSucursal,cEstatus,mMontoMaximo,sNumCve
				from bdidomi:dom_autorizaciones a
					inner join bdinteg:si_cliente c on c.numcte=a.num_cte
					left join bdidomi:dom_cat_servicios s on s.rfc=a.rfc
				where a.cve_sucursal = pSucursal and a.fecha_estatus between pFechaIni and pFechaFin
				order by a.fecha_estatus
				
				RETURN vCodRet, vErrorInfo,cFechaAplica,cNumCte,cNomCte,cCuenta,cServicio,cSucursal,cEstatus,mMontoMaximo,sNumCve WITH RESUME;
				
			END FOREACH;
		else
			LET vCodRet = '02610';
			CALL sp_obtenermensajeerror (vCodRet) RETURNING cCodRetMensaje,vErrorInfo;
			RETURN vCodRet, vErrorInfo,cFechaAplica,cNumCte,cNomCte,cCuenta,cServicio,cSucursal,cEstatus,mMontoMaximo,sNumCve;
		end if;
	
		
	-- SE VALIDA SI SUCURSAL Y SERVICIO SON DIFERENTES AL VALOR "TODOS" ENTONCES SE FILTRA POR SUCURSAL y RANGO DE FECHAS
	elif pServicio <> "1" and pSucursal <> "0000" then
		--SE OBTIENE EL RFC DEL NOMBRE CORTO QUE SE RECIBE
		SELECT limit 1 rfc  INTO cRFC FROM bdidomi:dom_cat_servicios WHERE razon_social = TRIM(pServicio);
		-- SE VALIDA SI EXISTEN REGISTROS EN LA TABLA CON LOS FILTROS SELECCIONADOS
		SELECT limit 1 fecha_estatus into cFechaAux from bdidomi:dom_autorizaciones 
		where rfc = TRIM(cRFC) and cve_sucursal = pSucursal and fecha_estatus between pFechaIni and pFechaFin;
		LET sNumReg=dbinfo("sqlca.sqlerrd2");
		if sNumReg > 0 then
			FOREACH
				select a.fecha_estatus,a.num_cte,trim(c.nombre1) || ' ' || trim(c.nombre2) || ' ' || trim(c.apell_paterno) || ' ' || trim(c.apell_materno) as Cliente,
					a.cuenta,nvl(s.razon_social,'') as servicio,a.cve_sucursal,
					(select descripcion from bdidomi:dom_cat_estatusaut where cve_estatus=a.cve_estatus) as Estatus,a.imp_maximo,1
				into cFechaAplica,cNumCte,cNomCte,cCuenta,cServicio,cSucursal,cEstatus,mMontoMaximo,sNumCve
				from bdidomi:dom_autorizaciones a
					inner join bdinteg:si_cliente c on c.numcte=a.num_cte
					left join bdidomi:dom_cat_servicios s on s.rfc=a.rfc
				where s.rfc = TRIM(cRFC) and a.cve_sucursal = pSucursal and a.fecha_estatus between pFechaIni and pFechaFin
				order by a.fecha_estatus
				
				RETURN vCodRet, vErrorInfo,cFechaAplica,cNumCte,cNomCte,cCuenta,cServicio,cSucursal,cEstatus,mMontoMaximo,sNumCve WITH RESUME;
				
			END FOREACH;
		else
			LET vCodRet = '02610';
			CALL sp_obtenermensajeerror (vCodRet) RETURNING cCodRetMensaje,vErrorInfo;
			RETURN vCodRet, vErrorInfo,cFechaAplica,cNumCte,cNomCte,cCuenta,cServicio,cSucursal,cEstatus,mMontoMaximo,sNumCve;
		end if;
		
	end if;

end;
END PROCEDURE
DOCUMENT
'AUTOR: Jose Luis Pulido Zepeda',
'Descripcion: Regresa los datos para el reporte de Servicios Domiciliarios',
'Fecha: 2009/08/19',
'Version: 20090819.1802',
'BD: BDIDOMI',

'Modifico: Jose Luis Pulido Zepeda',
'Descripcion: Se agrego ordenamiento por la fecha de aplicacion, un conteo de los diferentes estatus, mensajes de error controlados,',
			  'tambien se cambio el tipo de dato a char(10) a los parametros de entrada de fecha',
'Fecha: 2009/08/21',
'Version: 20090821.1003',
'BD: BDIDOMI',

'Modifico: Jose Luis Pulido Zepeda',
'Descripcion: Se cambio al valor que el SP toma para mostrar todos los registros para los filtros de servicio y sucursal,',
'			  para el filtro de servicio cuando se recibe el valor de 1 significa que se mostraran todos los servicios,',
'			  para el filtro de sucursal cuando se recibe el valor de 0000 significa que se mostraran todas las sucursales.',
'Fecha: 2009/08/24',
'Version: 20090824.0951',
'BD: BDIDOMI',

'Modifico: César Valdéz Figueroa',
'Descripcion: Se cambio para que cuando se fuera a filtrar por sucursal, se filtrara por el nombre corto que es lo que realmente recibe,',
'Fecha: 2009/09/24',
'Version: 20090924.1300',
'BD: BDIDOMI';

CREATE PROCEDURE  "informix".sp_domi_reportecargoscliente(pTipoConsulta CHAR(1),pNumcte CHAR(20),pFechaInicio CHAR(10),pFechaFin CHAR(10) )
	RETURNING CHAR(5),DATE, CHAR(20), MONEY(16,2),CHAR(40),CHAR(41),CHAR(20),CHAR(20),CHAR(20),CHAR(60),DATE,DATE;

---- VARIABLES  GENERALES---
DEFINE  cSqlerr				INTEGER;
DEFINE 	iExiste				INTEGER;
DEFINE 	dFecha_Ini			DATE;
DEFINE 	dFecha_Fin			DATE;
DEFINE 	dFechaCargo			DATE;
DEFINE	cEsFisica			CHAR(1);
DEFINE	cServicioDomi		CHAR(1);
DEFINE	cAutorizadoCteDomi	CHAR(1);
DEFINE	cTipper				CHAR(2);
DEFINE	cBancoPresentador	CHAR(3);
DEFINE	cBancoReceptor		CHAR(3);
DEFINE	cClaVeBancaria		CHAR(3);
DEFINE  cCodret     		CHAR(5);
DEFINE  cFechaFormarINI		CHAR(8);
DEFINE  cFechaFormarFIN		CHAR(8);
DEFINE  cFechaNac			CHAR(10);
DEFINE  cNumCte				CHAR(20);
DEFINE  cCuenta				CHAR(20);
DEFINE  cCuenta_clabe		CHAR(20);
DEFINE  cTarjeta			CHAR(20);
DEFINE 	cDescripcionEstatus CHAR(20);
DEFINE  cBanRecDescrip		CHAR(20);
DEFINE  cBanPresDescrip 	CHAR(20);
DEFINE  cRFC     			CHAR(18);
DEFINE  cRazon_social		CHAR(60);
DEFINE 	cDescripcionRechazo	CHAR(60);
DEFINE  cNombreCte     		CHAR(200);

DEFINE  cFecha_cargo		CHAR(8);
DEFINE 	cNCuenta			CHAR(20);
DEFINE  mImporte			MONEY(16,2);
DEFINE	cReferencia			CHAR(40);
DEFINE 	cBancosParticipantes CHAR(7);
DEFINE 	cEstatus			CHAR(20);
DEFINE 	cCausaRechazo		CHAR(20);


--VALORES INICIALES
LET cSqlerr 		= 0;
LET iExiste			= 0;
LET cCodret 		= '00000';
LET cNombreCte 		= '';
LET cRFC 			= '';
LET cRazon_social	= '';
LET cFechaNac		= '';
LET cTipper			= '';
LET cEsFisica		= '';
LET cServicioDomi 	= '';
LET cAutorizadoCteDomi	= '';
LET cDescripcionEstatus = '';
LET cDescripcionRechazo = '';
LET cBanPresDescrip	= '';
LET cBanRecDescrip	= '';
LET dFechaCargo		= '';
LET cClaVeBancaria	= '';
LET dFecha_Ini		= '';
LET dFecha_Fin		= '';
LET cBancoPresentador	= '';
LET cBancoReceptor	= '';
LET cFecha_cargo	= '';
LET cNCuenta		= '';
LET mImporte		= '';
LET cReferencia		= '';
LET cBancosParticipantes	= '';
LET cEstatus		= '';
LET cCausaRechazo	= '';

       --SET debug FILE TO "/tmp/ sp_Domi_ReporteCargosCliente.out";
       --Trace ON;

Begin
	------  Control de Errores no Controlados
    ON EXCEPTION SET cSqlerr
        IF cSqlerr <> 0 THEN
            Let cCodret = cSqlerr;
            RETURN cCodret,dFechaCargo,cNCuenta,mImporte,cReferencia,TRIM(cBanRecDescrip)|| ' / ' ||TRIM(cBanPresDescrip),cEstatus,cDescripcionEstatus,cCausaRechazo,cDescripcionRechazo,dFecha_Ini,dFecha_Fin;
        END IF;
    END EXCEPTION;
	IF pTipoConsulta = '' OR pNumcte = '' OR pFechaInicio = '' OR pFechaFin = ''  THEN
		LET cCodret = '02500';
		RETURN cCodret,dFechaCargo,cNCuenta,mImporte,cReferencia,TRIM(cBanRecDescrip)|| ' / ' ||TRIM(cBanPresDescrip),cEstatus,cDescripcionEstatus,cCausaRechazo,cDescripcionRechazo,dFecha_Ini,dFecha_Fin;
	END IF
		LET dFecha_Ini = pFechaInicio;
		LET dFecha_Fin = pFechaFin;
		LET cFechaFormarINI = YEAR(dFecha_Ini)||LPAD(MONTH(dFecha_Ini),2,'0')||LPAD(DAY(dFecha_Ini),2,'0');
		LET cFechaFormarFIN = YEAR(dFecha_Fin)||LPAD(MONTH(dFecha_Fin),2,'0')||LPAD(DAY(dFecha_Fin),2,'0');
	
		--	se extrae el valor del prefijo correspondiente a la cuenta de debito.
	SELECT valor INTO cClaVeBancaria FROM bdidomi:dom_parametros WHERE cod_param = '05';

	--	Valida que tenga un valor el prefijo correspondiente a la cuenta de debito.
	IF cClaVeBancaria = '' OR cClaVeBancaria IS NULL Then
		LET cCodRet = '02501';
		RETURN cCodret,dFechaCargo,cNCuenta,mImporte,cReferencia,TRIM(cBanRecDescrip)|| ' / ' ||TRIM(cBanPresDescrip),cEstatus,cDescripcionEstatus,cCausaRechazo,cDescripcionRechazo,dFecha_Ini,dFecha_Fin;
	END IF;
		
	  FOREACH WITH HOLD
		SELECT LPAD(TRIM(cuenta),20,'0'), LPAD(TRIM(cuenta_clabe),20,'0') INTO cCuenta,cCuenta_clabe  FROM bdicheq:sc_maechq WHERE num_cte = pNumcte
		
		SELECT LPAD(TRIM(num_tarjeta),20,'0') INTO cTarjeta FROM bdicheq:sc_tarjeta WHERE cuenta = cCuenta AND numcte = pNumcte;
		
		IF pTipoConsulta = 'P' THEN
		  FOREACH WITH HOLD
			SELECT Det.fecha_presentacion,Det.num_cta_ord,Det.importe/100,Det.ref_leyenda,Det.banco_receptor,Det.banco_presentador,Det.cve_estatus,sTatPago.descripcion ,Det.motivo_dev,Dev.descripcion
			INTO cFecha_cargo,cNCuenta,mImporte,cReferencia,cBancoReceptor,cBancoPresentador,cEstatus,cDescripcionEstatus,cCausaRechazo,cDescripcionRechazo
			FROM bdidomi:dom_cce_detalle AS Det
			INNER JOIN bdidomi:dom_status_pago AS sTatPago ON (Det.cve_estatus = sTatPago.cve_status)
			INNER JOIN bdidomi:dom_cat_devoluciones AS Dev ON (Det.motivo_dev = Dev.motivo_dev)
			WHERE Det.num_cta_ord IN (cCuenta,cCuenta_clabe,cTarjeta)
			AND Det.fecha_presentacion >= cFechaFormarINI
			AND Det.fecha_presentacion <= cFechaFormarFIN
			AND Det.banco_presentador = cClaVeBancaria
			ORDER BY Det.fecha_presentacion
			
			
			SELECT vchrnombrecorto INTO cBanRecDescrip FROM bdinteg:si_bancos WHERE banco = cBancoReceptor;
			SELECT vchrnombrecorto INTO cBanPresDescrip FROM bdinteg:si_bancos WHERE banco = cBancoPresentador;
			LET dFechaCargo = SUBSTR(cFecha_cargo,5,2)||'/'|| SUBSTR(cFecha_cargo,7,2) ||'/'|| SUBSTR(cFecha_cargo,1,4);
			
			RETURN cCodret,dFechaCargo,cNCuenta,mImporte,cReferencia,TRIM(cBanRecDescrip)|| ' / ' ||TRIM(cBanPresDescrip),cEstatus,cDescripcionEstatus,cCausaRechazo,cDescripcionRechazo,dFecha_Ini,dFecha_Fin WITH RESUME;		
  		  END FOREACH;
		END IF;
		
		IF pTipoConsulta = 'R' THEN
		  FOREACH WITH HOLD
			SELECT Det.fecha_presentacion,Det.num_cta_rec,Det.importe/100,Det.ref_leyenda,Det.banco_receptor,Det.banco_presentador,Det.cve_estatus,sTatPago.descripcion ,Det.motivo_dev,Dev.descripcion
			INTO cFecha_cargo,cNCuenta,mImporte,cReferencia,cBancoReceptor,cBancoPresentador,cEstatus,cDescripcionEstatus,cCausaRechazo,cDescripcionRechazo
			FROM bdidomi:dom_cce_detalle AS Det
			INNER JOIN bdidomi:dom_status_pago AS sTatPago ON (Det.cve_estatus = sTatPago.cve_status)
			INNER JOIN bdidomi:dom_cat_devoluciones AS Dev ON (Det.motivo_dev = Dev.motivo_dev)
			WHERE Det.num_cta_rec IN (cCuenta,cCuenta_clabe,cTarjeta)
			AND Det.fecha_presentacion >= cFechaFormarINI
			AND Det.fecha_presentacion <= cFechaFormarFIN
			AND Det.banco_receptor = cClaVeBancaria
			
			
			SELECT vchrnombrecorto INTO cBanRecDescrip FROM bdinteg:si_bancos WHERE banco = cBancoReceptor;
			SELECT vchrnombrecorto INTO cBanPresDescrip FROM bdinteg:si_bancos WHERE banco = cBancoPresentador;
			LET dFechaCargo = SUBSTR(cFecha_cargo,5,2)||'/'|| SUBSTR(cFecha_cargo,7,2) ||'/'|| SUBSTR(cFecha_cargo,1,4);
			
			RETURN cCodret,dFechaCargo,cNCuenta,mImporte,cReferencia,TRIM(cBanRecDescrip)|| ' / ' ||TRIM(cBanPresDescrip),cEstatus,cDescripcionEstatus,cCausaRechazo,cDescripcionRechazo,dFecha_Ini,dFecha_Fin WITH RESUME;		
		  END FOREACH;
		END IF;
	  END FOREACH;
END
END PROCEDURE
DOCUMENT
'AUTOR :Antonio Bastidas',
'DESCRIPCION:Consulta los cargos efectuados al cliente por domiciliacion',
'FECHA : 14 de Agosto de 2009',
'BD    : BDIDOMI',
'VERSION: 20090814.1005';

CREATE PROCEDURE "informix".sp_obtienesucursales()
returning char(5), char(4);

--DECLARACION DE VARIABLES
DEFINE sql_err 			  INTEGER;
DEFINE isam_err 		  INTEGER;
DEFINE error_info		  CHAR(80);
DEFINE cMensaje 		  CHAR(80);
DEFINE cCod_ret           CHAR(5);
DEFINE cSucursal          CHAR(4);
DEFINE cRazonCorto		  CHAR(20);

--INICIALIZACION DE VARIABLES
	LET cCod_ret      = '00000';
	LET sql_err       = 0;
	LET isam_err      = 0;
	LET error_info    = '';
	LET cMensaje      = '';
	LET cSucursal     = '';

BEGIN
    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensaje = error_info;
        RETURN cCod_ret, cSucursal;
    END EXCEPTION;

	--Set Debug File To '/tmp/sp_ObtieneSucursales.out';
	--Trace On;

	Foreach

		Select sucursal INTO cSucursal
		From bdinteg:si_sucursales
		WHERE tpo_sucursal='S'
		ORDER BY sucursal

		RETURN cCod_ret, cSucursal WITH RESUME;

	END FOREACH;

End;
End Procedure
DOCUMENT
'AUTOR      : Abigail Vasavilbazo Cañedo',
'DESCRIPCION: Obtiene las sucursales',
'Captacion',
'FECHA      : Agosto 2009',
'VERSION    : 20090812.1724',
'BD         : BDICHEQ';

CREATE PROCEDURE "informix".sp_parametrosdomi (pEmpresa CHAR(3),pNumEmpleado CHAR(9))
	RETURNING CHAR(5),CHAR(2),CHAR(2),CHAR(2),CHAR(100),CHAR(45),CHAR(30),DATE,CHAR(2);

	--Declaracion de variables		  
	DEFINE iSqlErr              INTEGER;
	DEFINE cCodRet              CHAR(5);
	DEFINE cLongitudCliente     CHAR(2);
	DEFINE cLongitudCuenta		char(2);
	DEFINE cCodMonNac           CHAR(2);
	DEFINE cPathRep             CHAR(100);
	DEFINE cNombreUsuario       CHAR(45);
	DEFINE cNombreEmpresa       CHAR(30);
	DEFINE dFecha_Hoy           DATE;
	DEFINE cSistema             CHAR(2);

	--Crea el archivo de monitoreo del proceso
	--SET DEBUG FILE TO "/tmp/sp_ParametrosDomi.out";
	--TRACE ON;

	--inicializacion de  variables
	LET cCodRet = '00000';
	LET cLongitudCliente = '';
	LET cLongitudCuenta = '';
	LET cCodMonNac = '';
	LET cPathRep = '';
	LET cNombreUsuario = '';
	LET cNombreEmpresa = '';
	LET dFecha_Hoy = '';
	LET cSistema = '';

	BEGIN
	--Crea el control de errores
		ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				RETURN cCodRet,cLongitudCliente,cLongitudCuenta,cCodMonNac,cPathRep,cNombreUsuario,cNombreEmpresa,dFecha_Hoy,cSistema;
			END IF;
		END EXCEPTION;
		
		--Se validan parametros de entrada
		IF ((pEmpresa = "") OR (pEmpresa IS NULL)) THEN
			LET cCodRet = '02612'; --Viene blanco o nulo el parametro de codigo de empresa.
			RETURN cCodRet,cLongitudCliente,cLongitudCuenta,cCodMonNac,cPathRep,cNombreUsuario,cNombreEmpresa,dFecha_Hoy,cSistema;		
		END IF;

		IF ((pNumEmpleado = "") OR (pNumEmpleado IS NULL)) THEN
			LET cCodRet = '02612'; --Viene en blanco o nulo el parametros de numero de empleado.
			RETURN cCodRet,cLongitudCliente,cLongitudCuenta,cCodMonNac,cPathRep,cNombreUsuario,cNombreEmpresa,dFecha_Hoy,cSistema;		
		END IF;

		IF LENGTH(pEmpresa)<> 3 Then
			LET cCodRet = '02612'; --No tiene la longitud correcta el paramtro de codigo de empresa.
			RETURN cCodRet,cLongitudCliente,cLongitudCuenta,cCodMonNac,cPathRep,cNombreUsuario,cNombreEmpresa,dFecha_Hoy,cSistema;		
		END IF;

		If LENGTH(pNumEmpleado)<> 8 Then
			LET cCodRet = '02612'; --No tiene la longitud correcta el paramtro de codigo de empresa.
			RETURN cCodRet,cLongitudCliente,cLongitudCuenta,cCodMonNac,cPathRep,cNombreUsuario,cNombreEmpresa,dFecha_Hoy,cSistema;		
		END IF;
						
		--Obtiene el valor longitud del numero de cliente		
		SELECT Trim(valor)
		INTO cLongitudCliente 
		FROM bdinteg:si_param 
		WHERE empresa = pEmpresa AND cod_param = 7; 

		--Obtiene longitud de cuenta cheques
		SELECT Trim(valor)
		INTO cLongitudCuenta 
		FROM bdicheq:sc_param 
		WHERE empresa = pEmpresa AND codparam = 'longcta'; 

		--Obtiene el valor codigo de la moneda nacional
		SELECT Trim(valor)
		INTO cCodMonNac 
		FROM bdinteg:si_param 
		WHERE empresa = pEmpresa AND cod_param = '15';

		 --Obtiene el valor path de reportes
		SELECT Trim(valor) 
		INTO cPathRep
		FROM bdidomi:dom_parametros 
		WHERE cod_param = '33';

		--Obtiene el nombre del usuario o ejecutivo
		SELECT nombre 
		INTO cNombreUsuario
		FROM bdinteg:si_ejecut
		WHERE ejecutivo = pNumEmpleado;
		 
		-- Obtiene el nombre de la empresa
		SELECT razon_social
		INTO cNombreEmpresa
		FROM bdinteg:si_empresas 
		WHERE empresa = pEmpresa;
		 
		-- OObtiene Fecha de integral para la Captura de Parametros
		SELECT fecha_hoy 
		INTO dFecha_Hoy
		FROM bdicheq:sc_fechas;

		--OObtiene codigo del sistema
		SELECT sistema
		INTO cSistema
		FROM bdinteg:si_sistema 
		WHERE siglas = 'DP';
		
		RETURN cCodRet,cLongitudCliente,cLongitudCuenta,cCodMonNac,cPathRep,cNombreUsuario,cNombreEmpresa,dFecha_Hoy,cSistema;
		
	END
	END PROCEDURE
	DOCUMENT
	'DESCRIPCION: Genera una consulta en las tablas si_param, si_ejecut,si_empresas,sc_fechas,si_sistema, dom_parametros', 
	'tomando como parametro o dato de entrada, la empresa y el numero de empleado para obtener datos del empleado',	
	'AUTOR: Abigail Vasavilbazo Cañedo ',
	'FECHA: Septiembre 2009',
	'VERSION: 20090901.1114',
	'BD: BDIDOMI';

CREATE PROCEDURE "informix".sp_domi_genrep30(pNomArchivo CHAR(20), pTpoProc INTEGER, pfecini CHAR(10), pfecfin CHAR(10))
RETURNING
         CHAR(5),       -- 001.- Codigo de Retorno
		 CHAR(130),     -- 002.- Descripcion del Error
		 CHAR(10),      -- 01.- Fecha Presentacion
		 CHAR(20),      -- 02.- Nombre Archivo
		 CHAR(40),      -- 03.- Nombre Ordenante
		 CHAR(60),      -- 04.- Servicio
		 CHAR(7),       -- 05.- Referencia Numerica
		 MONEY(15, 2),  -- 06.- Importe
		 CHAR(20),      -- 07.- Cuenta Destino
		 CHAR(7),       -- 08.- Sec
		 CHAR(20),      -- 09.- Tipo de Cuenta
		 CHAR(20),      -- 10.- Banco Destino
		 CHAR(20),      -- 11.- Estatus
		 CHAR(60),      -- 12.- Causa Rechazo
		 CHAR(2);       -- 13.- Codigo de Respuesta

-- Declaracion de Variables
DEFINE iSQLerr        INTEGER;
DEFINE cCodRet        CHAR(5);        -- 001
DEFINE cDescError     CHAR(130);      -- 002
DEFINE cFechPresFinR  CHAR(10);       -- 01
DEFINE cNomArch       CHAR(20);       -- 02
DEFINE cNomOrd        CHAR(40);       -- 03
DEFINE cServ          CHAR(60);       -- 04
DEFINE cRef           CHAR(7);        -- 05
DEFINE mImp2          MONEY(15, 2);   -- 06
DEFINE cCtaDest       CHAR(20);       -- 07
DEFINE cSec           CHAR(7);        -- 08
DEFINE cTpoCta        CHAR(20);       -- 09
DEFINE cBancDest      CHAR(20);       -- 10
DEFINE cStatus        CHAR(20);       -- 11
DEFINE cCausaRech     CHAR(60);       -- 12
DEFINE cCodResp       CHAR(2);        -- 13
DEFINE cImp           CHAR(15);
DEFINE cFechPresS	  CHAR(8);
DEFINE cFecInicioW    CHAR(8);
DEFINE cFecFinW       CHAR(8);
DEFINE cTipoP         CHAR(1);
DEFINE cStat_val      CHAR(2);
DEFINE cTipoCtaCod    CHAR(30);
DEFINE cCodRet2       CHAR(5);
DEFINE cBancDestCod   CHAR(3);
DEFINE iTipoOp        INTEGER;
DEFINE cClave_Rastreo CHAR(30);



ON EXCEPTION SET iSQLerr
	IF iSQLerr <> 0 THEN
		LET cCodRet = iSQLerr;
		EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
		RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, cImp, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp;
	END IF;
END EXCEPTION;

--	SET DEBUG FILE TO "/tmp/sp_domi_genrep30.out";
--	TRACE ON;	

-- Inicializacion de Variables
LET iSQLerr        = 0;
LET cCodRet        = "00000"; -- 001
LET cDescError     = "";      -- 002
LET cFechPresFinR  = "";      -- 01
LET cNomArch       = "";      -- 02
LET cNomOrd        = "";      -- 03
LET cServ          = "";      -- 04
LET cRef           = "";      -- 05
LET mImp2          = 0.00;    -- 06
LET cCtaDest       = "";      -- 07
LET cSec           = "";      -- 08
LET cTpoCta        = "";      -- 09
LET cBancDest      = "";      -- 10
LET cStatus        = "";      -- 11
LET cCausaRech     = "";      -- 12
LET cCodResp       = "";      -- 13
LET cImp           = "";
LET cFechPresS	   = "";
LET cFecInicioW    = "";
LET cFecFinW       = "";
LET cTipoP         = "";
LET cStat_val      = "";
LET cTipoCtaCod    = "";
LET cCodRet2       = "";
LET cDescError     = "";
LET cBancDestCod   = "";
LET iTipoOp        = 0;
LET cClave_Rastreo = "";

BEGIN

	IF pfecini = "01/01/1900" OR pfecfin = "01/01/1900" THEN
		LET pfecini = "";
		LET pfecfin = "";		
	END IF;	
	
	IF ((pTpoProc = "") OR (pTpoProc IS NULL)) THEN	
		LET iTipoOp = -1;		
	ELSE
		LET iTipoOp = pTpoProc;		
	END IF;
	
	IF ((pfecini IS NULL) OR (pfecfin IS NULL)) THEN			
		LET pfecini = "";
		LET pfecfin = "";
	ELSE		
		LET pfecini = pfecini;
		LET pfecfin = pfecfin;
	END IF;
	
	SET ISOLATION DIRTY READ;
	SET LOCK MODE TO wait 4;

	IF pNomArchivo = "" AND iTipoOp = -1 THEN 
		LET cCodRet = "02600"; -- FALTAN PARAMETROS: NOMBRE DEL ARCHIVO O TIPO DE PROCESO
		EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
		RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, cImp, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp;
	END IF;	
	
	IF (pNomArchivo <> "") AND (iTipoOp >= 0) THEN -- CON EL NOMBRE DEL ARCHIVO Y  TIPO DE PROCESO
		LET cCodRet = "02601"; -- ERROR EN LA ASIGNACION DE PARAMETROS: NO SE PUEDE GENERAR POR NOMBRE + TIPO DE PROCESO
		EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
		RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, cImp, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp;
	END IF;
	
	IF pNomArchivo <> "" AND iTipoOp = -1 THEN -- CONSULTA POR NOMBRE DEL ARCHIVO
		IF pfecini = "" AND pfecfin = "" THEN
			IF (SUBSTR(pNomArchivo, 1, 1) = 'E' AND SUBSTR(pNomArchivo, 14, 2) = 30 AND LENGTH(pNomArchivo) = 17) OR
			   (SUBSTR(pNomArchivo, 1, 1) = 'S' AND SUBSTR(pNomArchivo, 11, 2) = 30 AND LENGTH(pNomArchivo) = 16) THEN
				
				IF NOT EXISTS (SELECT 1 FROM bdidomi:dom_cce_detalle WHERE nombre_arch = pNomArchivo) THEN 
						LET cCodRet = "02602"; -- EL ARCHIVO NO EXISTE
						EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
						RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, cImp, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp;
				END IF;
	
				FOREACH WITH HOLD	
				
					SELECT 
						 TRIM(det.fecha_presentacion), TRIM(nombre_rec), TRIM(ser.razon_social), TRIM(det.ref_numerica),				
						 TRIM(det.importe), TRIM(det.num_cta_rec), TRIM(det.num_secuencia), TRIM(det.tipo_cta_rec),
						 CASE WHEN SUBSTR(pNomArchivo, 1,1) = 'E' THEN TRIM(det.banco_receptor) ELSE TRIM(det.banco_presentador) END,
						 TRIM(stap.descripcion), TRIM(dev.descripcion), TRIM(det.cve_estatus), det.clave_rastreo
					INTO cFechPresS, cNomOrd, cServ, cRef,
					     cImp, cCtaDest, cSec, cTipoCtaCod, 
						 cBancDestCod, 
						 cStatus, cCausaRech, cStat_val, cClave_Rastreo
					FROM bdidomi:dom_cce_detalle det
					INNER JOIN bdidomi:dom_cat_servicios ser ON det.rfc_ord = ser.rfc
					INNER JOIN bdidomi:dom_cat_devoluciones dev ON det.motivo_dev = dev.motivo_dev
					INNER JOIN bdidomi:dom_status_pago stap ON det.cve_estatus = stap.cve_status			
					WHERE nombre_arch = pNomArchivo
					AND cod_operacion = '30'
						LET cCodResp = '';
					SELECT TRIM(descripcion)
					INTO cTpoCta
					FROM bdidomi:dom_tipo_cta
					WHERE tipo_cta = cTipoCtaCod;
					
					SELECT TRIM(vchrnombrecorto)
					INTO cBancDest
					FROM bdinteg:si_bancos
					WHERE banco = cBancDestCod;
								
					IF cStat_val = '01' THEN
						LET cCodResp = '32';
						LET cCausaRech = "";
					ELIF cStat_val = '02' THEN
						LET cCodResp = '31';
					ELIF cStat_val = '03' OR cStat_val = '00' THEN
						LET cCodResp = "";
						LET cCausaRech = "";
					END IF;
					
					IF cCodResp = '31' THEN
						SELECT dev.descripcion 
						INTO cCausaRech
						FROM bdidomi:dom_cce_detalle AS det,bdidomi:dom_cat_devoluciones AS dev 
						WHERE clave_rastreo = cClave_Rastreo
						AND cod_operacion = '31'
						AND det.motivo_dev = dev.motivo_dev;
					END IF;
					
					LET mImp2 = cImp / 100;					
					LET	cFechPresFinR = TRIM(SUBSTR(cFechPresS, 7, 2) || '/' || SUBSTR(cFechPresS, 5, 2) || '/' || SUBSTR(cFechPresS, 1, 4));
					
					RETURN cCodRet, TRIM(cDescError), cFechPresFinR, pNomArchivo, cNomOrd, cServ, cRef, mImp2, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp WITH RESUME;
					
				END FOREACH;
			ELSE
				LET cCodRet = "02604"; -- ERROR EN LA ESTRUCTURA DEL NOMBRE DEL ARCHIVO
				EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
				RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, cImp, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp;
			END IF;
		ELSE
			LET cCodRet = "02605"; -- ERROR EN LA ASIGNACION DE PARAMETROS: NO SE PUEDE GENERAR POR ARCHIVO + FECHA(S) -- no se puede ejecutar nombre de archivo con fechaS
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
			RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, cImp, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp;
		END IF;		
			
	ELIF iTipoOp = 1 OR iTipoOp = 4 THEN -- CONSULTA POR NOMBRE DEL PROCESO		
		IF pfecini <> "" AND pfecfin <> "" THEN 
		
			-- SE FORMATEAN LAS FECHAS RECIBIDAS PARA CAMBIARLAS A 'YYYYMMDD' (SIN DIAGONALES) PARA INCLUIRLAS EN EL WHERE
			LET cFecInicioW = SUBSTR(pfecini, 7, 4) || SUBSTR(pfecini, 1, 2) || SUBSTR(pfecini, 4, 2);
			LET cFecFinW = SUBSTR(pfecfin, 7, 4) || SUBSTR(pfecfin, 1, 2) || SUBSTR(pfecfin, 4, 2);
		
			IF pTpoProc = 1 THEN -- REPORTE PRESENTADO
				LET cTipoP = 'E';
			ELIF pTpoProc = 4 THEN -- REPORTE RECIBIDO
				LET cTipoP = 'S';			
			END IF;
			
			IF NOT EXISTS (SELECT 1 FROM bdidomi:dom_cce_detalle WHERE cod_operacion = '30' AND fecha_presentacion BETWEEN cFecInicioW AND cFecFinW
																						    AND nombre_arch LIKE cTipoP || '%') THEN
				LET cCodRet = "02603"; -- EL ARCHIVO NO EXISTE
				EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
				RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, cImp, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp;
			END IF;
				
			FOREACH WITH HOLD
			
				SELECT		
					 TRIM(det.fecha_presentacion), TRIM(nombre_arch), TRIM(nombre_rec), TRIM(ser.razon_social), TRIM(det.ref_numerica),				
					 TRIM(det.importe), TRIM(det.num_cta_rec), TRIM(det.num_secuencia), TRIM(det.tipo_cta_rec),
					 CASE WHEN SUBSTR(nombre_arch, 1,1) = 'E' THEN TRIM(det.banco_receptor) ELSE TRIM(det.banco_presentador) END,
					 TRIM(stap.descripcion), TRIM(dev.descripcion), TRIM(det.cve_estatus), det.clave_rastreo
				INTO cFechPresS, cNomArch, cNomOrd, cServ, cRef,
				     cImp, cCtaDest, cSec, cTipoCtaCod, 
					 cBancDestCod, 
					 cStatus, cCausaRech, cStat_val, cClave_Rastreo
				FROM bdidomi:dom_cce_detalle det
				INNER JOIN bdidomi:dom_cat_servicios ser ON det.rfc_ord = ser.rfc			
				INNER JOIN bdidomi:dom_cat_devoluciones dev ON det.motivo_dev = dev.motivo_dev
				INNER JOIN bdidomi:dom_status_pago stap ON det.cve_estatus = stap.cve_status
				WHERE cod_operacion = '30'
				AND fecha_presentacion BETWEEN cFecInicioW AND cFecFinW
				AND nombre_arch LIKE cTipoP || '%'
				
				SELECT TRIM(descripcion)
				INTO cTpoCta
				FROM bdidomi:dom_tipo_cta
				WHERE tipo_cta = cTipoCtaCod;
				
				SELECT TRIM(vchrnombrecorto)
				INTO cBancDest
				FROM bdinteg:si_bancos
				WHERE banco = cBancDestCod;
				
				IF cStat_val = '01' THEN
					LET cCodResp = '32';
					LET cCausaRech = "";
				ELIF cStat_val = '02' THEN
					LET cCodResp = '31';
				ELIF cStat_val = '03' OR cStat_val = '00' THEN
					LET cCodResp = "";
					LET cCausaRech = "";
				END IF;
				
				IF cCodResp = '31' THEN
					SELECT dev.descripcion 
					INTO cCausaRech
					FROM bdidomi:dom_cce_detalle AS det,bdidomi:dom_cat_devoluciones AS dev 
					WHERE clave_rastreo = cClave_Rastreo
					AND cod_operacion = '31'
					AND det.motivo_dev = dev.motivo_dev;
				END IF;
				
				LET mImp2 = cImp / 100;				
				LET	cFechPresFinR = TRIM(SUBSTR(cFechPresS, 7, 2) || '/' || SUBSTR(cFechPresS, 5, 2) || '/' || SUBSTR(cFechPresS, 1, 4));
				
				RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, mImp2, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp WITH RESUME;
			
			END FOREACH;
		ELSE
			LET cCodRet = '02606'; -- ERROR EN LA GENERACION DEL REPORTE POR TIPO DE PROCESO: FALTAN FECHA INICIO Y/O FECHA FINAL
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
			RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, cImp, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp;
		END IF;	
	ELSE
		LET cCodRet = '02608'; -- TIPO DE OPERACION NO VALIDA PARA LA GENERACION DE REPORTES ARCHIVO 30 - VALORES 1 o 4
		EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
		RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, cImp, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp;
	END IF;	
END
END PROCEDURE
DOCUMENT
'AUTOR: Clemente Angulo Ballardo',
'DESCRIPCION: Procedimiento que genera el reporte de los archivos codigo 30, ya sean presentados o recibidos',
'FECHA: 13/08/2009',
'VERSION: 20090813.1730',
'BD: Bdidomi',

'MODIFICO: Cesar Valdez Figueroa',
'DESCRIPCION: para que regresara la descrimcion del codigo 31',
'FECHA: 10/11/2009',
'VERSION: 20091110.1200',
'BD: Bdidomi';

create procedure "informix".sp_altachequeras( pempresa char(3), --Empresa
                                            pcuenta  char(20), -- Cuenta
                                            pcanal   smallint, --Canal 1 OFI, 2 (CAT, Internet)
                                            ptipo    Char(2),   -- Tipo de Chequera
                                            pusuario Char(8)    --Usuario
                                            )
       returning     char(5);   -- vcodret

   -- ********************************************************************
   --
   -- Nombre:              sp_altachequeras
   --
   -- Version              1.0.0
   -- Objetivo:            Alta de  chequeras.........................
   -- Supuestos:           Ninguno
   -- Creado por:          Jorge Arango
   -- Ultima Modificacion: Octubre  - 2009
   --
   --                      Reingenieria de SPL
   --
   -- ********************************************************************

   -- // Definicion de variables
   DEFINE vcodret         char(5);
   DEFINE vcodreterr      char(5);
   DEFINE vsqlerr         integer;
   DEFINE vno_cheques     smallint;
   DEFINE vconsec         integer;
   DEFINE v_hoy           date;
   DEFINE v_sucursal      char(4);
   DEFINE v_status        char(1);
   DEFINE v_valor         char(1);
   DEFINE v_inicial       INTEGER;
   DEFINE v_final         INTEGER;
   DEFINE a               SMALLINT;
   DEFINE vnumchq         INTEGER;
   DEFINE vnumactivos     INTEGER;
   DEFINE vmaxpermite     INTEGER;
   DEFINE vdummy          char(100);
   DEFINE vdummy1         char(100);
   define vfecha   	DATETIME hour TO second;
   define vfecha1 		char(8);
   define vhora         char(10);




   LET vcodret      = " ";
   LET vno_cheques  = " ";
   LET vsqlerr      = 0;
   LET v_status     = " ";
   LET vno_cheques  = 0;
   LET vconsec      = 0;
   LET v_sucursal   = " ";
   LET v_status     = " ";
   LET v_inicial    = 0;
   LET v_final      = 0;
   LET a            = 0;
   LET v_valor      = " ";
   LET vnumchq      = 0;
   LET vmaxpermite  = 0;
   LET vdummy      = " ";
   LET vdummy1     = " ";
   LET vfecha1     = current hour to second;
   LET vhora       = vfecha1; --trim(vfecha1[1,2])|":"|trim(vfecha1[4,5]);
   



   --SET DEBUG FILE TO "/tmp/sp_altachequeras.out";
   --TRACE ON;

begin
    on exception set vsqlerr
       IF vsqlerr <> 0 then
          LET vcodret = vsqlerr;
          return vcodret;
       END IF;
    end exception;

   --- Selecciona la fecha del dia.
   SELECT fecha_hoy INTO v_hoy FROM bdicheq:sc_fechas;

   --Validaciones de nulos en parametros de entrada
   if pempresa = " " or pcuenta = " " or pcanal = 0 then
      let vcodret = "001";
      call sp_errores( v_hoy, vhora, pcuenta, "001","sp_altachequeras","Error en Parametros de Entrada Nulos",pusuario);
      return vcodret;
   end if

   --- Selecciona el numero de cheques por tipo de chequera.
   If ptipo = " " then
       select valor into ptipo
       from sq_param
       where cod_param = 2;
   end if

   --- Selecciona el numero de cheques por tipo de chequera.
   select valor into vmaxpermite
     from sq_param
    where cod_param = 3;

   select no_cheques
   into vno_cheques
   from bdicntchq:sq_chequera
   where chequera = ptipo;

   if vno_cheques is null  then
      let vcodret = "002";
      call sp_errores( v_hoy, vhora, pcuenta, "002","sp_altachequeras","Error al Consultar el Tipo de Chequera",pusuario);
      return vcodret;
   end if

   --- Selecciona el numero maximo de cheques.
   select max(numero)
     into vnumchq
     from bdicheq:sc_contch
    WHERE empresa = pempresa
      and cuenta = pcuenta;

   if vnumchq is null then
      let vnumchq = 1;
   else
      let vnumchq =  vnumchq + 1;
   end if

   --validacion de chequera maxima
   select max(consec)
   into vconsec
   from bdicntchq:sq_maechqra
   where cuenta = pcuenta;

   --Si la chequera es mayor o igual a 1 y el canal es OFI Regreso codigo de error
   If (vconsec >= 1 and pcanal = 1) or (vconsec is null and pcanal = 2) then
      let vcodret = "004";
      call sp_errores( v_hoy, vhora, pcuenta, "004","sp_altachequeras","Error Existen Chequeras Asignadas a esta Cuenta, No Puede Darse de Alta Como Nueva",pusuario);
      return vcodret;
   end if

   if vconsec is null then
      let vconsec = 1;
   else
      let vconsec =  vconsec + 1;
   end if

   --Se trae el numero de sucursal
   SELECT sucursal, status_cta
   INTO v_sucursal, v_status
   FROM bdicheq:sc_maechq
   WHERE cuenta = pcuenta;

   --Valida el status de la cuenta
--   IF v_status <> "1" THEN
   IF v_status = "2" THEN
      LET vcodret = "005";
      call sp_errores( v_hoy, vhora, pcuenta, "005","sp_altachequeras","Error la Cuenta no Esta Activa",pusuario);
      RETURN vcodret;
   END IF

   --Inicia proceso de actualizacion de Datos

   LET v_inicial = vnumchq;
   LET v_final   = vnumchq + vno_cheques;

   If pcanal = 1 then


      INSERT INTO bdicntchq:sq_maechqra(empresa, cuenta, consec, inicial, final, fecha_req, fecha_rec, fecha_ent, status, proveedor, sucursal, usuario)
       VALUES(pempresa, pcuenta, vconsec, v_inicial, v_final, v_hoy, " ", " ",
              'S', '000', v_sucursal, pusuario);

      -- Inserta requerimiento de chequeras
       FOR a = vnumchq TO v_final

           INSERT INTO bdicheq:sc_contch(empresa, cuenta, numero, estado, fecha_alta, importe, consec)
           VALUES(pempresa, pcuenta, a, "S", v_hoy, 0, vconsec);

       END FOR
       let vcodret = "000";
       return vcodret;

   elif pcanal = 2 then

   --- Validacion de Cheque Activo.

       select count(numero)
       into vnumactivos
       from bdicheq:sc_contch
       where cuenta = pcuenta
       and   empresa = pempresa
       and estado = "A";

       if vnumactivos > vmaxpermite then
           let vcodret = "003";
           call sp_errores( v_hoy, vhora, pcuenta, "003","sp_altachequeras","Error el Numero de Cheques Activos, Supera los Permitidos",pusuario);
           return vcodret;
       end if

      INSERT INTO bdicntchq:sq_maechqra(empresa, cuenta, consec, inicial, final, fecha_req, fecha_rec, fecha_ent, status, proveedor, sucursal, usuario)
       VALUES(pempresa, pcuenta, vconsec, v_inicial, v_final, v_hoy, " ", " ",
              'S', '000', v_sucursal, pusuario);

      -- Inserta requerimiento de chequeras
       FOR a = vnumchq TO v_final

           INSERT INTO bdicheq:sc_contch(empresa, cuenta, numero, estado, fecha_alta, importe, consec)
           VALUES(pempresa, pcuenta, a, "S", v_hoy, 0, vconsec);

       END FOR
       let vcodret = "000";
       return vcodret;
   end if
end
end procedure;