create procedure "informix".sp_rcda_extrac_movdia()
RETURNING CHAR (05) AS COD_RET,
		  CHAR (80) AS MENSAJE;
		  
		--variables 
		DEFINE cod_ret			char(04);
		DEFINE vmensaje			char(80);	
		
		  
		--variables de control de errores
		DEFINE  SQL_ERR          INTEGER;
		DEFINE  ISAM_ERR         INTEGER;
		DEFINE  ERROR_INFO       VARCHAR(80);		  
		  
		  
BEGIN
	ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
		IF SQL_ERR  <> 0 THEN
			LET cod_ret    = SQL_ERR;
			LET vmensaje  = ERROR_INFO;
			return cod_ret, vmensaje;
	    end if 
   END EXCEPTION;	
	set isolation to dirty read;
	
	let cod_ret  = '000';
	let vmensaje ='OK';	
   
 --limpiar tablas 
  truncate table mi_rcda_movdeb;
  truncate table mi_rcda_movcred;
  
---Extracción de movimientos débito

	execute procedure "informix".sp_bitacora_rcda('rcda_extmov_debito', 1)
	into cod_ret, vmensaje;
	if trim(cod_ret) <> '000' then
		return cod_ret ,vmensaje;
	end if
	
		begin work;
			insert into mi_rcda_movdeb (sucursal, usuario, fech_alt, transacc, producto, empresa, cuenta, num_cheq, monto_tot)
			select sucursal, usuario, fech_alt, transacc, producto, empresa, cuenta, num_cheq, monto_tot 
			from bdicheq:sc_movdia
			where cancelad <> 'S' and usuario <> 'interact' and fech_alt = today and 
			(transacc in('0223','0250','0310','0325','1154','1124','1149', '1134','1104','1139','1170','1110','1163',
						'1168','1108','1169','1109', '1191','1167','1107','1101','1161','1195','1193','1116','1176',
						'1115','1175','1117','1177','1118','1178')	OR (transacc = '0202' and transacc_suc <> '0280'));
		commit work;
		
	execute procedure "informix".sp_bitacora_rcda('rcda_extmov_debito', 2)
	into cod_ret, vmensaje;
	if trim(cod_ret) <> '000' then
		return cod_ret ,vmensaje;
	end if
-- Extracción de movimentos crédito

	execute procedure "informix".sp_bitacora_rcda('rcda_extmov_credito', 1)
	into cod_ret, vmensaje;
	if trim(cod_ret) <> '000' then
		return cod_ret ,vmensaje;
	end if
		begin work;
			insert into mi_rcda_movcred (empresa, fecha_mov, hora_mov, sucursal, num_credito, transacc_suc, usuario, monto, codigo_fun, codigo_ref)
			select a.empresa, a.fecha_mov, a.hora_mov, a.sucursal, a.num_credito, a.transacc_suc, a.usuario, a.monto, a.codigo_fun, a.codigo_ref
            from bdicred:sd_movdia a left join bdicred:sd_depositos_cobranza b
                      on a.folio_suc = b.folio_suc
			where a.fecha_mov = today and a.reversado <> 'S' and a.usuario <> 'interact' and  ((a.codigo_fun = '033' and a.codigo_ref = '1') or a.transacc_suc = '6900')
                  and a.folio_suc not in (select folio_suc from bdicred:sd_depositos_cobranza  where reversado = 'N'); --descarta depósitos realizados por personal de cobranzas
		commit work;
			/*select empresa, fecha_mov, hora_mov, sucursal, num_credito, transacc_suc, usuario, monto, codigo_fun, codigo_ref
			from bdicred:sd_movdia
			where fecha_mov = today and reversado <> 'S' and usuario <> 'interact' and  ((codigo_fun = '033' and codigo_ref = '1') or transacc_suc = '6900');*/
	execute procedure "informix".sp_bitacora_rcda('rcda_extmov_credito', 2)
	into cod_ret, vmensaje;
	if trim(cod_ret) <> '000' then
		return cod_ret ,vmensaje;
	end if		
		
	return cod_ret, vmensaje;	
END 
end procedure;