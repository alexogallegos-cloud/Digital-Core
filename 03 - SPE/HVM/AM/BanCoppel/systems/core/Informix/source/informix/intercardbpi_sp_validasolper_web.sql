CREATE PROCEDURE "informix".sp_validasolper_web(pNumCte varchar(13), pNumCuenta varchar(13), pNumtarjeta CHAR(16))
   RETURNING CHAR(5), CHAR(50), CHAR(6), CHAR(1);
      
   DEFINE cCodRet             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   
   DEFINE cDescripcion 	  CHAR(50);
   DEFINE cIdSolicitud 	  CHAR(6);
   DEFINE cEstatusProceso CHAR(1);
   DEFINE cNumTarj        CHAR(16);     
   DEFINE cNumCte        CHAR(16);    
   
   LET cCodRet 		      = '00000';   
   LET cDescripcion	      = '';
   LET cIdSolicitud	      = '';
   LET cEstatusProceso    = '';
   LET cNumTarj           = '';
   LET cNumCte           = '';      
      
BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
		SET DEBUG FILE TO "VerifCte1.err";
		TRACE sql_err||" * "||isam_err||" * "||error_info;
		LET cCodRet = sql_err;
		RETURN cCodRet, cDescripcion, cIdSolicitud, cEstatusProceso;
	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	--SET DEBUG FILE TO "/tmp/SP_VALIDASOLPER.out";
	--TRACE ON;	
	-- AAME RQM 10 676-2 Se agrega filtro de consulta por NÃÂºmero de tarjeta
	FOREACH
		SELECT MAX(idsolicitud)
		INTO cIdSolicitud
		FROM intercard: solicitudtarjeta WHERE numcliente = pNumCte AND numcuenta = pNumCuenta 
		--AND numtarjeta = pNumtarjeta
	   
        SELECT estatusproceso 
		INTO  cEstatusProceso
		FROM intercard: solicitudtarjeta WHERE numcliente = pNumCte AND numcuenta = pNumCuenta AND idsolicitud = cIdSolicitud;



		IF cNumTarj <> "" OR cNumTarj is not null THEN
			SELECT numcliente INTO cNumCte FROM intercard: tarjeta WHERE numcliente = pNumCte AND codstatustarjeta = 'NOA';
		END IF;
		
		IF cEstatusProceso = "V" AND NVL(cNumCte,'') <> '' THEN
			
			SELECT num_tarjeta INTO cNumTarj FROM bdicheq: sc_tarjeta WHERE numcte = pNumCte AND cuenta = pNumCuenta AND status_tar = 'A';
			IF cNumTarj = "" OR cNumTarj is null THEN
				SELECT num_tarjeta INTO cNumTarj FROM bdicred: sd_tarjeta WHERE numcte = pNumCte AND num_credito = pNumCuenta AND status_tar IN('A','I');
			END IF;
			
			IF cNumTarj = "" OR cNumTarj is null THEN
				LET cCodRet = "00000";
				LET cDescripcion = "Solicitud Procesada";					
			ELSE
				LET cCodRet = "00001";
				LET cDescripcion = "Solicitud (ReposiciÃÂ³n)";
			END IF;
			-- AAME RQM 10 676-2 Se agrega return para que no continue con validaciÃÂ³n una vez que se tiene resultado
			RETURN cCodRet, cDescripcion, cIdSolicitud, cEstatusProceso;
		ELIF cEstatusProceso = "F" AND NVL(cNumCte,'') = '' THEN
			LET cCodRet = "00000";
			LET cDescripcion = "Solicitud en Proceso";
			RETURN cCodRet, cDescripcion, cIdSolicitud, cEstatusProceso;
			-- AAME RQM 10 676-2 Se agrega nueva validaciÃÂ³n no contemplada para indicar que ya se procesÃÂ³ la solicitud y se encuentra activa la tarjeta
		ELIF cEstatusProceso = "V" AND NVL(cNumCte,'') = '' THEN
			LET cCodRet = "00001";
			LET cDescripcion = "Solicitud Procesada";
			RETURN cCodRet, cDescripcion, cIdSolicitud, cEstatusProceso;			
		END IF;	
	END FOREACH;
			-- AAME RQM 10 676-2 Se completo mas la descripciÃÂ³n
	IF cIdSolicitud = "" OR cEstatusProceso = "" OR cIdSolicitud is null OR cEstatusProceso is null THEN
		LET cCodRet = "00001";
		LET cDescripcion = 'Solicitud (Por primera vez) ';		
	END IF;
	
	RETURN cCodRet, cDescripcion, cIdSolicitud, cEstatusProceso;

END;
END PROCEDURE
DOCUMENT
'AUTOR: Elmer LÃÂ³pez Valenzuela',
'FECHA: 03/10/2016',
'BD: Intercard',
'Objetivo: Se crea procedimiento para validar exista una solicitud que no ha sido procesada para el cliente';

CREATE PROCEDURE "informix".sp_reporte_parametrico_rpt
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
	 psProducto CHAR(1), --Se recibirá 'C' - Crédito, 'D' - Débito y espacio en blanco todos, cualquier otro valor es un dato inválido
     psMetodoCaptura CHAR(2), -- Se recibirá '00', '01'-Digitada,, '02'-ATM, '05'-Chip, '09', '80' - Fall Back, '81'-Digitada, '90'-Banda, '92'-ContactLess	 
	 psTipoTransaccionposDigitada CHAR(2), --Se recibirá el tipo de transacción POS digitada, intercard:movimiento.tipotransaccionposdigitada	 
     psGiroComercio CHAR(4), --Se recibirá un código de giro de negocio de acuerdo al catálogo intercard:gironegocio.codgironeg, cualquier otro valor es un dato inválido	 
	 psIDTerminalRetailer CHAR(19), --Se recibirá el no. de afiliación o de cajero según corresponda, no hay catálogo por lo que buscará el valor recibido	 
	 psCodigoIso CHAR(2) -- Se recibirá el código ISO de acuerdo al catálogo intercard:respuestaiso.codigoiso, cualquier otro valor es un dato inválido
)
RETURNING


VARCHAR(5) AS CodRetorno, 
VARCHAR(50) AS DescRetorno

--****************************************************************************************************
-- DESCRIPCION:  REPORTE PARAMETRICO DE PRODUCTOS
-- AUTOR : Luis Antonio Gómez Santiago
-- FECHA : 03/03/2016
-- BD: INTERCARD
-- SISTEMA : PRODUCTOS
-- MODIFICADO :
--****************************************************************************************************

DEFINE CodRetorno VARCHAR(5);
DEFINE DescRetorno VARCHAR(50);
DEFINE dtFechaOperacion DATE;
DEFINE dtHoraOperacion DATETIME HOUR TO FRACTION(5);
DEFINE vdtFechaIni DATETIME YEAR TO FRACTION(5);
DEFINE vdtFechaFin DATETIME YEAR TO FRACTION(5);
DEFINE viSqlErr INTEGER;
DEFINE viSamErr INTEGER;
DEFINE vdtFechaAux DATETIME YEAR TO FRACTION(5);

---DEFINICION DE VARIBLES DE QUERYS:
DEFINE viContador INTEGER;
DEFINE vsnumCliente VARCHAR(13); --intercard:tarjeta.numcliente
DEFINE vsnoEstado VARCHAR(2); --bdinteg:si_estados.estado
DEFINE vsnombreEstado VARCHAR(30); --bdinteg:si_estados.nombre
DEFINE vsnoCiudad VARCHAR(3); --bdinteg:si_ciudades.ciudad
DEFINE vsnombreCiudad VARCHAR(60); --bdinteg:si_ciudades.nombre
DEFINE vscanal VARCHAR(3); --intercard:movimiento.prodind 01 = 'ATM' 02 = 'POS'
DEFINE vsChipBanda VARCHAR(5); --intercard:tipotarjeta.chip    V = 'CHIP  F = 'BANDA'
DEFINE vsbin VARCHAR(6); --intercard:bines.bin  
DEFINE vsSubbin VARCHAR(2); 
DEFINE vsproductoInterCard VARCHAR(3); --intercard:productotarjeta.codproductotarjeta
DEFINE vsdescProductoInterCard VARCHAR(30); --intercard:productotarjeta.descproducto
DEFINE vsproducto VARCHAR(1); --intercard:bin.creditodebito
DEFINE vscuentaProducto VARCHAR(13); --intercard:tarjetacuenta.numcuenta
DEFINE vsmetodoCaptura VARCHAR(2); --intercard:movimiento.metodocaptura
DEFINE vstipoTransaccionDigitada VARCHAR(2); --intercard:movimiento.tipotransaccionposdigitada
DEFINE vsterminacionTarjeta VARCHAR(4); --intercard:movimiento.numtarjeta
DEFINE vsfechaExpiracion VARCHAR(4); --intercard:tarjeta.fechaexp
DEFINE vdtfechaTransaccion DATE; --intercard:movimiento.fechahorainauth
DEFINE vsorigen VARCHAR(03); --intercard:movimiento.esnacional V = 'NAC'  F = 'INT'
DEFINE vsnombreComercio VARCHAR(40); --intercard:movimiento.infreceptor
DEFINE vsgiroComercio VARCHAR(4); --intercard:movimiento.codgironeg
DEFINE vsdescGiroNeg VARCHAR(80); --intercard:gironegocio.descgironeg
DEFINE vsidPosATM VARCHAR(19); --intercard:movimiento.idretailer / intercard:movimiento.idterminal
DEFINE vsTipoTransaccion VARCHAR(12); --intercard:movimiento. prodind = '01' - codtran= '31'= 'CONSULTA ATM', contran = '01' ='RETIRO ATM', prodind = '02' = 'COMPRA POS'
DEFINE vdcmonto DECIMAL(19,2); --intercard:movimiento.monto
DEFINE vdcmontoCashBack DECIMAL(19,2); --intercard:movimiento.montocashback
DEFINE vdcmontoSurcharge DECIMAL(19,2); --intercard:movimiento.montosurcharge
DEFINE vscodigoIso VARCHAR(2); --intercard:movimiento.codigoiso
DEFINE vsmotivoRechazo VARCHAR(70); --intercard:movimiento.motivo

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
DEFINE dtFechaValanioI DATE;
DEFINE dtFechaValanioF DATE;
DEFINE ivalciudad INTEGER;
DEFINE det_ChipBanda2 CHAR(1);
DEFINE chFlgTrace CHAR(35);
DEFINE vsql char(1150);
DEFINE vcAAAAMMDDHHMMSS char (19);
DEFINE ultimo_dia_mes DATE;
DEFINE primer_dia_mes DATE;
DEFINE ultimo_dia_mes_hora DATETIME YEAR TO FRACTION(5);
DEFINE primer_dia_mes_hora DATETIME YEAR TO FRACTION(5);
DEFINE pperiodofin_hora DATETIME YEAR TO FRACTION(5);
DEFINE pperiodini_hora DATETIME YEAR TO FRACTION(5);
DEFINE vaniomes VARCHAR(16);
DEFINE  vfecha_hoy DATETIME YEAR TO FRACTION(5);
DEFINE  vano VARCHAR(4);
DEFINE  vmes VARCHAR(2);
DEFINE  vdia VARCHAR(2);
DEFINE  dias integer;
DEFINE  vult_dia_mes DATE;    

	--SET DEBUG FILE TO "/informix/Esmeralda/SpParametrico/sp_reporte_parametrico_rpt.out";
    --TRACE ON;

--INICIALIZACION VARIABLES DE QUERY:

LET pdtFechaFin = pdtFechaFin;
LET vdtFechaIni = pdtFechaIni;
LET vdtFechaFin = pdtFechaFin;
LET viContador = 0;
LET vsnumCliente = ''; --intercard:tarjeta.numcliente
LET vsnoEstado = ''; --bdinteg:si_estados.estado
LET vsnombreEstado = ''; --bdinteg:si_estados.nombre
LET vsnoCiudad = ''; --bdinteg:si_ciudades.ciudad
LET vsnombreCiudad = ''; --bdinteg:si_ciudades.nombre
LET vscanal = ''; --intercard:movimiento.prodind 01 = 'ATM' 02 = 'POS'
LET vsChipBanda = ''; --intercard:tipotarjeta.chip    V = 'CHIP  F = 'BANDA'
LET vsbin = ''; --intercard:bines.bin  
LET vsSubBin = '';
LET vsproductoInterCard = ''; --intercard:productotarjeta.codproductotarjeta
LET vsdescProductoInterCard = ''; --intercard:productotarjeta.descproducto
LET vsproducto = ''; --bin.creditodebito
LET vscuentaProducto = ''; --intercard:tarjetacuenta.numcuenta
LET vsmetodoCaptura = ''; --intercard:movimiento.metodocaptura
LET vstipoTransaccionDigitada = ''; --intercard:movimiento.tipotransaccionposdigitada
LET vsterminacionTarjeta = ''; --intercard:movimiento.numtarjeta
LET vsfechaExpiracion = ''; --intercard:tarjeta.fechaexp
LET vdtfechaTransaccion = current; --intercard:movimiento.fechahorainauth
LET vsorigen = ''; --intercard:movimiento.esnacional V = 'NAC'  F = 'INT'
LET vsnombreComercio = ''; --intercard:movimiento.infreceptor
LET vsgiroComercio = ''; --intercard:movimiento.codgironeg
LET vsdescGiroNeg = ''; --intercard:gironegocio.descgironeg
LET vsidPosATM = ''; --intercard:movimiento.idretailer / intercard:movimiento.idterminal
LET vsTipoTransaccion = '';  --intercard:movimiento. prodind = '01' - codtran= '31'= 'CONSULTA ATM', contran = '01' ='RETIRO ATM', prodind = '02' = 'COMPRA POS'
LET vdcmonto = 0.0; --intercard:movimiento.monto
LET vdcmontoCashBack = 0.0; --intercard:movimiento.montocashback
LET vdcmontoSurcharge = 0.0; --intercard:movimiento.montosurcharge
LET vscodigoIso = ''; --intercard:movimiento.codigoiso
LET vsmotivoRechazo = ''; --intercard:movimiento.motivo
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
LET dtFechaValanioI = current;
LET dtFechaValanioF = current;
LET ivalciudad = 0;
LET det_ChipBanda2 = '';
LET chFlgTrace = '';
LET vsql = '';
LET vcAAAAMMDDHHMMSS = '';
LET CodRetorno = '00000';
LET DescRetorno = 'Ejecución de proceso exitosa.';
LET vult_dia_mes =''; 

