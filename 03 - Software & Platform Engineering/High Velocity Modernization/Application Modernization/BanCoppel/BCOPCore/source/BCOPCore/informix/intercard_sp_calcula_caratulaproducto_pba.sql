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