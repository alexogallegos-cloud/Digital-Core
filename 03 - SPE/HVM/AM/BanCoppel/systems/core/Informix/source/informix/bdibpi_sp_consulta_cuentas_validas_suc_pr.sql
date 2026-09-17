CREATE PROCEDURE "informix".sp_consulta_cuentas_validas_suc_pr(pProceso CHAR(1),
										 pEmpresa CHAR(3), pTarjeta CHAR (20),
                                         pNum_cte CHAR(20), pCuenta CHAR(20),
                                         pRegistro SMALLINT )
RETURNING CHAR(5), CHAR(20), CHAR(20), CHAR(120), CHAR(13), CHAR(10), CHAR(80), CHAR(10), CHAR(143);

    -- ***************************************************************************
    -- Define variables
    -- ***************************************************************************
    DEFINE cod_ret       CHAR(5);
    DEFINE v_cuenta      CHAR(20);
    DEFINE v_numtarjeta  CHAR(20);
    DEFINE sql_err       INTEGER;
	DEFINE cCuentaValNum CHAR(20);
	DEFINE cNumCelValNum CHAR(10);
	DEFINE cEsTransfer CHAR(1);
	DEFINE cNumCliente CHAR(10);
	DEFINE cNumCliente2 CHAR(10);
	DEFINE cDescripcion	CHAR(40);
	DEFINE cEstado		CHAR(1);
	DEFINE cTelefono	CHAR(13);
	DEFINE cAlias		CHAR(80);
	DEFINE cNomComp		CHAR(143);
	DEFINE cIdUsuario   CHAR(11);
    -- ***************************************************************************
    -- Inicializa variables
    -- ***************************************************************************
    LET cod_ret       = "00100";
    LET v_cuenta      = " ";
    LET v_numtarjeta  = "0000000000000000";
	LET cCuentaValNum='';
	LET cNumCelValNum='';
	LET cEsTransfer='';
	LET cNumCliente='';
	LET cNumCliente2='';	LET	cDescripcion = ''; 
	LET cEstado = '';
	LET	cTelefono = '';
	LET cAlias = '';	
	LET cNomComp = '';	
	LET cIdUsuario  = '';
	LET sql_err = 0;
    --SET DEBUG FILE TO "sp_consulta_cuentas_validas_pr.out";
    --TRACE ON;	
	/*
			CODRET 					DESCRIPCIÓN 
			00004					No es una cuenta.
			00001					No se  encontró cuenta.
			00003					Tiene Servicio transfer.
			00100					Parametros no validos.
			00101					El cliente no tiene cuentas de Captación.	
			00006					Tiene servicio SPEI 
	        00007					no se encontro registro consulta inicial(cliente)
			
			Tipos de estados.
			I = Cuenta con servicio Inactivo.
			A = Cuenta con servicio Activo.
			E = El servicio se encuentra Activo con diferente cuenta. 
			'' = No Tiene servicio.			
	*/
    BEGIN
    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN NVL(cod_ret,''), TRIM(NVL(v_cuenta,'')), TRIM(NVL(v_numtarjeta,'')), TRIM(NVL(cDescripcion,'')), TRIM(NVL(cTelefono,'')), TRIM(NVL(cEstado,'')),TRIM(NVL(cAlias,'')), TRIM(NVL(cNumCliente, '')), TRIM(NVL(cNomComp,''));
        END IF
    END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF (NVL(pProceso, '') <> '' AND (pProceso > '0' AND pProceso < '4' )) THEN 
		IF pProceso= '2' THEN		
			IF (  NVL(pTarjeta, '' ) <> ''OR NVL(pEmpresa,'') = '' ) THEN
			
				SELECT tar.cuenta, tar.numcte, prod.nombre
				INTO v_cuenta,cNumCliente, cDescripcion
				FROM bdicheq:"informix".sc_tarjeta tar, bdicheq:"informix".sc_producto prod
				WHERE tar.empresa = pEmpresa AND tar. num_tarjeta = TRIM(pTarjeta)
				AND tar.empresa = prod.empresa 
				AND tar.prodtarjeta = prod.producto ; 
				
				IF DBINFO('SQLCA.SQLERRD2') = 0 THEN
					LET cod_ret = '00007';		
				END IF;
				
				LET v_numtarjeta = pTarjeta; 
				
			END IF;	
		ELIF pProceso= '3' THEN
			IF (NVL(pCuenta, '') <> '') THEN
			   
			    SELECT mae.num_cte, prod.nombre
			    INTO cNumCliente, cDescripcion
			    FROM bdicheq:"informix".sc_maechq mae, bdicheq:"informix".sc_producto prod
			    WHERE mae.cuenta = pCuenta AND mae.producto = prod.producto  
				AND mae.status_cta NOT IN('2','6','7');
				   
				IF DBINFO('SQLCA.SQLERRD2') = 0 THEN
					LET cod_ret = '00007';		
				END IF;
				
				LET v_cuenta = pCuenta;
				
			END IF;
		ELSE 
			
			SELECT numcte
			INTO cNumCliente
			FROM bdinteg:"informix".si_cliente 
			WHERE empresa = pEmpresa
			AND numcte = pNum_cte;
			
			IF DBINFO('SQLCA.SQLERRD2') = 0 THEN
				LET cod_ret = '00007';		
			END IF;
			
			LET cNumCliente = pNum_cte;
			
		END IF;	
					
		--- REGRESA EL NUMERO DE TELEFONO 		
		IF cod_ret  = '00100'  THEN
		
			SELECT telefono
			INTO cTelefono
			FROM bdinteg:"informix".si_telefonos	 
			WHERE numcte = cNumCliente 
			AND status_tel= 'A' 
			AND tipo_tel= 2;
			
				SELECT num_cliente
				INTO cNumCliente2
				FROM bdibpi: "informix".pr_registro_app
				WHERE celular = cTelefono AND num_cliente != cNumCliente ;
				
				IF DBINFO('SQLCA.SQLERRD2') = 0  THEN
				
					SELECT cuenta,telefono,es_transfer 
					INTO cCuentaValNum,cNumCelValNum,cEsTransfer
					FROM bdicheq:"informix".sc_cuenta_telefono 
					WHERE telefono = cTelefono AND num_cte != cNumCliente;
					
					IF DBINFO('SQLCA.SQLERRD2') = 0  THEN
					
					--EL NOMBRE DEL CLIENTE
						SELECT TRIM(NVL(nombre1," ")) || " " || TRIM(NVL(nombre2," ")) || " " || 
							   TRIM(NVL(apell_paterno," ")) || " " || TRIM(NVL(apell_materno,' ')) || " " ||TRIM(NVL(razon_social, " ")) 
						INTO cNomComp
						FROM bdinteg:"informix".si_cliente
						wHERE numcte = cNumCliente;	
							
							FOREACH
								SELECT {INDEX+(bdicheq:"informix".sc_maechq maecheques)} SKIP pRegistro  FIRST 10 mae.cuenta,'0000000000000000',prod.nombre
									INTO v_cuenta, v_numtarjeta,cDescripcion
									FROM bdicheq:"informix".sc_maechq mae, bdicheq:"informix".sc_producto prod 
									WHERE mae.num_cte = cNumCliente 
									AND mae.producto = prod.producto
									AND mae.producto IN ('2000', '1900', '1800','1300')
									AND mae.status_cta NOT IN('2','6','7')
									AND mae.cuenta = (CASE WHEN v_cuenta <>'' THEN v_cuenta ELSE mae.cuenta END) --en caso de que tenga cuenta se filtra por esta
									ORDER BY mae.cuenta
									
								IF DBINFO('SQLCA.SQLERRD2') =  0 THEN
								ELSE 				
									SELECT num_cliente, id_usuario
									INTO cNumCliente2, cIdUsuario
									FROM bdibpi: "informix".pr_registro_app
									WHERE num_cliente = cNumCliente;
									
									IF DBINFO('SQLCA.SQLERRD2') <> 0 THEN
										SELECT num_cliente,estatus_servicio, alias
										INTO cNumCliente2,cEstado, cAlias
										FROM bdibpi: "informix".pr_registro_app
										WHERE cuenta = v_cuenta AND celular = cTelefono AND id_usuario = cIdUsuario;	
										
										IF DBINFO('SQLCA.SQLERRD2') =  0 THEN							
											IF pProceso <> '1' THEN 
												LET cEstado = 'E';
												SELECT alias
												INTO cAlias
												FROM bdibpi: "informix".pr_registro_app
												WHERE num_cliente = cNumCliente; 
											END IF;
										END IF;
									END IF;
									
									LET cod_ret = '00000';
								END IF;			
								RETURN NVL(cod_ret,''), TRIM(NVL(v_cuenta,'')), TRIM(NVL(v_numtarjeta,'')), TRIM(NVL(cDescripcion,'')), TRIM(NVL(cTelefono,'')), TRIM(NVL(cEstado,'')),TRIM(NVL(cAlias,'')), TRIM(NVL(cNumCliente, '')), TRIM(NVL(cNomComp,'')) WITH RESUME;
							    LET cEstado = '';
							    LET cAlias = '';
							    LET cDescripcion = '';
							END FOREACH;
							
							IF DBINFO('SQLCA.SQLERRD2') =  0 THEN
								LET cod_ret = '00004';
							END IF;
					ELSE 
						LET cod_ret = '00005';
					END IF;
				ELSE 
					LET cod_ret = '00005';
				END IF;
		END IF;

    END IF;
	IF cod_ret <> '00000' THEN 
		RETURN NVL(cod_ret,''), TRIM(NVL(v_cuenta,'')), TRIM(NVL(v_numtarjeta,'')), TRIM(NVL(cDescripcion,'')), TRIM(NVL(cTelefono,'')), TRIM(NVL(cEstado,'')),TRIM(NVL(cAlias,'')), TRIM(NVL(cNumCliente, '')), TRIM(NVL(cNomComp,''));
	END IF;
	
