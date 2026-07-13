create procedure "informix".sp_transfer_conadmin_capture 
(
piconsecutivo integer, psnomarchivo_out char (50),psnumtarjeta char(30), pssecuencia_out char(6),
pmonto_out money,psfecha_out char(6), psintegridad char(1), psaplicado char(6),psmsn_error char(130),
vsstatus_cnc char (1),pscve_usuario char(10)
)
returning char (1);

--Variables de control de errores 
define visqlerr integer;
define vscodret2 char(5);
define vsmensaje_respuesta varchar(250);

--Variables de trabajo
define vsnomarchivo_in char (50);
define vdfecha_proceso date ;
define vssecuencia_in char (6);
define vpmonto_in money ;
define vsfecha_in char (6);
define viconsecutivo integer;
define vicount integer;

define vsdescripcion_cnc char(200);
define vsdescripcion_cnc2 char(200);
define pssecuenciaextendida char(16);

define vsflagencontrado char (1);

begin
	on exception set visqlerr
		let vsmensaje_respuesta = vsmensaje_respuesta||' Error sp_transfer_conadmin '||visqlerr;
		execute procedure bditransfer:"informix".sp_transfer_guardabitacora ( '3', vsmensaje_respuesta, pscve_usuario) into vscodret2;
		let vsstatus_cnc='E';
		return 	vsstatus_cnc;
	end exception;
	
--set debug file to "/informix/HomeInformix/sp_transfer_conadmin.out";
--trace on;

let visqlerr  = 0;

let vsnomarchivo_in= '';
let vdfecha_proceso = today ;
let vssecuencia_in = '';
let vpmonto_in = 0.0 ;
let vsfecha_in = '';
let pssecuenciaextendida='';
let vicount = 0;

let vsdescripcion_cnc = '';
let vsdescripcion_cnc2 = '';
let vsflagencontrado = 'V';

Let psnumtarjeta = substr (psnumtarjeta, 5,16);

let vsmensaje_respuesta = 'Consulta si_fechas';
--OBTIENE LA FECHA HOY DEL SISTEMA CENTRAL INTEGRAL
set isolation to dirty read;
	select limit 1 fecha_hoy into vdfecha_proceso from bdinteg:"informix".si_fechas;
	
If (psaplicado = '000000' or trim(psaplicado) = '0' or trim(psaplicado) = '' or psaplicado is null ) THEN
		
	Let psaplicado = 'V';
else 
	
	Let psaplicado = 'F';
	Let vsdescripcion_cnc2 = ' El registro no se aplico por :'||trim(psmsn_error);
end if;

if   (psnumtarjeta = '' or psnumtarjeta is null or pssecuencia_out = '' or pssecuencia_out is null ) then

	Let vsdescripcion_cnc = 'No se recibieron los datos completos del registro OutCapture. ';
	let vsflagencontrado = 'F';
	
elif (psintegridad != 'V') then 
	Let vsdescripcion_cnc = 'Se encontro un error de integridad en registro OutCapture. ';
	let vsflagencontrado = 'F';
else 
	
	let vsmensaje_respuesta = 'Consulta tf_incapture';
	
	set isolation to dirty read;
	select count(nombre_archivo_envio) into vicount from bditransfer:tf_incapture
	where cuenta = psnumtarjeta and secuencia = pssecuencia_out and status_envio='V' and status_cnc='P';
	
	if (vicount = 0) then 
		Let vsdescripcion_cnc = 'No se encontro registro incapture relacionado.';
		let vsflagencontrado = 'F';
	
	elif (vicount = 1) then 
	
		set isolation to dirty read;
		select limit 1 nombre_archivo_envio,secuencia,(nvl(monto,0)::money/100),fecha_alta,secuenciaextendida,consecutivo
		into vsnomarchivo_in, vssecuencia_in,vpmonto_in,vsfecha_in,pssecuenciaextendida,viconsecutivo
		from bditransfer:tf_incapture
		where cuenta = psnumtarjeta and secuencia = pssecuencia_out and status_envio='V' and status_cnc='P';

		if (vpmonto_in != pmonto_out and vsfecha_in != psfecha_out) then 
			Let vsdescripcion_cnc = 'Existen diferencias en monto y fecha, pareja de consecutivos IN:'||viconsecutivo||' OUT:'||piconsecutivo||' .' ;
		elif (vpmonto_in != pmonto_out ) then
				Let vsdescripcion_cnc = 'Existen diferencias en monto, pareja de consecutivos IN:'||viconsecutivo||' OUT:'||piconsecutivo||' .' ;
		elif ( vsfecha_in != psfecha_out) then
				Let vsdescripcion_cnc = 'Existen diferencias en fecha, pareja de consecutivos IN:'||viconsecutivo||' OUT:'||piconsecutivo||' .' ;
		ELSE
			Let vsdescripcion_cnc = 'Conciliado correctamente, pareja de consecutivos IN:'||viconsecutivo||' OUT:'||piconsecutivo||' .' ;
		end if;
	else 
		set isolation to dirty read;
		select limit 1 nombre_archivo_envio,secuencia,(nvl(monto,0)::money/100),fecha_alta,secuenciaextendida,consecutivo
		into vsnomarchivo_in, vssecuencia_in,vpmonto_in,vsfecha_in,pssecuenciaextendida,viconsecutivo
		from bditransfer:tf_incapture
		where cuenta = psnumtarjeta and secuencia = pssecuencia_out and status_envio='V' and status_cnc='P' and (nvl(monto,0)::money/100)=pmonto_out;
		
		if (vsnomarchivo_in='' or vsnomarchivo_in is null) then 
			set isolation to dirty read;
			select limit 1 nombre_archivo_envio,secuencia,(nvl(monto,0)::money/100),fecha_alta,secuenciaextendida,consecutivo
			into vsnomarchivo_in, vssecuencia_in,vpmonto_in,vsfecha_in,pssecuenciaextendida,viconsecutivo
			from bditransfer:tf_incapture
			where cuenta = psnumtarjeta and secuencia = pssecuencia_out and status_envio='V' and status_cnc='P';
			
			Let vsdescripcion_cnc = 'Conciliado con diferencias a validar, pareja de consecutivos IN:'||viconsecutivo||' OUT:'||piconsecutivo||' .' ;		
			
		elif ( vsfecha_in != psfecha_out) then
				Let vsdescripcion_cnc = 'Existen diferencias en fecha, pareja de consecutivos IN:'||viconsecutivo||' OUT:'||piconsecutivo||' .' ;
		else 
			Let vsdescripcion_cnc = 'Conciliado correctamente, pareja de consecutivos IN:'||viconsecutivo||' OUT:'||piconsecutivo||' .' ;
		end if;
		
	
	end if;
	
