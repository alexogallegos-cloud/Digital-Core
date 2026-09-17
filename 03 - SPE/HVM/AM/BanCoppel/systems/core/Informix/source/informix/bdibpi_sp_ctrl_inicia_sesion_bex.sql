CREATE PROCEDURE "informix".sp_ctrl_inicia_sesion_bex( pNumCel CHAR(10), pImei CHAR(150), pUdid CHAR(150), pIp CHAR(15))
    RETURNING CHAR(5);

    DEFINE sql_err 		INTEGER ;
    DEFINE cCod_ret 	CHAR(5);
	DEFINE pIdUsuario 	INTEGER;
	DEFINE cNumCelular  CHAR(10);
	DEFINE cNumCte		CHAR(10);
	DEFINE vIntents 	INTEGER;
	DEFINE vStatus		VARCHAR(1);
	DEFINE l_num_cliente INTEGER;
	DEFINE l_num_cte INTEGER;
	
	LET cCod_ret  		= '00000';
	LET pIdUsuario		=0;
	LET cNumCelular		='';
	LET vIntents		=1;
	LET vStatus 		= '';
	LET l_num_cliente   = 0;
	LET l_num_cte		= 0;
	
		--SET DEBUG FILE TO "/informix/ireb/bdibpi/bex/sp_ctrl_inicia_sesion_bex.out";
	--TRACE ON;
	
BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cCod_ret = sql_err;
            RETURN cCod_ret;
      END IF;
   END EXCEPTION;
   
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF(NVL(pNumCel,'')='' OR NVL(pIp,'')='')THEN
		LET cCod_ret = '00002';
		RETURN cCod_ret;
	END IF;
	
	SELECT num_cliente, id_usuario, estatus_servicio
	INTO cNumCte, pIdUsuario, vStatus 
	FROM bdibpi:"informix".bpi_registro_bex 
	WHERE no_celular=pNumCel 
	AND estatus_servicio IN ('1','3');
	
	IF cNumCte <> '' THEN

--GM3 P.Del Razo: 16/11/2018 INI:OptimizaciÃ³n de IF EXISTS

		SELECT COUNT(num_cliente)
		INTO l_num_cliente
		FROM bdibpi:"informix". bpi_ctl_inicio_sesion_bex 
		WHERE num_cliente=cNumCte 
		AND id_usuario=pIdUsuario;
		
		IF l_num_cliente > 0 THEN
		
			SELECT num_cliente, numero_intentos
			INTO l_num_cte, vIntents
			FROM bdibpi:"informix". bpi_ctl_inicio_sesion_bex 
			WHERE num_cliente=cNumCte 
			AND id_usuario=pIdUsuario 
			AND DATE(fecha_inicio_acces) = DATE(current);
	
			IF l_num_cte > 0 THEN
--GM3 P.Del Razo: 16/11/2018 FIN:OptimizaciÃ³n de IF EXISTS
				
				UPDATE bdibpi:"informix". bpi_ctl_inicio_sesion_bex
				SET numero_intentos = vIntents + 1
				WHERE num_cliente = cNumCte
				AND id_usuario=pIdUsuario;
				
				IF vStatus = 3 THEN 
					LET cCod_ret  = '00003';
					RETURN cCod_ret;
				END IF;			
							
				IF vIntents = 2 THEN 	

					UPDATE bdibpi:"informix".bpi_registro_bex 
					SET estatus_servicio = '3', fecha_modificada = CURRENT 
					WHERE id_usuario=pIdUsuario  
					AND estatus_servicio = '1';
					
				END IF;
			
			ELSE
			
			    UPDATE bdibpi:"informix". bpi_ctl_inicio_sesion_bex
					SET numero_intentos = 0, fecha_inicio_acces = CURRENT
					WHERE num_cliente=cNumCte 
					AND id_usuario=pIdUsuario;
					
				LET cCod_ret  = '00000';
				
			END IF;
			
			RETURN cCod_ret;
		ELSE
			INSERT INTO bdibpi:"informix". bpi_ctl_inicio_sesion_bex (id_usuario, num_cliente, no_celular, imei, udid, ip_origen,  numero_intentos, fecha_inicio_acces,fecha_registro,fecha_modificada)
			VALUES(pIdUsuario,cNumCte,pNumCel,pImei,pUdid,pIp,vIntents,current,'','');
			
			UPDATE bdibpi:"informix".bpi_registro_bex SET estatus_servicio = '1' WHERE no_celular=pNumCel AND id_usuario=pIdUsuario; 

			LET cCod_ret  = '00000';
			
		END IF;
	ELSE
		LET cCod_ret='00001';
	END IF;
   
   RETURN cCod_ret;
