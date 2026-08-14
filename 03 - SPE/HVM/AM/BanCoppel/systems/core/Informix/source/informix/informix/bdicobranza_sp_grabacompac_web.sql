CREATE PROCEDURE "informix".sp_grabacompac_web(
		pempresa          CHAR(3),
		pempleado_captura INT,
		pnumcliente       CHAR(20),
		pnumcuenta        CHAR(20),
		ptipo_compac      CHAR(1),
		pplazo            CHAR(2),
		pimporte          DECIMAL,
		porigen	          SMALLINT,
		pefectuo_compac   INT,
		psucursal         CHAR(4),
        pfechasistema     DATE,
        pquien_convenio   CHAR(15),
        pnom_convenio     CHAR(40),
        pemail            CHAR(60),
        preferenciacoppel CHAR(20),
        pnombre_efectuo   CHAR(40)
) 

	RETURNING CHAR(5);
	
	DEFINE v_codret 	 CHAR(5);
	DEFINE vcod_ret 	 CHAR(5);
	DEFINE v_sqlerr 	 INTEGER;
	DEFINE v_isamerr     INTEGER;
	DEFINE v_pnumcliente CHAR(20);
	DEFINE v_Error       CHAR(20);
	DEFINE vv_cod_ret    CHAR(5);
	DEFINE vActivo       CHAR(1);
	---------------------------------------------------
	DEFINE cCodRet_1         CHAR(6);
	DEFINE cMensajeRet_1     CHAR(80);
	DEFINE dImpMensual       DECIMAL(18,2);
	DEFINE dIntVdo           DECIMAL(18,2);
	DEFINE dIntMoratorio     DECIMAL(18,2);
	DEFINE dIvaIntVdo        DECIMAL(18,2);
	DEFINE dPagosVdos        DECIMAL(18,2);
	DEFINE dIvaIntMoratorio  DECIMAL(18,2);
	DEFINE dIntMes_1         DECIMAL(18,2);
	DEFINE dIvaIntMes_1      DECIMAL(18,2);
	DEFINE dIntVig           DECIMAL(18,2);
	DEFINE dIvaIntVig        DECIMAL(18,2);
	DEFINE vcantReg		     SMALLINT;
	---------------------------------------------------
	LET v_codret      = "00000";
	LET vv_cod_ret    = "000";
	LET vcod_ret      = "000";
	LET v_sqlerr      = 0;
	LET v_isamerr     = 0;
	LET v_Error       = '';
	LET v_pnumcliente = lpad(trim(pnumcliente), 9, '0');
	LET vActivo       = '1';
	---------------------------------------------------
	LET cCodRet_1         = '';
	LET cMensajeRet_1     = '';
	LET dImpMensual		  = 0;
	LET dIntVdo           = 0;
	LET dIntMoratorio     = 0;
	LET dIvaIntVdo        = 0;
	LET dPagosVdos        = 0;
	LET dIvaIntMoratorio  = 0;
	LET dIntMes_1         = 0;
	LET dIvaIntMes_1      = 0;
	LET dIntVig           = 0;
	LET dIvaIntVig        = 0;
	LET vcantReg          = 0;
	---------------------------------------------------
	
	--SET DEBUG FILE TO "/aplicacion/Carlos/sp_grabacompac.out";
	--TRACE ON;
	
	--31/10/2008
	--CAMBIO:
	--Se comento la parte donde se valida si viene la referencia coppel ya que no es obligatoria.
	--WALBERTO CASTRO
	--19/11/2009
	--Se agrego el campo CANAL a la tabla cb_compac_error para que el se guarde el registro de error del procedimiento.
	--Armida Pazos
	
	--SET ISOLATION TO COMMITTED READ LAST COMMITTED;	
BEGIN

    ON EXCEPTION SET v_sqlerr, v_isamerr
      IF v_sqlerr != 0 THEN
         let v_codret=v_sqlerr;
         RETURN v_codret;
      END IF;
    END EXCEPTION;
   
   	SET ISOLATION COMMITTED READ;
	SET LOCK MODE TO WAIT 3;

   --CHECAR VALORES NULOS
    IF pempresa IS NULL OR Trim(pempresa) = "" THEN
	   LET v_codret = "20001";
    ELIF pempleado_captura IS NULL THEN
	   LET v_codret = "20002";
    ELIF v_pnumcliente IS NULL OR Trim(v_pnumcliente) = "" THEN
	   LET v_codret = "20003";
    ELIF pnumcuenta IS NULL OR Trim(pnumcuenta) = "" THEN
	   LET v_codret = "20004";
    ELIF ptipo_compac IS NULL OR Trim(ptipo_compac) = "" THEN
	   LET v_codret = "20005";
    ELIF pplazo IS NULL OR Trim(pplazo) = "" THEN
	   LET v_codret = "20006";
    ELIF pimporte IS NULL THEN
	   LET v_codret = "20007";
    ELIF pimporte = 0 THEN --A.L.L valida que el iporte capturado no sea cero
	   LET v_codret = "20007";
    ELIF porigen IS NULL THEN
	   LET v_codret = "20008";
    ELIF pefectuo_compac IS NULL THEN
	   LET v_codret = "20009";
    ELIF psucursal IS NULL OR Trim(psucursal) = "" THEN
	   LET v_codret = "20010";   

    ELIF pquien_convenio IS NULL OR Trim(pquien_convenio) = "" THEN
	   LET v_codret = "20011";

    ELIF pnom_convenio IS NULL OR Trim(pnom_convenio) = "" THEN
	   --LET v_codret = "20012";
	   LET v_codret = "00012";
	   RETURN v_codret;
 --IF preferenciacoppel IS NULL OR Trim(preferenciacoppel) = "" THEN
--	   LET v_codret = "014";
--	   RETURN v_codret;
   --END IF;

    ELIF pfechasistema IS NULL THEN
	    LET v_codret = "20013";
	

    ELIF pnombre_efectuo IS NULL OR Trim(pnombre_efectuo) = "" THEN
	    LET v_codret = "20014";
	

   --CHECAR SI EXISTEN LAS TABLAS
--jom   ELIF  NOT EXISTS (SELECT tabname FROM bdicobranza:systables WHERE tabname = 'cb_compac') THEN
--jom		LET v_codret = "20015";
		

--jom   ELIF NOT EXISTS (SELECT tabname FROM bdicobranza:systables WHERE tabname = 'cb_compac_his') THEN
--jom		LET v_codret = "20016";		
   END IF;
 
   ---Verificar si existe un compromiso vigente (20110124)
    CALL bdicobranza:"informix".sp_consultarcompromisovigente(pempresa, pnumcuenta)
    RETURNING vv_cod_ret, vActivo;
	
