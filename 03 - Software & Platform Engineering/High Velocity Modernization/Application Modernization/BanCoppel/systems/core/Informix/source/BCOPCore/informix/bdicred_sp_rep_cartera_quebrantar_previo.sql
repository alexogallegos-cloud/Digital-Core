CREATE PROCEDURE "informix".sp_rep_cartera_quebrantar_previo(pEmpresa CHAR(3), pPagos SMALLINT)
RETURNING CHAR (6);
 
--Juan Andrés Coronel Morán
 
--22-01-2008
--Obtener datos de clientes con tarjeta de credito
 
--  Paul IvAn Quintero Varela
--  18/02/2008
--  Se modifica para  que una vez obtenida la informacion la descargue en un archivo de salida
 
--  Paul Ivan Quintero Varela
--  26/02/2008
--  Se agrega ademas los siguientes datos:
--          Se obtiene los Intereses Vigentes
--          Se obtiene el Iva de los Intereses Vigentes
--          Se obtiene el Interes Moratorio Ordinario
--          Se obtiene el Iva de Intereses Moratorio Ordinarios
--          Se obtiene el Interes Moratorio Copete
--          Se obtiene el Iva de Intereses Moratorio Copete

--  Frank Gaxiola Gaxiola
--  26/08/2009
--  Se agrega filtro para la consulta a la tabla si_ingresos para que 
--  se tome la maxima secuencia del tipo de ingreso "T"

DEFINE cNumCredito, cNumCte CHAR(20);
DEFINE pNum_Vencidos    SMALLINT;
 
DEFINE cApellido1,cApellido2,cNombre1,cNombre2 CHAR(20);
DEFINE cRfc                     CHAR(13);
DEFINE cApellidoCasada          CHAR(26);
 
DEFINE cSector                  CHAR(2);
DEFINE dFechaNac                DATE;
DEFINE cCurp                    CHAR(20);
DEFINE cSexo                    CHAR(1);
DEFINE cEdoCivil                CHAR(2);
DEFINE cNumIdentificacion       CHAR(30);
 
DEFINE cEmail                   CHAR(60);
DEFINE cTipoIdentificacion      CHAR(40);
DEFINE cNacionalidad            CHAR(15);
 
DEFINE cNumEstado,cNumCiudad INTEGER;
DEFINE cPoblacion               CHAR(80);
DEFINE cNumColonia, cNumCalle INTEGER;
DEFINE cNumExterior, cNumInterior CHAR(10);
 

DEFINE cCodPostal               CHAR(5);
DEFINE cPuntoCardinal           CHAR(1);
DEFINE iManzana, iAndador, iEtapa, iLote, iEdificio, iEntrada  INTEGER;
 
DEFINE cDepartamento            CHAR(6);
DEFINE cComplemento             CHAR(80);
DEFINE cEntreCalles             CHAR(40);
DEFINE sOtros                   SMALLINT;
 
DEFINE mIngresoMensual          MONEY(14,2);
DEFINE cPuesto                  CHAR(3);
DEFINE cLugarTrabajo            CHAR(25);
DEFINE cTelefono, cTelTrab, cExtTrab CHAR(13);
 
DEFINE sElementoRes             SMALLINT;
DEFINE cDescripcion             CHAR(80);
DEFINE sElemResTrabajo          SMALLINT;
DEFINE cDescripPermTrabajo      CHAR(80);
 
DEFINE cActividad               CHAR(45);
 
---Domicilio de Trabajo
DEFINE cNumEstadoTrab, cNumCiudadTrab INTEGER;
DEFINE cPoblacionTrab           CHAR(80);
DEFINE cNumColoniaTrab, cNumCalleTrab INTEGER;
DEFINE cNumExteriorTrab, cNumInteriorTrab CHAR(10);
 
DEFINE cCodPostalTrab           CHAR(5);
DEFINE cPuntoCardinalTrab       CHAR(1);
DEFINE iManzanaTrab, iAndadorTrab, iEtapaTrab, iLoteTrab, iEdificioTrab, iEntradaTrab INTEGER;
 
DEFINE cDepartamentoTrab        CHAR(6);
DEFINE cComplementoTrab         CHAR(80);
DEFINE cEntreCallesTrab         CHAR(40);
DEFINE iOtrosTrab               SMALLINT;
 
------- PENDIENTES DE GENERAR
DEFINE cSituacion               CHAR(1);
DEFINE sCausa                   SMALLINT;
DEFINE dFechaMovtoSit           DATE;
DEFINE cEvaluacionCC            CHAR(1);
DEFINE cExisteCC                CHAR(2);
DEFINE iContadorRegistros       INTEGER;
-----
 
DEFINE cSucursal                CHAR(4);
 
DEFINE dFechaUltDisp            DATE;
DEFINE iMaxSecDisp, iCuantosDisp INTEGER;
DEFINE fMontoUltDisp            DECIMAL(14,2);
DEFINE cFolioSuc                CHAR(16);
DEFINE fMontoComi, fAbonoMensual, fSaldoMesAnt DECIMAL(14,2);
DEFINE iRef                     INTEGER;
DEFINE mMonto                   DECIMAL(14,2);
DEFINE dFechaUltCapitalizacion DATE;
DEFINE mMontoInteresCap, mMontoIvaIntCap, fSaldoMesActual DECIMAL(14,2);
DEFINE cUltMov                  CHAR(4);
DEFINE dFechaUltMov             DATE;
DEFINE fMontoUltMov, mMontoInteresCapMesAnt, mMontoIvaIntCapMesAnt DECIMAL(14,2);
DEFINE cNumSucursal           CHAR(4);
DEFINE mPorcIva            DECIMAL(14,2);
DEFINE mIntVencido, mIvaIntVencido, mIntMoraOrdi, mIvaIntMoraOrdi, mIntMoraCope, mIvaIntMoraCope DECIMAL(14,2);
DEFINE cMesesVencidos           INTEGER;
DEFINE cNumTarjeta              CHAR(20);
DEFINE dFechaUltPago            DATE;
DEFINE iMaxSecPago, iCuantosPagos INTEGER;
DEFINE fMontoPago               DECIMAL(14,2);
DEFINE cRefCoppel               CHAR(20);
 
DEFINE dFechaHoy                DATE;
DEFINE dFechaCapAux             DATE;
DEFINE iContador                SMALLINT;
DEFINE cBegin                   CHAR(1);
 
    DEFINE SQL_ERR            INTEGER;
    DEFINE ISAM_ERR           INTEGER;
    DEFINE ERROR_INFO         VARCHAR(80);
    DEFINE P_COD_RET          VARCHAR(6);
    DEFINE P_MENSAJE          VARCHAR(80);
 
DEFINE cSql                   CHAR(2024);
DEFINE cNombreArchivo1       CHAR(50);
DEFINE cNombreArchivo2       CHAR(50);
 
