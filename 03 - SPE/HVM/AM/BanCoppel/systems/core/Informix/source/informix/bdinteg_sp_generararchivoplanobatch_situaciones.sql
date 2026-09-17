CREATE PROCEDURE "informix".sp_generararchivoplanobatch_situaciones(cTipoMov CHAR(2), pFechaAct DATE)
RETURNING
     CHAR(6); ---cod_ret

    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
	DEFINE vDesErr              CHAR(60);
	DEFINE vsSQL1 				CHAR (150);
	DEFINE vsSQL2 				CHAR (750) ;
	DEFINE vsSQL3 				CHAR (150) ;
	--DEFINE v_NomArchivo  VARCHAR(50);
	DEFINE vRuta CHAR (90);
	DEFINE vsSQL CHAR (1050) ;
	DEFINE sPreNomArchivoFinal VARCHAR(100);
	DEFINE sNombreArchivoFinal VARCHAR(100);
	-- AAME RQI 27 067 SE AGREGA VARIABLE PARA EL NUEVO ARCHIVO
	DEFINE sAntNomArchivoFinal VARCHAR(100);
	DEFINE sAnterNomArchivoFinal VARCHAR(100);
	DEFINE iCountMovTO INTEGER;
	DEFINE  v_TipoMov VARCHAR (20);
	DEFINE cFecha_hoy CHAR(8);
	DEFINE cFechaSistema DATE;
	
	LET vsSQL = '' ;
	LET vsSQL1 = '' ;
	LET vsSQL2 = '' ;
	LET vsSQL3 = '' ;
	LET iCountMovTO = 0;
	LET  v_TipoMov = '';
	LET cFecha_hoy = '19000101';
	LET cFechaSistema = DATE(1);
	LET sPreNomArchivoFinal ='';
	LET sNombreArchivoFinal ='';
	-- AAME RQI 27 067 SE INICIALIZA VARIABLE PARA EL NUEVO ARCHIVO
	LET sAntNomArchivoFinal ='';
	LET sAnterNomArchivoFinal='';
	
SET ISOLATION TO COMMITTED READ LAST COMMITTED;	
	---SET LOCK MODE TO WAIT 10;

