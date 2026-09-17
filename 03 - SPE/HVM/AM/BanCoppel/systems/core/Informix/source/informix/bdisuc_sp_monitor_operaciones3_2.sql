CREATE PROCEDURE "informix".sp_monitor_operaciones3_2(eEmpresa      CHAR(3),
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
                      CHAR(50),       --** Desc. Status             vDesStatus                                 
                      CHAR(16),       --** Folio                    vFolio                             
                      DECIMAL(14,2),  --** Monto                    vMonto                             
                      CHAR(50),       --** CodTrans                 vDesCodTra                         
                      CHaR(4),        --** Cod Proveedor            vCodProveedor                      
                      CHAR(50),       --** Procedencia              vProcedencia  || ' '|| vDesProv    
                      CHAR(16),       --** folio Servicio           vFolioSer                          
                      CHAR(40),       --** Usuario                  vUsuario || ' ' || vNomUsuSol      
                      CHAR(4),        --** Status                   vStatus                            
                      CHAR(6),        --** Id ATM                   vIdatm
                      INTEGER,        --Biellete 1000
                      INTEGER,        --Biellete 500
                      INTEGER,        --Biellete 200
                      INTEGER,        --Biellete 100
                      INTEGER,        --Biellete 50
                      INTEGER,        --Biellete 20
                      INTEGER,        --Biellete 10
                      INTEGER,        --Biellete 5
                      INTEGER,        --Biellete 2
                      INTEGER,        --Biellete 1
                      INTEGER,        --Biellete .50  
                      CHAR(40),       --Nombre de codigo proveedor
                      INTEGER ,       --Posicion en reporte
                      money (18,2),   -- sdo caja 
                      CHAR(4);        --CC ATM


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

		--SET debug file  to "monitor_isa.out";
		--trace on;
		--SET DEBUG FILE TO "/tmp/mfinis/Daniel/sp_monitor_operaciones3_2.out";
		--TRACE ON;

		SET LOCK MODE TO WAIT 3; 
		SET ISOLATION TO DIRTY READ;

		LET eTipo = eTipo;
		LET eProveedor = eProveedor;
		LET vCodTrans  = eCodTrans;
		LET eFecInicio = eFecinicio;
		LET eFecFin    = eFecFin;

		IF eCodTrans = '' OR eCodTrans IS NULL THEN   --** Por operacion
			IF eFecInicio = '' OR eFecInicio IS NULL  THEN
				LET eFecInicio = MDY(1,1,2007);
			END IF

			IF eTipo = 'C' THEN
				LET vCajGen = eTipo;
			END IF
		
			FOREACH 
				SELECT 
				{+INDEX (bdisuc:"informix".ss_operaciones idx01ss_operaciones)} 
				{+INDEX (bdisuc:"informix".ss_mae_entradasalida idx01ss_mae_entradasalida)}
				{+INDEX (bdisuc:"informix".ss_proveedores idx_provplaza)}
				
				b.sucursal,a.fecha_operacion,b.status,b.folio_oper,b.monto, b.cod_proveedor, c.descripcion,
				NVL(a.procedencia,''),b.folio_servicio,a.usuario,a.cod_trans
				INTO vSucursal,vFecOpera, vStatus,vFolio,vMonto, vCodProveedor,vnomprov,vProcedencia,vFolioSer,vUsuario,vCodTrans
				FROM bdisuc:"informix".ss_operaciones a
				INNER JOIN bdisuc:"informix".ss_mae_entradasalida b ON a.folio_oper = b.folio_oper
				INNER JOIN bdisuc:"informix".ss_proveedores c ON c.cod_proveedor = b.cod_proveedor 
					WHERE  a.cod_trans != '0'
					AND	b.cod_proveedor = eProveedor
					AND a.fecha_operacion >= eFecInicio AND a.fecha_operacion <= eFecFin
					AND a.sucursal IN (SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal2)} sucursal
									FROM bdinteg:"informix".si_sucursales
									WHERE sucursal != '0'
										AND empresa = eEmpresa
										AND tpo_sucursal = eTipo or tpo_sucursal = vCajGen)
					AND a.reversado IN ('0','1')
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

			IF eCodTrans in ('0001','0002','0010','0036','0041') THEN
				
					IF eCodTrans ='0001' THEN
						FOREACH 

							SELECT 
							{+INDEX (bdisuc:"informix".ss_operaciones idx01ss_operaciones)} 
							{+INDEX (bdisuc:"informix".ss_mae_entradasalida idx01ss_mae_entradasalida)}
							{+INDEX (bdisuc:"informix".ss_proveedores idx_provplaza)}
							a.sucursal,a.fecha_operacion,b.status,a.folio_oper,a.monto, b.cod_proveedor, c.descripcion,
							NVL(a.procedencia,''),b.folio_servicio,a.usuario,a.cod_trans, 1 as pos_reporte
								INTO vSucursal,vFecOpera, vStatus,vFolio,vMonto, vCodProveedor,vnomprov,vProcedencia,vFolioSer, vUsuario, vCodTrans, iPosReporte
							FROM bdisuc:"informix".ss_operaciones a 
							INNER JOIN bdisuc:"informix".ss_mae_entradasalida b ON a.folio_oper = b.folio_oper
							INNER JOIN bdisuc:"informix".ss_proveedores c ON c.cod_proveedor = b.cod_proveedor 
							WHERE a.cod_trans = eCodTrans
								AND a.fecha_operacion >= eFecInicio AND a.fecha_operacion <= eFecFin
							AND a.sucursal IN 
										(SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal2)} sucursal  
											FROM bdinteg:"informix".si_sucursales
											WHERE empresa = eEmpresa
											AND sucursal != '0'
											AND tpo_sucursal = eTipo
											UNION 
											SELECT a.cod_proveedor  	 
											FROM bdisuc:ss_proveedores a
											INNER JOIN bdisuc:"informix".ss_mae_entradasalida b 
											ON a.cod_proveedor = b.cod_proveedor)
								AND a.reversado IN ('0','1')
								AND b.status IN ('01','03','05','11','08')
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
								SELECT 
									{+INDEX (bdisuc:"informix".ss_operaciones idx01ss_operaciones)} 
									{+INDEX (bdisuc:"informix".ss_mae_entradasalida idx01ss_mae_entradasalida)}
									{+INDEX (bdisuc:"informix".ss_proveedores idx_provplaza)}
								a.sucursal,a.fecha_operacion,b.status,a.folio_oper,a.monto, b.cod_proveedor, c.descripcion,
									NVL(a.procedencia,''),b.folio_servicio,a.usuario,a.cod_trans, 1 as pos_reporte
									INTO vSucursal,vFecOpera, vStatus,vFolio,vMonto, vCodProveedor,vnomprov,vProcedencia,vFolioSer, vUsuario, vCodTrans, iPosReporte
									FROM bdisuc:"informix".ss_operaciones a 
									INNER JOIN bdisuc:"informix".ss_mae_entradasalida b ON a.folio_oper = b.folio_oper
									INNER JOIN bdisuc:"informix".ss_proveedores c ON c.cod_proveedor = b.cod_proveedor 
									WHERE a.cod_trans = eCodTrans
									AND a.fecha_operacion >= eFecInicio AND a.fecha_operacion <= eFecFin
									AND a.sucursal IN 
													(SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal2)} sucursal  
														FROM bdinteg:"informix".si_sucursales
														WHERE empresa = eEmpresa
														AND sucursal != '0'
														AND tpo_sucursal = eTipo
														UNION 
														SELECT a.cod_proveedor  	 
														FROM bdisuc:ss_proveedores a
														INNER JOIN bdisuc:"informix".ss_mae_entradasalida b 
														ON a.cod_proveedor = b.cod_proveedor)
									AND a.reversado IN ('0','1')
									AND a.folio_oper = b.folio_oper
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

				--END IF;
		
			END IF;

		ELIF eSucursal <> '0000'  THEN   --** Por Sucursal

			IF eFecInicio = '' OR eFecInicio IS NULL  THEN
				LET eFecInicio= MDY(1,1,2007);
			END IF

			FOREACH
				SELECT 
				{+INDEX (bdisuc:"informix".ss_operaciones idx01ss_operaciones)} 
				{+INDEX (bdisuc:"informix".ss_mae_entradasalida idx01ss_mae_entradasalida)}
				{+INDEX (bdisuc:"informix".ss_proveedores idx_provplaza)}
				{+INDEX (bdinteg:si_sucursales idx_sucursal)}
				
				b.sucursal,a.fecha_operacion,b.status,b.folio_oper,b.monto, b.cod_proveedor, c.descripcion,
					NVL(a.procedencia,''),b.folio_servicio,a.usuario,a.cod_trans
				INTO vSucursal,vFecOpera, vStatus,vFolio,vMonto, vCodProveedor,vnomprov,vProcedencia,vFolioSer,
					vUsuario,vCodTrans
				FROM bdisuc:"informix".ss_operaciones a 
				INNER JOIN bdisuc:"informix".ss_mae_entradasalida b ON a.folio_oper = b.folio_oper
				INNER JOIN bdisuc:"informix".ss_proveedores c ON c.cod_proveedor = b.cod_proveedor 
				WHERE a.cod_trans = eCodTrans
					AND a.fecha_operacion >= eFecInicio AND a.fecha_operacion <= eFecFin
					AND a.sucursal = eSucursal
					AND a.reversado IN ('0','1')
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
				SELECT 
				{+INDEX (bdisuc:"informix".ss_operaciones idx01ss_operaciones)} 
				{+INDEX (bdisuc:"informix".ss_mae_entradasalida idx01ss_mae_entradasalida)}
				{+INDEX (bdisuc:"informix".ss_proveedores idx_provplaza)}
				a.sucursal,a.fecha_operacion,b.status,a.folio_oper,a.monto, b.cod_proveedor, c.descripcion,
					NVL(a.procedencia,''),b.folio_servicio,a.usuario,a.cod_trans
				INTO vSucursal,vFecOpera, vStatus,vFolio,vMonto, vCodProveedor,vnomprov,vProcedencia,vFolioSer,
					vUsuario,vCodTrans
				FROM bdisuc:"informix".ss_operaciones a
				INNER JOIN bdisuc:"informix".ss_mae_entradasalida b ON a.folio_oper = b.folio_oper
				INNER JOIN bdisuc:"informix".ss_proveedores c ON c.cod_proveedor = b.cod_proveedor 
				WHERE a.cod_trans = eCodTrans
					AND b.cod_proveedor = eProveedor
					AND a.fecha_operacion >= eFecInicio AND a.fecha_operacion <= eFecFin
					AND a.sucursal IN (SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal2)} sucursal
										FROM bdinteg:"informix".si_sucursales
										WHERE sucursal != '0'
											AND empresa = eEmpresa
											AND tpo_sucursal = eTipo
										UNION 
										SELECT cod_proveedor
										FROM bdisuc:ss_proveedores
										WHERE cod_proveedor = eProveedor)
					AND a.reversado IN ('0','1')
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
'BD: bdisuc',
'AUTOR: Daniel Reyes Guillen',
'FECHA: 24/11/2022',
'DESCRIPCION: Se colocan indices, se cambia join por sintaxis estandar y se optimiza consulta a si_sucursales y ss_proveedores',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_reportesdosuc()
RETURNING CHAR(6), CHAR(50);
DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(6);
DEFINE cCodRetP CHAR(6);
DEFINE cCadena  CHAR (500);
DEFINE cRuta CHAR (50);
DEFINE cNombreArch CHAR (50);
DEFINE dtFechaHoy			DATE;
DEFINE dtFechaAyer    DATE;
DEFINE cMensajeRetP		CHAR(50);
DEFINE v_fecha DATE;
DEFINE v_sucursal CHAR(4); 
DEFINE v_nombre_suc CHAR(40); 
DEFINE v_denominacion_1 CHAR(18); 
DEFINE v_denominacion_2 CHAR(18); 
DEFINE v_denominacion_3 CHAR(18);
DEFINE v_denominacion_4 CHAR(18);  
DEFINE v_denominacion_5 CHAR(18); 
DEFINE v_denominacion_6 CHAR(18);
DEFINE v_denominacion_7 CHAR(18); 
DEFINE v_cantidad_1 DECIMAL(18,2); 
DEFINE v_cantidad_2 DECIMAL(18,2);
DEFINE v_cantidad_3 DECIMAL(18,2); 
DEFINE v_cantidad_4 DECIMAL(18,2); 
DEFINE v_cantidad_5 DECIMAL(18,2); 
DEFINE v_cantidad_6 DECIMAL(18,2); 
DEFINE v_cantidad_7 DECIMAL(18,2); 
DEFINE v_saldo_total DECIMAL(18,2);


