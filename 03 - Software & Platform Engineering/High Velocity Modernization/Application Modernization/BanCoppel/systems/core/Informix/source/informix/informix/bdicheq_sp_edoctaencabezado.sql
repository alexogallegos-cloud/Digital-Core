CREATE PROCEDURE "informix".sp_edoctaencabezado( pempresa CHAR(3),
                                                 pcuenta  CHAR(20),
                                                 paniomes CHAR(6),
                                                 ptipo    CHAR(1) )
                                                 
RETURNING CHAR(5), CHAR(45), CHAR(10), CHAR(16), CHAR(18), DATE, DATE, MONEY(14,2), MONEY(14,2), MONEY(14,2), MONEY(14,2), MONEY(14,2),
          MONEY(14,2), MONEY(14,2), MONEY(14,2), MONEY(14,2), MONEY(14,2), SMALLINT, DECIMAL(9,6), CHAR(20), CHAR(107), CHAR(10),CHAR(10), CHAR(30), 
          CHAR(30), CHAR(30), CHAR(30), CHAR(5), CHAR(13), CHAR(20), DATE, CHAR(40), MONEY(14,2), MONEY(16,2), DECIMAL(9,6), MONEY(16,2), SMALLINT;
    
    DEFINE vcodret              CHAR(5);
    DEFINE vcodret2             CHAR(5);
    DEFINE vcodret3             CHAR(50);
    DEFINE cCodPostal           CHAR(5);
    DEFINE cNumExt              CHAR(10);
    DEFINE cNumInt              CHAR(10);
    DEFINE cNumProducto         CHAR(10);
    DEFINE cRFC                 CHAR(13);
    DEFINE cNumTarjeta          CHAR(16);
    DEFINE cClabe               CHAR(18);
    DEFINE cNumcte              CHAR(20);
    DEFINE cCurp                CHAR(20);
    DEFINE cNomCalle            CHAR(30);
    DEFINE cNomColonia          CHAR(30);
    DEFINE cNomCiudad           CHAR(30);
    DEFINE cNomEstado           CHAR(30);
    DEFINE cNomSucursal         CHAR(40);
    DEFINE cProducto            CHAR(45);
    DEFINE cNomcte              CHAR(107);
    DEFINE dFechaini            DATE;
    DEFINE dFechafin            DATE;
    DEFINE dFechaAlta           DATE;
    DEFINE mSaldoAnterior       MONEY(14,2);
    DEFINE mDepositos           MONEY(14,2);
    DEFINE mRetiros             MONEY(14,2);
    DEFINE mInteresesPagados    MONEY(14,2);
    DEFINE mOtrosCargos         MONEY(14,2);
    DEFINE mIvaOtrosCargos      MONEY(14,2);
    DEFINE mSaldoCorte          MONEY(14,2);
    DEFINE mAux1                MONEY(14,2);
    DEFINE mSaldoPromedio       MONEY(14,2);
    DEFINE mRetencionIsr        MONEY(14,2);
    DEFINE mInteresesNetos      MONEY(14,2);
    DEFINE dTasaBruta           DECIMAL(9,6);
    DEFINE iDias                SMALLINT;
    DEFINE vsec_dir             SMALLINT;
    DEFINE vsqlerr              INTEGER;
    DEFINE visamerr             INTEGER;
    DEFINE vdescerr             CHAR(50);
    DEFINE v_mes                CHAR(2);
    DEFINE v_mes2               CHAR(2);
    DEFINE mSaldoRet            MONEY(14,2);
    DEFINE cTipoPersona         CHAR(2);
    DEFINE cFech_param_old      CHAR(10);
    DEFINE mTotOtrosCargos      MONEY(16,2);
    DEFINE mGat                 DECIMAL(9,6);
    DEFINE mTotRetiros          MONEY(16,2);
    DEFINE iFlagGrafica         SMALLINT;
    DEFINE cAnyomes             CHAR(6);
	DEFINE cRFC_alterno         CHAR(13);
	DEFINE cSufijos             CHAR(60);
    DEFINE iExisteCuenta        SMALLINT;
    DEFINE iExisteMaehis        SMALLINT;
    
    LET vcodret           = "000";
    LET vcodret2          = "";
    LET vcodret3          = "";
    LET cProducto         = "";
    LET cNumProducto      = "";
    LET cNumTarjeta       = "";
    LET cClabe            = "";
    LET cNumcte           = "";
    LET cNomcte           = "";
    LET cNumExt           = "";
    LET cNumInt           = "";
    LET cNomCalle         = "";
    LET cNomColonia       = "";
    LET cNomCiudad        = "";
    LET cNomEstado        = "";
    LET cCodPostal        = "";
    LET cRFC              = "";
    LET cCurp             = "";
    LET cNomSucursal      = "";
    LET dFechaini         = "";
    LET dFechafin         = "";
    LET dFechaAlta        = "";
    LET mSaldoPromedio    = 0;
    LET mInteresesNetos   = 0;
    LET mSaldoAnterior    = 0;
    LET mDepositos        = 0;
    LET mRetiros          = 0;
    LET mInteresesPagados = 0;
    LET mOtrosCargos      = 0;
    LET mIvaOtrosCargos   = 0;
    LET mSaldoCorte       = 0;
    LET mRetencionIsr     = 0;
    LET iDias             = 0;
    LET dTasaBruta        = 0;
    LET mAux1             = 0;
    LET vsec_dir          = 0;
    LET pcuenta           = TRIM(pcuenta);
    LET mSaldoRet         = '';
    LET cTipoPersona      = '';
    LET mtotOtroscargos   = 0;
    LET mGat              = 0;
    LET mTotRetiros       = 0;
    LET iFlagGrafica      = 0;
    LET cAnyomes          = "";
	LET cRFC_alterno      = "";
	LET  cSufijos         = '';
    LET iExisteCuenta     = 0;
    LET iExisteMaehis     = 0;
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr, visamerr, vdescerr
     --   SET DEBUG FILE TO "/resplogifx/conciliachq/sp_edoctagenerales_central.err";
     --   TRACE ON;
        IF vsqlerr != 0 THEN
            LET vcodret = vsqlerr;
            LET vcodret2 = visamerr;
            LET vcodret3 = vdescerr;
            RETURN vcodret, cProducto, cNumProducto, cNumTarjeta, cClabe, dFechaini, dFechafin, mSaldoAnterior, mDepositos, mInteresesPagados, mRetiros, mOtrosCargos,
                   mIvaOtrosCargos, mSaldoCorte, mSaldoPromedio, mRetencionIsr, mInteresesNetos, iDias, dTasaBruta, cNumcte, cNomcte, cNumExt, cNumInt, cNomCalle, 
                   cNomColonia, cNomCiudad, cNomEstado, cCodPostal, cRFC, cCurp, dFechaAlta, cNomSucursal, mSaldoRet, mTotOtrosCargos, mGat, mTotRetiros, iFlagGrafica;
        END IF;
    END EXCEPTION;
    
	--- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_edoctagenerales_central.out";
	--- TRACE ON;
        
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT COUNT(*)
      INTO iExisteCuenta
      FROM bdicheq:sc_maechq
     WHERE empresa = pempresa
       AND cuenta = pcuenta;
       
    -- // VALIDA QUE LA CUENTA EXISTE 
    IF iExisteCuenta > 0 THEN
        -- // OBTIENE TIPO DE PERSONA 
        Select tpo_persona
          Into cTipoPersona
          From bdinteg:si_cliente
         Where numcte = ( Select num_cte
                            From bdicheq:sc_maechq
                           Where empresa = pempresa
                             And cuenta = pcuenta );

        -- // EN EN EL CASO DE PERSONA FISICA SE VA POR LA SECUENCIA MAXIMA DE NUMERO DE TARJETA DEL TITULAR
        If Trim(cTipoPersona) = '01' Then 
            Select num_tarjeta
              Into cNumTarjeta
              From bdicheq:sc_tarjeta
             Where empresa = pempresa
               And cuenta = pcuenta
               And tipo_tarjeta = "T"
               And status_tar = "A";
        End If;

        SELECT valor
          INTO cFech_param_old
          FROM bdicheq:sc_param
         WHERE empresa = pEmpresa
           AND codparam = 'FechIniCon_movhis_ol';
        
        -- // CONSULTA DE ESTADO DE CUENTA
        IF ptipo = '0' THEN 
            -- // OBTENER EL ESTADO DE CUENTA. SE MODIFICO PARA QUE MOSTRARA EL NUMERO DE TARJETA DE LA CUENTA MAS ACTUAL DEL CLIENTE
            SELECT {+INDEX(sc_maehis idx_maehis1)}
                   TRIM(ap.producto) || ' ' || TRIM(ap.nombre) AS producto, mc.producto,
                   TRIM(mc.num_cte), mc.cuenta_clabe, NVL(mc.fechaini, MDY(1, 1, 1900)), NVL(mc.fechafin,
                   MDY(1, 1, 1900)),NVL(sdo_mes_ant, 0), NVL(totdepositos, 0), NVL(totintpag, 0),
                   NVL(totretiros, 0),NVL(totcomcobrada, 0), NVL(totivacobrado, 0), NVL(sdo_actual, 0),
                   NVL(totisrcobrado, 0),NVL(dia_sdo_pos, 0), (NVL(tasabruta, 0) * 100), NVL(acum_sdo_pos, 0),
                   NVL(sdo_retenido, 0), NVL(tototroscargos,0), (NVL(gat,0)*100), NVL(totretirosefec,0)
              INTO cProducto, cNumProducto, cNumcte, cClabe, dFechaini, dFechafin,
                   mSaldoAnterior, mDepositos, mInteresesPagados, mRetiros,
                   mOtrosCargos, mIvaOtrosCargos, mSaldoCorte,
                   mRetencionIsr, iDias, dTasaBruta, mAux1,mSaldoRet, mTotOtrosCargos, mGat, mTotRetiros
              FROM sc_maehis AS mc,
                   sc_producto AS ap
             WHERE mc.empresa = pempresa 
               AND mc.cuenta = pcuenta 
               AND mc.aniomes = paniomes 
               AND mc.empresa = ap.empresa 
               AND mc.producto = ap.producto 
               AND mc.fechaini >= cFech_param_old;

              SELECT TRIM(valor) 
                INTO cAnyomes
                FROM sc_param 
               WHERE empresa = pEmpresa
                 AND codparam = 'edoctagrafica' ;

              IF CAST(paniomes as INTEGER) >= CAST(cAnyomes as INTEGER) THEN
                  LET iFlagGrafica = 1;
              END IF;    
        
        -- // CONSULTA DE MOVIMIENTOS
        ELIF ptipo = '1'  THEN 
            LET dFechaini = "";
            LET dFechafin = "";
            LET v_mes     = "";
            LET v_mes2    = "";

            -- // SE MODIFICO PARA QUE MOSTRARA EL NUMERO DE TARJETA DE LA CUENTA MAS ACTUAL DEL CLIENTE 
            SELECT TRIM(ap.producto) || ' ' || TRIM(ap.nombre) AS producto, mc.producto,
                   TRIM(mc.num_cte), mc.cuenta_clabe, MDY(1, 1, 1900), MDY(1, 1, 1900),
                   NVL(mc.sdo_dia_ant, 0), NVL(mc.depositos_cantidad, 0), 0, NVL(mc.retiros_cantidad, 0),
                   0, 0, NVL(mc.sdo_actual, 0), 0, 0, 0, 0,NVL(sdo_retenido, 0)
              INTO cProducto, cNumProducto, cNumcte, cClabe, dFechaini, dFechafin,
                   mSaldoAnterior, mDepositos, mInteresesPagados, mRetiros,
                   mOtrosCargos, mIvaOtrosCargos, mSaldoCorte,
                   mRetencionIsr, iDias, dTasaBruta, mAux1,mSaldoRet
              FROM sc_maechq AS mc,
                   sc_producto AS ap
             WHERE mc.empresa = pempresa 
               AND mc.cuenta = pcuenta 
               AND mc.empresa = ap.empresa 
               AND mc.producto = ap.producto;

            -- // SE OBTIENE LA FECHA DE INICIO PARA PRESENTAR LOS MOVIMIENTOS, FECHA FIN DE SU ULTIMO MESIVERSARIO 
            SELECT COUNT(*) 
              INTO iExisteMaehis
              FROM sc_maehis_factelect 
             WHERE empresa = pempresa 
               AND cuenta = pcuenta
               AND fechaini >= cFech_param_old;
               
            IF iExisteMaehis > 0 THEN
                SELECT MAX(fechafin)
                  INTO dFechaini
                  FROM sc_maehis_factelect
                 WHERE empresa = pempresa
                   AND cuenta = pcuenta
                   AND fechaini >= cFech_param_old;
                
                SELECT sdo_actual
                  INTO mSaldoAnterior
                  FROM sc_maehis_factelect
                 WHERE empresa = pempresa
                   AND cuenta = pcuenta
                   AND fechafin = dFechaini;
                   
                -- // A LA FECHA DE INICIO SE LE SUMA 1 DIA PARA QUE NO CONSIDERE LOS MOVTOS QUE YA APARECEN EN EL EDOCTA 
                LET dFechaini = dFechaini + 1 units day;
            ELSE 
                -- // SI LA CUENTA NO HA TENIDO UN MESIVERSARIO SE TOMA LA FECHA DE ALTA DE LA CUENTA 
                SELECT fecha_alta
                  INTO dFechaini
                  FROM sc_maenoc
                 WHERE empresa = pempresa
                   AND cuenta = pcuenta;
                   
                LET mSaldoAnterior = 0.00;
            END IF;
            
			-- // SE OBTIENE PARAMETRO PARA ACTIVAR EL FLAG QUE AUTORIZA QUE SE MUESTRE GRÁFICA 
			SELECT TRIM(valor) 
              INTO cAnyomes
              FROM sc_param 
             WHERE empresa = pEmpresa
               AND codparam = 'edoctagrafica' ;

            IF CAST(paniomes as INTEGER) >= CAST(cAnyomes as INTEGER) THEN
                LET iFlagGrafica = 1;
            END IF;   
			  
            -- // SE OBTIENE LA FECHA DE HOY QUE ES LA FECHA FIN AL CONSULTAR MOVIMIENTOS 
            SELECT fecha_hoy
              INTO dFechafin
              FROM sc_fechas
             WHERE empresa = pempresa;
        ELSE
            LET vcodret = "005";
        END IF;

        IF vcodret <> '005' THEN
            -- // EXTRAE LA ULTIMA SECUENCIA DE TIPO CASA DE DIRECCIONES MEL 
            SELECT secuencia
              INTO vsec_dir
              FROM bdinteg:si_direcciones_actual
             WHERE numcte = cnumcte 
               AND tipo_dir = 1;
           
            IF vsec_dir IS NULL THEN
                SELECT secuencia
                  INTO vsec_dir
                  FROM bdinteg:si_direcciones_actual
                 WHERE numcte = cnumcte 
                   AND tipo_dir = 2;
                   
                IF vsec_dir IS NULL THEN
                    SELECT secuencia
                      INTO vsec_dir
                      FROM bdinteg:si_direcciones_actual
                     WHERE numcte = cnumcte 
                       AND tipo_dir = 3;
                       
                    IF vsec_dir IS NULL THEN
                        LET vsec_dir = 1;
                    END IF;
                END IF;
            END IF

            IF iDias = 0 THEN
                LET mSaldoPromedio= 0;
            ELSE
                LET mSaldoPromedio= mAux1 / iDias;
            END IF;

            LET mInteresesNetos = mInteresesPagados - mRetencionIsr;

            IF cNumcte IS NULL THEN
                LET vcodret = "003";

                SELECT TRIM(ap.producto) || ' ' || TRIM(ap.nombre) AS producto, mc.producto,
                       TRIM(mc.num_cte), mc.cuenta_clabe
                  INTO cProducto, cNumProducto, cNumcte, cClabe
                  FROM sc_maechq AS mc,
                       sc_producto AS ap
                 WHERE mc.empresa = pempresa
                   AND mc.cuenta = pcuenta
                   AND mc.empresa = ap.empresa
                   AND mc.producto = ap.producto;

                SELECT NVL(TRIM(cte.razon_social), "") || NVL(TRIM(cte.nombre1), "") || ' ' || NVL(TRIM(cte.nombre2), "") || ' ' || NVL(TRIM(cte.apell_paterno), "") || ' ' || NVL(TRIM(cte.apell_materno), "") AS nombrex,
                       suc.nombre, cte.fecha_insert, cte.rfc, cte.rfc_alterno, cpf.curp, dir.numeroextcalle, dir.numerointcalle,
                       TRIM(cal.nombrecalle), TRIM(zon.nombrezona), TRIM(ciu.nombre), TRIM(edo.nombre), dir.cod_postal
                  INTO cNomcte, cNomSucursal, dFechaAlta, cRFC, cRFC_alterno, cCurp, cNumExt, cNumInt, cNomCalle,
                       cNomColonia, cNomCiudad, cNomEstado, cCodPostal
                  FROM bdinteg:si_cliente AS cte
                  LEFT JOIN bdinteg:si_ctepf cpf ON (cpf.numcte = cte.numcte)
                  LEFT JOIN bdinteg:si_direcciones_actual AS dir ON (dir.numcte = cte.numcte)
                  LEFT JOIN bdinteg:si_estados AS edo ON (edo.estado = dir.estado AND edo.pais = "001")
                  LEFT JOIN bdinteg:si_ciudades AS ciu ON (ciu.ciudad = dir.ciudad AND ciu.estado = dir.estado AND ciu.pais = "001")
                  LEFT JOIN bdinteg:si_catzonas AS zon ON (zon.numerociudad = dir.numerociudad AND zon.numerocolonia = dir.numerocolonia )
                  LEFT JOIN bdinteg:si_catcalles AS cal ON (cal.numerocalle = dir.numerocalle)
                  LEFT JOIN bdinteg:si_sucursales AS suc ON (suc.sucursal = cte.sucursal)
                 WHERE cte.empresa = pempresa
                   AND cte.numcte = cNumcte
                   AND dir.secuencia = vsec_dir;

                LET dFechaini = "";
                LET dFechafin = "";
                LET mSaldoAnterior = 0;
                LET mDepositos = 0;
                LET mInteresesPagados = 0;
                LET mRetiros = 0;
                LET mOtrosCargos = 0;
                LET mIvaOtrosCargos = 0;
                LET mSaldoCorte = 0;
                LET mSaldoPromedio = 0;
                LET mRetencionIsr = 0;
                LET mInteresesNetos = 0;
                LET iDias = 0;
                LET dTasaBruta = 0;
            ELSE
                SELECT NVL(TRIM(cte.razon_social), "") || NVL(TRIM(cte.nombre1), "") || ' ' || NVL(TRIM(cte.nombre2), "") || ' ' || NVL(TRIM(cte.apell_paterno), "") || ' ' || NVL(TRIM(cte.apell_materno), "") AS nombrex,
                       suc.nombre, cte.fecha_insert, cte.rfc, cte.rfc_alterno, cpf.curp, dir.numeroextcalle, dir.numerointcalle,
                       TRIM(cal.nombrecalle), TRIM(zon.nombrezona), TRIM(ciu.nombre), TRIM(edo.nombre), dir.cod_postal
                  INTO cNomcte, cNomSucursal, dFechaAlta, cRFC, cRFC_alterno, cCurp, cNumExt, cNumInt, cNomCalle, cNomColonia,
                       cNomCiudad, cNomEstado, cCodPostal
                  FROM bdinteg:si_cliente AS cte
                  LEFT JOIN bdinteg:si_ctepf AS cpf ON (cpf.numcte = cte.numcte)
                  LEFT JOIN bdinteg:si_direcciones_actual AS dir ON (dir.numcte = cte.numcte)
                  LEFT JOIN bdinteg:si_estados AS edo ON (edo.estado = dir.estado AND edo.pais = "001")
                  LEFT JOIN bdinteg:si_ciudades AS ciu ON (ciu.ciudad = dir.ciudad AND ciu.estado = dir.estado AND ciu.pais = "001")
                  LEFT JOIN bdinteg:si_catzonas AS zon ON (zon.numerociudad = dir.numerociudad AND zon.numerocolonia = dir.numerocolonia )
                  LEFT JOIN bdinteg:si_catcalles AS cal ON (cal.numerocalle = dir.numerocalle)
                  LEFT JOIN bdinteg:si_sucursales AS suc ON (suc.sucursal = cte.sucursal)
                 WHERE cte.empresa = pempresa
                   AND cte.numcte = cNumcte
                   AND dir.secuencia = vsec_dir;
            END IF;
            
            IF cRFC_alterno is not null and cRFC_alterno <> "" THEN
               LET cRFC = cRFC_alterno;
            END IF;	
        END IF;
        
        -- // SE OBTINE EL SUBFIJO DE LA EMPRESA Y SE AGREGA AL NOMBRE
        IF cTipoPersona NOT IN('01','03') THEN
            SELECT TRIM(suf.descripcion) 
              INTO cSufijos
              FROM bdinteg: "informix".si_sufijos suf, 
                   bdinteg: "informix".si_ctepm pm
             WHERE pm.empresa = pempresa
               AND pm.numcte = cNumcte
               AND suf.codigo = pm.sufijo;
            
            LET cNomcte = TRIM(cNomcte)||" "||TRIM(cSufijos);
        END IF;
    ELSE
        LET vcodret = "100";
    END IF;
    
    RETURN vcodret, cProducto, cNumProducto, cNumTarjeta, cClabe, dFechaini, dFechafin, mSaldoAnterior, mDepositos, mInteresesPagados, mRetiros, mOtrosCargos,
           mIvaOtrosCargos, mSaldoCorte, mSaldoPromedio, mRetencionIsr, mInteresesNetos, iDias, dTasaBruta, cNumcte, cNomcte, cNumExt, cNumInt, cNomCalle, 
           cNomColonia, cNomCiudad, cNomEstado, cCodPostal, cRFC, cCurp, dFechaAlta, cNomSucursal, mSaldoRet, mTotOtrosCargos, mGat, mTotRetiros, iFlagGrafica;
    
    END;
    
