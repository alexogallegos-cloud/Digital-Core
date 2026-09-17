CREATE PROCEDURE "informix".cuenta1_app( pempresa 			 CHAR(3),
									 pusuario    		     CHAR(8),
									 psucursal   		     CHAR(4),
									 pproducto    		   CHAR(4),
									 pnum_cte      		   CHAR(20),
									 pnum_cot      		   CHAR(2),
									 pclase_cta   		   CHAR(1),
									 preg_firmas  		   CHAR(1),
									 ptipo_bca     		   CHAR(3),
									 pejecutivo    		   CHAR(8),
									 penvio_direcc 		   CHAR(1),
									 pcuenta      		   CHAR(20),
									 pdirecc_envio  	   SMALLINT,
									 pcliente2     		   CHAR(20),
									 pnombre      		   CHAR(50),
									 pinstcap     		   CHAR(2),
									 pcuentacap   		   CHAR(20),
									 pinstint     		   CHAR(2),
									 pcuentaint   	     CHAR(20),
									 pplazo        		   SMALLINT,
									 pcobraISr   	       CHAR(1),
									 pproced_aperturacta CHAR(2),
									 pproced_mantenercta CHAR(2),
									 pmonto_mensual 	   CHAR(2),
									 pdepositos_cantidad CHAR(2),
									 pdepositos_monto	   CHAR(2),
									 pretiros_cantidad   CHAR(2),
									 pretiros_monto 	   CHAR(2),
									 pformaapert         CHAR(2),
									 pmtoapertura        MONEY(14,2))

RETURNING CHAR(5),CHAR(20),CHAR(18);

	DEFINE vcodret          CHAR(5);
	DEFINE vcodret2         CHAR(5);
	DEFINE vcodret3         CHAR(6);
	DEFINE vdesccodret3     CHAR(80);
	DEFINE vpago_capital,
				 vpago_interes,
				 vpaga_interes,
				 vpaga_capital,
				 vexiste           CHAR(1);
	DEFINE vplaza            CHAR(3);
	DEFINE vdIFerencia,
				vlongcta SMALLINT;
		DEFINE vfecha,
					vfecha_ini,
				vfecha_fin DATE;
		DEFINE vfecpagoint,
					vfecpagocap,
				vfeciniape,
				vfecfinape DATEtime MONTH TO DAY;
		DEFINE i SMALLINT;
		DEFINE vplazomin,
					vplazomax SMALLINT;
		DEFINE vsqlerr INTEGER;
		DEFINE vultpagocap,
						vultpagoint DATE;
		DEFINE vdivISa,
					vdivISacta CHAR(2);
		DEFINE vsistcap,
					vsIStint,
				vsiglas CHAR(2);
		DEFINE vrequiere_cta CHAR(1);
		DEFINE vtipocte1,
					vtipocte2,
				vtipocte3,
				vtipocte4,
				vtipocte5 CHAR(1);
		DEFINE ves_fisica,
					vtipo_cliente,
				vtpper_valida,
				vtpcte_valido CHAR(1);
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
		DEFINE vmarca_ret     CHAR (1);
		DEFINE vAlchepro      CHAR(1);
		DEFINE vTipocheq      CHAR(2);
		DEFINE iMaxCtas	       	INTEGER;
			DEFINE iNCuentas       	INTEGER;
			DEFINE iExiste			INTEGER;
			DEFINE cStatus_cta		CHAR(1);
			DEFINE sSecuencia		SMALLINT;
		DEFINE cPROACProducto	CHAR(4);
		DEFINE cFecFormat2 		CHAR(25);
		DEFINE cFecFormat1 		CHAR(25);
		DEFINE dFecha_siganio	DATE;
		DEFINE cProducto		CHAR(10);
		DEFINE cRecValor		CHAR(20);
		DEFINE cCodRetSp        CHAR(5);
			DEFINE correoCli        CHAR(100);
		DEFINE celularCli       CHAR(13);
		DEFINE cCodRetSp1       CHAR(5);
		DEFINE cCodRetSp2       CHAR(5);
		DEFINE nombreCuenta     CHAR(100);


		DEFINE vtransaccion     integer;
		DEFINE iExistCuenta     integer;
		DEFINE vcodret_firm     CHAR(5);
		
	
	LET vcodret3 		= '000000';
	LET vdesccodret3    = 'PROCESO EXITOSO';
	LET cCodRetSp        = '00000';
	LET correoCli         ='';
	LET celularCli        ='';
	LET cCodRetSp1        = '00000';
	LET cCodRetSp2        = '00000';
	LET nombreCuenta      ='';
	LET vdiferencia = 0;
	
	
