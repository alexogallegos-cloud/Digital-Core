CREATE PROCEDURE "informix".sp_entrada_salida2_total(eEmpresa    CHAR(3),
                                              eTipo       CHAR(1), 
                                              eSucursal   CHAR(4),
                                              ePlaza      CHAR(3),
                                              eFecInicio  DATE,
                                              eFecFin     DATE,
                                              eMes        CHAR(2),
                                              eAnio       CHAR(4),
                                              eStatus     CHAR(2))
RETURNING CHAR(5)    ,          --CodRet
          INTEGER;              --Total de registros

 DEFINE vCodRet       CHAR(5);
 DEFINE vCajGen       CHAR(1);
 DEFINE vRegistros    INTEGER;


 LET vCodRet       = "000";
 LET ePlaza = ePlaza;
 LET eStatus  = eStatus;
 LET eSucursal  = eSucursal;
 LET ePlaza = ePlaza;
 LET eStatus  = eStatus;
 LET eSucursal  = eSucursal;
 LET vCajGen = 'N';
 LET vRegistros = 0;

-- SET DEBUG FILE TO "/tmp/entrasal.out";
--TRACE ON;

--SET LOCK MODE TO WAIT 4;
SET ISOLATION TO DIRTY READ;

   IF eTipo = 'C' THEN
    LET vCajGen = eTipo;
   END IF;

  IF ePlaza <> '000' AND eSucursal = '0000' AND eStatus = '00'  THEN
	  SELECT {+ INDEX(bdisuc:ss_operaciones idx01ss_operaciones)} COUNT(*)
	  INTO  vRegistros
	   FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores  c
							  WHERE a.cod_trans != '0'                      
		AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin 
								AND a.sucursal IN (SELECT sucursal 
																 FROM bdinteg:"informix".si_sucursales  
																WHERE sucursal != '0' 
							  AND empresa = eEmpresa
																			  AND plaza_cajagen = ePlaza 
																	  AND tpo_sucursal = eTipo)
									AND a.reversado IN ('0','1')
									AND a.folio_oper    = b.folio_oper   
		AND c.cod_proveedor = b.cod_proveedor; 

	  RETURN vcodret, vRegistros;

  ELIF ePlaza <> '000' AND eSucursal <> '0000' AND eStatus = '00'  THEN
	  SELECT {+ INDEX(bdisuc:ss_operaciones idx01ss_operaciones)} COUNT(*)
	  INTO  vRegistros
	  FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores  c
							  WHERE a.cod_trans != '0'                      
		AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin 
								AND a.sucursal = eSucursal
									AND a.reversado IN ('0','1')
									AND a.folio_oper    = b.folio_oper   
		AND c.cod_proveedor = b.cod_proveedor;

	  RETURN vcodret, vRegistros;

  ELIF ePlaza <> '000' AND eSucursal <> '0000' AND eStatus <> '00' THEN
	  SELECT {+ INDEX(bdisuc:ss_operaciones idx01ss_operaciones)} COUNT(*)
	  INTO  vRegistros
	  FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores  c
							  WHERE a.cod_trans != '0'                      
		AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin 
								AND a.sucursal = eSucursal
									AND a.reversado IN ('0','1')
									AND a.folio_oper    = b.folio_oper   
		AND c.cod_proveedor = b.cod_proveedor 
		AND b.status        = eStatus;

	  RETURN vcodret, vRegistros;

  ELIF ePlaza <> '000' AND eSucursal = '0000' AND eStatus <> '00' THEN
	  SELECT {+ INDEX(bdisuc:ss_operaciones idx01ss_operaciones)} COUNT(*)
	  INTO  vRegistros
	  FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores  c
							  WHERE a.cod_trans != '0'                      
		AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin 
								AND a.sucursal IN (SELECT sucursal 
																 FROM bdinteg:"informix".si_sucursales  
																WHERE sucursal != '0' 
							  AND empresa = eEmpresa
																			  AND plaza_cajagen = ePlaza 
																	  AND tpo_sucursal = eTipo)
									AND a.reversado IN ('0','1')
									AND a.folio_oper    = b.folio_oper   
		AND c.cod_proveedor = b.cod_proveedor 
		AND b.status        = eStatus;
	  
	  RETURN vcodret, vRegistros;

 ELSE
		IF eMes <> '' AND eAnio <> '' THEN
			  SELECT {+ INDEX(bdisuc:ss_operaciones idx01ss_operaciones)} COUNT(*)
			  INTO  vRegistros
			  FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores  c
									  WHERE a.cod_trans != '0'                      
				AND (MONTH(a.fecha_operacion) = eMes AND YEAR(a.fecha_operacion) = eAnio)
										AND a.sucursal IN (SELECT sucursal 
																		 FROM bdinteg:"informix".si_sucursales  
																		WHERE sucursal != '0'
																		  AND empresa = eEmpresa
																			  AND (tpo_sucursal = eTipo OR  tpo_sucursal = vCajGen))
											AND a.reversado IN ('0','1')
											AND a.folio_oper    = b.folio_oper   
				AND c.cod_proveedor = b.cod_proveedor;
			  
			  RETURN vcodret, vRegistros;
		END IF;
  END IF;

END PROCEDURE;