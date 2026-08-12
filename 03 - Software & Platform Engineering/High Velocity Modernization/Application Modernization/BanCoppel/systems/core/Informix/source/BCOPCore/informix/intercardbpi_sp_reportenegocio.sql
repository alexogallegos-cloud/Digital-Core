CREATE PROCEDURE "informix".sp_reportenegocio()
RETURNING varchar(6), varchar(80);
----------Variables-------------------------------
DEFINE  error_info              varchar(80);
DEFINE  isam_err                integer;
DEFINE  vsqlerr                 integer;
DEFINE  vcodret                 varchar(6);
DEFINE  p_mensaje               varchar(80);
DEFINE  vletra                  varchar(1);
DEFINE  vaniomes                char(6);
DEFINE  vfecha_hoy              date;
DEFINE  vsql                    char(1150);
DEFINE  dias                    integer;
DEFINE  vStatushistcred         varchar(1); 
DEFINE  vproductotarjeta        varchar(3);
DEFINE  vproductotarjeta2       varchar(3);
DEFINE  vcodgironeg             varchar(4);
DEFINE  vdescgironeg            varchar(80);
DEFINE  vdescripcion            varchar(30);
DEFINE  vtransacciones          integer;
DEFINE  vmonto                  decimal(19,4);
DEFINE  vpromedio               decimal(19,4);
DEFINE  vproducto               varchar(3);
DEFINE  vperiodo                char(6);
DEFINE  vidreceptor             varchar(4);
DEFINE  vinfreceptor            varchar(40);
DEFINE  vmetodocaptura          varchar(2);
DEFINE  vesnacional             varchar(1);   
DEFINE  i                       integer;
DEFINE  v_ranking               integer;
DEFINE  v_ranking2              integer;
DEFINE  v_ranking3              integer;
DEFINE  v_ranking4              integer;
  
---------------------------------------------------
DEFINE ultimo_dia_mes DATE;
DEFINE primer_dia_mes DATE;
DEFINE ultimo_dia_mes_hora DATETIME YEAR TO FRACTION(5);
DEFINE primer_dia_mes_hora DATETIME YEAR TO FRACTION(5);
DEFINE FechaAux DATETIME YEAR TO FRACTION(5);

LET  vStatushistcred = "";    
LET  vproductotarjeta = ""; 
LET  vproductotarjeta2 = "";  
LET  vcodgironeg = "";             
LET  vdescgironeg  = "";   
LET  vdescripcion = "";      
LET  vtransacciones = "";         
LET  vmonto = "";                 
LET  vpromedio = "";               
LET  vproducto = "";               
LET  vperiodo = ""; 
LET  vidreceptor = ""; 
LET  vinfreceptor = ""; 
LET  v_ranking = 0; 
LET  v_ranking2 = 0;
LET  v_ranking3 = 0; 
LET  v_ranking4 = 0;  
LET  vmetodocaptura = "";
LET  vesnacional = "";                 
         
--SET DEBUG FILE TO "/informix/c94796696/reportenegocio.out";
--TRACE ON;

  begin
 ------------- control de errores------
    ON EXCEPTION SET vsqlerr,isam_err, error_info
	   SET DEBUG FILE TO "/informix/c94796696/reportenegocio2.out";
       TRACE ON;
            --IF vsqlerr <> 0 AND vsqlerr <> -958  then
                let vcodret = vsqlerr;
                let p_mensaje = error_info;
                  RETURN vcodret, p_mensaje;
            --END IF;
    END EXCEPTION;
	
	
	/*ON EXCEPTION SET vsqlerr,isam_err, error_info
            IF vsqlerr = -958  then	
                  if error_info ='informix.pasoprincipal' then
				     drop table pasoprincipal;
				  end if			
	              if error_info ='informix.paso2' then
				     drop table paso2;
				  end if			   
                  if error_info ='informix.paso3' then
				     drop table paso3;					  
				  end if
				  if error_info ='informix.paso_nego' then
				     drop table paso_nego;					  
				  end if
				   if error_info ='informix.paso_estab' then
				     drop table paso_estab;					  
				  end if
				  				   
		    END IF;    
    END EXCEPTION WITH RESUME; */
	
		/*SET ISOLATION TO DIRTY READ ;
        IF EXISTS ( SELECT dbsname, tabname FROM  sysmaster:SysTabNames  WHERE tabname = 'pasoprincipal' AND dbsname= 'intercard') THEN
            DROP TABLE intercard:pasoprincipal;
        END IF;*/
		
		SET ISOLATION TO DIRTY READ ;
        IF EXISTS ( SELECT dbsname, tabname FROM  sysmaster:SysTabNames  WHERE tabname = 'paso2' AND dbsname= 'intercard') THEN
            DROP TABLE intercard:paso2;
        END IF;

		
		SET ISOLATION TO DIRTY READ ;
        IF EXISTS ( SELECT dbsname, tabname FROM  sysmaster:SysTabNames  WHERE tabname = 'paso3' AND dbsname= 'intercard') THEN
            DROP TABLE intercard:paso3;
        END IF;
		
		SET ISOLATION TO DIRTY READ ;
        IF EXISTS ( SELECT dbsname, tabname FROM  sysmaster:SysTabNames  WHERE tabname = 'paso_nego' AND dbsname= 'intercard') THEN
            DROP TABLE intercard:paso_nego;
        END IF;

			SET ISOLATION TO DIRTY READ ;
        IF EXISTS ( SELECT dbsname, tabname FROM  sysmaster:SysTabNames  WHERE tabname = 'paso_estab' AND dbsname= 'intercard') THEN
            DROP TABLE intercard:paso_estab;
        END IF;