BEGIN
  ON EXCEPTION SET vsqlerr
    IF vsqlerr <> 0 THEN
      LET vcodret = vsqlerr;
      RETURN vcodret,pcuenta,vctaclabe;
    END IF;
  END EXCEPTION;

	ON EXCEPTION IN (-535)
		LET vtransaccion = 1;
	END EXCEPTION WITH RESUME;


		-- SET DEBUG FILE TO "/informix/FAOC/Debug/Inv/cuenta1_app.out";
		-- TRACE ON;

    SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;  

    

		

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

	LET iMaxCtas		= 0;
	LET iNCuentas		= 0;
	LET iExiste			= 0;
	LET cStatus_cta		= "";
	LET sSecuencia		= 0;
	LET  cPROACProducto	= "";

	LET  cFecFormat2 	= "";
	LET  cFecFormat1 	= "";
	LET  dFecha_siganio	= "01/01/1900";
	LET  cProducto		= "";
	LET  cRecValor		= "";

	LET vcodret2 		= '';

	LET vtransaccion = 0;
	LET iExistCuenta = 0;

   --******************************			PROAC			************************************
	--**********************************************************************************************
	--**********************************************************************************************
	--**********************************************************************************************
	--Consulta el parametro del producto de PROAC.
	/*
	SELECT valor INTO cPROACProducto FROM bdicheq:"informix".sc_param WHERE codparam = 'PROACPRODUCTO';
	IF cPROACProducto = '' OR cPROACProducto IS NULL THEN
		LET vcodret = '90001';
		LET vctaclabe = 'PRODUCTO NO IDENTIFICADO';
        RETURN vcodret, pcuenta, vctaclabe;
	END IF;

	IF TRIM(cPROACProducto) = TRIM(pproducto) THEN
		--VALIDAR QUE VENGA LA CUENTA EJE PARA ASOCIAR LA CUENTA PROAC
		IF pCliente2 = '' OR pCliente2 IS NULL THEN
			LET vcodret = '90007';
			LET vctaclabe = 'ES NECESARIO CUENTA EJE';
		END IF;

		--Consulta cuantas cuentas por cliente puede tener el PROAC
		SELECT valor INTO iMaxCtas FROM bdicheq:"informix".sc_param WHERE codparam = 'PROACMAXCTAS';

		SELECT COUNT(cuenta) INTO iNCuentas
		FROM bdicheq:"informix".sc_proac
		WHERE num_cte = pnum_cte
		AND status_cta ='1';

		IF	iNCuentas >= iMaxCtas  THEN
			LET iExiste = 0;
			LET vcodret = "90002";
			LET vctaclabe = "Cliente Con El Maximo De Cuentas Permitidas";
			RETURN vcodret,pcuenta,vctaclabe;
		END IF;

		--Valida que no exista la cuenta eje en alguna otra cuenta PROAC
		SELECT status_cta INTO cStatus_cta
		FROM bdicheq:"informix".sc_proac
		WHERE cta_eje = pCliente2
		AND secuencia = (SELECT MAX(secuencia) FROM bdicheq:"informix".sc_proac WHERE cta_eje = pCliente2);

		IF	cStatus_cta = "1"  THEN
			LET vcodret = "90003";
			LET vctaclabe = "Cuenta Eje ya Tiene Cuenta PROAC";
			RETURN vcodret,pcuenta,vctaclabe;
		END IF;
		IF	cStatus_cta = "2"  THEN

		END IF;
		IF	cStatus_cta = "3"  THEN
			LET vcodret = "90004";
			LET vctaclabe = "Bloqueada Cuenta PROAC";
			RETURN vcodret,pcuenta,vctaclabe;
		END IF;
		IF	cStatus_cta = "4"  THEN
			LET vcodret = "90005";
			LET vctaclabe = "Cuenta Eje ya Tiene Reinscrita la Cuenta PROAC";
			RETURN vcodret,pcuenta,vctaclabe;
		END IF;

		SELECT COUNT(cta_eje) INTO iNCuentas
		FROM bdicheq:"informix".sc_proac
		WHERE cta_eje = pCliente2;
		LET iNCuentas = iNCuentas;

		--Obtener la secuencia maxima.
		SELECT 1,NVL(MAX(secuencia),0) INTO iExiste,sSecuencia
		FROM bdicheq:"informix".sc_proac
		WHERE cta_eje = pCliente2
		AND secuencia = (SELECT MAX(secuencia) FROM bdicheq:"informix".sc_proac WHERE cta_eje = pCliente2)
		AND status_cta <> '1';

		IF	iExiste = 1  THEN
			LET iExiste = 0;
			LET sSecuencia = sSecuencia +1;
		END IF;
		IF sSecuencia = "" THEN
			LET sSecuencia = 1;
		END IF;

		--Consulta los datos que va a heredar de la cuenta eje
		SELECT  CobraISr,proced_aperturacta,proced_mantenercta,monto_mensual,depositos_cantidad,
				depositos_monto,retiros_cantidad,retiros_monto,'PROAC_'|| TRIM(producto)
		INTO 	pcobraISr,pproced_aperturacta, pproced_mantenercta, pmonto_mensual, pdepositos_cantidad,
				pdepositos_monto, pretiros_cantidad, pretiros_monto,cProducto
		FROM bdicheq:"informix".sc_maechq Mae
		WHERE mae.cuenta = pCliente2;

		--Consulta y valida el producto para verificar si participa o no en el PROAC
		LET cProducto = TRIM(cProducto) ;
		SELECT valor INTO cRecValor FROM bdicheq:"informix".sc_param WHERE codparam = TRIM(cProducto);

		IF cRecValor IS NULL THEN
			LET vcodret = "90006";
			LET vctaclabe = "El Producto No Es Participante";
			RETURN vcodret,pcuenta,vctaclabe;
			LET iExiste = 0;
		END IF;
	END IF;
	*/
	--******************************			FIN PROAC			********************************
	--**********************************************************************************************
	--**********************************************************************************************
	--**********************************************************************************************
