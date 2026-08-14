CREATE PROCEDURE "informix".sp_monitor_operaciones(eEmpresa      CHAR(3),
                                                  eTipo         CHAR(1), --**C = ATM , S = Sucursal
                                                  eSucursal     CHAR(4),
                                                  eCodTrans     CHAR(4),  --Operacion
                                                  eFecInicio    DATE,
                                                  eFecFin       DATE,
												  eProveedor    CHAR(4)) 
							
 
RETURNING CHAR(5),        --** Error vCodRet    	vcodret                            
          CHAR(50),       --** Nombre Sucursal  	vSucursal|| ' '||vNomSuc           
          DATE   ,        --** Fec. Operacion		vFecOpera                          
          CHAR(50),       --** Desc. Status			vDesStatus		                   
          CHAR(16),       --** Folio				vFolio                             
          DECIMAL(14,2),  --** Monto				vMonto                             
          CHAR(50),       --** CodTrans				vDesCodTra                         
          CHaR(4),        --** Cod Proveedor		vCodProveedor                      
          CHAR(50),       --** Procedencia			vProcedencia  || ' '|| vDesProv    
          CHAR(16),       --** folio Servicio		vFolioSer                          
          CHAR(40),       --** Usuario				vUsuario || ' ' || vNomUsuSol      
          CHAR(4),        --** Status				vStatus                            
		  CHAR(6),		  --** Id ATM				vIdatm
		  INTEGER,	      --Biellete 1000
		  INTEGER,		  --Biellete 500
		  INTEGER,		  --Biellete 200
		  INTEGER,		  --Biellete 100
		  INTEGER,		  --Biellete 50
		  INTEGER,		  --Biellete 20
		  INTEGER,		  --Biellete 10
		  INTEGER,		  --Biellete 5
		  INTEGER,		  --Biellete 2
		  INTEGER,		  --Biellete 1
		  INTEGER,		  --Biellete .50  
		  CHAR(40),		  --Nombre de codigo proveedor
		  INTEGER ,		  --Posicion en reporte
		  money (18,2),  -- sdo caja 
		  CHAR(4);		 --CC ATM
		 
	  
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
DEFINE vIdatm		 CHAR(15);
DEFINE v1000		INTEGER;
DEFINE v500			INTEGER;
DEFINE v200 		INTEGER;
DEFINE v100 		INTEGER;
DEFINE v50 			INTEGER;
DEFINE v20			INTEGER;
DEFINE v10			INTEGER;
DEFINE v5			INTEGER;
DEFINE v2			INTEGER;
DEFINE v1			INTEGER;
DEFINE vm50			INTEGER;
DEFINE vnomprov     CHAR(40);   
DEFINE sdo_caja     money (18,2);
DEFINE vcc_atm		CHAR(4);


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
LET vIdatm		  = '';
lET v1000		  = 0 ;
lET v500		  = 0 ;
lET v200		  = 0 ;
lET v100		  = 0 ;
lET v50		 	  = 0 ;
lET v20			  = 0 ;
lET v10			  = 0 ;
lET v5			  = 0 ;
lET v2			  = 0 ;
lET v1			  = 0 ;
lET vm50		  = 0 ;  
LET vnomprov	  = 0 ; 
LET sdo_caja	  = 0 ; 
LET vcc_atm 	  = '';
 
--SET debug file  to "monitor_isa.out";
--trace on;
 --SET DEBUG FILE TO "/tmp/monitor.out";
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
				SELECT b.sucursal,a.fecha_operacion,b.status,b.folio_oper,b.monto, b.cod_proveedor,
				NVL(a.procedencia,''),b.folio_servicio,a.usuario,a.cod_trans
				INTO vSucursal,vFecOpera, vStatus,vFolio,vMonto, vCodProveedor,vProcedencia,vFolioSer,
				vUsuario,vCodTrans
				FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b
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
				ORDER BY a.fecha_operacion ASC     
				
				SELECT 	descripcion	INTO vnomprov  FROM bdisuc:"informix".ss_proveedores WHERE cod_proveedor =vCodProveedor;
				
				SELECT nombre INTO vNomSuc FROM bdinteg:"informix".si_sucursales WHERE sucursal = vSucursal;

				SELECT descripcion INTO vDesStatus FROM bdisuc:"informix".ss_catstatus WHERE status = vStatus;

				SELECT nombre INTO vNomUsuSol   FROM bdinteg:"informix".si_ejecut     WHERE ejecutivo = vUsuario;

				SELECT TRIM(descripcion) INTO vDesCodTra FROM bdisuc:"informix".ss_param_cajagen WHERE codigo = vCodTrans;

				SELECT TRIM(descripcion) INTO vDesProv FROM bdisuc:"informix".ss_cat_proveedor WHERE codigo= vProcedencia;
				
				RETURN vcodret, vSucursal|| ' '||vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
				vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,'',0,0,0,0,0,0,0,0,0,0,0,vnomprov,1,0, '' WITH RESUME; 
	
		END FOREACH;   
