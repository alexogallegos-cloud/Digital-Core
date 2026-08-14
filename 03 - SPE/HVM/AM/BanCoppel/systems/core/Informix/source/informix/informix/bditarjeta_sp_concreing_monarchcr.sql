CREATE PROCEDURE "informix".sp_concreing_monarchcr
(
psFlag CHAR(1),
psUsuario CHAR(8),
pdFecha DATE
)

RETURNING CHAR(5), CHAR(23), CHAR(3), CHAR(20), CHAR(10), CHAR(16), CHAR(10), CHAR(25), CHAR(25), CHAR(25), CHAR(25), CHAR(25), CHAR(25), CHAR(25), CHAR(25),
CHAR(1), CHAR(1), CHAR(1), CHAR(20), CHAR(16), CHAR(20), CHAR(16), CHAR(1), INTEGER, INTEGER;

--***********************************************************************************************************
-- DESCRIPCION: Realiza consulta para obtener detalle de los archivos de conciliacion, y para realizar
--              un paro de emergencia en caso de necesitarse.
-- AUTOR : EDGAR IVAN ROCHIN ROCHA
-- FECHA : 2011/10/24
-- BD: bditarjeta
-- SISTEMA : Conciliacion Reingenieria
--***********************************************************************************************************

DEFINE vsnombrearchivo			CHAR(23);
DEFINE vsarchivo_origen			CHAR(3);
DEFINE vsnum_registros325			CHAR(20);
DEFINE vsfecha_archivo			CHAR(10);
DEFINE vsmonto325					CHAR(16);
DEFINE vsfecha_proceso			CHAR(10);
DEFINE vsfecha_hora_transferencia	CHAR(25);
DEFINE vsfecha_hora_ini_proceso	CHAR(25);
DEFINE vsfecha_hora_carga_archivo	CHAR(25);
DEFINE vsfecha_hora_carga_tabla	CHAR(25);
DEFINE vsfecha_hora_ini_concilia_reg	CHAR(25);
DEFINE vsfecha_hora_fin_concilia_reg	CHAR(25);
DEFINE vsfecha_hora_fin_proceso	CHAR(25);
DEFINE vsfecha_hora_gen_conadmin	CHAR(25);
DEFINE vstransferencia			CHAR(1);
DEFINE vscarga					CHAR(1);
DEFINE vsconadmin					CHAR(1);
DEFINE vsnum_cargo				CHAR(20);
DEFINE vsmonto_cargo				CHAR(16);
DEFINE vsnum_abono				CHAR(20);
DEFINE vsmonto_abono				CHAR(16);
DEFINE vsproceso					CHAR(1);
DEFINE dtfecha_hoy_integral 		DATE;
DEFINE viordenproceso			INTEGER;
DEFINE vicron					INTEGER;

DEFINE vsCodRet CHAR(5);
DEFINE viSqlErr INTEGER;

LET vsnombrearchivo = "";
LET vsarchivo_origen = "";
LET vsnum_registros325 = "";
LET vsfecha_archivo = "";
LET vsmonto325 = "";
LET vsfecha_proceso = "";
LET vsfecha_hora_transferencia = "";
LET vsfecha_hora_ini_proceso = "";
LET vsfecha_hora_carga_archivo = "";
LET vsfecha_hora_carga_tabla = "";
LET vsfecha_hora_ini_concilia_reg = "";
LET vsfecha_hora_fin_concilia_reg = "";
LET vsfecha_hora_fin_proceso = "";
LET vsfecha_hora_gen_conadmin = "";
LET vstransferencia = "";
LET vscarga = "";
LET vsconadmin = "";
LET vsnum_cargo = "";
LET vsmonto_cargo = "";
LET vsnum_abono = "";
LET vsmonto_abono = "";
LET vsproceso = "";
LET dtfecha_hoy_integral = CURRENT::DATE;
LET viordenproceso = 0;
LET vicron = 0;

LET vsCodRet = "00000";
LET viSqlErr = 0;

--SET DEBUG FILE TO "/dbexport/sp_concreing_monarchcr.sql";
--TRACE ON;

BEGIN

ON EXCEPTION SET viSqlErr   --Cacha el error en caso de que exista y regresa un valor predeterminado
	IF viSqlErr <> 0 THEN
		RETURN viSqlErr, vsnombrearchivo, vsarchivo_origen, vsnum_registros325, vsfecha_archivo, vsmonto325, vsfecha_proceso,
			   vsfecha_hora_transferencia, vsfecha_hora_ini_proceso, vsfecha_hora_carga_archivo, vsfecha_hora_carga_tabla,
			   vsfecha_hora_ini_concilia_reg, vsfecha_hora_fin_concilia_reg, vsfecha_hora_fin_proceso, vsfecha_hora_gen_conadmin,
			   vstransferencia, vscarga, vsconadmin, vsnum_cargo, vsmonto_cargo, vsnum_abono, vsmonto_abono, vsproceso, 0, 0;
	END IF;
