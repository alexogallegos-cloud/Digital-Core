CREATE PROCEDURE "informix".sp_co_selfaltantes(pempresa char(3),pfecha date) 
RETURNING CHAR(5),CHAR(4),CHAR(4),CHAR(8),CHAR(8),CHAR(14),
          DATE,DATE,DATE,INTEGER,INTEGER,CHAR(4),CHAR(4),MONEY(14,2),MONEY(14,2),CHAR(30);

	DEFINE vCodRet       	  CHAR(5);
	DEFINE vproducto     	  CHAR(4);
	DEFINE vtransacc     	  CHAR(4);
	DEFINE vusuario_sus  	  CHAR(8);
	DEFINE vusuario_fin  	  CHAR(8);
	DEFINE vccontable    	  CHAR(14);
	DEFINE vfecha_valida 	  DATE;
	DEFINE vfecha_captura_sus DATE;
	DEFINE vfecha_captura_fin DATE;
	DEFINE vcontrol_poliza_sus INTEGER;
	DEFINE vcontrol_poliza_fin INTEGER;
	DEFINE vsuccta 			  CHAR(4);
	DEFINE vsucursal 		  CHAR(4);
	DEFINE vtot_cargo 		  MONEY(14,2);
	DEFINE vtot_abono 		  MONEY(14,2);
	DEFINE vdescripcion 	  CHAR(30);
 
	LET vCodRet            = "000";
	
	LET vproducto          = "";
	LET vtransacc     	   = "";
	LET vusuario_sus  	   = "";
	LET vusuario_fin  	   = "";
	LET vccontable    	   = "";
	LET vfecha_valida 	   = TODAY;
	LET vfecha_captura_sus = TODAY;
	LET vfecha_captura_fin = TODAY;
	LET vcontrol_poliza_sus = 0;
	LET vcontrol_poliza_fin = 0;
	LET vsuccta 		   = "";
	LET vsucursal 		   = "";
	LET vtot_cargo 		   =0;
	LET vtot_abono 		   =0;
	LET vdescripcion 	   = "";

		
	-- SET DEBUG FILE TO "sp_co_selfaltantes.out";
	-- TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

    FOREACH
		SELECT producto,transacc,NVL(usuario_sus,''),NVL(usuario_fin,''),  
               TRIM(ccmayor)||TRIM(ccsub)||TRIM(ccsubsub)||TRIM(ccssubsub)||TRIM(ccsssubsub)||TRIM(sector),
			   NVL(fecha_valida,''), NVL(fecha_captura_sus,''), NVL(fecha_captura_fin,''),
			   control_poliza_sus,control_poliza_fin,
			   succta,sucursal,tot_cargo,tot_abono,descripcion
		  INTO vproducto,vtransacc,vusuario_sus,vusuario_fin,vccontable,vfecha_valida,vfecha_captura_sus,
	           vfecha_captura_fin,vcontrol_poliza_sus,vcontrol_poliza_fin,
			   vsuccta,vsucursal,vtot_cargo,vtot_abono,vdescripcion
		  FROM bdicheq:sc_suspenso
		 WHERE fecha_valida = pfecha
		 ORDER BY idsc_suspenso ASC

             RETURN  vCodRet,vproducto,vtransacc,vusuario_sus,vusuario_fin,vccontable,vfecha_valida,vfecha_captura_sus,
	                 vfecha_captura_fin,vcontrol_poliza_sus,vcontrol_poliza_fin,
			         vsuccta,vsucursal,vtot_cargo,vtot_abono,vdescripcion WITH RESUME;
			   
     END FOREACH;

	FOREACH
		SELECT producto,transacc,NVL(usuario_sus,''),NVL(usuario_fin,''),  
               TRIM(ccmayor)||TRIM(ccsub)||TRIM(ccsubsub)||TRIM(ccssubsub)||TRIM(ccsssubsub)||TRIM(sector),
			   NVL(fecha_valida,''), NVL(fecha_captura_sus,''), NVL(fecha_captura_fin,''),
			   control_poliza_sus,control_poliza_fin,
			   succta,sucursal,tot_cargo,tot_abono,descripcion
		  INTO vproducto,vtransacc,vusuario_sus,vusuario_fin,vccontable,vfecha_valida,vfecha_captura_sus,
	           vfecha_captura_fin,vcontrol_poliza_sus,vcontrol_poliza_fin,
			   vsuccta,vsucursal,vtot_cargo,vtot_abono,vdescripcion
		  FROM bdinvers:sv_suspenso
		 WHERE fecha_valida = pfecha
		 ORDER BY idsv_suspenso ASC

             RETURN  vCodRet,vproducto,vtransacc,vusuario_sus,vusuario_fin,vccontable,vfecha_valida,vfecha_captura_sus,
	                 vfecha_captura_fin,vcontrol_poliza_sus,vcontrol_poliza_fin,
			         vsuccta,vsucursal,vtot_cargo,vtot_abono,vdescripcion WITH RESUME;
			   
     END FOREACH;

END PROCEDURE;