/*
	EXECUTE PROCEDURE "informix".valcteprod(pempresa,	pnum_cte,pproducto)
	INTO vcodret;

	IF vcodret <> "000" THEN

		RETURN vcodret,pcuenta,vctaclabe;
	END IF;

*/
	SELECT sIStema
	INTO vsistcap
	FROM bdinteg:"informix".si_sistema
	WHERE siglas = "SC";

	LET vsIStint = vsistcap;


	SELECT fecha_hoy
	INTO vfecha
	FROM bdicheq:"informix".sc_fechas
	WHERE empresa = pempresa;

	LET vultpagocap = vfecha;
	LET vultpagoint = vfecha;

	IF pcuenta IS NULL THEN
	   LET pcuenta = " ";
	END IF

--IF penvio_direcc = "0" THEN
--   LET pdirecc_envio = "1";
--END IF;


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

    SELECT TRIM(valor)
	INTO vProdCrec
	FROM bdicheq:"informix".sc_param
	WHERE empresa = pempresa
	AND codparam ="PRODCREC";

	IF vProdCrec IS NULL THEN
		LET vcodret = "106";
		RETURN vcodret,pcuenta,vctaclabe;
	END IF;

	IF pproducto = vProdCrec THEN
		SELECT mtominape INTO vMtoMinimo
		FROM bdicheq:"informix".sc_producto
		WHERE empresa = pempresa
		AND producto = pproducto;

		IF vMtoMinimo > pmtoapertura THEN
			LET vcodret = "310";
			RETURN vcodret,pcuenta,vctaclabe;
		END IF
	END IF
/*
	SELECT 1 INTO vexiste FROM bdinteg:"informix".si_ejecut
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
*/
-- Valida el numero de cliente contra la tabla bdinteg:si_cliente
	SELECT es_fisica,tipo_cliente INTO ves_fisica,vtipo_cliente
	FROM bdinteg:"informix".si_cliente cl, bdinteg:"informix".si_tipper tp
	WHERE numcte = pnum_cte AND cl.tpo_persona = tp.tpo_persona;
	
	IF ves_fisica IS NULL THEN
		LET vcodret = "104";
		RETURN vcodret,pcuenta,vctaclabe;
	END IF;