End if; 
let vsmensaje_respuesta = 'Insert tf_conadmin';
--GUARDA EL REGISTRO EN LA TABLA DE CONCILIACION ADMINISTRATIVA INTERREDES
	INSERT INTO bditransfer:"informix".tf_conadmin_capture
	(
		--consecutivo
		fecha_proceso,
		numtarjeta,
		secuencia,
		secuenciaextendida,
		descripcion_concilia,
		nombrearchivo_incapture,
		fecha_mov_incapture,
		monto_incapture,
		nombrearchivo_outcapture,
		fecha_mov_outcapture,
		monto_outcapture,
		integridad,
		aplicado_transfer,
		encontrado
	)
	VALUES
	(
		vdfecha_proceso,
		TRIM(NVL(psnumtarjeta,'')),
		TRIM(NVL(pssecuencia_out,'')),
		TRIM(NVL(pssecuenciaextendida,'')),
		trim(vsdescripcion_cnc)||trim(vsdescripcion_cnc2),
		TRIM(NVL(vsnomarchivo_in,'')),
		TRIM(NVL(vsfecha_in,'')),
		NVL(vpmonto_in,''),
		TRIM(NVL(psnomarchivo_out,'')),
		TRIM(NVL(psfecha_out,'')),
		NVL(pmonto_out,''),
		psintegridad,
		psaplicado,
		vsflagencontrado
	);
	
If (vsflagencontrado = 'V') then
	
	Update bditransfer:tf_incapture set status_cnc = 'V' ,nombre_archivo_cnc = trim(psnomarchivo_out)
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
'Descripcion: Proceso conciliación administrativa transfer InCapture Vs OutCapture',
'Fecha: 2014/09/18',
'BD: BdiTransfer';

CREATE PROCEDURE "informix".sp_transfer_esnumerico ( psCadena CHAR (30))

RETURNING CHAR (1) AS Numerico ;

--****************************************************************************************************
-- DESCRIPCION:  SP CLONADO QUE VERIFICA QUE LA CADENA DE ENTRADA SOLAMENTE CONTENGA NUMEROS
-- AUTOR : Casanova Edeza Hector Juan // Clonador Ricardo Reséndiz Martinez
-- FECHA : 04/04/2014
-- BD: bditarjeta
-- SISTEMA : Reingenieria de la Conciliacion Automática
-- MODIFICADO : SIN MODIFICACIONES
--***************************************************************************************************

/*  definicion de variables */
define vsrespuesta char (1) ;
define visqlerr integer ;
/* inicializacion de variables */


begin

	on exception set visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado

		if visqlerr = -1213 then
			let vsrespuesta = 'F' ;
		else
			let vsrespuesta = ' ' ;
		end if;

		return vsrespuesta ;

	end exception;

let vsrespuesta = 'F' ;
let visqlerr = 0;


	if (pscadena >= 0) then
		let vsrespuesta = 'V';
	else
		let vsrespuesta = 'F';
	end if;

	return vsrespuesta ;

end