LET iSqlErr = 0;
LET cCodRet = '000001';
LET cCodRetP = '00000';
LET cCadena = '';
LET cRuta = '';
LET cNombreArch = '';
LET dtFechaHoy			= DATE(1);
LET dtFechaAyer		= DATE(1);
LET cMensajeRetP 		= 'PROCESO EXITOSO';

LET v_fecha =DATE(1);
LET v_sucursal =''; 
LET v_nombre_suc =''; 
LET v_denominacion_1  ='';
LET v_denominacion_2  ='';
LET v_denominacion_3  ='';
LET v_denominacion_4  ='';  
LET v_denominacion_5  =''; 
LET v_denominacion_6  ='';
LET v_denominacion_7  ='';
LET v_cantidad_1 =0; 
LET v_cantidad_2 =0;
LET v_cantidad_3 =0;
LET v_cantidad_4 =0;
LET v_cantidad_5 =0;
LET v_cantidad_6 =0;
LET v_cantidad_7 =0;
LET v_saldo_total =0;


BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
		END IF;
		
	END EXCEPTION;
   	
   SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/resplogifx/archivoscontabilidad/sp_reportesdosuc.out';
	--TRACE ON;
 
	--SE OBTIENE LA FECHA HOY Y AYER.
	SELECT fecha_hoy, fecha_ant 
	INTO dtFechaHoy, dtFechaAyer
	FROM bdinteg:"informix".si_fechas WHERE empresa = '001';	
	  
	LET cNombreArch='ss_saldossuc_'||LPAD(DAY(dtFechaAyer),2,0)||LPAD(MONTH(dtFechaAyer),2,0)||YEAR(dtFechaAyer)||'.txt';
    LET cRuta="/resplogifx/archivoscontabilidad/";                                              
	  
	IF NVL(cRuta,'') <> '' THEN
	
		LET cCadena = '';
		TRUNCATE TABLE ss_saldossuc_arqueo;
		
		FOREACH WITH HOLD
			SELECT a.fecha,a.sucursal,b.nombre,a.denominacion_1,a.denominacion_2,a.denominacion_3,a.denominacion_4,a.denominacion_5,a.denominacion_6,a.denominacion_7,a.cantidad_1, a.cantidad_2,a.cantidad_3,a.cantidad_4,a.cantidad_5,a.cantidad_6,a.cantidad_7, a.saldo_total
			INTO v_fecha,v_sucursal, v_nombre_suc, v_denominacion_1, v_denominacion_2, v_denominacion_3, v_denominacion_4, v_denominacion_5, v_denominacion_6,v_denominacion_7, v_cantidad_1, v_cantidad_2, v_cantidad_3, v_cantidad_4, v_cantidad_5, v_cantidad_6, v_cantidad_7, v_saldo_total
			FROM bdisuc:ss_saldossuc a
			LEFT OUTER JOIN bdinteg:si_sucursales b 
			ON (a.empresa = b.empresa and a.sucursal = b.sucursal)
			WHERE a.fecha= dtFechaAyer 
			ORDER BY 1, 2

			LET v_saldo_total = (v_denominacion_1 * v_cantidad_1) + (v_denominacion_2 * v_cantidad_2) + (v_denominacion_3 * v_cantidad_3) + (v_denominacion_4 * v_cantidad_4) + (v_denominacion_5 * v_cantidad_5) + (v_denominacion_6 * v_cantidad_6) + v_cantidad_7;
			
			INSERT INTO ss_saldossuc_arqueo(fecha,sucursal,nombre_sucursal,denominacion_1,denominacion_2,denominacion_3,denominacion_4,denominacion_5,denominacion_6,denominacion_7,cantidad_1,cantidad_2,cantidad_3,cantidad_4,cantidad_5,cantidad_6,cantidad_7,saldo_total)
			VALUES(v_fecha,v_sucursal,v_nombre_suc,v_denominacion_1,v_denominacion_2,v_denominacion_3,v_denominacion_4,v_denominacion_5, v_denominacion_6,'1',v_cantidad_1,v_cantidad_2,v_cantidad_3,v_cantidad_4,v_cantidad_5,v_cantidad_6,v_cantidad_7,NVL(v_saldo_total,'0'));
	
		END FOREACH;
			
		LET cCadena = '/usr/bin/echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || TRIM(cNombreArch)  ||'  delimiter ''|'' SELECT * FROM bdisuc:"informix".ss_saldossuc_arqueo" > '||TRIM(cRuta)||'bit_carga.sql';				
		SYSTEM cCadena;				
		LET cCadena='chmod 777 '||TRIM(cRuta)||'bit_carga.sql';
		System cCadena;		
		let cCadena = 'dbaccess bdisuc '||TRIM(cRuta)||'bit_carga.sql';
		System cCadena;				
		LET cCadena = '' ;
		LET cCadena = 'rm '|| TRIM(cRuta) ||'bit_carga.sql';
		SYSTEM cCadena;	
	END IF;
			
	RETURN cCodRetP, cMensajeRetP;
