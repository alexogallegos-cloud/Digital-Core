create procedure "informix".sp_gerenasenalizacion(fecha_mes date)
RETURNING varchar(6), varchar(80);
------ variables-----

DEFINE  error_info              varchar(80);
DEFINE  isam_err                integer;
DEFINE  vsqlerr                 integer;
DEFINE  vcodret                 varchar(6);
DEFINE  p_mensaje               varchar(80);
Define vfecha_hoy               date;
Define diferencia               integer;
Define vaniomes                 char(6);
Define dias                     integer;
Define vsucursal                varchar(5);
Define vnum                     integer; 
Define vlinea_mensual           money(30,4);
Define vcompras                 integer;
Define vmonto                   money(30,4);
Define vpromedio_mes            money(30,4);
Define vsql                     char(1150);
Define vtablas                  char(1);
-- clusters
	 Define vtcompras    integer;
	 Define vsaldo       money(30,4);

----------------------------------------------------
DEFINE ultimo_dia_mes DATE;
DEFINE primer_dia_mes DATE;
DEFINE ultimo_dia_mes_hora DATETIME YEAR TO FRACTION(5);
DEFINE primer_dia_mes_hora DATETIME YEAR TO FRACTION(5);
DEFINE FechaAux DATETIME YEAR TO FRACTION(5);

 --SET DEBUG FILE TO "/home/informix/senalizacion.out";
 --TRACE ON;
  begin
 ------------- control de errores------
  ON EXCEPTION SET vsqlerr,isam_err, error_info
           IF vsqlerr <> 0 and vsqlerr <> -958  then
                let vcodret = vsqlerr;
                let p_mensaje = error_info;
                  RETURN vcodret, p_mensaje;
            END IF;
    END EXCEPTION;
	
	  ON EXCEPTION SET vsqlerr,isam_err, error_info
           IF vsqlerr = -958  then		   
	              if error_info ='informix.suc_inf' then
					drop table suc_inf;
				   end if			   
                   if error_info ='informix.ntc' then
				      drop table ntc;					  
				   end if
				   if error_info ='informix.linea' then
				      drop table linea;
				   end if				   
				   if error_info ='informix.movimientos_cred' then
				      drop table movimientos_cred;
				   end if				  
				   if error_info ='informix.ntd' then
				      drop table ntd;
				   end if
				   if error_info ='informix.saldo_prom_mes' then
				      drop table saldo_prom_mes;
				   end if				   
				   if error_info ='informix.movimientos_debito' then
				      drop table movimientos_debito;
				   end if				   
				   if error_info ='informix.d_g5411' then
				      drop table d_g5411;
				   end if				   
				   if error_info ='informix.d_g5499' then
				      drop table d_g5499;
				   end if
				   if error_info ='informix.d_g4812' then
				      drop table d_g4812;
				   end if				   
				   if error_info ='informix.d_g5311' then
				      drop table d_g5311;
				   end if
				   if error_info ='informix.d_g5661' then
				      drop table d_g5661;
				   end if				   
				   if error_info ='informix.d_g5533' then
				      drop table d_g5533;
				   end if				   
				   if error_info ='informix.d_g5072' then
				      drop table d_g5072;
				   end if				   
				   if error_info ='informix.d_g5541' then
				      drop table d_g5541;
				   end if
				   if error_info ='informix.d_g5912' then
				      drop table d_g5912;
				   end if				   
				   if error_info ='informix.d_g5621' then
				      drop table d_g5621;
				   end if
				   if error_info ='informix.d_g5947' then
				      drop table d_g5947;
				   end if				   
				   if error_info ='informix.d_g5941' then
				      drop table d_g5941;
				   end if				   
				   if error_info ='informix.d_g7230' then
				      drop table d_g7230;
				   end if				   
				   if error_info ='informix.c_g5411' then
				      drop table c_g5411;
				   end if
				   if error_info ='informix.c_g5499' then
				      drop table c_g5499;
				   end if				   
				   if error_info ='informix.c_g4812' then
				      drop table c_g4812;
				   end if
				   if error_info ='informix.c_g5311' then
				      drop table c_g5311;
				   end if				   
				   if error_info ='informix.c_g5661' then
				      drop table c_g5661;
				   end if				   
				   if error_info ='informix.c_g5533' then
				      drop table c_g5533;
				   end if				   
				   if error_info ='informix.c_g5072' then
				      drop table c_g5072;
				   end if
				   if error_info ='informix.c_g5812' then
				      drop table c_g5812;
				   end if				   
				   if error_info ='informix.c_g5541' then
				      drop table c_g5541;
				   end if	
				   if error_info ='informix.c_g5912' then
				      drop table c_g5912;
				   end if				   
				   if error_info ='informix.c_g5621' then
				      drop table c_g5621;
				   end if				   
				   if error_info ='informix.c_g5947' then
				      drop table c_g5947;
				   end if				   
				   if error_info ='informix.c_g5941' then
				      drop table c_g5941;
				   end if
				   if error_info ='informix.c_g7230' then
				      drop table c_g7230;
				   end if   
				end if   
   END EXCEPTION WITH RESUME; 

-----------***********cuerpo**************-------------------  
--OBTIENE LA FECHA MINIMA DE INTERCARD:MOVIMIENTO    
     set isolation to dirty read;
     select fecha_hoy into vfecha_hoy from bdinteg:si_fechas;
     SELECT {+INDEX(intercard:movimiento idx_fechahorainauth)} MIN(FechaHoraInAuth)
     INTO FechaAux FROM Intercard:Movimiento;
     LET fecha_mes = vfecha_hoy;     
