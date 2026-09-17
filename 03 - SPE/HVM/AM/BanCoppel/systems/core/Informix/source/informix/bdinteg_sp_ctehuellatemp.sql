CREATE PROCEDURE "informix".sp_ctehuellatemp(cEmpresa CHAR(3), cNumCte CHAR(20), cOperador CHAR (8), cEmpleado CHAR(8),
                                    cUsuario3 CHAR(8), cSucursal CHAR(4), cNueva_Ident CHAR(20), cNum_Refer CHAR (20),
                                    dFecha_Alta DATE, cTipo CHAR(1), cMapad CHAR(942), cMapai CHAR(942))
    RETURNING CHAR(5), SMALLINT;

    DEFINE cCodRet          CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE smSigSec         SMALLINT;
    DEFINE cExiste          SMALLINT;
    DEFINE cTp_Persona      CHAR(2);
    DEFINE iSqlErr          INTEGER;
    DEFINE iIsamErr         INTEGER;
    DEFINE cEsFisica        CHAR(1);
    DEFINE smSecuencia      SMALLINT;
    DEFINE cPromotor        CHAR(8);
    DEFINE cGerente         CHAR(8);
    DEFINE cNombramiento    CHAR(20);
	DEFINE cnumctehtemp		INTEGER;  -- GRLL 20-11-18

    LET cCodRet = "000";
    LET cCodRet2 = "";
    LET smSigSec = 0;
    LET cExiste = 0;
    LET cTp_Persona = "";
    LET smSecuencia = 0;
    LET cPromotor = "";
    LET cGerente  = "";
	LET cnumctehtemp = 0;   -- GRLL 20-11-18

--set debug file to "/tmp/sp_CteHuellaTemp.out";
--trace on;

BEGIN
    ON EXCEPTION SET iSqlErr,iIsamErr
        IF iSqlErr != 0 THEN
            LET cCodRet=iSqlErr;
            RETURN cCodRet,smSigSec;
        END IF;
    END EXCEPTION;
	
	SET ISOLATION TO dirty READ;		
	SET LOCK MODE TO WAIT 3;			

--    LET cCodRet = "741";
--    RETURN cCodRet,smSigSec;

    SELECT tpo_persona INTO cTp_Persona
    FROM si_cliente
    WHERE numcte = cNumCte;

    SELECT es_fisica INTO cEsFisica
    FROM si_tipper
    WHERE tpo_persona = cTp_Persona;
    IF UPPER(cEsFisica) != "S" THEN
        LET cCodRet = "120";
    END IF;

    SELECT 1 INTO cExiste
    FROM si_sucursales
    WHERE sucursal=cSucursal;
    IF cExiste IS NULL THEN
        LET cCodRet="111";
    END IF;

    --Inicio de Proceso en Plataforma
    IF cTipo = 1 THEN
        --- Verifica recepcion correcta de datos
        IF cNumCte IS NULL OR Trim(cNumCte) = ""
            OR cMapad IS NULL OR cMapad = ""
            OR cMapai IS NULL OR cMapai = "" then
            LET cCodRet = "110";
        END IF;

        SELECT 1 INTO cExiste
           FROM si_ejecut
           WHERE ejecutivo=cOperador;
        IF cExiste IS NULL THEN
           LET cCodRet="112";
        END IF;

        IF TRIM(cEmpleado)<> "" then
            SELECT 1 INTO cExiste
            FROM si_ejecut
            WHERE ejecutivo=cEmpleado;
            IF cExiste IS NULL THEN
                LET cCodRet="112";
            END IF;
        END IF;
--RGH
        SELECT nombramiento
        INTO cNombramiento
        FROM si_ejecut
        WHERE ejecutivo=cEmpleado;

        --IF cNombramiento IS NULL or TRIM(UPPER(cNombramiento))<> "GERENTE TITULAR" THEN -- GRLL 20-11-18
		-- Se agrego la validacion para el nuevo perfil SUB-GERENTE
		IF TRIM(UPPER(cNombramiento)) in ('GERENTE TITULAR','JEFE OP. Y SERV') AND cNombramiento IS NOT NULL THEN -- GRLL 20-11-18
		ELSE
            LET cCodRet="119";
            RETURN cCodRet,smSigSec;
        END IF;
