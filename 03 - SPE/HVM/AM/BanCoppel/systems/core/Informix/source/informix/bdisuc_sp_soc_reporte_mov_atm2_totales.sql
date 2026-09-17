CREATE PROCEDURE "informix".sp_soc_reporte_mov_atm2_totales(vfechadesde DATE, vfechaal DATE, vmovimiento CHAR(15))
	RETURNING CHAR(6) as codret,
	INTEGER as no_registros;  

	DEFINE  SQL_ERR           INTEGER;
	DEFINE  ISAM_ERR          INTEGER;
	DEFINE  ERROR_INFO        VARCHAR(80);
	DEFINE  vcodret           CHAR(6);
	DEFINE  mensaje           CHAR(50);
	DEFINE  vcc               CHAR(4);  --sucursal
	DEFINE  vnomatm           CHAR(40); --nombre del atm
	DEFINE  vfecha            DATE;     --fecha del movimiento
	DEFINE  pmovimiento       CHAR(15); --tipo de movimiento: Alta, Modificacion
	DEFINE  vcodigo_proveedor CHAR(4);  --codigo del proveedor
	DEFINE  vnomcajagen       CHAR(40); --nombre de la caja general
	DEFINE  vusuario          CHAR(8);  --numero de empleado
	DEFINE  vnomusuario       CHAR(45); --nombre del empleado
	DEFINE vNoRegistros		  INTEGER;
	
	LET vcodret='';
	LET mensaje='';
	LET vcc ='';
	LET vnomatm='';
	LET pmovimiento='';
	LET vfecha='';
	LET vcodigo_proveedor='';
	LET vnomcajagen='';
	LET vusuario='';
	LET vnomusuario='';
	LET vNoRegistros = 0;
	
	BEGIN
		ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
			LET vcodret    = SQL_ERR;
			LET mensaje  = ERROR_INFO;
			 RETURN vcodret, vNoRegistros;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		
        IF vmovimiento ='TODOS' THEN
			SELECT COUNT (*)
			INTO vNoRegistros 
			FROM bdisuc:"informix".ss_bitacora_atm ssb, bdinteg:"informix".si_sucursales sis, bdisuc:"informix".ss_proveedores ssp, bdinteg:"informix".si_ejecut sie
			WHERE ssb.fecha_movimiento >=vfechadesde and ssb.fecha_movimiento <=vfechaal
			AND ssb.cc_atm=sis.sucursal
			AND ssb.cc_cajageneral=ssp.plaza
			AND ssb.usuario= sie.ejecutivo;
			
			RETURN vcodret, vNoRegistros;

        ELSE
			SELECT COUNT (*)
			INTO vNoRegistros 
			FROM bdisuc:"informix".ss_bitacora_atm ssb, bdinteg:"informix".si_sucursales sis, bdisuc:"informix".ss_proveedores ssp, bdinteg:"informix".si_ejecut sie
			WHERE ssb.fecha_movimiento >=vfechadesde and ssb.fecha_movimiento <=vfechaal
			AND ssb.accion=vmovimiento
			AND ssb.cc_atm=sis.sucursal
			AND ssb.cc_cajageneral=ssp.plaza
			AND ssb.usuario= sie.ejecutivo;
			
			RETURN vcodret, vNoRegistros;
        END IF;
