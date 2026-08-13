CREATE PROCEDURE "informix".sp_monitor_operaciones2_2(eEmpresa      CHAR(3),
                                                    eTipo         CHAR(1), --**C = ATM , S = Sucursal
                                                    eSucursal     CHAR(4),
                                                    eCodTrans     CHAR(4),  --Operacion
                                                    eFecInicio    DATE,
                                                    eFecFin       DATE,
                                                    eProveedor    CHAR(4)) 
			RETURNING CHAR(5),        --** Error vCodRet            vcodret                            
                      --CHAR(50),       --** Nombre Sucursal          vSucursal|| ' '||vNomSuc  
					  CHAR(4),       	--** Nombre Sucursal          vSucursal 
					  CHAR(45),         --** Nombre Sucursal          vNomSuc  
                      DATE   ,        --** Fec. Operacion           vFecOpera                          
                      CHAR(50),       --** Desc. Status                     vDesStatus                                 
                      CHAR(16),       --** Folio                            vFolio                             
                      DECIMAL(14,2),  --** Monto                            vMonto                             
                      CHAR(50),       --** CodTrans                         vDesCodTra                         
                      CHaR(4),        --** Cod Proveedor            vCodProveedor                      
                      CHAR(50),       --** Procedencia                      vProcedencia  || ' '|| vDesProv    
                      CHAR(16),       --** folio Servicio           vFolioSer                          
                      CHAR(40),       --** Usuario                          vUsuario || ' ' || vNomUsuSol      
                      CHAR(4),        --** Status                           vStatus                            
                      CHAR(6),                --** Id ATM                           vIdatm
                      INTEGER,            --Biellete 1000
                      INTEGER,                --Biellete 500
                      INTEGER,                --Biellete 200
                      INTEGER,                --Biellete 100
                      INTEGER,                --Biellete 50
                      INTEGER,                --Biellete 20
                      INTEGER,                --Biellete 10
                      INTEGER,                --Biellete 5
                      INTEGER,                --Biellete 2
                      INTEGER,                --Biellete 1
                      INTEGER,                --Biellete .50  
                      CHAR(40),               --Nombre de codigo proveedor
                      INTEGER ,               --Posicion en reporte
                      money (18,2),  -- sdo caja 
                      CHAR(4);               --CC ATM


	DEFINE vCodRet       CHAR(5);
	DEFINE vWHERE        CHAR(300);
	DEFINE vPlaza        CHAR(4);
	DEFINE vSucursal     CHAR(4);
	DEFINE vNomSuc       CHAR(50);
	DEFINE vFecOpera     DATE;
	DEFINE vStatus       CHAR(4);
	DEFINE vFolio        CHAR(16);
	DEFINE vMonto        DECIMAL(14,2);
	DEFINE vUsuario      CHAR(8);
	DEFINE vCodProveedor CHAR(4);
	DEFINE vProcedencia  CHAR(4);
	DEFINE vFolioSer     CHAR(16);
	DEFINE vCodTrans     CHAR(4);
	DEFINE vNomUsuSol    CHAR(40);
	DEFINE vDesCodTra    CHAR(50);
	DEFINE vDesStatus    CHAR(70);
	DEFINE vDesProv      CHAR(40);
	DEFINE vCajGen       CHAR(1);
	DEFINE vIdatm        CHAR(15);
	DEFINE v1000         INTEGER;
	DEFINE v500          INTEGER;
	DEFINE v200          INTEGER;
	DEFINE v100          INTEGER;
	DEFINE v50           INTEGER;
	DEFINE v20           INTEGER;
	DEFINE v10           INTEGER;
	DEFINE v5            INTEGER;
	DEFINE v2            INTEGER;
	DEFINE v1            INTEGER;
	DEFINE vm50          INTEGER;
	DEFINE vnomprov      CHAR(40);   
	DEFINE sdo_caja      MONEY (18,2);
	DEFINE vcc_atm       CHAR(4);
	DEFINE iNoRegistros  INTEGER;
	DEFINE iPosReporte   SMALLINT;
	
	LET vCodRet       = "000";
	LET vWHERE        = '';
	LET vPlaza        = '';
	LET vSucursal     = '';
	LET vNomSuc       = '';
	LET vFecOpera     = '';
	LET vStatus       = '';
	LET vFolio        = '';
	LET vMonto        = 0;
	LET vUsuario      = '';
	LET vCodProveedor = '';
	LET vProcedencia   = '';
	LET vFolioSer     = '';
	LET vNomUsuSol    = '';
	LET vDesCodTra    = '';
	LET vDesStatus    = '';
	LET vDesProv      = '';
	LET vCajGen       = 'N';
	LET vIdatm        = '';
	lET v1000         = 0 ;
	lET v500          = 0 ;
	lET v200          = 0 ;
	lET v100          = 0 ;
	lET v50           = 0 ;
	lET v20           = 0 ;
	lET v10           = 0 ;
	lET v5            = 0 ;
	lET v2            = 0 ;
	lET v1            = 0 ;
	lET vm50          = 0 ;  
	LET vnomprov      = 0 ; 
	LET sdo_caja      = 0 ; 
	LET vcc_atm       = '';
	LET iNoRegistros  = 0 ;
	LET iPosReporte   = 0;
	
	BEGIN

		--SET DEBUG FILE TO "/tmp/mfinis/sp_monitor_operaciones2_2.out";
		--TRACE ON;

		SET LOCK MODE TO WAIT 3; 
		SET ISOLATION TO DIRTY READ;

		LET eTipo = eTipo;
		LET eProveedor = eProveedor;
		LET vCodTrans  = eCodTrans;
		LET eFecInicio = eFecinicio;
		LET eFecFin    = eFecFin;

        IF eSucursal='0000' AND eCodTrans='0000' THEN
            LET eSucursal='';
            LET eCodTrans='';
        END IF;

		IF eCodTrans = '' OR eCodTrans IS NULL THEN   --** Por operacion
			IF eFecInicio = '' OR eFecInicio IS NULL  THEN
				LET eFecInicio = MDY(1,1,2007);
			END IF

			IF eTipo = 'C' THEN
				LET vCajGen = eTipo;
			END IF
		
			FOREACH 
				SELECT b.sucursal,a.fecha_operacion,b.status,b.folio_oper,b.monto, b.cod_proveedor, c.descripcion,
					NVL(a.procedencia,''),b.folio_servicio,a.usuario,a.cod_trans
				INTO vSucursal,vFecOpera, vStatus,vFolio,vMonto, vCodProveedor,vnomprov,vProcedencia,vFolioSer,
					vUsuario,vCodTrans
				FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores c
				WHERE a.cod_trans != '0'
					AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin
					AND a.sucursal IN (SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal)} sucursal
									FROM bdinteg:"informix".si_sucursales
									WHERE sucursal != '0'
										AND empresa = eEmpresa
										AND tpo_sucursal = eTipo or tpo_sucursal = vCajGen)
					AND a.reversado IN ('0','1')
					AND a.folio_oper    = b.folio_oper
					AND b.cod_proveedor = eProveedor
					AND c.cod_proveedor = b.cod_proveedor
				ORDER BY UPPER(TRIM(c.descripcion)) ASC 

				SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal)} nombre
				INTO vNomSuc
				FROM bdinteg:"informix".si_sucursales
				WHERE sucursal = vSucursal;

				SELECT descripcion
				INTO vDesStatus
				FROM bdisuc:"informix".ss_catstatus
				WHERE status = vStatus;

				SELECT nombre
				INTO vNomUsuSol   
				FROM bdinteg:"informix".si_ejecut     
				WHERE ejecutivo = vUsuario;

				SELECT TRIM(descripcion) 
				INTO vDesCodTra 
				FROM bdisuc:"informix".ss_param_cajagen 
				WHERE codigo = vCodTrans;

				SELECT TRIM(descripcion) 
				INTO vDesProv 
				FROM bdisuc:"informix".ss_cat_proveedor 
				WHERE codigo= vProcedencia;

				RETURN vcodret, vSucursal, vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
					vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,'',0,0,0,0,0,0,0,0,0,0,0,vnomprov,1,0, '' WITH RESUME; 
					
				LET iNoRegistros = iNoRegistros + 1;

			END FOREACH;

			IF iNoRegistros = 0 THEN
				LET vcodret = '001';
				RETURN vcodret, vSucursal, vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
					vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,'',0,0,0,0,0,0,0,0,0,0,0,vnomprov,1,0, ''; 
			END IF;
			
		ELIF eProveedor = '0000' THEN

			IF eFecInicio = '' OR eFecInicio IS NULL  THEN
				LET eFecInicio= MDY(1,1,2007);
			END IF;

			IF eCodTrans in ('0001','0002','0036','0041') THEN
			
					IF eCodTrans ='0001' THEN
						FOREACH 
							SELECT *
							INTO vSucursal,vFecOpera, vStatus,vFolio,vMonto, vCodProveedor,vnomprov,vProcedencia,vFolioSer, vUsuario, vCodTrans, iPosReporte
							FROM (
								SELECT a.sucursal,a.fecha_operacion,b.status,a.folio_oper,a.monto, b.cod_proveedor, c.descripcion,
										NVL(a.procedencia,''),b.folio_servicio,a.usuario,a.cod_trans, 1 as pos_reporte
								FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores c
								WHERE a.cod_trans = eCodTrans
									AND b.status IN ('01','03','05','11','08')
									AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin
									AND(a.sucursal IN (SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal)} sucursal
														FROM bdinteg:"informix".si_sucursales
														WHERE sucursal != '0'
														AND empresa = eEmpresa
														AND tpo_sucursal = eTipo)
									OR a.sucursal IN (SELECT cod_proveedor
													FROM bdisuc:ss_proveedores
													WHERE cod_proveedor = b.cod_proveedor ))
														AND a.reversado IN ('0','1')
									AND a.folio_oper = b.folio_oper
									AND c.cod_proveedor = b.cod_proveedor
							UNION
							SELECT '', ta.fecha_operacion, '', '', SUM(monto) as total_monto, ta.cod_proveedor, ta.descripcion, 
								'', '', '', '', 2 as pos_reporte
							FROM (
								SELECT a.sucursal,a.fecha_operacion,b.status,a.folio_oper,a.monto, b.cod_proveedor, c.descripcion,
									NVL(a.procedencia,''),b.folio_servicio,a.usuario,a.cod_trans
								FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores c
								WHERE a.cod_trans = eCodTrans
									AND b.status IN ('01','03','05','11','08')
									AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin
									AND(a.sucursal IN (SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal)} sucursal
														FROM bdinteg:"informix".si_sucursales
														WHERE sucursal != '0'
														AND empresa = eEmpresa
														AND tpo_sucursal = eTipo)
									OR a.sucursal IN (SELECT cod_proveedor
														FROM bdisuc:ss_proveedores
														WHERE cod_proveedor = b.cod_proveedor ))
														AND a.reversado IN ('0','1')
									AND a.folio_oper = b.folio_oper
									AND c.cod_proveedor = b.cod_proveedor) as ta
								GROUP BY 1,2,3,4,6,7,8,9,10)
							ORDER BY UPPER(TRIM(descripcion)) ASC

							SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal)} nombre 
							INTO vNomSuc 
							FROM bdinteg:"informix".si_sucursales 
							WHERE sucursal = vSucursal;                          

							SELECT descripcion
							INTO vDesStatus
							FROM bdisuc:"informix".ss_catstatus
							WHERE status = vStatus;

							SELECT nombre
							INTO vNomUsuSol
							FROM bdinteg:"informix".si_ejecut
							WHERE ejecutivo = vUsuario;

							SELECT TRIM(descripcion)
							INTO vDesCodTra
							FROM bdisuc:"informix".ss_param_cajagen
							WHERE codigo = vCodTrans;

							SELECT TRIM(descripcion)
							INTO vDesProv 
							FROM bdisuc:"informix".ss_cat_proveedor
							WHERE codigo= vProcedencia;

							SELECT id 
							INTO vIdatm 
							FROM  bdisuc:"informix".ss_relacionccid 
							WHERE cc = vSucursal;

							SELECT cantidad_1, cantidad_2 ,cantidad_3,cantidad_4,cantidad_5,cantidad_6, cantidad_7, cantidad_8, cantidad_9,cantidad_10,cantidad_11
							INTO v1000,v500,v200,v100,v50,v20,v10,v5,v2,v1,vm50
							FROM bdisuc:"informix".ss_operaciones WHERE folio_oper = vFolio;

							SELECT cc 
							INTO vcc_atm
							FROM  bdisuc:"informix".ss_relacionccid 
							WHERE cc = vSucursal;

							RETURN vcodret, vSucursal, vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
								vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,vIdatm,v1000,v500,v200,v100,v50,v20,v10,v5,v2,v1,vm50,vnomprov,iPosReporte,0,vcc_atm WITH RESUME;
							
							LET iNoRegistros = iNoRegistros + 1;

						END FOREACH;
						
						IF iNoRegistros = 0 THEN
							LET vcodret = '001';
							RETURN vcodret, vSucursal, vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
								vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,'',0,0,0,0,0,0,0,0,0,0,0,vnomprov,1,0, ''; 
						END IF;					

					ELSE

						FOREACH 
							SELECT *
							INTO vSucursal,vFecOpera, vStatus,vFolio,vMonto, vCodProveedor,vnomprov,vProcedencia,vFolioSer, vUsuario, vCodTrans, iPosReporte
							FROM (
								SELECT a.sucursal,a.fecha_operacion,b.status,a.folio_oper,a.monto, b.cod_proveedor, c.descripcion,
									NVL(a.procedencia,''),b.folio_servicio,a.usuario,a.cod_trans, 1 as pos_reporte
								FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores c
								WHERE a.cod_trans = eCodTrans
									AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin
									AND( a.sucursal IN (SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal)} sucursal
													FROM bdinteg:"informix".si_sucursales
													WHERE sucursal != '0'
														AND empresa = eEmpresa
														AND tpo_sucursal = eTipo)
									OR a.sucursal IN (SELECT cod_proveedor
													FROM bdisuc:ss_proveedores
													WHERE cod_proveedor = b.cod_proveedor ))
									AND a.reversado IN ('0','1')
									AND a.folio_oper = b.folio_oper
									AND c.cod_proveedor = b.cod_proveedor
								UNION
								SELECT '', ta.fecha_operacion, '', '', SUM(monto) as total_monto, ta.cod_proveedor, ta.descripcion, 
																'', '', '', '', 2 as pos_reporte
								FROM (
									SELECT a.sucursal,a.fecha_operacion,b.status,a.folio_oper,a.monto, b.cod_proveedor, c.descripcion,
										NVL(a.procedencia,''),b.folio_servicio,a.usuario,a.cod_trans
									FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores c
									WHERE a.cod_trans = eCodTrans
										AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin
										AND( a.sucursal IN (SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal)} sucursal
														FROM bdinteg:"informix".si_sucursales
														WHERE sucursal != '0'
															AND empresa = eEmpresa
															AND tpo_sucursal = eTipo)
										OR a.sucursal IN (SELECT cod_proveedor
														FROM bdisuc:ss_proveedores
														WHERE cod_proveedor = b.cod_proveedor ))
										AND a.reversado IN ('0','1')
										AND a.folio_oper = b.folio_oper
										AND c.cod_proveedor = b.cod_proveedor) ta
								GROUP BY 1,2,3,4,6,7,8,9,10)
							ORDER BY UPPER(TRIM(descripcion)) ASC 

							SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal)} nombre
							INTO vNomSuc 
							FROM bdinteg:"informix".si_sucursales
							WHERE sucursal = vSucursal;                          

							SELECT descripcion
							INTO vDesStatus
							FROM bdisuc:"informix".ss_catstatus
							WHERE status = vStatus;

							SELECT nombre
							INTO vNomUsuSol
							FROM bdinteg:"informix".si_ejecut
							WHERE ejecutivo = vUsuario;

							SELECT TRIM(descripcion)
							INTO vDesCodTra
							FROM bdisuc:"informix".ss_param_cajagen
							WHERE codigo = vCodTrans;

							SELECT TRIM(descripcion)
							INTO vDesProv
							FROM bdisuc:"informix".ss_cat_proveedor
							WHERE codigo= vProcedencia;

							SELECT id
							INTO vIdatm
							FROM bdisuc:"informix".ss_relacionccid
							WHERE cc = vSucursal;

							SELECT cantidad_1, cantidad_2 ,cantidad_3,cantidad_4,cantidad_5,cantidad_6, cantidad_7, cantidad_8, cantidad_9,cantidad_10,cantidad_11
							INTO v1000,v500,v200,v100,v50,v20,v10,v5,v2,v1,vm50
							FROM bdisuc:"informix".ss_operaciones WHERE folio_oper = vFolio;

							SELECT cc
							INTO vcc_atm
							FROM bdisuc:"informix".ss_relacionccid
							WHERE cc = vSucursal;

							RETURN vcodret, vSucursal, vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
								vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,vIdatm,v1000,v500,v200,v100,v50,v20,v10,v5,v2,v1,vm50,vnomprov,iPosReporte,0,vcc_atm WITH RESUME;


							LET iNoRegistros = iNoRegistros + 1;

						END FOREACH;
						
						IF iNoRegistros = 0 THEN
							LET vcodret = '001';
							RETURN vcodret, vSucursal, vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
								vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,'',0,0,0,0,0,0,0,0,0,0,0,vnomprov,1,0, ''; 
						END IF;					
					END IF;
		
			END IF;

		ELIF eSucursal <> '0000'  THEN   --** Por Sucursal

			IF eFecInicio = '' OR eFecInicio IS NULL  THEN
				LET eFecInicio= MDY(1,1,2007);
			END IF

			FOREACH
				SELECT b.sucursal,a.fecha_operacion,b.status,b.folio_oper,b.monto, b.cod_proveedor, c.descripcion,
					NVL(a.procedencia,''),b.folio_servicio,a.usuario,a.cod_trans
				INTO vSucursal,vFecOpera, vStatus,vFolio,vMonto, vCodProveedor,vnomprov,vProcedencia,vFolioSer,
					vUsuario,vCodTrans
				FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores c
				WHERE a.cod_trans = eCodTrans
					AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin
					AND a.sucursal = eSucursal
					AND a.reversado IN ('0','1')
					AND a.folio_oper    = b.folio_oper
					AND c.cod_proveedor = b.cod_proveedor
				ORDER BY UPPER(TRIM(c.descripcion)) ASC

				SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal)} nombre 
				INTO vNomSuc
				FROM bdinteg:"informix".si_sucursales
				WHERE sucursal = vSucursal;

				SELECT descripcion
				INTO vDesStatus
				FROM bdisuc:"informix".ss_catstatus
				WHERE status = vStatus;

				SELECT nombre
				INTO vNomUsuSol
				FROM bdinteg:"informix".si_ejecut
				WHERE ejecutivo = vUsuario;

				SELECT TRIM(descripcion)
				INTO vDesCodTra
				FROM bdisuc:"informix".ss_param_cajagen
				WHERE codigo = vCodTrans;

				SELECT TRIM(descripcion)
				INTO vDesProv
				FROM bdisuc:"informix".ss_cat_proveedor
				WHERE codigo= vProcedencia;

				RETURN vcodret, vSucursal, vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
					vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,'',0,0,0,0,0,0,0,0,0,0,0,vnomprov,1,0,'' WITH RESUME;
				
				LET iNoRegistros = iNoRegistros + 1;

			END FOREACH;
			
			IF iNoRegistros = 0 THEN
				LET vcodret = '001';
				RETURN vcodret, vSucursal, vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
					vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,'',0,0,0,0,0,0,0,0,0,0,0,vnomprov,1,0, ''; 
			END IF;

		ELSE

			FOREACH
				SELECT a.sucursal,a.fecha_operacion,b.status,a.folio_oper,a.monto, b.cod_proveedor, c.descripcion,
					NVL(a.procedencia,''),b.folio_servicio,a.usuario,a.cod_trans
				INTO vSucursal,vFecOpera, vStatus,vFolio,vMonto, vCodProveedor,vnomprov,vProcedencia,vFolioSer,
					vUsuario,vCodTrans
				FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores c
				WHERE a.cod_trans = eCodTrans
					AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin
					AND( a.sucursal IN (SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal)} sucursal
										FROM bdinteg:"informix".si_sucursales
										WHERE sucursal != '0'
											AND empresa = eEmpresa
											AND tpo_sucursal = eTipo)
					OR a.sucursal IN (SELECT cod_proveedor
										FROM bdisuc:ss_proveedores
										WHERE cod_proveedor = eProveedor))
					AND a.reversado IN ('0','1')
					AND a.folio_oper    = b.folio_oper
					AND b.cod_proveedor = eProveedor
					AND c.cod_proveedor = b.cod_proveedor
				ORDER BY UPPER(TRIM(c.descripcion)) ASC

				SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal)} nombre
				INTO vNomSuc
				FROM bdinteg:"informix".si_sucursales
				WHERE sucursal = vSucursal;

				SELECT descripcion
				INTO vDesStatus 
				FROM bdisuc:"informix".ss_catstatus 
				WHERE status = vStatus;

				SELECT nombre
				INTO vNomUsuSol
				FROM bdinteg:"informix".si_ejecut 
				WHERE ejecutivo = vUsuario;

				SELECT TRIM(descripcion) 
				INTO vDesCodTra
				FROM bdisuc:"informix".ss_param_cajagen
				WHERE codigo = vCodTrans;

				SELECT TRIM(descripcion)
				INTO vDesProv
				FROM bdisuc:"informix".ss_cat_proveedor
				WHERE codigo= vProcedencia;

				RETURN vcodret, vSucursal, vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
					vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,'',0,0,0,0,0,0,0,0,0,0,0,vnomprov,1,0,'' WITH RESUME;
					
				LET iNoRegistros = iNoRegistros + 1;

			END FOREACH;
			
			IF iNoRegistros = 0 THEN
				LET vcodret = '001';
				RETURN vcodret, vSucursal, vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
					vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,'',0,0,0,0,0,0,0,0,0,0,0,vnomprov,1,0, ''; 
			END IF;

		END IF;

	END;

