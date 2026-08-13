CREATE PROCEDURE "informix".cuenta2_pba(pempresa CHAR(3),
                         pusuario       CHAR(8),
                         psucursal      CHAR(4),
                         pproducto      CHAR(4),
                         pnum_cte       CHAR(20),
                         pnum_cot       CHAR(2),
                         pclase_cta     CHAR(1),
                         preg_firmas    CHAR(1),
                         ptipo_bca      CHAR(3),
                         pejecutivo     CHAR(8),
                         penvio_direcc  CHAR(1),
                         pcuenta        CHAR(20),
                         pdirecc_envio  SMALLINT,
                         pcliente2      CHAR(20),
                         pnombre        CHAR(50),
                         pinstcap       CHAR(2),
                         pcuentacap     CHAR(20),
                         pinstint       CHAR(2),
                         pcuentaint     CHAR(20),
                         pplazo         SMALLINT,
                         pcobraISr      CHAR(1),
			 pproced_aperturacta 	CHAR(2),
  			 pproced_mantenercta 	CHAR(2),
			 pmonto_mensual 	CHAR(2),
			 pdepositos_cantidad 	CHAR(2),
		         pdepositos_monto 	CHAR(2),
			 pretiros_cantidad 	CHAR(2),
			 pretiros_monto 	CHAR(2),
			 pformaapert            CHAR(2),
		         pmtoapertura           MONEY(14,2),
                         pempemp                INTEGER,
                         pnomina                INTEGER)

RETURNING CHAR(5),CHAR(20),CHAR(18);

   DEFINE vcodret CHAR(5);
   DEFINE vpago_capital,vpago_interes,vpaga_interes,
          vpaga_capital,vexiste CHAR(1);
   DEFINE vplaza CHAR(3);
   DEFINE vdIFerencia,vlongcta SMALLINT;
   DEFINE vfecha,vfecha_ini,vfecha_fin DATE;
   DEFINE vfecpagoint,vfecpagocap,vfeciniape,
          vfecfinape DATEtime month to DAY;
   DEFINE i SMALLINT;
   DEFINE vplazomin,vplazomax SMALLINT;
   DEFINE vsqlerr INTEGER;
   DEFINE vultpagocap, vultpagoint DATE;
   DEFINE vdivISa,vdivISacta CHAR(2);
   DEFINE vsistcap,vsIStint,vsiglas CHAR(2);
   DEFINE vrequiere_cta CHAR(1);
   DEFINE vtipocte1,vtipocte2,vtipocte3,vtipocte4,vtipocte5 CHAR(1);
   DEFINE ves_fisica,vtipo_cliente,vtpper_valida,vtpcte_valido CHAR(1);
   DEFINE vsignumcta INTEGER;
   DEFINE vdigverif CHAR(1);
   DEFINE vctaclabe CHAR(18);

   DEFINE vparamsigcta   CHAR(20);
   DEFINE vidcta         CHAR(1);
   DEFINE vtasavariable  CHAR(1);
   DEFINE vtasaprod      CHAR(8);
   DEFINE vvalorvariable DECIMAL(9,6);
   DEFINE vtipotasa      CHAR(1);
   DEFINE vfechaperiodo  DATE;
   DEFINE vProdCrec      CHAR(4);
   DEFINE vMtoMinimo     DECIMAL(14,2);
   DEFINE vprodNom       CHAR(4);
   DEFINE vprodplus      CHAR(4);
   DEFINE vprodnomba     CHAR(4);
   
begin
   on exception set vsqlerr
      IF vsqlerr <> 0 THEN
         LET vcodret = vsqlerr;
         RETURN vcodret,pcuenta,vctaclabe;
      END IF;
   END exception;

    --SET DEBUG FILE TO "/tmp/cuenta1.out";
    --TRACE ON;

-- Inicializa variables
   LET vcodret  = "000";
   LET vctaclabe = "";
   LET pcobraISr = "S"; -- Para Bancoppel

   LET vparamsigcta   ="?";
   LET vidcta         ="?";
   LET vtasavariable  = "?";
   LET vtasaprod      = "?";
   LET vvalorvariable = 0;
   LET vtipotasa      = "?";
   LET vfechaperiodo  = "";
   LET vplazomax      = 0;
   LET vprodNom       = "";
   LET vprodplus      = "";
   LET vprodnomba     = "";

    CALL valcteprod(pempresa,pnum_cte,pproducto) RETURNING vcodret;
				  IF vcodret <> "000" THEN
					-- LET vcodret = '126';
					 RETURN vcodret,pcuenta,vctaclabe;
				  END IF;
   
   SELECT sIStema INTO vsistcap
      FROM bdinteg:si_sistema
      WHERE siglas = "SC";
   LET vsIStint = vsistcap;

   SELECT fecha_hoy INTO vfecha FROM sc_fechas
      WHERE empresa = pempresa;
   LET vultpagocap = vfecha;
   LET vultpagoint = vfecha;

   SELECT valor INTO vprodNom
   FROM   sc_param
   WHERE  codparam = "PRODNOMI";
   IF vprodNom IS NULL THEN
      LET vcodret = "106";

      RETURN vcodret,pcuenta,vctaclabe;
   END IF

   SELECT valor INTO vprodplus
   FROM   sc_param
   WHERE  codparam = "PRODPLUS";

   SELECT valor INTO vprodnomba
   FROM   sc_param
   WHERE  codparam = "PRODNOMBA";
   
   IF pcuenta IS NULL THEN
      LET pcuenta = " ";
   END IF

   IF penvio_direcc = "0" THEN
      select secuencia
	  into pdirecc_envio
	  from bdinteg:si_direcciones_actual 
	  where numcte = pnum_cte and tipo_dir='1';
	  
	  --LET pdirecc_envio = "1";
   END IF;



