CREATE PROCEDURE "informix".sp_edoctagenerales(pempresa CHAR(3), 
                                               pcuenta CHAR(20), 
                                               paniomes CHAR(6), 
                                               ptipo CHAR(1))

RETURNING CHAR(5), CHAR(45), CHAR(10), CHAR(16), CHAR(18), DATE, DATE,
      	  MONEY(14, 2), MONEY(14, 2), MONEY(14, 2), MONEY(14, 2), MONEY(14, 2),
          MONEY(14, 2), MONEY(14, 2), MONEY(14, 2), MONEY(14, 2), MONEY(14, 2),
          SMALLINT, DECIMAL(9, 6), CHAR(20), CHAR(107), CHAR(10),
          CHAR(10), CHAR(30), CHAR(30), CHAR(30), CHAR(30),
          CHAR(5), CHAR(13), CHAR(20), DATE, CHAR(40);

    DEFINE vcodret, cCodPostal                                      CHAR(5);
    DEFINE cNumExt, cNumInt, cNumProducto                           CHAR(10);
    DEFINE cRFC                                                     CHAR(13);
    DEFINE cNumTarjeta                                              CHAR(16);
    DEFINE cClabe                                                   CHAR(18);
    DEFINE cNumcte, cCurp                                           CHAR(20);
    DEFINE cNomCalle, cNomColonia, cNomCiudad, cNomEstado           CHAR(30);
    DEFINE cNomSucursal                                             CHAR(40);
    DEFINE cProducto                                                CHAR(45);
    DEFINE cNomcte                                                  CHAR(107);
    DEFINE dFechaini, dFechafin, dFechaAlta                         DATE;
    DEFINE mSaldoAnterior, mDepositos, mRetiros, mInteresesPagados  MONEY(14, 2);
    DEFINE mOtrosCargos, mIvaOtrosCargos, mSaldoCorte, mAux1        MONEY(14, 2);
    DEFINE mSaldoPromedio, mRetencionIsr, mInteresesNetos           MONEY(14, 2);
    DEFINE dTasaBruta                                               DECIMAL(9, 6);
    DEFINE iDias, vsec_dir, iAnioMes                                SMALLINT;
    DEFINE vsqlerr, visamerr                                        INTEGER;
    DEFINE v_mes, v_mes2                                            CHAR(2);
    DEFINE cFech_param_old                                          CHAR(10);
	DEFINE cRFC_alterno                                             CHAR(13);
    
    LET vcodret = "000";
    LET cProducto = "";
    LET cNumProducto = "";
    LET cNumTarjeta = "";
    LET cClabe = "";
    LET cNumcte = "";
    LET cNomcte = "";
    LET cNumExt = "";
    LET cNumInt = "";
    LET cNomCalle = "";
    LET cNomColonia = "";
    LET cNomCiudad = "";
    LET cNomEstado = "";
    LET cCodPostal = "";
    LET cRFC = "";
    LET cCurp = "";
    LET cNomSucursal = "";
    LET dFechaini = "";
    LET dFechafin = "";
    LET dFechaAlta = "";
    LET mSaldoPromedio= 0;
    LET mInteresesNetos = 0;
    LET mSaldoAnterior = 0;
    LET mDepositos = 0;
    LET mRetiros = 0;
    LET mInteresesPagados = 0;
    LET mOtrosCargos = 0;
    LET mIvaOtrosCargos = 0;
    LET mSaldoCorte = 0;
    LET mRetencionIsr = 0;
    LET iDias = 0;
    LET dTasaBruta = 0;
    LET mAux1 = 0;
    LET vsec_dir = 0;
    LET iAnioMes = 0;
    LET pcuenta = TRIM(pcuenta);
	LET cRFC_alterno = "";

    BEGIN
	
	

    ON EXCEPTION SET vsqlerr, visamerr
        IF vsqlerr != 0 THEN
            LET vcodret=vsqlerr;

            RETURN vcodret, cProducto, cNumProducto, cNumTarjeta, cClabe, dFechaini, dFechafin,
                   mSaldoAnterior, mDepositos, mInteresesPagados, mRetiros, mOtrosCargos,
                   mIvaOtrosCargos, mSaldoCorte, mSaldoPromedio, mRetencionIsr, mInteresesNetos,
                   iDias, dTasaBruta, cNumcte, cNomcte, cNumExt, cNumInt, cNomCalle, cNomColonia, 
                   cNomCiudad, cNomEstado, cCodPostal, cRFC, cCurp, dFechaAlta, cNomSucursal;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 2;
	
	--SET DEBUG FILE TO "/informix/gaby/ArchivosOut/sp_edoctagenerales.out";
	--TRACE ON;
    
    SELECT valor
      INTO cFech_param_old
      FROM bdicheq:sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'FechIniCon_movhis_ol';

    IF EXISTS (SELECT cuenta 
                 FROM sc_maechq 
                WHERE empresa = pempresa
                  AND cuenta = pcuenta) THEN
                  
        IF ptipo = '1' THEN
            IF EXISTS (SELECT --{+INDEX(sc_maehis_factelect idx_sc_maehis_factelect1)}
                              mc.aniomes 
                         FROM sc_maehis_factelect mc 
                        WHERE mc.empresa = pempresa 
                          AND mc.cuenta = pcuenta 
                          AND mc.aniomes = paniomes
                          AND mc.fechaini >= cFech_param_old) THEN
                LET iAnioMes = 1;
            END IF;
        END IF;

        IF ptipo = '0' THEN

            /* -- OBTENER EL ESTADO DE CUENTA -- */
            /* -- SE MODIFICO PARA QUE MOSTRARA EL NUMERO DE TARJETA DE LA CUENTA MAS ACTUAL DEL CLIENTE -- */
            SELECT --{+INDEX(sc_maehis_factelect idx_sc_maehis_factelect1)}
                   TRIM(ap.producto) || ' ' || TRIM(ap.nombre) AS producto, chq.producto, --mc.num_tarjeta, 
                   TRIM(chq.num_cte), chq.cuenta_clabe, NVL(mc.fechaini, MDY(1, 1, 1900)), NVL(mc.fechafin, MDY(1, 1, 1900)),
                   NVL(sdo_mes_ant, 0), NVL(totdepositos, 0), 
				  -- NVL(totintpag, 0), 
				  NVL(totretiros, 0)
                   --NVL(totcomcobrada, 0), NVL(totivacobrado, 0), NVL(sdo_actual, 0), NVL(totisrcobrado, 0),
                  -- NVL(dia_sdo_pos, 0), (NVL(tasabruta, 0) * 100), NVL(acum_sdo_pos, 0)
              INTO cProducto, cNumProducto, --cNumTarjeta, 
				cNumcte, cClabe, dFechaini, dFechafin,
                   mSaldoAnterior, mDepositos, 
				   --mInteresesPagados, 
				   mRetiros
                  -- mOtrosCargos, mIvaOtrosCargos, mSaldoCorte,
                  -- mRetencionIsr, iDias, dTasaBruta, mAux1
              FROM sc_maehis_factelect AS mc,
                   sc_producto AS ap,
				   sc_maechq AS chq
             WHERE mc.empresa = pempresa 
               AND mc.cuenta = pcuenta 
               AND mc.aniomes = paniomes 
               AND mc.fechaini >= cFech_param_old
			   AND chq.cuenta = pcuenta
               AND ap.empresa = chq.empresa 
			   AND ap.producto = chq.producto;

        ELIF ptipo = '1' AND iAnioMes = 0 THEN

            LET dFechaini = "";
            LET dFechafin = "";
            LET v_mes = "";
            LET v_mes2 = "";

            /* -- SE MODIFICO PARA QUE MOSTRARA EL NUMERO DE TARJETA DE LA CUENTA MAS ACTUAL DEL CLIENTE -- */
            SELECT TRIM(ap.producto) || ' ' || TRIM(ap.nombre) AS producto, mc.producto, 
                   TRIM(mc.num_cte), mc.cuenta_clabe, MDY(1, 1, 1900), MDY(1, 1, 1900),
                   NVL(mc.sdo_dia_ant, 0), NVL(mc.depositos_cantidad, 0), 0, NVL(mc.retiros_cantidad, 0),
                   0, 0, NVL(mc.sdo_actual, 0), 0, 0, 0, 0
              INTO cProducto, cNumProducto, 
                   cNumcte, cClabe, dFechaini, dFechafin,
                   mSaldoAnterior, mDepositos, mInteresesPagados, mRetiros,
                   mOtrosCargos, mIvaOtrosCargos, mSaldoCorte,
                   mRetencionIsr, iDias, dTasaBruta, mAux1
              FROM sc_maechq AS mc,
                   sc_producto AS ap
             WHERE mc.empresa = pempresa 
               AND mc.cuenta = pcuenta 
               AND ap.empresa = mc.empresa
               AND ap.producto = mc.producto;

            IF NOT EXISTS(SELECT num_tarjeta 
                            FROM sc_tarjeta 
                           WHERE empresa = pempresa 
                             AND cuenta = pcuenta
                             AND secuencia = (SELECT MAX(secuencia) FROM sc_tarjeta WHERE empresa = pempresa AND cuenta = pcuenta)) THEN
                LET cNumTarjeta = " ";
            ELSE 
                SELECT tj.num_tarjeta 
                  INTO cNumTarjeta
                  FROM sc_tarjeta AS tj
                 WHERE tj.empresa = pempresa 
                   AND tj.num_tarjeta = (SELECT num_tarjeta FROM sc_tarjeta WHERE empresa = pempresa AND cuenta = pcuenta 
                                            AND secuencia = (SELECT MAX(secuencia) FROM sc_tarjeta WHERE empresa = pempresa AND cuenta = pcuenta))
                   AND tj.cuenta = pcuenta
                   AND tj.tipo_tarjeta = "T";
            END IF;

            /* -- VERIFICAR CUAL ES LA FECHA FINAL DEL ULTIMO ESTADO DE CUENTA -- */
            SELECT {+INDEX(sc_maehis_factelect idx_sc_maehis_factelect2)}
                   MAX(fechafin) 
              INTO dFechaini 
              FROM sc_maehis_factelect 
             WHERE empresa = pempresa 
               AND cuenta = pcuenta
               AND fechaini >= cFech_param_old;

            LET dFechaini = dFechaini + 1 units day;

            -- // SE MODFICO PARA QUE AL TRAER LA FECHA SIN REGISTRO, LE ASIGNARA LA FECHA DE ALTA DE LA CUENTA Y MUESTRE LOS MOVIMIENTOS
            IF dFechaini IS NULL THEN
                LET dFechaini = (SELECT fecha_alta  
                                   FROM sc_maenoc 
                                  WHERE empresa = pempresa 
                                    AND cuenta = pcuenta);
            END IF;

            IF dFechafin IS NULL THEN
                LET dFechafin = "";
            END IF;
        ELSE
            LET vcodret = "005";
        END IF;

        IF vcodret <> '005' THEN
            /* -- Extrae la Ultima Secuencia de Tipo casa de Direcciones MEL -- */
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
                   AND ap.empresa = mc.empresa 
                   AND ap.producto = mc.producto;

                SELECT NVL(TRIM(cte.razon_social), "") || 
                       NVL(TRIM(cte.nombre1), "") || ' ' || 
                       NVL(TRIM(cte.nombre2), "") || ' ' || 
                       NVL(TRIM(cte.apell_paterno), "") || ' ' || 
                       NVL(TRIM(cte.apell_materno), "") AS nombrex,
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
                SELECT NVL(TRIM(cte.razon_social), "") || 
                       NVL(TRIM(cte.nombre1), "") || ' ' || 
                       NVL(TRIM(cte.nombre2), "") || ' ' || 
                       NVL(TRIM(cte.apell_paterno), "") || ' ' || 
                       NVL(TRIM(cte.apell_materno), "") AS nombrex,
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
        END IF;
    ELSE
        LET vcodret = "100";
    END IF;

	IF cRFC_alterno is not null and cRFC_alterno <> "" THEN
       LET cRFC = cRFC_alterno;
    END IF;	 
	
    RETURN vcodret, cProducto, cNumProducto, cNumTarjeta, cClabe, dFechaini, dFechafin,
           mSaldoAnterior, mDepositos, mInteresesPagados, mRetiros, mOtrosCargos,
           mIvaOtrosCargos, mSaldoCorte, mSaldoPromedio, mRetencionIsr, mInteresesNetos,
           iDias, dTasaBruta, cNumcte, cNomcte, cNumExt,
           cNumInt, cNomCalle, cNomColonia, cNomCiudad, cNomEstado,
           cCodPostal, cRFC, cCurp, dFechaAlta, cNomSucursal;

    END;

END PROCEDURE;