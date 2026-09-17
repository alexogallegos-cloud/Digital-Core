CREATE PROCEDURE "informix".consprodcte(pempresa  char(3),
                                        pnumcte   char(20),
                                        pultreg   smallint,
                                        ptpcon    CHAR(1))
returning char(5),char(2),char(4),char(20),char(30),money(14,2);

    define vcodret      char(5);
    define vsiglas      char(2);
    define vproducto    char(4);
    define vcuenta      char(20);
    define vcuenta2     char(20);
    define vsqlerr      integer;
    define vexiste      char(1);
    define vconreg      smallint;
    define vstatus      char(2);
    define vsdodisp     money(14,2);
    define vdescst      CHAR(30);

    let vdescst = " ";
    let vcodret   = "000";
    let vproducto = " ";
    let vcuenta   = " ";
    let vcuenta2   = " ";
    let vsiglas   = " ";
    let vstatus   = " ";
    let vconreg   = 0;
    let vsdodisp = 0;

    --set debug file to "/home/c90301007/Traza/consprod_MODF.out";
    --trace on;

    begin
    
    on exception set vsqlerr
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            return vcodret,vsiglas,vproducto,vcuenta,vdescst,vsdodisp;
        end if
    end exception;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    select 1 
      into vexiste
      from si_cliente
     where numcte = pnumcte;
     
    if vexiste is null then
        let vcodret = "104";
        return vcodret,vsiglas,vproducto,vcuenta,vdescst,vsdodisp;
    end if

    -- Extrae la informacion del Sistema de Cheques
    foreach
		-- RQM 09 704. Se agrega el campo saldo_sbc para que sea considerado en el calculo del saldo disponible.
        select "SC",cuenta,producto,status_cta,sdo_actual-sdo_cong-sdo_retenido-saldo_sbc,
               DECODE(status_cta, "1", "Activa", 
                                  "2", "Cancelada", 
                                  "3", "Bloqueada", 
                                  "4", "Inactiva", 
                                  "5", "Informada", 
                                  "6", "Concentrada", 
                                  "7", "Traspasada", 
                                  "8", "DesConcentrada",
                                       "Desconocido")
          into vsiglas,vcuenta,vproducto,vstatus,vsdodisp, vdescst
          from bdicheq:sc_maechq
         where empresa = pempresa 
           and num_cte = pnumcte 
           and status_cta <> '2'
		   and producto <> '2300'
        union all
        select "SV",cuenta,cod_instrum,status_cta,capital-sdo_cong-sdo_retenido,
               DECODE(status_cta, "1","Activa", "2","Cancelada", "3","Bloqueada", "Desconocido")
          from bdinvers:sv_maeinv mv
         where num_cte = pnumcte 
           and status_cta not in ("4", "2")
        union all
        SELECT "SD", a.num_credito, num_producto, a.status_cred,
               sdo_cap_insoluto + sdo_exig_int + sdo_no_exig + sdo_moratorio,
			   CASE WHEN a.status_cred IN ("AA","E1") AND (b.monto_vencido + b.mto_venc_trasp) = 0 THEN "Activa" 
					WHEN a.status_cred IN ("BA","BT","E1","E2","E3")  THEN "Bloqueada" 
			        WHEN SUBSTR(a.status_cred,1,1) = "C" THEN "Cancelada"
			        WHEN SUBSTR(a.status_cred,1,1) = "F" THEN "Liquidada"
			   ELSE "Desconocido" END			   
          FROM bdicred:sd_maecred a, bdicred:sd_maesdos b
         WHERE b.num_credito = a.num_credito
           AND b.empresa = a.empresa
           AND a.empresa = pempresa
           AND a.numcte = pnumcte
        UNION ALL
        SELECT "SS", num_solicitud, num_producto, a.status_solicitud,
               monto_solicitado, b.descripcion
          FROM bdisolic:ss_solicitudes a, bdisolic:ss_status_sol b
         WHERE a.empresa = pempresa
           AND a.numcte = pnumcte
           AND a.status_solicitud <> 'AP'
           AND b.empresa = a.empresa
           AND b.status_solicitud = a.status_solicitud
         order by cuenta

        IF vsiglas = "SC" THEN
            IF ptpcon = "1" THEN
                IF vstatus = "2" THEN
                    CONTINUE FOREACH;
                END IF
            END IF
        ELIF vsiglas = "SV" THEN
            IF ptpcon = "1" THEN
                IF vstatus = "4" THEN
                    CONTINUE FOREACH;
                END IF
            END IF
        ELIF vsiglas = "SD" THEN
            IF ptpcon = "1" THEN
                IF vstatus = "CC" THEN
                    CONTINUE FOREACH;
                END IF
            END IF
        ELIF vsiglas = "SS" THEN
            IF ptpcon = "1" THEN
                CONTINUE FOREACH;
            END IF
        END IF

        if vstatus = "2" then
            let vsdodisp = 0;
        end if

        let vconreg = vconreg + 1;
        
        if vconreg <= pultreg then
            continue foreach;
        end if

        -- Si es Tarjeta regresa la tarjeta
        select 1 
          into vexiste
          from bdicred:sd_tarjeta
         where num_credito = vcuenta
           and empresa = pempresa
           and status_tar = "A"
           and tipo_tarjeta = "T";
           
        if not vexiste is null then
            LET vcuenta2 = vcuenta;
            
            select num_tarjeta 
              into vcuenta
              from bdicred:sd_tarjeta
             where num_credito = vcuenta2
               and empresa = pempresa
               and status_tar = "A"
               and tipo_tarjeta = "T";
        end if
        
        return vcodret,vsiglas,vproducto,vcuenta,nvl(vdescst, ' '),nvl(vsdodisp, 0) with resume;
    end foreach
    
    end
    
end procedure
DOCUMENT
"MODIFICO : Manuel Hernandez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1",
"------------------------------------------",
"MODIFICO :     Ezequiel Moreno Paredes",
"FECHA :        09-06-2025",
"MODIFICACION : Se modifica la formula de calculo de saldo disponible para considerar un nuevo campo llamado saldo_sbc",
"PROYECTO :     RQM 09 704 Cobranza Automatica en cuentas de captacion",
"VERSION :      1.1.1";

create procedure "informix".consinteg(pempresa  char(3),
                                      pnum_cte  char(20),
                                      psucursal char(4),
                                      pusuario  char(8),
                                      prenglon  smallint)
										  
returning char(5),char(40),char(2),char(20),char(4),char(40),date,date,
          money(14,2),money(14,2),char(40),char(40),char(20);

-- ************************************************************************
-- Define variables
-- ************************************************************************
    define cod_ret char(5);
    define v_sistema char(2);
    define v_sucursal char(4);
    define v_tpersona char(2);
    define v_numero char(20);
    define v_nombre1,v_materno,v_paterno char(12);
    define v_razon char(36);
    define v_completo char(36);
    define v_producto char(40);
    define v_cuenta char(20);
    define v_delega CHAR(20);
    define v_fecha_alta,v_fecha_venc date;
    define v_calle,v_colonia char(40);
    define v_monto1,v_monto2 money(14,2);
    define vc_sdo_actual,vc_sdo_retenido,vc_sdo_cong,vc_acum_sdo_pos,
    v_sdo_prom,v_sdo_disp,vi_intereses,vi_isr,
    vd_exig,vd_no_exig money(14,2);
    define vc_dia_sdo_pos,v_renglon,v_secuencia1,v_secuencia2 smallint;
    define longitud,v_long_cte smallint;
    define sql_err integer;
    define vnocalle  integer;
    define vnocolonia integer;
    define vnociudad integer;
   --RQM 09 704. Se agrega la siguiente variable DFTL 
    define mSaldo_SBC MONEY(14,2);


-- ************************************************************************
-- Inicializa variables
-- ************************************************************************
    let cod_ret      = "000";
    let v_sucursal   = " ";
    let v_producto   = " ";
    let v_cuenta     = " ";
    let v_sistema    = " ";
    let v_fecha_alta = " ";
    let v_fecha_venc = " ";
    let v_monto1     = 0;
    let v_monto2     = 0;
    let v_renglon    = 0;
    let v_calle      = " ";
    let v_colonia    = " ";
    let v_completo   = " ";
    let v_delega     = " ";
    let vnocalle     = 0;
    let vnocolonia   = 0;
    let vnociudad    = 0;
   --RQM 09 704. Se agrega la siguiente variable DFTL 
    let mSaldo_SBC	 = 0;


   --SET DEBUG FILE TO "/home/c90402536/Traza/consinteg_modif.out";
   --TRACE ON; 
   
 begin
    
    on exception set sql_err
        if sql_err <> 0 then
            let cod_ret = sql_err;
            return cod_ret,v_completo,v_sistema,v_cuenta,v_sucursal,v_producto,v_fecha_alta,v_fecha_venc,v_monto1,v_monto2,v_calle,v_colonia,v_delega;
        end if
    end exception;
    
    SET ISOLATION TO DIRTY READ;
    
    -- ***********************************************************************
    select numcte,apell_paterno,apell_materno,nombre1,razon_social,tpo_persona
      into v_numero,v_paterno,v_materno,v_nombre1,v_razon,v_tpersona
      from si_cliente
     where numcte=pnum_cte;

    if v_numero is null then
        let cod_ret = "137";
        return cod_ret,v_completo,v_sistema,v_cuenta,v_sucursal,v_producto,v_fecha_alta,v_fecha_venc,v_monto1,v_monto2,v_calle,v_colonia,v_delega;
    end if

    if (v_razon is null) or (trim(v_razon) = "") then
        let v_completo = trim(v_paterno)||" "||trim(v_materno)||" "||trim(v_nombre1);
    else
        let v_completo = v_razon;
    end if

-- ***************************************************************************
-- Verifica si debe generar la tabla de consulta
-- ***************************************************************************
--   if prenglon = 0 then
    delete from si_consinteg
     where sucursal = psucursal 
       and usuario = pusuario 
       and numcte  = pnum_cte;
      -- *********************************************************************
      -- Extrae la informacion del Sistema de Cheques
      -- *********************************************************************
    foreach
        select mc.cuenta,sucursal,mc.producto||" "||pr.nombre,fecha_alta,
               dia_sdo_pos,acum_sdo_pos,sdo_actual,sdo_retenido,
               sdo_cong,saldo_sbc,numerocalle,numerocolonia,numerociudad,
               CASE WHEN status_cta = "1" and marca_ret = "0" then
                        "Sin Deposito Inicial"
                    WHEN status_cta = "1" and marca_ret = "1" then
                        "Activa"
                    WHEN status_cta = "2" then
                        "Cancelada"
                    WHEN status_cta = "3" then
                        "Bloqueada"
                    WHEN status_cta = "4" then
                        "Inactiva"
                    WHEN status_cta = "5" then
                        "Informada"
                    WHEN status_cta = "6" then
                        "Concentrada"
                    WHEN status_cta = "7" then
                        "Traspasada"
                    WHEN status_cta = "8" then
                        "DesConcentrada"
                    END
          into v_cuenta,v_sucursal,v_producto,v_fecha_alta,
               vc_dia_sdo_pos,vc_acum_sdo_pos,vc_sdo_actual,vc_sdo_retenido,
               vc_sdo_cong,mSaldo_SBC,vnocalle,vnocolonia,vnociudad, v_delega
          from bdicheq:sc_maechq mc,
               bdicheq:sc_maenoc mn,
               bdicheq:sc_producto pr,
         outer si_direcciones di
         where num_cte = pnum_cte 
           and mc.cuenta = mn.cuenta 
           and mc.producto = pr.producto 
           and numcte = num_cte 
           and secuencia = direcc_envio
         order by mc.cuenta
        
        if vc_dia_sdo_pos > 0 then
            let v_sdo_prom = vc_acum_sdo_pos / vc_dia_sdo_pos;
        else
            let v_sdo_prom = 0;
        end if
		 
        --RQM 09 704. Se agrega el campo saldo_sbc al calculo del saldo disponible. DFTL 
        let v_sdo_disp = vc_sdo_actual - vc_sdo_retenido - vc_sdo_cong - mSaldo_SBC;
       let v_monto1   = v_sdo_prom;
        let v_monto2   = v_sdo_disp;

        if v_monto2 is null then
            let v_monto2 = 0;
        end if

        if v_monto1 is null then
            let v_monto1 = 0;
        end if

        -- Extrae la Direccion Coppel
        select nvl(nombrecalle,"") 
          into v_calle
          From si_catcalles 
         where numerocalle = vnocalle;
         
        Select nvl(nombrezona,"")
          into v_colonia
          From si_catzonas
         where numerociudad = vnociudad 
           and numerocolonia = vnocolonia;
           
        if v_colonia is null then
            let v_colonia = "";
        end if

        --Graba la informacion en la tabla temporal de consulta integral
        let v_renglon = v_renglon + 1;
        
        insert into si_consinteg
        values(psucursal,pusuario,v_renglon,pnum_cte,"01",v_cuenta,v_sucursal,v_producto,v_fecha_alta,v_fecha_alta,v_monto2,v_monto1,v_calle,v_colonia,v_delega);
    end foreach

    -- *********************************************************************
    -- Extrae la informacion del Sistema de Inversiones
    -- *********************************************************************
    foreach
        select cuenta,mv.sucursal,mv.cod_instrum||" "||pr.nombre,
               mv.fecha_alta,fecha_venc,capital,intereses,isr,mv.secuencia,
               mv.secuencia,calle,colonia,municipio,
               DECODE(status_cta, "1","Activa","3","Bloqueada")
          into v_cuenta,v_sucursal,v_producto,v_fecha_alta,
               v_fecha_venc,v_monto1,vi_intereses,vi_isr,v_secuencia1,
               v_secuencia2,vnocalle,vnocolonia,vnociudad, v_delega
          from bdinvers:sv_maeinv mv,
               bdinvers:sv_instrum pr,
         outer si_direcciones di
         where mv.num_cte = pnum_cte
           and mv.status_cta = "1" 
           and mv.cod_instrum = pr.cod_instrum
           and numcte = pnum_cte 
           and di.secuencia = direcc_envio
         order by cuenta
         
        let v_monto2   = vi_intereses - vi_isr;

        if v_monto2 is null then
            let v_monto2 = 0;
        end if

        if v_monto1 is null then
            let v_monto1 = 0;
        end if

        -- Extrae la Direccion Coppel
        select nvl(nombrecalle,"") 
          into v_calle
          From si_catcalles 
         where numerocalle = vnocalle;
         
        Select nvl(nombrezona,"")
          into v_colonia
          From si_catzonas
         where numerociudad = vnociudad 
           and numerocolonia = vnocolonia;
           
        if v_colonia is null then
            let v_colonia = "";
        end if
        
        if v_calle is null then
            let v_calle = "";
        end if
        
        --Graba la informacion en la tabla temporal de consulta integral
        let v_renglon = v_renglon + 1;
        
        insert into si_consinteg
        values(psucursal,pusuario,v_renglon,pnum_cte,"03",v_cuenta,v_sucursal,v_producto,v_fecha_alta,v_fecha_venc,v_monto1,v_monto2,v_calle,v_colonia,v_delega);
    end foreach
    
    -- *********************************************************************
    -- Extrae la informacion del Sistema de Credito
    -- *********************************************************************
    foreach
        select mc.num_credito,sucursal,mc.num_producto||" "||pr.nombre_prod,
               fecha_apertura,
               fecha_vencim,sdo_cap_insoluto,sdo_no_exig,sdo_exig_int,
			   CASE WHEN (status_cred IN ("AA","E1") AND (ms.monto_vencido + ms.mto_venc_trasp) = 0) THEN "Activo"
			   WHEN status_cred  IN ("BA","BT","E1","E2","E3") THEN "Suspendido"
			   WHEN status_cred ="FF" THEN "Liquidado"
			   WHEN status_cred ="CC" THEN "Problematico"
			   ELSE "Convenio" END
          into v_cuenta,v_sucursal,v_producto,v_fecha_alta,
               v_fecha_venc,v_monto1,vd_no_exig,vd_exig, v_delega
          from bdicred:sd_maecred mc,
               bdicred:sd_maesdos ms,
               bdicred:sd_definicion pr
         where numcte = pnum_cte 
           and mc.num_credito = ms.num_credito 
           and mc.num_producto = pr.num_producto
         order by 1
			/* IFRS Se modifica el estatus de credito por Etapas
        select mc.num_credito,sucursal,mc.num_producto||" "||pr.nombre_prod,
               fecha_apertura,
               fecha_vencim,sdo_cap_insoluto,sdo_no_exig,sdo_exig_int,
               DECODE(status_cred,"AA","Activo", "BA","Suspendido",
               "BT","Suspendido", "FF", "Liquidado",
               "CC","Problematico","Convenio")
          into v_cuenta,v_sucursal,v_producto,v_fecha_alta,
               v_fecha_venc,v_monto1,vd_no_exig,vd_exig, v_delega
          from bdicred:sd_maecred mc,
               bdicred:sd_maesdos ms,
               bdicred:sd_definicion pr
         where numcte = pnum_cte 
           and mc.num_credito = ms.num_credito 
           and mc.num_producto = pr.num_producto
         order by 1*/
         
        let v_monto2 = vd_exig + vd_no_exig;
        
        if v_monto2 is null then
            let v_monto2 = 0;
        end if
        
        if v_monto1 is null then
            let v_monto1 = 0;
        end if
        
        --Graba la informacion en la tabla temporal de consulta integral
        let v_renglon = v_renglon + 1;
        
        insert into si_consinteg
        values(psucursal,pusuario,v_renglon,pnum_cte,"06",v_cuenta,v_sucursal,v_producto,v_fecha_alta,v_fecha_venc,v_monto1,v_monto2,v_calle,v_colonia,v_delega);
    end foreach
    
    -- ************************************************************************
    -- Verifica si existen renglones en la tabla
    -- ************************************************************************
    select count(*) 
      into v_numero
      from si_consinteg
     where sucursal = psucursal 
       and usuario = pusuario 
       and numcte  = pnum_cte;

    -- ***********************************************************************
    -- Regresa la informacion generada en la tabla a partir del num de renglon
    -- ***********************************************************************
    if v_numero <= 0 then
        let cod_ret = "127";
        
        if v_fecha_venc is null then
            let v_fecha_venc = today;
        end if
        
        return cod_ret,v_completo,v_sistema,v_cuenta,v_sucursal,v_producto,v_fecha_alta,v_fecha_venc,v_monto1,v_monto2,v_calle,v_colonia,v_delega;
    end if
    
    foreach
        select sistema,cuenta,sucursal_cta,producto,fecha_alta,fecha_venc,importe_1,importe_2,calle,colonia,delegacion
          into v_sistema,v_cuenta,v_sucursal,v_producto,v_fecha_alta,v_fecha_venc,v_monto1,v_monto2,v_calle,v_colonia,v_delega
          from si_consinteg
         where sucursal = psucursal 
           and usuario  = pusuario  
           and numcte  = pnum_cte  
           and renglon  > prenglon
           
        if v_fecha_venc is null then
            let v_fecha_venc = today;
        end if
        
        return cod_ret,v_completo,v_sistema,v_cuenta,v_sucursal,v_producto,v_fecha_alta,v_fecha_venc,v_monto1,v_monto2,v_calle,v_colonia,v_delega WITH RESUME;
    end foreach
    
    end
    
end procedure
DOCUMENT
"MODIFICO : Manuel Hernandez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1",
"MODIFICADO:            Donovan F. Torres Landeros",
"ULTIMA MODIFICACION:   2025/06/04",
"RAZON:                 Se agrega la nueva variable saldo inmovilizado", 
"						por motivo de cobranza automÃ¡tica de crÃ©dito",
"                       a la operacion aritmetica para el nuevo calculo de",
"                       saldo disponible.",
"PROYECTO: RQM 09 704   Cobranza Automatica en cuentas de captacion",
"BD:                    bdinteg",
"VER:                   1.2";

CREATE PROCEDURE "informix".consinteg_web(pempresa  CHAR(3),
										  pnum_cte  CHAR(20),
			                              psucursal CHAR(4),
			                              pusuario  CHAR(8),
			                              prenglon  SMALLINT)
										  
RETURNING CHAR(5),CHAR(40),CHAR(2),CHAR(20),CHAR(4),CHAR(40),DATE,DATE,
	     MONEY(14,2),MONEY(14,2),CHAR(40),CHAR(40),CHAR(20);

-- ************************************************************************
-- Define variables
-- ************************************************************************
   DEFINE cod_ret CHAR(5);
   DEFINE v_sistema CHAR(2);
   DEFINE v_sucursal CHAR(4);
   DEFINE v_tpersona CHAR(2);
   DEFINE v_numero CHAR(20);
   DEFINE v_nombre1,v_materno,v_paterno CHAR(12);
   DEFINE v_razon CHAR(36);
   DEFINE v_completo CHAR(36);
   DEFINE v_producto CHAR(40);
   DEFINE v_cuenta CHAR(20);
   DEFINE v_delega CHAR(20);
   DEFINE v_fecha_alta,v_fecha_venc DATE;
   DEFINE v_calle,v_colonia CHAR(40);
   DEFINE v_monto1,v_monto2 MONEY(14,2);
   DEFINE vc_sdo_actual,vc_sdo_retenido,vc_sdo_cong,vc_acum_sdo_pos,
	  v_sdo_prom,v_sdo_disp,vi_intereses,vi_isr,
	  vd_exig,vd_no_exig MONEY(14,2);
   DEFINE vc_dia_sdo_pos,v_renglon,v_secuencia1,v_secuencia2 SMALLINT;
   DEFINE longitud,v_long_cte SMALLINT;
   DEFINE sql_err INTEGER;
   DEFINE vnocalle  INTEGER;
   DEFINE vnocolonia INTEGER;
   DEFINE vnociudad INTEGER;
   --RQM 09 704. Se agrega la siguiente variable DFTL 
   DEFINE mSaldo_SBC MONEY(14,2);


-- ************************************************************************
-- Inicializa variables
-- ************************************************************************
   LET cod_ret      = "00000";
   LET v_sucursal   = " ";
   LET v_producto   = " ";
   LET v_cuenta     = " ";
   LET v_sistema    = " ";
   LET v_fecha_alta = " ";
   LET v_fecha_venc = " ";
   LET v_monto1     = 0;
   LET v_monto2     = 0;
   LET v_renglon    = 0;
   LET v_calle      = " ";
   LET v_colonia    = " ";
   LET v_completo   = " ";
   LET v_delega     = " ";
   LET vnocalle     = 0;
   LET vnocolonia   = 0;
   LET vnociudad    = 0;
   --RQM 09 704. Se agrega la siguiente variable DFTL 
   LET mSaldo_SBC	 = 0;


   --SET DEBUG FILE TO "/home/c90402536/Traza/consinteg_web_modif.out";
   --TRACE ON; 
   
BEGIN

    ON EXCEPTION SET sql_err
		IF sql_err <> 0 then
		LET cod_ret = sql_err;
			return cod_ret,v_completo,v_sistema,v_cuenta,v_sucursal,v_producto,v_fecha_alta,v_fecha_venc,v_monto1,v_monto2,v_calle,v_colonia,v_delega;
		END IF
    END EXCEPTION;				 

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;				 
-- ***********************************************************************
    sELECT numcte,apell_paterno,apell_materno,nombre1,razon_social,tpo_persona
	   INTO v_numero,v_paterno,v_materno,v_nombre1,v_razon,v_tpersona
       FROM si_cliente
	wHERE numcte=pnum_cte;

	IF v_numero is null THEN
	    LET cod_ret = "00137";
		RETURN cod_ret,v_completo,v_sistema,v_cuenta,v_sucursal,v_producto,v_fecha_alta,v_fecha_venc,v_monto1,v_monto2,v_calle,v_colonia,v_delega;
	END IF

    IF (v_razon is null) or (trim(v_razon) = "") then
        LET v_completo = trim(v_paterno)||" "||trim(v_materno)||" "||trim(v_nombre1);
		  
	ELSE
        LET v_completo = v_razon;
    END IF

-- ***************************************************************************
-- Verifica si debe generar la tabla de consulta
-- ***************************************************************************
--   if prenglon = 0 then
    DELETE FROM si_consinteg
    WHERE sucursal = psucursal 
	AND usuario = pusuario 
	AND numcte  = pnum_cte;
      -- *********************************************************************
      -- Extrae la informacion del Sistema de Cheques
      -- *********************************************************************
    FOREACH
        --RQM 09 704. Se agrega el campo saldo_sbc al calculo del saldo disponible. DFTL 
        SELECT mc.cuenta,sucursal,mc.producto||" "||pr.nombre,fecha_alta,
		dia_sdo_pos,acum_sdo_pos,sdo_actual,sdo_retenido,
		sdo_cong,saldo_sbc,numerocalle,numerocolonia,numerociudad,
			CASE
			 WHEN status_cta = "1" and marca_ret ="0" then
				  "Sin Deposito Inicial"
			 WHEN status_cta ="1" and marca_ret ="1" then
				  "Activa"
			 WHEN status_cta ="2" then
				  "Cancelada"
			 WHEN status_cta = "3" then
				  "Bloqueada"	
			 WHEN status_cta = "4" then
					"Inactiva"
			 WHEN status_cta = "5" then
					"Informada"
			 WHEN status_cta = "6" then
					"Concentrada"
			 WHEN status_cta = "7" then
					"Traspasada"
			 WHEN status_cta = "8" then
					"DesConcentrada"
			END
        INTO v_cuenta,v_sucursal,v_producto,v_fecha_alta,
	        vc_dia_sdo_pos,vc_acum_sdo_pos,vc_sdo_actual,vc_sdo_retenido,
	        vc_sdo_cong,mSaldo_SBC,vnocalle,vnocolonia,vnociudad, v_delega
        FROM bdicheq:sc_maechq mc,
		      bdicheq:sc_maenoc mn,					
              bdicheq:sc_producto pr,
	    OUTER si_direcciones di					
        WHERE num_cte = pnum_cte 
		  AND mc.cuenta = mn.cuenta 
		  AND mc.producto = pr.producto 
		  AND numcte = num_cte 
		  AND secuencia = direcc_envio
         ORDER BY mc.cuenta
		 
        IF vc_dia_sdo_pos > 0 THEN
            LET v_sdo_prom = vc_acum_sdo_pos / vc_dia_sdo_pos;
        ELSE
			LET v_sdo_prom = 0;
        END IF

        --RQM 09 704. Se agrega el campo saldo_sbc al calculo del saldo disponible. DFTL 
        LET v_sdo_disp = vc_sdo_actual - vc_sdo_retenido - vc_sdo_cong - mSaldo_SBC;
        LET v_monto1   = v_sdo_prom;
        LET v_monto2   = v_sdo_disp;

		IF v_monto2 is null then
			LET v_monto2 = 0;
		END IF

		IF v_monto1 is null then
			LET v_monto1 = 0;
		END IF

        -- Extrae la Direccion Coppel
        SELECT nvl(nombrecalle,"") 
		  INTO v_calle					
        FROM si_catcalles 
		WHERE numerocalle = vnocalle;
		 
        Select nvl(nombrezona,"")
        into v_colonia
        From si_catzonas
		where numerociudad = vnociudad 
		  and numerocolonia = vnocolonia;
		  
        IF v_colonia is null THEN
           LET v_colonia = "";
        END IF

         --Graba la informacion en la tabla temporal de consulta integral
         let v_renglon = v_renglon + 1;
		 
        INSERT INTO si_consinteg
        VALUES(psucursal,pusuario,v_renglon,pnum_cte,"01",v_cuenta,
	        v_sucursal,v_producto,v_fecha_alta,v_fecha_alta,
	        v_monto2,v_monto1,v_calle,v_colonia,v_delega);
    END FOREACH

      -- *********************************************************************
      -- Extrae la informacion del Sistema de Inversiones
      -- *********************************************************************
    FOREACH
        SELECT cuenta,mv.sucursal,mv.cod_instrum||" "||pr.nombre,
               mv.fecha_alta,fecha_venc,capital,intereses,isr,mv.secuencia,
               mv.secuencia,calle,colonia,municipio,
	       DECODE(status_cta, "1","Activa","3","Bloqueada")
           into v_cuenta,v_sucursal,v_producto,v_fecha_alta,
	        v_fecha_venc,v_monto1,vi_intereses,vi_isr,v_secuencia1,
		   v_secuencia2,vnocalle,vnocolonia,vnociudad, v_delega
        FROM bdinvers:sv_maeinv mv,
              bdinvers:sv_instrum pr,
	    OUTER si_direcciones di
        WHERE mv.num_cte = pnum_cte
	    and mv.status_cta="1" and mv.cod_instrum = pr.cod_instrum
	    and numcte = pnum_cte and di.secuencia = direcc_envio
        ORDER BY cuenta
		 
        LET v_monto2   = vi_intereses - vi_isr;

		if v_monto2 is null then
			let v_monto2 = 0;
		end if

		if v_monto1 is null then
			let v_monto1 = 0;
		end if

        -- Extrae la Direccion Coppel
        select nvl(nombrecalle,"") 
		into v_calle
        From si_catcalles 
		where numerocalle = vnocalle;
		
        Select nvl(nombrezona,"")
        into v_colonia
        From si_catzonas
        where numerociudad = vnociudad 
		and numerocolonia = vnocolonia;
		
        if v_colonia is null then
           let v_colonia = "";
        end if
        if v_calle is null then
           let v_calle = "";
        end if

        --Graba la informacion en la tabla temporal de consulta integral
        let v_renglon = v_renglon + 1;
         insert into si_consinteg
        values(psucursal,pusuario,v_renglon,pnum_cte,"03",v_cuenta,
        v_sucursal,v_producto,v_fecha_alta,v_fecha_venc,
	        v_monto1,v_monto2,v_calle,v_colonia,v_delega);
    END FOREACH
      -- *********************************************************************
      -- Extrae la informacion del Sistema de Credito
      -- *********************************************************************

      FOREACH
        select mc.num_credito,sucursal,mc.num_producto||" "||pr.nombre_prod,
               fecha_apertura,
               fecha_vencim,sdo_cap_insoluto,sdo_no_exig,sdo_exig_int,
			   CASE WHEN (status_cred IN ("AA","E1") AND (ms.monto_vencido + ms.mto_venc_trasp) = 0) THEN "Activo"
			   WHEN status_cred  IN ("BA","BT","E1","E2","E3") THEN "Suspendido"
			   WHEN status_cred ="FF" THEN "Liquidado"
			   WHEN status_cred ="CC" THEN "Problematico"
			   ELSE "Convenio" END
          into v_cuenta,v_sucursal,v_producto,v_fecha_alta,
               v_fecha_venc,v_monto1,vd_no_exig,vd_exig, v_delega
          from bdicred:sd_maecred mc,
               bdicred:sd_maesdos ms,
               bdicred:sd_definicion pr
         where numcte = pnum_cte 
           and mc.num_credito = ms.num_credito 
           and mc.num_producto = pr.num_producto
         order by 1
			
	    LET v_monto2 = vd_exig + vd_no_exig;
	    
	    if v_monto2 is null then
	       LET v_monto2 = 0;
	    end if
	    if v_monto1 is null then
	       LET v_monto1 = 0;
	    end if

         --Graba la informacion en la tabla temporal de consulta integral
        LET v_renglon = v_renglon + 1;
        INSERT INTO si_consinteg
            VALUES(psucursal,pusuario,v_renglon,pnum_cte,"06",v_cuenta,
	           v_sucursal,v_producto,v_fecha_alta,v_fecha_venc,
	           v_monto1,v_monto2,v_calle,v_colonia,v_delega);
    END FOREACH
   -- ************************************************************************
   -- Verifica si existen renglones en la tabla
   -- ************************************************************************
    select count(*) into v_numero
    from si_consinteg
    where sucursal = psucursal and usuario = pusuario and
	 numcte  = pnum_cte;

   -- ***********************************************************************
   -- Regresa la informacion generada en la tabla a partir del num de renglon
   -- ***********************************************************************
    IF v_numero <= 0 then
		LET cod_ret = "00127";

		IF v_fecha_venc is null then
			LET v_fecha_venc = today;
		END IF
	  
      RETURN cod_ret,v_completo,v_sistema,v_cuenta,v_sucursal,
	     v_producto,v_fecha_alta,v_fecha_venc,v_monto1,v_monto2,
	     v_calle,v_colonia,v_delega;
    END IF
    FOREACH
        SELECT sistema,cuenta,sucursal_cta,producto,fecha_alta,
	     fecha_venc,importe_1,importe_2,calle,colonia,delegacion
	     into v_sistema,v_cuenta,v_sucursal,v_producto,v_fecha_alta,
	     v_fecha_venc,v_monto1,v_monto2,v_calle,v_colonia,v_delega
        FROM si_consinteg
		WHERE sucursal = psucursal and								
	    usuario  = pusuario  and
	    numcte  = pnum_cte  and
	    renglon  > prenglon
        IF v_fecha_venc is null then
			let v_fecha_venc = today;
        END IF
        RETURN cod_ret,v_completo,v_sistema,v_cuenta,v_sucursal,
		v_producto,v_fecha_alta,v_fecha_venc,v_monto1,
		v_monto2,v_calle,v_colonia,v_delega WITH RESUME;
    END FOREACH
END
END PROCEDURE
DOCUMENT
"MODIFICO : Manuel Hernandez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1",
"MODIFICADO:            Donovan F. Torres Landeros",
"ULTIMA MODIFICACION:   2025/06/04",
"RAZON:                 Se agrega la nueva variable sdo_sbc (saldo buen cobro)",
"                       a la operacion aritmetica para el nuevo calculo de",
"                       saldo disponible.",
"PROYECTO: RQM 09 704   Cobranza Automatica en cuentas de captacion",
"BD:                    bdicheq",
"VER:                   1.2";

CREATE PROCEDURE "informix".sp_cnsif_consprodcte(cID_USUARIOC CHAR(10),cID_FUNCIONC CHAR(10),cNUMCTE CHAR(20),cSISTEMACUENTA CHAR(2),pNumRegistro INTEGER,pRecuperacion INTEGER)
				returning 
				CHAR(5)     AS Cod_Retorno,
				CHAR(1)     AS Producto,
				CHAR(2)     AS Sistema_Cuenta,
				CHAR(20)    AS Numero_Cuenta,
				CHAR(4)     AS Cve_Producto,
				CHAR(40)    AS Nombre_Producto,
				DATE        AS Fecha_Apertura,
				CHAR(60)    AS Status_Cuenta,
				DATE        AS Fecha_Status,
				CHAR(4)     AS Clave_Sucursal,
				CHAR(8)     AS Ejecutivo,
				MONEY(14,2) AS Saldo_Actual,
                CHAR(20)    AS Numero_Tarjeta,
				CHAR(15)    AS Status_Tarjeta,
				CHAR(18)    AS Cuenta_CLABE,
				DATE        AS Fecha_Apertura_Inversion,
                SMALLINT    AS Dia_Corte,
				DATE		AS Fecha_cancelacion,
				CHAR(2)     AS cod_status;


DEFINE iexiste 				INT;
DEFINE cCodRet 				CHAR(5);
DEFINE iSql_err 			INT;
--SISTEMA DE CUENTA 01 VARIABLES
DEFINE cIProducto_chequera	CHAR(1);
DEFINE cScuenta				CHAR(2);
DEFINE cNo_cuenta			CHAR(20);
DEFINE cNo_tarjeta			CHAR(20);
DEFINE cClave_producto		CHAR(4);
DEFINE cNombre_producto		CHAR(40);
DEFINE cCuenta_clabe		CHAR(18);
DEFINE dFecha_apertura		DATE;
DEFINE cStatus_tarjeta		CHAR(15);
DEFINE cStatus_cuenta		CHAR(60);
DEFINE dFecha_status		DATE;
DEFINE cClave_sucursal		CHAR(4);
DEFINE cEjecutivo 			CHAR(8);
DEFINE mSaldo_actual		MONEY(14,2);
DEFINE dFecha_aperturaO_inv DATE;
DEFINE dFecha_max			DATE;
DEFINE dFecha_min			DATE;
DEFINE cNumero_cuenta 		CHAR(20);
DEFINE dFecha 				DATE;
DEFINE iCont                INTEGER;
DEFINE iMaxSec              INTEGER;
DEFINE cCtaInv              CHAR(20);
DEFINE cDiaCorte            SMALLINT;
DEFINE dFecha_cancelacion	DATE;
DEFINE iTpo_cliente			INT;
DEFINE cNumCtePrincipal 	CHAR(20);
DEFINE cNumCteTf			CHAR(20);
DEFINE cCodStatusCta        CHAR(2);



--inicializando variables
LET  iexiste 		     = 0;
LET cCodRet 		     = "00000";
LET iSql_err 			 = 0 ;
--SISTEMA DE CUENTA 01 VARIABLES
LET cIProducto_chequera	 = "";
LET cScuenta		 	 = "";
LET cNo_cuenta		 	 = "";
LET cNo_tarjeta			 = "";
LET cClave_producto		 = "";
LET cNombre_producto	 = "";
LET cCuenta_clabe		 = "";
LET dFecha_apertura		 = "";
LET cStatus_tarjeta		 = "";
LET cStatus_cuenta		 = "";
LET dFecha_status		 = "";
LET cClave_sucursal		 = "";
LET cEjecutivo 			 = "";
LET mSaldo_actual		 = 0;
LET dFecha_aperturaO_inv = "";
LET dFecha_max			 = "";
LET dFecha_min			 = "";
LET cNumero_cuenta 		 = "" ;
LET iCont				 = 0;
LET iMaxSec				 = 0;
LET cCtaInv				 = '';
LET cDiaCorte            = 0;
LET dFecha_cancelacion 	 = "";
LET iTpo_cliente		 = 0;
LET cNumCteTf 			 = "";
LET cNumCtePrincipal 	 = "";
LET cCodStatusCta 		 = "";



BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN
			cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cNo_tarjeta,cClave_producto,cNombre_producto,cCuenta_clabe,dFecha_apertura,
			cStatus_tarjeta,cStatus_cuenta,dFecha_status,cClave_sucursal,cEjecutivo,mSaldo_actual,dFecha_aperturaO_inv,cDiaCorte,dFecha_cancelacion,cCodStatusCta;
		END IF;
	END EXCEPTION;
	
   --SET DEBUG FILE TO "/home/c90402536/Traza/sp_cnsif_consprodcte_modf.out";
   --TRACE ON; 
		  
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF 	cID_USUARIOC = '' OR
		cID_FUNCIONC = '' OR
		cNUMCTE  = ''	  OR
		cSISTEMACUENTA = '' THEN
		LET cCodRet = "00036";
		RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
        cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cDiaCorte,dFecha_cancelacion,cCodStatusCta;

	END IF;
	IF cSISTEMACUENTA <> '01' AND cSISTEMACUENTA <> '06'  AND cSISTEMACUENTA <> '03' AND cSISTEMACUENTA <> '00'  THEN
		LET cCodRet = "00037";
		RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
        cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cDiaCorte,dFecha_cancelacion,cCodStatusCta;
	END IF;

    IF pNumRegistro<0 THEN
        LET cCodRet='00098';
		RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
        cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cDiaCorte,dFecha_cancelacion,cCodStatusCta;				
    ELSE
        IF pRecuperacion<=0 THEN
            LET cCodRet='00098';
            RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cDiaCorte,dFecha_cancelacion,cCodStatusCta;
        END IF;
    END IF;    	
	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCTE,cSISTEMACUENTA,'2')
	INTO
	cCodRet;
	IF (cCodRet != '00000')  THEN
		RETURN 
		cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cNo_tarjeta,cClave_producto,cNombre_producto,cCuenta_clabe,dFecha_apertura,
		cStatus_tarjeta,cStatus_cuenta,dFecha_status,cClave_sucursal,cEjecutivo,mSaldo_actual,dFecha_aperturaO_inv,cDiaCorte,dFecha_cancelacion,cCodStatusCta;
	END IF;
	-- TERMINA VALIDACION	

	EXECUTE PROCEDURE bdicnweb:"informix".sp_validacte_transfer(cNUMCTE) INTO cCodRet,iTpo_cliente,cNumCtePrincipal;
	IF cNumCtePrincipal IS NOT NULL THEN
		LET cNUMCTE = cNumCtePrincipal;
	END IF;

	IF cSISTEMACUENTA = '01' THEN
		FOREACH
		select FIRST 1 NVL(COUNT(cuenta),0)  INTO iexiste FROM bdicheq:"informix".sc_maechq WHERE num_cte = cNUMCTE
		UNION
		select NVL(COUNT(cuenta_tf),0) FROM bditransfer:"informix".tf_maecte WHERE CASE WHEN iTpo_cliente = 1 THEN numcte_tf ELSE numcte END = cNUMCTE
		order by 1 desc
		END FOREACH;
		
		IF iexiste = 0 THEN 
			LET cCodRet = "00024";
			RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cDiaCorte,dFecha_cancelacion,cCodStatusCta;
		END IF;	

		---SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT SKIP pNumRegistro FIRST pRecuperacion cuenta AS cuenta INTO cNumero_cuenta
			FROM bdicheq:"informix".sc_maechq
			WHERE num_cte = cNUMCTE 
			UNION
			SELECT cuenta_tf AS cuenta 
			FROM bditransfer:"informix".tf_maecte
			WHERE CASE WHEN iTpo_cliente = 1 THEN numcte_tf ELSE numcte END = cNUMCTE
			ORDER BY cuenta

			SELECT COUNT(cuenta)
			INTO iexiste
			FROM bditransfer:tf_account_balance_customer
			WHERE cuenta = cNumero_cuenta;
						
			IF iexiste = 0 THEN
				FOREACH	
				--RQM 09 704. Se agrega el campo saldo_sbc al calculo del saldo disponible. DFTL 
				SELECT DECODE(MC.producto,"2200","S","1900","S","N"),'01',cNumero_cuenta, MC.producto,PR.nombre,
				MC.cuenta_clabe,DECODE(MC.status_cta,"1","ACTIVA","2","CANCELADA","3","BLOQUEADA","4","INACTIVA","5","INFORMADA","6","CONCENTRADA","7","BENEFICIENCIA","8","DESCONCENTRADA"),
				MC.fec_cancelac, MC.sucursal,MC.sdo_actual - (MC.sdo_retenido + MC.sdo_cong + MC.imp_sbg_ccc + MC.saldo_sbc)AS SALDO,MC.status_cta
				INTO cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,cCuenta_clabe,cStatus_cuenta,
				dFecha_status,cClave_sucursal,mSaldo_actual,cCodStatusCta
				FROM bdicheq:"informix".sc_maechq MC,
				bdicheq:"informix".sc_producto PR
				WHERE MC.cuenta = cNumero_cuenta AND
				PR.producto = MC.producto
				UNION
				SELECT "N","01",cNumero_cuenta, MC.producto,PR.nombre,
				MC.cta_clabe,DECODE(MC.status_cta,"1","ACTIVA","2","CANCELADA","3","BLOQUEADA","4","INACTIVA","5","INFORMADA","6","CONCENTRADA","7","BENEFICIENCIA","8","DESCONCENTRADA"),
				MC.fec_cancelac,'0000' , 0 AS SALDO,MC.status_cta
				FROM bditransfer:"informix".tf_maecte MC,
				bdicheq:"informix".sc_producto PR
				WHERE MC.cuenta_tf = cNumero_cuenta
				AND PR.producto = MC.producto
				END FOREACH;
			ELSE
				FOREACH
			    --RQM 09 704. Se agrega el campo saldo_sbc al calculo del saldo disponible. DFTL
				SELECT DECODE(MC.producto,"2200","S","1900","S","N"),'01',cNumero_cuenta, MC.producto,PR.nombre,
				MC.cuenta_clabe,DECODE(MC.status_cta,"1","ACTIVA","2","CANCELADA","3","BLOQUEADA","4","INACTIVA","5","INFORMADA","6","CONCENTRADA","7","BENEFICIENCIA","8","DESCONCENTRADA"), 
				MC.fec_cancelac, MC.sucursal,MC.sdo_actual - (MC.sdo_retenido + MC.sdo_cong + MC.imp_sbg_ccc + MC.saldo_sbc)AS SALDO,
				MC.status_cta
				INTO cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,cCuenta_clabe,cStatus_cuenta,
				dFecha_status,cClave_sucursal,mSaldo_actual,cCodStatusCta
				FROM bdicheq:"informix".sc_maechq MC,
				bdicheq:"informix".sc_producto PR
				WHERE MC.cuenta = cNumero_cuenta AND
				PR.producto = MC.producto
				UNION
				SELECT "N","01",cNumero_cuenta, MC.producto,PR.nombre,
				MC.cta_clabe,DECODE(MC.status_cta,"1","ACTIVA","2","CANCELADA","3","BLOQUEADA","4","INACTIVA","5","INFORMADA","6","CONCENTRADA","7","BENEFICIENCIA","8","DESCONCENTRADA"),
				MC.fec_cancelac,'0000' ,SDO.sdo_cta AS SALDO,
				MC.status_cta
				FROM bditransfer:"informix".tf_maecte MC,
				bdicheq:"informix".sc_producto PR, bditransfer:tf_account_balance_customer SDO
				WHERE MC.cuenta_tf = cNumero_cuenta AND
				PR.producto = MC.producto AND
				MC.cuenta_tf = SDO.cuenta
				AND SDO.fecha_proceso = (SELECT MAX(fecha_proceso) FROM bditransfer:tf_account_balance_customer WHERE cuenta = cNumero_cuenta)
				END FOREACH;
			END IF;

			FOREACH
			SELECT fecha_alta, ejecutivo
			INTO dFecha_apertura,cEjecutivo
			FROM bdicheq:"informix".sc_maenoc
			WHERE cuenta =cNumero_cuenta
			UNION
			SELECT fec_alta,'TRANSFER'
			FROM bditransfer:"informix".tf_maecte
			WHERE cuenta_tf =cNumero_cuenta
			END FOREACH;

			SELECT numcte_tf, fec_cancelac
			INTO cNumCteTf, dFecha_cancelacion
			FROM bditransfer:"informix".tf_maecte
			WHERE cuenta_tf = cNumero_cuenta;
			
			SELECT num_tarjeta
			INTO cNo_tarjeta
			FROM  bdicheq:"informix".sc_tarjeta
			WHERE cuenta = cNumero_cuenta
			AND numcte = cNUMCTE
			AND tipo_tarjeta='T' AND secuencia IN (SELECT max(secuencia) FROM  bdicheq:"informix".sc_tarjeta
            WHERE cuenta = cNumero_cuenta
			AND numcte = cNUMCTE
			AND tipo_tarjeta='T');
			
            SELECT LIMIT 1 {+INDEX (intercard:tarjeta idx_numcte)} NVL(UPPER(B.descstatustarjeta),"") INTO cStatus_tarjeta FROM intercard:tarjeta A
            LEFT JOIN intercard:statustarjeta B
            ON A.codstatustarjeta = B.codstatustarjeta
            WHERE A.numcliente= cNUMCTE
            AND A.numtarjeta= cNo_tarjeta;

			IF cClave_producto='1100' THEN
				SELECT fec_ult_mov INTO dFecha_status FROM bdicheq:"informix".sc_maechq WHERE cuenta = cNumero_cuenta AND empresa='001' and status_cta='2';
			END IF;

            LET cDiaCorte=SUBSTR(dFecha_apertura,4,2); 

            LET iCont=iCont+1;	
			
			-- Se busca la fecha de cancelacion
	        IF cNumCteTf IS NULL THEN
		        EXECUTE PROCEDURE "informix".sp_consultafechacancelacioncta(cNumero_cuenta, '01') INTO cCodRet, dFecha_cancelacion;
	        END IF;
			
			RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cDiaCorte,dFecha_cancelacion,cCodStatusCta WITH resume;
		END FOREACH;
        IF iCont = 0 THEN
            DELETE {+INDEX (bdinteg:si_tempoctas idx_tempoctas)} FROM "informix".si_tempoctas WHERE numcte = cNUMCTE AND ejecutivosif= cID_USUARIOC;
            LET cCodRet = '1001'; 
			RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cDiaCorte,dFecha_cancelacion,cCodStatusCta;
        END IF 
	ELIF cSISTEMACUENTA = '03' THEN
		SELECT NVL(COUNT(cuenta),0)  INTO iexiste FROM bdinvers:"informix".sv_maeinv WHERE num_cte = cNUMCTE;
		
		IF iexiste = 0 THEN 
			LET cCodRet = "00024";
			RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cDiaCorte,dFecha_cancelacion,cCodStatusCta;
		END IF;	

		---SET ISOLATION TO DIRTY READ;
		FOREACH
            SELECT SKIP pNumRegistro FIRST pRecuperacion DISTINCT cuenta INTO cCtaInv FROM bdinvers:"informix".sv_maeinv
            WHERE num_cte=cNUMCTE ORDER BY cuenta

            SELECT NVL(MAX(secuencia),0) INTO iMaxSec FROM bdinvers:"informix".sv_maeinv WHERE CUENTA=cCtaInv;

			SELECT {+INDEX (bdinvers:sv_instrum idx_instrum)} 'N',cSISTEMACUENTA,MI.cuenta,MI.cod_instrum,IT.nombre,MI.fecha_alta,
			DECODE(MI.status_cta,"1","ACTIVA","2","CANCELADA","4","REINVERSION"),
            MI.adicionado,DECODE(MI.status_cta,"2",0,MI.capital),MI.sucursal,MI.fec_cancelac,
			MI.status_cta
			--MI.adicionado,MI.capital,MI.sucursal,MI.fec_cancelac
			INTO cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,cEjecutivo,
			mSaldo_actual,cClave_sucursal,dFecha_status,
			cCodStatusCta
			FROM bdinvers:"informix".sv_maeinv MI,
			bdinvers:"informix".sv_instrum IT
			WHERE MI.num_cte = cNUMCTE  AND IT.cod_instrum  = MI.cod_instrum
            AND MI.cuenta=cCtaInv
            and secuencia = iMaxSec;

            SELECT MIN(fecha_alta) INTO dFecha_aperturaO_inv FROM bdinvers:"informix".sv_maeinv WHERE num_cte = cNUMCTE and cuenta=cNo_cuenta;

            LET cDiaCorte=SUBSTR(dFecha_apertura,4,2); 

            LET iCont=iCont+1;
			
			-- FECHA DE CANCELACION
			EXECUTE PROCEDURE "informix".sp_consultafechacancelacioncta(cNo_cuenta, '03') INTO cCodRet, dFecha_cancelacion;

			RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cDiaCorte,dFecha_cancelacion,cCodStatusCta WITH resume;
		END FOREACH;
        IF iCont = 0 THEN
            DELETE {+INDEX (bdinteg:si_tempoctas idx_tempoctas)} from "informix".si_tempoctas WHERE numcte = cNUMCTE AND ejecutivosif= cID_USUARIOC;
            LET cCodRet = '1001'; 
			RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cDiaCorte,dFecha_cancelacion,cCodStatusCta;
        END IF 	
	ELIF cSISTEMACUENTA = '06' THEN
    IF pNumRegistro=0 THEN
        DELETE {+INDEX (bdinteg:si_tempoctas idx_tempoctas)} FROM si_tempoctas WHERE numcte = cNUMCTE AND ejecutivosif= cID_USUARIOC;
		FOREACH
            SELECT LIMIT 1 NVL(COUNT(num_credito),0) AS cant  INTO iexiste FROM bdicred:"informix".sd_maecred WHERE numcte = cNUMCTE
            UNION
            SELECT NVL(COUNT(num_credito),0) as cant FROM bdicred:"informix".sd_maecredcrd WHERE numcte = cNUMCTE ORDER BY CANT DESC
        END FOREACH;
		IF iexiste = 0 THEN 
			LET cCodRet = "00024";
			RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cDiaCorte,dFecha_cancelacion,cCodStatusCta;
		END IF;	

		---SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT num_credito INTO cNumero_cuenta
			FROM bdicred:"informix".sd_maecred
			WHERE numcte = cNUMCTE ORDER BY num_credito

			SELECT  MAX(fecha) INTO dFecha FROM bdicred:"informix".sd_bitacorabloqueocta WHERE cuenta = cNumero_cuenta;

			SELECT 'N',cSISTEMACUENTA,MC.num_credito, MC.num_producto,DE.nombre_prod,MC.fecha_apertura,
			TC.descripcion,	MC.sucursal,MC.ejecutivo, dFecha, TC.status_cred, MC.cuenta_clabe
			INTO cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,
			cStatus_cuenta,cClave_sucursal,cEjecutivo,dFecha_status,cCodStatusCta, cCuenta_clabe
			FROM bdicred:"informix".sd_maecred MC,
			bdicred:"informix".sd_tipocartera TC,
			bdicred:"informix".sd_definicion DE
			WHERE MC. num_credito  = cNumero_cuenta 
			AND	DE.num_producto = MC.num_producto
			AND MC.status_cred = TC.status_cred;

			SELECT sdo_cap_insoluto as Saldo
			INTO mSaldo_actual
			FROM bdicred:"informix".sd_maesdos
			WHERE num_credito =cNumero_cuenta;

			SELECT num_tarjeta
			INTO cNo_tarjeta
			FROM bdicred:"informix".sd_tarjeta 
			WHERE num_credito = cNumero_cuenta
			AND tipo_tarjeta='T' AND SECUENCIA IN (SELECT max(secuencia) FROM bdicred:"informix".sd_tarjeta
            WHERE num_credito = cNumero_cuenta
			AND numcte = cNUMCTE
			AND tipo_tarjeta='T');

            SELECT LIMIT 1 {+INDEX (intercard:tarjeta idx_numcte)} NVL(UPPER(B.descstatustarjeta),"") INTO cStatus_tarjeta FROM intercard:tarjeta A
            LEFT JOIN intercard:statustarjeta B
            ON A.codstatustarjeta = B.codstatustarjeta
            WHERE A.numcliente= cNUMCTE
            AND A.numtarjeta= cNo_tarjeta;
			
			

            IF cClave_producto IN ('6001','6600','7000','8100','8500', '5400') THEN
                SELECT dia_cuota
				INTO cDiaCorte
				FROM bdicred:sd_definicion
				WHERE num_producto = cClave_producto; 
            ELIF cClave_producto IN ('6300','6800','7600','7700') THEN    
                LET cDiaCorte=SUBSTR(dFecha_apertura,4,2); 
			ELIF cClave_producto='6400' THEN    
                LET cDiaCorte='20'; 
            ELIF cClave_producto='6011' THEN    
                LET cDiaCorte=SUBSTR(dFecha_apertura,4,2); 
                IF cDiaCorte>=3 AND cDiaCorte<17 THEN
                    LET cDiaCorte=2;
                ELIF cDiaCorte IN (1,2) OR cDiaCorte>=17 THEN
                    LET cDiaCorte=17;
                ELSE
                    LET cDiaCorte=0;
                END IF;
            END IF;


            INSERT INTO "informix".si_tempoctas (codret,producto_chequera,scuenta,no_cuenta,clave_producto,nombre_producto,fecha_apertura,status_cuenta,
            fecha_status,clave_sucursal,ejecutivo,saldo_actual,no_tarjeta,status_tarjeta,cuenta_clabe,fecha_apertura_inv,numcte,ejecutivosif,dia_corte,cod_statuscta) 
            values (cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cNUMCTE,cID_USUARIOC,cDiaCorte,cCodStatusCta);
		END FOREACH;

		---SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT num_credito into cNumero_cuenta
			FROM bdicred:"informix".sd_maecredcrd
			WHERE numcte = cNUMCTE order by num_credito
			
			SELECT  MAX(fecha) INTO dFecha FROM bdicred:"informix".sd_bitacorabloqueocta WHERE cuenta = cNumero_cuenta;
			
			SELECT 'N',cSISTEMACUENTA,MC.num_credito, MC.num_producto,DE.nombre_prod,MC.fecha_apertura,
			TC.descripcion,	MC.sucursal,MC.ejecutivo, dFecha, TC.status_cred, MC.cuenta_clabe
			INTO cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,
			cStatus_cuenta,cClave_sucursal,cEjecutivo,dFecha_status,cCodStatusCta, cCuenta_clabe
			FROM bdicred:"informix".sd_maecredcrd MC,
			bdicred:"informix".sd_tipocartera TC,
			bdicred:"informix".sd_definicion DE
			WHERE MC. num_credito  = cNumero_cuenta 
			AND	DE.num_producto = MC.num_producto
			AND MC.status_cred = TC.status_cred;

			SELECT sdo_cap_insoluto as Saldo
			INTO mSaldo_actual
			FROM bdicred:"informix".sd_maesdoscrd
			WHERE num_credito =cNumero_cuenta;

			SELECT num_tarjeta
			INTO cNo_tarjeta
			FROM bdicred:"informix".sd_tarjeta 
			WHERE num_credito = cNumero_cuenta
			AND tipo_tarjeta='T' AND SECUENCIA IN (SELECT max(secuencia) FROM bdicred:"informix".sd_tarjeta
            WHERE num_credito = cNumero_cuenta
			AND numcte = cNUMCTE
			AND tipo_tarjeta='T');

            SELECT LIMIT 1 {+INDEX (intercard:tarjeta idx_numcte)} NVL(UPPER(B.descstatustarjeta),"") INTO cStatus_tarjeta FROM intercard:tarjeta A
            LEFT JOIN intercard:statustarjeta B
            ON A.codstatustarjeta = B.codstatustarjeta
            WHERE A.numcliente= cNUMCTE
            AND A.numtarjeta= cNo_tarjeta;


            IF cClave_producto IN ('6001','6600','7000','8100','8500', '5400') THEN
                SELECT dia_cuota
				INTO cDiaCorte
				FROM bdicred:sd_definicion
				WHERE num_producto = cClave_producto; 
            ELIF cClave_producto IN ('6300','6800','7600','7700') THEN    
                LET cDiaCorte=SUBSTR(dFecha_apertura,4,2); 
			ELIF cClave_producto='6400' THEN    
                LET cDiaCorte='20'; 
            ELIF cClave_producto='6011' THEN    
                LET cDiaCorte=SUBSTR(dFecha_apertura,4,2); 
                IF cDiaCorte>=3 AND cDiaCorte<17 THEN
                    LET cDiaCorte=2;
                ELIF cDiaCorte IN (1,2) OR cDiaCorte>=17 THEN
                    LET cDiaCorte=17;
                ELSE
                    LET cDiaCorte=0;
                END IF;
            END IF;


            INSERT INTO "informix".si_tempoctas (codret,producto_chequera,scuenta,no_cuenta,clave_producto,nombre_producto,fecha_apertura,status_cuenta,
            fecha_status,clave_sucursal,ejecutivo,saldo_actual,no_tarjeta,status_tarjeta,cuenta_clabe,fecha_apertura_inv,numcte,ejecutivosif,dia_corte,cod_statuscta) 
            values (cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cNUMCTE,cID_USUARIOC,cDiaCorte,cCodStatusCta);
		END FOREACH;
      END IF;  
        ---SET ISOLATION TO DIRTY READ;
        FOREACH
            SELECT {+INDEX (bdinteg:"informix".si_tempoctas idx_tempoctas)} SKIP pNumRegistro FIRST pRecuperacion codret,producto_chequera,scuenta,no_cuenta,
                        clave_producto,nombre_producto,fecha_apertura,nvl(status_cuenta,''),fecha_status,clave_sucursal,ejecutivo,saldo_actual,
                        nvl(no_tarjeta,''),nvl(status_tarjeta,''),cuenta_clabe,fecha_apertura_inv,dia_corte,cod_statuscta
                         INTO cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
                        cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cDiaCorte,cCodStatusCta
            FROM "informix".si_tempoctas
            WHERE numcte = cNUMCTE AND ejecutivosif= cID_USUARIOC ORDER BY scuenta,no_cuenta 
            
            LET iCont=iCont+1;
			
			-- FECHA DE CANCELACION
			EXECUTE PROCEDURE "informix".sp_consultafechacancelacioncta(cNo_cuenta, '06') INTO cCodRet, dFecha_cancelacion;
			
            RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cDiaCorte,dFecha_cancelacion,cCodStatusCta WITH resume;
        END FOREACH;
        IF iCont = 0 THEN
            DELETE {+INDEX (bdinteg:si_tempoctas idx_tempoctas)} from "informix".si_tempoctas WHERE numcte = cNUMCTE AND ejecutivosif= cID_USUARIOC;
            LET cCodRet = '1001'; 
			RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cDiaCorte,dFecha_cancelacion,cCodStatusCta;
        END IF 	
	ELIF cSISTEMACUENTA = '00' THEN
		IF cID_FUNCIONC = 'SKI002' THEN
			EXECUTE PROCEDURE "informix".sp_cnsif_consprodctekiosko(cID_USUARIOC,cNUMCTE,iTpo_cliente) INTO cCodRet;
			---SET ISOLATION TO DIRTY READ;
			FOREACH
				SELECT {+INDEX (bdinteg:si_tempoctas idx_tempoctas)} SKIP pNumRegistro FIRST pRecuperacion codret,producto_chequera,scuenta,no_cuenta,
				clave_producto, nombre_producto,fecha_apertura,nvl(status_cuenta,''),fecha_status,clave_sucursal,ejecutivo,saldo_actual,nvl(no_tarjeta,''),
				nvl(status_tarjeta,''),cuenta_clabe,fecha_apertura_inv,dia_corte,cod_statuscta
				into cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
				cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cDiaCorte,cCodStatusCta
				FROM "informix".si_tempoctas
				WHERE numcte = cNUMCTE AND ejecutivosif= cID_USUARIOC ORDER BY scuenta,no_cuenta,fecha_apertura 
				
				LET iCont=iCont+1;
				
				IF (cNo_cuenta <> '') THEN
					EXECUTE PROCEDURE "informix".sp_consultafechacancelacioncta(cNo_cuenta, cScuenta) INTO cCodRet, dFecha_cancelacion;
				END IF;
							
				RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
				cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cDiaCorte,dFecha_cancelacion,cCodStatusCta 
				WITH RESUME;
			END FOREACH;
			IF iCont = 0 THEN
				DELETE {+INDEX (bdinteg:si_tempoctas idx_tempoctas)} FROM "informix".si_tempoctas WHERE numcte = cNUMCTE AND ejecutivosif= cID_USUARIOC;
				LET cCodRet = '00363'; 
				RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
				cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cDiaCorte,dFecha_cancelacion,cCodStatusCta;
			END IF 
		ELSE
			FOREACH
				select first 1 NVL(COUNT(cuenta),0)  into iexiste FROM bdicheq:sc_maechq WHERE num_cte = cNUMCTE
				UNION
				select NVL(COUNT(cuenta_tf),0) FROM bditransfer:tf_maecte WHERE CASE WHEN iTpo_cliente = 1 THEN numcte_tf ELSE numcte END = cNUMCTE
				order by 1 desc
			END FOREACH;
			IF iexiste = 0 THEN 
				FOREACH
					SELECT LIMIT 1 NVL(COUNT(num_credito),0) AS cant  INTO iexiste FROM bdicred:"informix".sd_maecred WHERE numcte = cNUMCTE
					UNION
					SELECT NVL(COUNT(num_credito),0) AS cant FROM bdicred:"informix".sd_maecredcrd WHERE numcte = cNUMCTE ORDER BY CANT DESC
				END FOREACH;
				IF iexiste = 0 THEN 
					SELECT nvl(COUNT(cuenta),0)  INTO iexiste FROM bdinvers:"informix".sv_maeinv WHERE num_cte = cNUMCTE;
					
					IF iexiste = 0 THEN 
						LET cCodRet = "00024";
						RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
						cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cDiaCorte,dFecha_cancelacion,cCodStatusCta;
					END IF;
				END IF;
			END IF;	
		
			IF pNumRegistro=0 THEN
					DELETE {+INDEX (bdinteg:si_tempoctas idx_tempoctas)} from "informix".si_tempoctas WHERE numcte = cNUMCTE AND ejecutivosif= cID_USUARIOC;
					---SET ISOLATION TO DIRTY READ;
					FOREACH
						SELECT cuenta  as cuenta into cNumero_cuenta
						FROM bdicheq:"informix".sc_maechq
						WHERE num_cte = cNUMCTE

				UNION
				SELECT cuenta_tf  as cuenta
						FROM bditransfer:"informix".tf_maecte
						WHERE CASE WHEN iTpo_cliente = 1 THEN numcte_tf ELSE numcte END = cNUMCTE
				order by cuenta

				SELECT COUNT(cuenta)
				INTO iexiste
				FROM bditransfer:tf_account_balance_customer
				WHERE cuenta = cNumero_cuenta;
							
				IF iexiste = 0 THEN
					FOREACH
			        --RQM 09 704. Se agrega el campo saldo_sbc al calculo del saldo disponible. DFTL
					SELECT DECODE(MC.producto,"2200","S","1900","S","N"),'01',cNumero_cuenta, MC.producto,PR.nombre,
					MC.cuenta_clabe,DECODE(MC.status_cta,"1","ACTIVA","2","CANCELADA","3","BLOQUEADA","4","INACTIVA","5","INFORMADA","6","CONCENTRADA","7","BENEFICIENCIA","8","DESCONCENTRADA"), 
					MC.fec_cancelac, MC.sucursal,MC.sdo_actual - (MC.sdo_retenido + MC.sdo_cong + MC.imp_sbg_ccc + MC.saldo_sbc)AS SALDO,MC.status_cta
					INTO cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,cCuenta_clabe,cStatus_cuenta,
					dFecha_status,cClave_sucursal,mSaldo_actual,cCodStatusCta
					FROM bdicheq:"informix".sc_maechq MC,
					bdicheq:"informix".sc_producto PR
					WHERE MC.cuenta = cNumero_cuenta AND
					PR.producto = MC.producto
					UNION
					SELECT "N","01",cNumero_cuenta, MC.producto,PR.nombre,
					MC.cta_clabe,DECODE(MC.status_cta,"1","ACTIVA","2","CANCELADA","3","BLOQUEADA","4","INACTIVA","5","INFORMADA","6","CONCENTRADA","7","BENEFICIENCIA","8","DESCONCENTRADA"),
					MC.fec_cancelac,'0000' , 0 AS SALDO, MC.status_cta
					FROM bditransfer:"informix".tf_maecte MC,
					bdicheq:"informix".sc_producto PR
					WHERE MC.cuenta_tf = cNumero_cuenta
					AND PR.producto = MC.producto
					END FOREACH;
				ELSE
					FOREACH
			        --RQM 09 704. Se agrega el campo saldo_sbc al calculo del saldo disponible. DFTL
					SELECT DECODE(MC.producto,"2200","S","1900","S","N"),'01',cNumero_cuenta, MC.producto,PR.nombre,
					MC.cuenta_clabe,DECODE(MC.status_cta,"1","ACTIVA","2","CANCELADA","3","BLOQUEADA","4","INACTIVA","5","INFORMADA","6","CONCENTRADA","7","BENEFICIENCIA","8","DESCONCENTRADA"),
					MC.fec_cancelac, MC.sucursal,MC.sdo_actual - (MC.sdo_retenido + MC.sdo_cong + MC.imp_sbg_ccc + MC.saldo_sbc)AS SALDO,MC.status_cta
					INTO cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,cCuenta_clabe,cStatus_cuenta,
					dFecha_status,cClave_sucursal,mSaldo_actual,cCodStatusCta
					FROM bdicheq:"informix".sc_maechq MC,
					bdicheq:"informix".sc_producto PR
					WHERE MC.cuenta = cNumero_cuenta AND
					PR.producto = MC.producto
					UNION
					SELECT "N","01",cNumero_cuenta, MC.producto,PR.nombre,
					MC.cta_clabe,DECODE(MC.status_cta,"1","ACTIVA","2","CANCELADA","3","BLOQUEADA","4","INACTIVA","5","INFORMADA","6","CONCENTRADA","7","BENEFICIENCIA","8","DESCONCENTRADA"),
					MC.fec_cancelac,'0000' ,SDO.sdo_cta AS SALDO,MC.status_cta
					FROM bditransfer:"informix".tf_maecte MC,
					bdicheq:"informix".sc_producto PR, bditransfer:tf_account_balance_customer SDO
					WHERE MC.cuenta_tf = cNumero_cuenta AND
					PR.producto = MC.producto AND
					MC.cuenta_tf = SDO.cuenta
					AND SDO.fecha_proceso = (SELECT MAX(fecha_proceso) FROM bditransfer:tf_account_balance_customer WHERE cuenta = cNumero_cuenta)
					END FOREACH;
				END IF;
				
				FOREACH
				SELECT fecha_alta, ejecutivo
				INTO dFecha_apertura,cEjecutivo
				FROM bdicheq:"informix".sc_maenoc
				WHERE cuenta =cNumero_cuenta
				UNION
				SELECT fec_alta, 'TRANSFER'
				FROM bditransfer:"informix".tf_maecte
				WHERE cuenta_tf =cNumero_cuenta
				END FOREACH;
						
						SELECT num_tarjeta
						INTO cNo_tarjeta
						FROM  bdicheq:"informix".sc_tarjeta
						WHERE cuenta = cNumero_cuenta
						AND numcte = cNUMCTE
						AND tipo_tarjeta='T' AND secuencia IN (SELECT max(secuencia) FROM  bdicheq:"informix".sc_tarjeta
						WHERE cuenta = cNumero_cuenta
						AND numcte = cNUMCTE
						AND tipo_tarjeta='T');

						SELECT LIMIT 1 {+INDEX (intercard:tarjeta idx_numcte)} NVL(UPPER(B.descstatustarjeta),"") INTO cStatus_tarjeta FROM intercard:tarjeta A
						LEFT JOIN intercard:statustarjeta B
						ON A.codstatustarjeta = B.codstatustarjeta
						WHERE A.numcliente= cNUMCTE
						AND A.numtarjeta= cNo_tarjeta;

						IF cClave_producto='1100' THEN
							SELECT fec_ult_mov INTO dFecha_status FROM bdicheq:"informix".sc_maechq WHERE cuenta = cNumero_cuenta AND empresa='001' and status_cta='2';
						END IF;

						LET cDiaCorte=SUBSTR(dFecha_apertura,4,2); 

						INSERT INTO "informix".si_tempoctas (codret,producto_chequera,scuenta,no_cuenta,clave_producto,nombre_producto,fecha_apertura,status_cuenta,
						fecha_status,clave_sucursal,ejecutivo,saldo_actual,no_tarjeta,status_tarjeta,cuenta_clabe,fecha_apertura_inv,numcte,ejecutivosif,dia_corte,cod_statuscta) 
						values (cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
						cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cNUMCTE,cID_USUARIOC,cDiaCorte,cCodStatusCta);
					END FOREACH;

					---SET ISOLATION TO DIRTY READ;
					FOREACH

						SELECT {+INDEX (bdinvers:sv_instrum idx_instrum)} 'N','03',MI.cuenta,MI.cod_instrum,IT.nombre,MI.fecha_alta,
						DECODE(MI.status_cta,"1","ACTIVA","2","CANCELADA","4","REINVERSION"),
						MI.adicionado,DECODE(MI.status_cta,"2",0,MI.capital),MI.sucursal,MI.fec_cancelac,MI.status_cta
						--MI.adicionado,MI.capital,MI.sucursal,MI.fec_cancelac
						INTO cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,cEjecutivo,
						mSaldo_actual,cClave_sucursal,dFecha_status,cCodStatusCta
						FROM bdinvers:"informix".sv_maeinv MI,
						bdinvers:"informix".sv_instrum IT
						WHERE MI.num_cte = cNUMCTE AND IT.cod_instrum  = MI.cod_instrum ORDER BY MI.cuenta
						
						SELECT MIN(fecha_alta) INTO dFecha_aperturaO_inv FROM bdinvers:"informix".sv_maeinv WHERE num_cte = cNUMCTE and cuenta=cNo_cuenta;

						LET cDiaCorte=SUBSTR(dFecha_apertura,4,2); 

						INSERT INTO "informix".si_tempoctas (codret,producto_chequera,scuenta,no_cuenta,clave_producto,nombre_producto,fecha_apertura,status_cuenta,
						fecha_status,clave_sucursal,ejecutivo,saldo_actual,no_tarjeta,status_tarjeta,cuenta_clabe,fecha_apertura_inv,numcte,ejecutivosif,dia_corte,cod_statuscta) 
						values (cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
						cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cNUMCTE,cID_USUARIOC,cDiaCorte,cCodStatusCta);
						
					END FOREACH;

					---SET ISOLATION TO DIRTY READ;
					FOREACH
						SELECT num_credito into cNumero_cuenta
						FROM bdicred:"informix".sd_maecred
						WHERE numcte = cNUMCTE order by num_credito

						SELECT  MAX(fecha) INTO dFecha FROM bdicred:"informix".sd_bitacorabloqueocta WHERE cuenta = cNumero_cuenta;
						
						SELECT 'N','06',MC.num_credito, MC.num_producto,DE.nombre_prod,MC.fecha_apertura,
						TC.descripcion,	MC.sucursal,MC.ejecutivo, dFecha,TC.status_cred
						INTO cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,
						cStatus_cuenta,cClave_sucursal,cEjecutivo,dFecha_status,cCodStatusCta
						FROM bdicred:"informix".sd_maecred MC,
						bdicred:"informix".sd_tipocartera TC,
						bdicred:"informix".sd_definicion DE
						WHERE MC. num_credito  = cNumero_cuenta 
						AND	DE.num_producto = MC.num_producto
						AND MC.status_cred = TC.status_cred;

						SELECT sdo_cap_insoluto as Saldo
						INTO mSaldo_actual
						FROM bdicred:"informix".sd_maesdos
						WHERE num_credito =cNumero_cuenta;

						SELECT num_tarjeta
						INTO cNo_tarjeta
						FROM bdicred:"informix".sd_tarjeta 
						WHERE num_credito = cNumero_cuenta
						AND tipo_tarjeta='T' AND SECUENCIA IN (SELECT max(secuencia) FROM bdicred:"informix".sd_tarjeta
						WHERE num_credito = cNumero_cuenta
						AND numcte = cNUMCTE
						AND tipo_tarjeta='T');

						SELECT LIMIT 1 {+INDEX (intercard:tarjeta idx_numcte)} NVL(UPPER(B.descstatustarjeta),"") INTO cStatus_tarjeta FROM intercard:tarjeta A
						LEFT JOIN intercard:statustarjeta B
						ON A.codstatustarjeta = B.codstatustarjeta
						WHERE A.numcliente= cNUMCTE
						AND A.numtarjeta= cNo_tarjeta;

						IF cClave_producto IN ('6001','6600','7000','8100','8500', '5400') THEN
							SELECT dia_cuota
							INTO cDiaCorte
							FROM bdicred:sd_definicion
							WHERE num_producto = cClave_producto; 
						ELIF cClave_producto='6300' THEN    
							LET cDiaCorte=SUBSTR(dFecha_apertura,4,2); 
						ELIF cClave_producto='6400' THEN    
							LET cDiaCorte='20'; 
						ELIF cClave_producto='6011' THEN    
							LET cDiaCorte=SUBSTR(dFecha_apertura,4,2); 
							IF cDiaCorte>=3 AND cDiaCorte<17 THEN
								LET cDiaCorte=2;
							ELIF cDiaCorte IN (1,2) OR cDiaCorte>=17 THEN
								LET cDiaCorte=17;
							ELSE
								LET cDiaCorte=0;
							END IF;
						END IF;

						INSERT INTO "informix".si_tempoctas (codret,producto_chequera,scuenta,no_cuenta,clave_producto,nombre_producto,fecha_apertura,status_cuenta,
						fecha_status,clave_sucursal,ejecutivo,saldo_actual,no_tarjeta,status_tarjeta,cuenta_clabe,fecha_apertura_inv,numcte,ejecutivosif,dia_corte,cod_statuscta) 
						values (cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
						cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cNUMCTE,cID_USUARIOC,cDiaCorte,cCodStatusCta);
					END FOREACH;

					---SET ISOLATION TO DIRTY READ;
					FOREACH
						SELECT num_credito INTO cNumero_cuenta
						FROM bdicred:"informix".sd_maecredcrd
						WHERE numcte = cNUMCTE ORDER BY num_credito

						SELECT  MAX(fecha) INTO dFecha FROM bdicred:"informix".sd_bitacorabloqueocta WHERE cuenta = cNumero_cuenta;

						SELECT 'N','06',MC.num_credito, MC.num_producto,DE.nombre_prod,MC.fecha_apertura,
						TC.descripcion,	MC.sucursal,MC.ejecutivo, dFecha,TC.status_cred
						INTO cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,
						cStatus_cuenta,cClave_sucursal,cEjecutivo,dFecha_status,cCodStatusCta
						FROM bdicred:"informix".sd_maecredcrd MC,
						bdicred:"informix".sd_tipocartera TC,
						bdicred:"informix".sd_definicion DE
						WHERE MC. num_credito  = cNumero_cuenta 
						AND	DE.num_producto = MC.num_producto
						AND MC.status_cred = TC.status_cred;

						SELECT sdo_cap_insoluto AS Saldo
						INTO mSaldo_actual
						FROM bdicred:"informix".sd_maesdoscrd
						WHERE num_credito =cNumero_cuenta;
						
						SELECT num_tarjeta
						INTO cNo_tarjeta
						FROM bdicred:"informix".sd_tarjeta 
						WHERE num_credito = cNumero_cuenta
						AND tipo_tarjeta='T' AND SECUENCIA IN (SELECT max(secuencia) FROM bdicred:"informix".sd_tarjeta
						WHERE num_credito = cNumero_cuenta
						AND numcte = cNUMCTE
						AND tipo_tarjeta='T');

						SELECT LIMIT 1 {+INDEX (intercard:tarjeta idx_numcte)} NVL(UPPER(B.descstatustarjeta),"") INTO cStatus_tarjeta FROM intercard:tarjeta A
						LEFT JOIN intercard:statustarjeta B
						ON A.codstatustarjeta = B.codstatustarjeta
						WHERE A.numcliente= cNUMCTE
						AND A.numtarjeta= cNo_tarjeta;

						IF cClave_producto IN ('6001','6600','7000','8100','8500') THEN
							SELECT dia_cuota
							INTO cDiaCorte
							FROM bdicred:sd_definicion
							WHERE num_producto = cClave_producto; 
						ELIF cClave_producto='6300' THEN    
							LET cDiaCorte=SUBSTR(dFecha_apertura,4,2); 
						ELIF cClave_producto='6400' THEN    
							LET cDiaCorte='20'; 
						ELIF cClave_producto='6011' THEN    
							LET cDiaCorte=SUBSTR(dFecha_apertura,4,2); 
							IF cDiaCorte>=3 AND cDiaCorte<17 THEN
								LET cDiaCorte=2;
							ELIF cDiaCorte IN (1,2) OR cDiaCorte>=17 THEN
								LET cDiaCorte=17;
							ELSE
								LET cDiaCorte=0;
							END IF;
						END IF;

						INSERT INTO "informix".si_tempoctas (codret,producto_chequera,scuenta,no_cuenta,clave_producto,nombre_producto,fecha_apertura,status_cuenta,
						fecha_status,clave_sucursal,ejecutivo,saldo_actual,no_tarjeta,status_tarjeta,cuenta_clabe,fecha_apertura_inv,numcte,ejecutivosif,dia_corte,cod_statuscta) 
						values (cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
						cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cNUMCTE,cID_USUARIOC,cDiaCorte,cCodStatusCta);
					END FOREACH;

			END IF 

			--SET ISOLATION TO DIRTY READ;
			FOREACH
				SELECT {+INDEX (bdinteg:si_tempoctas idx_tempoctas)} SKIP pNumRegistro FIRST pRecuperacion codret,producto_chequera,scuenta,no_cuenta,clave_producto,
							nombre_producto,fecha_apertura,nvl(status_cuenta,''),fecha_status,clave_sucursal,ejecutivo,saldo_actual,nvl(no_tarjeta,''),
							nvl(status_tarjeta,''),cuenta_clabe,fecha_apertura_inv,dia_corte,cod_statuscta
							into cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
							cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cDiaCorte,cCodStatusCta
				FROM "informix".si_tempoctas
				WHERE numcte = cNUMCTE AND ejecutivosif= cID_USUARIOC ORDER BY scuenta,no_cuenta,fecha_apertura 
				
				LET iCont=iCont+1;
				
				IF (cNo_cuenta <> '') THEN
					EXECUTE PROCEDURE "informix".sp_consultafechacancelacioncta(cNo_cuenta, cScuenta) INTO cCodRet, dFecha_cancelacion;
				END IF;
							
				RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
				cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cDiaCorte,dFecha_cancelacion,cCodStatusCta WITH resume;
			END FOREACH;
			IF iCont = 0 THEN
				DELETE {+INDEX (bdinteg:si_tempoctas idx_tempoctas)} FROM "informix".si_tempoctas WHERE numcte = cNUMCTE AND ejecutivosif= cID_USUARIOC;
				LET cCodRet = '1001'; 
				RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
				cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cDiaCorte,dFecha_cancelacion,cCodStatusCta;
			END IF
		END IF
	END IF
END
END PROCEDURE
DOCUMENT
"AutOR : Antonio Flores",
"FUNCIONAMIENTO:Este sp realizara la busqueda por tipo de cuenta, dependiendo de tipo de cuenta regresara los datos correspondientes, para captacion o cuenta de cheques",
"para cuentas tipo credito 06 que seran de credito y las cuentas tipo 03 que son de  tipo inversiones",
"FECHA : 04-01-2012",
"BD    : bdinteg",
"Modifico : Victor Hugo Sanchez",
"MODIFICACION : Se almacenan los datos de las cuentas en tabla de paso y se agrega la paginacion",
"Modifico : Oscar Flores Conde",
"MODIFICACION : Se agrega la fecha de cancelacion de la cuenta",
"FECHA : 01-08-2015",
"Modifico : Oscar Flores Conde",
"MODIFICACION : Se agrega el codigo de estatus de la cuenta",
"VER   : 1.0",
"FECHA : 03-04-2020",
"Modifico : Johnattan Esquivel SÃ¡nchez",
"MODIFICACION : Se agrega el retorno cuenta CLABE productos de Credito",
"VER   : 1.0",
"MODIFICADO:            Donovan F. Torres Landeros",
"ULTIMA MODIFICACION:   2025/06/04",
"RAZON:                 Se agrega la nueva variable sdo_sbc (saldo buen cobro)",
"                       a la operacion aritmetica para el nuevo calculo de",
"                       saldo disponible.",
"PROYECTO: RQM 09 704   Cobranza Automatica en cuentas de captacion",
"BD:                    bdicheq",
"VER:                   1.2";

CREATE PROCEDURE "informix".sp_cnsif_consprodcte_fstatus(cID_USUARIOC CHAR(10),cID_FUNCIONC CHAR(10),cNUMCTE CHAR(20),cSISTEMACUENTA CHAR(2),pNumRegistro INTEGER,pRecuperacion INTEGER)
	RETURNING 
		CHAR(5)     AS Cod_Retorno,
		CHAR(1)     AS Producto,
		CHAR(2)     AS Sistema_Cuenta,
		CHAR(20)    AS Numero_Cuenta,
		CHAR(4)     AS Cve_Producto,
		CHAR(40)    AS Nombre_Producto,
		DATE        AS Fecha_Apertura,
		CHAR(60)    AS Status_Cuenta,
		DATE        AS Fecha_Status,
		CHAR(4)     AS Clave_Sucursal,
		CHAR(8)     AS Ejecutivo,
		MONEY(14,2) AS Saldo_Actual,
		CHAR(20)    AS Numero_Tarjeta,
		CHAR(15)    AS Status_Tarjeta,
		CHAR(18)    AS Cuenta_CLABE,
		DATE        AS Fecha_Apertura_Inversion,
		SMALLINT    AS Dia_Corte,
		DATE		AS Fecha_cancelacion,
		CHAR(2)     AS cod_status,
		DATE 		AS FechaStatus;


DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;
--SISTEMA DE CUENTA 01 VARIABLES
DEFINE cIProducto_chequera	CHAR(1);
DEFINE cScuenta				CHAR(2);
DEFINE cNo_cuenta			CHAR(20);
DEFINE cNo_tarjeta			CHAR(20);
DEFINE cClave_producto		CHAR(4);
DEFINE cNombre_producto		CHAR(40);
DEFINE cCuenta_clabe		CHAR(18);
DEFINE dFecha_apertura		DATE;
DEFINE cStatus_tarjeta		CHAR(15);
DEFINE cStatus_cuenta		CHAR(60);
DEFINE dFecha_status		DATE;
DEFINE cClave_sucursal		CHAR(4);
DEFINE cEjecutivo 			CHAR(8);
DEFINE mSaldo_actual		MONEY(14,2);
DEFINE dFecha_aperturaO_inv DATE;
DEFINE dFecha_max			DATE;
DEFINE dFecha_min			DATE;
DEFINE cNumero_cuenta 		CHAR(20);
DEFINE dFecha 				DATE;
DEFINE iCont                INTEGER;
DEFINE iMaxSec              INTEGER;
DEFINE cCtaInv              CHAR(20);
DEFINE cDiaCorte            SMALLINT;
DEFINE dFecha_cancelacion	DATE;
DEFINE iTpo_cliente			INT;
DEFINE cNumCtePrincipal 	CHAR(20);
DEFINE cNumCteTf			CHAR(20);
DEFINE cCodStatusCta           CHAR(2);
DEFINE cTabla CHAR(10);
DEFINE cId_Status_cuenta CHAR(1);
DEFINE cMotivo CHAR(2);
DEFINE dFechaStatus DATE;


LET  iexiste = 0;
LET cCodRet = "00000";
LET iSql_err = 0 ;
--SISTEMA DE CUENTA 01 VARIABLES
LET cIProducto_chequera	 = "";
LET cScuenta		 = "";
LET cNo_cuenta		 = "";
LET cNo_tarjeta			 = "";
LET cClave_producto		 = "";
LET cNombre_producto		 = "";
LET cCuenta_clabe		 = "";
LET dFecha_apertura		 = "";
LET cStatus_tarjeta		 = "";
LET cStatus_cuenta		 = "";
LET dFecha_status		 = "";
LET cClave_sucursal		 = "";
LET cEjecutivo 			 = "";
LET mSaldo_actual		= 0;
LET dFecha_aperturaO_inv = "";
LET dFecha_max			="";
LET dFecha_min			="";
LET cNumero_cuenta 	= "" ;
LET iCont=0;
LET iMaxSec=0;
LET cCtaInv='';
LET cDiaCorte           =0;
LET dFecha_cancelacion = "";
LET iTpo_cliente=0;
LET cNumCteTf = "";
LET cNumCtePrincipal = "";
LET cCodStatusCta = "";
LET cTabla = '';
LET cId_Status_cuenta = '';
LET cMotivo = '';
LET dFechaStatus = '';


BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN
			cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cNo_tarjeta,cClave_producto,cNombre_producto,cCuenta_clabe,dFecha_apertura,
			cStatus_tarjeta,cStatus_cuenta,dFecha_status,cClave_sucursal,cEjecutivo,mSaldo_actual,dFecha_aperturaO_inv,cDiaCorte,dFecha_cancelacion,cCodStatusCta,dFechaStatus;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/home/c90301007/Traza/sp_cnsif_consprodcte_fstatus.out";
	--TRACE ON;
	
	IF 	cID_USUARIOC = '' OR
		cID_FUNCIONC = '' OR
		cNUMCTE  = ''	  OR
		cSISTEMACUENTA = '' THEN
		LET cCodRet = "00036";
		RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
        cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cDiaCorte,dFecha_cancelacion,cCodStatusCta,dFechaStatus;

	END IF;
	IF cSISTEMACUENTA <> '01' THEN
		LET cCodRet = "00037";
		RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
        cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cDiaCorte,dFecha_cancelacion,cCodStatusCta,dFechaStatus;
	END IF;

    IF pNumRegistro<0 THEN
        LET cCodRet='00098';
		RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
        cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cDiaCorte,dFecha_cancelacion,cCodStatusCta,dFechaStatus;				
    ELSE
        IF pRecuperacion<=0 THEN
            LET cCodRet='00098';
            RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cDiaCorte,dFecha_cancelacion,cCodStatusCta,dFechaStatus;
        END IF;
    END IF;
	
	-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
	EXECUTE PROCEDURE "informix".sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC,cNUMCTE,cSISTEMACUENTA,'2')
	INTO cCodRet;
	IF (cCodRet != '00000')  THEN
		RETURN 
		cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cNo_tarjeta,cClave_producto,cNombre_producto,cCuenta_clabe,dFecha_apertura,
		cStatus_tarjeta,cStatus_cuenta,dFecha_status,cClave_sucursal,cEjecutivo,mSaldo_actual,dFecha_aperturaO_inv,cDiaCorte,dFecha_cancelacion,cCodStatusCta,dFechaStatus;
	END IF;	
	
	EXECUTE PROCEDURE bdicnweb:"informix".sp_validacte_transfer(cNUMCTE) INTO cCodRet,iTpo_cliente,cNumCtePrincipal;
	IF cNumCtePrincipal IS NOT NULL THEN
		LET cNUMCTE = cNumCtePrincipal;
	END IF;

	IF cSISTEMACUENTA = '01' THEN
		FOREACH
			SELECT COUNT(cuenta) INTO iexiste FROM bdicheq:"informix".sc_maechq WHERE num_cte = cNUMCTE
			IF iexiste = 0 THEN
				IF iTpo_cliente = 1 THEN
					SELECT COUNT(cuenta_tf) INTO iexiste FROM bditransfer:"informix".tf_maecte WHERE numcte_tf = cNUMCTE;
				ELSE
					SELECT COUNT(cuenta_tf) INTO iexiste FROM bditransfer:"informix".tf_maecte WHERE numcte = cNUMCTE;
				END IF;
			END IF;
		END FOREACH;
		
		IF iexiste = 0 THEN 
			LET cCodRet = "00024";
			RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cDiaCorte,dFecha_cancelacion,cCodStatusCta,dFechaStatus;
		END IF;	

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
		
			SELECT SKIP pNumRegistro FIRST pRecuperacion cuenta AS cuenta INTO cNumero_cuenta
			FROM bdicheq:"informix".sc_maechq
			WHERE num_cte = cNUMCTE 
			UNION
			SELECT cuenta_tf AS cuenta 
			FROM bditransfer:"informix".tf_maecte
			WHERE CASE WHEN iTpo_cliente = 1 THEN numcte_tf ELSE numcte END = cNUMCTE
			ORDER BY cuenta

			SELECT COUNT(cuenta)
			INTO iexiste
			FROM bditransfer:"informix".tf_account_balance_customer
			WHERE cuenta = cNumero_cuenta;
						
			IF iexiste = 0 THEN
				FOREACH
					--RQM 09 704. Se agrega la variable mSaldoSBC para almacenar el dato de la columna saldo_sbc.
					SELECT 'sc_maechq',
					--DECODE(MC.producto,"2200","S","1900","S","N"),
					'N','01',cNumero_cuenta, MC.producto,PR.nombre,
					MC.cuenta_clabe,MC.status_cta,
					--DECODE(MC.status_cta,"1","ACTIVA","2","CANCELADA","3","BLOQUEADA","4","INACTIVA","5","INFORMADA","6","CONCENTRADA","7","BENEFICIENCIA","8","DESCONCENTRADA"),
					MC.fec_cancelac, MC.sucursal,MC.sdo_actual - (MC.sdo_retenido + MC.sdo_cong + MC.imp_sbg_ccc + MC.saldo_sbc)AS SALDO,MC.status_cta
					INTO cTabla,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,cCuenta_clabe,cId_Status_cuenta,
					dFecha_status,cClave_sucursal,mSaldo_actual,cCodStatusCta
					FROM bdicheq:"informix".sc_maechq MC,
					bdicheq:"informix".sc_producto PR
					WHERE MC.cuenta = cNumero_cuenta AND
					PR.producto = MC.producto
					UNION
					SELECT 'tf_maecte',
					"N","01",cNumero_cuenta, MC.producto,PR.nombre,
					MC.cta_clabe,MC.status_cta,
					--DECODE(MC.status_cta,"1","ACTIVA","2","CANCELADA","3","BLOQUEADA","4","INACTIVA","5","INFORMADA","6","CONCENTRADA","7","BENEFICIENCIA","8","DESCONCENTRADA"),
					MC.fec_cancelac,'0000' , 0 AS SALDO,MC.status_cta
					FROM bditransfer:"informix".tf_maecte MC,
					bdicheq:"informix".sc_producto PR
					WHERE MC.cuenta_tf = cNumero_cuenta
					AND PR.producto = MC.producto
					
				END FOREACH;
			ELSE
				FOREACH
					--RQM 09 704. Se agrega la variable mSaldoSBC para almacenar el dato de la columna saldo_sbc.
					SELECT 'sc_maechq',
					--DECODE(MC.producto,"2200","S","1900","S","N"),
					'N','01',cNumero_cuenta, MC.producto,PR.nombre,
					MC.cuenta_clabe,MC.status_cta,
					--DECODE(MC.status_cta,"1","ACTIVA","2","CANCELADA","3","BLOQUEADA","4","INACTIVA","5","INFORMADA","6","CONCENTRADA","7","BENEFICIENCIA","8","DESCONCENTRADA"),
					MC.fec_cancelac, MC.sucursal,MC.sdo_actual - (MC.sdo_retenido + MC.sdo_cong + MC.imp_sbg_ccc + MC.saldo_sbc)AS SALDO,
					MC.status_cta
					INTO cTabla,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,cCuenta_clabe,cId_Status_cuenta,
					dFecha_status,cClave_sucursal,mSaldo_actual,cCodStatusCta
					FROM bdicheq:"informix".sc_maechq MC,
					bdicheq:"informix".sc_producto PR
					WHERE MC.cuenta = cNumero_cuenta AND
					PR.producto = MC.producto
					UNION
					SELECT 'tf_maecte',
					"N","01",cNumero_cuenta, MC.producto,PR.nombre,
					MC.cta_clabe,MC.status_cta,
					--DECODE(MC.status_cta,"1","ACTIVA","2","CANCELADA","3","BLOQUEADA","4","INACTIVA","5","INFORMADA","6","CONCENTRADA","7","BENEFICIENCIA","8","DESCONCENTRADA"),
					MC.fec_cancelac,'0000' ,SDO.sdo_cta AS SALDO,
					MC.status_cta
					FROM bditransfer:"informix".tf_maecte MC,
					bdicheq:"informix".sc_producto PR, bditransfer:"informix".tf_account_balance_customer SDO
					WHERE MC.cuenta_tf = cNumero_cuenta AND
					PR.producto = MC.producto AND
					MC.cuenta_tf = SDO.cuenta
					AND SDO.fecha_proceso = (SELECT MAX(fecha_proceso) FROM bditransfer:"informix".tf_account_balance_customer WHERE cuenta = cNumero_cuenta)
				
				END FOREACH;
			END IF;
			
			-- SE IMPLEMENTA NUEVAS REGLAS DE NEGOCIO PARA OBTENER FECHA STATUS
			
			IF cId_Status_cuenta = '1' THEN
				LET cStatus_cuenta = 'ACTIVA';
			ELIF cId_Status_cuenta = '2' THEN
				LET cStatus_cuenta = 'CANCELADA';
			ELIF cId_Status_cuenta = '3' THEN
				LET cStatus_cuenta = 'BLOQUEADA';
			ELIF cId_Status_cuenta = '4' THEN
				LET cStatus_cuenta = 'INACTIVA';
			ELIF cId_Status_cuenta = '5' THEN
				LET cStatus_cuenta = 'INFORMADA';
			ELIF cId_Status_cuenta = '6' THEN
				LET cStatus_cuenta = 'CONCENTRADA';
			ELIF cId_Status_cuenta = '7' THEN
				LET cStatus_cuenta = 'BENEFICENCIA';
			ELIF cId_Status_cuenta = '8' THEN
				LET cStatus_cuenta = 'DESCONCENTRADA';
			END IF;
			
			IF cTabla = 'sc_maechq' THEN
				IF cClave_producto IN ('2200','1900') THEN
					LET cIProducto_chequera = 'S';
				END IF;
				
				IF cId_Status_cuenta = '2' THEN
					SELECT motivo INTO cMotivo FROM bdicheq:"informix".sc_maechq WHERE cuenta = cNumero_cuenta AND num_cte = cNUMCTE;
					
					IF cMotivo = '14' THEN
						LET cStatus_cuenta = 'BENEFICENCIA';
					END IF;
				END IF;
			END IF;
			
			-- INFORMADA
			IF cId_Status_cuenta = '5' THEN
				FOREACH
					SELECT FIRST 1 a.fecha_marc INTO dFechaStatus
					FROM bdicheq:"informix".sc_ctasinformadas AS a, bdicheq:"informix".sc_maechq AS b
					WHERE a.cuenta = b.cuenta AND a.cuenta = cNumero_cuenta 
					AND b.status_cta = '5' ORDER BY a.fecha_marc DESC
				END FOREACH;
			END IF;
			-- CONCENTRADA
			IF cId_Status_cuenta = '6' THEN
				SELECT a.fecha_concentra INTO dFechaStatus
				FROM bdicheq:"informix".sc_cuentas_concentradas AS a, bdicheq:"informix".sc_maechq AS b
				WHERE a.cuenta = b.cuenta AND a.cuenta = cNumero_cuenta 
				AND b.status_cta = '6';
			END IF;
			-- BENEFICENCIA
			IF cId_Status_cuenta = '2' AND cMotivo = '14' THEN
				SELECT a.fecha_trasp_benefic INTO dFechaStatus
				FROM bdicheq:"informix".sc_cuentas_concentradas AS a, bdicheq:"informix".sc_maechq AS b
				WHERE a.cuenta = b.cuenta AND a.cuenta = cNumero_cuenta 
				AND b.status_cta = '2' AND b.motivo = '14';
			END IF;
			
			-- SE IMPLEMENTA NUEVAS REGLAS DE NEGOCIO PARA OBTENER FECHA STATUS			
			
			FOREACH
				SELECT fecha_alta, ejecutivo
				INTO dFecha_apertura,cEjecutivo
				FROM bdicheq:"informix".sc_maenoc
				WHERE cuenta =cNumero_cuenta
				UNION
				SELECT fec_alta,'TRANSFER'
				FROM bditransfer:"informix".tf_maecte
				WHERE cuenta_tf =cNumero_cuenta
			END FOREACH;

			SELECT numcte_tf, fec_cancelac
			INTO cNumCteTf, dFecha_cancelacion
			FROM bditransfer:"informix".tf_maecte
			WHERE cuenta_tf = cNumero_cuenta;
			
			SELECT num_tarjeta
			INTO cNo_tarjeta
			FROM  bdicheq:"informix".sc_tarjeta
			WHERE cuenta = cNumero_cuenta
			AND numcte = cNUMCTE
			AND tipo_tarjeta='T' AND secuencia IN (SELECT max(secuencia) FROM  bdicheq:"informix".sc_tarjeta
            WHERE cuenta = cNumero_cuenta
			AND numcte = cNUMCTE
			AND tipo_tarjeta='T');
			
            SELECT LIMIT 1 {+INDEX (intercard:"informix".tarjeta idx_numcte)} NVL(UPPER(B.descstatustarjeta),"") INTO cStatus_tarjeta FROM intercard:"informix".tarjeta A
            LEFT JOIN intercard:"informix".statustarjeta B
            ON A.codstatustarjeta = B.codstatustarjeta
            WHERE A.numcliente= cNUMCTE
            AND A.numtarjeta= cNo_tarjeta;

			IF cClave_producto='1100' THEN
				SELECT fec_ult_mov INTO dFecha_status FROM bdicheq:"informix".sc_maechq WHERE cuenta = cNumero_cuenta AND empresa='001' and status_cta='2';
			END IF;

            LET cDiaCorte=SUBSTR(dFecha_apertura,4,2); 

            LET iCont=iCont+1;	
			
			-- Se busca la fecha de cancelacion
	        IF cNumCteTf IS NULL THEN
		        EXECUTE PROCEDURE "informix".sp_consultafechacancelacioncta(cNumero_cuenta, '01') INTO cCodRet, dFecha_cancelacion;
	        END IF;
			
			RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cDiaCorte,dFecha_cancelacion,cCodStatusCta,dFechaStatus WITH resume;
			
			LET cTabla = '';
			LET cId_Status_cuenta = '';
			LET cStatus_cuenta = '';
			LET cMotivo = '';
			LET dFechaStatus = '';
			
		END FOREACH;
		
        IF iCont = 0 THEN
            DELETE {+INDEX (bdinteg:"informix".si_tempoctas idx_tempoctas)} FROM "informix".si_tempoctas WHERE numcte = cNUMCTE AND ejecutivosif= cID_USUARIOC;
            LET cCodRet = '1001'; 
			RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cDiaCorte,dFecha_cancelacion,cCodStatusCta,dFechaStatus;
        END IF 
	
	END IF
END
END PROCEDURE
DOCUMENT
"AUTOR : Antonio Flores",
"FUNCIONAMIENTO:Este sp realizara la busqueda por tipo de cuenta, dependiendo de tipo de cuenta regresara los datos correspondientes, para captacion o cuenta de cheques",
"para cuentas tipo credito 06 que seran de credito y las cuentas tipo 03 que son de  tipo inversiones",
"FECHA : 04-01-2012",
"BD    : bdinteg",
"MODIFICO : Victor Hugo Sanchez",
"MODIFICACION : Se almacenan los datos de las cuentas en tabla de paso y se agrega la paginacion",
"MODIFICO : Oscar Flores Conde",
"MODIFICACION : Se agrega la fecha de cancelacion de la cuenta",
"FECHA : 01-08-2015",
"MODIFICO : Oscar Flores Conde",
"MODIFICACION : Se agrega el codigo de estatus de la cuenta",
"FECHA : 15-01-2019",
"MODIFICO : L. Montserrat Leon Amador",
"MODIFICACION : Se realiza clonacion de spl sp_cnsif_consprodcte correspondiente al cSISTEMACUENTA 01 (Captacion), para agregar nuevo campo Fecha Status.",
"VER   : 1.0",
"------------------------------------------",
"MODIFICO :     Ezequiel Moreno Paredes",
"FECHA :        09-06-2025",
"MODIFICACION : Se modifica la formula de calculo de saldo disponible para considerar un nuevo campo llamado saldo_sbc",
"PROYECTO :     RQM 09 704 Cobranza Automatica en cuentas de captacion",
"VERSION :      1.1.1";

CREATE PROCEDURE  "informix".sp_cnsif_consaldoscap(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCUENTA char(20),cTIPOSALDO CHAR(10),dPERIODO DATE)
       returning 	CHAR(5)     AS Cod_Retorno,
					CHAR(20)    AS Numero_Cuenta,
					MONEY(14,2) AS Saldo_Disponible,
					MONEY(14,2) AS Saldo_Congelado,
					MONEY(14,2) AS Saldo_Retenido,
					MONEY(14,2) AS Saldo_SBC,
					MONEY(14,2) AS Saldo_Comisiones,
					MONEY(14,2) AS Saldo_Actual,
					MONEY(14,2) AS Saldo_Promedio,
					MONEY(14,2) AS Interes,
					MONEY(14,2) AS Tasa;
 

 --Variables
	DEFINE iexiste 					INT;
	DEFINE cCodRet 					CHAR(5);
	DEFINE iSql_err 				INT;
	DEFINE cNumero_cuenta			CHAR(20);
	DEFINE mSaldo_disponible		MONEY(14,2);
	DEFINE mSaldo_congelado			MONEY(14,2);
	DEFINE mSaldo_retenido   		MONEY(14,2);
	DEFINE mSaldo_SBC				MONEY(14,2);
	DEFINE mSaldo_comisiones 		MONEY(14,2);
	DEFINE mSaldo_actual			MONEY(14,2);
	DEFINE mSlado_promedio			MONEY(14,2);
	DEFINE mItenres					MONEY(14,2);
	DEFINE mTasa					MONEY(14,2);
	DEFINE dAnio_actual				DATE;
	DEFINE dAnio_usuario			DATE;
	DEFINE dMes_usuario				DATE;
	DEFINE cTabla 					CHAR(40);
	DEFINE cAniomes					CHAR(6);
    DEFINE cconsmovhis      CHAR(10);
    DEFINE cconsmovhisold   CHAR(10);
    DEFINE cconsmovhisold2  CHAR(10);
    DEFINE cconsmovhisold3  CHAR(10);


	--inicializando variables
	LET iexiste 				= 0;
	LET cCodRet 				= "00000";
	LET iSql_err 				= 0;
	LET cNumero_cuenta			= "";
	LET mSaldo_disponible		= 0;
	LET mSaldo_congelado		= 0;
	LET mSaldo_retenido   		= 0;
	LET mSaldo_SBC				= 0;
	LET mSlado_promedio			= 0;
	LET mItenres				= 0;
	LET mTasa					= 0;
	LET dAnio_actual	 		= "";
	LET dAnio_usuario			= "";
	LET dMes_usuario			= "";
	LET cTabla 					= "";
	LET mSaldo_actual			= 0;
	LET mSaldo_comisiones  		= 0;
	LET cAniomes				= "";
    LET cconsmovhis     = '';
	LET cconsmovhisold  = '';
    LET cconsmovhisold2 = '';
    LET cconsmovhisold3 = '';

	
	BEGIN
		ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET cCodRet = iSql_err;
                RETURN cCodRet,cNumero_cuenta, mSaldo_disponible, mSaldo_congelado, mSaldo_retenido, mSaldo_SBC,mSaldo_comisiones,mSaldo_actual, mSlado_promedio, mItenres, mTasa;
            END IF;
        END EXCEPTION;
		--	SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_consaldoscap.out";
		--	TRACE ON;
		
		IF 		cID_USUARIOC 	='' OR
				cID_FUNCIONC	='' OR
				cNUMCUENTA 		=''	OR				
				cTIPOSALDO 		=''	THEN 
				LET cCodRet = '00036';
			RETURN cCodRet,cNumero_cuenta, mSaldo_disponible, mSaldo_congelado, mSaldo_retenido, mSaldo_SBC,mSaldo_comisiones,mSaldo_actual, mSlado_promedio, mItenres, mTasa;
		END IF;		
		
		IF cTIPOSALDO <> "ALCORTE" AND cTIPOSALDO <> "ACTUAL" THEN 
			LET cCodRet = '00038';
			RETURN cCodRet,cNumero_cuenta, mSaldo_disponible, mSaldo_congelado, mSaldo_retenido, mSaldo_SBC,mSaldo_comisiones,mSaldo_actual, mSlado_promedio, mItenres, mTasa;
		END IF;	
		
		--VALIDACION
		EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'01','1')
		INTO
		cCodRet;
		IF (cCodRet != '00000')  THEN
			RETURN cCodRet,cNumero_cuenta, mSaldo_disponible, mSaldo_congelado, mSaldo_retenido, mSaldo_SBC,mSaldo_comisiones,mSaldo_actual, mSlado_promedio, mItenres, mTasa;
		END IF;
	-- TERMINA VALIDACION		
		
    SELECT valor
      INTO cconsmovhis
      FROM bdicheq:"informix".sc_param
     WHERE empresa = '001'
       AND codparam = 'fechcon_movhis';

    SELECT valor
      INTO cconsmovhisold
      FROM bdicheq:"informix".sc_param
     WHERE empresa = '001'
       AND codparam = 'FechIniCon_movhis_ol';

    SELECT valor
      INTO cconsmovhisold2
      FROM bdicheq:"informix".sc_param
     WHERE empresa = '001'
       AND codparam = 'FechaIniMovhisOld2';
       
    SELECT valor
      INTO cconsmovhisold3
      FROM bdicheq:"informix".sc_param
     WHERE empresa = '001'
       AND codparam = 'vfechconmovhisold3';
		
		FOREACH
		SELECT FIRST 1 NVL(COUNT(cuenta),0) INTO iexiste FROM bdicheq:sc_maechq WHERE cuenta = cNUMCUENTA
		UNION
		SELECT NVL(COUNT(cuenta_tf),0) FROM bditransfer:tf_maecte WHERE cuenta_tf = cNUMCUENTA
		ORDER BY 1 desc
		END FOREACH;
		
		IF iexiste = 0 THEN 
			LET cCodRet = "00009";
			RETURN cCodRet,cNumero_cuenta, mSaldo_disponible, mSaldo_congelado, mSaldo_retenido, mSaldo_SBC,mSaldo_comisiones,mSaldo_actual, mSlado_promedio, mItenres, mTasa;
		END IF;	
		

	IF cTIPOSALDO = "ALCORTE" THEN 		
			IF 	dPERIODO IS NULL THEN
				LET cCodRet = "00036";
				RETURN cCodRet,cNumero_cuenta, mSaldo_disponible, mSaldo_congelado, mSaldo_retenido, mSaldo_SBC,mSaldo_comisiones,mSaldo_actual, mSlado_promedio, mItenres, mTasa;
			END IF;	
			LET dAnio_actual = YEAR(TODAY);
			LET dAnio_usuario = YEAR(dPERIODO);
			LET dMes_usuario = MONTH(dPERIODO);
			LET cAniomes =  SUBSTR(dPERIODO,7,10)||SUBSTR(dPERIODO,1,2);

           IF dAnio_usuario=2012 THEN 
				IF dMes_usuario = 1 THEN 
					SELECT  TA.capvigprom1 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 2 THEN 
					SELECT  TA.capvigprom2 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 3 THEN 
					SELECT  TA.capvigprom3 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 4 THEN 
					SELECT  TA.capvigprom4 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 5 THEN 
					SELECT  TA.capvigprom5 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 6 THEN 
					SELECT  TA.capvigprom6 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 7 THEN 
					SELECT  TA.capvigprom7 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 8 THEN 
					SELECT  TA.capvigprom8 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 9 THEN 
					SELECT  TA.capvigprom9 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 10 THEN 
					SELECT  TA.capvigprom10 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 11 THEN 
					SELECT  TA.capvigprom11 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 12 THEN 
					SELECT  TA.capvigprom12 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				END IF; 
           ELIF dAnio_usuario=2011 THEN 
				IF dMes_usuario = 1 THEN 
					SELECT  TA.capvigprom1 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc_2011 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 2 THEN 
					SELECT  TA.capvigprom2 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc_2011 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 3 THEN 
					SELECT  TA.capvigprom3 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc_2011 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 4 THEN 
					SELECT  TA.capvigprom4 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc_2011 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 5 THEN 
					SELECT  TA.capvigprom5 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc_2011 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 6 THEN 
					SELECT  TA.capvigprom6 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc_2011 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 7 THEN 
					SELECT  TA.capvigprom7 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc_2011 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 8 THEN 
					SELECT  TA.capvigprom8 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc_2011 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 9 THEN 
					SELECT  TA.capvigprom9 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc_2011 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 10 THEN 
					SELECT  TA.capvigprom10 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc_2011 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 11 THEN 
					SELECT  TA.capvigprom11 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc_2011 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 12 THEN 
					SELECT  TA.capvigprom12 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc_2011 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				END IF; 
           ELIF dAnio_usuario=2010 THEN 
				IF dMes_usuario = 1 THEN 
					SELECT  TA.capvigprom1 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2010 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 2 THEN 
					SELECT  TA.capvigprom2 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2010 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 3 THEN 
					SELECT  TA.capvigprom3 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2010 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 4 THEN 
					SELECT  TA.capvigprom4 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2010 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 5 THEN 
					SELECT  TA.capvigprom5 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2010 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 6 THEN 
					SELECT  TA.capvigprom6 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2010 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 7 THEN 
					SELECT  TA.capvigprom7 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2010 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 8 THEN 
					SELECT  TA.capvigprom8 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2010 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 9 THEN 
					SELECT  TA.capvigprom9 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2010 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 10 THEN 
					SELECT  TA.capvigprom10 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2010 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 11 THEN 
					SELECT  TA.capvigprom11 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2010 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 12 THEN 
					SELECT  TA.capvigprom12 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2010 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				END IF; 
           ELIF dAnio_usuario=2009 or dAnio_usuario=2008 THEN 
				IF dMes_usuario = 1 THEN 
					SELECT  TA.capvigprom1 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2009 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 2 THEN 
					SELECT  TA.capvigprom2 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2009 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 3 THEN 
					SELECT  TA.capvigprom3 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2009 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 4 THEN 
					SELECT  TA.capvigprom4 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2009 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 5 THEN 
					SELECT  TA.capvigprom5 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2009 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 6 THEN 
					SELECT  TA.capvigprom6 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2009 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 7 THEN 
					SELECT  TA.capvigprom7 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2009 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 8 THEN 
					SELECT  TA.capvigprom8 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2009 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 9 THEN 
					SELECT  TA.capvigprom9 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2009 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 10 THEN 
					SELECT  TA.capvigprom10 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2009 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 11 THEN 
					SELECT  TA.capvigprom11 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2009 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 12 THEN 
					SELECT  TA.capvigprom12 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2009 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				END IF; 
          END IF;  
          SET ISOLATION TO DIRTY READ;
          FOREACH    
             SELECT LIMIT 1 monto_tot,tasa_aplicada*100 
			 INTO  mItenres,mTasa 
			 FROM bdicheq:sc_movhis
			 WHERE empresa='001' and cuenta  =cNUMCUENTA 
			 AND transacc = '3276'
			 AND aniomes = cAniomes 
             AND fech_alt >= cconsmovhis
             UNION
			 SELECT monto_tot,tasa_aplicada*100 
			 FROM bdicheq:sc_movhis_old
			 WHERE empresa='001' and cuenta  =cNUMCUENTA 
			 AND transacc = '3276'
			 AND aniomes = cAniomes
             AND fech_alt >= cconsmovhisold
             AND fech_alt < cconsmovhis
             UNION
			 SELECT monto_tot,tasa_aplicada*100 
			 FROM bdicheq:sc_movhis_old2
			 WHERE empresa='001' and cuenta  =cNUMCUENTA 
			 AND transacc = '3276'
			 AND aniomes = cAniomes
             AND fech_alt >= cconsmovhisold2
             AND fech_alt < cconsmovhisold
             UNION
			 SELECT monto_tot,tasa_aplicada*100 
			 FROM bdicheq:sc_movhis_old3
			 WHERE empresa='001' and cuenta  =cNUMCUENTA 
			 AND transacc = '3276'
			 AND aniomes = cAniomes
             AND fech_alt >= cconsmovhisold3
             AND fech_alt < cconsmovhisold2
             UNION
			 SELECT monto_tot,tasa_aplicada*100 
			 FROM bdicheq:sc_movhis_old4
			 WHERE empresa='001' and cuenta  =cNUMCUENTA 
			 AND transacc = '3276'
			 AND aniomes = cAniomes
             AND fech_alt < cconsmovhisold3
         END FOREACH;
 	END IF; 
		--RQM 09 704. Se agrega el campo saldo_sbc al calculo del saldo disponible. DHG 
		FOREACH
		SELECT  cuenta, sdo_actual - (sdo_retenido + sdo_cong + imp_sbg_ccc + saldo_sbc) as saldo_disponible,sdo_cong,sdo_retenido,imp_chq_sbc,
				com_pendiente,sdo_actual
		INTO 
		cNumero_cuenta, mSaldo_disponible, mSaldo_congelado, mSaldo_retenido, mSaldo_SBC,mSaldo_comisiones,mSaldo_actual
		FROM
		bdicheq:sc_maechq
		WHERE cuenta   =  cNUMCUENTA AND empresa='001'
		UNION
		SELECT  cuenta, sdo_cta ,0,0,0,0,sdo_cta
		FROM
		bditransfer:tf_account_balance_customer
		WHERE cuenta =  cNUMCUENTA
		AND fecha_proceso = (SELECT MAX(fecha_proceso) FROM bditransfer:tf_account_balance_customer WHERE cuenta = cNUMCUENTA)
		END FOREACH;

	RETURN cCodRet,cNumero_cuenta, mSaldo_disponible, mSaldo_congelado, mSaldo_retenido, mSaldo_SBC,mSaldo_comisiones,mSaldo_actual, mSlado_promedio, mItenres, mTasa;					
	END
END PROCEDURE
DOCUMENT
"AutOR : Antonio Flores",
"FUNCIONAMIENTO:Este sp realizara la busqueda y el calculo de saldos segun la cuenta que se le envie al SP y tambien tomando en cuenta el tipo de saldo",
"ya sea al corte, que hara una busqueda de periodos anteriores, y actual que sera la busqueda de saldos del periodo acutal",
"FECHA : 10-01-2012",
"BD    : bdinteg",
"VER   : 1.0",
'MODIFICO : Daniel Hernandez Garcia',
'FECHA : 29-05-2025',
'MODIFICACION  : Se agrega el valor del campo saldo_sbc en el calculo del saldo disponible',
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdinteg',
'VER   : 1.2';

CREATE PROCEDURE  "informix".sp_cnsif_consaldoscap3(pUsuario char(8),pIdFuncion CHAR(10),
													cNUMCUENTA char(20),cTIPOSALDO CHAR(10),dPERIODO DATE)
       returning 	CHAR(5)     AS Cod_Retorno,
					CHAR(20)    AS Numero_Cuenta,
					MONEY(14,2) AS Saldo_Disponible,
					MONEY(14,2) AS Saldo_Congelado,
					MONEY(14,2) AS Saldo_Retenido,
					MONEY(14,2) AS Saldo_Apartado,
					MONEY(14,2) AS Saldo_SBC,
					MONEY(14,2) AS Saldo_Comisiones,
					MONEY(14,2) AS Saldo_Actual,
					MONEY(14,2) AS Saldo_Promedio,
					MONEY(14,2) AS Interes,
					MONEY(14,2) AS Tasa,
                    MONEY(14,2) AS Sobregiro;

			

 --Variables
	DEFINE iexiste 					INT;
	DEFINE cCodRet 					CHAR(5);
	DEFINE iSql_err 				INT;
	DEFINE cNumero_cuenta			CHAR(20);
	DEFINE mSaldo_disponible		MONEY(14,2);
	DEFINE mSaldo_congelado			MONEY(14,2);
	DEFINE mSaldo_retenido   		MONEY(14,2);
	DEFINE mSaldo_Apartado   		MONEY(14,2);
	DEFINE mSaldo_SBC				MONEY(14,2);
	DEFINE mSaldo_comisiones 		MONEY(14,2);
	DEFINE mSaldo_actual			MONEY(14,2);
	DEFINE mSlado_promedio			MONEY(14,2);
	DEFINE mItenres					MONEY(14,2);
	DEFINE mTasa					MONEY(14,2);
	DEFINE dAnio_actual				DATE;
	DEFINE dAnio_usuario			DATE;
	DEFINE dMes_usuario				DATE;
	DEFINE cTabla 					CHAR(40);
	DEFINE cAniomes					CHAR(6);
    DEFINE cconsmovhis      		CHAR(10);
    DEFINE cconsmovhisold   		CHAR(10);
    DEFINE cconsmovhisold2  		CHAR(10);
    DEFINE cconsmovhisold3  		CHAR(10);
	DEFINE mSobregiro				MONEY(14,2);


	--inicializando variables
	LET iexiste 				= 0;
	LET cCodRet 				= "00000";
	LET iSql_err 				= 0;
	LET cNumero_cuenta			= "";
	LET mSaldo_disponible		= 0;
	LET mSaldo_congelado		= 0;
	LET mSaldo_retenido   		= 0;
	LET mSaldo_Apartado			= 0;
	LET mSaldo_SBC				= 0;
	LET mSlado_promedio			= 0;
	LET mItenres				= 0;
	LET mTasa					= 0;
	LET dAnio_actual	 		= "";
	LET dAnio_usuario			= "";
	LET dMes_usuario			= "";
	LET cTabla 					= "";
	LET mSaldo_actual			= 0;
	LET mSaldo_comisiones  		= 0;
	LET cAniomes				= "";
    LET cconsmovhis     = '';
	LET cconsmovhisold  = '';
    LET cconsmovhisold2 = '';
    LET cconsmovhisold3 = '';
    LET mSobregiro              = 0;

	
	BEGIN
		ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET cCodRet = iSql_err;
                RETURN cCodRet,cNumero_cuenta, mSaldo_disponible, mSaldo_congelado, mSaldo_retenido, mSaldo_Apartado, mSaldo_SBC,mSaldo_comisiones,mSaldo_actual, mSlado_promedio, mItenres, mTasa, mSobregiro;
            END IF;
        END EXCEPTION;
		--SET DEBUG FILE TO "/tmp/mfinis/sp_cnsif_consaldoscap3.out";
		--TRACE ON;
		
		IF 		pUsuario 	='' OR
				pIdFuncion	='' OR
				cNUMCUENTA 		=''	OR				
				cTIPOSALDO 		=''	THEN 
				LET cCodRet = '00036';
			RETURN cCodRet,cNumero_cuenta, mSaldo_disponible, mSaldo_congelado, mSaldo_retenido, mSaldo_Apartado, mSaldo_SBC,mSaldo_comisiones,mSaldo_actual, mSlado_promedio, mItenres, mTasa, mSobregiro;
		END IF;		
		
		IF cTIPOSALDO <> "ALCORTE" AND cTIPOSALDO <> "ACTUAL" THEN 
			LET cCodRet = '00038';
			RETURN cCodRet,cNumero_cuenta, mSaldo_disponible, mSaldo_congelado, mSaldo_retenido, mSaldo_Apartado, mSaldo_SBC,mSaldo_comisiones,mSaldo_actual, mSlado_promedio, mItenres, mTasa, mSobregiro;
		END IF;	
		
		--VALIDACION
		EXECUTE PROCEDURE sp_cnsif_confirmaejecutivo(pUsuario,pIdFuncion)
		INTO
		cCodRet;
		IF (cCodRet != '00000')  THEN
			RETURN cCodRet,cNumero_cuenta, mSaldo_disponible, mSaldo_congelado, mSaldo_retenido, mSaldo_Apartado, mSaldo_SBC,mSaldo_comisiones,mSaldo_actual, mSlado_promedio, mItenres, mTasa, mSobregiro;
		END IF;
	-- TERMINA VALIDACION		
		
    SELECT valor
      INTO cconsmovhis
      FROM bdicheq:"informix".sc_param
     WHERE empresa = '001'
       AND codparam = 'fechcon_movhis';

    SELECT valor
      INTO cconsmovhisold
      FROM bdicheq:"informix".sc_param
     WHERE empresa = '001'
       AND codparam = 'FechIniCon_movhis_ol';

    SELECT valor
      INTO cconsmovhisold2
      FROM bdicheq:"informix".sc_param
     WHERE empresa = '001'
       AND codparam = 'FechaIniMovhisOld2';
       
    SELECT valor
      INTO cconsmovhisold3
      FROM bdicheq:"informix".sc_param
     WHERE empresa = '001'
       AND codparam = 'vfechconmovhisold3';
		
		FOREACH
		SELECT FIRST 1 NVL(COUNT(cuenta),0) INTO iexiste FROM bdicheq:sc_maechq WHERE cuenta = cNUMCUENTA
		UNION
		SELECT NVL(COUNT(cuenta_tf),0) FROM bditransfer:tf_maecte WHERE cuenta_tf = cNUMCUENTA
		ORDER BY 1 DESC
		END FOREACH;
		IF iexiste = 0 THEN 
			LET cCodRet = "00009";
			RETURN cCodRet,cNumero_cuenta, mSaldo_disponible, mSaldo_congelado, mSaldo_retenido, mSaldo_Apartado, mSaldo_SBC,mSaldo_comisiones,mSaldo_actual, mSlado_promedio, mItenres, mTasa, mSobregiro;
		END IF;	
		

	IF cTIPOSALDO = "ALCORTE" THEN 		
			IF 	dPERIODO IS NULL THEN
				LET cCodRet = "00036";
				RETURN cCodRet,cNumero_cuenta, mSaldo_disponible, mSaldo_congelado, mSaldo_retenido, mSaldo_Apartado, mSaldo_SBC,mSaldo_comisiones,mSaldo_actual, mSlado_promedio, mItenres, mTasa, mSobregiro;
			END IF;	
			LET dAnio_actual = YEAR(TODAY);
			LET dAnio_usuario = YEAR(dPERIODO);
			LET dMes_usuario = MONTH(dPERIODO);
			LET cAniomes =  SUBSTR(dPERIODO,7,10)||SUBSTR(dPERIODO,1,2);

           IF dAnio_usuario=2012 THEN 
				IF dMes_usuario = 1 THEN 
					SELECT  TA.capvigprom1 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 2 THEN 
					SELECT  TA.capvigprom2 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 3 THEN 
					SELECT  TA.capvigprom3 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 4 THEN 
					SELECT  TA.capvigprom4 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 5 THEN 
					SELECT  TA.capvigprom5 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 6 THEN 
					SELECT  TA.capvigprom6 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 7 THEN 
					SELECT  TA.capvigprom7 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 8 THEN 
					SELECT  TA.capvigprom8 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 9 THEN 
					SELECT  TA.capvigprom9 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 10 THEN 
					SELECT  TA.capvigprom10 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 11 THEN 
					SELECT  TA.capvigprom11 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 12 THEN 
					SELECT  TA.capvigprom12 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				END IF; 
           ELIF dAnio_usuario=2011 THEN 
				IF dMes_usuario = 1 THEN 
					SELECT  TA.capvigprom1 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc_2011 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 2 THEN 
					SELECT  TA.capvigprom2 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc_2011 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 3 THEN 
					SELECT  TA.capvigprom3 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc_2011 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 4 THEN 
					SELECT  TA.capvigprom4 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc_2011 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 5 THEN 
					SELECT  TA.capvigprom5 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc_2011 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 6 THEN 
					SELECT  TA.capvigprom6 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc_2011 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 7 THEN 
					SELECT  TA.capvigprom7 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc_2011 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 8 THEN 
					SELECT  TA.capvigprom8 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc_2011 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 9 THEN 
					SELECT  TA.capvigprom9 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc_2011 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 10 THEN 
					SELECT  TA.capvigprom10 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc_2011 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 11 THEN 
					SELECT  TA.capvigprom11 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc_2011 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 12 THEN 
					SELECT  TA.capvigprom12 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc_2011 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				END IF; 
           ELIF dAnio_usuario=2010 THEN 
				IF dMes_usuario = 1 THEN 
					SELECT  TA.capvigprom1 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2010 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 2 THEN 
					SELECT  TA.capvigprom2 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2010 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 3 THEN 
					SELECT  TA.capvigprom3 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2010 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 4 THEN 
					SELECT  TA.capvigprom4 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2010 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 5 THEN 
					SELECT  TA.capvigprom5 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2010 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 6 THEN 
					SELECT  TA.capvigprom6 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2010 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 7 THEN 
					SELECT  TA.capvigprom7 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2010 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 8 THEN 
					SELECT  TA.capvigprom8 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2010 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 9 THEN 
					SELECT  TA.capvigprom9 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2010 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 10 THEN 
					SELECT  TA.capvigprom10 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2010 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 11 THEN 
					SELECT  TA.capvigprom11 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2010 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 12 THEN 
					SELECT  TA.capvigprom12 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2010 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				END IF; 
           ELIF dAnio_usuario=2009 or dAnio_usuario=2008 THEN 
				IF dMes_usuario = 1 THEN 
					SELECT  TA.capvigprom1 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2009 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 2 THEN 
					SELECT  TA.capvigprom2 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2009 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 3 THEN 
					SELECT  TA.capvigprom3 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2009 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 4 THEN 
					SELECT  TA.capvigprom4 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2009 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 5 THEN 
					SELECT  TA.capvigprom5 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2009 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 6 THEN 
					SELECT  TA.capvigprom6 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2009 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 7 THEN 
					SELECT  TA.capvigprom7 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2009 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 8 THEN 
					SELECT  TA.capvigprom8 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2009 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 9 THEN 
					SELECT  TA.capvigprom9 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2009 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 10 THEN 
					SELECT  TA.capvigprom10 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2009 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 11 THEN 
					SELECT  TA.capvigprom11 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2009 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 12 THEN 
					SELECT  TA.capvigprom12 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2009 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				END IF; 
          END IF;  
          SET ISOLATION TO DIRTY READ;
          FOREACH    
             SELECT LIMIT 1 monto_tot,tasa_aplicada*100 
			 INTO  mItenres,mTasa 
			 FROM bdicheq:sc_movhis
			 WHERE empresa='001' and cuenta  =cNUMCUENTA 
			 AND transacc = '3276'
			 AND aniomes = cAniomes 
             AND fech_alt >= cconsmovhis
             UNION
			 SELECT monto_tot,tasa_aplicada*100 
			 FROM bdicheq:sc_movhis_old
			 WHERE empresa='001' and cuenta  =cNUMCUENTA 
			 AND transacc = '3276'
			 AND aniomes = cAniomes
             AND fech_alt >= cconsmovhisold
             AND fech_alt < cconsmovhis
             UNION
			 SELECT monto_tot,tasa_aplicada*100 
			 FROM bdicheq:sc_movhis_old2
			 WHERE empresa='001' and cuenta  =cNUMCUENTA 
			 AND transacc = '3276'
			 AND aniomes = cAniomes
             AND fech_alt >= cconsmovhisold2
             AND fech_alt < cconsmovhisold
             UNION
			 SELECT monto_tot,tasa_aplicada*100 
			 FROM bdicheq:sc_movhis_old3
			 WHERE empresa='001' and cuenta  =cNUMCUENTA 
			 AND transacc = '3276'
			 AND aniomes = cAniomes
             AND fech_alt >= cconsmovhisold3
             AND fech_alt < cconsmovhisold2
             UNION
			 SELECT monto_tot,tasa_aplicada*100 
			 FROM bdicheq:sc_movhis_old4
			 WHERE empresa='001' and cuenta  =cNUMCUENTA 
			 AND transacc = '3276'
			 AND aniomes = cAniomes
             AND fech_alt < cconsmovhisold3
         END FOREACH;
 	END IF; 
		LET cCodRet='00017'; -- No se devuelven registros
		FOREACH
			--RQM 09 704. Se agrega el campo saldo_sbc al calculo del saldo disponible. DHG 
			SELECT  '00000' as CodRet,cuenta, sdo_actual - (sdo_retenido + sdo_cong + imp_sbg_ccc + saldo_sbc) as saldo_disponible,sdo_cong, sdo_retenido - (saldo_ahorro) as sdo_retenido, imp_chq_sbc,
					com_pendiente, sdo_actual ,(imp_sbg_ccc + imp_chq_sbg) as sobregiro, nvl(saldo_ahorro,0) AS saldo_apartado
			INTO cCodRet,cNumero_cuenta, mSaldo_disponible, mSaldo_congelado, mSaldo_retenido, mSaldo_SBC,mSaldo_comisiones,mSaldo_actual,mSobregiro, mSaldo_Apartado
			FROM
			bdicheq:sc_maechq
			left join 
			(
				select sum(saldo_ahorro) saldo_ahorro,cuenta_eje
				from
				(
					select 
						sum(case when mv.tipo_movimiento=2 then monto*-1 else monto end) saldo_ahorro,mv.cuenta_eje
					from bdicheq:"informix".sc_mov_sd mv
					inner join bdicheq:"informix".sc_mae_sd sd on sd.cuenta_eje=mv.cuenta_eje and sd.cuenta_sd=mv.cuenta_sobre
					where TRIM(mv.cuenta_eje)=cNUMCUENTA --and mv.fecha_operacion>=sd.fecha_creacion and mv.fecha_operacion<=sd.fecha_meta 
					and sd.estatus IN (1, 3) --Filtro para retornar apartados activos y finalizados
					group by mv.cuenta_eje,mv.cuenta_sobre
				)
				group by cuenta_eje
			)ahorra on cuenta=ahorra.cuenta_eje
			WHERE cuenta   =  cNUMCUENTA AND empresa='001'
			UNION
			SELECT  '00000' as CodRet,cuenta, sdo_cta,0,0,0,
					0,sdo_cta,0,0
			FROM
			bditransfer:tf_account_balance_customer
			WHERE cuenta =  cNUMCUENTA
			AND fecha_proceso = (SELECT MAX(fecha_proceso) FROM bditransfer:tf_account_balance_customer WHERE cuenta = cNUMCUENTA)
			

		END FOREACH;
	IF (cCodRet != '00000')  THEN
		LET cCodRet='00017'; -- No se devuelven registros
	END IF;
	RETURN cCodRet,cNumero_cuenta, mSaldo_disponible, mSaldo_congelado, mSaldo_retenido, mSaldo_Apartado, mSaldo_SBC,mSaldo_comisiones,mSaldo_actual, mSlado_promedio, mItenres, mTasa, mSobregiro;					
	END
END PROCEDURE
DOCUMENT
"AutOR : Antonio Flores",
"FUNCIONAMIENTO:Este sp realizara la busqueda y el calculo de saldos segun la cuenta que se le envie al SP y tambien tomando en cuenta el tipo de saldo",
"ya sea al corte, que hara una busqueda de periodos anteriores, y actual que sera la busqueda de saldos del periodo acutal",
"FECHA : 10-01-2012",
"BD    : bdinteg",
"Modifico : Eder Solis Lopez",
"MODIFICACION : Se resta saldo retenido de cuentas de Ahorro+",
"FECHA : 07-11-2022",
"VER   : 1.1",
"Modifico : JosÃ© Antonio RamÃ­rez Franco",
"MODIFICACION : Se separaro del saldo retenido el saldo apartado (Lo que antes era Ahorro+) y se le suma al saldo actual.",
"FECHA : 11-07-2023",
"VER   : 1.2",
"Modifico :Karlos GÃ³mez DÃ­az",
"MODIFICACION : Se retiro los apartados de la sumatoria de saldo_disponible, al saldo retenido se le restÃ³ los apartados y se filtrÃ³ la sumatoria de apartados para estatus 1 y 3",
"FECHA : 07-09-2023",
"VER   : 1.3",
"Modifico :Karlos GÃ³mez DÃ­az",
"MODIFICACION : Se se comenta linea en 322 filtro de fechas a solicitud de: Ajuste de Consulta de Saldos Retenidos",
"FECHA : 29-12-2023",
"VER   : 1.4",
'MODIFICO : Daniel Hernandez Garcia',
'FECHA : 29-05-2025',
'MODIFICACION  : Se agrega el valor del campo saldo_sbc en el calculo del saldo disponible',
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdinteg',
'VER   : 1.6';

CREATE PROCEDURE  "informix".sp_cnsif_consaldoscap2(pUsuario char(8),pIdFuncion CHAR(10),cNUMCUENTA char(20),cTIPOSALDO CHAR(10),dPERIODO DATE)
       returning 	CHAR(5)     AS Cod_Retorno,
					CHAR(20)    AS Numero_Cuenta,
					MONEY(14,2) AS Saldo_Disponible,
					MONEY(14,2) AS Saldo_Congelado,
					MONEY(14,2) AS Saldo_Retenido,
					MONEY(14,2) AS Saldo_SBC,
					MONEY(14,2) AS Saldo_Comisiones,
					MONEY(14,2) AS Saldo_Actual,
					MONEY(14,2) AS Saldo_Promedio,
					MONEY(14,2) AS Interes,
					MONEY(14,2) AS Tasa,
                    MONEY(14,2) AS Sobregiro;

 --Variables
	DEFINE iexiste 					INT;
	DEFINE cCodRet 					CHAR(5);
	DEFINE iSql_err 				INT;
	DEFINE cNumero_cuenta			CHAR(20);
	DEFINE mSaldo_disponible		MONEY(14,2);
	DEFINE mSaldo_congelado			MONEY(14,2);
	DEFINE mSaldo_retenido   		MONEY(14,2);
	DEFINE mSaldo_SBC				MONEY(14,2);
	DEFINE mSaldo_comisiones 		MONEY(14,2);
	DEFINE mSaldo_actual			MONEY(14,2);
	DEFINE mSlado_promedio			MONEY(14,2);
	DEFINE mItenres					MONEY(14,2);
	DEFINE mTasa					MONEY(14,2);
	DEFINE dAnio_actual				DATE;
	DEFINE dAnio_usuario			DATE;
	DEFINE dMes_usuario				DATE;
	DEFINE cTabla 					CHAR(40);
	DEFINE cAniomes					CHAR(6);
    DEFINE cconsmovhis      CHAR(10);
    DEFINE cconsmovhisold   CHAR(10);
    DEFINE cconsmovhisold2  CHAR(10);
    DEFINE cconsmovhisold3  CHAR(10);
	DEFINE mSobregiro				MONEY(14,2);


	--inicializando variables
	LET iexiste 				= 0;
	LET cCodRet 				= "00000";
	LET iSql_err 				= 0;
	LET cNumero_cuenta			= "";
	LET mSaldo_disponible		= 0;
	LET mSaldo_congelado		= 0;
	LET mSaldo_retenido   		= 0;
	LET mSaldo_SBC				= 0;
	LET mSlado_promedio			= 0;
	LET mItenres				= 0;
	LET mTasa					= 0;
	LET dAnio_actual	 		= "";
	LET dAnio_usuario			= "";
	LET dMes_usuario			= "";
	LET cTabla 					= "";
	LET mSaldo_actual			= 0;
	LET mSaldo_comisiones  		= 0;
	LET cAniomes				= "";
    LET cconsmovhis     = '';
	LET cconsmovhisold  = '';
    LET cconsmovhisold2 = '';
    LET cconsmovhisold3 = '';
    LET mSobregiro              = 0;

	
	BEGIN
		ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET cCodRet = iSql_err;
                RETURN cCodRet,cNumero_cuenta, mSaldo_disponible, mSaldo_congelado, mSaldo_retenido, mSaldo_SBC,mSaldo_comisiones,mSaldo_actual, mSlado_promedio, mItenres, mTasa, mSobregiro;
            END IF;
        END EXCEPTION;
		--	SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_consaldoscap.out";
		--	TRACE ON;
		
		IF 		pUsuario 	='' OR
				pIdFuncion	='' OR
				cNUMCUENTA 		=''	OR				
				cTIPOSALDO 		=''	THEN 
				LET cCodRet = '00036';
			RETURN cCodRet,cNumero_cuenta, mSaldo_disponible, mSaldo_congelado, mSaldo_retenido, mSaldo_SBC,mSaldo_comisiones,mSaldo_actual, mSlado_promedio, mItenres, mTasa, mSobregiro;
		END IF;		
		
		IF cTIPOSALDO <> "ALCORTE" AND cTIPOSALDO <> "ACTUAL" THEN 
			LET cCodRet = '00038';
			RETURN cCodRet,cNumero_cuenta, mSaldo_disponible, mSaldo_congelado, mSaldo_retenido, mSaldo_SBC,mSaldo_comisiones,mSaldo_actual, mSlado_promedio, mItenres, mTasa, mSobregiro;
		END IF;	
		
		--VALIDACION
		EXECUTE PROCEDURE sp_cnsif_confirmaejecutivo(pUsuario,pIdFuncion)
		INTO
		cCodRet;
		IF (cCodRet != '00000')  THEN
			RETURN cCodRet,cNumero_cuenta, mSaldo_disponible, mSaldo_congelado, mSaldo_retenido, mSaldo_SBC,mSaldo_comisiones,mSaldo_actual, mSlado_promedio, mItenres, mTasa, mSobregiro;
		END IF;
	-- TERMINA VALIDACION		
		
    SELECT valor
      INTO cconsmovhis
      FROM bdicheq:"informix".sc_param
     WHERE empresa = '001'
       AND codparam = 'fechcon_movhis';

    SELECT valor
      INTO cconsmovhisold
      FROM bdicheq:"informix".sc_param
     WHERE empresa = '001'
       AND codparam = 'FechIniCon_movhis_ol';

    SELECT valor
      INTO cconsmovhisold2
      FROM bdicheq:"informix".sc_param
     WHERE empresa = '001'
       AND codparam = 'FechaIniMovhisOld2';
       
    SELECT valor
      INTO cconsmovhisold3
      FROM bdicheq:"informix".sc_param
     WHERE empresa = '001'
       AND codparam = 'vfechconmovhisold3';
		
		FOREACH
		SELECT FIRST 1 NVL(COUNT(cuenta),0) INTO iexiste FROM bdicheq:sc_maechq WHERE cuenta = cNUMCUENTA
		UNION
		SELECT NVL(COUNT(cuenta_tf),0) FROM bditransfer:tf_maecte WHERE cuenta_tf = cNUMCUENTA
		ORDER BY 1 DESC
		END FOREACH;
		IF iexiste = 0 THEN 
			LET cCodRet = "00009";
			RETURN cCodRet,cNumero_cuenta, mSaldo_disponible, mSaldo_congelado, mSaldo_retenido, mSaldo_SBC,mSaldo_comisiones,mSaldo_actual, mSlado_promedio, mItenres, mTasa, mSobregiro;
		END IF;	
		

	IF cTIPOSALDO = "ALCORTE" THEN 		
			IF 	dPERIODO IS NULL THEN
				LET cCodRet = "00036";
				RETURN cCodRet,cNumero_cuenta, mSaldo_disponible, mSaldo_congelado, mSaldo_retenido, mSaldo_SBC,mSaldo_comisiones,mSaldo_actual, mSlado_promedio, mItenres, mTasa, mSobregiro;
			END IF;	
			LET dAnio_actual = YEAR(TODAY);
			LET dAnio_usuario = YEAR(dPERIODO);
			LET dMes_usuario = MONTH(dPERIODO);
			LET cAniomes =  SUBSTR(dPERIODO,7,10)||SUBSTR(dPERIODO,1,2);

           IF dAnio_usuario=2012 THEN 
				IF dMes_usuario = 1 THEN 
					SELECT  TA.capvigprom1 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 2 THEN 
					SELECT  TA.capvigprom2 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 3 THEN 
					SELECT  TA.capvigprom3 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 4 THEN 
					SELECT  TA.capvigprom4 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 5 THEN 
					SELECT  TA.capvigprom5 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 6 THEN 
					SELECT  TA.capvigprom6 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 7 THEN 
					SELECT  TA.capvigprom7 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 8 THEN 
					SELECT  TA.capvigprom8 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 9 THEN 
					SELECT  TA.capvigprom9 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 10 THEN 
					SELECT  TA.capvigprom10 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 11 THEN 
					SELECT  TA.capvigprom11 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 12 THEN 
					SELECT  TA.capvigprom12 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				END IF; 
           ELIF dAnio_usuario=2011 THEN 
				IF dMes_usuario = 1 THEN 
					SELECT  TA.capvigprom1 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc_2011 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 2 THEN 
					SELECT  TA.capvigprom2 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc_2011 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 3 THEN 
					SELECT  TA.capvigprom3 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc_2011 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 4 THEN 
					SELECT  TA.capvigprom4 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc_2011 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 5 THEN 
					SELECT  TA.capvigprom5 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc_2011 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 6 THEN 
					SELECT  TA.capvigprom6 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc_2011 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 7 THEN 
					SELECT  TA.capvigprom7 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc_2011 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 8 THEN 
					SELECT  TA.capvigprom8 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc_2011 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 9 THEN 
					SELECT  TA.capvigprom9 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc_2011 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 10 THEN 
					SELECT  TA.capvigprom10 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc_2011 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 11 THEN 
					SELECT  TA.capvigprom11 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc_2011 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 12 THEN 
					SELECT  TA.capvigprom12 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc_2011 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				END IF; 
           ELIF dAnio_usuario=2010 THEN 
				IF dMes_usuario = 1 THEN 
					SELECT  TA.capvigprom1 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2010 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 2 THEN 
					SELECT  TA.capvigprom2 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2010 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 3 THEN 
					SELECT  TA.capvigprom3 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2010 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 4 THEN 
					SELECT  TA.capvigprom4 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2010 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 5 THEN 
					SELECT  TA.capvigprom5 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2010 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 6 THEN 
					SELECT  TA.capvigprom6 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2010 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 7 THEN 
					SELECT  TA.capvigprom7 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2010 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 8 THEN 
					SELECT  TA.capvigprom8 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2010 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 9 THEN 
					SELECT  TA.capvigprom9 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2010 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 10 THEN 
					SELECT  TA.capvigprom10 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2010 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 11 THEN 
					SELECT  TA.capvigprom11 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2010 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 12 THEN 
					SELECT  TA.capvigprom12 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2010 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				END IF; 
           ELIF dAnio_usuario=2009 or dAnio_usuario=2008 THEN 
				IF dMes_usuario = 1 THEN 
					SELECT  TA.capvigprom1 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2009 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 2 THEN 
					SELECT  TA.capvigprom2 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2009 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 3 THEN 
					SELECT  TA.capvigprom3 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2009 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 4 THEN 
					SELECT  TA.capvigprom4 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2009 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 5 THEN 
					SELECT  TA.capvigprom5 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2009 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 6 THEN 
					SELECT  TA.capvigprom6 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2009 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 7 THEN 
					SELECT  TA.capvigprom7 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2009 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 8 THEN 
					SELECT  TA.capvigprom8 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2009 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 9 THEN 
					SELECT  TA.capvigprom9 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2009 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 10 THEN 
					SELECT  TA.capvigprom10 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2009 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 11 THEN 
					SELECT  TA.capvigprom11 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2009 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				ELIF dMes_usuario = 12 THEN 
					SELECT  TA.capvigprom12 INTO mSlado_promedio FROM bdicheq:sc_sdomensualc2009 TA WHERE TA.cuenta = cNUMCUENTA AND TA.anio=dAnio_usuario;
				END IF; 
          END IF;  
          SET ISOLATION TO DIRTY READ;
          FOREACH    
             SELECT LIMIT 1 monto_tot,tasa_aplicada*100 
			 INTO  mItenres,mTasa 
			 FROM bdicheq:sc_movhis
			 WHERE empresa='001' and cuenta  =cNUMCUENTA 
			 AND transacc = '3276'
			 AND aniomes = cAniomes 
             AND fech_alt >= cconsmovhis
             UNION
			 SELECT monto_tot,tasa_aplicada*100 
			 FROM bdicheq:sc_movhis_old
			 WHERE empresa='001' and cuenta  =cNUMCUENTA 
			 AND transacc = '3276'
			 AND aniomes = cAniomes
             AND fech_alt >= cconsmovhisold
             AND fech_alt < cconsmovhis
             UNION
			 SELECT monto_tot,tasa_aplicada*100 
			 FROM bdicheq:sc_movhis_old2
			 WHERE empresa='001' and cuenta  =cNUMCUENTA 
			 AND transacc = '3276'
			 AND aniomes = cAniomes
             AND fech_alt >= cconsmovhisold2
             AND fech_alt < cconsmovhisold
             UNION
			 SELECT monto_tot,tasa_aplicada*100 
			 FROM bdicheq:sc_movhis_old3
			 WHERE empresa='001' and cuenta  =cNUMCUENTA 
			 AND transacc = '3276'
			 AND aniomes = cAniomes
             AND fech_alt >= cconsmovhisold3
             AND fech_alt < cconsmovhisold2
             UNION
			 SELECT monto_tot,tasa_aplicada*100 
			 FROM bdicheq:sc_movhis_old4
			 WHERE empresa='001' and cuenta  =cNUMCUENTA 
			 AND transacc = '3276'
			 AND aniomes = cAniomes
             AND fech_alt < cconsmovhisold3
         END FOREACH;
 	END IF; 
		LET cCodRet='00017'; -- No se devuelven registros
		FOREACH

			--RQM 09 704. Se agrega el campo saldo_sbc al calculo del saldo disponible. DHG 
			SELECT  '00000' as CodRet,cuenta, sdo_actual - (sdo_retenido + sdo_cong + imp_sbg_ccc + saldo_sbc + nvl(saldo_ahorro,0)) as saldo_disponible,sdo_cong,(sdo_retenido+nvl(saldo_ahorro,0)) as sdo_retenido,imp_chq_sbc,
					com_pendiente,sdo_actual,(imp_sbg_ccc + imp_chq_sbg) as sobregiro
			INTO cCodRet,cNumero_cuenta, mSaldo_disponible, mSaldo_congelado, mSaldo_retenido, mSaldo_SBC,mSaldo_comisiones,mSaldo_actual,mSobregiro
			FROM
			bdicheq:sc_maechq
			left join 
			(
				select sum(saldo_ahorro) saldo_ahorro,cuenta_eje
				from
				(
					select 
						sum(case when mv.tipo_movimiento=2 then monto*-1 else monto end) saldo_ahorro,mv.cuenta_eje
					from bdicheq:"informix".sc_mov_sd mv
					inner join bdicheq:"informix".sc_mae_sd sd on sd.cuenta_eje=mv.cuenta_eje and sd.cuenta_sd=mv.cuenta_sobre
					where TRIM(mv.cuenta_eje)=cNUMCUENTA and mv.fecha_operacion>=sd.fecha_creacion and mv.fecha_operacion<=sd.fecha_meta
					group by mv.cuenta_eje,mv.cuenta_sobre
				)
				group by cuenta_eje
			)ahorra on cuenta=ahorra.cuenta_eje
			WHERE cuenta   =  cNUMCUENTA AND empresa='001'
			UNION
			SELECT  '00000' as CodRet,cuenta, sdo_cta,0,0,0,
					0,sdo_cta,0
			FROM
			bditransfer:tf_account_balance_customer
			WHERE cuenta =  cNUMCUENTA
			AND fecha_proceso = (SELECT MAX(fecha_proceso) FROM bditransfer:tf_account_balance_customer WHERE cuenta = cNUMCUENTA)
			
		END FOREACH;
	IF (cCodRet != '00000')  THEN
		LET cCodRet='00017'; -- No se devuelven registros
	END IF;
	RETURN cCodRet,cNumero_cuenta, mSaldo_disponible, mSaldo_congelado, mSaldo_retenido, mSaldo_SBC,mSaldo_comisiones,mSaldo_actual, mSlado_promedio, mItenres, mTasa, mSobregiro;					
	END
END PROCEDURE
DOCUMENT
"AutOR : Antonio Flores",
"FUNCIONAMIENTO:Este sp realizara la busqueda y el calculo de saldos segun la cuenta que se le envie al SP y tambien tomando en cuenta el tipo de saldo",
"ya sea al corte, que hara una busqueda de periodos anteriores, y actual que sera la busqueda de saldos del periodo acutal",
"FECHA : 10-01-2012",
"BD    : bdinteg",
"Modifico : Eder Solis Lopez",
"MODIFICACION : Se resta saldo retenido de cuentas de Ahorro+",
"FECHA : 07-11-2022",
"VER   : 1.1",
'MODIFICO : Daniel Hernandez Garcia',
'FECHA : 29-05-2025',
'MODIFICACION  : Se agrega el valor del campo saldo_sbc en el calculo del saldo disponible',
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdinteg',
'VER   : 1.2';

CREATE PROCEDURE "informix".sp_consulta_datos_cte_coppel(cNumCteCoppel CHAR(9))
RETURNING  CHAR(6) As Retorno,
           INTEGER As Ingreso_mensual,
		   INTEGER As Opcion_puesto,
		   INTEGER As Sub_opcion_puesto,		   
		   CHAR (10) As  Tiempo_edo_civil,
		   CHAR (10) As  Tiempo_recide,
		   CHAR (2) As  Tipo_referencia;

DEFINE iSqlErr  	INTEGER;

DEFINE cCodRet CHAR(6);
DEFINE iIngresoMensual INTEGER;
DEFINE iOpcionPuesto INTEGER;
DEFINE iSubOpcionPuesto INTEGER;
DEFINE cTiempoEdoCivil CHAR(10);
DEFINE cTiempoRecide CHAR(10);
DEFINE cTipoRef CHAR(2);

DEFINE cNumSol CHAR(20);
DEFINE sElemento SMALLINT;
DEFINE cFechaEntrada CHAR(20);
DEFINE cEdoCivil CHAR(1);
DEFINE cEdoCiv 	CHAR(2);
DEFINE cResidencia		CHAR(2);
DEFINE dtFechSol		DATE;
DEFINE cNumCte CHAR(9);
DEFINE dMaxIng SMALLINT;


LET cCodRet = '00000';
LET iIngresoMensual = -1;
LET iOpcionPuesto = -1;
LET iSubOpcionPuesto =-1;
LET cTiempoEdoCivil = '';
LET cTiempoRecide = '';
LET cTipoRef = 'X';

LET cNumSol = '';
LET sElemento = 0;
LET cFechaEntrada = '';
LET cEdoCivil = '';
LET cEdoCiv = '';
LET cResidencia = '';
LET dtFechSol = DATE(1);

LET iSqlErr	= 0;
LET cNumCte	= '';
LET dMaxIng=0;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodret = iSqlErr;
			RETURN cCodret,iIngresoMensual,iOpcionPuesto,iSubOpcionPuesto,cTiempoEdoCivil,cTiempoRecide,cTipoRef;
		END IF;
	END EXCEPTION;

	 
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	--SET DEBUG FILE TO "/informix/Omujica/sp_consulta_datos_cte_coppel.out";
	--TRACE ON;
        
        --Obtenemos el cliente Bancoppel
                /*SELECT numcte
                INTO cNumCte
                FROM "informix".si_adiccoppel 		
                where numctecoppel = cNumCteCoppel and secuencia = 1;*/
        SELECT numcte_banco 
          INTO cNumCte 
        FROM si_relacion_ctebcplcpl 
        WHERE cliente = cNumCteCoppel;




        IF cNumCte != '' THEN
        
		/*SELECT num_solicitud,parentesco
		INTO cNumSol,cTipoRef
		FROM "informix".si_refclientes 		
		where numcte = cNumCte AND secuencia = (SELECT MIN(secuencia) FROM "informix".si_refclientes where numcte = cNumCte 
		AND fecha_insert = (SELECT MAX(fecha_insert) FROM "informix".si_refclientes where numcte = cNumCte ));*/

        SELECT LIMIT 1 num_solicitud,parentesco 
        INTO cNumSol,cTipoRef
        --INTO iOpcionPuesto,iSubOpcionPuesto
        FROM si_refclientes  WHERE numcte=cNumCte; 
	
		
		--OBTIENE LOS DATOS claveopcionpuesto, clavesubopcionpuesto DE LA TABLA si_ingresos
		/*SELECT claveopcionpuesto, clavesubopcionpuesto
		INTO iOpcionPuesto,iSubOpcionPuesto
		FROM "informix".si_ingresos
		WHERE numcte = cNumCte
		AND sec_ingreso = (SELECT MAX(sec_ingreso) FROM "informix".si_ingresos WHERE numcte = cNumCte AND tipo_ingreso = 'T');*/

        SELECT MAX(sec_ingreso) 
        INTO dMaxIng
        FROM "informix".si_ingresos 
        WHERE numcte = cNumCte AND tipo_ingreso = 'T';
        
        SELECT claveopcionpuesto, clavesubopcionpuesto 
        INTO iOpcionPuesto,iSubOpcionPuesto 
        FROM  si_ingresos
        WHERE numcte = cNumCte AND sec_ingreso =dMaxIng;
		

		IF TRIM(NVL(cNumSol,'')) != '' THEN
		
				SELECT ingreso_mensual
				INTO iIngresoMensual
				FROM bdisolic:"informix".ss_resum_scor_fin
				where num_solicitud = cNumSol;	
				
				SELECT estado_civil
				INTO cEdoCivil
				FROM "informix".si_ctepf 
				WHERE numcte = cNumCte;
				
			IF (cEdoCivil <> "S") THEN
						--TiempoDeEstadoCivil(Anios)
					SELECT SUBSTR(descripcion,1,2)
					INTO cEdoCiv
					FROM bdisolic:"informix".ss_scoring_element
					WHERE grupo = 4 and elemento = (SELECT elemento FROM bdisolic:"informix".ss_detalle_scoring WHERE grupo = 4 AND num_solicitud = cNumSol);
		
					IF (TRIM(cEdoCiv) <> "0") THEN
						IF cEdoCiv = "No" THEN
							LET cTiempoEdoCivil = "1900-01-02";
						ELSE
							SELECT fecha_insert
							INTO dtFechSol
							FROM bdisolic:"informix".ss_solicitudes
							WHERE numcte = cNumCte AND num_solicitud = cNumSol;
		
							LET cTiempoEdoCivil = TO_CHAR(bdicred:"informix".monthadd(dtFechSol,cEdoCiv::integer * -12),'%Y-%m-%d');
						END IF;
					ELSE
						--TiempoDeEstadoCivil(MESES)
						SELECT SUBSTR(descripcion,1,2)
						INTO cEdoCiv
						FROM bdisolic:"informix".ss_scoring_element
						WHERE grupo = 41 AND elemento = (SELECT elemento FROM bdisolic:"informix".ss_detalle_scoring WHERE grupo = 41 AND num_solicitud = cNumSol);
		
						IF (cEdoCiv <> "0") THEN
							SELECT fecha_insert
							INTO dtFechSol
							FROM bdisolic:"informix".ss_solicitudes
							WHERE numcte = cNumCte AND num_solicitud = cNumSol;
							LET cTiempoEdoCivil = TO_CHAR(bdicred:"informix".monthadd(dtFechSol,cEdoCiv::integer * -1),'%Y-%m-%d');
						END IF;
					END IF;
			ELSE 		
				LET cTiempoEdoCivil = "1900-01-02";
			END IF;
			IF NVL(cTiempoEdoCivil, '') = '' THEN
				LET cTiempoEdoCivil = "1900-01-02";
			END IF;
				--Obtiene parametros para el Tiempo de Residencia
				SELECT SUBSTR(descripcion,1,2)
				INTO cResidencia
				FROM bdisolic:"informix".ss_scoring_element
				WHERE grupo = 6 AND elemento = (SELECT elemento FROM bdisolic:"informix".ss_detalle_scoring WHERE grupo = 6 AND num_solicitud = cNumSol);
		
				--RTV
				SELECT fecha_insert
					INTO dtFechSol
				FROM bdisolic:"informix".ss_solicitudes
				WHERE numcte = cNumCte AND num_solicitud = cNumSol;
				
				LET cTiempoRecide = dtFechSol - cResidencia::INTEGER units YEAR;
				
			IF NVL(cTiempoRecide, '') = '' THEN
				LET cTiempoRecide = "1900-01-02";
			END IF;
		ELSE
				LET cCodret = '00002';
				LET iOpcionPuesto = 0;
				LET iSubOpcionPuesto =0;
				LET cTipoRef = 'X'; 
				
		END IF;
	ELSE 
				LET cCodret = '00001';				
	END IF;
    --END IF;
	
	RETURN cCodret,iIngresoMensual,iOpcionPuesto,iSubOpcionPuesto,cTiempoEdoCivil,cTiempoRecide,cTipoRef;	
END;
END PROCEDURE
DOCUMENT
'Realiza: se crea procedimiento que consultara los datos que solicita coppel, wsConsultaDatosClientes-1 ',
'AUTOR : Luis Trapero Soto',
'FECHA : 10/OCTUBRE/2022',
'BD    : BDINTEG';

CREATE PROCEDURE "informix".ctefisico(
	pEmpresa			CHAR(3),
	pFuncion			CHAR(1),
	pNumcte				CHAR(20),
	pSucursal			CHAR(4),
	pEjecutivo			CHAR(8),
	pTp_persona			CHAR (2),
	pTp_cliente			CHAR(1),
	pPaterno			CHAR (26),
	pMaterno			CHAR (26),
	pNombre1			CHAR (26),
	pNombre2			CHAR (26),
	pRfc				CHAR (13),
	pSector				CHAR (2),
	pSegmento			CHAR (3),
	pActividad_princ	CHAR (3),
	pGrupo				CHAR(3),
	pSubgrupo			CHAR(3),
	pResidencia			CHAR(1),
	pApell_casada		CHAR(20),
	pNumcte_ref			CHAR(20),
	pDistrito			CHAR(2),
	pPuesto_ppes		CHAR(1),
	pFamiliar_ppes		CHAR(1),
	pActividad_esp		CHAR(11),
	pFecha_nac			DATE, -- Inician columnas de Ctepf
	pLugar_nac			CHAR (2),
	pNacionalidad		CHAR(3),
	pFm3				CHAR(18),
	pEstado_civil		CHAR(1),
	pRegimen_mat		CHAR(1),
	pProfesion			CHAR (3),
	pSexo				CHAR(1),
	pCurp				CHAR(20),
	pCodidentif			CHAR(2),
	pNumidentif			CHAR(30),
	pNo_imss			CHAR(12),
	pDependientes		SMALLINT,
	pTutor				CHAR(60),
	pEmail				CHAR(100),
	pNom_conyuge		CHAR(60),
	pSeguro_defunc		CHAR(1),
	pEscolaridad		CHAR(2),
	pHabita_en			CHAR(20),
	pAnios_habita		SMALLINT,
	pNombre_prop		CHAR(60),
	pImphiporenta 		MONEY(14,2),
	pNumeroife			CHAR(20),
	pNumerotutor		CHAR(20),
	pNumeroconyuge		CHAR(20),
	pEjecut_autoriza	CHAR(8),
	pPromocion			CHAR(2),
	pNumhabitantes		CHAR (60),
	pIdPais				CHAR(3) ---- DSB230162JERV1694
)

RETURNING CHAR(5),CHAR(20);

DEFINE cCodret 			CHAR(5);
DEFINE cCodret2 			CHAR(5);
DEFINE dFecha 				DATE;
DEFINE iSignumcte 			INT;
DEFINE cExiste 			CHAR(1);
DEFINE cEmpresa 			CHAR(3);
DEFINE cNumcte 			CHAR(20);
DEFINE cSucursal 			CHAR(4);
DEFINE cEjecutivo 			CHAR(8);
DEFINE cEjecut_autoriza 	CHAR(8);
DEFINE cTp_persona 		CHAR (2);
DEFINE cTp_cliente 		CHAR(1);
DEFINE cPaterno 			CHAR(26);
DEFINE cMaterno 			CHAR(26);
DEFINE cNombre1 			CHAR(26);
DEFINE cNombre2 			CHAR(26);
DEFINE cRfc 				CHAR(13);
DEFINE cSector 			CHAR(2);
DEFINE cSegmento 			CHAR(3);
DEFINE cAtividad_princ 	CHAR(3);
DEFINE cGrupo 				CHAR(3);
DEFINE cSubgrupo 			CHAR(3);
DEFINE cResidencia 		CHAR(1);
DEFINE cApell_casada 		CHAR(20);
DEFINE cNumcte_referencia	CHAR(20);
DEFINE cDistrito 			CHAR(2);
DEFINE cPuesto_ppes 		CHAR(1);
DEFINE cFamiliar_ppes 		CHAR(1);
DEFINE cActividad_esp 		CHAR(11);
DEFINE dFecha_nac 			DATE; -- Inician columnas de Ctepf
DEFINE cLugar_nac 			CHAR(2);
DEFINE cNacionalidad 		CHAR(3);
DEFINE cFm3 				CHAR(18);
DEFINE cEstado_civil 		CHAR(1);
DEFINE cRegimen_mat 		CHAR(1);
DEFINE cProfesion 			CHAR (3);
DEFINE cSexo 				CHAR(1);
DEFINE cCurp 				CHAR(20);
DEFINE cCodidentif 		CHAR(2);
DEFINE cNumidentif 		CHAR(20);
DEFINE cNo_imss 			CHAR(12);
DEFINE sDependientes 		SMALLINT;
DEFINE cTutor 				CHAR(60);
DEFINE cEmail 				CHAR(60);
DEFINE cNom_conyuge 		CHAR(60);
DEFINE cSeguro_defunc 		CHAR(1);
DEFINE cEscolaridad 		CHAR(2);
DEFINE cHabita_en 			CHAR(20);
DEFINE sAnios_habita 		SMALLINT;
DEFINE cNombre_prop 		CHAR(60);
DEFINE mImphiporenta 		MONEY(14,2);
DEFINE cNumeroife 			CHAR(20);
DEFINE cNumerotutor 		CHAR(20);
DEFINE cNumeroconyuge 		CHAR(20);
DEFINE cTppersona 			CHAR(2);
DEFINE sCont 				SMALLINT;
DEFINE cEsfisica 			CHAR(1);
DEFINE sLongitud		    SMALLINT;
DEFINE sLong_cte 			SMALLINT;
DEFINE iSqlerr				INTEGER;
DEFINE iIsamerr 			INTEGER;
DEFINE cStatus_cte 		CHAR(2);
DEFINE dFecha_alta 		DATE;
DEFINE cRazon_soc 			CHAR(40);
DEFINE sDiferencia			SMALLINT;
DEFINE sI 					SMALLINT;
DEFINE cNumcte_ref 		CHAR(20);
DEFINE cNumhabitantes 		CHAR(60);
DEFINE cSucursalCajaUnica 	CHAR(1);
DEFINE iOrigen 			INTEGER;
DEFINE cTipoRel 			CHAR(1);
DEFINE cCodRet3            CHAR(6);
DEFINE cMensajeRet         CHAR(80);

-- Valida referencia Coppel JOM 20/Abr/2014 INI
DEFINE v_codret_cc         CHAR(5);
DEFINE v_result_cc			CHAR(1);
-- Valida referencia Coppel JOM 20/Abr/2014 FIN
--variable para guardar resultado de consulta
DEFINE nRes					INTEGER;
DEFINE nRes2				INTEGER;

DEFINE mCURP                CHAR(30);
DEFINE mCORREO              CHAR(100);
DEFINE mIDENTIF             CHAR(30);
DEFINE error_info           CHAR(100);

DEFINE cProducto			CHAR(10);
DEFINE bN2 					SMALLINT;


LET mCURP='';
LET mCORREO='';
LET mIDENTIF='';


LET nRes 				=0;
LET nRes2 				=0;
LET cCodret 			= "000";
LET cCodret2 			= '000';
LET cEmpresa 			= pEmpresa;
LET cNumcte 			= " ";
LET cSucursal 			= pSucursal;
LET cTppersona 			= pTp_persona;
LET cNumcte_ref 		= " ";
LET cEjecut_autoriza 	= pEjecut_autoriza;
LET iOrigen 			= 0; --sin informacion
LET cTipoRel			='0';
LET cCodRet3            = "00000";
LET cMensajeRet         = "Se realiza la consulta correctamente";

-- Valida referencia Coppel JOM 20/Abr/2014 INI
LET v_codret_cc      = "00000";
LET v_result_cc		= '';
-- Valida referencia Coppel JOM 20/Abr/2014 FIN

LET bN2 				= 0;
LET cProducto			= "";


BEGIN
ON EXCEPTION SET iSqlerr,iIsamerr,error_info
	IF iSqlerr != 0 THEN
		LET cCodret=iSqlerr;
		INSERT INTO bdisolic:ax_paso values ("bdisolic:ctefisico", iSqlerr, CURRENT ||error_info||' cte '||TRIM(pNumcte));
		RETURN cCodret,cNumcte;
	END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/tmp/ctefisicocurp.sql";
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 4;

SELECT fecha_hoy
  INTO dFecha
  FROM bdinteg:"informix".si_fechas
 WHERE empresa = pEmpresa;

    IF pFuncion = "B" THEN
        LET cNumcte = pNumcte;
        SELECT tpo_persona INTO cTppersona
          FROM bdinteg:"informix".si_cliente
         WHERE numero = pnumero;
        IF cTppersona IS NULL THEN
            LET cNumcte = pNumcte;
            LET cCodret = "104";
            RETURN cCodret,cNumcte;
        ELSE
            SELECT es_fisica
              INTO cEsfisica
              FROM bdinteg:"informix".si_tipper
             WHERE tpo_persona = cTppersona;

            IF UPPER(cEsfisica) != "S" THEN
                LET cCodret = "120";
                RETURN cCodret,cNumcte;
            END IF;
        END IF

        SELECT COUNT(*)
          INTO sCont
          FROM bdicheq:"informix".sc_maechq
         WHERE numcte = pNumcte;

        IF sCont > 0 THEN
            LET cCodret = "121";
            RETURN cCodret,cNumcte;
        END IF

        SELECT COUNT(*)
          INTO sCont
          FROM bdisolic:"informix".ss_solicitudes
         WHERE empresa="001"
           AND numcte = pNumcte;

        IF sCont > 0 THEN
            LET cCodret = "121";
            RETURN cCodret,cNumcte;
        END IF

        SELECT COUNT(*)
          INTO sCont
          FROM bdicred:"informix".sd_maecred
         WHERE numcte = pNumcte;

        IF sCont > 0 THEN
            LET cCodret = "121";
            RETURN cCodret,cNumcte;
        END IF

        SELECT COUNT(*)
          INTO sCont
          FROM bdinvers:"informix".sv_maeinv
         WHERE numcte = pNumcte;

        IF sCont > 0 THEN
            LET cCodret = "121";
            RETURN cCodret,cNumcte;
        END IF

        BEGIN

        DELETE FROM bdinteg:"informix".si_direcciones WHERE numcte = pNumcte;
        DELETE FROM bdinteg:"informix".si_refcomer WHERE numcte = pNumcte;
        DELETE FROM bdinteg:"informix".si_refbancarias WHERE numcte = pNumcte;
        DELETE FROM bdinteg:"informix".si_refper WHERE numcte = pNumcte;
        DELETE FROM bdinteg:"informix".si_ctepf WHERE numcte = pNumcte;
        DELETE FROM bdinteg:"informix".si_ingresos WHERE numcte = pNumcte;
        DELETE FROM bdinteg:"informix".si_cterelacionado WHERE empresa = "001" AND numcte = pNumcte;
        DELETE FROM bdinteg:"informix".si_cteppes WHERE numcte = pNumcte;
        DELETE FROM bdinteg:"informix".si_cliente WHERE numcte = pNumcte;

        END;

        RETURN cCodret,cNumcte;
    END IF

    IF pFuncion = "C" THEN
        LET cNumcte = pNumcte;

       /*
         OBTENEMOS CURP Y NUMERO DE IDENTIFICACION Y CORREO PARA NO ACTUALIZARLOS
       */
        SELECT LIMIT 1 CURP, NUMIDENTIFI INTO mCURP, mIDENTIF FROM SI_CTEPF WHERE NUMCTE=cNumcte;
        SELECT limit 1 CORREO_ELEC INTO mCORREO FROM SI_CORREOS WHERE NUMCTE=cNumcte AND STATUS_CORREO='A';


        SELECT empresa,     numcte,       status_cte,     sucursal,     ejecutivo,
               tpo_persona, tipo_cliente, apell_paterno,  apell_materno,
               nombre1,     nombre2,      razon_social,   rfc,
               sectOR,      segmento,     actividad_princ,grupo,
               subgrupo,    residencia,   fecha_alta,     apell_casada,
               distrito,    numcte_ref,   puesto_ppes,    familiar_ppes,
               actividad_princ,ejecut_autoriza, string2
          INTO cEmpresa,   cNumcte,      cStatus_cte,    cSucursal,   cEjecutivo,
               cTppersona,  cTp_cliente,  cPaterno,       cMaterno,
               cNombre1,    cNombre2,     cRazon_soc,     cRfc,
               cSector,     cSegmento,    cAtividad_princ,cGrupo,
               cSubgrupo,   cResidencia,  dFecha_alta,    cApell_casada,
               cDistrito,   cNumcte_ref,  cPuesto_ppes,   cFamiliar_ppes,
               cActividad_esp,cEjecut_autoriza, cNumhabitantes
          FROM bdinteg:"informix".si_cliente
         WHERE numcte = pNumcte;


        IF cNumcte IS NULL THEN
            LET cCodret = "104";
            RETURN cCodret,cNumcte;
        END IF

        IF pEmpresa IS NULL OR pEmpresa = " " THEN
            LET pEmpresa = cEmpresa;
        END IF

        IF pSucursal IS NULL OR pSucursal = " " THEN
            LET pSucursal=cSucursal;
        END IF;

        IF pEjecutivo IS NULL OR pEjecutivo = " " THEN
            LET pEjecutivo=cEjecutivo;
        END IF;

        IF pTp_persona IS NULL OR pTp_persona = " " THEN
            LET pTp_persona=cTppersona;
        END IF;

        IF pTp_cliente IS NULL OR pTp_cliente = " " THEN
            LET pTp_cliente = cTp_cliente;
        END IF;

        IF pTp_cliente = '2' AND cTp_cliente = '1' THEN
            LET pTp_cliente = cTp_cliente;
        END IF;

        IF pPaterno IS NULL OR pPaterno = " " THEN
            LET pPaterno=cPaterno;
        END IF;

        IF pMaterno IS NULL OR pMaterno = " " THEN
            LET pMaterno=cMaterno;
        END IF;

        IF pNombre1 IS NULL OR pNombre1 = " " THEN
            LET pNombre1=cNombre1;
        END IF;

        IF pNombre2 IS NULL OR pNombre2 = " " THEN
            LET pNombre2=cNombre2;
        END IF;

        IF pRfc IS NULL OR pRfc = " " THEN
            LET pRfc=cRfc;
        END IF;

        IF pSector IS NULL OR pSector = " " THEN
            LET pSector=cSector;
        END IF;

        IF pSegmento IS NULL OR pSegmento = " " THEN
            LET pSegmento=cSegmento;
        END IF;

        IF pActividad_princ IS NULL OR pActividad_princ = " " THEN
            LET pActividad_princ=cAtividad_princ;
        END IF;

        IF pGrupo IS NULL OR pGrupo = " " THEN
            LET pGrupo=cGrupo;
        END IF;

        IF pSubgrupo IS NULL OR pSubgrupo = " " THEN
            LET pSubgrupo=cSubgrupo;
        END IF;

        IF pResidencia IS NULL OR pResidencia = " " THEN
            LET pResidencia=cResidencia;
        END IF;

        IF pApell_casada IS NULL OR pApell_casada = " " THEN
            LET pApell_casada = cApell_casada;
        END IF;

        IF pDistrito IS NULL OR pDistrito = " " THEN
            LET pDistrito=cDistrito;
        END IF;

        IF pNumcte_ref IS NULL OR pNumcte_ref = " " THEN
            LET pNumcte_ref=cNumcte_ref;
        END IF;

        IF pPuesto_ppes IS NULL OR pPuesto_ppes = " " THEN
            LET pPuesto_ppes=cPuesto_ppes;
        END IF;

        IF pFamiliar_ppes IS NULL OR pFamiliar_ppes = " " THEN
            LET pFamiliar_ppes=cFamiliar_ppes;
        END IF;

        IF pActividad_esp IS NULL OR pActividad_esp = " " THEN
            LET pActividad_esp=cActividad_esp;
        END IF;

        IF pEjecut_autoriza IS NULL OR pEjecut_autoriza = " " THEN
            LET pEjecut_autoriza=cEjecut_autoriza;
        END IF;

        IF pCurp IS NULL OR pCurp = "" THEN
            LET pCurp=mCURP;
        END IF;

        IF pNumidentif IS NULL OR pNumidentif = "" THEN
            LET pNumidentif=mIDENTIF;
        END IF;

        IF pEmail IS NULL OR pEmail = "" THEN
            LET pEmail=mCORREO;
        END IF;



        SELECT numcte,         fecha_nac,       lugar_nac,        nacionalidad,
               no_fm3,         estado_civil,    regim_matrimonio, profesion,
               sexo,           curp,            codidentifi,      numidentifi,
               no_imss,        dependientes,    tutor,
               nom_conyuge,    seguro_defunc,   escolaridad,      habita_en,
               anios_habita,   nombre_prop,     imp_hipo_renta,   numeroife,
               numerotutor,    numeroconyuge
          INTO cNumcte,        dFecha_nac,      cLugar_nac,       cNacionalidad,
               cFm3,           cEstado_civil,   cRegimen_mat,     cProfesion,
               cSexo,          cCurp,           cCodidentif,      cNumidentif,
               cNo_imss,       sDependientes,   cTutor,
               cNom_conyuge,   cSeguro_defunc,  cEscolaridad,     cHabita_en,
               sAnios_habita,  cNombre_prop,    mImphiporenta,    cNumeroife,
               cNumerotutor,   cNumeroconyuge
          FROM bdinteg:"informix".si_ctepf
         WHERE numcte = pNumcte;

        SELECT correo_elec
          INTO cEmail
          FROM "informix".si_correos
         WHERE numcte = pNumcte
           AND tipo_correo = 1
           AND status_correo = 'A'
		   and secuencia = (
			select max(secuencia)
			from "informix".si_correos
			where numcte = pNumcte AND status_correo = 'A' AND tipo_correo = 1);

        IF pFecha_nac IS NULL OR pFecha_nac = " " THEN
            LET pFecha_nac=dFecha_nac;
        END IF;

        IF pLugar_nac IS NULL OR pLugar_nac = " " THEN
            LET pLugar_nac=cLugar_nac;
        END IF;

        IF pNacionalidad IS NULL OR pNacionalidad = " " THEN
            LET pNacionalidad=cNacionalidad;
        END IF;

		-->> 29/10/2014
        --IF pFm3 IS NULL OR pFm3 = " " THEN
        --    LET pFm3 = cFm3;
        --END IF; << 29/10/2014

        IF pEstado_civil IS NULL OR pEstado_civil = " " THEN
            LET pEstado_civil=cEstado_civil;
        END IF;

        IF pRegimen_mat IS NULL OR pRegimen_mat = " " THEN
            LET pRegimen_mat=cRegimen_mat;
        END IF;

        IF pProfesion IS NULL OR pProfesion = " " THEN
            LET pProfesion = cProfesion;
        END IF;

        IF pSexo IS NULL OR pSexo = " " THEN
            LET pSexo=cSexo;
        END IF;

		--SE VALIDA QUE LA CURP NO VENGA VACIA
		IF(pCurp <> '') THEN
		
			IF SUBSTRING(cRfc FROM 1 FOR 10) <> SUBSTRING(pCurp FROM 1 FOR 10) THEN
					INSERT INTO bdinteg:"informix".si_bitacora_cambio_curp
					( numcte, rfc, curp, resultado, fecha )
					VALUES
					( pNumcte, cRfc, pCurp, '03', CURRENT );

					--LET pCurp = cCurp;
			END IF;
		
		END IF;

        IF pCodidentif IS NULL OR pCodidentif = " " THEN
            LET pCodidentif = cCodidentif;
        END IF

        IF pNumidentif IS NULL OR pNumidentif = " " THEN
            LET pNumidentif = cNumidentif;
        END IF

        IF pNo_imss IS NULL OR pNo_imss = " " THEN
            LET pNo_imss = cNo_imss;
        END IF

        IF pDependientes IS NULL OR pDependientes = " " THEN
            LET pDependientes = sDependientes;
        END IF

        IF pTutor IS NULL OR pTutor = " " THEN
            LET pTutor = cTutor;
        END IF

        IF pEmail IS NULL OR pEmail = " " THEN
            LET pEmail = cEmail;
        END IF

        IF pNom_conyuge IS NULL OR pNom_conyuge = " " THEN
            LET pNom_conyuge = cNom_conyuge;
        END IF

        /* #####################################################
        IF pseguro_definc IS NULL OR pSeguro_defunc = " " THEN
            LET pSeguro_defunc = cSeguro_defunc;
        END IF
        ##################################################### */

        SELECT FIRST 1 ch.producto 
		INTO cPaterno
		FROM bdicheq: sc_maechq ch,	bdinteg: si_cliente cte 
		WHERE cte.numcte = pNumcte
		AND ch.num_cte = cte.numcte
		AND ch.producto = "2900";

		IF cPaterno <> "" THEN -- es cliente N2
			IF (pEscolaridad IS NULL OR pEscolaridad = " ") and (cEscolaridad IS NULL OR cEscolaridad = " ") THEN
				LET bN2 = 1;
			ELIF bN2 <> 1 AND (pHabita_en IS NULL OR pHabita_en = " ") AND (cHabita_en IS NULL OR cHabita_en = " ")THEN
				LET bN2 = 1;
			ELIF pEscolaridad IS NULL OR pEscolaridad = " " THEN
				LET pEscolaridad = cEscolaridad;
			ELIF pHabita_en IS NULL OR pHabita_en = " " THEN
				LET pHabita_en = cHabita_en;
			END IF
		ELSE
			LET bN2 = 0;
			IF pEscolaridad IS NULL OR pEscolaridad = " " THEN
				LET pEscolaridad = cEscolaridad;
			END IF
			
			IF pHabita_en IS NULL OR pHabita_en = " " THEN
				LET pHabita_en = cHabita_en;
			END IF
		ENd If

        IF pAnios_habita IS NULL THEN
            LET pAnios_habita = sAnios_habita;
        END IF

        IF pNombre_prop IS NULL OR pNombre_prop = " " THEN
            LET pNombre_prop = cNombre_prop;
        END IF

        IF pImphiporenta IS NULL THEN
            LET pImphiporenta = mImphiporenta;
        END IF

        IF pNumeroife IS NULL OR pNumeroife = " " THEN
            LET pNumeroife = cNumeroife;
        END IF

        IF pNumerotutor IS NULL OR pNumerotutor = " " THEN
            LET pNumerotutor = cNumerotutor;
        END IF

        IF pNumeroconyuge IS NULL OR pNumeroconyuge = " " THEN
            LET pNumeroconyuge = cNumeroconyuge;
        END IF
    END IF

	-- DSB 19/10/2014 >>
	IF NVL(pFuncion,'') = "S" THEN
		IF NVL(pEmpresa,'') = '' OR NVL(pNumcte,'') = '' OR NVL(pEscolaridad,'') = '' THEN
				LET cCodret = "200";
				RETURN cCodret,cNumcte;
		ELSE
			SELECT 1 INTO cExiste
			FROM bdinteg:"informix".si_cliente
			WHERE empresa = pEmpresa AND numcte = pNumcte;

		   IF NVL(cExiste,'') = '1' THEN
				SELECT 1 INTO cExiste
				FROM bdinteg:"informix".si_ctepf
				WHERE empresa = pEmpresa AND numcte = pNumcte;

				IF NVL(cExiste,'') = '1' THEN
					UPDATE bdinteg:"informix".si_ctepf
					SET escolaridad = pEscolaridad
					WHERE empresa = pEmpresa AND numcte = pNumcte;
					RETURN cCodret,cNumcte;
				ELSE
					LET cCodret = "220";
					RETURN cCodret,cNumcte;
			   END IF
			ELSE
				LET cCodret = "210";
				RETURN cCodret,cNumcte;
		   END IF
		END IF;
	END IF -- << DSB 19/10/2014

    --- Verifica recepcion correcta de datos
    IF pSucursal IS NULL OR pEjecutivo IS NULL OR
       pTp_persona IS NULL OR pTp_cliente IS NULL OR
       pPaterno IS NULL OR pNombre1 IS NULL OR pRfc IS NULL OR
       pSector IS NULL OR pSegmento IS NULL OR
       pActividad_princ IS NULL OR pGrupo IS NULL OR
       pSubgrupo IS NULL OR pResidencia IS NULL OR
       pPuesto_ppes IS NULL OR pFamiliar_ppes IS NULL OR
       pFecha_nac IS NULL OR pLugar_nac IS NULL OR
       pNacionalidad IS NULL OR pEstado_civil IS NULL OR
       pProfesion IS NULL OR pSexo IS NULL OR
       pCodidentif IS NULL OR pNumidentif IS NULL OR
       pDependientes IS NULL OR pEscolaridad IS NULL OR
       pHabita_en IS NULL THEN
        LET cCodret = "110";
        RETURN cCodret,cNumcte;
    END IF;

    SELECT es_fisica
      INTO cEsfisica
      FROM bdinteg:"informix".si_tipper
     WHERE tpo_persona = pTp_persona;

    IF UPPER(cEsfisica) != "S" THEN
        LET cCodret = "120";
        RETURN cCodret,cNumcte;
    END IF;

    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_sucursales
     WHERE sucursal=pSucursal;

    IF cExiste IS NULL THEN
        LET cCodret = "111";
        RETURN cCodret,cNumcte;
    END IF;

    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_ejecut
     WHERE ejecutivo=pEjecutivo;

    IF cExiste IS NULL THEN
        FOREACH
            SELECT limit 1 1
                INTO cExiste
            FROM bdinteg:"informix".si_usuario_movil
            WHERE ejecutivo=pEjecutivo
        END FOREACH;

        IF cExiste IS NULL THEN
            LET cCodret = "112";
            RETURN cCodret,cNumcte;
        END IF;
    END IF;

    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_sector
     WHERE sector=pSector;

    IF cExiste IS NULL THEN
        LET cCodret = "113";
        RETURN cCodret,cNumcte;
    END IF;

    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_segment
     WHERE segmento=pSegmento;

    IF cExiste IS NULL THEN
        LET cCodret = "114";
        RETURN cCodret,cNumcte;
    END IF;

    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_grupos
     WHERE grupo=pGrupo;

    IF cExiste IS NULL THEN
        LET cCodret = "115";
        RETURN cCodret,cNumcte;
    END IF;

    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_subgpos
     WHERE subgrupo=pSubgrupo;

    IF cExiste IS NULL THEN
        LET cCodret = "116";
        RETURN cCodret,cNumcte;
    END IF;

    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_nacion
     WHERE nacion=pNacionalidad;

    IF cExiste IS NULL THEN
        LET cCodret = "124";
        RETURN cCodret,cNumcte;
    END IF;

    /* ############################
    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_actesp
     WHERE codigo=pActividad_esp;

    IF cExiste IS NULL THEN
        LET cCodret="125";
        RETURN cCodret,cNumcte;
    END IF;
    ############################ */

	-- DSB 29/10/2014
    /* SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_profesion
     WHERE profesion = pProfesion;

    IF cExiste IS NULL THEN
        LET cCodret = "126";
        RETURN cCodret,cNumcte;
    END IF; */

    LET pRfc = TRIM(pRfc);

    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_cliente
     WHERE rfc = pRfc;

    IF NOT cExiste IS NULL AND pFuncion = "A" THEN
        LET cCodret = "106";
        RETURN cCodret,cNumcte;
    END IF

    /* #################################
    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_escolaridad
     WHERE escolaridad = pEscolaridad;

    IF cExiste IS NULL THEN
        LET cCodret="135";
        RETURN cCodret,cNumcte;
    END IF;
    ################################# */

    IF TRIM(pCodidentif) <> "" THEN
        SELECT 1
          INTO cExiste
          FROM bdinteg:"informix".si_tipoidentif
         WHERE codidentif = pCodidentif;

        IF cExiste IS NULL THEN
            LET cCodret = "133";
            RETURN cCodret,cNumcte;
        END IF
    END IF;

    /* ##############################
    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_habitaen
     WHERE habita_en = pHabita_en;

    IF cExiste IS NULL THEN
        LET cCodret="117";
        RETURN cCodret,cNumcte;
    END IF; --- Revisar MAC
    ############################## */

    IF pTp_cliente = "M" THEN ---MenOR de edad
        IF pTutor IS NULL OR pTutor = "" THEN
            LET cCodret = "144";
            RETURN cCodret,cNumcte;
        END IF

        SELECT 1
          INTO cExiste
          FROM bdinteg:"informix".si_cliente
         WHERE numcte = pTutor;

        IF cExiste IS NULL THEN
            LET cCodret = "145";
            RETURN cCodret,cNumcte;
        END IF
    END IF;

    IF pNumcte IS NULL OR pNumcte = " " THEN
        SELECT valor
          INTO sLong_cte
          FROM bdinteg:"informix".si_param
         WHERE cod_param = 7
           AND empresa = pEmpresa;

        IF sLong_cte IS NULL THEN
            LET cCodret = "105";
            RETURN cCodret,cNumcte;
        ELSE
            SELECT valor
              INTO iSignumcte
              FROM bdinteg:"informix".si_param
             WHERE empresa = pEmpresa
               AND cod_param = 6;

            IF iSignumcte IS NULL THEN
                LET iSignumcte = 1;
            END IF

            LET cNumcte=iSignumcte;
            LET iSignumcte=iSignumcte + 1;

            UPDATE bdinteg:"informix".si_param
               SET (valor) = (iSignumcte)
             WHERE empresa = pEmpresa
               AND cod_param = 6;

            LET sDiferencia = sLong_cte - LENGTH(cNumcte);

            IF sDiferencia > 0 THEN
                FOR sI = 1 TO sDiferencia
                    LET cNumcte = "0" || cNumcte;
                END FOR;
            END IF
        END IF;
    ELSE
        LET cNumcte = pNumcte;
    END IF;

    -- ****************** Actualizacion de Parametros *****************
    IF pFuncion = "A" THEN
        SELECT 1 INTO cExiste
          FROM bdinteg:"informix".si_cliente
         WHERE numcte = cNumcte;

        IF cExiste = "1" THEN
            LET cCodret = "118";
            RETURN cCodret, cNumcte;
        END IF;

        IF NVL(pNumcte_ref,'') <> '' THEN
-- Valida referencia Coppel JOM 20/Abr/2014 INI
            EXECUTE PROCEDURE bdinteg:"informix".sp_cons_ref_cop(pEmpresa, pSucursal, pEjecutivo, cNumcte, pNumcte_ref, pPaterno, pMaterno, pNombre1 ,pNombre2, pRfc)
                         INTO v_codret_cc, v_result_cc;

            IF ( v_result_cc = '1' ) THEN
                LET pNumcte_ref = '';
            END IF;
         END IF;
-- Valida referencia Coppel JOM 20/Abr/2014 FIN

		SELECT 1
			INTO cExiste
		FROM bdinteg:"informix".si_cliente
		WHERE rfc = pRfc;

		IF NOT cExiste IS NULL AND pFuncion = "A" THEN
			LET cCodret = "106";
			RETURN cCodret,cNumcte;
		END IF

        BEGIN

        INSERT INTO bdinteg:"informix".si_cliente
        ( empresa, numcte, status_cte, sucursal, ejecutivo, tpo_persona, tipo_cliente, apell_paterno, apell_materno, nombre1, nombre2, razon_social,
          rfc, sectOR, segmento, actividad_princ, grupo, subgrupo, residencia, fecha_alta, apell_casada, distrito, numcte_ref, string1, string2,
          numeric1, numeric2, money1, DATE1, puesto_ppes, familiar_ppes, actividad_esp, ejecut_autoriza, user_insert, fecha_insert) --, id_pais ) -- DSB230162JERV1694 id_pais
        VALUES
        ( pEmpresa, cNumcte, "AL", pSucursal, pEjecutivo, pTp_persona, pTp_cliente, pPaterno, pMaterno, pNombre1, pNombre2, " ",
          pRfc, pSector, pSegmento, pActividad_princ, pGrupo, pSubgrupo, pResidencia, dFecha, pApell_casada, pDistrito, pNumcte_ref, "", pNumhabitantes,
          0, 0, 0, "", pPuesto_ppes, pFamiliar_ppes, pActividad_esp, pEjecut_autoriza, pEjecutivo, dFecha); --, pIdPais); -- DSB230162JERV1694 pIdPais

		IF NVL(pEjecutivo,"") <> "" THEN
			INSERT INTO bdinteg:"informix".si_ctepf
			( numcte, fecha_nac, lugar_nac, nacionalidad, no_fm3, estado_civil, regim_matrimonio, profesion, sexo, curp, codidentifi, numidentifi, no_imss,
			  dependientes, tutor, nom_conyuge, empresa, seguro_defunc, escolaridad, habita_en, anios_habita, nombre_prop, imp_hipo_renta, string1, sms_cel, id_pais, user_insert) -- DSB230162JERV1694 id_pais
			VALUES
			( cNumcte, pFecha_nac, pLugar_nac, pNacionalidad, pFm3, pEstado_civil, pRegimen_mat, pProfesion, pSexo, pCurp, pCodidentif, pNumidentif, pNo_imss,
			  pDependientes, pTutor, pNom_conyuge, pEmpresa, pSeguro_defunc, pEscolaridad, pHabita_en, pAnios_habita, pNombre_prop, pImphiporenta, pPromocion, '0', pIdPais, pEjecutivo); -- DSB230162JERV1694 pIdPais
		ELSE
			INSERT INTO bdinteg:"informix".si_ctepf
			( numcte, fecha_nac, lugar_nac, nacionalidad, no_fm3, estado_civil, regim_matrimonio, profesion, sexo, curp, codidentifi, numidentifi, no_imss,
			  dependientes, tutor, nom_conyuge, empresa, seguro_defunc, escolaridad, habita_en, anios_habita, nombre_prop, imp_hipo_renta, string1, sms_cel, id_pais) -- DSB230162JERV1694 id_pais
			VALUES
			( cNumcte, pFecha_nac, pLugar_nac, pNacionalidad, pFm3, pEstado_civil, pRegimen_mat, pProfesion, pSexo, pCurp, pCodidentif, pNumidentif, pNo_imss,
			  pDependientes, pTutor, pNom_conyuge, pEmpresa, pSeguro_defunc, pEscolaridad, pHabita_en, pAnios_habita, pNombre_prop, pImphiporenta, pPromocion, '0', pIdPais); -- DSB230162JERV1694 pIdPais
		END IF;
		
        SELECT NVL(cajaunica, '')
          INTO cSucursalCajaUnica
          FROM bditarjcop:"informix".sucursalescajaunica
         WHERE cvesucursal = pSucursal;

        IF cSucursalCajaUnica = 'V' THEN
            UPDATE bdinteg:"informix".si_cliente
               SET string1 = '1'
             WHERE numcte = cNumcte;
        END IF;

        IF NVL(pNumcte_ref,"") <> "" THEN ---JMAH se realiza validacion para relacionar al cliente Bancoppel con un Cliente Coppel
			LET iOrigen = 2; --relacion por alta de cliente ; ---JMAH
			LET cTipoRel ='1';
		END IF;		--se agrega llamado para crear relacion de clientes bancoppel-coppel.

		EXECUTE PROCEDURE bdinteg:"informix".sp_relacion_generarelacion (cNumcte,pNumcte_ref,'',cTipoRel,iOrigen)
        INTO cCodRet3,cMensajeRet;

        END;

        IF pEmail IS NOT NULL OR pEmail <> '' THEN
            CALL sp_registra_correos( pEmpresa, cNumcte, pEmail, 1, 1, pEjecutivo )
            RETURNING cCodret2;
        END IF;

        RETURN cCodret, cNumcte;
    ELSE
        SELECT 1
          INTO cExiste
          FROM "informix".si_cliente
         WHERE numcte = cNumcte;

        IF cExiste IS NULL THEN
            LET cCodret = "104";
            RETURN cCodret,cNumcte;
        END IF;

        BEGIN
		
		SELECT COUNT(*) INTO nRes FROM si_usuario_movil WHERE ejecutivo=pEjecutivo;
        
		IF (nRes > 0) THEN
            
			SELECT  COUNT(*) INTO nRes2 FROM si_solicitud_movil WHERE numcte=cNumcte AND folio_procesado=0 AND status_valua=1;
			
            IF (nRes2 > 0) THEN
			
                SELECT first 1 escolaridad, tipo_residencia, pers_domicilio 
                    INTO pEscolaridad, pHabita_en, pNumhabitantes
                    FROM si_solicitud_movil
					WHERE numcte=cNumcte
					AND folio_procesado=0
					AND escolaridad <>'' AND escolaridad IS NOT NULL
					AND tipo_residencia <>'' AND tipo_residencia IS NOT NULL
					AND pers_domicilio <>'' AND pers_domicilio IS NOT NULL;
					
				
				LET pEscolaridad="0"||pEscolaridad;
				
            END IF;
        END IF;
		
		-- Se agrega para que los ciientes provenientes de Apolo no les cambie el ejecutivo
		    IF cEjecutivo='70000002' THEN
			 LET pEjecutivo='70000002';
			END IF;


		IF(pSector = '00') THEN 
		    		
			-- Se Desactiva por Requerimiento de Bancoppel JLP 18/09/07
			UPDATE bdinteg:"informix".si_cliente
			   SET ( ejecutivo, tpo_persona, tipo_cliente, --- apell_paterno, apell_materno, nombre1, nombre2, rfc, sectOR, segmento, actividad_esp,
					 segmento, actividad_esp, grupo, subgrupo, residencia, fecha_alta, apell_casada, distrito, string2) = --, id_pais) = -- DSB230162JERV1694 id_pais
				   ( pEjecutivo, pTp_persona, pTp_cliente, --- pPaterno, pMaterno, pNombre1, pNombre2,
					 pSegmento, pActividad_esp, pGrupo, pSubgrupo, pResidencia, dFecha, pApell_casada, pDistrito, pNumhabitantes) --, pIdPais) -- DSB230162JERV1694 pIdPais
			WHERE numcte = cNumcte;
		
		ELSE

			-- Se Desactiva por Requerimiento de Bancoppel JLP 18/09/07
			UPDATE bdinteg:"informix".si_cliente
			   SET ( ejecutivo, tpo_persona, tipo_cliente, --- apell_paterno, apell_materno, nombre1, nombre2, rfc, sectOR, segmento, actividad_esp,
					 sectOR, segmento, actividad_esp, grupo, subgrupo, residencia, fecha_alta, apell_casada, distrito, string2) = --, id_pais) = -- DSB230162JERV1694 id_pais
				   ( pEjecutivo, pTp_persona, pTp_cliente, --- pPaterno, pMaterno, pNombre1, pNombre2,
					 pSector, pSegmento, pActividad_esp, pGrupo, pSubgrupo, pResidencia, dFecha, pApell_casada, pDistrito, pNumhabitantes) --, pIdPais) -- DSB230162JERV1694 pIdPais
			WHERE numcte = cNumcte;
		
		END IF;

		--SE VALIDA SI LA CURP VIENE VACIA
		--IF(pCurp = '') THEN
		--	SELECT curp
		--	INTO pCurp
		--	FROM "informix".si_ctepf 
		--	WHERE numcte = cNumcte;
		--END IF;
		
		UPDATE bdinteg:"informix".si_ctepf
		   SET ( fecha_nac, lugar_nac, nacionalidad, no_fm3, estado_civil, regim_matrimonio, profesion, sexo,
				 curp, codidentifi, numidentifi, no_imss, dependientes, tutor, nom_conyuge,
				 seguro_defunc, escolaridad, habita_en, anios_habita, nombre_prop, imp_hipo_renta, sms_cel, id_pais) = -- DSB230162JERV1694 id_pais
			   ( pFecha_nac, pLugar_nac, pNacionalidad, pFm3, pEstado_civil, pRegimen_mat, pProfesion, pSexo,
				 pCurp, pCodidentif, pNumidentif, pNo_imss, pDependientes, pTutor, pNom_conyuge,
				 pSeguro_defunc, pEscolaridad,pHabita_en, pAnios_habita, pNombre_prop, pImphiporenta, '0', pIdPais) -- DSB230162JERV1694 pIdPais
		WHERE numcte = cNumcte;
		

        END;

        IF pEmail IS NOT NULL OR pEmail <> '' THEN
            CALL sp_registra_correos( pEmpresa, cNumcte, pEmail, 1, 1, pEjecutivo )
            RETURNING cCodret2;
        END IF;
    END IF;

    RETURN cCodret, cNumcte;

    END;

END PROCEDURE

DOCUMENT
"Alta, Baja y/o Cambio de cliente persona fisica ",
"AutOR : Procesamiento Interactivo S.A. de C.V.",
"FECHA : 14/Marzo/2008",
"Ver.  : 1.1",
"BD    : bdinteg",
"MODIFICO : Moreno Cota Jesus Alberto",
"MODIFICACION: Se agrega cantidad de personas vivien domicilio",
"BD    : bdinteg",
"VER   : 1.1",
"MODIFICO : Gaxiola Gaxiola Frank",
"MODIFICACION: Se agrega validacion para cuando la sucursal este activa como caja unica",
"marque al cliente en el campo string1 como cliente nacido en caja unica",
"BD    : bdinteg",
"VER   : 1.1",
"MODIFICO : Aguilar Heredia Jesus Manuel",
"FECHA : 26/Abril/2012",
"MODIFICACION: Se agrega validacion para crear la relacion de clientes Bancoppel con Coppel en una tabla de control",
"BD    : bdinteg",
"VER   : 1.1",
"MODIFICO : Zazueta Acosta Josue Remberto",
"FECHA : 11/JUNIO/2012",
"MODIFICACION:Se modifica para que realice el insert a la tabla de si_relacion_ctebcplcpl por medio de el", "sp_relacion_generarelacion en lugar de aserlo por medio de alta unica",
"BD    : bdinteg",
"VER   : 1.1",
"MODIFICO : Zazueta Acosta Josue Remberto",
"FECHA : 15/Agosto/2012",
"MODIFICACION: Se Modifica Origen de la relacion de clientes, se quita el origen por medio de alta unica",
"BD    : bdinteg",
"VER   : 1.1",
"MOFIDICA     : Martin Eduardo Miranda",
"FECHA        : 26/Abril/2013",
"MODIFICACION : Se modifica Procedimiento Almacenado para comentar la linea 'LET pCurp = cCurp'",
"               * Se aplican reglas de programacion.",
"MOFIDICA     : Claudio Almodovar",
"FECHA        : 29/10/2014",
"cCodret  200 : parametros vacios para opcion 'S'",
"cCodret  210 : cliente no existe en bdinteg:si_cliente",
"cCodret  220 : cliente no existe en bdinteg:si_ctepf",
"MODIFICACION : Se modifica para agregar la opcion 'S' para pFuncion y se comenta donde pFm3 toma valor si es vacio o null",
"--------------",
"Folio:			1693",
"Proyecto:		MTTO-OFI_PAIS_NACION",
"Asunto:		Requerimiento",
"Autor: 		95579737 - Jose Ernesto Raygoza Villa",
"Fecha: 		03/Mayo/2016",
"Sustento:		peticiones pendientes de desarrollo bancoppel",
"Solicita:		Gisela Rivera",
"Descripcion:	Se agrega parametro para aceptar el nuevo campo id_pais para el insert de la si_cliente y para el update de la si_ctepf",
"BD: 			bdinteg",
"Etiqueta:		DSB230162JERV1694";

CREATE PROCEDURE "informix".sp_acivarserviciobpi_apolo(psTipo CHAR(1), psEmpresa CHAR(3), psNumCte CHAR(20), psStatus SMALLINT,
                                               psFolio CHAR(12), psSucursal CHAR(4), psNomEmpleado CHAR(60), psIp CHAR(15), 
                                               pTipoServicio SMALLINT)
RETURNING CHAR(5),CHAR(6);

--Declaracion de variables
DEFINE vsCodRet CHAR(5);
DEFINE viSqlErr INTEGER;
--DEFINE vsMensaje CHAR(250);
DEFINE vsMensaje CHAR(6);
--DEFINE vdFecha  DATE;
DEFINE vsNumCliente CHAR(9); 
DEFINE cantidad SMALLINT;
DEFINE vsFolioSucEnc CHAR(55);
DEFINE FolioClaro CHAR(13); --INCFOLREP17082022
DEFINE folioAlterno CHAR(12);
DEFINE vsFolioAlternoEnc CHAR(55);
DEFINE i INTEGER;
DEFINE vsCodRetFolioDup CHAR(5);
DEFINE ccodretma CHAR(5);
--Asignacion de variables
LET vsCodRet = '00000';
LET viSqlErr = 0;
LET vsMensaje = '';
--LET vdFecha = '01-01-1900';
LET vsNumCliente = ''; 
LET vsFolioSucEnc = ''; 
LET FolioClaro = ''; --INCFOLREP17082022
LET folioAlterno = '';
LET vsFolioAlternoEnc = '';
LET i = 0;
LET vsCodRetFolioDup = '00000';
LET ccodretma = '';


--SET DEBUG FILE TO "/tmp/sp_acivarserviciobpitest"||TRIM(psNumCte)||".out";
--TRACE ON;


IF NVL(psTipo, '') = '' OR NVL(psEmpresa, '') = '' OR NVL(psNumCte, '') = '' OR  psStatus IS NULL OR NVL(psSucursal, '') = '' OR
   NVL(psNomEmpleado, '') = '' OR  NVL(psIp, '') = ''OR pTipoServicio IS NULL THEN --Valida que  no sean nulo o espacio en blanco
   LET vsCodRet = '00003';
END IF;

--Inicio del procedimiento


BEGIN
	ON EXCEPTION SET viSqlErr --Manejador de Errores
        IF viSqlErr <> 0 then
            LET vsCodRet = viSqlErr;
            RETURN vsCodRet,vsMensaje;
        END IF;
    END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION DIRTY READ;
	
    --AFORE
	IF psNumCte <> '' AND psSucursal <> '' AND psNomEmpleado <> '' THEN
        EXECUTE PROCEDURE bdinteg:"informix".sp_inserta_msjafore(psNumCte,'',psSucursal, substring(psNomEmpleado FROM 1 FOR 8))
        INTO ccodretma;
    END IF;
    --AFORE

    IF vsCodRet = '00000' THEN		
        IF psTipo = '1' THEN
            IF psFolio <>'' AND length(psFolio) = 12 THEN		
                EXECUTE PROCEDURE bdinteg:"informix".sp_valida_folio_dubplicado(psFolio) INTO vsCodRetFolioDup,FolioClaro ,vsFolioSucEnc; -- Encripta folio contrato   
                IF (vsCodRetFolioDup = '00002') THEN--Folio Duplicado
                    LET i = 0; 
                    WHILE i <= 1
                        EXECUTE FUNCTION bdinteg:"informix".sp_genera_folioactivacion_bpi() INTO vsCodRet, folioAlterno;
                        IF (vsCodRet = '00000' )  THEN
                            EXECUTE PROCEDURE bdinteg:"informix".sp_valida_folio_dubplicado(folioAlterno) INTO vsCodRetFolioDup,folioAlterno ,vsFolioAlternoEnc; -- Encripta folio contrato
                            IF (vsCodRetFolioDup = '00000' )THEN
                                LET i = 2;
                                INSERT INTO bdinteg:"informix".si_bpiusuarios(empresa, numcte, id_status, folio_contrato, f_status, suc_registro, num_empleado, fecha_movto, servicio, f_unico_reg)
                                VALUES(psEmpresa, psNumCte, psStatus, vsFolioAlternoEnc, CURRENT, psSucursal, psNomEmpleado, CURRENT, '2', CURRENT);
                                    
                                SELECT count(*), numcte  into cantidad, vsNumCliente FROM bdinteg:"informix".si_bpiusuarios_folioalterno WHERE empresa = psEmpresa AND numcte = psNumCte group by numcte;
                                IF(cantidad>0)THEN
                                    UPDATE bdinteg:"informix".si_bpiusuarios_folioalterno SET folio_contrato_suc = vsFolioSucEnc, folio_contrato_alterno = vsFolioAlternoEnc WHERE empresa = psEmpresa AND numcte = psNumCte;
                                ELSE
                                    INSERT INTO bdinteg:"informix".si_bpiusuarios_folioalterno(empresa, numcte, folio_contrato_suc, folio_contrato_alterno)
                                    VALUES(psEmpresa, psNumCte, vsFolioSucEnc, vsFolioAlternoEnc);
                                END IF;
                            ELSE
                                LET i = 1;
                            END IF;
                        END IF;
                    END WHILE;    
                ELSE                 
                    INSERT INTO bdinteg:"informix".si_bpiusuarios(empresa, numcte, id_status, folio_contrato, f_status, suc_registro, num_empleado, fecha_movto, servicio, f_unico_reg)
                    VALUES(psEmpresa, psNumCte, psStatus, vsFolioSucEnc, CURRENT, psSucursal, psNomEmpleado, CURRENT, '2', CURRENT);                
                END IF;   
            ELSE
                LET vsCodRet = '00002';
            END IF; 
        ELSE
            LET vsCodRet = '00001';
        END IF;
    END IF;

    RETURN vsCodRet,vsMensaje;

END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se genera copia depurada para flujo clientes nuevos APOLO ONBOARDING ' ,
'AUTOR:Oscar Marquez ',   
'FECHA DE CREACION: 12/06/2025',
'FOLIO: APOLO',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_cnsif_saldos(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCTE CHAR(20))
							
				returning CHAR(5)     AS Cod_Retorno,
						  MONEY(14,2) AS Saldo,
						  MONEY(14,2) AS Saldo_Plazo,
						  MONEY(14,2) AS Saldo_Credito;
												
DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;							

DEFINE mSaldo_vista			MONEY(14,2);
DEFINE mSaldo_plaza			MONEY(14,2);
DEFINE mSaldo_credito		MONEY(14,2);
DEFINE mSaldo_credito2		MONEY(14,2);
DEFINE mSaldo_credito3		MONEY(14,2);
DEFINE cNumero_credito		CHAR(20);
DEFINE iTpo_cliente			INT;
DEFINE cNumCtePrincipal CHAR(20);
DEFINE cNumero_cuenta 		CHAR(20);

--inicializando variables
LET  iexiste = 0;
LET cCodRet = "00000";
LET iSql_err = 0 ;	

LET mSaldo_vista	= 0;	
LET mSaldo_plaza	= 0;
LET mSaldo_credito	= 0;
LET mSaldo_credito2 = 0;
LET mSaldo_credito3 = 0;
LET cNumero_credito	="";
LET iTpo_cliente=0;
LET cNumCtePrincipal = "";
LET cNumero_cuenta 	= "" ;


BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN 
			cCodRet,mSaldo_vista,mSaldo_plaza,mSaldo_credito;
		END IF;
	END EXCEPTION;
	--  SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_saldos_2.out";
	-- TRACE ON;
	IF 	cID_USUARIOC = '' OR
		cID_FUNCIONC = '' OR
		cNUMCTE  = ''	   THEN 
		LET cCodRet = "00054";
		RETURN
		cCodRet,mSaldo_vista,mSaldo_plaza,mSaldo_credito;
	END IF;	

	EXECUTE PROCEDURE bdicnweb:"informix".sp_validacte_transfer(cNUMCTE) INTO cCodRet,iTpo_cliente,cNumCtePrincipal;
	IF cNumCtePrincipal IS NOT NULL THEN
		LET cNUMCTE = cNumCtePrincipal;
	END IF;

	FOREACH
	SELECT LIMIT 1 nvl(COUNT(numcte),0) INTO iexiste FROM si_cliente WHERE numcte = cNUMCTE
	UNION
	SELECT nvl(COUNT(numcte_tf),0) FROM bditransfer:tf_maecte WHERE numcte_tf = cNUMCTE
	ORDER BY 1 desc
	END FOREACH;

	IF iexiste = 0 THEN 
		LET cCodRet = "00055";
		RETURN cCodRet,mSaldo_vista,mSaldo_plaza,mSaldo_credito;
	END IF;	
	
	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCTE,'01','2')
	INTO
	cCodRet;
	IF (cCodRet != '00000')  THEN
	    RETURN cCodRet,mSaldo_vista,mSaldo_plaza,mSaldo_credito;
	END IF;
	-- TERMINA VALIDACION

    SET ISOLATION TO DIRTY READ;
	SELECT nvl(SUM(ME.sdo_cap_insoluto),0) as Saldo 
	INTO mSaldo_credito
	FROM bdicred:sd_maesdos ME,
		 bdicred:sd_maecred MC
	WHERE MC.numcte =  cNUMCTE 
	AND MC.num_credito = ME.num_credito;

    SET ISOLATION TO DIRTY READ;
	SELECT nvl(SUM(ME.sdo_cap_insoluto),0) as Saldo 
	INTO mSaldo_credito2
	FROM bdicred:sd_maesdoscrd ME,
		 bdicred:sd_maecredcrd MC
	WHERE MC.numcte =  cNUMCTE 
	AND MC.num_credito = ME.num_credito;

    LET mSaldo_credito3= mSaldo_credito + mSaldo_credito2;
	
	IF iTpo_cliente = 1 THEN
		SELECT FIRST 1 cuenta_tf
		INTO cNumero_cuenta
		FROM bditransfer:tf_maecte 
		WHERE numcte_tf = cNUMCTE
		AND status_cta <> '2';
	
	ELSE 
	
		SELECT FIRST 1 cuenta_tf
		INTO cNumero_cuenta
		FROM bditransfer:tf_maecte 
		WHERE numcte = cNUMCTE
		AND status_cta <> '2';
	
	END IF;

	/* 
		SELECT FIRST 1 cuenta_tf
		INTO cNumero_cuenta
		FROM bditransfer:tf_maecte 
		WHERE CASE WHEN iTpo_cliente = 1 THEN numcte_tf ELSE numcte END = cNUMCTE
		AND status_cta <> '2'; 

	*/
	
	
	
    SET ISOLATION TO DIRTY READ;
	FOREACH
	SELECT SUM(SALDO) 
	INTO mSaldo_vista  
	--RQM 09 704. Se agrega el campo saldo_sbc al calculo del saldo disponible. DHG 
	FROM (SELECT nvl(SUM(sdo_actual - (sdo_retenido + sdo_cong + imp_sbg_ccc + saldo_sbc)),0) AS SALDO
	FROM bdicheq:sc_maechq 
	WHERE num_cte = cNUMCTE
	UNION ALL
	SELECT SUM(sdo_cta) AS SALDO
	FROM bditransfer:tf_account_balance_customer
	WHERE cuenta = cNumero_cuenta
	AND fecha_proceso = (SELECT MAX(fecha_proceso) FROM bditransfer:tf_account_balance_customer WHERE cuenta = cNumero_cuenta))
	END FOREACH;
	
    SET ISOLATION TO DIRTY READ;
	SELECT nvl(SUM(capital),0) 
	INTO  mSaldo_plaza
	FROM  bdinvers:sv_maeinv 
	WHERE num_cte = cNUMCTE AND status_cta='1';

	RETURN
	cCodRet,mSaldo_vista,mSaldo_plaza,mSaldo_credito3;	
END
END PROCEDURE
DOCUMENT
"AutOR : Antonio Flores",
"FUNCIONAMIENTO:Este sp realizara el caluclo de los saldos generales por numero de cliente el saldo de credito, captacion e inversiones ",
"FECHA : 04-01-2012",
"BD    : bdinteg",
"VER   : 1.0",
'MODIFICO: Daniel Hernandez Garcia',
'FECHA: 10-06-2025',
'MODIFICACION: Se modifica la formula de calculo de saldo disponible para considerar un nuevo campo', 
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD: BDICHEQ',
'VERSION: 1.2';

CREATE PROCEDURE "informix".sp_cnsif_consprodctekiosko(cID_USUARIOC char(10),cNUMCTE CHAR(20),iTpo_cliente INTEGER)
				returning 
				CHAR(5)     AS Cod_Retorno;


DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;
--SISTEMA DE CUENTA 01 VARIABLES
DEFINE cIProducto_chequera	CHAR(1);
DEFINE cScuenta				CHAR(2);
DEFINE cNo_cuenta			CHAR(20);
DEFINE cNo_tarjeta			CHAR(20);
DEFINE cClave_producto		CHAR(4);
DEFINE cNombre_producto		CHAR(40);
DEFINE cCuenta_clabe		CHAR(18);
DEFINE dFecha_apertura		DATE;
DEFINE cStatus_tarjeta		CHAR(15);
DEFINE cStatus_cuenta		CHAR(60);
DEFINE dFecha_status		DATE;
DEFINE cClave_sucursal		CHAR(4);
DEFINE cEjecutivo 			CHAR(8);
DEFINE mSaldo_actual		MONEY(14,2);
DEFINE dFecha_aperturaO_inv DATE;
DEFINE dFecha_max			DATE;
DEFINE dFecha_min			DATE;
DEFINE cNumero_cuenta 		CHAR(20);
DEFINE dFecha 				DATE;
DEFINE iCont                INTEGER;
DEFINE iMaxSec              INTEGER;
DEFINE cCtaInv              CHAR(20);
DEFINE cDiaCorte            SMALLINT;
DEFINE dFecha_cancelacion	DATE;
--DEFINE iTpo_cliente			INT;
DEFINE cNumCtePrincipal 	CHAR(20);
DEFINE cNumCteTf			CHAR(20);
DEFINE cStatus				CHAR(50);
DEFINE cProdDebito			CHAR(200);
DEFINE cProdCredito			CHAR(200);
DEFINE cQuery CHAR(1500);


--inicializando variables
LET  iexiste = 0;
LET cCodRet = "00000";
LET iSql_err = 0 ;
--SISTEMA DE CUENTA 01 VARIABLES
LET cIProducto_chequera	 = "";
LET cScuenta		 = "";
LET cNo_cuenta		 = "";
LET cNo_tarjeta			 = "";
LET cClave_producto		 = "";
LET cNombre_producto		 = "";
LET cCuenta_clabe		 = "";
LET dFecha_apertura		 = "";
LET cStatus_tarjeta		 = "";
LET cStatus_cuenta		 = "";
LET dFecha_status		 = "";
LET cClave_sucursal		 = "";
LET cEjecutivo 			 = "";
LET mSaldo_actual		= 0;
LET dFecha_aperturaO_inv = "";
LET dFecha_max			="";
LET dFecha_min			="";
LET cNumero_cuenta 	= "" ;
LET iCont=0;
LET iMaxSec=0;
LET cCtaInv='';
LET cDiaCorte           =0;
LET dFecha_cancelacion = "";
--LET iTpo_cliente=0;
LET cNumCteTf = "";
LET cNumCtePrincipal = "";
LET cStatus = "";
LET cProdDebito = "";
LET cProdCredito = "";
LET cQuery = '';

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
   --SET DEBUG FILE TO "/home/c90402536/Traza/sp_cnsif_consprodctekiosko_modif.out";
   --TRACE ON; 
    
	
	SET ISOLATION TO DIRTY READ;
	
	SELECT valor
	INTO cStatus
	FROM si_param
	WHERE cod_param = 338;
	
	SELECT valor
	INTO cProdDebito
	FROM si_param
	WHERE cod_param = 339;
	
	SELECT valor
	INTO cProdCredito
	FROM si_param
	WHERE cod_param = 340;
	
	select first 1 NVL(COUNT(cuenta),0)  into iexiste FROM bdicheq:sc_maechq WHERE num_cte = cNUMCTE;
	IF iexiste = 0 THEN 
		FOREACH
			SELECT LIMIT 1 NVL(COUNT(num_credito),0) AS cant  INTO iexiste FROM bdicred:"informix".sd_maecred WHERE numcte = cNUMCTE
			UNION
			SELECT NVL(COUNT(num_credito),0) AS cant FROM bdicred:"informix".sd_maecredcrd WHERE numcte = cNUMCTE ORDER BY CANT DESC
		END FOREACH;
		IF iexiste = 0 THEN 
			LET cCodRet = "00024";
			RETURN cCodRet;
		END IF;
	END IF;	

	LET cQuery = "SELECT cuenta FROM bdicheq:sc_maechq WHERE num_cte = '"||TRIM(cNUMCTE)||"' AND status_cta NOT IN ("||TRIM(cStatus)||")";
	LET cQuery = TRIM(cQuery)||" AND producto IN ("||TRIM(cProdDebito)||") ORDER BY cuenta";
	
	DELETE {+INDEX (bdinteg:si_tempoctas idx_tempoctas)} from "informix".si_tempoctas WHERE numcte = cNUMCTE AND ejecutivosif= cID_USUARIOC;
	SET ISOLATION TO DIRTY READ;
	PREPARE stmtId FROM TRIM(cQuery);
	DECLARE custCur CURSOR FOR stmtId;
	OPEN custCur;
	FETCH custCur INTO cNumero_cuenta;
	WHILE(SQLCODE == 0)
		--RQM 09 704. Se agrega el campo saldo_sbc al calculo del saldo disponible. DFTL 
		SELECT DECODE(MC.producto,"2200","S","1900","S","N"),'01',cNumero_cuenta, MC.producto,PR.nombre, MC.cuenta_clabe,UPPER(ES.descripcion),
		MC.fec_cancelac, MC.sucursal,MC.sdo_actual - (MC.sdo_retenido + MC.sdo_cong + MC.imp_sbg_ccc + MC.saldo_sbc)AS SALDO 
		INTO cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,cCuenta_clabe,cStatus_cuenta, dFecha_status,cClave_sucursal,
		mSaldo_actual
		FROM bdicheq:"informix".sc_maechq MC,
		bdicheq:"informix".sc_producto PR,
		bdicheq:"informix".sc_mae_estatus ES
		WHERE MC.cuenta = cNumero_cuenta 
		AND	PR.producto = MC.producto
		AND MC.status_cta = ES.cod_estatus;

		SELECT fecha_alta, ejecutivo
		INTO dFecha_apertura,cEjecutivo
		FROM bdicheq:"informix".sc_maenoc
		WHERE cuenta =cNumero_cuenta;
			
		SELECT num_tarjeta
		INTO cNo_tarjeta
		FROM  bdicheq:"informix".sc_tarjeta
		WHERE cuenta = cNumero_cuenta
		AND numcte = cNUMCTE
		AND tipo_tarjeta='T' AND secuencia IN (SELECT max(secuencia) FROM  bdicheq:"informix".sc_tarjeta
		WHERE cuenta = cNumero_cuenta
		AND numcte = cNUMCTE
		AND tipo_tarjeta='T');

		SELECT LIMIT 1 {+INDEX (intercard:tarjeta idx_numcte)} NVL(UPPER(B.descstatustarjeta),"") INTO cStatus_tarjeta FROM intercard:tarjeta A
		LEFT JOIN intercard:statustarjeta B
		ON A.codstatustarjeta = B.codstatustarjeta
		WHERE A.numcliente= cNUMCTE
		AND A.numtarjeta= cNo_tarjeta;

		IF cClave_producto='1100' THEN
			SELECT fec_ult_mov INTO dFecha_status FROM bdicheq:"informix".sc_maechq WHERE cuenta = cNumero_cuenta AND empresa='001' and status_cta='2';
		END IF;

		LET cDiaCorte=SUBSTR(dFecha_apertura,4,2); 
		
		INSERT INTO "informix".si_tempoctas (codret,producto_chequera,scuenta,no_cuenta,clave_producto,nombre_producto,fecha_apertura,status_cuenta,
		fecha_status,clave_sucursal,ejecutivo,saldo_actual,no_tarjeta,status_tarjeta,cuenta_clabe,fecha_apertura_inv,numcte,ejecutivosif,dia_corte) 
		values (cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
		cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cNUMCTE,cID_USUARIOC,cDiaCorte);
		
		FETCH custCur INTO cNumero_cuenta;
	END WHILE;
	CLOSE custCur;
	FREE custCur;
	FREE stmtId;

	LET cQuery = "SELECT num_credito FROM bdicred:sd_maecred WHERE numcte = '"||TRIM(cNUMCTE)||"' AND num_producto IN ("||TRIM(cProdCredito)||")";
	LET cQuery = TRIM(cQuery)||" UNION SELECT num_credito FROM bdicred:sd_maecredcrd WHERE numcte = '"||TRIM(cNUMCTE)||"' AND";
	LET cQuery = TRIM(cQuery)||" num_producto IN ("||TRIM(cProdCredito)||") order by num_credito";
	
	SET ISOLATION TO DIRTY READ;
	PREPARE stmtId FROM TRIM(cQuery);
	DECLARE custCur CURSOR FOR stmtId;
	OPEN custCur;
	FETCH custCur INTO cNumero_cuenta;
	WHILE(SQLCODE == 0)
		SET ISOLATION TO DIRTY READ;
		SELECT MAX(fecha) INTO dFecha FROM bdicred:"informix".sd_bitacorabloqueocta WHERE cuenta = cNumero_cuenta;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH
		SELECT 'N','06',MC.num_credito, MC.num_producto,DE.nombre_prod,MC.fecha_apertura,
		TC.descripcion,	MC.sucursal,MC.ejecutivo, dFecha
		INTO cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,
		cStatus_cuenta,cClave_sucursal,cEjecutivo,dFecha_status
		FROM bdicred:"informix".sd_maecred MC,
		bdicred:"informix".sd_tipocartera TC,
		bdicred:"informix".sd_definicion DE
		WHERE MC. num_credito  = cNumero_cuenta 
		AND	DE.num_producto = MC.num_producto
		AND MC.status_cred = TC.status_cred
		UNION
		SELECT 'N','06',MC.num_credito, MC.num_producto,DE.nombre_prod,MC.fecha_apertura,
		TC.descripcion,	MC.sucursal,MC.ejecutivo, dFecha
		FROM bdicred:"informix".sd_maecredcrd MC,
		bdicred:"informix".sd_tipocartera TC,
		bdicred:"informix".sd_definicion DE
		WHERE MC. num_credito  = cNumero_cuenta 
		AND	DE.num_producto = MC.num_producto
		AND MC.status_cred = TC.status_cred
		END FOREACH;

		SET ISOLATION TO DIRTY READ;
		FOREACH
		SELECT sdo_cap_insoluto as Saldo
		INTO mSaldo_actual
		FROM bdicred:"informix".sd_maesdos
		WHERE num_credito =cNumero_cuenta
		UNION
		SELECT sdo_cap_insoluto AS Saldo
		FROM bdicred:"informix".sd_maesdoscrd
		WHERE num_credito =cNumero_cuenta
		END FOREACH;
		
		SET ISOLATION TO DIRTY READ;
		SELECT num_tarjeta
		INTO cNo_tarjeta
		FROM bdicred:"informix".sd_tarjeta 
		WHERE num_credito = cNumero_cuenta
		AND tipo_tarjeta='T' AND SECUENCIA IN (SELECT max(secuencia) FROM bdicred:"informix".sd_tarjeta
		WHERE num_credito = cNumero_cuenta
		AND numcte = cNUMCTE
		AND tipo_tarjeta='T');

		SELECT LIMIT 1 {+INDEX (intercard:tarjeta idx_numcte)} NVL(UPPER(B.descstatustarjeta),"") INTO cStatus_tarjeta FROM intercard:tarjeta A
		LEFT JOIN intercard:statustarjeta B
		ON A.codstatustarjeta = B.codstatustarjeta
		WHERE A.numcliente= cNUMCTE
		AND A.numtarjeta= cNo_tarjeta;

		IF cClave_producto IN ('6001','6600','7000') THEN
			SELECT dia_cuota
			INTO cDiaCorte
			FROM bdicred:sd_definicion
			WHERE num_producto = cClave_producto; 
		ELIF cClave_producto='6300' THEN    
			LET cDiaCorte=SUBSTR(dFecha_apertura,4,2); 
		ELIF cClave_producto='6400' THEN    
			LET cDiaCorte='20'; 
		ELIF cClave_producto='6011' THEN    
			LET cDiaCorte=SUBSTR(dFecha_apertura,4,2); 
			IF cDiaCorte>=3 AND cDiaCorte<17 THEN
				LET cDiaCorte=2;
			ELIF cDiaCorte IN (1,2) OR cDiaCorte>=17 THEN
				LET cDiaCorte=17;
			ELSE
				LET cDiaCorte=0;
			END IF;
		END IF;

		INSERT INTO "informix".si_tempoctas (codret,producto_chequera,scuenta,no_cuenta,clave_producto,nombre_producto,fecha_apertura,status_cuenta,
		fecha_status,clave_sucursal,ejecutivo,saldo_actual,no_tarjeta,status_tarjeta,cuenta_clabe,fecha_apertura_inv,numcte,ejecutivosif,dia_corte) 
		values (cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
		cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cNUMCTE,cID_USUARIOC,cDiaCorte);

		FETCH custCur INTO cNumero_cuenta;

	END WHILE;
	CLOSE custCur;
	FREE custCur;
	FREE stmtId;
	RETURN cCodRet;
END
END PROCEDURE
DOCUMENT
"AUTOR : Cesar Velazquez",
"FUNCIONAMIENTO:Este sp realizara la busqueda de cuentas que se presentaran en KIOSKO",
"FECHA : 06-04-2015",
"BD    : bdinteg",
"VER   : 1.0",
'MODIFICADO:            Donovan F. Torres Landeros',
'ULTIMA MODIFICACION:   2025/07/01',
'RAZON:                 Se agrega la nueva variable saldo_sbc (inmovilizacion por concepto de credito)',
'                       a la operacion aritmetica para el nuevo calculo de',
'                       saldo disponible.',
'PROYECTO:              RQM 09 704   Cobranza Automatica en cuentas de captacion',
'BD:                    bdinteg',
'VER:                   1.2';

CREATE PROCEDURE "informix".sp_cnsif_consprodcte_aclaraciones(cID_USUARIOC char(10),cID_FUNCIONC CHAR(10),cNUMCTE CHAR(20),cSISTEMACUENTA CHAR(2),pNumRegistro INTEGER,pRecuperacion INTEGER)
				returning 
				CHAR(5)     AS Cod_Retorno,
				CHAR(1)     AS Producto,
				CHAR(2)     AS Sistema_Cuenta,
				CHAR(20)    AS Numero_Cuenta,
				CHAR(4)     AS Cve_Producto,
				CHAR(40)    AS Nombre_Producto,
				DATE        AS Fecha_Apertura,
				CHAR(60)    AS Status_Cuenta,
				DATE        AS Fecha_Status,
				CHAR(4)     AS Clave_Sucursal,
				CHAR(8)     AS Ejecutivo,
				MONEY(14,2) AS Saldo_Actual,
                CHAR(20)    AS Numero_Tarjeta,
				CHAR(15)    AS Status_Tarjeta,
				CHAR(18)    AS Cuenta_CLABE,
				DATE        AS Fecha_Apertura_Inversion,
				DATE		AS Fecha_Cancelacion,
				CHAR(2)     AS Cod_Status_Cta;


DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;
--SISTEMA DE CUENTA 01 VARIABLES
DEFINE cIProducto_chequera	CHAR(1);
DEFINE cScuenta				CHAR(2);
DEFINE cNo_cuenta			CHAR(20);
DEFINE cNo_tarjeta			CHAR(20);
DEFINE cClave_producto		CHAR(4);
DEFINE cNombre_producto		CHAR(40);
DEFINE cCuenta_clabe		CHAR(18);
DEFINE dFecha_apertura		DATE;
DEFINE cStatus_tarjeta		CHAR(15);
DEFINE cStatus_cuenta		CHAR(60);
DEFINE dFecha_status		DATE;
DEFINE cClave_sucursal		CHAR(4);
DEFINE cEjecutivo 			CHAR(8);
DEFINE mSaldo_actual		MONEY(14,2);
DEFINE dFecha_aperturaO_inv DATE;
DEFINE dFechaCancelacion	DATE;
DEFINE dFecha_max			DATE;
DEFINE dFecha_min			DATE;
DEFINE cNumero_cuenta 		CHAR(20);
DEFINE dFecha 				DATE;
DEFINE iCont                INTEGER;
DEFINE iMaxSec              INTEGER;
DEFINE cCtaInv              CHAR(20);
DEFINE iTpo_cliente			INT;
DEFINE cNumCtePrincipal CHAR(20);
DEFINE cNumCteTf			CHAR(20);
DEFINE cIdStatusCuenta      CHAR(2);

--inicializando variables
LET  iexiste = 0;
LET cCodRet = "00000";
LET iSql_err = 0 ;
--SISTEMA DE CUENTA 01 VARIABLES
LET cIProducto_chequera	 = "";
LET cScuenta		 = "";
LET cNo_cuenta		 = "";
LET cNo_tarjeta			 = "";
LET cClave_producto		 = "";
LET cNombre_producto		 = "";
LET cCuenta_clabe		 = "";
LET dFecha_apertura		 = "";
LET dFechaCancelacion	 = "";
LET cStatus_tarjeta		 = "";
LET cStatus_cuenta		 = "";
LET dFecha_status		 = "";
LET cClave_sucursal		 = "";
LET cEjecutivo 			 = "";
LET mSaldo_actual		= 0;
LET dFecha_aperturaO_inv = "";
LET dFecha_max			="";
LET dFecha_min			="";
LET cNumero_cuenta 	= "" ;
LET iCont=0;
LET iMaxSec=0;
LET cCtaInv='';
LET iTpo_cliente=0;
LET cNumCtePrincipal = "";
LET cNumCteTf="";
LET cIdStatusCuenta = "";


    BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN
			cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cNo_tarjeta,cClave_producto,cNombre_producto,cCuenta_clabe,dFecha_apertura,
			cStatus_tarjeta,cStatus_cuenta,dFecha_status,cClave_sucursal,cEjecutivo,mSaldo_actual,dFecha_aperturaO_inv,dFechaCancelacion,cIdStatusCuenta;
		END IF;
	END EXCEPTION;
            --SET DEBUG FILE TO "/home/c90402536/Traza/sp_cnsif_consprodcte_aclaraciones_modif.out";
            --TRACE ON; 
	IF 	cID_USUARIOC = '' OR
		cID_FUNCIONC = '' OR
		cNUMCTE  = ''	  OR
		cSISTEMACUENTA = '' THEN
		LET cCodRet = "00036";
		RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
        cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,dFechaCancelacion,cIdStatusCuenta;

	END IF;
	IF cSISTEMACUENTA <> '01' AND cSISTEMACUENTA <> '06'  AND cSISTEMACUENTA <> '03' AND cSISTEMACUENTA <> '00'  THEN
		LET cCodRet = "00037";
		RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
        cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,dFechaCancelacion,cIdStatusCuenta;
	END IF;

    IF pNumRegistro<0 THEN
        LET cCodRet='00098';
		RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
        cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,dFechaCancelacion,cIdStatusCuenta;				
    ELSE
        IF pRecuperacion<=0 THEN
            LET cCodRet='00098';
            RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,dFechaCancelacion,cIdStatusCuenta;
        END IF;
    END IF;    	
	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCTE,cSISTEMACUENTA,'2')
	INTO
	cCodRet;
	IF (cCodRet != '00000')  THEN
		RETURN 
		cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cNo_tarjeta,cClave_producto,cNombre_producto,cCuenta_clabe,dFecha_apertura,
		cStatus_tarjeta,cStatus_cuenta,dFecha_status,cClave_sucursal,cEjecutivo,mSaldo_actual,dFecha_aperturaO_inv,dFechaCancelacion,cIdStatusCuenta;
	END IF;
	-- TERMINA VALIDACION	
	
--TRANSFER
	EXECUTE PROCEDURE bdicnweb:"informix".sp_validacte_transfer(cNUMCTE) INTO cCodRet,iTpo_cliente,cNumCtePrincipal;
	IF cNumCtePrincipal IS NOT NULL THEN
		LET cNUMCTE = cNumCtePrincipal;
	END IF;
--TRANSFER	

	IF cSISTEMACUENTA = '01' THEN
--TRANSFER
		FOREACH
		select FIRST 1 NVL(COUNT(cuenta),0)  INTO iexiste FROM bdicheq:"informix".sc_maechq WHERE num_cte = cNUMCTE
		UNION
		select NVL(COUNT(cuenta_tf),0) FROM bditransfer:"informix".tf_maecte WHERE CASE WHEN iTpo_cliente = 1 THEN numcte_tf ELSE numcte END = cNUMCTE
		order by 1 desc
		END FOREACH;
--TRANSFER
		IF iexiste = 0 THEN 
			LET cCodRet = "00024";
			RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,dFechaCancelacion,cIdStatusCuenta;
		END IF;	

		SET ISOLATION TO DIRTY READ;
		FOREACH
            SELECT SKIP pNumRegistro FIRST pRecuperacion a.cuenta,b.num_tarjeta,DECODE(b.status_tar,"A","ACTIVA","C","CANCELADA","")
            INTO cNumero_cuenta,cNo_tarjeta,cStatus_tarjeta
            FROM bdicheq:"informix".sc_maechq a
            LEFT JOIN bdicheq:"informix".sc_tarjeta b
            ON b.cuenta= a.cuenta
            WHERE a.num_cte = cNUMCTE ORDER BY a.cuenta
--TRANSFER
			FOREACH
			--RQM 09 704. Se agrega el campo saldo_sbc al calculo del saldo disponible. DFTL 
			SELECT DECODE(MC.producto,"2200","S","1900","S","N"),cSISTEMACUENTA,cNumero_cuenta, MC.producto,PR.nombre,
			MC.cuenta_clabe,DECODE(MC.status_cta,"1","ACTIVA","2","CANCELADA","3","BLOQUEADA","4","INACTIVA","5","INFORMADA","6","CONCENTRADA","7","BENEFICIENCIA","8","DESCONCENTRADA"),
			MC.fec_cancelac, MC.sucursal,MC.sdo_actual - (MC.sdo_retenido + MC.sdo_cong + MC.imp_sbg_ccc + MC.saldo_sbc)AS SALDO,MC.status_cta
			INTO cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,cCuenta_clabe,cStatus_cuenta,
			dFecha_status,cClave_sucursal,mSaldo_actual,cIdStatusCuenta
			FROM bdicheq:"informix".sc_maechq MC,
			bdicheq:"informix".sc_producto PR
			WHERE MC.cuenta = cNumero_cuenta AND
			PR.producto = MC.producto
			UNION
			SELECT "N","01",cNumero_cuenta, MC.producto,PR.nombre,
			MC.cta_clabe,DECODE(MC.status_cta,"1","ACTIVA","2","CANCELADA","3","BLOQUEADA","4","INACTIVA","5","INFORMADA","6","CONCENTRADA","7","BENEFICIENCIA","8","DESCONCENTRADA"),
			MC.fec_cancelac, '',SDO.sdo_cta AS SALDO,MC.status_cta
			FROM bditransfer:"informix".tf_maecte MC,
			bdicheq:"informix".sc_producto PR, bditransfer:tf_account_balance_customer SDO
			WHERE MC.cuenta_tf = cNumero_cuenta AND
			PR.producto = MC.producto AND
			MC.cuenta_tf = SDO.cuenta
			END FOREACH;
--TRANSFER			
--TRANSFER
			FOREACH
			SELECT fecha_alta, ejecutivo
			INTO dFecha_apertura,cEjecutivo
			FROM bdicheq:"informix".sc_maenoc
			WHERE cuenta =cNumero_cuenta
			UNION
			SELECT fec_alta, ''
			FROM bditransfer:"informix".tf_maecte
			WHERE cuenta_tf =cNumero_cuenta
			END FOREACH;
--TRANSFER
--TRANSFER
			SELECT numcte_tf, fec_cancelac
			INTO cNumCteTf, dFechaCancelacion
			FROM bditransfer:"informix".tf_maecte
			WHERE cuenta_tf = cNumero_cuenta;
			
			IF cNumCteTf IS NOT NULL THEN
				LET cNUMCTE = cNumCteTf;
			END IF;
--TRANSFER			
/*
			SELECT num_tarjeta,DECODE(status_tar,"A","ACTIVA","C","CANCELADA","DESCONOCIDO")
			INTO cNo_tarjeta,cStatus_tarjeta
			FROM  bdicheq:sc_tarjeta
			WHERE cuenta = cNumero_cuenta
			AND numcte = cNUMCTE
			AND status_tar = 'A' AND tipo_tarjeta='T'; */
			
			LET iCont=iCont+1;	
			
			-- FECHA DE CANCELACION
			IF cNumCteTf IS NULL THEN
				EXECUTE PROCEDURE sp_consultafechacancelacioncta(cNo_cuenta, cScuenta) INTO cCodRet, dFechaCancelacion;
			END IF;
			
			RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,dFechaCancelacion,cIdStatusCuenta WITH resume;
		END FOREACH;
        IF iCont = 0 THEN
            DELETE {+INDEX (bdinteg:si_tempoctas idx_tempoctas)} FROM "informix".si_tempoctas WHERE numcte = cNUMCTE AND ejecutivosif= cID_USUARIOC;
            LET cCodRet = '1001'; 
			RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,dFechaCancelacion,cIdStatusCuenta;
        END IF 
	ELIF cSISTEMACUENTA = '03' THEN
		SELECT NVL(COUNT(cuenta),0)  INTO iexiste FROM bdinvers:"informix".sv_maeinv WHERE num_cte = cNUMCTE;
		
		IF iexiste = 0 THEN 
			LET cCodRet = "00024";
			RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,dFechaCancelacion,cIdStatusCuenta;
		END IF;	

		SET ISOLATION TO DIRTY READ;
		FOREACH
            SELECT SKIP pNumRegistro FIRST pRecuperacion DISTINCT cuenta INTO cCtaInv FROM bdinvers:"informix".sv_maeinv
            WHERE num_cte=cNUMCTE ORDER BY cuenta

			SELECT NVL(MAX(secuencia),0) INTO iMaxSec FROM bdinvers:"informix".sv_maeinv WHERE CUENTA=cCtaInv;

			SELECT {+INDEX (bdinvers:sv_instrum idx_instrum)} 'N',cSISTEMACUENTA,MI.cuenta,MI.cod_instrum,IT.nombre,MI.fecha_alta,
			DECODE(MI.status_cta,"1","ACTIVA","2","CANCELADA","4","REINVERSION"),
            MI.adicionado,DECODE(MI.status_cta,"2",0,MI.capital),MI.sucursal,MI.fec_cancelac,MI.status_cta
			--MI.adicionado,MI.capital,MI.sucursal,MI.fec_cancelac
			INTO cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,cEjecutivo,
			mSaldo_actual,cClave_sucursal,dFecha_status,cIdStatusCuenta
			FROM bdinvers:"informix".sv_maeinv MI,
			bdinvers:"informix".sv_instrum IT
			WHERE MI.num_cte = cNUMCTE  AND IT.cod_instrum  = MI.cod_instrum
            AND MI.cuenta=cCtaInv
            and secuencia = iMaxSec;

            SELECT MIN(fecha_alta) INTO dFecha_aperturaO_inv FROM bdinvers:"informix".sv_maeinv WHERE num_cte = cNUMCTE and cuenta=cNo_cuenta;

            LET iCont=iCont+1;
			
			-- FECHA DE CANCELACION
			EXECUTE PROCEDURE "informix".sp_consultafechacancelacioncta(cNo_cuenta, cScuenta) INTO cCodRet, dFechaCancelacion;
			
			RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,dFechaCancelacion,cIdStatusCuenta WITH resume;
		END FOREACH;
        IF iCont = 0 THEN
            DELETE {+INDEX (bdinteg:si_tempoctas idx_tempoctas)} from "informix".si_tempoctas WHERE numcte = cNUMCTE AND ejecutivosif= cID_USUARIOC;
			
            LET cCodRet = '1001'; 
			RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,dFechaCancelacion,cIdStatusCuenta;
        END IF 	
	ELIF cSISTEMACUENTA = '06' THEN
    IF pNumRegistro=0 THEN
        DELETE {+INDEX (bdinteg:si_tempoctas idx_tempoctas)} FROM si_tempoctas WHERE numcte = cNUMCTE AND ejecutivosif= cID_USUARIOC;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH
            SELECT LIMIT 1 NVL(COUNT(num_credito),0) AS cant  INTO iexiste FROM bdicred:"informix".sd_maecred WHERE numcte = cNUMCTE
            UNION
            SELECT NVL(COUNT(num_credito),0) as cant FROM bdicred:"informix".sd_maecredcrd WHERE numcte = cNUMCTE ORDER BY CANT DESC
        END FOREACH;
		IF iexiste = 0 THEN 
			LET cCodRet = "00024";
			RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,dFechaCancelacion,cIdStatusCuenta;
		END IF;	

		SET ISOLATION TO DIRTY READ;
		FOREACH

            SELECT a.num_credito,b.num_tarjeta,DECODE(b.status_tar,"A","ACTIVA","C","CANCELADA","")
            INTO cNumero_cuenta,cNo_tarjeta,cStatus_tarjeta
            FROM bdicred:"informix".sd_maecred a
            LEFT JOIN bdicred:"informix".sd_tarjeta b
            ON b.num_credito= a.num_credito
            WHERE a.numcte = cNUMCTE ORDER BY a.num_credito

			/*SELECT num_credito into cNumero_cuenta
			FROM bdicred:sd_maecred
			WHERE numcte = cNUMCTE order by num_credito*/

			SELECT  MAX(fecha) INTO dFecha FROM bdicred:"informix".sd_bitacorabloqueocta WHERE cuenta = cNumero_cuenta;
			
			SELECT 'N',cSISTEMACUENTA,MC.num_credito, MC.num_producto,DE.nombre_prod,MC.fecha_apertura,
			TC.descripcion,	MC.sucursal,MC.ejecutivo, dFecha, TC.status_cred
			INTO cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,
			cStatus_cuenta,cClave_sucursal,cEjecutivo,dFecha_status,cIdStatusCuenta
			FROM bdicred:"informix".sd_maecred MC,
			bdicred:"informix".sd_tipocartera TC,
			bdicred:"informix".sd_definicion DE
			WHERE MC. num_credito  = cNumero_cuenta 
			AND	DE.num_producto = MC.num_producto
			AND MC.status_cred = TC.status_cred;

			SELECT sdo_cap_insoluto + sdo_exig_int + sdo_no_exig + sdo_moratorio as Saldo
			INTO mSaldo_actual
			FROM bdicred:"informix".sd_maesdos
			WHERE num_credito =cNumero_cuenta;

			/*SELECT num_tarjeta,DECODE(status_tar,"A","ACTIVA","C","CANCELADA","DESCONOCIDO")
			INTO cNo_tarjeta,cStatus_tarjeta
			FROM bdicred:sd_tarjeta TA
			WHERE TA.num_credito = cNumero_cuenta
			AND TA.status_tar ='A' AND tipo_tarjeta='T';*/

            INSERT INTO "informix".si_tempoctas (codret,producto_chequera,scuenta,no_cuenta,clave_producto,nombre_producto,fecha_apertura,status_cuenta,
            fecha_status,clave_sucursal,ejecutivo,saldo_actual,no_tarjeta,status_tarjeta,cuenta_clabe,fecha_apertura_inv,numcte,ejecutivosif,cod_statuscta) 
			values (cCodRet,cIProducto_chequera,
            cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cNUMCTE,cID_USUARIOC,cIdStatusCuenta);
		END FOREACH;

		SET ISOLATION TO DIRTY READ;
		FOREACH
			/*SELECT num_credito into cNumero_cuenta
			FROM bdicred:sd_maecredcrd
			WHERE numcte = cNUMCTE order by num_credito*/

            SELECT a.num_credito,b.num_tarjeta,DECODE(b.status_tar,"A","ACTIVA","C","CANCELADA","")
            INTO cNumero_cuenta,cNo_tarjeta,cStatus_tarjeta
            FROM bdicred:"informix".sd_maecredcrd a
            LEFT JOIN bdicred:"informix".sd_tarjeta b
            ON b.num_credito= a.num_credito
            WHERE a.numcte = cNUMCTE ORDER BY a.num_credito

			SELECT  MAX(fecha) INTO dFecha FROM bdicred:"informix".sd_bitacorabloqueocta WHERE cuenta = cNumero_cuenta;
					
			SELECT 'N',cSISTEMACUENTA,MC.num_credito, MC.num_producto,DE.nombre_prod,MC.fecha_apertura,
			TC.descripcion,	MC.sucursal,MC.ejecutivo, dFecha,TC.status_cred
			INTO cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,
			cStatus_cuenta,cClave_sucursal,cEjecutivo,dFecha_status,cIdStatusCuenta
			FROM bdicred:"informix".sd_maecredcrd MC,
			bdicred:"informix".sd_tipocartera TC,
			bdicred:"informix".sd_definicion DE
			WHERE MC. num_credito  = cNumero_cuenta 
			AND	DE.num_producto = MC.num_producto
			AND MC.status_cred = TC.status_cred;

			SELECT sdo_cap_insoluto + sdo_exig_int + sdo_no_exig + sdo_moratorio as Saldo
			INTO mSaldo_actual
			FROM bdicred:"informix".sd_maesdoscrd
			WHERE num_credito =cNumero_cuenta;

			/*SELECT num_tarjeta,DECODE(status_tar,"A","ACTIVA","C","CANCELADA","DESCONOCIDO")
			INTO cNo_tarjeta,cStatus_tarjeta
			FROM bdicred:sd_tarjeta TA
			WHERE TA.num_credito = cNumero_cuenta
			AND TA.status_tar ='A' AND tipo_tarjeta='T';*/

            INSERT INTO "informix".si_tempoctas (codret,producto_chequera,scuenta,no_cuenta,clave_producto,nombre_producto,fecha_apertura,status_cuenta,
            fecha_status,clave_sucursal,ejecutivo,saldo_actual,no_tarjeta,status_tarjeta,cuenta_clabe,fecha_apertura_inv,numcte,ejecutivosif,cod_statuscta) values (cCodRet,cIProducto_chequera,
            cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cNUMCTE,cID_USUARIOC,cIdStatusCuenta);
		END FOREACH;
      END IF;  
        SET ISOLATION TO DIRTY READ;
        FOREACH
            SELECT {+INDEX (bdinteg:si_tempoctas idx_tempoctas)} SKIP pNumRegistro FIRST pRecuperacion codret,producto_chequera,scuenta,no_cuenta,clave_producto,nombre_producto,fecha_apertura,nvl(status_cuenta,''),
                        fecha_status,clave_sucursal,ejecutivo,saldo_actual,nvl(no_tarjeta,''),nvl(status_tarjeta,''),cuenta_clabe,fecha_apertura_inv,cod_statuscta 
						into cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
                        cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cIdStatusCuenta
            FROM "informix".si_tempoctas
            WHERE numcte = cNUMCTE AND ejecutivosif= cID_USUARIOC ORDER BY scuenta,no_cuenta 
            
            LET iCont=iCont+1;
			
			-- FECHA DE CANCELACION
			EXECUTE PROCEDURE "informix".sp_consultafechacancelacioncta(cNo_cuenta, cScuenta) INTO cCodRet, dFechaCancelacion;

            RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,dFechaCancelacion,cIdStatusCuenta WITH resume;
        END FOREACH;
        IF iCont = 0 THEN
            DELETE {+INDEX (bdinteg:si_tempoctas idx_tempoctas)} from "informix".si_tempoctas WHERE numcte = cNUMCTE AND ejecutivosif= cID_USUARIOC;
			
            LET cCodRet = '1001'; 
			RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,dFechaCancelacion,cIdStatusCuenta;
        END IF 	
	ELIF cSISTEMACUENTA = '00' THEN
--TRANSFER
		FOREACH
		select FIRST 1 NVL(COUNT(cuenta),0)  into iexiste FROM bdicheq:"informix".sc_maechq WHERE num_cte = cNUMCTE
		UNION
		select NVL(COUNT(cuenta_tf),0)  FROM bditransfer:"informix".tf_maecte WHERE CASE WHEN iTpo_cliente = 1 THEN numcte_tf ELSE numcte END = cNUMCTE
		ORDER BY 1 DESC
		END FOREACH;
--TRANSFER		
		
		IF iexiste = 0 THEN 
			SET ISOLATION TO DIRTY READ;
            FOREACH
                SELECT LIMIT 1 NVL(COUNT(num_credito),0) AS cant  INTO iexiste FROM bdicred:"informix".sd_maecred WHERE numcte = cNUMCTE
                UNION
                SELECT NVL(COUNT(num_credito),0) AS cant FROM bdicred:"informix".sd_maecredcrd WHERE numcte = cNUMCTE ORDER BY CANT DESC
            END FOREACH;
            IF iexiste = 0 THEN 
                SELECT nvl(COUNT(cuenta),0)  INTO iexiste FROM bdinvers:"informix".sv_maeinv WHERE num_cte = cNUMCTE;
				
                IF iexiste = 0 THEN 
                    LET cCodRet = "00024";
                    RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
                    cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,dFechaCancelacion,cIdStatusCuenta;
                END IF;
            END IF;
		END IF;	
    
        IF pNumRegistro=0 THEN
                DELETE {+INDEX (bdinteg:si_tempoctas idx_tempoctas)} from "informix".si_tempoctas WHERE numcte = cNUMCTE AND ejecutivosif= cID_USUARIOC;
				
                SET ISOLATION TO DIRTY READ;
                FOREACH

                    SELECT a.cuenta,b.num_tarjeta,DECODE(b.status_tar,"A","ACTIVA","C","CANCELADA","")
                    INTO cNumero_cuenta,cNo_tarjeta,cStatus_tarjeta
                    FROM bdicheq:"informix".sc_maechq a
                    LEFT JOIN bdicheq:"informix".sc_tarjeta b
                    ON b.cuenta= a.cuenta
                    WHERE a.num_cte = cNUMCTE 
				    UNION
	                SELECT a.cuenta_tf,b.num_tarjeta,DECODE(b.status_tar,"A","ACTIVA","C","CANCELADA","")
                    FROM bditransfer:"informix".tf_maecte a
                    LEFT JOIN bdicheq:"informix".sc_tarjeta b
                    ON b.cuenta = a.cuenta_tf
                    WHERE CASE WHEN iTpo_cliente = 1 THEN a.numcte_tf ELSE a.numcte END = cNUMCTE
					ORDER BY 1

--TRANSFER
                   /* SELECT cuenta into cNumero_cuenta
                    FROM bdicheq:sc_maechq
                    WHERE num_cte = cNUMCTE order by cuenta*/
                    FOREACH
			        --RQM 09 704. Se agrega el campo saldo_sbc al calculo del saldo disponible. DFTL 

                    SELECT DECODE(MC.producto,"2200","S","1900","S","N"),'01',cNumero_cuenta, MC.producto,PR.nombre,
                    MC.cuenta_clabe,DECODE(MC.status_cta,"1","ACTIVA","2","CANCELADA","3","BLOQUEADA","4","CONGELADA","5","INFORMADA","6","CONCENTRADA","7","BENEFICIENCIA","8","DESCONCENTRADA"),
			        MC.fec_cancelac, MC.sucursal,MC.sdo_actual - (MC.sdo_retenido + MC.sdo_cong + MC.imp_sbg_ccc + MC.saldo_sbc)AS SALDO,MC.status_cta
			        INTO cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,cCuenta_clabe,cStatus_cuenta,
			        dFecha_status,cClave_sucursal,mSaldo_actual,cIdStatusCuenta
                    FROM bdicheq:"informix".sc_maechq MC,
                    bdicheq:"informix".sc_producto PR
                    WHERE MC.cuenta = cNumero_cuenta AND
                    PR.producto = MC.producto
					UNION
					SELECT "N","01",cNumero_cuenta, MC.producto,PR.nombre,
					MC.cta_clabe,DECODE(MC.status_cta,"1","ACTIVA","2","CANCELADA","3","BLOQUEADA","4","INACTIVA","5","INFORMADA","6","CONCENTRADA","7","BENEFICIENCIA","8","DESCONCENTRADA"),
					MC.fec_cancelac, '',SDO.sdo_cta AS SALDO,MC.status_cta
					FROM bditransfer:"informix".tf_maecte MC,
					bdicheq:"informix".sc_producto PR, bditransfer:tf_account_balance_customer SDO
					WHERE MC.cuenta_tf = cNumero_cuenta AND
					PR.producto = MC.producto AND
					MC.cuenta_tf = SDO.cuenta
					END FOREACH;

					FOREACH
                    SELECT fecha_alta, ejecutivo
                    INTO dFecha_apertura,cEjecutivo
                    FROM bdicheq:"informix".sc_maenoc
					WHERE cuenta =cNumero_cuenta
					UNION
					SELECT fec_alta, ''
					FROM bditransfer:"informix".tf_maecte
					WHERE cuenta_tf =cNumero_cuenta
					END FOREACH;
--TRANSFER

                    /*SELECT num_tarjeta,DECODE(status_tar,"A","ACTIVA","C","CANCELADA","DESCONOCIDO")
                    INTO cNo_tarjeta,cStatus_tarjeta
                    FROM  bdicheq:sc_tarjeta
                    WHERE cuenta = cNumero_cuenta
                    AND numcte = cNUMCTE
                    AND status_tar = 'A' AND tipo_tarjeta='T';*/

                    INSERT INTO "informix".si_tempoctas (codret,producto_chequera,scuenta,no_cuenta,clave_producto,nombre_producto,fecha_apertura,status_cuenta,
                    fecha_status,clave_sucursal,ejecutivo,saldo_actual,no_tarjeta,status_tarjeta,cuenta_clabe,fecha_apertura_inv,numcte,ejecutivosif,cod_statuscta) values (cCodRet,cIProducto_chequera,
                    cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
                    cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cNUMCTE,cID_USUARIOC, cIdStatusCuenta);
                END FOREACH;

                SET ISOLATION TO DIRTY READ;
                FOREACH

                    SELECT {+INDEX (bdinvers:sv_instrum idx_instrum)} 'N','03',MI.cuenta,MI.cod_instrum,IT.nombre,MI.fecha_alta,
                    DECODE(MI.status_cta,"1","ACTIVA","2","CANCELADA","4","REINVERSION"),
                    MI.adicionado,DECODE(MI.status_cta,"2",0,MI.capital),MI.sucursal,MI.fec_cancelac,MI.status_cta
                    --MI.adicionado,MI.capital,MI.sucursal,MI.fec_cancelac
                    INTO cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,cEjecutivo,
                    mSaldo_actual,cClave_sucursal,dFecha_status,cIdStatusCuenta
                    FROM bdinvers:"informix".sv_maeinv MI,
                    bdinvers:"informix".sv_instrum IT
                    WHERE MI.num_cte = cNUMCTE AND IT.cod_instrum  = MI.cod_instrum ORDER BY MI.cuenta

                    SELECT MIN(fecha_alta) INTO dFecha_aperturaO_inv FROM bdinvers:"informix".sv_maeinv WHERE num_cte = cNUMCTE and cuenta=cNo_cuenta;

                    INSERT INTO "informix".si_tempoctas (codret,producto_chequera,scuenta,no_cuenta,clave_producto,nombre_producto,fecha_apertura,status_cuenta,
                    fecha_status,clave_sucursal,ejecutivo,saldo_actual,no_tarjeta,status_tarjeta,cuenta_clabe,fecha_apertura_inv,numcte,ejecutivosif,cod_statuscta) values (cCodRet,cIProducto_chequera,
                    cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
                    cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cNUMCTE,cID_USUARIOC,cIdStatusCuenta);
                END FOREACH;

                SET ISOLATION TO DIRTY READ;
                FOREACH

                    SELECT a.num_credito,b.num_tarjeta,DECODE(b.status_tar,"A","ACTIVA","C","CANCELADA","")
                    INTO cNumero_cuenta,cNo_tarjeta,cStatus_tarjeta
                    FROM bdicred:"informix".sd_maecred a
                    LEFT JOIN bdicred:"informix".sd_tarjeta b
                    ON b.num_credito= a.num_credito
                    WHERE a.numcte = cNUMCTE ORDER BY a.num_credito

                    /*SELECT num_credito into cNumero_cuenta
                    FROM bdicred:sd_maecred
                    WHERE numcte = cNUMCTE order by num_credito*/

                    SELECT  MAX(fecha) INTO dFecha FROM bdicred:"informix".sd_bitacorabloqueocta WHERE cuenta = cNumero_cuenta;
					                 
                    SELECT 'N','06',MC.num_credito, MC.num_producto,DE.nombre_prod,MC.fecha_apertura,
                    TC.descripcion,	MC.sucursal,MC.ejecutivo, dFecha,TC.status_cred
                    INTO cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,
                    cStatus_cuenta,cClave_sucursal,cEjecutivo,dFecha_status,cIdStatusCuenta
                    FROM bdicred:"informix".sd_maecred MC,
                    bdicred:"informix".sd_tipocartera TC,
                    bdicred:"informix".sd_definicion DE
                    WHERE MC. num_credito  = cNumero_cuenta 
                    AND	DE.num_producto = MC.num_producto
                    AND MC.status_cred = TC.status_cred;
                  
                    SELECT sdo_cap_insoluto + sdo_exig_int + sdo_no_exig + sdo_moratorio as Saldo
                    INTO mSaldo_actual
                    FROM bdicred:"informix".sd_maesdos
                    WHERE num_credito =cNumero_cuenta;

                    /*SELECT num_tarjeta,DECODE(status_tar,"A","ACTIVA","C","CANCELADA","DESCONOCIDO")
                    INTO cNo_tarjeta,cStatus_tarjeta
                    FROM bdicred:sd_tarjeta TA
                    WHERE TA.num_credito = cNumero_cuenta 
                    AND TA.status_tar ='A' AND tipo_tarjeta='T';*/

                    INSERT INTO "informix".si_tempoctas (codret,producto_chequera,scuenta,no_cuenta,clave_producto,nombre_producto,fecha_apertura,status_cuenta,
                    fecha_status,clave_sucursal,ejecutivo,saldo_actual,no_tarjeta,status_tarjeta,cuenta_clabe,fecha_apertura_inv,numcte,ejecutivosif,cod_statuscta) values (cCodRet,cIProducto_chequera,
                    cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
                    cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cNUMCTE,cID_USUARIOC,cIdStatusCuenta);
                END FOREACH;

                SET ISOLATION TO DIRTY READ;
                FOREACH

                    SELECT a.num_credito,b.num_tarjeta,DECODE(b.status_tar,"A","ACTIVA","C","CANCELADA","")
                    INTO cNumero_cuenta,cNo_tarjeta,cStatus_tarjeta
                    FROM bdicred:"informix".sd_maecredcrd a
                    LEFT JOIN bdicred:"informix".sd_tarjeta b
                    ON b.num_credito= a.num_credito
                    WHERE a.numcte = cNUMCTE ORDER BY a.num_credito

                    /*SELECT num_credito INTO cNumero_cuenta
                    FROM bdicred:sd_maecredcrd
                    WHERE numcte = cNUMCTE ORDER BY num_credito*/

                    SELECT  MAX(fecha) INTO dFecha FROM bdicred:sd_bitacorabloqueocta WHERE cuenta = cNumero_cuenta;

                    SELECT 'N','06',MC.num_credito, MC.num_producto,DE.nombre_prod,MC.fecha_apertura,
                    TC.descripcion,	MC.sucursal,MC.ejecutivo, dFecha,TC.status_cred
                    INTO cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,
                    cStatus_cuenta,cClave_sucursal,cEjecutivo,dFecha_status,cIdStatusCuenta
                    FROM bdicred:"informix".sd_maecredcrd MC,
                    bdicred:"informix".sd_tipocartera TC,
                    bdicred:"informix".sd_definicion DE
                    WHERE MC. num_credito  = cNumero_cuenta 
                    AND	DE.num_producto = MC.num_producto
                    AND MC.status_cred = TC.status_cred;

                    SELECT sdo_cap_insoluto + sdo_exig_int + sdo_no_exig + sdo_moratorio AS Saldo
                    INTO mSaldo_actual
                    FROM bdicred:"informix".sd_maesdoscrd
                    WHERE num_credito =cNumero_cuenta;

                    /*SELECT num_tarjeta,DECODE(status_tar,"A","ACTIVA","C","CANCELADA","DESCONOCIDO")
                    INTO cNo_tarjeta,cStatus_tarjeta
                    FROM bdicred:sd_tarjeta TA
                    WHERE TA.num_credito = cNumero_cuenta 
                    AND TA.status_tar ='A' AND tipo_tarjeta='T';*/


                    INSERT INTO "informix".si_tempoctas (codret,producto_chequera,scuenta,no_cuenta,clave_producto,nombre_producto,fecha_apertura,status_cuenta,
                    fecha_status,clave_sucursal,ejecutivo,saldo_actual,no_tarjeta,status_tarjeta,cuenta_clabe,fecha_apertura_inv,numcte,ejecutivosif,cod_statuscta) values (cCodRet,cIProducto_chequera,
                    cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
                    cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cNUMCTE,cID_USUARIOC,cIdStatusCuenta);
                END FOREACH;

        END IF 

        SET ISOLATION TO DIRTY READ;
        FOREACH
            SELECT {+INDEX (bdinteg:si_tempoctas idx_tempoctas)} SKIP pNumRegistro FIRST pRecuperacion codret,producto_chequera,scuenta,no_cuenta,clave_producto,nombre_producto,fecha_apertura,nvl(status_cuenta,''),
                        fecha_status,clave_sucursal,ejecutivo,saldo_actual,nvl(no_tarjeta,''),nvl(status_tarjeta,''),cuenta_clabe,fecha_apertura_inv,cod_statuscta into cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
                        cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cIdStatusCuenta
            FROM "informix".si_tempoctas
            WHERE numcte = cNUMCTE AND ejecutivosif= cID_USUARIOC ORDER BY scuenta,no_cuenta,fecha_apertura 
            
            LET iCont=iCont+1;
			
			
			-- FECHA DE CANCELACION
			EXECUTE PROCEDURE "informix".sp_consultafechacancelacioncta(cNo_cuenta, cScuenta) INTO cCodRet, dFechaCancelacion;

            RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,dFechaCancelacion,cIdStatusCuenta WITH resume;
        END FOREACH;
        IF iCont = 0 THEN
            DELETE {+INDEX (bdinteg:si_tempoctas idx_tempoctas)} FROM "informix".si_tempoctas WHERE numcte = cNUMCTE AND ejecutivosif= cID_USUARIOC;
			
            LET cCodRet = '1001'; 
			RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,dFechaCancelacion,cIdStatusCuenta;
        END IF 
	END IF
END
END PROCEDURE
DOCUMENT
"AutOR : Antonio Flores",
"FUNCIONAMIENTO:Este sp realizara la busqueda por tipo de cuenta, dependiendo de tipo de cuenta regresara los datos correspondientes, para captacion o cuenta de cheques",
"para cuentas tipo credito 06 que seran de credito y las cuentas tipo 03 que son de  tipo inversiones",
"FECHA : 04-01-2012",
"BD    : bdinteg",
"Modifico : Victor Hugo Sanchez",
"MODIFICACION : Se almacenan los datos de las cuentas en tabla de paso y se agrega la paginacion",
"Modifico : Oscar Flores Conde",
"MODIFICACION : Se agrega la fecha de cancelacion de la cuenta",
"FECHA : 10-08-2015",
"Modifico : Oscar Flores Conde",
"MODIFICACION : Se agrega el estatus de la cuenta para saber si es cancelada o no",
"VER   : 1.0",
'MODIFICADO:            Donovan F. Torres Landeros',
'ULTIMA MODIFICACION:   2025/07/01',
'RAZON:                 Se agrega la nueva variable saldo_sbc (inmovilizacion por concepto de credito)',
'                       a la operacion aritmetica para el nuevo calculo de',
'                       saldo disponible.',
'PROYECTO:              RQM 09 704   Cobranza Automatica en cuentas de captacion',
'BD:                    bdinteg',
'VER:                   1.2';

CREATE PROCEDURE "informix".sp_desbctasfus_consctas(pNumeroCliente CHAR(20), pAnalista CHAR (20))
RETURNING CHAR(5), CHAR(20), CHAR(20), CHAR(4), CHAR(40), CHAR(2), MONEY(10,2), CHAR(10), DATE, CHAR(10), DATE,CHAR(1);
--DEFINICION DE VARIABLES
DEFINE cCodRet        			CHAR(5);
DEFINE cNumeroCte     			CHAR(20);
DEFINE cCuenta        			CHAR(20);
DEFINE cProducto      			CHAR(4);
DEFINE cDescProducto  			CHAR(40);
DEFINE dFechaAlta     			DATE;
DEFINE cStatusCta     			CHAR(2);
DEFINE cDescStatus    			CHAR(50);
DEFINE dFechaUltMov   			DATE;
DEFINE mSaldo         			MONEY(10,2);
DEFINE iSqlErr        			INTEGER;
DEFINE cEmpresa      			CHAR(3);
DEFINE cUsuario_bloqueo   		CHAR(10);
DEFINE dFecha_bloqueo     		DATE;
DEFINE cSupervisor_desbloqueo  	CHAR(10);
DEFINE dFecha_desbloqueo      	DATE;
DEFINE cValidaNumCte			CHAR(20);	--DSB20130911
DEFINE cValidaNumCta			CHAR (20);	--DSB20130911
DEFINE iNumRows					INTEGER;	--DSB20130911
DEFINE dMaxFecha				DATE;
DEFINE dtHora					DATETIME HOUR TO FRACTION(3);
DEFINE dMaxFechaDesb			DATE;
DEFINE dtHoraDesb				DATETIME HOUR TO FRACTION(3);
DEFINE bBloqueo					CHAR(1);
--RQM 09 704. Se agregan las siguientes variable DFTL 
DEFINE mSdoActual              MONEY(14,2);
DEFINE mSdoRetenido        	   MONEY(14,2);
DEFINE mSdoCongelado           MONEY(14,2);
DEFINE mSaldoSbc               MONEY(14,2);
DEFINE mImpChqSbg              MONEY(14,2); 
DEFINE cCodRetConsSdo          CHAR(5); --Codigo de retorno de SP de consulta de saldo.
DEFINE cMensajeRetConsSdo      CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
--INICIALIZACION DE VARIABLES
LET cCodRet 					= "00000";
LET cNumeroCte 					= "";
LET cCuenta 					= "";
LET cProducto 					= "";
LET cDescProducto 				= "";
LET dFechaAlta 					= "";
LET cStatusCta 					= "";
LET cDescStatus 				= "";
LET dFechaUltMov 				= "";
LET mSaldo 						= 0.00;
LET iSqlErr 					= 0;
LET cEmpresa 					= "001";
LET cUsuario_bloqueo 			= "";
LET dFecha_bloqueo 				= "";
LET cSupervisor_desbloqueo		= "";
LET dFecha_desbloqueo 			= "";
LET cValidaNumCte 				= '';		--DSB20130911
LET cValidaNumCta 				= '';		--DSB20130911
LET iNumRows					= 0;		--DSB20130911
LET dMaxFecha					= CURRENT;
LET dtHora						= '00:00:00';
LET dMaxFechaDesb				= CURRENT;
LET dtHoraDesb					= '00:00:00';
LET bBloqueo					="";
--RQM 09 704. Se agregan las siguientes variable DFTL
LET mSdoActual         			= 0;
LET mSdoRetenido           		= 0;
LET mSdoCongelado          		= 0;
LET mSaldoSbc           		= 0;
LET mImpChqSbg      			= 0;
LET cCodRetConsSdo      		= '00000';
LET cMensajeRetConsSdo  		= '';

--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

    --SET DEBUG FILE TO '/informix/VH/decli/sp_desbctasfus_consctas.out';
    --TRACE ON;
BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet, pNumeroCliente, cCuenta, cProducto, cDescProducto, cStatusCta, mSaldo,cUsuario_bloqueo,dFecha_bloqueo,cSupervisor_desbloqueo,dFecha_desbloqueo,bBloqueo;
        END IF;
    END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	DELETE {+INDEX(bdinteg:"informix".si_desbctasfus_cuentas idx_desbctasfus)} FROM bdinteg:"informix".si_desbctasfus_cuentas where analista=pAnalista AND cuenta=cuenta;	-- Sustituciï¿½n de la tabla temporal. Borra los registros de la tabla que antes era temporal.	--DSB20130911{
	
	SELECT FIRST 1 num_cte INTO cValidaNumCte
	FROM bdicheq:"informix".sc_maechq 
	WHERE num_cte = pNumeroCliente AND status_cta IN (1,3); --and motivo = '09')		--DSB20130805
	LET iNumRows = DBINFO("sqlca.sqlerrd2");
	IF(iNumRows = 0) THEN
		SELECT FIRST 1 numcte INTO cValidaNumCte
		FROM bdicred:"informix".sd_maecred
		WHERE numcte = pNumeroCliente;
		LET iNumRows = DBINFO("sqlca.sqlerrd2");
		IF(iNumRows = 0) THEN								--DSB20130911}
			LET cCodRet = "00100";
			RETURN cCodRet, pNumeroCliente, cCuenta, cProducto, cDescProducto, cStatusCta, mSaldo,cUsuario_bloqueo,dFecha_bloqueo,cSupervisor_desbloqueo,dFecha_desbloqueo,bBloqueo;
		END IF;
    END IF;

	SELECT FIRST 1 chq.num_cte INTO cValidaNumCte			--DSB20130911{
	FROM bdicheq:"informix".sc_maechq chq, bdicheq:"informix".sc_histbloq bloq 
	WHERE chq.num_cte = pNumeroCliente AND chq.status_cta IN (1,3) AND chq.cuenta = bloq.cuenta AND bloq.usuario = pAnalista AND bloq.tipo_mov = 'B';
	LET iNumRows = DBINFO("sqlca.sqlerrd2");
	IF(iNumRows = 0) THEN
		SELECT {+INDEX(bdicred:"informix".sd_bitacorabloqueocta idx_bitcta)} FIRST 1 numcte INTO cValidaNumCte
		FROM bdicred:"informix".sd_maecred cred, bdicred:"informix".sd_bitacorabloqueocta bloq 
		WHERE cred.numcte = pNumeroCliente
		AND bloq.ejecutivo = pAnalista AND cred.num_credito = bloq.cuenta AND bloq.tipo_movimiento = 'B' AND bloq.cuenta = bloq.cuenta;
		LET iNumRows = DBINFO("sqlca.sqlerrd2");
		IF(iNumRows = 0) THEN
			SELECT FIRST 1 num_cte INTO cValidaNumCte
			FROM bdicheq:"informix".sc_maechq
			WHERE num_cte = pNumeroCliente;
			LET iNumRows = DBINFO("sqlca.sqlerrd2");
			IF(iNumRows > 0) THEN							--DSB20130911{
				FOREACH
					SELECT mae.cuenta AS cuenta, mae.producto AS producto, prod.nombre AS nombre, NVL(mae.status_cta, "00") AS status,
					mae.sdo_actual, mae.sdo_retenido, mae.sdo_cong, mae.imp_chq_sbg, mae.saldo_sbc 
					INTO cCuenta, cProducto, cDescProducto,  cStatusCta, mSdoActual, mSdoRetenido, mSdoCongelado, mImpChqSbg, mSaldoSbc
					FROM bdicheq:"informix".sc_maechq mae , bdicheq:"informix".sc_producto prod 
					WHERE mae.num_cte = pNumeroCliente 
					AND mae.producto = prod.producto

					--RQM 09 704. Se ejecuta el siguiente SP para el calculo del saldo disponible DFTL
					EXECUTE PROCEDURE bdicheq:"informix".sp_cons_sdodisp_x_tpcalculo('', mSdoActual, mSdoRetenido, mSdoCongelado, mSaldoSbc, mImpChqSbg, null, null, 'F', 1)
					INTO cCodRetConsSdo, cMensajeRetConsSdo, mSaldo;

					SELECT FIRST 1 cuenta INTO cValidaNumCta	--DSB20130911{
					FROM bdicheq:"informix".sc_histbloq
					WHERE cuenta = cCuenta AND tipo_mov = 'B';
					LET iNumRows = DBINFO("sqlca.sqlerrd2");
					IF(iNumRows > 0) THEN						--DSB20130911}
						SELECT MAX(fecha) INTO dMaxFecha FROM bdicheq:"informix".sc_histbloq WHERE cuenta =  cCuenta AND tipo_mov = 'B';
					
						SELECT MAX(hora) INTO dtHora FROM bdicheq:"informix".sc_histbloq  
						WHERE cuenta = cCuenta AND fecha = dMaxFecha;
						
						SELECT FIRST 1 usuario AS usuario_bloq ,fecha AS fecha_bloq 
						INTO cUsuario_bloqueo,dFecha_bloqueo
						FROM bdicheq:"informix".sc_histbloq  
						WHERE cuenta = cCuenta AND fecha = dMaxFecha AND hora = dtHora;
						
					ELSE
						LET cUsuario_bloqueo = '';
						LET dFecha_bloqueo = '';
					END IF;

						SELECT MAX(fecha) INTO dFecha_desbloqueo FROM bdicheq:"informix".sc_histbloq WHERE cuenta =  cCuenta AND tipo_mov = 'D';
					
						SELECT MAX(hora) INTO dtHoraDesb FROM bdicheq:"informix".sc_histbloq  
						WHERE cuenta = cCuenta AND fecha = dFecha_desbloqueo AND tipo_mov = 'D';

						SELECT FIRST 1 usuario AS supervisor_desb
						INTO cSupervisor_desbloqueo
						FROM bdicheq:"informix".sc_histbloq WHERE cuenta = cCuenta AND fecha = dFecha_desbloqueo AND tipo_mov = 'D';


--					SELECT MAX(fecha) INTO dMaxFechaDesb FROM bdinteg:"informix".si_fusbitacoradesbloqueo WHERE cuenta =  cCuenta;
--					SELECT MAX(hora) INTO dtHoraDesb FROM bdinteg:"informix".si_fusbitacoradesbloqueo WHERE cuenta = cCuenta AND fecha = dMaxFechaDesb;
					/*
					SELECT usuario AS supervisor_desb,fecha AS fecha_desb
					INTO cSupervisor_desbloqueo,dFecha_desbloqueo
					FROM bdinteg:"informix".si_fusbitacoradesbloqueo WHERE cuenta = cCuenta AND fecha = dMaxFechaDesb AND hora = dtHoraDesb;
					*/

					
					INSERT INTO bdinteg:"informix".si_desbctasfus_cuentas(cuenta, producto, nombre, status, saldo,usuario_bloqueo, fecha_bloqueo, supervisor_desbloqueo, fecha_desbloqueo,analista)	--DSB20130911
					VALUES(cCuenta, cProducto, cDescProducto,  cStatusCta,  mSaldo,cUsuario_bloqueo,dFecha_bloqueo,cSupervisor_desbloqueo,dFecha_desbloqueo,pAnalista);
					
					LET cCodRet = '00200';
					
				END FOREACH;
			END IF;
			
			SELECT FIRST 1 numcte INTO cValidaNumCte															--DSB20130911{
			FROM bdicred:"informix".sd_maecred
			WHERE numcte = pNumeroCliente;
			LET iNumRows = DBINFO("sqlca.sqlerrd2");
			IF(iNumRows > 0) THEN																				--DSB20130911}
				FOREACH
					SELECT cred.num_credito AS cuenta, cred.num_producto AS producto, def.nombre_prod AS nombre, cred.status_cred AS status, (dos.sdo_capital + dos.monto_vencido + dos.mto_venc_trasp + dos.cap_tras_no_venci) AS saldo 
					INTO cCuenta, cProducto, cDescProducto,  cStatusCta,  mSaldo 
					FROM bdicred:"informix".sd_maecred cred, bdicred:"informix".sd_maesdos dos, bdicred:"informix".sd_definicion def 
					WHERE cred.numcte = pNumeroCliente AND dos.empresa = cEmpresa AND dos.num_credito = cred.num_credito AND
					def.empresa = cEmpresa AND def.num_producto = cred.num_producto
					
					SELECT {+INDEX(bdicred:"informix".sd_bitacorabloqueocta idx_bitcta)} FIRST 1 cuenta INTO cValidaNumCta													--DSB20130911{
					FROM bdicred:"informix".sd_bitacorabloqueocta
					WHERE cuenta = cCuenta AND tipo_movimiento = 'B';
					LET iNumRows = DBINFO("sqlca.sqlerrd2");
					IF(iNumRows > 0) THEN																		--DSB20130911}
						SELECT {+INDEX(bdicred:"informix".sd_bitacorabloqueocta idx_bitcta)} ejecutivo AS usuario_bloq, fecha AS fecha_bloq
						INTO cUsuario_bloqueo,dFecha_bloqueo
						FROM bdicred:"informix".sd_bitacorabloqueocta
						WHERE id = (SELECT {+INDEX(bdicred:"informix".sd_bitacorabloqueocta idx_bitcta)} MAX(id) FROM bdicred:"informix".sd_bitacorabloqueocta WHERE cuenta = cCuenta AND tipo_movimiento = 'B');
					ELSE
						LET cUsuario_bloqueo = '';
						LET dFecha_bloqueo = '';
					END IF;
					
					SELECT MAX(fecha) INTO dMaxFechaDesb FROM bdicred:"informix".sd_bitacorabloqueocta WHERE cuenta =  cCuenta AND tipo_movimiento = 'D';
					--SELECT MAX(hora) INTO dtHoraDesb FROM bdicred:"informix".sd_bitacorabloqueocta WHERE cuenta = cCuenta AND fecha = dMaxFechaDesb AND tipo_movimiento = 'D';
					/*SELECT usuario AS supervisor_desb,fecha AS fecha_desb
					INTO cSupervisor_desbloqueo,dFecha_desbloqueo
					FROM bdinteg:"informix".si_fusbitacoradesbloqueo WHERE cuenta = cCuenta AND fecha = dMaxFechaDesb AND hora = dtHoraDesb;*/


						SELECT {+INDEX(bdicred:"informix".sd_bitacorabloqueocta idx_bitcta)} FIRST 1 ejecutivo AS usuario_bloq, fecha AS fecha_bloq
						INTO cSupervisor_desbloqueo,dFecha_desbloqueo
						FROM bdicred:"informix".sd_bitacorabloqueocta
						WHERE id = (SELECT {+INDEX(bdicred:"informix".sd_bitacorabloqueocta idx_bitcta)} MAX(id) FROM bdicred:"informix".sd_bitacorabloqueocta WHERE cuenta = cCuenta AND tipo_movimiento = 'D');



					
					INSERT INTO bdinteg:"informix".si_desbctasfus_cuentas(cuenta, producto, nombre, status, saldo,usuario_bloqueo, fecha_bloqueo, supervisor_desbloqueo, fecha_desbloqueo,analista )	--DSB20130911
					VALUES(cCuenta, cProducto, cDescProducto,  cStatusCta,  mSaldo,cUsuario_bloqueo,dFecha_bloqueo,cSupervisor_desbloqueo,dFecha_desbloqueo,pAnalista );
					
					LET cCodRet = '00200';
					
				END FOREACH;
			END IF;
		END IF
    END IF;
	--DSB20130805 }
	
	--	Dï¿½bito	
	SELECT FIRST 1 num_cte INTO cValidaNumCte									--DSB20130911{
	FROM bdicheq:"informix".sc_maechq
	WHERE num_cte = pNumeroCliente AND motivo = '09';
	LET iNumRows = DBINFO("sqlca.sqlerrd2");
	IF(iNumRows > 0) THEN														--DSB20130911}
		FOREACH
			SELECT DISTINCT(mae.cuenta) AS cuenta, mae.producto AS producto, prod.nombre AS nombre, NVL(mae.status_cta, "00") AS status, mae.sdo_actual, mae.sdo_retenido, mae.sdo_cong, mae.imp_chq_sbg, mae.saldo_sbc, bloq.usuario AS usuario_bloq ,bloq.fecha AS fecha_bloq
			INTO cCuenta, cProducto, cDescProducto,  cStatusCta,mSdoActual, mSdoRetenido, mSdoCongelado, mImpChqSbg, mSaldoSbc, cUsuario_bloqueo,dFecha_bloqueo
			FROM bdicheq:"informix".sc_maechq mae, bdicheq:"informix".sc_maenoc noc, bdicheq:"informix".sc_producto prod ,bdicheq:"informix".sc_histbloq bloq
			WHERE mae.num_cte = pNumeroCliente AND noc.cuenta = mae.cuenta AND mae.producto = prod.producto AND mae.cuenta = bloq.cuenta
			AND mae.status_cta IN (1,3) AND bloq.cve_tipobloq = '12' AND bloq.cod_tipobloq = 'Z' AND mae.motivo = '09'	AND bloq.tipo_mov = 'B'--DSB20130805
			AND bloq.fecha in( SELECT MAX(fecha) FROM bdicheq:"informix".sc_histbloq WHERE cuenta =  mae.cuenta 
			AND tipo_mov = 'B' )		--DSB20130805
			--RQM 09 704. Se ejecuta el siguiente SP para el calculo del saldo disponible DFTL
			EXECUTE PROCEDURE bdicheq:"informix".sp_cons_sdodisp_x_tpcalculo('', mSdoActual, mSdoRetenido, mSdoCongelado, mSaldoSbc, mImpChqSbg, null, null, 'F', 1)
			INTO cCodRetConsSdo, cMensajeRetConsSdo, mSaldo;
		/*	SELECT MAX(fecha) INTO dMaxFechaDesb FROM bdinteg:"informix".si_fusbitacoradesbloqueo WHERE cuenta =  cCuenta;
			SELECT MAX(hora) INTO dtHoraDesb FROM bdinteg:"informix".si_fusbitacoradesbloqueo WHERE cuenta = cCuenta AND fecha = dMaxFechaDesb;
			
			SELECT usuario AS supervisor_desb,fecha AS fecha_desb
			INTO cSupervisor_desbloqueo,dFecha_desbloqueo
			FROM bdinteg:"informix".si_fusbitacoradesbloqueo WHERE cuenta = cCuenta AND fecha = dMaxFechaDesb AND hora = dtHoraDesb;
		*/

			SELECT MAX(fecha) INTO dFecha_desbloqueo FROM bdicheq:"informix".sc_histbloq WHERE cuenta =  cCuenta AND tipo_mov = 'B';

			SELECT MAX(hora) INTO dtHoraDesb FROM bdicheq:"informix".sc_histbloq  
			WHERE cuenta = cCuenta AND fecha = dFecha_desbloqueo AND tipo_mov = 'B';

			SELECT FIRST 1 usuario AS supervisor_desb
			INTO cSupervisor_desbloqueo
			FROM bdicheq:"informix".sc_histbloq WHERE cuenta = cCuenta AND fecha = dFecha_desbloqueo AND tipo_mov = 'B';

			IF cUsuario_bloqueo = pAnalista THEN
				INSERT INTO bdinteg:"informix".si_desbctasfus_cuentas(cuenta, producto, nombre, status, saldo,usuario_bloqueo, fecha_bloqueo, supervisor_desbloqueo, fecha_desbloqueo,analista)	--DSB20130911
				VALUES(cCuenta, cProducto, cDescProducto,  cStatusCta,  mSaldo,cUsuario_bloqueo,dFecha_bloqueo,cSupervisor_desbloqueo,dFecha_desbloqueo,pAnalista);
			END IF
		END FOREACH;
		
		SELECT FIRST 1 num_cte INTO cValidaNumCte								--DSB20130911{
		FROM bdicheq:"informix".sc_maechq
		WHERE num_cte = pNumeroCliente AND motivo <> '09';
		LET iNumRows = DBINFO("sqlca.sqlerrd2");
		IF(iNumRows > 0) THEN													--DSB20130911}				
			FOREACH
				SELECT DISTINCT(mae.cuenta) AS cuenta, mae.producto AS producto, prod.nombre AS nombre, NVL(mae.status_cta, "00") AS status, mae.sdo_actual, mae.sdo_retenido, mae.sdo_cong, mae.imp_chq_sbg, mae.saldo_sbc, bloq.usuario AS usuario_bloq ,bloq.fecha AS fecha_bloq
				INTO cCuenta, cProducto, cDescProducto,  cStatusCta, mSdoActual, mSdoRetenido, mSdoCongelado, mImpChqSbg, mSaldoSbc, cUsuario_bloqueo,dFecha_bloqueo
				FROM bdicheq:"informix".sc_maechq mae, bdicheq:"informix".sc_maenoc noc, bdicheq:"informix".sc_producto prod ,bdicheq:"informix".sc_histbloq bloq
				WHERE mae.num_cte = pNumeroCliente AND noc.cuenta = mae.cuenta AND mae.producto = prod.producto AND mae.cuenta = bloq.cuenta
				AND mae.status_cta IN (1,3) AND bloq.cve_tipobloq = '12' AND bloq.cod_tipobloq = 'Z' AND mae.motivo <> '09' AND bloq.tipo_mov = 'B'
				AND bloq.fecha in( SELECT MAX(fecha) FROM bdicheq:"informix".sc_histbloq WHERE cuenta =  mae.cuenta 
				AND tipo_mov = 'B' )
				--RQM 09 704. Se ejecuta el siguiente SP para el calculo del saldo disponible DFTL
				EXECUTE PROCEDURE bdicheq:"informix".sp_cons_sdodisp_x_tpcalculo('', mSdoActual, mSdoRetenido, mSdoCongelado, mSaldoSbc, mImpChqSbg, null, null, 'F', 1)
				INTO cCodRetConsSdo, cMensajeRetConsSdo, mSaldo;
/*				
				SELECT MAX(fecha) INTO dMaxFechaDesb FROM bdinteg:"informix".si_fusbitacoradesbloqueo WHERE cuenta =  cCuenta;
				SELECT MAX(hora) INTO dtHoraDesb FROM bdinteg:"informix".si_fusbitacoradesbloqueo WHERE cuenta = cCuenta AND fecha = dMaxFechaDesb;
				
				SELECT usuario AS supervisor_desb,fecha AS fecha_desb
				INTO cSupervisor_desbloqueo,dFecha_desbloqueo
				FROM bdinteg:"informix".si_fusbitacoradesbloqueo WHERE cuenta = cCuenta AND fecha = dMaxFechaDesb AND hora = dtHoraDesb;
*/

				SELECT MAX(fecha) INTO dFecha_desbloqueo FROM bdicheq:"informix".sc_histbloq WHERE cuenta =  cCuenta AND tipo_mov = 'D';

				SELECT MAX(hora) INTO dtHoraDesb FROM bdicheq:"informix".sc_histbloq  
				WHERE cuenta = cCuenta AND fecha = dFecha_desbloqueo AND tipo_mov = 'D';

				SELECT FIRST 1 usuario AS supervisor_desb
				INTO cSupervisor_desbloqueo
				FROM bdicheq:"informix".sc_histbloq WHERE cuenta = cCuenta AND fecha = dFecha_desbloqueo AND tipo_mov = 'D';
			
				IF cUsuario_bloqueo = pAnalista THEN
					INSERT INTO bdinteg:"informix".si_desbctasfus_cuentas(cuenta, producto, nombre, status, saldo,usuario_bloqueo, fecha_bloqueo, supervisor_desbloqueo, fecha_desbloqueo,analista)	--DSB20130911
					VALUES(cCuenta, cProducto, cDescProducto,  cStatusCta,  mSaldo,cUsuario_bloqueo,dFecha_bloqueo,cSupervisor_desbloqueo,dFecha_desbloqueo,pAnalista);
				END IF
			END FOREACH;
		END IF;
	ELSE
		FOREACH  --DSB23082013
			SELECT DISTINCT(mae.cuenta) AS cuenta, mae.producto AS producto, prod.nombre AS nombre, NVL(mae.status_cta, "00") AS status, mae.sdo_actual, mae.sdo_retenido, mae.sdo_cong, mae.imp_chq_sbg, mae.saldo_sbc, bloq.usuario AS usuario_bloq ,bloq.fecha AS fecha_bloq
			INTO cCuenta, cProducto, cDescProducto,  cStatusCta, mSdoActual, mSdoRetenido, mSdoCongelado, mImpChqSbg, mSaldoSbc, cUsuario_bloqueo,dFecha_bloqueo
			FROM bdicheq:"informix".sc_maechq mae, bdicheq:"informix".sc_maenoc noc, bdicheq:"informix".sc_producto prod ,bdicheq:"informix".sc_histbloq bloq
			WHERE mae.num_cte = pNumeroCliente AND noc.cuenta = mae.cuenta AND mae.producto = prod.producto AND mae.cuenta = bloq.cuenta
			AND mae.status_cta IN (1,3) AND bloq.cve_tipobloq = '12' AND bloq.cod_tipobloq = 'Z' AND tipo_mov = 'B'--AND mae.motivo = '09'
			AND bloq.fecha in( SELECT MAX(fecha) FROM bdicheq:"informix".sc_histbloq WHERE cuenta =  mae.cuenta 
			AND tipo_mov = 'B' )
			--RQM 09 704. Se ejecuta el siguiente SP para el calculo del saldo disponible DFTL
			EXECUTE PROCEDURE bdicheq:"informix".sp_cons_sdodisp_x_tpcalculo('', mSdoActual, mSdoRetenido, mSdoCongelado, mSaldoSbc, mImpChqSbg, null, null, 'F', 1)
			INTO cCodRetConsSdo, cMensajeRetConsSdo, mSaldo;
		/*	
			SELECT MAX(fecha) INTO dMaxFechaDesb FROM bdinteg:"informix".si_fusbitacoradesbloqueo WHERE cuenta =  cCuenta;
			SELECT MAX(hora) INTO dtHoraDesb FROM bdinteg:"informix".si_fusbitacoradesbloqueo WHERE cuenta = cCuenta AND fecha = dMaxFechaDesb;

			SELECT usuario AS supervisor_desb,fecha AS fecha_desb
			INTO cSupervisor_desbloqueo,dFecha_desbloqueo
			FROM bdinteg:"informix".si_fusbitacoradesbloqueo WHERE cuenta = cCuenta AND fecha = dMaxFechaDesb AND hora = dtHoraDesb;
*/

			SELECT MAX(fecha) INTO dFecha_desbloqueo FROM bdicheq:"informix".sc_histbloq WHERE cuenta =  cCuenta AND tipo_mov = 'B';

			SELECT MAX(hora) INTO dtHoraDesb FROM bdicheq:"informix".sc_histbloq  
			WHERE cuenta = cCuenta AND fecha = dFecha_desbloqueo AND tipo_mov = 'B';

			SELECT FIRST 1 usuario AS supervisor_desb
			INTO cSupervisor_desbloqueo
			FROM bdicheq:"informix".sc_histbloq WHERE cuenta = cCuenta AND fecha = dFecha_desbloqueo AND tipo_mov = 'B';

			IF cUsuario_bloqueo = pAnalista THEN
				INSERT INTO bdinteg:"informix".si_desbctasfus_cuentas(cuenta, producto, nombre, status, saldo,usuario_bloqueo, fecha_bloqueo, supervisor_desbloqueo, fecha_desbloqueo,analista)	--DSB20130911
				VALUES(cCuenta, cProducto, cDescProducto,  cStatusCta,  mSaldo,cUsuario_bloqueo,dFecha_bloqueo,cSupervisor_desbloqueo,dFecha_desbloqueo,pAnalista);
			END IF
		END FOREACH;
	END IF;

	-- Crï¿½dito
	SELECT FIRST 1 numcte INTO cValidaNumCte									--DSB20130911{
	FROM bdicred:"informix".sd_maecred
	WHERE numcte = pNumeroCliente  AND cod_caract_2 = '09';
	LET iNumRows = DBINFO("sqlca.sqlerrd2");
	IF(iNumRows > 0) THEN														--DSB20130911}
		FOREACH
			SELECT {+INDEX(bdicred:"informix".sd_bitacorabloqueocta idx_bitcta)} cred.num_credito AS cuenta, cred.num_producto AS producto, def.nombre_prod AS nombre, cred.status_cred AS status, (dos.sdo_capital + dos.monto_vencido + dos.mto_venc_trasp + dos.cap_tras_no_venci) AS saldo ,
			bloq.ejecutivo AS usuario_bloq ,bloq.fecha AS fecha_bloq
			INTO cCuenta, cProducto, cDescProducto,  cStatusCta,  mSaldo ,cUsuario_bloqueo,dFecha_bloqueo
			FROM bdicred:"informix".sd_maecred cred, bdicred:"informix".sd_maesdos dos, bdicred:"informix".sd_definicion def ,
			bdicred:"informix".sd_bitacorabloqueocta bloq
			WHERE cred.numcte = pNumeroCliente AND dos.empresa = cEmpresa AND dos.num_credito = cred.num_credito AND
			def.empresa = cEmpresa AND def.num_producto = cred.num_producto AND cred.num_credito = bloq.cuenta 
			AND cred.id_unidad_prod = 3 AND cred.cod_caract_2 = '09' 			 		--DSB20130805
			AND id = (SELECT {+INDEX(bdicred:"informix".sd_bitacorabloqueocta idx_bitcta)} MAX(id) FROM bdicred:"informix".sd_bitacorabloqueocta 		--DSB20130805
			WHERE cuenta = cred.num_credito AND tipo_movimiento = 'B' AND ejecutivo = pAnalista) --DSB20130805

			--LET cStatusCta='B';

			SELECT MAX(fecha) INTO dMaxFechaDesb FROM bdicred:"informix".sd_bitacorabloqueocta WHERE cuenta =  cCuenta AND tipo_movimiento = 'B';
			--SELECT MAX(hora) INTO dtHoraDesb FROM bdicred:"informix".sd_bitacorabloqueocta WHERE cuenta = cCuenta AND fecha = dMaxFechaDesb AND tipo_movimiento = 'B';
			
			/*SELECT usuario AS supervisor_desb,fecha AS fecha_desb
			INTO cSupervisor_desbloqueo,dFecha_desbloqueo
			FROM bdinteg:"informix".si_fusbitacoradesbloqueo WHERE cuenta = cCuenta AND fecha = dMaxFechaDesb AND hora = dtHoraDesb;*/

			SELECT {+INDEX(bdicred:"informix".sd_bitacorabloqueocta idx_bitcta)} FIRST 1 ejecutivo AS usuario_bloq, fecha AS fecha_bloq
			INTO cSupervisor_desbloqueo,dFecha_desbloqueo
			FROM bdicred:"informix".sd_bitacorabloqueocta
			WHERE id = (SELECT {+INDEX(bdicred:"informix".sd_bitacorabloqueocta idx_bitcta)} MAX(id) FROM bdicred:"informix".sd_bitacorabloqueocta WHERE cuenta = cCuenta AND tipo_movimiento = 'B');


			IF cUsuario_bloqueo = pAnalista THEN
				INSERT INTO bdinteg:"informix".si_desbctasfus_cuentas(cuenta, producto, nombre, status, saldo,usuario_bloqueo, fecha_bloqueo, supervisor_desbloqueo, fecha_desbloqueo,analista,bloq_cred )	--DSB20130911
				VALUES(cCuenta, cProducto, cDescProducto,  cStatusCta,  mSaldo,cUsuario_bloqueo,dFecha_bloqueo,cSupervisor_desbloqueo,dFecha_desbloqueo,pAnalista,'B' );
			END IF
		END FOREACH;
			SELECT FIRST 1 numcte INTO cValidaNumCte								--DSB20130911{
			FROM bdicred:"informix".sd_maecred
			WHERE numcte = pNumeroCliente  AND NVL(cod_caract_2,'') <> '09';
			LET iNumRows = DBINFO("sqlca.sqlerrd2");
			IF(iNumRows > 0) THEN													--DSB20130911}
				FOREACH
					SELECT {+INDEX(bdicred:"informix".sd_bitacorabloqueocta idx_bitcta)} cred.num_credito AS cuenta, cred.num_producto AS producto, def.nombre_prod AS nombre, cred.status_cred AS status, (dos.sdo_capital + dos.monto_vencido + dos.mto_venc_trasp + dos.cap_tras_no_venci) AS saldo ,
					bloq.ejecutivo AS usuario_bloq ,bloq.fecha AS fecha_bloq
					INTO cCuenta, cProducto, cDescProducto,  cStatusCta,  mSaldo ,cUsuario_bloqueo,dFecha_bloqueo
					FROM bdicred:"informix".sd_maecred cred, bdicred:"informix".sd_maesdos dos, bdicred:"informix".sd_definicion def ,
					bdicred:"informix".sd_bitacorabloqueocta bloq
					WHERE cred.numcte = pNumeroCliente AND dos.empresa = cEmpresa AND dos.num_credito = cred.num_credito AND
					def.empresa = cEmpresa AND def.num_producto = cred.num_producto AND cred.num_credito = bloq.cuenta 
					--AND cred.id_unidad_prod = 3 
					AND NVL(cred.cod_caract_2,'') <> '09'
					AND id = (SELECT {+INDEX(bdicred:"informix".sd_bitacorabloqueocta idx_bitcta)} MAX(id) FROM bdicred:"informix".sd_bitacorabloqueocta
					WHERE cuenta = cred.num_credito AND tipo_movimiento = 'B' AND ejecutivo = pAnalista)
				
				/*	SELECT usuario AS supervisor_desb,fecha AS fecha_desb
					INTO cSupervisor_desbloqueo,dFecha_desbloqueo
					FROM bdinteg:"informix".si_fusbitacoradesbloqueo WHERE  cuenta = cCuenta;*/

						SELECT {+INDEX(bdicred:"informix".sd_bitacorabloqueocta idx_bitcta)} FIRST 1 ejecutivo AS usuario_bloq, fecha AS fecha_bloq
						INTO cSupervisor_desbloqueo,dFecha_desbloqueo
						FROM bdicred:"informix".sd_bitacorabloqueocta
						WHERE id = (SELECT {+INDEX(bdicred:"informix".sd_bitacorabloqueocta idx_bitcta)} MAX(id) FROM bdicred:"informix".sd_bitacorabloqueocta WHERE cuenta = cCuenta AND tipo_movimiento = 'D');


					IF cUsuario_bloqueo = pAnalista THEN
						INSERT INTO bdinteg:"informix".si_desbctasfus_cuentas(cuenta, producto, nombre, status, saldo,usuario_bloqueo, fecha_bloqueo, supervisor_desbloqueo, fecha_desbloqueo,analista )	--DSB20130911
						VALUES(cCuenta, cProducto, cDescProducto,  cStatusCta,  mSaldo,cUsuario_bloqueo,dFecha_bloqueo,cSupervisor_desbloqueo,dFecha_desbloqueo,pAnalista );
					END IF
				END FOREACH;
			END IF;
	ELSE
		FOREACH  --DSB23082013
			SELECT {+INDEX(bdicred:"informix".sd_bitacorabloqueocta idx_bitcta)} cred.num_credito AS cuenta, cred.num_producto AS producto, def.nombre_prod AS nombre, cred.status_cred AS status, (dos.sdo_capital + dos.monto_vencido + dos.mto_venc_trasp + dos.cap_tras_no_venci) AS saldo ,
			bloq.ejecutivo AS usuario_bloq ,bloq.fecha AS fecha_bloq
			INTO cCuenta, cProducto, cDescProducto,  cStatusCta,  mSaldo ,cUsuario_bloqueo,dFecha_bloqueo
			FROM bdicred:"informix".sd_maecred cred, bdicred:"informix".sd_maesdos dos, bdicred:"informix".sd_definicion def ,
			bdicred:"informix".sd_bitacorabloqueocta bloq
			WHERE cred.numcte = pNumeroCliente AND dos.empresa = cEmpresa AND dos.num_credito = cred.num_credito AND
			def.empresa = cEmpresa AND def.num_producto = cred.num_producto AND cred.num_credito = bloq.cuenta 
			AND id = (SELECT {+INDEX(bdicred:"informix".sd_bitacorabloqueocta idx_bitcta)} MAX(id) FROM bdicred:"informix".sd_bitacorabloqueocta
			WHERE cuenta = cred.num_credito AND tipo_movimiento = 'B' AND ejecutivo = pAnalista)
			
			SELECT MAX(fecha) INTO dFecha_desbloqueo FROM bdicred:"informix".sd_bitacorabloqueocta WHERE cuenta =  cCuenta AND tipo_movimiento = 'B';
			--SELECT MAX(hora) INTO dtHoraDesb FROM bdicred:"informix".sd_bitacorabloqueocta WHERE cuenta = cCuenta AND fecha = dFecha_desbloqueo AND tipo_movimiento = 'B';
			
		/*	SELECT usuario AS supervisor_desb,fecha AS fecha_desb
			INTO cSupervisor_desbloqueo,dFecha_desbloqueo
			FROM bdinteg:"informix".si_fusbitacoradesbloqueo WHERE cuenta = cCuenta AND fecha = dMaxFechaDesb AND hora = dtHoraDesb;*/

			SELECT {+INDEX(bdicred:"informix".sd_bitacorabloqueocta idx_bitcta)} FIRST 1 ejecutivo AS usuario_bloq, fecha AS fecha_bloq
			INTO cSupervisor_desbloqueo,dFecha_desbloqueo
			FROM bdicred:"informix".sd_bitacorabloqueocta
			WHERE id = (SELECT {+INDEX(bdicred:"informix".sd_bitacorabloqueocta idx_bitcta)} MAX(id) FROM bdicred:"informix".sd_bitacorabloqueocta WHERE cuenta = cCuenta AND tipo_movimiento = 'B');

			
			IF cUsuario_bloqueo = pAnalista THEN
				INSERT INTO bdinteg:"informix".si_desbctasfus_cuentas(cuenta, producto, nombre, status, saldo,usuario_bloqueo, fecha_bloqueo, supervisor_desbloqueo, fecha_desbloqueo,analista )	--DSB20130911
				VALUES(cCuenta, cProducto, cDescProducto,  cStatusCta,  mSaldo,cUsuario_bloqueo,dFecha_bloqueo,cSupervisor_desbloqueo,dFecha_desbloqueo,pAnalista );
			END IF
		END FOREACH;
	END IF;

	FOREACH
		SELECT cuenta, producto, nombre, status, saldo,usuario_bloqueo, fecha_bloqueo, supervisor_desbloqueo, fecha_desbloqueo,bloq_cred
		INTO cCuenta, cProducto, cDescProducto,  cStatusCta,  mSaldo,cUsuario_bloqueo,dFecha_bloqueo,cSupervisor_desbloqueo,dFecha_desbloqueo,bBloqueo 
		FROM bdinteg:"informix".si_desbctasfus_cuentas WHERE analista=pAnalista ORDER BY cuenta

		RETURN cCodRet, pNumeroCliente, cCuenta, cProducto, cDescProducto, cStatusCta, mSaldo, NVL(cUsuario_bloqueo,''), NVL(dFecha_bloqueo,''),
		NVL(cSupervisor_desbloqueo,''), NVL(dFecha_desbloqueo,''),nvl(bBloqueo,'')  WITH RESUME;
	END FOREACH;
	
	--DELETE FROM bdinteg:"informix".si_desbctasfus_cuentas WHERE analista=pAnalista;
END; 
END PROCEDURE
DOCUMENT
'MODIFICADO:            Donovan F. Torres Landeros',
'ULTIMA MODIFICACION:   2025/07/07',
'RAZON:                 Se agrega la nueva variable sdo_sbc (saldo buen cobro)',
'                       a la operacion aritmetica para el nuevo calculo de',
'                       saldo disponible.',
'PROYECTO:              RQM 09 704   Cobranza Automatica en cuentas de captacion',
'BD:                    bdinteg',
'VER:                   1.2';

CREATE PROCEDURE "informix".bm_obten_lista_cuentas( pSessionToken INTEGER,   --- Session Token
                                                    pTipoCuenta   CHAR(10) ) --- Tipo de Cuentas
RETURNING CHAR(5)  AS vCodRet1,        --- Codigo de Retorno
          CHAR(2)  AS vStatus,         --- Status
          CHAR(25) AS vStatusDesc,     --- Descripcion del Status
           
          CHAR(16) AS vCuenta1,               --- Cuenta 
          CHAR(4)  AS vTermCta1,              --- Terminacion Cuenta 
          CHAR(7)  AS vNombreCta1,            --- Producto Cuenta 
          DECIMAL(12,2) AS vSdoDispCta1,      --- Saldo Disponible
          DECIMAL(12,2) AS vSdoCorteCta1,     --- Saldo al Corte
          DECIMAL(12,2) AS vPagoMinCta1,      --- Pago Minimo
          DECIMAL(12,2) AS vPagoNoGenIntCta1, --- Pago No Genera Interes
          CHAR(10) AS vFechaLimPagoCta1,      --- Fecha Limite Pago
          
          CHAR(16) AS vCuenta2,               --- Cuenta 
          CHAR(4)  AS vTermCta2,              --- Terminacion Cuenta 
          CHAR(7)  AS vNombreCta2,            --- Producto Cuenta 
          DECIMAL(12,2) AS vSdoDispCta2,      --- Saldo Disponible
          DECIMAL(12,2) AS vSdoCorteCta2,     --- Saldo al Corte
          DECIMAL(12,2) AS vPagoMinCta2,      --- Pago Minimo
          DECIMAL(12,2) AS vPagoNoGenIntCta2, --- Pago No Genera Interes
          CHAR(10) AS vFechaLimPagoCta2,      --- Fecha Limite Pago
          
          CHAR(16) AS vCuenta3,               --- Cuenta 
          CHAR(4)  AS vTermCta3,              --- Terminacion Cuenta 
          CHAR(7)  AS vNombreCta3,            --- Producto Cuenta 
          DECIMAL(12,2) AS vSdoDispCta3,      --- Saldo Disponible
          DECIMAL(12,2) AS vSdoCorteCta3,     --- Saldo al Corte
          DECIMAL(12,2) AS vPagoMinCta3,      --- Pago Minimo
          DECIMAL(12,2) AS vPagoNoGenIntCta3, --- Pago No Genera Interes
          CHAR(10) AS vFechaLimPagoCta3,      --- Fecha Limite Pago
          
          CHAR(16) AS vCuenta4,               --- Cuenta 
          CHAR(4)  AS vTermCta4,              --- Terminacion Cuenta 
          CHAR(7)  AS vNombreCta4,            --- Producto Cuenta 
          DECIMAL(12,2) AS vSdoDispCta4,      --- Saldo Disponible
          DECIMAL(12,2) AS vSdoCorteCta4,     --- Saldo al Corte
          DECIMAL(12,2) AS vPagoMinCta4,      --- Pago Minimo
          DECIMAL(12,2) AS vPagoNoGenIntCta4, --- Pago No Genera Interes
          CHAR(10) AS vFechaLimPagoCta4,      --- Fecha Limite Pago
          
          CHAR(16) AS vCuenta5,               --- Cuenta 
          CHAR(4)  AS vTermCta5,              --- Terminacion Cuenta 
          CHAR(7)  AS vNombreCta5,            --- Producto Cuenta 
          DECIMAL(12,2) AS vSdoDispCta5,      --- Saldo Disponible
          DECIMAL(12,2) AS vSdoCorteCta5,     --- Saldo al Corte
          DECIMAL(12,2) AS vPagoMinCta5,      --- Pago Minimo
          DECIMAL(12,2) AS vPagoNoGenIntCta5, --- Pago No Genera Interes
          CHAR(10) AS vFechaLimPagoCta5,      --- Fecha Limite Pago
          
          CHAR(16) AS vCuenta6,               --- Cuenta 
          CHAR(4)  AS vTermCta6,              --- Terminacion Cuenta 
          CHAR(7)  AS vNombreCta6,            --- Producto Cuenta 
          DECIMAL(12,2) AS vSdoDispCta6,      --- Saldo Disponible
          DECIMAL(12,2) AS vSdoCorteCta6,     --- Saldo al Corte
          DECIMAL(12,2) AS vPagoMinCta6,      --- Pago Minimo
          DECIMAL(12,2) AS vPagoNoGenIntCta6, --- Pago No Genera Interes
          CHAR(10) AS vFechaLimPagoCta6,      --- Fecha Limite Pago
          
          CHAR(16) AS vCuenta7,               --- Cuenta 
          CHAR(4)  AS vTermCta7,              --- Terminacion Cuenta 
          CHAR(7)  AS vNombreCta,             --- Producto Cuenta 
          DECIMAL(12,2) AS vSdoDispCta7,      --- Saldo Disponible
          DECIMAL(12,2) AS vSdoCorteCta7,     --- Saldo al Corte
          DECIMAL(12,2) AS vPagoMinCta7,      --- Pago Minimo
          DECIMAL(12,2) AS vPagoNoGenIntCta7, --- Pago No Genera Interes
          CHAR(10) AS vFechaLimPagoCta7,      --- Fecha Limite Pago
          
          CHAR(16) AS vCuenta8,               --- Cuenta 
          CHAR(4)  AS vTermCta8,              --- Terminacion Cuenta 
          CHAR(7)  AS vNombreCta8,            --- Producto Cuenta 
          DECIMAL(12,2) AS vSdoDispCta8,      --- Saldo Disponible
          DECIMAL(12,2) AS vSdoCorteCta8,     --- Saldo al Corte
          DECIMAL(12,2) AS vPagoMinCta8,      --- Pago Minimo
          DECIMAL(12,2) AS vPagoNoGenIntCta8, --- Pago No Genera Interes
          CHAR(10) AS vFechaLimPagoCta8,      --- Fecha Limite Pago
          
          CHAR(16) AS vCuenta9,               --- Cuenta 
          CHAR(4)  AS vTermCta9,              --- Terminacion Cuenta 
          CHAR(7)  AS vNombreCta9,            --- Producto Cuenta 
          DECIMAL(12,2) AS vSdoDispCta9,      --- Saldo Disponible
          DECIMAL(12,2) AS vSdoCorteCta9,     --- Saldo al Corte
          DECIMAL(12,2) AS vPagoMinCta9,      --- Pago Minimo
          DECIMAL(12,2) AS vPagoNoGenIntCta9, --- Pago No Genera Interes
          CHAR(10) AS vFechaLimPagoCta9,      --- Fecha Limite Pago
          
          CHAR(16) AS vCuenta10,               --- Cuenta 
          CHAR(4)  AS vTermCta10,              --- Terminacion Cuenta 
          CHAR(7)  AS vNombreCta10,            --- Producto Cuenta 
          DECIMAL(12,2) AS vSdoDispCta10,      --- Saldo Disponible
          DECIMAL(12,2) AS vSdoCorteCta10,     --- Saldo al Corte
          DECIMAL(12,2) AS vPagoMinCta10,      --- Pago Minimo
          DECIMAL(12,2) AS vPagoNoGenIntCta10, --- Pago No Genera Interes
          CHAR(10) AS vFechaLimPagoCta10;      --- Fecha Limite Pago

    
    DEFINE Sql_Err      INTEGER;
    DEFINE Isam_Err     INTEGER;
    DEFINE Desc_Err     CHAR(50);
    DEFINE vCodRet1     CHAR(5);
    DEFINE vCodRet2     CHAR(5);
    DEFINE vCodRet3     CHAR(50);
    DEFINE vStatus      CHAR(2);
    DEFINE vStatusDesc  CHAR(25);

    DEFINE vCuenta1             CHAR(16);
    DEFINE vTermCta1            CHAR(4);
    DEFINE vNombreCta1          CHAR(7);
    DEFINE vSdoDispCta1         DECIMAL(12,2);
    DEFINE vSdoCorteCta1        DECIMAL(12,2);
    DEFINE vPagoMinCta1         DECIMAL(12,2);
    DEFINE vPagoNoGenIntCta1    DECIMAL(12,2);
    DEFINE vFechaLimPagoCta1    CHAR(10);
          
    DEFINE vCuenta2             CHAR(16);
    DEFINE vTermCta2            CHAR(4);
    DEFINE vNombreCta2          CHAR(7);
    DEFINE vSdoDispCta2         DECIMAL(12,2);
    DEFINE vSdoCorteCta2        DECIMAL(12,2);
    DEFINE vPagoMinCta2         DECIMAL(12,2);
    DEFINE vPagoNoGenIntCta2    DECIMAL(12,2);
    DEFINE vFechaLimPagoCta2    CHAR(10);
    
    DEFINE vCuenta3             CHAR(16);
    DEFINE vTermCta3            CHAR(4);
    DEFINE vNombreCta3          CHAR(7);
    DEFINE vSdoDispCta3         DECIMAL(12,2);
    DEFINE vSdoCorteCta3        DECIMAL(12,2);
    DEFINE vPagoMinCta3         DECIMAL(12,2);
    DEFINE vPagoNoGenIntCta3    DECIMAL(12,2);
    DEFINE vFechaLimPagoCta3    CHAR(10);
    
    DEFINE vCuenta4             CHAR(16);
    DEFINE vTermCta4            CHAR(4);
    DEFINE vNombreCta4          CHAR(7);
    DEFINE vSdoDispCta4         DECIMAL(12,2);
    DEFINE vSdoCorteCta4        DECIMAL(12,2);
    DEFINE vPagoMinCta4         DECIMAL(12,2);
    DEFINE vPagoNoGenIntCta4    DECIMAL(12,2);
    DEFINE vFechaLimPagoCta4    CHAR(10);
    
    DEFINE vCuenta5             CHAR(16);
    DEFINE vTermCta5            CHAR(4);
    DEFINE vNombreCta5          CHAR(7);
    DEFINE vSdoDispCta5         DECIMAL(12,2);
    DEFINE vSdoCorteCta5        DECIMAL(12,2);
    DEFINE vPagoMinCta5         DECIMAL(12,2);
    DEFINE vPagoNoGenIntCta5    DECIMAL(12,2);
    DEFINE vFechaLimPagoCta5    CHAR(10);
    
    DEFINE vCuenta6             CHAR(16);
    DEFINE vTermCta6            CHAR(4);
    DEFINE vNombreCta6          CHAR(7);
    DEFINE vSdoDispCta6         DECIMAL(12,2);
    DEFINE vSdoCorteCta6        DECIMAL(12,2);
    DEFINE vPagoMinCta6         DECIMAL(12,2);
    DEFINE vPagoNoGenIntCta6    DECIMAL(12,2);
    DEFINE vFechaLimPagoCta6    CHAR(10);
    
    DEFINE vCuenta7             CHAR(16);
    DEFINE vTermCta7            CHAR(4);
    DEFINE vNombreCta7          CHAR(7);
    DEFINE vSdoDispCta7         DECIMAL(12,2);
    DEFINE vSdoCorteCta7        DECIMAL(12,2);
    DEFINE vPagoMinCta7         DECIMAL(12,2);
    DEFINE vPagoNoGenIntCta7    DECIMAL(12,2);
    DEFINE vFechaLimPagoCta7    CHAR(10);
    
    DEFINE vCuenta8             CHAR(16);
    DEFINE vTermCta8            CHAR(4);
    DEFINE vNombreCta8          CHAR(7);
    DEFINE vSdoDispCta8         DECIMAL(12,2);
    DEFINE vSdoCorteCta8        DECIMAL(12,2);
    DEFINE vPagoMinCta8         DECIMAL(12,2);
    DEFINE vPagoNoGenIntCta8    DECIMAL(12,2);
    DEFINE vFechaLimPagoCta8    CHAR(10);
    
    DEFINE vCuenta9             CHAR(16);
    DEFINE vTermCta9            CHAR(4);
    DEFINE vNombreCta9          CHAR(7);
    DEFINE vSdoDispCta9         DECIMAL(12,2);
    DEFINE vSdoCorteCta9        DECIMAL(12,2);
    DEFINE vPagoMinCta9         DECIMAL(12,2);
    DEFINE vPagoNoGenIntCta9    DECIMAL(12,2);
    DEFINE vFechaLimPagoCta9    CHAR(10);
    
    DEFINE vCuenta10            CHAR(16);
    DEFINE vTermCta10           CHAR(4);
    DEFINE vNombreCta10         CHAR(7);
    DEFINE vSdoDispCta10        DECIMAL(12,2);
    DEFINE vSdoCorteCta10       DECIMAL(12,2);
    DEFINE vPagoMinCta10        DECIMAL(12,2);
    DEFINE vPagoNoGenIntCta10   DECIMAL(12,2);
    DEFINE vFechaLimPagoCta10   CHAR(10);
    
    DEFINE vnumcte          CHAR(20);
    DEFINE vnumcel          CHAR(15);
    DEFINE vsecmax          INTEGER;
    DEFINE vid_oper         CHAR(4);
    DEFINE vcont            SMALLINT;
    DEFINE vcuenta          CHAR(20);
    DEFINE vsdo_disp        DECIMAL(12,2);
    DEFINE vprod            CHAR(7);
    DEFINE vnum_credito     CHAR(20);
    DEFINE vproducto        CHAR(4);
    DEFINE vnombre_prod     CHAR(7);
    DEFINE vnum_tarjeta     CHAR(16);
    DEFINE vsdo_corte       DECIMAL(12,2);
    DEFINE vpago_min        DECIMAL(12,2);
    DEFINE vpagonogenint    DECIMAL(12,2);
    DEFINE vfechlimpago     CHAR(10);
    
    DEFINE vcodret_dat      CHAR(6);
    DEFINE vmensaje_dat     CHAR(80);
    DEFINE vnum_credito_dat CHAR(20);
    DEFINE vnumcte_dat      CHAR(20);
    DEFINE vnombre_prod_dat CHAR(40);
    DEFINE vnum_tarjeta_dat CHAR(20);
    DEFINE vcliente_dat     CHAR(150);
    
    DEFINE vcodret_sdos             CHAR(6);
    DEFINE vmensaje_sdos            CHAR(80);
    DEFINE vnumcredito              CHAR(20);
    DEFINE vcodigo_tipcred          CHAR(2);
    DEFINE vfecha_origen            DATE;
    DEFINE vfecha_prox_pago         DATE;
    DEFINE vpago_minimo             DECIMAL(18,2);
    DEFINE vfecha_ult_pago          DATE;
    DEFINE vplazo                   INTEGER;
    DEFINE vpagos_realizados        INTEGER;
    DEFINE vlinea_otorgada          DECIMAL(18,2);
    DEFINE vtasa_interes            DECIMAL(9,6);
    DEFINE vtasa_moratorios         DECIMAL(9,6);
    DEFINE vmonto_sbc               DECIMAL(14,2);
    DEFINE vcap_vig                 DECIMAL(18,2);
    DEFINE vcap_trans               DECIMAL(18,2);
    DEFINE vcap_vdo_exig            DECIMAL(18,2);
    DEFINE vcap_vdo_no_exig         DECIMAL(18,2);
    DEFINE vsdo_act_total_cap       DECIMAL(18,2);
    DEFINE vint_vig                 DECIMAL(18,2);
    DEFINE vint_vdo                 DECIMAL(18,2);
    DEFINE vint_moratorios          DECIMAL(18,2);
    DEFINE vint_mes                 DECIMAL(18,2);
    DEFINE vsdo_act_total_int       DECIMAL(18,2);
    DEFINE viva_int_vig             DECIMAL(18,2);
    DEFINE viva_int_vdo             DECIMAL(18,2);
    DEFINE viva_int_moratorios      DECIMAL(18,2);
    DEFINE viva_int_mes             DECIMAL(18,2);
    DEFINE vsdo_act_total_iva       DECIMAL(18,2);
    DEFINE vcom_pend                DECIMAL(18,2);
    DEFINE viva_com                 DECIMAL(18,2);
    DEFINE vsdo_retenido            DECIMAL(18,2);
    DEFINE vtotal_liquidacion       DECIMAL(18,2);
    DEFINE vint_devengado           DECIMAL(18,2);
    DEFINE viva_int_devengado       DECIMAL(18,2);
    DEFINE vlinea_disponible        DECIMAL(18,2);
    DEFINE vpagos_vdos              DECIMAL(18,2);
    DEFINE vdesc_status_cred        CHAR(60);
    DEFINE vid_bloqueo_cred         INTEGER;
    DEFINE vbloqueo_cta             CHAR(60);
    DEFINE vid_causa_bloqueo_cred   CHAR(3);
    DEFINE vcausa_bloqueo_cta       CHAR(50);
    DEFINE vid_sit_esp_cte          CHAR(1);
    DEFINE vid_causa_esp_cte        INTEGER;
    DEFINE vsit_esp_cte             CHAR(75);
    DEFINE vid_sit_esp_cred         CHAR(1);
    DEFINE vid_causa_esp_cred       INTEGER;
    DEFINE vsit_esp_cred            CHAR(75);
    DEFINE vstatus_cred             CHAR(2);
    DEFINE vtransaccion             INTEGER;
    DEFINE vCodRetSdoCorte          CHAR(5);
    DEFINE vSdoAlCorte              DECIMAL(18,2);
    DEFINE vSdoNoGenInt             DECIMAL(18,2);
    --RQM 09 704. Se agregan las siguientes variable DFTL 
    DEFINE mSdoActual              MONEY(14,2);
    DEFINE mSdoRetenido        	   MONEY(14,2);
    DEFINE mSdoCongelado           MONEY(14,2);
    DEFINE mSaldoSbc               MONEY(14,2);
    DEFINE mImpChqSbg              MONEY(14,2); 
    DEFINE cCodRetConsSdo          CHAR(5); --Codigo de retorno de SP de consulta de saldo.
    DEFINE cMensajeRetConsSdo      CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
    
    LET Sql_Err	     = 0;
    LET Isam_Err     = 0;
    LET Desc_Err     = '';
    LET vCodRet1     = '00000';
    LET vCodRet2     = '00000';
    LET vCodRet3     = '';
    LET vStatus      = '00';
    LET vStatusDesc  = '';

    LET vCuenta1          = '';
    LET vTermCta1         = '';
    LET vNombreCta1       = '';
    LET vSdoDispCta1      = 0.00;
    LET vSdoCorteCta1     = 0.00;
    LET vPagoMinCta1      = 0.00;
    LET vPagoNoGenIntCta1 = 0.00;
    LET vFechaLimPagoCta1 = '';
    
    LET vCuenta2          = '';
    LET vTermCta2         = '';
    LET vNombreCta2       = '';
    LET vSdoDispCta2      = 0.00;
    LET vSdoCorteCta2     = 0.00;
    LET vPagoMinCta2      = 0.00;
    LET vPagoNoGenIntCta2 = 0.00;
    LET vFechaLimPagoCta2 = '';
    
    LET vCuenta3          = '';
    LET vTermCta3         = '';
    LET vNombreCta3       = '';
    LET vSdoDispCta3      = 0.00;
    LET vSdoCorteCta3     = 0.00;
    LET vPagoMinCta3      = 0.00;
    LET vPagoNoGenIntCta3 = 0.00;
    LET vFechaLimPagoCta3 = '';
    
    LET vCuenta4          = '';
    LET vTermCta4         = '';
    LET vNombreCta4       = '';
    LET vSdoDispCta4      = 0.00;
    LET vSdoCorteCta4     = 0.00;
    LET vPagoMinCta4      = 0.00;
    LET vPagoNoGenIntCta4 = 0.00;
    LET vFechaLimPagoCta4 = '';
    
    LET vCuenta5          = '';
    LET vTermCta5         = '';
    LET vNombreCta5       = '';
    LET vSdoDispCta5      = 0.00;
    LET vSdoCorteCta5     = 0.00;
    LET vPagoMinCta5      = 0.00;
    LET vPagoNoGenIntCta5 = 0.00;
    LET vFechaLimPagoCta5 = '';
    
    LET vCuenta6          = '';
    LET vTermCta6         = '';
    LET vNombreCta6       = '';
    LET vSdoDispCta6      = 0.00;
    LET vSdoCorteCta6     = 0.00;
    LET vPagoMinCta6      = 0.00;
    LET vPagoNoGenIntCta6 = 0.00;
    LET vFechaLimPagoCta6 = '';
    
    LET vCuenta7          = '';
    LET vTermCta7         = '';
    LET vNombreCta7       = '';
    LET vSdoDispCta7      = 0.00;
    LET vSdoCorteCta7     = 0.00;
    LET vPagoMinCta7      = 0.00;
    LET vPagoNoGenIntCta7 = 0.00;
    LET vFechaLimPagoCta7 = '';
    
    LET vCuenta8          = '';
    LET vTermCta8         = '';
    LET vNombreCta8       = '';
    LET vSdoDispCta8      = 0.00;
    LET vSdoCorteCta8     = 0.00;
    LET vPagoMinCta8      = 0.00;
    LET vPagoNoGenIntCta8 = 0.00;
    LET vFechaLimPagoCta8 = '';
    
    LET vCuenta9          = '';
    LET vTermCta9         = '';
    LET vNombreCta9       = '';
    LET vSdoDispCta9      = 0.00;
    LET vSdoCorteCta9     = 0.00;
    LET vPagoMinCta9      = 0.00;
    LET vPagoNoGenIntCta9 = 0.00;
    LET vFechaLimPagoCta9 = '';
    
    LET vCuenta10          = '';
    LET vTermCta10         = '';
    LET vNombreCta10       = '';
    LET vSdoDispCta10      = 0.00;
    LET vSdoCorteCta10     = 0.00;
    LET vPagoMinCta10      = 0.00;
    LET vPagoNoGenIntCta10 = 0.00;
    LET vFechaLimPagoCta10 = '';
    
    LET vnumcte = '';
    LET vnumcel = '';
    LET vsecmax = 0;
    LET vid_oper = '';
    LET vcont = 0;
    LET vcuenta = '';
    LET vsdo_disp = 0.00;
    LET vprod = '';
    LET vnum_credito = '';
    LET vproducto = '';
    LET vnombre_prod = '';
    LET vnum_tarjeta = '';
    LET vsdo_corte = 0.00;
    LET vpago_min = 0.00;
    LET vpagonogenint = 0.00;
    LET vfechlimpago = '';
    
    LET vcodret_dat      = '';
    LET vmensaje_dat     = '';
    LET vnum_credito_dat = '';
    LET vnumcte_dat      = '';
    LET vnombre_prod_dat = '';
    LET vnum_tarjeta_dat = '';
    LET vcliente_dat     = '';
    
    LET vcodret_sdos           = '';
    LET vmensaje_sdos          = '';
    LET vnumcredito            = '';
    LET vcodigo_tipcred        = '';
    LET vfecha_origen          = '';
    LET vfecha_prox_pago       = '';
    LET vpago_minimo           = 0;
    LET vfecha_ult_pago        = '';
    LET vplazo                 = 0;
    LET vpagos_realizados      = 0;
    LET vlinea_otorgada        = 0;
    LET vtasa_interes          = 0;
    LET vtasa_moratorios       = 0;
    LET vmonto_sbc             = 0;
    LET vcap_vig               = 0;
    LET vcap_trans             = 0;
    LET vcap_vdo_exig          = 0;
    LET vcap_vdo_no_exig       = 0;
    LET vsdo_act_total_cap     = 0;
    LET vint_vig               = 0;
    LET vint_vdo               = 0;
    LET vint_moratorios        = 0;
    LET vint_mes               = 0;
    LET vsdo_act_total_int     = 0;
    LET viva_int_vig           = 0;
    LET viva_int_vdo           = 0;
    LET viva_int_moratorios    = 0;
    LET viva_int_mes           = 0;
    LET vsdo_act_total_iva     = 0;
    LET vcom_pend              = 0;
    LET viva_com               = 0;
    LET vsdo_retenido          = 0;
    LET vtotal_liquidacion     = 0;
    LET vint_devengado         = 0;
    LET viva_int_devengado     = 0;
    LET vlinea_disponible      = 0;
    LET vpagos_vdos            = 0;
    LET vdesc_status_cred      = '';
    LET vid_bloqueo_cred       = 0;
    LET vbloqueo_cta           = '';
    LET vid_causa_bloqueo_cred = '';
    LET vcausa_bloqueo_cta     = '';
    LET vid_sit_esp_cte        = '';
    LET vid_causa_esp_cte      = 0;
    LET vsit_esp_cte           = '';
    LET vid_sit_esp_cred       = '';
    LET vid_causa_esp_cred     = 0;
    LET vsit_esp_cred          = '';
    LET vstatus_cred           = '';
    LET vtransaccion           = 0;
    LET vCodRetSdoCorte        = '';
    LET vSdoAlCorte            = 0.00;
    LET vSdoNoGenInt           = 0.00;
    --RQM 09 704. Se agregan las siguientes variable DFTL
    LET mSdoActual         			= 0;
    LET mSdoRetenido           		= 0;
    LET mSdoCongelado          		= 0;
    LET mSaldoSbc           		= 0;
    LET mImpChqSbg      			= 0;
    LET cCodRetConsSdo      		= '00000';
    LET cMensajeRetConsSdo  		= '';
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/bm_obten_lista_cuentas.err";
        --- TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1, vStatus, vStatusDesc, 
                   vCuenta1, vTermCta1, vNombreCta1, vSdoDispCta1, vSdoCorteCta1, vPagoMinCta1, vPagoNoGenIntCta1, vFechaLimPagoCta1,
                   vCuenta2, vTermCta2, vNombreCta2, vSdoDispCta2, vSdoCorteCta2, vPagoMinCta2, vPagoNoGenIntCta2, vFechaLimPagoCta2,
                   vCuenta3, vTermCta3, vNombreCta3, vSdoDispCta3, vSdoCorteCta3, vPagoMinCta3, vPagoNoGenIntCta3, vFechaLimPagoCta3,
                   vCuenta4, vTermCta4, vNombreCta4, vSdoDispCta4, vSdoCorteCta4, vPagoMinCta4, vPagoNoGenIntCta4, vFechaLimPagoCta4,
                   vCuenta5, vTermCta5, vNombreCta5, vSdoDispCta5, vSdoCorteCta5, vPagoMinCta5, vPagoNoGenIntCta5, vFechaLimPagoCta5,
                   vCuenta6, vTermCta6, vNombreCta6, vSdoDispCta6, vSdoCorteCta6, vPagoMinCta6, vPagoNoGenIntCta6, vFechaLimPagoCta6,
                   vCuenta7, vTermCta7, vNombreCta7, vSdoDispCta7, vSdoCorteCta7, vPagoMinCta7, vPagoNoGenIntCta7, vFechaLimPagoCta7,
                   vCuenta8, vTermCta8, vNombreCta8, vSdoDispCta8, vSdoCorteCta8, vPagoMinCta8, vPagoNoGenIntCta8, vFechaLimPagoCta8,
                   vCuenta9, vTermCta9, vNombreCta9, vSdoDispCta9, vSdoCorteCta9, vPagoMinCta9, vPagoNoGenIntCta9, vFechaLimPagoCta9,
                   vCuenta10, vTermCta10, vNombreCta10, vSdoDispCta10, vSdoCorteCta10, vPagoMinCta10, vPagoNoGenIntCta10, vFechaLimPagoCta10;
        END IF;
    END EXCEPTION;
    
    ON EXCEPTION IN (-535)
        LET vtransaccion = 1;
    END EXCEPTION WITH RESUME;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/bm_obten_lista_cuentas.out";
    --- TRACE ON;
    
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;
    
    -- // VALIDA PARAMETROS DE ENTRADA
    IF (pSessionToken is null OR pSessionToken = 0) OR
       (pTipoCuenta is null OR pTipoCuenta = '') THEN
        LET vCodRet1 = '11111';
        LET vStatus = '';
        LET vStatusDesc = 'Error en aplicativo.';
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vCodRet1, vStatus, vStatusDesc, 
               vCuenta1, vTermCta1, vNombreCta1, vSdoDispCta1, vSdoCorteCta1, vPagoMinCta1, vPagoNoGenIntCta1, vFechaLimPagoCta1,
               vCuenta2, vTermCta2, vNombreCta2, vSdoDispCta2, vSdoCorteCta2, vPagoMinCta2, vPagoNoGenIntCta2, vFechaLimPagoCta2,
               vCuenta3, vTermCta3, vNombreCta3, vSdoDispCta3, vSdoCorteCta3, vPagoMinCta3, vPagoNoGenIntCta3, vFechaLimPagoCta3,
               vCuenta4, vTermCta4, vNombreCta4, vSdoDispCta4, vSdoCorteCta4, vPagoMinCta4, vPagoNoGenIntCta4, vFechaLimPagoCta4,
               vCuenta5, vTermCta5, vNombreCta5, vSdoDispCta5, vSdoCorteCta5, vPagoMinCta5, vPagoNoGenIntCta5, vFechaLimPagoCta5,
               vCuenta6, vTermCta6, vNombreCta6, vSdoDispCta6, vSdoCorteCta6, vPagoMinCta6, vPagoNoGenIntCta6, vFechaLimPagoCta6,
               vCuenta7, vTermCta7, vNombreCta7, vSdoDispCta7, vSdoCorteCta7, vPagoMinCta7, vPagoNoGenIntCta7, vFechaLimPagoCta7,
               vCuenta8, vTermCta8, vNombreCta8, vSdoDispCta8, vSdoCorteCta8, vPagoMinCta8, vPagoNoGenIntCta8, vFechaLimPagoCta8,
               vCuenta9, vTermCta9, vNombreCta9, vSdoDispCta9, vSdoCorteCta9, vPagoMinCta9, vPagoNoGenIntCta9, vFechaLimPagoCta9,
               vCuenta10, vTermCta10, vNombreCta10, vSdoDispCta10, vSdoCorteCta10, vPagoMinCta10, vPagoNoGenIntCta10, vFechaLimPagoCta10;
    END IF;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTIENE MAXIMA SECUENCIA DEL CLIENTE EN LA BITACORA
    SELECT MAX(secuencia)
      INTO vsecmax
      FROM bdinteg:"informix".si_bm_bitacora
     WHERE DATE(fech_oper) = CURRENT::DATE
       AND id_session = pSessionToken;
       
    IF vsecmax is null THEN
        LET vCodRet1 = '11111';
        LET vStatus = '';
        LET vStatusDesc = 'Usuario no firmado.';
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vCodRet1, vStatus, vStatusDesc, 
               vCuenta1, vTermCta1, vNombreCta1, vSdoDispCta1, vSdoCorteCta1, vPagoMinCta1, vPagoNoGenIntCta1, vFechaLimPagoCta1,
               vCuenta2, vTermCta2, vNombreCta2, vSdoDispCta2, vSdoCorteCta2, vPagoMinCta2, vPagoNoGenIntCta2, vFechaLimPagoCta2,
               vCuenta3, vTermCta3, vNombreCta3, vSdoDispCta3, vSdoCorteCta3, vPagoMinCta3, vPagoNoGenIntCta3, vFechaLimPagoCta3,
               vCuenta4, vTermCta4, vNombreCta4, vSdoDispCta4, vSdoCorteCta4, vPagoMinCta4, vPagoNoGenIntCta4, vFechaLimPagoCta4,
               vCuenta5, vTermCta5, vNombreCta5, vSdoDispCta5, vSdoCorteCta5, vPagoMinCta5, vPagoNoGenIntCta5, vFechaLimPagoCta5,
               vCuenta6, vTermCta6, vNombreCta6, vSdoDispCta6, vSdoCorteCta6, vPagoMinCta6, vPagoNoGenIntCta6, vFechaLimPagoCta6,
               vCuenta7, vTermCta7, vNombreCta7, vSdoDispCta7, vSdoCorteCta7, vPagoMinCta7, vPagoNoGenIntCta7, vFechaLimPagoCta7,
               vCuenta8, vTermCta8, vNombreCta8, vSdoDispCta8, vSdoCorteCta8, vPagoMinCta8, vPagoNoGenIntCta8, vFechaLimPagoCta8,
               vCuenta9, vTermCta9, vNombreCta9, vSdoDispCta9, vSdoCorteCta9, vPagoMinCta9, vPagoNoGenIntCta9, vFechaLimPagoCta9,
               vCuenta10, vTermCta10, vNombreCta10, vSdoDispCta10, vSdoCorteCta10, vPagoMinCta10, vPagoNoGenIntCta10, vFechaLimPagoCta10;
    END IF;
       
    SELECT id_oper, numcte, numcel
      INTO vid_oper, vnumcte, vnumcel
      FROM bdinteg:"informix".si_bm_bitacora
     WHERE DATE(fech_oper) = CURRENT::DATE
       AND id_session = pSessionToken
       AND secuencia = vsecmax;
       
    IF vid_oper is null OR vid_oper = '' THEN
        LET vCodRet1 = '11111';
        LET vStatus = '';
        LET vStatusDesc = 'Usuario no firmado.';
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vCodRet1, vStatus, vStatusDesc, 
               vCuenta1, vTermCta1, vNombreCta1, vSdoDispCta1, vSdoCorteCta1, vPagoMinCta1, vPagoNoGenIntCta1, vFechaLimPagoCta1,
               vCuenta2, vTermCta2, vNombreCta2, vSdoDispCta2, vSdoCorteCta2, vPagoMinCta2, vPagoNoGenIntCta2, vFechaLimPagoCta2,
               vCuenta3, vTermCta3, vNombreCta3, vSdoDispCta3, vSdoCorteCta3, vPagoMinCta3, vPagoNoGenIntCta3, vFechaLimPagoCta3,
               vCuenta4, vTermCta4, vNombreCta4, vSdoDispCta4, vSdoCorteCta4, vPagoMinCta4, vPagoNoGenIntCta4, vFechaLimPagoCta4,
               vCuenta5, vTermCta5, vNombreCta5, vSdoDispCta5, vSdoCorteCta5, vPagoMinCta5, vPagoNoGenIntCta5, vFechaLimPagoCta5,
               vCuenta6, vTermCta6, vNombreCta6, vSdoDispCta6, vSdoCorteCta6, vPagoMinCta6, vPagoNoGenIntCta6, vFechaLimPagoCta6,
               vCuenta7, vTermCta7, vNombreCta7, vSdoDispCta7, vSdoCorteCta7, vPagoMinCta7, vPagoNoGenIntCta7, vFechaLimPagoCta7,
               vCuenta8, vTermCta8, vNombreCta8, vSdoDispCta8, vSdoCorteCta8, vPagoMinCta8, vPagoNoGenIntCta8, vFechaLimPagoCta8,
               vCuenta9, vTermCta9, vNombreCta9, vSdoDispCta9, vSdoCorteCta9, vPagoMinCta9, vPagoNoGenIntCta9, vFechaLimPagoCta9,
               vCuenta10, vTermCta10, vNombreCta10, vSdoDispCta10, vSdoCorteCta10, vPagoMinCta10, vPagoNoGenIntCta10, vFechaLimPagoCta10;
    END IF;   
    
    IF vid_oper = '1001' THEN
        LET vCodRet1 = '11111';
        LET vStatus = '';
        LET vStatusDesc = 'Usuario no firmado.';
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vCodRet1, vStatus, vStatusDesc, 
               vCuenta1, vTermCta1, vNombreCta1, vSdoDispCta1, vSdoCorteCta1, vPagoMinCta1, vPagoNoGenIntCta1, vFechaLimPagoCta1,
               vCuenta2, vTermCta2, vNombreCta2, vSdoDispCta2, vSdoCorteCta2, vPagoMinCta2, vPagoNoGenIntCta2, vFechaLimPagoCta2,
               vCuenta3, vTermCta3, vNombreCta3, vSdoDispCta3, vSdoCorteCta3, vPagoMinCta3, vPagoNoGenIntCta3, vFechaLimPagoCta3,
               vCuenta4, vTermCta4, vNombreCta4, vSdoDispCta4, vSdoCorteCta4, vPagoMinCta4, vPagoNoGenIntCta4, vFechaLimPagoCta4,
               vCuenta5, vTermCta5, vNombreCta5, vSdoDispCta5, vSdoCorteCta5, vPagoMinCta5, vPagoNoGenIntCta5, vFechaLimPagoCta5,
               vCuenta6, vTermCta6, vNombreCta6, vSdoDispCta6, vSdoCorteCta6, vPagoMinCta6, vPagoNoGenIntCta6, vFechaLimPagoCta6,
               vCuenta7, vTermCta7, vNombreCta7, vSdoDispCta7, vSdoCorteCta7, vPagoMinCta7, vPagoNoGenIntCta7, vFechaLimPagoCta7,
               vCuenta8, vTermCta8, vNombreCta8, vSdoDispCta8, vSdoCorteCta8, vPagoMinCta8, vPagoNoGenIntCta8, vFechaLimPagoCta8,
               vCuenta9, vTermCta9, vNombreCta9, vSdoDispCta9, vSdoCorteCta9, vPagoMinCta9, vPagoNoGenIntCta9, vFechaLimPagoCta9,
               vCuenta10, vTermCta10, vNombreCta10, vSdoDispCta10, vSdoCorteCta10, vPagoMinCta10, vPagoNoGenIntCta10, vFechaLimPagoCta10;
    END IF;
    
    IF vid_oper IN('1000', '1002', '1003', '1004', '1005') THEN
    
        -- // OBTIENE INFORMACION DE LAS CUENTAS DE DEBITO
        IF pTipoCuenta = 'DEBITO' THEN
        
            LET vcont = 1;
            
            FOREACH
                SELECT mae.cuenta, mae.sdo_actual, mae.sdo_retenido, mae.sdo_cong, mae.imp_chq_sbg, mae.producto, mae.saldo_sbc
                  INTO vcuenta, mSdoActual, mSdoRetenido, mSdoCongelado, mImpChqSbg, vprod, mSaldoSbc
                  FROM bdicheq:"informix".sc_maechq mae
                 WHERE mae.num_cte = vnumcte
                   AND mae.status_cta <> '2'
                   AND mae.producto NOT IN('2300')
                 ORDER BY mae.cuenta

                --RQM 09 704. Se ejecuta el siguiente SP para el calculo del saldo disponible DFTL
			    EXECUTE PROCEDURE bdicheq:"informix".sp_cons_sdodisp_x_tpcalculo('', mSdoActual, mSdoRetenido, mSdoCongelado, mSaldoSbc, mImpChqSbg, null, null, 'F', 1)
				INTO cCodRetConsSdo, cMensajeRetConsSdo, vsdo_disp;
                 
                SELECT nombre
                  INTO vnombre_prod
                  FROM bdinteg:"informix".si_bm_productos
                 WHERE producto = vprod;
                 
                IF vcont = 1 THEN
                    LET vCuenta1          = vcuenta;
                    LET vTermCta1         = SUBSTR(vcuenta,LENGTH(vcuenta)-3,4);
                    LET vNombreCta1       = vnombre_prod;
                    LET vSdoDispCta1      = vsdo_disp;
                    LET vSdoCorteCta1     = 0.00;
                    LET vPagoMinCta1      = 0.00;
                    LET vPagoNoGenIntCta1 = 0.00;
                    LET vFechaLimPagoCta1 = ' ';
                ELIF vcont = 2 THEN
                    LET vCuenta2          = vcuenta;
                    LET vTermCta2         = SUBSTR(vcuenta,LENGTH(vcuenta)-3,4);
                    LET vNombreCta2       = vnombre_prod;
                    LET vSdoDispCta2      = vsdo_disp;
                    LET vSdoCorteCta2     = 0.00;
                    LET vPagoMinCta2      = 0.00;
                    LET vPagoNoGenIntCta2 = 0.00;
                    LET vFechaLimPagoCta2 = ' ';
                ELIF vcont = 3 THEN
                    LET vCuenta3          = vcuenta;
                    LET vTermCta3         = SUBSTR(vcuenta,LENGTH(vcuenta)-3,4);
                    LET vNombreCta3       = vnombre_prod;
                    LET vSdoDispCta3      = vsdo_disp;
                    LET vSdoCorteCta3     = 0.00;
                    LET vPagoMinCta3      = 0.00;
                    LET vPagoNoGenIntCta3 = 0.00;
                    LET vFechaLimPagoCta3 = ' ';
                ELIF vcont = 4 THEN
                    LET vCuenta4          = vcuenta;
                    LET vTermCta4         = SUBSTR(vcuenta,LENGTH(vcuenta)-3,4);
                    LET vNombreCta4       = vnombre_prod;
                    LET vSdoDispCta4      = vsdo_disp;
                    LET vSdoCorteCta4     = 0.00;
                    LET vPagoMinCta4      = 0.00;
                    LET vPagoNoGenIntCta4 = 0.00;
                    LET vFechaLimPagoCta4 = ' ';
                ELIF vcont = 5 THEN
                    LET vCuenta5          = vcuenta;
                    LET vTermCta5         = SUBSTR(vcuenta,LENGTH(vcuenta)-3,4);
                    LET vNombreCta5       = vnombre_prod;
                    LET vSdoDispCta5      = vsdo_disp;
                    LET vSdoCorteCta5     = 0.00;
                    LET vPagoMinCta5      = 0.00;
                    LET vPagoNoGenIntCta5 = 0.00;
                    LET vFechaLimPagoCta5 = ' ';
                ELIF vcont = 6 THEN
                    LET vCuenta6          = vcuenta;
                    LET vTermCta6         = SUBSTR(vcuenta,LENGTH(vcuenta)-3,4);
                    LET vNombreCta6       = vnombre_prod;
                    LET vSdoDispCta6      = vsdo_disp;
                    LET vSdoCorteCta6     = 0.00;
                    LET vPagoMinCta6      = 0.00;
                    LET vPagoNoGenIntCta6 = 0.00;
                    LET vFechaLimPagoCta6 = ' ';
                ELIF vcont = 7 THEN
                    LET vCuenta7          = vcuenta;
                    LET vTermCta7         = SUBSTR(vcuenta,LENGTH(vcuenta)-3,4);
                    LET vNombreCta7       = vnombre_prod;
                    LET vSdoDispCta7      = vsdo_disp;
                    LET vSdoCorteCta7     = 0.00;
                    LET vPagoMinCta7      = 0.00;
                    LET vPagoNoGenIntCta7 = 0.00;
                    LET vFechaLimPagoCta7 = ' ';
                ELIF vcont = 8 THEN
                    LET vCuenta8          = vcuenta;
                    LET vTermCta8         = SUBSTR(vcuenta,LENGTH(vcuenta)-3,4);
                    LET vNombreCta8       = vnombre_prod;
                    LET vSdoDispCta8      = vsdo_disp;
                    LET vSdoCorteCta8     = 0.00;
                    LET vPagoMinCta8      = 0.00;
                    LET vPagoNoGenIntCta8 = 0.00;
                    LET vFechaLimPagoCta8 = ' ';
                ELIF vcont = 9 THEN
                    LET vCuenta9          = vcuenta;
                    LET vTermCta9         = SUBSTR(vcuenta,LENGTH(vcuenta)-3,4);
                    LET vNombreCta9       = vnombre_prod;
                    LET vSdoDispCta9      = vsdo_disp;
                    LET vSdoCorteCta9     = 0.00;
                    LET vPagoMinCta9      = 0.00;
                    LET vPagoNoGenIntCta9 = 0.00;
                    LET vFechaLimPagoCta9 = ' ';
                ELIF vcont = 10 THEN
                    LET vCuenta10          = vcuenta;
                    LET vTermCta10         = SUBSTR(vcuenta,LENGTH(vcuenta)-3,4);
                    LET vNombreCta10       = vnombre_prod;
                    LET vSdoDispCta10      = vsdo_disp;
                    LET vSdoCorteCta10     = 0.00;
                    LET vPagoMinCta10      = 0.00;
                    LET vPagoNoGenIntCta10 = 0.00;
                    LET vFechaLimPagoCta10 = ' ';            
                END IF;
                
                LET vcont = vcont + 1;
                
                IF vcont >= 10 THEN
                    EXIT FOREACH;
                END IF;
                
                LET vcuenta = '';
                LET vsdo_disp = 0.00;
                LET vprod = '';
                LET vnombre_prod = '';
            END FOREACH;
        
            -- // GENERA REGISTRO EN BITACORA 
            SELECT MAX(secuencia)
              INTO vsecmax
              FROM bdinteg:"informix".si_bm_bitacora
             WHERE DATE(fech_oper) = CURRENT::DATE
               AND id_session = pSessionToken;
               
            LET vsecmax = vsecmax + 1;
            
            INSERT INTO bdinteg:"informix".si_bm_bitacora(id_session, fech_oper, numcte, secuencia, id_oper, numcel, cuenta, foliosol)
            VALUES(pSessionToken, current, vnumcte, vsecmax, '1002', vnumcel, null, null);
            
            IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
                LET vCodRet1 = '11111';
                LET vStatus = '';
                LET vStatusDesc = 'Error en aplicativo.';
                IF vtransaccion = 1 THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF;
                RETURN vCodRet1, vStatus, vStatusDesc, 
                       vCuenta1, vTermCta1, vNombreCta1, vSdoDispCta1, vSdoCorteCta1, vPagoMinCta1, vPagoNoGenIntCta1, vFechaLimPagoCta1,
                       vCuenta2, vTermCta2, vNombreCta2, vSdoDispCta2, vSdoCorteCta2, vPagoMinCta2, vPagoNoGenIntCta2, vFechaLimPagoCta2,
                       vCuenta3, vTermCta3, vNombreCta3, vSdoDispCta3, vSdoCorteCta3, vPagoMinCta3, vPagoNoGenIntCta3, vFechaLimPagoCta3,
                       vCuenta4, vTermCta4, vNombreCta4, vSdoDispCta4, vSdoCorteCta4, vPagoMinCta4, vPagoNoGenIntCta4, vFechaLimPagoCta4,
                       vCuenta5, vTermCta5, vNombreCta5, vSdoDispCta5, vSdoCorteCta5, vPagoMinCta5, vPagoNoGenIntCta5, vFechaLimPagoCta5,
                       vCuenta6, vTermCta6, vNombreCta6, vSdoDispCta6, vSdoCorteCta6, vPagoMinCta6, vPagoNoGenIntCta6, vFechaLimPagoCta6,
                       vCuenta7, vTermCta7, vNombreCta7, vSdoDispCta7, vSdoCorteCta7, vPagoMinCta7, vPagoNoGenIntCta7, vFechaLimPagoCta7,
                       vCuenta8, vTermCta8, vNombreCta8, vSdoDispCta8, vSdoCorteCta8, vPagoMinCta8, vPagoNoGenIntCta8, vFechaLimPagoCta8,
                       vCuenta9, vTermCta9, vNombreCta9, vSdoDispCta9, vSdoCorteCta9, vPagoMinCta9, vPagoNoGenIntCta9, vFechaLimPagoCta9,
                       vCuenta10, vTermCta10, vNombreCta10, vSdoDispCta10, vSdoCorteCta10, vPagoMinCta10, vPagoNoGenIntCta10, vFechaLimPagoCta10;
            END IF;
            
        ELIF pTipoCuenta = 'CREDITO' THEN
        
            LET vcont = 1;
            
            FOREACH
                EXECUTE PROCEDURE bdicred:"informix".sp_consulta_datos_general('001', vnumcte, '', '', '', '', '')
                INTO vcodret_dat, vmensaje_dat, vnum_credito_dat, vnumcte_dat, vnombre_prod_dat, vnum_tarjeta_dat, vcliente_dat
                
                IF vcodret_dat <> '000000' OR vnum_credito_dat is null OR vnum_credito_dat = '' THEN 
                    CONTINUE FOREACH;
                END IF;
                
                -- // OBTIENE EL NUMERO DE TARJETA O CREDITO
                LET vnum_credito = vnum_credito_dat;
                LET vnum_tarjeta = vnum_tarjeta_dat;
                
                IF vnum_tarjeta is null OR vnum_tarjeta = '' THEN
                    LET vnum_tarjeta = vnum_credito;
                END IF;
                
                -- // VALIDA EL STATUS DEL CREDITO Y OBTIENE EL TIPO DE PRODUCTO
                SELECT status_cred, num_producto
                  INTO vstatus_cred, vproducto
                  FROM bdicred:"informix".sd_maecred
                 WHERE num_credito = vnum_credito;
                 
                IF (vstatus_cred is null OR vstatus_cred = '') OR 
                   (vproducto is null OR vproducto = '') THEN
                    SELECT status_cred, num_producto
                      INTO vstatus_cred, vproducto
                      FROM bdicred:"informix".sd_maecredcrd
                     WHERE num_credito = vnum_credito
                       AND empresa = '001';
                END IF;
                
				--IFRS Se modifica estatus por etapas
                --IF vstatus_cred is null OR vstatus_cred = '' OR vstatus_cred NOT IN('AA','BA','BT','VP') THEN
				IF vstatus_cred is null OR vstatus_cred = '' OR vstatus_cred NOT IN('AA','BA','BT','VP','E1','E2','E3') THEN
                    CONTINUE FOREACH;
                END IF;
                 
                SELECT nombre
                  INTO vnombre_prod
                  FROM bdinteg:"informix".si_bm_productos
                 WHERE producto = vproducto;
                
                -- // OBTIENE LOS SALDOS DEL CREDITO 
                EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general('001', vnum_credito)
                INTO vcodret_sdos, vmensaje_sdos, vnumcredito, vcodigo_tipcred, vfecha_origen, vfecha_prox_pago, 
                     vpago_minimo, vfecha_ult_pago, vplazo, vpagos_realizados, vlinea_otorgada, vtasa_interes,
                     vtasa_moratorios, vmonto_sbc, vcap_vig, vcap_trans, vcap_vdo_exig, vcap_vdo_no_exig, vsdo_act_total_cap,
                     vint_vig, vint_vdo, vint_moratorios, vint_mes, vsdo_act_total_int, viva_int_vig, viva_int_vdo, viva_int_moratorios,
                     viva_int_mes, vsdo_act_total_iva, vcom_pend, viva_com, vsdo_retenido, vtotal_liquidacion, vint_devengado, viva_int_devengado, 
                     vlinea_disponible, vpagos_vdos, vdesc_status_cred, vid_bloqueo_cred, vbloqueo_cta, vid_causa_bloqueo_cred, vcausa_bloqueo_cta, 
                     vid_sit_esp_cte, vid_causa_esp_cte, vsit_esp_cte, vid_sit_esp_cred, vid_causa_esp_cred, vsit_esp_cred;
                         
                -- // SALDO DISPONIBLE AL DIA DE HOY
                LET vsdo_disp = vtotal_liquidacion;
                
                IF vsdo_disp is null OR vsdo_disp < 0.00 THEN 
                    LET vsdo_disp = 0.00; 
                END IF;
                
                -- // SALDO AL CORTE
                EXECUTE PROCEDURE bdicred:"informix".sp_consultasaldocorte('001', vnum_credito, 1)
                INTO vCodRetSdoCorte, vSdoAlCorte;
                
                LET vsdo_corte = vlinea_disponible;
                
                IF vsdo_corte is null OR vsdo_corte < 0 THEN
                    LET vsdo_corte = 0.00;
                END IF;
                
                -- // PAGO MINIMO
                LET vpago_min = vpago_minimo;
                
                IF vpago_min < 0 THEN 
                    LET vpago_min = 0.00; 
                END IF;
                
                -- // PAGO PARA NO GENERAR INTERESES
                EXECUTE PROCEDURE bdicred:"informix".sp_consultasaldocorte('001', vnum_credito, 0)
                INTO vCodRetSdoCorte, vSdoNoGenInt;
                
                LET vpagonogenint = vSdoNoGenInt;
                
                IF vpagonogenint is null THEN 
                    LET vpagonogenint = 0.00; 
                END IF;
                
                -- // FECHA LIMITE DE PAGO 
                LET vfechlimpago = TO_CHAR(vfecha_prox_pago, '%d/%m/%Y');
                                 
                IF vcont = 1 THEN 
                    LET vCuenta1          = vnum_tarjeta;
                    LET vTermCta1         = SUBSTR(vnum_tarjeta,LENGTH(vnum_tarjeta)-3,4);
                    LET vNombreCta1       = vnombre_prod;
                    LET vSdoDispCta1      = vsdo_disp;
                    LET vSdoCorteCta1     = vsdo_corte;
                    LET vPagoMinCta1      = vpago_min;
                    LET vPagoNoGenIntCta1 = vpagonogenint;
                    LET vFechaLimPagoCta1 = vfechlimpago;
                ELIF vcont = 2 THEN
                    LET vCuenta2          = vnum_tarjeta;
                    LET vTermCta2         = SUBSTR(vnum_tarjeta,LENGTH(vnum_tarjeta)-3,4);
                    LET vNombreCta2       = vnombre_prod;
                    LET vSdoDispCta2      = vsdo_disp;
                    LET vSdoCorteCta2     = vsdo_corte;
                    LET vPagoMinCta2      = vpago_min;
                    LET vPagoNoGenIntCta2 = vpagonogenint;
                    LET vFechaLimPagoCta2 = vfechlimpago;
                ELIF vcont = 3 THEN
                    LET vCuenta3          = vnum_tarjeta;
                    LET vTermCta3         = SUBSTR(vnum_tarjeta,LENGTH(vnum_tarjeta)-3,4);
                    LET vNombreCta3       = vnombre_prod;
                    LET vSdoDispCta3      = vsdo_disp;
                    LET vSdoCorteCta3     = vsdo_corte;
                    LET vPagoMinCta3      = vpago_min;
                    LET vPagoNoGenIntCta3 = vpagonogenint;
                    LET vFechaLimPagoCta3 = vfechlimpago;
                ELIF vcont = 4 THEN
                    LET vCuenta4          = vnum_tarjeta;
                    LET vTermCta4         = SUBSTR(vnum_tarjeta,LENGTH(vnum_tarjeta)-3,4);
                    LET vNombreCta4       = vnombre_prod;
                    LET vSdoDispCta4      = vsdo_disp;
                    LET vSdoCorteCta4     = vsdo_corte;
                    LET vPagoMinCta4      = vpago_min;
                    LET vPagoNoGenIntCta4 = vpagonogenint;
                    LET vFechaLimPagoCta4 = vfechlimpago;
                ELIF vcont = 5 THEN
                    LET vCuenta5          = vnum_tarjeta;
                    LET vTermCta5         = SUBSTR(vnum_tarjeta,LENGTH(vnum_tarjeta)-3,4);
                    LET vNombreCta5       = vnombre_prod;
                    LET vSdoDispCta5      = vsdo_disp;
                    LET vSdoCorteCta5     = vsdo_corte;
                    LET vPagoMinCta5      = vpago_min;
                    LET vPagoNoGenIntCta5 = vpagonogenint;
                    LET vFechaLimPagoCta5 = vfechlimpago;
                ELIF vcont = 6 THEN
                    LET vCuenta6          = vnum_tarjeta;
                    LET vTermCta6         = SUBSTR(vnum_tarjeta,LENGTH(vnum_tarjeta)-3,4);
                    LET vNombreCta6       = vnombre_prod;
                    LET vSdoDispCta6      = vsdo_disp;
                    LET vSdoCorteCta6     = vsdo_corte;
                    LET vPagoMinCta6      = vpago_min;
                    LET vPagoNoGenIntCta6 = vpagonogenint;
                    LET vFechaLimPagoCta6 = vfechlimpago;
                ELIF vcont = 7 THEN
                    LET vCuenta7          = vnum_tarjeta;
                    LET vTermCta7         = SUBSTR(vnum_tarjeta,LENGTH(vnum_tarjeta)-3,4);
                    LET vNombreCta7       = vnombre_prod;
                    LET vSdoDispCta7      = vsdo_disp;
                    LET vSdoCorteCta7     = vsdo_corte;
                    LET vPagoMinCta7      = vpago_min;
                    LET vPagoNoGenIntCta7 = vpagonogenint;
                    LET vFechaLimPagoCta7 = vfechlimpago;
                ELIF vcont = 8 THEN
                    LET vCuenta8          = vnum_tarjeta;
                    LET vTermCta8         = SUBSTR(vnum_tarjeta,LENGTH(vnum_tarjeta)-3,4);
                    LET vNombreCta8       = vnombre_prod;
                    LET vSdoDispCta8      = vsdo_disp;
                    LET vSdoCorteCta8     = vsdo_corte;
                    LET vPagoMinCta8      = vpago_min;
                    LET vPagoNoGenIntCta8 = vpagonogenint;
                    LET vFechaLimPagoCta8 = vfechlimpago;
                ELIF vcont = 9 THEN
                    LET vCuenta9          = vnum_tarjeta;
                    LET vTermCta9         = SUBSTR(vnum_tarjeta,LENGTH(vnum_tarjeta)-3,4);
                    LET vNombreCta9       = vnombre_prod;
                    LET vSdoDispCta9      = vsdo_disp;
                    LET vSdoCorteCta9     = vsdo_corte;
                    LET vPagoMinCta9      = vpago_min;
                    LET vPagoNoGenIntCta9 = vpagonogenint;
                    LET vFechaLimPagoCta9 = vfechlimpago;
                ELIF vcont = 10 THEN
                    LET vCuenta10          = vnum_tarjeta;
                    LET vTermCta10         = SUBSTR(vnum_tarjeta,LENGTH(vnum_tarjeta)-3,4);
                    LET vNombreCta10       = vnombre_prod;
                    LET vSdoDispCta10      = vsdo_disp;
                    LET vSdoCorteCta10     = vsdo_corte;
                    LET vPagoMinCta10      = vpago_min;
                    LET vPagoNoGenIntCta10 = vpagonogenint;
                    LET vFechaLimPagoCta10 = vfechlimpago;            
                END IF;
                
                LET vcont = vcont + 1;
                
                IF vcont >= 10 THEN
                    EXIT FOREACH;
                END IF;
                
                LET vnum_credito = '';
                LET vproducto = '';
                LET vnombre_prod = '';
                LET vnum_tarjeta = '';
                LET vsdo_disp = 0.00;
                LET vsdo_corte = 0.00;
                LET vpago_min = 0.00;
                LET vpagonogenint = 0.00;
                LET vfechlimpago = '';
                LET vstatus_cred = '';
            END FOREACH;
            
            -- // GENERA REGISTRO EN BITACORA 
            SELECT MAX(secuencia)
              INTO vsecmax
              FROM bdinteg:"informix".si_bm_bitacora
             WHERE DATE(fech_oper) = CURRENT::DATE
               AND id_session = pSessionToken;
               
            LET vsecmax = vsecmax + 1;
            
            INSERT INTO bdinteg:"informix".si_bm_bitacora(id_session, fech_oper, numcte, secuencia, id_oper, numcel, cuenta, foliosol)
            VALUES(pSessionToken, current, vnumcte, vsecmax, '1003', vnumcel, null, null);
            
            IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
                LET vCodRet1 = '11111';
                LET vStatus = '';
                LET vStatusDesc = 'Error en aplicativo.';
                IF vtransaccion = 1 THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF;
                RETURN vCodRet1, vStatus, vStatusDesc, 
                       vCuenta1, vTermCta1, vNombreCta1, vSdoDispCta1, vSdoCorteCta1, vPagoMinCta1, vPagoNoGenIntCta1, vFechaLimPagoCta1,
                       vCuenta2, vTermCta2, vNombreCta2, vSdoDispCta2, vSdoCorteCta2, vPagoMinCta2, vPagoNoGenIntCta2, vFechaLimPagoCta2,
                       vCuenta3, vTermCta3, vNombreCta3, vSdoDispCta3, vSdoCorteCta3, vPagoMinCta3, vPagoNoGenIntCta3, vFechaLimPagoCta3,
                       vCuenta4, vTermCta4, vNombreCta4, vSdoDispCta4, vSdoCorteCta4, vPagoMinCta4, vPagoNoGenIntCta4, vFechaLimPagoCta4,
                       vCuenta5, vTermCta5, vNombreCta5, vSdoDispCta5, vSdoCorteCta5, vPagoMinCta5, vPagoNoGenIntCta5, vFechaLimPagoCta5,
                       vCuenta6, vTermCta6, vNombreCta6, vSdoDispCta6, vSdoCorteCta6, vPagoMinCta6, vPagoNoGenIntCta6, vFechaLimPagoCta6,
                       vCuenta7, vTermCta7, vNombreCta7, vSdoDispCta7, vSdoCorteCta7, vPagoMinCta7, vPagoNoGenIntCta7, vFechaLimPagoCta7,
                       vCuenta8, vTermCta8, vNombreCta8, vSdoDispCta8, vSdoCorteCta8, vPagoMinCta8, vPagoNoGenIntCta8, vFechaLimPagoCta8,
                       vCuenta9, vTermCta9, vNombreCta9, vSdoDispCta9, vSdoCorteCta9, vPagoMinCta9, vPagoNoGenIntCta9, vFechaLimPagoCta9,
                       vCuenta10, vTermCta10, vNombreCta10, vSdoDispCta10, vSdoCorteCta10, vPagoMinCta10, vPagoNoGenIntCta10, vFechaLimPagoCta10;
            END IF;
        END IF;
    ELSE
        LET vCodRet1 = '11111';
        LET vStatus = '';
        LET vStatusDesc = 'Usuario no firmado.';
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vCodRet1, vStatus, vStatusDesc, 
               vCuenta1, vTermCta1, vNombreCta1, vSdoDispCta1, vSdoCorteCta1, vPagoMinCta1, vPagoNoGenIntCta1, vFechaLimPagoCta1,
               vCuenta2, vTermCta2, vNombreCta2, vSdoDispCta2, vSdoCorteCta2, vPagoMinCta2, vPagoNoGenIntCta2, vFechaLimPagoCta2,
               vCuenta3, vTermCta3, vNombreCta3, vSdoDispCta3, vSdoCorteCta3, vPagoMinCta3, vPagoNoGenIntCta3, vFechaLimPagoCta3,
               vCuenta4, vTermCta4, vNombreCta4, vSdoDispCta4, vSdoCorteCta4, vPagoMinCta4, vPagoNoGenIntCta4, vFechaLimPagoCta4,
               vCuenta5, vTermCta5, vNombreCta5, vSdoDispCta5, vSdoCorteCta5, vPagoMinCta5, vPagoNoGenIntCta5, vFechaLimPagoCta5,
               vCuenta6, vTermCta6, vNombreCta6, vSdoDispCta6, vSdoCorteCta6, vPagoMinCta6, vPagoNoGenIntCta6, vFechaLimPagoCta6,
               vCuenta7, vTermCta7, vNombreCta7, vSdoDispCta7, vSdoCorteCta7, vPagoMinCta7, vPagoNoGenIntCta7, vFechaLimPagoCta7,
               vCuenta8, vTermCta8, vNombreCta8, vSdoDispCta8, vSdoCorteCta8, vPagoMinCta8, vPagoNoGenIntCta8, vFechaLimPagoCta8,
               vCuenta9, vTermCta9, vNombreCta9, vSdoDispCta9, vSdoCorteCta9, vPagoMinCta9, vPagoNoGenIntCta9, vFechaLimPagoCta9,
               vCuenta10, vTermCta10, vNombreCta10, vSdoDispCta10, vSdoCorteCta10, vPagoMinCta10, vPagoNoGenIntCta10, vFechaLimPagoCta10;
    END IF;
    
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK;
    END IF;

    RETURN vCodRet1, vStatus, vStatusDesc, 
           vCuenta1, vTermCta1, vNombreCta1, vSdoDispCta1, vSdoCorteCta1, vPagoMinCta1, vPagoNoGenIntCta1, vFechaLimPagoCta1,
           vCuenta2, vTermCta2, vNombreCta2, vSdoDispCta2, vSdoCorteCta2, vPagoMinCta2, vPagoNoGenIntCta2, vFechaLimPagoCta2,
           vCuenta3, vTermCta3, vNombreCta3, vSdoDispCta3, vSdoCorteCta3, vPagoMinCta3, vPagoNoGenIntCta3, vFechaLimPagoCta3,
           vCuenta4, vTermCta4, vNombreCta4, vSdoDispCta4, vSdoCorteCta4, vPagoMinCta4, vPagoNoGenIntCta4, vFechaLimPagoCta4,
           vCuenta5, vTermCta5, vNombreCta5, vSdoDispCta5, vSdoCorteCta5, vPagoMinCta5, vPagoNoGenIntCta5, vFechaLimPagoCta5,
           vCuenta6, vTermCta6, vNombreCta6, vSdoDispCta6, vSdoCorteCta6, vPagoMinCta6, vPagoNoGenIntCta6, vFechaLimPagoCta6,
           vCuenta7, vTermCta7, vNombreCta7, vSdoDispCta7, vSdoCorteCta7, vPagoMinCta7, vPagoNoGenIntCta7, vFechaLimPagoCta7,
           vCuenta8, vTermCta8, vNombreCta8, vSdoDispCta8, vSdoCorteCta8, vPagoMinCta8, vPagoNoGenIntCta8, vFechaLimPagoCta8,
           vCuenta9, vTermCta9, vNombreCta9, vSdoDispCta9, vSdoCorteCta9, vPagoMinCta9, vPagoNoGenIntCta9, vFechaLimPagoCta9,
           vCuenta10, vTermCta10, vNombreCta10, vSdoDispCta10, vSdoCorteCta10, vPagoMinCta10, vPagoNoGenIntCta10, vFechaLimPagoCta10;
    
    END;
    
END PROCEDURE
DOCUMENT
'MODIFICADO:            Donovan F. Torres Landeros',
'ULTIMA MODIFICACION:   2025/07/09',
'RAZON:                 Se agrega la nueva variable sdo_sbc (saldo buen cobro)',
'                       a la operacion aritmetica para el nuevo calculo de',
'                       saldo disponible.',
'PROYECTO:              RQM 09 704   Cobranza Automatica en cuentas de captacion',
'BD:                    bdinteg',
'VER:                   1.2';

CREATE PROCEDURE "informix".sp_alta_solicitud_movil_online_pba_1_jlh(
pproductos         	CHAR(120),
pnumcte            	CHAR(20),
pap_nombre1        	CHAR(26),
pap_nombre2        	CHAR(26),
pap_apell_paterno  	CHAR(26),
pap_apell_materno  	CHAR(26),
pap_sexo           	CHAR(1),
pap_fecha_nac      	CHAR(10),
pap_rfc            	CHAR(13),
pemail             	CHAR(100),
ptelefono_casa     	CHAR(10),
ptelefono          	CHAR(10),
pcarrier           	CHAR(1),
ppais_nac          	CHAR(3),
pap_cod_postal     	CHAR(5),
pap_id_estado         	CHAR(2),
pap_id_ciudad         	CHAR(3),
pap_id_colonia        	CHAR(10),
pap_id_municipio      	CHAR(5),
pap_id_calle          	CHAR(40),
pnumero_exterior	CHAR(10),
pnumero_interior	CHAR(10),
pentre_calles		CHAR(40),
pcomplemento		CHAR(80),
ptarjeta_de_credito_activa	CHAR(1),
pultimos_cuatro_digitos	CHAR(4),
pcredito_hipotecario	CHAR(1),
pcredito_automotriz		CHAR(1),
pfirma_buro        	CHAR(1),
pescolaridad       	CHAR(2),
pestado_civil       CHAR(1),
ptpo_edo_civil     	CHAR(2),
pmeses_edo_civil   	CHAR(2),
ptipo_residencia   	CHAR(1),
ptiempo_domicilio  	CHAR(2),
ppers_domicilio    	CHAR(2),
ppers_trabajan     	CHAR(2),
ppers_dependen     	CHAR(2),
pempresa           	CHAR(60),
ptiempo_trabajo    	CHAR(2),
ptiempo_trab_ant   	CHAR(2),
pactividad         	CHAR(2),
psubactividad      	CHAR(2),
pnivel_ingresos    	CHAR(8),
ptel_trabajo       	CHAR(10),
pprimer_nombre_referencia	CHAR(26),
psegundo_nombre_referencia	CHAR(26),	
pprimer_apellido_referencia	CHAR(26),
psegundo_apellido_referencia	CHAR(26),
pfecha_de_nacimiento_referencia	DATE,
pgenero_referencia				CHAR(1),
pparentesco_referencia			CHAR(2),
ptelefono_celular_referencia	CHAR(13),
pejecutivo         	CHAR(8),
pnumero_control         	CHAR(25),
pfecha_hora        	DATETIME YEAR to FRACTION(5)
)

    RETURNING 
          CHAR(4)       as vcodret1,
		  CHAR(120)     as vmsjresp,
		  CHAR(2)       as vcodsolbcpl,
		  CHAR(40)      as vdescsolbcpl,
		  CHAR(255)     as vmotivobcpl,
		  CHAR(4)       as vproductobcpl,
		  CHAR(20)      as vfoliobcpl,
		  CHAR(2)       as vcodsolcpl,
		  CHAR(40)      as vdescsolcpl,
		  CHAR(255)     as vmotivocpl,
		  CHAR(4)       as vproductocpl,
		  CHAR(20)      as vfoliocpl;
         
    DEFINE vcodret1 CHAR(4);
	DEFINE vmsjresp CHAR(120);
	DEFINE vcodsolbcpl CHAR(2);
	DEFINE vdescsolbcpl CHAR(40);
	DEFINE vmotivobcpl CHAR(255);
	DEFINE vproductobcpl CHAR(4);
	DEFINE vfoliobcpl CHAR(20);
	DEFINE vcodsolcpl CHAR(2);
	DEFINE vdescsolcpl CHAR(40);
	DEFINE vmotivocpl CHAR(255);
	DEFINE vproductocpl CHAR(4);
	DEFINE vfoliocpl CHAR(20);
	
    DEFINE sql_err  INTEGER;
    DEFINE isam_err INTEGER;
    DEFINE desc_err CHAR(50);
	
    LET vcodret1 = '0000';
	LET vmsjresp = 'Consulta exitosa';
	LET vcodsolbcpl = 'PA';
	LET vdescsolbcpl = 'Pre autorizada';
	LET vmotivobcpl = '';
	LET vproductobcpl = '6001';
	LET vfoliobcpl = '11111111';
	LET vcodsolcpl = 'PA';
	LET vdescsolcpl = 'Pre autorizada';
	LET vmotivocpl = '';
	LET vproductocpl = '6500';
	LET vfoliocpl = '55555555';
	
    LET sql_err	 = 0;
    LET isam_err = 0;
    LET desc_err = '';

    BEGIN
	
		ON EXCEPTION SET sql_err, isam_err, desc_err
			--SET DEBUG FILE TO "/informix/LIP/sp_alta_solicitud_movil_online.out";
			--TRACE ON;
			IF sql_err <> 0 THEN
				LET vcodret1 = sql_err;
				LET vmsjresp = isam_err;
				--LET vmsjresp = desc_err;
				RETURN vcodret1,vmsjresp,vcodsolbcpl,vdescsolbcpl,vmotivobcpl,vproductobcpl,vfoliobcpl,vcodsolcpl,vdescsolcpl,vmotivocpl,vproductocpl,vfoliocpl;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO "/informix/LIP/logs/sp_alta_solicitud_movil_online.out";
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		INSERT INTO informix.si_solicitud_movil_online(productos, numcte, ap_nombre1, ap_nombre2, ap_apell_paterno, ap_apell_materno, ap_sexo, ap_fecha_nac, ap_rfc, email, telefono_casa, telefono, carrier, pais_nac, ap_cod_postal, ap_id_estado, ap_id_ciudad, ap_id_colonia, ap_id_municipio, ap_id_calle, num_exterior, num_interior, entre_calles, complemento, tdc_activa, cuatro_digitos, credito_hipotecario, credito_automotriz, firma_buro, escolaridad, estado_civil, tpo_edo_civil, meses_edo_civil, tipo_residencia, tpo_domicilio, pers_domicilio, pers_trabajan, pers_dependen, empresa, tpo_trabajo, tpo_trab_ant, actividad, subactividad, nivel_ingresos, tel_trabajo, nombre1_ref, nombre2_ref, apell_paterno_ref, apell_materno_ref, fech_nac_ref, genero_ref, parentesco_ref, tel_celular_ref, ejecutivo, numero_control, fecha_hora)
		VALUES(pproductos,pnumcte,pap_nombre1,pap_nombre2,pap_apell_paterno,pap_apell_materno,pap_sexo,pap_fecha_nac,pap_rfc,pemail,ptelefono_casa,ptelefono,
				pcarrier,ppais_nac,pap_cod_postal,pap_id_estado,pap_id_ciudad,pap_id_colonia,pap_id_municipio,pap_id_calle,pnumero_exterior,pnumero_interior,
				pentre_calles,pcomplemento,ptarjeta_de_credito_activa,pultimos_cuatro_digitos,pcredito_hipotecario,pcredito_automotriz,pfirma_buro,pescolaridad,
				pestado_civil,ptpo_edo_civil,pmeses_edo_civil,ptipo_residencia,ptiempo_domicilio,ppers_domicilio,ppers_trabajan,ppers_dependen,pempresa,ptiempo_trabajo,
				ptiempo_trab_ant,pactividad,psubactividad,pnivel_ingresos,ptel_trabajo,pprimer_nombre_referencia,psegundo_nombre_referencia,pprimer_apellido_referencia,
				psegundo_apellido_referencia,pfecha_de_nacimiento_referencia,pgenero_referencia,pparentesco_referencia,ptelefono_celular_referencia,pejecutivo,pnumero_control,pfecha_hora);

		
		RETURN vcodret1,vmsjresp,vcodsolbcpl,vdescsolbcpl,vmotivobcpl,vproductobcpl,vfoliobcpl,vcodsolcpl,vdescsolcpl,vmotivocpl,vproductocpl,vfoliocpl;
	
	END;
	
END PROCEDURE;