create procedure "informix".sp_sw_ro_consmovtos(pUsuarioC char(8), pFuncionC char(10), pIdOficio int, pIdBusqueda int, pIdCliente int, pNumCuenta char(20), pNumRegistros int, pRecuperacion int)
	returning char(5) as codret,
			char(10) as fechaMovimiento, 
			char(12) as hora,
			char(16) as folioSucursal, 
			char(4) as transaccion,
			char(50) as descripcion_transaccion,
			char(1) as reverso,
			decimal(18,2) as monto, 
			char(4) as sucursal,
			char(1) as naturaleza,
			money(14,2) as saldo,
			char(20) as procedencia, 
			char(50) as descripcion_procedencia,
			char(40) as referencia,
			char(1) as ind_omitir,
			char(20) as numerotarjeta
		
	define cCodRet char(5);
	define iSqlErr int;
	define cFechaMovto char(10);
	define cHora char(12);
	define cFolioSucursal char(16);
	define cTransaccion char(4);
	define cDescTransaccion char(50);
	define cReversado char(1);
	define dMonto decimal(18,2);
	define cSucursal char(4);
	define cNaturaleza char(1);
	define mSaldo money(14,2);
	define cProcedencia char(20);
	define cDescProcedencia char(50);
	define cReferencia char(40);
	define cIndOmitir char(1);
	define iNoRegs int;
	define cNumTarjeta char(20);
	
	let cCodRet = '00000';
	let iSqlErr = '';
	let cFechaMovto = '';
	let cHora = '';
	let cFolioSucursal = '';
	let cTransaccion = '';
	let cDescTransaccion = '';
	let cReversado = '';
	let dMonto = 0.0;
	let cSucursal = '';
	let cNaturaleza = '';
	let mSaldo = 0.0;
	let cProcedencia = '';
	let cDescProcedencia = '';
	let cReferencia = '';
	let cIndOmitir = '';
	let iNoRegs = 0;
	let cNumTarjeta = '';
	
	begin
		
		on exception set iSqlErr
			if iSqlErr <> 0 then
				let cCodRet = iSqlErr;
				return cCodRet, cFechaMovto, cHora, cFolioSucursal, cTransaccion, cDescTransaccion, cReversado, dMonto, cSucursal, cNaturaleza, mSaldo, cProcedencia, cDescProcedencia, cReferencia, cIndOmitir, cNumTarjeta;
			end if;
		end exception;
		
		if pUsuarioC = '' or pFuncionC = '' or pIdOficio = '' or pIdBusqueda = '' or pIdCliente = '' or pNumRegistros = '' or pRecuperacion = '' or pNumCuenta = '' then
			let cCodRet = '00003';
			return cCodRet, cFechaMovto, cHora, cFolioSucursal, cTransaccion, cDescTransaccion, cReversado, dMonto, cSucursal, cNaturaleza, mSaldo, cProcedencia, cDescProcedencia, cReferencia, cIndOmitir, cNumTarjeta;
		end if;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		execute function bdinteg:sp_cnsif_confirmaejecutivo(pUsuarioC, pFuncionC) into cCodRet;
		
		if cCodRet <> '00000' then
			return cCodRet, cFechaMovto, cHora, cFolioSucursal, cTransaccion, cDescTransaccion, cReversado, dMonto, cSucursal, cNaturaleza, mSaldo, cProcedencia, cDescProcedencia, cReferencia, cIndOmitir, cNumTarjeta;
		end if;
		
		
		foreach select skip pNumRegistros first pRecuperacion fecha_mov, folio_sucursal, transaccion, descripcion_transaccion, reversado, monto, 
					to_char(hora, '%H:%M:%S.000') as hora, 
					sucursal, naturaleza, saldo, procedencia, descripcion_procedencia, referencia, ind_omitido, tarjeta
				into cFechaMovto, cFolioSucursal, cTransaccion, cDescTransaccion, cReversado, dMonto, cHora,
					cSucursal, cNaturaleza, mSaldo, cProcedencia, cDescProcedencia, cReferencia, cIndOmitir, cNumTarjeta
				from sw_ro_movtos
				where id_resulcte = pIdCliente and id_busqueda = pIdBusqueda and  id_oficio = pIdOficio 
					and cuenta = pNumCuenta
				order by id_movtos
			
			let iNoRegs = iNoRegs + 1;
			return cCodRet, cFechaMovto, cHora, cFolioSucursal, cTransaccion, cDescTransaccion, cReversado, dMonto, cSucursal, cNaturaleza, mSaldo, cProcedencia, cDescProcedencia, cReferencia, cIndOmitir, cNumTarjeta with resume;
			
		end foreach;
		
		if iNoRegs = 0 then
			let cCodRet = '01001';
			return cCodRet, cFechaMovto, cHora, cFolioSucursal, cTransaccion, cDescTransaccion, cReversado, dMonto, cSucursal, cNaturaleza, mSaldo, cProcedencia, cDescProcedencia, cReferencia, cIndOmitir, cNumTarjeta;
		end if;
		
	end; 
end procedure;