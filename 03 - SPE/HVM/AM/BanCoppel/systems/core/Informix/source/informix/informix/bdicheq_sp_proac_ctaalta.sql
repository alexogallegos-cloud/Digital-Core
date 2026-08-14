Create procedure "informix".sp_proac_ctaalta(pempresa CHAR(3),
                         pEjecutivo       CHAR(8),
                         psucursal      CHAR(4),
                         pproducto      CHAR(4),
                         pnum_cte       CHAR(20),
						 pCuentaEje		CHAR(20))
returning char(5),char(20),char(50),integer;

-- Declaración de variables:
DEFINE iSqlerr 			INTEGER;
DEFINE cCodret,cCodret2	CHAR(5);
DEFINE	dFecha,dFecha_siganio	DATE;
DEFINE iExiste 			INTEGER;
DEFINE cPlaza			CHAR(3);
DEFINE cEs_fisica 		CHAR(1);
DEFINE cTipo_cliente 	CHAR(2);
DEFINE cLongcta			CHAR(40);
DEFINE cPaga_interes	char(1);
DEFINE cPago_interes	char(1);
DEFINE dFeciniape		DATE;
DEFINE dFecfinape		DATE;
DEFINE cPaga_capital,cCobraISr,cStatus_cta 	CHAR(1);
DEFINE dFecpagocap		DATE;
DEFINE dFecpagoint		DATE;
DEFINE cDivISa			CHAR(3);
DEFINE cPago_capital	CHAR(3);
DEFINE iPlazomin,iMaxCtas	INTEGER;
DEFINE iPlazomax		INTEGER;
DEFINE iTpper_valida	INTEGER;
DEFINE iTpcte_valido	INTEGER;
DEFINE cIdcta			char(2);
DEFINE cTasavariable	CHAR(2);
DEFINE cTasaprod		CHAR(20);
DEFINE cCtaclabe   		CHAR(50);
DEFINE cParamsigcta		CHAR(25);
DEFINE iSignumcta		integer;
DEFINE iDiferencia		INTEGER;
DEFINE i,iNCuentas		INTEGER;
DEFINE iDigverif,iSecuencia		INTEGER;
DEFINE sSecuencia		SMALLINT;
DEFINE mMtoapertura		MONEY;
DEFINE cProced_aperturacta,cProced_mantenercta,cMonto_mensual,
	   cDepositos_cantidad,cDepositos_monto,cRetiros_cantidad,cRetiros_monto CHAR(2);
DEFINE cProducto 		CHAR(20);
DEFINE cRecValorproducto,cRecValor,cCuenta 		CHAR(20);
DEFINE cFecFormat1,cFecFormat2 		CHAR(25);

