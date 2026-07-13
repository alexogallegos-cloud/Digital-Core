CREATE PROCEDURE "informix".sp_acl_regulatorio27 (pFechaCap_Ini DATE,pFechaCap_Fin DATE)

	RETURNING CHAR(5);

-- ****************************************************************************
-- DefiniciÃ³n de Variables de datos 
-- ****************************************************************************

	DEFINE CodRet                        CHAR(5);
    define icontador                     integer;
	DEFINE v_folio_csuac                 VARCHAR (11);                    
	DEFINE v_fechacaptura                DATE;                            
	DEFINE v_importereclamado            MONEY;                           
	DEFINE v_fky_estatus_aclaracion      INTEGER;                         
	DEFINE v_fecha_dictamen              DATEtime YEAR to FRACTION(5);    
	DEFINE v_montoprocedente             MONEY;                           
	DEFINE v_fky_tipo_codigo_resolucion  INTEGER;                         
	DEFINE v_procede					 SMALLINT;                        
	DEFINE v_fky_producto                INTEGER;                         
	DEFINE v_fky_tipo_evento             INTEGER;                         
	DEFINE v_fky_estatus_corp_general    INTEGER;                         
	DEFINE v_fechahora                   DATEtime YEAR to FRACTION(5);    
	DEFINE v_fecha_abono                 DATEtime YEAR to FRACTION(5);  
	DEFINE v_fky_tipo_producto           INTEGER;                         
	DEFINE v_numero_cuenta               VARCHAR (20);                    
	DEFINE v_numero_tarjeta              VARCHAR (16);                    
	DEFINE v_pky_tipo_producto 			 INTEGER;                         
	DEFINE v_des_tipo_producto			 VARCHAR (255);	                  
	DEFINE v_origen_evento               INTEGER;                         
	DEFINE v_pky_tipo_evento			 INTEGER;                         
	DEFINE v_desc_evento                 VARCHAR (50);                    
	DEFINE v_desc_origen                 VARCHAR (50);                    
	DEFINE v_desc_aclaracion			 VARCHAR (255);                   
	DEFINE v_pky_estatus_corporativo	 INTEGER;                         
	DEFINE v_codigo_resolucion           VARCHAR (4);                     
	DEFINE v_desc_resolucion             VARCHAR (255);                     
	DEFINE v_importe_rec                 MONEY;                           
	DEFINE v_quebranto_inst              MONEY;                           
	DEFINE v_transaccion_quebranto       INTEGER;
	DEFINE v_folio_csuac_r27             VARCHAR (11);                    
	DEFINE v_fky_estatus_aclaracion_r27  INTEGER;
	
	DEFINE v_tipo_procedente			 INTEGER;
	
	DEFINE v_fecha_inicio_min            DATE;
	DEFINE v_fecha_inicio                DATE;                             
	DEFINE v_fecha_fin                   DATE;   

	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO "/resplogifx/traces/IAP/SPR27";
--TRACE ON;
	
-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************
	
	LET CodRet                            = '00000';
	
	LET v_folio_csuac                     = '';
	LET v_fechacaptura                    = '';
	LET v_importereclamado                = '';
	LET v_fky_estatus_aclaracion          = 0 ;
	LET v_fecha_dictamen                  = '';
	LET v_montoprocedente                 = '';
	LET v_fky_tipo_codigo_resolucion      = 0 ;
	LET v_procede                         = 0 ;
	LET v_fky_producto                    = 0 ;
	LET v_fky_tipo_evento                 = 0 ;
	LET v_fky_estatus_corp_general        = 0 ;
	LET v_fechahora                       = '';
	LET v_fecha_abono                     = '';
	LET v_numero_cuenta                   = '';
	LET v_numero_tarjeta                  = '';
	LET v_pky_tipo_producto               = 0 ;
	LET v_des_tipo_producto               = '';
	LET v_origen_evento                   = 0 ;
	LET v_pky_tipo_evento                 = 0 ;
	LET v_desc_evento                     = '';
	LET v_desc_origen                     = '';
	LET v_desc_aclaracion                 = '';
	LET v_pky_estatus_corporativo         = '';
	LET v_codigo_resolucion               = '';
	LET v_desc_resolucion                 = '';
    LET v_importe_rec                     = '';    
    LET v_quebranto_inst                  = '';
	LET v_transaccion_quebranto           = 0 ;
	LET v_folio_csuac_r27                 = '';
	LET v_fky_estatus_aclaracion_r27      = 0 ;
	
	LET v_tipo_procedente                 = 0 ;

	LET v_fecha_inicio_min                = '';            -- Fecha para inicio de bÃºsqueda por aclaraciÃ³n activa mÃ¡s antigua.               
	LET v_fecha_inicio                    = pFechaCap_Ini;                           
	LET v_fecha_fin                       = pFechaCap_Fin;
	LET icontador=0;

