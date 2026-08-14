CREATE PROCEDURE "informix".sp_edoctagenerales(pempresa CHAR(3),
                                    pcuenta CHAR(20),
                                    paniomes CHAR(6))
RETURNING CHAR(5),CHAR(45),CHAR(18),DATE,DATE,
          MONEY(14,2),MONEY(14,2),MONEY(14,2),MONEY(14,2),MONEY(14,2),MONEY(14,2),MONEY(14,2),
          MONEY(14,2),MONEY(14,2),MONEY(14,2),SMALLINT,DECIMAL(9,6),
          CHAR(20),CHAR(107),CHAR(10),CHAR(10),CHAR(30),
          CHAR(30),CHAR(30),CHAR(30),CHAR(5),CHAR(13),
          CHAR(20),DATE,CHAR(40);

define vcodret CHAR(5);
define vsqlerr,visamerr INTEGER;

define cProducto CHAR(45);
define cClabe CHAR(18);
define dFechaini ,dFechafin DATE;
define cNumcte CHAR(20);
define cNomcte CHAR(107);
define cNumExt,cNumInt CHAR(10);
define cNomCalle,cNomColonia,cNomCiudad,cNomEstado CHAR(30);
define cCodPostal CHAR(5);
define cRFC CHAR(13);
define cCurp CHAR(20);
define dFechaAlta DATE;
define cNomSucursal CHAR(40);
define mSaldoAnterior,mDepositos,mRetiros,mInteresesPagados MONEY(14,2);
define mOtrosCargos,mIvaOtrosCargos,mSaldoCorte MONEY(14,2);
define mSaldoPromedio,mRetencionIsr,mInteresesNetos MONEY(14,2);
define iDias smallint;
define dTasaBruta decimal(9,6);
define mAux1 MONEY(14,2);
define vsec_dir smallint;


LET vcodret = "000";
LET cProducto = "";
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
let mSaldoPromedio= 0;
let mInteresesNetos = 0;
let mSaldoAnterior = 0;
let mDepositos = 0;
let mRetiros = 0;
let mInteresesPagados = 0;
let mOtrosCargos = 0;
let mIvaOtrosCargos = 0;
let mSaldoCorte = 0;
let mRetencionIsr = 0;
let iDias = 0;
let dTasaBruta = 0;
let mAux1 = 0;
let vsec_dir = 0;


BEGIN
ON EXCEPTION SET vsqlerr,visamerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      RETURN vcodret,cProducto,cClabe,dFechaini ,dFechafin,
             mSaldoAnterior,mDepositos,mInteresesPagados,mRetiros,
             mOtrosCargos,mIvaOtrosCargos,mSaldoCorte,
             mSaldoPromedio,mRetencionIsr,mInteresesNetos,iDias,dTasaBruta,
             cNumcte,cNomcte,cNumExt,cNumInt,
             cNomCalle,cNomColonia,cNomCiudad,cNomEstado,cCodPostal,cRFC,cCurp,dFechaAlta,
             cNomSucursal;
   END IF;
END EXCEPTION;

