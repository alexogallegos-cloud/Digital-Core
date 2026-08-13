CREATE PROCEDURE "informix".sp_renapo_curp(	pcAgent_trans_type_code CHAR(10),
											pcAgent_cd 				CHAR(6),
											pcUsuario 				CHAR(8),
											pcPassword 				CHAR(8),
											pcIp_origen 			CHAR(15),
											pcSession_id 			CHAR(30),
											-----------------------------------
											pcTipoTransaccion		CHAR(1),
											pcUsuarioR  			CHAR(15),
											pcPasswordR				CHAR(12),
											pcdireccionIpR			CHAR(15),
											pccveCurp				CHAR(18))
	
RETURNING
CHAR (4)   AS cCodigoError,            
CHAR (100) AS cErrorDescription;  

		
		
		
																							
				
	---DECLARACION DE VARIABLES
	DEFINE iSqlErr  				INTEGER;
	DEFINE cPCodRet 				CHAR(5);
	DEFINE cCodigoError	 			CHAR (5);
	DEFINE cErrorDescription 		CHAR (256);
	DEFINE cUsuario					CHAR(12);
	DEFINE cIpRenapo				CHAR(15);
	DEFINE cPassword				CHAR(8);
	DEFINE cAgent_cd				CHAR(3);
	DEFINE vcUsuario				CHAR(12);
	DEFINE vcPassword				CHAR(8);
	DEFINE cIp_origen				CHAR(15);
	DEFINE cId_sesion_act			CHAR(30);
	DEFINE dtFecha_dia				DATE;
	DEFINE dFechaNueva 	 			CHAR(10);
	DEFINE cDia         			CHAR(2);
	DEFINE cMes         			CHAR(2);
	DEFINE cAnio        			CHAR(4);


	---INICIALIZACION DE VARIABLES
	LET cAgent_cd ='';
	LET cUsuario ='';
	LET cPassword ='';
	LET cIp_origeN ='';
	LET cId_sesion_act ='';
	LET dtFecha_dia   = CURRENT::DATE;
	LET dFechaNueva   = DATE(1);
	LET iSqlErr = 0;
	LET cPCodRet = '0';
	LET cCodigoError = '0000';
	LET cErrorDescription = 'Consulta exitosa';
	LET	cDia='';
	LET	cMes=''; 
	LET	cAnio='';
				
	--SET DEBUG FILE TO '/informix/andrescrespo/sp_renapo_curp.out';
	--TRACE ON;

    BEGIN
    -- 
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN--manejador de errores
			LET cCodigoError = iSqlErr;
	  	
			SELECT descripcion 
			INTO  cErrorDescription
			FROM  tf_codret 
			WHERE cod_error = cCodigoError;
			
			RETURN  cCodigoError,cErrorDescription;  
		END IF;
    END EXCEPTION;
	
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 10;

		IF pcUsuario='sys_ofi' and pcPassword='sucursal' THEN
                RETURN  cCodigoError,cErrorDescription;
			
		ELIF NVL(pcAgent_cd,'?')= '?' OR NVL(pcUsuario,'?')= '?'
			 OR NVL(pcAgent_trans_type_code,'?')= '?' OR NVL(pcPassword,'?')= '?'
		     OR NVL(pcIp_origen,'?')= '?' OR NVL(pcSession_id,'?')= '?'
			 OR NVL(pcUsuarioR,'?')= '?' OR NVL(pcPasswordR,'?')= '?'
		     OR NVL(pcdireccionIpR,'?')= '?' OR NVL(pccveCurp,'?')= '?'
			THEN
			
			LET cCodigoError ='9996';
			LET cErrorDescription = "Error de parametros de entrada";
		
		ELSE
			IF EXISTS (SELECT transaccion FROM bdisac:"informix".sac_ws_transacc_ctes
			   WHERE agent_cd = pcAgent_cd AND transaccion = pcAgent_trans_type_code AND usuario = trim(pcusuario) AND activa = 'S' ) THEN

				--Se obtienen lo0s valores de lo0s campo0s, para la validacio0n de lo0s parametro0s de entrada
				SELECT agent_cd,usuario,password,ip_origen,id_sesion_act
				INTO cAgent_cd,cUsuario,cPassword,cIp_origen,cId_sesion_act
				FROM bdisac:"informix".sac_ws_clientes WHERE agent_cd = pcAgent_cd AND usuario = trim(pcusuario) and  fecha_insert = dtFecha_dia;

				
				IF cAgent_cd = pcAgent_cd THEN
					IF cUsuario = pcUsuario   THEN
						IF cPassword = pcPassword THEN
							IF cIp_origen = pcIp_origen THEN
								IF cId_sesion_act::CHAR(30) = pcSession_id THEN
									IF pcSession_id = (SELECT id_sesion_act::CHAR(30) FROM bdisac:"informix".sac_ws_clientes WHERE agent_cd = pcAgent_cd AND usuario = trim(pcusuario) and fecha_insert = dtFecha_dia) THEN
										IF pcTipoTransaccion = '6' THEN
										
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------																					
										RETURN  cCodigoError,cErrorDescription;    
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
										ELSE
											LET cCodigoError = '9995';
											LET cErrorDescription = "Error autenticaciÃ³n. TipoTransaccion.";
										END IF;											
									ELSE
										LET cCodigoError = '9975';
										LET cErrorDescription = "Error autenticaciÃ³n. Id de sesiÃ³n invÃ¡lido.";
									END IF;
								ELSE
									LET cCodigoError = '9975';
									LET cErrorDescription = "Error autenticaciÃ³n. Id de sesiÃ³n invÃ¡lido.";
								END IF;
							ELSE
								LET cCodigoError = '9976';
								LET cErrorDescription = "Error autenticaciÃ³n. IP origen invÃ¡lida ";
							END IF;
						ELSE
							LET cCodigoError = '9979';
							LET cErrorDescription = " Error autenticaciÃ³n. Password no existe.";
						END IF;
					ELSE
						LET cCodigoError = '9980';
						LET cErrorDescription = 'Error autenticaciÃ³n. Usuario no existe';
					END IF;
				ELSE
					LET cCodigoError = '9998';
					LET cErrorDescription = "AutenticaciÃ³n fallida. CÃ³digo de agente invÃ¡lido.";
				END IF;
			ELSE
				LET cCodigoError ='9982';
				LET cErrorDescription = " Consulta no exitosa. TransacciÃ³n no definida.";
			END IF;					
		END IF;

	
	RETURN  cCodigoError,cErrorDescription;  														
	END;
