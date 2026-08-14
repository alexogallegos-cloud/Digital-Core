create procedure "informix".consintegpba(pempresa     char(3),
                           pnum_cte     char(20),
			   psucursal    char(4),
			   pusuario     char(8),
			   prenglon     smallint)
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


begin
   on exception set sql_err
      if sql_err <> 0 then
	 let cod_ret = sql_err;
         return cod_ret,v_completo,v_sistema,v_cuenta,v_sucursal,
		v_producto,v_fecha_alta,v_fecha_venc,v_monto1,v_monto2,
		v_calle,v_colonia,v_delega;
      end if
   end exception;


   SET ISOLATION TO DIRTY READ;

-- ***********************************************************************
    select numcte,apell_paterno,apell_materno,
       nombre1,razon_social,tpo_persona
       into v_numero,v_paterno,v_materno,
       v_nombre1,v_razon,v_tpersona
       from si_cliente
	where numcte=pnum_cte;

	if v_numero is null then
	   let cod_ret = "137";
           return cod_ret,v_completo,v_sistema,v_cuenta,v_sucursal,
	          v_producto,v_fecha_alta,v_fecha_venc,v_monto1,v_monto2,
	          v_calle,v_colonia,v_delega;
	end if

       if (v_razon is null) or (trim(v_razon) = "") then
          let v_completo = trim(v_paterno)||" "||trim(v_materno)||
			   " "||trim(v_nombre1);
	else
          let v_completo = v_razon;
       end if