end procedure
document
'autor: casanova edeza hector juan // clonador ricardo resendiz martinez',
'proyecto: proceso de validacion  de transfer',
'solicito: jose luis puebla',
'descripcion: verifica que la cadena de entrada solamente contenga numeros.',
'fecha: 2014/07/04',
'version: 20140704.1630',
'bd: bditransfer';

create procedure "informix".sp_transfer_guardabitacora(
	pselemento integer,
	psactividad char(150),
	pscve_usuario char(10)
)

	returning char(5) as retorno;

	/*definicion de variables*/

	/*variables de retorno*/
	define visqlerr integer ;
	define vssqlerr char(5);

	/*inicializacion de variables*/

	let visqlerr = 0;
	let vssqlerr = '00000';

	begin

		on exception set visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado

				let vssqlerr = visqlerr;
				return vssqlerr;

		end exception;

--	set debug file to "/informix/HomeInformix/rrm/sp_transfer_bitacora.out";
--	trace on;

	set lock mode to wait 3;

	insert into bditransfer:"informix".tf_bitacora_transfer (elemento, fecha_hora, actividad, cve_usuario)
		values (	pselemento,
					(select dbinfo('utc_to_datetime', sh_curtime)::datetime year to fraction(5) from sysmaster:"informix".sysshmvals),
					psactividad,
					pscve_usuario
				);

		let vssqlerr = '00000';

	return vssqlerr;


end

end procedure
DOCUMENT
'autor: Ricardo Reséndiz Martinez',
'proyecto: Integracion de Transfer ',
'solicito: jose luis puebla',
'descripcion: guarda bitacora.',
'fecha: 2014/07/23',
'version: 20110723.1720',
'bd: bditransfer';

CREATE PROCEDURE "informix".sp_consulta_detalle_compensacion(pConsulta INTEGER,pTipoConsulta CHAR(2),pFechaConsulta DATE)

--RETORNOS
RETURNING
CHAR(5) 	AS	CodigoRetorno,
CHAR(100)	AS	MensajeRetorno,
CHAR(16)	AS 	Num_Cuenta,
CHAR(6) 	AS	Secuencia,
CHAR(6) 	AS	Fecha_Alta,
MONEY(14,2)	AS	Monto_total_operaciones,
CHAR(9) 	AS 	Id_Negocio,
CHAR(1)		AS	Estatus;

--dEFINICION DE VARIABLES

DEFINE	cCodigoRetorno       CHAR(5);
DEFINE 	cMensajeRetorno		 CHAR(100);
DEFINE	cCuenta		  		 CHAR(16);
DEFINE	cSecuencia		 	 CHAR(6);
DEFINE	cFechaAlta	 		 CHAR(6);
DEFINE	mMontoTotalOperacion MONEY(14,2);
DEFINE	cIdNegocio			 CHAR(9);
DEFINE	cStatus			 	 CHAR(1);
DEFINE  cCdtoDeb		     CHAR(1);
DEFINE  cFecha				 CHAR(6);
DEFINE  iSqlErr				 INTEGER;


--INICIALIZACION DE VARIABLES
LET	cCodigoRetorno 		 = "00000";	
LET cMensajeRetorno 	 = "EXITO";	
LET	cCuenta	  			 = "";
LET cSecuencia		     = "";
LET cFechaAlta	         = "";	
LET mMontoTotalOperacion = 0.00;
LET cIdNegocio			 = "";
LET cStatus			     = "";
LET cCdtoDeb			 = "";
LET cFecha				 = "";
LET iSqlErr				 = 0;	
		
	 
--SET DEBUG FILE TO "/respaldosbd/raulpacheco/sp_consulta_detalle_compensacion.out"; 
--TRACE ON;


BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodigoRetorno = iSqlErr;
			LET cMensajeRetorno ="ERROR NO CONTROLADO";
			RETURN TRIM(NVL(cCodigoRetorno,"")),TRIM(NVL(cMensajeRetorno,"")),TRIM(NVL(cCuenta,"")), TRIM(NVL(cSecuencia,"")), TRIM(NVL(cFechaAlta,"")), NVL(mMontoTotalOperacion,0.00), TRIM(NVL(cIdNegocio,"")), TRIM(NVL(cStatus,"")); 
		END IF;
	END EXCEPTION;
 
 	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO dirty READ;
	
	IF NVL(pConsulta,0) NOT IN (1,2) THEN
		LET  cCodigoRetorno= "00001";
		LET  cMensajeRetorno="PARAMETRO pConsulta NO VALIDO";
		RETURN TRIM(NVL(cCodigoRetorno,"")),TRIM(NVL(cMensajeRetorno,"")),TRIM(NVL(cCuenta,"")), TRIM(NVL(cSecuencia,"")), TRIM(NVL(cFechaAlta,"")), NVL(mMontoTotalOperacion,0.00), TRIM(NVL(cIdNegocio,"")), TRIM(NVL(cStatus,""));
	END IF
	IF TRIM(NVL(pTipoConsulta,"")) NOT IN("GE","DI","SC","SD") THEN
		LET  cCodigoRetorno= "00002";
		LET  cMensajeRetorno="PARAMETRO pTipoConsulta NO VALIDO";
		RETURN TRIM(NVL(cCodigoRetorno,"")),TRIM(NVL(cMensajeRetorno,"")),TRIM(NVL(cCuenta,"")), TRIM(NVL(cSecuencia,"")), TRIM(NVL(cFechaAlta,"")), NVL(mMontoTotalOperacion,0.00), TRIM(NVL(cIdNegocio,"")), TRIM(NVL(cStatus,"")) ;
	END IF;	
	IF TRIM(NVL(pFechaConsulta,"")) = "" THEN
		LET  cCodigoRetorno= "00003";
		LET  cMensajeRetorno= "PARAMETRO pFechaConsulta NO VALIDO";
		RETURN TRIM(NVL(cCodigoRetorno,"")),TRIM(NVL(cMensajeRetorno,"")),TRIM(NVL(cCuenta,"")), TRIM(NVL(cSecuencia,"")), TRIM(NVL(cFechaAlta,"")), NVL(mMontoTotalOperacion,0.00), TRIM(NVL(cIdNegocio,"")), TRIM(NVL(cStatus,""));
	END IF;	
	--SE CAMBIA EL FORMATO DE LA FECHA PARA PODERCE COMPARAR CON UN VALOR DE LA TABLA
	LET cFecha = SUBSTR(YEAR(pFechaConsulta),3,2) || LPAD(MONTH(pFechaConsulta),2,"0") || LPAD(DAY(pFechaConsulta),2,"0");
	--SE OPTIENE DETALLES DE OPERACIONES GENERALES
	IF pTipoConsulta = "GE" THEN
		FOREACH			
			SELECT cuenta, secuencia, fecha_alta, ((monto::MONEY)/100), id_negocio, status_envio
			INTO cCuenta, cSecuencia, cFechaAlta, mMontoTotalOperacion, cIdNegocio, cStatus
			FROM 'informix'.tf_incapture
			WHERE SUBSTR(cuenta,1,6) IN (SELECT bin	FROM intercard:'informix'.bines WHERE 
			creditodebito = DECODE (pConsulta,1,"D",2,"C",""))
			AND fecha_alta = cFecha			
			RETURN TRIM(NVL(cCodigoRetorno,"")),TRIM(NVL(cMensajeRetorno,"")),TRIM(NVL(cCuenta,"")), TRIM(NVL(cSecuencia,"")), TRIM(NVL(cFechaAlta,"")), NVL(mMontoTotalOperacion,0.00), TRIM(NVL(cIdNegocio,"")), TRIM(NVL(cStatus,"")) WITH RESUME;
		END FOREACH;	
	END IF;
	--SE OBTIENE DETALLE DE DISPOSICIONES
	IF pConsulta = 1 THEN
		IF pTipoConsulta = "DI" THEN
			FOREACH				
				SELECT cuenta, secuencia, fecha_alta, ((monto::MONEY)/100), id_negocio, status_envio
				INTO cCuenta, cSecuencia, cFechaAlta, mMontoTotalOperacion, cIdNegocio, cStatus
				FROM 'informix'.tf_incapture
				WHERE SUBSTR(cuenta,1,6) IN (SELECT bin FROM intercard:'informix'.bines
				WHERE creditodebito = 'D') 
				AND archivo_origen IN(SELECT valor FROM 'informix'.tf_param_transfer
				WHERE codigo BETWEEN '100' AND '109')
				AND fecha_alta = cFecha
				
				RETURN TRIM(NVL(cCodigoRetorno,"")),TRIM(NVL(cMensajeRetorno,"")),TRIM(NVL(cCuenta,"")), TRIM(NVL(cSecuencia,"")), TRIM(NVL(cFechaAlta,"")), NVL(mMontoTotalOperacion,0.00), TRIM(NVL(cIdNegocio,"")), TRIM(NVL(cStatus,"")) WITH RESUME;		
			END FOREACH;	
		END IF;
	--SE OBTIENE DETALLE DE COMPRAS TIPO DEBITO
		IF pTipoConsulta = "SC" THEN
			FOREACH				
				SELECT cuenta, secuencia, fecha_alta, ((monto::MONEY)/100), id_negocio, status_envio
				INTO cCuenta, cSecuencia, cFechaAlta, mMontoTotalOperacion, cIdNegocio, cStatus
				FROM 'informix'.tf_incapture
				WHERE SUBSTR(cuenta,1,6) IN (SELECT bin FROM intercard:'informix'.bines
				WHERE creditodebito = 'D')
				AND archivo_origen IN (SELECT valor FROM 'informix'.tf_param_transfer
				WHERE codigo BETWEEN '110' AND '149')
				AND tipotransaccion <> '21'
				AND fecha_alta = cFecha
				
				RETURN TRIM(NVL(cCodigoRetorno,"")),TRIM(NVL(cMensajeRetorno,"")),TRIM(NVL(cCuenta,"")), TRIM(NVL(cSecuencia,"")), TRIM(NVL(cFechaAlta,"")), NVL(mMontoTotalOperacion,0.00), TRIM(NVL(cIdNegocio,"")), TRIM(NVL(cStatus,"")) WITH RESUME;		
			END FOREACH;
		END IF;
	--SE OBTIENE DETALLE DEVOLUCIONES DEBITO
		IF pTipoConsulta = "SD" THEN
			FOREACH
				SELECT cuenta, secuencia, fecha_alta, ((monto::MONEY)/100), id_negocio, status_envio
				INTO cCuenta, cSecuencia, cFechaAlta, mMontoTotalOperacion, cIdNegocio, cStatus
				FROM 'informix'.tf_incapture
				WHERE SUBSTR(cuenta,1,6) IN (SELECT bin FROM intercard:'informix'.bines
				WHERE creditodebito = 'D')
				AND tipotransaccion = '21'
				AND fecha_alta = cFecha
				RETURN TRIM(NVL(cCodigoRetorno,"")),TRIM(NVL(cMensajeRetorno,"")),TRIM(NVL(cCuenta,"")), TRIM(NVL(cSecuencia,"")), TRIM(NVL(cFechaAlta,"")), NVL(mMontoTotalOperacion,0.00), TRIM(NVL(cIdNegocio,"")), TRIM(NVL(cStatus,"")) WITH RESUME;		
			END FOREACH;
		END IF;
	ELIF pConsulta = 2 THEN 	
	--SE OBTIENE DETALLE DE DISPOSICIONES
		IF pTipoConsulta = "DI" THEN
			FOREACH				
				SELECT cuenta, secuencia, fecha_alta, ((monto::MONEY)/100), id_negocio, status_envio
				INTO cCuenta, cSecuencia, cFechaAlta, mMontoTotalOperacion, cIdNegocio, cStatus
				FROM 'informix'.tf_incapture 
				WHERE substr(cuenta,1,6) IN (SELECT bin FROM Intercard:"informix".bines WHERE creditodebito = 'C') 
				AND archivo_origen IN (SELECT valor FROM "informix".tf_param_transfer
				WHERE codigo BETWEEN '150' AND '159') AND fecha_alta = cFecha				
				RETURN TRIM(NVL(cCodigoRetorno,"")),TRIM(NVL(cMensajeRetorno,"")),TRIM(NVL(cCuenta,"")), TRIM(NVL(cSecuencia,"")), TRIM(NVL(cFechaAlta,"")), NVL(mMontoTotalOperacion,0.00), TRIM(NVL(cIdNegocio,"")), TRIM(NVL(cStatus,"")) WITH RESUME;		
			END FOREACH;	
		END IF;	
	--SE OBTIENE DETALLES DE COMPRAS TIPO CREDITO 
		IF pTipoConsulta = "SC" THEN
			FOREACH				
				SELECT cuenta, secuencia, fecha_alta, ((monto::MONEY)/100), id_negocio, status_envio
				INTO cCuenta, cSecuencia, cFechaAlta, mMontoTotalOperacion, cIdNegocio, cStatus
				FROM "informix".tf_incapture 
				WHERE substr(cuenta,1,6) IN (SELECT bin FROM Intercard:"informix".bines 
					WHERE creditodebito = DECODE (pConsulta,1,"D",2,"C","")) 
				AND archivo_origen IN (SELECT valor FROM "informix".tf_param_transfer 
					WHERE codigo BETWEEN '160' AND '199') 
				AND tipotransaccion <> '21' 
				AND fecha_alta = cFecha
				
				RETURN TRIM(NVL(cCodigoRetorno,"")),TRIM(NVL(cMensajeRetorno,"")),TRIM(NVL(cCuenta,"")), TRIM(NVL(cSecuencia,"")), TRIM(NVL(cFechaAlta,"")), NVL(mMontoTotalOperacion,0.00), TRIM(NVL(cIdNegocio,"")), TRIM(NVL(cStatus,"")) WITH RESUME;
			END FOREACH;
		END IF;
		
	--SE OBTIENE DETALLE DEVOLUCIONES CREDITO
		IF pTipoConsulta = "SD" THEN
			FOREACH
				SELECT cuenta, secuencia, fecha_alta, ((monto::MONEY)/100), id_negocio, status_envio
				INTO cCuenta, cSecuencia, cFechaAlta, mMontoTotalOperacion, cIdNegocio, cStatus
				FROM "informix".tf_incapture 
				WHERE substr(cuenta,1,6) IN (SELECT bin from Intercard:"informix".bines 
					WHERE creditodebito = 'C')
				AND archivo_origen IN (SELECT valor FROM "informix".tf_param_transfer
					WHERE codigo BETWEEN '160' AND '199') 
				AND tipotransaccion = '21'
				AND fecha_alta = cFecha
				RETURN TRIM(NVL(cCodigoRetorno,"")),TRIM(NVL(cMensajeRetorno,"")),TRIM(NVL(cCuenta,"")), TRIM(NVL(cSecuencia,"")), TRIM(NVL(cFechaAlta,"")), NVL(mMontoTotalOperacion,0.00), TRIM(NVL(cIdNegocio,"")), TRIM(NVL(cStatus,"")) WITH RESUME;		
			END FOREACH;
		END IF;
	END IF;	
	
	
	IF NVL(mMontoTotalOperacion,0.00) = 0 THEN
		LET cCodigoRetorno = "00004";
		LET cMensajeRetorno = "DATOS NO ENCONTRADOS";
		RETURN TRIM(NVL(cCodigoRetorno,"")),TRIM(NVL(cMensajeRetorno,"")),TRIM(NVL(cCuenta,"")), TRIM(NVL(cSecuencia,"")), TRIM(NVL(cFechaAlta,"")), NVL(mMontoTotalOperacion,0.00), TRIM(NVL(cIdNegocio,"")), TRIM(NVL(cStatus,""));
	END IF;	
