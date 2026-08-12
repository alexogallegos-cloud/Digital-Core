CREATE PROCEDURE "informix".sp_concreing_consultaparam (psCodigo VARCHAR(3))

RETURNING VARCHAR(3) AS Codigo, VARCHAR(50) AS Descripcion, VARCHAR(90) AS Valor, DATETIME YEAR TO FRACTION(5) AS Fecha_Modificacion;

--****************************************************************************************************
-- DESCRIPCION: Obtiene la informacion correspondiente del codigo del paramatero indicado.
-- AUTOR : Casanova Edeza Hector Juan
-- FECHA : 20/11/2012
-- BD: BdiTrajeta
-- SISTEMA : Reingenieria Conciliacion
-- MODIFICADO :

--***************************************************************************************************

/*  DEFINICION DE VARIABLES */
DEFINE vsCodigo VARCHAR(3);
DEFINE vsDescripcion VARCHAR(50);
DEFINE vsValor VARCHAR(90);
DEFINE vdtFecha_Modificacion DATETIME YEAR TO FRACTION(5) ;

DEFINE visqlerr INTEGER ;

/* INICIALIZACION DE VARIABLES */

LET vsCodigo = '';
LET vsDescripcion = '';
LET vsValor = '';
LET vdtFecha_Modificacion = CURRENT;

LET visqlerr = 0 ;

BEGIN

	ON EXCEPTION SET visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado

		RETURN '', ('ERROR' || visqlerr), '', CURRENT;

	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	--OBTIENE LA INFORMACION DEL PARAMTRO
	SELECT FIRST 1 Codigo, Descripcion, Valor, Fecha_Modificacion
	INTO vsCodigo, vsDescripcion, vsValor, vdtFecha_Modificacion
	FROM BdiTarjeta:"informix".td_param_conciliacion_concreing
	WHERE Codigo = psCodigo;
	
	RETURN NVL(vsCodigo, ''), NVL(vsDescripcion, ''), NVL(vsValor, ''), NVL(vdtFecha_Modificacion, CURRENT);

END

END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: OBTIENE LA INFORMACION CORRESPONDIENTE DEL CODIGO DEL PARAMATERO INDICADO.',
'Fecha: 2012/11/20',
'Version: 20121120.1637',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_tras_movhis_con(cNumEmpl varchar(9))
RETURNING VARCHAR(6) as Cod_ret,VARCHAR(80) as Men_ret;     
	DEFINE  SQL_ERR          INTEGER;
	DEFINE  ISAM_ERR         INTEGER;
	DEFINE  ERROR_INFO       VARCHAR(80);
	DEFINE  P_COD_RET        VARCHAR(6);
	DEFINE  P_COD_RET2       VARCHAR(6);
	DEFINE  P_MENSAJE        VARCHAR(80);
	DEFINE  iValor           INTEGER;
	DEFINE  dFechaFin        DATE;	
	DEFINE  iNumReg          INTEGER;
	
		
	--SET DEBUG FILE TO "/informix/HomeInformix/rrm/movhis.out";
	--TRACE ON;

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
	  
	  EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora('47','Error en sp_tras_movhis_con ' || SQL_ERR || ' ' || P_MENSAJE,cNumEmpl) INTO P_COD_RET2;
	  
      RETURN P_COD_RET,P_MENSAJE;
   END EXCEPTION;

--************************************************************
-- Creado por Manuel Osuna Valencia 
-- fecha : 19/10/2011
-- Funcion: Traspaso de Informacion de movimientos a historico 
--************************************************************

   LET P_COD_RET = '00000';
   LET P_COD_RET2 = '00000';
   LET P_MENSAJE = 'PROCESO EXITOSO TRANSFERENCIA DE MOVIMIENTOS A HISTORICOS';
   LET iValor = 0;
   LET iNumReg = 0;
   
   
   
   	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	SELECT valor INTO iValor FROM bditarjeta:"informix".td_param_conciliacion_concreing WHERE codigo = '403';	
	
		
	IF (iValor == 0) THEN
	   LET P_COD_RET = '00000';
	   LET P_MENSAJE = 'NO EXISTEN DIAS A SUBSTRAER.. ';	
	ELSE
		
		SELECT fecha_hoy - iValor units day INTO dFechaFin  FROM bdinteg:"informix".si_fechas;
		
		set isolation to dirty read;
		select count(*) into iNumReg from bditarjeta:"informix".td_movimientos_conciliacion 
		where date(fechacarga) <= dFechaFin;
		
		-- Se quito para ser insertado por bloques
		
		/*INSERT INTO bditarjeta:"informix".td_movimientos_conciliacion_his(consecutivo,nombrearchivo,archivo_origen,fechacarga,integridad,integridad_error,numtarjeta,secuencia325,
			   monto325,montosurcharge325,numcuenta,idcomercio325,nomcomercio325,tipotransaccion325,referencia23_325,
			   rfc325,divisa325,monto_divisa325,iso323, movrev325,conciliacion,secuencia,secuencia_extendida,montointercard,fechatransaccion,
			   infreceptor,idterminal,metodocaptura,movconciliado,movreversado,tipo_mov,folio_mov,fechaconcilia,tipo_conciliacion,
			   desc_conciliacion,aplicacion,transaccion_aplica,bandera_proceso,cod_retorno,fechaaplica)
		SELECT consecutivo,nombrearchivo,archivo_origen,fechacarga,integridad,integridad_error,numtarjeta,secuencia325,
			   monto325,montosurcharge325,numcuenta,idcomercio325,nomcomercio325,tipotransaccion325,referencia23_325,
			   rfc325,divisa325,monto_divisa325,iso323, movrev325,conciliacion,secuencia,secuencia_extendida,montointercard,fechatransaccion,
			   infreceptor,idterminal,metodocaptura,movconciliado,movreversado,tipo_mov,folio_mov,fechaconcilia,tipo_conciliacion,
			   desc_conciliacion,aplicacion,transaccion_aplica,bandera_proceso,cod_retorno,fechaaplica
		FROM bditarjeta:"informix".td_movimientos_conciliacion	   
		WHERE date(fechacarga) <= dFechaFin;	   */
         
		--LET iNumReg =dbinfo("sqlca.sqlerrd2");
		
		
				
		EXECUTE PROCEDURE bditarjeta:"informix".sp_idmovhis_cnc (dFechaFin) into P_COD_RET, P_MENSAJE; -- Para Borrado por Bloques

		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora('47','Exito en Traspaso de Movimientos a Historico ' || iNumReg  || ' ' || 'Registros Transferidos ',cNumEmpl) INTO P_COD_RET;		
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora('47','Exito en Borrado de Movimientos ' || iNumReg  || ' ' || 'Registros Borrados ',cNumEmpl ) INTO P_COD_RET; -- Para registro en Bitacora de registros borrados 
		
	END IF;
     
	RETURN P_COD_RET,P_MENSAJE;
  
END;
END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICO LA LOGOCA PARA INCLUIR LOS NUEVOS CAMPOS DE LA TABLA DE MOVIMIENTOS ISO325 Y CODREV325.',
'Fecha: 2012/07/27',
'Version: 20120727.1715',
'BD: BdiTarjeta', 
'',
'Modifico: Ricardo Reséndiz Martínez',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Luis Antonio Gomez',
'Descripcion: Se agrego llamado a SP para el borrado de registros por bloques',
'Fecha: 2012/11/26',
'Version: 20121126.2000',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_tras_archivoshis_con(cNumEmpl varchar(9))
RETURNING VARCHAR(6) as Cod_ret,VARCHAR(80) as Men_ret;
	DEFINE  SQL_ERR          INTEGER;
	DEFINE  ISAM_ERR         INTEGER;
	DEFINE  ERROR_INFO       VARCHAR(80);
	DEFINE  P_COD_RET        VARCHAR(6);
	DEFINE  P_COD_RET2        VARCHAR(6);
	DEFINE  P_MENSAJE        VARCHAR(80);
	DEFINE  iValor           INTEGER;
	DEFINE  dFechaFin        DATE;	
	
	DEFINE  cRutaFinal       VARCHAR(90);
	DEFINE  vNombreArchivo   VARCHAR(23);
	DEFINE  vRutaInicio      VARCHAR(50);
	DEFINE 	vsSQL CHAR(120);
	
	 --SET DEBUG FILE TO "/informix/HomeInformix/rrm/tras.out";
	 --TRACE ON;

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
	  
	  EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora('49','Error en sp_tras_archivoshis_con ' || SQL_ERR || ' ' || P_MENSAJE,cNumEmpl) INTO P_COD_RET2;
	  
      RETURN P_COD_RET,P_MENSAJE;
   END EXCEPTION;

--************************************************************
-- Creado por Manuel Osuna Valencia 
-- fecha : 19/10/2011
-- Funcion: Traspaso de Archivos de Conciliacion a historico 
--************************************************************

   LET P_COD_RET = '00000';
   LET P_COD_RET2 = '00000';
   LET P_MENSAJE = 'PROCESO EXITOSO TRANSFERENCIA DE ARCHIVOS A HISTORICOS';
   LET iValor = 0;
   LET cRutaFinal = '';
   LET vNombreArchivo = '';
   LET vRutaInicio = '';
   LET vsSQL = "";
   
   	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
	--Dias	
	SELECT valor INTO iValor FROM bditarjeta:"informix".td_param_conciliacion_concreing WHERE codigo = '404';
	
	--Ruta
	SELECT valor INTO cRutaFinal FROM bditarjeta:"informix".td_param_conciliacion_concreing WHERE codigo = '401';
		
		
	IF (iValor == 0) THEN
	   LET P_COD_RET = '000-1';
	   LET P_MENSAJE = 'NO EXISTEN DIAS A SUBSTRAER.. ';	
	ELSE
		
		SELECT fecha_hoy - iValor units day INTO dFechaFin   FROM bdinteg:"informix".si_fechas;				
			
		FOREACH Copiado WITH HOLD FOR 
			SELECT nombrearchivo,rep_aix 
			INTO vNombreArchivo,vRutaInicio
			FROM bditarjeta:"informix".td_archivos_conciliacion co, bditarjeta:"informix".td_archivo_origen ori
			WHERE co.archivo_origen = ori.archivo_origen
			and co.fecha_archivo <= dFechaFin and co.traspaso_historico = 'F'
						 
			IF (vRutaInicio IS NOT NULL OR vRutaInicio <> '') THEN
			
				--   Copiando de ruta origen a ruta respaldo misma ruta para todos
				LET vsSQL = "";
				LET vsSQL  = 'cp' || ' ' || TRIM(vRutaInicio) || '/' || TRIM(vNombreArchivo) || ' ' || TRIM(cRutaFinal) || '/' || TRIM(vNombreArchivo);
				SYSTEM vsSQL;
				
				-- El archivo respaldado es comprimido 
				LET vsSQL = "";
				LET vsSQL  =  'gzip'|| ' ' || TRIM (crutafinal) || '/' || TRIM(vNombreArchivo);
				SYSTEM vsSQL;
				
				--   Borra el archivo origen de la ruta 
				LET vsSQL = "";
				LET vsSQL  = 'rm -f' || ' ' || TRIM(vRutaInicio) || '/' || TRIM(vNombreArchivo);
				SYSTEM vsSQL;
				
				--   Inicializa variable 
				LET vsSQL = "";
						
				UPDATE bditarjeta:"informix".td_archivos_conciliacion SET traspaso_historico = 'V' WHERE nombrearchivo =  vNombreArchivo;	
				
				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora('49','Exito en Traspaso de Archivo a Historico '||trim(vNombreArchivo) ,cNumEmpl) INTO P_COD_RET;		
							
			ELSE
				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora('49','Error: No Existe Ruta Inicial para el Archivo ' || trim(vNombreArchivo) ,cNumEmpl) INTO P_COD_RET;		
			END IF;
								
		END FOREACH;
		
		
	
	END IF;
	RETURN P_COD_RET,P_MENSAJE;
  
END;
END PROCEDURE
DOCUMENT
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICO LA LOGICA PARA REGISTRAR EN BITACORA TODOS LOS ARCHIVOS TRANSFERIDOS AL HISTORICO.',
'Fecha: 2012/08/23',
'Version: 20120823.1112',
'BD: BdiTarjeta',
'',
'Modificacion: Ricardo Reséndiz Martínez',
'Proyecto: Pase automatico a Historicos',
'Solicito: Luis Antonio Gomez',
'Descripción: Se modifica flujo al cual se le incluye proceso para la compactacion de los archivos',
'Fecha: 2012/01/23',
'Version: 20130123.1630',
'BD: Bditarjeta';

CREATE PROCEDURE "informix".sp_concreing_conciliaintercard_pba(
	psCve_usuario char (10), 		--USUARIO DEL SISTEMA
	psArchivo_origen CHAR (3), 		--TD_ARCHIVO_ORIGEN
	psConciliacionArchivo CHAR (1),	--TD_ARCHIVO_ORIGEN
	psConciliacion CHAR(1),   		-- bditarjeta:td_movimientos_conciliacion
	psConsecutivo INTEGER, 			--TD_MOVIMIENTOS_CONCILIACION	CONSECUTIVO
	psNumtarjeta CHAR (16), 		--TD_MOVIMIENTOS_CONCILIACION   NUMTARJETA
	psSecuencia325 CHAR(6),  		--TD_MOVIMIENTOS_CONCILIACION
	psMonto325 CHAR(13),
	psTipotransaccion325 CHAR(15),
	psIntegridad CHAR(1),         	--PARAMETRO INICIAL
	piTipo_LayOut INTEGER,			--BdiTarjeta:Td_Archivo_OrigenTmp ---
	psISO323 CHAR(2),				--BdiTarjeta:Td_Movimientos_Conciliacion
	psMovRev325 CHAR(1)				--BdiTarjeta:Td_Movimientos_Conciliacion
)

	RETURNING CHAR(5) AS Retorno,
				CHAR(1) AS Conciliacion ,
				CHAR(7) AS Secuencia,
				CHAR(15) AS Secuencia_extendida,
				MONEY AS Montointercard,
				DATETIME YEAR TO FRACTION(5) AS FechaTransaccion,
				CHAR(40) AS Infreceptor,
				CHAR(16) AS Idterminal,
				CHAR(2) AS Metodocaptura,
				CHAR(1) AS Movconciliado,
				CHAR(1) AS Movreversado,
				CHAR(1) AS Tipo_mov,
				CHAR(16) AS Folio_mov,
				DATETIME YEAR TO FRACTION(5) AS Fechaconcilia,
				INTEGER AS Tipo_conciliacion,
				CHAR(60) AS Desc_conciliacion,
				CHAR(250) AS ErrorActividad,
				INTEGER AS Elemento;

/*
*****************************************************************************************************
-- DESCRIPCION:  CONCILIACION INTERCARD  ------------------------------------------------------------
-- AUTOR : Ing. Alfonso Cruz  -----------------------------------------------------------------------
-- FECHA : 20/06/2011  ------------------------------------------------------------------------------
-- BD: bditarjeta  ----------------------------------------------------------------------------------
-- SISTEMA : Reingenieria de la conciliacion automatica / Validacion de Integridad  -----------------
*****************************************************************************************************
*/

/*DEFINICION DE VARIABLES*/

/*VARIABLES DE RETORNO*/
DEFINE viCodigo INTEGER;
DEFINE vssqlerr CHAR(5) ;

DEFINE vsErrorActividad CHAR (250) ;
DEFINE viElemento INTEGER;

/*VARIABLES QUE CONTIENEN AL MOVIMIENTO DE INTERCARD*/
DEFINE vsRetorno CHAR(5);
DEFINE viRetorno INTEGER;
DEFINE vsSecuenciaorig CHAR(7);
DEFINE vsSecuencia_extendida CHAR(15);
DEFINE vmMontointercard MONEY;
DEFINE vdFechatransaccion DATETIME YEAR TO FRACTION(5);
DEFINE vsInfreceptor CHAR(40);
DEFINE vsIdterminal CHAR(16);
DEFINE vsMetodocaptura CHAR(2);
DEFINE vsMovconciliado CHAR(1);
DEFINE vsMovreversado CHAR(1);
DEFINE vsCodigoiso CHAR(2);

DEFINE vmSumaMonto325 MONEY;
DEFINE vmMonto325 MONEY;

DEFINE vsConciliacion CHAR(1);
DEFINE vsSecuencia CHAR(7);

DEFINE vsTipo_mov CHAR(1);
DEFINE vsFolio_mov CHAR(16);
DEFINE vdFechaconcilia DATETIME YEAR TO FRACTION(5);
DEFINE viTipo_conciliacion INTEGER;
DEFINE vsDesc_conciliacion CHAR(60);

/*VARIABLES DE RETORNO DE sp_cidentifica_tipoconciliacion*/
DEFINE vsRetornor CHAR(5);
DEFINE vsConciliacionr CHAR(1);
DEFINE vsSecuencia_extendidar CHAR(16);
DEFINE vsMonto325 CHAR(13);
DEFINE vmMontointercardr MONEY;
DEFINE vdFechatransaccionr DATETIME YEAR TO FRACTION(5);
DEFINE vsInfreceptorr CHAR(40);
DEFINE vsIdterminalr CHAR(16);
DEFINE vsMetodocapturar CHAR(2);
DEFINE vsMovconciliador CHAR(1);
DEFINE vsMovreversador CHAR(1);
DEFINE vsFormato VARCHAR(4);

DEFINE vsNumCuenta CHAR(20);

DEFINE vsCodReversa CHAR(1); 	--Intercard:Movimiento
DEFINE vsCodigoCentral CHAR(5);	--Intercard:Movimiento

/*INICIALIZACION DE VARIABLES*/

LET viCodigo = 0;
LET vssqlerr = '00000';


LET vsErrorActividad = '';
LET viElemento = 4;

LET vsConciliacion = psConciliacion;

/*VARIABLES QUE CONTIENEN AL MOVIMIENTO DE INTERCARD*/
LET vsRetorno = '00000';
LET viRetorno = 0;
LET vsSecuenciaorig = '';
LET vsSecuencia_extendida = '';

LET vmMontointercard = 0;
LET vdFechatransaccion = CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5));
LET vsInfreceptor = '';
LET vsIdterminal = '';
LET vsMetodocaptura = '';
LET vsMovconciliado = '';
LET vsMovreversado = '';
LET vsCodigoiso = '';

LET vmSumaMonto325 = 0;

LET vsSecuencia = '';
LET vsTipo_mov = '';
LET vsFolio_mov = '';
LET vdFechaconcilia = CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5));
LET viTipo_conciliacion = 0;
LET vsDesc_conciliacion = '';

/*VARIABLES DE RETORNO DE sp_cidentifica_tipoconciliacion*/
LET vsRetornor = '00000';
LET vsConciliacionr = psConciliacion;
LET vsSecuencia_extendidar = '';
LET vmMontointercardr = 0;
LET vdFechatransaccionr = CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5));
LET vsInfreceptorr = '';
LET vsIdterminalr = '';
LET vsMetodocapturar = '';
LET vsMovconciliador = '';
LET vsMovreversador = '';
LET vsFormato = '';

LET vsNumCuenta  = '';

LET vsCodReversa = '';
LET vsCodigoCentral = '';

--LET vmMonto325 = 0;
LET vmMonto325 = ( ( REPLACE( psMonto325,'.',''))::MONEY /100 );
LET vsMonto325 = CAST(vmMonto325 AS CHAR(13));
LET vmSumaMonto325 = 0;
BEGIN

ON EXCEPTION SET viCodigo   --cacha el error en caso de que exista y regresa un valor predeterminado

LET vssqlerr = viCodigo;
RETURN	vssqlerr,
	NVL(vsConciliacion,''),
	NVL(vsSecuencia,''),
	NVL(vsSecuencia_extendida,''),
	NVL(vmMontointercard,0),
	NVL(vdFechaTransaccion,CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5))), 
	NVL(vsInfreceptor,''),
	NVL(vsIdterminal,''),
	NVL(vsMetodocaptura,''),
	NVL(vsMovconciliado,''),
	NVL(vsMovreversado,''),
	NVL(vsTipo_mov,''),
	NVL(vsFolio_mov,''),
	NVL(vdFechaconcilia,CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5))), 
	NVL(viTipo_conciliacion,0),
	NVL(vsDesc_conciliacion,''),
	NVL(vsErrorActividad,''),
	NVL(viElemento,4);

END EXCEPTION;

--SET DEBUG FILE TO '/home/sysifx/concreing/TraceCONCILIAINTERCARD.sql';
--SET DEBUG FILE TO '/tmp/concreing/TraceCONCILIAINTERCARD.txt';
--TRACE ON;

-----------------------------------------------------
--------REINGENIERIA-CONCILIACION-AUTOMATICA---------
--------2011/06/24-ING-ALFONSO-CRUZ------------------
-----------------------------------------------------

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ ;
	--OBTIENE NUMERO DE CUENTA DE LOS MOVIMIENTOS MEDIANTE LA TARJETA
	SELECT FIRST 1 NumCuenta
	INTO vsNumCuenta
	FROM Intercard:"informix".tarjetacuenta
	WHERE numtarjeta = psNumtarjeta;


	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ ;
	--ACTUALIZA EL NUMERO DE CUENTA DE LOS REGISTROS QUE NO LO TIENEN (POS)
	UPDATE BdiTarjeta:"informix".Td_Movimientos_Conciliacion
	SET NumCuenta = DECODE(NumCuenta, '', vsNumCuenta, NumCuenta)
	WHERE Consecutivo = psConsecutivo;


	/*SE VERIFICA LA INTEGRIDAD DEL REGISTRO*/
	IF ( psIntegridad = 'V') THEN
		/*CONTINUA FASE 2*/

		/*LECTURA DEL MOVIMIENTO ORIGINAL EN INTERCARD*/
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_buscarmovimientointercard( psCve_usuario, psNumtarjeta , psSecuencia325, psMonto325 ) -- Se agrega psmonto325 para validar montos
		INTO vsRetorno, vsSecuenciaorig, vsSecuencia_extendida, vmMontointercard, vdFechatransaccion,
			vsInfreceptor, vsIdterminal, vsMetodocaptura, vsMovconciliado, vsMovreversado, vsCodigoiso, vsFormato, vsErrorActividad,
			vsCodReversa, vsCodigoCentral;

		--LET vsErrorActividad = 'CONSULTA MOVIMIENTO INTERCARD' ;


		LET viRetorno = CAST( vsRetorno AS INTEGER);

		IF( viRetorno >= 0  ) THEN

			IF ( vmMonto325 < vmMontointercard) THEN
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ ;
				--SUMA EL MONTO DE LAS TRANSACCIONES FRACCIONADAS QUE YA FUERON APLICADAS
				SELECT SUM( ( ( REPLACE( monto325,'.',''))::MONEY/100 )) AS MONTO325
				INTO vmSumaMonto325
				FROM bditarjeta:"informix".td_movimientos_conciliacion
				WHERE numtarjeta = psNumtarjeta 
				AND secuencia325 = psSecuencia325
				AND Aplicacion = 'V'
				AND Finalizado = 'V';
				
				--AGREGA EL MONTO DE LA OPERACION ACTUAL PARA EFECTOS DE CALCULO
				LET vmSumaMonto325 = vmSumaMonto325 + vmMonto325;
				
			END IF;
			
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ ;
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_identificatipoconciliacion
			(
				vsRetorno,	--intercard:movimiento
				psConsecutivo,  --bditarjeta:td_movimientos_conciliacion
				psNumtarjeta,			--bditarjeta:td_movimientos_conciliacion
				psSecuencia325,			--bditarjeta:td_movimientos_conciliacion
				vsMovconciliado,		--intercard:movimiento
				vmMontointercard,	--intercard:movimiento
				vsMonto325,			--bditarjeta:td_movimientos_conciliacion
				--psSumaMonto325,		--bditarjeta:td_movimientos_conciliacion  Suma de monto325
				vmSumaMonto325,		--bditarjeta:td_movimientos_conciliacion  Suma de monto325
				psTipotransaccion325,  --bditarjeta:td_movimientos_conciliacion
				psConciliacionArchivo,	--bditarjeta:td_archivo_origen

				psConciliacion,   		-- bditarjeta:td_movimientos_conciliacion
				vsSecuenciaorig,		--intercard:movimiento
				vsSecuencia_extendida,	--intercard:movimiento
				vdFechatransaccion, 	--intercard:movimiento
				vsInfreceptor,			--intercard:movimiento
				vsIdterminal,			--intercard:movimiento
				vsMetodocaptura,		--intercard:movimiento
				vsMovreversado,			--intercard:movimiento
				vsCodigoiso,			--intercard:movimiento
				vsFormato,				--intercard:movimiento
				
				piTipo_LayOut,			--BdiTarjeta:Td_Archivo_OrigenTmp ---
				psISO323,				--BdiTarjeta:Td_Movimientos_Conciliacion
				psMovRev325,			--BdiTarjeta:Td_Movimientos_Conciliacion
				vsCodReversa, 			--Intercard:Movimiento
				vsCodigoCentral			--Intercard:Movimiento
			)
			INTO
				vsRetornor,              --
				vsConciliacion,
				vsSecuencia,
				vsSecuencia_extendidar,  --
				vmMontointercardr,       --
				vdFechatransaccionr,     --
				vsInfreceptorr,          --
				vsIdterminalr,           --
				vsMetodocapturar,        --
				vsMovconciliador,        --
				vsMovreversador,         --
				vsTipo_mov,
				vsFolio_mov,
				vdFechaconcilia,
				viTipo_conciliacion,
				vsDesc_conciliacion,
				vsErrorActividad;

			LET vssqlerr = vsRetornor;
			LET viRetorno = CAST( vsRetornor AS INTEGER );

			IF ( viRetorno < 0  ) THEN
				LET vsErrorActividad = 'CONSECUTIVO ' || psConsecutivo || ' OCURRIO UN ERROR NO CONTROLADO AL EJECUTAR sp_concreing_identificatipoconciliacion' ;
			ELIF ( viRetorno >= 0  ) THEN
				
				LET vsSecuencia_extendida = vsSecuencia_extendidar;
				LET vmMontointercard = vmMontointercardr;
				LET vdFechatransaccion = vdFechatransaccionr;
				LET vsInfreceptor = vsInfreceptorr;
				LET vsIdterminal = vsIdterminalr;
				LET vsMetodocaptura = vsMetodocapturar;
				LET vsMovconciliado = vsMovconciliador;
				LET vsMovreversado = vsMovconciliador;
				
			END IF;
		ELSE

			LET vsErrorActividad = 'CONSECUTIVO ' || psConsecutivo || ' OCURRIO UN ERROR NO CONTROLADO AL EJECUTAR sp_concreing_buscarmovimientointercard';

		END IF;

	ELIF ( psIntegridad IN ('F','P')) THEN
		/*CONCLUYE LA ETAPA DE CONCILIACION DEL REGISTRO*/

		/*SE DEBE MANTENER P EN CONCILIACION */
		LET vsConciliacion = 'P';
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;
		
		UPDATE bditarjeta:"informix".td_movimientos_conciliacion
		SET conciliacion = 'P'
		WHERE numtarjeta = psNumtarjeta AND secuencia325 = psSecuencia325 AND consecutivo = psConsecutivo;

		LET vssqlerr = '00402';

		LET vsErrorActividad = 'CONSECUTIVO ' || psConsecutivo || ' EL REGISTRO NO PRESENTA INTEGRIDAD CORRECTA';

	END IF;



	/*RETORNO DEL PROCEDIMIENTO ALMACENADO*/
	RETURN	vssqlerr,
		NVL(vsConciliacion,''),
		NVL(vsSecuencia,''),
		NVL(vsSecuencia_extendida,''),
		NVL(vmMontointercard,0),
		NVL(vdFechaTransaccion,CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5))), 
		NVL(vsInfreceptor,''),
		NVL(vsIdterminal,''),
		NVL(vsMetodocaptura,''),
		NVL(vsMovconciliado,''),
		NVL(vsMovreversado,''),
		NVL(vsTipo_mov,''),
		NVL(vsFolio_mov,''),
		NVL(vdFechaconcilia,CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5))), 
		NVL(viTipo_conciliacion,0),
		NVL(vsDesc_conciliacion,''),
		NVL(vsErrorActividad,''),
		NVL(viElemento,4);


