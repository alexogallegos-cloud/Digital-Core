CREATE PROCEDURE "informix".sp_altaserv_edoctamov(pempresa CHAR(3), pnumcte CHAR(20),pcuenta CHAR(20),pproducto CHAR(4),pusuario CHAR(10),ptipo SMALLINT )
	RETURNING CHAR(6) AS CodRet,CHAR(20) AS Cuenta;

	DEFINE iSqlErr 		INTEGER;
	DEFINE cCodRetorno		CHAR(6);
	DEFINE sCuenta			CHAR(20);
	DEFINE iCantReg		INTEGER;
	 
	LET iSqlErr	 = 	0;
	LET cCodRetorno	 = 	'000000';
	LET sCuenta	 = '';
	LET iCantReg = 0;
	
	 
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/home/sysifx/OmarLerma/sp_altaserv_edoctamov.out";
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,'';
			END IF;
		END EXCEPTION;	
	
		
		IF TRIM(pempresa) = '' AND TRIM(pnumcte) = '' AND TRIM(pproducto) = '' AND TRIM(pusuario) = '' AND TRIM(pcuenta) = '' THEN
		
			LET cCodRetorno = '00002';				
			RETURN cCodRetorno,'';
			
		ELSE
		
			IF ptipo = 0 THEN		
												
				
				SELECT  DISTINCT(cuenta)
				INTO sCuenta
				FROM bdinteg: "informix".si_altaserv_edoctamov 
				WHERE empresa = pempresa AND cuenta = pcuenta;
				
				LET iCantReg = dbinfo("sqlca.sqlerrd2");
				
				IF iCantReg = 0 THEN
			
					LET sCuenta = '';	
					
				END IF;
				
				RETURN cCodRetorno,sCuenta;
	
			
				
			ELIF ptipo = 1 THEN
				
				INSERT INTO bdinteg: "informix".si_altaserv_edoctamov (empresa,numcte,cuenta,producto,fecha_cancel_servicio,user_modif) 
				VALUES (pempresa,pnumcte,pcuenta,pproducto,current,pusuario);
				
				LET iCantReg = dbinfo("sqlca.sqlerrd2");
				IF iCantReg = 0 THEN
	
					LET sCuenta = '';	
					LET cCodRetorno = '000004';
				END IF;
				
				RETURN cCodRetorno,'';
				
			ELIF ptipo = 2 THEN
			
				DELETE FROM bdinteg: "informix".si_altaserv_edoctamov 
				WHERE empresa = pempresa 
				AND numcte = pnumcte 
				AND cuenta = pcuenta;
				
				LET iCantReg = dbinfo("sqlca.sqlerrd2");
				IF iCantReg = 0 THEN
	
					LET sCuenta = '';	
					LET cCodRetorno = '000005';
				END IF;
						
				RETURN cCodRetorno,'';
				
			END IF;
			
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT
'FOLIO: 301-RQM 10 943 - ActivaciÃ³n y CancelaciÃ³n de envÃ­o por correo electrÃ³nico del Estado de Movimientos',
'AUTOR: Omar Lerma',
'FECHA: 22/09/2017',
'MODIFICACIÃN: SE CREA PROCEDIMIENTO PARA INSERTAR A LOS CLIENTES QUE CANCELEN EL SERVICIO',
'SOLICITA: CUTBERTO',
'DB:BDINTEG';

CREATE PROCEDURE "informix".sp_repejecutivo_db2()

RETURNING CHAR(5)     		AS CodRet,
		  VARCHAR(3)  		AS Empresa,
		  VARCHAR(4)  		AS Sucursal,
		  VARCHAR(8)  		AS Ejecutivo,
		  VARCHAR(1)  		AS Perfil,
		  CHAR(10)        	AS Fecha_alta,
		  CHAR(10)     		AS Fecha_ult_cambio,
		  VARCHAR(50) 	  	AS Nombre_usuario,
		  SMALLINT    		AS Cajero_certifi,
		  SMALLINT    		AS Cajero_en_linea,
		  SMALLINT    		AS Cajero_privilegio,
		  SMALLINT   		AS Cajero_apertura,
		  SMALLINT    		AS Sesion,
		  DECIMAL(16,2)     AS Cajero_monto_min,
		  DECIMAL(16,2)     AS Cajero_monto_max,
		  SMALLINT    		AS Cajero_cierre_est,
		  SMALLINT    		AS Cajero_cierre_dia,
		  VARCHAR(12)   	AS Mac_address,
		  VARCHAR(16)     	AS Ipmicro,
		  VARCHAR(20)    	AS Edo_usuario,
		  VARCHAR(20)    	AS Nombramiento,
		  CHAR(10)			AS Fecha_insert,
		  CHAR(10)        	AS Fecha_modif,
		  VARCHAR(5)    	AS Tipo_evento,
		  INTEGER			AS TotalReg;
		  