-- Validar la direccion de envio
/*
	IF penvio_direcc =  "0" THEN
		LET pdirecc_envio = pdirecc_envio;
		LET pnum_cte = pnum_cte;

		SELECT 1 INTO vexiste FROM bdinteg:"informix".si_direcciones
		WHERE numcte = pnum_cte AND secuencia = pdirecc_envio;
		
		IF vexiste IS NULL THEN
			LET vcodret = "130";
			RETURN vcodret,pcuenta,vctaclabe;
		END IF;
	END IF;

	IF ves_fisica = "N" THEN
		--Se quito para que la informacion se guarde con la sucursal con la cual se da de alta la cuenta....HMBR
		--LET psucursal = "5001";
		LET vmarca_ret = "1";
	ELSE
		LET vmarca_ret = "0";
	END IF;
	
	IF pproducto = "2400" THEN
	   LET vmarca_ret = "1";
    END IF;	   
*/
-- Valida la sucursal contra la tabla bdinteg:si_sucursales
/*
	SELECT 1,plaza INTO vexiste,vplaza
	FROM bdinteg:"informix".si_sucursales
	WHERE empresa = pempresa AND sucursal = psucursal;
	
	IF vexiste IS NULL THEN
		LET vcodret = "102";
		RETURN vcodret,pcuenta,vctaclabe;
	END IF;
	*/
LET vmarca_ret = 0;
LET vexiste = 1;
LET vplaza = '002';
-- Validar el tipo de banca contra la tabla bdinteg:si_tpbanca
/*
	SELECT 1 INTO vexiste FROM bdinteg:"informix".si_tpbanca
	WHERE banca = ptipo_bca;

	IF vexiste IS NULL THEN
		LET vcodret = "105";
		RETURN vcodret,pcuenta,vctaclabe;
	END IF;
*/
-- Validar el ejecutivo contra la tabla bdinteg:si_ejecut
/*
	SELECT 1 INTO vexiste FROM bdinteg:"informix".si_ejecut
	WHERE ejecutivo = pejecutivo;

	IF vexiste IS NULL THEN
		LET vcodret = "106";
		RETURN vcodret,pcuenta,vctaclabe;
	END IF;
*/
-- Valida la Longitud a Considerar para el Numero de Cuenta
/*
	SELECT valOR INTO vlongcta
	FROM bdicheq:"informix".sc_param
	WHERE empresa = pempresa AND codparam = "longcta";
	
	IF vlongcta IS NULL THEN
		LET vcodret = "107";
		RETURN vcodret,pcuenta,vctaclabe;
	END IF;
	*/
LET vlongcta = 11;
-- Valida el producto

   -- *************************************************************************
   -- La columna manten_valOR contiene el identIFicadOR de la cuenta axl'07
   -- La columna paga dividENDos identIFica si la cluenta maneja tasa variable

   -- *************************************************************************
	SELECT paga_interes,tipo_dias_calc,feciniape,fecfinape,paga_capital,
	fecpagocap,fecpagoint,divISa,pago_capital,plazomin,plazomax,
	tpper_valida,tpcte_valido, manten_valor, paga_dividENDo,
	tasa,val_chequeras
	INTO vpaga_interes,vpago_interes,vfeciniape,vfecfinape,vpaga_capital,
	vfecpagocap,vfecpagoint,vdivISa,vpago_capital,vplazomin,vplazomax,
	vtpper_valida,vtpcte_valido, vidcta, vtasavariable, vtasaprod, vAlchepro
	FROM bdicheq:"informix".sc_producto
	WHERE empresa = pempresa AND producto = '1100';
	
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
/*
	LET vtpcte_valido = RPAD(TRIM(vtpcte_valido),5,"X");
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
*/
-- Valida el periodo de apertura de la cuenta
	LET vfecha_ini = mdy(MONTH(vfeciniape),DAY(vfeciniape),YEAR(vfecha));
	LET vfecha_fin = mdy(MONTH(vfecfinape),DAY(vfecfinape),YEAR(vfecha));  ---->>>

	IF vfecha_ini > vfecha THEN
		LET vfecha_ini = vfecha_ini - 1 UNITS YEAR;
	END IF

	IF vfecha_fin <= vfecha_ini THEN
		LET vfecha_fin = vfecha_fin + 1 UNITS YEAR;
	END IF

	IF vfecha BETWEEN vfecha_ini AND vfecha_fin THEN

	ELSE
		LET vcodret = "402";
		RETURN vcodret,pcuenta,vctaclabe;
	END IF