if exists (select cuenta from sc_maechq where cuenta = trim(pcuenta)) then

    select trim(ap.producto)||' '||trim(ap.nombre) producto,
            mc.num_cte,mc.cuenta_clabe,mc.fechaini,mc.fechafin,
            nvl(sdo_mes_ant,0),nvl(totdepositos,0),nvl(totintpag,0),nvl(totretiros,0),
            nvl(totcomcobrada,0),nvl(totivacobrado,0),nvl(sdo_actual,0),
            nvl(totisrcobrado,0),nvl(dia_sdo_pos,0),nvl(tasabruta,0),nvl(acum_sdo_pos,0)
    into    cProducto,cNumcte,cClabe,dFechaini,dFechafin,
            mSaldoAnterior,mDepositos,mInteresesPagados,mRetiros,
            mOtrosCargos,mIvaOtrosCargos,mSaldoCorte,
            mRetencionIsr,iDias,dTasaBruta,mAux1
    from    sc_maehis mc, sc_producto ap 
    where   mc.empresa = pempresa and mc.cuenta = trim(pcuenta) 
            and mc.aniomes = paniomes 
            and mc.empresa = ap.empresa and mc.producto = ap.producto;
    

   -- Extrae la Ultima Secuencia de Tipo casa de Direcciones MEL
   select max(secuencia) into vsec_dir
   from   bdinteg:si_direcciones
   where  numcte = cnumcte
   and    tipo_dir = 1;
   if vsec_dir is null then
      let vsec_dir = 1;
   end if
   

    if iDias  = 0 then
       let mSaldoPromedio= 0;
    else
       let mSaldoPromedio= mAux1 / iDias;   
    end if;

    let mInteresesNetos = mInteresesPagados - mRetencionIsr;
           
    if cNumcte  is null then
        let vcodret= "003";
    else

        select nvl(trim(cte.razon_social),"")||nvl(trim(cte.nombre1),"")||' '||nvl(trim(cte.nombre2),"")||' '||
               nvl(trim(cte.apell_paterno),"")||' '|| 
               nvl(trim(cte.apell_materno),"") nombrex,suc.nombre,cte.fecha_alta,cte.rfc,cpf.curp,dir.numeroextcalle,dir.numerointcalle,
               trim(cal.nombrecalle),trim(zon.nombrezona),trim(ciu.nombre),trim(edo.nombre),dir.cod_postal
        into    cNomcte,cNomSucursal,dFechaAlta,cRFC,cCurp,cNumExt,cNumInt,
                cNomCalle, cNomColonia,cNomCiudad,cNomEstado,cCodPostal
        from    bdinteg:si_cliente cte
                left join bdinteg:si_ctepf cpf on(cpf.numcte = cte.numcte)
                left join bdinteg:si_direcciones dir on(dir.numcte = cte.numcte)
                left join bdinteg:si_estados edo on(edo.estado = dir.estado and edo.pais = "001")
                left join bdinteg:si_ciudades ciu on(ciu.ciudad = dir.ciudad and ciu.estado = dir.estado and ciu.pais = "001")
                left join bdinteg:si_catzonas zon on(zon.numerociudad = dir.numerociudad and zon.numerocolonia = dir.numerocolonia )
                left join bdinteg:si_catcalles cal on(cal.numerocalle = dir.numerocalle)
                left join bdinteg:si_sucursales suc on(suc.sucursal = cte.sucursal)
        where   cte.empresa = pempresa 
                and cte.numcte = trim(cNumcte)
                and dir.secuencia = vsec_dir;    
    
    end if;
else
    let vcodret = "100";
end if;

      RETURN vcodret,cProducto,cClabe,dFechaini ,dFechafin,
             mSaldoAnterior,mDepositos,mInteresesPagados,mRetiros,
             mOtrosCargos,mIvaOtrosCargos,mSaldoCorte,
             mSaldoPromedio,mRetencionIsr,mInteresesNetos,iDias,dTasaBruta,
             cNumcte,cNomcte,cNumExt,cNumInt,
             cNomCalle,cNomColonia,cNomCiudad,cNomEstado,cCodPostal,cRFC,cCurp,dFechaAlta,
             cNomSucursal;

END;
END PROCEDURE
DOCUMENT
"Regresa datos generales del estado de cuenta ahorro ",
"Creado por Daniel Zambada "
;