END
END PROCEDURE
DOCUMENT
'',
'AUTOR : CONCEPCION ALVAREZ CARRILLO',
'FECHA : 24/feb/2019',
'BD    : BDISUC';

CREATE PROCEDURE "informix".sp_consulta_cajageneral(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		CHAR(4) AS cIdProvCaja,
		CHAR(30) AS cDescCaja;

        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cIdProvCaja CHAR(4);
		DEFINE cDescCaja CHAR(30);
        DEFINE cPlazaCaja CHAR(3);
        DEFINE iNoRegistros INTEGER;

        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cIdProvCaja = '';
        LET cDescCaja = '';
        LET cPlazaCaja = '';
        LET iNoRegistros = 0;


        BEGIN

                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cIdProvCaja, cDescCaja;
                END EXCEPTION;

                --SET DEBUG FILE TO '/tmp/mfinis/sp_consulta_cajageneral.out';
                --TRACE ON;

                IF pUsuario = '' OR pIdFuncion = ''  THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, cIdProvCaja, cDescCaja;
                END IF;

                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, cIdProvCaja, cDescCaja;
                END IF;

				SET ISOLATION TO DIRTY READ;
                SET LOCK MODE TO WAIT 3;

                -- COMBOBOX CAJA GENERAL
			FOREACH
                SELECT SKIP pRegistros FIRST pRecuperacion cod_proveedor, descripcion, plaza
                INTO cIdProvCaja, cDescCaja, cPlazaCaja 
                FROM bdisuc:"informix".ss_proveedores ORDER BY UPPER(descripcion)

                LET iNoRegistros = iNoRegistros + 1;
                RETURN cCodret, cIdProvCaja, UPPER(cDescCaja) WITH RESUME;   
			END FOREACH;
			
			IF iNoRegistros = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cIdProvCaja, cDescCaja;
			ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, cIdProvCaja, cDescCaja;
			END IF;

        END;

END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 03/09/2018',
'DESCRIPCION: SPL, que hace la consulta para el llenado del combobox caja general, Aumento Resta de Saldos Caja General',
'AUTOR: ING. JosÃ© Antonio RamÃ­rez Franco',
'FECHA: 06/07/2023',
'DESCRIPCION: MODIFICACIÃN Se le agrego la paginaciÃ³n a la consulta.',
'BD: bdisuc';

CREATE PROCEDURE  "informix".sp_valfcfs_web_pbatrace(pusuario         char(4),
                                  pfecha_sucursal  date)

   RETURNING CHAR(5),
             DATE,
             SMALLINT;

   DEFINE cod_ret           CHAR(5);
   DEFINE sql_err           INTEGER;
   DEFINE vfecha_central    DATE;
   DEFINE vexiste           SMALLINT; 

-- *****************************************************************
-- Inicializa variables
-- *****************************************************************
   LET cod_ret           = "00000";
   LET vfecha_central    = "";

      SET DEBUG FILE TO "/DBA/INC/20240518/RESPALDO/bdisuc.sp_valfcfs_web.240518_trace.out";
      TRACE ON;


BEGIN
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         LET cod_ret = sql_err;
         RETURN cod_ret,vfecha_central,vexiste;
      END IF;
   END EXCEPTION;

-- *****************************************************************
-- Valida los parametros de entrada
-- *****************************************************************
      IF pfecha_sucursal is null THEN 
         LET cod_ret = "00110";
         RETURN cod_ret,vfecha_central,vexiste;
      END IF
      
-- *****************************************************************
-- Valida la sucursal asignada,como el usuario del Pase Contable
-- *****************************************************************
   
   SELECT fecha_hoy 
   INTO vfecha_central
   FROM bdicont:co_fechas;
   
   IF EXISTS(SELECT usuario FROM bdicont:co_poldet_20240518 WHERE usuario = pusuario AND  
                     fecha_captura = pfecha_sucursal AND fecha_valida = vfecha_central) THEN
      LET vexiste = 0;
   ELSE
      LET vexiste = 1;
   END IF;
  

   IF not vfecha_central > pfecha_sucursal THEN
      --RETURN cod_ret,vfecha_central,vexiste;
   --ELSE
      LET vfecha_central = pfecha_sucursal;
   END IF;
    
    RETURN cod_ret,vfecha_central,vexiste;
END
END PROCEDURE;