END
END PROCEDURE
DOCUMENT
'FOLIO.........: 1549 - ProyectoRayo',
'AUTOR.........: Jose Magdiel Martinez Lopez',
'FECHA.........: 31/07/2015',
'MODIFICACIÓN..: Se crea stored procedure espejo al sp bdicheq:consulta_cuentas_validas_pr agregando validaciones de cuentas asociadas a un numero celular',
'SOLICITA......: Jesus Montoya',
'BD............: BDIBPI',
'FOLIO.........: 1785-MejorasPagoRayo',
'AUTOR.........: Carolina Elizabeth Verdugo Gastélum',
'FECHA.........: 21/01/2016',
'MODIFICACIÓN..: Se modifica procedimiento para que regrese la descripción del producto, teléfono, estado, Alias, numCliente y nombre completo.',
'				  se agregan busqueda por cuenta, validacion si el servicio está solicitado, valida que no tenga servicio SPEI. ',
'SOLICITA......: Jesus Montoya',
'BD............: BDIBPI',
'FOLIO.........: 1794-MejorasPagoRayoII',
'AUTOR.........: Carolina Elizabeth Verdugo Gastélum',
'FECHA.........: 11/03/2016',
'MODIFICACIÓN..: Se modifica la consulta para que solo acepte los productos 2000, 1800, 1900,1300',
'SOLICITA......: Marcela Pérez',
'BD............: BDIBPI',
'FOLIO.........: 1794-MejorasPagoRayoII',
'AUTOR.........: Carolina Elizabeth Verdugo Gastélum',
'FECHA.........: 13/04/2016',
'MODIFICACIÓN..: Se modifica Procedimiento para que deje continuar aunque no hay número de celular registrado ',
'SOLICITA......: Marcela Pérez',
'BD............: BDIBPI',
'FOLIO.........: 1794-MejorasPagoRayoII',
'AUTOR.........: Carolina Elizabeth Verdugo Gastélum',
'FECHA.........: 22/04/2016',
'MODIFICACIÓN..: Se modifica retorno de código de error después del foreach para que retorno cuando no encuentre cuentas válidas. ',
'SOLICITA......: Marcela Pérez',
'BD............: BDIBPI',
'FOLIO.........: 1794-MejorasPagoRayoII',
'AUTOR.........: Felipe Urias',
'FECHA.........: 26/04/2016',
'MODIFICACIÓN..: se modifica el codigo de retorno de la primera consulta proceso 2 y 3, se agrega consulta a si_clientes para conprobar el numero de cliente. y',
'                se agrega validacion de codigo de retorno para las consultas de numero de cliente.',
'SOLICITA......: Marcela Pérez',
'BD............: BDIBPI';