-- Valida pago de capital
	IF vpaga_capital = "S" THEN
		IF pinstcap <> "" THEN
			SELECT sIStema,requiere_cta INTO vsistcap,vrequiere_cta
			FROM bdicheq:"informix".sc_instrucc
			WHERE empresa = pempresa AND instrucc = pinstcap;
			
			IF vrequiere_cta = "S" THEN
				SELECT siglas INTO vsiglas
				FROM bdinteg:"informix".si_sistema
				WHERE sIStema = vsistcap;

				IF vsiglas = "SC" THEN
					SELECT divISa INTO vdivISacta
					FROM bdicheq:"informix".sc_maechq mc, bdicheq:"informix".sc_producto pr
					WHERE mc.empresa = pempresa AND cuenta = pcuentacap 
					AND pr.empresa = mc.empresa AND pr.producto = mc.producto;
					
					IF vdivISacta IS NULL THEN
						LET vcodret = "100";
						RETURN vcodret,pcuenta,vctaclabe;
					END IF

					IF vdivISacta <> vdivISa THEN
						LET vcodret = "905";
						RETURN vcodret,pcuenta,vctaclabe;
					END IF
				END IF
			ELSE
				LET pcuentacap = " ";
			END IF
		END IF
	END IF

-- Valida pago de interes
	IF vpaga_interes = "S" THEN
		IF pinstint <> "" THEN


			SELECT sIStema,requiere_cta INTO vsIStint,vrequiere_cta
			FROM bdicheq:"informix".sc_instrucc
			WHERE empresa = pempresa AND instrucc = pinstint;
			
			IF vrequiere_cta = "S" THEN
				SELECT siglas INTO vsiglas
				FROM bdinteg:"informix".si_sistema
				WHERE sIStema = vsIStint;

				IF vsiglas = "SC" THEN
					SELECT divISa INTO vdivISacta
					FROM bdicheq:"informix".sc_maechq mc, bdicheq:"informix".sc_producto pr
					WHERE mc.empresa = pempresa AND cuenta = pcuentaint AND
					pr.empresa = mc.empresa AND pr.producto = mc.producto;
					IF vdivISacta IS NULL THEN
						LET vcodret = "100";
						RETURN vcodret,pcuenta,vctaclabe;
					END IF;
					IF vdivISacta <> vdivISa THEN
						LET vcodret = "905";
						RETURN vcodret,pcuenta,vctaclabe;
					END IF;
				END IF;
			ELSE
				LET pcuentaint = " ";
			END IF;
		END IF;
	END IF;

	IF pcuenta = " " THEN
		--crea cuenta inversion
		CALL "informix".sp_creacta_inv(pempresa,pnum_cte,pproducto,pcuenta,vlongcta,vdiferencia,vidcta)
		RETURNING vcodret,pcuenta;
		IF vcodret <> '000' THEN
			RETURN vcodret,pcuenta,vctaclabe;
		END IF;	
	END IF;
		


		--Se valida que la longitud de la cuenta sea la correcta y que solo sean nÃÂÃÂºmeros

		IF length(pcuenta) = vlongcta AND bdinteg:"informix".val_num(pcuenta) THEN

			-- Genera Cuenta CLABE
				IF pproducto = vProdCrec THEN
					LET vctaclabe = "";
				ELSE
					CALL "informix".ctaclabe(pempresa,pcuenta,psucursal)
					RETURNING vcodret,vctaclabe;
					IF vcodret <> "000" THEN
						LET vcodret = "170";
						RETURN vcodret,pcuenta,vctaclabe;
					END IF;
				END IF;

				--06/03/2008
				--Martha Aguirre

				--Se extraen los datos procedencia de la apaertura, procedencia para mantener la cuenta,, monto mensual, cantidad de depositos,
				--cantidad de depositos, cantidad de retiros, monto de retiros
			IF pproducto = "1100" THEN
				SELECT proced_aperturacta, proced_mantenercta, monto_mensual, depositos_cantidad,
				depositos_monto, retiros_cantidad, retiros_monto
				INTO  pproced_aperturacta,pproced_mantenercta, pmonto_mensual,pdepositos_cantidad,
				pdepositos_monto,pretiros_cantidad,pretiros_monto
				FROM bdicheq:"informix".sc_maechq
				WHERE cuenta = pcuentacap AND num_cte = pnum_cte;
			END IF;
			
			UPDATE bdicheq:"informix".sc_maechq SET sucursal = psucursal,
						 plaza = vplaza,
						 status_cta = "1",
						 motivo = " ",
						 ult_chq = 0,
						 colateral = "N",
						 fec_ult_mov = vfecha,
						 fec_cancelac = " ",
						 lim_chq_sbc = 0,
						 imp_chq_sbc = 0,
						 fech_alta_sbc = " ",
						 fech_venc_sbc = " ",
						 lim_chq_rem = 0,
						 imp_chq_rem = pmtoapertura,
						 fech_alta_rem = " ",
						 fech_venc_rem = " ",
						 lim_sbg_ccc = 0,
						 imp_sbg_ccc = 0,
						 tipo_linea = "0",
						 fec_alta_ccc = " ",
						 fech_venc_ccc = " ",
						 imp_int_ccc = 0,
						 sdo_retenido = 0,
						 chq_exp_mes = 0,
						 chq_dev = 0,
						 monto_dev = 0,
						 chq_dev_obco = 0,
						 sdo_cong = 0,
						 num_cgos_mes = 0,
						 imp_cgos_mes = 0,
						 num_abonos_mes = 0,
						 imp_abonos_mes = 0,
						 sdo_actual = 0,
						 sdo_dia_ant = 0,
						 marca_ret = vmarca_ret,
						 direcc_envio = pdirecc_envio,
						 com_pendiente = 0,
						 imp_chq_sbg = 0,
						 imp_int_sbg = 0,
						 fecha_proceso = " ",
						 cuenta_rel = " ",
						 saldo_sbc = 0,
						 fecultdep = "",
						 fecultret = "",
						 ultpagocap = vultpagocap,
						 ultpagoint = vultpagoint,
						 plazo = pplazo,
						 cobraisr = pcobraISr,
						 proced_aperturacta = pproced_aperturacta,
						 proced_mantenercta = pproced_mantenercta,
						 monto_mensual = pmonto_mensual,
						 depositos_cantidad = pdepositos_cantidad,
						 depositos_monto = pdepositos_monto,
						 retiros_cantidad = pretiros_cantidad,
						 retiros_monto = pretiros_monto,
						 cuenta_clabe = vctaclabe
			WHERE empresa = pempresa AND cuenta = pcuenta AND num_cte = pnum_cte;

			INSERT INTO bdicheq:"informix".sc_maenoc
			VALUES(pempresa,pcuenta,"00",pclase_cta,preg_firmas,ptipo_bca,
			pejecutivo,penvio_direcc,0,0," ",0," "," ",0,0,0,0,
			0,0,0,0,pusuario,vfecha," "," ",0,0,vpago_interes,
			" ",0,0,0,0);
	ELSE
		DELETE FROM bdicheq:"informix".sc_maechq WHERE empresa = pempresa AND cuenta = pcuenta AND num_cte = pnum_cte;
		LET vcodret = "131";
		RETURN vcodret,pcuenta,vctaclabe;
	END IF;

