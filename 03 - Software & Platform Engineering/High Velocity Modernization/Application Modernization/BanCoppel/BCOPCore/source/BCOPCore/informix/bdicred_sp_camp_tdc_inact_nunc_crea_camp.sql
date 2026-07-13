CREATE PROCEDURE "informix".sp_camp_tdc_inact_nunc_crea_camp(pEmpresa CHAR(3), pTipo_camp CHAR(3), pSubcamp CHAR(2), pDuracion SMALLINT, pdFechaHoy DATE, pdFecha6meses DATE)


RETURNING CHAR(6);

-- Creado: MAHR. Julio 2013.- Creacion de campaña de Tarjetas Inactivas y Nuncas.
-- Servicio 1 -> Campaña: 1 Llamada de seguimiento              Servicio 4 -> Campaña: 4 Promociones temporada 4
-- Servicio 2 -> Campaña: 2 Credisoluciones                     Servicio 5 -> Campaña: 5 Promociones temporada 5
-- Servicio 3 -> Campaña: 3 Promociones temporada 3             Servicio 6 -> Campaña: 6 Pre-cancelacion


--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE cCod_RetIB           CHAR(6);
DEFINE cMensaje				CHAR(80);
DEFINE vproceso				CHAR(4);
DEFINE cempresa             CHAR(3);
DEFINE sNumCamp             SMALLINT;
DEFINE iMontoMinGpoA        INTEGER;
DEFINE iMontoMinGpoB        INTEGER;
DEFINE iMontoMaxGpoB        INTEGER;
DEFINE iRegsMaxGpoA         INTEGER;
DEFINE iRegsMaxGpoB         INTEGER;
DEFINE iNumLogica           SMALLINT;
DEFINE dfecha_gen_camp      DATE;
DEFINE dfecha_ejec_camp_ant DATE;
DEFINE dfecha_ejec_camp     DATE;
DEFINE dfecha_desde         DATE;
DEFINE dfecha_hasta         DATE;
DEFINE dfecha_a             DATE;
DEFINE dfecha_b             DATE;
DEFINE dFechaFinNunca       DATE;
DEFINE sCont_prioridad      INTEGER;
DEFINE cNumCredito          CHAR(20);
DEFINE cNumCte              CHAR(20);
DEFINE cNumTel              CHAR(13);
DEFINE itot_tarj_entreg     INTEGER;
DEFINE itot_tarj_act        INTEGER;
DEFINE itot_tarj_inact      INTEGER;

--SET DEBUG FILE TO "/informix/sp_camp_tdc_inact_nunc_crea_camp.out";
--TRACE ON;

--Inicialización de variables
LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET cCod_Ret                = '000000';
LET cCod_RetIB              = '';
LET cMensaje                = 'PROCESO EXITOSO';
LET vproceso				= '0505';
LET cempresa                = "";
LET iMontoMinGpoA           = 0;
LET iMontoMinGpoB           = 0;
LET iMontoMaxGpoB           = 0;
LET iRegsMaxGpoA            = 0;
LET iRegsMaxGpoB            = 0;
LET iNumLogica              = 0;
LET sCont_prioridad         = 0;
LET cNumCredito             = '';
LET cNumCte                 = '';
LET cNumTel                 = '';
LET itot_tarj_entreg        = 0;
LET itot_tarj_act           = 0;
LET itot_tarj_inact         = 0;
 
--SET ISOLATION TO COMMITTED READ LAST COMMITTED;

BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensaje = error_info;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCod_ret, trim(cMensaje)||'-'|| isam_err::CHAR ||'-'|| pTipo_camp, '02') Returning cCod_RetIB;    
        RETURN cCod_ret;
	END EXCEPTION;

	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCod_ret, 'INICIA CAMPAÑA-'||pTipo_camp||'-'||pSubcamp, '02') Returning cCod_RetIB;

	-- Validacion de parámetros de entrada
	IF (NVL(pEmpresa,"") = "" OR NVL(ptipo_camp, '') = '' OR NVL(psubcamp, "") = "" OR pDuracion = 0 OR pdFechaHoy = date(1) ) THEN
        LET cCod_Ret= '104001'; 
        SELECT descripcion INTO cMensaje
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCod_ret, trim(cMensaje)||'-'||pTipo_camp||'-'||pSubcamp, '02') Returning cCod_RetIB;
        Return cCod_Ret;
	END IF;

	--Validación de la empresa
	SELECT empresa INTO cempresa FROM bdinteg:si_empresas WHERE empresa = pEmpresa;
	IF NVL (cempresa, '') = '' THEN
        LET cCod_Ret = '104002';
        SELECT descripcion INTO cMensaje FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCod_ret, trim(cMensaje)||'-'||pTipo_camp||'-'||pSubcamp, '02') Returning cCod_RetIB;
        Return cCod_Ret;
	END IF;

    --Valida si existen las tablas temporales y las borra.
    IF EXISTS( SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'tmp_indicador_camp') THEN DROP TABLE tmp_indicador_camp; END IF;
    IF EXISTS( SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'temp_campania_a')  THEN DROP TABLE temp_campania_a; END IF;
    IF EXISTS( SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'temp_campania_b')  THEN DROP TABLE temp_campania_b; END IF;

    -- Obtiene parámetros segun el Tipo de Campaña
    IF pTipo_camp = 'INA' THEN -- Montos minimos y maximos y registros limites de Grupo A y B de TDC Inactivas

        LET iNumLogica = 11;
        SELECT NVL(valor_numerico,0) INTO iRegsMaxGpoA FROM bdicred:"informix".sd_param_campania WHERE empresa = pEmpresa 
            AND tipo_campania = 3 AND grupo_parametro = 'CAMPINCNUN' AND num_parametro = 15;

        SELECT NVL(valor_numerico,0) INTO iRegsMaxGpoB FROM bdicred:"informix".sd_param_campania WHERE empresa = pEmpresa 
            AND tipo_campania = 3 AND grupo_parametro = 'CAMPINCNUN' AND num_parametro = 16;

        SELECT NVL(valor_numerico,0) INTO iMontoMinGpoA FROM bdicred:"informix".sd_param_campania WHERE empresa = pEmpresa 
            AND tipo_campania = 3 AND grupo_parametro = 'CAMPINCNUN' AND num_parametro = 17;

        SELECT NVL(valor_alfabetico::INTEGER,0), NVL(valor_numerico,0) INTO iMontoMinGpoB, iMontoMaxGpoB FROM bdicred:"informix".sd_param_campania 
            WHERE empresa = pEmpresa AND tipo_campania = 3 AND grupo_parametro = 'CAMPINCNUN' AND num_parametro = 18;


    ELSE    -- Montos minimos y maximos y registros limites de Grupo A y B de TDC Nuncas

        LET iNumLogica = 12;
        SELECT NVL(valor_numerico,0) INTO iRegsMaxGpoA FROM bdicred:"informix".sd_param_campania WHERE empresa = pEmpresa 
            AND tipo_campania = 3 AND grupo_parametro = 'CAMPINCNUN' AND num_parametro = 19;

        SELECT NVL(valor_numerico,0) INTO iRegsMaxGpoB FROM bdicred:"informix".sd_param_campania WHERE empresa = pEmpresa 
            AND tipo_campania = 3 AND grupo_parametro = 'CAMPINCNUN' AND num_parametro = 20;

        SELECT NVL(valor_numerico,0) INTO iMontoMinGpoA FROM bdicred:"informix".sd_param_campania WHERE empresa = pEmpresa 
            AND tipo_campania = 3 AND grupo_parametro = 'CAMPINCNUN' AND num_parametro = 21;

        SELECT NVL(valor_alfabetico::INTEGER,0), NVL(valor_numerico,0) INTO iMontoMinGpoB, iMontoMaxGpoB FROM bdicred:"informix".sd_param_campania 
            WHERE empresa = pEmpresa AND tipo_campania = 3 AND grupo_parametro = 'CAMPINCNUN' AND num_parametro = 22;

    END IF;


    IF ( iMontoMinGpoA = 0 OR iMontoMinGpoB = 0 OR iMontoMaxGpoB = 0 OR iRegsMaxGpoA = 0 OR iRegsMaxGpoB = 0 ) THEN
        LET cCod_ret = '000001';
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCod_ret, 'SIN PARAMETROS BASICOS DE CAMPAÑA'||'-'||pTipo_camp||'-'||pSubcamp, '02') Returning cCod_RetIB;
        RETURN cCod_Ret;
    END IF

    LET sNumCamp = pSubcamp::SMALLINT;

    -- Obtiene fecha limite superior de los creditos entregados. Las campañas solo trabajaran creditos generados de 2007 a 2012.
    SELECT NVL(valor_alfabetico, date(1)) INTO dFechaFinNunca FROM bdicred:"informix".sd_param_campania WHERE empresa = pEmpresa 
       AND tipo_campania = 3 AND grupo_parametro = 'CAMPINCNUN' AND num_parametro = 31;
    IF dFechaFinNunca = date(1) THEN LET dFechaFinNunca = '08-30-2012'; END IF;

    -- Obtiene fechas de la campaña cosecha (fecha campaña, fecha ejecucion, desde , hasta)
    IF sNumCamp > 1 THEN
        LET dfecha_ejec_camp_ant = pdFechaHoy - pDuracion units month; -- Fecha de campaña de la campaña anterior ejecutada en el mes calculado
        SELECT first 1 fecha_ejecucion, fecha_gen_campania, fecha_entreg_desde, fecha_entreg_hasta 
                INTO dfecha_ejec_camp, dfecha_gen_camp, dfecha_desde, dfecha_hasta
                FROM bdicred:"informix".sd_camp_inactiv_nuncas WHERE month(fecha_ejecucion) = month(dfecha_ejec_camp_ant)
                AND year(fecha_ejecucion) = year(dfecha_ejec_camp_ant) AND tipo_campania = pTipo_camp AND num_sub_campania = (sNumCamp - 1);
        IF dfecha_gen_camp IS NULL THEN
            CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCod_ret, 'SIN CAMPAÑA'||'-'||pTipo_camp||'-'||pSubcamp, '02') Returning cCod_RetIB;
            LET cCod_Ret = '000001';        --  Termina proceso, ya que no existe campaña generada para esta fecha.
            RETURN cCod_Ret;
        END IF;

        IF ( Select count(*) from bdicred:"informix".sd_camp_inactiv_nuncas where fecha_gen_campania = dfecha_gen_camp and tipo_campania = pTipo_camp 
                and num_sub_campania = sNumCamp and fecha_entreg_desde = dfecha_desde and fecha_entreg_hasta = dfecha_hasta ) > 0 THEN

            CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCod_ret, 'CAMPAÑA EXISTENTE'||'-'||pTipo_camp||'-'||pSubcamp, '02') Returning cCod_RetIB;
            LET cCod_Ret = '000001';        --  Termina proceso, ya que no existe campaña generada para esta fecha.
            RETURN cCod_Ret;
        END IF;
    END IF;

    -- Cierra campaña No 6, y asigna numeros de cierre a la campaña
    IF sNumCamp = 7 THEN

        IF pTipo_camp = 'INA' THEN   -- Campaña Inactivas

            SELECT count(inac.num_credito) INTO itot_tarj_inact
              FROM bdicred:sd_camp_inactiv_nuncas inac JOIN bdicred:sd_indicador_cred ind ON (ind.empresa = pEmpresa and ind.num_credito = inac.num_credito
                            and ind.fecha_ultima_compra = inac.fecha_ultima_compra and ind.fecha_ultimo_pago = inac.fecha_ultimo_pago and ind.f_primer_compra != date(1))
              JOIN bdicred:sd_maecred cred ON (cred.empresa = pEmpresa and cred.num_credito = inac.num_credito and cred.status_cred IN ('AA','E1'))
			  JOIN bdicred:sd_maesdos maes ON (maes.empresa = pEmpresa and maes.num_credito = inac.num_credito AND (maes.monto_vencido + maes.mto_venc_trasp) = 0)
             WHERE inac.fecha_gen_campania = dfecha_gen_camp AND inac.tipo_campania = pTipo_camp AND inac.num_sub_campania = (sNumCamp - 1)
               AND inac.fecha_ejecucion = dfecha_ejec_camp AND inac.fecha_entreg_desde = dfecha_desde AND inac.fecha_entreg_hasta = dfecha_hasta  
               AND inac.status_cte = 'INACT';

        ELSE -- Campaña Nunca

            SELECT count(inac.num_credito) INTO itot_tarj_inact
              FROM bdicred:sd_camp_inactiv_nuncas inac JOIN bdicred:sd_indicador_cred ind ON ( ind.empresa = pEmpresa and ind.num_credito = inac.num_credito )
              JOIN bdicred:sd_maecred cred ON (cred.empresa = pEmpresa and cred.num_credito = inac.num_credito and cred.status_cred IN ('AA','E1'))
			  JOIN bdicred:sd_maesdos maes ON (maes.empresa = pEmpresa and maes.num_credito = inac.num_credito AND (maes.monto_vencido + maes.mto_venc_trasp) = 0)
            WHERE inac.fecha_gen_campania = dfecha_gen_camp AND inac.tipo_campania = pTipo_camp AND inac.num_sub_campania = (sNumCamp - 1)
              AND inac.fecha_ejecucion = dfecha_ejec_camp AND inac.fecha_entreg_desde = dfecha_desde 
              AND inac.fecha_entreg_hasta = dfecha_hasta 
              AND nvl(ind.f_primer_compra, date(1)) = date(1) AND nvl(ind.f_primer_disp, date(1)) = date(1) 
              AND inac.status_cte = 'INACT';

        END IF;

        -- Se actualizan datos de la campaña anterior. Las inactivas restantes de la campaña anterior = Las entregadas de esta campaña
        UPDATE bdicred:sd_camp_inactiv_nuncas_reporte SET tot_tarj_inactivas = itot_tarj_inact, tot_tarj_activas = (tot_tarj_entregadas - itot_tarj_inact), 
            porcentaje_efec = (((tot_tarj_entregadas - itot_tarj_inact) / tot_tarj_entregadas) * 100) -- itot_tarj_inact = inactivas de camp anterior
            WHERE fecha_gen_campania = dfecha_gen_camp AND tipo_campania =  pTipo_camp AND num_sub_campania = (sNumCamp - 1)
              AND fecha_entreg_desde = dfecha_desde AND fecha_entreg_hasta = dfecha_hasta; 

        RETURN cCod_Ret;
    END IF;

    -- Crea tabla temporal.
    /*CREATE temp TABLE temp_inactivas_nuncas (
        tipcamp     CHAR(3),    logica      SMALLINT,   subcamp             SMALLINT,       grupo               CHAR(1),
        num_credito CHAR(20),   numcte      CHAR(20),   monto_otorgado      DECIMAL(18,2),  fecha_apertura      DATE,   
        prioridad   SMALLINT,   statcte     CHAR(5),    apell_paterno       CHAR(26),       apell_materno       CHAR(26),
        nombre1     CHAR(26),   nombre2     CHAR(26),   sexo                CHAR(1),        estado_civil        CHAR(2),
        email       CHAR(50),   estado      CHAR(30),   ciudad              CHAR(30),       fecha_ultima_compra DATE,           
        fecha_ultimo_pago   DATE ); */


    -- Crea subcampaña 1 de campaña de Tarjetas Inactivas
    IF (sNumCamp = 1 AND pTipo_camp = 'INA') THEN

        -- Obtiene tablas temporales.   

        -- Tabla: sd_indicardor_cred, todos los creditos inactivos: 
        --SELECT * FROM bdicred:sd_indicador_cred
        SELECT empresa, num_credito, fecha_ultima_compra, fecha_ultimo_pago, f_primer_compra, fecha_alta FROM bdicred:sd_indicador_cred
         WHERE empresa = pEmpresa AND fecha_ultima_compra <= pdFecha6meses AND fecha_ultimo_pago <= pdFecha6meses
           AND f_primer_compra != date(1) AND fecha_alta <= dFechaFinNunca
        INTO temp tmp_indicador_camp WITH NO LOG;
        create index ix2_indicador on tmp_indicador_camp ( num_credito );

        -- Elimina los creditos ya incluidos en campañas-cosechas previas
        DELETE FROM tmp_indicador_camp WHERE num_credito IN ( Select num_credito from bdicred:sd_camp_inactiv_nuncas Where tipo_campania = 'INA' and num_sub_campania = 1 );
        UPDATE STATISTICS medium FOR TABLE tmp_indicador_camp;

        -- Obtiene registros de para campaña 1 Inactivas del grupo A
        --INSERT INTO temp_inactivas_nuncas 
        SELECT limit iRegsMaxGpoA 'INA' tipcamp, iNumLogica logica, 1 subcamp, 'A' grupo, ind.num_credito, cred.numcte, dos.monto_otorgado, 
            cred.fecha_apertura, 0 prioridad, 'INACT' statcte, cte.apell_paterno, cte.apell_materno, cte.nombre1, cte.nombre2, pf.sexo, pf.estado_civil, 
            trim(co.correo_elec) email, edos.nombre estado, rpad(TRIM(cd.nombreciudad),25,' ') as ciudad, ind.fecha_ultima_compra, 
            ind.fecha_ultimo_pago
            FROM bdicred:sd_maecred cred JOIN tmp_indicador_camp ind ON (cred.empresa = ind.empresa and cred.num_credito = ind.num_credito
                                                                                and cred.status_cred IN ('AA','E1'))
            JOIN bdicred:sd_maesdos dos ON ( cred.empresa = dos.empresa and cred.num_credito = dos.num_credito and dos.sdo_cap_insoluto <= 0 )
																									
																																								   
            JOIN bdinteg:si_cliente cte ON ( cred.empresa = cte.empresa and cred.numcte = cte.numcte )
            JOIN bdinteg:si_ctepf pf ON ( cred.empresa = pf.empresa and cred.numcte = pf.numcte )
            JOIN bdinteg:si_direcciones_actual dir ON (cred.numcte = dir.numcte and dir.tipo_dir = '1')
            JOIN bdinteg:si_estados edos ON (dir.pais = edos.pais and dir.estado = edos.estado)
            JOIN bdinteg:si_catciudades cd ON (dir.numerociudad = cd.numerociudad )
            LEFT OUTER JOIN bdinteg:si_correos co ON (cred.empresa = co.empresa and cred.numcte = co.numcte
                    AND co.secuencia = (select max(secuencia) from bdinteg:si_correos where empresa = cred.empresa and numcte = cred.numcte))
            WHERE dos.monto_otorgado >=  iMontoMinGpoA -- >=  5001
            ORDER BY ind.fecha_ultima_compra DESC  -- tomar en cada camp 1 de las mas recientes a las mas viejas
            INTO temp temp_campania_a with no log;

        -- Obtiene registros del grupo B, para campaña de INACTIVAS
        --INSERT INTO temp_inactivas_nuncas 
        SELECT limit iRegsMaxGpoB 'INA' tipcamp, iNumLogica logica, 1 subcamp, 'B' grupo, ind2.num_credito, cred.numcte, dos.monto_otorgado, 
            cred.fecha_apertura, 0 prioridad, 'INACT' statcte, cte.apell_paterno, cte.apell_materno, cte.nombre1, cte.nombre2, pf.sexo, pf.estado_civil, 
            trim(co.correo_elec) email, edos.nombre estado, rpad(TRIM(cd.nombreciudad),25,' ') as ciudad, ind2.fecha_ultima_compra, ind2.fecha_ultimo_pago
            FROM bdicred:sd_maecred cred JOIN tmp_indicador_camp ind2 ON (cred.empresa = ind2.empresa and cred.num_credito = ind2.num_credito 
                                                                                and cred.status_cred IN ('AA','E1'))
            JOIN bdicred:sd_maesdos dos ON (cred.empresa = dos.empresa and cred.num_credito = dos.num_credito and dos.sdo_cap_insoluto <= 0 )
																										
																																								  
            JOIN bdinteg:si_cliente cte ON ( cred.empresa = cte.empresa and cred.numcte = cte.numcte)
            JOIN bdinteg:si_ctepf pf ON ( cred.empresa = pf.empresa and cred.numcte = pf.numcte)
            JOIN bdinteg:si_direcciones_actual dir ON (cred.numcte = dir.numcte and dir.tipo_dir = '1')
            JOIN bdinteg:si_estados edos ON (dir.pais = edos.pais and  dir.estado = edos.estado)
            JOIN bdinteg:si_catciudades cd ON (dir.numerociudad = cd.numerociudad)
            LEFT OUTER JOIN bdinteg:si_correos co ON (cred.empresa = co.empresa and  cred.numcte = co.numcte
                AND co.secuencia = (select max(secuencia) from  bdinteg:si_correos where empresa = cred.empresa and numcte = cred.numcte)) 
            WHERE dos.monto_otorgado >= iMontoMinGpoB AND dos.monto_otorgado <= iMontoMaxGpoB -- between 2001 y 5000
            ORDER BY ind2.fecha_ultima_compra DESC  -- tomar en cada camp 1 de las mas recientes a las mas viejas
            INTO temp temp_campania_b WITH NO LOG;



        -- Obtiene fechas limite maxima y minima de ambos grupos.
        SELECT max(fecha_ultima_compra) INTO dfecha_a FROM temp_campania_a; 
        SELECT max(fecha_ultima_compra) INTO dfecha_b FROM temp_campania_b; 
        IF dfecha_a >= dfecha_b THEN LET dfecha_hasta = dfecha_a; ELSE LET dfecha_hasta = dfecha_b; END IF;
        IF dfecha_hasta IS NULL THEN -- En caso de que solo exista una sola fecha, no asigne nulo.
            IF dfecha_a IS NOT NULL THEN LET dfecha_hasta = dfecha_a; ELSE LET dfecha_hasta = dfecha_b; END IF
        END IF;    

        SELECT min(fecha_ultima_compra) INTO dfecha_a FROM temp_campania_a; 
        SELECT min(fecha_ultima_compra) INTO dfecha_b FROM temp_campania_b; 
        IF dfecha_a <= dfecha_b THEN LET dfecha_desde = dfecha_a; ELSE LET dfecha_desde = dfecha_b; END IF;
        IF dfecha_desde IS NULL THEN -- En caso de que solo exista una sola fecha, no asigne nulo.
            IF dfecha_a IS NOT NULL THEN LET dfecha_desde = dfecha_a; ELSE LET dfecha_desde = dfecha_b; END IF
        END IF;

        LET dfecha_gen_camp = pdFechaHoy; LET dfecha_ejec_camp = pdFechaHoy;


        INSERT INTO bdicred:sd_camp_inactiv_nuncas
            SELECT pEmpresa, dfecha_gen_camp, dfecha_ejec_camp, dfecha_desde, dfecha_hasta, tipcamp, logica, subcamp, grupo, num_credito, numcte, 
            monto_otorgado, fecha_apertura, prioridad, statcte, apell_paterno, apell_materno, nombre1, nombre2, sexo, estado_civil, email, estado, 
            ciudad, fecha_ultima_compra, fecha_ultimo_pago FROM temp_campania_a;

        INSERT INTO bdicred:sd_camp_inactiv_nuncas
            SELECT pEmpresa, dfecha_gen_camp, dfecha_ejec_camp, dfecha_desde, dfecha_hasta, tipcamp, logica, subcamp, grupo, num_credito, numcte, 
            monto_otorgado, fecha_apertura, prioridad, statcte, apell_paterno, apell_materno, nombre1, nombre2, sexo, estado_civil, email, estado, 
            ciudad, fecha_ultima_compra, fecha_ultimo_pago FROM temp_campania_b;


        -- Valida que se hayan obtenido registros para la campaña
        IF dfecha_desde IS NULL AND dfecha_hasta IS NULL THEN
            CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCod_ret, 'SIN DATOS EN CAMPAÑA'||'-'||pTipo_camp||'-'||pSubcamp, '02') Returning cCod_RetIB;
            LET cCod_Ret = '000001';        --  Termina proceso, ya que no existen datos para generar la campaña.
            RETURN cCod_Ret;
        END IF;

    ELIF (sNumCamp = 1 AND pTipo_camp = 'NUN') THEN     -- Obtiene subcampaña 1 de Campaña NUNCAS


         -- Obtiene todos los creditos nunca utilizados
        --SELECT * FROM bdicred:sd_indicador_cred 
        SELECT empresa, num_credito, f_primer_compra, f_primer_disp, fecha_alta FROM bdicred:sd_indicador_cred 
            WHERE empresa = pEmpresa AND nvl(f_primer_compra, date(1)) = date(1) AND nvl(f_primer_disp, date(1)) = date(1) AND fecha_alta <= dFechaFinNunca
        INTO temp tmp_indicador_camp WITH NO LOG;
        create index ix1_ind_nun on tmp_indicador_camp ( num_credito);
        
        -- Elimina los creditos ya incluidos en campañas-cosechas previas
        DELETE FROM tmp_indicador_camp WHERE num_credito IN ( Select num_credito from bdicred:sd_camp_inactiv_nuncas Where tipo_campania = 'NUN' and num_sub_campania = 1);
        UPDATE STATISTICS medium FOR TABLE tmp_indicador_camp;

        -- Inserta registros de campaña -- Obtiene registros para campaña 1 NUNCAS del grupo A
        --INSERT INTO temp_inactivas_nuncas 
        SELECT limit iRegsMaxGpoA  'NUN' tipcamp, iNumLogica logica, 1 subcamp, 'A' grupo, ind.num_credito, cred.numcte, dos.monto_otorgado, 
            cred.fecha_apertura, 0 prioridad, 'INACT' statcte, cte.apell_paterno, cte.apell_materno, cte.nombre1, cte.nombre2, pf.sexo, pf.estado_civil,
            trim(co.correo_elec) email, edos.nombre estado, rpad(TRIM(cd.nombreciudad),25,' ') as ciudad, date(1) fecha_ultima_compra, date(1) fecha_ultimo_pago
            FROM bdicred:sd_maecred cred JOIN tmp_indicador_camp ind ON (cred.empresa = ind.empresa AND cred.num_credito = ind.num_credito
                                                                                AND cred.status_cred IN ('AA','E1') )
            JOIN bdicred:sd_maesdos dos ON ( cred.empresa = dos.empresa AND cred.num_credito = dos.num_credito AND (dos.monto_vencido + dos.mto_venc_trasp) = 0)
																									
																																								   
            JOIN bdinteg:si_cliente cte ON ( cred.empresa = cte.empresa AND cred.numcte = cte.numcte)
            JOIN bdinteg:si_ctepf pf ON ( cred.empresa = pf.empresa and cred.numcte = pf.numcte )
            JOIN bdinteg:si_direcciones_actual dir ON ( cred.numcte = dir.numcte AND dir.tipo_dir = '1')
            JOIN bdinteg:si_estados edos on (dir.pais = edos.pais and dir.estado = edos.estado)
            JOIN bdinteg:si_catciudades cd ON (dir.numerociudad = cd.numerociudad)
            LEFT OUTER JOIN bdinteg:si_correos co on (cred.numcte = co.numcte and co.secuencia = (select max(secuencia) from bdinteg:si_correos 
                                                      where empresa = cred.empresa and numcte = cred.numcte))
            WHERE dos.monto_otorgado >= iMontoMinGpoA  -- >=  5001 
            ORDER BY cred.fecha_apertura DESC  -- tomar en cada camp 1 de las mas recientes a las mas viejas
            INTO temp temp_campania_a with no log;


        -- Obtiene registros para campaña 1 NUNCAS del grupo B
        --INSERT INTO temp_inactivas_nuncas 
        SELECT limit iRegsMaxGpoB  'NUN' tipcamp, iNumLogica logica, 1 subcamp, 'B' grupo, ind2.num_credito, cred.numcte, dos.monto_otorgado, 
            cred.fecha_apertura, 0 prioridad, 'INACT' statcte, cte.apell_paterno, cte.apell_materno, cte.nombre1, cte.nombre2, pf.sexo, pf.estado_civil, 
            trim(co.correo_elec) email, edos.nombre estado, rpad(TRIM(cd.nombreciudad),25,' ') as ciudad, date(1) fecha_ultima_compra, date(1) fecha_ultimo_pago
            FROM bdicred:sd_maecred cred JOIN tmp_indicador_camp ind2 ON (cred.empresa = ind2.empresa AND cred.num_credito = ind2.num_credito
                                                                                AND cred.status_cred IN ('AA','E1') ) 
            JOIN bdicred:sd_maesdos dos ON ( cred.empresa = dos.empresa AND cred.num_credito = dos.num_credito AND (dos.monto_vencido + dos.mto_venc_trasp) = 0)
																									   
																																								   
            JOIN bdinteg:si_cliente cte ON ( cred.empresa = cte.empresa AND cred.numcte = cte.numcte)
            JOIN bdinteg:si_ctepf pf ON ( cred.empresa = pf.empresa and cred.numcte = pf.numcte )
            JOIN bdinteg:si_direcciones_actual dir ON (cred.numcte = dir.numcte AND dir.tipo_dir = '1')
            JOIN bdinteg:si_estados edos on (dir.pais = edos.pais and dir.estado = edos.estado)
            JOIN bdinteg:si_catciudades cd ON (dir.numerociudad = cd.numerociudad)
            LEFT OUTER JOIN bdinteg:si_correos co on (cred.numcte = co.numcte and co.secuencia = (select max(secuencia) from bdinteg:si_correos 
                                                      where empresa = cred.empresa and numcte = cred.numcte))
            WHERE dos.monto_otorgado >= iMontoMinGpoB AND dos.monto_otorgado <= iMontoMaxGpoB -- between 2001 y 5000 ;
            ORDER BY cred.fecha_apertura DESC  -- tomar en cada camp 1 de las mas recientes a las mas viejas
            INTO temp temp_campania_b with no log;


        SELECT max(fecha_apertura) INTO dfecha_a FROM temp_campania_a; 
        SELECT max(fecha_apertura) INTO dfecha_b FROM temp_campania_b; 
        IF dfecha_a >= dfecha_b THEN LET dfecha_hasta = dfecha_a; ELSE LET dfecha_hasta = dfecha_b; END IF;
        IF dfecha_hasta IS NULL THEN -- En caso de que solo exista una sola fecha, no asigne nulo.
            IF dfecha_a IS NOT NULL THEN LET dfecha_hasta = dfecha_a; ELSE LET dfecha_hasta = dfecha_b; END IF
        END IF;

        SELECT min(fecha_apertura) INTO dfecha_a FROM temp_campania_a; 
        SELECT min(fecha_apertura) INTO dfecha_b FROM temp_campania_b; 
        IF dfecha_a <= dfecha_b THEN LET dfecha_desde = dfecha_a; ELSE LET dfecha_desde = dfecha_b; END IF;
        IF dfecha_desde IS NULL THEN -- En caso de que solo exista una sola fecha, no asigne nulo.
            IF dfecha_a IS NOT NULL THEN LET dfecha_desde = dfecha_a; ELSE LET dfecha_desde = dfecha_b; END IF
        END IF;


        LET dfecha_gen_camp = pdFechaHoy;   LET dfecha_ejec_camp = pdFechaHoy;


        INSERT INTO bdicred:sd_camp_inactiv_nuncas
            SELECT pEmpresa, dfecha_gen_camp, dfecha_ejec_camp, dfecha_desde, dfecha_hasta, tipcamp, logica, subcamp, grupo, num_credito, numcte, 
            monto_otorgado, fecha_apertura, prioridad, statcte, apell_paterno, apell_materno, nombre1, nombre2, sexo, estado_civil, email, 
            estado, ciudad, date(1), date(1) FROM temp_campania_a;

        INSERT INTO bdicred:sd_camp_inactiv_nuncas
            SELECT pEmpresa, dfecha_gen_camp, dfecha_ejec_camp, dfecha_desde, dfecha_hasta, tipcamp, logica, subcamp, grupo, num_credito, numcte, 
            monto_otorgado, fecha_apertura, prioridad, statcte, apell_paterno, apell_materno, nombre1, nombre2, sexo, estado_civil, email, 
            estado, ciudad, date(1), date(1) FROM temp_campania_b;


        -- Valida que se hayan obtenido registros para la campaña
        IF dfecha_desde IS NULL AND dfecha_hasta IS NULL THEN
            CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCod_ret, 'SIN DATOS EN CAMPAÑA'||'-'||pTipo_camp||'-'||pSubcamp, '02') Returning cCod_RetIB;
            LET cCod_Ret = '000001';        --  Termina proceso, ya que no existen datos para generar la campaña.
            RETURN cCod_Ret;
        END IF;


    ELIF ( pTipo_camp = 'INA' ) THEN    -- Obtiene subcampañas 2 en adelante, de Campaña INACTIVAS

        -- Obtiene los registros de las campañas 2 en adelante de los creditos que aun sigan inactivas a la fecha. (INACTIVAS)
        --INSERT INTO temp_inactivas_nuncas
        INSERT INTO bdicred:sd_camp_inactiv_nuncas
            SELECT pEmpresa, dfecha_gen_camp, pdFechaHoy, dfecha_desde, dfecha_hasta, inac.tipo_campania, inac.tipo_logica, sNumCamp, inac.grupo, 
                inac.num_credito, inac.numcte, inac.monto_otorgado, inac.fecha_apertura, 0, inac.status_cte, inac.ap_paterno, inac.ap_materno, 
                inac.primer_nombre, inac.segundo_nombre, inac.sexo, inac.estado_civil, inac.email, inac.estado, inac.ciudad, 
                inac.fecha_ultima_compra, inac.fecha_ultimo_pago
              FROM bdicred:sd_camp_inactiv_nuncas inac JOIN bdicred:sd_indicador_cred ind ON ( ind.empresa = inac.empresa and ind.num_credito = inac.num_credito 
                        and ind.fecha_ultima_compra = inac.fecha_ultima_compra and ind.fecha_ultimo_pago = inac.fecha_ultimo_pago and ind.f_primer_compra != date(1))
              JOIN bdicred:sd_maecred cred ON ( cred.empresa = inac.empresa and cred.num_credito = inac.num_credito and cred.status_cred IN ('AA','E1'))
			  JOIN bdicred:sd_maesdos maes ON ( maes.empresa = inac.empresa and maes.num_credito = inac.num_credito AND (maes.monto_vencido + maes.mto_venc_trasp) = 0)
             WHERE inac.fecha_gen_campania = dfecha_gen_camp AND inac.fecha_ejecucion = dfecha_ejec_camp AND inac.fecha_entreg_desde = dfecha_desde 
               AND inac.fecha_entreg_hasta = dfecha_hasta AND inac.tipo_campania = pTipo_camp AND inac.num_sub_campania = (sNumCamp - 1) AND inac.status_cte = 'INACT';

    ELIF (pTipo_camp = 'NUN') THEN      -- Obtiene subcampañas 2 en adelante, de Campaña NUNCAS

        -- Obtiene los registros de las campañas 2 en adelante de los creditos que aun sigan sin ser utilizadas (NUNCAS). 
        --INSERT INTO temp_inactivas_nuncas
        INSERT INTO bdicred:sd_camp_inactiv_nuncas
            SELECT pEmpresa, dfecha_gen_camp, pdFechaHoy, dfecha_desde, dfecha_hasta, inac.tipo_campania, inac.tipo_logica, sNumCamp, inac.grupo, 
                   inac.num_credito, inac.numcte, inac.monto_otorgado, inac.fecha_apertura, 0, inac.status_cte, inac.ap_paterno, inac.ap_materno, 
                   inac.primer_nombre, inac.segundo_nombre, inac.sexo, inac.estado_civil, inac.email, inac.estado, inac.ciudad, 
                   inac.fecha_ultima_compra, inac.fecha_ultimo_pago
              FROM bdicred:sd_camp_inactiv_nuncas inac JOIN bdicred:sd_indicador_cred ind ON ( ind.empresa = inac.empresa and ind.num_credito = inac.num_credito)
              JOIN bdicred:sd_maecred cred ON ( cred.empresa = inac.empresa and cred.num_credito = inac.num_credito and cred.status_cred IN ('AA','E1'))
			  JOIN bdicred:sd_maesdos maes ON ( maes.empresa = inac.empresa and maes.num_credito = inac.num_credito AND (maes.monto_vencido + maes.mto_venc_trasp) = 0)
            WHERE inac.fecha_gen_campania = dfecha_gen_camp AND inac.fecha_ejecucion = dfecha_ejec_camp
              AND inac.fecha_entreg_desde = dfecha_desde AND inac.fecha_entreg_hasta = dfecha_hasta AND inac.tipo_campania = pTipo_camp  
              AND inac.num_sub_campania = (sNumCamp - 1) 
              AND nvl(ind.f_primer_compra, date(1)) = date(1) AND nvl(ind.f_primer_disp, date(1)) = date(1) 
              AND inac.status_cte = 'INACT';

    ELSE
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCod_ret, 'TIPO CAMPAÑA INCORRECTA (pTipo_camp)'||'-'||pTipo_camp||'-'||pSubcamp, '02') Returning cCod_RetIB;
        LET cCod_Ret = '000001';        --  Termina proceso, informacion de entrada incorrecta (pTipo_camp)
        RETURN cCod_Ret;
    END IF;
    -- Se actualiza fecha ejecucion de la campaña con fecha_hoy, ya que sd_camp_inactiv_nuncas ya tiene registros con la fecha de hoy.
    LET dfecha_ejec_camp = pdFechaHoy;

    -- Obtiene informacion de telefonos de los clientes obtenidos
    DELETE FROM bdinteg:si_telefonos_nvo_layout_cat WHERE grupo_archivos = 'INA_NUN';
    
    /*INSERT INTO bdinteg:si_telefonos_nvo_layout_cat
        SELECT 'INA_NUN',  camp.num_credito, camp.numcte, tel.tipo_tel::CHAR, decode(tel.tipo_tel,1,'F',2,'M','F') tipored, 
            substr(tel.telefono,length(tel.telefono)-9,10) tel_orig, substr(tel.telefono,length(tel.telefono)-9,10) tel_recons, 
                NVL(tel.carrier,''), NVL(tel.extension, '')
         FROM temp_inactivas_nuncas camp JOIN bdinteg:si_telefonos_actual tel ON ( camp.numcte = tel.numcte )
        WHERE tel.status_tel = 'A' AND tel.cofetel = 'V' AND trim(tel.telefono) <> '' 
          AND length(nvl(tel.telefono,'')) >= 10 AND nvl(tel.telefono, '') <> ''
          AND tipo_tel IN (1,2,3); --- activar para incluir telefono 2 en archivos.
          --AND tel.tipo_tel IN (1,3); */

    INSERT INTO bdinteg:si_telefonos_nvo_layout_cat
        SELECT 'INA_NUN', camp.num_credito, camp.numcte, tel.tipo_tel::CHAR, decode(tel.tipo_tel,1,'F',2,'M','F') tipored, 
            substr(tel.telefono,length(tel.telefono)-9,10) tel_orig, substr(tel.telefono,length(tel.telefono)-9,10) tel_recons, 
                NVL(tel.carrier,''), NVL(tel.extension, '')
         FROM bdicred:sd_camp_inactiv_nuncas camp JOIN bdinteg:si_telefonos_actual tel ON ( camp.numcte = tel.numcte )
        WHERE camp.fecha_gen_campania = dfecha_gen_camp AND camp.tipo_campania = pTipo_camp AND camp.num_sub_campania = pSubcamp
          AND camp.fecha_ejecucion = dfecha_ejec_camp 
          AND tel.status_tel = 'A' AND tel.cofetel = 'V' AND trim(tel.telefono) <> '' 
          AND length(nvl(tel.telefono,'')) >= 10 AND nvl(tel.telefono, '') <> ''
          AND tipo_tel IN (1,2,3); --- activar para incluir telefono 2 en archivos.
          --AND tel.tipo_tel IN (1,3); 

    -- Obtiene los telefonos de referencia casa. (Tipo 4)
    /*FOREACH
        SELECT camp.num_credito, camp.numcte INTO cNumCredito, cNumCte
        FROM temp_inactivas_nuncas camp JOIN bdinteg:si_refdirecciones refdir ON (camp.numcte = refdir.numcte)
        WHERE refdir.tipo_dir = '1' AND refdir.tipo_telef1 = 'P' AND refdir.ind_cofeteltel1 = 'V' AND trim(refdir.telefono1) <> ''
        GROUP BY camp.num_credito, camp.numcte*/
    FOREACH
        SELECT camp.num_credito, camp.numcte INTO cNumCredito, cNumCte
        FROM bdicred:sd_camp_inactiv_nuncas camp JOIN bdinteg:si_refdirecciones refdir ON (camp.numcte = refdir.numcte)
        WHERE camp.fecha_gen_campania = dfecha_gen_camp AND camp.tipo_campania = pTipo_camp AND camp.num_sub_campania = pSubcamp
          AND camp.fecha_ejecucion = dfecha_ejec_camp 
          AND refdir.tipo_dir = '1' AND refdir.tipo_telef1 = 'P' AND refdir.ind_cofeteltel1 = 'V' AND trim(refdir.telefono1) <> ''
        GROUP BY camp.num_credito, camp.numcte


        SELECT substr(telefono1,length(telefono1)-9,10) INTO cNumTel FROM bdinteg:si_refdirecciones WHERE numcte = cNumCte AND tipo_dir = '1' AND tipo_telef1 = 'P' 
           AND ind_cofeteltel1 = 'V' AND secuencia = (Select max(secuencia) from bdinteg:si_refdirecciones where numcte = cNumCte 
                                                and tipo_dir = '1' and tipo_telef1 = 'P' and ind_cofeteltel1 = 'V');

        INSERT INTO bdinteg:si_telefonos_nvo_layout_cat VALUES('INA_NUN', cNumCredito, cNumCte, '4', 'F', cNumTel,cNumTel,0,'');

    END FOREACH;

    -- Se identifican los clientes que no tienen registros de telefonos asignados, para excluirlos del reporte.
    UPDATE bdicred:sd_camp_inactiv_nuncas SET status_cte = 'NOTLF'
     WHERE fecha_gen_campania = dfecha_gen_camp AND tipo_campania = pTipo_camp AND num_sub_campania = pSubcamp
       AND fecha_ejecucion = dfecha_ejec_camp AND fecha_entreg_desde = dfecha_desde AND fecha_entreg_hasta = dfecha_hasta
       AND numcte NOT IN ( SELECT numcte FROM bdinteg:si_telefonos_nvo_layout_cat WHERE grupo_archivos = 'INA_NUN' );

    -- Asigna prioridades
        -- Asigna prioridad: de menor a mayor inactividad & de mayor a menor monto otorgado > 5 m. Del GRUPO A
    LET sCont_prioridad = 0;
    FOREACH
        SELECT num_credito, numcte INTO cNumCredito, cNumCte FROM bdicred:sd_camp_inactiv_nuncas 
         WHERE fecha_gen_campania = dfecha_gen_camp AND tipo_campania = pTipo_camp AND num_sub_campania = pSubcamp 
           AND fecha_ejecucion = dfecha_ejec_camp AND fecha_entreg_desde = dfecha_desde AND fecha_entreg_hasta = dfecha_hasta 
           AND status_cte = 'INACT' AND grupo = 'A'
           ORDER BY fecha_apertura DESC, monto_otorgado DESC

        LET sCont_prioridad = sCont_prioridad  + 1;
        UPDATE bdicred:sd_camp_inactiv_nuncas SET prioridad = sCont_prioridad WHERE fecha_gen_campania = dfecha_gen_camp 
           AND tipo_campania = pTipo_camp AND num_sub_campania = pSubcamp AND fecha_ejecucion = dfecha_ejec_camp 
           AND fecha_entreg_desde = dfecha_desde AND fecha_entreg_hasta = dfecha_hasta AND num_credito = cNumCredito AND numcte = cNumCte;
    END FOREACH;

    -- Asigna prioridad: de menor a mayor inactividad & de mayor a menor monto otorgado de 2100 a 5 m. Del GRUPO B
    -- continua con la secuencia de prioridad, no la reinicia para el grupo B
    --LET sCont_prioridad = 0;
    FOREACH
        SELECT num_credito, numcte INTO cNumCredito, cNumCte FROM bdicred:sd_camp_inactiv_nuncas 
         WHERE fecha_gen_campania = dfecha_gen_camp AND tipo_campania = pTipo_camp AND num_sub_campania = pSubcamp
           AND fecha_ejecucion = dfecha_ejec_camp AND fecha_entreg_desde = dfecha_desde AND fecha_entreg_hasta = dfecha_hasta
           AND status_cte = 'INACT' AND grupo = 'B'
           ORDER BY fecha_apertura DESC, monto_otorgado DESC

        LET sCont_prioridad = sCont_prioridad  + 1;
        UPDATE bdicred:sd_camp_inactiv_nuncas SET prioridad = sCont_prioridad WHERE fecha_gen_campania = dfecha_gen_camp 
           AND tipo_campania = pTipo_camp AND num_sub_campania = pSubcamp AND fecha_ejecucion = dfecha_ejec_camp 
           AND fecha_entreg_desde = dfecha_desde AND fecha_entreg_hasta = dfecha_hasta AND num_credito = cNumCredito AND numcte = cNumCte;
    END FOREACH;

    -- Genera registro de la campaña para el reporte correspondiente.
    IF sNumCamp = 1 THEN

        -- Se inserta el registro de la campaña actual.
        SELECT count(*) INTO itot_tarj_entreg FROM bdicred:sd_camp_inactiv_nuncas WHERE fecha_gen_campania = dfecha_gen_camp 
           AND tipo_campania = pTipo_camp AND num_sub_campania = pSubcamp AND fecha_ejecucion = dfecha_ejec_camp 
           AND fecha_entreg_desde = dfecha_desde AND fecha_entreg_hasta = dfecha_hasta  AND status_cte = 'INACT';

        LET itot_tarj_act = NULL;   LET itot_tarj_inact = NULL;

        INSERT INTO bdicred:sd_camp_inactiv_nuncas_reporte VALUES(pEmpresa, dfecha_gen_camp, dfecha_ejec_camp, dfecha_desde, dfecha_hasta, 
                pTipo_camp, sNumCamp, itot_tarj_entreg, itot_tarj_act, itot_tarj_inact, NULL );

    ELSE
        -- Se actualizan numeros del registro de la subcampaña anterior. Se obtiene los numero de tarjetas entregadas = num de tarjetas q termina la previa
        SELECT count(*) INTO itot_tarj_entreg FROM bdicred:sd_camp_inactiv_nuncas WHERE fecha_gen_campania = dfecha_gen_camp 
           AND tipo_campania = pTipo_camp AND num_sub_campania = pSubcamp AND fecha_ejecucion = dfecha_ejec_camp 
           AND fecha_entreg_desde = dfecha_desde AND fecha_entreg_hasta = dfecha_hasta  AND status_cte = 'INACT';

        -- Se actualizan datos de la campaña anterior. Las inactivas restantes de la campaña anterior = Las entregadas de esta campaña
        UPDATE bdicred:sd_camp_inactiv_nuncas_reporte SET tot_tarj_inactivas = itot_tarj_entreg, tot_tarj_activas = (tot_tarj_entregadas - itot_tarj_entreg), 
            porcentaje_efec = (((tot_tarj_entregadas - itot_tarj_entreg) / tot_tarj_entregadas) * 100) -- itot_tarj_entreg = inactivas de camp anterior
            WHERE fecha_gen_campania = dfecha_gen_camp AND tipo_campania = pTipo_camp AND num_sub_campania = (sNumCamp - 1)
              AND fecha_entreg_desde = dfecha_desde AND fecha_entreg_hasta = dfecha_hasta; 

        -- Se genera registro de la campaña actual.
        LET itot_tarj_act = NULL;  LET itot_tarj_inact = NULL;

        INSERT INTO bdicred:sd_camp_inactiv_nuncas_reporte VALUES(pEmpresa, dfecha_gen_camp, dfecha_ejec_camp, dfecha_desde, dfecha_hasta, 
                pTipo_camp, sNumCamp, itot_tarj_entreg, itot_tarj_act, itot_tarj_inact, NULL );

    END IF;


    -- Se ejecuta el sp que generará el archivo correspondiente a la campaña. Asi mismo obtendra la información de los telefonos.
    CALL bdicred:sp_camp_tdc_inact_nunc_crea_arch(pempresa, pTipo_camp, sNumCamp, dfecha_gen_camp, dfecha_desde, dfecha_hasta, pdFechaHoy) Returning cCod_RetIB;

    IF cCod_RetIB != '000000' THEN
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCod_ret, 'Error al ejecutar sp_camp_tdc_inact_nunc_crea_arch campaña'||'-'||pTipo_camp||'-'||pSubcamp, '02') Returning cCod_RetIB;
        LET cCod_Ret = '000001';
        RETURN cCod_Ret;
    END IF;


    --CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCod_ret, 'FINALIZA'||'-'||pTipo_camp||'-'||pSubcamp, '02') Returning cCod_RetIB;
    RETURN cCod_Ret;


END;
END PROCEDURE;