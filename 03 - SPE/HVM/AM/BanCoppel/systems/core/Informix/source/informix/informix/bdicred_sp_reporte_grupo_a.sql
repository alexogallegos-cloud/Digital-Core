CREATE PROCEDURE "informix".sp_reporte_grupo_a(pempresa CHAR(3), pfechacorte DATE)
RETURNING CHAR(6);
--Creado por: Francisco Martinez Viveros
-- 28/Agosto/2012
-- Modificado por: Francisco Martinez Viveros
-- 27/Noviembre/2012  
-- Ultim.Modificacion de Optimizacion con tablas temporales 
--31/Diciembre/2012
--Proceso para la generación del reporte del grupo6 o grupo A


--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE cCod_retIB			CHAR(6);
DEFINE vproceso				CHAR(30);
DEFINE cruta                CHAR(100);
DEFINE cnombre				CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnomarchivoEjecSql   CHAR(100);
DEFINE cSQL                 CHAR(11104);
DEFINE cSQL_cero            CHAR(4500); --FMV 4ene2013 Se adicionan tablas temporales a la sesion
DEFINE cSQL1                CHAR(2500);
DEFINE cSQL2                CHAR(4004);
DEFINE cSQL3                CHAR(100);
DEFINE cempresa             CHAR(3);
DEFINE cdelimitador         CHAR(1);
DEFINE cFechaGenArchivo     CHAR(8);
DEFINE cFechaCorte          DATE; --CHAR(8);
DEFINE iParamNombreArch     INTEGER;


--SET DEBUG FILE TO "/tmp/sp_reporte_grupo_a.out";
--TRACE ON;

--Inicialización de variables

LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET cCod_Ret                = "000000";
LET cCod_retIB              = "000000";
LET cMensaje                = 'PROCESO EXITOSO';
LET vproceso				= '0018';
LET cruta                   = "";
LET cnombre					= "Grupo_A";
LET cnomarchivo             = "";
LET cnomarchivo1			= "";
LET cnomarchivoEjecSql      = "";
LET cSQL_cero                   = "";
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET cempresa                = "001";
LET cdelimitador            = "";

