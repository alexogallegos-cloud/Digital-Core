CREATE PROCEDURE "informix".sp_replica_usuarios_db2_trigger(pEvento CHAR(1), 
                                                            pEjecutivo CHAR(8), 
                                                            pSucursal CHAR(4))
--DEFINICION DE VARIABLES--
DEFINE  cCodRet 		CHAR(5);
DEFINE  iSqlErr			INTEGER;
DEFINE  vCheckSuc       CHAR(4);
DEFINE  cValor			INTEGER;
--INICIALIZACION DE VARIABLES--
LET cCodRet 		= '00000';
LET iSqlErr			= 0;
LET vCheckSuc       = '';   
LET cValor			= 0;

BEGIN
 
ON EXCEPTION SET iSqlErr
	   IF (iSqlErr != 0) THEN
		  LET cCodRet = iSqlErr;
          Rollback;
		END IF;
END EXCEPTION;

IF pEvento IS NULL OR Trim(pEvento) = '' THEN
       LET cCodRet  = '00001';
END IF;

IF pEjecutivo IS NULL OR Trim(pEjecutivo) = '' THEN
       LET cCodRet  = '00001';
END IF;

IF pSucursal IS NULL OR Trim(pSucursal) = '' THEN
       LET cCodRet  = '00001';
END IF;
    
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

IF pSucursal = '0800' THEN
	SELECT sucursal 
	INTO vCheckSuc
	FROM bdinteg:si_sucursales 
	WHERE sucursal = pSucursal;
ELSE
	SELECT sucursal 
	INTO vCheckSuc
	FROM si_sucursales 
	WHERE sucursal = pSucursal AND tpo_sucursal = 'S';
END IF

SELECT 1 
INTO cValor
FROM si_ejecut_replica_db2 
where ejecutivo = pEjecutivo;

IF TRIM(vCheckSuc) = '' THEN
    LET cCodRet  = '00001';
END IF;
    
                     IF pEvento = '1' THEN
                     INSERT INTO si_ejecut_replica_db2(empresa,
                                    sucursal,
                                    ejecutivo,
                                    perfil,
                                    fecha_alta,
                                    fecha_ult_cambio,
                                    nombre_usuario,
                                    cajero_certifi,
                                    cajero_en_linea,
                                    cajero_privilegio,
                                    cajero_apertura,
                                    sesion,
                                    cajero_monto_min,
                                    cajero_monto_max,
                                    cajero_cierre_est,
                                    cajero_cierre_dia,
                                    mac_address,
                                    ipmicro,
                                    edo_usuario,
                                    nombramiento,
                                    fecha_insert,
                                    fecha_modif,
                                    tipo_evento)
					SELECT ej.EMPRESA, ej.SUCURSAL, ej.EJECUTIVO, 
							 CASE
						  WHEN ej.puesto = '001' THEN "A"
						  WHEN ej.puesto = '002' THEN "O"
						  WHEN ej.puesto = '003' THEN "E"
						  WHEN ej.puesto = '004' THEN "R"
						  WHEN ej.puesto = '005' THEN "Z"
						  WHEN ej.puesto = '008' THEN "U"
						  WHEN ej.puesto = '010' THEN "N"
						  WHEN ej.puesto = '011' THEN "O"
						  WHEN ej.puesto = '012' THEN "E" 
						  WHEN ej.puesto = '013' THEN "R"
						  WHEN ej.puesto = '014' THEN "A"
						  WHEN ej.puesto = '015' THEN "E"
						  
						  ELSE NULL
					   END AS PERFIL, 
									TODAY as FECHA_ALTA, TODAY as FECHA_ULT_CAMBIO, NOMBRE, 
									'0' as CAJERO_CERTIFI,'0' as CAJERO_EN_LINEA,'0' as CAJERO_PRIVILEGIO,
									'0' as CAJERO_APERTURA,'0' as SESION, '5000' as CAJERO_MONTO_MIN,
									'60000' as CAJERO_MONTO_MAX, 0 as CAJERO_CIERRE_EST,0 as CAJERO_CIERRE_DIA,
									'' as  MAC_ADDRESS, '' as IPMICRO, 'ACTIVO' as EDO_USUARIO, 
									ej.nombramiento as NOMBRAMIENTO, today as FECHA_INSERT, 									
									current as FECHA_MODIF, 'A' as TIPO_EVENTO
					from si_ejecut ej
					where ej.empresa = '001'
					and   ej.ejecutivo = pEjecutivo
					and   ej.sucursal = (SELECT sucursal FROM si_sucursales WHERE sucursal = pSucursal);
          ELSE
               IF cValor > 0 THEN 
                   DELETE si_ejecut_replica_db2 where ejecutivo = pEjecutivo;
               END IF;

               INSERT INTO si_ejecut_replica_db2(empresa,
                                    sucursal,
                                    ejecutivo,
                                    perfil,
                                    fecha_alta,
                                    fecha_ult_cambio,
                                    nombre_usuario,
                                    cajero_certifi,
                                    cajero_en_linea,
                                    cajero_privilegio,
                                    cajero_apertura,
                                    sesion,
                                    cajero_monto_min,
                                    cajero_monto_max,
                                    cajero_cierre_est,
                                    cajero_cierre_dia,
                                    mac_address,
                                    ipmicro,
                                    edo_usuario,
                                    nombramiento,
                                    fecha_insert,
                                    fecha_modif,
                                    tipo_evento)
					SELECT ej.EMPRESA, ej.SUCURSAL, ej.EJECUTIVO, 
							 CASE
						  WHEN ej.puesto = '001' THEN "A"
						  WHEN ej.puesto = '002' THEN "O"
						  WHEN ej.puesto = '003' THEN "E"
						  WHEN ej.puesto = '004' THEN "R"
						  WHEN ej.puesto = '005' THEN "Z"
						  WHEN ej.puesto = '008' THEN "U"
						  WHEN ej.puesto = '010' THEN "N"
						  WHEN ej.puesto = '011' THEN "O"
						  WHEN ej.puesto = '012' THEN "E" 
						  WHEN ej.puesto = '013' THEN "R"
						  WHEN ej.puesto = '014' THEN "A"
						  WHEN ej.puesto = '015' THEN "E"
						  ELSE NULL
					   END AS PERFIL, 
									TODAY as FECHA_ALTA, TODAY as FECHA_ULT_CAMBIO, NOMBRE, 
									'0' as CAJERO_CERTIFI,'0' as CAJERO_EN_LINEA,'0' as CAJERO_PRIVILEGIO,
									'0' as CAJERO_APERTURA,'0' as SESION, '5000' as CAJERO_MONTO_MIN,
									'60000' as CAJERO_MONTO_MAX, 0 as CAJERO_CIERRE_EST,0 as CAJERO_CIERRE_DIA,
									'' as  MAC_ADDRESS, '' as IPMICRO, 
                             CASE
                             when ej.password like '%BAJA%'  then 'BAJA'
                             when ej.password <> 'BAJA'  then  'ACTIVO'
                             ELSE null
                             END AS EDO_USUARIO, 
									ej.nombramiento as NOMBRAMIENTO, today as FECHA_INSERT, 									
									current as FECHA_MODIF, 'C' as TIPO_EVENTO
					from si_ejecut ej
					where ej.empresa = '001'
					and   ej.ejecutivo = pEjecutivo
					and   ej.sucursal = (SELECT sucursal FROM si_sucursales WHERE sucursal = pSucursal);


            END IF;
        END;
END PROCEDURE;