DEFINE cCodRet 				CHAR(5);
DEFINE iSqlError    	 	INTEGER;
DEFINE vEmpresa				VARCHAR(3);
DEFINE vSucursal			VARCHAR(4); 
DEFINE vEjecutivo			VARCHAR(8);  
DEFINE vPerfil				VARCHAR(1); 
DEFINE dFecha_alta			CHAR(10);
DEFINE dFecha_ult_cambio	CHAR(10);
DEFINE vNombre_usuario		VARCHAR(50); 
DEFINE sCajero_certifi		SMALLINT;
DEFINE sCajero_en_linea		SMALLINT;
DEFINE sCajero_privilegio	SMALLINT;
DEFINE sCajero_apertura		SMALLINT;
DEFINE sSesion				SMALLINT;
DEFINE dCajero_monto_min	DECIMAL(16,2);
DEFINE dCajero_monto_max	DECIMAL(16,2);
DEFINE sCajero_cierre_est	SMALLINT;
DEFINE sCajero_cierre_dia	SMALLINT;
DEFINE vMac_address			VARCHAR(12);
DEFINE vIpmicro				VARCHAR(16);
DEFINE vEdo_usuario			VARCHAR(20);
DEFINE vNombramiento		VARCHAR(20);
DEFINE dFecha_insert		CHAR(10);
DEFINE dFecha_modif			CHAR(10);
DEFINE vTipo_evento			VARCHAR(5);
DEFINE iTotalReg			INTEGER;

LET cCodRet     	       = '00001';
LET iSqlError   	       = 0;
LET vTipo_evento    	   = '';
LET vMac_address     	   = '';
LET vNombramiento          = '';
LET dFecha_modif           = '';
LET vEdo_usuario           = '';
LET dFecha_insert          = '';
LET vIpmicro               = '';
LET sCajero_cierre_dia     = '';
LET sCajero_cierre_est     = '';
LET dCajero_monto_max      = '';
LET dCajero_monto_min      = '';
LET sSesion                = '';
LET sCajero_apertura       = '';
LET sCajero_privilegio     = '';
LET sCajero_en_linea       = '';
LET sCajero_certifi        = '';
LET vNombre_usuario        = '';
LET dFecha_ult_cambio      = '';
LET dFecha_alta            = '';
LET vPerfil                = '';
LET vEjecutivo             = '';
LET vSucursal              = '';
LET vEmpresa               = '';
LET iTotalReg              = 0;

	--******************************************************* 
	--SET DEBUG FILE TO "/informix/sp_repejecutivo_db2.out";
	--TRACE ON;                                          
	--*******************************************************
