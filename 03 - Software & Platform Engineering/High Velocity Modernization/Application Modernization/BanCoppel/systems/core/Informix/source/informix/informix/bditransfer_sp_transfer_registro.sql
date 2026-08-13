create procedure "informix".sp_transfer_registro (
					psfolio_suc             char(15),
					pscve_usuario 			char(10),
					pstransacc				char (4),
					psid_banco_origen       char (3),
					pstpo_id_origen         char (2),
					psid_cuenta_origen      char (20),
					psid_banco_destino      char (3),
					pstpo_id_destino		char(2),
					psid_cuenta_destino     char(20), 
					pmmonto       			money
					)
returning 	
				varchar (5) as codret;
--Variable sgenerales de error
define visqlerr integer ;
define vscodret varchar(5);
define vsmensaje_respuesta varchar(250);
define vstransaccion char(4);
define vstransaccion2 char(4);
define vsdescripcion char(50);
define vsdescripcion2 char(50);
define vscuenta char(20);
define vscuenta1 char(20);
define vscuenta2 char(20);
define vspsid_cuenta_origen char(18);
define vspsid_cuenta_destino char(18);
define vnum_tarjeta varchar(16); 
define vnumcuenta   char(20);   
define vEsRetiroVtanilla char(1);
define vPagoTDC  char(1);
define vcreditodebito char(1);
--define verr_trace varchar(5); 
define vcod_ret             char(5);
define vcuenta              char(20);
define vedo_cta             char(1);
define vsdo_cta             money(14,2);
define vsdo_ret             money(14,2);
define vsdo_cong            money(14,2);
define vsdo_ccc             money(14,2);
define vimp_chq_sbc         money(14,2);
define vtipo_linea          char(1);
define vsdo_disp            money(14,2);
define vnum_cte             char(20);
define vsdo_disp_ccc        money(14,2);
define vsdo_t1              money(14,2);
define vapell_pat           char(26);
define vapell_mat           char(26);
define vnombre1             char(26);
define vnombre2             char(26);
define vrazon_soc           char(60);
define vdescrip1            char(40);
define vdescrip2            char(40);
define vfecbloq             date;
define vusubloq             char(8);
define vcta_clabe           char(18);

