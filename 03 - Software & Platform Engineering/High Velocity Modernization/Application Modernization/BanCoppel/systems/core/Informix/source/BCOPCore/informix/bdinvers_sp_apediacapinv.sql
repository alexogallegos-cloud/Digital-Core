CREATE PROCEDURE "informix".sp_apediacapinv(vfecha DATE)
RETURNING CHAR(5);
   
	DEFINE sql_err          			INTEGER;   
    DEFINE vfec_a_cargar                DATE;
    DEFINE vmaxfecha_cargada            DATE;
    DEFINE vflagfinalizado              char(2);
    DEFINE vf_a_cargada                 DATE;
    DEFINE vf_a_cargar                  DATE;
	DEFINE vcodret     					char(5);
	DEFINE vsqlerr     					integer;	
	DEFINE error_info                   CHAR(40);
    DEFINE isam_err                     SMALLINT;   
    DEFINE vflagpaso                    SMALLINT;   
	DEFINE vtipo_transacc    			CHAR(5);
    DEFINE vcuenta                      CHAR(20);
	DEFINE vnum_cte                     CHAR(20);
	DEFINE vcod_instrum                 CHAR(4);
	DEFINE vstatus_cta                  CHAR(1);
	DEFINE vfechaAnt					DATE;
	DEFINE vfecha_alta                  DATE;
	DEFINE vsucursal                    CHAR(4);
	DEFINE vpromotor                    CHAR(8);
	DEFINE vmoneda                      CHAR(2);
	DEFINE vplazo                       SMALLINT;
	DEFINE vfecha_venc                  DATE;
    DEFINE vempresa                     CHAR(3);
	DEFINE vfecha_carga                 DATE;
	DEFINE vcontador                    INTEGER;
	DEFINE vgenerico1                   CHAR(40);
	DEFINE vgenerico2                   CHAR(40);
	DEFINE vgenerico3                   CHAR(40);
	DEFINE vcargado                     INTEGER;
    DEFINE vf_fechafin                  DATETIME YEAR TO SECOND;
    DEFINE vf_fechaini                  DATETIME YEAR TO SECOND;
    DEFINE vnom_proceso                 CHAR(40);
    DEFINE vnum_proceso                 INTEGER;
	DEFINE vfecha_ant       			CHAR(10);
	DEFINE vdia             			CHAR(2);
    DEFINE vmes             			CHAR(2);
    DEFINE vanio            			CHAR(4);
	DEFINE vfechades        			CHAR(8);	
	DEFINE vRuta						CHAR(400);
	DEFINE desc_err         			CHAR(50);
	DEFINE vcodret1         			CHAR(5);
    DEFINE vcodret2         			CHAR(5);
    DEFINE vcodret3         			CHAR(50);
	DEFINE ven_transacc     			SMALLINT; 
	DEFINE vcontar        				INTEGER;
    DEFINE vsql             			CHAR(400);
	DEFINE vstmt            			CHAR(200);
	
	LET vstmt 			 = '';
	LET vsql 			 = '';
	LET ven_transacc     = 0;
    LET vcodret1         = '00000';
    LET vcodret2         = '00000';
    LET vcodret3         = '';
	LET vcontar     	 = 0;
	LET vempresa 		 = '001';
    LET vflagpaso 		 = 0;
	LET vcodret 		 = '00000';	
	LET vfec_a_cargar 	 = TODAY-1; --Rrg
    LET vcargado 		 = 0;
    LET vsqlerr 		 = 0;
    LET isam_err 		 = 0;
    LET vnum_proceso 	 = 1;
	LET vfechaAnt 		 = vfecha-1;
	LET sql_err	         = 0;
	LET desc_err      	 = '';
   
   
	
BEGIN
     ON EXCEPTION SET sql_err--, isam_err, desc_err
     --   SET DEBUG FILE TO "/resplogifx/conciliachq/sp_apediacapinv.err";
     --   TRACE ON;
    
    IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1;        END IF;
    END EXCEPTION;
	
	--SET DEBUG FILE TO "/resplogifx/conciliachq/sp_apediacapinv1.out";
    --TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'aperdiariascaptinv') THEN
        DROP TABLE bdinvers:"informix".aperdiariascaptinv;
    END IF;
	
	CREATE TABLE bdinvers:"informix".aperdiariascaptinv
		(
		tipo_transacc CHAR(20), 
		cuenta CHAR(20), 
		num_cte CHAR(20), 
		producto CHAR(4) , 
		status_cta CHAR(4), 
		fecha_alta CHAR(10), 
		sucursal CHAR (4),
		promotor CHAR(10), 
		moneda CHAR(4),
		plazo CHAR(5) , 
		fec_ulmovcan CHAR(10), 
		empresa CHAR(4), 
		fecha_carga CHAR(10)
		)
	EXTENT SIZE 3200 NEXT SIZE 320 LOCK MODE ROW;