ELIF eProveedor = '0000' THEN

        IF eFecInicio = '' OR eFecInicio IS NULL  THEN
			LET eFecInicio= MDY(1,1,2007);
		END IF;
		
		IF eCodTrans in ('0001','0002','0036','0041') THEN
		
					create temp table tmprpt(
					codret      				 	 CHAR(5),       
					Sucursal                         CHAR(50),     
					FecOpera                         DATE   ,      
					DesStatus	                     CHAR(50),     
					Folio                            CHAR(16),     
					Monto                            DECIMAL(14,2),
					DesCodTra                        CHAR(50),     
					CodProveedor                     CHaR(4),      
					Procedencia                      CHAR(50),     
					FolioSer                         CHAR(16),     
					Usuario                          CHAR(40),     
					Status                           CHAR(4),      
					Idatm           		         CHAR(6),		
					B1000           		 INTEGER,	    
					B500           		     INTEGER,		
					B200           		     INTEGER,		
					B100           		     INTEGER,		
					B50           		     INTEGER,		
					B20           		     INTEGER,		
					B10           		     INTEGER,		
					B5           		     INTEGER,		
					B2           		     INTEGER,		
					B1           		     INTEGER,		
					Bp50             		 INTEGER,		
					Nombre_proveedor         CHAR(40),
					posicion				 integer
					);	
		if eCodTrans ='0001' THEN
		FOREACH 
		
				SELECT a.sucursal,a.fecha_operacion,b.status,a.folio_oper,a.monto, b.cod_proveedor,
				NVL(a.procedencia,''),b.folio_servicio,a.usuario,a.cod_trans, c.descripcion
				INTO vSucursal,vFecOpera, vStatus,vFolio,vMonto, vCodProveedor,vProcedencia,vFolioSer, vUsuario,vCodTrans,vnomprov
				FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores c
				WHERE a.cod_trans = eCodTrans
				AND b.status IN('01','03','04','11') 
				AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin
				AND( a.sucursal IN (SELECT sucursal
                    FROM bdinteg:"informix".si_sucursales
                    WHERE sucursal != '0'
                    AND empresa = eEmpresa
                    AND tpo_sucursal = eTipo)
				    OR a.sucursal = c.cod_proveedor)
				AND b.cod_proveedor = c.cod_proveedor
				AND a.reversado IN ('0','1')
				AND a.folio_oper = b.folio_oper
				ORDER BY a.fecha_operacion, c.descripcion ASC	
				
				SELECT nombre INTO vNomSuc FROM bdinteg:"informix".si_sucursales WHERE sucursal = vSucursal;                          

				SELECT descripcion INTO vDesStatus FROM bdisuc:"informix".ss_catstatus WHERE status = vStatus;

				SELECT nombre INTO vNomUsuSol   FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = vUsuario;

				SELECT TRIM(descripcion) INTO vDesCodTra FROM bdisuc:"informix".ss_param_cajagen WHERE codigo = vCodTrans;

				SELECT TRIM(descripcion) INTO vDesProv FROM bdisuc:"informix".ss_cat_proveedor WHERE codigo= vProcedencia;
				
				SELECT id INTO vIdatm FROM  bdisuc:"informix".ss_relacionccid WHERE cc = vSucursal;

				SELECT cantidad_1, cantidad_2 ,cantidad_3,cantidad_4,cantidad_5,cantidad_6, cantidad_7, cantidad_8, cantidad_9,cantidad_10,cantidad_11
				INTO v1000,v500,v200,v100,v50,v20,v10,v5,v2,v1,vm50
				from bdisuc:"informix".ss_operaciones where folio_oper = vFolio;
				
				SELECT cc  INTO vcc_atm FROM  bdisuc:"informix".ss_relacionccid WHERE cc = vSucursal;
				
				insert INTO tmprpt (codret,Sucursal,FecOpera, DesStatus, Folio, Monto, DesCodTra, CodProveedor, Procedencia, FolioSer, Usuario,
									Status, Idatm, B1000, B500, B200, B100, B50, B20, B10, B5, B2, B1, Bp50, Nombre_proveedor,posicion )
							VALUES  (		
				vcodret, vSucursal|| ' '||vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
				vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,vIdatm,v1000,v500,v200,v100,v50,v20,v10,v5,v2,v1,vm50,vnomprov,1);
				
				RETURN vcodret, vSucursal|| ' '||vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
				vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,vIdatm,v1000,v500,v200,v100,v50,v20,v10,v5,v2,v1,vm50,vnomprov,1,0,vcc_atm WITH RESUME;
				

		 END FOREACH;
				
		else
		
		FOREACH 
					
				SELECT a.sucursal,a.fecha_operacion,b.status,a.folio_oper,a.monto, b.cod_proveedor,
				NVL(a.procedencia,''),b.folio_servicio,a.usuario,a.cod_trans, c.descripcion
				INTO vSucursal,vFecOpera, vStatus,vFolio,vMonto, vCodProveedor,vProcedencia,vFolioSer, vUsuario,vCodTrans,vnomprov
				FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b,bdisuc:"informix".ss_proveedores c
				WHERE a.cod_trans = eCodTrans
				AND b.status!='08'
				AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin
				AND( a.sucursal IN (SELECT sucursal
                    FROM bdinteg:"informix".si_sucursales
                    WHERE sucursal != '0'
                    AND empresa = eEmpresa
                    AND tpo_sucursal = eTipo)
				    OR a.sucursal = c.cod_proveedor)
				AND b.cod_proveedor = c.cod_proveedor
				AND a.reversado IN ('0','1')
				AND a.folio_oper = b.folio_oper
				ORDER BY a.fecha_operacion, c.descripcion ASC	
				
				SELECT nombre INTO vNomSuc FROM bdinteg:"informix".si_sucursales WHERE sucursal = vSucursal;                          

				SELECT descripcion INTO vDesStatus FROM bdisuc:"informix".ss_catstatus WHERE status = vStatus;

				SELECT nombre INTO vNomUsuSol   FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = vUsuario;

				SELECT TRIM(descripcion) INTO vDesCodTra FROM bdisuc:"informix".ss_param_cajagen WHERE codigo = vCodTrans;

				SELECT TRIM(descripcion) INTO vDesProv FROM bdisuc:"informix".ss_cat_proveedor WHERE codigo= vProcedencia;
				
				SELECT id INTO vIdatm FROM  bdisuc:"informix".ss_relacionccid WHERE cc = vSucursal;

				SELECT cantidad_1, cantidad_2 ,cantidad_3,cantidad_4,cantidad_5,cantidad_6, cantidad_7, cantidad_8, cantidad_9,cantidad_10,cantidad_11
				INTO v1000,v500,v200,v100,v50,v20,v10,v5,v2,v1,vm50
				from bdisuc:"informix".ss_operaciones where folio_oper = vFolio;
				
				SELECT cc  INTO vcc_atm FROM  bdisuc:"informix".ss_relacionccid WHERE cc = vSucursal;
				
				insert INTO tmprpt (codret,Sucursal,FecOpera, DesStatus, Folio, Monto, DesCodTra, CodProveedor, Procedencia, FolioSer, Usuario,
									Status, Idatm, B1000, B500, B200, B100, B50, B20, B10, B5, B2, B1, Bp50, Nombre_proveedor,posicion )
							VALUES  (		
				vcodret, vSucursal|| ' '||vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
				vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,vIdatm,v1000,v500,v200,v100,v50,v20,v10,v5,v2,v1,vm50,vnomprov,1);
				
				RETURN vcodret, vSucursal|| ' '||vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
				vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,vIdatm,v1000,v500,v200,v100,v50,v20,v10,v5,v2,v1,vm50,vnomprov,1,0,vcc_atm WITH RESUME;
				

		 END FOREACH;
		 end if;
		 
			 FOREACH
				SELECT FecOpera, CodProveedor ,Nombre_proveedor,   sum (monto) 
				INTO   vFecOpera, vCodProveedor, vnomprov, vmonto
				from tmprpt GROUP BY 1,2,3
				
				SELECT saldo_total INTO sdo_caja from bdisuc:ss_cajageneral  WHERE cod_proveedor = vCodProveedor;
				
				RETURN vcodret, "", vFecOpera, "", "", vMonto,"" ,vCodProveedor,"", 
				"", "", "","",0,0,0,0,0,0,0,0,0,0,0,vnomprov,2,sdo_caja, vcc_atm WITH RESUME;
				
			 
			 END FOREACH;	
			 
			 drop TABLE tmprpt;
	END IF;
		

