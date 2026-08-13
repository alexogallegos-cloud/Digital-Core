CREATE PROCEDURE "informix".sp_txrechazo_pba(pindica VARCHAR (1),--Parametro que indica si "M" es mensual o "P" es a petición."Q" Reporte Qiubo
                                         pcodigoiso VARCHAR(2), --Parametro si es Código ISO de rechazo cuando es por petición
										 pbin VARCHAR(6), --Parametro si el BIN es de débito o crédito	
                                         pprodind VARCHAR(2),-- Parametro que Indica si es "01" es ATM y "02" es POS
										 pesnacional VARCHAR(1),--Parametro que indica si es "V" Nacional o "F" Internacional 
										 pmetodocaptura VARCHAR(2),--Parametro que indica si es Digitada (01), Chip (05), FallBack (80), eCommerce (81, sólo MC), Banda (90), ContaccLess (91), etc.
										 pperiodo VARCHAR(6)) ---Parametro de periodo de extracción de información                                                                                      

RETURNING varchar(6), varchar(80);
----------Variables-------------------------------
DEFINE  error_info              varchar(80);
DEFINE  isam_err                integer;
DEFINE  vsqlerr                 integer;
DEFINE  vcodret                 varchar(6);
DEFINE  p_mensaje               varchar(80);
DEFINE  vletra                  varchar(1);
DEFINE  vaniomes                char(6);
DEFINE  vaniomes2               char(6);
DEFINE  vfecha_hoy              DATE;
DEFINE  vfechahorainauth        DATE;
DEFINE  vsql                    char(1150);
DEFINE  vcodigoiso              varchar(2);
DEFINE  vindica                 varchar(1);
DEFINE  vbin                    VARCHAR(6); --Bin de débito
DEFINE  vbin2                   VARCHAR(6); --Bin de crédito
DEFINE  vbin3                   VARCHAR(9); --Bin de crédito
DEFINE  vprodind                VARCHAR(2); --Método de captura
DEFINE  vesnacional             varchar(1); --Indica si es Nac ó Int.
--	2015.06.30	FRG	-	Se agrega el parámetro de entrada 'Método de Captura' para los reportes Tipo 'P'.
DEFINE	vmetodocaptura			VARCHAR(2);
DEFINE  vnprodind               VARCHAR(2);
DEFINE  vnesnacional            VARCHAR(1);
DEFINE  viprodind               VARCHAR(2);
DEFINE  viesnacional            VARCHAR(1);
DEFINE  vperiodini              DATE;
DEFINE  vperiodofin             DATE;
DEFINE  vperiodo                VARCHAR(6);
DEFINE  vperiodo3               VARCHAR(6);
DEFINE  vano                    VARCHAR(4);
DEFINE  vmes                    VARCHAR(2);
DEFINE  vdia                    VARCHAR(2);
DEFINE  dias                    integer;
DEFINE  nrows                   SMALLINT;
DEFINE  vcreditodebito          VARCHAR(1); --Indica si es crédito o débito.
 
---------------------------------------------------

DEFINE ultimo_dia_mes DATE;
DEFINE primer_dia_mes DATE;
DEFINE ultimo_dia_mes_hora DATETIME YEAR TO FRACTION(5);
DEFINE primer_dia_mes_hora DATETIME YEAR TO FRACTION(5);
DEFINE pperiodofin_hora DATETIME YEAR TO FRACTION(5);
DEFINE pperiodini_hora DATETIME YEAR TO FRACTION(5);
DEFINE FechaAux DATETIME YEAR TO FRACTION(5);
         
  
--		SET DEBUG FILE TO "/informix/frg/Rpts_Productos/sp_txrechazo_frg.out";
--		TRACE ON;

  begin
 
 
 ------------- control de errores------
    ON EXCEPTION SET vsqlerr,isam_err, error_info
            IF vsqlerr <> 0 AND vsqlerr <> -958  then
                let vcodret = vsqlerr;
                let p_mensaje = error_info;
                  RETURN vcodret, p_mensaje;
            END IF;
    END EXCEPTION;


	ON EXCEPTION SET vsqlerr,isam_err, error_info
            IF vsqlerr = -958  then	
			    if error_info ='informix.pasodebito' then
				     DROP TABLE pasodebito;
				  end if
                if error_info ='informix.pasodebitodos' then
				     DROP TABLE pasodebitodos;
				  end if
                if error_info ='informix.pasocredito' then
				     DROP TABLE pasocredito;
				  end if
                if error_info ='informix.pasocreditodos' then
				     DROP TABLE pasocreditodos;
				  end if
                if error_info ='informix.tx_debito' then
				     DROP TABLE tx_debito;
				  end if
			    if error_info ='informix.tx_credito' then
				     DROP TABLE tx_credito;
				  end if
                if error_info ='informix.tx_credito_debito' then
				     DROP TABLE tx_credito_debito;
				  end if
                if error_info ='informix.pasodatos' then
				     DROP TABLE pasodatos;
				  end if
                if error_info ='informix.paso' then
				     DROP TABLE paso;
				  end if				  
		  				   
		    END IF;    
    END EXCEPTION WITH RESUME; 

-----------***********cuerpo**************-------------------  
SET ISOLATION to dirty read;
SELECT fecha_hoy INTO vfecha_hoy FROM bdinteg:si_fechas;
--LET vfecha_hoy = '05/03/2013';

SET ISOLATION to dirty read;
SELECT MIN (fechahorainauth) INTO vfechahorainauth FROM intercard:movimientohistorico;
LET vindica = pindica;
LET vcodigoiso = pcodigoiso;
LET vbin = pbin; 
LET vprodind = pprodind;
LET vesnacional  = pesnacional;
--	2015.06.30	FRG	-	Se agrega el parámetro de entrada 'Método de Captura' para los reportes Tipo 'P'.
LET	vmetodocaptura	= pmetodocaptura;
LET vperiodo = pperiodo;
LET vano = SUBSTR(vperiodo,0,4);
LET vmes = SUBSTR(vperiodo,5,6);
LET vdia = '01';
LET vperiodini =  vmes||'/'||vdia||'/'||vano;LET vperiodofin = vmes||'/'||vdia||'/'||vano;LET vfechahorainauth = SUBSTR(vfechahorainauth,0,10);

---Modificación para ejecutar opción de reporte de tarjetas de banda ---
IF ((vindica = 'L' OR vindica = 'Y' OR vindica = 'V') AND vindica <>'')THEN
 
      EXECUTE PROCEDURE intercard:sp_tarjetabanda(vindica) INTO vcodret,p_mensaje;
	  
	    return  vcodret, p_mensaje;	 
		
ELSE

