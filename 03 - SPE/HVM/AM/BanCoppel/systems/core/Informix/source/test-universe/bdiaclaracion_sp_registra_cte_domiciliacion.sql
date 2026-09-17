CREATE PROCEDURE "informix".sp_registra_cte_domiciliacion(
bandera CHAR(5),
eEmpresa CHAR(5),
eNumeroCliente CHAR(20),
eNumeroCuenta CHAR(20),
eNumeroTarjeta CHAR(20),
eClienteTelefonoCasa CHAR(20),
eTipoTelefono INTEGER,
eCanalTelefono INTEGER,
eNumEmpleado CHAR(12),
eClienteCorreoElectronico CHAR(100),
eTipoCorreo INTEGER,
eCanalCorreo INTEGER ,
eRefServicio CHAR(40),
eTransaccion CHAR(5),
eFolioSuc CHAR(20),
opc1 CHAR(80),
opc2 CHAR(80),
opc3 CHAR(80),
opc4 CHAR(80),
opc5 CHAR(80)
)


RETURNING CHAR(5),CHAR(100),CHAR(80),CHAR(80),CHAR(80),CHAR(80),CHAR(80);

--****************************************************************************************************
-- DESCRIPCION:  SP PRINCIPAL DE GUARDADO DE CLIENTES Y MOVIMIENTOS PARA CANCELACION Y OBJECION DE DOMICILIACIONES POR EL BUS.
-- FECHA : 22/07/2022
-- BD: Bdiaclaracion
-- SISTEMA : Aclaraciones
--****************************************************************************************************

DEFINE sCodigoRetorno CHAR(5);
DEFINE sCodigoDescripcion CHAR(100);
DEFINE ret1 CHAR(80);
DEFINE ret2 CHAR(80);
DEFINE ret3 CHAR(80);
DEFINE ret4 CHAR(80);
DEFINE ret5 CHAR(80);
DEFINE cStatusCancelacion CHAR(2);
DEFINE iSQLerr	INTEGER;

LET sCodigoRetorno = '00000';
LET sCodigoDescripcion = 'Proceso Exitoso';
LET ret1 = '';
LET ret2 = '';
LET ret3 = '';
LET ret4 = '';
LET ret5 = '';
LET cStatusCancelacion = '0';

BEGIN

	--Manejo de excepciones (errores)
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET sCodigoRetorno = iSqlErr;
			LET sCodigoDescripcion = 'ERROR NO CONTROLADO(' || iSqlErr || ')';
			
			INSERT INTO bdidomi:"informix".dom_errores(fecha_error, hora_error, cod_error, nombre_arch, sp_llamado, mensaje_error, user_insert, fecha_insert)
            VALUES(EXTEND(CURRENT::DATE, YEAR to SECOND), EXTEND(CURRENT::DATE, YEAR to SECOND)+10 UNITS HOUR+42 UNITS MINUTE+29 UNITS SECOND,sCodigoRetorno,'', 'bdiaclaracion:sp_registra_cte_domiciliacion', 'OBTENER MENSAJES CODIGO DE ERROR DESCONOCIDO', 'sysdomi ', EXTEND(CURRENT::DATE, YEAR to SECOND));
			
			RETURN sCodigoRetorno,sCodigoDescripcion,ret1,ret2,ret3,ret4,ret5;
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	IF bandera = "1" THEN
	
		EXECUTE PROCEDURE bdinteg:sp_registra_telefonos(eEmpresa,eNumeroCliente,eClienteTelefonoCasa,eTipoTelefono,opc1,opc2,eCanalTelefono,opc3) INTO sCodigoRetorno;
		RETURN sCodigoRetorno,sCodigoDescripcion,ret1,ret2,ret3,ret4,ret5;
	
	ELIF (bandera = "2") THEN
	
		EXECUTE PROCEDURE bdinteg:sp_registra_correos(eEmpresa,eNumeroCliente,eClienteCorreoElectronico,eTipoCorreo,eCanalCorreo,opc3) INTO sCodigoRetorno;
		RETURN sCodigoRetorno,sCodigoDescripcion,ret1,ret2,ret3,ret4,ret5;
	ELIF (bandera = "3") THEN --Cancelacion de domiciliaciones
		--Tipo Domiciliacion = opc1
			-- 1 Cancelacion de domiciliaciones por tarjeta
			-- 2 Cancelacion de domiciliaciones en especifico	
		--cStatusCancelacion
			-- 0 Enviada por alaraciones
			-- 1 Cancelacion aplicada en domiciliacion
		--cRefLeyenda = eRefServicio	
		--Sucursal = opc2
		--Monto = opc3
		--fechaMovimiento = opc4  formato DD/MM/AAAA
		--RefCliente no se ocupa
		EXECUTE PROCEDURE bdidomi:sp_guarda_cancelaciones(eNumeroCliente,eNumeroCuenta,eNumeroTarjeta,opc1,'',cStatusCancelacion,eRefServicio,eFolioSuc,opc2,eTransaccion,opc3,opc4,'','sysdomi',CURRENT) INTO sCodigoRetorno,sCodigoDescripcion;
		RETURN sCodigoRetorno,sCodigoDescripcion,ret1,ret2,ret3,ret4,ret5;	
	ELIF (bandera = "4") THEN --Objecion de domiciliaciones
		--Tipo Domiciliacion = opc1
			-- 1 Cancelacion de domiciliaciones por tarjeta
			-- 2 Cancelacion de domiciliaciones en especifico	
		--cStatusCancelacion
			-- 0 Enviada por alaraciones
			-- 1 Cancelacion aplicada en domiciliacion
		--cRefLeyenda = eRefServicio	
		--Sucursal = opc2
		--Monto = opc3
		--fechaMovimiento = opc4  formato DD/MM/AAAA
		--RefCliente no se ocupa
		EXECUTE PROCEDURE bdidomi:sp_guarda_obj_domi(eNumeroCliente,eNumeroCuenta,eNumeroTarjeta,opc1,'',cStatusCancelacion,eRefServicio,eFolioSuc,opc2,eTransaccion,opc3,opc4,'','sysdomi',CURRENT) INTO sCodigoRetorno,sCodigoDescripcion;
		RETURN sCodigoRetorno,sCodigoDescripcion,ret1,ret2,ret3,ret4,ret5;		
		
	ELSE
		LET sCodigoRetorno = '00004';
		LET sCodigoDescripcion = 'BÃºsqueda No Encontrada.';
		RETURN sCodigoRetorno,sCodigoDescripcion,ret1,ret2,ret3,ret4,ret5;
	END IF;

END
END PROCEDURE;