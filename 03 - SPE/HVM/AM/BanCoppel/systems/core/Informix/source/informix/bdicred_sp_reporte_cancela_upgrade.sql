CREATE PROCEDURE "informix".sp_reporte_cancela_upgrade(pFecha DATE)
    RETURNING CHAR(6)  AS Codigo_retorno, 
              CHAR(80) AS Mensaje;        

-- Proceso para la generación del reporte de la cancelación del marcaje de upgrade TDC Oro/Platino RQM 10 1062 
-- Modificado: Agosto 2018, Febrero 2019

DEFINE sql_err				INTEGER;
DEFINE iSqlErr              INTEGER;
DEFINE isam_err				INTEGER;
DEFINE iIsamErr             INTEGER;
DEFINE cErrorInfo           CHAR(80);
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE cnombre				CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnomarchivoEjecSql   CHAR(100);
DEFINE cSQL                 CHAR(3000);
DEFINE cSQL1                CHAR(3000);
DEFINE cSQL2                CHAR(3000);
DEFINE cSQL3                CHAR(3000);
DEFINE cruta                CHAR(100);
DEFINE cFechaGenArchivo     CHAR(8);
DEFINE mes                  CHAR(2);
DEFINE anio					CHAR(4);
DEFINE cfechacorte          DATE;
DEFINE dFechaHoy            DATE;
DEFINE cfech_corte          DATE;
DEFINE cfech1               CHAR(12);
DEFINE cfech2               CHAR(12);
DEFINE cCodRet              CHAR(6);
DEFINE cMensajeRet          VARCHAR(100,1);
DEFINE cEmpresa				CHAR(3);	

--Inicialización de variables
LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "PROCESO NO EXITOSO";
LET cCod_Ret                = '00000';
LET cMensaje                = "";
LET cruta                   = "";
LET cnombre					= "CANCELUPGRADE_";
LET cnomarchivo             = "";
LET cnomarchivo1			= "";
LET cnomarchivoEjecSql      = "";
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET mes                     = "";
LET anio					= "";
LET cfechacorte             = NULL;
LET dFechaHoy               = DATE(1);
LET cfech_corte             = NULL;
LET cfech1                  = NULL;
LET cfech2                  = NULL;
LET cCodRet                 = '00000';
LET cMensajeRet 			= '';
LET cEmpresa				= '001';

 BEGIN
   	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			RETURN cCodRet, cMensajeRet;
		END IF;
	END EXCEPTION;

	-- SET DEBUG FILE TO '/tmp/sp_reporte_cancela_upgrade.out';
    -- SET DEBUG FILE TO '/informix/jquintana/RQM1010622/logs/sp_reporte_cancela_upgrade.out';
	-- TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;    

	-- Obtener ruta del archivo
    SELECT valor INTO cruta
    FROM bdicred:"informix".sd_param 
	WHERE empresa = cEmpresa AND cod_param = '056';
	
	LET cruta = TRIM(cruta);
	
	SELECT fecha_hoy INTO dFechaHoy
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = cEmpresa; 
	
 	SELECT (fecha_hoy - 30) INTO cfech_corte
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = cEmpresa; 
	
	LET cfech1 = TO_CHAR(cfech_corte,'%m,%d,%Y');
	LET cfech2 = TO_CHAR(pFecha,'%m,%d,%Y');
	
    -- SE VALIDA SI LA FECHA PARAMETRO ES MAYOR A LA FECHA HOY.
	IF pFecha > dFechaHoy THEN 
	   LET cCod_Ret = '00002';
	   LET cMensaje = error_info; 
	   RETURN cCod_Ret, cMensaje ;
	END IF; 
	
	IF MONTH(pFecha) < 10 THEN
	   LET mes = '0' || MONTH(pFecha);
	ELSE 
	   LET mes = MONTH(pFecha); 
	END IF;
	
	LET anio = TO_CHAR(YEAR(pFecha));
	
	LET cFechaGenArchivo = mes || SUBSTR(anio,3,2);
        
	LET cSQL  = '';
	LET cSQL1 = '';
	LET cSQL2 = '';
	LET cSQL3 = ''; 
	LET cnomarchivo1 = '';
	LET cnomarchivo = '';
	LET cnomarchivoEjecSql = '';
	
	--Se definen nombres de archivos
	LET cnomarchivo1 = TRIM(cnombre)||TRIM(cFechaGenArchivo)||'_Aux'||'.txt ';
	LET cnomarchivo =  TRIM(cnombre)||TRIM(cFechaGenArchivo)||'.txt ';
    LET cnomarchivoEjecSql = 'Exec_Cancel_Upgrade.sql';

    LET cSQL='';
    LET cSQL = ' echo "Num Credito'||'|'||'Num Cliente'||'|'||'Num Tarjeta credito marcado'||'|'||'Nombre cliente' ||
            '|'||'Num sucursal'||'|'||'Fecha Ingreso'||'|'||'Fecha Cancelacion'||'|'||' " >>' || TRIM(cruta) || TRIM(cnomarchivo)||'';
    SYSTEM cSQL;
	
	--Se arma consulta para extraccion de datos										
	LET cSQL1 = 'echo " UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || '';																	 
	LET cSQL2 = " SELECT cu.num_credito, cu.numcte, cu.numerotarjeta, cu.nombre, st.sucursal, cu.fecha_insert, cu.fecha_cancelaupgrade " ||        
                " FROM bdicred:'informix'.sd_credito_upgrade cu " ||
				" JOIN intercard:'informix'.solicitudtarjeta st ON cu.numcte = st.numcliente AND cu.num_credito = st.numcuenta " ||
                " WHERE cu.empresa = '" || TRIM(cEmpresa) || "' AND cu.fecha_cancelaupgrade IS NOT NULL " ||
                " AND cu.resultado = '3' " ||
				" AND DATE(cu.fecha_cancelaupgrade) BETWEEN MDY( " || TRIM(cfech1) || " ) AND MDY( " || TRIM(cfech2) || "  ) " ||
				" AND st.fechasolicitud = (SELECT MAX(fechasolicitud) FROM intercard:'informix'.solicitudtarjeta WHERE numcliente = cu.numcte AND numcuenta = cu.num_credito) " ||
                " ORDER BY cu.num_credito ";
	
	LET cSQL3 = ' " >> '||TRIM(cruta)|| TRIM(cnomarchivoEjecSql);
	LET cSQL = '';
	LET cSQL =  TRIM(cSQL1) || ' ' || TRIM(cSQL2) || ' ' || TRIM(cSQL3);
    System cSQL;
	
	LET cSQL = '';
    LET cSQL='chmod 777 '|| TRIM(cruta)|| TRIM(cnomarchivoEjecSql);
    System cSQL;

	LET cSQL = '';
    let cSQL = 'dbaccess bdicred ' || TRIM(cruta) || TRIM(cnomarchivoEjecSql);
    System cSQL;

	LET cSql = '';
    LET cSql = "sed 's/|$//g' "|| TRIM(cruta) || TRIM(cnomarchivo1) || " >> " || TRIM(cruta) || TRIM(cnomarchivo);
    SYSTEM cSql;

	-- Borra el archivo de control.
    LET cSQL = '' ;
    LET cSQL = 'rm ' || TRIM(cruta) || TRIM(cnomarchivoejecsql) || ' ' || TRIM(cruta) || TRIM(cnomarchivo1);
    SYSTEM cSQL;

    LET cCod_Ret = '00000';
    LET cMensaje = 'PROCESO EXITOSO';

	RETURN cCod_Ret,cMensaje;

 END;

