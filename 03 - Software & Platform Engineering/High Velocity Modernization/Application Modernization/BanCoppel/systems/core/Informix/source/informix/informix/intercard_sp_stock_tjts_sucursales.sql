CREATE PROCEDURE "informix".sp_stock_tjts_sucursales()
---ASIGNACION DE NOMBRE A LAS VARIABLRES DE RETORNO.
RETURNING VARCHAR(5) AS CODIGO_RETORNO, VARCHAR (50) AS MENSAJE_RETORNO;
	
	--Definicion de variables
    DEFINE  codigo_retorno      CHAR(5);				
	DEFINE  mensaje_retorno     CHAR(50);
	DEFINE	rpt_fecha			CHAR(8);
    DEFINE  sfecha_hoy			DATE; 
    DEFINE	TIPO_PLANTILLA 		VARCHAR(20);   
	DEFINE	RUTA_DESTINO 		VARCHAR(80);
	DEFINE	vsql				CHAR(1150);
	DEFINE SQLERR		INTEGER;
	DEFINE ISAM_ERR		INTEGER;
	DEFINE ERROR_INFO	VARCHAR(80);  
	
	DEFINE vclave_sucursal  VARCHAR(5);
	DEFINE vclave_tipotarjeta INTEGER;
	DEFINE vproducto          VARCHAR(7);
	DEFINE vexistentes        INTEGER;
	DEFINE vsolicitadas       INTEGER;
	DEFINE vdescripcion       VARCHAR(28);
	--new
	DEFINE vConteo             INTEGER;
	DEFINE vcommit  varchar(50);
	DEFINE vempresa CHAR(3);
	DEFINE vclave_sucursal1    VARCHAR(5);
	DEFINE vclave_tipotarjeta1 INTEGER;
	DEFINE vtipo         CHAR(1); 
	DEFINE vproducto1    VARCHAR(7);
	DEFINE vestatus      CHAR(10);
	DEFINE vdescripcion1 CHAR(40);
	DEFINE vcodstatustarjeta CHAR(3);
	DEFINE vtotal INTEGER;
	DEFINE vsFlagEnTransaccion VARCHAR(1);
 
    LET RUTA_DESTINO	 = '/RESPALDOSNEW/';
	LET TIPO_PLANTILLA	 = 'Inventario_suc';
	--Asignacion de valores a las variables de retorno
    LET rpt_fecha='';
    LET codigo_retorno = '00000';
    LET mensaje_retorno = 'PROCESO EXITOSO';
    LET	vclave_sucursal = '';
	LET vclave_tipotarjeta = 0;
	LET vproducto          = '';
	LET vexistentes  = 0;
	LET vsolicitadas = 0;
	LET vdescripcion = '';
	--new
    LET vConteo  = 0;
	LET vcommit = '';
	LET vempresa  = '';
	LET vclave_sucursal1    = '';
	LET vclave_tipotarjeta1 = 0;
	LET vtipo         = '';
	LET vproducto1    = '';
	LET vestatus     = '';
	LET vdescripcion1 = '';
	LET vcodstatustarjeta = '';
    LET vtotal = 0; 
	LET vsFlagEnTransaccion = 'F';

     --SET DEBUG FILE TO RUTA_DESTINO || "sp_stock_tjts_sucursales.out";
     --TRACE ON;        
	
    BEGIN 
		
        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO

            SET DEBUG FILE TO RUTA_DESTINO || "excepcion_sp_stock_tjts_sucursales.out"  WITH APPEND;
            TRACE ON;
            
            IF ( SQLERR <> 0 ) THEN
                LET CODIGO_RETORNO = SQLERR;
                LET MENSAJE_RETORNO = ERROR_INFO;                
                RETURN CODIGO_RETORNO, MENSAJE_RETORNO;
            END IF;
			
        END EXCEPTION;
 

	    SET ISOLATION TO DIRTY READ; 
	    SET LOCK MODE TO WAIT 3;
	
	    SELECT valores INTO vcommit FROM "informix".tbl_inter_parametros where cond_busqueda = 'Commits_N1';
	
	
		SELECT fecha_hoy  INTO  sfecha_hoy FROM bdinteg:si_fechas WHERE empresa='001';    
        LET rpt_fecha = LPAD(DAY(sfecha_hoy),2,'0')||LPAD(MONTH(sfecha_hoy),2, '0')||YEAR(sfecha_hoy);
		
		--LET rpt_fecha = substr (sfecha_hoy, 4,2)||substr (sfecha_hoy, 0,2)||substr (sfecha_hoy, 7,4);  
		 
		-- NEW
		   TRUNCATE TABLE "informix".tbl_paso_inventario_suc  DROP STORAGE;   
		   TRUNCATE TABLE "informix".sucursales_base_tmp      DROP STORAGE;   
		   TRUNCATE TABLE "informix".inventario_suc_tmp2      DROP STORAGE;   
		   TRUNCATE TABLE "informix".inventario_suc_tmp_noa   DROP STORAGE;   
		   TRUNCATE TABLE "informix".inventario_suc_tmp_noe   DROP STORAGE;   
		   TRUNCATE TABLE "informix".inventario_suc_final     DROP STORAGE;  
	 
	 foreach cur_F1_main WITH hold for
          ---1) query principal
		 select 
        --'001' as empresa, 
        lot.clave_sucursal as clave_sucursal,
        lot.clave_tipotarjeta,
        tt.tipo as tipo,
        case when tt.tipo = 'C' then 'CREDITO' 
        when tt.tipo ='D' then  'DEBITO' end as producto,
        tjt.codstatusasignada as estatus,
        tt.descripcion,
        tjt.codstatustarjeta as codstatustarjeta
		INTO 
		--vempresa,
		vclave_sucursal1,
		vclave_tipotarjeta1,
		vtipo,
		vproducto1,
		vestatus,
		vdescripcion1,
		vcodstatustarjeta
        from tarjeta tjt 
        inner join lote lot on tjt.numerolote = lot.numerolote 
        inner join tipotarjeta tt on lot.clave_tipotarjeta = tt.clave_tipotarjeta
        where 
		 tt.chip in ('F','V') 
        AND tjt.codstatusasignada in ('NOE','NOA')  
        AND tjt.codstatustarjeta = 'INA'
        AND lot.tipoenvio = 'S'
		ORDER BY clave_sucursal
         
		 
            IF (vsFlagEnTransaccion = 'F') THEN
                 BEGIN WORK;
			   --TRACE 'T0_'|| vConteo;
                 LET vsFlagEnTransaccion = 'V';
             END IF;
			 
			    INSERT INTO "informix".tbl_paso_inventario_suc  
				 values ('001',vclave_sucursal1,vclave_tipotarjeta1,vtipo,vproducto1,vestatus,vdescripcion1,vcodstatustarjeta);

				  LET vConteo = vConteo +1;  
													 
					  IF (vConteo >= vcommit) THEN    
                           COMMIT WORK;
							--TRACE 'T1_'|| vConteo;
                            LET vConteo = 0;
                            LET vsFlagEnTransaccion = 'F';                
                           CONTINUE FOREACH;
                   END IF;
			
    end foreach;
        --TRACE 'T2_'|| vConteo;
		
				   IF ((vConteo > 0) OR (vsFlagEnTransaccion = 'V')) THEN
                      COMMIT WORK;
                        LET vsFlagEnTransaccion = 'F';
                    END IF; 
  
        UPDATE STATISTICS MEDIUM FOR TABLE "informix".tbl_paso_inventario_suc;    
		-----------------------
		
        --2   generacion de sucursales base con las que trabajar
         LET vclave_sucursal = '';
		 LET vproducto = '';
		 LET vclave_tipotarjeta = '';
		 LET vtipo = '';
		 LET vdescripcion = '';
		 LET vConteo = 0; 
		 LET vsFlagEnTransaccion = 'F';
		
		foreach cur_F2_suc WITH hold for
		
		    Select 
			distinct clave_sucursal,
		    producto,
		    clave_tipotarjeta,
			tipo,
			descripcion
            INTO vclave_sucursal,vproducto,vclave_tipotarjeta,vtipo,vdescripcion
			from tbl_paso_inventario_suc
		    where empresa = '001' 
            AND tipo IN ('C', 'D')
			order by clave_sucursal
   
		     IF (vsFlagEnTransaccion = 'F') THEN
                 BEGIN WORK;
			   --TRACE 'T0_'|| vConteo;
                 LET vsFlagEnTransaccion = 'V';
             END IF;
		   
		   	INSERT INTO "informix".sucursales_base_tmp  (clave_sucursal,producto,clave_tipotarjeta,tipo,descripcion)
		    VALUES  (vclave_sucursal,vproducto,vclave_tipotarjeta,vtipo,vdescripcion);
			
				  LET vConteo = vConteo +1;  
													 
				    IF (vConteo >= vcommit) THEN    
                           COMMIT WORK;
							--TRACE 'T1_'|| vConteo;
                            LET vConteo = 0;
                            LET vsFlagEnTransaccion = 'F';                
                           CONTINUE FOREACH;
                    END IF;
			
        end foreach; 

				   IF ((vConteo > 0) OR (vsFlagEnTransaccion = 'V')) THEN
                      COMMIT WORK;
                        LET vsFlagEnTransaccion = 'F';
                    END IF; 
  
        UPDATE STATISTICS MEDIUM FOR TABLE "informix".sucursales_base_tmp;   		
		--------------------------
 
         LET vclave_sucursal = '';
		 LET vproducto = '';
		 LET vestatus = '';
		 LET vclave_tipotarjeta = '';
		 LET vdescripcion = '';
		 LET vtotal = 0; 
 		 LET vConteo = 0; 
		 LET vsFlagEnTransaccion = 'F';
        --3   Agrupacion por sucursal y stock 
		 foreach cur_F3_stock WITH hold for
		 
             select clave_sucursal,producto,estatus, clave_tipotarjeta,descripcion,count(*) as total 
             INTO vclave_sucursal,vproducto,vestatus,vclave_tipotarjeta,vdescripcion,vtotal 
		     from tbl_paso_inventario_suc
              group by 1,2,3,4,5
              order by clave_sucursal
			  
			 IF (vsFlagEnTransaccion = 'F') THEN
                 BEGIN WORK;
			   --TRACE 'T0_'|| vConteo;
                 LET vsFlagEnTransaccion = 'V';
             END IF;
           
		    INSERT INTO "informix".inventario_suc_tmp2  (clave_sucursal,producto,estatus,clave_tipotarjeta,descripcion,total)
		    VALUES  (vclave_sucursal,vproducto,vestatus,vclave_tipotarjeta,vdescripcion,vtotal);
			
			  LET vConteo = vConteo +1;  
													 
			    IF (vConteo >= vcommit) THEN    
                           COMMIT WORK;
							--TRACE 'T1_'|| vConteo;
                            LET vConteo = 0;
                            LET vsFlagEnTransaccion = 'F';                
                           CONTINUE FOREACH;
                END IF;
 
         end foreach;  
		 
		 		    IF ((vConteo > 0) OR (vsFlagEnTransaccion = 'V')) THEN
                      COMMIT WORK;
                        LET vsFlagEnTransaccion = 'F';
                    END IF; 
  
        UPDATE STATISTICS MEDIUM FOR TABLE "informix".inventario_suc_tmp2;   
		-------------------------
	     LET vclave_sucursal = '';
		 LET vproducto = '';
		 LET vclave_tipotarjeta = '';
		 LET vtotal = 0; 
		 LET vConteo = 0; 
		 LET vsFlagEnTransaccion = 'F';
        --4   agrupacion de existentes por sucursal
		foreach cur_F4_noa WITH hold for
                 Select clave_sucursal,producto,clave_tipotarjeta, total as total_noa 
				 INTO  vclave_sucursal,vproducto,vclave_tipotarjeta,vtotal
				 from inventario_suc_tmp2  
                 where estatus = 'NOA'
				 order by clave_sucursal 
			   
			    IF (vsFlagEnTransaccion = 'F') THEN
                    BEGIN WORK;
			        --TRACE 'T0_'|| vConteo;
                     LET vsFlagEnTransaccion = 'V';
                END IF;
 
 		        INSERT INTO "informix".inventario_suc_tmp_noa  ( clave_sucursal,producto,clave_tipotarjeta, total_noa )
		        VALUES  (vclave_sucursal,vproducto,vclave_tipotarjeta,vtotal);
   
   				  LET vConteo = vConteo +1;  
													 
					  IF (vConteo >= vcommit) THEN    
                           COMMIT WORK;
							--TRACE 'T1_'|| vConteo;
                            LET vConteo = 0;
                            LET vsFlagEnTransaccion = 'F';                
                           CONTINUE FOREACH;
                   END IF;
  
		 end foreach;  
		 
		 		    IF ((vConteo > 0) OR (vsFlagEnTransaccion = 'V')) THEN
                      COMMIT WORK;
                        LET vsFlagEnTransaccion = 'F';
                    END IF; 
  
           UPDATE STATISTICS MEDIUM FOR TABLE "informix".inventario_suc_tmp_noa;  
			--------------------------
		 LET vclave_sucursal = '';
		 LET vproducto = '';
		 LET vclave_tipotarjeta = '';
		 LET vtotal = 0; 
		 LET vConteo = 0; 
		 LET vsFlagEnTransaccion = 'F';
        --5  agrupacion de solicitadas por sucursal
		    foreach cur_F5_noa WITH hold for 
                      Select clave_sucursal,producto,clave_tipotarjeta, total as total_noe  
		              INTO vclave_sucursal,vproducto,vclave_tipotarjeta,vtotal
					  from inventario_suc_tmp2  
                      where estatus = 'NOE'
					  order by clave_sucursal
                   
				   	   IF (vsFlagEnTransaccion = 'F') THEN
                           BEGIN WORK;
			               --TRACE 'T0_'|| vConteo;
                           LET vsFlagEnTransaccion = 'V';
                        END IF;
 
					  INSERT INTO "informix".inventario_suc_tmp_noe  ( clave_sucursal,producto,clave_tipotarjeta, total_noe )
		              VALUES  (vclave_sucursal,vproducto,vclave_tipotarjeta,vtotal);  
					  
					    LET vConteo = vConteo +1;  
													 
					    IF (vConteo >= vcommit) THEN    
                           COMMIT WORK;
							--TRACE 'T1_'|| vConteo;
                            LET vConteo = 0;
                            LET vsFlagEnTransaccion = 'F';                
                           CONTINUE FOREACH;
                        END IF;
					  
		    end foreach; 
 
 		 		    IF ((vConteo > 0) OR (vsFlagEnTransaccion = 'V')) THEN
                      COMMIT WORK;
                        LET vsFlagEnTransaccion = 'F';
                    END IF; 
  
           UPDATE STATISTICS MEDIUM FOR TABLE "informix".inventario_suc_tmp_noe;  
           -------
			LET vclave_sucursal= '';
			LET vclave_tipotarjeta = '';
			LET vproducto = '';
			LET vexistentes = 0;
			LET vsolicitadas = 0;
			LET vdescripcion = '';
		    LET vConteo = 0; 
		    LET vsFlagEnTransaccion = 'F';
			
       --6  concentrado final 
           foreach cur_F6_fin WITH hold for

            Select suc.clave_sucursal, 
            suc.clave_tipotarjeta, 
            suc.producto,
            NVL(total_noa,'0') as existentes, 
            NVL(total_noe,'0') as solicitadas, 
            TRIM(suc.descripcion) 
			INTO  vclave_sucursal,vclave_tipotarjeta,vproducto,vexistentes,vsolicitadas,vdescripcion
            from sucursales_base_tmp as suc
            LEFT JOIN  inventario_suc_tmp_noa as noa ON suc.clave_sucursal = noa.clave_sucursal and suc.clave_tipotarjeta = noa.clave_tipotarjeta
            LEFT JOIN  inventario_suc_tmp_noe as noe ON suc.clave_sucursal = noe.clave_sucursal and suc.clave_tipotarjeta = noe.clave_tipotarjeta
           	order by clave_sucursal  		

  			IF (vsFlagEnTransaccion = 'F') THEN
                  BEGIN WORK;
			      --TRACE 'T0_'|| vConteo;
                  LET vsFlagEnTransaccion = 'V';
            END IF;
					
		    INSERT INTO "informix".inventario_suc_final  (clave_sucursal,clave_tipotarjeta,producto,existentes,solicitadas,descripcion)
		    VALUES  (vclave_sucursal,vclave_tipotarjeta,vproducto,vexistentes,vsolicitadas,vdescripcion);
		   
		     LET vConteo = vConteo +1;  
													 
				IF (vConteo >= vcommit) THEN    
                           COMMIT WORK;
							--TRACE 'T1_'|| vConteo;
                            LET vConteo = 0;
                            LET vsFlagEnTransaccion = 'F';                
                           CONTINUE FOREACH;
                END IF;
		   
		    end foreach;  
  
   		 		    IF ((vConteo > 0) OR (vsFlagEnTransaccion = 'V')) THEN
                      COMMIT WORK;
                        LET vsFlagEnTransaccion = 'F';
                    END IF; 
  
           UPDATE STATISTICS MEDIUM FOR TABLE "informix".inventario_suc_final;  
  
            -----------------------------------------------------------------------------------------------------------------
			--Elimina reportes anteriores
	        let vsql = '';
            let vsql ='rm -f '||RUTA_DESTINO||TIPO_PLANTILLA||'*';
            system vsql;
           ----------------------------------------------------------------------------------------------------------------- 
		    let vsql = ''; 	   
		    let vsql = 'echo "clave_sucursal|clave_tipotarjeta|producto|existentes|solicitadas|descripcion|">'||RUTA_DESTINO||TIPO_PLANTILLA||'_'||rpt_fecha||'.txt';  
		    system vsql;
           -----------------------------------------------------------------------------------------------------------------
            let vsql = '';
            let vsql = ' echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||RUTA_DESTINO ||'inventario_base_'||rpt_fecha||'.txt '||
                      ' SELECT  * FROM   intercard:inventario_suc_final order by 1,2 asc;">'||RUTA_DESTINO||'script_inventario.sql';  
            system vsql;	
            -----------------------------------------------------------------------------------------------------------------	
			---Asigancion de permisos del archivo .sql
			let vsql ='';			
			let vsql= 'chmod 777 ' ||RUTA_DESTINO||'script_inventario.sql';
			system vsql;
		    
		    let vsql = '';
            let vsql = 'dbaccess intercard '||RUTA_DESTINO||'script_inventario.sql';
            system vsql;	
			-----------------------------------------------------------------------------------------------------------------
		    --Resultado del unload se complementa con el encabezado del reporte
			let vsql ='';
            let vsql = "sed 's/|s//g' "||RUTA_DESTINO||'inventario_base_'||rpt_fecha||".txt >> "||RUTA_DESTINO||TIPO_PLANTILLA||'_'||rpt_fecha||".txt";
            system vsql;
 
			-----------------------------------------------------------------------------------------------------------------
			--eliminaciÃ³n de archivos
			let vsql = '';
            let vsql ='rm -f '||RUTA_DESTINO||'script_inventario.sql';
            system vsql;
		 
		    let vsql = '';
			let vsql ='rm -f '||RUTA_DESTINO||'inventario_base_'||rpt_fecha||'.txt';  
			system vsql;
		 		   
          ------------------------------------------------------------------------------------------------------------------------
      
    RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO;


