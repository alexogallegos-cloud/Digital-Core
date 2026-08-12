CREATE PROCEDURE "informix".sp_geninfmovscorresp(pempresa CHAR(3))
RETURNING CHAR(5), CHAR(5), CHAR(50);

    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(50);
    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    
    DEFINE vfecha_hoy       DATE;
    DEFINE vfecha_ant       DATE;
    DEFINE vpri_dia_mes     DATE;
    DEFINE vfecha_ini       DATE;
    DEFINE vfecha_ini_ori   DATE; 
    DEFINE vfecha_fin       DATE;
    DEFINE vfechaproc       DATE;
    
    DEFINE vexiste          CHAR(6);
    
    DEFINE vsucursal        CHAR(4);
    DEFINE vfecha           DATE;
    DEFINE vno_transacc     INTEGER;
    DEFINE vmonto_tot       DECIMAL(18,2);
    DEFINE vmonto           DECIMAL(18,2);
    DEFINE vlocalidad       CHAR(12);
    DEFINE vciudad          CHAR(60);
    
    DEFINE vexiste_suc      INTEGER;
    DEFINE vaniomes         CHAR(6);
    DEFINE vsql             CHAR(500);
    

    DEFINE vfecha_ejecucion DATE;
    
	  DEFINE iContReg			INTEGER;
	  DEFINE iExisten_registros	INTEGER;

    DEFINE vMaxFecha DATE; 
    DEFINE vCuenta,vEstatus  INTEGER;
	
    LET sql_err	 = 0;
    LET isam_err = 0;
    LET desc_err = '';
    LET vcodret1 = '000';
    LET vcodret2 = '000';
    LET vcodret3 = '';
    
    LET vfecha_hoy   = ''; 
    LET vfecha_ant   = ''; 
    LET vpri_dia_mes = '';
    LET vfechaproc   = '';
    LET vfecha_ini   = '';
    LET vfecha_ini_ori = '';
    LET vfecha_fin   = '';
    
    LET vexiste  = '';
    
    LET vsucursal    = '';
    LET vfecha       = '';
    LET vno_transacc = 0;
    LET vmonto_tot   = 0.00;
    LET vmonto       = 0.00;
    LET vlocalidad   = '';
    LET vciudad      = '';
    
    LET vexiste_suc = 0;
    LET vaniomes    = '';
    LET vsql        = '';
    

    LET vfecha_ejecucion = '';
    
	LET iContReg = 1;
	
	LET iExisten_registros = 0;
    LET vCuenta = 0;
	LET vEstatus = 0;

    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_geninfmovscorresp.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1, vcodret2, vcodret3;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/ifxsif01/ilopez/PRO_132CalMenCaptGlobban/sp_geninfmovscorresp.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTIENE LAS FECHAS DEL SISTEMA
    SELECT fecha_hoy, fecha_ant, pri_dia_mes
      INTO vfecha_hoy, vfecha_ant, vpri_dia_mes
      FROM sc_fechas
     WHERE empresa = pempresa;
     
    LET vfecha_ini = vpri_dia_mes - 1 UNITS MONTH;
    LET vfecha_fin = vpri_dia_mes - 1 UNITS DAY;

    -- // VERIFICA QUE NO SE HAYA EJECUTADO EL PROCESO PARA ESTE PERIODO
   -- SELECT fecha
   --   INTO vfecha_ejecucion
   --   FROM sc_contproc_corresp
   --  WHERE empresa = pempresa
   --    AND proceso = 'movsxsucursal';
       
   -- IF vfecha_ejecucion >= vpri_dia_mes THEN
   --     LET vcodret1 = '958';
   --     LET vcodret2 = '958';
        
   --     SELECT descripcion
   --       INTO vcodret3
   --       FROM bdinteg:si_codret
   --      WHERE codigo_retorno = '958'
   --        AND sistema = '01';
           
   --     RETURN vcodret1, vcodret2, vcodret3;
   -- END IF;
     
    -- // Verifica se haya efectuado el paso de movs a historico
    SELECT fecha 
      INTO vfechaproc
      FROM sc_contproc
     WHERE empresa = pempresa 
       AND proceso = "pasomovshist"
       AND fecha = vfecha_ant;
       
    IF vfechaproc is null THEN
        LET vcodret1 = '953';
        LET vcodret2 = '953';
        
        SELECT descripcion
          INTO vcodret3
          FROM bdinteg:si_codret
         WHERE codigo_retorno = '953'
           AND sistema = '01';
           
        RETURN vcodret1, vcodret2, vcodret3;
    END IF;
    
    LET vfecha_ini = vfecha_ini;	
	--Si hay Re-run se aplica el delete de registros del periodo------------------
	
	--SELECT COUNT(DISTINCT(fecha)) INTO iExisten_registros FROM bdicheq:sc_movs_corresp WHERE fecha >= vfecha_ini;
    --LET vfecha_ini_ori = vfecha_ini;
	--IF iExisten_registros > 0 THEN 
    --    IF iExisten_registros > 1 THEN  
    --    	SELECT MAX(fecha)
    --    	into vMaxFecha
    --    	from bdicheq:sc_movs_corresp WHERE fecha >= vfecha_ini and fecha <= vfecha_fin;
    --        
	--		LET vfecha_ini = vMaxFecha; 
    --        DELETE FROM bdicheq:sc_movs_corresp where fecha >= vfecha_ini;  
    --    ELSE
	--    	DELETE FROM bdicheq:sc_movs_corresp where fecha >= vfecha_ini;
    --    END IF; 	
    --END IF;
		LET vCuenta = 0;
		LET vfecha_ini_ori = vfecha_ini;
		--VALIDA QUE NO SE HAYA EJECUTADO EL SP EN EL PERIODO
		SELECT COUNT(*),estatus INTO vCuenta,vEstatus FROM sc_control_procesos WHERE proceso='sp_geninfmovscorresp' AND fecha = vpri_dia_mes GROUP BY 2;
		
		IF vCuenta = 0 OR vCuenta IS NULL THEN
           --DETECTA QUE SE EJECUTA EL SP POR PRIMERA VEZ 
		   BEGIN;
		   		INSERT INTO sc_control_procesos VALUES('sp_geninfmovscorresp',vpri_dia_mes,0);
		   COMMIT;	 
		END IF; 
    -- // VERIFICA QUE NO SE HAYA EJECUTADO EL PROCESO PARA ESTE PERIODO
		IF vCuenta = 1 AND vEstatus=1 THEN
		   --DETECTA QUE YA SE HABIA EJECUTADO EL SP EN EL PERIODO Y LO REPROCESA DESDE CERO
		   DELETE FROM bdicheq:sc_movs_corresp where fecha >= vfecha_ini AND fecha <=vfecha_fin;
           BEGIN;
                UPDATE sc_control_procesos SET estatus=0 WHERE proceso='sp_geninfmovscorresp' AND fecha= vpri_dia_mes;
           COMMIT;
        ELSE 
			IF vCuenta = 1 AND vEstatus=0 THEN
		        --DETECTA QUE EL SP NO CONCLUYO EN SU ANTERIOR EJECUCION E INICIA EN EL PUNTO EN EL CUAL SE QUEDO 
				SELECT COUNT(DISTINCT(fecha)) INTO iExisten_registros FROM bdicheq:sc_movs_corresp WHERE fecha >= vfecha_ini;
				--LET vfecha_ini_ori = vfecha_ini;
				IF iExisten_registros > 0 THEN 
				    IF iExisten_registros > 1 THEN  
				    	SELECT MAX(fecha)
				    	into vMaxFecha
				    	from bdicheq:sc_movs_corresp WHERE fecha >= vfecha_ini and fecha <= vfecha_fin;
				        
						LET vfecha_ini = vMaxFecha; 
				        DELETE FROM bdicheq:sc_movs_corresp where fecha >= vfecha_ini AND fecha <=vfecha_fin;  
				    ELSE
				    	DELETE FROM bdicheq:sc_movs_corresp where fecha >= vfecha_ini AND fecha <=vfecha_fin;
				    END IF; 	
				END IF;	
			END IF; 
		END IF; 
		
    ------------------------------------------------------------------------------------------------------------------
    WHILE vfecha_ini<=vfecha_fin 
		LET vsucursal = '';
		LET vfecha = '';
		LET vno_transacc = 0;
		LET vmonto_tot = 0.00;
		LET iContReg = 1;

		FOREACH cursor_reg_sc_movhis WITH HOLD FOR
		
			SELECT 
				  SUBSTR(folio_suc,1,4), fech_alt, COUNT(*), SUM(monto_tot)
			  INTO vsucursal, vfecha, vno_transacc, vmonto_tot
			  FROM sc_movhis
			 WHERE fech_alt = vfecha_ini 
			   AND cancelad <> 'S'
			   AND transacc = '0282'
			GROUP BY 1,2

			SELECT COUNT(*)
			  INTO vexiste_suc
			  FROM sc_movs_corresp
			 WHERE fecha = vfecha
			   AND sucursal = vsucursal;

			IF iContReg=1 THEN
				BEGIN WORK;
			END IF
			
			IF vexiste_suc = 0 THEN
				INSERT INTO sc_movs_corresp(sucursal, no_movs_capt, monto_capt, no_movs_cred, monto_cred, fecha)
				VALUES(vsucursal, vno_transacc, vmonto_tot, 0, 0.00, vfecha);
			ELSE
				UPDATE sc_movs_corresp
				   SET no_movs_capt = vno_transacc,
					   monto_capt = vmonto_tot
				 WHERE fecha = vfecha
				   AND sucursal = vsucursal;
			END IF;
	  
			IF iContReg >= 50 THEN
				COMMIT WORK;
				LET iContReg=1;
								
			ELSE
				LET iContReg = iContReg + 1 ;
			END IF;
					
			LET vsucursal = '';
			LET vfecha = '';
			LET vno_transacc = 0;
			LET vmonto_tot = 0.00;
			CONTINUE FOREACH;
		END FOREACH;
	   
		IF iContReg > 1 THEN
			COMMIT WORK;
		END IF;
		-----------------------------------------------------------------------------------------------------------------------------------------
		LET vsucursal = '';
		LET vfecha = '';
		LET vno_transacc = 0;
		LET vmonto_tot = 0.00;
		LET iContReg = 1;
		
		FOREACH cursor_reg_sd_movhis WITH HOLD FOR
			SELECT SUBSTR(folio_suc,1,4), fecha_mov, COUNT(*), SUM(monto)
			  INTO vsucursal, vfecha, vno_transacc, vmonto_tot
			  FROM bdicred:sd_movhis
			 WHERE codigo_fun = '700'
			   AND codigo_ref = 1
			   AND fecha_mov = vfecha_ini 
			   AND reversado = 'N'
			   AND transacc_suc = '6282'
			 GROUP BY 1,2

			SELECT COUNT(*)
			  INTO vexiste_suc
			  FROM sc_movs_corresp
			 WHERE fecha = vfecha
			   AND sucursal = vsucursal;

			IF iContReg=1 THEN
				BEGIN WORK;
			END IF 
			  
			IF vexiste_suc = 0 THEN
				INSERT INTO sc_movs_corresp(sucursal, no_movs_capt, monto_capt, no_movs_cred, monto_cred, fecha)
				VALUES(vsucursal, 0, 0.00, vno_transacc, vmonto_tot, vfecha);
			ELSE
				UPDATE sc_movs_corresp
				   SET no_movs_cred = vno_transacc,
					   monto_cred = vmonto_tot
				 WHERE fecha = vfecha
				   AND sucursal = vsucursal;
			END IF;
			
			IF iContReg >= 50 THEN
				COMMIT WORK;
				LET iContReg=1;
			ELSE
				LET iContReg = iContReg + 1 ;
			END IF;
			
			LET vsucursal = '';
			LET vfecha = '';
			LET vno_transacc = 0;
			LET vmonto_tot = 0.00;
			CONTINUE FOREACH;
		END FOREACH;
		
		IF iContReg > 1 THEN
			COMMIT WORK;
		END IF;
		LET vfecha_ini = vfecha_ini + 1 UNITS DAY;
	END WHILE;

    LET iContReg = 1;	
    UPDATE STATISTICS MEDIUM FOR TABLE sc_movs_corresp;	
    
    -- // INSERTA LAS CIUDADES DE LAS SUCURSALES
    FOREACH cursor_movs_corresponsales WITH HOLD FOR
        SELECT UNIQUE sucursal
          INTO vsucursal
          FROM sc_movs_corresp
          --WHERE fecha >= vfecha_ini_ori AND fecha<= vfecha_fin
		  
		 
        SELECT LIMIT 1 localidad_inegi
          INTO vlocalidad
          FROM bdirepaut@coppelcont_tcp:"informix".sp_r026_establecimiento  
         WHERE clave = vsucursal
           AND periodo_afectacion = (SELECT MAX(periodo_afectacion) 
                                       FROM bdirepaut@coppelcont_tcp:"informix".sp_r026_establecimiento  
                                      WHERE clave = vsucursal);
           
        SELECT LIMIT 1 ciudad||' '||TRIM(nombre)
          INTO vciudad
          FROM bdinteg:si_ciudades
         WHERE localidad_inegi = vlocalidad;
         
		IF iContReg=1 THEN
			BEGIN WORK;
		END IF
		
       UPDATE sc_movs_corresp
           SET ciudad = vciudad
         WHERE sucursal = vsucursal;
        
		IF iContReg >= 50 THEN
			COMMIT WORK;
			LET iContReg=1;
		ELSE
			LET iContReg = iContReg + 1 ;
		END IF;
		
        LET vsucursal = '';
        LET vlocalidad = '';
        LET vciudad = '';
		CONTINUE FOREACH;
    END FOREACH;
    
	IF iContReg > 1 THEN
		COMMIT WORK;
	END IF;
	
    UPDATE STATISTICS MEDIUM FOR TABLE sc_movs_corresp;
    
    -- // DESCARGA EL ARCHIVO DE INFORMACIï¿½N
    LET vaniomes = TO_CHAR(vfecha_fin, '%Y%m');
    
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/movscorrespxfechasuc_'||vaniomes||'.txt '||
               ----' SELECT ciudad, sucursal, no_movs_capt, monto_capt, no_movs_cred, monto_cred, fecha[4,5]||fecha[1,2]||fecha[9,10]'||
               ' SELECT ciudad, sucursal, no_movs_capt, monto_capt, no_movs_cred, monto_cred, TO_CHAR(fecha, '''||'%d%m%Y'||''')'||
               ' FROM sc_movs_corresp WHERE fecha BETWEEN '''||vfecha_ini_ori||''' AND '''||vfecha_fin||''' ORDER BY fecha, sucursal" > /resplogifx/conciliachq/movtoscorresp.sql';
    SYSTEM vsql;
    
    LET vsql = '';
    --- LET vsql = "dbaccess bdicheq /resplogifx/conciliachq/movtoscorresp.sql"; 
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/movtoscorresp.sql"; 
    SYSTEM vsql;
       
    UPDATE sc_contproc_corresp
       SET fecha = vfecha_hoy
     WHERE empresa = pempresa
       AND proceso = 'movsxsucursal';
       
    LET vcodret3 = 'EL PROCESO SE REALIZO SATISFACTORIAMENTE';

    END;

    IF vCuenta = 1 AND vEstatus=0 THEN
		BEGIN;
          	UPDATE sc_control_procesos SET estatus=1 WHERE proceso='sp_geninfmovscorresp' AND fecha= vpri_dia_mes;
		COMMIT;
    END IF; 
    RETURN vcodret1, vcodret2, vcodret3;

END PROCEDURE;