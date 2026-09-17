CREATE PROCEDURE "informix".sp_insertactualizacentrocostos	(iTipoRegistro INTEGER,pUser_Insert VARCHAR(30),pEmpresa VARCHAR(3),
pTelex VARCHAR(20),pDireccion2 VARCHAR(40),	pNombre VARCHAR(40),pTpo_sucursal VARCHAR(2),pSucursal VARCHAR(4),pSubger VARCHAR(40),
pGerente VARCHAR(40),pPlaza VARCHAR(3),pImpresora VARCHAR(8),pDias_Laborables INTEGER,pIva DECIMAL(5,3),pSal_Min_Pza DECIMAL(14,2),
pFactor_Rem_Sbc DECIMAL(10,5),pMonto_Min_Sbc DECIMAL(14,2),pFactor_Remesas DECIMAL(9,6),pMonto_Minimo DECIMAL(10,2),pMto_Max_Efect MONEY,
pMto_Min_Efect MONEY,pTipo CHAR(1),pCom_consulta DECIMAL(5,2),pCom_retiro DECIMAL(5,2),pCorreo VARCHAR(120),pTipo_bovsuc VARCHAR(3),
pHorario VARCHAR(12),pDispensa_Baja CHAR(1),pServicio_Canje CHAR(1),pTipo_Acceso CHAR(1),pTel2 VARCHAR(14),pTel1 VARCHAR(14),
pcriterio_com VARCHAR(5),pNum_int VARCHAR(5),pReferencia VARCHAR(120),pNum_ext VARCHAR(6),pCalle VARCHAR(100),pLongitud VARCHAR(11),
pCve_col CHAR(8),pLatitud VARCHAR(10),pCve_localidad CHAR(14),pCve_mun CHAR(3),pCp CHAR(5),pCve_ciudad CHAR(3),pCve_estado CHAR(2),
pCve_pais CHAR(3),pClave_sit CHAR(3),pFecha_sit DATE/*,ptipon char(1)*/) 											

-------------------------------------------------------------------------------------------------
--AUTOR: 98633775-EVER FIERRO HERNANDEZ															-
--FOLIO: 601																					-
--DESCRIPCION: Inserta y Actualiza la tabla si_sucursales y si_ptf con los parametros recibidos	-
--FECHA: 20/07/2019																				-
--SOLICITO: Ricardo Resendiz																	-
--BD: BDINTEG																					-
-------------------------------------------------------------------------------------------------

RETURNING CHAR(5) AS CodRet;

	--DEFINE VARIABLES
   DEFINE cCodRet CHAR(5);
   DEFINE iSqlErr	INTEGER;
   DEFINE cExTpoSuc	CHAR(1);
   
	--INICIALIZA VARIABLES
	LET cCodRet = '00002';
	LET iSqlErr	= 0;
	LET cExTpoSuc = '';
	