END PROCEDURE

DOCUMENT
'-------------------------------------------------------------------------------------------------------------',
'-- CONTROL DE CAMBIOS',
'-------------------------------------------------------------------------------------------------------------',
'-- Modificó: Jorge Humberto Quintana Santiesteban',
'-- Fecha de Modificación: 28-02-2019',
'-- Descripción: Se modifica el nuevo campo Número de Sucursal del reporte:',
'--              	De Número de sucursal de origen de Tarjeta marcada',
'--              	A Número de sucursal donde se ingresó la TDC Oro/Platinum cancelada.',
'-- RQ: RQM 10 1062-2 - IMPLEMENTACIÓN - ADENDUM - Cancelación del marcaje de upgrade TDC Oro/Platinum (28960)',
'-- CC Rational: 30283',
'-------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_depura_sd_movhis_auto()
       RETURNING char(6);

--declaracion de variables
----------------------------------------------------------------------------------------------
DEFINE sql_err 		INTEGER;
DEFINE isam_err 	INTEGER;
DEFINE error_info	CHAR(150);
DEFINE cMensaje 	CHAR(150);
DEFINE cCod_ret     CHAR(6);
DEFINE vrowid       INTEGER;
DEFINE VlNumCredito	CHAR(20);
DEFINE iCont		INTEGER;
DEFINE cValor		CHAR(1);
DEFINE dFecha		DATE;	

	--SET DEBUG FILE TO "/informix/c91691184/sp_depura_sd_movhis_auto.out";
    --TRACE ON; 

	LET cCod_ret    = '000000';
	LET sql_err     = 0;
	LET isam_err    = 0;
	LET error_info	= '';
	LET cMensaje    = 'PROCESO EXITOSO';
	LET iCont		= 0;
	LET cValor		= '';

	BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
		LET cCod_ret = sql_err;
		LET cMensaje = error_info;
		RETURN cCod_ret;
	END EXCEPTION;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO wait 3;

	select valor into cValor 
	from "informix".sd_param 
	where empresa = '001' and cod_param = 'DT6';

	LET cValor = trim(cValor);

	select date((pri_dia_mes - 1 units year) - 1 units day) into dFecha 
	from "informix".sd_fechas
	where empresa = '001';

	select count(*) into iCont 
	from "informix".temp_creditos_depurar6;

	if iCont > 0 and cValor = '1' then

		update "informix".sd_param set valor = '2'
		where empresa = '001' and cod_param = 'DT6';

	ELIF iCont > 0 and cValor = '0' then

		LET cCod_ret = '000001';
		RETURN cCod_ret;

	end if;

    FOREACH WITH HOLD

		select num_credito
		into VlNumCredito  
		from "informix".temp_creditos_depurar6

		BEGIN WORK;

			DELETE FROM bdicred:"informix".sd_movhis 
			WHERE empresa = '001' and  num_credito = VlNumCredito and fecha_mov <= dFecha;
			delete from "informix".temp_creditos_depurar6 where num_credito = VlNumCredito;

		COMMIT WORK;

	END FOREACH;

	update "informix".sd_param set valor = '0'
	where empresa = '001' and cod_param = 'DT6';

	RETURN cCod_ret;

	END;

END PROCEDURE;