END;
END PROCEDURE
DOCUMENT
'AUTOR: Ing. Alfonso Cruz',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: Conciliacion intercard.',
'Fecha: 2011/06/20',
'Version: 20110620.0901',
'BD: bditarjeta',
'AUTOR: Ing. Alfonso Cruz',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: Se agregó consulta para actualizar el campo numtarjeta de td_movimientos_conciliacion .',
'Fecha: 2011/10/05',
'Version: 20111005.1101',
'BD: bditarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AJUSTA LA CONSULTA PARA OBTENER EL NUMERO DE CUENTA PARA LAS TRANSACCIONES POS.',
'Fecha: 2011/10/17',
'Version: 20111017.1048',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion -DEVOLUCIONES',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AJUSTA EL CODIGO PARA MANEJAR EL NUEVO CAMPO DE FORMATO PARA LA CLASIFICACION DE DEVOLUCIONES.',
'Fecha: 2012/05/21',
'Version: 20120521.1239',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion ',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AJUSTA EL CODIGO PARA CONTEMPLAR LOS CAMPOS CodReversa Y CodigoCentral ASI COMO LOS PARAMETROS piTipo_LayOut, psISO323 Y psMovRev325 PARA LAS CONCILIACION DE ATM.',
'Fecha: 2012/07/27',
'Version: 20120727.1437',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AJUSTA LA LOGICA PARA ELIMINAR LA CLASIFICACION DE LOS ARCHIVOS PNC DEL PROCESO PUESTO QUE NO REQUIEREN CLASIFICACION.',
'Fecha: 2012/08/10',
'Version: 20120810.1039',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AJUSTA LA LOGICA PARA CALCULAR CORRECTAMENTE EL MONTO DE LAS OPERACIONES FRACCIONADAS.',
'Fecha: 2012/08/10',
'Version: 20120810.1145',
'BD: BdiTarjeta',
'',
'MODIFICACION: Ricardo Reséndiz Martinez',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Luis Antonio Gomez',
'Descripcion: Se modificación llamado a sp_concreing_buscarmovimientointercard, por cambio de entrada de integro psmonto325',
'Fecha: 2013/05/30',
'Version: 20130530.1400',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_concreing_identificatipoconciliacion_pba(
	psOriginalEncontrado CHAR(5),	--intercard:movimiento
	psConsecutivo INTEGER,
	psNumtarjeta CHAR(16),			--bditarjeta:td_movimientos_conciliacion
	psSecuencia325 CHAR(6),			--bditarjeta:td_movimientos_conciliacion
	psMovconciliado CHAR(1),		--intercard:movimiento
	pmMontointercard MONEY,			--intercard:movimiento
	psMonto325 CHAR(13),			--bditarjeta:td_movimientos_conciliacion
	pmSumaMonto325 MONEY,			--bditarjeta:td_movimientos_conciliacion  Suma de monto325
	psTipotransaccion325 CHAR(15),  --bditarjeta:td_movimientos_conciliacion
	psConciliacionArchivo CHAR(1),	--bditarjeta:td_archivo_origen
	psConciliacion CHAR(1),   		-- bditarjeta:td_movimientos_conciliacion
	psSecuenciaorig CHAR(7),		--intercard:movimiento
	psSecuencia_extendida CHAR(15),	--intercard:movimiento
	pdFechatransaccion DATETIME YEAR TO FRACTION(5), 	--intercard:movimiento
	psInfreceptor CHAR(40),			--intercard:movimiento
	psIdterminal CHAR(16),			--intercard:movimiento
	psMetodocaptura CHAR(2),		--intercard:movimiento
	psMovreversado CHAR(1),			--intercard:movimiento
	psCodigoiso CHAR(2),			--intercard:movimiento
	psFormato CHAR(4),				--intercard:movimiento	
	piTipo_LayOut INTEGER,			--BdiTarjeta:Td_Archivo_OrigenTmp ---
	psISO323 CHAR(2),				--BdiTarjeta:Td_Movimientos_Conciliacion
	psMovRev325 CHAR(1),			--BdiTarjeta:Td_Movimientos_Conciliacion
	psCodReversa CHAR(1),			--Intercard:Movimiento
	psCodigoCentral CHAR(5)			--Intercard:Movimiento
	
)

	RETURNING CHAR(5) AS Retorno,
	CHAR(1) AS Conciliacion ,
	CHAR(7) AS Secuencia,
	CHAR(15) AS Secuencia_extendida,
	MONEY AS Montointercard,
	DATETIME YEAR TO FRACTION(5) AS FechaTransaccion,
	CHAR(40) AS Infreceptor,
	CHAR(16) AS Idterminal,
	CHAR(2) AS Metodocaptura,
	CHAR(1) AS Movconciliado,
	CHAR(1) AS Movreversado,
	CHAR(1) AS Tipo_mov ,
	CHAR(16) AS Folio_mov,
	DATETIME YEAR TO FRACTION(5) AS Fechaconcilia,
	INTEGER AS Tipo_conciliacion,
	CHAR(60) AS Desc_conciliacion,
	CHAR(250) AS ErrorActividad;

	/*
	*****************************************************************************************************
	-----------------------------------------------------------------------------------------------------
	-- DESCRIPCION:  IDENTIFICA EL TIPO DE CONCILIACION  ------------------------------------------------
	-- AUTOR : Ing. Alfonso Cruz  -----------------------------------------------------------------------
	-- FECHA : 20/06/2011  ------------------------------------------------------------------------------
	-- BD: bditarjeta  ----------------------------------------------------------------------------------
	-- SISTEMA : Reingenieria de la conciliacion automatica / Validacion de Integridad  -----------------
	-- MODIFICADO: CASANOVA EDEZA HECTOR JUAN. 19/04/2012 	SE MODIFICA LA LOGICA PARA LA CLASIFICACION DE LAS TRANSACCIONES DE DEVOLUCIONES (21) PARA LOS TIPOS DE CONCILIACION 10,11 Y 12. SE AGREGA EL TIPO CONCILIACION 14.
	-- MODIFICADO: CASANOVA EDEZA HECTOR JUAN. 25/06/2012 	SE HACE NUEVAMENTE EL SP, OPTIMIZANDO EL PROCESO EN CUANTO A FUNCIONAMIENTO Y CLARIDAD DEL CODIGO
	-- MODIFICADO: CASANOVA EDEZA HECTOR JUAN. 01/10/2012   SE AJUSTA LA LOGICA PARA CLASIFICAR LAS TRANSACCIONES TIPO 20 EN LOS ARCHIVOS VIC(MONEYGRAM)
	-----------------------------------------------------------------------------------------------------
	*****************************************************************************************************
	*/

	/*DEFINICION DE VARIABLES*/

	/*VARIABLES DE ERRORES*/
	DEFINE visqlerr INTEGER ;
	DEFINE vssqlerr CHAR(5);
	DEFINE vsErrorActividad CHAR(250);
	DEFINE vsCodRetFecha CHAR(5);
	DEFINE vsFechaHora CHAR(8);
	DEFINE vmMonto325 MONEY;

	/*VARIABLES DE RETORNO*/
	DEFINE vsConciliacion CHAR(1);
	DEFINE vdFechaTransaccion DATETIME YEAR TO FRACTION (5);
	DEFINE vsMovconciliado CHAR(1);
	DEFINE vsTipo_mov CHAR(1);
	DEFINE vsFolio_mov CHAR(16);
	DEFINE vdFechaconcilia DATETIME YEAR TO FRACTION (5);
	DEFINE viTipo_Conciliacion INTEGER;
	DEFINE vsDesc_conciliacion CHAR(60);
	
	/*VARIABLES DE ENTORNO*/
	DEFINE StatusTarjeta VARCHAR (3);
	DEFINE numcredito VARCHAR(13);
	DEFINE statuscred CHAR(2);
	
	

	/*INICIALIZACION DE VARIABLES*/
	LET visqlerr = 0;
	LET vssqlerr = '00000' ;
	LET vsErrorActividad = '';
	LET vsCodRetFecha='';
	LET vsFechaHora = '';

	/*VARIABLES DE RETORNO*/
	LET vsConciliacion = 'V';  -- PARA TODOS
	LET psSecuenciaorig = NVL(psSecuenciaorig,'');
	LET psSecuencia_extendida = NVL(psSecuencia_extendida,'');
	LET vmMonto325 = ( ( REPLACE( psMonto325,'.',''))::MONEY /100 );
	LET pmMontointercard = NVL(pmMontointercard,'');
	LET vdFechaTransaccion = NVL(pdFechatransaccion,  CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5)));
	LET psInfreceptor = NVL(psInfreceptor,'');
	LET psIdterminal = NVL(psIdterminal,'');
	LET psMetodocaptura = NVL(psMetodocaptura,'');
	LET vsMovconciliado = NVL(psMovconciliado,'');
	LET psMovreversado = NVL(psMovreversado,'');
	LET vsTipo_mov = '';
	LET vsFolio_mov = '';
	LET vdFechaconcilia = CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5));
	LET viTipo_Conciliacion = 0;
	LET vsDesc_conciliacion = '';
	LET psTipotransaccion325 = TRIM(NVL(psTipotransaccion325,''));

	/*VARIABLES DE ENTORNO*/
	LET StatusTarjeta = '';
	LET numcredito = '';
	LET statuscred = '';

	BEGIN

		ON EXCEPTION SET visqlerr   --CACHA EL ERROR EN CASO DE QUE EXISTA Y REGRESA UN VALOR PREDETERMINADO

				LET vssqlerr = visqlerr;
				RETURN vssqlerr,
					NVL(vsConciliacion,''),
					NVL(psSecuenciaorig,''),
					NVL(psSecuencia_extendida,''),
					NVL(pmMontointercard,0),
					NVL(vdFechaTransaccion,CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5))), 
					NVL(psInfreceptor,''),
					NVL(psIdterminal,''),
					NVL(psMetodocaptura,''),
					NVL(vsMovconciliado,''),
					NVL(psMovreversado,''),
					NVL(vsTipo_mov,''),
					NVL(vsFolio_mov,''),
					NVL(vdFechaconcilia,CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5))), 
					NVL(viTipo_Conciliacion,0),
					NVL(vsDesc_conciliacion,''),
					NVL(vsErrorActividad,'');

		END EXCEPTION;

		--SET DEBUG FILE TO '/informix/HomeInformix/rrm/TraceIDENTIFICATIPO.out';
		--TRACE ON;

		--------REINGENIERIA-CONCILIACION-AUTOMATICA---------
		--------2012/06/25-MGTI-HECTOR CASANOVA------------------


		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;

		LET vsConciliacion = 'V'; --TODOS V 
		LET vdFechaconcilia = (SELECT DBINFO('utc_to_datetime', Sh_Curtime)::DATETIME YEAR TO FRACTION(5) FROM SysMaster:"informix".Sysshmvals); --SE REQUIERE SOLO UNA VEZ POR EJECUCION
		LET viTipo_Conciliacion = -2; --DEFAULT
	
		
		--IDENTIFICA TIPO DE LAYOUT PARA REALIZAR VALIDACIONES DE MOVIMIENTOS (POS O ATM)
		IF (piTipo_LayOut = 1) THEN --POS POS325 (EGLOABL, COPPEL)
			
			-- Para agregar validacion de estatus de credito
			IF (SUBSTR (psNumtarjeta, 1, 6 ) = '426807') then 
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ ;
				SELECT FIRST 1 numcuenta INTO numcredito 
					FROM Intercard:Tarjetacuenta 
				WHERE NumTarjeta = psNumtarjeta; 
				
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ ;
				SELECT FIRST 1 status_cred into statuscred
					FROM Bdicred:sd_maecred
				where 	empresa = '001' and 
						num_credito  = numcredito and
						status_cred =  'CV';
			END IF;
			
			
			IF ( psConciliacionArchivo = 'F' ) THEN
				/* TIPO DE CONCILIACION = 0 */ --NO REQUIERE CONCILIACIÓN INTERCARD
				LET viTipo_Conciliacion = -1; -- ES TIPO 0, PARA FINES PRACTICOS, INTERNAMENTE ES -1, EN LA TABLA QUEDA COMO 0
	
			ELIF ( statuscred = 'CV' ) THEN 
				/* TIPO DE CONCILIACION = 16  */-- No se conciliacia por ser credito vendido
				LET viTipo_Conciliacion = 16;
			
			ELIF (( psOriginalEncontrado = '00000' ) AND ( LPAD(psCodigoiso,2,'0') != '00' )) THEN
				/* TIPO DE CONCILIACION = 9 */ --MOVIMIENTO ORIGINAL RECHAZADO
				LET viTipo_Conciliacion = 9; 

			ELIF ((psOriginalEncontrado = '00400') AND ( psTipotransaccion325 = '20' ) ) THEN --ORIGINAL NO ENCONTRADO + ABONO DE MONEYGRAM (SOLO VID)
				/* TIPO DE CONCILIACION = 0 */ --NO REQUIERE CONCILIACIÓN INTERCARD  ABONO DE MONEYGRAM (SOLO VID)
				LET viTipo_Conciliacion = 0;
			
			ELIF ( ( psOriginalEncontrado = '00400' )  AND ( psTipotransaccion325 IN ( '01','02' ) ) ) THEN  /*MOVIMIENTO NO ENCONTRADO EN INTERCARD CON LA TARJETA Y SECUENCIA DEL REGISTRO 325*/
				/* TIPO DE CONCILIACION = 8 */ --FORZADO (SIN MOVIMIENTO EN INTERCARD)
				LET viTipo_Conciliacion = 8; 
				
			ELIF ((psTipotransaccion325 = '21' ) 
				AND ((psOriginalEncontrado = '00400')  --ORIGINAL NO ENCONTRADO
				OR (TRIM(psSecuencia325) IN ('','000000','111111','222222','333333','444444','555555','666666','777777','888888','999999')))  -- RECHAZADO POR NUMERO REPETIDOS O EN BLANCO
			) THEN
				/* TIPO DE CONCILIACION = 12 */	--DEVOLUCIÓN NO APLICADA
				LET viTipo_Conciliacion = 12; 

			ELIF ( ( psMovreversado = 'V' ) AND ( NVL (psFormato,'') = '0220' ) AND ( psTipotransaccion325 IN ( '01', '02' ) ) ) THEN
				/* TIPO DE CONCILIACION = 13 */ --FORZADO INTERCARD
				LET viTipo_Conciliacion = 13; 
				LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				
			ELIF ( ( psMovreversado = 'V' ) AND ( NVL (psFormato,'') = '0420' )	AND ( psTipotransaccion325 IN ( '01','02' ) ) ) THEN
				/* TIPO DE CONCILIACION = 7 */ --MOVIMIENTO ORIGINAL REVERSADO
				LET viTipo_Conciliacion = 7; 
				LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				
			ELIF ( ( psMovconciliado = 'V')  AND ( psTipotransaccion325 IN ( '01','02')  OR 
				psTipotransaccion325 MATCHES('RETIRO*') OR  psTipotransaccion325 MATCHES('CONSULTA*') OR psTipotransaccion325 MATCHES('CAMB_NIP*') ) ) THEN
				/* TIPO DE CONCILIACION = 6 */ --MOVIMIENTO PREVIAMENTE CONCILIADO
				LET viTipo_Conciliacion = 6; 
				LET vsMovconciliado = psMovconciliado; 
				
			ELIF (( ( psMovconciliado = 'F') AND ( pmMontointercard = vmMonto325 ) AND ( psTipotransaccion325 IN ('01','02')))
			OR (psTipotransaccion325 MATCHES('RETIRO*') OR  psTipotransaccion325 MATCHES('CONSULTA*') OR psTipotransaccion325 MATCHES('CAMB_NIP*')) ) THEN
				/* TIPO DE CONCILIACION = 1 */ --CONCILIACIÓN INTERCARD
				LET viTipo_Conciliacion = 1; 
				LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				
			ELIF ( ( psMovconciliado = 'P' ) AND ( vmMonto325 < pmMontointercard ) AND ( pmSumaMonto325 < pmMontointercard )
				AND ( psTipotransaccion325 IN ( '01','02' ) ) ) THEN  
				/* TIPO DE CONCILIACION = 3 */ --CONCILIADO CON MONTO MENOR    --PARCIALES INCOMPLETOS
				LET viTipo_Conciliacion = 3; 
				LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				
			ELIF ( ( psMovconciliado = 'P' ) AND ( vmMonto325 < pmMontointercard ) AND ( pmSumaMonto325 >= pmMontointercard ) AND ( psTipotransaccion325 IN ( '01','02') ) ) THEN
				/* TIPO DE CONCILIACION = 4 */ --CONCILIADO CON MONTO MENOR    --PARCIALES COMPLETOS
				LET viTipo_Conciliacion = 4; 
				LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				
			ELIF ( ( psMovconciliado = 'F') AND ( vmMonto325 < pmMontointercard )  AND ( psTipotransaccion325 IN ( '01','02' ) ) ) THEN
				/* TIPO DE CONCILIACION = 2 */ --CONCILIADO CON MONTO MENOR
				LET viTipo_Conciliacion = 2; 
				LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				
			ELIF ( ( psMovconciliado = 'F') AND ( vmMonto325 > pmMontointercard ) AND ( psTipotransaccion325 IN ( '01','02' ) ) ) THEN
				/* TIPO DE CONCILIACION = 5 */ --CONCILIADO CON MONTO MAYOR
				LET viTipo_Conciliacion = 5; 
				LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				
			ELIF ( ((psOriginalEncontrado = '00000') AND ( psTipotransaccion325 = '21' ) AND (psMovconciliado <> 'V')) --MOVIMIENTO NO CONCILIADO
					OR ((psOriginalEncontrado = '00000') AND (vmMonto325 > pmMontointercard)) -- DEVOLUCION CON MONTO MAYOR AL ORIGINAL
			) THEN
				/* TIPO DE CONCILIACION = 10 */ --DEVOLUCIÓN CONCILIADA INTERCARD
				LET viTipo_Conciliacion = 10; 
				LET vsMovconciliado = psMovconciliado; 

			ELIF (( psOriginalEncontrado = '00000' ) AND ( psTipotransaccion325 = '21' ) AND (vmMonto325 < pmMontointercard) ) THEN -- DEVOLUCION CON MONTO MENOR AL ORIGINAL
				/* TIPO DE CONCILIACION = 11 */ --DEVOLUCIÓN FORZADA -- MONTO MENOR
				LET viTipo_Conciliacion = 11; 
				
			ELIF (( psOriginalEncontrado = '00000' ) AND ( psTipotransaccion325 = '21' ) AND (vmMonto325 = pmMontointercard) AND (psMovconciliado = 'V') ) THEN -- DEVOLUCION CON MONTO IGUAL AL ORIGINAL
				/* TIPO DE CONCILIACION = 14 */ --DEVOLUCIÓN APLICADA
				LET viTipo_Conciliacion = 14; 

			ELSE -- ERROR
				--MOV NO CONCUERDA CON NINGUN TIPO
				LET viTipo_Conciliacion = 0; 
				
			END IF;
			
		ELIF (piTipo_LayOut IN (2,3)) THEN --ATM  STAT07 (2- EGLOBAL, 3-PROSA)
			
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ ;
			--OBTIENE EL ESTATUS DE LA TARJETA
			SELECT FIRST 1 CodStatusTarjeta INTO StatusTarjeta FROM Intercard:Tarjeta WHERE NumTarjeta = psNumtarjeta; 
			
			IF (psOriginalEncontrado <> '00000') THEN -- 
				/* TIPO DE CONCILIACION = 52 */ --ATM NO ENCONTRADO EN INTERCARD
				LET viTipo_Conciliacion = 52; 
				
			ELIF (StatusTarjeta IN ('BLO', 'CAN', 'DES', 'EXT', 'INA', 'ROB') ) THEN --
				/* TIPO DE CONCILIACION = 53 */ --ATM NO CONCILIADA POR IMPROCEDENTE (ESTATUS DE TARJETA)
				--NO CONCILIADA POR BLOQUEO O CANCELACION
				LET viTipo_Conciliacion = 53; 
				
			ELIF (psMovconciliado = 'V') THEN --
				/* TIPO DE CONCILIACION = 54 */ --ATM CONCILIACION CORRECTA (MOVIMINETO PREVIAMENTE CONCILIADO)
				LET viTipo_Conciliacion = 54; 
				
			ELIF (psMovRev325 = 'T') THEN --
				/* TIPO DE CONCILIACION = 55 */ --ATM REVERSA TOTAL
				LET viTipo_Conciliacion = 55; 
				LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				
			ELIF (psMovRev325 = 'P') THEN --
				/* TIPO DE CONCILIACION = 56 */ --ATM REVERSA PARCIAL
				LET viTipo_Conciliacion = 56; 
				LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				
			ELIF ((psISO323 = psCodigoiso) AND (psISO323 <> '00') AND (psCodigoCentral <> '00000')) THEN --
				--CONCILIADA CORRECTA RECHAZADA POR AMBOS
				--CONCILIADA CORRECTA (CONSULTA RECHAZADA)
				--CONCILIADA CORRECTA (CAMBIO DE NIP FALLIDO)
				/* TIPO DE CONCILIACION = 57 */ --ATM CONCILIADA CORRECTA (RECHAZADA POR AMBOS)
				LET viTipo_Conciliacion = 57; 
				
			ELIF ((psISO323 <> '00') OR (psCodigoiso <> '00') OR (psCodigoCentral <> '00000')) THEN --
				--SE PUEDE UNIR CON LA VALIDACION ANTERIOR ATRAPARIA TODAS LAS OERACIONES CON ISO Y/O ISO 325 DIFERENTE DE 00
				--NO CONCILIADA POR IMPROCEDENTE
				--NO CONCILIADA POR IMPROCEDENTE (PROSA SI INTERCARD NO)
				--CONCILIADA CORRECTA (CONSULTA RECHAZADA)
				--CONCILIADA CORRECTA (CAMBIO DE NIP FALLIDO)
				/* TIPO DE CONCILIACION = 58 */ --ATM NO CONCILIADA POR IMPROCEDENTE
				LET viTipo_Conciliacion = 58; 
				
			ELIF (psMovreversado = 'V') THEN--
				--MOVIMIENTO ATM ORIGINAL REVERSADO
				/* TIPO DE CONCILIACION = 59 */ --ATM MOVIMIENTO ORIGINAL REVERSADO
				LET viTipo_Conciliacion = 59; 
				
			ELIF ((psTipotransaccion325 MATCHES('CONSULTA*')) AND (psCodigoiso = '00')) THEN --
				--CONCILIADA CORRECTA (CONSULTA APROBADA)
				/* TIPO DE CONCILIACION = 60 */ --ATM CONCILIADA CORRECTA (CONSULTA APROBADA)
				LET viTipo_Conciliacion = 60; 
				LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				
			ELIF ((psTipotransaccion325 MATCHES('CAMBIO*')) AND (psCodigoiso = '00')) THEN --
				--CONCILIADA CORRECTA (CAMBIO DE NIP EXITOSO)
				/* TIPO DE CONCILIACION = 62 */ --ATM CONCILIADA CORRECTA (CAMBIO DE NIP EXITOSO)
				LET viTipo_Conciliacion = 61; 
				LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				
			ELIF ((psTipotransaccion325 MATCHES('RETIRO*')) AND (vmMonto325 <> pmMontointercard)) THEN -- 
				--CONCILIADA CON DIFERENCIA DE MONTOS
				/* TIPO DE CONCILIACION = 51 */ --ATM CONCILIADA CON DIFERENCIA DE MONTOS
				LET viTipo_Conciliacion = 51; 
				LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				
			ELIF ((psTipotransaccion325 MATCHES('RETIRO*')) AND (vmMonto325 = pmMontointercard)) THEN --
				--CONCILIADA CORRECTA (MONTOS IGUALES)
				/* TIPO DE CONCILIACION = 50 */ --ATM CONCILIADA CORRECTA (MONTOS IGUALES)
				LET viTipo_Conciliacion = 50; 
				LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				
			ELSE --ERROR
				--MOV NO CONCUERDA CON NINGUN TIPO
				LET viTipo_Conciliacion = 0; 
				
			END IF;
			
		END IF;
		
		
		--MENSAJE DE RASTREO
		LET vsErrorActividad  = 'CONSECUTIVO ' || psConsecutivo || ' SE DETECTO EL TIPO CONCILIACION ' || DECODE (viTipo_Conciliacion, -1, 0, viTipo_Conciliacion);
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		--OBTIENE LA DESCRIPCION DEL TIPO DE CONCILIACION 
		SELECT FIRST 1 Desc_Conciliacion INTO vsDesc_Conciliacion FROM BdiTarjeta:"informix".td_Tipo_Conciliacion WHERE Tipo_Conciliacion = viTipo_Conciliacion;

		
		IF (viTipo_Conciliacion IN (8, 11, 12, 14)) THEN --TIPOS DE CONCILIACION QUE RECALCULAN EL FOLIO_MOV
			
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			--OBTIENE LA FECHA EN FORMATO ESPECIAL
			EXECUTE PROCEDURE BdiTarjeta:"informix".sp_Concreing_ObtenerFechauHora('15','')	INTO vsCodRetFecha, vsFechaHora;

			IF (vsCodRetFecha = '00000') THEN

				LET vsFolio_mov = 'i' || TRIM(vsFechaHora) || '2' || psSecuencia325;
			ELSE
				/*ERROR AL OBTENER LA FECHA U HORA*/
				LET vssqlerr = '00451';
				LET vsErrorActividad  = 'CONSECUTIVO ' || psConsecutivo || ' ERROR AL OBTENER LA FECHA PROCESO IDENTIFICARTIPOCONCILIACION';
			END IF;
			
		ELSE -- FOLIO_MOV ORIGINAL DE INTERCARD
			-- -1,0,1,2,3,4,5,7,,9,10,13
			LET vsFolio_mov = 'i' || psSecuencia_extendida; 
		END IF;
	

		IF ((viTipo_Conciliacion IN (1,2,3,4,5,7,13)) --POS
			OR ((viTipo_Conciliacion IN (50,51,55,56,57,60,61))) --ATM
		) THEN --TIPOS DE CONCILIACION QUE ACTUALIZAN EN REGISTRO ORIGINAL DE INTERCARD
		
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			--ACTUALIZA EL MOVIMIENTO DE INTERCARD 
			UPDATE Intercard:"informix".Movimiento
			SET MovConciliado = (CASE 
				WHEN (viTipo_Conciliacion IN (2,3)) THEN 'P' --COMPRAS FRACCIONADAS QUEDAN PENDIENTES[P]
				WHEN (viTipo_Conciliacion IN (1,4,5,7,13)) THEN 'V' -- COMPRAS NORMALES CONCILIADO [V]
				WHEN (viTipo_Conciliacion IN (50,51,55,56,57,60,61)) THEN 'V' -- ATM CONCILIADO [V]
				ELSE MovConciliado END) --DEFAULT
			WHERE NumTarjeta = psNumtarjeta AND secuencia= "1" || psSecuencia325;

		END IF;
		
		IF 	(psTipotransaccion325 IN ('20','21')) THEN  --TRANSACCIONES DE ABONO
			LET vsTipo_mov = 'A'; -- ABONOS [A]
			--ACTUALIZACION PARA TIPOS 0, 10, 11, 12 Y 14
			UPDATE BdiTarjeta:"informix".td_Movimientos_Conciliacion  --12
			SET Tipo_Conciliacion = viTipo_Conciliacion, 
			Desc_Conciliacion = vsDesc_conciliacion, 
			Conciliacion = vsConciliacion, --BANDERA DE QUE FUE TRABAJADO
			FechaConcilia = vdFechaconcilia,
			Folio_Mov = DECODE (psTipotransaccion325, '20', Folio_Mov, vsFolio_mov), --psTipotransaccion325 20 (PNC) NO REQUIEREN ESTE CAMPO.
			Tipo_Mov = vsTipo_mov -- ABONOS [A]
			WHERE NumTarjeta = psNumtarjeta AND Secuencia325 = psSecuencia325 AND Consecutivo = psConsecutivo;
		
		ELSE --TRANSACCIONES DE COMPRA
		
			--ATM ????
			LET vsTipo_mov = 'C'; -- CARGOS [C]
			
			--ACTUALIZACION PARA TIPOS -1, 2, 3, 4, 5, 6, 7, 8, 9 Y 13 [POS]
			--ACTUALIZACION PARA TIPOS -50, 51, 52, 53, 54, 55, 56, 57, 59, 60, 61 [ATM]
			UPDATE BdiTarjeta:"informix".td_Movimientos_Conciliacion
			SET Tipo_Conciliacion = DECODE (viTipo_Conciliacion, -1, 0, viTipo_Conciliacion), --REEMPLAZA EL TIPO -1 POR UN 0 Y DEJA LOS DEMAS TIPOS IGUAL
			Desc_Conciliacion = vsDesc_conciliacion, 
			Conciliacion = vsConciliacion, --BANDERA DE QUE FUE TRABAJADO
			FechaConcilia = vdFechaconcilia,
			Folio_Mov = vsFolio_mov, 
			Tipo_Mov = vsTipo_mov,  -- CARGOS [C]
			Secuencia = psSecuenciaorig, 
			Secuencia_extendida = psSecuencia_extendida, 
			MontoIntercard = pmMontointercard,
			FechaTransaccion = pdFechatransaccion, 
			InfReceptor = psInfreceptor, 
			IdTerminal = psIdterminal,
			MetodoCaptura = psMetodocaptura, 
			MovConciliado = vsMovconciliado, --- puede cambiar ok
			MovReversado = psMovreversado 
			WHERE NumTarjeta = psNumtarjeta AND Secuencia325 = psSecuencia325 AND Consecutivo = psConsecutivo;
			
		END IF;


			/*RETORNO DEL PROCEDIMIENTO ALMACENADO*/
		RETURN vssqlerr,
			NVL(vsConciliacion,''),
			NVL(psSecuenciaorig,''),
			NVL(psSecuencia_extendida,''),
			NVL(pmMontointercard,0),
			NVL(vdFechaTransaccion,CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5))), 
			NVL(psInfreceptor,''),
			NVL(psIdterminal,''),
			NVL(psMetodocaptura,''),
			NVL(vsMovconciliado,''),
			NVL(psMovreversado,''),
			NVL(vsTipo_mov,''),
			NVL(vsFolio_mov,''),
			NVL(vdFechaconcilia,CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5))), 
			NVL(viTipo_Conciliacion,0),
			DECODE (vssqlerr, '00000', '', NVL(vsDesc_conciliacion,'')),
			NVL(vsErrorActividad,'');
			
	END

END PROCEDURE
DOCUMENT
'AUTOR: Ing. Alfonso Cruz',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: IDENTIFICA EL TIPO DE CONCILIACION.',
'Fecha: 2011/07/06',
'Version: 20110706.1139',
'BD: bditarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICA LA LOGICA PARA LA CLASIFICACION DE LAS TRANSACCIONES DE DEVOLUCIONES (21) PARA LOS TIPOS DE CONCILIACION 10,11 Y 12. SE AGREGA EL TIPO CONCILIACION 14.',
'Fecha: 2012/04/19',
'Version: 20120419.1110',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICA LA LOGICA PARA LAS DEVOLUCIONES CON MONTO MAYOR SE RECLASIFICAN A TIPO 10 (ANTERIORMENTE 12).',
'Fecha: 2012/05/21',
'Version: 20120521.1210',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICA LA LOGICA PARA QUE EN LOS TIPOS DE CONCILIACION 7 Y 13 UTILICE EL CAMPO [FORMATO] PARA VALIDAR LA NATURALEZA DE LA TRANSACCION.',
'Fecha: 2012/05/21',
'Version: 20120521.1445',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE HACE NUEVAMENTE EL SP, OPTIMIZANDO EL PROCESO EN CUANTO A FUNCIONAMIENTO Y CLARIDAD DEL CODIGO.',
'Fecha: 2012/06/25',
'Version: 20120625.1753',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AGREGA LOGICA PARA LA CLASIFICACION DE TRANSACCIONES DE ATM.',
'Fecha: 2012/07/27',
'Version: 20120727.1148',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AJUSTA LA LOGICA PARA LA CLASIFICACION DE TRANSACCIONES DE ATM EN EL CASO DE LAS TARJETAS CON DIF ESTATUS.',
'Fecha: 2012/07/30',
'Version: 20120730.1221',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AJUSTA LA LOGICA PARA ELIMINAR LA CLASIFICACION DE LOS ARCHIVOS PNC DEL PROCESO PUESTO QUE NO REQUIEREN CLASIFICACION.',
'Fecha: 2012/08/10',
'Version: 20120810.1035',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AJUSTA LA LOGICA PARA CLASIFICAR LAS TRANSACCIONES TIPO 20 EN LOS ARCHIVOS VIC(MONEYGRAM).',
'Fecha: 2012/10/01',
'Version: 20121001.0955',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AJUSTA LA LOGICA PARA CLASIFICAR LAS TRANSACCIONES TIPO 21 CON CONSEGUTIVOS DE NUMEROS REPETIDOS. Y HOMOLOGACION DE CODIGO',
'Fecha: 2012/10/12',
'Version: 20121012.1015',
'BD: BdiTarjeta',
'',
'MODIFICACION: Ricardo Reséndiz Martinez',
'Proyecto: INC 13 XXX Clasificacion de movimientos por cartera vendida',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Se agrego validacion para el status del credito y hacer la validacion correspondiente ',
'Fecha: 2013/02/06',
'Version: 20130206.1400',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_concreing_buscarmovimientointercard_pba(
		psCve_usuario CHAR(10),
		psNumtarjeta CHAR(16),
		psSecuencia325 CHAR(6),
		psMonto325 CHAR(13)
	)

