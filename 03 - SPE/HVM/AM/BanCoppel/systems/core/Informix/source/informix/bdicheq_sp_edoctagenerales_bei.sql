CREATE PROCEDURE "informix".sp_edoctagenerales_bei(pempresa CHAR(3), 
											   pcuenta CHAR(20), 
											   paniomes CHAR(6), 
											   ptipo CHAR(1))

  RETURNING CHAR(5), CHAR(45), CHAR(10), CHAR(16), CHAR(18), DATE, DATE,
			MONEY(14, 2), MONEY(14, 2), MONEY(14, 2), MONEY(14, 2), MONEY(14, 2),
			MONEY(14, 2), MONEY(14, 2), MONEY(14, 2), MONEY(14, 2), MONEY(14, 2),
			SMALLINT, DECIMAL(9, 6), CHAR(20), CHAR(107), CHAR(10),
			CHAR(10), CHAR(30), CHAR(30), CHAR(30), CHAR(30),
			CHAR(5), CHAR(13), DATE, CHAR(40);
			
			
			
    DEFINE cCodret, cCodPostal CHAR(5);
    DEFINE cNumExt, cNumInt, cNumProducto CHAR(10);
    DEFINE cRFC CHAR(13);
    DEFINE cNumTarjeta CHAR(16);
    DEFINE cClabe CHAR(18);
    DEFINE cNumcte CHAR(20);
    DEFINE cNomCalle, cNomColonia, cNomCiudad, cNomEstado CHAR(30);
    DEFINE cNomSucursal CHAR(40);
    DEFINE cProducto CHAR(45);
    DEFINE cNomcte CHAR(107);
    DEFINE dFechaini, dFechafin, dFechaAlta DATE;
    DEFINE mSaldoAnterior, mDepositos, mRetiros, mInteresesPagados MONEY(14, 2);
    DEFINE mOtrosCargos, mIvaOtrosCargos, mSaldoCorte, mAux1 MONEY(14, 2);
    DEFINE mSaldoPromedio, mRetencionIsr, mInteresesNetos MONEY(14, 2);
    DEFINE dTasaBruta DECIMAL(9, 6);
    DEFINE sDias, sSec_dir SMALLINT;
    DEFINE iSqlerr, iIsamerr INTEGER;
    DEFINE cMes, cMes2 CHAR(2);
	

    LET cCodret = "000";
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
    LET sDias = 0;
    LET dTasaBruta = 0;
    LET mAux1 = 0;
    LET sSec_dir = 0;    
    LET pcuenta = TRIM(pcuenta);

    BEGIN
	

    ON EXCEPTION SET iSqlerr, iIsamerr
	IF iSqlerr != 0 THEN

	    LET cCodret=iSqlerr;

	    RETURN cCodret, cProducto, cNumProducto, cNumTarjeta, cClabe, 
			dFechaini, dFechafin,
		   mSaldoAnterior, mDepositos, mInteresesPagados, mRetiros, mOtrosCargos,
		   mIvaOtrosCargos, mSaldoCorte, mSaldoPromedio, mRetencionIsr, mInteresesNetos,
		   sDias, dTasaBruta, cNumcte, cNomcte, cNumExt,
		   cNumInt, cNomCalle, cNomColonia, cNomCiudad, cNomEstado,
		   cCodPostal, cRFC, dFechaAlta, cNomSucursal;
	END IF;
    END EXCEPTION;
	
	
	--SET DEBUG FILE TO "/informix/gaby/ArchivosOut/sp_edoctagenerales_bei.out";
	--TRACE ON;

	SET LOCK MODE TO WAIT ;
	SET ISOLATION DIRTY READ ;
	
    IF EXISTS (SELECT cuenta 
		 FROM bdicheq:"informix".sc_maechq 
		WHERE cuenta = pcuenta) THEN	

		IF ptipo = '0' THEN

		    -- // OBTENER EL ESTADO DE CUENTA

		    -- // SE MODIFICO PARA QUE MOSTRARA EL NUMERO DE TARJETA DE LA CUENTA MAS ACTUAL DEL CLIENTE

			SET LOCK MODE TO WAIT ;
			SET ISOLATION DIRTY READ ;
			
		    SELECT TRIM(ap.producto) || ' ' || TRIM(ap.nombre) AS producto, chq.producto, --mc.num_tarjeta, -- tj.num_tarjeta,
	        	   TRIM(chq.num_cte), chq.cuenta_clabe, NVL(mc.fechaini, MDY(1, 1, 1900)), NVL(mc.fechafin, MDY(1, 1, 1900)),
	        	   NVL(sdo_mes_ant, 0), NVL(totdepositos, 0), --NVL(totintpag, 0), 
				   NVL(totretiros, 0)
	        	  -- NVL(totcomcobrada, 0), NVL(totivacobrado, 0), NVL(sdo_actual, 0), NVL(totisrcobrado, 0),
	        	   --NVL(dia_sdo_pos, 0), (NVL(tasabruta, 0)*100), NVL(acum_sdo_pos, 0)
		      INTO cProducto, cNumProducto, --cNumTarjeta, 
					cNumcte, cClabe, dFechaini, dFechafin,
	        	   mSaldoAnterior, mDepositos,-- mInteresesPagados, 
				   mRetiros
	        	   --mOtrosCargos, mIvaOtrosCargos, mSaldoCorte,
	        	  -- mRetencionIsr, sDias, dTasaBruta, mAux1
		      FROM bdicheq:"informix".sc_maehis_factelect AS mc,
	        	   bdicheq:"informix".sc_producto AS ap,
				   bdicheq:sc_maechq AS chq
	        	-- sc_tarjeta AS tj
		     WHERE mc.empresa = pempresa 
	               AND mc.cuenta = pcuenta 
	               AND mc.aniomes = paniomes 
	               AND mc.empresa = ap.empresa 
				   AND chq.cuenta = pcuenta
	               AND ap.producto = chq.producto;
	            -- AND mc.empresa = tj.empresa
	            -- AND mc.cuenta = tj.cuenta
	            -- AND tipo_tarjeta = "T"
	            -- AND tj.num_tarjeta = (SELECT num_tarjeta
	            --       	               FROM sc_tarjeta
	            --       	              WHERE cuenta = pcuenta 
	            -- 			        AND secuencia = (SELECT MAX(secuencia) FROM sc_tarjeta WHERE cuenta = pcuenta));

		ELIF ptipo = '1'  THEN

		    LET dFechaini = "";
		    LET dFechafin = "";
		    LET cMes = "";
		    LET cMes2 = "";

		    -- // SE MODIFICO PARA QUE MOSTRARA EL NUMERO DE TARJETA DE LA CUENTA MAS ACTUAL DEL CLIENTE
					
			SET LOCK MODE TO WAIT ;
			SET ISOLATION DIRTY READ ;
					
			SELECT TRIM(ap.producto) || ' ' || TRIM(ap.nombre) AS producto, mc.producto, -- tj.num_tarjeta,
				TRIM(mc.num_cte), mc.cuenta_clabe, MDY(1, 1, 1900), MDY(1, 1, 1900),
				NVL(mc.sdo_dia_ant, 0), NVL(mc.depositos_cantidad, 0), 0, NVL(mc.retiros_cantidad, 0),
				0, 0, NVL(mc.sdo_actual, 0), 0, 0, 0, 0
			INTO cProducto, cNumProducto, -- cNumTarjeta, 
				cNumcte, cClabe, 
				dFechaini, dFechafin,
				mSaldoAnterior, mDepositos, mInteresesPagados, mRetiros,
				mOtrosCargos, mIvaOtrosCargos, mSaldoCorte,
				mRetencionIsr, sDias, dTasaBruta, mAux1
			FROM bdicheq:"informix".sc_maechq AS mc,
				bdicheq:"informix".sc_producto AS ap
				-- sc_tarjeta AS tj
			WHERE mc.empresa = pempresa 
				AND mc.cuenta = pcuenta 
				AND mc.empresa = ap.empresa
				AND mc.producto = ap.producto;
				-- AND mc.empresa = tj.empresa 
				-- AND mc.cuenta = tj.cuenta 
				-- AND tipo_tarjeta = "T" 
				-- AND tj.num_tarjeta = (SELECT num_tarjeta
				--		               FROM sc_tarjeta
				--			      WHERE cuenta = pcuenta
				--				AND secuencia = (SELECT MAX(secuencia) FROM sc_tarjeta WHERE cuenta = pcuenta));

			SET LOCK MODE TO WAIT ;
			SET ISOLATION DIRTY READ ;
				
			IF NOT EXISTS(SELECT num_tarjeta 
				FROM bdicheq:"informix".sc_tarjeta 
			    WHERE empresa = pempresa 
				AND cuenta = pcuenta
				AND secuencia = (SELECT MAX(secuencia) 
				FROM sc_tarjeta
				WHERE empresa = pempresa
				AND cuenta = pcuenta)) THEN

				LET cNumTarjeta = " ";

			ELSE 

				SELECT tj.num_tarjeta 
				INTO cNumTarjeta
				FROM bdicheq:"informix".sc_tarjeta AS tj
				WHERE tj.empresa = pempresa 
				AND tj.num_tarjeta = (SELECT num_tarjeta
				FROM bdicheq:"informix".sc_tarjeta
				WHERE empresa = pempresa 
				AND cuenta = pcuenta 
				AND secuencia = (SELECT MAX(secuencia) 
				FROM bdicheq:"informix".sc_tarjeta 
				WHERE empresa = pempresa 
				AND cuenta = pcuenta))
				AND tj.cuenta = pcuenta
				AND tipo_tarjeta = "T";

			END IF;

			-- Se obtiene la fecha de inicio para presentar los Movimientos, fecha fin de su ultimo mesiversario
			If Exists (SELECT MAX(fechafin) FROM bdicheq:"informix".sc_maehis_factelect WHERE empresa = pempresa AND cuenta = pcuenta) then
				SELECT MAX(fechafin) INTO dFechaini 
				FROM bdicheq:"informix".sc_maehis_factelect 
				WHERE empresa = pempresa 
				AND cuenta = pcuenta;
			Else -- Si la cuenta no ha tenido un mesiversario se toma la fecha de alta de la cuenta
				SELECT fecha_alta INTO dFechaini 
				FROM bdicheq:"informix".sc_maenoc 
				WHERE empresa = pempresa 
				AND cuenta = pcuenta;
			End If				
			
			-- Se obtiene la fecha de hoy que es la fecha fin al consultar Movimientos
			SELECT fecha_hoy INTO dFechafin 
			FROM bdicheq:"informix".sc_fechas;
			
			--A la fecha de inicio se le suma 1 dia para que no considere los movtos que ya aparecen en el EdoCta
			LET dFechaini = dFechaini + 1 units day;		    					   
							    
		ELSE
		    LET cCodret = "005";
		END IF;

		IF cCodret <> '005' THEN

		    -- // Extrae la Ultima Secuencia de Tipo casa de Direcciones MEL

			SET LOCK MODE TO WAIT ;
			SET ISOLATION DIRTY READ ;
			
		    SELECT MAX(secuencia) 
		    INTO sSec_dir
		    FROM bdinteg:"informix".si_direcciones
		    WHERE numcte = cnumcte 
		    AND tipo_dir = 1;
				   
		    IF sSec_dir IS NULL THEN
				LET sSec_dir = 1;
		    END IF

		    IF sDias = 0 THEN
		       LET mSaldoPromedio= 0;
		    ELSE
		       LET mSaldoPromedio= mAux1 / sDias;
		    END IF;

		    LET mInteresesNetos = mInteresesPagados - mRetencionIsr;

		    IF cNumcte IS NULL THEN

				LET cCodret= "003";
					
				SET LOCK MODE TO WAIT ;
				SET ISOLATION DIRTY READ ;
					
				SELECT TRIM(ap.producto) || ' ' || TRIM(ap.nombre) AS producto, mc.producto,
					TRIM(mc.num_cte), mc.cuenta_clabe
				INTO cProducto, cNumProducto, cNumcte, cClabe
				FROM bdicheq:"informix".sc_maechq AS mc,
					bdicheq:"informix".sc_producto AS ap
				WHERE mc.empresa = pempresa 
					AND mc.cuenta = pcuenta 
					AND mc.empresa = ap.empresa 
					AND mc.producto = ap.producto;

				SET LOCK MODE TO WAIT ;
				SET ISOLATION DIRTY READ ;
					
				SELECT NVL(TRIM(cte.razon_social), "") || NVL(TRIM(cte.nombre1), "") || ' ' || NVL(TRIM(cte.nombre2), "") || ' ' || NVL(TRIM(cte.apell_paterno), "") || ' ' || NVL(TRIM(cte.apell_materno), "") AS nombrex,
				    suc.nombre, cte.fecha_insert, cte.rfc, dir.numeroextcalle, dir.numerointcalle,
				    TRIM(cal.nombrecalle), TRIM(zon.nombrezona), TRIM(ciu.nombre), TRIM(edo.nombre), dir.cod_postal
				INTO cNomcte, cNomSucursal, dFechaAlta, cRFC, cNumExt, cNumInt, cNomCalle,
					cNomColonia, cNomCiudad, cNomEstado, cCodPostal
				FROM bdinteg:"informix".si_cliente AS cte
					LEFT JOIN bdinteg:"informix".si_ctepm cpm ON (cpm.numcte = cte.numcte)
					LEFT JOIN bdinteg:"informix".si_direcciones AS dir ON (dir.numcte = cte.numcte)
					LEFT JOIN bdinteg:"informix".si_estados AS edo ON (edo.estado = dir.estado AND edo.pais = "001")
					LEFT JOIN bdinteg:"informix".si_ciudades AS ciu ON (ciu.ciudad = dir.ciudad AND ciu.estado = dir.estado AND ciu.pais = "001")
					LEFT JOIN bdinteg:"informix".si_catzonas AS zon ON (zon.numerociudad = dir.numerociudad AND zon.numerocolonia = dir.numerocolonia )
					LEFT JOIN bdinteg:"informix".si_catcalles AS cal ON (cal.numerocalle = dir.numerocalle)
					LEFT JOIN bdinteg:"informix".si_sucursales AS suc ON (suc.sucursal = cte.sucursal)
				WHERE cte.empresa = pempresa 
					AND cte.numcte = cNumcte 
					AND dir.secuencia = sSec_dir;
				   
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
				LET sDias = 0;
				LET dTasaBruta = 0;

		    ELSE

				SET LOCK MODE TO WAIT ;
				SET ISOLATION DIRTY READ ;
			
				SELECT NVL(TRIM(cte.razon_social), "") || NVL(TRIM(cte.nombre1), "") || ' ' || NVL(TRIM(cte.nombre2), "") || ' ' || NVL(TRIM(cte.apell_paterno), "") || ' ' || NVL(TRIM(cte.apell_materno), "") AS nombrex,
					suc.nombre, cte.fecha_insert, cte.rfc, dir.numeroextcalle, dir.numerointcalle,
					TRIM(cal.nombrecalle), TRIM(zon.nombrezona), TRIM(ciu.nombre), TRIM(edo.nombre), dir.cod_postal
				INTO cNomcte, cNomSucursal, dFechaAlta, cRFC, cNumExt, cNumInt, cNomCalle, cNomColonia,
					cNomCiudad, cNomEstado, cCodPostal
				FROM bdinteg:"informix".si_cliente AS cte
					LEFT JOIN bdinteg:"informix".si_ctepm AS cpm ON (cpm.numcte = cte.numcte)
					LEFT JOIN bdinteg:"informix".si_direcciones AS dir ON (dir.numcte = cte.numcte)
					LEFT JOIN bdinteg:"informix".si_estados AS edo ON (edo.estado = dir.estado AND edo.pais = "001")
					LEFT JOIN bdinteg:"informix".si_ciudades AS ciu ON (ciu.ciudad = dir.ciudad AND ciu.estado = dir.estado AND ciu.pais = "001")
					LEFT JOIN bdinteg:"informix".si_catzonas AS zon ON (zon.numerociudad = dir.numerociudad AND zon.numerocolonia = dir.numerocolonia )
					LEFT JOIN bdinteg:"informix".si_catcalles AS cal ON (cal.numerocalle = dir.numerocalle)
					LEFT JOIN bdinteg:"informix".si_sucursales AS suc ON (suc.sucursal = cte.sucursal)
				WHERE cte.empresa = pempresa 
					AND cte.numcte = cNumcte 
					AND dir.secuencia = sSec_dir;

		    END IF;
		END IF;
    ELSE
		LET cCodret = "100";
    END IF;

    RETURN  cCodret, cProducto, cNumProducto, cNumTarjeta, cClabe, dFechaini, dFechafin,
			mSaldoAnterior, mDepositos, mInteresesPagados, mRetiros, mOtrosCargos,
			mIvaOtrosCargos, mSaldoCorte, mSaldoPromedio, mRetencionIsr, mInteresesNetos,
			sDias, dTasaBruta, cNumcte, cNomcte, cNumExt,
			cNumInt, cNomCalle, cNomColonia, cNomCiudad, cNomEstado,
			cCodPostal, cRFC, dFechaAlta, cNomSucursal;
	
    END;