-- jom ini
DEFINE cNumRegTotal           INTEGER;
DEFINE sSaldoActTotal         DECIMAL(14,2);
DEFINE sFechadeCorte          DATE;
DEFINE fSaldoMesVencido       DECIMAL(14,2);
DEFINE fSaldoMesNoExig        DECIMAL(14,2);
DEFINE mIvaIntMoraPagado      DECIMAL(14,2);
DEFINE mIvaIntMoraTotal       DECIMAL(14,2);
-- jom fin
DEFINE var_rga                CHAR(05);
 
--   SET DEBUG FILE TO '/tmp/sp_rep_cartera_quebrantar_previo.out';
--   TRACE ON;
 
BEGIN
 
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
        DROP TABLE temp_cb_rep_cart_quebrantar;
        IF cBegin = 'S' THEN
            ROLLBACK WORK;
        END IF;
        RETURN P_COD_RET;
    END EXCEPTION;
 
LET cBegin = 'N';
 
--jom ini
LET cNumRegTotal    = 0;
LET sSaldoActTotal  = 0;
--jom fin
 
LET  cNombreArchivo1= '/pisa/CarteraQuebrantada' || LPAD(TRIM(MONTH(CURRENT::DATE)::CHAR(2)),2,'0') ||YEAR(CURRENT::DATE) || '.txt';
LET  cNombreArchivo2= '/pisa/CifrasCarteraQuebrantada' || LPAD(TRIM(MONTH(CURRENT::DATE)::CHAR(2)),2,'0') ||YEAR(CURRENT::DATE) || '.txt';
LET  cSql="";
LET  pNum_Vencidos=0;
LET  cNumSucursal = '0000';
LET  mPorcIva= 0;
LET  mIntVencido= 0;
LET  mIvaIntVencido= 0;
LET  mIntMoraOrdi= 0;
LET  mIvaIntMoraOrdi= 0;
LET  mIntMoraCope= 0;
LET  mIvaIntMoraCope= 0;
LET  fSaldoMesVencido=0;
 

    CREATE temp TABLE temp_cb_rep_cart_quebrantar
    (
    Num_Credito             CHAR(20),
    NumCte                  CHAR(20),
 
    Apellido1               CHAR(20),
    Apellido2               CHAR(20),
    Nombre1                 CHAR(20),
    Nombre2                 CHAR(20),
    FechaNac                DATE,
    Rfc                     CHAR(13),
    Curp                    CHAR(20),
 
    Sexo                    CHAR(1),
    EdoCivil                CHAR(2),
    ApellidoCasada          CHAR(26),
    Nacionalidad            CHAR(15),
    Actividad               CHAR(80),
    TipoIdentificacion      CHAR(40),
    NumIdentificacion       CHAR(30),
    Email                   CHAR(60),
 
    NumEstado               INTEGER,
    NumCiudad               INTEGER,
    Poblacion               CHAR(80),
    NumColonia              INTEGER,
    NumCalle                INTEGER,
    NumExterior             CHAR(10),
    NumInterior             CHAR(10),
 
    CodPostal               CHAR(5),
    PuntoCardinal           CHAR(1),
    Manzana                 INTEGER,
    Andador                 INTEGER,
    Etapa                   INTEGER,
    Lote                    INTEGER,
 
    Edificio                INTEGER,
    Entrada                 INTEGER,
    Departamento            CHAR(6),
    Complemento             CHAR(80),
    EntreCalles             CHAR(40),
    AntigDomic              CHAR(80),
    Telefono                CHAR(13),
    Otros                   SMALLINT,
 
    SituacionEsp            CHAR(1),
    CausaSitEsp             SMALLINT,
 
    Sector                  CHAR(2),
    LugarTrabajo            CHAR(25),
    AntigTrab               CHAR(80),
    Puesto                  CHAR(3),
    IngresoMensual          MONEY(14,2),
--Domiclio de Trabajo
    NumEstadoTrab           INTEGER,
    NumCiudadTrab           INTEGER,
    PoblacionTrab           CHAR(80),
    NumColoniaTrab          INTEGER,
    NumCalleTrab            INTEGER,
    NumExteriorTrab         CHAR(10),
    NumInteriorTrab         CHAR(10),
 
    CodPostalTrab           CHAR(5),
    PuntoCardinalTrab       CHAR(1),
    ManzanaTrab             INTEGER,
    AndadorTrab             INTEGER,
    EtapaTrab               INTEGER,
    LoteTrab                INTEGER,
 
    EdificioTrab            INTEGER,
    EntradaTrab             INTEGER,
    DepartamentoTrab        CHAR(6),
    ComplementoTrab         CHAR(80),
    EntreCallesTrab         CHAR(40),
    OtrosTrab               SMALLINT,
    TelTrab                 CHAR(13),
    ExtTrab                 CHAR(13),
 
---Segunda Parte
    Sucursal                CHAR(4),
    Fecha_Ult_Disp          DATE,
    Monto_Ult_Disp          DECIMAL (14,2),
    Monto_Comi_Ult_Disp     DECIMAL (14,2),
    Abono_Mensual_Al_Qub    DECIMAL (14,2),
    Int_Capit               DECIMAL (14,2),
    Iva_Int_Capit           DECIMAL (14,2),
    Sdo_Mes_Ant             DECIMAL (14,2),
    Sdo_Actual              DECIMAL (14,2),
    Sdo_Vencido             DECIMAL (14,2),
    Sdo_No_Exig             DECIMAL (14,2),
    Fecha_Ult_Mov           DATE,
    Tipo_Ult_Mov            CHAR(4),
    Monto_Ult_Mov           DECIMAL (14,2),
    Int_Vencido             DECIMAL (14,2),
    Iva_Int_Vencido         DECIMAL (14,2),
    Int_Mora_Ordi           DECIMAL (14,2),
    Iva_Int_Mora_Ordi       DECIMAL (14,2),
    Int_Mora_Cope           DECIMAL (14,2),
    Iva_Int_Mora_Cope       DECIMAL (14,2),
    Meses_Vencidos          INTEGER,
    Numero_Tarjeta          CHAR(20),
    --NumCliente              CHAR(20),
    ReferenciaCoppel        CHAR(20),
    feCHAReporte            DATE
    );
 
    LET P_cod_ret  = "00000";
    LET iContador  = 0;
    LET cSituacion = '';
    LET sCausa     = 0;
 
    SELECT Fecha_Hoy
    INTO dFechaHoy
    FROM bdicred:sd_fechas
    WHERE empresa = '001';
 
     BEGIN WORK;
       LET cBegin = 'S';
       DELETE FROM bdicobranza:cb_rep_cart_quebrantar_cifras WHERE feCHAReporte = DATE(CURRENT);
    COMMIT WORK;
 
     BEGIN WORK;
       DELETE FROM bdicobranza:cb_rep_cart_quebrantar WHERE feCHAReporte = DATE(CURRENT);
    COMMIT WORK;
 
    LET cBegin = 'N';
 
    FOREACH WITH HOLD
 
    SELECT DISTINCT(a.num_credito), a.numcte
    INTO cNumCredito, cNumCte
    FROM bdicred:sd_maecred a
    WHERE a.empresa= '001'
      AND status_cred = 'BT'
 
    SELECT COUNT(b.num_credito)
 INTO pNum_Vencidos
 FROM bdicred:sd_amortiza_credito b
 WHERE b.empresa= '001'
 AND b.num_credito= cNumCredito
 AND b.capital_status IN (2,7);
 
 IF pNum_Vencidos >= pPagos THEN
        LET cMesesVencidos = pNum_Vencidos;
 
   SELECT  LIMIT 1
      RPAD(TRIM(NVL(cte.apell_paterno,'')),20,' ') AS apellpaterno,       --apellido 1
      RPAD(TRIM(NVL(cte.apell_materno,'')),20,' ') AS apellmaterno,     --apellido 2
      RPAD(TRIM(NVL(cte.nombre1,'')),20,' ') AS nombre1,      -- nombre 1
      RPAD(TRIM(NVL(cte.nombre2,'')),20,' ') AS nombre2,      -- nombre 2
      RPAD(TRIM(NVL(cte.rfc,'')),13,' ')     AS rfc, -- rfc
      RPAD(TRIM(NVL(cte.apell_casada,'')),26,' ') AS apellcasada, -- apellido de casada
      RPAD(TRIM(NVL(cte.sector,'')),2,' ') AS sector, -- sector
      LPAD(TRIM(NVL(actesp.descripcion,'')),45,' ') AS actividad, --actividad o giro de negocio
 
      NVL(ctepf.fecha_nac, DATE(1)) AS anionac,    -- año de nacimiento
      RPAD(TRIM(NVL(ctepf.curp,'')),20,' ') AS curp, -- curp
      RPAD(TRIM(NVL(ctepf.sexo,'')),1,' ') AS sexo, -- sexo
      RPAD(TRIM(NVL(ctepf.estado_civil,'')),2,' ') AS edocivil, -- estado civil
      RPAD(TRIM(NVL(ctepf.numidentifi,'')),30,' ') AS numidentificacion, --numero de identificación
      --RPAD(TRIM(NVL(ctepf.email,'')),60,' ') AS email, -- correo electronico
	  rpad(TRIM(co.correo_elec),60,' ') as email,
      RPAD(TRIM(NVL(tipoidentif.descripcion,'')),40,' ') AS tipoidentificacion, -- tipo de identificación
 
      RPAD(TRIM(NVL(nac.descripcion,'')),15,' ') AS nacionalidad, -- nacionalidad
 
      RPAD(TRIM(NVL(ing.nombre_empresa,'')),25,' ') AS lugartrabajo,    -- lugar de trabajo
      NVL(ing.ingreso_mensual, 0) AS ingresomensual,     -- ingreso mensual
 