--jom	if (porigen = 4)	then
--jom		if (v_codret in("20011","20012","20014")) then
--jom			LET v_codret = '000';  
--jom		end if;
--jom	end if;
    
   IF v_codret = '00000' and vActivo = '0' THEN
   
		IF porigen = 3 THEN
		
			EXECUTE PROCEDURE bdicred:"informix".sp_obtener_pagomin(pEmpresa, pNumCuenta) 
			INTO cCodRet_1, cMensajeRet_1, dImpMensual, dIntVdo,
			dIntMoratorio, dIvaIntVdo, dPagosVdos, dIvaIntMoratorio,
			dIntMes_1, dIvaIntMes_1, dIntVig, dIvaIntVig;
		
			INSERT INTO bdicobranza:cb_compac
				(empresa, sucursal, origen, empleado_captura, numcliente,
				numcuenta, plazo, importe, tipo_compac, activo,
				flag_pago, efectuo_compac, nombre_efectuo,
				fecha_compac, fecha_insert, quien_convenio, nom_convenio, email, referenciacoppel, hora_insert, pago_minimo)
			VALUES (pempresa, psucursal, porigen, pempleado_captura,v_pnumcliente,
				pnumcuenta, pplazo, pimporte, ptipo_compac, '1',
				'0', pefectuo_compac, pnombre_efectuo,
				pfechasistema ,TODAY, pquien_convenio, pnom_convenio, pemail, preferenciacoppel, current,dImpMensual);
		
			UPDATE bdicred:sd_indicador_cred SET num_convenios_hist = nvl(num_convenios_hist,0) + 1,
												  monto_ult_convenio = pimporte,
												  fecha_ult_convenio = pfechasistema 	
			WHERE empresa = pempresa AND num_credito = pnumcuenta;
				 
			LET vCantReg = DBINFO("sqlca.sqlerrd2");

			IF vCantReg = 0 THEN
				UPDATE bdicred:sd_indicador_cred_crd SET num_convenios_hist = nvl(num_convenios_hist,0) + 1
				WHERE empresa = pempresa AND num_credito = pnumcuenta;
			END IF;
		
		ELSE
   
			INSERT INTO bdicobranza:cb_compac
				 (empresa, sucursal, origen, empleado_captura, numcliente,
				numcuenta, plazo, importe, tipo_compac, activo,
				flag_pago, efectuo_compac, nombre_efectuo,
				fecha_compac, fecha_insert, quien_convenio, nom_convenio, email, referenciacoppel, hora_insert)
			 VALUES (pempresa, psucursal, porigen, pempleado_captura,v_pnumcliente,
				pnumcuenta, pplazo, pimporte, ptipo_compac, '1',
				'0', pefectuo_compac, pnombre_efectuo,
				pfechasistema ,TODAY, pquien_convenio, pnom_convenio, pemail, preferenciacoppel, current);
			
				 UPDATE bdicred:sd_indicador_cred SET num_convenios_hist = nvl(num_convenios_hist,0) + 1,
                                                      monto_ult_convenio = pimporte,
                                                      fecha_ult_convenio = pfechasistema 	
				 WHERE empresa = pempresa AND num_credito = pnumcuenta;
				 
				 LET vCantReg = DBINFO("sqlca.sqlerrd2");

				IF vCantReg = 0 THEN
				    UPDATE bdicred:sd_indicador_cred_crd SET num_convenios_hist = nvl(num_convenios_hist,0) + 1
				    WHERE empresa = pempresa AND num_credito = pnumcuenta;
				END IF;			

		END IF;
    ELSE
  	
	
	    IF vActivo = '1' THEN
			LET v_Error = 'SUCURSAL';
			LET v_codret = "20017"; 
		END IF;

		IF porigen = 3 THEN 
			LET v_Error = 'CATONLINE';
			LET v_codret = "00000";
		END IF;
	
		INSERT INTO bdicobranza:"informix".cb_compac_error
				(empresa, sucursal, origen, empleado_captura, numcliente,
	            numcuenta, plazo, importe, tipo_compac, activo,
	            flag_pago, efectuo_compac, nombre_efectuo,
				fecha_compac, fecha_insert, quien_convenio, nom_convenio, email, referenciacoppel, codigo_error, canal, hora_insert)
		VALUES (pempresa, psucursal, porigen, pempleado_captura,v_pnumcliente,
				pnumcuenta, pplazo, pimporte, ptipo_compac, '1',
				'0', pefectuo_compac, pnombre_efectuo,
				pfechasistema ,TODAY, pquien_convenio, pnom_convenio, pemail, preferenciacoppel, v_codret, v_Error, current);
	END IF;

--  if v_codret = '000' then  
--    execute procedure bdicred:sp_graba_indicador(pempresa, pnumcuenta,pimporte,'' , pfechasistema, 5) into vcod_ret;
--  end if;
	RETURN v_codret;
END;
END PROCEDURE
DOCUMENT
'Fecha ModificaciÃ³n: 2013/11/29',
'Autor: Marco A. Campos',
'DESCRIPCION: Realizar validaciÃ³n de Nombre EfectuÃ³',
'Fecha Modificació®º 2018/08/30',
'Autor: Marco A. Campos',
'DESCRIPCION: Actualizació® ©ndicadores TRIAD';

CREATE PROCEDURE "informix".sp_registro_ctetitular_cv_web(pSucural CHAR(4), pEmpleado CHAR(8), pTipoCliente CHAR(1), pFecha DATE)
RETURNING   CHAR(5)     AS cCodRet,
			CHAR(80) 	AS cMensajeRet;

 DEFINE cCodRet         CHAR(5);
 DEFINE iSqlErr         INTEGER;
 DEFINE iIsamErr        INTEGER;
 DEFINE cErrorInfo		CHAR(80);
 DEFINE cMensajeRet     CHAR(80); 

 DEFINE dFechains		DATE;
 DEFINE cSucursal		CHAR(4);
 DEFINE cEmpleado		CHAR(8);
 DEFINE cTipoCliente    CHAR(1);
 
 LET cCodRet = '00000';
 LET cMensajeRet = 'Registro insertado';
 LET cSucursal = pSucural;
 LET cEmpleado = pEmpleado;
 LET cTipoCliente = pTipoCliente;
 LET dFechains = pFecha;

 BEGIN	

     ON EXCEPTION SET iSqlErr, iIsamErr
      	let cCodRet = iSqlErr;
        let cMensajeRet = trim(cCodRet) || '- ' || iIsamErr ;
			  
        RETURN cCodRet,cMensajeRet;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
   IF cSucursal = '' OR cEmpleado = '' OR NVL(dFechains,'') = '' THEN
      LET cCodRet = '00001';
	  LET cMensajeRet = 'ParÃ¡metros incompletos';
	  RETURN cCodRet,cMensajeRet;
   END IF;
  
   
   IF cTipoCliente = 'T' THEN
   
	   INSERT INTO "informix".cb_cob_vent_cliente_titular(fecha, sucursal, empleado, cont_si, cont_no)
	   VALUES(dFechains, cSucursal, cEmpleado, 1, 0);
   ELSE
   
       INSERT INTO "informix".cb_cob_vent_cliente_titular(fecha, sucursal, empleado, cont_si, cont_no)
	   VALUES(dFechains, cSucursal, cEmpleado, 0, 1);
   END IF;
   
 RETURN cCodRet,cMensajeRet;

END;
 
END PROCEDURE
DOCUMENT
'Autor: Marco A. Campos',
'Fecha: 20200803',
'DescripciÃ³n: Regisra en tabla un contador cuando el cliente es titulas o no, para Cobranza en Ventanilla',
'BD: bdicobranza';

CREATE PROCEDURE "informix".sp_cilocconsultacausasituacionesespeciales(cSituacion CHAR(1), pCausa INTEGER)
		RETURNING   CHAR(5) as Codigo,	--codret
					CHAR(3) as Causa, --Causa segun la situacion seleccionada
					CHAR(75) as Descripcion;
					
	DEFINE cCodRet 			CHAR(5);
	DEFINE iCont            INTEGER;
	DEFINE iSqlErr 			INTEGER;
	DEFINE cDescripcion    	CHAR(75);
	DEFINE cCausa 			CHAR(3); 
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET icont=0;
	LET cDescripcion= '';
	LET cCausa='';
	--------------------------------------------------------------------------
	--SET DEBUG FILE TO '/home/sysifx/Malena/sp_CiLocConsultaCausaSituacionesEspeciales.out';
	--TRACE ON;
	--------------------------------------------------------------------------
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			LET cDescripcion='Error de Informix';
			RETURN cCodRet,cCausa,cDescripcion;
		END EXCEPTION;		
		
	--Se realiza consulta a la tabla se_catsitesp para obtener las causas de las situaciones especiales.	
	
	set isolation to dirty read; -- Lectura de tablas bloqueadas.
	
		FOREACH   
			SELECT {+INDEX(bdisitesp:se_catsitesp idx_catsitesp)} distinct(causa),descripcion
			INTO  cCausa,cDescripcion
			FROM bdisitesp:se_catsitesp
			WHERE situacion = TRIM(cSituacion)
			AND causa = CASE WHEN pCausa = 0 THEN causa ELSE pCausa END
			LET icont=icont+1;
            RETURN cCodret,cCausa,cDescripcion WITH RESUME;
		END FOREACH;		
		
        IF icont == 0 THEN 
			LET cCodret='00001';  
			LET cDescripcion='No hay Informacion en la tabla';
            RETURN cCodret,cCausa,cDescripcion WITH RESUME;
        END IF;

	END;
END PROCEDURE

DOCUMENT
'AUTOR       : Maria Elena Angulo Aispuro',
'DESCRIPCION : Devuelve un listado de las causas existentes en la tabla se_catsitesp segun la situacion especial',
'FECHA       : 16 de Agosto de 2010',
'VERSION     : 20100816.1230',
'BD          : BDICOBRANZA';

CREATE PROCEDURE "informix".sp_asigna_cartera_agex(ptipo_cobranza CHAR(1), paccion CHAR(2))
returning VARCHAR(06),
          VARCHAR(80);