END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	--OBTIENE LA FECHA HOY DEL SISTEMA CENTRAL INTEGRAL
	SELECT LIMIT 1 Fecha_Hoy INTO dtfecha_hoy_integral FROM bdinteg:"informix".Si_Fechas;

	--Obtiene registros de tabla con proceso diferente a V.
	IF(psFlag = "1")THEN
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT
			nombrearchivo, archivo_origen, num_registros325, fecha_archivo, monto325, fecha_proceso,
			fecha_hora_transferencia, fecha_hora_carga_tabla /*fecha_hora_ini_proceso*/, fecha_hora_carga_archivo, fecha_hora_carga_tabla,
			fecha_hora_ini_concilia_reg, fecha_hora_fin_concilia_reg, fecha_hora_fin_proceso, fecha_hora_gen_conadmin,
			transferencia, carga, conadmin, num_cargo, monto_cargo, num_abono, monto_abono, proceso
			INTO
			vsnombrearchivo, vsarchivo_origen, vsnum_registros325, vsfecha_archivo, vsmonto325, vsfecha_proceso,
			vsfecha_hora_transferencia, vsfecha_hora_ini_proceso, vsfecha_hora_carga_archivo, vsfecha_hora_carga_tabla,
			vsfecha_hora_ini_concilia_reg, vsfecha_hora_fin_concilia_reg, vsfecha_hora_fin_proceso, vsfecha_hora_gen_conadmin,
			vstransferencia, vscarga, vsconadmin, vsnum_cargo, vsmonto_cargo, vsnum_abono, vsmonto_abono, vsproceso
			FROM bditarjeta:"informix".td_archivos_conciliacion 
			WHERE Proceso <> 'T' 
			OR Fecha_Proceso = dtfecha_hoy_integral
			ORDER BY proceso

			RETURN vsCodRet, vsnombrearchivo, vsarchivo_origen, vsnum_registros325, vsfecha_archivo, vsmonto325, vsfecha_proceso,
				   vsfecha_hora_transferencia, vsfecha_hora_ini_proceso, vsfecha_hora_carga_archivo, vsfecha_hora_carga_tabla,
				   vsfecha_hora_ini_concilia_reg, vsfecha_hora_fin_concilia_reg, vsfecha_hora_fin_proceso, vsfecha_hora_gen_conadmin,
				   vstransferencia, vscarga, vsconadmin, vsnum_cargo, vsmonto_cargo, vsnum_abono, vsmonto_abono, vsproceso, 0, 0 WITH RESUME;
		END FOREACH
	--Obtiene registros con proceso igual a P.
	ELIF (psFlag = "2")THEN
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT
			archori.orden_proceso, 
			(CASE WHEN archcon.fecha_archivo = (dtfecha_hoy_integral::DATE - archori.dias_desfase)::DATE THEN archori.horario_ejecucion_hoy ELSE archori.horario_ejecucion_ext END) AS cron,
			archcon.nombrearchivo, archcon.archivo_origen, archcon.fecha_hora_carga_tabla /*archcon.fecha_hora_ini_proceso*/, archcon.fecha_hora_carga_archivo, archcon.fecha_hora_carga_tabla, archcon.fecha_hora_ini_concilia_reg,
			archcon.fecha_hora_fin_concilia_reg, archcon.fecha_hora_fin_proceso, archcon.fecha_hora_gen_conadmin, archcon.carga, archcon.conadmin, archcon.proceso
			INTO
			viordenproceso, vicron, vsnombrearchivo, vsarchivo_origen, vsfecha_hora_ini_proceso, vsfecha_hora_carga_archivo, vsfecha_hora_carga_tabla, vsfecha_hora_ini_concilia_reg, 
			vsfecha_hora_fin_concilia_reg, vsfecha_hora_fin_proceso, vsfecha_hora_gen_conadmin, vscarga, vsconadmin, vsproceso
			FROM bditarjeta:"informix".td_archivos_conciliacion AS archcon LEFT JOIN BdiTarjeta:"informix".td_archivo_origentmp AS archori
			ON archcon.archivo_origen = archori.archivo_origen
			WHERE proceso = 'P'
			ORDER BY cron, archori.orden_proceso
					
			RETURN vsCodRet, vsnombrearchivo, vsarchivo_origen, '', '', '', '', '', vsfecha_hora_ini_proceso, vsfecha_hora_carga_archivo, 
					vsfecha_hora_carga_tabla, vsfecha_hora_ini_concilia_reg, vsfecha_hora_fin_concilia_reg, vsfecha_hora_fin_proceso, 
					vsfecha_hora_gen_conadmin, '', vscarga, vsconadmin, '', '', '', '', vsproceso, viordenproceso, vicron WITH RESUME;
		END FOREACH
		
	--Actualiza en F la conciliacion automatica en caso de paro de emergencia e inserta en bitacora hora, actividad, usuario.
	ELIF (psFlag = "3")THEN
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		UPDATE bditarjeta:"informix".td_param_conciliacion_concreing SET valor = 'F' WHERE codigo = '002';
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora (8, 'PARO DE EMERGENCIA EN CONCILIACION AUTOMATICA', psUsuario) INTO vsCodRet;
		RETURN vsCodRet, vsnombrearchivo, vsarchivo_origen, vsnum_registros325, vsfecha_archivo, vsmonto325, vsfecha_proceso,
			   vsfecha_hora_transferencia, vsfecha_hora_ini_proceso, vsfecha_hora_carga_archivo, vsfecha_hora_carga_tabla,
			   vsfecha_hora_ini_concilia_reg, vsfecha_hora_fin_concilia_reg, vsfecha_hora_fin_proceso, vsfecha_hora_gen_conadmin,
			   vstransferencia, vscarga, vsconadmin, vsnum_cargo, vsmonto_cargo, vsnum_abono, vsmonto_abono, vsproceso, 0, 0;
	END IF;

