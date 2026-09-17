CREATE PROCEDURE "informix".sp_reporteparametrico
(
     pdtFechaIni DATE, --Fecha Inicio del Periodo, se debe validar que no sea mayor a 90 días
	 pdtFechaFin DATE, --Fecha Final del Periodo, se debe validar que sea menor o igual a la fecha actual
	 psEstado CHAR(2), --Se recibirá el código de Estado de acuerdo al catálogo de bdinteg:si_estados.estado, se debe validar existencia
	 psCiudad CHAR(3), --Se recibira el código de Ciudad de acuerdo al catálogo de bdinteg:si_ciudades.ciudad, se debe validar existencia de acuerdo a la ciudad
	 psOrigen CHAR(1), --Se recibirá 'N'-Nacional, 'I'-Internacional o en blanco cualquiera y se validará contra intercard:movimiento.esnacional	 
	 psProdInd CHAR(1),--Se recibirá 'A' para ATM, 'P' para POS y vacio para ambos, cualquier otro valor es un dato inválido	 
	 psBin CHAR(6),    --Se recibira el código de Bin de acuerdo al catálogo intercard:bines.bin, se debe validar existencia
	 psSubBin CHAR(2), -- Producto / imagen de la tarjeta
	 psChipBanda CHAR(1), -- 'C' - Chip, 'B' - Banda, espacio en blanco todos, cualquier otro valor es un dato inválido	 
	 psProductoInterCard CHAR(3), --Se recibirá el código de Producto de Tarjeta de acuerdo al catálogo intercard:productotarjeta.codproductotarjeta, cualquier otro valor es un dato inválido	 
	 psFechaExp CHAR(4), --Se reciirá la fecha de expiración de la tarjeta en formato AAMM, se verificará que corresponda cada dato a una fecha válida
	 psProducto CHAR(1), --Se recibirá 'C' - Crédito, 'D' - Débito de lo contrario mandará un msj solicitando dicho valor. 
     psMetodoCaptura CHAR(2), -- Se recibirá '00', '01'-Digitada,, '02'-ATM, '05'-Chip, '09', '80' - Fall Back, '81'-Digitada, '90'-Banda, '92'-ContactLess	 
	 psTipoTransaccionposDigitada CHAR(2), --Se recibirá el tipo de transacción POS digitada, intercard:movimiento.tipotransaccionposdigitada	 
     psGiroComercio CHAR(4), --Se recibirá un código de giro de negocio de acuerdo al catálogo intercard:gironegocio.codgironeg, cualquier otro valor es un dato inválido	 
	 psIDTerminalRetailer CHAR(19), --Se recibirá el no. de afiliación o de cajero según corresponda, no hay catálogo por lo que buscará el valor recibido	 
	 psCodigoIso CHAR(2) -- Se recibirá el código ISO de acuerdo al catálogo intercard:respuestaiso.codigoiso, cualquier otro valor es un dato inválido
)
RETURNING

VARCHAR(5) AS CodRetorno, 
VARCHAR(50) AS DescRetorno,
INTEGER AS tot_registros;
 
DEFINE CodRetorno VARCHAR(5);
DEFINE DescRetorno VARCHAR(50);
DEFINE vdtFechaIni DATETIME YEAR TO FRACTION(5);
DEFINE vdtFechaFin DATETIME YEAR TO FRACTION(5);
DEFINE viSqlErr INTEGER;
DEFINE viSamErr INTEGER;
DEFINE vdtFechaAux DATETIME YEAR TO FRACTION(5);

--DEFINICION DE VARIABLES DETERMINANTES:
DEFINE det_estado CHAR(2);
DEFINE det_Ciudad CHAR(3);
DEFINE det_Origen CHAR(1);
DEFINE det_Origen2 CHAR(1);
DEFINE det_ProdInd CHAR(2);
DEFINE det_ProdInd2 CHAR(2);
DEFINE det_ChipBanda CHAR(1);
DEFINE det_MetodoCaptura CHAR;
DEFINE det_TipoTransaccionposDigitada CHAR(2);
DEFINE det_Bin CHAR(6);
DEFINE det_SubBin CHAR(2);
DEFINE det_ProductoInterCard CHAR(3);
DEFINE det_Producto CHAR(1);
DEFINE det_FechaExp CHAR(4);
DEFINE det_GiroComercio CHAR(4);
DEFINE det_CodigoIso CHAR(2);
DEFINE det_IDTerminalRetailer CHAR(1); 
DEFINE det_TerminalRetailer CHAR(1);
DEFINE det_ChipBanda2 CHAR(1);
DEFINE vsql char(1150);
--DEFINE vcAAAAMMDDHHMMSS char (19);
DEFINE vaniomes VARCHAR(16);
DEFINE vfecha_hoy DATETIME YEAR TO FRACTION(5);
DEFINE vult_dia_mes DATE;    
DEFINE vpaso CHAR(1);
DEFINE vitotalregistros integer;

	
LET pdtFechaFin = pdtFechaFin;
LET vdtFechaIni = pdtFechaIni;
LET vdtFechaFin = pdtFechaFin; 
LET viSqlErr = 0;
LET viSamErr = 0;

--INICIALIZACION VARIABLES DETERMINANTES:

LET det_estado = '';
LET det_Ciudad = '';
LET det_Origen = '';
LET det_Origen2 = '';
LET det_ProdInd = '';
LET det_ProdInd2 = '';
LET det_ChipBanda = '';
LET det_MetodoCaptura = '';
LET det_TipoTransaccionposDigitada = '';
LET det_Bin = '';
lET det_SubBin = '';
LET det_ProductoInterCard = '';
LET det_Producto = '';
LET det_FechaExp = '';
LET det_GiroComercio = '';
LET det_CodigoIso = '';
LET det_IDTerminalRetailer = '';
LET det_TerminalRetailer = ''; 
LET det_ChipBanda2 = '';
LET vsql = '';
--LET vcAAAAMMDDHHMMSS = '';
LET CodRetorno = '00000';
LET DescRetorno = 'Ejecución de proceso exitosa.';
LET vult_dia_mes ='';
LET vpaso = '';	 
LET vitotalregistros = 0;