RETURNING CHAR(5) AS Retorno,
	CHAR(7) AS secuencia,
	CHAR(15) AS secuencia_extendida,
	--MONEY(19,4) AS montointercard,
	MONEY AS montointercard,
	DATETIME YEAR TO FRACTION(5) AS fechatransaccion,
	CHAR(40) AS infreceptor,
	CHAR(16) AS idterminal,
	CHAR(2) AS metodocaptura,
	CHAR(1) AS movconciliado,
	CHAR(1) AS movreversado,
	CHAR(2) AS codigoiso,
	CHAR(4) AS Formato,
	CHAR(250) AS ErrorActividad,
	CHAR(1) AS CodReversa, 
	CHAR(5) AS CodigoCentral ;

	/*
	*****************************************************************************************************
	-- DESCRIPCION:  OBTIENE EL MOVIMIENTO ORIGINAL DE INTERCARD:MOVIMIENTO  ----------------------------
	-- AUTOR : Ing. Alfonso Cruz  -----------------------------------------------------------------------
	-- FECHA : 24/06/2011  ------------------------------------------------------------------------------
	-- BD: bditarjeta  ----------------------------------------------------------------------------------
	-- SISTEMA : Reingenieria de la conciliacion automatica / Conciliacion Intercard  -------------------
	*****************************************************************************************************
	*/

	/*DEFINICION DE VARIABLES*/

	/*VARIABLES DE RETORNO*/
	/*VARIABLES DE ERROR*/
	DEFINE viCodigo INTEGER;
	DEFINE vssqlerr CHAR(5) ;
	DEFINE vsErrorActividad CHAR(250);

	/*VARIABLES DEL MOVIMIENTO ORIGINAL*/
	DEFINE vsNumtarjeta CHAR(16);
	DEFINE vsSecuenciaorig CHAR(7);
	DEFINE vsSecuencia_extendida CHAR(15);
	--DEFINE vmMontointercard MONEY(19,4);
	DEFINE vmMontointercard MONEY;
	DEFINE vdFechatransaccion DATETIME YEAR TO FRACTION(5);
	DEFINE vsInfreceptor CHAR(40);
	DEFINE vsIdterminal CHAR(16);
	DEFINE vsMetodocaptura CHAR(2);
	DEFINE vsMovconciliado CHAR(1);
	DEFINE vsMovreversado CHAR(1);
	DEFINE vsCodigoiso CHAR(2);
	DEFINE vsFormato VARCHAR(2);
	DEFINE vsCodReversa CHAR(1); 
	DEFINE vsCodigoCentral CHAR(5);	

	DEFINE vsSecuencia CHAR(7);
	
	DEFINE vmmonto325 money;
	DEFINE contador integer;
	/*INICIALIZACION DE VARIABLES*/

	LET viCodigo = 0;
	LET vssqlerr = '00000';
	LET vsErrorActividad = '';

	LET vsNumtarjeta = '';
	LET vsSecuenciaorig = '';
	LET vsSecuencia_extendida = '';
	LET vmMontointercard = 0;
	LET vdFechatransaccion = CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5));
	LET vsInfreceptor = '';
	LET vsIdterminal = '';
	LET vsMetodocaptura = '';
	LET vsMovconciliado = '';
	LET vsMovreversado = '';
	LET vsCodigoiso = '';
	LET vsCodReversa = '';
	LET vsCodigoCentral = '';

	LET vsFormato = '';
	LET vsSecuencia = '';
	
	LET vmmonto325 = 0;
	LET contador = 0;
	BEGIN

		ON EXCEPTION SET viCodigo   --cacha el error en caso de que exista y regresa un valor predeterminado

				LET vssqlerr = viCodigo;

				RETURN vssqlerr, 
					NVL(vsSecuenciaorig,''), 
					NVL(vsSecuencia_extendida,''), 
					NVL(vmMontointercard,0),
					NVL(vdFechatransaccion,CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5))), 
					NVL(vsInfreceptor,''), 
					NVL(vsIdterminal,''), 
					NVL(vsMetodocaptura,''), 
					NVL(vsMovconciliado,''), 
					NVL(vsMovreversado,''), 
					NVL(vsCodigoiso,''), 
					NVL(vsFormato, ''),
					NVL(vsErrorActividad,''),
					NVL(vsCodReversa, ''),
					NVL(vsCodigoCentral,'');

		END EXCEPTION;

		--SET DEBUG FILE TO '/home/sysifx/concreing/TraceBUSCARMOVIMIENTOINTERCARD.sql';
		--SET DEBUG FILE TO '/informix/HomeInformix/rrm/Buscamovintercard.out';
		--TRACE ON;

		-----------------------------------------------------
		--------REINGENIERIA-CONCILIACION-AUTOMATICA---------
		--------2011/06/24-ING-ALFONSO-CRUZ------------------
		-----------------------------------------------------

		LET vsSecuencia = "1"||psSecuencia325;
		

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;
		
		select 
			count(*) into contador
		from intercard:"informix".movimiento
			where 	numtarjeta = psNumtarjeta AND 
					secuencia = vsSecuencia;

		if (contador = 1) then 			
				SELECT FIRST 1 numtarjeta,
					secuencia, 
					secuenciaextendida, 
					(NVL(monto,0) + NVL(montosurcharge,0)),
					fechahorainauth, 
					infreceptor, 
					idterminal, 
					metodocaptura, 
					movconciliado, 
					movreversado, 
					codigoiso, 
					Formato,
					CodReversa,
					CodigoCentral
				INTO vsNumtarjeta, 
					vsSecuenciaorig, 
					vsSecuencia_extendida, 
					vmMontointercard,
					vdFechatransaccion, 
					vsInfreceptor, 
					vsIdterminal, 
					vsMetodocaptura, 
					vsMovconciliado, 
					vsMovreversado, 
					vsCodigoiso, 
					vsFormato,
					vsCodReversa,
					vsCodigoCentral
				FROM intercard:"informix".movimiento
				WHERE numtarjeta = psNumtarjeta AND 
				secuencia = vsSecuencia;
				
		elif (contador >=2) then 
			LET vmMonto325 = ( ( REPLACE( psMonto325,'.',''))::MONEY /100 );
			SELECT limit 1 numtarjeta,
					secuencia, 
					secuenciaextendida, 
					(NVL(monto,0) + NVL(montosurcharge,0)),
					fechahorainauth, 
					infreceptor, 
					idterminal, 
					metodocaptura, 
					movconciliado, 
					movreversado, 
					codigoiso, 
					Formato,
					CodReversa,
					CodigoCentral
				INTO vsNumtarjeta, 
					vsSecuenciaorig, 
					vsSecuencia_extendida, 
					vmMontointercard,
					vdFechatransaccion, 
					vsInfreceptor, 
					vsIdterminal, 
					vsMetodocaptura, 
					vsMovconciliado, 
					vsMovreversado, 
					vsCodigoiso, 
					vsFormato,
					vsCodReversa,
					vsCodigoCentral
				FROM intercard:"informix".movimiento
				WHERE 	numtarjeta = psNumtarjeta AND 
						secuencia = vsSecuencia AND
						monto = vmMonto325;
		END IF;
						
		IF ( (vsNumtarjeta IS NULL) OR ( TRIM (vsNumtarjeta) = '') ) THEN
		
			/*NO EXISTE EL MOVIMIENTO ORIGINAL*/
			LET vssqlerr = '00400';
			LET vsErrorActividad = 'NO EXISTE EL MOVIMIENTO INTERCARD';
			
		END IF;

	/*RETORNO DEL PROCEDIMIENTO ALMACENADO*/
	RETURN vssqlerr, 
			NVL(vsSecuenciaorig,''), 
			NVL(vsSecuencia_extendida,''), 
			NVL(vmMontointercard,0),
			NVL(vdFechatransaccion,CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5))), 
			NVL(vsInfreceptor,''), 
			NVL(vsIdterminal,''), 
			NVL(vsMetodocaptura,''), 
			NVL(vsMovconciliado,''), 
			NVL(vsMovreversado,''), 
			NVL(vsCodigoiso,''), 
			NVL(vsFormato, ''),
			NVL(vsErrorActividad,''),
			NVL(vsCodReversa, ''),
			NVL(vsCodigoCentral,'');

	END

END PROCEDURE
DOCUMENT
'AUTOR: Ing. Alfonso Cruz',
'Proyecto: Reingenieria de la Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: OBTIENE EL MOVIMIENTO ORIGINAL DE INTERCARD:MOVIMIENTO.',
'Fecha: 2011/06/24',
'Version: 20110624.1601',
'BD: bditarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion -DEVOLUCIONES',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AGREGA EL CAMPO DE [FORMATO] A LA CONSULTA Y EL RETORNO DEL SP.',
'Fecha: 2012/05/21',
'Version: 20120521.1231',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion ',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AGREGA LA OBTENCION DE LOS CAMPOS CodReversa Y CodigoCentral PARA LAS CONCILIACION DE ATM.',
'Fecha: 2012/07/27',
'Version: 20120727.1433',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion ',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AGREGA EL MONTOSURCHARGE AL MOTO DE LA OPERACION.',
'Fecha: 2012/08/24',
'Version: 20120824.1703',
'BD: BdiTarjeta',
'',
'MODIFICACION: Ricardo Reséndiz Martinez',
'Proyecto: Reingenieria Conciliacion ',
'Solicito: Luis Antonio Gomez',
'Descripcion: Se agrega validación para contemplar secuencias iguales a una tarjeta de operaciones diferentes ',
'Fecha: 2013/05/30',
'Version: 20130530.1400',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_concreing_consdevolucion_pba( piTipoArchivo INTEGER, psFechaConsulta VARCHAR(10), psNombreArchivo VARCHAR(21))
RETURNING 	VARCHAR(5)  AS CodRet, 
			VARCHAR(48) AS TipoArchivo, 
			VARCHAR(23) AS NombreArchivo,
			DATE		AS FechaCarga,
			INTEGER 	AS DevRecibidas, 
			INTEGER 	AS DevAplicadas,
			INTEGER 	AS DevAplicadasForzadas, 
			INTEGER 	AS DevConciliadasSA, 
			INTEGER 	AS DevErrorIntegridad, 
			INTEGER 	AS DevFaltantes,
			VARCHAR(16) AS NumTarjeta,
			VARCHAR(5)  AS TipoOperacion,
			VARCHAR(61) AS Motivo,
			VARCHAR(30) AS NomComercio,
			VARCHAR(40) AS Referencia,
			MONEY		AS Monto;

--****************************************************************************************************
-- DESCRIPCION: OBTENCION DE DEVOLUCIONES POS
-- AUTOR : Arturo Méndez Cárdenas
-- FECHA : 12/ABRIL/2012
-- BD: BdiTarjeta
-- SISTEMA : DevolucionesPOS
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */

--CONTROL GENERAL
DEFINE cCodret CHAR(5);
DEFINE cTipoarchivo CHAR(48);
DEFINE cNombrearchivo CHAR(23);
DEFINE cFechacarga DATE;
DEFINE iDevrecibidas INTEGER;
DEFINE iDevaplicadas INTEGER;
DEFINE iDevaplicadasforzadas INTEGER;
DEFINE iDevconciliadassa INTEGER;
DEFINE iDeverrorintegridad INTEGER;
DEFINE iDevfaltantes INTEGER;
DEFINE iEncontrado INTEGER;
DEFINE cArchivoOrigenAnt CHAR(23);
DEFINE cArchivoOrigen CHAR(3);

-- Variables de Detalle
DEFINE cNumTarjeta CHAR(16);
DEFINE cTipoOperacion CHAR(5);
DEFINE cMotivo CHAR(61);
DEFINE cNomcomercio CHAR(30);
DEFINE cReferencia CHAR(40);
DEFINE mMonto325 MONEY;

/* INICIALIZACION DE VARIABLES */
--CONTROL GENERAL
LET cCodret = '00000';
LET cTipoArchivo = '';
LET cNombrearchivo = '';
LET cFechacarga = CURRENT::DATE;
LET iDevrecibidas = 0;
LET iDevaplicadas = 0;
LET iDevaplicadasforzadas = 0;
LET iDevconciliadasSA = 0;
LET iDevErrorIntegridad = 0;
LET iDevFaltantes = 0;
LET iEncontrado = 0;
LET cArchivoOrigenAnt = '';
LET cArchivoOrigen = '';

-- Variables de Detalle
LET cNumTarjeta = '';
LET cTipoOperacion = '';
LET cMotivo = '';
LET cNomcomercio = '';
LET cReferencia = '';
LET mMonto325 = 0.0;

BEGIN
	
ON EXCEPTION SET iDevrecibidas 
   IF iDevrecibidas != 0 THEN
      LET cCodret = iDevrecibidas;      
      RETURN cCodret,cTipoArchivo, cNombrearchivo,cFechacarga,iDevrecibidas,iDevaplicadas,iDevaplicadasforzadas,iDevconciliadasSA,iDevErrorIntegridad,iDevFaltantes,
				cNumTarjeta,cTipoOperacion,cMotivo,cNomcomercio,cReferencia,mMonto325;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO 'respaldosbd/sp_concreing_pba.txt';
--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF piTipoArchivo = 1 THEN -- Todos los tipos de archivos
	
		FOREACH WITH HOLD
			SELECT {+INDEX(td_devolucionespos idx_td_devolucionespos)} distinct(nomarchivo),fecha,archivoorigen INTO cNombrearchivo,cFechacarga,cArchivoOrigen 
			FROM bditarjeta:"informix".td_devolucionespos 
			WHERE archivoorigen IN('VIC','VNC','VID','VND') AND fecha = psFechaConsulta 
			
			LET iEncontrado = 0;
				
			-- Archivos con devoluciones pendientes(Crédito o Débito).
			IF EXISTS( SELECT nomarchivo FROM bditarjeta:"informix".td_devolucionespos WHERE nomarchivo = cNombreArchivo 
						AND fecha = psFechaConsulta AND archivoorigen = cArchivoOrigen 
						AND ((encontrado = 'V' AND estado IN('P','A','F') AND aplicado IN('F','E')) OR 
							 (encontrado = 'F' AND estado = 'P' AND aplicado IN('E','F'))) ) THEN	-- (tipo_conciliación 0,10,12 y 15)
			
				IF(iEncontrado = 0 OR cArchivoOrigen <> cArchivoOrigenAnt) THEN
					IF cArchivoOrigen IN('VIC','VNC') THEN
						IF iEncontrado = 0 THEN					
							LET cTipoArchivo = 'Archivo de crédito con devoluciones pendientes';
							LET iEncontrado= 1;
							LET cArchivoOrigenAnt = cArchivoOrigen;
						END IF;
					ELIF cArchivoOrigen IN('VID','VND') THEN
						IF iEncontrado = 0 THEN
							LET cTipoArchivo = 'Archivo de débito con devoluciones pendientes';
							LET iEncontrado = 1;
							LET cArchivoOrigenAnt = cArchivoOrigen;
						END IF;
					END IF;
						
					-- Total Devoluciones Recibidas.
					SELECT COUNT(nomarchivo) INTO iDevrecibidas FROM bditarjeta:"informix".td_devolucionespos 
					WHERE nomarchivo = cNombreArchivo AND fecha = psFechaConsulta;
					
					-- Total Devoluciones Aplicadas (tipo_conciliacion = 14).
					SELECT COUNT(nomarchivo) INTO iDevaplicadas FROM bditarjeta:"informix".td_devolucionespos 
					WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado = 'A' AND aplicado = 'V';
					
					-- Total Devoluciones Aplicadas Forzadas (tipo_conciliacion = 11).
					SELECT COUNT(nomarchivo) INTO iDevaplicadasforzadas FROM bditarjeta:"informix".td_devolucionespos 
					WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado = 'F' AND aplicado = 'V';
					
					-- Total Devoluciones Conciliadas sin Aplicar (tipo_conciliacion 10 y 15).
					SELECT COUNT(nomarchivo) INTO iDevconciliadasSA FROM bditarjeta:"informix".td_devolucionespos 
					WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado IN('P','A','F') AND aplicado IN('F','E');
					
					-- Total Devoluciones con Error de Integridad (tipo_conciliacion 0 y 12).
					SELECT COUNT(nomarchivo) INTO iDevErrorIntegridad FROM bditarjeta:"informix".td_devolucionespos 
					WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'F' AND estado = 'P' AND aplicado IN('E','F');
					
					-- Total Devoluciones Faltantes.
					SELECT FIRST 1 iDevrecibidas - ( iDevaplicadas + iDevaplicadasforzadas ) INTO iDevFaltantes 
					---FROM bditarjeta:"informix".td_devolucionespos;
					FROM bditarjeta:"informix".td_param;
					
					IF iDevrecibidas > 0 THEN
						LET cCodRet = '00001';
					END IF;
					RETURN cCodret,cTipoArchivo,cNombrearchivo,cFechacarga,iDevrecibidas,iDevaplicadas,iDevaplicadasforzadas,iDevconciliadasSA,iDevErrorIntegridad,iDevFaltantes,
							cNumTarjeta,cTipoOperacion,cMotivo,cNomcomercio,cReferencia,mMonto325 WITH RESUME;
				END IF;
			ELSE	-- Archivos sin devoluciones(Crédito o Débito).
				IF cArchivoOrigen IN('VIC','VNC') THEN
					LET cTipoArchivo = 'Archivo de crédito sin devoluciones pendientes';
				ELIF cArchivoOrigen IN('VID','VND') THEN
					LET cTipoArchivo = 'Archivo de débito sin devoluciones pendientes';
				END IF;
					
				-- Total Devoluciones Recibidas.
				SELECT COUNT(nomarchivo) INTO iDevrecibidas FROM bditarjeta:"informix".td_devolucionespos 
				WHERE nomarchivo = cNombreArchivo AND fecha = psFechaConsulta;
				
				-- Total Devoluciones Aplicadas (tipo_conciliacion = 14).
				SELECT COUNT(nomarchivo) INTO iDevaplicadas FROM bditarjeta:"informix".td_devolucionespos 
				WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado = 'A' AND aplicado = 'V';
				
				-- Total Devoluciones Aplicadas Forzadas (tipo_conciliacion = 11).
				SELECT COUNT(nomarchivo) INTO iDevaplicadasforzadas FROM bditarjeta:"informix".td_devolucionespos 
				WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado = 'F' AND aplicado = 'V';
				
				-- Total Devoluciones Conciliadas sin Aplicar (tipo_conciliacion 10 y 15).
				SELECT COUNT(nomarchivo) INTO iDevconciliadasSA FROM bditarjeta:"informix".td_devolucionespos 
				WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado IN('P','A','F') AND aplicado IN('F','E');
				
				-- Total Devoluciones con Error de Integridad (tipo_conciliacion 0 y 12).
				SELECT COUNT(nomarchivo) INTO iDevErrorIntegridad FROM bditarjeta:"informix".td_devolucionespos 
				WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'F' AND estado = 'P' AND aplicado IN('E','F');
				
				-- Total Devoluciones Faltantes.
				SELECT FIRST 1 iDevrecibidas - ( iDevaplicadas + iDevaplicadasforzadas ) INTO iDevFaltantes 
				---FROM bditarjeta:"informix".td_devolucionespos;
				FROM bditarjeta:"informix".td_param;
				
				IF iDevrecibidas > 0 THEN
					LET cCodRet = '00001';
				END IF;
				RETURN cCodret,cTipoArchivo,cNombrearchivo,cFechacarga,iDevrecibidas,iDevaplicadas,iDevaplicadasforzadas,iDevconciliadasSA,iDevErrorIntegridad,iDevFaltantes,
						cNumTarjeta,cTipoOperacion,cMotivo,cNomcomercio,cReferencia,mMonto325 WITH RESUME;
			END IF;
		END FOREACH;
		
		LET cNombrearchivo = '';
		LET cFechacarga = '';
		LET cArchivoOrigen = '';
		
		FOREACH WITH HOLD -- Se regresa valores en 0 para casos donde no existen devoluciones dentro de archivos.
			SELECT distinct(nombrearchivo),fecha_archivo,archivo_origen INTO cNombrearchivo,cFechacarga,cArchivoOrigen 
			FROM bditarjeta:"informix".td_archivos_conciliacion WHERE fecha_archivo = psFechaConsulta 
			AND fecha_hora_fin_proceso > '1900-01-01 00:00:00.0' AND archivo_origen IN('VIC','VNC','VID','VND') 
			AND nombrearchivo NOT IN (select nomarchivo	from bditarjeta:"informix".td_devolucionespos where fecha = psFechaConsulta)			
						
			IF( cArchivoOrigen = 'VIC' OR cArchivoOrigen = 'VNC' ) THEN
				LET cTipoArchivo = 'Archivo de crédito sin devoluciones';
				LET iDevrecibidas = 0;
				LET iDevaplicadas = 0;
				LET iDevaplicadasforzadas = 0;
				LET iDevconciliadasSA = 0;
				LET iDevErrorIntegridad = 0;
				LET iDevFaltantes = 0;
				LET cCodRet = '00001';
				
				RETURN cCodret,cTipoArchivo,cNombrearchivo,cFechacarga,iDevrecibidas,iDevaplicadas,iDevaplicadasforzadas,iDevconciliadasSA,iDevErrorIntegridad,iDevFaltantes,
						cNumTarjeta,cTipoOperacion,cMotivo,cNomcomercio,cReferencia,mMonto325 WITH RESUME;
				
			ELIF( cArchivoOrigen = 'VID' OR cArchivoOrigen = 'VND' ) THEN
				LET cTipoArchivo = 'Archivo de débito sin devoluciones';
				LET iDevrecibidas = 0;
				LET iDevaplicadas = 0;
				LET iDevaplicadasforzadas = 0;
				LET iDevconciliadasSA = 0;
				LET iDevErrorIntegridad = 0;
				LET iDevFaltantes = 0;
				LET cCodRet = '00001';
				
				RETURN cCodret,cTipoArchivo,cNombrearchivo,cFechacarga,iDevrecibidas,iDevaplicadas,iDevaplicadasforzadas,iDevconciliadasSA,iDevErrorIntegridad,iDevFaltantes,
						cNumTarjeta,cTipoOperacion,cMotivo,cNomcomercio,cReferencia,mMonto325 WITH RESUME;
			END IF;
		END FOREACH;
	
	ELIF piTipoArchivo = 2 THEN -- Archivos de crédito con devoluciones pendientes
		
		FOREACH WITH HOLD
			SELECT distinct(nomarchivo),fecha INTO cNombrearchivo,cFechacarga 
			FROM bditarjeta:"informix".td_devolucionespos 
			WHERE archivoorigen IN('VIC','VNC') AND fecha = psFechaConsulta 
			AND ((encontrado = 'V' AND estado IN('P','A','F') AND aplicado IN('F','E')) OR 
				 (encontrado = 'F' AND estado = 'P' AND aplicado IN('E','F'))) -- (tipo_conciliación 0,10,12 y 15)
						
			LET cTipoArchivo = 'Archivo de crédito con devoluciones pendientes';
			
			-- Total Devoluciones Recibidas.
			SELECT COUNT(nomarchivo) INTO iDevrecibidas FROM bditarjeta:"informix".td_devolucionespos 
			WHERE nomarchivo = cNombreArchivo AND fecha = psFechaConsulta;
			
			-- Total Devoluciones Aplicadas (tipo_conciliacion = 14).
			SELECT COUNT(nomarchivo) INTO iDevaplicadas FROM bditarjeta:"informix".td_devolucionespos 
			WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado = 'A' AND aplicado = 'V';
			
			-- Total Devoluciones Aplicadas Forzadas (tipo_conciliacion = 11).
			SELECT COUNT(nomarchivo) INTO iDevaplicadasforzadas FROM bditarjeta:"informix".td_devolucionespos 
			WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado = 'F' AND aplicado = 'V';
			
			-- Total Devoluciones Conciliadas sin Aplicar (tipo_conciliacion 10 y 15).
			SELECT COUNT(nomarchivo) INTO iDevconciliadasSA FROM bditarjeta:"informix".td_devolucionespos 
			WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado IN('P','A','F') AND aplicado IN('F','E');
			
			-- Total Devoluciones con Error de Integridad (tipo_conciliacion 0 y 12).
			SELECT COUNT(nomarchivo) INTO iDevErrorIntegridad FROM bditarjeta:"informix".td_devolucionespos 
			WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'F' AND estado = 'P' AND aplicado IN('E','F');
			
			-- Total Devoluciones Faltantes.
			SELECT FIRST 1 iDevrecibidas - ( iDevaplicadas + iDevaplicadasforzadas ) INTO iDevFaltantes 
			---FROM bditarjeta:"informix".td_devolucionespos;
			FROM bditarjeta:"informix".td_param;
									
			IF iDevrecibidas > 0 THEN
				LET cCodRet = '00001';
			END IF;
			RETURN cCodret,cTipoArchivo,cNombrearchivo,cFechacarga,iDevrecibidas,iDevaplicadas,iDevaplicadasforzadas,iDevconciliadasSA,iDevErrorIntegridad,iDevFaltantes,
					cNumTarjeta,cTipoOperacion,cMotivo,cNomcomercio,cReferencia,mMonto325 WITH RESUME;
		END FOREACH;
		
	ELIF piTipoArchivo = 3 THEN -- Archivos de crédito sin devoluciones pendientes
				
		IF NOT EXISTS( SELECT nomarchivo FROM bditarjeta:"informix".td_devolucionespos 
						WHERE archivoorigen IN('VIC','VNC') AND fecha = psFechaConsulta 
						AND ((encontrado = 'V' AND estado IN('P','A','F') AND aplicado IN('F','E')) OR 
							(encontrado = 'F' AND estado = 'P' AND aplicado IN('E','F'))) ) THEN
		
			FOREACH WITH HOLD
				SELECT distinct(nomarchivo),fecha INTO cNombrearchivo,cFechacarga 
				FROM bditarjeta:"informix".td_devolucionespos 
				WHERE archivoorigen IN('VIC','VNC') AND fecha = psFechaConsulta 
				AND((encontrado = 'V' AND estado = 'F' AND aplicado = 'V') OR 
					(encontrado = 'V' AND estado = 'A' AND aplicado = 'V')) -- (tipo_conciliacion 11 y 14)
					
				LET cTipoArchivo = 'Archivo de crédito sin devoluciones pendientes';
				
				-- Total Devoluciones Recibidas.
				SELECT COUNT(nomarchivo) INTO iDevrecibidas FROM bditarjeta:"informix".td_devolucionespos 
				WHERE nomarchivo = cNombreArchivo AND fecha = psFechaConsulta;
				
				-- Total Devoluciones Aplicadas (tipo_conciliacion = 14).
				SELECT COUNT(nomarchivo) INTO iDevaplicadas FROM bditarjeta:"informix".td_devolucionespos 
				WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado = 'A' AND aplicado = 'V';
				
				-- Total Devoluciones Aplicadas Forzadas (tipo_conciliacion = 11).
				SELECT COUNT(nomarchivo) INTO iDevaplicadasforzadas FROM bditarjeta:"informix".td_devolucionespos 
				WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado = 'F' AND aplicado = 'V';
				
				-- Total Devoluciones Conciliadas sin Aplicar (tipo_conciliacion 10 y 15).
				SELECT COUNT(nomarchivo) INTO iDevconciliadasSA FROM bditarjeta:"informix".td_devolucionespos 
				WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado IN('P','A','F') AND aplicado IN('F','E');
				
				-- Total Devoluciones con Error de Integridad (tipo_conciliacion 0 y 12).
				SELECT COUNT(nomarchivo) INTO iDevErrorIntegridad FROM bditarjeta:"informix".td_devolucionespos 
				WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'F' AND estado = 'P' AND aplicado IN('E','F');
				
				-- Total Devoluciones Faltantes.
				SELECT FIRST 1 iDevrecibidas - ( iDevaplicadas + iDevaplicadasforzadas ) INTO iDevFaltantes 
				---FROM bditarjeta:"informix".td_devolucionespos;
				FROM bditarjeta:"informix".td_param;
				
				IF iDevrecibidas > 0 THEN
					LET cCodRet = '00001';
				END IF;
				
				RETURN cCodret,cTipoArchivo,cNombrearchivo,cFechacarga,iDevrecibidas,iDevaplicadas,iDevaplicadasforzadas,iDevconciliadasSA,iDevErrorIntegridad,iDevFaltantes,
						cNumTarjeta,cTipoOperacion,cMotivo,cNomcomercio,cReferencia,mMonto325 WITH RESUME;
			END FOREACH;
		END IF;
	
	ELIF piTipoArchivo = 4 THEN -- Archivos de débito con devoluciones pendientes
	
		FOREACH WITH HOLD
			SELECT distinct(nomarchivo),fecha INTO cNombrearchivo,cFechacarga 
			FROM bditarjeta:"informix".td_devolucionespos 
			WHERE archivoorigen IN('VID','VND') AND fecha = psFechaConsulta 
			AND ((encontrado = 'V' AND estado IN('P','A','F') AND aplicado IN('F','E')) OR 
				 (encontrado = 'F' AND estado = 'P' AND aplicado IN('E','F'))) -- (tipo_conciliación 0,10,12 y 15)
			
			LET cTipoArchivo = 'Archivo de débito con devoluciones pendientes';
			
			-- Total Devoluciones Recibidas.
			SELECT COUNT(nomarchivo) INTO iDevrecibidas FROM bditarjeta:"informix".td_devolucionespos 
			WHERE nomarchivo = cNombreArchivo AND fecha = psFechaConsulta;
			
			-- Total Devoluciones Aplicadas (tipo_conciliacion = 14).
			SELECT COUNT(nomarchivo) INTO iDevaplicadas FROM bditarjeta:"informix".td_devolucionespos 
			WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado = 'A' AND aplicado = 'V';
			
			-- Total Devoluciones Aplicadas Forzadas (tipo_conciliacion = 11).
			SELECT COUNT(nomarchivo) INTO iDevaplicadasforzadas FROM bditarjeta:"informix".td_devolucionespos 
			WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado = 'F' AND aplicado = 'V';
			
			-- Total Devoluciones Conciliadas sin Aplicar (tipo_conciliacion 10 y 15).
			SELECT COUNT(nomarchivo) INTO iDevconciliadasSA FROM bditarjeta:"informix".td_devolucionespos 
			WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado IN('P','A','F') AND aplicado IN('F','E');
			
			-- Total Devoluciones con Error de Integridad (tipo_conciliacion 0 y 12).
			SELECT COUNT(nomarchivo) INTO iDevErrorIntegridad FROM bditarjeta:"informix".td_devolucionespos 
			WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'F' AND estado = 'P' AND aplicado IN('E','F');
			
			-- Total Devoluciones Faltantes.
			SELECT FIRST 1 iDevrecibidas - ( iDevaplicadas + iDevaplicadasforzadas ) INTO iDevFaltantes 
			----FROM bditarjeta:"informix".td_devolucionespos;
			FROM bditarjeta:"informix".td_param;
					
			IF iDevrecibidas > 0 THEN
				LET cCodRet = '00001';
			END IF;
			RETURN cCodret,cTipoArchivo,cNombrearchivo,cFechacarga,iDevrecibidas,iDevaplicadas,iDevaplicadasforzadas,iDevconciliadasSA,iDevErrorIntegridad,iDevFaltantes,
					cNumTarjeta,cTipoOperacion,cMotivo,cNomcomercio,cReferencia,mMonto325 WITH RESUME;
		END FOREACH;
	
	ELIF piTipoArchivo = 5 THEN -- Archivos de débito sin devoluciones pendientes
				
		IF NOT EXISTS( SELECT nomarchivo FROM bditarjeta:"informix".td_devolucionespos 
						WHERE archivoorigen IN('VID','VND') AND fecha = psFechaConsulta 
						AND ((encontrado = 'V' AND estado IN('P','A','F') AND aplicado IN('F','E')) OR 
							(encontrado = 'F' AND estado = 'P' AND aplicado IN('E','F'))) ) THEN
		
			FOREACH WITH HOLD
				SELECT distinct(nomarchivo),fecha INTO cNombrearchivo,cFechacarga 
				FROM bditarjeta:"informix".td_devolucionespos 
				WHERE archivoorigen IN('VID','VND') AND fecha = psFechaConsulta 
				AND((encontrado = 'V' AND estado = 'F' AND aplicado = 'V') OR 
					(encontrado = 'V' AND estado = 'A' AND aplicado = 'V')) -- (tipo_conciliacion 11 y 14)
							
				LET cTipoArchivo = 'Archivo de débito sin devoluciones pendientes';
				
				-- Total Devoluciones Recibidas.
				SELECT COUNT(nomarchivo) INTO iDevrecibidas FROM bditarjeta:"informix".td_devolucionespos 
				WHERE nomarchivo = cNombreArchivo AND fecha = psFechaConsulta;
				
				-- Total Devoluciones Aplicadas (tipo_conciliacion = 14).
				SELECT COUNT(nomarchivo) INTO iDevaplicadas FROM bditarjeta:"informix".td_devolucionespos 
				WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado = 'A' AND aplicado = 'V';
				
				-- Total Devoluciones Aplicadas Forzadas (tipo_conciliacion = 11).
				SELECT COUNT(nomarchivo) INTO iDevaplicadasforzadas FROM bditarjeta:"informix".td_devolucionespos 
				WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado = 'F' AND aplicado = 'V';
				
				-- Total Devoluciones Conciliadas sin Aplicar (tipo_conciliacion 10 y 15).
				SELECT COUNT(nomarchivo) INTO iDevconciliadasSA FROM bditarjeta:"informix".td_devolucionespos 
				WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado IN('P','A','F') AND aplicado IN('F','E');
				
				-- Total Devoluciones con Error de Integridad (tipo_conciliacion 0 y 12).
				SELECT COUNT(nomarchivo) INTO iDevErrorIntegridad FROM bditarjeta:"informix".td_devolucionespos 
				WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'F' AND estado = 'P' AND aplicado IN('E','F');
				
				-- Total Devoluciones Faltantes.
				SELECT FIRST 1 iDevrecibidas - ( iDevaplicadas + iDevaplicadasforzadas ) INTO iDevFaltantes 
				---FROM bditarjeta:"informix".td_devolucionespos;
				FROM bditarjeta:"informix".td_param;
				
				IF iDevrecibidas > 0 THEN
					LET cCodRet = '00001';
				END IF;
				RETURN cCodret,cTipoArchivo,cNombrearchivo,cFechacarga,iDevrecibidas,iDevaplicadas,iDevaplicadasforzadas,iDevconciliadasSA,iDevErrorIntegridad,iDevFaltantes,
						cNumTarjeta,cTipoOperacion,cMotivo,cNomcomercio,cReferencia,mMonto325 WITH RESUME;
			END FOREACH;
		END IF;
	
	ELIF piTipoArchivo = 6 THEN -- Datos Detalle
	
		FOREACH WITH HOLD		
			SELECT numtarjeta,fecha,nomcomercio,referencia,montoarchivo,motivo 
			INTO cNumTarjeta,cFechacarga,cNomcomercio,cReferencia,mMonto325,cMotivo  
			FROM bditarjeta:"informix".td_devolucionespos 
			WHERE nomarchivo = psNombreArchivo AND fecha = psFechaConsulta
			
			LET cTipoOperacion = 'ABONO'; -- Valor por Default.
			LET cCodret = '00001';
					
			RETURN cCodret,cTipoArchivo,cNombrearchivo,cFechacarga,iDevrecibidas,iDevaplicadas,iDevaplicadasforzadas,iDevconciliadasSA,iDevErrorIntegridad,iDevFaltantes,
					cNumTarjeta,cTipoOperacion,cMotivo,cNomcomercio,cReferencia,mMonto325 WITH RESUME;
			END FOREACH;
	END IF;
	