-----------***********cuerpo**************-------------------  
SET isolation to dirty read;
SELECT fecha_hoy INTO vfecha_hoy FROM bdinteg:si_fechas;
     LET vcodret = '';
-----operaciones de fechas
     LET vcodret = '';
     LET ultimo_dia_mes = extend(extend(vfecha_hoy - 0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 0 units DAY;
     LET ultimo_dia_mes_hora = extend(extend(vfecha_hoy - 0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 0 units DAY;
     LET ultimo_dia_mes_hora = SUBSTRING(ultimo_dia_mes_hora FROM 1 FOR 10) || ' 23:59:59';
     --OBTIENE EL PRIMER DIA DEL MES DE CORTE
     LET primer_dia_mes = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);
     LET primer_dia_mes_hora = extend(extend(vfecha_hoy - 1 units MONTH ,YEAR TO MONTH)||"-01",YEAR TO DAY);
     LET primer_dia_mes_hora= SUBSTRING(primer_dia_mes_hora FROM 1 FOR 10) || ' 00:00:00';
--OBTIENE LA FECHA MINIMA DE INTERCARD:MOVIMIENTO    
    --SET isolation to dirty read;
	--SELECT fecha_hoy INTO vfecha_hoy FROM bdinteg:si_fechas;
	 SELECT {+INDEX(intercard:movimiento idx_fechahorainauth)} MIN(FechaHoraInAuth)
      INTO FechaAux FROM Intercard:Movimiento;
--OBTIENE EL AÑO Y MES DE LA FECHA	  
     let vaniomes =  year(ultimo_dia_mes) || LPAD (MONTH(ultimo_dia_mes),2,"0");
	 let dias = day(ultimo_dia_mes);
     
 -----validamos si el mes de la fecha que nos dan ya esta completo y si no se ha ejecutado con anterioridad.
 IF (not exists (SELECT * FROM intercard:tempfacgiro_negocio WHERE periodo = vaniomes) AND
     ultimo_dia_mes < vfecha_hoy) THEN
	 
	   SET isolation to dirty read;
	    SELECT status_proc INTO vStatushistcred  FROM bdicred:sd_contproc  WHERE fecha=today-1 AND proceso = 'CierreCred' AND cod_ret='000';
		  IF( vStatushistcred = 'F')THEN
	 
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
 
--Cuerpo del SP--
--1) Extraemos la información de las  tablas movimiento y movimientohistorico hacemos un UNION entre ellas para empatar los movimientos y las guardamos en la tabla pasoprincipal

		/*SET isolation to dirty read;
		SELECT {+INDEX(intercard:movimientohistorico idx_movimiento3)} {+INDEX(intercard:tarjeta 144_89 )}
		movh.numtarjeta,movh.codgironeg,movh.codigoiso,movh.monto,movh.infreceptor,movh.idreceptor,tar.codproductotarjeta 
		FROM intercard:movimientohistorico movh, intercard:tarjeta tar
		WHERE fechahorainauth BETWEEN  primer_dia_mes_hora AND  ultimo_dia_mes_hora
		AND movh.numtarjeta = tar.numtarjeta
		AND prodind = '02'
		AND codigoiso = '00'
		
		UNION ALL

		SELECT {+INDEX(intercard:movimiento idx_fechahorainauth)}  {+INDEX(intercard:tarjeta 144_89 )}
		mov.numtarjeta,mov.codgironeg,mov.codigoiso,mov.monto,mov.infreceptor,mov.idreceptor,tar.codproductotarjeta
		FROM intercard:movimiento mov,intercard:tarjeta tar
		WHERE (fechahorainauth BETWEEN primer_dia_mes_hora AND  ultimo_dia_mes_hora)
		AND mov.numtarjeta = tar.numtarjeta
		AND prodind = '02'
		AND codigoiso = '00'
		INTO temp pasoprincipal  WITH NO LOG; */

		----2) Se ejecuta la segunda consulta, para extraer la suma de transacciones, monto y promedio y se guarda en una tabla de paso1
		/*SET isolation to dirty read;
		SELECT DISTINCT p.codgironeg as codgironeg,gn.descgironeg as descgironeg,COUNT(p.codigoiso) as transacciones ,sum(nvl(p.monto,0)) as monto,
		(sum(nvl(p.monto,0))/COUNT(p.codigoiso)) as promedio,p.codproductotarjeta as producto,vaniomes as periodo
		FROM intercard:pasoprincipal p,intercard:gironegocio gn
		WHERE  gn.codgironeg = p.codgironeg 
		GROUP BY 7,1,6,2
		ORDER BY transacciones DESC
		INTO temp paso2  WITH NO LOG; */
		
		
	    SET isolation to dirty read;
		SELECT DISTINCT mov.codgironeg AS codgironeg,gn.descgironeg AS descgironeg,mov.metodocaptura,
		CASE 
				 WHEN metodocaptura = '05' THEN "CHIP"
				 WHEN metodocaptura = '90' THEN "Deslizada" 
				 WHEN metodocaptura = '01'  AND   tipotransaccionposdigitada = 'AV'    THEN "Telemarketing" 
				 WHEN metodocaptura = '01'  AND   tipotransaccionposdigitada = 'CE'    THEN "Comercio_Elect"
				 WHEN metodocaptura = '01'  AND   tipotransaccionposdigitada = 'CA'    THEN "Cargo_Autómatico" 
				 WHEN metodocaptura = '01'  AND   tipotransaccionposdigitada = 'HO'    THEN "Hotel"
--	2016.08.16 -I Se agrega <tipotransaccionposdigitada> tipo TAG:
				 WHEN metodocaptura = '01'  AND   tipotransaccionposdigitada = 'TG'    THEN "TAG"
--	2016.08.16 -F.
				 WHEN metodocaptura = '01'  AND   tipotransaccionposdigitada = 'ND'    THEN "No_Determinada" 
				 WHEN metodocaptura = '01'  AND   tipotransaccionposdigitada = '  '    THEN "No_clasificada"
				 WHEN metodocaptura = '81'  THEN "Ecomerce MasterCard"
				 WHEN metodocaptura = '80'  THEN "FallBack"
				 WHEN metodocaptura = '92'  THEN "Contactless"
				 WHEN metodocaptura IN ('00','02') THEN "Metodos Captura No Determinados"
	    END AS descripcion,COUNT(mov.codigoiso) AS transacciones ,sum(nvl(mov.monto,0)) AS monto,(sum(nvl(mov.monto,0))/COUNT(mov.codigoiso)) AS promedio,tar.codproductotarjeta AS producto,mov.esnacional AS esnacional, vaniomes AS periodo
		FROM intercard:movimiento mov, intercard:tarjeta tar,intercard:gironegocio gn
		WHERE mov.fechahorainauth BETWEEN  primer_dia_mes_hora AND  ultimo_dia_mes_hora
		AND mov.numtarjeta = tar.numtarjeta
        AND gn.codgironeg = mov.codgironeg
        AND SUBSTR (tar.numtarjeta,0,6) IN  (SELECT bin FROM intercard:bines)
		AND mov.prodind = '02'
		AND mov.codigoiso = '00'
        AND mov.codigoiso IS NOT NULL AND mov.codigoiso != ('null') AND mov.codigoiso <> ''
		AND formato in ('0200','0220','0221','0420')
        AND mov.movreversado = 'F'
        AND mov.metodocaptura IS NOT NULL AND mov.metodocaptura != ('null')
		GROUP BY 1,2,3,4,8,9,10
		
		UNION ALL
		
		--SET isolation to dirty read;
		SELECT DISTINCT movh.codgironeg AS codgironeg,gn.descgironeg AS descgironeg,movh.metodocaptura,
		CASE 
				 WHEN metodocaptura = '05' THEN "CHIP"
				 WHEN metodocaptura = '90' THEN "Deslizada" 
				 WHEN metodocaptura = '01'  AND   tipotransaccionposdigitada = 'AV'    THEN "Telemarketing" 
				 WHEN metodocaptura = '01'  AND   tipotransaccionposdigitada = 'CE'    THEN "Comercio_Elect"
				 WHEN metodocaptura = '01'  AND   tipotransaccionposdigitada = 'CA'    THEN "Cargo_Autómatico" 
				 WHEN metodocaptura = '01'  AND   tipotransaccionposdigitada = 'HO'    THEN "Hotel"
--	2016.08.16 -I Se agrega <tipotransaccionposdigitada> tipo TAG:
				 WHEN metodocaptura = '01'  AND   tipotransaccionposdigitada = 'TG'    THEN "TAG"
--	2016.08.16 -F.				 
				 WHEN metodocaptura = '01'  AND   tipotransaccionposdigitada = 'ND'    THEN "No_Determinada" 
				 WHEN metodocaptura = '01'  AND   tipotransaccionposdigitada = '  '    THEN "No_clasificada"
				 WHEN metodocaptura = '81'  THEN "Ecomerce MasterCard"
				 WHEN metodocaptura = '80'  THEN "FallBack"
				 WHEN metodocaptura = '92'  THEN "Contactless"
				 WHEN metodocaptura IN ('00','02') THEN "Metodos Captura No Determinados"
		ELSE "NULL"
	    END AS descripcion,COUNT(movh.codigoiso) AS transacciones ,sum(nvl(movh.monto,0)) AS monto,(sum(nvl(movh.monto,0))/COUNT(movh.codigoiso)) AS promedio,tar.codproductotarjeta AS producto,movh.esnacional AS esnacional, vaniomes AS periodo
		FROM intercard:movimientohistorico movh, intercard:tarjeta tar,intercard:gironegocio gn
		WHERE movh.fechahorainauth BETWEEN  primer_dia_mes_hora AND  ultimo_dia_mes_hora
		AND movh.numtarjeta = tar.numtarjeta
        AND gn.codgironeg = movh.codgironeg
        AND SUBSTR (tar.numtarjeta,0,6) IN  (SELECT bin FROM intercard:bines)
		AND movh.prodind = '02'
		AND movh.codigoiso = '00'
        AND movh.codigoiso IS NOT NULL AND movh.codigoiso != ('null') AND movh.codigoiso <> ''
		AND formato in ('0200','0220','0221','0420')
        AND movh.movreversado = 'F'
        AND movh.metodocaptura IS NOT NULL AND movh.metodocaptura != ('null')

		GROUP BY 1,2,3,4,8,9,10
        ORDER BY transacciones DESC
		INTO temp paso2  WITH NO LOG;
        CREATE INDEX idxtmp_paso2 ON paso2(codgironeg) USING BTREE;
        UPDATE STATISTICS HIGH FOR TABLE paso2;
		
		---2) Se inserta en la tabla de fisica tempfacgiro_negocio
		