-->> Fecha mas antigua con aclaraciones con estatus de ingresadas

	SELECT MIN (fechacaptura) 
	INTO v_fecha_inicio_min
	FROM acl_aclaracion 
	WHERE fky_estatus_aclaracion = 2;

BEGIN WORK;
FOREACH WITH HOLD

	-- select * from acl_aclaracion                                             -- A
	SELECT 
	folio_csuac, fechacaptura, importereclamado, fky_estatus_aclaracion, fecha_dictamen, montoprocedente, fky_tipo_codigo_resolucion, procede
	,fky_producto, fky_tipo_evento, fky_estatus_corp_general
	INTO 
	v_folio_csuac, v_fechacaptura, v_importereclamado, v_fky_estatus_aclaracion, v_fecha_dictamen, v_montoprocedente, v_fky_tipo_codigo_resolucion, v_procede
	,v_fky_producto, v_fky_tipo_evento, v_fky_estatus_corp_general
	FROM acl_aclaracion a
	WHERE (fky_tipo_evento NOT IN (40, 42, 44, 45, 46, 47, 53, 54) AND fky_estatus_aclaracion > 1 AND fechacaptura BETWEEN pFechaCap_Ini AND pFechaCap_Fin AND folio_csuac IS NOT NULL)  -->> Ingresadas en el periodo
	OR    (fechacaptura >= v_fecha_inicio_min AND fky_tipo_evento NOT IN (40, 42, 44, 45, 46, 47, 53, 54) AND fechacaptura < pFechaCap_Ini AND fky_estatus_aclaracion in (2))            -->> Sin resolver en el periodo
	OR    (fky_tipo_evento NOT IN (40, 42, 44, 45, 46, 47, 53, 54) AND fechacaptura < pFechaCap_Ini AND DATE(fecha_dictamen) BETWEEN pFechaCap_Ini AND pFechaCap_Fin)	                 -->> Resultas en el periodo
	
	-->> select * from acl_movimiento												-- B 
	SELECT fechahora AS fecha_mov_original, fecha_afectacion as fecha_abono
	INTO v_fechahora, v_fecha_abono
	FROM acl_movimiento
	WHERE folio_csuac = v_folio_csuac
	AND fky_padre IS NULL
	AND duplicado = 0; 																--> ValidaciÃ³n de movimientos duplicados 11/03/2013

	SELECT b.quebranto_transaccion AS transaccion_quebranto
	INTO v_transaccion_quebranto
	FROM acl_movimiento a, acl_tipo_catalogo_transaccion b
	WHERE b.pky_tipo_catalogo_transaccion = a.fky_tipo_catalogo_transaccion 
    AND a.folio_csuac = v_folio_csuac
	AND a.fky_padre IS NULL
    AND b.quebranto_transaccion = 1 ;

	-- >> select * from acl_producto												-- C
	SELECT fky_tipo_producto, numero_cuenta, numero_tarjeta
	INTO v_fky_tipo_producto, v_numero_cuenta, v_numero_tarjeta
	FROM acl_producto 
	WHERE pky_producto = v_fky_producto;

	-- >> select * from acl_tipo_producto											-- C.C
	SELECT pky_tipo_producto, descripcion
	INTO v_pky_tipo_producto, v_des_tipo_producto
	FROM acl_tipo_producto
	WHERE pky_tipo_producto = v_fky_tipo_producto;
	
	-->> select * from acl_tipo_evento                                              -- D
	SELECT fky_origen_evento, pky_tipo_evento, descripcion as desc_evento
	INTO v_origen_evento, v_pky_tipo_evento, v_desc_evento
	FROM acl_tipo_evento
	WHERE pky_tipo_evento = v_fky_tipo_evento;
	
	-->> select * from acl_origen_evento                                            -- E
	SELECT descripcion as desc_origen_evento
	INTO v_desc_origen
	FROM acl_origen_evento
	WHERE pky_origen_evento = v_origen_evento;
	
	-->> select * from acl_estatus_aclaracion                                       -- F
	SELECT descripcion as desc_aclaracion
	INTO v_desc_aclaracion
	FROM acl_estatus_aclaracion
	WHERE pky_estatus_aclaracion = v_fky_estatus_aclaracion;
	
	-->> select * from acl_estatus_corporativo                                      -- G
	SELECT pky_estatus_corporativo
	INTO v_pky_estatus_corporativo
	FROM acl_estatus_corporativo
	WHERE pky_estatus_corporativo = v_fky_estatus_corp_general;
	
	-->> select * from acl_tipo_codigo_resolucion                                   -- H
	SELECT codigo_resolucion, descripcion as desc_resolucion, tipo_procedente
	INTO v_codigo_resolucion, v_desc_resolucion, v_tipo_procedente
	FROM acl_tipo_codigo_resolucion
	WHERE pky_tipo_codigo_resolucion = v_fky_tipo_codigo_resolucion;

--- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ValidaciÃ³n no duplicar aclaraciones dictaminadas y ya reportadas.
	
	SELECT folio_csuac, fky_estatus_aclaracion
	INTO v_folio_csuac_r27, v_fky_estatus_aclaracion_r27
	FROM acl_regulatorio27 
	WHERE folio_csuac = v_folio_csuac 
	AND fky_estatus_aclaracion in(3,4,5);
	
	IF v_fky_estatus_aclaracion_r27 in (3,4,5) THEN 

		CONTINUE FOREACH;
	
	END IF;
				
		--CONTINUE FOREACH;
		
--- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ValidaciÃ³n de monto recuperados -- ok

    IF v_fky_estatus_aclaracion in (3,4,5) AND v_transaccion_quebranto <> 1 THEN

        LET v_quebranto_inst = 0;

        SELECT montoprocedente as monto_procedente, montoprocedente as importe_recuperado -- >> Montos Recuperados
        INTO v_montoprocedente, v_importe_rec
        FROM acl_aclaracion 
        WHERE folio_csuac = v_folio_csuac;

    END IF;

    IF v_fky_estatus_aclaracion in (3,4,5) AND v_fky_estatus_corp_general <> 19 THEN

        LET v_quebranto_inst = 0;

        SELECT montoprocedente as monto_procedente, montoprocedente as importe_recuperado -- >> Montos Recuperados
        INTO v_montoprocedente, v_importe_rec
        FROM acl_aclaracion 
        WHERE folio_csuac = v_folio_csuac 
		AND v_procede = 1; -- ValidaciÃ³n para finalizadas

    END IF;

--- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ValidaciÃ³n de monto quebrantado por abono sin autorizaciÃ³n -- ok

    IF v_fky_estatus_aclaracion IN (3,4,5) AND v_fky_estatus_corp_general = 19 THEN

        LET v_importe_rec = 0;

        SELECT importereclamado as monto_procedente, importereclamado as quebranto_institucion  -- >> Montos quebrantados
        INTO v_montoprocedente, v_quebranto_inst
        FROM acl_aclaracion a
        WHERE folio_csuac = v_folio_csuac;

        SELECT codigo_resolucion, descripcion
        INTO v_codigo_resolucion, v_desc_resolucion
        FROM bdiaclaracion:acl_tipo_codigo_resolucion where codigo_resolucion = '653';

    END IF;

--- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ValidaciÃ³n de monto quebrantado por selecciÃ³n de transacciÃ³n -- ok

    IF v_transaccion_quebranto = 1 THEN
    
        LET v_importe_rec = 0;

        SELECT importereclamado as monto_procedente, importereclamado as quebranto_institucion  -- >> Montos quebrantados
        INTO v_montoprocedente, v_quebranto_inst
        FROM acl_aclaracion
        WHERE folio_csuac = v_folio_csuac;

    END IF;

--- >> Formateo de Campos

    IF v_quebranto_inst IS NULL THEN    -- ValidaciÃ³n de monto quebrantado para que no se coloque en null
        LET v_quebranto_inst = 0;
    END IF;

    IF v_montoprocedente IS NULL THEN   -- ValidaciÃ³n de monto procedente para que no se coloque en null
        LET v_montoprocedente = 0;
    END IF;

    IF v_importe_rec IS NULL THEN       -- ValidaciÃ³n de monto recuperado para que no se coloque en null
        LET v_importe_rec = 0;
    END IF;

--- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Aclaraciones Concluidas sin Procede a favor del cliente por Abono sin AutorizaciÃ³n -- ok
	
	IF v_fky_estatus_aclaracion in (3,4,5) AND v_procede IS NULL AND v_fky_estatus_corp_general = 19 THEN
	
	LET v_procede = 1 ; -- Abono a favor del Cliente
	
	END IF;

--- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Suma de Montos a Favor CrÃ©dito
{	
	IF v_fky_estatus_aclaracion in (3,4,5) AND v_pky_tipo_evento in (7,15,17,18,19,24,48,50,51) THEN
	
	SELECT SUM (monto) 
	INTO v_importereclamado
	FROM acl_movimiento WHERE folio_csuac = v_folio_csuac;
		
	END IF;

--- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Suma de Montos a Favor CrÃ©dito Procedentes

	IF v_fky_estatus_aclaracion in (3,4,5) AND v_pky_tipo_evento in (7,15,17,18,19,24,48,50,51) AND v_procede = 1 AND v_montoprocedente <> v_importe_rec THEN
	
	LET v_montoprocedente = v_importe_rec ;
		
	END IF;-
}	

--- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ValidaciÃ³n Aclaraciones pendientes y/o concluidas despuÃ©s de el periodo a reportar no mostrar datos innecesarios
	 IF v_fky_estatus_aclaracion = 2 OR DATE (v_fecha_dictamen) > pFechaCap_Fin THEN -- Agregada
	    SELECT codigo_resolucion, descripcion
        INTO v_codigo_resolucion, v_desc_resolucion
        FROM bdiaclaracion:acl_tipo_codigo_resolucion where codigo_resolucion = '654';

		LET v_montoprocedente 	= 0;    -- ValidaciÃ³n de monto procedente para que no se coloque en null    
        LET v_importe_rec 		= 0;	-- ValidaciÃ³n de monto recuperado para que no se coloque en null
        LET v_quebranto_inst 	= 0;	-- ValidaciÃ³n de monto quebrantado para que no se coloque en null
		LET v_fecha_abono 		= '';
		LET v_fecha_dictamen	= ''; 	-- Agregada
		LET v_procede 			= ''; 	-- Agregada 
		
			IF v_fky_estatus_aclaracion > 2 THEN 
			
				SELECT descripcion as desc_aclaracion  
				INTO v_desc_aclaracion				-- Cambiar la descripciÃ³n de estatus de la aclaraciÃ³n a Ingresada
				FROM acl_estatus_aclaracion
				WHERE pky_estatus_aclaracion = 2;	
				
				LET v_fky_estatus_aclaracion = 2;	-- Cambiar estatus de la aclaraciÃ³n a 2
			
			END IF;

    END IF;

	
--- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Adecuaciones para aclaraciones correspondientes a productos '1900' y '2200' para capturarlos como "Cuentas de Cheques" por peticiÃ³n de usuario 24/09/2014 <<<<<<<<<<<<<
IF (SUBSTR (v_numero_cuenta , 0, 4) IN ('1900', '2200') AND v_numero_tarjeta = '' OR v_numero_tarjeta IS NULL) THEN
	LET v_pky_tipo_producto = 4;
	LET v_des_tipo_producto = 'Cuentas de Cheques';
END IF;
--------------------------------------------------------------------------------------------------------------------------------------------

	INSERT INTO acl_regulatorio27
	VALUES (v_folio_csuac, v_fechacaptura, v_fechahora, v_numero_cuenta, v_numero_tarjeta, v_pky_tipo_producto, 
	v_des_tipo_producto, v_origen_evento, v_desc_origen, v_pky_tipo_evento, v_desc_evento, v_importereclamado, v_fky_estatus_aclaracion, 
	v_desc_aclaracion, v_procede, v_fecha_dictamen, v_fecha_abono, v_codigo_resolucion, v_desc_resolucion, v_montoprocedente, 
	v_importe_rec, v_quebranto_inst, v_fecha_inicio, v_fecha_fin, current);
	
	LET iContador = iContador + 1;
    IF iContador= 1000 THEN COMMIT WORK;
    LET iContador=0;
    BEGIN WORK;
    END IF;

END FOREACH

LET iContador=0;

-- No es posible convertir entre los tipos especificados
	
	--UPDATE "informix".acl_control_r27 SET exito = 1, fecha_exito = CURRENT WHERE fecha_fin = pFechaCap_Fin;

	LET CodRet = '00000';
	
	RETURN CodRet;
	
END PROCEDURE;