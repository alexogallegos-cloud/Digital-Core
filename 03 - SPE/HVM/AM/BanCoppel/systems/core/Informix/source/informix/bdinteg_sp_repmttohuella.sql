CREATE PROCEDURE "informix".sp_repmttohuella(pFechaIni DATE, pFechaFin DATE, pSucursal CHAR(4), pOpc INT)

RETURNING
--Datos a Regresar--
CHAR(5),    					--Codigo de Retorno
DATETIME YEAR TO SECOND,		--Fecha y Hora de Mantenimiento
CHAR(4),						--No. de Sucursal donde se realizo Mantenimiento
CHAR(9), 						--No. de Cliente al que se realizo mantenimiento
CHAR(108),						--Nombre completo del Cliente (nombre1 + nombre2 + apell_paterno + apell_materno)
CHAR(1),						--Estatus del mantenimiento de la huella
CHAR(20),						--Tipo de identificaciÃ³n con la que se realizo el mantenimiento
CHAR(20),						--Folio de la identificaciÃ³n con la que se realizo el mantenimiento
CHAR(8),						--No. de empleado del promotor que realizo el mantenimiento
CHAR(45),						--Nombre del promotor que realizo el mantenimiento
CHAR(8),						--No. de empleado del Gerente que autorizo el mantenimiento
CHAR(45),						--Nombre del Gerente que autorizo el mantenimiento
CHAR(8),						--No. de empleado del Cajero Principal donde se finaliza el proceso de mantenimiento
CHAR(45),						--Nombre del Cajero Principal donde se finaliza el proceso de mantenimiento
CHAR(40);						--Nombre de Sucursal

--DEFINICION DE VARIABLES--
DEFINE iSql_err 	INTEGER;
DEFINE cCodRet 		CHAR(5);
DEFINE dFechaMtto	DATETIME YEAR TO SECOND;
DEFINE cNumSucur	CHAR(4);
DEFINE cNumCte 		CHAR(9);
DEFINE cNomCte		CHAR(108);
DEFINE cStatus		CHAR(1);
DEFINE cTpoIdent 	CHAR(20);
DEFINE cFolIdent	CHAR(20);
DEFINE cNumProm	 	CHAR(8);
DEFINE cNomProm	 	CHAR(45);
DEFINE cNumGeren 	CHAR(8);
DEFINE cNomGeren	CHAR(45);
DEFINE cNumCajer	CHAR(8);
DEFINE cNomCajer	CHAR(45);
DEFINE cNomSucur	CHAR(40);
DEFINE cSecuencia 	CHAR(2);

