CREATE PROCEDURE "informix".sp_consulta_archivos_transfer (
								pIdOpcion INTEGER, 
								pFechaInicial DATE, 
								pFechaFin DATE, 
								pArchivoOrigen CHAR (3)
								)

--RETORNOS
RETURNING 
CHAR(5) 	AS CodRet,
CHAR(100)	AS MensajeRet,
CHAR(50) 	AS Nombre_Archivo,
CHAR(3) 	AS Achivo_Origen,
DATE 		AS Fecha_Archivo,
INTEGER 	AS Num_Registros,
DATE  		AS Fecha_Integracion,
DATE  		AS Fecha_Transferencia,
CHAR(1) 	AS Tranferencia,
CHAR(1) 	AS Carga,
CHAR(1) 	AS Proceso,
CHAR(1) 	AS Edo_Seguridad;

--DECLARACIONES DE VARIABLES
DEFINE cCodRet        		CHAR(5);
DEFINE cMensajeRet			CHAR(100);
DEFINE cNombreArchivo 		CHAR(50);
DEFINE cArchivoOrigen 		CHAR(3);
DEFINE dtFechaArchivo 		DATE;
DEFINE dtFechaSistema  		DATE;
DEFINE iNumeroRegistros 	INTEGER;
DEFINE dtFechaIntegracion 	DATE;
DEFINE dtFechaTransferencia DATE;
DEFINE cTransferencia		CHAR(1);
DEFINE cCarga           	CHAR(1);
DEFINE cProceso         	CHAR(1);
DEFINE cEdoSeguridad    	CHAR(1);
DEFINE iSqlErr 				INTEGER; 

--INICIALIZACION DE VARIABLES
LET cCodRet 				= '00000';
LET cMensajeRet 			= "EXITO";
LET cNombreArchivo 			= "";
LET cArchivoOrigen 			= "";
LET dtFechaArchivo 			= DATE(1);
LET iNumeroRegistros 		= 0;
LET dtFechaIntegracion 		= DATE(1);
LET dtFechaSistema 			= DATE(1);
LET dtFechaTransferencia	= DATE(1);
LET cTransferencia 			= "";
LET cCarga 					= "";
LET cProceso 				= "";
LET cEdoSeguridad 			= ""; 
LET iSqlErr 				= 0;

--SET DEBUG FILE TO '/respaldosbd/raulpacheco/sp_consulta_archivos_transfer.out'; 
--TRACE ON;

