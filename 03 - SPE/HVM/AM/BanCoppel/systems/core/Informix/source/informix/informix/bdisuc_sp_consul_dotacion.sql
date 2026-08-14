CREATE PROCEDURE "informix".sp_consul_dotacion(eEmpresa    CHAR(3),
                                               eTipo       CHAR(1), 
                                               eProveedor  CHAR(4),
                                               eSucursal   CHAR(4),
                                               eFecInicio  DATE,
                                               eFecFin     DATE,
                                               eStatus     CHAR(2))
RETURNING CHAR(5),
          CHAR(50),
          CHAR(50),
          DATE   ,
          CHAR(50),
          CHAR(16),
          DECIMAL(14,2),
          CHAR(50),
          CHAR(16);

DEFINE vCodRet   CHAR(5);
DEFINE vWHERE    CHAR(300);
DEFINE vSucursal CHAR(4);
DEFINE vNomSuc   CHAR(50);
DEFINE vFecOpera DATE;
DEFINE vStatus   CHAR(50);
DEFINE vFolio    CHAR(16);
DEFINE vMonto    DECIMAL(14,2);
DEFINE vUsuario  CHAR(50);
DEFINE vUser     CHAR(16);
DEFINE vPlaza    CHAR(50);
DEFINE vPSuc     char(4);

LET vCodRet  = "000";
LET vWHERE   = '';
LET vPSuc    = "";
LET eTipo = eTipo;
LET eFecInicio = eFecInicio;
LET eFecFin = eFecFin;
LET vPlaza = "";

-- SET DEBUG FILE TO "/pisa/pisabanco/pisa_ftes/dotacion.out";
-- TRACE ON;


SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

    IF eProveedor <> '' and eSucursal = '' THEN   --** Por proveedor

		IF eFecInicio = '' OR eFecInicio IS NULL  THEN
			LET eFecInicio = MDY(1,1,2007);
		END IF

           FOREACH
                  SELECT b.sucursal,a.fecha_operacion,b.status,b.folio_oper,b.monto, a.usuario
                    INTO vSucursal,vFecOpera, vStatus,vFolio,vMonto, vUser
                    FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b
                   WHERE a.cod_trans in (  '0001' ,'0036', '0010' ) 
				     AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin 
                     AND a.sucursal IN (SELECT sucursal 
									      FROM bdinteg:"informix".si_sucursales  
									     WHERE sucursal != '0' 
									       AND empresa = eEmpresa 
										   AND tpo_sucursal = eTipo)
					AND a.reversado IN ('0')
				    AND a.folio_oper = b.folio_oper                 
				    AND b.cod_proveedor = eProveedor               
				    AND b.status in ('01','12') 
               ORDER BY a.fecha_operacion ASC

                  SELECT Sucursal||" "||nombre,plaza_cajagen INTO vNomSuc,vPSuc FROM bdinteg:"informix".si_sucursales WHERE sucursal = vSucursal;

                  SELECT cod_proveedor||" "||substr(descripcion,14) INTO vPlaza FROM bdisuc:"informix".ss_proveedores WHERE plaza = vPSuc;                 

                  SELECT nombre INTO vUsuario FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = vUser;

                  SELECT descripcion INTO vStatus FROM bdisuc:"informix".ss_catstatus WHERE status = vStatus;

                  RETURN vcodret, vNomSuc, vPlaza,vFecOpera, vStatus, vFolio, vMonto, vUsuario,vUser  WITH RESUME;
           END FOREACH;

    ELIF eProveedor <> '' and eSucursal <> ''  THEN   --** Por Sucursal

		IF eFecInicio = '' OR eFecInicio IS NULL  THEN
			LET eFecInicio = MDY(1,1,2007);
		END IF

           FOREACH
                  SELECT b.sucursal,a.fecha_operacion,b.status,b.folio_oper,b.monto, a.usuario
                    INTO vSucursal,vFecOpera, vStatus,vFolio,vMonto, vUser
                    FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b
                   WHERE a.cod_trans in (  '0001' ,'0036', '0010' ) 
                     AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin 
				     AND a.sucursal = eSucursal 
					 AND a.reversado IN ('0')
                     AND a.folio_oper = b.folio_oper                 
                     AND b.status in ('01','12')                 
                ORDER BY a.fecha_operacion ASC

                  SELECT Sucursal||" "||nombre,plaza_cajagen INTO vNomSuc,vPSuc FROM bdinteg:"informix".si_sucursales WHERE sucursal = vSucursal;

                  SELECT cod_proveedor||" "||substr(descripcion,14) INTO vPlaza FROM bdisuc:"informix".ss_proveedores WHERE plaza = vPSuc;

                  SELECT nombre INTO vUsuario FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = vUser;

                  SELECT descripcion INTO vStatus FROM bdisuc:"informix".ss_catstatus WHERE status = vStatus;

                  RETURN vcodret, vNomSuc, vPlaza,vFecOpera, vStatus, vFolio, vMonto, vUsuario,vUser  WITH RESUME;
           END FOREACH;

    ELSE  --** Todos

		IF eFecInicio = '' OR eFecInicio IS NULL  THEN
			LET eFecInicio = MDY(1,1,2007);
		END IF

           FOREACH
                  SELECT b.sucursal,a.fecha_operacion,b.status,b.folio_oper,b.monto, a.usuario
                    INTO vSucursal,vFecOpera, vStatus,vFolio,vMonto, vUser
                    FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b
                   WHERE a.cod_trans in (  '0001' ,'0036', '0010' ) 
				     AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin 
					 AND a.sucursal IN (SELECT sucursal 
								  FROM bdinteg:"informix".si_sucursales  
								  WHERE sucursal != '0' 
								    AND empresa = eEmpresa 
									AND tpo_sucursal = eTipo)
					 AND a.reversado IN ('0')
                     AND a.folio_oper = b.folio_oper                 
                     AND b.status in ('01','12')                 
                  ORDER BY a.fecha_operacion ASC

                  SELECT Sucursal||" "||nombre,plaza_cajagen INTO vNomSuc,vPSuc FROM bdinteg:"informix".si_sucursales WHERE sucursal = vSucursal;

                  SELECT cod_proveedor||" "||substr(descripcion,14) INTO vPlaza FROM bdisuc:"informix".ss_proveedores WHERE plaza = vPSuc;

                  SELECT nombre INTO vUsuario FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = vUser;

                  SELECT descripcion INTO vStatus FROM bdisuc:"informix".ss_catstatus WHERE status = vStatus;

                  RETURN vcodret, vNomSuc, vPlaza,vFecOpera, vStatus, vFolio, vMonto, vUsuario,vUser  WITH RESUME;
           END FOREACH;
    END IF;

END PROCEDURE;