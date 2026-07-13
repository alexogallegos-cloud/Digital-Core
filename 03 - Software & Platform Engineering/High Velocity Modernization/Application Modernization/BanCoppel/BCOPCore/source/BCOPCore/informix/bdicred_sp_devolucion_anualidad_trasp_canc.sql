CREATE PROCEDURE "informix".sp_devolucion_anualidad_trasp_canc(pempresa CHAR(3))
RETURNING CHAR(5);       -- Codigo de Retorno  

---------------------------------------------------------------------------
--                         DEFINICION DE VARIABLES
---------------------------------------------------------------------------
DEFINE cCod_ret         CHAR(5);
DEFINE cMen_ret         CHAR(80);
DEFINE iSqlerr          INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cCodRet2         CHAR(5);
DEFINE cProceso         CHAR(4);
DEFINE cCod_retIB		CHAR(6);
DEFINE dFechaHoy        DATE;
DEFINE cFolioSuc        CHAR(16);
DEFINE sNoDiasMaxNoRet  SMALLINT;
DEFINE dMnto_Devol      DECIMAL(16,2);
DEFINE cNumCred         CHAR(20);
DEFINE cNumCte          CHAR(20);
DEFINE cSucursal        CHAR(4);
DEFINE cNumTarjeta      CHAR(20);
DEFINE dSdoCapInsol     DECIMAL(18,2);
DEFINE cFolioSucCancel  CHAR(16);
DEFINE dFech_prev_an	DATE;
DEFINE dFech_prox_an	DATE;

---------------------------------------------------------------------------
-- *                        ASIGNACION DE VARIABLES
---------------------------------------------------------------------------

--SET DEBUG FILE TO "/tmp/sp_devolucion_anualidad_trasp_canc.out";
--TRACE ON;

LET cCod_ret            = "00000";
LET cMen_ret            = "Proceso Exitoso";
LET iSqlerr             = 0;
LET iIsamErr            = 0;
LET cCodRet2            = '';
LET cProceso            = '0088';
LET cCod_retIB          = '000000';
LET dFechaHoy           = DATE(1);
LET cFolioSuc           = '';
LET sNoDiasMaxNoRet     = 0;
LET dMnto_Devol         = 0;
LET cNumCred            = '';
LET cNumCte             = '';
LET cSucursal           = '';
LET cNumTarjeta         = '';
LET dSdoCapInsol        = 0;
LET cFolioSucCancel     = '';
LET dFech_prev_an		= DATE(1);
LET dFech_prox_an		= DATE(1);
    
    ---------------------------------------------------------------------------
    -- *                        CONTROL DE ERRORES
    ---------------------------------------------------------------------------

