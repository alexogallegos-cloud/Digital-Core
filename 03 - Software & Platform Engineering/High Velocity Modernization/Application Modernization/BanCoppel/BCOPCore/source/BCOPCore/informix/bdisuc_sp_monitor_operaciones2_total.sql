CREATE PROCEDURE "informix".sp_monitor_operaciones2_total(eEmpresa      CHAR(3),
														eTipo         CHAR(1), --**C = ATM , S = Sucursal
														eSucursal     CHAR(4),
														eCodTrans     CHAR(4),  --Operacion
														eFecInicio    DATE,
														eFecFin       DATE,
														eProveedor    CHAR(4)) 
			RETURNING CHAR(5),        --** Error vCodRet            vcodret                            
					  INTEGER;        --** Total de registros encontrados

	DEFINE vCodRet       CHAR(5);
	DEFINE vCajGen       CHAR(1);
	DEFINE iTotalRegistros INTEGER;
	DEFINE iTotalRegistrosTmp INTEGER;


	LET vCodRet       = "000";
	LET vCajGen       = 'N';
	LET iTotalRegistros = 0;
	
	BEGIN

		--SET DEBUG FILE TO "/tmp/mfinis/sp_monitor_operaciones2_total.out";
		--TRACE ON;

		SET LOCK MODE TO WAIT 3; 
		SET ISOLATION TO DIRTY READ;

        IF eSucursal='0000' AND eCodTrans='0000' THEN
            LET eSucursal='';  
            LET eCodTrans='';
        END IF;


		IF eCodTrans = '' OR eCodTrans IS NULL THEN   --** Por operacion
			IF eFecInicio = '' OR eFecInicio IS NULL  THEN
				LET eFecInicio = MDY(1,1,2007);
			END IF

			IF eTipo = 'C' THEN
				LET vCajGen = eTipo;
			END IF
		
			SELECT COUNT(*)
			INTO iTotalRegistros
			FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b
			WHERE a.cod_trans != '0'
				AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin
				AND a.sucursal IN (SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal)} sucursal
								FROM bdinteg:"informix".si_sucursales
								WHERE sucursal != '0'
									AND empresa = eEmpresa
									AND tpo_sucursal = eTipo or tpo_sucursal = vCajGen)
				AND a.reversado IN ('0','1')
				AND a.folio_oper    = b.folio_oper
				AND b.cod_proveedor = eProveedor;

			RETURN vcodret, iTotalRegistros; 
					
		ELIF eProveedor = '0000' THEN

			IF eFecInicio = '' OR eFecInicio IS NULL  THEN
				LET eFecInicio= MDY(1,1,2007);
			END IF;

			IF eCodTrans in ('0001','0002','0036','0041','0010') THEN
			
				IF eCodTrans ='0001' THEN
					
					SELECT COUNT(*)
					INTO iTotalRegistros
					FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b
						WHERE a.cod_trans = eCodTrans
							AND b.status IN ('01','03','05','11','08')
							AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin
							AND(a.sucursal IN (SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal)} sucursal
												FROM bdinteg:"informix".si_sucursales
												WHERE sucursal != '0'
												AND empresa = eEmpresa
												AND tpo_sucursal = eTipo)
							OR a.sucursal IN (SELECT cod_proveedor
											FROM bdisuc:ss_proveedores
											WHERE cod_proveedor = b.cod_proveedor ))
												AND a.reversado IN ('0','1')
							AND a.folio_oper = b.folio_oper ;
					RETURN vcodret, iTotalRegistros;
						
				ELSE

					SELECT COUNT(*)
					INTO iTotalRegistros
					FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b
						WHERE a.cod_trans = eCodTrans
							AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin
							AND( a.sucursal IN (SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal)} sucursal
											FROM bdinteg:"informix".si_sucursales
											WHERE sucursal != '0'
												AND empresa = eEmpresa
												AND tpo_sucursal = eTipo)
							OR a.sucursal IN (SELECT cod_proveedor
											FROM bdisuc:ss_proveedores
											WHERE cod_proveedor = b.cod_proveedor ))
							AND a.reversado IN ('0','1')
							AND a.folio_oper = b.folio_oper ;
						
					RETURN vcodret, iTotalRegistros;
				
				END IF;
		
			END IF;

		ELIF eSucursal <> '0000'  THEN   --** Por Sucursal

			IF eFecInicio = '' OR eFecInicio IS NULL  THEN
				LET eFecInicio= MDY(1,1,2007);
			END IF

			SELECT COUNT(*)
			INTO iTotalRegistros
			FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b
			WHERE a.cod_trans = eCodTrans
				AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin
				AND a.sucursal = eSucursal
				AND a.reversado IN ('0','1')
				AND a.folio_oper    = b.folio_oper;

			RETURN vcodret, iTotalRegistros;
				
		ELSE

			SELECT COUNT(*)
			INTO iTotalRegistros
			FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b
			WHERE a.cod_trans = eCodTrans
				AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin
				AND( a.sucursal IN (SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal)} sucursal
									FROM bdinteg:"informix".si_sucursales
									WHERE sucursal != '0'
										AND empresa = eEmpresa
										AND tpo_sucursal = eTipo)
				OR a.sucursal IN (SELECT cod_proveedor
									FROM bdisuc:ss_proveedores
									WHERE cod_proveedor = eProveedor))
				AND a.reversado IN ('0','1')
				AND a.folio_oper    = b.folio_oper
				AND b.cod_proveedor = eProveedor;
			
			RETURN vcodret, iTotalRegistros;
					
		END IF;
	
	END;

END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 12/01/2015',
'DESCRIPCION: Consulta el total de registros que va a devolver la consulta del monitor de operaciones',
'BD: bdisuc',
'FECHA: 11/12/2020',
'DESCRIPCION: Se realiza ajuste a SP para agregar la transaccion 0010 - Solicitud de DotaciÃ³n',
'AUTOR: Veronica Sanches Tlacomulco';

CREATE PROCEDURE "informix".sp_layoutsif_con_suc()
RETURNING CHAR(5) AS cod_ret,
		  CHAR(80) AS mensaje;

