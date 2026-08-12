CREATE PROCEDURE "informix".sp_tr_si_ejecut_update(p_Ejecutivo CHAR(8), p_SucAnterior CHAR(4), p_SucNueva CHAR(4))
	---DECLARACIONES
	DEFINE v_PromotorVirtual	CHAR(8);
	DEFINE v_AnioMes			CHAR(6);

	---INICIALIZACIONES
	LET v_PromotorVirtual	= '';
	LET v_AnioMes			= '';
	---SET DEBUG FILE TO "/tmp/sp_tr_si_ejecut_update.out";
	---TRACE ON;

	---OBTENER LA FECHA DEL DIA ANTERIOR
	SELECT (YEAR(fecha_ant ) || LPAD(MONTH(fecha_ant),2,'0'))::CHAR(6)
	INTO v_AnioMes
	FROM bdmis: mi_fechas;

	---OBTENER EL PROMOTOR VIRTUAL DE LA SUCURSAL
	SELECT promotor_virtual
	INTO v_PromotorVirtual
	FROM bdmis:mi_sucursalesinfo
	WHERE num_sucursal = p_SucAnterior;

	INSERT INTO BDMIS: mi_ejecutivocambiosuc
	VALUES (p_Ejecutivo, p_SucAnterior, p_SucNueva, v_PromotorVirtual,v_AnioMes);
--##############################################################################
--## Procedimiento   : sp_tr_si_ejecut_update
--## Version         : 1.0
--## Creado por      : Mohamed Carreón
--## Fecha creacion  : Abril de 2009
--##Descripcion :  Procedimiento que es llamado por el trigger "sp_tr_si_ejecut_update" que esta montado en la bdinteg: si_ejecut para llenar los datos del ejecutivo que cambios de sucursal en  la tabla ejecutivocambiosuc
--##############################################################################
END PROCEDURE;