--      RPAD(TRIM(NVL(puest.descripcion,'')),30,' ') AS puesto -- descripcion puesto
      RPAD(TRIM(NVL(ing.puesto,'')),3,'0') AS puesto -- descripcion puesto
   INTO
      cApellido1, cApellido2, cNombre1, cNombre2, cRfc, cApellidoCasada,
      cSector, cActividad, dFechaNac, cCurp, cSexo, cEdoCivil, cNumIdentificacion,
      cEmail, cTipoIdentificacion, cNacionalidad, cLugarTrabajo, mIngresoMensual, cPuesto
 
   FROM  bdinteg:si_cliente cte
   LEFT OUTER JOIN bdinteg:si_actesp  actesp  ON (actesp.empresa= cte.empresa AND actesp.codigo=cte.actividad_esp)
   LEFT OUTER JOIN bdinteg:si_ctepf   ctepf   ON (ctepf.empresa=cte.empresa AND ctepf.numcte = cte.numcte)
   LEFT OUTER JOIN bdinteg:si_tipoidentif tipoidentif ON (tipoidentif.codidentif=ctepf.codidentifi)
   LEFT OUTER JOIN bdinteg:si_nacion nac  ON (nac.nacion = ctepf.nacionalidad)
          LEFT OUTER JOIN bdinteg:si_ingresos ing ON (ing.empresa=cte.empresa AND ing.numcte = cte.numcte AND ing.sec_ingreso= (SELECT MAX(ing1.sec_ingreso)
                                                                                                                                              FROM bdinteg:si_ingresos ing1
                                                                                                                                              WHERE ing1.empresa=cte.empresa
                                                                                                                                              AND ing1.numcte = cte.numcte
																																			  AND ing1.tipo_ingreso = 'T'))
	left outer join bdinteg:si_correos co on (cte.empresa = co.empresa and  cte.numcte = co.numcte
							and co.secuencia = (select max(secuencia) from  bdinteg:si_correos where empresa = co.empresa 
																			and numcte = co.numcte))
--   LEFT OUTER JOIN bdinteg:si_puestos  puest  ON (puest.puesto = ing.puesto)
   WHERE cte.empresa= pEmpresa
   AND cte.numcte= cNumCte;
 

        SELECT
            --RPAD(TRIM(NVL(edo1.nombre,'')),30,' ') AS estado, -- descripcion del estado
            dir1.estado AS estado, -- numero de estado
--            RPAD(TRIM(NVL(ciudad1.nombreciudad,'')),25,' ') AS ciudad, -- descripcion de la ciudad
            dir1.numerociudad AS ciudad, -- numero de ciudad
            NVL(zonas1.poblacionzona, '')AS poblacion,
--            NVL(zonas1.NombreZona,'')    AS colonia,
            dir1.numerocolonia AS colonia, -- numero de colonia
--            NVL(calle1.nombrecalle,'')   AS calle,
            dir1.numerocalle AS calle, -- numero de calle
            TRIM(dir1.numeroextcalle) AS numextcalle,   -- numero exterior
            TRIM(dir1.numerointcalle) AS numintecalle,  -- numero interior
            LPAD(TRIM(dir1.cod_postal),5,'0') AS cod_postal,     -- codigo postal
            RPAD(TRIM(dir1.puntocardinal),1,' ') AS puntocardinal,   -- punto cardinal
            LPAD(dir1.manzana,5,'0') AS manzana,     -- manzana
            LPAD(dir1.andador,5,'0') AS andador,     -- andador
            LPAD(dir1.etapa,5,'0')   AS etapa,     --etapa
 
            LPAD(dir1.lote,5,'0')    AS lote,       -- lote
            LPAD(dir1.edificio,5,'0') AS edificio,   --edificio
            LPAD(dir1.entrada,5,'0') AS entrada,   -- entrada
            RPAD(TRIM(dir1.departamento),6,' ') AS departamento,     -- departamento
            RPAD(TRIM(dir1.observaciones),80,' ') AS complemento,  --   complemento
            RPAD(TRIM(dir1.entre_calles),40,' ') AS entre_calles,    -- entre calles
 
            LPAD(dir1.otros,2,'0') AS otros,     -- otros
         --   RPAD(NVL(dir1.telefono1,''), 13, ' ') AS Telefono,
         --   RPAD(NVL(dir1.telefono3,''), 13, ' ') AS TelTrab,
         --   RPAD(NVL(dir1.extension,''), 13, ' ') AS ExtTrab,
 
            --Domiclio de Trabajo