--DECLARACION DE VARIABLES		  
DEFINE cod_ret					CHAR(5);
DEFINE vmensaje					CHAR(80);	
DEFINE vpaso		    		INTEGER;
DEFINE SQL_ERR          		INTEGER;
DEFINE ISAM_ERR         		INTEGER;
DEFINE ERROR_INFO       		CHAR(80);
DEFINE vsql						CHAR(200);
DEFINE cArchivo  				CHAR(50);
DEFINE cRuta					CHAR(50);

DEFINE v_folio_servicio		VARCHAR (16);
DEFINE v_fecha_envio 		DATE;
DEFINE v_monto 				MONEY(18,2);
DEFINE v_descripcion		VARCHAR(30);
DEFINE v_nombre			 	VARCHAR(45);
DEFINE v_sucursal			VARCHAR(4);
DEFINE v_fecha_operacion	DATE;

--VARIABLE DE PASO
DEFINE v_fecha_hoy				DATE;
DEFINE v_fecha_ant				DATE;
DEFINE v_fecha_inicio			DATE;
DEFINE cDiaI		  			CHAR(2);
DEFINE cMesI		  			CHAR(2);
DEFINE cAnoI		  			CHAR(4);
DEFINE cFechaI  				CHAR(8);

--SE INICIALIZAN VARIABLES
LET cRuta	= '/RESPALDOSNEW/';
LET v_folio_servicio		= '';
LET v_monto 				= 0;
LET v_descripcion		= '';
LET v_nombre			= '';
LET v_sucursal			= '';

BEGIN
    
    --CONTROL DE ERRORES
    ON EXCEPTION SET SQL_ERR,ISAM_ERR,ERROR_INFO
        LET cod_ret  = SQL_ERR;
        LET vmensaje  = TRIM(ERROR_INFO)||' sp_layoutsif_con_suc en el paso '||vpaso;
		RETURN cod_ret, vmensaje;
    END EXCEPTION;
	
	--SET DEBUG FILE TO '/RESPALDOSNEW/sp_layoutsif_con_suc.out';
    --TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	LET vpaso = 1;
	
	--OBTIENE LA FECHA DEL DIA ANTERIOR DE LA FECHA ACTUAL
	SELECT fecha_hoy, fecha_ant 
	INTO v_fecha_hoy, v_fecha_ant
	FROM bdinteg:si_fechas;
	
	LET vpaso = 2;
	
	LET v_fecha_inicio = v_fecha_ant;
	
	LET cDiaI = LPAD(DAY(v_fecha_inicio), 2, '0');
	LET cMesI = LPAD(MONTH(v_fecha_inicio), 2, '0');
	LET cAnoI = YEAR(v_fecha_inicio);
	--DA FORMATO 'AAAAMMDD' A LA FECHA
	LET cFechaI = cAnoI||cMesI||cDiaI;
	
	LET vpaso = 3;
	
	---Borrado de la tabla de paso
		TRUNCATE TABLE "informix".ss_concentraciones_temp;
		TRUNCATE TABLE "informix".ss_dotaciones_temp;
		TRUNCATE TABLE "informix".ss_dotaciones_moneda_temp;
	
	LET vpaso = 4;
	LET cArchivo = TRIM('CONCENTRACIONES_'||TRIM(cFechaI)||'.txt');
	
	FOREACH WITH HOLD 
		SELECT {+AVOID_FULL(bdisuc:ss_proveedores)} mae.fecha_envio, suc.sucursal||' '||suc.nombre, mae.monto, pro.descripcion, suc.sucursal, mae.folio_servicio
		INTO v_fecha_envio, v_nombre, v_monto,v_descripcion,v_sucursal,v_folio_servicio
		FROM bdisuc:ss_mae_entradasalida mae, bdisuc:ss_operaciones op, bdinteg:si_sucursales suc, bdisuc:ss_proveedores pro
		WHERE mae.fecha_envio = v_fecha_inicio
		AND mae.folio_oper = op.folio_oper
		AND op.cod_trans = '0002'
		AND op.sucursal = suc.sucursal
		AND mae.cod_proveedor = pro.cod_proveedor
		
		LET vpaso = 5;
		
		
		INSERT INTO "informix".ss_concentraciones_temp (fecha_envio, nombre, monto, descripcion, sucursal, folio_servicio)
		VALUES (v_fecha_envio, TRIM(v_nombre), v_monto,TRIM(v_descripcion),TRIM(v_sucursal),TRIM(v_folio_servicio));	
		
		LET vpaso = 6;	
		
	END FOREACH;
	
	LET vpaso = 7;
	
	LET vpaso = 8;	
	LET vsql = '';
	LET vsql = 'echo "UNLOAD TO '||TRIM(cRuta)||TRIM(cArchivo)||' SELECT * FROM bdisuc:ss_concentraciones_temp;">'||TRIM(cRuta)||TRIM(cArchivo)||'_01.sql'; 
	system vsql;
	LET vsql = '';
	
	LET vpaso = 9;
	--SE EJECUTA EL SCRIPT
	LET vsql = 'chmod 777 '||TRIM(cRuta)||TRIM(cArchivo)||'_01.sql';
	system vsql;
	LET vsql = '';
	LET vsql = 'dbaccess bdiauditor '||TRIM(cRuta)||TRIM(cArchivo)||'_01.sql';
	system vsql;
	
	LET vpaso = 10;
	--SE BORRA EL SCRIPT
	LET vsql = '';
	LET vsql = 'rm '||TRIM(cRuta)||TRIM(cArchivo)||'_01.sql';
	system vsql;
	
	LET vpaso = 11;
	
	LET vpaso = 12;
	LET cArchivo = TRIM('DOTACIONES_'||TRIM(cFechaI)||'.txt');
	
	FOREACH WITH HOLD 
		SELECT op.fecha_operacion, suc.sucursal, suc.nombre, pro.descripcion, mae.monto
		INTO v_fecha_operacion, v_sucursal ,v_nombre, v_descripcion, v_monto
		FROM bdisuc:ss_mae_entradasalida mae, bdisuc:ss_operaciones op, bdinteg:si_sucursales suc, bdisuc:ss_proveedores pro
		WHERE op.fecha_operacion = v_fecha_inicio
		AND op.folio_oper = mae.folio_oper
		AND op.cod_trans = '0001'
		AND op.sucursal = suc.sucursal
		AND mae.cod_proveedor = pro.cod_proveedor
		
		LET vpaso = 13;
		
		
		INSERT INTO "informix".ss_dotaciones_temp (fecha_operacion, sucursal ,nombre, descripcion, monto)
		VALUES (v_fecha_operacion,TRIM(v_sucursal) ,TRIM(v_nombre), TRIM(v_descripcion), v_monto);	
		
		LET vpaso = 14;
		
	END FOREACH;
	
	LET vpaso = 15;
	
	LET vpaso = 16;	
	LET vsql = '';
	LET vsql = 'echo "UNLOAD TO '||TRIM(cRuta)||TRIM(cArchivo)||' SELECT * FROM bdisuc:ss_dotaciones_temp;">'||TRIM(cRuta)||TRIM(cArchivo)||'_01.sql'; 
	system vsql;
	LET vsql = '';
	
	LET vpaso = 17;
	--SE EJECUTA EL SCRIPT
	LET vsql = 'chmod 777 '||TRIM(cRuta)||TRIM(cArchivo)||'_01.sql';
	system vsql;
	LET vsql = '';
	LET vsql = 'dbaccess bdiauditor '||TRIM(cRuta)||TRIM(cArchivo)||'_01.sql';
	system vsql;
	
	LET vpaso = 18;
	--SE BORRA EL SCRIPT
	LET vsql = '';
	LET vsql = 'rm '||TRIM(cRuta)||TRIM(cArchivo)||'_01.sql';
	system vsql;
	
	LET vpaso = 19;
	
	LET vpaso = 20;
	LET cArchivo = TRIM('DOTACIONES_MONEDA_'||TRIM(cFechaI)||'.txt');
	
	FOREACH WITH HOLD 
		SELECT op.fecha_operacion, suc.sucursal, suc.nombre, pro.descripcion, mae.monto
		INTO v_fecha_operacion, v_sucursal ,v_nombre, v_descripcion, v_monto
		FROM bdisuc:ss_mae_entradasalida mae, bdisuc:ss_operaciones op, bdinteg:si_sucursales suc, bdisuc:ss_proveedores pro
		WHERE op.fecha_operacion = v_fecha_inicio
		AND op.folio_oper = mae.folio_oper
		AND op.cod_trans = '0010'
		AND op.sucursal = suc.sucursal
		AND mae.cod_proveedor = pro.cod_proveedor 
		
		LET vpaso = 21;

		
		INSERT INTO "informix".ss_dotaciones_moneda_temp (fecha_operacion, sucursal ,nombre, descripcion, monto)
		VALUES (v_fecha_operacion, TRIM(v_sucursal) ,TRIM(v_nombre), TRIM(v_descripcion), v_monto);	
		
		LET vpaso = 22;
			
		
	END FOREACH;
	
	LET vpaso = 23;
	
	LET vpaso = 24;	
	LET vsql = '';
	LET vsql = 'echo "UNLOAD TO '||TRIM(cRuta)||TRIM(cArchivo)||' SELECT * FROM bdisuc:ss_dotaciones_moneda_temp;">'||TRIM(cRuta)||TRIM(cArchivo)||'_01.sql'; 
	system vsql;
	LET vsql = '';
	
	LET vpaso = 25;
	--SE EJECUTA EL SCRIPT
	LET vsql = 'chmod 777 '||TRIM(cRuta)||TRIM(cArchivo)||'_01.sql';
	system vsql;
	LET vsql = '';
	LET vsql = 'dbaccess bdiauditor '||TRIM(cRuta)||TRIM(cArchivo)||'_01.sql';
	system vsql;
	
	LET vpaso = 26;
	--SE BORRA EL SCRIPT
	LET vsql = '';
	LET vsql = 'rm '||TRIM(cRuta)||TRIM(cArchivo)||'_01.sql';
	system vsql;
	
	LET cod_ret = '00000';
    LET vmensaje = 'PROCESO EXITOSO';
	
	RETURN cod_ret, vmensaje;
	
