CREATE PROCEDURE "informix".sp_ctbcpl_gen_arctelefonos(pEmpresa         CHAR(3),
                                                       pTipoCobranza    CHAR(1),
                                                       pFechaGenCartera DATE,
                                                       pStatusTel       CHAR(2))
RETURNING CHAR(6) AS COD_RET;
-----------------------------------------------------------------------------------------------------------------------------------------------------
-- Modificado por: Martha A Hernandez
-- Fecha: Noviembre 2011
-- Modificacion: Se modifica proceso para que tome en cuenta tambien el tipo de cobranza R
-----------------------------------------------------------------------------------------------------------------------------------------------------
-- Modificado por: Elizabeth Anzures
-- Fecha: Marzo 2012
-- Modificacion: Se modifica proceso para que no tome clientes con estatus en AT
-----------------------------------------------------------------------------------------------------------------------------------------------------
-- Modificado por: Abrham Lopez L.
-- Fecha: 10 Diciembre 2012
-- Modificacion: Se modifica consulta principal para que a los tipotelefono = 2 les ponga el tipored = 'M'
-- execute procedure sp_ctbcpl_gen_arctelefonos ('001','A','01-20-2015','01');
-----------------------------------------------------------------------------------------------------------------------------------------------------

-- DECLARACIONES
DEFINE iSqlErr              INTEGER;
DEFINE iIsamErr             INTEGER;
DEFINE error_info		    CHAR(80);
DEFINE cCodRet              CHAR(6);
DEFINE cMensaje 		    CHAR(80);
DEFINE cRuta                CHAR(100);
DEFINE cNomArchivo          CHAR(100);
DEFINE cNomArchivoAux       CHAR(100);
DEFINE cNomArchivoEjecSql   CHAR(100);
DEFINE cSQL                 CHAR(2204);
DEFINE cSQL1                CHAR(100);
DEFINE cSQL2                CHAR(2004);
DEFINE cSQL3                CHAR(100);
DEFINE cFechaGenArchivo     CHAR(8);
DEFINE cEmpresa             CHAR(3);
DEFINE cDelimitador         CHAR(1);
DEFINE cTipoCampania        CHAR(1);
DEFINE cCodRetIB            CHAR(6);
DEFINE vnumparametro        SMALLINT;

-- INICIALIZACIONES
LET iSqlErr                 = 0;
LET iIsamErr                = 0;
LET cCodRet                 = "000000";
LET cMensaje                = 'PROCESO EXITOSO';
LET cRuta                   = "";
LET cNomArchivo             = "";
LET cNomArchivoAux          = "";
LET cNomArchivoEjecSql      = "";
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET cEmpresa                = "000";
LET cDelimitador            = "";
LET cTipoCampania           = "";
LET cCodRetIB               = "000000";


BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, error_info
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;
            LET cMensaje = error_info;
           -- EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,"0028",cCodRet,cMensaje,"02")  INTO cCodRetIB;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

    -- DIRECTIVA PARA TENER LECTURA LECTURA DE TABLAS AUNQUE ESTEN BLOQUEADAS
    SET ISOLATION TO DIRTY READ;
    -- DIRECTIVA PARA QUE EXISTA UNA ESPERA DE TRES SEGUNDOS AL ACCESO 
    SET LOCK MODE TO WAIT 3;

