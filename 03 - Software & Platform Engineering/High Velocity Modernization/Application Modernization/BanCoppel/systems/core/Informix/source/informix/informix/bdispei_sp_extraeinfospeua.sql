create procedure "informix".sp_extraeinfospeua(ve_fecha char(10),
                                       ve_estatus char(1),
                                       ve_tipomov char(2),
                                       ve_tipocon char(1))

{
 Para el caso de que tipomov sea igual a cambios no debera
 incluir aquellas operaciones con status igual a pendientes
 para el resto de las consultas si
}

returning char(5),     -- cod_ret
          char(30),    -- clave_rastreo
 	  money(16,2), -- importe
 	  char(4),     -- banco
 	  char(30),    -- nombre1
 	  char(20),    -- cuenta
 	  char(30),    -- nombre2
 	  char(1);     -- estatus


define cod_ret            char(5);
define sql_err            integer;
define vt_clave_rastreo   char(30);
define vt_importe         money(16,2);
define vt_banco           char(4);
define vt_nombre1         char(30);
define vt_cuenta          char(20);
define vt_nombre2         char(30);
define vt_estatus         char(1);
define vt_fecha           date;

define vt_fechaSPEIBco	  date;
define ve_estatusLiq	  char(1);
define ve_estatusXConf	  char(1);
define ve_estatusDev	  char(1);

--set debug file to "/tmp/extrainfospeua.out";
--trace on;