END
END PROCEDURE

DOCUMENT
'MODIFICADO POR: GM3-PATRICIA DEL RAZO HERNANDEZ',
'FECHA DE MODIFICACION: 16 DE NOVIEMBRE DE 2018',
'OBJETIVO: CAMBIO:OPTIMIZACION IF EXISTS',
'BD: BDIBPI';

CREATE PROCEDURE "informix".sp_obtiene_montoac_bex(pNumCelular CHAR(10), pNumCte CHAR(10))
    RETURNING CHAR(5),DECIMAL(16,2),DECIMAL(16,2);

    DEFINE sql_err INTEGER ;
    DEFINE cCodRet CHAR(5);
	DEFINE dMontoAcumuladoMes DECIMAL(16,2);
	DEFINE dMontoAcumuladoDia DECIMAL(16,2);
	DEFINE dFechaRegMes DATETIME YEAR TO SECOND;
	DEFINE dFechaRegDia DATETIME YEAR TO SECOND;
	DEFINE dFechaReg DATETIME YEAR TO SECOND;
	DEFINE dFechaHoy DATETIME YEAR TO SECOND;
	DEFINE iMesActual INTEGER;
	DEFINE iDiaActual INTEGER;
	DEFINE iDiaReg INTEGER;
	
	LET cCodRet  = '00000';
	LET dMontoAcumuladoMes  =0;
	LET dMontoAcumuladoDia =0;
	LET iMesActual  =0;
	LET iDiaActual  =0;
	LET iDiaReg = 0;
	  
BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cCodRet = sql_err;
            RETURN cCodRet,dMontoAcumuladoMes,dMontoAcumuladoDia;
	  END IF;
   END EXCEPTION;
   
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF(NVL(pNumCelular,'')='') OR (NVL(pNumCte,'')='') THEN
		LET cCodRet = '00001';
		RETURN cCodRet,dMontoAcumuladoMes,dMontoAcumuladoDia;
	END IF;
	
	SELECT fecha_hoy
	INTO dFechaHoy
	FROM bdicheq:"informix".sc_fechas
	WHERE empresa = '001';
    
    LET iMesActual = MONTH(dFechaHoy);
	LET iDiaActual = DAY(dFechaHoy);	
	
	SELECT monto_acumulado_dia, monto_acumulado,fecha 
	INTO dMontoAcumuladoDia,dMontoAcumuladoMes,dFechaRegMes
	FROM "informix".bpi_control_trans_bex
	WHERE num_celular=pNumCelular 
	AND num_cte = pNumCte;

	LET iDiaReg = DAY(dFechaRegMes);
	LET dFechaRegDia = dFechaRegMes;
	
	IF NVL(dMontoAcumuladoMes,-1)=-1 AND NVL(dMontoAcumuladoDia,-1)=-1 THEN--SE VALIDA SI NO EXISTE REGISTRO LO INICIALIZA
		INSERT INTO "informix".bpi_control_trans_bex(num_cte,num_celular,monto_acumulado,fecha,monto_acumulado_dia,canal)
		VALUES(pNumCte,pNumCelular,0,CURRENT,0,0);
		LET dMontoAcumuladoMes=0;
		LET dMontoAcumuladoDia=0;
	ELSE
		IF YEAR(dFechaRegMes)<YEAR(dFechaHoy) OR MONTH(dFechaRegMes)<iMesActual THEN --VALIDA EL AÃâO 
			
			UPDATE "informix".bpi_control_trans_bex 
			SET monto_acumulado=0, monto_acumulado_dia=0, fecha=dFechaHoy
			WHERE num_cte = pNumCte 
			AND num_celular=pNumCelular;
			LET dMontoAcumuladoMes=0;
			LET dMontoAcumuladoDia=0;
		ELSE
			IF dFechaRegDia<dFechaHoy THEN--SE VALIDA QUE SEA EL DIA ACTUAL, SI N, ACTUALIZA EL REGISTRO A MONTO CERO
				UPDATE "informix".bpi_control_trans_bex 
				SET monto_acumulado_dia=0 , fecha=dFechaHoy
				WHERE num_cte = pNumCte 
				AND num_celular=pNumCelular;
				LET dMontoAcumuladoDia=0;
			END IF;
		END IF;
	END IF;
	
    RETURN cCodRet,dMontoAcumuladoMes,dMontoAcumuladoDia;
   
