CREATE PROCEDURE "informix".consctacte(pEmpresa char(3), pNumeroTarjeta char(20))


	--DATOS A REGRESAR---
	RETURNING
	CHAR(5),  -- Codigo de Retorno
	CHAR(20), -- # de Cuenta
	CHAR(20); -- # de Cliente


	--DEFINICION DE VARIABLES--
	DEFINE vCodRet		char(5);
	DEFINE vNumCuenta	char(20);
	DEFINE vNumCliente	char(20);
    DEFINE vStatus      char(1);


	--INICIALIZACION DE VARIABLES--
	LET vCodRet = "000";

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	-- CONSULTA --
	SELECT
        cuenta, numcte, status_tar
	INTO
        vNumCuenta, vNumCliente, vStatus
	FROM
		bdicheq:"informix".sc_tarjeta
	WHERE
		empresa = pEmpresa AND num_tarjeta = pNumeroTarjeta;


	IF vNumCuenta IS NULL OR vNumCliente IS NULL THEN
		LET vCodRet		= "252";
		LET vNumCuenta  = "";
		LET vNumCliente = "";
    ELIF vStatus = "C" THEN
        LET vCodRet     = "143";
		--LET vNumCuenta  = "";
		--LET vNumCliente = "";
    END IF


	RETURN vCodRet, vNumCuenta, vNumCliente;

END PROCEDURE
DOCUMENT
"Modificó: Julio Cesar Polanco",
"Descripción: Se modifica para que si esta cancelada la tarjeta regrese el codigo 143",
"Solicitó: Cutberto Gonzalez",
"Fecha: 15/10/2010",

"Modifico: Sonia Guzman Rodriguez",
"Descripcion: Se modifica para que si esta cancelada la tarjeta envie el numero de cuenta y el numero de cliente",
"Solicito: Cutberto Gonzalez",
"Fecha: 03/04/2011";