BEGIN
    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensaje = error_info;
        CALL bdicred:"informix".sp_inserta_bitacora(pempresa, vproceso, cCod_ret, cMensaje, '02')
            Returning cCod_retIB;
        RETURN cCod_ret;
    END EXCEPTION;

	--Directiva para lectura de tablas bloqueadas.
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    CALL bdicred:"informix".sp_inserta_bitacora(pempresa, vproceso, cCod_ret, cMensaje, '01')
    Returning cCod_retIB;

	-- Validacion de parámetros de entrada
    IF NVL(pEmpresa,"") = "" OR NVL(pfechacorte, "") = ""  THEN
        LET cCod_Ret= "104001";
        SELECT descripcion
        INTO cMensaje
        FROM bdicobranza:"informix".cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;

        IF cMensaje IS NULL THEN
            LET cMensaje = "";
        END IF;

        CALL bdicred:"informix".sp_inserta_bitacora(pempresa, vproceso, cCod_ret, cMensaje, '02')
        Returning cCod_retIB;
        Return cCod_Ret;
	END IF;

	--Validación de la empresa
    SELECT empresa
	INTO cempresa
	FROM bdinteg:si_empresas
	WHERE empresa = pempresa;

    IF NVL (cempresa, '') = '' THEN
        LET cCod_Ret= '104002';
        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;

        IF cMensaje IS NULL THEN
            LET cMensaje = "";
        END IF;

        CALL bdicred:"informix".sp_inserta_bitacora(pempresa, vproceso, cCod_ret, cMensaje, '02')
        Returning cCod_retIB;
        Return cCod_Ret;
	END IF;

	--Obtener caracter delimitador
    SELECT trim(valor_alfabetico)
	INTO cdelimitador
	FROM bdicobranza:cb_param_campania
	WHERE empresa = pempresa
	AND tipo_campania = 1
	AND grupo_parametro = 'ARCHIVOS'
	AND num_parametro = 2;

	--Valida que exista el caracter
    IF NVL(cdelimitador,'') = '' THEN
        LET cCod_Ret= '104004';
        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;

        IF cMensaje IS NULL THEN
            LET cMensaje = "";
        END IF;

        CALL bdicred:"informix".sp_inserta_bitacora(pempresa, vproceso, cCod_ret, cMensaje, '02')
        Returning cCod_retIB;
        Return cCod_Ret;
	END IF;

	--Obtener ruta del archivo
    SELECT TRIM(valor)
        INTO cruta
        FROM bdicred:sd_param
        WHERE empresa = pempresa
        AND cod_param = '033';
        
    --Valida que exista la carpeta
	IF NVL (cruta,'') = '' THEN
        LET cCod_Ret= '104005';
        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;

        IF cMensaje IS NULL THEN
            LET cMensaje = "";
        END IF;

        CALL bdicred:"informix".sp_inserta_bitacora(pempresa, vproceso, cCod_ret, cMensaje, '02')
        Returning cCod_retIB;
        Return cCod_Ret;
	END IF;



    LET cFechaGenArchivo =  to_char(pfechacorte,'%d%m%Y');
    LET cFechaCorte = pfechacorte;

	--Validar que existe el archivo	

	LET cnomarchivo1 =  trim(cnombre)||cFechaGenArchivo||'A.txt ';
    LET cnomarchivo =  trim(cnombre)||cFechaGenArchivo||'.txt ';
    LET cnomarchivoEjecSql = 'Exec_GenArchgrupoA' || '.sql';


   --FMV 31dic2012: Creacion de las tablas temporales para optimizacion descarga de datos

                --Tabla 1 de 6  sd_grupo_cliente 
    LET cSQL_cero = ' echo  " SET ISOLATION TO DIRTY READ; '
                 || " SELECT empresa, numcte "
                 || " FROM bdicred:sd_grupo_cliente "                 
                 || " INTO temp CteGpoA WITH NO LOG; "
                 || " CREATE INDEX ix_CteGpoA ON CteGpoA (empresa, numcte); "
                 || " UPDATE STATISTICS MEDIUM FOR TABLE CteGpoA; "

                --Tabla 2 de 6  sd_grupo_credito 
                || " SET ISOLATION TO DIRTY READ; "
                || " SELECT crd.empresa , crd.numcte, crd.num_credito, crd.num_historia_efic "
                || "  FROM bdicred:sd_grupo_credito crd, CteGpoA "
                || " WHERE crd.empresa = CteGpoA.empresa "
                || "   AND crd.numcte = CteGpoA.numcte "
                || "   AND crd.num_producto = '6001' "
                || "   INTO temp CredGpoA WITH NO LOG; "
                || " CREATE INDEX ix_CredGpoA ON CredGpoA (empresa, numcte, num_credito); "
                || " UPDATE STATISTICS MEDIUM FOR TABLE CredGpoA; "

                --Tabla 3 de 6  sd_maecred 
                || " SET ISOLATION TO DIRTY READ; "
                || " SELECT cr.empresa, cr.numcte, cr.num_credito, cr.fecha_apertura, cr.sucursal "
                || "  FROM CredGpoA cte, bdicred:sd_maecred cr "
                || " WHERE cte.empresa = cr.empresa "
                || "   AND cte.numcte = cr.numcte "  
                || "  INTO temp CreditosA WITH NO LOG; "
                || " CREATE INDEX ix_CreditosA ON CreditosA (empresa, num_credito); "
                || " UPDATE STATISTICS MEDIUM FOR TABLE CreditosA; "

                --Tabla 4 de 6   sd_movhis
                || " SET ISOLATION TO DIRTY READ; "
                || " SELECT movh.empresa, movh.num_credito, movh.fecha_mov, movh.codigo_fun, "
                || "       movh.codigo_ref, movh.reversado, movh.monto "
                || "  FROM CreditosA crda, bdicred:sd_movhis movh "
                || " WHERE movh.empresa = crda.empresa "
                || "   AND movh.num_credito = crda.num_credito "
                || "   AND movh.codigo_fun = '001' "
                || "   AND movh.codigo_ref = 1 "
                || "   AND movh.fecha_mov < today "
                || "   AND movh.reversado = 'N' "
                || "  INTO temp movtos_hisA WITH NO LOG; "
                || " CREATE INDEX ix_movtos_hisA ON movtos_hisA (empresa, num_credito); "
                || " UPDATE STATISTICS MEDIUM FOR TABLE movtos_hisA; "

                --Tabla 5 de 6  ss_resum_scor_fin
                || " SET ISOLATION TO DIRTY READ; "
                || " SELECT fin.empresa, fin.evalua_cc, fin.num_solicitud "
                || "  FROM CreditosA cr, bdisolic:ss_resum_scor_fin fin "
                || " WHERE cr.num_credito = fin.num_solicitud "
                || "  INTO temp ResumScor WITH NO LOG; "
                || " CREATE INDEX ix_ResumScor ON ResumScor (num_solicitud); "
                || " UPDATE STATISTICS MEDIUM FOR TABLE ResumScor; "

                --Tabla 5 de 6  sd_bitacora_aumlincred
                || " SET ISOLATION TO DIRTY READ; "
                || " SELECT aum.* "
                || "  FROM CreditosA cr, bdicred:sd_bitacora_aumlincred aum "
                || " WHERE cr.num_credito = aum.num_solicitud "
                || "  INTO temp Aumento WITH NO LOG; "
                || " CREATE INDEX ix_Aumento ON Aumento (num_solicitud); "
                || " UPDATE STATISTICS MEDIUM FOR TABLE Aumento; ";

    LET cSQL1 = ' SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1)||'';
                      
  

        LET cSQL2 = " SELECT a.numcte, b.num_credito, b.fecha_apertura , f.fecha_insert as FofertaIncre , f.fecha_status as FAcepta , "
               || " ema.correo_elec, tca.telefono, tcl.telefono, tra.telefono, tra.extension, "
               || " a.num_historia_efic as meses_vigentes, b.sucursal, mov.monto as monto_otorgado, "
               || " f.lincred_actual, f.lincred_sugerida, h.evalua_cc "
               || " FROM   CredGpoA a, movtos_hisA mov, "
               || "        ResumScor h , "               
               || "        CreditosA b "
               || " LEFT JOIN bdinteg:si_telefonos tca on (b.numcte = tca.numcte AND tca.tipo_tel = 1 AND tca.status_tel ='A' AND tca.cofetel='V' ) "
               || " LEFT JOIN bdinteg:si_telefonos tcl on (b.numcte = tcl.numcte AND tcl.tipo_tel = 2 AND tcl.status_tel ='A' AND tca.cofetel='V' ) "
               || " LEFT JOIN bdinteg:si_telefonos tra on (b.numcte = tra.numcte AND tra.tipo_tel = 3 AND tra.status_tel ='A' AND tca.cofetel='V' ) "
               || " LEFT JOIN Aumento f on (b.num_credito = f.num_solicitud ) "
               || " LEFT JOIN bdinteg:si_correos ema on ( ema.numcte = b.numcte ) "
               || " WHERE a.empresa = '001' "
               || " AND a.empresa = b.empresa "
               || " AND a.numcte = b.numcte "
               || " AND a.num_credito = b.num_credito "
               || " AND a.num_credito = h.num_solicitud "           
               || " AND a.empresa = mov.empresa "
               || " AND a.num_credito = mov.num_credito "

               || "  union all "

               || " SELECT a.numcte, b.num_credito, b.fecha_apertura , date(1) as FofertaIncre , date(1) as FAcepta , "
               || " ema.correo_elec, tca.telefono, tcl.telefono, tra.telefono, tra.extension, "
               || " a.num_historia_efic as meses_vigentes, b.sucursal, sdo.monto_otorgado,  "
               || " 0 AS lincred_actual, 0 AS lincred_sugerida, h.evalua_cc "
               || " FROM bdicred:sd_grupo_credito a, bdicred:sd_maesdoscrd sdo, bdisolic:ss_resum_scor_fin h , bdicred:sd_maecredcrd b "
               || " LEFT JOIN bdinteg:si_telefonos tca on (b.numcte = tca.numcte AND tca.tipo_tel = 1 AND tca.status_tel ='A' AND tca.cofetel='V' ) "
               || " LEFT JOIN bdinteg:si_telefonos tcl on (b.numcte = tcl.numcte AND tcl.tipo_tel = 2 AND tcl.status_tel ='A' AND tca.cofetel='V' ) "
               || " LEFT JOIN bdinteg:si_telefonos tra on (b.numcte = tra.numcte AND tra.tipo_tel = 3 AND tra.status_tel ='A' AND tca.cofetel='V' ) "               
               || " LEFT JOIN bdinteg:si_correos ema on ( ema.numcte = b.numcte ) "
               || " WHERE a.empresa = '001' "
               || " AND a.empresa = b.empresa "
               || " AND a.numcte = b.numcte "               
               || " AND a.num_credito = b.num_credito "               
               || " AND a.num_credito = h.num_solicitud "
               || " AND a.empresa = sdo.empresa "
               || " AND a.num_credito = sdo.num_credito; ";



    LET cSQL3 = '" >'||TRIM(cRuta)|| cnomarchivoEjecSql;
    LET cSQL = cSQL_cero || trim(cSQL1) || (cSQL2) || trim(cSQL3);
    System cSQL;

    LET cSQL='chmod 777 '|| TRIM(cRuta)|| cnomarchivoEjecSql;
    System cSQL;

    let cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || cnomarchivoEjecSql;
    System cSQL;

	--Borra el archivo de control.
	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivoEjecSql;
	SYSTEM cSQL;

	CALL bdicred:"informix".sp_inserta_bitacora(pempresa, vproceso, cCod_ret, cMensaje, '03')
            Returning cCod_retIB;
	
    RETURN cCod_ret;

END;
END PROCEDURE;