--            RPAD(TRIM(edo2.nombre),30,' ') AS estadoTrab, -- descripcion del estado
            dir2.estado AS estadoTrab, --Numero de estado
--            RPAD(TRIM(ciudad2.nombreciudad),25,' ') AS ciudadTrab, -- descripcion de la ciudad
            dir2.numerociudad AS ciudad, -- numero de ciudad
            NVL(zonas2.poblacionzona, '')AS poblacionTrab,
--            NVL(zonas2.NombreZona,'')    AS coloniaTrab,
            dir2.numerocolonia AS colonia, -- numero de colonia
--            NVL(calle2.nombrecalle,'')   AS calleTrab,
            dir2.numerocalle AS calle, -- numero de calle
            TRIM(dir2.numeroextcalle) AS numextcalleTrab,   -- numero exterior
            TRIM(dir2.numerointcalle) AS numintecalleTrab,  -- numero interior
            LPAD(TRIM(dir2.cod_postal),5,'0') AS cod_postalTrab,     -- codigo postal
            RPAD(TRIM(dir2.puntocardinal),1,' ') AS puntocardinalTrab,   -- punto cardinal
            LPAD(dir2.manzana,5,'0') AS manzanaTrab,     -- manzana
            LPAD(dir2.andador,5,'0') AS andadorTrab,     -- andador
            LPAD(dir2.etapa,5,'0')   AS etapaTrab,     --etapa
 
            LPAD(dir2.lote,5,'0')    AS loteTrab,       -- lote
            LPAD(dir2.edificio,5,'0') AS edificioTrab,   --edificio
            LPAD(dir2.entrada,5,'0') AS entradaTrab,   -- entrada
            RPAD(TRIM(dir2.departamento),6,' ') AS departamentoTrab,     -- departamento
            RPAD(TRIM(dir2.observaciones),80,' ') AS complementoTrab,  --   complemento
            RPAD(TRIM(dir2.entre_calles),40,' ') AS entre_callesTrab,    -- entre calles
 
            LPAD(dir2.otros,2,'0') AS otrosTrab
        INTO
            cNumEstado,     cNumCiudad,         cPoblacion,     cNumColonia,       cNumCalle,         cNumExterior,
            cNumInterior,   cCodPostal,         cPuntoCardinal, iManzana,       iAndador,       iEtapa,
            iLote,          iEdificio,          iEntrada,       cDepartamento,  cComplemento,   cEntreCalles,
            sOtros,     --    cTelefono,          cTelTrab,       cExtTrab,
 
            cNumEstadoTrab,     cNumCiudadTrab,     cPoblacionTrab,     cNumColoniaTrab,    cNumCalleTrab,      cNumExteriorTrab,
            cNumInteriorTrab,   cCodPostalTrab,     cPuntoCardinalTrab, iManzanaTrab,       iAndadorTrab,       iEtapaTrab,
            iLoteTrab,          iEdificioTrab,      iEntradaTrab,       cDepartamentoTrab,  cComplementoTrab,   cEntreCallesTrab,
            iOtrosTrab
        FROM bdinteg:si_cliente cte
            LEFT OUTER JOIN bdinteg:si_direcciones dir1        ON (dir1.numcte = cte.numcte AND dir1.tipo_dir  = '1')
--            LEFT OUTER JOIN bdinteg:si_estados     edo1        ON (edo1.estado = dir1.estado)
--            LEFT OUTER JOIN bdinteg:si_catciudades ciudad1     ON (ciudad1.numerociudad = dir1.numerociudad)
            LEFT OUTER JOIN bdinteg:si_catzonas    zonas1      ON (dir1.numerociudad = zonas1.numerociudad AND dir1.numerocolonia = zonas1.numerocolonia)
--            LEFT OUTER JOIN bdinteg:si_catcalles   calle1      ON (dir1.numerocalle  = calle1.numerocalle)
            LEFT OUTER JOIN bdinteg:si_direcciones dir2        ON (dir2.numcte = cte.numcte AND dir2.tipo_dir = '2')
--            LEFT OUTER JOIN bdinteg:si_estados     edo2        ON (edo2.estado = dir2.estado)
--            LEFT OUTER JOIN bdinteg:si_catciudades ciudad2     ON (ciudad2.numerociudad = dir2.numerociudad)
            LEFT OUTER JOIN bdinteg:si_catzonas    zonas2      ON (dir2.numerociudad = zonas2.numerociudad AND dir2.numerocolonia = zonas2.numerocolonia)
--            LEFT OUTER JOIN bdinteg:si_catcalles   calle2      ON (dir2.numerocalle  = calle2.numerocalle)
        WHERE cte.NumCte     = cNumCte
        --AND dir1.tipo_dir  = '1'
        AND NVL(dir1.secuencia,0) = (   SELECT NVL(MAX(secuencia),0)
                                        FROM bdinteg:si_direcciones dir
                                        WHERE dir.tipo_dir = dir1.tipo_dir AND dir.numcte = cNumCte )
        --AND dir2.tipo_dir = '2'
        AND NVL(dir2.secuencia,0) = (   SELECT NVL(MAX(secuencia),0)
                                        FROM bdinteg:si_direcciones dir
                                        WHERE dir.tipo_dir = dir2.tipo_dir AND dir.numcte = cNumCte );
										
		select  nvl(rpad(TRIM(telefono),13,' '),' ') 
			into  cTelefono      
		from bdinteg:si_telefonos_actual 
		where numcte = cNumCte 
			and tipo_tel = 1 and cofetel ='V'
			and secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
													where numcte = cNumCte and tipo_tel = 1 and cofetel ='V');
										
		select  nvl(rpad(TRIM(telefono),13,' '),' ') ,RPAD(NVL(extension,''), 13, ' ')
			into      cTelTrab,       cExtTrab 
		from bdinteg:si_telefonos_actual 
		where numcte = cNumCte 
			and tipo_tel = 3 and cofetel ='V'
			and secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
													where numcte = cNumCte and tipo_tel = 3 and cofetel ='V');
 
        -- Se obtiene el elemento respondido en la pregunta tiempo de residencia
        SELECT elemento
        INTO sElementoRes
        FROM bdisolic:ss_detalle_scoring
        WHERE num_solicitud= cNumCredito
        AND seccion= 2
        AND grupo  = 6;
 
        -- Se obtiene la descripcion del elemento respondido en la pregunta tiempo de residencia
        SELECT descripcion
        INTO cDescripcion
        FROM bdisolic:ss_scoring_element
        WHERE seccion = 2
        AND grupo = 6
        AND elemento = sElementoRes;
 
