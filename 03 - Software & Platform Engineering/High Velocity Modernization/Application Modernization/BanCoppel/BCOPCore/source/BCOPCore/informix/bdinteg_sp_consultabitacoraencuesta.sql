CREATE PROCEDURE "informix".sp_consultabitacoraencuesta(pEmpresa CHAR(3))
RETURNING CHAR(5);

DEFINE cCodret            CHAR(5);
DEFINE sql_err 			  INTEGER;
DEFINE cNombreArchivo	  CHAR(64);
DEFINE vsql 			  CHAR(1000);
DEFINE cRuta              CHAR(50);
DEFINE cEmpresa           CHAR(3);
DEFINE cNumCte            CHAR(20);
DEFINE cTipo_Producto     CHAR(4);
DEFINE cTipo_Rechazo      CHAR(4);
DEFINE cDescripcion       CHAR(40);
DEFINE cSucursal          CHAR(4);
DEFINE cEjecutivo         CHAR(8);
DEFINE cNombre            CHAR(45);
DEFINE cfecha_insert      CHAR(10);
DEFINE dfecha_hoy         DATE;
DEFINE cfecha_inicio      CHAR(10);
DEFINE cfecha_fin         CHAR(10);
DEFINE cMostrarFecha      CHAR(10);
DEFINE iDias              INTEGER;
DEFINE iMes               INTEGER;
DEFINE cMes               CHAR(2);
DEFINE cNombreMes         CHAR(3);
DEFINE iAnio              INTEGER;
DEFINE iBiciesto          INTEGER;

LET cCodret               = '00000';
LET sql_err               = 0;
LET cEmpresa              = '';
LET cNumCte               = '';
LET cTipo_Producto        = '';
LET cTipo_Rechazo         = '';
LET cDescripcion          = '';
LET cSucursal             = '';
LET cEjecutivo            = '';
LET cNombre               = '';
LET cfecha_insert         = '';
LET dfecha_hoy            = '';
LET cfecha_inicio         = '';
LET cfecha_fin            = '';
LET cMostrarFecha         = '';
LET iDias                 = 0;
LET iMes                  = 0;
LET cMes                  = '';
LET cNombreMes            = '';
LET iAnio                 = 0;
LET iBiciesto             = 0;

--SET DEBUG FILE TO '/tmp/sp_consultabitacoraencuesta.out';
--TRACE ON;