BEGIN
	ON EXCEPTION
		SET viSqlErr, viSamErr
		LET CodRetorno = viSqlErr;
		LET DescRetorno = viSamErr;
		RETURN CodRetorno, DescRetorno, 0;
	END EXCEPTION;

 
--set debug file to "/informix/HomeInformix/mgap/sp_reporte_parametrico.out";
--trace on;
	 
LET psEstado = TRIM(psEstado);
LET psCiudad = TRIM(psCiudad);
LET psOrigen = TRIM(psOrigen);
LET psProdInd = TRIM(psProdInd);
LET psChipBanda = TRIM(psChipBanda);	
LET psMetodoCaptura = TRIM(psMetodoCaptura);
LET psTipoTransaccionposDigitada = TRIM(psTipoTransaccionposDigitada);
LET psBin = TRIM(psBin);
LET psSubBin = TRIM(psSubBin);
LET psProductoInterCard = TRIM(psProductoInterCard);
LET psProducto = TRIM(psProducto);
LET psfechaexp = TRIM(psfechaexp);	
LET psGiroComercio = TRIM(psGiroComercio);	
LET psCodigoIso = TRIM(pscodigoiso);
LET psIDTerminalRetailer = TRIM(psIDTerminalRetailer);

	---------------------------------------------------
	SET ISOLATION TO DIRTY READ;
	SELECT  fecha_hoy,ult_dia_mes  INTO vfecha_hoy,vult_dia_mes FROM  bdinteg:si_fechas WHERE empresa='001';   
	---------------------------------------------------
      IF ((vfecha_hoy::DATE) = (vult_dia_mes)) THEN 
        LET CodRetorno = '00018';
        LET DescRetorno = 'No es posible ejecutar los últimos días del mes.';
        RETURN CodRetorno, DescRetorno, 0;
 	  ELIF (DAY(vfecha_hoy) = 15)  THEN 
		LET CodRetorno = '00019';
		LET DescRetorno = 'No es posible ejecutar los días 15 del mes.';
		RETURN CodRetorno, DescRetorno, 0;
	  ELIF (DAY(vfecha_hoy) = 20)  THEN 
		LET CodRetorno = '00020';
		LET DescRetorno = 'No es posible ejecutar los días 20 del mes.';
		RETURN CodRetorno, DescRetorno, 0;
	 END IF; 
 	
 ---------------------------------------------------
	SET ISOLATION TO DIRTY READ;
	SELECT current INTO vfecha_hoy  FROM  bdinteg:si_fechas WHERE empresa='001';   
   
	let vaniomes = REPLACE( year(vfecha_hoy) || LPAD (MONTH(vfecha_hoy),2,"00")||LPAD (day(vfecha_hoy),2,"00")|| extend (vfecha_hoy,hour to SECOND),':','');
	let vaniomes=  vaniomes;
	LET vdtFechaFin=vdtFechaFin;
	 
	IF(psEstado = '') THEN	    
		LET det_Estado = 'T'; --Todos
		ELSE
        LET det_Estado = 'A'; --Solo uno
    END IF;
	 
	IF(psCiudad = '') THEN	    
		LET det_Ciudad = 'T'; --Todos
		ELSE
        LET det_Ciudad = 'A'; --Solo uno
    END IF;
	 
	IF(psBin = '') THEN	    
		LET det_Bin = 'T'; --Todos
		ELSE
        LET det_Bin = 'A'; --Solo uno
    END IF;
	
	IF(psSubBin = '') THEN	    
		LET det_SubBin = 'T'; --Todos
		ELSE
        LET det_SubBin = 'A'; --Solo uno
    END IF;
	 
	IF(psChipBanda = '') THEN	    
		LET det_ChipBanda = 'T'; --Todos
		ELSE
        LET det_ChipBanda = 'A'; --Solo uno
		IF	psChipBanda = 'C' THEN
			LET det_ChipBanda2 = 'V';
			ELSE
			LET det_ChipBanda2 = 'F';
		END IF;
    END IF;
	 
	IF(psProductoInterCard = '') THEN	    
		LET det_ProductoInterCard = 'T'; --Todos
		ELSE
        LET det_ProductoInterCard = 'A'; --Solo uno
    END IF;
 
	IF(psProdInd = '') THEN   --Busqueda de 'P': POS / ' 'A' : ATM Canal	    
		LET det_ProdInd = 'T'; --Todos
		ELSE
        LET det_ProdInd = 'A'; --Solo uno		
    END IF;
	 
	IF det_ProdInd = 'A' THEN
		IF psProdInd = 'A' THEN  
			let det_ProdInd2 = '01'; --ATM
			ELSE
			let det_ProdInd2 = '02'; --POS
		END IF;
	END IF;		 
	 
	IF(psMetodoCaptura = '') THEN	    
		LET det_MetodoCaptura = 'T'; --Todos
		ELSE
        LET det_MetodoCaptura = 'A'; --Solo uno
    END IF;
	 
	IF(psGiroComercio = '') THEN	    
		LET det_GiroComercio = 'T'; --Todos
		ELSE
        LET det_GiroComercio = 'A'; --Solo uno
    END IF;
	 
	IF(psOrigen = '') THEN	    
		LET det_Origen = 'T'; --Todos
		ELSE
        LET det_Origen = 'A'; --Solo uno
    END IF;
	 
	IF(det_Origen = 'A') THEN	    
		IF psOrigen = 'N' THEN
			let det_Origen2 = 'V';
			ELSE
			let det_Origen2 = 'F';
		END IF;
    END IF;

	IF(psCodigoIso = '') THEN	    
		LET det_CodigoIso = 'T'; --Todos
		ELSE
        LET det_CodigoIso = 'A'; --Solo uno
    END IF;
	 
	IF(psfechaexp = '') THEN	    
		LET det_fechaexp = 'T'; --Todos
		ELSE
        LET det_fechaexp = 'A'; --Solo uno
    END IF;
	 
	IF(psTipoTransaccionposDigitada = '') THEN	    
		LET det_TipoTransaccionposDigitada = 'T'; --Todos
		ELSE
        LET det_TipoTransaccionposDigitada = 'A'; --Solo uno
    END IF;	 	
	 
	IF(psIDTerminalRetailer = '') THEN  
		LET det_IDTerminalRetailer = 'T';
		ELSE
	    LET det_IDTerminalRetailer = 'A';
	END IF;	 
	 
	IF(det_ProdInd2 = '01') THEN	    
		LET det_TerminalRetailer = 'T'; --Terminal
		ELIF (det_ProdInd2 = '02') THEN	     
           LET det_TerminalRetailer = 'R'; --Retailer
		ELSE
		   LET det_TerminalRetailer = 'A'; --Ambos
    END IF;
	 