BEGIN
	ON EXCEPTION
		SET viSqlErr, viSamErr
		LET CodRetorno = viSqlErr;
		LET DescRetorno = viSamErr;
		RETURN CodRetorno, DescRetorno;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
		   
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
	
	--LET vsql ='';
    --LET vsql ='rm /informix/Esmeralda/SpParametrico/sqexplain.out';
    --SYSTEM vsql;
	---------------------------------------------------
	SET ISOLATION TO DIRTY READ;
	SELECT  fecha_hoy,ult_dia_mes  INTO vfecha_hoy,vult_dia_mes FROM  bdinteg:si_fechas WHERE empresa='001';   
	---------------------------------------------------
      IF ((vfecha_hoy::DATE) = (vult_dia_mes)) THEN 
        LET CodRetorno = '00018';
        LET DescRetorno = 'No es posible ejecutar los últimos días del mes.';
        RETURN CodRetorno, DescRetorno;
 	  ELIF (DAY(vfecha_hoy) = 15)  THEN 
		LET CodRetorno = '00019';
		LET DescRetorno = 'No es posible ejecutar los días 15 del mes.';
		RETURN CodRetorno, DescRetorno;
	  ELIF (DAY(vfecha_hoy) = 20)  THEN 
		LET CodRetorno = '00020';
		LET DescRetorno = 'No es posible ejecutar los días 20 del mes.';
		RETURN CodRetorno, DescRetorno;
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
	 
	IF(psProducto = '') THEN	    
		LET det_Producto = 'T'; --Todos
		ELSE
        LET det_Producto = 'A'; --Solo uno
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
	 
	 
	SET ISOLATION TO DIRTY READ;
    IF EXISTS (SELECT {+AVOID_FULL(sysmaster:SysTabNames)} dbsname, tabname FROM  sysmaster:SysTabNames  WHERE tabname = 'rptdina_movimiento' AND dbsname= 'intercard') THEN
        DROP TABLE intercard:rptdina_movimiento;
    END IF;
		
	SET ISOLATION TO DIRTY READ ;
    IF EXISTS (SELECT {+AVOID_FULL(sysmaster:SysTabNames)} dbsname, tabname FROM  sysmaster:SysTabNames  WHERE tabname = 'rptdina_movimientohist' AND dbsname= 'intercard') THEN
        DROP TABLE intercard:rptdina_movimientohist;
    END IF;
	 
	SET ISOLATION TO DIRTY READ ;
    IF EXISTS (SELECT {+AVOID_FULL(sysmaster:SysTabNames)} dbsname, tabname FROM  sysmaster:SysTabNames  WHERE tabname = 'rptdina_movimientoambos' AND dbsname= 'intercard') THEN
        DROP TABLE intercard:rptdina_movimientoambos;
    END IF;
	 
	SET ISOLATION TO DIRTY READ ;
    IF EXISTS (SELECT {+AVOID_FULL(sysmaster:SysTabNames)} dbsname, tabname FROM  sysmaster:SysTabNames  WHERE tabname = 'pasoambos' AND dbsname= 'intercard') THEN
        DROP TABLE intercard:pasoambos;
    END IF;
	 
	let pdtFechaFin = pdtFechaFin;
	let vdtFechaFin = vdtFechaFin;
	 
	 --Validación de Parámetros (Se deben de validar que todos los parámetros cumplan las condiciones necesarias		

	IF 
		(pdtFechaIni < current::date - 365) OR (pdtFechaIni is null) THEN --ERROR : pdtFechaIni
		LET CodRetorno = '00001';
		LET DescRetorno = 'Fecha-Inicio es Mayor a 365 días. Verificar.';
		RETURN CodRetorno, DescRetorno;
		
		ELIF (pdtFechaFin > current::date) OR (pdtFechaFin is null)  THEN --ERROR : pdtFechaFin 	
		LET CodRetorno = '00002';
		LET DescRetorno = 'Fecha-Fin es Mayor al día actual. Verificar.';
		RETURN CodRetorno, DescRetorno;

		ELIF (select {+AVOID_FULL (bdinteg:si_estados) } {+INDEX (bdinteg:si_estados inx_estado)} count(estado) from bdinteg:si_estados where (det_Estado = 'A' AND estado = psEstado) OR (det_Estado = 'T' AND 1 = 1)) = 0 THEN --ERROR : psEstado
		LET CodRetorno = '00003';
		LET DescRetorno = 'Código-Estado no reconocido. Verificar.';
		RETURN CodRetorno, DescRetorno;

		ELIF (select count(ciudad) from bdinteg:si_ciudades where (det_Ciudad = 'A' AND ciudad = psCiudad) OR (det_Ciudad = 'T' AND 1 = 1)) = 0 THEN --ERROR : psCiudad
		LET CodRetorno = '00004';
		LET DescRetorno = 'Código-Ciudad no reconocido. Verificar.';
		RETURN CodRetorno, DescRetorno;

		ELIF (select {+AVOID_FULL (bines)} {+INDEX (bines idx_bines)} count(bin) from intercard:bines where (det_bin = 'A' AND bin = psBin) OR (det_bin = 'T' AND 1 = 1)) = 0 THEN --ERROR : psBin	
		LET CodRetorno = '00005';
		LET DescRetorno = 'Bin no reconocido. Verificar.';
		RETURN CodRetorno, DescRetorno;
		
		--NUEVA VALIDACIÓN PARA EL CAMPO SUB BIN
		ELIF (select {+AVOID_FULL (productoimagen)} count(producto) from intercard:productoimagen where (det_SubBin = 'A' AND producto = psSubBin) OR (det_SubBin = 'T' AND 1 = 1)) = 0 THEN --ERROR : psBin	
		LET CodRetorno = '00021';
		LET DescRetorno = 'Sub Bin no reconocido. Verificar.';
		RETURN CodRetorno, DescRetorno;

		ELIF (psChipBanda <> 'C' AND psChipBanda <> 'B' and psChipBanda <> '') THEN --ERROR : psChipBanda	
		LET CodRetorno = '00006';
		LET DescRetorno = 'Valor Chip-Banda no reconocido. Verificar.';
		RETURN CodRetorno, DescRetorno;
			 
		ELIF (select {+AVOID_FULL (productotarjeta) } count(codproductotarjeta) from intercard:productotarjeta where (det_ProductoInterCard = 'A' AND codproductotarjeta = psProductoInterCard) OR (det_ProductoInterCard = 'T' AND 1 = 1)) = 0 THEN --ERROR : psProductoInterCard
		LET CodRetorno = '00007';
		LET DescRetorno = 'Producto-Tarjeta no reconocido. Verificar.';
		RETURN CodRetorno, DescRetorno;
	 
		ELIF (psProdInd <> 'A' AND psProdInd <> 'P' AND psProdInd <> '') THEN --ERROR : psProdInd	
		LET CodRetorno = '00008';
		LET DescRetorno = 'Tipo-Terminal no reconocido. Verificar.';
		RETURN CodRetorno, DescRetorno;

		ELIF (
				psMetodoCaptura <> '00' AND psMetodoCaptura <> '01' AND psMetodoCaptura <> '02' AND psMetodoCaptura <> '05' AND
				psMetodoCaptura <> '09' AND psMetodoCaptura <> '80' AND psMetodoCaptura <> '81' AND psMetodoCaptura <> '90' AND
				psMetodoCaptura <> '92' AND psMetodoCaptura <> ''
			 ) THEN --ERROR : psMetodoCaptura	
		LET CodRetorno = '00009';
		LET DescRetorno = 'Método-Captura no reconocido. Verificar.';
		RETURN CodRetorno, DescRetorno;

		ELIF LENGTH(NVL(psGiroComercio, '')) > 4 AND psGiroComercio <> '' THEN --ERROR : psGiroComercio	 --Revisar
		LET CodRetorno = '00010';
		LET DescRetorno = 'Giro-Comercio no reconocido. Verificar.';
		RETURN CodRetorno, DescRetorno;

		ELIF (psOrigen <> 'N' AND psOrigen <> 'I' AND psOrigen <> '') THEN --ERROR : psOrigen	
		LET CodRetorno = '00011';
		LET DescRetorno = 'Origen-Transacción no reconocido. Verificar.';
		RETURN CodRetorno, DescRetorno;

		ELIF (select {+AVOID_FULL (respuestaiso)} count(codigoiso) from intercard:respuestaiso where (det_codigoiso = 'A' AND codigoiso = pscodigoiso) OR (det_codigoiso = 'T' AND 1 = 1)) = 0 THEN --ERROR : pscodigoiso
		LET CodRetorno = '00012';
		LET DescRetorno = 'Código-ISO no reconocido. Verificar.';
		RETURN CodRetorno, DescRetorno;

		ELIF ((substring(psfechaexp from 3 for 2) < 1 OR substring(psfechaexp from 3 for 2) > 12)) and psfechaexp <> '' THEN --ERROR : psfechaexp
		LET CodRetorno = '00013';
		LET DescRetorno = 'Fecha-Expiración-Tarjeta no reconocida. Verificar.';
		RETURN CodRetorno, DescRetorno;
			                               
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
		RETURN CodRetorno, DescRetorno;
			 
		ELIF (((psProdInd = '01') AND (LENGTH(NVL(psIDTerminalRetailer, '')) > 16) AND (NVL(psIDTerminalRetailer, '') <> ''))
				OR ((psProdInd = '02') AND (LENGTH(NVL(psIDTerminalRetailer, '')) > 19) AND (NVL(psIDTerminalRetailer, '') <> ''))) THEN --ERROR : psIDTerminalRetailer
		LET CodRetorno = '00015';
		LET DescRetorno = 'No. Afiliación-Terminal no reconocido. Verificar.';
		RETURN CodRetorno, DescRetorno;
	 	 
		ELIF (psProducto <> 'C' AND psProducto <> 'D' AND psProducto <> '' ) THEN --ERROR : psProducto
		LET CodRetorno = '00016';
		LET DescRetorno = 'Producto no reconocido. Verificar.';
		RETURN CodRetorno, DescRetorno;
		
        ELIF  ((pdtFechaFin) - (pdtFechaIni))  > 31  THEN 
        LET CodRetorno = '00017';
        LET DescRetorno = 'Rango supera los 31 días de consulta. Verificar.';
        RETURN CodRetorno, DescRetorno;
		
		let pdtFechaFin = pdtFechaFin;
	    let vdtFechaFin = vdtFechaFin;
		
		ELSE
			LET vdtFechaIni = pdtFechaIni;
			LET vdtFechaIni = SUBSTRING(vdtFechaIni FROM 1 FOR 10) || ' 00:00:00';
			LET vdtFechaFin = pdtFechaFin;
			LET vdtFechaFin = SUBSTRING(vdtFechaFin FROM 1 FOR 10) || ' 23:59:59';
			LET vdtFechaAux = CURRENT;
			
	        LET vcAAAAMMDDHHMMSS = SUBSTRING(vdtFechaAux FROM 0 FOR 20);
			let pdtFechaFin = pdtFechaFin;
			let vdtFechaFin = vdtFechaFin;

		--OBTIENE LA FECHA MINIMA DE LA TABLA DE MOVIMIENTOS
		
--		LET chFlgTrace = 'Calculo Fecha-Min';
		
		CREATE TABLE "informix".rptdina_movimiento
		( 
			numCliente					VARCHAR(13), 
			noEstado					VARCHAR(2), 
			nombreEstado				VARCHAR(30), 
			noCiudad					VARCHAR(3), 
			nombreCiudad				VARCHAR(60), 
			canal						VARCHAR(3), 
			ChipBanda					VARCHAR(5), 
			bin							VARCHAR(6), 
			SubBin                      VARCHAR(2),
			productoInterCard			VARCHAR(3), 
			descProductoInterCard		VARCHAR(30),
			producto					VARCHAR(1), 
			cuentaProducto				VARCHAR(13), 
			metodoCaptura				VARCHAR(2), 
			tipotransaccionposdigitada	VARCHAR(2), 
			terminacionTarjeta			VARCHAR(4), 
			fechaExpiracion				VARCHAR(4), 
			fechaTransaccion			DATE, 
			origen						VARCHAR(03),
			nombreComercio				VARCHAR(40), 
			giroComercio				VARCHAR(4), 
			descGiroNeg					VARCHAR(80), 
			idPosATM					VARCHAR(19), 
			TipoTransaccion				VARCHAR(12), 
			monto						DECIMAL(19,2), 
			montoCashBack				DECIMAL(19,2), 
			montoSurcharge				DECIMAL(19,2), 
			codigoIso					VARCHAR(2), 
			motivoRechazo				VARCHAR(70)
			--primary key (fechaTransaccion)
		) EXTENT SIZE 3200 NEXT SIZE 320 LOCK MODE ROW;

CREATE INDEX "informix".idx_rptdina_movimiento
    ON "informix".rptdina_movimiento (numCliente) ONLINE;

SET pdqpriority 0;
UPDATE STATISTICS MEDIUM FOR TABLE "informix".rptdina_movimiento;


		SELECT {+INDEX(intercard:"informix".movimiento "informix".idx_fechahorainauth)} MIN(FechaHoraInAuth)
			INTO vdtFechaAux
		FROM intercard:"informix".movimiento;			
	
				IF (
					(pdtFechaIni >= vdtFechaAux::DATE AND pdtFechaIni <= CURRENT::DATE)
					AND 
					(pdtFechaFin >= vdtFechaAux::DATE AND pdtFechaFin <= CURRENT::DATE)
				   )	THEN --VALIDA SI EL RANGO DE BUSQUEDA ESTA DENTRO DE LA TABLA <MOVIMIENTO>

--					LET chFlgTrace = 'Entrada ForEach-movimiento';
					
					INSERT INTO "informix".rptdina_movimiento   
					(numCliente, noEstado, nombreEstado, noCiudad, nombreCiudad, canal, ChipBanda, bin, SubBin, productoInterCard, 
					 descProductoInterCard, producto, cuentaProducto, metodoCaptura, tipotransaccionposdigitada, terminacionTarjeta, 
					 fechaExpiracion, fechaTransaccion, origen, nombreComercio, giroComercio, descGiroNeg, idPosATM, TipoTransaccion, 
					 monto, montoCashBack, montoSurcharge, codigoIso, motivoRechazo)
						
						SELECT {+AVOID_FULL (movimiento) } {+INDEX(intercard:"informix".movimiento "informix".idx_fechahorainauth)}
							tjt.numcliente, 
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
								 WHEN prodind = '02' THEN (select {+AVOID_FULL (gironegocio)}  {+INDEX (gironegocio idx_gironegocio)} descgironeg from gironegocio where codgironeg = mv.codgironeg and (tipotarjeta =  bin.creditodebito OR tipotarjeta = 'A'))
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

						FROM intercard:"informix".movimiento mv
							LEFT JOIN intercard:"informix".tarjeta tjt on tjt.numtarjeta = mv.numtarjeta      
							LEFT JOIN intercard:"informix".lote lte on tjt.numerolote = lte.numerolote
							LEFT JOIN intercard:"informix".tipotarjeta tpo on tpo.clave_tipotarjeta = lte.clave_tipotarjeta
							LEFT JOIN intercard:"informix".tarjetacuenta cta on cta.numtarjeta = mv.Numtarjeta
							LEFT JOIN bdinteg:"informix".si_direcciones_actual dir on dir.numcte = tjt.numcliente                                              
							LEFT JOIN intercard:"informix".bines bin on bin.bin = tpo.bin
							--LEFT JOIN intercard:"informix".productoimagen subbin on subbin.producto =  substring(mv.numtarjeta from 7 for 2)
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
							--AND substring(mv.numtarjeta from 7 for 2) = subbin.producto
							AND ((det_producto = 'A' AND bin.creditodebito = psProducto) OR (det_producto = 'T' AND 1 = 1))    
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
								OR (det_CodigoIso = 'T' AND 1 = 1))
							AND mv.formato in ('0200','0220','0221','0420')                             --Solo considerar Operaciones Normales, Forzadas y Forzadas Recurrentes; las reversas solo se consideraran cuando son parciales
							AND mv.codtran not in ('91','92','93','94','95','97')                  --No considerar transacciones de NIP de sucursal o contraseñas del portal. Se elimina codigo 96 (No hay registro de él en tablas de movimientos/historico).
							AND (mv.codreversa = 0 or mv.codreversa = 2)                                --Solo considera transacciones completas o reversadas parcialmente
							AND mv.movreversado = 'F'                                                   --No se contabilizan transacciones reversadas
							AND mv.metodocaptura is not null 
							AND mv.metodocaptura != ('null')                                            --Solo considerar métodos de captura válidos, para un 0420 viene vacío

							ORDER BY tjt.numcliente DESC;
						
						LET viContador = viContador + 1;
			
--				LET chFlgTrace = 'Salida ForEach-movimiento';

--- Genera Reporte:

				let vaniomes=  vaniomes;
				let vsql = ''; 	
	            let vsql = 'echo "UNLOAD TO /resplogifx/Rpt_Dinamico_'||vaniomes||'.txt '||
               'SELECT * FROM "informix".rptdina_movimiento;">/resplogifx/rebandos.sql';
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

				DROP TABLE rptdina_movimiento;
			
				RETURN CodRetorno, DescRetorno;

			ELIF
					(
						(pdtFechaIni < vdtFechaAux::DATE) 
						AND (pdtFechaFin < vdtFechaAux::DATE)
					)	THEN --VALIDA SI EL RANGO DE BUSQUEDA ESTA DENTRO DE LA TABLA <MOVIMIENTOHISTORICO>

		CREATE TABLE "informix".rptdina_movimientohist
		( 
			numCliente					VARCHAR(13), 
			noEstado					VARCHAR(2), 
			nombreEstado				VARCHAR(30), 
			noCiudad					VARCHAR(3), 
			nombreCiudad				VARCHAR(60), 
			canal						VARCHAR(3), 
			ChipBanda					VARCHAR(5), 
			bin							VARCHAR(6), 
			SubBin						VARCHAR(2),
			productoInterCard			VARCHAR(3), 
			descProductoInterCard		VARCHAR(30),
			producto					VARCHAR(1), 
			cuentaProducto				VARCHAR(13), 
			metodoCaptura				VARCHAR(2), 
			tipotransaccionposdigitada  VARCHAR(2), 
			terminacionTarjeta			VARCHAR(4), 
			fechaExpiracion				VARCHAR(4), 
			fechaTransaccion			DATE, 
			origen						VARCHAR(03),
			nombreComercio				VARCHAR(40), 
			giroComercio				VARCHAR(4), 
			descGiroNeg					VARCHAR(80), 
			idPosATM					VARCHAR(19), 
			TipoTransaccion				VARCHAR(12), 
			monto						DECIMAL(19,2), 
			montoCashBack				DECIMAL(19,2), 
			montoSurcharge				DECIMAL(19,2), 
			codigoIso					VARCHAR(2), 
			motivoRechazo				VARCHAR(70)
		) EXTENT SIZE 3200 NEXT SIZE 320 LOCK MODE ROW;

CREATE INDEX "informix".idx_rptdina_movimientohist
    ON "informix".rptdina_movimientohist (numCliente) ONLINE;

