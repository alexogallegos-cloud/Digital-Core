CREATE PROCEDURE "informix".sp_bitacoraapertura_web(prfc CHAR(13),pnumcte CHAR (9),pid_preg SMALLINT,prespuesta CHAR(3),pid_act SMALLINT,pid_subact SMALLINT, prechazo CHAR(255),pfechayhr datetime YEAR TO FRACTION,psucursal CHAR(4),pid_sec INTEGER,pcuenta CHAR(11),pproducto CHAR(4))
RETURNING CHAR(5) AS CodRetorno, INTEGER AS Secuencia, INTEGER AS ErrorSql;

--Definicion de Variables
DEFINE SQL_ERR INTEGER;
DEFINE ISAM_ERR INTEGER;
DEFINE iError INTEGER;
DEFINE P_COD_RET CHAR(5);
DEFINE vsSecuencia INTEGER;
DEFINE vsFecha_Insercion DATETIME  YEAR TO FRACTION;
-- ingresos
DEFINE pTipoOperacion CHAR(01);
DEFINE pEmpresa CHAR(03);
DEFINE iSecuencia SMALLINT;
DEFINE pTipoIngreso CHAR(01);
DEFINE pNombreEmpresa CHAR(60);
DEFINE pPuesto CHAR(03);
DEFINE pAntiguedad DECIMAL(4,2);
DEFINE pNombreDepto CHAR(40);
DEFINE pJefeInmediato CHAR(60);
DEFINE pIngresosMensuales MONEY(14,2);
DEFINE pUsuarioInserta CHAR(08);
DEFINE pFechaInserta DATE;
DEFINE pPuestoEsp CHAR(02);
DEFINE pClavePuesto INTEGER;
DEFINE pSisCotiza INTEGER;
DEFINE pNumEmpLab INTEGER;
DEFINE pTipoIngresoExt INTEGER;
DEFINE pPeriosidad INTEGER;
DEFINE vcodret CHAR(05);
DEFINE iClaveOpPuesto INTEGER;
DEFINE iClaveSubOpPuesto INTEGER;
DEFINE cTipoCte CHAR(1);


--Inicializacion de Variables
LET P_COD_RET = '00000';
LET iError = 0;
LET prfc = TRIM(prfc);
LET pnumcte = TRIM(pnumcte);
LET prespuesta = TRIM(prespuesta);
LET prechazo = TRIM(prechazo);
LET psucursal = TRIM(psucursal);
LET pcuenta = TRIM(pcuenta);
LET pproducto = TRIM (pproducto);
LET vsFecha_Insercion = CURRENT;
LET vsSecuencia = 0;	
-- ingresos
LET pTipoOperacion = '';
LET pEmpresa = '001';
LET iSecuencia = 0;
LET pTipoIngreso = 'T'; --El tipo de ingreso siempre debe de ser 'T'
LET pNombreEmpresa = '';
LET pPuesto = '';
LET pAntiguedad = 0;
LET pNombreDepto = '';
LET pJefeInmediato = '';
LET pIngresosMensuales = 0;
LET pUsuarioInserta = '';
LET pFechaInserta = DATE(1);
LET pPuestoEsp = '';
LET pClavePuesto = 0;
LET pSisCotiza = 0;
LET pNumEmpLab = 0;
LET pTipoIngresoExt = 0;
LET pPeriosidad = 0;
LET vcodret = '000';
LET iClaveOpPuesto = 0;
LET iClaveSubOpPuesto = 0;
LET cTipoCte = '';

