CREATE PROCEDURE "informix".sp_reportenegocio_pbajj	( pPeriodicidad CHAR(1), pNumeroDesfase SMALLINT )
---ASIGNACION DE NOMBRE A LAS VARIABLRES DE RETORNO
RETURNING VARCHAR(5) AS CODIGO_RETORNO, VARCHAR (50) AS MENSAJE_RETORNO;						 
 
	--Definicion de variables
    DEFINE  codigo_retorno      CHAR(5);				
	DEFINE  mensaje_retorno     CHAR(50);
	DEFINE  CODIGO_RETORNO2     CHAR(5);
	DEFINE  MENSAJE_RESPUESTA2  CHAR(50);
    DEFINE  sfecha_hoy			DATE; 
	DEFINE  vFechaIntegral      DATE;
	
	DEFINE vpri_dia_mes  	   DATE; 
    DEFINE ultimo_dia_mes_hora DATETIME YEAR TO FRACTION(5);
    DEFINE primer_dia_mes_hora DATETIME YEAR TO FRACTION(5);
	DEFINE vaniomes       char(6);
	DEFINE CONTADOR_TRANSACCIONES SMALLINT;
		
	DEFINE vsecuencia     varchar(7);
	DEFINE vnumtarjeta    varchar(16);
	DEFINE vcodigoneg     varchar(4);
	DEFINE vmetodocaptura varchar(2);
	DEFINE vidreceptor    varchar(4);
	DEFINE vinfreceptor   varchar(40);
	DEFINE vcodigoiso     varchar(2);
	DEFINE vmonto         decimal(19,4);
	DEFINE vesnacional    varchar(1);
	DEFINE vtipotransaccionposdigitada varchar(2);
		   
	DEFINE TIPO_PLANTILLA 		varchar(20); 
    DEFINE TIPO_PLANTILLA2 	    varchar(30); 		   
    DEFINE RUTA_DESTINO 		varchar(80);
		      
    DEFINE  vcodgironeg2        varchar(4);
    DEFINE  vdescgironeg2       varchar(80);
    DEFINE  vdescripcion2       varchar(30);
    DEFINE  vtransacciones2     integer;
    DEFINE  vmonto2             decimal(19,4);
    DEFINE  vpromedio2          decimal(19,4);
    DEFINE  vproducto2          varchar(3);
    DEFINE  vperiodo2           char(6);
    DEFINE  vidreceptor2        varchar(4);
    DEFINE  vinfreceptor2       varchar(40);
    DEFINE  vmetodocaptura2     varchar(2);
    DEFINE  vesnacional2        varchar(1);  
    DEFINE	vsql			    char(1150);
	
    DEFINE  vproductotarjeta        varchar(3);
    DEFINE  vproductotarjeta2       varchar(3);	
		   
    DEFINE  v_ranking               integer;
    DEFINE  v_ranking2              integer;
	
    DEFINE vExecuteSQL LVARCHAR(8000);
    DEFINE NOMBRE_ARCHIVO    VARCHAR(50);
    DEFINE NOMBRE_ARCHIVO2   VARCHAR(50);
    DEFINE NOMBRE_ARCHIVO3   VARCHAR(50);
    DEFINE SCRIPT_EJECUCION  VARCHAR(30);
    DEFINE SCRIPT_EJECUCION2 VARCHAR(30);
    DEFINE SCRIPT_EJECUCION3 VARCHAR(30);
    DEFINE SCRIPT_EJECUCION4 VARCHAR(30);
    DEFINE SCRIPT_EJECUCION5 VARCHAR(30);
    DEFINE SCRIPT_EJECUCION6 VARCHAR(30);
 
    DEFINE  icommit	    INTEGER;
	DEFINE SQLERR		INTEGER;
	DEFINE ISAM_ERR		INTEGER;
	DEFINE ERROR_INFO	VARCHAR(80);  
----------------------------------------------- 
	LET  vFechaIntegral     = ''; 
    LET  CODIGO_RETORNO2    = '';
	LET  MENSAJE_RESPUESTA2 = '';
 
    LET vsecuencia          = ''; 
	LET vnumtarjeta         = '';
	LET vcodigoneg          = '';
	LET vmetodocaptura      = '';
	LET vidreceptor         = '';
	LET vinfreceptor        = '';
	LET vcodigoiso          = '';
	LET vmonto              =  0;
	LET vesnacional         = '';
    LET vcodgironeg2        = '';
    LET vdescgironeg2       = '';
    LET vdescripcion2       = '';
    LET vtransacciones2     =  0;
    LET vmonto2             =  0;
    LET vpromedio2          =  0;
    LET vproducto2          = '';
    LET vperiodo2           = '';
    LET vidreceptor2        = '';
    LET vinfreceptor2       = '';
    LET vmetodocaptura2     = '';
    LET vesnacional2        = '';
    LET vproductotarjeta    = ""; 
    LET vproductotarjeta2   = "";  
	LET vtipotransaccionposdigitada = '';

    LET RUTA_DESTINO     = '/RESPALDOSNEW/';
	LET TIPO_PLANTILLA	 = 'GirosNegocioNacional'; 
    LET TIPO_PLANTILLA2	 = 'ReporteEstablecimientoNacional'; 
 
    LET  v_ranking  = 0; 
    LET  v_ranking2 = 0;
 
    LET icommit 		  = 0;
	LET vExecuteSQL       = '';
    LET NOMBRE_ARCHIVO    = 'mov_top_gironegocio_';
    LET NOMBRE_ARCHIVO2   = 'mov_tempfac_giro_';
	LET NOMBRE_ARCHIVO3   = 'mov_tempfac_esta_';
    LET SCRIPT_EJECUCION  = 'script_txn_giro.sql';
	LET SCRIPT_EJECUCION2 = 'mov_top_giros';
	LET SCRIPT_EJECUCION5 = 'mov_temp_giro';
	LET SCRIPT_EJECUCION6 = 'mov_temp_est';
	
	LET SCRIPT_EJECUCION3 = 'script_temp_giro.sql';
	LET SCRIPT_EJECUCION4 = 'script_temp_est.sql';
	LET CONTADOR_TRANSACCIONES = 1000;

	LET codigo_retorno  = '00000';
    LET mensaje_retorno = 'PROCESO EXITOSO';
	
	
	--SET DEBUG FILE TO RUTA_DESTINO || "sp_reportenegocio.out";
    --TRACE ON;        

