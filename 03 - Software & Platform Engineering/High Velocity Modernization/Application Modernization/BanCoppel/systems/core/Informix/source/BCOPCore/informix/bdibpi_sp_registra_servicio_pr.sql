CREATE PROCEDURE "informix".sp_registra_servicio_pr( pProceso CHAR(1),
															pIdUsuario INTEGER,
															pNumCliente CHAR(20), 
															pNumCelular CHAR(10),
															pNumCuenta CHAR(11),
															pContrasenia CHAR(50),
															pAlias CHAR(80),
															pImei CHAR(50),
															pMac CHAR(50),
															pFolioAct CHAR(12),
															pIdsesion CHAR(200))
   returning CHAR(5),CHAR(150),CHAR(100),CHAR(100),INTEGER;


    DEFINE sql_err INTEGER ;
    DEFINE cod_ret CHAR(5);
	DEFINE cBin CHAR(100);
	DEFINE cPrefBan CHAR(100);
	DEFINE iIdUsuario INTEGER;
	DEFINE cGen1 CHAR(100);
	DEFINE cGen2 CHAR(100);
	DEFINE cAlias CHAR(80);
	DEFINE cNumCuenta CHAR(11);
	DEFINE cNumCliente CHAR(20);
	DEFINE mSaldoCuenta DECIMAL(16,2);
	DEFINE cMensajeRet CHAR(150);
	DEFINE cIdSesion CHAR(200);
	DEFINE cCuentaValNum CHAR(20);
	DEFINE cNumCelValNum CHAR(10);
	DEFINE cEsTransfer CHAR(1);
	DEFINE bFlagRegistro CHAR(1);
	DEFINE cEstatus CHAR(1);
	DEFINE iRegistroCuenta INTEGER;
	DEFINE iRegistroCliente INTEGER;
	
	LET cod_ret  = '00000';
	LET cBin='';
	LET cPrefBan='';
	LET iIdUsuario=0;
	LET cGen1='';
	LET cGen2='';
	LET cMensajeRet='';
	LET cIdSesion='';
	LET cCuentaValNum='';
	LET cNumCelValNum='';
	LET cEsTransfer='';
	LET bFlagRegistro='F';
	LET cEstatus = 'A';
	LET iRegistroCuenta = 0;
	LET iRegistroCliente = 0;
	
  --SET DEBUG FILE TO "/tmp/sp_registra_servicio_pr.out";
  --TRACE ON;
BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret,cMensajeRet,cGen1,cGen2,iIdUsuario;
      END IF;
   END EXCEPTION;
   
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	--Si es un registro, se valida que contenga todos los datos.
	IF pProceso = '0' OR pProceso = '2' THEN
		IF(NVL(pProceso,'')='' OR NVL(pNumCelular,'')='' OR NVL(pNumCliente,'') = '' OR NVL(pNumCuenta, '') = '') THEN
			LET cod_ret = '00001';
			RETURN TRIM(NVL(cod_ret, '')),TRIM(NVL(cMensajeRet, '')),TRIM(NVL(cGen1,'')),TRIM(NVL(cGen2,'')),TRIM(NVL(iIdUsuario,''));
		END IF;
	END IF;
	
	-- Si es una actualizacion se valida solamente el numero de celular.
	If pProceso = '1' THEN
		IF(NVL(pProceso,'')='' OR NVL(pNumCelular,'')='')THEN
			LET cod_ret = '00001';
			RETURN cod_ret,cMensajeRet,cGen1,cGen2,iIdUsuario;
		END IF;
	END IF;
	
	
	--------------------------
	-- Registro de Servicio --
	--------------------------
	IF pProceso='0' THEN -- REGISTRO (Sucursal = 0, App = 2).
		
		--Si es PreRegistro, se asegura que la contrasena, imei y mac esten vacias y se marca el status como "I".
		IF pProceso='0' THEN
			LET pContrasenia = '';
			LET pImei = '';
			LET pMac = '';
			LET cEstatus = 'I';	
		END IF;
		
		-- Cuando el registro es realizado por App Pago Rayo, se cancela el servicio anterior.
		EXECUTE PROCEDURE sp_cancelaservicio_suc_pr(pNumCelular) INTO cod_ret;

		IF (cod_ret <> '00000') THEN
			-- Por el momento, no se emite mensaje de error. Sino que continua
			LET cod_ret = '00000';
		END IF;			

		-- Se revisa si ya esta registrado por cuenta o cliente.
		SELECT FIRST 1 1
		INTO iRegistroCuenta
		FROM bdibpi:"informix".pr_registro_app 
		WHERE num_cliente=pNumCliente AND (cuenta=pNumCuenta OR celular=pNumCelular);
		
		SELECT FIRST 1 1 
		INTO iRegistroCliente
		FROM bdibpi:"informix".pr_registro_app 
		WHERE num_cliente!=NVL(pNumCliente,'') AND celular=NVL(pNumCelular,'');
		
		-- Si no esta registrado se inserta en la tabla pr_registro_app. En caso contrario se envia mensaje de error.
		IF NVL(iRegistroCuenta, 0) = 0 THEN
			IF NVL(iRegistroCliente, 0) = 0 THEN
			
				INSERT INTO bdibpi:"informix".pr_registro_app(num_cliente,celular,cuenta,contrasenia,alias,imei,mac,folio_activacion,estatus_servicio,fecha_reg,fecha_mod)
				VALUES(pNumCliente, pNumCelular,pNumCuenta, pContrasenia, pAlias, pImei, pMac,pFolioAct, cEstatus, CURRENT, CURRENT);
					
				SELECT id_usuario 
				INTO iIdUsuario
				FROM bdibpi:"informix".pr_registro_app 
				WHERE num_cliente=pNumCliente AND celular=pNumCelular AND cuenta=pNumCuenta;
				
				SELECT valor 
				INTO cBin
				FROM bdibpi:"informix".pr_param_mensajes 
				WHERE id_param='001' AND tipo_param='1';
				
				SELECT valor 
				INTO cPrefBan
				FROM bdibpi:"informix".pr_param_mensajes 
				WHERE id_param='002' AND tipo_param='1';
				
				LET cGen1=cBin;
				LET cGen2=cPrefBan;
			ELSE

				LET cod_ret = '00004';
			END IF;
				
		ELSE
			LET cod_ret = '00002';
			SELECT valor 
			INTO cMensajeRet
			FROM bdibpi:"informix".pr_param_mensajes 
			WHERE id_param='007' AND tipo_param='2';
		END IF;
	
	END IF;   
	
	-------------------------------------------------------------------------------------------------
	-- Confirmacion de Registro desde la App. ( 1 = Registro de Sucursal. 2 = Registro desde App ) --
	-------------------------------------------------------------------------------------------------
	IF pProceso='1' OR pProceso = '2' THEN  
		
		--Se obtiene la sesion
		SELECT id_sesion 
		INTO cIdSesion
		FROM bdibpi:"informix".pr_sesiones_activas WHERE id_sesion=pIdsesion;
		
		--Se valida la sesion
		IF NVL(cIdSesion,'')<>''  THEN
			SELECT id_usuario,alias,cuenta,num_cliente 
			INTO iIdUsuario,cAlias,cNumCuenta,cNumCliente
			FROM bdibpi:"informix".pr_registro_app WHERE celular=pNumCelular AND id_usuario=pIdUsuario;
			IF (NVL(iIdUsuario,-1)>= 0) THEN
				
				--Consultar saldo cuenta
				SELECT sdo_actual 
				INTO mSaldoCuenta
				FROM bdicheq:"informix".sc_maechq where num_cte=cNumCliente AND cuenta=cNumCuenta AND status_cta='1';
				
				IF NVL(mSaldoCuenta,'')<>'' THEN
				
					-- Si el PreRegistro fue hecho en la App, se actualiza el Alias para que no quede vacio.
					IF pProceso = '2' THEN
						LET cAlias = pAlias;
					END IF;
					
					LET cGen2=mSaldoCuenta;
					LET cGen1=cAlias; 
					
					--Se actualiza la informacion
					UPDATE bdibpi:"informix".pr_registro_app 
					SET contrasenia=pContrasenia,imei=pImei,mac=pMac,estatus_servicio='A', alias = cAlias, fecha_ulti_acceso=current
					WHERE celular=pNumCelular AND id_usuario=pIdUsuario;
					
					SELECT valor 
					INTO cMensajeRet
					FROM bdibpi:"informix".pr_param_mensajes 
					WHERE id_param='003' AND tipo_param='2';
				ELSE
					LET cod_ret='00003';					SELECT valor 
					INTO cMensajeRet
					FROM bdibpi:"informix".pr_param_mensajes 
					WHERE id_param='007' AND tipo_param='2';
					
				END IF;
			ELSE
				LET cod_ret = '00002';				SELECT valor 
				INTO cMensajeRet
				FROM bdibpi:"informix".pr_param_mensajes 
				WHERE id_param='007' AND tipo_param='2';
				
			END IF;
		ELSE
			LET cod_ret='00002';
			SELECT valor 
			INTO cMensajeRet
			FROM bdibpi:"informix".pr_param_mensajes 
			WHERE id_param='008' AND tipo_param='2';
		END IF;
	END IF;   
	
	RETURN cod_ret,cMensajeRet,cGen1,cGen2,iIdUsuario;
   