BEGIN
    ON EXCEPTION SET iSqlerr, iIsamErr, cMen_ret
        IF iSqlerr != 0 THEN
            LET cCod_ret = iSqlerr;
            CALL bdicred:"informix".sp_inserta_bitacora(pempresa, cProceso, cCod_ret, 'ERROR TRASPASO DEVOL ANUALIDAD '||'-'||iIsamErr::CHAR ||'-'||cNumCred, '02') Returning cCod_retIB;
            RETURN cCod_ret;
        END IF;
    END EXCEPTION;

    SET LOCK MODE TO WAIT 4;

    ---------------------------------------------------------------------------
    -- *                        PROGRAMA PRINCIPAL
    ---------------------------------------------------------------------------

    CALL bdicred:"informix".sp_inserta_bitacora(pempresa, cProceso, cCod_ret, 'INICIA TRASPASO DEVOLUCION ANUALIDAD NO RETIRADA', '02') Returning cCod_RetIB;

    -- Obtiene la fecha actual
    SELECT fecha_hoy INTO dFechaHoy FROM bdicred:"informix".sd_fechas WHERE empresa = pempresa;
	
    -- Parametros: Maximo de numero de dias naturales para no realizar el retiro de la devolucion de comision por anualidad
    SELECT NVL(valor_numerico,0) INTO sNoDiasMaxNoRet
      FROM bdicred:sd_param_campania WHERE empresa = pempresa and tipo_campania = 70 and grupo_parametro = 'COMI_ANUAL' and num_parametro = 2;
    IF sNoDiasMaxNoRet = 0 THEN
        LET cCod_ret = '00001';		
		RETURN cCod_ret;    -- No existen parametros correctos
    END IF;

    -- Genera FolioSuc
    --EXECUTE PROCEDURE bdicheq:"informix".sp_generafolionomina("informix")INTO cCodRet2, cFolioSuc;
	EXECUTE PROCEDURE bdicheq:"informix".sp_generafolionomina(user)INTO cCodRet2, cFolioSuc;

    -- Realiza el traspaso de los creditos cuyo saldo no fue retirado en caja despues de 30 dias de haber sido depositado.

    FOREACH WITH HOLD   -- Obtiene los creditos con al menos 30 dias de no haber retirado la devolucion de anualidad.
        SELECT crd.num_credito, crd.numcte, crd.sucursal, ind.monto_devolucion, dos.sdo_cap_insoluto,	fecha_prox_anualidad
          INTO cNumCred,        cNumCte,    cSucursal,    dMnto_Devol,          dSdoCapInsol,			dFech_prox_an
          FROM bdicred:sd_indicador_cred ind
          JOIN bdicred:sd_maecred crd ON (ind.empresa = crd.empresa and ind.num_credito = crd.num_credito and crd.status_cred IN ('AA','E1') and crd.id_unidad_prod = 4)
          JOIN bdicred:sd_maesdos dos ON (dos.empresa = ind.empresa and dos.num_credito = ind.num_credito and nvl(dos.sdo_cap_insoluto,0) < 0)
         WHERE ind.empresa = pempresa
           AND nvl(date(ind.fecha_pre_devol_anual), date(1)) > date(1)
           AND nvl(date(ind.fecha_devol_anual), date(1)) = date(1)
           AND (nvl(date(ind.fecha_pre_devol_anual), date(1)) + sNoDiasMaxNoRet units day ) < dFechaHoy


        SELECT {+INDEX(bdicred:sd_tarjeta 193_600)} 
               tar.num_tarjeta INTO cNumTarjeta FROM bdicred:sd_tarjeta tar
         WHERE tar.empresa = pempresa and tar.num_credito = cNumCred and tar.secuencia = (select max(secuencia) from bdicred:sd_tarjeta 
               where tar.empresa = empresa and tar.num_credito = num_credito and tipo_tarjeta = 'T') AND tar.tipo_tarjeta = 'T'; 

        -- Realiza el cargo del traspaso del monto de la devolucion de comision de anualidad.
        EXECUTE PROCEDURE bdicred:"informix".cargo_cred(pempresa, cNumCred, cSucursal, user, '8254', (dSdoCapInsol * -1), cFolioSuc, cNumTarjeta, 0, 0, dFechaHoy,
                                                'TRASPASO DEVOL ANUALID', '', '') INTO cCodRet2;
        IF cCodRet2 <> '000' THEN 
            CONTINUE FOREACH; 
        END IF;
		
		LET dFech_prev_an = monthadd(dFech_prox_an, -12);

        BEGIN;	-- Marca credito que se realizo traspaso de devolucion y no retiro en ventanilla
            UPDATE bdicred:sd_indicador_cred SET fecha_trasp_devol_anual = CURRENT WHERE empresa = pempresa AND num_credito = cNumCred;

            -- Elimina cobros pendientes en caso de tener mas de una en Parcialidad Titular, Parcialidad Adicional y Diferimiento Contable.
            UPDATE bdicred:sd_comision_x_apertura_contable SET afec_pendientes = 0 WHERE empresa = pempresa AND num_credito = cNumCred 
               AND diferim_parcial IN ('PT', 'PA', 'DC') AND proceso_comision = 'ANUALIDAD' AND fecha_insert = dFech_prev_an;
        COMMIT;

        LET cCodRet2 = 0;
        LET cFolioSucCancel = '';
        -- Cancela los creditos a los que se les realizo el traspaso			-- FF1.- A petición del cliente   
        EXECUTE PROCEDURE bdicred:"informix".sp_cancelarcredito(pempresa, cNumCred, 'FF1', USER, USER, '3', cSucursal) INTO cCodRet2, cFolioSucCancel;

        IF cCodRet2 != '00000' THEN
            CONTINUE FOREACH;
            LET cNumCred = '';  LET cNumCte = '';   LET cSucursal = ''; LET dMnto_Devol = 0;    LET dSdoCapInsol = 0;   LET cCodRet2 = '';  LET cFolioSuc = '';
        END IF
        LET cNumCred = '';  LET cNumCte = '';   LET cSucursal = ''; LET dMnto_Devol = 0;    LET dSdoCapInsol = 0;   LET cCodRet2 = '';
		
    END FOREACH; 

    CALL bdicred:"informix".sp_inserta_bitacora(pempresa, cProceso, cCod_ret, 'TERMINA TRASPASO DEVOLUCION ANUALIDAD NO RETIRADA', '02') Returning cCod_RetIB;
    CALL bdicred:"informix".sp_inserta_bitacora(pempresa, cProceso, cCod_ret, 'INICIA CANCELACION CREDITOS CON SALDO EN CEROS', '02') Returning cCod_RetIB;

    -- Realiza la cancelación de creditos cuya devolución ya fue realizada y esta en ceros.
    LET cNumCred = '';  LET cNumCte = '';   LET cSucursal = ''; LET dMnto_Devol = 0;    LET dSdoCapInsol = 0;   LET cCodRet2 = '';  LET cFolioSuc = '';

    -- Genera FolioSuc
    --EXECUTE PROCEDURE bdicheq:"informix".sp_generafolionomina("informix")INTO cCodRet2, cFolioSuc;
	EXECUTE PROCEDURE bdicheq:"informix".sp_generafolionomina(user)INTO cCodRet2, cFolioSuc;

    FOREACH WITH HOLD   -- Obtiene los creditos con al menos 30 dias de no haber retirado la devolucion de anualidad.
        SELECT crd.num_credito, crd.numcte, crd.sucursal, ind.monto_devolucion, dos.sdo_cap_insoluto  
          INTO cNumCred,        cNumCte,    cSucursal,    dMnto_Devol,          dSdoCapInsol
          FROM bdicred:sd_indicador_cred ind
          JOIN bdicred:sd_maecred crd ON (ind.empresa = crd.empresa and ind.num_credito = crd.num_credito and crd.id_unidad_prod = 4 and crd.status_cred IN ('AA','E1'))
          JOIN bdicred:sd_maesdos dos ON (ind.empresa = dos.empresa and ind.num_credito = dos.num_credito and nvl(dos.sdo_cap_insoluto,0) = 0)
         WHERE ind.empresa = pempresa
           AND nvl(date(ind.fecha_pre_devol_anual), date(1)) > date(1)
           AND nvl(date(ind.fecha_devol_anual), date(1)) > date(1)

        LET cCodRet2 = 0;
        LET cFolioSucCancel = '';
        
        -- FF1.- A petición del cliente   
        EXECUTE PROCEDURE bdicred:"informix".sp_cancelarcredito(pempresa, cNumCred, 'FF1', USER, USER, '3', cSucursal) INTO cCodRet2, cFolioSucCancel;

        IF cCodRet2 != '00000' THEN
            CONTINUE FOREACH;
            LET cNumCred = '';  LET cNumCte = '';   LET cSucursal = ''; LET dMnto_Devol = 0;    LET dSdoCapInsol = 0;   LET cCodRet2 = '';  LET cFolioSuc = '';
        END IF
        LET cNumCred = '';  LET cNumCte = '';   LET cSucursal = ''; LET dMnto_Devol = 0;    LET dSdoCapInsol = 0;   LET cFolioSucCancel = '';

    END FOREACH; 

    CALL bdicred:"informix".sp_inserta_bitacora(pempresa, cProceso, cCod_ret, 'TERMINA CANCELACION CREDITOS CON SALDO EN CEROS', '02') Returning cCod_RetIB;

    RETURN cCod_ret;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento para el traspaso de la devolucion de comision por anualidad, que le fue depositada al cliente y que despues de ',
