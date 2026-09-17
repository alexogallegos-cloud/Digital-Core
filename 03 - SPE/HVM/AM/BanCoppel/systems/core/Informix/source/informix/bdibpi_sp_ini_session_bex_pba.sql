CREATE PROCEDURE "informix".sp_ini_session_bex_pba(pNumCel CHAR(10),pImei CHAR(150), pUdid CHAR(150), pIp CHAR(15))
   RETURNING CHAR(5), CHAR (20), CHAR(26), CHAR(26), CHAR(26), CHAR(26),  VARCHAR(2), DATETIME YEAR TO SECOND, VARCHAR(11), VARCHAR(5),CHAR(20),CHAR(100),money(14,2),DECIMAL(18,2),VARCHAR(2),VARCHAR(2);
   
    DEFINE iSql_err 			INTEGER;
	DEFINE cCod_ret 			CHAR(5);
	DEFINE cNumCliente 			CHAR (20);
	DEFINE cNombre1				CHAR (26);
	DEFINE cNombre2				CHAR (26);
	DEFINE cApellPaterno		CHAR (26);
	DEFINE cApellMaterno		CHAR (26);
	DEFINE sIdStatus 			VARCHAR (2);
	DEFINE dFecUltAcceso 		CHAR(19);
	DEFINE vIdUsuario 			VARCHAR(11);
	DEFINE vCanal				CHAR(10);
	DEFINE vCtaAso				CHAR(20);
	DEFINE vNombre				CHAR(100);
	DEFINE Vsdo 				MONEY(14,2);
	DEFINE dSdoActCap        	DECIMAL(18,2);
	DEFINE nCtaCap				VARCHAR(2);
	DEFINE nCtaCred				VARCHAR(2);
	DEFINE pUser 			 	INTEGER;
	DEFINE vCta					CHAR(20);	
	DEFINE vIntentos			VARCHAR(1);
	DEFINE vLogCta 				INTEGER;
    DEFINE pCanal               INTEGER;
   

	LET iSql_err			= 0;
	LET cCod_ret  			= '00000';
	LET cNumCliente  		= '';
	LET sIdStatus 			= '0';
	LET cNombre1 			= '';
	LET cNombre2 			= '';
	LET cApellPaterno  		= '';
	LET cApellMaterno  		= '';
	LET dFecUltAcceso 		= '';
	LET vIdUsuario 			= '';
	LET vCanal				= '';
	LET vCtaAso				= '';
	LET vNombre				= '';
	LET Vsdo				= 0;
	LET dSdoActCap          = 0;	
	LET nCtaCap				= '0';
	LET nCtaCred			= '0';
	LET pUser				= 0;
	LET vCta				= '';
	LET vIntentos	        = '0';
	LET vLogCta				= 0;
    LET pCanal				= 0;
	

 -- SET DEBUG FILE TO '/opt/jboss/EAP-6.4.0/standalone/log/sp_ini_session_bex.out';
--  TRACE ON;  

BEGIN

   ON EXCEPTION SET iSql_err
	  IF iSql_err <> 0 THEN
			LET cCod_ret = iSql_err;
		   RETURN cCod_ret, cNumCliente, cNombre1, cNombre2, cApellPaterno, cApellMaterno, sIdStatus, dFecUltAcceso,vIdUsuario, vCanal,vCtaAso,vNombre,Vsdo,dSdoActCap, nCtaCap, nCtaCred;
	  END IF ;
   END EXCEPTION ;
   
   SET LOCK MODE TO WAIT 3;
   SET ISOLATION TO DIRTY READ;
   
	SELECT id_usuario, a.num_cliente, a.estatus_servicio,a.fecha_ulti_acceso, cuenta
    INTO vIdUsuario,cNumCliente, sIdStatus, dFecUltAcceso, vCtaAso
	FROM bdibpi:"informix".bpi_registro_bex a 
	WHERE a.no_celular = pNumCel 
	AND a.estatus_servicio <> '2';
	
	IF dFecUltAcceso IS NULL THEN
		LET dFecUltAcceso = SUBSTRING (CURRENT::VARCHAR(23) FROM 1 FOR 19);
	ELSE
		LET dFecUltAcceso = SUBSTRING (dFecUltAcceso::VARCHAR(23) FROM 1 FOR 19);
	END IF;

    SELECT COUNT(canal) 
    INTO pCanal 
    FROM  bpi_doblesesion
    WHERE numcliente = cNumCliente;
	
	IF pCanal = 1 THEN
		SELECT canal 
        INTO vCanal 
        FROM bpi_doblesesion 
        WHERE numcliente = cNumCliente;
	END IF;

	IF vCanal = '' THEN
		LET vCanal = '0';
	ELSE
		IF vCanal = 'PORTALBPI' THEN LET vCanal = '1'; END IF;	
		IF vCanal = 'APPS' THEN LET vCanal = '2'; END IF;	
		IF vCanal = 'BEX' THEN LET vCanal = '3'; END IF;	
