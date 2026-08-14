CREATE PROCEDURE "informix".sp_sac_concimovtotal(pfecha DATE)
	returning 	char(5)  	as CodRetorno,
				CHAR(90)	as mensaje,
				INTEGER		AS enviados,
				INTEGER		AS conciliados,
				INTEGER		AS aplicados,
				INTEGER		AS errores,
				INTEGER		AS faltantes,
				CHAR(20)	AS nombre;
	--Elaboró: Alejandro Osuna Iza
	--Actividad: Extrae la información para la generacion de la pantalla de conciliacion
	--Solicito: Jorge Nuñez
	--Fecha: 16 de Marzo de 2010
	--Modificado:  07/04/2010 --Casanova Edeza Hector Juan --Se modifica el calculo de las transacciones Aplicadas y las faltantes de conciliar.
	

	--Declaracion de variables
	DEFINE vCodRet 			CHAR(5);
	DEFINE cSqlErr			INTEGER;
	DEFINE vmensaje			CHAR(90);
	DEFINE iTotalEnvi		INTEGER;
	DEFINE iErrores			INTEGER;
	DEFINE iAplicados		INTEGER;
	DEFINE iConciliado		INTEGER;
	DEFINE ifaltantes		INTEGER;
	DEFINE vNombre			CHAR(20);
	
	LET vCodRet 			= '00000';
	LET cSqlErr				= 0;
	LET vmensaje			= '';
	LET iTotalEnvi			= 0;
	LET iErrores			= 0;
	LET iAplicados			= 0;
	LET iConciliado			= 0;
	LET ifaltantes			= 0;
	LET vNombre				= '';
	
	--SET DEBUG FILE TO "/tmp/pitdc/sp_sac_concimovtotal.out";
	--TRACE ON;
	
	BEGIN
		 ON EXCEPTION SET cSqlErr
	        IF cSqlerr <> 0 THEN
				LET vmensaje = 'Error de Informix';
	            Let vCodRet = cSqlErr;
				RETURN vCodRet,vmensaje,iTotalEnvi,iConciliado,iAplicados,iErrores,ifaltantes,vNombre;
			END IF;
		END EXCEPTION;
		
		IF (pfecha is null ) OR (pfecha = '' ) THEN
			Let vCodRet = '07001';  
			SELECT TRIM(descripcion) INTO vmensaje FROM bdisac:sac_eglobal_mensajes_error WHERE  cod_ret = vCodRet;
			RETURN vCodRet,vmensaje,iTotalEnvi,iConciliado,iAplicados,iErrores,ifaltantes,vNombre;
		END IF;
	
	--1.- El Sistema valida que existe el registro de algún archivo que coincide con la Fecha recibida como dato de entrada.
		--	1.a.- El Sistema validó que no existe el registro de algún archivo que coincide con la Fecha recibida como dato de entrada.
		IF EXISTS(SELECT conciliado FROM bdisac:sac_eglobal_archivos where fecha_archivo = pfecha) THEN
			--2.- El Sistema valida que el Archivo obtenido tiene estatus de Transmitido.
			--2.a.- El Sistema validó que el Archivo obtenido no tiene estatus de Transmitido.
			IF EXISTS(SELECT conciliado FROM bdisac:sac_eglobal_archivos where fecha_archivo = pfecha and conciliado = '1') THEN
				IF EXISTS(SELECT conciliado FROM bdisac:sac_eglobal_archivos where fecha_archivo = pfecha and estatus = '1') THEN
					SELECT nombre_archivo into vNombre FROM bdisac:sac_eglobal_archivos where fecha_archivo = pfecha;
					SELECT total_registros INTO iTotalEnvi FROM bdisac:sac_eglobal_sumario WHERE fecha_archivo = pfecha;
					SELECT COUNT(sucursal) INTO iErrores FROM bdisac:sac_eglobal_noconcil WHERE fecha_archivo = pfecha;
					SELECT COUNT(cod_txn) INTO iConciliado FROM bdisac:sac_eglobal_detalle WHERE fecha_archivo = pfecha and conciliado = '1' ;
					SELECT COUNT(cod_txn) INTO ifaltantes FROM bdisac:sac_eglobal_detalle WHERE fecha_archivo = pfecha and conciliado = '0' ;
					LET iAplicados = iConciliado +  iErrores;
					--LET iAplicados = iTotalEnvi +  iErrores;
					--LET ifaltantes = iTotalEnvi - iErrores;
					
					LET vCodRet = '00000';
					SELECT TRIM(descripcion) INTO vmensaje FROM bdisac:sac_eglobal_mensajes_error WHERE  cod_ret = vCodRet;
					RETURN vCodRet,vmensaje,iTotalEnvi,iConciliado,iAplicados,iErrores,ifaltantes,vNombre;
				ELSE
					LET vCodRet = '06002';
					SELECT TRIM(descripcion) INTO vmensaje FROM bdisac:sac_eglobal_mensajes_error WHERE  cod_ret = vCodRet;
					RETURN vCodRet,vmensaje,iTotalEnvi,iConciliado,iAplicados,iErrores,ifaltantes,vNombre;
				END IF;
			ELSE
				LET vCodRet = '06003';
				SELECT TRIM(descripcion) INTO vmensaje FROM bdisac:sac_eglobal_mensajes_error WHERE  cod_ret = vCodRet;
				RETURN vCodRet,vmensaje,iTotalEnvi,iConciliado,iAplicados,iErrores,ifaltantes,vNombre;
			END IF;
		ELSE
			LET vCodRet = '06000';
			SELECT TRIM(descripcion) INTO vmensaje FROM bdisac:sac_eglobal_mensajes_error WHERE  cod_ret = vCodRet;
			RETURN vCodRet,vmensaje,iTotalEnvi,iConciliado,iAplicados,iErrores,ifaltantes,vNombre;
		END IF;
	END;	
END PROCEDURE
 DOCUMENT
'AUTOR: Alejandro Osuna Iza',
'Proyecto: Pago interbancario de tarjetas de credito',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: Extrae la información para la generacion de la pantalla de conciliacion',
'Fecha: 2010/03/16',
'Version: 20100316.0953',
'BD: BdiSac',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Pago interbancario de tarjetas de credito',
'Folio: 1113',
'Solicito: Jose Luis Puebla',
'Descripcion: Se modifica el calculo de las transacciones Aplicadas y las faltantes de conciliar.',
'Fecha: 2010/04/29',
'Version: 20100429.0934',
'BD: BdiSac';

CREATE PROCEDURE "informix".sp_dinya_consultaidentificaciones()
RETURNING
     CHAR(5), 
     CHAR(2),
     CHAR(30);

    DEFINE v_cod_ret       CHAR(5);
    DEFINE iSqlErr            INTEGER;
    DEFINE v_CodIden	CHAR(2);
    DEFINE v_DescIden   CHAR(30);
  
    LET  v_CodIden	     = "";
    LET  v_DescIden	    = "";
    LET  v_cod_ret        = "00000";

    --SET DEBUG FILE TO "/tmp/sp_dinya_consultaidentificaciones.out";
    --TRACE ON;

BEGIN
        ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET  v_cod_ret = iSqlErr;
			RETURN  v_cod_ret, v_CodIden, v_DescIden;
		END IF;
	END EXCEPTION;
   	
	IF EXISTS (SELECT identificacion FROM bdisac:sac_identificacion) THEN
		FOREACH
			SELECT      identificacion, descripcion
			INTO            v_CodIden, v_DescIden
			FROM          bdisac:sac_identificacion
                  WHERE identificacion <> '00'
                        ORDER BY identificacion
			RETURN     v_cod_ret, v_CodIden, v_DescIden WITH RESUME;

		END FOREACH;
	ELSE
		RETURN "00001",   v_CodIden, v_DescIden;
	END IF;
END
END PROCEDURE                             
Document
'DESCRIPCION: Consulta Catalogo de Identificaciones para llenar combo de la DLL BCOFI0020129',
'AUTOR: Saúl Ivanhoe Valdespino Hernández',
'FECHA: 30 de Octubre de 2009',
'VERSION: 20091030.1300',
'BD: BDISAC',           
'MODIFICÓ: Javier Chávez',
'MODIFICACIÓN: Se hizo mas grande el campo descripcion';

CREATE PROCEDURE "informix".sp_dinya_generadigitoverificador
					(
					cNoControl 	CHAR(11)	--> DINEROYA
					)
RETURNING CHAR(5),-->Codigo de Retorno
	  INTEGER ;   -->Dígito verificador

DEFINE vcodret          CHAR(5);
DEFINE vsqlerr          INT;
DEFINE iDigver			INT8;
DEFINE icontador		INT8;

LET vcodret = "000";
LET iDigver = 0;

 --SET DEBUG FILE TO "/tmp/Antonio/sp_DinYa_GeneradigitoVerificador.out";
 --TRACE ON;

BEGIN

	ON EXCEPTION
	   SET vsqlerr
	   LET vcodret = vsqlerr;

	   RETURN vcodret,--> Codigo de Retorno
	          iDigver;	--> Fecha de Ultimo Pago
	END EXCEPTION;
	
	LET cNoControl = LPAD(TRIM(cNoControl),11,'0');
	
	let iContador = substr(cNoControl,1,1) * 1;
	let iContador = iContador + substr(cNoControl,2,1) * 4;
	let iContador = iContador + substr(cNoControl,3,1) * 7;
	let iContador = iContador + substr(cNoControl,4,1) * 1;
	let iContador = iContador + substr(cNoControl,5,1) * 4;
	let iContador = iContador + substr(cNoControl,6,1) * 7;
	let iContador = iContador + substr(cNoControl,7,1) * 1;
	let iContador = iContador + substr(cNoControl,8,1) * 4;
	let iContador = iContador + substr(cNoControl,9,1) * 7;
	let iContador = iContador + substr(cNoControl,10,1) * 1;
	let iContador = iContador + substr(cNoControl,11,1) * 4;
	let iContador = iContador + 48;
	let iContador = mod(iContador, 9);
	let iDigver = iContador + 1;
    RETURN vcodret, iDigver;

END
END PROCEDURE
DOCUMENT
'AUTOR: Antonio Bastidas',
'DESCRIPCION: Se genera proceso para obtener el digito verficador para envío de DineroYa', 
'FECHA: DICIEMBRE 2009',
'BD: BDISAC',
'VERSION: 20091204.1320';

CREATE PROCEDURE "informix".sp_dinya_obtenerdetalleenvio
	(pNoControl CHAR(12))

RETURNING  CHAR(5),CHAR(12),DATE,CHAR(8),CHAR(4),CHAR(26),CHAR(26),CHAR(26),CHAR(26),CHAR(20),MONEY (16,2),CHAR(16),
			DATE,CHAR(8),CHAR(8),CHAR(26),CHAR(26),CHAR(26),CHAR(26),CHAR(20),CHAR(20),CHAR(2),CHAR(25),CHAR(3),CHAR(16);

DEFINE cCodRet 			CHAR(5);
DEFINE cNumconvenio		CHAR(3);
DEFINE cFechaEnvio 		DATE;
DEFINE cFechaPago 		DATE;
DEFINE cSucursalOrigen 	CHAR(4);
DEFINE cSucCobropago 	CHAR(4);
DEFINE cHoraEnvio	 	DATETIME HOUR TO SECOND;
DEFINE cHoraPago	 	DATETIME HOUR TO SECOND;
DEFINE cFolioSucEnvio	CHAR(16);
DEFINE cFolioSucPago	CHAR(16);
DEFINE cTelrem	 		CHAR(20);
DEFINE cTelben	 		CHAR(20);
DEFINE cNombre1Rem 		CHAR(26);
DEFINE cNombre1ben 		CHAR(26);
DEFINE cNombre2Rem 		CHAR(26);
DEFINE cNombre2ben 		CHAR(26);
DEFINE cApellido1Rem 	CHAR(26);
DEFINE cApellido1ben 	CHAR(26);
DEFINE cApellido2Rem 	CHAR(26);
DEFINE cApellido2ben 	CHAR(26);
DEFINE cNumIdent 		CHAR(25);
DEFINE mImporteEnviado 	MONEY (16,2);
DEFINE cEstatus 		CHAR(20);
DEFINE cIdentifi 		CHAR(2);
DEFINE iSqlErr			INTEGER;
DEFINE cNocontrol		CHAR(12);
DEFINE isam_error		INTEGER;
DEFINE cMensaje			CHAR(50);
DEFINE dfechoy			DATE;

BEGIN

	ON EXCEPTION SET iSqlErr,isam_error,cMensaje
		IF iSqlErr != 0 THEN
			LET cCodRet= iSqlErr;
			INSERT INTO sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)
			VALUES (iSqlErr,isam_error,cMensaje,'sp_DinYa_ObtenerDetalleEnvio',dfechoy,CURRENT );
			RETURN NVL(cCodRet,''),NVL(cNocontrol,''),NVL(cFechaEnvio,''),NVL(cHoraEnvio,''),NVL(cSucursalOrigen,''),NVL(cNombre1rem,''),NVL(cNombre2rem,''),NVL(cApellido1rem,''),NVL(cApellido2rem,''),NVL(cTelrem,''),NVL(mImporteEnviado,'')
			,NVL(cFolioSucEnvio,''),NVL(cFechaPago,''),NVL(cHoraPago,''), NVL(cSucCobropago,''),NVL(cNombre1ben,''),NVL(cNombre2ben,''),NVL(cApellido1ben,''),NVL(cApellido2ben,''),NVL(cTelben,''),NVL(cEstatus,''),NVL(cIdentifi,''),NVL(cNumIdent,''),
			NVL(cNumconvenio,''),NVL(cFolioSucPago,'');
		END IF;
	END EXCEPTION;


 --SET DEBUG FILE TO "/tmp/sp_DinYa_ObtenerDetalleEnvio.out";
 --TRACE ON;