CREATE PROCEDURE "informix".sp_blqcargayvalidaarchivobloqmasivo(pNombreArchivo CHAR(20))
RETURNING CHAR(6), CHAR(90);

    -- // DEFINICIONES
    DEFINE cCodRet         CHAR(6);
    DEFINE cCodRet2        CHAR(6);
    DEFINE cCodRet3        CHAR(60);
    DEFINE cMensajeRet     CHAR(90);
    DEFINE sql_err         INTEGER;
    DEFINE isam_err        INTEGER;
    DEFINE desc_err        CHAR(60);
    DEFINE cSQL            CHAR(350);
    DEFINE cRuta           CHAR(60);
    DEFINE cCuenta         CHAR(20);
    DEFINE cClaveBloqueo   CHAR(20);
    DEFINE iOpcionBloqueo  CHAR(2);
    DEFINE mImporte        CHAR(20);
    DEFINE cArea           CHAR(2);
    DEFINE cMotivoBloqueo  CHAR(2);
    DEFINE iContador       INTEGER;
    DEFINE iColumna        INTEGER;
    
    -- // INICIALIZACIONES
    LET cCodRet           = '000';
    LET cMensajeRet       = '';
    LET cSQL              = '';
    LET cRuta             = '';
    LET cCuenta           = '';
    LET cClaveBloqueo     = '';
    LET iOpcionBloqueo    = '';
    LET mImporte          = '';
    LET cArea             = '';
    LET cMotivoBloqueo    = '';
    LET iContador         = 0;
    LET iColumna          = 0;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/bloqmasivos/sp_blqcargayvalidaarchivobloqmasivo.out";
    --- TRACE ON;
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/bloqmasivos/sp_blqcargayvalidaarchivobloqmasivo.err";
        TRACE ON;
        LET cCodRet = sql_err;
        LET cCodRet2 = isam_err;
        LET cCodRet3 = desc_err;
        LET cMensajeRet = '';
        IF cCodRet = '-668' THEN
            LET cCodRet = '002';
            LET cMensajeRet = 'No se encuentra archivo para cargar o no cumple con la validación para ser cargado.';
        END IF;
        DROP TABLE "informix".sc_bloqueoctastemp;
        RETURN cCodRet, cMensajeRet;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    IF EXISTS(SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'sc_bloqueoctastemp') THEN
        DROP TABLE "informix".sc_bloqueoctastemp;
    END IF;  

    -- // Se crea una tabla temporal que contendra los registros que seran cargados en la tabla 
    CREATE TABLE "informix".sc_bloqueoctastemp  
        ( 
            cuenta         CHAR(20) NOT NULL,
            clave_bloqueo  CHAR(2)  NOT NULL,
            opcion_bloqueo CHAR(2)  NOT NULL,
            importe        CHAR(20),
            area           CHAR(2)  NOT NULL,
            motivo_bloqueo CHAR(2)  NOT NULL
        )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_bloqctastemp ON "informix".sc_bloqueoctastemp(cuenta) USING BTREE; 
    UPDATE STATISTICS MEDIUM FOR TABLE sc_bloqueoctastemp;

    -- // Se consulta la ruta de repositorio del archivo a cargarse.
    SELECT valor 
      INTO cRuta 
      FROM "informix".sc_param 
     WHERE empresa = "001"  
       AND codparam = "rutarchbloqmasivos";

    -- // Carga el archivo de Respuesta a la tabla temporal.
    LET cSQL = '';
    LET cSQL = 'echo "LOAD FROM '||TRIM(cRuta)||TRIM(pNombreArchivo)||' delimiter '','' INSERT INTO sc_bloqueoctastemp" > '||TRIM(cRuta)||'query.sql';
    SYSTEM cSQL;

    -- // Se ejecuta el archivo cargado anteriormente.
    LET cSQL = '';
    LET cSQL = "/ifxsif01/bin/dbaccess bdicheq "||TRIM(cRuta)||"query.sql";
    SYSTEM cSQL;

    -- // Borra el Archivo Generado para carga de registros
    LET cSQL = "/usr/bin/rm -rf "||TRIM(cRuta)||TRIM(pNombreArchivo);
    SYSTEM cSQL;  

    -- // Se realiza la validacion del archivo que se desea cargar a la base de datos.
    FOREACH
        SELECT cuenta, clave_bloqueo, opcion_bloqueo, importe, area, motivo_bloqueo
          INTO cCuenta, cClaveBloqueo, iOpcionBloqueo, mImporte, cArea, cMotivoBloqueo
          FROM "informix".sc_bloqueoctastemp

        LET iContador = iContador + 1;

        -- // Se valida la estructura del archivo que se desea cargar.
        IF bdiprog:"informix".isnumeric(cCuenta) <> 1 OR bdiprog:"informix".isInteger(cClaveBloqueo) <> 1 OR bdiprog:"informix".isDecimal14(mImporte) <> 1 THEN 
            IF bdiprog:isnumeric(cCuenta) <> 1 THEN 
                LET iColumna = 1;
            ELIF bdiprog:isInteger(cClaveBloqueo) <> 1 THEN
                LET iColumna = 2;
            ELIF bdiprog:isDecimal14(mImporte) <> 1 THEN
                LET iColumna = 4;
            END IF;

            LET cCodRet = '002';
            LET cMensajeRet = 'El registro '||iContador||' en la columna '||iColumna||' no cumple con la validacion';
            
            EXIT FOREACH;
        END IF;
    END FOREACH;

    IF cCodRet = '000' THEN
        -- // Si el registro cumple con los criterios indicados se guarda en la tabla temporal.
        INSERT INTO "informix".sc_bloqueomasivoctas(cuenta, clave_bloqueo, opcion_bloqueo, importe, area, motivo_bloqueo)
        SELECT cuenta, clave_bloqueo, opcion_bloqueo, importe, area, motivo_bloqueo 
          FROM "informix".sc_bloqueoctastemp;

        LET cCodRet = '000';
        LET cMensajeRet = 'Validacion Terminada';
    END IF;

    -- // Se eliminian los registros de la tabla
    DROP TABLE "informix".sc_bloqueoctastemp;

    RETURN cCodRet,cMensajeRet;

    END;