--******************************			PROAC			************************************
	--**********************************************************************************************
	--**********************************************************************************************
	--**********************************************************************************************

	IF cPROACProducto = TRIM(pproducto) THEN
		CALL "informix".sp_PROAC_Calc_ProximoAnio(vfecha) RETURNING vcodret2,dFecha_siganio,cFecFormat1,cFecFormat2 ;

		IF iNCuentas >= 1 THEN
			UPDATE bdicheq:"informix".sc_proac SET status_cta = '4' WHERE cta_eje = pCliente2 AND secuencia = sSecuencia -1 ;
		END IF;

		INSERT INTO bdicheq:"informix".sc_proac
		(cuenta,num_cte,cta_eje,secuencia,status_cta,fecha_alta,fecha_canc,sucursal,saldo,prem_proac)
		VALUES
		(pcuenta,pnum_cte,pCliente2,sSecuencia,1,vfecha,dFecha_siganio,pSucursal,0.00,0.00);

		SELECT cuenta_clabe INTO vctaclabe
		FROM bdicheq:"informix".sc_maechq
		WHERE empresa = '001'
		AND cuenta = pcuenta;

	END IF;

	--******************************		FIN PROAC		****************************************
	--**********************************************************************************************
	--**********************************************************************************************
	--**********************************************************************************************

	IF pinstcap <> "" THEN

		INSERT INTO bdicheq:"informix".sc_maeinstrucc
		VALUES(pempresa,pcuenta,"C",pinstcap,vsistcap,pcuentacap,"N");
	END IF

	IF pinstint <> "" THEN

		INSERT INTO bdicheq:"informix".sc_maeinstrucc
		VALUES(pempresa,pcuenta,"I",pinstint,vsIStint,pcuentaint,"N");
	END IF

	IF vProdCrec = pproducto THEN

		INSERT INTO bdicheq:"informix".sc_maeinstrucc
		VALUES(pempresa,pcuenta,"R",pformaapert,"01",pcuentacap,"N");
	END IF

	-- Genera comISiones pOR apertura en caso de que exIStan
	CALL "informix".gencomape(pempresa,pcuenta,pproducto) RETURNING vcodret;

	--  LLAMADO AL PROCESO QUE DA DE ALTA LA CUENTA EN LOS INDICADORES
	EXECUTE PROCEDURE "informix".sp_insertar_fila_indicador(pcuenta,vfecha,pproducto,psucursal)
	INTO vcodret3,vdesccodret3;


	SELECT LIMIT 1 correo_elec --Obtiene el correo que del cliente
	INTO correoCli 
	FROM bdinteg:"informix".si_correos 
	WHERE numcte=pnum_cte and tipo_correo=1 and status_correo='A';	
	SELECT LIMIT 1 nombre INTO nombreCuenta FROM bdicheq:"informix".sc_producto WHERE producto = pproducto;
	
	IF NVL(correoCli,'') <> '' THEN
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CUB_EMAIL','MAIL_CONT',TRIM(pnum_cte),'','','1','CONTRATACION',TRIM(nombreCuenta),'','','','','','','','',TRIM(correoCli),'',1,0,0,0,0,'','') INTO cCodRetSp1;
	ELSE
		SELECT LIMIT 1 telefono  --Obtiene el numero de celular del cliente
		INTO celularCli 
		FROM bdinteg:"informix".si_telefonos_actual 
		WHERE numcte = pnum_cte	AND tipo_tel='2' AND status_tel='A'; 
		
		IF NVL(celularCli,'') <> '' THEN
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','CUB_SMS','SMS_CONT',TRIM(pnum_cte),'','','1','CONTRATACION',TRIM(nombreCuenta),'','','','','','','','','',TRIM(celularCli),1,0,0,0,0,'','') INTO cCodRetSp2; -------- NOTIFICACION DE CUALQUIER PRODUCTO O SERVICIO (SMS)
		END IF;
	END IF;


	EXECUTE PROCEDURE bdicheq:'informix'.firmantes(pempresa,pcuenta,1,pnum_cte,'','','A','A','','')
	INTO vcodret_firm;

	IF vcodret_firm <> '000' THEN

		LET vcodret = vcodret_firm;

		RETURN vcodret,pcuenta,vctaclabe;

	END IF;