LET cCodRet 			= '00000';
LET cNumconvenio 		= '';
LET cFechaEnvio 		= '';
LET cFechaPago			= '';
LET cSucursalOrigen 	= '';
LET cSucCobropago 	= '';
LET cNombre1Rem 		= '';
LET cNombre1ben 		= '';
LET cNombre2Rem 		= '';
LET cNombre2ben 		= '';
LET cApellido1Rem 		= '';
LET cApellido1ben 		= '';
LET cApellido2Rem 		= '';
LET cApellido2ben 		= '';
LET mImporteEnviado 	= '0.00';
LET cEstatus 			= '';
LET cIdentifi 			= '';
LET cHoraEnvio			= '';
LET cHoraPago			= '';
LET cTelrem				= '';
LET cTelben				= '';
LET cFolioSucEnvio		= '';
LET cFolioSucPago		= '';
LET cNumIdent			= '';
LET cNocontrol			= '';
LET cMensaje			= '';
LET dfechoy				= '';
LET iSqlErr				= 0;
LET isam_error			= 0;

 SELECT fecha_hoy INTO dfechoy FROM bdisac:sac_fechas;

 FOREACH
	SELECT  env.no_control,env.fecha_envio,env.suc_origen,env.pri_nom_rem,env.seg_nom_rem,env.apell_pat_rem,env.apell_mat_rem,
			env.telefono_rem,env.importe_envio,NVL(TRIM(mov.folio_suc),'') || NVL(TRIM(movh.folio_suc),''),env.fecha_pago, suc_cobropago,env.pri_nom_ben,env.seg_nom_ben,
			env.apell_pat_ben,env.apell_mat_ben,env.telefono_ben, est.descripcion,env.identificacion,env.num_ident,TRIM(mov.numconvenio) || TRIM(movh.numconvenio)
	INTO cNocontrol,cFechaEnvio,cSucursalOrigen,cNombre1rem,cNombre2rem,cApellido1rem,cApellido2rem,cTelrem,mImporteEnviado,cFolioSucEnvio,
		 cFechaPago, cSucCobropago,cNombre1ben,cNombre2ben,cApellido1ben,cApellido2ben,cTelben,cEstatus,cIdentifi,cNumIdent,cNumconvenio
	FROM sac_enviosdineroya AS env
	LEFT JOIN sac_movimientos AS mov ON (env.no_control = mov.referencia1 AND mov.numcategoria = '07' AND mov.numconvenio = '001')
	LEFT JOIN sac_movimientoshistorial AS movh ON (env.no_control = movh.referencia1 AND movh.numcategoria = '07' AND movh.numconvenio = '001')
	INNER JOIN sac_estatus as est ON (env.estatus = est.estatus)
	WHERE env.no_control = pNoControl


	UNION ALL

	SELECT  env.no_control,env.fecha_envio,env.suc_origen,env.pri_nom_rem,env.seg_nom_rem,env.apell_pat_rem,env.apell_mat_rem,
			env.telefono_rem,env.importe_envio,NVL(TRIM(mov.folio_suc),'') || NVL(TRIM(movh.folio_suc),''),env.fecha_pago, suc_cobropago,env.pri_nom_ben,env.seg_nom_ben,
			env.apell_pat_ben,env.apell_mat_ben,env.telefono_ben,est.descripcion,env.identificacion,env.num_ident,mov.numconvenio
	FROM sac_enviosdineroyahis AS env
	LEFT JOIN sac_movimientos AS mov ON (env.no_control = mov.referencia1 AND mov.numcategoria = '07' AND mov.numconvenio = '001')
	LEFT JOIN sac_movimientoshistorial AS movh ON (env.no_control = movh.referencia1 AND movh.numcategoria = '07' AND movh.numconvenio = '001')
	INNER JOIN sac_estatus as est ON (env.estatus = est.estatus)
	WHERE env.no_control = pNoControl

 END FOREACH;

 FOREACH
	SELECT NVL(TRIM(mov.folio_suc),'')
	INTO cFolioSucPago
	FROM sac_enviosdineroya AS env
	LEFT JOIN sac_movimientos AS mov ON (env.no_control = mov.referencia1 AND mov.numcategoria = '07' AND mov.numconvenio = '002')
	LEFT JOIN sac_movimientoshistorial AS movh ON (env.no_control = movh.referencia1 AND movh.numcategoria = '07' AND movh.numconvenio = '002')
	WHERE env.no_control = pNoControl


	UNION ALL

	SELECT NVL(TRIM(movh.folio_suc),'')
	FROM sac_enviosdineroyahis AS env
	LEFT JOIN sac_movimientos AS mov ON (env.no_control = mov.referencia1 AND mov.numcategoria = '07' AND mov.numconvenio = '002')
	LEFT JOIN sac_movimientoshistorial AS movh ON (env.no_control = movh.referencia1 AND movh.numcategoria = '07' AND movh.numconvenio = '002')
	WHERE env.no_control = pNoControl

 END FOREACH;

 FOREACH
   SELECT hora_envio,hora_pago
   INTO cHoraEnvio,cHoraPago
   FROM sac_enviosdineroya
   WHERE no_control = pNoControl

   UNION ALL

   SELECT hora_envio,hora_pago
   FROM sac_enviosdineroyahis
   WHERE no_control = pNoControl
 END FOREACH;


	RETURN NVL(cCodRet,''),NVL(cNocontrol,''),NVL(cFechaEnvio,''),NVL(cHoraEnvio,''),NVL(cSucursalOrigen,''),NVL(cNombre1rem,''),NVL(cNombre2rem,''),NVL(cApellido1rem,''),NVL(cApellido2rem,''),NVL(cTelrem,''),NVL(mImporteEnviado,'')
	,NVL(cFolioSucEnvio,''),NVL(cFechaPago,''),NVL(cHoraPago,''), NVL(cSucCobropago,''),NVL(cNombre1ben,''),NVL(cNombre2ben,''),NVL(cApellido1ben,''),NVL(cApellido2ben,''),NVL(cTelben,''),NVL(cEstatus,''),NVL(cIdentifi,''),NVL(cNumIdent,''),
	NVL(cNumconvenio,''),NVL(cFolioSucPago,'');
END
END PROCEDURE
Document
'DESCRIPCION: Consulta los movimientos a detalle de DineroYa',
'AUTOR: Antonio Bastidas',
'FECHA: 12 de Noviembre de 2009',
'MODIFICO: Clemente Angulo Ballardo',
'DESCRIPCION: Se modifica para que en lugar de regresar el codigo del estatus regresara la descripcion del estatus',
'MODIFICO: Antonio Bastidas',
'DESCRIPCION: Se modifica al incluir un NVL en la concatenacion del folio_suc de movimientos y de movimientos historicos',
'BD: BDISAC',
'VERSION: 20100514.1120';

CREATE PROCEDURE "informix".sp_dinya_obtienedetdiario(pConvenio CHAR(5), pFechaInicial DATE, pFechaFinal DATE)

RETURNING CHAR(5) AS cRegreso1, 
		  CHAR(10) AS cRegreso2, 
		  CHAR(8) AS cRegreso3, 
		  CHAR(12) AS cRegreso4, 
		  CHAR(4) AS cRegreso5, 
		  CHAR(26) AS cRegreso6, 
		  CHAR(26) AS cRegreso7, 
		  CHAR(26) AS cRegreso8, 
		  CHAR(26) AS cRegreso9, 
		  MONEY (16,2) AS cRegreso10, 
		  CHAR(10) AS cRegreso11, 
		  CHAR(8) AS cRegreso12,
		  CHAR(4) AS cRegreso13,
		  CHAR(26) AS cRegreso14, 
		  CHAR(26) AS cRegreso15, 
		  CHAR(26) AS cRegreso16, 
		  CHAR(26) AS cRegreso17,
		  CHAR(20) AS cRegreso18;

DEFINE cCodRet 			CHAR(5);
DEFINE cFechaEnvio 		DATE;
DEFINE cHoraEnvio	 	DATETIME HOUR TO SECOND;
DEFINE cNocontrol		CHAR(12);
DEFINE cSucursalOrigen 	CHAR(4);
DEFINE cNombre1Rem 		CHAR(26);
DEFINE cNombre2Rem 		CHAR(26);
DEFINE cApellido1Rem 	CHAR(26);
DEFINE cApellido2Rem 	CHAR(26);
DEFINE mImporteEnviado 	MONEY (16,2);
DEFINE cFechaPago 		DATE;
DEFINE cHoraPago	 	DATETIME HOUR TO SECOND;
DEFINE cSucCobropago 	CHAR(4);
DEFINE cNombre1ben 		CHAR(26);
DEFINE cNombre2ben 		CHAR(26);
DEFINE cApellido1ben 	CHAR(26);
DEFINE cApellido2ben 	CHAR(26);
DEFINE cEstatus 		CHAR(20);
DEFINE cSqlErr			INTEGER;
DEFINE iContador		INTEGER;
DEFINE isam_err			INTEGER;
DEFINE cMensaje			CHAR(200);
DEFINE cFechaHoy       DATE;

LET cCodRet = '00000';
LET cFechaEnvio = CURRENT;
LET cHoraEnvio	= CURRENT;
LET cNocontrol	= 0;
LET cSucursalOrigen = '';
LET cNombre1Rem = '';
LET cNombre2Rem = '';
LET cApellido1Rem = '';
LET cApellido2Rem = '';
LET mImporteEnviado = 0.00;
LET cFechaPago = CURRENT;
LET cHoraPago = CURRENT;
LET cSucCobropago = '';
LET cNombre1ben = '';
LET cNombre2ben = '';
LET cApellido1ben = '';
LET cApellido2ben = '';
LET cEstatus = '';
LET cSqlerr	= 0;
LET iContador	= 0;
LET isam_err	= '';
LET cMensaje	= '';
LET cFechaHoy = CURRENT;