--ranking,codgironeg,descgironeg,metodocaptura,descripcion,transacciones,monto,promedio,producto,esnacional, periodo   
		INSERT INTO tempfacgiro_negocio(codgironeg,descgironeg,metodocaptura,descripcion,transacciones,monto,promedio,producto,esnacional,periodo)
		SELECT codgironeg,descgironeg,metodocaptura,descripcion,sum(transacciones) as transacciones,sum (monto) as monto,sum (promedio) as promedio,producto,esnacional,periodo 
		FROM paso2 GROUP BY 1,2,3,4,8,9,10;    
		--3) Se hace la seleción por producto y se guarda en tablas temporales
		FOREACH 		
		       SELECT  codproductotarjeta INTO vproductotarjeta FROM intercard:productotarjeta
			   let v_ranking =0;
				    FOREACH 
						 SELECT FIRST 10 codgironeg,descgironeg,metodocaptura,descripcion,transacciones,monto,promedio,producto,esnacional,periodo 
						 INTO vcodgironeg,vdescgironeg,vmetodocaptura,vdescripcion,vtransacciones,vmonto,vpromedio,vproducto,vesnacional,vperiodo
						 FROM tempfacgiro_negocio WHERE  producto = vproductotarjeta AND periodo= vaniomes AND esnacional ='V' ORDER BY transacciones DESC
	                     let v_ranking = v_ranking+1;	 	
						 INSERT  INTO paso_nego(ranking,codgironeg,descgironeg,metodocaptura,descripcion,transacciones,monto,promedio,producto,esnacional,periodo)					 
						 VALUES (v_ranking,vcodgironeg,vdescgironeg,vmetodocaptura,vdescripcion,vtransacciones,vmonto,vpromedio,vproducto,vesnacional,vperiodo);				 
					END FOREACH;
	    END FOREACH;
		
		--3) Se hace la seleción por producto y se guarda en tablas temporales
		FOREACH 		
		       SELECT  codproductotarjeta INTO vproductotarjeta FROM intercard:productotarjeta
			   let v_ranking2 =0;
				    FOREACH 
						 SELECT FIRST 10 codgironeg,descgironeg,metodocaptura,descripcion,transacciones,monto,promedio,producto,esnacional,periodo 
						 INTO vcodgironeg,vdescgironeg,vmetodocaptura,vdescripcion,vtransacciones,vmonto,vpromedio,vproducto,vesnacional,vperiodo
						 FROM tempfacgiro_negocio WHERE  producto = vproductotarjeta AND periodo= vaniomes AND esnacional ='F' ORDER BY transacciones DESC
	                     let v_ranking2 = v_ranking2+1;	 	
						 INSERT  INTO paso_nego(ranking,codgironeg,descgironeg,metodocaptura,descripcion,transacciones,monto,promedio,producto,esnacional,periodo)					 
						 VALUES (v_ranking2,vcodgironeg,vdescgironeg,vmetodocaptura,vdescripcion,vtransacciones,vmonto,vpromedio,vproducto,vesnacional,vperiodo);				 
					END FOREACH;
	    END FOREACH;
	        	
		