END;
END PROCEDURE
DOCUMENT 'AUTOR: Jorge Luis Arias Nu#ez',
'FECHA: 24/02/2021',
'DESCRIPCION: GeneraciÃÂ³n de layout sif para el area de Caja General',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_entrada_salida(pUsuario CHAR(8),pIdFuncion CHAR(10), eEmpresa CHAR(3),
                                              eTipo       CHAR(1), 
                                              eSucursal   CHAR(4),
                                              ePlaza      CHAR(3),
                                              eFecInicio  DATE,
                                              eFecFin     DATE,
                                              eMes        CHAR(2),
                                              eAnio       CHAR(4),
                                              eStatus     CHAR(2),
											  bandera     CHAR(1))
RETURNING CHAR(5)    ,          --CodRet
          INTEGER;              --Total de registros

 DEFINE vCodRet       CHAR(5);
 DEFINE vCodProveedor CHAR(50);
 DEFINE vFolOper      CHAR(8);
 DEFINE vSucursal     CHAR(4);
 DEFINE vNomSuc       CHAR(40);
 DEFINE vFolSuc       CHAR(16);
 DEFINE vFecSol       DATE;
 DEFINE vUsuarioSol   CHAR(8);
 DEFINE vNomUsuSol    CHAR(40);
 DEFINE vFecEnvio     DATE;
 DEFINE vUsuarioEnv   CHAR(8);
 DEFINE vNomUsuEnv    CHAR(40);
 DEFINE vFecRecepcion DATE;
 DEFINE vUsuarioRecep CHAR(8);
 DEFINE vNomUsuRecep  CHAR(40);
 DEFINE vDesStatus    CHAR(40);
 DEFINE vMonto        MONEY(14,2);
 DEFINE vFecRever     DATE;
 DEFINE vUsuarioRever CHAR(40);
 DEFINE vNomUsuRever  CHAR(40);
 DEFINE vNomPlaza     CHAR(40);
 DEFINE vCajGen       CHAR(1);
 DEFINE vRegistros    INTEGER;
 DEFINE iNumRegistros INTEGER;
 DEFINE iSqlErr INTEGER;
 
 LET iSqlErr =0;
 LET vCodRet       = "000";
 LET vCodProveedor = '';
 LET vFolOper      = '';
 LET vSucursal     = '';
 LET vNomSuc       = '';
 LET vFolSuc       = '';
 LET vFecSol       = '';
 LET vUsuarioSol   = '';
 LET vNomUsuSol    = '';
 LET vFecEnvio     = '';
 LET vUsuarioEnv   = '';
 LET vNomUsuEnv    = '';
 LET vFecRecepcion = '';
 LET vUsuarioRecep = '';
 LET vNomUsuRecep  = '';
 LET vMonto        = 0;
 LET vFecRever     = '';
 LET vUsuarioRever = '';
 LET vNomUsuRever  = '';
 LET vDesStatus    = '';
 LET vNomPlaza     = '';
 LET ePlaza = ePlaza;
 LET eStatus  = eStatus;
 LET eSucursal  = eSucursal;
 LET ePlaza = ePlaza;
 LET eStatus  = eStatus;
 LET eSucursal  = eSucursal;
 LET vCajGen = 'N';
 LET vRegistros = 0;
 LET iNumRegistros = 0;

	BEGIN
 
		ON EXCEPTION SET iSqlErr
			LET vCodRet = iSqlErr;
			UPDATE {+INDEX (bdicnweb:sw_verificastatusentradasalida idx_sw_verificastatusentradasalida)} bdicnweb:"informix".sw_verificastatusentradasalida
			SET status = 'E', error_proceso = 'S', error = vCodRet WHERE usuario_insert = pUsuario;
			RETURN vCodRet, iNumRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_entrada_salida2.out';
		--TRACE ON;

		-- SE LIMPIA TABLA POR USUARIO
		DELETE {+INDEX (bdicnweb:sw_verificastatusentradasalida idx_sw_verificastatusentradasalida)} FROM  bdicnweb:"informix".sw_verificastatusentradasalida WHERE usuario_insert = TRIM(pUsuario);
		INSERT INTO bdicnweb:"informix".sw_verificastatusentradasalida(usuario_insert,status,num_registros,error_proceso,error) VALUES(pUsuario,'I',0,'',vCodRet);
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET vCodRet = '00003';
			UPDATE {+INDEX (bdicnweb:sw_verificastatusentradasalida idx_sw_verificastatusentradasalida)} bdicnweb:"informix".sw_verificastatusentradasalida
			SET status = 'E', error_proceso = 'S', error = vCodRet WHERE usuario_insert = pUsuario;
			RETURN vCodRet, iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO vCodRet;
		IF vCodRet <> '00000' THEN
			UPDATE {+INDEX (bdicnweb:sw_verificastatusentradasalida idx_sw_verificastatusentradasalida)} bdicnweb:"informix".sw_verificastatusentradasalida
			SET status = 'E', error_proceso = 'S', error = vCodRet WHERE usuario_insert = pUsuario;
			RETURN vCodRet, iNumRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		IF eTipo = 'C' THEN
			LET vCajGen = eTipo;
		END IF;
   
		IF ePlaza <> '000' AND eSucursal = '0000' AND eStatus = '00'  THEN
			FOREACH
				SELECT {+ INDEX(bdisuc:ss_operaciones idx01ss_operaciones),INDEX (bdisuc:ss_proveedores idx01ss_proveedores)} b.folio_oper,b.sucursal,b.folio_sucursal,b.fecha_solicitud,b.usuario_solicitud,
					b.fecha_envio,b.usuario_envio,b.fecha_recepcion,b.usuario_recepcion,b.monto,b.fecha_reversion,
					b.usuario_reversion ,c.descripcion,b.status
					INTO  vFolOper,vSucursal,vFolSuc,vFecSol,vUsuarioSol,
					vFecEnvio,vUsuarioEnv,vFecRecepcion,vUsuarioRecep,vMonto,vFecRever,
					vUsuarioRever,vCodProveedor,eStatus
					FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores  c
					WHERE a.cod_trans != '0'                      
					AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin 
					AND a.sucursal IN (SELECT sucursal 
											FROM bdinteg:"informix".si_sucursales  
											WHERE sucursal != '0' 
											AND empresa = eEmpresa
											AND plaza_cajagen = ePlaza 
											AND tpo_sucursal = eTipo)
					AND a.reversado IN ('0','1')
					AND a.folio_oper    = b.folio_oper   
					AND c.cod_proveedor = b.cod_proveedor 
					ORDER BY b.fecha_solicitud ASC

					SELECT nombre INTO vNomSuc FROM bdinteg:"informix".si_sucursales WHERE sucursal = vSucursal AND empresa = eEmpresa;
					SELECT nombre INTO vNomUsuSol FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = vUsuarioSol;
					SELECT nombre INTO vNomUsuEnv FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = vUsuarioEnv;
					SELECT nombre INTO vNomUsuRecep FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = vUsuarioRecep;
					SELECT nombre INTO vNomUsuRever FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = vUsuarioRever;
					SELECT descripcion INTO vDesStatus FROM bdisuc:"informix".ss_catstatus WHERE status = eStatus;
					SELECT descripcion INTO vNomPlaza FROM bdinteg:"informix".si_plazas_cajagen WHERE codigo_plaza = ePlaza AND empresa = eEmpresa;

					LET vSucursal = vSucursal ||' '|| vNomSuc;
					LET vUsuarioSol = vUsuarioSol || ' ' ||vNomUsuSol;
					LET vUsuarioEnv = vUsuarioEnv || ' '|| vNomUsuEnv;
					LET vUsuarioRecep = vUsuarioRecep || ' ' || vNomUsuRecep;
					LET vUsuarioRever = vUsuarioRever || ' '|| vNomUsuRever;
							
					LET iNumRegistros = iNumRegistros + 1;
							
					INSERT INTO bdicnweb:"informix".tmp_entradasalida
					(codproveedor,foloper,desstatus,sucursal,folsuc,fecsol,usuariosol,fecenvio,usuarioenv,fecrecepcion,
					usuariorecep,monto,fecrever,vusuariorever,empresa,nomplaza,tipo_suc,id_usuario) 
					VALUES (vCodProveedor,vFolOper,vDesStatus,vSucursal,vFolSuc,vFecSol,vUsuarioSol,vFecEnvio,vUsuarioEnv,vFecRecepcion,
					vUsuarioRecep,vMonto,vFecRever,vUsuarioRever,eEmpresa,vNomPlaza,eTipo,pUsuario);

                   END FOREACH;
				   
				IF iNumRegistros = 0 THEN
					LET vCodRet = '00017';
					UPDATE {+INDEX (bdicnweb:sw_verificastatusentradasalida idx_sw_verificastatusentradasalida)} bdicnweb:"informix".sw_verificastatusentradasalida
					SET status = 'E', error_proceso = 'S', error = vCodRet WHERE usuario_insert = pUsuario;
				END IF;	
		
				UPDATE {+INDEX (bdicnweb:sw_verificastatusentradasalida idx_sw_verificastatusentradasalida)} bdicnweb:"informix".sw_verificastatusentradasalida
				SET status = 'T', error_proceso = 'N', num_registros = iNumRegistros WHERE usuario_insert = pUsuario;


		ELIF ePlaza <> '000' AND eSucursal <> '0000' AND eStatus = '00'  THEN
			FOREACH
				SELECT {+ INDEX(bdisuc:ss_operaciones idx01ss_operaciones),INDEX (bdisuc:ss_proveedores idx01ss_proveedores)} b.folio_oper,b.sucursal,b.folio_sucursal,b.fecha_solicitud,b.usuario_solicitud,
					b.fecha_envio,b.usuario_envio,b.fecha_recepcion,b.usuario_recepcion,b.monto,b.fecha_reversion,
					b.usuario_reversion , c.descripcion, b.status
					INTO  vFolOper,vSucursal,vFolSuc,vFecSol,vUsuarioSol,
					vFecEnvio,vUsuarioEnv,vFecRecepcion,vUsuarioRecep,vMonto,vFecRever,
					vUsuarioRever,vCodProveedor,eStatus                          
					FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores  c
					WHERE a.cod_trans != '0'                      
					AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin 
					AND a.sucursal = eSucursal
					AND a.reversado IN ('0','1')
					AND a.folio_oper    = b.folio_oper   
					AND c.cod_proveedor = b.cod_proveedor 
					ORDER BY b.fecha_solicitud ASC

					SELECT nombre INTO vNomSuc FROM bdinteg:"informix".si_sucursales WHERE sucursal = vSucursal AND empresa = eEmpresa;
					SELECT nombre INTO vNomUsuRever FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = vUsuarioRever;
					SELECT descripcion INTO vDesStatus FROM bdisuc:"informix".ss_catstatus WHERE status = eStatus;
					SELECT descripcion INTO vNomPlaza FROM bdinteg:"informix".si_plazas_cajagen WHERE codigo_plaza = ePlaza AND empresa = eEmpresa;

					LET vSucursal = vSucursal ||' '|| vNomSuc;
					LET vUsuarioSol = vUsuarioSol || ' ' ||vNomUsuSol;
					LET vUsuarioEnv = vUsuarioEnv || ' '|| vNomUsuEnv;
					LET vUsuarioRecep = vUsuarioRecep || ' ' || vNomUsuRecep;
					LET vUsuarioRever = vUsuarioRever || ' '|| vNomUsuRever;
							
					LET iNumRegistros = iNumRegistros + 1;
							
					INSERT INTO bdicnweb:"informix".tmp_entradasalida
					(codproveedor,foloper,desstatus,sucursal,folsuc,fecsol,usuariosol,fecenvio,usuarioenv,fecrecepcion,
					usuariorecep,monto,fecrever,vusuariorever,empresa,nomplaza,tipo_suc,id_usuario) 
					VALUES (vCodProveedor,vFolOper,vDesStatus,vSucursal,vFolSuc,vFecSol,vUsuarioSol,vFecEnvio,vUsuarioEnv,vFecRecepcion,
					vUsuarioRecep,vMonto,vFecRever,vUsuarioRever,eEmpresa,vNomPlaza,eTipo,pUsuario);

			END FOREACH;
				   
			IF iNumRegistros = 0 THEN
				LET vCodRet = '00017';
				UPDATE {+INDEX (bdicnweb:sw_verificastatusentradasalida idx_sw_verificastatusentradasalida)} bdicnweb:"informix".sw_verificastatusentradasalida
				SET status = 'E', error_proceso = 'S', error = vCodRet WHERE usuario_insert = pUsuario;
			END IF;	
		
			UPDATE {+INDEX (bdicnweb:sw_verificastatusentradasalida idx_sw_verificastatusentradasalida)} bdicnweb:"informix".sw_verificastatusentradasalida
			SET status = 'T', error_proceso = 'N', num_registros = iNumRegistros WHERE usuario_insert = pUsuario;

		ELIF ePlaza <> '000' AND eSucursal <> '0000' AND eStatus <> '00' THEN
			FOREACH
				SELECT {+ INDEX(bdisuc:ss_operaciones idx01ss_operaciones),INDEX (bdisuc:ss_proveedores idx01ss_proveedores)} b.folio_oper,b.sucursal,b.folio_sucursal,b.fecha_solicitud,b.usuario_solicitud,
					b.fecha_envio,b.usuario_envio,b.fecha_recepcion,b.usuario_recepcion,b.monto,b.fecha_reversion,
					b.usuario_reversion,c.descripcion, b.status
					INTO  vFolOper,vSucursal,vFolSuc,vFecSol,vUsuarioSol,
					vFecEnvio,vUsuarioEnv,vFecRecepcion,vUsuarioRecep,vMonto,vFecRever,
					vUsuarioRever,vCodProveedor,eStatus
					FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores  c
					WHERE a.cod_trans != '0'                      
					AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin 
					AND a.sucursal = eSucursal
					AND a.reversado IN ('0','1')
					AND a.folio_oper    = b.folio_oper   
					AND c.cod_proveedor = b.cod_proveedor 
					AND b.status        = eStatus
					ORDER BY b.fecha_solicitud ASC

					SELECT nombre INTO vNomSuc FROM bdinteg:"informix".si_sucursales WHERE sucursal = vSucursal AND empresa = eEmpresa;
					SELECT nombre INTO vNomUsuRever FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = vUsuarioRever;
					SELECT descripcion INTO vDesStatus FROM bdisuc:"informix".ss_catstatus WHERE status = eStatus;
					SELECT descripcion INTO  vNomPlaza FROM bdinteg:"informix".si_plazas_cajagen WHERE codigo_plaza = ePlaza AND empresa = eEmpresa;

					LET vSucursal = vSucursal ||' '|| vNomSuc;
					LET vUsuarioSol = vUsuarioSol || ' ' ||vNomUsuSol;
					LET vUsuarioEnv = vUsuarioEnv || ' '|| vNomUsuEnv;
					LET vUsuarioRecep = vUsuarioRecep || ' ' || vNomUsuRecep;
					LET vUsuarioRever = vUsuarioRever || ' '|| vNomUsuRever;
							
					LET iNumRegistros = iNumRegistros + 1;
							
					INSERT INTO bdicnweb:"informix".tmp_entradasalida
					(codproveedor,foloper,desstatus,sucursal,folsuc,fecsol,usuariosol,fecenvio,usuarioenv,fecrecepcion,
					usuariorecep,monto,fecrever,vusuariorever,empresa,nomplaza,tipo_suc,id_usuario) 
					VALUES (vCodProveedor,vFolOper,vDesStatus,vSucursal,vFolSuc,vFecSol,vUsuarioSol,vFecEnvio,vUsuarioEnv,vFecRecepcion,
					vUsuarioRecep,vMonto,vFecRever,vUsuarioRever,eEmpresa,vNomPlaza,eTipo,pUsuario);

			END FOREACH;
				   
			IF iNumRegistros = 0 THEN
				LET vCodRet = '00017';
				UPDATE {+INDEX (bdicnweb:sw_verificastatusentradasalida idx_sw_verificastatusentradasalida)} bdicnweb:"informix".sw_verificastatusentradasalida
				SET status = 'E', error_proceso = 'S', error = vCodRet WHERE usuario_insert = pUsuario;
			END IF;	
		
			UPDATE {+INDEX (bdicnweb:sw_verificastatusentradasalida idx_sw_verificastatusentradasalida)} bdicnweb:"informix".sw_verificastatusentradasalida
			SET status = 'T', error_proceso = 'N', num_registros = iNumRegistros WHERE usuario_insert = pUsuario;

		ELIF ePlaza <> '000' AND eSucursal = '0000' AND eStatus <> '00' THEN
			FOREACH
				SELECT {+ INDEX(bdisuc:ss_operaciones idx01ss_operaciones),INDEX (bdisuc:ss_proveedores idx01ss_proveedores)} b.folio_oper,b.sucursal,b.folio_sucursal,b.fecha_solicitud,b.usuario_solicitud,
					b.fecha_envio,b.usuario_envio,b.fecha_recepcion,b.usuario_recepcion,b.monto,b.fecha_reversion,
					b.usuario_reversion ,c.descripcion, b.status
					INTO  vFolOper,vSucursal,vFolSuc,vFecSol,vUsuarioSol,
					vFecEnvio,vUsuarioEnv,vFecRecepcion,vUsuarioRecep,vMonto,vFecRever,
					vUsuarioRever,vCodProveedor,eStatus
					FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores  c
					WHERE a.cod_trans != '0'                      
					AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin 
					AND a.sucursal IN (SELECT sucursal 
										FROM bdinteg:"informix".si_sucursales  
										WHERE sucursal != '0' 
										AND empresa = eEmpresa
										AND plaza_cajagen = ePlaza 
										AND tpo_sucursal = eTipo)
					AND a.reversado IN ('0','1')
					AND a.folio_oper    = b.folio_oper   
					AND c.cod_proveedor = b.cod_proveedor 
					AND b.status        = eStatus
					ORDER BY b.fecha_solicitud ASC

					SELECT nombre INTO vNomSuc FROM bdinteg:"informix".si_sucursales WHERE sucursal = vSucursal AND empresa = eEmpresa;
					SELECT nombre INTO vNomUsuRever FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = vUsuarioRever;
					SELECT descripcion INTO vDesStatus FROM bdisuc:"informix".ss_catstatus WHERE status = eStatus;
					SELECT descripcion INTO vNomPlaza FROM bdinteg:"informix".si_plazas_cajagen WHERE codigo_plaza = ePlaza AND empresa = eEmpresa;

					LET vSucursal = vSucursal ||' '|| vNomSuc;
					LET vUsuarioSol = vUsuarioSol || ' ' ||vNomUsuSol;
					LET vUsuarioEnv = vUsuarioEnv || ' '|| vNomUsuEnv;
					LET vUsuarioRecep = vUsuarioRecep || ' ' || vNomUsuRecep;
					LET vUsuarioRever = vUsuarioRever || ' '|| vNomUsuRever;
							
					LET iNumRegistros = iNumRegistros + 1;
							
					INSERT INTO bdicnweb:"informix".tmp_entradasalida
					(codproveedor,foloper,desstatus,sucursal,folsuc,fecsol,usuariosol,fecenvio,usuarioenv,fecrecepcion,
					usuariorecep,monto,fecrever,vusuariorever,empresa,nomplaza,tipo_suc,id_usuario) 
					VALUES (vCodProveedor,vFolOper,vDesStatus,vSucursal,vFolSuc,vFecSol,vUsuarioSol,vFecEnvio,vUsuarioEnv,vFecRecepcion,
					vUsuarioRecep,vMonto,vFecRever,vUsuarioRever,eEmpresa,vNomPlaza,eTipo,pUsuario);

			END FOREACH;
				 
			IF iNumRegistros = 0 THEN
				LET vCodRet = '00017';
				UPDATE {+INDEX (bdicnweb:sw_verificastatusentradasalida idx_sw_verificastatusentradasalida)} bdicnweb:"informix".sw_verificastatusentradasalida
				SET status = 'E', error_proceso = 'S', error = vCodRet WHERE usuario_insert = pUsuario;
			END IF;	
		
			UPDATE {+INDEX (bdicnweb:sw_verificastatusentradasalida idx_sw_verificastatusentradasalida)} bdicnweb:"informix".sw_verificastatusentradasalida
			SET status = 'T', error_proceso = 'N', num_registros = iNumRegistros WHERE usuario_insert = pUsuario;

		ELSE
			IF eMes <> '' AND eAnio <> '' THEN
				FOREACH
					SELECT {+ INDEX(bdisuc:ss_operaciones idx01ss_operaciones),INDEX (bdisuc:ss_proveedores idx01ss_proveedores)} b.folio_oper,b.sucursal,b.folio_sucursal,b.fecha_solicitud,b.usuario_solicitud,
					b.fecha_envio,b.usuario_envio,b.fecha_recepcion,b.usuario_recepcion,b.monto,b.fecha_reversion,
					b.usuario_reversion ,c.descripcion, b.status
					INTO  vFolOper,vSucursal,vFolSuc,vFecSol,vUsuarioSol,
					vFecEnvio,vUsuarioEnv,vFecRecepcion,vUsuarioRecep,vMonto,vFecRever,
					vUsuarioRever,vCodProveedor,eStatus
					FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores  c
					WHERE a.cod_trans != '0'                      
					AND (MONTH(a.fecha_operacion) = eMes AND YEAR(a.fecha_operacion) = eAnio)
					AND a.sucursal IN (SELECT sucursal 
										FROM bdinteg:"informix".si_sucursales  
										WHERE sucursal != '0'
										AND empresa = eEmpresa
										AND (tpo_sucursal = eTipo OR  tpo_sucursal = vCajGen))
					AND a.reversado IN ('0','1')
					AND a.folio_oper    = b.folio_oper   
					AND c.cod_proveedor = b.cod_proveedor 
					ORDER BY b.fecha_solicitud ASC


					SELECT nombre, plaza_cajagen INTO vNomSuc, ePlaza FROM bdinteg:"informix".si_sucursales WHERE sucursal = vSucursal AND empresa = eEmpresa;
					SELECT nombre INTO vNomUsuSol FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = vUsuarioSol;
					SELECT nombre INTO vNomUsuEnv FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = vUsuarioEnv;
					SELECT nombre INTO vNomUsuRecep FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = vUsuarioRecep;
					SELECT nombre INTO vNomUsuRever FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = vUsuarioRever;
					SELECT descripcion INTO vDesStatus FROM bdisuc:"informix".ss_catstatus WHERE status = eStatus;                          
					SELECT descripcion INTO vNomPlaza FROM bdinteg:"informix".si_plazas_cajagen WHERE codigo_plaza = ePlaza AND empresa = eEmpresa;

					LET vSucursal = vSucursal ||' '|| vNomSuc;
					LET vUsuarioSol = vUsuarioSol || ' ' ||vNomUsuSol;
					LET vUsuarioEnv = vUsuarioEnv || ' '|| vNomUsuEnv;
					LET vUsuarioRecep = vUsuarioRecep || ' ' || vNomUsuRecep;
					LET vUsuarioRever = vUsuarioRever || ' '|| vNomUsuRever;
							
					LET iNumRegistros = iNumRegistros + 1;
							
					INSERT INTO bdicnweb:"informix".tmp_entradasalida
					(codproveedor,foloper,desstatus,sucursal,folsuc,fecsol,usuariosol,fecenvio,usuarioenv,fecrecepcion,
					usuariorecep,monto,fecrever,vusuariorever,empresa,nomplaza,tipo_suc,id_usuario) 
					VALUES (vCodProveedor,vFolOper,vDesStatus,vSucursal,vFolSuc,vFecSol,vUsuarioSol,vFecEnvio,vUsuarioEnv,vFecRecepcion,
					vUsuarioRecep,vMonto,vFecRever,vUsuarioRever,eEmpresa,vNomPlaza,eTipo,pUsuario);

				END FOREACH;
					   
				IF iNumRegistros = 0 THEN
					LET vCodRet = '00017';
					UPDATE {+INDEX (bdicnweb:sw_verificastatusentradasalida idx_sw_verificastatusentradasalida)} bdicnweb:"informix".sw_verificastatusentradasalida
					SET status = 'E', error_proceso = 'S', error = vCodRet WHERE usuario_insert = pUsuario;
				END IF;	
		
				UPDATE {+INDEX (bdicnweb:sw_verificastatusentradasalida idx_sw_verificastatusentradasalida)} bdicnweb:"informix".sw_verificastatusentradasalida
				SET status = 'T', error_proceso = 'N', num_registros = iNumRegistros WHERE usuario_insert = pUsuario;
					   
			END IF;
		END IF;
  
		
		RETURN vCodRet, iNumRegistros;


	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 05/02/2020',