BEGIN
	 ON EXCEPTION SET cSqlerr, isam_err, cMensaje
        IF cSqlerr <> 0 THEN
            Let cCodret = cSqlerr;  
			INSERT INTO sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)
			VALUES (cSqlerr,isam_err,cMensaje,'sp_Dinya_ObtieneDetDiario',cFechaHoy,CURRENT );  
			RETURN NVL(cCodRet,'') , NVL(cFechaEnvio,'') , NVL(cHoraEnvio,'') , NVL(cNocontrol,'') , NVL(cSucursalOrigen,'') , NVL(cNombre1Rem,'') , NVL(cNombre2Rem,'') , 
			       NVL(cApellido1Rem,'') , NVL(cApellido2Rem,'') , NVL(mImporteEnviado,'') , NVL(cFechaPago,'') , NVL(cHoraPago,'') , NVL(cSucCobropago,'') , NVL(cNombre1ben,'') ,
				   NVL(cNombre2ben,'') , NVL(cApellido1ben,'') , NVL(cApellido2ben,'') , NVL(cEstatus,'');
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/Antonio/sp_Dinya_ObtieneDetDiario.out";
	--TRACE ON;
	
	--se obtiene la fecha de la sac_fechas
	SELECT fecha_hoy INTO cFechaHoy FROM sac_fechas WHERE empresa = '001';
	
	IF (( pFechaInicial = '' OR (pFechaInicial IS NULL)) OR ( pFechaFinal = '' OR (pFechaFinal IS NULL))) THEN
		--No estan todos los parametros
		LET cCodRet = '00001';
		RETURN NVL(cCodRet,'') , NVL(cFechaEnvio,'') , NVL(cHoraEnvio,'') , NVL(cNocontrol,'') , NVL(cSucursalOrigen,'') , NVL(cNombre1Rem,'') , NVL(cNombre2Rem,'') , 
			   NVL(cApellido1Rem,'') , NVL(cApellido2Rem,'') , NVL(mImporteEnviado,'') , NVL(cFechaPago,'') , NVL(cHoraPago,'') , NVL(cSucCobropago,'') , NVL(cNombre1ben,'') ,
		       NVL(cNombre2ben,'') , NVL(cApellido1ben,'') , NVL(cApellido2ben,'') , NVL(cEstatus,'');
	END IF;
	IF pConvenio = '' OR (pConvenio IS NULL) THEN

		FOREACH 

			SELECT fecha_envio,hora_envio, no_control,suc_origen,pri_nom_rem,seg_nom_rem,apell_pat_rem,apell_mat_rem,importe_envio,env.fecha_pago,hora_pago,suc_cobropago,
				pri_nom_ben,seg_nom_ben,apell_pat_ben,apell_mat_ben, es.descripcion
			INTO cFechaEnvio, cHoraEnvio, cNocontrol, cSucursalOrigen, cNombre1Rem, cNombre2Rem, cApellido1Rem, cApellido2Rem, mImporteEnviado, cFechaPago, cHoraPago,
				 cSucCobropago, cNombre1ben, cNombre2ben, cApellido1ben, cApellido2ben, cEstatus
			FROM bdisac:sac_enviosdineroya AS env
			INNER JOIN bdisac:sac_estatus AS es ON (env.estatus = es.estatus)
			WHERE fecha_envio >= pFechaInicial
			AND fecha_envio <= pFechaFinal

			UNION ALL

			SELECT fecha_envio,hora_envio, no_control,suc_origen,pri_nom_rem,seg_nom_rem,apell_pat_rem,apell_mat_rem,importe_envio,env.fecha_pago,hora_pago,suc_cobropago,
				pri_nom_ben,seg_nom_ben,apell_pat_ben,apell_mat_ben, es.descripcion
			FROM bdisac:sac_enviosdineroyahis AS env
			INNER JOIN bdisac:sac_estatus AS es ON (env.estatus = es.estatus)
			WHERE fecha_envio >= pFechaInicial
			AND fecha_envio <= pFechaFinal
			ORDER BY fecha_envio,hora_envio,no_control
			
			LET iContador = Icontador + 1;
			
			RETURN NVL(cCodRet,'') , NVL(cFechaEnvio,'') , NVL(cHoraEnvio,'') , NVL(cNocontrol,'') , NVL(cSucursalOrigen,'') , NVL(cNombre1Rem,'') , NVL(cNombre2Rem,'') , 
				   NVL(cApellido1Rem,'') , NVL(cApellido2Rem,'') , NVL(mImporteEnviado,'') , NVL(cFechaPago,'') , NVL(cHoraPago,'') , NVL(cSucCobropago,'') , NVL(cNombre1ben,'') ,
			       NVL(cNombre2ben,'') , NVL(cApellido1ben,'') , NVL(cApellido2ben,'') , NVL(cEstatus,'') WITH RESUME;
		END FOREACH;   
		
	ELSE

		IF pConvenio = '07001' THEN
			FOREACH 
			
				SELECT fecha_envio,hora_envio, no_control,suc_origen,pri_nom_rem,seg_nom_rem,apell_pat_rem,apell_mat_rem,importe_envio,
						env.fecha_pago,hora_pago,suc_cobropago,pri_nom_ben,seg_nom_ben,apell_pat_ben,apell_mat_ben, es.descripcion
				INTO cFechaEnvio, cHoraEnvio, cNocontrol, cSucursalOrigen, cNombre1Rem, cNombre2Rem, cApellido1Rem, cApellido2Rem, mImporteEnviado, cFechaPago, cHoraPago,  
					 cSucCobropago, cNombre1ben, cNombre2ben, cApellido1ben, cApellido2ben, cEstatus
				FROM bdisac:sac_enviosdineroya AS env,
				OUTER bdisac:sac_estatus as es,
				OUTER bdisac:sac_movimientos as mov,
				OUTER bdisac:sac_movimientoshistorial as movh
				WHERE  env.estatus IN ('01','03')
				    AND env.estatus = es.estatus
				    AND env.no_control = mov.referencia1  
				    AND mov.numcategoria||mov.numconvenio = pConvenio
				    AND env.no_control = movh.referencia1
				    AND movh.numcategoria||movh.numconvenio = pConvenio
					AND fecha_envio >= pFechaInicial
					AND fecha_envio <= pFechaFinal

				UNION ALL


				SELECT fecha_envio,hora_envio, no_control,suc_origen,pri_nom_rem,seg_nom_rem,apell_pat_rem,apell_mat_rem,importe_envio,
						env.fecha_pago,hora_pago,suc_cobropago,pri_nom_ben,seg_nom_ben,apell_pat_ben,apell_mat_ben, es.descripcion
				FROM bdisac:sac_enviosdineroyahis AS env,
				OUTER bdisac:sac_estatus as es,
				OUTER bdisac:sac_movimientos as mov,
				OUTER bdisac:sac_movimientoshistorial as movh
				WHERE  env.estatus IN ('01','03')
				    AND env.estatus = es.estatus
				    AND env.no_control = mov.referencia1  
				    AND mov.numcategoria||mov.numconvenio = pConvenio
				    AND env.no_control = movh.referencia1
				    AND movh.numcategoria||movh.numconvenio = pConvenio
				    AND fecha_envio >= pFechaInicial
					AND fecha_envio <= pFechaFinal
					ORDER BY fecha_envio,hora_envio,no_control
				
				LET iContador = Icontador + 1;
				
				RETURN NVL(cCodRet,'') , NVL(cFechaEnvio,'') , NVL(cHoraEnvio,'') , NVL(cNocontrol,'') , NVL(cSucursalOrigen,'') , NVL(cNombre1Rem,'') , NVL(cNombre2Rem,'') , 
					   NVL(cApellido1Rem,'') , NVL(cApellido2Rem,'') , NVL(mImporteEnviado,'') , NVL(cFechaPago,'') , NVL(cHoraPago,'') , NVL(cSucCobropago,'') , NVL(cNombre1ben,'') ,
				       NVL(cNombre2ben,'') , NVL(cApellido1ben,'') , NVL(cApellido2ben,'') , NVL(cEstatus,'') WITH RESUME;
			END FOREACH;
		ElIF pConvenio = '07002' THEN
			FOREACH 
			
				SELECT fecha_envio,hora_envio, no_control,suc_origen,pri_nom_rem,seg_nom_rem,apell_pat_rem,apell_mat_rem,importe_envio,
						env.fecha_pago,hora_pago,suc_cobropago,pri_nom_ben,seg_nom_ben,apell_pat_ben,apell_mat_ben, es.descripcion
				INTO cFechaEnvio, cHoraEnvio, cNocontrol, cSucursalOrigen, cNombre1Rem, cNombre2Rem, cApellido1Rem, cApellido2Rem, mImporteEnviado, cFechaPago, cHoraPago,  
					 cSucCobropago, cNombre1ben, cNombre2ben, cApellido1ben, cApellido2ben, cEstatus
				FROM bdisac:sac_enviosdineroya AS env,
				OUTER bdisac:sac_estatus as es,
				OUTER bdisac:sac_movimientos as mov,
				OUTER bdisac:sac_movimientoshistorial as movh
				WHERE  env.estatus IN ('04')
				    AND env.estatus = es.estatus
				    AND env.no_control = mov.referencia1  
				    AND mov.numcategoria||mov.numconvenio = pConvenio
				    AND env.no_control = movh.referencia1
				    AND movh.numcategoria||movh.numconvenio = pConvenio
					AND fecha_envio >= pFechaInicial
					AND fecha_envio <= pFechaFinal
					

				UNION ALL


				SELECT fecha_envio,hora_envio, no_control,suc_origen,pri_nom_rem,seg_nom_rem,apell_pat_rem,apell_mat_rem,importe_envio,
						env.fecha_pago,hora_pago,suc_cobropago,pri_nom_ben,seg_nom_ben,apell_pat_ben,apell_mat_ben, es.descripcion
				FROM bdisac:sac_enviosdineroyahis AS env,
				OUTER bdisac:sac_estatus as es,
				OUTER bdisac:sac_movimientos as mov,
				OUTER bdisac:sac_movimientoshistorial as movh
				WHERE  env.estatus IN ('04')
				    AND env.estatus = es.estatus
				    AND env.no_control = mov.referencia1  
				    AND mov.numcategoria||mov.numconvenio = pConvenio
				    AND env.no_control = movh.referencia1
				    AND movh.numcategoria||movh.numconvenio = pConvenio
				    AND fecha_envio >= pFechaInicial
					AND fecha_envio <= pFechaFinal
					ORDER BY fecha_envio,hora_envio,no_control
				
				LET iContador = Icontador + 1;
				
				RETURN NVL(cCodRet,'') , NVL(cFechaEnvio,'') , NVL(cHoraEnvio,'') , NVL(cNocontrol,'') , NVL(cSucursalOrigen,'') , NVL(cNombre1Rem,'') , NVL(cNombre2Rem,'') , 
					   NVL(cApellido1Rem,'') , NVL(cApellido2Rem,'') , NVL(mImporteEnviado,'') , NVL(cFechaPago,'') , NVL(cHoraPago,'') , NVL(cSucCobropago,'') , NVL(cNombre1ben,'') ,
				       NVL(cNombre2ben,'') , NVL(cApellido1ben,'') , NVL(cApellido2ben,'') , NVL(cEstatus,'') WITH RESUME;
			END FOREACH;
		ElIF pConvenio = '07003' THEN
			FOREACH 
			
				SELECT fecha_envio,hora_envio, no_control,suc_origen,pri_nom_rem,seg_nom_rem,apell_pat_rem,apell_mat_rem,importe_envio,
						env.fecha_pago,hora_pago,suc_cobropago,pri_nom_ben,seg_nom_ben,apell_pat_ben,apell_mat_ben, es.descripcion
				INTO cFechaEnvio, cHoraEnvio, cNocontrol, cSucursalOrigen, cNombre1Rem, cNombre2Rem, cApellido1Rem, cApellido2Rem, mImporteEnviado, cFechaPago, cHoraPago,  
					 cSucCobropago, cNombre1ben, cNombre2ben, cApellido1ben, cApellido2ben, cEstatus
				FROM bdisac:sac_enviosdineroya AS env,
				OUTER bdisac:sac_estatus as es,
				OUTER bdisac:sac_movimientos as mov,
				OUTER bdisac:sac_movimientoshistorial as movh
				WHERE  env.estatus IN ('02')
				    AND env.estatus = es.estatus
				    AND env.no_control = mov.referencia1  
				    AND mov.numcategoria||mov.numconvenio = pConvenio
				    AND env.no_control = movh.referencia1
				    AND movh.numcategoria||movh.numconvenio = pConvenio
					AND fecha_envio >= pFechaInicial
					AND fecha_envio <= pFechaFinal

				UNION ALL


				SELECT fecha_envio,hora_envio, no_control,suc_origen,pri_nom_rem,seg_nom_rem,apell_pat_rem,apell_mat_rem,importe_envio,
						env.fecha_pago,hora_pago,suc_cobropago,pri_nom_ben,seg_nom_ben,apell_pat_ben,apell_mat_ben, es.descripcion
				FROM bdisac:sac_enviosdineroyahis AS env,
				OUTER bdisac:sac_estatus as es,
				OUTER bdisac:sac_movimientos as mov,
				OUTER bdisac:sac_movimientoshistorial as movh
				WHERE  env.estatus IN ('02')
				    AND env.estatus = es.estatus
				    AND env.no_control = mov.referencia1  
				    AND mov.numcategoria||mov.numconvenio = pConvenio
				    AND env.no_control = movh.referencia1
				    AND movh.numcategoria||movh.numconvenio = pConvenio
				    AND fecha_envio >= pFechaInicial
					AND fecha_envio <= pFechaFinal
					ORDER BY fecha_envio,hora_envio,no_control
				
				LET iContador = Icontador + 1;
				
				RETURN NVL(cCodRet,'') , NVL(cFechaEnvio,'') , NVL(cHoraEnvio,'') , NVL(cNocontrol,'') , NVL(cSucursalOrigen,'') , NVL(cNombre1Rem,'') , NVL(cNombre2Rem,'') , 
					   NVL(cApellido1Rem,'') , NVL(cApellido2Rem,'') , NVL(mImporteEnviado,'') , NVL(cFechaPago,'') , NVL(cHoraPago,'') , NVL(cSucCobropago,'') , NVL(cNombre1ben,'') ,
				       NVL(cNombre2ben,'') , NVL(cApellido1ben,'') , NVL(cApellido2ben,'') , NVL(cEstatus,'') WITH RESUME;
			END FOREACH;
		END IF;
		
	END IF;
	IF iContador = 0 THEN
		--No Hay registros con ese criterio de busqueda
		LET cCodRet = '00002';
		RETURN NVL(cCodRet,'') , NVL(cFechaEnvio,'') , NVL(cHoraEnvio,'') , NVL(cNocontrol,'') , NVL(cSucursalOrigen,'') , NVL(cNombre1Rem,'') , NVL(cNombre2Rem,'') , 
			   NVL(cApellido1Rem,'') , NVL(cApellido2Rem,'') , NVL(mImporteEnviado,'') , NVL(cFechaPago,'') , NVL(cHoraPago,'') , NVL(cSucCobropago,'') , NVL(cNombre1ben,'') ,
		       NVL(cNombre2ben,'') , NVL(cApellido1ben,'') , NVL(cApellido2ben,'') , NVL(cEstatus,'');
	END IF;
END
END PROCEDURE
Document
'DESCRIPCION:  Obtener informacion a detalle de envios con filtro de convenio y/o rango de fechas, de DineroYa', 
'AUTOR: César Valdéz Figueroa',
'FECHA: 03 de Noviembre de 2009',
'BD: BDISAC',
'VERSION: 20091218.1029',
'DESCRIPCION:  Se agregó el orden fecha_envio,hora_envio,no_control, se omite los reversados', 
'Modifico: Antonio Bastidas',
'FECHA: 17 de mayo de 2010',
'VERSION: 20100517.1029';

CREATE PROCEDURE "informix".sp_dinya_obtieneparam (pEmpresa CHAR(3),pNumEmpleado CHAR(9))
	RETURNING CHAR(5),CHAR(2),CHAR(2),CHAR(100),CHAR(45),CHAR(30),DATE,CHAR(2),CHAR(5),CHAR(5);

--Declaracion de variables		  
DEFINE cSqlerr              INTEGER;
DEFINE cCodRet              CHAR(5);
DEFINE cLongitudCliente     CHAR(2);
DEFINE cCodMonNac           CHAR(2);
DEFINE cPathRep             CHAR(100);
DEFINE cNombreUsuario       CHAR(45);
DEFINE cNombreEmpresa       CHAR(30);
DEFINE dFecha_Hoy           DATE;
DEFINE cSistema             CHAR(2);
DEFINE cLongitudNoControl	CHAR(5);
DEFINE cLongitudCuenta 		CHAR(5);
DEFINE isam_err			INTEGER;
DEFINE cMensaje			CHAR(200);


--SET DEBUG FILE TO "/tmp/sp_dinya_obtieneParam.out";
--TRACE ON;

--inicializacion de  variables
LET cCodRet= '00000';
LET cLongitudCliente= '';
LET cCodMonNac= '';
LET cPathRep= '';                                             
LET cNombreUsuario= '';
LET cNombreEmpresa = '';
LET dFecha_Hoy = '';
LET cSistema = '';
LET cLongitudNoControl = '';
LET cLongitudCuenta = '';
LET isam_err	= '';
LET cMensaje	= '';