--RGH
		SELECT count(numcte) 
		INTO cnumctehtemp 
		FROM si_huella_temp WHERE numcte = cNumCte; -- GRLL 20-11-18
		
        --IF EXISTS (SELECT numcte FROM si_huella_temp WHERE numcte = cNumCte) THEN -- GRLL 20-11-18
		IF cnumctehtemp > 0 THEN  -- GRLL 20-11-18
            LET cExiste = 1;
        ELSE
            LET cExiste = 0;
        END IF;

        IF cExiste = 1 THEN
           SELECT MAX(secuencia) + 1 INTO smSigSec
           FROM si_huella_temp
           WHERE numcte = cNumCte;
        ELSE
           LET smSigSec = 1;
        END IF;

        INSERT INTO si_huella_temp
            (empresa, numcte, secuencia, status, operador, empleado, usuario3, sucursal, nueva_ident, num_refer, fecha_alta, dmapa, imapa)
        VALUES
            (cEmpresa, cNumCte, smSigSec, "M", cOperador, cEmpleado, cUsuario3, cSucursal, cNueva_Ident, cNum_Refer, CURRENT, cMapad, cMapai);
    END IF;

    --Fin de Proceso en Caja
    IF cTipo = 2 THEN
        SELECT 1 INTO cExiste
             FROM si_ejecut
             WHERE ejecutivo=cUsuario3;
        IF cExiste IS NULL THEN
             LET cCodRet="112";
        END IF;

--RGH
        SELECT nombramiento
        INTO cNombramiento
        FROM si_ejecut
        WHERE ejecutivo=cEmpleado;

        --IF cNombramiento IS NULL or TRIM(UPPER(cNombramiento))<> "GERENTE TITULAR" THEN -- GRLL 20-11-18
		-- Se agrego la validacion para el nuevo perfil SUB-GERENTE
		IF TRIM(UPPER(cNombramiento)) in ('GERENTE TITULAR','JEFE OP. Y SERV') AND cNombramiento IS NOT NULL THEN -- GRLL 20-11-18
		ELSE
            LET cCodRet="119";
            RETURN cCodRet,smSigSec;
        END IF;
--RGH

        SELECT MAX(secuencia) INTO smSecuencia FROM si_huella_temp WHERE numcte = TRIM(cNumCte);

        UPDATE si_huella_temp
        SET status = "A", usuario3 = cUsuario3, nueva_ident = cNueva_Ident, num_refer = cNum_Refer
        WHERE  numcte = cNumCte AND status = "M" AND secuencia = smSecuencia;

        SELECT operador, empleado INTO cPromotor, cGerente FROM si_huella_temp WHERE numcte = TRIM(cNumCte) AND secuencia = smSecuencia;

        EXECUTE PROCEDURE sp_ctehuella(cEmpresa, cSucursal, cPromotor, cEmpleado, CURRENT, "C", cNumCte, cMapad, cMapai) INTO cCodRet2,smSigSec;

        --IF TRIM(cCodRet2) <> "000" THEN
        LET cCodRet = cCodRet2;
        --END IF
    END IF;

RETURN cCodRet,smSigSec;
END;
END PROCEDURE
DOCUMENT
"Alta de Huella de cliente persona fisica temporal",
"AutOR : Priscilla Mercado CampaÃ±a.",
"FECHA : 15-11-2008",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".sp_rpt_sol_movil()
returning char(5) as CodRet;

DEFINE cCodRet 		CHAR(5);
DEFINE iSql_err     INT;
DEFINE sFecha       CHAR(10);
DEFINE sFechaArch   CHAR(10);
DEFINE cCmd1        CHAR(10000);
DEFINE cCmd2        CHAR(10000);
DEFINE cCmd3        CHAR(10000);
DEFINE cCmd4        CHAR(10000);
DEFINE cQuery        CHAR(10000);
DEFINE pArchDescarga CHAR(100);
DEFINE sDia         CHAR(2);
DEFINE sMes         CHAR(2);
DEFINE sYear        CHAR(4);

LET cCodRet 		='00000';
LET iSql_err        =0;
LET sFecha          ='';
LET cCmd1           ='';
LET cCmd2           ='';
LET cCmd3           ='';
LET cCmd4           ='';
LET pArchDescarga   ='';
LET sFechaArch      ='';
LET sDia            ='';
LET sMes            ='';
LET sYear           ='';
LET cQuery			='';

