CREATE PROCEDURE "informix".sp_obtieneinfoopventanilla_web( Pfecha Date,Psucursal Char (04),Pejecutivo Char (08), PtipoEjecutivo Char (01),  siRegistros SMALLINT )
RETURNING   Char (05)	AS cod_ret      ,
			Date		AS Fecha        ,
			Char (04)	AS Sucursal     ,
			Char (08)	AS Cajero       ,
			integer		AS tpo_reg      ,
			Char (104)	AS Nombre       ,
			Integer		AS num_depcap   ,
			Money (18,2)AS mont_depcap  ,
			Integer		AS num_retcap   ,
			Money (18,2)AS mont_retcap  ,
			integer		AS num_pagcred  ,
			Money (18,2)AS mont_pagcred ,
			Integer		AS num_dispcred ,
			Money (18,2)AS mont_dispcred,
			integer		AS num_pagserv  ,
			Money (18,2)AS mont_pagserv ;
		  
--declaracion de variables de retorno
	DEFINE	cod_ret			Char (05)   ;
	DEFINE	VFecha			Date        ;
	DEFINE	VSucursal		Char (04)   ;
	DEFINE	VCajero			Char (08)   ;
	DEFINE	Vtpo_reg		integer     ;
	DEFINE	VNombre			Char (104)  ;
	DEFINE	Vnum_depcap		Integer     ;
	DEFINE	Vmont_depcap	Money (18,2);
	DEFINE	Vnum_retcap		Integer     ;
	DEFINE	Vmont_retcap	Money (18,2);
	DEFINE	Vnum_pagcred	integer     ;
	DEFINE	Vmont_pagcred	Money (18,2);
	DEFINE	Vnum_dispcred	Integer     ;
	DEFINE	Vmont_dispcred	Money (18,2);
	DEFINE	Vnum_pagserv	integer     ;
	DEFINE	Vmont_pagserv	Money (18,2);
	 DEFINE  vestatus_rcda		CHAR(1); 
--
	DEFINE 	vpaso			smallint	;
	DEFINE 	v_sEstatus 		CHAR(1)		;
	DEFINE 	dMaxFecha    	DATE		;
	
	DEFINE	vsqlerr      	INTEGER;
	DEFINE	contador 		INTEGER;
--inicializacion de variables

	let	cod_ret 		  = '00000'	;
	let	vFecha			  = '01/01/1900';
	let	vSucursal 		  = '';	
	let	vtpo_reg		  =	0 ;
	let	vCajero			  = '';
	let	vNombre			  = "Error en central sp_obtieneinfoopventanilla" ;
	let Vnum_depcap		  = 0 ;
	let Vmont_depcap	  = 0 ;
	let Vnum_retcap		  = 0 ;
	let Vmont_retcap	  = 0 ;
	let Vnum_pagcred	  = 0 ;
	let Vmont_pagcred	  = 0 ;
	let Vnum_dispcred	  = 0 ;
	let Vmont_dispcred	  = 0 ;
	let Vnum_pagserv	  = 0 ;
	let Vmont_pagserv     = 0 ;	
	
	let contador  		  = 0 ;
	
BEGIN 
   ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            let cod_ret = vsqlerr;
            RETURN  cod_ret,Vfecha, Vsucursal,Vcajero, Vtpo_reg , Vnombre, Vnum_depcap, Vmont_depcap, Vnum_retcap, Vmont_retcap, 
							   Vnum_pagcred, Vmont_pagcred, Vnum_dispcred, Vmont_dispcred, Vnum_pagserv, Vmont_pagserv;
        END IF;
    END EXCEPTION;


