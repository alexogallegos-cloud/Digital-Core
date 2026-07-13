create procedure "informix".sp_domi_valida_intentos(pIntentos Integer, pPeriodo char(2), pFechaUltimoPago date, pNom_Arch_Aux char(20), pFechaEnvio date, pFolioActivacion char(20),pNum_cte char(20), pEstatus char(2), pUsuario char(8))
returning char(5) as cCodRet

--declaración de variables
DEFINE cCodRet						CHAR(5);
DEFINE v_generico1					CHAR(100);
DEFINE v_generico2 					CHAR(100);
DEFINE v_generico3					CHAR(100);
DEFINE v_generico4					CHAR(100);
DEFINE iSqlerr      				INTEGER;
DEFINE cInTransaction	 			CHAR(1); 
DEFINE iIntentos					INTEGER;
DEFINE iMeses						INTEGER;
DEFINE iDias						INTEGER;
DEFINE dFechaProximoPago			DATE;
define dFechaPago					DATE;
DEFINE cFechaPago					CHAR(8);
DEFINE cNombreCargo					CHAR(40);
DEFINE cCuentaAbono					CHAR(20);
DEFINE cTipoAbono					CHAR(2);
DEFINE cImporteOperacion			CHAR(15);
DEFINE cCuentaCargo					CHAR(20);
DEFINE cTipoCargo					CHAR(2);
DEFINE cBancoCargo					CHAR(3);
DEFINE cTipoDomi					CHAR(2);
DEFINE cRfcCargo					CHAR(13);	      
DEFINE cCodret2						CHAR(5);
DEFINE cMensajeRespuesta 			CHAR(110);
DEFINE cNumPeriodo					INTEGER;
DEFINE cNumIntento   				INTEGER;

-- valores iniciales
LET cCodRet 			= "00000";
LET iSqlerr 			=  0;
LET cCodret2			= '';
LET cInTransaction      = 'N';
LET v_generico1			= '';
LET v_generico2			= '';
LET v_generico3			= '';
LET v_generico4			= '';

begin
	--Manejo de excepciones (errores)
	on exception set iSqlerr
		if iSqlerr <> 0 then 
			if cInTransaction = 'S' then 
				rollback work;
			end if;
			let cCodret = iSqlerr;
		
			--Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_intentos', TRIM(pFolioActivacion), pUsuario, CURRENT);
			
			return cCodRet;
		end if;
	end exception;
	on exception in(-535)
		commit work;
		begin work;
	end exception with resume;
	
	--***************************************************************************************
	--SET DEBUG FILE TO "/tmp/sp_domi_valida_intentos.out";
	--TRACE ON;
	--***************************************************************************************

	set isolation to dirty read;
	-- validaciones de parametros de entrada
	
	if  nvl(pPeriodo,'') = '' or nvl(pFechaUltimoPago,'') = '' or nvl(pNom_Arch_Aux,'') = '' or nvl(pFechaEnvio,'')='' or 
		nvl(pFolioActivacion,'') = '' or nvl(pNum_cte,'') = '' or nvl(pEstatus,'') = '' or nvl(pUsuario,'') = '' then
		let cCodRet = '99975';
	
		--Obtenemos los datos del error ocurrido.
		EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;
				
		--Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
		INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
		VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_valida_intentos', TRIM(cMensajeRespuesta), pUsuario, CURRENT);
			
		RETURN cCodret;
	end if;
	
	let iIntentos = pIntentos + 1;
	-- Se valida intentos de cobro por periodo
	
	select fecha_pago into dFechaPago from bdidomi:"informix".dom_fecha_pago where folio_activacion = pFolioActivacion;

		
	let dFechaProximoPago = pFechaUltimoPago;

	if iIntentos >= 3 then 
		-- SELECCIONAR EL NÚMERO DE DÍAS
		select dias into iDias from bdidomi:"informix".dom_cat_periodo where cve_periodo = pPeriodo;
		let iMeses = iDias/30;
					
		-- Calcula próxima fecha de pago= fecha_ultimo_pago + periodo
		if iMeses > 12 then
			let dFechaProximoPago = dFechaProximoPago + 1 units year;
		elif (iMeses >=1 and iMeses < 12) then
			let dFechaProximoPago = dFechaProximoPago + iMeses units month;
		elif iMeses < 1 then
			let dFechaProximoPago = dFechaProximoPago + iDias units day;
		end if;

		if day(dFechaProximoPago) <> day(dFechaPago) then
			let dFechaProximoPago = dFechaProximoPago - (day(pFechaUltimoPago) - day(dFechaPago));
		end if;

		
	else
		let dFechaProximoPago = dFechaProximoPago + 1 units day;
	end if;	
	
	begin work;
	let cInTransaction = 'S';
	
	select nombre_cargo,cuenta_abono,tipo_cta_abono,imp_operacion,cuenta_cargo,tipo_cta_cargo,cve_banco_cargo,tipo_domi,rfc_cargo,num_periodo,num_intento 
	into cNombreCargo,cCuentaAbono,cTipoAbono,cImporteOperacion,cCuentaCargo,cTipoCargo,cBancoCargo,cTipoDomi,cRfcCargo,cNumPeriodo,cNumIntento 
	from bdidomi:"informix".dom_archivomanual where folio_activacion = pFolioActivacion and nombre_arch = pNom_Arch_Aux and accion = 'A' and estatus='EP';	
						
	-- Actualiza estatus en dom_archivo_manual
	if (iIntentos >= 3 ) then -- cobro correcto o no debe nada
		update bdidomi:"informix".dom_archivomanual set estatus = pEstatus, num_intento = 0 
		where folio_activacion = pFolioActivacion and nombre_arch = pNom_Arch_Aux and accion = 'A' and estatus='EP';
	else
		update bdidomi:"informix".dom_archivomanual set num_intento = iIntentos, num_periodo = pPeriodo, estatus = pEstatus 
		where folio_activacion = pFolioActivacion and nombre_arch = pNom_Arch_Aux and accion = 'A' and estatus='EP';
	end if;
						
	LET cFechaPago = TO_CHAR(dFechaProximoPago, '%Y%m%d');
	
	commit work;
	let cInTransaction = 'N';

	-- Llamar a sp_dom_guardararchivo_manual
	execute procedure bdidomi:"informix".sp_domi_guardararchivo_manual(cNombreCargo,cCuentaAbono,cTipoAbono,cImporteOperacion,cCuentaCargo,
	cTipoCargo,cBancoCargo,pUsuario,cTipoDomi,cFechaPago,cFechaPago,cFechaPago,cRfcCargo,pFolioActivacion,TO_CHAR(dFechaProximoPago, '%d%m%y'),
	'A',pPeriodo,'EP',pNum_cte) into cCodRet,v_generico1,v_generico2,v_generico3,v_generico4;

	if(cCodRet::INTEGER <> 0) then
		update bdidomi:"informix".dom_cte_detalle set estatus = 'EP', causa_rechazo = '', folio_suc = '' where nombre_arch = pNom_Arch_Aux and fecha_envio = pFechaEnvio and folio_suc = pFolioActivacion;
	
		update bdidomi:"informix".dom_archivomanual set estatus = 'EP', causa_rechazo = '', num_periodo = cNumPeriodo, num_intento = cNumIntento 
		where folio_activacion = pFolioActivacion and accion = 'A' and estatus=pEstatus;
	
		return cCodRet;
	end if;
end;
return cCodRet;
end procedure;