BEGIN 

	ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensajeRet="OCURRIO UN ERROR NO CONTROLADO";
				RETURN  TRIM(NVL(cCodRet,"")), TRIM(NVL(cMensajeRet,"")), TRIM(NVL(cNombreArchivo,"")), TRIM(NVL(cArchivoOrigen,"")), NVL(dtFechaArchivo,""), NVL(iNumeroRegistros,0), NVL(dtFechaIntegracion,""), NVL(dtFechaTransferencia,""),TRIM(NVL(cTransferencia,"")), TRIM(NVL(cCarga,"")), TRIM(NVL(cProceso,"")), TRIM(NVL(cEdoSeguridad,""));
			END IF;
	END EXCEPTION;
	
		
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO dirty READ;
	
	SELECT fecha_hoy
	INTO dtFechaSistema
	FROM bdinteg:"informix".si_fechas
	WHERE empresa = "001";

	--VALIDA QUE LOS PARAMETROS VENGAN CON UNE VALOR CORRECTO
	IF NVL(pIdOpcion,0) NOT IN (1,2) THEN	
		LET cCodRet = "00001"; --PARAMETROS  ERRONEOS
		LET cMensajeRet ="VALOR NO ACEPTADO PARA EL TIPO DE OPCION";		
		RETURN  TRIM(NVL(cCodRet,"")), TRIM(NVL(cMensajeRet,"")), TRIM(NVL(cNombreArchivo,"")), TRIM(NVL(cArchivoOrigen,"")), NVL(dtFechaArchivo,""), NVL(iNumeroRegistros,0), NVL(dtFechaIntegracion,""), NVL(dtFechaTransferencia,""),TRIM(NVL(cTransferencia,"")), TRIM(NVL(cCarga,"")), TRIM(NVL(cProceso,"")), TRIM(NVL(cEdoSeguridad,""));			
	END IF;
		
	--SE VALIDA LA OPCION QUE SE USARA EN LOS RADIO BUTTON SI ES 0 ES LA OPCION CONSULTA DIA ACTUAL
	IF  NVL(pIdOpcion,0) = 1 THEN
			--SE VALIDA SI EL PARAMETRO DE ARCHIVO ORIGEN VIENE VASIO O DIFERENTE A VACIO
		IF TRIM(NVL(pArchivoOrigen, "")) <> "" THEN 
			FOREACH	
				SELECT nombrearchivo, archivo_origen, fecha_archivo, num_registros, fecha_hora_ini_integracion_reg,   fecha_hora_transferencia, transferencia, carga, proceso, b_seguridad
				INTO  cNombreArchivo, cArchivoOrigen, dtFechaArchivo, iNumeroRegistros, dtFechaIntegracion,dtFechaTransferencia, cTransferencia, cCarga, cProceso, cEdoSeguridad
				FROM "informix".tf_archivos_transfer 
				WHERE fecha_archivo = dtFechaSistema
				AND archivo_origen = pArchivoOrigen
				
				 
				RETURN  TRIM(NVL(cCodRet,"")), TRIM(NVL(cMensajeRet,"")), TRIM(NVL(cNombreArchivo,"")), TRIM(NVL(cArchivoOrigen,"")), NVL(dtFechaArchivo,""), NVL(iNumeroRegistros,0), NVL(dtFechaIntegracion,""), NVL(dtFechaTransferencia,""),TRIM(NVL(cTransferencia,"")), TRIM(NVL(cCarga,"")), TRIM(NVL(cProceso,"")), TRIM(NVL(cEdoSeguridad,"")) WITH RESUME;
					
			END FOREACH;
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
					
				LET cCodRet= "00005";
				LET cMensajeRet="NO EXISTEN DATOS";
					
				RETURN  TRIM(NVL(cCodRet,"")), TRIM(NVL(cMensajeRet,"")), TRIM(NVL(cNombreArchivo,"")), TRIM(NVL(cArchivoOrigen,"")), NVL(dtFechaArchivo,""), NVL(iNumeroRegistros,0), NVL(dtFechaIntegracion,""), NVL(dtFechaTransferencia,""),TRIM(NVL(cTransferencia,"")), TRIM(NVL(cCarga,"")), TRIM(NVL(cProceso,"")), TRIM(NVL(cEdoSeguridad,""));
					
			END IF;
	
			
		ELSE 	
			FOREACH
				
				SELECT nombrearchivo, archivo_origen, fecha_archivo, num_registros, fecha_hora_ini_integracion_reg,   fecha_hora_transferencia, transferencia, carga, proceso, b_seguridad
				INTO  cNombreArchivo, cArchivoOrigen, dtFechaArchivo, iNumeroRegistros, dtFechaIntegracion,dtFechaTransferencia, cTransferencia, cCarga, cProceso, cEdoSeguridad
				FROM "informix".tf_archivos_transfer
				WHERE fecha_archivo = dtFechaSistema
		
				RETURN  TRIM(NVL(cCodRet,"")), TRIM(NVL(cMensajeRet,"")), TRIM(NVL(cNombreArchivo,"")), TRIM(NVL(cArchivoOrigen,"")), NVL(dtFechaArchivo,""), NVL(iNumeroRegistros,0), NVL(dtFechaIntegracion,""), NVL(dtFechaTransferencia,""),TRIM(NVL(cTransferencia,"")), TRIM(NVL(cCarga,"")), TRIM(NVL(cProceso,"")), TRIM(NVL(cEdoSeguridad,"")) WITH RESUME;
					
				
			END FOREACH;	
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
					
					LET cCodRet= "00005";
					LET cMensajeRet="NO EXISTEN DATOS";
					
					RETURN  TRIM(NVL(cCodRet,"")), TRIM(NVL(cMensajeRet,"")), TRIM(NVL(cNombreArchivo,"")), TRIM(NVL(cArchivoOrigen,"")), NVL(dtFechaArchivo,""), NVL(iNumeroRegistros,0), NVL(dtFechaIntegracion,""), NVL(dtFechaTransferencia,""),TRIM(NVL(cTransferencia,"")), TRIM(NVL(cCarga,"")), TRIM(NVL(cProceso,"")), TRIM(NVL(cEdoSeguridad,""));
				END IF;
		END IF;
				

	ELSE --iIdOpcion=2
		
		IF NVL(pFechaInicial,"") = ""  OR NVL(pFechaFin,"") = "" THEN

			LET cCodRet = "00002";
			LET cMensajeRet = "ERROR EN PARAMETROS";

			RETURN  TRIM(NVL(cCodRet,"")), TRIM(NVL(cMensajeRet,"")), TRIM(NVL(cNombreArchivo,"")), TRIM(NVL(cArchivoOrigen,"")), NVL(dtFechaArchivo,""), NVL(iNumeroRegistros,0), NVL(dtFechaIntegracion,""), NVL(dtFechaTransferencia,""),TRIM(NVL(cTransferencia,"")), TRIM(NVL(cCarga,"")), TRIM(NVL(cProceso,"")), TRIM(NVL(cEdoSeguridad,""));
		END IF	
			--SE VALIDA SI LA FECHA VIENE CON VALOR
		IF NVL(pFechaInicial,"") <> ""  OR NVL(pFechaFin,"") <> "" THEN				
			--SE VALIDA QUE LA FECHA INICIAL Y LA FECHA FINAL NO SEA MAYOR A LA FECHA INICIAL
			IF NVL(pFechaFin, "") < NVL(pFechaInicial,"")  THEN
				LET cCodRet = "00003";
				LET cMensajeRet = "ERROR EN PARAMETROS";
				
				RETURN  TRIM(NVL(cCodRet,"")), TRIM(NVL(cMensajeRet,"")), TRIM(NVL(cNombreArchivo,"")), TRIM(NVL(cArchivoOrigen,"")), NVL(dtFechaArchivo,""), NVL(iNumeroRegistros,0), NVL(dtFechaIntegracion,""), NVL(dtFechaTransferencia,""),TRIM(NVL(cTransferencia,"")), TRIM(NVL(cCarga,"")), TRIM(NVL(cProceso,"")), TRIM(NVL(cEdoSeguridad,""));
			END IF	
			--SE VALIDA QUE LA FECHA INICIAL Y LA FECHA FINAL NO SEA MAYOR A LA FECHA DEL SISTEMA
			IF NVL(pFechaInicial,"") > NVL(dtFechaSistema,"") OR NVL(pFechaFin,"") > NVL(dtFechaSistema,"") 	THEN
				LET cCodRet = "00004";
				LET cMensajeRet = "ERROR EN PARAMETROS";
				
				RETURN  TRIM(NVL(cCodRet,"")), TRIM(NVL(cMensajeRet,"")), TRIM(NVL(cNombreArchivo,"")), TRIM(NVL(cArchivoOrigen,"")), NVL(dtFechaArchivo,""), NVL(iNumeroRegistros,0), NVL(dtFechaIntegracion,""), NVL(dtFechaTransferencia,""),TRIM(NVL(cTransferencia,"")), TRIM(NVL(cCarga,"")), TRIM(NVL(cProceso,"")), TRIM(NVL(cEdoSeguridad,""));
			END IF
		
			-- SE VALIDA SI EL ARCHIVO VIENE CON VALOR
			IF TRIM(NVL(pArchivoOrigen, "")) = "" THEN
			
				FOREACH
	
					SELECT nombrearchivo, archivo_origen, fecha_archivo, num_registros, fecha_hora_ini_integracion_reg,   fecha_hora_transferencia, transferencia, carga, proceso, b_seguridad
					INTO  cNombreArchivo, cArchivoOrigen, dtFechaArchivo, iNumeroRegistros, dtFechaIntegracion,dtFechaTransferencia, cTransferencia, cCarga, cProceso, cEdoSeguridad
					FROM "informix".tf_archivos_transfer
					WHERE fecha_archivo <= pFechaFin
					AND  fecha_archivo  >= pFechaInicial
					
					RETURN  TRIM(NVL(cCodRet,"")),TRIM(NVL(cMensajeRet,"")), TRIM(NVL(cNombreArchivo,"")), TRIM(NVL(cArchivoOrigen,"")), NVL(dtFechaArchivo,""), NVL(iNumeroRegistros,0), NVL(dtFechaIntegracion,""), NVL(dtFechaTransferencia,""),TRIM(NVL(cTransferencia,"")), TRIM(NVL(cCarga,"")), TRIM(NVL(cProceso,"")), TRIM(NVL(cEdoSeguridad,"")) WITH RESUME;
					
				END FOREACH
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
					
					LET cCodRet= "00005";
					LET cMensajeRet="NO EXISTEN DATOS";
					
					RETURN  TRIM(NVL(cCodRet,"")), TRIM(NVL(cMensajeRet,"")), TRIM(NVL(cNombreArchivo,"")), TRIM(NVL(cArchivoOrigen,"")), NVL(dtFechaArchivo,""), NVL(iNumeroRegistros,0), NVL(dtFechaIntegracion,""), NVL(dtFechaTransferencia,""),TRIM(NVL(cTransferencia,"")), TRIM(NVL(cCarga,"")), TRIM(NVL(cProceso,"")), TRIM(NVL(cEdoSeguridad,""));
				END IF;
		
			
			ELSE
				FOREACH
					
					SELECT nombrearchivo, archivo_origen, fecha_archivo, num_registros, fecha_hora_ini_integracion_reg,   fecha_hora_transferencia, transferencia, carga, proceso, b_seguridad
					INTO  cNombreArchivo, cArchivoOrigen, dtFechaArchivo, iNumeroRegistros, dtFechaIntegracion,dtFechaTransferencia, cTransferencia, cCarga, cProceso, cEdoSeguridad
					FROM "informix".tf_archivos_transfer
					WHERE fecha_archivo <= pFechaFin
					AND  fecha_archivo  >= pFechaInicial
					AND  archivo_origen = pArchivoOrigen
					
					RETURN  TRIM(NVL(cCodRet,"")),TRIM(NVL(cMensajeRet,"")), TRIM(NVL(cNombreArchivo,"")), TRIM(NVL(cArchivoOrigen,"")), NVL(dtFechaArchivo,""), NVL(iNumeroRegistros,0), NVL(dtFechaIntegracion,""), NVL(dtFechaTransferencia,""),TRIM(NVL(cTransferencia,"")), TRIM(NVL(cCarga,"")), TRIM(NVL(cProceso,"")), TRIM(NVL(cEdoSeguridad,"")) WITH RESUME;
					
				END FOREACH;
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
					
					LET cCodRet= "00005";
					LET cMensajeRet="NO EXISTEN DATOS";
					
					RETURN  TRIM(NVL(cCodRet,"")), TRIM(NVL(cMensajeRet,"")), TRIM(NVL(cNombreArchivo,"")), TRIM(NVL(cArchivoOrigen,"")), NVL(dtFechaArchivo,""), NVL(iNumeroRegistros,0), NVL(dtFechaIntegracion,""), NVL(dtFechaTransferencia,""),TRIM(NVL(cTransferencia,"")), TRIM(NVL(cCarga,"")), TRIM(NVL(cProceso,"")), TRIM(NVL(cEdoSeguridad,""));
				END IF;
			
			END IF; 	
				
			
		
		ELSE --FECHA INICIAL Y FINAL VACIA 
			--SE VALIDA SI EL ARCHIVO ORIGEN VIENE CON VALOR
			IF TRIM(NVL(pArchivoOrigen, "")) = "" THEN
				FOREACH
				
					SELECT nombrearchivo, archivo_origen, fecha_archivo, num_registros, fecha_hora_ini_integracion_reg,   fecha_hora_transferencia, transferencia, carga, proceso, b_seguridad
					INTO  cNombreArchivo, cArchivoOrigen, dtFechaArchivo, iNumeroRegistros, dtFechaIntegracion,dtFechaTransferencia, cTransferencia, cCarga, cProceso, cEdoSeguridad
					FROM "informix".tf_archivos_transfer
						
					RETURN  TRIM(NVL(cCodRet,"")),TRIM(NVL(cMensajeRet,"")), TRIM(NVL(cNombreArchivo,"")), TRIM(NVL(cArchivoOrigen,"")), NVL(dtFechaArchivo,""), NVL(iNumeroRegistros,0), NVL(dtFechaIntegracion,""), NVL(dtFechaTransferencia,""),TRIM(NVL(cTransferencia,"")), TRIM(NVL(cCarga,"")), TRIM(NVL(cProceso,"")), TRIM(NVL(cEdoSeguridad,"")) WITH RESUME;
					
				END FOREACH; 	
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
					
					LET cCodRet= "00005";
					LET cMensajeRet="NO EXISTEN DATOS";
					
					RETURN  TRIM(NVL(cCodRet,"")), TRIM(NVL(cMensajeRet,"")), TRIM(NVL(cNombreArchivo,"")), TRIM(NVL(cArchivoOrigen,"")), NVL(dtFechaArchivo,""), NVL(iNumeroRegistros,0), NVL(dtFechaIntegracion,""), NVL(dtFechaTransferencia,""),TRIM(NVL(cTransferencia,"")), TRIM(NVL(cCarga,"")), TRIM(NVL(cProceso,"")), TRIM(NVL(cEdoSeguridad,""));
				END IF;
				
			ELSE	
				FOREACH
					SELECT nombrearchivo, archivo_origen, fecha_archivo, num_registros, fecha_hora_ini_integracion_reg,   fecha_hora_transferencia, transferencia, carga, proceso, b_seguridad
					INTO  cNombreArchivo, cArchivoOrigen, dtFechaArchivo, iNumeroRegistros, dtFechaIntegracion,dtFechaTransferencia, cTransferencia, cCarga, cProceso, cEdoSeguridad
					FROM "informix".tf_archivos_transfer
					WHERE  archivo_origen = pArchivoOrigen
						
					RETURN  TRIM(NVL(cCodRet,"")),TRIM(NVL(cMensajeRet,"")), TRIM(NVL(cNombreArchivo,"")), TRIM(NVL(cArchivoOrigen,"")), NVL(dtFechaArchivo,""), NVL(iNumeroRegistros,0), NVL(dtFechaIntegracion,""), NVL(dtFechaTransferencia,""),TRIM(NVL(cTransferencia,"")), TRIM(NVL(cCarga,"")), TRIM(NVL(cProceso,"")), TRIM(NVL(cEdoSeguridad,"")) WITH RESUME;
				
				END FOREACH;
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
					
					LET cCodRet= "00005"; 
					LET cMensajeRet="NO EXISTEN DATOS";
					
					RETURN  TRIM(NVL(cCodRet,"")), TRIM(NVL(cMensajeRet,"")), TRIM(NVL(cNombreArchivo,"")), TRIM(NVL(cArchivoOrigen,"")), NVL(dtFechaArchivo,""), NVL(iNumeroRegistros,0), NVL(dtFechaIntegracion,""), NVL(dtFechaTransferencia,""),TRIM(NVL(cTransferencia,"")), TRIM(NVL(cCarga,"")), TRIM(NVL(cProceso,"")), TRIM(NVL(cEdoSeguridad,""));
				END IF;				
			END IF;
				
	
		END IF;
			
	END IF;	
	