---Ctas de inversión producto 3000 con status diferente a 2	
  FOREACH WITH HOLD
	SELECT '99999' AS tipo_transacc, inv.cuenta, inv.num_cte, inv.cod_instrum, 
                    inv.status_cta, inv.fecha_alta, inv.sucursal, inv.promotor, instr.moneda, 
                    inv.plazo, nvl(fec_ult_mov, inv.fec_cancelac) as fecha_venc  ,inv.empresa, vfecha AS fecha_carga
                    
					INTO
                    vtipo_transacc, vcuenta, vnum_cte, vcod_instrum, 
                    vstatus_cta, vfecha_alta, vsucursal, vpromotor, vmoneda, 
                    vplazo, vfecha_venc, vempresa, vfecha_carga
    
					FROM  bdinvers:sv_maeinv inv, 
                          bdinvers:sv_instrum instr
                    WHERE inv.cod_instrum = instr.cod_instrum 
                    AND inv.fecha_alta = vfechaAnt
                    AND inv.secuencia = (SELECT max(secuencia) 
                                              FROM bdinvers:sv_maeinv a
                                              WHERE a.empresa = vempresa
                                              AND a.cuenta = inv.cuenta
                                              AND a.secuencia <> 0)
                    AND inv.status_cta <> 2
                    GROUP BY inv.cuenta, inv.num_cte, inv.cod_instrum, 
                    inv.status_cta, inv.fecha_alta, inv.sucursal, inv.promotor, instr.moneda, 
                    inv.plazo, 11,inv.empresa
					
	INSERT INTO bdinvers:aperdiariascaptinv 
					VALUES (vtipo_transacc, vcuenta, vnum_cte, vcod_instrum, 
                            vstatus_cta, vfecha_alta, vsucursal, vpromotor, vmoneda, 
                            vplazo, vfecha_venc, vempresa, vfecha_carga);		
  END FOREACH;		
---Ctas de inversión producto 3000 con status 2		
  FOREACH WITH HOLD
	SELECT '99999' AS tipo_transacc, inv.cuenta, inv.num_cte, inv.cod_instrum, 
                    inv.status_cta, inv.fec_cancelac, inv.sucursal, inv.promotor, instr.moneda, 
                    inv.plazo, nvl(fec_ult_mov, inv.fec_cancelac) as fecha_venc ,inv.empresa, vfecha AS fecha_carga
                    
					INTO
                    vtipo_transacc, vcuenta, vnum_cte, vcod_instrum, 
                    vstatus_cta, vfecha_alta, vsucursal, vpromotor, vmoneda, 
                    vplazo, vfecha_venc, vempresa, vfecha_carga
                    
					FROM  bdinvers:sv_maeinv inv, 
                          bdinvers:sv_instrum instr
                    WHERE inv.cod_instrum = instr.cod_instrum 
                    AND inv.fec_cancelac = vfechaAnt
                    AND inv.secuencia = (SELECT max(secuencia) 
                                            FROM bdinvers:sv_maeinv a
                                            WHERE a.empresa = vempresa
                                            AND a.cuenta = inv.cuenta
                                            AND a.secuencia <> 0)
                    AND inv.status_cta = 2
                    GROUP BY inv.cuenta, inv.num_cte, inv.cod_instrum, 
                    inv.status_cta, inv.fec_cancelac, inv.sucursal, inv.promotor, instr.moneda, 
                    inv.plazo, 11,inv.empresa
	
INSERT INTO bdinvers:aperdiariascaptinv 
					VALUES (vtipo_transacc, vcuenta, vnum_cte, vcod_instrum, 
                            vstatus_cta, vfecha_alta, vsucursal, vpromotor, vmoneda, 
                            vplazo, vfecha_venc, vempresa, vfecha_carga);			

LET vcontar = vcontar + 1;
							
  END FOREACH;
  
  CREATE INDEX "informix".idx_apediacapinv ON bdinvers:"informix".aperdiariascaptinv(cuenta) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE aperdiariascaptinv;
	
	LET vfechaAnt = vfechaAnt;
    LET vdia  = SUBSTR(vfechaAnt, 4, 2);
    LET vmes  = SUBSTR(vfechaAnt, 1, 2);
    LET vanio = SUBSTR(vfechaAnt, 7, 4);
    LET vdia  = TRIM(vdia);
    LET vmes  = TRIM(vmes);
    LET vanio = TRIM(vanio);
    LET vfechades = vmes||vdia||vanio;
 
    LET vsql = 'echo "set isolation to dirty read; unload to /resplogifx/conciliachq/apediacapinv_'||vfechades||'.txt '||
               ' select * from aperdiariascaptinv order by sucursal, producto, cuenta;" > /resplogifx/conciliachq/apediacapinv.sql';
    SYSTEM TRIM(vsql);
    LET vsql = '';
    		
    LET vstmt = '/ifxsif01/bin/dbaccess bdinvers /resplogifx/conciliachq/apediacapinv.sql'; 
	SYSTEM SUBSTR(vstmt,1,LENGTH(vstmt));
	
	LET vsql = "";
	LET vsql = 'rm /resplogifx/conciliachq/apediacapinv.sql'; 
	system vsql;

	 END;
    
     RETURN vcodret1;    
END PROCEDURE;