--INICIACION DE VARIABLES--
LET iSql_err 	=	0;
LET cCodRet 	=	'0000';
LET dFechaMtto	=	'';
LET cNumSucur	=	'';
LET cNumCte 	=	'';
LET cNomCte		=	'';
LET cStatus		=	'';
LET cTpoIdent 	=	'';
LET cFolIdent	=	'';
LET cNumProm	=	'';
LET cNomProm	=	'';
LET cNumGeren 	=	'';
LET cNomGeren	=	'';
LET cNumCajer	=	'';
LET cNomCajer	=	'';
LET cNomSucur   = 	'';
LET cSecuencia   = 	'';


	--SET DEBUG FILE TO "/informix/jagl/bdinteg/sp_repmttohuella.out";
	--TRACE ON;
	
	BEGIN
	
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
				RETURN  cCodRet, dFechaMtto, cNumSucur, cNumCte, cNomCte, cStatus, cTpoIdent, cFolIdent, cNumProm,  cNomProm, cNumGeren, cNomGeren, cNumCajer, cNomCajer, cNomSucur;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pOpc = 1 THEN
		
			FOREACH
				SELECT sucursal, nombre INTO cNumSucur, cNomSucur FROM bdinteg:"informix".si_sucursales 
				WHERE tpo_sucursal = 'S' ORDER BY sucursal
				
				LET cCodRet = '0035';
				
				
				RETURN  cCodRet, dFechaMtto, TRIM(NVL(cNumSucur, '')), cNumCte, cNomCte, cStatus, cTpoIdent,  cFolIdent, cNumProm, cNomProm, cNumGeren, cNomGeren, cNumCajer, cNomCajer,  TRIM(NVL(cNomSucur, '')) WITH RESUME;
			
			END FOREACH;
		
		ELSE
				IF TRIM(NVL(pSucursal, '')) = '' THEN
					FOREACH
						
						/*
						SELECT hue.fecha_alta, hue.sucursal, hue.numcte, 
								TRIM(cl.nombre1) || " " || TRIM(cl.nombre2) || " " || TRIM(cl.apell_paterno) || " " || TRIM(cl.apell_materno), 
								hue.status, hue.nueva_ident, hue.num_refer, hue.operador, hue.empleado, hue.usuario3
						INTO dFechaMtto, cNumSucur, cNumCte, cNomCte, cStatus, cTpoIdent, cFolIdent, cNumProm, cNumGeren, cNumCajer
						FROM bdinteg:"informix".si_huella_temp hue, bdinteg:"informix".si_cliente cl
						WHERE hue.numcte=cl.numcte AND hue.fecha_alta::date>=pFechaIni AND hue.fecha_alta::date<=pFechaFin ORDER BY hue.fecha_alta DESC
						*/
						
						SELECT {+AVOID_FULL (bdinteg:"informix".si_rep_mtto_huella)}
						fecha_hora_alta, sucursal, numcte, nombre_cte, status, nueva_ident, num_refer, operador, nombre_promotor, empleado, nombre_gerente, usuario3, nombre_cajero
						INTO dFechaMtto, cNumSucur, cNumCte, cNomCte, cStatus, cTpoIdent, cFolIdent, cNumProm, cNomProm, cNumGeren, cNomGeren, cNumCajer, cNomCajer
						FROM bdinteg:"informix".si_rep_mtto_huella
						WHERE fecha_alta between pFechaIni AND pFechaFin 
						ORDER BY fecha_alta DESC
						--limit 10

						LET cCodRet = '0035';
						
						RETURN  TRIM(NVL(cCodRet, '')), TRIM(NVL(dFechaMtto, '')), TRIM(NVL(cNumSucur, '')), TRIM(NVL(cNumCte, '')), TRIM(NVL(cNomCte, '')), TRIM(NVL(cStatus, '')), TRIM(NVL(cTpoIdent, '')), TRIM(NVL(cFolIdent, '')), TRIM(NVL(cNumProm, '')), TRIM(NVL(cNomProm, '')), TRIM(NVL(cNumGeren, '')), TRIM(NVL(cNomGeren, '')), TRIM(NVL(cNumCajer, '')), TRIM(NVL(cNomCajer, '')), TRIM(NVL(cNomSucur, '')) WITH RESUME;
						
					END FOREACH;
							
				ELSE
					FOREACH
						/*
						SELECT hue.fecha_alta, hue.sucursal, hue.numcte, 
								TRIM(cl.nombre1) || " " || TRIM(cl.nombre2) || " " || TRIM(cl.apell_paterno) || " " || TRIM(cl.apell_materno), hue.status, hue.nueva_ident, hue.num_refer, hue.operador, hue.empleado, hue.usuario3
						INTO dFechaMtto, cNumSucur, cNumCte, cNomCte, cStatus, cTpoIdent, cFolIdent, cNumProm, cNumGeren, cNumCajer
						FROM bdinteg:"informix".si_huella_temp hue, bdinteg:"informix".si_cliente cl
						WHERE hue.numcte=cl.numcte AND hue.sucursal=pSucursal AND hue.fecha_alta::date>=pFechaIni AND hue.fecha_alta::date<=pFechaFin ORDER BY hue.fecha_alta DESC
						*/
						
						SELECT {+AVOID_FULL (bdinteg:"informix".si_rep_mtto_huella)}
						fecha_hora_alta, sucursal, numcte, nombre_cte, status, nueva_ident, num_refer, operador, nombre_promotor, empleado, nombre_gerente, usuario3, nombre_cajero
						INTO dFechaMtto, cNumSucur, cNumCte, cNomCte, cStatus, cTpoIdent, cFolIdent, cNumProm, cNomProm, cNumGeren, cNomGeren, cNumCajer, cNomCajer
						FROM bdinteg:"informix".si_rep_mtto_huella
						WHERE sucursal = pSucursal
						AND fecha_alta between pFechaIni AND pFechaFin 
						ORDER BY fecha_alta DESC
						--limit 10
						
						LET cCodRet = '0035';
						
						RETURN  TRIM(NVL(cCodRet, '')), TRIM(NVL(dFechaMtto, '')), TRIM(NVL(cNumSucur, '')), TRIM(NVL(cNumCte, '')), TRIM(NVL(cNomCte, '')), TRIM(NVL(cStatus, '')), TRIM(NVL(cTpoIdent, '')), TRIM(NVL(cFolIdent, '')), TRIM(NVL(cNumProm, '')), TRIM(NVL(cNomProm, '')), TRIM(NVL(cNumGeren, '')), TRIM(NVL(cNomGeren, '')), TRIM(NVL(cNumCajer, '')), TRIM(NVL(cNomCajer, '')), TRIM(NVL(cNomSucur, '')) WITH RESUME;
						
					END FOREACH;
						
				END IF;
		END IF;
		
		IF cCodRet = '0000' THEN
				LET cCodRet = '0001';
				RETURN  TRIM(NVL(cCodRet, '')), TRIM(NVL(dFechaMtto, '')), TRIM(NVL(cNumSucur, '')), TRIM(NVL(cNumCte, '')), TRIM(NVL(cNomCte, '')), TRIM(NVL(cStatus, '')), TRIM(NVL(cTpoIdent, '')), TRIM(NVL(cFolIdent, '')), TRIM(NVL(cNumProm, '')), TRIM(NVL(cNomProm, '')), TRIM(NVL(cNumGeren, '')), TRIM(NVL(cNomGeren, '')), TRIM(NVL(cNumCajer, '')), TRIM(NVL(cNomCajer, '')), TRIM(NVL(cNomSucur, ''));
		END IF;
		

	END