END;	
END PROCEDURE
DOCUMENT
"AUTOR: 96152877 - Jose Raul Pacheco Ortiz",
"FOLIO: 1434",
"DESCRIPCION: Se para obtener detalles de los tipos de archivos transfer.",
"FECHA: 27/08/2014",
"SUSTENTO: Se definio con Ricardo Resendiz en el requerimiento RQI 13276 TRANSFER Proceso Font End Firmado.pdf",
"BD: BDITRANSFER",
"---------------------------------------------------------------------------------------------------------------",
"AUTOR: 95407693 - Daniel Lazalde",
"FOLIO: 1492",
"DESCRIPCION: Se consulta detalle de compensación",
"FECHA: 25/09/2014",
"SUSTENTO: Se definio con José Luis Puebla en el requerimiento Proceso Font End Firmado.pdf",
"BD: BDITRANSFER",
'-----------------------------------------------------------------------------',
"MODIFICO: - María del Rosario Montes Villa",
"FOLIO: 1492",
"DESCRIPCION: Se consulta detalle de compensación.",
"FECHA: 09/10/2014",
"SUSTENTO: Se definio con Ricardo Resendiz en el requerimiento RQI 13276 TRANSFER Proceso Font End Firmado.pdf",
"BD: BDITRANSFER";

