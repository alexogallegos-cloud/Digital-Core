CREATE PROCEDURE "informix".sp_cons_edotarjeta(pNumeroTarjeta char(20))
	--DATOS A REGRESAR---
	RETURNING
	CHAR(5),  -- Codigo de Retorno
	CHAR(3); -- # Estado


	--DEFINICION DE VARIABLES--
	DEFINE vCodRet		CHAR(5);
    DEFINE vStatus      CHAR(3);


	--INICIALIZACION DE VARIABLES--
	LET vCodRet = "00000";
	LET vStatus = "";

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	-- CONSULTA --
	SELECT
        codstatustarjeta
	INTO
       vStatus
	FROM
		"informix".tarjeta
	WHERE
         numtarjeta = pNumeroTarjeta;

	IF vStatus IS NULL THEN
		LET vCodRet	    = "00002"; 
    END IF

	RETURN vCodRet, vStatus;

END PROCEDURE
DOCUMENT
"Modificó: Jesús Alberto Rubio Lugo",
"Descripción Se crea sp para consultar el estado de las tarjetas en la base de datos y tabla intercard: tarjeta",
"Fecha: 26/02/2019",
"Folio: 527- NO permitir el cambio de NIP a una tarjeta bloqueada",
"BD: intercard",
"Solicita: Cutberto Gonzales";

