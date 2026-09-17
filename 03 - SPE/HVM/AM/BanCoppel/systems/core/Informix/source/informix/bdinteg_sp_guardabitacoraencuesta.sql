CREATE PROCEDURE "informix".sp_guardabitacoraencuesta(pEmpresa CHAR(3), pNumCte CHAR(20), pTipoProd CHAR(4), pTipoRechazo CHAR(1),
	pDescripcion CHAR(40), pSucursal CHAR(4), pEjecutivo CHAR(8), pNombre CHAR(45))

--DATOS A REGRESAR--
RETURNING CHAR(5) AS CodigoRetorno;

--DEFINICION DE VARIABLES--
DEFINE cCodRet CHAR(5);
DEFINE iSqlErr INTEGER;
DEFINE cFecha  CHAR(10);

--INICIALIZACION DE VARIABLES--
LET cCodRet = '00000';
LET iSqlErr = 0;
LET cFecha = '';

--SET DEBUG FILE TO "/tmp/sp_guardabitacoraencuesta.out";
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF pEmpresa = '' OR pEmpresa IS NULL OR pNumCte = '' OR pNumCte IS NULL OR pTipoProd = '' OR pTipoProd IS NULL 
		OR pTipoRechazo = '' OR pTipoRechazo IS NULL OR pSucursal = '' OR pSucursal IS NULL OR pEjecutivo = '' 
		OR pEjecutivo IS NULL OR pNombre = '' OR pNombre IS NULL THEN

		LET cCodRet = '00001'; --PARAMETRO DE ENTRADA VACIO.
		RETURN cCodRet;
	ELSE
		SELECT fecha_hoy INTO cFecha FROM si_fechas;

		INSERT INTO "informix".si_encuesta_cte(empresa, numcte, tipo_producto, tipo_rechazo, descripcion, sucursal, ejecutivo, nombre, fecha_insert)
			VALUES(pEmpresa, pNumCte, pTipoProd, pTipoRechazo, pDescripcion, pSucursal, pEjecutivo, pNombre, cFecha::DATE);

		RETURN cCodRet;
	END IF;
END;
END PROCEDURE
DOCUMENT
"CREO  : Daniela Ramírez",
"FECHA : 31/Enero/2013",
"BD    : bdinteg";

create procedure "informix".obtenerconexion_pba(pEmpresa char(3), pDSN char(15), pUsuario char(8))
	returning	char(3) as regreso, char(15) as instancia, char(15) as ip, integer as puerto, 
				char(15) as protocolo, char(15) as usuario, char(32) as password, char(15) as db, char(15) as dsn;
	
	define cRegreso char(3);
	define cInstancia char(15);
	define cIP char(15);
	define iPuerto integer;
	define cProtocolo char(15);
	define cUsuario char(15);
	define cPassword char(32);
	define cDB char(15);
	define cDSN char(15);
		
	let cRegreso='000';
	let cInstancia='';
	let cIP='';
	let iPuerto=0;
	let cProtocolo='';
	let cUsuario='';
	let cPassword='';
	let cDB='';
	let cDSN='';
	
set lock mode to wait 3;
set pdqpriority 0;

	begin
		
		select {+INDEX(si_ejecut idx_si_ejecut), +INDEX(si_perfil_ejecut idx_si_perfil_ejecut), +INDEX(si_ejecutdb idx_si_ejecutdb)} first 1 db.instancia, db.ip, db.puerto, db.protocolo, eje.asistente, eje.password, db.bd, db.dsn
		into cInstancia, cIP, iPuerto, cProtocolo, cUsuario, cPassword, cDB, cDSN
		from si_ejecut eje, si_perfil_ejecut per, si_ejecutdb db
		where eje.empresa=pEmpresa
			and eje.ejecutivo=pUsuario
			and per.cod_emp=eje.empresa
			and per.ejecutivo=eje.ejecutivo 			
			and db.sistema=per.sistema
			and db.dsn=pDSN;
	
		if cDSN is null then
			let cRegreso='001';
		end if;
		
		return cRegreso, cInstancia, cIP, iPuerto, cProtocolo, cUsuario, cPassword, cDB, cDSN;
	end	
end procedure;