END PROCEDURE
    
DOCUMENT
'MODIFICA:ARMIDA PAZOS CHÁVEZ',
'DESCRIPCION:SE MODIFCA PARA LA TASABRUTA SE MULTIPLIQUE POR 100',
'FECHA:2009/10/27',
'VERSION:20091027.1241',
'BD: BDICHEQ',
'MODIFICA:ABIGAIL VASAVILBAZO CAÑEDO',
'DESCRIPCION:SE UNIFICAN LOS PROCESOS DE SUCURSAL, CENTRAL Y BPI PARA GENERAR EL ENCABEZADO DEL EDO CTA',
'FECHA:NOVIEMBRE 2009',
'VERSION:20091130.1109',
'MODIFICA:SAUL IVANHOE VALDESPINO HERNANDEZ',
'DESCRIPCION:SE MODIFICA PARA QUE REGRESE TRES CAMPOS NUEVOS DE LA sc_maehis:tototroscargos,porcientogat,totretirosefec ',
'FECHA:09/NOV/2010',
'MODIFICA:SAUL IVANHOE VALDESPINO HERNANDEZ',
'DESCRIPCION:SE MODIFICA YA QUE SE SOLICITO CAMBIAR EL NOMBRE DEL CAMPO porcientogat A gat',
'FECHA:23/NOV/2010',
'*******************************************************',
'Autor: 94912599',
'Fecha: 07/10/2013',
'Modificación: Se modifíca procedimiento para agregar sufijo a razon_social de personas morales',
'Sustento: 1450-EdoCtaPersonasMorales-Contrato.pdf',
'Solicita: Daniel Mayen',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_obtienedetalle_edoctacap(pEmpresa CHAR(3),
													pNumCta CHAR(12),
													pNumTarjeta CHAR(16),
													pultreg SMALLINT)