BEGIN

   ON EXCEPTION
        SET iSqlErr, iSamErr
        IF iSqlErr <> 0 THEN
                LET v_cod_ret = iSqlErr;
                --EXECUTE PROCEDURE  "informix".sp_desc_ret(20, v_cod_ret)
                --INTO v_cod_ret, vDesErr;
        END IF;
        RETURN v_cod_ret;
    END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/respaldosbd/mr/sp_GenerarArchivoPlano.out";
	--TRACE ON;

	LET v_cod_ret = '00000';
	LET vDesErr = '';
	
	SELECT TRIM(valor)
	INTO vRuta
	FROM "informix".si_param
	WHERE cod_param='193';

	LET sNombreArchivoFinal = TRIM(vRuta)||'batchsituaciones';
	-- INC 27 047 Se cambia el nombrado de los archivos generados a como se encontraban los productivos.
	
	IF cTipoMov IS NULL OR (cTipoMov <> '' AND cTipoMov <> 'TO') THEN
		LET v_cod_ret = '00001';
		RETURN v_cod_ret;
	END IF;
	
	SELECT COUNT(tipomovto) INTO iCountMovTO FROM "informix".si_archivoscopdiario_sitesp WHERE tipomovto = 'TO' AND fecha_insert = pFechaAct;
	
	SELECT fecha_hoy INTO cFechaSistema FROM bdinteg:"informix".si_fechas WHERE empresa = '001';
	
	IF pFechaAct <> mdy(1,1,1900) OR pFechaAct IS NOT NULL THEN	
		IF iCountMovTO > 0 THEN
			IF cTipoMov = '' THEN	---	Se valida el tipo de movimiento
					
				IF EXISTS (SELECT DISTINCT tipomovto FROM "informix".si_archivoscopdiario_sitesp WHERE tipomovto <> 'TO' AND fecha_insert = pFechaAct) THEN		---	Se valida que que tlpo de movimiento se encuentre en la tabla
					LET cFecha_hoy = YEAR(pFechaAct)||""||LPAD(MONTH(pFechaAct),2,0)||""||LPAD(DAY(pFechaAct),2,0);
					LET sNombreArchivoFinal = TRIM(vRuta)||'batchsituaciones'|| cFecha_hoy || '.txt' ;
					LET sPreNomArchivoFinal = TRIM(vRuta)||'batchsituaciones.unl';
					-- AAME RQI 27 067 SE AGREGA EL NOMBRE PARA EL NUEVOS ARCHIVOS DE PASO
					LET sAntNomArchivoFinal = TRIM(vRuta)||'batchsituaciones2.unl';
					LET sAnterNomArchivoFinal = TRIM(vRuta)||'batchsituaciones3.unl';
					--
					LET vsSQL = ' echo "UNLOAD TO ' ||  TRIM(vRuta)|| 'batchsituacionesx.unl' || ' DELIMITER ' || '''|''' || 
								' SELECT trama '||
								' FROM "informix".si_archivoscopdiario_sitesp '||
								' WHERE tipomovto <> '||'''TO'''||
								' AND fecha_insert = '||''''||pFechaAct||''''||
								' " > ' || TRIM(vRuta)|| 'Ejecutabatchsituaciones.sql';
					SYSTEM vsSQL;
					LET vsSQL =  "chmod 777 "||sNombreArchivoFinal||" > "|| TRIM(vRuta)|| "Ejecutabatchsituaciones.sql";
					LET vsSQL = '';
					LET vsSQL = 'dbaccess bdinteg ' || TRIM(vRuta)|| 'Ejecutabatchsituaciones.sql';
					SYSTEM vsSQL;

					LET vsSQL = '';
					LET vsSQL =  "sed 's/\\//g' " || TRIM(vRuta)|| "batchsituacionesx.unl > " || sPreNomArchivoFinal;
					SYSTEM vsSQL;					
					LET vsSQL = '';
					LET vsSQL =  "sed 's/|$//g' " || TRIM(vRuta)|| "batchsituaciones.unl > " || sAntNomArchivoFinal;
					SYSTEM vsSQL;
					-- AAME RQI 27 067 SE AGREGA ARCHIVO DE PASO PARA AGREGAR ESPACIOS EN BLANCO A LOS CAMPOS VACÍOS
					LET vsSQL = '';
					LET vsSQL =  "sed 's/||/| |/g' " || TRIM(vRuta)|| "batchsituaciones2.unl > " || sAnterNomArchivoFinal;
					SYSTEM vsSQL;				
					LET vsSQL = '';
					LET vsSQL =  "sed 's/||/| |/g' " || TRIM(vRuta)|| "batchsituaciones3.unl > " || sNombreArchivoFinal;
					SYSTEM vsSQL;	
					--
					LET vsSQL = '';
					LET vsSQL =  "chmod 777 "||sNombreArchivoFinal||" > "|| TRIM(vRuta)|| "batchsituacionesderechos.txt";
					SYSTEM vsSQL;
					LET vsSQL = '';
					LET vsSQL =  "rm " || TRIM(vRuta)|| "batchsituacionesderechos.txt";
					SYSTEM vsSQL;
					---	RESPALDA LOS DATOS DEL MOVIMIENTO A LA TABLA HISTORICA
					INSERT INTO "informix".si_archivoscophist_sitesp(empresa,secuencia, identificador,trama,tipomovto,fecha_archivo,fecha_insert)
					SELECT empresa,secuencia,'',trama,tipomovto,fecha_insert, cFechaSistema
					FROM "informix".si_archivoscopdiario_sitesp
					WHERE tipomovto <> 'TO'
					AND fecha_insert = pFechaAct;
					
					--BORRA LOS MOVIMIENTOS DE LA TABLA DIARIA
					DELETE FROM "informix".si_archivoscopdiario_sitesp
					WHERE tipomovto <> 'TO' 
					AND fecha_insert = pFechaAct;					
									
				END IF;
			ELIF cTipoMov = 'TO'  THEN --Valida el tipo de movimiento para generar el archivo de totales
				LET v_cod_ret = '00000';
				IF EXISTS (SELECT DISTINCT tipomovto FROM "informix".si_archivoscopdiario_sitesp WHERE tipomovto = 'TO' AND fecha_insert = pFechaAct) THEN		---	Se valida que que tlpo de movimiento se encuentre en la tabla
					LET cFecha_hoy = YEAR(pFechaAct)||""||LPAD(MONTH(pFechaAct),2,0)||""||LPAD(DAY(pFechaAct),2,0);
					LET sNombreArchivoFinal = TRIM(vRuta)|| 'MovSituaciones'|| cFecha_hoy || '.txt';
					LET sPreNomArchivoFinal =  TRIM(vRuta)|| 'MovSituaciones.unl';
					-- AAME RQI 27 067 SE AGREGA EL NOMBRE PARA EL NUEVOS ARCHIVOS DE PASO
					LET sAntNomArchivoFinal = TRIM(vRuta)|| 'MovSituaciones2.unl';
					LET sAnterNomArchivoFinal = TRIM(vRuta)|| 'MovSituaciones3.unl';
					--
					---	GENERA EL ARCHIVO PLANO
					LET vsSQL1 = ' echo "UNLOAD TO ' || TRIM(vRuta)||'MovSituacionesx.unl' || ' DELIMITER ' || '''|''';
					LET vsSQL2 = "SELECT  trama FROM  bdinteg:si_archivoscopdiario_sitesp WHERE  tipomovto = '"||cTipoMov||"' AND fecha_insert ='"||pFechaAct||"';";
					LET vsSQL3 = ' " > '|| TRIM(vRuta) || 'EjecutacifrasMovSituaciones.sql'; 
					LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;
					SYSTEM vsSQL;
					LET vsSQL =  "chmod 777 "||sNombreArchivoFinal||" > "|| TRIM(vRuta)|| "EjecutacifrasMovSituaciones.sql";
					LET vsSQL = '';
					LET vsSQL = 'dbaccess bdinteg '|| TRIM(vRuta)|| 'EjecutacifrasMovSituaciones.sql';
					SYSTEM vsSQL;

					LET vsSQL = '';
					LET vsSQL =  "sed 's/\\//g' " || TRIM(vRuta)|| "MovSituacionesx.unl > "|| sPreNomArchivoFinal;
					SYSTEM vsSQL;
					LET vsSQL = '';
					LET vsSQL =  "sed 's/|$//g' " || TRIM(vRuta)|| "MovSituaciones.unl > "|| sAntNomArchivoFinal;
					SYSTEM vsSQL;
					-- AAME RQI 27 067 SE AGREGA ARCHIVO DE PASO PARA AGREGAR ESPACIOS EN BLANCO A LOS CAMPOS VACÍOS
					LET vsSQL = '';
					LET vsSQL =  "sed 's/||/| |/g' " || TRIM(vRuta)|| "MovSituaciones2.unl > " || sAnterNomArchivoFinal;
					SYSTEM vsSQL;	
					LET vsSQL = '';
					LET vsSQL =  "sed 's/||/| |/g' " || TRIM(vRuta)|| "MovSituaciones3.unl > " || sNombreArchivoFinal;
					SYSTEM vsSQL;	
					--
					LET vsSQL = '';
					LET vsSQL =  "chmod 777 " || sNombreArchivoFinal || " > "|| TRIM(vRuta)|| "cifrasMovSituacionesderechos.txt";
					SYSTEM vsSQL;
					LET vsSQL = '';
					LET vsSQL =  "rm "|| TRIM(vRuta)|| "cifrasMovSituacionesderechos.txt";
					SYSTEM vsSQL;
				
					---	RESPALDA LOS DATOS DEL MOVIMIENTO A LA TABLA HISTORICA
					INSERT INTO "informix".si_archivoscophist_sitesp(empresa,secuencia, identificador,trama,tipomovto,fecha_archivo,fecha_insert)
					SELECT empresa,secuencia,'',trama,tipomovto,fecha_insert, cFechaSistema
					FROM "informix".si_archivoscopdiario_sitesp
					WHERE tipomovto = 'TO'
					AND fecha_insert = pFechaAct;
					
					--BORRA LOS MOVIMIENTOS DE LA TABLA DIARIA
					DELETE FROM "informix".si_archivoscopdiario_sitesp
					WHERE tipomovto = 'TO' 
					AND fecha_insert = pFechaAct;							

				END IF;
			END IF;
		ELSE
			LET v_cod_ret = '00002';
		END IF;
	ELSE
		LET v_cod_ret = '00003';
	END IF;
	RETURN v_cod_ret;
