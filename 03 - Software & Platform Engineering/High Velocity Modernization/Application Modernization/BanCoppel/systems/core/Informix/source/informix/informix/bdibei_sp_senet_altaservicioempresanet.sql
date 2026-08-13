CREATE PROCEDURE "informix".sp_senet_altaservicioempresanet( pNumCte CHAR(20), pEstatus CHAR(2), pUsuario CHAR(8), pNoTokens smallint, pSucursal CHAR(4) )

	RETURNING CHAR(5) AS cCodRet,
			  CHAR(40) AS Mensaje;
	
--****************************************************************************************************
-- Objetivo: spl que guarda el servicio de la empresa en la tabla bei_contratación.
-- Modificación: Se modifica para que reste uno al campo oper_no_token
-- Autor: Berenice Noriega
-- FECHA : 07/11/2013
-- SOLICITO : Ismael Hernandez
-- BD: bdibei
--***************************************************************************************************
-- Modificación: Se modifica para agregar un insert al final para el registro de la conciliación
-- Autor: 		 95419888 Elmer López Valenzuela
-- FECHA : 		 26/08/2015
-- SOLICITO : 	 Alejandro Vazquez
-- BD: 			 bdibei
--***************************************************************************************************
	
    -- DEFINICIONES
    DEFINE iSql_Err         INTEGER;
    DEFINE cCodRet          CHAR(5);
    DEFINE cMensaje         CHAR(100);
    DEFINE sSecuencia       SMALLINT;
    DEFINE cSolicitud       CHAR(10);
    DEFINE cFolioSucursal   CHAR(16);
    DEFINE cRandon1         CHAR(6);
    DEFINE cRandon2         CHAR(2);
    DEFINE cRepLegal		CHAR(104);
	DEFINE cEmpresa			CHAR(3);
	DEFINE vTotal_admin		SMALLINT;
	DEFINE vNoTokens_oper	SMALLINT;
	DEFINE dMonto			DECIMAL(12,2);
	DEFINE cTipoPersona		CHAR(2);
	
    -- INICIALIZACIONES
    LET iSql_Err           	= 0;
    LET cCodRet           	= '000000';
    LET cMensaje          	= 'SE GENERO EL ALTA EXISTOSAMENTE';
    LET sSecuencia        	= 0;
    LET cSolicitud        	= '';
    LET cFolioSucursal    	= '';
    LET cRandon1          	= '';
    LET cRandon2         	= '';
	LET cRepLegal			= '';
	LET cEmpresa			= '001';
	LET vTotal_admin		= 0;
   	LET vNoTokens_oper		= 0;
	LET dMonto				= 0.00;
	LET cTipoPersona		= '';

    BEGIN

    ON EXCEPTION SET iSql_Err
        LET cCodRet = iSql_Err;
        LET cMensaje = '';
        RETURN cCodRet, cMensaje;
    END EXCEPTION;

	--SET DEBUG FILE TO "/informix/gaby/bdibei/sp/sp_senet_altaservicioempresanet.out";
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- // Valida los parametros de entrada.
	IF NVL(pNumCte,'') = '' OR NVL(pEstatus, '') = '' OR NVL(pUsuario,'') = '' OR NVL(pNoTokens,0) = 0 THEN
    --IF (pNumCte = '' OR pNumCte IS NULL) OR (pUsuario = '' OR pUsuario IS NULL) THEN
        LET cCodRet = '00001';
        LET cMensaje = 'FALTAN PARAMETROS PARA SU EJECUCIÓN';
        RETURN cCodRet, cMensaje;
    END IF;

	--validamos que el número de tokens sea correcto
	IF pNoTokens < 2 OR pNoTokens > 10 THEN
	    LET cCodRet = '00002';
        LET cMensaje = 'EL TOTAL DE DISPOSITIVOS DE SEGURIDAD SOLICITADOS NO ESTÁ EN EL RANGO PERMITIDO';
        RETURN cCodRet, cMensaje;
	END IF;	
	
	--valida estatus del servicio
	IF pEstatus <> '30' THEN
	    LET cCodRet = '00003';
        LET cMensaje = 'EL ESTATUS DEL SERVICIO NO ES VALIDO PARA EL SERVICIO';
        RETURN cCodRet, cMensaje;
	END IF;	
	
