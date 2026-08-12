CREATE PROCEDURE "informix".sp_entrada_salida_pba(eEmpresa    CHAR(3),
                                              eTipo       CHAR(1), 
                                              eSucursal   CHAR(4),
                                              ePlaza      CHAR(3),
                                              eFecInicio  DATE,
                                              eFecFin     DATE,
                                              eMes        CHAR(2),
                                              eAnio       CHAR(4),
                                              eStatus     CHAR(2))
RETURNING CHAR(5)    ,          --CodRet
          CHAR(50)   ,          --Proveedores
          CHAR(8)    ,          --Folio Oper
          CHAR(40)   ,         --Status
          CHAR(50)   ,         --Sucursal
          CHAR(16)   ,         --Folio Sucursal
          DATE       ,         --Fec. Solicitud
          CHAR(60)   ,         --Usuario Sol
          DATE       ,         --Fec.Envio
          CHAR(8)    ,         --Usuario Envio
          DATe       ,         --Fec.Recepcion
          CHAR(60)   ,         --Usuario Recepcion
          CHAR(40)   ,         --Status
          MONEY(14,2),         --Monto
          DATE       ,         --Fec. Reversion
          CHAR(60)   ,         --Usuario Reversion
          CHAR(3)    ,         --Empresa
          CHAR(40)   ;

 DEFINE vCodRet       CHAR(5);
 DEFINE vCodProveedor CHAR(50);
 DEFINE vFolOper      CHAR(8);
 DEFINE vSucursal     CHAR(4);
 DEFINE vNomSuc       CHAR(40);
 DEFINE vFolSuc       CHAR(16);
 DEFINE vFecSol       DATE;
 DEFINE vUsuarioSol   CHAR(8);
 DEFINE vNomUsuSol    CHAR(40);
 DEFINE vFecEnvio     DATE;
 DEFINE vUsuarioEnv   CHAR(8);
 DEFINE vNomUsuEnv    CHAR(40);
 DEFINE vFecRecepcion DATE;
 DEFINE vUsuarioRecep CHAR(8);
 DEFINE vNomUsuRecep  CHAR(40);
 DEFINE vDesStatus    CHAR(40);
 DEFINE vMonto        MONEY(14,2);
 DEFINE vFecRever     DATE;
 DEFINE vUsuarioRever CHAR(40);
 DEFINE vNomUsuRever  CHAR(40);
 DEFINE vNomPlaza     CHAR(40);
 DEFINE vCajGen       CHAR(1);


 LET vCodRet       = "000";
 LET vCodProveedor = '';
 LET vFolOper      = '';
 LET vSucursal     = '';
 LET vNomSuc       = '';
 LET vFolSuc       = '';
 LET vFecSol       = '';
 LET vUsuarioSol   = '';
 LET vNomUsuSol    = '';
 LET vFecEnvio     = '';
 LET vUsuarioEnv   = '';
 LET vNomUsuEnv    = '';
 LET vFecRecepcion = '';
 LET vUsuarioRecep = '';
 LET vNomUsuRecep  = '';
 LET vMonto        = 0;
 LET vFecRever     = '';
 LET vUsuarioRever = '';
 LET vNomUsuRever  = '';
 LET vDesStatus    = '';
 LET vNomPlaza     = '';
 LET ePlaza = ePlaza;
 LET eStatus  = eStatus;
 LET eSucursal  = eSucursal;
 LET ePlaza = ePlaza;
 LET eStatus  = eStatus;
 LET eSucursal  = eSucursal;
 LET vCajGen = 'N';

-- SET DEBUG FILE TO "/tmp/entrasal.out";
--TRACE ON;