END;
END PROCEDURE
DOCUMENT
'AUTOR: MIREYA REYES',
'FOLIO: 1739',
'DESCRIPCION: Se crea procedimiento que genera los archivos planos de movimientos de situaciones',
'FECHA: 06/07/2015',
'VERSION: 20150706.1740',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_totalesmovimientoscoppelbatch_situaciones(cEmpresa CHAR(3), cTipoMov CHAR(2), dFechaAct DATE)
RETURNING CHAR(6); ---cod_ret

DEFINE cCodRet			CHAR(5);
DEFINE iSqlErr			INTEGER;

DEFINE cTipoMov			CHAR(5);
DEFINE iTipoMov			INTEGER;
DEFINE iImporte			INTEGER;
DEFINE iCantidad		INTEGER;
DEFINE CSucursal		CHAR(4);
DEFINE dFecha			DATE;
DEFINE dFechaMov		DATE;
DEFINE iSecuencia		INTEGER;
DEFINE cFecha			CHAR(10);
DEFINE cFechaMov		CHAR(19);
DEFINE vHora DATETIME HOUR TO FRACTION(3);

LET cCodRet		= '00000';
LET iSqlErr		= 0;
LET iTipoMov	= 0;
LET iImporte	= 0;
LET iCantidad	= 0;
LET CSucursal	= '';
LET dFecha		= DATE(1);
LET dFechaMov	= DATE(1);
LET iSecuencia	= 0;
LET cFecha		= '1900/01/01';
LET cFechaMov	= '1900/01/01 12:00:00';
LET vHora		= '';

--SET DEBUG FILE TO '/tmp/sp_totalesmovimientoscoppelbatch_situaciones.out';
--TRACE ON;

BEGIN
    ON EXCEPTION
        SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                RETURN cCodRet;
            END IF;
    END EXCEPTION;

	SET LOCK MODE TO WAIT 3;

	SELECT NVL(secuencia_max,0) INTO iSecuencia
	FROM "informix".si_archivosecuenciamax_sitesp
	WHERE empresa = cEmpresa;


	--FOREACH

		/*SELECT DISTINCT(sucursal)
		INTO CSucursal
		FROM  "informix".si_archivoscopdiario_sitesp
		WHERE tipomovto = 'M'
		AND fecha_insert = dFechaAct*/

		SELECT count(*)--, tipomovto, fecha_insert, fecha_insert
		INTO iCantidad--, cTipoMov, dFecha, dFechaMov
		FROM  "informix".si_archivoscopdiario_sitesp
		WHERE --sucursal = CSucursal
        tipomovto = 'M'
		AND fecha_insert = dFechaAct;
		--GROUP BY 2, 3;

		LET iTipoMov = 14;

		SELECT DBINFO('utc_to_datetime', sh_curtime) INTO vHora FROM sysmaster:sysshmvals;
		LET cFechaMov = YEAR(dFechaAct)||"/"||LPAD(MONTH(dFechaAct),2,0)||"/"||LPAD(DAY(dFechaAct),2,0)||" "||vHora;
		LET cFecha = YEAR(dFechaAct)||"/"||LPAD(MONTH(dFechaAct),2,0)||"/"||LPAD(DAY(dFechaAct),2,0);

		INSERT INTO "informix".si_archivoscopdiario_sitesp(empresa, secuencia, sucursal, trama, tipomovto, fecha_insert)
		VALUES ('001',iSecuencia, CSucursal, iCantidad ||"|"||cFecha, 'TO', dFechaAct);

		LET iSecuencia = iSecuencia + 1;

--	END FOREACH

	IF iSecuencia > 0 THEN
		UPDATE "informix".si_archivosecuenciamax_sitesp SET secuencia_max=iSecuencia WHERE empresa = cEmpresa;
	END IF;

RETURN cCodRet;

END;
END PROCEDURE
DOCUMENT
'AUTOR: MIREYA REYES',
'FOLIO: 1739',
'DESCRIPCION: Guarda el total de movimientos realizados',
'FECHA: 06/07/2015',
'VERSION: 20150706.1740',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_obtparamwsalta(pcEmpresa CHAR(3))
RETURNING CHAR(6),CHAR(4), CHAR(100), CHAR(100), CHAR(100), INTEGER, CHAR(20), INTEGER, INTEGER, INTEGER, CHAR(1), CHAR(8), 
		  DATE, CHAR(100)

--DEFINE VARIABLES
DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(6);
DEFINE cSucursal CHAR(4);
DEFINE cTipoOperacion CHAR(100);
DEFINE cLlave CHAR(100);
DEFINE cLlavePrivada CHAR(100);
DEFINE iIdTransaccion INTEGER;
DEFINE cCliente CHAR(20);
DEFINE iIdSituacion INTEGER;
DEFINE iIdMotivo INTEGER;
DEFINE iIdPersona INTEGER;
DEFINE cDesCtas CHAR(1);
DEFINE cNumEmp CHAR(8);
DEFINE dFecMarcado DATE;
DEFINE ccodAltaWsSitEsp CHAR(4);
DEFINE cCodRetSP CHAR(6);
DEFINE cUrl_webservice CHAR(100);