/*	-- Consultamos la fecha actual
    SELECT fecha_hoy 
      INTO dtFechaHoy
      FROM bdicheq:"informix".sc_fechas;
*/
	 -- registrando el servicio en central
	
	-----obteniendo el nombre del representante legal		
	/*	SELECT {+INDEX (bdinteg:"informix".si_ctepm  idx_cte)} 
	TRIM(b.nombre1) ||" "|| TRIM(b.nombre2) ||" "||TRIM(b.apell_paterno)||" "||TRIm(b.apell_materno)
		INTO cRepLegal
	FROM bdinteg:"informix".si_ctepm as a, bdinteg:"informix".si_cliente as b
	WHERE a.numcte = pNumCte
	AND TRIM(a.nombre_contacto) = b.numcte;*/

	SELECT a.numcte,TRIM(a.nombre1) ||" "|| TRIM(a.nombre2) ||" "||TRIM(a.apell_paterno)||" "||TRIm(a.apell_materno) replegal	      
	  FROM bdinteg:"informix".si_cliente as a
	 WHERE a.numcte in (select trim(nombre_contacto) FROM bdinteg:"informix".si_ctepm where numcte = pNumcte)	   
      INTO TEMP tmp_si_ctepm
	  WITH NO LOG;
    
    CREATE INDEX idx_tmp_si_ctepm ON tmp_si_ctepm(numcte);		
    UPDATE STATISTICS MEDIUM FOR TABLE bdibei:tmp_si_ctepm;  	
	
	SELECT replegal INTO cRepLegal FROM tmp_si_ctepm;
	
	---------------------------------------------------------------------------------------------------------------------------------
	--Se resta al total de tokens la cantidad de administradores -------------------------------------------
	--Consulta el numero de administradores---
	select count(num_cliente) INTO vTotal_admin
		from bdibei:bei_servicio where num_cliente=pNumCte;
	--Actualiza el parametros de total de tokens para operadores--
        LET vNoTokens_oper = pNoTokens - vTotal_admin;        	
	---------------------------------------------------------------------------------------------------------------------------------
	INSERT INTO bdibei:"informix".bei_contratacion (empresa, num_cliente ,folio_contrato, oper_no_token, rep_legal, f_registro,num_empleado, fecha_movto, usuario_atiende, usuario_aut, suc_registro, status_contrato)
       VALUES (cEmpresa, pNumCte,(SELECT LPAD(CAST(NVL(MAX((folio_contrato) + 1),0000000001)  AS INTEGER), 10, '0') FROM bdibei:"informix".bei_contratacion ), vNoTokens_oper, cRepLegal,TODAY, pUsuario, CURRENT, pUsuario, '',pSucursal,"30");
	   
	--Registrar solicitud de token  
	  
	   -- Consultamos la maxima secuencia del domicilio del cliente.
    SELECT secuencia 
      INTO sSecuencia
      FROM bdinteg:"informix".si_direcciones_actual 
     WHERE numcte = pNumCte
       AND tipo_dir = 1;

    IF sSecuencia IS NULL THEN
        SELECT MAX(secuencia) 
          INTO sSecuencia 
          FROM bdinteg:"informix".si_direcciones
         WHERE numcte = pNumCte
           AND tipo_dir = 1;
    END IF

    -- Consulta el maximo regitro + 1
    SELECT (NVL(MAX(solicitud),'0')::INTEGER + 1) 
      INTO cSolicitud
      FROM bdibei:"informix".bei_solicitudtoken;

    IF cSolicitud IS NULL THEN
        LET cSolicitud = '1';
    END IF;

    LET cSolicitud = LPAD(TRIM(cSolicitud), 10, '0');	
	
    -- Consultamos la hora para generar el folio.
    SELECT SUBSTR(DBINFO('utc_to_datetime', sh_curtime),12,2) || SUBSTR(DBINFO('utc_to_datetime', sh_curtime),15,2) || SUBSTR(DBINFO('utc_to_datetime', sh_curtime),18,2)
      INTO cRandon1
      FROM sysmaster:sysshmvals;

    -- Generamos un Randon para completar el valor del folio.
    EXECUTE PROCEDURE bdicheq:"informix".sp_random()
    INTO cRandon2;

    LET cFolioSucursal = 'SINCOMIS'||cRandon1||LPAD(TRIM(cRandon2), 2, '0');

   /* --Valida el estatus anterior.
    IF sEstatus = 0 THEN
        LET sEstatusAnt = 0;
    ELIF sEstatus = 1 THEN
        LET sEstatusAnt = 0;
    ELIF sEstatus = 2 THEN
        LET sEstatusAnt = 1;
    ELIF sEstatus = 10 THEN
        LET sEstatusAnt = 2;
    ELSE
        LET cCodRet = '000002';
        LET cMensaje = 'ESTATUS NO VALIDO PARA EL PROCESO DE ALTA DE EMPRESA NET';
        RETURN cCodRet, cMensaje;
    END IF 

    --  Inserta los registros de la alta definitiva del servicio de EmpresaNet.
	

	
    /*INSERT INTO bdibei:"informix".bei_token 
    ( id_usuario, num_cliente, ns_token, suc_registro, folio_token, id_status_token, f_status  , f_registro )
    VALUES                                      
    ( cUsuarioId , pNumCte, '', '5001', cFolioToken, 0 , dtFechaHoy , dtFechaHoy );*/

    INSERT INTO bdibei:"informix".bei_solicitudtoken 
	( solicitud, numcte, id_status,unidades ,sucursal,  f_solicitud, f_atencion, sec_domicilio, usr_solicita, usr_atiende, folio_suc, comentarios )
    VALUES ( cSolicitud, pNumCte, '100', pNoTokens, pSucursal, CURRENT, '', sSecuencia, pUsuario,'', cFolioSucursal,"");

	INSERT INTO bdibei:"informix".bei_stasolicitud (solicitud, anterior, actual, f_registro)
	VALUES (cSolicitud, '100', '100', CURRENT);

	
		
		-- Obtiene datos faltantes para el registro de conciliación	
		IF TRIM(SUBSTR(cFolioSucursal,1,8)) = 'SINCOMIS' THEN
			LET dMonto = 0.00;
		END IF;
		
		SELECT tpo_persona INTO cTipoPersona FROM bdinteg: "informix".si_cliente WHERE numcte = pNumCte;
		
		-- Inserta el registro de conciliación
		INSERT INTO bdibpi: "informix".tkn_solcobranza 
		( solicitud, Numcte, id_status, f_solicitud, folio_suc, f_cobro, cuenta, monto_tot, T_Persona )
		VALUES (cSolicitud, pNumCte, '100', CURRENT, cFolioSucursal,'','',dMonto,cTipoPersona);
		

	DROP TABLE tmp_si_ctepm;
    RETURN cCodRet, cMensaje;

 END;    
