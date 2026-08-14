CREATE PROCEDURE "informix".pasecheqcomp5(pempresa CHAR(3))
RETURNING CHAR(5);
     
DEFINE GLOBAL vgcodigo_mn           CHAR(2)        DEFAULT ' ';
DEFINE GLOBAL vg_sistema            CHAR(2)        DEFAULT ' ';
DEFINE GLOBAL vgtransacc_t1         CHAR(4)        DEFAULT ' ';
DEFINE GLOBAL vgtransacc_t2         CHAR(4)        DEFAULT ' ';
DEFINE GLOBAL vgcta_iva             CHAR(20)    DEFAULT ' ';
DEFINE GLOBAL vgcta_itr             CHAR(20)    DEFAULT ' ';
DEFINE GLOBAL vgtransacc_corresp    CHAR(4)        DEFAULT ' ';
DEFINE GLOBAL vfecha_hoy            DATE           DEFAULT TODAY;
    
DEFINE vcodret          CHAR(5);
DEFINE vcodret2         CHAR(5);
DEFINE vcodret3         VARCHAR(50);
DEFINE vsqlerr          INTEGER;
DEFINE visamerr         INTEGER;
DEFINE vdescerr         VARCHAR(50);
DEFINE vsucopero        CHAR(4);
DEFINE vproducto        CHAR(4);
DEFINE vmoneda          CHAR(2);
DEFINE vtransacc        CHAR(4);
DEFINE vmonto_tot       MONEY(14,2);
DEFINE vexento_isr      CHAR(1);
DEFINE vsector          CHAR(2);
DEFINE vvaloriza        CHAR(1);
DEFINE vcancelad        CHAR(1);
DEFINE vsuccta          CHAR(4);
DEFINE wabreviatura     VARCHAR(20);
DEFINE wdescripcion     VARCHAR(30);
DEFINE vfechaproc       DATE;
DEFINE vporcentaje      DECIMAL(9,6);
DEFINE vtasa_bruta      DECIMAL(9,6);
DEFINE vsobretasa       DECIMAL(9,6);
DEFINE vtpcambval       DECIMAL(14,6);
DEFINE vmonto1          MONEY(14,2);
DEFINE vmonto2          MONEY(14,2);
DEFINE vdivisa_cambio   CHAR(2);
DEFINE vtranprovint     CHAR(4);
DEFINE vcobraisr        CHAR(1);
DEFINE vexiste          INTEGER;
DEFINE vexistefin       INTEGER;
DEFINE vproceso         VARCHAR(12);
DEFINE vsistema         CHAR(2);
DEFINE vestatusproc     CHAR(1);
DEFINE vusuario         VARCHAR(10);
DEFINE vhora_tc         DATETIME HOUR TO MINUTE;
DEFINE vbintarjeta      CHAR(6);   -- PITDC
DEFINE vsecuencia       INTEGER;   -- PITDC
DEFINE vreferencia      VARCHAR (19); -- PITDC
DEFINE vsql             LVARCHAR(600);
DEFINE vstmt            VARCHAR(250);
DEFINE vcuenta          VARCHAR(20);
DEFINE vsecserv         SMALLINT;
DEFINE vserial_inicial  INTEGER;
DEFINE vserial_final    INTEGER;

LET vcodret             = "00000";
LET vcodret2            = "";
LET vcodret3            = "";
LET vsqlerr             = 0;
LET visamerr            = 0;
LET vdescerr            = "";
LET vsucopero           = "";
LET vproducto           = "";
LET vmoneda             = "";
LET vtransacc           = "";
LET vmonto_tot          = "";
LET vexento_isr         = "";
LET vsector             = "";
LET vvaloriza           = "";
LET vcancelad           = "";
LET vsuccta             = "";
LET wabreviatura        = "";
LET wdescripcion        = "";
LET vfechaproc          = "";
LET vporcentaje         = "";
LET vtasa_bruta         = "";
LET vsobretasa          = "";
LET vtpcambval          = "";
LET vmonto1             = "";
LET vmonto2             = "";
LET vdivisa_cambio      = "";
LET vtranprovint        = "";
LET vcobraisr           = "";
LET vexiste             = 0;
LET vexistefin          = 0;
LET vproceso            = "pasechqcomp5";
LET vsistema            = "01";
LET vestatusproc        = "";
LET vusuario            = USER;
LET vhora_tc            = "";
LET vbintarjeta         = "";   -- PITDC
LET vsecuencia          = 0;   -- PITDC
LET vreferencia         = ""; -- PITDC
LET vsql                = '';
LET vstmt               = '';
LET vcuenta             = "";
LET vsecserv            = 0;
LET vserial_inicial     = 0;
LET vserial_final       = 0;

