CREATE PROCEDURE "informix".sp_consinfobtssif(cUsuario char(10))
RETURNING VARCHAR(6),VARCHAR(80),DATE,VARCHAR(5);

DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);
DEFINE  P_COD_RET        VARCHAR(6);
DEFINE  P_MENSAJE        VARCHAR(80);
DEFINE  dFecha           DATE;
DEFINE  vSucursal        VARCHAR(5);


BEGIN
   
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
      RETURN P_COD_RET, P_MENSAJE,dFecha,vSucursal;
   END EXCEPTION;

--**************************************************************
-- By Manuel Osuna Valencia (Transaccion por Producto,Empresa)--*
-- Debug del Procedure                                        --*
 --SET DEBUG FILE TO "/tmp/manuel.out";                       --*
 --TRACE ON;                                                  --*
--**************************************************************

   LET P_COD_RET = '00000';
   LET P_MENSAJE = '';
   let vSucursal = '';
   let dFecha = '';

	--Sacar la Fecha del Sistema
	select fecha_hoy into dFecha  from bdinteg:si_fechas;
	
	select nombre into P_MENSAJE from bdinteg:si_ejecut where ejecutivo = trim(cUsuario);
	
	select valor into  vSucursal from bdisac:sac_param where cod_param = '999';
	
		
	RETURN P_COD_RET,P_MENSAJE,dFecha,vSucursal;
END;
END PROCEDURE;