-----------------------------------------------------------------------
--  EXECUTE PROCEDURE "informix".sp_asigna_cartera_agex('R', 'AS');

DEFINE SQL_ERR					INTEGER;
DEFINE ISAM_ERR					INTEGER;
DEFINE ERROR_INFO				VARCHAR(80);
DEFINE cProceso					CHAR(4);
DEFINE P_COD_RET				VARCHAR(6);
DEFINE P_MENSAJE				VARCHAR(200);
DEFINE cCodRet  				CHAR(6);

DEFINE v_pago_venc_ini			INTEGER;
DEFINE v_pago_venc_fin			INTEGER;
DEFINE v_porcentaje_asignado 	DECIMAL(9,2);
DEFINE pfechaevalua				DATE;
DEFINE v_cantidadtdc 			INTEGER;
DEFINE v_asignados				INTEGER;
DEFINE vcontador 				INTEGER;
DEFINE v_num_producto			CHAR(4);
DEFINE v_numcte 				CHAR(20);
DEFINE v_fecha_insert			DATE;
DEFINE v_num_credito 			CHAR(20);
DEFINE v_puntualidad 			CHAR(1);
DEFINE v_eficiencia 			SMALLINT;
DEFINE v_calificacion 			SMALLINT;
DEFINE v_pago_venc 				SMALLINT;
DEFINE v_prioridad 				SMALLINT;
DEFINE v_tipo_logica 			SMALLINT;
DEFINE v_status_cliente 		CHAR(2);
DEFINE v_tipo_movto 			SMALLINT;
DEFINE v_fecha_modificacion 	DATE;
DEFINE v_apell_paterno 			CHAR(26);
DEFINE v_apell_materno 			CHAR(26);
DEFINE v_nombre1 				CHAR(26);
DEFINE v_nombre2 				CHAR(26);
DEFINE v_sucursal 				CHAR(4);
DEFINE v_fecha_apertura 		DATE;
DEFINE v_monto_ult_pago_periodo DECIMAL(18,2);
DEFINE v_pagos_realizados 		DECIMAL(18,2);
DEFINE v_fecha_ultimo_pago 		DATE;
DEFINE v_dias_atraso 			SMALLINT;
DEFINE v_saldo_vencido_inicial 	DECIMAL(18,2);
DEFINE v_saldo_total_inicial 	DECIMAL(18,2);
DEFINE v_saldo_vencido_final 	DECIMAL(18,2);
DEFINE v_saldo_total_final 		DECIMAL(18,2);
DEFINE v_saldovencido1 			DECIMAL(18,2);
DEFINE v_saldovencido2 			DECIMAL(18,2);
DEFINE v_saldovencido3 			DECIMAL(18,2);
DEFINE v_saldovencido4 			DECIMAL(18,2);
DEFINE v_saldovencido5 			DECIMAL(18,2);
DEFINE v_saldovencido6 			DECIMAL(18,2);
DEFINE v_interesmoratorio1 		DECIMAL(18,2);
DEFINE v_interesmoratorio2 		DECIMAL(18,2);
DEFINE v_interesmoratorio3 		DECIMAL(18,2);
DEFINE v_interesmoratorio4 		DECIMAL(18,2);
DEFINE v_interesmoratorio5 		DECIMAL(18,2);
DEFINE v_interesmoratorio6 		DECIMAL(18,2);
DEFINE v_sdo_intereses 			DECIMAL(18,2);
DEFINE v_pago_vencido1_inicial	DECIMAL(18,2);
DEFINE v_pago_vencido2_inicial	DECIMAL(18,2);
DEFINE v_pago_vencido3_inicial	DECIMAL(18,2);
DEFINE v_pago_vencido4_inicial	DECIMAL(18,2);
DEFINE v_pago_vencido1_final 	DECIMAL(18,2);
DEFINE v_pago_vencido2_final 	DECIMAL(18,2);
DEFINE v_pago_vencido3_final 	DECIMAL(18,2);
DEFINE v_pago_vencido4_final 	DECIMAL(18,2);
DEFINE v_cantidadpp12 			INTEGER;
DEFINE v_preasignados 			INTEGER;
DEFINE v_cantidadant 	 		INTEGER;
DEFINE cNumProd 				CHAR(4);
DEFINE v_fecha_vigencia			DATE;
DEFINE vFecha_hoy               DATE;
DEFINE b_Upd_saldos_ini         CHAR(1);

DEFINE iCantTbl_Agex            INTEGER;
DEFINE c_digitos_selec          CHAR(2);
DEFINE cSql                     CHAR(500);
DEFINE vEmpresa                 CHAR(3);
DEFINE cruta                    CHAR(100);
DEFINE iCantTest                INTEGER;
DEFINE iCargaIni_A              INTEGER;
DEFINE iCargaIni_R              INTEGER;
DEFINE iCargaSig_A              INTEGER;
DEFINE iCargaSig_R              INTEGER;
DEFINE v_num_credito_previo		CHAR(20);
DEFINE v_pago_venc_previo       INTEGER;        
DEFINE v_numcte_previo          CHAR(20);
DEFINE c_canal                  CHAR(4);
DEFINE dt_fecha_asigna_mesant   DATE;
DEFINE v_numcte_mesant			CHAR(20);
DEFINE v_num_credito_mesant	    CHAR(20);
DEFINE c_canal_mesant           CHAR(4);
DEFINE vFecha_hoy_sys           DATE;
DEFINE pfechaevalua_tdc			DATE;
DEFINE v_pago_venc_en_tipoA     SMALLINT;
DEFINE v_numcte_en_tipoA        CHAR(20);
DEFINE v_num_credito_en_tipoA   CHAR(20);
DEFINE c_canal_en_tipoA         CHAR(4);
DEFINE v_num_credito_c 			CHAR(20);
DEFINE v_status_cliente_c 		CHAR(2);
DEFINE v_tipomov		 		INTEGER;
DEFINE v_bandera_reasigna		INTEGER;
DEFINE c_canal_reasigna         VARCHAR(4);
DEFINE c_canal_anterior         VARCHAR(4);
DEFINE c_fecha_reasigna         DATE;
DEFINE cCanal_digitos			VARCHAR(4);
DEFINE cCanal_actual			VARCHAR(4);
      
