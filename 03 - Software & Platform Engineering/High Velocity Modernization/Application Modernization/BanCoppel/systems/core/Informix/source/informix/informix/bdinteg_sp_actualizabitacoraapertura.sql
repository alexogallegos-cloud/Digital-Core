CREATE PROCEDURE "informix".sp_actualizabitacoraapertura(pNumcte CHAR (9), pSecuencia INTEGER, pCuenta CHAR(11))
	RETURNING VARCHAR(6) AS CodRetorno;

--Definicion de Variables
DEFINE  SQL_ERR      		INTEGER;
DEFINE  ISAM_ERR     		INTEGER;
DEFINE  P_COD_RET   		VARCHAR(6);
DEFINE vsCliente			CHAR(9);
DEFINE vsSecuencia			INTEGER;
DEFINE vsCuenta				CHAR(11);
DEFINE 	Reg_Afectados 		INTEGER;
DEFINE vsValSec             INTEGER;

--Inicializacion de Variables
LET P_COD_RET = '000';
LET vsCliente 	= TRIM(pNumcte);
LET vsSecuencia = pSecuencia;
LET vsCuenta 	= TRIM(pCuenta);
LET vsValSec    = 0;          
	
--SET DEBUG FILE TO '/tmp/sp_actualizabitacoraapertura.out';
--TRACE ON;
	
BEGIN
    ON EXCEPTION SET SQL_ERR, ISAM_ERR
        LET P_COD_RET    = SQL_ERR;
        RETURN P_COD_RET;
    END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	
	IF EXISTS(SELECT numcte FROM bdinteg:"informix".si_bitacoraapertura WHERE numcte= vsCliente) THEN 
		IF vsSecuencia = 0 OR vsSecuencia IS NULL OR vsSecuencia = '' THEN
			SELECT MAX(id_secuencia) INTO vsValSec FROM bdinteg:"informix".si_bitacoraapertura WHERE numcte= vsCliente;  
		ELSE
			LET vsValSec = vsSecuencia;
		END IF;

		UPDATE bdinteg:"informix".si_bitacoraapertura SET cuenta=vsCuenta WHERE numcte= vsCliente AND id_secuencia=vsValSec;
		LET Reg_Afectados = dbinfo("sqlca.sqlerrd2");
		IF (Reg_Afectados > 0) THEN
			LET P_COD_RET= '000';
		ELSE
			LET P_COD_RET='022';
		END IF;
	ELSE
		LET P_COD_RET='022';
	END IF;
	
	RETURN P_COD_RET;
	
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Actualiza el campo cuenta en la tabla tbl_bitacoraapertura',
'AUTOR : Nevarez Peinado JosÃ¨ de JesÃ¹s',
'FECHA : 12 Julio 2010',
'VERSION: 20100712',
'BD: bdiauditor',
'SISTEMA : PreLavado',

'DESCRIPCION: Se modifica cambiando el nombre de la tabla a la nueva que se registraran la recopilacion en las preguntas',
'MODIFICO : Adrian Lara Izaguirre',
'FECHA : 14 Julio 2011',
'VERSION: 20110714',
'BD: bdinteg',

'DESCRIPCION: Se realiza consulta para tomar la maxina secuencia',
'MODIFICO : Veronica Rodriguez',
'FECHA : 01 Febrero 2024',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_bitacoraapertura(prfc CHAR(13),pnumcte CHAR (9),pid_preg SMALLINT,prespuesta CHAR(3),pid_act SMALLINT,pid_subact SMALLINT, prechazo CHAR(255),pfechayhr datetime YEAR TO FRACTION,psucursal CHAR(4),pid_sec INTEGER,pcuenta CHAR(11),pproducto CHAR(4))
RETURNING CHAR(6) AS CodRetorno, INTEGER AS Secuencia, INTEGER AS ErrorSql;

--Definicion de Variables
DEFINE SQL_ERR INTEGER;
DEFINE ISAM_ERR INTEGER;
DEFINE iError INTEGER;
DEFINE P_COD_RET CHAR(6);
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
DEFINE iLenRFC INTEGER;


--Inicializacion de Variables
LET P_COD_RET = '000';
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
LET iLenRFC=0;