END;
		
END PROCEDURE
DOCUMENT
'AUTOR: 96152877 - Jose Raul Pacheco Ortiz  ',
'FOLIO: 1434',
'DESCRIPCION: Realiza la consulta de archivos transfer ya sea por rango de fecha o por dia actual .',
'FECHA: 12/08/2014',
'SUSTENTO: Se definio con Ricardo Resendis en el requerimiento RQI 13276 TRANSFER Proceso Font End Firmado.pdf', 
'BD: BDITRANSFER';

create procedure "informix".sp_transfer_conadmin_sva 
(
psnomarchivo_out char (50),pdfecha_recibido date, pstipo_cuenta char(1), pscuenta char(18), pscomentario char(256),
pmonto_out char (18), psintegridad char(1), psaplicado char(6),psmsn_motivo char(150),
vsstatus_cnc char (1),piconsecutivo integer, pscve_usuario char(10)
)
returning char (1);

--Variables de control de errores 
define visqlerr integer ;
define vscodret2 char(5);
define vsmensaje_respuesta varchar(250);

--Variables de trabajo
define vsnomarchivo_in char (50);
define vdfecha_proceso date ;
define vstipo_cuenta char (1);
define vpmonto_in char (18) ;
define vsfecha_in date;
define viconsecutivo integer;
define vinumresul integer;