-- SET DEBUG FILE TO "/tmp/sp_ctbcpl_gen_arctelefonos.out";
-- TRACE ON;

    --EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,"0028","","","01")INTO cCodRetIB;
    
    -- VALIDA LOS PARAMETROS DE ENTRADA   
    IF NVL(pEmpresa,"") = "" OR NVL(pTipoCobranza,"") = "" OR NVL(pFechaGenCartera,"")= "" OR NVL(pStatusTel,"") = "" THEN
        LET cCodRet = "104001";
        SELECT descripcion INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen       = 3
            AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        --EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,"0028",cCodRet,cMensaje,"02")INTO cCodRetIB;
        RETURN cCodRet;
    END IF
    
    LET vnumparametro  =14; 
    IF (pTipoCobranza='A' OR pTipoCobranza='P'  ) THEN  LET vnumparametro  =14; END IF;
    IF (pTipoCobranza='E' OR pTipoCobranza='R'  ) THEN  LET vnumparametro  =16; END IF;

    SELECT empresa INTO cEmpresa
        FROM bdinteg: si_empresas
        WHERE empresa= pEmpresa;

    IF NVL(cEmpresa,'') = '' THEN
        LET cCodRet = "104002";
        SELECT descripcion INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen       = 3
            AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

       -- EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,"0028",cCodRet,cMensaje,"02")INTO cCodRetIB;
        RETURN cCodRet;
    END IF;

    SELECT tipo_cobranza INTO cTipoCampania
        FROM bdicobranza:cb_cat_campania
        WHERE empresa         = pEmpresa
            AND tipo_cobranza = pTipoCobranza
            AND modulo_cob    = 3;

    IF NVL(cTipoCampania,'') = '' THEN
        LET cCodRet = "104003";
        SELECT descripcion INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen       = 3
                AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        --EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,"0028",cCodRet,cMensaje,"02")INTO cCodRetIB;
        RETURN cCodRet;
    END IF;
   
    -- OBTIENE EL CARACTER SEPARADOR
    SELECT TRIM(valor_alfabetico) INTO cDelimitador
        FROM bdicobranza:cb_param_campania 
        WHERE empresa       = pEmpresa 
        AND tipo_campania   = 1 
        AND grupo_parametro = "ARCHIVOS" 
        AND num_parametro   = 2;
    
    -- VALIDA QUE EXISTA EL CARACTER
    IF NVL(cDelimitador,"") = "" THEN
        LET cCodRet = "104004";
        SELECT descripcion INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen       = 3
              AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        --EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,"0028",cCodRet,cMensaje,"02") INTO cCodRetIB;
        RETURN cCodRet;
    END IF;

    -- OBTIENE LA RUTA DESTINO DEL ARCHIVO
    SELECT TRIM(valor_alfabetico) INTO cRuta
        FROM bdicobranza:cb_param_campania 
        WHERE empresa = pEmpresa
            AND tipo_campania   = 1 
            AND grupo_parametro = "ARCHIVOS" 
            AND num_parametro   = 3;
    
    -- VALIDA QUE EXISTA LA CARPETA
    IF NVL(cRuta,"") = "" THEN
        LET cCodRet = "104005";
        SELECT descripcion INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen       = 3
            AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        --EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,"0028",cCodRet,cMensaje,"02")INTO cCodRetIB;
        RETURN cCodRet;
    END IF

    -- OBTIENE EL NOMBRE DEL ARCHIVO
    SELECT TRIM(valor_alfabetico) INTO cNomArchivo
        FROM bdicobranza:cb_param_campania 
        WHERE empresa         = pEmpresa 
            AND tipo_campania   = 1
            AND grupo_parametro = "ARCHIVOS" 
            AND num_parametro   = vnumparametro;
    
    -- VALIDA QUE EXISTA EL NOMBRE DEL ARCHIVO
    IF NVL(cNomArchivo,"") = "" THEN
        LET cCodRet = "104006";
        SELECT descripcion INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen       = 3
            AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

       -- EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,"0028",cCodRet,cMensaje,"02") INTO cCodRetIB;
        RETURN cCodRet;
    END IF
	
	let pFechaGenCartera = date(1);		
	SELECT MAX(fecha_insert) INTO pFechaGenCartera
	FROM bdicobranza:cb_cat_directorio_cte
	WHERE empresa = pempresa
	AND tipo_cobranza = ptipocobranza;

	LET cFechaGenArchivo = TRIM(LPAD(DAY(pFechaGenCartera),2,'0') || LPAD(MONTH(pFechaGenCartera),2,'0') || YEAR(pFechaGenCartera));

    LET cNomArchivoAux = TRIM(cNomArchivo) || cFechaGenArchivo || '_aux_' || pTipoCobranza ||'.txt';
    LET cNomArchivo = TRIM(cNomArchivo) || cFechaGenArchivo || '.txt';
    LET cNomArchivoEjecSql = 'Ejecuta_GenArchivoTelefonos_'|| pTipoCobranza || '.sql';