BEGIN	
	ON EXCEPTION SET iSqlError
		IF iSqlError <> 0 THEN
			LET cCodRet = iSqlError;
			RETURN cCodRet,vEmpresa,vSucursal,vEjecutivo,vPerfil,dFecha_alta,dFecha_ult_cambio,vNombre_usuario,sCajero_certifi,sCajero_en_linea,sCajero_privilegio,sCajero_apertura,sSesion,dCajero_monto_min,dCajero_monto_max,sCajero_cierre_est,sCajero_cierre_dia,vMac_address,vIpmicro,vEdo_usuario,vNombramiento,dFecha_insert,dFecha_modif,vTipo_evento,iTotalReg;
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT;
		
		SELECT COUNT (ejecutivo) 
		INTO iTotalReg  
		FROM bdinteg:"informix".si_ejecut_replica_db2;
		
	    IF iTotalReg > 0 THEN
			FOREACH	
				SELECT empresa,sucursal,ejecutivo,perfil,fecha_alta,fecha_ult_cambio,nombre_usuario,cajero_certifi,cajero_en_linea,cajero_privilegio,cajero_apertura,sesion,cajero_monto_min,
				cajero_monto_max,cajero_cierre_est,cajero_cierre_dia,mac_address,ipmicro,edo_usuario,nombramiento,fecha_insert,fecha_modif,tipo_evento
				INTO vEmpresa,vSucursal,vEjecutivo,vPerfil,dFecha_alta,dFecha_ult_cambio,vNombre_usuario,sCajero_certifi,sCajero_en_linea,sCajero_privilegio,sCajero_apertura,sSesion,dCajero_monto_min,dCajero_monto_max,sCajero_cierre_est,sCajero_cierre_dia,vMac_address,vIpmicro,vEdo_usuario,vNombramiento,dFecha_insert,dFecha_modif,vTipo_evento
				FROM bdinteg:"informix".si_ejecut_replica_db2
				
				LET cCodRet = '00000';
			
				RETURN cCodRet,vEmpresa,vSucursal,vEjecutivo,vPerfil,dFecha_alta,dFecha_ult_cambio,vNombre_usuario,sCajero_certifi,sCajero_en_linea,sCajero_privilegio,sCajero_apertura,sSesion,dCajero_monto_min,dCajero_monto_max,sCajero_cierre_est,sCajero_cierre_dia,vMac_address,vIpmicro,vEdo_usuario,vNombramiento,dFecha_insert,dFecha_modif,vTipo_evento,iTotalReg WITH RESUME;		
			END FOREACH;
		ELSE		
			RETURN cCodRet,vEmpresa,vSucursal,vEjecutivo,vPerfil,dFecha_alta,dFecha_ult_cambio,vNombre_usuario,sCajero_certifi,sCajero_en_linea,sCajero_privilegio,sCajero_apertura,sSesion,dCajero_monto_min,dCajero_monto_max,sCajero_cierre_est,sCajero_cierre_dia,vMac_address,vIpmicro,vEdo_usuario,vNombramiento,dFecha_insert,dFecha_modif,vTipo_evento,iTotalReg;
		END IF;
END;
END PROCEDURE
DOCUMENT
'Procedimiento   : sp_repejecutivo_db2',
'Folio           : 282',
'Creado por      : Hever Barraza',
'Fecha creaciÃÂ³n  : 28/07/2017',
'DescripciÃ³n     : Realiza la recopilaciÃ³n del catÃ¡logo de empleados que se encuentran en la tabla SI_EJECUT_REPLICA_DB2';

CREATE PROCEDURE "informix".sp_get_indicadores_idbox_manual(dFechaini DATE, dFechafin DATE)
RETURNING CHAR(6), CHAR(100);

--DEFINICION DE VARIABLES
DEFINE vCodRet          CHAR(6);
DEFINE cMensCodRet      CHAR(100);
DEFINE iNomErr			INTEGER;
DEFINE iNanErr			INTEGER;
DEFINE iEnTransaccion   SMALLINT;
DEFINE dFechaProceso	DATE;
DEFINE bTablatmp		BOOLEAN;


--ASIGNACION DE VARIABLES
LET vCodRet = '000000';
LET cMensCodRet = 'EL PROCESO SE A GENERADO CORRECTAMENTE';
LET iEnTransaccion = 0;
LET bTablatmp = 'f';

--SET DEBUG FILE TO "/tmp/ALAN/SOC/sp_indicadores_manual_idbox.out";
--TRACE ON;