END PROCEDURE

DOCUMENT
'DESCRIPCION: Proceso que obtiene la información del representante legal e inserta la inserta la información , inserta los registros de la alta definitiva del servicio de EmpresaNet.',
'AUTOR:  Rosa Castro',
'FECHA DE CREACION: 17 Agosto 2013',
'BD: bdibei';

CREATE PROCEDURE "informix".sp_consuloperpagoservi_manco_bei2(pIdOperacion INTEGER)
RETURNING CHAR(5),CHAR(3),CHAR(4),CHAR(4),CHAR(4),CHAR(4),CHAR(4),CHAR(16),
        CHAR(20),CHAR(20),MONEY,CHAR(2),CHAR(40),MONEY,CHAR(2),CHAR(3),CHAR(20),
        CHAR(20),CHAR(10),CHAR(100),CHAR(10),INTEGER,INTEGER,CHAR(1),CHAR(40),CHAR(40),CHAR(40),CHAR(40),CHAR(6),CHAR(200),CHAR(250);
    
    DEFINE sql_err INTEGER;
	DEFINE cCod_ret CHAR (5);
    DEFINE vempresa CHAR(3);
    DEFINE vsucursal_virtual CHAR(4);
    DEFINE vusuario_virtual CHAR(4);
    DEFINE vnumtransferenciacargo CHAR(4);
    DEFINE vnumtransferenciaabono CHAR(4);
    DEFINE vtransaccion_sucursal CHAR(4);
    DEFINE vfoliosuc CHAR(16);
    DEFINE vcuenta_origen CHAR(20);
    DEFINE vcuenta_destino CHAR(20);
    DEFINE vimporte MONEY;
    DEFINE vmoneda CHAR(2);
    DEFINE vreferencia CHAR(40);
    DEFINE vmontototal MONEY;
    DEFINE vcategoria CHAR(2);
    DEFINE vconvenio CHAR(3);
    DEFINE vreftelefono CHAR(20);
    DEFINE vrefverificador CHAR(20);
    DEFINE vf_operacion CHAR(10);
    DEFINE vnombre_beneficiario CHAR(100);
    DEFINE vf_aplicacion CHAR(10);
    DEFINE vid_usuario INTEGER;
    DEFINE vid_cat_operacion INTEGER;
    DEFINE vstatusoperacion CHAR(1);
    DEFINE vpgen1 CHAR(40);
    DEFINE vpgen2 CHAR(40);
    DEFINE vpgen3 CHAR(40);
    DEFINE vpgen4 CHAR(40);
    DEFINE vtipo_servicio CHAR(6);
    DEFINE vconcepto CHAR(200);
    DEFINE vlistacampos CHAR(250);

    LET cCod_ret = '00000';
    LET vempresa = '';
    LET vsucursal_virtual = '';
    LET vusuario_virtual = '';
    LET vnumtransferenciacargo = '';
    LET vnumtransferenciaabono = '';
    LET vtransaccion_sucursal = '';
    LET vfoliosuc = '';
    LET vcuenta_origen = '';
    LET vcuenta_destino = '';
    LET vimporte = 0;
    LET vmoneda = '';
    LET vreferencia = '';
    LET vmontototal = 0;
    LET vcategoria = '';
    LET vconvenio = '';
    LET vreftelefono = '';
    LET vrefverificador = '';
    LET vf_operacion = TODAY;
    LET vnombre_beneficiario = '';
    LET vf_aplicacion = TODAY;
    LET vid_usuario = 0;
    LET vid_cat_operacion = 0;
    LET vstatusoperacion = '';
    LET vpgen1 = '';
    LET vpgen2 = '';
    LET vpgen3 = '';
    LET vpgen4 = '';
    LET vtipo_servicio = '';
    LET vconcepto = '';
    LET vlistacampos = '';