SET LOCK MODE TO WAIT 4;
SET ISOLATION TO DIRTY READ;

   IF eTipo = 'C' THEN
    LET vCajGen = eTipo;
   END IF;

  IF ePlaza <> '000' AND eSucursal = '0000' AND eStatus = '00'  THEN
                FOREACH
                          SELECT {+ INDEX(ss_operaciones idx01ss_operaciones)} b.folio_oper,b.sucursal,b.folio_sucursal,b.fecha_solicitud,b.usuario_solicitud,
                                 b.fecha_envio,b.usuario_envio,b.fecha_recepcion,b.usuario_recepcion,b.monto,b.fecha_reversion,
                                 b.usuario_reversion ,c.descripcion,b.status
                          INTO  vFolOper,vSucursal,vFolSuc,vFecSol,vUsuarioSol,
                                vFecEnvio,vUsuarioEnv,vFecRecepcion,vUsuarioRecep,vMonto,vFecRever,
                                vUsuarioRever,vCodProveedor,eStatus
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
                          ORDER BY b.fecha_solicitud ASC

                          SELECT nombre INTO vNomSuc      FROM bdinteg:"informix".si_sucursales WHERE sucursal = vSucursal AND empresa = eEmpresa;
                          SELECT nombre INTO vNomUsuSol   FROM bdinteg:"informix".si_ejecut     WHERE ejecutivo = vUsuarioSol;
                          SELECT nombre INTO vNomUsuEnv   FROM bdinteg:"informix".si_ejecut     WHERE ejecutivo = vUsuarioEnv;
                          SELECT nombre INTO vNomUsuRecep FROM bdinteg:"informix".si_ejecut     WHERE ejecutivo = vUsuarioRecep;
                          SELECT nombre INTO vNomUsuRever FROM bdinteg:"informix".si_ejecut     WHERE ejecutivo = vUsuarioRever;
                          SELECT descripcion INTO vDesStatus FROM bdisuc:"informix".ss_catstatus WHERE status = eStatus;
                          SELECT descripcion INTO vNomPlaza  FROM bdinteg:"informix".si_plazas_cajagen WHERE codigo_plaza = ePlaza AND empresa = eEmpresa;

                          RETURN vcodret, vCodProveedor,vFolOper,vDesStatus ,vSucursal ||' '|| vNomSuc,vFolSuc,vFecSol, vUsuarioSol || ' ' ||vNomUsuSol,
                              vFecEnvio,vUsuarioEnv || ' '|| vNomUsuEnv, vFecRecepcion, vUsuarioRecep || ' ' || vNomUsuRecep,
                              vDesStatus,vMonto,vFecRever,vUsuarioRever || ' '|| vNomUsuRever,eEmpresa,vNomPlaza   WITH RESUME;
                   END FOREACH;

  ELIF ePlaza <> '000' AND eSucursal <> '0000' AND eStatus = '00'  THEN
                FOREACH
                          SELECT {+ INDEX(ss_operaciones idx01ss_operaciones)} b.folio_oper,b.sucursal,b.folio_sucursal,b.fecha_solicitud,b.usuario_solicitud,
                                 b.fecha_envio,b.usuario_envio,b.fecha_recepcion,b.usuario_recepcion,b.monto,b.fecha_reversion,
                                 b.usuario_reversion , c.descripcion, b.status
                          INTO  vFolOper,vSucursal,vFolSuc,vFecSol,vUsuarioSol,
                                vFecEnvio,vUsuarioEnv,vFecRecepcion,vUsuarioRecep,vMonto,vFecRever,
                                vUsuarioRever,vCodProveedor,eStatus                          
                          FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores  c
						  WHERE a.cod_trans != '0'                      
                            AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin 
						    AND a.sucursal = eSucursal
							AND a.reversado IN ('0','1')
							AND a.folio_oper    = b.folio_oper   
                            AND c.cod_proveedor = b.cod_proveedor 
                          ORDER BY b.fecha_solicitud ASC

                          SELECT nombre INTO vNomSuc      FROM bdinteg:"informix".si_sucursales WHERE sucursal = vSucursal AND empresa = eEmpresa;
                          SELECT nombre INTO vNomUsuRever FROM bdinteg:"informix".si_ejecut     WHERE ejecutivo = vUsuarioRever;
                          SELECT descripcion INTO vDesStatus FROM bdisuc:"informix".ss_catstatus WHERE status = eStatus;
                          SELECT descripcion INTO  vNomPlaza   FROM bdinteg:"informix".si_plazas_cajagen WHERE codigo_plaza = ePlaza AND empresa = eEmpresa;

                          RETURN vcodret, vCodProveedor,vFolOper,vDesStatus ,vSucursal ||' '|| vNomSuc,vFolSuc,vFecSol, vUsuarioSol || ' ' ||vNomUsuSol,
                              vFecEnvio,vUsuarioEnv || ' '|| vNomUsuEnv, vFecRecepcion, vUsuarioRecep || ' ' || vNomUsuRecep,
                              vDesStatus,vMonto,vFecRever,vUsuarioRever || ' '|| vNomUsuRever,eEmpresa,vNomPlaza   WITH RESUME;
                   END FOREACH;

  ELIF ePlaza <> '000' AND eSucursal <> '0000' AND eStatus <> '00' THEN
                FOREACH
                          SELECT {+ INDEX(ss_operaciones idx01ss_operaciones)} b.folio_oper,b.sucursal,b.folio_sucursal,b.fecha_solicitud,b.usuario_solicitud,
                                 b.fecha_envio,b.usuario_envio,b.fecha_recepcion,b.usuario_recepcion,b.monto,b.fecha_reversion,
                                 b.usuario_reversion,c.descripcion, b.status
                          INTO  vFolOper,vSucursal,vFolSuc,vFecSol,vUsuarioSol,
                                vFecEnvio,vUsuarioEnv,vFecRecepcion,vUsuarioRecep,vMonto,vFecRever,
                                vUsuarioRever,vCodProveedor,eStatus
                          FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores  c
						  WHERE a.cod_trans != '0'                      
                            AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin 
						    AND a.sucursal = eSucursal
							AND a.reversado IN ('0','1')
							AND a.folio_oper    = b.folio_oper   
                            AND c.cod_proveedor = b.cod_proveedor 
                            AND b.status        = eStatus
                          ORDER BY b.fecha_solicitud ASC

                          SELECT nombre INTO vNomSuc      FROM bdinteg:"informix".si_sucursales WHERE sucursal = vSucursal AND empresa = eEmpresa;
                          SELECT nombre INTO vNomUsuRever FROM bdinteg:"informix".si_ejecut     WHERE ejecutivo = vUsuarioRever;
                          SELECT descripcion INTO vDesStatus FROM bdisuc:"informix".ss_catstatus WHERE status = eStatus;
                          SELECT descripcion INTO  vNomPlaza   FROM bdinteg:"informix".si_plazas_cajagen WHERE codigo_plaza = ePlaza AND empresa = eEmpresa;

                          RETURN vcodret, vCodProveedor,vFolOper,vDesStatus ,vSucursal ||' '|| vNomSuc,vFolSuc,vFecSol, vUsuarioSol || ' ' ||vNomUsuSol,
                              vFecEnvio,vUsuarioEnv || ' '|| vNomUsuEnv, vFecRecepcion, vUsuarioRecep || ' ' || vNomUsuRecep,
                              vDesStatus,vMonto,vFecRever,vUsuarioRever || ' '|| vNomUsuRever,eEmpresa,vNomPlaza   WITH RESUME;
                   END FOREACH;

  ELIF ePlaza <> '000' AND eSucursal = '0000' AND eStatus <> '00' THEN
                FOREACH
                          SELECT {+ INDEX(ss_operaciones idx01ss_operaciones)} b.folio_oper,b.sucursal,b.folio_sucursal,b.fecha_solicitud,b.usuario_solicitud,
                                 b.fecha_envio,b.usuario_envio,b.fecha_recepcion,b.usuario_recepcion,b.monto,b.fecha_reversion,
                                 b.usuario_reversion ,c.descripcion, b.status
                          INTO  vFolOper,vSucursal,vFolSuc,vFecSol,vUsuarioSol,
                                vFecEnvio,vUsuarioEnv,vFecRecepcion,vUsuarioRecep,vMonto,vFecRever,
                                vUsuarioRever,vCodProveedor,eStatus
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
                            AND b.status        = eStatus
                          ORDER BY b.fecha_solicitud ASC

                          SELECT nombre INTO vNomSuc      FROM bdinteg:"informix".si_sucursales WHERE sucursal = vSucursal AND empresa = eEmpresa;
                          SELECT nombre INTO vNomUsuRever FROM bdinteg:"informix".si_ejecut     WHERE ejecutivo = vUsuarioRever;
                          SELECT descripcion INTO vDesStatus FROM bdisuc:"informix".ss_catstatus WHERE status = eStatus;
                          SELECT descripcion INTO  vNomPlaza   FROM bdinteg:"informix".si_plazas_cajagen WHERE codigo_plaza = ePlaza AND empresa = eEmpresa;

                          RETURN vcodret, vCodProveedor,vFolOper,vDesStatus ,vSucursal ||' '|| vNomSuc,vFolSuc,vFecSol,
                              vUsuarioSol || ' ' ||vNomUsuSol,
                              vFecEnvio,vUsuarioEnv || ' '|| vNomUsuEnv, vFecRecepcion, vUsuarioRecep || ' ' || vNomUsuRecep,
                              vDesStatus,vMonto,vFecRever,vUsuarioRever || ' '|| vNomUsuRever,eEmpresa,vNomPlaza   WITH RESUME;
                 END FOREACH;

 ELSE
                IF eMes <> '' AND eAnio <> '' THEN
                      FOREACH
                          SELECT {+ INDEX(ss_operaciones idx01ss_operaciones)} b.folio_oper,b.sucursal,b.folio_sucursal,b.fecha_solicitud,b.usuario_solicitud,
                                 b.fecha_envio,b.usuario_envio,b.fecha_recepcion,b.usuario_recepcion,b.monto,b.fecha_reversion,
                                 b.usuario_reversion ,c.descripcion, b.status
                          INTO  vFolOper,vSucursal,vFolSuc,vFecSol,vUsuarioSol,
                                vFecEnvio,vUsuarioEnv,vFecRecepcion,vUsuarioRecep,vMonto,vFecRever,
                                vUsuarioRever,vCodProveedor,eStatus
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
                            AND c.cod_proveedor = b.cod_proveedor 
                          ORDER BY b.fecha_solicitud ASC


                          SELECT nombre, plaza_cajagen INTO vNomSuc, ePlaza FROM bdinteg:"informix".si_sucursales WHERE sucursal = vSucursal AND empresa = eEmpresa;
                          SELECT nombre INTO vNomUsuSol   FROM bdinteg:"informix".si_ejecut     WHERE ejecutivo = vUsuarioSol;
                          SELECT nombre INTO vNomUsuEnv   FROM bdinteg:"informix".si_ejecut     WHERE ejecutivo = vUsuarioEnv;
                          SELECT nombre INTO vNomUsuRecep FROM bdinteg:"informix".si_ejecut     WHERE ejecutivo = vUsuarioRecep;
                          SELECT nombre INTO vNomUsuRever FROM bdinteg:"informix".si_ejecut     WHERE ejecutivo = vUsuarioRever;
                          SELECT descripcion INTO vDesStatus FROM bdisuc:"informix".ss_catstatus WHERE status = eStatus;                          
                          SELECT descripcion INTO  vNomPlaza   FROM bdinteg:"informix".si_plazas_cajagen WHERE codigo_plaza = ePlaza AND empresa = eEmpresa;

                          RETURN vcodret, vCodProveedor,vFolOper,vDesStatus ,vSucursal ||' '|| vNomSuc,vFolSuc,vFecSol,
                              vUsuarioSol || ' ' ||vNomUsuSol,
                              vFecEnvio,vUsuarioEnv || ' '|| vNomUsuEnv, vFecRecepcion, vUsuarioRecep || ' ' || vNomUsuRecep,
                              vDesStatus,vMonto,vFecRever,vUsuarioRever || ' '|| vNomUsuRever,eEmpresa,vNomPlaza   WITH RESUME;
                       END FOREACH;
                END IF;
  END IF;

END PROCEDURE;