SET pdqpriority 0;
UPDATE STATISTICS MEDIUM FOR TABLE "informix".rptdina_movimientohist;

					

					let vcAAAAMMDDHHMMSS = vcAAAAMMDDHHMMSS;
                       
						INSERT INTO "informix".rptdina_movimientohist (numCliente, noEstado, nombreEstado, noCiudad, nombreCiudad, canal, ChipBanda, bin, SubBin, productoInterCard, 
																   descProductoInterCard, producto, cuentaProducto, metodoCaptura, tipotransaccionposdigitada, terminacionTarjeta, 
																   fechaExpiracion, fechaTransaccion, origen, nombreComercio, giroComercio, descGiroNeg, idPosATM, TipoTransaccion, 
																   monto, montoCashBack, montoSurcharge, codigoIso, motivoRechazo)
																   
						SELECT {+AVOID_FULL (movimientohistorico) } {+INDEX(intercard:"informix".movimientohistorico "informix".idx_movimiento3)}
							tjt.numcliente, 
							dir.estado as noEstado,
							(select {+AVOID_FULL (bdinteg:si_estados) } {+INDEX (bdinteg:si_estados inx_estado)} nombre from bdinteg:si_estados where estado = dir.estado) as nombreEstado,
							dir.ciudad as noCiudad,
							(select {+AVOID_FULL (bdinteg:si_ciudades) } nombre from bdinteg:si_ciudades where dir.estado = estado and dir.ciudad = ciudad) as nombreCiudad,
							case when mvh.prodind = '01' THEN 'ATM' 
								 when mvh.prodind = '02' THEN 'POS'
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
							mvh.metodocaptura,
							mvh.tipotransaccionposdigitada,       
							substring(mvh.numtarjeta from 13 for 4) as terminaTarjeta,
							tjt.fechaexp,
							date(mvh.fechahorainauth) as Fecha,
							case when mvh.esnacional = 'V' THEN 'NAC'
								 when mvh.esnacional = 'F' THEN 'INT'
							end as txnOrigen,
							mvh.infreceptor as comercio,
							case WHEN prodind = '01' THEN mvh.idreceptor
								 WHEN prodind = '02' THEN mvh.codgironeg 
							end as giroComercio,
							case WHEN prodind = '01' THEN 'CAJERO AUTOMÁTICO'
								 WHEN prodind = '02' THEN (select {+AVOID_FULL (gironegocio)}  {+INDEX (gironegocio idx_gironegocio)} descgironeg from gironegocio where codgironeg = mvh.codgironeg and (tipotarjeta =  bin.creditodebito OR tipotarjeta = 'A'))
							end as descGiroComercio,
							case WHEN prodind = '01' THEN mvh.idterminal
								 WHEN prodind = '02' THEN mvh.idretailer
							end as afiliacionTerminal,
							case when prodind = '01' and  codtran = '01' then 'Retiro ATM'
								 when prodind = '01' and  codtran = '31' then 'Consulta ATM'
								 when prodind = '02' then 'Compras POS'           
							end as TipoTransaccion,
							case when (mvh.formato = '0420' and mvh.codreversa = 2) then mvh.montorealrevfzda
								 when (mvh.formato <> '0420' and mvh.codreversa = 0) then mvh.monto
							end as montoTxn,
							case when (mvh.formato = '0420' and mvh.codreversa = 2) then mvh.montocashback
								 when (mvh.formato <> '0420' and mvh.codreversa = 0) then mvh.montocashback
							end as montoCashBack,       
							mvh.montosurcharge as montoSurcharge,
							mvh.codigoiso,
							case when mvh.codigoiso  = '00' then 'Transacción Aprobada'
								 when mvh.codigoiso <> '00' then mvh.motivo 
							end as motivo

						FROM intercard:"informix".movimientohistorico mvh
							LEFT JOIN intercard:"informix".tarjeta tjt on tjt.numtarjeta = mvh.numtarjeta      
							LEFT JOIN intercard:"informix".lote lte on tjt.numerolote = lte.numerolote
							LEFT JOIN intercard:"informix".tipotarjeta tpo on tpo.clave_tipotarjeta = lte.clave_tipotarjeta
							LEFT JOIN intercard:"informix".tarjetacuenta cta on cta.numtarjeta = mvh.Numtarjeta
							LEFT JOIN bdinteg:"informix".si_direcciones_actual dir on dir.numcte = tjt.numcliente                                              
							LEFT JOIN intercard:"informix".bines bin on bin.bin = tpo.bin
							--LEFT JOIN intercard:"informix".productoimagen subbin on subbin.producto =  substring(mvh.numtarjeta from 7 for 2)
						WHERE 
							mvh.FechaHoraInAuth BETWEEN vdtFechaIni AND vdtFechaFin
							AND dir.numcte = tjt.numcliente and dir.pais = '001' and dir.tipo_dir = '1' 
							AND ((det_Estado = 'A' and dir.estado = psEstado) OR (det_Estado = 'T' AND 1 = 1))
							AND ((det_Ciudad = 'A' and dir.ciudad = psCiudad) OR (det_Ciudad = 'T' AND 1 = 1))
							AND ((det_Prodind = 'A' AND mvh.ProdInd = det_ProdInd2) OR (det_Prodind = 'T' AND 1 = 1))
							AND tpo.clave_tipotarjeta = lte.clave_tipotarjeta
							AND ((det_ChipBanda = 'A' and tpo.chip = det_ChipBanda2) OR (det_ChipBanda = 'T' and 1 = 1))
							AND ((det_bin ='A' AND substring(mvh.numtarjeta from 1 for 6) = psBin) OR (det_bin = 'T' AND 1 = 1))
							AND ((det_SubBin ='A' AND substring(mvh.numtarjeta from 7 for 2) = psSubBin) OR (det_Subbin = 'T' AND 1 = 1))
							AND ((det_productoInterCard = 'A' AND tjt.codproductotarjeta = psProductoInterCard) 
								OR (det_productoInterCard = 'T' AND 1 = 1))
							AND substring(mvh.numtarjeta from 1 for 6) = bin.bin 
							--AND substring(mvh.numtarjeta from 7 for 2) = subbin.producto 
							AND ((det_producto = 'A' AND bin.creditodebito = psProducto) OR (det_producto = 'T' AND 1 = 1))    
							AND((det_MetodoCaptura = 'A' AND mvh.metodocaptura = psMetodoCaptura) OR (det_MetodoCaptura = 'T' AND 1 = 1))
							AND((det_tipotransaccionposdigitada = 'A' AND mvh.tipotransaccionposdigitada = pstipotransaccionposdigitada) 
								OR (det_tipotransaccionposdigitada = 'T' AND 1 = 1))
							AND((det_FechaExp = 'A' AND tjt.fechaexp = psFechaExp) OR (det_FechaExp = 'T' AND 1 = 1))
							AND((det_Origen = 'A' AND mvh.esnacional = det_Origen2) OR (det_Origen = 'T' AND 1 = 1))
							AND((det_GiroComercio = 'A' AND mvh.codgironeg = psGiroComercio) OR (det_GiroComercio = 'T' AND 1 = 1))						
							AND((det_IDTerminalRetailer = 'A' AND mvh.IdTerminal = psIDTerminalRetailer) 
							 OR (det_IDTerminalRetailer = 'A' AND mvh.IdRetailer = psIDTerminalRetailer) 
							 OR (det_IDTerminalRetailer = 'T' AND 1 = 1))
							AND((det_TerminalRetailer = 'T' AND mvh.IdTerminal = psIDTerminalRetailer)
							 OR (det_TerminalRetailer = 'T' AND 1 = 1)
							 OR (det_TerminalRetailer = 'R' AND mvh.IdRetailer = psIDTerminalRetailer) 
							 OR (det_TerminalRetailer = 'R' AND 1 = 1)
							 OR (det_TerminalRetailer = 'A' AND 1 = 1))
							AND((det_CodigoIso = 'A' AND mvh.codigoiso = psCodigoIso) 
								OR (det_CodigoIso = 'T' AND 1 = 1))
							AND mvh.formato in ('0200','0220','0221','0420')                             --Solo considerar Operaciones Normales, Forzadas y Forzadas Recurrentes; las reversas solo se consideraran cuando son parciales
							AND mvh.codtran not in ('91','92','93','94','95','97')                  --No considerar transacciones de NIP de sucursal o contraseñas del portal. Se elimina codigo 96 (No hay registro de él en tablas de movimientos/historico).
							AND (mvh.codreversa = 0 or mvh.codreversa = 2)                                --Solo considera transacciones completas o reversadas parcialmente
							AND mvh.movreversado = 'F'                                                   --No se contabilizan transacciones reversadas
							AND mvh.metodocaptura is not null 
							AND mvh.metodocaptura != ('null')                                            --Solo considerar métodos de captura válidos, para un 0420 viene vacío						
							
							ORDER BY tjt.numcliente DESC;

						LET viContador = viContador + 1;

				
				let vaniomes=  vaniomes;
				let vsql = ''; 	
	            let vsql = 'echo "UNLOAD TO /resplogifx/Rpt_Dinamico_'||vaniomes||'.txt '||
                'SELECT * FROM "informix".rptdina_movimientohist;">/resplogifx/rebandos.sql';
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
				system vsql;

				DROP TABLE rptdina_movimientohist;
			
				RETURN CodRetorno, DescRetorno; 

			ELSE
				
--					LET chFlgTrace = 'Entrada ForEach-Ambas';		
 let pdtFechaFin = pdtFechaFin;
	 let vdtFechaFin = vdtFechaFin;		
				
		CREATE TABLE "informix".rptdina_movimientoambos
		( 
			numCliente					VARCHAR(13), 
			noEstado					VARCHAR(2), 
			nombreEstado				VARCHAR(30), 
			noCiudad					VARCHAR(3), 
			nombreCiudad				VARCHAR(60), 
			canal						VARCHAR(3), 
			ChipBanda					VARCHAR(5), 
			bin							VARCHAR(6), 
			SubBin						VARCHAR(2),
			productoInterCard			VARCHAR(3), 
			descProductoInterCard		VARCHAR(30),
			producto					VARCHAR(1), 
			cuentaProducto				VARCHAR(13), 
			metodoCaptura				VARCHAR(2), 
			tipotransaccionposdigitada  VARCHAR(2), 
			terminacionTarjeta			VARCHAR(4), 
			fechaExpiracion				VARCHAR(4), 
			fechaTransaccion			DATE, 
			origen						VARCHAR(03),
			nombreComercio				VARCHAR(40), 
			giroComercio				VARCHAR(4), 
			descGiroNeg					VARCHAR(80), 
			idPosATM					VARCHAR(19), 
			TipoTransaccion				VARCHAR(12), 
			monto						DECIMAL(19,2), 
			montoCashBack				DECIMAL(19,2), 
			montoSurcharge				DECIMAL(19,2), 
			codigoIso					VARCHAR(2), 
			motivoRechazo				VARCHAR(70)
			--primary key (fechaTransaccion)
		) EXTENT SIZE 320 NEXT SIZE 32 LOCK MODE ROW;

CREATE INDEX "informix".idx_rptdina_movimientoambos
    ON "informix".rptdina_movimientoambos (numCliente) ONLINE;

SET pdqpriority 0;
UPDATE STATISTICS MEDIUM FOR TABLE "informix".rptdina_movimientoambos;

					
--					LET chFlgTrace = 'Entrada ForEach-movimientohistorico';

						SELECT {+AVOID_FULL (movimiento) } {+INDEX(intercard:"informix".movimiento "informix".idx_fechahorainauth)}  
							tjt.numcliente, 
							dir.estado as noEstado,
							(select  {+AVOID_FULL (bdinteg:si_estados) } {+INDEX (bdinteg:si_estados inx_estado)}  nombre from bdinteg:si_estados where estado = dir.estado) as nombreEstado,
							dir.ciudad as noCiudad,
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
								 WHEN prodind = '02' THEN (select {+AVOID_FULL (gironegocio)}  {+INDEX (gironegocio idx_gironegocio)} descgironeg from gironegocio where codgironeg = mv.codgironeg and (tipotarjeta =  bin.creditodebito OR tipotarjeta = 'A'))
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

						FROM intercard:"informix".movimiento mv
							LEFT JOIN intercard:"informix".tarjeta tjt on tjt.numtarjeta = mv.numtarjeta      
							LEFT JOIN intercard:"informix".lote lte on tjt.numerolote = lte.numerolote
							LEFT JOIN intercard:"informix".tipotarjeta tpo on tpo.clave_tipotarjeta = lte.clave_tipotarjeta
							LEFT JOIN intercard:"informix".tarjetacuenta cta on cta.numtarjeta = mv.Numtarjeta
							LEFT JOIN bdinteg:"informix".si_direcciones_actual dir on dir.numcte = tjt.numcliente                                              
							LEFT JOIN intercard:"informix".bines bin on bin.bin = tpo.bin
							--LEFT JOIN intercard:"informix".productoimagen subbin on subbin.producto =  substring(mv.numtarjeta from 7 for 2)
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
							--AND substring(mv.numtarjeta from 7 for 2) = subbin.producto
							AND ((det_producto = 'A' AND bin.creditodebito = psProducto) OR (det_producto = 'T' AND 1 = 1))    
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
								OR (det_CodigoIso = 'T' AND 1 = 1))
							AND mv.formato in ('0200','0220','0221','0420')                             --Solo considerar Operaciones Normales, Forzadas y Forzadas Recurrentes; las reversas solo se consideraran cuando son parciales
							AND mv.codtran not in ('91','92','93','94','95','97')                  --No considerar transacciones de NIP de sucursal o contraseñas del portal. Se elimina codigo 96 (No hay registro de él en tablas de movimientos/historico).
							AND (mv.codreversa = 0 or mv.codreversa = 2)                                --Solo considera transacciones completas o reversadas parcialmente
							AND mv.movreversado = 'F'                                                   --No se contabilizan transacciones reversadas
							AND mv.metodocaptura is not null 
							AND mv.metodocaptura != ('null')                                       --Solo considerar métodos de captura válidos, para un 0420 viene vacío

					   UNION ALL
							
						SELECT {+AVOID_FULL (movimientohistorico) } {+INDEX(intercard:"informix".movimientohistorico "informix".idx_movimiento3)}
							tjt.numcliente, 
							dir.estado as noEstado,
							(select {+AVOID_FULL (bdinteg:si_estados) } {+INDEX (bdinteg:si_estados inx_estado)} nombre from bdinteg:si_estados where estado = dir.estado) as nombreEstado,
							dir.ciudad as noCiudad,
							(select {+AVOID_FULL (bdinteg:si_ciudades) } nombre from bdinteg:si_ciudades where dir.estado = estado and dir.ciudad = ciudad) as nombreCiudad,
							case when mvh.prodind = '01' THEN 'ATM' 
								 when mvh.prodind = '02' THEN 'POS'
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
							mvh.metodocaptura,
							mvh.tipotransaccionposdigitada,       
							substring(mvh.numtarjeta from 13 for 4) as terminaTarjeta,
							tjt.fechaexp,
							date(mvh.fechahorainauth) as Fecha,
							case when mvh.esnacional = 'V' THEN 'NAC'
								 when mvh.esnacional = 'F' THEN 'INT'
							end as txnOrigen,
							mvh.infreceptor as comercio,
							case WHEN prodind = '01' THEN mvh.idreceptor
								 WHEN prodind = '02' THEN mvh.codgironeg 
							end as giroComercio,
							case WHEN prodind = '01' THEN 'CAJERO AUTOMÁTICO'
								 WHEN prodind = '02' THEN (select {+AVOID_FULL (gironegocio)}  {+INDEX (gironegocio idx_gironegocio)} descgironeg from gironegocio where codgironeg = mvh.codgironeg and (tipotarjeta =  bin.creditodebito OR tipotarjeta = 'A'))
							end as descGiroComercio,
							case WHEN prodind = '01' THEN mvh.idterminal
								 WHEN prodind = '02' THEN mvh.idretailer
							end as afiliacionTerminal,
							case when prodind = '01' and  codtran = '01' then 'Retiro ATM'
								 when prodind = '01' and  codtran = '31' then 'Consulta ATM'
								 when prodind = '02' then 'Compras POS'           
							end as TipoTransaccion,
							case when (mvh.formato = '0420' and mvh.codreversa = 2) then mvh.montorealrevfzda
								 when (mvh.formato <> '0420' and mvh.codreversa = 0) then mvh.monto
							end as montoTxn,
							case when (mvh.formato = '0420' and mvh.codreversa = 2) then mvh.montocashback
								 when (mvh.formato <> '0420' and mvh.codreversa = 0) then mvh.montocashback
							end as montoCashBack,       
							mvh.montosurcharge as montoSurcharge,
							mvh.codigoiso,
							case when mvh.codigoiso  = '00' then 'Transacción Aprobada'
								 when mvh.codigoiso <> '00' then mvh.motivo 
							end as motivo

						FROM intercard:"informix".movimientohistorico mvh
							LEFT JOIN intercard:"informix".tarjeta tjt on tjt.numtarjeta = mvh.numtarjeta      
							LEFT JOIN intercard:"informix".lote lte on tjt.numerolote = lte.numerolote
							LEFT JOIN intercard:"informix".tipotarjeta tpo on tpo.clave_tipotarjeta = lte.clave_tipotarjeta
							LEFT JOIN intercard:"informix".tarjetacuenta cta on cta.numtarjeta = mvh.Numtarjeta
							LEFT JOIN bdinteg:"informix".si_direcciones_actual dir on dir.numcte = tjt.numcliente                                              
							LEFT JOIN intercard:"informix".bines bin on bin.bin = tpo.bin
							--LEFT JOIN intercard:"informix".productoimagen subbin on subbin.producto =  substring(mvh.numtarjeta from 7 for 2)
						WHERE 
							mvh.FechaHoraInAuth BETWEEN vdtFechaIni AND vdtFechaFin
							AND dir.numcte = tjt.numcliente and dir.pais = '001' and dir.tipo_dir = '1' 
							AND ((det_Estado = 'A' and dir.estado = psEstado) OR (det_Estado = 'T' AND 1 = 1))
							AND ((det_Ciudad = 'A' and dir.ciudad = psCiudad) OR (det_Ciudad = 'T' AND 1 = 1))
							AND ((det_Prodind = 'A' AND mvh.ProdInd = det_ProdInd2) OR (det_Prodind = 'T' AND 1 = 1))
							AND tpo.clave_tipotarjeta = lte.clave_tipotarjeta
							AND ((det_ChipBanda = 'A' and tpo.chip = det_ChipBanda2) OR (det_ChipBanda = 'T' and 1 = 1))
							AND ((det_bin ='A' AND substring(mvh.numtarjeta from 1 for 6) = psBin) OR (det_bin = 'T' AND 1 = 1))
							AND ((det_SubBin ='A' AND substring(mvh.numtarjeta from 7 for 2) = psSubBin) OR (det_SubBin = 'T' AND 1 = 1))
							AND ((det_productoInterCard = 'A' AND tjt.codproductotarjeta = psProductoInterCard) 
								OR (det_productoInterCard = 'T' AND 1 = 1))
							AND substring(mvh.numtarjeta from 1 for 6) = bin.bin 
							--AND substring(mvh.numtarjeta from 7 for 2) = subbin.producto
							AND ((det_producto = 'A' AND bin.creditodebito = psProducto) OR (det_producto = 'T' AND 1 = 1))    
							AND((det_MetodoCaptura = 'A' AND mvh.metodocaptura = psMetodoCaptura) OR (det_MetodoCaptura = 'T' AND 1 = 1))
							AND((det_tipotransaccionposdigitada = 'A' AND mvh.tipotransaccionposdigitada = pstipotransaccionposdigitada) 
								OR (det_tipotransaccionposdigitada = 'T' AND 1 = 1))
							AND((det_FechaExp = 'A' AND tjt.fechaexp = psFechaExp) OR (det_FechaExp = 'T' AND 1 = 1))
							AND((det_Origen = 'A' AND mvh.esnacional = det_Origen2) OR (det_Origen = 'T' AND 1 = 1))
							AND((det_GiroComercio = 'A' AND mvh.codgironeg = psGiroComercio) OR (det_GiroComercio = 'T' AND 1 = 1))						
							AND((det_IDTerminalRetailer = 'A' AND mvh.IdTerminal = psIDTerminalRetailer) 
							 OR (det_IDTerminalRetailer = 'A' AND mvh.IdRetailer = psIDTerminalRetailer) 
							 OR (det_IDTerminalRetailer = 'T' AND 1 = 1))
							AND((det_TerminalRetailer = 'T' AND mvh.IdTerminal = psIDTerminalRetailer)
							 OR (det_TerminalRetailer = 'T' AND 1 = 1)
							 OR (det_TerminalRetailer = 'R' AND mvh.IdRetailer = psIDTerminalRetailer) 
							 OR (det_TerminalRetailer = 'R' AND 1 = 1)
							 OR (det_TerminalRetailer = 'A' AND 1 = 1))
							AND((det_CodigoIso = 'A' AND mvh.codigoiso = psCodigoIso) 
								OR (det_CodigoIso = 'T' AND 1 = 1))
							AND mvh.formato in ('0200','0220','0221','0420')                             --Solo considerar Operaciones Normales, Forzadas y Forzadas Recurrentes; las reversas solo se consideraran cuando son parciales
							AND mvh.codtran not in ('91','92','93','94','95','97')                  --No considerar transacciones de NIP de sucursal o contraseñas del portal. Se elimina codigo 96 (No hay registro de él en tablas de movimientos/historico).
							AND (mvh.codreversa = 0 or mvh.codreversa = 2)                                --Solo considera transacciones completas o reversadas parcialmente
							AND mvh.movreversado = 'F'                                                   --No se contabilizan transacciones reversadas
							AND mvh.metodocaptura is not null 
							AND mvh.metodocaptura != ('null')                                          --Solo considerar métodos de captura válidos, para un 0420 viene vacío													
							
							INTO  temp pasoambos WITH NO LOG;
		                    CREATE INDEX idxtmp_pasoambos ON pasoambos(numcliente) USING BTREE;
                            UPDATE STATISTICS MEDIUM FOR TABLE pasoambos;
							
							

							INSERT INTO "informix".rptdina_movimientoambos (numCliente, noEstado, nombreEstado, noCiudad, nombreCiudad, canal, ChipBanda, bin, SubBin, productoInterCard, 
																	descProductoInterCard, producto, cuentaProducto, metodoCaptura, tipotransaccionposdigitada, terminacionTarjeta, 
																	fechaExpiracion, fechaTransaccion, origen, nombreComercio, giroComercio, descGiroNeg, idPosATM, TipoTransaccion, 
																	monto, montoCashBack, montoSurcharge, codigoIso, motivoRechazo)
							SELECT * FROM intercard:pasoambos;
							--ORDER BY tjt.numcliente DESC

						--LET viContador = viContador + 1;
					