BEGIN 
		
        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
            
            SET DEBUG FILE TO RUTA_DESTINO || "sp_reportenegocio.out" WITH APPEND;
            TRACE ON;
            
            IF ( SQLERR <> 0 ) THEN
                LET CODIGO_RETORNO = SQLERR;
                LET MENSAJE_RETORNO = ERROR_INFO;                
                RETURN CODIGO_RETORNO, MENSAJE_RETORNO;
            END IF;
			
        END EXCEPTION;	

	
	    SET ISOLATION TO DIRTY READ; 
	    SET LOCK MODE TO WAIT 3;
		--------------------------------------------------------------------------------------------------------	
		IF  pNumeroDesfase  = '1' THEN 	  
		
		 BEGIN;
		   TRUNCATE TABLE "informix".paso_mov_giro;
         COMMIT; 
		 
		END IF; 
  	
		BEGIN;
             DROP TABLE IF EXISTS intercard:paso_nego;
		COMMIT;
	
		BEGIN;
             DROP TABLE IF EXISTS intercard:paso_estab;
		COMMIT;
 
        --------------------------------------------------------------------------------------------------------
		-----------<ObtenciÃ³n de fechas>-------------------  
 
		           EXECUTE PROCEDURE sp_intercard_calcular_periodos(pPeriodicidad, pNumeroDesfase)  
		           INTO  CODIGO_RETORNO2, MENSAJE_RESPUESTA2, primer_dia_mes_hora, ultimo_dia_mes_hora, vFechaIntegral;
	 
		            SELECT pri_dia_mes INTO  vpri_dia_mes  FROM bdinteg:si_fechas WHERE empresa= '001';  
		            let vaniomes =  year(vpri_dia_mes) || LPAD (MONTH(vpri_dia_mes),2,"0");   
 
		    -----------<Fin ObtenciÃ³n de fechas>------------------- 
                
				-- Elimina el reporte anterior solo cuando se procesa la primera parte de la descarga 	
				   --------------------
				    LET vExecuteSQL = '';
                    LET vExecuteSQL = ' rm -f '||RUTA_DESTINO||NOMBRE_ARCHIVO||'*';
                    SYSTEM vExecuteSQL;	
                   --------------------
                   LET vExecuteSQL	= '';
                   LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 4; UNLOAD TO '||RUTA_DESTINO||NOMBRE_ARCHIVO||vaniomes||'.unl '||
				                     'SELECT  mov.codgironeg AS codgironeg, gn.descgironeg AS descgironeg, mov.metodocaptura,  '||
		                             'CASE  '||
				                     'WHEN metodocaptura =  ''"'||'05'||'"''  THEN   ''"'||'CHIP'||'"''      '||             
									 'WHEN metodocaptura =  ''"'||'90'||'"''  THEN   ''"'||'Deslizada'||'"'' '||    
				                     'WHEN metodocaptura =  ''"'||'01'||'"''   AND   tipotransaccionposdigitada =  ''"'||'AV'||'"''  THEN  ''"'||'Telemarketing'||'"'' '||
				                     'WHEN metodocaptura =  ''"'||'01'||'"''   AND   tipotransaccionposdigitada =  ''"'||'CE'||'"''  THEN  ''"'||'Comercio_Elect'||'"'' '||  
				                     'WHEN metodocaptura =  ''"'||'01'||'"''   AND   tipotransaccionposdigitada =  ''"'||'CA'||'"''  THEN  ''"'||'Cargo_Automatico'||'"''  '||  
				                     'WHEN metodocaptura =  ''"'||'01'||'"''   AND   tipotransaccionposdigitada =  ''"'||'HO'||'"''  THEN  ''"'||'Hotel'||'"''  '||  
				                     'WHEN metodocaptura =  ''"'||'01'||'"''   AND   tipotransaccionposdigitada =  ''"'||'TG'||'"''  THEN  ''"'||'TAG'||'"'' '||  
				                     'WHEN metodocaptura =  ''"'||'01'||'"''   AND   tipotransaccionposdigitada = ''"'||'ND'||'"''   THEN  ''"'||'No_Determinada'||'"''  '||  
				                     'WHEN metodocaptura =  ''"'||'01'||'"''  AND    tipotransaccionposdigitada = ''"'||''||'"''     THEN  ''"'||'No_clasificada'||'"'' '||  
				                     'WHEN metodocaptura =  ''"'||'81'||'"''  THEN   ''"'||'Ecommerce MasterCard'||'"'' '||  
				                     'WHEN metodocaptura =  ''"'||'80'||'"''  THEN   ''"'||'FallBack'||'"''             '||  
				                     'WHEN metodocaptura =  ''"'||'07'||'"''   THEN  ''"'||'Contactless'||'"'' '||  
				                     'WHEN metodocaptura IN ( ''"'||'00'||'"'' , ''"'||'02'||'"'') THEN ''"'||'Metodos Captura No Determinados'||'"'' '||  
									 ' END AS descripcion, '||  
		                             'mov.idreceptor AS idreceptor, '||   
		                             'mov.infreceptor AS infreceptor, '||   
		                             'COUNT(mov.codigoiso) AS transacciones,  '||   
		                             'sum(nvl(mov.monto,0)) AS monto,  '||  
									 ' 0 AS promedio, '||    
		                             --'(sum(nvl(mov.monto,0))/COUNT(mov.codigoiso)) AS promedio,  '||   
		                             'tar.codproductotarjeta AS producto,  '||   
		                             'mov.esnacional AS esnacional,  '||    
		                             '   '''||vaniomes||'''  AS periodo  '||       
		                             'FROM intercard:movimiento mov, intercard:tarjeta tar,intercard:gironegocio gn  '||    
		                             'WHERE mov.fechahorainauth BETWEEN  '''||primer_dia_mes_hora||''' AND  '''||ultimo_dia_mes_hora||'''  '||  
		                             'AND mov.numtarjeta = tar.numtarjeta   '||  
                                     'AND gn.codgironeg = mov.codgironeg   '||  
                                     'AND SUBSTR (tar.numtarjeta,0,6) IN  (SELECT bin FROM intercard:bines)   '||  
		                             'AND mov.prodind =  ''"'||'02'||'"''   '||  
		                             'AND mov.codigoiso = ''"'||'00'||'"''   '||  
		                             'AND mov.esnacional =  ''"'||'V'||'"''   '||  
                                     'AND mov.codigoiso IS NOT NULL AND mov.codigoiso !=  (''"'||'null'||'"'')  AND mov.codigoiso <> ''"'||''||'"''    '||  
		                             'AND formato in  (''"'||'0200'||'"'',''"'||'0220'||'"'',''"'||'0221'||'"'',''"'||'0420'||'"'')   '||   
                                     'AND mov.movreversado =   ''"'||'F'||'"''     '||   
                                     'AND mov.metodocaptura IS NOT NULL AND mov.metodocaptura != (''"'||'null'||'"'')   '||   
		                             'GROUP BY 1,2,3,4,5,6,10,11,12     '||  	 
		                             ' UNION ALL   '||   
						             'SELECT  movh.codgironeg AS codgironeg, gn.descgironeg AS descgironeg, movh.metodocaptura,  '||
		                             'CASE  '||
				                     'WHEN metodocaptura =  ''"'||'05'||'"''  THEN   ''"'||'CHIP'||'"''      '||             
									 'WHEN metodocaptura =  ''"'||'90'||'"''  THEN   ''"'||'Deslizada'||'"'' '||    
				                     'WHEN metodocaptura =  ''"'||'01'||'"''   AND   tipotransaccionposdigitada =  ''"'||'AV'||'"''  THEN  ''"'||'Telemarketing'||'"'' '||
				                     'WHEN metodocaptura =  ''"'||'01'||'"''   AND   tipotransaccionposdigitada =  ''"'||'CE'||'"''  THEN  ''"'||'Comercio_Elect'||'"'' '||  
				                     'WHEN metodocaptura =  ''"'||'01'||'"''   AND   tipotransaccionposdigitada =  ''"'||'CA'||'"''  THEN  ''"'||'Cargo_Automatico'||'"''  '||  
				                     'WHEN metodocaptura =  ''"'||'01'||'"''   AND   tipotransaccionposdigitada =  ''"'||'HO'||'"''  THEN  ''"'||'Hotel'||'"''  '||  
				                     'WHEN metodocaptura =  ''"'||'01'||'"''   AND   tipotransaccionposdigitada =  ''"'||'TG'||'"''  THEN  ''"'||'TAG'||'"'' '||  
				                     'WHEN metodocaptura =  ''"'||'01'||'"''   AND   tipotransaccionposdigitada = ''"'||'ND'||'"''   THEN  ''"'||'No_Determinada'||'"''  '||  
				                     'WHEN metodocaptura =  ''"'||'01'||'"''  AND    tipotransaccionposdigitada = ''"'||''||'"''     THEN  ''"'||'No_clasificada'||'"'' '||  
				                     'WHEN metodocaptura =  ''"'||'81'||'"''  THEN   ''"'||'Ecommerce MasterCard'||'"'' '||  
				                     'WHEN metodocaptura =  ''"'||'80'||'"''  THEN   ''"'||'FallBack'||'"''             '||  
				                     'WHEN metodocaptura =  ''"'||'07'||'"''   THEN  ''"'||'Contactless'||'"'' '||  
				                     'WHEN metodocaptura IN ( ''"'||'00'||'"'' , ''"'||'02'||'"'') THEN ''"'||'Metodos Captura No Determinados'||'"'' '|| 
									 ' END AS descripcion, '|| 
		                             'movh.idreceptor AS idreceptor, '||   
		                             'movh.infreceptor AS infreceptor, '||   
		                             'COUNT(movh.codigoiso) AS transacciones,  '||   
		                             'sum(nvl(movh.monto,0)) AS monto,  '||  
                                     ' 0 AS promedio, '||    									 
		                             --'(sum(nvl(movh.monto,0))/COUNT(movh.codigoiso)) AS promedio,  '||   
		                             'tar.codproductotarjeta AS producto,  '||   
		                             'movh.esnacional AS esnacional,  '||    
		                             '   '''||vaniomes||'''  AS periodo  '||       
		                             'FROM intercard:movimientohistorico movh, intercard:tarjeta tar,intercard:gironegocio gn  '||    
		                             'WHERE movh.fechahorainauth BETWEEN  '''||primer_dia_mes_hora||''' AND  '''||ultimo_dia_mes_hora||'''  '||  
		                             'AND movh.numtarjeta = tar.numtarjeta   '||  
                                     'AND gn.codgironeg = movh.codgironeg   '||  
                                     'AND SUBSTR (tar.numtarjeta,0,6) IN  (SELECT bin FROM intercard:bines)   '||  
		                             'AND movh.prodind =  ''"'||'02'||'"''   '||  
		                             'AND movh.codigoiso = ''"'||'00'||'"''   '||  
		                             'AND movh.esnacional =  ''"'||'V'||'"''   '||  
                                     'AND movh.codigoiso IS NOT NULL AND movh.codigoiso !=  (''"'||'null'||'"'')  AND movh.codigoiso <> ''"'||''||'"''   '||  
		                             'AND formato in  (''"'||'0200'||'"'',''"'||'0220'||'"'',''"'||'0221'||'"'',''"'||'0420'||'"'')   '||   
                                     'AND movh.movreversado =   ''"'||'F'||'"''     '||   
                                     'AND movh.metodocaptura IS NOT NULL AND movh.metodocaptura != (''"'||'null'||'"'')   '||   
		                             'GROUP BY 1,2,3,4,5,6,10,11,12     '||  
		                             ' ORDER BY transacciones DESC;  '||
                                     '" >'||RUTA_DESTINO||SCRIPT_EJECUCION;
				     SYSTEM vExecuteSQL;
  			        -----------------------------------------------------------------------------------------------------------------	
		            --Asigancion de permisos del archivo .sql
		            let vExecuteSQL ='';			
		            let vExecuteSQL= 'chmod 777 ' ||RUTA_DESTINO||SCRIPT_EJECUCION;
		            system vExecuteSQL;
		            
		            let vExecuteSQL = '';
                    let vExecuteSQL = 'dbaccess intercard '||RUTA_DESTINO||SCRIPT_EJECUCION;
                    system vExecuteSQL;	  
                    ---------------------------------------------------------------------------------------------------------------            
			        --eliminaciÃ³n de archivos
		            let vExecuteSQL = '';
                    let vExecuteSQL ='rm -f '||RUTA_DESTINO||SCRIPT_EJECUCION;
                    system vExecuteSQL; 
				 
			       -------------------------------------------------------------------------------------------------------------
                    --- Genera dbload para la carga de registros a la tabla  destino
 	                LET vExecuteSQL = '';
                    LET vExecuteSQL = "echo "||'"'|| "file '"||RUTA_DESTINO||NOMBRE_ARCHIVO||vaniomes||'.unl' || "' delimiter '|' "|| '12'||                          
                                      "; INSERT INTO paso_mov_giro" || ";"||'"'||' > '||RUTA_DESTINO||SCRIPT_EJECUCION2||'file_movs.txt';
                    SYSTEM vExecuteSQL; 
                    
                    LET vExecuteSQL = '';
                    LET vExecuteSQL = "dbload -d intercard -c "||RUTA_DESTINO||SCRIPT_EJECUCION2||"file_movs.txt -l "||RUTA_DESTINO||SCRIPT_EJECUCION2||"err_tarj_paso.log -n "||CONTADOR_TRANSACCIONES||" -k";
                    SYSTEM vExecuteSQL;  
		           ------------------------------------------------------------------------------------------------------------
		           UPDATE STATISTICS MEDIUM FOR TABLE "informix".paso_mov_giro;   
	               -------------------------------------------------------------------------------------------------------------
				   
	   IF  pNumeroDesfase  = '2' THEN 	   --- inicia la segunda y Ãºltima fase del proceso 
				   
	                 CREATE TABLE "informix".paso_nego (
                        ranking             integer,		
                        codgironeg          varchar(4),
	              	    descgironeg       	varchar(80),
	              		metodocaptura       varchar(2),
	              		descripcion         varchar(30),
                        transacciones     	integer,
	                    monto               decimal(19,4),
                        promedio			decimal(19,4),
                        producto            varchar(4),
	              		esnacional          varchar(1),
	              		periodo             varchar(6)
	              )EXTENT SIZE 320 NEXT SIZE 320 LOCK MODE ROW;
	              
	                  CREATE TABLE "informix".paso_estab (
                        ranking             integer,			
                        codgironeg          varchar(4),
	              	    descgironeg       	varchar(80),
	              		idreceptor          varchar(4),
                        infreceptor         varchar(40),
	              		metodocaptura       varchar(2),
	              		descripcion         varchar(30),
                        transacciones     	integer,
	                    monto               decimal(19,4),
                        promedio			decimal(19,4),
                        producto            varchar(4),
	              		esnacional          varchar(1),
	              		periodo             varchar(6)
	              )EXTENT SIZE 320 NEXT SIZE 320 LOCK MODE ROW;
	 
	        ----------------------------------------------------------------------------------------------------------------
	                delete from intercard:tempfacgiro_negocio      WHERE periodo = vaniomes;
		            delete from intercard:tempfac_establecimiento  WHERE periodo = vaniomes;
	        ----------------------------------------------------------------------------------------------------------------
	          -- Re-ingenieria giro: 		   
				    LET vExecuteSQL = '';
                    LET vExecuteSQL = ' rm -f '||RUTA_DESTINO||NOMBRE_ARCHIVO2||'*';
                    SYSTEM vExecuteSQL;
					  --------------------
                   LET vExecuteSQL	= '';
                   LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 4; UNLOAD TO '||RUTA_DESTINO||NOMBRE_ARCHIVO2||vaniomes||'.unl '||
				                     '  SELECT 0 as ranking,codgironeg,descgironeg,metodocaptura,desc_pem,sum(transacciones) as transacciones, '||
									 '  sum (monto) as monto,sum (promedio) as promedio,codproductotarjeta,esnacional,periodo  '||
									 '  FROM paso_mov_giro   '||  
									 '  WHERE  esnacional =  ''"'||'V'||'"''   AND  periodo = '''||vaniomes||'''  '||  
									 '  GROUP BY 1,2,3,4,5,9,10,11;     '||
									 '" >'||RUTA_DESTINO||SCRIPT_EJECUCION3;
				     SYSTEM vExecuteSQL;
  			       -----------------------------------------------------------------------------------------------------------------	
		            --Asigancion de permisos del archivo .sql
		            let vExecuteSQL ='';			
		            let vExecuteSQL= 'chmod 777 ' ||RUTA_DESTINO||SCRIPT_EJECUCION3;
		            system vExecuteSQL;
		            
		            let vExecuteSQL = '';
                    let vExecuteSQL = 'dbaccess intercard '||RUTA_DESTINO||SCRIPT_EJECUCION3;
                    system vExecuteSQL;	  
                    ---------------------------------------------------------------------------------------------------------------            
			        --eliminaciÃ³n de archivos
		            let vExecuteSQL = '';
                    let vExecuteSQL ='rm -f '||RUTA_DESTINO||SCRIPT_EJECUCION3;
                    system vExecuteSQL; 
				 	-------------------------------------------------------------------------------------------------------------
                    --- Genera dbload para la carga de registros a la tabla  destino
 	                LET vExecuteSQL = '';
                    LET vExecuteSQL = "echo "||'"'|| "file '"||RUTA_DESTINO||NOMBRE_ARCHIVO2||vaniomes||'.unl' || "' delimiter '|' "|| '11'||                          
                                      "; INSERT INTO tempfacgiro_negocio" || ";"||'"'||' > '||RUTA_DESTINO||SCRIPT_EJECUCION5||'file_movs.txt';
                    SYSTEM vExecuteSQL; 
                    
                    LET vExecuteSQL = '';
                    LET vExecuteSQL = "dbload -d intercard -c "||RUTA_DESTINO||SCRIPT_EJECUCION5||"file_movs.txt -l "||RUTA_DESTINO||SCRIPT_EJECUCION5||"err_tarj_paso.log -n "||CONTADOR_TRANSACCIONES||" -k";
                    SYSTEM vExecuteSQL;  	
	             ---------------------------------------------------------------------------------------------------------------- 
				   UPDATE STATISTICS MEDIUM FOR TABLE "informix".tempfacgiro_negocio;   
                  ------------------------------------------------------------------------------------------------------------
		           update tempfacgiro_negocio set promedio = (monto/transacciones)  WHERE    periodo= vaniomes;
		   ----------------------------------------------------------------------------------------------------------------
		   -- Se hace la seleciÃ³n por producto y se guarda en tablas temporales
		    FOREACH cur_F1_negocio WITH HOLD FOR  		
		       SELECT  codproductotarjeta INTO vproductotarjeta FROM intercard:productotarjeta WHERE permitetransdigitadas in ('V','F')
			   let v_ranking =0;
				    FOREACH  cur_F1_r1 WITH HOLD FOR  		
						 SELECT FIRST 10 codgironeg,descgironeg,metodocaptura,descripcion,transacciones,monto,promedio,producto,esnacional,periodo 
						 INTO vcodgironeg2,vdescgironeg2,vmetodocaptura2,vdescripcion2,vtransacciones2,vmonto2,vpromedio2,vproducto2,vesnacional2,vperiodo2
						 FROM tempfacgiro_negocio WHERE  producto = vproductotarjeta AND periodo= vaniomes AND esnacional ='V'  ORDER BY transacciones DESC  
	                     let v_ranking = v_ranking+1;	 	
						 INSERT  INTO paso_nego(ranking,codgironeg,descgironeg,metodocaptura,descripcion,transacciones,monto,promedio,producto,esnacional,periodo)					 
						 VALUES (v_ranking,vcodgironeg2,vdescgironeg2,vmetodocaptura2,vdescripcion2,vtransacciones2,vmonto2,vpromedio2,vproducto2,vesnacional2,vperiodo2);				 
					END FOREACH;
	        END FOREACH;
            ----------------------------------------------------------------------------------------------------------------
                UPDATE STATISTICS MEDIUM FOR TABLE "informix".paso_nego;   
	        ----------------------------------------------------------------------------------------------------------------
		     -- Re-ingenieria Establecimiento
			 	    LET vExecuteSQL = '';
                    LET vExecuteSQL = ' rm -f '||RUTA_DESTINO||NOMBRE_ARCHIVO3||'*';
                    SYSTEM vExecuteSQL;
				    --------------------
                    LET vExecuteSQL	= '';
                    LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 4; UNLOAD TO '||RUTA_DESTINO||NOMBRE_ARCHIVO3||vaniomes||'.unl '||
				                     '  SELECT 0 as ranking, codgironeg,descgironeg,metodocaptura,desc_pem,idreceptor, '||   
									 '  infreceptor,sum(transacciones) as transacciones,sum (monto) as monto, sum (promedio) as promedio, '||   
									 '  codproductotarjeta,esnacional,periodo  '||
									 '  FROM paso_mov_giro    '||  
									 '  WHERE  esnacional =  ''"'||'V'||'"''  AND  periodo = '''||vaniomes||'''   '||  
									 '  GROUP BY 1,2,3,4,5,6,7,11,12,13 ;     '||
									 '" >'||RUTA_DESTINO||SCRIPT_EJECUCION4;
				     SYSTEM vExecuteSQL;
  			         -----------------------------------------------------------------------------------------------------------------	
		            --Asigancion de permisos del archivo .sql
		            let vExecuteSQL ='';			
		            let vExecuteSQL= 'chmod 777 ' ||RUTA_DESTINO||SCRIPT_EJECUCION4;
		            system vExecuteSQL;
		            
		            let vExecuteSQL = '';
                    let vExecuteSQL = 'dbaccess intercard '||RUTA_DESTINO||SCRIPT_EJECUCION4;
                    system vExecuteSQL;	  
                    ---------------------------------------------------------------------------------------------------------------            
			        --eliminaciÃ³n de archivos
		            let vExecuteSQL = '';
                    let vExecuteSQL ='rm -f '||RUTA_DESTINO||SCRIPT_EJECUCION4;
                    system vExecuteSQL; 
				 	-------------------------------------------------------------------------------------------------------------
                    --- Genera dbload para la carga de registros a la tabla  destino
 	                LET vExecuteSQL = '';
                    LET vExecuteSQL = "echo "||'"'|| "file '"||RUTA_DESTINO||NOMBRE_ARCHIVO3||vaniomes||'.unl' || "' delimiter '|' "|| '13'||                          
                                      "; INSERT INTO tempfac_establecimiento" || ";"||'"'||' > '||RUTA_DESTINO||SCRIPT_EJECUCION6||'file_movs.txt';
                    SYSTEM vExecuteSQL; 
                    
                    LET vExecuteSQL = '';
                    LET vExecuteSQL = "dbload -d intercard -c "||RUTA_DESTINO||SCRIPT_EJECUCION6||"file_movs.txt -l "||RUTA_DESTINO||SCRIPT_EJECUCION6||"err_tarj_paso.log -n "||CONTADOR_TRANSACCIONES||" -k";
                    SYSTEM vExecuteSQL;  	
                 ----------------------------------------------------------------------------------------------------------------
				  UPDATE STATISTICS MEDIUM FOR TABLE "informix".tempfac_establecimiento;   
	             ----------------------------------------------------------------------------------------------------------------
				  update tempfac_establecimiento set promedio = (monto/transacciones)  WHERE    periodo= vaniomes;
				 ----------------------------------------------------------------------------------------------------------------
	             FOREACH cur_F2_estab WITH HOLD FOR  
		               SELECT  codproductotarjeta INTO vproductotarjeta2 FROM intercard:productotarjeta WHERE permitetransdigitadas in ('V','F')
		               let v_ranking2 =0;
		             FOREACH  cur_F2_r1 WITH HOLD FOR  
			            SELECT FIRST 10 codgironeg,descgironeg,metodocaptura,descripcion,idreceptor,infreceptor,transacciones,monto,promedio,producto,esnacional,periodo
			            INTO vcodgironeg2,vdescgironeg2,vmetodocaptura2,vdescripcion2,vidreceptor2,vinfreceptor2,vtransacciones2,vmonto2,vpromedio2,vproducto2,vesnacional2,vperiodo2
			            FROM tempfac_establecimiento WHERE  producto = vproductotarjeta2 AND periodo= vaniomes  AND esnacional ='V'   ORDER BY transacciones DESC  -- 
			            let v_ranking2 = v_ranking2+1;	
			            INSERT  INTO paso_estab(ranking,codgironeg,descgironeg,metodocaptura,descripcion,idreceptor,infreceptor,transacciones,monto,promedio,producto,esnacional,periodo) 
			            VALUES (v_ranking2,vcodgironeg2,vdescgironeg2,vmetodocaptura2,vdescripcion2,vidreceptor2,vinfreceptor2,vtransacciones2,vmonto2,vpromedio2,vproducto2,vesnacional2,vperiodo2); 
		             END FOREACH;
	            END FOREACH;	
	            ----------------------------------------------------------------------------------------------------------------
                UPDATE STATISTICS MEDIUM FOR TABLE "informix".paso_estab;   
	            ----------------------------------------------------------------------------------------------------------------

		   --7)Generar archivo por Giro de Negocio GirosNegocioNacional 
		   -----------------------------------------------------------------------------------------------------------------
		    --Elimina reportes anteriores
	        let vsql = '';
            let vsql ='rm -f '||RUTA_DESTINO||TIPO_PLANTILLA||'*';
            system vsql;
             ----------------------------------------------------------------------------------------------------------------- 
		    let vsql = ''; 	   
			let vsql = 'echo "Rank|Giro de Comercio|Desc. Giro Comercio|Metodo_Captura|Descripcion|Num. Transacciones|Monto Total Compras|Compra Promedio|Producto|Nacional(V)/Internacional(F)|Periodo">'||RUTA_DESTINO||TIPO_PLANTILLA||'_'||vaniomes||'.txt';
			system vsql;
			let vsql = '';
			let vsql = '';
			let vsql=  'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;  UNLOAD TO  '||RUTA_DESTINO||'rpt_GirosNegocioNacionalbase_'||vaniomes||'.txt   '||
			           ' SELECT * FROM paso_nego where esnacional =''"'||'V'||'"''    '||
					   ' order by producto,transacciones desc;">'||RUTA_DESTINO||'gironegocio.sql';    
			system vsql;
			-----------------------------------------------------------------------------------------------------------------	
		      ---Asigancion de permisos del archivo .sql
		    let vsql ='';			
		    let vsql= 'chmod 777 ' ||RUTA_DESTINO||'gironegocio.sql';
		    system vsql;
		    
		    let vsql = '';
            let vsql = 'dbaccess intercard '||RUTA_DESTINO||'gironegocio.sql';
            system vsql;	 
            ---------------------------------------------------------------------------------------------------------------
		    --Resultado del unload se complementa con el encabezado del reporte
		    let vsql ='';
            let vsql = "sed 's/|$//g' "||RUTA_DESTINO||'rpt_GirosNegocioNacionalbase_'||vaniomes||".txt >> "||RUTA_DESTINO||TIPO_PLANTILLA||'_'||vaniomes||'.txt';
            system vsql; 
            ----------------------------------------------------------------------------------------------------------------
			--eliminaciÃ³n de archivos
		 
		    let vsql = '';
            let vsql ='rm -f '||RUTA_DESTINO||'gironegocio.sql';
            system vsql;
		     
		    let vsql = '';
		    let vsql ='rm -f '||RUTA_DESTINO||'rpt_GirosNegocioNacionalbase_'||vaniomes||'.txt';
		    system vsql;
            -----------------------------------------------------------------------------------------------------------------
		   --8)Generar archivo Por Establecimiento  
	       -----------------------------------------------------------------------------------------------------------------
		   --Elimina reportes anteriores
	        let vsql = '';
            let vsql ='rm -f '||RUTA_DESTINO||TIPO_PLANTILLA2||'*';
            system vsql;
           ----------------------------------------------------------------------------------------------------------------- 
		    let vsql = '';
			let vsql = 'echo "Rank|Giro de Comercio|Desc. Giro Comercio|Num.Establecimiento|Numero de Comercio|Metodo_Captura|Descripcion|Num. Transacciones|Monto Total Compras|Compra Promedio|Producto|Nacional(V)/Internacional(F)|Periodo">'||RUTA_DESTINO||TIPO_PLANTILLA2||'_'||vaniomes||'.txt';
			system vsql;
			let vsql = '';
			let vsql=  'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;  UNLOAD TO  '||RUTA_DESTINO||'rpt_EstablecimientoNacionalbase_'||vaniomes||'.txt   '||
			           ' SELECT * FROM paso_estab where esnacional =''"'||'V'||'"''    '||
					   ' order by producto,transacciones desc;">'||RUTA_DESTINO||'establecimiento.sql';    
			system vsql;
			-----------------------------------------------------------------------------------------------------------------	
		    ---Asigancion de permisos del archivo .sql
		    let vsql ='';			
		    let vsql= 'chmod 777 ' ||RUTA_DESTINO||'establecimiento.sql';
		    system vsql;
		    
		    let vsql = '';
            let vsql = 'dbaccess intercard '||RUTA_DESTINO||'establecimiento.sql';
            system vsql;	 
            --------------------------------------------------------------------------------------------------------------- 
		    --Resultado del unload se complementa con el encabezado del reporte
		    let vsql ='';
            let vsql = "sed 's/|$//g' "||RUTA_DESTINO||'rpt_EstablecimientoNacionalbase_'||vaniomes||".txt >> "||RUTA_DESTINO||TIPO_PLANTILLA2||'_'||vaniomes||'.txt';
            system vsql; 
            ----------------------------------------------------------------------------------------------------------------
			--eliminaciÃ³n de archivos
		    let vsql = '';
            let vsql ='rm -f '||RUTA_DESTINO||'establecimiento.sql';
            system vsql;
		     
		    let vsql = '';
		    let vsql ='rm -f '||RUTA_DESTINO||'rpt_EstablecimientoNacionalbase_'||vaniomes||'.txt';
		    system vsql;    
            -----------------------------------------------------------------------------------------------------------------
			BEGIN;
             DROP TABLE IF EXISTS intercard:paso_nego;
		    COMMIT;
	
		    BEGIN;
             DROP TABLE IF EXISTS intercard:paso_estab;
		    COMMIT;
		     ---------------------------------------------------------------------------------------------------------------            
		   --eliminaciÃ³n de archivos basura
		            let vExecuteSQL = '';
                    let vExecuteSQL ='rm -f '||RUTA_DESTINO||NOMBRE_ARCHIVO||'*';
                    system vExecuteSQL; 
					
				    let vExecuteSQL = '';
                    let vExecuteSQL ='rm -f '||RUTA_DESTINO||NOMBRE_ARCHIVO2||'*';
                    system vExecuteSQL; 
					
				    let vExecuteSQL = '';
                    let vExecuteSQL ='rm -f '||RUTA_DESTINO||NOMBRE_ARCHIVO3||'*';
                    system vExecuteSQL; 
 
 				    let vExecuteSQL = '';
                    let vExecuteSQL ='rm -f '||RUTA_DESTINO||SCRIPT_EJECUCION||'*';
                    system vExecuteSQL; 
					
				    let vExecuteSQL = '';
                    let vExecuteSQL ='rm -f '||RUTA_DESTINO||SCRIPT_EJECUCION2||'*';
                    system vExecuteSQL; 
	 
	 	 	 	    let vExecuteSQL = '';
                    let vExecuteSQL ='rm -f '||RUTA_DESTINO||SCRIPT_EJECUCION5||'*';
                    system vExecuteSQL; 
	 
 	 	 	 	    let vExecuteSQL = '';
                    let vExecuteSQL ='rm -f '||RUTA_DESTINO||SCRIPT_EJECUCION6||'*';
                    system vExecuteSQL; 
  
		-------------------------------------------------------------------------------------------------------------
	    -------------------------------------------------------------------
				
		    LET CODIGO_RETORNO = '00000';
		    LET  MENSAJE_RETORNO  = 'PROCESO EXITOSO';
		    RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO;
			
		 ELSE 	
		
		 --eliminaciÃ³n de archivos basura
		            let vExecuteSQL = '';
                    let vExecuteSQL ='rm -f '||RUTA_DESTINO||NOMBRE_ARCHIVO||'*';
                    system vExecuteSQL; 
					
				    let vExecuteSQL = '';
                    let vExecuteSQL ='rm -f '||RUTA_DESTINO||SCRIPT_EJECUCION2||'*';
                    system vExecuteSQL; 
					
				    let vExecuteSQL = '';
                    let vExecuteSQL ='rm -f '||RUTA_DESTINO||NOMBRE_ARCHIVO3||'*';
                    system vExecuteSQL; 
 
		
		    LET CODIGO_RETORNO = '00000';
		    LET  MENSAJE_RETORNO  = 'PROCESO EXITOSO';
		    RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO;
			
		END IF;	
 
END;
END PROCEDURE
---CoordinaciÃ³n de Tarjetas e Interfaces Transaccionales | Gerencia Mantenimiento I
---Autor: Marcos Gerardo Ayala Ponce
---Fecha de creacion: 15 de diciembre del 2020
---Base de datos: intercard
---Este proceso corresponde al job 875
--  EXECUTE PROCEDURE "informix".sp_reportenegocio('Q','1');
--  EXECUTE PROCEDURE "informix".sp_reportenegocio('Q','2');	
;

CREATE PROCEDURE "informix".sp_initeverydays_ctrlm_pbajj ()
RETURNING VARCHAR(6) as Cod_ret,VARCHAR(80) as Men_ret;

	--  Variables de Errores y datos de SP
	define  sql_err          integer;
	define  isam_err         integer;
	define  error_info       varchar(80);
	define  p_cod_ret        varchar(6);
	define  p_mensaje        varchar(80);
	define  vdfechafin       date;	
	
	
   	--  Variables para control de contadores
	define  vsflagentransaccion 	char(1);
	define 	vicontadorregistros 	integer;
	define  vicontadorregistros2 	integer;
    
	--  Variables para datos de primary key
	define  vconsecutivo		integer;
	define 	varchivoorigen  	CHAR(3);
    --  define 	vfechacarga      	DATETIME YEAR to FRACTION(3);
    define 	vfechacarga      	DATETIME YEAR to FRACTION(5);
    define 	vnombrearchivo   	CHAR(23);
	define  vperiododepuracion  integer;
	define  vmaxnumregistros integer;
	define  vsecuencia  varchar (7);
	define  vnumtarjeta  varchar (16);
	define  vfechalocaltransaccion  varchar (4);
	define  vhoralocaltransaccion  varchar (6);
		
 -- SET DEBUG FILE TO "/informix/HomeInformix/rrm/init.out";
 -- TRACE ON;


BEGIN
	ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
	LET P_COD_RET    = SQL_ERR;
	LET P_MENSAJE  = ERROR_INFO;
	
    RETURN 	P_COD_RET,P_MENSAJE;
		
   END EXCEPTION;

	let     vconsecutivo = 0;
	let 	varchivoorigen = '';
    ---let 	vfechacarga = current;
    let 	vfechacarga = sysdate;
    let 	vnombrearchivo = '';
	let     vperiododepuracion =0;
	let     vsecuencia='';
	let     vnumtarjeta='';
	let     vfechalocaltransaccion='';
	let     vhoralocaltransaccion='';
	let    vmaxnumregistros=0;
	let 	vsflagentransaccion = 'F';
	let		vicontadorregistros = 0;
	let     vicontadorregistros2 = 0;
	let p_cod_ret = '00000';
	let p_mensaje = 'Proceso Exitoso';
	
	
	--	set isolation to dirty read;

SET ISOLATION TO dirty READ;
SET LOCK MODE TO WAIT 3;

	select 	periododepuracion, maxnumregistros
					into vperiododepuracion , vmaxnumregistros
			from intercard:"informix".parametros;
			
	let  vfechacarga = vfechacarga - vperiododepuracion UNITS DAY;
					
	--	set isolation to dirty read;
		foreach cusor1 with hold
				for    
				select 	{+INDEX (movimiento idx_fechahorainauth)} secuencia, numtarjeta, fechalocaltransaccion, horalocaltransaccion
					into vsecuencia, vnumtarjeta, vfechalocaltransaccion, vhoralocaltransaccion
			from intercard:"informix".movimiento
		    where fechahorainauth < vfechacarga 
			
			if(vsflagentransaccion = 'F') then
				begin work;
                let vsflagentransaccion = 'V';
            end if;
			
		--  Inserta datos en la tabla historica
		insert into "informix".MovimientoHistorico 
		select * 
--		insert into intercard:"informix".MovimientoHistorico (secuencia, codigoiso, codgironeg, codigocentral, numtarjeta, enlinea, enviado, prodind, formato, codtran, tipoctaorigen, tipoctadestino, fechaexptarj, fechamov, horamov, codreversa, moneda, referencia, monto, infreceptor, idreceptor, idterminal, montorealrevfzda, secuenciaorig, pinvalido, cvvvalido, preautorizacion, movreversado, fechaapliccentral, esnacional, pais, metodocaptura, motivo, draftcaptura, prosaauth, authhost, hostauth, authprosa, cobrocomision, montocomision, movconciliado, fechalocaltransaccion, horalocaltransaccion, fechacaptura, trancajeropropio, fechahorainauth, comisionenlinea, codigoretcomision, seccomision, tnrcobrocomisionctaindividual, tnrmontocomisionctaindividual, permitecomisionpendiente, generocomisionpendiente, movduranteactsaldos, montosurcharge, secsurcharge, montocashback, secuenciacashback, secuenciacomcashback, montocomcashback, cvv2valido, transaccionorigen, tipotransaccionposdigitada, tokens63in, trancajeroconvenio, codigoisorev, fechahoraoutauth, fechahorabcentral, fechahoraacentral, fechahorainauthj, idretailer, tipotransaccionpos, secuenciaextendida, surcharge, arqcrecibido, arqccalculado, arqcrc)
--		select secuencia, codigoiso, codgironeg, codigocentral, numtarjeta, enlinea, enviado, prodind, formato, codtran, tipoctaorigen, tipoctadestino, fechaexptarj, fechamov, horamov, codreversa, moneda, referencia, monto, infreceptor, idreceptor, idterminal, montorealrevfzda, secuenciaorig, pinvalido, cvvvalido, preautorizacion, movreversado, fechaapliccentral, esnacional, pais, metodocaptura, motivo, draftcaptura, prosaauth, authhost, hostauth, authprosa, cobrocomision, montocomision, movconciliado, fechalocaltransaccion, horalocaltransaccion, fechacaptura, trancajeropropio, fechahorainauth, comisionenlinea, codigoretcomision, seccomision, tnrcobrocomisionctaindividual, tnrmontocomisionctaindividual, permitecomisionpendiente, generocomisionpendiente, movduranteactsaldos, montosurcharge, secsurcharge, montocashback, secuenciacashback, secuenciacomcashback, montocomcashback, cvv2valido, transaccionorigen, tipotransaccionposdigitada, tokens63in, trancajeroconvenio, codigoisorev, fechahoraoutauth, fechahorabcentral, fechahoraacentral, fechahorainauthj, idretailer, tipotransaccionpos, secuenciaextendida, surcharge, arqcrecibido, arqccalculado, arqcrc
		from "informix".movimiento	  
		where fechahorainauth < vfechacarga AND
		secuencia = vsecuencia AND
		numtarjeta = vnumtarjeta AND
		fechalocaltransaccion = vfechalocaltransaccion AND 
		horalocaltransaccion = vhoralocaltransaccion;
			
			--  Borra registro de la Tabla de Movimientos	
			delete from "informix".movimiento 
		where fechahorainauth < vfechacarga AND
		secuencia = vsecuencia AND
		numtarjeta = vnumtarjeta AND
		fechalocaltransaccion = vfechalocaltransaccion AND 
		horalocaltransaccion = vhoralocaltransaccion;
				
			let vicontadorregistros = vicontadorregistros + 1;
--			let vicontadorregistros2 = vicontadorregistros2 + 1;

--			if (vicontadorregistros2 = 100000) then 
--				update statistics medium for table intercard:"informix".movimiento;           
--			let vicontadorregistros2 = 0;
--			end if;

			if (vicontadorregistros = vmaxnumregistros) then
				commit work;
				let vsflagentransaccion = 'F';
				let vicontadorregistros = 0;
				continue foreach;
			end if;		
		end foreach;
		
		if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then
				commit work;
				update statistics medium for table "informix".movimiento;      
                update statistics medium for table "informix".productotarjeta;   
                update statistics medium for table "informix".alertservice;   
                update statistics medium for table "informix".tarjeta_indicadores;   
				let vsflagentransaccion = 'F';
		end if;
		
			let p_cod_ret = '00000';
	        let p_mensaje = 'Proceso initeverydays Exitoso';
		
		EXECUTE PROCEDURE "informix".sp_movimientobpihistorico() INTO P_COD_RET,P_MENSAJE;
				return 	P_COD_RET,P_MENSAJE;	
	--END IF;
	
	--END IF;

END;

END PROCEDURE;