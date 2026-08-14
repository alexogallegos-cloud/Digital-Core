CREATE PROCEDURE "informix".sp_altamodificacion_club(pEmpresa CHAR(3),pCliente CHAR(20),pCteCoppel CHAR(20),pNumPoliza CHAR(20),pTipoPlan CHAR(1),pSucAlta CHAR(4),pEjecutivo CHAR(8),pTipopago CHAR(1),pNumtarjeta CHAR(20),pNumcta CHAR(20),pMesesPagar INTEGER,pMontoPagar MONEY(14,2),pMontoMes MONEY(14,2),pMontoTotal MONEY(14,2),pAceptada CHAR(1),pMotivo_rechazo CHAR(50),pFolioOperacion CHAR(16),pOpcion CHAR(1),pSucCambio CHAR(4),pFechaVencimiento DATE,pTipoPlanAnt CHAR(1))
RETURNING CHAR(6) AS codRet;

--DEFINICION DE VARIABLES
DEFINE cCodret CHAR(6);
DEFINE iSqlErr INTEGER;
DEFINE iContador INTEGER;

--INICIALIZACION DE VARIABLES
LET cCodret	= "000000";
LET iSqlErr = 0;
LET iContador = 0;

--SET DEBUG FILE TO '/informix/IrisA/sp_altamodificacion_club.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodret = iSqlErr;
			RETURN cCodret;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 5;

	IF TRIM(NVL(pOpcion,''))='' THEN
		LET cCodret	= "000001";
	ELSE
		IF TRIM(pOpcion) ='1' THEN
			IF TRIM(NVL(pEmpresa,''))='' OR TRIM(NVL(pCliente,''))='' OR TRIM(NVL(pCteCoppel,''))=''
				OR TRIM(NVL(pTipoPlan,''))='' OR TRIM(NVL(pSucAlta,''))='' OR TRIM(NVL(pEjecutivo,''))='' OR TRIM(NVL(pTipopago,''))=''
				OR NVL(pMesesPagar,0)=0 OR NVL(pMontoPagar,0)=0 OR NVL(pMontoMes,0)=0 OR NVL(pMontoTotal,0)=0
				OR TRIM(NVL(pAceptada,''))='' OR TRIM(NVL(pFolioOperacion,''))=''  THEN
				LET cCodret	= "000001";
			ELSE
				IF TRIM(pTipopago)='1' THEN
					IF TRIM(NVL(pNumtarjeta,''))='' AND TRIM(NVL(pNumcta,''))='' OR TRIM(NVL(pNumPoliza,''))=''THEN
						LET cCodret	= "000001";
					END IF
				END IF
				IF TRIM(cCodret)="000000" THEN
					INSERT INTO "informix".si_club_proteccion (empresa,numcte,numcte_coppel,num_poliza,tipo_plan,suc_alta,ejecutivo,tipo_pago,num_tarjeta,num_cta,meses_pagar,monto_pagar,monto_mes,monto_total,aceptada,motivo_rechazo,tipo_mov,pago_mov,foliooperacion,fecha_alta,fecha_cambio,suc_cambio,fecha_vencimiento,tipoplan_ant)
						VALUES (TRIM(pEmpresa),TRIM(pCliente),TRIM(pCteCoppel),TRIM(pNumPoliza),TRIM(pTipoPlan),TRIM(pSucAlta),TRIM(pEjecutivo),TRIM(pTipopago),TRIM(pNumtarjeta),TRIM(pNumcta),pMesesPagar,pMontoPagar,pMontoMes,pMontoTotal,TRIM(pAceptada),'','V','0',TRIM(pFolioOperacion),CURRENT,CURRENT,"",pFechaVencimiento,pTipoPlanAnt);
				END IF
			END IF
		END IF
		IF TRIM(pOpcion)='2'THEN
			IF TRIM(NVL(pEmpresa,''))='' OR TRIM(NVL(pCliente,''))='' OR TRIM(NVL(pNumPoliza,''))='' OR TRIM(NVL(pCteCoppel,''))='' THEN
				LET cCodret	= "000001";
			ELSE
				SELECT COUNT(numcte)
				INTO iContador
				FROM "informix".si_club_proteccion
				WHERE empresa= TRIM(pEmpresa)
				AND numcte= TRIM(pCliente)
				AND numcte_coppel=TRIM(pCteCoppel)
				AND num_poliza=TRIM(pNumPoliza)
				AND aceptada='1';

				IF NVL(iContador,0)>0 THEN
					IF  TRIM(NVL(pTipopago,''))<>"" THEN
						IF TRIM(NVL(pTipopago,''))=0 THEN
							UPDATE "informix".si_club_proteccion
							SET tipo_pago=pTipopago, num_tarjeta='',num_cta='',fecha_cambio=CURRENT
							WHERE empresa= TRIM(pEmpresa)
							AND numcte= TRIM(pCliente)
							AND numcte_coppel=TRIM(pCteCoppel)
							AND num_poliza=TRIM(pNumPoliza)
							AND aceptada='1';
						ELSE 
							IF TRIM(NVL(pTipopago,''))=1 THEN
								IF TRIM(NVL(pNumtarjeta,''))='' AND TRIM(NVL(pNumcta,''))='' THEN
									LET cCodret	= "000001";
								ELSE
									UPDATE "informix".si_club_proteccion
									SET tipo_pago=pTipopago, num_tarjeta=TRIM(pNumtarjeta),num_cta=TRIM(pNumcta),fecha_cambio=CURRENT
									WHERE empresa= TRIM(pEmpresa)
									AND numcte= TRIM(pCliente)
									AND numcte_coppel=TRIM(pCteCoppel)
									AND num_poliza=TRIM(pNumPoliza)
									AND aceptada='1';
								END IF
							END IF
						END IF
					END IF
					IF  TRIM(cCodret)="000000" AND  TRIM(NVL(pTipoPlan,''))<>'' THEN
						IF NVL(pMesesPagar,0)=0 OR NVL(pMontoPagar,0)=0 OR NVL(pMontoMes,0)=0  OR NVL(pMontoTotal,0)=0 OR TRIM(NVL(pSucCambio,''))='' THEN
							LET cCodret	= "000001";
						ELSE
							UPDATE "informix".si_club_proteccion
							SET meses_pagar=pMesesPagar,monto_pagar=pMontoPagar,monto_mes=pMontoMes,
							monto_total=pMontoTotal,tipo_mov='C',pago_mov='0',fecha_cambio=CURRENT,suc_cambio=pSucCambio,
							tipo_plan=TRIM(pTipoPlan),tipoplan_ant=pTipoPlanAnt
							WHERE empresa= TRIM(pEmpresa)
							AND numcte= TRIM(pCliente)
							AND numcte_coppel=TRIM(pCteCoppel)
							AND num_poliza=TRIM(pNumPoliza)
							AND aceptada='1';
						END IF
					END IF
				ELSE
					LET cCodret	= "000002";
				END IF
			END IF
		END IF
		IF TRIM(pOpcion)='3'THEN
			IF TRIM(NVL(pEmpresa,''))='' OR TRIM(NVL(pCliente,''))='' OR TRIM(NVL(pCteCoppel,''))='' OR
				TRIM(NVL(pAceptada,''))='' OR TRIM(NVL(pMotivo_rechazo,''))='' THEN
				LET cCodret	= "000001";
			ELSE
				SELECT COUNT(numcte)
				INTO iContador
				FROM "informix".si_club_proteccion
				WHERE empresa= TRIM(pEmpresa)
				AND numcte= TRIM(pCliente)
				AND numcte_coppel=TRIM(pCteCoppel)
				AND aceptada<>'1';

				IF NVL(iContador,0)>0 THEN
					DELETE FROM "informix".si_club_proteccion
					WHERE empresa= TRIM(pEmpresa)
					AND numcte= TRIM(pCliente)
					AND numcte_coppel=TRIM(pCteCoppel)
					AND aceptada<>1;
				END IF
				INSERT INTO "informix".si_club_proteccion (empresa,numcte,numcte_coppel,num_poliza,tipo_plan,suc_alta,ejecutivo,tipo_pago,num_tarjeta,
					num_cta,meses_pagar,monto_pagar,monto_mes,monto_total,aceptada,motivo_rechazo,tipo_mov,pago_mov,foliooperacion,fecha_alta,fecha_cambio,suc_cambio,fecha_vencimiento,tipoplan_ant)
					VALUES (pEmpresa,pCliente,pCteCoppel,pNumPoliza,pTipoPlan,pSucAlta,pEjecutivo,pTipopago,pNumtarjeta,pNumcta,pMesesPagar,pMontoPagar,pMontoMes,pMontoTotal,pAceptada,pMotivo_rechazo,' ',' ',pFolioOperacion,CURRENT,CURRENT,"",pFechaVencimiento,pTipoPlanAnt);
			END IF
		END IF
	END IF
	RETURN cCodret;