END PROCEDURE
DOCUMENT
'AUTOR: Valentin Lopez',
'FECHA: 09 Mayo del 2011',
'DESCRIPCION: Se valida que el archivo recibido cumpla con los criterios indicados.',
'VERSION: 20110509.0915',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_blqgenerabloqueoctamasivo(pEmpresa CHAR(3), pNombreArchivo CHAR(20) , pUsuario CHAR(8))
RETURNING CHAR(6), CHAR(20), CHAR(2), INTEGER, MONEY(14,2), CHAR(25), CHAR(2), CHAR(4), CHAR(10), CHAR(8), CHAR(30), CHAR(20);

    -- // DEFINICIONES
    DEFINE cCodRet          CHAR(6);
    DEFINE cCodRet2         CHAR(6);
    DEFINE cCodRet3         CHAR(6);
    DEFINE cCodRet4         CHAR(60);
    DEFINE cCuenta          CHAR(20);
    DEFINE cClaveBloqueo    CHAR(2);
    DEFINE iOpcionBloqueo   INTEGER;
    DEFINE mImporte         MONEY(14,2);
    DEFINE cArea            CHAR(2);
    DEFINE cMotivoBloqueo   CHAR(2);
    DEFINE cFolioBloqueo    CHAR(4);
    DEFINE cFechaBloqueo    CHAR(10);
    DEFINE cFechaBloqueo2   CHAR(10);
    DEFINE cUsuario         CHAR(8);
    DEFINE cEstatus         CHAR(30);
    DEFINE cAreaSolicito    CHAR(25);
    DEFINE iIdArchivo       INTEGER;
    
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(60);
    DEFINE cSQL             CHAR(350);
    
    DEFINE vcodret1         CHAR(6);   
    DEFINE vmensaje1        CHAR(40);
    DEFINE vclave1          CHAR(2);
    DEFINE vcodigo1         CHAR(1);
    DEFINE vdesc1           CHAR(20);
    DEFINE vcoddesc1        CHAR(38);
    DEFINE vcvedesc1        CHAR(38);
    DEFINE vcodret2         CHAR(6);   
    DEFINE vmensaje2        CHAR(40);
    DEFINE vclave2          CHAR(2);
    DEFINE vcodigo2         CHAR(1);
    DEFINE vdesc2           CHAR(20);
    DEFINE vcoddesc2        CHAR(38);
    DEFINE vcvedesc2        CHAR(38);
    
    -- // INICIALIZACIONES
    LET cCodRet           = '000000';
    LET cCodRet2          = '000000';
    LET cCuenta           = '';
    LET cClaveBloqueo     = '';
    LET iOpcionBloqueo    = 0;
    LET mImporte          = 0.00;
    LET cArea             = '';
    LET cMotivoBloqueo    = '';
    LET cFolioBloqueo     = '0000';
    LET cFechaBloqueo     = '01-01-2000';
    LET cFechaBloqueo2    = '01-01-2000';
    LET cUsuario          = '';
    LET cEstatus          = '';
    LET cAreaSolicito     = '';

    LET cSQL              = '';
    LET iIdArchivo        = 0;
    
    LET vcodret1  = '';
    LET vmensaje1 = '';
    LET vclave1   = '';
    LET vcodigo1  = '';
    LET vdesc1    = '';
    LET vcoddesc1 = '';
    LET vcvedesc1 = '';
    LET vcodret2  = '';
    LET vmensaje2 = '';
    LET vclave2   = '';
    LET vcodigo2  = '';
    LET vdesc2    = '';
    LET vcoddesc2 = '';
    LET vcvedesc2 = '';
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/bloqmasivos/sp_blqgenerabloqueoctamasivo.out";
    --- TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/bloqmasivos/sp_blqgenerabloqueoctamasivo.err";
        TRACE ON;
        LET cCodRet = sql_err;
        LET cCodRet3 = isam_err;
        LET cCodRet4 = desc_err;
        RETURN cCodRet,TRIM(cCuenta),cClaveBloqueo,iOpcionBloqueo,mImporte,TRIM(cAreaSolicito),cMotivoBloqueo,cFolioBloqueo,cFechaBloqueo,pUsuario,cEstatus,pNombreArchivo;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT SUBSTRING (fecha_hoy FROM 4 FOR 2) ||'-'||  SUBSTRING (fecha_hoy FROM 1 FOR 2)||'-'|| SUBSTRING (fecha_hoy FROM 7 FOR 4), fecha_hoy
      INTO cFechaBloqueo2, cFechaBloqueo
      FROM bdicheq:"informix".sc_fechas
     WHERE empresa = '001';

    --// Se inserta un identificador del archivo que se acaba de generar.
    SELECT NVL(MAX(idarchivo),0) + 1 
      INTO iIdArchivo 
      FROM sc_bloqueomasivoctashist;

    FOREACH -- // Se consultan todos los registros que contiene el archivo cargado.
        SELECT NVL(Cuenta,''), clave_bloqueo, opcion_bloqueo, importe, area, motivo_bloqueo 
          INTO cCuenta, cClaveBloqueo, iOpcionBloqueo, mImporte, cArea, cMotivoBloqueo
          FROM bdicheq:"informix".sc_bloqueomasivoctas

        -- // Verifico que si puedo bloquear la cuenta, si ya esta bloqueada retorna un 10000, 00000 - Sin bloqueo, 20000 - TeniaBloqueo
        EXECUTE PROCEDURE bdicheq:"informix".sp_blqvalbloqueocta(cCuenta)
        INTO cCodRet2, cEstatus;

        IF cCodRet2 = '00000' OR cCodRet2 = '20000' THEN 
        
            IF EXISTS (SELECT codigo FROM bdicheq:"informix".sc_bloqueo WHERE codigo = cClaveBloqueo) THEN
            
                IF EXISTS (SELECT opcion FROM bdicheq:"informix".sc_opcionbloqueo WHERE opcion = iOpcionBloqueo) THEN
                    
                    CALL bdicheq:"informix".sp_blqconsareasolicbloqueo(cArea, "")
                    RETURNING vcodret1, vmensaje1, vclave1, vcodigo1, vdesc1, vcoddesc1, vcvedesc1;
                    
                    IF EXISTS (SELECT codigo FROM bdicheq:"informix".sc_areabloqueo WHERE codigo = vcodigo1) THEN
                    
                        CALL bdicheq:"informix".sp_blqconstipobloqueo(cMotivoBloqueo, "")
                        RETURNING vcodret2, vmensaje2, vclave2, vcodigo2, vdesc2, vcoddesc2, vcvedesc2;
                        
                        IF EXISTS (SELECT codigo FROM bdicheq:"informix".sc_tipobloqueo WHERE codigo = vcodigo2) THEN
                        
                            CALL "informix".bloqueo_cta(pEmpresa,cCuenta,mImporte,cClaveBloqueo,iOpcionBloqueo,cFechaBloqueo,pUsuario,'',cArea,vcodigo1,cMotivoBloqueo,vcodigo2)
                            RETURNING cCodRet2, cFolioBloqueo;
                            
                        ELSE
                            LET cCodRet2 = '005'; --- No existe el tipo de bloqueo
                        END IF;
                    ELSE
                        LET cCodRet2 = '004'; --- No existe el area de bloqueo
                    END IF;
                ELSE 
                    LET cCodRet2 = '002'; --- No existe la opcion de bloqueo
                END IF;
            ELSE
                LET cCodRet2 = '003'; --- No existe la clave bloqueo
            END IF;
        ELSE
            LET cCodRet2 = '303';
        END IF;

        -- // Se insertan registros solamente de la cuentas que se pudieron bloquear.
        INSERT INTO sc_bloqueomasivoctashist
        (cuenta, clave_bloqueo, opcion_bloqueo, importe, area, motivo_bloqueo, folio_bloqueo, fecha_bloqueo, usuarioinsert, motivo_error, nombrearchivo, idarchivo)
        VALUES 
        (cCuenta, cClaveBloqueo, iOpcionBloqueo, mImporte, cArea, cMotivoBloqueo, cFolioBloqueo, cFechaBloqueo2, pUsuario, cCodRet2, pNombreArchivo, iIdArchivo);

        -- // Se muestra un reporte de las cuentas que no pudieron ser bloqueadas y se valida el motivo.
        IF cCodRet2 = '100' THEN
            LET cEstatus = 'Cuenta Inexistente';
        ELIF cCodRet2 = '000' THEN
            LET cEstatus = 'Aplicado';
        ELIF cCodRet2 = '162' OR cCodRet2 ='163' THEN
            LET cEstatus = 'Saldo Insuficiente';
        ELIF cCodRet2 = '302' OR cCodRet2 = '303' THEN
            LET cEstatus = 'No Aplicado-Bloq Anterior';
        ELIF cCodRet2 = '200' THEN
            LET cEstatus = 'Cuenta Cancelada';
        ELIF cCodRet2 = '003' THEN
            LET cEstatus = 'Clave Bloqueo Inexistente';
        ELIF cCodRet2 = '002' THEN
            LET cEstatus = 'Opcion Bloqueo Inexistente';
        ELIF cCodRet2 = '004' THEN
            LET cEstatus = 'Area Bloqueo Inexistente';
        ELIF cCodRet2 = '005' THEN
            LET cEstatus = 'Tipo Bloqueo Inexistente';
        END IF;
        
        SELECT descripcion 
          INTO cAreaSolicito 
          FROM bdicheq:"informix".sc_areabloqueo 
         WHERE clave = cArea;

        IF cAreaSolicito IS NULL OR cAreaSolicito = ''THEN
            LET cAreaSolicito = 'AREA INEXISTENTE';
        END IF;

        RETURN cCodRet2,TRIM(cCuenta),cClaveBloqueo,iOpcionBloqueo,mImporte,TRIM(cAreaSolicito),cMotivoBloqueo,cFolioBloqueo,cFechaBloqueo2,pUsuario,cEstatus,pNombreArchivo WITH RESUME;
    END FOREACH;

    -- // En caso de que no se encuentren registros en la tabla sc_BloqueoMasivoCtas
    IF cCuenta IS NULL OR cCuenta = '' THEN
        LET cCodRet = '001';  --- No se encuentran registros en la tabla.
        RETURN cCodRet,TRIM(NVL(cCuenta,'')),cClaveBloqueo,iOpcionBloqueo,mImporte,TRIM(cAreaSolicito),cMotivoBloqueo,cFolioBloqueo,cFechaBloqueo2,pUsuario,cEstatus,pNombreArchivo;
    END IF;

    -- // Se borran los registros que fueron procesados.
    --- DELETE FROM bdicheq:"informix".sc_bloqueomasivoctas;
    TRUNCATE TABLE "informix".sc_bloqueomasivoctas;

    END;
    