BEGIN

	ON EXCEPTION SET sql_err
	    LET cCodret = sql_err;    
        RETURN cCodret;
	END EXCEPTION;	
		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;	
	
    SELECT fecha_hoy INTO dfecha_hoy
    FROM "informix".si_fechas WHERE empresa = pEmpresa;
	
	IF NVL(dfecha_hoy,'') <> '' THEN
		LET iMes  =  MONTH(dfecha_hoy);
		LET iAnio =  YEAR(dfecha_hoy);
		
		IF iMes = 1 THEN
			LET iMes = 12;
			LET iAnio = iAnio -1;
		ELSE
			LET iMes = iMes -1; 
		END IF;
		
		LET cMes = LPAD(iMes,2,'0');
		
		LET cfecha_inicio =  cMes ||'/01/' || TO_CHAR(iAnio); 
		
		LET iBiciesto= MOD(iAnio,4);
		
		IF iMes = 1 THEN
			LET cNombreMes= "Ene";
			LET iDias = 31;
		ELIF  iMes = 2 THEN
			LET cNombreMes= "Feb";    
			LET iDias = 28;
			IF iBiciesto = 0 THEN 
				LET iDias = iDias+1;
			END IF;
		ELIF  iMes = 3 THEN
			LET cNombreMes= "Mar";
			LET iDias = 31;
		ELIF  iMes = 4 THEN
			LET cNombreMes= "Abr";
			LET iDias = 30;
		ELIF  iMes = 5 THEN
			LET cNombreMes= "May";
			LET iDias = 31;
		ELIF  iMes = 6 THEN
			LET cNombreMes= "Jun";
			LET iDias = 30;
		ELIF  iMes = 7 THEN
			LET cNombreMes= "Jul";
			LET iDias = 31;
		ELIF  iMes = 8 THEN
			LET cNombreMes= "Ago";
			LET iDias = 31;
		ELIF  iMes = 9 THEN
			LET cNombreMes= "Sep";
			LET iDias = 30;
		ELIF  iMes = 10 THEN
			LET cNombreMes= "Oct";
			LET iDias = 31;
		ELIF  iMes = 11 THEN
			LET cNombreMes= "Nov";
			LET iDias = 30;
		ELIF  iMes = 12 THEN
			LET cNombreMes= "Dic";
			LET iDias = 31;
		END IF;
		
		LET cfecha_fin    =  cMes || "/" || TO_CHAR(iDias) || "/" || TO_CHAR(iAnio);
		
		LET cNombreArchivo = "Reporte_encuesta_" || cNombreMes || iAnio;
		
		SELECT valor INTO cRuta
		FROM bdicred:"informix".sd_param WHERE cod_param = '109';
		
		IF NVL(cRuta,'') <> '' THEN
		
            IF EXISTS(SELECT NumCte FROM "informix".si_encuesta_cte WHERE fecha_insert >= cfecha_inicio AND fecha_insert <= cfecha_fin) THEN
		
			    FOREACH
					SELECT Empresa, NumCte, Tipo_Producto, Tipo_Rechazo, Descripcion, Sucursal, Ejecutivo, Nombre, fecha_insert
					INTO cEmpresa, cNumCte, cTipo_Producto, cTipo_Rechazo, cDescripcion, cSucursal, cEjecutivo, cNombre, cfecha_insert
					FROM "informix".si_encuesta_cte
					WHERE  fecha_insert >= cfecha_inicio AND fecha_insert <= cfecha_fin
					ORDER BY NumCte, Tipo_Producto, Tipo_Rechazo
					
					
					INSERT INTO "informix".si_encuesta_cte_hist (Empresa, NumCte, Tipo_Producto, Tipo_Rechazo, Descripcion, Sucursal, Ejecutivo, Nombre, fecha_insert)
					VALUES ( cEmpresa, cNumCte, cTipo_Producto, cTipo_Rechazo, cDescripcion, cSucursal, cEjecutivo, cNombre, cfecha_insert);
						
					LET cMostrarFecha = SUBSTR(cfecha_insert,4,2) || "/" || SUBSTR(cfecha_insert,1,2) || "/" || SUBSTR(cfecha_insert,7,4);
						
					LET vsql = 'echo "' || TRIM(cEmpresa) || '|' || Trim(cNumCte) || '|' || Trim(cTipo_Producto) || '|' || TRIM(cTipo_Rechazo) || '|' || Trim(cDescripcion) || '|' || Trim(cSucursal) || '|' || Trim(cEjecutivo) || '|' || Trim(cNombre) || '|' || TRIM( cMostrarFecha) || '" >> ' || TRIM(cRuta) ||  trim(cNombreArchivo) || '.txt';
					SYSTEM vsql;
					
			    END FOREACH;
			
			    DELETE FROM "informix".si_encuesta_cte WHERE fecha_insert >= cfecha_inicio AND fecha_insert <= cfecha_fin;
			
			ELSE
			    LET vsql = 'echo "" >> ' || TRIM(cRuta) ||  trim(cNombreArchivo) || '.txt';
				SYSTEM vsql;
				
			END IF;
		ELSE		
			LET cCodret = "00001";
		END IF;
	ELSE
		LET cCodret = "00002";
	END IF;
	
	RETURN cCodret;	
	
END;
END PROCEDURE
DOCUMENT
'AUTOR         : Felipe Urias',
'DESCRIPCION   : traspasa datos de encuesta de tabla principal a historial y genera archivo ',
'BASE DE DATOS : BDINTEG ',
'FECHA         : 05/02/2013';

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