--INICIALIZA VARIABLES
LET iSqlErr = 0;
LET cCodRet = '000003';
LET cSucursal = '';
LET cTipoOperacion = '';
LET cLlave = '';
LET cLlavePrivada= '';
LET iIdTransaccion = 0;
LET cCliente = '';
LET iIdSituacion= 0;
LET iIdMotivo = 0;
LET iIdPersona = 0;
LET cDesCtas= '0';
LET cNumEmp= '';
LET dFecMarcado= CURRENT::DATE;
LET ccodAltaWsSitEsp = '';
LET cCodRetSP = '000000';
LET cUrl_webservice = '';

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet,NVL(cSucursal, ''),NVL(cTipoOperacion, ''),NVL(cLlave, ''),NVL(cLlavePrivada, ''),iIdTransaccion,
			NVL(cCliente, ''),iIdSituacion,iIdMotivo,iIdPersona,cDesCtas,NVL(cNumEmp, ''),dFecMarcado,NVL(cUrl_webservice, '');
		END IF;
	END EXCEPTION;
	SET LOCK MODE TO WAIT 3;
	
  --SET DEBUG FILE TO '/respaldosbd/IvanM/SituacionesEspeciales_Rep/sp_obtparamwsalta.out';
  --TRACE ON;
  
	IF NVL(pcEmpresa,'') <> '' THEN
		SELECT TRIM(valor) INTO cTipoOperacion FROM bdinteg:"informix".si_param WHERE cod_param = 369;
		SELECT TRIM(valor) INTO cLlave FROM bdinteg:"informix".si_param WHERE cod_param = 351;
		SELECT TRIM(valor) INTO cLlavePrivada FROM bdinteg:"informix".si_param WHERE cod_param = 388;
		SELECT TRIM(valor) INTO ccodAltaWsSitEsp FROM bdinteg:"informix".si_param WHERE cod_param = 367;
		SELECT TRIM(url_webservice) INTO cUrl_webservice FROM bdinteg:"informix".mae_webservice WHERE empresa = pcEmpresa  AND cod_ws =ccodAltaWsSitEsp;
		
		IF NVL(cTipoOperacion,'') <> '' AND NVL(cLlave,'') <> '' AND NVL(cLlavePrivada,'') <> '' AND 
		NVL(ccodAltaWsSitEsp,'') <> '' AND NVL(cUrl_webservice,'') <> '' THEN
		
			FOREACH
				SELECT sit.cliente,sit.idusituacion,sit.sucursal,sit.empleado INTO cCliente,iIdSituacion,cSucursal,cNumEmp
				FROM si_situaciones_clientescoppel_porenviar sit, si_clientescoppelporenviar cte
				WHERE sit.numcte = cte.numcte AND sit.empresa = pcEmpresa AND sit.ctl_enviado = 2 AND cte.status = 3
				
				IF NVL(cTipoOperacion,'') <> ''THEN
					EXECUTE PROCEDURE bdinteg:"informix".sp_obtienenumeroconsultaws('366','001') INTO cCodRetSP,iIdTransaccion;
					
					IF cCodRetSP = '000000' THEN
						LET cCodRet = cCodRetSP;
						RETURN cCodRet,NVL(cSucursal, ''),NVL(cTipoOperacion, ''),NVL(cLlave, ''),NVL(cLlavePrivada, ''),iIdTransaccion,
						NVL(cCliente, ''),iIdSituacion,iIdMotivo,iIdPersona,cDesCtas,NVL(cNumEmp, ''),dFecMarcado,
						NVL(cUrl_webservice, '') WITH RESUME;
					ELSE
						LET cCodRet = '000004';
					END IF;
				ELSE
					CONTINUE FOREACH;
				END IF;
			END FOREACH;
		ELSE
			LET cCodRet = '000002';
		END IF;
	ELSE
		LET cCodRet = '000001';
	END IF;
	IF cCodRet <> '000000' THEN
		RETURN cCodRet,NVL(cSucursal, ''),NVL(cTipoOperacion, ''),NVL(cLlave, ''),NVL(cLlavePrivada, ''),iIdTransaccion,NVL(cCliente, ''),
		iIdSituacion,iIdMotivo,iIdPersona,cDesCtas,NVL(cNumEmp, ''),dFecMarcado,NVL(curl_webservice, '');
	END IF;
END
END PROCEDURE
DOCUMENT
'AUTOR: IvÃ n Michel Valdez RodrÃ¬guez',
'FOLIO: 1747',
'DESCRIPCION: Procedimiento que obtiene parÃ metros para WebService wsSituacionesEspecialesServicesBCPL',
'FECHA: 19/Agosto/2015',
'VERSION: 20150819.1240',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_fustraspasotelefonos(pClienteTitular CHAR(20), pClienteTraspasaCtas CHAR(20), pUsuario CHAR(8)) 
RETURNING CHAR(5), CHAR(80);
DEFINE vc_CodRet        CHAR(5);
DEFINE vi_SqlErr        INTEGER;
DEFINE vi_iSAMErr        INTEGER;
DEFINE vi_iSAMData        CHAR(80);
DEFINE vc_Mensaje       CHAR(80);
DEFINE vd_FechaHoy      DATE;
DEFINE vc_AnioMes       CHAR(6);
DEFINE vc_AnioMes2       CHAR(6);
DEFINE vi_num_serial    INTEGER;
DEFINE vc_rfc           CHAR(13);
DEFINE vc_ref_ret       CHAR(20);
DEFINE vc_tipo_cta      CHAR(1);
DEFINE vc_sucursal      CHAR(4);
DEFINE vc_num_cta       CHAR(20);
DEFINE vd_fecha_mov     DATE;
DEFINE vm_imp_tot_dep   MONEY(10,2);
DEFINE vm_imp_ide       MONEY(10,2);
DEFINE vc_user_insert   CHAR(8);
DEFINE vd_fecha_insert  DATE;
DEFINE vc_proceso       CHAR(50);
DEFINE vc_tabla         CHAR(30);
DEFINE vc_detalle_mov   CHAR(200);
DEFINE vc_detalle_mov2   CHAR(200);
DEFINE vc_Cuenta        CHAR(20);
DEFINE vc_Cuenta2       CHAR(20);
DEFINE vc_Credito        CHAR(20);
DEFINE vi_secuencia     INTEGER;
DEFINE vc_num_tarjeta   CHAR(20);
DEFINE vc_rfc_ori       CHAR(13);
DEFINE vc_numsolic      CHAR(20);
DEFINE vc_statusolic    CHAR(2);
DEFINE vi_MaxSec        INTEGER;
DEFINE vi_SecTit        INTEGER;
DEFINE vc_NumCteDirec   CHAR(20);
DEFINE vi_SecDirec      INTEGER;
DEFINE vd_FechaSolic    DATE;
DEFINE vc_TipoDir       CHAR(1);
DEFINE vc_estado       CHAR(1);
DEFINE vtransaccion INTEGER;
DEFINE vtel CHAR(13);
DEFINE vcd CHAR(3);
DEFINE cTipo_tel	 CHAR(1);
DEFINE cTipo_tel2	 CHAR(1);
DEFINE cStatus_tel	 CHAR(1);
DEFINE vmun CHAR(5);
DEFINE vnumcol INTEGER;
DEFINE vnumcall INTEGER;
DEFINE vnumext CHAR(10);
DEFINE vcodp CHAR(5);
DEFINE vsec INTEGER;
DEFINE vcont INTEGER;
DEFINE vtel2 CHAR(13);
DEFINE vcd2 CHAR(3);
DEFINE vmun2 CHAR(5);
DEFINE vnumcol2 INTEGER;
DEFINE vnumcall2 INTEGER;
DEFINE vnumext2 CHAR(10);
DEFINE vcodp2 CHAR(5);
DEFINE vsec2 INTEGER;
DEFINE vcont2 INTEGER;
DEFINE vcont3 INTEGER;
DEFINE pCte        CHAR(20);
DEFINE vcvepg CHAR(10);
DEFINE iExiste	INTEGER;
DEFINE cEmail CHAR(100);
DEFINE cEmail2 CHAR(100);