END
END PROCEDURE
DOCUMENT
'AUTOR: Arturo Méndez Cárdenas',
'Proyecto: ReingenieriaConciliacionAutomatica',
'Solicito: Jose Luis Puebla',
'Fecha: 2012/04/12',
'Version: 20120412.1605',
'BD: BdiTarjeta',
'',
'MODIFICACION: Arturo Méndez Cárdenas',
'Proyecto: ReingenieriaConciliacionAutomatica',
'Solicito: Jose Luis Puebla',
'Fecha: 2012/05/23',
'Version: 20120523.1542',
'BD: BdiTarjeta',
'',
'MODIFICACION: Arturo Méndez Cárdenas',
'Proyecto: ReingenieriaConciliacionAutomatica',
'Solicito: Jose Luis Puebla',
'Cambio: Se modifica para obtener archivos sin devoluciones',
'Fecha: 2012/06/22',
'Version: 20120622.0845',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_concreing_consif_pba(pusuario CHAR(9),parchivo_origen CHAR(3),pfecha DATE,
   psistema CHAR,
   ptran_car CHAR(4),
   ptran_lib CHAR(4),
   ptran_for CHAR(4),
   ptran_abo CHAR(4),
   ptran_Extra CHAR(4),
   ptipo_conciliacion INTEGER,
   pnumtarjeta CHAR(16),
   pnumcuenta CHAR(20),
   ptipotransaccion325 CHAR(2),
   pfolio_mov CHAR(16),
   pmonto325 money(16,2),
   pmoneda325 CHAR(2),
   pnomcomercio325 CHAR(30),
   prfc325 CHAR(15),
   preferencia23_325 CHAR(23),
   pdivisa325 CHAR(3),
   pmonto_divisa325 money(16,2),
   pidterminal CHAR(16),
   ptipo_mov CHAR,
   pconsecutivo INTEGER,
   pnombrearchivo CHAR(23)
)
RETURNING VARCHAR(6),VARCHAR(80),INTEGER,CHAR(4),INTEGER, VARCHAR(1);

DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);
DEFINE  P_COD_RET        VARCHAR(6);
DEFINE  P_MENSAJE        VARCHAR(80);
DEFINE  P_BANDERA        VARCHAR(1);
DEFINE  vtransacion      CHAR(4);
DEFINE  vsistema_aplica  CHAR;
DEFINE  vtransaparencia  VARCHAR(40);
DEFINE  vformaaplica     CHAR;
DEFINE  vid_proceso      INTEGER;
DEFINE vsNuevaSecuencia VARCHAR(6);
DEFINE vFech_param  DATE;

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
      RETURN P_COD_RET, P_MENSAJE,vid_proceso,vtransacion, ptipo_conciliacion, P_BANDERA;
   END EXCEPTION;

--*****************************************************************
-- APLICACION DE SALDOS                                         --*
-- Creado por: Manuel Osuna Valencia                            --*
-- Fecha: 20/07/2011                                            --*
-- Funcion: Recibe Registros para Aplicar Saldo  a los   		--*
-- clientes (cargo o abono) en lntegral 						--*
--*****************************************************************
-- Modificado por: Manuel Osuna Valencia                        --*
-- Fecha: 05/10/2011                                            --*
-- Funcion: Se modifico para que contabilizara el numero y saldo--*
-- de cargos o abanos que realizara por cada archivo            --*
--*****************************************************************
-- Modificado por: Manuel Osuna Valencia                        --*
-- Fecha: 17/10/2011                                            --*
-- Funcion: Se modifico para especificar bien el campo en el que--*
-- se estara sumarizando los cargos o abanos que realizara      --*
-- por cada archivo                                             --*
--*****************************************************************
-- Modificado por: Manuel Osuna Valencia                        --*
-- Fecha: 27/03/2012                                            --*
-- Funcion: Se modifico parametro de entrada fecha para que el  --*
-- proceso actualizará, fecha y hora, asi como tambien en el    --*
-- proceso cuando el sistema sea Credito y el tipo de conciliacion
-- sea igual a 1 o 10 la forma aplica sería igual a "B"         --*
--*****************************************************************
--*****************************************************************
-- Modificado por: Arturo Méndez Cárdenas                       --*
-- Fecha: 17/04/2012                                            --*
-- Funcion: Se modifico para que se ejecute el SP conciliadebito--*
-- solo cuando el tipo de conciliacion sea igual a 11 ó 14		--*
--*****************************************************************
-- Modificado por: CASANOVA EDEZA HECTOR JUAN                   --*
-- Fecha: 19/04/2012                                            --*
-- Funcion: SE MODIFICO LA LOGICA PARA LA APLICACION DE LAS     --*
-- DEVOLUCIONES, PARA QUE PERMITA APLICAR TODAS LAS TRANSACCIONES --* 
-- MENOS LOS ABONOS/DEVOLUCIONES CON TIPO_CONCILIACION  10 O 12 --*
--*****************************************************************
-- Modificado por: CASANOVA EDEZA HECTOR JUAN                   --*
-- Fecha: 01/10/2012                                            --*
-- Funcion: SE MODIFICA LA LOGICA PARA PERMITIR LAS 			--*
-- TRANSACCIONES TIPO 20 EN LOS ARCHIVOS VIC(MONEYGRAM) Y 		--*
-- REALIZAR EL ABONO CON LA TRANSACCION CORRESPONDIENTE.		--*
--*****************************************************************

--SET DEBUG FILE TO "/home/sysconau/conciliacion/aplica_sif.sql";
--TRACE ON;

	LET P_COD_RET = '00000';
	LET P_MENSAJE = 'PROCESO EXITOSO';

	LET vid_proceso = '7';
	LET P_BANDERA = '';

	LET vsistema_aplica = psistema;
	LET vformaaplica = '';
	LET vtransaparencia = '';

	LET vtransacion = '';
   
	LET vsNuevaSecuencia = '';
    LET vFech_param = " ";

     -- // OBTENGO PARAMETROS
	SELECT FIRST 1 fecha_hoy - 10 UNITS DAY
	INTO vFech_param
	FROM bdinteg:"informix".si_fechas
	WHERE empresa = '001';

	IF (NOT((pTipo_Mov = 'A') AND (pTipo_Conciliacion IN ('10','12')))) THEN --SE APLICAN LOS ABONOS QUE NO TENGAN ESTATUS DEV. CONCILIADA(12) NI DEV. NO APLICADA(10)
	 
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		--OBTIENE EL NUMERO DE CUENTA RELACIONADO A LA TARJETA
		SELECT FIRST 1 NumCuenta
		INTO pnumcuenta
		FROM Intercard:"informix".tarjetacuenta
		WHERE numtarjeta = pnumtarjeta;
	 
		IF (ptipo_conciliacion IN (1,2,3,4,5) ) THEN 
			LET vtransacion  =  ptran_car ;

		ELIF (ptipo_conciliacion IN (8,13)) THEN 

			LET vtransacion  =  ptran_for ;

		ELIF (ptipo_conciliacion IN (10,11, 14)) THEN 

			LET vtransacion  =  ptran_abo ;

		ELIF ( ptipo_conciliacion == 0 AND ptipotransaccion325 == 20) THEN --PNC y VIC (MONEYGRAM)

			LET vtransacion  = CASE WHEN (parchivo_origen = 'PNC') THEN ptran_abo /*PNC*/ 
									WHEN (parchivo_origen = 'VID') THEN ptran_Extra /*VID*/
									ELSE ptran_abo /*DEFAULT*/ END;
			
			LET ptipo_mov = 'A'; -- ABONOS [A]
			
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			--OBTIENE UNA SECUENACIA DE AUTORIZACION PARA TRANSACCIONES QUE NO PASAN POR EL AUTORIZADOR
			EXECUTE PROCEDURE Intercard:"informix".sp_GetSecuencia (CASE WHEN (parchivo_origen = 'PNC') THEN 22 /*PNC*/ 
																		 WHEN (parchivo_origen = 'VID') THEN 23 /*VID*/
																		 ELSE 22 /*DEFAULT*/ END ) 
			INTO vsNuevaSecuencia; -- GENERA UNA SECUENCIA
			
			--GENERA EL FOLIO_MOV PARA EL PNC [iMMDD3secuencia]
			LET pfolio_mov = 'i' || REPLACE (SUBSTRING (CURRENT::DATE FROM 1 FOR 5), '/', '' ) || REPLACE (SUBSTRING (CURRENT FROM 12 FOR 6), ':', '' ) || '3' || LPAD ( TRIM ( vsNuevaSecuencia ), 6, '0' );
			
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			--ACTUALIZA EL NUMERO DE CUENTA DE LOS REGISTROS QUE NO LO TIENEN (POS)
			UPDATE BdiTarjeta:"informix".Td_Movimientos_Conciliacion
			SET NumCuenta = pnumcuenta, 
			Tipo_Mov = ptipo_mov, -- ABONOS [A]
			Folio_Mov = pfolio_mov -- FOLIO PARTICULAR PARA PNC
			WHERE nombrearchivo = pnombrearchivo 
			AND consecutivo = pconsecutivo;
			
			
		ELSE --NINGUN CASO CONCUERDA
			LET vtransacion = '';
			LET psistema = '';
		END IF;

		--ASEGURA EL BLOQUE TRANSACCION, ANTES DE ABONO_REF Y CARGO_REF
		COMMIT WORK;
		BEGIN WORK;
		
		IF ((vtransacion <> '') AND (psistema <> '')) THEN
		
			IF (psistema == "D" ) THEN
			--insert into bditarjeta:td_conciliadebito values ('001',pnumtarjeta,'9290',pusuario,ptipo_mov,vtransacion,pfolio_mov,pmonto325,pmoneda325,pnomcomercio325,'000000000000000',prfc325,preferencia23_325);
				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;
				   
				  
				IF (parchivo_origen == 'TCD') THEN --AGREGA COPPEL AL NOMBRE DE COMERCIO PARA LOS ARCHIVOS TCC Y TCD
					LET pnomcomercio325 = 'COPPEL ' || TRIM(pnomcomercio325);
				END IF
				
				-- AQUI SE MODIFICARÁ (EJECUTAR sp CUANDO TIPO_CONCILIACION IN(11,14), 
				-- Y VALIDAR EL RESULTADO(SI ES 15 PONER EL ERROR INESPERADO))
				
				EXECUTE PROCEDURE bdicheq:"informix".conciliadebito('001',pnumtarjeta,'9290',pusuario,ptipo_mov,vtransacion,pfolio_mov,pmonto325,pmoneda325,pnomcomercio325,'000000000000000',prfc325,preferencia23_325) INTO P_COD_RET,P_BANDERA;
					
				IF (parchivo_origen == 'VND') THEN

					LET vtransaparencia  = TRIM(prfc325) || ' ' || TRIM(pnomcomercio325) ||' ' || SUBSTR(NVL(pfolio_mov,''),11,6);

				ELIF (parchivo_origen == 'VID') THEN

					LET vtransaparencia  = TRIM(pnomcomercio325) || ' ' || SUBSTR(NVL(pfolio_mov,''),11,6)|| ' ' || pmonto_divisa325 || ' ' || pdivisa325;

				ELIF (parchivo_origen == 'TCD') THEN
					--i123120311794341
					LET vtransaparencia  = TRIM(prfc325) || ' ' || TRIM(pnomcomercio325) || ' ' || SUBSTR(NVL(pfolio_mov,''),11,6);
					
				ELIF (parchivo_origen == 'TMD') THEN

					LET vtransaparencia  = pidterminal;

				END IF;

				IF (TRIM(vtransaparencia) <> '') THEN 
					IF (P_BANDERA == 'C') THEN
						
						--REGISTRA LA REFERENCIA DE LA OPERACION EN MOVHIS
                        IF (parchivo_origen == 'TMD') THEN
                            
							UPDATE {+INDEX(bdicheq:sc_movhis idx_movhisnew4)}
                            bdicheq:"informix".sc_movhis  
                            SET  referencia = TRIM(NVL(referencia,'')) || vtransaparencia 
                            --WHERE empresa = '001' and cuenta = TRIM(pnumcuenta) AND folio_suc = TRIM(pfolio_mov);
                            WHERE fech_alt >= vFech_param
                            AND transacc = vtransacion
                            AND empresa = '001'
					        AND cuenta = TRIM(pnumcuenta)					        
					        AND cancelad <> "S"					        
					        AND folio_suc = TRIM(pfolio_mov);
										
                        ELSE						
						
						    UPDATE {+INDEX(bdicheq:sc_movdia idx_movdia7a)}
                            bdicheq:"informix".sc_movdia  
                            SET  referencia = TRIM(NVL(referencia,'')) || vtransaparencia 
                            WHERE folio_suc = TRIM(pfolio_mov) and cuenta = TRIM(pnumcuenta);
							
                        END IF;
						
						
		
					ELIF (P_BANDERA == 'A') THEN
						
						
						--REGISTRA LA REFERENCIA DE LA OPERACION EN MOVDIA
						UPDATE {+INDEX(bdicheq:sc_movdia idx_movdia7a)}
                        bdicheq:"informix".sc_movdia 
                        SET  referencia = referencia || vtransaparencia 
                        WHERE folio_suc = TRIM(pfolio_mov) and cuenta = TRIM(pnumcuenta);

					END IF;
				END IF;
				
				--ACTUALIZA EL REGISTRO COMO APLICADO
				UPDATE bditarjeta:"informix".td_movimientos_conciliacion 
                SET  aplicacion = 'V',transaccion_aplica = vtransacion,bandera_proceso = 'C',cod_retorno = '000',fechaaplica = current, cve_usuario = pusuario 
                WHERE nombrearchivo = pnombrearchivo AND consecutivo = pconsecutivo;
				
				IF ( ptipo_conciliacion IN (8,13) ) THEN

					UPDATE {+INDEX(bdicheq:sc_movdia idx_movdia7a)}
                    bdicheq:"informix".sc_movdia  
                    SET  referencia = preferencia23_325  
                    WHERE folio_suc = TRIM(pfolio_mov) and cuenta = TRIM(pnumcuenta);
					
				ELIF ( ptipo_conciliacion = 0) THEN  --   Para agregar referencia para Money Gram
				
					UPDATE {+INDEX(bdicheq:sc_movdia idx_movdia7a)}
                    bdicheq:"informix".sc_movdia  
                    SET  referencia = SUBSTR(NVL(preferencia23_325,''),15,9) 
                    WHERE folio_suc = TRIM(pfolio_mov) and cuenta = TRIM(pnumcuenta);
				
				-- Se separa Para poner la ley de transparanecia cuando son devoluciones del dia 
				
				ELIF ( ptipo_conciliacion = 11) and (parchivo_origen in ('VID', 'VND') )  THEN

					UPDATE {+INDEX(bdicheq:sc_movdia idx_movdia7a)}
                    bdicheq:"informix".sc_movdia  
                    SET  referencia = TRIM(NVL(referencia,'')) || vtransaparencia
                    WHERE folio_suc = TRIM(pfolio_mov) and cuenta = TRIM(pnumcuenta);
		
				END IF;

				IF (P_COD_RET <> '000') THEN

					--ACTUALIZA EL ESTATUS DE LA APLICACION
					UPDATE bditarjeta:"informix".td_movimientos_conciliacion  
							SET tipo_conciliacion = (CASE WHEN((pTipo_Mov = 'A') AND (pTipo_Conciliacion IN ('11','14'))) THEN 15 ELSE tipo_conciliacion END), 
							aplicacion = 'F',transaccion_aplica = vtransacion,bandera_proceso = 'E',fechaaplica = current, cve_usuario = pusuario,cod_retorno = P_COD_RET 
						WHERE nombrearchivo = pnombrearchivo 
					AND consecutivo = pconsecutivo;
					
					LET ptipo_conciliacion = (CASE WHEN((pTipo_Mov = 'A') AND (pTipo_Conciliacion IN ('11','14'))) THEN 15 ELSE ptipo_conciliacion END);
					
				END IF;

		ELIF (psistema == 'C' ) THEN

				--IF ( ptipo_conciliacion == 1  ) THEN
				IF ( ptipo_conciliacion IN (1,2,3,4,5)) THEN 
					LET vformaaplica  =  "B" ;   -- Cuando los datos corresponden completamente 
				--ELIF ( ptipo_conciliacion IN (2,3,4,5,11,14)) THEN 
				ELIF ( ptipo_conciliacion IN (13)) THEN 
					LET vformaaplica  =  "X" ; --Cuando hay diferencias en los montos del 325 a los de Intercard
				ELIF ( ptipo_conciliacion IN (0,8,11,14)) THEN 
					LET vformaaplica  =  "A" ; -- Cuando Hay que aplicar forzados los movimientos 
				END IF;
				
				-- La '6' no se clasifica ya que no debe paras a aplicacion por ser un movimiento que se detecto como previa mente conciliado
				-- La '7' no se clasifica por hacer referencia a una operacion reversada donde el campo formato es igual a 0420
				-- La '9' no se clasifica ya que al estar rechazado el movimiento original no procede su conciliacion para la aplicacion
				-- La '10' no se aplica la devolucion ya que al no cuprir todos los requisitos solamente habre de clasificarse por inprocedencia
				-- La '12' no se clasifica ya que al ser una devolucion que no aplica por errores de integridad
				-- La '13' no se clasifica por hacer referencia a una operacion reversada donde el campo formato es igual a 0220
				-- Lo 15 no se clasifica por estar marcada como error 
				-- La 16 no se aplica por ser de una cartera vendida 

				--insert into bditarjeta:td_conciliatc values ('001',pnumtarjeta,'9290',pusuario,ptipo_mov,vtransacion,pfolio_mov,pmonto325,pmoneda325,pnomcomercio325,'000000000000000',vformaaplica,prfc325,preferencia23_325);
				
				IF (parchivo_origen == 'TCC') THEN --AGREGA COPPEL AL NOMBRE DE COMERCIO PARA LOS ARCHIVOS TCC Y TCD
					LET pnomcomercio325 = 'COPPEL ' || TRIM(pnomcomercio325);
				END IF
				
				EXECUTE PROCEDURE bdicred:"informix".conciliatc('001',pnumtarjeta,'9290',pusuario,ptipo_mov,vtransacion,pfolio_mov,pmonto325,pmoneda325,pnomcomercio325,'000000000000000',vformaaplica,prfc325,preferencia23_325) INTO P_COD_RET,P_BANDERA;

				IF (parchivo_origen == "VNC") THEN

					LET vtransaparencia  = TRIM(prfc325) || ' ' || TRIM(pnomcomercio325);

				ELIF (parchivo_origen == "VIC") THEN

					LET vtransaparencia  = pmonto_divisa325 || ' ' || pdivisa325;

				ELIF (parchivo_origen == 'TCC') THEN
					--i123120311794341
					LET vtransaparencia  = TRIM(pnomcomercio325) || ' ' || SUBSTR(NVL(pfolio_mov,''),11,6);
					
				ELIF (parchivo_origen == "TMC") THEN

					LET vtransaparencia  = pidterminal;

				END IF;

				IF (TRIM(vtransaparencia) <> '') THEN 
					IF (P_BANDERA == "C") THEN
						--REGISTRA LA REFERENCIA DE LA OPERACION EN MOVHIS
						IF(parchivo_origen == 'TMC') THEN
						
                            UPDATE {+INDEX(bdicred:sd_movhis inx_movhis4)}
                            bdicred:"informix".sd_movhis  
                            SET  referencia = TRIM(referencia) || vtransaparencia 
                            WHERE empresa = '001' and fecha_mov is not null and
                            num_credito = TRIM(pnumcuenta) AND folio_suc = TRIM(pfolio_mov);
							
                        ELSE
						
                            UPDATE {+INDEX(bdicred:sd_movdia mov3)}
                            bdicred:"informix".sd_movdia 
                            SET  referencia = referencia || vtransaparencia 
                            WHERE empresa = '001' and num_credito = TRIM(pnumcuenta) AND folio_suc = TRIM(pfolio_mov);
							
						END IF;
						
					
					ELIF (P_BANDERA == "A") THEN
						
						UPDATE {+INDEX(bdicred:sd_movdia mov3)}
                        bdicred:"informix".sd_movdia 
                        SET  referencia = referencia || vtransaparencia 
                        WHERE empresa = '001' and num_credito = TRIM(pnumcuenta) AND folio_suc = TRIM(pfolio_mov);
						
					END IF;
				END IF;

				--ACTUALIZA EL REGISTRO COMO APLICADO
				UPDATE bditarjeta:"informix".td_movimientos_conciliacion  SET  aplicacion = 'V',transaccion_aplica = vtransacion,bandera_proceso = 'C',cod_retorno = '000',fechaaplica = current, cve_usuario = pusuario   WHERE nombrearchivo = pnombrearchivo AND consecutivo = pconsecutivo;				
				
				--   Para aplicar ley de transparencia a los registros de 
				IF ( ptipo_conciliacion == 11 ) and (parchivo_origen IN ('VIC', 'VNC'))  THEN
						
						UPDATE {+INDEX(bdicred:sd_movdia mov3)}
                        bdicred:"informix".sd_movdia 
                        SET  referencia = referencia || vtransaparencia 
                        WHERE empresa = '001' and num_credito = TRIM(pnumcuenta) AND folio_suc = TRIM(pfolio_mov);

				END IF;	 
				
				IF (P_COD_RET <> "000") THEN
					
					--ACTUALIZA EL ESTATUS DE LA APLICACION
					UPDATE bditarjeta:"informix".td_movimientos_conciliacion  
							SET tipo_conciliacion = (CASE WHEN((pTipo_Mov = 'A') AND (pTipo_Conciliacion IN ('11','14'))) THEN 15 ELSE tipo_conciliacion END), 
							aplicacion = 'F',
							transaccion_aplica = vtransacion,
							bandera_proceso = 'E',
							fechaaplica = current,
							cve_usuario = pusuario,
							cod_retorno = P_COD_RET 
						WHERE nombrearchivo = pnombrearchivo 
						AND consecutivo = pconsecutivo;
						
					LET ptipo_conciliacion = (CASE WHEN((pTipo_Mov = 'A') AND (pTipo_Conciliacion IN ('11','14'))) THEN 15 ELSE ptipo_conciliacion END);

				END IF;

			END IF;
		   
		   
			IF ((P_COD_RET == '000') AND (ptipo_mov == 'C')) THEN --INCREMENTA EL NUMERO DE CARGOS APLICADOS
			
				UPDATE bditarjeta:"informix".td_archivos_conciliacion SET num_cargo = num_cargo + 1,monto_cargo = monto_cargo + pmonto325 WHERE nombrearchivo = pnombrearchivo;
				
			ELIF ((P_COD_RET == '000') AND (ptipo_mov == 'A')) THEN --INCREMENTA EL NUMERO DE ABONOS APLICADOS
			
				UPDATE bditarjeta:"informix".td_archivos_conciliacion SET num_abono = num_abono + 1,monto_abono = monto_abono + pmonto325 WHERE nombrearchivo = pnombrearchivo;
				
			END IF;	
			
		ELSE --TRANSACCIONES KE NO SE PROCESAN (CARGO O ABONO) 
			-- NO REALIZA EL PROCESO DE APLICACION Y ESTABLECE EL REGISTRO COMO FINALIZADO DE PROCESAR
			LET P_COD_RET = '00000'; 
		END IF;
	ELSE -- DEVOLUCIONES QUE NO APLICAN
		-- NO REALIZA EL PROCESO DE APLICACION Y ESTABLECE EL REGISTRO COMO FINALIZADO DE PROCESAR
		LET P_COD_RET = '00000'; 
	END IF;

	
   RETURN LPAD(TRIM(P_COD_RET), 5, '0'),P_MENSAJE,vid_proceso,vtransacion, ptipo_conciliacion, P_BANDERA;
   
END;
END PROCEDURE
DOCUMENT
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Luis Gomez Santiago',
'Descripcion: SE MODIFICO LA LOGICA PARA LA APLICACION DE LAS DEVOLUCIONES, PARA QUE PERMITA APLICAR TODAS LAS TRANSACCIONES MENOS LOS ABONOS/DEVOLUCIONES CON TIPO_CONCILIACION  10 O 12.',
'Fecha: 2012/04/19',
'Version: 20120419.1756',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion -DEVOLUCIONES',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICA LA LOGICA PARA QUE NO PERMITA PROCESAR LAS OPERACIONES DE TIPOS NO RELACIONADOS CON EL PROCESO DE CARGO Y ABONO.',
'Fecha: 2012/05/21',
'Version: 20120521.1547',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AGREGA EL PARAMETRO PARA MANDAR LA TRANSACCION DE CARGO.',
'Fecha: 2012/07/31',
'Version: 20120731.1214',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AJUSTA LA LOGICA PARA ASIGNAR LOS VALORES REQUERIDOS (TIPO_MOV Y CUENTA) A LOS REGISTROS DE PNC PARA SU APLICACION.',
'Fecha: 2012/08/10',
'Version: 20120810.1051',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AGREGA LOGICA PARA GENERAR EL FOLIO_MOV PARA LOS REGISTROS PNC.',
'Fecha: 2012/08/13',
'Version: 20120813.1641',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICA LA LOGICA PARA ASIGNAR LA LEY DE TRANSPARENCIA PARA LOS REGISTROS DE TIENDAS COPPEL.',
'Fecha: 2012/09/19',
'Version: 20120919.1730',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICA LA LOGICA PARA OBTENER EL NUMERO DE CUENTA PARA TODOS LOS REGISTROS.',
'Fecha: 2012/09/20',
'Version: 20120920.1755',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICA LA LOGICA PARA GENERAR CAMPO DE TRANSPARENCIA PARA LOS REGISTROS DE VND Y VNC.',
'Fecha: 2012/09/26',
'Version: 20120926.1031',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICA LA LOGICA PARA PERMITIR LAS TRANSACCIONES TIPO 20 EN LOS ARCHIVOS VIC(MONEYGRAM) Y REALIZAR EL ABONO CON LA TRANSACCION CORRESPONDIENTE.',
'Fecha: 2012/10/01',
'Version: 20121001.1059',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: HOMOLOGACION DE CODIGO - INDICES',
'Fecha: 2012/10/12',
'Version: 20121012.1030',
'BD: BdiTarjeta',
'',
'MODIFICACION: Ricardo Reséndiz Martínez',
'Proyecto:  RQI 13 2XX Aplicación Ley de transparencia para registros de devoluciones forzadas',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Actualizacion de Ley de transparencia para la devoluciones forzadas',
'Fecha: 2013/02/11',
'Version: 20130205.1600',
'BD: Bditarjeta';

