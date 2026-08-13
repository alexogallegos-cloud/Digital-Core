create procedure "informix".abono(pempresa char(3),
                       psucursal  char(4),
		       pusuario   char(8),
		       ptransacc  char(4),
		       ptransacc_suc char(4),
		       pfolio_suc char(16),
		       pcuenta    char(20),
		       pdocto     integer,
		       pmto_tot   money(14,2),
		       pmto_firme money(14,2),
		       pmto_sbc   money(14,2),
		       pmto_rem   money(14,2),
		       pdias_ret  smallint,
		       pdivisa    char(2))
   returning char(5),money(14,2);

   define v_sucursal char(4); 
   define v_plaza char(3);
   define vcodret char(5);
   define nat,v_status_cta,acept_ab,edo char(1);
   define mot char(2);
   define v_instrumento char(4);
   define v_fecha_alta,v_hoy date;
   define v_periodo char(1);
   define v_moneda char(2);
   define v_transvtopas1 char(4);
   define v_secuencia,v_contador smallint;
   define vtotal_sbc,monto_tran,sdo money(14,2);
   define hora datetime hour to fraction;
   define sql_err,isam_err int;
   define v_usuario char(8);
   define vfecha_hoy date;
begin
   on exception set sql_err,isam_err
      if sql_err <> 0 or isam_err <> 0 then
	 let vcodret = sql_err;
 	 return vcodret,sdo;
      end if;
   end exception;
   set isolation to dirty read;
   set lock mode to wait 3;
-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************
   let vcodret 	  = "000";
   let sdo 	  = 0;
   select fecha_hoy into vfecha_hoy
      from sv_fechas
      where empresa = pempresa;



-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************
if psucursal  = " " or
   psucursal is null or
   pusuario   = " " or
   pusuario is null or
   ptransacc  = " " or
   ptransacc is null or
   pfolio_suc = " " or
   pfolio_suc is null or
   pcuenta    = " " or
   pcuenta is null or
   pdocto     < 0     or
   pmto_tot   = 0     or
   pmto_tot is null or
   pmto_firme < 0     or
   pmto_firme is null or
   pmto_sbc   < 0     or
   pmto_sbc   is null     or
   pmto_rem   < 0     or
   pmto_rem   is null     or
   pdias_ret  < 0 then
   let vcodret = 110;
   return vcodret,sdo;
end if;

select ejecutivo into v_usuario from bdinteg:si_ejecut
   where ejecutivo = pusuario;

if v_usuario <> pusuario or v_usuario is null then
   let vcodret = "107";
   return vcodret,sdo;
end if

-- ****************************************************************************
-- Valida si se envia monto en remesa,debe indicarse dias de retencion
-- ****************************************************************************
if pmto_rem > 0  and pdias_ret = 0  then
   let vcodret = "114";
   return vcodret,sdo;
end if;

-- ****************************************************************************
-- Valida la suma de los montos
-- ****************************************************************************
let monto_tran = pmto_firme + pmto_sbc + pmto_rem;
if monto_tran != pmto_tot then
   let vcodret = "420";
   return vcodret,sdo;
end if;

-- ****************************************************************************
-- Valida exista la transaccion
-- ****************************************************************************
    select naturaleza into nat
    from bdinteg:si_transacc
    where empresa = pempresa and numero = ptransacc and sistema = "03";

if nat != "A" then
   let vcodret = "552";
   return vcodret,sdo;
end if;

-- ****************************************************************************
-- Extrae los datos de la cuenta de Inversion
-- ****************************************************************************
select  secuencia,cod_instrum,status_cta,motivo,capital,
	plaza,sucursal,fecha_alta
   into v_secuencia,v_instrumento,v_status_cta,mot,
       	sdo,v_plaza,v_sucursal,v_fecha_alta
   from sv_maeinv
   where empresa = pempresa and cuenta = pcuenta and status_cta <> "4";
if v_secuencia is null then
   let vcodret = "100";
   return vcodret,sdo;
end if;
if v_status_cta = 2 then
   let vcodret = "200";
   return vcodret,sdo;
elif
   v_status_cta = 3 then
     select abono into acept_ab
     from sv_bloqueo where codigo = mot;
     if acept_ab = "N" then
	let vcodret = "301";
	return vcodret,sdo;
     end if;
end if;

-- ****************************************************************************
-- Extrae el tipo de instrumento
-- ****************************************************************************
select moneda,per_acred_int,trans_vtopas1
   into v_moneda,v_periodo,v_transvtopas1
   from sv_instrum
   where empresa = pempresa and cod_instrum=v_instrumento;
  if v_periodo is null then
	let vcodret="337";
	return vcodret,sdo;
  else
	if v_moneda !=pdivisa then
		let vcodret="951";
		return vcodret,sdo;
	else
		if pmto_tot!=sdo then
			let vcodret="370";
			return vcodret,sdo;
		end if
	end if
  end if
  select fecha_hoy into v_hoy from sv_fechas where empresa = pempresa;
  if sdo!=pmto_tot then
     let vcodret="370";
     return vcodret,sdo;
  end if
  if v_fecha_alta < v_hoy then
     let vcodret="365";
     return vcodret,sdo;
  end if
  select count(*) into v_contador
     from sv_movdia
     where empresa = pempresa and cuenta = pcuenta and cancelad <> "S";

  if v_contador is not null and v_contador > 0 then
	let vcodret="360";
	return vcodret,sdo;
  end if;

  if pmto_sbc > 0 then
     select sum(monto) into vtotal_sbc
        from bdicheq:sc_docret_sbc
        where empresa = pempresa and siglas = "SV" and cuenta = pcuenta and
              folio_suc = pfolio_suc and fecha_alta = vfecha_hoy;
     if vtotal_sbc <> pmto_sbc then
        let vcodret="401";
        return vcodret,sdo;
     end if;
  end if

  let hora = current hour to fraction;
  if v_transvtopas1 <> "" and v_transvtopas1 is not null then
     insert into sv_movdia
        values (pempresa,0,pfolio_suc,v_plaza,psucursal,pusuario,v_hoy,
           hora,v_transvtopas1,v_sucursal,pcuenta,v_secuencia,v_instrumento,
           pdias_ret,pmto_tot,pmto_firme,pmto_sbc,pmto_rem,
           "",sdo,ptransacc_suc);
  end if
  insert into sv_movdia
     values (pempresa,0,pfolio_suc,v_plaza,psucursal,pusuario,v_hoy,
        hora,ptransacc,v_sucursal,pcuenta,v_secuencia,v_instrumento,
        pdias_ret,pmto_tot,pmto_firme,pmto_sbc,pmto_rem,
        "",sdo,ptransacc_suc);
  update sv_maeinv
     set status_cta = "1",
         sdo_retenido = sdo_retenido + pmto_sbc
     where empresa = pempresa and cuenta = pcuenta and
           secuencia = v_secuencia;
return vcodret,sdo;
end;
end procedure;