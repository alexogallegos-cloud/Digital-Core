CREATE PROCEDURE "informix".sp_faltsob_atm(pempresa CHAR(3),
		psucursal CHAR(4),
		pcajeroprincipal CHAR(8),
        pfolio_suc CHAR(16),
  		ptransaccion CHAR(4),
		pdivisa CHAR(2),
		pmonto money(14,2),
        pfecha DATE,
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
		pcant1 FLOAT(8),
		pcant2 FLOAT(8),
		pcant3 FLOAT(8),
		pcant4 FLOAT(8),
		pcant5 FLOAT(8),
		pcant6 FLOAT(8),
		pcant7 FLOAT(8),
		pcant8 FLOAT(8),
		pcant9 FLOAT(8),
        pcant10 FLOAT(8),
		pcant11 FLOAT(8),
		pcant12 FLOAT(8),
		pcant13 FLOAT(8),
		pcant14 FLOAT(8),
		pcant15 FLOAT(8), 
        poperacion smallint)

RETURNING CHAR(5),CHAR(8);

DEFINE vcodret CHAR(5);
DEFINE vfolio CHAR(8);
DEFINE vsqlerr integer;
DEFINE visamerr INTEGER;
DEFINE vhora CHAR(5);
DEFINE vproveedor CHAR(4);
DEFINE vplaza CHAR(3);
DEFINE vnum CHAR(8);
DEFINE bTransacInterAct	CHAR(1);
DEFINE bEnTransac CHAR(1);

LET vcodret = "000";
LET vproveedor = "";
LEt vplaza = "";
LET vhora = substr(current,12,5);
LET vnum = 0;
LET vfolio = "";
LET vsqlerr = 0;
LET visamerr = 0;
LET bTransacInterAct = 'F';
LET bEnTransac = 'F';
	
