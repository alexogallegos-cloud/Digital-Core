CREATE PROCEDURE "informix".sp_ce_validacuentacont(p_opcion CHAR(3), p_ccuenta CHAR(4), p_csubcta CHAR(2), p_csubsubcta CHAR(2), p_cssubsubcta CHAR(2), p_csssubsubcta CHAR(2), p_csector CHAR(2) )
RETURNING CHAR(5) as codigo_retorno, CHAR(5) as cuenta;

     DEFINE    sql_err                  INTEGER;
     DEFINE    isam_err                 INTEGER;
     DEFINE    error_info               CHAR(40);
     DEFINE    cod_ret                  CHAR(6);
	DEFINE	vCtaContable			CHAR(4);
	DEFINE	vSubCtaContable		CHAR(2);
	DEFINE	vSSCtaContable			CHAR(2);
	DEFINE	vSSSCtaContable		CHAR(2);
	DEFINE	vSSSSCtaContable		CHAR(2);
	DEFINE	vSector			     CHAR(2);
	DEFINE	vEmpresa			     CHAR(3);
	DEFINE    vCountCtaContable        INTEGER;
	DEFINE    vCountSubCtaContable     INTEGER;
	DEFINE    vCountSector             INTEGER;
	
     LET 	   	cod_ret 				= '00000'; 
	LET	     vCtaContable			= "";
	LET	   	vSubCtaContable		= "";
	LET	     vSSCtaContable			= "";
	LET	     vSSSCtaContable		= "";
	LET	     vSSSSCtaContable		= "";
	LET	     vSector			     = "";
	LET	     vEmpresa			     = "001";
	LET	     vCountCtaContable		= 0;
	LET	     vCountSubCtaContable	= 0;
	LET	     vCountSector			= 0;

    BEGIN

		ON EXCEPTION SET sql_err, isam_err, error_info
			LET cod_ret = sql_err;

			SET DEBUG FILE TO "ErrPoliza.err";
			TRACE sql_err||" * "||isam_err|| " * "||error_info;
			RETURN cod_ret, vCtaContable;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		
		--VALIDAR LOS PARAMETROS DE ENTRADA
			IF p_opcion = '1' OR p_opcion = '2' OR p_opcion = '3' THEN
				
				--VALIDAR LA CUENTA --- consulta SQL
				   
				 SET ISOLATION DIRTY READ;

				IF (p_opcion = '1') THEN   --> CUENTA
				-- SE HACE VALIDACION PARA QUE LA CUENTA NO SE ENCUENTRE VACIA
			          IF p_ccuenta = ''  THEN  
						LET cod_ret = '00015';
					ELSE
						--- ccmayor
						SELECT count (ccmayor)
						INTO vCountCtaContable
						FROM bdinteg:si_catalog 
						WHERE empresa = vEmpresa AND ccmayor = p_ccuenta; -- Se valida unicamente la cuenta.
						
						IF vCountCtaContable = 0 THEN
							LET vCtaContable = '';
							LET cod_ret = '00015';	
						ELSE 		
							LET cod_ret = '00000';	
						END IF;	
					END IF;
				ELIF (p_opcion = '2') THEN --> SUBCUENTA
				--SE VALIDA CUENTA NO SE ENCUENTRE VACIA
					IF p_ccuenta = ''  THEN  
						LET vCtaContable = '';
						LET cod_ret = '00015';	
					ELSE
						--SE VALIDA QUE LAS SUBCUENTAS NO ESTEN VACIAS
						IF p_csubcta = '' OR p_csubsubcta = '' OR  p_cssubsubcta = '' or p_csssubsubcta = '' THEN 
							LET cod_ret = '00016';	
						
						ELSE							
							SELECT count (ccmayor)
							INTO vCountCtaContable
							FROM bdinteg:si_catalog 
							WHERE empresa = vEmpresa AND ccmayor = p_ccuenta; -- Se valida unicamente la cuenta.
							
							IF vCountCtaContable  = 0 THEN
								LET vCtaContable = '';
								LET cod_ret = '00015';		
							ELSE 	
							--- ccmayor,ccsub,ccsubsub, ccssubsub,ccsssubsub
								SELECT count (ccsub)
								INTO vCountSubCtaContable
								FROM bdinteg:si_catalog 
								WHERE 	empresa = vEmpresa AND 
										ccmayor = p_ccuenta AND 
										ccsub = p_csubcta AND 
										ccsubsub = p_csubsubcta AND 
										ccssubsub = p_cssubsubcta AND 
										ccsssubsub = p_csssubsubcta; -- Se valida la cuenta y las subcuentas.							
								IF vCountSubCtaContable = 0 THEN
									LET vCtaContable = '';
									LET cod_ret = '00016';	
								ELSE 		
									LET cod_ret = '00000';	
								END IF;
							END IF;							
						END IF;	
					END IF;
				ELIF (p_opcion = '3') THEN --> SECTOR
					--SE VALIDA QUE LA CUENTA NO ESTE VACIA
					IF p_ccuenta = ''  THEN  
						LET vCtaContable = '';
						LET cod_ret = '00015';						
					ELSE
					--- ccmayor
						SELECT count (ccmayor)
						INTO vCountCtaContable
						FROM bdinteg:si_catalog 
						WHERE empresa = vEmpresa AND ccmayor = p_ccuenta; -- Se valida unicamente la cuenta.
						
						IF vCountCtaContable = 0 THEN
							LET vCtaContable = '';
							LET cod_ret = '00015';	
						ELSE 
							--SE VALIDA QUE LAS SUB CUENTAS NO ESTEN VACIAS
							IF p_csubcta = '' OR p_csubsubcta = '' OR  p_cssubsubcta = '' or p_csssubsubcta = '' THEN 
								LET vCtaContable = '';
								LET cod_ret = '00016';						
							ELSE
							--valida sub cuentas 
							--aqui va el codigo para validar las sub cuentas
								--- ccmayor,ccsub,ccsubsub, ccssubsub,ccsssubsub
								SELECT count (ccsub)
								INTO vCountSubCtaContable
								FROM bdinteg:si_catalog 
								WHERE 	empresa = vEmpresa AND 
										ccmayor = p_ccuenta AND 
										ccsub = p_csubcta AND 
										ccsubsub = p_csubsubcta AND 
										ccssubsub = p_cssubsubcta AND 
										ccsssubsub = p_csssubsubcta; -- Se valida la cuenta y las subcuentas.
										
								IF vCountSubCtaContable= 0 THEN
									LET vCtaContable = '';
									LET cod_ret = '00016';	
								ELSE									
									--SE VALIDA QUE EL SECTOR NO ESTE VACIO
									IF  p_csector = '' THEN
										LET vCtaContable = '';									
										LET cod_ret = '00017';	
									ELSE	
									--- ccmayor,ccsub,ccsubsub, ccssubsub,ccsssubsub, sector
										SELECT count (sector)
										INTO vCountSector
										FROM bdinteg:si_catalog 
										WHERE 	empresa = vEmpresa AND 
												ccmayor = p_ccuenta AND 
												ccsub = p_csubcta AND 
												ccsubsub = p_csubsubcta AND 
												ccssubsub = p_cssubsubcta AND 
												ccsssubsub = p_csssubsubcta AND 
												sector = p_csector; -- Se valida la cuenta, subcuentas y sector.
												
										IF vCountSector = 0 THEN
											LET vCtaContable = '';
											LET cod_ret = '00017';		
										ELSE 		
											LET cod_ret = '00000';		
										END IF;
									END IF;
								END IF;									
							END IF;
						END IF;
					END IF;
				END IF;
				ELSE 
					LET cod_ret = '00014'; 	
			END IF;
		RETURN cod_ret, vCtaContable;
    END	
END PROCEDURE;