-- Valida la informacion de entrada
   IF pusuario       = "" OR
      psucursal      = "" OR
      pproducto      = "" OR
      pnum_cte       = "" OR
      pnum_cot       = "" OR
      pclase_cta     = "" OR
      ptipo_bca      = "" OR
      pejecutivo     = "" OR
      penvio_direcc  = "" OR
      pdirecc_envio  = "" OR
	pproced_aperturacta 	= "" OR
	pproced_mantenercta 	= "" OR
	pmonto_mensual 		= "" OR
	pdepositos_cantidad 	= "" OR
	pdepositos_monto 		= "" OR
	pretiros_cantidad 	= "" OR
	pretiros_monto 		= "" THEN
      LET vcodret = "110";
      RETURN vcodret,pcuenta,vctaclabe;
   END IF;
   IF vprodNom = pproducto OR vprodplus = pproducto OR vprodnomba = pproducto THEN
      IF pempemp = "" or pnomina = "" THEN
         LET vcodret = "110";
         RETURN vcodret,pcuenta,vctaclabe;
      END IF    
   END IF

   SELECT TRIM(valor)
     INTO vProdCrec
     FROM sc_param
    WHERE empresa = pempresa
      AND codparam ="PRODCREC";

   IF vProdCrec IS NULL THEN
      LET vcodret = "106";
      RETURN vcodret,pcuenta,vctaclabe;
   END IF;

   IF pproducto = vProdCrec THEN
	SELECT mtominape INTO vMtoMinimo
	  FROM sc_producto
	 WHERE empresa = pempresa
	   AND producto = pproducto;

	IF vMtoMinimo > pmtoapertura THEN
           LET vcodret = "310";
           RETURN vcodret,pcuenta,vctaclabe;
	END IF

   END IF


   SELECT 1 INTO vexiste FROM bdinteg:si_ejecut
      WHERE ejecutivo = pusuario;
   IF vexiste IS NULL THEN
      LET vcodret = "106";
      RETURN vcodret,pcuenta,vctaclabe;
   END IF;

-- Valida la clase de cuenta 1 = cuenta normal,2 = cuenta de cortesia
   IF pclase_cta != 1 AND pclase_cta != 2 THEN
      LET vcodret = "011";
      RETURN vcodret,pcuenta,vctaclabe;
   END IF;

-- Valida el regimen de firmas 1 = individual,2 = indIStinta,3 = mancomunada
   IF preg_firmas != "1" AND
      preg_firmas != "2" AND
      preg_firmas != "3" THEN
      LET vcodret = "112";
      RETURN vcodret,pcuenta,vctaclabe;
   END IF;

-- Validar el envio de direccion 0 = Domicilio,1 = Sucursal  3 = Sucursal s/imp
   IF penvio_direcc != "0" AND penvio_direcc != "1" AND
      penvio_direcc != "3" THEN
      LET vcodret = "113";
      RETURN vcodret,pcuenta,vctaclabe;
   END IF;

-- Valida el numero de cliente contra la tabla bdinteg:si_cliente
   SELECT es_fisica,tipo_cliente INTO ves_fisica,vtipo_cliente
      FROM bdinteg:si_cliente cl, bdinteg:si_tipper tp
      WHERE numcte = pnum_cte AND cl.tpo_persona = tp.tpo_persona;
   IF ves_fisica IS NULL THEN
      LET vcodret = "104";
      RETURN vcodret,pcuenta,vctaclabe;
   END IF;

-- Validar la direccion de envio
   IF penvio_direcc = "0" THEN
      SELECT 1 INTO vexiste FROM bdinteg:si_direcciones_actual
         WHERE numcte = pnum_cte AND secuencia = pdirecc_envio;
      IF vexiste IS NULL THEN
         LET vcodret = "130";
         RETURN vcodret,pcuenta,vctaclabe;
      END IF;
   END IF

-- Valida la sucursal contra la tabla bdinteg:si_sucursales
   SELECT 1,plaza INTO vexiste,vplaza
      FROM bdinteg:si_sucursales
      WHERE empresa = pempresa AND sucursal = psucursal;
   IF vexiste IS NULL THEN
      LET vcodret = "102";
      RETURN vcodret,pcuenta,vctaclabe;
   END IF;

-- Validar el tipo de banca contra la tabla bdinteg:si_tpbanca
   SELECT 1 INTO vexiste FROM bdinteg:si_tpbanca
      WHERE banca = ptipo_bca;
   IF vexiste IS NULL THEN
      LET vcodret = "105";
      RETURN vcodret,pcuenta,vctaclabe;
   END IF;

-- Validar el ejecutivo contra la tabla bdinteg:si_ejecut
   SELECT 1 INTO vexiste FROM bdinteg:si_ejecut
      WHERE ejecutivo = pejecutivo;
   IF vexiste IS NULL THEN
      LET vcodret = "106";
      RETURN vcodret,pcuenta,vctaclabe;
   END IF;