END;
END PROCEDURE
---CoordinaciÃ³n de Tarjetas e Interfaces Transaccionales | Gerencia Mantenimiento I
---Autor: Marcos Gerardo Ayala Ponce
---Fecha de creacion: 21 de septiembre del 2021
---Base de datos: intercard
---Este proceso corresponde al job 828
----EXECUTE PROCEDURE "informix".sp_stock_tjts_sucursales();
;

CREATE PROCEDURE "informix".sp_tarj_det_vcas_exp()
    RETURNING VARCHAR(10), VARCHAR(255)

    DEFINE vfecha DATETIME YEAR TO FRACTION(5);
    DEFINE vfechaTime DATETIME YEAR TO FRACTION(5);


    DEFINE vstatus_proc 	CHAR(1);
    DEFINE vcod_ret         VARCHAR(10);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE error_info       CHAR(40);

    DEFINE v_dia         	CHAR(2);
    DEFINE v_mes         	CHAR(2);
    DEFINE v_ano         	CHAR(4);
    DEFINE v_hora 			DATETIME HOUR TO SECOND;
    DEFINE v_hora2 			CHAR(8);
    DEFINE v_sql         	CHAR(250);
    DEFINE cEncabezado   	CHAR(250);

    DEFINE cRuta 			CHAR(250);
    DEFINE cRuta2 			CHAR(250);
    DEFINE cNombreArchivo 	CHAR(250);
    DEFINE cNombreArchivo1 	CHAR(250);
    DEFINE cNombreArchivo2 	CHAR(250);

    DEFINE var_action 		CHAR(6);
    DEFINE var_numtarjeta   VARCHAR(16);
    DEFINE var_telefono     CHAR(13);
    DEFINE var_correo_elec 	CHAR(100);
    DEFINE var_fecha        DATETIME YEAR to SECOND;

    DEFINE iContador_pay    SMALLINT;
    DEFINE vreg_ins INTEGER;

    --MANEJO DEL ERROR.
    ON EXCEPTION SET sql_err, isam_err, error_info
            
        SET DEBUG FILE TO "/RESPALDOSNEW/exc_sp_tarj_det_vcas.err.out" WITH APPEND;
        TRACE ON;
        
        UPDATE intercard:ctrl_info_ctes_vcas
        SET status_proc = '0';

        IF sql_err <> 0 THEN
            LET vcod_ret=sql_err;
            UPDATE intercard:ctrl_info_ctes_vcas
            SET(cod_err, descripcion_err) = (vcod_ret, isam_err||' ' ||error_info);
            RETURN vcod_ret, isam_err||' ' ||error_info;
        END IF;
    END EXCEPTION;

        SET DEBUG FILE TO "/RESPALDOSNEW/sp_tarj_det_vcas.out";
        TRACE ON;

    LET vfecha = TODAY;
    LET vfechaTime = TODAY;
    LET vstatus_proc = '';

    LET vcod_ret = '000';          
    LET sql_err = 0;          
    LET isam_err = 0;        
    LET error_info = '';
    LET iContador_pay = 0;

    LET v_dia           = "";
    LET v_mes           = "";
    LET v_ano           = "";  
    LET v_hora 			= CURRENT;
    LET v_hora2 		= "";
    LET v_sql           = "";

    LET cEncabezado     = "";
    LET cRuta 			= "/tmp/";
    LET cRuta2 			= "/RESPALDOSNEW/VCAS_resultados/";
    LET cNombreArchivo 	= "";
    LET cNombreArchivo1 = "";
    LET cNombreArchivo2 = "";

    LET var_action 		= "";
    LET var_numtarjeta  = "";
    LET var_telefono    = "";
    LET var_correo_elec = "";
    LET var_fecha       = CURRENT;
    LET vreg_ins 		= 0;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
     
    SELECT status_proc
        INTO vstatus_proc
    FROM intercard:ctrl_info_ctes_vcas;

    IF(vstatus_proc = '1') THEN
            UPDATE intercard:ctrl_info_ctes_vcas
            SET(cod_err, descripcion_err) = (vcod_ret, 'DESCARGA EN PROCESO');
        
        RETURN vcod_ret, 'DESCARGA EN PROCESO';
    END IF;
   
    UPDATE intercard:ctrl_info_ctes_vcas SET status_proc = '1';  
 
    SELECT fecha, fecha  - 1 units hour
        INTO vfecha, vfechaTime
    FROM intercard:ctrl_info_ctes_vcas;