CREATE PROCEDURE "informix".sitcredito(
      p_empresa    CHAR(3),
      p_numcredito CHAR(20))
   RETURNING CHAR(6), CHAR(80), CHAR(20), CHAR(60), CHAR(40), CHAR(40),
             CHAR(20), CHAR(40), CHAR(40),
             DECIMAL(6,3), CHAR(30),
             DATE, DATE, DECIMAL(9,6),
             MONEY(14,2), MONEY(14,2);


   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE p_mensaje           CHAR(80);
   DEFINE nrows               SMALLINT;

   DEFINE p_numcte          LIKE bdinteg:si_cliente.numcte;
   DEFINE p_cliente         LIKE bdinteg:si_cliente.razon_social;
   DEFINE p_ejecut          LIKE bdinteg:si_ejecut.nombre;
   DEFINE p_divisa          LIKE bdinteg:si_divisas.descripcion;
   DEFINE p_producto        LIKE sd_definicion.nombre_prod;
   DEFINE p_num_credito     LIKE sd_maecred.num_credito;
   DEFINE p_sucursal        LIKE bdinteg:si_sucursales.nombre;
   DEFINE p_productor       LIKE bdinteg:si_sucursales.nombre;
   DEFINE p_institucion     LIKE bdinteg:si_sucursales.nombre;
   DEFINE p_porc_rec_prop   LIKE sd_maecred.porc_rec_prop;
   DEFINE p_porcen_redesc   LIKE sd_maecred.porc_rec_prop;
   DEFINE p_status          LIKE sd_tipocartera.descripcion;
   DEFINE p_lininv          char(50); --LIKE sd_lineas.descrip_linea;
   DEFINE p_fecha_apertura  LIKE sd_maecred.fecha_apertura;
   DEFINE p_fecha_vencim    LIKE sd_maecred.fecha_vencim;
   DEFINE p_tasa_interes    LIKE sd_maecred.tasa_interes;
   DEFINE p_tasa_fon        LIKE sd_maecred.tasa_interes;
   DEFINE p_monto_otorgado  LIKE sd_maesdos.monto_otorgado;
   DEFINE p_intereses       LIKE sd_maesdos.sdo_moratorio;

  ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "SitCred.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET cod_ret = sql_err;
      RETURN cod_ret, p_mensaje, p_numcte, p_cliente, p_ejecut, p_divisa,
             p_producto, p_num_credito, p_sucursal,
             p_porc_rec_prop,
             p_status, p_fecha_apertura, p_fecha_vencim,
             p_tasa_interes, p_monto_otorgado, p_intereses;

   END EXCEPTION;



   LET cod_ret = '000';
   LET p_mensaje = "Operacion Realizada Exitosamente";
   LET p_numcte = ' ';
   LET p_cliente = ' ';
   LET p_ejecut = ' ';
   LET p_divisa = ' ';
   LET p_producto = ' ';
   LET p_num_credito = ' ';
   LET p_sucursal = ' ';
   LET p_productor = ' ';
   LET p_institucion = ' ';
   LET p_porc_rec_prop = 0;
   LET p_porcen_redesc = 0;
   LET p_status = ' ';
   LET p_lininv = ' ';
   LET p_fecha_apertura = ' ';
   LET p_fecha_vencim = ' ';
   LET p_tasa_interes = 0;
   LET p_tasa_fon = 0;
   LET p_monto_otorgado = 0;
   LET p_intereses = 0;

   SELECT
      c.numcte,
      c.num_credito,
      NVL(c.porc_rec_prop, 0),
      c.fecha_apertura,
      c.fecha_vencim,
      c.tasa_interes,
      DECODE(NVL(u.razon_social,'XXX'),
        'XXX',
      NVL(u.apell_paterno,' ')||' '||
      NVL(u.apell_materno,' ')||' '||
      NVL(u.nombre1,' ')||' '||
      NVL(u.nombre2,' '),
      razon_social),
      e.nombre,
      d.descripcion,
      p.nombre_prod,
      s.nombre,
      t.descripcion,
      m.monto_otorgado,
      m.sdo_moratorio + m.sdo_exig_int + m.sdo_no_exig +
      m.monto_vencido + m.mto_venc_trasp + m.monto_reservado +
      m.mto_venc_int + m.mto_venc_tra_int + m.mto_finan_vdo +
      m.mto_reser_int
   INTO
      p_numcte,
      p_num_credito,
      p_porc_rec_prop,
      p_fecha_apertura,
      p_fecha_vencim,
      p_tasa_interes,
      p_cliente,
      p_ejecut,
      p_divisa,
      p_producto,
      p_sucursal,
      p_status,
      p_monto_otorgado,
      p_intereses
   FROM
     sd_maecred c,
     outer bdinteg:si_cliente u,
     outer bdinteg:si_ejecut e,
     outer bdinteg:si_divisas d,
     outer sd_definicion p,
     outer bdinteg:si_sucursales s,
     outer sd_tipocartera t,
     outer sd_maesdos m
   WHERE
      u.numcte = c.numcte
   AND u.empresa = c.empresa
   AND e.ejecutivo = c.ejecutivo
   AND e.empresa = c.empresa
   AND d.divisa = c.divisa
   AND d.empresa = c.empresa
   AND p.num_producto = c.num_producto
   AND p.empresa = c.empresa
   AND s.sucursal = c.sucursal
   AND s.empresa = c.empresa
   AND t.status_cred = c.status_cred
   AND t.empresa = c.empresa
   AND m.num_credito = c.num_credito
   AND m.empresa = c.empresa
   AND c.num_credito = p_numcredito
   AND c.empresa = p.empresa;

   LET p_productor = ' ';
   LET p_institucion = ' ';
   LET p_porcen_redesc = 0;
   LET p_tasa_fon = 0;

   select trim(razon_social) ||
          trim(nombre1) || " " ||
          trim(nombre2) || " " ||
          trim(apell_paterno) || " " ||
          trim(apell_materno) as nombre
      into p_cliente
      from bdinteg:si_cliente
      where numcte = p_numcte;


   RETURN cod_ret, p_mensaje, p_numcte, p_cliente, p_ejecut, p_divisa,
          p_producto, p_num_credito, p_sucursal,
          p_porc_rec_prop, p_status, p_fecha_apertura, p_fecha_vencim,
          p_tasa_interes, p_monto_otorgado, p_intereses;