RETURN vcodret,pcuenta,vctaclabe;
END
END procedure
DOCUMENT
'DESCRIPCION: Se le agrega un llamado al sp valcteprod donde este sp valida la edad del cliente en cuestion',
'MODIFICO: Jose Angel Rodriguez Rodriguez',
'FECHA: 26/01/2010',
'VERSION: 20100126.1828',
'BD: BDICHEQ',
'MODIFICO: ABIGAIL VASAVILBAZO CAÃÂ?EDO',
'MODIFICACION: SE AGREGA LA FUNCIONALIDAD DE LAS CUENTAS PROAC LAS CUALES SE DETERMINÃÂ? ESTE PROCEDIMIENTO',
			  'COMO SU ALTA DE CLIENTE',
'FECHA: NOVIEMBRE 2010',
'VERSION: 20101103.1642',
'MODIFICO: HÃÂÃÂ©ctor Manuel Bojorquez Ruelas',
'MODIFICACION: Se quita codifo duro que iguala la sucursal a 5001 cuando el tipode cliente es Moral',
'FECHA: 23 Marzo 2012',
'VERSION: 20120323.1542';

CREATE PROCEDURE "informix".sp_actualizafechaconci_atm()

RETURNING 	CHAR(5) as codret, 
			CHAR(50) as seguros_atm,
			CHAR (50) as donativos_atm;

