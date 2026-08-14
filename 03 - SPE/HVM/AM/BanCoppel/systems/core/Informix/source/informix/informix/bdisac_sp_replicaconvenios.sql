CREATE PROCEDURE "informix".sp_replicaconvenios(dFecha CHAR(10), cSucursal CHAR(4), siRegistros SMALLINT)

    RETURNING
    CHAR (5), CHAR (5), CHAR (3), CHAR (4), CHAR (40), CHAR (40), CHAR (1), CHAR(1), DATE, CHAR (1),
    MONEY(16,2), CHAR (1), MONEY(16,2), CHAR (1), MONEY(16,2), CHAR (1), MONEY(16,2),
    CHAR (1), MONEY(16,2), CHAR (1), MONEY(16,2), CHAR (1), MONEY(16,2), SMALLINT, CHAR(20),
	CHAR (20), CHAR (4), CHAR (4), CHAR (4), CHAR (4), CHAR (4);

    --Definicion de Variables
    DEFINE iSqlErr, iIsamErr   INTEGER;
    DEFINE cInfoErr            CHAR(100);
    DEFINE cCodRet             CHAR(5);
    DEFINE cCodRet2            CHAR(5);
    DEFINE dFechaHoy           DATE;
    DEFINE cNumCategoria       CHAR(3);
    DEFINE cNumConvenio        CHAR(4);
    DEFINE cNomCategoria       CHAR(40);
    DEFINE cNomConvenio        CHAR(40);
    DEFINE cStatusConvenio     CHAR(1);
    DEFINE dFechaAct           DATE;
    DEFINE cflgporccomtrans    CHAR (1);
    DEFINE dporccomtransaccion MONEY(16,2);
    DEFINE cflgporccomtotal    CHAR (1);
    DEFINE dporccomtotal       MONEY(16,2);
    DEFINE cflgimpcomtrans     CHAR (1);
    DEFINE dimpcomtrans        MONEY(16,2);
    DEFINE cflgimpcomtotal     CHAR (1);
    DEFINE dimpcomtotal        MONEY(16,2);
    DEFINE cflgivaincluido     CHAR (1);
    DEFINE divaincluido        MONEY(16,2);
    DEFINE cflgporccomtranscte CHAR (1);
    DEFINE dporccomtranscte    MONEY(16,2);
    DEFINE cflgimpcomtranscte  CHAR (1);
    DEFINE dimpcomtranscte     MONEY(16,2);
    DEFINE ctipoReferencia     CHAR(1);
    DEFINE siCiclo             SMALLINT;
	DEFINE iProceso_automatico 		   SMALLINT; 
	DEFINE cCuenta_prestadora  		   CHAR (20);
	DEFINE cCuenta_contable    		   CHAR (20);
	DEFINE cTrans_suc_cargo            CHAR (4);
    DEFINE cTrans_suc_efectivo         CHAR (4);
	DEFINE cTrans_cen_cargo_cliente    CHAR (4); 
	DEFINE cTrans_cen_efectivo_cliente CHAR (4); 
	DEFINE cTrans_cen_abono_convenio   CHAR (4);
	
    --DEFINE cCuentaServicio     CHAR(20);
    --DEFINE cCodParametro       CHAR(5);

        -- Inicializa variables
    LET cCodRet             = "00000";
    LET cCodRet2            = "00000";
    LET dFechaHoy           = "01-01-1900";
    LET cNumCategoria       = "";
    LET cNumConvenio        = "";
    LET cNomCategoria       = "";
    LET cNomConvenio        = "";
    LET cStatusConvenio     = "";
    LET dFechaAct           = "01-01-1900";
    LET cflgporccomtrans    = "";
    LET dporccomtransaccion = 0;
    LET cflgporccomtotal    = "";
    LET dporccomtotal       = 0;
    LET cflgimpcomtrans     = "";
    LET dimpcomtrans        = 0;
    LET cflgimpcomtotal     = "";
    LET dimpcomtotal        = 0;
    LET cflgivaincluido     = "";
    LET divaincluido        = 0;
    LET cflgporccomtranscte = "";
    LET dporccomtranscte    = 0;
    LET cflgimpcomtranscte  = "";
    LET dimpcomtranscte     = 0;
    LET ctipoReferencia     = "";
    LET siCiclo             = 0;
    --LET cCuentaServicio     = "";
    --LET cCodParametro       = "";
	LET iProceso_automatico  = 0;
	LET cCuenta_prestadora   = "";
	LET cCuenta_contable     = "";
	LET cTrans_suc_cargo     = "";
    LET cTrans_suc_efectivo   = "";
	LET cTrans_cen_cargo_cliente = "";
	LET cTrans_cen_efectivo_cliente = "";
	LET cTrans_cen_abono_convenio   = "";

    --debug flag
    --SET DEBUG FILE TO "/tmp/sp_replicacatalogosconvenios.out";
    --TRACE ON;


    BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
                IF iSqlErr <> 0 THEN
                    LET cCodRet = iSqlErr;
                    EXECUTE PROCEDURE sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_ProcesoCierreSAC");
                    RETURN cCodRet, cCodRet2, cNumCategoria, cNumConvenio, cNomCategoria, cNomConvenio, cStatusConvenio, ctipoReferencia, dFechaAct, cflgporccomtrans,
                    dporccomtransaccion, cflgporccomtotal, dporccomtotal, cflgimpcomtrans, dimpcomtrans, cflgimpcomtotal,
                    dimpcomtotal, cflgivaincluido, divaincluido, cflgporccomtranscte, dporccomtranscte, cflgimpcomtranscte,
                    dimpcomtranscte, iProceso_automatico, cCuenta_prestadora, cCuenta_contable, cTrans_suc_cargo, 
                    cTrans_suc_efectivo, cTrans_cen_cargo_cliente, cTrans_cen_efectivo_cliente, cTrans_cen_abono_convenio;
                END IF;
        END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

        -- Obtiene la fecha actual del sistema
        SELECT fecha_hoy
        INTO dFechaHoy
        FROM sac_fechas;

        FOREACH
            SELECT a.numcategoria, a.numconvenio, b.nombrecategoria, a.nomconvenio, a.statusconvenio, tipo_referencia, a.fechaactualizacion,
                   a.flgporccomtrans_conv, a.porc_com_trans_conv, a.flgporccomtotal_conv, a.porc_com_total_conv, a.flgimpcomtrans_conv, a.imp_com_trans_conv,
                   a.flgimpcomtotal_conv, a.imp_com_total_conv, a.flgivaincluido_conv, a.iva_convenio, a.flgporccomtrans_cte, a.porc_com_trans_cte,
                   a.flgimpcomtrans_cte, a.imp_com_trans_cte, a.proceso_automatico, a.cuenta_prestadora, a.cuenta_contable, a.trans_suc_cargo, 
                   a.trans_suc_efectivo, a.trans_cen_cargo_cliente, a.trans_cen_efectivo_cliente, a.trans_cen_abono_convenio
            INTO cNumCategoria, cNumConvenio, cNomCategoria, cNomConvenio, cStatusConvenio, ctipoReferencia, dFechaAct, cflgporccomtrans,
                 dporccomtransaccion, cflgporccomtotal, dporccomtotal, cflgimpcomtrans, dimpcomtrans, cflgimpcomtotal,
                 dimpcomtotal, cflgivaincluido, divaincluido, cflgporccomtranscte, dporccomtranscte, cflgimpcomtranscte,
                 dimpcomtranscte, iProceso_automatico, cCuenta_prestadora, cCuenta_contable, cTrans_suc_cargo, 
                 cTrans_suc_efectivo, cTrans_cen_cargo_cliente, cTrans_cen_efectivo_cliente, cTrans_cen_abono_convenio
            FROM sac_convenios a, sac_categorias b
            WHERE fechaactualizacion > dFecha
            AND fechaactualizacion < dFechaHoy
            AND a.numcategoria = b.numcategoria

            --LET cCodParametro = TRIM(cNumCategoria) || TRIM(cNumConvenio);
            --SELECT valor INTO cCuentaServicio FROM bdisac:sac_param WHERE cod_param = CAST(cCodParametro AS INTEGER);
            LET siCiclo = siCiclo + 1;

            IF siCiclo <= siRegistros THEN
                CONTINUE FOREACH;
            END IF;

            RETURN cCodRet, cCodRet2, cNumCategoria, cNumConvenio, cNomCategoria, cNomConvenio, cStatusConvenio, ctipoReferencia, dFechaAct, cflgporccomtrans,
                 dporccomtransaccion, cflgporccomtotal, dporccomtotal, cflgimpcomtrans, dimpcomtrans, cflgimpcomtotal,
                 dimpcomtotal, cflgivaincluido, divaincluido, cflgporccomtranscte, dporccomtranscte, cflgimpcomtranscte,
                 dimpcomtranscte, iProceso_automatico, cCuenta_prestadora, cCuenta_contable, cTrans_suc_cargo, 
                 cTrans_suc_efectivo, cTrans_cen_cargo_cliente, cTrans_cen_efectivo_cliente, cTrans_cen_abono_convenio WITH RESUME;
        END FOREACH;

        IF cNumConvenio = "" OR cNumConvenio IS NULL THEN
            LET cCodRet2 = "00001";
            RETURN cCodRet, cCodRet2, cNumCategoria, cNumConvenio, cNomCategoria, cNomConvenio, cStatusConvenio, ctipoReferencia, dFechaAct, cflgporccomtrans,
            dporccomtransaccion, cflgporccomtotal, dporccomtotal, cflgimpcomtrans, dimpcomtrans, cflgimpcomtotal,
            dimpcomtotal, cflgivaincluido, divaincluido, cflgporccomtranscte, dporccomtranscte, cflgimpcomtranscte,
            dimpcomtranscte, iProceso_automatico, cCuenta_prestadora, cCuenta_contable, cTrans_suc_cargo, 
            cTrans_suc_efectivo, cTrans_cen_cargo_cliente, cTrans_cen_efectivo_cliente, cTrans_cen_abono_convenio;
        END IF;

        IF NOT EXISTS (SELECT numsucursal FROM sac_actualizacionsucursales WHERE numsucursal = cSucursal) THEN
            INSERT INTO sac_actualizacionsucursales VALUES (cSucursal, dFechaAct, dFechaHoy, 0);
        ELSE
            UPDATE sac_actualizacionsucursales SET flagconfirmado = 0 WHERE numsucursal = cSucursal;
        END IF;
    END;
