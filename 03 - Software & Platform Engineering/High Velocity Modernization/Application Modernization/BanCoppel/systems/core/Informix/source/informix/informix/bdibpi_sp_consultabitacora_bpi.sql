CREATE PROCEDURE "informix".sp_consultabitacora_bpi(
	pNumCte CHAR(10),
	pIdOperacion CHAR(4),
	pIdOperacionFdh CHAR(4),
	pIdOperacionProg CHAR(4),
	pcvePago CHAR(4),
	pTipoConsulta CHAR(1),
	pFechaConsulta DATE,
	pSalto INT
)
Returning char(5) as CodRet,
datetime year to second AS FechaOper,
date AS FechaApli,
char(12) AS CtaOrigen,
char(20) AS CtaDesti,
money AS Monto,
char(16) AS SecTrans,
char(100) AS Cgen1 ,
char(200) AS Cgen2,
char(60) AS Cgen3,
char(60) AS Cgen4,
char(60) AS Cgen5,
char(100) AS Cgen6,
CHAR(100) AS Referencia,
CHAR(16) AS Folio,
CHAR(4) AS IDoperacion,
INT AS TotalRenglones;

DEFINE cod_ret char(5);
DEFINE sql_err integer;
DEFINE vCtasFrec CHAR(1);

DEFINE vfecha_oper datetime year to second;
DEFINE vfecha_aplic date;
DEFINE vcuenta_origen char(12);
DEFINE vdestino char(20);
DEFINE vmonto_oper money;
DEFINE vsec_transaccion char(16);
DEFINE vcgenerico1 char(100);
DEFINE vcgenerico2 char(200);
DEFINE vcgenerico3 char(60);
DEFINE vcgenerico4 char(60);
DEFINE vcgenerico5 char(60);
DEFINE vcgenerico6 char(100);
DEFINE vreferencia char(100);
DEFINE vfolio  char(16);
DEFINE vIdOperacion  char(4);

DEFINE vfecha_limite_Inicio DATE;
DEFINE vfecha_limite_Fin DATE;
DEFINE vTotalRegistros  INT;
DEFINE vTotalRegistros1  INT;
DEFINE vTotalRegistrosProg INT;
LET vfecha_oper = DATE(1);
LET vfecha_aplic = DATE(1);
LET vcuenta_origen = '';
LET vdestino ='';
LET vmonto_oper =0.00;
LET vsec_transaccion ='';
LET vcgenerico1 ='';
LET vcgenerico2 ='';
LET vcgenerico3 ='';
LET vcgenerico4 ='';
LET vcgenerico5 ='';
LET vcgenerico6 ='';
LET vreferencia ='';
LET vfolio  ='';
LET vIdOperacion = '';

--INICIALIZA VARIABLES
LET vfecha_limite_Inicio = DATE(1);
LET vfecha_limite_Fin = CURRENT;
LET vTotalRegistros = 0;
LET vTotalRegistros1 = 0;
LET vTotalRegistrosProg = 0;
LET cod_ret  = "00000";

/*
ELABORO: ING. ALFONSO CRUZ
FECHA: 24-06-2013
DESCRIPCION: CONSULTA BITACORA BPI PARA LA REIMPRESION DE COMPROBANTES
--
ELABORO: ING. ALFONSO CRUZ
FECHA: 15-07-2013
DESCRIPCION: SE AGREGA COMO RETORNO EL ID DE OPERACION (PARA IDENTIFICAR SI ES PROGRAMADA) Y TOTAL DE REGISTROS
--
ELABORO: L.I. Manuel Ramos Figueroa
FECHA: 16-01-2014
DESCRIPCION: Se aumento el tamaÃ±o a 100 de la variable que se usa para consultar la columna cgenerico6 asi como la salida para dicho valor
				ademas la tabla a consultar a una nueva (bdibpi: bpi_bitacora)
--
ELABORO: L.I. Manuel Ramos Figueroa
FECHA: 06-02-2014
DESCRIPCION: Se aumento el tamaÃ±o a 200 de la variable que se usa para consultar la columna cgenerico2 asi como la salida para dicho valor.
*/

--SET DEBUG FILE TO "/home/informix/BereniceOut/sp_consultabitacora_bpi.out";
 --TRACE ON;