-- Valida la Longitud a Considerar para el Numero de Cuenta
   SELECT valOR INTO vlongcta
      FROM sc_param
      WHERE empresa = pempresa AND codparam = "longcta";
   IF vlongcta IS NULL THEN
      LET vcodret = "107";
      RETURN vcodret,pcuenta,vctaclabe;
   END IF;

   LET pproducto = pproducto;
   LET pempresa = pempresa;

-- Valida el producto
   -- *************************************************************************
   -- La columna manten_valOR contiene el identIFicadOR de la cuenta axl'07
   -- La columna paga dividENDos identIFica si la cluenta maneja tasa variable
   -- *************************************************************************
   SELECT paga_interes,tipo_dias_calc,feciniape,fecfinape,paga_capital,
          fecpagocap,fecpagoint,divISa,pago_capital,plazomin,plazomax,
          tpper_valida,tpcte_valido, manten_valor, paga_dividENDo,
	  tasa
      INTO vpaga_interes,vpago_interes,vfeciniape,vfecfinape,vpaga_capital,
           vfecpagocap,vfecpagoint,vdivISa,vpago_capital,vplazomin,vplazomax,
           vtpper_valida,vtpcte_valido, vidcta, vtasavariable, vtasaprod
      FROM sc_producto
      WHERE empresa = pempresa AND producto = TRIM(pproducto);
   IF vpaga_interes IS NULL THEN
      LET vcodret = "103";
      RETURN vcodret,pcuenta,vctaclabe;
   END IF;

-- Valida el tipo de persona permitido
  -- IF ves_fisica = "N" AND vtpper_valida = "1" THEN
    --  LET vcodret = "020";
     -- RETURN vcodret,pcuenta,vctaclabe;
  -- END IF

-- Valida el tipo de cliente permitido
   LET vtpcte_valido = rpad(TRIM(vtpcte_valido),5,"X");
   LET vtipocte1 = SUBSTR(vtpcte_valido,1,1);
   LET vtipocte2 = SUBSTR(vtpcte_valido,2,1);
   LET vtipocte3 = SUBSTR(vtpcte_valido,3,1);
   LET vtipocte4 = SUBSTR(vtpcte_valido,4,1);
   LET vtipocte5 = SUBSTR(vtpcte_valido,5,1);
   IF vtipo_cliente <> vtipocte1 AND vtipo_cliente <> vtipocte2 AND
      vtipo_cliente <> vtipocte3 AND vtipo_cliente <> vtipocte4 AND
      vtipo_cliente <> vtipocte5 THEN
      LET vcodret = "021";
      RETURN vcodret,pcuenta,vctaclabe;
   END IF

-- Valida el periodo de apertura de la cuenta
   LET vfecha_ini = mdy(month(vfeciniape),DAY(vfeciniape),YEAR(vfecha));
   LET vfecha_fin = mdy(month(vfecfinape),DAY(vfecfinape),YEAR(vfecha));
   IF vfecha_ini > vfecha THEN
      LET vfecha_ini = vfecha_ini - 1 UNITS YEAR;
   END IF
   IF vfecha_fin <= vfecha_ini THEN
      LET vfecha_fin = vfecha_fin + 1 UNITS YEAR;
   END IF
   IF vfecha BETWEEN vfecha_ini AND vfecha_fin THEN
   else
      LET vcodret = "402";
      RETURN vcodret,pcuenta,vctaclabe;
   END IF

-- Valida pago de capital
   IF vpaga_capital = "S" THEN
      IF pinstcap <> "" THEN
         SELECT sIStema,requiere_cta INTO vsistcap,vrequiere_cta
            FROM sc_instrucc
            WHERE empresa = pempresa AND instrucc = pinstcap;
         IF vrequiere_cta = "S" THEN
            SELECT siglas INTO vsiglas
               FROM bdinteg:si_sistema
               WHERE sIStema = vsistcap;
            IF vsiglas = "SC" THEN
               SELECT divISa INTO vdivISacta
                  FROM sc_maechq mc, sc_producto pr
                  WHERE mc.empresa = pempresa AND cuenta = pcuentacap AND
                        pr.empresa = mc.empresa AND pr.producto = mc.producto;
               IF vdivISacta IS NULL THEN
                  LET vcodret = "100";
                  RETURN vcodret,pcuenta,vctaclabe;
               END IF
               IF vdivISacta <> vdivISa THEN
                  LET vcodret = "905";
                  RETURN vcodret,pcuenta,vctaclabe;
               END IF
            END IF
         else
            LET pcuentacap = " ";
         END IF
      END IF
  END IF

-- Valida pago de interes
   IF vpaga_interes = "S" THEN
      IF pinstint <> "" THEN
         SELECT sIStema,requiere_cta INTO vsIStint,vrequiere_cta
            FROM sc_instrucc
            WHERE empresa = pempresa AND instrucc = pinstint;
         IF vrequiere_cta = "S" THEN
            SELECT siglas INTO vsiglas
               FROM bdinteg:si_sistema
               WHERE sIStema = vsIStint;
            IF vsiglas = "SC" THEN
               SELECT divISa INTO vdivISacta
                  FROM sc_maechq mc, sc_producto pr
                  WHERE mc.empresa = pempresa AND cuenta = pcuentaint AND
                        pr.empresa = mc.empresa AND pr.producto = mc.producto;
               IF vdivISacta IS NULL THEN
                  LET vcodret = "100";
                  RETURN vcodret,pcuenta,vctaclabe;
               END IF
               IF vdivISacta <> vdivISa THEN
                  LET vcodret = "905";
                  RETURN vcodret,pcuenta,vctaclabe;
               END IF
            END IF
         else
            LET pcuentaint = " ";
         END IF
      END IF
   END IF