END PROCEDURE
DOCUMENT
    'AUTOR : Jesus Antonio M',
    'DESCRIPCION: Obtiene todos los convenios que sufrieron modificaciones para su replicacion',
    'EJECUTADO O LLAMADO POR: caja.exe',
    'FECHA : oct del 2008',
	'AUTOR MODIFICACION: Dulce Ramirez',
    'DESCRIPCION: Se modifica para que regrese mas retornos',
    'VERSION: 20081024',
    'BD    : bdisac';

CREATE PROCEDURE "informix".sp_actualiza_cte_remesa(cnumcte CHAR(20), csucursal CHAR(4), ctipo_cte CHAR(2), cpais_emision CHAR(3),
							dfecha_vencimiento DATE, cusuario CHAR(8), cflujo CHAR(1))
--DATOS DE SALIDA							
RETURNING
	CHAR(5) AS CodigoRetorno;
	
--DECLARACION DE VARIABLES
DEFINE iSqlErr        		INTEGER;
DEFINE iIsamErr         	INTEGER;
DEFINE cCodRet        		CHAR(5);

--INICIALIZACION DE VARIABLES
LET iSqlErr       	   = 0;
LET iIsamErr           = 0 ;
LET cCodRet	           = '00000';
SET ISOLATION TO DIRTY READ;	
SET LOCK MODE TO WAIT 3;
	
