CREATE PROCEDURE "informix".sp_domi_genrep342(pNomArchivo CHAR(20), pTpoProc INTEGER, pfecini CHAR(10), pfecfin CHAR(10), pregistros INTEGER, precuperacion INTEGER)
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

					SELECT SKIP pregistros FIRST precuperacion
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

				SELECT SKIP pregistros FIRST precuperacion
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
'Modifico: CÃ©sar ValdÃ©z Figueroa',
'Descripcion: Se modificaron los filtros de obtenian la sucursal, ademas que se intercambiaron unos datos como banco ordenate por receptor',
'Fecha: 2009/09/27',
'Version: 20090929.1000',
'BD: BDIDOMI';

CREATE PROCEDURE "informix".sp_domi_genrepservicios2 (pServicio char(18),pSucursal char(4),pFechaIni char(10),pFechaFin char(10), pregistros INTEGER, precuperacion INTEGER)
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
				select skip pregistros first precuperacion a.fecha_estatus,a.num_cte,trim(c.nombre1) || ' ' || trim(c.nombre2) || ' ' || trim(c.apell_paterno) || ' ' || trim(c.apell_materno) as Cliente,
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
				select skip pregistros first precuperacion a.fecha_estatus,a.num_cte,trim(c.nombre1) || ' ' || trim(c.nombre2) || ' ' || trim(c.apell_paterno) || ' ' || trim(c.apell_materno) as Cliente,
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
				select skip pregistros first precuperacion a.fecha_estatus,a.num_cte,trim(c.nombre1) || ' ' || trim(c.nombre2) || ' ' || trim(c.apell_paterno) || ' ' || trim(c.apell_materno) as Cliente,
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
				select skip pregistros first precuperacion a.fecha_estatus,a.num_cte,trim(c.nombre1) || ' ' || trim(c.nombre2) || ' ' || trim(c.apell_paterno) || ' ' || trim(c.apell_materno) as Cliente,
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

'Modifico: CÃ©sar ValdÃ©z Figueroa',
'Descripcion: Se cambio para que cuando se fuera a filtrar por sucursal, se filtrara por el nombre corto que es lo que realmente recibe,',
'Fecha: 2009/09/24',
'Version: 20090924.1300',
'BD: BDIDOMI';

