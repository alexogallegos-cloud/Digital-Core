CREATE PROCEDURE "informix".sp_ini_session_bex( pNumCel CHAR(10),
                                                pImei   CHAR(150), 
                                                pUdid   CHAR(150), 
                                                pIp     CHAR(15) )
RETURNING CHAR(5), 
          CHAR(20), 
          CHAR(26), 
          CHAR(26), 
          CHAR(26), 
          CHAR(26),  
          VARCHAR(2), 
          DATETIME YEAR TO SECOND, 
          VARCHAR(11), 
          VARCHAR(5),
          CHAR(20),
          CHAR(100),
          MONEY(14,2),
          DECIMAL(18,2),
          VARCHAR(2),
          VARCHAR(2),
		  CHAR(4);
    
    DEFINE iSql_err 		INTEGER;
    DEFINE iSam_err 		INTEGER;
    DEFINE Desc_err 		CHAR(80);
    DEFINE cCod_ret 		CHAR(5);
    DEFINE cCod_ret2		CHAR(5);
    DEFINE cCod_ret3		CHAR(80);
    DEFINE cNumCliente 		CHAR (20);
    DEFINE cNombre1			CHAR (26);
    DEFINE cNombre2			CHAR (26);
    DEFINE cApellPaterno	CHAR (26);
    DEFINE cApellMaterno	CHAR (26);
    DEFINE sIdStatus 		VARCHAR (2);
    DEFINE dFecUltAcceso 	CHAR(19);
    DEFINE vIdUsuario 		VARCHAR(11);
    DEFINE vCanal			CHAR(10);
    DEFINE vCtaAso			CHAR(20);
    DEFINE vNombre			CHAR(100);
    DEFINE Vsdo 			MONEY(14,2);
    DEFINE dSdoActCap       DECIMAL(18,2);
    DEFINE nCtaCap			VARCHAR(2);
    DEFINE nCtaCred			VARCHAR(2);
    DEFINE pUser 			INTEGER;
    DEFINE vCta				CHAR(20);	
    DEFINE vIntentos		VARCHAR(1);
    DEFINE vLogCta 			INTEGER;
    DEFINE vSdoActual       MONEY(14,2);
    DEFINE vSdoRetenido     MONEY(14,2);
    DEFINE vSdoCongelado    MONEY(14,2);
    DEFINE vSdoSobregirado  MONEY(14,2);
	DEFINE vProducto		CHAR(20);

    LET iSql_err		= 0;
    LET iSam_err		= 0;
    LET Desc_err		= '';
    LET cCod_ret  		= '00000';
    LET cCod_ret2  		= '';
    LET cCod_ret3  		= '';
    LET cNumCliente  	= '';
    LET sIdStatus 		= '0';
    LET cNombre1 		= '';
    LET cNombre2 		= '';
    LET cApellPaterno  	= '';
    LET cApellMaterno  	= '';
    LET dFecUltAcceso 	= '';
    LET vIdUsuario 		= '';
    LET vCanal			= '';
    LET vCtaAso			= '';
    LET vNombre			= '';
    LET Vsdo			= 0.00;
    LET dSdoActCap      = 0.00;	
    LET nCtaCap			= '0';
    LET nCtaCred		= '0';
    LET pUser			= 0;
    LET vCta			= '';
    LET vIntentos	    = '0';
    LET vLogCta		    = 0;
    LET vSdoActual      = 0.00;
    LET vSdoRetenido    = 0.00;
    LET vSdoCongelado   = 0.00;
    LET vSdoSobregirado = 0.00;
	LET vProducto		= '';

    BEGIN

    ON EXCEPTION SET iSql_err, iSam_err, Desc_err
        SET DEBUG FILE TO '/resplogifx/conciliachq/sp_ini_session_bex.err';
        TRACE ON;
        IF iSql_err <> 0 THEN
            LET cCod_ret  = iSql_err;
            LET cCod_ret2 = iSam_err;
            LET cCod_ret3 = Desc_err;
            RETURN cCod_ret, cNumCliente, cNombre1, cNombre2, cApellPaterno, cApellMaterno, sIdStatus, 
                   dFecUltAcceso, vIdUsuario, vCanal, vCtaAso, vNombre, Vsdo, dSdoActCap, nCtaCap, nCtaCred,vProducto;
        END IF ;
    END EXCEPTION ;
    

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;
	
	--SET DEBUG FILE TO '/informix/bdibpi/sp_ini_session_bex.out';
    --TRACE ON;

    SELECT COUNT(no_celular) 
      INTO pUser 
      FROM bdibpi:bpi_registro_bex 
     WHERE imei = pImei 
       AND udid = pUdid 
       AND no_celular = pNumCel
       AND servicio = 'activo';

    IF pUser = 0 THEN
	
		SELECT COUNT(no_celular) 
			INTO pUser 
		FROM bdibpi:bpi_registro_bex 
		WHERE imei = pImei 
		AND udid = pUdid 
		AND no_celular = pNumCel
		 AND servicio = 'inactivo';
	
		IF pUser = 0 THEN
        LET cCod_ret = '00003';
		LET sIdStatus = '1';
        RETURN cCod_ret, cNumCliente, cNombre1, cNombre2, cApellPaterno, cApellMaterno, sIdStatus, 
               dFecUltAcceso, vIdUsuario, vCanal, vCtaAso, vNombre, Vsdo, dSdoActCap, nCtaCap, nCtaCred,vProducto;
		ELSE 
		     LET cCod_ret = '00000';  --Usuario con el servicio cancelado se envia 00000 pero el status es 2
			 LET sIdStatus = '2';
			 RETURN cCod_ret, cNumCliente, cNombre1, cNombre2, cApellPaterno, cApellMaterno, sIdStatus, 
               dFecUltAcceso, vIdUsuario, vCanal, vCtaAso, vNombre, Vsdo, dSdoActCap, nCtaCap, nCtaCred,vProducto;
		END IF;		 
		
    END IF

    SELECT id_usuario, num_cliente, estatus_servicio, fecha_ulti_acceso, cuenta
      INTO vIdUsuario, cNumCliente, sIdStatus, dFecUltAcceso, vCtaAso
      FROM bdibpi:"informix".bpi_registro_bex  
     WHERE no_celular = pNumCel
       AND estatus_servicio IN('1','3','4');

    IF dFecUltAcceso IS NULL THEN
        LET dFecUltAcceso = SUBSTRING (CURRENT::VARCHAR(23) FROM 1 FOR 19);
    ELSE
        LET dFecUltAcceso = SUBSTRING (dFecUltAcceso::VARCHAR(23) FROM 1 FOR 19);
    END IF;

    SELECT canal
      INTO vCanal 
      FROM bpi_doblesesion
     WHERE numcliente = cNumCliente;

    LET vCanal = NVL(TRIM(vCanal),'');

    IF vCanal = '' THEN
        LET vCanal = '0';
    ELIF vCanal = 'BEX' THEN 
        LET vCanal = '3';	
    ELIF vCanal = 'PORTALBPI' THEN 
        LET vCanal = '1';	
    ELIF vCanal = 'APPS' THEN 
        LET vCanal = '2';	
    ELIF vCanal = 'BMOVI' THEN  --- Se agrega Canal 4 para tener un codigo de retorno
        LET vCanal = '4';	
    END IF;

    IF NVL(cNumCliente,'') != ''  THEN
        SELECT nombre1, nombre2, apell_paterno, apell_materno
          INTO cNombre1, cNombre2, cApellPaterno, cApellMaterno
          FROM bdinteg:"informix".si_cliente 
         WHERE numcte = cNumCliente;

        IF sIdStatus = '1' THEN
            SELECT numero_intentos 
              INTO vIntentos 
              FROM bdibpi:"informix".bpi_ctl_inicio_sesion_bex   
             WHERE no_celular = pNumCel  
               AND id_usuario = vIdUsuario
               AND DATE(fecha_inicio_acces) = TODAY;

            IF vIntentos = '2' THEN 
                UPDATE bdibpi:"informix".bpi_registro_bex 
                   SET estatus_servicio = '3', 
                       fecha_modificada = CURRENT 
                 WHERE no_celular = pNumCel  
                   AND estatus_servicio = '1';
                   
                LET cCod_ret = '00001';
                RETURN cCod_ret, cNumCliente, cNombre1, cNombre2, cApellPaterno, cApellMaterno, sIdStatus, 
                       dFecUltAcceso, vIdUsuario, vCanal, vCtaAso, vNombre, Vsdo, dSdoActCap, nCtaCap, nCtaCred,vProducto;
            END IF;

            --- ACTUALIZA ULTIMO ACCESO en bpi_usuario
            IF NVL(vIdUsuario, '') <> '' THEN
                UPDATE bdibpi:"informix".bpi_registro_bex 
                   SET fecha_ulti_acceso = CURRENT 
                 WHERE id_usuario = vIdUsuario 
                   AND num_cliente = cNumCliente 
                   AND no_celular = pNumCel 
                   AND estatus_servicio = '1';
                   
                LET cCod_ret = '00000';  --- Sesion iniciada
            END IF;
        END IF;			

        IF sIdStatus = '3' THEN
            LET cCod_ret = '00001'; --- Usuario Bloqueado por numero de intentos		
        END IF;	

    ELSE
        LET cCod_ret = '00002';  --- Usuario cancelado o invalido
    END IF;

    IF cCod_ret = '00000' THEN
	
        /* #####################################
        SELECT COUNT(num_credito) 
          INTO nCtaCred 
          FROM bdicred:sd_maecred 
         WHERE status_cred IN('AA','BA','BT') 
           AND numcte = cNumCliente;
        ##################################### */
        
        LET nCtaCred = '0';
		
		SELECT COUNT(cuenta) 
		INTO nCtaCap 
		FROM bdicheq:sc_maechq 
		WHERE status_cta NOT IN ('2','3')
		AND num_cte = cNumCliente
		AND cuenta=vctaaso;    --- Validacion del usuario y la cuenta

		LET vLogCta = LENGTH(vCtaAso);
	
		IF  nCtaCap = '0' THEN
			 LET cCod_ret = '00002';  --- Usuario cancelado o invalido
		END IF;	 

        IF vLogCta = 11 THEN 
            SELECT mc.cuenta, mc.sdo_actual, mc.sdo_retenido, mc.sdo_cong, mc.imp_chq_sbg, pr.nombre, mc.producto
              INTO vCta, vSdoActual, vSdoRetenido, vSdoCongelado, vSdoSobregirado, vNombre, vProducto   
              FROM bdicheq:"informix".sc_maechq as mc, 
                   bdicheq:"informix".sc_producto as pr
             WHERE mc.cuenta = vCtaAso
               AND mc.status_cta IN('1','3','4','5')
               AND pr.producto = mc.producto
               AND pr.producto IN ('2000','1300','1400','1500','1800','1700','1900','2400','2500');
               
            IF vSdoRetenido < 0 THEN
                LET vSdoRetenido = vSdoRetenido * -1;
            END IF;
            
            IF vSdoCongelado < 0 THEN
                LET vSdoCongelado = vSdoCongelado * -1;
            END IF;
            
            IF vSdoSobregirado < 0 THEN
                LET vSdoSobregirado = vSdoSobregirado * -1;
            END IF;
               
            LET Vsdo = vSdoActual - (vSdoRetenido + vSdoCongelado + vSdoSobregirado);
            
            IF Vsdo < 0 THEN
                LET Vsdo = 0.00;
            END IF;
            
            /* ########################################################################################
            SELECT pr.nombre
              INTO vNombre
              FROM bdicheq:"informix".sc_maechq as mc, 
                   bdicheq:"informix".sc_producto AS pr
             WHERE mc.num_cte = cNumCliente
               AND mc.cuenta = vCtaAso
               AND mc.status_cta = '1'
               AND pr.empresa = mc.empresa 
               AND pr.producto = mc.producto
               AND mc.producto IN ('2000','1300','1400','1500','1800','1700','1900','2400','2500');
            ######################################################################################## */
        END IF;

        IF vLogCta = 16 THEN 
            /*
            SELECT df.nombre_prod, mc.num_credito
              INTO vNombre, vCta 
              FROM bdicred:"informix".sd_maecred mc,
                   bdicred:"informix".sd_definicion df,
                   bdicred:"informix".sd_tarjeta tr 
             WHERE mc.num_credito = tr.num_credito
               AND mc.numcte = tr.numcte 
               AND mc.status_cred IN('AA','BA','BT')
               AND mc.num_producto IN('6600','7000','8100','6001')
               AND df.num_producto = mc.num_producto
               AND tr.empresa = '001'
               AND tr.num_tarjeta = vCtaAso 
               AND tr.tipo_tarjeta = 'T' 
               AND tr.secuencia = ( SELECT MAX(secuencia) 
                                      FROM bdicred:"informix".sd_tarjeta 
                                     WHERE empresa = '001' 
                                       AND num_tarjeta = vCtaAso
                                       AND tipo_tarjeta = 'T' );
            */
            
            LET vNombre = '';
            LET vCta = '';
        
            /* ############################
            SELECT num_credito 
              INTO vCta 
              FROM bdicred:sd_tarjeta 
             WHERE num_tarjeta = vCtaAso;
            ############################ */
            
            --- Se elimina consulta de SP bdicred:sp_consulta_saldos_general
            --- Se reemplaza con el siguiente llamado al SP 
            --- EXECUTE PROCEDURE bdicred:sp_consultasaldocortemin('001',vCta, 5) 
            --- INTO cCod_ret, dSdoActCap;	
            
            LET dSdoActCap = 0.00;
            
            /* #############################################################################################################################################
            SELECT df.nombre_prod
              INTO vNombre 
              FROM bdicred:sd_maecred mc
              JOIN bdicred:sd_tarjeta tr ON ( tr.empresa = '001' AND mc.num_credito = tr.num_credito AND tipo_tarjeta = 'T' AND 
                                              mc.status_cred IN('AA','BA','BT') AND secuencia = ( SELECT MAX(secuencia) 
                                              FROM bdicred:sd_tarjeta WHERE empresa = '001' AND mc.num_credito = num_credito AND tipo_tarjeta = 'T' ) )
              JOIN bdicred:"informix".sd_definicion df ON (df.num_producto = mc.num_producto)
             WHERE mc.numcte = cNumCliente 
               AND tr.num_tarjeta = vCtaAso
               AND mc.num_producto IN ('6600','7000','8100','6001');
            ############################################################################################################################################# */
        END IF;			
    END IF;

    RETURN cCod_ret, cNumCliente, cNombre1, cNombre2, cApellPaterno, cApellMaterno, sIdStatus, 
           dFecUltAcceso, vIdUsuario, vCanal, vCtaAso, vNombre, Vsdo, dSdoActCap, nCtaCap, nCtaCred,vProducto;
    
    END;
    