-- Determina numero de cuenta
   -- ******************************************
   -- Extra consecutivo de acuerdo al producto *
   -- ******************************************
   LET vparamsigcta = "signumcta" || TRIM(vidcta);
   IF pcuenta = " " THEN
      SELECT valOR INTO vsignumcta
         FROM sc_param
         WHERE empresa = pempresa AND codparam = TRIM(vparamsigcta);
      IF vsignumcta IS NULL THEN
         LET vcodret = "933";
         RETURN vcodret,pcuenta,vctaclabe;
      END IF
      LET pcuenta = vsignumcta;
      LET vsignumcta = vsignumcta + 1;
      UPDATE sc_param
         set valor = vsignumcta
         WHERE empresa = pempresa AND codparam =  TRIM(vparamsigcta);
      LET vdIFerencia = vlongcta - length(pcuenta) - 3;
      IF vdIFerencia > 0 THEN
         fOR i = 1 to vdIFerencia
             LET pcuenta = "0" || pcuenta; --,vctaclabe; MEL...
         END for;
      END IF
      LET pcuenta = "1" || TRIM(vidcta) || TRIM(pcuenta);
      CALL digver11(pcuenta)
           RETURNING vcodret,vdigverif;
      LET pcuenta = TRIM(pcuenta)||vdigverif;
   END IF
   SELECT 1 INTO vexiste
      FROM sc_maechq WHERE empresa = pempresa AND cuenta = pcuenta;
   IF vexiste IS not NULL THEN
      LET vcodret = "405";
      RETURN vcodret,pcuenta,vctaclabe;
   END IF;
   CALL ctaclabe(pempresa,pcuenta,psucursal)
        RETURNING vcodret,vctaclabe;
   IF vcodret <> "000" THEN
      LET vcodret = "170";
      RETURN vcodret,pcuenta,vctaclabe;
   END IF;
   INSERT INTO sc_maechq
      VALUES (pempresa,pcuenta,psucursal,vplaza,pproducto,
              pnum_cte,"1"," ",0,"N",vfecha," ",0,0," "," ",
              0,pmtoapertura," "," ",0,0,"0"," "," ",0,0,0,0,0,0,0,0,0,
              0,0,0,0,"0",pdirecc_envio,0,0,0," "," ",0,"",
              "",vultpagocap,vultpagoint,pplazo,pcobraISr,
		 pproced_aperturacta,pproced_mantenercta,
		 pmonto_mensual,pdepositos_cantidad,
		 pdepositos_monto,pretiros_cantidad,pretiros_monto,
                 vctaclabe);

   INSERT INTO sc_maenoc
      VALUES(pempresa,pcuenta,"00",pclase_cta,preg_firmas,ptipo_bca,
             pejecutivo,penvio_direcc,0,0," ",0," "," ",0,0,0,0,
             0,0,0,0,pusuario,vfecha," "," ",0,0,vpago_interes,
             " ",0,0,0,0);
   IF pinstcap <> "" THEN
      INSERT INTO sc_maeinstrucc
         VALUES(pempresa,pcuenta,"C",pinstcap,vsistcap,pcuentacap,"N");
   END IF
   IF pinstint <> "" THEN
      INSERT INTO sc_maeinstrucc
         VALUES(pempresa,pcuenta,"I",pinstint,vsIStint,pcuentaint,"N");
   END IF

   IF vProdCrec = pproducto THEN
      INSERT INTO sc_maeinstrucc
         VALUES(pempresa,pcuenta,"R",pformaapert,"01",pcuentacap,"N");
   END IF
   
   -- Actualiza al Cliente si es Producto de Nomina
   IF vprodNom = pproducto OR vprodplus = pproducto OR vprodnomba = pproducto THEN
      UPDATE bdinteg:si_ctepf SET numeric1 = pempemp,
             numeric2 = pnomina
      WHERE  empresa = pempresa and numcte = pnum_cte; 
   END IF

   -- Genera comISiones pOR apertura en caso de que exIStan
   CALL gencomape(pempresa,pcuenta,pproducto) RETURNING vcodret;

RETURN vcodret,pcuenta,vctaclabe;
END
END procedure
DOCUMENT
'DESCRIPCION: Programa que se encarga de realizar la apertura de las    ',
'cuentas de captacion',
'EJECUTADO O LLAMADO POR:',
'Platarforma ',
'AUTOR : Antonio Ruiz Mtz.',
'FECHA : 29/Agosto/2007',
'VERSION: 1.00.0002',
'BD    : BDICHEQ',
'MODIFICACION: Se agrega llamado al procedimiento valcteprod, que se encarga de validar si la edad del cliente, ',
             ' es válida para el producto que se quiere aperturar',
'MODIFICO : Cristian Valentina Aguilar.',
'FECHA : 08/Febrero/2010',
'VERSION: 20100208.1044',
'BD    : BDICHEQ';