'DESCRIPCION: SPL que realiza la consulta para el llenado de la tabla temporal de entradas y salidas, Consultas Entrada Salida Caja General',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_faltsob_ofi_web(pempresa CHAR(3),
		psucursal CHAR(4),
		pcajeroprincipal CHAR(8),
        pfolio_suc char(16),
  		ptransaccion char(4),
		pdivisa CHAR(2),
		pmonto money(14,2),
        pfecha date,
		pdeno1 CHAR(18),
		pdeno2 CHAR(18),
		pdeno3 CHAR(18),
		pdeno4 CHAR(18),
        pdeno5 CHAR(18),
		pdeno6 CHAR(18),
		pdeno7 CHAR(18),
		pdeno8 CHAR(18),
		pdeno9 CHAR(18),
		pdeno10 CHAR(18),
        pdeno11 CHAR(18),
		pdeno12 CHAR(18),
		pdeno13 CHAR(18),
		pdeno14 CHAR(18),
		pdeno15 CHAR(18),
		pcant1 float(8),
		pcant2 float(8),
		pcant3 float(8),
		pcant4 float(8),
		pcant5 float(8),
		pcant6 float(8),
		pcant7 float(8),
		pcant8 float(8),
		pcant9 float(8),
        pcant10 float(8),
		pcant11 float(8),
		pcant12 float(8),
		pcant13 float(8),
		pcant14 float(8),
		pcant15 float(8), 
        poperacion smallint)