CREATE PROCEDURE "informix".sp_conarchivos_con_pba(cparam1 char(1),cTipo char(3),dfecha_ini date,dfecha_fin date,cUsuario char(10),cNumEmpl varchar(9))
RETURNING VARCHAR(6) as Cod_ret,VARCHAR(80) as Men_ret,
     char(23) as nombrearchivo,        
     char(3)  as archivo_origen,      
     date     as fecha_archivo, 
     integer  as num_registros325,
     money(16,2) as monto325,       
     date     as fecha_proceso,  
     datetime year to fraction(5)  as fecha_hora_transferencia,       
     datetime year to fraction(5)  as fecha_hora_ini_proceso,      
     datetime year to fraction(5)  as fecha_hora_carga_archivo,      
     datetime year to fraction(5)  as fecha_hora_carga_tabla,
     datetime year to fraction(5)  as fecha_hora_ini_concilia_reg,
     datetime year to fraction(5)  as fecha_hora_fin_concilia_reg,
     datetime year to fraction(5)  as fecha_hora_fin_proceso,
     datetime year to fraction(5)  as fecha_hora_gen_conadmin,
     char(1) as transferencia,
     char(1) as carga,
     char(1) as conadmin,
     integer as num_cargo,
     money(16,2)  as monto_cargo,
     integer as num_abono,
     money(16,2)  as monto_abono,
     char(1) as proceso;


	DEFINE  SQL_ERR          INTEGER;
	DEFINE  ISAM_ERR         INTEGER;
	DEFINE  ERROR_INFO       VARCHAR(80);
	DEFINE  P_COD_RET        VARCHAR(6);
	DEFINE  P_COD_RET2        VARCHAR(6);
	DEFINE  P_MENSAJE        VARCHAR(80);
	DEFINE c_nombrearchivo char(23);
	DEFINE c_archivo_origen char(3);
	DEFINE d_fecha_archivo date;
	DEFINE i_num_registros325 integer;
	DEFINE m_monto325 money(16,2);
	DEFINE d_fecha_proceso date;
	DEFINE d_fecha_hora_transferencia datetime year to fraction(5);
	DEFINE d_fecha_hora_ini_proceso datetime year to fraction(5);
	DEFINE d_fecha_hora_carga_archivo datetime year to fraction(5);
	DEFINE d_fecha_hora_carga_tabla datetime year to fraction(5);
	DEFINE d_fecha_hora_ini_concilia_reg datetime year to fraction(5);
	DEFINE d_fecha_hora_fin_concilia_reg datetime year to fraction(5);
	DEFINE d_fecha_hora_fin_proceso datetime year to fraction(5);
	DEFINE d_fecha_hora_gen_conadmin datetime year to fraction(5);
	DEFINE c_transferencia char(1);
	DEFINE c_carga char(1);
	DEFINE c_conadmin char(1);
	DEFINE i_num_cargo integer;
	DEFINE m_monto_cargo money(16,2);
	DEFINE i_num_abono integer;
	DEFINE m_monto_abono money(16,2);
	DEFINE c_proceso char(1);



	LET c_nombrearchivo = '';
	LET c_archivo_origen = '';
	LET d_fecha_archivo= '01-01-1900';
	LET i_num_registros325 = 0;
	LET m_monto325 = 0;
	LET d_fecha_proceso = '01-01-1900';
	LET d_fecha_hora_transferencia = '1900-01-01 00:00:00';
	LET d_fecha_hora_ini_proceso = '1900-01-01 00:00:00';
	LET d_fecha_hora_carga_archivo = '1900-01-01 00:00:00';
	LET d_fecha_hora_carga_tabla = '1900-01-01 00:00:00';
	LET d_fecha_hora_ini_concilia_reg = '1900-01-01 00:00:00';
	LET d_fecha_hora_fin_concilia_reg = '1900-01-01 00:00:00';
	LET d_fecha_hora_fin_proceso = '1900-01-01 00:00:00';
	LET d_fecha_hora_gen_conadmin = '1900-01-01 00:00:00';
	LET c_transferencia  = '';
	LET c_carga  = '';
	LET c_conadmin  = '';
	LET i_num_cargo  = 0;
	LET m_monto_cargo  = 0;
	LET i_num_abono  = 0;
	LET m_monto_abono  = 0;
	LET c_proceso  = '';
	
	--SET DEBUG FILE TO "/tmp/manuel/ejemplo_consarc";
	--TRACE ON;

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
	  
	  EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora('130','Error en sp_conarchivos_con ' || SQL_ERR || ' ' || P_MENSAJE,cNumEmpl) INTO P_COD_RET2;
      RETURN P_COD_RET,P_MENSAJE,c_nombrearchivo,c_archivo_origen,d_fecha_archivo,i_num_registros325,m_monto325,d_fecha_proceso,d_fecha_hora_transferencia,
				   d_fecha_hora_ini_proceso,d_fecha_hora_carga_archivo,d_fecha_hora_carga_tabla,d_fecha_hora_ini_concilia_reg,d_fecha_hora_fin_concilia_reg,
				   d_fecha_hora_fin_proceso,d_fecha_hora_gen_conadmin,c_transferencia,c_carga,c_conadmin,i_num_cargo,m_monto_cargo,i_num_abono,m_monto_abono,c_proceso;
   END EXCEPTION;

--************************************************************
-- Creado por Manuel Osuna Valencia 
-- fecha : 19/10/2011
-- Funcion: Consulta de Archivos de conciliación por fecha
--************************************************************

   LET P_COD_RET = '00000';
   LET P_COD_RET2 = '00000';
   LET P_MENSAJE = 'PROCESO EXITOSO';
   
   	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
   
   IF (cparam1 == 1) THEN --Consulta por Todos los archivos 

		FOREACH
						
			SELECT nombrearchivo,archivo_origen,fecha_archivo,num_registros325,monto325,fecha_proceso,fecha_hora_transferencia,
					fecha_hora_ini_proceso,fecha_hora_carga_archivo,fecha_hora_carga_tabla,fecha_hora_ini_concilia_reg,fecha_hora_fin_concilia_reg,
					fecha_hora_fin_proceso,fecha_hora_gen_conadmin,transferencia,carga,conadmin,num_cargo,monto_cargo,num_abono,monto_abono,proceso						
			INTO c_nombrearchivo,c_archivo_origen,d_fecha_archivo,i_num_registros325,m_monto325,d_fecha_proceso,d_fecha_hora_transferencia,
				 d_fecha_hora_ini_proceso,d_fecha_hora_carga_archivo,d_fecha_hora_carga_tabla,d_fecha_hora_ini_concilia_reg,d_fecha_hora_fin_concilia_reg,
				 d_fecha_hora_fin_proceso,d_fecha_hora_gen_conadmin,c_transferencia,c_carga,c_conadmin,i_num_cargo,m_monto_cargo,i_num_abono,m_monto_abono,c_proceso		
			FROM bditarjeta:"informix".td_archivos_conciliacion
			WHERE fecha_proceso BETWEEN dfecha_ini AND dfecha_fin
			
			
			RETURN P_COD_RET,P_MENSAJE,c_nombrearchivo,c_archivo_origen,d_fecha_archivo,i_num_registros325,m_monto325,d_fecha_proceso,d_fecha_hora_transferencia,
				   d_fecha_hora_ini_proceso,d_fecha_hora_carga_archivo,d_fecha_hora_carga_tabla,d_fecha_hora_ini_concilia_reg,d_fecha_hora_fin_concilia_reg,
				   d_fecha_hora_fin_proceso,d_fecha_hora_gen_conadmin,c_transferencia,c_carga,c_conadmin,i_num_cargo,m_monto_cargo,i_num_abono,m_monto_abono,c_proceso	with resume;	
								
		END FOREACH;
		
	ELIF (cparam1 == 2) THEN --Consulta un Archivo en especifico
	
		FOREACH
						
			SELECT nombrearchivo,archivo_origen,fecha_archivo,num_registros325,monto325,fecha_proceso,fecha_hora_transferencia,
					fecha_hora_ini_proceso,fecha_hora_carga_archivo,fecha_hora_carga_tabla,fecha_hora_ini_concilia_reg,fecha_hora_fin_concilia_reg,
					fecha_hora_fin_proceso,fecha_hora_gen_conadmin,transferencia,carga,conadmin,num_cargo,monto_cargo,num_abono,monto_abono,proceso						
			INTO c_nombrearchivo,c_archivo_origen,d_fecha_archivo,i_num_registros325,m_monto325,d_fecha_proceso,d_fecha_hora_transferencia,
				 d_fecha_hora_ini_proceso,d_fecha_hora_carga_archivo,d_fecha_hora_carga_tabla,d_fecha_hora_ini_concilia_reg,d_fecha_hora_fin_concilia_reg,
				 d_fecha_hora_fin_proceso,d_fecha_hora_gen_conadmin,c_transferencia,c_carga,c_conadmin,i_num_cargo,m_monto_cargo,i_num_abono,m_monto_abono,c_proceso		
			FROM bditarjeta:"informix".td_archivos_conciliacion
			WHERE 	archivo_origen = trim(cTipo)  
					and fecha_proceso BETWEEN dfecha_ini AND dfecha_fin 
			
			
			RETURN P_COD_RET,P_MENSAJE,c_nombrearchivo,c_archivo_origen,d_fecha_archivo,i_num_registros325,m_monto325,d_fecha_proceso,d_fecha_hora_transferencia,
				   d_fecha_hora_ini_proceso,d_fecha_hora_carga_archivo,d_fecha_hora_carga_tabla,d_fecha_hora_ini_concilia_reg,d_fecha_hora_fin_concilia_reg,
				   d_fecha_hora_fin_proceso,d_fecha_hora_gen_conadmin,c_transferencia,c_carga,c_conadmin,i_num_cargo,m_monto_cargo,i_num_abono,m_monto_abono,c_proceso	with resume;	
								
		END FOREACH;
		
	
 	
   
	END IF;

     
	
  
END;
END PROCEDURE
DOCUMENT
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Luis Gomez Santiago',
'Descripcion: SE MODIFICA EL FILTRO DE LA CONSULTA PARA UTILIZAR EL CAMPO DE FECHA PROCESO EN LUGAR DE FECHA ARCHIVO',
'Fecha: 2012/10/08',
'Version: 20121008.1830',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_concreing_consultamovpendientes_pba ( psCve_usuario CHAR(10), psFecha DATE )
	RETURNING CHAR (5) AS Retorno, 
	INTEGER AS Consecutivo,
	CHAR(23) AS NombreArchivo,
	CHAR(3) AS ArchivoOrigen,
	CHAR(1) AS Integridad,
	CHAR(20) AS IntegridadError,
	CHAR(16) AS NumTarjeta,
	CHAR(6) AS Secuencia,
	CHAR(9) AS IdComercio325,
	CHAR(30) AS NomComercio325,
	CHAR(23) AS Referencia23_325,
	CHAR(13) AS Monto ,
	CHAR(15) as Rfc325,
	CHAR(3) AS Divisa325,
	MONEY(14,2) AS MontoCashBack ,
	CHAR(1) AS Conciliacion ,
	INTEGER AS TipoConciliacion,
	CHAR(15) AS SecuenciaExtendida,
	MONEY(16,2) AS MontoIntercard,
	CHAR(1) AS MovConciliado ,
	CHAR(1) AS MovReversado ,
	CHAR(1) AS Aplicacion ,
	CHAR(16) AS FolioAplica ,
	CHAR(5) AS CodigoRetorno,
	CHAR(15) AS TipoTransaccion325,
	CHAR(13) AS Monto325,
	CHAR(1) AS BanderaProceso;
	
	/*
	*****************************************************************************************************
	-- DESCRIPCION:  CONSULTA DE MOVIMIENTOS PENDIENTES  ------------------------------------------------
	-- AUTOR : Ing. Alfonso Cruz  -----------------------------------------------------------------------
	-- FECHA : 24/10/2011  ------------------------------------------------------------------------------
	-- BD: bditarjeta  ----------------------------------------------------------------------------------
	-- SISTEMA : Reingenieria de la conciliacion automatica  --------------------------------------------
	-----------------------------------------------------------------------------------------------------
	*****************************************************************************************************
	*/

	/*VARIABLES DE ERRORES*/
	DEFINE vsErrorIntegridad CHAR(20);
	DEFINE vsErrorActividad	CHAR(250);
	DEFINE vsRetBitacora CHAR(5);
	
	DEFINE vsActividad VARCHAR(150);
	DEFINE viElemento INTEGER;

	DEFINE viCodigo INTEGER;
	DEFINE vssqlerr CHAR(5) ;
	DEFINE isam_err INT ;
	DEFINE error_info CHAR(70) ;
	DEFINE viErrores INTEGER;
	
	DEFINE viConsecutivo INTEGER;
	DEFINE vsNombreArchivo CHAR(23);
	DEFINE vsArchivoOrigen CHAR(3);
	DEFINE vsIntegridad CHAR(1);
	DEFINE vsIntegridadError CHAR(20);
	DEFINE vsNumTarjeta CHAR(16);
	DEFINE vsSecuencia CHAR(6);
	DEFINE vsIdComercio325 CHAR(9);
	DEFINE vsNomComercio325 CHAR(30);
	DEFINE vsReferencia23_325 CHAR(23);
	DEFINE vsMonto CHAR(13);
	DEFINE vsRfc325 CHAR(15);
	DEFINE vsDivisa325 CHAR(3);
	DEFINE vmMontoCashBack MONEY(14,2);
	DEFINE vsConciliacion CHAR(1);
	DEFINE viTipoConciliacion INTEGER;
	DEFINE vsSecuenciaExtendida CHAR(15);
	DEFINE vmMontoIntercard MONEY(16,2);
	DEFINE vsMovConciliado CHAR(1);
	DEFINE vsMovReversado CHAR(1);
	DEFINE vsAplicacion CHAR(1);
	DEFINE vsFolioAplica CHAR(16);
	DEFINE vsCodigoRetorno CHAR(5);
	
	DEFINE vsTipotransaccion325 CHAR(15);
	DEFINE vsMonto325 CHAR(13);
	DEFINE vsBanderaProceso CHAR(1);
	/* INICIALIZACION DE VARIABLES */

	LET vsIntegridad = '';
	LET vsErrorIntegridad = '';
	LET vsErrorActividad = '';
	
	LET  vsRetBitacora = '';
	
	LET vsActividad = '';
	LET viElemento = 40;
	
	LET viCodigo = 0;
	LET vssqlerr = '00000';
	LET isam_err = 0 ;
	LET error_info = '' ;
	LET viErrores = 0;
	
	LET viConsecutivo = 0;
	LET vsNombreArchivo ='';
	LET vsArchivoOrigen ='';
	LET vsIntegridad ='';
	LET vsIntegridadError ='';
	LET vsNumTarjeta ='';
	LET vsSecuencia ='';
	LET vsIdComercio325 = "";
	LET vsNomComercio325 = "";
	LET vsReferencia23_325 = "";
	LET vsMonto ='';
	LET vsRfc325 ='';
	LET vsDivisa325 ='';
	LET vmMontoCashBack =0.0;
	LET vsConciliacion ='';
	LET viTipoConciliacion =0;
	LET vsSecuenciaExtendida ='';
	LET vmMontoIntercard =0.0;
	LET vsMovConciliado ='';
	LET vsMovReversado ='';
	LET vsAplicacion ='';
	LET vsFolioAplica ='';
	LET vsCodigoRetorno = '';
	LET vsBanderaProceso = '';
	
	LET vsTipotransaccion325 = '';
	LET vsMonto325 = '';
	
	BEGIN

	ON EXCEPTION SET viCodigo,isam_err,error_info   --cacha el error en caso de que exista y regresa un valor predeterminado
		LET vssqlerr = viCodigo;
		LET vsActividad = 'ERROR ' || NVL(vssqlerr,'') ||' ISAM '|| NVL(isam_err,0) ||' INFORMIX '||TRIM(NVL(error_info,'')) || ' EN sp_concreing_consultamovpendientes';
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora(viElemento,vsActividad,psCve_usuario) INTO vsRetBitacora;
			

		RETURN NVL(vssqlerr,''), 
			NVL(viConsecutivo,0),
			NVL(vsNombreArchivo,''),
			NVL(vsArchivoOrigen,''),
			NVL(vsIntegridad,''),
			NVL(vsIntegridadError,''),
			NVL(vsNumTarjeta,''),
			NVL(vsSecuencia,''),
			NVL(vsIdComercio325,''),
			NVL(vsNomComercio325,''),
			NVL(vsReferencia23_325,''),
			NVL(vsMonto,''),
			nvl(vsRfc325,''),
			nvl(vsDivisa325,''),
			NVL(vmMontoCashBack,0.0),
			NVL(vsConciliacion,''),
			NVL(viTipoConciliacion,0),
			NVL(vsSecuenciaExtendida,''),
			NVL(vmMontoIntercard,''),
			NVL(vsMovConciliado,''),
			NVL(vsMovReversado,''),
			NVL(vsAplicacion,''),
			NVL(vsFolioAplica,''),
			NVL(vsCodigoRetorno,''),
			NVL(vsTipotransaccion325,''),
			NVL(vsMonto325,''),
			NVL(vsBanderaProceso,'');

	END EXCEPTION;

	--SET DEBUG FILE TO '/home/sysifx/soporte/concreing/TraceCONSULTAMOVPENDIENTES.sql';
	--SET DEBUG FILE TO '/informix/HomeInformix/rrm/movpen.txt';
	--TRACE ON;

	--REINGENIERIA-CONCILIACION-AUTOMATICA---------
	--2011/10/24-ING-ALFONSO-CRUZ------------------

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;

		--CONSULTA QUE SE TRAE LOS REGISTROS PENDIENTES
	IF psCve_usuario not in ( 
							'93616902', -- Evelio Chaparro García 
							'92580981', -- Jose Armando Ongay Miramontes
							'92933122', -- Deisy Denise Sotelo Pérez
							'93176953',	-- Jose Antonio de la Paz Nieto                     
							'94621713', -- Oscar Daniel Romero Hernandez             
							'95116613'  -- Lizbeth Trinidad Sepulveda                        
							) THEN  	-- Usuarios con capacidad de modificar registros a su criterio 
		-- Se mantienen registros de todos los archivos 
		FOREACH 
			SELECT consecutivo, nombrearchivo, archivo_origen, 
				integridad, 
				integridad_error, numtarjeta, secuencia325, idcomercio325, 
				REPLACE (REPLACE (nomcomercio325,"'", " "),'"' , ' '), 
				referencia23_325,
				monto325, rfc325, divisa325, montosurcharge325, conciliacion, tipo_conciliacion,
				secuencia_extendida, montointercard, movconciliado, movreversado, aplicacion, folio_mov,
				cod_retorno, tipotransaccion325, monto325, bandera_proceso 
				INTO viConsecutivo, 
				 vsNombreArchivo, vsArchivoOrigen, vsIntegridad, vsIntegridadError, vsNumTarjeta, vsSecuencia,
				 vsIdComercio325, vsNomComercio325, 
				 vsReferencia23_325, vsMonto, vsRfc325, vsDivisa325, vmMontoCashBack,
				 vsConciliacion, viTipoConciliacion, vsSecuenciaExtendida, vmMontoIntercard, vsMovConciliado, vsMovReversado,
				 vsAplicacion, vsFolioAplica, vsCodigoRetorno, vsTipotransaccion325, vsMonto325, vsBanderaProceso
				FROM bditarjeta:td_movimientos_conciliacion	
				WHERE (integridad='F' OR conciliacion = 'F'	OR aplicacion =  'F') 
					   and nombrearchivo in (SELECT nombrearchivo 
											 FROM bditarjeta:td_archivos_conciliacion  
											 WHERE fecha_archivo = psFecha)
			
			IF ((vsSecuencia IS NULL)OR(TRIM(vsSecuencia) ='' ) ) THEN
				LET viErrores = viErrores + 1;
			END IF;
				
		RETURN NVL(vssqlerr,''), 
			NVL(viConsecutivo,0),
			NVL(vsNombreArchivo,''),
			NVL(vsArchivoOrigen,''),
			NVL(vsIntegridad,''),
			NVL(vsIntegridadError,''),
			NVL(vsNumTarjeta,''),
			NVL(vsSecuencia,''),
			NVL(vsIdComercio325,''),
			NVL(vsNomComercio325,''),
			NVL(vsReferencia23_325,''),
			NVL(vsMonto,''),
			nvl(vsRfc325,''),
			nvl(vsDivisa325,''),
			NVL(vmMontoCashBack,0.0),
			NVL(vsConciliacion,''),
			NVL(viTipoConciliacion,0),
			NVL(vsSecuenciaExtendida,''),
			NVL(vmMontoIntercard,''),
			NVL(vsMovConciliado,''),
			NVL(vsMovReversado,''),
			NVL(vsAplicacion,''),
			NVL(vsFolioAplica,''),
			NVL(vsCodigoRetorno,''),
			NVL(vsTipotransaccion325,''),
			NVL(vsMonto325,''),
			NVL(vsBanderaProceso,'')
			WITH RESUME;
			
		END FOREACH;
	ELSE
		FOREACH 
			SELECT consecutivo, nombrearchivo, archivo_origen, 
				REPLACE (REPLACE (integridad,'P', 'F'),'V', 'F'), -- Cambia para poder reprocesar los registros con aplicacion en P
				integridad_error, numtarjeta, secuencia325, idcomercio325, 
				REPLACE (REPLACE (nomcomercio325,"'", " "),'"' , ' '), 
				referencia23_325,
				monto325, rfc325, divisa325, montosurcharge325, conciliacion, tipo_conciliacion,
				secuencia_extendida, montointercard, movconciliado, movreversado, aplicacion, folio_mov,
				cod_retorno, tipotransaccion325, monto325, bandera_proceso 
				INTO viConsecutivo, 
				 vsNombreArchivo, vsArchivoOrigen, vsIntegridad, vsIntegridadError, vsNumTarjeta, vsSecuencia,
				 vsIdComercio325, vsNomComercio325, 
				 vsReferencia23_325, vsMonto, vsRfc325, vsDivisa325, vmMontoCashBack,
				 vsConciliacion, viTipoConciliacion, vsSecuenciaExtendida, vmMontoIntercard, vsMovConciliado, vsMovReversado,
				 vsAplicacion, vsFolioAplica, vsCodigoRetorno, vsTipotransaccion325, vsMonto325, vsBanderaProceso
				FROM bditarjeta:td_movimientos_conciliacion	
				WHERE (integridad='F' OR conciliacion = 'F'	OR aplicacion <> 'V') -- Se mostrar los registros hasta que estos sean reprocesados por el cron 3
					   and nombrearchivo in (SELECT nombrearchivo 
											 FROM bditarjeta:td_archivos_conciliacion  
											 WHERE fecha_archivo = psFecha)
					   and archivo_origen in ('VNC', 'VND', 'VID', 'VIC')
			
			IF ((vsSecuencia IS NULL)OR(TRIM(vsSecuencia) ='' ) ) THEN
				LET viErrores = viErrores + 1;
			END IF;
				
		RETURN NVL(vssqlerr,''), 
			NVL(viConsecutivo,0),
			NVL(vsNombreArchivo,''),
			NVL(vsArchivoOrigen,''),
			NVL(vsIntegridad,''),
			NVL(vsIntegridadError,''),
			NVL(vsNumTarjeta,''),
			NVL(vsSecuencia,''),
			NVL(vsIdComercio325,''),
			NVL(vsNomComercio325,''),
			NVL(vsReferencia23_325,''),
			NVL(vsMonto,''),
			nvl(vsRfc325,''),
			nvl(vsDivisa325,''),
			NVL(vmMontoCashBack,0.0),
			NVL(vsConciliacion,''),
			NVL(viTipoConciliacion,0),
			NVL(vsSecuenciaExtendida,''),
			NVL(vmMontoIntercard,''),
			NVL(vsMovConciliado,''),
			NVL(vsMovReversado,''),
			NVL(vsAplicacion,''),
			NVL(vsFolioAplica,''),
			NVL(vsCodigoRetorno,''),
			NVL(vsTipotransaccion325,''),
			NVL(vsMonto325,''),
			NVL(vsBanderaProceso,'')
			WITH RESUME;
			
		END FOREACH;
	END IF;
	
	END

END PROCEDURE
DOCUMENT
'AUTOR: Ing. Alfonso Cruz',
'Proyecto: Reingenieria de la Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: CONSULTA MOVIMIENTOS PENDIENTES.',
'Fecha: 2011/10/24',
'Version: 20111024.1712',
'BD: bditarjeta',
'',
'AUTOR: Ing. Alfonso Cruz',
'Proyecto: Reingenieria de la Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AGREGA CAMPO BANDERA PROCESO.',
'Fecha: 2011/11/24',
'Version: 20111124.1712',
'BD: bditarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE CAMBIA EL ELEMENTO DE IDENTIFICACION DEL SISTEMA DE 8 A 40.',
'Fecha: 2012/08/03',
'Version: 20120803.1555',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICA LA EXTRACCION DE DATOS PARA OMITIR CARACTERES ESPECIALES EN EL NOMRE DEL COMERCIO.',
'Fecha: 2012/10/23',
'Version: 20121023.1036',
'BD: BdiTarjeta',
'',
'MODIFICACION: Ricardo Reséndiz Martinez',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Luis Antonio Gomez ',
'Descripcion: Se agrega IF para tener consulta de usuario especial y resto de los usuarios de sistema.',
'Fecha: 2012/11/08',
'Version: 20121108',
'BD: BdiTarjeta',
'',
'MODIFICACION: Ricardo Reséndiz Martinez',
'Proyecto: Perfiles para modificacion de devoluciones no aplicadas',
'Solicito: Evelio Chaparro Garcia ',
'Descripcion: Se agregaron usuarios especificos para que pueda modificar devoluciones no aplicadas por regla de negocio ',
'Fecha: 2013/02/20',
'Version: 20130220.2030',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_conarchivoresumen_con(
													cNombreArchivo varchar(23),
													cNumEmpl varchar(9)
													)
RETURNING VARCHAR(6) as Cod_ret,VARCHAR(80) as Men_ret,
    char(23) as nombrearchivo,
    char(3) as archivo_origen,
	integer as registros_archivo,
	money(16,2) as monto_archivo,
	integer as registro_aplicados_arch,
	INTEGER as NumCargos_Arch,
	INTEGER as NumAbonos_Arch,
	integer as cargo_aplicados,
	money(16,2) as monto_cargos_apli,
	integer as numero_abonos_apli,
	money(16,2) as monto_abonos_apli,
    integer as mov_err_aplica,
    integer as conciliado_intercard,
    integer as pago_inter_dep_mg,
    integer as conc_montomenor,
    integer as conc_montomayor,
    integer as mov_pre_conc,
    integer as no_conc,
    integer as forzado,
    integer as no_conc_err,
    integer as no_conc_rec,
    integer as no_conc_dev,
    integer as solo_carga,
	integer as monto_cashback;


	DEFINE  SQL_ERR          INTEGER;
	DEFINE  ISAM_ERR         INTEGER;
	DEFINE  ERROR_INFO       VARCHAR(80);
	DEFINE  P_COD_RET        VARCHAR(6);
	DEFINE  P_COD_RET2        VARCHAR(6);
	DEFINE  P_MENSAJE        VARCHAR(80);
	DEFINE vNombrearchivo char(23);
    DEFINE vArchivo_origen char(3);
	DEFINE vRegistros_archivo INTEGER;
	DEFINE vMonto_archivo money(16,2);
	DEFINE vRegistro_aplicados INTEGER;
	DEFINE vNumCargos_Arch INTEGER;
	DEFINE NumAbonos_Arch INTEGER;
	DEFINE vCargo_aplicados INTEGER;
	DEFINE vMonto_cargos_apli money(16,2);
	DEFINE vNumero_abonos_apli INTEGER;
	DEFINE vMonto_abonos_apli money(16,2);
	DEFINE vMov_err_aplica INTEGER;
	DEFINE vConciliado_intercard INTEGER;
	DEFINE vPago_inter INTEGER;
	DEFINE vConc_montomenor INTEGER;
	DEFINE vConc_montomayor INTEGER;
	DEFINE vMov_pre_conc INTEGER;
	DEFINE vNo_conc INTEGER;
	DEFINE vForzado INTEGER;
	DEFINE vNo_conc_err INTEGER;
	DEFINE vNo_conc_rec INTEGER;
	DEFINE vNo_conc_dev INTEGER;
	DEFINE vSolo_carga INTEGER;
	DEFINE vMov_cash_back INTEGER;


	LET vNombrearchivo = '';
    LET vArchivo_origen = '';
	LET vRegistros_archivo = 0;
	LET vMonto_archivo = 0;
	LET vRegistro_aplicados = 0;
	LET vNumCargos_Arch = 0;
	LET NumAbonos_Arch = 0;
	LET vCargo_aplicados = 0;
	LET vMonto_cargos_apli = 0;
	LET vNumero_abonos_apli = 0;
	LET vMonto_abonos_apli = 0;
	LET vMov_err_aplica = 0;
	LET vConciliado_intercard = 0;
	LET vPago_inter = 0;
	LET vConc_montomenor = 0;
	LET vConc_montomayor = 0;
	LET vMov_pre_conc = 0;
	LET vNo_conc = 0;
	LET vForzado = 0;
	LET vNo_conc_err = 0;
	LET vNo_conc_rec = 0;
	LET vNo_conc_dev = 0;
	LET vSolo_carga = 0;
	LET vMov_cash_back = 0;

	--SET DEBUG FILE TO "/tmp/manuel/ejemplo_resumen.out";
	--TRACE ON;

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;

	 EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora('9','Error en sp_conarchivoresumen_con ' || SQL_ERR || ' ' || P_MENSAJE,cNumEmpl) INTO P_COD_RET2;

     RETURN P_COD_RET,P_MENSAJE, vNombrearchivo,vArchivo_origen,vRegistros_archivo,vMonto_archivo,vRegistro_aplicados,vNumCargos_Arch,NumAbonos_Arch,vCargo_aplicados,
	 vMonto_cargos_apli,vNumero_abonos_apli,vMonto_abonos_apli,vMov_err_aplica,vConciliado_intercard,vPago_inter,vConc_montomenor,vConc_montomayor,vMov_pre_conc,vNo_conc,vForzado,
	 vNo_conc_err,vNo_conc_rec,vNo_conc_dev,vSolo_carga,vMov_cash_back;

   END EXCEPTION;