--SET DEBUG FILE TO "/tmp/Anayeli.out";
--TRACE ON;

	BEGIN
	--CONTROL DE ERRORES 'INFORMIX' NO CONTROLADOS
		ON EXCEPTION SET iSqlErr, iIsamErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;

	--VALIDACIÃN DE PARAMETROS DE ENTRADA.
			IF (cnumcte = '') OR (cnumcte IS NULL) OR (csucursal = '') OR (csucursal IS NULL) OR (cusuario = '') OR 
			   (cusuario IS NULL) OR (cflujo = '') OR (cflujo IS NULL) THEN
				LET cCodRet = '00002'; --FALTAN PARAMETROS
				RETURN cCodRet;
			END IF;
	
		IF cflujo = 1 THEN  --FLUJO(1):USUARIO DE REMESA.
			--REALIZA BUSQUEDA EN LA TABLA "sac_cte_remesas" PARA VERIFICAR SI EXISTE.
			IF EXISTS (SELECT numcte FROM bdisac:"informix".sac_cte_remesas WHERE numcte = cnumcte) THEN
			--SI YA EXISTEN LOS DATOS, SE ACTUALIZAN.
			UPDATE bdisac:"informix".sac_cte_remesas SET sucursal = csucursal, tipo_cte = ctipo_cte, pais_emision = cpais_emision, fecha_vencimiento = dfecha_vencimiento,
			usuario = cusuario, fecha_insert = current WHERE numcte =cnumcte;
			LET cCodRet = '00000'; -- SE ACTUALIZARON LOS DATOS CORRECTAMENTE.
			RETURN cCodRet;
		ELSE
			--SI NO EXISTEN LOS DATOS DEL CTE. EN LA TABLA "sac_cte_remesas" SE INSERTAN.
			INSERT INTO bdisac:"informix".sac_cte_remesas (numcte, fecha_alta, sucursal, tipo_cte, pais_emision, fecha_vencimiento, usuario, fecha_insert) 
			VALUES (cnumcte, current, csucursal, ctipo_cte, cpais_emision, dfecha_vencimiento, cusuario, current);
			LET cCodRet = '00000'; -- SE INSERTARON LOS DATOS CORRECTAMENTE.
			RETURN cCodRet;
		END IF;
		
		ELIF cflujo = 2 THEN -- FLUJO(2): MANTENIMIENTO CLIENTE TITULAR.
			UPDATE bdisac:"informix".sac_cte_remesas SET pais_emision = cpais_emision, fecha_vencimiento = dfecha_vencimiento --DATOS DEL PASAPORTE
			WHERE numcte = cnumcte;
			LET cCodRet = '00000'; --SE ACTUALIZARON LOS DATOS CORRECTAMENTE.
		END IF;
		RETURN cCodRet;
	END;
