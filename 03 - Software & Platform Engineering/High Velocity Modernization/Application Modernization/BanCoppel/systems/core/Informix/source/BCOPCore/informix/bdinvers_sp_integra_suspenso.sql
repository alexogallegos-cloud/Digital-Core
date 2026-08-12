CREATE PROCEDURE "informix".sp_integra_suspenso(pempresa CHAR(3),psistema CHAR(2),pfecha DATE)
    RETURNING CHAR(5);

    DEFINE GLOBAL vgcodigo_mn           CHAR(2)     DEFAULT ' ';
    DEFINE GLOBAL vg_sistema            CHAR(2)     DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_t1         CHAR(4)     DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_t2         CHAR(4)     DEFAULT ' ';
    DEFINE GLOBAL vgcta_iva             CHAR(20)    DEFAULT ' ';
    DEFINE GLOBAL vgcta_itr             CHAR(20)    DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_corresp    CHAR(4)     DEFAULT ' ';
    
    DEFINE vcodret          CHAR(5);
    DEFINE vsqlerr          INTEGER;
	DEFINE vfecha_valida    DATE;

	DEFINE vidsv_suspenso   INTEGER; 
    DEFINE vsecuencia       INTEGER;
    DEFINE vsucursal 		CHAR(4);
    DEFINE vsuccta 			CHAR(4);
	DEFINE vcancelad 		CHAR(1);
    DEFINE vccmayor 		CHAR(10);
    DEFINE vccsub 			CHAR(10);
    DEFINE vccsubsub 		CHAR(10);
    DEFINE vccssubsub 		CHAR(10);
    DEFINE vccsssubsub 		CHAR(10);
    DEFINE vsector 			CHAR(10);
    DEFINE vauxiliar 		CHAR(9);
    DEFINE vproducto 		CHAR(4);
    DEFINE vtransacc 		CHAR(4);
	DEFINE vsectorca 		CHAR(2);
	
    DEFINE vtot_cargo 		MONEY(14,2);
    DEFINE vtot_abono 		MONEY(14,2);
	DEFINE vmonto_tot       MONEY(14,2);
    DEFINE vmoneda 			CHAR(2);
    DEFINE vdescripcion 	CHAR(30);
	
    DEFINE vc_ccmayor        CHAR(4);
    DEFINE vc_ccsub          CHAR(2);
    DEFINE vc_ccsubsub       CHAR(2);
    DEFINE vc_ccsssub        CHAR(2);
    DEFINE vc_ccssssub       CHAR(2);
    DEFINE vc_sector         CHAR(2);
    DEFINE va_ccmayor        CHAR(4);
    DEFINE va_ccsub          CHAR(2);
    DEFINE va_ccsubsub       CHAR(2);
    DEFINE va_ccsssub        CHAR(2);
    DEFINE va_ccssssub       CHAR(2);
    DEFINE va_sector         CHAR(2);
	
    DEFINE vpsucursal 		 CHAR(4);
    DEFINE vpsuccta 		 CHAR(4);
	
	DEFINE vpccmayor         CHAR(4);
    DEFINE vpccsub           CHAR(2);
    DEFINE vpccsubsub        CHAR(2);
    DEFINE vpccssubsub       CHAR(2);
    DEFINE vpccsssubsub      CHAR(2);
    DEFINE vpsector          CHAR(2);
	
	DEFINE vpauxiliar 		  CHAR(9);
	DEFINE vptot_cargo 		  MONEY(14,2);
    DEFINE vptot_abono 		  MONEY(14,2);
    DEFINE vpmoneda 		  CHAR(2);
    DEFINE vpdescripcion 	  CHAR(30);
	DEFINE vpciudad           CHAR(3);
	DEFINE vusuario 		  CHAR(8);
	DEFINE vfecha_hoy         DATE;
	DEFINE vpsecuencia        INTEGER;
	DEFINE vaplicapasecap     BOOLEAN;
	DEFINE vmca_aplic 	      CHAR(1);
	
	BEGIN 
	
	ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            RETURN vcodret ;
        END IF;
    END EXCEPTION;

	--set debug file to "sp_integra_suspenso.out";
    --trace on;

    LET vcodret  = '000';
	LET vfecha_valida = NULL;

	LET vidsv_suspenso = 0;
	LET vproducto = '';
	LET vtransacc = '';
	LET vsectorca = '';
	LET vsecuencia = '';
	
	LET vc_ccmayor        = ' ';
    LET vc_ccsub          = ' ';
    LET vc_ccsubsub       = ' ';
    LET vc_ccsssub        = ' ';
    LET vc_ccssssub       = ' ';
    LET vc_sector         = ' ';
    LET va_ccmayor        = ' ';
    LET va_ccsub          = ' ';
    LET va_ccsubsub       = ' ';
    LET va_ccsssub        = ' ';
    LET va_ccssssub       = ' ';
    LET va_sector         = ' ';

	LET vusuario 		  = ' ';
	LET vpsucursal 	      = ' ';
	LET vpsuccta 	      = ' ';

	LET vpccmayor         = ' ';
	LET vpccsub           = ' ';
	LET vpccsubsub        = ' ';
	LET vpccssubsub       = ' ';
	LET vpccsssubsub      = ' ';
	LET vpsector          = ' ';
	LET vpauxiliar 	      = ' ';
	LET vptot_cargo 	  = 0;
	LET vptot_abono 	  = 0;
	LET vmonto_tot        = 0;
	LET vpmoneda 	      = ' ';
	LET vpdescripcion     = ' ';
	LET vpciudad          = ' ';
	LET vpsecuencia       = 0;
	
	LET vaplicapasecap    = 'f';
	LET vmca_aplic        = "0";
	
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF psistema='03' THEN

		IF EXISTS( SELECT COUNT(fecha_valida) FROM bdinvers:sv_suspenso WHERE fecha_captura_fin = pfecha ) THEN
			UPDATE bdinvers:sv_suspenso 
			   SET fecha_captura_fin = null
			 WHERE fecha_captura_fin = pfecha;
		END IF
		
		SELECT MIN(fecha_valida) INTO vfecha_valida FROM bdinvers:sv_suspenso WHERE fecha_captura_fin IS NULL;
		
		IF vfecha_valida IS NULL THEN
			
			RETURN vcodret;
			
		ELSE
		
			UPDATE bdinvers:sv_suspenso 
			   SET (usuario_sus, control_poliza_sus,fecha_captura_sus) = 
		           ((SELECT usuario,control_poliza,fecha_captura 
				       FROM bdicont:co_poliza 
					  WHERE empresa = pempresa
					    AND usuario='invinfor'
						AND control_poliza > 0 
						AND fecha_captura = pfecha
						AND moneda IS NOT NULL))
			 WHERE fecha_valida = pfecha;
			 
		END IF
		
		TRUNCATE bdinvers:sv_contab;
        TRUNCATE bdinvers:aux_auditerr;
	
		FOREACH
			SELECT idsv_suspenso,secuencia,sucursal,succta,cancelad,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector,auxiliar,producto,transacc,sectorca,tot_cargo,tot_abono,moneda,descripcion
			  INTO vidsv_suspenso,vsecuencia,vsucursal,vsuccta,vcancelad,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,vsector,vauxiliar,vproducto,vtransacc,vsectorca,vtot_cargo,vtot_abono,vmoneda,vdescripcion
			  FROM bdinvers:sv_suspenso
			 WHERE fecha_valida = vfecha_valida
			 ORDER BY idsv_suspenso ASC

				SELECT c_ccmayor, c_ccsub, c_ccsubsub, c_ccsssub, c_ccssssub, c_sector,
					   a_ccmayor, a_ccsub, a_ccsubsub, a_ccsssub, a_ccssssub, a_sector
				  INTO vc_ccmayor, vc_ccsub, vc_ccsubsub, vc_ccsssub, vc_ccssssub, vc_sector,
					   va_ccmayor, va_ccsub, va_ccsubsub, va_ccsssub, va_ccssssub, va_sector
				  FROM bdinteg:si_prodtran
				 WHERE empresa = pempresa 
				   AND producto = vproducto 
				   AND sistema = psistema 
				   AND transaccion = vtransacc 
				   AND secuencia = vsecuencia;
				   
					IF (vc_ccmayor =' '  OR vc_ccmayor IS NULL) AND (va_ccmayor = ' ' OR va_ccmayor IS NULL) THEN
						CONTINUE FOREACH;
					END IF
					
					IF vtot_cargo <> 0 THEN -- cancelacion de poliza suspenso

						INSERT INTO bdinvers:sv_contab VALUES (pempresa, vsecuencia, vsucursal, vsuccta, vccmayor,vccsub,vccsubsub,
															  vccssubsub,vccsssubsub,vsector,vauxiliar,0,vtot_cargo,
															  vmoneda,vdescripcion) ; 
															  
															  
					ELSE

						INSERT INTO bdinvers:sv_contab VALUES (pempresa, vsecuencia, vsucursal, vsuccta, vccmayor,vccsub,vccsubsub,
															  vccssubsub,vccsssubsub,vsector,vauxiliar,vtot_abono,0,
														      vmoneda,vdescripcion) ; 
					END IF

					LET vaplicapasecap = 't';
					
					IF vtot_cargo <> 0 THEN
						LET vmonto_tot = vtot_cargo;

						CALL extrae_cont(pempresa,vsecuencia,vmonto_tot,vsucursal,vproducto,vmoneda,vtransacc,vsectorca,vcancelad,vsuccta,vdescripcion,'99','99') 
						RETURNING vcodret;
						
						IF vcodret <> "000" THEN 
							RETURN vcodret;
						END IF
						
					END IF

		END FOREACH

		IF vaplicapasecap = 't' THEN
		
		    CALL auditor(pempresa) RETURNING vcodret;
		
			IF vcodret = "000" THEN 
		
				LET vusuario = "ctassuin";
			    CALL pasecont(pempresa,pfecha,vfecha_valida,vusuario) RETURNING vcodret;
				
				IF vcodret = "000" THEN 
				
					UPDATE bdinvers:sv_suspenso 
					   SET (usuario_fin, control_poliza_fin,fecha_captura_fin) = 
		                   ((SELECT usuario,control_poliza,fecha_captura 
							   FROM bdicont:co_poliza 
							  WHERE empresa = pempresa
					            AND usuario='ctassuin'
						        AND control_poliza > 0 
						        AND fecha_captura = pfecha
						        AND moneda IS NOT NULL))
			        WHERE fecha_valida = vfecha_valida;

				END IF
			
			END IF

			END IF
		
	END IF
	
    RETURN vcodret;

    END;

END PROCEDURE;