LET vc_CodRet = "00000";
LET vi_SqlErr = 0;
LET vi_iSAMErr=0;
LET vi_iSAMData="";
LET vc_Mensaje = "EL PROCESO SE EFECTUO CORRECTAMENTE";
LET vd_FechaHoy = "";
LET vc_AnioMes = "";
LET vc_AnioMes2 = "";
LET vi_num_serial = 0;
LET vc_rfc = "";
LET vc_ref_ret = "";
LET vc_tipo_cta = "";
LET vc_sucursal = "";
LET vc_num_cta = "";
LET vd_fecha_mov = "";
LET vm_imp_tot_dep = 0;
LET vm_imp_ide = 0;
LET vc_user_insert = "";
LET vd_fecha_insert = "";
LET vc_proceso = "FusionClientes";
LET vc_tabla = "";
LET vc_detalle_mov = "";
LET vc_detalle_mov2 = "";
LET vc_Cuenta = "";
LET vc_Cuenta2 = "";
LET vc_Credito = "";
LET vi_secuencia = 0;
LET vc_num_tarjeta = "";
LET vc_rfc_ori = "";
LET vc_numsolic = "";
LET vc_statusolic = "";
LET vi_MaxSec = 0;
LET vi_SecTit = 0;
LET vc_NumCteDirec = "";
LET vi_SecDirec = 0;
LET vd_FechaSolic = "";
LET vc_TipoDir = "";
LET vtransaccion = 0;
LET vcont=0;
LET vcont2=0;
LET vcont3=0;
LET pCte="";
LET vcvepg="";
LET iExiste=0;	
LET cEmail="";
LET cEmail2="";