END PROCEDURE
--'DOCUMENT',
--'FOLIO: 197',
--'DESCRIPCION: ACTUALIZA LA INFORMACIÃN DEL USUARIO DE REMESAS EN LA TABLA SAC_CTE_REMESAS, EN CASO DE NO EXISTIR; INSERTA LOS DATOS.',
--'AUTOR: ANAYELI CAMACHO GUTIERRÃZ',
--'SUSTENTO: RQI 63 266 ALTA DE USUARIOS DE REMESA OFI',
--'FECHA DE CREACION: 21/03/2017',
--'SOLICITA: JAIME GONZALEZ',
--'VERSION: 1.0 20170321',
--'BD: BDISAC',
--'------------------------------------------------------------------------------------------------------------------------';;

CREATE PROCEDURE "informix".sp_app_consrevrem(pSucursal CHAR(4), pFolio CHAR(16))

	RETURNING 
	CHAR(6) AS CodRet,--Codigo de retorno
	CHAR(40) AS Remesa,
	CHAR(4) AS Sucursal,
	CHAR(8) AS NumEmpleado,
	CHAR(16) AS FolioSuc,
	CHAR(1) As StatusCancel; 
	
	 --DEFINICION DE VARIABLES--
    DEFINE sql_err      	INT;
    DEFINE cCodRet      	CHAR(6);
	DEFINE cRemesa			CHAR(40);
	DEFINE cSucursal		CHAR(4) ;
	DEFINE cNumEmpleado		CHAR(8) ;
	DEFINE cFolioSuc		CHAR(16);
	DEFINE cStatusCancel	CHAR(1) ; 
	
	
	--INICIALIZACION DE VARIABLES--
    LET sql_err 		= 0;
    LET cCodRet 		= '000000';
	LET cRemesa			= '';
	LET cSucursal		= '';
	LET cNumEmpleado	= '';
	LET cFolioSuc		= '';
	LET cStatusCancel	= ''; 
	
	
	--SET DEBUG FILE TO "/respaldosbd/Pedro/1542/sp_app_consrevrem.out";
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET cCodRet = sql_err;
				RETURN cCodRet,cRemesa,cSucursal,cNumEmpleado,cFolioSuc,cStatusCancel;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF NVL(pSucursal,'') = '' OR NVL(pFolio,'') = '' THEN
			LET cCodRet =   '000001'; --Faltan parÃ¡metros
			RETURN cCodRet,cRemesa,cSucursal,cNumEmpleado,cFolioSuc,cStatusCancel;
		END IF;
		
		SELECT referencia1, id_sucursal, usuario, folio_suc, status_cancelado
		INTO cRemesa,cSucursal,cNumEmpleado,cFolioSuc,cStatusCancel
		FROM 'informix'.sac_movimientos 
		WHERE id_sucursal = pSucursal 
		AND folio_suc = pFolio;

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
		 LET cCodRet='000002';
		END IF;
		let cStatusCancel = "N";
	RETURN cCodRet,NVL(cRemesa,''),NVL(cSucursal,''),NVL(cNumEmpleado,''),NVL(cFolioSuc,''),NVL(cStatusCancel,'');
	END 
