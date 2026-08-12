create procedure "informix".sp_domi_createnotificacionacuse(pFolio char(20),pTipo char(1),pCliente char(20),pNombreCliente char(40),pApellidoCliente char(60),
                                                                    pCorreo char(100),pCelular char(10),pAccion char(4),pProducto char(80),pProductoCorto char(40),
                                                                    pCuentaCargo char(20),pCuentaAbono char(20),pImporte decimal(16,2),pFechaPago char(10),
                                                                    pFechaMes char(5),pUser char(8))
returning char(5) as cCodRet,
			CHAR(100)	AS v_generico1,
			CHAR(100)	AS v_generico2,
			CHAR(100)	AS v_generico3,
			CHAR(100)	AS v_generico4;
-- DECLARACION DE VARIABLES.
define iSqlerr       integer;
define cCodRet      char(5);
DEFINE v_generico1			CHAR (110);
DEFINE v_generico2			CHAR (110);
DEFINE v_generico3			CHAR (110);
DEFINE v_generico4			CHAR (110);

-- VALORES INICIALES.
let iSqlerr    =  0;
let cCodRet   = '00000';
LET v_generico1			= '';
LET v_generico2			= '';
LET v_generico3			= '';
LET v_generico4			= '';

-- *************************************************************
--SET DEBUG FILE TO "/tmp/sp_domi_createnotificacionacuse.out";
--TRACE ON;
-- *************************************************************

begin
	on exception set iSqlerr
		if iSqlerr <> 0 then
			let cCodRet = iSqlerr;
			return cCodRet, v_generico1, v_generico2, v_generico3, v_generico4;
		end if;
	end exception;
	set isolation to dirty read;
	insert into bdidomi:"informix".dom_bitacora_acuses(folio_activacion,tipo_notificacion,num_cliente,nombre_cliente,
	apellido_cliente,email_cliente,celular_cliente,accion,producto,producto_corto,cuenta_cargo,cuenta_abono,
	imp_maximo,fecha_pago,fecha_mes,fecha_insert,user_insert) 
	values(pFolio,pTipo,pCliente,pNombreCliente,pApellidoCliente,pCorreo,pCelular,pAccion,
	pProducto,pProductoCorto,pCuentaCargo,pCuentaAbono,pImporte,TO_DATE(pFechaPago,'%Y-%m-%d'),pFechaMes,today,pUser);
end;
return cCodRet, v_generico1, v_generico2, v_generico3, v_generico4;
end procedure;