CREATE PROCEDURE "informix".sp_rpt_reporte_parametrico
(
     pdtFechaIni DATE, --Fecha Inicio del Periodo '<mm-dd-aaaa'>
	 pdtFechaFin DATE, --Fecha Final del Periodo  '<mm-dd-aaaa'>
	 psEstado CHAR(2), --Codigo de bdinteg:si_estados.estado 
	 psCiudad CHAR(3), --Código de bdinteg:si_ciudades.ciudad 
	 psOrigen CHAR(1), --'N'-Nacional, 'I'-Internacional o en blanco cualquiera. 
	 psProdInd CHAR(1),--'A' - ATM, 'P' - POS y vacio para ambos.	 
	 psBin CHAR(6),    --Bin de acuerdo al catálogo intercard:bines.bin
	 psSubBin CHAR(2), -- Imagen de la tarjeta
	 psChipBanda CHAR(1), -- 'C' - Chip, 'B' - Banda, espacio en blanco todos.
	 psProductoInterCard CHAR(3), --Código de intercard:productotarjeta.codproductotarjeta  
	 psFechaExp CHAR(4), --Formato AAMM, 
	 psProducto CHAR(1), --  'C' - Crédito, 'D' - Débito. 
     psMetodoCaptura CHAR(2), -- Se recibirá '00', '01'-Digitada,, '02'-ATM, '05'-Chip, '09', '80' - Fall Back, '81'-Digitada, '90'-Banda, '92'-ContactLess	 
	 psTipoTransaccionposDigitada CHAR(2), --intercard:movimiento.tipotransaccionposdigitada
     psGiroComercio CHAR(4), --Código de intercard:gironegocio.codgironeg 
	 psIDTerminalRetailer CHAR(19), --No de afiliación o de cajero.
	 psCodigoIso CHAR(2) --  intercard:respuestaiso.codigoiso
)
RETURNING VARCHAR(5) AS CODIGO_RETORNO, VARCHAR(100) AS MENSAJE_RESPUESTA, INTEGER AS tot_registros;

    DEFINE SQLERR		INTEGER;
    DEFINE ISAM_ERR		INTEGER;
    DEFINE ERROR_INFO	VARCHAR(80);
 
    DEFINE CODIGO_RETORNO CHAR(5);
    DEFINE MENSAJE_RESPUESTA VARCHAR(100);
    DEFINE RUTA_ORIGEN  VARCHAR(80);

    
    DEFINE vitotalregistros INTEGER;
    DEFINE vdtFechaIni DATETIME YEAR TO FRACTION(5);
    DEFINE vdtFechaFin DATETIME YEAR TO FRACTION(5);
    DEFINE vFechaMinimaMov DATETIME YEAR TO FRACTION(5);  
    DEFINE vExecuteSQL LVARCHAR(4000);

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
      

    DEFINE vicontadorregistros integer;
    DEFINE vnumcliente  varchar(13);
    DEFINE vestado char(2);
    DEFINE vnombreestado char(30) ;
    DEFINE vnumciudad char(3) ;
    DEFINE vnombreCiudad VARCHAR(60,1);
    DEFINE vcanal varchar(3);
    DEFINE vChipBanda varchar(5);
    DEFINE vbin varchar(6);
    DEFINE vsubbin varchar(2) ;
    DEFINE vproductoInterCard varchar(3) ;
    DEFINE vdescproductoInterCard varchar(30) ;
    DEFINE vproducto varchar(7) ;
    DEFINE vCuentaProducto varchar(13) ;
    DEFINE vmetodocaptura varchar(2) ;
    DEFINE vtipotransaccionposdigitada varchar(2);
    DEFINE vterminaTarjeta varchar(16); --4
    DEFINE vfechaexp varchar(4) ;
    DEFINE vFecha date;
    DEFINE vtxnOrigen  varchar(3) ;
    DEFINE vcomercio  varchar(40) ;
    DEFINE vgiroComercio varchar(4) ;
    DEFINE vdescGiroComercio varchar(80) ;
    DEFINE vafiliacionTerminal  varchar(19) ;
    DEFINE vTipoTransaccion  varchar(12) ; 
    DEFINE vmontoTxn DECIMAL(19,4);
    DEFINE vmontoCashBack DECIMAL(19,4);
    DEFINE vmontoSurcharge DECIMAL(19,4);
    DEFINE vcodigoiso varchar(2);
    DEFINE vmotivo  VARCHAR(70);

     DEFINE vnumtarjeta  VARCHAR(16);
     DEFINE vformato     VARCHAR(4);
     DEFINE vcodreversa  VARCHAR(1); 
     DEFINE vidreceptor  VARCHAR(4);
     DEFINE vidterminal  VARCHAR(16);
     DEFINE vidretailer  CHAR(19);
     DEFINE vcodtran     VARCHAR(2);
     DEFINE vmonto        DECIMAL(19,4);
     DEFINE vmontorealrevfzda    DECIMAL(19,4);
     DEFINE vedonombre VARCHAR(30);
     DEFINE vcodgironeg VARCHAR(4);
     DEFINE pstipocarga CHAR(1);

    DEFINE vcFechaCompInicial DATETIME YEAR TO FRACTION(5);
    DEFINE vcFechaCompFinal DATETIME YEAR TO FRACTION(5);
    
    
    
    ---Inicializar
    LET CODIGO_RETORNO = '00000';
    LET MENSAJE_RESPUESTA = 'Ejecucion correcta.'; 
    LET RUTA_ORIGEN = '/RESPALDOSNEW/'; -- Producción  
    --LET RUTA_ORIGEN = '/ifxsif01/_argoz/parametrico/'; -- Desarrollo
    LET vitotalregistros = 0;
    LET vExecuteSQL = '';
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

    LET vnumcliente = '';
    LET vestado  = '';
    LET vnombreestado = '';
    LET vnumciudad = '';
    LET vnombreCiudad = '';
    LET vcanal = '';
    LET vChipBanda = '';
    LET vbin  = '';
    LET vsubbin = '';
    LET vproductoInterCard = '';
    LET vdescproductoInterCard = '';
    LET vproducto = '';
    LET vCuentaProducto = '';
    LET vmetodocaptura = '';
    LET vtipotransaccionposdigitada = '';
    LET vterminaTarjeta = '';
    LET vfechaexp = '';
    LET vFecha = '';
    LET vtxnOrigen  = '';
    LET vcomercio = '';
    LET vgiroComercio = '';
    LET vdescGiroComercio = '';
    LET vafiliacionTerminal = '';
    LET vTipoTransaccion  = '';
    LET vmontoTxn = '';
    LET vmontoCashBack = '';
    LET vmontoSurcharge  = '';
    LET vcodigoiso  = '';
    LET vmotivo   = '';
 
    LET vnumtarjeta  = '';
    LET vformato     = '';
    LET vcodreversa  = '';
    LET vidreceptor  = '';
    LET vidterminal  = '';
    LET vidretailer  = '';
    LET vcodtran     = '';
    LET vmonto               = 0;
    LET vmontorealrevfzda    = 0;
    LET vedonombre  = '';
    LET vcodgironeg = '';
    LET pstipocarga = '';

    LET vcFechaCompInicial = '';
    LET vcFechaCompFinal = '';
    
    --SET DEBUG FILE TO RUTA_ORIGEN||"sp_rpt_reporte_parametrico.out";
    --TRACE ON;
 
	BEGIN
    
        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
        
            SET DEBUG FILE TO RUTA_ORIGEN || "excepcion_sp_rpt_reporte_parametrico.out";
            TRACE ON;
            
            IF ( SQLERR <> 0 ) THEN
                LET CODIGO_RETORNO = SQLERR;
                LET MENSAJE_RESPUESTA = ERROR_INFO;
                RETURN CODIGO_RETORNO, MENSAJE_RESPUESTA,NVL(viTotalRegistros,0);
            END IF;
        END EXCEPTION;
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

        ---Validar fechas
        EXECUTE PROCEDURE "informix".sp_rpt_validar_fechas_reporte (pdtFechaIni, pdtFechaFin)
            INTO CODIGO_RETORNO, MENSAJE_RESPUESTA, vcFechaCompInicial, vcFechaCompFinal;
    
        IF(CODIGO_RETORNO <> '00000') THEN
            LET CODIGO_RETORNO = CODIGO_RETORNO;
            LET MENSAJE_RESPUESTA = MENSAJE_RESPUESTA||'ingresa a sp_rpt_validar_fechas_reporte';
            RETURN CODIGO_RETORNO, MENSAJE_RESPUESTA,NVL(viTotalRegistros,0);
        END IF;

        ---Validar parametros
        EXECUTE PROCEDURE "informix".sp_rpt_calcular_parametros (psEstado,  psCiudad,  psOrigen,  psProdInd,  psBin, psSubBin,  psChipBanda,  psProductoInterCard,
                                                      psFechaExp,  psProducto,  psMetodoCaptura,  psTipoTransaccionposDigitada, psGiroComercio,  psIDTerminalRetailer,  psCodigoIso)  

            INTO CODIGO_RETORNO, MENSAJE_RESPUESTA,det_estado, det_Ciudad,det_Origen,det_Origen2,det_ProdInd, det_ProdInd2,det_ChipBanda,det_MetodoCaptura,det_TipoTransaccionposDigitada,
	             det_Bin,det_SubBin,det_ProductoInterCard,det_FechaExp,det_GiroComercio,det_CodigoIso,det_IDTerminalRetailer,det_TerminalRetailer,det_ChipBanda2;
        
        IF(CODIGO_RETORNO <> '00000') THEN
            LET CODIGO_RETORNO = CODIGO_RETORNO;
            LET MENSAJE_RESPUESTA = MENSAJE_RESPUESTA||'ingresa a sp_rpt_calcular_parametros';
            RETURN CODIGO_RETORNO, MENSAJE_RESPUESTA,NVL(viTotalRegistros,0);
        END IF

        TRUNCATE TABLE intercard:"informix".rpt_movimientopaso;
        TRUNCATE TABLE intercard:"informix".rptdinamico;

        LET vdtFechaIni = pdtFechaIni;
        LET vdtFechaFin = pdtFechaFin; 
        LET vFechaMinimaMov = CURRENT;
  
        --OBTIENE LA FECHA MINIMA DE LA TABLA DE MOVIMIENTOS  EJ:  01/NOV/2017
        SELECT MIN(FechaHoraInAuth) 
            INTO vFechaMinimaMov
        FROM intercard:"informix".movimiento;
 
        -- A ===> Bandera para indicar que la busqueda se realice en intercard:movimiento 
        -----===>  e intercard:movimientohistorico
        LET pstipocarga = 'A';
 
        --VALIDA SI EL RANGO DE BUSQUEDA ESTA DENTRO DE LA TABLA <MOVIMIENTO>	 
        IF ( (pdtFechaIni >= vFechaMinimaMov::DATE AND pdtFechaIni <= CURRENT::DATE)    -- EJ: 15/NOV/2017 >= 01/NOV/2017  AND 15/NOV/2017 <= 28/DIC/2017 (ACTUAL) 
                AND 
                (pdtFechaFin >= vFechaMinimaMov::DATE AND pdtFechaFin <= CURRENT::DATE)    -- EJ: 30/NOV/2017 >= 01/NOV/2017  AND 30/NOV/2017 <= 28/DIC/2017 (ACTUAL)
            ) THEN

                -- M ===> Bandera para indicar que la busqueda se realice en intercard:movimiento
                LET pstipocarga = 'M';

            ELIF ( (pdtFechaIni < vFechaMinimaMov::DATE) -- EJ: 01/OCT/2017  <  01/NOV/2017
                        AND (pdtFechaFin < vFechaMinimaMov::DATE) -- EJ: 31/OCT/2017  <  01/NOV/2017
                            
                ) THEN

                -- H  ===> Bandera para indicar que la busqueda se realice en intercard:movimientohistorico
                LET pstipocarga = 'H';

            END IF;

            EXECUTE PROCEDURE "informix".sp_rpt_obtener_transacciones (vcFechaCompInicial, vcFechaCompFinal, pstipocarga )
                    INTO CODIGO_RETORNO, MENSAJE_RESPUESTA;

            IF(CODIGO_RETORNO <> '00000') THEN
            
                LET CODIGO_RETORNO = CODIGO_RETORNO;
                LET MENSAJE_RESPUESTA =  MENSAJE_RESPUESTA;
                RETURN CODIGO_RETORNO, MENSAJE_RESPUESTA,NVL(viTotalRegistros,0);
            END IF

      -- Genera reporte final en base a la tabla de paso y con las tablas auxiliares para obtener los datos complementarios de la transacción
        ---	  (Tarjeta, cliente, estado etc):
            EXECUTE PROCEDURE "informix".sp_rpt_filtrado_param
                        (vcFechaCompInicial, vcFechaCompFinal, psEstado,         psCiudad,  psOrigen,  psProdInd,  psBin, psSubBin,  psChipBanda,  psProductoInterCard,
                         psFechaExp,  psProducto,  psMetodoCaptura,  psTipoTransaccionposDigitada, psGiroComercio,  psIDTerminalRetailer,  psCodigoIso,
                         det_estado, det_Ciudad,det_Origen,det_Origen2,det_ProdInd, det_ProdInd2,det_ChipBanda,det_MetodoCaptura,det_TipoTransaccionposDigitada,
                         det_Bin,det_SubBin,det_ProductoInterCard,det_FechaExp,det_GiroComercio,det_CodigoIso,det_IDTerminalRetailer,det_TerminalRetailer,det_ChipBanda2)
                INTO CODIGO_RETORNO, MENSAJE_RESPUESTA;
 	
            IF(CODIGO_RETORNO <> '00000') THEN
                LET CODIGO_RETORNO = CODIGO_RETORNO;
                LET MENSAJE_RESPUESTA =  MENSAJE_RESPUESTA||'error sp_rpt_filtrado_param';
                RETURN CODIGO_RETORNO, MENSAJE_RESPUESTA,NVL(viTotalRegistros,0);
            END IF;

		    EXECUTE PROCEDURE "informix".sp_rpt_generar_archivo( RUTA_ORIGEN )
                INTO  CODIGO_RETORNO, MENSAJE_RESPUESTA;

            IF ( CODIGO_RETORNO <> '00000' ) THEN
            
                LET CODIGO_RETORNO = CODIGO_RETORNO;
                LET MENSAJE_RESPUESTA =  MENSAJE_RESPUESTA||'error sp_rpt_generar_archivo';
                RETURN CODIGO_RETORNO, MENSAJE_RESPUESTA,NVL(viTotalRegistros,0);
            END IF;
 
		 	--Obtiene el numero de registros procesados en el archivo resultante
		    SELECT COUNT(*) 
                INTO vitotalregistros 
            FROM intercard:"informix".rptdinamico;
		 	
		    TRUNCATE TABLE intercard:"informix".rpt_movimientopaso;
		    TRUNCATE TABLE intercard:"informix".rptdinamico;

		 RETURN CODIGO_RETORNO, MENSAJE_RESPUESTA,NVL(viTotalRegistros,0);


	END;
END PROCEDURE;