--LET cRuta = '/informix/Elizabeth/';---PRUEBAAAAAA
    LET cSQL1 = 'echo "UNLOAD TO ' || TRIM(cRuta) || TRIM(cNomArchivoAux) || " DELIMITER '" || cDelimitador || "' ";

    LET cSQL2 = " SELECT tel.numcte, tel.tipo_tel, 0, substr(tel.telefono,length(tel.telefono)-9,10),  "
                || " tel.extension, decode(tel.tipo_tel,1,'F',2,'M','M'), date(1) fultimocontacto,"  -- A.L.L. Se modifica en los 2 de 'F' a 'M'
                || " '' quiencontestouc, tel.fecha_hora,tel.carrier , tel.secuencia, decode(tel.status_tel,'A',0,1) "
                || " FROM bdicobranza:cb_cat_directorio_cte dir ,bdinteg:si_telefonos_actual tel "
                || " WHERE dir.tipo_cobranza = '" || pTipoCobranza || "' " 
                || " AND dir.fecha_insert = '" || pFechaGenCartera || "' "
                || " AND dir.tipo_logica > 0 "                
                || " AND dir.status_cliente NOT IN ('NT', 'EX') "        		
                || " AND tel.numcte  = dir.numcte "
				|| " AND tel.tipo_tel in (1,2,3) "
                || " AND tel.cofetel= 'V' ";

    LET cSQL3 = ' " > '|| TRIM(cRuta) || cNomArchivoEjecSql;
    
    LET cSQL1 = TRIM(cSQL1);
    LET cSQL3 = TRIM(cSQL3);

    LET cSQL = cSQL1 || cSQL2 || cSQL3;

    -- Verifica que no este vacia la consulta.
    IF ( cSQL <> '' ) THEN 
        SYSTEM cSQL;
        -- Permiso para la creacion de archivo.
        LET cSQL = '' ;
        LET cSQL = 'chmod 666 ' || TRIM(cRuta) || cNomArchivoEjecSql ;
        LET cSQL = '' ;
        LET cSQL = 'dbaccess bdicobranza ' || TRIM(cRuta) || cNomArchivoEjecSql ;
        SYSTEM cSQL;
		
		--A.L.L Se le dan permisos al archivo que se genera con el .sql con chmod 777
		LET cSQL = '';
		LET cSQL = 'chmod 666 '|| TRIM(cRuta) || TRIM(cNomArchivoAux);
		SYSTEM cSQL;

        LET cSql = cSql;
        LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cNomArchivoAux) || " >> " || TRIM(cRuta) || TRIM(cNomArchivo);
        SYSTEM cSql;
		
		--A.L.L Se le dan permisos al archivo final con el chmod 777
		LET cSQL = '';
		LET cSQL = 'chmod 666 '|| TRIM(cRuta) || TRIM(cNomArchivo);
		SYSTEM cSQL;
 
        -- Borra el archivo de control.
        LET cSQL = '' ;
        LET cSQL = 'rm ' || TRIM(cRuta) || cNomArchivoEjecSql || '  ' || TRIM(cRuta) || TRIM(cNomArchivoAux);
        SYSTEM cSQL;

        -- Operacion exitosa "Archivo Generado".
        --EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,"0028","","","03") INTO cCodRetIB;
        RETURN cCodRet;
    END IF;

END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para generar el archivo de Teléfonos del cliente', 
'AUTOR: Mohamed Carreón ',
'VERSION: 20101109.1545';

CREATE PROCEDURE "informix".sp_migra_tablas_smsmail()
       RETURNING CHAR(6), CHAR(80);

--DEClaracion de variables
-- execute procedure "informix".sp_migra_reporte_smsmail();
------------------------------------------------------------
DEFINE sql_err 			    INTEGER;
DEFINE isam_err 		    INTEGER;
DEFINE error_info		    CHAR(80);
DEFINE cMensaje 		    CHAR(100);
define P_MENSAJE			CHAR(80);
DEFINE cCod_ret             CHAR(6);
define v_fecha_hoy			DATE;