BEGIN

	--MANEJO DEL ERROR
		ON EXCEPTION SET iNomErr, iNanErr, cMensCodRet
			IF iNomErr <> 0 THEN
			LET vCodRet=iNomErr;
				IF iEnTransaccion = 1 THEN
					ROLLBACK;
					
					LET iEnTransaccion = 0;
					
					IF bTablatmp = 't' THEN
						LET bTablatmp = 'f';	
					END IF;
                END IF;
				
				IF bTablatmp = 't' THEN
					DROP TABLE si_tmp_ctes_titulares_idbox;
					LET bTablatmp = 'f';
				END IF;
				
				RETURN vCodRet, cMensCodRet;
			END IF;
		END EXCEPTION;	
		
		IF NVL(dFechaIni,'') = '' OR  NVL(dFechaFin,'') = ''  THEN 		
			LET vCodRet = '000001';
			LET cMensCodRet = 'PARAMETRO INCORRECTO';
			RETURN vCodRet, cMensCodRet;
		ELIF dFechaIni > dFechaFin THEN
			LET vCodRet = '000002';
			LET cMensCodRet = 'PARAMETROS INCORRECTOS, FECHA INCIAL MAYOR A FECHA FINAL';
			RETURN vCodRet, cMensCodRet;
		END IF;
			
		LET dFechaProceso = dFechaIni;
		
		WHILE (dFechaProceso <= dFechaFin)
			BEGIN WORK;
			
				LET iEnTransaccion = 1;
					
				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;	
				SELECT {+INDEX (bdinteg:"informix".si_cliente idx_si_clientex )} a.sucursal, a.numcte, a.ejecutivo AS numemp, a.fecha_insert
				FROM bdinteg:"informix".si_cliente a INNER JOIN bdinteg:"informix".si_ctepf b
				ON a.numcte = b.numcte	
				WHERE a.fecha_insert = dFechaProceso
				AND a.tipo_cliente='1'
				INTO TEMP si_tmp_ctes_titulares_idbox WITH NO LOG;
				
				LET bTablatmp = 't';
					
				IF  EXISTS (SELECT 1 FROM si_indicadores_idbox WHERE fecha_proceso = dFechaProceso) THEN
					DELETE FROM si_indicadores_idbox
					WHERE fecha_proceso = dFechaProceso;
				END IF;	
				
				INSERT INTO si_indicadores_idbox (fecha_proceso,sucursal,altas_total,total_idb,user_insert,fecha_insert)
				SELECT NVL(b.fecha_insert,dFechaProceso) AS fecha_insert,a.sucursal, nvl(c.total,0) as Altas_Total, nvl(b.total,0) as Tot_Idb,user as usuer_insert,(SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals) as fecha_insert
					FROM si_sucursales a
					LEFT JOIN(  --OBTENIENDO TODOS LOS CLIENTES TITULARES DE LA TABLA DE si_tmp_ctes_titulares_idbox
									SELECT clientes.sucursal AS sucursal, count(DISTINCT(clientes.numcte)) AS total, clientes.fecha_insert FROM 
									(SELECT numcte, sucursal,fecha_insert 
									FROM si_tmp_ctes_titulares_idbox
									WHERE fecha_insert = dFechaProceso) clientes
									INNER JOIN
								--OBTENIENDO LOS DATOS DE LA BITACORA DE IDBOX
									(SELECT DISTINCT(numcte), sucursal, fecha
									FROM si_bitacora_ife
									WHERE date(fecha) = dFechaProceso) bitacora
									ON clientes.numcte=bitacora.numcte AND clientes.sucursal=bitacora.sucursal
									GROUP BY clientes.sucursal,clientes.fecha_insert
							 ) b 	ON a.sucursal=b.sucursal
					LEFT JOIN (--OBTENIENDO ALTAS POR SUCURSAL
									SELECT sucursal, COUNT(DISTINCT (numcte)) AS total
									FROM si_tmp_ctes_titulares_idbox
									WHERE fecha_insert = dFechaProceso
									GROUP BY sucursal
							  )C 	ON a.sucursal=C.sucursal	
					WHERE a.sucursal IN (SELECT DISTINCT(sucursal) FROM si_bitacora_ife);
					
				IF bTablatmp = 't' THEN
					DROP TABLE si_tmp_ctes_titulares_idbox;
					LET bTablatmp = 'f';
				END IF;

			COMMIT WORK;
				LET iEnTransaccion = 0;
				LET dFechaProceso = dFechaProceso + 1 UNITS DAY; 
		END WHILE;
		
		RETURN vCodRet, cMensCodRet;	
END;
		
END PROCEDURE		
;