END PROCEDURE
DOCUMENT
'AUTOR: 96103817, Carlos Andres Crespo',
'DESCRIPCION: Servicio OT que recibe datos de transfer y ejecuta un web service RENAPO para validar la curp. ',
'FECHA: 29/08/2014',
'SOLICITO:Manuel Osuna',
'RQI 63 070 WS-PUB Transfer ',
'BD: BDITRANSFER';

CREATE PROCEDURE "informix".sp_cancelactatf(pEmpresa CHAR(3), pNumCtetf CHAR(20), pNumCtatf CHAR(20), pEmpleado CHAR(8), pSucursal CHAR(4))

	--DATOS A REGRESAR---
	RETURNING
	CHAR(6)	  AS  CodRet,
	CHAR(60)  AS  Mensaje,
	CHAR(22)  AS  FolioCAncel;
	
	--DEFINICION DE VARIABLES--
	DEFINE iSqlErr 				INTEGER;
	DEFINE cCodRet 				CHAR(6);
	DEFINE cMensaje				CHAR(60);
	DEFINE dFechaHoy			DATE;
	DEFINE dHoraActual			DATETIME HOUR TO SECOND;
	DEFINE cFolioCancel         CHAR(22); 
	DEFINE cStatusCuenta		CHAR(1);
	DEFINE mUltimoSaldo			MONEY(14,2);
	
	--INICIALIZACION DE VARIABLES--
	LET iSqlErr 			= 0;
	LET cCodRet 			= '000000';
	LET cMensaje			= 'PROCESO EJECUTADO EXISTOSAMENTE';
	LET dFechaHoy			= DATE(1);
	LET dHoraActual			= CURRENT HOUR TO FRACTION(3);
	LET cFolioCancel		= '';
	LET cStatusCuenta		= '';
	LET mUltimoSaldo		= 0.00;
	
	--SET DEBUG FILE TO "/home/sysifx/Pedro/sp_cancelactatf.out";
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cMensaje,cFolioCancel;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SE VALIDA SI LO PARAMETROS VIENE VACIOS.
		IF NVL(pEmpresa,'') = '' OR NVL(pNumCtetf,'') = '' OR NVL(pNumCtatf,'') = '' OR 
			NVL(pEmpleado,'') = '' OR NVL(pSucursal,'') = '' THEN 
		
			LET cCodRet = '000001';
			LET cMensaje = 'ERROR PARAMETROS VACIOS';
			RETURN cCodRet,cMensaje,cFolioCancel;
			
		END IF;
			
		--SE VALIDA SI NUMERO DE CLIENTE Y CUENTA EXISTE.
		IF EXISTS (SELECT numcte_tf, cuenta_tf FROM "informix".tf_maecte 
					WHERE empresa = pEmpresa AND numcte_tf = pNumCtetf AND cuenta_tf = pNumCtatf) THEN 
				
			SELECT status_cta, ultimo_saldo
			INTO cStatusCuenta, mUltimoSaldo
			FROM "informix".tf_maecte
			WHERE empresa = pEmpresa AND numcte_tf = pNumCtetf AND cuenta_tf = pNumCtatf;
			
			IF NVL(mUltimoSaldo,0.00) <> 0.00 THEN
				LET cCodRet = '000004';
				LET cMensaje = 'ERROR, LA CUENTA TIENE SALDO';
				RETURN cCodRet,cMensaje,cFolioCancel;
			END IF;
			
			IF cStatusCuenta = '1' THEN
				SELECT fecha_hoy 
				INTO dFechaHoy
				FROM bdinteg:"informix".si_fechas;
			
				UPDATE "informix".tf_maecte SET status_cta = '2', fec_cancelac = dFechaHoy 
				WHERE empresa = pEmpresa AND cuenta_tf = pNumCtatf AND numcte_tf = pNumCtetf AND status_cta = '1';
			
				--FOLIO DE CANCELACION
				LET cFolioCancel = LPAD(pEmpleado,8,'0') || YEAR(dFechaHoy) || LPAD(MONTH(dFechaHoy),2,'0') || 
									LPAD(DAY(dFechaHoy),2,'0') || LPAD(SUBSTR(dHoraActual,1,2),2,'0') || 
									LPAD(SUBSTR(dHoraActual,4,2),2,'0') || LPAD(SUBSTR(dHoraActual,7,2),2,'0'); 
			
				INSERT INTO "informix".tf_ctacancelada (empresa,cuenta_tf,folio_cancelacion,motivo,promotor_cancelo,sucursal,fecha_cancelacion) 
				VALUES (pEmpresa, pNumCtatf,cFolioCancel,'Peticion del Cliente', pEmpleado,pSucursal,dFechaHoy);
			
			--SE ELIMINA DE SC_CUENTA_TELEFONO POR CANCELACIONN DE NUMERO TRANSFER	
			DELETE FROM bdicheq:"informix".sc_cuenta_telefono 
			WHERE  cuenta = pNumCtatf AND es_transfer='S';
			
			ELIF cStatusCuenta = '2' THEN
				LET cCodRet = '000002';
				LET cMensaje = 'ERROR, LA CUENTA YA ESTA CANCELADA';
			END IF; 
		END IF;	
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '000003';
			LET cMensaje = 'NO SE ENCONTRARON DATOS';
		END IF;
		
		RETURN cCodRet,cMensaje,cFolioCancel;
	
	END	