----------------------------------------------------------------------
DEFINE vproceso				CHAR(4);
DEFINE Vempresa				CHAR(3);
DEFINE Vnum_campana			SMALLINT;
DEFINE vcliente             CHAR(20);
DEFINE vcredito             CHAR(20);
DEFINE Vproducto			CHAR(4);
DEFINE VfechaEnvio			DATE;
DEFINE vciudad              CHAR(10);
DEFINE vestado              CHAR(10);
DEFINE vt_celular           CHAR(13);
DEFINE cNombre1				CHAR(26);
DEFINE cNombre2				CHAR(26);
DEFINE cApellPat			CHAR(26);
DEFINE cApellMat			CHAR(26);
DEFINE vMora				SMALLINT;
DEFINE vsdo_venc_int_mora   DEC(18,2);
DEFINE vpago_min            DEC(18,2);
DEFINE vpago_min_sin_vdo    DEC(18,2); 
DEFINE vpago_venc           DEC(18,2); 
DEFINE vpago_req_sms		DEC(18,2);
DEFINE vCosto				DEC(18,2);
DEFINE vResultadoEntrega	CHAR(15);
DEFINE vPagoDia1			DEC(18,2);
DEFINE vPagoDia2			DEC(18,2);
DEFINE vPagoDia3			DEC(18,2);
DEFINE vPagoDia4			DEC(18,2);
DEFINE vPagoDia5			DEC(18,2);
DEFINE vPagoNdias			DEC(18,2);
DEFINE vEstatusResultado	CHAR(02);
DEFINE vFechaCambioEstatus  DATE;
DEFINE vResultadoMora		SMALLINT;
DEFINE vFechaApertura		DATE;
DEFINE vFechaPrimerConsumo  DATE;
DEFINE vLineaCredito		DEC(18,2);
DEFINE vTipoTransaccion		CHAR(30);
DEFINE vMontoTransaccion	DEC(18,2);
DEFINE vPorcentaje_uso      DEC(18,2);
DEFINE vCorreoElec			CHAR(100);
DEFINE vPagoReqEmail		DEC(18,2);
DEFINE vCount				INTEGER;
DEFINE vCount1				INTEGER;
DEFINE iCuentasProcesadas     integer; 
DEFINE iCuentasInsertadas     integer; 
DEFINE iCuentasEliminadas     integer; 
DEFINE iCuentasExcluidasXMail integer;
DEFINE iOtrasExclusiones 	  integer;
DEFINE iCuentasExcluidasXCel  INTEGER;
  

--------------------------------------------
LET Vempresa 			= '';
LET Vnum_campana 		= 0;
LET vcliente         	= '';
LET vcredito        	= '';
LET Vproducto 			= '';
LET VfechaEnvio 		= '';
LET vciudad          = '';
LET vestado          = '';
LET cNombre1			= '';
LET cNombre2			= '';
LET cApellPat			= '';
LET cApellMat			= '';
LET vMora				= 0;
LET vCosto				= 0;
LET vResultadoEntrega	= '';
LET vPagoDia1			= 0;
LET vPagoDia2			= 0;
LET vPagoDia3			= 0;
LET vPagoDia4			= 0;
LET vPagoDia5			= 0;
LET vPagoNdias			= 0;
LET vEstatusResultado	= '';
LET vFechaCambioEstatus = '';
LET vResultadoMora		= 0;
LET vFechaApertura		= '';
LET vFechaPrimerConsumo = '';
LET vLineaCredito		= 0;
LET vTipoTransaccion	= '';
LET vMontoTransaccion	= 0;
LET vPorcentaje_uso		= 0;
LET vCorreoElec			= '';
LET vPagoReqEmail		= 0;
LET vpago_req_sms		= 0;
let vCount1 			= 0;
let iCuentasProcesadas     = 0;
let iCuentasInsertadas     = 0;
let iCuentasEliminadas     = 0; 

let iCuentasExcluidasXMail  = 0;
let iCuentasExcluidasXCel = 0;
---------------------------------------

--SET DEBUG FILE TO 'sp_migra_reporte_smsmail.out';
--TRACE ON;

      LET cCod_ret      = '000000';
	  LET sql_err       = 0;
	  LET isam_err      = 0;
	  LET error_info    = '';
	  LET cMensaje      = 'PROCESO EXITOSO';
	  LET P_MENSAJE      = 'El proceso de MIGRACION DE TABLAS SMSs MAILs se realizó correctamente.';
	  LET vproceso		= '0119';
      --LET pUsuario      = user;
	  let v_fecha_hoy = DATE(1);
 

	BEGIN

        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
	        LET P_MENSAJE = error_info;
			CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, P_MENSAJE, '02')RETURNING cCod_ret; 
	        LET cCod_ret = sql_err;
    		RETURN cCod_ret, P_MENSAJE;
		END EXCEPTION;
     
--------------------------------------------------------------------------
--    SELECT fecha_hoy INTO v_fecha_hoy FROM bdinteg:si_fechas;
--------------------------------------------------------------------------

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, cMensaje, '01')RETURNING cCod_ret; 


        --se obtiene la informacion
		SET ISOLATION TO dirty READ;
        SET LOCK MODE TO WAIT 3;