END

END PROCEDURE

DOCUMENT
'MODIFICADO POR: COPPEL ',
'VALIDACION FUNCIONALIDAD POR: PATRICIA DEL RAZO-GM3',
'FECHA DE MODIFICACION: 22 DE DICIEMBRE DE 2018',
'OBJETIVO: CAMBIO: OPTIMIZACION DEL SP',
'BD: BDIBPI';

CREATE PROCEDURE "informix".sp_actualiza_sesion_bex(pc_numero_cliente varchar(20), pc_canal varchar(20), pc_id_sesion char(500), key_old varchar(100), key_new varchar(100))
    RETURNING CHAR(5),CHAR(5);
	
	DEFINE resultado CHAR(5);
    DEFINE vcodret   CHAR(5);
    DEFINE sql_err   INTEGER;
	DEFINE exist     INTEGER;
    DEFINE vCountinactivas INTEGER;
	DEFINE dFecha	DATETIME YEAR TO SECOND;
	
	--SET DEBUG FILE TO "/informix/ireb/bdibpi/bex/sp_actualiza_sesion_bex.out";
    --TRACE ON; 
	LET vcodret   = '00000';
	LET resultado = '00000';
    LET exist = 0;
    LET vCountinactivas = 0;
	LET dFecha = CURRENT;
	
	BEGIN	

	ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
			LET vcodret = sql_err;
        RETURN vcodret, resultado;
       END IF;
	END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
		
		--SELECT count(numcliente) 
		SELECT LIMIT 1 1, fecha
		INTO exist, dFecha
		FROM "informix".bpi_doblesesion 
		WHERE numcliente = pc_numero_cliente 
		AND canal = pc_canal 
		AND id_sesion = pc_id_sesion 
		AND llave = key_old;
			 
		IF exist > 0 THEN
--GM2 Juan Olivares: 25/10/2018 INI: ModificaciÃÂ³n Validacion Doble SesiÃÂ³n para evitar error -284
			/*SELECT SUM(CASE WHEN (CURRENT - fecha) < '0 00:08:00.000' THEN 1 ELSE 0 END)
            INTO vCountinactivas
            FROM "informix".bpi_doblesesion 
            WHERE numcliente = pc_numero_cliente
            AND canal = pc_canal;
*/
           -- LET vCountinactivas = NVL(vCountinactivas,0);
		   IF ((CURRENT - dFecha) < '0 00:08:00.000') THEN
				LET vCountinactivas = 1;
		   ELSE
				LET vCountinactivas = 0;				
		   END IF;

			--IF ((SELECT (CURRENT - fecha) FROM "informix".bpi_doblesesion WHERE numcliente = pc_numero_cliente AND canal = pc_canal AND id_sesion = pc_id_sesion AND llave = key_old) <  '0 00:08:00.000')
                IF  (vCountinactivas = 1) THEN
					UPDATE "informix".bpi_doblesesion 
					SET fecha = CURRENT,
					    llave = key_new
					WHERE numcliente = pc_numero_cliente
					AND canal = pc_canal
					AND id_sesion = pc_id_sesion 
					AND llave = key_old;
							
					LET resultado = '00000';
				ELSE
					DELETE FROM "informix".bpi_doblesesion 
					WHERE numcliente = pc_numero_cliente 
					AND canal = pc_canal
					AND id_sesion = pc_id_sesion 
					AND llave = key_old;
--GM2 Juan Olivares: 25/10/2018 FIN: ModificaciÃÂ³n Validacion Doble SesiÃÂ³n para evitar error -284							
					LET resultado = '00001';
				END IF;
		ELSE			
			LET resultado = '00002';
		END IF;
END;		
	RETURN	vcodret, resultado;	
END PROCEDURE

DOCUMENT
'MODIFICADO POR: JUAN OLIVARES-GM2',
'VALIDACION FUNCIONALIDAD POR: PATRICIA DEL RAZO-GM3',
'FECHA DE MODIFICACION: 25 DE OCTUBRE DE 2018',
'OBJETIVO: CAMBIO: ELIMINAR ERROR -284, DOBLE SESION',
'FECHA DE ULTIMA MODIFICACION: 26 DE DICIEMBRE DE 2018',
'MODIFICADO POR: COPPEL',
'VALIDACION FUNCIONALIDAD POR:MARCELA PEREZ GM3',
'VoBo POR: ALEJANDRO SANCHEZ-GM1',
'BD: BDIBPI';