CREATE PROCEDURE "informix".pase_cam_pba(pempresa char(3))
   RETURNING CHAR(5);

   DEFINE cod_ret          CHAR(5);
   DEFINE v_statuschq,
          vcancelachq,
          vmca             CHAR(1);
   DEFINE vtipo_docto,
          v_moneda,
          v_tipo           CHAR(2);
   DEFINE vsuc_usuario,
          vsuc_cta,
          vproducto,
          vsucursal        CHAR(4);
   define vcodigo_bco,
          v_plaza,
          vcodigo_causa    CHAR(3);
   DEFINE vcausa_dev       CHAR(5);
   DEFINE vtransacc,
          tran,
          vnum_remesa      CHAR(4);
   DEFINE vusuario         CHAR(8);
   DEFINE vcuenta,
          vcuenta_aux      CHAR(20);
   DEFINE v_no_cheque      CHAR(10);
   DEFINE v_stts           CHAR(28);
   DEFINE vimporte,
          v_comision,
          v_iva,
          v_total_com      MONEY(14,2);
   DEFINE vsecuencia       INTEGER;
   DEFINE vnum_cheq        CHAR(10);   -- NCB 6/Ene/97
   DEFINE vnum_serial,
          sql_err,
          vfolio,
          v_rowid          INTEGER;
   DEFINE vfecha date;
   DEFINE v_fech_hor,
          vw_fech_hor       DATETIME YEAR TO SECOND;
   DEFINE vt_moneda_docto   CHAR(2);
   DEFINE vt_mto_divisa     money(14,2);
   DEFINE v_fecha           DATETIME YEAR TO DAY;
   DEFINE v_fecha_hora      CHAR(19);
   DEFINE vcodigo_mn        CHAR(2);
   DEFINE vmoneda           CHAR(2);
   DEFINE vsistrans         CHAR(2);
   DEFINE vsischeq          CHAR(2);
   DEFINE FOLIO1,FOLIO2     INTEGER;
   DEFINE FOLIOX            CHAR(16);
   DEFINE FOLIOC            CHAR(5);
   DEFINE hora              DATETIME HOUR TO FRACTION;
   DEFINE vplaza            CHAR(3);
   define vnum_tarjeta      char(16);
   define vmaxsec           smallint;

   -- Inicializa variables
   LET cod_ret       = "000";
   LET vcausa_dev    = " ";
   LET vtransacc     = "000";
   LET vfolio        = 0;
   LET vsecuencia    = 0;
   LET v_fech_hor    = " ";
   LET v_tipo        = " ";

  
   BEGIN
      ON EXCEPTION SET sql_err
         IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret;
         END IF
      END EXCEPTION;

   SELECT codigo_mn INTO vcodigo_mn
      FROM bdinteg:si_param where empresa = pempresa;
   SELECT fecha_hoy INTO vfecha FROM sc_fechas where empresa = pempresa;

   LET v_fecha      = vfecha;
   LET v_fecha_hora = v_fecha || " " || current hour to second;
   LET v_fech_hor   = v_fecha_hora;
   SELECT sistema INTO vsistrans FROM bdinteg:si_sistema
      WHERE siglas = "ST";

   SELECT sistema INTO vsischeq FROM bdinteg:si_sistema
      WHERE siglas = "SC";