CREATE PROCEDURE "informix".sp_consulta_resumen_compensacion(pConsulta INTEGER, pFechaConsultar DATE)

--RETORNOS
RETURNING
CHAR(5)			AS	CodigoRetorno,
CHAR(100)		AS	MensajeRetorno,
CHAR(1)			AS	ConciliacionEjecut,
INTEGER 		AS	Num_Total_Operaciones,
MONEY(14,2) 	AS 	Monto_Total_Operacion,
INTEGER			AS	Num_Total_Dispociciones,
MONEY(14,2)		AS	Monto_Total_Disposiciones,
INTEGER			AS	Num_Subtotal_Compras,
MONEY(14,2) 	AS	Monto_Subtotal_Compras,
INTEGER 		AS	Num_Subtotal_Devoluciones,
MONEY(14,2)		AS	Monto_Subtotal_Devoluciones;

--DEFINICON DE VARIABLES
DEFINE cCodigoRetorno 			CHAR(5);
DEFINE cMensajeRetorno			CHAR(100);
DEFINE iNumTotalOperaciones 	INTEGER;
DEFINE mMontoTotalOperacion		MONEY(14,2);
DEFINE iNumTotalDispo			INTEGER;
DEFINE mMontoTotalDispo			MONEY(14,2);
DEFINE iNumSubTotalCOmpras		INTEGER;
DEFINE mMontoSubtotalCompras	MONEY(14,2);
DEFINE iNumSubTotalDevo 		INTEGER;
DEFINE mMontoSubTotalDevo		MONEY(14,2);
DEFINE iSqlErr 					INTEGER;
DEFINE cFecha					CHAR(6);
DEFINE cConciliacionEjecut		CHAR(1);

--INICIALIZACION DE VARIABLES
LET cCodigoRetorno 			= "00000";
LET cMensajeRetorno			= "EXITO";
LET iNumTotalOperaciones 	= 0;
LET mMontoTotalOperacion	= 0.00;
LET iNumTotalDispo			= 0;
LET mMontoTotalDispo		= 0.00;
LET iNumSubTotalCompras		= 0;
LET mMontoSubtotalCompras	= 0.00;
LET iNumSubTotalDevo 		= 0;
LET mMontoSubTotalDevo		= 0.00;
LET iSqlErr 				= 0;
LET cFecha					= ""; 
LET cConciliacionEjecut		= "";