BEGIN
	ON EXCEPTION SET sql_err
	  IF sql_err <> 0 THEN
			let cod_ret = sql_err;
			RETURN
				cod_ret,
				NVL(vfecha_oper,DATE(1)),
				NVL(vfecha_aplic,DATE(1)),
				NVL(vcuenta_origen,''),
				NVL(vdestino,''),
				NVL(vmonto_oper,''),
				NVL(vsec_transaccion,''),
				NVL(vcgenerico1,''),
				NVL(vcgenerico2,''),
				NVL(vcgenerico3,''),
				NVL(vcgenerico4,''),
				NVL(vcgenerico5,''),
				NVL(vcgenerico6,''),
				NVL(vreferencia,''),
				NVL(vfolio,''),
				NVL(vIdOperacion,''),
				NVL(vTotalRegistros,0);

	  END IF ;
	END EXCEPTION ;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF(pTipoConsulta='1') THEN
		LET vfecha_limite_Inicio = pFechaConsulta;
		LET vfecha_limite_Fin 	 = pFechaConsulta;
	ELIF(pTipoConsulta='2') THEN
		--CONSULTA DEL MES ACTUAL
		LET vfecha_limite_Inicio = ((MONTH(CURRENT)||'/01/'||YEAR(CURRENT))::DATE);
		LET vfecha_limite_Fin = ((MONTH(CURRENT)||'/'||DAY(CURRENT) ||'/'||YEAR(CURRENT))::DATE);
		
	ELIF(pTipoConsulta='3') THEN
		--CONSULTA DEL MES ANTERIOR (SOLO EL MES ANTERIOR: JUNIO)
		LET vfecha_limite_Inicio = ((MONTH(CURRENT)||'/01/'||YEAR(CURRENT))::DATE);
		LET vfecha_limite_Fin = vfecha_limite_Inicio;
		LET vfecha_limite_Inicio = vfecha_limite_Inicio - 1 UNITS MONTH;
		LET vfecha_limite_Fin = vfecha_limite_Fin - 1 UNITS DAY;
	ELIF(pTipoConsulta='4') THEN
		--CONSULTA DE 2 MESES ANTERIORES (DOS MESES ANTERIORES SIN CINCLUIR EL ACTUAL: MAYO Y JUNIO)
		LET vfecha_limite_Inicio = ((MONTH(CURRENT)||'/01/'||YEAR(CURRENT))::DATE);
		LET vfecha_limite_Fin = vfecha_limite_Inicio;
		LET vfecha_limite_Inicio = vfecha_limite_Inicio - 2 UNITS MONTH;
		LET vfecha_limite_Fin = vfecha_limite_Fin - 1 UNITS DAY;
	ELIF(pTipoConsulta='5') THEN
		--CONSULTA DE 3 MESES ANTERIORES (INCLUYENDO EL ACTUAL)
		LET vfecha_limite_Inicio = CURRENT - 3 UNITS MONTH;
		LET vfecha_limite_Fin = ((MONTH(CURRENT)||'/'||DAY(CURRENT) ||'/'||YEAR(CURRENT))::DATE);
	END IF;

	IF(pTipoConsulta IN ('1','2','5'))THEN
	
		SET ISOLATION TO DIRTY READ;

		SELECT
			NVL(COUNT(id_operacion),0)
			INTO
			vTotalRegistros1
			FROM bdibpi:"informix".bpi_bitacora
			WHERE id_usuario IN
				(SELECT {+INDEX (bpi_usuario,inx_ncst)}
				id_usuario FROM bdibpi:"informix".bpi_usuario
				WHERE numcliente = pNumCte)
				AND id_operacion IN (pIdOperacion,pIdOperacionFdh)
				AND fecha_oper::date BETWEEN vfecha_limite_Inicio AND vfecha_limite_Fin;

		SELECT
			NVL(COUNT(id_operacion),0)
			INTO
			vTotalRegistrosProg
			FROM bdibpi:"informix".bpi_bitacora
			WHERE id_usuario IN
				(SELECT id_usuario FROM bdibpi:"informix".bpi_usuario
				WHERE numcliente = pNumCte)
				AND id_operacion = pIdOperacionProg and sec_transaccion = pIdOperacion
				AND fecha_oper::date BETWEEN vfecha_limite_Inicio AND vfecha_limite_Fin;

		 
		
		LET vTotalRegistros = vTotalRegistros1 + vTotalRegistrosProg;

		SELECT
			NVL(COUNT(id_operacion),0)
			INTO
			vTotalRegistros1
			FROM bdibpi:"informix".bpi_bitacora_historial
			WHERE id_usuario IN
				(SELECT {+INDEX (bpi_usuario,inx_ncst)}
				id_usuario FROM bdibpi:"informix".bpi_usuario
				WHERE numcliente = pNumCte)
				AND id_operacion IN (pIdOperacion,pIdOperacionFdh)
				AND fecha_oper::date BETWEEN vfecha_limite_Inicio AND vfecha_limite_Fin;

		SELECT
			NVL(COUNT(id_operacion),0)
			INTO
			vTotalRegistrosProg
			FROM bdibpi:"informix".bpi_bitacora_historial
			WHERE id_usuario IN
				(SELECT id_usuario FROM bdibpi:"informix".bpi_usuario
				WHERE numcliente = pNumCte)
				AND id_operacion = pIdOperacionProg and sec_transaccion = pIdOperacion
				AND fecha_oper::date BETWEEN vfecha_limite_Inicio AND vfecha_limite_Fin;

		
		LET vTotalRegistros = vTotalRegistros + vTotalRegistros1 + vTotalRegistrosProg;

		
		
		FOREACH

			SELECT SKIP pSalto FIRST 10
				ms2.id_operacion,
				ms2.fecha_oper,
				ms2.fecha_aplic,
				ms2.cuenta_origen,
				ms2.destino,
				ms2.monto_oper,
				ms2.sec_transaccion,
				ms2.cgenerico1,
				ms2.cgenerico2,
				ms2.cgenerico3,
				ms2.cgenerico4,
				ms2.cgenerico5,
				ms2.cgenerico6,
				ms2.referencia,
				ms2.folio
			INTO
				vIdOperacion,
				vfecha_oper,
				vfecha_aplic,
				vcuenta_origen,
				vdestino,
				vmonto_oper,
				vsec_transaccion,
				vcgenerico1,
				vcgenerico2,
				vcgenerico3,
				vcgenerico4,
				vcgenerico5,
				vcgenerico6,
				vreferencia,
				vfolio
			FROM  ( 
			SELECT
				id_operacion,
				fecha_oper,
				fecha_aplic,
				cuenta_origen,
				destino,
				monto_oper,
				sec_transaccion,
				cgenerico1,
				cgenerico2,
				cgenerico3,
				cgenerico4,
				cgenerico5,
				cgenerico6,
				referencia,
				folio
			FROM bdibpi:"informix".bpi_bitacora
			WHERE id_usuario IN
				(SELECT id_usuario FROM bdibpi:"informix".bpi_usuario
				WHERE numcliente = pNumCte)
				
				AND fecha_oper::date BETWEEN vfecha_limite_Inicio AND vfecha_limite_Fin
				
				AND (
						(	id_operacion IN (pIdOperacion,pIdOperacionFdh) ) 
						OR
						(						
							id_operacion = pIdOperacionProg
							AND sec_transaccion = pIdOperacion
						)	
				)
			 UNION
			 SELECT
				id_operacion,
				fecha_oper,
				fecha_aplic,
				cuenta_origen,
				destino,
				monto_oper,
				sec_transaccion,
				cgenerico1,
				cgenerico2,
				cgenerico3,
				cgenerico4,
				cgenerico5,
				cgenerico6,
				referencia,
				folio
			FROM bdibpi:"informix".bpi_bitacora_historial
			WHERE id_usuario IN
				(SELECT id_usuario FROM bdibpi:"informix".bpi_usuario
				WHERE numcliente = pNumCte)
				
				AND fecha_oper::date BETWEEN vfecha_limite_Inicio AND vfecha_limite_Fin
				
				AND (
						(	id_operacion IN (pIdOperacion,pIdOperacionFdh) ) 
						OR
						(						
							id_operacion = pIdOperacionProg
							AND sec_transaccion = pIdOperacion
						)	
				)			 
			 ORDER BY fecha_oper DESC
			) ms2

			RETURN
				cod_ret,
				NVL(vfecha_oper,DATE(1)),
				NVL(vfecha_aplic,DATE(1)),
				NVL(vcuenta_origen,''),
				NVL(vdestino,''),
				NVL(vmonto_oper,''),
				NVL(vsec_transaccion,''),
				NVL(vcgenerico1,''),
				NVL(vcgenerico2,''),
				NVL(vcgenerico3,''),
				NVL(vcgenerico4,''),
				NVL(vcgenerico5,''),
				NVL(vcgenerico6,''),
				NVL(vreferencia,''),
				NVL(vfolio,''),
				NVL(vIdOperacion,''),
				NVL(vTotalRegistros,0)
				WITH RESUME;
		END FOREACH;
		
	ELIF (pTipoConsulta IN ('3','4')) THEN
		SET ISOLATION TO DIRTY READ;
		SELECT
			NVL(COUNT(id_operacion),0)
			INTO
			vTotalRegistros
			FROM bdibpi:"informix".bpi_bitacora_historial
			WHERE id_usuario IN
				(SELECT {+INDEX (bpi_usuario,inx_ncst)}
				id_usuario FROM bdibpi:"informix".bpi_usuario
				WHERE numcliente = pNumCte)
				AND id_operacion IN (pIdOperacion,pIdOperacionFdh)
				AND fecha_oper::date BETWEEN vfecha_limite_Inicio AND vfecha_limite_Fin;

		SELECT
			NVL(COUNT(id_operacion),0)
			INTO
			vTotalRegistrosProg
			FROM bdibpi:"informix".bpi_bitacora_historial
			WHERE id_usuario IN
				(SELECT id_usuario FROM bdibpi:"informix".bpi_usuario
				WHERE numcliente = pNumCte)
				AND id_operacion = pIdOperacionProg and sec_transaccion = pIdOperacion
				AND fecha_oper::date BETWEEN vfecha_limite_Inicio AND vfecha_limite_Fin;

		LET vTotalRegistros = vTotalRegistros + vTotalRegistrosProg;

		FOREACH

			SELECT SKIP pSalto FIRST 10
				ms2.id_operacion,
				ms2.fecha_oper,
				ms2.fecha_aplic,
				ms2.cuenta_origen,
				ms2.destino,
				ms2.monto_oper,
				ms2.sec_transaccion,
				ms2.cgenerico1,
				ms2.cgenerico2,
				ms2.cgenerico3,
				ms2.cgenerico4,
				ms2.cgenerico5,
				ms2.cgenerico6,
				ms2.referencia,
				ms2.folio
			INTO
				vIdOperacion,
				vfecha_oper,
				vfecha_aplic,
				vcuenta_origen,
				vdestino,
				vmonto_oper,
				vsec_transaccion,
				vcgenerico1,
				vcgenerico2,
				vcgenerico3,
				vcgenerico4,
				vcgenerico5,
				vcgenerico6,
				vreferencia,
				vfolio
			FROM  ( 
			SELECT
				id_operacion,
				fecha_oper,
				fecha_aplic,
				cuenta_origen,
				destino,
				monto_oper,
				sec_transaccion,
				cgenerico1,
				cgenerico2,
				cgenerico3,
				cgenerico4,
				cgenerico5,
				cgenerico6,
				referencia,
				folio
			FROM bdibpi:"informix".bpi_bitacora_historial
			WHERE id_usuario IN
				(SELECT id_usuario FROM bdibpi:"informix".bpi_usuario
				WHERE numcliente = pNumCte)
				
				AND fecha_oper::date BETWEEN vfecha_limite_Inicio AND vfecha_limite_Fin
				
				AND (
						(	id_operacion IN (pIdOperacion,pIdOperacionFdh) ) 
						OR
						(						
							id_operacion = pIdOperacionProg
							AND sec_transaccion = pIdOperacion
						)	
				)
				ORDER BY fecha_oper DESC
			) ms2

			RETURN
				cod_ret,
				NVL(vfecha_oper,DATE(1)),
				NVL(vfecha_aplic,DATE(1)),
				NVL(vcuenta_origen,''),
				NVL(vdestino,''),
				NVL(vmonto_oper,''),
				NVL(vsec_transaccion,''),
				NVL(vcgenerico1,''),
				NVL(vcgenerico2,''),
				NVL(vcgenerico3,''),
				NVL(vcgenerico4,''),
				NVL(vcgenerico5,''),
				NVL(vcgenerico6,''),
				NVL(vreferencia,''),
				NVL(vfolio,''),
				NVL(vIdOperacion,''),
				NVL(vTotalRegistros,0)
				WITH RESUME;
		END FOREACH;
	ELSE
		LET cod_ret = '00100'; --PARAMETROS INCORRECTOS

		RETURN cod_ret,
				NVL(vfecha_oper,DATE(1)),
				NVL(vfecha_aplic,DATE(1)),
				NVL(vcuenta_origen,''),
				NVL(vdestino,''),
				NVL(vmonto_oper,''),
				NVL(vsec_transaccion,''),
				NVL(vcgenerico1,''),
				NVL(vcgenerico2,''),
				NVL(vcgenerico3,''),
				NVL(vcgenerico4,''),
				NVL(vcgenerico5,''),
				NVL(vcgenerico6,''),
				NVL(vreferencia,''),
				NVL(vfolio,''),
				NVL(vIdOperacion,''),
				NVL(vTotalRegistros,0);
	END IF;
END;
END PROCEDURE;