ELIF eSucursal <> '0000'  THEN   --** Por Sucursal

		IF eFecInicio = '' OR eFecInicio IS NULL  THEN
			LET eFecInicio= MDY(1,1,2007);
		END IF

        FOREACH
			SELECT b.sucursal,a.fecha_operacion,b.status,b.folio_oper,b.monto, b.cod_proveedor,
			NVL(a.procedencia,''),b.folio_servicio,a.usuario,a.cod_trans
			INTO vSucursal,vFecOpera, vStatus,vFolio,vMonto, vCodProveedor,vProcedencia,vFolioSer,
			vUsuario,vCodTrans
			FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b
			WHERE a.cod_trans = eCodTrans
			AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin
			AND a.sucursal = eSucursal
			AND a.reversado IN ('0','1')
			AND a.folio_oper    = b.folio_oper
			ORDER BY a.fecha_operacion ASC
			
			SELECT 	descripcion	INTO vnomprov  FROM bdisuc:"informix".ss_proveedores WHERE cod_proveedor =vCodProveedor;
			
			SELECT nombre INTO vNomSuc FROM bdinteg:"informix".si_sucursales WHERE sucursal = vSucursal;

			SELECT descripcion INTO vDesStatus FROM bdisuc:"informix".ss_catstatus WHERE status = vStatus;

			SELECT nombre INTO vNomUsuSol   FROM bdinteg:"informix".si_ejecut     WHERE ejecutivo = vUsuario;

			SELECT TRIM(descripcion) INTO vDesCodTra FROM bdisuc:"informix".ss_param_cajagen WHERE codigo = vCodTrans;

			SELECT TRIM(descripcion) INTO vDesProv FROM bdisuc:"informix".ss_cat_proveedor WHERE codigo= vProcedencia;

				
				RETURN vcodret, vSucursal|| ' '||vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
				vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,'',0,0,0,0,0,0,0,0,0,0,0,vnomprov,1,0,'' WITH RESUME;
				
        END FOREACH;
			
			