CREATE PROCEDURE "informix".sp_cons_ctas_cap_cred_bex(pEmpresa CHAR(3), pNumCte CHAR(20))
RETURNING CHAR(5), CHAR(20), CHAR(10), CHAR(100), CHAR(1);
    
    DEFINE vCodRet 		CHAR(5);
    DEFINE vCodRet2		CHAR(5);
    DEFINE vCodRet3		CHAR(80);
    DEFINE sql_err 		INTEGER;
    DEFINE isam_err		INTEGER;
    DEFINE desc_err		CHAR(80);
    DEFINE vCuenta	 	CHAR(20);
    DEFINE vProducto	CHAR(10);
    DEFINE vNombre		CHAR(100);
    DEFINE vTipo		CHAR(1);
    DEFINE iCont		INTEGER;
    DEFINE nCtaCap		INTEGER;
    DEFINE nCtaCred		INTEGER;
    DEFINE vNumcred	 	CHAR(20);
    DEFINE nMaxsec		INTEGER;

    LET vCodRet   = '00000';
    LET vCodRet2  = '';
    LET vCodRet3  = '';
    LET sql_err   = 0;
    LET isam_err  = 0;
    LET desc_err  = '';
    LET vCuenta	  = '';
    LET vProducto = '';
    LET vNombre	  = '';
    LET vTipo	  = '';
    LET iCont 	  = 0;
    LET nCtaCap   = 0;
    LET nCtaCred  = 0;
    LET vNumcred  = '';
    LET nMaxsec   = 0;

    BEGIN
    
	ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/informix/mpm/sp_cons_ctas_cap_cred_bex.err";
        TRACE ON;
		IF sql_err <> 0 THEN
			let vCodRet = sql_err;
            let vCodRet2 = isam_err;
            let vCodRet3 = desc_err;
			RETURN vCodRet, vCuenta, vProducto, vNombre, vTipo;
		END IF
	END EXCEPTION;

 	SET ISOLATION DIRTY READ ;
    SET LOCK MODE TO WAIT 3;
    
	IF NVL(pNumCte,'') = '' THEN
        LET vCodRet = '00002';
        RETURN vCodRet, vCuenta, vProducto, vNombre, vTipo;
	END IF;
	
    FOREACH
        SELECT mc.cuenta, mc.producto, pr.nombre, 1 as tipo
          INTO vCuenta, vProducto, vNombre, vTipo
          FROM bdicheq:"informix".sc_maechq as mc, 
               bdicheq:"informix".sc_producto AS pr
         WHERE mc.num_cte = pNumCte
           AND mc.status_cta IN ('1','3','4', '5')
           AND pr.producto = mc.producto
           AND mc.producto IN ('2000','1300','1400','1500','1800','1700','1900','2400','2500')
        
        LET iCont = iCont + 1;
        
        IF (iCont < 100 ) THEN
            RETURN vCodRet, vCuenta, vProducto, vNombre, vTipo WITH RESUME;
        END IF;
    END FOREACH;
        
    /* ##########################################################################################
    FOREACH
        SELECT mc.num_credito,
        mc.num_producto,
        df.nombre_prod, 
        2 as tipo
        INTO vNumcred, vProducto, vNombre,  vTipo
        FROM bdicred:"informix".sd_maecred as mc, bdicred:"informix".sd_definicion as df
        WHERE mc.numcte = pNumCte 
          AND mc.status_cred in ('AA','BA','BT')
          AND mc.num_producto IN ('6600','7000','8100','6001')
          AND df.num_producto = mc.num_producto

        LET nMaxsec = 0;
          
        SELECT MAX(secuencia) 
        INTO nMaxsec
        FROM bdicred:"informix".sd_tarjeta
        WHERE empresa = pEmpresa
        AND   num_credito = vNumcred
        AND  tipo_tarjeta = 'T';

        SELECT num_tarjeta 
        INTO vCuenta
        FROM bdicred:"informix".sd_tarjeta			
        WHERE empresa = pEmpresa
        AND   num_credito = vNumcred
        AND  secuencia = nMaxsec;		
        
        LET iCont = iCont + 1;
        IF(iCont < 100 ) THEN
            RETURN vCodRet, vCuenta, vProducto, vNombre,  vTipo	WITH RESUME;
        END IF;
    END FOREACH;
    ########################################################################################## */
	
	IF ( iCont = 0 ) THEN
        LET vCodRet = '00001'; --- Cliente No tiene cuentas
        RETURN vCodRet, vCuenta, vProducto, vNombre, vTipo;
    END IF;
    
    END;

END PROCEDURE;