END
END PROCEDURE
DOCUMENT
'AUTOR: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Conciliacion Reingenieria',
'Solicito: Luis Gomez',
'Descripcion: Realiza consulta para obtener detalle de los archivos de conciliacion, y para realizar un paro de emergencia en caso de necesitarse.',
'Fecha: 2011/10/24',
'Version: 20111024.1800',
'BD: bditarjeta',
'',
'MODIFICADO: Casanova Edeza Hector Juan',
'Proyecto: Conciliacion Reingenieria',
'Solicito: Luis Gomez',
'Descripcion: Se quito el campo fecha de los criterios de busqueda y se dejo solamente el campo proceso.',
'Fecha: 2012/03/17',
'Version: 20120317.1557',
'BD: bditarjeta',
'',
'MODIFICADO: Casanova Edeza Hector Juan',
'Proyecto: Conciliacion Reingenieria',
'Solicito: Luis Gomez',
'Descripcion: SE MODIFICO EL CRITERIO DEL FILTRO PARA LA CONSULTA DE LOS ARCHIVOS PENDIENTES QUE CORRESPONDAN CON EL DIA ACTUAL, ADEMAS SE CAMBIA LA FECHA INI_PROCESO POR LA DE CARGA_ARCHIVO, PARA INDICAR EL INICIO DE TRABAJO DE CADA ARCHIVO.',
'Fecha: 2012/06/27',
'Version: 20120627.1637',
'BD: bditarjeta';

CREATE PROCEDURE "informix".sp_concreing_obtenerfechauhora(
	psTipo INTEGER,
	psSeparador CHAR(2)
)

	RETURNING CHAR(5) AS Retorno, CHAR (25) AS FechaHora;

	/*
	*****************************************************************************************************
    -- DESCRIPCION:  OBTIENE LA FECHA U HORA DEL SISTEMA SERVIDOR  --------------------------------------
	-- AUTOR : Ing. Alfonso Cruz  -----------------------------------------------------------------------
	-- FECHA : 30/06/2011  ------------------------------------------------------------------------------
	-- BD: bditarjeta  ----------------------------------------------------------------------------------
	-- SISTEMA : Reingenieria de la conciliacion automatica / Utilerias  --------------------------------
	*****************************************************************************************************
		PARAMETROS
		pSeparador = 	caracter separador
		TIPO
		0 - FECHA HORA COMPLETA DD/MM/AAAA hh:mm:ss
		1 - FECHA COMPLETA DD/MM/AAAA
		2 - FECHA COMPLETA MM/DD/AAAA
		3 - FECHA COMPLETA AAAA/MM/DD
		4 - FECHA COMPLETA AAAA/DD/MM
		5 - AÑO AAAA
		6 - AÑO AA
		7 - MES MM
		8 - DIA DD
		9 - HORA hh
		10 - MINUTOS mm
		11 - SEGUNDOS ss
		12 - MILISEGUNDOS zzz
		13 - HORA COMPLETA hh:mm:ss
		14 - HORA Y MINUTOS hh:mm
		15 - FECHA CON HORA MMDDhhmm
	*/

	/*DEFINICION DE VARIABLES*/

	/*VARIABLES DE RETORNO*/
	DEFINE visqlerr CHAR(5) ;
	DEFINE viCodigo INTEGER;

	DEFINE vsFechaHora CHAR(25);
	DEFINE vsAnio CHAR(4);
	DEFINE vsMes CHAR(2);
	DEFINE vsDia CHAR(2);
	DEFINE vsHora CHAR(2);
	DEFINE vsMinuto CHAR(2);
	DEFINE vsSegundo CHAR(2);
	DEFINE vsMilisegundos CHAR(3);


        SET LOCK MODE TO WAIT 3;
        SET ISOLATION TO DIRTY READ ;

    /*INICIALIZACION DE VARIABLES*/

	LET visqlerr = '00000';
	LET viCodigo = 0;

	LET vsFechaHora = CAST ( (SELECT DBINFO('utc_to_datetime', Sh_Curtime)::DATETIME YEAR TO FRACTION(5)
		FROM SysMaster:"informix".Sysshmvals) AS CHAR(25));
	LET vsAnio = '';
	LET vsMes = '' ;
	LET vsDia = '' ;
	LET vsHora = '' ;
	LET vsMinuto = '' ;
	LET vsSegundo = '' ;
	LET vsMilisegundos = '';

	BEGIN

		ON EXCEPTION SET viCodigo   --cacha el error en caso de que exista y regresa un valor predeterminado

				LET visqlerr = viCodigo;
				RETURN visqlerr, vsFechaHora;

		END EXCEPTION;

		--SET DEBUG FILE TO '/home/sysifx/concreing/TraceOBTFECHAHORA.sql';
		--SET DEBUG FILE TO '/tmp/conciliacion/TraceSP_OBTFECHAHORA.txt';
		--TRACE ON;



		LET vsAnio = SUBSTRING ( vsFechaHora FROM 1 FOR 4 ) ;
		LET vsMes = SUBSTRING ( vsFechaHora FROM 6 FOR 2 );
		LET vsDia = SUBSTRING ( vsFechaHora FROM 9 FOR 2 );
		LET vsHora = SUBSTRING ( vsFechaHora FROM 12 FOR 2 );
		LET vsMinuto = SUBSTRING ( vsFechaHora FROM 15 FOR 2 );
		LET vsSegundo = SUBSTRING ( vsFechaHora FROM 18 FOR 2 );
		LET vsMilisegundos = SUBSTRING ( vsFechaHora FROM 21 FOR 3 );


		IF (psTipo = 0) THEN
			LET vsFechaHora = vsDia || TRIM ( psSeparador ) || vsMes || TRIM ( psSeparador ) || vsAnio || ' ' || vsHora || ':' || vsMinuto  || ':' || vsSegundo;
		ELIF (psTipo = 1) THEN
			LET vsFechaHora = vsDia || TRIM ( psSeparador ) || vsMes || TRIM ( psSeparador ) || vsAnio;
		ELIF (psTipo = 2) THEN
			LET vsFechaHora = vsMes || TRIM ( psSeparador ) || vsDia || TRIM ( psSeparador ) || vsAnio;
		ELIF (psTipo = 3) THEN
			LET vsFechaHora = vsAnio || TRIM ( psSeparador ) || vsMes || TRIM ( psSeparador ) || vsDia;
		ELIF (psTipo = 4) THEN
			LET vsFechaHora = vsAnio || TRIM ( psSeparador ) || vsDia || TRIM ( psSeparador ) || vsMes;
		ELIF (psTipo = 5) THEN
			LET vsFechaHora = vsAnio;
		ELIF (psTipo = 6) THEN
			LET vsFechaHora = SUBSTRING ( vsAnio FROM 3 FOR 2 );
		ELIF (psTipo = 7) THEN
			LET vsFechaHora = vsMes;
		ELIF (psTipo = 8) THEN
			LET vsFechaHora = vsDia;
		ELIF (psTipo = 9) THEN
			LET vsFechaHora = vsHora;
		ELIF (psTipo = 10) THEN
			LET vsFechaHora = vsMinuto;
		ELIF (psTipo = 11) THEN
			LET vsFechaHora = vsSegundo;
		ELIF (psTipo = 12) THEN
			LET vsFechaHora = vsMilisegundos;
		ELIF (psTipo = 13) THEN
			LET vsFechaHora = vsHora || ':' || vsMinuto  || ':' || vsSegundo;
		ELIF (psTipo = 14) THEN
			LET vsFechaHora = vsHora || ':' || vsMinuto ;
		ELIF (psTipo = 15) THEN
			LET vsFechaHora = vsMes || TRIM ( psSeparador ) || vsDia || TRIM(psSeparador) || vsHora || TRIM(psSeparador) || vsMinuto  ;
		ELSE
			LET visqlerr = '0-100';
		END IF;


		/*RETORNO DEL PROCEDIMIENTO ALMACENADO*/
	RETURN visqlerr, vsFechaHora;

	END