'             30 dias naturales no ha realizado el retiro en ventanilla de dicho deposito',
'AUTOR: Martha Angelica Hernandez Rodriguez',
'BD: bdicred ',
'FECHA: Julio 2017',
'VERSION: 20170701.1';

CREATE PROCEDURE "informix".sp_gen_archivo_pagotdcempleados(pEmpresa CHAR(3))
	
RETURNING CHAR(6) AS CodigoRetorno,
		CHAR(80) AS Mensaje;

--Elaborado por: Guadalupe Espinoza Valenzuela. 20140113		
--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE pMensaje				CHAR(80);
DEFINE pCod_ret				CHAR(6);
DEFINE cErrorInfo			CHAR(80);
DEFINE pempresa				CHAR(3);
DEFINE pproceso				CHAR(30);
DEFINE pusuario				CHAR(8);
DEFINE cruta				CHAR(100);
DEFINE cnombre				CHAR(100);
DEFINE ntrimestre 			CHAR(30);
DEFINE cnomarchivo			CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnumcte				CHAR(20);
DEFINE cnumcred				CHAR(20);
DEFINE cSucursal			CHAR(4);
DEFINE cSQL					CHAR(8204);
DEFINE cSQL1				CHAR(6204);
DEFINE cSQL2				CHAR(6204);
DEFINE cSQL3				CHAR(100);
DEFINE cCod_RetIB			CHAR(6);
DEFINE dFecha				DATE;
DEFINE sPaso				smallint;