define vsdescripcion_cnc char(200);
define vsdescripcion_cnc2 char(200);

define pssecuenciaextendida char(16);

define vsflagencontrado char (1);

begin
	on exception set visqlerr
		let vsmensaje_respuesta = vsmensaje_respuesta||' Error sp_transfer_conadmin_sva '||visqlerr;
		execute procedure bditransfer:"informix".sp_transfer_guardabitacora ( '3', vsmensaje_respuesta, pscve_usuario) ;
		let vsstatus_cnc='E';
		return 	vsstatus_cnc;
	end exception;
	
--set debug file to "/informix/HomeInformix/sp_transfer_conadmin_sva.out";
--trace on;

let visqlerr  = 0;

let vsnomarchivo_in= '';
let vdfecha_proceso = today ;
let vstipo_cuenta = '';
let vpmonto_in = '' ;
let viconsecutivo = 0;
let vinumresul = 0;

let vsfecha_in = '01-01-1900';
let pssecuenciaextendida='';

let vsdescripcion_cnc = '';
let vsdescripcion_cnc2 = '';
let vsflagencontrado = 'V';

let vsmensaje_respuesta = 'Consulta si_fechas';
--OBTIENE LA FECHA HOY DEL SISTEMA CENTRAL INTEGRAL
set isolation to dirty read;
	select limit 1 fecha_hoy into vdfecha_proceso from bdinteg:"informix".si_fechas;