begin
   on exception set iSqlerr
      if iSqlerr <> 0 then
         let cCodret = iSqlerr;
         return cCodret,cCuenta,cCtaclabe,iNCuentas;
      end if;
	end exception;
	
	
	--SET DEBUG FILE TO "/tmp/sp_PROAC_CtaAlta.out";
	--TRACE ON;
	
	-- Asignación de variables:
	LET dFecha = '01/01/1950';
	LET iSqlerr =0;
	LET cCodret ='00000';
	LET iExiste = 0;
	LET cPlaza = "";
	LET cEs_fisica 	= "";
	LET cTipo_cliente = "";
	LET cLongcta = "";
	LET cPaga_interes = 0.00;
	LET cPago_interes = 0.00;
	LET dFeciniape = '01/01/1950';
	LET dFecfinape = '01/01/1950';
	LET cPaga_capital ="";
	LET dFecpagocap = '01/01/1950';
	LET dFecpagoint = '01/01/1950';
	LET cDivISa	="";
	LET cPago_capital ="";
	LET iPlazomin	= 0;
	LET iPlazomax	= 0;
	LET iTpper_valida	= 0;
	LET iTpcte_valido	= 0;
	LET cIdcta			= "";
	LET cTasavariable	="";
	LET cTasaprod	="";
	LET cCtaclabe = "";
	LET cParamsigcta = "";
	LET iSignumcta = "";
	LET iDiferencia = "";
	LET i = "";
	LET iDigverif = "";
	LET cProced_aperturacta = "";
	LET cProced_mantenercta = "";
	LET cMonto_mensual ="";
	LET cDepositos_cantidad = "";
	LET cDepositos_monto = "";
	LET cRetiros_cantidad ="";
	LET cRetiros_monto = "";
	LET mMtoapertura = 0.00;
	LET cCobraISr = "";
	LET cProducto = "";
	LET cRecValorproducto = "";
	LET cCuenta = "";
	LET cFecFormat1 = "";
	LET cFecFormat2 = "";
	LET sSecuencia = 1;
	LET cStatus_cta = "";
	LET iSecuencia = 0;
	LET iNcuentas = 0;
	--Consulta cuantas cuentas por cliente puede tener el PROAC
	Select valor Into iMaxCtas From sc_param Where codparam = 'PROACMAXCTAS';

	Select Count(cuenta) Into iNCuentas
	From sc_proac
	Where num_cte = pnum_cte
	And status_cta ='1';
		IF	iNCuentas >= iMaxCtas  THEN
			LET iExiste = 0;
			LET cCodret = "90001";
			LET cCtaclabe = "Cliente Con El Maximo De Cuentas Permitidas";
			RETURN cCodret,cCuenta,cCtaclabe,iNCuentas;
		END IF;

	--Valida que no exista la cuenta eje en alguna otra cuenta PROAC
	Select status_cta Into cStatus_cta
	From sc_proac
	Where cta_eje = pCuentaEje
	And secuencia = (SELECT Max(secuencia) FROM sc_proac Where cta_eje = pCuentaEje);
		IF	cStatus_cta = "1"  THEN
			LET cCodret = "90002";
			LET cCtaclabe = "Cuenta Eje ya Tiene Cuenta PROAC";
			RETURN cCodret,cCuenta,cCtaclabe,iNCuentas;
		END IF;
		IF	cStatus_cta = "2"  THEN
		
		END IF;
		IF	cStatus_cta = "3"  THEN
			LET cCodret = "90004";
			LET cCtaclabe = "Bloqueada Cuenta PROAC";
			RETURN cCodret,cCuenta,cCtaclabe,iNCuentas;
		END IF;
		IF	cStatus_cta = "4"  THEN
			LET cCodret = "90005";
			LET cCtaclabe = "Cuenta Eje ya Tiene Reinscrita la Cuenta PROAC";
			RETURN cCodret,cCuenta,cCtaclabe,iNCuentas;
		END IF;
	Select count(cta_eje) into iNCuentas
	FROM sc_proac
	Where cta_eje = pCuentaEje;
	LET iNCuentas = iNCuentas;
	
	--Obtienen la Fecha de Hoy
	SELECT fecha_hoy INTO dFecha FROM sc_fechas
	WHERE empresa = pempresa;
	
	
	Select 1,NVL(Max(secuencia),0) Into iExiste,sSecuencia
	From sc_proac
	Where cta_eje = pCuentaEje
	And secuencia = (Select Max(secuencia) From sc_proac Where cta_eje = pCuentaEje)
	And status_cta <> '1';
		IF	iExiste = 1  THEN
			LET iExiste = 0;
			LET sSecuencia = sSecuencia +1;
		END IF;
		IF sSecuencia = "" THEN
			LET sSecuencia = 1;
		END IF;

	--Consulta los datos que va a heredar de la cuenta eje
	Select  CobraISr,proced_aperturacta,proced_mantenercta,monto_mensual,depositos_cantidad,
     		depositos_monto,retiros_cantidad,retiros_monto,'PROAC_'|| trim(producto)
	Into cCobraISr,cProced_aperturacta,cProced_mantenercta,cMonto_mensual,cDepositos_cantidad,
    	 cDepositos_monto,cRetiros_cantidad,cRetiros_monto,cProducto
	From sc_maechq Mae
	Where mae.cuenta = pCuentaEje;

	--Consulta y valida el producto para verificar si participa o no en el PROAC
	LET cProducto = trim(cProducto) ;
	Select valor Into cRecValor From sc_param Where codparam = trim(cProducto);
	LET cRecValor = cRecValor;
		IF cRecValor is null THEN
			LET cCodret = "90006";
			LET cCtaclabe = "El Producto No Es Participante";
			RETURN cCodret,cCuenta,cCtaclabe,iNCuentas;
			LET iExiste = 0;
		END IF;

	-- Valida existencia Ejecutivo
	SELECT 1 INTO iExiste FROM bdinteg:si_ejecut
	WHERE ejecutivo = pEjecutivo;
		IF iExiste IS NULL THEN
			LET cCodret = "106";
			LET cCtaclabe = "Usuario inexistente";
			RETURN cCodret,cCuenta,cCtaclabe,iNCuentas;
		Else
		LET iExiste = 0;
		END IF;

	-- Valida la sucursal contra la tabla bdinteg:si_sucursales
	SELECT 1,plaza INTO iExiste,cPlaza
	FROM bdinteg:si_sucursales
	WHERE empresa = pempresa AND sucursal = psucursal;
		IF iExiste IS NULL THEN
		  LET cCodret = "102";
		  LET cCtaclabe = "La Plaza es incorrecta";
		  RETURN cCodret,cCuenta,cCtaclabe,iNCuentas;
		END IF;

	-- Valida el numero de cliente contra la tabla bdinteg:si_cliente
	SELECT es_fisica,tipo_cliente INTO cEs_fisica,cTipo_cliente
	FROM bdinteg:si_cliente cl, bdinteg:si_tipper tp
	WHERE numcte = pnum_cte AND cl.tpo_persona = tp.tpo_persona;
		IF cEs_fisica IS NULL THEN
		  LET cCodret = "104";
		  LET cCtaclabe = "La Tipo de persona no valida";
		  RETURN cCodret,cCuenta,cCtaclabe,iNCuentas;
		END IF;

	-- Valida la Longitud a Considerar para el Numero de Cuenta
	SELECT valOR INTO cLongcta
	FROM sc_param
	WHERE empresa = pempresa AND codparam = "longcta";
		IF cLongcta IS NULL THEN
		  LET cCodret = "107";
		  LET cCtaclabe = "Es necesaria la longitud de la cuenta";
		  RETURN cCodret,cCuenta,cCtaclabe,iNCuentas;
		END IF;

	-- Valida el producto
	-- *************************************************************************
	-- La columna manten_valOR contiene el identIFicadOR de la cuenta axl'07
	-- La columna paga dividENDos identIFica si la cluenta maneja tasa variable
	-- *************************************************************************
	SELECT paga_interes,tipo_dias_calc,feciniape,fecfinape,paga_capital,
		  fecpagocap,fecpagoint,divISa,pago_capital,plazomin,plazomax,
		  tpper_valida,tpcte_valido, manten_valor, paga_dividENDo,tasa
	INTO cPaga_interes,cPago_interes,dFeciniape,dFecfinape,cPaga_capital,
		   dFecpagocap,dFecpagoint,cDivISa,cPago_capital,iPlazomin,iPlazomax,
		   iTpper_valida,iTpcte_valido, cIdcta, cTasavariable, cTasaprod
	FROM sc_producto
	WHERE empresa = pempresa AND producto = TRIM(pproducto);
		IF cPaga_interes IS NULL THEN
		  LET cCodret = "103";
		  LET cCtaclabe = "No esta expreso en el pago de intereses";
		  RETURN cCodret,cCuenta,cCtaclabe,iNCuentas;
		END IF;
	LET cIdcta = cIdcta;
	-- Determina numero de cuenta
	-- ******************************************
	-- Extrae consecutivo de acuerdo al producto *
	-- ******************************************
	LET cParamsigcta = "signumcta" || trim(cIdcta);
	IF cCuenta = " " THEN
	  SELECT valOR INTO iSignumcta
		 FROM sc_param
		 WHERE empresa = pempresa AND codparam = TRIM(cParamsigcta);
	  IF iSignumcta IS NULL THEN
		 LET cCodret = "933";
		 LET cCtaclabe = "Parametros invalidos ó nulos";
		 RETURN cCodret,cCuenta,cCtaclabe,iNCuentas;
	  END IF

	  LET cCuenta = iSignumcta;
	  LET iSignumcta = iSignumcta + 1;
	  UPDATE sc_param
		 set valor = iSignumcta
		 WHERE empresa = pempresa AND codparam =  TRIM(cParamsigcta);

	  LET iDiferencia = cLongcta - length(cCuenta) - 3;
	  IF iDiferencia > 0 THEN
		 fOR i = 1 to iDiferencia
			 LET cCuenta = "0" || cCuenta; --,cCtaclabe; MEL...
		 END for;
	  END IF
	  LET cCuenta = "1" || trim(cIdcta) || TRIM(cCuenta);

	  CALL digver11(cCuenta) -- Asigna digito verificador
		   RETURNING cCodret,iDigverif;
	  LET cCuenta = TRIM(cCuenta)||iDigverif;
	END IF

	-- Valida que la cuenta no exista en el Maestro de cheques
	SELECT 1 INTO iExiste
	  FROM sc_maechq WHERE empresa = pempresa AND cuenta = cCuenta;
	IF iExiste IS not NULL THEN
	  LET cCodret = "405";
	  RETURN cCodret,cCuenta,cCtaclabe,iNCuentas;
	END IF;
    
	
	INSERT INTO sc_maechq (empresa,cuenta,sucursal,plaza,producto,num_cte,status_cta,motivo,
	ult_chq,colateral,fec_ult_mov,fec_cancelac,lim_chq_sbc,imp_chq_sbc,fech_alta_sbc,fech_venc_sbc,
	lim_chq_rem,imp_chq_rem,fech_alta_rem,fech_venc_rem,lim_sbg_ccc,imp_sbg_ccc,tipo_linea,fec_alta_ccc,
	fech_venc_ccc,imp_int_ccc,sdo_retenido,chq_exp_mes,chq_dev,monto_dev,chq_dev_obco,sdo_cong,num_cgos_mes,
	imp_cgos_mes,num_abonos_mes,imp_abonos_mes,sdo_actual,sdo_dia_ant,marca_ret,direcc_envio,com_pendiente,
	imp_chq_sbg,imp_int_sbg,fecha_proceso,cuenta_rel,saldo_sbc,fecultdep,fecultret,ultpagocap,ultpagoint,plazo,
	cobraisr,proced_aperturacta,proced_mantenercta,monto_mensual,depositos_cantidad,depositos_monto,retiros_cantidad,
	retiros_monto,cuenta_clabe)
	  VALUES (pempresa,cCuenta,psucursal,cPlaza,pproducto,
			  pnum_cte,"1"," ",0,"N",dFecha," ",0,0," "," ",
			  0,mMtoapertura," "," ",0,0,"0"," "," ",0,0,0,0,0,0,0,0,0,
			  0,0,0,0,"1",0,0,0,0," "," ",0,"",
			  "","","","12",cCobraISr,
		 cProced_aperturacta,cProced_mantenercta,
		 cMonto_mensual,cDepositos_cantidad,
		 cDepositos_monto,cRetiros_cantidad,cRetiros_monto,
				 cCtaclabe);

	INSERT INTO sc_maenoc (empresa,cuenta,num_cot,clase_cta,reg_firmas,tipo_bca,ejecutivo,envio_direcc,
	porc_sdoprom_sbc,porc_sdoprom_rem,tasa_int_ccc,sobretasa_ccc,cta_en_legal,fec_tras_legal,dias_ccc,acum_ccc,
	dia_sdo_pos,acum_sdo_pos,sdo_prom_mesant,acum_sbc,acum_rem,sdo_mes_ant,adicionado,fecha_alta,modificado,fecha_mod,
	int_acum,isr_acum,capitalizacion,paga_interes,ret_mes_ant,cong_mes_ant,dias_acum_int,acum_sdo_int)
	  VALUES(pempresa,cCuenta,"00",1,0,"001",
			 pejecutivo,1,0,0," ",0," "," ",0,0,0,0,
			 0,0,0,0,pejecutivo,dFecha," "," ",0,0,cPago_interes,
			 " ",0,0,0,0);

	Call sp_PROAC_Calc_ProximoAnio(dFecha) returning cCodret2,dFecha_siganio,cFecFormat1,cFecFormat2 ;
	
	IF iNCuentas >= 1 Then
		Update sc_proac Set status_cta = '4' Where cta_eje = pCuentaEje And secuencia = sSecuencia -1 ;		
	End IF;

	INSERT INTO sc_proac (cuenta,num_cte,cta_eje,secuencia,status_cta,fecha_alta,fecha_canc,sucursal,saldo,prem_proac)
	  VALUES(cCuenta,pnum_cte,pCuentaEje,sSecuencia,1,dFecha,dFecha_siganio,pSucursal,0.00,0.00);
	  LET cCtaclabe = "Proceso Exitoso";
	
	return cCodret,cCuenta,cCtaclabe,iNCuentas;
	End
	End Procedure
	DOCUMENT
	
	'AUTOR       : Jesus Antonio Bastidas Lopez',
	'DESCRIPCION : Genera el proceso de altas nuevas para cliente PROAC donde graba en las tablas sc_maechq, sc_maenoc, sc_proac',
	'FECHA       : Febrero de 2009',
	'VERSION     : 200902',
	'BD          : BDICHEQ';