--------4) EJECUCIÓN DE SEGUNDA CONSULTA PARA EL REPORTE 2 POR ESTABLECIMIENTO.

		/*SET isolation to dirty read;
		SELECT DISTINCT p.codgironeg AS codgironeg,gn.descgironeg AS descgironeg,p.idreceptor,p.infreceptor,COUNT(p.codigoiso) AS transacciones ,sum(nvl(p.monto,0)) AS monto,
		(sum(nvl(p.monto,0))/COUNT(p.codigoiso)) AS promedio,p.codproductotarjeta AS producto,vaniomes AS periodo
		FROM intercard:pasoprincipal p,intercard:gironegocio gn
		WHERE  gn.codgironeg = p.codgironeg
		GROUP BY 9,3,8,4,2,1
		ORDER BY transacciones DESC
		INTO temp paso3  WITH NO LOG;*/
		
				
	    SET isolation to dirty read;
		SELECT DISTINCT (mov.codgironeg) AS codgironeg,gn.descgironeg AS descgironeg,mov.metodocaptura,
		CASE 
				 WHEN metodocaptura = '05' THEN "CHIP"
				 WHEN metodocaptura = '90' THEN "Deslizada" 
				 WHEN metodocaptura = '01'  AND   tipotransaccionposdigitada = 'AV'    THEN "Telemarketing" 
				 WHEN metodocaptura = '01'  AND   tipotransaccionposdigitada = 'CE'    THEN "Comercio_Elect"
				 WHEN metodocaptura = '01'  AND   tipotransaccionposdigitada = 'CA'    THEN "Cargo_Autómatico" 
				 WHEN metodocaptura = '01'  AND   tipotransaccionposdigitada = 'HO'    THEN "Hotel"