END PROCEDURE
DOCUMENT
'AUTOR: Ing. Alfonso Cruz',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: OBTIENE LA FECHA CON EL FORMATO INDICADO.',
'Fecha: 2011/06/30',
'Version: 20110630.0230',
'BD: bditarjeta';

CREATE PROCEDURE "informix".sp_conarchivos_con(cparam1 char(1),cTipo char(3),dfecha_ini date,dfecha_fin date,cUsuario char(10),cNumEmpl varchar(9))
RETURNING VARCHAR(6) as Cod_ret,VARCHAR(80) as Men_ret,
     char(23) as nombrearchivo,        
     char(3)  as archivo_origen,      
     date     as fecha_archivo, 
     integer  as num_registros325,
     money(16,2) as monto325,       
     date     as fecha_proceso,  
     datetime year to fraction(5)  as fecha_hora_transferencia,       
     datetime year to fraction(5)  as fecha_hora_ini_proceso,      
     datetime year to fraction(5)  as fecha_hora_carga_archivo,      
     datetime year to fraction(5)  as fecha_hora_carga_tabla,
     datetime year to fraction(5)  as fecha_hora_ini_concilia_reg,
     datetime year to fraction(5)  as fecha_hora_fin_concilia_reg,
     datetime year to fraction(5)  as fecha_hora_fin_proceso,
     datetime year to fraction(5)  as fecha_hora_gen_conadmin,
     char(1) as transferencia,
     char(1) as carga,
     char(1) as conadmin,
     integer as num_cargo,
     money(16,2)  as monto_cargo,
     integer as num_abono,
     money(16,2)  as monto_abono,
     char(1) as proceso;


	DEFINE  SQL_ERR          INTEGER;
	DEFINE  ISAM_ERR         INTEGER;
	DEFINE  ERROR_INFO       VARCHAR(80);
	DEFINE  P_COD_RET        VARCHAR(6);
	DEFINE  P_COD_RET2        VARCHAR(6);
	DEFINE  P_MENSAJE        VARCHAR(80);
	DEFINE c_nombrearchivo char(23);
	DEFINE c_archivo_origen char(3);
	DEFINE d_fecha_archivo date;
	DEFINE i_num_registros325 integer;
	DEFINE m_monto325 money(16,2);
	DEFINE d_fecha_proceso date;
	DEFINE d_fecha_hora_transferencia datetime year to fraction(5);
	DEFINE d_fecha_hora_ini_proceso datetime year to fraction(5);
	DEFINE d_fecha_hora_carga_archivo datetime year to fraction(5);
	DEFINE d_fecha_hora_carga_tabla datetime year to fraction(5);
	DEFINE d_fecha_hora_ini_concilia_reg datetime year to fraction(5);
	DEFINE d_fecha_hora_fin_concilia_reg datetime year to fraction(5);
	DEFINE d_fecha_hora_fin_proceso datetime year to fraction(5);
	DEFINE d_fecha_hora_gen_conadmin datetime year to fraction(5);
	DEFINE c_transferencia char(1);
	DEFINE c_carga char(1);
	DEFINE c_conadmin char(1);
	DEFINE i_num_cargo integer;
	DEFINE m_monto_cargo money(16,2);
	DEFINE i_num_abono integer;
	DEFINE m_monto_abono money(16,2);
	DEFINE c_proceso char(1);



	LET c_nombrearchivo = '';
	LET c_archivo_origen = '';
	LET d_fecha_archivo= '01-01-1900';
	LET i_num_registros325 = 0;
	LET m_monto325 = 0;
	LET d_fecha_proceso = '01-01-1900';
	LET d_fecha_hora_transferencia = '1900-01-01 00:00:00';
	LET d_fecha_hora_ini_proceso = '1900-01-01 00:00:00';
	LET d_fecha_hora_carga_archivo = '1900-01-01 00:00:00';
	LET d_fecha_hora_carga_tabla = '1900-01-01 00:00:00';
	LET d_fecha_hora_ini_concilia_reg = '1900-01-01 00:00:00';
	LET d_fecha_hora_fin_concilia_reg = '1900-01-01 00:00:00';
	LET d_fecha_hora_fin_proceso = '1900-01-01 00:00:00';
	LET d_fecha_hora_gen_conadmin = '1900-01-01 00:00:00';
	LET c_transferencia  = '';
	LET c_carga  = '';
	LET c_conadmin  = '';
	LET i_num_cargo  = 0;
	LET m_monto_cargo  = 0;
	LET i_num_abono  = 0;
	LET m_monto_abono  = 0;
	LET c_proceso  = '';
	
	--SET DEBUG FILE TO "/tmp/manuel/ejemplo_consarc";
	--TRACE ON;

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
	  
	  EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora('130','Error en sp_conarchivos_con ' || SQL_ERR || ' ' || P_MENSAJE,cNumEmpl) INTO P_COD_RET2;
      RETURN P_COD_RET,P_MENSAJE,c_nombrearchivo,c_archivo_origen,d_fecha_archivo,i_num_registros325,m_monto325,d_fecha_proceso,d_fecha_hora_transferencia,
				   d_fecha_hora_ini_proceso,d_fecha_hora_carga_archivo,d_fecha_hora_carga_tabla,d_fecha_hora_ini_concilia_reg,d_fecha_hora_fin_concilia_reg,
				   d_fecha_hora_fin_proceso,d_fecha_hora_gen_conadmin,c_transferencia,c_carga,c_conadmin,i_num_cargo,m_monto_cargo,i_num_abono,m_monto_abono,c_proceso;
   END EXCEPTION;