BEGIN

    ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO dirty READ;
	SET LOCK MODE TO WAIT 3;
    
    --SET DEBUG FILE TO '/informix/VH/movil/sp_rpt_sol_movil.out';
    --TRACE ON;

    LET sfecha = (select fecha_hoy from si_fechas);
    --LET sFechaArch=(select REPLACE(fecha_hoy,'/','') from si_fechas);

    LET sDia=(select day(fecha_hoy) from si_fechas);
    LET sMes=(select month(fecha_hoy) from si_fechas);
    LET sYear=(select year(fecha_hoy) from si_fechas);

    IF LENGTH(sDia)<2 THEN
         LET sDia="0"||sDia;
    END IF;

    IF LENGTH(sMes)<2 THEN
         LET sMes="0"||sMes;
    END IF;

    LET sFechaArch=sDia||sMes||sYear;

    LET pArchDescarga='"/RESPALDOSNEW/reporte_de_solicitudes_moviles_'||TRIM(sFechaArch)||'.txt" delimiter "|" ';
	-- Solicitudes completas
    LET cCmd1 = 'select a.ejecutivo, d.nombre, a.fecha_insert, d.sucursal, d.centro_costos, b.producto,c.num_solicitud, a.ap_apell_paterno as apellido_paterno, a.ap_apell_materno as apell_materno, a.ap_nombre1 as nombre1, a.ap_nombre2 as nombre2, TO_CHAR(f.fecha_nac, "%d/%m/%Y"),a.telefono, c.status_solicitud, generico1 as Zona from bdinteg:si_solicitud_movil a, bdisolic:ss_solicitudes_movil b, bdisolic:ss_solicitudes c, (select distinct ejecutivo, nombre, sucursal, centro_costos, generico1 from si_usuario_movil where activo=1) d, bdinteg:si_cliente e, bdinteg:si_ctepf f where not a.folio is null and not a.numcte is null and a.folio=b.folio_movil and b.num_solicitud=c.num_solicitud and a.numcte=e.numcte and a.numcte=f.numcte and a.ejecutivo=d.ejecutivo and a.fecha_insert=c.fecha_insert and a.fecha_insert between "'||sFecha||'" and "'||sFecha||'"';
	
	-- Solicitudes rechazadas
    LET cCmd2 = 'select a.ejecutivo, d.nombre, a.fecha_insert, d.sucursal, d.centro_costos, b.producto,b.num_solicitud, a.ap_apell_paterno as apellido_paterno, a.ap_apell_materno as apell_materno, a.ap_nombre1 as nombre1, a.ap_nombre2 as nombre2, TO_CHAR(f.fecha_nac, "%d/%m/%Y"), a.telefono, "RT", generico1 as Zona from bdinteg:si_solicitud_movil a, bdisolic:ss_solicitudes_movil b, (select distinct ejecutivo, nombre, sucursal, centro_costos, generico1 from si_usuario_movil where activo=1) d, bdinteg:si_cliente e, bdinteg:si_ctepf f where not a.folio is null and not a.numcte is null and a.folio=b.folio_movil and b.num_solicitud = "" and a.numcte=e.numcte and a.numcte=f.numcte and a.ejecutivo=d.ejecutivo and a.fecha_insert between "'||sFecha||'" and "'||sFecha||'"';
	
	-- Solicitudes inconclusas
    --LET cCmd3 = 'select  a.ejecutivo, d.nombre, a.fecha_insert, d.sucursal, " "," ", a.apell_paterno as apell_paterno, a.apell_materno as apell_materno, a.nombre1 as nombre1, a.nombre2 as nombre2, a.fecha_nac,a.telefono, "INCONCLUSO", generico1 as Zona from bdinteg:si_solicitud_movil a, (select distinct ejecutivo, nombre, sucursal, generico1 from si_usuario_movil) d where a.folio is null and a.ejecutivo=d.ejecutivo and a.fecha_insert between "'||sFecha||'" and "'||sFecha||'"';
		
	--LET cCmd4 = TRIM(cCmd1)||" UNION "||TRIM(cCmd2)||" UNION "||TRIM(cCmd3)||" ORDER BY 1;";
	  LET cCmd4 = TRIM(cCmd1)||" UNION "||TRIM(cCmd2)||" ORDER BY 1;";
	
	LET cQuery = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO "||TRIM(pArchDescarga)||"  "||TRIM(cCmd4)||"' | /ifxsif01/bin/dbaccess bdinteg > /dev/null 2>&1";
	--LET cQuery = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO "||TRIM(pArchDescarga)||"  "||TRIM(cCmd4)||"' | /informix/bin/dbaccess bdinteg > /dev/null 2>&1";
	
    SYSTEM TRIM(cQuery);

RETURN cCodRet;
END;
END PROCEDURE;