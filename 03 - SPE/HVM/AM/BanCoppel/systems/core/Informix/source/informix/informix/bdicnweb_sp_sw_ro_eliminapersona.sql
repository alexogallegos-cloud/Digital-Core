create procedure "informix".sp_sw_ro_eliminapersona(pUsuarioC char(8), pFuncionC char(10), pIdResultPer int)
	returning char(5) as codret
	
	define iSqlErr int;
	define cCodRet char(5);
	define iIdResultPer int;
	define iIdOficio int;
	define iResultCte int;
	
	let iSqlErr = 0;
	let cCodRet = '00000';
	let iIdResultPer = 0;
	let iIdOficio = 0;
	let iResultCte = 0;
	
	begin

		on exception set iSqlErr
			if iSqlErr <> 0 then
				let cCodRet = iSqlErr;
				return cCodRet;
			end if;
		end exception;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		execute function bdinteg:sp_cnsif_confirmaejecutivo(pUsuarioC, pFuncionC) into cCodRet;
		
		if cCodRet <> '00000' then
			return cCodRet;
		end if;
		
		-- Se obtiene el id del cliente y el id de oficio
		foreach select id_resulper, id_oficio
				into iIdResultPer, iIdOficio
				from sw_ro_resulper where id_busqueda = pIdResultPer
		
			select id_resulcte
			into iResultCte
			from sw_ro_resulcte
			where id_resulper = iIdResultPer and id_oficio = iIdOficio;
			
			-- Se eliminan las notas del cliente
			delete from sw_ro_notascte where id_resulper = iIdResultPer and id_oficio = iIdOficio;
			
			-- Se eliminan los filtros de los movimientos
			delete from sw_ro_filtros_movtos where id_resulcte = iResultCte and id_busqueda = pIdResultPer and id_oficio = iIdOficio;
			
			-- Se eliminan los movimientos
			delete from sw_ro_movtos where id_resulcte = iResultCte and id_busqueda = pIdResultPer and id_oficio = iIdOficio;
			
			-- Se eliminan los estados de cuenta
			delete from sw_ro_edocta where id_resulcte = iResultCte and id_busqueda = pIdResultPer and id_oficio = iIdOficio;
			
			-- Se elimina el expediente digital del cliente
			delete from sw_ro_cteexp where id_resulcte = iResultCte and id_busqueda = pIdResultPer and id_oficio = iIdOficio;
			
			-- Se eliminan las cuentas del cliente
			delete from sw_ro_ctecta where id_resulcte = iResultCte and id_busqueda = pIdResultPer and id_oficio = iIdOficio;
			
			-- Se eliminan los participes
			delete from sw_ro_cta_participes where id_resulcte = iResultCte and id_busqueda = pIdResultPer and id_oficio = iIdOficio;
			
			-- Se eliminan los datos del titular
			delete from sw_ro_cte_ctatitular where id_resulcte = iResultCte and id_busqueda = pIdResultPer and id_oficio = iIdOficio;
			
			-- Se eliminan los registros de bloqueos
			delete from sw_ro_bloqueos where id_resulcte = iResultCte and id_busqueda = pIdResultPer and id_oficio = iIdOficio;
			
			-- Se elimina al cliente
			delete from sw_ro_resulcte where id_resulper = iIdResultPer and id_oficio = iIdOficio;
			
			-- Se elimina el resultado de la busqueda
			delete from sw_ro_resulper where id_resulper = iIdResultPer and id_oficio = iIdOficio;
		
		end foreach;
		
		return cCodRet;
	
	end;
end procedure;