END

END PROCEDURE
DOCUMENT
'FOLIO.........: 1549 - ProyectoRayo',
'AUTOR.........: Jose Ruben Lopez',
'FECHA.........: 19/05/2014',
'MODIFICACIÓN..: Se crea stored procedure, registra servicio pago rayo por sucursal y por la api de pago rayo',
'SOLICITA......: Jesus Montoya',
'BD............: BDIBPI';

CREATE PROCEDURE "informix".reversion_tae(pEmpresa  CHAR(3), pId_Sucursal CHAR (4),   pUsuario  CHAR(8), pFolioSucursal CHAR (16),  pTiporev  CHAR(1), pNumCategoria  CHAR(2), pNumConvenio   CHAR(3),   pFechaPago     DATE,   pReferencia CHAR (27), pNumTrama      INTEGER,pCadena_Req    CHAR (1620),   pCadena_Rply   CHAR (1620))
    RETURNING CHAR(5);
  
    --DESCRIPCION: Se crea spl nuevo para realizar el reverso del cobro y abono realizados de la compra de tiempo aire así
    --             como el registro en tablas del sistema si la respuesta de la conexión a Interactué no es exitosa
    --AUTOR: SOLSER SISTEM S.A. DE C.V
    --FECHA: 03/10/2019
    --VERSION: 20191003.0001
    --BD: bdibpi
    --SUSTENTO: Se definio en el Requerimiento: RQI 03 767 Compra Tiempo Aire Portal BanCoppel.doc
    --SOLICITO: Arturo Alejandro Vazquez Fernandez

    --DECLARA VARIABLES
    DEFINE   vempresa  CHAR(3);
    DEFINE   vidSucursal CHAR (4);
    DEFINE   vusuario  CHAR(8);
    DEFINE   vfolioSucursal CHAR (16);
    DEFINE   vtipoRev  CHAR(1);
    DEFINE   vfechaPago  DATE;
    DEFINE   vnumTrama       INTEGER;
    DEFINE   vcadenaReq  CHAR (1620);
    DEFINE   vcadenaRply     CHAR (1620);
    DEFINE   vnumCategoria  CHAR(2);
    DEFINE   vnumConvenio    CHAR(3);
    DEFINE   vReferencia CHAR (27);
    DEFINE   vcodigoRespuesta CHAR(40);
    DEFINE   vconceptoRespuesta CHAR(80);
    DEFINE   venviaTrama INTEGER;
    DEFINE   vreversa CHAR (1); 
    DEFINE   vcodErr CHAR (4);
    DEFINE   vcodErr_reversa CHAR (4);
    DEFINE   vencErrores CHAR(80);
    DEFINE   cod_ret              CHAR(5);
 
    --INICIA VARIABLES
    LET vempresa              ='';
    LET vidSucursal           ='';
    LET vusuario              ='';
    LET vfolioSucursal        ='';
    LET vtipoRev              ='';
    LET vfechaPago            ='';
    LET vnumTrama             = 0;
    LET vcadenaReq            ='';
    LET vcadenaRply           ='';
    LET vnumCategoria         ='';
    LET vnumConvenio          ='';
    LET vReferencia           ='';
    LET vcodigoRespuesta      ='';
    LET vconceptoRespuesta    ='';
    LET venviaTrama           = 0;
    LET vreversa              ='';
    LET vcodErr               ='';
    LET vcodErr_reversa       ='';
    LET vencErrores           ='';
    LET cod_ret               ='00000';
	
	
	
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
		
		
		
		
	
	--	SET DEBUG FILE TO '/informix/gaby/ArchivosOut/reversion_tae.out';
	--	TRACE ON;
    
    BEGIN
         LET vempresa             =  pEmpresa;
         LET vidSucursal          =  pId_Sucursal;
         LET vusuario             =  pUsuario;
         LET vfolioSucursal       =  pFolioSucursal;
         LET vtipoRev             =  pTiporev;
         LET vfechaPago           =  pFechaPago;
         LET vnumTrama            =  pNumTrama;
         LET vcadenaReq           =  pCadena_Req;
         LET vcadenaRply          =  pCadena_Rply;
         LET vnumCategoria        =  pNumCategoria;
         LET vnumConvenio         =  pNumConvenio;
         LET vReferencia          =  pReferencia;

        CALL bdicheq:"informix".reversion( vempresa, vidSucursal, vusuario, vfolioSucursal, vtipoRev)
            RETURNING cod_ret;
        
        IF ( cod_ret is null OR cod_ret <> '000' ) THEN
            RETURN cod_ret;
        END IF;


        CALL bdisac:"informix".sp_inserta_msw_respuesta(vnumCategoria, vnumConvenio, vidSucursal, vfolioSucursal, vfechaPago, vnumTrama, vcadenaReq, vcadenaRply)
            RETURNING cod_ret, vcodigoRespuesta;
        
        IF ( cod_ret is null OR cod_ret <> '00000' ) THEN
            RETURN cod_ret;
        END IF;

        CALL bdisac:"informix".sp_obtiene_tae_catrespws(vcodigoRespuesta, vnumTrama)
            RETURNING cod_ret, vconceptoRespuesta;
        
        IF ( cod_ret is null OR cod_ret <> '00000' ) THEN
            RETURN cod_ret;
        END IF;

        CALL bdisac:"informix".sp_bitacorawstae(vnumCategoria, vnumConvenio, vidSucursal, vfolioSucursal, vfechaPago, vcodigoRespuesta, vconceptoRespuesta, vReferencia, vnumTrama)
            RETURNING cod_ret;

        IF ( cod_ret is null OR cod_ret <> '00000' ) THEN
            RETURN cod_ret;
        END IF;

        CALL bdisac:"informix".sp_obtiene_msw_validacion(vcodigoRespuesta, vnumCategoria, vnumConvenio, vnumTrama)
            RETURNING cod_ret, venviaTrama, vreversa, vcodErr, vcodErr_reversa, vencErrores;
        
        IF ( cod_ret is null OR cod_ret <> '00000' ) THEN
            RETURN cod_ret;
        END IF;

    END;

       RETURN cod_ret;
END PROCEDURE;