--SET DEBUG FILE TO '/respaldosbd/Martha/sp_bitacoraapertura.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET SQL_ERR, ISAM_ERR
		LET P_COD_RET    = '00022';
		LET iError = SQL_ERR;
		RETURN P_COD_RET, pid_sec, iError;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF (pid_preg = 100 OR pid_preg = 0) THEN --VALIDAD QUE LOS DATOS RECIBIDOS SON DE LA PRIMERA PREGUNTA.

		IF EXISTS (SELECT rfc FROM bdinteg:"informix".si_bitacoraapertura WHERE rfc=prfc ) THEN -- VALIDA QUE EXISTA UN REGISTRO PREVIO DEL CLIENTE.
			--CALCULA LA SECUENCIA.
			SELECT MAX(id_secuencia) INTO vsSecuencia FROM bdinteg:"informix".si_bitacoraapertura WHERE rfc=prfc;
			IF (vsSecuencia >= 0) THEN
				LET pid_sec = vsSecuencia + 1;
			END IF;
		ELSE --SI NO ID DE SECUENCIA = 1.
			LET pid_sec=1;
		END IF;
	END IF;
	
	IF (pid_preg <> 100 ) THEN --*P.1
		--INSERTA LA INFORMACIÃN RECOPILATA DE LA PANTALLA DEL MULTIPLA.
		
		IF pid_preg <> 6 THEN
			INSERT INTO bdinteg:"informix".si_bitacoraapertura (rfc,numcte,id_pregunta,respuesta,id_act,id_subact,motivo_rechazo,fechayhr,
			sucursal,id_secuencia,cuenta,producto)
			VALUES(prfc,pnumcte,pid_preg,prespuesta,pid_act,pid_subact,prechazo,vsFecha_Insercion,psucursal,pid_sec,pcuenta,pproducto);
		END IF;
		
        IF pid_preg = 6 THEN
		-- GRABA INGRESOS
            SELECT MAX(sec_ingreso)
            INTO iSecuencia
            FROM bdinteg:"informix".si_ingresos
            WHERE empresa = '001' AND numcte = pnumcte;
			
            IF iSecuencia IS NULL THEN
                LET pTipoOperacion = 'A';
                LET iSecuencia = 0;
                LET pFechaInserta = today;
                LET pUsuarioInserta = user;
            ELSE
                LET pTipoOperacion = 'C';

                SELECT 
                    empresa, 
                    nombre_empresa, puesto, puesto_esp, antiguedad,
                    nombre_depto, jefe_inmediato, ingreso_mensual, user_insert,
                    fecha_insert, clavepuesto, claveopcionpuesto, clavesubopcionpuesto,
                    sis_cotiza, num_emp_lab, periosidad, tipo_ingreso_ext
                    INTO
                    pEmpresa, 
                    pNombreEmpresa, pPuesto, pPuestoEsp, pAntiguedad,
                    pNombreDepto, pJefeInmediato, pIngresosMensuales, pUsuarioInserta,
                    pFechaInserta, pClavePuesto, iClaveOpPuesto, iClaveSubOpPuesto,
                    pSisCotiza, pNumEmpLab, pPeriosidad, pTipoIngresoExt
                FROM bdinteg:"informix".si_ingresos
                WHERE numcte = pnumcte AND sec_ingreso = iSecuencia;
            END IF; 
			
			SELECT tipo_cliente INTO cTipoCte FROM bdinteg:"informix".si_cliente WHERE numcte = pnumcte;
            IF NVL(cTipoCte,'') <> '2' AND iClaveOpPuesto = 0 and iClaveSubOpPuesto = 0 THEN
                LET iClaveOpPuesto = 5;
                LET iClaveSubOpPuesto = 23;
            END IF

			INSERT INTO bdinteg:"informix".si_bitacoraapertura 
			      (rfc,numcte,id_pregunta,respuesta,id_act,id_subact,motivo_rechazo,fechayhr,sucursal,id_secuencia,cuenta,producto)
			VALUES(prfc,pnumcte,pid_preg,prespuesta,iClaveOpPuesto,iClaveSubOpPuesto,prechazo,vsFecha_Insercion,psucursal,pid_sec,pcuenta,pproducto);
			
			IF prechazo <> 'PROCESO CANCELADO' THEN
				--LET iClaveOpPuesto = pid_act;
				--LET iClaveSubOpPuesto = pid_subact;
			
				IF  pid_act <> iClaveOpPuesto OR pid_subact <> iClaveSubOpPuesto THEN
					LET pNombreEmpresa = '';
				END IF;

				EXECUTE PROCEDURE bdinteg:"informix".sp_ingresos (pTipoOperacion, pEmpresa, pnumcte, iSecuencia ,pTipoIngreso,
                                                          pNombreEmpresa, pPuesto, pAntiguedad, pNombreDepto, pJefeInmediato,
                                                          pIngresosMensuales, pUsuarioInserta, pFechaInserta, pPuestoEsp,
                                                          pClavePuesto, pid_act, pid_subact, pSisCotiza, pNumEmpLab, pTipoIngresoExt, pPeriosidad)
                INTO vcodret;
			END IF;
			
        END IF;

	END IF;
	RETURN P_COD_RET, pid_sec, iError;
END;
END PROCEDURE;