/*
                    --LET V_fechaantiguedadtrabajo    = '01/01/1900'::DATE;
                    LET iAuxElemento = 0;
                    SELECT elemento
                    INTO iAuxElemento
                    FROM bdisolic:ss_detalle_scoring a
                    WHERE grupo = 8
                    AND seccion = 2
                    AND tpo_persona = '01'
                    AND num_solicitud = V_NumSolicitud;
 
                    IF iAuxElemento =  1 THEN
                        LET iAniosHabita = 10;
                    ELIF iAuxElemento =  2 THEN
                        LET iAniosHabita = 5;
                    ELIF iAuxElemento =  3 THEN
                        LET iAniosHabita = 2;
                    ELIF iAuxElemento =  4 THEN
                        LET iAniosHabita = 1;
                    ELIF iAuxElemento =  5 THEN
                        LET iAniosHabita = 0;
                    END IF;
 
                    IF iAniosHabita = 0 THEN
                        LET V_fechaantiguedadtrabajo  = dFechaSolCred;
                    ELSE
                        LET V_fechaantiguedadtrabajo  = dFechaSolCred - iAniosHabita units YEAR;
                    END IF;
 
*/
        --  Se obtiene el elemento respondido en la pregunta Tiempo de permanencia en la ocupacion actual
        SELECT elemento
        INTO sElemResTrabajo
        FROM bdisolic:ss_detalle_scoring
        WHERE num_solicitud = cNumCredito
        AND seccion= 2
        AND grupo  = 8 ;
 
        -- Se obtiene la descripcion del elemento respondido  en la pregunta Tiempo de permanencia en la ocupacion actual
        SELECT descripcion
        INTO cDescripPermTrabajo
        FROM bdisolic:ss_scoring_element
        WHERE seccion=2
        AND grupo=8
        AND elemento= sElemResTrabajo;
 
----SEGUNDA PARTE DE CAMPOS
        SELECT sucursal
        INTO cSucursal
        FROM bdisolic:ss_solicitudes
        WHERE num_solicitud = cNumCredito;
 
        SELECT NVL(MAX(fecha_mov), DATE(1)),  NVL(MAX(secuencia),0), COUNT(*)
        INTO dFechaUltDisp, iMaxSecDisp, iCuantosDisp
        FROM bdicred:sd_movhis a, bdicred:sd_transfun b, bdinteg:si_transacc c
        WHERE a.empresa   = pEmpresa
        AND a.num_credito = cNumCredito
        AND a.codigo_fun IN ('002')
        AND a.reversado = 'N'
        AND b.codigo_fun = a.codigo_fun
        AND b.codigo_ref = a.codigo_ref
        AND c.numero = b.transacc
        AND c.sistema ='06'
        AND c.tipo_tran IN ('00','01','02','30');
        --AND a.fecha_mov <= pFechaQuebranto;
 
        IF iCuantosDisp > 0 THEN
            SELECT monto, folio_suc
            INTO fMontoUltDisp, cFolioSuc
            FROM bdicred:sd_movhis
            WHERE empresa = pEmpresa
            AND secuencia = iMaxSecDisp
            AND num_credito = cNumCredito;
 
            SELECT NVL(MAX(Monto),0)
            INTO fMontoComi
            FROM bdicred:sd_movhis
            WHERE folio_suc = cFolioSuc
            AND codigo_fun = '339';
        ELSE
            LET fMontoUltDisp = 0;
            LET fMontoComi    = 0;
        END IF;
 
        LET fAbonoMensual = 0;
        LET fSaldoMesAnt  = 0;
        --LET fSaldoMesAnt_2 = 0;
 
        FOREACH
        SELECT NVL(monto_financiado,0), --NVL(sdo_capinsoluto,0),
               --NVL(sdo_capital,0) + NVL(monto_vencido,0) + NVL(mto_venc_trasp,0) + NVL(sdo_no_exig, 0) + NVL(cap_tras_no_venci,0)
               NVL(sdo_capital,0) + NVL(monto_vencido,0) + NVL(mto_venc_trasp,0) + NVL(cap_tras_no_venci,0)
        INTO fAbonoMensual, fSaldoMesAnt --, fSaldoMesAnt_2
        FROM bdicred:sd_maesdoshist
        WHERE empresa= pEmpresa
  AND num_credito = cNumCredito
        AND fecha =
             (
                SELECT NVL(MAX(fecha), dFechaHoy)
                FROM bdicred:sd_maesdoshist
                WHERE fecha < mdy(MONTH(dFechaHoy),20,YEAR(dFechaHoy))
                AND empresa= pEmpresa
    AND num_credito = cNumCredito
             )
 
        END FOREACH;
 
        LET mMontoInteresCap = 0;
        LET mMontoIvaIntCap  = 0;
        LET dFechaUltCapitalizacion = dFechaHoy;
 
        FOREACH
        SELECT codigo_ref, monto, fecha_mov
        INTO iRef, mMonto, dFechaUltCapitalizacion
        FROM bdicred:sd_movhis
        WHERE empresa   = pEmpresa
        AND num_credito = cNumCredito
        AND codigo_fun  = '605'
        AND codigo_ref IN ('2', '3')
        AND reversado   = 'N'
        AND fecha_mov =
                (
                SELECT NVL(MAX(fecha_mov), dFechaHoy)
                FROM bdicred:sd_movhis
                WHERE empresa = pEmpresa
                AND num_credito = cNumCredito
                AND codigo_fun  = '605'
                AND codigo_ref IN ('2', '3')
                AND reversado = 'N'
                --AND fecha_mov <= pFechaQuebranto
                )
            IF iRef = '2' THEN
                LET mMontoInteresCap = mMonto;
            ELIF iRef = '3' THEN
                LET mMontoIvaIntCap  = mMonto;
            END IF;
 
        END FOREACH;
 
        SELECT --sdo_capinsoluto,
            --NVL(MAX(NVL(b.sdo_capital,0) + NVL(b.monto_vencido,0) + NVL(b.mto_venc_trasp,0) + NVL(b.sdo_no_exig, 0) + NVL(b.cap_tras_no_venci,0)),0)
            NVL(sum(NVL(b.sdo_capital,0) + NVL(b.monto_vencido,0) + NVL(b.mto_venc_trasp,0) + NVL(b.cap_tras_no_venci,0)),0),
            NVL(sum(NVL(b.monto_vencido,0) + NVL(b.mto_venc_trasp,0)),0),
            NVL(sum(NVL(b.sdo_capital,0) + NVL(b.cap_tras_no_venci,0)),0)
        INTO fSaldoMesActual , --, fSaldoMesActual_2
             fSaldoMesVencido,
             fSaldoMesNoExig
        FROM bdicred:sd_maesdos b
  WHERE empresa= pEmpresa
        AND num_credito = cNumCredito;
 
        SELECT NVL(MAX(fecha_mov), DATE(1)), MAX(SECUENCIA), COUNT(*)
        INTO dFechaUltPago, iMaxSecPago, iCuantosPagos
        FROM bdicred:sd_movhis
        WHERE num_credito = cNumCredito
        AND empresa = pEmpresa
        AND reversado = 'N'
        AND (
            (codigo_fun IN ('033', '334') AND codigo_ref = 1)
            OR
            (codigo_fun = '342' AND codigo_ref IN (1,2) )
            );
 
        IF dFechaUltPago > dFechaUltDisp THEN
            LET cUltMov      = 'PAGO';
            LET dFechaUltMov = dFechaUltPago;
        ELSE
            IF dFechaUltPago = dFechaUltDisp THEN
                IF dFechaUltPago = DATE(1) THEN
                    LET cUltMov      = ''; --'NO hubo nada'
                    LET dFechaUltMov = dFechaUltPago;
                ELSE
                    IF iMaxSecDisp > iMaxSecPago THEN
                        LET cUltMov      = 'DISP';
                        LET dFechaUltMov = dFechaUltDisp;
                    ELSE
                        LET cUltMov      = 'PAGO';
                        LET dFechaUltMov = dFechaUltPago;
                    END IF;
                END IF;
            ELSE
                LET cUltMov      = 'DISP';
                LET dFechaUltMov = dFechaUltDisp;
            END IF;
        END IF;
 
        IF cUltMov = 'PAGO' THEN
 
            SELECT monto
            INTO fMontoPago
            FROM bdicred:sd_movhis
            WHERE empresa = pEmpresa
            AND secuencia = iMaxSecPago
            AND num_credito = cNumCredito;
 
            LET fMontoUltMov = NVL(fMontoPago,0);
 
        ELIF cUltMov = 'DISP' THEN
            LET fMontoUltMov = fMontoUltDisp;
        ELSE
            LET fMontoUltMov = 0;
        END IF;
 
        LET mMontoInteresCapMesAnt = 0;
        LET mMontoIvaIntCapMesAnt  = 0;
 
        SELECT NVL(MAX(fecha_mov),dFechaHoy)
        INTO dFechaCapAux
        FROM bdicred:sd_movhis
        WHERE empresa = pEmpresa
        AND num_credito = cNumCredito
        AND codigo_fun  = '605'
        AND codigo_ref IN ('2', '3')
        AND reversado = 'N'
        AND fecha_mov < NVL(dFechaUltCapitalizacion, dFechaHoy);
 
        FOREACH
        SELECT codigo_ref, monto
        INTO iRef, mMonto
        FROM bdicred:sd_movhis
        WHERE empresa = pEmpresa
        AND num_credito = cNumCredito
        AND codigo_fun  = '605'
        AND codigo_ref IN ('2', '3')
        AND reversado = 'N'
        AND fecha_mov = dFechaCapAux
 
