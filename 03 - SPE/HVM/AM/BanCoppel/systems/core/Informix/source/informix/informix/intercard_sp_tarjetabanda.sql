CREATE PROCEDURE "informix".sp_tarjetabanda(pindica VARCHAR (1))--Parametro "B" indica que es reporte mensual de tarjetas de banda                                                                                

RETURNING varchar(6), varchar(80);
----------Variables-------------------------------
DEFINE  error_info              varchar(80);
DEFINE  isam_err                integer;
DEFINE  vsqlerr                 integer;
DEFINE  iSqlErr                 integer;
DEFINE  vcodret                 varchar(6);
DEFINE  cCodret                 varchar(6);
DEFINE  cVarDataErr             varchar(26);
DEFINE  p_mensaje               varchar(80);
DEFINE  vfecha_hoy              DATE;
DEFINE  vsql                    char(1700);
DEFINE  vindica                 varchar(1);
DEFINE  vcuenta                 VARCHAR(13); 
DEFINE  vsaldopromedio          DECIMAL(19,4);
DEFINE  vperiodo                VARCHAR(6);
DEFINE  vperiodo3               VARCHAR(6);
DEFINE  vano                    VARCHAR(4);
DEFINE  vmes                    VARCHAR(2);
DEFINE  vmedos                  VARCHAR(2);
DEFINE  vmesdos                 VARCHAR(6);
DEFINE  vmesuno                 VARCHAR(6);
DEFINE  vmesinicio              VARCHAR(2);
DEFINE  vfechaexp               VARCHAR(4);
DEFINE  sql_err                 integer;
DEFINE  nrows                   SMALLINT;
DEFINE  vperiodofinal           DATE;
DEFINE  vperiodoini             DATE;
DEFINE  vdia                    VARCHAR(3);
DEFINE  vdia2                   VARCHAR(3);
DEFINE  vnumtarjeta             VARCHAR(16);
DEFINE  vnumtarjeta2            VARCHAR(16);
 
--------------FECHAS-------------------------------------

DEFINE ultimo_dia_mes DATE;
DEFINE primer_dia_mes DATE;
DEFINE ultimo_dia_mes_hora DATETIME YEAR TO FRACTION(5);
DEFINE primer_dia_mes_hora DATETIME YEAR TO FRACTION(5);
DEFINE pperiodofin_hora DATETIME YEAR TO FRACTION(5);
DEFINE pperiodini_hora DATETIME YEAR TO FRACTION(5);
DEFINE FechaAux DATETIME YEAR TO FRACTION(5);
DEFINE vsflagentransaccion 	char(5);
DEFINE vicontadorregistros 	integer;
DEFINE vicontadorregistros2 integer;
         

 --SET DEBUG FILE TO "/informix/c94796696/tarjetabanda.out";
 --TRACE ON;
	
BEGIN
	ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
	SET DEBUG FILE TO "/resplogifx/tarjetabanda.out";
    TRACE ON;
	
	IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
				COMMIT WORK;
				LET vsFlagEnTransaccion = 'F';
			END IF;
	LET vcodret    = SQL_ERR;
	LET p_mensaje  = error_info;
	
    RETURN 	vcodret,p_mensaje;
		
   END EXCEPTION;
   
   
       /* SET ISOLATION TO DIRTY READ ;
        IF EXISTS ( SELECT dbsname, tabname FROM  sysmaster:SysTabNames  WHERE tabname = 'td_reporteuno' AND dbsname= 'intercard') THEN
            DROP TABLE intercard:td_reporteuno;
        END IF;*/
		
			/*SET ISOLATION TO DIRTY READ ;
        IF EXISTS ( SELECT dbsname, tabname FROM  sysmaster:SysTabNames  WHERE tabname = 'td_reportedostres' AND dbsname= 'intercard') THEN
            DROP TABLE intercard:td_reportedostres;
        END IF;*/
		
		SET ISOLATION TO DIRTY READ ;
        IF EXISTS ( SELECT dbsname, tabname FROM  sysmaster:SysTabNames  WHERE tabname = 'td_ventanilla' AND dbsname= 'intercard') THEN
            DROP TABLE intercard:td_ventanilla;
        END IF;
		
		/*SET ISOLATION TO DIRTY READ ;
        IF EXISTS ( SELECT dbsname, tabname FROM  sysmaster:SysTabNames  WHERE tabname = 'td_ventanillareporte' AND dbsname= 'intercard') THEN
            DROP TABLE intercard:td_ventanillareporte;
        END IF;*/
		
			/*SET ISOLATION TO DIRTY READ ;
        IF EXISTS ( SELECT dbsname, tabname FROM  sysmaster:SysTabNames  WHERE tabname = 'ventanillareporte' AND dbsname= 'intercard') THEN
            DROP TABLE intercard:ventanillareporte;
        END IF;*/
		
			/*SET ISOLATION TO DIRTY READ ;
        IF EXISTS ( SELECT dbsname, tabname FROM  sysmaster:SysTabNames  WHERE tabname = 'td_informacion' AND dbsname= 'intercard') THEN
            DROP TABLE intercard:td_informacion;
        END IF;*/
		