RETURNING CHAR(5),char(8);

DEFINE vcodret CHAR(5);
DEFINE vfolio char(8);
DEFINE vsqlerr,visamerr INTEGER;
DEFINE vhora char(5);
DEFINE vproveedor char(4);
DEFINE vplaza char(3);
DEFINE vnum char(8);

LET vcodret = "00000";
LET vproveedor = "";
LEt vplaza = "";
LET vhora = substr(current,12,5);
LET vnum = 0;
LET vfolio = "";
	BEGIN
		ON EXCEPTION SET vsqlerr,visamerr
		   IF vsqlerr != 0 THEN
			  LET vcodret=vsqlerr;
			  RETURN vcodret,vfolio;
		   END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--SET debug file to "/tmp/sp_faltsob.out";
		--trace on;

		--- Verifica recepcion correcta de datos
		IF pempresa = '0' OR pempresa = '' OR psucursal = '0' OR psucursal = '' OR
		   pdivisa = '0' OR pdivisa = ''  OR pcajeroprincipal = '0' OR pcajeroprincipal = ''
		   OR pfolio_suc = '0' OR pfolio_suc = '' OR ptransaccion = '0' OR ptransaccion = ''
		   OR pmonto = 0 THEN
		   LET vcodret = "00110";
		ELSE

			SELECT plaza_cajagen INTO vplaza
			FROM   bdinteg:si_sucursales
			WHERE  sucursal = psucursal;

			SELECT cod_proveedor INTO vproveedor
			FROM   ss_proveedores
			WHERE  plaza = vplaza;

			IF (SELECT count(cod_proveedor) FROM ss_proveedores WHERE cod_proveedor = vproveedor) > 0 THEN
			   IF poperacion != 0 AND poperacion != 1 THEN
				  LET vcodret = "00106";       
			   ELSE 

				SELECT valor
				  INTO vnum
				  FROM bdisuc:"informix".ss_param_cajagen
				 WHERE  codigo = '0005';

				UPDATE bdisuc:"informix".ss_param_cajagen
				   SET  valor = valor + 1
				 WHERE  codigo = '0005';
						
				   LET vfolio = LPAD(ROUND(vnum),8,"0");
			   
				  INSERT INTO ss_operaciones
							 (empresa,cod_trans,fecha_operacion,sucursal,folio_sucursal,folio_oper,reversado,usuario,divisa,monto,procedencia,
							  denominacion_1,denominacion_2,denominacion_3,denominacion_4,denominacion_5,denominacion_6,
							  denominacion_7,denominacion_8,denominacion_9,denominacion_10,denominacion_11,denominacion_12,
							  denominacion_13,denominacion_14,denominacion_15,cantidad_1,cantidad_2,cantidad_3,cantidad_4,
							  cantidad_5,cantidad_6,cantidad_7,cantidad_8,cantidad_9,cantidad_10,cantidad_11,cantidad_12,
							  cantidad_13,cantidad_14,cantidad_15)
				  VALUES
						 (pempresa,ptransaccion,pfecha,psucursal,pfolio_suc,vfolio,'0',pcajeroprincipal,pdivisa,pmonto,psucursal,
						  pdeno1,pdeno2,pdeno3,pdeno4,pdeno5,pdeno6,pdeno7,pdeno8,pdeno9,pdeno10,pdeno11,pdeno12,
					  pdeno13,pdeno14,pdeno15,pcant1,pcant2,pcant3,pcant4,pcant5,pcant6,pcant7,pcant8,pcant9,
					  pcant10,pcant11,pcant12,pcant13,pcant14,pcant15);
				 
				   IF poperacion = 1 THEN    
					  UPDATE ss_atm set cantidad_1 = cantidad_1 + pcant1, cantidad_2 = cantidad_2 + pcant2, 
												cantidad_3 = cantidad_3 + pcant3, cantidad_4 = cantidad_4 + pcant4,
												cantidad_5 = cantidad_5 + pcant5, cantidad_6 = cantidad_6 + pcant6,
												cantidad_7 = cantidad_7 + pcant7,
												cantidad_8 = cantidad_8 + pcant8,
												cantidad_9 = cantidad_9 + pcant9,
												cantidad_10 = cantidad_10 + pcant10,
												saldo_anterior = saldo_total,
												saldo_total =  saldo_total + pmonto
												  
					  WHERE  cod_atm = psucursal;
		 
				   ELSE
					  UPDATE ss_atm set cantidad_1 = cantidad_1 - pcant1, 
										cantidad_2 = cantidad_2 - pcant2,
										cantidad_3 = cantidad_3 - pcant3, 
										cantidad_4 = cantidad_4 - pcant4,
										cantidad_5 = cantidad_5 - pcant5, 
										cantidad_6 = cantidad_6 - pcant6,
												cantidad_7 = cantidad_7 - pcant7,
												cantidad_8 = cantidad_8 - pcant8,
												cantidad_9 = cantidad_9 - pcant9,
												cantidad_10 = cantidad_10 - pcant10,
										saldo_anterior = saldo_total,
										saldo_total =  saldo_total - pmonto
					  WHERE  cod_atm = psucursal;
		 

				   END IF; 

			   END IF; 
			ELSE

		   let vcodret = "00105";
		   return vcodret,vfolio;

		   END IF;
		END IF;

	RETURN vcodret,vfolio;
	END;
END PROCEDURE;