END PROCEDURE
DOCUMENT
'Generacion de un reporte de mantenimiento de huellas por busqueda de sucursal o todas las sucursales',
'Autor : Jesus Horacio Lopez Gonzalez',
'FECHA : 04/06/2013',
'BD: bdinteg';

CREATE PROCEDURE "informix".considentificacion_web(p_numcte char(10))
   RETURNING CHAR(5), CHAR(20), CHAR(20);

   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE p_mensaje           CHAR(80);
   DEFINE nrows               SMALLINT;

   DEFINE v_tipoIdent		CHAR(50);
   DEFINE v_noIdent			CHAR(50);

   LET v_tipoIdent = "";
   LET v_noIdent   = "";
	

	--SET DEBUG FILE TO "/respaldosbd/mario/trace.sql";
	--TRACE ON;
BEGIN	
	ON EXCEPTION SET sql_err, isam_err, error_info
		SET DEBUG FILE TO "VerifCte1.err";
		TRACE sql_err||" * "||isam_err||" * "||error_info;
		LET cod_ret = sql_err;
		RETURN  NVL(cod_ret,'00001'),NVL(v_tipoIdent,''), NVL(v_noIdent,'');
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	LET cod_ret = '00000';
	LET p_mensaje = "Operacion Realizada Exitosamente";	

	SELECT trim(tipo_ident),trim(num_ident)
	INTO v_tipoIdent,v_noIdent 
	FROM "informix".si_bitmant_huellarostro
    	WHERE numcte = trim(p_numcte) AND  fecha_hora = (SELECT MAX(fecha_hora) FROM bdinteg:"informix".si_bitmant_huellarostro WHERE NUMCTE = trim(p_numcte));
    
    IF trim(v_noIdent) is null then
		let cod_ret = "00104";
		RETURN  NVL(cod_ret,'00001'),NVL(v_tipoIdent,''), NVL(v_noIdent,'');
    end if

    RETURN  NVL(cod_ret,'00001'),NVL(v_tipoIdent,''), NVL(v_noIdent,'');
END
END PROCEDURE

DOCUMENT
'SPL Extrae tipo y numero de identificacion ingresados en manhuella',
"MODIFICO : CRISTIAN IBARRA",
"FECHA : 27/Febrero/2021",
"Ver.  : 1.0",
"BD    : bdinteg";

CREATE PROCEDURE "informix".sp_consulta_huella_dec_temp(
pNumcte CHAR(20)
)

RETURNING
CHAR(5)    AS cCodigoRet,
SMALLINT   AS sSecuencia,
SMALLINT   AS sIdTemplate,
CHAR(1000) AS cTemplate,
CHAR(25)   AS cImagen,
CHAR(50)   AS cRutaimg;

DEFINE sql_err INTEGER;
DEFINE cCodigoRet CHAR(5);
DEFINE sSecuencia SMALLINT;
DEFINE sIdTemplate SMALLINT;
DEFINE cTemplate CHAR(1000);
DEFINE cImagen CHAR(25);
DEFINE cRutaimg CHAR(50);
DEFINE sSecuenciaCambiar SMALLINT;
DEFINE sIdTemplateCambiar SMALLINT;
DEFINE cTemplateCambiar CHAR(1000);
DEFINE cImagenCambiar CHAR(25);
DEFINE cRutaimgCambiar CHAR(50);

LET cCodigoRet = '00000';
LET sSecuencia = 0;
LET sIdTemplate = 0;
LET cTemplate = '';
LET cImagen = '';
LET cRutaimg = '';
LET sSecuenciaCambiar = 0;
LET sIdTemplateCambiar = 0;
LET cTemplateCambiar = '';
LET cImagenCambiar = '';
LET cRutaimgCambiar = '';

BEGIN
 
    ON EXCEPTION SET sql_err

		RETURN sql_err, sSecuencia, sIdTemplate, cTemplate, cImagen, cRutaimg;

    END EXCEPTION;

	-- SET DEBUG FILE TO "/home/sysifx/Mario/trace.sql";
	-- TRACE ON;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--VALIDAR DATOS VACIOS
	IF NVL(pNumcte,'') = '' THEN	
		LET cCodigoRet = '00001'; --Datos vacios
		RETURN cCodigoRet, sSecuencia, sIdTemplate, cTemplate, cImagen, cRutaimg;
	ELSE 	
		FOREACH
			SELECT secuencia, id_template, Template, Imagen, Rutaimg 
			INTO sSecuenciaCambiar, sIdTemplateCambiar, cTemplateCambiar, cImagenCambiar, cRutaimgCambiar 
			FROM "informix".si_cte_huella_dec_temp WHERE numcte = pNumcte
			LET sSecuencia = sSecuenciaCambiar;
			LET sIdTemplate = sIdTemplateCambiar;
			LET cTemplate = cTemplateCambiar;
			LET cImagen = cImagenCambiar;
			LET cRutaimg = cRutaimgCambiar;
			RETURN cCodigoRet, sSecuencia, sIdTemplate, cTemplate, cImagen, cRutaimg WITH RESUME;
		END FOREACH;
	END IF;
 
END;
END PROCEDURE;