--GM3.PDRH.- INI: Se agrega "vCanal = 4" para tener un codigo de retorno.
		IF vCanal = 'BMOVI' THEN LET vCanal = '4'; END IF;	
--GM3.PDRH.- FIN: Se agrega "vCanal = 4" para tener un codigo de retorno.
	END IF;
	
	SELECT COUNT(no_celular) 
	INTO pUser 
	FROM bdibpi:bpi_registro_bex 
	WHERE imei=pImei 
	AND udid=pUdid 
	AND no_celular=pNumCel 
	AND servicio='activo';
	
   IF pUser = 0 THEN
		LET cCod_ret = '00003';
		RETURN cCod_ret, cNumCliente, cNombre1, cNombre2, cApellPaterno, cApellMaterno, sIdStatus, dFecUltAcceso,vIdUsuario, vCanal,vCtaAso,vNombre,Vsdo,dSdoActCap, nCtaCap, nCtaCred;
	END IF
	
	IF NVL(cNumCliente,'') != ''  THEN
			
		SELECT si.nombre1, si.nombre2, si.apell_paterno, si.apell_materno
		INTO cNombre1, cNombre2, cApellPaterno, cApellMaterno
		FROM bdinteg:"informix".si_cliente si 
		WHERE si.numcte = cNumCliente;
	
		IF sIdStatus = '1' THEN
		
			SELECT numero_intentos 
            INTO vIntentos 
            FROM bdibpi:"informix".bpi_ctl_inicio_sesion_bex b  
			WHERE no_celular = pNumCel  
            AND id_usuario=vIdUsuario
            AND DATE(fecha_inicio_acces) = TODAY;
	
			IF vIntentos = '2' THEN 
			
				UPDATE bdibpi:"informix".bpi_registro_bex 
                SET estatus_servicio = '3', fecha_modificada = CURRENT 
                WHERE no_celular=pNumCel  
                AND estatus_servicio = '1';
				LET cCod_ret = '00001';
				RETURN cCod_ret, cNumCliente, cNombre1, cNombre2, cApellPaterno, cApellMaterno, sIdStatus, dFecUltAcceso,vIdUsuario, vCanal,vCtaAso,vNombre,Vsdo,dSdoActCap, nCtaCap, nCtaCred;
			END IF;
			
		--ACTUALIZA ULTIMO ACCESO en bpi_usuario
			IF NVL(vIdUsuario, '') <> '' THEN
				UPDATE bdibpi:"informix".bpi_registro_bex 
				SET fecha_ulti_acceso = CURRENT 
				WHERE id_usuario=vIdUsuario 
				AND num_cliente = cNumCliente 
				AND no_celular = pNumCel 
				AND estatus_servicio = '1';
				LET cCod_ret = '00000';  -- Sesion iniciada
			END IF;
		END IF;			
			
		IF sIdStatus = '3' THEN
			LET cCod_ret = '00001'; --Usuario Bloqueado por numero de intentos		
		END IF;	
	ELSE
		LET cCod_ret = '00002';  -- Usuario invalido
	END IF ;
	
	IF cCod_ret = '00000' THEN
	
		SELECT COUNT(num_credito) 
		INTO nCtaCred 
		FROM bdicred:sd_maecred 
		WHERE status_cred IN('AA','BA','BT','VP') 
		AND numcte=cNumCliente;

		SELECT COUNT(cuenta) 
		INTO nCtaCap 
		FROM bdicheq:sc_maechq 
		WHERE status_cta NOT IN ('2')
		AND num_cte=cNumCliente;
	
		LET vLogCta=LENGTH(vCtaAso);
		
		IF vLogCta = 11 THEN 
			
			SELECT mc.cuenta, (mc.sdo_actual-mc.sdo_retenido-mc.sdo_cong-mc.imp_chq_sbg) as sdo
			INTO  vCta, Vsdo  
			FROM bdicheq:"informix".sc_maechq as mc, bdicheq:"informix".sc_producto as pr
			WHERE mc.cuenta = vCtaAso
			AND mc.status_cta not in ('2')
			AND pr.empresa = mc.empresa 
			AND pr.producto = mc.producto;

			SELECT pr.nombre
			INTO vNombre
			FROM bdicheq:"informix".sc_maechq as mc, bdicheq:"informix".sc_producto AS pr
			WHERE mc.num_cte = cNumCliente
			AND mc.cuenta = vCtaAso
			AND mc.status_cta = '1'
			AND pr.empresa = mc.empresa 
			AND pr.producto = mc.producto
			AND mc.producto IN ('2000','1300','1400','1500','1800','1700','1900','2400','2500');
		END IF;
		
		IF vLogCta = 16 THEN 
			SELECT  num_credito 
			INTO vCta 
			FROM bdicred:sd_tarjeta 
			WHERE num_tarjeta = vCtaAso;