Create procedure "informix".sp_proac_validacionacuenta(pNum_cte CHAR(20),pCuentaEje CHAR(20),pAltaoBaja CHAR(1))
returning char(5),char(50),char(100),money,money,money,money,Char (3),Char (3),money,
		  money,char(7),Char (3),char(100),char(100),Char(10),Char(10),Char(50),CHAR(30),CHAR(30);

-- Declaración de variables:
DEFINE iSqlerr,iContador,iContadorMx INTEGER;
DEFINE cCodret,cCodret2,cCodret3	 CHAR(5);
DEFINE iMaxCtas,iNCuentas,iExiste 	 INTEGER;
DEFINE cCtaclabe   					 CHAR(50);
DEFINE iEdad,iEdadMin,iEdadMax,iBandera		 Integer;
DEFINE cProducto,cRecValor 			 CHAR(20);
DEFINE Recb2,cTipoCta,cNomCte		 CHAR(100);
DEFINE mCompMayor2,mPremioMaximo2,mMontoAhorrado12,mMontoAhorrado42,
	   mMtoPremio12,mMtoPremio42		 MONEY;
DEFINE cRangoEdad2					 CHAR (7);
DEFINE cEdadCTe,cPorcPremio12,cPorcPremio42		 CHAR (3);
DEFINE cFechaInsc,cFechaProx 			CHAR(10);
DEFINE cUbicacion 			CHAR(50);
DEFINE cFecha1,cFecha2 CHAR(30);
DEFINE mMontoPromedio  MONEY (14,2);