BEGIN
--Crea el control de errores
	ON EXCEPTION SET cSqlerr, isam_err, cMensaje
		IF cSqlerr != 0 THEN
			LET cCodRet= cSqlerr;
			INSERT INTO sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)
			VALUES (cSqlerr,isam_err,cMensaje,'sp_dinya_obtieneParam',dFecha_Hoy,CURRENT );
			RETURN cCodRet,cLongitudCliente,cCodMonNac,cPathRep,cNombreUsuario,cNombreEmpresa,dFecha_Hoy,cSistema,cLongitudNoControl,cLongitudCuenta;
		END IF;
	END EXCEPTION;

	-- Obtengo Fecha del sistemal para la Captura de Parametros
	SELECT fecha_hoy 
	INTO dFecha_Hoy
	FROM bdisac:sac_fechas
    WHERE empresa = pEmpresa;
	
	--Obtengo el valor longitud del numero de cliente		
    SELECT Trim(valor)
	INTO cLongitudCliente 
	FROM bdinteg:si_param 
	WHERE empresa = pEmpresa AND cod_param = ('7'); 

	--Obtengo el valor codigo de la moneda nacional
	SELECT Trim(valor)
	INTO cCodMonNac 
	FROM bdinteg:si_param 
	WHERE empresa = pEmpresa AND cod_param = ('15'); 

	 --Obtengo el valor path de reportes
	SELECT Trim(valor)
	INTO cPathRep
	FROM bdisac:sac_param 
	WHERE empresa = pEmpresa AND cod_param = ('74');

	--Obtengo el nombre del usuario o ejecutivo
	SELECT nombre 
	INTO cNombreUsuario
	FROM bdinteg:si_ejecut
	WHERE ejecutivo = pNumEmpleado;
	 
	-- Obtengo el nombre de la empresa
	SELECT razon_social
	INTO cNombreEmpresa
	FROM bdinteg:si_empresas 
	WHERE empresa = pEmpresa;
	 
	--Obtengo codigo del sistema
	SELECT sistema
	INTO cSistema
	FROM bdinteg:si_sistema 
	WHERE siglas = 'SI';	
	
    -- se obtiene la longitud de la cuenta cLongitudCuenta
    SELECT valor
	INTO cLongitudCuenta
    FROM bdicheq:sc_param 
    WHERE empresa = pEmpresa AND codparam = 'longcta';

    --se obtiene el la longitud del numero de control
	SELECT valor 
	INTO cLongitudNoControl
    FROM bdisac:sac_param 
    WHERE empresa = pEmpresa AND cod_param = '77';
	
	RETURN cCodRet,cLongitudCliente,cCodMonNac,cPathRep,cNombreUsuario,cNombreEmpresa,dFecha_Hoy,cSistema,cLongitudNoControl,cLongitudCuenta;
	
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Genera una consulta en las tablas si_param, si_ejecut,si_empresas,sc_fechas,si_sistema', 
'tomando como parametro o dato de entrada, la empresa y el numero de empleado para obtener datos del empleado',
'Solicito : Armando Mercado',	
'AUTOR: César Valdéz Figueroa',
'FECHA: Octubre 2009',
'VERSION: 20091023.0700',
'BD: BDISAC';

CREATE PROCEDURE "informix".sp_dinya_obtienetotales(pConvenio CHAR(5), pFechaInicial DATE, pFechaFinal DATE)

RETURNING CHAR(5) AS cRegreso1,
 		  CHAR(10) AS cRegreso2,
		  CHAR(20) AS cRegreso3,
		  INTEGER AS cRegreso4,
		  MONEY (16,2) AS cRegreso5;

DEFINE cCodRet 			CHAR(5);
DEFINE cFechaEnvio 		DATE;
DEFINE mTotalImporteEnviado MONEY (16,2);
DEFINE iTotalEnvios 	INTEGER;
DEFINE cEstatus 		CHAR(20);
DEFINE iSqlErr			INTEGER;
DEFINE iContador		INTEGER;
DEFINE isam_err			INTEGER;
DEFINE cMensaje			CHAR(200);
DEFINE cFechaHoy       DATE;

LET cCodRet = '00000';
LET cFechaEnvio = CURRENT;
LET mTotalImporteEnviado = 0.00;
LET iTotalEnvios = 0;
LET cEstatus = '';
LET iSqlErr	= 0;
LET iContador	= 0;
LET isam_err	= '';
LET cMensaje	= '';
LET cFechaHoy = CURRENT;



BEGIN
	 ON EXCEPTION SET iSqlErr, isam_err, cMensaje
        IF iSqlErr <> 0 THEN
            Let cCodret = iSqlErr;  
			INSERT INTO sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)
			VALUES (iSqlErr,isam_err,cMensaje,'sp_dinya_ObtieneTotales',cFechaHoy,CURRENT );  
			RETURN NVL(cCodRet,'') , NVL(cFechaEnvio,'') , NVL(cEstatus,''),NVL(iTotalEnvios,'') , NVL(mTotalImporteEnviado,'');
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/sp_dinya_ObtieneTotales.out";
	--TRACE ON;
	--se obtiene la fecha de la sac_fechas
	SELECT fecha_hoy INTO cFechaHoy FROM sac_fechas WHERE empresa = '001';
	
	IF (( pFechaInicial = '' OR (pFechaInicial IS NULL)) OR ( pFechaFinal = '' OR (pFechaFinal IS NULL))) THEN
		--No estan todos los parametros
		LET cCodRet = '00001';
		RETURN NVL(cCodRet,'') , NVL(cFechaEnvio,'') , NVL(cEstatus,''),NVL(iTotalEnvios,'') , NVL(mTotalImporteEnviado,'');
	END IF;
	IF  pConvenio = '' OR (pConvenio IS NULL) THEN
		FOREACH 
			SELECT DISTINCT(fecha_envio),es.descripcion,COUNT(importe_envio),SUM(importe_envio)
			INTO cFechaEnvio, cEstatus, iTotalEnvios, mTotalImporteEnviado
			FROM bdisac:sac_enviosdineroya AS env
			INNER JOIN bdisac:sac_estatus AS es ON (env.estatus = es.estatus)
			WHERE fecha_envio >= pFechaInicial
			AND fecha_envio <= pFechaFinal
			GROUP BY fecha_envio,es.descripcion
			
			UNION ALL
			
			SELECT DISTINCT(fecha_envio),es.descripcion,COUNT(importe_envio),SUM(importe_envio)
			FROM bdisac:sac_enviosdineroyahis AS env
			INNER JOIN bdisac:sac_estatus AS es ON (env.estatus = es.estatus)
			WHERE fecha_envio >= pFechaInicial
			AND fecha_envio <= pFechaFinal
			GROUP BY fecha_envio,es.descripcion

			LET iContador = Icontador + 1;
			
			RETURN NVL(cCodRet,'') , NVL(cFechaEnvio,'') , NVL(cEstatus,''),NVL(iTotalEnvios,'') , NVL(mTotalImporteEnviado,'') WITH RESUME;
			
		END FOREACH;   
	ELSE
		FOREACH 
			
			SELECT DISTINCT(fecha_envio),es.descripcion,COUNT(importe_envio),SUM(importe_envio)
			INTO cFechaEnvio, cEstatus, iTotalEnvios, mTotalImporteEnviado
			FROM bdisac:sac_enviosdineroya AS env
			INNER JOIN bdisac:sac_estatus AS es ON (env.estatus = es.estatus)
			WHERE fecha_envio >= pFechaInicial
			AND fecha_envio <= pFechaFinal
			GROUP BY fecha_envio,es.descripcion

			UNION ALL

			SELECT DISTINCT(fecha_envio),es.descripcion,COUNT(importe_envio),SUM(importe_envio)
			FROM bdisac:sac_enviosdineroyahis AS env
			INNER JOIN bdisac:sac_estatus AS es ON (env.estatus = es.estatus)
			WHERE fecha_envio >= pFechaInicial
			AND fecha_envio <= pFechaFinal
			GROUP BY fecha_envio,es.descripcion
			
			LET iContador = Icontador + 1;
			
			RETURN NVL(cCodRet,'') , NVL(cFechaEnvio,'') , NVL(cEstatus,''),NVL(iTotalEnvios,'') , NVL(mTotalImporteEnviado,'') WITH RESUME;
			
		END FOREACH;  
	END IF;

	IF iContador = 0 THEN
		--No Hay registros con ese criterio de busqueda
		LET cCodRet = '00002';
		RETURN NVL(cCodRet,'') , NVL(cFechaEnvio,'') , NVL(cEstatus,''),NVL(iTotalEnvios,'') , NVL(mTotalImporteEnviado,'');
	END IF;
END
END PROCEDURE
Document
'DESCRIPCION:  Obtener informacion a detalle de envios con filtro de estatus y/o rango de fechas del proyecto con folio 1114', 
'AUTOR: César Valdéz Figueroa',
'FECHA: 05 de Noviembre de 2009',
'VERSION: 20091112.0730',
'BD: BDISAC';

CREATE PROCEDURE "informix".sp_obtieneconvenios()
	RETURNING CHAR(5),CHAR(40);

---- VARIABLES  GENERALES---
DEFINE cSqlerr			INTEGER;
DEFINE cCodret      	CHAR(5);
DEFINE vsSQL    		CHAR(100);
DEFINE cConvenio        CHAR(40);
DEFINE id_convenio 		CHAR(5);
DEFINE isam_err			INTEGER;
DEFINE cMensaje			CHAR(200);
DEFINE cFecha_Hoy       DATE;

--VALORES INICIALES
LET cSqlerr = '';
LET cCodret = '00000';
LET vsSQL    = '';
LET cConvenio 	=	'';
LET id_convenio = '';
LET isam_err	= '';
LET cMensaje	= '';
LET cFecha_Hoy = CURRENT;

--SET debug FILE TO "/tmp/sp_obtieneconvenios.out";
--Trace ON;

Begin
	------  Control de Errores no Controlados
	 ON EXCEPTION SET cSqlerr, isam_err, cMensaje
        IF cSqlerr <> 0 THEN
            Let cCodret = cSqlerr;  
			INSERT INTO sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)
			VALUES (cSqlerr,isam_err,cMensaje,'sp_obtieneconvenios',cFecha_Hoy,CURRENT );
            RETURN NVL(cCodret,''),NVL(cConvenio,'');
        END IF;
	END EXCEPTION;
	--SE OBTIENE LA FECHA HOY   --SE OBTIENE LA FECHA HOY - n DIAS
	SELECT fecha_hoy INTO cFecha_Hoy FROM bdisac:sac_fechas WHERE empresa = '001';
	
		--SE OBTIENEN LOS CONVENIOS DE LA  bdisac:sac_comisiones unique(
		FOREACH WITH HOLD 
			SELECT  DISTINCT(id_convenio) , con.nomconvenio INTO id_convenio, cconvenio
			FROM bdisac:sac_comisiones AS com,  bdisac:sac_convenios AS con
			WHERE numcategoria = SUBSTR(com.id_convenio,1,2)
			AND numconvenio = SUBSTR(com.id_convenio,3,3)

			RETURN cCodret,cconvenio WITH RESUME;
		END FOREACH;
		
END
END PROCEDURE
DOCUMENT
'AUTOR :César Valdéz Figueroa',
'DESCRIPCION:  Este Procedimiento Obtiene los convenios con comisiones parametrizadas, al Sistema de Mantenimiento ',
'			   de Catalogos de Comisiones.',
'FECHA : Octubre de 2009',
'BD    : BDISAC',
'VERSION: 20091022.0500';

CREATE PROCEDURE "informix".sp_dinya_activaenviosnocobrados(pNoControl CHAR(12))
	RETURNING CHAR(5);

---- VARIABLES  GENERALES---
DEFINE cSqlerr			INTEGER;
DEFINE cCodret      	CHAR(5);
DEFINE isam_err			INTEGER;
DEFINE cMensaje			CHAR(200);
DEFINE cFecha_Hoy       DATE;

--VALORES INICIALES
LET cSqlerr = '';
LET cCodret = '00000';
LET isam_err	= '';
LET cMensaje	= '';
LET cFecha_Hoy = CURRENT;

--SET debug FILE TO "/tmp/sp_dinya_ActivaEnviosNoCobrados.out";
--Trace ON;

Begin
	------  Control de Errores no Controlados
   ON EXCEPTION SET cSqlerr, isam_err, cMensaje
        IF cSqlerr <> 0 THEN
            Let cCodret = cSqlerr;  
			INSERT INTO sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)
			VALUES (cSqlerr,isam_err,cMensaje,'sp_dinya_ActivaEnviosNoCobrados',cFecha_Hoy,CURRENT );  
            RETURN NVL(cCodret,'');
        END IF;
	END EXCEPTION;
	
	IF EXISTS( SELECT {+INDEX (bdisac:sac_enviosdineroya idxsac_envdinya13_1)} estatus FROM bdisac:sac_EnviosDineroYa WHERE estatus = '03' AND no_control = TRIM(pNoControl)) THEN
		--Se reactiva el envio no cobrado con el numero de control pasado por parametro
		UPDATE {+INDEX (bdisac:sac_enviosdineroya idxsac_envdinya13_1)} bdisac:sac_EnviosDineroYa SET estatus = '01' WHERE no_control = TRIM(pNoControl);
		RETURN NVL(cCodret,'');
	ELSE
		--ESE NUMERO DE CONTROL NO EXISTE
		LET cCodret = '00001';
		RETURN NVL(cCodret,'');
	END IF;