CREATE PROCEDURE "informix".sp_domi_subirarchivosproveedor(p_NombreArchivo VARCHAR(23), p_FechaEnvio DATE, p_NumCte VARCHAR(20), p_FechaCarga DATE, p_CveStatus CHAR(2), p_Usuario CHAR(8))
RETURNING
	CHAR(5), ---cod_ret
	CHAR(80); ---descripcion

	---DECLARACIONES
    DEFINE v_cod_ret            	CHAR(5);
    DEFINE iSqlErr              	INTEGER;
    DEFINE iSamErr              	INTEGER;

	DEFINE sDescMensajeError		VARCHAR(95);
	DEFINE sRuta					CHAR(100);
	DEFINE sCadSql					LVARCHAR(1000);
	DEFINE sLinea					LVARCHAR(500);
	DEFINE bBandArchivo				BOOLEAN;
	DEFINE iNumCaracteres			INTEGER;
	DEFINE iContador				SMALLINT;
	DEFINE iNumReg					INTEGER;

	DEFINE sEncTipoReg				CHAR(1);
	DEFINE sEncNumCte				CHAR(20);
	DEFINE sEncCtaAbono				CHAR(20);
	DEFINE sEncNumOper				CHAR(8);
	DEFINE sEncFechaIni				CHAR(8);
	DEFINE sEncFechaFin				CHAR(8);

	DEFINE sDetTipoReg				CHAR(1);
	DEFINE sDetConsecutivo			CHAR(6);
	DEFINE sDetFechaCargo			CHAR(8);
	DEFINE sDetFechaAbono			CHAR(8);
	DEFINE sDetTipoCtaCargo			CHAR(2);
	DEFINE sDetCveBancoCargo		CHAR(3);
	DEFINE sDetCtaCargo				CHAR(20);
	DEFINE sDetRFC_Cargo			CHAR(13);
	DEFINE sDetNomCargo				CHAR(50);
	DEFINE sDetCtaAbono				CHAR(20);
	DEFINE sDetImpOper				CHAR(15);
	DEFINE sDetImpIva				CHAR(15);
	DEFINE sDetRefNumerica			CHAR(7);
	DEFINE sDetRefLeyenda			CHAR(40);
	DEFINE sDetRefServicio			CHAR(40);
	DEFINE sDetRefTituServ			CHAR(40);
	DEFINE sDetAccion				CHAR(1);
	DEFINE sDetReintentarCta		CHAR(1);
	DEFINE sDetEstatus				CHAR(2);
	DEFINE sDetCausaRechazo			CHAR(50);

	DEFINE sSumTipoReg				CHAR(1);
	DEFINE sSumNumOper				CHAR(8);
	DEFINE sSumImpOper				CHAR(18);
	DEFINE sSumNumOperPend			CHAR(8);
	DEFINE sSumImpOperPend			CHAR(18);
	DEFINE sSumNumOperApli			CHAR(8);
	DEFINE sSumImpOperApli			CHAR(18);
	DEFINE sSumNumOperRecha			CHAR(8);
	DEFINE sSumImpOperRecha			CHAR(18);

	DEFINE sDia						CHAR(2);
	DEFINE sMes						CHAR(2);
	DEFINE sAnio					CHAR(4);

	DEFINE cHora					CHAR(8);
	DEFINE cFechaArchivoOUT			CHAR(15);
	DEFINE iTemporales				SMALLINT;
	DEFINE iPaso					SMALLINT;
	DEFINE cRutaIfx					CHAR(100);
	---INICIALIZACIONES
	LET v_cod_ret = '00000';
	LET sDescMensajeError	= "";
	LET sRuta						= "";
	LET sLinea						= "";
	LET sDescMensajeError			= "";
	LET bBandArchivo				= "f";
	LET iNumCaracteres				= 0;
	LET iContador					= 0;
	LET iNumReg						= 0;

	LET sEncTipoReg					= "";
	LET sEncNumCte					= "";
	LET sEncCtaAbono				= "";
	LET sEncNumOper					= "";
	LET sEncFechaIni				= "";
	LET sEncFechaFin				= "";

	LET sDetTipoReg					= "";
	LET sDetConsecutivo				= "";
	LET sDetFechaCargo				= "";
	LET sDetFechaAbono				= "";
	LET sDetTipoCtaCargo			= "";
	LET sDetCveBancoCargo			= "";
	LET sDetCtaCargo				= "";
	LET sDetRFC_Cargo				= "";
	LET sDetNomCargo				= "";
	LET sDetCtaAbono				= "";
	LET sDetImpOper					= "";
	LET sDetImpIva					= "";
	LET sDetRefNumerica				= "";
	LET sDetRefLeyenda				= "";
	LET sDetRefServicio				= "";
	LET sDetRefTituServ				= "";
	LET sDetAccion					= "";
	LET sDetReintentarCta			= "";
	LET sDetEstatus					= "";
	LET sDetCausaRechazo			= "";

	LET sSumTipoReg					= "";
	LET sSumNumOper					= "";
	LET sSumImpOper					= "";
	LET sSumNumOperPend				= "";
	LET sSumImpOperPend				= "";
	LET sSumNumOperApli				= "";
	LET sSumImpOperApli				= "";
	LET sSumNumOperRecha			= "";
	LET sSumImpOperRecha			= "";

	LET sDia						= "";
	LET sMes						= "";
	LET sAnio						= "";

	LET cHora						= TO_CHAR(EXTEND(CURRENT, HOUR TO SECOND),'%H:%M:%S');
	LET cFechaArchivoOUT			= YEAR(CURRENT::DATE)||LPAD(MONTH(CURRENT::DATE),2,'0')||LPAD(DAY(CURRENT::DATE),2,'0')||SUBSTR(cHora,1,2)||SUBSTR(cHora,4,2)||SUBSTR(cHora,7,2)||'_';
	LET iTemporales					= 0;
	LET iPaso						= 0;
	LET cRutaIfx	= '';
	