--************************************************************
-- Creado por Manuel Osuna Valencia
-- fecha : 19/10/2011
-- Funcion: Consulta de Totalizados por Archivo de Consiliacion
--
--************************************************************

   LET P_COD_RET = '00000';
   LET P_COD_RET2 = '00000';
   LET P_MENSAJE = 'PROCESO EXITOSO';

   	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	
	
	
    
	select arch.nombrearchivo,
	arch.archivo_origen,
	sum(decode(nvl(mov.nombrearchivo,''),'',0,1))  as registros_archivo,
	sum(nvl(mov.monto325::money(16,9), 0.0)) as monto_archivo,
	sum(case when mov.aplicacion = 'V' then 1 else 0 end) as registro_aplicados,
	--sum(case when mov.aplicacion = 'V' then nvl(mov.monto325::money(16,9),0.0)  else 0.0 end) as monto_aplicado,
	--sum(case when mov.tipotransaccion325 = '01' or  mov.tipotransaccion325 = '02' then 1 else 0 end) as numero_cargo,
	SUM(CASE WHEN (mov.tipotransaccion325 IN ('01','02')) THEN 1 ELSE 0 END ) AS NumCargos_Arch,
	SUM(CASE WHEN (mov.tipotransaccion325 IN ('20','21')) THEN 1 ELSE 0 END ) AS NumAbonos_Arch,
	sum(case when (mov.tipotransaccion325 = '01' or  mov.tipotransaccion325 = '02') and mov.aplicacion = 'V'  then 1 else 0 end) as cargo_aplicados,
	sum(case when (mov.tipotransaccion325 = '01' or  mov.tipotransaccion325 = '02') and mov.aplicacion = 'V'  then mov.monto325::money(16,9) else 0 end) as monto_cargos_apli,
	sum(case when mov.tipotransaccion325 = '20' or  mov.tipotransaccion325 = '21' then 1 else 0 end) as numero_abonos_apli,
	sum(case when (mov.tipotransaccion325 = '20' or  mov.tipotransaccion325 = '21') and mov.aplicacion = 'V'  then mov.monto325::money(16,9) else 0 end) as monto_abonos_apli,
	sum(case when mov.aplicacion = 'F' then 1 else 0 end) as mov_err_aplica,
	sum(case when mov.conciliacion = 'V' then 1 else 0 end) as conciliado_intercard,
	SUM(CASE WHEN mov.tipotransaccion325 = '20' THEN 1 ELSE 0 END) AS pago_inter_dep_mg,
	sum(case when mov.tipo_conciliacion in ('2','3','4') then 1 else 0 end) as conc_montomenor,
	sum(case when mov.tipo_conciliacion = '5' then 1 else 0 end) as conc_montomayor,
	sum(case when (mov.montocashback325 > 0) then 1 else 0 end) as monto_cashback,
	sum(case when mov.tipo_conciliacion = '6' then 1 else 0 end) as mov_pre_conc,
	sum(case when mov.tipo_conciliacion = '7' then 1 else 0 end) as no_conc,
	sum(case when mov.tipo_conciliacion = '8' then 1 else 0 end) as forzado,
	sum(case when mov.integridad = 'F' then 1 else 0 end) as no_conc_err,
	sum(case when mov.tipo_conciliacion = '9' then 1 else 0 end) as no_conc_rec,
	sum(case when (mov.tipotransaccion325 = '21' ) then 1 else 0 end) as no_conc_dev,
	sum(case when mov.tipo_conciliacion = '0' then 1 else 0 end) as solo_carga
    INTO vNombrearchivo,vArchivo_origen,vRegistros_archivo,vMonto_archivo,
	vRegistro_aplicados,vNumCargos_Arch,NumAbonos_Arch,vCargo_aplicados,
	vMonto_cargos_apli,vNumero_abonos_apli,vMonto_abonos_apli,vMov_err_aplica,vConciliado_intercard,
	vPago_inter,vConc_montomenor,vConc_montomayor,vMov_cash_back,vMov_pre_conc,vNo_conc,vForzado,
	vNo_conc_err,vNo_conc_rec,vNo_conc_dev,vSolo_carga
	from bditarjeta:"informix".td_Archivos_Conciliacion AS arch left join  bditarjeta:"informix".td_movimientos_conciliacion AS mov
    on arch.nombrearchivo = mov.nombrearchivo
	where arch.nombrearchivo = cNombreArchivo
    group by 1,2;
	
	
    RETURN P_COD_RET,P_MENSAJE, vNombrearchivo,vArchivo_origen,vRegistros_archivo,
	decode (vMonto_archivo, 0, vMonto_archivo, (vMonto_archivo/100)), vRegistro_aplicados,
	vNumCargos_Arch, NumAbonos_Arch,vCargo_aplicados,
	decode (vMonto_cargos_apli, 0, vMonto_cargos_apli, (vMonto_cargos_apli/100)), vNumero_abonos_apli,
	decode (vMonto_abonos_apli, 0, vMonto_abonos_apli, (vMonto_abonos_apli/100)),
	vMov_err_aplica,vConciliado_intercard,vPago_inter,vConc_montomenor,vConc_montomayor,vMov_cash_back,
	vMov_pre_conc,vNo_conc,vForzado,vNo_conc_err,vNo_conc_rec,vNo_conc_dev,vSolo_carga;


END;
END PROCEDURE
DOCUMENT
'AUTOR: Manuel Osuna Valencia',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: Consulta de Totalizados por Archivo de Consiliacion.',
'Fecha: 2011/10/19',
'Version: 20111010.1125',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICA LA LOGICA DE LA CONSILTA PARA CONSIDERAR EL CASO CUANDO NO EXISTAN REGISTROSN EN LA TABLA DE MOVIMIENTOS_CONCILIACION.',
'Fecha: 2012/04/17',
'Version: 20120417.0900',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICA LA LOGICA DE LA CONSILTA PARA CALCULAR TOTALES DE REGISTROS DE CARGOS Y ABONOS CONTENIDOS EN EL ARCHIVO.',
'Fecha: 2012/10/01',
'Version: 20121001.1441',
'BD: BdiTarjeta',
'',
'MODIFICACION: Juan Fco. Ponce Damian',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Luis Antonio Gomez',
'Descripcion: Se integra un nuevo campo al proceso de estracción, para retornar el numero de transacciones con Cash Back.',
'Fecha: 2013/08/21',
'Version: 20130821.1441',
'BD: BdiTarjeta',
'',
'MODIFICACION: Gómez Pérez Ilse Jazmín',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Luis Antonio Gomez',
'Descripcion: Se modifica para mostrar los datos de manera correcta.',
'Fecha: 2013/09/05',
'Version: 20130821.1441',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_concreing_compvalidaintegridad ( 
psCve_usuario CHAR(10),
psArchivo_origen CHAR (3), 
psIntegridad CHAR(1),
psConsecutivo INTEGER, 
psNumTarjeta CHAR(16),
psTipotransaccion325 CHAR(15), 
pmMonto325 CHAR(13), 
psIdcomercio325 CHAR(9), 
psNomcomercio325 CHAR(30),
psReferencia23_325 CHAR(23), 
psSecuencia325 CHAR(6), 
psDivisa325 CHAR(3), 
psRfc325 CHAR(16) 
)

	RETURNING CHAR (5) AS Retorno, CHAR (1) AS Integridad, CHAR(250) AS ErrorActividad, CHAR(20) AS IntegridadError;

	/*
	*****************************************************************************************************
	-----------------------------------------------------------------------------------------------------
	-- DESCRIPCION:  COMPLEMENTA LA INTEGRIDAD DE LOS CAMPOS NECESARIOS PARA LA CONCILIACION  -----------
	-- AUTOR : Ing. Alfonso Cruz  -----------------------------------------------------------------------
	-- FECHA : 28/09/2011  ------------------------------------------------------------------------------
	-- BD: bditarjeta  ----------------------------------------------------------------------------------
	-- SISTEMA : Reingenieria de la conciliacion automatica / Complemento de Integridad  -----------------
	*****************************************************************************************************
	*/

	/*VARIABLES DE ERRORES*/
	DEFINE vsRetBitacora CHAR(5);
	
	DEFINE vsRetorno VARCHAR(5);
	DEFINE vsIntegridad	CHAR(1);
	DEFINE vsErrorActividad	CHAR(250);
	DEFINE vsIntegridadError CHAR(20);
	DEFINE viElemento INTEGER;
	DEFINE vsActividad VARCHAR(150);


	DEFINE viCodigo INTEGER;
	DEFINE isam_err INTEGER ;
	DEFINE error_info CHAR(70) ;
	
	DEFINE vssqlerr CHAR(5) ;
	DEFINE vsFlagError CHAR (1) ;

	DEFINE vsSistema CHAR(1);
	DEFINE vsBinCredito VARCHAR (6);
	DEFINE vsBinDebito VARCHAR (6);
	
	DEFINE vsMontoCashBack325 Char(13);
	
	
	/* INICIALIZACION DE VARIABLES */
	LET vsRetBitacora = '';
	
	LET vsSistema = '';
	LET vsBinCredito ='';
	LET vsBinDebito = '';
	
	LET vsRetorno = '00000';
	LET vsIntegridad = '';
	LET vsErrorActividad = '';
	LET vsIntegridadError = '';
	LET viElemento = 40;
	LET vsActividad = '';
	
	LET viCodigo = 0;
	LET isam_err =0;
	LET error_info = '';
	LET vssqlerr = '00000';
	LET vsFlagError = '' ;
	
	LET vsMontoCashBack325 = '';


	BEGIN

	ON EXCEPTION SET viCodigo,isam_err,error_info   --cacha el error en caso de que exista y regresa un valor predeterminado

			LET vssqlerr = viCodigo;
			LET vsFlagError = 'F';
			
			LET vsActividad = 'ERROR ' || vssqlerr ||' ISAM '|| isam_err ||' INFORMIX '||error_info || ' EN sp_concreing_consultaCompConciliacion';
			EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora(viElemento,vsActividad,psCve_usuario) INTO vsRetBitacora;

			RETURN NVL(vssqlerr,''), 
			NVL(vsFlagError,''), 
			NVL(vsErrorActividad,''), 
			NVL(vsIntegridadError,'');

	END EXCEPTION;

	--SET DEBUG FILE TO '/home/sysifx/soporte/TraceCompMovINTEGRIDAD.sql';
	--TRACE ON;

	-----------------------------------------------------
	--------REINGENIERIA-CONCILIACION-AUTOMATICA---------
	--------2011/10/24-ING-ALFONSO-CRUZ------------------
	-----------------------------------------------------

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;

		-- LECTURA DEL CAMPO SISTEMA
		SELECT FIRST 1 sistema
		INTO vsSistema
		FROM bditarjeta:"informix".td_archivo_origen
		WHERE archivo_origen = psArchivo_origen;
			
		-- OBTENER BINES
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;
		--OBTIENE EL BIN DE CREDITO
		SELECT FIRST 1  Bin INTO vsBinCredito FROM Intercard:"informix".Bines WHERE CreditoDebito = 'C';

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;
		--OBTIENE EL BIN DE DEBITO
		SELECT FIRST 1  Bin INTO vsBinDebito FROM Intercard:"informix".Bines WHERE CreditoDebito = 'D';
		-- RECUPERA el valor del monto cashback del registro en cuestion
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;
		select montocashback325 into vsMontoCashBack325 from Bditarjeta:"informix".td_movimientos_conciliacion
			where 	archivo_origen = psArchivo_origen  and
					consecutivo = psConsecutivo;
		
		
		--REGISTRO EN BITACORA DE ACTIVIDAD
		LET vsActividad = 'EJECUCION DE sp_concreing_CompValidaIntegridad PARA EL CONSECUTIVO ' || psConsecutivo ;
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora(viElemento, vsActividad, psCve_usuario) INTO vsRetBitacora;
		
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_validaintegridad (
		psArchivo_origen, --archivo_origen
		psConsecutivo, --Consecutivo
		psNumTarjeta,--numtarjeta
		psTipotransaccion325, --Tipotransaccion325 
		pmMonto325, --monto325
		vsMontoCashBack325, --montocashback325
		psIdcomercio325, --idcomercio
		psNomcomercio325,  --nombre del comercio
		psReferencia23_325, --referencia de la transaccion
		psSecuencia325,  --secuencia325
		psDivisa325, --divisa325 
		psRfc325,---- RFC
		vsBinDebito, -- BINE DEBIDO
		vsBinCredito, --BINE CREDITO
		vsSistema  --SISTEMA
		)INTO vsRetorno, vsIntegridad, vsErrorActividad, viElemento;
		
		LET vssqlerr = vsRetorno;
		LET vsFlagError = vsIntegridad;
		
		/*ACTUALIZAR VARIABLES DE RETORNO*/
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		SELECT FIRST 1 integridad_error 
		INTO vsIntegridadError
		FROM bditarjeta:"informix".td_movimientos_conciliacion
		WHERE consecutivo = psConsecutivo;
		
		IF ( vsIntegridad == 'V' ) THEN
			
			/*ACTUALIZANDO LOS VALORES DE INTEGRIDAD DEL REGISTRO*/
			UPDATE bditarjeta:"informix".td_movimientos_conciliacion
			SET integridad=psIntegridad,
			integridad_error='',
			secuencia325=psSecuencia325,
			numtarjeta=psNumTarjeta,
			IdComercio325 = psIdcomercio325,
			NomComercio325 = psNomcomercio325,
			Referencia23_325 = psReferencia23_325,
			rfc325 = psRfc325,
			divisa325 = psDivisa325,
			aplicacion = 'P',
			tipo_conciliacion = 0,      -- Se agrega para volver aplicar clasificacion a los movimientos
			desc_conciliacion = '',     -- Se agrega para volver aplicar descripcion de conciliacion 
			conciliacion = 'P',         -- Se agrega para reversar la bandera de conciliacion
			finalizado = 'F',
			cod_retorno = ''
			WHERE consecutivo = psConsecutivo;
			
			--ACTUALIZA EL ESTATUS DE TRABAJO DEL ARCHIVO PARA SER REPROCESADO
			UPDATE BdiTarjeta:"informix".Td_Archivos_Conciliacion
			SET Proceso = 'P'
			WHERE nombrearchivo IN (SELECT nombrearchivo FROM bditarjeta:"informix".td_movimientos_conciliacion WHERE consecutivo = psConsecutivo);
			
			
		END IF;
		
		IF(vsRetorno != '00000')THEN
			LET vsActividad = 'ERROR DE sp_concreing_CompValidaIntegridad PARA EL CONSECUTIVO ' || psConsecutivo ;
		ELSE --OK	
			LET vsActividad = 'SE COMPLEMENTA LA INTEGRIDAD DEL REGISTRO CON CONSECUTIVO ' || psConsecutivo;
		END IF;
		
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora(viElemento, vsActividad, psCve_usuario) INTO vsRetBitacora;
		
		RETURN NVL(vssqlerr,''), NVL(vsFlagError,''), NVL(vsErrorActividad,''), NVL(vsIntegridadError,'');

	END

END PROCEDURE
DOCUMENT
'AUTOR: Ing. Alfonso Cruz',
'Proyecto: Reingenieria de la Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: COMPLEMENTA LA INTEGRIDAD DE LOS CAMPOS NECESARIOS PARA LA CONCILIACION.',
'Fecha: 2011/10/24',
'Version: 20111024.1714',
'BD: bditarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE CAMBIA EL STATUS DE finalizado = "F", ANTERIORMENTE P.',
'Fecha: 2012/08/01',
'Version: 20120801.1647',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE ACTUALIZA EL ESTATUS DE TRABAJO DEL ARCHIVO PARA SER REPROCESADO.',
'Fecha: 2012/08/13',
'Version: 20120813.1723',
'BD: BdiTarjeta',
'',
'MODIFICACION: Ricardo Reséndiz Martínez',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Luis Antonio Gomez',
'Descripcion: SE AGREGA AL UPDATE TIPO DE CONCILIACION Y DESCRIPCION Y BANDERA DE CONCILIACION',
'Fecha: 2012/11/28',
'Version: 20121128.1400',
'BD: BdiTarjeta',
'',
'MODIFICACION: Ricardo Reséndiz Martínez',
'Proyecto: Integración de transaccion CashBack',
'Solicito: Luis Antonio Gomez',
'Descripcion: SE INTEGRA RECUPERACION DE MONTO CASH BACK EN LA TRANSACCION Y SE MODIFICA LLAMADO AL SP_CONCREING_VALIDAINTEGRIDAD POR CAMBIO',
'Fecha: 2012/11/28',
'Version: 20121128.1400',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_esnumerico ( psCadena CHAR (20))

RETURNING CHAR (1) AS Numerico ;

--****************************************************************************************************
-- DESCRIPCION:  SP CLONADO QUE VERIFICA QUE LA CADENA DE ENTRADA SOLAMENTE CONTENGA NUMEROS
-- AUTOR : Casanova Edeza Hector Juan // CLONADOR Ricardo Resendiz
-- FECHA : 11/11/2013
-- BD: bditarjeta
-- SISTEMA : Sorteo SAT
-- MODIFICADO : SIN MODIFICACIONES
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */
DEFINE vsRespuesta CHAR (1) ;

DEFINE visqlerr INTEGER ;
/* INICIALIZACION DE VARIABLES */

LET vsRespuesta = 'F' ;

LET visqlerr = 0;

BEGIN

	ON EXCEPTION SET visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado

		IF visqlerr = -1213 THEN
			LET vsRespuesta = 'F' ;
		ELSE
			LET vsRespuesta = ' ' ;
		END IF;

		RETURN vsRespuesta ;

	END EXCEPTION;

	IF (psCadena >= 0) THEN
		LET vsRespuesta = 'V';
	ELSE
		LET vsRespuesta = 'F';
	END IF  ;

	RETURN vsRespuesta ;

END

END PROCEDURE
DOCUMENT
'AUTOR: Casanova Edeza Hector Juan // CLONADOR Ricardo Resendiz',
'Proyecto: Sorteo SAT',
'Solicito: Luis Antonio Gomez',
'Descripcion: VERIFICA QUE LA CADENA DE ENTRADA SOLAMENTE CONTENGA NUMEROS.',
'Fecha: 2013/11/11',
'Version: 20131111.1830',
'BD: bditarjeta';

CREATE PROCEDURE "informix".sp_sorteo_sat2 (
		pdfecha date
		)

RETURNING 
			VARCHAR (5) AS CodRet, 
			VARCHAR(250) AS Mensaje_Respuesta;

--Definición de Variables de Error
DEFINE vicodigo 			integer;
DEFINE vsCodRet 			VARCHAR(5);
DEFINE vsMensaje_Respuesta 	VARCHAR(250);


--Definición de datos centrales

DEFINE vdfechahoyinte		date;



-- Para retorno de Principal de Credito
DEFINE 	g_Remanente		money;
DEFINE  g_IntMoraCob   	money;
DEFINE  g_IntVencCob	money;
DEFINE  g_CapVencCob    money;
DEFINE  g_IntVigCob		money;
DEFINE  g_CapVigCob		money;
DEFINE  g_Impuesto		money;
DEFINE  g_Comision		money;
DEFINE	g_Seguro		money;

-- Para generacion de archivo

DEFINE 	vsql			char (1150);
DEFINE  vsfecencabezado   char(10);
DEFINE  vicontador 		integer;
DEFINE  vscontador		char(10);
DEFINE  viincremento	integer;
DEFINE  vicontador2		integer;


BEGIN
	ON EXCEPTION SET viCodigo   --cacha el error en caso de que exista y regresa un valor predeterminado

				RETURN 	vsCodRet, 
						vsMensaje_Respuesta;

	END EXCEPTION;

--SET DEBUG FILE TO '/informix/HomeInformix/rrm/sp_sorteo_sat2.out';
--TRACE ON;

-- Inicialización de variables
LET 	vicodigo = 0;
LET		vsCodRet = '00000';
LET		vsMensaje_Respuesta = 'PROCESO TERMINADO SATISFACTORIAMENTE';



-- Inicializacion de variables de retorno de credito
LET  g_Remanente 	= 0.00;
LET  g_IntMoraCob 	= 0.00;
LET  g_IntVencCob 	= 0.00;
LET  g_CapVencCob  	= 0.00;
LET  g_IntVigCob	= 0.00;
LET  g_CapVigCob 	= 0.00;
LET  g_Impuesto		= 0.00;
LET  g_Comision 	= 0.00;
LET	 g_Seguro  		= 0.00;

-- Para generacion de archivo

LET 	vsql	= '';
LET     vsfecencabezado = '';
LET 	vicontador = 0;
LET 	vscontador = '';
LET  	viincremento = 0;
LET		vicontador2 = 0;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	Select fecha_hoy into vdfechahoyinte from Bdinteg:"informix".si_fechas;

	if vdfechahoyinte = pdfecha then 
			
			EXECUTE PROCEDURE Bdicred:"informix".principal(	'001','600045117634',1,	3753.00 ,	'informix',	'9290',	'i111818031038624',	'7860')
				into vsCodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
			
			if vsCodRet = '000' then 
				update bditarjeta:"informix".tb_sorteo_sat
					set codigodevolucion = '0',
						observacion = 'Movimiento aplica',
						retcentral = vsCodRet,
						validaciones = 'V'
				where consecutivo = 234149;
			else 
				update bditarjeta:"informix".tb_sorteo_sat
					set codigodevolucion = '1',
						observacion = 'NO APLICADO POR CREDITO',
						retcentral = vsCodRet
				where consecutivo = 234149;
			end if;
	
	else
	
		let vsCodRet = '00001';
		LET  vsMensaje_Respuesta = 'Fechas diferentes en integral';
		
		RETURN 	vsCodRet, 
			NVL(vsMensaje_Respuesta,'');
		
	end if; 
	
			
	 			
	let vsfecencabezado = day(vdfechahoyinte)||'/'||month(vdfechahoyinte)||'/'||year(vdfechahoyinte);
				
	set isolation to dirty read;
	select count(*) into vicontador from Bditarjeta:tb_sorteo_sat;
		
	let vscontador = vicontador::char(10);
		
	LET viincremento = Length(vscontador);
		
	For vicontador2 = viincremento  TO 9 STEP 1
			LET vscontador = '0'||vscontador;
	end for;

	
	
	
	-- Primera linea del archivo
	let vsql = 'echo "00|1|SAT           |FECHA|'||vsfecencabezado||'|" >> /resplogifx/Bancoppel_SAT1.txt';
	system vsql;
	let vsql = '';
	let vsql = '';
	system vsql;
	--   #########################################  Todas las no premiadas ####################################################################
	-- Para generar comando de descarga de datos			
	let vsql = '';
	let vsql = 	'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/SAT_BuenFin.unl '||
				'select  tporeg,banemisor,day(fchtransacintercard)||month(fchtransacintercard)||SUBSTR(year(fchtransacintercard),3,2), numtarjeta,'||
				'montoarchivo,secuenciaarchivo,numrefarchivo,montopremio,ordenabono,codigodevolucion from bditarjeta:"informix".tb_sorteo_sat where validaciones =''"'||'F'||'"'';"> /resplogifx/SAT_BuenFin.sql';
			
	system vsql;
	-- Ejecución del comando anterior
	let vsql = '';
	let vsql = '';
	system vsql;
	let vsql= "dbaccess bditarjeta /resplogifx/SAT_BuenFin.sql";
	system vsql;
	-- Borrando sentencia de ejecucion
	let vsql = '';
	let vsql ='rm /resplogifx/SAT_BuenFin.sql';
	system vsql;
	let vsql = '';
	-- Agragando descarga a archivo final 
	let vsql = 'cat /resplogifx/SAT_BuenFin.unl >> /resplogifx/Bancoppel_SAT1.txt';
	system vsql;
	let vsql = '';
	let vsql = '';
	system vsql;
	-- Se le agrega espacido 
	let vsql = '';
	let vsql ='rm /resplogifx/SAT_BuenFin.unl';
	system vsql;
	let vsql = '';
	
	--   #########################################  Todas las premiadas excluyendo especial  ####################################################################
	-- Para generar comando de descarga de datos			
	let vsql = '';
	let vsql = 	'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/SAT_BuenFin.unl '||
				'select  tporeg,banemisor,day(fchtransacintercard)||month(fchtransacintercard)||SUBSTR(year(fchtransacintercard),3,2), numtarjeta,'||
				'montoarchivo,secuenciaarchivo,numrefarchivo,montoarchivo,ordenabono,codigodevolucion from bditarjeta:"informix".tb_sorteo_sat where validaciones = ''"'||'V'||'"'' and numtarjeta <> ''"'||'4268070225475773'||'"'';"> /resplogifx/SAT_BuenFin.sql';
			
	system vsql;
	-- Ejecución del comando anterior
	let vsql = '';
	let vsql = '';
	system vsql;
	let vsql= "dbaccess bditarjeta /resplogifx/SAT_BuenFin.sql";
	system vsql;
	-- Borrando sentencia de ejecucion
	let vsql = '';
	let vsql ='rm /resplogifx/SAT_BuenFin.sql';
	system vsql;
	let vsql = '';
	-- Agragando descarga a archivo final 
	let vsql = 'cat /resplogifx/SAT_BuenFin.unl >> /resplogifx/Bancoppel_SAT1.txt';
	system vsql;
	let vsql = '';
	let vsql = '';
	system vsql;
	-- Se le agrega espacido 
	let vsql = '';
	let vsql ='rm /resplogifx/SAT_BuenFin.unl';
	system vsql;
	let vsql = '';

		--   #########################################  Todas las premiadas excluyendo especial  ####################################################################
	-- Para generar comando de descarga de datos			
	let vsql = '';
	let vsql = 	'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/SAT_BuenFin.unl '||
				'select  tporeg,banemisor,day(fchtransacintercard)||month(fchtransacintercard)||SUBSTR(year(fchtransacintercard),3,2), numtarjeta,'||
				'montoarchivo,secuenciaarchivo,numrefarchivo,montoarchivo,ordenabono,codigodevolucion from bditarjeta:"informix".tb_sorteo_sat where validaciones = ''"'||'P'||'"'';"> /resplogifx/SAT_BuenFin.sql';
			
	system vsql;
	-- Ejecución del comando anterior
	let vsql = '';
	let vsql = '';
	system vsql;
	let vsql= "dbaccess bditarjeta /resplogifx/SAT_BuenFin.sql";
	system vsql;
	-- Borrando sentencia de ejecucion
	let vsql = '';
	let vsql ='rm /resplogifx/SAT_BuenFin.sql';
	system vsql;
	let vsql = '';
	-- Agragando descarga a archivo final 
	let vsql = 'cat /resplogifx/SAT_BuenFin.unl >> /resplogifx/Bancoppel_SAT1.txt';
	system vsql;
	let vsql = '';
	let vsql = '';
	system vsql;
	-- Se le agrega espacido 
	let vsql = '';
	let vsql ='rm /resplogifx/SAT_BuenFin.unl';
	system vsql;
	let vsql = '';
	
	--   #########################################  Todas las premiadas incluyendo especial  ####################################################################
	-- Para generar comando de descarga de datos			
	let vsql = '';
	let vsql = 	'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/SAT_BuenFin.unl '||
				'select  tporeg,banemisor,day(fchtransacintercard)||month(fchtransacintercard)||SUBSTR(year(fchtransacintercard),3,2), numtarjeta,'||
				'montoarchivo,secuenciaarchivo,numrefarchivo,montopremio,ordenabono,codigodevolucion from bditarjeta:"informix".tb_sorteo_sat where validaciones = ''"'||'V'||'"'' and numtarjeta = ''"'||'4268070225475773'||'"'';"> /resplogifx/SAT_BuenFin.sql';
			
	system vsql;
	-- Ejecución del comando anterior
	let vsql = '';
	let vsql = '';
	system vsql;
	let vsql= "dbaccess bditarjeta /resplogifx/SAT_BuenFin.sql";
	system vsql;
	-- Borrando sentencia de ejecucion
	let vsql = '';
	let vsql ='rm /resplogifx/SAT_BuenFin.sql';
	system vsql;
	let vsql = '';
	-- Agragando descarga a archivo final 
	let vsql = 'cat /resplogifx/SAT_BuenFin.unl >> /resplogifx/Bancoppel_SAT1.txt';
	system vsql;
	let vsql = '';
	let vsql = '';
	system vsql;
	-- Se le agrega espacido 
	let vsql = '';
	let vsql ='rm /resplogifx/SAT_BuenFin.unl';
	system vsql;
	let vsql = '';
	
	
	-- Agregando pie de archivo
	let vsql = 'echo "99|'||vscontador||'|" >> /resplogifx/Bancoppel_SAT1.txt';
	system vsql;
		
	LET  vsMensaje_Respuesta = 'Proceso completo se genero archivo Bancoppel_SAT1.txt';

	
	RETURN 	vsCodRet, 
			NVL(vsMensaje_Respuesta,'');


END
END PROCEDURE
DOCUMENT
'AUTOR: Ricardo Resendiz Martinez',
'Proyecto: Sorteo de SAT del Buen Fin',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Complemento de descarga por transacciones probables por el estatus de la tarjeta para ser incluidas en archivo y aplicacion de transaccion devuelta',
'Fecha: 2013/12/18',
'Version: 20131218.1400',
'BD: bditarjeta';

CREATE PROCEDURE "informix".sp_sorteo_sat3 (
		pdfecha date
		)

RETURNING 
			VARCHAR (5) AS CodRet, 
			VARCHAR(250) AS Mensaje_Respuesta;

--Definición de Variables de Error
DEFINE vicodigo 			integer;
DEFINE vsCodRet 			VARCHAR(5);
DEFINE vsMensaje_Respuesta 	VARCHAR(250);

--Definición de bandera de ciclo
DEFINE vsFlagEnTransaccion 	varchar(1);
DEFINE viContadorRegistros 	integer;

--Definición de datos centrales

DEFINE vdfechahoyinte		date;
DEFINE vsnumtarjeta			char(16);
DEFINE viconsecutivo		integer;
DEFINE vsnumcliente			char(13);
DEFINE vsmunicipiozona  	char(27);
DEFINE vsnombreciudad		char(30);
DEFINE vsnomedo				char(30);
DEFINE vspoblacion 			char(30);


-- Para generacion de archivo

DEFINE 	vsql			char (1150);
DEFINE  vsfecencabezado   char(10);
DEFINE  vicontador 		integer;
DEFINE  vscontador		char(10);
DEFINE  viincremento	integer;
DEFINE  vicontador2		integer;


BEGIN
	ON EXCEPTION SET viCodigo   --cacha el error en caso de que exista y regresa un valor predeterminado

				RETURN 	vsCodRet, 
						vsMensaje_Respuesta;

	END EXCEPTION;

--SET DEBUG FILE TO '/informix/HomeInformix/rrm/sp_sorteo_sat2.out';
--TRACE ON;

-- Inicialización de variables
LET 	vicodigo = 0;
LET		vsCodRet = '00000';
LET		vsMensaje_Respuesta = 'PROCESO TERMINADO SATISFACTORIAMENTE';

-- Inicializacion de variables de ciclo
LET vsFlagEnTransaccion = 'F';
LET viContadorRegistros = 0;

-- Datos del proceso 
LET vsnumtarjeta = '';
LET viconsecutivo = 0;
let vsnumcliente = '';
let vsmunicipiozona = '';
let vsnombreciudad = '';
let vsnomedo = '';
let vspoblacion = '';

-- Para generacion de archivo