-- ***************************************************************************
-- Verifica si debe generar la tabla de consulta
-- ***************************************************************************
--   if prenglon = 0 then
      delete from si_consinteg
      where sucursal = psucursal and usuario = pusuario and
	    numcte  = pnum_cte;
      -- *********************************************************************
      -- Extrae la informacion del Sistema de Cheques
      -- *********************************************************************
      foreach
         select mc.cuenta,sucursal,mc.producto||" "||pr.nombre,fecha_alta,
	        dia_sdo_pos,acum_sdo_pos,sdo_actual,sdo_retenido,
	        sdo_cong,numerocalle,numerocolonia,numerociudad,
                CASE
                 WHEN status_cta = "1" and marca_ret ="0" then
                      "Sin Deposito Inicial"
                 WHEN status_cta ="1" and marca_ret ="1" then
                      "Activa"
                 WHEN status_cta ="2" then
                      "Cancelada"
                 WHEN status_cta = "3" then
                      "Bloqueada"
                END
           into v_cuenta,v_sucursal,v_producto,v_fecha_alta,
	        vc_dia_sdo_pos,vc_acum_sdo_pos,vc_sdo_actual,vc_sdo_retenido,
	        vc_sdo_cong,vnocalle,vnocolonia,vnociudad, v_delega
         from bdicheq:sc_maechq mc,bdicheq:sc_maenoc mn,
              bdicheq:sc_producto pr,outer si_direcciones di
         where num_cte = pnum_cte and
	       mc.cuenta = mn.cuenta and mc.producto = pr.producto and
	       numcte = num_cte and secuencia = direcc_envio
         order by mc.cuenta
         if vc_dia_sdo_pos > 0 then
            let v_sdo_prom = vc_acum_sdo_pos / vc_dia_sdo_pos;
         else
	    let v_sdo_prom = 0;
         end if
         let v_sdo_disp = vc_sdo_actual - vc_sdo_retenido - vc_sdo_cong;
         let v_monto1   = v_sdo_prom;
         let v_monto2   = v_sdo_disp;

	if v_monto2 is null then
		let v_monto2 = 0;
	end if

	if v_monto1 is null then
		let v_monto1 = 0;
	end if

        -- Extrae la Direccion Coppel
        select nvl(nombrecalle,"") into v_calle
        From si_catcalles where numerocalle = vnocalle;
        Select nvl(nombrezona,"")
        into v_colonia
        From si_catzonas
        where numerociudad = vnociudad and numerocolonia = vnocolonia;
        if v_colonia is null then
           let v_colonia = "";
        end if

         --Graba la informacion en la tabla temporal de consulta integral
         let v_renglon = v_renglon + 1;
         insert into si_consinteg
         values(psucursal,pusuario,v_renglon,pnum_cte,"01",v_cuenta,
	        v_sucursal,v_producto,v_fecha_alta,v_fecha_alta,
	        v_monto2,v_monto1,v_calle,v_colonia,v_delega);
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
              bdinvers:sv_instrum pr,outer si_direcciones di
         where mv.num_cte = pnum_cte
	 and mv.status_cta="1" and mv.cod_instrum = pr.cod_instrum
	 and numcte = pnum_cte and di.secuencia = direcc_envio
         order by cuenta
         let v_monto2   = vi_intereses - vi_isr;

	if v_monto2 is null then
		let v_monto2 = 0;
	end if

	if v_monto1 is null then
		let v_monto1 = 0;
	end if

        -- Extrae la Direccion Coppel
        select nvl(nombrecalle,"") into v_calle
        From si_catcalles where numerocalle = vnocalle;
        Select nvl(nombrezona,"")
        into v_colonia
        From si_catzonas
        where numerociudad = vnociudad and numerocolonia = vnocolonia;
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
    end foreach
      -- *********************************************************************
      -- Extrae la informacion del Sistema de Credito
      -- *********************************************************************

      foreach
         select mc.num_credito,sucursal,mc.num_producto||" "||pr.nombre_prod,
                fecha_apertura,
                fecha_vencim,sdo_cap_insoluto,sdo_no_exig,sdo_exig_int,
	        DECODE(status_cred,"AA","Activo", "BA","Suspendido",
				   "BT","Suspendido", "FF", "Liquidado",
				   "CC","Problematico","Convenio")
            into v_cuenta,v_sucursal,v_producto,v_fecha_alta,
	         v_fecha_venc,v_monto1,vd_no_exig,vd_exig, v_delega
            from bdicred:sd_maecred mc,bdicred:sd_maesdos ms,
                 bdicred:sd_definicion pr
            where numcte = pnum_cte and mc.num_credito = ms.num_credito and
                  mc.num_producto = pr.num_producto
            order by 1
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
            values(psucursal,pusuario,v_renglon,pnum_cte,"06",v_cuenta,
	           v_sucursal,v_producto,v_fecha_alta,v_fecha_venc,
	           v_monto1,v_monto2,v_calle,v_colonia,v_delega);
      end foreach
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
   if v_numero <= 0 then
      let cod_ret = "127";
      if v_fecha_venc is null then
         let v_fecha_venc = today;
      end if
      return cod_ret,v_completo,v_sistema,v_cuenta,v_sucursal,
	     v_producto,v_fecha_alta,v_fecha_venc,v_monto1,v_monto2,
	     v_calle,v_colonia,v_delega;
   end if
   foreach
      select sistema,cuenta,sucursal_cta,producto,fecha_alta,
	     fecha_venc,importe_1,importe_2,calle,colonia,delegacion
	     into v_sistema,v_cuenta,v_sucursal,v_producto,v_fecha_alta,
	     v_fecha_venc,v_monto1,v_monto2,v_calle,v_colonia,v_delega
      from si_consinteg
      where sucursal = psucursal and
	    usuario  = pusuario  and
	    numcte  = pnum_cte  and
	    renglon  > prenglon
      if v_fecha_venc is null then
         let v_fecha_venc = today;
      end if
      return cod_ret,v_completo,v_sistema,v_cuenta,v_sucursal,
		v_producto,v_fecha_alta,v_fecha_venc,v_monto1,
		v_monto2,v_calle,v_colonia,v_delega WITH RESUME;
   end foreach
end
end procedure
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".sp_valida_reversada (pIdSucursal CHAR(4),
                                                 pFolioOperacion CHAR(16),
                                                 pTipoOperacion CHAR(2))
                                                 
RETURNING CHAR(5) AS cod_ret;

--- DECLARACION DE VARIABLES

	DEFINE vCodRet     CHAR(5);
	DEFINE iSqlErr     INTEGER;
      
  DEFINE vCiclo      CHAR(1);
    
			