begin
   on exception set iSqlerr
      if iSqlerr <> 0 then
         let cCodret = iSqlerr;
         return cCodret,cCtaclabe,Recb2,mCompMayor2,mPremioMaximo2,mMontoAhorrado12,mMontoAhorrado42,
		cPorcPremio12,cPorcPremio42,mMtoPremio12,mMtoPremio42,cRangoEdad2,cEdadCte,cTipoCta,cNomCte
		,cFechaInsc,cFechaProx,cUbicacion,cFecha1,cFecha2;
      end if;
	end exception;

	--SET DEBUG FILE TO "/tmp/sp_PROAC_ValidacionACuenta.out";
	--TRACE ON;
	
	-- Asignación de variables:
	LET iSqlerr =0;
	LET cCodret ='00000';
	LET cCodret2 ='00000';
	LET cCodret3 ='00000';
	LET iMaxCtas = 0;
	LET iNCuentas = 0;
	LET iExiste = 0;
	LET cProducto = "";
	LET cRecValor = "";
	LET cCtaclabe = "";
	LET iEdad = 0;
	LET iEdadMin = 0;
	LET iEdadMax = 0;
	LET iContador = 1;
	LET iContadorMx = 1;
	LET iBandera = 0;
	LET mCompMayor2 = 0.00;
	LET mPremioMaximo2 = 0.00;
	LET mMontoAhorrado12 = 0.00;
	LET mMontoAhorrado42 = 0.00;
	LET cPorcPremio12 = 0;
	LET cPorcPremio42 = 0;
	LET mMtoPremio12 = 0.00;
	LET mMtoPremio42 = 0.00;
	LET cRangoEdad2 = "";
	LET Recb2 = "";
	LET cEdadCte = 0;
	LET cTipoCta = "";
	LET cNomCte ="";
	LET cUbicacion = "";
	LET cFechaInsc = "";
	LET cFechaProx = "";
	LET cFecha1 = "";
	LET cFecha2 = "";
	
	
	
	IF pAltaoBaja = 'A' Then 
	IF TRIM(pNum_cte) = ""  OR TRIM(pNum_cte) = 0 THEN
		LET cCodret = "90000";
		LET cCtaclabe = "Datos nulos";
		RETURN cCodret,cCtaclabe,Recb2,mCompMayor2,mPremioMaximo2,mMontoAhorrado12,mMontoAhorrado42,
		cPorcPremio12,cPorcPremio42,mMtoPremio12,mMtoPremio42,cRangoEdad2,cEdadCte,cTipoCta,cNomCte
		,cFechaInsc,cFechaProx,cUbicacion,cFecha1,cFecha2;
	END IF;
	
	IF TRIM(pCuentaEje) = ""  OR TRIM(pCuentaEje) = 0 THEN
		LET cCodret = "90000";
		LET cCtaclabe = "Datos nulos";
		RETURN cCodret,cCtaclabe,Recb2,mCompMayor2,mPremioMaximo2,mMontoAhorrado12,mMontoAhorrado42,
		cPorcPremio12,cPorcPremio42,mMtoPremio12,mMtoPremio42,cRangoEdad2,cEdadCte,cTipoCta,cNomCte
		,cFechaInsc,cFechaProx,cUbicacion,cFecha1,cFecha2;
	END IF;
	
	--Consulta cuantas cuentas por cliente puede tener el PROAC
	Select valor Into iMaxCtas From sc_param Where codparam = 'PROACMAXCTAS';

	Select Count(cuenta) Into iNCuentas
	From sc_proac
	Where num_cte = pNum_cte
	And status_cta in ('1','3') ;
		IF	iNCuentas >= iMaxCtas  THEN
			LET iExiste = 0;
			LET cCodret = "90001";
			LET cCtaclabe = "Cliente Con El Maximo De Cuentas Permitidas";
			RETURN cCodret,cCtaclabe,Recb2,mCompMayor2,mPremioMaximo2,mMontoAhorrado12,mMontoAhorrado42,
		cPorcPremio12,cPorcPremio42,mMtoPremio12,mMtoPremio42,cRangoEdad2,cEdadCte,cTipoCta,cNomCte,cFechaInsc
		,cFechaProx,cUbicacion,cFecha1,cFecha2;
		END IF;

	--Valida que no exista la cuenta eje en alguna otra cuenta PROAC
	Select 1 Into iExiste
	From sc_proac
	Where cta_eje = pCuentaEje
	And status_cta in ('1','3');
		IF	iExiste = 1  THEN
			LET iExiste = 0;
			LET cCodret = "90002";
			LET cCtaclabe = "Cuenta Eje ya Tiene Cuenta PROAC";
			RETURN cCodret,cCtaclabe,Recb2,mCompMayor2,mPremioMaximo2,mMontoAhorrado12,mMontoAhorrado42,
		cPorcPremio12,cPorcPremio42,mMtoPremio12,mMtoPremio42,cRangoEdad2,cEdadCte,cTipoCta,cNomCte,cFechaInsc
		,cFechaProx,cUbicacion,cFecha1,cFecha2;
		END IF;
	
	
	
	End if;
	--Consulta los datos que va a heredar de la cuenta eje
	Select  'PROAC_'|| trim(producto)
	Into cProducto
	From sc_maechq Mae
	Where mae.cuenta = pCuentaEje;

	--Consulta y valida el producto para verificar si participa o no en el PROAC
	LET cProducto = trim(cProducto) ;
	Select valor,descripcion Into cRecValor,cUbicacion From sc_param Where codparam = trim(cProducto);
	LET cRecValor = cRecValor;
		IF cRecValor is null THEN
			LET cCodret = "90003";
			LET cCtaclabe = "El Producto No Es Participante";
			IF cUbicacion IS NULL OR  cUbicacion = "" Then
			LET cUbicacion = 'C:\OFI\Reportes\';
		End IF;
			RETURN cCodret,cCtaclabe,Recb2,mCompMayor2,mPremioMaximo2,mMontoAhorrado12,mMontoAhorrado42,
		cPorcPremio12,cPorcPremio42,mMtoPremio12,mMtoPremio42,cRangoEdad2,cEdadCte,cTipoCta,cNomCte,cFechaInsc
		,cFechaProx,cUbicacion,cFecha1,cFecha2 ;
			LET iExiste = 0;
		END IF;
	Call sp_PROAC_TraeParametros() Returning 