BEGIN
	-- ERRORES DE INFORMIX
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			ROLLBACK WORK;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

   -- SET DEBUG FILE TO '/informix/RRM/sp_centrocostos.out';
   -- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--VALIDA PARAMETROS
	IF NVL(pEmpresa,'') = '' OR NVL(pNombre,'') = '' OR NVL(pSucursal,'') = '' OR NVL(pGerente,'') = '' OR NVL(pDias_Laborables,'') = '' OR NVL(pIva,'') = '' OR NVL(pSal_Min_Pza,'') = '' OR NVL(pFactor_Rem_Sbc,'') = '' OR NVL(pMonto_Min_Sbc,'') = '' OR NVL(pFactor_Remesas,'') = '' OR NVL(pMonto_Minimo,'') = '' OR NVL(pMto_Max_Efect,'') = '' OR NVL(pMto_Min_Efect,'') = '' THEN
	
		LET cCodRet='00001';		RETURN cCodRet;
	END IF;
	
	IF iTipoRegistro = 1 THEN
		SELECT a.tipo INTO cExTpoSuc FROM bdinteg:"informix".si_sucursales a, bdinteg:"informix".si_ptf b 
		WHERE a.sucursal = b.id_ptf 
		AND a.tipo = b.tipo 
		AND a.sucursal = pSucursal;
		BEGIN WORK;			
			IF cExTpoSuc <> pTipo THEN
				UPDATE bdinteg:"informix".si_sucursales 
				SET user_insert = pUser_Insert,empresa = pEmpresa,telex = pTelex,direccion2 = pDireccion2,nombre = pNombre,Tpo_sucursal =pTpo_sucursal,fecha_insert = pFecha_sit,subger = pSubger,gerente = pGerente,plaza = pPlaza,impresora = pImpresora,dias_laborables = pDias_Laborables,iva = pIva,sal_min_pza = pSal_Min_Pza,factor_rem_sbc = pFactor_Rem_Sbc,monto_min_sbc = pMonto_Min_Sbc,factor_remesas = pFactor_Remesas,monto_minimo = pMonto_Minimo,mto_max_efect = pMto_Max_Efect,mto_min_efect = pMto_Min_Efect,tipo = pTipo --RRM
				WHERE sucursal = pSucursal 
				AND tipo = cExTpoSuc;
				
				IF DBINFO("sqlca.sqlerrd2") > 0 THEN
					UPDATE bdinteg:"informix".si_ptf 
					SET	com_consulta = pCom_consulta,com_retiro = pCom_retiro,correo = pCorreo,tipo_bovsuc = pTipo_bovsuc,horario = pHorario,dispensa_Baja = pDispensa_Baja,servicio_Canje = pServicio_Canje,tipo_Acceso = pTipo_Acceso,tel2 = pTel2,tel1 = pTel1,id_ptf = pSucursal,tipo = pTipo/*RRM*/,criterio_com = pcriterio_com,num_int = pNum_int,referencia = pReferencia,num_ext = pNum_ext,calle = pCalle,longitud = pLongitud,cve_col = pCve_col,latitud = pLatitud,cve_localidad = pCve_localidad,cve_mun = pCve_mun,cp = pCp,cve_ciudad = pCve_ciudad,cve_estado = pCve_estado,cve_pais = pCve_pais,clave_sit = pClave_sit,fecha_sit = pFecha_sit
					WHERE id_ptf = pSucursal /*JMMO*/ 
					AND tipo = cExTpoSuc;
				
					IF DBINFO("sqlca.sqlerrd2") > 0 THEN
						COMMIT WORK;
						LET cCodRet = '00000';
					END IF;	
				END IF;
			ELSE
				UPDATE bdinteg:"informix".si_sucursales 
				SET user_insert = pUser_Insert,empresa = pEmpresa,telex = pTelex,direccion2 = pDireccion2,nombre = pNombre,Tpo_sucursal = pTpo_sucursal,fecha_insert = pFecha_sit,subger = pSubger,gerente = pGerente,plaza = pPlaza,impresora = pImpresora,dias_laborables = pDias_Laborables,iva = pIva,sal_min_pza = pSal_Min_Pza,factor_rem_sbc = pFactor_Rem_Sbc,monto_min_sbc = pMonto_Min_Sbc,factor_remesas = pFactor_Remesas,monto_minimo = pMonto_Minimo,mto_max_efect = pMto_Max_Efect,mto_min_efect = pMto_Min_Efect,tipo = pTipo --RRM
				WHERE sucursal = pSucursal 
				AND tipo = pTipo;
				
				IF DBINFO("sqlca.sqlerrd2") > 0 THEN
					UPDATE bdinteg:"informix".si_ptf 
					SET	com_consulta = pCom_consulta,com_retiro = pCom_retiro,correo = pCorreo,tipo_bovsuc = pTipo_bovsuc,horario = pHorario,dispensa_Baja = pDispensa_Baja,servicio_Canje = pServicio_Canje,tipo_Acceso = pTipo_Acceso,tel2 = pTel2,tel1 = pTel1,id_ptf = pSucursal,tipo = pTipo/*RRM*/,criterio_com = pcriterio_com,num_int = pNum_int,referencia = pReferencia,num_ext = pNum_ext,calle = pCalle,longitud = pLongitud,cve_col = pCve_col,latitud = pLatitud,cve_localidad = pCve_localidad,cve_mun = pCve_mun,cp = pCp,cve_ciudad = pCve_ciudad,cve_estado = pCve_estado,cve_pais = pCve_pais,clave_sit = pClave_sit,fecha_sit = pFecha_sit
					WHERE id_ptf = pSucursal /*JMMO*/ 
					AND tipo = pTipo;
				
					IF DBINFO("sqlca.sqlerrd2") > 0 THEN
						COMMIT WORK;
						LET cCodRet = '00000';
					END IF;	
				END IF;
			END IF;			
		IF cCodRet <> '00000' THEN
			ROLLBACK WORK;
		END IF;
	END IF;
	
	IF iTipoRegistro = 0 THEN
		BEGIN WORK;
			INSERT INTO bdinteg:"informix".si_sucursales(user_insert,empresa,telex,direccion2,nombre,Tpo_sucursal,sucursal,fecha_insert,subger,gerente,plaza,impresora,dias_laborables,iva,sal_min_pza,factor_rem_sbc,monto_min_sbc,factor_remesas,monto_minimo,mto_max_efect,mto_min_efect,tipo)
			VALUES(pUser_Insert,pEmpresa,pTelex,pDireccion2,pNombre,pTpo_sucursal,pSucursal,pFecha_sit,pSubger,pGerente,pPlaza,pImpresora,pDias_Laborables,pIva,pSal_Min_Pza,pFactor_Rem_Sbc,pMonto_Min_Sbc,pFactor_Remesas,pMonto_Minimo,pMto_Max_Efect,pMto_Min_Efect,pTipo);
			
			IF DBINFO("sqlca.sqlerrd2") > 0 THEN
				INSERT INTO bdinteg:"informix".si_ptf(id_ptf,com_consulta,com_retiro,correo,tipo_bovsuc,horario,dispensa_Baja,servicio_Canje,tipo_Acceso,tel2,tel1,tipo,criterio_com,num_int,referencia,num_ext,calle,longitud,cve_col,latitud,cve_localidad,cve_mun,cp,cve_ciudad,cve_estado,cve_pais,clave_sit,fecha_sit)
				VALUES(pSucursal,pCom_consulta,pCom_retiro,pCorreo,pTipo_bovsuc,pHorario,pDispensa_Baja,pServicio_Canje,pTipo_Acceso,pTel2,pTel1,pTipo,pcriterio_com,pNum_int,pReferencia,pNum_ext,pCalle,pLongitud,pCve_col,pLatitud,pCve_localidad,pCve_mun,pCp,pCve_ciudad,pCve_estado,pCve_pais,pClave_sit,pFecha_sit);
			
				IF DBINFO("sqlca.sqlerrd2") > 0 THEN
					COMMIT WORK;
					LET cCodRet = '00000';
				END IF;
			END IF;
		IF cCodRet <> '00000' THEN
			ROLLBACK WORK;
		END IF;
	END IF;
	
	RETURN cCodRet;
END;
END PROCEDURE;