--************************************************************
-- Creado por Manuel Osuna Valencia 
-- fecha : 19/10/2011
-- Funcion: Consulta de Archivos de conciliación por fecha
--************************************************************

   LET P_COD_RET = '00000';
   LET P_COD_RET2 = '00000';
   LET P_MENSAJE = 'PROCESO EXITOSO';
   
   	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
   
   IF (cparam1 == 1) THEN --Consulta por Todos los archivos 

		FOREACH
						
			SELECT nombrearchivo,archivo_origen,fecha_archivo,num_registros325,monto325,fecha_proceso,fecha_hora_transferencia,
					fecha_hora_ini_proceso,fecha_hora_carga_archivo,fecha_hora_carga_tabla,fecha_hora_ini_concilia_reg,fecha_hora_fin_concilia_reg,
					fecha_hora_fin_proceso,fecha_hora_gen_conadmin,transferencia,carga,conadmin,num_cargo,monto_cargo,num_abono,monto_abono,proceso						
			INTO c_nombrearchivo,c_archivo_origen,d_fecha_archivo,i_num_registros325,m_monto325,d_fecha_proceso,d_fecha_hora_transferencia,
				 d_fecha_hora_ini_proceso,d_fecha_hora_carga_archivo,d_fecha_hora_carga_tabla,d_fecha_hora_ini_concilia_reg,d_fecha_hora_fin_concilia_reg,
				 d_fecha_hora_fin_proceso,d_fecha_hora_gen_conadmin,c_transferencia,c_carga,c_conadmin,i_num_cargo,m_monto_cargo,i_num_abono,m_monto_abono,c_proceso		
			FROM bditarjeta:"informix".td_archivos_conciliacion
			WHERE fecha_proceso BETWEEN dfecha_ini AND dfecha_fin
			
			
			RETURN P_COD_RET,P_MENSAJE,c_nombrearchivo,c_archivo_origen,d_fecha_archivo,i_num_registros325,m_monto325,d_fecha_proceso,d_fecha_hora_transferencia,
				   d_fecha_hora_ini_proceso,d_fecha_hora_carga_archivo,d_fecha_hora_carga_tabla,d_fecha_hora_ini_concilia_reg,d_fecha_hora_fin_concilia_reg,
				   d_fecha_hora_fin_proceso,d_fecha_hora_gen_conadmin,c_transferencia,c_carga,c_conadmin,i_num_cargo,m_monto_cargo,i_num_abono,m_monto_abono,c_proceso	with resume;	
								
		END FOREACH;
		
	ELIF (cparam1 == 2) THEN --Consulta un Archivo en especifico
	
		FOREACH
						
			SELECT nombrearchivo,archivo_origen,fecha_archivo,num_registros325,monto325,fecha_proceso,fecha_hora_transferencia,
					fecha_hora_ini_proceso,fecha_hora_carga_archivo,fecha_hora_carga_tabla,fecha_hora_ini_concilia_reg,fecha_hora_fin_concilia_reg,
					fecha_hora_fin_proceso,fecha_hora_gen_conadmin,transferencia,carga,conadmin,num_cargo,monto_cargo,num_abono,monto_abono,proceso						
			INTO c_nombrearchivo,c_archivo_origen,d_fecha_archivo,i_num_registros325,m_monto325,d_fecha_proceso,d_fecha_hora_transferencia,
				 d_fecha_hora_ini_proceso,d_fecha_hora_carga_archivo,d_fecha_hora_carga_tabla,d_fecha_hora_ini_concilia_reg,d_fecha_hora_fin_concilia_reg,
				 d_fecha_hora_fin_proceso,d_fecha_hora_gen_conadmin,c_transferencia,c_carga,c_conadmin,i_num_cargo,m_monto_cargo,i_num_abono,m_monto_abono,c_proceso		
			FROM bditarjeta:"informix".td_archivos_conciliacion
			WHERE 	archivo_origen = trim(cTipo)  
					and fecha_proceso BETWEEN dfecha_ini AND dfecha_fin 
			
			
			RETURN P_COD_RET,P_MENSAJE,c_nombrearchivo,c_archivo_origen,d_fecha_archivo,i_num_registros325,m_monto325,d_fecha_proceso,d_fecha_hora_transferencia,
				   d_fecha_hora_ini_proceso,d_fecha_hora_carga_archivo,d_fecha_hora_carga_tabla,d_fecha_hora_ini_concilia_reg,d_fecha_hora_fin_concilia_reg,
				   d_fecha_hora_fin_proceso,d_fecha_hora_gen_conadmin,c_transferencia,c_carga,c_conadmin,i_num_cargo,m_monto_cargo,i_num_abono,m_monto_abono,c_proceso	with resume;	
								
		END FOREACH;
		
	
 	
   
	END IF;

     
	
  