/*            (
            SELECT NVL(MAX(fecha_mov),dFechaHoy)
            --INTO dFechaCapAux
            FROM bdicred:sd_movhis
            WHERE empresa = pEmpresa
            AND num_credito = cNumCredito
            AND codigo_fun  = '605'
            AND codigo_ref IN ('2', '3')
            AND reversado = 'N'
            AND fecha_mov < NVL(dFechaUltCapitalizacion, dFechaHoy)
            )
*/
             IF iRef = '2' THEN
                LET mMontoInteresCap = mMontoInteresCap + mMonto;
             ELIF iRef = '3' THEN
                LET mMontoIvaIntCap  = mMontoIvaIntCap + mMonto;
             END IF;
 
--            IF iRef = '2' THEN
--                LET mMontoInteresCapMesAnt = mMonto;
--            ELIF iRef = '3' THEN
--                LET mMontoIvaIntCapMesAnt  = mMonto;
--            END IF;
        END FOREACH;
 
        --- Se obtiene la Sucursal del Credito
       SELECT  sucursal
       INTO  cNumSucursal
       FROM sd_maecred b
       WHERE b.empresa = pempresa
       AND b.num_credito = cNumCredito;
 
      -- Se  Obtiene el iva correspondiente a la sucursal que se asoció al Credito
        SELECT iva
        INTO mPorcIva
        FROM bdinteg:si_sucursales
        WHERE empresa = pempresa
 AND sucursal = cNumSucursal;
 
        -- Se obtiene los Intereses orden
        SELECT d.int_tra_no_exig
        INTO mIntVencido
        FROM bdicred:sd_maesdos d
        WHERE d.empresa= pEmpresa
        AND d.num_credito= cNumCredito;
 
       --  Se obtiene el Iva de los Intereses Vigentes
       SELECT Sum(iva_debe - iva_pagado)
       INTO mIvaIntVencido
       FROM sd_amortiza_credito d
       WHERE d.empresa = pEmpresa
       AND d.num_credito = cNumCredito
       AND capital_status <> '5';
 
 
 
 -- Se obtiene el Iva de Intereses Moratorio pagado
     SELECT NVL(SUM(mora_iva_debe+((mora_provi_ordi+mora_provi_cope) * mPorcIva) - mora_iva_pagado),0)
     INTO mIvaIntMoraTotal
     FROM sd_amortiza_credito
     WHERE num_credito = cNumCredito
     AND empresa = pempresa
     AND capital_status IN ("2","7")
     AND (mora_iva_debe - mora_iva_pagado + ((mora_provi_ordi+mora_provi_cope) * mPorcIva)) > 0;
 

      -- Se obtiene el Interes Moratorio Copete
      -- SELECT (SUM(mora_sdo_cope+mora_provi_cope-mora_sdo_cope_pag)) -- este es el correcto se deja intencional el erroneo
      -- para que coincida con los manejados actualmente en las consultas
      SELECT NVL(SUM(mora_sdo_cope + mora_provi_cope - mora_sdo_cope_pag),0),
             NVL(SUM((mora_sdo_cope + mora_provi_cope - mora_sdo_cope_pag) * 0.15),0),
             NVL(SUM(mora_sdo_ordi + mora_provi_ordi - mora_sdo_ordi_pag),0),
             NVL(SUM((mora_sdo_ordi + mora_provi_ordi - mora_sdo_ordi_pag) * 0.15),0)
      INTO mIntMoraCope,
           mIvaIntMoraCope,
           mIntMoraOrdi,
           mIvaIntMoraOrdi
      FROM sd_amortiza_credito
      WHERE  empresa = pempresa
      AND num_credito = cNumCredito
      AND capital_status IN ("2","7");