--GM3.PDRH.- 31/10/2018 INI: Se elimina consulta de SP <bdicred:sp_consulta_saldos_general>.
--Se reemplaza con el siguiente llamado al SP 
            EXECUTE PROCEDURE bdicred:sp_consultasaldocortemin('001',vCta, 5) 
            INTO cCod_ret, dSdoActCap;	
--GM3.PDRH.- 31/10/2018 FIN: Se elimina consulta de SP <bdicred:sp_consulta_saldos_general>.				
			SELECT df.nombre_prod
			INTO vNombre 
			FROM bdicred:"informix".sd_maecred mc
			JOIN bdicred:"informix".sd_tarjeta tr ON (tr.empresa = '001' AND mc.num_credito = tr.num_credito AND tipo_tarjeta = 'T' AND mc.status_cred IN ('AA','BA','BT') AND secuencia = (SELECT MAX(secuencia) FROM bdicred:"informix".sd_tarjeta WHERE empresa = '001' AND mc.num_credito = num_credito AND tipo_tarjeta = 'T'))
			JOIN bdicred:"informix".sd_definicion df ON (df.num_producto = mc.num_producto)
			WHERE mc.numcte = cNumCliente 
			AND tr.num_tarjeta = vCtaAso
			AND mc.num_producto IN ('6600','7000','8100','6001');
		END IF;			
	END IF;
		
  RETURN cCod_ret, cNumCliente, cNombre1, cNombre2, cApellPaterno, cApellMaterno, sIdStatus, dFecUltAcceso,vIdUsuario, vCanal,vCtaAso,vNombre,Vsdo,dSdoActCap, nCtaCap, nCtaCred;
END
END PROCEDURE

DOCUMENT
'MODIFICADO POR: PATRICIA DEL RAZO-GM3',
'VALIDACION FUNCIONALIDAD POR: PATRICIA DEL RAZO-GM3',
'FECHA DE MODIFICACION: 25 DE OCTUBRE DE 2018',
'OBJETIVO: CAMBIO: ELIMINAR ERROR -284, DOBLE SESION',
'Y OPTIMIZACION DE CONSULTA DE SP',
'BD: BDIBPI';

CREATE PROCEDURE "informix".sp_validapass_bex_pba(pNumCte char(20))
returning char(5),char(50),smallint;

	-- ***************************************************************************
    -- Define variables
    -- ***************************************************************************
    define cod_ret char(5);
    define sql_err integer;
    define v_usuario, v_pass, v_pass1, v_pass2, v_pass3 char(50);
	define sBandera smallint;
	
	
	--DescripciÃ³n: Valida Pass
	--22/04/2015
    
    -- ***************************************************************************
    -- Inicializa variables
    -- ***************************************************************************
    let cod_ret = "00000";
    let v_usuario = "";
    let v_pass  = "";
    let v_pass1 = "";
    let v_pass2 = "";
    let v_pass3 = "";
	let sBandera="";

    
	--SET DEBUG FILE TO "/informix/ireb/bdibpi/bex/sp_validapass_bex.out";
	--TRACE ON;
	
    BEGIN
    
    on exception set sql_err
        if sql_err <> 0 then
            let cod_ret = sql_err;
            return cod_ret, v_usuario, sBandera;
        end if
    end exception;
	
	SET LOCK MODE TO WAIT ;

	
    IF EXISTS ( SELECT num_cliente FROM  bdibpi:"informix".bpi_registro_bex  WHERE num_cliente = pNumCte ) THEN
        SELECT LIMIT 1 no_celular, contrasenia, contrasenia1, contrasenia2
          INTO v_usuario, v_pass, v_pass1, v_pass2
          FROM bdibpi:"informix".bpi_registro_bex 
         WHERE estatus_servicio <> '2'
            AND num_cliente = pNumCte;
		   
		IF (NVL(v_pass,'') == '' AND NVL(v_pass1,'') == '' AND NVL(v_pass2,'') == '' )THEN
			let sBandera="1";
		ELSE
			let sBandera="2";
		END IF;
		         
    ELSE
        LET cod_ret = '00001';
    END IF;
    
    return cod_ret, nvl(v_usuario,''),sBandera;
    
    END
    
END PROCEDURE
;