END;
END PROCEDURE
DOCUMENT
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Luis Gomez Santiago',
'Descripcion: SE MODIFICA EL FILTRO DE LA CONSULTA PARA UTILIZAR EL CAMPO DE FECHA PROCESO EN LUGAR DE FECHA ARCHIVO',
'Fecha: 2012/10/08',
'Version: 20121008.1830',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_concreing_movimientosretenidos ( pTipo CHAR(1), pdtFechaIni DATE, pdtFechaFin DATE)
RETURNING CHAR(5), CHAR(15),	DATETIME YEAR TO FRACTION(5), CHAR(20), MONEY(14,2), INTEGER;

--************************************************************
-- Creado por Adilene Lara Armenta.
--12/ 10/2011
-- Funcion de Consulta de movimientos retenidos pendientes por liberar de cheques & credito.
-- Hector Juan Casanova Edeza -- 22/05/2012 -SE MODIFICO LA LOGICA DEL PROCEDIMIENTO PARA QUE HACEPTE LOS PARAMETROS DE FECHA INICIAL Y FINAL PARA ACOTAR EL ESPACIO DE BUSQUEDA DE LA CONSULTA.
-----------------------------------------------------------------------------

--Definición de Variables
	DEFINE cod_ret      CHAR(5);
	DEFINE sql_err      SMALLINT;
 
	DEFINE v_cuenta_credito           CHAR(15);
        DEFINE v_fecha_retencion         DATETIME YEAR TO FRACTION(5);
        DEFINE v_folio_retencion           CHAR(20);
        DEFINE v_monto_retenido          MONEY(14, 2);
        DEFINE v_dias_restantes_lib     INTEGER;
		
--Inicializacion de Variables

	LET cod_ret       = "000";
	LET sql_err       = "";

	LET v_cuenta_credito        = "";
	LET  v_fecha_retencion     = CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5));
	LET v_folio_retencion        = "";
	LET v_monto_retenido      = 0.00;
	LET v_dias_restantes_lib = 0;
        
BEGIN

--Control de Errores 

ON EXCEPTION SET sql_err
  LET cod_ret = sql_err;
  RETURN 	cod_ret,	"", CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5)), "", 0.00, 0;