--SET DEBUG FILE TO "/informix/gpe/sp_gen_archivo_pagotdcempleados.out";
--TRACE ON;

--Inicializació® ¤e variables
LET sql_err					= 0;
LET isam_err				= 0;
LET error_info				= "";
LET pCod_Ret				= "000000";
LET pMensaje				= 'PROCESO EXITOSO';
LET pproceso				= '2120';
LET pempresa				= '001';
LET pusuario				= USER;
LET cruta					= "";
LET cnombre					= "";
LET ntrimestre 				= "";
LET cnomarchivo				= "";
LET cnomarchivo1			= "";
LET cnumcte					= "";
LET cnumcred				= "";
LET cSucursal				= "";
LET cSQL					= "";
LET cSQL1					= "";
LET cSQL2					= "";
LET cSQL3					= "";
LET cCod_RetIB				= "000000";
LET dFecha					= DATE(1);
LET sPaso					=0;

	BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
	LET pCod_ret = sql_err;
	LET pMensaje = error_info;
	CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, pMensaje, '02')
	Returning cCod_RetIB;
		RETURN pCod_ret,pMensaje;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, pMensaje, '01')
	Returning cCod_RetIB;
		
	SELECT fecha_hoy
	INTO dFecha
	FROM bdicred:sd_fechas;
	
	SELECT TRIM(valor_alfabetico) 
	INTO cRuta 
	FROM bdicred:"informix".sd_param_campania 
	WHERE empresa = '001' AND tipo_campania = 50 
	AND num_parametro = 2;
	--let cruta = '/informix/gpe/'; --pruebas
	
	-----Creació® ¤e archivo------
    LET cnomarchivo1 =  'seguimiento_pagos_tdc'||substr(year(dFecha),3)||to_char(dFecha,'%m%d')||'.txt';
    LET cnomarchivo =  'seguimiento_pagos_tdc_'||substr(year(dFecha),3)||to_char( dFecha,'%m%d')||'.txt';
	--se ejecuta para ponerle el encabezado
	let cSql='';
	let csql = 'echo "NÃºmero de cré¤©to;Estatus del cré¤©to;Monto otorgado;Capital vigente;Capital transitorio;Saldo vencido;Capital vencido no exigible;Meses vencidos;" >' ||TRIM(cruta)|| cnomarchivo;
	system csql;

	LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || ''';'''||'';
	LET cSQL2 = ' select a.num_credito,a.status_cred,b.monto_otorgado,b.sdo_capital,b.monto_vencido,b.mto_venc_trasp,'||
				'b.cap_tras_no_venci, '||
				'(select count(*) from bdicred:sd_amortiza_credito where num_credito = a.num_credito and empresa = a.empresa and capital_status in('''||2||''','''||7||''','''||6||''')) '||
				'from bdicred:sd_maecred a '||
				'join bdicred:sd_maesdos b on (b.empresa = a.empresa and b.num_credito = a.num_credito) '||
				'where a.num_credito in(select e.num_credito from bdicred:sd_tdc_empleados e where e.empresa = a.empresa) '||
				'union all '||
				'select c.num_credito,c.status_cred,d.monto_otorgado,d.sdo_capital,d.monto_vencido,d.mto_venc_trasp, '||
				'd.cap_tras_no_venci, '||
				'(select count(*) from bdicred:sd_amortiza_creditocrd where num_credito = c.num_credito and empresa = c.empresa and capital_status in('''||2||''','''||7||''','''||6||''')) '||
				'from bdicred:sd_maecredcrd c '||
				'join bdicred:sd_maesdoscrd d on (d.empresa = c.empresa and d.num_credito = c.num_credito) '||
				'where c.num_credito in(select e.num_credito from bdicred:sd_tdc_empleados e where e.empresa = c.empresa);';

	LET cSQL3 = '">'||TRIM(cRuta)||'ejec_seg_tdc_pagos.sql';
    LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
	System cSQL;

    LET cSQL='chmod 777 '|| TRIM(cRuta)||'ejec_seg_tdc_pagos.sql';
    System cSQL;

    let cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || 'ejec_seg_tdc_pagos.sql';
    System cSQL;

    LET cSql = cSql; 
    LET cSql = "sed 's/;$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo1) || " >> " || TRIM(cRuta) || TRIM(cnomarchivo);
    SYSTEM cSql;

	--Borra el archivo de control.
	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || 'ejec_seg_tdc_pagos.sql';
	SYSTEM cSQL;

    LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo1;
	SYSTEM cSQL;
	
	CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, pMensaje, '03')
		Returning cCod_RetIB;

	RETURN pCod_ret,pMensaje;

END;
END PROCEDURE;