--SET DEBUG FILE TO '/tmp/anj/sp_bitacoraapertura.sql';
--TRACE ON;

BEGIN
	ON EXCEPTION SET SQL_ERR, ISAM_ERR
		LET P_COD_RET    = '022';
		LET iError = SQL_ERR;
		RETURN P_COD_RET, pid_sec, iError;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
 
    LET iLenRFC = LEN(prfc);

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
                
                IF iLenRFC>=10 THEN
                    EXECUTE PROCEDURE bdinteg:"informix".sp_ingresos (pTipoOperacion, pEmpresa, pnumcte, iSecuencia ,pTipoIngreso,
                                                          pNombreEmpresa, pPuesto, pAntiguedad, pNombreDepto, pJefeInmediato,
                                                          pIngresosMensuales, pUsuarioInserta, pFechaInserta, pPuestoEsp,
                                                          pClavePuesto, pid_act, pid_subact, pSisCotiza, pNumEmpLab, pTipoIngresoExt, pPeriosidad)
                    INTO vcodret;
                END IF;
			END IF;
			
        END IF;

	END IF;
	RETURN P_COD_RET, pid_sec, iError;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Guarda la informaciÃ³n recopilada en las preguntas o en alta del cliente en la tabla si_bitacoraapertura',
'AUTOR : Nevarez Peinado JosÃ¨ de JesÃ¹s',
'FECHA : 12 Julio 2010',
'VERSION: 20100712',
'BD: bdiauditor',
'SISTEMA : PreLavado',

'DESCRIPCION: Se modifica cambiando el nombre de la tabla a la nueva que se registraran la recopilacion en las preguntas',
'MODIFICO : Adrian Lara Izaguirre',
'FECHA : 14 Julio 2011',
'VERSION: 20110714',
'BD: bdinteg',

'DESCRIPCION: Se modifica para que no guarde registro con la pid_preg = 0: *P.1',
'MODIFICO : Adrian Lara Izaguirre',
'FECHA : 22 Marzo 2012',
'VERSION: 20120314',
'BD: bdinteg',

'DESCRIPCION: Se modifica para que guarde correctamente los datos de claveopcionpuesto y clavesubopcionpuesto',
'			  en la tabla si_bitacoraapertura cuando se cancele el proceso de respuestas a las preguntas de puestos',
'			  y para que no realice ningun tipo de movimiento en la tabla si_ingresos',
'MODIFICO : Martha Aguirre',
'FECHA : 14 Agosto 2012',
'VERSION: 20120810',
'BD: bdinteg',

'DESCRIPCION: Se modifica para inicializar la variable pTipoIngreso = T',
'			  Se quita el campo "tipo_ingreso" del SELECT Y Se quita la variable "pTipoIngreso" del INTO',
'             para que siempre que se inserte un registro nuevo en la si_ingresos sea con valor T. ',
'MODIFICO   : Rodolfo Tortolero Varela',
'FECHA      : 10 Septiembre 2012',
'VERSION    : 20120910',
'BD         : bdinteg',

'DESCRIPCION: Se modifica flujo para que inserte primero en la tabla si_bitacoraapertura',
'             y luego mande llamar al sp_ingresos',
'MODIFICO   : Rodolfo Tortolero Varela',
'FECHA      : 20 Septiembre 2012',
'VERSION    : 20120920',
'BD         : bdinteg',
'DESCRIPCION: Se modifica para hacer una validacion de parametros pid_act <> iClaveOpPuesto OR pid_subact <> iClaveSubOpPuesto',
'             si es diferente se se limpia el parametro pNombreEmpresa para la ejecucion del sp_ingresos',
'MODIFICO   : Jairo Valdez Gonzalez',
'FECHA      : 10/11/2014',
'VERSION    : 20141110',
'BD         : bdinteg',
'------------------------------------------------------------------------------------------------------------------------------------',
'Folio:1695',
'Autor:95142134 Mario Gallardo',
'Fecha:12/01/2015',
'ModificaciÃ³n: Se modifica para agregar validacion para validar el tipo de cliente  y puesto',
'Sustento: CorreoPeticion',
'Solicita: Rodolfo GÃ³mez';

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