END
END PROCEDURE
DOCUMENT
'AUTOR :César Valdéz Figueroa',
'DESCRIPCION:  Este procedimiento Reactiva los envios bloqueados,Cambiando el estatus de los envios bloqueados a activos',
'FECHA : Octubre de 2009',
'BD    : BDISAC',
'VERSION: 20091204.1120';

CREATE PROCEDURE "informix".sp_dinya_actualizacomisiones(
				pNumeroConvenio CHAR(5),
				pMontoMinComision MONEY(16,2),
				pMontoMin MONEY(16,2),
				pMontoMax MONEY(16,2),
				pComision MONEY(16,2),
				pTipoComision INTEGER,
				pUsuario CHAR(8),
				pFecha DATE,
				pControl INTEGER
)
	RETURNING CHAR(5);

---- VARIABLES  GENERALES---
DEFINE cSqlerr			INTEGER;
DEFINE cCodret      	CHAR(5);
DEFINE vsSQL    		CHAR(100);
DEFINE isam_err			INTEGER;
DEFINE cMensaje			CHAR(200);
DEFINE cFecha_Hoy       DATE;

--VALORES INICIALES
LET cSqlerr = '';
LET cCodret = '00000';
LET vsSQL    = '';
LET isam_err	= '';
LET cMensaje	= '';
LET cFecha_Hoy = CURRENT;


--SET debug FILE TO "/tmp/sp_dinya_ActualizaComisiones.out";
--Trace ON;

Begin
	------  Control de Errores no Controlados
    ON EXCEPTION SET cSqlerr, isam_err, cMensaje
        IF cSqlerr <> 0 THEN
            Let cCodret = cSqlerr;  
			INSERT INTO sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)
			VALUES (cSqlerr,isam_err,cMensaje,'sp_dinya_ActualizaComisiones',cFecha_Hoy,CURRENT );  
			RETURN NVL(cCodret,'');
        END IF;
	END EXCEPTION;
	
	--SE BORRA LA TABLA CUANDO  EL pControl SEA EL	PRIMERO
	IF pControl = 0 THEN
		DELETE {+INDEX (bdisac:sac_comisiones idxid_cov)} FROM sac_comisiones WHERE id_convenio = pNumeroConvenio;
	END IF;
	--INSERTA EN LA TABLA
	INSERT INTO sac_comisiones (id_convenio, valorminimocomision, montominimo, montomaximo, comision, tipo, userinsert, fechainsert) 
	VALUES (pNumeroConvenio, pMontoMinComision, pMontoMin, pMontoMax, pComision, pTipoComision,pUsuario, pFecha);
	
	RETURN NVL(cCodret,'');
END
END PROCEDURE
DOCUMENT
'AUTOR :César Valdéz Figueroa',
'DESCRIPCION:  Actualizar el catalogo de parametros de comisiones, para cualquier convenio',
'			   de Catalogos de Comisiones.',
'FECHA : Octubre de 2009',
'BD    : BDISAC',
'VERSION: 20091026.1130';

CREATE PROCEDURE "informix".sp_dinya_bloqueaenviosnocobrados()
	RETURNING CHAR(5);

---- VARIABLES  GENERALES---
DEFINE cSqlerr			INTEGER;
DEFINE cCodret      	CHAR(5);
DEFINE vsSQL    		CHAR(100);
DEFINE dFecha_Hoy       DATE;
DEFINE pDias            CHAR(50);
DEFINE dFecha_Hoy90     DATE;
DEFINE cNo_control 	    CHAR(10);
DEFINE cNumReg1			CHAR(10);
DEFINE cNumReg2			CHAR(10);
DEFINE cNumReg3			CHAR(10);
DEFINE isam_err			INTEGER;
DEFINE cMensaje			CHAR(200);

--VALORES INICIALES
LET cSqlerr = '';
LET cCodret = '00000';
LET vsSQL    = '';
LET dFecha_Hoy = CURRENT;
LET dFecha_Hoy90 = CURRENT;
LET cNo_control = '';
LET pDias       = '';
LET cNumReg1	= '';
LET cNumReg2	= '';
LET cNumReg3	= '';
LET isam_err	= '';
LET cMensaje	= '';


--SET debug FILE TO "/tmp/sp_dinya_bloqueaenviosnocobrados.out";
--Trace ON;

Begin
	------  Control de Errores no Controlados
    ON EXCEPTION SET cSqlerr, isam_err, cMensaje
        IF cSqlerr <> 0 THEN
            Let cCodret = cSqlerr;  
			DELETE  {+INDEX (bdisac:sac_enviosdineroyahis idxenv_his)} sac_enviosdineroyahis WHERE fecha_insert= dFecha_Hoy;
			INSERT INTO sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)
		VALUES (cSqlerr,isam_err,cMensaje,'sp_dinya_BloqueaEnviosNoCobrados',dFecha_Hoy,CURRENT );
            RETURN NVL(cCodret,'');
        END IF;
	END EXCEPTION;
	
	--SE OBTIENE LOS DIAS PARAMETRIZADOS
	SELECT valor INTO pDias FROM bdisac:sac_param WHERE empresa = '001' AND cod_param = '73';
	
	--SE OBTIENE LA FECHA HOY   --SE OBTIENE LA FECHA HOY - n DIAS
	SELECT fecha_hoy, ( fecha_hoy - TRIM(pDias)::INTEGER) INTO dFecha_Hoy, dFecha_Hoy90 FROM bdisac:sac_fechas WHERE empresa = '001';
	
	--ACTUALIZAR EL ESTATUS A 03
	UPDATE {+INDEX (bdisac:sac_enviosdineroya idxsac_envdinya13_1)} sac_enviosdineroya SET estatus = '03' WHERE fecha_envio < dFecha_Hoy90 AND estatus = '01';


	--SE PASA INFORMACION AL HISTORICO DE DINERO YA (ENVIOS PAGADOSM CANCELADOS Y REVERSADOS)

	SELECT {+INDEX (bdisac:sac_enviosdineroya 294_285)}  COUNT(*) 
	INTO cNumReg1
	FROM sac_enviosdineroya
	WHERE estatus IN ('02','04','05');

	INSERT INTO sac_enviosdineroyahis(no_control, fecha_envio, estatus, hora_envio, usua_envio, suc_origen, 
				importe_total, importe_pago, importe_envio, comision, iva, fecha_pago, hora_pago, usua_pago, 
				identificacion, num_ident, pri_nom_rem, seg_nom_rem, apell_pat_rem, apell_mat_rem, telefono_rem, 
				direc_rem, pri_nom_ben, seg_nom_ben, apell_pat_ben, apell_mat_ben, telefono_ben, direc_ben, mensaje,
				suc_cobropago, suc_cance, fecha_cance, hora_cance, usua_cance, fecha_insert)
	SELECT 	 {+INDEX (bdisac:sac_enviosdineroya 294_285)} no_control, fecha_envio, estatus, hora_envio, usua_envio, suc_origen, importe_total,
			importe_pago, importe_envio, comision, iva, fecha_pago, hora_pago, usua_pago, identificacion, 
			num_ident, pri_nom_rem, seg_nom_rem, apell_pat_rem, apell_mat_rem, telefono_rem, direc_rem, 
			pri_nom_ben, seg_nom_ben, apell_pat_ben, apell_mat_ben, telefono_ben, direc_ben, mensaje, 
			suc_cobropago, suc_cance, fecha_cance, hora_cance, usua_cance, dFecha_Hoy 
	FROM sac_enviosdineroya
	WHERE estatus IN ('02','04','05');
	
	SELECT {+INDEX (bdisac:sac_enviosdineroyahis idxenv_his)} COUNT(*) 
	INTO cNumReg2
	FROM sac_enviosdineroyahis
	WHERE fecha_insert = dFecha_Hoy;

	IF cNumReg1 <> cNumReg2  THEN
		LET cCodret= '00001';
		DELETE {+INDEX (bdisac:sac_enviosdineroyahis idxenv_his)} sac_enviosdineroyahis WHERE fecha_insert= dFecha_Hoy;
		INSERT INTO sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)
		VALUES ('00001','0','NO SE REPLICARON LOS ENVIOS DINERO YA','sp_dinya_BloqueaEnviosNoCobrados',dFecha_Hoy,CURRENT);
	ELSE
		DELETE {+INDEX (bdisac:sac_enviosdineroya 294_285)} sac_enviosdineroya WHERE estatus IN ('02','04','05');
	END IF;
		
	RETURN NVL(cCodret,'');
END
END PROCEDURE
DOCUMENT
'AUTOR :CÉSAR VALDÉZ FIGUEROA',
'DESCRIPCION:  ESTE PROCEDIMIENTO BLOQUEA LOS ENVIOS NO COBRADOS CON MAS DE 90 DIAS, OBTENIENDO LOS DIAS DE LA TABLA PARAMETROS',
'FECHA : OCTUBRE DE 2009',
'BD    : BDISAC',
'MODIFICO: ABIGAIL VASAVILBAZO CAÑEDO',
'CAMBIO: SE PASARAN LOS ENVIOS PAGADOS, CANCELADOS Y REVERSADOS AL HISTORICO SAC_ENVIOSDINEROYAHIS',
'VERSION: 20091112.1424';

CREATE PROCEDURE "informix".sp_dinya_consultaenviosbloqueados(pNoControl CHAR(12))
	RETURNING CHAR(5),DATE,CHAR(26),CHAR(26),CHAR(26),CHAR(26),MONEY (16,2),CHAR(2),CHAR(4);

---- VARIABLES  GENERALES---
DEFINE cSqlerr			INTEGER;
DEFINE cCodret      	CHAR(5);
DEFINE dFechaEnvio 		DATE;
DEFINE cNombre1Rem 		CHAR(26);
DEFINE cSuc_origen 		CHAR(4);
DEFINE cNombre2Rem 		CHAR(26);
DEFINE cApellido1Rem 	CHAR(26);
DEFINE cApellido2Rem 	CHAR(26);
DEFINE mImporteEnviado 	MONEY (16,2);
DEFINE cStatus 			CHAR(2);
DEFINE isam_err			INTEGER;
DEFINE cMensaje			CHAR(200);
DEFINE cFecha_Hoy       DATE;

--VALORES INICIALES
LET cSqlerr = '';
LET cCodret = '00000';
LET dFechaEnvio 	=	CURRENT;
LET cNombre1Rem    = '';
LET cNombre2Rem   = '';
LET cApellido1Rem    = '';
LET cSuc_origen 	= '';
LET cApellido2Rem    = '';
LET mImporteEnviado    = 0.00;
LET cStatus    = '';
LET isam_err	= '';
LET cMensaje	= '';
LET cFecha_Hoy = CURRENT;

--SET debug FILE TO "/tmp/sp_dinya_ConsultaEnviosBloqueados.out";
---Trace ON;

Begin
	------  Control de Errores no Controlados
	 ON EXCEPTION SET cSqlerr, isam_err, cMensaje
        IF cSqlerr <> 0 THEN
            Let cCodret = cSqlerr;  
			INSERT INTO sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)
			VALUES (cSqlerr,isam_err,cMensaje,'sp_dinya_ConsultaEnviosBloqueados',cFecha_Hoy,CURRENT );  
			RETURN NVL(cCodret,''),NVL(dFechaEnvio,''),NVL(cNombre1Rem,''),NVL(cNombre2Rem,''),NVL(cApellido1Rem,''),
			    NVL(cApellido2Rem,''),NVL(mImporteEnviado,''),NVL(cStatus,''),NVL(cSuc_origen,'');
        END IF;
	END EXCEPTION;
	--SE OBTIENE LA FECHA HOY   --SE OBTIENE LA FECHA HOY - n DIAS
	SELECT fecha_hoy INTO cFecha_Hoy FROM sac_fechas WHERE empresa = '001';
	
	IF EXISTS( SELECT {+INDEX (bdisac:sac_enviosdineroya idxsac_envdinya13_1)} estatus FROM sac_enviosdineroya WHERE estatus = '03' AND no_control = TRIM(pNoControl)) THEN
		--se seleccionan los datos del no de control pasado por parametro
		SELECT  {+INDEX (bdisac:sac_enviosdineroya idxsac_envdinya13_1)} fecha_envio,pri_nom_rem,seg_nom_rem,apell_pat_rem,apell_mat_rem,importe_envio,estatus,suc_origen 
		INTO dFechaEnvio, cNombre1Rem ,cNombre2Rem,cApellido1Rem,cApellido2Rem,mImporteEnviado,cStatus,cSuc_origen
		FROM bdisac:sac_enviosdineroya 
		WHERE estatus = '03' 
		AND no_control = TRIM(pNoControl);
		
		--Se RETORNA LOS DATOS DEL ENVIO QUE SE REQUIERE PARA REACTIVAR
		RETURN NVL(cCodret,''),NVL(dFechaEnvio,''),NVL(cNombre1Rem,''),NVL(cNombre2Rem,''),NVL(cApellido1Rem,''),
			   NVL(cApellido2Rem,''),NVL(mImporteEnviado,''),NVL(cStatus,''),NVL(cSuc_origen,'');
	ELSE
		--ESE NUMERO DE CONTROL NO EXISTE
		LET cCodret = '00001';
		RETURN NVL(cCodret,''),NVL(dFechaEnvio,''),NVL(cNombre1Rem,''),NVL(cNombre2Rem,''),NVL(cApellido1Rem,''),
			   NVL(cApellido2Rem,''),NVL(mImporteEnviado,''),NVL(cStatus,''),NVL(cSuc_origen,'');
	END IF;
