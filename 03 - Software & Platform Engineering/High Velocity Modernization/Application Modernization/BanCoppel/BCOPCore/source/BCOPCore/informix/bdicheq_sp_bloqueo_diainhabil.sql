CREATE  PROCEDURE "informix".sp_bloqueo_diainhabil(pempresa  CHAR(3))
RETURNING CHAR(5), CHAR(5);

    DEFINE cod_ret		  CHAR(5);
	DEFINE v_clave        CHAR(5);
	DEFINE vfechahoy      DATE;
	DEFINE v_fecha_pre    DATE;
	DEFINE v_fecha_blo    DATE;
	DEFINE vfecha_cuota	  DATE;
	DEFINE vnum_credito	  CHAR(20);
	DEFINE vd_monto_cuota DECIMAL(18,2);
	DEFINE vsdo_actual    DECIMAL(18,2);
	DEFINE vstatus_cta	  CHAR(1);
	DEFINE vcuenta		  CHAR(20);
	DEFINE vcontador      SMALLINT;
	DEFINE vclave		  CHAR(5);

    DEFINE vc_numcredito  CHAR(20);
    DEFINE vc_kmpo_trabjo CHAR(20); 
    DEFINE vc_kpital_stat CHAR(1);
    DEFINE vcproceso      CHAR(15);
    DEFINE vcproceso_M1   CHAR(15);
    DEFINE v_exist_proc   INTEGER;
	
	DEFINE credcontproc   CHAR(1);
	DEFINE intecontproc	  CHAR(1);
	DEFINE cMensaje		  CHAR(125);
	DEFINE iSqlErr        INTEGER;
	DEFINE iIsamErr       INTEGER;
	DEFINE cErrorInfo     CHAR(80);
    

	LET cod_ret 		= "00000";
	LET v_clave 		= "00000";
	LET vfechahoy  	    = DATE(1);
	LET v_fecha_pre		= DATE(1);
	LET v_fecha_blo		= DATE(1);
	LET vfecha_cuota	= DATE(1);
	LET vnum_credito	= '';
	LET vsdo_actual     = 0;
	LET vd_monto_cuota  = 0;
	LET vstatus_cta		= '';
	LET vcuenta			= '';
	LET vcontador		= 0;
	LET vclave		    = '00001';
    LET vc_numcredito   = '';
    LET vc_kmpo_trabjo  = '';
    LET vc_kpital_stat  = '';
    --LET vcproceso     = '';
    --LET vcproceso_M1  = '';
	LET vcproceso		= 'BloqDiaInh';
    LET vcproceso_M1	= 'BloqDiaInh_M1';
    LET v_exist_proc 	= 0;
	
	LET credcontproc	= " ";
	LET intecontproc	= " ";
	LET cMensaje		= "Se realizo el Proceso correctamente";
	LET iSqlErr         = 0;
	LET iIsamErr        = 0;
	LET cErrorInfo      = "";

    --*********************************************************--
	-- Creado por: Francisco Martinez Viveros	
	--Fecha Creacion: 30/Agosto/2012
    --Fecha Modifica: 07/Nov/2012
    --Fecha RE-Modifica: 14/Mar/2013
	--Objetivo: Bloqueo del saldo de captacion para cuentas
    --          que presentan credinomina y su proxima fecha
    --          de pago cae en dia inhabil
	--*********************************************************--

	--SET DEBUG FILE TO "/resplogifx/archivoscredito/sp_bloqueo_diainhabil.out";
	--TRACE ON;


	