END PROCEDURE
DOCUMENT
'SPL migrado del PL del mismo nombre de fondafa',
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdicred",
"VER   : 1.1";

CREATE PROCEDURE "informix".cons_capitales(p_empresa CHAR(3),
                                           pnum_credito CHAR(20))
RETURNING CHAR(6),
          CHAR(80),
          CHAR(20),
          CHAR(60),
          CHAR(45),
          CHAR(30),
          CHAR(40),
          CHAR(20),
          DECIMAL(18,2),
          DECIMAL(18,2),
          DECIMAL(18,2),
          DECIMAL(18,2),
          DECIMAL(18,2);

   --####################################################################
   --#####                    variables                      #####
   --####################################################################

   DEFINE i                  INTEGER;
   DEFINE text               VARCHAR(100);
   DEFINE v_apell_paterno    VARCHAR(15);
   DEFINE v_apell_materno    VARCHAR(15);
   DEFINE v_nombre1          VARCHAR(15);
   DEFINE v_nombre2          VARCHAR(15);
   DEFINE v_razon_social     VARCHAR(40);
   DEFINE v_num_prod         VARCHAR(04);
   DEFINE v_monto_ven_tras   LIKE SD_MAESDOS.MTO_VENC_TRASP;
   DEFINE p_cod_ret          VARCHAR(8);
   DEFINE p_mensaje          VARCHAR(80);
   DEFINE v_numcte	     VARCHAR(20);
   DEFINE v_cliente	     VARCHAR(60);
   DEFINE v_ejecut	     VARCHAR(45);
   DEFINE v_divnom	     VARCHAR(30);
   DEFINE v_prodnom	     VARCHAR(40);
   DEFINE v_num_credito      VARCHAR(20);
   DEFINE v_sdo_capital      DECIMAL(18,2);
   DEFINE v_mto_ministra     DECIMAL(18,2);
   DEFINE v_monto_otorgado   DECIMAL(18,2);
   DEFINE v_sdo_cap_insoluto DECIMAL(18,2);
   DEFINE v_monto_vencido    DECIMAL(18,2);

BEGIN


   --####################################################################
   --#####                 Inicializa Variables                     #####
   --####################################################################

   LET p_cod_ret          = '00000';
   LET p_mensaje          = ' ';
   LET v_apell_paterno    = ' ';
   LET v_apell_materno    = ' ';
   LET v_nombre1          = ' ';
   LET v_nombre2          = ' ';
   LET v_cliente          = ' ';
   LET v_divnom           = ' ';
   LET v_prodnom          = ' ';
   LET v_razon_social     = ' ';
   LET v_numcte           = ' ';
   LET v_num_credito      = ' ';
   LET v_sdo_capital      = 0;
   LET v_mto_ministra     = 0;
   LET v_monto_otorgado   = 0;
   LET v_sdo_cap_insoluto = 0;
   LET v_monto_vencido    = 0;
   LET v_monto_ven_tras	  = 0;