----------------------------------- Se obtienen DATOS del CLIENTE y SALDOS--------------------------------------------
FOREACH with hold
            SELECT empresa,num_campana,num_credito,numcte,num_producto,fecha_envio,ciudad,estado,num_celular,
				nombre1,nombre2,apell_paterno,apell_materno,mora,sdo_venc_int_mora,pago_min,pago_min_sin_vdo, 
				pago_ven,pago_req_sms,costo,resultado_entrega,pago_dia1,pago_dia2,pago_dia3,pago_dia4,pago_dia5, 
				pago_ndias,estatus_resultado,fecha_cambio_estatus,resultado_mora, fecha_apertura, 
				fecha_primer_consumo,linea_credito,tipo_transaccion,monto_transaccion,porcentaje_uso 
			INTO Vempresa,Vnum_campana,vcredito,vcliente,Vproducto,VfechaEnvio,vciudad,vestado,vt_celular,
				cNombre1,cNombre2,cApellPat,cApellMat,vMora,vsdo_venc_int_mora,vpago_min,vpago_min_sin_vdo,
				vpago_venc,vpago_req_sms,vCosto,vResultadoEntrega,vPagoDia1,vPagoDia2,vPagoDia3,vPagoDia4,vPagoDia5,
				vPagoNdias,vEstatusResultado,vFechaCambioEstatus,vResultadoMora,vFechaApertura,
				vFechaPrimerConsumo,vLineaCredito,vTipoTransaccion,vMontoTransaccion,vPorcentaje_uso
            FROM bdicobranza:cb_rep_resultado_sms
			
			--A.L.L.	
			let iCuentasProcesadas = iCuentasProcesadas + 1;
			
---------------SE INCERTAN DATOS GENERADOS----------------------------------------------------------

             BEGIN WORK;
			 INSERT INTO cb_rep_resultado_sms_hist (
                empresa,num_campana,num_credito,numcte,num_producto,fecha_envio,ciudad,estado,num_celular,
				nombre1,nombre2,apell_paterno,apell_materno,mora,sdo_venc_int_mora,pago_min,pago_min_sin_vdo, 
				pago_ven,pago_req_sms,costo,resultado_entrega,pago_dia1,pago_dia2,pago_dia3,pago_dia4,pago_dia5, 
				pago_ndias,estatus_resultado,fecha_cambio_estatus,resultado_mora, fecha_apertura, 
				fecha_primer_consumo,linea_credito,tipo_transaccion,monto_transaccion,porcentaje_uso)
			  VALUES(Vempresa,Vnum_campana,vcredito,vcliente,Vproducto,VfechaEnvio,vciudad,vestado,vt_celular,
				cNombre1,cNombre2,cApellPat,cApellMat,vMora,vsdo_venc_int_mora,vpago_min,vpago_min_sin_vdo,
				vpago_venc,vpago_req_sms,vCosto,vResultadoEntrega,vPagoDia1,vPagoDia2,vPagoDia3,vPagoDia4,vPagoDia5,
				vPagoNdias,vEstatusResultado,vFechaCambioEstatus,vResultadoMora,vFechaApertura,
				vFechaPrimerConsumo,vLineaCredito,vTipoTransaccion,vMontoTransaccion,vPorcentaje_uso);

            let iCuentasInsertadas = iCuentasInsertadas + 1;

			--A.L.L. Borramos los clientes de la tabla cb_rep_resultado_sms 	
			delete bdicobranza:cb_rep_resultado_sms where empresa = Vempresa and num_campana = Vnum_campana and num_credito = vcredito and fecha_envio = VfechaEnvio;

			let iCuentasEliminadas = iCuentasEliminadas +1;
			
			COMMIT WORK;
END FOREACH;

--Genera cifras de control
	    if iCuentasProcesadas > 0 then
	       let cMensaje = 'TOTAL cuentas PROCESADAS SMSs : ' || iCuentasProcesadas;
	       let cMensaje = trim(cMensaje) ||'    TOTAL cuentas INSERTADAS SMSs a histórica : ' || iCuentasInsertadas;
	       CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, trim(cMensaje), '02') RETURNING cCod_ret;
	       let cMensaje = 'TOTAL cuentas ELIMINADAS SMSs : ' || iCuentasEliminadas;
	       CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, trim(cMensaje), '02') RETURNING cCod_ret;
	    end if;
--Genera cifras de control
		let iCuentasProcesadas = 0;
		let iCuentasInsertadas = 0;
		let iCuentasEliminadas = 0;