-- Lee el movimiento del detalle de camara por cada banco
FOREACH devoluc WITH HOLD FOR
   SELECT sucursal,usuario,codigo_bco,num_remesa,secuencia,numero_cta,
          numero_cheque,importe,tipo_docto,causa_dev,mca_aplic,rowid,
          moneda
          INTO vsucursal,vusuario,vcodigo_bco,vnum_remesa,vsecuencia,
          vcuenta,vnum_cheq,vimporte,vtipo_docto,vcausa_dev,vmca,v_rowid,
          vmoneda
   FROM sc_detcam
   WHERE empresa = pempresa and mca_aplic = "0"
   ORDER BY numero_cta,importe

   SELECT plaza INTO vplaza FROM bdinteg:si_sucursales
      WHERE empresa = pempresa and sucursal = vsucursal;

   LET cod_ret   = "000";
   LET vfolio    = vfolio+1;
   LET vsuc_cta  = " ";
   LET vproducto = " ";
   LET FOLIOX = vsucursal||vusuario||vfolio;

   -- VerIFica sea valida la secuencia del movimiento
   IF vsecuencia IS NULL THEN
      LET cod_ret = "099";
      UPDATE sc_detcam
         SET (mca_aplic) = ("1")
         WHERE rowid = v_rowid;
   END IF

   -- VerIFica el movimiento no haya sido aplicado anteriormente
   IF vmca = "1" THEN
      LET cod_ret = "909";
      CONTINUE FOREACH;
   END IF

   -- VerIFica el tipo del documento
   IF vtipo_docto = "01" THEN                 -- Cheque Propio      (CP)
      LET v_tipo = "CP";
      LET vtransacc = "0231";
      select estado into v_statuschq
         from sc_contch
         where empresa = pempresa and cuenta = vcuenta and numero = vnum_cheq;
      if v_statuschq is null then
         select estado into v_statuschq
            from sc_histch
            where empresa = pempresa and cuenta = vcuenta and
                  numero = vnum_cheq;
         if v_statuschq = "C" then
            LET v_tipo = "CC";
            LET vtipo_docto = "03";
            LET vtransacc = "0000";
         end if
      else
         if v_statuschq = "C" then
            LET v_tipo = "CC";
            LET vtipo_docto = "03";
            LET vtransacc = "0000";
         end if

      end if
   ELSE
     IF vtipo_docto = "03" THEN               -- Cheque CertIFicado (CC)
        LET v_tipo = "CC";
        LET vtransacc = "0000";
     ELSE
       IF vtipo_docto = "04" THEN               -- Giro Bancario      (GB)
          LET v_tipo = "GB";
          LET vtransacc = "0000";
       ELSE
         IF vtipo_docto = "05" THEN               -- Cheque de Caja     (CJ)
            LET v_tipo = "CJ";
            LET vtransacc = "0000";
         ELSE
            LET v_tipo = '  ';
            LET vtransacc = '0000';
         END IF;
       END IF;
     END IF;
   END IF;

   IF v_tipo = "CP" THEN                         -- Cheque Propio
      SELECT sucursal INTO vsuc_usuario
         FROM bdinteg:si_ejecut
         WHERE ejecutivo = vusuario;
      SELECT sucursal,producto,cuenta,plaza
         INTO vsuc_cta,vproducto,vcuenta_aux,v_plaza
         FROM sc_maechq
         WHERE empresa = pempresa and cuenta = vcuenta;
      IF vproducto IS NULL THEN
         LET vcausa_dev = "02";
         LET cod_ret = "100";
      END IF
      SELECT divisa INTO v_moneda
         FROM sc_producto
         WHERE empresa = pempresa and producto = vproducto;

      -- Valida que exista la cuenta en Maestro de Cheques
      IF vcuenta_aux IS NULL THEN
         LET vcausa_dev = "02";
         LET cod_ret = "100";
      END IF;
      select max(secuencia) into vmaxsec
         from sc_tarjeta
         where empresa = pempresa and cuenta = pcuenta and
               tipo_tarjeta = "T";

      select num_tarjeta into vnum_tarjeta
          from sc_tarjeta
          where empresa = pempresa and cuenta = pcuenta and
                secuencia = vmaxsec;

      -- Valida si el documento fue rechazado por el area operativa de camara
      IF vcausa_dev IS NOT NULL  AND vcausa_dev <> " "
         and vcausa_dev <> "000" AND vcausa_dev <> "00"  AND
         vcausa_dev <> "0"  THEN
         INSERT INTO sc_devcam
            VALUES(pempresa,vusuario,vcodigo_bco,vnum_remesa,vsecuencia,
                   vcuenta,vsucursal,vproducto,vnum_cheq,vimporte,vcausa_dev,
                   vmoneda,"A");
         LET hora = current hour to fraction;
         INSERT INTO sc_movdia
         VALUES(0,FOLIOX,vsucursal,vusuario,vfecha,vfecha,hora,"3313",
                vsuc_cta,vproducto,pempresa,vcuenta," ",vnum_cheq,vimporte,
                vimporte,0,0,0," "," ",0," ",vnum_tarjeta,"");
         UPDATE sc_detcam
            SET mca_aplic = "1"
            WHERE rowid = v_rowid;
         UPDATE sc_histcamara
            SET motivo_dev = vcausa_dev
            WHERE empresa = pempresa and nro_cuenta = vcuenta AND
                  nro_cheque = vnum_cheq AND
                  propias = "1";
      ELSE
         IF cod_ret = "000" and vtransacc = "0231" THEN
            call cargon_ref(pempresa,vsucursal,vusuario,vtransacc,
                    "0000", FOLIOX,vcuenta,vnum_cheq,vimporte,v_moneda,
                    "",vnum_tarjeta,"")
                 returning cod_ret,tran;
         END IF;
         IF cod_ret != "000" THEN
            LET  vcodigo_causa  = NULL;
            SELECT codigo INTO vcodigo_causa
               FROM bdinteg:si_coddevcam
               WHERE cod_ret_rel     = cod_ret
                     and sistema_rel = vsischeq;
            IF vcodigo_causa IS NOT NULL OR vcodigo_causa != "" then
               LET vcausa_dev = vcodigo_causa;
            END IF;
            INSERT INTO sc_devcam
               VALUES(pempresa,vusuario,vcodigo_bco,vnum_remesa,vsecuencia,
                      vcuenta,vsucursal,vproducto,vnum_cheq,vimporte,
                      vcausa_dev,vmoneda,"A");
            LET hora = current hour to fraction;
            INSERT INTO sc_movdia
               VALUES(0,FOLIOX,vsucursal,vusuario,vfecha,vfecha,hora,
                      "3313",vsuc_cta,vproducto,pempresa,vcuenta," ",
                      vnum_cheq,vimporte,vimporte,0,0,0," "," ",0," ",
                      vnum_tarjeta,"");
            UPDATE sc_histcamara
               SET motivo_dev = vcausa_dev
               WHERE empresa = pempresa and nro_cuenta = vcuenta AND
                     nro_cheque = vnum_cheq AND
                     propias = "1";
         END IF;
      END IF;
   END IF                                        -- Cheque Propio

   IF v_tipo = "CC" THEN                         -- Cheque CertIFicado
      SELECT moneda INTO vt_moneda_docto FROM bditrans:st_maetrans
         WHERE empresa = pempresa and tipo_docto = "03" and
               num_docto = vnum_cheq and
               num_cargo_cta = vcuenta;
      IF vt_moneda_docto != vcodigo_mn THEN
         LET vt_mto_divisa = vimporte;
      ELSE
         LET vt_mto_divisa = 0;
      END IF
      IF vcausa_dev is not null and vcausa_dev <> " " and vcausa_dev <> "00"
         and vcausa_dev <> "000" and vcausa_dev <> "0" THEN
         INSERT INTO sc_devcam
            VALUES(pempresa,vusuario,vcodigo_bco,vnum_remesa,vsecuencia,vcuenta,
                   vsucursal," ",vnum_cheq,vimporte,vcausa_dev,vmoneda,"A");
         call bditrans:stmovdia(pempresa,vplaza,vsucursal,
             vusuario,v_fech_hor,"7",vt_moneda_docto,"03",vnum_cheq,
             FOLIOX,vcuenta) returning cod_ret;
         call bditrans:stmovdia(pempresa,vplaza,vsucursal,
             vusuario,v_fech_hor,"8",vt_moneda_docto,"03",vnum_cheq,
             FOLIOX,vcuenta) returning cod_ret;
         UPDATE sc_histcamara
            SET motivo_dev = vcausa_dev
            WHERE empresa = pempresa and nro_cuenta = vcuenta AND
                  nro_cheque = vnum_cheq AND
                  propias = "1";
      ELSE
         call bditrans:cert_pag2(pempresa,"CMRA",vsucursal,
                 vusuario, v_fech_hor,vfolio, vcuenta,vnum_cheq,vimporte,
                 vt_mto_divisa,vt_moneda_docto," ",0,vimporte) returning cod_ret;
         IF cod_ret != "000" THEN
            SELECT codigo INTO vcausa_dev
               FROM bdinteg:si_coddevcam
               WHERE cod_ret_rel = cod_ret and sistema_rel = vsistrans;
            IF vcausa_dev IS NULL THEN
               LET vcausa_dev = cod_ret;
            END IF;
            INSERT INTO sc_devcam
               VALUES(pempresa,vusuario,vcodigo_bco,vnum_remesa,vsecuencia,
                      vcuenta,vsucursal," ",vnum_cheq,vimporte,vcausa_dev,
                      vmoneda,"A");
            call bditrans:stmovdia(pempresa,vplaza,vsucursal,
               vusuario,v_fech_hor,"7",vt_moneda_docto,"03",vnum_cheq,
               FOLIOX,vcuenta) returning cod_ret;
            call bditrans:stmovdia(pempresa,vplaza,vsucursal,
               vusuario,v_fech_hor,"8",vt_moneda_docto,"03",vnum_cheq,
               FOLIOX,vcuenta) returning cod_ret;
            UPDATE sc_histcamara
               SET motivo_dev = vcausa_dev
               WHERE empresa = pempresa and nro_cuenta = vcuenta AND
                     nro_cheque = vnum_cheq AND
                     propias = "1";
            SELECT cancela INTO vcancelachq
               FROM sc_devolu
               WHERE codigo = vcausa_dev;
            IF vcancelachq = "S" THEN
               call bditrans:cert_pag2(pempresa,"CANC",
                  vsucursal,vusuario,v_fech_hor,vfolio,vcuenta,vnum_cheq,
                  vimporte,vt_mto_divisa,vt_moneda_docto," ",0,vimporte)
                  returning cod_ret;
            END IF
         END IF
      END IF
   END IF                                        -- Cheque CertIFicado

   IF v_tipo = "GB" THEN                         -- Giro Bancario
      SELECT moneda INTO vt_moneda_docto FROM bditrans:st_maetrans
         WHERE empresa = pempresa and tipo_docto = "04" and
               num_docto = vnum_cheq;
      IF vt_moneda_docto != vcodigo_mn THEN
         LET vt_mto_divisa = vimporte;
      ELSE
         LET vt_mto_divisa = 0;
      END IF
      IF vcausa_dev is not null and vcausa_dev <> " " and
         vcausa_dev <> "00"  and vcausa_dev <> "000"  and vcausa_dev <> "0" THEN
         INSERT INTO sc_devcam
            VALUES(pempresa,vusuario,vcodigo_bco,vnum_remesa,vsecuencia,vcuenta,
                   vsucursal," ",vnum_cheq,vimporte,vcausa_dev,vmoneda,"A");
         call bditrans:stmovdia(pempresa,vplaza,vsucursal,
            vusuario,v_fech_hor,"7",vt_moneda_docto,"04",vnum_cheq,
            FOLIOX,"") returning cod_ret;
         call bditrans:stmovdia(pempresa,vplaza,vsucursal,
            vusuario,v_fech_hor,"8",vt_moneda_docto,"04",vnum_cheq,
            FOLIOX,"") returning cod_ret;
      ELSE
         call bditrans:girbanc(pempresa,"CMRA",vtipo_docto,
            vusuario, v_fech_hor,"0",vsucursal," ",vnum_cheq,
            vt_moneda_docto,vt_mto_divisa,vimporte,
            0,0,0," ",0," ",0,0," "," "," "," "," "," "," "," ")
            returning cod_ret,v_no_cheque,v_comision,v_iva,v_total_com,
                     v_stts,vw_fech_hor;
         IF cod_ret != "000" THEN
            SELECT codigo INTO vcausa_dev
               FROM bdinteg:si_coddevcam
               WHERE cod_ret_rel = cod_ret and sistema_rel = vsistrans;
            IF vcausa_dev IS NULL THEN
               LET vcausa_dev = cod_ret;
            END IF;
            INSERT INTO sc_devcam
            VALUES(pempresa,vusuario,vcodigo_bco,vnum_remesa,vsecuencia,vcuenta,
                   vsucursal," ",vnum_cheq,vimporte,vcausa_dev,vmoneda,"A");
            call bditrans:stmovdia(pempresa,vplaza,vsucursal,
               vusuario,v_fech_hor,"7",vt_moneda_docto,"04",vnum_cheq,
               FOLIOX,"") returning cod_ret;
            call bditrans:stmovdia(pempresa,vplaza,vsucursal,
               vusuario,v_fech_hor,"8",vt_moneda_docto,"04",vnum_cheq,
               FOLIOX,"") returning cod_ret;
         END IF
      END IF
   END IF                                        -- Giro Bancario

   IF v_tipo = "CJ" THEN                         -- Cheque de Caja
      SELECT moneda INTO vt_moneda_docto FROM bditrans:st_maetrans
         WHERE empresa = pempresa and tipo_docto = "05" and
               num_docto = vnum_cheq;
      IF vt_moneda_docto != vcodigo_mn THEN
         LET vt_mto_divisa = vimporte;
      ELSE
         LET vt_mto_divisa = 0;
      END IF
      IF vcausa_dev is not null and vcausa_dev <> " " and vcausa_dev <> "00"
         and vcausa_dev <> "000" and vcausa_dev <> "0" THEN
         INSERT INTO sc_devcam
            VALUES(pempresa,vusuario,vcodigo_bco,vnum_remesa,vsecuencia,vcuenta,
                   vsucursal," ",vnum_cheq,vimporte,vcausa_dev,vmoneda,"A");
         call bditrans:stmovdia(pempresa,vplaza,vsucursal,vusuario,
               v_fech_hor, "7",vt_moneda_docto,"05",vnum_cheq,FOLIOX,"")
               returning cod_ret;
         call bditrans:stmovdia(pempresa,vplaza,vsucursal,vusuario,
               v_fech_hor, "8",vt_moneda_docto,"05",vnum_cheq,FOLIOX,"")
               returning cod_ret;
         UPDATE sc_histcamara
            SET motivo_dev = vcausa_dev
            WHERE empresa = pempresa and nro_cuenta = vcuenta AND
                  nro_cheque = vnum_cheq AND
                  propias = "1";
      ELSE
         call bditrans:chqcaj(pempresa,"CMRA",vtipo_docto,vusuario,
              v_fech_hor,
              "0","0",vsucursal," ",vnum_cheq,vt_moneda_docto,vt_mto_divisa,
              vimporte,0,0,0," ",0," ",0,0," "," "," "," ")
              returning v_comision,v_iva,v_total_com,v_stts,vw_fech_hor,
                   cod_ret,v_no_cheque;
         IF cod_ret != "000" THEN
            SELECT codigo INTO vcausa_dev
               FROM bdinteg:si_coddevcam
               WHERE cod_ret_rel = cod_ret and sistema_rel = vsistrans;
            IF vcausa_dev IS NULL THEN
               LET vcausa_dev = cod_ret;
            END IF;
            INSERT INTO sc_devcam
               VALUES(pempresa,vusuario,vcodigo_bco,vnum_remesa,vsecuencia,
                   vcuenta,
                   vsucursal," ",vnum_cheq,vimporte,vcausa_dev,vmoneda,"A");
            call bditrans:stmovdia(pempresa,vplaza,vsucursal,vusuario,
                v_fech_hor, "7",vt_moneda_docto,"05",vnum_cheq,FOLIOX,"")
                returning cod_ret;
            call bditrans:stmovdia(pempresa,vplaza,vsucursal,vusuario,
                v_fech_hor,"8",vt_moneda_docto,"05",vnum_cheq,FOLIOX,"")
                returning cod_ret;
            UPDATE sc_histcamara
              SET motivo_dev = vcausa_dev
              WHERE empresa = pempresa and nro_cuenta = vcuenta AND
                    nro_cheque = vnum_cheq AND
                    propias = "1";

            SELECT cancela INTO vcancelachq
               FROM sc_devolu
               WHERE codigo = vcausa_dev;
            IF vcancelachq = "S" THEN
               call bditrans:chqcaj(pempresa,"CANC",vtipo_docto,
                     vusuario,v_fech_hor,"0","0",vsucursal," ",vnum_cheq,
                     vt_moneda_docto,vt_mto_divisa,
                     vimporte,0,0,0," ",0," ",0,0," "," "," "," ")
                     returning v_comision,v_iva,v_total_com,v_stts,vw_fech_hor,
                          cod_ret,v_no_cheque;
            END IF
         END IF
      END IF
   END IF                                        -- Cheque de Caja
   -- Actualiza marca de movimiento aplicado en el detalle de camara
   UPDATE sc_detcam
      SET mca_aplic = "1",
          tipo_docto = vtipo_docto,
          causa_dev =  vcausa_dev
      WHERE rowid = v_rowid;

   INSERT INTO sc_valpase
      VALUES(pempresa,v_tipo,vcuenta,cod_ret);
   LET cod_ret   = "000";
END FOREACH

RETURN cod_ret;
END
END PROCEDURE;