CREATE PROCEDURE "informix".sp_valida_folio_pr( pFolio CHAR(12),
														pCodSeg CHAR(4),
														pIdSesion CHAR(200))
   returning CHAR(5),CHAR(150),CHAR(10),INTEGER;


    DEFINE sql_err INTEGER ;
    DEFINE cCod_ret CHAR(5);
	DEFINE iIdUsuario INTEGER;
	DEFINE cNumCelular  CHAR(10);
	DEFINE cFolioActivacion CHAR(12);
	DEFINE cEstatusServ CHAR(1);
	DEFINE cMensajeRet CHAR(150);
	DEFINE cCodRetLat CHAR(5);
	DEFINE cIdSesion CHAR(200);
	
	LET cCod_ret  = '00000';
	LET iIdUsuario=0;
	LET cNumCelular='';
	LET cFolioActivacion='';
	LET cEstatusServ='';
	LET cMensajeRet='';
	LET cIdSesion='';
	
 -- SET DEBUG FILE TO "/tmp/sp_valida_folio_pr.out";
  --TRACE ON;
BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cCod_ret = sql_err;
			SELECT valor 
			INTO cMensajeRet
			FROM bdibpi:"informix".pr_param_mensajes 
			WHERE id_param='007' AND tipo_param='2';
            RETURN cCod_ret,cMensajeRet,cNumCelular,iIdUsuario;
      END IF;
   END EXCEPTION;
   
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF( NVL(pFolio,'')=''OR NVL(pCodSeg,'')=''OR NVL(pIdSesion,'')='')THEN
		LET cCod_ret = '00009';
		   RETURN cCod_ret,cMensajeRet,cNumCelular,iIdUsuario;
	END IF;
	
	--VALIDA SESION PERMITIDA
	SELECT id_sesion 
	INTO cIdSesion
	FROM bdibpi:"informix".pr_sesiones_activas WHERE id_sesion=pIdsesion;
	
	IF NVL(cIdSesion,'')<>'' THEN
			SELECT folio_activacion,estatus_servicio,celular,id_usuario 
			INTO cFolioActivacion,cEstatusServ,cNumCelular,iIdUsuario
			FROM bdibpi:"informix".pr_registro_app WHERE folio_activacion=pFolio;
			IF NVL(cFolioActivacion,'')<>'' THEN
				IF NVL(cEstatusServ,'')='I' OR NVL(cEstatusServ,'')='A' THEN
					--SE MANDA A LLAMAR LATINIA PARA MANDAR CODIGO POR SMS SE UTILIZA LA PLANTILLA SMS_RAYO1
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','SMS_RAYO','SMS_RAYO3','000000000','','','1',pCodSeg,'','','','','','','','','','',cNumCelular,0,0,0,0,0,'','') 
					INTO cCodRetLat;
					IF cCodRetLat<>'00000' THEN
						LET cCod_ret='00003'; --ERROR EN LATINIA
						SELECT valor 
						INTO cMensajeRet
						FROM bdibpi:"informix".pr_param_mensajes 
						WHERE id_param='007' AND tipo_param='2';
					END IF;
				ELSE
					LET cCod_ret='00002';					SELECT valor 
					INTO cMensajeRet
					FROM bdibpi:"informix".pr_param_mensajes 
					WHERE id_param='002' AND tipo_param='2';
				END IF;
			ELSE
				LET cCod_ret='00001';				SELECT valor 
				INTO cMensajeRet
				FROM bdibpi:"informix".pr_param_mensajes 
				WHERE id_param='001' AND tipo_param='2';
			END IF;
    ELSE
		LET cCod_ret='00002';		SELECT valor 
		INTO cMensajeRet
		FROM bdibpi:"informix".pr_param_mensajes 
		WHERE id_param='008' AND tipo_param='2';
	END IF;
    RETURN cCod_ret,cMensajeRet,cNumCelular,iIdUsuario;
   