--   v_monto_financiado := 0;
--   v_sdo_acum_vencido := 0;
--   v_monto_recuperado  := 0;
   LET v_ejecut           = ' ';
   LET v_num_prod         = ' ';

   --#####################################################################
   --######            Inicio de Transaccion                         #####
   --#####################################################################

   IF pnum_credito IS NULL OR
      pnum_credito = ' ' THEN
      LET p_cod_ret = '223'; -- NUMERO DE CREDITO NULO O BLANCO
--      GOTO FIN;
   ELSE
      LET v_num_credito = pnum_credito;
   END IF;
END;

BEGIN
   SELECT num_credito,sdo_capital,mto_ministra_cap,monto_otorgado,
--          sdo_cap_insoluto,monto_vencido,monto_financiado,
            sdo_cap_insoluto,monto_vencido, mto_venc_trasp
--          sdo_acum_vencido
   INTO v_num_credito,v_sdo_capital,v_mto_ministra,v_monto_otorgado,
--        v_sdo_cap_insoluto,v_monto_vencido,v_monto_financiado,
        v_sdo_cap_insoluto,v_monto_vencido, v_monto_ven_tras
--        v_sdo_acum_vencido
   FROM sd_maesdos
   WHERE empresa = p_empresa
   AND   num_credito = v_num_credito;

--EXCEPTION
--WHEN NO_DATA_FOUND THEN
--     NULL;
--WHEN TOO_MANY_ROWS THEN
--     NULL;
END;

   IF v_num_credito IS NULL OR v_num_credito = ' ' THEN
      LET p_cod_ret = '224'; -- NO EXISTE EL CREDITO
--      GOTO FIN;
   END IF;

BEGIN
      SELECT si_cliente.numcte,apell_paterno,apell_materno,nombre1,
             nombre2,razon_social
      INTO v_numcte,v_apell_paterno,v_apell_materno,v_nombre1,v_nombre2,
           v_razon_social
      FROM sd_maecred, bdinteg:si_cliente si_cliente
      WHERE sd_maecred.empresa     = p_empresa
      AND   sd_maecred.num_credito = v_num_credito
      AND   sd_maecred.empresa     = si_cliente.empresa
      AND   sd_maecred.numcte      = si_cliente.numcte;
--EXCEPTION
--WHEN NO_DATA_FOUND THEN
--     NULL;
--WHEN TOO_MANY_ROWS THEN
--     NULL;
END;
      IF v_razon_social IS NULL OR v_razon_social = ' ' THEN
         LET v_cliente = TRIM (v_nombre1) || ' ' || TRIM (v_nombre2);
         LET v_cliente = TRIM (v_cliente) || ' ' ||
                         TRIM (v_apell_paterno) || ' ' ||
                         TRIM (v_apell_materno);
      ELSE
         LET v_cliente = v_razon_social;
      END IF;
--BEGIN
--   SELECT SUM(monto_real_pag) INTO v_monto_recuperado
--  FROM sd_pagocapit
--   WHERE empresa = p_empresa
--   AND   num_credito = v_num_credito
--   AND   status_cuota IN ('3','5','9');
--EXCEPTION
--WHEN NO_DATA_FOUND THEN
--     NULL;
--WHEN TOO_MANY_ROWS THEN
--     NULL;
--END;
--   IF v_monto_recuperado IS NULL THEN
--     v_monto_recuperado := 0;
--   END IF;
BEGIN
   SELECT nombre INTO v_ejecut
   FROM sd_maecred, bdinteg:si_ejecut si_ejecut
   WHERE sd_maecred.empresa     = p_empresa
   AND   sd_maecred.num_credito = v_num_credito
   AND  sd_maecred.empresa      = si_ejecut.empresa
   AND  sd_maecred.ejecutivo    = si_ejecut.ejecutivo;
--EXCEPTION
--WHEN NO_DATA_FOUND THEN
--     NULL;
--WHEN TOO_MANY_ROWS THEN
--     NULL;
END;

    IF v_ejecut IS NULL OR v_ejecut = ' ' THEN
      LET v_ejecut    = ' ';
   END IF;

BEGIN
   SELECT num_producto INTO v_num_prod
   FROM sd_maecred
   WHERE sd_maecred.empresa     = p_empresa
   AND   sd_maecred.num_credito = v_num_credito;