BEGIN
    ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cCod_ret = sql_err;
            RETURN cCod_ret, vempresa,vsucursal_virtual,vusuario_virtual,vnumtransferenciacargo,
            vnumtransferenciaabono,vtransaccion_sucursal,vfoliosuc,vcuenta_origen,
            vcuenta_destino,vimporte,vmoneda,vreferencia,vmontototal,vcategoria,
            vconvenio,vreftelefono,vrefverificador,vf_operacion,vnombre_beneficiario,
            vf_aplicacion,vid_usuario,vid_cat_operacion,vstatusoperacion,vpgen1,vpgen2,vpgen3,vpgen4,vtipo_servicio,vconcepto,vlistacampos;
      END IF ;
    END EXCEPTION ;

    SELECT  empresa,sucursal_virtual,usuario_virtual,numtransferenciacargo,numtransferenciaabono,
            transaccion_sucursal,foliosuc,cuenta_origen,cuenta_destino,importe,moneda,referencia,
            montototal,categoria,convenio,reftelefono,refverificador,f_operacion,nombre_beneficiario,
            f_aplicacion,id_usuario,id_cat_operacion,statusoperacion,pgen1,pgen2, pgen3, pgen4, tipo_servicio, concepto , campos_adicionales  
    INTO    vempresa,vsucursal_virtual,vusuario_virtual,vnumtransferenciacargo,
            vnumtransferenciaabono,vtransaccion_sucursal,vfoliosuc,vcuenta_origen,
            vcuenta_destino,vimporte,vmoneda,vreferencia,vmontototal,vcategoria,
            vconvenio,vreftelefono,vrefverificador,vf_operacion,vnombre_beneficiario,
            vf_aplicacion,vid_usuario,vid_cat_operacion,vstatusoperacion,vpgen1,vpgen2,vpgen3,vpgen4,vtipo_servicio,vconcepto,vlistacampos
    FROM bei_operacionesmancomunadasoperador
    WHERE ID_OPERACION = pIdOperacion;     

    RETURN cCod_ret, vempresa,vsucursal_virtual,vusuario_virtual,vnumtransferenciacargo,
            vnumtransferenciaabono,vtransaccion_sucursal,vfoliosuc,vcuenta_origen,
            vcuenta_destino,vimporte,vmoneda,vreferencia,vmontototal,vcategoria,
            vconvenio,vreftelefono,vrefverificador,vf_operacion,vnombre_beneficiario,
            vf_aplicacion,vid_usuario,vid_cat_operacion,vstatusoperacion,vpgen1,vpgen2,vpgen3,vpgen4,vtipo_servicio,NVL(vconcepto,''),NVL(vlistacampos,'');

END

END PROCEDURE;