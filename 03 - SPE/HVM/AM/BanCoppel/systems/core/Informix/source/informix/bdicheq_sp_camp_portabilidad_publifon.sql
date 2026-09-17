CREATE PROCEDURE "informix".sp_camp_portabilidad_publifon (p_empresa char(3))
RETURNING   CHAR(5);

DEFINE v_c_vcomienza    SMALLINT;
DEFINE ven_transacc     SMALLINT;
DEFINE v_c_vcontador    INTEGER;
DEFINE v_monto_tot      DECIMAL(18,2);
DEFINE vult_mes_ant     DATE;
DEFINE vult_mes_ant1    CHAR(8);
DEFINE vpri_mes_ant     DATE; 
DEFINE vpri_mes_ant1    CHAR(8);
DEFINE vsqlerr          INTEGER;
DEFINE vcodret          CHAR(5);
DEFINE v_cantidad       INTEGER; 
DEFINE v_sucursal       CHAR(4);
DEFINE v_cuenta         CHAR(20);
DEFINE v_cliente        CHAR(20);  
DEFINE v_nombre         CHAR(50);
DEFINE v_apellido       CHAR(50);
DEFINE v_tel_cel        CHAR(13);	
DEFINE v_correo         CHAR(100);
DEFINE v_fecha_activa   CHAR(8);
DEFINE vsql             CHAR(500);
DEFINE v_fecha_arch     CHAR(8);
DEFINE v_fecha_hoy      DATE; 

	
LET vsqlerr             = 0; 
LET vcodret             = "00000";
LET v_c_vcomienza       = -1;
LET ven_transacc        = 0;
LET v_c_vcontador       = 0;
LET v_cantidad          = 0;
LET vsql                = '';

BEGIN
	 ON EXCEPTION SET vsqlerr
        SET DEBUG FILE TO "/resplogifx/conciliachq/camp_portabilidad_publifon.err";
	 	    TRACE ON;
            IF vsqlerr <> 0 THEN
               LET vcodret = vsqlerr;
			   IF ven_transacc = 1 THEN
                  ROLLBACK WORK;
               END IF;
            RETURN vcodret;
            END IF;
     END EXCEPTION;
	
     --SET   DEBUG FILE TO '/RESPALDOSNEW/camp_portabilidad_publifon.txt';
	 --TRACE ON;
	
	   SET ISOLATION TO DIRTY READ;
	SELECT  DATE(pri_dia_mes - 1 UNITS MONTH), DATE(pri_dia_mes - 1  UNITS DAY) , fecha_hoy 
	  INTO  vpri_mes_ant                     , vult_mes_ant                     , v_fecha_hoy
      FROM sc_fechas
     WHERE empresa = p_empresa;
	 
	 LET vpri_mes_ant1 = to_char(vpri_mes_ant, '%Y%m%d');
	 LET vult_mes_ant1 = to_char(vult_mes_ant, '%Y%m%d');
	 	
	 -- // MOVIMIENTOS DE PAGO DE INTERESES DEL SISTEMA DE CHEQUES
	 
    CREATE TABLE tmp_portabilidad(
           sucursal       CHAR(4)  ,
           cuenta         CHAR(20) ,
           cliente        CHAR(20) ,  
           nombre         CHAR(50) ,
           apellido       CHAR(50) ,
           tel_cel        CHAR(13) ,	
           correo         CHAR(100),
           fecha_activa   CHAR(8));
  --  EXTENT SIZE 1000 NEXT SIZE 100 LOCK MODE ROW;
	 		
   FOREACH WITH HOLD

           SELECT a.sucursal, a.cuenta, a.num_cte, TRIM(c.nombre1) AS nombre, TRIM(c.apell_paterno) AS apellido, d.telefono, e.correo_elec, b.fecha_estatus_portabilidad
			 INTO v_sucursal, v_cuenta, v_cliente,                  v_nombre,                        v_apellido,  v_tel_cel,      v_correo,               v_fecha_activa
			 FROM bdicheq:sc_maechq                      AS a
            INNER JOIN bdicheq:sc_portacec_solicitud     AS b ON (b.num_cte = a.num_cte AND b.cta_receptora  = a.cuenta_clabe)
			INNER JOIN bdinteg:si_cliente                AS c ON (c.numcte  = b.num_cte )
             LEFT OUTER JOIN bdinteg:si_telefonos_actual AS d ON (d.numcte  = b.num_cte AND  d.tipo_tel = 2)
             LEFT OUTER JOIN bdinteg:si_correos          AS e ON (e.numcte  = b.num_cte AND e.tipo_correo = 1 and e.status_correo = 'A')
            WHERE a.empresa = p_empresa
              AND a.producto IN ('2000','1900','2500','1400')
         ---  AND b.fecha_solicitud  BETWEEN  vpri_mes_ant1 AND vult_mes_ant1
              AND b.estatus_portabilidad = 1
              AND b.fecha_estatus_portabilidad BETWEEN vpri_mes_ant1 AND vult_mes_ant1 
				 
		       -- Abre la transaccion 
		       IF (v_c_vcomienza = -1) THEN
                  LET v_c_vcomienza = 0;
                  LET ven_transacc = 1;
                  BEGIN WORK;
              END IF;
		
		   INSERT INTO tmp_portabilidad VALUES (v_sucursal,v_cuenta,v_cliente,v_nombre,v_apellido,v_tel_cel,v_correo,v_fecha_activa);
			  
			  LET v_c_vcontador = v_c_vcontador + 1;
			      --Realiza commit cada 1000 registros 
			   IF (v_c_vcontador >= 1000) THEN
                  LET v_c_vcontador = 0;
                  COMMIT WORK;
                  BEGIN WORK;
              END IF; 
   END FOREACH;
	    
		--Si la transaccion esta abierta realiza el commit
	    IF  ven_transacc = 1 THEN
            LET ven_transacc = 0;
            COMMIT WORK;
        END IF;
		
		LET v_fecha_arch = to_char (v_fecha_hoy,'%d%m%YY');
		
		LET vsql = '';
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
			       'UNLOAD TO /RESPALDOSNEW/Porta_Publifon'||v_fecha_arch||'.txt '||
		           'SELECT * FROM tmp_portabilidad" > /resplogifx/conciliachq/porta.sql';
	    SYSTEM vsql; 
	
	    --/EJECUCION DEL ARCHIVO .SQL 
        LET vsql = '';
        LET vsql = "dbaccess bdicheq /resplogifx/conciliachq/porta.sql"; 
        SYSTEM vsql;	
        
		BEGIN;
		DROP TABLE tmp_portabilidad;
		COMMIT; 
		
	    --/COMPRIME EL ARCHIVO .SQL 
        LET vsql = '';
        LET vsql = '/usr/bin/gzip -9 /RESPALDOSNEW/Porta_Publifon'||v_fecha_arch||'.txt'; 
        SYSTEM vsql;
		
							  
RETURN  vcodret;
END; 
END PROCEDURE;