--Clasificación de bandera de aplicado por parte de Transfer.

If (psaplicado = '000000' or trim(psaplicado) = '0' or trim(psaplicado) = '' or psaplicado is null ) THEN
		
	Let psaplicado = 'V';
else 
	
	Let psaplicado = 'F';
	Let vsdescripcion_cnc2 = 'El registro no se aplico por :'||trim(psmsn_motivo);
end if;

--Clasificación general de conciliacion administrativa

if   (pscuenta = '' or pscuenta is null or pstipo_cuenta = '' or pstipo_cuenta is null) then

	Let vsdescripcion_cnc = 'No se recibieron los datos completos del registro OutSVA.';
	let vsflagencontrado = 'F';
	
elif (psintegridad != 'V') then 
	Let vsdescripcion_cnc = 'Se encontro un error de integridad en registro OutSVA.';
	let vsflagencontrado = 'F';
	
-- inicia el proceso de busqueda de la pareja InSVA
else 
	
	let vsmensaje_respuesta = 'Consulta tf_sva_incoming';
	
	set isolation to dirty read;
	select count(cuenta) into vinumresul from bditransfer:tf_sva_incoming
	where tpo_id = pstipo_cuenta and cuenta = pscuenta and status_envio = 'V' and status_cnc='P';
	
	if (vinumresul = 0 ) then 
	
		Let vsdescripcion_cnc = 'No se encontro registro InSVA relacionado.';
		let vsflagencontrado = 'F';
	
	elif (vinumresul = 1) then
		set isolation to dirty read;
		select nombre_archivo_envio, tpo_id, fecha_proceso, trim(nvo_monto),consecutivo
		into vsnomarchivo_in, vstipo_cuenta,vsfecha_in,vpmonto_in,viconsecutivo
		from bditransfer:tf_sva_incoming
		where tpo_id = pstipo_cuenta and cuenta = pscuenta and status_envio = 'V' and status_cnc='P';
		
		if (trim(vpmonto_in) != trim(pmonto_out)) then 
			
			Let vsdescripcion_cnc = 'Los registros tienen diferencia en monto, pareja de consecutivos IN:'||viconsecutivo||' OUT:'||piconsecutivo||' .' ;
		else 
		
			Let vsdescripcion_cnc = 'Conciliado correctamente, pareja de consecutivos IN:'||viconsecutivo||' OUT:'||piconsecutivo||' .' ;
		end if;
						
	else
		-- Busqueda con mas filtros en caso de tener varios posibles. 
		set isolation to dirty read;
		select limit 1 nombre_archivo_envio, tpo_id, fecha_proceso, trim(nvo_monto),consecutivo
		into vsnomarchivo_in, vstipo_cuenta,vsfecha_in,vpmonto_in,viconsecutivo
		from bditransfer:tf_sva_incoming
		where tpo_id = pstipo_cuenta and cuenta = pscuenta and status_envio = 'V' and status_cnc='P'
		and  trim(nvo_monto) = trim(pmonto_out);
		
		if (vsnomarchivo_in = '' or vsnomarchivo_in is null ) then
			--Busqueda sin filtro de monto.
			set isolation to dirty read;
			select limit 1 nombre_archivo_envio, tpo_id, fecha_proceso, trim(nvo_monto),consecutivo
			into vsnomarchivo_in, vstipo_cuenta,vsfecha_in,vpmonto_in,viconsecutivo
			from bditransfer:tf_sva_incoming
			where tpo_id = pstipo_cuenta and cuenta = pscuenta and status_envio = 'V' and status_cnc='P'
			and comentario = pscomentario;
			
			if (vsnomarchivo_in = '' or vsnomarchivo_in is null ) then
			
				Let vsdescripcion_cnc = 'No se encontro registro InSVA relacionado. ';
				let vsflagencontrado = 'F';
			else 
				Let vsdescripcion_cnc = 'Los registros tienen diferencia en monto, pareja de consecutivos IN:'||viconsecutivo||' OUT:'||piconsecutivo||' .' ;
			end if;
		
		else 
		
		Let vsdescripcion_cnc = 'Conciliado correctamente, pareja de consecutivos IN:'||viconsecutivo||' OUT:'||piconsecutivo||' .' ;
		
		end if; 
			
		
	end if;
	
	