END PROCEDURE
DOCUMENT
'Obtiene los datos de la remesa Appriza',
'AUTOR : Pedro G Jimenez Guzman',
'FECHA : 18-abril-2016',
'BD    : BDISAC';

CREATE PROCEDURE "informix".sp_consultaderechosvariosgdf_bpi(pId CHAR(2))
-- DESCRIPCION: CONSULTA TRAMITE
-- AUTOR: ING. CRUZ
-- FECHA: 10-05-2013
-- SISTEMA: PAGOS GDF BPI

RETURNING
CHAR(5)   AS CodigoRetorno,
CHAR(300)  AS Tramite;

DEFINE iSqlerr     	INTEGER;
DEFINE cCodRet     	CHAR(5);
DEFINE cTramite CHAR(300);

LET iSqlerr = 0;
LET cCodRet = '00000';
LET cTramite =''; 

--SET DEBUG FILE TO "/home/informix/bibiana/sp_consultaderechosvariosgdf_bpi.out";
--TRACE ON;
  
BEGIN

	ON EXCEPTION SET iSqlerr
		LET cCodRet= iSqlerr;
		RETURN cCodRet, cTramite;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF TRIM(NVL(pId,'')) = '' THEN
		LET cCodRet = '00001';
	END IF;
	
	SELECT concepto
	INTO cTramite
	FROM bdisac:"informix".sac_catderechosvariosgdf
	WHERE id = pId;
	
	IF (cTramite is NULL) OR (TRIM(cTramite)=='') THEN
		LET cCodRet = '00001';
		--EL TRAMITE NO SE ENCONTRO EN EL CATALOGO O NO TIENE DESCRIPCION
	END IF;
	
	RETURN cCodRet, cTramite;	
END
END PROCEDURE
DOCUMENT
"Autor : Ing. Cruz",
"FECHA : 10-05-2013",
"Descripcion: Consulta el campo tramite del catalogo de trÃ¡mites.",
"SISTEMA: PAGOS GDF BPI";