END PROCEDURE

DOCUMENT
'MODIFICADO POR: PATRICIA DEL RAZO-GM3',
'VALIDACION FUNCIONALIDAD POR: PATRICIA DEL RAZO-GM3',
'FECHA DE MODIFICACION: 25 DE OCTUBRE DE 2018',
'OBJETIVO DEL CAMBIO: ELIMINAR ERROR -284, DOBLE SESION Y OPTIMIZACION DE CONSULTA DE SP',
'BD: BDIBPI',
'MODIFICADO POR: JORGE IVAN CAMACHO',
'FECHA DE MODIFICACION: 16 DE ENERO DE 2019',
'SE MODIFICA POR PARTE DE LA GERENCIA DE MTTO 1 - SPL QUE NO CONSULTA CREDITO',
'SE CREO UNO NUEVO CON CREDITO QUE ENVIO ALEJANDRO SANCHEZ',
'MODIFICACION: OPTIMIZACION Y VALIDACION PARA LA OBTENCION DE SALDOS',
'MODIFICADO POR: IVAN ESCALONA',
'FECHA DE MODIFICACION: 23 DE JULIO DE 2019',
'SE MODIFICA POR PARTE DE LA GERENCIA DE MTTO 3 - SE AGREGA VALIDACION DE LAS CUENTAS';

