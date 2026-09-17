CREATE PROCEDURE "informix".sp_bloquea_tarjeta(tarjeta CHAR(16))
	RETURNING CHAR(5) AS CodigoRetorno;
  
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRet CHAR(5);
		
	LET iSqlErr = 0;
	LET cCodRet = '00000';
	
BEGIN	
	ON EXCEPTION SET iSqlErr
	    IF iSqlErr <> 0 THEN
	        LET cCodRet = iSqlErr;
	        RETURN cCodRet;
	    END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/respaldosbd/mario/sp_bloquea_tarjeta.out';
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF  NVL(TRIM(tarjeta),'') <> '' THEN
		
		UPDATE intercard:"informix".tarjeta SET codstatustarjeta='BLO' WHERE numtarjeta = tarjeta;
		
	ELSE
		LET cCodRet = '00110';
	END IF;	

	RETURN cCodRet;

END;
END PROCEDURE
DOCUMENT
'Folio: 1730 - OperacionesMayoresConNIP',
'Autor: 95142134 Mario Gallardo',
'Fecha: 02/06/2015',
'Modificación: Se crea procedimiento para bloquear tarjeta en intercard.tarjeta',
'Sustento: RQM 06 221Operaciones Mayores con NIP y autorizadas por cajero o gerente.pdf',
'Solicita: Rodolfo Gómez',
'BD: intercard';

CREATE PROCEDURE "informix".sp_movimientosvi()
RETURNING VARCHAR(6), VARCHAR(100);

--##################################################################################################
--### Creado por: Ulises Jacobo Acevedo Aguilar												      ##
--##  Fecha: 23/07/2015																			  ##
--##  Descripcion: Se realizá el proceso de carga de información de la tabla de movimiento y      ##
--##               movimientohistorico a la tabla bdibi:bi_movimiento_consolidado_tarjeta		  ##
--##################################################################################################

     
    DEFINE  SQL_ERR                 INTEGER;
    DEFINE  ISAM_ERR                INTEGER;
    DEFINE  ERROR_INFO              VARCHAR(100);
    DEFINE  vcodret                 VARCHAR(6);
    DEFINE  p_mensaje               VARCHAR(100);
	DEFINE  vfecha_hoy              DATE;
	DEFINE  vfechavi_hoy            DATE;
	DEFINE  vindica                 varchar(1);
	DEFINE  vano                    VARCHAR(4);
	DEFINE  vmes                    VARCHAR(2);
	DEFINE  vdia                    VARCHAR(2);
	DEFINE  dias                    integer;
	DEFINE  vsql                    char(1150);
	DEFINE  vaniomes                VARCHAR(6);
	DEFINE  vaniomes2  				VARCHAR(6);
	DEFINE  vperiodo  				VARCHAR(6);
	DEFINE  vproductotarjeta        VARCHAR(3);
	DEFINE  vnumtarjeta             VARCHAR(16);
	DEFINE  nrows                   SMALLINT;
    DEFINE  vfecha                     	DATE;
    DEFINE  vbin                       	VARCHAR(6);
    DEFINE  vprodind                   	VARCHAR(2);
    DEFINE  vformato                   	VARCHAR(4);
    DEFINE  vcodtran                   	VARCHAR(2);
    DEFINE  vmetodocaptura             	VARCHAR(2);
    DEFINE  vcodigoiso                 	VARCHAR(2);
    DEFINE  vcodgironeg                	VARCHAR(4);
    DEFINE  vesnacional                	VARCHAR(1);
    DEFINE  vtrancajeropropio          	VARCHAR(1);
    DEFINE  vidreceptor                	VARCHAR(4);
    DEFINE  vtransaccionorigen         	VARCHAR(4);
    DEFINE  vtipotransaccionposdigitada	VARCHAR(2);
    DEFINE  vcantidad                  	INTEGER;
    DEFINE  vmonto1                    	DECIMAL(19,4);
    DEFINE  vmonto2                    	DECIMAL(19,4);
	DEFINE  vcontador                   INTEGER;
	
	
	DEFINE viContadorRegistros  INTEGER;
	DEFINE viContadorRegistros2 INTEGER;
    DEFINE vsFlagEnTransaccion  CHAR(1);
	
	DEFINE ultimo_dia_mes DATE;
	DEFINE primer_dia_mes DATE;
	DEFINE ultimo_dia_mes_hora DATETIME YEAR TO FRACTION(5);
	DEFINE primer_dia_mes_hora DATETIME YEAR TO FRACTION(5);
	DEFINE pperiodofin_hora DATETIME YEAR TO FRACTION(5);
	DEFINE pperiodini_hora DATETIME YEAR TO FRACTION(5);
	DEFINE FechaAux DATETIME YEAR TO FRACTION(5);
	
    LET  vbin = "";                        	
    LET  vprodind = "";                   	
    LET  vformato = "";                   	
    LET  vcodtran = "";                   	
    LET  vmetodocaptura = "";             	
    LET  vcodigoiso = "";                 	
    LET  vcodgironeg  = "";               	
    LET  vesnacional = "";                	
    LET  vtrancajeropropio = "";          	
    LET  vidreceptor = "";                	
    LET  vtransaccionorigen  = "";        	
    LET  vtipotransaccionposdigitada = ""; 	
    LET  vcantidad =0;
    LET  vmonto1 =0;
    LET  vmonto2 =0;
	LET  vcontador  =0;

  -- SET DEBUG FILE TO "/informix/c94796696/sp_movimientovi2.out";
  -- TRACE ON;
    
     BEGIN
    
     ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
	 SET DEBUG FILE TO "/resplogifx/sp_movimientovi.out";
     TRACE ON;
	
	 IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
				COMMIT WORK;
				LET vsFlagEnTransaccion = 'F';
      END IF;
	  LET vcodret    = SQL_ERR;
	  LET p_mensaje  = error_info;
	
      RETURN 	vcodret,p_mensaje;
		
   END EXCEPTION;
       


    
	SET ISOLATION TO DIRTY READ ;
     IF EXISTS ( SELECT dbsname, tabname FROM  sysmaster:SysTabNames  WHERE tabname = 'pasovi' AND dbsname= 'intercard') THEN
         DROP TABLE IF EXISTS intercard:pasovi;
		 DROP INDEX IF EXISTS intercard:pasovi.idxtmp_pasovi;
         DROP INDEX IF EXISTS intercard:pasovi.idxtmp_pasovi2;
    END IF;