-----------------------------------------------------------------------------------------------
    -- Se truncan las tablas de trabajo
    SET ISOLATION TO DIRTY READ;
    IF EXISTS (SELECT {+AVOID_FULL(sysmaster:SysTabNames)} dbsname, tabname FROM  sysmaster:SysTabNames  WHERE tabname = 'rpt_movimientopaso' AND dbsname= 'intercard') THEN        
		TRUNCATE TABLE intercard:"informix".rpt_movimientopaso;
    END IF;
		
	SET ISOLATION TO DIRTY READ;
    IF EXISTS (SELECT {+AVOID_FULL(sysmaster:SysTabNames)} dbsname, tabname FROM  sysmaster:SysTabNames  WHERE tabname = 'rptdinamico' AND dbsname= 'intercard') THEN
        TRUNCATE TABLE intercard:"informix".rptdinamico;		
    END IF;

-----------------------------------------------------------------------------------------------
	let pdtFechaFin = pdtFechaFin;
	let vdtFechaFin = vdtFechaFin; 
	 
	--Validación de Parámetros (Se deben de validar que todos los parámetros cumplan las condiciones necesarias	
	IF 
		(pdtFechaIni < current::date - 365) OR (pdtFechaIni is null) THEN --ERROR : pdtFechaIni
		LET CodRetorno = '00001';
		LET DescRetorno = 'Fecha-Inicio es Mayor a 365 días. Verificar.';
		RETURN CodRetorno, DescRetorno, 0;
		
		ELIF (pdtFechaFin > current::date) OR (pdtFechaFin is null)  THEN --ERROR : pdtFechaFin 	
		LET CodRetorno = '00002';
		LET DescRetorno = 'Fecha-Fin es Mayor al día actual. Verificar.';
		RETURN CodRetorno, DescRetorno, 0;

		ELIF (select {+AVOID_FULL (bdinteg:si_estados) } {+INDEX (bdinteg:si_estados inx_estado)} count(estado) from bdinteg:si_estados where (det_Estado = 'A' AND estado = psEstado) OR (det_Estado = 'T' AND 1 = 1)) = 0 THEN --ERROR : psEstado
		LET CodRetorno = '00003';
		LET DescRetorno = 'Código-Estado no reconocido. Verificar.';
		RETURN CodRetorno, DescRetorno, 0;

		ELIF (select count(ciudad) from bdinteg:si_ciudades where (det_Ciudad = 'A' AND ciudad = psCiudad) OR (det_Ciudad = 'T' AND 1 = 1)) = 0 THEN --ERROR : psCiudad
		LET CodRetorno = '00004';
		LET DescRetorno = 'Código-Ciudad no reconocido. Verificar.';
		RETURN CodRetorno, DescRetorno, 0;

		ELIF (select {+AVOID_FULL (bines)} {+INDEX (bines idx_bines)} count(bin) from intercard:bines where (det_bin = 'A' AND bin = psBin) OR (det_bin = 'T' AND 1 = 1)) = 0 THEN --ERROR : psBin	
		LET CodRetorno = '00005';
		LET DescRetorno = 'Bin no reconocido. Verificar.';
		RETURN CodRetorno, DescRetorno, 0;
		
		--NUEVA VALIDACIÓN PARA EL CAMPO SUB BIN
		ELIF (select {+AVOID_FULL (productoimagen)} count(producto) from intercard:productoimagen where (det_SubBin = 'A' AND producto = psSubBin) OR (det_SubBin = 'T' AND 1 = 1)) = 0 THEN --ERROR : psBin	
		LET CodRetorno = '00021';
		LET DescRetorno = 'Sub Bin no reconocido. Verificar.';
		RETURN CodRetorno, DescRetorno, 0;

		ELIF (psChipBanda <> 'C' AND psChipBanda <> 'B' and psChipBanda <> '') THEN --ERROR : psChipBanda	
		LET CodRetorno = '00006';
		LET DescRetorno = 'Valor Chip-Banda no reconocido. Verificar.';
		RETURN CodRetorno, DescRetorno, 0;
			 
		ELIF (select {+AVOID_FULL (productotarjeta) } count(codproductotarjeta) from intercard:productotarjeta where (det_ProductoInterCard = 'A' AND codproductotarjeta = psProductoInterCard) OR (det_ProductoInterCard = 'T' AND 1 = 1)) = 0 THEN --ERROR : psProductoInterCard
		LET CodRetorno = '00007';
		LET DescRetorno = 'Producto-Tarjeta no reconocido. Verificar.';
		RETURN CodRetorno, DescRetorno, 0;
	 
		ELIF (psProdInd <> 'A' AND psProdInd <> 'P' AND psProdInd <> '') THEN --ERROR : psProdInd	
		LET CodRetorno = '00008';
		LET DescRetorno = 'Tipo-Terminal no reconocido. Verificar.';
		RETURN CodRetorno, DescRetorno, 0;

		ELIF (
				psMetodoCaptura <> '00' AND psMetodoCaptura <> '01' AND psMetodoCaptura <> '02' AND psMetodoCaptura <> '05' AND
				psMetodoCaptura <> '09' AND psMetodoCaptura <> '80' AND psMetodoCaptura <> '81' AND psMetodoCaptura <> '90' AND
				psMetodoCaptura <> '92' AND psMetodoCaptura <> ''
			 ) THEN --ERROR : psMetodoCaptura	
		LET CodRetorno = '00009';
		LET DescRetorno = 'Método-Captura no reconocido. Verificar.';
		RETURN CodRetorno, DescRetorno, 0;

		ELIF LENGTH(NVL(psGiroComercio, '')) > 4 AND psGiroComercio <> '' THEN --ERROR : psGiroComercio	 --Revisar
		LET CodRetorno = '00010';
		LET DescRetorno = 'Giro-Comercio no reconocido. Verificar.';
		RETURN CodRetorno, DescRetorno, 0;

		ELIF (psOrigen <> 'N' AND psOrigen <> 'I' AND psOrigen <> '') THEN --ERROR : psOrigen	
		LET CodRetorno = '00011';
		LET DescRetorno = 'Origen-Transacción no reconocido. Verificar.';
		RETURN CodRetorno, DescRetorno, 0;

		ELIF (select {+AVOID_FULL (respuestaiso)} count(codigoiso) from intercard:respuestaiso where (det_codigoiso = 'A' AND codigoiso = pscodigoiso) OR (det_codigoiso = 'T' AND 1 = 1)) = 0 THEN --ERROR : pscodigoiso
		LET CodRetorno = '00012';
		LET DescRetorno = 'Código-ISO no reconocido. Verificar.';
		RETURN CodRetorno, DescRetorno, 0;

		ELIF ((substring(psfechaexp from 3 for 2) < 1 OR substring(psfechaexp from 3 for 2) > 12)) and psfechaexp <> '' THEN --ERROR : psfechaexp
		LET CodRetorno = '00013';
		LET DescRetorno = 'Fecha-Expiración-Tarjeta no reconocida. Verificar.';
		RETURN CodRetorno, DescRetorno, 0;
			                               
		ELIF (
				psTipoTransaccionposDigitada <> 'AV' AND psTipoTransaccionposDigitada <> 'CA' AND psTipoTransaccionposDigitada <> 'CE' 
				AND	psTipoTransaccionposDigitada <> 'HO' 
             --	2016.08.16 -I Se agrega <tipotransaccionposdigitada> tipo TAG:
				AND	psTipoTransaccionposDigitada <> 'TG' 
             --	2016.08.16 -F.
				AND psTipoTransaccionposDigitada <> 'ND' AND  psTipoTransaccionposDigitada <> ''
			  ) THEN --ERROR : psTipoTransaccionposDigitada
			  
		LET CodRetorno = '00014';
		LET DescRetorno = 'Tipo Transacción-POS-Digitada no reconocido. Verificar.';
		RETURN CodRetorno, DescRetorno, 0;
			 
		ELIF (((psProdInd = '01') AND (LENGTH(NVL(psIDTerminalRetailer, '')) > 16) AND (NVL(psIDTerminalRetailer, '') <> ''))
				OR ((psProdInd = '02') AND (LENGTH(NVL(psIDTerminalRetailer, '')) > 19) AND (NVL(psIDTerminalRetailer, '') <> ''))) THEN --ERROR : psIDTerminalRetailer
		LET CodRetorno = '00015';
		LET DescRetorno = 'No. Afiliación-Terminal no reconocido. Verificar.';
		RETURN CodRetorno, DescRetorno, 0;
	 	 
		ELIF (psProducto <> 'C' AND psProducto <> 'D' /*AND psProducto <> ''*/) THEN --ERROR : psProducto
		LET CodRetorno = '00016';
		LET DescRetorno = 'Producto(D/C) NO capturado o reconocido. Verificar';
		RETURN CodRetorno, DescRetorno, 0;
		
        ELIF  ((pdtFechaFin) - (pdtFechaIni))  > 31  THEN 
        LET CodRetorno = '00017';
        LET DescRetorno = 'Rango supera los 31 días de consulta. Verificar.';
        RETURN CodRetorno, DescRetorno, 0;
		
		ELSE
		
			LET vdtFechaIni = pdtFechaIni;
			LET vdtFechaIni = SUBSTRING(vdtFechaIni FROM 1 FOR 10) || ' 00:00:00';
			LET vdtFechaFin = pdtFechaFin;
			LET vdtFechaFin = SUBSTRING(vdtFechaFin FROM 1 FOR 10) || ' 23:59:59';
			LET vdtFechaAux = CURRENT;
			
	        --LET vcAAAAMMDDHHMMSS = SUBSTRING(vdtFechaAux FROM 0 FOR 20); 
	 
	        --OBTIENE LA FECHA MINIMA DE LA TABLA DE MOVIMIENTOS  EJ:  01/NOV/2017 
			SET ISOLATION TO DIRTY READ;
            SELECT {+INDEX(intercard:"informix".movimiento "informix".idx_fechahorainauth)} MIN(FechaHoraInAuth)
			INTO vdtFechaAux
		    FROM intercard:"informix".movimiento; 
 
		    IF ( --VALIDA SI EL RANGO DE BUSQUEDA ESTA DENTRO DE LA TABLA <MOVIMIENTO>	 
				 (pdtFechaIni >= vdtFechaAux::DATE AND pdtFechaIni <= CURRENT::DATE)    -- EJ: 15/NOV/2017 >= 01/NOV/2017  AND 15/NOV/2017 <= 28/DIC/2017 (ACTUAL) 
				   AND 
				 (pdtFechaFin >= vdtFechaAux::DATE AND pdtFechaFin <= CURRENT::DATE)    -- EJ: 30/NOV/2017 >= 01/NOV/2017  AND 30/NOV/2017 <= 28/DIC/2017 (ACTUAL)
				)	THEN                                                             

				 LET vpaso = 'M'; --- Activa bandera para indicar que entro al flujo de extracción de la tabla de movimiento
				
			     INSERT INTO "informix".rpt_movimientopaso
				 (secuencia,codigoiso,codgironeg,numtarjeta,prodind,formato,codtran,codreversa,monto,infreceptor,idreceptor,idterminal,
				  montorealrevfzda,movreversado,esnacional,metodocaptura,motivo,fechalocaltransaccion,horalocaltransaccion,fechahorainauth,
				  codigoretcomision,montosurcharge,montocashback,tipotransaccionposdigitada,idretailer)
                 -- Se inserta en la tabla fisica de paso los resultados encontrados en base a la tabla de movimiento y el rango seleccionado por usuario
                 SELECT {+AVOID_FULL (movimiento) } {+INDEX(intercard:"informix".movimiento "informix".idx_fechahorainauth)}
                 secuencia,codigoiso,codgironeg,numtarjeta,prodind,formato,codtran,codreversa,monto,infreceptor,idreceptor,idterminal,
				 montorealrevfzda,movreversado,esnacional,metodocaptura,motivo,fechalocaltransaccion,horalocaltransaccion,fechahorainauth,
				 codigoretcomision,montosurcharge,montocashback,tipotransaccionposdigitada,idretailer
				 FROM intercard:"informix".movimiento mv
				 WHERE mv.FechaHoraInAuth BETWEEN vdtFechaIni AND vdtFechaFin
				 AND mv.formato in ('0200','0220','0221','0420')                             
				 AND mv.codtran not in ('91','92','93','94','95','97')                   
				 AND (mv.codreversa = 0 or mv.codreversa = 2)                            
				 AND mv.movreversado = 'F'                                               
				 AND mv.metodocaptura is not null 
				 AND mv.metodocaptura != ('null');    
				 --ORDER BY mv.secuencia ASC;
				
			ELIF           --VALIDA SI EL RANGO DE BUSQUEDA ESTA DENTRO DE LA TABLA <MOVIMIENTOHISTORICO>	
					(
						    (pdtFechaIni < vdtFechaAux::DATE) -- EJ: 01/OCT/2017  <  01/NOV/2017
						AND (pdtFechaFin < vdtFechaAux::DATE) -- EJ: 31/OCT/2017  <  01/NOV/2017
						
					)	THEN 
					
				LET vpaso = 'H';  --- Activa bandera para indicar que entro al flujo de extracción de la tabla de movimientohistorico
				 	
					
				 INSERT INTO "informix".rpt_movimientopaso
				 (secuencia,codigoiso,codgironeg,numtarjeta,prodind,formato,codtran,codreversa,monto,infreceptor,idreceptor,idterminal,
				  montorealrevfzda,movreversado,esnacional,metodocaptura,motivo,fechalocaltransaccion,horalocaltransaccion,fechahorainauth,
				  codigoretcomision,montosurcharge,montocashback,tipotransaccionposdigitada,idretailer)
                 -- Se inserta en la tabla fisica de paso los resultados encontrados en base a la tabla de movimientohistorico y el rango seleccionado por usuario
                 SELECT {+AVOID_FULL (movimientohistorico) } {+INDEX(intercard:"informix".movimientohistorico "informix".idx_movimiento3)}
                 secuencia,codigoiso,codgironeg,numtarjeta,prodind,formato,codtran,codreversa,monto,infreceptor,idreceptor,idterminal,
				 montorealrevfzda,movreversado,esnacional,metodocaptura,motivo,fechalocaltransaccion,horalocaltransaccion,fechahorainauth,
				 codigoretcomision,montosurcharge,montocashback,tipotransaccionposdigitada,idretailer
				 FROM intercard:"informix".movimientohistorico mvh
				 WHERE mvh.FechaHoraInAuth BETWEEN vdtFechaIni AND vdtFechaFin
				 AND mvh.formato in ('0200','0220','0221','0420')                             
				 AND mvh.codtran not in ('91','92','93','94','95','97')                   
				 AND (mvh.codreversa = 0 or mvh.codreversa = 2)                            
				 AND mvh.movreversado = 'F'                                               
				 AND mvh.metodocaptura is not null 
				 AND mvh.metodocaptura != ('null');    
				 --ORDER BY mvh.secuencia ASC;	
			
            ELSE	--- De lo contrario obtiene los registros que se encuentren en las tablas de movimiento y movimientohistorico

			    LET vpaso = 'A';	--- Activa bandera para indicar que entro al flujo de extracción de ambas tablas
                  -- Se inserta en la tabla fisica de paso los resultados encontrados en base a ambas tablas y el rango seleccionado por usuario	
                 INSERT INTO "informix".rpt_movimientopaso
				 (secuencia,codigoiso,codgironeg,numtarjeta,prodind,formato,codtran,codreversa,monto,infreceptor,idreceptor,idterminal,
				  montorealrevfzda,movreversado,esnacional,metodocaptura,motivo,fechalocaltransaccion,horalocaltransaccion,fechahorainauth,
				  codigoretcomision,montosurcharge,montocashback,tipotransaccionposdigitada,idretailer)
			    
				 SELECT {+AVOID_FULL (movimiento) } {+INDEX(intercard:"informix".movimiento "informix".idx_fechahorainauth)}
                 secuencia,codigoiso,codgironeg,numtarjeta,prodind,formato,codtran,codreversa,monto,infreceptor,idreceptor,idterminal,
				 montorealrevfzda,movreversado,esnacional,metodocaptura,motivo,fechalocaltransaccion,horalocaltransaccion,fechahorainauth,
				 codigoretcomision,montosurcharge,montocashback,tipotransaccionposdigitada,idretailer
				 FROM intercard:"informix".movimiento mv
				 WHERE mv.FechaHoraInAuth BETWEEN vdtFechaIni AND vdtFechaFin
				 AND mv.formato in ('0200','0220','0221','0420')                             
				 AND mv.codtran not in ('91','92','93','94','95','97')                   
				 AND (mv.codreversa = 0 or mv.codreversa = 2)                            
				 AND mv.movreversado = 'F'                                               
				 AND mv.metodocaptura is not null 
				 AND mv.metodocaptura != ('null');
                 --ORDER BY mv.secuencia ASC;				 
				 		
				 
                 INSERT INTO "informix".rpt_movimientopaso
				 (secuencia,codigoiso,codgironeg,numtarjeta,prodind,formato,codtran,codreversa,monto,infreceptor,idreceptor,idterminal,
				  montorealrevfzda,movreversado,esnacional,metodocaptura,motivo,fechalocaltransaccion,horalocaltransaccion,fechahorainauth,
				  codigoretcomision,montosurcharge,montocashback,tipotransaccionposdigitada,idretailer)
				  
				 SELECT {+AVOID_FULL (movimientohistorico) } {+INDEX(intercard:"informix".movimientohistorico "informix".idx_movimiento3)}
                 secuencia,codigoiso,codgironeg,numtarjeta,prodind,formato,codtran,codreversa,monto,infreceptor,idreceptor,idterminal,
				 montorealrevfzda,movreversado,esnacional,metodocaptura,motivo,fechalocaltransaccion,horalocaltransaccion,fechahorainauth,
				 codigoretcomision,montosurcharge,montocashback,tipotransaccionposdigitada,idretailer
				 FROM intercard:"informix".movimientohistorico mvh
				 WHERE mvh.FechaHoraInAuth BETWEEN vdtFechaIni AND vdtFechaFin
				 AND mvh.formato in ('0200','0220','0221','0420')                             
				 AND mvh.codtran not in ('91','92','93','94','95','97')                   
				 AND (mvh.codreversa = 0 or mvh.codreversa = 2)                            
				 AND mvh.movreversado = 'F'                                               
				 AND mvh.metodocaptura is not null 
				 AND mvh.metodocaptura != ('null');
				 --ORDER BY mvh.secuencia ASC;	
				 
			END IF;					
		-----------------------------------------------------------------------------------------------------------------------------------------	
		-- Genera reporte final en base a la tabla de paso y con las tablas auxiliares para obtener los datos complementarios de la transacción (Tarjeta, cliente, estado etc): 
		
		        LET vpaso = 'F'; --- Activa bandera para indicar que entro al flujo de la  filtración final
		
		            INSERT INTO "informix".rptdinamico   
					(numCliente, noEstado, nombreEstado, noCiudad, nombreCiudad, canal, ChipBanda, bin, SubBin, productoInterCard, 
					 descProductoInterCard, producto, cuentaProducto, metodoCaptura, tipotransaccionposdigitada, terminacionTarjeta, 
					 fechaExpiracion, fechaTransaccion, origen, nombreComercio, giroComercio, descGiroNeg, idPosATM, TipoTransaccion, 
					 monto, montoCashBack, montoSurcharge, codigoIso, motivoRechazo)
		
		            SELECT  tjt.numcliente, 
							dir.estado as noestado,
							(select {+AVOID_FULL (bdinteg:si_estados) } {+INDEX (bdinteg:si_estados inx_estado)} nombre from bdinteg:si_estados where estado = dir.estado) as nombreestado,
							dir.ciudad as nociudad,
							(select {+AVOID_FULL (bdinteg:si_ciudades) } nombre from bdinteg:si_ciudades where dir.estado = estado and dir.ciudad = ciudad) as nombreCiudad,
							case when mv.prodind = '01' THEN 'ATM' 
								 when mv.prodind = '02' THEN 'POS'
							end as canal,       
							case when tpo.chip  = 'V' THEN 'CHIP'
								 when tpo.chip  = 'F' THEN 'BANDA'
							end as ChipBanda,
							substring(tjt.numtarjeta from 1 for 6) as bin,
							substring(tjt.numtarjeta from 7 for 2) as SubBin,
							tjt.codproductotarjeta as productoInterCard,
							(select {+AVOID_FULL (productotarjeta)} descproducto from productotarjeta where codproductotarjeta = tjt.codproductotarjeta) as descproductoInterCard,
							case when bin.creditodebito = 'C' THEN 'CREDITO'
								 when bin.creditodebito = 'D' THEN 'DEBITO'     
							end as producto,
							cta.numcuenta as CuentaProducto,
							mv.metodocaptura,
							mv.tipotransaccionposdigitada,       
							substring(mv.numtarjeta from 13 for 4) as terminaTarjeta,
							tjt.fechaexp,
							date(mv.fechahorainauth) as Fecha,
							case when mv.esnacional = 'V' THEN 'NAC'
								 when mv.esnacional = 'F' THEN 'INT'
							end as txnOrigen,
							mv.infreceptor as comercio,
							case WHEN prodind = '01' THEN mv.idreceptor
								 WHEN prodind = '02' THEN mv.codgironeg 
							end as giroComercio,
							case WHEN prodind = '01' THEN 'CAJERO AUTOMÁTICO'
								 WHEN prodind = '02' THEN (select {+AVOID_FULL (gironegocio)}  {+INDEX (gironegocio idx_gironegocio)} descgironeg from gironegocio where codgironeg = mv.codgironeg  and (tipotarjeta =  bin.creditodebito OR tipotarjeta = 'A'))
							end as descGiroComercio,
							case WHEN prodind = '01' THEN mv.idterminal
								 WHEN prodind = '02' THEN mv.idretailer
							end as afiliacionTerminal,
							case when prodind = '01' and  codtran = '01' then 'Retiro ATM'
								 when prodind = '01' and  codtran = '31' then 'Consulta ATM'
								 when prodind = '02' then 'Compras POS'           
							end as TipoTransaccion,
							case when (mv.formato = '0420' and mv.codreversa = 2) then mv.montorealrevfzda
								 when (mv.formato <> '0420' and mv.codreversa = 0) then mv.monto
							end as montoTxn,
							case when (mv.formato = '0420' and mv.codreversa = 2) then mv.montocashback
								 when (mv.formato <> '0420' and mv.codreversa = 0) then mv.montocashback
							end as montoCashBack,       
							mv.montosurcharge as montoSurcharge,
							mv.codigoiso,
							case when mv.codigoiso  = '00' then 'Transacción Aprobada'
								 when mv.codigoiso <> '00' then mv.motivo 
							end as motivo
						FROM intercard:"informix".rpt_movimientopaso mv
							LEFT JOIN intercard:"informix".tarjeta tjt on tjt.numtarjeta = mv.numtarjeta      
							LEFT JOIN intercard:"informix".lote lte on tjt.numerolote = lte.numerolote
							LEFT JOIN intercard:"informix".tipotarjeta tpo on tpo.clave_tipotarjeta = lte.clave_tipotarjeta
							LEFT JOIN intercard:"informix".tarjetacuenta cta on cta.numtarjeta = mv.Numtarjeta
							LEFT JOIN bdinteg:"informix".si_direcciones_actual dir on dir.numcte = tjt.numcliente                                              
							LEFT JOIN intercard:"informix".bines bin on bin.bin = tpo.bin							
						WHERE 
							mv.FechaHoraInAuth BETWEEN vdtFechaIni AND vdtFechaFin
							AND dir.numcte = tjt.numcliente and dir.pais = '001' and dir.tipo_dir = '1' 
							AND ((det_Estado = 'A' and dir.estado = psEstado) OR (det_Estado = 'T' AND 1 = 1))
							AND ((det_Ciudad = 'A' and dir.ciudad = psCiudad) OR (det_Ciudad = 'T' AND 1 = 1))
							AND ((det_Prodind = 'A' AND mv.ProdInd = det_ProdInd2) OR (det_Prodind = 'T' AND 1 = 1))
							AND tpo.clave_tipotarjeta = lte.clave_tipotarjeta
							AND ((det_ChipBanda = 'A' and tpo.chip = det_ChipBanda2) OR (det_ChipBanda = 'T' and 1 = 1))
							AND ((det_bin ='A' AND substring(mv.numtarjeta from 1 for 6) = psBin) OR (det_bin = 'T' AND 1 = 1))
							AND ((det_SubBin ='A' AND substring(mv.numtarjeta from 7 for 2) = psSubBin) OR (det_SubBin = 'T' AND 1 = 1))
							AND ((det_productoInterCard = 'A' AND tjt.codproductotarjeta = psProductoInterCard) 
								OR (det_productoInterCard = 'T' AND 1 = 1))
							AND substring(mv.numtarjeta from 1 for 6) = bin.bin  
                            AND bin.creditodebito = psProducto							
							AND((det_MetodoCaptura = 'A' AND mv.metodocaptura = psMetodoCaptura) OR (det_MetodoCaptura = 'T' AND 1 = 1))
							AND((det_tipotransaccionposdigitada = 'A' AND mv.tipotransaccionposdigitada = pstipotransaccionposdigitada) 
								OR (det_tipotransaccionposdigitada = 'T' AND 1 = 1))
							AND((det_FechaExp = 'A' AND tjt.fechaexp = psFechaExp) OR (det_FechaExp = 'T' AND 1 = 1))
							AND((det_Origen = 'A' AND mv.esnacional = det_Origen2) OR (det_Origen = 'T' AND 1 = 1))
							AND((det_GiroComercio = 'A' AND mv.codgironeg = psGiroComercio) OR (det_GiroComercio = 'T' AND 1 = 1))						
							AND((det_IDTerminalRetailer = 'A' AND mv.IdTerminal = psIDTerminalRetailer) 
							 OR (det_IDTerminalRetailer = 'A' AND mv.IdRetailer = psIDTerminalRetailer) 
							 OR (det_IDTerminalRetailer = 'T' AND 1 = 1))
							AND((det_TerminalRetailer = 'T' AND mv.IdTerminal = psIDTerminalRetailer)
							 OR (det_TerminalRetailer = 'T' AND 1 = 1)
							 OR (det_TerminalRetailer = 'R' AND mv.IdRetailer = psIDTerminalRetailer) 
							 OR (det_TerminalRetailer = 'R' AND 1 = 1)
							 OR (det_TerminalRetailer = 'A' AND 1 = 1))
							AND((det_CodigoIso = 'A' AND mv.codigoiso = psCodigoIso) 
								OR (det_CodigoIso = 'T' AND 1 = 1));						
							--ORDER BY tjt.numcliente DESC;
						
						LET vpaso = '';
                        LET vpaso = 'R'; --- Activa bandera para indicar que entro al flujo de generación del reporte. 
						
                        let vaniomes=  vaniomes;
			         	let vsql = ''; 	
	                    let vsql = 'echo "UNLOAD TO /resplogifx/Rpt_Dinamico_'||vaniomes||'.txt '||
                        'SELECT * FROM "informix".rptdinamico ORDER BY numcliente DESC;">/resplogifx/rebandos.sql';
						system vsql;
					    let vsql = '';
						let vsql = '';
						system vsql;
						let vsql= 'dbaccess intercard /resplogifx/rebandos.sql';
						system vsql;
						let vsql = '';
						let vsql ='rm /resplogifx/rebandos.sql';
						system vsql;
						let vsql ='';

						system vsql;
						let vsql = '';
						let vsql ='gzip -9 /resplogifx/Rpt_Dinamico_'||vaniomes||'.txt';
						system vsql;																		  
						let vsql = ''; 	  
						system vsql;

						--Obtiene el numero de registros procesados en el archivo resultante
						set isolation to dirty read; 
			            select count(*) into vitotalregistros from intercard:"informix".rptdinamico;
						
		                   TRUNCATE TABLE intercard:"informix".rpt_movimientopaso;			
		                   TRUNCATE TABLE intercard:"informix".rptdinamico;
					 						
				        RETURN CodRetorno, DescRetorno,NVL(viTotalRegistros,0);
		-----------------------------------------------------------------------------------------------------------------------------------------
	END IF;
END
END PROCEDURE
DOCUMENT
'AUTOR: L.I. Marcos Gerardo Ayala Ponce',
'Proyecto: Reporte Paramétrico de Productos - Transacciones de Tarjetas',
'Solicito: Luis Antonio Gomez',
'Descripcion: GENERA REPORTE PARAMETRICO DE TRANSACCIONES DE TARJETAS',
'Fecha: 2018/01/08',
'Version: 20180108.1800',
'Modificacion: Se genera SP alterno para optimizar el proceso.',
'BD: Intercard';

CREATE PROCEDURE "informix".sp_actualiza_estadisticas() 
RETURNING VARCHAR(5) as Cod_ret,VARCHAR(80) as Men_ret;
/*Se definen las variables a ser utilizadas para el paso de la información.*/
   DEFINE spconsumo integer;
   DEFINE spsucursal varchar(5);
   DEFINE  p_cod_ret varchar(5);
   DEFINE  p_mensaje varchar(80);
   DEFINE  sql_err integer;
   DEFINE  isam_err integer;
   DEFINE  error_info varchar(80);
 
 /* Las siguientes opciones pueden ser habilitadas para recabar información del store procedure durante su ejecución, es necesario 
 especificar la ruta donde será colocado el log del proceso. */
    --SET DEBUG FILE TO "/informix/HomeInformix/rrm/sp_actualiza_estadistica.out";
    --TRACE ON;
    
 BEGIN
 
 /* El manejo de excepciones que se presenta está diseñado para deshacer los cambios ocasionados y poder verificar cualquier mensaje
 de error proporcionado por la base de datos durante la ejecución de este proceso */
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
	LET P_COD_RET  = SQL_ERR;
	LET P_MENSAJE  = ERROR_INFO;	
    RETURN P_COD_RET,P_MENSAJE;		
   END EXCEPTION;
    
/*Se inicializan las variables  a ser usadas.*/
        let spconsumo = 0;
	let spsucursal = '';
	let p_cod_ret = '00000';
	let p_mensaje = 'Proceso Exitoso';
	let sql_err = 0;
        let isam_err = 0;
        let error_info = 'Error durante el proceso de Actualizar Estadisticas.';
  

/*El siguiente FOREACH se encarga de disminuir las existencias del tipo 16 en base a las 
//estadísticas del presente día del tipo 2. Así como añadir el consumo de tipo 2 al tipo
//16 en la tabla de estadisticatarjetasuc ya sea agregando un nuevo registro o sumando el
//consumo al registro actual.*/
   FOREACH SELECT {+INDEX("informix".estadisticatarjetasuc "informix".idx_estadisticatarjetasuc)}
     consumo, clave_sucursal INTO spconsumo, spsucursal FROM "informix".estadisticatarjetasuc WHERE clave_tipotarjeta = 2 AND fecha = TODAY
        
        /*Este UPDATE se encarga de disminuír las existencias del tipo 12 en base al consumo del tipo 5 */
      UPDATE "informix".sucursal_tipotarjeta SET existencia = existencia - spconsumo WHERE clave_sucursal = spsucursal AND clave_tipotarjeta = 16;   
      
      /*Este If determina si no existe consumo de tipo 16 ese día para agregar su registro de consumo, en caso de ya existir consumo 
      //procede a aumentarlo con el consumo del tipo 2.*/
      IF (SELECT Count(*) FROM "informix".estadisticatarjetasuc WHERE clave_sucursal = spsucursal AND clave_tipotarjeta = 16 AND fecha = TODAY) = 0 Then
        INSERT INTO "informix".estadisticatarjetasuc(clave_sucursal, clave_tipotarjeta, fecha, consumo) VALUES (spsucursal, 16, TODAY,spconsumo);
      ELSE
        UPDATE "informix".estadisticatarjetasuc SET consumo = consumo + spconsumo WHERE clave_sucursal = spsucursal AND clave_tipotarjeta = 16 AND fecha = TODAY;
      END IF; 
              
   END FOREACH;
   
 /*El siguiente FOREACH se encarga de disminuir las existencias del tipo 17 en base a las 
//estadísticas del presente día del tipo 12. Así como añadir el consumo de tipo 12 al tipo
//17 en la tabla de estadisticatarjetasuc ya sea agregando un nuevo registro o sumando el
//consumo al registro actual.*/
   FOREACH SELECT {+INDEX("informix".estadisticatarjetasuc "informix".idx_estadisticatarjetasuc)}
     consumo, clave_sucursal INTO spconsumo, spsucursal FROM "informix".estadisticatarjetasuc WHERE clave_tipotarjeta = 12 AND fecha = TODAY
        
        /*Este UPDATE se encarga de disminuír las existencias del tipo 17 en base al consumo del tipo 12 */
      UPDATE "informix".sucursal_tipotarjeta SET existencia = existencia - spconsumo WHERE clave_sucursal = spsucursal AND clave_tipotarjeta = 17;   
      
      /*Este If determina si no existe consumo de tipo 17 ese día para agregar su registro de consumo, en caso de ya existir consumo 
      //procede a aumentarlo con el consumo del tipo 12.*/
      IF (SELECT Count(*) FROM "informix".estadisticatarjetasuc WHERE clave_sucursal = spsucursal AND clave_tipotarjeta = 17 AND fecha = TODAY) = 0 Then
        INSERT INTO "informix".estadisticatarjetasuc(clave_sucursal, clave_tipotarjeta, fecha, consumo) VALUES (spsucursal, 17, TODAY,spconsumo);
      ELSE
        UPDATE "informix".estadisticatarjetasuc SET consumo = consumo + spconsumo WHERE clave_sucursal = spsucursal AND clave_tipotarjeta = 17 AND fecha = TODAY;
      END IF; 
              
   END FOREACH;
 return	P_COD_RET,P_MENSAJE;
 END;     

END PROCEDURE;