END PROCEDURE
DOCUMENT
'CAMBIO     : Armando Mercado F.',
'DESCRIPCION: Se modifico para consultar los movimientos de cuenta a partir de su ultima fecha de corte,',
'             esto sin importar que su ultima fecha corte sea en el mismo mes que se desea consultar',
'Captacion',
'FECHA      : Septiembre 2009',
'VERSION    : 20090908',
'BD         : BDICHEQ',
'Modificó: Héctor Bojórquez',
'Descripción: Para obtener el dato de tasabruta de la tabla "sc_maehis" multiplicado por 100.',
'Fecha: 26/Octubre/2009',
' Modifico  : Gabriela Aguilar',
'Activdad  : Cambio de tabla de sc_maehis hacia  sc_maehis_factelect',
'fecha     : 10/11/2017';

CREATE PROCEDURE "informix".sp_obt_fec_edo_cta_deb(pCuenta char(20))
        RETURNING char(5), char(6), date, date;

    -- Realizo   : Javier Humberto Calderon Zazueta
    -- Actividad : Obetener fechas para estado de cuenta de debito
    -- Solicitó  : Diana Castellanos
    -- Fecha     :  17/07/2008
	
	--------------------------------------------------------------------
	-- Modifico  : Gabriela Aguilar
	-- Activdad  : Cambio de tabla de sc_maehis hacia  sc_maehis_factelect
	-- fecha     : 10/11/2017
	
	
	

       DEFINE vcodret   char(5);
       DEFINE vAnioMes  char(6);
       DEFINE vFechaFin date;
       DEFINE vFechaIni date;
       DEFINE sql_err integer;

ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
        LET vcodret = sql_err;
        RETURN vcodret, vAnioMes, vFechaIni, vFechaFin;
       END IF;
END EXCEPTION;

LET vcodret = '000';
LET vAnioMes = '000000';
LET vFechaIni = '01/01/1900';
LET vFechaFin = '01/01/1900';
BEGIN

	--SET DEBUG FILE TO "/informix/gaby/ArchivosOut/sp_obt_fec_edo_cta_deb.out";
	--TRACE ON;


   SET ISOLATION DIRTY READ ;
   set lock mode to wait 3;

    FOREACH
        SELECT LIMIT 3 aniomes, fechaini, fechafin
        INTO vAnioMes, vFechaIni, vFechaFin
        --FROM sc_maehis
		FROM sc_maehis_factelect
        WHERE empresa = '001'
        AND cuenta = pCuenta
        ORDER BY fechaini DESC


        --IF vAnioMes IS NULL THEN
        --  LET vcodret = '100';
        --  RETURN vcodret, vAnioMes, vFechaIni, vFechaFin;
        --END IF;
        RETURN vcodret, vAnioMes, vFechaIni, vFechaFin WITH RESUME;
    END FOREACH;
END;

END PROCEDURE;