END EXCEPTION;
	
	--SET DEBUG FILE TO '/home/sysifx/soporte/concreing/Tracemovimientosretenidos.sql';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	--CONSULTA DE MOVIMIENTOS RETENIDOS PENDIENTES POR LIBERAR

	FOREACH
		SELECT cuenta_credito, fecha_retencion, folio_retencion, monto_retenido, dias_restantes_lib 
		INTO   v_cuenta_credito, v_fecha_retencion, v_folio_retencion, v_monto_retenido, v_dias_restantes_lib
		FROM bditarjeta:"informix".td_retenidos
		WHERE tipo = NVL(pTipo,'')
		AND fecha_retencion BETWEEN NVL(pdtFechaIni, '01/01/1900') AND NVL(pdtFechaFin, '01/01/1900')
		ORDER BY fecha_retencion
		
		 RETURN 	cod_ret, NVL(v_cuenta_credito, ""), NVL(v_fecha_retencion, CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5))), NVL(v_folio_retencion, ""), 
											NVL (v_monto_retenido, 0.00), NVL(v_dias_restantes_lib, 0) WITH RESUME;


	END FOREACH;
	
END;
END PROCEDURE
DOCUMENT
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Luis Gomez Santiago',
'Descripcion: SE MODIFICO LA LOGICA DEL PROCEDIMIENTO PARA QUE HACEPTE LOS PARAMETROS DE FECHA INICIAL Y FINAL PARA ACOTAR EL ESPACIO DE BUSQUEDA DE LA CONSULTA.',
'Fecha: 2012/05/22',
'Version: 20120522.1023',
'BD: BdiTarjeta',
'MODIFICACION: Ricardo Reséndiz Martinez',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Luis Gomez Santiago',
'Descripcion: SE AGREGO ORDENAMIENTO DE CONSULTA POR DIAS DE RETENCION',
'Fecha: 2012/05/22',
'Version: 20120522.1023',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_concreing_obtenermovretenido ( )
RETURNING VARCHAR (5) AS CodRet, VARCHAR(250) AS Mensaje_Respuesta;

--****************************************************************************************************
-- DESCRIPCION:  OBTIENE MOVIMIENTOS RETENIDOS PENDIENTES POR LIBERAR
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 02/10/2011
-- BD: BdiTarjeta
-- SISTEMA : Reingenieria Conciliacion -- OBTENER MOVIMIENTOS RETENIDOS
-- MODIFICADO : 
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */
DEFINE vsSQL VARCHAR (200) ;
DEFINE viSQLerr INTEGER ;

DEFINE vsCodRet VARCHAR(5);
DEFINE vsMensaje_Respuesta VARCHAR(250);
DEFINE dtFecha_Hoy_Cheques DATE;
DEFINE dtFecha_Hoy_Credito DATE;


/* INICIALIZACION DE VARIABLES */
LET vsSQL = '' ;
LET viSQLerr = 0;    
  
LET vsCodRet = '00000';
LET vsMensaje_Respuesta = '';
LET dtFecha_Hoy_Cheques = CURRENT::DATE;
LET dtFecha_Hoy_Credito = CURRENT::DATE;

BEGIN

ON EXCEPTION SET viSQLerr
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	--LIMPIA LA TABLA
	DELETE FROM BdiTarjeta:"informix".Td_Carga_Archivo;
	LET vsCodRet = '03801';
	RETURN vsCodRet, ('[' || vsCodRet ||  '] ERROR NO CONTROLADO (' || viSQLerr || '). ' || TRIM(vsMensaje_Respuesta) );
	
END EXCEPTION;
	

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	LET vsMensaje_Respuesta = 'OBTENER FECHA CHEQUES.';
	SELECT LIMIT 1 Fecha_Hoy INTO dtFecha_Hoy_Cheques FROM BdiCheq:"informix".Sc_Fechas;
	
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	LET vsMensaje_Respuesta = 'OBTENER FECHA CREDITO.';
	SELECT LIMIT 1 Fecha_Hoy INTO dtFecha_Hoy_Credito FROM BdiCred:"informix".Sd_Fechas;
	
	
	LET vsMensaje_Respuesta = 'LIMPIAR TABLA DE TRABAJO.';
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	--LIMPIA LA TABLA
	--DELETE FROM BdiTarjeta:"informix".Td_Retenidos;
		IF EXISTS ( SELECT dbsname, tabname FROM sysmaster:SysTabNames  WHERE tabname = 'td_retenidos' AND dbsname= 'bditarjeta') THEN
			DROP TABLE bditarjeta:td_retenidos;
		END IF;
	
	create table "informix".td_retenidos
		(
			tipo char(1) default '' not null,
			cuenta_credito char(20) default '' not null,
			fecha_retencion date default '01/01/1900' not null,
			folio_retencion char(16) default '' not null,
			cve_usuario char(10) default '' not null,
			monto_retenido money default 0.0 not null,
			dias_restantes_lib integer default 0 not null,
			primary key(tipo, cuenta_credito, fecha_retencion, folio_retencion)
		)extent size 4192 next size 32 lock mode row;
	
	LET vsMensaje_Respuesta = 'LLENA LA TABLA DE TRABAJO.';
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	--GUARDA LOS MOVIMIENTOS PENDIENTES
	INSERT INTO BdiTarjeta:"informix".Td_Retenidos (Tipo, Cuenta_Credito, Fecha_Retencion, Folio_Retencion, Monto_Retenido, Dias_Restantes_Lib) 
		SELECT Tipo, Cuenta_Credito, Fecha_Retencion, Folio_Retencion, Monto_Retenido, Dias_Restantes_Lib 
		FROM TABLE ( 
			MULTISET 	(
				--OBTIENE MOVIMEINTOS DE CHEQUES
				SELECT "D" AS Tipo, Cuenta::VARCHAR(20) AS Cuenta_Credito, Fecha_Alta AS Fecha_Retencion, Folio_Suc::VARCHAR(16) AS Folio_Retencion, Monto AS Monto_Retenido, (fecha_alta-(dtFecha_Hoy_Cheques - Dias_Ret)) AS Dias_Restantes_Lib 
				FROM BdiCheq:"informix".Sc_DocRet 
				WHERE siglas in ('SD', 'SC')
					and Fecha_Alta between (dtFecha_Hoy_Cheques - 9) and (dtFecha_Hoy_Cheques - 2)
					and	Cancelado = 'P'
				UNION
				--OBTIENE MOVIMIENTOS DE CREDITO
				SELECT "C" AS Tipo, Num_Credito::VARCHAR(20) AS Cuenta_Credito, Fecha AS Fecha_Retencion, Folio_Suc::VARCHAR(16) AS Folio_Retencion, Monto AS Monto_Retenido, (fecha-(dtFecha_Hoy_Credito-Dias_Ret)) AS Dias_Restantes_Lib 
				FROM BdiCred:"informix".Sd_MaeRetenido
				WHERE 	Empresa = '001'
						and Estatus = 'P'
						and Fecha between (dtFecha_Hoy_Credito - 9) and(dtFecha_Hoy_Credito - 2)
						)
					);

	RETURN vsCodRet, DECODE (vsCodRet, '00000', '', vsMensaje_Respuesta);
	