END
END PROCEDURE
DOCUMENT
'AUTOR :César Valdéz Figueroa',
'DESCRIPCION:  Este procedimiento Consulta los envios bloqueados por numero de control,Enviar al sistema de reactivacion de  ',
'			   envios de Dinero Ya los envios bloqueados encontrados',
'FECHA : Octubre de 2009',
'BD    : BDISAC',
'VERSION: 20091204.1130';

CREATE PROCEDURE "informix".sp_dinya_generanumerocontrol 
	(pSucursalOrigen CHAR(4))
RETURNING  CHAR(5),CHAR(12);

DEFINE cCodRet 			CHAR(5);
DEFINE cFolioGenerado 	CHAR(12);
DEFINE cMensaje		 	CHAR(50);
DEFINE iConsecutivoSig	INTEGER;
DEFINE iDigitoVerficador INTEGER;
DEFINE iSqlErr			INTEGER;
DEFINE isam_error		INTEGER;
DEFINE iExiste			INTEGER;
DEFINE iCiclo			INTEGER;
DEFINE iLongitudFolio	INTEGER;
DEFINE iMaximoIntPerm	INTEGER;
DEFINE dFecha_envio		DATE;

LET cCodRet 			= '00000';
LET cFolioGenerado		= '';
LET iSqlErr				= 0;
LET isam_error			= 0;
LET iExiste				= 0;
LET iConsecutivoSig		= 0;
LET iDigitoVerficador	= 0;
LET iCiclo				= 0;
LET iLongitudFolio		= 0;
LET iMaximoIntPerm		= 0;
LET dFecha_envio		= '';
LET cMensaje			= '';

BEGIN
	ON EXCEPTION SET iSqlErr,isam_error,cMensaje
		IF iSqlErr != 0 THEN
			LET cCodRet= iSqlErr;
			INSERT INTO sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)
			VALUES (iSqlErr,isam_error,cMensaje,'sp_DinYa_GeneraNumeroControl',dFecha_envio,CURRENT );
			RETURN cCodRet,cFolioGenerado;
		END IF;
	END EXCEPTION;
	
    --SET DEBUG FILE TO "/tmp/Antonio/sp_DinYa_GeneraNumeroControl.out";
	--TRACE ON;	
  
  SET ISOLATION TO CURSOR STABILITY;
  SET LOCK MODE TO WAIT 3;
  
  SELECT fecha_hoy INTO dFecha_envio
  FROM BDISAC:sac_fechas;
  
  IF pSucursalOrigen = '' OR pSucursalOrigen IS NULL THEN 
	LET cCodRet = '00001';
	RETURN cCodRet,cFolioGenerado;
  END IF;
  
  SELECT 1 INTO iExiste FROM bdinteg:si_sucursales 
  WHERE empresa = '001' 
  AND sucursal = pSucursalOrigen;
  
	  IF iExiste = 0 OR iExiste IS NULL  THEN
		LET cCodRet = '00002';
		RETURN cCodRet,cFolioGenerado;
	  ELSE
		LET iExiste = 0;
	  END IF;
  
   SELECT TRIM(valor)  INTO iConsecutivoSig
   FROM bdisac:sac_param
   WHERE cod_param = 71;
   
	   IF iConsecutivoSig IS NULL OR iConsecutivoSig = '' THEN
		LET iConsecutivoSig = 0;
	   ELSE
		LET iConsecutivoSig = iConsecutivoSig + 1 ;
	   END IF;
	   
	   LET iLongitudFolio = LENGTH(TRIM(iConsecutivoSig::CHAR(8)));
	   
	   IF iLongitudFolio > 7 THEN
		LET iConsecutivoSig = 0;
	   END IF;
	   
	   UPDATE bdisac:sac_param 
	   SET valor = iConsecutivoSig  
	   WHERE cod_param = 71;
	   
	SELECT valor INTO iMaximoIntPerm FROM bdisac:sac_param WHERE cod_param = 72;
	
		IF iMaximoIntPerm IS NULL THEN
			LET iMaximoIntPerm = 500;
		END IF;
   
   LET cFolioGenerado = LPAD (TRIM(pSucursalOrigen),4,'0') || TRIM(LPAD (iConsecutivoSig,7,'0'));
   
   CALL bdisac:sp_DinYa_GeneradigitoVerificador (cFolioGenerado) RETURNING cCodRet,iDigitoVerficador;
   
   LET cFolioGenerado = TRIM(cFolioGenerado)||iDigitoVerficador;
   
   IF EXISTS (SELECT {+INDEX (bdisac:sac_enviosdineroya idxsac_envdinya13_1)} 1 FROM bdisac:sac_enviosdineroya WHERE no_control = cFolioGenerado and estatus is not null) OR 
	  		 (SELECT {+INDEX (bdisac:sac_enviosdineroyahis idxsac_envdinyahis13_1)} 1 FROM bdisac:sac_enviosdineroyahis WHERE no_control = cFolioGenerado and estatus is not null) THEN
   
		WHILE EXISTS (SELECT {+INDEX (bdisac:sac_enviosdineroya idxsac_envdinya13_1)} 1 FROM bdisac:sac_enviosdineroya WHERE no_control = cFolioGenerado and estatus is not null) OR
			  EXISTS (SELECT {+INDEX (bdisac:sac_enviosdineroyahis idxsac_envdinyahis13_1)} 1 FROM bdisac:sac_enviosdineroyahis WHERE no_control = cFolioGenerado and estatus is not null) 
		      
     		   SELECT TRIM(valor) INTO iConsecutivoSig
	    	   FROM bdisac:sac_param
		       WHERE cod_param = 71;
		
			   IF iConsecutivoSig IS NULL OR iConsecutivoSig = '' THEN
				LET iConsecutivoSig = 0;
			   ELSE
				LET iConsecutivoSig = iConsecutivoSig + 1 ;
			   END IF;
			   
			   LET iLongitudFolio = LENGTH(TRIM(iConsecutivoSig::CHAR(8)));
			   IF iLongitudFolio > 7 THEN
				LET iConsecutivoSig = 0;
			   END IF;
	   
			   UPDATE bdisac:sac_param 
			   SET valor = iConsecutivoSig  
			   WHERE cod_param = 71;
		   
		   LET cFolioGenerado = LPAD(TRIM(pSucursalOrigen),4,'0') || TRIM(LPAD (iConsecutivoSig,7,'0'));
		   
		   CALL bdisac:sp_DinYa_GeneradigitoVerificador (cFolioGenerado) RETURNING cCodRet,iDigitoVerficador;
		   
		   LET cFolioGenerado = TRIM(cFolioGenerado)||iDigitoVerficador;
		   
		   LET iCiclo = iCiclo + 1;
		   IF iCiclo >= iMaximoIntPerm THEN
			   LET cCodRet = '00003';
			   RETURN cCodRet,cFolioGenerado;
		   END IF;
		END WHILE;
   END IF;
   LET cCodRet = LPAD(TRIM(cCodRet),5,'0');
   RETURN cCodRet,cFolioGenerado;
END
END PROCEDURE
Document
'DESCRIPCION: Genera numero de control para Dinero Ya', 
'AUTOR: Antonio Bastidas',
'FECHA: 23 de octubre de 2009',
'BD: BDISAC',
'VERSION: 20091204.1145';

CREATE PROCEDURE "informix".sp_dinya_insertaenvios2 
	(mMontoEnvio MONEY(16,2),
	pMontoCargo MONEY(16,2),
	pEfectivo   MONEY(16,2),
	pCuentaCargo CHAR(20),
	pSucursal CHAR(4),
	cEjecutivo CHAR(8),
	pFolioSuc CHAR(16))

RETURNING  CHAR(5), CHAR(16);

DEFINE cCodRet 			 		CHAR(5);
DEFINE iSqlErr			 		INTEGER;
DEFINE cCuentaPrestadora 		CHAR(20);
DEFINE cCuentaReceptora	 		CHAR(20);
DEFINE cTransaccAbonoEnvio		CHAR(4);
DEFINE cTransaccAbonoIva		CHAR(4);
DEFINE cTransaccAbonoComision	CHAR(4);
DEFINE mTotComision				MONEY (16,2);
DEFINE mTotIVA					MONEY (16,2);
DEFINE mTotIvaComision			MONEY (16,2);
DEFINE pImporte					MONEY (16,2);
DEFINE mTotalaCobrar			MONEY (16,2);
DEFINE cTransaccSuc				CHAR(4);
DEFINE cTransaccCargoEnvio 		CHAR(4);
DEFINE ctranret					CHAR(4);
DEFINE dfechoy					DATE;
DEFINE msdodisp					MONEY (14,2);
DEFINE mmontoret				MONEY (14,2);
DEFINE dFecha_hoy				DATE;
DEFINE isam_error				INTEGER;
DEFINE cDescripcion				CHAR(200);
DEFINE cTransaccCargocomi		CHAR(4);
DEFINE cTransaccCargoiva		CHAR(4);
DEFINE cAbonoEfectivo 			MONEY(16,2);
DEFINE cAbonoCargo				MONEY(16,2);
DEFINE cTransaccAbonoEnvioC		CHAR(4);

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet= iSqlErr;
			INSERT INTO sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)
			VALUES (iSqlErr,isam_error,cDescripcion,'sp_dinya_insertaenvios2',dFecha_hoy,CURRENT );
			RETURN cCodRet, pFolioSuc;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/sp_dinya_InsertaEnvios2.out";
	--TRACE ON;

	LET cCodRet 			   = '00000';
	LET iSqlErr			 	   = 0;
	LET cCuentaPrestadora 	   = '';
	LET cCuentaReceptora       = '';
	LET cTransaccAbonoEnvio	   = '';
	LET cTransaccAbonoIva	   = '';
	LET cTransaccAbonoComision = '';
	LET mTotComision		   = '';
	LET mTotIVA				   = '';
	LET mTotIvaComision 	   = '';
	LET pImporte			   = '';
	LET mTotalaCobrar		   = '';	
	LET cTransaccSuc		   = '';
	LET cTransaccCargoEnvio	   = '';
	LET ctranret			   = '';
	LET dfechoy				   = '';
	LET msdodisp			   = '';
	LET mmontoret			   = '';
	LET dFecha_hoy			   = '';
	LET isam_error			   = '';
	LET cDescripcion		   = '';
	LET cTransaccCargocomi     ='';
	LET cTransaccCargoiva     = '';
	LET cAbonoEfectivo 			='';
	LET cAbonoCargo				='';
	LET cTransaccAbonoEnvioC    ='';

	--Obtiene parametros
	SELECT valor INTO cCuentaPrestadora
	FROM Bdisac:sac_param
	WHERE cod_param='75';

	SELECT valor INTO cTransaccAbonoEnvio
	FROM Bdisac:sac_param
	WHERE cod_param='5070011';

	SELECT valor INTO cTransaccAbonoEnvioC
	FROM Bdisac:sac_param
	WHERE cod_param='5070012';

	SELECT valor INTO cTransaccCargoEnvio
	FROM Bdisac:sac_param
	WHERE cod_param='414070021';

	SELECT valor INTO cTransaccAbonoComision
	FROM Bdisac:sac_param
	WHERE cod_param='511070011';

	SELECT valor INTO cTransaccAbonoIva
	FROM Bdisac:sac_param
	WHERE cod_param='510070011';

	SELECT valor INTO cTransaccSuc
	FROM Bdisac:sac_param
	WHERE cod_param='807001';	

	SELECT valor INTO cTransaccCargocomi
	FROM Bdisac:sac_param
	WHERE cod_param='413070012';

	SELECT valor INTO cTransaccCargoiva
	FROM Bdisac:sac_param
	WHERE cod_param='4070012';

	SELECT fecha_hoy 
	INTO dFecha_hoy
	FROM Bdisac:sac_fechas;	

	--Calcula la comision e Iva
	CALL  bdisac:sp_DinYa_CalcularComisionIva ('07001',mMontoEnvio,pSucursal)
	RETURNING cCodRet,mTotComision,mTotIVA,mTotIvaComision,pImporte,mTotalaCobrar;
	IF cCodRet <> 0 THEN
		LET cCodRet = '00010'; --Error en el calculo de comision e iva
		RETURN cCodRet,pFolioSuc;
	END IF;

	IF pEfectivo > mTotIvaComision THEN

		LET cAbonoEfectivo = (pEfectivo - mTotIvaComision);
		LET cAbonoCargo = (mMontoEnvio - cAbonoEfectivo);

		--Cargo a la cuenta del cte por el monto cargo.
		CALL bdicheq:cargo_ref ("001", pSucursal, cEjecutivo, cTransaccCargoEnvio, cTransaccSuc, pFolioSuc, 
		pCuentaCargo, 0, cAbonoCargo,"01", " ", '', cEjecutivo) 
		Returning cCodRet,ctranret,dfechoy,msdodisp,mmontoret;

		IF cCodRet <> 0 THEN
			LET cCodRet = '00029'; --Error en el cargo de el monto cargo
			RETURN cCodRet,pFolioSuc;
		END IF;	
			
		CALL bdicheq:abono_ref ("001", pSucursal, cEjecutivo, cTransaccAbonoEnvio, cTransaccSuc , pFolioSuc, 
		cCuentaPrestadora,0, cAbonoEfectivo, cAbonoEfectivo, 0, 0, 0, "01", " ", '', cEjecutivo) 
		Returning cCodRet;  

		IF cCodRet <> 0 THEN
			CALL bdicheq:reversion ('001', pSucursal, cEjecutivo,pFolioSuc, "M") Returning cCodRet;	
			LET cCodRet = '00027'; --Error en el abono de el importe
			RETURN cCodRet,pFolioSuc;
		END IF;		

		CALL bdicheq:abono_ref ("001", pSucursal, cEjecutivo, cTransaccAbonoEnvioC, cTransaccSuc , pFolioSuc, 
		cCuentaPrestadora,0, cAbonoCargo, cAbonoCargo, 0, 0, 0, "01", " ", '', cEjecutivo) 
		Returning cCodRet;  

		IF cCodRet <> 0 THEN
			CALL bdicheq:reversion ('001', pSucursal, cEjecutivo,pFolioSuc, "M") Returning cCodRet;	
			LET cCodRet = '00028'; --Error en el abono de el importe
			RETURN cCodRet,pFolioSuc;
		END IF;		

	ELSE 

		--Cargo a la cuenta del cte por el monto envio.
		CALL bdicheq:cargo_ref ("001", pSucursal, cEjecutivo, cTransaccCargoEnvio, cTransaccSuc, pFolioSuc, 
		pCuentaCargo, 0, mMontoEnvio,"01", " ", '', cEjecutivo) 
		Returning cCodRet,ctranret,dfechoy,msdodisp,mmontoret;

		IF cCodRet <> 0 THEN
			LET cCodRet = '00011'; --Error en el cargo de el monto cargo
			RETURN cCodRet,pFolioSuc;
		END IF;	

		--Abono a la cuenta prestadora de servicios por el monto del Envio
		CALL bdicheq:abono_ref ("001", pSucursal, cEjecutivo, cTransaccAbonoEnvioC, cTransaccSuc , pFolioSuc, 
		cCuentaPrestadora,0, mMontoEnvio, mMontoEnvio, 0, 0, 0, "01", " ", '', cEjecutivo) 
		Returning cCodRet;  

		IF cCodRet <> 0 THEN
			CALL bdicheq:reversion ('001', pSucursal, cEjecutivo,pFolioSuc, "M") Returning cCodRet;	
			LET cCodRet = '00012'; --Error en el abono de el importe
			RETURN cCodRet,pFolioSuc;
		END IF;			

	END IF;	

	--Abono a la cuenta prestadora (Comision)
	CALL bdicheq:abono_ref ("001", pSucursal, cEjecutivo, cTransaccAbonoComision ,cTransaccSuc , 
	pFolioSuc, cCuentaPrestadora,0, mTotComision, mTotComision, 0, 0, 0, "01", " ", '', cEjecutivo) 
	Returning cCodRet;

	IF cCodRet <> 0 THEN
	--LLamado a realizar la reversion del abono.
		CALL bdicheq:reversion ('001', pSucursal, cEjecutivo,pFolioSuc, "M") Returning cCodRet;	
		LET cCodRet = '00013'; --Error en el abono de la comision
		RETURN cCodRet,pFolioSuc;
	END IF;

	--Abono a la cuenta prestadora (Iva)
	CALL bdicheq:abono_ref ("001", pSucursal, cEjecutivo, cTransaccAbonoIva , cTransaccSuc , pFolioSuc, cCuentaPrestadora,
	0, mTotIVA, mTotIVA, 0, 0, 0, "01", " ", '', cEjecutivo) Returning cCodRet;
	
	IF cCodRet <> 0 THEN
	--LLamado a realizar la reversion del abono y cargo
		CALL bdicheq:reversion ('001', pSucursal, cEjecutivo,pFolioSuc, "M") Returning cCodRet;		
		LET cCodRet = '00014'; --Error en el abono del iva
		RETURN cCodRet,pFolioSuc;
	END IF;

	--Cargo a la cuenta prestadora por la comision.
	CALL bdicheq:cargo_ref ("001", pSucursal, cEjecutivo, cTransaccCargocomi, cTransaccSuc, pFolioSuc, 
	cCuentaPrestadora, 0, mTotComision,"01", " ", '', cEjecutivo) 
	Returning cCodRet,ctranret,dfechoy,msdodisp,mmontoret;

	IF cCodRet <> 0 THEN
		LET cCodRet = '00030'; --Error en el cargo de el monto cargo
		RETURN cCodRet,pFolioSuc;
	END IF;	

	--Cargo a la cuenta prestadora por el iva
	CALL bdicheq:cargo_ref ("001", pSucursal, cEjecutivo, cTransaccCargoiva, cTransaccSuc, pFolioSuc, 
	cCuentaPrestadora, 0, mTotIVA,"01", " ", '', cEjecutivo) 
	Returning cCodRet,ctranret,dfechoy,msdodisp,mmontoret;

	IF cCodRet <> 0 THEN
		LET cCodRet = '00031'; --Error en el cargo de el monto cargo
		RETURN cCodRet,pFolioSuc;
	END IF;	
	
		
	RETURN cCodRet,pFolioSuc;

