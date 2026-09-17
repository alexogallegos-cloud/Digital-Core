create procedure "informix".sp_sw_ro_consopcoficio(pUsuario char(8), pIdFuncion char(10), pIdOficio int)
	returning char(5) as codret,
		char(4) as indicadores
	
	define cCodRet char(5);
	define iSqlErr int;
	define cIndCertificaImgs char(1);
	define cIndCertificaEdosCta char(1);
	define cDetalleMovotos char(1);
	define cCtasBloqueadasPorSistema char(1);
	
	let cCodRet = '00000';
	let iSqlErr = 0;
	let cIndCertificaImgs = ' ';
	let cIndCertificaEdosCta = ' ';
	let cDetalleMovotos = ' ';
	let cCtasBloqueadasPorSistema = ' ';
	
	begin
	
		on exception set iSqlErr
			if iSqlErr <> 0 then
				let cCodRet = iSqlErr;
				return cCodRet, cIndCertificaImgs||cIndCertificaEdosCta||cDetalleMovotos||cCtasBloqueadasPorSistema;
			end if;
		end exception;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		execute function bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		if cCodRet <> '00000' then
			return cCodRet, cIndCertificaImgs||cIndCertificaEdosCta||cDetalleMovotos||cCtasBloqueadasPorSistema;
		end if;
		
		if pUsuario = '' or pIdFuncion = '' or pIdOficio = '' then
			let cCodRet = '00003';
			return cCodRet, cIndCertificaImgs||cIndCertificaEdosCta||cDetalleMovotos||cCtasBloqueadasPorSistema;
		end if;
		
		
		select 
			case when (certifica_imagenes + (select count(ind_expdig) from sw_ro_resulcte where id_oficio = mo.id_oficio and ind_expdig = '1' and status = '1')) > 0 
				then '1' else '0' end as certifica_imagenes
			, certifica_edocuenta
			, detalle_movimientos, 
				(select case when count(ind_bloqueo_cta_por_sistema) > 0 then '1' else '0' end from sw_ro_ctecta where ind_bloqueo_cta_por_sistema = '1'
					and id_oficio = mo.id_oficio) as bloqueo_cuentas
		into cIndCertificaImgs, cIndCertificaEdosCta, cDetalleMovotos, cCtasBloqueadasPorSistema
		from sw_ro_maeoficios mo where mo.id_oficio = pIdOficio;

		if cIndCertificaImgs is null and cIndCertificaEdosCta is null and cDetalleMovotos is null and cCtasBloqueadasPorSistema is null then
			let cCodRet = '00110'; -- No existe el numero de oficio buscado 
			return cCodRet, cIndCertificaImgs||cIndCertificaEdosCta||cDetalleMovotos||cCtasBloqueadasPorSistema;
		else
			return cCodRet, cIndCertificaImgs||cIndCertificaEdosCta||cDetalleMovotos||cCtasBloqueadasPorSistema;
		end if;
	
	end;
		
end procedure;