--- INICIALIZACION DE VARIABLES


	LET vCodret       = '00000';
	LET iSqlErr       = '0';
      
  LET vCiclo        = '';
    
     --****************************************************************
     -- Creado por Raúl Ramírez    07/Septiembre/2010
     -- Proceso para validar transacciones reversadas para la traducción
     -- de boletos a un detalle de boletos
     --****************************************************************

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				 LET vCodRet = iSqlErr;
				RETURN vCodret;		
			END IF;
		END EXCEPTION;

       -- SET DEBUG FILE TO "/ids10_uc9/raul/sorteo/sp_valida_reversada.out";
       -- TRACE ON;


    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    

        IF pTipoOperacion = '10' THEN 
						--Para debito
						--IF EXISTS (SELECT {+INDEX (bdicheq:sc_movdia idx_movdia2a)} -- BGM 09-Nov-2010: se coloca directiva
						                 --empresa, cuenta, fech_alt, cancelad, transacc, folio_suc 
									     --FROM bdicheq:sc_movdia
									     --WHERE empresa is not null
										 --WHERE folio_suc  = pFolioOperacion     -- BGM 09-Nov-2010: se cambia condición
									     -- AND cuenta is not null    			-- BGM 09-Nov-2010: se comenta condición
									     --AND empresa = '001'
									     --AND fech_alt is not null   			-- BGM 09-Nov-2010: se comenta condición
									     --AND transacc is not null   			-- BGM 09-Nov-2010: se comenta condición
									     --AND cancelad = 'S') THEN
			IF EXISTS (SELECT {+INDEX (bdinteg:si_movreversados idx_si_movrever)} empresa, folio_suc 
				FROM bdinteg:si_movreversados
				WHERE empresa = '001'
				AND folio_suc  = pFolioOperacion     -- BGM 16-Nov-2010: se cambia tabla a si_movreversados
				AND tipo_mov = pTipoOperacion) THEN
				LET vCiclo = 'S';
						--ELSE
						--	    IF EXISTS (SELECT {+INDEX (bdicheq:sc_movdia idx_movdia2a)}  -- BGM 09-Nov-2010: se coloca directiva
						--		  empresa,folio_suc    
                        --    FROM bdicheq:sc_movdia
						--				         WHERE folio_suc  = pFolioOperacion
						--				         AND  empresa = '001'
						--				         AND cancelad = 'S') THEN
						--                
                        --     LET vCiclo = 'S';
						--	    END IF;	
			END IF;
        END IF;
        IF pTipoOperacion = '11' THEN
          	
						--IF vCiclo <> 'S' THEN
              --Para credito
							--IF EXISTS (SELECT {+INDEX (bdicred:sd_movdia mov2)}  -- BGM 09-Nov-2010: se coloca directiva
							 --folio_suc 
                        --FROM bdicred:sd_movdia
								        --WHERE sucursal = pIdSucursal
								        --AND  folio_suc = pFolioOperacion
								        --AND reversado = 'S') THEN
						            --LET vCiclo = 'S';								
						  --ELSE
						    	--IF EXISTS(SELECT {+INDEX (bdicred:sd_movdia mov2)}  -- BGM 09-Nov-2010: se coloca directiva
								   --folio_suc --, codigo_fun, codigo_ref             -- BGM 09-Nov-2010: se omiten datos que no se usan
                              --FROM bdicred:sd_movdia 
									   		--	    WHERE folio_suc = pFolioOperacion 
										    --		AND codigo_fun is not null
										    --		AND codigo_ref is not null
										  	--	    AND reversado = 'S') THEN
			IF EXISTS (SELECT {+INDEX (bdinteg:si_movreversados idx_si_movrever)} empresa, folio_suc 
				FROM bdinteg:si_movreversados
				WHERE empresa = '001'
				AND folio_suc  = pFolioOperacion     -- BGM 16-Nov-2010: se cambia tabla a si_movreversados
				AND tipo_mov = pTipoOperacion) THEN
				LET vCiclo = 'S'; 
				   
			END IF;
		END IF;	
		
          	
		IF vCiclo = 'S' THEN
             LET vCodRet = '00101';
             --LET vMensaje = 'Folio Reversado';
        END IF;
END
    RETURN vCodret; --, vMensaje;

END PROCEDURE;