END PROCEDURE
DOCUMENT
'AUTOR: Valentin Lopez',
'FECHA: 10 Mayo del 2011',
'DESCRIPCION: Realiza un bloqeuo masivo de las cuentas siempre y cuando cumpla con los criterios para ser bloqueadas.',
'VERSION: 20110510.0825',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_rptmensualconproac( pempresa char(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50);
     
    DEFINE vcodret1             char(5);
    DEFINE vcodret2             char(5);
    DEFINE vcodret3             char(50);
    DEFINE sql_err              integer;
    DEFINE isam_err             integer;
    DEFINE desc_err             char(50);
    DEFINE vcontador1           integer;
    DEFINE vcontador2           integer;
    DEFINE vcontador3           integer;
    DEFINE ven_transacc         smallint;
    DEFINE vcomienza            smallint;
    
    DEFINE vfecha_hoy           date;
    DEFINE vfecha_ant           DATE;
    DEFINE vpri_dia_mes         DATE;
    DEFINE vfecha_ini           DATE;
    DEFINE vfecha_fin           DATE;
    DEFINE vfecha_ejecucion     DATE;
    DEFINE vfechaproc           DATE;
    DEFINE vfechconmovhis       char(10);
    DEFINE vfechconmovhisold    char(10);
    
    DEFINE vsucursal            char(4);
    DEFINE vproducto            char(4);
    DEFINE vno_ctes             integer;
    DEFINE vno_ctas             integer;
    DEFINE vsdo_fin_mes         decimal(18,2);
    DEFINE vno_compras          integer;
    DEFINE vmonto_compras       decimal(18,2);
    DEFINE vsdo_proac           decimal(18,2);
    DEFINE vpremio_proac        decimal(18,2);
    
    DEFINE vsql                 CHAR(500);
    DEFINE vfechades            CHAR(6);

    LET vcodret1     = "000";               
    LET vcodret2     = '000';
    LET vcodret3     = 'PROCESO CONCLUIDO SATISFACTORIAMENTE';
    LET sql_err      = 0;                   
    LET isam_err     = 0;
    LET desc_err     = '';
    LET vcontador1   = 0;                   
    LET vcontador2   = 0;
    LET vcontador3   = 0;
    LET ven_transacc = 0;                   
    LET vcomienza    = -1;  
       
    LET vfecha_hoy        = ''; 
    LET vfecha_ant        = '';
    LET vpri_dia_mes      = '';
    LET vfecha_ini        = '';
    LET vfecha_fin        = '';
    LET vfecha_ejecucion  = '';
    LET vfechaproc        = '';
    LET vfechconmovhis    = '';
    LET vfechconmovhisold = '';
    
    LET vsucursal      = '';
    LET vproducto      = '';
    LET vno_ctes       = 0;
    LET vno_ctas       = 0;
    LET vsdo_fin_mes   = 0.00;
    LET vno_compras    = 0;
    LET vmonto_compras = 0.00;
    LET vsdo_proac     = 0.00;
    LET vpremio_proac  = 0.00;
    
    LET vsql      = '';
    LET vfechades = '';
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_rptmensualconproac.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcodret3;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_rptmensualconproac.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    SELECT fecha_hoy, fecha_ant, pri_dia_mes
      INTO vfecha_hoy, vfecha_ant, vpri_dia_mes
      FROM sc_fechas
     WHERE empresa = pempresa;
     
    LET vfecha_ini = vpri_dia_mes - 1 UNITS MONTH;
    LET vfecha_fin = vpri_dia_mes - 1 UNITS DAY;
    
    -- // VERIFICA QUE NO SE HAYA EJECUTADO EL PROCESO
    SELECT fecha
      INTO vfecha_ejecucion
      FROM sc_contproc_proac
     WHERE proceso = 'rptmensualconproac'
       AND empresa = pempresa;
       
    IF vfecha_ejecucion >= vpri_dia_mes THEN
        LET vcodret1 = '958';
        LET vcodret2 = '958';
        
        SELECT descripcion
          INTO vcodret3
          FROM bdinteg:si_codret
         WHERE codigo_retorno = vcodret1
           AND sistema = '01';
           
        RETURN vcodret1, vcodret2, vcodret3;
    END IF;
    
    -- // Verifica se haya efectuado el paso de movs a historico
    SELECT fecha 
      INTO vfechaproc
      FROM sc_contproc
     WHERE empresa = pempresa 
       AND proceso = "pasomovshist"
       AND fecha = vfecha_ant;
       
    IF vfechaproc is null THEN
        LET vcodret1 = '953';
        LET vcodret2 = '953';
        
        SELECT descripcion
          INTO vcodret3
          FROM bdinteg:si_codret
         WHERE codigo_retorno = vcodret1
           AND sistema = '01';
           
        RETURN vcodret1, vcodret2, vcodret3;
    END IF;
    
    -- // BORRA Y CREA TABLA PARA REPORTE
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'sc_rptmensualconproac') THEN
        DROP TABLE "informix".sc_rptmensualconproac;        
    END IF;
    
    CREATE TABLE "informix".sc_rptmensualconproac
      ( 
        sucursal            CHAR(4), 
        producto            CHAR(4), 
        no_clientes         INTEGER,
        no_cuentas          INTEGER,
        sdo_fin_mes         DECIMAL(18,2),
        no_compras_td       INTEGER,
        monto_compras_td    DECIMAL(18,2),
        sdo_proac           DECIMAL(18,2),
        premio_proac        DECIMAL(18,2)
      ) 
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_rptmenconproac ON "informix".sc_rptmensualconproac(sucursal);
    UPDATE STATISTICS MEDIUM FOR TABLE "informix".sc_rptmensualconproac;

    -- // PARAMETROS DE CONSULTA PARA MOVIMIENTOS HISTORICOS
    SELECT valor 
      INTO vfechconmovhis
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'fechcon_movhis';
       
    SELECT valor 
      INTO vfechconmovhisold
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'FechIniCon_movhis_ol';
       
    -- // TABLA TEMPORAL DE MOVIMIENTOS DEL MES
    SELECT *
      FROM sc_movhis_old  
     WHERE fech_alt BETWEEN vfecha_ini and vfecha_fin
       AND fech_alt >= vfechconmovhisold
       AND fech_alt < vfechconmovhis
       AND transacc IN('0830','0887')
       AND cancelad <> 'S'
    UNION ALL
    SELECT *
      FROM sc_movhis
     WHERE fech_alt BETWEEN vfecha_ini AND vfecha_fin
       AND fech_alt >= vfechconmovhis
       AND transacc IN('0830','0887')
       AND cancelad <> 'S'
    INTO TEMP tmp_movs WITH NO LOG;
    CREATE INDEX idx_tmpmovs1 ON tmp_movs(suc_cuen, producto);
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_movs;
    
    FOREACH WITH HOLD
        SELECT sucursal
          INTO vsucursal
          FROM sc_sucsrptsproac
          
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET ven_transacc = 1;
            BEGIN WORK;
        END IF;
          
        FOREACH
            SELECT producto
              INTO vproducto
              FROM sc_prodproac
             
            SELECT NVL(COUNT(UNIQUE mae.num_cte),0)
              INTO vno_ctes
              FROM sc_maechq mae
             WHERE mae.sucursal = vsucursal
               AND mae.producto = vproducto
               AND mae.status_cta <> '2'
               AND mae.cuenta IN(SELECT cta_eje
                                   FROM sc_proac
                                  WHERE cta_eje = mae.cuenta
                                    AND status_cta = '1');
               
            SELECT NVL(COUNT(mae.cuenta),0)
              INTO vno_ctas
              FROM sc_maechq mae
             WHERE mae.sucursal = vsucursal
               AND mae.producto = vproducto
               AND mae.status_cta <> '2'
               AND mae.cuenta IN(SELECT cta_eje
                                   FROM sc_proac
                                  WHERE cta_eje = mae.cuenta
                                    AND status_cta = '1');
               
            SELECT NVL(SUM(mae.sdo_dia_ant),0.00)
              INTO vsdo_fin_mes
              FROM sc_maechq mae
             WHERE mae.sucursal = vsucursal
               AND mae.producto = vproducto
               AND mae.status_cta <> '2'
               AND mae.cuenta IN(SELECT cta_eje
                                   FROM sc_proac
                                  WHERE cta_eje = mae.cuenta
                                    AND status_cta = '1');
               
            SELECT NVL(COUNT(mov.num_serial),0)
              INTO vno_compras
              FROM tmp_movs mov
             WHERE mov.suc_cuen = vsucursal
               AND mov.producto = vproducto
               AND mov.cuenta IN(SELECT cta_eje
                                   FROM sc_proac
                                  WHERE cta_eje = mov.cuenta
                                    AND status_cta = '1');
               
            SELECT NVL(SUM(mov.monto_tot),0.00)
              INTO vmonto_compras
              FROM tmp_movs mov
             WHERE mov.suc_cuen = vsucursal
               AND mov.producto = vproducto
               AND mov.cuenta IN(SELECT cta_eje
                                   FROM sc_proac
                                  WHERE cta_eje = mov.cuenta
                                    AND status_cta = '1');
               
            SELECT NVL(SUM(saldo),0.00)
              INTO vsdo_proac
              FROM sc_proac
             WHERE cta_eje IN(SELECT cuenta 
                                FROM sc_maechq 
                               WHERE sucursal = vsucursal 
                                 AND producto = vproducto 
                                 AND status_cta <> '2')
               AND status_cta = '1';
               
            SELECT NVL(SUM(prem_proac),0.00)
              INTO vpremio_proac
              FROM sc_proac
             WHERE cta_eje IN(SELECT cuenta 
                                FROM sc_maechq 
                               WHERE sucursal = vsucursal 
                                 AND producto = vproducto 
                                 AND status_cta <> '2')
               AND status_cta = '1';
               
            INSERT INTO sc_rptmensualconproac(sucursal, producto, no_clientes, no_cuentas, sdo_fin_mes, no_compras_td, monto_compras_td, sdo_proac, premio_proac)
            VALUES(vsucursal, vproducto, vno_ctes, vno_ctas, vsdo_fin_mes, vno_compras, vmonto_compras, vsdo_proac, vpremio_proac);
            
            LET vproducto      = '';
            LET vno_ctes       = 0;
            LET vno_ctas       = 0;
            LET vsdo_fin_mes   = 0.00;
            LET vno_compras    = 0;
            LET vmonto_compras = 0.00;
            LET vsdo_proac     = 0.00;
            LET vpremio_proac  = 0.00;
        END FOREACH;
        
        COMMIT WORK;
        BEGIN WORK;
        
        LET vsucursal = '';
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    UPDATE STATISTICS MEDIUM FOR TABLE "informix".sc_rptmensualconproac;
    
    -- // DESCARGA EL ARCHIVO DE INFORMACIÓN
    LET vfechades = TO_CHAR(vfecha_fin, '%Y%m');
    
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/rptmensualconproac_'||vfechades||'.txt '||
               ' SELECT * FROM sc_rptmensualconproac ORDER BY sucursal, producto;" > /resplogifx/conciliachq/rptproac3.sql';
    SYSTEM vsql;
    
    LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/rptproac3.sql"; 
    SYSTEM vsql;
    
    UPDATE sc_contproc_proac
       SET fecha = vfecha_hoy
     WHERE proceso = 'rptmensualconproac'
       AND empresa = pempresa;
    
    END;

    RETURN vcodret1, vcodret2, vcodret3;

END PROCEDURE;