BEGIN
	
	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
	    IF iSqlErr != 0 THEN
			LET cod_ret     = iSqlErr;
		    LET cMensaje = cErrorInfo;
	    END IF;
			UPDATE bdicred:"informix".sd_contproc
				SET status_proc = "C",
					hora_fin    = CURRENT,
					cod_ret     = cod_ret,
					mensaje     = cMensaje
			WHERE empresa     = pempresa
			AND proceso     = vcproceso
			AND fecha       = vfechahoy;

			UPDATE bdinteg:sx_contproc
				SET status_proc = "C",
					hora_fin    = CURRENT,
					codret      = cod_ret
			WHERE empresa     = pempresa
				AND proceso     = vcproceso
				AND fecha       = vfechahoy;

		RETURN cod_ret, v_clave;

	END EXCEPTION;
	
	IF pempresa = "" THEN
        LET cod_ret = '11111';
		RETURN cod_ret, v_clave;
    END IF;

	SELECT fecha_hoy 
		INTO vfechahoy
	FROM bdicred:sd_fechas
	WHERE empresa = '001';
	
    
	/*
    SELECT COUNT(status_proc) 
        INTO v_exist_proc
    FROM bdinteg:sx_contproc
    WHERE fecha= vfechahoy 
    and proceso = vcproceso_M1;

    IF v_exist_proc>0 THEN
    --FMV 14MAR13 Bitacoras de ejecucion del proceso
        INSERT INTO bdinteg:sx_contproc(empresa,proceso,fecha,sistema,status_proc,ejecutivo,hora_ini,hora_fin,codret) 
           VALUES ('001','BloqDiaInh',vfechahoy,'06','I','informix',CURRENT,CURRENT,'000');
        
        INSERT INTO bdicred:sd_contproc(empresa,proceso,fecha,status_proc,ejecutivo,hora_inicio,hora_fin,cod_ret,mensaje)
           VALUES ('001','BloqDiaInh',vfechahoy,'I','informix',CURRENT,CURRENT,'000','BloqCtaDiaInh');
    ELSE 
        INSERT INTO bdinteg:sx_contproc(empresa,proceso,fecha,sistema,status_proc,ejecutivo,hora_ini,hora_fin,codret) 
               VALUES ('001',vcproceso_M1,vfechahoy,'06','I','informix',CURRENT,CURRENT,'000');

        INSERT INTO bdicred:sd_contproc(empresa,proceso,fecha,status_proc,ejecutivo,hora_inicio,hora_fin,cod_ret,mensaje)
           VALUES ('001',vcproceso_M1,vfechahoy,'I','informix',CURRENT,CURRENT,'000','BloqCtaDiaInh_M1');
    END IF;
	*/
	
	-- *******************************************************
	-- *         INSERTA PARA EJECUCIÃN DE PROCESO           *
	-- *******************************************************
	-- INI CAS

		SELECT status_proc 
			INTO intecontproc
		FROM bdinteg:sx_contproc
		WHERE fecha= vfechahoy 
		AND proceso = vcproceso;
		
		SELECT status_proc  
			INTO credcontproc
		FROM bdicred:sd_contproc
		WHERE fecha= vfechahoy 
		AND proceso = vcproceso;

		IF (intecontproc = 'I') THEN
			LET cMensaje="EXISTE UN PROCESO PREVIO EN EJECUCION";
			RETURN cod_ret,v_clave;
		END IF;	 

		IF (intecontproc IS NULL) THEN
			INSERT INTO bdinteg:sx_contproc(empresa,proceso,fecha,sistema,status_proc,ejecutivo,hora_ini,hora_fin,codret) 
			VALUES ('001',vcproceso,vfechahoy,'06','I','informix',CURRENT,CURRENT,'000');
		ELSE 
			UPDATE bdinteg:sx_contproc 
				SET hora_ini=CURRENT, status_proc='I'
			WHERE fecha= vfechahoy 
			AND proceso =vcproceso;
		END IF;

		IF (credcontproc IS NULL) THEN
			INSERT INTO  bdicred:sd_contproc(empresa,proceso,fecha,status_proc,ejecutivo,hora_inicio,hora_fin,cod_ret,mensaje)
			VALUES ('001',vcproceso,vfechahoy,'I','informix',CURRENT,CURRENT,'000','BloqCtaDiaInh');
		ELSE
			UPDATE bdicred:sd_contproc 
				SET hora_inicio=CURRENT, status_proc='I' ,mensaje = 'BloqCtaDiaInh'
			WHERE fecha= vfechahoy 
			AND proceso =vcproceso;
		END IF;
			
	--FIN CAS
	
	--EXECUTE PROCEDURE bditef:"informix".cal_fecha_pre_fh(vfechahoy) INTO cod_ret,v_fecha_pre;

	--LET vcontador = nvl(v_fecha_pre,vfechahoy) - vfechahoy ;
	
	-- ELS RQM 09 703
	LET	v_fecha_blo = DATE(vfechahoy) + 2 UNITS DAY ;
	
	IF( DAY(v_fecha_blo) in ('25','26') AND MONTH(v_fecha_blo) = '12' ) THEN
		  LET v_fecha_blo = DATE(vfechahoy);
		  LET v_fecha_blo = DATE(vfechahoy) + 3 UNITS DAY ;
	END IF;
	
	IF( DAY(v_fecha_blo) in ('01','02') AND MONTH(v_fecha_blo) = '01' ) THEN
		  LET v_fecha_blo = DATE(vfechahoy);
		  LET v_fecha_blo = DATE(vfechahoy) + 3 UNITS DAY ;
	END IF;
	--
	
	-- RQM --
	IF( v_fecha_blo = mdy(03,30,2025) ) THEN
		  LET v_fecha_blo = DATE(vfechahoy);
		  LET v_fecha_blo = DATE(vfechahoy) + 3 UNITS DAY ;
	END IF;	
	--
	
	-- Se quita contador para bloqueo de cuentas por RQM 09 703
	--IF(vcontador > 1) THEN
	  SELECT MAX(clave) 
        INTO vclave
		FROM bdicheq:sc_histbloq 
        WHERE empresa = pempresa
          AND motivo = '20';

		IF(vclave IS NULL OR vclave = '') THEN
		  LET vclave= '00001'; 
		END IF;
		IF(vclave <> '' ) THEN
		  LET vclave= '00001'; 
		END IF;
	
	FOREACH WITH HOLD   
		SELECT cta.num_cta, mae.prox_fecha_pago, amor.num_credito, amor.capital_mto_cuota, 
				amor.campo_trabajo4, amor.capital_status, cheq.sdo_actual, cheq.status_cta
			INTO vcuenta, vfecha_cuota, vc_numcredito, vd_monto_cuota, 
				vc_kmpo_trabjo, vc_kpital_stat, vsdo_actual, vstatus_cta
		FROM bdicred:sd_maecredcrd a,
            bdicred:sd_amortiza_creditocrd amor, 
            bdicred:sd_ctascarg cta,
		    bdicred:sd_maecredanexocrd mae,
            bdicheq:sc_maechq cheq
	    WHERE a.empresa = amor.empresa
			AND a.num_credito = amor.num_credito
			AND a.empresa = mae.empresa
			AND a.num_credito = mae.num_credito
        	AND a.empresa = cta.empresa
			AND a.num_credito = cta.num_credito
            AND cta.empresa = cheq.empresa
            AND cta.num_cta = cheq.cuenta	
			AND a.num_producto = '6400'
			AND amor.fecha_cuota = mae.prox_fecha_pago
			--AND amor.fecha_cuota BETWEEN DATE(vfechahoy) + 1 UNITS DAY  
								     --AND DATE(v_fecha_pre) - 1 UNITS DAY
			AND amor.fecha_cuota BETWEEN DATE(vfechahoy) + 1 UNITS DAY  
								     AND DATE(v_fecha_blo)
			AND nvl(amor.campo_trabajo4,'') = ''
	
	--	IF (vc_kmpo_trabjo = 'B') THEN    --FMV 30oct12: Cuenta con saldo bloqueado para el proximo vencimiento.
    --  		RETURN cod_ret, v_clave;
    --  END IF; -- IF vc_kmpo_trabjo = 'B'          

			IF (vstatus_cta <> '4' AND vsdo_actual >= vd_monto_cuota AND vc_kpital_stat = '3' AND vfecha_cuota <> vfechahoy) THEN
				
				IF (vc_kmpo_trabjo IS NULL OR vc_kmpo_trabjo = '') THEN
					CALL  bdicheq:"informix".bloqueo_cta('001',
											vcuenta,
											vd_monto_cuota,									
											'20',
											1,
											vfecha_cuota,
											'informix',
											vclave,
											'',
											'',
											'',
											'')  RETURNING cod_ret, v_clave;
					IF cod_ret = '000' THEN
						BEGIN WORK;
							UPDATE bdicred:sd_amortiza_creditocrd
								SET campo_trabajo4 = 'B'
							WHERE empresa = pempresa
								AND num_credito = vc_numcredito
								AND fecha_cuota = vfecha_cuota;             								   
						COMMIT WORK;  
					END IF;   
				END IF; --vc_kmpo_trabjo IS NULL OR vc_kmpo_trabjo = '')

			END IF;  --IF (vstatus_cta <> '4') THEN  


	END FOREACH;
	--END IF;
   
	UPDATE bdinteg:sx_contproc
		SET status_proc = "F", hora_fin = CURRENT, codret = cod_ret
	WHERE empresa   = pempresa
	AND proceso     = vcproceso
	AND fecha       = vfechahoy;
	
	UPDATE bdicred:"informix".sd_contproc
	SET status_proc = "F",
		hora_fin    = CURRENT,
		cod_ret     = cod_ret,
		mensaje     = cMensaje
	WHERE empresa   = pempresa
	AND proceso     = vcproceso
	AND fecha       = vfechahoy;
   
	RETURN cod_ret, v_clave;

END
END PROCEDURE;