SET ISOLATION TO DIRTY READ;
SELECT {+ INDEX(mi_param idx_descparam)} estatus INTO v_sEstatus FROM bdmis:mi_param WHERE descripcion = 'FLAG RPT CIERRE';
SELECT {+ INDEX(mi_activarsuc_rcda idx_mi_activarsuc_rcda)} estatus_rcda INTO vestatus_rcda	FROM bdmis:mi_activarsuc_rcda WHERE sucursal = Psucursal;

	if (v_sEstatus = 'V') OR (vestatus_rcda = 'V') then
	
			SELECT MAX(fecha_rptcierre) INTO dMaxFecha FROM bdmis:mi_rptcierresucestatus WHERE sucursal = Psucursal AND fecha_rptcierre IS NOT NULL;

		IF (PtipoEjecutivo = 'A'  AND dMaxFecha IS NOT NULL) or(PtipoEjecutivo = 'Z'  AND dMaxFecha IS NOT NULL)  OR (PtipoEjecutivo = 'E'  AND dMaxFecha IS NOT NULL) OR (PtipoEjecutivo = 'U'  AND dMaxFecha IS NOT NULL) THEN	
		
			IF PtipoEjecutivo = 'E'OR PtipoEjecutivo = 'U' THEN
			
				IF (SELECT TRIM(estatus) FROM mi_rptcierresucestatus WHERE sucursal = Psucursal) <> 'C' THEN
				
					LET cod_ret = '00008';
								LET Vnombre = 'EL GERENTE NO A CONSULTADO EL REPORTE';
							
								RETURN  cod_ret,Vfecha, Vsucursal,Vcajero, Vtpo_reg , Vnombre, Vnum_depcap, Vmont_depcap, Vnum_retcap, Vmont_retcap, 
								   Vnum_pagcred, Vmont_pagcred, Vnum_dispcred, Vmont_dispcred, Vnum_pagserv, Vmont_pagserv;	
					
				END IF
			
			END IF
			
			if pfecha = dMaxFecha THEN
						
					IF (SELECT COUNT(*) FROM mi_opventanilla where fecha = pfecha and sucursal = Psucursal ) > 0 THEN	
					
						foreach
							select SKIP siRegistros  FIRST 10 fecha, sucursal, tpo_reg ,cajero, nombre, num_depcap, mont_depcap, num_retcap, mont_retcap, 
								   num_pagcred, mont_pagcred, num_dispcred, mont_dispcred, num_pagserv, mont_pagserv
							INTO  Vfecha, Vsucursal, Vtpo_reg ,Vcajero, Vnombre, Vnum_depcap, Vmont_depcap, Vnum_retcap, Vmont_retcap, 
								   Vnum_pagcred, Vmont_pagcred, Vnum_dispcred, Vmont_dispcred, Vnum_pagserv, Vmont_pagserv
							from  mi_opventanilla
							where fecha = pfecha and sucursal = Psucursal
							
								RETURN  cod_ret,Vfecha, Vsucursal,Vcajero, Vtpo_reg , Vnombre, Vnum_depcap, Vmont_depcap, Vnum_retcap, Vmont_retcap, 
								   Vnum_pagcred, Vmont_pagcred, Vnum_dispcred, Vmont_dispcred, Vnum_pagserv, Vmont_pagserv WITH RESUME;
								   
								let contador = contador + 1;   
						
						end foreach
						
					ELSE
								
								LET cod_ret = '00007';
								LET Vnombre = 'NO EXISTE INFORMACION DE OPERACIONES EN VENTANILLA';
							
								RETURN  cod_ret,Vfecha, Vsucursal,Vcajero, Vtpo_reg , Vnombre, Vnum_depcap, Vmont_depcap, Vnum_retcap, Vmont_retcap, 
								   Vnum_pagcred, Vmont_pagcred, Vnum_dispcred, Vmont_dispcred, Vnum_pagserv, Vmont_pagserv;								
							
					END if
						
				ELif pfecha < dMaxFecha THEN
			
					IF (SELECT COUNT(*) FROM mi_his_opventanilla where fecha = pfecha and sucursal = Psucursal ) > 0 THEN
			
						foreach
							select SKIP siRegistros  FIRST 10 fecha, sucursal, tpo_reg ,cajero, nombre, num_depcap, mont_depcap, num_retcap, mont_retcap, 
								   num_pagcred, mont_pagcred, num_dispcred, mont_dispcred, num_pagserv, mont_pagserv
							INTO  Vfecha, Vsucursal, Vtpo_reg ,Vcajero, Vnombre, Vnum_depcap, Vmont_depcap, Vnum_retcap, Vmont_retcap, 
								   Vnum_pagcred, Vmont_pagcred, Vnum_dispcred, Vmont_dispcred, Vnum_pagserv, Vmont_pagserv
							from  mi_his_opventanilla
							where fecha = pfecha and sucursal = Psucursal
							
								RETURN  cod_ret,Vfecha, Vsucursal, Vcajero, Vtpo_reg , Vnombre, Vnum_depcap, Vmont_depcap, Vnum_retcap, Vmont_retcap, 
								   Vnum_pagcred, Vmont_pagcred, Vnum_dispcred, Vmont_dispcred, Vnum_pagserv, Vmont_pagserv WITH RESUME;
								   
								let contador = contador + 1;    
																		
						end foreach
						
					ELSE
								
								LET cod_ret = '00007';
								LET Vnombre = 'NO EXISTE INFORMACION DE OPERACIONES EN VENTANILLA';
							
								RETURN  cod_ret,Vfecha, Vsucursal,Vcajero, Vtpo_reg , Vnombre, Vnum_depcap, Vmont_depcap, Vnum_retcap, Vmont_retcap, 
								   Vnum_pagcred, Vmont_pagcred, Vnum_dispcred, Vmont_dispcred, Vnum_pagserv, Vmont_pagserv;								
							
					END IF
					
				ELSE 
				
						RETURN '00005',vFecha,vSucursal,vtpo_reg,vcajero,'No existe información del reporte del cierre diario de la sucursal',Vnum_depcap, 
						Vmont_depcap, Vnum_retcap, Vmont_retcap, Vnum_pagcred, Vmont_pagcred, Vnum_dispcred, Vmont_dispcred, Vnum_pagserv, Vmont_pagserv;
					
					
			
			end if
			
			ELSE
			
				RETURN '00006',vFecha,vSucursal,vtpo_reg,vcajero,'tipo de usuario no valido',Vnum_depcap, 
						Vmont_depcap, Vnum_retcap, Vmont_retcap, Vnum_pagcred, Vmont_pagcred, Vnum_dispcred, Vmont_dispcred, Vnum_pagserv, Vmont_pagserv;							
		end if	

	ELIF (v_sEstatus = '') OR (v_sEstatus IS NULL) THEN
        LET cod_ret = '00002';
		LET vNombre = 'Parámetro de servicio no establecido';
    ELSE
		LET cod_ret = '00003';
		LET vNombre = 'Servicio no disponible';
	END IF;
	
	IF  cod_ret <> '00000' THEN
	
		RETURN cod_ret,Vfecha, Vsucursal, Vcajero, Vtpo_reg , Vnombre, Vnum_depcap, Vmont_depcap, Vnum_retcap, Vmont_retcap, 
							   Vnum_pagcred, Vmont_pagcred, Vnum_dispcred, Vmont_dispcred, Vnum_pagserv, Vmont_pagserv;
	
	END IF

END 
END PROCEDURE;