BEGIN
    
    ON EXCEPTION SET vsqlerr, visamerr, vdescerr
       SET debug FILE TO "/tmp/pasecheqcomp5.out";
       TRACE ON;
       IF vsqlerr <> 0 THEN
          UPDATE bdinteg:sx_contproc 
             SET ejecutivo   = vusuario,
                 status_proc = 'C',
                 codret      = vcodret,
                 hora_fin    = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas WHERE empresa = pempresa)
           WHERE proceso = vproceso
             AND fecha   = vfecha_hoy
             AND sistema = vsistema; 		  		    
          RETURN vcodret;
       END IF;
    END EXCEPTION;

    --SET debug FILE TO "/tmp/pasecheqcomp5.out";
    --TRACE ON;	
	
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- // Asigna la fecha de hoy
    SELECT fecha_ant 
      INTO vfecha_hoy
      FROM bdicheq:sc_fechas
	 WHERE empresa = pempresa;	 
    
    -- // VALIDA SI YA SE EJECUTO EL PROCESO DEL DIA 
    SELECT COUNT(*)
      INTO vexiste
      FROM bdinteg:sx_contproc
     WHERE proceso = vproceso
       AND fecha   = vfecha_hoy
       AND sistema = vsistema;	   

    IF vexiste = 0 THEN
       INSERT INTO bdinteg:sx_contproc (empresa, proceso, fecha, sistema, status_proc, ejecutivo, hora_ini, hora_fin, codret)
       VALUES (pempresa, vproceso, vfecha_hoy, vsistema, 'I', vusuario,
                  (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL); 		   
	   
	   
    ELSE
	   IF NOT EXISTS (SELECT proceso FROM bdinteg:sx_contproc
                       WHERE proceso     = vproceso
                         AND fecha       = vfecha_hoy
                         AND sistema     = vsistema
                         AND status_proc = 'F' ) THEN 				
				
		  UPDATE bdinteg:sx_contproc
             SET ejecutivo   = vusuario,
                 status_proc = 'I',
                 codret      = ' ',
                 hora_ini    = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas WHERE empresa = pempresa)
           WHERE proceso  = vproceso
             AND fecha    = vfecha_hoy
             AND sistema  = vsistema;			  
		  
		  
		  
        ELSE
          LET vcodret = "963";
          UPDATE bdinteg:sx_contproc
             SET ejecutivo   = vusuario,
                 status_proc = 'C',
                 codret      = vcodret,
                 hora_fin    = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas WHERE empresa = pempresa)
           WHERE proceso  = vproceso
             AND fecha    = vfecha_hoy
             AND sistema  = vsistema;			  
		  
		  
        END IF
    END IF;
    
    -- // Verifica se haya iniciado el pase contable principal
    SELECT fecha 
      INTO vfechaproc
      FROM bdicheq:sc_contproc
     WHERE proceso = "inicio_pase";    

	--**//Comentar este IF para ejecuciÃ³n de pruebas
    IF vfechaproc <> vfecha_hoy THEN
        LET vcodret = "973";        
        RETURN vcodret;
    END IF

    -- // Extrae parametros globales	
	CALL pasechq_globalvar (pempresa) 
    RETURNING vcodret; 
       
    SELECT valor 
      INTO vtranprovint
      FROM bdicheq:sc_param
     WHERE codparam = "tranprov";	   
       
    -- // Extrae tasa base para el calculo de tasa exenta y param de T+1
    SELECT valor 
      INTO vdivisa_cambio
      FROM bdinteg:si_param
     WHERE cod_param > 0 
       AND descripcion = "divisa cambio";	   
	   
    
    -- // Extrae tipo de cambio valorizado
    SELECT precio_venta 
      INTO vtpcambval
      FROM bdinteg:si_tpcambio
     WHERE divisa = vdivisa_cambio 
       AND fecha_tpcambio = vfecha_hoy 
       AND clase_tpcambio = "O";	   
	   
       
    IF vtpcambval IS NULL THEN
       SELECT max(hora_tc) 
         INTO vhora_tc
         FROM bdinteg:si_histdiv
        WHERE empresa = pempresa 
          AND divisa = vdivisa_cambio 
          AND fecha_tc = vfecha_hoy
          AND clase_tpcambio = "O";		   
		    
       SELECT precio_venta 
         INTO vtpcambval
         FROM bdinteg:si_histdiv
        WHERE divisa = vdivisa_cambio 
          AND fecha_tc = vfecha_hoy
          AND clase_tpcambio = "O"
          AND hora_tc = vhora_tc;		  
		  
       IF vtpcambval IS NULL THEN
          LET vtpcambval = 1;
       END IF
    END IF
    
    -- // OBTINE VALORES PARA RANGO DE SERIALES A PROCESAR
    SELECT valor::INTEGER
      INTO vserial_inicial
      FROM bdicheq:sc_param
     WHERE codparam = 'SerialIniPaseChqCom5';
	 
	-- // CREA TABLA TEMPORAL DEL CUENTAS X PROCESO CUENTAS SUSPENSO
	select empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector 
      from bdinteg:si_catalog  
      into temp tmp_si_catalog with no log;
	
    create index id1_tmp_si_catalog on tmp_si_catalog (empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector ) using btree fillfactor 99;
    update statistics medium for table tmp_si_catalog;

	
   -- // CREA TABLA TEMPORAL DEL RANGO DE SERIALES INDICADOS
    -- his1: para ramas 1 y 3
    SELECT cuenta, sucursal, producto, transacc, monto_tot, cancelad, referencia /* PITDC Se agrega el campo "referencia" para que traiga el numero de tarjeta */
      FROM bdicheq:sc_movdia_concil
     WHERE num_serial >= vserial_inicial
       AND cancelad <> 'S'
       AND transacc NOT IN (vgtransacc_t1, vgtransacc_t2, '0231', '0232','3313', '3314', '0269', '1113', '1144')
      INTO TEMP his1 WITH NO LOG;

    CREATE INDEX idx_his1_tran_cuen ON his1(transacc,cuenta,producto) USING BTREE FILLFACTOR 90;
    UPDATE STATISTICS MEDIUM FOR TABLE his1;

    -- his1_esp: para rama 2
    SELECT cuenta, sucursal, producto, transacc, monto_tot, cancelad, referencia /* PITDC Se agrega el campo "referencia" para que traiga el numero de tarjeta */
      FROM bdicheq:sc_movdia_concil
     WHERE num_serial >= vserial_inicial
       AND transacc IN (vgtransacc_t1, vgtransacc_t2, '0231', '0232', '3313', '3314', '0269', '1113', '1144')
      INTO TEMP his1_esp WITH NO LOG;

    --CREATE INDEX idx_his1_esp_tran_cuen ON his1_esp (transacc,cuenta,producto) fillfactor 99; 
    CREATE INDEX idx_his1_esp_tran_cuen ON his1_esp (transacc,cuenta,producto) USING BTREE FILLFACTOR 90;
    UPDATE STATISTICS MEDIUM FOR TABLE his1_esp;

	-- // CREA TABLA TEMPORAL DEL CUENTAS X PROCESO CUENTAS SUSPENSO
    /*Se quita uso tabla temporal se usarÃ¡ tabla fÃ­sica, debido a que tiene aprÃ³x 50,000 reg*/
    -- // FOREACH PRINCIPAL
    FOREACH CurIni FOR
        /*Se quita campo EMPRESA del WHERE de los queries y se agrega trim en md.cuenta se usa en query penÃºltimo*/
        
        -- Asegura el conjunto de caracteres y aislamiento adecuados si aplica al batch
        -- Rama 1: usa his1 (ya filtrada por cancelad <> 'S' y NOT IN)
        SELECT {+INDEX (his1 idx_his1_tran_cuen)} md.sucursal, md.producto, pr.divisa, md.transacc, md.referencia, 
               md.monto_tot, tp.exento_isr, cl.sector, tr.valoriza, md.cancelad, 
               ac.tasa_bruta, ac.sobretasa, mc.sucursal, tr.descripcion AS abreviatura, mc.cobraisr, TRIM(md.cuenta)
          INTO vsucopero, vproducto, vmoneda, vtransacc,vreferencia, 
               vmonto_tot, vexento_isr, vsector, vvaloriza, vcancelad, 
               vtasa_bruta, vsobretasa, vsuccta, wabreviatura, vcobraisr, vcuenta
          FROM his1                    md
          JOIN bdicheq:sc_maechq       mc ON mc.cuenta  = md.cuenta
          LEFT JOIN bdicheq:sc_auxcont ac ON ac.empresa = pempresa AND ac.cuenta = md.cuenta
          JOIN bdicheq:sc_producto     pr ON pr.producto = md.producto
          JOIN bdinteg:si_transacc     tr ON tr.numero = md.transacc AND tr.se_contabiliza = 'S' AND tr.sistema = vg_sistema
          JOIN bdinteg:si_cliente      cl ON cl.numcte = mc.num_cte
          JOIN bdinteg:si_tipper       tp ON tp.tpo_persona = cl.tpo_persona
         --WHERE md.cancelad <> 'S'
         --  AND md.transacc NOT IN (vgtransacc_t1, vgtransacc_t2, '0231', '0232', '3313', '3314', '0269', '1113', '1144')
        UNION ALL 
        -- Rama 2: usa his1_esp (transacciones especiales, con o sin cancelaciÃ³n)
        SELECT {+INDEX (his1_esp idx_his1_esp_tran_cuen)} md.sucursal, ma.producto, pr.divisa, md.transacc, md.referencia, 
               md.monto_tot, "N" AS exento_isr, cl.sector, tr.valoriza, md.cancelad, 
               0 AS tasa_bruta, 0 AS sobretasa, ma.sucursal, tr.descripcion AS abreviatura, ma.cobraisr,TRIM(md.cuenta)
          FROM his1_esp             md
          JOIN bdicheq:sc_maechq    ma ON ma.cuenta  = md.cuenta
          JOIN bdicheq:sc_producto  pr ON pr.producto = md.producto
          JOIN bdinteg:si_cliente   cl ON cl.numcte = ma.num_cte
          JOIN bdinteg:si_transacc  tr ON tr.numero = md.transacc AND tr.se_contabiliza = 'S' AND tr.sistema = vg_sistema
         --WHERE md.transacc IN (vgtransacc_t1, vgtransacc_t2, '0231', '0232', '3313', '3314', '0269', '1113', '1144')
        /*UNION ALL
        -- Rama 3: usa his1 (mismo universo que rama 1)
        SELECT {+INDEX (his1 idx_his1_tran_cuen)} md.sucursal, md.producto, pr.divisa, md.transacc, md.referencia, 
               md.monto_tot, "N" AS exento_isr, "00", tr.valoriza, md.cancelad, 
               ac.tasa_bruta, ac.sobretasa, md.sucursal, tr.descripcion AS abreviatura, 'S', TRIM(md.cuenta)
          FROM his1                    md
          JOIN bditransfer:tf_maecte   mc ON mc.cuenta_tf = md.cuenta
          LEFT JOIN bdicheq:sc_auxcont ac ON ac.empresa = pempresa AND ac.cuenta = md.cuenta
          JOIN bdicheq:sc_producto     pr ON pr.producto  = md.producto
          JOIN bdinteg:si_transacc     tr ON tr.numero    = md.transacc AND tr.se_contabiliza = 'S' AND tr.sistema = vg_sistema*/

        LET wdescripcion = wabreviatura;
        
        IF vcobraisr <> "" THEN
           IF vcobraisr = "S" THEN
               LET vexento_isr = "N";
           ELSE
               LET vexento_isr = "S";
           END IF
        END IF

        -- // Verifica si es Transaccion de provision de Interes
        IF vtransacc = vtranprovint THEN
           IF vmoneda = vgcodigo_mn THEN
              CALL extrae_cont(pempresa,1,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion) 
              RETURNING vcodret;
              
              CONTINUE FOREACH;
           END IF
           
           IF vmoneda != vgcodigo_mn AND vvaloriza = "S" THEN
              CALL extrae_cont(pempresa,1,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion) 
              RETURNING vcodret;
              
              LET vmonto2 = vmonto_tot * vtpcambval;
              
              CALL extrae_cont(pempresa,3,vmonto2,vsucopero,vproducto,vgcodigo_mn,vtransacc,vsector,vcancelad,vsuccta,wdescripcion) 
              RETURNING vcodret;
              
              CONTINUE FOREACH;
           END IF
        END IF

        -- // Verifica si es movimiento valorizado
        IF vmoneda <> vgcodigo_mn AND vvaloriza = "S"  THEN
           LET vmonto2 = vmonto_tot * vtpcambval;
           
           CALL extrae_cont(pempresa,3,vmonto2,vsucopero,vproducto,vgcodigo_mn,vtransacc,vsector,vcancelad,vsuccta,wdescripcion) 
           RETURNING vcodret;
        END IF

        IF vtransacc <> "0231" AND 
           vtransacc <> "0232" AND 
           vtransacc <> "3313" AND 
           vtransacc <> "3314" AND
           vtransacc <> "1193" AND 
           vtransacc <> "1195" AND
           vtransacc <> vgtransacc_t1 AND 
           vtransacc <> "0269" AND 
           vtransacc <> "1113" AND
           vtransacc <> "1144" AND		   
           vtransacc <> vgtransacc_t2 AND NOT  
           (vtransacc="0274" AND vproducto="9901") AND NOT 
           (vtransacc="0273" AND vproducto="9901") AND NOT 
           (vtransacc="0273" AND vproducto = "1600" AND vcuenta IN ('16000000080')) AND NOT
		   (vtransacc="0273" AND vproducto = "1600" AND vcuenta IN ('16000000322')) AND NOT	
           (vtransacc="0273" AND vproducto = "2200" AND vcuenta IN ('22000001574'))   THEN
             CALL extrae_cont(pempresa,1,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion)  
             RETURNING vcodret;
        END IF
        
        --	// Proceso para PITDC:
        IF vtransacc = "1193" OR vtransacc = "1195" THEN
           LET vbintarjeta = SUBSTR(vreferencia, 1, 6);
           
           -- // Obtener que secuencia debe ser tomada en cuenta:
           /*SELECT Cod_Reg 
             INTO vsecuencia 
             FROM BdiSac:Sac_EGlobal_Banco 
            WHERE IdBanco = (SELECT NVL(Id_Bco, 0) 
                               FROM BdiCheq:Sc_Bines 
                              WHERE Bin = vbintarjeta);*/
							  
							  
			SELECT cod_reg 
              INTO vsecuencia 
              --FROM BdiSac:Sac_EGlobal_Banco 
			  FROM bdisac:sac_eglobal_banco
             WHERE idbanco = (SELECT NVL(id_bco, 0) 
                                FROM bdicheq:sc_bines 
                               WHERE Bin = vbintarjeta);
            
           IF vsecuencia IS NULL THEN
              LET vsecuencia = "3";
           END IF;	
           
           CALL extrae_cont(pempresa,vsecuencia,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion)
           RETURNING vcodret;
     	END IF;			

        -- // Contabiliza Camara,231,232,3246,269,1113
        IF vtransacc = "0231" OR 
           vtransacc = "0232" OR
           vtransacc = "3313" OR 
           vtransacc = "3314" OR
           vtransacc = vgtransacc_t1 OR 
           vtransacc = "0269" OR 
           vtransacc = "1113" OR 		   
           vtransacc = "1144" OR
		   vtransacc = vgtransacc_t2 THEN
           CALL extrae_cont(pempresa,1,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion)  
           RETURNING vcodret;
           
           IF vtransacc = vgtransacc_t1 OR vtransacc = "0269" OR vtransacc = "1113" OR vtransacc = "1144" THEN
              CALL extrae_cont(pempresa,2,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,wdescripcion) 
              RETURNING vcodret;
           END IF
        END IF
		
		
		LET vcuenta = TRIM(vcuenta);
		
        /* SERVICIOS */
		IF (vtransacc = "0274" AND vproducto="9901") OR 
           (vtransacc = "0273" AND vproducto="9901") OR 
           (vtransacc = "0273" AND vproducto="1600" AND vcuenta IN ('16000000080')) OR 
		   (vtransacc = "0273" AND vproducto="1600" AND vcuenta IN ('16000000322')) OR 
           (vtransacc = "0273" AND vproducto="2200" AND vcuenta IN ('22000001574')) THEN

            SELECT NVL(MAX(secuencia),0) INTO vsecserv FROM bdisac:sac_catalogo_pt WHERE cuenta=vcuenta; 
			
            IF vsecserv<>0 THEN
                CALL extrae_cont(pempresa,vsecserv,vmonto_tot,vsucopero,vproducto,vmoneda,vtransacc,vsector,vcancelad,vsuccta,
				                 CASE WHEN vcuenta = '22000001574' THEN 'ABSPEIWU' 
								      WHEN vcuenta = '16000000080' THEN 'ABSPEIBTS'
									  WHEN vcuenta = '16000000322' THEN 'ABSPEIAPP' 									  
									  ELSE wdescripcion END) 
                RETURNING vcodret;
            END IF;
        END IF;

    END FOREACH
    
    LET vestatusproc = "F";	
	UPDATE bdinteg:sx_contproc 
       SET status_proc   = vestatusproc,
           codret        = vcodret,
           hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas WHERE empresa = pempresa) 
     WHERE proceso = vproceso
       AND fecha   = vfecha_hoy
       AND sistema = vsistema;		
	
    RETURN vcodret;

END;
END procedure;