BEGIN
	ON EXCEPTION SET vsqlerr,visamerr
		IF vsqlerr <> 0 THEN
			IF bTransacInterAct = 'T' THEN		--DSB20150429 {
				IF bEnTransac = 'T' THEN
					ROLLBACK WORK;
					BEGIN WORK;
				ELSE
					BEGIN WORK;
				END IF;
			ELSE
				IF bEnTransac = 'T' THEN
					ROLLBACK WORK;
				ELSE
					ROLLBACK WORK;
				END IF;							
			END IF;	

			LET vcodret = vsqlerr;
			RETURN vcodret,vfolio;
		END IF;
	END EXCEPTION;

	ON EXCEPTION IN (-535)				--DSB20150429 {
		LET bTransacInterAct = 'T';
		LET bEnTransac = 'T';
		COMMIT WORK;
		BEGIN WORK;
	END EXCEPTION WITH RESUME;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET debug file to "/tmp/Ricardo/sp_faltsob.out";
	--trace on;
	
	BEGIN WORK;
	--- Verifica recepcion correcta de datos
	IF pempresa = '0' or pempresa = '' or psucursal = '0' or psucursal = '' or
	   pdivisa = '0' or pdivisa = ''  or pcajeroprincipal = '0' or pcajeroprincipal = ''
	   or pfolio_suc = '0' or pfolio_suc = '' or ptransaccion = '0' or ptransaccion = ''
	   or pmonto = 0 then
	   LET vcodret = "110";
	ELSE

		select plaza_cajagen into vplaza
		from   bdinteg:si_sucursales
		where  sucursal = psucursal;

		select cod_proveedor into vproveedor
		from   ss_proveedores
		where  plaza = vplaza;

		IF EXISTS (select cod_proveedor from ss_proveedores where cod_proveedor = vproveedor) THEN
		   IF poperacion != 0 AND poperacion != 1 THEN
			  LET vcodret = "106";       
		   ELSE 

			SELECT valor
			  INTO vnum
			  FROM bdisuc:"informix".ss_param_cajagen
			 WHERE  codigo = '0005';

			UPDATE bdisuc:"informix".ss_param_cajagen
			   SET  valor = valor + 1
			 WHERE  codigo = '0005';
					
			   LET vfolio = LPAD(ROUND(vnum),8,"0");
			
			--SE AGREGA DEPURACIÓN A LA TABLA DE RECUPERACIÓN			
			DELETE FROM ss_atm_rec WHERE  cod_atm = psucursal;
			   
		    INSERT INTO ss_atm_rec(empresa,cod_atm,divisa,saldo_anterior,saldo_asignado,saldo_total,denominacion_1,denominacion_2,denominacion_3,denominacion_4,denominacion_5,
			denominacion_6,denominacion_7,denominacion_8,denominacion_9,denominacion_10,denominacion_11,denominacion_12,denominacion_13,denominacion_14,
			denominacion_15,cantidad_1,cantidad_2,cantidad_3,cantidad_4,cantidad_5,cantidad_6,cantidad_7,cantidad_8,cantidad_9,cantidad_10,cantidad_11,
			cantidad_12,cantidad_13,cantidad_14,cantidad_15 ) 
			SELECT empresa,cod_atm,divisa,saldo_anterior,saldo_asignado,saldo_total,denominacion_1,denominacion_2,denominacion_3,denominacion_4,denominacion_5,
			denominacion_6,denominacion_7,denominacion_8,denominacion_9,denominacion_10,denominacion_11,denominacion_12,denominacion_13,denominacion_14,
			denominacion_15,cantidad_1,cantidad_2,cantidad_3,cantidad_4,cantidad_5,cantidad_6,cantidad_7,cantidad_8,cantidad_9,cantidad_10,cantidad_11,
			cantidad_12,cantidad_13,cantidad_14,cantidad_15 FROM ss_atm WHERE  cod_atm = psucursal;
		   
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
											saldo_anterior = saldo_total,
											saldo_total =  saldo_total + pmonto
											  
				  WHERE  cod_atm = psucursal;
	 
			   ELSE
				  UPDATE ss_atm set cantidad_1 = cantidad_1 - pcant1, cantidad_2 = cantidad_2 - pcant2,
											cantidad_3 = cantidad_3 - pcant3, cantidad_4 = cantidad_4 - pcant4,
											cantidad_5 = cantidad_5 - pcant5, cantidad_6 = cantidad_6 - pcant6,
											saldo_anterior = saldo_total,
											saldo_total =  saldo_total - pmonto
				  WHERE  cod_atm = psucursal;
	 

			   END IF; 

		   END IF; 
		ELSE
		   let vcodret = "105";
		   return vcodret,vfolio;
	    END IF;
	END IF;

	COMMIT WORK;
	IF bTransacInterAct = 'T' THEN
		BEGIN WORK;
	END IF;

	RETURN vcodret,vfolio;
END;
END PROCEDURE
DOCUMENT
'BD: bdisuc',
'FOLIO:628',
'Llamado desde:FaltaATM.exe',
'AUTOR:Jesus Moreno', 
'FECHA:2019-09-24',
'DESCRIPCIÓN: Se modifica procedimiento para realiza rollback',
'SOLICITA: Gabriela Angulo',
'AUTOR:Jesus Moreno', 
'FECHA:2020-01-06',
'DESCRIPCIÓN: Se agrega depurado a la tabla ss_atm_rec y se renombre al sp de sp_faltsob01 a sp_faltsob_atm',
'SOLICITA: Gabriela Angulo';

CREATE PROCEDURE "informix".sp_rpt_dotacionesatm_sucursal()
RETURNING CHAR(5) AS cod_ret, CHAR(150) AS msj_ret;
--VARIABLES DE CONTROL DE ERROR
DEFINE iSqlErr    INTEGER;
DEFINE iIsamErr   INTEGER;
DEFINE iPasoErr   INTEGER;
DEFINE cCod_ret	  CHAR(5);
DEFINE cMsj_ret	  CHAR(150);
DEFINE cCmd		  CHAR(500);
--VARIABLES DE ARCHIVOS
DEFINE cRuta 	  CHAR(30);
DEFINE cPrefijo   CHAR(21);
DEFINE cExtension CHAR(4);
DEFINE cArchivo  CHAR(63);
DEFINE dFecha_ant DATE;
DEFINE cDia		  CHAR(2);
DEFINE cMes		  CHAR(2);
DEFINE cAno		  CHAR(4);
DEFINE cFechaRpt  CHAR(8);
--VARIABLES
DEFINE cFolio          CHAR(8);
DEFINE cCodTrans       CHAR(4);
DEFINE cDesTrans       CHAR(35);
DEFINE cTransaccion    CHAR(40);
DEFINE cIdAtm          CHAR(6);
DEFINE cAtm            CHAR(4);
DEFINE cNomBre         CHAR(40);
DEFINE mImporte        MONEY(14,2);
DEFINE iBilletes500    INTEGER;
DEFINE mTotal500       MONEY(14,2);
DEFINE iBilletes200    INTEGER;
DEFINE mTotal200       MONEY(14,2);
DEFINE iBilletes100    INTEGER;
DEFINE mTotal100       MONEY(14,2);
DEFINE iBilletes50     INTEGER;
DEFINE mTotal50        MONEY(14,2);
DEFINE cReverso        CHAR(1);
DEFINE cReversada      CHAR(2);
DEFINE dFechaSolicitud DATE;
DEFINE cHoraSolicitud  CHAR(5);
DEFINE cNumEmpSol      CHAR(8);
DEFINE dFechaEnvio     DATE;
DEFINE cHoraEnvio      CHAR(5);
DEFINE cNumEmpEnv      CHAR(8);
DEFINE dFechaRecepcion DATE;
DEFINE cHoraRecepcion  CHAR(5);
DEFINE cNumEmpRec      CHAR(8);
DEFINE cCodStatus      CHAR(2);
DEFINE cCodPlaza       CHAR(3);
DEFINE cDescPlaza      CHAR(30);
DEFINE cPlaza		   CHAR(33);
DEFINE cNomEmp         CHAR(45);
DEFINE cDescStatus     CHAR(30);
DEFINE cStatus         CHAR(32);
DEFINE cFecHorSol      CHAR(16);
DEFINE cFecHorEnv      CHAR(16);
DEFINE cFecHorRec      CHAR(16);
DEFINE cEmpSol         CHAR(54);
DEFINE cEmpEnv         CHAR(54);
DEFINE cEmpRec         CHAR(54);

LET cFolio          = '';
LET cCodTrans       = '';
LET cDesTrans       = '';
LET cTransaccion    = '';
LET cIdAtm          = '';
LET cAtm            = '';
LET cNomBre         = '';
LET mImporte        = 0;
LET iBilletes500    = 0;
LET mTotal500       = 0;
LET iBilletes200    = 0;
LET mTotal200       = 0;
LET iBilletes100    = 0;
LET mTotal100       = 0;
LET iBilletes50     = 0;
LET mTotal50        = 0;
LET cReverso        = '';
LET cReversada      = '';
LET dFechaSolicitud = '';
LET cHoraSolicitud  = '';
LET cNumEmpSol      = '';
LET dFechaEnvio     = '';
LET cHoraEnvio      = '';
LET cNumEmpEnv      = '';
LET dFechaRecepcion = '';
LET cHoraRecepcion  = '';
LET cNumEmpRec      = '';
LET cCodStatus      = '';
LET cCodPlaza       = '';
LET cDescPlaza      = '';
LET cPlaza			= '';
LET cNomEmp         = '';
LET cDescStatus     = '';
LET cStatus         = '';
LET cFecHorSol      = '';
LET cFecHorEnv      = '';
LET cFecHorRec      = '';
LET cEmpSol         = '';
LET cEmpEnv         = '';
LET cEmpRec         = '';

LET iPasoErr = 0;
LET cCod_ret = '';
LET cMsj_ret = '';
LET cCmd = '';

LET cDia = '';
LET cMes = '';
LET cAno = '';
LET cFechaRpt = '';
LET cRuta = '/resplogifx/OFIConciliacion';
LET cExtension = '.txt';
LET cArchivo = '';

--SET DEBUG FILE TO "/resplogifx/OFIConciliacion/sp_rpt_dotacionesatm_sucursal.out";
--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr
			IF iSqlErr <> 0 OR iIsamErr <> 0 THEN
				TRUNCATE TABLE rpt_operacionatm_bancoppel_tmp;
				TRUNCATE TABLE rpt_dotacionatm_bancoppel_tmp;
				DROP TABLE IF EXISTS atms_administrados_bancoppel;
				RETURN iSqlErr, iIsamErr||' En paso: '||iPasoErr;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--ELIMINA INFORMACION DE LAS TABLAS DE PASO
		TRUNCATE TABLE rpt_operacionatm_bancoppel_tmp;
		TRUNCATE TABLE rpt_dotacionatm_bancoppel_tmp;
		DROP TABLE IF EXISTS atms_administrados_bancoppel;
		
		--OBTIENE LA FECHA DEL DÃA ANTERIOR DE LA FECHA ACTUAL
		SELECT fecha_ant INTO dFecha_ant FROM bdinteg:"informix".si_fechas;
		LET cDia = LPAD(DAY(dFecha_ant), 2, '0');
		LET cMes = LPAD(MONTH(dFecha_ant), 2, '0');
		LET cAno = YEAR(dFecha_ant);
		
		--DA FORMATO 'AAAAMMDD' A LA FECHA
		LET cFechaRpt = cAno||cMes||cDia;
		
		SELECT {+INDEX (bdinteg:"informix".si_sucursales idx_si_sucursales_empzon)} sucursal FROM bdinteg:"informix".si_sucursales 
		WHERE tpo_sucursal = 'C' AND plaza_cajagen IS NOT NULL AND sucursal NOT IN (SELECT cod_atm FROM bdisuc:"informix".ss_atms_sucursal) 
		INTO TEMP atms_administrados_bancoppel;
		
		LET cPrefijo = '/OperacionesSucursal_';
		
		--NOMBRE COMPLETO DEL ARCHIVO
		LET cArchivo = TRIM(cRuta)||TRIM(cPrefijo)||TRIM(cFechaRpt)||TRIM(cExtension);

		FOREACH
			SELECT folio_oper, cod_trans, sucursal, monto, cantidad_2, (denominacion_2 * cantidad_2), cantidad_3, (denominacion_3 * cantidad_3), cantidad_4, (denominacion_4 * cantidad_4), cantidad_5, (denominacion_5 * cantidad_5), reversado
			INTO	cFolio, cCodTrans, cAtm, mImporte, iBilletes500, mTotal500, iBilletes200, mTotal200, iBilletes100, mTotal100, iBilletes50, mTotal50, cReverso
			FROM bdisuc:"informix".ss_operaciones 
			WHERE fecha_operacion = (
				SELECT fecha_ant FROM bdinteg:"informix".si_fechas)
			AND sucursal IN (SELECT sucursal FROM atms_administrados_bancoppel)
			
			SELECT descripcion INTO cDesTrans FROM bdisuc:"informix".ss_param_cajagen WHERE codigo = cCodTrans;
			
			SELECT {+INDEX (bdisuc:"informix".ss_relacionccid idx_relacioncc)} id INTO cIdAtm FROM bdisuc:"informix".ss_relacionccid WHERE cc = cAtm;
			
			SELECT nombre INTO cNombre FROM bdinteg:"informix".si_sucursales WHERE sucursal = cAtm;
			
			IF cReverso = '0' THEN
				LET cReversada = 'NO';
			ELSE
				LET cReversada = 'SI';
			END IF;
			
			LET cTransaccion = TRIM(cCodTrans)||' '||UPPER(TRIM(cDesTrans));
			LET cNombre = UPPER(TRIM(cNombre));
			
			INSERT INTO rpt_operacionatm_bancoppel_tmp VALUES (
			cFolio, cTransaccion, cIdAtm, cAtm, cNombre, mImporte, iBilletes500, mTotal500, iBilletes200, mTotal200, iBilletes100, mTotal100, iBilletes50, mTotal50, cReversada);
			
		END FOREACH;
			
		LET iPasoErr = 1;
		LET cCmd= '';
		LET cCmd= 'echo "UNLOAD TO '||TRIM(cArchivo)||' DELIMITER '||"'|'"||' SELECT * FROM rpt_operacionatm_bancoppel_tmp ORDER BY folio;" >> '||TRIM(cRuta)||'/rpt_operacionatm_bancoppel.sql';
		SYSTEM cCmd;
		
		LET iPasoErr = 2;
		LET cCmd = '';
		LET cCmd = 'dbaccess bdisuc '||TRIM(cRuta)||'/rpt_operacionatm_bancoppel.sql';
		SYSTEM cCmd;
		
		LET iPasoErr = 3;
		LET cCmd = '';
		LET cCmd = 'rm -f '||TRIM(cRuta)||'/rpt_operacionatm_bancoppel.sql';
		SYSTEM cCmd;
		
		LET cPrefijo = '/DotacionesSucursal_';
		
		--NOMBRE COMPLETO DEL ARCHIVO
		LET cArchivo = TRIM(cRuta)||TRIM(cPrefijo)||TRIM(cFechaRpt)||TRIM(cExtension);

		FOREACH
			SELECT {+INDEX (bdisuc:"informix".ss_mae_entradasalida idx01ss_mae_entradasalida)} folio_oper, sucursal, fecha_solicitud, hora_solicitud, usuario_solicitud, fecha_envio, hora_envio, usuario_envio, fecha_recepcion, hora_recepcion, usuario_recepcion, status, monto
			INTO cFolio, cAtm, dFechaSolicitud, cHoraSolicitud, cNumEmpSol, dFechaEnvio, cHoraEnvio, cNumEmpEnv, dFechaRecepcion, cHoraRecepcion, cNumEmpRec, cCodStatus, mImporte
			FROM bdisuc:"informix".ss_mae_entradasalida WHERE fecha_solicitud = (
				SELECT fecha_ant FROM bdinteg:"informix".si_fechas)
			AND sucursal IN (SELECT sucursal FROM atms_administrados_bancoppel)
			
			SELECT cod_trans, cantidad_2, (denominacion_2 * cantidad_2), cantidad_3, (denominacion_3 * cantidad_3), cantidad_4, (denominacion_4 * cantidad_4), cantidad_5, (denominacion_5 * cantidad_5)
			INTO cCodTrans, iBilletes500, mTotal500, iBilletes200, mTotal200, iBilletes100, mTotal100, iBilletes50, mTotal50
			FROM bdisuc:"informix".ss_operaciones WHERE folio_oper = cFolio;
			
			SELECT {+INDEX (bdisuc:"informix".ss_relacionccid idx_relacioncc)} id INTO cIdAtm FROM bdisuc:"informix".ss_relacionccid WHERE cc = cAtm;
			
			SELECT nombre, plaza_cajagen INTO cNombre, cCodPlaza FROM bdinteg:"informix".si_sucursales WHERE sucursal = cAtm;
			
			SELECT descripcion INTO cDescPlaza FROM bdisuc:"informix".ss_proveedores WHERE plaza = cCodPlaza;
			
			SELECT descripcion INTO cDesTrans FROM bdisuc:"informix".ss_param_cajagen WHERE codigo = cCodTrans;
			
			SELECT nombre INTO cNomEmp FROM bdinteg:si_ejecut WHERE ejecutivo = cNumEmpSol;
			
			LET cEmpSol = TRIM(NVL(cNumEmpSol, ''))||' '||UPPER(TRIM(NVL(cNomEmp, '')));
			
			SELECT nombre INTO cNomEmp FROM bdinteg:si_ejecut WHERE ejecutivo = cNumEmpEnv;
			
			LET cEmpEnv = TRIM(NVL(cNumEmpEnv, ''))||' '||UPPER(TRIM(NVL(cNomEmp, '')));
			
			SELECT nombre INTO cNomEmp FROM bdinteg:si_ejecut WHERE ejecutivo = cNumEmpRec;
			
			LET cEmpRec = TRIM(NVL(cNumEmpRec, ''))||' '||UPPER(TRIM(NVL(cNomEmp, '')));
			
			IF cCodStatus = '01' THEN
				LET cDescStatus = 'SOLICITUD DE DOTACION ATM';
			ELIF cCodStatus = '11' THEN
				LET cDescStatus = 'DOTACION ATM APROBADA CG';
			ELIF cCodStatus = '05' THEN
				LET cDescStatus = 'RECEPCION DE DOTACION ATM';
			ELSE 
				SELECT descripcion INTO cDescStatus FROM bdisuc:"informix".ss_catstatus WHERE status = cCodStatus;
			END IF;
			
			LET cPlaza = TRIM(cCodPlaza)||' '||UPPER(TRIM(cDescPlaza));
			LET cTransaccion = TRIM(cCodTrans)||' '||UPPER(TRIM(cDesTrans));
			LET cNombre = UPPER(TRIM(cNombre));
			LET cStatus = TRIM(cCodStatus)||' '||UPPER(TRIM(cDescStatus));
			LET cFecHorSol = dFechaSolicitud||' '||cHoraSolicitud;
			LET cFecHorEnv = NVL(dFechaEnvio, '')||' '||NVL(cHoraEnvio, '');
			LET cFecHorRec = NVL(dFechaRecepcion, '')||' '||NVL(cHoraRecepcion, '');
			
			INSERT INTO rpt_dotacionatm_bancoppel_tmp VALUES (
			cIdAtm, cAtm, cNombre, cPlaza, cTransaccion, cStatus, cFolio, cFecHorSol, cEmpSol, cFecHorEnv, cEmpEnv, cFecHorRec, cEmpRec, mImporte, iBilletes500, mTotal500, iBilletes200, mTotal200, iBilletes100, mTotal100, iBilletes50, mTotal50);	
		END FOREACH;
		
		LET iPasoErr = 4;
		LET cCmd= '';
		LET cCmd= 'echo "UNLOAD TO '||TRIM(cArchivo)||' DELIMITER '||"'|'"||' SELECT * FROM rpt_dotacionatm_bancoppel_tmp ORDER BY folio;" >> '||TRIM(cRuta)||'/descarga_rpt_dotacionatm_bancoppel.sql';
		SYSTEM cCmd;
		
		LET iPasoErr = 5;
		LET cCmd = '';
		LET cCmd = 'dbaccess bdisuc '||TRIM(cRuta)||'/descarga_rpt_dotacionatm_bancoppel.sql';
		SYSTEM cCmd;
		
		LET iPasoErr = 6;
		LET cCmd = '';
		LET cCmd = 'rm -f '||TRIM(cRuta)||'/descarga_rpt_dotacionatm_bancoppel.sql';
		SYSTEM cCmd;
		
		LET cCod_ret = '00000';
		LET cMsj_ret = 'REPORTES GENERADOS: OperacionesSucursal y DotacionesSucursal DEL DÃA '||dFecha_ant;
		
		TRUNCATE TABLE rpt_operacionatm_bancoppel_tmp;
		TRUNCATE TABLE rpt_dotacionatm_bancoppel_tmp;
		DROP TABLE atms_administrados_bancoppel;
			
		RETURN cCod_ret, cMsj_ret;
		
	END;
END PROCEDURE;