end;                                            
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Hernández Pérez',
'FECHA: 19/07/2016',
'DESCRIPCION: SPL que consulta el total de los registros p',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_monitor_operaciones2(eEmpresa      CHAR(3),
                                                    eTipo         CHAR(1), --**C = ATM , S = Sucursal
                                                    eSucursal     CHAR(4),
                                                    eCodTrans     CHAR(4),  --Operacion
                                                    eFecInicio    DATE,
                                                    eFecFin       DATE,
                                                    eProveedor    CHAR(4),
                                                    eRegistros    INTEGER,
                                                    eRecuperacion INTEGER) 
			RETURNING CHAR(5),        --** Error vCodRet            vcodret                            
                      CHAR(50),       --** Nombre Sucursal          vSucursal|| ' '||vNomSuc           
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

		-- SET DEBUG FILE TO "/tmp/mfinis/sp_monitor_operaciones2.out";
		-- TRACE ON;

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
				SELECT {+INDEX (bdisuc:"informix".ss_proveedores 109_50)} SKIP eRegistros FIRST eRecuperacion b.sucursal,a.fecha_operacion,b.status,b.folio_oper,b.monto, b.cod_proveedor, c.descripcion,
					NVL(a.procedencia,''),b.folio_servicio,a.usuario,a.cod_trans
				INTO vSucursal,vFecOpera, vStatus,vFolio,vMonto, vCodProveedor,vnomprov,vProcedencia,vFolioSer,
					vUsuario,vCodTrans
				FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores c
				WHERE a.cod_trans != '0'
					AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin
					AND a.sucursal IN (SELECT sucursal
									FROM bdinteg:"informix".si_sucursales
									WHERE sucursal != '0'
										AND empresa = eEmpresa
										AND tpo_sucursal = eTipo or tpo_sucursal = vCajGen)
					AND a.reversado IN ('0','1')
					AND a.folio_oper    = b.folio_oper
					AND b.cod_proveedor = eProveedor
					AND c.cod_proveedor = b.cod_proveedor
				ORDER BY UPPER(TRIM(c.descripcion)) ASC 

				SELECT nombre
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

				RETURN vcodret, vSucursal|| ' '||vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
					vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,'',0,0,0,0,0,0,0,0,0,0,0,vnomprov,1,0, '' WITH RESUME; 
					
				LET iNoRegistros = iNoRegistros + 1;

			END FOREACH;

			IF iNoRegistros = 0 THEN
				LET vcodret = '001';
				RETURN vcodret, vSucursal|| ' '||vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
					vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,'',0,0,0,0,0,0,0,0,0,0,0,vnomprov,1,0, ''; 
			END IF;
			
		ELIF eProveedor = '0000' THEN

			IF eFecInicio = '' OR eFecInicio IS NULL  THEN
				LET eFecInicio= MDY(1,1,2007);
			END IF;

			IF eCodTrans in ('0001','0002','0036','0041') THEN
			
					IF eCodTrans ='0001' THEN
						FOREACH 
							SELECT SKIP eRegistros FIRST eRecuperacion *
							INTO vSucursal,vFecOpera, vStatus,vFolio,vMonto, vCodProveedor,vnomprov,vProcedencia,vFolioSer, vUsuario, vCodTrans, iPosReporte
							FROM (
								SELECT a.sucursal,a.fecha_operacion,b.status,a.folio_oper,a.monto, b.cod_proveedor, c.descripcion,
										NVL(a.procedencia,''),b.folio_servicio,a.usuario,a.cod_trans, 1 as pos_reporte
								FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores c
								WHERE a.cod_trans = eCodTrans
									AND b.status IN('01','03','04','11') 
									AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin
									AND(a.sucursal IN (SELECT sucursal
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
									AND b.status IN('01','03','04','11') 
									AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin
									AND(a.sucursal IN (SELECT sucursal
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

							SELECT nombre 
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

							RETURN vcodret, vSucursal|| ' '||vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
								vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,vIdatm,v1000,v500,v200,v100,v50,v20,v10,v5,v2,v1,vm50,vnomprov,iPosReporte,0,vcc_atm WITH RESUME;
							
							LET iNoRegistros = iNoRegistros + 1;

						END FOREACH;
						
						IF iNoRegistros = 0 THEN
							LET vcodret = '001';
							RETURN vcodret, vSucursal|| ' '||vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
								vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,'',0,0,0,0,0,0,0,0,0,0,0,vnomprov,1,0, ''; 
						END IF;					

					ELSE

						FOREACH 
							SELECT SKIP eRegistros FIRST eRecuperacion *
							INTO vSucursal,vFecOpera, vStatus,vFolio,vMonto, vCodProveedor,vnomprov,vProcedencia,vFolioSer, vUsuario, vCodTrans, iPosReporte
							FROM (
								SELECT a.sucursal,a.fecha_operacion,b.status,a.folio_oper,a.monto, b.cod_proveedor, c.descripcion,
									NVL(a.procedencia,''),b.folio_servicio,a.usuario,a.cod_trans, 1 as pos_reporte
								FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores c
								WHERE a.cod_trans = eCodTrans
									AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin
									AND( a.sucursal IN (SELECT sucursal
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
										AND( a.sucursal IN (SELECT sucursal
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

							SELECT nombre
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

							RETURN vcodret, vSucursal|| ' '||vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
								vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,vIdatm,v1000,v500,v200,v100,v50,v20,v10,v5,v2,v1,vm50,vnomprov,iPosReporte,0,vcc_atm WITH RESUME;


							LET iNoRegistros = iNoRegistros + 1;

						END FOREACH;
						
						IF iNoRegistros = 0 THEN
							LET vcodret = '001';
							RETURN vcodret, vSucursal|| ' '||vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
								vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,'',0,0,0,0,0,0,0,0,0,0,0,vnomprov,1,0, ''; 
						END IF;					
					END IF;
		
			END IF;

		ELIF eSucursal <> '0000'  THEN   --** Por Sucursal

			IF eFecInicio = '' OR eFecInicio IS NULL  THEN
				LET eFecInicio= MDY(1,1,2007);
			END IF

			FOREACH
				SELECT SKIP eRegistros FIRST eRecuperacion b.sucursal,a.fecha_operacion,b.status,b.folio_oper,b.monto, b.cod_proveedor, c.descripcion,
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

				SELECT nombre 
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

				RETURN vcodret, vSucursal|| ' '||vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
					vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,'',0,0,0,0,0,0,0,0,0,0,0,vnomprov,1,0,'' WITH RESUME;
				
				LET iNoRegistros = iNoRegistros + 1;

			END FOREACH;
			
			IF iNoRegistros = 0 THEN
				LET vcodret = '001';
				RETURN vcodret, vSucursal|| ' '||vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
					vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,'',0,0,0,0,0,0,0,0,0,0,0,vnomprov,1,0, ''; 
			END IF;

		ELSE

			FOREACH
				SELECT SKIP eRegistros FIRST eRecuperacion a.sucursal,a.fecha_operacion,b.status,a.folio_oper,a.monto, b.cod_proveedor, c.descripcion,
					NVL(a.procedencia,''),b.folio_servicio,a.usuario,a.cod_trans
				INTO vSucursal,vFecOpera, vStatus,vFolio,vMonto, vCodProveedor,vnomprov,vProcedencia,vFolioSer,
					vUsuario,vCodTrans
				FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores c
				WHERE a.cod_trans = eCodTrans
					AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin
					AND( a.sucursal IN (SELECT sucursal
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

				SELECT nombre
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

				RETURN vcodret, vSucursal|| ' '||vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
					vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,'',0,0,0,0,0,0,0,0,0,0,0,vnomprov,1,0,'' WITH RESUME;
					
				LET iNoRegistros = iNoRegistros + 1;

			END FOREACH;
			
			IF iNoRegistros = 0 THEN
				LET vcodret = '001';
				RETURN vcodret, vSucursal|| ' '||vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
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
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_concen_crg_masiva()
RETURNING
        CHAR(5) as Codigo,
        CHAR(50) as Mensaje;
		
DEFINE vempresa 	CHAR(4);
DEFINE vusuario 	CHAR(8);
DEFINE vtransac 	CHAR(4);
DEFINE vdivisa 		CHAR(2);
DEFINE vsecuencia 	CHAR(8);
DEFINE vfolio_suc 	CHAR(18);
DEFINE vfecha		DATE;

DEFINE vfolio_serv	CHAR(16);
DEFINE vsucursal	CHAR(4);
DEFINE vmonto		money;
DEFINE vcant_1000	FLOAT(8);
DEFINE vcant_500	FLOAT(8);
DEFINE vcant_200	FLOAT(8);
DEFINE vcant_100	FLOAT(8);
DEFINE vcant_50		FLOAT(8);
DEFINE vcant_20		FLOAT(8);

DEFINE vcant_1_atm	FLOAT(8);
DEFINE vcant_2_atm	FLOAT(8);
DEFINE vcant_3_atm	FLOAT(8);
DEFINE vcant_4_atm	FLOAT(8);
DEFINE vcant_5_atm	FLOAT(8);
DEFINE vcant_6_atm	FLOAT(8);

DEFINE vcod_ret 	CHAR(5);
DEFINE vDesErr 		CHAR(50);
DEFINE vsqlerr,visamerr INTEGER;
DEFINE vcodret_2 	CHAR(5);
DEFINE vfolio_2 	CHAR(8);
DEFINE vsecuencia_i INTEGER;

let vcod_ret     =   '00000';
let vempresa 	=	'001';
let vusuario 	=	'92803849';
let vtransac 	=	'0041';
let vdivisa 	=	'01';
let vsecuencia	=	'';
let vfecha		=	'01/01/1900';
let vsecuencia_i =	0;

BEGIN

    ON EXCEPTION SET vsqlerr, visamerr, vDesErr
        IF vsqlerr <> 0 THEN
           LET vcod_ret = vsqlerr;    
           RETURN vcod_ret, vDesErr;			
        END IF       
    END EXCEPTION;
	
	set isolation dirty read;
	
	SELECT fecha_hoy 
	INTO vfecha
	FROM bdinteg:si_fechas;
	
	INSERT INTO "informix".ss_atm_respaldo 
		SELECT empresa,cod_atm, saldo_anterior, saldo_total, cantidad_1, cantidad_2, cantidad_3, cantidad_4, cantidad_5, cantidad_6,'I'
		FROM bdisuc:ss_atm;
	
	let vsecuencia = to_char(extend(current, hour to second),'%H') || to_char(extend(current, hour to second),'%M') || to_char(extend(current, hour to second),'%S') || '00';
	
	let vsecuencia_i = vsecuencia;
	
	FOREACH SELECT folio_servicio,
					sucursal,
					monto,
					cant_1000,
					cant_500,
					cant_200,
					cant_100,
					cant_50,
					cant_20
			INTO vfolio_serv,
					vsucursal,
					vmonto,
					vcant_1000,
					vcant_500,
					vcant_200,
					vcant_100,
					vcant_50,
					vcant_20
			FROM "informix".ss_crgmasiva_concen
			WHERE aplicado not in('S','N')
		
	
	SELECT cantidad_1, cantidad_2, cantidad_3, cantidad_4, cantidad_5, cantidad_6
	INTO vcant_1_atm, vcant_2_atm, vcant_3_atm, vcant_4_atm, vcant_5_atm, vcant_6_atm
	FROM bdisuc:ss_atm
	WHERE cod_atm = vsucursal;
	
	IF vcant_1000 > vcant_1_atm OR vcant_500 > vcant_2_atm OR vcant_200 > vcant_3_atm
		OR vcant_100 > vcant_4_atm OR vcant_50 > vcant_5_atm OR vcant_20 > vcant_6_atm THEN
			UPDATE bdisuc:ss_crgmasiva_concen SET aplicado = 'N'
			WHERE sucursal = vsucursal AND folio_servicio = vfolio_serv;
	ELSE
		let vsecuencia_i = vsecuencia_i + 1;
	
		let vsecuencia = vsecuencia_i;
			
		let vfolio_suc = TRIM(vusuario) || TRIM(vsecuencia);
	
		EXECUTE PROCEDURE "informix".sp_concen_atm(vempresa,
			vsucursal,
			vusuario,
			vfolio_suc,
			vtransac,
			vdivisa,
			vmonto,
			vfecha,
			'1000',
			'500',
			'200',
			'100',
			'50',
			'20',
			'',
			'',
			'',
			'',
			'',
			'',
			'',
			'',
			'',
			vcant_1000,
			vcant_500,
			vcant_200,
			vcant_100,
			vcant_50,
			vcant_20,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			vfolio_serv)
		INTO vcodret_2, vfolio_2;
		
		IF vcodret_2 <> '000' THEN
			UPDATE bdisuc:ss_crgmasiva_concen SET aplicado = 'N'
			WHERE sucursal = vsucursal AND folio_servicio = vfolio_serv;
		ELSE
			UPDATE bdisuc:ss_crgmasiva_concen SET aplicado = 'S', folio_suc = vfolio_suc
			WHERE sucursal = vsucursal AND folio_servicio = vfolio_serv;
		END IF
		 
	END IF
	
	END FOREACH
	
	INSERT INTO "informix".ss_atm_respaldo 
		SELECT empresa,cod_atm, saldo_anterior, saldo_total, cantidad_1, cantidad_2, cantidad_3, cantidad_4, cantidad_5, cantidad_6,'F'
		FROM bdisuc:ss_atm;
	
	RETURN vcod_ret, 'PROCESO EXITOSO' WITH RESUME;

END
END PROCEDURE;