cCodret2,Recb2,mCompMayor2,mPremioMaximo2,mMontoAhorrado12,mMontoAhorrado42,cPorcPremio12,cPorcPremio42,mMtoPremio12,mMtoPremio42,cRangoEdad2,mMontoPromedio;
	LET cRangoEdad2 = nvl(cRangoEdad2,"18-85");
	LET iContadorMx = LENGTH(cRangoEdad2);
	Select (fecha_hoy -Fecha_nac)/365 Into iEdad
	From bdinteg:si_ctepf , bdicheq:sc_fechas  
	Where numcte = pNum_cte;
	LET cEdadCte = iEdad;
	For iContador = 1 to iContadorMx 
	
		If substr(cRangoEdad2,icontador,1) = '-' And iBandera = 0 Then
			LET iEdadMin = substr(cRangoEdad2,1,icontador-1);
			LET iEdad = iEdad;
			If iEdad < iEdadMin Then
				LET cCodret = "90004";
				LET cCtaclabe = "La Edad Del Cliente Es Menor A la del Programa";
				LET iBandera = 1;
				RETURN cCodret,cCtaclabe,Recb2,mCompMayor2,mPremioMaximo2,mMontoAhorrado12,mMontoAhorrado42,
				cPorcPremio12,cPorcPremio42,mMtoPremio12,mMtoPremio42,cRangoEdad2,cEdadCte,cTipoCta,cNomCte,cFechaInsc
				,cFechaProx,cUbicacion,cFecha1,cFecha2 ;
				Exit For;
			End if;
			LET iEdadMax = substr(cRangoEdad2,icontador+1);
			LET iEdad = iEdad;
				If iEdad > iEdadMax Then
					LET cCodret = "90005";
					LET cCtaclabe = "La Edad Del Cliente Es Mayor a la del Programa";
					LET iBandera = 2;
					RETURN cCodret,cCtaclabe,Recb2,mCompMayor2,mPremioMaximo2,mMontoAhorrado12,mMontoAhorrado42,
					cPorcPremio12,cPorcPremio42,mMtoPremio12,mMtoPremio42,cRangoEdad2,cEdadCte,cTipoCta,cNomCte,cFechaInsc
					,cFechaProx,cUbicacion,cFecha1,cFecha2 ;
					Exit For;
				End if;
		End if;
	End For;
	If  iBandera <>1 And  iBandera <> 2 Then
	
	LET cCodret = "00000"; 
	LET cCtaclabe = "Los datos del cliente y cuenta estan OK";

	Select Trim(nombre1) || ' ' || Trim(nombre2)  ||' ' || Trim(apell_paterno) || ' ' || Trim(apell_materno)
	Into cNomCte
	From bdinteg:si_cliente where numcte = pNum_cte;
	
	Select trim(nombre) 
	Into cTipoCta
	From sc_producto pr 
	Where pr.producto = substr(cproducto,7);

	Select fecha_hoy Into cFechaInsc
	From sc_fechas 
	Where Empresa = '001';
	End If;
	Call sp_PROAC_Calc_ProximoAnio(cFechaInsc) returning cCodret3,cFechaProx,cFecha1,cFecha2;
	RETURN cCodret,cCtaclabe,Recb2,mCompMayor2,mPremioMaximo2,mMontoAhorrado12,mMontoAhorrado42,
		cPorcPremio12,cPorcPremio42,mMtoPremio12,mMtoPremio42,cRangoEdad2,cEdadCte,cTipoCta,cNomCte
		,cFechaInsc,cFechaProx,cUbicacion,cFecha1,cFecha2 with Resume;
	End
	End Procedure
	DOCUMENT
	
	'AUTOR		: Jesus Antonio Bastidas Lopez',
	'DESCRIPCION: Genera La validacion de las cuentas PROAC, respecto a las cuenta eje maximo de cuentas ',
					' por numero de cliente y si el producto de la cuenta es participante.',
	'FECHA		: Febrero 2009',
	'VERSION	: 200902',
	'BD			: BDICHEQ';