SET ISOLATION TO DIRTY READ;
SELECT fecha_hoy INTO vfecha_hoy FROM  bdinteg:si_fechas;
--LET vfecha_hoy = '01/05/2015';
--LET vindica = pindica;
LET vano = SUBSTR(vfecha_hoy,7,10);
LET vmes = SUBSTR(vfecha_hoy,1,2);
LET vmes = vmes-01;
LET vmes =0||vmes;

-----operaciones de fechas
     LET ultimo_dia_mes = extend(extend(vfecha_hoy - 0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 0 units DAY;
     LET ultimo_dia_mes_hora = extend(extend(vfecha_hoy - 0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 0 units DAY;
     LET ultimo_dia_mes_hora = SUBSTRING(ultimo_dia_mes_hora FROM  1 FOR 10) || ' 00:00:00';
     --OBTIENE EL PRIMER DIA DEL MES DE CORTE
     LET primer_dia_mes = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);
     LET primer_dia_mes_hora = extend(extend(vfecha_hoy - 1 units MONTH ,YEAR TO MONTH)||"-01",YEAR TO DAY);
     LET primer_dia_mes_hora= SUBSTRING(primer_dia_mes_hora FROM  1 FOR 10) || ' 00:00:00';
	 
	 --OBTIENE EL AÑO Y MES DE LA FECHA	  
     let vaniomes =  year(ultimo_dia_mes) || LPAD (MONTH(ultimo_dia_mes),2,"00");
	 let dias = day(ultimo_dia_mes);
	 let vaniomes2 =  year(primer_dia_mes) || LPAD (MONTH(primer_dia_mes),2,"00");
	-- LET vfechahorainauth = extend(extend(vfechahorainauth - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);
 	
	  SET ISOLATION to dirty read;
      SELECT max(fecha) INTO vfechavi_hoy FROM bdibi@stag_ids1170:"informix".bi_movimiento_consolidado_tarjeta;
	   IF vfechavi_hoy >= vfecha_hoy THEN
      LET vcodret = '002';
      LET  p_mensaje  = 'Ya se ejecuto la opción mensual '||vfechavi_hoy||' ';
	  return vcodret, p_mensaje;
	   END IF;
	  


SET ISOLATION TO DIRTY READ; 
SET LOCK MODE TO WAIT 3;
SELECT cast(fechahorainauth as date) as fecha,
       substring(numtarjeta from 1 for 6) as Bin,       
       prodind,
       formato, 
       codtran,
       metodocaptura,
       codigoiso,
       codgironeg,       
       esnacional,              
       trancajeropropio,
       idreceptor,
       transaccionorigen,
       tipotransaccionposdigitada,codreversa,
      case when (formato = '0420' and codreversa = 2) then
           count(*)
          when (formato <> '0420' and codreversa = 0) then
           count(*) 
      end as cantidad,
	  case when (formato = '0420' and codreversa = 2) then
           sum(montorealrevfzda)
          when (formato <> '0420' and codreversa = 0) then
           sum(monto)
		    end as monto,
     case when (formato = '0420' and codreversa = 2) then
           sum(montocashback)
          when (formato <> '0420' and codreversa = 0) then
           sum(montocashback)
      end as montocashback
      FROM intercard:movimiento 
      WHERE fechahorainauth BETWEEN primer_dia_mes_hora AND ultimo_dia_mes_hora
      AND SUBSTR (numtarjeta,0,6) in  (SELECT bin FROM intercard:bines)        --Solo considerar los bines que están en InterCard:bines
      AND codigoiso is not null AND codigoiso != ('null') and codigoiso <> ''  --No considerar codigoiso nulos o en blanco
      AND prodind in('01','02')                                                --Solo considerar POS y ATM
      AND formato in ('0200','0220','0221','0420')                             --Solo considerar Operaciones Normales, Forzadas y Forzadas Recurrentes; las reversas solo se consideraran cuando son parciales
      AND codtran not in ('91','92','93','94','95','96','97')                  --No considerar transacciones de NIP de sucursal o contraseñas del portal
      AND ( codreversa = 0 or codreversa = 2)                                  --Solo considera transacciones completas o reversadas parcialmente
      AND movreversado = 'F'                                                   --No se contabilizan transacciones reversadas
      AND metodocaptura is not null AND metodocaptura != ('null')              --Solo considerar métodos de captura válidos, para un 0420 viene vacío
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14
      UNION ALL 
SELECT cast(fechahorainauth as date) as fecha,
       substring(numtarjeta from 1 for 6) as Bin,       
       prodind,
       formato, 
       codtran,
       metodocaptura,
       codigoiso,
       codgironeg,       
       esnacional,              
       trancajeropropio,
       idreceptor,
       transaccionorigen,
       tipotransaccionposdigitada,codreversa,
      case when (formato = '0420' and codreversa = 2) then
           count(*)
          when (formato <> '0420' and codreversa = 0) then
           count(*) 
      end as cantidad,
	  case when (formato = '0420' and codreversa = 2) then
           sum(montorealrevfzda)
          when (formato <> '0420' and codreversa = 0) then
           sum(monto)
		    end as monto,
     case when (formato = '0420' and codreversa = 2) then
           sum(montocashback)
          when (formato <> '0420' and codreversa = 0) then
           sum(montocashback)
      end as montocashback
      FROM intercard:movimientohistorico 
      WHERE fechahorainauth BETWEEN primer_dia_mes_hora AND ultimo_dia_mes_hora
      AND SUBSTR (numtarjeta,0,6) in  (SELECT bin FROM intercard:bines)        --Solo considerar los bines que están en InterCard:bines
      AND codigoiso is not null AND codigoiso != ('null') and codigoiso <> ''  --No considerar codigoiso nulos o en blanco
      AND prodind in('01','02')                                                --Solo considerar POS y ATM
      AND formato in ('0200','0220','0221','0420')                             --Solo considerar Operaciones Normales, Forzadas y Forzadas Recurrentes; las reversas solo se consideraran cuando son parciales
      AND codtran not in ('91','92','93','94','95','96','97')                  --No considerar transacciones de NIP de sucursal o contraseñas del portal
      AND ( codreversa = 0 or codreversa = 2)                                  --Solo considera transacciones completas o reversadas parcialmente
      AND movreversado = 'F'                                                   --No se contabilizan transacciones reversadas
      AND metodocaptura is not null AND metodocaptura != ('null')              --Solo considerar métodos de captura válidos, para un 0420 viene vacío
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14

    
		 INTO temp pasovi  WITH NO LOG;
		 CREATE INDEX idxtmp_pasovi ON pasovi(fecha) USING BTREE;
         CREATE INDEX idxtmp_pasovi2 ON pasovi(codigoiso) USING BTREE;
         UPDATE STATISTICS HIGH FOR TABLE pasovi;
		 
		 select count (*) into vcontador from intercard:pasovi;

    LET vsFlagEnTransaccion = 'F';
	LET viContadorRegistros = 0;
	LET viContadorRegistros2 = 0;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	FOREACH CUSOR1 WITH HOLD FOR	

         select fecha,bin,prodind,formato,codtran,metodocaptura,codigoiso,codgironeg,esnacional,trancajeropropio,idreceptor,transaccionorigen,tipotransaccionposdigitada,sum(cantidad) as cantidad,sum(monto) as monto1,sum(montocashback) as monto2           
		 INTO vfecha,vbin,vprodind,vformato,vcodtran,vmetodocaptura,vcodigoiso,vcodgironeg,vesnacional,vtrancajeropropio,vidreceptor,vtransaccionorigen,vtipotransaccionposdigitada,vcantidad,vmonto1,vmonto2
         from  intercard:pasovi GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13
		 INSERT INTO bdibi@stag_ids1170:"informix".bi_movimiento_consolidado_tarjeta (fecha,bin,prodind,formato,codtran,metodocaptura,codigoiso,codgironeg,esnacional,trancajeropropio,idreceptor,transaccionorigen,tipotransaccionposdigitada,cantidad,monto1,monto2)
         VALUES (vfecha,vbin,vprodind,vformato,vcodtran,vmetodocaptura,vcodigoiso,vcodgironeg,vesnacional,vtrancajeropropio,vidreceptor,vtransaccionorigen,vtipotransaccionposdigitada,vcantidad,vmonto1,vmonto2);
    
		--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
		IF (vsFlagEnTransaccion = 'F') THEN
			 BEGIN WORK;
			 LET vsFlagEnTransaccion = 'V';
		END IF;	 
		 
			 	    LET viContadorRegistros = viContadorRegistros + 1;
					LET viContadorRegistros2 = viContadorRegistros2 + 1;
			 
			 --SE APLICA update statistics medium A LA TABLA.
		    IF (viContadorRegistros = 100000) THEN --VERIFICA SI EL BLOKE 2 ALCANSO LA CONDICION PARA REALIZAR EL update statistics
			---UPDATE STATISTICS MEDIUM FOR TABLE bdibi@coppelsm_tcp:bi_movimiento_consolidado_tarjeta;
			LET viContadorRegistros2 = 0;
	        CONTINUE FOREACH;
		    END IF;

		--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
		   IF (viContadorRegistros = 1000) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
			LET viContadorRegistros = 0;
			CONTINUE FOREACH;
		   END IF;
		   
     END FOREACH;
		 
		   -- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
		END IF;
		 
		-- UPDATE STATISTICS MEDIUM FOR TABLE bdibi@coppelsm_tcp:bi_movimiento_consolidado_tarjeta;                                 
         DROP TABLE intercard:pasovi;
		 
    	LET vcodret = '000';
	    LET p_mensaje = 'PROCESO EXITOSO' ;

       RETURN 	vcodret,p_mensaje;
	 --END IF;
    
    END
    
END PROCEDURE;