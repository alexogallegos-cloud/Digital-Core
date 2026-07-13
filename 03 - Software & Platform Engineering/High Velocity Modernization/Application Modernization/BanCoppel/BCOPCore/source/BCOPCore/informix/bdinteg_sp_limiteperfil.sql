CREATE PROCEDURE "informix".sp_limiteperfil(pSucursal CHAR(4), pEjecutivo CHAR(8), pGerente CHAR(8))
	--DATOS A REGRESAR
	RETURNING  
	CHAR(5) AS cCodRet,
	INTEGER AS iLimite;
--========== DEFINIR VARIABLES =======
	DEFINE iSqlErr SMALLINT;
	DEFINE iSamErr SMALLINT;
	DEFINE cErrorInfo CHAR(40);
	DEFINE cCodRet CHAR(5);
	DEFINE iLimite INTEGER;
	DEFINE iGerente INTEGER;
	DEFINE cEjecutivo CHAR(8);
	DEFINE cHora1 CHAR(5);
	DEFINE cHora2 CHAR(5);
	DEFINE iNumCambios	INTEGER;
--============= INICIALIZA VARIABLES ============
	LET iSqlErr = 0;
	LET iSamErr = 0;
	LET cErrorInfo = '';
	LET cCodRet = '00000';
	LET iLimite = 0;
	LET iGerente = 0;
	LET cEjecutivo = '';
	LET cHora1 = '';
	LET cHora2 = '';
	LET iNumCambios = 0;
--============= TRAER CLIENTES ===================
BEGIN
	ON EXCEPTION SET iSqlErr, iSamErr, cErrorInfo
		LET cCodRet = iSqlErr;
		RETURN  cCodRet,iLimite;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    --SET DEBUG FILE TO "/informix/Acuellar/sp_limiteperfil.out";
	--TRACE ON;

	IF ( (NVL(pSucursal,'')) = '' OR (NVL(pEjecutivo,'')) = '' OR (NVL(pGerente,'')) = '' )  THEN
		LET cCodRet = '00001'; 
	ELSE
		-- Valida si un Ejecutivo ha dado de alta a mÃÂ¡s de un gerente
		SELECT COUNT(c.cod_usuario) 
		INTO iLimite
		FROM bdinteg: "informix".si_cambio_perf c
		INNER JOIN bdinteg: "informix".si_fechas f ON c.fecha_cambio = f.fecha_Hoy
		WHERE c.sucursal = pSucursal AND c.password_ant = 'E' AND c.password_nuevo = 'A';
		--AND c.cod_usuario = pEjecutivo;

		select valor
		into iNumCambios
		from si_param
		where cod_param = '471';

		IF iLimite <= iNumCambios then	

			-- Ultimo cambio de promoto a gerente de un empleado
			SELECT c.cod_usuario, max(c.hora_cambio)
			into cEjecutivo, cHora1
			FROM bdinteg: "informix".si_cambio_perf c
			INNER JOIN bdinteg: "informix".si_fechas f ON c.fecha_cambio = f.fecha_Hoy
			WHERE c.sucursal = pSucursal AND c.password_ant = 'E' AND c.password_nuevo = 'A'
			and c.hora_cambio = 
			(select max(hora_cambio) FROM bdinteg: "informix".si_cambio_perf
			where password_ant = 'E' AND password_nuevo = 'A' and sucursal = c.sucursal
			and fecha_cambio = f.fecha_Hoy)
			and c.cod_usuario <> pGerente
			GROUP BY cod_usuario;

			-- Revisar si ese empleado ya no es gerente
			SELECT max(c.hora_cambio)
			into cHora2
			FROM bdinteg: "informix".si_cambio_perf c
			INNER JOIN bdinteg: "informix".si_fechas f ON c.fecha_cambio = f.fecha_Hoy
			WHERE c.sucursal = pSucursal AND c.cod_usuario = cEjecutivo;

			IF cHora1 = cHora2 then

				LET cCodRet = '00001'; 
				-- es el ultimo cambio NO se puede

			elif cHora1 < cHora2 then

				LET cCodRet = '00000'; 
				-- ya NO es gerente

			end if;

		else

			LET cCodRet = '00002';

		END IF;

	END IF;

	RETURN cCodRet,iLimite;