end if;
let vsmensaje_respuesta = 'Insert tf_conadmin_sva';
--GUARDA EL REGISTRO EN LA TABLA DE CONCILIACION ADMINISTRATIVA INTERREDES
	INSERT INTO bditransfer:"informix".tf_conadmin_sva
	(
		--consecutivo,
		fecha_proceso,
		tipo_cuenta,
		cuenta,
		comentario,
		--secuenciaextendidadescripcion_concilia,
		descripcion_concilia,
		nombrearchivo_insva,
		fecha_mov_insva,
		monto_insva,
		nombrearchivo_outsva,
		fecha_mov_outsva,
		monto_outsva,
		integridad,
		aplicado_transfer,
		encontrado
		
	)
	VALUES
	(
		vdfecha_proceso,
		NVL(pstipo_cuenta,''),
		TRIM(NVL(pscuenta,'')),
		TRIM(NVL(pscomentario,'')),
		trim(vsdescripcion_cnc)||trim(vsdescripcion_cnc2),
		TRIM(NVL(vsnomarchivo_in,'')),
		vsfecha_in,
		TRIM(NVL(vpmonto_in,'')),
		TRIM(NVL(psnomarchivo_out,'')),
		pdfecha_recibido,
		TRIM(NVL(pmonto_out,'')),
		psintegridad,
		psaplicado,
		vsflagencontrado
	);
	