--					LET chFlgTrace = 'Salida ForEach-movimientohistorico';

--- Genera Reporte:

				let vaniomes=  vaniomes;
				let vsql = ''; 	
	            let vsql = 'echo "UNLOAD TO /resplogifx/Rpt_Dinamico_'||vaniomes||'.txt '||
                'SELECT * FROM "informix".rptdina_movimientoambos;">/resplogifx/rebandos.sql';

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

				system vsql;

					DROP TABLE rptdina_movimientoambos;
					DROP TABLE pasoambos;
			
					RETURN CodRetorno, DescRetorno; 
					
				END IF;	
	END IF;	
END;
END PROCEDURE
/*DOCUMENT
'AUTOR: Luis Antonio Gómez Santiago',
'Proyecto: Reporte Paramétrico de Productos - Transacciones de Tarjetas',
'Solicito: Mónica Martinez Ulloa',
'Descripcion: GENERA REPORTE PARAMETRICO DE TRANSACCIONES DE TARJETAS',
'Fecha: 2016/03/03',
'Version: 20160303.2100',
'Modificacion: Se optimiza SP y se comprime archivo.',
'Fecha: 2016/04/14',
'Version: 20160414.1200',
'BD: INTERCARD';*/



;

CREATE PROCEDURE "informix".sp_activatarjeta_iccat(pEmpresa CHAR(3), pTipoConsulta CHAR(1), pNumCte char(9), pNumTarjeta CHAR(16), pEstatus CHAR(1))
RETURNING CHAR(9) as cCodRet;

DEFINE vsqlerr INTEGER;
DEFINE cCodRet CHAR(9);

LET vsqlerr = 0;
LET cCodRet = "000000000";

BEGIN
	ON EXCEPTION SET vsqlerr
      IF vsqlerr <> 0 THEN
		LET cCodRet = vsqlerr;
		RETURN cCodRet;
      END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/informix/tmp/sp_activatarjeta_iccat.out";
	--TRACE ON;

	SET ISOLATION DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF pTipoConsulta = 'D' THEN
		UPDATE bdicheq:'informix'.sc_tarjeta SET status_tar = pEstatus WHERE num_tarjeta = TRIM(pNumTarjeta) AND numcte = TRIM(pNumCte) and empresa = pEmpresa;
	ELIF pTipoConsulta = 'C' THEN
		UPDATE bdicred:'informix'.sd_tarjeta SET status_tar = pEstatus WHERE num_tarjeta = TRIM(pNumTarjeta) AND numcte = TRIM(pNumCte) and empresa = pEmpresa;
	END IF;

	IF dbinfo("sqlca.sqlerrd2") <> 1 THEN
		LET cCodRet = '000000001';
	END IF;

	RETURN cCodRet;

END;	
END PROCEDURE
DOCUMENT
'OBJETIVO: 	Se crea SP para actualizar el estatus de la tarjeta de crédito o débito',
'AUTOR:		José Luis Polanco Bustillo',
'FECHA : 	16/08/2017',
'BD : 		intercard';

CREATE PROCEDURE "informix".sp_limpiatarjeta_bloqueada_iccat()
	RETURNING CHAR(6), CHAR(18); -- CODIGO DE RETORNO

	DEFINE sql_err 		INTEGER ;
    DEFINE cCodret1  	CHAR(6);
	DEFINE cCodret2  	CHAR(18);
	DEFINE iNumReg		INTEGER;

    LET cCodret1  = '000000';
	LET cCodret2  = 'Ejecución Correcta';
	LET iNumReg = 0;

	--SET DEBUG FILE TO '/informix/tmp/sp_limpiatarjeta_bloqueada_iccat.out'; 
	--TRACE ON;

BEGIN
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cCodret1 = '000001';
			LET cCodret2 = 'No Existe Tabla';
			RETURN cCodret1, cCodret2;
		END IF;
	END EXCEPTION;

	SELECT COUNT(*) INTO iNumReg
	FROM "informix".stmp_tarjeta_clte_bloqueada_iccat;
	IF (iNumReg > 0) THEN		
		--TRUNCATE TABLE INTERCARD: "informix".stmp_tarjeta_clte_bloqueada_iccat DROP STORAGE;
		DELETE FROM "informix".stmp_tarjeta_clte_bloqueada_iccat;
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN		
			LET cCodret1 = '000001';
			LET cCodret2 = 'Falló Borrado';			
		END IF;
	END IF;

	RETURN cCodret1, cCodret2;
END;

END PROCEDURE

DOCUMENT
'OBJETIVO: 	Eliminar informacion contenida en la tabla stmp_tarjeta_clte_bloqueada_iccat',
'AUTOR:		Pedro Portugal',
'FECHA : 	01/06/2017',
'BD : 		INTERCARD',
'OBJETIVO: 	Se modifica procedimiento para que regrese un código de retorno de éxito o fallo, así como se modifica el borrado de la información de tabla contenedora ya que se usaba: TRUNCATE TABLE',
'AUTOR:		José Luis Polanco Bustillo',
'FECHA : 	18/10/2017',
'BD : 		INTERCARD';

CREATE PROCEDURE "informix".sp_consultartarjetas_debcred_iccat(pempresa char(3), pnumcte char(9), pstatus char (3),pNumRegistros SMALLINT)
RETURNING char(9),char(104),char(16), char(1), char(3), char(20), char(60), char(1), char(1), char(1);   

DEFINE ccodret char(9);
DEFINE isql_err integer;
DEFINE cvnumcte char (20);
DEFINE cvnomcliente char (104);
DEFINE cvnumtarjeta char (16);
DEFINE cvestatus_tar char (3);
DEFINE cvnumcuenta char (20);
DEFINE cvstatuscuenta char (60);
DEFINE cvtitular char (1);
DEFINE cvradiobuton char(1);
DEFINE cvtipotar char(1);
DEFINE cstatus_tarjeta char(1);

--@comment: Declaracion variables para tabla temporal 
DEFINE cv_trjasig_num_cte char (20);
DEFINE cv_cta_cuenta char (20);
DEFINE cv_ctast_descripcion char (60);
DEFINE cv_astrj_num_tarjeta char (16);
DEFINE cv_astrj_status_tar char(1);
DEFINE cv_trj_nombre char (104);
DEFINE cv_trj_codstatustarjeta char (3);
DEFINE cv_trj_titular char (1);

LET ccodret = "000000001"; -- NO TIENE TARJETAS 
LET cvnumcte = "";
LET cvnomcliente = "";
LET cvnumtarjeta = "";
LET cvestatus_tar = "";
LET cvnumcuenta = "";
LET cvstatuscuenta = "";
LET cvtitular = "";
LET cvradiobuton = "T";
LET cvtipotar = '';
LET cstatus_tarjeta = '';

--@comment: Inicializar variables para tabla temporal 
LET cv_trjasig_num_cte = "";
LET cv_cta_cuenta = "";
LET cv_ctast_descripcion = "";
LET cv_astrj_num_tarjeta = "";
LET cv_astrj_status_tar = '';
LET cv_trj_nombre = "";
LET cv_trj_codstatustarjeta = "";
LET cv_trj_titular = "";