set isolation to dirty read;
set lock mode to wait 3;

    BEGIN WORK;

    BEGIN

    ON EXCEPTION SET vi_SqlErr,vi_iSAMErr,vi_iSAMData
        IF vi_SqlErr <> 0 THEN
            LET vc_CodRet = vi_SqlErr;
            LET vc_Mensaje = "ERROR NO CONTROLADO";
            ROLLBACK WORK;
            LET vc_detalle_mov2=vi_SqlErr||'|'||vi_iSAMErr||'|'||vi_iSAMData; 
            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov2, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);

            RETURN vc_CodRet, vc_Mensaje;
        END IF;
    END EXCEPTION;
	DELETE {+INDEX(bdinteg:si_fustelefonos2 idx_si_fustelefonos2_empresa)} FROM bdinteg:si_fustelefonos2 WHERE numcte IN (pClienteTitular,pClienteTraspasaCtas);
    DELETE  {+INDEX(bdinteg:si_fuscorreos2 si_fuscorreos2)} FROM bdinteg:si_fuscorreos2 WHERE numcte IN (pClienteTitular,pClienteTraspasaCtas);

  --SET DEBUG FILE TO "/informix/josea/sp_fustraspasotelefonos.out";
  --TRACE ON;

   --*******************************INICIA TRASPASO DE TELEFONOS *********************************************
    LET vc_tabla = "si_telefonos";
    LET vc_proceso='TELEFONOS';
	INSERT INTO bdinteg:si_fustelefonos(empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, 
	fecha_hora, user_insert, movil_fijo, status_stel, verificado, marcatel, fecha_actualiza,tel_confirmado,fech_confirmado)
	SELECT empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, 
	fecha_hora, user_insert, movil_fijo, status_stel, verificado, marcatel, fecha_actualiza,tel_confirmado,fech_confirmado  
	FROM bdinteg:si_telefonos WHERE numcte IN (pClienteTitular,pClienteTraspasaCtas);
		
    SELECT NVL(COUNT(*),0) INTO iExiste FROM bdinteg:si_telefonos WHERE numcte = pClienteTraspasaCtas;
	
	IF iExiste IS  NOT NULL OR iExiste<>0 THEN
        SELECT NVL(MAX(secuencia),0) INTO vi_MaxSec FROM bdinteg:si_telefonos WHERE numcte = pClienteTraspasaCtas;
   
		IF vi_MaxSec <> 0 THEN
		--******************************DEPURA TELEFONOS CLIENTE INCORRECTO ***************************************
			SET ISOLATION TO DIRTY READ;
			FOREACH   
				SELECT telefono,tipo_tel,secuencia INTO vtel,cTipo_tel,vsec FROM bdinteg:si_telefonos
				WHERE numcte = pClienteTraspasaCtas ORDER BY secuencia
				IF vcont=0 THEN
					LET vtel2 = vtel;
					LET cTipo_tel2 = cTipo_tel;
					LET vsec2 = vsec;
					LET vcont = vcont + 1;
					
					INSERT INTO bdinteg:si_fustelefonos2(empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, verificado, marcatel, fecha_actualiza,tel_confirmado,fech_confirmado)
					SELECT empresa, pClienteTitular AS numcte,telefono,tipo_tel,'A',secuencia,extension,carrier,canal,contacto,cofetel,fecha_hora,user_insert, movil_fijo, status_stel,verificado, marcatel, fecha_actualiza,tel_confirmado,fech_confirmado
                    FROM bdinteg:si_telefonos
				    WHERE numcte = pClienteTraspasaCtas AND secuencia = vsec;
				ELSE
					LET vtel2=vtel;
					LET cTipo_tel2 = cTipo_tel;
					LET vsec2=vsec;
					LET vcont2=vcont2 + 1;
					
					IF NOT EXISTS (SELECT telefono FROM bdinteg:si_fustelefonos2 WHERE numcte = pClienteTitular AND telefono = vtel AND tipo_tel = cTipo_tel ) THEN
						IF EXISTS (SELECT telefono FROM bdinteg:si_fustelefonos2 WHERE numcte = pClienteTitular  AND tipo_tel = cTipo_tel) THEN
							UPDATE bdinteg:si_fustelefonos2 SET status_tel = 'C' 
							WHERE numcte = pClienteTitular 
							AND tipo_tel = cTipo_tel;									
						END IF;
						
                        INSERT INTO bdinteg:si_fustelefonos2(empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, verificado, marcatel, fecha_actualiza,tel_confirmado,fech_confirmado)
                        SELECT empresa,pClienteTitular AS numcte,telefono,tipo_tel,'A',(SELECT NVL(MAX(secuencia),0)+1 FROM si_fustelefonos2 WHERE numcte = pClienteTitular ) AS secuencia, extension,carrier,canal,contacto,cofetel,fecha_hora,user_insert, movil_fijo, status_stel, verificado, marcatel, fecha_actualiza,tel_confirmado,fech_confirmado       
                        FROM bdinteg:si_telefonos
                        WHERE numcte = pClienteTraspasaCtas 
							AND secuencia=vsec;						
					END IF;
					LET vcont=vcont + 1;
				END IF;
			END FOREACH;

            SET ISOLATION TO DIRTY READ;
            FOREACH
                SELECT telefono, secuencia, tipo_tel INTO vc_NumCteDirec, vi_SecDirec, vc_TipoDir FROM bdinteg:si_telefonos WHERE numcte = pClienteTraspasaCtas
                LET vc_detalle_mov = TRIM(vc_NumCteDirec)||'|'||TRIM(vc_TipoDir)||'|'||vi_SecDirec;
                INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
                VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT); 
            END FOREACH;

			LET vcont=0;
			LET vcont2=0;
			SELECT {+INDEX(bdinteg:si_fustelefonos2 idx_si_fustelefonos2_empresa)}  NVL(MAX(secuencia),0) INTO vi_MaxSec FROM bdinteg:si_fustelefonos2 WHERE numcte = pClienteTitular;
		--*****************************DEPURA TELEFONOS CLIENTE TITULAR *******************************************
			SET ISOLATION TO DIRTY READ;
			FOREACH   
				SELECT telefono,tipo_tel,status_tel, secuencia 
				INTO vtel,cTipo_tel,cStatus_tel, vsec from bdinteg:si_telefonos
				WHERE numcte = pClienteTitular ORDER BY secuencia
				IF vcont=0 THEN
					LET vtel2=vtel;
					LET cTipo_tel2 = cTipo_tel;
					LET vsec2=vsec;
					LET vcont=vcont + 1;
					
					IF NOT EXISTS (SELECT telefono FROM bdinteg:si_fustelefonos2 WHERE numcte = pClienteTitular AND telefono = vtel AND tipo_tel = cTipo_tel) THEN
						IF EXISTS(SELECT telefono FROM bdinteg:si_fustelefonos2 WHERE numcte = pClienteTitular AND tipo_tel = cTipo_tel) THEN
							UPDATE bdinteg:si_fustelefonos2 SET status_tel = 'C' 
							WHERE numcte = pClienteTitular 
								AND tipo_tel = cTipo_tel; 
						END IF;
					
						INSERT INTO bdinteg:si_fustelefonos2(empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, verificado, marcatel, fecha_actualiza,tel_confirmado,fech_confirmado)
						SELECT empresa,numcte,telefono,tipo_tel,'A',(SELECT NVL(MAX(secuencia),0)+1 FROM si_fustelefonos2 WHERE numcte = pClienteTitular ) AS secuencia,extension,carrier,canal,contacto,cofetel,fecha_hora,user_insert, movil_fijo, status_stel, verificado, marcatel, fecha_actualiza,tel_confirmado,fech_confirmado    
						FROM bdinteg:si_telefonos
						WHERE numcte = pClienteTitular 
							AND secuencia=vsec;
					END IF;
				ELSE											
					LET vtel2=vtel;
					LET cTipo_tel2 = cTipo_tel;
					LET vsec2=vsec;
					LET vcont2=vcont2 + 1;
					
					IF NOT EXISTS (SELECT telefono FROM bdinteg:si_fustelefonos2 WHERE numcte = pClienteTitular AND telefono = vtel AND tipo_tel = cTipo_tel  AND status_tel = cStatus_tel ) THEN
						IF EXISTS(SELECT telefono FROM bdinteg:si_fustelefonos2 WHERE numcte = pClienteTitular AND tipo_tel = cTipo_tel) THEN
							UPDATE bdinteg:si_fustelefonos2 SET status_tel = 'C' 
							WHERE numcte = pClienteTitular 
								AND tipo_tel = cTipo_tel; 
						END IF;

						INSERT INTO bdinteg:si_fustelefonos2(empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, verificado, marcatel, fecha_actualiza,tel_confirmado,fech_confirmado)
						SELECT empresa,numcte,telefono,tipo_tel,'A',(SELECT NVL(MAX(secuencia),0)+1 FROM si_fustelefonos2 WHERE numcte = pClienteTitular ) AS secuencia,extension,carrier,canal,contacto,cofetel,fecha_hora,user_insert, movil_fijo, status_stel, verificado, marcatel, fecha_actualiza,tel_confirmado,fech_confirmado         
						FROM bdinteg:si_telefonos
						WHERE numcte = pClienteTitular 
							AND secuencia=vsec;
						
						LET vcont=vcont + 1;
					END IF;
					
				 END IF;
			END FOREACH;

			LET vcont=0;
			LET vcont2=0;
		--*****************************DEPURA TODOS TELEFONOS *******************************************
		--	SET ISOLATION TO DIRTY READ;
		/*	FOREACH   
				SELECT {+INDEX(bdinteg:si_fustelefonos2 idx_si_fustelefonos2_empresa)} telefono,tipo_tel,secuencia INTO vtel,vcd,vsec FROM bdinteg:si_fustelefonos2
				WHERE numcte = pClienteTitular ORDER BY telefono,tipo_tel
				IF vcont=0 THEN
					LET vtel2=vtel;
					LET vcd2=vcd;
					LET vsec2=vsec;
					LET vcont=vcont + 1;
				ELSE
					IF vtel2=vtel AND vcd2=vcd THEN

						DELETE {+INDEX(bdinteg:si_fustelefonos2 idx_si_fustelefonos2_empresa)} FROM bdinteg:si_fustelefonos2
						WHERE numcte = pClienteTitular AND secuencia=vsec AND tipo_tel=vcd;	
					ELSE
						LET vtel2=vtel;
						LET vcd2=vcd;
						LET vsec2=vsec;
						LET vcont2=vcont2 + 1;
					END IF;
					LET vcont=vcont + 1;
				 END IF;
			END FOREACH;
			----- ACTUALIZA SECUENCIAS 
			SET ISOLATION TO DIRTY READ;   
			FOREACH
				SELECT {+INDEX(bdinteg:si_fustelefonos2 idx_si_fustelefonos2_empresa)} secuencia, tipo_tel INTO vi_SecDirec, vc_TipoDir FROM bdinteg:si_fustelefonos2 WHERE numcte = pClienteTitular ORDER BY secuencia
				LET vi_SecDirec=vi_SecDirec;
				LET vcont3=vcont3 + 1;
				UPDATE {+INDEX(bdinteg:si_fustelefonos2 idx_si_fustelefonos2_empresa)} bdinteg:si_fustelefonos2 SET secuencia= vcont3 WHERE numcte = pClienteTitular AND secuencia = vi_SecDirec AND tipo_tel = vc_TipoDir;
			END FOREACH;
			*/
            DELETE {+INDEX(bdinteg:si_telefonos_actual idx_telact_cte)}  FROM bdinteg:si_telefonos_actual WHERE numcte IN(pClienteTitular,pClienteTraspasaCtas);
			DELETE FROM bdinteg:si_telefonos WHERE numcte IN(pClienteTitular,pClienteTraspasaCtas);
			--INSERTA LOS REGISTROS EN LA TABLA si_telefonos 
			SET ISOLATION TO DIRTY READ;
			FOREACH 
				SELECT secuencia 
				INTO vsec 
				FROM bdinteg:si_fustelefonos2
				WHERE numcte = pClienteTitular 
				ORDER BY secuencia ASC
								
				INSERT INTO bdinteg:si_telefonos(empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, verificado, marcatel, fecha_actualiza,tel_confirmado,fech_confirmado)
				SELECT empresa,numcte,telefono,tipo_tel,status_tel, secuencia,extension,carrier,canal,contacto,cofetel,fecha_hora,user_insert, movil_fijo, status_stel, verificado, marcatel, fecha_actualiza,tel_confirmado,fech_confirmado    
				FROM bdinteg:si_fustelefonos2
				WHERE numcte = pClienteTitular 
				AND secuencia = vsec;					
			END FOREACH; 
		END IF;
	END IF;
	DELETE {+INDEX(bdinteg:si_fustelefonos2 idx_si_fustelefonos2_empresa)} FROM bdinteg:si_fustelefonos2 WHERE numcte IN(pClienteTitular,pClienteTraspasaCtas);
   --*******************************INICIA TRASPASO DE EMAIL *********************************************
    LET vc_tabla = "si_correos";
    LET vc_proceso='EMAIL';

	INSERT INTO bdinteg:si_fuscorreos(empresa, numcte, correo_elec, tipo_correo, status_correo, secuencia, canal, fecha_hora, user_insert, valida_correo, valido,fecha_valida)
	SELECT empresa, numcte, correo_elec, tipo_correo, status_correo, secuencia, canal, fecha_hora, user_insert, valida_correo, valido,fecha_valida
	FROM bdinteg:si_correos WHERE numcte IN (pClienteTitular,pClienteTraspasaCtas);
		
    SELECT NVL(COUNT(*),0) INTO iExiste FROM bdinteg:si_correos WHERE numcte = pClienteTraspasaCtas;
	
	IF iExiste IS  NOT NULL OR iExiste<>0 THEN
        SELECT NVL(MAX(secuencia),0) INTO vi_MaxSec FROM bdinteg:si_correos WHERE numcte = pClienteTraspasaCtas;
   
		IF vi_MaxSec <> 0 THEN
		--******************************DEPURA EMAIL CLIENTE INCORRECTO ***************************************
			LET vcont=0;
			LET vcont2=0;
			SET ISOLATION TO DIRTY READ;
			FOREACH   
				SELECT Lower(trim(correo_elec)),tipo_correo,secuencia INTO cEmail,vcd,vsec from bdinteg:si_correos
				WHERE numcte = pClienteTraspasaCtas ORDER BY correo_elec,tipo_correo
				IF vcont=0 THEN
					LET cEmail2=cEmail;
					LET vcd2=vcd;
					LET vsec2=vsec;
					
					INSERT INTO bdinteg:si_fuscorreos2(empresa, numcte, correo_elec, tipo_correo, status_correo, secuencia, canal, fecha_hora, user_insert, valida_correo, valido,fecha_valida)
					SELECT empresa,pClienteTitular AS numcte,Lower(trim(correo_elec)),tipo_correo,'A',secuencia,canal,fecha_hora,user_insert, valida_correo, valido,fecha_valida
                    FROM bdinteg:si_correos
				    WHERE numcte = pClienteTraspasaCtas AND secuencia=vsec;
					
					LET vcont=vcont + 1;
				ELSE
					--IF cEmail2=cEmail AND vcd2=vcd THEN
					--ELSE
						LET cEmail2=cEmail;
						LET vcd2=vcd;
						LET vsec2=vsec;
                        LET vcont2=vcont2 + 1;
						
						IF NOT EXISTS (SELECT correo_elec FROM bdinteg:si_fuscorreos2 WHERE numcte = pClienteTitular AND correo_elec = cEmail AND tipo_correo = vcd ) THEN
							IF EXISTS (SELECT correo_elec FROM bdinteg:si_fuscorreos2 WHERE numcte = pClienteTitular  AND tipo_correo = vcd) THEN
								UPDATE bdinteg:si_fuscorreos2 SET status_correo = 'C' 
								WHERE numcte = pClienteTitular 
								AND tipo_correo = vcd;
							END IF;
							INSERT INTO bdinteg:si_fuscorreos2(empresa, numcte, correo_elec, tipo_correo, status_correo, secuencia, canal, fecha_hora, user_insert, valida_correo, valido,fecha_valida)
							SELECT empresa,pClienteTitular AS numcte,Lower(trim(correo_elec)),tipo_correo,'A',secuencia,canal,fecha_hora,user_insert, valida_correo, valido,fecha_valida
							FROM bdinteg:si_correos
							WHERE numcte = pClienteTraspasaCtas AND secuencia=vsec;
						END IF;
					--END IF;
					LET vcont=vcont + 1;
				END IF;
			END FOREACH;

            SET ISOLATION TO DIRTY READ;
            FOREACH
                SELECT Lower(trim(correo_elec)), secuencia, tipo_correo INTO cEmail, vi_SecDirec, vc_TipoDir FROM bdinteg:si_correos WHERE numcte = pClienteTraspasaCtas
                LET vc_detalle_mov = TRIM(cEmail)||'|'||TRIM(vc_TipoDir)||'|'||vi_SecDirec;
                INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
                VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT); 
             END FOREACH;

		LET vcont=0;
		LET vcont2=0;
		SELECT NVL(MAX(secuencia),0) INTO vi_MaxSec FROM bdinteg:si_fuscorreos2 WHERE numcte = pClienteTitular;
		--*****************************DEPURA EMAIL CLIENTE TITULAR *******************************************
			SET ISOLATION TO DIRTY READ;
			FOREACH   
				SELECT Lower(trim(correo_elec)),tipo_correo,secuencia INTO cEmail,vcd,vsec FROM bdinteg:si_correos
				WHERE numcte = pClienteTitular ORDER BY correo_elec,tipo_correo
				IF vcont=0 THEN
					LET cEmail2=cEmail;
					LET vcd2=vcd;
					LET vsec2=vsec;
					
					
					IF NOT EXISTS (SELECT correo_elec FROM bdinteg:si_fuscorreos2 WHERE numcte = pClienteTitular AND correo_elec = cEmail AND tipo_correo = vcd ) THEN
						IF EXISTS (SELECT correo_elec FROM bdinteg:si_fuscorreos2 WHERE numcte = pClienteTitular  AND tipo_correo = vcd) THEN
							UPDATE bdinteg:si_fuscorreos2 SET status_correo = 'C' 
							WHERE numcte = pClienteTitular 
							AND tipo_correo = vcd;
						END IF;
						
						INSERT INTO bdinteg:si_fuscorreos2(empresa, numcte, correo_elec, tipo_correo, status_correo, secuencia, canal, fecha_hora, user_insert, valida_correo, valido,fecha_valida)
						SELECT empresa,numcte,correo_elec,tipo_correo,'A',(secuencia + vi_MaxSec) AS secuencia,canal,fecha_hora,user_insert, valida_correo, valido,fecha_valida
						FROM bdinteg:si_correos
						WHERE numcte = pClienteTitular AND secuencia=vsec;
						
						LET vcont=vcont + 1;
					END IF;
				ELSE
					--IF cEmail2=cEmail AND vcd2=vcd THEN
					--ELSE
						LET cEmail2=cEmail;
						LET vcd2=vcd;
						LET vsec2=vsec;
						LET vcont2=vcont2 + 1;

						IF NOT EXISTS (SELECT correo_elec FROM bdinteg:si_fuscorreos2 WHERE numcte = pClienteTitular AND correo_elec = cEmail AND tipo_correo = vcd ) THEN
							IF EXISTS (SELECT correo_elec FROM bdinteg:si_fuscorreos2 WHERE numcte = pClienteTitular  AND tipo_correo = vcd) THEN
								UPDATE bdinteg:si_fuscorreos2 SET status_correo = 'C' 
								WHERE numcte = pClienteTitular 
								AND tipo_correo = vcd;
							END IF;
						
							INSERT INTO bdinteg:si_fuscorreos2(empresa, numcte, correo_elec, tipo_correo, status_correo, secuencia, canal, fecha_hora, user_insert, valida_correo, valido,fecha_valida)
							SELECT empresa,numcte,Lower(trim(correo_elec)),tipo_correo,'A',(secuencia + vi_MaxSec) AS secuencia,canal,fecha_hora,user_insert, valida_correo, valido,fecha_valida
							FROM bdinteg:si_correos
							WHERE numcte = pClienteTitular AND secuencia=vsec;
						
							LET vcont=vcont + 1;
						END IF;
					--END IF;
				END IF;
			END FOREACH;
		--*****************************DEPURA TODOS EMAILS *******************************************
			LET vcont=0;
			LET vcont2=0;
			SET ISOLATION TO DIRTY READ;
			FOREACH   
				SELECT Lower(trim(correo_elec)),tipo_correo,secuencia INTO cEmail,vcd,vsec FROM bdinteg:si_fuscorreos2
				WHERE numcte = pClienteTitular ORDER BY correo_elec,tipo_correo
				IF vcont=0 THEN
					LET cEmail2=cEmail;
					LET vcd2=vcd;
					LET vsec2=vsec;
					LET vcont=vcont + 1;
				ELSE
					IF cEmail2=cEmail AND vcd2=vcd THEN
						DELETE FROM bdinteg:si_fuscorreos2
						WHERE numcte = pClienteTitular AND secuencia=vsec AND tipo_correo=vcd;	
					ELSE
						LET cEmail2=cEmail;
						LET vcd2=vcd;
						LET vsec2=vsec;
						LET vcont2=vcont2 + 1;
					END IF;
					LET vcont=vcont + 1;
				 END IF;
			END FOREACH;
			----- ACTUALIZA SECUENCIAS 
            LET vi_SecDirec=0;
            LET vcont3=0;
			SET ISOLATION TO DIRTY READ;   
			FOREACH
				SELECT secuencia, tipo_correo INTO vi_SecDirec, vc_TipoDir FROM bdinteg:si_fuscorreos2 WHERE numcte = pClienteTitular ORDER BY secuencia
				LET vi_SecDirec=vi_SecDirec;
				LET vcont3=vcont3 + 1;
				UPDATE  bdinteg:si_fuscorreos2 set secuencia= vcont3 WHERE numcte = pClienteTitular AND secuencia = vi_SecDirec AND tipo_correo = vc_TipoDir;
			END FOREACH;

    		DELETE FROM bdinteg:si_correos WHERE numcte IN(pClienteTitular,pClienteTraspasaCtas);

			INSERT INTO bdinteg:si_correos(empresa, numcte, correo_elec, tipo_correo, status_correo, secuencia, canal, fecha_hora, user_insert, valida_correo, valido,fecha_valida)
			SELECT empresa, numcte, correo_elec, tipo_correo, status_correo, secuencia, canal, fecha_hora, user_insert, valida_correo, valido,fecha_valida
			FROM bdinteg:si_fuscorreos2
			WHERE numcte = pClienteTitular;			

		END IF;
	END IF;
	DELETE FROM bdinteg:si_fuscorreos2 WHERE numcte IN(pClienteTitular,pClienteTraspasaCtas);

    IF vc_CodRet = "00000" THEN
        COMMIT WORK;
        RETURN vc_CodRet, vc_Mensaje;
    END IF;
END;
END PROCEDURE;