--	2016.08.16 -I Se agrega <tipotransaccionposdigitada> tipo TAG:
				 WHEN metodocaptura = '01'  AND   tipotransaccionposdigitada = 'TG'    THEN "TAG"
--	2016.08.16 -F.
				 WHEN metodocaptura = '01'  AND   tipotransaccionposdigitada = 'ND'    THEN "No_Determinada" 
				 WHEN metodocaptura = '01'  AND   tipotransaccionposdigitada = '  '    THEN "No_clasificada"
				 WHEN metodocaptura = '81'  THEN "Ecomerce MasterCard"
				 WHEN metodocaptura = '80'  THEN "FallBack"
				 WHEN metodocaptura = '92'  THEN "Contactless"
				 WHEN metodocaptura IN ('00','02') THEN "Metodos Captura No Determinados"
	    END AS descripcion,mov.idreceptor AS idreceptor,mov.infreceptor AS infreceptor,COUNT(mov.codigoiso) AS transacciones ,sum(nvl(mov.monto,0)) AS monto,(sum(nvl(mov.monto,0))/COUNT(mov.codigoiso)) AS promedio,tar.codproductotarjeta AS producto,mov.esnacional AS esnacional, vaniomes AS periodo
		FROM intercard:movimiento mov, intercard:tarjeta tar,intercard:gironegocio gn
		WHERE mov.fechahorainauth BETWEEN  primer_dia_mes_hora AND  ultimo_dia_mes_hora
		AND mov.numtarjeta = tar.numtarjeta
        AND gn.codgironeg = mov.codgironeg
        AND SUBSTR (tar.numtarjeta,0,6) IN  (SELECT bin FROM intercard:bines)
		AND mov.prodind = '02'
		AND mov.codigoiso = '00'
        AND mov.codigoiso IS NOT NULL AND mov.codigoiso != ('null') AND mov.codigoiso <> ''
		AND formato in ('0200','0220','0221','0420')
        AND mov.movreversado = 'F'
        AND mov.metodocaptura IS NOT NULL AND mov.metodocaptura != ('null')
		GROUP BY 1,2,3,4,5,6,10,11,12
		
		UNION ALL
		
		--SET isolation to dirty read;
		SELECT DISTINCT (movh.codgironeg) AS codgironeg,gn.descgironeg AS descgironeg,movh.metodocaptura,
		CASE 
				 WHEN metodocaptura = '05' THEN "CHIP"
				 WHEN metodocaptura = '90' THEN "Deslizada" 
				 WHEN metodocaptura = '01'  AND   tipotransaccionposdigitada = 'AV'    THEN "Telemarketing" 
				 WHEN metodocaptura = '01'  AND   tipotransaccionposdigitada = 'CE'    THEN "Comercio_Elect"
				 WHEN metodocaptura = '01'  AND   tipotransaccionposdigitada = 'CA'    THEN "Cargo_Autómatico" 
				 WHEN metodocaptura = '01'  AND   tipotransaccionposdigitada = 'HO'    THEN "Hotel"
