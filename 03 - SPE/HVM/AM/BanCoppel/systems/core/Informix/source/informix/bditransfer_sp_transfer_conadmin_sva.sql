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