END
END PROCEDURE
DOCUMENT
"Descripción: Guardará o actualizará los datos de la póliza del cliente en la tabla si_club_proteccion.",
"Autor : Leslie Rendón",
"FECHA : 03/07/2014",
"Descripción: Se agrega campo suc_cambio para identificar la sucursal en la que se realizo el cambio del club",
"Modifico: Leslie Rendón",
"Fecha: 03/09/2014",
"BD    : bdinteg";

CREATE PROCEDURE "informix".sp_obtienepagosventa_club(pFecha DATE)
--DATOS A REGRESAR--
RETURNING CHAR(6) AS CodigoRetorno;

--DEFINICION DE VARIABLES--
DEFINE cCodret CHAR(6);
DEFINE vMensajeRet VARCHAR(80);
DEFINE iSqlErr INTEGER;
DEFINE iIsamErr INTEGER;
DEFINE vErrorInfo VARCHAR(80);
DEFINE vProceso VARCHAR(30);
DEFINE cSql CHAR(1024);
DEFINE cRuta CHAR(100);
DEFINE dFechaHoy DATE;
DEFINE cFechaArchivo CHAR(8);

--INICIALIZACION DE VARIABLES--
LET cCodret = '000';
LET vMensajeRet = '';
LET iSqlErr = 0;
LET iIsamErr = 0;
LET vErrorInfo = '';
LET vProceso = 'sp_obtienepagosventa_club';
LET cSql = '';
LET cRuta = '';
LET dFechaHoy = '';
LET cFechaArchivo = '';