END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 12/01/2015',
'DESCRIPCION: Clon del SPL de sp_monitor_operaciones para manejar la paginacion',
'vcodret = 001 -> No se encontraron datos',
'eTotalRes = 1 -> Recuperar registros con la sumatoria de las operaciones 0001,0002,0036,0041',
'AUTOR: L. Montserrat Leon Amador',
'FECHA: 08/10/2015',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: Monitor Operaciones', 
'DESCRIPCION: Se hizo la modificacion para que el retorno de los registros se ordenara por descripcion caja general (descripcion)',
'AUTOR: L. Montserrat Leon Amador',
'FECHA: 25/10/2016',
'DESCRIPCION: Se realiza spl clon para que retorne el bloque total de registros.',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_faltsob_cg( pempresa CHAR(3), 
		pcodigo_proveedor CHAR(4),
		pcajeroprincipal CHAR(8), 
        pfolio_suc char(16),
  		ptransaccion char(4),
		pdivisa CHAR(2),
		pmonto money(14,2),
        pfecha date,
		pdeno1 CHAR(18),
		pdeno2 CHAR(18),
		pdeno3 CHAR(18),
		pdeno4 CHAR(18),
        pdeno5 CHAR(18),
		pdeno6 CHAR(18),
		pdeno7 CHAR(18),
		pdeno8 CHAR(18),
		pdeno9 CHAR(18),
		pdeno10 CHAR(18),
        pdeno11 CHAR(18),
		pdeno12 CHAR(18),
		pdeno13 CHAR(18),
		pdeno14 CHAR(18),
		pdeno15 CHAR(18),
		pcant1 float(8),
		pcant2 float(8),
		pcant3 float(8),
		pcant4 float(8),
		pcant5 float(8),
		pcant6 float(8),
		pcant7 float(8),
		pcant8 float(8),
		pcant9 float(8),
        pcant10 float(8),
		pcant11 float(8),
		pcant12 float(8),
		pcant13 float(8),
		pcant14 float(8),
		pcant15 float(8) )
		