LET 	vsql	= '';
LET     vsfecencabezado = '';
LET 	vicontador = 0;
LET 	vscontador = '';
LET  	viincremento = 0;
LET		vicontador2 = 0;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	Select fecha_hoy into vdfechahoyinte from Bdinteg:"informix".si_fechas;

	if vdfechahoyinte = pdfecha then 
		FOREACH WITH HOLD
				select consecutivo, numtarjeta into viconsecutivo, vsnumtarjeta from Bditarjeta:tb_sorteo_sat 
					where codigodevolucion = '0'
		
				IF (vsFlagEnTransaccion = 'F') THEN 
						BEGIN WORK;
						LET vsFlagEnTransaccion = 'V';
				END IF;
		
				select numcliente into vsnumcliente from Intercard:"informix".tarjeta
					where numtarjeta = vsnumtarjeta;

				set isolation to dirty read;
				SELECT zona.municipiozona, cd.nombreciudad, edo.nombre into vsmunicipiozona, vsnombreciudad, vsnomedo
					FROM 	bdinteg:"informix".si_direcciones_actual dir
							LEFT OUTER JOIN bdinteg:"informix".si_catcalles calle ON ( calle.numerocalle = dir.numerocalle )
							LEFT OUTER JOIN bdinteg:"informix".si_catzonas zona ON ( zona.numerociudad = dir.numerociudad AND zona.numerocolonia = dir.numerocolonia )
							LEFT OUTER JOIN bdinteg:"informix".si_catciudades cd ON ( cd.numerociudad = dir.numerociudad )
							LEFT OUTER JOIN bdinteg:"informix".si_estados edo ON ( edo.estado = dir.estado )
					WHERE 
							dir.numcte = vsnumcliente AND 
							dir.tipo_dir = '1'; -- EL TIPO DE DIRECCION PUEDES SER 1, 2 ó 3
					
				Let vspoblacion = TRIM(NVL(vsmunicipiozona,'')) || ' ' ||TRIM (NVL(vsnombreciudad,''));

				-- registros a 30 posiciones
					let vicontador2 = 0;
					let viincremento = length (vsnomedo);
					if viincremento < 30 then
						For vicontador2 = viincremento  TO 29 STEP 1
							LET vsnomedo = ' '||vsnomedo;
						end for;
					end if;
				
				-- Registro a 30 posiciones 
					let vicontador2 = 0;
					let viincremento = length (vspoblacion);
					if viincremento < 30 then
						For vicontador2 = viincremento  TO 29 STEP 1
							LET vspoblacion = ' '||vspoblacion;
						end for;
					end if;
				

				update Bditarjeta:"informix".tb_sorteo_sat
						set 	estado = vsnomedo,
								poblacion = vspoblacion
					where consecutivo = viconsecutivo;

				LET viContadorRegistros = viContadorRegistros + 1;

				--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
				IF (viContadorRegistros = 1000) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
						COMMIT WORK;
						LET vsFlagEnTransaccion = 'F';
						LET viContadorRegistros = 0;
						CONTINUE FOREACH;
				END IF;
		END FOREACH;

		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
				COMMIT WORK;
				LET vsFlagEnTransaccion = 'F';
		END IF;

		LET  vsMensaje_Respuesta = 'Etapa 1 Completa';

	else

		let vsCodRet = '00001';
		LET  vsMensaje_Respuesta = 'Fechas diferentes en integral';
		
		RETURN 	vsCodRet, 
			NVL(vsMensaje_Respuesta,'');
		
	end if; 
	
			
	 			
	let vsfecencabezado = day(vdfechahoyinte)||'/'||month(vdfechahoyinte)||'/'||year(vdfechahoyinte);
				
	set isolation to dirty read;
	select count(*) into vicontador from Bditarjeta:tb_sorteo_sat
		where codigodevolucion = '0';
		
	let vicontador2 = 0;
	let vscontador = vicontador::char(10);
		
	LET viincremento = Length(vscontador);
		
	For vicontador2 = viincremento  TO 9 STEP 1
			LET vscontador = '0'||vscontador;
	end for;

	
	-- Primera linea del archivo
	let vsql = 'echo "00|1|SAT           |FECHA|'||vsfecencabezado||'|" >> /resplogifx/Bancoppel_SAT2.txt';
	system vsql;
	let vsql = '';
	let vsql = '';
	system vsql;
	
	--   #########################################  Todas las premiadas excluyendo especial  ####################################################################
	-- Para generar comando de descarga de datos			
	let vsql = '';
	let vsql = 	'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/SAT_BuenFin.unl '||
				'select  tporeg,banemisor,day(fchtransacintercard)||month(fchtransacintercard)||SUBSTR(year(fchtransacintercard),3,2), numtarjeta,'||
				'montoarchivo,secuenciaarchivo,numrefarchivo,montoarchivo,ordenabono,codigodevolucion,estado,poblacion from bditarjeta:"informix".tb_sorteo_sat where validaciones = ''"'||'V'||'"'' and numtarjeta <> ''"'||'4268070225475773'||'"'';"> /resplogifx/SAT_BuenFin.sql';
			
	system vsql;
	-- Ejecución del comando anterior
	let vsql = '';
	let vsql = '';
	system vsql;
	let vsql= "dbaccess bditarjeta /resplogifx/SAT_BuenFin.sql";
	system vsql;
	-- Borrando sentencia de ejecucion
	let vsql = '';
	let vsql ='rm /resplogifx/SAT_BuenFin.sql';
	system vsql;
	let vsql = '';
	-- Agragando descarga a archivo final 
	let vsql = 'cat /resplogifx/SAT_BuenFin.unl >> /resplogifx/Bancoppel_SAT2.txt';
	system vsql;
	let vsql = '';
	let vsql = '';
	system vsql;
	-- Se le agrega espacido 
	let vsql = '';
	let vsql ='rm /resplogifx/SAT_BuenFin.unl';
	system vsql;
	let vsql = '';

		--   #########################################   premiadas  probables por estatus de tarjeta  ####################################################################
	-- Para generar comando de descarga de datos			
	let vsql = '';
	let vsql = 	'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/SAT_BuenFin.unl '||
				'select  tporeg,banemisor,day(fchtransacintercard)||month(fchtransacintercard)||SUBSTR(year(fchtransacintercard),3,2), numtarjeta,'||
				'montoarchivo,secuenciaarchivo,numrefarchivo,montoarchivo,ordenabono,codigodevolucion,estado,poblacion from bditarjeta:"informix".tb_sorteo_sat where validaciones = ''"'||'P'||'"'';"> /resplogifx/SAT_BuenFin.sql';
			
	system vsql;
	-- Ejecución del comando anterior
	let vsql = '';
	let vsql = '';
	system vsql;
	let vsql= "dbaccess bditarjeta /resplogifx/SAT_BuenFin.sql";
	system vsql;
	-- Borrando sentencia de ejecucion
	let vsql = '';
	let vsql ='rm /resplogifx/SAT_BuenFin.sql';
	system vsql;
	let vsql = '';
	-- Agragando descarga a archivo final 
	let vsql = 'cat /resplogifx/SAT_BuenFin.unl >> /resplogifx/Bancoppel_SAT2.txt';
	system vsql;
	let vsql = '';
	let vsql = '';
	system vsql;
	-- Se le agrega espacido 
	let vsql = '';
	let vsql ='rm /resplogifx/SAT_BuenFin.unl';
	system vsql;
	let vsql = '';
	
	--   #########################################  Todas las premiadas  especiales  ####################################################################
	-- Para generar comando de descarga de datos			
	let vsql = '';
	let vsql = 	'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/SAT_BuenFin.unl '||
				'select  tporeg,banemisor,day(fchtransacintercard)||month(fchtransacintercard)||SUBSTR(year(fchtransacintercard),3,2), numtarjeta,'||
				'montoarchivo,secuenciaarchivo,numrefarchivo,montopremio,ordenabono,codigodevolucion,estado,poblacion from bditarjeta:"informix".tb_sorteo_sat where validaciones = ''"'||'V'||'"'' and numtarjeta = ''"'||'4268070225475773'||'"'';"> /resplogifx/SAT_BuenFin.sql';
			
	system vsql;
	-- Ejecución del comando anterior
	let vsql = '';
	let vsql = '';
	system vsql;
	let vsql= "dbaccess bditarjeta /resplogifx/SAT_BuenFin.sql";
	system vsql;
	-- Borrando sentencia de ejecucion
	let vsql = '';
	let vsql ='rm /resplogifx/SAT_BuenFin.sql';
	system vsql;
	let vsql = '';
	-- Agragando descarga a archivo final 
	let vsql = 'cat /resplogifx/SAT_BuenFin.unl >> /resplogifx/Bancoppel_SAT2.txt';
	system vsql;
	let vsql = '';
	let vsql = '';
	system vsql;
	-- Se le agrega espacido 
	let vsql = '';
	let vsql ='rm /resplogifx/SAT_BuenFin.unl';
	system vsql;
	let vsql = '';
	
	
	-- Agregando pie de archivo
	let vsql = 'echo "99|'||vscontador||'|" >> /resplogifx/Bancoppel_SAT2.txt';
	system vsql;
		
	LET  vsMensaje_Respuesta = 'Proceso completo se genero archivo Bancoppel_SAT2.txt';

	
	RETURN 	vsCodRet, 
			NVL(vsMensaje_Respuesta,'');


END
END PROCEDURE
DOCUMENT
'AUTOR: Ricardo Resendiz Martinez',
'Proyecto: Sorteo de SAT del Buen Fin',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Complemento de complemento de informacion con estado y municio de la transacciones premidas',
'Fecha: 2013/12/23',
'Version: 20131218.1800',
'BD: bditarjeta';

CREATE PROCEDURE "informix".sp_concreing_consdevolucion( piTipoArchivo INTEGER, psFechaConsulta VARCHAR(10), psNombreArchivo VARCHAR(21))
RETURNING 	VARCHAR(5)  AS CodRet, 
			VARCHAR(48) AS TipoArchivo, 
			VARCHAR(23) AS NombreArchivo,
			DATE		AS FechaCarga,
			INTEGER 	AS DevRecibidas, 
			INTEGER 	AS DevAplicadas,
			INTEGER 	AS DevAplicadasForzadas, 
			INTEGER 	AS DevConciliadasSA, 
			INTEGER 	AS DevErrorIntegridad, 
			INTEGER 	AS DevFaltantes,
			VARCHAR(16) AS NumTarjeta,
			VARCHAR(5)  AS TipoOperacion,
			VARCHAR(61) AS Motivo,
			VARCHAR(30) AS NomComercio,
			VARCHAR(40) AS Referencia,
			MONEY		AS Monto,
			MONEY		AS montocashbackarchivo;

--****************************************************************************************************
-- DESCRIPCION: OBTENCION DE DEVOLUCIONES POS
-- AUTOR : Arturo Méndez Cárdenas
-- FECHA : 12/ABRIL/2012
-- BD: bditarjeta
-- SISTEMA : DevolucionesPOS
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */

--CONTROL GENERAL
DEFINE cCodret CHAR(5);
DEFINE cTipoarchivo CHAR(48);
DEFINE cNombrearchivo CHAR(23);
DEFINE cFechacarga DATE;
DEFINE iDevrecibidas INTEGER;
DEFINE iDevaplicadas INTEGER;
DEFINE iDevaplicadasforzadas INTEGER;
DEFINE iDevconciliadassa INTEGER;
DEFINE iDeverrorintegridad INTEGER;
DEFINE iDevfaltantes INTEGER;
DEFINE iEncontrado INTEGER;
DEFINE cArchivoOrigenAnt CHAR(23);
DEFINE cArchivoOrigen CHAR(3);

-- Variables de Detalle
DEFINE cNumTarjeta CHAR(16);
DEFINE cTipoOperacion CHAR(5);
DEFINE cMotivo CHAR(61);
DEFINE cNomcomercio CHAR(30);
DEFINE cReferencia CHAR(40);
DEFINE mMonto325 MONEY;
DEFINE mMontocashbackarchivo MONEY;

/* INICIALIZACION DE VARIABLES */
--CONTROL GENERAL
LET cCodret = '00000';
LET cTipoArchivo = '';
LET cNombrearchivo = '';
LET cFechacarga = CURRENT::DATE;
LET iDevrecibidas = 0;
LET iDevaplicadas = 0;
LET iDevaplicadasforzadas = 0;
LET iDevconciliadasSA = 0;
LET iDevErrorIntegridad = 0;
LET iDevFaltantes = 0;
LET iEncontrado = 0;
LET cArchivoOrigenAnt = '';
LET cArchivoOrigen = '';

-- Variables de Detalle
LET cNumTarjeta = '';
LET cTipoOperacion = '';
LET cMotivo = '';
LET cNomcomercio = '';
LET cReferencia = '';
LET mMonto325 = 0.0;
LET mMontocashbackarchivo = 0.0;

BEGIN
	
ON EXCEPTION SET iDevrecibidas 
   IF iDevrecibidas != 0 THEN
      LET cCodret = iDevrecibidas;      
      RETURN cCodret,cTipoArchivo, cNombrearchivo,cFechacarga,iDevrecibidas,iDevaplicadas,iDevaplicadasforzadas,iDevconciliadasSA,iDevErrorIntegridad,iDevFaltantes,
				cNumTarjeta,cTipoOperacion,cMotivo,cNomcomercio,cReferencia,mMonto325,mMontocashbackarchivo;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/home/sysifx/ilse/cashBack/sp_concreing_pba.txt';
--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF piTipoArchivo = 1 THEN -- Todos los tipos de archivos
	
		FOREACH WITH HOLD
			SELECT distinct(nomarchivo),fecha,archivoorigen INTO cNombrearchivo,cFechacarga,cArchivoOrigen 
			FROM bditarjeta:"informix".td_devolucionespos 
			WHERE archivoorigen IN('VIC','VNC','VID','VND','MCD','MCC') AND fecha = psFechaConsulta 
			
			LET iEncontrado = 0;
				
			-- Archivos con devoluciones pendientes(Crédito o Débito).
			IF EXISTS( SELECT nomarchivo FROM bditarjeta:"informix".td_devolucionespos WHERE nomarchivo = cNombreArchivo 
						AND fecha = psFechaConsulta AND archivoorigen = cArchivoOrigen 
						AND ((encontrado = 'V' AND estado IN('P','A','F') AND aplicado IN('F','E')) OR 
							 (encontrado = 'F' AND estado = 'P' AND aplicado IN('E','F'))) ) THEN	-- (tipo_conciliación 0,10,12 y 15)
			
				IF(iEncontrado = 0 OR cArchivoOrigen <> cArchivoOrigenAnt) THEN
					IF cArchivoOrigen IN('VIC','VNC','MCC') THEN
						IF iEncontrado = 0 THEN					
							LET cTipoArchivo = 'Archivo de crédito con devoluciones pendientes';
							LET iEncontrado= 1;
							LET cArchivoOrigenAnt = cArchivoOrigen;
						END IF;
					ELIF cArchivoOrigen IN('VID','VND','MCD') THEN
						IF iEncontrado = 0 THEN
							LET cTipoArchivo = 'Archivo de débito con devoluciones pendientes';
							LET iEncontrado = 1;
							LET cArchivoOrigenAnt = cArchivoOrigen;
						END IF;
					END IF;
						
					-- Total Devoluciones Recibidas.
					SELECT COUNT(nomarchivo) INTO iDevrecibidas FROM bditarjeta:"informix".td_devolucionespos 
					WHERE nomarchivo = cNombreArchivo AND fecha = psFechaConsulta;
					
					-- Total Devoluciones Aplicadas (tipo_conciliacion = 14).
					SELECT COUNT(nomarchivo) INTO iDevaplicadas FROM bditarjeta:"informix".td_devolucionespos 
					WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado = 'A' AND aplicado = 'V';
					
					-- Total Devoluciones Aplicadas Forzadas (tipo_conciliacion = 11).
					SELECT COUNT(nomarchivo) INTO iDevaplicadasforzadas FROM bditarjeta:"informix".td_devolucionespos 
					WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado = 'F' AND aplicado = 'V';
					
					-- Total Devoluciones Conciliadas sin Aplicar (tipo_conciliacion 10 y 15).
					SELECT COUNT(nomarchivo) INTO iDevconciliadasSA FROM bditarjeta:"informix".td_devolucionespos 
					WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado IN('P','A','F') AND aplicado IN('F','E');
					
					-- Total Devoluciones con Error de Integridad (tipo_conciliacion 0 y 12).
					SELECT COUNT(nomarchivo) INTO iDevErrorIntegridad FROM bditarjeta:"informix".td_devolucionespos 
					WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'F' AND estado = 'P' AND aplicado IN('E','F');
					
					-- Total Devoluciones Faltantes.
					SELECT FIRST 1 iDevrecibidas - ( iDevaplicadas + iDevaplicadasforzadas ) INTO iDevFaltantes 
					FROM bditarjeta:"informix".td_devolucionespos;
					
					IF iDevrecibidas > 0 THEN
						LET cCodRet = '00001';
					END IF;
					RETURN cCodret,cTipoArchivo,cNombrearchivo,cFechacarga,iDevrecibidas,iDevaplicadas,iDevaplicadasforzadas,iDevconciliadasSA,iDevErrorIntegridad,iDevFaltantes,
							cNumTarjeta,cTipoOperacion,cMotivo,cNomcomercio,cReferencia,mMonto325,mMontocashbackarchivo WITH RESUME;
				END IF;
			ELSE	-- Archivos sin devoluciones(Crédito o Débito).
				IF cArchivoOrigen IN('VIC','VNC','MCC') THEN
					LET cTipoArchivo = 'Archivo de crédito sin devoluciones pendientes';
				ELIF cArchivoOrigen IN('VID','VND','MCD') THEN
					LET cTipoArchivo = 'Archivo de débito sin devoluciones pendientes';
				END IF;
					
				-- Total Devoluciones Recibidas.
				SELECT COUNT(nomarchivo) INTO iDevrecibidas FROM bditarjeta:"informix".td_devolucionespos 
				WHERE nomarchivo = cNombreArchivo AND fecha = psFechaConsulta;
				
				-- Total Devoluciones Aplicadas (tipo_conciliacion = 14).
				SELECT COUNT(nomarchivo) INTO iDevaplicadas FROM bditarjeta:"informix".td_devolucionespos 
				WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado = 'A' AND aplicado = 'V';
				
				-- Total Devoluciones Aplicadas Forzadas (tipo_conciliacion = 11).
				SELECT COUNT(nomarchivo) INTO iDevaplicadasforzadas FROM bditarjeta:"informix".td_devolucionespos 
				WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado = 'F' AND aplicado = 'V';
				
				-- Total Devoluciones Conciliadas sin Aplicar (tipo_conciliacion 10 y 15).
				SELECT COUNT(nomarchivo) INTO iDevconciliadasSA FROM bditarjeta:"informix".td_devolucionespos 
				WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado IN('P','A','F') AND aplicado IN('F','E');
				
				-- Total Devoluciones con Error de Integridad (tipo_conciliacion 0 y 12).
				SELECT COUNT(nomarchivo) INTO iDevErrorIntegridad FROM bditarjeta:"informix".td_devolucionespos 
				WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'F' AND estado = 'P' AND aplicado IN('E','F');
				
				-- Total Devoluciones Faltantes.
				SELECT FIRST 1 iDevrecibidas - ( iDevaplicadas + iDevaplicadasforzadas ) INTO iDevFaltantes 
				FROM bditarjeta:"informix".td_devolucionespos;
				
				IF iDevrecibidas > 0 THEN
					LET cCodRet = '00001';
				END IF;
				RETURN cCodret,cTipoArchivo,cNombrearchivo,cFechacarga,iDevrecibidas,iDevaplicadas,iDevaplicadasforzadas,iDevconciliadasSA,iDevErrorIntegridad,iDevFaltantes,
						cNumTarjeta,cTipoOperacion,cMotivo,cNomcomercio,cReferencia,mMonto325,mMontocashbackarchivo WITH RESUME;
			END IF;
		END FOREACH;
		
		LET cNombrearchivo = '';
		LET cFechacarga = '';
		LET cArchivoOrigen = '';
		
		FOREACH WITH HOLD -- Se regresa valores en 0 para casos donde no existen devoluciones dentro de archivos.
			SELECT distinct(nombrearchivo),fecha_archivo,archivo_origen INTO cNombrearchivo,cFechacarga,cArchivoOrigen 
			FROM bditarjeta:"informix".td_archivos_conciliacion WHERE fecha_archivo = psFechaConsulta 
			AND fecha_hora_fin_proceso > '1900-01-01 00:00:00.0' AND archivo_origen IN('VIC','VNC','VID','VND') 
			AND nombrearchivo NOT IN (select nomarchivo	from bditarjeta:"informix".td_devolucionespos where fecha = psFechaConsulta)			
						
			IF( cArchivoOrigen = 'VIC' OR cArchivoOrigen = 'VNC' OR cArchivoOrigen = 'MCC') THEN
				LET cTipoArchivo = 'Archivo de crédito sin devoluciones';
				LET iDevrecibidas = 0;
				LET iDevaplicadas = 0;
				LET iDevaplicadasforzadas = 0;
				LET iDevconciliadasSA = 0;
				LET iDevErrorIntegridad = 0;
				LET iDevFaltantes = 0;
				LET cCodRet = '00001';
				
				RETURN cCodret,cTipoArchivo,cNombrearchivo,cFechacarga,iDevrecibidas,iDevaplicadas,iDevaplicadasforzadas,iDevconciliadasSA,iDevErrorIntegridad,iDevFaltantes,
						cNumTarjeta,cTipoOperacion,cMotivo,cNomcomercio,cReferencia,mMonto325,mMontocashbackarchivo WITH RESUME;
				
			ELIF( cArchivoOrigen = 'VID' OR cArchivoOrigen = 'VND' OR cArchivoOrigen = 'MCD') THEN
				LET cTipoArchivo = 'Archivo de débito sin devoluciones';
				LET iDevrecibidas = 0;
				LET iDevaplicadas = 0;
				LET iDevaplicadasforzadas = 0;
				LET iDevconciliadasSA = 0;
				LET iDevErrorIntegridad = 0;
				LET iDevFaltantes = 0;
				LET cCodRet = '00001';
				
				RETURN cCodret,cTipoArchivo,cNombrearchivo,cFechacarga,iDevrecibidas,iDevaplicadas,iDevaplicadasforzadas,iDevconciliadasSA,iDevErrorIntegridad,iDevFaltantes,
						cNumTarjeta,cTipoOperacion,cMotivo,cNomcomercio,cReferencia,mMonto325,mMontocashbackarchivo WITH RESUME;
			END IF;
		END FOREACH;
	
	ELIF piTipoArchivo = 2 THEN -- Archivos de crédito con devoluciones pendientes
		
		FOREACH WITH HOLD
			SELECT distinct(nomarchivo),fecha INTO cNombrearchivo,cFechacarga 
			FROM bditarjeta:"informix".td_devolucionespos 
			WHERE archivoorigen IN('VIC','VNC','MCC') AND fecha = psFechaConsulta 
			AND ((encontrado = 'V' AND estado IN('P','A','F') AND aplicado IN('F','E')) OR 
				 (encontrado = 'F' AND estado = 'P' AND aplicado IN('E','F'))) -- (tipo_conciliación 0,10,12 y 15)
						
			LET cTipoArchivo = 'Archivo de crédito con devoluciones pendientes';
			
			-- Total Devoluciones Recibidas.
			SELECT COUNT(nomarchivo) INTO iDevrecibidas FROM bditarjeta:"informix".td_devolucionespos 
			WHERE nomarchivo = cNombreArchivo AND fecha = psFechaConsulta;
			
			-- Total Devoluciones Aplicadas (tipo_conciliacion = 14).
			SELECT COUNT(nomarchivo) INTO iDevaplicadas FROM bditarjeta:"informix".td_devolucionespos 
			WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado = 'A' AND aplicado = 'V';
			
			-- Total Devoluciones Aplicadas Forzadas (tipo_conciliacion = 11).
			SELECT COUNT(nomarchivo) INTO iDevaplicadasforzadas FROM bditarjeta:"informix".td_devolucionespos 
			WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado = 'F' AND aplicado = 'V';
			
			-- Total Devoluciones Conciliadas sin Aplicar (tipo_conciliacion 10 y 15).
			SELECT COUNT(nomarchivo) INTO iDevconciliadasSA FROM bditarjeta:"informix".td_devolucionespos 
			WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado IN('P','A','F') AND aplicado IN('F','E');
			
			-- Total Devoluciones con Error de Integridad (tipo_conciliacion 0 y 12).
			SELECT COUNT(nomarchivo) INTO iDevErrorIntegridad FROM bditarjeta:"informix".td_devolucionespos 
			WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'F' AND estado = 'P' AND aplicado IN('E','F');
			
			-- Total Devoluciones Faltantes.
			SELECT FIRST 1 iDevrecibidas - ( iDevaplicadas + iDevaplicadasforzadas ) INTO iDevFaltantes 
			FROM bditarjeta:"informix".td_devolucionespos;
									
			IF iDevrecibidas > 0 THEN
				LET cCodRet = '00001';
			END IF;
			RETURN cCodret,cTipoArchivo,cNombrearchivo,cFechacarga,iDevrecibidas,iDevaplicadas,iDevaplicadasforzadas,iDevconciliadasSA,iDevErrorIntegridad,iDevFaltantes,
					cNumTarjeta,cTipoOperacion,cMotivo,cNomcomercio,cReferencia,mMonto325,mMontocashbackarchivo WITH RESUME;
		END FOREACH;
		
	ELIF piTipoArchivo = 3 THEN -- Archivos de crédito sin devoluciones pendientes
				
		IF NOT EXISTS( SELECT nomarchivo FROM bditarjeta:"informix".td_devolucionespos 
						WHERE archivoorigen IN('VIC','VNC','MCC') AND fecha = psFechaConsulta 
						AND ((encontrado = 'V' AND estado IN('P','A','F') AND aplicado IN('F','E')) OR 
							(encontrado = 'F' AND estado = 'P' AND aplicado IN('E','F'))) ) THEN
		
			FOREACH WITH HOLD
				SELECT distinct(nomarchivo),fecha INTO cNombrearchivo,cFechacarga 
				FROM bditarjeta:"informix".td_devolucionespos 
				WHERE archivoorigen IN('VIC','VNC','MCC') AND fecha = psFechaConsulta 
				AND((encontrado = 'V' AND estado = 'F' AND aplicado = 'V') OR 
					(encontrado = 'V' AND estado = 'A' AND aplicado = 'V')) -- (tipo_conciliacion 11 y 14)
					
				LET cTipoArchivo = 'Archivo de crédito sin devoluciones pendientes';
				
				-- Total Devoluciones Recibidas.
				SELECT COUNT(nomarchivo) INTO iDevrecibidas FROM bditarjeta:"informix".td_devolucionespos 
				WHERE nomarchivo = cNombreArchivo AND fecha = psFechaConsulta;
				
				-- Total Devoluciones Aplicadas (tipo_conciliacion = 14).
				SELECT COUNT(nomarchivo) INTO iDevaplicadas FROM bditarjeta:"informix".td_devolucionespos 
				WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado = 'A' AND aplicado = 'V';
				
				-- Total Devoluciones Aplicadas Forzadas (tipo_conciliacion = 11).
				SELECT COUNT(nomarchivo) INTO iDevaplicadasforzadas FROM bditarjeta:"informix".td_devolucionespos 
				WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado = 'F' AND aplicado = 'V';
				
				-- Total Devoluciones Conciliadas sin Aplicar (tipo_conciliacion 10 y 15).
				SELECT COUNT(nomarchivo) INTO iDevconciliadasSA FROM bditarjeta:"informix".td_devolucionespos 
				WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado IN('P','A','F') AND aplicado IN('F','E');
				
				-- Total Devoluciones con Error de Integridad (tipo_conciliacion 0 y 12).
				SELECT COUNT(nomarchivo) INTO iDevErrorIntegridad FROM bditarjeta:"informix".td_devolucionespos 
				WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'F' AND estado = 'P' AND aplicado IN('E','F');
				
				-- Total Devoluciones Faltantes.
				SELECT FIRST 1 iDevrecibidas - ( iDevaplicadas + iDevaplicadasforzadas ) INTO iDevFaltantes 
				FROM bditarjeta:"informix".td_devolucionespos;
				
				IF iDevrecibidas > 0 THEN
					LET cCodRet = '00001';
				END IF;
				
				RETURN cCodret,cTipoArchivo,cNombrearchivo,cFechacarga,iDevrecibidas,iDevaplicadas,iDevaplicadasforzadas,iDevconciliadasSA,iDevErrorIntegridad,iDevFaltantes,
						cNumTarjeta,cTipoOperacion,cMotivo,cNomcomercio,cReferencia,mMonto325,mMontocashbackarchivo WITH RESUME;
			END FOREACH;
		END IF;
	
	ELIF piTipoArchivo = 4 THEN -- Archivos de débito con devoluciones pendientes
	
		FOREACH WITH HOLD
			SELECT distinct(nomarchivo),fecha INTO cNombrearchivo,cFechacarga 
			FROM bditarjeta:"informix".td_devolucionespos 
			WHERE archivoorigen IN('VID','VND','MCD') AND fecha = psFechaConsulta 
			AND ((encontrado = 'V' AND estado IN('P','A','F') AND aplicado IN('F','E')) OR 
				 (encontrado = 'F' AND estado = 'P' AND aplicado IN('E','F'))) -- (tipo_conciliación 0,10,12 y 15)
			
			LET cTipoArchivo = 'Archivo de débito con devoluciones pendientes';
			
			-- Total Devoluciones Recibidas.
			SELECT COUNT(nomarchivo) INTO iDevrecibidas FROM bditarjeta:"informix".td_devolucionespos 
			WHERE nomarchivo = cNombreArchivo AND fecha = psFechaConsulta;
			
			-- Total Devoluciones Aplicadas (tipo_conciliacion = 14).
			SELECT COUNT(nomarchivo) INTO iDevaplicadas FROM bditarjeta:"informix".td_devolucionespos 
			WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado = 'A' AND aplicado = 'V';
			
			-- Total Devoluciones Aplicadas Forzadas (tipo_conciliacion = 11).
			SELECT COUNT(nomarchivo) INTO iDevaplicadasforzadas FROM bditarjeta:"informix".td_devolucionespos 
			WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado = 'F' AND aplicado = 'V';
			
			-- Total Devoluciones Conciliadas sin Aplicar (tipo_conciliacion 10 y 15).
			SELECT COUNT(nomarchivo) INTO iDevconciliadasSA FROM bditarjeta:"informix".td_devolucionespos 
			WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado IN('P','A','F') AND aplicado IN('F','E');
			
			-- Total Devoluciones con Error de Integridad (tipo_conciliacion 0 y 12).
			SELECT COUNT(nomarchivo) INTO iDevErrorIntegridad FROM bditarjeta:"informix".td_devolucionespos 
			WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'F' AND estado = 'P' AND aplicado IN('E','F');
			
			-- Total Devoluciones Faltantes.
			SELECT FIRST 1 iDevrecibidas - ( iDevaplicadas + iDevaplicadasforzadas ) INTO iDevFaltantes 
			FROM bditarjeta:"informix".td_devolucionespos;
					
			IF iDevrecibidas > 0 THEN
				LET cCodRet = '00001';
			END IF;
			RETURN cCodret,cTipoArchivo,cNombrearchivo,cFechacarga,iDevrecibidas,iDevaplicadas,iDevaplicadasforzadas,iDevconciliadasSA,iDevErrorIntegridad,iDevFaltantes,
					cNumTarjeta,cTipoOperacion,cMotivo,cNomcomercio,cReferencia,mMonto325,mMontocashbackarchivo WITH RESUME;
		END FOREACH;
	
	ELIF piTipoArchivo = 5 THEN -- Archivos de débito sin devoluciones pendientes
				
		IF NOT EXISTS( SELECT nomarchivo FROM bditarjeta:"informix".td_devolucionespos 
						WHERE archivoorigen IN('VID','VND','MCD') AND fecha = psFechaConsulta 
						AND ((encontrado = 'V' AND estado IN('P','A','F') AND aplicado IN('F','E')) OR 
							(encontrado = 'F' AND estado = 'P' AND aplicado IN('E','F'))) ) THEN
		
			FOREACH WITH HOLD
				SELECT distinct(nomarchivo),fecha INTO cNombrearchivo,cFechacarga 
				FROM bditarjeta:"informix".td_devolucionespos 
				WHERE archivoorigen IN('VID','VND','MCD') AND fecha = psFechaConsulta 
				AND((encontrado = 'V' AND estado = 'F' AND aplicado = 'V') OR 
					(encontrado = 'V' AND estado = 'A' AND aplicado = 'V')) -- (tipo_conciliacion 11 y 14)
							
				LET cTipoArchivo = 'Archivo de débito sin devoluciones pendientes';
				
				-- Total Devoluciones Recibidas.
				SELECT COUNT(nomarchivo) INTO iDevrecibidas FROM bditarjeta:"informix".td_devolucionespos 
				WHERE nomarchivo = cNombreArchivo AND fecha = psFechaConsulta;
				
				-- Total Devoluciones Aplicadas (tipo_conciliacion = 14).
				SELECT COUNT(nomarchivo) INTO iDevaplicadas FROM bditarjeta:"informix".td_devolucionespos 
				WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado = 'A' AND aplicado = 'V';
				
				-- Total Devoluciones Aplicadas Forzadas (tipo_conciliacion = 11).
				SELECT COUNT(nomarchivo) INTO iDevaplicadasforzadas FROM bditarjeta:"informix".td_devolucionespos 
				WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado = 'F' AND aplicado = 'V';
				
				-- Total Devoluciones Conciliadas sin Aplicar (tipo_conciliacion 10 y 15).
				SELECT COUNT(nomarchivo) INTO iDevconciliadasSA FROM bditarjeta:"informix".td_devolucionespos 
				WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado IN('P','A','F') AND aplicado IN('F','E');
				
				-- Total Devoluciones con Error de Integridad (tipo_conciliacion 0 y 12).
				SELECT COUNT(nomarchivo) INTO iDevErrorIntegridad FROM bditarjeta:"informix".td_devolucionespos 
				WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'F' AND estado = 'P' AND aplicado IN('E','F');
				
				-- Total Devoluciones Faltantes.
				SELECT FIRST 1 iDevrecibidas - ( iDevaplicadas + iDevaplicadasforzadas ) INTO iDevFaltantes 
				FROM bditarjeta:"informix".td_devolucionespos;
				
				IF iDevrecibidas > 0 THEN
					LET cCodRet = '00001';
				END IF;
				RETURN cCodret,cTipoArchivo,cNombrearchivo,cFechacarga,iDevrecibidas,iDevaplicadas,iDevaplicadasforzadas,iDevconciliadasSA,iDevErrorIntegridad,iDevFaltantes,
						cNumTarjeta,cTipoOperacion,cMotivo,cNomcomercio,cReferencia,mMonto325,mMontocashbackarchivo WITH RESUME;
			END FOREACH;
		END IF;
	
	ELIF piTipoArchivo = 6 THEN -- Datos Detalle
	
		FOREACH WITH HOLD		
			SELECT numtarjeta,fecha,nomcomercio,referencia,montoarchivo,motivo,montocashbackarchivo
			INTO cNumTarjeta,cFechacarga,cNomcomercio,cReferencia,mMonto325,cMotivo,mMontocashbackarchivo
			FROM bditarjeta:"informix".td_devolucionespos 
			WHERE nomarchivo = psNombreArchivo AND fecha = psFechaConsulta
			
			LET cTipoOperacion = 'ABONO'; -- Valor por Default.
			LET cCodret = '00001';
					
			RETURN cCodret,cTipoArchivo,cNombrearchivo,cFechacarga,iDevrecibidas,iDevaplicadas,iDevaplicadasforzadas,iDevconciliadasSA,iDevErrorIntegridad,iDevFaltantes,
					cNumTarjeta,cTipoOperacion,cMotivo,cNomcomercio,cReferencia,mMonto325,mMontocashbackarchivo WITH RESUME;
			END FOREACH;
	END IF;
	