END

END PROCEDURE
DOCUMENT
'FOLIO.........: 1549 - ProyectoRayo',
'AUTOR.........: Jose Ruben Lopez',
'FECHA.........: 19/05/2014',
'MODIFICACIÓN..: Se crea stored procedure, valida folio de activacion para utilizar la app pago rayo',
'SOLICITA......: Jesus Montoya',
'BD............: BDIBPI';

CREATE PROCEDURE "informix".sp_registra_servicio_suc_pr( pProceso CHAR(1),
															pIdUsuario INTEGER,
															pNumCliente CHAR(20), 
															pNumCelular CHAR(10),
															pNumCuenta CHAR(11),
															pContrasenia CHAR(50),
															pAlias CHAR(80),
															pImei CHAR(17),
															pMac CHAR(17),
															pFolioAct CHAR(12),
															pIdsesion CHAR(200))
   RETURNING CHAR(5),CHAR(150),CHAR(100),CHAR(100),INTEGER;


    DEFINE sql_err INTEGER ;
    DEFINE cod_ret CHAR(5);
	DEFINE cBin CHAR(100);
	DEFINE cPrefBan CHAR(100);
	DEFINE iIdUsuario INTEGER;
	DEFINE cGen1 CHAR(100);
	DEFINE cGen2 CHAR(100);
	DEFINE cMensajeRet CHAR(150);
	DEFINE cCuentaValNum CHAR(20);
	DEFINE cNumCelValNum CHAR(10);
	DEFINE cEsTransfer CHAR(1);
	DEFINE bFlagRegistro CHAR(1);
	
	
	LET sql_err = 0;
	LET cod_ret  = '00000';
	LET cBin='';
	LET cPrefBan='';
	LET iIdUsuario=0;
	LET cGen1='';
	LET cGen2='';
	LET cMensajeRet='';
	LET cCuentaValNum='';
	LET cNumCelValNum='';
	LET cEsTransfer='';
	LET bFlagRegistro='F';


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
	
	IF(NVL(pProceso,'')='' OR NVL(pNumCelular,'')='' OR NVL(pNumCliente,'') = '' OR NVL(pNumCuenta, '') = '') THEN
		LET cod_ret = '00001';
		RETURN TRIM(NVL(cod_ret, '')),TRIM(NVL(cMensajeRet, '')),TRIM(NVL(cGen1,'')),TRIM(NVL(cGen2,'')),TRIM(NVL(iIdUsuario,''));
	END IF;
	
	
		IF pProceso='0' THEN -- REGISTRO POR PARTE DE SUCURSAL
			
			
			IF NOT EXISTS(SELECT id_usuario FROM bdibpi:"informix".pr_registro_app WHERE num_cliente=pNumCliente AND (cuenta=pNumCuenta OR celular=pNumCelular)) THEN
				  IF NOT EXISTS(SELECT id_usuario FROM bdibpi:"informix".pr_registro_app WHERE num_cliente!=NVL(pNumCliente,'') AND celular=NVL(pNumCelular,'')) THEN
					
					INSERT INTO bdibpi:"informix".pr_registro_app(num_cliente,celular,cuenta,contrasenia,alias,imei,mac,folio_activacion,estatus_servicio,fecha_reg,fecha_mod)
						
						VALUES(pNumCliente,
						pNumCelular,pNumCuenta,'',pAlias,'','',pFolioAct,'I',CURRENT,CURRENT);
						
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
	RETURN TRIM(NVL(cod_ret, '')),TRIM(NVL(cMensajeRet, '')),TRIM(NVL(cGen1,'')),TRIM(NVL(cGen2,'')),TRIM(NVL(iIdUsuario,''));
   