--SET DEBUG FILE TO "/informix/IrisA/sp_obtienepagosventa_club.out";
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, vErrorInfo
		IF iSqlErr <> 0 OR iIsamErr <> 0 THEN
			LET cCodret = iSqlErr;
			LET vMensajeRet = vErrorInfo;
			INSERT INTO "informix".si_club_bitacoradomiciliacion(proceso, codigoretorno, mensajeretorno, fec_paquete)
				VALUES(vProceso, cCodret, vMensajeRet, dFechaHoy);
			RETURN cCodret;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 5;

	SELECT fecha_hoy INTO dFechaHoy FROM "informix".si_fechas WHERE empresa = '001';

	IF TRIM(NVL(dFechaHoy,'')) <> '' THEN

		SELECT valor INTO cRuta FROM "informix".si_param WHERE empresa = '001' AND cod_param = 319;

		IF TRIM(NVL(cRuta,'')) <> '' THEN

			IF TRIM(NVL(pFecha,'')) = '' THEN

				LET cFechaArchivo = YEAR(dFechaHoy) || LPAD(MONTH(dFechaHoy),2,'0') || LPAD(DAY(dFechaHoy),2,'0');

				LET cSql = '';
				LET cSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || 'club1' || TRIM(cFechaArchivo) || '.txt' || ' DELIMITER ' || '''|''' ||
							' SELECT d.fecha_alta, d.suc_alta, d.ejecutivo, d.numcte, d.tipo_plan ' ||
							' FROM bdisac:"informix".sac_movimientos a ' ||
							' INNER JOIN bdisac:"informix".sac_vta_cambio_seg b ON(b.numcliente = a.referencia1 AND b.recibo = a.referencia2 AND b.tipomovimiento = ''C'') ' ||
							' JOIN bdinteg:"informix".si_club_proteccion d ON(d.num_poliza = b.poliza AND aceptada = 1) ' ||
							' WHERE a.fecha_pago = ''' || dFechaHoy || ''' AND a.transacc_suc = ''8102'' AND a.status_cancelado = ''N'' ' ||
							' ORDER BY d.suc_alta, d.ejecutivo, d.numcte ' || ';' ||
							' " > pagosventaclub.sql';
				SYSTEM cSql; 

			ELSE

				LET cFechaArchivo = YEAR(pFecha) || LPAD(MONTH(pFecha),2,'0') || LPAD(DAY(pFecha),2,'0');

				LET cSql = '';
				LET cSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || 'club1' || TRIM(cFechaArchivo) || '.txt' || ' DELIMITER ' || '''|''' ||
							' SELECT d.fecha_alta, d.suc_alta, d.ejecutivo, d.numcte, d.tipo_plan ' ||
							' FROM bdisac:"informix".sac_movimientoshistorial a ' ||
							' INNER JOIN bdisac:"informix".sac_vta_cambio_seg b ON(b.numcliente = a.referencia1 AND b.recibo = a.referencia2 AND b.tipomovimiento = ''C'') ' ||
							' JOIN bdinteg:"informix".si_club_proteccion d ON(d.num_poliza = b.poliza AND aceptada = 1) ' ||
							' WHERE a.fecha_pago = ''' || pFecha || ''' AND a.transacc_suc = ''8102'' AND a.status_cancelado = ''N'' ' ||
							' ORDER BY d.suc_alta, d.ejecutivo, d.numcte ' || ';' ||
							' " > pagosventaclub.sql';
				SYSTEM cSql; 

			END IF;

			LET cSql = '';
			LET cSql = 'dbaccess bdinteg pagosventaclub.sql';
			SYSTEM cSql; 

			LET cSql = '';
			LET cSql = "sed 's/|$//g' " || TRIM(cRuta) || 'club1' || TRIM(cFechaArchivo) || '.txt' || " > " || TRIM(cRuta) || 'club' || TRIM(cFechaArchivo) || '.txt';
			SYSTEM cSql; 

			LET cSql = '';
			LET cSql = 'rm pagosventaclub.sql';
			SYSTEM cSql; 

			LET cSql = '';
			LET cSql = 'rm ' || TRIM(cRuta) || 'club1' || TRIM(cFechaArchivo) || '.txt';
			SYSTEM cSql; 
		ELSE
			LET cCodret = '002';
			LET vMensajeRet = 'No Existe Ruta';
		END IF;
	ELSE
		LET cCodret = '001';
		LET vMensajeRet = 'No Existe Fecha';
	END IF;

	IF cCodret <> '000' THEN
		INSERT INTO "informix".si_club_bitacoradomiciliacion(proceso, codigoretorno, mensajeretorno, fec_paquete)
			VALUES(vProceso, cCodret, vMensajeRet, dFechaHoy);
	END IF;

	RETURN cCodret;
END;
END PROCEDURE;