END
END PROCEDURE
DOCUMENT
'DESCRIPCION: GENERA EL ENVIO CON PAGO CON CARGO A CUENTA DE MONTO ENVIO Y EFECTIVO LA COMISION E IVA, ACTIVA ENVIO EN SAC_ENVIOSDINEROYA', 
'AUTOR: ABIGAIL VASAVILBAZO CAÑEDO',
'FECHA: DICIEMBRE 2009',
'MODIFICACION: SE AGREGA CARGO PARA COMISION E IVA A CTA PRESTADORA Y SE UTILIZAN DIFERENTES TRANSACCIONES PARA ABONO DE PAGO EN EFECTIVO Y DE CARGO', 
'AUTOR: ABIGAIL VASAVILBAZO CAÑEDO',
'FECHA: ENERO 2010',
'VERSION: 20100126.0844',
'BD: BDISAC';

CREATE PROCEDURE "informix".sp_obtienecomisiones(pConvenio CHAR(40))
	RETURNING CHAR(5),CHAR(5),MONEY(16,2),MONEY(16,2),MONEY(16,2),MONEY(16,2),CHAR(1);

---- VARIABLES  GENERALES---
DEFINE cSqlerr			INTEGER;
DEFINE cCodret      	CHAR(5);
DEFINE vsSQL    		CHAR(100);
DEFINE cConvenio        CHAR(40);
DEFINE pId_convenio		CHAR(5);
DEFINE cNumCategoria	CHAR(2);
DEFINE cNumConvenio	CHAR(3);
DEFINE cId_Convenio CHAR(5);
DEFINE mValorMinimoComision MONEY(16,2);
DEFINE mMontoMinimo MONEY(16,2);
DEFINE mMontoMaximo MONEY(16,2);
DEFINE mComision MONEY(16,2);
DEFINE cTipo CHAR(1);

--VALORES INICIALES
LET cSqlerr = '';
LET cCodret = '00000';
LET vsSQL    = '';
LET cConvenio 	=	'';
LET pId_convenio = '';
LET cNumCategoria	=	'';
LET cNumConvenio	=	'';
LET cId_Convenio =	'';
LET mValorMinimoComision =	0.00;
LET mMontoMinimo =	0.00;
LET mMontoMaximo =	0.00;
LET mComision =	0.00;
LET cTipo =	'';

--SET debug FILE TO "/tmp/sp_ObtieneComisiones.out";
--Trace ON;

Begin
	------  Control de Errores no Controlados
    ON EXCEPTION SET cSqlerr
        IF cSqlerr <> 0 THEN
            Let cCodret = cSqlerr;    
			RETURN NVL(cCodret,''),NVL(cId_Convenio,''),NVL(mValorMinimoComision,''),NVL(mMontoMinimo,''),NVL(mMontoMaximo,''),NVL(mComision,''),NVL(cTipo,'');
        END IF;
	END EXCEPTION;

	--DEL  CONVENIO QUE SE RECIBE SE OBTIENE LA CATEGORIA Y EL NUMERO DE CONVENIO
	SELECT {+INDEX (bdisac:sac_convenios idxsac_conv3)} numcategoria,numconvenio INTO cNumCategoria,cNumConvenio FROM bdisac:sac_convenios WHERE nomconvenio = TRIM(pConvenio);
	LET pId_convenio = TRIM(cNumCategoria || cNumConvenio );
	--SE PUEDE VALIDAR SI NO REGRESA NADA ESE SELECT	
	FOREACH WITH HOLD 	
		SELECT {+INDEX (bdisac:sac_comisiones idxid_cov)} id_convenio,valorminimocomision,montominimo,montomaximo,comision,tipo
		INTO cId_Convenio, mValorMinimoComision, mMontoMinimo, mMontoMaximo, mComision, cTipo
		FROM bdisac:sac_comisiones
		WHERE id_convenio  = pId_convenio
		
		RETURN NVL(cCodret,''),NVL(cId_Convenio,''),NVL(mValorMinimoComision,''),NVL(mMontoMinimo,''),NVL(mMontoMaximo,''),NVL(mComision,''),NVL(cTipo,'') WITH RESUME;
	END FOREACH;	
END
END PROCEDURE
DOCUMENT
'AUTOR :César Valdéz Figueroa',
'DESCRIPCION:  Este Procedimiento Obtiene las comisiones parametrizadas filtrado por convenio y categoria.',
'FECHA : Octubre de 2009',
'BD    : BDISAC',
'VERSION: 20091022.0630';

CREATE PROCEDURE "informix".sp_sacreportemensualdish(cPeriodo CHAR(6))
RETURNING
	CHAR (6) AS retorno,
	CHAR(6) AS aniomes,
	DATE AS fecha,
	INTEGER AS num_operaciones,
	MONEY (16,2) AS comision,
	MONEY (16,2) AS iva;
    
DEFINE cCodRet					CHAR (6);
DEFINE cAnioMes					CHAR(6);
DEFINE dFecha					DATE ;
DEFINE iNumOperaciones			INTEGER;
DEFINE mComision				MONEY(16,2);
DEFINE mIva						MONEY(16,2);
DEFINE iSqlErr					INTEGER;
DEFINE iIsamErr					INTEGER;
DEFINE cInfoErr                 CHAR(100);

LET cCodRet				= '000000';
LET cAnioMes			= '';
LET dFecha				= '01-01-1900';
LET iNumOperaciones		= 0;
LET mComision			= 0;
LET mIva				= 0;
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET cInfoErr			= '';

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr

		IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				EXECUTE PROCEDURE sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_sacreportemensualdish");
				RETURN cCodRet, cAnioMes, dFecha, iNumOperaciones, mComision, mIva;
		END IF;

	END EXCEPTION;

-- SET DEBUG FILE TO  '/tmp/sp_sacreportemensualdish.out';
-- TRACE ON;

	IF  cPeriodo = "" OR LENGTH(cPeriodo) <> 6 THEN
		LET cCodRet = "00001";
		RETURN cCodRet, cAnioMes, dFecha, iNumOperaciones, mComision, mIva;
	ELSE   
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT {+INDEX (bdisac:sac_liquidacionmensualdish idx_sacliqmesdish)} aniomes, fecha, num_operaciones, comision, iva
			INTO cAnioMes, dFecha, iNumOperaciones, mComision, mIva
			FROM bdisac : sac_liquidacionmensualdish
			WHERE aniomes = cPeriodo
			ORDER BY fecha
			
			RETURN cCodRet, cAnioMes, dFecha, iNumOperaciones, mComision, mIva
			WITH RESUME;
		END FOREACH;
	END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR : Dulce Ramírez',
'DESCRIPCION: Obtiene la informacion para la generacion del reporte mensual dish',
'EJECUTADO O LLAMADO POR: repsac.exe',
'FECHA : Septiembre 2010',
'VERSION: 20100902.1709',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_sacreportemensualmastv(cPeriodo CHAR(6))
RETURNING
	CHAR (6) AS retorno,
	CHAR(6) AS aniomes,
	DATE AS fecha,
	INTEGER AS num_operaciones,
	MONEY (16,2) AS comision,
	MONEY (16,2) AS iva;
    
DEFINE cCodRet					CHAR (6);
DEFINE cAnioMes					CHAR(6);
DEFINE dFecha					DATE ;
DEFINE iNumOperaciones			INTEGER;
DEFINE mComision				MONEY(16,2);
DEFINE mIva						MONEY(16,2);
DEFINE iSqlErr					INTEGER;
DEFINE iIsamErr					INTEGER;
DEFINE cInfoErr                 CHAR(100);

LET cCodRet				= '000000';
LET cAnioMes			= '';
LET dFecha				= '01-01-1900';
LET iNumOperaciones		= 0;
LET mComision			= 0;
LET mIva				= 0;
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET cInfoErr			= '';

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr

		IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				EXECUTE PROCEDURE sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_sacreportemensualmastv");
				RETURN cCodRet, cAnioMes, dFecha, iNumOperaciones, mComision, mIva;
		END IF;

	END EXCEPTION;

-- SET DEBUG FILE TO  '/tmp/sp_sacreportemensualmastv.out';
-- TRACE ON;

	IF  cPeriodo = "" OR LENGTH(cPeriodo) <> 6 THEN
		LET cCodRet = "00001";
		RETURN cCodRet, cAnioMes, dFecha, iNumOperaciones, mComision, mIva;
	ELSE   
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT {+INDEX (bdisac:sac_liquidacionmensualmastv idx_sacliqmesmastv)} aniomes, fecha, num_operaciones, comision, iva
			INTO cAnioMes, dFecha, iNumOperaciones, mComision, mIva
			FROM bdisac : sac_liquidacionmensualmastv
			WHERE aniomes = cPeriodo
			ORDER BY fecha
			
			RETURN cCodRet, cAnioMes, dFecha, iNumOperaciones, mComision, mIva
			WITH RESUME;
		END FOREACH;
	END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR : Dulce Ramírez',
'DESCRIPCION: Obtiene la informacion para la generacion del reporte mensual mastv',
'EJECUTADO O LLAMADO POR: repsac.exe',
'FECHA : Septiembre 2010',
'VERSION: 20100902.1712',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_sacreportemensualsky(cPeriodo CHAR(6))
RETURNING
	CHAR (6) AS retorno,
	CHAR(6) AS aniomes,
	DATE AS fecha,
	INTEGER AS num_operaciones,
	MONEY (16,2) AS comision,
	MONEY (16,2) AS iva;
    