begin
  on exception set sql_err
    if sql_err <> 0 then
      let cod_ret = sql_err;
      return cod_ret,'',0,'0000','','','','';
    end if;
  end exception;

  let cod_ret = "000";

  let vt_clave_rastreo = '';
  let vt_importe = 0;
  let vt_banco = '0000';
  let vt_nombre1 = '';
  let vt_cuenta = '';
  let vt_nombre2 = '';
  let vt_estatus = '';
  let ve_estatusLiq = '';
  let ve_estatusXConf = '';
  let ve_estatusDev = '';

  if (ve_fecha is null or ve_fecha  = '') or
     (ve_estatus is null ) or
     (ve_tipomov is null or ve_tipomov = '') or
     (ve_tipocon is null or ve_tipocon = '') then
  --if ve_fecha is null or ve_fecha = '' or (ve_tipomov not in('CA','CL')) or ve_tipomov is null then
    let cod_ret = "110";
    RETURN cod_ret,vt_clave_rastreo,vt_importe,vt_banco,
    vt_nombre1,vt_cuenta,vt_nombre2,vt_estatus;
  end if;

  {
  if ve_estatus not in ('T','E','P','R','D','') or
     ve_tipocon not in ('E','S') or ve_tipocon is null  or
     ve_estatus is null then
    let cod_ret = "110";
    RETURN cod_ret,vt_clave_rastreo,vt_importe,vt_banco,
    vt_nombre1,vt_cuenta,vt_nombre2,vt_estatus;
  end if;
  }

  --Obtiene la fecha de liberacion de las op Bco-Bco en SPEI.
  SELECT to_date(vchrvalor, '%d/%m/%Y') INTO vt_fechaSPEIBco
  FROM bdispei:tblparametros
  WHERE vchrcveparametro = 'FECHA_LIB_BCO_BCO';

  if ve_tipocon = 'E' then
	let vt_fecha = ve_fecha;
  end if


  if ve_tipocon == 'E' then      				-- ENTRADAS
    if ve_estatus not in ('T','D','R','P') then
      let cod_ret = "200";
      RETURN cod_ret,vt_clave_rastreo,vt_importe,vt_banco,
      vt_nombre1,vt_cuenta,vt_nombre2,vt_estatus;
    end if

    if ve_tipomov == 'CL' then						-- ENTRADAS DE CLIENTES
      if ve_estatus <> 'T' then							-- ENTRADAS CLIENTES,     	
        --Operaciones Clientes SPEI
        if ve_estatus = 'P' then
        	let ve_estatus = 'A';
        end if;
        foreach reg for								-- SOLO EL STATUS SELECCIONADO
          select									-- OPERACIONES SPEI
            p1.vchrclaverastreo, p1.mnyimporte,
            lpad(''||intcvebsi, 3, '0'), p1.vchrnombreord,
            p1.vchrcuentabenef, p1.vchrnombrebenef,
            decode(p1.chrestatusenvio, 'A', 'P', p1.chrestatusenvio)
          into
            vt_clave_rastreo,vt_importe,
            vt_banco,vt_nombre1,
            vt_cuenta,vt_nombre2,
            vt_estatus
          from
            bdispei:tblpago p1,
            bdispei:tblbanco
          where
			p1.cvecesifbcoord = bdispei:tblbanco.cvecesif
          	and p1.chrsentidopago = 'R'
          	and (p1.intcvetipopago in (1, 5) or (p1.intcvetipopago = 0 and (select intcvetipopago from bdispei:tblpago p2 where p2.intpkpago = p1.intpkpagoorig) in (1, 5) ))
			and	lpad(nvl(p1.vchrcuentabenef, 0), 18, '0') not in (SELECT vchrcuenta FROM bdispei:tblctabansi)
			and p1.chrestatusenvio = ve_estatus
			and p1.dtfechavalor = vt_fecha
          RETURN cod_ret,vt_clave_rastreo,vt_importe,vt_banco,
  	  		vt_nombre1,vt_cuenta,vt_nombre2,vt_estatus
  	  		with resume;
        end foreach

      else									-- ENTRADAS CLIENTES,

		--Entradas clientes SPEI
        foreach reg for								-- SOLO EL STATUS SELECCIONADO
          select									-- OPERACIONES SPEI
            p1.vchrclaverastreo, p1.mnyimporte,
            lpad(''||intcvebsi, 3, '0'), p1.vchrnombreord,
            p1.vchrcuentabenef, p1.vchrnombrebenef,
            decode(p1.chrestatusenvio, 'A', 'P', p1.chrestatusenvio)
          into
            vt_clave_rastreo,vt_importe,
            vt_banco,vt_nombre1,
            vt_cuenta,vt_nombre2,
            vt_estatus
          from
            bdispei:tblpago p1,
            bdispei:tblbanco
          where
			p1.cvecesifbcoord = bdispei:tblbanco.cvecesif
          	and p1.chrsentidopago = 'R'
          	and (p1.intcvetipopago in (1, 5) or (p1.intcvetipopago = 0 and (select intcvetipopago from bdispei:tblpago p2 where p2.intpkpago = p1.intpkpagoorig) in (1, 5) ))
			and	lpad(nvl(p1.vchrcuentabenef, 0), 18, '0') not in (SELECT vchrcuenta FROM bdispei:tblctabansi)
			and p1.dtfechavalor = vt_fecha
          RETURN cod_ret,vt_clave_rastreo,vt_importe,vt_banco,
  	  		vt_nombre1,vt_cuenta,vt_nombre2,vt_estatus
  	  		with resume;
        end foreach

      end if;
    end if;

    if ve_tipomov == 'CA' then						-- ENTRADAS DE CAMBIOS
      if ve_estatus <> 'T' then							-- ENTRADAS CAMBIOS
        if ve_estatus = 'P' then
        	let ve_estatus = 'A';
        end if;
        foreach reg for								-- SOLO EL STATUS SELECCIONADO
          select									-- OPERACIONES SPEI
            '',mnyimporte,
            lpad(''||intcvebsi, 3, '0'),
            decode(intcvetipopago, 7, decode(vchrnombre, '', vchrnombrecorto, vchrnombre),
            vchrnombreord),
            '','',
            decode(chrestatusenvio, 'A', 'P', chrestatusenvio)
          into
            vt_clave_rastreo,vt_importe,
            vt_banco,vt_nombre1,
            vt_cuenta,vt_nombre2,
            vt_estatus
          from
            bdispei:tblpago,
            bdispei:tblbanco
          where
			bdispei:tblpago.cvecesifbcoord = bdispei:tblbanco.cvecesif
          	and chrsentidopago = 'R'
          	and ((intcvetipopago = 7 and intcvetpooperacion = 6)
			or	 (lpad(vchrcuentabenef, 18, '0') = '060320022770006074'))
			and chrestatusenvio = ve_estatus
			and dtfechavalor = vt_fecha
          RETURN cod_ret,vt_clave_rastreo,vt_importe,vt_banco,
  	  vt_nombre1,vt_cuenta,vt_nombre2,vt_estatus
  	  with resume;
        end foreach

      else									-- ENTRADAS CAMBIOS
        foreach reg for								-- TODOS LOS REGISTROS
          select									-- OPERACIONES SPEI
            '',mnyimporte,
            lpad(''||intcvebsi, 3, '0'),
            decode(intcvetipopago, 7, decode(vchrnombre, '', vchrnombrecorto, vchrnombre),
            vchrnombreord),
            '','',
            decode(chrestatusenvio, 'A', 'P', chrestatusenvio)
          into
            vt_clave_rastreo,vt_importe,
            vt_banco,vt_nombre1,
            vt_cuenta,vt_nombre2,
            vt_estatus
          from
            bdispei:tblpago,
            bdispei:tblbanco
          where
			bdispei:tblpago.cvecesifbcoord = bdispei:tblbanco.cvecesif
          	and chrsentidopago = 'R'
          	and ((intcvetipopago = 7 and intcvetpooperacion = 6)
			or	 (lpad(vchrcuentabenef, 18, '0') = '060320022770006074'))
			and dtfechavalor = vt_fecha
          RETURN cod_ret,vt_clave_rastreo,vt_importe,vt_banco,
  	  vt_nombre1,vt_cuenta,vt_nombre2,vt_estatus
  	  with resume;
        end foreach

      end if;
    end if;
  end if;

  if ve_tipocon == 'S' then					-- SALIDAS
    if ve_tipomov == 'CL' then						-- SALIDAS CLIENTES
      if ve_estatus <> 'E' and ve_estatus <> 'P' and ve_estatus <> '' and ve_estatus <> 'T' then
        let cod_ret = "200";
        RETURN cod_ret,vt_clave_rastreo,vt_importe,vt_banco,
        vt_nombre1,vt_cuenta,vt_nombre2,vt_estatus;
      end if;
      if ve_estatus <> 'T' then						-- SALIDAS CLIENTES

		--Operaciones clientes SPEI
		if ve_estatus = '' then
			let ve_estatus = 'N';
		end if;

		if ve_estatus = 'E' then
			let ve_estatusLiq = 'L';
			let ve_estatusXConf = 'S';
			let ve_estatusdev = 'D';
		end if;

        foreach reg for							-- SOLO STATUS SELECCIONADO
          select								-- OPERACIONES SPEI
            p1.vchrclaverastreo,p1.mnyimporte,
            lpad(''||intcvebsi, 3, '0'),p1.vchrnombreord,
            p1.vchrcuentaord,'',
            decode(p1.chrestatusenvio, 'L', 'E', 'S', 'E', 'D', 'E', 'N', '', p1.chrestatusenvio)
          into
            vt_clave_rastreo, vt_importe,
            vt_banco, vt_nombre1,
            vt_cuenta, vt_nombre2,
            vt_estatus
          from
            bdispei:tblpago p1,
            bdispei:tblbanco
          where
          	p1.cvecesifbcodest = bdispei:tblbanco.cvecesif
          	AND p1.chrsentidopago = 'E'
          	and p1.intcvetipopago = 1
            and (p1.chrestatusenvio = ve_estatus
            	or p1.chrestatusenvio = ve_estatusLiq
            	or p1.chrestatusenvio = ve_estatusXConf
            	or p1.chrestatusenvio = ve_estatusdev)
            and p1.dtfechavalor = to_date(trim(ve_fecha), '%d%m%Y')
          RETURN cod_ret,vt_clave_rastreo,vt_importe,vt_banco,
  	  vt_nombre1,vt_cuenta,vt_nombre2,vt_estatus
  	  with resume;
        end foreach

      else								-- SALIDAS CLIENTES
		--Salidas clientes SPEI
        foreach reg for
          select								-- OPERACIONES SPEI
            p1.vchrclaverastreo,p1.mnyimporte,
            lpad(''||intcvebsi, 3, '0'),p1.vchrnombreord,
            p1.vchrcuentaord,'',
            decode(p1.chrestatusenvio, 'L', 'E', 'S', 'E', 'D', 'E', 'N', '', p1.chrestatusenvio)
          into
            vt_clave_rastreo, vt_importe,
            vt_banco, vt_nombre1,
            vt_cuenta, vt_nombre2,
            vt_estatus
          from
            bdispei:tblpago p1,
            bdispei:tblbanco
          where
          	p1.cvecesifbcodest = bdispei:tblbanco.cvecesif
          	AND p1.chrsentidopago = 'E'
          	and p1.intcvetipopago = 1
            and p1.dtfechavalor = to_date(trim(ve_fecha), '%d%m%Y')
            and p1.chrestatusenvio not in ('C', 'X', 'Z')
          RETURN cod_ret,vt_clave_rastreo,vt_importe,vt_banco,
  	  vt_nombre1,vt_cuenta,vt_nombre2,vt_estatus
  	  with resume;
        end foreach

      end if
    end if;
    if ve_tipomov == 'CA' then						-- SALIDAS CAMBIOS
      if ve_estatus <> 'E' and ve_estatus <> '' and ve_estatus <> 'T' then
        let cod_ret = "200";
        RETURN cod_ret,vt_clave_rastreo,vt_importe,vt_banco,
        vt_nombre1,vt_cuenta,vt_nombre2,vt_estatus;
      end if;
      if ve_estatus <> 'T' then						-- SALIDAS CAMBIOS

		if ve_estatus = '' then
			let ve_estatus = 'N';
		end if;

		if ve_estatus = 'E' then
			let ve_estatusLiq = 'L';
			let ve_estatusXConf = 'S';
			let ve_estatusdev = 'D';
		end if;

        foreach reg for							-- SOLO STATUS SELECCIONADO
          select								-- OPERACIONES SPEI
            vchrclaverastreo,mnyimporte,
            lpad(''||intcvebsi, 3, '0'),
            decode(intcvetipopago, 7, decode(vchrnombre, '', vchrnombrecorto, vchrnombre),
            vchrnombrebenef),
            vchrcuentabenef,'',
            decode(chrestatusenvio, 'L', 'E', 'S', 'E', 'D', 'E', 'N', '', chrestatusenvio)
          into
            vt_clave_rastreo, vt_importe,
            vt_banco, vt_nombre1,
            vt_cuenta, vt_nombre2,
            vt_estatus
          from
            bdispei:tblpago,
            bdispei:tblbanco
          where
          	bdispei:tblpago.cvecesifbcodest = bdispei:tblbanco.cvecesif
          	AND chrsentidopago = 'E'
          	and ((intcvetipopago = 7 and intcvetpooperacion = 6)
          	or	 (intcvetipopago = 5 and chrtxop = '0001')) --Operaciones Bco-Ter de Divisas
            and (chrestatusenvio = ve_estatus
            	or chrestatusenvio = ve_estatusLiq
            	or chrestatusenvio = ve_estatusXConf
				or p1.chrestatusenvio = ve_estatusdev)
            and dtfechavalor = to_date(trim(ve_fecha), '%d%m%Y')
          RETURN cod_ret,vt_clave_rastreo,vt_importe,vt_banco,
  	  vt_nombre1,vt_cuenta,vt_nombre2,vt_estatus
  	  with resume;
        end foreach

      else								-- SALIDAS CAMBIOS

        foreach reg for							-- TODOS LOS ESTATUS
          select								-- OPERACIONES SPEI
            vchrclaverastreo,mnyimporte,
            lpad(''||intcvebsi, 3, '0'),
            decode(intcvetipopago, 7, decode(vchrnombre, '', vchrnombrecorto, vchrnombre),
            vchrnombrebenef),
            vchrcuentabenef,'',
            decode(chrestatusenvio, 'L', 'E', 'S', 'E', 'D', 'E', 'N', '', chrestatusenvio)
          into
            vt_clave_rastreo, vt_importe,
            vt_banco, vt_nombre1,
            vt_cuenta, vt_nombre2,
            vt_estatus
          from
            bdispei:tblpago,
            bdispei:tblbanco
          where
          	bdispei:tblpago.cvecesifbcodest = bdispei:tblbanco.cvecesif
          	and chrsentidopago = 'E'
          	and ((intcvetipopago = 7 and intcvetpooperacion = 6)
          	or	 (intcvetipopago = 5 and chrtxop = '0001')) --Operaciones Bco-Ter de Divisas
            and chrestatusenvio not in ('C', 'X', 'Z')
            and dtfechavalor = to_date(trim(ve_fecha), '%d%m%Y')
          RETURN cod_ret,vt_clave_rastreo,vt_importe,vt_banco,
  	  vt_nombre1,vt_cuenta,vt_nombre2,vt_estatus
  	  with resume;
        end foreach

      end if
    end if;
  end if;
  end
end procedure;