CREATE PROCEDURE "informix".sp_bitacora_proceso(p_tipo VARCHAR(10), p_id_proceso INTEGER, p_id_subproceso INTEGER, p_nombre_proceso VARCHAR(100),
												p_nombre_subproceso VARCHAR(100), p_usuario CHAR(8))
												RETURNING INTEGER AS v_id_proceso, INTEGER AS v_id_subproceso;
												
	DEFINE iSqlErr              	INTEGER;
	DEFINE iIsamErr             	INTEGER;
	DEFINE cInfoErr             	CHAR(100);
	DEFINE iCuenta					INTEGER;
	DEFINE iCuenta2					INTEGER;
	DEFINE iIdProceso				INTEGER;
	DEFINE cSubproceso				CHAR(100);
	DEFINE cCodRet              	CHAR(5);
	DEFINE v_id_proceso				INTEGER;
	DEFINE v_id_subproceso			INTEGER;
	DEFINE v_sql					CHAR(1000);
	DEFINE vstmt					CHAR(250);
	
	LET iCuenta						= 0;
	LET iCuenta2					= 0;
	LET v_id_proceso				= 0;
	LET v_sql						= '';
	LET vstmt						= '';
	
	--SET DEBUG FILE TO "/tmp/adrian/sp_bitacora_proceso.out";
	--TRACE ON;
	
	BEGIN
		
		ON EXCEPTION SET isqlerr, iisamerr, cinfoerr
			IF isqlerr <> 0 THEN
				LET cCodRet = isqlerr;
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_GuardaMensajeerror (isqlerr, iisamerr, cinfoerr, "sp_bitacoraspj");
			END IF;
		END EXCEPTION;
		
		IF p_tipo = 'ACTUALIZA' THEN
		
			IF NOT ((p_id_proceso <= 0 OR p_id_proceso IS NULL) OR (p_nombre_proceso = '' OR p_nombre_proceso IS NULL)
			OR (p_nombre_subproceso = '' OR p_nombre_subproceso IS NULL) OR (p_usuario = '' OR p_usuario IS NULL)) THEN
			
				IF p_id_subproceso = 0 THEN
					
					SELECT NVL(MAX(id_subproceso),0)+1
					INTO   iCuenta2
					FROM   bdisac:"informix".sac_monitor
					WHERE  id_proceso  = p_id_proceso;
					
					LET p_id_subproceso = iCuenta2;
				
					--INSERT INTO bdisac:"informix".sac_monitor (id_proceso, id_subproceso, nombre_proceso, nombre_subproceso, usuario, fecha_ini_corrida)
					--VALUES (p_id_proceso, p_id_subproceso, p_nombre_proceso, p_nombre_subproceso, p_usuario, CURRENT);
					
					LET v_sql = 'echo " INSERT INTO bdisac:sac_monitor (id_proceso,  id_subproceso, nombre_proceso, nombre_subproceso, ' || 
				    'usuario, fecha_ini_corrida) VALUES '||
                    '('''||p_id_proceso||''', '''||p_id_subproceso||''', '''||TRIM(p_nombre_proceso)||''', '''||TRIM(p_nombre_subproceso)||''', '''||p_usuario||''','||
                    '(SELECT CURRENT FROM bdisac:sac_fechas));" > /tmp/inserta_bitacora_proceso_1.sql';
					SYSTEM v_sql;
					
					LET vstmt = 'dbaccess bdisac /tmp/inserta_bitacora_proceso_1.sql';
					SYSTEM vstmt;
				
				ELSE
				
					--UPDATE bdisac:"informix".sac_monitor
					--SET    fecha_fin_corrida = CURRENT
					--WHERE  id_proceso        = p_id_proceso
					--AND    id_subproceso     = p_id_subproceso;
					
					LET v_sql = 'echo " UPDATE bdisac:sac_monitor ' ||
					' SET fecha_fin_corrida = (SELECT CURRENT FROM bdisac:sac_fechas) ' || 
				    ' WHERE id_proceso = '''||p_id_proceso||''' '||
					' AND   id_subproceso = '''||p_id_subproceso||''';" > /tmp/inserta_bitacora_proceso_2.sql';
					SYSTEM v_sql;
					
					LET vstmt = 'dbaccess bdisac /tmp/inserta_bitacora_proceso_2.sql';
					SYSTEM vstmt;
				
				END IF;
			
			END IF;
			
		ELIF p_tipo = 'ALTA' THEN
			
			IF NOT ((p_nombre_proceso = '' OR p_nombre_proceso IS NULL) OR (p_usuario = '' OR p_usuario IS NULL)) THEN
		
				SELECT NVL(MAX(id_proceso)+1,1)
				INTO   iIdProceso
				FROM   bdisac:"informix".sac_monitor;
				
				LET cSubproceso = 'INICIA PROCESO';
				LET p_id_subproceso = 1;
				
				--INSERT INTO sac_monitor (id_proceso,  id_subproceso, nombre_proceso, nombre_subproceso, usuario, fecha_ini_corrida, fecha_fin_corrida)
				--VALUES (iIdProceso, p_id_subproceso, p_nombre_proceso, cSubproceso, p_usuario, CURRENT, CURRENT);
				
				LET v_sql = 'echo " INSERT INTO bdisac:sac_monitor (id_proceso,  id_subproceso, nombre_proceso, nombre_subproceso, ' || 
				'usuario, fecha_ini_corrida, fecha_fin_corrida) VALUES '||
                '('''||iIdProceso||''', '''||p_id_subproceso||''', '''||TRIM(p_nombre_proceso)||''', '''||TRIM(cSubproceso)||''', '''||p_usuario||''','||
                '(SELECT CURRENT FROM bdisac:sac_fechas), (SELECT CURRENT FROM bdisac:sac_fechas));" > /tmp/inserta_bitacora_proceso.sql';
				SYSTEM v_sql;
				
				LET vstmt = 'dbaccess bdisac /tmp/inserta_bitacora_proceso.sql';
				SYSTEM vstmt;
				
				LET p_id_proceso = iIdProceso;
					
			END IF;
		
		END IF;
		
		LET v_id_proceso    = p_id_proceso;
		LET v_id_subproceso = p_id_subproceso;
		
		RETURN v_id_proceso, p_id_subproceso;

	END;
END PROCEDURE;