END

END PROCEDURE
DOCUMENT
'FOLIO.........: 1549 - ProyectoRayo',
'AUTOR.........: Jose Ruben Lopez',
'FECHA.........: 19/05/2014',
'MODIFICACIÓN..: Se crea stored procedure, registra servicio pago rayo por sucursal y por la api de pago rayo',
'SOLICITA......: Jesus Montoya',
'BD............: BDIBPI',
'FOLIO.........: 1785 - MejorasPagoRayo',
'AUTOR.........: Carolina Elizabeth Verdugo Gastélum',
'FECHA.........: 21/01/2016',
'MODIFICACIÓN..: Se modifica procedimiento para validar si ya esta dado de alta un número de celular',
'SOLICITA......: Jesus Montoya',
'BD............: BDIBPI',
'FOLIO.........: 1785 - MejorasPagoRayo',
'AUTOR.........: Carolina Elizabeth Verdugo Gastélum',
'FECHA.........: 26/02/2016',
'MODIFICACIÓN..: Se modifica procedimiento para validar si ya esta dado de alta un número de celular con otro servicio',
'BD............: BDIBPI';

CREATE PROCEDURE "informix".sp_inicia_sesion_pr( pContra CHAR(50),
														pNumCel CHAR(10),
														pImei CHAR(50),
														pMac CHAR(50),
														pIdSesion CHAR(200))
   returning CHAR(5),CHAR(150),CHAR(80),CHAR(80),CHAR(80),INTEGER;


    DEFINE sql_err INTEGER ;
    DEFINE cCod_ret CHAR(5);
	DEFINE iIdUsuario INTEGER;
	DEFINE cNumCelular  CHAR(10);
	DEFINE cAlias  CHAR(80);
	DEFINE cGen1 CHAR(80);
	DEFINE cGen2 CHAR(80);
	DEFINE cGen3 CHAR(80);
	DEFINE cFolioActivacion CHAR(12);
	DEFINE cEstatusServ CHAR(1);
	DEFINE cImei CHAR(50);
	DEFINE cMac CHAR(50);
	DEFINE cNumCuenta CHAR(11);
	DEFINE dSaldoCuenta DECIMAL(16,2);
	DEFINE cContrasenia CHAR(50);
	DEFINE dFechaUltAcceso DATETIME YEAR TO SECOND;
	DEFINE cNumCliente CHAR(20);
	DEFINE cMensajeRet CHAR(150);
	DEFINE cCodRetLat CHAR(5);
	DEFINE cIdSesion CHAR(200);
	--DEFINE logimac integer;
	
	LET cCod_ret  = '00000';
	LET iIdUsuario=0;
	LET cNumCelular='';
	LET cAlias='';
	--LET dSaldoCuenta=0;
	LET cGen1='';
	LET cGen2='';
	LET cGen3='';
	LET cFolioActivacion='';
	LET cEstatusServ='';
	LET cImei='';
	LET cMac='';
	LET cNumCuenta='';
	LET cContrasenia='';
	LET cNumCliente='';
	LET cMensajeRet='';
	LET cIdSesion='';
	--LET logimac = 0;
	
  --SET DEBUG FILE TO "/tmp/sp_inicia_sesion_pr.out";
  --TRACE ON;
BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cCod_ret = sql_err;
            RETURN cCod_ret,cMensajeRet,cGen1,cGen2,cGen3,iIdUsuario;
      END IF;
   END EXCEPTION;
   
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF(NVL(pContra,'')=''OR NVL(pImei,'')=''OR NVL(pMac,'')=''OR NVL(pNumCel,'')=''OR NVL(pIdSesion,'')='')THEN
		LET cCod_ret = '00009';
		RETURN cCod_ret,cMensajeRet,cGen1,cGen2,cGen3,iIdUsuario;
	END IF;
	
	--VALIDA SESION PERMITIDA
	SELECT id_sesion 
	INTO cIdSesion
	FROM bdibpi:"informix".pr_sesiones_activas WHERE id_sesion=pIdsesion;
	
	IF NVL(cIdSesion,'')<>'' THEN
		
			SELECT folio_activacion,estatus_servicio,celular,id_usuario,imei,mac,cuenta,contrasenia,alias,fecha_ulti_acceso,num_cliente		
			INTO cFolioActivacion,cEstatusServ,cNumCelular,iIdUsuario,cImei,cMac,cNumCuenta,cContrasenia,cAlias,dFechaUltAcceso,cNumCliente
			FROM bdibpi:"informix".pr_registro_app WHERE celular=pNumCel AND estatus_servicio='A';
			
			--LET logimac = LEN(cImei);
			
			IF NVL(cFolioActivacion,'')<>''THEN
				--CONSULTA SALDO Y VALIDA CUENTA
				SELECT sdo_actual 
				INTO dSaldoCuenta
				FROM bdicheq:"informix".sc_maechq 
				WHERE num_cte=cNumCliente AND cuenta=cNumCuenta AND status_cta='1';
				
				IF NVL(dSaldoCuenta,'')<>'' THEN
					IF pContra=cContrasenia THEN
						IF cImei=pImei AND cMac=pMac THEN
							LET cGen1=cAlias;
							LET cGen2=dSaldoCuenta;
							LET cGen3=dFechaUltAcceso;
							
							--SE ACTUALIZA FECHA ULTIMO ACCESO
							UPDATE bdibpi:"informix".pr_registro_app SET fecha_ulti_acceso=current WHERE celular=pNumCel AND id_usuario=iIdUsuario;
						ELSE
							LET cGen1=cAlias;
							LET cGen2=dSaldoCuenta;
							LET cGen3=dFechaUltAcceso;
							
							--SE PASA EL REGISTRO A LA TABLA HISTORICA
							Insert into bdibpi:"informix".pr_registro_app_his select * from bdibpi:"informix".pr_registro_app where celular = pNumCel; 
							
							--SE ACTUALIZA FECHA ULTIMO ACCESO, IMEI Y MAC
							UPDATE bdibpi:"informix".pr_registro_app SET fecha_ulti_acceso=current,imei=pImei, mac=pMac WHERE celular=pNumCel AND id_usuario=iIdUsuario;
							
						END IF;
					ELSE
						LET cCod_ret='00003';						SELECT valor 
						INTO cMensajeRet
						FROM bdibpi:"informix".pr_param_mensajes 
						WHERE id_param='004' AND tipo_param='2';
					END IF;
				ELSE
					LET cCod_ret='00002';					SELECT valor 
					INTO cMensajeRet
					FROM bdibpi:"informix".pr_param_mensajes 
					WHERE id_param='007' AND tipo_param='2';
				END IF;
				
			ELSE
				LET cCod_ret='00001';				SELECT valor 
				INTO cMensajeRet
				FROM bdibpi:"informix".pr_param_mensajes 
				WHERE id_param='010' AND tipo_param='2';
				
			END IF;		
    ELSE
		LET cCod_ret='00005';		SELECT valor 
		INTO cMensajeRet
		FROM bdibpi:"informix".pr_param_mensajes 
		WHERE id_param='008' AND tipo_param='2';
	END IF;
    RETURN cCod_ret,cMensajeRet,cGen1,cGen2,cGen3,iIdUsuario;
   
END

END PROCEDURE
DOCUMENT
'FOLIO.........: 1549 - ProyectoRayo',
'AUTOR.........: Jose Ruben Lopez',
'FECHA.........: 19/05/2014',
'MODIFICACIÓN..: Se crea stored procedure, valida el inicio de sesion para utilizar la app pago rayo',
'SOLICITA......: Jesus Montoya',
'BD............: BDIBPI';