--RETORNO--
RETURNING	CHAR(6),		-- Codigo de Retorno
			CHAR(10),	-- Periodo
			DECIMAL(16,2),	-- Sdo Inicial
			DECIMAL(16,2),	-- Cargos
			DECIMAL(16,2),	-- Abonos
			DECIMAL(16,2);	-- Sdo Final

--DEFINICION DE VARIABLES
DEFINE	iSqlErr 	INTEGER;
DEFINE	cCodRet 	CHAR(6);
DEFINE	cPeriodo	CHAR(10);
DEFINE	dSdoIni		DECIMAL(16,2);
DEFINE	dCargos		DECIMAL(16,2);
DEFINE	dAbonos		DECIMAL(16,2);
DEFINE	dSdoFin		DECIMAL(16,2);
DEFINE	dFecha6mes	DATE;
DEFINE	cPeriodos 	INTEGER;
DEFINE	iTotalCtas	INTEGER;
DEFINE	dFechaHoy	DATE;

--INICIALIZACION DE VARIABLES
LET iSqlErr		= 0;
LET cCodRet		= '000000';
LET	cPeriodo	= '';
LET dSdoIni		= 0;
LET dCargos		= 0;
LET dAbonos		= 0;
LET dSdoFin		= 0;
LET dFecha6mes	= '';
LET cPeriodos	= 0;
LET iTotalCtas	= 0;
LET dFechaHoy = '';

	--SET DEBUG FILE TO '/respaldosbd/claudio/sp_obtienedetalle_edoctacap.out';
	--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet,NVL(cPeriodo,''),dSdoIni,dCargos,dAbonos,dSdoFin;
		END IF
	END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	IF NVL(pEmpresa,'') <> '' AND (NVL(pNumCta,'') <> '' OR NVL(pNumTarjeta,'') <> '') THEN
	
		SELECT valor INTO cPeriodos FROM bdinteg:"informix".si_param WHERE cod_param = 400 AND empresa = pEmpresa;	
		SELECT fecha_hoy INTO dFechaHoy FROM bdicheq:"informix".sc_fechas;		
		EXECUTE PROCEDURE bdicred:"informix".monthadd(dFechaHoy,-cPeriodos) INTO dFecha6mes;		
		
		IF NVL(pNumTarjeta,'') <> '' THEN
            SELECT cuenta 
              into pNumCta
              from bdicheq:"informix".sc_tarjeta 
              where empresa = pEmpresa 
                and num_tarjeta = pNumTarjeta;
        END IF;

        IF ( pNumCta is null ) THEN 
            LET cCodRet = '000001'; --Parametros Vacios.
        ELSE
            FOREACH
                SELECT fechafin,sdo_mes_ant,totretiros,totdepositos,sdo_actual INTO cPeriodo,dSdoIni,dCargos,dAbonos,dSdoFin
                FROM bdicheq:"informix".sc_maehis_factelect
                WHERE empresa = pEmpresa AND fechafin > dFecha6mes AND fechafin <= dFechaHoy AND cuenta = pNumCta ORDER BY aniomes DESC

                LET iTotalCtas = iTotalCtas + 1;
                IF iTotalCtas <= pultreg THEN
                    CONTINUE FOREACH;
                END IF
                RETURN cCodRet,NVL(cPeriodo,''),dSdoIni,dCargos,dAbonos,dSdoFin WITH RESUME;
            END FOREACH;

            IF iTotalCtas = 0 THEN
                LET cCodRet = '000002'; --Cta o Tarj sin Edos de Cuenta.
            END IF

        END IF;

	ELSE
		LET cCodRet = '000001'; --Parametros Vacios.
	END IF

	IF NVL(cCodRet,'') <> '000000' THEN
		RETURN cCodRet,NVL(cPeriodo,''),dSdoIni,dCargos,dAbonos,dSdoFin;
	END IF
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Cosulta estados de cuenta captacion CFDI',
'REALIZO: Claudio Almodovar',
'FECHA: 08/07/2014',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_cancelaportanom_bpi (pEmpresa CHAR(3),pNumcte CHAR(20),pCtaOrdenante CHAR(20),pFolio CHAR(30),pFolioCancela CHAR(30),pUserCancela CHAR(8),pSucCancela CHAR(4))
RETURNING
	CHAR(5)   AS	vcCodRet;
	
	--DECLARA VARIABLES
	DEFINE cCodRet					CHAR (5);
	DEFINE cSqlErr					SMALLINT;
	DEFINE vcNumCte					CHAR(20);
	DEFINE viNumReg					SMALLINT;
	DEFINE vcCuenta					CHAR(20);
	
	--INICIALIZA VARIABLES
	LET cCodRet					= '00000';
	LET cSqlErr					= 0;
	LET vcNumCte				= '';
	LET	viNumReg				= 0;
	LET vcCuenta				= '';
	
	BEGIN
		ON EXCEPTION SET cSqlErr
			IF cSqlErr <> 0 THEN
				LET cCodRet = cSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		
		  --SET DEBUG FILE TO "/informix/gaby/ArchivosOut/sp_cancelaportanom_bpi.out";
		  --TRACE ON;
		
		SET LOCK MODE TO WAIT 3;	
		
		SELECT cta_ordenante INTO vcCuenta FROM bdicheq:"informix".sc_portacec_solicitud WHERE empresa = pEmpresa AND num_cte = pNumcte AND folio_solicitud = pFolio;
				
		IF EXISTS (SELECT num_cte FROM bdicheq:"informix".sc_portacec_solicitud WHERE empresa = pEmpresa AND num_cte = pNumcte 	AND cta_ordenante = vcCuenta  AND folio_solicitud = pFolio) then
			
			SELECT {+INDEX (sc_maechq, idx_ctaclabe)} cuenta INTO vcCuenta FROM bdicheq:"informix".sc_maechq WHERE cuenta_clabe=pCtaOrdenante;
			IF EXISTS(SELECT cliente FROM bdicheq:"informix".sc_portabilidadnomina WHERE empresa = pEmpresa AND cliente = pNumcte and cuenta_abono = vcCuenta)THEN
							
				UPDATE bdicheq:"informix".sc_portabilidadnomina 
				SET estatus='02', user_cancel='transBPI', fecha_cancel=TODAY, origen_cancel='WEB', sucursal_cancel='5003' 
				WHERE empresa = pEmpresa AND cliente = pNumcte and cuenta_abono = vcCuenta;
				
				UPDATE bdicheq:"informix".sc_portacec_solicitud
				SET estatus_portabilidad='4', clave_sentido='0', folio_cancelacion=pFolioCancela, fecha_estatus_portabilidad= year(today)||lpad(month(today),2,0)||lpad(day(today),2,0)   ,fecha_solca_portabilidad= year(today)||lpad(month(today),2,0)||lpad(day(today),2,0) , clave_origen= '2', suc_cancela='5003', user_cancela='transBPI'
				WHERE empresa = pEmpresa AND num_cte = pNumcte AND cta_ordenante = pCtaOrdenante 
				AND folio_solicitud = pFolio;
				
			ELSE
				LET cCodRet = '002';			END IF;
		ELSE
			LET cCodRet = '001';		END IF;

		RETURN cCodRet;
	END;
END PROCEDURE;