-----operaciones de fechas
     LET ultimo_dia_mes = extend(extend(vfecha_hoy - 0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 0 units DAY;
     LET ultimo_dia_mes_hora = extend(extend(vfecha_hoy - 0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 0 units DAY;
     LET ultimo_dia_mes_hora = SUBSTRING(ultimo_dia_mes_hora FROM 1 FOR 10) || ' 00:00:00';
     --OBTIENE EL PRIMER DIA DEL MES DE CORTE
     LET primer_dia_mes = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);
     LET primer_dia_mes_hora = extend(extend(vfecha_hoy - 1 units MONTH ,YEAR TO MONTH)||"-01",YEAR TO DAY);
     LET primer_dia_mes_hora= SUBSTRING(primer_dia_mes_hora FROM 1 FOR 10) || ' 00:00:00';
-------------------------------  CÁLCULO DE FECHAS-----------------------------------------------------------------------------
 -----operaciones de fechas
     --LET ultimo_dia_mes = extend(extend(vfecha_hoy - 0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 0 units DAY;
     LET pperiodofin_hora = extend(extend(vperiodofin + 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 0 units DAY;
     LET pperiodofin_hora = SUBSTRING(pperiodofin_hora FROM 1 FOR 10) || ' 23:59:59';
     --OBTIENE EL PRIMER DIA DEL MES DE CORTE
      --LET pperiodini = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);
        LET pperiodini_hora = extend(extend(vperiodini - 0 units MONTH ,YEAR TO MONTH)||"-01",YEAR TO DAY);
        LET pperiodini_hora= SUBSTRING(pperiodini_hora FROM 1 FOR 10) || ' 00:00:00';
	 --LET pperiodini = '04/01/2013';
	 --let pperiodini_hora = 2013-03-01 00:00:00 */
	 
--OBTIENE LA FECHA MINIMA DE INTERCARD:MOVIMIENTO    
    set ISOLATION to dirty read;
	SELECT fecha_hoy INTO vfecha_hoy FROM bdinteg:si_fechAS;
	 SELECT {+INDEX(intercard:movimiento idx_fechahorainauth)} MIN(FechaHoraInAuth)
      INTO FechaAux FROM Intercard:Movimiento;
--OBTIENE EL AÑO Y MES DE LA FECHA	  
     let vaniomes =  year(ultimo_dia_mes) || LPAD (MONTH(ultimo_dia_mes),2,"00");
	 let dias = day(ultimo_dia_mes);
	 let vaniomes2 =  year(primer_dia_mes) || LPAD (MONTH(primer_dia_mes),2,"00");
	 LET vfechahorainauth = extend(extend(vfechahorainauth - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);
 	 
	 	IF (ultimo_dia_mes < vfecha_hoy) THEN --Se valida que la opción produtiva no se hayá ejecutado con anterioridad
		
			IF ( vindica == 'Q' ) THEN
				--Se ejecuta proceso mensual QIUBO que genera un archivo en /resplogifx/compras_culiacan_qiubo_'mes'.txt
				EXECUTE PROCEDURE intercard:sp_informacion_qiubo(primer_dia_mes_hora,ultimo_dia_mes_hora) INTO vcodret,p_mensaje;
				return vcodret, p_mensaje;
			END IF;
			
			IF ( vindica == 'R' ) THEN
				-- Reporte mensual de Tarjetas de Debito Rechazadas; ruta de archivo :/resplogifx/ RTX_BIN_DEBITO_RECHAZO_vaniomes2.unl
				EXECUTE PROCEDURE intercard:sp_bedito_rechazo(pindica, primer_dia_mes_hora, ultimo_dia_mes_hora, vaniomes2, pbin) INTO vcodret,p_mensaje;
				RETURN vcodret, p_mensaje;
			END IF;
			IF ( vindica == 'D' ) THEN
				-- Transacciones TDD  y TDC en Coppel; ruta de archivo :/resplogifx/Txns_Detalle_TDD_Coppel_aaaamm.txt, /resplogifx/Txns_Resumen_TDD_Coppel_aaaamm.txt, /resplogifx/Txns_Detalle_TDC_Coppel_aaaamm.txt y /resplogifx/Txns_Resumen_TDC_Coppel_aaaamm.txt
				EXECUTE PROCEDURE intercard:sp_bedito_rechazo(pindica, primer_dia_mes_hora, ultimo_dia_mes_hora, vaniomes2, pbin) INTO vcodret,p_mensaje;
				RETURN vcodret, p_mensaje;
			END IF;
			IF ( vindica IN('1','2','3','4') ) THEN
				-- Transacciones autorizadas  y  no autorizadas.; ruta de archivo :/resplogifx/movs_aut_aaaamma.txt.gz, /resplogifx/movs_aut_aaaammb.txt.gz, /resplogifx/movs_aut_aaaammc.txt.gz y /resplogifx/movs_noaut_aaaamm.txt
				EXECUTE PROCEDURE intercard:sp_txn_auto_noauto(pindica, primer_dia_mes_hora, ultimo_dia_mes_hora, vaniomes2) INTO vcodret,p_mensaje;
				RETURN vcodret, p_mensaje;
			END IF;
		
    SET ISOLATION to dirty read;
		IF (vindica ='M') THEN
			SELECT   FIRST 1 periodo INTO vperiodo3 FROM intercard:estadisticautorizacion WHERE periodo = vaniomes2;	--	No debe existir p/poderse ejecutar.
			LET nrows = dbinfo("sqlca.sqlerrd2");
			IF(nrows = 1) THEN
				LET vcodret = '0007';
				LET  p_mensaje  = 'Ya se ejecuto la opción mensual del periodo '||vperiodo3||' ';
				return vcodret, p_mensaje;
			END IF;
		END IF;
		
    
	IF (vindica ='P') THEN
	  IF (vfechahorainauth < vperiodini ) THEN
			
		else
        LET vcodret = '0004';
        LET  p_mensaje  = 'El periodo es menor al periodo minimo de la tabla de movimientohistroico';
         return vcodret, p_mensaje;
	  END IF;
	END IF;
   
--/////////////////////////////////  INICIO DE EJECUCIÓN DE OPCIÓN MENSUAL ////////////////////////////////////////////////--

 ---Se extrae información  de la tabla de movimiento y movimientohistorico de Intercard de transacciones POS, ATM, Nacional e Internacional,métodos de captura 90,05,01  y formatos 0200,0220,0420
  
  IF  ( vindica = 'M' AND vindica <> '') THEN
  
  
  		CREATE TABLE informix.pasodatos ( 
		bin                       VARCHAR(6),
--	2015.06.26 - FRG.I	Se agregan los campos 'motivo_rechazo' y 'producto'	a la tabla.
		producto				  VARCHAR(6),
		codigoiso       		  VARCHAR(2),
		metodocaptura   		  VARCHAR(2),
		descripcion               VARCHAR(30),
		numero_tx    		      integer,
		monto_tx                  DECIMAL(19,4),
		transaccionorigen         VARCHAR(4),
		periodo                   VARCHAR(6), 
		motivo_rechazo		  	  VARCHAR(70)
		
		)EXTENT SIZE 120 NEXT SIZE 120 LOCK MODE ROW;
		
		
    SET  ISOLATION to dirty read;
    SELECT {+INDEX(intercard:movimiento idx_fechahorainauth)} {+INDEX(intercard:movimiento idx_movimientonew1a)}
	SUBSTR (mv.numtarjeta,0,6) AS BIN,
--	2015.06.26 - FRG.I	Se agregan los campos 'motivo_rechazo' y 'producto'	a la tabla.
	trj.codproductotarjeta as prod_tarjeta, 
	codigoiso as Codigo_Rechazo,prodind,esnacional,metodocaptura,
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
--	2015.06.30 - FRG - Se agregan Métodos de Captura.
 				 WHEN metodocaptura = '81'  THEN "Ecomerce MasterCard"
				 WHEN metodocaptura = '80'  THEN "FallBack"
				 WHEN metodocaptura = '92'  THEN "Contactless"
				 WHEN metodocaptura IN ('00','02') THEN "Metodos Captura No Determinados"
		ELSE "NULL"
			END AS Descripcion,motivo AS Motivo_Rechazo,count(*) as Total_tx,sum(monto) as Monto_de_TX,transaccionorigen, vaniomes2 as periodo
            FROM intercard:movimiento mv, intercard:productotarjeta pro,intercard: tarjeta trj
--	2015.06.26 - FRG.I	Se agregan los campos 'motivo_rechazo' y 'producto'	a la tabla.		
			WHERE fechahorainauth BETWEEN primer_dia_mes_hora AND ultimo_dia_mes_hora  
			AND SUBSTR (mv.numtarjeta,0,6) in  (SELECT bin FROM intercard:bines)
			AND prodind in ('02','01')
			AND esnacional in ('V','F')
--	2015.07.01 - FRG.	Se agregan formatos de mensaje.
			AND formato IN ('0200', '0220', '0221', '0420')
			AND SUBSTR (mv.numtarjeta,0,6) in (SELECT bin FROM intercard:bines) --	Solo considerar los bines que están en InterCard:bines.
--	2015.06.30 - FRG. Se agrega condición:
			AND movreversado = 'F'	--	No se contabilizan transacciones reversadas.
			AND metodocaptura is not null AND metodocaptura != ('null')
			AND codigoiso != ('null')
		    and trj.numtarjeta = mv.numtarjeta
            and trj.codproductotarjeta = pro.codproductotarjeta
--	2015.06.26 - FRG.I	Se agregan los campos 'motivo_rechazo' y 'producto'	a la tabla.	
			--	group by 1,2,3,4,5,6,7,10
			group by 1,2,3,4,5,6,7,8,11
UNION ALL

--set ISOLATION to dirty read;
    SELECT  {+INDEX(intercard:movimientohistorico idx_movimiento3)} {+INDEX(intercard:movimientohistorico idx_movimiento1)}
	SUBSTR (mvh.numtarjeta,0,6) AS BIN,
--	2015.06.26 - FRG.I	Se agregan los campos 'motivo' y 'producto'	a la tabla.
	trj.codproductotarjeta as prod_tarjeta, 
	codigoiso as Codigo_Rechazo,prodind,esnacional,metodocaptura,
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
--	2015.06.30 - FRG - Se agregan Métodos de Captura.
 				 WHEN metodocaptura = '81'  THEN "Ecomerce MasterCard"
				 WHEN metodocaptura = '80'  THEN "FallBack"
				 WHEN metodocaptura = '92'  THEN "Contactless"
				 WHEN metodocaptura IN ('00','02') THEN "Metodos Captura No Determinados"
		ELSE "NULL"
			END AS Descripcion,motivo AS Motivo_Rechazo,count(*) as Total_tx, sum(monto) as Monto_de_TX,transaccionorigen, vaniomes2 as periodo
			FROM intercard:movimientohistorico mvh, intercard:productotarjeta pro,intercard: tarjeta trj
			WHERE fechahorainauth BETWEEN primer_dia_mes_hora AND ultimo_dia_mes_hora  
			AND SUBSTR (mvh.numtarjeta,0,6) in  (SELECT bin FROM intercard:bines)
			AND prodind in ('02','01')
			AND esnacional in ('V','F')
--	2015.07.01 - FRG.	Se agregan formatos de mensaje.
			AND formato IN ('0200', '0220', '0221', '0420')
			AND SUBSTR (mvh.numtarjeta,0,6) in (SELECT bin FROM intercard:bines) --	Solo considerar los bines que están en InterCard:bines.
--	2015.06.30 - FRG. Se agrega condición:
			AND movreversado = 'F'	--	No se contabilizan transacciones reversadas.
			AND metodocaptura is not null AND metodocaptura != ('null')	
			AND codigoiso != ('null')
		    and trj.numtarjeta = mvh.numtarjeta
            and trj.codproductotarjeta = pro.codproductotarjeta
--	2015.06.26 - FRG.I	Se agregan los campos 'motivo_rechazo' y 'producto'	a la tabla.
			--	group by 1,2,3,4,5,6,7,10
			group by 1,2,3,4,5,6,7,8,11
			
    INTO temp paso  WITH NO LOG;
	
	
	----Se inserta los datos obtebidos en la tabla estadisticautorizacion
	
	SET ISOLATION to dirty read;
	INSERT INTO estadisticautorizacion 
--	2015.06.26 - FRG.I	Se agregan los campos 'motivo_rechazo' y 'producto'	(codproductotarjeta) a la tabla.	
	(bin,codproductotarjeta,codigoiso,prodind,esnacional,metodocaptura,descripcion,motivo_rechazo,numero_tx,monto_tx,transaccionorigen,periodo)
	SELECT * FROM intercard:paso;		
				SET ISOLATION TO dirty READ;
				INSERT INTO pasodatos 
--	2015.06.26 - FRG.I	Se agregan los campos 'motivo_rechazo' y 'producto'	a la tabla.
				(bin,producto,codigoiso,metodocaptura,descripcion,numero_tx,monto_tx,transaccionorigen,periodo, motivo_rechazo)
				SELECT bin,codproductotarjeta,codigoiso,metodocaptura,descripcion,numero_tx,monto_tx,transaccionorigen,periodo, motivo_rechazo
				FROM intercard:estadisticautorizacion
				WHERE prodind = '02'
				AND   esnacional = 'V';
				
				
	 ---Genera Reporter de Transacciones POS NACIONAL -------------
            let vsql = ''; 	   
--	2015.06.26 - FRG.I	Se agregan los campos 'motivo_rechazo' y 'producto'	a la tabla.
			let vsql = 'echo "|Bin  |ProdTarjeta|Código_ISO|Método de Captura|Descripción|Número_TX|Monto de Transacciones|Transacción_Origen|Motivo_Rechazo|">/resplogifx/RTX_BIN_POSNAC'|| vaniomes2 ||'.unl';
			system vsql;
			let vsql = '';
			let vsql = '';
--	2015.06.26 - FRG.I	Se agregan los campos 'motivo_rechazo' y 'producto'	a la tabla.
			let vsql=  'echo "UNLOAD TO /resplogifx/RTX_BIN_POSNAC.unl SELECT bin,producto,codigoiso,metodocaptura,descripcion,numero_tx,monto_tx,transaccionorigen, motivo_rechazo FROM intercard:pasodatos where periodo = '|| vaniomes2 ||' order by bin;">/resplogifx/retx.sql'; 
			system vsql;
			let vsql ='';
			let vsql= 'dbaccess intercard /resplogifx/retx.sql';
			system vsql;
			let vsql = '';
			let vsql ='rm /resplogifx/retx.sql';
			system vsql;
			let vsql ='';
			let vsql = "sed 's/|$//g' /resplogifx/RTX_BIN_POSNAC.unl >>/resplogifx/RTX_BIN_POSNAC"||vaniomes2||".unl";
			system vsql;
			let vsql ='rm /resplogifx/RTX_BIN_POSNAC.unl';
			system vsql;
			
			TRUNCATE TABLE intercard:pasodatos;
			
			SET ISOLATION TO dirty READ;
--	2015.06.26 - FRG.I	Se agregan los campos 'motivo_rechazo' y 'producto'	a la tabla.
				INSERT INTO pasodatos (bin,producto,codigoiso,metodocaptura,descripcion,monto_tx,numero_tx,transaccionorigen,periodo, motivo_rechazo)
				SELECT bin,codproductotarjeta,codigoiso,metodocaptura,descripcion,monto_tx,numero_tx,transaccionorigen,periodo, motivo_rechazo
				FROM intercard:estadisticautorizacion
				WHERE prodind = '02'
				AND   esnacional = 'F';
			
		
		  ---Genera Reporter de Transacciones POS INTERNACIONAL -------------
                 let vsql = ''; 	   
--	2015.06.26 - FRG.I	Se agregan los campos 'motivo_rechazo' y 'producto'	a la tabla.
			let vsql = 'echo "|Bin  |ProdTarjeta|Código_ISO|Método de Captura|Descripción|Número_TX|Monto de Transacciones|Transacción_Origen|Motivo_Rechazo|">/resplogifx/RTX_BIN_POSINT'|| vaniomes2 ||'.unl';
			system vsql;
			let vsql = '';
			let vsql = '';
			let vsql=  'echo "UNLOAD TO /resplogifx/RTX_BIN_POSINT.unl SELECT bin,producto,codigoiso,metodocaptura,descripcion,numero_tx,monto_tx,transaccionorigen, motivo_rechazo FROM intercard:pasodatos where periodo = '|| vaniomes2 ||'order by bin;">/resplogifx/retx.sql'; 
			system vsql;
			let vsql ='';
			let vsql= 'dbaccess intercard /resplogifx/retx.sql';
			system vsql;
			let vsql = '';
			let vsql ='rm /resplogifx/retx.sql';
			system vsql;
			let vsql ='';
			let vsql = "sed 's/|$//g' /resplogifx/RTX_BIN_POSINT.unl >>/resplogifx/RTX_BIN_POSINT"||vaniomes2||".unl";
			system vsql;
			let vsql ='rm /resplogifx/RTX_BIN_POSINT.unl';
			system vsql;
			
            TRUNCATE TABLE intercard:pasodatos;
			
			
			SET ISOLATION TO dirty READ;
--	2015.06.26 - FRG.I	Se agregan los campos 'motivo_rechazo' y 'producto'	a la tabla.
				INSERT INTO pasodatos (bin,producto,codigoiso,metodocaptura,descripcion,monto_tx,numero_tx,transaccionorigen,periodo, motivo_rechazo)
				SELECT bin,codproductotarjeta,codigoiso,metodocaptura,descripcion,monto_tx,numero_tx,transaccionorigen,periodo, motivo_rechazo
				FROM intercard:estadisticautorizacion
				WHERE prodind = '01'
				AND   esnacional = 'V';
			
		
		  ---Genera Reporter de Transacciones ATM NACIONAL -------------
                 let vsql = ''; 	   
--	2015.06.26 - FRG.I	Se agregan los campos 'motivo_rechazo' y 'producto'	a la tabla.
			let vsql = 'echo "|Bin  |ProdTarjeta|Código_ISO|Método de Captura|Descripción|Número_TX|Monto de Transacciones|Transacción_Origen|Motivo_Rechazo|">/resplogifx/RTX_BIN_ATMNAC'|| vaniomes2 ||'.unl';
			system vsql;
			let vsql = '';
			let vsql = '';
--	2015.06.26 - FRG.I	Se agregan los campos 'motivo_rechazo' y 'producto'	a la tabla.
			let vsql=  'echo "UNLOAD TO /resplogifx/RTX_BIN_ATMNAC.unl SELECT bin,producto,codigoiso,metodocaptura,descripcion,numero_tx,monto_tx,transaccionorigen, motivo_rechazo FROM intercard:pasodatos where periodo = '|| vaniomes2 ||'order by bin;">/resplogifx/retx.sql'; 
			system vsql;
			let vsql ='';
			let vsql= 'dbaccess intercard /resplogifx/retx.sql';
			system vsql;
			let vsql = '';
			let vsql ='rm /resplogifx/retx.sql';
			system vsql;
			let vsql ='';
			let vsql = "sed 's/|$//g' /resplogifx/RTX_BIN_ATMNAC.unl >>/resplogifx/RTX_BIN_ATMNAC"||vaniomes2||".unl";
			system vsql;
			let vsql ='rm /resplogifx/RTX_BIN_ATMNAC.unl';
			system vsql;
			
            TRUNCATE TABLE intercard:pasodatos;
			
				SET ISOLATION TO dirty READ;
--	2015.06.26 - FRG.I	Se agregan los campos 'motivo_rechazo' y 'producto'	a la tabla.
				INSERT INTO pasodatos (bin,producto,codigoiso,metodocaptura,descripcion,monto_tx,numero_tx,transaccionorigen,periodo, motivo_rechazo)
				SELECT bin,codproductotarjeta,codigoiso,metodocaptura,descripcion,monto_tx,numero_tx,transaccionorigen,periodo, motivo_rechazo
				FROM intercard:estadisticautorizacion
				WHERE prodind = '01'
				AND   esnacional = 'F';
			
		
		  ---Genera Reporter de Transacciones ATM INTERNACIONAL -------------
            let vsql = '';
--	2015.06.26 - FRG.I	Se agregan los campos 'motivo_rechazo' y 'producto'	a la tabla.
			let vsql = 'echo "|Bin  |ProdTarjeta|Código_ISO|Método de Captura|Descripción|Número_TX|Monto de Transacciones|Transacción_Origen|Motivo_Rechazo|">/resplogifx/RTX_BIN_ATMINT'|| vaniomes2 ||'.unl';
			system vsql;
			let vsql = '';
			let vsql = '';
--	2015.06.26 - FRG.I	Se agregan los campos 'motivo_rechazo' y 'producto'	a la tabla.
			let vsql=  'echo "UNLOAD TO /resplogifx/RTX_BIN_ATMINT.unl SELECT bin,producto,codigoiso,metodocaptura,descripcion,numero_tx,monto_tx,transaccionorigen, motivo_rechazo FROM intercard:pasodatos where periodo = '|| vaniomes2 ||'order by bin;">/resplogifx/retx.sql'; 
			system vsql;
			let vsql ='';
			let vsql= 'dbaccess intercard /resplogifx/retx.sql';
			system vsql;
			let vsql = '';
			let vsql ='rm /resplogifx/retx.sql';
			system vsql;
			let vsql ='';
			let vsql = "sed 's/|$//g' /resplogifx/RTX_BIN_ATMINT.unl >>/resplogifx/RTX_BIN_ATMINT"||vaniomes2||".unl";
			system vsql;
			let vsql ='rm /resplogifx/RTX_BIN_ATMINT.unl';
			system vsql;
			
            TRUNCATE TABLE intercard:pasodatos;
		
			DROP TABLE intercard:pasodatos;
			DROP TABLE intercard:paso;

			--/////////////////////////////////  FIN DE EJECUCIÓN DE OPCIÓN MENSUAL ////////////////////////////////////////////////--

			
--///////////////////////////////// INICIO DE EJECUCIÓN DE OPCIÓN A PETICIÓN DE USUARIO////////////////////////////////////////////////--
		
  			
ELSE 
--	2015.06.30	FRG	-	Se agrega el parámetro de entrada 'Método de Captura' para los reportes Tipo 'P'.
    IF  ( vindica = 'P' AND vindica is not null AND  vcodigoiso <> ''  AND vbin <> '' AND vprodind <> '' AND vmetodocaptura <> '' AND vesnacional <> '' AND vperiodo is not null ) THEN--3
	
	SET ISOLATION to dirty read;
    SELECT bin,creditodebito INTO vbin2, vcreditodebito  FROM intercard:bines WHERE bin = vbin;
    LET nrows = dbinfo("sqlca.sqlerrd2");
    IF(nrows = 0) THEN
      LET vcodret = '0005';
      LET  p_mensaje  = 'El BIN no existe';
	 return vcodret, p_mensaje;
    END IF;
     
		IF ( vcreditodebito = 'D') THEN--4
		
		CREATE TABLE informix.tx_debito( 
		numtarjeta             	  VARCHAR(16),
		codproductotarjeta        VARCHAR(3),
		descproducto       		  VARCHAR(60),
		fechahorainauthcred       DATETIME YEAR TO FRACTION(5),
		descripcion       		  VARCHAR(60),
		monto   		          DECIMAL(19,4),
		linea                     DECIMAL(19,4),
		codigoiso    		      VARCHAR(2),
		motivorechazo             VARCHAR(100),
		transaccionorigen         VARCHAR(4)
		)EXTENT SIZE 120 NEXT SIZE 120 LOCK MODE ROW;
		
--Consulta para descarga de débito, se toma en cuenta casos de compras POS con formato 200, reversos con 420 y forzadas 220
		SET ISOLATION to dirty read; 
		----SELECT {+INDEX(movimientohistorico idx_movimiento3)} {+INDEX(intercard:movimientohistorico idx_movimiento1)} {+INDEX(intercard:tarjeta 144_89 )} {+INDEX(intercard:tarjetacuenta 128_56 )} 
		---SELECT {+INDEX(intercard:movimientohistorico idx_movimiento3)} {+INDEX(intercard:movimientohistorico idx_movimiento1)} {+INDEX(intercard:tarjeta idx_tarpri )}
		---SELECT {+INDEX_ALL(movimientohistorico)} {+INDEX(intercard:tarjeta idx_tarpri )}
		SELECT {+INDEX_ALL(movh)}
				numtarjeta,codproductotarjeta,descproducto,fechahorainauth,metodocaptura, tipotransaccionposdigitada, monto,codigoiso,motivorechazo,transaccionorigen,nvl((capvigacum)/saldo,0) AS linea
				from table (multiset ( select sdo.capvigacum as capvigacum, nvl(case when sdo.diacum = 0 then 1 else sdo.diacum end,1) as saldo, movh.numtarjeta as numtarjeta,tar.codproductotarjeta as codproductotarjeta,pro.descproducto as descproducto ,movh.fechahorainauth as fechahorainauth,movh.metodocaptura as metodocaptura,movh.tipotransaccionposdigitada as tipotransaccionposdigitada, movh.monto AS monto,movh.codigoiso AS codigoiso,movh.motivo AS motivorechazo,movh.transaccionorigen AS transaccionorigen
						FROM intercard:movimientohistorico as movh,intercard:productotarjeta pro,intercard:tarjeta tar,bdicheq:sc_sdodiarioc sdo,intercard:tarjetacuenta tc 
							WHERE movh.fechahorainauth  BETWEEN pperiodini_hora AND  pperiodofin_hora
							AND SUBSTR (movh.numtarjeta,0,6) in  (select bin FROM intercard:bines where bin = vbin)
							AND codigoiso =  vcodigoiso
--	2015.06.30	FRG	-	Se agrega el parámetro de entrada 'Método de Captura' para los reportes Tipo 'P'.
							AND metodocaptura = vmetodocaptura
--	2015.07.01 - FRG.	Se agregan formatos de mensaje.
							AND formato IN ('0200', '0220', '0221', '0420')
							AND SUBSTR (movh.numtarjeta,0,6) in (SELECT bin FROM intercard:bines) --	Solo considerar los bines que están en InterCard:bines.
--	2015.06.30 - FRG. Se agrega condición:
							AND movreversado = 'F'	--	No se contabilizan transacciones reversadas.
							AND prodind = vprodind
							AND esnacional = vesnacional
							AND tar.numtarjeta = movh.numtarjeta 
							AND pro.codproductotarjeta = tar.codproductotarjeta 
							AND sdo.aniomes = vperiodo 
							AND tc.numtarjeta = tar.numtarjeta 
							AND tc.numcuenta = sdo.cuenta ))
						
		UNION ALL
      
		----SELECT  {+INDEX(intercard:movimiento idx_fechahorainauth)} {+INDEX(intercard:movimiento idx_movimientonew1a)} {+INDEX(intercard:tarjeta 144_89 )} {+INDEX(intercard:tarjetacuenta 128_56 )} 
		SELECT  {+INDEX(intercard:movimiento idx_fechahorainauth)} {+INDEX(intercard:movimiento idx_movimientonew1a)} {+INDEX(intercard:tarjeta idx_tarpri )}
				numtarjeta,codproductotarjeta,descproducto,fechahorainauth,metodocaptura, tipotransaccionposdigitada, monto,codigoiso,motivorechazo,transaccionorigen,nvl((capvigacum)/saldo,0) AS linea
				from table (multiset ( select sdo.capvigacum as capvigacum, nvl(case when sdo.diacum = 0 then 1 else sdo.diacum end,1) as saldo, mov.numtarjeta as numtarjeta,tar.codproductotarjeta as codproductotarjeta,pro.descproducto as descproducto ,mov.fechahorainauth as fechahorainauth,mov.metodocaptura as metodocaptura,mov.tipotransaccionposdigitada as tipotransaccionposdigitada, mov.monto AS monto,mov.codigoiso AS codigoiso,mov.motivo AS motivorechazo,mov.transaccionorigen AS transaccionorigen
						FROM intercard:movimiento as mov,intercard:productotarjeta pro,intercard:tarjeta tar,bdicheq:sc_sdodiarioc sdo,intercard:tarjetacuenta tc 
							WHERE mov.fechahorainauth  BETWEEN pperiodini_hora AND  pperiodofin_hora
							AND SUBSTR (mov.numtarjeta,0,6) in  (select bin FROM intercard:bines where bin = vbin)
							AND codigoiso =  vcodigoiso
--	2015.06.30	FRG	-	Se agrega el parámetro de entrada 'Método de Captura' para los reportes Tipo 'P'.
							AND metodocaptura = vmetodocaptura
--	2015.07.01 - FRG.	Se agregan formatos de mensaje.
							AND formato IN ('0200', '0220', '0221', '0420')
							AND SUBSTR (mov.numtarjeta,0,6) in (SELECT bin FROM intercard:bines) --	Solo considerar los bines que están en InterCard:bines.
--	2015.06.30 - FRG. Se agrega condición:
							AND movreversado = 'F'	--	No se contabilizan transacciones reversadas.
							AND prodind = vprodind
							AND esnacional = vesnacional
							AND tar.numtarjeta = mov.numtarjeta 
							AND pro.codproductotarjeta = tar.codproductotarjeta 
							AND sdo.aniomes = vperiodo 
							AND tc.numtarjeta = tar.numtarjeta 
							AND tc.numcuenta = sdo.cuenta ))	

			
							
			INTO  temp pasodebito WITH NO LOG;
			
			
			SET ISOLATION to dirty read; 
					SELECT pd.numtarjeta,pd.codproductotarjeta,pd.descproducto,pd.fechahorainauth,
       
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
--	2015.06.30 - FRG - Se agregan Métodos de Captura.
 				 WHEN metodocaptura = '81'  THEN "Ecomerce MasterCard"
				 WHEN metodocaptura = '80'  THEN "FallBack"
				 WHEN metodocaptura = '92'  THEN "Contactless"
				 WHEN metodocaptura IN ('00','02') THEN "Metodos Captura No Determinados"
		ELSE "NULL"
			END AS Descripcion,pd.monto,pd.linea,pd.codigoiso,pd.motivorechazo,pd.transaccionorigen
		from intercard:pasodebito pd
		
		INTO  temp pasodebitodos WITH NO LOG;
		
			
		SET isolation to dirty read;
	    INSERT INTO tx_debito (numtarjeta,codproductotarjeta,descproducto,fechahorainauthcred,Descripcion,monto,linea,codigoiso,motivorechazo,transaccionorigen)
        SELECT * FROM intercard:pasodebitodos;
		
		   --8)Generación del segundo reporte a detalle por la causa de rechazo código ISO 61 y 65
		    let vsql = ''; 	   
			let vsql = 'echo "|Tarjeta|Producto|Descripción|Fecha Transacción|Método_Captura|Monto de Compra|Línea Crédito/Débito|Código_ISO|Descripción_ISO|Transacción_Origen|">/resplogifx/RTX_BIN_DEB_'|| vaniomes2 ||'.unl';
			system vsql;
			let vsql = '';
			let vsql = '';
			let vsql=  'echo "UNLOAD TO /resplogifx/RTX_BIN_DEB_.unl SELECT * FROM tx_debito;">/resplogifx/retxcred.sql'; 
			system vsql;
			let vsql ='';
			let vsql= 'dbaccess intercard /resplogifx/retxcred.sql';
			system vsql;
			let vsql = '';
			let vsql ='rm /resplogifx/retxcred.sql';
			system vsql;
			let vsql ='';
			let vsql = "sed 's/|$//g' /resplogifx/RTX_BIN_DEB_.unl >>/resplogifx/RTX_BIN_DEB_"||vaniomes2||".unl";
			system vsql;
			let vsql ='rm /resplogifx/RTX_BIN_DEB_.unl';
			system vsql;
			
			DROP TABLE pasodebitodos;
		    DROP TABLE pasodebito;
			DROP TABLE tx_debito;
			
			
		ELSE IF ( vcreditodebito = 'C')	THEN--5		

        CREATE TABLE informix.tx_credito( 
		numtarjeta             	  VARCHAR(16),
		codproductotarjeta        VARCHAR(3),
		descproducto       		  VARCHAR(60),
		fechahorainauthcred     	  DATETIME YEAR TO FRACTION(5),
		descripcion       		  VARCHAR(60),
		monto   		          DECIMAL(19,4),
		linea                     DECIMAL(19,4),
		codigoiso    		      VARCHAR(2),
		motivorechazo             VARCHAR(100),
		transaccionorigen         VARCHAR(4)
		)EXTENT SIZE 120 NEXT SIZE 120 LOCK MODE ROW;
		
														
   
	   --Consulta para la descarga de crédito, se toma en cuenta casos de compras POS con formato 200, reversos con 420 y forzadas 220
	   
	    SET isolation to dirty read;
	    ---SELECT  {+INDEX(intercard:movimientohistorico idx_movimiento3)} {+INDEX(intercard:movimientohistorico idx_movimiento1)} {+INDEX(intercard:tarjeta 144_89 )} {+INDEX(intercard:tarjetacuenta 128_56 )} 			
	    SELECT  {+INDEX(intercard:movimientohistorico idx_movimiento3)} {+INDEX(intercard:movimientohistorico idx_movimiento1)}  {+INDEX(intercard:tarjeta idx_tarpri )}
		        movh.numtarjeta,tar.codproductotarjeta,pro.descproducto,movh.fechahorainauth AS fechahorainauthcred,movh.metodocaptura,movh.tipotransaccionposdigitada,
                movh.monto AS monto ,sdm.monto_otorgado AS lineaC,movh.codigoiso,movh.motivo AS motivorechazo,movh.transaccionorigen AS transaccionorigen
                        FROM  intercard:movimientohistorico movh,intercard:productotarjeta pro,intercard:tarjeta tar,
                               intercard:tarjetacuenta tc,bdicred:sd_maesdos sdm
								WHERE movh.fechahorainauth  BETWEEN pperiodini_hora AND  pperiodofin_hora
								AND   SUBSTR (movh.numtarjeta,0,6) in  (select bin FROM intercard:bines where bin = vbin)
								AND   codigoiso =  vcodigoiso
--	2015.06.30	FRG	-	Se agrega el parámetro de entrada 'Método de Captura' para los reportes Tipo 'P'.
								AND   movh.metodocaptura = vmetodocaptura
--	2015.07.01 - FRG.	Se agregan formatos de mensaje.
								AND   formato IN ('0200', '0220', '0221', '0420')
								AND   SUBSTR (movh.numtarjeta,0,6) in (SELECT bin FROM intercard:bines) --	Solo considerar los bines que están en InterCard:bines.								
--	2015.06.30 - FRG. Se agrega condición:
								AND   movreversado = 'F'	--	No se contabilizan transacciones reversadas.
								AND   prodind = vprodind
								AND   esnacional = vesnacional
								AND   pro.codproductotarjeta = tar.codproductotarjeta
								AND   tar.numtarjeta = movh.numtarjeta
								AND   tc.numtarjeta = tar.numtarjeta
								AND   sdm.num_credito = tc.numcuenta
		
		UNION ALL

	    ----SELECT  {+INDEX(intercard:movimiento idx_fechahorainauth)} {+INDEX(intercard:movimiento idx_movimientonew1a)} {+INDEX(intercard:tarjeta 144_89 )} {+INDEX(intercard:tarjetacuenta 128_56 )} 
	    SELECT  {+INDEX(intercard:movimiento idx_fechahorainauth)} {+INDEX(intercard:movimiento idx_movimientonew1a)}  {+INDEX(intercard:tarjeta idx_tarpri )}
		        mov.numtarjeta,tar.codproductotarjeta,pro.descproducto,mov.fechahorainauth AS fechahorainauthcred,mov.metodocaptura,mov.tipotransaccionposdigitada,
                mov.monto AS monto ,sdm.monto_otorgado AS lineaC,mov.codigoiso,mov.motivo AS motivorechazo,mov.transaccionorigen AS transaccionorigen
                          FROM  intercard:movimiento mov,intercard:productotarjeta pro,intercard:tarjeta tar,
                           intercard:tarjetacuenta tc,bdicred:sd_maesdos sdm
								WHERE mov.fechahorainauth  BETWEEN pperiodini_hora AND  pperiodofin_hora
								AND   SUBSTR (mov.numtarjeta,0,6) in  (select bin FROM intercard:bines where bin = vbin)
								AND   codigoiso =  vcodigoiso
--	2015.06.30	FRG	-	Se agrega el parámetro de entrada 'Método de Captura' para los reportes Tipo 'P'.
								AND   mov.metodocaptura = vmetodocaptura
--	2015.07.01 - FRG.	Se agregan formatos de mensaje.
								AND   formato IN ('0200', '0220', '0221', '0420')
								AND   SUBSTR (mov.numtarjeta,0,6) in (SELECT bin FROM intercard:bines) --	Solo considerar los bines que están en InterCard:bines.
--	2015.06.30 - FRG. Se agrega condición:
								AND   movreversado = 'F'	--	No se contabilizan transacciones reversadas.
								AND   prodind = vprodind
								AND   esnacional = vesnacional 
								AND   pro.codproductotarjeta = tar.codproductotarjeta
								AND   tar.numtarjeta = mov.numtarjeta
								AND   tc.numtarjeta = tar.numtarjeta
								AND   sdm.num_credito = tc.numcuenta
		
		INTO  temp pasocredito WITH NO LOG;
		
		
		SET isolation to dirty read;
		select pc.numtarjeta,pc.codproductotarjeta,pc.descproducto,pc.fechahorainauthcred,
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
--	2015.06.30 - FRG - Se agregan Métodos de Captura.
 				 WHEN metodocaptura = '81'  THEN "Ecomerce MasterCard"
				 WHEN metodocaptura = '80'  THEN "FallBack"
				 WHEN metodocaptura = '92'  THEN "Contactless"
				 WHEN metodocaptura IN ('00','02') THEN "Metodos Captura No Determinados"
		ELSE "NULL"
			END AS Descripcion,pc.monto,pc.lineaC,pc.codigoiso,pc.motivorechazo,pc.transaccionorigen
		from intercard:pasocredito pc
		
		INTO  temp pasocreditodos WITH NO LOG;
		
		
		SET isolation to dirty read;
	    INSERT INTO tx_credito (numtarjeta,codproductotarjeta,descproducto,fechahorainauthcred,Descripcion,monto,linea,codigoiso,motivorechazo,transaccionorigen)
        SELECT * FROM intercard:pasocreditodos;
	
	    --8)Generación del segundo reporte a detalle por la causa de rechazo código ISO 61 y 65
		    let vsql = ''; 	   
			let vsql = 'echo "|Tarjeta|Producto|Descripción|Fecha Transacción|Método_Captura|Monto de Compra|Línea Crédito/Débito|Código_ISO|Descripción_ISO|Transacción_Origen|">/resplogifx/RTX_BIN_CRED_'|| vaniomes2 ||'.unl';
			system vsql;
			let vsql = '';
			let vsql = '';
			let vsql=  'echo "UNLOAD TO /resplogifx/RTX_BIN_CRED_.unl SELECT * FROM tx_credito;">/resplogifx/retxcred.sql'; 
			system vsql;
			let vsql ='';
			let vsql= 'dbaccess intercard /resplogifx/retxcred.sql';
			system vsql;
			let vsql = '';
			let vsql ='rm /resplogifx/retxcred.sql';
			system vsql;
			let vsql ='';
			let vsql = "sed 's/|$//g' /resplogifx/RTX_BIN_CRED_.unl >>/resplogifx/RTX_BIN_CRED_"||vaniomes2||".unl";
			system vsql;
			let vsql ='rm /resplogifx/RTX_BIN_CRED_.unl';
			system vsql;
			
			 DROP TABLE pasocreditodos;
		     DROP TABLE pasocredito;
		     DROP TABLE tx_credito;
         END IF;  		
       END IF; 	
	ELSE
    LET vcodret = '0002';
    LET  p_mensaje  = 'Hay valores nulos.';
    return vcodret, p_mensaje;
	    
  
     END IF; 
	END IF; 
		
				 			
        LET vcodret = '00000';
		LET  p_mensaje  = 'Reporte Generado ';
		return vcodret, p_mensaje;
		  

	 	else
      LET vcodret = '0005';
      LET  p_mensaje  = 'Se debe ejecutar los dias 5 de cada mes ';
     return vcodret, p_mensaje;
	
 END IF;	
END IF; 
END;
end procedure
/*
2015.06.26 - Se agregan los campos 'motivo_rechazo' y 'producto' para los reportes.
2015.06.30 - Se agrega el parámetro de entrada 'Método de Captura' para los reportes Tipo 'P'.
Solicitud: RQM 10 640 - Mejoras a reporte de aceptacion.
Autor: FRG
BD: intercard
*/
;

CREATE PROCEDURE "informix".sp_txrechazo(pindica VARCHAR (1),--Parametro que indica si "M" es mensual o "P" es a petición."Q" Reporte Qiubo
                                         pcodigoiso VARCHAR(2), --Parametro si es Código ISO de rechazo cuando es por petición
										 pbin VARCHAR(6), --Parametro si el BIN es de débito o crédito	
                                         pprodind VARCHAR(2),-- Parametro que Indica si es "01" es ATM y "02" es POS
										 pesnacional VARCHAR(1),--Parametro que indica si es "V" Nacional o "F" Internacional 
										 pmetodocaptura VARCHAR(2),--Parametro que indica si es Digitada (01), Chip (05), FallBack (80), eCommerce (81, sólo MC), Banda (90), ContaccLess (91), etc.
										 pperiodo VARCHAR(6)) ---Parametro de periodo de extracción de información                                                                                      

RETURNING varchar(6), varchar(80);
----------Variables-------------------------------
DEFINE  error_info              varchar(80);
DEFINE  isam_err                integer;
DEFINE  vsqlerr                 integer;
DEFINE  vcodret                 varchar(6);
DEFINE  p_mensaje               varchar(80);
DEFINE  vletra                  varchar(1);
DEFINE  vaniomes                char(6);
DEFINE  vaniomes2               char(6);
DEFINE  vfecha_hoy              DATE;
DEFINE  vfechahorainauth        DATE;
DEFINE  vsql                    char(1150);
DEFINE  vcodigoiso              varchar(2);
DEFINE  vindica                 varchar(1);
DEFINE  vbin                    VARCHAR(6); --Bin de débito
DEFINE  vbin2                   VARCHAR(6); --Bin de crédito
DEFINE  vbin3                   VARCHAR(9); --Bin de crédito
DEFINE  vprodind                VARCHAR(2); --Método de captura
DEFINE  vesnacional             varchar(1); --Indica si es Nac ó Int.
DEFINE	vmetodocaptura			VARCHAR(2);
DEFINE  vnprodind               VARCHAR(2);
DEFINE  vnesnacional            VARCHAR(1);
DEFINE  viprodind               VARCHAR(2);
DEFINE  viesnacional            VARCHAR(1);
DEFINE  vperiodini              DATE;
DEFINE  vperiodofin             DATE;
DEFINE  vperiodo                VARCHAR(6);
DEFINE  vperiodo3               VARCHAR(6);
DEFINE  vano                    VARCHAR(4);
DEFINE  vmes                    VARCHAR(2);
DEFINE  vdia                    VARCHAR(2);
DEFINE  dias                    integer;
DEFINE  nrows                   SMALLINT;
DEFINE  vcreditodebito          VARCHAR(1); --Indica si es crédito o débito.
 
---------------------------------------------------

DEFINE ultimo_dia_mes DATE;
DEFINE primer_dia_mes DATE;
DEFINE ultimo_dia_mes_hora DATETIME YEAR TO FRACTION(5);
DEFINE primer_dia_mes_hora DATETIME YEAR TO FRACTION(5);
DEFINE pperiodofin_hora DATETIME YEAR TO FRACTION(5);
DEFINE pperiodini_hora DATETIME YEAR TO FRACTION(5);
DEFINE FechaAux DATETIME YEAR TO FRACTION(5);
         
  
	--	SET DEBUG FILE TO "/informix/frg/Rpts_Productos/sp_txrechazo_frg.out";
	--	TRACE ON;

  begin
 
 
 ------------- control de errores------
    ON EXCEPTION SET vsqlerr,isam_err, error_info
            IF vsqlerr <> 0 AND vsqlerr <> -958  then
                let vcodret = vsqlerr;
                let p_mensaje = error_info;
                  RETURN vcodret, p_mensaje;
            END IF;
    END EXCEPTION;


	ON EXCEPTION SET vsqlerr,isam_err, error_info
            IF vsqlerr = -958  then	
			    if error_info ='informix.pasodebito' then
				     DROP TABLE pasodebito;
				  end if
                if error_info ='informix.pasodebitodos' then
				     DROP TABLE pasodebitodos;
				  end if
                if error_info ='informix.pasocredito' then
				     DROP TABLE pasocredito;
				  end if
                if error_info ='informix.pasocreditodos' then
				     DROP TABLE pasocreditodos;
				  end if
                if error_info ='informix.tx_debito' then
				     DROP TABLE tx_debito;
				  end if
			    if error_info ='informix.tx_credito' then
				     DROP TABLE tx_credito;
				  end if
                if error_info ='informix.tx_credito_debito' then
				     DROP TABLE tx_credito_debito;
				  end if
                if error_info ='informix.pasodatos' then
				     DROP TABLE pasodatos;
				  end if
                if error_info ='informix.paso' then
				     DROP TABLE paso;
				  end if				  
		  				   
		    END IF;    
    END EXCEPTION WITH RESUME; 

-----------***********cuerpo**************-------------------  
SET ISOLATION to dirty read;
SELECT fecha_hoy INTO vfecha_hoy FROM bdinteg:si_fechas;
--LET vfecha_hoy = '05/03/2013';

SET ISOLATION to dirty read;
SELECT MIN (fechahorainauth) INTO vfechahorainauth FROM intercard:movimientohistorico;
LET vindica = pindica;
LET vcodigoiso = pcodigoiso;
LET vbin = pbin; 
LET vprodind = pprodind;
LET vesnacional  = pesnacional;
LET	vmetodocaptura	= pmetodocaptura;
LET vperiodo = pperiodo;
LET vano = SUBSTR(vperiodo,0,4);
LET vmes = SUBSTR(vperiodo,5,6);
LET vdia = '01';
LET vperiodini =  vmes||'/'||vdia||'/'||vano;LET vperiodofin = vmes||'/'||vdia||'/'||vano;LET vfechahorainauth = SUBSTR(vfechahorainauth,0,10);

---Modificación para ejecutar opción de reporte de tarjetas de banda ---
IF ((vindica = 'L' OR vindica = 'Y' OR vindica = 'V') AND vindica <>'')THEN
 
      EXECUTE PROCEDURE intercard:sp_tarjetabanda(vindica) INTO vcodret,p_mensaje;
	  
	    return  vcodret, p_mensaje;	 
		
ELSE

-----operaciones de fechas
     LET ultimo_dia_mes = extend(extend(vfecha_hoy - 0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 0 units DAY;
     LET ultimo_dia_mes_hora = extend(extend(vfecha_hoy - 0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 0 units DAY;
     LET ultimo_dia_mes_hora = SUBSTRING(ultimo_dia_mes_hora FROM 1 FOR 10) || ' 00:00:00';
     --OBTIENE EL PRIMER DIA DEL MES DE CORTE
     LET primer_dia_mes = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);
     LET primer_dia_mes_hora = extend(extend(vfecha_hoy - 1 units MONTH ,YEAR TO MONTH)||"-01",YEAR TO DAY);
     LET primer_dia_mes_hora= SUBSTRING(primer_dia_mes_hora FROM 1 FOR 10) || ' 00:00:00';
-------------------------------  CÁLCULO DE FECHAS-----------------------------------------------------------------------------
 -----operaciones de fechas
     --LET ultimo_dia_mes = extend(extend(vfecha_hoy - 0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 0 units DAY;
     LET pperiodofin_hora = extend(extend(vperiodofin + 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 0 units DAY;
     LET pperiodofin_hora = SUBSTRING(pperiodofin_hora FROM 1 FOR 10) || ' 23:59:59';
     --OBTIENE EL PRIMER DIA DEL MES DE CORTE
      --LET pperiodini = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);
        LET pperiodini_hora = extend(extend(vperiodini - 0 units MONTH ,YEAR TO MONTH)||"-01",YEAR TO DAY);
        LET pperiodini_hora= SUBSTRING(pperiodini_hora FROM 1 FOR 10) || ' 00:00:00';
	 --LET pperiodini = '04/01/2013';
	 --let pperiodini_hora = 2013-03-01 00:00:00 */
	 
--OBTIENE LA FECHA MINIMA DE INTERCARD:MOVIMIENTO    
    set ISOLATION to dirty read;
	SELECT fecha_hoy INTO vfecha_hoy FROM bdinteg:si_fechAS;
	 SELECT {+INDEX(intercard:movimiento idx_fechahorainauth)} MIN(FechaHoraInAuth)
      INTO FechaAux FROM Intercard:Movimiento;
--OBTIENE EL AÑO Y MES DE LA FECHA	  
     let vaniomes =  year(ultimo_dia_mes) || LPAD (MONTH(ultimo_dia_mes),2,"00");
	 let dias = day(ultimo_dia_mes);
	 let vaniomes2 =  year(primer_dia_mes) || LPAD (MONTH(primer_dia_mes),2,"00");
	 LET vfechahorainauth = extend(extend(vfechahorainauth - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);
 	 
	 	IF (ultimo_dia_mes < vfecha_hoy) THEN --Se valida que la opción produtiva no se hayá ejecutado con anterioridad
		
			IF ( vindica == 'Q' ) THEN
				--Se ejecuta proceso mensual QIUBO que genera un archivo en /resplogifx/compras_culiacan_qiubo_'mes'.txt
				EXECUTE PROCEDURE intercard:sp_informacion_qiubo(primer_dia_mes_hora,ultimo_dia_mes_hora) INTO vcodret,p_mensaje;
				return vcodret, p_mensaje;
			END IF;
			
			IF ( vindica == 'R' ) THEN
				-- Reporte mensual de Tarjetas de Debito Rechazadas; ruta de archivo :/resplogifx/ RTX_BIN_DEBITO_RECHAZO_vaniomes2.unl
				EXECUTE PROCEDURE intercard:sp_bedito_rechazo(pindica, primer_dia_mes_hora, ultimo_dia_mes_hora, vaniomes2, pbin) INTO vcodret,p_mensaje;
				RETURN vcodret, p_mensaje;
			END IF;
			IF ( vindica == 'D' ) THEN
				-- Transacciones TDD  y TDC en Coppel; ruta de archivo :/resplogifx/Txns_Detalle_TDD_Coppel_aaaamm.txt, /resplogifx/Txns_Resumen_TDD_Coppel_aaaamm.txt, /resplogifx/Txns_Detalle_TDC_Coppel_aaaamm.txt y /resplogifx/Txns_Resumen_TDC_Coppel_aaaamm.txt
				EXECUTE PROCEDURE intercard:sp_bedito_rechazo(pindica, primer_dia_mes_hora, ultimo_dia_mes_hora, vaniomes2, pbin) INTO vcodret,p_mensaje;
				RETURN vcodret, p_mensaje;
			END IF;
			IF ( vindica IN('1','2','3','4') ) THEN
				-- Transacciones autorizadas  y  no autorizadas.; ruta de archivo :/resplogifx/movs_aut_aaaamma.txt.gz, /resplogifx/movs_aut_aaaammb.txt.gz, /resplogifx/movs_aut_aaaammc.txt.gz y /resplogifx/movs_noaut_aaaamm.txt
				EXECUTE PROCEDURE intercard:sp_txn_auto_noauto(pindica, primer_dia_mes_hora, ultimo_dia_mes_hora, vaniomes2) INTO vcodret,p_mensaje;
				RETURN vcodret, p_mensaje;
			END IF;
		
    SET ISOLATION to dirty read;
		IF (vindica ='M') THEN
			SELECT   FIRST 1 periodo INTO vperiodo3 FROM intercard:estadisticautorizacion WHERE periodo = vaniomes2;	--	No debe existir p/poderse ejecutar.
			LET nrows = dbinfo("sqlca.sqlerrd2");
			IF(nrows = 1) THEN
				LET vcodret = '0007';
				LET  p_mensaje  = 'Ya se ejecuto la opción mensual del periodo '||vperiodo3||' ';
				return vcodret, p_mensaje;
			END IF;
		END IF;
		
    
	IF (vindica ='P') THEN
	  IF (vfechahorainauth < vperiodini ) THEN
			
		else
        LET vcodret = '0004';
        LET  p_mensaje  = 'El periodo es menor al periodo minimo de la tabla de movimientohistroico';
         return vcodret, p_mensaje;
	  END IF;
	END IF;
   
--/////////////////////////////////  INICIO DE EJECUCIÓN DE OPCIÓN MENSUAL ////////////////////////////////////////////////--

 ---Se extrae información  de la tabla de movimiento y movimientohistorico de Intercard de transacciones POS, ATM, Nacional e Internacional,métodos de captura 90,05,01  y formatos 0200,0220,0420
  
  IF  ( vindica = 'M' AND vindica <> '') THEN
  
  
  		CREATE TABLE informix.pasodatos ( 
		bin                       VARCHAR(6),
		producto				  VARCHAR(6),
		codigoiso       		  VARCHAR(2),
		metodocaptura   		  VARCHAR(2),
		descripcion               VARCHAR(30),
		numero_tx    		      integer,
		monto_tx                  DECIMAL(19,4),
		transaccionorigen         VARCHAR(4),
		periodo                   VARCHAR(6), 
		motivo_rechazo		  	  VARCHAR(70)
		
		)EXTENT SIZE 120 NEXT SIZE 120 LOCK MODE ROW;
		
		
    SET  ISOLATION to dirty read;
    SELECT {+INDEX(intercard:movimiento idx_fechahorainauth)} {+INDEX(intercard:movimiento idx_movimientonew1a)}
	SUBSTR (mv.numtarjeta,0,6) AS BIN,
	trj.codproductotarjeta as prod_tarjeta, 
	codigoiso as Codigo_Rechazo,prodind,esnacional,metodocaptura,
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
			END AS Descripcion,motivo AS Motivo_Rechazo,count(*) as Total_tx,sum(monto) as Monto_de_TX,transaccionorigen, vaniomes2 as periodo
            FROM intercard:movimiento mv, intercard:productotarjeta pro,intercard: tarjeta trj
			WHERE fechahorainauth BETWEEN primer_dia_mes_hora AND ultimo_dia_mes_hora  
			AND SUBSTR (mv.numtarjeta,0,6) in  (SELECT bin FROM intercard:bines)
			AND prodind in ('02','01')
			AND esnacional in ('V','F')
			AND formato IN ('0200', '0220', '0221', '0420')
			AND SUBSTR (mv.numtarjeta,0,6) in (SELECT bin FROM intercard:bines) --	Solo considerar los bines que están en InterCard:bines.
			AND movreversado = 'F'	--	No se contabilizan transacciones reversadas.
			AND metodocaptura is not null AND metodocaptura != ('null')
			AND codigoiso != ('null')
		    and trj.numtarjeta = mv.numtarjeta
            and trj.codproductotarjeta = pro.codproductotarjeta
			group by 1,2,3,4,5,6,7,8,11
UNION ALL

--set ISOLATION to dirty read;
    SELECT  {+INDEX(intercard:movimientohistorico idx_movimiento3)} {+INDEX(intercard:movimientohistorico idx_movimiento1)}
	SUBSTR (mvh.numtarjeta,0,6) AS BIN,
	trj.codproductotarjeta as prod_tarjeta, 
	codigoiso as Codigo_Rechazo,prodind,esnacional,metodocaptura,
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
			END AS Descripcion,motivo AS Motivo_Rechazo,count(*) as Total_tx, sum(monto) as Monto_de_TX,transaccionorigen, vaniomes2 as periodo
			FROM intercard:movimientohistorico mvh, intercard:productotarjeta pro,intercard: tarjeta trj
			WHERE fechahorainauth BETWEEN primer_dia_mes_hora AND ultimo_dia_mes_hora  
			AND SUBSTR (mvh.numtarjeta,0,6) in  (SELECT bin FROM intercard:bines)
			AND prodind in ('02','01')
			AND esnacional in ('V','F')
			AND formato IN ('0200', '0220', '0221', '0420')
			AND SUBSTR (mvh.numtarjeta,0,6) in (SELECT bin FROM intercard:bines) --	Solo considerar los bines que están en InterCard:bines.
			AND movreversado = 'F'	--	No se contabilizan transacciones reversadas.
			AND metodocaptura is not null AND metodocaptura != ('null')	
			AND codigoiso != ('null')
		    and trj.numtarjeta = mvh.numtarjeta
            and trj.codproductotarjeta = pro.codproductotarjeta
			group by 1,2,3,4,5,6,7,8,11
			
    INTO temp paso  WITH NO LOG;

	----Se inserta los datos obtebidos en la tabla estadisticautorizacion
	
	SET ISOLATION to dirty read;
	INSERT INTO estadisticautorizacion 
	(bin,codproductotarjeta,codigoiso,prodind,esnacional,metodocaptura,descripcion,motivo_rechazo,numero_tx,monto_tx,transaccionorigen,periodo)
	SELECT * FROM intercard:paso;		
				SET ISOLATION TO dirty READ;
				INSERT INTO pasodatos 
				(bin,producto,codigoiso,metodocaptura,descripcion,numero_tx,monto_tx,transaccionorigen,periodo, motivo_rechazo)
				SELECT bin,codproductotarjeta,codigoiso,metodocaptura,descripcion,numero_tx,monto_tx,transaccionorigen,periodo, motivo_rechazo
				FROM intercard:estadisticautorizacion
				WHERE prodind = '02'
				AND   esnacional = 'V';
				
	 ---Genera Reporter de Transacciones POS NACIONAL -------------
            let vsql = ''; 	   
			let vsql = 'echo "|Bin  |ProdTarjeta|Código_ISO|Método de Captura|Descripción|Número_TX|Monto de Transacciones|Transacción_Origen|Motivo_Rechazo|">/resplogifx/RTX_BIN_POSNAC'|| vaniomes2 ||'.unl';
			system vsql;
			let vsql = '';
			let vsql = '';
			let vsql=  'echo "UNLOAD TO /resplogifx/RTX_BIN_POSNAC.unl SELECT bin,producto,codigoiso,metodocaptura,descripcion,numero_tx,monto_tx,transaccionorigen, motivo_rechazo FROM intercard:pasodatos where periodo = '|| vaniomes2 ||' order by bin;">/resplogifx/retx.sql'; 
			system vsql;
			let vsql ='';
			let vsql= 'dbaccess intercard /resplogifx/retx.sql';
			system vsql;
			let vsql = '';
			let vsql ='rm /resplogifx/retx.sql';
			system vsql;
			let vsql ='';
			let vsql = "sed 's/|$//g' /resplogifx/RTX_BIN_POSNAC.unl >>/resplogifx/RTX_BIN_POSNAC"||vaniomes2||".unl";
			system vsql;
			let vsql ='rm /resplogifx/RTX_BIN_POSNAC.unl';
			system vsql;
			
			TRUNCATE TABLE intercard:pasodatos;
			
			SET ISOLATION TO dirty READ;
				INSERT INTO pasodatos (bin,producto,codigoiso,metodocaptura,descripcion,monto_tx,numero_tx,transaccionorigen,periodo, motivo_rechazo)
				SELECT bin,codproductotarjeta,codigoiso,metodocaptura,descripcion,monto_tx,numero_tx,transaccionorigen,periodo, motivo_rechazo
				FROM intercard:estadisticautorizacion
				WHERE prodind = '02'
				AND   esnacional = 'F';
		
		  ---Genera Reporter de Transacciones POS INTERNACIONAL -------------
                 let vsql = ''; 	   
			let vsql = 'echo "|Bin  |ProdTarjeta|Código_ISO|Método de Captura|Descripción|Número_TX|Monto de Transacciones|Transacción_Origen|Motivo_Rechazo|">/resplogifx/RTX_BIN_POSINT'|| vaniomes2 ||'.unl';
			system vsql;
			let vsql = '';
			let vsql = '';
			let vsql=  'echo "UNLOAD TO /resplogifx/RTX_BIN_POSINT.unl SELECT bin,producto,codigoiso,metodocaptura,descripcion,numero_tx,monto_tx,transaccionorigen, motivo_rechazo FROM intercard:pasodatos where periodo = '|| vaniomes2 ||'order by bin;">/resplogifx/retx.sql'; 
			system vsql;
			let vsql ='';
			let vsql= 'dbaccess intercard /resplogifx/retx.sql';
			system vsql;
			let vsql = '';
			let vsql ='rm /resplogifx/retx.sql';
			system vsql;
			let vsql ='';
			let vsql = "sed 's/|$//g' /resplogifx/RTX_BIN_POSINT.unl >>/resplogifx/RTX_BIN_POSINT"||vaniomes2||".unl";
			system vsql;
			let vsql ='rm /resplogifx/RTX_BIN_POSINT.unl';
			system vsql;
			
            TRUNCATE TABLE intercard:pasodatos;
			
			SET ISOLATION TO dirty READ;
				INSERT INTO pasodatos (bin,producto,codigoiso,metodocaptura,descripcion,monto_tx,numero_tx,transaccionorigen,periodo, motivo_rechazo)
				SELECT bin,codproductotarjeta,codigoiso,metodocaptura,descripcion,monto_tx,numero_tx,transaccionorigen,periodo, motivo_rechazo
				FROM intercard:estadisticautorizacion
				WHERE prodind = '01'
				AND   esnacional = 'V';
		
		  ---Genera Reporter de Transacciones ATM NACIONAL -------------
                 let vsql = ''; 	   
			let vsql = 'echo "|Bin  |ProdTarjeta|Código_ISO|Método de Captura|Descripción|Número_TX|Monto de Transacciones|Transacción_Origen|Motivo_Rechazo|">/resplogifx/RTX_BIN_ATMNAC'|| vaniomes2 ||'.unl';
			system vsql;
			let vsql = '';
			let vsql = '';
			let vsql=  'echo "UNLOAD TO /resplogifx/RTX_BIN_ATMNAC.unl SELECT bin,producto,codigoiso,metodocaptura,descripcion,numero_tx,monto_tx,transaccionorigen, motivo_rechazo FROM intercard:pasodatos where periodo = '|| vaniomes2 ||'order by bin;">/resplogifx/retx.sql'; 
			system vsql;
			let vsql ='';
			let vsql= 'dbaccess intercard /resplogifx/retx.sql';
			system vsql;
			let vsql = '';
			let vsql ='rm /resplogifx/retx.sql';
			system vsql;
			let vsql ='';
			let vsql = "sed 's/|$//g' /resplogifx/RTX_BIN_ATMNAC.unl >>/resplogifx/RTX_BIN_ATMNAC"||vaniomes2||".unl";
			system vsql;
			let vsql ='rm /resplogifx/RTX_BIN_ATMNAC.unl';
			system vsql;
			
            TRUNCATE TABLE intercard:pasodatos;
			
				SET ISOLATION TO dirty READ;
				INSERT INTO pasodatos (bin,producto,codigoiso,metodocaptura,descripcion,monto_tx,numero_tx,transaccionorigen,periodo, motivo_rechazo)
				SELECT bin,codproductotarjeta,codigoiso,metodocaptura,descripcion,monto_tx,numero_tx,transaccionorigen,periodo, motivo_rechazo
				FROM intercard:estadisticautorizacion
				WHERE prodind = '01'
				AND   esnacional = 'F';
		
		  ---Genera Reporter de Transacciones ATM INTERNACIONAL -------------
            let vsql = '';
			let vsql = 'echo "|Bin  |ProdTarjeta|Código_ISO|Método de Captura|Descripción|Número_TX|Monto de Transacciones|Transacción_Origen|Motivo_Rechazo|">/resplogifx/RTX_BIN_ATMINT'|| vaniomes2 ||'.unl';
			system vsql;
			let vsql = '';
			let vsql = '';
			let vsql=  'echo "UNLOAD TO /resplogifx/RTX_BIN_ATMINT.unl SELECT bin,producto,codigoiso,metodocaptura,descripcion,numero_tx,monto_tx,transaccionorigen, motivo_rechazo FROM intercard:pasodatos where periodo = '|| vaniomes2 ||'order by bin;">/resplogifx/retx.sql'; 
			system vsql;
			let vsql ='';
			let vsql= 'dbaccess intercard /resplogifx/retx.sql';
			system vsql;
			let vsql = '';
			let vsql ='rm /resplogifx/retx.sql';
			system vsql;
			let vsql ='';
			let vsql = "sed 's/|$//g' /resplogifx/RTX_BIN_ATMINT.unl >>/resplogifx/RTX_BIN_ATMINT"||vaniomes2||".unl";
			system vsql;
			let vsql ='rm /resplogifx/RTX_BIN_ATMINT.unl';
			system vsql;
			
            TRUNCATE TABLE intercard:pasodatos;
		
			DROP TABLE intercard:pasodatos;
			DROP TABLE intercard:paso;

			--/////////////////////////////////  FIN DE EJECUCIÓN DE OPCIÓN MENSUAL ////////////////////////////////////////////////--

			
--///////////////////////////////// INICIO DE EJECUCIÓN DE OPCIÓN A PETICIÓN DE USUARIO////////////////////////////////////////////////--
		
  			
ELSE 
    IF  ( vindica = 'P' AND vindica is not null AND  vcodigoiso <> ''  AND vbin <> '' AND vprodind <> '' AND vmetodocaptura <> '' AND vesnacional <> '' AND vperiodo is not null ) THEN--3
	
	SET ISOLATION to dirty read;
    SELECT bin,creditodebito INTO vbin2, vcreditodebito  FROM intercard:bines WHERE bin = vbin;
    LET nrows = dbinfo("sqlca.sqlerrd2");
    IF(nrows = 0) THEN
      LET vcodret = '0005';
      LET  p_mensaje  = 'El BIN no existe';
	 return vcodret, p_mensaje;
    END IF;
     
		IF ( vcreditodebito = 'D') THEN--4
		
		CREATE TABLE informix.tx_debito( 
		numtarjeta             	  VARCHAR(16),
		codproductotarjeta        VARCHAR(3),
		descproducto       		  VARCHAR(60),
--	2015.08.05 - Se agrega campo 'NOMBRE COMERCIO' (infreceptor) al reporte.
		nombrecomercio    		  VARCHAR(40),
		fechahorainauthcred       DATETIME YEAR TO FRACTION(5),
		descripcion       		  VARCHAR(60),
		monto   		          DECIMAL(19,4),
		linea                     DECIMAL(19,4),
		codigoiso    		      VARCHAR(2),
		motivorechazo             VARCHAR(100),
		transaccionorigen         VARCHAR(4)
		)EXTENT SIZE 120 NEXT SIZE 120 LOCK MODE ROW;
		
--Consulta para descarga de débito, se toma en cuenta casos de compras POS con formato 200, reversos con 420 y forzadas 220
		SET ISOLATION to dirty read; 
		SELECT {+INDEX(intercard:movimientohistorico idx_movimiento3)} {+INDEX(intercard:movimientohistorico idx_movimiento1)} {+INDEX(intercard:tarjeta 144_89 )} {+INDEX(intercard:tarjetacuenta 128_56 )} 
--	2015.08.05 - Se agrega campo 'NOMBRE COMERCIO' (infreceptor) al reporte.
			numtarjeta,codproductotarjeta,descproducto,infreceptor,fechahorainauth,metodocaptura, tipotransaccionposdigitada, monto,codigoiso,motivorechazo,transaccionorigen,nvl((capvigacum)/saldo,0) AS linea
				from table (multiset ( select sdo.capvigacum as capvigacum, nvl(case when sdo.diacum = 0 then 1 else sdo.diacum end,1) as saldo, movh.numtarjeta as numtarjeta,tar.codproductotarjeta as codproductotarjeta,pro.descproducto as descproducto, movh.infreceptor as infreceptor, movh.fechahorainauth as fechahorainauth,movh.metodocaptura as metodocaptura,movh.tipotransaccionposdigitada as tipotransaccionposdigitada, movh.monto AS monto,movh.codigoiso AS codigoiso,movh.motivo AS motivorechazo,movh.transaccionorigen AS transaccionorigen
						FROM intercard:movimientohistorico as movh,intercard:productotarjeta pro,intercard:tarjeta tar,bdicheq:sc_sdodiarioc sdo,intercard:tarjetacuenta tc 
							WHERE movh.fechahorainauth  BETWEEN pperiodini_hora AND  pperiodofin_hora
							AND SUBSTR (movh.numtarjeta,0,6) in  (select bin FROM intercard:bines where bin = vbin)
							AND codigoiso =  vcodigoiso
							AND metodocaptura = vmetodocaptura
							AND formato IN ('0200', '0220', '0221', '0420')
							AND SUBSTR (movh.numtarjeta,0,6) in (SELECT bin FROM intercard:bines) --	Solo considerar los bines que están en InterCard:bines.
							AND movreversado = 'F'	--	No se contabilizan transacciones reversadas.
							AND prodind = vprodind
							AND esnacional = vesnacional
							AND tar.numtarjeta = movh.numtarjeta 
							AND pro.codproductotarjeta = tar.codproductotarjeta 
							AND sdo.aniomes = vperiodo 
							AND tc.numtarjeta = tar.numtarjeta 
							AND tc.numcuenta = sdo.cuenta ))
						
		UNION ALL
      
		SELECT  {+INDEX(intercard:movimiento idx_fechahorainauth)} {+INDEX(intercard:movimiento idx_movimientonew1a)} {+INDEX(intercard:tarjeta 144_89 )} {+INDEX(intercard:tarjetacuenta 128_56 )} 
--	2015.08.05 - Se agrega campo 'NOMBRE COMERCIO' (infreceptor) al reporte.
			numtarjeta,codproductotarjeta,descproducto,infreceptor,fechahorainauth,metodocaptura, tipotransaccionposdigitada, monto,codigoiso,motivorechazo,transaccionorigen,nvl((capvigacum)/saldo,0) AS linea
				from table (multiset ( select sdo.capvigacum as capvigacum, nvl(case when sdo.diacum = 0 then 1 else sdo.diacum end,1) as saldo, mov.numtarjeta as numtarjeta,tar.codproductotarjeta as codproductotarjeta,pro.descproducto as descproducto, mov.infreceptor as infreceptor, mov.fechahorainauth as fechahorainauth,mov.metodocaptura as metodocaptura,mov.tipotransaccionposdigitada as tipotransaccionposdigitada, mov.monto AS monto,mov.codigoiso AS codigoiso,mov.motivo AS motivorechazo,mov.transaccionorigen AS transaccionorigen
						FROM intercard:movimiento as mov,intercard:productotarjeta pro,intercard:tarjeta tar,bdicheq:sc_sdodiarioc sdo,intercard:tarjetacuenta tc 
							WHERE mov.fechahorainauth  BETWEEN pperiodini_hora AND  pperiodofin_hora
							AND SUBSTR (mov.numtarjeta,0,6) in  (select bin FROM intercard:bines where bin = vbin)
							AND codigoiso =  vcodigoiso
							AND metodocaptura = vmetodocaptura
							AND formato IN ('0200', '0220', '0221', '0420')
							AND SUBSTR (mov.numtarjeta,0,6) in (SELECT bin FROM intercard:bines) --	Solo considerar los bines que están en InterCard:bines.
							AND movreversado = 'F'	--	No se contabilizan transacciones reversadas.
							AND prodind = vprodind
							AND esnacional = vesnacional
							AND tar.numtarjeta = mov.numtarjeta 
							AND pro.codproductotarjeta = tar.codproductotarjeta 
							AND sdo.aniomes = vperiodo 
							AND tc.numtarjeta = tar.numtarjeta 
							AND tc.numcuenta = sdo.cuenta ))	
							
			INTO  temp pasodebito WITH NO LOG;
			
			SET ISOLATION to dirty read; 
--	2015.08.05 - Se agrega campo 'NOMBRE COMERCIO' (infreceptor) al reporte.
			SELECT pd.numtarjeta,pd.codproductotarjeta,pd.descproducto,pd.infreceptor,pd.fechahorainauth,
       
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
--	2015.06.30 - FRG - Se agregan Métodos de Captura.
 				 WHEN metodocaptura = '81'  THEN "Ecomerce MasterCard"
				 WHEN metodocaptura = '80'  THEN "FallBack"
				 WHEN metodocaptura = '92'  THEN "Contactless"
				 WHEN metodocaptura IN ('00','02') THEN "Metodos Captura No Determinados"
		ELSE "NULL"
			END AS Descripcion,pd.monto,pd.linea,pd.codigoiso,pd.motivorechazo,pd.transaccionorigen
		from intercard:pasodebito pd
		
		INTO  temp pasodebitodos WITH NO LOG;
		
			
		SET isolation to dirty read;
--	2015.08.05 - Se agrega campo 'NOMBRE COMERCIO' (infreceptor) al reporte.
	    INSERT INTO tx_debito (numtarjeta,codproductotarjeta,descproducto,nombrecomercio,fechahorainauthcred,Descripcion,monto,linea,codigoiso,motivorechazo,transaccionorigen)
        SELECT * FROM intercard:pasodebitodos;
		
		   --8)Generación del segundo reporte a detalle por la causa de rechazo código ISO 61 y 65
		    let vsql = ''; 
--	2015.08.05 - Se agrega campo 'NOMBRE COMERCIO' (infreceptor) al reporte.
			let vsql = 'echo "|Tarjeta|Producto|Descripción|Nombre Comercio|Fecha Transacción|Método_Captura|Monto de Compra|Línea Crédito/Débito|Código_ISO|Descripción_ISO|Transacción_Origen|">/resplogifx/RTX_BIN_DEB_'|| vaniomes2 ||'.unl';
			system vsql;
			let vsql = '';
			let vsql = '';
			let vsql=  'echo "UNLOAD TO /resplogifx/RTX_BIN_DEB_.unl SELECT * FROM tx_debito;">/resplogifx/retxcred.sql'; 
			system vsql;
			let vsql ='';
			let vsql= 'dbaccess intercard /resplogifx/retxcred.sql';
			system vsql;
			let vsql = '';
			let vsql ='rm /resplogifx/retxcred.sql';
			system vsql;
			let vsql ='';
			let vsql = "sed 's/|$//g' /resplogifx/RTX_BIN_DEB_.unl >>/resplogifx/RTX_BIN_DEB_"||vaniomes2||".unl";
			system vsql;
			let vsql ='rm /resplogifx/RTX_BIN_DEB_.unl';
			system vsql;
			
			DROP TABLE pasodebitodos;
		    DROP TABLE pasodebito;
			DROP TABLE tx_debito;
			
			
		ELSE IF ( vcreditodebito = 'C')	THEN--5		

        CREATE TABLE informix.tx_credito( 
		numtarjeta             	  VARCHAR(16),
		codproductotarjeta        VARCHAR(3),
		descproducto       		  VARCHAR(60),
--	2015.08.05 - Se agrega campo 'NOMBRE COMERCIO' (infreceptor) al reporte.
		nombrecomercio    		  VARCHAR(40),
		fechahorainauthcred     	  DATETIME YEAR TO FRACTION(5),
		descripcion       		  VARCHAR(60),
		monto   		          DECIMAL(19,4),
		linea                     DECIMAL(19,4),
		codigoiso    		      VARCHAR(2),
		motivorechazo             VARCHAR(100),
		transaccionorigen         VARCHAR(4)
		)EXTENT SIZE 120 NEXT SIZE 120 LOCK MODE ROW;
   
	   --Consulta para la descarga de crédito, se toma en cuenta casos de compras POS con formato 200, reversos con 420 y forzadas 220
	   
	    SET isolation to dirty read;
	    SELECT  {+INDEX(intercard:movimientohistorico idx_movimiento3)} {+INDEX(intercard:movimientohistorico idx_movimiento1)} {+INDEX(intercard:tarjeta 144_89 )} {+INDEX(intercard:tarjetacuenta 128_56 )} 			
--	2015.08.05 - Se agrega campo 'NOMBRE COMERCIO' (infreceptor) al reporte.
				movh.numtarjeta,tar.codproductotarjeta,pro.descproducto,movh.infreceptor,movh.fechahorainauth AS fechahorainauthcred,movh.metodocaptura,movh.tipotransaccionposdigitada,
                movh.monto AS monto ,sdm.monto_otorgado AS lineaC,movh.codigoiso,movh.motivo AS motivorechazo,movh.transaccionorigen AS transaccionorigen
                        FROM  intercard:movimientohistorico movh,intercard:productotarjeta pro,intercard:tarjeta tar,
                               intercard:tarjetacuenta tc,bdicred:sd_maesdos sdm
								WHERE movh.fechahorainauth  BETWEEN pperiodini_hora AND  pperiodofin_hora
								AND   SUBSTR (movh.numtarjeta,0,6) in  (select bin FROM intercard:bines where bin = vbin)
								AND   codigoiso =  vcodigoiso
								AND   movh.metodocaptura = vmetodocaptura
								AND   formato IN ('0200', '0220', '0221', '0420')
								AND   SUBSTR (movh.numtarjeta,0,6) in (SELECT bin FROM intercard:bines) --	Solo considerar los bines que están en InterCard:bines.								
								AND   movreversado = 'F'	--	No se contabilizan transacciones reversadas.
								AND   prodind = vprodind
								AND   esnacional = vesnacional
								AND   pro.codproductotarjeta = tar.codproductotarjeta
								AND   tar.numtarjeta = movh.numtarjeta
								AND   tc.numtarjeta = tar.numtarjeta
								AND   sdm.num_credito = tc.numcuenta
		
		UNION ALL

	    SELECT  {+INDEX(intercard:movimiento idx_fechahorainauth)} {+INDEX(intercard:movimiento idx_movimientonew1a)} {+INDEX(intercard:tarjeta 144_89 )} {+INDEX(intercard:tarjetacuenta 128_56 )} 
--	2015.08.05 - Se agrega campo 'NOMBRE COMERCIO' (infreceptor) al reporte.
				mov.numtarjeta,tar.codproductotarjeta,pro.descproducto,mov.infreceptor,mov.fechahorainauth AS fechahorainauthcred,mov.metodocaptura,mov.tipotransaccionposdigitada,
                mov.monto AS monto ,sdm.monto_otorgado AS lineaC,mov.codigoiso,mov.motivo AS motivorechazo,mov.transaccionorigen AS transaccionorigen
                          FROM  intercard:movimiento mov,intercard:productotarjeta pro,intercard:tarjeta tar,
                           intercard:tarjetacuenta tc,bdicred:sd_maesdos sdm
								WHERE mov.fechahorainauth  BETWEEN pperiodini_hora AND  pperiodofin_hora
								AND   SUBSTR (mov.numtarjeta,0,6) in  (select bin FROM intercard:bines where bin = vbin)
								AND   codigoiso =  vcodigoiso
								AND   mov.metodocaptura = vmetodocaptura
								AND   formato IN ('0200', '0220', '0221', '0420')
								AND   SUBSTR (mov.numtarjeta,0,6) in (SELECT bin FROM intercard:bines) --	Solo considerar los bines que están en InterCard:bines.
								AND   movreversado = 'F'	--	No se contabilizan transacciones reversadas.
								AND   prodind = vprodind
								AND   esnacional = vesnacional 
								AND   pro.codproductotarjeta = tar.codproductotarjeta
								AND   tar.numtarjeta = mov.numtarjeta
								AND   tc.numtarjeta = tar.numtarjeta
								AND   sdm.num_credito = tc.numcuenta
		
		INTO  temp pasocredito WITH NO LOG;
		
		SET isolation to dirty read;
--	2015.08.05 - Se agrega campo 'NOMBRE COMERCIO' (infreceptor) al reporte.
		select pc.numtarjeta,pc.codproductotarjeta,pc.descproducto,pc.infreceptor,pc.fechahorainauthcred,
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
			END AS Descripcion,pc.monto,pc.lineaC,pc.codigoiso,pc.motivorechazo,pc.transaccionorigen
		from intercard:pasocredito pc
		
		INTO  temp pasocreditodos WITH NO LOG;
		
		SET isolation to dirty read;
--	2015.08.05 - Se agrega campo 'NOMBRE COMERCIO' (infreceptor) al reporte.
	    INSERT INTO tx_credito (numtarjeta,codproductotarjeta,descproducto,nombrecomercio,fechahorainauthcred,Descripcion,monto,linea,codigoiso,motivorechazo,transaccionorigen)
        SELECT * FROM intercard:pasocreditodos;
	
	    --8)Generación del segundo reporte a detalle por la causa de rechazo código ISO 61 y 65
		    let vsql = ''; 	   
--	2015.08.05 - Se agrega campo 'NOMBRE COMERCIO' (infreceptor) al reporte.
			let vsql = 'echo "|Tarjeta|Producto|Descripción|Nombre Comercio|Fecha Transacción|Método_Captura|Monto de Compra|Línea Crédito/Débito|Código_ISO|Descripción_ISO|Transacción_Origen|">/resplogifx/RTX_BIN_CRED_'|| vaniomes2 ||'.unl';
			system vsql;
			let vsql = '';
			let vsql = '';
			let vsql=  'echo "UNLOAD TO /resplogifx/RTX_BIN_CRED_.unl SELECT * FROM tx_credito;">/resplogifx/retxcred.sql'; 
			system vsql;
			let vsql ='';
			let vsql= 'dbaccess intercard /resplogifx/retxcred.sql';
			system vsql;
			let vsql = '';
			let vsql ='rm /resplogifx/retxcred.sql';
			system vsql;
			let vsql ='';
			let vsql = "sed 's/|$//g' /resplogifx/RTX_BIN_CRED_.unl >>/resplogifx/RTX_BIN_CRED_"||vaniomes2||".unl";
			system vsql;
			let vsql ='rm /resplogifx/RTX_BIN_CRED_.unl';
			system vsql;
			
			 DROP TABLE pasocreditodos;
		     DROP TABLE pasocredito;
		     DROP TABLE tx_credito;
         END IF;  		
       END IF; 	
	ELSE
    LET vcodret = '0002';
    LET  p_mensaje  = 'Hay valores nulos.';
    return vcodret, p_mensaje;
	    
  
     END IF; 
	END IF; 
		
				 			
        LET vcodret = '00000';
		LET  p_mensaje  = 'Reporte Generado ';
		return vcodret, p_mensaje;
		  

	 	else
      LET vcodret = '0005';
      LET  p_mensaje  = 'Se debe ejecutar los dias 5 de cada mes ';
     return vcodret, p_mensaje;
	
 END IF;	
END IF; 
END;
end procedure
/*
2015.06.26 - Se agregan los campos 'motivo_rechazo' y 'producto' para los reportes.
2015.06.30 - Se agrega el parámetro de entrada 'Método de Captura' para los reportes Tipo 'P'.
2015.08.05 - Se agrega campo 'NOMBRE COMERCIO' (infreceptor) al reporte (petición usuario).
Solicitud: RQM 10 640 - Mejoras a reporte de aceptacion.
Autor: FRG
BD: intercard
*/
;

CREATE PROCEDURE "informix".sp_calcula_caratulaproducto_pba()
RETURNING 	char (5) AS COD_RET,
			char(150) AS MENSAJE;
			  

			  
---variables de control de errores
 
DEFINE	iSqlErr 		INTEGER;
DEFINE	iIsamErr		INTEGER;
DEFINE	vErrorInfo		VARCHAR(80);
DEFINE  CVarDataErr      CHAR(150);
DEFINE  CCodret          CHAR(5);
DEFINE  CMENSAJE		 CHAR(150);

DEFINE	vpaso			INTEGER;
			  
--Variables

DEFINE Vsumamis decimal(19,4);
DEFINE vsumasus decimal(19,4);
DEFINE vsumatotal decimal(19,4);

--VARIABLES DE TOTALES

DEFINE vmonto_retiro_bd decimal(19,4);
DEFINE vmonto_retiro_bc decimal(19,4);
DEFINE vmonto_retiro_od decimal(19,4);
DEFINE vmonto_retiro_oc decimal(19,4);
DEFINE vmaest decimal(19,4);


--VARIABLES DE FECHA
DEFINE vfecharep DATE;
DEFINE vfecha_hoy DATE;
DEFINE vano	varchar (4);
DEFINE vano2 varchar (4);
DEFINE vmes	varchar (2);
DEFINE vdia varchar (2);
DEFINE vdma varchar (8);
DEFINE vdmar varchar (10);
DEFINE vfecharep_ini	DATETIME YEAR TO FRACTION(5);
DEFINE vfecharep_fin	DATETIME YEAR TO FRACTION(5);


---VARIABLES DE ARCHIVO

DEFINE vNombreArchivo	VARCHAR (50);
DEFINE vsql 			CHAR (2404);


	--SET DEBUG FILE TO "/informix/analy/sp_calcula_caratulaproducto.out";
	--TRACE ON; 
	

BEGIN
		
		ON EXCEPTION SET iSqlErr, iIsamErr, vErrorInfo
		IF iSqlErr <> 0 OR iIsamErr <> 0 THEN
				LET CCodret = iSqlErr;
				LET CMENSAJE = vErrorInfo;			
				RETURN cCodret, 'iIsamErr: '|| iIsamErr  || ' EN PASO: ' || vpaso|| ' ERR_DES ' || CMENSAJE ;
			END IF;
		END EXCEPTION;
		

	---INICIALIZANDO VARIABLES
	
	let vfecharep ='';
	let vfecha_hoy = '';
	
	let vsumamis = 0;
	let vsumasus = 0;
	let vsumatotal = 0;

	let vmonto_retiro_bd = 0;
	let vmonto_retiro_bc = 0;
	let vmonto_retiro_od = 0;
	let vmonto_retiro_oc = 0;
	let vmaest = 0;
	
	
	/*----------CALCULA LA FECHA DEL REPORTE----------------*/

	SET ISOLATION TO DIRTY READ;
	SELECT fecha_hoy INTO vfecha_hoy FROM  bdinteg:si_fechas; 
	
	let vfecharep = vfecha_hoy-1; -->>Fecha de datos (no de la conciliación)

	--Fechas para el campo fechaconciliacion--
	
    let vfecharep_ini = vfecha_hoy;
    let vfecharep_ini= SUBSTRING(vfecharep_ini FROM  1 FOR 10) || ' 00:00:00';	
		
	let vfecharep_fin = vfecha_hoy;
    let vfecharep_fin = SUBSTRING(vfecharep_fin FROM  1 FOR 10) || ' 23:59:59';
	
	let vano = YEAR(vfecharep);
	let vmes = LPAD(MONTH(vfecharep), 2,"0");
	let vdia = LPAD(DAY (vfecharep),2,"0");
	let vdma = vdia||vmes||vano;
	let vdmar = vdia||'-'||vmes||'-'||vano;

	
	/*----------VALIDA QUE EXISTA INFORMACIÓN DEL DÍA DENTRO DEL STAT06----------------*/
	
	if (not exists(select fechaconciliacion from intercard:conciliacion_atm_stat06 where cast(fechaconciliacion as date) = vfecha_hoy)) THEN
		let cCodret = '00011';
		let CVarDataErr = 'NO EXISTE INFORMACIÓN DEL DIA EN LA TABLA DE STAT06';
		RETURN cCodret,CVarDataErr;
	END IF;
	
	/*----------VALIDA QUE NO EXISTA INFORMACIÓN DEL DÍA, DENTRO DE LA TABLA DE TOTALES----------------*/
	
	if ( exists(select fechaconciliacion from intercard:caratula_producto where cast(fechaconciliacion as date) = vfecha_hoy)) THEN
		let cCodret = '00012';
		let CVarDataErr = 'YA EXISTE INFORMACIÓN DEL DIA EN LA TABLA "CARATULA_PRODUCTO"';
		RETURN cCodret,CVarDataErr;
	END IF;
	
	/*----------VALIDA QUE NO EXISTA INFORMACIÓN DEL DÍA, DENTRO DE LA TABLA DE TOTALES 2----------------*/
	
	if ( exists(select fechaconciliacion from intercard:caratula_producto_totales where cast(fechaconciliacion as date) = vfecha_hoy)) THEN
		let cCodret = '00013';
		let CVarDataErr = 'YA EXISTE INFORMACIÓN DEL DIA EN LA TABLA "CARATULA_PRODUCTO_TOTALES"';
		RETURN cCodret,CVarDataErr;
	END IF;

	
/*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::Reporte de caratula por producto::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::se calcula la sumatoria del importe de transacciones exitosas en cajeros propios::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/
	
	/*:::tipooperacion 1= MIS EN MIS, 2= SUS EN MIS::*/

	/*SE CALCULA LA SUMA DE LAS CONSULTAS Y RETIROS DE ATM CON TARJETA DÉBITO BANCOPPEL*/
	let vpaso= 1;
	
	SET ISOLATION TO dirty READ;
	INSERT INTO intercard:caratula_producto(fecha, fechaconciliacion, tipooperacion, tipoproducto, monto_consulta, comi_consulta, numtran_consulta,
											monto_retiro, comi_retiro, numtran_retiro, monto_reverso, numtran_reverso, monto_reverso_p, numtran_reverso_p)
	SELECT fecha, fechaconciliacion, '1', 'D',
				   SUM(monto_consulta) AS monto_consulta, SUM(comi_consulta) AS comi_consulta, SUM(numtran_consulta) AS numtran_consulta,
				   SUM(monto_retiro) AS monto_retiro, SUM(comi_retiro) AS comi_retiro, SUM(numtran_retiro) AS numtran_retiro,
				   SUM(monto_rev) AS monto_rev, SUM(numtran_rev) AS numtran_rev,
				   SUM(monto_revp) AS monto_revp, SUM(numtran_revp) AS numtran_revp
	FROM
	TABLE(MULTISET(
	SELECT fecha, fechaconciliacion,
		CASE WHEN descripcion like 'CONSULTA%' THEN SUM(monto) ELSE 0 END AS monto_consulta,
		CASE WHEN descripcion like 'CONSULTA%' THEN SUM(comisionsurcharge) ELSE 0 END AS comi_consulta,
		CASE WHEN descripcion like 'CONSULTA%' THEN COUNT(*) ELSE 0 END AS numtran_consulta,
		CASE WHEN descripcion like 'RETIRO%' AND indicadordereversa = '' THEN SUM(monto) ELSE 0 END AS monto_retiro,
		CASE WHEN descripcion like 'RETIRO%' AND indicadordereversa = '' THEN SUM(comisionsurcharge) ELSE 0 END AS comi_retiro,
		CASE WHEN descripcion like 'RETIRO%' AND indicadordereversa = '' THEN COUNT (*) ELSE 0 END AS numtran_retiro,
		CASE WHEN descripcion like 'RETIRO%' AND trim(indicadordereversa)= 'REVERSAL' THEN SUM(monto) ELSE 0 END AS monto_rev,
		CASE WHEN descripcion like 'RETIRO%' AND trim(indicadordereversa)= 'REVERSAL' THEN COUNT (*) ELSE 0 END AS numtran_rev,
		CASE WHEN descripcion like 'RETIRO%' AND trim(indicadordereversa)= 'REVERSAL          P' THEN SUM(monto) ELSE 0 END AS monto_revp,
		CASE WHEN descripcion like 'RETIRO%' AND trim(indicadordereversa)= 'REVERSAL          P' THEN COUNT(*) ELSE 0 END AS numtran_revp
	FROM intercard:conciliacion_atm_stat06
	WHERE fechaconciliacion BETWEEN vfecharep_ini AND vfecharep_fin
	--WHERE fechaconciliacion BETWEEN '2016-08-28 00:00:00' AND '2016-08-28 23:59:59'
	AND codigoiso in ('00')     
	AND compania IN ('VDE','MDE') --> valida que sean bines Bancoppel
	AND archivoorigen='IST'
	GROUP BY fecha, fechaconciliacion, descripcion, indicadordereversa))
	GROUP BY 1,2;
	
	
	/*SE CALCULA EL MONTO DE LAS CONSULTAS Y RETIROS DE ATM CON TARJETA CRÉDITO BANCOPPEL*/
	let vpaso= 2;

	SET ISOLATION TO dirty READ;
	INSERT INTO intercard:caratula_producto(fecha, fechaconciliacion, tipooperacion, tipoproducto, monto_consulta, comi_consulta, numtran_consulta,
												monto_retiro, comi_retiro, numtran_retiro, monto_reverso, numtran_reverso, monto_reverso_p, numtran_reverso_p)
	SELECT fecha, fechaconciliacion,'1', 'C',
		   SUM(monto_consulta) AS monto_consulta, SUM(comi_consulta) AS comi_consulta, SUM(numtran_consulta) AS numtran_consulta, 
		   SUM(monto_retiro) AS monto_retiro, SUM(comi_retiro) AS comi_retiro, SUM(numtran_retiro) AS numtran_retiro, 
		   SUM(monto_rev) AS monto_rev, SUM(numtran_rev) AS numtran_rev,
		   SUM(monto_revp) AS monto_revp, SUM(numtran_revp) AS numtran_revp
	FROM 
	TABLE(MULTISET(
	SELECT fecha, fechaconciliacion,
		CASE WHEN descripcion like 'CONSULTA%' THEN SUM(monto) ELSE 0 END AS monto_consulta,
		CASE WHEN descripcion like 'CONSULTA%' THEN SUM(comisionsurcharge) ELSE 0 END AS comi_consulta,
		CASE WHEN descripcion like 'CONSULTA%' THEN COUNT(*) ELSE 0 END AS numtran_consulta,
		CASE WHEN descripcion like 'RETIRO%' AND indicadordereversa = '' THEN SUM(monto) ELSE 0 END AS monto_retiro,
		CASE WHEN descripcion like 'RETIRO%' AND indicadordereversa = '' THEN SUM(comisionsurcharge) ELSE 0 END AS comi_retiro,
		CASE WHEN descripcion like 'RETIRO%' AND indicadordereversa = '' THEN COUNT (*) ELSE 0 END AS numtran_retiro,
		CASE WHEN descripcion like 'RETIRO%' AND trim(indicadordereversa)= 'REVERSAL' THEN SUM(monto) ELSE 0 END AS monto_rev,
		CASE WHEN descripcion like 'RETIRO%' AND trim(indicadordereversa)= 'REVERSAL' THEN COUNT (*) ELSE 0 END AS numtran_rev,
		CASE WHEN descripcion like 'RETIRO%' AND trim(indicadordereversa)= 'REVERSAL          P' THEN SUM(monto) ELSE 0 END AS monto_revp,
		CASE WHEN descripcion like 'RETIRO%' AND trim(indicadordereversa)= 'REVERSAL          P' THEN COUNT(*) ELSE 0 END AS numtran_revp
	FROM intercard:conciliacion_atm_stat06
	WHERE fechaconciliacion BETWEEN vfecharep_ini AND vfecharep_fin
	--WHERE fechaconciliacion BETWEEN '2016-08-22 00:00:00' AND '2016-08-22 23:00:00'
	AND codigoiso = '00'
	AND compania IN ('VCR','MCR')	--> valida que sean bines Bancoppel
	AND archivoorigen='IST'
	GROUP BY fecha, fechaconciliacion, descripcion, indicadordereversa))
	GROUP BY 1,2;
	
	
 /*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
 ::::::::::::::::::::::::::::::OTROS BANCOS::::::::::::::::::::::::::::::::::::
 :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/
	
	/*SE CALCULA LA SUMA DEL MONTO DE CONSULTAS Y RETIROS DE ATM CON TARJETA DE DÉBITO DE OTROS BANCOS*/
	let vpaso= 3;
	
	SET ISOLATION TO dirty READ;
	INSERT INTO intercard:caratula_producto(fecha, fechaconciliacion, tipooperacion, tipoproducto, monto_consulta, comi_consulta, numtran_consulta,
											monto_retiro, comi_retiro, numtran_retiro, monto_reverso, numtran_reverso, monto_reverso_p, numtran_reverso_p)
	SELECT fecha, fechaconciliacion, '2', 'D',
	   SUM(monto_consulta+monto_consultam) AS monto_consulta, SUM(comi_consulta+comi_consultam) AS comi_consulta, SUM(numtran_consulta+numtran_consultam) AS numtran_consulta,
	   SUM(monto_retiro+monto_retirom) AS monto_retiro, SUM(comi_retiro+comi_retirom) AS comi_retiro, SUM(numtran_retiro+numtran_retirom) AS numtran_retiro,
	   SUM(monto_rev+monto_revm) AS monto_rev, SUM(numtran_rev+numtran_revm) AS numtran_rev,
	   SUM(monto_revp+monto_revpm) AS monto_revp, SUM(numtran_revpm) AS numtran_revp
	FROM
	TABLE(MULTISET(
	SELECT fecha, fechaconciliacion,
		CASE WHEN descripcion ='CONSULTA CHEQUE' THEN SUM(monto) ELSE 0 END AS monto_consulta,
		CASE WHEN descripcion ='CONSULTA CHEQUE' THEN SUM(comisionsurcharge) ELSE 0 END AS comi_consulta,
		CASE WHEN descripcion ='CONSULTA CHEQUE' THEN COUNT(*) ELSE 0 END AS numtran_consulta,
		CASE WHEN descripcion ='RETIRO   CHEQUE' AND indicadordereversa = '' THEN SUM(monto) ELSE 0 END AS monto_retiro,
		CASE WHEN descripcion ='RETIRO   CHEQUE' AND indicadordereversa = '' THEN SUM(comisionsurcharge) ELSE 0 END AS comi_retiro,
		CASE WHEN descripcion ='RETIRO   CHEQUE' AND indicadordereversa = '' THEN COUNT (*) ELSE 0 END AS numtran_retiro,
		CASE WHEN descripcion ='RETIRO   CHEQUE' AND trim(indicadordereversa)= 'REVERSAL' THEN SUM(monto) ELSE 0 END AS monto_rev,
		CASE WHEN descripcion ='RETIRO   CHEQUE' AND trim(indicadordereversa)= 'REVERSAL' THEN COUNT (*) ELSE 0 END AS numtran_rev,
		CASE WHEN descripcion ='RETIRO   CHEQUE' AND trim(indicadordereversa)= 'REVERSAL          P' THEN SUM(monto) ELSE 0 END AS monto_revp,
		CASE WHEN descripcion ='RETIRO   CHEQUE' AND trim(indicadordereversa)= 'REVERSAL          P' THEN COUNT(*) ELSE 0 END AS numtran_revp,
			CASE WHEN descripcion ='CONSULTA MAESTR' THEN SUM(monto) ELSE 0 END AS monto_consultam,
			CASE WHEN descripcion ='CONSULTA MAESTR' THEN SUM(comisionsurcharge) ELSE 0 END AS comi_consultam,
			CASE WHEN descripcion ='CONSULTA MAESTR' THEN COUNT(*) ELSE 0 END AS numtran_consultam,
			CASE WHEN descripcion ='RETIRO   MAESTR' AND indicadordereversa = '' THEN SUM(monto) ELSE 0 END AS monto_retirom,
			CASE WHEN descripcion ='RETIRO   MAESTR' AND indicadordereversa = '' THEN SUM(comisionsurcharge) ELSE 0 END AS comi_retirom,
			CASE WHEN descripcion ='RETIRO   MAESTR' AND indicadordereversa = '' THEN COUNT (*) ELSE 0 END AS numtran_retirom,
			CASE WHEN descripcion ='RETIRO   MAESTR' AND trim(indicadordereversa)= 'REVERSAL' THEN SUM(monto) ELSE 0 END AS monto_revm,
			CASE WHEN descripcion ='RETIRO   MAESTR' AND trim(indicadordereversa)= 'REVERSAL' THEN COUNT (*) ELSE 0 END AS numtran_revm,
			CASE WHEN descripcion ='RETIRO   MAESTR' AND trim(indicadordereversa)= 'REVERSAL          P' THEN SUM(monto) ELSE 0 END AS monto_revpm,
			CASE WHEN descripcion ='RETIRO   MAESTR' AND trim(indicadordereversa)= 'REVERSAL          P' THEN COUNT(*) ELSE 0 END AS numtran_revpm
	FROM intercard:conciliacion_atm_stat06
	WHERE fechaconciliacion BETWEEN vfecharep_ini AND vfecharep_fin
	--WHERE fechaconciliacion BETWEEN '2016-08-28 00:00:00' AND '2016-08-28 23:59:59'
	AND codigoiso IN ('00','01')
	AND archivoorigen='IST'
	AND compania IN ('BNI')      --> valida que sean bines de otros bancos
	GROUP BY fecha, fechaconciliacion, descripcion, indicadordereversa))
	GROUP BY 1,2;

	
	/*SE CALCULA LA SUMA DEL MONTO DE CONSULTAS Y RETIROS DE ATM CON TARJETA DE CRÉDITO DE OTROS BANCOS*/
	let vpaso= 4;

	SET ISOLATION TO dirty READ;
	INSERT INTO intercard:caratula_producto(fecha, fechaconciliacion, tipooperacion, tipoproducto, monto_consulta, comi_consulta, numtran_consulta,
												monto_retiro, comi_retiro, numtran_retiro, monto_reverso, numtran_reverso, monto_reverso_p, numtran_reverso_p)
	SELECT fecha, fechaconciliacion,'2', 'C',
		   SUM(monto_consulta) AS monto_consulta, SUM(comi_consulta) AS comi_consulta, SUM(numtran_consulta) AS numtran_consulta, 
		   SUM(monto_retiro) AS monto_retiro, SUM(comi_retiro) AS comi_retiro, SUM(numtran_retiro) AS numtran_retiro, 
		   SUM(monto_rev) AS monto_rev, SUM(numtran_rev) AS numtran_rev,
		   SUM(monto_revp) AS monto_revp, SUM(numtran_revp) AS numtran_revp
	FROM 
	TABLE(MULTISET(
	SELECT fecha, fechaconciliacion,
		CASE WHEN descripcion ='CONSULTA CREDIT' THEN SUM(monto) ELSE 0 END AS monto_consulta,
		CASE WHEN descripcion ='CONSULTA CREDIT' THEN SUM(comisionsurcharge) ELSE 0 END AS comi_consulta,
		CASE WHEN descripcion ='CONSULTA CREDIT' THEN COUNT(*) ELSE 0 END AS numtran_consulta,
		CASE WHEN descripcion ='RETIRO   CREDIT' AND indicadordereversa = '' THEN SUM(monto) ELSE 0 END AS monto_retiro,
		CASE WHEN descripcion ='RETIRO   CREDIT' AND indicadordereversa = '' THEN SUM(comisionsurcharge) ELSE 0 END AS comi_retiro,
		CASE WHEN descripcion ='RETIRO   CREDIT' AND indicadordereversa = '' THEN COUNT (*) ELSE 0 END AS numtran_retiro,
		CASE WHEN descripcion ='RETIRO   CREDIT' AND trim(indicadordereversa)= 'REVERSAL' THEN SUM(monto) ELSE 0 END AS monto_rev,
		CASE WHEN descripcion ='RETIRO   CREDIT' AND trim(indicadordereversa)= 'REVERSAL' THEN COUNT (*) ELSE 0 END AS numtran_rev,
		CASE WHEN descripcion ='RETIRO   CREDIT' AND trim(indicadordereversa)= 'REVERSAL          P' THEN SUM(monto) ELSE 0 END AS monto_revp,
		CASE WHEN descripcion ='RETIRO   CREDIT' AND trim(indicadordereversa)= 'REVERSAL          P' THEN COUNT(*) ELSE 0 END AS numtran_revp
	FROM intercard:conciliacion_atm_stat06
	WHERE fechaconciliacion BETWEEN vfecharep_ini AND vfecharep_fin
	--WHERE fechaconciliacion BETWEEN '2016-08-28 00:00:00' AND '2016-08-28 23:00:00'
	AND codigoiso IN ('00','01')
	AND archivoorigen='IST'
	AND compania IN ('BNI')	--> valida que sean bines de otros bancos
	GROUP BY fecha, fechaconciliacion, descripcion, indicadordereversa))
	GROUP BY 1,2;

	 /*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	 ::::::::::::::::::::::::::SUMAS PARA EL REPORTE:::::::::::::::::::::::::::::::
	 :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/	

 
	let vpaso= 5;
	
	INSERT INTO intercard:caratula_producto_totales(fecha, fechaconciliacion, tipooperacion, tipoproducto, monto_retiro, monto_comision)
   	SELECT fecha, fechaconciliacion, 
			CASE WHEN tipooperacion='1' THEN 'MIS EN MIS'
				 WHEN tipooperacion='2' THEN 'SUS EN MIS'
			ELSE '' END AS tipo_operacion, 
			CASE WHEN tipoproducto='C' THEN 'CUENTA DE CRÉDITO'
				 WHEN tipoproducto='D' THEN 'CUENTA DE DÉBITO'
			ELSE '' END AS tipo_producto, 
			SUM (monto_retiro - monto_reverso - monto_reverso_p) AS retiro, SUM(comi_retiro + comi_consulta) AS comision
    FROM intercard:caratula_producto
	WHERE fechaconciliacion BETWEEN vfecharep_ini AND vfecharep_fin
	--WHERE fechaconciliacion between '2016-08-23 00:00:00' and  '2016-08-23 23:00:00'
    GROUP BY 1,2,3,4;
	
	
	--SE INSERTAN LOS REGISTROS QUE NECESITAMOS PARA EL REPORTE FINAL EN VARIABLES
	let vpaso= 6;
	
	SELECT monto_retiro INTO vmonto_retiro_bd FROM intercard:caratula_producto_totales 
	WHERE tipooperacion ='MIS EN MIS' AND tipoproducto = 'CUENTA DE DÉBITO' AND fechaconciliacion BETWEEN vfecharep_ini AND vfecharep_fin;

	SELECT monto_retiro INTO vmonto_retiro_bc FROM intercard:caratula_producto_totales 
	WHERE tipooperacion ='MIS EN MIS' AND tipoproducto = 'CUENTA DE CRÉDITO' AND fechaconciliacion BETWEEN vfecharep_ini AND vfecharep_fin;
	
	SELECT monto_retiro INTO vmonto_retiro_od FROM intercard:caratula_producto_totales 
	WHERE tipooperacion ='SUS EN MIS' AND tipoproducto = 'CUENTA DE DÉBITO' AND fechaconciliacion BETWEEN vfecharep_ini AND vfecharep_fin;

	SELECT monto_retiro INTO vmonto_retiro_oc FROM intercard:caratula_producto_totales 
	WHERE tipooperacion ='SUS EN MIS' AND tipoproducto = 'CUENTA DE CRÉDITO' AND fechaconciliacion BETWEEN vfecharep_ini AND vfecharep_fin;
	
	let vsumamis = vmonto_retiro_bd + vmonto_retiro_bc;
	let vsumasus = vmonto_retiro_od + vmonto_retiro_oc;
	let vsumatotal = vsumamis + vsumasus;
	
/*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::GENERACIÓN DEL REPORTE::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/	

	LET vNombreArchivo = 'caratula_producto'||vdma||'.txt';
	
	--SE CREAN LOS RENGLONES DEL REPORTE
	let vpaso= 7;
	
	let vsql = '';
	let vsql = ' echo "|COMPENSACIÓN RED|COMPBC">/resplogifx/'||TRIM(vNombreArchivo)||'';
	system vsql;
    let vsql = ' echo "|DETALLE BANCO|T137">/resplogifx/archivo_fin1.txt';  	
	system vsql;
	let vsql = ' echo "|FECHA DE DATOS|'||vdmar||'">/resplogifx/archivo_fin2.txt';  	
	system vsql;
	let vsql = ' echo "|BANCOPPEL S.A. INSTITUCION DE BANCA MULTIPLE">/resplogifx/archivo_fin3.txt';  	
	system vsql;
	let vsql = ' echo "TIPO DE OPERACION|PRODUCTO|MONTO RETIRO|MONTO POR COMISIONES">/resplogifx/archivo_fin5.txt';  	
	system vsql;
	LET vsql = 'echo "UNLOAD TO /resplogifx/archivo_fin4.txt select tipooperacion, tipoproducto, monto_retiro, monto_comision from intercard:caratula_producto_totales where fechaconciliacion BETWEEN '''||vfecharep_ini||''' AND '''||vfecharep_fin||''' order by tipooperacion, tipoproducto">/resplogifx/load_archivo.sql';                         
	system vsql;
	LET vsql = 'dbaccess intercard /resplogifx/load_archivo.sql';
	system vsql;
	let vsql ='';
	let vsql = ' echo "|MONTO TOTAL DE RETIROS|'||vsumatotal||'">/resplogifx/archivo_fin6.txt';  	
	system vsql;
	
	--SE CONCATENAN LOS RENGLONES DENTRO DEL ARCHIVO FINAL
	let vpaso = 8;

	let vsql ='';
    let vsql = "sed 's/|$//g' /resplogifx/archivo_fin1.txt >>/resplogifx/"||vNombreArchivo;       
	system vsql;
    let vsql = "sed 's/|$//g' /resplogifx/archivo_fin2.txt >>/resplogifx/"||vNombreArchivo;       
    system vsql;
    let vsql = "sed 's/|$//g' /resplogifx/archivo_fin3.txt >>/resplogifx/"||vNombreArchivo;       
	system vsql;
    let vsql = "sed 's/|$//g' /resplogifx/archivo_fin5.txt >>/resplogifx/"||vNombreArchivo;       
	system vsql;
    let vsql = "sed 's/|$//g' /resplogifx/archivo_fin4.txt >>/resplogifx/"||vNombreArchivo;       
	system vsql;
    let vsql = "sed 's/|$//g' /resplogifx/archivo_fin6.txt >>/resplogifx/"||vNombreArchivo;       
	system vsql;
	
	--SE ELIMINAN LOS RENGLONES
	let vpaso = 9;
	
	let vsql = '';
	let vsql = 'rm -f /resplogifx/archivo_fin1.txt';
    system vsql;
	let vsql= 'rm -f /resplogifx/archivo_fin2.txt';
    system vsql;
	let vsql= 'rm -f /resplogifx/archivo_fin3.txt';
    system vsql; 
	let vsql= 'rm -f /resplogifx/archivo_fin5.txt';
    system vsql; 
	let vsql= 'rm -f /resplogifx/archivo_fin4.txt';
    system vsql; 
	let vsql= 'rm -f /resplogifx/load_archivo.sql';
    system vsql;
	let vsql= 'rm -f /resplogifx/archivo_fin6.txt';
    system vsql;

		
		let cCodret = '00000';
		let CVarDataErr = 'Reporte generado correctamente';
		RETURN cCodret,CVarDataErr;
	
END	
END PROCEDURE;