BEGIN 
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
     LET P_COD_RET = SQL_ERR;
     LET P_MENSAJE = ERROR_INFO ||'   Error credito: '||v_num_credito;
     CALL "informix".sp_inserta_bitacora_cob("001", cProceso, P_COD_RET, P_MENSAJE, '02')
     RETURNING P_COD_RET;
     LET P_COD_RET = SQL_ERR;
     RETURN P_COD_RET,P_MENSAJE;
   END EXCEPTION;

	--SET DEBUG FILE TO "/ifxsif01/aldo/asig/sp_asigna_cartera_agex.out";
	--TRACE ON;

	LET cProceso            		= '0086';
	LET P_COD_RET           		= '000000';
	LET P_MENSAJE           		= 'El proceso ASIGNACION EXT se ejecuto correctamente.';
	LET cCodRet           			= '000000';

	LET v_pago_venc_ini				= 0;
	LET v_pago_venc_fin				= 0;
	LET v_porcentaje_asignado 		= 0;
	LET pfechaevalua				= DATE(1);
	LET v_cantidadtdc 				= 0;
	LET v_asignados					= 0;
	LET vcontador 					= 0;
	LET v_num_producto				= "";
	LET v_numcte 					= "";
	LET v_fecha_insert				= DATE(1);
	LET v_num_credito 				= "";
	LET v_puntualidad 				= "";
	LET v_eficiencia 				= 0;
	LET v_calificacion 				= 0;
	LET v_pago_venc 				= 0;
	LET v_prioridad 				= 0;
	LET v_tipo_logica 				= 0;
	LET v_status_cliente 			= "";
	LET v_tipo_movto 				= 0;
	LET v_fecha_modificacion 		= DATE(1);
	LET v_apell_paterno 			= "";
	LET v_apell_materno 			= "";
	LET v_nombre1 					= "";
	LET v_nombre2 					= "";
	LET v_sucursal 					= "";
	LET v_fecha_apertura 			= DATE(1);
	LET v_monto_ult_pago_periodo 	= 0;
	LET v_pagos_realizados 			= 0;
	LET v_fecha_ultimo_pago 		= DATE(1);
	LET v_dias_atraso 				= 0;
	LET v_saldo_vencido_inicial 	= 0;
	LET v_saldo_total_inicial 		= 0;
	LET v_saldo_vencido_final 		= 0;
	LET v_saldo_total_final 		= 0;
	LET v_saldovencido1 			= 0;
	LET v_saldovencido2 			= 0;
	LET v_saldovencido3 			= 0;
	LET v_saldovencido4 			= 0;
	LET v_saldovencido5 			= 0;
	LET v_saldovencido6 			= 0;
	LET v_interesmoratorio1 		= 0;
	LET v_interesmoratorio2 		= 0;
	LET v_interesmoratorio3 		= 0;
	LET v_interesmoratorio4 		= 0;
	LET v_interesmoratorio5 		= 0;
	LET v_interesmoratorio6 		= 0;
	LET v_sdo_intereses 			= 0;
	LET v_pago_vencido1_inicial		= 0;
	LET v_pago_vencido2_inicial		= 0;
	LET v_pago_vencido3_inicial		= 0;
	LET v_pago_vencido4_inicial		= 0;
	LET v_pago_vencido1_final 		= 0;
	LET v_pago_vencido2_final 		= 0;
	LET v_pago_vencido3_final 		= 0;
	LET v_pago_vencido4_final 		= 0;
	LET v_cantidadpp12 				= 0;
	LET v_preasignados 				= 0;
	LET v_cantidadant 	 			= 0;
	LET cNumProd 					= "";
	LET v_fecha_vigencia 			= DATE(1);
    LET vFecha_hoy                  = DATE(1);
	LET iCantTbl_Agex               = 0;
	LET c_digitos_selec             = '';
	LET cSql                        = ''; 
    LET vEmpresa                    = '001';
	LET cruta                       = '';
	LET iCantTest                   = 0;
	
	
	LET iCargaIni_A             = 0;
    LET iCargaIni_R             = 0;
    LET iCargaSig_A             = 0;
    LET iCargaSig_R             = 0;
	LET v_num_credito_previo    = '';
	LET v_pago_venc_previo      = 0;
	LET v_numcte_previo         = '';
	LET c_canal                 = '';  
	LET dt_fecha_asigna_mesant  = DATE(1);
	LET v_numcte_mesant			= '';
    LET v_num_credito_mesant	= '';
    LET c_canal_mesant          = '';
	LET b_Upd_saldos_ini        = '0'; 
	LET vFecha_hoy_sys          = DATE(1);
	LET pfechaevalua_tdc        = DATE(1);
	LET v_pago_venc_en_tipoA    = 0;
	LET v_numcte_en_tipoA       = '';
	LET v_num_credito_en_tipoA  = '';
	LET c_canal_en_tipoA        = '';
	LET v_num_credito_c 		= "";
	LET v_status_cliente_c		= '';
	LET v_tipomov				= 0;
	LET v_bandera_reasigna 		= 0;
	LET c_canal_reasigna		= '';
	LET c_canal_anterior		= '';	
    LET c_fecha_reasigna		= DATE(1);	
	LET cCanal_digitos			= '';
	LET cCanal_actual			= '';
	

	CALL "informix".sp_inserta_bitacora_cob("001", cProceso, cCodRet, "INICIO PROCESO "||paccion||" PARA TIPO COBRANZA "||ptipo_cobranza||"", '02')
		RETURNING P_COD_RET;

	IF P_COD_RET != '000000' THEN
	   LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
	   RETURN P_COD_RET,P_MENSAJE;
	END IF;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;


		
	SELECT MAX(fecha_insert) INTO pfechaevalua
	FROM "informix".cb_cat_directorio_cte
	WHERE tipo_cobranza = ptipo_cobranza; 

	--LET pfechaevalua = MDY(02,20,2020); -- PARA TEST TIPO R (MACF)
    --LET vFecha_hoy_sys = MDY(03,24,2019);  -- SOLO TEST MACF 

	LET vFecha_hoy_sys = TODAY;
	
    --LET dt_fecha_asigna_mesant = pfechaevalua -1 UNITS MONTH;
	LET dt_fecha_asigna_mesant = bdicred:monthadd(pfechaevalua, -1);
	 
	  
	IF paccion = "AS" THEN	
	
		
		IF ptipo_cobranza = "A" THEN
			   
			   
			   -- Crear tabla temporal con los datos de la asignaciÃÂÃÂÃÂÃÂ³n anterior (mes anterior)
			    SELECT numcte, num_credito, pago_venc, canal 
				  FROM bdicobranza:cb_cat_directorio_cte
				 WHERE empresa = vEmpresa AND tipo_cobranza = ptipo_cobranza 
				   AND fecha_insert = dt_fecha_asigna_mesant
				   AND status_cliente NOT IN('NT')
				  INTO temp paso_catdircte_anterior with no log;
				  
				  CREATE UNIQUE INDEX inx_paso_catdircte_anterior on paso_catdircte_anterior(numcte,num_credito);
                  UPDATE STATISTICS MEDIUM FOR TABLE paso_catdircte_anterior;
			   
				FOREACH WITH HOLD
			
				SELECT DISTINCT(canal) INTO c_canal_reasigna
				  FROM bdicobranza:cb_cat_directorio_cte
				 WHERE empresa = vEmpresa
				  AND tipo_cobranza = ptipo_cobranza
				  AND fecha_insert = pfechaevalua
				  AND status_cliente IN ("AC","EX")

					FOREACH WITH HOLD
					
						SELECT {+AVOID_FULL(bdicobranza:cb_gestion_cobagext_clasifica)} a.num_producto, a.numcte, a.num_credito, a.puntualidad, a.eficiencia, a.calificacion, a.pago_venc, 
							a.prioridad, a.tipo_logica, a.status_cliente, a.tipo_movto, a.fecha_modificacion, a.apell_paterno, a.apell_materno,
							a.nombre1, a.nombre2, a.digitos_selec, c.canal, a.canal
						INTO v_num_producto, v_numcte, v_num_credito, v_puntualidad, v_eficiencia, v_calificacion, v_pago_venc, 
							v_prioridad, v_tipo_logica, v_status_cliente, v_tipo_movto, v_fecha_modificacion, v_apell_paterno, v_apell_materno,
							v_nombre1, v_nombre2, c_digitos_selec, c_canal, cCanal_actual
						FROM bdicobranza:cb_cat_directorio_cte a
							INNER JOIN bdicobranza:cb_gestion_cobagext_clasifica c ON(a.digitos_selec = c.digitos_selec) -- and c.canal IN('PENT','TEST')   
						WHERE a.empresa = vEmpresa 
						AND a.tipo_cobranza = ptipo_cobranza
						AND a.fecha_insert = pfechaevalua 
						AND a.status_cliente IN ("AC","EX") 
						AND a.canal = c_canal_reasigna


						SELECT numcte, num_credito, canal INTO v_numcte_mesant, v_num_credito_mesant, c_canal_mesant
						FROM paso_catdircte_anterior
						WHERE numcte = v_numcte AND num_credito = v_num_credito;

						LET v_numcte_mesant = NVL(v_numcte_mesant,'');
						LET v_num_credito_mesant = NVL(v_num_credito_mesant,''); 
						LET c_canal_mesant = NVL(c_canal_mesant,'');
						LET v_bandera_reasigna = 1;
						
						-- Si existe en el mes anterior, solamente le actualizao el canal ya que si una vez fue asignado a ÃÂÃÂÃÂÃÂ©l
						-- no importa si aumentÃÂÃÂÃÂÃÂ³ o disminuyo su mora debe seguir atendiÃÂÃÂÃÂÃÂ©ndolo ese canal (de agex?)

						IF nvl(c_canal,'') = 'CAT' THEN
							LET cCanal_digitos='';
						ELSE 
							LET cCanal_digitos=c_canal;
						END IF;


						IF nvl(c_canal_mesant,'') != nvl(cCanal_digitos,'') AND nvl(c_canal_mesant,'') != '' THEN 
							BEGIN WORK;
								UPDATE "informix".cb_cat_directorio_cte 
								SET canal = cCanal_digitos, fecha_reasignacion=pfechaevalua, canal_ant_reasigna=c_canal_mesant
								WHERE empresa = vEmpresa 
								AND tipo_cobranza = ptipo_cobranza
								AND num_credito = v_num_credito
								AND fecha_insert = pfechaevalua; 
							COMMIT WORK;

						ELIF nvl(v_numcte_mesant,'') <> '' AND nvl(v_num_credito_mesant,'') <> '' and nvl(c_canal_mesant,'') <> '' THEN
							BEGIN WORK;
								UPDATE "informix".cb_cat_directorio_cte 
								SET canal = c_canal_mesant
								WHERE empresa = vEmpresa 
								AND tipo_cobranza = ptipo_cobranza
								AND num_credito = v_num_credito
								AND fecha_insert = pfechaevalua; 
							COMMIT WORK;

						ELIF v_pago_venc > 2 THEN
							IF trim(c_canal) = 'TEST' THEN
								Let v_status_cliente = 'TE';  
								BEGIN WORK;
									UPDATE "informix".cb_cat_directorio_cte 
									SET canal = 'TEST', status_cliente = v_status_cliente, fecha_reasignacion=pfechaevalua
									WHERE empresa = vEmpresa 
									AND tipo_cobranza = ptipo_cobranza
									AND num_credito = v_num_credito
									AND fecha_insert = pfechaevalua; 
								COMMIT WORK;
							ELIF (nvl(c_canal,'') <> '' AND nvl(c_canal,'') <> 'CAT' ) THEN
								IF v_pago_venc <= 8 THEN
									BEGIN WORK;
									UPDATE "informix".cb_cat_directorio_cte 
										SET canal = c_canal, fecha_reasignacion=pfechaevalua
									WHERE empresa = vEmpresa 
										AND tipo_cobranza = ptipo_cobranza
										AND num_credito = v_num_credito
										AND fecha_insert = pfechaevalua; 
									COMMIT WORK;
								ELSE
									LET v_bandera_reasigna = 0;	
								END IF;
							ELSE
								LET v_bandera_reasigna = 0;	   						    
							END IF;	
						ELSE
							LET v_bandera_reasigna = 0;
						END IF;						
						
						IF v_bandera_reasigna = 1 THEN
							FOREACH WITH HOLD
								SELECT num_credito,status_cliente, tipo_movto, canal, fecha_insert 
									INTO v_num_credito_c,v_status_cliente_c, v_tipomov, c_canal_anterior, c_fecha_reasigna 
								  FROM bdicobranza:cb_cat_directorio_cte
								  WHERE empresa = vEmpresa 
								  	AND status_cliente IN ("AC","EX") 
									AND canal != c_canal
									AND numcte = v_numcte
									AND num_credito != v_num_credito
									AND fecha_insert BETWEEN (pfechaevalua - 1 UNITS MONTH) AND (pfechaevalua)

								IF v_status_cliente_c = 'EX' THEN
									LET v_tipomov=9;
								END IF;	
								
								BEGIN WORK;
									UPDATE "informix".cb_cat_directorio_cte 
									SET canal = cCanal_digitos, fecha_reasignacion=pfechaevalua,
											tipo_movto=v_tipomov, canal_ant_reasigna=c_canal_anterior 
									WHERE empresa = vEmpresa 
									AND num_credito = v_num_credito_c
									AND fecha_insert = c_fecha_reasigna; 
								COMMIT WORK;
							END FOREACH;
						END IF;

					END FOREACH;

				END FOREACH;
			
		ELIF ptipo_cobranza = 'R' THEN 	--Tipo Cob R  (AsignaciÃÂÃÂÃÂÃÂ³n)

		        SELECT MAX(fecha_insert) INTO pfechaevalua_tdc
	              FROM "informix".cb_cat_directorio_cte
	             WHERE tipo_cobranza = 'A'; 
				
				--IF DAY(pfechaevalua) = 30 AND ( DAY(dt_fecha_asigna_mesant) = 30 AND month(dt_fecha_asigna_mesant) in(4,6,9,11) )  THEN
				IF DAY(pfechaevalua) = 30 AND ( DAY(dt_fecha_asigna_mesant) = 30 AND month(dt_fecha_asigna_mesant) in(3,5,8,10) )  THEN
				
				   SELECT num_producto, numcte, num_credito, pago_venc, canal 
				     FROM bdicobranza:cb_cat_directorio_cte
				    WHERE empresa = vEmpresa AND tipo_cobranza = ptipo_cobranza AND fecha_insert BETWEEN dt_fecha_asigna_mesant AND (dt_fecha_asigna_mesant +1 UNITS DAY)
				      AND status_cliente NOT IN('EX','NT')
			         INTO temp paso_catdircte_anterior with no log;
				
				/*ELIF DAY(pfechaevalua) = 30 AND ( DAY(dt_fecha_asigna_mesant) = 31 AND month(dt_fecha_asigna_mesant) in() )  THEN
				   
				   SELECT num_producto, numcte, num_credito, pago_venc, canal 
				     FROM bdicobranza:cb_cat_directorio_cte
				    WHERE empresa = vEmpresa AND tipo_cobranza = ptipo_cobranza AND fecha_insert BETWEEN (dt_fecha_asigna_mesant -1 UNITS DAY) AND dt_fecha_asigna_mesant
				      AND status_cliente NOT IN('EX','NT')
			         INTO temp paso_catdircte_anterior with no log; */
				   
				ELIF ( DAY(pfechaevalua) = 28 AND MONTH(pfechaevalua)= 2) OR (DAY(pfechaevalua) = 29 AND MONTH(pfechaevalua)= 2) THEN
                     LET dt_fecha_asigna_mesant = MDY(MONTH(dt_fecha_asigna_mesant),31,YEAR(dt_fecha_asigna_mesant));
					 
					 SELECT num_producto, numcte, num_credito, pago_venc, canal 
				     FROM bdicobranza:cb_cat_directorio_cte
				    WHERE empresa = vEmpresa AND tipo_cobranza = ptipo_cobranza AND fecha_insert BETWEEN (dt_fecha_asigna_mesant -1 UNITS DAY) AND dt_fecha_asigna_mesant
				      AND status_cliente NOT IN('EX','NT')
			         INTO temp paso_catdircte_anterior with no log;
					 
				ELSE
				
				   SELECT num_producto, numcte, num_credito, pago_venc, canal 
				     FROM bdicobranza:cb_cat_directorio_cte
				    WHERE empresa = vEmpresa AND tipo_cobranza = ptipo_cobranza AND fecha_insert = dt_fecha_asigna_mesant
				      AND status_cliente NOT IN('EX','NT')
			         INTO temp paso_catdircte_anterior with no log;
				
				END IF;
			

			FOREACH WITH HOLD
			
				SELECT DISTINCT(canal) INTO c_canal_reasigna
				  FROM bdicobranza:cb_cat_directorio_cte
				 WHERE empresa = vEmpresa
				   AND tipo_cobranza = ptipo_cobranza
				   AND fecha_insert = pfechaevalua
				   AND status_cliente IN ("AC","EX")
				   AND num_producto IN ('6300','7600','7700','6800','6011') 
			    
				FOREACH WITH HOLD
					SELECT {+AVOID_FULL(bdicobranza:cb_gestion_cobagext_clasifica)} a.num_producto, a.numcte, a.num_credito, a.puntualidad, a.eficiencia, a.calificacion, a.pago_venc, 
							a.prioridad, a.tipo_logica, a.status_cliente, a.tipo_movto, a.fecha_modificacion, a.apell_paterno, a.apell_materno,
							a.nombre1, a.nombre2, a.digitos_selec, c.canal, a.canal
						INTO v_num_producto, v_numcte, v_num_credito, v_puntualidad, v_eficiencia, v_calificacion, v_pago_venc, 
							v_prioridad, v_tipo_logica, v_status_cliente, v_tipo_movto, v_fecha_modificacion, v_apell_paterno, v_apell_materno,
							v_nombre1, v_nombre2, c_digitos_selec, c_canal, cCanal_actual
						FROM bdicobranza:cb_cat_directorio_cte a
							INNER JOIN bdicobranza:cb_gestion_cobagext_clasifica c ON(a.digitos_selec = c.digitos_selec) -- and c.canal IN('PENT','TEST')   
						WHERE a.empresa = vEmpresa AND a.tipo_cobranza = ptipo_cobranza AND a.fecha_insert = pfechaevalua 
						AND a.status_cliente IN ("AC","EX") 
						AND a.num_producto IN ('6300','7600','7700','6800','6011')
						AND a.canal = c_canal_reasigna
					  
					/*-- Validar si el cliente ya estÃÂÃÂÃÂÃÂ¡ asignado en TDC (ÃÂÃÂÃÂÃÂltimo corte)
					--IPCB se incluye el limit para tener un registro unico
					SELECT limit 1 numcte, num_credito, canal, pago_venc INTO v_numcte_en_tipoA, v_num_credito_en_tipoA, c_canal_en_tipoA, v_pago_venc_en_tipoA
					  FROM bdicobranza:cb_cat_directorio_cte
					 WHERE tipo_cobranza = 'A' and fecha_insert = pfechaevalua_tdc 
					   AND numcte = v_numcte;
					   
					LET v_numcte_en_tipoA = NVL(v_numcte_en_tipoA,'');
                    LET v_num_credito_en_tipoA = NVL(v_num_credito_en_tipoA,'');
                    
					IF v_numcte_en_tipoA <> '' AND v_num_credito_en_tipoA <> '' THEN
                       BEGIN;
					        UPDATE "informix".cb_cat_directorio_cte 
						       SET canal = c_canal_en_tipoA
						     WHERE empresa = vEmpresa 
						       AND tipo_cobranza = ptipo_cobranza
						       AND num_credito = v_num_credito
						       AND fecha_insert = pfechaevalua; 
					   COMMIT;   
   					ELSE*/
					
						--Buscar el cliente en el corte anterior
						SELECT numcte, num_credito, canal INTO v_numcte_mesant, v_num_credito_mesant, c_canal_mesant
						  FROM paso_catdircte_anterior
						 WHERE numcte = v_numcte AND num_credito = v_num_credito;

						LET v_numcte_mesant = NVL(v_numcte_mesant,'');
						LET v_num_credito_mesant = NVL(v_num_credito_mesant,''); 
						LET c_canal_mesant = NVL(c_canal_mesant,'');
						LET v_bandera_reasigna = 1;
						
						-- Si existe en el mes anterior, solamente le actualizo el canal ya que si una vez fue asignado a ÃÂÃÂÃÂÃÂ©l
						-- no importa si aumentÃÂÃÂÃÂÃÂ³ o disminuyo su mora debe seguir atendiÃÂÃÂÃÂÃÂ©ndolo ese canal

						IF nvl(c_canal,'') = 'CAT' THEN
							LET cCanal_digitos='';
						ELSE 
							LET cCanal_digitos=c_canal;
						END IF;

						IF nvl(c_canal_mesant,'') != nvl(cCanal_digitos,'') AND nvl(c_canal_mesant,'') != '' THEN 
							BEGIN WORK;
								UPDATE "informix".cb_cat_directorio_cte 
								SET canal = cCanal_digitos, fecha_reasignacion=pfechaevalua, canal_ant_reasigna=c_canal_mesant
								WHERE empresa = vEmpresa 
								AND tipo_cobranza = ptipo_cobranza
								AND num_credito = v_num_credito
								AND fecha_insert = pfechaevalua; 
							COMMIT WORK; 

						ELIF v_numcte_mesant <> '' AND v_num_credito_mesant <> '' and nvl(c_canal_mesant,'') <> '' THEN
						    BEGIN;
								UPDATE "informix".cb_cat_directorio_cte 
								   SET canal = c_canal_mesant
								 WHERE empresa = vEmpresa 
								   AND tipo_cobranza = ptipo_cobranza
								   AND num_credito = v_num_credito
								   AND fecha_insert = pfechaevalua; 
						    COMMIT; 
						
						ELIF v_pago_venc > 2 THEN
							IF c_canal = 'TEST' THEN
								Let v_status_cliente = 'TE';  
								BEGIN;
									UPDATE "informix".cb_cat_directorio_cte 
									SET canal = 'TEST', status_cliente = v_status_cliente, fecha_reasignacion=pfechaevalua
									WHERE empresa = vEmpresa 
									AND tipo_cobranza = ptipo_cobranza
									AND num_credito = v_num_credito
									AND fecha_insert = pfechaevalua; 
								COMMIT;

							ELIF (nvl(c_canal,'') <> '' AND nvl(c_canal,'') <> 'CAT' ) THEN
								IF v_pago_venc <= 8 THEN
									BEGIN;
									UPDATE "informix".cb_cat_directorio_cte 
										SET canal = c_canal, fecha_reasignacion=pfechaevalua
									WHERE empresa = vEmpresa 
										AND tipo_cobranza = ptipo_cobranza
										AND num_credito = v_num_credito
										AND fecha_insert = pfechaevalua; 
									COMMIT;
								ELSE
									LET v_bandera_reasigna = 0;	
								END IF;			
							ELSE
								LET v_bandera_reasigna = 0;					    
							END IF;	
						ELSE
							LET v_bandera_reasigna = 0;
						END IF;

						IF v_bandera_reasigna = 1 THEN
							FOREACH WITH HOLD
								SELECT num_credito,status_cliente, tipo_movto, canal, fecha_insert 
									INTO v_num_credito_c,v_status_cliente_c, v_tipomov, c_canal_anterior, c_fecha_reasigna 
								  FROM bdicobranza:cb_cat_directorio_cte
								  WHERE empresa = vEmpresa 
								  	AND status_cliente IN ("AC","EX") 
									AND canal != c_canal
									AND numcte = v_numcte
									AND num_credito != v_num_credito
									AND fecha_insert BETWEEN (pfechaevalua - 1 UNITS MONTH) AND (pfechaevalua)

								IF v_status_cliente_c = 'EX' THEN
									LET v_tipomov=9;
								END IF;	
								
								BEGIN WORK;
									UPDATE "informix".cb_cat_directorio_cte 
									SET canal = cCanal_digitos, fecha_reasignacion=pfechaevalua,
											tipo_movto=v_tipomov, canal_ant_reasigna=c_canal_anterior 
									WHERE empresa = vEmpresa 
									AND num_credito = v_num_credito_c
									AND fecha_insert = c_fecha_reasigna; 
								COMMIT WORK;
							END FOREACH;
						END IF;
					
				END FOREACH;
			END FOREACH;	
		END IF;	

    ELIF paccion = "AC" THEN
	
		IF ptipo_cobranza = "A" THEN

		FOREACH WITH HOLD
			SELECT DISTINCT(canal) INTO c_canal
				FROM bdicobranza:cb_cat_directorio_cte
				WHERE empresa = vEmpresa
				AND tipo_cobranza = ptipo_cobranza
				AND num_producto in("6001","8100")
				AND fecha_insert >= (TODAY - 1 UNITS MONTH)
				AND fecha_insert <= TODAY

			FOREACH WITH HOLD
				SELECT fecha_insert, num_credito, status_cliente, tipo_movto, fecha_modificacion
				INTO v_fecha_insert, v_num_credito, v_status_cliente, v_tipo_movto, v_fecha_modificacion
				FROM "informix".cb_cat_directorio_cte
				WHERE empresa = "001"
				AND tipo_cobranza = ptipo_cobranza
				AND num_producto in("6001","8100")
				AND fecha_insert >= (TODAY - 1 UNITS MONTH)
				AND fecha_insert <= TODAY
				AND canal = c_canal

				SELECT monto_ultimo_pago, fecha_ultimo_pago, dias_atraso
					INTO v_monto_ult_pago_periodo, v_fecha_ultimo_pago, v_dias_atraso
				FROM bdicred:"informix".sd_indicador_cred
				WHERE empresa = "001"
				AND num_credito = v_num_credito;

				SELECT mto_venc_trasp+monto_vencido, sdo_cap_insoluto, saldovencido1, saldovencido2, saldovencido3,
						saldovencido4, saldovencido5, saldovencido6, interesmoratorio1, interesmoratorio2,
						interesmoratorio3, interesmoratorio4, interesmoratorio5, interesmoratorio6, sdo_intereses
					INTO v_saldo_vencido_inicial, v_saldo_total_inicial, v_saldovencido1, v_saldovencido2, v_saldovencido3,
						v_saldovencido4, v_saldovencido5, v_saldovencido6, v_interesmoratorio1, v_interesmoratorio2,
						v_interesmoratorio3, v_interesmoratorio4, v_interesmoratorio5, v_interesmoratorio6, v_sdo_intereses
				FROM bdicred:"informix".sd_sdos_cartera_linea
				WHERE num_credito = v_num_credito;

				IF v_monto_ult_pago_periodo IS NULL THEN LET v_monto_ult_pago_periodo = 0; END IF;
				IF v_dias_atraso IS NULL THEN LET v_dias_atraso = 0; END IF;
				IF v_saldo_vencido_inicial IS NULL THEN LET v_saldo_vencido_inicial = 0; END IF;
				IF v_saldo_total_inicial IS NULL THEN LET v_saldo_total_inicial = 0; END IF;
				IF v_saldovencido1 IS NULL THEN LET v_saldovencido1 = 0; END IF;
				IF v_saldovencido2 IS NULL THEN LET v_saldovencido2 = 0; END IF;
				IF v_saldovencido3 IS NULL THEN LET v_saldovencido3 = 0; END IF;
				IF v_saldovencido4 IS NULL THEN LET v_saldovencido4 = 0; END IF;
				IF v_saldovencido5 IS NULL THEN LET v_saldovencido5 = 0; END IF;
				IF v_saldovencido6 IS NULL THEN LET v_saldovencido6 = 0; END IF;
				IF v_interesmoratorio1 IS NULL THEN LET v_interesmoratorio1 = 0; END IF;
				IF v_interesmoratorio2 IS NULL THEN LET v_interesmoratorio2 = 0; END IF;
				IF v_interesmoratorio3 IS NULL THEN LET v_interesmoratorio3 = 0; END IF;
				IF v_interesmoratorio4 IS NULL THEN LET v_interesmoratorio4 = 0; END IF;
				IF v_interesmoratorio5 IS NULL THEN LET v_interesmoratorio5 = 0; END IF;
				IF v_interesmoratorio6 IS NULL THEN LET v_interesmoratorio6 = 0; END IF;
				IF v_sdo_intereses IS NULL THEN LET v_sdo_intereses = 0; END IF;

				LET v_saldo_vencido_final = v_saldo_vencido_inicial; LET v_saldo_total_final = v_saldo_total_inicial;

				--IF (v_fecha_insert = TODAY - 1 UNITS DAY)THEN
				IF (v_fecha_insert = vFecha_hoy_sys - 1 UNITS DAY)THEN
					LET v_pago_vencido1_inicial = v_saldovencido1 + v_interesmoratorio1 + v_interesmoratorio2 + v_interesmoratorio3 + v_interesmoratorio4 + v_interesmoratorio5 + v_interesmoratorio6 + v_sdo_intereses;

					LET v_pago_vencido2_inicial = v_saldovencido2 + v_saldovencido1 + v_interesmoratorio1 + v_interesmoratorio2 + v_interesmoratorio3 + v_interesmoratorio4 + v_interesmoratorio5 + v_interesmoratorio6 + v_sdo_intereses;

					LET v_pago_vencido3_inicial = v_saldovencido3 + v_saldovencido2 + v_saldovencido1 + v_interesmoratorio1 + v_interesmoratorio2 + v_interesmoratorio3 + v_interesmoratorio4 + v_interesmoratorio5 + v_interesmoratorio6 + v_sdo_intereses;

					LET v_pago_vencido4_inicial = v_saldovencido6 + v_saldovencido5 + v_saldovencido4 + v_saldovencido3 + v_saldovencido2 + v_saldovencido1 + v_interesmoratorio1 + v_interesmoratorio2 + v_interesmoratorio3 + v_interesmoratorio4 + v_interesmoratorio5 + v_interesmoratorio6 + v_sdo_intereses;

					BEGIN WORK;
						UPDATE "informix".cb_cat_directorio_cte
						SET saldo_vencido_inicial = v_saldo_vencido_inicial, saldo_total_inicial = v_saldo_total_inicial,
							monto_ult_pago = v_monto_ult_pago_periodo, fecha_ult_pago = v_fecha_ultimo_pago,
							dias_mora = v_dias_atraso, pago_vencido1_inicial = v_pago_vencido1_inicial,
							pago_vencido2_inicial = v_pago_vencido2_inicial, pago_vencido3_inicial = v_pago_vencido3_inicial,
							pago_vencido4_inicial = v_pago_vencido4_inicial
						WHERE num_credito = v_num_credito
						AND fecha_insert = v_fecha_insert;
						
					COMMIT WORK;
				END IF;

				--IF (v_fecha_ultimo_pago = TODAY - 1 UNITS DAY) THEN
				IF (v_fecha_ultimo_pago = vFecha_hoy_sys - 1 UNITS DAY) THEN
					SELECT pagos_realizados
					INTO v_pagos_realizados
					FROM "informix".cb_cat_directorio_cte
					WHERE num_credito = v_num_credito
					AND fecha_insert = v_fecha_insert;

					IF v_pagos_realizados IS NULL THEN LET v_pagos_realizados = 0; END IF;

					IF v_monto_ult_pago_periodo IS NULL THEN LET v_monto_ult_pago_periodo = 0; END IF;

					LET v_pagos_realizados = v_pagos_realizados + v_monto_ult_pago_periodo;

					BEGIN WORK;
						UPDATE "informix".cb_cat_directorio_cte
						SET pagos_realizados = v_pagos_realizados
						WHERE num_credito = v_num_credito
						AND fecha_insert = v_fecha_insert;

					COMMIT WORK;
				END IF;

				LET v_pago_vencido1_final = v_saldovencido1 + v_interesmoratorio1 + v_interesmoratorio2 + v_interesmoratorio3 + v_interesmoratorio4 + v_interesmoratorio5 + v_interesmoratorio6 + v_sdo_intereses;

				LET v_pago_vencido2_final = v_saldovencido2 + v_saldovencido1 + v_interesmoratorio1 + v_interesmoratorio2 + v_interesmoratorio3 + v_interesmoratorio4 + v_interesmoratorio5 + v_interesmoratorio6 + v_sdo_intereses;

				LET v_pago_vencido3_final = v_saldovencido3 + v_saldovencido2 + v_saldovencido1 + v_interesmoratorio1 + v_interesmoratorio2 + v_interesmoratorio3 + v_interesmoratorio4 + v_interesmoratorio5 + v_interesmoratorio6 + v_sdo_intereses;

				LET v_pago_vencido4_final = v_saldovencido6 + v_saldovencido5 + v_saldovencido4 + v_saldovencido3 + v_saldovencido2 + v_saldovencido1 + v_interesmoratorio1 + v_interesmoratorio2 + v_interesmoratorio3 + v_interesmoratorio4 + v_interesmoratorio5 + v_interesmoratorio6 + v_sdo_intereses;

				BEGIN WORK;
					UPDATE "informix".cb_cat_directorio_cte
					SET --status_cliente = v_status_cliente, tipo_movto = v_tipo_movto,
						--fecha_modificacion = v_fecha_modificacion,
						saldo_vencido_final = v_saldo_vencido_final, saldo_total_final = v_saldo_total_final,
						pago_vencido1_final = v_pago_vencido1_final, pago_vencido2_final = v_pago_vencido2_final,
						pago_vencido3_final = v_pago_vencido3_final, pago_vencido4_final = v_pago_vencido4_final
					WHERE num_credito = v_num_credito
					AND fecha_insert = v_fecha_insert;

				COMMIT WORK;
			END FOREACH;
		END FOREACH;

		ELSE  --AC TIPO R

			FOREACH WITH HOLD
				SELECT DISTINCT(canal) INTO c_canal
					FROM bdicobranza:cb_cat_directorio_cte
					WHERE empresa = vEmpresa
					AND tipo_cobranza = ptipo_cobranza
					AND num_producto in ("6300","7600","7700","6800","6011")
					AND fecha_insert >= (TODAY - 1 UNITS MONTH)
					AND fecha_insert <= TODAY

				FOREACH WITH HOLD
					SELECT fecha_insert, num_credito, status_cliente, tipo_movto, fecha_modificacion
					INTO v_fecha_insert, v_num_credito, v_status_cliente, v_tipo_movto, v_fecha_modificacion
					FROM "informix".cb_cat_directorio_cte
					WHERE empresa = vEmpresa
					AND tipo_cobranza = ptipo_cobranza
					AND num_producto IN ("6300","7600","7700","6800","6011")
					AND fecha_insert >= (TODAY - 1 UNITS MONTH)
					AND fecha_insert <= TODAY
					AND canal = c_canal

					SELECT monto_ultimo_pago, fecha_ultimo_pago, dias_atraso
						INTO v_monto_ult_pago_periodo, v_fecha_ultimo_pago, v_dias_atraso
					FROM bdicred:"informix".sd_indicador_cred_crd
					WHERE empresa = "001"
					AND num_credito = v_num_credito;

					SELECT mto_venc_trasp+monto_vencido, sdo_cap_insoluto, saldovencido1, saldovencido2, saldovencido3,
							saldovencido4, saldovencido5, saldovencido6, interesmoratorio1, interesmoratorio2,
							interesmoratorio3, interesmoratorio4, interesmoratorio5, interesmoratorio6, sdo_intereses
						INTO v_saldo_vencido_inicial, v_saldo_total_inicial, v_saldovencido1, v_saldovencido2, v_saldovencido3,
							v_saldovencido4, v_saldovencido5, v_saldovencido6, v_interesmoratorio1, v_interesmoratorio2,
							v_interesmoratorio3, v_interesmoratorio4, v_interesmoratorio5, v_interesmoratorio6, v_sdo_intereses 
					FROM bdicred:"informix".sd_sdos_cartera_linea
					WHERE num_credito = v_num_credito;

					IF v_monto_ult_pago_periodo IS NULL THEN LET v_monto_ult_pago_periodo = 0; END IF;
					IF v_dias_atraso IS NULL THEN LET v_dias_atraso = 0; END IF;
					IF v_saldo_vencido_inicial IS NULL THEN LET v_saldo_vencido_inicial = 0; END IF;
					IF v_saldo_total_inicial IS NULL THEN LET v_saldo_total_inicial = 0; END IF;
					IF v_saldovencido1 IS NULL THEN LET v_saldovencido1 = 0; END IF;
					IF v_saldovencido2 IS NULL THEN LET v_saldovencido2 = 0; END IF;
					IF v_saldovencido3 IS NULL THEN LET v_saldovencido3 = 0; END IF;
					IF v_saldovencido4 IS NULL THEN LET v_saldovencido4 = 0; END IF;
					IF v_saldovencido5 IS NULL THEN LET v_saldovencido5 = 0; END IF;
					IF v_saldovencido6 IS NULL THEN LET v_saldovencido6 = 0; END IF;
					IF v_interesmoratorio1 IS NULL THEN LET v_interesmoratorio1 = 0; END IF;
					IF v_interesmoratorio2 IS NULL THEN LET v_interesmoratorio2 = 0; END IF;
					IF v_interesmoratorio3 IS NULL THEN LET v_interesmoratorio3 = 0; END IF;
					IF v_interesmoratorio4 IS NULL THEN LET v_interesmoratorio4 = 0; END IF;
					IF v_interesmoratorio5 IS NULL THEN LET v_interesmoratorio5 = 0; END IF;
					IF v_interesmoratorio6 IS NULL THEN LET v_interesmoratorio6 = 0; END IF;
					IF v_sdo_intereses IS NULL THEN LET v_sdo_intereses = 0; END IF;

					LET v_saldo_vencido_final = v_saldo_vencido_inicial; LET v_saldo_total_final = v_saldo_total_inicial;

					--IF v_fecha_insert = TODAY THEN
					IF v_fecha_insert = vFecha_hoy_sys THEN
						LET v_pago_vencido1_inicial = v_saldovencido1 + v_interesmoratorio1 + v_interesmoratorio2 + v_interesmoratorio3 + v_interesmoratorio4 + v_interesmoratorio5 + v_interesmoratorio6 + v_sdo_intereses;

						LET v_pago_vencido2_inicial = v_saldovencido2 + v_saldovencido1 + v_interesmoratorio1 + v_interesmoratorio2 + v_interesmoratorio3 + v_interesmoratorio4 + v_interesmoratorio5 + v_interesmoratorio6 + v_sdo_intereses;

						LET v_pago_vencido3_inicial = v_saldovencido3 + v_saldovencido2 + v_saldovencido1 + v_interesmoratorio1 + v_interesmoratorio2 + v_interesmoratorio3 + v_interesmoratorio4 + v_interesmoratorio5 + v_interesmoratorio6 + v_sdo_intereses;

						LET v_pago_vencido4_inicial = v_saldovencido6 + v_saldovencido5 + v_saldovencido4 + v_saldovencido3 + v_saldovencido2 + v_saldovencido1 + v_interesmoratorio1 + v_interesmoratorio2 + v_interesmoratorio3 + v_interesmoratorio4 + v_interesmoratorio5 + v_interesmoratorio6 + v_sdo_intereses;

						BEGIN WORK;
							UPDATE "informix".cb_cat_directorio_cte
							SET saldo_vencido_inicial = v_saldo_vencido_inicial, saldo_total_inicial = v_saldo_total_inicial,
								monto_ult_pago = v_monto_ult_pago_periodo, fecha_ult_pago = v_fecha_ultimo_pago,
								dias_mora = v_dias_atraso, pago_vencido1_inicial = v_pago_vencido1_inicial,
								pago_vencido2_inicial = v_pago_vencido2_inicial, pago_vencido3_inicial = v_pago_vencido3_inicial,
								pago_vencido4_inicial = v_pago_vencido4_inicial
							WHERE num_credito = v_num_credito
							AND fecha_insert = v_fecha_insert;

						COMMIT WORK;
					END IF;

					--IF (v_fecha_ultimo_pago = TODAY - 1 UNITS DAY) THEN
					IF (v_fecha_ultimo_pago = vFecha_hoy_sys - 1 UNITS DAY) THEN
						SELECT pagos_realizados
						INTO v_pagos_realizados
						FROM "informix".cb_cat_directorio_cte
						WHERE num_credito = v_num_credito
						AND fecha_insert = v_fecha_insert;

						IF v_pagos_realizados IS NULL THEN LET v_pagos_realizados = 0; END IF;

						IF v_monto_ult_pago_periodo IS NULL THEN LET v_monto_ult_pago_periodo = 0; END IF;

						LET v_pagos_realizados = v_pagos_realizados + v_monto_ult_pago_periodo;

						BEGIN WORK;
							UPDATE "informix".cb_cat_directorio_cte
							SET pagos_realizados = v_pagos_realizados
							WHERE num_credito = v_num_credito
							AND fecha_insert = v_fecha_insert;
							--AND f_vigencia = "1";
						COMMIT WORK;
					END IF;

					LET v_pago_vencido1_final = v_saldovencido1 + v_interesmoratorio1 + v_interesmoratorio2 + v_interesmoratorio3 + v_interesmoratorio4 + v_interesmoratorio5 + v_interesmoratorio6 + v_sdo_intereses;

					LET v_pago_vencido2_final = v_saldovencido2 + v_saldovencido1 + v_interesmoratorio1 + v_interesmoratorio2 + v_interesmoratorio3 + v_interesmoratorio4 + v_interesmoratorio5 + v_interesmoratorio6 + v_sdo_intereses;

					LET v_pago_vencido3_final = v_saldovencido3 + v_saldovencido2 + v_saldovencido1 + v_interesmoratorio1 + v_interesmoratorio2 + v_interesmoratorio3 + v_interesmoratorio4 + v_interesmoratorio5 + v_interesmoratorio6 + v_sdo_intereses;

					LET v_pago_vencido4_final = v_saldovencido6 + v_saldovencido5 + v_saldovencido4 + v_saldovencido3 + v_saldovencido2 + v_saldovencido1 + v_interesmoratorio1 + v_interesmoratorio2 + v_interesmoratorio3 + v_interesmoratorio4 + v_interesmoratorio5 + v_interesmoratorio6 + v_sdo_intereses;

					BEGIN WORK;
						UPDATE "informix".cb_cat_directorio_cte
						SET --status_cliente = v_status_cliente, tipo_movto = v_tipo_movto,
							--fecha_modificacion = v_fecha_modificacion,
							saldo_vencido_final = v_saldo_vencido_final, saldo_total_final = v_saldo_total_final,
							pago_vencido1_final = v_pago_vencido1_final, pago_vencido2_final = v_pago_vencido2_final,
							pago_vencido3_final = v_pago_vencido3_final, pago_vencido4_final = v_pago_vencido4_final
						WHERE num_credito = v_num_credito
						AND fecha_insert = v_fecha_insert;

					COMMIT WORK;
				END FOREACH;
			END FOREACH;	
		END IF;

	
	END IF;	
	
	CALL "informix".sp_inserta_bitacora_cob("001", cProceso, cCodRet, "FIN PROCESO "||paccion||" PARA TIPO COBRANZA "||ptipo_cobranza||"", '02') RETURNING P_COD_RET;

	IF P_COD_RET != '000000' THEN
		LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
		RETURN P_COD_RET,P_MENSAJE;
	END IF;

	RETURN cCodRet,P_MENSAJE;
END;
END PROCEDURE;