ELSE

        FOREACH
				SELECT a.sucursal,a.fecha_operacion,b.status,a.folio_oper,a.monto, b.cod_proveedor,
				NVL(a.procedencia,''),b.folio_servicio,a.usuario,a.cod_trans
				INTO vSucursal,vFecOpera, vStatus,vFolio,vMonto, vCodProveedor,vProcedencia,vFolioSer,
				vUsuario,vCodTrans
				FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b
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
				ORDER BY a.fecha_operacion ASC
				
			  SELECT 	descripcion	INTO vnomprov  FROM bdisuc:"informix".ss_proveedores WHERE cod_proveedor =vCodProveedor;
			  
              SELECT nombre INTO vNomSuc FROM bdinteg:"informix".si_sucursales WHERE sucursal = vSucursal;

              SELECT descripcion INTO vDesStatus FROM bdisuc:"informix".ss_catstatus WHERE status = vStatus;

              SELECT nombre INTO vNomUsuSol   FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = vUsuario;

              SELECT TRIM(descripcion) INTO vDesCodTra FROM bdisuc:"informix".ss_param_cajagen WHERE codigo = vCodTrans;

              SELECT TRIM(descripcion) INTO vDesProv FROM bdisuc:"informix".ss_cat_proveedor WHERE codigo= vProcedencia;
					
					RETURN vcodret, vSucursal|| ' '||vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
				vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,'',0,0,0,0,0,0,0,0,0,0,0,vnomprov,1,0,'' WITH RESUME;
				
        END FOREACH;

END IF;
	
END PROCEDURE;