--SET DEBUG FILE TO "/respaldosbd/carlosaguirre/sp_consulta_resumen_compensacion.out"; 
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodigoRetorno = iSqlErr;
			LET cMensajeRetorno = "ERROR NO CONTROLADO";
			RETURN TRIM(NVL(cCodigoRetorno,"")), TRIM(NVL(cMensajeRetorno,"")), NVL(cConciliacionEjecut,""), NVL(iNumTotalOperaciones,0), 
				NVL(mMontoTotalOperacion,0.00),	NVL(iNumTotalDispo,0), NVL(mMontoTotalDispo,0.00), NVL(iNumSubTotalCOmpras,0), 
				NVL(mMontoSubtotalCompras,0.00), NVL(iNumSubTotalDevo,0), NVL(mMontoSubTotalDevo,0.00);
		END IF;
	END EXCEPTION;
 
 	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	-- VALIDA QUE EL PARAMETRO pConsulta NO VENGA VACIA
	IF NVL(pConsulta,0) NOT IN (1,2) THEN
		LET cCodigoRetorno = "00001"; -- ERROR EN PARAMETRO DE TIPO DE CONSULTA
		LET cMensajeRetorno = "PARAMETRO pConsulta NULO O INVALIDO";
		RETURN TRIM(NVL(cCodigoRetorno,"")), TRIM(NVL(cMensajeRetorno,"")), NVL(cConciliacionEjecut,""), NVL(iNumTotalOperaciones,0), 
			NVL(mMontoTotalOperacion,0.00),	NVL(iNumTotalDispo,0), NVL(mMontoTotalDispo,0.00), NVL(iNumSubTotalCOmpras,0), 
			NVL(mMontoSubtotalCompras,0.00), NVL(iNumSubTotalDevo,0), NVL(mMontoSubTotalDevo,0.00);
	END IF;
	
	-- SE VALIDA QUE LA FECHA NO TENGA VALOR NULO O SEA MAYOR A LA FECHA DEL SISTEMA
	IF NVL(pFechaConsultar,DATE(1)) = DATE(1) THEN
		LET cCodigoRetorno = "00002"; -- ERROR EN PARAMETRO DE FECHA 
		LET cMensajeRetorno = "PARAMETRO pFechaConsultar NULO O INVALIDO";
		RETURN TRIM(NVL(cCodigoRetorno,"")), TRIM(NVL(cMensajeRetorno,"")), NVL(cConciliacionEjecut,""), NVL(iNumTotalOperaciones,0), 
			NVL(mMontoTotalOperacion,0.00),	NVL(iNumTotalDispo,0), NVL(mMontoTotalDispo,0.00), NVL(iNumSubTotalCOmpras,0), 
			NVL(mMontoSubtotalCompras,0.00), NVL(iNumSubTotalDevo,0), NVL(mMontoSubTotalDevo,0.00);
	END IF;
	
	SELECT valor
	INTO cConciliacionEjecut
	FROM bditarjeta:"informix".td_param_conciliacion_concreing
	WHERE codigo = "001";
	
	--SE CAMBIA DE FORMATO LA FECHA QUE SE INGRESO COMO PARAMATRO PARA PODER COMPARAR 
	LET cFecha = SUBSTR(YEAR(pFechaConsultar),3,2) || LPAD(MONTH(pFechaConsultar),2,"0") || LPAD(DAY(pFechaConsultar),2,"0");

	--Total de Transacciones Operadas (Débito y Crédito).
	SELECT COUNT(consecutivo), SUM((monto::MONEY)/100)
		INTO iNumTotalOperaciones, mMontoTotalOperacion
	FROM "informix".tf_incapture
	WHERE SUBSTR(cuenta,1,6) IN (SELECT bin FROM intercard:"informix".bines
		WHERE creditodebito = DECODE(pConsulta,1,"D",2,"C",""))
	AND fecha_alta = cFecha;
	
	IF pConsulta = 1 THEN -- DEBITO
	
		--Total de Disposiciones Operadas Débito.
		SELECT COUNT(consecutivo), SUM((monto::MONEY)/100)
			INTO iNumTotalDispo, mMontoTotalDispo
		FROM "informix".tf_incapture
		WHERE SUBSTR(cuenta,1,6) IN (SELECT bin FROM intercard:"informix".bines
			WHERE creditodebito = 'D') 
		AND archivo_origen IN (SELECT valor FROM "informix".tf_param_transfer
			WHERE codigo BETWEEN "100" AND "109")
		AND fecha_alta = cFecha;

		--Total de Compras Exitosas Débito.
		SELECT COUNT(consecutivo), SUM((monto::MONEY)/100)
			INTO iNumSubTotalCompras, mMontoSubtotalCompras
		FROM "informix".tf_incapture
		WHERE SUBSTR(cuenta,1,6) IN (SELECT bin FROM intercard:"informix".bines
			WHERE creditodebito = 'D') 
		AND archivo_origen IN (SELECT valor FROM "informix".tf_param_transfer
			WHERE codigo BETWEEN "110" AND "149")
		AND tipotransaccion <> "21"
		AND fecha_alta = cFecha;

		--Total de Devoluciones Débito.
		SELECT COUNT(consecutivo), SUM((monto::MONEY)/100)
			INTO iNumSubTotalDevo, mMontoSubTotalDevo
		FROM "informix".tf_incapture
		WHERE SUBSTR(cuenta,1,6) IN (SELECT bin FROM intercard:"informix".bines
			WHERE creditodebito = 'D') 
		AND archivo_origen IN (SELECT valor FROM "informix".tf_param_transfer
			WHERE codigo BETWEEN "110" AND "149")
		AND tipotransaccion = "21"
		AND fecha_alta = cFecha;
	
	ELIF pConsulta = 2 THEN -- CREDITO
		
		--Total de Disposiciones Operadas Crédito.
		SELECT COUNT(consecutivo), SUM((monto::MONEY)/100)
			INTO iNumTotalDispo, mMontoTotalDispo
		FROM "informix".tf_incapture
		WHERE SUBSTR(cuenta,1,6) IN (SELECT bin FROM intercard:"informix".bines
			WHERE creditodebito = 'C') 
		AND archivo_origen IN (SELECT valor FROM "informix".tf_param_transfer
			WHERE codigo BETWEEN "150" AND "159")
		AND fecha_alta = cFecha;

		--Total de Compras Exitosas Crédito.
		SELECT COUNT(consecutivo), SUM((monto::MONEY)/100)
			INTO iNumSubTotalCompras, mMontoSubtotalCompras
		FROM "informix".tf_incapture
		WHERE SUBSTR(cuenta,1,6) IN (SELECT bin FROM intercard:"informix".bines
			WHERE creditodebito = 'C') 
		AND archivo_origen IN (SELECT valor FROM "informix".tf_param_transfer
			WHERE codigo BETWEEN "160" AND "199")
		AND tipotransaccion <> "21"
		AND fecha_alta = cFecha;
		
		--Total de Devoluciones Crédito.
		SELECT COUNT(consecutivo), SUM((monto::MONEY)/100)
			INTO iNumSubTotalDevo, mMontoSubTotalDevo
		FROM "informix".tf_incapture
		WHERE SUBSTR(cuenta,1,6) IN (SELECT bin FROM intercard:"informix".bines
			WHERE creditodebito = 'C') 
		AND archivo_origen IN (SELECT valor FROM "informix".tf_param_transfer
			WHERE codigo BETWEEN "160" AND "199") 
		AND tipotransaccion = "21"
		AND fecha_alta = cFecha;
		
	END IF;
	
	--SE VALIDA QUE LAS VARIABLES DE RETORNOS TENGAN VALOR 
	IF iNumTotalOperaciones = 0 THEN
		LET cMensajeRetorno = "DATOS VACIOS";
		LET cCodigoRetorno = "00003";
	END IF;
	
	RETURN TRIM(NVL(cCodigoRetorno,"")), TRIM(NVL(cMensajeRetorno,"")), NVL(cConciliacionEjecut,""), NVL(iNumTotalOperaciones,0), 
		NVL(mMontoTotalOperacion,0.00),	NVL(iNumTotalDispo,0), NVL(mMontoTotalDispo,0.00), NVL(iNumSubTotalCOmpras,0), 
		NVL(mMontoSubtotalCompras,0.00), NVL(iNumSubTotalDevo,0), NVL(mMontoSubTotalDevo,0.00);
	