--      AND (mora_sdo_cope - mora_sdo_cope_pag) > 0 ;
 
      IF  mIntMoraCope IS NULL OR  mIntMoraCope < 0 THEN
            LET mIntMoraCope = 0;
      END IF;
 
      IF  mIntMoraOrdi IS NULL OR  mIntMoraOrdi < 0 THEN
            LET mIntMoraOrdi = 0;
      END IF;
 

      IF (mIntMoraCope + mIntMoraOrdi) > 0 THEN
        LET mIvaIntMoraTotal = (mIvaIntMoraCope + mIvaIntMoraOrdi) - mIvaIntMoraTotal;
      ELSE
        LET mIvaIntMoraTotal = 0;
      END IF;
 
      IF (mIvaIntMoraCope >= mIvaIntMoraTotal) THEN
         LET mIvaIntMoraCope = mIvaIntMoraCope - mIvaIntMoraTotal;
         LET mIvaIntMoraTotal = 0;
      ELSE
         LET mIvaIntMoraTotal = mIvaIntMoraTotal - mIvaIntMoraCope;
         LET mIvaIntMoraCope = 0;
      END IF;
 

      IF (mIvaIntMoraOrdi >= mIvaIntMoraTotal) THEN
         LET mIvaIntMoraOrdi = mIvaIntMoraOrdi - mIvaIntMoraTotal;
         LET mIvaIntMoraTotal = 0;
      ELSE
         LET mIvaIntMoraTotal = mIvaIntMoraTotal - mIvaIntMoraOrdi;
         LET mIvaIntMoraOrdi = 0;
      END IF;
 

        SELECT LIMIT 1 num_tarjeta
        INTO cNumTarjeta
        FROM bdicred:sd_tarjeta
        WHERE empresa = pEmpresa
        AND tipo_tarjeta = 'T'
        AND status_tar = 'A'
        AND num_credito  = cNumCredito;
 
        IF cNumTarjeta is null THEN
            SELECT LIMIT 1 num_tarjeta
            INTO cNumTarjeta
            FROM bdicred:sd_tarjeta
            WHERE empresa = pEmpresa
            AND tipo_tarjeta = 'T'
            AND num_credito  = cNumCredito
            AND secuencia =
                (
                SELECT NVL(MAX(secuencia),0)
                FROM bdicred:sd_tarjeta
                WHERE empresa = pEmpresa
                AND tipo_tarjeta = 'T'
                AND num_credito  = cNumCredito
                );
        END IF;
 
        LET cNumTarjeta = NVL(cNumTarjeta, '');
 
        LET cRefCoppel = '';
        FOREACH
        SELECT numcte_ref
        INTO cRefCoppel
        FROM bdinteg:si_cliente
        WHERE NumCte = cNumCte
        END FOREACH;
 
        INSERT INTO Temp_cb_rep_cart_quebrantar
        (   Num_Credito,    NumCte,
            Apellido1,      Apellido2,          Nombre1,            Nombre2,            Rfc        ,    ApellidoCasada,
            Sector,         FechaNac,           Curp,               Sexo,               EdoCivil   ,    NumIdentificacion,
            Email,          TipoIdentificacion, Nacionalidad,
 
            NumEstado,      NumCiudad,          Poblacion,          NumColonia,         NumCalle,       NumExterior,
            NumInterior,    CodPostal,          PuntoCardinal,      Manzana,            Andador,        Etapa      ,
            Lote,           Edificio,           Entrada,            Departamento,       Complemento,    EntreCalles,
            Otros,          SituacionEsp,       CausaSitEsp,
 
            IngresoMensual, Puesto,             LugarTrabajo,       Telefono,           TelTrab,        ExtTrab,
            AntigDomic,     AntigTrab,          Actividad,
 
            NumEstadoTrab,  NumCiudadTrab,      PoblacionTrab,      NumColoniaTrab,     NumCalleTrab,   NumExteriorTrab,
            NumInteriorTrab,CodPostalTrab,      PuntoCardinalTrab,  ManzanaTrab,        AndadorTrab,    EtapaTrab,
            LoteTrab,       EdificioTrab,       EntradaTrab,        DepartamentoTrab,   ComplementoTrab,EntreCallesTrab,
            OtrosTrab,
 
            Sucursal,               Fecha_Ult_Disp,         Monto_Ult_Disp,
            Monto_Comi_Ult_Disp ,   Abono_Mensual_Al_Qub,   Int_Capit,          Iva_Int_Capit ,
            Sdo_Mes_Ant,            Sdo_Actual          ,   Sdo_Vencido,        Sdo_No_Exig,        Fecha_Ult_Mov,      Tipo_Ult_Mov  ,
            Monto_Ult_Mov,          Int_Vencido,   Iva_Int_Vencido ,
            Int_Mora_Ordi, Iva_Int_Mora_Ordi ,  Int_Mora_Cope , Iva_Int_Mora_Cope , Meses_Vencidos, Numero_Tarjeta,
            --NumCliente   ,
           ReferenciaCoppel, feCHAReporte
        )
        VALUES
        (   cNumCredito,        cNumCte,
            cApellido1,         cApellido2,         cNombre1,           cNombre2,           cRfc,               cApellidoCasada,
            cSector,            dFechaNac,          cCurp,              cSexo,              cEdoCivil,          cNumIdentificacion,
            cEmail,             cTipoIdentificacion,cNacionalidad,
 
            cNumEstado,         cNumCiudad,         cPoblacion,         cNumColonia,           cNumCalle,             cNumExterior,
            cNumInterior,       cCodPostal,         cPuntoCardinal,     iManzana,           iAndador,           iEtapa,
            iLote,              iEdificio,          iEntrada,           cDepartamento,      cComplemento,       cEntreCalles,
            sOtros,             cSituacion,         sCausa,
 
            mIngresoMensual,    cPuesto,            cLugarTrabajo,      cTelefono,          cTelTrab,           cExtTrab,
            cDescripcion,       cDescripPermTrabajo,cActividad,
 
            cNumEstadoTrab,     cNumCiudadTrab,     cPoblacionTrab,     cNumColoniaTrab,    cNumCalleTrab,      cNumExteriorTrab,
            cNumInteriorTrab,   cCodPostalTrab,     cPuntoCardinalTrab, iManzanaTrab,       iAndadorTrab,       iEtapaTrab,
            iLoteTrab,          iEdificioTrab,      iEntradaTrab,       cDepartamentoTrab,  cComplementoTrab,   cEntreCallesTrab,
            iOtrosTrab,
----
            cSucursal,              dFechaUltDisp,          fMontoUltDisp,
            fMontoComi,             fAbonoMensual,          mMontoInteresCap,       mMontoIvaIntCap,
            fSaldoMesAnt,           fSaldoMesActual,        fSaldoMesVencido,       fSaldoMesNoExig,    dFechaUltMov,           cUltMov,
            fMontoUltMov,           
            mIntVencido, mIvaIntVencido , mIntMoraOrdi , mIvaIntMoraOrdi, mIntMoraCope,
             mIvaIntMoraCope , cMesesVencidos, cNumTarjeta,
            --cNumCte,
            cRefCoppel, CURRENT
        );
-- jom ini
        LET cNumRegTotal = cNumRegTotal + 1;
        LET sSaldoActTotal = sSaldoActTotal + fSaldoMesActual;
 