If (vsflagencontrado = 'V') then
	
	Update bditransfer:tf_sva_incoming set status_cnc = 'V' ,nombre_archivo_cnc = trim(psnomarchivo_out)
	where consecutivo=viconsecutivo ;
	
	let vsstatus_cnc='V';
	
End if;
	
let vsmensaje_respuesta = 'Proceso exitoso';

return 	vsstatus_cnc;

end
end procedure
DOCUMENT
'AUTOR: Juan Fco. Ponce Damian',
'Proyecto: Proyecto Transfer',
'Solicito: Luis Antonio Gomez',
'Descripcion: Proceso conciliación administrativa transfer InSVA Vs OutSVA',
'Fecha: 2014/09/24',
'BD: BdiTransfer';

CREATE PROCEDURE "informix".sp_actualizanumctetitular(pEmpresa CHAR(3), pRFC CHAR(13), pNumCte CHAR(20))
--DATOS A REGRESAR--
RETURNING 	CHAR(6) AS CodigoRetorno,
			CHAR(1) AS BanCteTransfer;

--DEFINICION DE VARIABLES--
DEFINE cCodRet CHAR(6);
DEFINE iSqlErr INTEGER;
DEFINE iIsamErr INTEGER;
DEFINE cNumCtetf CHAR(20);
DEFINE cBanCtetf CHAR(1);

--INICIALIZACION DE VARIABLES--
LET cCodRet = '000';
LET iSqlErr = 0;
LET iIsamErr = 0;
LET cNumCtetf = '';
LET cBanCtetf = '0';

--SET DEBUG FILE TO "/informix/IrisA/sp_actualizanumctetitular.out";
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr
		IF iSqlErr <> 0 OR iIsamErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cBanCtetf;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa, '') <> '' AND NVL(pRFC, '') <> '' AND NVL(pNumCte, '') <> '' THEN

		SELECT numcte_tf 
		INTO cNumCtetf
		FROM "informix".tf_maecte 
		WHERE empresa = pEmpresa AND rfc = pRFC;

		IF NVL(cNumCtetf, '') <> '' THEN

			LET cBanCtetf = '1';

			UPDATE "informix".tf_maecte 
			SET numcte = pNumCte
			WHERE empresa = pEmpresa AND numcte_tf = cNumCtetf;

		END IF;

	END IF;

	RETURN cCodRet, cBanCtetf;

END;
END PROCEDURE;