CREATE PROCEDURE "informix".obtienecuentaclabe (sEmpresa CHAR(3), sNumCte CHAR(20), sNumCuenta CHAR(20))
    RETURNING CHAR(5), CHAR(20);

--DEFINICIÓN DE VARIABLES
    DEFINE iSqlErr            INTEGER;
    DEFINE sCodRet        CHAR(5);
    DEFINE sClabe           CHAR(20);

--INICIALIZACIÓN DE VARIABLES
    LET sCodRet = "000";
    LET sClabe = "";

--SET DEBUG FILE TO '/tmp/ObtieneCuentaClabe.out';
--TRACE ON;

    BEGIN
        ON EXCEPTION SET iSqlErr
                IF iSqlErr <> 0 THEN
                        LET sCodRet = iSqlErr;
                        RETURN sCodRet, sClabe;
                END IF;
        END EXCEPTION;

        SELECT cuenta_clabe INTO sClabe
        FROM sc_maechq
        WHERE num_cte = sNumCte
        AND cuenta = sNumCuenta;
        
        IF sClabe = '' or sClabe is null THEN
                LET sCodRet = "001"; -- NO ESISTE LA CUENTA CLABE
                RETURN sCodRet, sClabe;
        END IF;

        RETURN sCodRet, sClabe;

    END;
--*************************************************************************
--| Procedimiento   : ObtieneCuentaClabe
--| Versión         : 1.0
--| Creado por      : Martha Aguirre
--| Fecha creacion  : Junio de 2009
--| Descripción     : Realiza una consulta en la tabla sc_maechq para 
--|				      obtener la cuenta clabe del cliente cuando se le
--|					  otorga una cuenta efectiva.
--*************************************************************************
END PROCEDURE;