END;
END PROCEDURE
DOCUMENT
'Folio: 466 - RQM 08 030 Limitar OFI Cantidad de Veces que Asigna el Perfil de Gerente',
'Autor: 97893323 Judith Moreno',
'BD: bdinteg',
'Solicita: CUTBERTO GONZALEZ',
'Fecha: 20/08/2018',
'Descripcion: Se crea procedimiento para obtener la cantidad de cambios de perfil de cualquier perfil a Gerente';

CREATE PROCEDURE "informix".sp_altasolicitudmovil_mx()
RETURNING CHAR(5);

--Declaracion de variables
DEFINE vcodret           CHAR(5);
DEFINE vcodretdet        CHAR(5);
DEFINE iSecuencia        INTEGER;
DEFINE iSqlErr           INTEGER;
DEFINE sid               INTEGER;
DEFINE snumcte           CHAR(20);
DEFINE sfolio            CHAR(12);
DEFINE sstatus_valua     INTEGER;
DEFINE sempresa          CHAR(3);
DEFINE svalor_param      INTEGER; 
DEFINE sfecha_insert     DATE;
DEFINE iNumCte			 CHAR(9);

--Inicializacion de variables
LET vcodret              = '000';
LET vcodretdet           = "000";
LET iSecuencia           = 0;
LET sid                  = 0;
LET snumcte              = "";
LET sfolio               = "";
LET sstatus_valua        = 0;
LET sempresa             = "";
LET svalor_param         = 0;
LET sfecha_insert        = "";

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3; 

--SET DEBUG FILE TO '/informix/emm/sp_altasolicitudmovil.out';
--TRACE ON;

BEGIN
 ON EXCEPTION SET iSqlErr
     IF iSqlErr <> 0 THEN
	LET vcodret = iSqlErr;
	RETURN vCodret;
    END IF;
 END EXCEPTION

 --Efectua la revision del numero de folio-

 CALL bdinteg:sp_monitor_folio() RETURNING vcodret;

 IF TRIM(vcodret)!="000" THEN
    INSERT INTO "informix".si_valida_folio_detalle(folio, rutina, numcte, cod_ret, fecha)
        VALUES('','sp_altasolicitudmovil','',vcodret,current);
 END IF;

   ---Ejecuta Cursor principal de reviso de folios para solicitud movil
 FOREACH
        SELECT {+INDEX (bdinteg:"informix".si_solicitud_movil idx_valida_opera)} id, numcte, folio,status_valua,fecha_insert
        INTO sid, snumcte,sfolio,sstatus_valua,sfecha_insert
        FROM bdinteg:"informix".si_solicitud_movil
        WHERE bdinteg:si_solicitud_movil.folio_procesado = "0"
        AND bdinteg:si_solicitud_movil.status_valua = 0
        ORDER BY folio

        --Ejecuta rutina de alta de solicitud por folio
        IF sfolio IS NOT NULL THEN

            CALL sp_ALTA_CTEMOVIL(sfolio)
            RETURNING vcodretdet,snumcte;

            IF vcodretdet = "00000" OR vcodretdet = "000000" THEN

               UPDATE "informix".si_solicitud_movil
               SET(status_valua)=(1)
              WHERE folio = sfolio;

            END IF;
        END IF;
		
		IF snumcte <> '' THEN
			SELECT numcte INTO iNumCte FROM bdinteg:"informix".si_bitacora_ife where id_sol_movil <> '' and id_sol_movil = sid;
			
			IF iNumCte = '' THEN
				UPDATE bdinteg:"informix".si_bitacora_ife SET numcte = snumcte WHERE id_sol_movil = sid;
			END IF;
		END IF;
		
 END FOREACH;