CREATE PROCEDURE "informix".sp_reg_ver(pNumCteTel CHAR(15), pCanal CHAR(3),pVer CHAR(50))
returning CHAR(5);

	DEFINE sql_err 			INTEGER ;
	DEFINE cod_ret 			CHAR(5);
	DEFINE vUser			CHAR(3);

	
 
	LET cod_ret 	 	= '00000';
	LET vUser			= '';
	
  
--  SET DEBUG FILE TO "/informix/bdibpi/sp_reg_ver.out";
--  TRACE ON;
  
	
BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret;
      END IF;
   END EXCEPTION;
   
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	LET vUser = LENGTH(pNumCteTel);
	
	IF pCanal = 'BX' THEN  --PARA BANCOPPEL EXPRESS
	
		IF vUser = '10' THEN  --SI SE ENVIA NUMERO CELULAR
		
			UPDATE bdibpi:bpi_registro_bex SET folio_activacion=pVer WHERE no_celular = pNumCteTel
			AND servicio = 'activo';
			
			LET cod_ret  = '00000';
			RETURN cod_ret;	
			
		ELIF vUser = '9' THEN  ---SI SE ENVIA NUMERO CLIENTE
			
			UPDATE bdibpi:bpi_registro_bex SET folio_activacion=pVer WHERE num_cliente = pNumCteTel
			AND servicio = 'activo';
			
			LET cod_ret  = '00000';
			RETURN cod_ret;	
			
		END IF	
		
	END IF
	
	IF pCanal = 'BM' THEN --PARA BANCOPPEL MOVIL
		
		IF vUser = '10' THEN  --SI SE ENVIA NUMERO CELULAR
		
			UPDATE bdibpi:bpi_reg_dispo_apps SET generico1=pVer WHERE no_celular = pNumCteTel
			AND dispo_act = '1';
			
			LET cod_ret  = '00000';
			RETURN cod_ret;	
			
		ELIF vUser = '9' THEN  ---SI SE ENVIA NUMERO CLIENTE
			
			UPDATE bdibpi:bpi_reg_dispo_apps SET generico1=pVer WHERE num_cliente = pNumCteTel
			AND dispo_act = '1';
	
			LET cod_ret  = '00000';
			RETURN cod_ret;	
			
		END IF	
		
	END IF
   
END;

END PROCEDURE;