-- ELIMINA REGISTROS DE TABLA DE RESULTADOS EN CASO DE QUE HAYA FALLADO EL SP Y HAYA GENERADO INFORMACION.
   
   TRUNCATE TABLE intercard:ctas_vcas;

  -- CREAR TEMPORALES PARA RESULTADO FINAL
    SELECT numtarjeta, fechaasignacion
    FROM intercard:info_tarjeta_pyt
    WHERE codstatustarjeta = 'ACT'
    AND fechaasignacion >= vfecha
    INTO temp tmptarj with no log;

    CREATE INDEX "informix".tmp_tartarj_vcas ON tmptarj(numtarjeta) ONLINE;
    
    /*
	SELECT bin
	FROM intercard:bines WHERE (marca  = 'VS' or bin in (510148, 554948 ,559471)) --
	INTO temp BIN_VISA with no log;
    */
    SELECT bin 
        FROM intercard:bines 
            WHERE bin IN ('400819', '426807', '559471', '554948', '510148', '416916')
    INTO TEMP BIN_VISA WITH NO LOG;

    CREATE INDEX "informix".tmp_bin_visa ON BIN_VISA(bin) ONLINE;
    
    --TARJETAS DE CREDITO
    SELECT numcte,num_tarjeta
    FROM bdicred:sd_tarjeta
    WHERE empresa= '001' AND num_tarjeta IN (SELECT numtarjeta FROM tmptarj GROUP BY numtarjeta)
    INTO temp tmpctestarj with no log;

    CREATE INDEX "informix".tmp_cte_pt ON tmpctestarj(numcte,num_tarjeta) ONLINE;

    -- CREATE INDEX "informix".tmp_tarj_pt ON tmpctestarj(num_tarjeta) ONLINE;

    --TARJETAS DE DEBITO
    INSERT INTO tmpctestarj
    SELECT numcte, num_tarjeta
    FROM bdicheq:sc_tarjeta
    WHERE empresa= '001' AND num_tarjeta IN (SELECT numtarjeta FROM tmptarj GROUP BY numtarjeta);

    -- TABLA TELEONOS TIPO 2
	SELECT telefono, numcte, status_tel, fecha_hora
    FROM bdinteg:si_telefonos_actual
    --WHERE (tipo_tel = 2 and  fecha_hora >=vfecha) or (numcte IN (SELECT numcte FROM tmpctestarj WHERE 1=1))
	WHERE ((fecha_hora >=vfechaTime) or (numcte IN (SELECT numcte FROM tmpctestarj WHERE 1=1))) and tipo_tel = 2
    INTO temp tmptelefono_tipo2 with no log;

    CREATE INDEX "informix".tmptelefono_tipo2_idx1  ON tmptelefono_tipo2(status_tel,fecha_hora) ONLINE;
    --CREATE INDEX "informix".tmptelefono_tipo2_idx2  ON tmptelefono_tipo2(numcte) ONLINE;


    --TEMPORAL DE TELEONOS
	SELECT telefono, numcte
    FROM tmptelefono_tipo2 WHERE status_tel = 'A' and fecha_hora >= vfechaTime
    GROUP BY telefono, numcte
    UNION
    SELECT telefono, numcte
    FROM tmptelefono_tipo2 WHERE numcte IN (SELECT numcte FROM tmpctestarj WHERE 1=1) AND status_tel = 'A'
    GROUP BY telefono, numcte
    INTO temp tmptelefono with no log;

    CREATE INDEX "informix".tmptelefono_idx1 ON tmptelefono(numcte,telefono) ONLINE;
    --CREATE INDEX "informix".tmptelefono_idx2 ON tmptelefono(numcte) ONLINE;


    -- TABLA CORREOS  TIPO 1
	SELECT tipo_correo, status_correo, secuencia, valido, numcte, correo_elec, fecha_hora
    FROM bdinteg:si_correos C
    WHERE C.tipo_correo = 1 AND C.status_correo = 'A' AND C.valido = 1 AND C.fecha_hora >= vfechaTime
	INTO temp tmpsi_correos with no log;

	--CREATE INDEX "informix".tmpsi_correos_idx1 ON tmpsi_correos(tipo_correo,status_correo,fecha_hora, valido);
	CREATE INDEX "informix".tmpsi_correos_idx2 ON tmpsi_correos(numcte,tipo_correo,status_correo,valido);

	--TEMPORAL DE CORREOS

	SELECT correo_elec, numcte
    FROM bdinteg:tmpsi_correos C
    WHERE numcte IN  (SELECT numcte FROM tmpctestarj WHERE 1=1)
	AND C.tipo_correo = 1 AND C.status_correo = 'A' AND C.valido = 1
    GROUP BY correo_elec, numcte
	UNION
	SELECT correo_elec, numcte
    FROM bdinteg:tmpsi_correos C
    WHERE C.tipo_correo = 1 AND C.status_correo = 'A' AND fecha_hora >= vfechaTime AND C.valido = 1
	GROUP BY correo_elec, numcte
	INTO temp tmpcorreo with no log;

    CREATE INDEX "informix".tmp_correlec_vcas ON tmpcorreo(numcte,correo_elec) ONLINE;
    --CREATE INDEX "informix".tmp_numctecorr_vcas ON tmpcorreo(numcte) ONLINE;

   --TARJETAS DE CREDITO CTES
    SELECT numcte,num_tarjeta
    FROM bdicred:sd_tarjeta
    WHERE empresa= '001' AND numcte IN (SELECT numcte FROM tmpcorreo UNION ALL SELECT numcte FROM tmptelefono)
    INTO temp tmpctestarjfin with no log;

    CREATE INDEX "informix".tmp_cte_pts ON tmpctestarjfin(numcte,num_tarjeta) ONLINE;
	--CREATE INDEX "informix".tmp_tarj_pts ON tmpctestarjfin(num_tarjeta) ONLINE;

    --TARJETAS DE DEBITO CTES
    INSERT INTO tmpctestarjfin
    SELECT numcte, num_tarjeta
    FROM bdicheq:sc_tarjeta
    WHERE empresa= '001' AND numcte IN (SELECT numcte FROM tmpcorreo UNION ALL SELECT numcte FROM tmptelefono);

	--CTES CON TARJETAS ACTUALIZADAS
    SELECT numtarjeta, A.fechaasignacion, B.numcte
    FROM intercard:info_tarjeta_pyt A, tmpctestarjfin B
    WHERE A.numtarjeta=B.num_tarjeta AND codstatustarjeta = 'ACT'
    GROUP BY A.numtarjeta, A.fechaasignacion, B.numcte
    INTO temp tmptarjeta with no log;

    CREATE INDEX "informix".tmp_numtarj_vcas ON tmptarjeta(numcte,numtarjeta) ONLINE;
    --CREATE INDEX "informix".tmp_numclient_vcas ON tmptarjeta(numcte) ONLINE;
    CREATE INDEX "informix".tmp_fechasig_vcas ON tmptarjeta(fechaasignacion) ONLINE;
   