-- *********************************************************************
-- *                        DEFINICION DE VARIABLES                    *
-- *********************************************************************
-- Variables 
	DEFINE vcod_ret 	CHAR(5);
	DEFINE vcod_ret2	CHAR(10);
	DEFINE vcod_ret3	CHAR(10);
	DEFINE vsqlerr		INTEGER;
	DEFINE isam_err		INTEGER;
	DEFINE desc_err		CHAR(50);
--
	DEFINE p_empresa     	CHAR(3);
	DEFINE p_proceso1   	CHAR(20);
	DEFINE p_proceso2   	CHAR(20);
	DEFINE p_fecha_hoy   	DATE ;
	DEFINE p_fecha_proc1   	DATE ;
	DEFINE p_fecha_proc2   	DATE ;
--
-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
	LET vcod_ret	= "0000";
	LET vcod_ret2	= " ";
	LET vcod_ret3	= " ";
	LET vsqlerr		= 0;
	LET isam_err	=0;
	LET desc_err	= " ";
	--
	LET p_empresa		='001';
	LET p_proceso1		= 'concisegatm';
	LET p_proceso2		='concidonativos';
	LET p_fecha_hoy		='';
	LET p_fecha_proc1	='';
	LET p_fecha_proc2	='';
--  
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
	
	
	ON EXCEPTION SET vsqlerr, isam_err, desc_err
	
		SET DEBUG FILE TO "/RESPALDOSNEW/sp_actualizafechaconci_atm.err";
		TRACE ON;
		
	IF vsqlerr <> 0 THEN 
		LET vcod_ret	= vsqlerr;
        LET vcod_ret2	= isam_err;
        LET vcod_ret3	= desc_err;
	RETURN vcod_ret,vcod_ret2,vcod_ret3;	
	END IF
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--	SET DEBUG FILE TO "/RESPALDOSNEW/sp_actualizafechaconci_atm.out";
	--	TRACE ON;
--
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************


	
--SE OBTIENEN FECHA DEL DIA CORRIENTE
	SELECT fecha_hoy 
		INTO p_fecha_hoy
	FROM bdicheq:sc_fechas;

--SE OBTIENEN FECHA DEL PRIMER PROCESO 

	SELECT  fecha
		INTO p_fecha_proc1
	FROM bdicheq:sc_contproc 
	WHERE	proceso	= p_proceso1
	AND		empresa	= p_empresa;
-- SE EVALUA SI ES NECESSARIO ACTUALIZAR LAS FECHAS DE LOS PROCESOS INVOLUCRADOS
	
	IF p_fecha_proc1 <> p_fecha_hoy THEN 
	
		UPDATE bdicheq:sc_contproc
			SET FECHA = p_fecha_hoy
		WHERE	proceso	= p_proceso1
		AND		empresa	= p_empresa;
		LET vcod_ret2='0000';
		
		ELSE

			IF p_fecha_proc1 = p_fecha_hoy THEN
			
			LET vcod_ret2 =SUBSTR(p_fecha_proc1,7,4)||'-'||SUBSTR(p_fecha_proc1,1,2)||'-'||SUBSTR(p_fecha_proc1,4,2);
			LET p_fecha_proc1 = '';
			END IF;
	END IF;

--SE OBTIENEN FECHA DEL SEGUNDO PROCESO 

	SELECT  fecha
		INTO p_fecha_proc2
	FROM bdicheq:sc_contproc 
	WHERE	proceso	= p_proceso2
	AND		empresa	= p_empresa;	

-- SE EVALUA SI ES NECESSARIO ACTUALIZAR LAS FECHAS DE LOS PROCESOS INVOLUCRADOS
	
	IF p_fecha_proc2 <> p_fecha_hoy THEN 
		
		UPDATE bdicheq:sc_contproc
			SET FECHA = p_fecha_hoy
		WHERE	proceso	= p_proceso2
		AND		empresa	= p_empresa;
		LET vcod_ret3='0000';
		
		ELSE
		
			IF p_fecha_proc2 = p_fecha_hoy THEN
		
			LET vcod_ret3 =SUBSTR(p_fecha_proc2,7,4)||'-'||SUBSTR(p_fecha_proc2,1,2)||'-'||SUBSTR(p_fecha_proc2,4,2);
			LET p_fecha_proc2 = '';
			END IF;
	END IF;

--
-- ****************************************************************************
-- *                 FIN DE PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

	RETURN vcod_ret, vcod_ret2, vcod_ret3;
END
END PROCEDURE;