DEFINE cCodRet					CHAR (6);
DEFINE cAnioMes					CHAR(6);
DEFINE dFecha					DATE ;
DEFINE iNumOperaciones			INTEGER;
DEFINE mComision				MONEY(16,2);
DEFINE mIva						MONEY(16,2);
DEFINE iSqlErr					INTEGER;
DEFINE iIsamErr					INTEGER;
DEFINE cInfoErr                 CHAR(100);

LET cCodRet				= '000000';
LET cAnioMes			= '';
LET dFecha				= '01-01-1900';
LET iNumOperaciones		= 0;
LET mComision			= 0;
LET mIva				= 0;
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET cInfoErr			= '';

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr

		IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				EXECUTE PROCEDURE sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_sacreportemensualsky");
				RETURN cCodRet, cAnioMes, dFecha, iNumOperaciones, mComision, mIva;
		END IF;

	END EXCEPTION;

-- SET DEBUG FILE TO  '/tmp/sp_sacreportemensualsky.out';
-- TRACE ON;

	IF  cPeriodo = "" OR LENGTH(cPeriodo) <> 6 THEN
		LET cCodRet = "00001";
		RETURN cCodRet, cAnioMes, dFecha, iNumOperaciones, mComision, mIva;
	ELSE   
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT aniomes, fecha, num_operaciones, comision, iva
			INTO cAnioMes, dFecha, iNumOperaciones, mComision, mIva
			FROM bdisac : sac_liquidacionmensualsky
			WHERE aniomes = cPeriodo
			ORDER BY fecha
			
			RETURN cCodRet, cAnioMes, dFecha, iNumOperaciones, mComision, mIva
			WITH RESUME;
		END FOREACH;
	END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR : Raul Ruiz',
'DESCRIPCION: Obtiene la informacion para la generacion del reporte mensual sky',
'EJECUTADO O LLAMADO POR: repsac.exe',
'FECHA : Mayo 2010',
'VERSION: 20100524.1757',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_sacreportesemanalsky(Consecutivo INTEGER)
	RETURNING
		CHAR (6) AS retorno,
        INTEGER AS rec_lunes , 
        INTEGER AS rec_martes, 
        INTEGER AS rec_miercoles, 
        INTEGER AS rec_jueves, 
        INTEGER AS rec_viernes, 
        INTEGER AS rec_sabado, 
        INTEGER AS rec_domingo, 
        MONEY(16,2) AS cob_lunes, 
        MONEY(16,2) AS cob_martes, 
        MONEY(16,2) AS cob_miercoles, 
        MONEY(16,2) AS cob_jueves, 
        MONEY(16,2) AS cob_viernes, 
        MONEY(16,2) AS cob_sabado, 
        MONEY(16,2) AS cob_domingo, 
        INTEGER AS rec_efectivo, 
        INTEGER AS rec_chequemb, 
        INTEGER AS rec_chequeob, 
        INTEGER AS rec_tarcred, 
        MONEY(16,2) AS cob_efectivo, 
        MONEY(16,2) AS cob_cheqmb, 
        MONEY(16,2) AS cob_cheqob, 
        MONEY(16,2) AS cob_tarcred, 
        MONEY(16,2) AS liq_miercoles, 
        MONEY(16,2) AS liq_jueves, 
        MONEY(16,2) AS liq_viernes,
        MONEY(16,2) AS liq_lunes, 
        MONEY(16,2) AS liq_martes, 
        MONEY(16,2) AS aclaraciones, 
        MONEY(16,2) AS comision, 
        MONEY(16,2) AS iva_comision, 
        DATE AS fec_iniperiodo, 
        DATE AS fec_finperiodo, 
        INTEGER AS keyx;
     
		DEFINE cCodRet			CHAR (6);
        DEFINE iRecLunes		INTEGER; 
        DEFINE iRecMartes		INTEGER;
        DEFINE iRecMiercoles	INTEGER;
        DEFINE iRecJueves		INTEGER;
        DEFINE iRecViernes		INTEGER;
        DEFINE iRecSabado		INTEGER;
        DEFINE iRecDomingo		INTEGER;
        DEFINE mCobLunes		MONEY(16,2);
        DEFINE mCobMartes		MONEY(16,2); 
        DEFINE mCobMiercoles	MONEY(16,2);
        DEFINE mCobJueves		MONEY(16,2);
        DEFINE mCobViernes		MONEY(16,2);
        DEFINE mCobSabado		MONEY(16,2);
        DEFINE mCobDomingo		MONEY(16,2);
        DEFINE iRecEfectivo		INTEGER;
        DEFINE iRecChequemb		INTEGER;
        DEFINE iRecChequeob		INTEGER;
        DEFINE iRecTarcred		INTEGER;
        DEFINE mCobEfectivo		INTEGER;
        DEFINE mCobCheqmb		MONEY(16,2);
        DEFINE mCobCheqob		MONEY(16,2);
        DEFINE mCobTarcred		MONEY(16,2);
        DEFINE mLiqMiercoles	MONEY(16,2);
        DEFINE mLiqJueves		MONEY(16,2);
        DEFINE mLiqViernes		MONEY(16,2);
        DEFINE mLiqLunes		MONEY(16,2);
        DEFINE mLiqMartes		MONEY(16,2);
        DEFINE mAclaraciones	MONEY(16,2);
        DEFINE mComision		MONEY(16,2);
        DEFINE mIvaComision		MONEY(16,2);
        DEFINE dFecIniPeriodo	DATE;
        DEFINE dFecFinPeriodo	DATE;
        DEFINE iConsecutivo		INTEGER;
		DEFINE iSqlErr			INTEGER;
		DEFINE iIsamErr			INTEGER;
		DEFINE cInfoErr         CHAR(100);

		LET cCodRet			= '000000';
        LET iRecLunes		= 0;
        LET iRecMartes		= 0;
        LET iRecMiercoles	= 0;
        LET iRecJueves		= 0;
        LET iRecViernes		= 0;
        LET iRecSabado		= 0;
        LET iRecDomingo		= 0;
        LET mCobLunes		= 0;
        LET mCobMartes		= 0;
        LET mCobMiercoles	= 0;
        LET mCobJueves		= 0;
        LET mCobViernes		= 0;
        LET mCobSabado		= 0;
        LET mCobDomingo		= 0;
        LET iRecEfectivo	= 0;
        LET iRecChequemb	= 0;
        LET iRecChequeob	= 0;
        LET iRecTarcred		= 0;
        LET mCobEfectivo	= 0;
        LET mCobCheqmb		= 0;
        LET mCobCheqob		= 0;
        LET mCobTarcred		= 0;
        LET mLiqMiercoles	= 0;
        LET mLiqJueves		= 0;
        LET mLiqViernes		= 0;
        LET mLiqLunes		= 0;
        LET mLiqMartes		= 0;
        LET mAclaraciones	= 0;
        LET mComision		= 0;
        LET mIvaComision	= 0;
        LET dFecIniPeriodo	= '01-01-1900';
        LET dFecFinPeriodo	= '01-01-1900';
        LET iConsecutivo	= 0;
		LET iSqlErr			= 0;
		LET iIsamErr		= 0;
		LET cInfoErr		= '';

		BEGIN
			ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr

				IF iSqlErr <> 0 THEN
						LET cCodRet = iSqlErr;
						EXECUTE PROCEDURE sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_sacreportesemanalsky");
						RETURN cCodRet, iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes, 
							mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred, mCobEfectivo, 
							mCobCheqmb, mCobCheqob, mCobTarcred, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqLunes, mLiqMartes, mAclaraciones, mComision, 
							mIvaComision, dFecIniPeriodo, dFecFinPeriodo, iConsecutivo;
				END IF;

			END EXCEPTION;

	-- SET DEBUG FILE TO  '/tmp/sp_sacreportesemanalsky.out';
	-- TRACE ON;

			IF  Consecutivo IS NULL THEN
				LET cCodRet = "00001";
				RETURN cCodRet, iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes, 
					mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred, mCobEfectivo, 
					mCobCheqmb, mCobCheqob, mCobTarcred, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqLunes, mLiqMartes, mAclaraciones, mComision, 
					mIvaComision, dFecIniPeriodo, dFecFinPeriodo, iConsecutivo;
			ELSE   
				SET ISOLATION TO DIRTY READ;
					FOREACH
						SELECT rec_lunes, rec_martes, rec_miercoles, rec_jueves, rec_viernes, rec_sabado, rec_domingo, cob_lunes, cob_martes, 
							cob_miercoles, cob_jueves, cob_viernes, cob_sabado, cob_domingo, rec_efectivo, rec_chequemb, rec_chequeob, rec_tarcred, 
							cob_efectivo, cob_cheqmb, cob_cheqob, cob_tarcred, liq_miercoles, liq_jueves, liq_viernes, liq_lunes, liq_martes, 
							aclaraciones, comision, iva_comision, fec_iniperiodo, fec_finperiodo, keyx 
						INTO iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes, 
							mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred, mCobEfectivo, 
							mCobCheqmb, mCobCheqob, mCobTarcred, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqLunes, mLiqMartes, mAclaraciones, mComision, 
							mIvaComision, dFecIniPeriodo, dFecFinPeriodo, iConsecutivo 
						FROM bdisac : sac_liquidacionsemanalsky
						WHERE keyx  = Consecutivo
						
						
						RETURN cCodRet, iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes, 
							mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred, mCobEfectivo, 
							mCobCheqmb, mCobCheqob, mCobTarcred, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqLunes, mLiqMartes, mAclaraciones, mComision, 
							mIvaComision, dFecIniPeriodo, dFecFinPeriodo, iConsecutivo
						WITH RESUME;
					END FOREACH;
			END IF;
		END;
	END PROCEDURE
	DOCUMENT
	'AUTOR : Raul Ruiz',
	'DESCRIPCION: Consulta la informacion para la generacion del reporte de liquidacion semanal de pagos sky',
	'EJECUTADO O LLAMADO POR: repsac.exe',
	'FECHA : Mayo 2010',
	'VERSION: 20100524.1755',
	'BD    : bdisac';

CREATE PROCEDURE "informix".sp_repservicios_totales (dFechaI char(10), dFechaF char(10))
    RETURNING CHAR(5),CHAR(50),INTEGER,MONEY(16,2),MONEY(16,2),MONEY(16,2),MONEY(16,2),MONEY(16,2),MONEY(16,2);
    -- Definicion de Variables
    DEFINE cCodRet CHAR(5);
    DEFINE iSql_err INT;
    DEFINE cNomConvenio CHAR(50);
    DEFINE iNumPagos    INTEGER;
    DEFINE mImportePago  MONEY(16,2);
    DEFINE mIVAComisionConvenio MONEY(16,2);
    DEFINE mImpComisionCte     MONEY(16,2);
    DEFINE mImpComisionConvenio   MONEY(16,2);
    DEFINE mIVAComisionCte   MONEY(16,2);
    DEFINE cNumcategoria CHAR(5);
    DEFINE cNumconvenio CHAR(5);
    DEFINE Importe_total   MONEY(16,2);
    -- Inicializa variables
    LET cCodRet = "00000";
    LET iSql_err = 0;
    LET cNomConvenio = "";
    LET iNumPagos = 0;
    LET mImportePago = 0;
    LET mIVAComisionConvenio = 0;
    LET mImpComisionCte = 0;
    LET mImpComisionConvenio = 0;
    LET mIVAComisionCte = 0;
    LET Importe_total = 0;
    LET cNumcategoria = "";
    LET cNumconvenio = "";

     --SET DEBUG FILE TO "/home/informix/VHSM/sp_repservicios_totales.out";
     --TRACE ON;

    BEGIN
        ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET cCodRet = iSql_err;
                RETURN cCodRet, cNomConvenio,iNumPagos, mImportePago, mImpComisionConvenio,mIVAComisionConvenio, mImpComisionCte,mIVAComisionCte,Importe_total;
            END IF;
        END EXCEPTION;

FOREACH
      SELECT {+INDEX (bdisac:sac_convenios 103_9)} TRIM(NVL(nomconvenio,'')), TRIM(NVL(numcategoria,'')), TRIM(NVL(numconvenio,''))
      INTO cNomConvenio, cNumcategoria, cNumconvenio
      FROM bdisac:sac_convenios
      where statusconvenio='A'
 
      SET ISOLATION TO DIRTY READ;
      SELECT count(*),nvl(sum(importe_pago),0),nvl(sum(importe_comision_convenio),0),nvl(sum(iva_comision_convenio),0),
      nvl(sum(importe_comision_cte),0)  ,nvl(sum(iva_comision_cte),0)
      INTO iNumPagos, mImportePago, mImpComisionConvenio,mIVAComisionConvenio, mImpComisionCte,mIVAComisionCte
      FROM bdisac:sac_movimientoshistorial
      WHERE fecha_pago::DATE >= dFechaI AND fecha_pago::DATE  <= dFechaF AND numcategoria = cNumcategoria AND
      numconvenio = cNumConvenio AND status_cancelado <> 'S'
      AND flag_confirmacion_central = 1
      AND flag_confirmacion_sucursal = 1;

      let Importe_total=mImportePago-mImpComisionConvenio-mIVAComisionConvenio-mImpComisionCte-mIVAComisionCte;

      RETURN cCodRet, cNomConvenio,iNumPagos, mImportePago, mImpComisionConvenio,mIVAComisionConvenio, mImpComisionCte,mIVAComisionCte,Importe_total WITH RESUME;

END FOREACH;

END;
END PROCEDURE;