RETURN vcodret;
END;
END PROCEDURE
DOCUMENT
"Autor      : Sergio Fabricio Ruiz Jimenez",
"Descripcion: Ejecuta Cursor principal de folios para solicitud movil",
"Fecha      : 09/04/2015",
"Version    : 1.0",
"Modifico   : ",
"Autor      : Eduardo Martinez",
"Descripcion: Agrega el numcte a si_bitacora_ife",
"Fecha      : 01/11/2019",
"Version    : 1.0",
"Modifico   : ";

CREATE PROCEDURE "informix".sp_altasolicitudmovil_old()
RETURNING CHAR(5);

--Declaracion de variables
DEFINE vcodret           CHAR(5);
DEFINE vcodretdet        CHAR(5);
DEFINE iSecuencia        INTEGER;
DEFINE iSqlErr           INTEGER;
DEFINE sid               INTEGER;
DEFINE snumcte           CHAR(20);
DEFINE sfolio            CHAR(12);
DEFINE sstatus_valua     INTEGER;
DEFINE sempresa          CHAR(3);
DEFINE svalor_param      INTEGER; 
DEFINE sfecha_insert     DATE;
DEFINE iNumCte			 CHAR(9);

--Inicializacion de variables
LET vcodret              = '000';
LET vcodretdet           = "000";
LET iSecuencia           = 0;
LET sid                  = 0;
LET snumcte              = "";
LET sfolio               = "";
LET sstatus_valua        = 0;
LET sempresa             = "";
LET svalor_param         = 0;
LET sfecha_insert        = "";

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3; 

--SET DEBUG FILE TO '/informix/emm/sp_altasolicitudmovil.out';
--TRACE ON;

BEGIN
 ON EXCEPTION SET iSqlErr
     IF iSqlErr <> 0 THEN
	LET vcodret = iSqlErr;
	RETURN vCodret;
    END IF;
 END EXCEPTION

 --Efectua la revision del numero de folio-

 CALL bdinteg:sp_monitor_folio() RETURNING vcodret;

 IF TRIM(vcodret)!="000" THEN
    INSERT INTO "informix".si_valida_folio_detalle(folio, rutina, numcte, cod_ret, fecha)
        VALUES('','sp_altasolicitudmovil','',vcodret,current);
 END IF;

   ---Ejecuta Cursor principal de reviso de folios para solicitud movil
 FOREACH
        SELECT {+INDEX (bdinteg:"informix".si_solicitud_movil idx_valida_opera)} id, numcte, folio,status_valua,fecha_insert
        INTO sid, snumcte,sfolio,sstatus_valua,sfecha_insert
        FROM bdinteg:"informix".si_solicitud_movil
        WHERE bdinteg:si_solicitud_movil.folio_procesado = "0"
        AND bdinteg:si_solicitud_movil.status_valua = 0
        ORDER BY folio

        --Ejecuta rutina de alta de solicitud por folio
        IF sfolio IS NOT NULL THEN

            CALL sp_ALTA_CTEMOVIL(sfolio)
            RETURNING vcodretdet,snumcte;

            IF vcodretdet = "00000" OR vcodretdet = "000000" THEN

               UPDATE "informix".si_solicitud_movil
               SET(status_valua)=(1)
              WHERE folio = sfolio;

            END IF;
        END IF;
		
		IF snumcte <> '' THEN
			SELECT {+INDEX(si_bitacora_ife idx_id_sol_mov_2019)} numcte INTO iNumCte FROM bdinteg:"informix".si_bitacora_ife where id_sol_movil <> '' and id_sol_movil = sid;
			
			IF iNumCte = '' THEN
				UPDATE {+INDEX(si_bitacora_ife idx_id_sol_mov_2019)} bdinteg:"informix".si_bitacora_ife SET numcte = snumcte WHERE id_sol_movil = sid;
			END IF;
		END IF;
		
 END FOREACH;