BEGIN

	ON EXCEPTION SET isql_err
		IF isql_err <> 0 THEN
			let ccodret = isql_err;
			RETURN ccodret, cvnomcliente, cvnumtarjeta, cvtipotar, cvestatus_tar, cvnumcuenta, cvstatuscuenta, cvtitular, cvradiobuton, cstatus_tarjeta;
		END IF;
	END EXCEPTION;
   
	SET ISOLATION DIRTY READ;
	--SET DEBUG FILE TO '/informix/tmp/sp_consultartarjetas_debcred_iccat.out';
	--TRACE ON;
	
	--Validar y crear tabla temporal intercard:tmp_tarjetas_debcret_iccat
	SET ISOLATION TO DIRTY READ;
	IF EXISTS ( SELECT dbsname, tabname FROM sysmaster:SysTabNames  WHERE tabname = 'tmp_tarjetas_debcret_iccat' AND dbsname= 'intercard') THEN
		DROP TABLE intercard:"informix".tmp_tarjetas_debcret_iccat;
	END IF;
	CREATE TABLE intercard:"informix".tmp_tarjetas_debcret_iccat(
		numcte char(20), 
		nombre varchar(104), 
		num_tarjeta char(20),
		codstatustarjeta varchar(3),
		num_cuenta_credito char(20),
		descripcion char(60),
		titular varchar(1),
		habilitado char(1),
		tipo_tarjeta char(1),
		status_tar char(1)
	);
	
	--Obtener tarjetas de debito de las que el cliente es titular
	SET ISOLATION TO DIRTY READ;
	FOREACH WITH HOLD
		SELECT trjasig.numcte, cta.cuenta, ctaest.descripcion, trjasig.num_tarjeta, trjasig.status_tar, trj.nombre, trj.codstatustarjeta, trj.titular 
		INTO cv_trjasig_num_cte, cv_cta_cuenta, cv_ctast_descripcion, cv_astrj_num_tarjeta, cv_astrj_status_tar, cv_trj_nombre, cv_trj_codstatustarjeta, cv_trj_titular 
		FROM bdicheq:"informix".sc_maechq cta, bdicheq:"informix".sc_mae_estatus ctaest, bdicheq:'informix'.sc_tarjeta trjasig, bdicheq:'informix'.sc_producto def, intercard:'informix'.tarjeta trj 
		WHERE cta.empresa = pempresa AND ctaest.empresa = pempresa AND trjasig.empresa = pempresa 
		AND (cta.num_cte = pnumcte AND trjasig.numcte = pnumcte) 
		AND cta.status_cta = ctaest.cod_estatus 
		AND cta.cuenta = trjasig.cuenta 
		AND (trjasig.tipo_tarjeta = 'T' OR trjasig.tipo_tarjeta = 'A') AND trjasig.prodtarjeta = '2400'
		AND trjasig.prodtarjeta = def.producto
		AND trj.numtarjeta = trjasig.num_tarjeta AND trj.codstatusasignada = 'SIA' AND trj.codstatustarjeta = pstatus

		INSERT INTO intercard:"informix".tmp_tarjetas_debcret_iccat(numcte, nombre, num_tarjeta, codstatustarjeta, num_cuenta_credito, descripcion, titular, habilitado, tipo_tarjeta, status_tar)
		VALUES (cv_trjasig_num_cte, cv_trj_nombre, cv_astrj_num_tarjeta, cv_trj_codstatustarjeta, cv_cta_cuenta, cv_ctast_descripcion, cv_trj_titular, 'F', 'D', cv_astrj_status_tar);
	END FOREACH
	
	--Obtener tarjetas de debito de otros clientes de la que el cliente es adicional
	SET ISOLATION TO DIRTY READ;
	FOREACH WITH HOLD
		SELECT trjasig.numcte, cta.cuenta, ctaest.descripcion, trjasig.num_tarjeta, trjasig.status_tar, trj.nombre, trj.codstatustarjeta, trj.titular 
		INTO cv_trjasig_num_cte, cv_cta_cuenta, cv_ctast_descripcion, cv_astrj_num_tarjeta, cv_astrj_status_tar, cv_trj_nombre, cv_trj_codstatustarjeta, cv_trj_titular 
		FROM bdicheq:"informix".sc_maechq cta, bdicheq:"informix".sc_mae_estatus ctaest, bdicheq:'informix'.sc_tarjeta trjasig, bdicheq:'informix'.sc_producto def, intercard:'informix'.tarjeta trj 
		WHERE cta.empresa = pempresa AND ctaest.empresa = pempresa AND trjasig.empresa = pempresa 
		AND (cta.num_cte <> pnumcte AND trjasig.numcte = pnumcte) 
		AND cta.status_cta = ctaest.cod_estatus 
		AND cta.cuenta = trjasig.cuenta 
		AND (trjasig.tipo_tarjeta = 'T' OR trjasig.tipo_tarjeta = 'A') AND trjasig.prodtarjeta = '2400'
		AND trjasig.prodtarjeta = def.producto
		AND trj.numtarjeta = trjasig.num_tarjeta AND trj.codstatusasignada = 'SIA' AND trj.codstatustarjeta = pstatus

		INSERT INTO intercard:"informix".tmp_tarjetas_debcret_iccat(numcte, nombre, num_tarjeta, codstatustarjeta, num_cuenta_credito, descripcion, titular, habilitado, tipo_tarjeta, status_tar)
		VALUES (cv_trjasig_num_cte, cv_trj_nombre, cv_astrj_num_tarjeta, cv_trj_codstatustarjeta, cv_cta_cuenta, cv_ctast_descripcion, cv_trj_titular, 'F', 'D', cv_astrj_status_tar);
	END FOREACH
	
	--Obtener tarjetas de debito que el cliente ha otorado a otros clientes
	SET ISOLATION TO DIRTY READ;
	FOREACH WITH HOLD
		SELECT trjasig.numcte, cta.cuenta, ctaest.descripcion, trjasig.num_tarjeta, trjasig.status_tar, trj.nombre, trj.codstatustarjeta, trj.titular 
		INTO cv_trjasig_num_cte, cv_cta_cuenta, cv_ctast_descripcion, cv_astrj_num_tarjeta, cv_astrj_status_tar, cv_trj_nombre, cv_trj_codstatustarjeta, cv_trj_titular 
		FROM bdicheq:"informix".sc_maechq cta, bdicheq:"informix".sc_mae_estatus ctaest, bdicheq:'informix'.sc_tarjeta trjasig, bdicheq:'informix'.sc_producto def, intercard:'informix'.tarjeta trj 
		WHERE cta.empresa = pempresa AND ctaest.empresa = pempresa AND trjasig.empresa = pempresa 
		AND (cta.num_cte = pnumcte AND trjasig.numcte <> pnumcte) 
		AND cta.status_cta = ctaest.cod_estatus 
		AND cta.cuenta = trjasig.cuenta 
		AND (trjasig.tipo_tarjeta = 'T' OR trjasig.tipo_tarjeta = 'A') AND trjasig.prodtarjeta = '2400'
		AND trjasig.prodtarjeta = def.producto
		AND trj.numtarjeta = trjasig.num_tarjeta AND trj.codstatusasignada = 'SIA' AND trj.codstatustarjeta = pstatus

		INSERT INTO intercard:"informix".tmp_tarjetas_debcret_iccat(numcte, nombre, num_tarjeta, codstatustarjeta, num_cuenta_credito, descripcion, titular, habilitado, tipo_tarjeta, status_tar)
		VALUES (cv_trjasig_num_cte, cv_trj_nombre, cv_astrj_num_tarjeta, cv_trj_codstatustarjeta, cv_cta_cuenta, cv_ctast_descripcion, cv_trj_titular, 'F', 'D', cv_astrj_status_tar);
	END FOREACH
	
	--Obtener tarjetas de credito de las que el cliente es titular
	SET ISOLATION TO DIRTY READ;
	FOREACH WITH HOLD
		SELECT trjasig.numcte, cta.num_credito, ctaest.descripcion, trjasig.num_tarjeta, trjasig.status_tar, trj.nombre, trj.codstatustarjeta, trj.titular 
		INTO cv_trjasig_num_cte, cv_cta_cuenta, cv_ctast_descripcion, cv_astrj_num_tarjeta, cv_astrj_status_tar, cv_trj_nombre, cv_trj_codstatustarjeta, cv_trj_titular 
		FROM bdicred:"informix".sd_maecred cta, bdicred:"informix".sd_tipocartera ctaest, bdicred:"informix".sd_tarjeta trjasig, bdicred:"informix".sd_definicion def, intercard:"informix".tarjeta trj 
		WHERE cta.empresa = pempresa AND ctaest.empresa = pempresa AND trjasig.empresa = pempresa 
		AND (cta.numcte = pnumcte AND trjasig.numcte = pnumcte) 
		AND cta.status_cred = ctaest.status_cred 
		AND cta.num_credito = trjasig.num_credito 
		AND (trjasig.tipo_tarjeta = 'T' OR trjasig.tipo_tarjeta = 'A') AND trjasig.prodtarjeta IN (6001,7000,8100) 
		AND trjasig.prodtarjeta = def.num_producto 
		AND trj.numtarjeta = trjasig.num_tarjeta AND trj.codstatusasignada = 'SIA' AND trj.codstatustarjeta = pstatus 

		INSERT INTO intercard:"informix".tmp_tarjetas_debcret_iccat(numcte, nombre, num_tarjeta, codstatustarjeta, num_cuenta_credito, descripcion, titular, habilitado, tipo_tarjeta, status_tar)
		VALUES (cv_trjasig_num_cte, cv_trj_nombre, cv_astrj_num_tarjeta, cv_trj_codstatustarjeta, cv_cta_cuenta, cv_ctast_descripcion, cv_trj_titular, 'F', 'C', cv_astrj_status_tar);
	END FOREACH
	
	--Obtener tarjetas de credito de otros clientes de la que el cliente es adicional
	SET ISOLATION TO DIRTY READ;
	FOREACH WITH HOLD
		SELECT trjasig.numcte, cta.num_credito, ctaest.descripcion, trjasig.num_tarjeta, trjasig.status_tar, trj.nombre, trj.codstatustarjeta, trj.titular 
		INTO cv_trjasig_num_cte, cv_cta_cuenta, cv_ctast_descripcion, cv_astrj_num_tarjeta, cv_astrj_status_tar, cv_trj_nombre, cv_trj_codstatustarjeta, cv_trj_titular 
		FROM bdicred:"informix".sd_maecred cta, bdicred:"informix".sd_tipocartera ctaest, bdicred:"informix".sd_tarjeta trjasig, bdicred:"informix".sd_definicion def, intercard:"informix".tarjeta trj 
		WHERE cta.empresa = pempresa AND ctaest.empresa = pempresa AND trjasig.empresa = pempresa 
		AND (cta.numcte <> pnumcte AND trjasig.numcte = pnumcte) 
		AND cta.status_cred = ctaest.status_cred 
		AND cta.num_credito = trjasig.num_credito 
		AND (trjasig.tipo_tarjeta = 'T' OR trjasig.tipo_tarjeta = 'A') AND trjasig.prodtarjeta IN (6001,7000,8100) 
		AND trjasig.prodtarjeta = def.num_producto 
		AND trj.numtarjeta = trjasig.num_tarjeta AND trj.codstatusasignada = 'SIA' AND trj.codstatustarjeta = pstatus 

		INSERT INTO intercard:"informix".tmp_tarjetas_debcret_iccat(numcte, nombre, num_tarjeta, codstatustarjeta, num_cuenta_credito, descripcion, titular, habilitado, tipo_tarjeta, status_tar)
		VALUES (cv_trjasig_num_cte, cv_trj_nombre, cv_astrj_num_tarjeta, cv_trj_codstatustarjeta, cv_cta_cuenta, cv_ctast_descripcion, cv_trj_titular, 'F', 'C', cv_astrj_status_tar);
	END FOREACH
	
	--Obtener tarjetas de debito que el cliente ha otorado a otros clientes
	SET ISOLATION TO DIRTY READ;
	FOREACH WITH HOLD
		SELECT trjasig.numcte, cta.num_credito, ctaest.descripcion, trjasig.num_tarjeta, trjasig.status_tar, trj.nombre, trj.codstatustarjeta, trj.titular 
		INTO cv_trjasig_num_cte, cv_cta_cuenta, cv_ctast_descripcion, cv_astrj_num_tarjeta, cv_astrj_status_tar, cv_trj_nombre, cv_trj_codstatustarjeta, cv_trj_titular 
		FROM bdicred:"informix".sd_maecred cta, bdicred:"informix".sd_tipocartera ctaest, bdicred:"informix".sd_tarjeta trjasig, bdicred:"informix".sd_definicion def, intercard:"informix".tarjeta trj 
		WHERE cta.empresa = pempresa AND ctaest.empresa = pempresa AND trjasig.empresa = pempresa 
		AND (cta.numcte = pnumcte AND trjasig.numcte <> pnumcte) 
		AND cta.status_cred = ctaest.status_cred 
		AND cta.num_credito = trjasig.num_credito 
		AND (trjasig.tipo_tarjeta = 'T' OR trjasig.tipo_tarjeta = 'A') AND trjasig.prodtarjeta IN (6001,7000,8100) 
		AND trjasig.prodtarjeta = def.num_producto 
		AND trj.numtarjeta = trjasig.num_tarjeta AND trj.codstatusasignada = 'SIA' AND trj.codstatustarjeta = pstatus 

		INSERT INTO intercard:"informix".tmp_tarjetas_debcret_iccat(numcte, nombre, num_tarjeta, codstatustarjeta, num_cuenta_credito, descripcion, titular, habilitado, tipo_tarjeta, status_tar)
		VALUES (cv_trjasig_num_cte, cv_trj_nombre, cv_astrj_num_tarjeta, cv_trj_codstatustarjeta, cv_cta_cuenta, cv_ctast_descripcion, cv_trj_titular, 'F', 'C', cv_astrj_status_tar);
	END FOREACH
	
	--Asignar en tabla temporal bandera de tarjeta habilitado/deshabilitado para activación
	UPDATE intercard:"informix".tmp_tarjetas_debcret_iccat tmp SET tmp.habilitado = 'T' WHERE tmp.numcte = pnumcte AND tmp.titular = 'T';
	UPDATE intercard:"informix".tmp_tarjetas_debcret_iccat tmp SET tmp.habilitado = 'T' WHERE tmp.numcte = pnumcte AND tmp.titular = 'A';
	--UPDATE intercard:"informix".tmp_tarjetas_debcret_iccat tmp SET tmp.habilitado = 'F' WHERE tmp.numcte <> pnumcte AND tmp.titular = 'T';
	
	--Retornar todas las tarjetas en la tabla temporal
	SET LOCK MODE TO WAIT 3;
	FOREACH 
		SELECT SKIP pNumRegistros FIRST 10 nombre, num_tarjeta, codstatustarjeta, num_cuenta_credito, descripcion, titular, habilitado, tipo_tarjeta, status_tar
		INTO cvnomcliente, cvnumtarjeta, cvestatus_tar, cvnumcuenta, cvstatuscuenta, cvtitular, cvradiobuton, cvtipotar, cstatus_tarjeta
		FROM intercard: tmp_tarjetas_debcret_iccat
		
		LET ccodret = '000000000';
		
		RETURN ccodret, cvnomcliente, cvnumtarjeta, cvtipotar, cvestatus_tar, cvnumcuenta, cvstatuscuenta, cvtitular, cvradiobuton, cstatus_tarjeta WITH RESUME;
	END FOREACH;
	
	IF (ccodret = '000000001') THEN
		RETURN ccodret, cvnomcliente, cvnumtarjeta, cvtipotar, cvestatus_tar, cvnumcuenta, cvstatuscuenta, cvtitular, cvradiobuton, cstatus_tarjeta;
	END IF;
		
END
END PROCEDURE
DOCUMENT
'OBJETIVO: 	Consulta tarjetas inactivas de débito platino y crédito',
'AUTOR:		Felipe Monzón Mendoza',
'FECHA : 	26/05/2017',
'BD : 		intercard',

'OBJETIVO: 	Se retorna el campo: status_tar',
'MODIFICÓ:	Keevyn Adrian Gil Valenzuela',
'FECHA : 	21/08/2017',
'BD : 		intercard',

'OBJETIVO: 	Se modifica codigo para dismunuir costo',
'MODIFICÓ:	Ruben Antonio Ojeda Milan',
'FECHA : 	19/10/2017',
'BD : 		intercard';