-----operaciones de fechas
--OBTIENE EL ULTIMO DIA DEL MES	  
     LET ultimo_dia_mes = extend(extend(fecha_mes + 0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY;
     LET ultimo_dia_mes_hora = extend(extend(fecha_mes + 0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY;
     LET ultimo_dia_mes_hora = SUBSTRING(ultimo_dia_mes_hora FROM 1 FOR 10) || ' 23:59:59';
--OBTIENE EL PRIMER DIA DEL MES
     LET primer_dia_mes = extend(extend(fecha_mes - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);
     LET primer_dia_mes_hora = extend(extend(fecha_mes - 1 units MONTH ,YEAR TO MONTH)||"-01",YEAR TO DAY);
     LET primer_dia_mes_hora= SUBSTRING(primer_dia_mes_hora FROM 1 FOR 10) || ' 00:00:00';
--OBTIENE EL AÑO Y MES DE LA FECHA	  
     let vaniomes =  year(ultimo_dia_mes) || LPAD (MONTH(ultimo_dia_mes),2,"0");
     let dias = day(ultimo_dia_mes);
  
 -----validamos si el mes de la fecha que nos dan ya esta completo y si no se ha ejecutado con anterioridad.
 if (not exists (select * from intercard:senalizacion_credito where periodo = vaniomes) and
     ultimo_dia_mes <  vfecha_hoy) then
      ----1) Obtiene información de las sucursales
      set isolation to dirty read;
      select {+INDEX(bdinteg:si_sucursales 127_95)}
            suc.sucursal as num_suc, cda.nombre as ciudad, (suc.sucursal ||' '|| suc.nombre) as  sucursal       
      from bdinteg:si_sucursales suc, bdinteg:si_ciudades cda, bdinteg:si_estados edo
      where suc.empresa='001' and 
      cda.estado = edo.estado and
      ((cda.estado = '11' and edo.siglas = 'GTO' and cda.ciudad in('032','042','036')) or
      (cda.estado = '14' and edo.siglas = 'JAL' and cda.ciudad in('105','027')) or 
      (cda.estado = '21' and edo.siglas = 'PUE' and cda.ciudad in('020')) or      
      (cda.estado = '30' and edo.siglas = 'VER' and cda.ciudad in('107','055','155','130'))) and
      suc.estado = cda.estado and
      suc.ciudad = cda.ciudad and
      suc.sucursal < 1000
      order by cda.ciudad, suc.sucursal 
      into temp suc_inf  WITH NO LOG;     

	  --- verificar si existen tablas fisicas	
          if exists (select * from systables where tabname ='suc_tarj' ) then
		   drop table suc_tarj;
		  end if
		  
          if exists (select * from systables where tabname ='mov_mes' ) then
		   drop table mov_mes;
		  end if
		           
	  ---end verificar si existen tablas fisicas
	  --crear tablas fisicas
      	    CREATE TABLE "informix".suc_tarj ( 
	        sucursal       	varchar(5),
	        numtarjeta     	varchar(16) NOT NULL,
	        fechaasignacion	datetime year to fraction(5) 
	        )EXTENT SIZE 78704 NEXT SIZE 7872 LOCK MODE ROW;
		 	  
            CREATE TABLE "informix".mov_mes ( 
	         sucursal       	varchar(5),
	         numtarjeta     	varchar(16),
	         monto          	decimal(21,4),
	         codgironeg     	varchar(4),
	         fechahorainauth	datetime year to fraction(5),
	         prodind        	varchar(2) 
	        )EXTENT SIZE 90240 NEXT SIZE 9024 LOCK MODE ROW;			  		     			

      --end crear tablas fisicas       		
		
     --2) Insertar Tarjetas Vigentes de las sucursales (credito y debito)	   
     set isolation to dirty read;
     insert into suc_tarj(sucursal, numtarjeta, fechaasignacion)
     select  {+INDEX(intercard:tarjeta lote)}
             SUBSTR (b.clave_sucursal,2,4) as sucursal, a.numtarjeta as numtarjeta, a.fechaasignacion     
     from intercard:tarjeta a, intercard:lote b, intercard:suc_inf suc
     where substr(b.clave_sucursal,2,4) = suc.num_suc and
           a.numerolote = b.numerolote and
           a.fechaasignacion <= ultimo_dia_mes_hora and 
           a.codstatustarjeta in ('ACT','BLT');
  
	 
     --3) Obtener movimientos de las tarjetas obtenidas para el periodo a procesar
     set isolation to dirty read;                
     if (ultimo_dia_mes_hora >= FechaAux ) THEN -- primer dia en movimientos <= ultimo dia del mes (como es por mes y movimiento guarda 15 dias aprox. esta en las dos)
        insert into mov_mes (sucursal, numtarjeta, monto, codgironeg, fechahorainauth, prodind )
		  select {+INDEX(intercard:movimientohistorico idx_movimiento3)} 
                tarjetas.sucursal as sucursal,
                mov.numtarjeta as numtarjeta,
                nvl(mov.monto,0) as monto, 
                mov.codgironeg as codgironeg, 
                mov.fechahorainauth as fechahorainauth, 
                mov.prodind as prodind
                from suc_tarj tarjetas, intercard:movimientohistorico mov
              where (mov.fechahorainauth  BETWEEN  primer_dia_mes_hora and ultimo_dia_mes_hora) and 
                mov.numtarjeta = tarjetas.numtarjeta and 
                mov.prodind ='02'  and 
                mov.codigoiso='00' and            
			    codgironeg in ('5411', '5499', '4812', '5311', '5661', '5533','5072', '5812', '5541', '5912', '5621', '5947', '5941', '7230')
			  group by   sucursal, codgironeg, mov.numtarjeta, monto, fechahorainauth, prodind;              

          insert into mov_mes (sucursal, numtarjeta, monto, codgironeg, fechahorainauth, prodind )
		  select {+INDEX(intercard:movimiento idx_fechahorainauth)} 
                tarjetas.sucursal as sucursal,
                mov.numtarjeta as numtarjeta,
                nvl(mov.monto,0) as monto, 
                mov.codgironeg as codgironeg, 
                mov.fechahorainauth as fechahorainauth, 
                mov.prodind as prodind
                from suc_tarj tarjetas, intercard:movimiento mov
              where (mov.fechahorainauth  BETWEEN  primer_dia_mes_hora and ultimo_dia_mes_hora) and 
                mov.numtarjeta = tarjetas.numtarjeta and 
                mov.prodind ='02'  and 
                mov.codigoiso='00' and            
			    codgironeg in ('5411', '5499', '4812', '5311', '5661', '5533','5072', '5812', '5541', '5912', '5621', '5947', '5941', '7230')
			  group by   sucursal, codgironeg, mov.numtarjeta, monto, fechahorainauth, prodind;                       
		else -- el primer dia de movimiento > a ultimo dia del mes 
		  insert into mov_mes (sucursal, numtarjeta, monto, codgironeg, fechahorainauth, prodind )
		  select {+INDEX(intercard:movimientohistorico idx_movimiento3)} 
                tarjetas.sucursal as sucursal,
                mov.numtarjeta as numtarjeta,
                nvl(mov.monto,0) as monto, 
                mov.codgironeg as codgironeg, 
                mov.fechahorainauth as fechahorainauth, 
                mov.prodind as prodind
                from suc_tarj tarjetas, intercard:movimientohistorico mov
              where (mov.fechahorainauth  BETWEEN  primer_dia_mes_hora and ultimo_dia_mes_hora) and 
                mov.numtarjeta = tarjetas.numtarjeta and 
                mov.prodind ='02'  and 
                mov.codigoiso='00' and            
			    codgironeg in ('5411', '5499', '4812', '5311', '5661', '5533','5072', '5812', '5541', '5912', '5621', '5947', '5941', '7230')
			  group by   sucursal, codgironeg, mov.numtarjeta, monto, fechahorainauth, prodind;
     end if

     --4) Obtener no. de tarjetas de crédito por sucursal
     set isolation to dirty read;
     select sucursal, nvl(count(numtarjeta),0) as num 
     from suc_tarj where numtarjeta like '426807%' group by sucursal
     into temp ntc  WITH NO LOG;

     --5) Obtener no. de tarjetas de débito por sucursal
     set isolation to dirty read;
     select sucursal, nvl(count(numtarjeta),0) as num 
     from suc_tarj 
	 where (numtarjeta like '400819%' or numtarjeta like '416916%') group by sucursal
     into temp ntd  WITH NO LOG;

     --6) Obtener línea de crédito mensual
     set isolation to dirty read;
     select mae.sucursal, nvl(sum(nvl(mad.monto_otorgado,0)),0) as linea_mensual  
     from bdicred:sd_maesdos mad, bdicred:sd_maecred mae, intercard:suc_inf suc
     where mae.empresa = '001' and
           mae.num_credito = mad.num_credito and                      
           mae.sucursal = suc.num_suc and
           fecha_apertura <= ultimo_dia_mes  
          group by mae.sucursal
          into temp linea  WITH NO LOG;	   

     --7) Obtener saldo promedio mensual
	 set isolation to dirty read;
         if TRIM(SUBSTRING (vaniomes FROM 1 FOR 4 )) = '2011' then
	     select {+INDEX(bdicheq:sc_sdodiarioc_2011 isdodiario_2011)} 
                sdo.sucursal, nvl(round(
        	(sum(nvl(capvig1,0)) + sum(nvl(capvig2,0)) + sum(nvl(capvig3,0)) 
	        + sum(nvl(capvig4,0)) + sum(nvl(capvig5,0)) +
	        sum(nvl(capvig6,0)) + sum(nvl(capvig7,0)) + sum(nvl(capvig8,0)) 
	        + sum(nvl(capvig9,0)) + sum(nvl(capvig10,0)) +
	        sum(nvl(capvig11,0)) + sum(nvl(capvig12,0)) + 
	        sum(nvl(capvig13,0)) + sum(nvl(capvig14,0)) + sum(nvl(capvig15,0)) +
	        sum(nvl(capvig16,0)) + sum(nvl(capvig17,0)) + 
        	sum(nvl(capvig18,0)) + sum(nvl(capvig19,0)) + sum(nvl(capvig20,0)) +
	        sum(nvl(capvig21,0)) + sum(nvl(capvig22,0)) + 
        	sum(nvl(capvig23,0)) + sum(nvl(capvig24,0)) + sum(nvl(capvig25,0)) +
	        sum(nvl(capvig26,0)) + sum(nvl(capvig27,0)) + 
	        sum(nvl(capvig28,0)) + sum(nvl(capvig29,0)) + sum(nvl(capvig30,0)) +
	        sum(nvl(capvig31,0))) / 31, 2),0) as promedio_mes --Cambiar días del mes
	        from bdicheq:sc_sdodiarioc_2011 sdo, intercard:suc_inf suc
	        where sdo.cuenta <> '' and 
	              sdo.aniomes= vaniomes and  --Cambiar mes del periodo vaniomes = '201103' (Considerar cuando cambie la tabla sc_sdodiarioc)
        	      sdo.sucursal = suc.num_suc
	        group by sdo.sucursal
		   into temp saldo_prom_mes  WITH NO LOG;	
         else
		select {+INDEX(bdicheq:sc_sdodiarioc isdodiario)} 
                sdo.sucursal, nvl(round(
        	(sum(nvl(capvig1,0)) + sum(nvl(capvig2,0)) + sum(nvl(capvig3,0)) 
	        + sum(nvl(capvig4,0)) + sum(nvl(capvig5,0)) +
	        sum(nvl(capvig6,0)) + sum(nvl(capvig7,0)) + sum(nvl(capvig8,0)) 
	        + sum(nvl(capvig9,0)) + sum(nvl(capvig10,0)) +
	        sum(nvl(capvig11,0)) + sum(nvl(capvig12,0)) + 
	        sum(nvl(capvig13,0)) + sum(nvl(capvig14,0)) + sum(nvl(capvig15,0)) +
	        sum(nvl(capvig16,0)) + sum(nvl(capvig17,0)) + 
        	sum(nvl(capvig18,0)) + sum(nvl(capvig19,0)) + sum(nvl(capvig20,0)) +
	        sum(nvl(capvig21,0)) + sum(nvl(capvig22,0)) + 
        	sum(nvl(capvig23,0)) + sum(nvl(capvig24,0)) + sum(nvl(capvig25,0)) +
	        sum(nvl(capvig26,0)) + sum(nvl(capvig27,0)) + 
	        sum(nvl(capvig28,0)) + sum(nvl(capvig29,0)) + sum(nvl(capvig30,0)) +
	        sum(nvl(capvig31,0))) / 31, 2),0) as promedio_mes --Cambiar días del mes
	        from bdicheq:sc_sdodiarioc sdo, intercard:suc_inf suc
	        where sdo.cuenta <> '' and 
	              sdo.aniomes= vaniomes and  --Cambiar mes del periodo vaniomes = '201103' (Considerar cuando cambie la tabla sc_sdodiarioc)
        	      sdo.sucursal = suc.num_suc
	        group by sdo.sucursal
		   into temp saldo_prom_mes  WITH NO LOG;
         end if 	

    --8) Obtener movimientos de crédito del mes por sucursal             
     set isolation to dirty read;
     select tarjetas.sucursal, nvl(count(monto),0) as compras , sum(nvl(mov.monto,0)) as monto 
     from suc_tarj tarjetas, mov_mes mov
     where (mov.fechahorainauth  BETWEEN primer_dia_mes_hora and ultimo_dia_mes_hora) and --Cambiar fechas primer_dia_mes_hora = '2011-03-01 00:00:01.0' y ultimo_dia_mes_hora = '2011-03-31 23:59:59.9'
            mov.numtarjeta like '426807%' and 
            mov.numtarjeta  = tarjetas.numtarjeta and 
            mov.prodind ='02'
     group by tarjetas.sucursal
     into temp movimientos_cred WITH NO LOG;

     --9) Obtener movimientos de débito del mes por sucursal             			  			  
     set isolation to dirty read;
     select tarjetas.sucursal, nvl(count(monto),0) as compras , sum(nvl(mov.monto,0)) as monto 
     from suc_tarj tarjetas, mov_mes mov
     where (mov.fechahorainauth BETWEEN primer_dia_mes_hora and ultimo_dia_mes_hora) and 
           (mov.numtarjeta like '400819%' or mov.numtarjeta like '416916%') and 
            mov.numtarjeta  = tarjetas.numtarjeta and 
            mov.prodind ='02'
     group by tarjetas.sucursal
     into temp movimientos_debito WITH NO LOG;

     --13) Cargar los clusters de Crédito y Débito (Remplazar todas las fechas)			  		  
	 ------CLUSTERS CREDITO
     --Giros de negocio 5411, 5499, 4812, 5311     
       set isolation to dirty read;
       select tarjetas.sucursal, nvl(count(mov.monto),0) as tcompras , SUM(nvl(mov.monto,0)) as saldo from suc_tarj  tarjetas, mov_mes mov
       where (mov.fechahorainauth  BETWEEN  primer_dia_mes_hora and ultimo_dia_mes_hora) and mov.numtarjeta like '426807%' and 
       mov.numtarjeta  = tarjetas.numtarjeta and mov.prodind ='02' and mov.codgironeg='5411' group by tarjetas.sucursal
       into temp c_g5411 WITH NO LOG;

       set isolation to dirty read;	
	   select tarjetas.sucursal, nvl(count(mov.monto),0) as tcompras , SUM(nvl(mov.monto,0)) as saldo from suc_tarj  tarjetas, mov_mes mov
       where (mov.fechahorainauth  BETWEEN primer_dia_mes_hora and ultimo_dia_mes_hora) and mov.numtarjeta like '426807%' and
       mov.numtarjeta  = tarjetas.numtarjeta and mov.prodind ='02' and mov.codgironeg='5499' group by tarjetas.sucursal
	   into temp c_g5499 WITH NO LOG;
   
       set isolation to dirty read;
	   select tarjetas.sucursal, nvl(count(mov.monto),0) as tcompras , SUM(nvl(mov.monto,0)) as saldo from suc_tarj  tarjetas, mov_mes mov
       where (mov.fechahorainauth  BETWEEN  primer_dia_mes_hora and ultimo_dia_mes_hora) and mov.numtarjeta like '426807%' and
       mov.numtarjeta  = tarjetas.numtarjeta and mov.prodind ='02' and mov.codgironeg='4812' group by tarjetas.sucursal
       into temp c_g4812 WITH NO LOG;

       set isolation to dirty read;      
	   select tarjetas.sucursal, nvl(count(mov.monto),0) as tcompras , SUM(nvl(mov.monto,0)) as saldo from suc_tarj  tarjetas, mov_mes mov
       where (mov.fechahorainauth  BETWEEN  primer_dia_mes_hora and ultimo_dia_mes_hora) and mov.numtarjeta like '426807%' and
       mov.numtarjeta  = tarjetas.numtarjeta and mov.prodind ='02' and mov.codgironeg='5311' group by tarjetas.sucursal
       into temp c_g5311;
					
       --Giros de negocio 5661, 5533, 5072, 5812, 5541, 5912
       set isolation to dirty read;      
       select tarjetas.sucursal, nvl(count(mov.monto),0) as tcompras , SUM(nvl(mov.monto,0)) as saldo from suc_tarj  tarjetas, mov_mes mov
       where (mov.fechahorainauth  BETWEEN  primer_dia_mes_hora and ultimo_dia_mes_hora) and mov.numtarjeta like '426807%' and
       mov.numtarjeta  = tarjetas.numtarjeta and mov.prodind ='02' and mov.codgironeg='5661' group by tarjetas.sucursal
	   into temp c_g5661 WITH NO LOG;
       	  
       set isolation to dirty read;      
	   select tarjetas.sucursal,  nvl(count(mov.monto),0) as tcompras , SUM(nvl(mov.monto,0)) as saldo from suc_tarj  tarjetas, mov_mes mov
       where (mov.fechahorainauth  BETWEEN  primer_dia_mes_hora and ultimo_dia_mes_hora) and mov.numtarjeta like '426807%' and
       mov.numtarjeta  = tarjetas.numtarjeta and mov.prodind ='02' and mov.codgironeg='5533' group by tarjetas.sucursal
       into temp c_g5533 WITH NO LOG;

       set isolation to dirty read;           
	   select tarjetas.sucursal, nvl(count(mov.monto),0) as tcompras , SUM(nvl(mov.monto,0)) as saldo from suc_tarj  tarjetas, mov_mes mov
       where (mov.fechahorainauth  BETWEEN  primer_dia_mes_hora and ultimo_dia_mes_hora) and mov.numtarjeta like '426807%' and
       mov.numtarjeta  = tarjetas.numtarjeta and mov.prodind ='02' and mov.codgironeg='5072' group by tarjetas.sucursal
	   into temp c_g5072 WITH NO LOG;
      
       set isolation to dirty read;      
	   select tarjetas.sucursal, nvl(count(mov.monto),0) as tcompras , SUM(nvl(mov.monto,0)) as saldo from suc_tarj  tarjetas, mov_mes mov
       where (mov.fechahorainauth  BETWEEN  primer_dia_mes_hora and ultimo_dia_mes_hora) and mov.numtarjeta like '426807%' and
       mov.numtarjeta  = tarjetas.numtarjeta and mov.prodind ='02' and mov.codgironeg='5812' group by tarjetas.sucursal
	   into temp c_g5812 WITH NO LOG;
	 
       set isolation to dirty read;      
	   select tarjetas.sucursal, nvl(count(mov.monto),0) as tcompras , SUM(nvl(mov.monto,0)) as saldo from suc_tarj  tarjetas, mov_mes mov
       where (mov.fechahorainauth  BETWEEN  primer_dia_mes_hora and ultimo_dia_mes_hora) and mov.numtarjeta like '426807%' and
       mov.numtarjeta  = tarjetas.numtarjeta and mov.prodind ='02' and mov.codgironeg='5541' group by tarjetas.sucursal
	   into temp c_g5541 WITH NO LOG;
	  
       set isolation to dirty read;      
	   select tarjetas.sucursal, nvl(count(mov.monto),0) as tcompras , SUM(nvl(mov.monto,0)) as saldo from suc_tarj  tarjetas,  mov_mes mov
       where (mov.fechahorainauth  BETWEEN  primer_dia_mes_hora and ultimo_dia_mes_hora) and mov.numtarjeta like '426807%' and
       mov.numtarjeta  = tarjetas.numtarjeta and mov.prodind ='02' and mov.codgironeg='5912' group by tarjetas.sucursal
	   into temp c_g5912 WITH NO LOG;

       --Giros de negocio 5621, 5947, 5941, 7230	
       set isolation to dirty read;      
       select tarjetas.sucursal, nvl(count(mov.monto),0) as tcompras , SUM(nvl(mov.monto,0)) as saldo from suc_tarj  tarjetas, mov_mes mov
       where (mov.fechahorainauth  BETWEEN  primer_dia_mes_hora and ultimo_dia_mes_hora) and mov.numtarjeta like '426807%' and
       mov.numtarjeta  = tarjetas.numtarjeta and mov.prodind ='02' and mov.codgironeg='5621' group by tarjetas.sucursal
	   into temp c_g5621 WITH NO LOG;
	  
       set isolation to dirty read;      
	   select tarjetas.sucursal, nvl(count(mov.monto),0) as tcompras , SUM(nvl(mov.monto,0)) as saldo from suc_tarj  tarjetas, mov_mes mov
       where (mov.fechahorainauth  BETWEEN  primer_dia_mes_hora and ultimo_dia_mes_hora) and mov.numtarjeta like '426807%' and
       mov.numtarjeta  = tarjetas.numtarjeta and mov.prodind ='02' and mov.codgironeg='5947' group by tarjetas.sucursal
	   into temp c_g5947 WITH NO LOG;

       set isolation to dirty read;            
	   select tarjetas.sucursal, nvl(count(mov.monto),0) as tcompras , SUM(nvl(mov.monto,0)) as saldo from suc_tarj  tarjetas, mov_mes mov
       where (mov.fechahorainauth  BETWEEN  primer_dia_mes_hora and ultimo_dia_mes_hora) and mov.numtarjeta like '426807%' and
       mov.numtarjeta  = tarjetas.numtarjeta and mov.prodind ='02' and mov.codgironeg='5941' group by tarjetas.sucursal
	   into temp c_g5941 WITH NO LOG;
      
       set isolation to dirty read;      
	   select tarjetas.sucursal, nvl(count(mov.monto),0) as tcompras , SUM(nvl(mov.monto,0)) as saldo from suc_tarj  tarjetas, mov_mes mov
       where (mov.fechahorainauth  BETWEEN  primer_dia_mes_hora and ultimo_dia_mes_hora) and mov.numtarjeta like '426807%' and
       mov.numtarjeta  = tarjetas.numtarjeta and mov.prodind ='02' and mov.codgironeg='7230' group by tarjetas.sucursal
	   into temp c_g7230 WITH NO LOG;							

       ------CLUSTERS DEBITO
       --Giros de negocio 5411, 5499, 4812, 5311          
       set isolation to dirty read;  
       select tarjetas.sucursal, nvl(count(mov.monto),0) as tcompras , SUM(nvl(mov.monto,0)) as saldo from suc_tarj  tarjetas, mov_mes mov
       where (mov.fechahorainauth  BETWEEN  primer_dia_mes_hora and ultimo_dia_mes_hora) and 
	   (mov.numtarjeta like '400819%' or mov.numtarjeta like '416916%') and
       mov.numtarjeta  = tarjetas.numtarjeta and mov.prodind ='02' and mov.codgironeg='5411' group by tarjetas.sucursal
	   into temp d_g5411 WITH NO LOG;
       
       set isolation to dirty read;  	  
	   select tarjetas.sucursal, nvl(count(mov.monto),0) as tcompras , SUM(nvl(mov.monto,0)) as saldo from suc_tarj  tarjetas, mov_mes mov
       where (mov.fechahorainauth  BETWEEN  primer_dia_mes_hora and ultimo_dia_mes_hora) and 
	   (mov.numtarjeta like '400819%' or mov.numtarjeta like '416916%') and
       mov.numtarjeta  = tarjetas.numtarjeta and mov.prodind ='02' and mov.codgironeg='5499' group by tarjetas.sucursal
	   into temp d_g5499 WITH NO LOG;

       set isolation to dirty read;        
	   select tarjetas.sucursal, nvl(count(mov.monto),0) as tcompras , SUM(nvl(mov.monto,0)) as saldo from suc_tarj  tarjetas, mov_mes mov
       where (mov.fechahorainauth  BETWEEN  primer_dia_mes_hora and ultimo_dia_mes_hora) and 
	   (mov.numtarjeta like '400819%' or mov.numtarjeta like '416916%') and
       mov.numtarjeta  = tarjetas.numtarjeta and mov.prodind ='02' and mov.codgironeg='4812' group by tarjetas.sucursal
	   into temp d_g4812 WITH NO LOG;
      
       set isolation to dirty read;  
 	   select tarjetas.sucursal, nvl(count(mov.monto),0) as tcompras , SUM(nvl(mov.monto,0)) as saldo from suc_tarj  tarjetas, mov_mes mov
       where (mov.fechahorainauth  BETWEEN  primer_dia_mes_hora and ultimo_dia_mes_hora) and 
	   (mov.numtarjeta like '400819%' or mov.numtarjeta like '416916%') and
       mov.numtarjeta  = tarjetas.numtarjeta and mov.prodind ='02' and mov.codgironeg='5311' group by tarjetas.sucursal
	   into temp d_g5311 WITH NO LOG;
					
       --Giros de negocio 5661, 5533, 5072, 5812, 5541, 5912
       set isolation to dirty read;  
       select tarjetas.sucursal, nvl(count(mov.monto),0) as tcompras , SUM(nvl(mov.monto,0)) as saldo from suc_tarj  tarjetas, mov_mes mov
       where (mov.fechahorainauth  BETWEEN  primer_dia_mes_hora and ultimo_dia_mes_hora) and 
	   (mov.numtarjeta like '400819%' or mov.numtarjeta like '416916%') and
       mov.numtarjeta  = tarjetas.numtarjeta and mov.prodind ='02' and mov.codgironeg='5661' group by tarjetas.sucursal
	   into temp d_g5661 WITH NO LOG;
	  
       set isolation to dirty read;  
	   select tarjetas.sucursal, nvl(count(mov.monto),0) as tcompras , SUM(nvl(mov.monto,0)) as saldo from suc_tarj  tarjetas, mov_mes mov
       where (mov.fechahorainauth  BETWEEN  primer_dia_mes_hora and ultimo_dia_mes_hora) and 
	   (mov.numtarjeta like '400819%' or mov.numtarjeta like '416916%') and
       mov.numtarjeta  = tarjetas.numtarjeta and mov.prodind ='02' and mov.codgironeg='5533' group by tarjetas.sucursal
	   into temp d_g5533 WITH NO LOG;
      
       set isolation to dirty read;  
	   select tarjetas.sucursal, nvl(count(mov.monto),0) as tcompras , SUM(nvl(mov.monto,0)) as saldo from suc_tarj  tarjetas, mov_mes mov
       where (mov.fechahorainauth  BETWEEN  primer_dia_mes_hora and ultimo_dia_mes_hora) and 
	   (mov.numtarjeta like '400819%' or mov.numtarjeta like '416916%') and
       mov.numtarjeta  = tarjetas.numtarjeta and mov.prodind ='02' and mov.codgironeg='5072' group by tarjetas.sucursal
	   into temp d_g5072 WITH NO LOG;
      
       set isolation to dirty read;  
	   select tarjetas.sucursal, nvl(count(mov.monto),0) as tcompras , SUM(nvl(mov.monto,0)) as saldo from suc_tarj  tarjetas, mov_mes mov
       where (mov.fechahorainauth  BETWEEN  primer_dia_mes_hora and ultimo_dia_mes_hora) and 
	   (mov.numtarjeta like '400819%' or mov.numtarjeta like '416916%') and
       mov.numtarjeta  = tarjetas.numtarjeta and mov.prodind ='02' and mov.codgironeg='5812' group by tarjetas.sucursal
	   into temp d_g5812 WITH NO LOG;
	  
       set isolation to dirty read;  
	   select tarjetas.sucursal, nvl(count(mov.monto),0) as tcompras , SUM(nvl(mov.monto,0)) as saldo from suc_tarj  tarjetas, mov_mes mov
       where (mov.fechahorainauth  BETWEEN  primer_dia_mes_hora and ultimo_dia_mes_hora) and 
	   (mov.numtarjeta like '400819%' or mov.numtarjeta like '416916%') and
       mov.numtarjeta  = tarjetas.numtarjeta and mov.prodind ='02' and mov.codgironeg='5541' group by tarjetas.sucursal
	   into temp d_g5541 WITH NO LOG;
	  
       set isolation to dirty read;  
	   select tarjetas.sucursal, nvl(count(mov.monto),0) as tcompras , SUM(nvl(mov.monto,0)) as saldo from suc_tarj  tarjetas, mov_mes mov
       where (mov.fechahorainauth  BETWEEN  primer_dia_mes_hora and ultimo_dia_mes_hora) and 
	   (mov.numtarjeta like '400819%' or mov.numtarjeta like '416916%') and
       mov.numtarjeta  = tarjetas.numtarjeta and mov.prodind ='02' and mov.codgironeg='5912' group by tarjetas.sucursal
	   into temp d_g5912 WITH NO LOG;

       --Giros de negocio 5631, 5947, 5941, 7230	
       set isolation to dirty read;
       select tarjetas.sucursal, nvl(count(mov.monto),0) as tcompras , SUM(nvl(mov.monto,0)) as saldo from suc_tarj  tarjetas, mov_mes mov
       where (mov.fechahorainauth  BETWEEN  primer_dia_mes_hora and ultimo_dia_mes_hora) and 
	   (mov.numtarjeta like '400819%' or mov.numtarjeta like '416916%') and
       mov.numtarjeta  = tarjetas.numtarjeta and mov.prodind ='02' and mov.codgironeg='5621' group by tarjetas.sucursal
	   into temp d_g5621 WITH NO LOG;
	  
       set isolation to dirty read;
	   select tarjetas.sucursal, nvl(count(mov.monto),0) as tcompras , SUM(nvl(mov.monto,0)) as saldo from suc_tarj  tarjetas, mov_mes mov
       where (mov.fechahorainauth  BETWEEN  primer_dia_mes_hora and ultimo_dia_mes_hora) and 
	   (mov.numtarjeta like '400819%' or mov.numtarjeta like '416916%') and
       mov.numtarjeta  = tarjetas.numtarjeta and mov.prodind ='02' and mov.codgironeg='5947' group by tarjetas.sucursal
	   into temp d_g5947 WITH NO LOG;
      
       set isolation to dirty read;
	   select tarjetas.sucursal, nvl(count(mov.monto),0) as tcompras , SUM(nvl(mov.monto,0)) as saldo from suc_tarj  tarjetas, mov_mes mov
       where (mov.fechahorainauth  BETWEEN  primer_dia_mes_hora and ultimo_dia_mes_hora) and 
	   (mov.numtarjeta like '400819%' or mov.numtarjeta like '416916%') and
       mov.numtarjeta  = tarjetas.numtarjeta and mov.prodind ='02' and mov.codgironeg='5941' group by tarjetas.sucursal
	   into temp d_g5941 WITH NO LOG;
      
       set isolation to dirty read;
	   select tarjetas.sucursal, nvl(count(mov.monto),0) as tcompras , SUM(nvl(mov.monto,0)) as saldo from suc_tarj  tarjetas, mov_mes mov
       where (mov.fechahorainauth  BETWEEN  primer_dia_mes_hora and ultimo_dia_mes_hora) and 
	   (mov.numtarjeta like '400819%' or mov.numtarjeta like '416916%') and
       mov.numtarjeta  = tarjetas.numtarjeta and mov.prodind ='02' and mov.codgironeg='7230' group by tarjetas.sucursal
	   into temp d_g7230 WITH NO LOG;
	 
       ------------------ union de tablas temporales-----------------------------------

       ---insertar a tabla de reporte de tdc

       --14) Insertar encabezado de Señalización de Crédito
       INSERT INTO senalizacion_credito (periodo, n_suc, ciudad, sucursal) 
       select vaniomes, num_suc, ciudad , sucursal from suc_inf;
       
       --15) Actualizar Señalizacion Crédito              
       --Actualiza numero de tarjetas
       begin;
       update {+INDEX(intercard:senalizacion_credito idx_sen_credito)}
              senalizacion_credito 
       set num = (select n.num
                  from ntc n
                  where n_suc = n.sucursal)
       where periodo = vaniomes and
             n_suc = (select m.sucursal 
                      from ntc m
                      where n_suc = m.sucursal);
       commit;
       
       --Actualiza linea mensual
       begin;
       update {+INDEX(intercard:senalizacion_credito idx_sen_credito)}
              senalizacion_credito 
       set linea_mensual = (select n.linea_mensual
                            from linea n
                            where n_suc = n.sucursal)
       where periodo = vaniomes and
             n_suc = (select m.sucursal 
                      from linea m
                      where n_suc = m.sucursal);
       commit;

       ---Actualiza compras y monto
       begin;
       update {+INDEX(intercard:senalizacion_credito idx_sen_credito)}
              senalizacion_credito 
       set compras = (select n.compras
                      from movimientos_cred n
                      where n_suc = n.sucursal),
             monto = (select n.monto
                      from movimientos_cred n
                      where n_suc = n.sucursal)
       where periodo = vaniomes and
             n_suc = (select m.sucursal 
                      from movimientos_cred m
                      where n_suc = m.sucursal);       	 
       commit;
		
       --Actualiza Clusters de Crédito
       begin;
       update {+INDEX(intercard:senalizacion_credito idx_sen_credito)}
              senalizacion_credito
       set tcompras_5411 = (select n.tcompras
                            from c_g5411 n
                            where n_suc = n.sucursal),
              saldo_5411 = (select n.saldo
                            from c_g5411 n
                            where n_suc = n.sucursal)
             where periodo = vaniomes and
                   n_suc = (select m.sucursal 
                            from c_g5411 m
                            where n_suc = m.sucursal);
       commit;

       begin;
       update {+INDEX(intercard:senalizacion_credito idx_sen_credito)}
              senalizacion_credito 
       set tcompras_5499 = (select n.tcompras
                            from c_g5499 n
                            where n_suc = n.sucursal),
              saldo_5499 = (select n.saldo
                            from c_g5499 n
                            where n_suc = n.sucursal)
             where periodo = vaniomes and
                   n_suc = (select m.sucursal 
                            from c_g5499 m
                            where n_suc = m.sucursal);
       commit;

       begin;                            
       update {+INDEX(intercard:senalizacion_credito idx_sen_credito)}
              senalizacion_credito 
       set tcompras_4812 = (select n.tcompras
                            from c_g4812 n
                            where n_suc = n.sucursal),
              saldo_4812 = (select n.saldo
                            from c_g4812 n
                            where n_suc = n.sucursal)
             where periodo = vaniomes and
                   n_suc = (select m.sucursal 
                            from c_g4812 m
                            where n_suc = m.sucursal);
       commit;
       
       begin;
       update {+INDEX(intercard:senalizacion_credito idx_sen_credito)}
              senalizacion_credito 
       set tcompras_5311 = (select n.tcompras
                            from c_g5311 n
                            where n_suc = n.sucursal),
              saldo_5311 = (select n.saldo
                            from c_g5311 n
                            where n_suc = n.sucursal)
             where periodo = vaniomes and
                   n_suc = (select m.sucursal 
                            from c_g5311 m
                            where n_suc = m.sucursal);
       commit;

       begin;
       update {+INDEX(intercard:senalizacion_credito idx_sen_credito)}
              senalizacion_credito 
       set tcompras_5661 = (select n.tcompras
                            from c_g5661 n
                            where n_suc = n.sucursal),
              saldo_5661 = (select n.saldo
                            from c_g5661 n
                            where n_suc = n.sucursal)
             where periodo = vaniomes and
                   n_suc = (select m.sucursal 
                            from c_g5661 m
                            where n_suc = m.sucursal);
       commit;

       begin;
       update {+INDEX(intercard:senalizacion_credito idx_sen_credito)}
              senalizacion_credito 
       set tcompras_5533 = (select n.tcompras
                            from c_g5533 n
                            where n_suc = n.sucursal),
              saldo_5533 = (select n.saldo
                            from c_g5533 n
                            where n_suc = n.sucursal)
             where periodo = vaniomes and
                   n_suc = (select m.sucursal 
                            from c_g5533 m
                            where n_suc = m.sucursal);
       commit;

       begin;
       update {+INDEX(intercard:senalizacion_credito idx_sen_credito)}
              senalizacion_credito 
       set tcompras_5072 = (select n.tcompras
                            from c_g5072 n
                            where n_suc = n.sucursal),
              saldo_5072 = (select n.saldo
                            from c_g5072 n
                            where n_suc = n.sucursal)
            where periodo = vaniomes and
                n_suc = (select m.sucursal 
                         from c_g5072 m
                         where n_suc = m.sucursal);
       commit;

       begin;
       update {+INDEX(intercard:senalizacion_credito idx_sen_credito)}
              senalizacion_credito 
       set tcompras_5812 = (select n.tcompras
                            from c_g5812 n
                            where n_suc = n.sucursal),
              saldo_5812 = (select n.saldo
                            from c_g5812 n
                            where n_suc = n.sucursal)
             where periodo = vaniomes and
                   n_suc = (select m.sucursal 
                            from c_g5812 m
                            where n_suc = m.sucursal);
       commit;
       
       begin;
       update {+INDEX(intercard:senalizacion_credito idx_sen_credito)}
              senalizacion_credito 
       set tcompras_5541 = (select n.tcompras
                            from c_g5541 n
                            where n_suc = n.sucursal),
              saldo_5541 = (select n.saldo
                            from c_g5541 n
                            where n_suc = n.sucursal)
             where periodo = vaniomes and
                   n_suc = (select m.sucursal 
                            from c_g5541 m
                            where n_suc = m.sucursal);
       commit;
 
       begin;
       update {+INDEX(intercard:senalizacion_credito idx_sen_credito)}
              senalizacion_credito 
       set tcompras_5912 = (select n.tcompras
                            from c_g5912 n
                            where n_suc = n.sucursal),
              saldo_5912 = (select n.saldo
                            from c_g5912 n
                            where n_suc = n.sucursal)
             where periodo = vaniomes and
                   n_suc = (select m.sucursal 
                            from c_g5912 m
                            where n_suc = m.sucursal);
       commit;

       begin;
        update {+INDEX(intercard:senalizacion_credito idx_sen_credito)}
               senalizacion_credito 
        set tcompras_5621 = (select n.tcompras
                             from c_g5621 n
                             where n_suc = n.sucursal),
               saldo_5621 = (select n.saldo
                             from c_g5621 n
                             where n_suc = n.sucursal)
              where periodo = vaniomes and
                    n_suc = (select m.sucursal 
                             from c_g5621 m
                             where n_suc = m.sucursal);
       commit;

       begin;
        update {+INDEX(intercard:senalizacion_credito idx_sen_credito)}
               senalizacion_credito 
        set tcompras_5947 = (select n.tcompras
                             from c_g5947 n
                             where n_suc = n.sucursal),
               saldo_5947 = (select n.saldo
                             from c_g5947 n
                             where n_suc = n.sucursal)
              where periodo = vaniomes and
                    n_suc = (select m.sucursal 
                             from c_g5947 m
                             where n_suc = m.sucursal);
       commit;

       begin;
        update {+INDEX(intercard:senalizacion_credito idx_sen_credito)}
               senalizacion_credito 
        set tcompras_5941 = (select n.tcompras
                             from c_g5941 n
                             where n_suc = n.sucursal),
               saldo_5941 = (select n.saldo
                             from c_g5941 n
                             where n_suc = n.sucursal)
              where periodo = vaniomes and
                    n_suc = (select m.sucursal 
                             from c_g5941 m
                             where n_suc = m.sucursal);
       commit;

       begin;
        update {+INDEX(intercard:senalizacion_credito idx_sen_credito)}
               senalizacion_credito 
        set tcompras_7230 = (select n.tcompras
                             from c_g7230 n
                             where n_suc = n.sucursal),
               saldo_7230 = (select n.saldo
                             from c_g7230 n
                             where n_suc = n.sucursal)
              where periodo = vaniomes and
                    n_suc = (select m.sucursal 
                             from c_g7230 m
                             where n_suc = m.sucursal);
       commit;

        --16) Insertar encabezado de Señalización de Débito
        INSERT INTO senalizacion_debito (periodo, n_suc, ciudad, sucursal)
        select vaniomes, num_suc, ciudad , sucursal from suc_inf;

        --17) Actualizar Señalizacion Débito
        --Actualiza numero de tarjetas	 
       begin;
	    update {+INDEX(intercard:senalizacion_debito idx_sen_debito)}
               senalizacion_debito 
        set num = (select n.num
                  from ntd n
                  where n_suc = n.sucursal)
        where periodo = vaniomes and
             n_suc = (select m.sucursal 
                      from ntd m
                      where n_suc = m.sucursal);
       commit;
    		  
	    --promedio mensual 
       begin;
        update {+INDEX(intercard:senalizacion_debito idx_sen_debito)}
               senalizacion_debito
        set promedio_mes = (select n.promedio_mes
                            from saldo_prom_mes n
                            where n_suc = n.sucursal)
        where periodo = vaniomes and
              n_suc = (select m.sucursal 
                       from saldo_prom_mes m
                       where n_suc = m.sucursal);
       commit;
        
        --Actualiza compras monto
       begin;
        update {+INDEX(intercard:senalizacion_debito idx_sen_debito)}
               senalizacion_debito
        set compras = (select n.compras
                       from movimientos_debito n
                       where n_suc = n.sucursal),
              monto = (select n.monto
                       from movimientos_debito n
                       where n_suc = n.sucursal)
        where periodo = vaniomes and
              n_suc = (select m.sucursal 
                       from movimientos_debito m
                       where n_suc = m.sucursal);
       commit;
		
        --Actualiza Clusters de Débito
       begin;
        update {+INDEX(intercard:senalizacion_debito idx_sen_debito)}
               senalizacion_debito
        set tcompras_5411 = (select n.tcompras
                             from d_g5411 n
                             where n_suc = n.sucursal),
               saldo_5411 = (select n.saldo
                             from d_g5411 n
                             where n_suc = n.sucursal)
        where periodo = vaniomes and
              n_suc = (select m.sucursal 
                       from d_g5411 m
                       where n_suc = m.sucursal);
       commit;

       begin;
        update {+INDEX(intercard:senalizacion_debito idx_sen_debito)}
               senalizacion_debito
        set tcompras_5499 = (select n.tcompras
                             from d_g5499 n
                             where n_suc = n.sucursal),
               saldo_5499 = (select n.saldo
                             from d_g5499 n
                             where n_suc = n.sucursal)
        where periodo = vaniomes and
              n_suc = (select m.sucursal 
                       from d_g5499 m
                       where n_suc = m.sucursal);
       commit;

       begin;
        update {+INDEX(intercard:senalizacion_debito idx_sen_debito)}
               senalizacion_debito
        set tcompras_4812 = (select n.tcompras
                             from d_g4812 n
                             where n_suc = n.sucursal),
               saldo_4812 = (select n.saldo
                             from d_g4812 n
                             where n_suc = n.sucursal)
        where periodo = vaniomes and
              n_suc = (select m.sucursal 
                       from d_g4812 m
                       where n_suc = m.sucursal);
       commit;

       begin;
        update {+INDEX(intercard:senalizacion_debito idx_sen_debito)}
               senalizacion_debito
        set tcompras_5311 = (select n.tcompras
                             from d_g5311 n
                             where n_suc = n.sucursal),
               saldo_5311 = (select n.saldo
                             from d_g5311 n
                             where n_suc = n.sucursal)
        where periodo = vaniomes and
              n_suc = (select m.sucursal 
                       from d_g5311 m
                       where n_suc = m.sucursal);
       commit;

       begin;
        update {+INDEX(intercard:senalizacion_debito idx_sen_debito)}
               senalizacion_debito 
        set tcompras_5661 = (select n.tcompras
                             from d_g5661 n
                             where n_suc = n.sucursal),
               saldo_5661 = (select n.saldo
                             from d_g5661 n
                             where n_suc = n.sucursal)
        where periodo = vaniomes and
                    n_suc = (select m.sucursal 
                             from d_g5661 m
                             where n_suc = m.sucursal);
       commit;

       begin;
        update {+INDEX(intercard:senalizacion_debito idx_sen_debito)}
               senalizacion_debito 
        set tcompras_5533 = (select n.tcompras
                             from d_g5533 n
                             where n_suc = n.sucursal),
               saldo_5533 = (select n.saldo
                             from d_g5533 n
                             where n_suc = n.sucursal)
        where periodo = vaniomes and
              n_suc = (select m.sucursal 
                       from d_g5533 m
                       where n_suc = m.sucursal);
       commit;

       begin;
        update {+INDEX(intercard:senalizacion_debito idx_sen_debito)}
               senalizacion_debito 
        set tcompras_5072 = (select n.tcompras
                             from d_g5072 n
                             where n_suc = n.sucursal),
               saldo_5072 = (select n.saldo
                             from d_g5072 n
                             where n_suc = n.sucursal)
        where periodo = vaniomes and
              n_suc = (select m.sucursal 
                       from d_g5072 m
                       where n_suc = m.sucursal);
       commit;

       begin;
        update {+INDEX(intercard:senalizacion_debito idx_sen_debito)}
               senalizacion_debito 
        set tcompras_5812 = (select n.tcompras
                             from d_g5812 n
                             where n_suc = n.sucursal),
               saldo_5812 = (select n.saldo
                             from d_g5812 n
                             where n_suc = n.sucursal)
        where periodo = vaniomes and
              n_suc = (select m.sucursal 
                       from d_g5812 m
                       where n_suc = m.sucursal);
       commit;

       begin;
        update {+INDEX(intercard:senalizacion_debito idx_sen_debito)}
               senalizacion_debito 
        set tcompras_5541 = (select n.tcompras
                             from d_g5541 n
                             where n_suc = n.sucursal),
            saldo_5541 = (select n.saldo
                          from d_g5541 n
                          where n_suc = n.sucursal)
        where periodo = vaniomes and
              n_suc = (select m.sucursal 
                       from d_g5541 m
                       where n_suc = m.sucursal);
       commit;

       begin;
        update {+INDEX(intercard:senalizacion_debito idx_sen_debito)}
               senalizacion_debito 
        set tcompras_5912 = (select n.tcompras
                            from d_g5912 n
                            where n_suc = n.sucursal),
              saldo_5912 = (select n.saldo
                            from d_g5912 n
                            where n_suc = n.sucursal)
        where periodo = vaniomes and
              n_suc = (select m.sucursal 
                       from d_g5912 m
                       where n_suc = m.sucursal);
       commit;

       begin;
        update {+INDEX(intercard:senalizacion_debito idx_sen_debito)}
               senalizacion_debito 
        set tcompras_5621 = (select n.tcompras
                             from d_g5621 n
                             where n_suc = n.sucursal),
               saldo_5621 = (select n.saldo
                             from d_g5621 n
                             where n_suc = n.sucursal)
        where periodo = vaniomes and
              n_suc = (select m.sucursal 
                       from d_g5621 m
                       where n_suc = m.sucursal);
       commit;

       begin;
        update {+INDEX(intercard:senalizacion_debito idx_sen_debito)}
               senalizacion_debito 
        set tcompras_5947 = (select n.tcompras
                             from d_g5947 n
                             where n_suc = n.sucursal),
               saldo_5947 = (select n.saldo
                             from d_g5947 n
                             where n_suc = n.sucursal)
        where periodo = vaniomes and
              n_suc = (select m.sucursal 
                       from d_g5947 m
                       where n_suc = m.sucursal);
       commit;

       begin;
        update {+INDEX(intercard:senalizacion_debito idx_sen_debito)}
               senalizacion_debito 
        set tcompras_5941 = (select n.tcompras
                             from d_g5941 n
                             where n_suc = n.sucursal),
               saldo_5941 = (select n.saldo
                             from d_g5941 n
                             where n_suc = n.sucursal)
        where periodo = vaniomes and
              n_suc = (select m.sucursal 
                       from d_g5941 m
                       where n_suc = m.sucursal);
       commit;

       begin;
        update {+INDEX(intercard:senalizacion_debito idx_sen_debito)}
               senalizacion_debito
        set tcompras_7230 = (select n.tcompras
                             from d_g7230 n
                             where n_suc = n.sucursal),
               saldo_7230 = (select n.saldo
                             from d_g7230 n
                             where n_suc = n.sucursal)
        where periodo = vaniomes and
              n_suc = (select m.sucursal 
                       from d_g7230 m
                       where n_suc = m.sucursal);
       commit;

		--18)Generar archivo de crédito		
			let vsql = 'echo "Ciudad|Sucursal|Numero de Tarjetas por Sucursal|Linea de credito Acumulada Mensual|No. Compras Mensual|Saldo de Compras Mensual (Monto)|Giro 5411 No. Compras Mensual|Giro 5411 Saldo de Compras Mensual|Giro 5499 No. Compras Mensual|Giro 5499 Saldo de Compras Mensual|Giro 4812 No. Compras Mensual|Giro 4812 Saldo de Compras Mensual|Giro 5311 No. Compras Mensual|Giro 5311 Saldo de Compras Mensual|Giro 5661 No. Compras Mensual|Giro 5661 Saldo de Compras Mensual|Giro 5533 No. Compras Mensual|Giro 5533 Saldo de Compras Mensual|Giro 5072 No. Compras Mensual|Giro 5072 Saldo de Compras Mensual|Giro 5812 No. Compras Mensual|Giro 5812 Saldo de Compras Mensual|Giro 5541 No. Compras Mensual|Giro 5541 Saldo de Compras Mensual|Giro 5912 No. Compras Mensual|Giro 5912 Saldo de Compras Mensual|Giro 5621 No. Compras Mensual|Giro 5621 Saldo de Compras Mensual|Giro 5947 No. Compras Mensual|Giro 5947 Saldo de Compras Mensual|Giro 5941 No. Compras Mensual|Giro 5941 Saldo de Compras Mensual|Giro 7230 No. Compras Mensual|Giro 7230 Saldo de Compras Mensual|">/resplogifx/rpt_senalizacion_credito'||vaniomes||'.unl';
			system vsql;
			let vsql = '';
			let vsql=  'echo "UNLOAD TO /resplogifx/rpt_senalizacion_credito.unl select ciudad, sucursal, num, linea_mensual, compras, monto, tcompras_5411, saldo_5411, tcompras_5499, saldo_5499, tcompras_4812, saldo_4812, tcompras_5311, saldo_5311, tcompras_5661, saldo_5661, tcompras_5533, saldo_5533, tcompras_5072, saldo_5072, tcompras_5812, saldo_5812, tcompras_5541, saldo_5541, tcompras_5912, saldo_5912, tcompras_5621, saldo_5621, tcompras_5947, saldo_5947, tcompras_5941, saldo_5941, tcompras_7230, saldo_7230 from senalizacion_credito where periodo = ' || vaniomes || ';">/resplogifx/senalizacioncred.sql'; 
			system vsql;
			let vsql = '';
			let vsql= 'dbaccess intercard /resplogifx/senalizacioncred.sql';
			system vsql;
			let vsql ='';
			let vsql ='rm /resplogifx/senalizacioncred.sql';
			system vsql;
			let vsql ='';
			let vsql = "sed 's/|$//g' /resplogifx/rpt_senalizacion_credito.unl >>/resplogifx/rpt_senalizacion_credito"||vaniomes||".unl";
			system vsql;
			let vsql ='rm  /resplogifx/rpt_senalizacion_credito.unl';
			system vsql;
			
        --19)Generar archivo de débito
			let vsql = 'echo "Ciudad|Sucursal|Numero de Tarjetas por Sucursal|Saldo Promedio Mensual|No. Compras Mensual|Saldo de Compras Mensual (Monto)|Giro 5411 No. Compras Mensual|Giro 5411 Saldo de Compras Mensual|Giro 5499 No. Compras Mensual|Giro 5499 Saldo de Compras Mensual|Giro 4812 No. Compras Mensual|Giro 4812 Saldo de Compras Mensual|Giro 5311 No. Compras Mensual|Giro 5311 Saldo de Compras Mensual|Giro 5661 No. Compras Mensual|Giro 5661 Saldo de Compras Mensual|Giro 5533 No. Compras Mensual|Giro 5533 Saldo de Compras Mensual|Giro 5072 No. Compras Mensual|Giro 5072 Saldo de Compras Mensual|Giro 5812 No. Compras Mensual|Giro 5812 Saldo de Compras Mensual|Giro 5541 No. Compras Mensual|Giro 5541 Saldo de Compras Mensual|Giro 5912 No. Compras Mensual|Giro 5912 Saldo de Compras Mensual|Giro 5621 No. Compras Mensual|Giro 5621 Saldo de Compras Mensual|Giro 5947 No. Compras Mensual|Giro 5947 Saldo de Compras Mensual|Giro 5941 No. Compras Mensual|Giro 5941 Saldo de Compras Mensual|Giro 7230 No. Compras Mensual|Giro 7230 Saldo de Compras Mensual|">/resplogifx/rpt_senalizacion_debito'||vaniomes||'.unl';
			system vsql;
			let vsql=  'echo "UNLOAD TO /resplogifx/rpt_senalizacion_debito.unl select ciudad, sucursal, num, promedio_mes, compras, monto, tcompras_5411, saldo_5411, tcompras_5499, saldo_5499, tcompras_4812, saldo_4812, tcompras_5311, saldo_5311, tcompras_5661, saldo_5661, tcompras_5533, saldo_5533, tcompras_5072, saldo_5072, tcompras_5812, saldo_5812, tcompras_5541, saldo_5541, tcompras_5912, saldo_5912, tcompras_5621, saldo_5621, tcompras_5947, saldo_5947, tcompras_5941, saldo_5941, tcompras_7230, saldo_7230 from senalizacion_debito where periodo = ' || vaniomes || ';">/resplogifx/senalizaciondebito.sql'; 
			system vsql;
			let vsql = '';
			let vsql= 'dbaccess intercard /resplogifx/senalizaciondebito.sql';
			system vsql;
			let vsql ='';
			let vsql ='rm /resplogifx/senalizaciondebito.sql';
			system vsql;
			let vsql ='';
			let vsql = "sed 's/|$//g' /resplogifx/rpt_senalizacion_debito.unl >>/resplogifx/rpt_senalizacion_debito"||vaniomes||".unl";
			system vsql;
			let vsql ='rm /resplogifx/rpt_senalizacion_debito.unl';
			system vsql;
	 ------barrido de tablas temporales
	 drop table suc_inf;
	 drop table ntc;
	 drop table linea;
	 drop table movimientos_cred;
         drop table ntd;
	 drop table saldo_prom_mes;
	 drop table movimientos_debito;
         drop table suc_tarj;
	 drop table mov_mes;
	 drop table d_g5411;
	 drop table d_g5499;
	 drop table d_g4812;
	 drop table d_g5311;
	 drop table d_g5661;
	 drop table d_g5533;
	 drop table d_g5072;
	 drop table d_g5812;
	 drop table d_g5541;
	 drop table d_g5912;
	 drop table d_g5621;
	 drop table d_g5947;
	 drop table d_g5941;
	 drop table d_g7230;
	 
	 drop table c_g5411;
	 drop table c_g5499;
	 drop table c_g4812;
	 drop table c_g5311;
	 drop table c_g5661;
	 drop table c_g5533;
	 drop table c_g5072;
	 drop table c_g5812;
	 drop table c_g5541;
	 drop table c_g5912;
	 drop table c_g5621;
	 drop table c_g5947;
	 drop table c_g5941;
	 drop table c_g7230;
	 
	       LET vcodret = '0000';
           LET  p_mensaje  = 'Proceso exitoso';
           return vcodret, p_mensaje;
  else
    LET vcodret = '0001';
    LET  p_mensaje  = 'Mes ya Procesado o No concluido, Favor de Verificar';
     return vcodret, p_mensaje;
end if 
end;
END PROCEDURE;