CREATE PROCEDURE "informix".sp_cancelartokensucursal(pEmpresa CHAR(3), pNumCliente CHAR(9), pUsrAtendio CHAR(9), pCanal CHAR(2))

	RETURNING CHAR(5), CHAR(10)	

	-- DECLARA
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cNumCliente CHAR(9);
	DEFINE cSolicitud CHAR(10);
	DEFINE cToken CHAR(10);
	DEFINE cEstatusSol CHAR(3);
	DEFINE cEstatusToken CHAR(3);
	DEFINE cSucursalRegistra CHAR(4);
	DEFINE cFolioToken CHAR(25);
	DEFINE dF_Status DATE;
	DEFINE dF_Registro DATE;
	DEFINE cCodRet_Token CHAR(5);
	DEFINE cCodRet_Sol CHAR(5);
	DEFINE dFechaSol DATE;
        DEFINE dFecSol datetime year to second;

	-- INICIALIZA
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNumCliente = '';
	LET cSolicitud = '';
	LET cToken = '0000000000';
	LET cEstatusSol = '';
	LET cEstatusToken = '';
	LET cSucursalRegistra = '';
	LET cFolioToken = '';
	LET dF_Status = '01-01-1900';
	LET dF_Registro = '01-01-1900';
	LET cCodRet_Token = '00000';
	LET cCodRet_Sol = '00000';
	LET dFechaSol = '01-01-1900';
	LET dFecSol = current;

	--SET DEBUG FILE TO "/informix/gaby/ArchivosOut/sp_cancelartokensucursal.out";
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3; 
	SET ISOLATION TO DIRTY READ;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cToken;
			END IF;
		END EXCEPTION;

		IF(pNumCliente <> '' OR pNumCliente IS NOT NULL) THEN
			SELECT MAX(f_solicitud)
                        INTO dFecSol
			FROM bdibpi:"informix".bpi_tokensolicitud 
			WHERE numcte = pNumCliente;		
			
			SELECT TS.solicitud, TS.ns_token, TS.id_status, TK.id_status
			INTO cSolicitud, cToken, cEstatusSol, cEstatusToken
			FROM bdibpi:"informix".bpi_tokensolicitud AS TS, bdibpi:"informix".tkn_nseries AS TK
			WHERE TK.ns_token = TS.ns_token
			AND TS.f_solicitud = dFecSol
			AND TS.numcte = pNumCliente;

			IF(cSolicitud <> '' OR cSolicitud IS NOT NULL) THEN
				IF (cEstatusSol::INTEGER < 120) OR (cEstatusSol::INTEGER = 175) OR (cEstatusSol::INTEGER = 199)  THEN-- OR (cEstatusSol::INTEGER >= 300 AND cEstatusSol::INTEGER < 320) THEN
					LET cCodRet = '00006'; --No se puede cancelar el token				
				ELSE
					IF (cEstatusSol::INTEGER = 120) OR (cEstatusSol::INTEGER = 320) THEN
						EXECUTE PROCEDURE bdibpi:"informix".sp_set_solicitudstatus_admtoken(cSolicitud, pNumCliente, pUsrAtendio, cEstatusSol, '199') INTO cCodRet_Sol;
					END IF;

					IF (cCodRet_Sol::INTEGER = 0) THEN							
						SELECT num_cliente,suc_registro,folio_token ,f_status::DATE,f_registro::DATE
						INTO cNumCliente, cSucursalRegistra, cFolioToken, dF_Status, dF_Registro
						FROM bdinteg:"informix".si_bpitoken 
						WHERE empresa = TRIM(pEmpresa) 
						AND num_cliente = TRIM(pNumCliente) 
						AND ns_token = TRIM(cToken);

						IF(cNumCliente <> '' OR cNumCliente IS  NULL) THEN
							INSERT INTO bdinteg:"informix".si_bpitokenhis(empresa, num_cliente, ns_token, suc_registro, folio_token, id_status_token, f_status, f_registro)
								VALUES(pEmpresa, cNumCliente, cToken, cSucursalRegistra, cFolioToken, '199', dF_Status, dF_Registro);

							DELETE bdinteg:"informix".si_bpitoken WHERE empresa = TRIM(pEmpresa) AND num_cliente = TRIM(pNumCliente) AND ns_token = TRIM(cToken);

							EXECUTE PROCEDURE bdibpi:"informix".sp_set_statustoken_admtoken(cToken, cEstatusToken, '199', pUsrAtendio, pCanal) INTO cCodRet_Token;
							IF (cCodRet_Token <> '000') THEN
								LET cCodRet = '00005'; --Error al querer actualizar estatus del token en la BD bdibpi
							END IF;

                            EXECUTE PROCEDURE bdibpi:"informix".sp_set_solicitudstatus_admtoken(cSolicitud, pNumCliente, pUsrAtendio, cEstatusSol, '199') INTO cCodRet_Sol;
							IF (cCodRet_Sol <> '000') THEN
								LET cCodRet = '00007'; --Error al querer actualizar estatus de la solicitud en la BD bdibpi
							END IF;
							
							IF (SELECT COUNT(numcte) FROM  bdibpi:"informix".tkn_envios WHERE solicitud = cSolicitud AND numcte = pNumCliente) > 0 THEN
								UPDATE bdibpi:"informix".tkn_envios SET id_status = 199 WHERE solicitud = cSolicitud AND numcte = pNumCliente;
							END IF;
						ELSE
							LET cCodRet = '00004'; --No existe el cliente ne la bdinteg:si_bpicliente
						END IF
					ELSE
						LET cCodRet = '00003'; --Error al querer cancelar la solicitud
					END IF
				END IF
			ELSE
				LET cCodRet = '00002'; --Error al tratar de obtener datos de la solicitud
			END IF
		ELSE
			LET cCodRet = '00001'; --Error en parametros de entrada
		END IF;
		RETURN cCodRet, cToken;
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Cancela la el token, es decir elimina registro de la si_bpitoken, registra la informacion en la si_bpitokenhis',
'AUTOR: Francisco RodrÃ­guez Ibarra',
'FECHA: 04-10-2010',
'MODIFICO : SaÃºl Ivanhoe Valdespino HernÃ¡ndez',
'FECHA : 25/Enero/2011',
'DESCRIPCION: Se modifica para que al cancelar el token actualice las tablas: bpi_tokensolicitud, tkn_stasolicitud, tkn_envios',
'BD: bdibpi',
'Folio: 368.1 - RQI 03 639 Proceso OFI para ImplementaciÃ³n de Token Digital',
'ModificaciÃ³n: Se agregan los status 300 y 320 para la validaciÃ³n de token digital y se agrega una condiciÃ³n validando si exite el registro',
'en la tabla tkn_envios para poder actualizar el campo id_status = 199 al cliente correspondiente',
'ModificÃ³: IRMA URETA',
'Fecha: 08/02/2018',
'ModificaciÃ³n: Se quitan los status 300 y 320 para la validaciÃ³n de token digital y se quita la condiciÃ³n validando si exite el registro',
'en la tabla si_bpitoken',
'ModificÃ³: Gabriela Aguilar',
'Fecha: 29/04/2019',
'BD: bdibpi';