--EXCEPTION
--WHEN NO_DATA_FOUND THEN
--     NULL;
--WHEN TOO_MANY_ROWS THEN
--     NULL;
END;

BEGIN
   SELECT nombre_prod INTO v_prodnom
   FROM sd_definicion
   WHERE empresa = p_empresa
   AND   num_producto = v_num_prod;
--EXCEPTION
--WHEN NO_DATA_FOUND THEN
--     NULL;
--WHEN TOO_MANY_ROWS THEN
--     NULL;
END;

   LET v_prodnom = SUBSTR(TRIM (v_num_prod) || ' ' || TRIM (v_prodnom),1,40);

   IF v_prodnom IS NULL THEN
      LET v_prodnom = ' ';
   END IF;

BEGIN
   SELECT descripcion INTO v_divnom
   FROM sd_maecred, bdinteg:si_divisas si_divisas
   WHERE sd_maecred.empresa     = p_empresa
   AND   sd_maecred.num_credito = v_num_credito
   AND   sd_maecred.empresa     = si_divisas.empresa
   AND   sd_maecred.divisa      = si_divisas.divisa;
--EXCEPTION
--WHEN NO_DATA_FOUND THEN
--     NULL;
--WHEN TOO_MANY_ROWS THEN
--     NULL;
END;

   IF v_sdo_capital IS NULL THEN
      LET v_sdo_capital = 0;
   END IF;
   IF v_mto_ministra IS NULL THEN
      LET v_mto_ministra = 0;
   END IF;
   IF v_monto_otorgado IS NULL THEN
      LET v_monto_otorgado = 0;
   END IF;
   IF v_sdo_cap_insoluto IS NULL THEN
      LET v_sdo_cap_insoluto = 0;
   END IF;
   IF v_monto_vencido IS NULL THEN
      LET v_monto_vencido = 0;
   END IF;
   if v_monto_ven_tras is null then
      LET v_monto_ven_tras = 0;
   end if;

   LET v_monto_vencido = v_monto_vencido + v_monto_ven_tras;

--   IF v_monto_financiado IS NULL THEN
--      v_monto_financiado := 0;
--   END IF;
--   IF v_sdo_acum_vencido IS NULL THEN
--      v_sdo_acum_vencido := 0;
--   END IF;
--   IF v_monto_recuperado IS NULL THEN
--      v_monto_recuperado := 0;
--   END IF;
--   <<FIN>>
--     NULL;
--   EXCEPTION
--      WHEN OTHERS THEN
--       SIPK_MENSAJES.SP_TRAE_MENSAJE (SQLCODE, SQLERRM, P_COD_RET, P_MENSAJE);
RETURN    p_cod_ret,p_mensaje,
          v_numcte,v_cliente,v_ejecut,v_divnom,v_prodnom,v_num_credito,
          v_sdo_capital,v_mto_ministra,v_monto_otorgado,v_sdo_cap_insoluto,
          v_monto_vencido;  --p_cod_ret,p_mensaje;
END PROCEDURE
DOCUMENT
"MODIFICO : Manuel Herndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdicred",
"VER   : 1.1";

CREATE PROCEDURE "informix".log_cierre(vEmpresa CHAR(3),
			    vNumCred CHAR(20),
			    vCodRet  CHAR(5),
			    vFecha   DATE,
			    vDesc    VARCHAR(200,1))
RETURNING SMALLINT;


DEFINE vContador SMALLINT;
DEFINE vParamPara SMALLINT;

	SELECT valor INTO vParamPara
	  FROM sd_param
	 WHERE empresa = vEmpresa
	   AND cod_param ="79";

	INSERT INTO sd_valcierre
	 (empresa, cod_ret, num_credito, secuencia, fecha_proc,
	  desc_err)
	VALUES
	 (vEmpresa, vCodRet, vNumCred, 0, vFecha, vDesc);


	SET ISOLATION TO DIRTY READ;
	SELECT COUNT(*) INTO vContador
	  FROM sd_valcierre
	 WHERE empresa = vEmpresa
	   AND fecha_proc = vFecha;

	IF vContador >= vParamPara THEN
		RETURN vContador;
	ELSE
		LET vContador = 0;
	END IF

	RETURN vContador;

END PROCEDURE
			    
;