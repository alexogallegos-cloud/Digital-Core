create procedure "informix".subeiva()


define vemp char(3);
define vfecha date;
define vmonto decimal(14,2);
define vtran  char(4);
define vfolio char(16);
define vnum char(16);


foreach select empresa, fecha_mov, monto, transacc_suc, folio_suc, num_credito
          into vemp, vfecha, vmonto, vtran, vfolio, vnum
	  from sd_movdia
	where transacc_suc in ("6260", "6261")

	insert into sd_detcomi
	 (empresa, cod_comis, num_credito, fecha_alta, secuencia,
	  fecha_pago, monto_com, monto_pag, apli_factor, estado_com,
	  num_solicitud)
	values
	 (vemp, vtran, vnum, vfecha, 0, vfecha, vmonto, 0, 0, "A",
	  vfolio);



end foreach




end procedure
;