CREATE PROCEDURE "informix".sp_registra_evento(
                  pIdProceso VARCHAR(20),
				  pNumTarjeta VARCHAR(16),
				  pNombreCliente CHAR(104),
				  pFechaHoraInAuth DATETIME YEAR TO FRACTION(5),
				  pInfReceptor VARCHAR(40),
				  pMonto DECIMAL(19,4),
				  pSecuencia VARCHAR(7),
				  pUsuario CHAR(10))

    RETURNING VARCHAR(5) as Cod_ret,VARCHAR(80) as Men_ret;

    ---VARIABLES PARA CAPTURAR ERRORES
    DEFINE vNumTarjeta          VARCHAR(16);
    DEFINE vsnumcte 	        CHAR (20);
    DEFINE vsCodRet1            CHAR(5);
    DEFINE vsCodRet2            CHAR(5);
    DEFINE vstelefono	        CHAR(13);
    DEFINE vstipotel 	        SMALLINT;
    DEFINE vsSecuencia          SMALLINT;
    DEFINE vsStatustel	        CHAR(1);
    DEFINE vsextension 	   	    CHAR(5);
    DEFINE vscarrier	   	    SMALLINT;
    DEFINE vsnombrecarrier 	    CHAR(20);
    DEFINE vsStatusvalidacion   SMALLINT;
    DEFINE vscorreo			    CHAR(100);
    DEFINE vstipocorreo		    SMALLINT;
    DEFINE vsStatuscorreo       CHAR(1);
    DEFINE vsMensaje            CHAR(200);
    DEFINE vsString1            VARCHAR(50);  
    DEFINE cCodRet              CHAR(5);
    DEFINE vsecuencial          INTEGER;
    DEFINE valerta1             VARCHAR(10);
    DEFINE valerta2             VARCHAR(10);
    DEFINE vIdPlantilla1        VARCHAR(15); 
    DEFINE vIdPlantilla2        VARCHAR(15); 
    DEFINE vdFechaInsert        DATETIME YEAR TO FRACTION(5);
    DEFINE vdFechaHoy           DATETIME YEAR TO FRACTION(5);
    DEFINE vcount               INTEGER;
	DEFINE vi_valor1            INTEGER;
	DEFINE vd_valor2            DECIMAL(19,8);
	DEFINE vs_valor3            CHAR(50);
	DEFINE vi_limdiarios        INTEGER;
	DEFINE vi_limmensuales      INTEGER;
	DEFINE vi_contdiarios       INTEGER;
	DEFINE vi_contmensuales     INTEGER;
	DEFINE vs_bines				CHAR(6);
	DEFINE vi_contdiariotjtinactiva INTEGER;
    DEFINE vi_contmensualtjtinactiva INTEGER;
    DEFINE vi_contdiariotjtfondos INTEGER;
    DEFINE vi_contmensualtjtfondos INTEGER;
	DEFINE vs_numtarjeta         VARCHAR(16);
	DEFINE vs_nombre            VARCHAR(250);
	DEFINE vs_nombre_completo   LVARCHAR(400);
	DEFINE vd_hora   CHAR(8);
	DEFINE vNumeroCliente   VARCHAR(20);

    BEGIN 
     
         ---INICIALIZAN VARIABLES PARA QUERYS
        LET vsnumcte           = '';
        LET vsCodRet1          = '00000';
        LET vsCodRet2          = '00000';
        LET vstelefono         = '';
        LET vsMensaje          = ''; 
        LET vstipotel          = 0;
        LET vsSecuencia        = 0;
        LET vsStatustel        = '';
        LET vsextension        = '';
        LET vscarrier          = 0;   
        LET vsnombrecarrier    = '';
        LET vsStatusvalidacion = 0;
        LET vscorreo           = '';
        LET vsStatuscorreo     = '';
        LET vstipocorreo       = 0;
        LET cCodRet = '00000';
        LET vsecuencial = 0; 
        LET vdFechaInsert      =  sysdate;
        LET vdFechaHoy         =  sysdate;
        LET vcount             = 0; 
        LET vi_valor1          = 0;
        LET vd_valor2          = 0;
        LET vi_limdiarios      = 0;
        LET vi_limmensuales    = 0;
        LET vi_contdiarios     = 0;
        LET vi_contmensuales   = 0;
        LET vs_valor3          = '';
        LET vs_bines	       = '';
        LET vi_contdiariotjtinactiva = 0;
        LET vi_contmensualtjtinactiva = 0;
        LET vi_contdiariotjtfondos = 0;
        LET vi_contmensualtjtfondos = 0;
        LET vs_numtarjeta = '';
        LET vs_nombre = '';
        LET vs_nombre_completo = '';
        LET vd_hora = '';
        -- Los ceros indican un cliente generico para Latinia
        --Y debe tomar en cuenta el dato almacenado en el campo celular_alterno o correo_alterno
        LET vNumeroCliente = '000000000';

        LET vNumTarjeta = pNumTarjeta;
        
            IF (pIdProceso = 'MSJ_ICPANP') THEN
                
                    LET vIdPlantilla1 ='1CPANPMAIL'; -- plantilla email
                    LET valerta1      ='1CPANPMAIL'; -- alerta email
                    LET vIdPlantilla2 ='1CPANP_SMS'; -- plantilla sms
                    LET valerta2      ='1CPANP_SMS'; -- alerta sms                                
            ELSE
                
                LET vsCodRet1 = '00005'; 
                LET vsMensaje = 'Se intento procesar con un ID indefinido o erroneo';
                
                INSERT INTO intercard:"informix".bitacoraenvios_tjts (id_proceso,tarjeta,fecha_insert,estatus_envio,cod_ret,descripcion)
                VALUES (pIdProceso,vNumTarjeta,vdFechaInsert,'F',vsCodRet1,vsMensaje); 
                
                RETURN 	vsCodRet1,vsMensaje; 
            
            END IF;
            
            /*--Determina si el mensaje viene del Autorizador para reglas de negocio de Tarjeta
            IF(pIdProceso = 'MSJ_ICPANP') THEN*/
            --Verifica en la tabla de bditarjeta:td_parametro  si el parametro esta encendido para el envio del mensaje
            SET ISOLATION TO DIRTY READ;
            SELECT valor1, valor2, valor3 INTO vi_valor1, vd_valor2, vs_valor3
            FROM bditarjeta:"informix".td_parametro
            WHERE clave = pIdProceso;
                
            IF(vi_valor1 = 1) THEN --Bandera Encendida para Enviar Mensaje
                 
                --Obtiene el producto de la tarjeta
                SET ISOLATION TO DIRTY READ;
                SELECT creditodebito INTO vs_bines
                FROM intercard:"informix".bines
                WHERE bin = SUBSTRING(vNumTarjeta FROM 1 FOR 6);
            
                IF (vs_valor3 = vs_bines OR vs_valor3 = 'A') THEN --Verifica si aplica el mensaje para Debito, Credito o Ambos Productos (A)
                
                    --Verifica si la tarjeta ya llega al limite de mensajes diarios o mensuales, en su caso no envia mensaje.
                    SET ISOLATION TO DIRTY READ;
                    SELECT numtarjeta
					--	, contdiariotjtinactiva, contmensualtjtinactiva, contdiariotjtfondos, contmensualtjtfondos
                        INTO vs_numtarjeta
					--	, vi_contdiariotjtinactiva, vi_contmensualtjtinactiva, vi_contdiariotjtfondos, vi_contmensualtjtfondos
                    FROM intercard:"informix".tarjeta_indicadores
                    WHERE numtarjeta = vNumTarjeta;
                
                    IF(vs_numtarjeta <> '' AND vs_numtarjeta is not null) THEN --Se encontro tarjeta en Indicadores
                
                        --El valor almacenado en el campo valor2 tiene dos digitos. Por ejemplo: 11, 13, 19
                        --y usando la funcion trunc con operaciones aritmeticas
                        --se extraen el primer y segundo digito indicando siÂ­ cumple con las condiciones de enviar mensajes.
                        LET vi_contdiarios = trunc(vd_valor2/10, 0);
                        LET vi_contmensuales = vd_valor2 - (vi_contdiarios * 10);
                
                        LET vi_limdiarios = 1; --No lo requiere ya que lo controla el autorizador desde que invoca el SP
                        LET vi_limmensuales = 1; --No lo requiere ya que lo controla el autorizador desde que invoca el SP                                         
                        
                        IF (vi_limdiarios <= vi_contdiarios AND vi_limmensuales <= vi_contmensuales) THEN --Envia mensaje, si los contadores se supera no envia
            
                            INSERT INTO intercard:"informix".bitacoraenvios_tjts (id_proceso, tarjeta, fecha_insert, estatus_envio, tipo_envio, cod_ret, descripcion)
                                                            VALUES (pIdProceso,vNumTarjeta,vdFechaInsert,'P','','','');  
     
                            SELECT FIRST 1 secuencial,fecha_insert  INTO  vsecuencial,vdFechaInsert FROM intercard:"informix".bitacoraenvios_tjts
                            where estatus_envio = 'P' AND fecha_insert = vdFechaInsert AND tarjeta = vNumTarjeta AND id_proceso= pIdProceso;
          
                            SELECT {+INDEX(intercard:tarjeta 819_8158 } FIRST 1 numcliente  INTO  vsnumcte FROM  intercard:"informix".tarjeta  
                            WHERE   numtarjeta = vNumTarjeta;
             
                            --Obtener el nombre del cliente correspondiente a los mensajes de texto o correo electronico.
                            --Si es mensaje de texto se utiliza la variable vs_nombre
                            --Si es correo electronico se utiliza la variable vs_nombre_completo
                            SET ISOLATION TO DIRTY READ;
                            SELECT
                                CASE
                                    WHEN LENGTH (TRIM(nombre1)) < 3 THEN TRIM(nombre2)
                                    ELSE TRIM(nombre1)
                                END AS nombre,
                                TRIM(nombre1) ||' '|| TRIM(nombre2)  ||' '|| TRIM(apell_paterno) ||' '|| TRIM(apell_materno) AS nombre_completo
                            INTO vs_nombre, vs_nombre_completo
                            FROM bdinteg:"informix".si_cliente
                            WHERE numcte = vsnumcte;
                            
                            --Ultimos 4 digitos del numero de tarjeta
                            LET  vsString1  =  SUBSTR(vNumTarjeta,13,4);

                            IF ( vsnumcte <> '' AND vsnumcte is not null ) THEN  --- De encontrar usuarios le busca primero su contacto celular.
                            
                                EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_telefonos("001",vsnumcte,2,"0")
                                INTO vsCodRet1,vstelefono,vstipotel,vsSecuencia,vsStatustel,vsextension,vscarrier,vsnombrecarrier,vsStatusvalidacion;
               
                                IF (vsCodRet1 <> '000') THEN
                
                                    EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_correos("001",vsnumcte,1,"0")
                                    INTO vsCodRet2,vscorreo,vstipocorreo,vsStatuscorreo;
                                  
                                    IF (vsCodRet2 <> '000') THEN
                                    
                                        LET vsCodRet1 = '00006';
                                        LET vsMensaje = 'Error al obtener telefono y correo del titular.';  
                                        UPDATE  intercard:"informix".bitacoraenvios_tjts
                                            SET cod_ret = vsCodRet1, estatus_envio = 'E', tipo_envio = NULL, descripcion = vsMensaje
                                        WHERE secuencial = vsecuencial;
     
                                    ELSE
                                    
                                        IF (vscorreo <> '' AND vscorreo is not null)  THEN  
                                                
                                            ---  INVOCAR  SP REGISTRA EVENTO (EMAIL)
                                            EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento ('1',valerta1,vIdPlantilla1,vNumeroCliente,NULL,vNumTarjeta,'1', vsString1, SUBSTR(TRIM(pInfReceptor), 0,20),NULL,NULL, vs_nombre_completo,NULL,NULL,NULL,NULL,NULL,vscorreo,NULL,pMonto,0,0,0,0,vdFechaHoy,NULL)
                                            INTO 	cCodRet;
                                                    
                                            IF  ( cCodRet <> '00000' )  THEN 
                                                LET vsCodRet1 = '00004';
                                                LET vsMensaje = 'Hubo un error al registrarse en bdimnsj.';
                                                UPDATE  intercard:"informix".bitacoraenvios_tjts
                                                    SET cod_ret = vsCodRet1,estatus_envio = 'E', tipo_envio = '2', descripcion = vsMensaje
                                                WHERE secuencial = vsecuencial; 
                                            END IF;  
                                                        
                                            UPDATE  intercard:"informix".bitacoraenvios_tjts
                                                SET cod_ret = '000', estatus_envio = 'V', tipo_envio = '2', descripcion = 'Se envio Correo al titular.' 
                                            WHERE secuencial = vsecuencial; 
                                          
                                        ELSE    --- De no encontrar ningun medio de contacto genera bitacora de error. 
                                 
                                            LET vsCodRet1 = '00002';
                                            LET vsMensaje   = 'Titular no tiene registrado celular o correo electronico.';
                                            UPDATE  intercard:"informix".bitacoraenvios_tjts
                                                SET cod_ret = vsCodRet1, estatus_envio = 'E', tipo_envio = NULL , descripcion = vsMensaje 
                                            WHERE secuencial = vsecuencial; 
                                                 
                                        END IF;
                                        
                                    END IF; -- CIERRE | IF (vsCodRet2 <> '000') THEN | Consulta de correos
                                    
                                ELSE -- IF (vsCodRet1 <> '000') THEN | | Consulta de telefonos
                                    
                                    IF (vstelefono <> '' AND vstelefono is not null)  THEN   
                            
                                        ---  INVOCAR  SP REGISTRA EVENTO (SMS)
                                        
                                        EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento  ('1',valerta2,vIdPlantilla2,vNumeroCliente,NULL,vNumTarjeta,'1', vsString1, SUBSTR(TRIM(pInfReceptor), 0,20),NULL,NULL, vs_nombre,NULL,NULL,NULL,NULL,NULL,NULL,vstelefono,pMonto,0,0,0,0,vdFechaHoy,NULL)
                                        INTO 	cCodRet;
                                
                                        IF  ( cCodRet <> '00000' )  THEN
                                            LET vsCodRet1 = '00004';
                                            LET vsMensaje = 'Hubo un error al registrarse en bdimnsj.';
                                            UPDATE  intercard:"informix".bitacoraenvios_tjts
                                                SET cod_ret = vsCodRet1,estatus_envio = 'E', tipo_envio = '1', descripcion = vsMensaje
                                            WHERE secuencial = vsecuencial; 
                                        END IF; 
                                
                                        UPDATE  intercard:"informix".bitacoraenvios_tjts
                                            SET cod_ret = '000',estatus_envio = 'V', tipo_envio = '1', descripcion = 'Se envio SMS al titular.' 
                                        WHERE secuencial = vsecuencial;
                            
                                    ELSE    --- De no encontrar el telefono procede con la busqueda de algun correo electronico.

                                        
                                        EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_correos("001",vsnumcte,1,"0")
                                        INTO vsCodRet2,vscorreo,vstipocorreo,vsStatuscorreo; 
                                        
                                        IF (vsCodRet2 <> '000') THEN   -- Guarda bitacora en caso de generar un error en el proceso anterior. 
                                            LET vsCodRet1 = '00006';
                                            LET vsMensaje = 'Error al obtener el correo del titular.';
                                            UPDATE  intercard:"informix".bitacoraenvios_tjts
                                                SET cod_ret = vsCodRet1, estatus_envio = 'E', tipo_envio = '2', descripcion = vsMensaje
                                            WHERE secuencial = vsecuencial; 
                                        
                                        ELSE 
         
                                            IF (vscorreo <> '' AND vscorreo is not null)  THEN  
                                            
                                            ---  INVOCAR  SP REGISTRA EVENTO (EMAIL)
                                                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento ('1',valerta1,vIdPlantilla1,vNumeroCliente,NULL,vNumTarjeta,'1', vsString1, SUBSTR(TRIM(pInfReceptor), 0,20),NULL,NULL, vs_nombre_completo,NULL,NULL,NULL,NULL,NULL,vscorreo,NULL,pMonto,0,0,0,0,vdFechaHoy,NULL)
                                                INTO 	cCodRet;
                                                        
                                                IF  ( cCodRet <> '00000' )  THEN 
                                                    LET vsCodRet1 = '004';
                                                    LET vsMensaje = 'Hubo un error al registrarse en bdimnsj.';
                                                    UPDATE  intercard:"informix".bitacoraenvios_tjts
                                                        SET cod_ret = vsCodRet1,estatus_envio = 'E', tipo_envio = '2', descripcion = vsMensaje
                                                    WHERE secuencial = vsecuencial;
                                                END IF;
                                                
                                                UPDATE  intercard:"informix".bitacoraenvios_tjts
                                                    SET cod_ret = '000', estatus_envio = 'V', tipo_envio = '2', descripcion = 'Se envio Correo al titular.' 
                                                WHERE secuencial = vsecuencial; 
                                                        
                                            ELSE    --- De no hallar ningun medio de contacto genera bitacora de error. 
                                                
                                                LET vsCodRet1 = '00003';
                                                LET vsMensaje = 'Titular no tiene registrado celular o correo electronico.';
                                                UPDATE  intercard:"informix".bitacoraenvios_tjts
                                                    SET cod_ret = vsCodRet1, estatus_envio = 'E', tipo_envio = NULL, descripcion = vsMensaje
                                                WHERE secuencial = vsecuencial; 
                                                 
                                            END IF;
                                        
                                        END IF;
                                        
                                    END IF;
                                    
                                END IF; -- CIERRE | IF (vsCodRet1 <> '000') THEN Codigo de retorno para consulta de telefonos.
         
                            ELSE
                            
                                LET vsCodRet1 = '00001';
                                LET vsMensaje   = 'Cliente no se pudo identificar con tarjeta : '||vNumTarjeta||'';
              
                                UPDATE intercard:"informix".bitacoraenvios_tjts SET cod_ret = vsCodRet1,estatus_envio = 'F',descripcion = vsMensaje
                                WHERE secuencial = vsecuencial;

                            END IF; -- CIERRE -> IF ( vsnumcte <> '' AND vsnumcte is not null ) THEN
                            
                        END IF; -- Sobre Limites Diarios y Mensuales
                        
                    END IF; --Sobre Indicadores de la Tarjeta
                    
                END IF; --Sobre Bines
                
            ELSE --No se envia ningun mensaje o no aplica para la plantilla
            
                LET vsCodRet1          = '00000';
                LET vsMensaje          = '';
                
            END IF; --Sobre Indicador de Envio o No de Mensajes para la Platilla
    ----------------------------------------------------------------------------------------------------------------------------------------------------
        RETURN 	vsCodRet1,vsMensaje; 
   
    END;
    
END PROCEDURE

DOCUMENT
'AUTOR : Luis Antonio Gomez',
'DESCRIPCION: SP para registro y envio de SMS/email al tarjetahabiente.',
'EJECUTADO O LLAMADO POR:',
'sp_registra_evento(VARCHAR(20), VARCHAR(16), CHAR(10), DATETIME, CHAR (40), MONEY, CHAR (6), CHAR (8))',
'FECHA : Septiembre/2017',
'VERSION: 20170912',
'BD    : intercard';

CREATE PROCEDURE "informix".sp_registra_evento(
                  pTipoRechazo     	VARCHAR(1), -- 'N'egocio/'C'entral
                  pIdvalidacionAuth VARCHAR(6), 
				  pNumTarjeta VARCHAR(16),
				  pNombreCliente CHAR(104),
				  pFechaHoraInAuth DATETIME YEAR TO FRACTION(5),
				  pProdind VARCHAR(2),
				  pEsNacional VARCHAR(1),
				  pMetodoCaptura VARCHAR(2),
				  pTipoTransaccionPosDigitada VARCHAR(2),
				  pInfReceptor VARCHAR(40),
				  pMonto DECIMAL(19,4),
				  pSecuencia VARCHAR(7),
				  pUsuario CHAR(10))

    RETURNING VARCHAR(5) as Cod_ret,VARCHAR(80) as Men_ret;

    ---VARIABLES PARA CAPTURAR ERRORES
    DEFINE vNumTarjeta          VARCHAR(16);
    DEFINE vsnumcte 	        CHAR (20);
    DEFINE vsCodRet1            CHAR(5);
    DEFINE vsCodRet2            CHAR(5);
    DEFINE vstelefono	        CHAR(13);
    DEFINE vstipotel 	        SMALLINT;
    DEFINE vsSecuencia          SMALLINT;
    DEFINE vsStatustel	        CHAR(1);
    DEFINE vsextension 	   	    CHAR(5);
    DEFINE vscarrier	   	    SMALLINT;
    DEFINE vsnombrecarrier 	    CHAR(20);
    DEFINE vsStatusvalidacion   SMALLINT;
    DEFINE vscorreo			    CHAR(100);
    DEFINE vstipocorreo		    SMALLINT;
    DEFINE vsStatuscorreo       CHAR(1);
    DEFINE vsMensaje            CHAR(200);
    DEFINE vsString1            VARCHAR(50);  
    DEFINE cCodRet              CHAR(5);
    DEFINE vsecuencial          INTEGER;
    DEFINE valerta1             VARCHAR(10);
    DEFINE valerta2             VARCHAR(10);
    DEFINE vIdPlantilla1        VARCHAR(15); 
    DEFINE vIdPlantilla2        VARCHAR(15); 
    DEFINE vdFechaInsert        DATETIME YEAR TO FRACTION(5);
    DEFINE vdFechaHoy           DATETIME YEAR TO FRACTION(5);
    DEFINE vcount               INTEGER;
	DEFINE vi_valor1            INTEGER;
	DEFINE vd_valor2            DECIMAL(19,8);
	DEFINE vs_valor3            CHAR(50);
	DEFINE vi_limdiarios        INTEGER;
	DEFINE vi_limmensuales      INTEGER;
	DEFINE vi_contdiarios       INTEGER;
	DEFINE vi_contmensuales     INTEGER;
	DEFINE vs_bines				CHAR(6);
	DEFINE vi_contdiariotjtinactiva INTEGER;
    DEFINE vi_contmensualtjtinactiva INTEGER;
    DEFINE vi_contdiariotjtfondos INTEGER;
    DEFINE vi_contmensualtjtfondos INTEGER;
	DEFINE vs_numtarjeta         VARCHAR(16);
	DEFINE vs_nombre            VARCHAR(250);
	DEFINE vs_nombre_completo   LVARCHAR(400);
	DEFINE vd_hora   CHAR(8);
	DEFINE vNumeroCliente   VARCHAR(20);
	
	DEFINE vidvalidacionauth            VARCHAR(6);
	DEFINE vidproceso					VARCHAR(10);
	DEFINE vtiporechazo             	VARCHAR(1);
    DEFINE vtipoproducto            	CHAR(1);
    DEFINE vnotifica                	CHAR(1);
    DEFINE venvia_sms               	CHAR(1);
    DEFINE vplantilla_sms           	VARCHAR(10);
    DEFINE vcontenido_sms           	VARCHAR(160);
    DEFINE venvia_email             	CHAR(1);
    DEFINE vplantilla_email         	VARCHAR(10);
    DEFINE vcontenido_email         	CHAR(300);
    DEFINE vmotivo                  	VARCHAR(20);
    DEFINE vaplica_producto         	CHAR(1);
    DEFINE vaplica_prodind          	CHAR(1);
    DEFINE vaplica_transaccionorigen	CHAR(1);
    DEFINE vaplica_metodocaptura    	VARCHAR(20);
    DEFINE vlimdiarionotificacredito	INTEGER;
    DEFINE vlimensualnotificacredito	INTEGER;
    DEFINE vlimdiarionotificadebito 	INTEGER;
    DEFINE vlimmensualnotificadebito	INTEGER;
	
	DEFINE vcontmaxtrandiarias          INTEGER;
	DEFINE vcontmaxtranmens              INTEGER;

	DEFINE det_ProdInd CHAR(2);
    DEFINE det_ProdInd2 CHAR(2);
	DEFINE det_Origen CHAR(1);
	DEFINE det_Origen2 CHAR(1);
	DEFINE det_MetodoCaptura CHAR;
	DEFINE det_MetodoCaptura2 CHAR(20);

    BEGIN 

		--	SET DEBUG FILE TO "/informix/frg/autorizador/sp_registra_evento_13p.out";
		--	TRACE ON;

	
        ---INICIALIZAN VARIABLES PARA QUERYS
        LET vsnumcte           = '';
        LET vsCodRet1          = '00000';
        LET vsCodRet2          = '00000';
        LET vstelefono         = '';
        LET vsMensaje          = ''; 
        LET vstipotel          = 0;
        LET vsSecuencia        = 0;
        LET vsStatustel        = '';
        LET vsextension        = '';
        LET vscarrier          = 0;   
        LET vsnombrecarrier    = '';
        LET vsStatusvalidacion = 0;
        LET vscorreo           = '';
        LET vsStatuscorreo     = '';
        LET vstipocorreo       = 0;
        LET cCodRet = '00000';
        LET vsecuencial = 0; 
        LET vdFechaInsert      =  sysdate;
        LET vdFechaHoy         =  sysdate;
        LET vcount             = 0; 
        LET vi_valor1          = 0;
        LET vd_valor2          = 0;
        LET vi_limdiarios      = 0;
        LET vi_limmensuales    = 0;
        LET vi_contdiarios     = 0;
        LET vi_contmensuales   = 0;
        LET vs_valor3          = '';
        LET vs_bines	       = '';
        LET vi_contdiariotjtinactiva = 0;
        LET vi_contmensualtjtinactiva = 0;
        LET vi_contdiariotjtfondos = 0;
        LET vi_contmensualtjtfondos = 0;
        LET vs_numtarjeta = '';
        LET vs_nombre = '';
        LET vs_nombre_completo = '';
        LET vd_hora = '';
        -- Los ceros indican un cliente generico para Latinia
        --Y debe tomar en cuenta el dato almacenado en el campo celular_alterno o correo_alterno
        LET vNumeroCliente = '000000000';

        LET vNumTarjeta = pNumTarjeta;
		
		LET vidvalidacionauth           = '';
		LET vidproceso					= '';
		LET vtiporechazo   				= '';
		LET vtipoproducto  				= 'N';
		LET vnotifica      				= '';
		LET venvia_sms     				= '';
		LET vPlantilla_sms 				= '';
		LET vcontenido_sms  			= '';
		LET venvia_email    			= '';
		LET vplantilla_email 			= '';
		LET vcontenido_email 			= '';
		LET vmotivo           			= '';
		LET vaplica_producto 			= '';
		LET vaplica_prodind  			= '';
		LET vaplica_transaccionorigen	= '';
		LET vaplica_metodocaptura    	= '';
		LET vlimdiarionotificacredito	= 0.0;
		LET vlimensualnotificacredito	= 0.0;
		LET vlimdiarionotificadebito 	= 0.0;
		LET vlimmensualnotificadebito	= 0.0;	
		
		LET vcontmaxtrandiarias         = 0;
	    LET vcontmaxtranmens             = 0;

		
		LET det_ProdInd = '';
		LET det_ProdInd2 = '';
		LET det_Origen = '';
		LET det_Origen2 = '';
		LET det_MetodoCaptura = '';
		LET det_MetodoCaptura2 = '';
		
        --Obtiene el producto de la tarjeta
        SET ISOLATION TO DIRTY READ;
        SELECT creditodebito INTO vs_bines
			FROM intercard:"informix".bines
            WHERE bin = SUBSTRING(vNumTarjeta FROM 1 FOR 6);

		SET ISOLATION TO DIRTY READ;
        SELECT idproceso, tiporechazo, tipoproducto, notifica, envia_sms, plantilla_sms, contenido_sms, envia_email, plantilla_email, contenido_email,
		       motivo, aplica_producto, aplica_prodind, aplica_transaccionorigen, aplica_metodocaptura, 
			   limdiarionotificacredito, limensualnotificacredito, limdiarionotificadebito, limmensualnotificadebito
		INTO vidproceso, vtiporechazo, vtipoproducto, vnotifica, venvia_sms, vplantilla_sms,vcontenido_sms, venvia_email, vplantilla_email, vcontenido_email,
		       vmotivo, vaplica_producto, vaplica_prodind, vaplica_transaccionorigen, vaplica_metodocaptura, 
			   vlimdiarionotificacredito, vlimensualnotificacredito, vlimdiarionotificadebito, vlimmensualnotificadebito
        FROM intercard:"informix".catparamnotificaciones
        WHERE idvalidacionauth = pIdvalidacionAuth and tiporechazo = pTipoRechazo
			AND (tipoproducto = vs_bines OR tipoproducto = vtipoproducto);						
		
        IF (vnotifica <> '') THEN --No hay coincidencia de registros
                
            LET vIdPlantilla1 = vplantilla_email; -- plantilla email
            LET valerta1      = vplantilla_email; -- alerta email
            LET vIdPlantilla2 = vplantilla_sms; -- plantilla sms
            LET valerta2      = vplantilla_sms; -- alerta sms               
        ELSE
                
            LET vsCodRet1 = '00005'; 
            LET vsMensaje = 'Se intento procesar con un ID indefinido o erroneo';
              
            INSERT INTO intercard:"informix".bitacoraenvios_tjts (id_proceso,tarjeta,fecha_insert,estatus_envio,cod_ret,descripcion)
            VALUES (vidproceso,vNumTarjeta,vdFechaInsert,'F',vsCodRet1,vsMensaje); 
                
            RETURN 	vsCodRet1,vsMensaje; 
            
        END IF;
        
		IF(vaplica_prodind = 'A') THEN   
			LET det_ProdInd = 'T'; --Ambos POS y ATM
		ELSE
			LET det_ProdInd = 'A'; --Solo uno		
		END IF;
		
		IF det_ProdInd = 'A' THEN
			IF vaplica_prodind = 'T' THEN  
				let det_ProdInd2 = '01'; --ATM
			ELSE
				let det_ProdInd2 = '02'; --POS
			END IF;
		END IF;	
		
		IF(vaplica_transaccionorigen = 'A') THEN	    
			LET det_Origen = 'T'; --Todos
			ELSE
			LET det_Origen = 'A'; --Solo uno
		END IF;
	 
		IF(det_Origen = 'A') THEN	    
			IF vaplica_transaccionorigen = 'N' THEN
				let det_Origen2 = 'V';
				ELSE
				let det_Origen2 = 'F';
			END IF;
		END IF;
		
		IF(length(vaplica_metodocaptura) < 2) THEN --Define los métodos de Captura que aplica
           IF(vaplica_metodocaptura = '') THEN	    
				LET det_MetodoCaptura = 'T'; --Todos
			ELSE
				LET det_MetodoCaptura = 'A'; --Solo uno
			END IF
		ELSE
		    LET det_MetodoCaptura2 = vaplica_metodocaptura;
		END IF;
							
		--Aqui voy
			--Verifica si está encendida la Notificacion(notifica)	y si aplica para todos los Criterios del mensaje		               
            IF(vnotifica = 'V' and (venvia_sms = 'V' OR venvia_email = 'V') and 
               (det_ProdInd = 'T' or det_ProdInd2 = pProdind) and -- Para todos los Canales o Solo ATM o POS
			   (det_Origen = 'T' or  det_Origen2 = pEsNacional) and --Para todos los Origenes o Solo Nacional o Internacional
			   (det_MetodoCaptura = 'T' or INSTR(vaplica_metodocaptura,pMetodoCaptura,1) > 0 )) THEN --Para todos los métodos de captura o Solo algunos de ellos               
            
                IF (vaplica_producto = vs_bines OR vaplica_producto = 'A') THEN --Verifica si aplica el mensaje para Debito, Credito o Ambos Productos (A)
                
                    --Verifica si la tarjeta ya llega al limite de mensajes diarios o mensuales, en su caso no envia mensaje.
                    SET ISOLATION TO DIRTY READ;
                    SELECT numtarjeta, tiporechazo, idvalidacionauth, contmaxtrandiarias, contmaxtranmens
                        INTO vs_numtarjeta, vtiporechazo, vidvalidacionauth, vcontmaxtrandiarias, vcontmaxtranmens
                    FROM intercard:"informix".tarjeta_rechazos
                    WHERE numtarjeta = vNumTarjeta and idvalidacionauth = pIdvalidacionAuth and tiporechazo = pTipoRechazo;
                
                    IF(vs_numtarjeta <> '' AND vs_numtarjeta is not null) THEN --Se encontro tarjeta en <<tarjeta_rechazos>>                             
                        
						IF (vs_bines = 'C') THEN
                            LET vi_limdiarios = vlimdiarionotificacredito;
                            LET vi_limmensuales = vlimensualnotificacredito;
						ELSE
						    LET vi_limdiarios = vlimdiarionotificadebito;
                            LET vi_limmensuales = vlimmensualnotificadebito;
						END IF;
                                     
                        IF (vcontmaxtrandiarias <= vi_limdiarios AND vcontmaxtranmens <= vi_limmensuales) THEN --Envia mensaje, si los contadores se supera no envia
            
                            INSERT INTO intercard:"informix".bitacoraenvios_tjts (id_proceso, tarjeta, fecha_insert, estatus_envio, tipo_envio, cod_ret, descripcion)
                                                            VALUES (vidproceso,vNumTarjeta,vdFechaInsert,'P','','','');  
     
                            SELECT FIRST 1 secuencial,fecha_insert  INTO  vsecuencial,vdFechaInsert FROM intercard:"informix".bitacoraenvios_tjts
                            where estatus_envio = 'P' AND fecha_insert = vdFechaInsert AND tarjeta = vNumTarjeta AND id_proceso= vidproceso;
          
                            SELECT {+INDEX(intercard:tarjeta 819_8158 } FIRST 1 numcliente  INTO  vsnumcte FROM  intercard:"informix".tarjeta  
                            WHERE   numtarjeta = vNumTarjeta;
             
                            --Obtener el nombre del cliente correspondiente a los mensajes de texto o correo electronico.
                            --Si es mensaje de texto se utiliza la variable vs_nombre
                            --Si es correo electronico se utiliza la variable vs_nombre_completo
                            SET ISOLATION TO DIRTY READ;
                            SELECT
                                CASE
                                    WHEN LENGTH (TRIM(nombre1)) < 3 THEN TRIM(nombre2)
                                    ELSE TRIM(nombre1)
                                END AS nombre,
                                TRIM(nombre1) ||' '|| TRIM(nombre2)  ||' '|| TRIM(apell_paterno) ||' '|| TRIM(apell_materno) AS nombre_completo
                            INTO vs_nombre, vs_nombre_completo
                            FROM bdinteg:"informix".si_cliente
                            WHERE numcte = vsnumcte;
                            
                            --Ultimos 4 digitos del numero de tarjeta
                            LET  vsString1  =  SUBSTR(vNumTarjeta,13,4);

                            IF ( vsnumcte <> '' AND vsnumcte is not null and venvia_sms = 'V') THEN  --- De encontrar usuarios le busca primero su contacto celular.
                            
                                EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_telefonos("001",vsnumcte,2,"0")
                                INTO vsCodRet1,vstelefono,vstipotel,vsSecuencia,vsStatustel,vsextension,vscarrier,vsnombrecarrier,vsStatusvalidacion;
               
                                IF (vsCodRet1 <> '000' and venvia_email = 'V') THEN
                
                                    EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_correos("001",vsnumcte,1,"0")
                                    INTO vsCodRet2,vscorreo,vstipocorreo,vsStatuscorreo;
                                  
                                    IF (vsCodRet2 <> '000') THEN
                                    
                                        LET vsCodRet1 = '00006';
                                        LET vsMensaje = 'Error al obtener telefono y correo del titular.';  
                                        UPDATE  intercard:"informix".bitacoraenvios_tjts
                                            SET cod_ret = vsCodRet1, estatus_envio = 'E', tipo_envio = NULL, descripcion = vsMensaje
                                        WHERE secuencial = vsecuencial;
     
                                    ELSE
                                    
                                        IF (vscorreo <> '' AND vscorreo is not null and venvia_email = 'V')  THEN  
                                                
                                            ---  INVOCAR  SP REGISTRA EVENTO (EMAIL)
                                            EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento ('1',valerta1,vIdPlantilla1,vNumeroCliente,NULL,vNumTarjeta,'1', vsString1, SUBSTR(TRIM(pInfReceptor), 0,20),NULL,NULL, vs_nombre_completo,NULL,NULL,NULL,NULL,NULL,vscorreo,NULL,pMonto,0,0,0,0,vdFechaHoy,NULL)
                                            INTO 	cCodRet;
                                                    
                                            IF  ( cCodRet <> '00000' )  THEN 
                                                LET vsCodRet1 = '00004';
                                                LET vsMensaje = 'Hubo un error al registrarse en bdimnsj.';
                                                UPDATE  intercard:"informix".bitacoraenvios_tjts
                                                    SET cod_ret = vsCodRet1,estatus_envio = 'E', tipo_envio = '2', descripcion = vsMensaje
                                                WHERE secuencial = vsecuencial; 
                                            END IF;  
                                                        
                                            UPDATE  intercard:"informix".bitacoraenvios_tjts
                                                SET cod_ret = '000', estatus_envio = 'V', tipo_envio = '2', descripcion = 'Se envio Correo al titular.' 
                                            WHERE secuencial = vsecuencial; 
                                          
                                        ELSE    --- De no encontrar ningun medio de contacto genera bitacora de error. 
                                 
                                            LET vsCodRet1 = '00002';
                                            LET vsMensaje   = 'Titular no tiene registrado celular o correo electronico.';
                                            UPDATE  intercard:"informix".bitacoraenvios_tjts
                                                SET cod_ret = vsCodRet1, estatus_envio = 'E', tipo_envio = NULL , descripcion = vsMensaje 
                                            WHERE secuencial = vsecuencial; 
                                                 
                                        END IF;
                                        
                                    END IF; -- CIERRE | IF (vsCodRet2 <> '000') THEN | Consulta de correos
                                    
                                ELSE -- IF (vsCodRet1 <> '000') THEN | | Consulta de telefonos
                                    
                                    IF (vstelefono <> '' AND vstelefono is not null and venvia_sms = 'V')  THEN   
                            
                                        ---  INVOCAR  SP REGISTRA EVENTO (SMS)
                                        
                                        EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento  ('1',valerta2,vIdPlantilla2,vNumeroCliente,NULL,vNumTarjeta,'1', vsString1, SUBSTR(TRIM(pInfReceptor), 0,20),NULL,NULL, vs_nombre,NULL,NULL,NULL,NULL,NULL,NULL,vstelefono,pMonto,0,0,0,0,vdFechaHoy,NULL)
                                        INTO 	cCodRet;
                                
                                        IF  ( cCodRet <> '00000' )  THEN
                                            LET vsCodRet1 = '00004';
                                            LET vsMensaje = 'Hubo un error al registrarse en bdimnsj.';
                                            UPDATE  intercard:"informix".bitacoraenvios_tjts
                                                SET cod_ret = vsCodRet1,estatus_envio = 'E', tipo_envio = '1', descripcion = vsMensaje
                                            WHERE secuencial = vsecuencial; 
                                        END IF; 
                                
                                        UPDATE  intercard:"informix".bitacoraenvios_tjts
                                            SET cod_ret = '000',estatus_envio = 'V', tipo_envio = '1', descripcion = 'Se envio SMS al titular.' 
                                        WHERE secuencial = vsecuencial;
                            
                                    ELSE    --- De no encontrar el telefono procede con la busqueda de algun correo electronico.

                                        
                                        EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_correos("001",vsnumcte,1,"0")
                                        INTO vsCodRet2,vscorreo,vstipocorreo,vsStatuscorreo; 
                                        
                                        IF (vsCodRet2 <> '000') THEN   -- Guarda bitacora en caso de generar un error en el proceso anterior. 
                                            LET vsCodRet1 = '00006';
                                            LET vsMensaje = 'Error al obtener el correo del titular.';
                                            UPDATE  intercard:"informix".bitacoraenvios_tjts
                                                SET cod_ret = vsCodRet1, estatus_envio = 'E', tipo_envio = '2', descripcion = vsMensaje
                                            WHERE secuencial = vsecuencial; 
                                        
                                        ELSE 
         
                                            IF (vscorreo <> '' AND vscorreo is not null and venvia_email = 'V')  THEN  
                                            
                                            ---  INVOCAR  SP REGISTRA EVENTO (EMAIL)
                                                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento ('1',valerta1,vIdPlantilla1,vNumeroCliente,NULL,vNumTarjeta,'1', vsString1, SUBSTR(TRIM(pInfReceptor), 0,20),NULL,NULL, vs_nombre_completo,NULL,NULL,NULL,NULL,NULL,vscorreo,NULL,pMonto,0,0,0,0,vdFechaHoy,NULL)
                                                INTO 	cCodRet;
                                                        
                                                IF  ( cCodRet <> '00000' )  THEN 
                                                    LET vsCodRet1 = '004';
                                                    LET vsMensaje = 'Hubo un error al registrarse en bdimnsj.';
                                                    UPDATE  intercard:"informix".bitacoraenvios_tjts
                                                        SET cod_ret = vsCodRet1,estatus_envio = 'E', tipo_envio = '2', descripcion = vsMensaje
                                                    WHERE secuencial = vsecuencial;
                                                END IF;
                                                
                                                UPDATE  intercard:"informix".bitacoraenvios_tjts
                                                    SET cod_ret = '000', estatus_envio = 'V', tipo_envio = '2', descripcion = 'Se envio Correo al titular.' 
                                                WHERE secuencial = vsecuencial; 
                                                        
                                            ELSE    --- De no hallar ningun medio de contacto genera bitacora de error. 
                                                
                                                LET vsCodRet1 = '00003';
                                                LET vsMensaje = 'Titular no tiene registrado celular o correo electronico.';
                                                UPDATE  intercard:"informix".bitacoraenvios_tjts
                                                    SET cod_ret = vsCodRet1, estatus_envio = 'E', tipo_envio = NULL, descripcion = vsMensaje
                                                WHERE secuencial = vsecuencial; 
                                                 
                                            END IF;
                                        
                                        END IF;
                                        
                                    END IF;
                                    
                                END IF; -- CIERRE | IF (vsCodRet1 <> '000') THEN Codigo de retorno para consulta de telefonos.
         
                            ELSE
                            
                                LET vsCodRet1 = '00001';
                                LET vsMensaje   = 'Cliente no se pudo identificar con tarjeta : '||vNumTarjeta||'';
              
                                UPDATE intercard:"informix".bitacoraenvios_tjts SET cod_ret = vsCodRet1,estatus_envio = 'F',descripcion = vsMensaje
                                WHERE secuencial = vsecuencial;

                            END IF; -- CIERRE -> IF ( vsnumcte <> '' AND vsnumcte is not null ) THEN
                            
                        END IF; -- Sobre Limites Diarios y Mensuales
                        
                    END IF; --Sobre Indicadores de la Tarjeta
                    
                END IF; --Sobre Bines
                
            ELSE --No se envia ningun mensaje o no aplica para la plantilla
            
                LET vsCodRet1          = '00000';
                LET vsMensaje          = '';
                
            END IF; --Sobre Indicador de Envio o No de Mensajes para la Platilla
    ----------------------------------------------------------------------------------------------------------------------------------------------------
        RETURN 	vsCodRet1,vsMensaje; 
   
    END;
    
END PROCEDURE

DOCUMENT
'AUTOR : Luis Antonio Gomez',
'DESCRIPCION: SP para registro y envio de SMS/email al tarjetahabiente.',
'EJECUTADO O LLAMADO POR:',
'sp_registra_evento(VARCHAR(20), VARCHAR(16), CHAR(10), DATETIME, CHAR (40), MONEY, CHAR (6), CHAR (8))',
'FECHA : Septiembre/2017',
'VERSION: 20170912',
'BD    : intercard';

CREATE PROCEDURE "informix".sp_validaproducto1(pNumProd CHAR(4), pNumTarjeta CHAR(16), pNumOpc CHAR(1),pClave CHAR(3),Tipot CHAR(1), Clavetp CHAR(3) )
   RETURNING CHAR(5), CHAR(6), CHAR(3), INTEGER;
      
   DEFINE cCodRet            CHAR(5);
   DEFINE iSqlErr            INTEGER;
   DEFINE cCodBin            CHAR(6);
   DEFINE cCodProd           CHAR(3);
   DEFINE cCodClaveTar       INTEGER;
   DEFINE cNumCta            CHAR(12);
   DEFINE cLimiteAut         money (14,2);
     
   LET cCodRet              = '00000';   
   LET cCodBin              = '000000';
   LET cCodProd             = '000';
   LET cCodClaveTar         = 0;
         
BEGIN
                   ON EXCEPTION SET iSqlErr
                      IF iSqlErr <> 0 THEN
                         LET cCodRet = iSqlErr;
                                                               
                             RETURN cCodRet, cCodBin, cCodProd, cCodClaveTar;
                         END IF;
                   END EXCEPTION;
                
                --SET DEBUG FILE TO "/tmp/combinacion/Sp_ValidaProducto.out";
                --TRACE ON;
                
                SET LOCK MODE TO WAIT 3;
                SET ISOLATION TO DIRTY READ;           
           
               SELECT codproductotarjeta,clave_tipotarjeta,bin  
               INTO cCodProd,cCodClaveTar,cCodBin 
               FROM intercard:tipotarjeta 
               WHERE codproductotarjeta = pClave 
               AND Tipo = Tipot
               AND clave = Clavetp;
                --AND flagsolicitud = 1;

                         IF pNumProd = "6001" THEN
                                               
                            SELECT LIMIT 1 num_credito INTO cNumCta FROM bdicred: sd_tarjeta WHERE num_tarjeta = pNumTarjeta;
                            SELECT LIMIT 1 monto_otorgado INTO cLimiteAut FROM bdicred: sd_maesdos where num_credito = cNumCta;        
                               
                            --* La busqueda en la tabla intercard:"informix".segmentoproducto donde el tipo_producto sea igual a C y los limites que anteriormente tenia en el sp
                            SELECT LIMIT 1 TRIM(codproductotarjeta) INTO cCodProd
                            FROM intercard:"informix".segmentoproducto
                            WHERE tipo_producto = "C"
                            AND limite_max >= NVL(cLimiteAut,0) 
                            AND limite_min <= NVL(cLimiteAut,0);                                                                            
                          END IF;

              IF cCodBin IS NULL or cCodClaveTar IS NULL or cCodBin IS NULL THEN
                      LET  cCodRet = '00001';
              END IF;
              

               RETURN cCodRet, cCodBin, cCodProd,cCodClaveTar;
END;
END PROCEDURE
DOCUMENT
'AUTOR: Irma Ureta Gaxiola',
'FECHA: 17/10/2016',
'BD: Intercard',
'Objetivo: Se crea procedimiento para validar que en número de producto de la cuenta exista en la base de datos intercard ';

CREATE PROCEDURE "informix".sp_validaproducto2(pNumProd CHAR(4), pNumTarjeta CHAR(16), pNumOpc CHAR(1),pClave CHAR(3),Tipot CHAR(1) )
   RETURNING CHAR(5), CHAR(6), CHAR(3), INTEGER;
      
   DEFINE cCodRet            CHAR(5);
   DEFINE iSqlErr            INTEGER;
   DEFINE cCodBin            CHAR(6);
   DEFINE cCodProd           CHAR(3);
   DEFINE cCodClaveTar       INTEGER;
   DEFINE cNumCta            CHAR(12);
   DEFINE cLimiteAut         money (14,2);
     
   LET cCodRet              = '00000';   
   LET cCodBin              = '000000';
   LET cCodProd             = '000';
   LET cCodClaveTar         = 0;
         
BEGIN
                   ON EXCEPTION SET iSqlErr
                      IF iSqlErr <> 0 THEN
                         LET cCodRet = iSqlErr;
                                                               
                             RETURN cCodRet, cCodBin, cCodProd, cCodClaveTar;
                         END IF;
                   END EXCEPTION;
                
                --SET DEBUG FILE TO "/tmp/combinacion/Sp_ValidaProducto.out";
                --TRACE ON;
                
                SET LOCK MODE TO WAIT 3;
                SET ISOLATION TO DIRTY READ;

           SELECT codproductotarjeta,clave_tipotarjeta,bin  
           INTO cCodProd,cCodClaveTar,cCodBin 
           FROM intercard:tipotarjeta 
           WHERE clave = pClave 
           AND Tipo = Tipot; 
           --AND flagsolicitud = 1;

                         IF pNumProd = "6001" THEN
                                               
                            SELECT LIMIT 1 num_credito INTO cNumCta FROM bdicred: sd_tarjeta WHERE num_tarjeta = pNumTarjeta;
                            SELECT LIMIT 1 monto_otorgado INTO cLimiteAut FROM bdicred: sd_maesdos where num_credito = cNumCta;        
                               
                            --* La busqueda en la tabla intercard:"informix".segmentoproducto donde el tipo_producto sea igual a C y los limites que anteriormente tenia en el sp
                            SELECT LIMIT 1 TRIM(codproductotarjeta) INTO cCodProd
                            FROM intercard:"informix".segmentoproducto
                            WHERE tipo_producto = "C"
                            AND limite_max >= NVL(cLimiteAut,0) 
                            AND limite_min <= NVL(cLimiteAut,0);                                                                            
                          END IF;

              IF cCodBin IS NULL or cCodClaveTar IS NULL or cCodBin IS NULL THEN
                      LET  cCodRet = '00001';
              END IF;
              

               RETURN cCodRet, cCodBin, cCodProd,cCodClaveTar;
END;
END PROCEDURE
DOCUMENT
'AUTOR: Scarlett Mendoza',
'FECHA: 17/10/2017',
'BD: Intercard',
'Objetivo: Se copia procedimiento para validar que en numero de producto de la cuenta exista en la base de datos intercard y sea correcto';

CREATE PROCEDURE "informix".sp_registra_evento_pba1(pIdProceso VARCHAR(20),pNumTarjeta VARCHAR(16),pUsuario CHAR(10))

RETURNING VARCHAR(6) as Cod_ret,VARCHAR(80) as Men_ret;

---VARIABLES PARA CAPTURAR ERRORES
DEFINE vNumTarjeta          Varchar(16);
DEFINE vsnumcte 	        CHAR (20);
DEFINE vsCodRet1            CHAR(5);
DEFINE vsCodRet2            CHAR(5);
DEFINE vstelefono	        CHAR(13);
DEFINE vstipotel 	        SMALLINT;
DEFINE vsSecuencia          SMALLINT;
DEFINE vsStatustel	        CHAR(1);
DEFINE vsextension 	   	    CHAR(5);
DEFINE vscarrier	   	    SMALLINT;
DEFINE vsnombrecarrier 	    CHAR(20);
DEFINE vsStatusvalidacion   SMALLINT;
DEFINE vscorreo			    CHAR(100);
DEFINE vstipocorreo		    SMALLINT;
DEFINE vsStatuscorreo       CHAR(1);
DEFINE vsMensaje            CHAR(200);
DEFINE vsString1            VARCHAR(50);  
DEFINE cCodRet              CHAR(5);
DEFINE vsecuencial          integer; 
DEFINE valerta1             varchar(10);
DEFINE valerta2             varchar(10);
DEFINE vIdPlantilla1        varchar(15); 
DEFINE vIdPlantilla2        varchar(15); 
DEFINE vdFechaInsert        DATETIME YEAR TO FRACTION(5);
DEFINE vdFechaHoy           DATETIME YEAR TO FRACTION(5);
DEFINE vcount               integer;


BEGIN 
 
 ---INICIALIZAN VARIABLES PARA QUERYS
LET vsnumcte           = '';
LET vsCodRet1          = '00000';
LET vsCodRet2          = '00000';
LET vstelefono         = '';
LET vsMensaje          = ''; 
LET vstipotel          = 0;
LET vsSecuencia        = 0;
LET vsStatustel        = '';
LET vsextension        = '';
LET vscarrier          = 0;   
LET vsnombrecarrier    = '';
LET vsStatusvalidacion = 0;
LET vscorreo           = '';
LET vsStatuscorreo     = '';
LET vstipocorreo       = 0;
LET cCodRet = '00000';
LET vsecuencial = 0; 
LET vdFechaInsert      =  sysdate;  
LET vdFechaHoy         =  sysdate;  
LET vcount             = 0; 
 
--set debug file to "/informix/HomeInformix/mgap/sp_registra_evento.out";
--trace on;	

LET vNumTarjeta = pNumTarjeta; 

        IF (pIdProceso = 'REC_SUC') THEN

            LET vIdPlantilla1 ='TJTPERMAIL';    -- plantilla email    
            LET valerta1      ='TJTPERMAIL';    -- alerta email 
            LET vIdPlantilla2 ='TJTPER_SMS';    -- plantilla sms    
            LET valerta2      ='TJTPER_SMS';    -- alerta sms   		         
        
        ELIF (pIdProceso = 'MSJ_NOTIF_SIA') THEN
            
            LET vIdPlantilla1 ='TJEMAILSIA'; 
            LET valerta1      ='TJEMAILSIA'; 
            LET vIdPlantilla2 ='TJTSMS_SIA';
            LET valerta2      ='TJTSMS_SIA'; 

        ELSE
            
            LET vsCodRet1 = '005'; 
            LET vsMensaje = 'Se intento procesar con un ID indefinido o erroneo';
            
            INSERT INTO intercard:"informix".bitacoraenvios_tjts (id_proceso,tarjeta,fecha_insert,estatus_envio,cod_ret,descripcion)
            VALUES (pIdProceso,vNumTarjeta,vdFechaInsert,'F',vsCodRet1,vsMensaje); 
            
            RETURN 	vsCodRet1,vsMensaje; 
        
        END IF;         
         
        INSERT INTO intercard:"informix".bitacoraenvios_tjts (id_proceso, tarjeta, fecha_insert, estatus_envio, tipo_envio, cod_ret, descripcion)
													  VALUES (pIdProceso,vNumTarjeta,vdFechaInsert,'P','','','');  
 
        SELECT FIRST 1 secuencial,fecha_insert  INTO  vsecuencial,vdFechaInsert   FROM intercard:"informix".bitacoraenvios_tjts  
		where estatus_envio = 'P' AND fecha_insert = vdFechaInsert AND tarjeta = vNumTarjeta AND id_proceso= pIdProceso;
      
		SELECT {+INDEX(intercard:tarjeta 819_8158 } FIRST 1 numcliente  INTO  vsnumcte FROM  intercard:"informix".tarjeta  
		WHERE   numtarjeta = vNumTarjeta;
		 
	    IF (vsnumcte <> '' AND vsnumcte is not null  ) THEN  --- De encontrar usuarios le busca primero su contacto celular.

	       EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_telefonos("001",vsnumcte,2,"0") 
		   INTO vsCodRet1,vstelefono,vstipotel,vsSecuencia,vsStatustel,vsextension,vscarrier,vsnombrecarrier,vsStatusvalidacion;
		   
	        IF vsCodRet1 <> '000' THEN   
			
	                          EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_correos("001",vsnumcte,1,"0")
				              INTO vsCodRet2,vscorreo,vstipocorreo,vsStatuscorreo;         
							  
	                            IF vsCodRet2 <> '000' THEN  
					                LET vsCodRet1 = '006';
									LET vsMensaje = 'Error al obtener telefono y correo del titular.';  
									UPDATE  intercard:"informix".bitacoraenvios_tjts SET cod_ret = vsCodRet1,estatus_envio = 'E',descripcion = vsMensaje
                                    WHERE secuencial = vsecuencial; 
 
								 ELSE 
	 
	                                        IF (vscorreo <> '' AND vscorreo is not null)  THEN  
											
											    ---  INVOCAR  SP REGISTRA EVENTO (EMAIL)
                                                LET  vsString1  =  SUBSTR(vNumTarjeta,13,4); 
                                                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento  ('1',valerta1,vIdPlantilla1,'000000000','',vNumTarjeta,'1',vsString1,'','','','','','','','','',vscorreo,'',0,0,0,0,0,vdFechaHoy,'')
                                                INTO 	cCodRet;
												
												    IF  ( cCodRet <> '00000' )  THEN 
                                                        LET vsCodRet1 = '004';
														LET vsMensaje = 'Hubo un error al registrarse en bdimnsj.';
                                                        UPDATE  intercard:"informix".bitacoraenvios_tjts SET cod_ret = vsCodRet1,estatus_envio = 'E',descripcion = vsMensaje
                                                        WHERE secuencial = vsecuencial; 
	                                                END IF;  
													
												UPDATE  intercard:"informix".bitacoraenvios_tjts SET cod_ret = '000',estatus_envio = 'V',descripcion = 'Se envio Correo al titular.' 
                                                WHERE secuencial = vsecuencial; 
									  
									         ELSE    --- De no encontrar ningun medio de contacto genera bitacora de error. 
											 
	                                          LET vsCodRet1 = '002';
                                              LET vsMensaje   = 'Titular no tiene registrado celular o correo electronico.';
											  UPDATE  intercard:"informix".bitacoraenvios_tjts SET cod_ret = vsCodRet1, estatus_envio = 'E', descripcion = vsMensaje 
                                              WHERE secuencial = vsecuencial; 
                                             
	                                        END IF;
							    END IF;	
	                            ------------------
	 
	         ELSE 
				    IF (vstelefono <> '' AND vstelefono is not null)  THEN   
					    
						---  INVOCAR  SP REGISTRA EVENTO (SMS) 
						    LET  vsString1  =  SUBSTR(vNumTarjeta,13,4); 
				            EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento  ('1',valerta2,vIdPlantilla2,'000000000','',vNumTarjeta,'1',vsString1,'','','','','','','','','','',vstelefono,0,0,0,0,0,vdFechaHoy,'')
                            INTO 	cCodRet;
							
								    IF  ( cCodRet <> '00000' )  THEN 
                                        LET vsCodRet1 = '004';
										LET vsMensaje = 'Hubo un error al registrarse en bdimnsj.';
                                        UPDATE  intercard:"informix".bitacoraenvios_tjts SET cod_ret = vsCodRet1,estatus_envio = 'E',descripcion = vsMensaje
                                        WHERE secuencial = vsecuencial; 
	                                END IF; 
							
							UPDATE  intercard:"informix".bitacoraenvios_tjts SET cod_ret = '000',estatus_envio = 'V',descripcion = 'Se envio SMS al titular.' 
                            WHERE secuencial = vsecuencial;
						
	                  ELSE    --- De no encontrar el telefono procede con la busqueda de algun correo electronico. 
									
					        EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_correos("001",vsnumcte,1,"0")
				            INTO vsCodRet2,vscorreo,vstipocorreo,vsStatuscorreo; 
									
							    IF vsCodRet2 <> '000' THEN   -- Guarda bitacora en caso de generar un error en el proceso anterior. 
					                LET vsCodRet1 = '006';
									LET vsMensaje = 'Error al obtener telefono y correo del titular.';
									UPDATE  intercard:"informix".bitacoraenvios_tjts SET cod_ret = vsCodRet1,estatus_envio = 'E',descripcion = vsMensaje
                                    WHERE secuencial = vsecuencial; 
									
							     ELSE 
	 
	                                        IF (vscorreo <> '' AND vscorreo is not null)  THEN  
											  	---  INVOCAR  SP REGISTRA EVENTO (EMAIL) 
												    LET  vsString1  =  SUBSTR(vNumTarjeta,13,4); 
									                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento  ('1',valerta1,vIdPlantilla1,'000000000','',vNumTarjeta,'1',vsString1,'','','','','','','','','',vscorreo,'',0,0,0,0,0,vdFechaHoy,'')
                                                    INTO 	cCodRet;
													
                                                    IF  ( cCodRet <> '00000' )  THEN 
                                                        LET vsCodRet1 = '004';
														LET vsMensaje = 'Hubo un error al registrarse en bdimnsj.';
                                                        UPDATE  intercard:"informix".bitacoraenvios_tjts SET cod_ret = vsCodRet1,estatus_envio = 'E',descripcion = vsMensaje
                                                        WHERE secuencial = vsecuencial; 
	                                                END IF; 
													
													UPDATE  intercard:"informix".bitacoraenvios_tjts SET cod_ret = '000',estatus_envio = 'V',descripcion = 'Se envio Correo al titular.' 
                                                    WHERE secuencial = vsecuencial; 
													
									         ELSE    --- De no hallar ningun medio de contacto genera bitacora de error. 
	                                          LET vsCodRet1 = '003';
											  LET vsMensaje = 'Titular no tiene registrado celular o correo electronico.';
											  UPDATE  intercard:"informix".bitacoraenvios_tjts SET cod_ret = vsCodRet1,estatus_envio = 'E',descripcion = vsMensaje
                                              WHERE secuencial = vsecuencial; 
                                             
	                                        END IF;
										
							    END IF;	
					END IF;		
			END IF; 	  
	 
	      ELSE  
              LET vsCodRet1 = '001';  
              LET vsMensaje   = 'Cliente no se pudo identificar con tarjeta : '||vNumTarjeta||'';
		  
          UPDATE intercard:"informix".bitacoraenvios_tjts SET cod_ret = vsCodRet1,estatus_envio = 'F',descripcion = vsMensaje
          WHERE secuencial = vsecuencial; 		         

	      END IF;   				 
	 
----------------------------------------------------------------------------------------------------------------------------------------------------
RETURN 	vsCodRet1,vsMensaje; 
   
END;
END PROCEDURE;