END;
END PROCEDURE
DOCUMENT
"AUTOR: 96152877 - Jose Raul Pacheco Ortiz",
"FOLIO: 1434",
"DESCRIPCION: Se sube para la consulta de archivos transfer.",
"FECHA: 27/08/2014",
"SUSTENTO: Se definio con Ricardo Resendiz en el requerimiento RQI 13276 TRANSFER Proceso Font End Firmado.pdf",
"BD: BDITRANSFER",
'-----------------------------------------------------------------------------',
"AUTOR: 95407693, Daniel Lazalde",
"FOLIO: 1492",
"DESCRIPCION: Consulta resumen compensación",
"FECHA: 24/09/2014",
"MODIFICACION: Se agrego parametro cConciliacionEjecut que identifica si se esta procesando en ese momento en conciliacion y ",
"modificación de las consultas para usar el archivo_origen parametrizable",
'-----------------------------------------------------------------------------',
"MODIFICO: - María del Rosario Montes Villa",
"FOLIO: 1434",
"DESCRIPCION: Se sube para la consulta de archivos transfer.",
"FECHA: 09/10/2014",
"SUSTENTO: Se definio con Ricardo Resendiz en el requerimiento RQI 13276 TRANSFER Proceso Font End Firmado.pdf",
"BD: BDITRANSFER";

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