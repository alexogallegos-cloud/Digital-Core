CREATE PROCEDURE "informix".sp_rcda_apert()
RETURNING CHAR(005) AS cod_ret,
		  CHAR(180) AS mensaje;
    
    -- // DECLARACION DE VARIABLES
    DEFINE vusuario         CHAR(8);
    DEFINE vtipo_reg        INTEGER;
    DEFINE vempresa         CHAR(3);
    DEFINE vsucursal        CHAR(4);
    DEFINE vejecutivo       CHAR(8);
    DEFINE vnombre          CHAR(45);
    DEFINE vproducto        CHAR(4);
    DEFINE vfechacierre     CHAR(10);
    DEFINE vnumtdc          INTEGER;
    DEFINE vmetanumtdc      INTEGER;
    DEFINE vcumpmetatdc     MONEY(18,2);
    DEFINE vmeta 			INTEGER;
    
    DEFINE SQL_ERR          INTEGER;
    DEFINE ISAM_ERR         INTEGER;
    DEFINE ERROR_INFO       VARCHAR(80);
    DEFINE P_COD_RET        VARCHAR(6);
    DEFINE P_COD_RET2       VARCHAR(6);
    DEFINE P_MENSAJE        VARCHAR(80);
    DEFINE dFecha           DATE;
    DEFINE dFechafto        CHAR(10);
    DEFINE dFechaCorte      DATE;
    DEFINE dFechaAnt        DATE;
    DEFINE dFechaAnioAnt    DATE;
    DEFINE cFechaAnioAnt    CHAR(06);
    DEFINE dFechahoy        DATE;
    DEFINE dult_dia_mes     DATE;
    DEFINE dfechaantier     DATE;
    DEFINE iDiasMes         INTEGER;
    DEFINE vpaso		    INTEGER;	
    
    DEFINE cod_ret			CHAR(04);
    DEFINE vmensaje			CHAR(80);	
    
    DEFINE op_sucursal		CHAR(04);
    DEFINE op_usuario	 	CHAR(08);
    DEFINE op_fech_alt		DATE;
    DEFINE op_n_transacc	INTEGER;
    DEFINE op_monto		 	MONEY(18,2);
    DEFINE vcajero			CHAR(08);
    
    DEFINE vsucconv	        CHAR(004);
    DEFINE vcliconv	        CHAR(020);
    DEFINE	vjecutconv	    CHAR(008);
    DEFINE vct_conv	        CHAR(006);
    DEFINE vynconv		    INTEGER;	
    DEFINE vcuentaconv      CHAR(020);
    DEFINE vnombrecb 	    CHAR(104); 
    
    DEFINE pgmincodigo_retorno	CHAR(6);
    DEFINE pgminmensaje_retorno CHAR(80);
    DEFINE pgminnumero_credito  CHAR(20);
    DEFINE pgmincodigo_tipcred  CHAR(2);
    DEFINE pgminfecha_origen	DATE;
    DEFINE pgminfecha_prox_pago DATE;
    DEFINE pgminpago_minimo     DECIMAL(18,2);
    DEFINE pgminfecha_ult_pago  DATE;
    DEFINE pgminplazo			INTEGER;
	
	
	
	DEFINE v_empresa       char(3)     ; 
    DEFINE v_sucursal      char(4)     ;
    DEFINE v_tipo          char(5)     ; 
    DEFINE v_ejecutivo     char(8)     ;
    DEFINE v_producto      char(4)     ; 
    DEFINE v_num_ctasdia   integer     ;
    DEFINE v_monto_ctasdia money(16,2) ; 
	DEFINE v_numcte         char(20)   ;
	DEFINE v_num_referencia char(20)   ;
	DEFINE v_fecha_insert   date       ;
	DEFINE v_nombrearchivo  char(35)   ;
	DEFINE v_fecha          date       ;
	DEFINE v_promotor       char(8)    ; 
	
	
	
    
    BEGIN
    
    -- // CONTROL DE ERRORES
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        SET DEBUG FILE TO '/resplogifx/conciliachq/sp_rcda_apert.err';
        TRACE ON;
        
        LET P_COD_RET  = SQL_ERR;
        LET P_COD_RET2 = ISAM_ERR;
        LET P_MENSAJE  = ERROR_INFO||' sp_rcda_apert en paso '||vpaso;
        
        INSERT INTO "informix".mi_rcda_cierresucerror( fecha_cierre, estatus_ejec, codigo_error, desc_error )
        SELECT fecha_ant, 'F', P_COD_RET, P_MENSAJE 
          FROM "informix".mi_fechas;
          
        RETURN P_COD_RET, P_MENSAJE;
    END EXCEPTION;
    
    --SET DEBUG FILE TO '/informix/rsv/especial/incidencia/sp_rcda_apert.out';
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // INICIALIZACION
    LET P_COD_RET = '00000';
    LET P_MENSAJE ='PROCESO EXITOSO';
    
    -- // SE OBTIENEN LAS FECHAS
    LET vpaso = 0;  
    
    SELECT fecha_ant, DAY(ult_dia_mes)::INT, (fecha_ant - 1), fecha_hoy, ult_dia_mes 
      INTO dFecha, iDiasMes, dfechaantier, dFechahoy, dult_dia_mes 
      FROM "informix".mi_fechas;
    
    IF ( SELECT COUNT(codigo_error) FROM "informix".mi_rcda_cierresucerror WHERE fecha_cierre = dfecha AND codigo_error = 001 ) > 0 THEN
        RETURN '001','fecha ya procesada';
    END IF;
    
    
    -- // LIMPIA LA TABLA DEL ACUMULADO DE SOLICITUDES MENSUAL AL INICIO DE MES (01/04/2012)
    LET vpaso = 1;
    
    IF ( DAY(dFechahoy)::INT) = 2 OR ( DAY(dFechahoy)::INT) = 02 THEN
        TRUNCATE TABLE "informix".mi_rcda_solic; 
    END IF;
    
	LET vpaso = 2;  
    
    -- // Se limpia la tabla temporal de paso 
    TRUNCATE TABLE "informix".mi_rcda_suc;
    
    
    BEGIN WORK;
	
   
          -- INSERTA AL RCD LAS SOLICITUDES Y PRECALIFICACIONES REALIZADAS EN EL DIA Y QUE NO HAN SIDO CONSIDERADAS EN EL MES
          -- 13/09/2018 Se omiten solicitudes con estatus PC JORGE LUIS ARIAS
		  select empresa, sucursal, user_insert, num_solicitud, 
                 case when num_producto not in ('6500','6300','6400','7600','7700') or user_insert = 'interact' then '6001'  --- Se agrega producto 7600, 7700 y 6400 para que no se considere como 6001
                      else num_producto 
                 end as num_producto, 
                 numcte, '' as num_referencia, fecha_insert
            from bdisolic:ss_solicitudes sol
           where fecha_insert = dFecha  
             AND user_insert <> 'interact' 
			 AND num_producto = '6500'
             and numcte not in ( SELECT rpt.numcte 
                                   FROM "informix".mi_rcda_solic rpt
                                  WHERE rpt.numcte = sol.numcte 
                                    and rpt.sucursal = sol.sucursal
									and rpt.num_producto = sol.num_producto	) --Se agrega validacion tambien por producto
             and num_solicitud = ( Select min(num_solicitud) 
                                     from bdisolic:ss_solicitudes soli2  
                                    where fecha_insert = dFecha 
                                      and soli2.numcte = sol.numcte 
                                      and soli2.num_producto = sol.num_producto 
                                      --and soli2.status_solicitud = sol.status_solicitud --Se quita validacion sobre solicitudes duplicadas el mismo dia, sin importar status
                                      and soli2.sucursal = sol.sucursal
										AND soli2.status_solicitud NOT IN ('PC','AN','CN'))	--Se agrega validacion para no contar las solicitudes duplicadas mismo dia en estatus PC,AN,CN	04/01/2019	
			AND sol.status_solicitud NOT IN ('PC','AN','CN') --Se agrega validacion para solicitudes AN y CN 04/01/2019 JORGE L ARIAS
          into temp solicis with no log;
    
    COMMIT WORK;    
    
    LET vpaso = 6;
    
    BEGIN WORK;
    
    select 'APERC' as tipo, empresa, sucursal, user_insert, num_producto, 
           case when num_producto = '6400' then count(numcte) * 2 --- Se agrega validaciÃÂ³n para contabilizar al doble el producto 6400
                else count(numcte) 
           end as num_ctasdia  
      from solicis
     where fecha_insert = dFecha 
       and (numcte is not null or numcte <> '') 
       and numcte > "000000000"
     group by 1, 2, 3, 4, 5
    union all
    select 'APERC' as tipo, empresa, sucursal, user_insert, num_producto,
           case when num_producto = '6400' then count(numcte) * 2 --- Se agrega validaciÃÂ³n para contabilizar al doble el producto 6400
                else count(numcte) 
           end as num_ctasdia 
      from solicis
     where fecha_insert = dFecha 
       and (num_referencia is not null or num_referencia <> '') 
       and num_referencia > "0"
     group by 1, 2, 3, 4, 5
    into temp mi_rptsolic2 with no log;
    
    COMMIT WORK;
    
    LET vpaso = 7;
    
    BEGIN WORK;		
    
    UPDATE mi_rptsolic2 
       SET num_producto = '6001' 
     WHERE num_producto = '6300';
    
    COMMIT WORK;


    BEGIN WORK;
	
	--- LIMPIA VARIABLES 
	LET v_tipo        = '';
	LET v_empresa     = '';   
    LET v_sucursal    = '';  
    LET v_ejecutivo   = ''; 
    LET v_producto    = '';  
    LET v_num_ctasdia = ''; 
   
	
	FOREACH WITH HOLD
	
	   
        ---  insert into "informix".mi_rcda_suc( tipo, empresa, sucursal, ejecutivo, producto, num_ctasdia )
          select tipo  , empresa  , sucursal  , user_insert , num_producto, sum(num_ctasdia) as num_ctasdia
		    into v_tipo, v_empresa, v_sucursal, v_ejecutivo , v_producto  , v_num_ctasdia 
            from mi_rptsolic2 
           group by tipo, empresa, sucursal, user_insert, num_producto
		   
		   
		   
		  
		   INSERT INTO "informix".mi_rcda_suc(tipo  ,empresa  ,sucursal  ,ejecutivo  ,producto  ,num_ctasdia  )
	            VALUES                       (v_tipo,v_empresa,v_sucursal,v_ejecutivo,v_producto,v_num_ctasdia);
		  
		   
		   
    END FOREACH;
       
    COMMIT WORK;
	
	
    
    LET vpaso = 8;  
    
	
	
	--- LIMPIA VARIABLES 
	LET v_empresa     = '';   
    LET v_sucursal    = '';  
    LET v_ejecutivo   = ''; 
    LET v_producto    = '';  
    LET v_numcte      = '';
	LET v_num_referencia = '';
	
	FOREACH WITH HOLD	
	

           --insert into "informix".mi_rcda_solic( empresa, sucursal, ejecutivo, num_producto, numcte, num_referencia, fecha_insert )
           select empresa, sucursal, user_insert, num_producto, numcte, 		 
                  case when num_solicitud = '' then num_referencia  
                       when num_referencia = '' then num_solicitud
                       else '' 
                  end as num_referencia,		   
                  fecha_insert 
		     into v_empresa,v_sucursal,v_ejecutivo,v_producto,v_numcte,v_num_referencia,v_fecha_insert
             FROM solicis
            WHERE fecha_insert = dfecha
			
			
		  
		   INSERT INTO "informix".mi_rcda_solic( empresa , sucursal , ejecutivo  , num_producto, numcte , num_referencia , fecha_insert )
	            VALUES                         (v_empresa,v_sucursal, v_ejecutivo,v_producto   ,v_numcte,v_num_referencia,v_fecha_insert);
		  
		   
	END FOREACH;
			
			
    drop table solicis; 
    drop table mi_rptsolic2;  
    
    /* #################################################  TARJETA DEPARTAMENTAL COPPEL ENTREGADAS  ################################################# */
    
	--- LIMPIA VARIABLES 
	LET v_tipo        = '';
	LET v_empresa     = '';   
    LET v_sucursal    = '';  
    LET v_ejecutivo   = ''; 
    LET v_producto    = '';  
    LET v_num_ctasdia = ''; 
   
	{

	     -- INSERT INTO "informix".mi_rcda_suc(tipo, empresa, sucursal, ejecutivo, producto, num_ctasdia)
		 --13/09/2018 se cuenta la tarjeta entregada al ejecutivo que entrego la tarjeta JORGE LUIS ARIAS
          SELECT 'APERC' AS tipo, aut.empresa, /*sol.sucursal*/ 
                 case when ( SELECT sucursal FROM bdinteg:si_ejecut eje WHERE eje.ejecutivo = sol.user_insert )  is not null then 
                      ( SELECT sucursal FROM bdinteg:si_ejecut eje WHERE eje.ejecutivo = sol.user_insert )
                      else sol.sucursal 
                 end as sucursal, 
                 /*sol.user_insert,*/aut.ejecutivo_auto, '6566' as producto, count(*) as numero
			INTO  v_tipo        , v_empresa, v_sucursal , v_ejecutivo , v_producto        ,  v_num_ctasdia	
            FROM bdisolic:ss_solicitudes sol 
           inner join bdisolic:ss_autorizacion aut on ( aut.fecha_salida = dFecha and aut.status_solicitud = 'AP' and sol.num_solicitud = aut.num_solicitud )
           where sol.status_solicitud = 'AP' 
             and sol.num_producto = '6500'
           group by 2, 3, 4
		   
		   
		     
	       	  INSERT INTO "informix".mi_rcda_suc(tipo  ,empresa  ,sucursal  ,ejecutivo  ,producto  ,num_ctasdia )
	               VALUES                       (v_tipo,v_empresa,v_sucursal,v_ejecutivo,v_producto,v_num_ctasdia);
	       	 
	}		  
			  
		     -- INSERT INTO "informix".mi_rcda_suc(tipo, empresa, sucursal, ejecutivo, producto, num_ctasdia)
          SELECT {+INDEX(bdisolic:ss_autorizacion idx_ss_solicitud_status_salida),+INDEX(bdisolic:ss_solicitudes idx_ss_solicitudes3),+INDEX(bdinteg:si_adiccoppel idx_adiccoppel3)
				,+INDEX(bdinteg:si_ejecut idx_si_ejecut)}
				'APERC' AS tipo, 
		         aut.empresa, /*sol.sucursal*/ 
                 eje.sucursal,  
                 /*sol.user_insert*/adic.user_insert,
				 '6566' as producto,   
				 count(*) as numero
            FROM bdisolic:ss_solicitudes sol
			 inner join bdisolic:ss_autorizacion aut on ( aut.fecha_salida = dFecha and aut.status_solicitud = 'AP' and sol.num_solicitud = aut.num_solicitud )
			 inner join bdinteg:si_adiccoppel adic on ( adic.fechamov = dFecha and adic.numcte = sol.numcte ) 
			 inner join bdinteg:si_ejecut eje on( eje.ejecutivo = adic.user_insert )
			where sol.status_solicitud = 'AP'
			 and adic.sucursal = eje.sucursal
             and sol.num_producto = '6500'
			 and eje.sucursal is not null
			group by 2,3,4
			 
			INTO TEMP tmp_transacciones_total with no log;			
		    
			FOREACH WITH HOLD
			
			       SELECT tipo  , empresa  ,sucursal   ,user_insert ,producto  , numero
			        INTO  v_tipo, v_empresa,v_sucursal ,v_ejecutivo ,v_producto, v_num_ctasdia
			        FROM  tmp_transacciones_total
			 
         		   
		         
	       	       INSERT INTO "informix".mi_rcda_suc(tipo  ,empresa  ,sucursal  ,ejecutivo  ,producto  ,num_ctasdia )
	                      VALUES                     (v_tipo,v_empresa,v_sucursal,v_ejecutivo,v_producto,v_num_ctasdia);
	       	       
		   
            END FOREACH;
			
		 --ELIMINA LAS TABLAS TEMPORALES   
		DROP TABLE tmp_transacciones_total;
		   
          
    
	LET vpaso = 12;
    
    RETURN P_COD_RET, P_MENSAJE;
    
    END
    
END PROCEDURE;