--	2016.08.16 -I Se agrega <tipotransaccionposdigitada> tipo TAG:
				 WHEN metodocaptura = '01'  AND   tipotransaccionposdigitada = 'TG'    THEN "TAG"
--	2016.08.16 -F.
				 WHEN metodocaptura = '01'  AND   tipotransaccionposdigitada = 'ND'    THEN "No_Determinada" 
				 WHEN metodocaptura = '01'  AND   tipotransaccionposdigitada = '  '    THEN "No_clasificada"
				 WHEN metodocaptura = '81'  THEN "Ecomerce MasterCard"
				 WHEN metodocaptura = '80'  THEN "FallBack"
				 WHEN metodocaptura = '92'  THEN "Contactless"
				 WHEN metodocaptura IN ('00','02') THEN "Metodos Captura No Determinados"
	    END AS descripcion,movh.idreceptor AS idreceptor,movh.infreceptor AS infreceptor,COUNT(movh.codigoiso) AS transacciones ,sum(nvl(movh.monto,0)) AS monto,(sum(nvl(movh.monto,0))/COUNT(movh.codigoiso)) AS promedio,tar.codproductotarjeta AS producto,movh.esnacional AS esnacional, vaniomes AS periodo
		FROM intercard:movimientohistorico movh, intercard:tarjeta tar,intercard:gironegocio gn
		WHERE movh.fechahorainauth BETWEEN  primer_dia_mes_hora AND  ultimo_dia_mes_hora
		AND movh.numtarjeta = tar.numtarjeta
        AND gn.codgironeg = movh.codgironeg
        AND SUBSTR (tar.numtarjeta,0,6) IN  (SELECT bin FROM intercard:bines)
		AND movh.prodind = '02'
		AND movh.codigoiso = '00'
        AND movh.codigoiso IS NOT NULL AND movh.codigoiso != ('null') AND movh.codigoiso <> ''
		AND formato in ('0200','0220','0221','0420')
        AND movh.movreversado = 'F'
        AND movh.metodocaptura IS NOT NULL AND movh.metodocaptura != ('null')
        GROUP BY 1,2,3,4,5,6,10,11,12
        ORDER BY transacciones DESC
		INTO temp paso3  WITH NO LOG;
        CREATE INDEX idxtmp_paso3 ON paso3(codgironeg) USING BTREE;
        UPDATE STATISTICS HIGH FOR TABLE paso3;
		
		---5) Se INSERTa en la tabla de fisica tempfac_establecimiento
		--ranking,codgironeg,descgironeg,metodocaptura,idreceptor,infreceptor,transacciones, monto,promedio,producto,esnacional,periodo    
		INSERT INTO tempfac_establecimiento(codgironeg,descgironeg,metodocaptura,descripcion,idreceptor,infreceptor,transacciones,monto,promedio,producto,esnacional,periodo)
		SELECT codgironeg,descgironeg,metodocaptura,descripcion,idreceptor,infreceptor,sum(transacciones) as transacciones,sum (monto) as monto,sum (promedio) as promedio,producto,esnacional,periodo
		FROM paso3 GROUP BY 1,2,3,4,5,6,10,11,12; 
		--codgironeg,descgironeg,metodocaptura,idreceptor,infreceptor,transacciones,monto,promedio,producto,esnacional,periodo    
 
		--6) Se hace la seleción por producto y se guarda en tablas temporales
	   FOREACH 
		  SELECT  codproductotarjeta INTO vproductotarjeta2 FROM intercard:productotarjeta
		  let v_ranking3 =0;
		  FOREACH 
			   SELECT FIRST 10 codgironeg,descgironeg,metodocaptura,descripcion,idreceptor,infreceptor,transacciones,monto,promedio,producto,esnacional,periodo
			   INTO vcodgironeg,vdescgironeg,vmetodocaptura,vdescripcion,vidreceptor,vinfreceptor,vtransacciones,vmonto,vpromedio,vproducto,vesnacional,vperiodo
			   FROM tempfac_establecimiento WHERE  producto = vproductotarjeta2 AND periodo= vaniomes  AND esnacional ='V' ORDER BY transacciones DESC
			   let v_ranking3 = v_ranking3+1;	
			   INSERT  INTO paso_estab(ranking,codgironeg,descgironeg,metodocaptura,descripcion,idreceptor,infreceptor,transacciones,monto,promedio,producto,esnacional,periodo) 
			   VALUES (v_ranking3,vcodgironeg,vdescgironeg,vmetodocaptura,vdescripcion,vidreceptor,vinfreceptor,vtransacciones,vmonto,vpromedio,vproducto,vesnacional,vperiodo); 
		  END FOREACH;
	    END FOREACH;
		
		
			   FOREACH 
		  SELECT  codproductotarjeta INTO vproductotarjeta2 FROM intercard:productotarjeta
		  let v_ranking4 =0;
		  FOREACH 
			   SELECT FIRST 10 codgironeg,descgironeg,metodocaptura,descripcion,idreceptor,infreceptor,transacciones,monto,promedio,producto,esnacional,periodo
			   INTO vcodgironeg,vdescgironeg,vmetodocaptura,vdescripcion,vidreceptor,vinfreceptor,vtransacciones,vmonto,vpromedio,vproducto,vesnacional,vperiodo
			   FROM tempfac_establecimiento WHERE  producto = vproductotarjeta2 AND periodo= vaniomes  AND esnacional ='F' ORDER BY transacciones DESC
			   let v_ranking4 = v_ranking4+1;	
			   INSERT  INTO paso_estab(ranking,codgironeg,descgironeg,metodocaptura,descripcion,idreceptor,infreceptor,transacciones,monto,promedio,producto,esnacional,periodo) 
			   VALUES (v_ranking4,vcodgironeg,vdescgironeg,vmetodocaptura,vdescripcion,vidreceptor,vinfreceptor,vtransacciones,vmonto,vpromedio,vproducto,vesnacional,vperiodo); 
		  END FOREACH;
	    END FOREACH;
		
	   --7)Generar archivo por Giro de Negocio GirosNegocioNacional_201506 Nacional
	   
	   --ranking,codgironeg,descgironeg,metodocaptura,transacciones,monto,promedio,producto,esnacional, periodo   
            let vsql = ''; 	   
			let vsql = 'echo "Rank|Giro de Comercio|Desc. Giro Comercio|Método_Captura|Descripción|Num. Transacciones|Monto Total Compras|Compra Promedio|Producto|Nacional(V)/Internacional(F)|Periodo">/resplogifx/GirosNegocioNacional_'|| vaniomes ||'.unl';
			system vsql;
			let vsql = '';
			let vsql = '';
			let vsql=  'echo "UNLOAD TO /resplogifx/GirosNegocioNacional_.unl SELECT * FROM paso_nego where esnacional =''"'||'V'||'"'';">/resplogifx/gironegocio.sql'; 
			system vsql;
			let vsql ='';
			let vsql= 'dbaccess intercard /resplogifx/gironegocio.sql';
			system vsql;
			let vsql = '';
			let vsql ='rm /resplogifx/gironegocio.sql';
			system vsql;
			let vsql ='';
			let vsql = "sed 's/|$//g' /resplogifx/GirosNegocioNacional_.unl >>/resplogifx/GirosNegocioNacional_"||vaniomes||".unl";
			system vsql;
			let vsql ='rm /resplogifx/GirosNegocioNacional_.unl';
			system vsql;
			
									   
			
				   --7)Generar archivo por Giro de Negocio GirosNegocioInternacional_201506 Internacional
            let vsql = ''; 	   
			let vsql = 'echo "Rank|Giro de Comercio|Desc. Giro Comercio|Método_Captura|Descripción|Num. Transacciones|Monto Total Compras|Compra Promedio|Producto|Nacional(V)/Internacional(F)|Periodo">/resplogifx/GirosNegocioInternacional_'|| vaniomes ||'.unl';
			system vsql;
			let vsql = '';
			let vsql = '';
			let vsql=  'echo "UNLOAD TO /resplogifx/GirosNegocioInternacional_.unl SELECT * FROM paso_nego where esnacional =''"'||'F'||'"'';">/resplogifx/gironegocio.sql'; 
			system vsql;
			let vsql ='';
			let vsql= 'dbaccess intercard /resplogifx/gironegocio.sql';
			system vsql;
			let vsql = '';
			let vsql ='rm /resplogifx/gironegocio.sql';
			system vsql;
			let vsql ='';
			let vsql = "sed 's/|$//g' /resplogifx/GirosNegocioInternacional_.unl >>/resplogifx/GirosNegocioInternacional_"||vaniomes||".unl";
			system vsql;
			let vsql ='rm /resplogifx/GirosNegocioInternacional_.unl';
			system vsql;
			
		--ranking,codgironeg,descgironeg,metodocaptura,idreceptor,infreceptor,transacciones,monto,promedio,producto,esnacional,periodo  
        --8)Generar archivo Por Establecimiento 201203
		    let vsql = '';
			let vsql = 'echo "Rank|Giro de Comercio|Desc. Giro Comercio|Num.Establecimiento|Número de Comercio|Método_Captura|Descripción|Num. Transacciones|Monto Total Compras|Compra Promedio|Producto|Nacional(V)/Internacional(F)|Periodo">/resplogifx/ReporteEstablecimientoNacional_'|| vaniomes ||'.unl';
			system vsql;
			let vsql = '';
			let vsql = '';
			let vsql=  'echo "UNLOAD TO /resplogifx/ReporteEstablecimientoNacional_.unl SELECT * FROM paso_estab where esnacional=''"'||'V'||'"'';">/resplogifx/establecimiento.sql'; 
			system vsql;
			let vsql = '';
			let vsql= 'dbaccess intercard /resplogifx/establecimiento.sql';
			system vsql;
			let vsql ='';
			let vsql ='rm /resplogifx/establecimiento.sql';
			system vsql;
			let vsql ='';
			let vsql = "sed 's/|$//g' /resplogifx/ReporteEstablecimientoNacional_.unl >>/resplogifx/ReporteEstablecimientoNacional_"||vaniomes||".unl";
			system vsql;
			let vsql ='rm /resplogifx/ReporteEstablecimientoNacional_.unl';
			system vsql;
			
			
			--8)Generar archivo Por Establecimiento 201203
		    let vsql = '';
			let vsql = 'echo "Rank|Giro de Comercio|Desc. Giro Comercio|Num.Establecimiento|Número de Comercio|Método_Captura|Descripción|Num. Transacciones|Monto Total Compras|Compra Promedio|Producto|Nacional(V)/Internacional(F)|Periodo">/resplogifx/ReporteEstablecimientoInternacional_'|| vaniomes ||'.unl';
			system vsql;
			let vsql = '';
			let vsql = '';
			let vsql=  'echo "UNLOAD TO /resplogifx/ReporteEstablecimientoInternacional_.unl SELECT * FROM paso_estab where esnacional=''"'||'F'||'"'';">/resplogifx/establecimiento.sql'; 
			system vsql;
			let vsql = '';
			let vsql= 'dbaccess intercard /resplogifx/establecimiento.sql';
			system vsql;
			let vsql ='';
			let vsql ='rm /resplogifx/establecimiento.sql';
			system vsql;
			let vsql ='';
			let vsql = "sed 's/|$//g' /resplogifx/ReporteEstablecimientoInternacional_.unl >>/resplogifx/ReporteEstablecimientoInternacional_"||vaniomes||".unl";
			system vsql;
			let vsql ='rm /resplogifx/ReporteEstablecimientoInternacional_.unl';
			system vsql;
			
		
		 DROP table paso2;
		 DROP table paso3;
		 --drop table pasoprincipal;
		 DROP table paso_nego;
		 DROP table paso_estab;
		 			

				ELSE
					LET vcodret = '0001';
					LET  p_mensaje  = 'No ha concluido el cierre de credito ';
					 return vcodret, p_mensaje;
				END IF
				
		LET vcodret = '00000';
		LET  p_mensaje  = 'PROCESO EXITOSO';
		return vcodret, p_mensaje;
				
ELSE
    LET vcodret = '0001';
    LET  p_mensaje  = 'Mes ya Procesado, Favor de Verificar';
     return vcodret, p_mensaje;
END IF 
END;
END PROCEDURE;