BEGIN

	ON EXCEPTION
        SET iSqlErr, iSamErr
        IF iSqlErr <> 0 THEN
            LET v_cod_ret = iSqlErr;
        END IF;

        RETURN v_cod_ret, NULL;
    END EXCEPTION;

	ON EXCEPTION IN(-668) SET iSqlErr
		IF  iPaso NOT IN (4,5,6,9,10) THEN 
			LET v_cod_ret = iSqlErr;
			RETURN v_cod_ret,NULL;
		END IF;
		
	END EXCEPTION WITH RESUME;
	--SET DEBUG FILE TO "/home/sysdomi/sp_Domi_SubirArchivosProveedor.out";
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	--- OBTIENE LA RUTA DONDE SE ENCUENTRA EL ARCHIVO
	SELECT TRIM(valor)
	INTO sRuta
	FROM bdidomi: dom_parametros
	WHERE cod_param = "16";
	
	SELECT TRIM(valor)
	INTO cRutaIfx
	FROM bdidomi: dom_parametros
	WHERE cod_param = "44";	

	IF (sRuta IS NULL) OR (sRuta = "")THEN
		EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("02400") INTO v_cod_ret, sDescMensajeError;
		RETURN v_cod_ret, sDescMensajeError;
	END IF

	IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'dom_tmp_trabajo_proveedor') THEN
		DROP TABLE dom_tmp_trabajo_proveedor;
	END IF

	--- CREAR LA TABLA DE TRABAJO
	CREATE TABLE dom_tmp_trabajo_proveedor
	(linea LVARCHAR(500));

	--- GUARDA LOS NOMBRES DE LOS ARCHIVOS EXISTENTES EN LA RUTA EL CARPETA.CAR
	LET iPaso = 1;
	LET sCadSql = 'ls ' || TRIM(sRuta) || ' > ' || TRIM(sRuta) ||cFechaArchivoOUT||'.car';
	SYSTEM sCadSql;
		
	--- GUARDA EL QUERY DEL LOAD EN EL ARCHIVO   *.SQL
	LET iPaso = 2;
	LET sCadSql = 'echo "LOAD FROM ' || TRIM(sRuta) || cFechaArchivoOUT||'.car' || ' INSERT INTO dom_tmp_trabajo_proveedor" > '|| TRIM(sRuta) || cFechaArchivoOUT || '.sql';
	SYSTEM sCadSql;

	--- EJECUTA LAS INSTRUCCIONES QUE ESTAN DENTRO DEL ARCHIVO  *.SQL
	LET iPaso = 3;
	--PRODUCCION
	LET sCadSql = TRIM(cRutaIfx)||' bdidomi ' || TRIM(sRuta) || cFechaArchivoOUT ||'.sql > '||TRIM(sRuta)||TRIM(cFechaArchivoOUT)||'.out 2>&1';
	--DESARROLLO
	--LET sCadSql = '/informix/bin/dbaccess bdidomi ' || TRIM(sRuta) || cFechaArchivoOUT ||'.sql > '||TRIM(sRuta)||TRIM(cFechaArchivoOUT)||'.out 2>&1';
	SYSTEM sCadSql;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	--- CICLO PARA BUSCAR EL NOMBRE DEL ARCHIVO
	FOREACH
		SELECT linea
		INTO sLinea
		FROM dom_tmp_trabajo_proveedor

		IF sLinea = p_NombreArchivo THEN
			LET bBandArchivo = "t";
			EXIT FOREACH;
		END IF;
	END FOREACH;

	--- BORRAR LA TABLA PARA VOLVER A USARLA
	TRUNCATE TABLE dom_tmp_trabajo_proveedor;

	LET iPaso = 4;
	LET sCadSql = 'rm ' || TRIM(sRuta) || cFechaArchivoOUT||'.car';
	SYSTEM sCadSql;
	
	--- BORRA EL ARCHIVO .SQL
	LET iPaso = 5;
	LET sCadSql = 'rm ' || TRIM(sRuta) ||TRIM(cFechaArchivoOUT)||'.sql';
	SYSTEM sCadSql;

	LET iPaso = 6;
	LET sCadSql = 'rm ' || TRIM(sRuta) ||TRIM(cFechaArchivoOUT)||'.out';
	SYSTEM sCadSql;
		
	--- VALIDA QUE EL ARCHIVO EXISTA
	IF bBandArchivo = "f" THEN
		EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("02401") INTO v_cod_ret, sDescMensajeError;
		RETURN v_cod_ret, sDescMensajeError;
	ELSE
		--- GUARDA EL QUERY DEL LOAD EN EL ARCHIVO   *.SQL
		LET iPaso = 7;
		LET sCadSql = 'echo "LOAD FROM ' || TRIM(sRuta) || p_NombreArchivo || ' INSERT INTO dom_tmp_trabajo_proveedor" > '|| TRIM(sRuta) ||TRIM(cFechaArchivoOUT)|| '.sql';
		SYSTEM sCadSql;

		--- EJECUTA LAS INSTRUCCIONES QUE ESTAN DENTRO DEL ARCHIVO  *.SQL
		
		LET iPaso = 8;
		--PRODUCCION
		LET sCadSql = TRIM(cRutaIfx)||' bdidomi ' || TRIM(sRuta) || cFechaArchivoOUT ||'.sql > '||TRIM(sRuta)||TRIM(cFechaArchivoOUT)||'.out 2>&1';
		
		--DESARROLLO
		--LET sCadSql = '/informix/bin/dbaccess bdidomi ' || TRIM(sRuta) || cFechaArchivoOUT ||'.sql > '||TRIM(sRuta)||TRIM(cFechaArchivoOUT)||'.out 2>&1';

		SYSTEM sCadSql;
		
		LET iPaso = 9;
		LET sCadSql = 'rm ' || TRIM(sRuta) ||TRIM(cFechaArchivoOUT)||'.sql';
		SYSTEM sCadSql;

		LET iPaso = 10;
		LET sCadSql = 'rm ' || TRIM(sRuta) ||TRIM(cFechaArchivoOUT)||'.out';
		SYSTEM sCadSql;

		--- VALIDA QUE NO EXISTAN TIPOS DE REGISTROS AJENOS A LOS AUTORIZADOS
		IF EXISTS(SELECT linea FROM bdidomi: dom_tmp_trabajo_proveedor WHERE SUBSTR(linea,1,1) NOT IN ("E","D","S")) THEN
			EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("02402") INTO v_cod_ret, sDescMensajeError;
			RETURN v_cod_ret, sDescMensajeError;
		END IF

		LET iNumReg		= 0;
		--- OBTENER EL NUMERO DE REGISTROS DE ENCABEZADO
		SELECT COUNT(*)::INTEGER
		INTO iNumReg
		FROM  dom_tmp_trabajo_proveedor
		WHERE SUBSTR(linea,1,1) = "E";

		IF iNumReg = 0 THEN
			EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("02403") INTO v_cod_ret, sDescMensajeError;
			RETURN v_cod_ret, sDescMensajeError;
		ELIF iNumReg > 1 THEN
			EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("02404") INTO v_cod_ret, sDescMensajeError;
			RETURN v_cod_ret, sDescMensajeError;
		END IF

		LET iNumReg		= 0;
		--- OBTENER EL NUMERO DE REGISTROS DE SUMARIO
		SELECT COUNT(*)::INTEGER
		INTO iNumReg
		FROM  dom_tmp_trabajo_proveedor
		WHERE SUBSTR(linea,1,1) = "S";

		IF iNumReg = 0 THEN
			EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("02405") INTO v_cod_ret, sDescMensajeError;
			RETURN v_cod_ret, sDescMensajeError;
		ELIF iNumReg > 1 THEN
			EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("02406") INTO v_cod_ret, sDescMensajeError;
			RETURN v_cod_ret, sDescMensajeError;
		END IF

		LET iNumReg		= 0;
		--- OBTENER EL NUMERO DE REGISTROS DE DETALLE
		SELECT COUNT(*)::INTEGER
		INTO iNumReg
		FROM  dom_tmp_trabajo_proveedor
		WHERE SUBSTR(linea,1,1) = "D";

		IF iNumReg = 0 THEN
			EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("02407") INTO v_cod_ret, sDescMensajeError;
			RETURN v_cod_ret, sDescMensajeError;
		END IF

		--- BORRAR  LA TABLA DE TEMPORAL DE TRABAJO EN CASO DE QUE EXISTA
		IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'dom_tmp_secuencia_aut') THEN
			DROP TABLE dom_tmp_secuencia_aut;
		END IF

		--- CUENTA LA LONGITUD DE CARACTERES DE LAS CADENAS EN LA TABLA
		SELECT LENGTH(REPLACE(linea," ","*"))
		INTO iNumCaracteres
		FROM dom_tmp_trabajo_proveedor
		WHERE SUBSTR(linea,1,1) = "E";

		--- VALIDA LA LONGITUD DE LA LINEA DE ENCABEZADO
		IF iNumCaracteres NOT IN (65,66)  THEN
			EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("02408") INTO v_cod_ret, sDescMensajeError;
			RETURN v_cod_ret, sDescMensajeError;
		END IF

		--- CUENTA LA LONGITUD DE CARACTERES DE LAS CADENAS EN LA TABLA
		SELECT LENGTH(REPLACE(linea," ","*"))
		INTO iNumCaracteres
		FROM dom_tmp_trabajo_proveedor
		WHERE SUBSTR(linea,1,1) = "S";

		--- VALIDA LA LONGITUD DE LA LINEA DE SUMARIO
		IF iNumCaracteres NOT IN (105,106)  THEN
			EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("02409") INTO v_cod_ret, sDescMensajeError;
			RETURN v_cod_ret, sDescMensajeError;
		END IF

		LET iContador = 0;

		FOREACH
			--- CUENTA LA LONGITUD DE CARACTERES DE LAS CADENAS EN LA TABLA
			SELECT DISTINCT LENGTH(REPLACE(linea," ","*"))
			INTO iNumCaracteres
			FROM dom_tmp_trabajo_proveedor
			WHERE SUBSTR(linea,1,1) = "D"

			LET iContador = iContador + 1;
		END FOREACH
		--- VALIDA QUE NO EXISTAN DIFERENTES LONGITUDES EN LA TABLA
		IF iContador > 1 THEN
			EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("02410") INTO v_cod_ret, sDescMensajeError;
			RETURN v_cod_ret, sDescMensajeError;
		--- VALLIDA QUE SI EXISTE EL MISMO NUMERO DE CARACTERES POR LINEA ESTE SEA EL ADECUADO
		ELIF iContador = 1 AND iNumCaracteres NOT IN (342,343)  THEN
			EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("02410") INTO v_cod_ret, sDescMensajeError;
			RETURN v_cod_ret, sDescMensajeError;
		END IF

		--- BORRAR  LA TABLA DE TEMPORAL DE TRABAJO EN CASO DE QUE EXISTA
		IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'dom_tmp_secuencia_prov') THEN
			DROP TABLE dom_tmp_secuencia_prov;
		END IF

		--- CREAR LA TABLA DE TRABAJO
		CREATE TABLE dom_tmp_secuencia_prov
		(secuencia CHAR(6));

		INSERT INTO dom_tmp_secuencia_prov
		SELECT SUBSTR(linea,2,6) AS SECUENCIA
		FROM bdidomi: dom_tmp_trabajo_proveedor
		WHERE SUBSTR(linea,1,1) = "D";
		---VERIFICAR QUE NO VENGAN REPETIDOS LOS NUMEROS DE SECUENCIA
		IF EXISTS(SELECT SECUENCIA FROM dom_tmp_secuencia_prov GROUP BY SECUENCIA HAVING COUNT(*) > 1) THEN
			EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("02411") INTO v_cod_ret, sDescMensajeError;
			RETURN v_cod_ret, sDescMensajeError;
		END IF

		INSERT INTO bdidomi: dom_cte_archivos(nombre_arch, fecha_envio, num_cte, fecha_carga, cve_status, user_insert, fecha_insert)
		VALUES(p_NombreArchivo, p_FechaEnvio, p_NumCte, p_FechaCarga, p_CveStatus, p_Usuario, CURRENT);

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT linea
			INTO sLinea
			FROM dom_tmp_trabajo_proveedor

			IF SUBSTR(sLinea,1,1) = "E" THEN --- ASIGNACIONES PARA ENCABEZADO
				LET sEncTipoReg					= SUBSTR(sLinea,1,1);
				LET sEncNumCte					= SUBSTR(sLinea,2,20);
				LET sEncCtaAbono				= SUBSTR(sLinea,22,20);
				LET sEncNumOper					= SUBSTR(sLinea,42,8);
				LET sEncFechaIni				= SUBSTR(sLinea,50,8);
				LET sEncFechaFin				= SUBSTR(sLinea,58,8);

				INSERT INTO bdidomi: dom_cte_encabezado (nombre_arch,fecha_envio,tipo_registro,num_cte,cuenta_abono,num_operaciones
														,fecha_inicial,fecha_final,user_insert,fecha_insert)
				VALUES (p_NombreArchivo,p_FechaEnvio,sEncTipoReg,sEncNumCte,sEncCtaAbono,sEncNumOper,sEncFechaIni,sEncFechaFin,p_Usuario,CURRENT);

			ELIF SUBSTR(sLinea,1,1) = "D" THEN --- ASIGNACIONES PARA DETALLE
				LET sDetTipoReg					= SUBSTR(sLinea,1,1);
				LET sDetConsecutivo				= SUBSTR(sLinea,2,6);
				LET sDetFechaCargo				= SUBSTR(sLinea,8,8);
				LET sDetFechaAbono				= SUBSTR(sLinea,16,8);
				LET sDetTipoCtaCargo			= SUBSTR(sLinea,24,2);
				LET sDetCveBancoCargo			= SUBSTR(sLinea,26,3);
				LET sDetCtaCargo				= SUBSTR(sLinea,29,20);
				LET sDetRFC_Cargo				= SUBSTR(sLinea,49,13);
				LET sDetNomCargo				= SUBSTR(sLinea,62,50);
				LET sDetCtaAbono				= SUBSTR(sLinea,112,20);
				LET sDetImpOper					= SUBSTR(sLinea,132,15);
				LET sDetImpIva					= SUBSTR(sLinea,147,15);
				LET sDetRefNumerica				= SUBSTR(sLinea,162,7);
				LET sDetRefLeyenda				= SUBSTR(sLinea,169,40);
				LET sDetRefServicio				= SUBSTR(sLinea,209,40);
				LET sDetRefTituServ				= SUBSTR(sLinea,249,40);
				LET sDetAccion					= SUBSTR(sLinea,289,1);
				LET sDetReintentarCta			= SUBSTR(sLinea,290,1);
				LET sDetEstatus					= SUBSTR(sLinea,291,2);
				LET sDetCausaRechazo			= SUBSTR(sLinea,293,50);
				/*
				LET sDia						= SUBSTR(sDetFechaCargo,1,2);
				LET sMes						= SUBSTR(sDetFechaCargo,3,2);
				LET sAnio						= SUBSTR(sDetFechaCargo,5,4);
				LET sDetFechaCargo				= sAnio || sMes || sDia;

				LET sDia						= SUBSTR(sDetFechaAbono,1,2);
				LET sMes						= SUBSTR(sDetFechaAbono,3,2);
				LET sAnio						= SUBSTR(sDetFechaAbono,5,4);
				LET sDetFechaAbono				= sAnio || sMes || sDia;*/

				INSERT INTO bdidomi: dom_cte_detalle (nombre_arch,fecha_envio,tipo_registro,consecutivo,fecha_cargo,fecha_abono,tipo_cta_cargo
							,cve_banco_cargo,cuenta_cargo,rfc_cargo,nombre_cargo,cuenta_abono,imp_operacion,imp_iva,ref_numerica,ref_leyenda
							,ref_servicio,ref_titular_serv,accion,reintentar_cuenta,estatus,causa_rechazo,nombre_arch_cce,fecha_presentacion_cce
							,tipo_registro_cce,numero_secuencia_cce,comision_cobrada,iva_cobrado,user_insert,fecha_insert)
				VALUES (p_NombreArchivo,p_FechaEnvio,sDetTipoReg,sDetConsecutivo,sDetFechaCargo,sDetFechaAbono,sDetTipoCtaCargo,sDetCveBancoCargo
						,sDetCtaCargo,sDetRFC_Cargo,sDetNomCargo,sDetCtaAbono,sDetImpOper,sDetImpIva,sDetRefNumerica,sDetRefLeyenda,sDetRefServicio,sDetRefTituServ,sDetAccion
						,sDetReintentarCta,sDetEstatus,sDetCausaRechazo,NULL,NULL,NULL,NULL,NULL,NULL,p_Usuario,CURRENT);

			ELIF SUBSTR(sLinea,1,1) = "S" THEN--- ASIGNACIONES PARA SUMARIO
				LET sSumTipoReg					= SUBSTR(sLinea,1,1);
				LET sSumNumOper					= SUBSTR(sLinea,2,8);
				LET sSumImpOper					= SUBSTR(sLinea,10,18);
				LET sSumNumOperPend				= SUBSTR(sLinea,28,8);
				LET sSumImpOperPend				= SUBSTR(sLinea,36,18);
				LET sSumNumOperApli				= SUBSTR(sLinea,54,8);
				LET sSumImpOperApli				= SUBSTR(sLinea,62,18);
				LET sSumNumOperRecha			= SUBSTR(sLinea,80,8);
				LET sSumImpOperRecha			= SUBSTR(sLinea,88,18);

				INSERT INTO bdidomi: dom_cte_sumario (nombre_arch,fecha_envio,tipo_registro,num_operaciones,imp_operaciones,num_oper_pend
							,imp_oper_pend,num_oper_apli,imp_oper_apli,num_oper_rech,imp_oper_rech,user_insert,fecha_insert)
				VALUES (p_NombreArchivo,p_FechaEnvio,sSumTipoReg,sSumNumOper,sSumImpOper,sSumNumOperPend,sSumImpOperPend
						,sSumNumOperApli,sSumImpOperApli,sSumNumOperRecha,sSumImpOperRecha,p_Usuario,CURRENT);
			END IF
		END FOREACH
	END IF

	RETURN v_cod_ret, sDescMensajeError;
END;
--##############################################################################
--## Procedimiento   : sp_Domi_SubirArchivosProveedor
--## Version         : 1.0
--## Creado por      : Mohamed CarreÃ?Â³n
--## Fecha creacion  : Agosto de 2009
--##Descripcion :
--##############################################################################
END PROCEDURE;