RETURNING CHAR(5),char(8);

DEFINE vcodret CHAR(5);
DEFINE vfolio char(8);
DEFINE vsqlerr,visamerr INTEGER;
DEFINE vhora char(5);
DEFINE vnum integer;
DEFINE vmonto money(14,2);
DEFINE iContador INTEGER;

LET vcodret = "000";
LET vfolio = "";
LET vhora = substr(current,12,5);
LET vnum = 0;
LET iContador = 0;

BEGIN
ON EXCEPTION SET vsqlerr,visamerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      RETURN vcodret,vfolio;
   END IF;
END EXCEPTION;

--SET debug file to "/tmp/sp_faltsob_cg.out";
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--- Verifica recepcion correcta de datos
IF pempresa = '0' or pempresa = '' or pcodigo_proveedor = '0' or pcodigo_proveedor = '' or
   pdivisa = '0' or pdivisa = ''  or pcajeroprincipal = '0' or 
   pcajeroprincipal = '' or pfolio_suc = '0' or pfolio_suc = '' or ptransaccion = '0' or ptransaccion = ''
   or pmonto = 0 then
   LET vcodret = "110";
ELSE

	SELECT COUNT(*) INTO iContador FROM bdisuc:"informix".ss_proveedores WHERE cod_proveedor = pcodigo_proveedor;		
	IF iContador > 0 THEN
		IF ptransaccion != '0070' AND ptransaccion != '0071' THEN
			LET vcodret = "106";
		ELSE
		-----TRAE EL VALOR DEL FOLIO
			SELECT valor
			  INTO vnum
			  FROM bdisuc:"informix".ss_param_cajagen
			 WHERE codigo = '0005';
		----ACTUALIXA VALOR DEL FOLIO A + 1
			UPDATE bdisuc:"informix".ss_param_cajagen
			   SET valor = valor + 1
			 WHERE  codigo = '0005';   

			LET vfolio = LPAD(ROUND(vnum),8,"0");

			INSERT INTO bdisuc:ss_operaciones
			  (empresa,cod_trans,fecha_operacion,sucursal,folio_sucursal,folio_oper,reversado,usuario,divisa,monto,
				   denominacion_1,denominacion_2,denominacion_3,denominacion_4,denominacion_5,denominacion_6,denominacion_7,
				   cantidad_1,cantidad_2,cantidad_3,cantidad_4,cantidad_5,cantidad_6,cantidad_7,cantidad_8,cantidad_9,cantidad_10,
				   cantidad_11,cantidad_12,cantidad_13,cantidad_14,cantidad_15)
			VALUES	   
			(pempresa,ptransaccion,pfecha,pcodigo_proveedor,pfolio_suc,vfolio,'0',pcajeroprincipal,pdivisa,pmonto,
				   pdeno1,pdeno2,pdeno3,pdeno4,pdeno5,pdeno6,pdeno7,pcant1,pcant2,pcant3,pcant4,pcant5,pcant6,pcant7,pcant8,pcant9,
				   pcant10,pcant11,pcant12,pcant13,pcant14,pcant15);
			
			IF ptransaccion = '0070' THEN --Faltante Caja General
				
				UPDATE bdisuc:ss_cajageneral set cantidad_1 = cantidad_1 + pcant1,cantidad_2 = cantidad_2 + pcant2,cantidad_3 = cantidad_3 + pcant3,
									cantidad_4 = cantidad_4 + pcant4,cantidad_5 = cantidad_5 + pcant5,cantidad_6 = cantidad_6 + pcant6,
									cantidad_7 = cantidad_7 + pcant7,saldo_total =  saldo_total + pmonto
				WHERE  cod_proveedor = pcodigo_proveedor; 
				
			ELIF ptransaccion = '0071' THEN --Sobrante Caja General
				
				UPDATE bdisuc:ss_cajageneral set cantidad_1 = cantidad_1 - pcant1,cantidad_2 = cantidad_2 - pcant2,cantidad_3 = cantidad_3 - pcant3,
									cantidad_4 = cantidad_4 - pcant4,cantidad_5 = cantidad_5 - pcant5,cantidad_6 = cantidad_6 - pcant6,
									cantidad_7 = cantidad_7 - pcant7,saldo_total =  saldo_total - pmonto
				WHERE  cod_proveedor = pcodigo_proveedor; 
			
			END IF;
		END IF;
	ELSE
		LET vcodret = "105";
		RETURN vcodret,vfolio;
	END IF;
END IF;

RETURN vcodret,vfolio;
END;
END PROCEDURE;