END PROCEDURE
DOCUMENT
'AUTOR: 95689966, Pedro Jimenez Guzman',
'FOLIO: 1440',
'DESCRIPCION: Cancela cuenta transfer y registra los datos de la cuenta cancelada',
'FECHA: 17/06/2014',
'SUSTENTO: Se definio con Manuel Osuna y Grabiela Gudino en el requerimiento',
'RQI 63 050 Procesos Transfer Sucursal v1 4.pdf',
'BD: BDITRANSFER';

CREATE PROCEDURE "informix".sp_dskrga_arch_transfer()
RETURNING CHAR(5);
    
	DEFINE vcodret1             CHAR(5);
    DEFINE vcodret2             CHAR(5);
    DEFINE vcodret3             CHAR(50);
    DEFINE sql_err              INTEGER;
    DEFINE isam_err             INTEGER;
    DEFINE desc_err             CHAR(50);
	DEFINE vsql                 CHAR(1500);
    DEFINE vstmt                CHAR(200);
	DEFINE vfecha_hoy       	DATE;
    DEFINE vfecha_valor         DATE;
    DEFINE vfecha_ini           DATE;
    DEFINE vfecha_fin           DATE;
    DEFINE vfecha_des           CHAR(8);
    DEFINE vnumcte              CHAR(20);
    DEFINE vcuenta              CHAR(20);
    DEFINE vtelefono            CHAR(13);
    DEFINE vfecha_alta          DATE;
    DEFINE vfecha_canc          DATE;
    DEFINE vpoblacion_estado    CHAR(100);
	
	DEFINE vestado             CHAR(50);
	DEFINE vasigna_nip           CHAR(2);
	
    DEFINE vtransacc            CHAR(50);
    DEFINE vmonto               DECIMAL(16,2);
    DEFINE vcta_destino         CHAR(18);
    DEFINE vstatus_transacc     CHAR(28);
    DEFINE vexiste              SMALLINT;
	
	DEFINE vfech_alt            DATE;
    
    LET vcodret1            = '000';
    LET vcodret2            = '';
    LET vcodret3            = '';
    LET sql_err	            = 0 ;
    LET isam_err            = 0 ;
    LET desc_err            = '';
	LET vsql                = '';
    LET vstmt               = '';
    LET vfecha_hoy          = '';
    LET vfecha_valor        = '';
    LET vfecha_ini          = '';
    LET vfecha_fin          = '';
    LET vfecha_des          = '';
    LET vnumcte             = '';
    LET vcuenta             = '';
    LET vtelefono           = '';
    LET vfecha_alta         = '';
    LET vfecha_canc         = '';
    LET vpoblacion_estado   = '';
	LET vestado             = '';
	LET vasigna_nip         = '';
	
    LET vtransacc           = '';
    LET vmonto              = 0.00;
    LET vcta_destino        = '';
    LET vstatus_transacc    = '';
    LET vexiste             = 0;
	LET vfech_alt           = '';
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_dskrga_arch_transfer.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1;
        END IF;
     END EXCEPTION;
    
	 --SET DEBUG FILE TO "/informix/vamilan/sp_dskrga_arch_transfer.out";
	-- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	SELECT fecha_hoy
      INTO vfecha_hoy
      FROM bdinteg:si_fechas
     WHERE empresa = '001';
     
    SELECT valor
      INTO vfecha_valor
      FROM tf_param_transfer
     WHERE codigo = '900';
     
    LET vfecha_ini = vfecha_valor;
    LET vfecha_fin = vfecha_valor + 6 UNITS DAY;
    LET vfecha_des = TO_CHAR(vfecha_hoy,'%Y%m%d');
    
    TRUNCATE TABLE tf_arch_user;
    TRUNCATE TABLE tf_arch_trxs;
    
    -- // REGISTROS DE tf_user_transfer
    FOREACH
      SELECT maec.numcte_tf, maec.cuenta_tf, maec.telefono, maec.fec_alta, maec.fec_cancelac, ass.asigna_nip 
          INTO vnumcte, vcuenta, vtelefono, vfecha_alta, vfecha_canc, vasigna_nip   
      FROM tf_maecte maec
	      LEFT OUTER JOIN tf_assign_nip ass ON (ass.cuenta = maec.cuenta_tf)
          WHERE cuenta_tf >= '80000000000'
          AND maec.fec_alta BETWEEN vfecha_ini AND vfecha_fin  		 
		                           
                                   
        SELECT COUNT(*)
          INTO vexiste
          FROM tf_direcciones
         WHERE numcte_tf = vnumcte
           AND cuenta_tf = vcuenta;
           
        IF vexiste > 0 THEN
		  -- TRIM por si encuentra espacios vacios
          SELECT FIRST 1 TRIM(colonia)||' '||TRIM(municipio), TRIM(estado)       
              INTO vpoblacion_estado, vestado
          FROM tf_direcciones
               WHERE numcte_tf = vnumcte
               AND cuenta_tf = vcuenta;
        ELSE
            LET vpoblacion_estado = '';
		END IF;
        
		IF TRIM(NVL(vasigna_nip,'')) = '' THEN
			LET vasigna_nip = "00";
		END IF
		
        INSERT INTO tf_arch_user VALUES
		(vnumcte, vcuenta, vtelefono, vpoblacion_estado, vfecha_alta, vfecha_canc, vfecha_hoy, vestado, vasigna_nip);
        
        LET vnumcte = '';
        LET vcuenta = '';
        LET vtelefono = '';
        LET vfecha_alta = '';
        LET vfecha_canc = '';
        LET vpoblacion_estado = '';
		LET vestado = '';
		LET vasigna_nip = '';
    END FOREACH;
    
    -- // REGISTROS DE tf_retire_customer
    FOREACH
 
	SELECT ma.numcte_tf, ma.cuenta_tf, ma.telefono, ma.fec_alta, ma.fec_cancelac, ass.asigna_nip 
           INTO vnumcte, vcuenta, vtelefono, vfecha_alta, vfecha_canc, vasigna_nip   
        FROM tf_maecte ma 
	   	  LEFT OUTER JOIN tf_assign_nip ass ON ( ass.cuenta = ma.cuenta_tf )	
          WHERE cuenta_tf >= '80000000000'
          AND ma.fec_cancelac BETWEEN vfecha_ini AND vfecha_fin
                                                      
        SELECT COUNT(*)
          INTO vexiste
          FROM tf_direcciones
         WHERE numcte_tf = vnumcte
           AND cuenta_tf = vcuenta;
           
        IF vexiste > 0 THEN
         SELECT FIRST 1 TRIM(colonia)||' '||TRIM(municipio), TRIM(estado)       
             INTO vpoblacion_estado, vestado
          FROM tf_direcciones
             WHERE numcte_tf = vnumcte
             AND cuenta_tf = vcuenta;
        ELSE
            LET vpoblacion_estado = '';
		END IF;
        
		
		IF TRIM(NVL(vasigna_nip,'')) = '' THEN
			LET vasigna_nip = "00";
		END IF
		
        INSERT INTO tf_arch_user VALUES
        (vnumcte, vcuenta, vtelefono, vpoblacion_estado, vfecha_alta, vfecha_canc, vfecha_hoy, vestado, vasigna_nip);
		        
        LET vnumcte = '';
        LET vcuenta = '';
        LET vtelefono = '';
        LET vfecha_alta = '';
        LET vfecha_canc = '';
        LET vpoblacion_estado = '';
		LET vestado = '';
		LET vasigna_nip = '';
		
    END FOREACH;
    
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/arch_user_transfer_'||vfecha_des||'.txt '||
               'SELECT UNIQUE numcte, cuenta, telefono, fecha_alta, fecha_canc, poblacion, estado, asigna_nip FROM tf_arch_user ORDER BY numcte, cuenta;"> /resplogifx/conciliachq/archtrf1.sql';

      SYSTEM vsql;
      LET vstmt = "/ifxsif01/bin/dbaccess bditransfer /resplogifx/conciliachq/archtrf1.sql";
	  SYSTEM vstmt;
    
    -- // REGISTROS DE TRANSACCIONES MONETARIAS
    FOREACH
	 SELECT mae.numcte, trn.cuenta, mae.telefono, TRIM(trx.descripcion), trn.monto, trn.id_cuenta_destino, TRIM(sta.descripcion), trn.fech_alt 
          INTO vnumcte, vcuenta, vtelefono, vtransacc, vmonto, vcta_destino, vstatus_transacc, vfech_alt
          FROM tf_all_transaction trn
          LEFT OUTER JOIN tf_maecte mae ON ( mae.cuenta_tf = trn.cuenta )
          LEFT OUTER JOIN tf_cat_transac_mps trx ON ( trx.transac = trn.transacc AND trx.tipo_transaccion = 'M' )
          LEFT OUTER JOIN tf_cat_status_transac sta ON ( sta.estatus_transac = trn.estatus_transac )
         WHERE trn.fech_alt BETWEEN vfecha_ini AND vfecha_fin  
                                                
        INSERT INTO tf_arch_trxs VALUES
        ( vnumcte, vcuenta, vtelefono, vtransacc, vmonto, vcta_destino, vstatus_transacc, vfecha_hoy, vfech_alt);
        
        LET vnumcte = '';
        LET vcuenta = '';
        LET vtelefono = '';
        LET vtransacc = '';
        LET vmonto = 0.00;
        LET vcta_destino = '';
        LET vstatus_transacc = '';
        LET vfech_alt = ''; 
		 
    END FOREACH;
    
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/arch_trxs_transfer_'||vfecha_des||'.txt '||
               'SELECT numcte, cuenta, telefono, transacc, monto, cta_destino, status_trx, fech_alt FROM tf_arch_trxs ORDER BY numcte, cuenta;"> /resplogifx/conciliachq/archtrf2.sql';
    
    SYSTEM vsql;
    LET vstmt = '';
    LET vstmt = "/ifxsif01/bin/dbaccess bditransfer /resplogifx/conciliachq/archtrf2.sql";

	
	
    SYSTEM vstmt;
    
    -- // ACTUALIZA EL VALOR DE LA FECHA DE INICIO PARA LA PROXIMA GENERACION DE ARCHIVOS
    UPDATE tf_param_transfer 
       SET valor = vfecha_hoy
     WHERE codigo = '900';
    
    END;
    
    RETURN vcodret1;
    
END PROCEDURE;