RETURN vcodret;
END;
END PROCEDURE
DOCUMENT
"Autor      : Sergio Fabricio Ruiz Jimenez",
"Descripcion: Ejecuta Cursor principal de folios para solicitud movil",
"Fecha      : 09/04/2015",
"Version    : 1.0",
"Modifico   : ",
"Autor      : Eduardo Martinez",
"Descripcion: Agrega el numcte a si_bitacora_ife",
"Fecha      : 01/11/2019",
"Version    : 1.0",
"Modifico   : ";

CREATE PROCEDURE "informix".sp_generar_reporte_sos()
RETURNING 	VARCHAR(6) AS cCodRet,
			VARCHAR(40) AS cMensaje;
			--VARCHAR(40) AS cRegistros;
			
		  
/*DEFINICION DE VARIABLES */

DEFINE 	cCodRet      	  VARCHAR(6);
DEFINE 	cMensaje      	  VARCHAR(40);
DEFINE 	cRegistros     	  VARCHAR(40);
DEFINE 	vsNombreArchivo   VARCHAR(50);
DEFINE 	vsNombreArchivo2  VARCHAR(50);
DEFINE  cSQL			  VARCHAR(250);
DEFINE  cSQL1			  LVARCHAR(500);
DEFINE  cSQL2			  LVARCHAR(500);
DEFINE  cSQL3			  LVARCHAR(500);
DEFINE  iCont			  INTEGER;	
DEFINE  iSqlErr			  INTEGER;
DEFINE	dFecha		      DATE;
DEFINE  vNumcte		      VARCHAR(20);
DEFINE  vNumcte2		  VARCHAR(20);
DEFINE  vNomCorr		      VARCHAR(104);
DEFINE  vNomINC		      VARCHAR(104);
DEFINE  vFechaNacCor	  DATE;
DEFINE  vFechaNacINC	  DATE;

/*FIN DE DEFINICION DE VARIABLES*/
LET cCodRet   = 0;
LET cMensaje   = '';
LET cRegistros = '';
LET vsNombreArchivo = '';
LET vsNombreArchivo2 = '';
LET cSQL	    = '';
LET cSQL1	    = '';
LET cSQL2	    = '';
LET cSQL3	    = '';	  
LET iCont	    = 0;	  
LET iSqlErr     = 0;
LET dFecha = DATE(0);
LET vNumcte	= '';
LET vNumcte2	= '';
LET vNomCorr	= '';
LET vNomINC	= '';
LET vFechaNacCor = DATE(0);
LET vFechaNacINC = DATE(0);




BEGIN
	
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN -- manejador de errores
			LET cCodRet = iSqlErr;
			LET cMensaje  = 'ERROR AL GENERAR REPORTE';
		
			RETURN cCodRet,cMensaje;
		END IF;
	END EXCEPTION;
	

	
	
	--Nombre del archivo
	LET vsNombreArchivo = '/RESPALDOSNEW/REPORTE_CORRECCION_DATOS.csv';
	LET vsNombreArchivo2 = '/RESPALDOSNEW/REPORTE_FUSION_DATOS.csv';
						

		LET cSQL='dbaccess bdinteg /RESPALDOSNEW/generar_reporte_correcciones_sos.sql';
		SYSTEM cSQL;

		LET cSQL='dbaccess bdinteg /RESPALDOSNEW/generar_reporte_fusion_sos.sql';
		SYSTEM cSQL;
		
		LET cSQL2='zip /RESPALDOSNEW/REPORTE_CORRECCION_DATOS.zip -P 4846+16svh13th516*2019 /RESPALDOSNEW/REPORTE_CORRECCION_DATOS.csv';
		SYSTEM cSQL2;
		
		LET cSQL3='zip /RESPALDOSNEW/REPORTE_FUSION_DATOS.zip -P 4846+16svh13th516*2019 /RESPALDOSNEW/REPORTE_FUSION_DATOS.csv';
		SYSTEM cSQL3;
		
		LET cMensaje  = 'REPORTE GENERADO CORRECTAMENTE';
		
		LET cCodRet = '000000';

	RETURN cCodRet,cMensaje;
END;
END PROCEDURE;