--        upDATE sd_maecred 
--           set id_unidad_prod = 1
--        WHERE empresa = pEmpresa
--          AND num_credito = cNumCredito;
-- jom fin
 
--        LET iContador = iContador + 1;
--        IF iContador = 500 THEN
--            BEGIN WORK;
--            LET cBegin = 'S';
--            INSERT INTO bdicobranza:cb_rep_cart_quebrantar
--            SELECT * FROM Temp_cb_rep_cart_quebrantar;
--            DELETE Temp_cb_rep_cart_quebrantar;
--            COMMIT WORK;
--            LET iContador = 0;
--        END IF; 
 
 END IF;
    END FOREACH;
 
    INSERT INTO bdicobranza:cb_rep_cart_quebrantar_cifras VALUES (cNumRegTotal,sSaldoActTotal,CURRENT);
 
--    IF iContador > 0 THEN
--        BEGIN WORK;
    INSERT INTO bdicobranza:cb_rep_cart_quebrantar
    SELECT * FROM Temp_cb_rep_cart_quebrantar;
--        COMMIT WORK;
--    END IF;
 
-- para Generar el archivo de Salida de Cartera Quebrantada.
 
              LET cSql = "";
              LET cSql = ' UNLOAD TO ' || '''/pisa/CarteraQuebrantadaRegistros.unl''' || ' DELIMITER ' || '''"|"''';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  ' SELECT ' ;
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.Num_Credito,' || '''" "''' || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.NumCte,' || '''" "''' || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a. Apellido1,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a.Apellido2,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a.Nombre1,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a.Nombre2,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.FechaNac,DATE"("1")"")", ' ;
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a.Rfc,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a.Curp,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.Sexo,' || '''" "''' || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a.EdoCivil,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a.ApellidoCasada,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a.Nacionalidad,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a.Actividad,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a.TipoIdentificacion,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a.NumIdentificacion,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a.Email,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.NumEstado,0")", ';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.NumCiudad,0")", ';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a.Poblacion,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.NumColonia,0")", ';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.NumCalle,0")", ';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a.NumExterior,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a.NumInterior,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a.CodPostal,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a.PuntoCardinal,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.Manzana,0")", ';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.Andador,0")", ';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.Etapa,0")", ';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.Lote,0")", ';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.Edificio,0")", ';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.Entrada,0")", ';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a.Departamento,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a.Complemento,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a.EntreCalles,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a.AntigDomic,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a.Telefono,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.Otros,0")", ';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a.SituacionEsp,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.CausaSitEsp,0")", ';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a.Sector,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a.LugarTrabajo,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a.AntigTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a.Puesto,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.IngresoMensual,0")", ';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.NumEstadoTrab,0")", ';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.NumCiudadTrab,0")", ';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a.PoblacionTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.NumColoniaTrab,0")", ';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.NumCalleTrab,0")", ';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a.NumExteriorTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a.NumInteriorTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a.CodPostalTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a.PuntoCardinalTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.ManzanaTrab,0")", ';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.AndadorTrab,0")", ';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.EtapaTrab,0")", ';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.LoteTrab,0")", ';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.EdificioTrab,0")", ';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.EntradaTrab,0")", ';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a.DepartamentoTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a.ComplementoTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a.EntreCallesTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.OtrosTrab,0")", ';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a.TelTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a.ExtTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a.sucursal,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.Fecha_Ult_Disp,DATE"("1")"")", ' ;
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.Monto_Ult_Disp,0")", ';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.Monto_Comi_Ult_Disp,0")", ';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.Abono_Mensual_Al_Qub,0")", ';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.Int_Capit,0")", ';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.Iva_Int_Capit,0")", ';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.Sdo_Mes_Ant,0")", ';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.Sdo_Actual,0")", ';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.Sdo_Vencido,0")", ';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.Fecha_Ult_Mov,DATE"("1")"")", ' ;
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a.Tipo_Ult_Mov,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.Monto_Ult_Mov,0")", ';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.Int_Vencido,0")", ';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.Iva_Int_Vencido,0")", ';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.Int_Mora_Ordi,0")", ';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.Iva_Int_Mora_Ordi,0")", ';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.Int_Mora_Cope,0")", ';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.Iva_Int_Mora_Cope,0")", ';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("a.meses_vencidos,0")", ';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a.Numero_Tarjeta,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =  '  NVL"("replace"("replace"("a.ReferenciaCoppel,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")"';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
              LET cSql =' FROM bdicobranza:cb_rep_cart_quebrantar a WHERE a.feCHAReporte = DATE"("CURRENT")"'||''';''';
              CALL sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) RETURNING var_rga;
 
              LET cSql = '';
              LET cSql = 'dbaccess bdicred /pisa/CarteraQuebrantadaQuerys.sql';
              SYSTEM cSql;
 
              LET cSql = "sed 's/|$//g' /pisa/CarteraQuebrantadaRegistros.unl > " || cNombreArchivo1;
              SYSTEM cSql;
 
              LET cSql = '';
 
            -- cifras de control
            LET cSql = 'echo "UNLOAD TO ' || '''/pisa/CarteraQuebrantadaCifras.unl''' || ' DELIMITER ' || '''|'''  ||
                                ' SELECT ' ||
                                'a.Totalregistros, ' ||
                                'a.Saldoactual_total, ' ||
                                'a.feCHAReporte ' ||
                                ' FROM bdicobranza:cb_rep_cart_quebrantar_cifras a WHERE a.feCHAReporte = DATE(CURRENT) ' ||
                                ' " > /pisa/CarteraQuebrantadaQuerysCifras.sql';
              SYSTEM cSql;
 
              LET cSql = '';
              LET cSql = 'dbaccess bdicred /pisa/CarteraQuebrantadaQuerysCifras.sql';
              SYSTEM cSql;
 
              LET cSql = "sed 's/|$//g' /pisa/CarteraQuebrantadaCifras.unl > " || cNombreArchivo2;
              SYSTEM cSql;
 
              LET cSql = '';
 
             LET cSQL = 'rm /pisa/CarteraQuebrantadaRegistros.unl /pisa/CarteraQuebrantadaQuerysCifras.sql /pisa/CarteraQuebrantadaQuerys.sql /pisa/CarteraQuebrantadaCifras.unl';
              SYSTEM cSql;
              LET cSql = '';
 
     LET cSql = "scp " || TRIM(cNombreArchivo1) || " sysbancartera@10.36.193.35:/sysx/progs/archivoscartera";
              SYSTEM cSql;
              LET cNombreArchivo1 = "";
 
              LET cSql = '';
     LET cSql = "scp " || TRIM(cNombreArchivo2) || " sysbancartera@10.36.193.35:/sysx/progs/archivoscartera";
              SYSTEM cSql;
             LET cNombreArchivo2 = "";
              
    LET P_COD_RET = '000000';
    LET cSql = '';
 

    RETURN P_COD_RET;
 
END;
END PROCEDURE;