begin
	on exception set visqlerr
		let vscodret = '00001';
		return 	vsCodRet;
				--('[' || vscodret ||  '] Error no controlado ' || visqlerr || ' ' || trim(vsmensaje_respuesta);
	end exception;
	on exception in (-535)
			commit work; --termina la transaccion actual y continua
	end exception with resume;
	on exception in (-255)
			begin work; --termina la transaccion actual y continua
	end exception with resume;	
--set debug file to "/informix/HomeInformix/mgap/sp_transfer_registro.out";
--trace on;	
-- Inicializando variables de error
let visqlerr  = 0;
let vscodret  = '00000';
let vsmensaje_respuesta = 'Iniciando proceso de registro contable en SC_MOVDIA Transfer puro';		
-- Variables de proceso 
let vstransaccion = '';
let vsdescripcion = '';
let vstransaccion2 = '';
let vsdescripcion2 = '';
let vscuenta = '';
let vscuenta1 = '';
let vscuenta2 = '';
let vspsid_cuenta_origen =  '';
let vspsid_cuenta_destino = '';
let vspsid_cuenta_origen = psid_cuenta_origen;
let vspsid_cuenta_destino = psid_cuenta_destino;
let vnum_tarjeta = ''; 
let vnumcuenta   = ''; 
let vEsRetiroVtanilla = '0'; --  VTA 
let vPagoTDC  = '0';
let vcreditodebito = '';
--let verr_trace  = '00000'; 
let vcod_ret   = "000";
let vcuenta    = "";
let vnum_cte   = "";
let vapell_pat = " ";
let vapell_mat = " ";
let vnombre1   = " ";
let vnombre2   = " ";
let vrazon_soc = " ";
let vedo_cta   = "";
let vsdo_disp  = 0 ;
let vsdo_ret   = 0 ;
let vsdo_ccc   = 0 ;
let vsdo_disp_ccc = 0 ;
let vsdo_cta   = 0 ;
let vtipo_linea = " ";
let vdescrip1 = "";
let vdescrip2 = "";
let vsdo_t1 =  0 ;
let vsdo_cong  = 0 ;
let vimp_chq_sbc = 0;
let vfecbloq = "";
let vusubloq = " ";
let vcta_clabe = "";
------------------------------------------------------------------------------------------------------------------------------------------
-- Valida integridad en datos complementarios: 
-----------------------------------------------------------------------------------------------------------------------------
		IF (( psfolio_suc is null or psfolio_suc = '' ) OR  ( pscve_usuario  is null or pscve_usuario  = '' ) )  then
				let vscodret = '00001';
              return 	vscodret;
        END IF;
			
		IF (( pstransacc <> '0014' ) AND  (pmmonto is null  or pmmonto  <= 0 ))  then
				let vscodret = '00001';
              return 	vscodret;
        END IF;
-- ###################  VALIDAR CUENTAS PARA PROCESO DE SPEWITAS, PAGO AL COMERCIANTE Y RETIROS ANÓNIMOS ############################################
IF  (pstransacc in ('0005','0042'))  THEN
    IF  (psid_banco_origen = '137' and psid_banco_destino = '137') THEN 
        IF (pstpo_id_origen = '01' )  THEN 
            Execute procedure bditransfer:"informix".sp_transfer_valida_cta (pstpo_id_origen,vspsid_cuenta_origen) ----RETORNA CTA CARGO
				INTO vscodret,vscuenta;
            LET vscuenta1 = vscuenta;
           	IF vscodret <> '00000' then
					let vscodret = '00001';
 			    return 	vscodret;	
			END IF;	
		    Execute procedure bditransfer:"informix".sp_transfer_valida_cta (pstpo_id_destino,vspsid_cuenta_destino) ----CTA ABONO
				INTO vscodret,vscuenta;
            LET vscuenta2 = vscuenta;
			-------------------------------------------
			IF  (pstransacc = '0042')  THEN  -- En linea 312 retornará error en caso de que cuenta abono no sea exitosa.
			  ELSE 
			       --- RQM 06-449-2 RETIRO CON FOLIO EN VENTANILLA TRANSFER:
			       IF (vscodret <> '00000') THEN
			        LET vEsRetiroVtanilla = '1';
			       END IF;
			      --- RQM 06-449-2
			END IF; 	  
		ELSE 	
		    Execute procedure bditransfer:"informix".sp_transfer_valida_cta (pstpo_id_origen,vspsid_cuenta_origen) ----CTA CARGO
				INTO vscodret,vscuenta;
            LET vscuenta1 = vscuenta;
           
		END IF; 
	ELIF (psid_banco_origen = '137' and psid_banco_destino IN ( '036', '002')) THEN
        Execute procedure bditransfer:"informix".sp_transfer_valida_cta (pstpo_id_origen,vspsid_cuenta_origen) ----RETORNA CTA CARGO
			INTO vscodret,vscuenta;
        LET vscuenta1 = vscuenta;
    ELIF (psid_banco_destino = '137' and psid_banco_origen IN ( '036', '002'))  THEN
        Execute procedure bditransfer:"informix".sp_transfer_valida_cta (pstpo_id_destino,vspsid_cuenta_destino) ----CTA ABONO
            INTO vscodret,vscuenta;
        LET vscuenta2 = vscuenta;
    END IF;     

--	###################  VALIDAR CUENTAS PARA PROCESO DE FONDEO, ABONO POR CANCELACION DE FOLIO VENTANILLA  ############################################
ELIF  ( pstransacc in ('0004','0036') ) THEN  --- RQM 06-449-2  se añade TXN 0036 -- Cancelación retiro con folio en ventanilla. 
	IF (pstransacc = '0036')  THEN -- valida la 0036 
		IF  (psid_banco_origen = '137' and psid_banco_destino = '137') AND  (pstpo_id_origen  = '01'  AND  pstpo_id_destino  ='01')  THEN 
			Execute procedure bditransfer:"informix".sp_transfer_valida_cta (pstpo_id_origen,vspsid_cuenta_origen) 
				INTO vscodret,vscuenta;
		    IF vscodret = '00000' then  -- Debe ser null , es decir no encontrar su cta. origen, solo la destino. 
				let vscodret = '00001';
 			    return 	vscodret;	
			END IF;	
		ELSE 	
			let vscodret = '00001'; -- Bancos y destinos invalidos para la txn 0036 
				return 	vscodret;
	    END IF; 
    END IF; 			
	Execute procedure bditransfer:"informix".sp_transfer_valida_cta (pstpo_id_destino,vspsid_cuenta_destino) ----CTA ABONO
			INTO vscodret,vscuenta;
		LET vscuenta2 = vscuenta;

--	###################  VALIDAR CUENTAS PARA CARGO A CTA TRANSFER ABONO CTA BANCOPPEL   ############################################	
ELIF  (pstransacc in ('0031','0032') ) THEN		---***** Se añaden validación a las cuentas destino correspondientes 
 
  IF (pstransacc = '0031') THEN 
	IF  (psid_banco_origen = '137' /*and psid_banco_destino = '000'*/) AND  (pstpo_id_origen   IN ('01','02','03','04')  AND  pstpo_id_destino  IN ('01','02','03','04'))  THEN 
		Execute procedure bditransfer:"informix".sp_transfer_valida_cta (pstpo_id_origen,vspsid_cuenta_origen) ---- Valida la cta. Origen. 
			INTO vscodret,vscuenta;
        LET vscuenta1 = vscuenta;  
		IF vscodret <> '00000' then
		        --LET verr_trace = '04006';
				let vscodret = '00001';
			return 	vscodret;	
		END IF;			
	ELSE   
	     LET vscodret = '001'; 
         -- LET verr_trace = '04007';		 
	     RETURN 	vscodret;	 --- Cta.Txn invalida 		
		 
	END IF;
	
   ELSE  -- 0032
	
	    IF  (psid_banco_destino = '137'  AND pstpo_id_destino  IN ('01','02','03','04'))  THEN 
		    ELSE 
			let vscodret = '00001';
			--LET verr_trace = '04008';
			return 	vscodret;	
		END IF;	
	
  END IF;
	
		IF  (pstpo_id_destino = '01')  THEN  -- Valida que el telefono destino sea transfer para proceder registro. 
			Execute procedure bditransfer:"informix".sp_transfer_valida_cta ('01',vspsid_cuenta_destino) 
				INTO vscodret,vscuenta;
		ELIF (pstpo_id_destino = '02')  THEN  -- Valida la Cta. Clabe sea valida para proceder registro. 
			IF  (vspsid_cuenta_destino <> '000000000000000000' and vspsid_cuenta_destino is not null and vspsid_cuenta_destino <> '')  THEN    
				LET  vspsid_cuenta_destino =  substr(TRIM(vspsid_cuenta_destino),-18);   --137900800000008026  -- Clabe Transfer 
				IF substr(vspsid_cuenta_destino,1,3) = '137' THEN  --137XXXXXXXXXXXXXXX  -- Clabe Transfer 
					IF SUBSTR(vspsid_cuenta_destino,7,1) = '8' THEN    -- XXXXXX8XXXXXXXXXXX
						Execute procedure bditransfer:"informix".sp_transfer_valida_cta ('02',vspsid_cuenta_destino) 
							INTO vscodret,vscuenta;
					ELSE    -- 137180130016937804  -- 13001693780
						LET vspsid_cuenta_destino = SUBSTR(vspsid_cuenta_destino,7,11); -- 13001693780
						execute procedure bdicheq:"informix".cons_sdos1("001",vspsid_cuenta_destino,"0000000000000000")
							INTO  vcod_ret,vcuenta,vnum_cte,vapell_pat,vapell_mat,vnombre1,vnombre2,vrazon_soc,vedo_cta,vsdo_disp,
                                  vsdo_ret,vsdo_ccc,vsdo_disp_ccc,vsdo_cta,vtipo_linea,vdescrip1,vdescrip2,vsdo_t1 ,vsdo_cong,vimp_chq_sbc,
                                  vusubloq,vfecbloq,vnum_tarjeta,vcta_clabe; 
	                    IF (vcod_ret = '000' AND  vedo_cta = '1' )  THEN    
							LET vscodret = '00000';
						ELSE 
							LET vscodret = '001';
						END IF; 	
					END IF; 							
				ELSE 
					LET vscodret = '001'; -- Clabe no pertenece a Bancoppel  
				END IF;
			ELSE
				LET vscodret = '001'; -- Destino invalido 			   
			END IF; 			
		ELIF (pstpo_id_destino = '03')  THEN  -- Valida la Tarjeta sea valida para proceder registro.  
		
		    IF (vspsid_cuenta_destino <> '000000000000000000' and vspsid_cuenta_destino is not null and vspsid_cuenta_destino <> '')  THEN
		   
					--Obtiene BIN de la tarjeta y retorne el Producto (C/D) 						
					set isolation to dirty read;
					Select limit 1 creditodebito into vcreditodebito from intercard:"informix".bines where SUBSTR(TRIM(vspsid_cuenta_destino),3,6) = bin;
				
					IF (TRIM(vcreditodebito) in ('D','C')) THEN 
							
									set isolation to dirty read;
									SELECT {+INDEX(intercard:tarjetacuenta numtarjeta} numcuenta INTO vnumcuenta FROM  intercard:"informix".tarjetacuenta as cta 
									WHERE  cta.numtarjeta = substr(TRIM(vspsid_cuenta_destino),-16);
							
									IF (vnumcuenta IS not null AND vnumcuenta <> '' )  THEN  
									
										IF (TRIM(vcreditodebito) = 'D') then    -- DÉBITO 
																						
														execute procedure bdicheq:"informix".cons_sdos1("001",vnumcuenta,"0000000000000000")
														INTO  vcod_ret,vcuenta,vnum_cte,vapell_pat,vapell_mat,vnombre1,vnombre2,vrazon_soc,vedo_cta,vsdo_disp,
														vsdo_ret,vsdo_ccc,vsdo_disp_ccc,vsdo_cta,vtipo_linea,vdescrip1,vdescrip2,vsdo_t1 ,vsdo_cong,vimp_chq_sbc,
														vusubloq,vfecbloq,vnum_tarjeta,vcta_clabe; 
														
														IF  (vcod_ret = '000' AND  vedo_cta = '1')  THEN 
															 LET vscodret = '00000';
														  ELSE 
														    --LET verr_trace = '04005';
															LET vscodret = '001'; -- Cta. de Débito no encontrado en Captación.
														END IF; 														
						
										 ELIF  (TRIM(vcreditodebito) = 'C') then  -- CRÉDITO 
													
														IF  (pstransacc = '0031')  THEN  
															 LET vscodret = '00000'; 
															 LET vPagoTDC = '1'; -- FLAG Es TDC Bancoppel 									  
														  ELSE  
														    --LET verr_trace = '04004';
															LET vscodret = '001'; -- TXN 0032 no puede procesar crédito. 
														END IF;   
										END IF;	
								
									 ELSE 

										  --LET verr_trace = '04003';
										  LET vscodret = '001';  --- Cuenta Bancoppel NO fue encontrada. 
								
									END IF;										   
			          ELSE 
									IF  (pstransacc = '0031')  THEN  
									        
											let vcreditodebito = ''; 
									        set isolation to dirty read;
											Select limit 1 creditodebito into vcreditodebito FROM bdicheq:"informix".sc_bines where bin =  SUBSTR(TRIM(vspsid_cuenta_destino),3,6);
																
                                                if vcreditodebito = 'c' then
																
											        LET vscodret = '00000'; 
												    LET vPagoTDC = '2';  --- FLAG Es TDC de OTROS Bancos.                                        										                                       															     
                                                
												 else   LET vscodret = '001'; -- Bin de "otro banco" no es de Crédito.
												
                                                end if; 												
												 
										ELSE  	  
										         --LET verr_trace = '04002';
												 LET vscodret = '001';  --- Bin no es BCOPPEL para txn '0032' 												
						            END IF;							
				    END IF; 	 						
			 ELSE 
			        --LET verr_trace = '04001';
				    LET vscodret = '001';    --- formato del destino invalido. 					
            END IF; 	
			
		ELIF (pstpo_id_destino = '04')  THEN  -- Valida la Cta. Transfer sea valida para proceder registro. 
			IF  (vspsid_cuenta_destino <> '000000000000000000'  and vspsid_cuenta_destino IS not null AND vspsid_cuenta_destino <> '')  THEN   
				IF  SUBSTR(substr(TRIM(vspsid_cuenta_destino),-11),1,1) = '8'   THEN 
					Execute procedure bditransfer:"informix".sp_transfer_valida_cta ('04',vspsid_cuenta_destino) --000000080001133059
						INTO vscodret,vscuenta;
				ELSE 
					LET vspsid_cuenta_destino =  SUBSTR(vspsid_cuenta_destino,-11);
					execute procedure bdicheq:"informix".cons_sdos1("001",vspsid_cuenta_destino,"0000000000000000")
						INTO  vcod_ret,vcuenta,vnum_cte,vapell_pat,vapell_mat,vnombre1,vnombre2,vrazon_soc,vedo_cta,vsdo_disp,
							  vsdo_ret,vsdo_ccc,vsdo_disp_ccc,vsdo_cta,vtipo_linea,vdescrip1,vdescrip2,vsdo_t1 ,vsdo_cong,vimp_chq_sbc,
							  vusubloq,vfecbloq,vnum_tarjeta,vcta_clabe; 
					IF (vcod_ret = '000' AND  vedo_cta = '1')  THEN 
						LET vscodret = '00000';
					ELSE 
						LET vscodret = '001';
					END IF; 	
				END IF; 
			ELSE   
				LET vscodret = '001';  --- Cta. Transfer Invalida.
			END IF; 
		ELSE 	 
			LET vscodret = '001';  --- Destino invalido.
		END IF;

ELIF  pstransacc = '0057'  THEN  -- Devolución pagos de servicios
           
		Execute procedure bditransfer:"informix".sp_transfer_valida_cta (pstpo_id_destino,vspsid_cuenta_destino)   
	    INTO vscodret,vscuenta;
		
		LET vscuenta2 = vscuenta;		
--	###################  VALIDAR CUENTAS CON COMPRA DE TIEMPO AIRE, AJUSTE DE SALDOS y PAGO DE SERVICIOS   ############################################	
ELSE     ---  0034, 0014 , '0094', '0095', '0096', '0080', '0081', 	'0082', '0083', '0084', '0085', '0086', '0087','0088', '0089', '0090', '0091', '0092'         
		 ---  0103, 0104 , '0110','0111', '0112', '0113','0114','0115','0118','0119','0120','0121','0122','0123','0124','0125','0093' '0106' '0107' '0108', #NEW '0126','0132','0133','0134','0135'
		 
     Execute procedure bditransfer:"informix".sp_transfer_valida_cta (pstpo_id_origen,vspsid_cuenta_origen) ----RETORNA CTA CARGO
        INTO vscodret,vscuenta;
           
             LET vscuenta1 = vscuenta;    
END IF; 
	
IF vEsRetiroVtanilla = '1' THEN  -- VTA 		
ELSE
	IF vscodret <> '00000' then   --- Valida el codigo exitoso a las transacciones ptes, de no cumplir termina el proceso. 
		let vscodret = '00001';
 		return 	vscodret;	
	END IF;	
END IF;   
------------------------------------------------------------------------------------------------------------------------------------------ 
--  ######################################################    SVA TO SVA  ###########################################
--TBANCOPPEL  A TBANCOPPEL  CARGO y ABONO
if pstransacc = '0005' and psid_banco_origen = '137' and psid_banco_destino = '137' then   

    IF vEsRetiroVtanilla = '0' THEN  -- VTA 
		set isolation to dirty read; -- Transaccion de Cargo --8001
		select trim(valor), trim(descripcion) into vstransaccion, vsdescripcion  from Bditransfer:"informix".tf_param_transfer
		where codigo = '210';
		set isolation to dirty read; -- Transacción de Abono -- 8007
		select trim(valor), trim(descripcion) into vstransaccion2, vsdescripcion2  from Bditransfer:"informix".tf_param_transfer
		where codigo = '215';
		
		IF  ( vstransaccion is null or vstransaccion = '' ) OR ( vstransaccion2 is null or vstransaccion2 = '' )  then
			let vscodret = '00001';
			return 	vscodret;
		END IF;
		
	else 	-- VTA 
		set isolation to dirty read; -- VTA 
		select trim(valor), trim(descripcion) into vstransaccion, vsdescripcion  from Bditransfer:"informix".tf_param_transfer -- VTA 
			where codigo = '228'; -- RETIRO CON FOLIO (CARGO) 8020  
		IF  ( vstransaccion is null or vstransaccion = '' )   then
			let vscodret = '00001';
			return 	vscodret;
		END IF;
    END IF; -- VTA  

	if pstpo_id_origen = '01' then    -- Tipo de origen es celular
		IF vEsRetiroVtanilla = '0' THEN   --- VTA 
			execute procedure Bdicheq:"informix".sp_transfer_regtrxconciliacion ( 	psfolio_suc, /* Folio suc del registro */ '9290', /* Numero de la sucursal*/
																					pscve_usuario, vstransaccion, /*Pendiente de ser definida*/
																					vscuenta1, pmmonto, vsdescripcion, '')  INTO vscodret;

			execute procedure Bdicheq:"informix".sp_transfer_regtrxconciliacion  (  psfolio_suc, /* Folio suc del registro*/ '9290', /* Numero de la sucursal */
																					pscve_usuario, vstransaccion2, /* Pendiente de ser definida */
																					vscuenta2, pmmonto, vsdescripcion2, '') INTO vscodret;
														   
		ELSE -- VTA 				
             execute procedure Bdicheq:"informix".sp_transfer_regtrxconciliacion  ( psfolio_suc, /* Folio suc del registro*/ '9290', /* Numero de la sucursal*/
																					pscve_usuario, vstransaccion, 
																					vscuenta1, pmmonto, vsdescripcion, '') INTO vscodret; 

        END IF;         -- VTA  	

		if vscodret <> '000' then
			let vscodret = '00001';
			return 	vscodret;	
		end if;								
			                                    
	elif (pstpo_id_origen in ('02','03')) then   -- Tipo de Origen en Cuenta Clabe / tjt 
 
		execute procedure Bdicheq:"informix".sp_transfer_regtrxconciliacion ( psfolio_suc, /*Folio suc del registro*/ '9290', /* Numero de la sucursal*/
																			  pscve_usuario, vstransaccion, /* Pendiente de ser definida */
																			  vscuenta1, pmmonto, vsdescripcion, '') INTO vscodret;
			                                                          
		if vscodret <> '000' then
			let vscodret = '00001';
			return 	vscodret;
		end if; 
	end if;
--TBANCOPPEL  A TINBURSA CARGO	
elif pstransacc = '0005' and psid_banco_origen = '137' and psid_banco_destino = '036' then 
	set isolation to dirty read;
	select trim(valor), trim(descripcion) into vstransaccion, vsdescripcion  from Bditransfer:"informix".tf_param_transfer
		where codigo = '211';
	
	IF  ( vstransaccion is null or vstransaccion = '' )  then
		let vscodret = '00001';
        return 	vscodret;
    END IF;
	
	if  (pstpo_id_origen in ('01','02','03') )  then    -- Tipo de origen es celular / cbe / tjt
          
		execute procedure Bdicheq:"informix".sp_transfer_regtrxconciliacion ( psfolio_suc, /* Folio suc del registro*/ '9290', /* Numero de la sucursal */
																			pscve_usuario, vstransaccion, /* Pendiente de ser definida */
																			vscuenta1, pmmonto, vsdescripcion, '') INTO vscodret;
		                                                                 
		if vscodret <> '000' then
			let vscodret = '00001';
			return 	vscodret;
		end if;
							
	end if;
--TBANCOPPEL  A TBANAMEX    -- CARGO
elif pstransacc = '0005' and psid_banco_origen = '137' and psid_banco_destino = '002' then 
	set isolation to dirty read;
	select trim(valor), trim(descripcion) into vstransaccion, vsdescripcion  from Bditransfer:"informix".tf_param_transfer
		where codigo = '212';
	
	IF  ( vstransaccion is null or vstransaccion = '' )  then
		let vscodret = '00001';
		return 	vscodret;
	END IF;
	
    if  (pstpo_id_origen in ('01','02','03') )  then    -- Tipo de origen es celular / cbe / tjt
	
		execute procedure Bdicheq:"informix".sp_transfer_regtrxconciliacion(psfolio_suc, /* Folio suc del registro */ '9290', /* Numero de la sucursal */
																			pscve_usuario, vstransaccion, /* Pendiente de ser definida */
																			vscuenta1, pmmonto, vsdescripcion, '') INTO vscodret;
		 
		if  vscodret <> '000' then
			let vscodret = '00001';
			return 	vscodret;
		end if;

 	end if; 			
--TINBURSA  A TBANCOPPEL   -- ABONO	
elif pstransacc = '0005' and psid_banco_origen = '036' and psid_banco_destino = '137' then 
	set isolation to dirty read;
	select trim(valor), trim(descripcion) into vstransaccion, vsdescripcion  from Bditransfer:"informix".tf_param_transfer
	where codigo = '213'; 
	
	IF  ( vstransaccion is null or vstransaccion = '' )  then
		let vscodret = '00001';
		return 	vscodret;
    END IF;
 
	if (pstpo_id_destino in ('00','01','02','03')) then    -- Tipo de origen es celular / cbe / tjt
	    
		execute procedure Bdicheq:"informix".sp_transfer_regtrxconciliacion(psfolio_suc, /* Folio suc del registro*/ '9290', /* Numero de la sucursal*/
																			pscve_usuario, vstransaccion, /* Pendiente de ser definida */
																			vscuenta2, pmmonto, vsdescripcion, '') INTO vscodret;
                                                 
		if  vscodret <> '000' then
			let vscodret = '00001';
			return 	vscodret;
		end if;
			                                  
	end if; 	
--TBANAMEX  A TBANCOPPEL    -- ABONO	
elif pstransacc = '0005' and psid_banco_origen = '002' and psid_banco_destino = '137' then 
	set isolation to dirty read;
	select trim(valor), trim(descripcion) into vstransaccion, vsdescripcion  from Bditransfer:"informix".tf_param_transfer
	where codigo = '214';
	
	IF  ( vstransaccion is null or vstransaccion = '' )  then
		let vscodret = '00001';
			return 	vscodret;
	END IF;
	
	if (pstpo_id_destino in ('00','01','02','03')) then    -- Tipo de origen es celular / cbe / tjt
	   
		execute procedure Bdicheq:"informix".sp_transfer_regtrxconciliacion(psfolio_suc, /* Folio suc del registro*/ '9290', /* Numero de la sucursal*/
																			pscve_usuario, vstransaccion, /* Pendiente de ser definida */
																			vscuenta2, pmmonto, vsdescripcion, '') INTO vscodret;
																			
		if  vscodret <> '000' then
			let vscodret = '00001';
			return 	vscodret;
		end if;
												                                              
	END IF;		
--  #####################################  INICIO PAGO AL  COMERCIANTE  ####################################################
elif pstransacc = '0042' and psid_banco_origen = '137' and psid_banco_destino = '137' then   --TBANCOPPEL  A TBANCOPPEL  CARGO
	set isolation to dirty read; -- Transaccion de Cargo --8008
	select trim(valor), trim(descripcion) into vstransaccion, vsdescripcion  from Bditransfer:"informix".tf_param_transfer
		where codigo = '220';
	set isolation to dirty read; -- Transacción de Abono -- 8009
	select trim(valor), trim(descripcion) into vstransaccion2, vsdescripcion2  from Bditransfer:"informix".tf_param_transfer
		where codigo = '221';
		
	IF  ( vstransaccion is null or vstransaccion = '' ) OR ( vstransaccion2 is null or vstransaccion2 = '' )  then
		let vscodret = '00001';
		return 	vscodret;
	END IF;
			
	if pstpo_id_origen = '01' then    -- Tipo de origen es celular
			       
		execute procedure Bdicheq:"informix".sp_transfer_regtrxconciliacion(psfolio_suc, /* Folio suc del registro*/  '9290', /* Numero de la sucursal */
																			pscve_usuario, vstransaccion, /* Pendiente de ser definida */
																			vscuenta1, pmmonto, vsdescripcion, '') INTO vscodret;

		execute procedure Bdicheq:"informix".sp_transfer_regtrxconciliacion(psfolio_suc, /* Folio suc del registro*/  '9290', /* Numero de la sucursal */
																			pscve_usuario, vstransaccion2, /* Pendiente de ser definida */
																			vscuenta2, pmmonto, vsdescripcion2, '') INTO vscodret;
			
        if vscodret <> '000' then
			let vscodret = '00001';
			return 	vscodret;	
        end if;															   
			                                        
	elif (pstpo_id_origen in ('02','03')) then   -- Tipo de Origen en Cuenta Clabe / tjt
			
		execute procedure Bdicheq:"informix".sp_transfer_regtrxconciliacion(psfolio_suc, /* Folio suc del registro */ '9290', /* Numero de la sucursal */
																				pscve_usuario, vstransaccion, /* Pendiente de ser definida */
																				vscuenta1, pmmonto, vsdescripcion, '') INTO vscodret;
		                                                              
		if vscodret <> '000' then
			let vscodret = '00001';
			return 	vscodret;	
        end if;															   
														   
	end if; 		
--TBANCOPPEL  A TINBURSA CARGO		
elif pstransacc = '0042' and psid_banco_origen = '137' and psid_banco_destino = '036' then --TBANCOPPEL  A TINBURSA CARGO
	
	set isolation to dirty read;
	select trim(valor), trim(descripcion) into vstransaccion, vsdescripcion  from Bditransfer:"informix".tf_param_transfer --8010
	where codigo = '222';
	
	IF  ( vstransaccion is null or vstransaccion = '' )  then
		let vscodret = '00001';
		return 	vscodret;
    END IF;
	
	if (pstpo_id_origen in ('01','02','03')) then    -- Tipo de origen es celular / clabe / tjt
	 
		execute procedure Bdicheq:"informix".sp_transfer_regtrxconciliacion(psfolio_suc, /* Folio suc del registro */ '9290', /* Numero de la sucursal */
																			pscve_usuario, vstransaccion, /* Pendiente de ser definida */
																			vscuenta1, pmmonto, vsdescripcion, '') INTO vscodret;

        if vscodret <> '000' then
			let vscodret = '00001';
 			return 	vscodret;	
        end if;															   

	end if;
--TBANCOPPEL  A TBANAMEX    -- CARGO 8011
elif pstransacc = '0042' and psid_banco_origen = '137' and psid_banco_destino = '002' then 
	
	set isolation to dirty read;
	select trim(valor), trim(descripcion) into vstransaccion, vsdescripcion  from Bditransfer:"informix".tf_param_transfer
	where codigo = '223';
	
		 IF  ( vstransaccion is null or vstransaccion = '' )  then
              let vscodret = '00001';
              return 	vscodret;
        END IF;
	
	if (pstpo_id_origen in ('01','02','03')) then    -- Tipo de origen es celular / clabe / tjt

		execute procedure Bdicheq:"informix".sp_transfer_regtrxconciliacion(psfolio_suc, /* Folio suc del registro */ '9290', /* Numero de la sucursal */
																			pscve_usuario, vstransaccion, /* Pendiente de ser definida */
																			vscuenta1, pmmonto, vsdescripcion, '') INTO vscodret;
		                                                        
		if vscodret <> '000' then
			let vscodret = '00001';
			return 	vscodret;
		end if;	

	end if;
	
elif pstransacc = '0042' and psid_banco_origen = '036' and psid_banco_destino = '137' then --TINBURSA  A TBANCOPPEL   -- ABONO 8012
	set isolation to dirty read;
	select trim(valor), trim(descripcion) into vstransaccion, vsdescripcion  from Bditransfer:"informix".tf_param_transfer
		where codigo = '224';
	
	IF  ( vstransaccion is null or vstransaccion = '' )  then
		let vscodret = '00001';
		return 	vscodret;
	END IF;
	
	if (pstpo_id_destino in ('00','01','02','03')) then    -- Tipo de origen es celular / cbe / tjt
	
		execute procedure Bdicheq:"informix".sp_transfer_regtrxconciliacion(psfolio_suc, /* Folio suc del registro*/ '9290', /* Numero de la sucursal*/
																			pscve_usuario, vstransaccion, /* Pendiente de ser definida */
																			vscuenta2, pmmonto, vsdescripcion, '') INTO vscodret;																			
		if vscodret <> '000' then
			let vscodret = '00001';
			return 	vscodret;	
        end if;
		
	end if;
--TBANAMEX  A TBANCOPPEL    -- ABONO 8013	
elif pstransacc = '0042' and psid_banco_origen = '002' and psid_banco_destino = '137' then 
	set isolation to dirty read;
	select trim(valor), trim(descripcion) into vstransaccion, vsdescripcion  from Bditransfer:"informix".tf_param_transfer
		where codigo = '225';
	
	IF  ( vstransaccion is null or vstransaccion = '' )  then
		let vscodret = '00001';
              return 	vscodret;
        END IF;
	
	if (pstpo_id_destino in ('00','01','02','03')) then    -- Tipo de origen es celular / cbe / tjt
  
		execute procedure Bdicheq:"informix".sp_transfer_regtrxconciliacion(psfolio_suc, /* Folio suc del registro */ '9290', /* Numero de la sucursal */
																			pscve_usuario, vstransaccion, /* Pendiente de ser definida*/
																			vscuenta2, pmmonto, vsdescripcion, '') INTO vscodret;
																			
		if vscodret <> '000' then
			let vscodret = '00001';
 			return 	vscodret;	
        end if;															   
			                                             
	end if;
--  ######################################    FINAL de PAGO AL COMERCIANTE   #########################################
--  ######  INICIO  ##################### BANCO a SVA  ABONO A CUENTA TRANSFER  PARA FONDEO transaccion 0330 #####################################
elif pstransacc = '0004' and psid_banco_origen = '137' and psid_banco_destino = '137' then --BANCOPPEL  A TBANCOPPEL    
	set isolation to dirty read;
	select trim(valor), trim(descripcion) into vstransaccion, vsdescripcion  from Bditransfer:"informix".tf_param_transfer
		where codigo = '241';   

	IF  ( vstransaccion is null or vstransaccion = '' )  then
        let vscodret = '00001';
        return 	vscodret;
    END IF;
	
	if (pstpo_id_destino in ('00','01','02','03')) then    -- Tipo de origen es celular / cbe / tjt
		
		execute procedure Bdicheq:"informix".sp_transfer_regtrxconciliacion( psfolio_suc, /* Folio suc del registro */ '9290', /* Numero de la sucursal */
																		pscve_usuario, vstransaccion, /* Pendiente de ser definida */
																		vscuenta2, pmmonto, vsdescripcion, '') INTO vscodret;
                                                         						
	    if vscodret <> '000' then
			let vscodret = '00001';
 			return 	vscodret;	
        end if;	
		
	end if;
	
--  ######  FINAL   ##################### BANCO a SVA  ABONO A CUENTA TRANSFER  PARA FONDEO transacción 0330 #####################################
--  ######## INICIO #####################  SVA TO BANK  CARGO a Cta. Transfer  y (s/a) abono Cta. Bancoppel  transaccion  0300 #################   
elif 	pstransacc = '0031' and  psid_banco_origen = '137' and  pstpo_id_origen in ('01', '02', '03','04')  --- Se agregan origenes 01,02,03 
		/*and psid_banco_destino = '000'*/ and pstpo_id_destino in ('01','02','03','04') then -- TBANCOPPEL A BANCOPPEL Tradicional
		  
	  if ( vPagoTDC = '0' )  then 
 	
	     set isolation to dirty read;
	     select trim(valor), trim(descripcion) into vstransaccion, vsdescripcion  from Bditransfer:"informix".tf_param_transfer
		 where codigo = '251';
	
	elif (vPagoTDC = '1') then  -- Pago TDC BANCOPPEL  
	
	     set isolation to dirty read;
	     select trim(valor), trim(descripcion) into vstransaccion, vsdescripcion  from Bditransfer:"informix".tf_param_transfer
		 where codigo = '271'; -- 0279 
		 
    elif (vPagoTDC = '2') then 	-- Pago TDC Otros Bancos
	  
	     set isolation to dirty read;
	     select trim(valor), trim(descripcion) into vstransaccion, vsdescripcion  from Bditransfer:"informix".tf_param_transfer
		 where codigo = '270';  -- 8016 PAGO DE CREDITO TDC 	
	 else 	
	    let vscodret = '00001';
		return 	vscodret;
	
	end	if;		 		
	
	IF  ( vstransaccion is null or vstransaccion = '' )  then
		let vscodret = '00001';
		return 	vscodret;
    END IF;
	
	execute procedure Bdicheq:"informix".sp_transfer_regtrxconciliacion( psfolio_suc, /* Folio suc del registro */ '9290', /* Numero de la sucursal */
																		pscve_usuario, vstransaccion, /* Pendiente de ser definida*/
																		vscuenta1, pmmonto, vsdescripcion, '') INTO vscodret;
																		
	if vscodret <> '000' then
		let vscodret = '00001';
 		return 	vscodret;	
    end if;																		
																
--  ######## FINAL  #####################  SVA TO BANK  Cargo a Cta. Transfer abono Cta. Bancoppel  transaccion  transacción 0300 #################   
--  ###################################  Compra de tiempo Aire  ###########################################################   
elif pstransacc in ('0034','0085') and psid_banco_origen = '137'  then --BANCOPPEL  A TBANCOPPEL    
	set isolation to dirty read;
	select trim(valor), trim(descripcion) into vstransaccion, vsdescripcion  from Bditransfer:"informix".tf_param_transfer
	where codigo = '201';
	
	IF  ( vstransaccion is null or vstransaccion = '' )  then
		let vscodret = '00001';
        return 	vscodret;
    END IF;
	
	if pstpo_id_origen = '01' then    -- Tipo de origen es celular

		execute procedure Bdicheq:"informix".sp_transfer_regtrxconciliacion( psfolio_suc, /* Folio suc del registro */ '9290', /* Numero de la sucursal */
																		pscve_usuario, vstransaccion, /* Pendiente de ser definida */
																		vscuenta1, pmmonto, vsdescripcion, '') INTO vscodret;
		   
        if vscodret <> '000' then
           let vscodret = '00001';
           return 	vscodret;	
        end if;																				                                          
	end if;		
-- ############################################  FIN DE TIEMPO AIRE   ###########################################################
-- ############################################	INICIO AJUSTE DE SALDO ############################################
elif pstransacc = '0014' and psid_banco_origen = '137' then --and psid_banco_destino = '000' then      	
	
	IF (pmmonto < 0 ) THEN 
		set isolation to dirty read;
		select trim(valor), trim(descripcion) into vstransaccion, vsdescripcion  from Bditransfer:"informix".tf_param_transfer
			where codigo = '227'; --- ( ABONO ) Cargo de Saldo
	  
		LET pmmonto = ABS(pmmonto);  -- Transforma a positivo para que no genere error y se contabilice de esa manera. 
	  
	ELSE 
		IF (pmmonto  > 0 ) THEN 
	        set isolation to dirty read;
	        select trim(valor), trim(descripcion) into vstransaccion, vsdescripcion  from Bditransfer:"informix".tf_param_transfer
				where codigo = '226';   --- ( CARGO ) Ajuste de Saldo
		ELSE  
			let vscodret = '00001';
		    RETURN 	vscodret;
		END IF; 		
	END IF;   
	  
	IF  ( vstransaccion is null or vstransaccion = '' )  then
		let vscodret = '00001';
        return 	vscodret;
    END IF;
	
	if (pstpo_id_origen in ('01','02','03','04')) then    -- Tipo de origen es celular

		execute procedure Bdicheq:"informix".sp_transfer_regtrxconciliacion(psfolio_suc, /* Folio suc del registro */ '9290', /* Numero de la sucursal */
																			pscve_usuario, vstransaccion, /* Pendiente de ser definida */
																			vscuenta1, pmmonto, vsdescripcion, '') INTO vscodret;
 
        if vscodret <> '000' then
			let vscodret = '00001';
			return 	vscodret;	
		end if;						
				
	end if;
--################################################## FIN AJUSTE DE SALDO ######################################################### 
-- ############################################	INICIO CANCELACIÓN RETIRO CON FOLIO EN VENTANILLA ############################################
elif (pstransacc = '0036') AND  (psid_banco_origen = '137' and psid_banco_destino = '137') AND  (pstpo_id_origen  = '01'  AND  pstpo_id_destino  ='01') THEN 

    set isolation to dirty read;
	select trim(valor), trim(descripcion) into vstransaccion, vsdescripcion  from Bditransfer:"informix".tf_param_transfer
		where codigo = '229';  --DEVOLUCIÓN RETIRO CON FOLIO (ABONO)
	
	IF  ( vstransaccion is null or vstransaccion = '' )  then
		let vscodret = '00001';
        return 	vscodret;
    END IF;

	execute procedure Bdicheq:"informix".sp_transfer_regtrxconciliacion( psfolio_suc,  '9290',  pscve_usuario, vstransaccion, 
																		vscuenta2, pmmonto, vsdescripcion, '') INTO vscodret;
                                                         						
	if vscodret <> '000' then
		let vscodret = '00001';
        return 	vscodret;	
    end if;		
--################################################## FIN CANCELACIÓN RETIRO CON FOLIO EN VENTANILLA ######################################################### 
--################################################## INICIA PAGO DE SERVICIOS ######################################################### 
elif pstransacc in ('0094', /*Aportación AFORE*/ '0095', /*NEXTEL */ '0096', /*IZZI */ '0080', /* PAGO CFE */ 	'0081', /* PAGO GDF */ 
                	'0082', /*  GEDOMEX */	     '0083', /*DISH */   '0084', /*TAG' */ '0086', /*MOVISTAR */ 	'0087', /* RECARGA IUSACELL */ 
					'0088', /*  UNEFON */        '0089', /*NEXTEL*/  '0090', /*TELMEX*/'0091', /*TELCEL */ 	    '0092', /* PAGO INFONAVIT */
					'0103',/*PIN FACEBOOK */     '0104', /*PAYPAL */ '0110', /*PS*/    '0111', /* PS PLUS*/     '0112', /*PAGO SALAMANCA*/ 
					'0113', /*CELAYA*/           '0114', /*FENOSA*/  '0115', /*QUERET*/'0118', /*GUANAJUATO*/   '0119', /*JALISCO*/ 
					'0120', /*MICHOACAN*/        '0121', /*TLAZCALA*/'0122', /*COAHUL*/'0123', /*MEGACABLE*/    '0124', /*MAXCOM*/  
					'0125', /*XBOX*/             '0093', /*CINEPOLI*/'0106', /*CINECA*/'0107', /*KONIBIT*/      '0108', /*STAR TV*/
					'0126',/*SL TELCEL*/         '0132', /*RESP.CVL*/'0133', /*PETCO*/ '0134', /*QUERETARO*/    '0135'  /*LEON*/ )
	  AND  psid_banco_origen = '137' AND  pstpo_id_origen  = '01'  then
	  
	set isolation to dirty read;
	select trim(valor), trim(descripcion) 
		into vstransaccion, vsdescripcion  
	from Bditransfer:"informix".tf_param_transfer
		where codigo MATCHES  ( case 	when pstransacc = '0094' then '252' /* Aportación Voluntaria AFORE */
										when pstransacc = '0095' then '253' /* PAGO NEXTEL */
										when pstransacc = '0096' then '254' /* PAGO IZZI */
										when pstransacc = '0080' then '255' /* PAGO CFE */
										when pstransacc = '0081' then '256' /* PAGO GDF */
										when pstransacc = '0082' then '257' /* PAGO GEDOMEX */
										when pstransacc = '0083' then '258' /* PAGO DISH */
										when pstransacc = '0084' then '259' /* RECARGA TAG' */ 
										when pstransacc = '0086' then '260' /* RECARGA MOVISTAR */ 
										when pstransacc = '0087' then '261' /* RECARGA IUSACELL */
										when pstransacc = '0088' then '262' /* RECARGA UNEFON */
										when pstransacc = '0089' then '263' /* RECARGA NEXTEL */ 
										when pstransacc = '0090' then '264' /* PAGO TELMEX */
										when pstransacc = '0091' then '265' /* PAGO TELCEL */
										when pstransacc = '0092' then '266' /* PAGO INFONAVIT */
										when pstransacc = '0103' then '269' /* COMPRA PIN FACEBOOK */
										when pstransacc = '0104' then '268' /* RECARGA DE SALDO PAYPAL */
										when pstransacc = '0110' then '272' /*PLAYSTATION*/
										when pstransacc = '0111' then '273' /*PLAYSTATION PLUS*/
										when pstransacc = '0112' then '274' /*PAGO CMAPAS SALAMANCA*/
										when pstransacc = '0113' then '275' /*PAGO JUMAPA CELAYA*/
										when pstransacc = '0114' then '276' /*PAGO GAS NATURAL FENOSA*/
										when pstransacc = '0115' then '277' /*PAGO A GOB ESTADO DE QUERETARO*/
										when pstransacc = '0118' then '278' /*PAGO A GOB ESTADO DE GUANAJUATO*/
										when pstransacc = '0119' then '279' /*PAGO A GOB ESTADO DE JALISCO*/
										when pstransacc = '0120' then '280' /*PAGO A GOB ESTADO DE MICHOACAN*/
										when pstransacc = '0121' then '281' /*PAGO A GOB ESTADO DE TLAZCALA*/
										when pstransacc = '0122' then '282' /*PAGO A GOB ESTADO DE COAHUILA*/
										when pstransacc = '0123' then '283' /*PAGO A MEGACABLE*/ 
										when pstransacc = '0124' then '284' /*PAGO A MAXCOM*/
										when pstransacc = '0125' then '285' /*XBOX*/ 
										when pstransacc = '0093' then '286' /*CINEPOLIS*/
										when pstransacc = '0106' then '287' /*PAGO A CINECASH*/ 
										when pstransacc = '0107' then '288' /*PAGO DE ANTIVIRUS KONIBIT*/
										when pstransacc = '0108' then '289' /*PAGO A STAR TV*/ 
										when pstransacc = '0126' then '290' /*PAQ. SL TELCEL*/
										when pstransacc = '0132' then '291' /*RESP.CIVL*/ 
										when pstransacc = '0133' then '292' /*PETCO*/
										when pstransacc = '0134' then '293' /*MUNICIPIO QUERETARO*/ 
										when pstransacc = '0135' then '294' /*MUNICIPIO LEON*/										
										end);
										
	IF  ( vstransaccion is null or vstransaccion = '' )  then
		let vscodret = '00001';
        return 	vscodret;
	end if;
	
	execute procedure Bdicheq:"informix".sp_transfer_regtrxconciliacion( psfolio_suc, /* Folio suc del registro */ '9290', /* Numero de la sucursal */
																		pscve_usuario, vstransaccion, vscuenta1, pmmonto, vsdescripcion, '') INTO vscodret;		   
    if vscodret <> '000' then
         let vscodret = '00001';
         return 	vscodret;	
    end if;			
		
--################################################## FINALIZA PAGO DE SERVICIOS ######################################################### 	
--################################################## INICIA DEV. PAGO DE SERVICIOS ######################################################### 
elif (pstransacc  =  '0057' ) then -- NEW 

 if exists ( select dbsname, tabname from sysmaster:systabnames  where tabname = 'tf_success_transac_1' and dbsname= 'bditransfer') then
		drop table bditransfer:"informix".tf_success_transac_1;
 end if;

  set isolation to dirty read;
  SELECT  b.consecutivo, b.transacc FROM bditransfer:"informix".tf_success_transac a 
  INNER JOIN bditransfer:"informix".tf_success_transac b  
  ON    a.id_reverso = b.id_transacc_mps  WHERE a.folio_suc  =  psfolio_suc
  AND   (b.fecha_alt >=  today - 250) 
  order by b.consecutivo desc
  into temp tf_success_transac_1 with no log;
  
  set isolation to dirty read;
  select limit 1 transacc into vstransaccion from Bditransfer:"informix".tf_success_transac_1;
	
  drop table bditransfer:"informix".tf_success_transac_1;
   
    if  ( vstransaccion is null or vstransaccion = '' )  then
		let vscodret = '00001';
        return 	vscodret;
	end if;
  
	set isolation to dirty read; -- DEVOLUTION  
	select trim(valor), trim(descripcion) 
		into vstransaccion, vsdescripcion  
	from Bditransfer:"informix".tf_param_transfer
		where codigo MATCHES  ( case 	when vstransaccion = '0094' then '295' -- DEVOLUCIÓN Aportación Voluntaria AFORE 
										when vstransaccion = '0095' then '296' -- DEVOLUCIÓN PAGO NEXTEL 
										when vstransaccion = '0096' then '297' -- DEVOLUCIÓN PAGO IZZI 
										when vstransaccion = '0080' then '298' -- DEVOLUCIÓN PAGO CFE 
										when vstransaccion = '0081' then '299' -- DEVOLUCIÓN PAGO GDF 
										when vstransaccion = '0082' then '300' -- DEVOLUCIÓN PAGO GEDOMEX 
										when vstransaccion = '0083' then '301' -- DEVOLUCIÓN PAGO DISH 
										when vstransaccion = '0084' then '302' -- DEVOLUCIÓN RECARGA TAG
										when vstransaccion = '0086' then '303' -- DEVOLUCIÓN RECARGA MOVISTAR 
										when vstransaccion = '0087' then '304' -- DEVOLUCIÓN RECARGA IUSACELL 
										when vstransaccion = '0088' then '305' -- DEVOLUCIÓN RECARGA UNEFON 
										when vstransaccion = '0089' then '306' -- DEVOLUCIÓN RECARGA NEXTEL 
										when vstransaccion = '0090' then '307' -- DEVOLUCIÓN PAGO TELMEX 
										when vstransaccion = '0091' then '308' -- DEVOLUCIÓN PAGO TELCEL 
										when vstransaccion = '0092' then '309' -- DEVOLUCIÓN PAGO INFONAVIT 
										when vstransaccion = '0103' then '311' -- DEVOLUCIÓN COMPRA PIN FACEBOOK 
										when vstransaccion = '0104' then '310' -- DEVOLUCIÓN RECARGA DE SALDO PAYPAL 
										when vstransaccion = '0110' then '312' -- DEVOLUCIÓN PLAYSTATION
										when vstransaccion = '0111' then '313' -- DEVOLUCIÓN PLAYSTATION PLUS
										when vstransaccion = '0112' then '314' -- DEVOLUCIÓN PAGO CMAPAS SALAMANCA
										when vstransaccion = '0113' then '315' -- DEVOLUCIÓN PAGO JUMAPA CELAYA
										when vstransaccion = '0114' then '316' -- DEVOLUCIÓN PAGO GAS NATURAL FENOSA
										when vstransaccion = '0115' then '317' -- DEVOLUCIÓN PAGO A GOB ESTADO DE QUERETARO
										when vstransaccion = '0118' then '318' -- DEVOLUCIÓN PAGO A GOB ESTADO DE GUANAJUATO
										when vstransaccion = '0119' then '319' -- DEVOLUCIÓN PAGO A GOB ESTADO DE JALISCO
										when vstransaccion = '0120' then '320' -- DEVOLUCIÓN PAGO A GOB ESTADO DE MICHOACAN
										when vstransaccion = '0121' then '321' -- DEVOLUCIÓN PAGO A GOB ESTADO DE TLAZCALA
										when vstransaccion = '0122' then '322' -- DEVOLUCIÓN PAGO A GOB ESTADO DE COAHUILA
										when vstransaccion = '0123' then '323' -- DEVOLUCIÓN PAGO A MEGACABLE
										when vstransaccion = '0124' then '324' -- DEVOLUCIÓN PAGO A MAXCOM
										when vstransaccion = '0125' then '325' -- DEVOLUCIÓN XBOX
										when vstransaccion = '0093' then '326' -- DEVOLUCIÓN CINEPOLIS
										when vstransaccion = '0106' then '327' -- DEVOLUCIÓN PAGO A CINECASH
										when vstransaccion = '0107' then '328' -- DEVOLUCIÓN PAGO DE ANTIVIRUS KONIBIT
										when vstransaccion = '0108' then '329' -- DEVOLUCIÓN PAGO A STAR TV
		                                when vstransaccion = '0126' then '330' -- PAQ. SL TELCEL
										when vstransaccion = '0132' then '331' -- RESP.CIVL
										when vstransaccion = '0133' then '332' -- PETCO
										when vstransaccion = '0134' then '333' -- MUNICIPIO QUERETARO
										when vstransaccion = '0135' then '334' -- MUNICIPIO LEON											
										end);
		
	IF  ( vstransaccion is null or vstransaccion = '' )  then
		let vscodret = '00001';
        return 	vscodret;
	end if;		
			
	execute procedure Bdicheq:"informix".sp_transfer_regtrxconciliacion( psfolio_suc,  '9290',  pscve_usuario, vstransaccion, vscuenta2, pmmonto, vsdescripcion, '') INTO vscodret;
                                                         						
	if vscodret <> '000' then
		let vscodret = '00001';
        return 	vscodret;	
    end if;	
	
--################################################## FINALIZA DEV. PAGO DE SERVICIOS ######################################################### 	
--################################################## INICIO OPM SPEI - BANK TO SVA ######################################################### 	
elif 	pstransacc = '0032'  and psid_banco_destino = '137' and pstpo_id_destino in ('01','02','03','04') then -- TBANCOPPEL A BANCOPPEL Tradicional
		
	set isolation to dirty read;
	select trim(valor), trim(descripcion) into vstransaccion, vsdescripcion  from Bditransfer:"informix".tf_param_transfer
		where codigo = '267';
	
	
	IF  ( vstransaccion is null or vstransaccion = '' )  then
		let vscodret = '00001';
		return 	vscodret;
    END IF;
	
	execute procedure Bdicheq:"informix".sp_transfer_regtrxconciliacion( psfolio_suc, /* Folio suc del registro */ '9290', /* Numero de la sucursal */
																		pscve_usuario, vstransaccion, /* Pendiente de ser definida*/
																		vscuenta, pmmonto, vsdescripcion, '') INTO vscodret;																	
	if vscodret <> '000' then
		let vscodret = '00001';
 		return 	vscodret;	
    end if;					
--################################################## FIN OPM SPEI - BANK TO SVA ######################################################### 		
end if;  

let vsmensaje_respuesta = 'Finaliza proceso de registro contable en SC_MOVDIA Transfer puro';
return 
	vscodret;
end
end procedure
DOCUMENT
'AUTOR: Ricardo Reséndiz Martínez',
'Proyecto: Proceso de registro de Transacciones Transfer a Transfer, Solicito: Jose Luis Puebla',
'Descripcion: Realiza proceso Asignacion de transaccion de operaciones Transfer a Transfer',
'Fecha: 2014/09/08 Version: 20140908.1500 BD: BdiTransfer', 
'',
'MODIFICO: L.I.A. Ricardo Reséndiz Martínez',
'Proyecto: Proceso de registro de Transacciones SVA a  BANK y de BANK a SVA, Solicito: Jose Luis Puebla',
'Descripcion: Se integra proceso para el registro de Abonos por Fondeo y Cargos por Transferencias, se integra uso de rollback',
'Fecha: 2015/03/23, Version: 20150323.13 , BD: BdiTransfer', 
'',
'MODIFICO: L.I.A. Ricardo Reséndiz Martínez',
'Proyecto: Proceso de registro de Transacciones Pago al comerciante, Solicito: Jose Luis Puebla',
'Descripcion: Se integra proceso para el registro de pago al comerciante, se integra uso de rollback',
'Fecha: 2015/07/27 , Version: 20150727.1300 , BD: BdiTransfer', 
'',
'MODIFICO: L.I.A. Ricardo Reséndiz Martínez',
'Proyecto: RQM 06 432 Redefinición para la aplicacion de la transacción 300,Solicito: Jose Luis Puebla',
'Descripcion: Se agrega proceso para que solo se apliquen aquellos registros que tengam como banco origen y destino ctas. Bancoppel',
'Fecha: 2015/09/09,Version: 20150909.1200',
'BD: BdiTransfer',
'',
'MODIFICO: L.I. Marcos Gerardo Ayala Ponce',
'Proyecto: RQM 06 455 Corrección transacciones transfer en Central Transfer, Solicito: Ana Laura Alverdi Morfin',
'Descripcion: Se añade la transacción "0014" para la aplicación contable del ajuste de saldo Cargo o Abono ',
'Fecha: 2016/02/02, Version: 20160202.1500 BD: BdiTransfer',
'',
'MODIFICO: L.I. Marcos Gerardo Ayala Ponce',
'Proyecto: INC Operativa: INC 13 428 Identificación y registro de la transacción 300 de Transfer por los diferentes canales operativos identificados no considerados',
'Solicito: Ana Laura Alverdi Morfin',
'Descripcion: Se añade a TXN 0031 los destinos (celular, Cta. Clabe) y validanse la correcta existencia en cada destino',
'Fecha: 2016/03/02 Version: 20160302.1200 BD: BdiTransfer',
'',
'MODIFICO: L.I. Marcos Gerardo Ayala Ponce',
'Proyecto: RQM 06-449 Retiro con folio en ventanilla transfer , Solicito: Ana Laura Alverdi Morfin',
'Descripcion: Se añade la transacción (0036-Cancelación retiro con folio en ventanilla) y considera los abonos a cel. sin cta transfer registrandose como 8020-RETIRO CON FOLIO (cargo)',
'Fecha: 2016/03/03, Version: 20160303.1200, BD: BdiTransfer',
'',
'MODIFICO: L.I.A Ricardo Reséndiz Martinez',
'Proyecto: RQM 10 616 Incorporar pago de servicios Transfer',
'Solicito: Jose Luis Puebla Salinas, Descripcion: Se agrega proceso para registros de transacciones de transfer',
'Fecha: 2016/06/08,Version: 20160608.1500, BD: BdiTransfer',
'',
'MODIFICO: L.I. Marcos Gerardo Ayala Ponce Proyecto: RQM 10 797 Pago de TDC BanCoppel y otros bancos en Transfer BanCoppel',
'Solicito: Ana Laura Alverdi Morfin',
'Descripcion: Se añade la transacción (0279 - PAGO DE CREDITO TDC) y (8016 -PAGO A TDC OTRO BANCO (cargo)) Dentro de las Transacciones 0031',
'Fecha: 2016/10/10, Version: 20161010.1200, BD: BdiTransfer',
'',
'MODIFICO: L.I. Marcos Gerardo Ayala Ponce',
'Proyecto: 2017-04-06 RQM 10 616-3 Adendum - Incorporar pago de servicios en Transfer',
'Solicito: David Sanchez, Descripcion: Se añaden 14 nuevos pagos de servicios transfer para su aplicación contable',
'Fecha: 2017/03/28, Version: 20170328.1800, BD: BdiTransfer',
'',
'MODIFICO: L.I. Marcos Gerardo Ayala Ponce',
'Proyecto: RQM 10 929 Cuenta Efectiva Digital - Incorporar pago de servicios, Solicito: David Sanchez',
'Descripcion: Se añaden 4 nuevos pagos de servicios transfer para su aplicación contable',
'Fecha: 2017/07/03, Version: 20170703.1500 BD: BdiTransfer',
'',
'MODIFICO: L.I. Marcos Gerardo Ayala Ponce',
'Proyecto: RQM 10 929-2 Cuenta Efectiva Digital - Incorporar pago de servicios, Solicito: David Sanchez',
'Descripcion: Se añaden 5 nuevos pagos de servicios transfer para su aplicación contable,reemplaza la txn 0133 -> 0032 para SPEI BANK TO SVA ',
'Fecha: 2017/08/18, Version: 20170818.1500, BD: BdiTransfer',
'',
'MODIFICO: L.I. Marcos Gerardo Ayala Ponce',
'Proyecto:  RQM 06 572  Transacciones Nuevas Conciliación, Solicito: Ana Laura Alverdi Morfin',
'Descripcion: Se habilita el registro contable para la Devolución de pago de servicios transfer',
'Fecha: 2017/10/13, Version: 20171013.1600, BD: BdiTransfer',
'',
'MODIFICO: L.I. Marcos Gerardo Ayala Ponce',
'Proyecto:  RQM 10 1098 Cuenta Móvil-Actualizacion de Reportes, Solicito: Productos',
'Descripcion: Se habilita cualquier clave del banco Destino en las transacciones <0031>',
'Fecha: 2018/06/18, Version: 20180618.1800, BD: BdiTransfer';