-- INFORMACION QUE SE EJECUTARA CADA DETERMINADO TIEMPO.
    BEGIN WORK;
        FOREACH WITH HOLD
            SELECT 
                CASE 
                    WHEN A.fechaasignacion >= vfecha THEN 'ADD' ELSE 'UPDATE' END 
                AS action,
                A.numtarjeta,B.telefono AS telefono,
                C.correo_elec AS correo_elec,
                CURRENT AS fecha
                INTO var_action, var_numtarjeta, var_telefono, var_correo_elec, var_fecha
            FROM tmptarjeta A
                LEFT JOIN tmptelefono B ON A.numcte=B.numcte
                LEFT JOIN tmpcorreo C ON A.numcte=C.numcte
            WHERE SUBSTR(A.numtarjeta,1,6) IN (SELECT bin FROM BIN_VISA )
            AND((B.telefono IS NOT NULL)OR(C.correo_elec IS NOT NULL))            
            GROUP BY A.numtarjeta, B.telefono, C.correo_elec,fecha,action

            LET iContador_pay = iContador_pay + 1;

            INSERT INTO "informix".ctas_vcas(action, numtarjeta, telefono, correo_elec, fecha)
            VALUES(var_action, var_numtarjeta, var_telefono, var_correo_elec, var_fecha);
               
            IF iContador_pay = 1000 THEN
                COMMIT;
                LET iContador_pay = 0;
                UPDATE STATISTICS MEDIUM FOR TABLE "informix".ctas_vcas;
                BEGIN WORK;
            END IF;
        END FOREACH;
    COMMIT;

        UPDATE STATISTICS MEDIUM FOR TABLE "informix".ctas_vcas;
    
	-- DESCARGAR ARCHIVO.
	LET v_dia = LPAD(DAY(CURRENT),2,'0');  
	LET v_mes = LPAD(MONTH(CURRENT),2,'0');
	LET v_ano = year(CURRENT);
    LET v_hora2 = v_hora::CHAR(8);
	LET cNombreArchivo = TRIM(cRuta2)||'ISSUERNAME'||v_ano||v_mes||v_dia||SUBSTR(v_hora2,1,2)||SUBSTR(v_hora2,4,2)||SUBSTR(v_hora2,7,2)||'.csv';
	LET cNombreArchivo1 = TRIM(cRuta)||'ISSUERNAME'||v_ano||v_mes||v_dia||'_aux.csv';
    LET cNombreArchivo2 = TRIM(cRuta)||'ISSUERNAME'||v_ano||v_mes||v_dia||'_aux2.csv';
         
	-- DESCARGA DEL ARCHIVO .CSV.
	LET cEncabezado = 'echo "action,pan,mobilenumber,email,segmentationindicator," > /tmp/queryenc.sql';
    System cEncabezado;

	LET v_sql = 'echo "UNLOAD TO ' || TRIM (cNombreArchivo1) || ' DELIMITER '',''" > /tmp/queryhist.sql ';
	System v_sql;

	LET v_sql = 'echo "SELECT action,numtarjeta AS pan, ''+52''||RIGHT(LTRIM(RTRIM(telefono)),10) AS mobilenumber," >> /tmp/queryhist.sql ';
	System v_sql;

    LET v_sql = 'echo "LTRIM(RTRIM(correo_elec)) AS email, ''01'' AS segmentationindicator" >> /tmp/queryhist.sql ';
	System v_sql;

	LET v_sql = 'echo " from intercard:ctas_vcas  where numtarjeta <> ''''" >> /tmp/queryhist.sql';
	System v_sql;

	LET v_sql = "dbaccess intercard /tmp/queryhist.sql";
	System v_sql;

	LET v_sql="";

	--SE AÃ?Â?ADEN LOS ENCABEZADOS Y LOS RESULTADOS EXTRAIDOS AL ARCHIVO AUXILIAR.
	LET v_sql = "sed 's/$//g' "|| TRIM(cRuta) || "queryenc.sql >> " || TRIM (cNombreArchivo2);
    SYSTEM TRIM(v_sql);

    LET v_sql="";

	LET v_sql = "sed 's/$//g' "|| TRIM (cNombreArchivo1) || " >> " || TRIM (cNombreArchivo2);
    SYSTEM TRIM(v_sql);

    --SE PASA LA INFORMACION DESCARGADA AL ARCHIVO FINAL.
    LET v_sql = "";
    LET v_sql = "sed -e 's/.$//' "|| TRIM(cNombreArchivo2) || " >> " || TRIM (cNombreArchivo);
    SYSTEM v_sql;

	--BORRADO DE SCRIPTS GENERADOS EN EL PROCESO.
    LET v_sql = "";
    LET v_sql = "rm " || TRIM(cRuta) || "queryhist.sql";
    SYSTEM TRIM(v_sql);

    LET v_sql = "";
    LET v_sql = "rm " || TRIM(cRuta) || "queryenc.sql";
    SYSTEM TRIM(v_sql);

    LET v_sql = "";
    LET v_sql = "rm " || TRIM(cNombreArchivo1);
    SYSTEM TRIM(v_sql);

    LET v_sql = "";
    LET v_sql = "rm " || TRIM(cNombreArchivo2);
    SYSTEM TRIM(v_sql);

	-- DATOS PARA LA TABLA CONTROL.
	SELECT MAX(fecha::DATETIME YEAR TO SECOND + INTERVAL (01) SECOND(2) TO SECOND )
	INTO vfecha
	FROM intercard:ctas_vcas;

	IF  vfecha  IS NULL THEN
		LET vfecha = CURRENT;
	END IF

	-- CONTEO DE REGISTROS.
	SELECT COUNT(*)
	INTO vreg_ins
	FROM intercard:ctas_vcas;

	-- ELIMINA REGISTROS DE TABLA DE RESULTADOS Y TEMPORALES.
    --TRUNCATE TABLE intercard:ctas_vcas;
    TRUNCATE TABLE intercard:ctas_vcas DROP STORAGE;

	DROP TABLE BIN_VISA;
	DROP TABLE tmpctestarj;
    DROP TABLE tmptelefono;
    DROP TABLE tmpcorreo;
	DROP TABLE tmptarjeta;
    DROP TABLE tmptarj;
    DROP TABLE tmpctestarjfin;

	-- ACTUALIZAR TABLA CONTROL.
	UPDATE intercard:ctrl_info_ctes_vcas
	SET ( fecha, status_proc,cod_err, descripcion_err, reg_insertados) = ( vfecha, '0', vcod_ret, 'DESCARGA EXITOSA', vreg_ins);

 
    RETURN vcod_ret, 'DESCARGA EXITOSA';
END PROCEDURE;