--begin work;
-----------------------------------------------INSERTAR----CB_MAIL_CLIENTE_HIS------------------------------------
	FOREACH with hold
	
		select  empresa,num_campana,num_credito,numcte,num_producto,fecha_envio,ciudad,estado,correo_elec,
				nombre1,nombre2,apell_paterno,apell_materno,mora,sdo_venc_int_mora,pago_min,pago_min_sin_vdo, 
				pago_ven,pago_req_email,costo,resultado_entrega,pago_dia1,pago_dia2,pago_dia3,pago_dia4,pago_dia5, 
				pago_ndias,estatus_resultado,fecha_cambio_estatus,resultado_mora, fecha_apertura, 
				fecha_primer_consumo,linea_credito,tipo_transaccion,monto_transaccion,porcentaje_uso
		into 	Vempresa,Vnum_campana,vcredito,vcliente,Vproducto,VfechaEnvio,vciudad,vestado,vCorreoElec,
				cNombre1,cNombre2,cApellPat,cApellMat,vMora,vsdo_venc_int_mora,vpago_min,vpago_min_sin_vdo,
				vpago_venc,vPagoReqEmail,vCosto,vResultadoEntrega,vPagoDia1,vPagoDia2,vPagoDia3,vPagoDia4,vPagoDia5,
				vPagoNdias,vEstatusResultado,vFechaCambioEstatus,vResultadoMora,vFechaApertura,
				vFechaPrimerConsumo,vLineaCredito,vTipoTransaccion,vMontoTransaccion,vPorcentaje_uso
		from bdicobranza:cb_rep_resultado_mail
		
		let vCount = vCount1 +1;
		--A.L.L.	
		let iCuentasProcesadas = iCuentasProcesadas + 1;
		
        BEGIN WORK;
		insert into bdicobranza:"informix".cb_rep_resultado_mail_hist(
	        empresa,num_campana,num_credito,numcte,num_producto,fecha_envio,ciudad,estado,correo_elec,
				nombre1,nombre2,apell_paterno,apell_materno,mora,sdo_venc_int_mora,pago_min,pago_min_sin_vdo, 
				pago_ven,pago_req_email,costo,resultado_entrega,pago_dia1,pago_dia2,pago_dia3,pago_dia4,pago_dia5, 
				pago_ndias,estatus_resultado,fecha_cambio_estatus,resultado_mora, fecha_apertura, 
				fecha_primer_consumo,linea_credito,tipo_transaccion,monto_transaccion,porcentaje_uso)
		values(Vempresa,Vnum_campana,vcredito,vcliente,Vproducto,VfechaEnvio,vciudad,vestado,vCorreoElec,
				cNombre1,cNombre2,cApellPat,cApellMat,vMora,vsdo_venc_int_mora,vpago_min,vpago_min_sin_vdo,
				vpago_venc,vPagoReqEmail,vCosto,vResultadoEntrega,vPagoDia1,vPagoDia2,vPagoDia3,vPagoDia4,vPagoDia5,
				vPagoNdias,vEstatusResultado,vFechaCambioEstatus,vResultadoMora,vFechaApertura,
				vFechaPrimerConsumo,vLineaCredito,vTipoTransaccion,vMontoTransaccion,vPorcentaje_uso);

		let iCuentasInsertadas = iCuentasInsertadas + 1;
				
		--A.L.L. Borramos los clientes de la tabla cb_mail_cliente 
		delete bdicobranza:cb_rep_resultado_mail where empresa = Vempresa and num_campana = Vnum_campana and num_credito = vcredito and fecha_envio = VfechaEnvio;

		let iCuentasEliminadas = iCuentasEliminadas + 1;

        COMMIT WORK;
	end FOREACH;

	--Genera cifras de control
	    if iCuentasProcesadas > 0 then
	       let cMensaje = 'TOTAL cuentas PROCESADAS MAILs : ' || iCuentasProcesadas;
	       let cMensaje = trim(cMensaje) ||'    TOTAL cuentas INSERTADAS MAILs a histórica : ' || iCuentasInsertadas;
	       CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, trim(cMensaje), '02') RETURNING cCod_ret;
	       let cMensaje = 'TOTAL cuentas ELIMINADAS MAILs : ' || iCuentasEliminadas;
	       CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, trim(cMensaje), '02') RETURNING cCod_ret;
	    end if;
--Genera cifras de control

    UPDATE STATISTICS MEDIUM FOR TABLE bdicobranza:cb_rep_resultado_sms;
    UPDATE STATISTICS MEDIUM FOR TABLE bdicobranza:cb_rep_resultado_sms_hist;
    UPDATE STATISTICS MEDIUM FOR TABLE bdicobranza:cb_rep_resultado_mail;
    UPDATE STATISTICS MEDIUM FOR TABLE bdicobranza:cb_rep_resultado_mail_hist;
	

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, cMensaje, '03')RETURNING cCod_ret; 
	RETURN cCod_ret, P_MENSAJE;

END;
END PROCEDURE;