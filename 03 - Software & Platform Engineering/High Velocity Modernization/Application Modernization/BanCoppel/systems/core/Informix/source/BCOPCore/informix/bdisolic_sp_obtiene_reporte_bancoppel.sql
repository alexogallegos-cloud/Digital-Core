CREATE PROCEDURE "informix".sp_obtiene_reporte_bancoppel()
RETURNING CHAR(6);

DEFINE cCodRet  	CHAR(6);
DEFINE cSql			CHAR(1000);
DEFINE cSql2			CHAR(1000);
DEFINE cRuta		CHAR(50);
DEFINE iSqlErr  		INTEGER;
DEFINE cNumcte           	CHAR(20);
DEFINE cNombre1			CHAR(26);
DEFINE cNombre2			CHAR(26);
DEFINE cApellidoP			CHAR(26);
DEFINE cApellidoM		CHAR(26);
DEFINE cCelular		CHAR (13);
DEFINE cCorreo		CHAR (100);
DEFINE cNumSolicitud CHAR(20);
DEFINE cFechaSol CHAR(20);
DEFINE cFechaR CHAR(20); 
DEFINE iEdad CHAR(2);
DEFINE cGenero CHAR(1);
DEFINE cFechaNac CHAR(20);
DEFINE cFechaHoy	CHAR(20);
DEFINE cNomArch		CHAR(100);
DEFINE cNomArch2		CHAR(100);
DEFINE cRutaArchivo	CHAR(200);
DEFINE cRutaArchivo2	CHAR(200);
DEFINE cMes			CHAR(2);
DEFINE cDia			CHAR(2);
DEFINE cAnio		CHAR(4);
DEFINE cNumProducto CHAR(4);




LET cCodRet = '000000';
LET cSql = '';
LET cSql2 = '';
LET cRuta ='';
LET iSqlErr			= 0;
LET cNumCte	= '';
LET cNombre1	= '';
LET cNombre2	= '';
LET cApellidoP		= '';
LET cApellidoM		= '';
LET cCelular	= '';
LET cCorreo	= '';
LET cNumSolicitud='';
LET cFechaSol='';
LET cFechaR ='';
LET iEdad = '';
LET cGenero = '';
LET cFechaNac='';
LET cFechaHoy		= '';
LET cNomArch		= '';
LET cNomArch2		= '';
LET cRutaArchivo	= '';
LET cRutaArchivo2	= '';
LET cMes			= '';
LET cDia			= '';
LET cAnio			= '';
LET cNumProducto = '';


BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodret = iSqlErr;
			RETURN cCodret;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/tmp/ifx14/respaldo/BANCOPPEL.out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	

	SELECT valor INTO cRuta FROM bdisolic:"informix".ss_param WHERE secuencia= '455';
	SELECT valor INTO cNomArch FROM bdisolic:"informix".ss_param WHERE secuencia = '457';
	
	IF TRIM(NVL(cRuta,'')) != '' AND TRIM(NVL(cNomArch,'')) != '' THEN
		SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE INTO cFechaHoy FROM sysmaster:sysshmvals;
		
		LET cDia = LPAD(DAY(cFechaHoy::DATE), 2, '0');
		LET cMes = LPAD(MONTH(cFechaHoy::DATE), 2, '0');
		LET cAnio = SUBSTR(YEAR(cFechaHoy),3,2);	
		
		LET cNomArch = REPLACE(cNomArch,'DD',cDia);
		LET cNomArch = REPLACE(cNomArch,'MM',cMes);
		LET cNomArch = REPLACE(cNomArch,'AA',cAnio);
		LET cNomArch = TRIM(cNomArch) || '.txt';
		
		
		LET cRutaArchivo = TRIM(cRuta) || TRIM(cNomArch);	
		
		
		--Elimina archivo
		LET cSQL = 'rm -rf ' || TRIM(cRutaArchivo);		
		SYSTEM cSQL;	
		--Crea archivo vacio
		LET cSQL = 'touch ' || TRIM(cRutaArchivo);
		SYSTEM cSQL;
		
		
		FOREACH
			SELECT TRIM(a.numcte),TRIM(c.nombre1),TRIM(c.nombre2),TRIM(c.apell_paterno),TRIM(c.apell_materno),TRIM(b.telefono_celular),TRIM(o.correo_elec),TRIM(a.num_solicitud),
			TO_CHAR(a.fecha_insert),TO_CHAR(e.fecha_reevaluacion),TO_CHAR(b.edad),TRIM(b.sexo),TO_CHAR(b.fecha_nacimiento)
			INTO cNumCte,cNombre1,cNombre2,cApellidoP,cApellidoM,cCelular,cCorreo,cNumSolicitud,cFechaSol,cFechaR,iEdad,cGenero,cFechaNac
			FROM ss_solicitudes AS a
			JOIN ss_solic_rt AS e ON a.num_solicitud = e.num_solicitud 
			LEFT JOIN bdisolic:"informix".ss_autorizacion AS f ON a.num_solicitud = f.num_solicitud
			LEFT JOIN bdinteg:"informix".si_cliente AS c ON a.numcte = c.numcte
			LEFT JOIN bdisolic:"informix".ss_revision_determinacion AS b ON a.num_solicitud = b.num_solicitud 
			LEFT JOIN bdinteg:"informix".si_correos AS o ON a.numcte = o.numcte
			WHERE f.status_solicitud = 'AT' AND a.num_producto = '6001' AND e.reevaluado = '1'
				
			
			IF cNumCte IS NULL THEN
			LET cNumCte = ' ';
			END IF;
			
			IF cNombre1 IS NULL THEN
			LET cNombre1 = ' ';
			END IF;		
			
			IF cNombre2 IS NULL OR cNombre2 = " " THEN
			LET cNombre2 = ' ';
			END IF;	
			
			IF cApellidoP IS NULL THEN
			LET cApellidoP = ' ';
			END IF;
			
			IF cApellidoM IS NULL THEN
			LET cApellidoM = ' ';
			END IF;
			
			IF cCelular IS NULL THEN
			LET cCelular = ' ';
			END IF;
			
			IF cCorreo IS NULL THEN
			LET cCorreo = ' ';
			END IF;
			
			IF cNumSolicitud IS NULL THEN
			LET cNumSolicitud = ' ';
			END IF;
			
			IF iEdad IS NULL THEN
			LET iEdad = ' ';
			END IF;
			
			IF cFechaSol IS NULL THEN
			LET cFechaSol = ' ';
			END IF;
			
			
			
			IF cFechaR IS NULL THEN
			LET cFechaR = ' ';
			END IF;
			
			IF cGenero IS NULL THEN
			LET cGenero = ' ';
			END IF;
			
			IF cFechaNac IS NULL THEN
			LET cFechaNac = ' ';
			END IF;
			
			
			--Escribe en archivo
			LET cSQL = 'echo "' || TRIM(cNumCte) || ' | ' || TRIM(cNombre1) || ' | ' || TRIM(cNombre2) || ' | ' || TRIM(cApellidoP) || ' | ' || TRIM(cApellidoM) || ' | ' || TRIM(cCelular) || ' | ' || TRIM(cCorreo) || ' | ' ||  TRIM (cNumSolicitud) || ' | ' ||  cFechaSol || ' | ' ||  cFechaR || ' | ' ||  iEdad || ' | ' ||  cGenero || ' | ' || cFechaNac || '" >> ' || cRutaArchivo;
			/*
			LET cSQL = 'echo "' || TRIM(cNumCte) || ' | ' || TRIM(cNombre1) || ' | ' || TRIM(cNombre2) || ' | ' || TRIM(cApellidoP) || ' | ' || TRIM(cApellidoM) || ' | ' || TRIM(cCelular) || ' | ' || TRIM(cCorreo) || ' | ' ||  TRIM (cNumSolicitud) || ' | ' ||  cFechaSol || ' | ' ||  iEdad || ' | ' ||  cGenero || ' | ' || cFechaNac || '" >> ' || cRutaArchivo;
			*/
				
				IF cSQL IS NULL THEN
					LET cCodRet = '000002';
					RETURN cCodRet;
					EXIT FOREACH;
				ELSE
					SYSTEM cSQL;		
				END IF;
			UPDATE bdisolic:ss_solic_rt SET reevaluado = '2' WHERE num_solicitud = cNumSolicitud;
		END FOREACH;		
	ELSE
		LET cCodret = '000001';
	END IF;
	RETURN cCodret;	
END;
END PROCEDURE