CREATE PROCEDURE "informix".sp_validaservicio_tkndig(pNumCliente CHAR(9))
   RETURNING CHAR(5) as cCodRet, CHAR (9) as vnumcte , CHAR(2) as vservicio , SMALLINT as bid_status,CHAR(10) as vsolicitud, SMALLINT as vid_status,CHAR(25) as vfolio_token,CHAR(12) as vns_token,CHAR(3) as vidstatustoken,INTEGER as vtkndig;

   --SE DEFINE VARIABLES
	DEFINE cCodRet 			CHAR(10);
	DEFINE iSqlErr 			INTEGER;
	DEFINE vnumcte 			CHAR (9);
	DEFINE vservicio 		CHAR(2);
	DEFINE vsolicitud		CHAR(10);
	DEFINE vid_status		SMALLINT;
	DEFINE bid_status		SMALLINT;
	DEFINE vfolio_token		CHAR(25);
	DEFINE vfolio_contr		CHAR(25);
	DEFINE vns_token		CHAR(12);
	DEFINE vidstatustoken	CHAR(3);
	DEFINE vtkndig			INTEGER;
	DEFINE dFecSol 			datetime year to second;
	--define csol				integer;
   
   --ASIGNACION DE VARIABLES
    LET cCodRet 		= '00000';
	LET iSqlErr 		= 0;
	LET vnumcte 		= '';
	LET vservicio 		= '';
	LET vsolicitud		= '';
	LET vid_status		= 0;
	LET bid_status		= 0;
	LET vfolio_token	= '';
	let vfolio_contr	= '';
	LET vns_token		= '';
	LET vidstatustoken	= '';
	LET vtkndig			= 0;
	--let csol 			= 0;
	LET dFecSol 	= current;
   
   
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, vnumcte, vservicio, bid_status, vsolicitud, vid_status, vfolio_token, vns_token, vidstatustoken, vtkndig;
			END IF;
		END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	SELECT numcte,servicio, id_status, folio_contrato
	INTO vnumcte, vservicio, bid_status, vfolio_contr
	FROM bdinteg:si_bpiusuarios  WHERE numcte=pNumCliente;
	
	
	IF vservicio=2 THEN
	
			--Obtener la solicitud mas reciente
			SELECT MAX(f_solicitud)
            INTO dFecSol
			FROM bdibpi:"informix".bpi_tokensolicitud
			WHERE numcte = pNumCliente
			AND id_status not in ('199','220');
				
			--Verifica la solicitud
			SELECT solicitud,id_status 
			INTO vsolicitud, vid_status 
			FROM bdibpi:bpi_tokensolicitud WHERE numcte = pNumCliente and id_status not in ('199','220')
			AND f_solicitud = dFecSol;
				
			--Verifica el token
			SELECT folio_token,ns_token,id_status_token ,tipo_token
			INTO vfolio_token, vns_token, vidstatustoken,vtkndig 
			FROM bdinteg:si_bpitoken WHERE num_cliente = pNumCliente and id_status_token not in ('199','220');
			
			IF vfolio_token = '' or vfolio_token is null THEN 
				LET vfolio_token = vfolio_contr;
			END IF;
		
			
			IF vtkndig = 1 THEN 
				IF vsolicitud <> '' AND vid_status <> '300' THEN 
					LET cCodRet = '00002';	 --USUARIO QUE TIENE SOLICITUD DE TOKEN FISICO ACTIVO
				END IF;	 
			ELSE	
				IF vtkndig=2 THEN
					IF vsolicitud <> '' AND vid_status = '300' THEN 
						LET cCodRet = '00000';	 --USUARIO QUE NO TIENE SOLICITUD DE TOKEN
					ELSE	
						LET cCodRet = '00001';	 --USUARIO TIENE SOLICITUD DE TOKEN
					END IF;
				ELSE 
					IF (vtkndig IS NULL OR vtkndig = '') THEN 
						IF  vid_status = '300' THEN 
							LET cCodRet = '00001';	 --USUARIO QUE NO TIENE SOLICITUD DE TOKEN  PERO TIENE REGISTROS
						ELSE
							LET cCodRet = '00002';	 --USUARIO QUE NO TIENE SOLICITUD DE TOKEN  PERO TIENE REGISTROS
						END IF; 
					END IF;
				END IF;
			END IF;	
			
	ELSE
			LET cCodRet = '00003' ; --ES SERVICIO BASICO
	END IF;

	RETURN cCodRet, vnumcte, vservicio, bid_status, vsolicitud, vid_status, vfolio_token, vns_token, vidstatustoken, vtkndig;
	
	END;
END PROCEDURE;