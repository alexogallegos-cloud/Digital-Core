CREATE PROCEDURE "informix".sp_domi_genrep30_pba(pNomArchivo CHAR(20), pTpoProc INTEGER, pfecini CHAR(10), pfecfin CHAR(10))
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

CREATE PROCEDURE "informix".sp_domi_buscararchivo(p_Ruta VARCHAR(100), p_NombreArchivo VARCHAR(50))
RETURNING
	CHAR(5), ---cod_ret
	CHAR(1); ---Bandera   *** V > Existe el Archivo en la Ruta, *** F > No existe el Archivo

	---DECLARACIONES
    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;

	DEFINE bBandera				CHAR(1);
	DEFINE sCadSql				LVARCHAR(500);
	DEFINE sLinea				VARCHAR(50);
	
	DEFINE cHora				CHAR(8);
	DEFINE cFechaArchivoOUT		CHAR(15);
	DEFINE iPaso				SMALLINT;

	---INICIALIZACIONES
	LET sCadSql				= "";
	LET bBandera			= "F";
	LET sLinea				= "";

	LET cHora				= TO_CHAR(EXTEND(CURRENT, HOUR TO SECOND),'%H:%M:%S');
	LET cFechaArchivoOUT	= YEAR(CURRENT::DATE)||LPAD(MONTH(CURRENT::DATE),2,'0')||LPAD(DAY(CURRENT::DATE),2,'0')||SUBSTR(cHora,1,2)||SUBSTR(cHora,4,2)||SUBSTR(cHora,7,2)||'_';
	LET iPaso				= 0;
	

BEGIN

	ON EXCEPTION
        SET iSqlErr, iSamErr
        IF iSqlErr <> 0 THEN
            LET v_cod_ret = iSqlErr;
        END IF;

        RETURN v_cod_ret,NULL;
    END EXCEPTION;
	
	ON EXCEPTION IN(-668) SET iSqlErr
		IF iPaso NOT IN (4,5,6) THEN 
			LET v_cod_ret = iSqlErr;
			RETURN v_cod_ret,NULL;
		END IF;
	END EXCEPTION WITH RESUME;


	--SET DEBUG FILE TO "/home/sysdomi/sp_Domi_BuscarArchivo.out";
	--TRACE ON;

	LET v_cod_ret = '00000';

	IF (p_Ruta = "") OR (p_Ruta  IS NULL) THEN
		RETURN "00450", NULL;
	END IF

	IF (p_NombreArchivo = "") OR (p_NombreArchivo  IS NULL) THEN
		RETURN "00451", NULL;
	END IF

	--- BORRAR  LA TABLA DE TEMPORAL DE TRABAJO EN CASO DE QUE EXISTA
	IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'dom_tmp_busca_archivo') THEN
		DROP TABLE dom_tmp_busca_archivo;
	END IF

	--- CREAR LA TABLA DE TRABAJO
	CREATE TABLE dom_tmp_busca_archivo
	(linea LVARCHAR(50));

	--- CORRER EL COMANDO LS PARA OBTENER LOS NOMBRES QUE EXISTEN EN LAS CARPETAS Y METERLOS EN EL ARCHIVO buscar.bus
	LET iPaso = 1;
	LET sCadSql = 'ls ' || TRIM(p_Ruta) || ' > ' || TRIM(p_Ruta) || cFechaArchivoOUT|| '.bus';
	SYSTEM sCadSql;

	--- GUARDA EL QUERY DEL LOAD EN EL ARCHIVO   *.SQL
	LET iPaso = 2;
	LET sCadSql = 'echo "LOAD FROM ' || TRIM(p_Ruta) || cFechaArchivoOUT|| '.bus' || ' INSERT INTO dom_tmp_busca_archivo" > '|| TRIM(p_Ruta) || cFechaArchivoOUT|| '.sql';
	SYSTEM sCadSql;

	--- EJECUTA LAS INSTRUCCIONES QUE ESTAN DENTRO DEL ARCHIVO  *.SQL
	LET iPaso = 3;
	--Produccion
	LET sCadSql = '/ifxsif01/bin/dbaccess  bdidomi ' || TRIM(p_Ruta) || cFechaArchivoOUT||'.sql > '||TRIM(p_Ruta)||TRIM(cFechaArchivoOUT)||'.out 2>&1';
	
	--Desarrollo
	--LET sCadSql = '/informix/bin/dbaccess  bdidomi ' || TRIM(p_Ruta) || cFechaArchivoOUT||'.sql > '||TRIM(p_Ruta)||TRIM(cFechaArchivoOUT)||'.out 2>&1';
	
	SYSTEM sCadSql;
	

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	--- CICLO PARA BARRER  LA TABLA DE TRABAJO Y BUSCAR EL NOMBRE DEL ARCHIVO
	FOREACH
		SELECT linea
		INTO sLinea
		FROM dom_tmp_busca_archivo

		IF sLinea = p_NombreArchivo THEN
			LET bBandera = "V";
			EXIT FOREACH;
		END IF;
	END FOREACH;
	
	LET iPaso = 4;	
	LET sCadSql = 'rm ' || TRIM(p_Ruta) ||cFechaArchivoOUT||'.bus';
	SYSTEM sCadSql;

	LET iPaso = 5;
	LET sCadSql = 'rm ' || TRIM(p_Ruta) ||cFechaArchivoOUT||'.sql';
	SYSTEM sCadSql;	

	LET iPaso = 6;
	LET sCadSql = 'rm ' || TRIM(p_Ruta) ||cFechaArchivoOUT||'.out';
	SYSTEM sCadSql;	
	
	DROP TABLE dom_tmp_busca_archivo;

	RETURN v_cod_ret, bBandera;
END;
--##############################################################################
--## Procedimiento   : sp_Domi_BuscarArchivo
--## Version         : 1.0
--## Creado por      : Mohamed CarreÃ³n
--## Fecha creacion  : Julio de 2009
--##Descripcion :  Procedimiento para buscar un archivo en una ruta proporcionada
--##############################################################################
END PROCEDURE;