-----------***********cuerpo**************-------------------  


SET ISOLATION TO DIRTY READ;
SELECT fecha_hoy INTO vfecha_hoy FROM  bdinteg:si_fechas;
--LET vfecha_hoy = '06/05/2014';
LET vindica = pindica;
LET vano = SUBSTR(vfecha_hoy,7,10);
LET vmes = SUBSTR(vfecha_hoy,1,2);
LET vmes = vmes-01;
LET vmes =0||vmes;
LET vmesuno =  vano||vmes;
LET vmedos = SUBSTR(vfecha_hoy,1,2);
LET vmesdos = vmedos-03;
LET vmesdos =0||vmesdos;
LET vmesdos =  vano||vmesdos;



	--let 	vsflagentransaccion = 'V';
	--let		vicontadorregistros = 0;
	--let     vicontadorregistros2 = 0;
	---let     vsaldopromedio= 0;
	--let 	vsflagentransaccion = 'F';
	



-----operaciones de fechas
     LET ultimo_dia_mes = extend(extend(vfecha_hoy - 0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 0 units DAY;
     LET ultimo_dia_mes_hora = extend(extend(vfecha_hoy - 0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 0 units DAY;
     LET ultimo_dia_mes_hora = SUBSTRING(ultimo_dia_mes_hora FROM  1 FOR 10) || ' 00:00:00';
     --OBTIENE EL PRIMER DIA DEL MES DE CORTE
     LET primer_dia_mes = extend(extend(vfecha_hoy - 3 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);
     LET primer_dia_mes_hora = extend(extend(vfecha_hoy - 3 units MONTH ,YEAR TO MONTH)||"-01",YEAR TO DAY);
     LET primer_dia_mes_hora= SUBSTRING(primer_dia_mes_hora FROM  1 FOR 10) || ' 00:00:00';
-------------------------------  CÁLCULO DE FECHAS----------------------------------------------------------------------------
   
--/////////////////////////////////  INICIO DE EJECUCIÓN DE OPCIÓN MENSUAL ////////////////////////////////////////////////--
		IF ((vindica = 'L' OR vindica = 'Y' OR vindica = 'V') AND vindica <>'')THEN
			ELSE
				LET vcodret = '0002';
				LET  p_mensaje  = 'El paremetro no es el correcto';
				 return vcodret, p_mensaje;
		END IF;	
 
    IF  ( vindica = 'L' AND vindica <> '') THEN
	
	    SET ISOLATION TO DIRTY READ;
		SELECT fecha_hoy INTO vfecha_hoy FROM  bdinteg:si_fechas;
		--LET vfecha_hoy = '05/03/2013';
		LET vindica = pindica;
		LET vano = SUBSTR(vfecha_hoy,9,10);
		LET vmes = SUBSTR(vfecha_hoy,1,2);
		LET vfechaexp =  vano||vmes;
		--1309
       
	   	LET vsFlagEnTransaccion = 'F';
	    LET viContadorRegistros = 0;
	    LET viContadorRegistros2 = 0;
		--Activa el foreach para realizar commit cada 5000 registros.
	  SET LOCK MODE TO WAIT 3;
	  SET ISOLATION TO DIRTY READ;
	  --FOREACH WITH HOLD 
	  FOREACH CUSOR1 WITH HOLD FOR
		--SET ISOLATION TO DIRTY READ;
		--Select * from intercard:bines
		SELECT tar.numtarjeta 
		INTO   vnumtarjeta
		FROM   intercard:td_bandacontrol tdc ,intercard:tarjeta tar 
		where  tdc.numtarjeta =tar.numtarjeta
		--AND    tar.codstatustarjeta in ('CAN','DES','EXT','ROB','FAL','DAN')
		and    tdc.fechaexp <=vfechaexp
		
		/*SELECT tar.numtarjeta 
		INTO   vnumtarjeta2 
		FROM   intercard:td_bandacontrol tdc ,intercard:tarjeta tar 
		where  tdc.numtarjeta =tar.numtarjeta
		AND    tar.codstatustarjeta in ('CAN','DES','EXT','ROB','FAL','DAN');
		--and    tdc.fechaexp <=vfechaexp*/
		
	--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
	    IF (vsFlagEnTransaccion = 'F') THEN
			 BEGIN WORK;
			 LET vsFlagEnTransaccion = 'V';
		END IF;
		

		/*delete FROM  intercard:td_bandacontrol
		where numtarjeta in ( 
		SELECT tar.numtarjeta 
		FROM   intercard:td_bandacontrol tdc ,intercard:tarjeta tar 
		where  tdc.numtarjeta =tar.numtarjeta
		AND    tar.codstatustarjeta in ('CAN','DES','EXT','ROB','FAL','DAN'));*/
		
		delete FROM  intercard:td_bandacontrol
		where numtarjeta = vnumtarjeta;
	
		
		--SET ISOLATION TO DIRTY READ;
		/*delete FROM  intercard:td_bandacontrol
		where numtarjeta =vnumtarjeta2;*/
		
		LET viContadorRegistros = viContadorRegistros + 1;
		LET viContadorRegistros2 = viContadorRegistros2 + 1;
		
		--SE APLICA update statistics medium A LA TABLA.
		IF (viContadorRegistros = 30000) THEN --VERIFICA, SI EL BLOQUE 2 ALCANZO LA CONDICIÓN PARA REALIZAR EL update statistics
			UPDATE statistics medium for table intercard:td_bandacontrol;
			LET viContadorRegistros2 = 0;
			CONTINUE FOREACH;
		END IF;
		
			--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
		IF (viContadorRegistros = 5000) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
			LET viContadorRegistros = 0;
			CONTINUE FOREACH;
		END IF;
		
		END FOREACH ;
		
		--UPDATE statistics medium for table intercard:td_bandacontrol;   
	   -- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
		END IF;
		
		 LET vcodret = '00000';
		 LET  p_mensaje  = 'Termino Limpieza de Fechas de Exp.(L)';
		return vcodret, p_mensaje;
		
	
    END IF;
	
	IF  ( vindica = 'Y' AND vindica <> '') THEN
	
	    LET vsFlagEnTransaccion  = 'F';
        LET viContadorRegistros  =  0;
        LET viContadorRegistros2 =  0;
	
	
		SET ISOLATION TO DIRTY READ ;
        IF EXISTS ( SELECT dbsname, tabname FROM  sysmaster:SysTabNames  WHERE tabname = 'td_tablaposatm' AND dbsname= 'intercard') THEN
          TRUNCATE TABLE intercard:td_tablaposatm;
        END IF;
		
	    SET ISOLATION TO DIRTY READ ;
        IF EXISTS ( SELECT dbsname, tabname FROM  sysmaster:SysTabNames  WHERE tabname = 'posatm' AND dbsname= 'intercard') THEN
          DROP TABLE intercard:posatm;
        END IF;
			
	--Genera segundo reporte de saldos menores a 10,000 de POS y ATM			
	/*	CREATE TABLE informix.td_tablaposatm( 
		numtarjeta                VARCHAR(16),
		codigoiso                 VARCHAR(2),
		prodind                   VARCHAR(2),
		monto                     DECIMAL(19,4),
		numtrax                   integer,
		descripcion               char(1)
		)EXTENT SIZE 320 NEXT SIZE 320 LOCK MODE ROW;
		
		CREATE INDEX "informix".idx_numtarjeta ON "informix".td_tablaposatm(numtarjeta);
		CREATE INDEX "informix".idx_codigoiso ON "informix".td_tablaposatm(codigoiso);
		CREATE INDEX "informix".idx_prodind ON "informix".td_tablaposatm(prodind);
		CREATE INDEX "informix".idx_descripcion ON "informix".td_tablaposatm(descripcion);
		
		UPDATE statistics medium for table intercard:td_tablaposatm;  
		*/
		
		
        /*CREATE TABLE informix.td_reportedostres( 
        numtarjeta                VARCHAR(16),
		numcliente                VARCHAR(13),
		nombre1                   VARCHAR(26),
		nombre2                   VARCHAR(26),
		apell_paterno             VARCHAR(26),
		apell_materno             VARCHAR(26),
        celular                   CHAR(13),
		casa                      CHAR(13),
        oficina                   CHAR(13),
        correo_elec               VARCHAR(100),
		sucursal                  VARCHAR(5),
		prodind                   VARCHAR(2),
        cuenta                    VARCHAR(13),
		promedio_saldo   		  DECIMAL(19,4),
		numtrax                   integer,
		monto                     DECIMAL(19,4)
		)EXTENT SIZE 320 NEXT SIZE 320 LOCK MODE ROW;
		CREATE INDEX "informix".idx_numcliente2 ON "informix".td_reportedostres(numcliente);*/
			
			
	  	SET ISOLATION TO DIRTY READ;
		--INSERT INTO td_tablaposatm(numtarjeta,codigoiso,prodind,monto,numtrax)  
		SELECT movh.numtarjeta as numtarjeta,codigoiso as codigoiso ,prodind,sum (monto) as monto,count(*) AS numtrax,'X' as descripcion
		FROM   intercard:movimientohistorico movh,intercard:td_bandacontrol td
        WHERE  fechahorainauth between primer_dia_mes_hora AND ultimo_dia_mes_hora
		and    codstatustarjeta  in ('ACT','BLT','BLO')
        and    movh.numtarjeta = td.numtarjeta
		--and    td.numtarjeta not in (select numtarjeta from intercard:td_bandacontrol where maycta10000 ='X')
		and    movh.codigoiso = '00'  
        and    movh.formato = '0200' 
        and    movh.movreversado = 'F' 
        and    prodind in ('01','02')
		and    monto > 0	
		--and    td.promedio_saldo < 10000   
        GROUP BY 1,2,3

        UNION ALL

		SELECT  mov.numtarjeta as numtarjeta,codigoiso as codigoiso ,prodind,sum (monto) as monto,count(*) AS numtrax,'X' as descripcion
		FROM    intercard:movimiento mov, intercard:td_bandacontrol td
        WHERE   fechahorainauth between primer_dia_mes_hora AND ultimo_dia_mes_hora
		and     codstatustarjeta  in ('ACT','BLT','BLO')
        and     mov.numtarjeta = td.numtarjeta
        --and     td.numtarjeta not in (select numtarjeta from intercard:td_bandacontrol where maycta10000 ='X')
		and     mov.codigoiso = '00'  
        and     mov.formato = '0200'
        and     mov.movreversado = 'F'  		
		and     prodind in ('01','02')
		--and     td.promedio_saldo < 10000 
        and monto > 0		
        GROUP BY 1,2,3
		into temp posatm WITH NO LOG;
         CREATE INDEX idxposatm ON posatm(numtarjeta) USING BTREE;
         UPDATE STATISTICS HIGH FOR TABLE posatm;
		
		
	 
		 
		SET ISOLATION TO DIRTY READ;
	    INSERT INTO td_tablaposatm(numtarjeta,codigoiso,prodind,monto,numtrax,descripcion)
        SELECT * FROM   intercard:posatm
		WHERE numtrax >=3
		and monto>0;

		/*begin;
		UPDATE intercard:td_tablaposatm
		set descripcion = 'P'
			where prodind = '02'
			and codigoiso = '00'
			and numtrax >= 3;
	    commit;
		
	    begin;
		UPDATE intercard:td_tablaposatm
		set descripcion = 'A'
			where prodind = '01'
			and codigoiso = '00'
			and numtrax >= 3;
	    commit;*/
												
																	  
	---Genera Reporte POS -------------
						let vsql = ''; 	 
                        let vsql ='rm -f /resplogifx/BandaPOS'||vmesuno||'.txt.gz';	
	                    system vsql;						
						let vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/BandaPOS'||vmesuno||'.txt '||
                                       'SELECT td.numtarjeta, numcliente,trim(cte.nombre1),trim(cte.nombre2),trim(cte.apell_paterno),trim(cte.apell_materno),si2.telefono as celular, si.telefono as casa, si3.telefono as oficina,sic.correo_elec as correo_elec, chq.sucursal as sucursal,txn.prodind as prodind,td.cuenta as cuenta,td.fechaexp,chq.sdo_actual as saldo,sie.nombre as estado,txn.numtrax as numtrax, txn.monto as monto '||
									   --'SELECT td.numtarjeta, numcliente,trim(cte.nombre1),trim(cte.nombre2),trim(cte.apell_paterno),trim(cte.apell_materno),si2.telefono as celular, si.telefono as casa, si3.telefono as oficina,sic.correo_elec as correo_elec, chq.sucursal as sucursal,txn.prodind as prodind,td.cuenta as cuenta,td.fechaexp,chq.sdo_actual as saldo,txn.numtrax as numtrax, txn.monto as monto '||
									   'FROM  intercard:td_bandacontrol td '||
									   'LEFT OUTER JOIN bdinteg:si_telefonos_actual si '||
						               'ON  td.numcliente =si.numcte and si.tipo_tel = ''"'||'1'||'"'''||
							           'LEFT OUTER JOIN bdinteg:si_telefonos_actual si2 '||
								       'ON  td.numcliente =si2.numcte and si2.tipo_tel = ''"'||'2'||'"'' '||
									   'LEFT OUTER JOIN bdinteg:si_telefonos_actual si3 '||
									   'ON  td.numcliente =si3.numcte and si3.tipo_tel = ''"'||'3'||'"'' '|| 
									   'LEFT OUTER JOIN bdinteg:si_correos sic '||
									   'ON  td.numcliente =sic.numcte and sic.status_correo =''"'||'A'||'"'''||
									   'LEFT OUTER JOIN bdinteg:si_cliente cte '||
                   			           'ON  td.numcliente =cte.numcte '||
									   'LEFT OUTER JOIN bdicheq:sc_maechq chq  '||
									   'ON  td.cuenta = chq.cuenta '||
									   'LEFT OUTER JOIN intercard:td_tablaposatm txn '||
									   'ON  txn.numtarjeta = td.numtarjeta '||
									   'LEFT OUTER JOIN bdinteg:si_direcciones_actual sid '||
									   'ON  td.numcliente =sid.numcte  and sid.tipo_dir = ''"'||'1'||'"'''||
									   'LEFT OUTER JOIN bdinteg:si_estados sie '||
									   'ON  sid.estado =sie.estado '||
									  -- 'WHERE txn.descripcion =''"'||'P'||'"'' and '||
									   'WHERE txn.prodind = ''"'||'02'||'"'' and '||
									   'txn.numtrax >= 3;" >/resplogifx/reban.sql';
									   
									   
						/*let vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/BandaPOS'||vmesuno||'.txt '||
                                       'SELECT td.numtarjeta, numcliente,trim(cte.nombre1),trim(cte.nombre2),trim(cte.apell_paterno),trim(cte.apell_materno),si2.telefono as celular, si.telefono as casa, si3.telefono as oficina,sic.correo_elec as correo_elec, chq.sucursal as sucursal,txn.prodind as prodind,td.cuenta as cuenta, txn.numtrax as numtrax, txn.monto as monto '||
									   'FROM  intercard:td_bandacontrol td '||
									   'LEFT OUTER JOIN bdinteg:si_telefonos_actual si '||
						               'ON  td.numcliente =si.numcte and si.tipo_tel = ''"'||'1'||'"'''||
							           'LEFT OUTER JOIN bdinteg:si_telefonos_actual si2 '||
								       'ON  td.numcliente =si2.numcte and si2.tipo_tel = ''"'||'2'||'"'' '||
									   'LEFT OUTER JOIN bdinteg:si_telefonos_actual si3 '||
									   'ON  td.numcliente =si3.numcte and si3.tipo_tel = ''"'||'3'||'"'' '|| 
									   'LEFT OUTER JOIN bdinteg:si_correos sic '||
									   'ON  td.numcliente =sic.numcte and sic.status_correo =''"'||'A'||'"'''||
									   'LEFT OUTER JOIN bdinteg:si_cliente cte '||
                   			           'ON  td.numcliente =cte.numcte '||
									   'LEFT OUTER JOIN bdicheq:sc_maechq chq  '||
									   'ON  td.cuenta = chq.cuenta '||
									   'LEFT OUTER JOIN td_tablaposatm txn '||
									   'ON  txn.numtarjeta = td.numtarjeta '||
									   'WHERE txn.descripcion =''"'||'P'||'"'' and '||
									   'txn.prodind = ''"'||'02'||'"'' and '||
									   'txn.numtrax >= 3;" >/resplogifx/reban.sql';*/
						system vsql;
						let vsql = '';
						let vsql = '';
						system vsql;
						let vsql= "dbaccess intercard /resplogifx/reban.sql";
						system vsql;
						let vsql = '';
						let vsql ='rm /resplogifx/reban.sql';
						system vsql;
						let vsql = '';
						let vsql ='gzip -9 /resplogifx/BandaPOS'||vmesuno||'.txt';
						system vsql;																		  
            let vsql = ''; 	  

	---Genera Reporte ATM -------------	
	  let vsql = ''; 	 
	  let vsql ='rm -f /resplogifx/BandaATM'||vmesuno||'.txt.gz';
	  	system vsql;
                        let vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/BandaATM'||vmesuno||'.txt '||
                                       'SELECT td.numtarjeta, numcliente, trim(cte.nombre1), trim(cte.nombre2), trim(cte.apell_paterno), trim(cte.apell_materno),si2.telefono as celular, si.telefono as casa, si3.telefono as oficina,sic.correo_elec as correo_elec, chq.sucursal as sucursal,txn.prodind as prodind,td.cuenta as cuenta,td.fechaexp,chq.sdo_actual as saldo,sie.nombre as estado,txn.numtrax as numtrax, txn.monto as monto '||
									   'FROM  intercard:td_bandacontrol td '||
									   'LEFT OUTER JOIN bdinteg:si_telefonos_actual si '||
						               'ON  td.numcliente =si.numcte and si.tipo_tel = ''"'||'1'||'"'''||
							           'LEFT OUTER JOIN bdinteg:si_telefonos_actual si2 '||
								       'ON  td.numcliente =si2.numcte and si2.tipo_tel = ''"'||'2'||'"'' '||
									   'LEFT OUTER JOIN bdinteg:si_telefonos_actual si3 '||
									   'ON  td.numcliente =si3.numcte and si3.tipo_tel = ''"'||'3'||'"'' '|| 
									   'LEFT OUTER JOIN bdinteg:si_correos sic '||
									   'ON  td.numcliente =sic.numcte and sic.status_correo =''"'||'A'||'"'''||
									   'LEFT OUTER JOIN bdinteg:si_cliente cte '||
                   			           'ON  td.numcliente =cte.numcte '||
									   'LEFT OUTER JOIN bdicheq:sc_maechq chq  '||
									   'ON  td.cuenta = chq.cuenta '||
									   'LEFT OUTER JOIN intercard:td_tablaposatm txn '||
									   'ON  txn.numtarjeta = td.numtarjeta '||
									   'LEFT OUTER JOIN bdinteg:si_direcciones_actual sid '||
									   'ON  td.numcliente =sid.numcte  and tipo_dir = ''"'||'1'||'"'' '|| 
									   'LEFT OUTER JOIN bdinteg:si_estados sie '||
									   'ON  sid.estado =sie.estado '||
									 --  'WHERE txn.descripcion =''"'||'A'||'"'' and '||
									   'WHERE txn.prodind = ''"'||'01'||'"'' and '||
									   'txn.numtrax >= 3;" >/resplogifx/reban.sql';
									   
						system vsql;
						let vsql = '';
						let vsql = '';
						system vsql;
						let vsql= "dbaccess intercard /resplogifx/reban.sql";
						system vsql;
						let vsql = '';
						let vsql ='rm /resplogifx/reban.sql';
						system vsql;
						let vsql = '';
						let vsql ='gzip -9 /resplogifx/BandaATM'||vmesuno||'.txt';
						system vsql;																		  
                        let vsql = ''; 
			
			--DROP TABLE  td_tablaposatm;
			--DROP TABLE  pasopos;
			--DROP TABLE  td_reportedostres;	
             DROP TABLE  posatm;	
            --DROP TABLE  pasoatm;
			 LET vcodret = '00000';
		     LET  p_mensaje  = 'Termino proceso de POS y ATM(Y)';
		     return vcodret, p_mensaje;
    END IF;
----------------------------------------------------------------	

	
		IF  ( vindica = 'V' AND vindica <> '') THEN  
		
		     LET vsFlagEnTransaccion  = 'F';
             LET viContadorRegistros  =  0;
             LET viContadorRegistros2 =  0;
		
		set isolation to dirty read;
						Select (extend(fecha_hoy, year to month) -2 units month)::date - 1 into vperiodofinal
						from bdinteg:si_fechas;
						LET vperiodofinal=vperiodofinal;
						LET vano = SUBSTR(vperiodofinal,7,10);
						LET vmes = SUBSTR(vperiodofinal,1,2);
						LET vdia = SUBSTR(vperiodofinal,3,4);
						LET vdia2 = SUBSTR(vdia,2,5);
						LET vperiodofinal =  vmes||vdia2||vano;
						LET vperiodofinal=vperiodofinal;
						LET vmesdos=vano||vmes;
						
						LET primer_dia_mes = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);
						let primer_dia_mes= primer_dia_mes;
						LET vano = SUBSTR(primer_dia_mes,7,10);
						LET vmes = SUBSTR(primer_dia_mes,1,2);
						LET vdia = SUBSTR(primer_dia_mes,3,4);
						LET vdia2 = SUBSTR(vdia,2,5);
						LET vperiodoini =  vmes||vdia2||vano;
						LET vperiodoini= vperiodoini;
						LET vmesuno=vano||vmes;
						
		
		
		 	--Genera cuarto reporte de saldos menores a 10,000 de Ventanilla	
		CREATE TABLE informix.td_ventanilla( 
		numtarjeta             VARCHAR(16),
		sucursal               VARCHAR(5),
		aniomes                VARCHAR(6),
		cuenta                 VARCHAR(13),
		monto_tot              DECIMAL(19,4),
		num_tarjeta            VARCHAR(16),
		transventa             integer,
		descripcion            char(1)
		)EXTENT SIZE 320 NEXT SIZE 320 LOCK MODE ROW;
		
		CREATE INDEX "informix".idx_numtarjeta2 ON "informix".td_ventanilla(numtarjeta);
		CREATE INDEX "informix".idx_cuenta ON "informix".td_ventanilla(cuenta);	
		CREATE INDEX "informix".idxtransventa ON "informix".td_ventanilla(transventa);
		
	    UPDATE statistics medium for table intercard:td_ventanilla;   
		
	
		LET vmesdos = vmesdos;
		LET vmesuno = vmesuno;
		
	   
			SET ISOLATION TO DIRTY READ;
			--INSERT INTO td_ventanilla(numtarjeta,sucursal,aniomes,cuenta,monto_tot,num_tarjeta,transventa,descripcion)
			SELECT {+INDEX(intercard:td_bandacontrol idx_bandacontrol3)} 
			       tdb.numtarjeta as numtarjeta, sucursal as sucursal,aniomes as aniomes,scm.cuenta as cuenta,sum (monto_tot) as monto_tot ,num_tarjeta as num_tarjeta ,count (*) as transventa,'V' as descripcion
			FROM   intercard:td_bandacontrol tdb,bdicheq:sc_movhis scm
			where  tdb.cuenta = scm.cuenta
			and    transacc = '0223'
			and    tdb.numtarjeta = scm.num_tarjeta
			and    tdb.numtarjeta not in (select numtarjeta from intercard:td_tablaposatm)
			--and    promedio_saldo <= 10000
			and    aniomes between vmesdos  and vmesuno
			GROUP BY 1,2,3,4,6
			into temp ventanilla WITH NO LOG;
			
			
		SET ISOLATION TO DIRTY READ;
	    INSERT INTO td_ventanilla(numtarjeta,sucursal,aniomes,cuenta,monto_tot,num_tarjeta,transventa,descripcion)
        SELECT * FROM  intercard:ventanilla
		WHERE transventa >=3;
					
		let vsql = ''; 	 												
		let vsql ='rm -f /resplogifx/BandaVentanilla'||vmesuno||'.txt.gz';
	    system vsql;							   									   
		let vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/BandaVentanilla'||vmesuno||'.txt '||
                                       'SELECT td.numtarjeta,numcliente,trim(cte.nombre1)as nombre1,trim(cte.nombre2) as nombre2,trim(cte.apell_paterno) as apell_paterno,trim(cte.apell_materno) as apell_materno,si2.telefono as celular,si.telefono as casa,si3.telefono as oficina,sic.correo_elec as correo_elec,chq.sucursal as sucursal,td.cuenta as cuenta,td.fechaexp,chq.sdo_actual,sie.nombre,txn.transventa as transventa,txn.monto_tot as monto_tot '||
									   'FROM  intercard:td_bandacontrol td '||
									   'LEFT OUTER JOIN bdinteg:si_telefonos_actual si '||
						               'ON  td.numcliente =si.numcte and si.tipo_tel = ''"'||'1'||'"'''||
							           'LEFT OUTER JOIN bdinteg:si_telefonos_actual si2 '||
								       'ON  td.numcliente =si2.numcte and si2.tipo_tel = ''"'||'2'||'"'' '||
									   'LEFT OUTER JOIN bdinteg:si_telefonos_actual si3 '||
									   'ON  td.numcliente =si3.numcte and si3.tipo_tel = ''"'||'3'||'"'' '|| 
									   'LEFT OUTER JOIN bdinteg:si_correos sic '||
									   'ON  td.numcliente =sic.numcte and sic.status_correo =''"'||'A'||'"'''||
									   'LEFT OUTER JOIN bdinteg:si_cliente cte '||
                   			           'ON  td.numcliente =cte.numcte '||
									   'LEFT OUTER JOIN bdicheq:sc_maechq chq  '||
									   'ON  td.cuenta = chq.cuenta  '||
									   'LEFT OUTER JOIN intercard:td_ventanilla txn  '||
									   'ON  txn.numtarjeta = td.numtarjeta  '||
									   'LEFT OUTER JOIN bdinteg:si_direcciones_actual sid '||
									   'ON  td.numcliente =sid.numcte  and tipo_dir = ''"'||'1'||'"'' '|| 
									   'LEFT OUTER JOIN bdinteg:si_estados sie '||
									   'ON  sid.estado =sie.estado '||
									   'WHERE txn.descripcion =''"'||'V'||'"'' and '||
									   'txn.transventa >=3;">/resplogifx/rebanventanilla.sql';
									   
						system vsql;
						let vsql = '';
						let vsql = '';
						system vsql;
						let vsql= "dbaccess intercard /resplogifx/rebanventanilla.sql";
						system vsql;
						let vsql = '';
						let vsql ='rm /resplogifx/rebanventanilla.sql';
						system vsql;
						let vsql = '';
						let vsql ='gzip -9 /resplogifx/BandaVentanilla'||vmesuno||'.txt';
						system vsql;																		  
                        let vsql = ''; 
								          	
            --DROP TABLE ventanillareporte;		   
            --DROP TABLE td_ventanillareporte;
            --DROP TABLE pasoventa;
			DROP TABLE td_ventanilla;
			TRUNCATE TABLE  td_tablaposatm;
			DROP TABLE ventanilla;
			--DROP TABLE td_informacion;
			 LET vcodret = '00000';
		     LET  p_mensaje  = 'Termino proceso de Ventanilla(V)';
		     return vcodret, p_mensaje;
			END IF;
	
  
-- END IF;		
END;
end procedure;