END
END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: OBTIENE MOVIMIENTOS RETENIDOS PENDIENTES POR LIBERAR.',
'Fecha: 2011/11/02',
'Version: 20111102.11043',
'BD: BdiTarjeta',
'Modifico: Ricardo Resendiz Martinez',
'Proyecto: Reingenieria de la conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: Se optimizaron consultas y de delimitaron periodos',
'Fecha: 2012/10/12',
'BD: Bditarjeta';

CREATE PROCEDURE "informix".sp_tras_bitacorahis_con(cNumEmpl varchar(9))
RETURNING VARCHAR(6) as Cod_ret,VARCHAR(80) as Men_ret;
	DEFINE  SQL_ERR          INTEGER;
	DEFINE  ISAM_ERR         INTEGER;
	DEFINE  ERROR_INFO       VARCHAR(80);
	DEFINE  P_COD_RET        VARCHAR(6);
	DEFINE  P_COD_RET2        VARCHAR(6);
	DEFINE  P_MENSAJE        VARCHAR(80);
	DEFINE  iValor           INTEGER;
	DEFINE  dFechaFin        DATE;	
	DEFINE  iNumReg          INTEGER;
	
	--SET DEBUG FILE TO "/tmp/manuel/tras.out";
	--TRACE ON;

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
	  
	  EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora('46','Error en sp_tras_bitacorahis_con ' || SQL_ERR || ' ' || P_MENSAJE,cNumEmpl) INTO P_COD_RET2;
	  
      RETURN P_COD_RET,P_MENSAJE;
   END EXCEPTION;

--************************************************************
-- Creado por Manuel Osuna Valencia 
-- fecha : 19/10/2011
-- Funcion: Traspaso de Informacion de bitacora a historico 
--************************************************************

   LET P_COD_RET = '00000';
   LET P_COD_RET2 = '00000';
   LET P_MENSAJE = 'PROCESO EXITOSO TRASNFERENCIA DE BITACORA A HISTORICOS';
   LET iValor = 0;
   LET iNumReg = 0;
   
   	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
	SELECT valor INTO iValor FROM bditarjeta:"informix".td_param_conciliacion_concreing WHERE codigo = '402';
	
		
	IF (iValor == 0) THEN
	   LET P_COD_RET = '00000';
	   LET P_MENSAJE = 'NO EXISTEN DIAS A SUBSTRAER.. ';	
	ELSE
		
		SELECT fecha_hoy - iValor units day INTO dFechaFin   FROM bdinteg:"informix".si_fechas;				
		
		INSERT INTO bditarjeta:"informix".td_bitacora_conciliacion_his(consecutivo,elemento,fecha_hora,actividad,cve_usuario)
		SELECT consecutivo,elemento,fecha_hora,actividad,cve_usuario
		FROM bditarjeta:"informix".td_bitacora_conciliacion
		WHERE date(fecha_hora) <= dFechaFin;
						
		LET iNumReg =dbinfo("sqlca.sqlerrd2");
		
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora('46','Exito en Traspaso de  Bitacora a Historico (sp_tras_bitacorahis_con) ' || iNumReg  || ' ' || 'Registros Transferidos',cNumEmpl) INTO P_COD_RET;
				
		DELETE FROM bditarjeta:"informix".td_bitacora_conciliacion	WHERE date(fecha_hora) <= dFechaFin;	   

	
	END IF;
     
	RETURN P_COD_RET,P_MENSAJE;
  
END;
END PROCEDURE;