END
END PROCEDURE
DOCUMENT
'AUTOR: Arturo Méndez Cárdenas',
'Proyecto: ReingenieriaConciliacionAutomatica',
'Solicito: Jose Luis Puebla',
'Fecha: 2012/04/12',
'Version: 20120412.1605',
'BD: BdiTarjeta',
'',
'MODIFICACION: Arturo Méndez Cárdenas',
'Proyecto: ReingenieriaConciliacionAutomatica',
'Solicito: Jose Luis Puebla',
'Fecha: 2012/05/23',
'Version: 20120523.1542',
'BD: BdiTarjeta',
'',
'MODIFICACION: Arturo Méndez Cárdenas',
'Proyecto: ReingenieriaConciliacionAutomatica',
'Solicito: Jose Luis Puebla',
'Cambio: Se modifica para obtener archivos sin devoluciones',
'Fecha: 2012/06/22',
'Version: 20120622.0845',
'BD: BdiTarjeta',
'',
'MODIFICACION: Gómez Pérez Ilse Jazmín',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Luis Antonio Gomez',
'Cambio: Se integra un nuevo campo al proceso de estracción, para retornar el monto de transacciones Cash Back.',
'Fecha: 2013/08/27',
'Version: 20130821.1441',
'BD: BdiTarjeta',
'',
'MODIFICACION: Ricardo Reséndiz Martinez',
'Proyecto: Conciliacion MasterCard',
'Solicito: Luis Antonio Gomez',
'Cambio: Se integra archivos MCD y MCC para el procesos de clasificacion de ',
'Fecha: 2014/04/04',
'Version: 20140404.1322',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_sorteo_sat_pba (
		pdfecha date
		)

RETURNING 
			VARCHAR (5) AS CodRet, 
			VARCHAR(250) AS Mensaje_Respuesta;

--Definición de Variables de Error
DEFINE vicodigo 			integer;
DEFINE vsCodRet 			VARCHAR(5);
DEFINE vsMensaje_Respuesta 	VARCHAR(250);

--Definición de Variables de Error para central
DEFINE vsCodRet2 			VARCHAR(5);
DEFINE vsPbandera		 	VARCHAR(1);



--Definición de Variables de datos archivo
DEFINE viconsecutivo		integer;
DEFINE vsperiodo			varchar(4);
DEFINE vstporeg				varchar(2);
DEFINE vsemisor				varchar(4);
DEFINE vsfecha				varchar(6);
DEFINE vstarjeta			varchar(16);
DEFINE vsmonto				varchar(12);
DEFINE vmmonto			money;
DEFINE vssecuencia			varchar(6);
DEFINE vssecuencia2		varchar(7);
DEFINE vsreferencia			varchar(12);
DEFINE vsmontopremio		varchar(12);
DEFINE vmmontopremio	money;
DEFINE vsbin				varchar(6);
DEFINE vsproducto			Varchar(1);


	
--Definicion de variables de validaciones
DEFINE vsesreferencia			varchar(1);
DEFINE vsesmonto			varchar(1);
DEFINE vsessecuencia		varchar(1);
DEFINE vsesmontopremio		varchar(1);


--Definicion variables recuperadas de Intercard
DEFINE vssecintercard		varchar(7);
DEFINE vssecextendidainter	varchar(15);
DEFINE vmmontointercard		money;
DEFINE vdFechatransaccion 	DATETIME YEAR TO FRACTION(5);
DEFINE vsrefintercard		varchar(12);
DEFINE vsstatustarjeta		varchar(3);
DEFINE vsnumerocuenta		varchar(13);
DEFINE vsreferencia23_325 	varchar(23);

DEFINE vsfoliosuc    		varchar(16);

DEFINE vsencontrado 		Char(1);

--Definición de datos centrales
DEFINE vsretcentral			varchar(5);
DEFINE vsordenabono			varchar(16);
DEFINE vscoddevolucion		varchar(1);

DEFINE vdfechahoyinte		date;


--Definicion de variable de validacion
DEFINE vsvalidacion			varchar(1);
DEFINE vsErrorIntegridad	varchar(20);
DEFINE vsobservacion		varchar(40);

--Definición de bandera de ciclo
DEFINE vsFlagEnTransaccion 	varchar(1);
DEFINE viContadorRegistros 	integer;

--Para las transacciones a ser utilizadas
DEFINE vstranaplica		 	varchar(4);

-- Para retorno de Principal de Credito
DEFINE 	g_Remanente		money;
DEFINE  g_IntMoraCob   	money;
DEFINE  g_IntVencCob	money;
DEFINE  g_CapVencCob    money;
DEFINE  g_IntVigCob		money;
DEFINE  g_CapVigCob		money;
DEFINE  g_Impuesto		money;
DEFINE  g_Comision		money;
DEFINE	g_Seguro		money;

-- Para generacion de archivo

DEFINE 	vsql			char (1150);
DEFINE  vsfecencabezado   char(10);
DEFINE  vicontador 		integer;
DEFINE  vscontador		char(10);
DEFINE  viincremento	integer;
DEFINE  vicontador2		integer;


BEGIN
	ON EXCEPTION SET viCodigo   --cacha el error en caso de que exista y regresa un valor predeterminado

				RETURN 	vsCodRet, 
						vsMensaje_Respuesta;

	END EXCEPTION;

SET DEBUG FILE TO '/resplogifx/sp_sorteo_sat.out';
TRACE ON;

-- Inicialización de variables
LET 	vicodigo = 0;
LET		vsCodRet = '00000';
LET		vsMensaje_Respuesta = 'PROCESO TERMINADO SATISFACTORIAMENTE';

--Definición de Variables de Error para central
LET vsCodRet2 = '';
LET vsPbandera = '';

--Inicialización de Variables de datos archivo
LET 	viconsecutivo = 0;
LET 	vsperiodo = '';
LET 	vstporeg = '';
LET 	vsemisor = '';
LET 	vsfecha = '';
LET 	vstarjeta = '';
LET 	vsmonto = '';
LET 	vmmonto	= 0;
LET vssecuencia	= '';
LET vssecuencia2 = '';
LET vsreferencia = '';
LET vsmontopremio = '';
LET vmmontopremio = 0;
LET vsbin = '';
LET vsproducto = '';
	
--Inicilaizacion de variables de validacion

LET vsesreferencia	= '';
LET vsesmonto = '';
LET vsessecuencia = '';
LET vsesmontopremio = '';


--Inicializacion variables recuperadas de Intercard
LET vssecintercard = '';
LET vssecextendidainter = '';
LET vmmontointercard = 0;
LET vdFechatransaccion 	= CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5));
LET vsrefintercard = '';
LET vsstatustarjeta = '';
LET vsnumerocuenta = '';
LET vsreferencia23_325 = '';

LET vsfoliosuc = '';

LET vsencontrado = '';
--Inicialización de datos centrales
LET vsretcentral = '';
LET vsordenabono = '';
LET vscoddevolucion = '';


--Inicialización de variable de validacion
LET vsvalidacion = '';
LET vsErrorIntegridad = '';
LET vsobservacion = '';

LET vsFlagEnTransaccion = 'F';
LET viContadorRegistros = 0;

--Para las transacciones a ser utilizadas
LET vstranaplica  = '';

-- Inicializacion de variables de retorno de credito
LET  g_Remanente 	= 0.00;
LET  g_IntMoraCob 	= 0.00;
LET  g_IntVencCob 	= 0.00;
LET  g_CapVencCob  	= 0.00;
LET  g_IntVigCob	= 0.00;
LET  g_CapVigCob 	= 0.00;
LET  g_Impuesto		= 0.00;
LET  g_Comision 	= 0.00;
LET	 g_Seguro  		= 0.00;

-- Para generacion de archivo

LET 	vsql	= '';
LET     vsfecencabezado = '';
LET 	vicontador = 0;
LET 	vscontador = '';
LET  	viincremento = 0;
LET		vicontador2 = 0;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	Select fecha_hoy into vdfechahoyinte from Bdinteg:"informix".si_fechas;
	
	if pdfecha = vdfechahoyinte then
			FOREACH WITH HOLD
				Select consecutivo, periodofiscal, tporeg, banemisor, fechatransaccion, numtarjeta, montoarchivo, secuenciaarchivo, numrefarchivo, montopremio
						into viconsecutivo, vsperiodo, vstporeg, vsemisor, vsfecha, vstarjeta, vsmonto, vssecuencia, vsreferencia, vsmontopremio 
						from Bditarjeta:"informix".tb_sorteo_sat
							where validaciones = 'V' and 
									periodofiscal = '2014' -- Actualizar periodo para ejecucion 
						
				IF (vsFlagEnTransaccion = 'F') THEN 
					BEGIN WORK;
					LET vsFlagEnTransaccion = 'V';
				END IF;
						
			--		EXECUTE PROCEDURE Bditarjeta:"informix".sp_valida_sorteosat (viconsecutivo,vstarjeta,vsmonto,vssecuencia,vsreferencia,vsmontopremio)
			--			into vsCodRet, vsMensaje_Respuesta, vsvalidacion;
						
			--			if vsCodRet <> '00000' and vsvalidacion = 'F' then
			--				RETURN 		vsCodRet, 
			--								NVL(vsMensaje_Respuesta,'');
			--			else					
								
				LET vstranaplica = (CASE 	
										WHEN TRIM(SUBSTR(vstarjeta, 1,6)) in (select bin from Intercard:"informix".bines where creditodebito = 'D')	THEN '0326'
										WHEN TRIM(SUBSTR(vstarjeta, 1,6)) in (select bin from Intercard:"informix".bines where creditodebito = 'C') THEN '7860'
									END);
								
				EXECUTE PROCEDURE "informix".sp_busmovint_sat (vstarjeta, vssecuencia) 
						into vsCodRet, vssecintercard, vssecextendidainter, vmmontointercard, vdFechatransaccion, vsrefintercard,vsnumerocuenta ,vsstatustarjeta, vsreferencia23_325; 	
								let  vsfoliosuc	= 'i'||vssecextendidainter;
									
				if vsCodRet = '00000' then 
						update Bditarjeta:"informix".tb_sorteo_sat
								set
									secuenciaintercard = vssecintercard,
									secextendidainter = vssecextendidainter,
									montointercard = vmmontointercard,
									fchtransacintercard = vdFechatransaccion,
									numrefintercard = vsrefintercard,
									numcuenta = vsnumerocuenta,
									estatustarjeta = vsstatustarjeta,
									referencia23_325 = vsreferencia23_325,
									ordenabono = LPAD (vsfoliosuc,23,' '),
									tranaplica = vstranaplica
								where
									consecutivo = viconsecutivo;
											
						EXECUTE PROCEDURE "informix".sp_busmovdev_sat ( vstarjeta, vssecuencia )
								into vsCodRet, vsencontrado;
										
						if (vsCodRet = '00001'  and vsencontrado = 'V') then 
							update Bditarjeta:"informix".tb_sorteo_sat
								set
									validaciones = 'F',
									observacion = 'Movimiento fue devuelto'
								where
									consecutivo = viconsecutivo;
							LET vsvalidacion = 'F';
											
						elif (vsCodRet = '00000'  and vsencontrado = 'F') then
							update Bditarjeta:"informix".tb_sorteo_sat
								set
									validaciones = 'V',
									observacion = 'Movimiento aplica'
								where
									consecutivo = viconsecutivo;
							LET vsvalidacion = 'V';
						end if;
										
										/*    ###### Se comenta para quitar validaciones de los montos 11/12/2014 RRM
										if vmmontointercard <> ((vsmontopremio::MONEY)/100) then
											update Bditarjeta:"informix".tb_sorteo_sat
												set
													validaciones = 'F',
													observacion = 'Transaccion con montos diferentes'
												where
											consecutivo = viconsecutivo;
									
											LET vsvalidacion = 'F';
										end if;*/

						if  ((vsmontopremio::MONEY)/100) > 10000 then
							update Bditarjeta:"informix".tb_sorteo_sat
								set
									validaciones = 'F',
									observacion = 'Monto premio mayor a $10,000.00'
								where
									consecutivo = viconsecutivo;
											LET vsvalidacion = 'F';
						end if;
										
						if  ((vsmontopremio::MONEY)/100) = 0 then
							update Bditarjeta:"informix".tb_sorteo_sat
								set
									validaciones = 'F',
									observacion = 'Monto premio deber ser mayor $0.01'
								where
									consecutivo = viconsecutivo;
									LET vsvalidacion = 'F';
						end if;
										
										
						if vsstatustarjeta <> 'ACT' then
							update Bditarjeta:"informix".tb_sorteo_sat
								set
									validaciones = 'P',
									observacion = 'Tarjeta tiene estatus <> Activo'
								where
									consecutivo = viconsecutivo;
									LET vsvalidacion = 'P';		
						end if;
										
						if vsvalidacion in ('P','V') then 
						-- Se agrega proceso para la recuperacion de la direccción del Cliente premiado 
							EXECUTE PROCEDURE "informix".sp_busEdoPob_sat ( vstarjeta, viconsecutivo )
									into vsCodRet, vsencontrado;	
						end if;
				else
					update Bditarjeta:"informix".tb_sorteo_sat
						set
							secuenciaintercard = 	'000000',
							secextendidainter = 	'000000000000000',
							montointercard = 		0.0,
							fchtransacintercard = 	CAST('1900-10-10 12:00:00' AS DATETIME YEAR TO FRACTION(5)),
							numrefintercard = '0000000000000',
							numcuenta = '00000000000',
							estatustarjeta = 'NOE',
							ordenabono = '00000000000000000000000',
							tranaplica = '0000',
							validaciones = 'F',
							observacion = 'Transaccion no encontrada',
							referencia23_325 = '00000000000000000000000'
						where
							consecutivo = viconsecutivo;
							LET vsvalidacion = 'F';
				end if;
								
				COMMIT WORK;   
				BEGIN WORK;
								
				if (TRIM(SUBSTR(vstarjeta, 1,6)) in (select bin from Intercard:"informix".bines where creditodebito = 'D')
					and	vsvalidacion in ('P','V')) then

					execute procedure Bdicheq:"informix".abono_ref(
																	'001',						-- empresa
																	'9290',						-- sucursal
																	'informix', 				-- usuario
																	vstranaplica,				-- transaccion aplica
																	'0000', 					-- trasaccion sucursal
																	vsfoliosuc, 				-- Folio suc
																	vsnumerocuenta, 			-- numero de cuenta
																	'0', 						-- numero de documento
																	((vsmontopremio::MONEY)/100),		-- monto total
																	((vsmontopremio::MONEY)/100),		-- monto firme
																	0,							-- monto sbc
																	0,							-- monto remesa
																	0,							-- Dias retenido
																	'01',						-- divisa
																	'Premio Hacienda Buen Fin',	-- Referencia
																	' ',						-- numero de tarjeta
																	' ' 						-- usuario autoriza
																	)
						into vsCodRet;
											
					if 	vsCodRet = '000'	then
						update Bditarjeta:"informix".tb_sorteo_sat
							set
								retcentral = vsCodRet,
								codigodevolucion = '0'
							where
								consecutivo = viconsecutivo;
					else
						update Bditarjeta:"informix".tb_sorteo_sat
							set
								retcentral = vsCodRet,
								codigodevolucion = '1'
							where
								consecutivo = viconsecutivo;
					end if;
									
				elif (TRIM(SUBSTR(vstarjeta, 1,6)) in (select bin from Intercard:"informix".bines where creditodebito = 'C')
						and vsvalidacion in ('P','V'))  then
					EXECUTE PROCEDURE Bdicred:"informix".principal(
																	'001',							-- Empresa
																	vsnumerocuenta,					-- Numero de credito
																	1,								-- Tipo de pago
																	((vsmontopremio::MONEY)/100),	-- Monto
																	'informix',						-- Usuario
																	'9290',							-- Sucursal
																	vsfoliosuc,						-- Folio_suc
																	vstranaplica					-- Transaccion aplica
																	)
					into vsCodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
									
					if 	vsCodRet = '000'	then
						update Bditarjeta:"informix".tb_sorteo_sat
							set
								retcentral = vsCodRet,
								codigodevolucion = '0'
							where
								consecutivo = viconsecutivo;
					else
						update Bditarjeta:"informix".tb_sorteo_sat
							set
								retcentral = vsCodRet,
								codigodevolucion = '1'
							where
								consecutivo = viconsecutivo;
					end if;
								
				elif (TRIM(SUBSTR(vstarjeta, 1,6)) in (select bin from Intercard:"informix".bines where creditodebito = 'D') 
					and vsvalidacion in ('F'))  then
						
					update Bditarjeta:"informix".tb_sorteo_sat
						set
							retcentral = 'NP',
							codigodevolucion = '1'
						where
							consecutivo = viconsecutivo;
												
				elif (TRIM(SUBSTR(vstarjeta, 1,6)) in (select bin from Intercard:"informix".bines where creditodebito = 'C') 
					and vsvalidacion in ('F'))  then
					
					update Bditarjeta:"informix".tb_sorteo_sat
						set
							retcentral = 'NP',
							codigodevolucion = '1'
						where
							consecutivo = viconsecutivo;
									
				end if;
								
	--		end if;

				LET viContadorRegistros = viContadorRegistros + 1;

				--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
				IF (viContadorRegistros = 1000) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
					COMMIT WORK;
					--BEGIN WORK;
					LET vsFlagEnTransaccion = 'F';
					LET viContadorRegistros = 0;
					CONTINUE FOREACH;
				END IF;
			END FOREACH;
					
			IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
				COMMIT WORK;
				LET vsFlagEnTransaccion = 'F';
			END IF;
				
			LET  vsMensaje_Respuesta = 'Etapa 1 Completa';
		--end if;
	else
			LET	vsCodRet = '00001';
			LET	vsMensaje_Respuesta = 'Existe discrepancia en Fechas integral con ejecucion de proceso';
	end if;

				
	let vsfecencabezado = day(vdfechahoyinte)||'/'||month(vdfechahoyinte)||'/'||year(vdfechahoyinte);
				
	set isolation to dirty read;
	select count(*) into vicontador from Bditarjeta:tb_sorteo_sat
		where periodofiscal = '2014';  -- Actualizar periodo para ejecucion
		
	let vscontador = vicontador::char(10);
		
	LET viincremento = Length(vscontador);
		
	For vicontador2 = viincremento  TO 9 STEP 1
			LET vscontador = '0'||vscontador;
	end for;
	
	
			
				
	-- Primera linea del archivo
	let vsql = 'echo "00|1|SAT           |FECHA|'||vsfecencabezado||'|" >> /resplogifx/EntregaSAT2014.txt';
	system vsql;
	let vsql = '';
	let vsql = '';
	system vsql;
	-- Para generar comando de descarga de datos -- Actualizar periodo para ejecucion
	let vsql = '';
	let vsql = 	'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/SAT_BuenFin.unl '||
				'select  tporeg,banemisor,day(fchtransacintercard)||month(fchtransacintercard)||year(fchtransacintercard), numtarjeta,'||
				'montoarchivo,secuenciaarchivo,numrefarchivo,montopremio,ordenabono,codigodevolucion,codpostal,estado,poblacion from bditarjeta:"informix".tb_sorteo_sat where periodofiscal = ''"'||'2014'||'"'';">/resplogifx/SAT_BuenFin.sql';
			
	system vsql;
	-- Ejecución del comando anterior
	let vsql = '';
	let vsql = '';
	system vsql;
	let vsql= "dbaccess bditarjeta /resplogifx/SAT_BuenFin.sql";
	system vsql;
	-- Borrando sentencia de ejecucion
	let vsql = '';
	let vsql ='rm /resplogifx/SAT_BuenFin.sql';
	system vsql;
	let vsql = '';
	-- Agragando descarga a archivo final 
	let vsql = 'cat /resplogifx/SAT_BuenFin.unl >> /resplogifx/EntregaSAT2014.txt';
	system vsql;
	let vsql = '';
	let vsql = '';
	system vsql;
	-- Se le agrega espacido 
	let vsql = '';
	let vsql ='rm /resplogifx/SAT_BuenFin.unl';
	system vsql;
	let vsql = '';
	-- Agregando pie de archivo
	let vsql = 'echo "99|'||vscontador||'|" >> /resplogifx/EntregaSAT2014.txt';
	system vsql;
	
	LET	vsCodRet = '00000';
	LET  vsMensaje_Respuesta = 'Proceso completo se genero archivo EntregaSAT2014.txt';

	
	RETURN 	vsCodRet, 
			NVL(vsMensaje_Respuesta,'');

END 

END PROCEDURE
DOCUMENT
'AUTOR: Ricardo Resendiz Martinez',
'Proyecto: Sorteo de SAT del Buen Fin',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Proceso principal de proceso sorteo SAT',
'Fecha: 2013/11/20',
'Version: 20131112.1600',
'BD: bditarjeta',
'',
'AUTOR: Ricardo Resendiz Martinez',
'Proyecto: Sorteo de SAT del Buen Fin',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Proceso principal de proceso sorteo SAT con generacion de archivo de entrega al SAT',
'Fecha: 2013/11/26',
'Version: 20131126.1030',
'BD: bditarjeta',
'',
'AUTOR: Ricardo Resendiz Martinez',
'Proyecto: Sorteo de SAT del Buen Fin',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Se optimizo el proceso para busqueda optimizar forma de determinar la transaccion a ser aplicada',
'Fecha: 2013/11/26',
'Version: 20131126.1130',
'BD: bditarjeta',
'',
'AUTOR: Ricardo Resendiz Martinez',
'Proyecto: Sorteo de SAT del Buen Fin',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Se agrego spl el cual pemitira validar que el movimiento no se haya devuelto',
'Fecha: 2013/11/29',
'Version: 20131129.1820',
'BD: bditarjeta',
'',
'AUTOR: Ricardo Resendiz Martinez',
'Proyecto: Sorteo de SAT del Buen Fin',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Se agrego validaciones de monto premio',
'Fecha: 2013/12/02',
'Version: 20131202.1730',
'BD: bditarjeta',
'',
'Modifica: Ricardo Resendiz Martinez',
'Proyecto: Sorteo de SAT del Buen Fin',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Se agrega al proceso SPL el cual se encargara de recuperar los datos de estado y poblacion',
'Fecha: 2013/12/02',
'Version: 20131202.1730',
'BD: bditarjeta';

CREATE PROCEDURE "informix".sp_reporte_tarjetas_pba()
RETURNING 	CHAR (06) as cod_ret,
			CHAR (80) AS mensaje;
			
--variables de retorno
	DEFINE cod_ret CHAR(06);
	DEFINE mensaje CHAR(80);
	
 --variables de control de errores
	DEFINE  SQL_ERR			INTEGER;
	DEFINE  ISAM_ERR		INTEGER;
	DEFINE  ERROR_INFO		VARCHAR(80);			
	DEFINE	vpaso			INTEGER;	
	
--variables de proceso

	DEFINE vcont 			INTEGER;
	DEFINE vmax				datetime year to fraction(3)  ;
	
	
	--variables para datos
	                                                          
	DEFINE vbin              	char(6)                       ;
	DEFINE vcodstatustarjeta 	varchar(3)                    ;
	DEFINE vcodstatusasignada	varchar(3)                    ;
	DEFINE vtipo             	char(1)                       ;
	DEFINE vfechaexp         	varchar(4)                    ;
	DEFINE vproducto         	char(1)                       ;
	DEFINE vmarca            	char(1)                       ;
	DEFINE vtitular          	char(1)                       ;
	DEFINE vcantidad         	INTEGER                       ;
	DEFINE vfecha_ejecucion  	date                          ;
	DEFINE vfecha_exp			char(04)					  ;
	DEFINE vfecha_exp_min		char(04)					  ;
	DEFINE vfecha_exp_max		char(04)					  ;
	
--SET DEBUG FILE TO "/informix/frg/Rpts_Productos/sp_reporte_tarjetas.out";
--TRACE ON;
	
BEGIN
	ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET cod_ret    = SQL_ERR;
      LET mensaje  = SQL_ERR || ' ' || ISAM_ERR ||' en paso '|| vpaso ||' '|| ERROR_INFO ;
      RETURN cod_ret, mensaje;
	END EXCEPTION;

	let cod_ret = '00000';
	let mensaje = 'PROCESO EXITOSO';
	
	let vcont  = 0;
	
	set isolation to dirty read;
	
	SELECT {+INDEX(intercard:tarjeta idx_tarjeta2)} min(fechaexp),max(fechaexp)
	INTO vfecha_exp_min, vfecha_exp_max
	FROM intercard:tarjeta;	
	 
	let vpaso = 1;
	let vfecha_exp = lpad(substr( year(date(current)) ,3,2) ,2,'0' ) || lpad(month(date(current)),2,'0') ; 
	SELECT {+INDEX(reporte_tarjetas idx_reporte_tarjetas)} MAX(fecha_ejecucion) INTO vmax FROM reporte_tarjetas;
	
	
	IF vmax IS NOT NULL THEN
		
	 LET vfecha_exp_min = vfecha_exp;
	
	END IF
	
		foreach cursor1 WITH HOLD 
		
		for
		
				select distinct (b.bin),

					   t.codstatustarjeta,

					   t.codstatusasignada,

					  (CASE WHEN tipotar.chip = 'F' THEN 'B'

							WHEN tipotar.chip = 'V' THEN 'C'

							END) as tipo,          

					   t.fechaexp,

					   b.creditodebito as producto,      

					  (CASE WHEN SUBSTR(b.bin,1,1) = 4 THEN 'V'

							WHEN SUBSTR(b.bin,1,1) = 5 THEN 'M' END) as marca,

					  (CASE WHEN t.titular = 'T' THEN 'T'

							WHEN t.titular = 'A' THEN 'A'

							ELSE 'N' END) as titular,      

					   count(*) as cantidad,

					   date(current) as fecha_ejecucion
					   	INTO 	vbin              
							   , vcodstatustarjeta 
							   , vcodstatusasignada
							   , vtipo             
							   , vfechaexp         
							   , vproducto         							     
							   , vmarca            
							   , vtitular          
							   , vcantidad 
							   , vfecha_ejecucion
					   
							from intercard:bines as b, intercard:tarjeta as t, intercard:tipotarjeta as tipotar, intercard:lote as lt

							where b.bin = SUBSTR(t.numtarjeta,1,6)

							and t.fechaexp BETWEEN vfecha_exp_min AND vfecha_exp_max 

							  and tipotar.clave_tipotarjeta=lt.clave_tipotarjeta   

							  and t.numerolote=lt.numerolote

						group by 1,2,3,4,5,6,7,8

						order by 1,2,3,4,5,6,7,8
						
						
				     let vmarca = vmarca;
					 
				if vcont= 0 THEN
					
					BEGIN WORK;
					
				end IF
		
				let vpaso = 3;
				INSERT INTO reporte_tarjetas (bin, codstatustarjeta, codstatusasignada, tipo, fechaexp, producto, marca, titular, cantidad, fecha_ejecucion)
				VALUES( vbin, vcodstatustarjeta, vcodstatusasignada, vtipo, vfechaexp, vproducto, vmarca, vtitular, vcantidad, vfecha_ejecucion);

				let vcont = vcont + 1;      
		
				if vcont= 1000 THEN
					
					let vcont=0;            
					COMMIT WORK;
					
					
				end IF		
				
		
			end foreach;

			if vcont <> 0 THEN
					
					COMMIT WORK;
					
			end IF			
		
	
	
	  RETURN cod_ret, mensaje;	
END
END PROCEDURE;