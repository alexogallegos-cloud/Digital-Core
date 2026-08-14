CREATE PROCEDURE "informix".sp_valida_dv_emprndmsfin
(
	  pNumRef CHAR (10)
)
RETURNING CHAR(5) AS cod_ret;

DEFINE cCod_ret         CHAR(5);
DEFINE vCadena          CHAR(100);
DEFINE iSqlErr          INTEGER;
DEFINE vPosicion		INTEGER;
DEFINE vMultip 			INTEGER;
DEFINE vSuma 			INTEGER;
DEFINE vResultado 		INTEGER;
DEFINE VNumRefInteger	INTEGER;

LET cCod_ret    = '00000';
LET iSqlErr     = 0;
LET vMultip		= 2;
LET vResultado	= 0;
LET vCadena 	= '';
LET VNumRefInteger = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				
				IF iSqlErr='-1213' THEN
					LET cCod_ret = '00004';
				ELSE
					LET cCod_ret = iSqlErr;
				END IF
				
				RETURN cCod_ret;	
			END IF;
		END EXCEPTION;
		 
		SET ISOLATION TO DIRTY READ;		
		SET LOCK MODE TO WAIT 3;
		
		IF LEN(pNumRef) < 10 THEN
			LET cCod_ret = '00002';
			RETURN cCod_ret;	
		END IF;
		
			--SET DEBUG FILE TO '/informix/noe/sp_valida_dv_emprndmsfin.out';
			--TRACE ON;
		
		
		--VALIDA QUE LOS ULTIMOS 9 CARACTERES SEAN NUMERICOS
			LET VNumRefInteger = CAST(SUBSTR(pNumRef, 2,9) as INTEGER);

		--VALIDA PRIMER CARACTER DE LA REFERENCIA	
			IF UPPER(SUBSTR(pNumRef, 1,1)) = 'P' THEN
				LET pNumRef = '7' || SUBSTR(pNumRef, 2,9);
			ELSE
				--VALIDA QUE TODA LA CADENA SEA NUMERICA
					LET VNumRefInteger = CAST(pNumRef as INTEGER);
			END IF;


		--PASO 1 ALGORITMO DV
			FOR vPosicion=1 TO 9 LOOP
				
				LET vSuma= (cast(substr(pNumRef, vPosicion,1) AS INTEGER) * vMultip);
				
				IF vSuma > 9 THEN
					LET vSuma = SUBSTR(vSuma,1,1) + SUBSTR(vSuma,2,1);
				END IF;
		--PASO 2 ALGORITMO DV	
				LET vResultado= vResultado + vSuma;
				
				IF vMultip = 2 THEN
					LET vMultip = 1;
				ELIF vMultip = 1 THEN
					LET vMultip = 2;
				END IF;
				
			END LOOP;
			
		--PASO 3 ALGORITMO
			IF MOD(vResultado,10) = 0 THEN
				LET vResultado = 0;
			ELSE
		--PASO 4 ALGORITMO DV
				LET vResultado = 10 - MOD(vResultado,10) ;
			END IF;
			
			
			IF vResultado <> CAST(SUBSTR(pNumRef, 10,1) AS INTEGER) THEN
				LET cCod_ret = '00109';
			END IF;

			RETURN cCod_ret;
	END
END PROCEDURE
DOCUMENT
'AUTOR: Noe Medina Ramirez',
'FOLIO: ',
'DESCRIPCION: Valida el digito verificador de EMPRENDAMOSFIN',
'FECHA: 07/06/2017',
'VERSION: 1.0000',
'BD:Bdisac';

CREATE PROCEDURE "informix".sp_dinya_calcularcomisioniva 
	(pIdConvenio CHAR(5),
	pImporte MONEY (16,2),
	pSucursalOrigen CHAR(4))
RETURNING  CHAR(5),MONEY (16,2),MONEY (16,2),MONEY (16,2),MONEY (16,2),MONEY (16,2);

DEFINE cCodRet 				CHAR(5);
DEFINE cMensaje				CHAR(50);
DEFINE mTotComision			MONEY (16,2);
DEFINE mTotIvaComision		MONEY (16,2);
DEFINE mValorComision		MONEY (16,2);
DEFINE mValorMinimoComision	MONEY (16,2);
DEFINE mValorMinComRango1	MONEY (16,2);
DEFINE mValorMaxComRango2	MONEY (16,2);
DEFINE mValorIVACiudad		MONEY (16,2);
DEFINE mTotIVA				MONEY (16,2);
DEFINE mTotalaCobrar		MONEY (16,2);
DEFINE iSqlErr				INTEGER;
DEFINE isam_error			INTEGER;
DEFINE iTipoComision		INTEGER;
DEFINE dFecha_envio			DATE;

BEGIN
	ON EXCEPTION SET iSqlErr,isam_error,cMensaje
		IF iSqlErr != 0 THEN
			LET cCodRet= iSqlErr;
			INSERT INTO sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)
			VALUES (iSqlErr,isam_error,cMensaje,'sp_DinYa_CalcularComisionIva',dFecha_envio,CURRENT );
			RETURN cCodRet,mTotComision,mTotIVA,mTotIvaComision,pImporte,mTotalaCobrar;
		END IF;
	END EXCEPTION;
	--SET DEBUG FILE TO "/tmp/sp_dinya_calcularcomisioniva.out";
	--TRACE ON;	

LET cCodRet 				= '00000';
LET mTotComision			= '0.00';
LET mTotIvaComision			= '0.00';
LET mValorMinComRango1		= '0.00';
LET mValorMaxComRango2		= '0.00';
LET mValorMinimoComision	= '0.00';
LET mValorComision			= '0.00';
LET mValorIVACiudad			= '0.00';
LET mTotIVA					= '0.00';
LET mTotalaCobrar			= '0.00';
LET cMensaje				= '';
LET dFecha_envio			= '';
LET iSqlErr					= 0;
LET iTipoComision			= 0;
LET iSqlErr					= 0;
LET isam_error				= 0;
	
	SELECT fecha_hoy INTO dFecha_envio
	FROM sac_fechas where empresa='001';

	IF pIdConvenio IS NULL OR pImporte IS NULL OR pSucursalOrigen IS NULL OR pIdConvenio = '' OR pImporte = '' OR pSucursalOrigen = '' THEN
		LET cCodRet = '00001';
		RETURN cCodRet,mTotComision,mTotIVA,mTotIvaComision,pImporte,mTotalaCobrar;
	END IF;
	
	SELECT {+INDEX (bdisac:sac_comisiones idxid_cov)} {+INDEX (bdisac:sac_convenios idxsac_conv3)} MIN(com.montominimo) INTO mValorMinComRango1 
	FROM bdisac:sac_comisiones as com
	INNER JOIN bdisac:sac_convenios as cn ON (cn.numcategoria = SUBSTR(pIdConvenio,1,2) AND cn.numconvenio = SUBSTR(pIdConvenio,3,3))
	WHERE com.id_convenio = pIdConvenio;
	
	SELECT {+INDEX (bdisac:sac_comisiones idxid_cov)} {+INDEX (bdisac:sac_convenios idxsac_conv3)} MAX(com.montomaximo) INTO mValorMaxComRango2 
	FROM bdisac:sac_comisiones as com
	INNER JOIN bdisac:sac_convenios as cn ON (cn.numcategoria = SUBSTR(pIdConvenio,1,2) AND cn.numconvenio = SUBSTR(pIdConvenio,3,3))
	WHERE com.id_convenio = pIdConvenio;
		
		IF mValorMinComRango1 IS NULL OR mValorMaxComRango2 IS NULL THEN
			LET cCodRet = '00002';
			RETURN cCodRet,mTotComision,mTotIVA,mTotIvaComision,pImporte,mTotalaCobrar;
		END IF;
	
		IF pImporte < mValorMinComRango1 OR pImporte > mValorMaxComRango2 THEN
			LET cCodRet = '00003';
			RETURN cCodRet,mTotComision,mTotIVA,mTotIvaComision,pImporte,mTotalaCobrar;
		END IF;

	SELECT {+INDEX (bdisac:sac_comisiones idxsac_conm1)} montominimo,montomaximo,valorminimocomision,comision,tipo 
	INTO mValorMinComRango1,mValorMaxComRango2,mValorMinimoComision,mValorComision,iTipoComision
	FROM bdisac:sac_comisiones 
	WHERE id_convenio = pIdConvenio 
	 AND montominimo <= pImporte 
	 AND montomaximo >= pImporte;
	 
		IF iTipoComision = 1 THEN
			LET mTotComision = mValorComision;
		END IF;
		
		IF iTipoComision = 2 THEN
			LET mTotComision = pImporte * (mValorComision/100);
		END IF;

		IF mTotComision < mValorMinimoComision THEN
			LET mTotComision = mValorMinimoComision;
		END IF;
	
	SELECT iva INTO mValorIVACiudad FROM bdinteg:si_sucursales WHERE sucursal = pSucursalOrigen;
	
		IF mValorIVACiudad IS NULL OR mValorIVACiudad = '' THEN
			LET cCodRet = '00004';
			RETURN cCodRet,mTotComision,mTotIVA,mTotIvaComision,pImporte,mTotalaCobrar;
		END IF;


				IF iTipoComision = 3 THEN  -------------------MODIFICACION VERSION: 20170728.1213------------------
					LET mTotComision = mValorComision;
					LET mTotIVA = mValorComision * mValorIVACiudad;
				ELSE
					LET mTotIVA = mTotComision * mValorIVACiudad;				
                END IF;

		LET mTotIvaComision = mTotComision + mTotIVA;
		LET mTotalaCobrar = pImporte + mTotIvaComision;
	
    RETURN cCodRet,mTotComision,mTotIVA,mTotIvaComision,pImporte,mTotalaCobrar;

END
END PROCEDURE

Document
'DESCRIPCION: Calcula el IVA y Comision de un importe', 
'AUTOR: Antonio Bastidas',
'FECHA: 21 de octubre de 2009',
'VERSION: 20091021.1314',
'BD: BDISAC',

'MODIFICACION: SE AGREGA CONDICION PARA EVALUAR EL TIPO DE COMISION 3 (comision+iva= $50)', 
'AUTOR: Noe Medina R.',
'FECHA: 21 de Junio de 2017',
'VERSION: 20170621.1725',
'BD: BDISAC';

CREATE PROCEDURE "informix".sp_decodificadatospermisosadmintemrevo(pLineaCaptura CHAR(20), pImporte CHAR(16), pLlaveGDF INTEGER)
	RETURNING CHAR(5) AS CodRetorno, CHAR(60) AS Leyenda, CHAR(25) AS Folio;
	
	--Definicion de Variables
	DEFINE iSqlErr 				INTEGER;
	DEFINE cCodRet 				CHAR(5);
	DEFINE cCodRet2				CHAR(5);
	DEFINE cLeyenda				CHAR(60);
	DEFINE cLineaCapturaBase	CHAR(20);
	DEFINE cConcepto			CHAR(2);
	DEFINE cFolio				CHAR(25);
	
	--Inicializacion de Variables
	LET iSqlErr 			= 0;
	LET cCodRet 			= '00000';
	LET cCodRet2			= '00000';
	LET cLeyenda			= '';
	LET cLineaCapturaBase	= '';
	LET cConcepto			= '';
	LET cFolio				= '';
		
	--SET DEBUG FILE TO "/home/informix/bibiana/sp_decodificadatospermisosadmintemrevo.out";
	--TRACE ON;
	
	BEGIN
		--Control de excepciones
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET  cCodRet = iSqlErr;
				RETURN cCodRet, '', '';
			END IF;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		
		--Se valida que la Linea de Captura y el Importe tengan el formato correcto
		IF TRIM(NVL(pLineaCaptura,'')) = '' OR LENGTH(TRIM(pLineaCaptura)) <> 20 OR TRIM(NVL(pImporte,'')) = '' OR TRIM(NVL(pLlaveGDF,'')) = '' THEN
			LET cCodRet = '00001';
		ELSE
			--Se valida que sea una Linea de Captura apta para ser procesada y la Linea de Captura Base 
			--para decodificar los datos necesarios
			EXECUTE PROCEDURE bdisac:"informix".sp_obtienelineabase_bpi(pLineaCaptura, pImporte, pLlaveGDF)
			INTO cCodRet2, cLeyenda, cLineaCapturaBase;
			
			IF NVL(cCodRet2, '') = '00000' THEN
				LET cConcepto = SUBSTR(pLineaCaptura, 1, 2);
				
				SELECT descripcion 
				INTO cLeyenda 
				FROM bdisac:"informix".sac_catconceptosgdf
				WHERE clave = cConcepto;
				
				LET cLeyenda =  cLeyenda;				
				LET cFolio = SUBSTR(cLineaCapturaBase, 3, 11);
				 
			ELSE
				LET cCodRet = cCodRet2;
			END IF;
		END IF;
		
		RETURN cCodRet, cLeyenda, cFolio;
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea Procedimiento Almacenado para decodificar datos de la Linea de Captura Base de Pagos de Impuesto de GDF ',
'				(Permisos Administrativos Temporales Revocables  , Conceptos 20 - 21).',
'BD: bdisac',
'Fecha: 02-08-2017',
'ModificaciÃ³n: Se aÃ±ade un nuevo parÃ¡metro quen contiene la llave de decodificaciÃ³n de la linea base.',
'Sustento: Reimpresion GDF';

CREATE PROCEDURE "informix".sp_actualiza_datos(pTipoProceso CHAR(3), pFechaInicio DATE, pFechaFin DATE)
	
    RETURNING
    CHAR(100),CHAR(5), CHAR (100);

    --DEFINICION DE VARIABLES
	DEFINE iSqlErr 			 INTEGER;
	DEFINE iSamErr 			 INTEGER;
	DEFINE cVarError		 CHAR (100);
	DEFINE cCodret           CHAR (5);
	DEFINE cStatus_ejecucion CHAR (1);
	DEFINE cProceso  		 CHAR (100);
	DEFINE dFechaIni         DATETIME YEAR TO FRACTION(5);
	DEFINE dFechaFin         DATETIME YEAR TO FRACTION(5);
	DEFINE cMaxCredito		 CHAR (30);
	DEFINE cMinCredito		 CHAR (30);
	DEFINE cVarDataErr       CHAR (100);
	DEFINE iEstatus			 INTEGER;
	
	DEFINE cNumCte 			CHAR (100);
	DEFINE cNumCredito  	CHAR (100);
	
	DEFINE cNumcteCoppel 	CHAR(20);
    DEFINE cSucursal 		CHAR(4);
    DEFINE dFecha_alta    	DATE;
    DEFINE cApell_paterno 	CHAR(26);
    DEFINE cApell_materno 	CHAR(26);
    DEFINE cNombre1       	CHAR(26);
    DEFINE cNombre2       	CHAR(26);
    DEFINE dFecha_nac     	DATE;
    DEFINE cEstado_civil  	CHAR(2);
    DEFINE cSexo          	CHAR(1);
    DEFINE cRfc           	CHAR(13);
    DEFINE cGrupo         	CHAR(3);
    DEFINE cSubgrupo      	CHAR(3);
    DEFINE cCalle         	CHAR(40);
    DEFINE cColonia       	CHAR(60);
    DEFINE cEstado        	CHAR(2);
    DEFINE cCiudad        	CHAR(3);
    DEFINE cMunicipio     	CHAR(5);
    DEFINE cCod_postal    	CHAR(5);
    DEFINE cNumeroextcalle	CHAR(10);
    DEFINE cNumerointcalle	CHAR(10);
    DEFINE cDepartamento  	CHAR(6);
    DEFINE smManzana       	SMALLINT;
    DEFINE smAndador       	SMALLINT;
    DEFINE smEtapa         	SMALLINT;
    DEFINE smLote          	SMALLINT;
    DEFINE smEdificio      	SMALLINT;
    DEFINE smEntrada       	SMALLINT;
    DEFINE cObservaciones 	CHAR(80);	
	
	DEFINE cCasa      		VARCHAR(13);
    DEFINE cCelular   		VARCHAR(13);
    DEFINE cOficina   		VARCHAR(13);
    DEFINE cOtro      		VARCHAR(13);
    DEFINE cExtension 		CHAR(5);
    DEFINE cCarrier   		VARCHAR(30);
    DEFINE cStatus_tel		CHAR(1);
    DEFINE cCofetel   		CHAR(1);
    DEFINE cMovil_fijo		CHAR(1);
	
    DEFINE cCorreo_elec  	CHAR(100);
    DEFINE cTipo_correo  	SMALLINT;
    DEFINE cStatus_correo	CHAR(1);
    DEFINE cValido       	CHAR(1);

	DEFINE cNumProducto		CHAR(4);
	DEFINE cStatusCred		CHAR(2);
	DEFINE dFechaApertura	DATE;
	DEFINE dMontoOtorgado	DECIMAL(14,2);
	DEFINE dNoTcAdi			DECIMAL(14,2);
	DEFINE sSecuencia		SMALLINT;
	DEFINE cNumTarjeta		CHAR(20);
	DEFINE dExpiracion		DATE;
	DEFINE cTipoTarjeta		CHAR(1);
	DEFINE cStatusTar		CHAR(1);

	
    --INICIALIZACION DE VARIABLES
	LET iSqlErr           	= 0;
	LET iSamErr           	= 0;
	LET cVarError		  	= "EJECUCION EXITOSA DAT";
	LET cCodret           	= "00000";
	LET cStatus_ejecucion 	= "1";
	LET cProceso          	= "SP_ACTUALIZA_DATOS";
	LET dFechaIni 		  	= CURRENT;
	LET dFechaFin 		  	= '';
	LET cMaxCredito		  	= '';
	LET cMinCredito		  	= '';
	LET cVarDataErr 	  	= '';
	LET iEstatus          	= 1;
	
	LET cNumCte           	= "";
	LET cNumCredito       	= "";	
	
    LET cNumcteCoppel 		= "";
    LET cSucursal 			= "";
    LET dFecha_alta    		= "";
    LET cApell_paterno 		= "";
    LET cApell_materno 		= "";
    LET cNombre1       		= "";
    LET cNombre2       		= "";
    LET dFecha_nac     		= "";
    LET cEstado_civil  		= "";
    LET cSexo          		= "";
    LET cRfc           		= "";
    LET cGrupo         		= "";
    LET cSubgrupo      		= "";
    LET cCalle         		= "";
    LET cColonia       		= "";
    LET cEstado        		= "";
    LET cCiudad        		= "";
    LET cMunicipio     		= "";
    LET cCod_postal    		= "";
    LET cNumeroextcalle		= "";
    LET cNumerointcalle		= "";
    LET cDepartamento  		= "";
    LET smManzana       	= "";
    LET smAndador       	= "";
    LET smEtapa         	= "";
    LET smLote          	= "";
    LET smEdificio      	= "";
    LET smEntrada       	= "";
    LET cObservaciones 		= "";
	
	LET cCasa 				= "";
    LET cCelular 			= "";
    LET cOficina 			= "";
    LET cOtro 				= "";
    LET cExtension 			= "";
    LET cCarrier 			= "";
    LET cStatus_tel 		= "";
    LET cCofetel 			= "";
    LET cMovil_fijo 		= "";
	
    LET cCorreo_elec 		= "";
    LET cTipo_correo 		= "";
    LET cStatus_correo 		= "";
    LET cValido 			= "";

	LET cNumProducto 		= "";
	LET cSucursal 			= "";
	LET cStatusCred 		= "";
	LET dFechaApertura 		= "";
	LET dMontoOtorgado 		= "";
	LET dNoTcAdi 			= "";
	LET sSecuencia 			= "";
	LET cNumTarjeta 		= "";
	LET dExpiracion 		= "";
	LET cTipoTarjeta 		= "";
	LET cStatusTar 			= "";
	
	--SET DEBUG FILE TO "/informix/ljfs/sp_actualiza_datos_ljfs.out";
	--TRACE ON; 
	
    BEGIN
	
		--CONTROLAMOS ERRORES
		ON EXCEPTION SET iSqlErr, iSamErr, cVarError
				IF iSqlErr <> 0 THEN
					LET cCodRet=iSqlErr;
					LET cStatus_ejecucion = 0;
					LET cVarError = 'ERROR NO CONTROLADO';
				
				INSERT INTO bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso (nombre_proceso, fecha_inicio, fecha_fin, status_ejecucion, observacion, tipo_proceso)
				VALUES (cProceso, dFechaIni, CURRENT, cStatus_ejecucion,cVarError, pTipoProceso);
				
				RETURN cProceso,cCodRet,cVarError;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT  DBINFO('utc_to_datetime',sh_curtime)
		INTO    dFechaIni
		FROM    sysmaster:"informix".sysshmvals;
		
		DROP TABLE IF EXISTS tmp_clientes_unica;
		DROP TABLE IF EXISTS tmp_telefonos_unica;
		DROP TABLE IF EXISTS tmp_correos_unica;
		DROP TABLE IF EXISTS tmp_creditos_unica;
		TRUNCATE TABLE bdisac:"informix".tmp_actualiza_datos;
		
		--VALIDAR LOS PARAMETROS DE ENTRADA
		IF NVL(pTipoProceso,'') = '' OR NVL(pFechaInicio,'')= '' OR NVL(pFechaFin,'') = '' THEN
			LET cCodRet = '00001'; 
			LET cStatus_ejecucion = 0;
			LET cVarError = "FALTAN PARAMETROS DE ENTRADA";
			INSERT INTO bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso (nombre_proceso, fecha_inicio, fecha_fin,status_ejecucion, observacion, tipo_proceso)
			VALUES (cProceso, dFechaIni, CURRENT, cStatus_ejecucion, cVarError, pTipoProceso);
					
			RETURN cProceso, cCodRet, cVarError;
		END IF;
		
		IF pFechaFin > CURRENT::DATE THEN
			LET cCodRet = '00002'; 
			LET cStatus_ejecucion = 0;
			LET cVarError = "FECHA FINAL ES MAYOR A LA FECHA DE HOY";
			INSERT INTO bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso (nombre_proceso, fecha_inicio, fecha_fin,status_ejecucion, observacion, tipo_proceso)
			VALUES (cProceso, dFechaIni, CURRENT, cStatus_ejecucion, cVarError, pTipoProceso);
					
			RETURN cProceso,cCodRet, cVarError;
		END IF;
		
		IF pFechaInicio > pFechaFin THEN
			LET cCodRet = '00003'; 
			LET cStatus_ejecucion = 0;
			LET cVarError= "FECHA INICIO ES MAYOR A LA FECHA FIN";
			INSERT INTO bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso (nombre_proceso, fecha_inicio, fecha_fin,status_ejecucion, observacion, tipo_proceso)
			VALUES (cProceso, dFechaIni, CURRENT, cStatus_ejecucion, cVarError, pTipoProceso);
			
			RETURN cProceso,cCodRet, cVarError;
		END IF;
		--TERMINA DE VALIDAR LOS PARAMETROS DE ENTRADA		
		
	 SELECT MIN(num_credito)
	 INTO   cMinCredito
	 FROM   bdiunica@stag_ids1170:"informix".uni_ind_credito;
		
	 SELECT MAX(num_credito)
	 INTO   cMaxCredito
	 FROM   bdiunica@stag_ids1170:"informix".uni_ind_credito;
	 
	 
	IF (UPPER(pTipoProceso) = 'DAT') THEN
	
	    -- ACTUALIZAMOS SOLICITUDES - CLIENTE
		-- IDENTIFICAMOS LAS SOLICITUDES SIN CLIENTES
		INSERT INTO bdisac:"informix".tmp_actualiza_datos(numcte, num_credito)
		SELECT  sl.numcte,
				'000000000000' AS num_credito
		FROM    bdiunica@stag_ids1170:"informix".uni_solicitudes sl
		WHERE   sl.numcte NOT IN (SELECT  numcte
								  FROM    bdiunica@stag_ids1170:"informix".uni_cliente cl);

		-- OBTNENEMOS LOS DATOS DE LOS CLIENTES
		SELECT  act.numcte,cliente.numcte_ref as num_cte_coppel,cliente.sucursal,cliente.fecha_alta,cliente.apell_paterno,cliente.apell_materno,
				cliente.nombre1,cliente.nombre2,ctepf.fecha_nac,ctepf.estado_civil,ctepf.sexo,cliente.rfc,cliente.grupo,cliente.subgrupo,
				direccion.calle,direccion.colonia,direccion.estado,direccion.ciudad,direccion.municipio,direccion.cod_postal,direccion.numeroextcalle,direccion.numerointcalle,
				direccion.departamento,direccion.manzana,direccion.andador,direccion.etapa,direccion.lote,direccion.edificio,direccion.entrada,direccion.observaciones
		FROM    bdisac:"informix".tmp_actualiza_datos act, bdinteg:"informix".si_cliente cliente, bdinteg:"informix".si_ctepf ctepf, bdinteg:"informix".si_direcciones_actual direccion
		WHERE   act.numcte = cliente.numcte
		AND     cliente.numcte = ctepf.numcte
		AND     cliente.numcte = direccion.numcte
		AND     tipo_cliente = '1'
		AND     direccion.tipo_dir = '1'		
		INTO TEMP tmp_clientes_unica WITH NO LOG;
		
		FOREACH 
			SELECT numcte, num_cte_coppel,sucursal,fecha_alta,apell_paterno,apell_materno, nombre1,nombre2,fecha_nac,estado_civil,sexo,rfc,grupo,subgrupo,
				   calle,colonia,estado,ciudad,municipio,cod_postal,numeroextcalle,numerointcalle, departamento,manzana,andador,etapa,lote,edificio,entrada,observaciones
			INTO cNumcte, cNumcteCoppel, cSucursal, dFecha_alta, cApell_paterno, cApell_materno, cNombre1, cNombre2, dFecha_nac, cEstado_civil, cSexo, cRfc, cGrupo, cSubgrupo,
				 cCalle, cColonia, cEstado, cCiudad, cMunicipio, cCod_postal, cNumeroextcalle, cNumerointcalle, cDepartamento, smManzana, smAndador, smEtapa, smLote, smEdificio, smEntrada, cObservaciones
			FROM bdisac:tmp_clientes_unica
			
			IF EXISTS (SELECT numcte FROM bdiunica@stag_ids1170:"informix".uni_cliente WHERE numcte = cNumcte) THEN
				UPDATE bdiunica@stag_ids1170:"informix".uni_cliente
				SET num_cte_coppel = cNumcteCoppel, sucursal = cSucursal, fecha_alta = dFecha_alta, apell_paterno = cApell_paterno, apell_materno = cApell_materno, nombre1 = cNombre1, nombre2 = cNombre2, fecha_nac = dFecha_nac, estado_civil = cEstado_civil, sexo = cSexo, rfc = cRfc, grupo = cGrupo, subgrupo = cSubgrupo,
					calle = cCalle, colonia = cColonia, estado = cEstado, ciudad = cCiudad, municipio = cMunicipio, cod_postal = cCod_postal, numeroextcalle = cNumeroextcalle, numerointcalle = cNumerointcalle, departamento = cDepartamento,manzana = smManzana, andador = smAndador, etapa = smEtapa, lote = smLote, edificio = smEdificio, entrada = smEntrada, observaciones = cObservaciones
				WHERE numcte = cNumcte;
			ELSE
				INSERT INTO bdiunica@stag_ids1170:"informix".uni_cliente (numcte, num_cte_coppel,sucursal,fecha_alta,apell_paterno,apell_materno, nombre1,nombre2,fecha_nac,estado_civil,sexo,rfc,grupo,subgrupo,
				   calle,colonia,estado,ciudad,municipio,cod_postal,numeroextcalle,numerointcalle, departamento,manzana,andador,etapa,lote,edificio,entrada,observaciones)
				VALUES (cNumcte, cNumcteCoppel, cSucursal, dFecha_alta, cApell_paterno, cApell_materno, cNombre1, cNombre2, dFecha_nac, cEstado_civil, cSexo, cRfc, cGrupo, cSubgrupo,
				 cCalle, cColonia, cEstado, cCiudad, cMunicipio, cCod_postal, cNumeroextcalle, cNumerointcalle, cDepartamento, smManzana, smAndador, smEtapa, smLote, smEdificio, smEntrada, cObservaciones);
			END IF;
		END FOREACH;

		DROP TABLE IF EXISTS tmp_clientes_unica;
		
		-- OBTENEMOS LOS TELEFONOS DE LOS CLIENTES
		SELECT      telefono.numcte,
					CASE WHEN telefono.tipo_tel = "01" THEN telefono.telefono ELSE '' END  AS casa,
					CASE WHEN telefono.tipo_tel = "02" THEN telefono.telefono ELSE '' END  AS celular,
					CASE WHEN telefono.tipo_tel = "03" THEN telefono.telefono ELSE '' END  AS oficina,
					CASE WHEN telefono.tipo_tel = "04" THEN telefono.telefono ELSE '' END  AS otro,
					extension,
					CASE WHEN telefono.carrier <> "0"  THEN (SELECT nombre_carrier
															 FROM   bdinteg:"informix".si_carriers
															 WHERE  cve_carrier = telefono.carrier ) ELSE '' END carrier,
					status_tel,
					cofetel,
					movil_fijo
		FROM        bdinteg:"informix".si_telefonos_actual telefono,
					bdinteg:"informix".si_carriers carrier
		WHERE       telefono.numcte IN (SELECT act.numcte FROM bdisac:"informix".tmp_actualiza_datos act)
		AND         telefono.status_tel = 'A'
		GROUP BY    telefono.numcte, casa, celular, oficina, otro, extension, carrier, status_tel, cofetel,movil_fijo
		INTO TEMP tmp_telefonos_unica  WITH NO LOG;
		
		FOREACH
			SELECT  numcte, casa, celular, oficina, otro, extension, carrier, status_tel, cofetel,movil_fijo 
			INTO    cNumcte, cCasa, cCelular, cOficina, cOtro, cExtension, cCarrier, cStatus_tel, cCofetel, cMovil_fijo
			FROM    bdisac:tmp_telefonos_unica
			
			IF EXISTS (SELECT 1 FROM bdiunica@stag_ids1170:"informix".uni_telefonos WHERE numcte = cNumcte) THEN
				UPDATE bdiunica@stag_ids1170:"informix".uni_telefonos
				SET casa = cCasa, celular = cCelular, oficina = cOficina, otro = cOtro, extension = cExtension, carrier = cCarrier, status_tel = cStatus_tel, cofetel = cCofetel,movil_fijo = cMovil_fijo
				WHERE numcte = cNumcte;	
			ELSE
				INSERT INTO bdiunica@stag_ids1170:"informix".uni_telefonos(numcte, casa, celular, oficina, otro, extension, carrier, status_tel, cofetel,movil_fijo)
				VALUES (cNumcte, cCasa, cCelular, cOficina, cOtro, cExtension, cCarrier, cStatus_tel, cCofetel, cMovil_fijo);
			END IF;
		END FOREACH;

		DROP TABLE IF EXISTS tmp_telefonos_unica;		
		
		-- OBTENEMOS LOS CORREOS DE LOS CLIENTES		
		SELECT	act.numcte, co.correo_elec, co.tipo_correo, co.status_correo, co.valido 
		FROM 	bdisac:"informix".tmp_actualiza_datos act,
				bdinteg:"informix".si_correos co
		WHERE	co.numcte = act.numcte
		INTO TEMP tmp_correos_unica  WITH NO LOG;
		
		FOREACH
			SELECT	numcte, correo_elec, tipo_correo, status_correo, valido 
			INTO	cNumcte, cCorreo_elec, cTipo_correo, cStatus_correo, cValido
			FROM	bdinteg:tmp_correos_unica
			
			IF EXISTS (SELECT numcte FROM bdiunica@stag_ids1170:"informix".uni_correo WHERE numcte = cNumcte) THEN
				UPDATE bdiunica@stag_ids1170:"informix".uni_correo
				SET correo_elec = cCorreo_elec, tipo_correo = cTipo_correo, status_correo = cStatus_correo, valido = cValido
				WHERE numcte = cNumcte;					
			ELSE
				INSERT INTO bdiunica@stag_ids1170:"informix".uni_correo (numcte,correo_elec,tipo_correo,status_correo,valido)
				VALUES (cNumcte, cCorreo_elec, cTipo_correo, cStatus_correo, cValido);
			END IF;
		END FOREACH;

		DROP TABLE IF EXISTS tmp_correos_unica;		
		TRUNCATE TABLE bdisac:"informix".tmp_actualiza_datos;
		-- TERMINA DE ACTUALIZAR SOLICITUDES - CLIENTE
	
	
	
		-- ACTUALIZAMOS CREDITOS - CLIENTE
		-- IDENTIFICAMOS LOS CREDITOS CON DATOS FALTANTES
		INSERT INTO bdisac:"informix".tmp_actualiza_datos(numcte, num_credito)
		SELECT      u.numcte,
					u.num_credito
		FROM        (
						SELECT  DISTINCT
								p.numcte,
								p.num_credito,
								p.nombre1
						FROM    (
										SELECT  DISTINCT
												h.numcte,
												h.num_credito,
												cl.nombre1,
												cl.nombre2,
												cl.apell_paterno,
												cl.apell_materno
										FROM    (
													SELECT  DISTINCT
															e.numcte,
															a.num_credito
													FROM    (
																SELECT  DISTINCT cr.num_credito AS num_credito
																FROM    bdiunica@stag_ids1170:"informix".uni_ind_credito cr
																WHERE   cr.num_credito NOT BETWEEN '780000000001' AND '790000000000'
															) a
													LEFT JOIN bdiunica@stag_ids1170:"informix".uni_credito e ON (e.num_credito = a.num_credito)
												) h
										LEFT JOIN bdiunica@stag_ids1170:"informix".uni_cliente cl ON (cl.numcte = h.numcte)
								 ) p
						WHERE   p.nombre1 IS NULL
				   )u;
		
		
		FOREACH 
			SELECT  b.numcte, a.num_credito
			INTO    cNumCte, cNumcredito
			FROM    bdisac:"informix".tmp_actualiza_datos a,
					bdicred:"informix".sd_maecred b
			WHERE   b.num_credito = a.num_credito
			
			IF EXISTS (SELECT num_credito FROM bdisac:"informix".tmp_actualiza_datos WHERE num_credito = cNumCredito) THEN
				UPDATE  bdisac:"informix".tmp_actualiza_datos
				SET     numcte = cNumCte
				WHERE   num_credito = cNumCredito;
			END IF;
		END FOREACH;

		-- OBTNENEMOS LOS DATOS DE LOS CLIENTES
		SELECT  act.numcte,cliente.numcte_ref as num_cte_coppel,cliente.sucursal,cliente.fecha_alta,cliente.apell_paterno,cliente.apell_materno,
				cliente.nombre1,cliente.nombre2,ctepf.fecha_nac,ctepf.estado_civil,ctepf.sexo,cliente.rfc,cliente.grupo,cliente.subgrupo,
				direccion.calle,direccion.colonia,direccion.estado,direccion.ciudad,direccion.municipio,direccion.cod_postal,direccion.numeroextcalle,direccion.numerointcalle,
				direccion.departamento,direccion.manzana,direccion.andador,direccion.etapa,direccion.lote,direccion.edificio,direccion.entrada,direccion.observaciones
		FROM    bdisac:"informix".tmp_actualiza_datos act, bdinteg:"informix".si_cliente cliente, bdinteg:"informix".si_ctepf ctepf, bdinteg:"informix".si_direcciones_actual direccion
		WHERE   act.numcte = cliente.numcte
		AND     cliente.numcte = ctepf.numcte
		AND     cliente.numcte = direccion.numcte
		AND     tipo_cliente = '1'
		AND     direccion.tipo_dir = '1'		
		INTO TEMP tmp_clientes_unica WITH NO LOG;
		
		FOREACH 
			SELECT numcte, num_cte_coppel,sucursal,fecha_alta,apell_paterno,apell_materno, nombre1,nombre2,fecha_nac,estado_civil,sexo,rfc,grupo,subgrupo,
				   calle,colonia,estado,ciudad,municipio,cod_postal,numeroextcalle,numerointcalle, departamento,manzana,andador,etapa,lote,edificio,entrada,observaciones
			INTO cNumcte, cNumcteCoppel, cSucursal, dFecha_alta, cApell_paterno, cApell_materno, cNombre1, cNombre2, dFecha_nac, cEstado_civil, cSexo, cRfc, cGrupo, cSubgrupo,
				 cCalle, cColonia, cEstado, cCiudad, cMunicipio, cCod_postal, cNumeroextcalle, cNumerointcalle, cDepartamento, smManzana, smAndador, smEtapa, smLote, smEdificio, smEntrada, cObservaciones
			FROM bdisac:tmp_clientes_unica
			
			IF EXISTS (SELECT numcte FROM bdiunica@stag_ids1170:"informix".uni_cliente WHERE numcte = cNumcte) THEN
				UPDATE bdiunica@stag_ids1170:"informix".uni_cliente
				SET num_cte_coppel = cNumcteCoppel, sucursal = cSucursal, fecha_alta = dFecha_alta, apell_paterno = cApell_paterno, apell_materno = cApell_materno, nombre1 = cNombre1, nombre2 = cNombre2, fecha_nac = dFecha_nac, estado_civil = cEstado_civil, sexo = cSexo, rfc = cRfc, grupo = cGrupo, subgrupo = cSubgrupo,
					calle = cCalle, colonia = cColonia, estado = cEstado, ciudad = cCiudad, municipio = cMunicipio, cod_postal = cCod_postal, numeroextcalle = cNumeroextcalle, numerointcalle = cNumerointcalle, departamento = cDepartamento,manzana = smManzana, andador = smAndador, etapa = smEtapa, lote = smLote, edificio = smEdificio, entrada = smEntrada, observaciones = cObservaciones
				WHERE numcte = cNumcte;
			ELSE
				INSERT INTO bdiunica@stag_ids1170:"informix".uni_cliente (numcte, num_cte_coppel,sucursal,fecha_alta,apell_paterno,apell_materno, nombre1,nombre2,fecha_nac,estado_civil,sexo,rfc,grupo,subgrupo,
				   calle,colonia,estado,ciudad,municipio,cod_postal,numeroextcalle,numerointcalle, departamento,manzana,andador,etapa,lote,edificio,entrada,observaciones)
				VALUES (cNumcte, cNumcteCoppel, cSucursal, dFecha_alta, cApell_paterno, cApell_materno, cNombre1, cNombre2, dFecha_nac, cEstado_civil, cSexo, cRfc, cGrupo, cSubgrupo,
				 cCalle, cColonia, cEstado, cCiudad, cMunicipio, cCod_postal, cNumeroextcalle, cNumerointcalle, cDepartamento, smManzana, smAndador, smEtapa, smLote, smEdificio, smEntrada, cObservaciones);
			END IF;
		END FOREACH;
		
		DROP TABLE IF EXISTS tmp_clientes_unica;


		-- OBTENEMOS LOS TELEFONOS DE LOS CLIENTES
		SELECT      telefono.numcte,
					CASE WHEN telefono.tipo_tel = "01" THEN telefono.telefono ELSE '' END  AS casa,
					CASE WHEN telefono.tipo_tel = "02" THEN telefono.telefono ELSE '' END  AS celular,
					CASE WHEN telefono.tipo_tel = "03" THEN telefono.telefono ELSE '' END  AS oficina,
					CASE WHEN telefono.tipo_tel = "04" THEN telefono.telefono ELSE '' END  AS otro,
					extension,
					CASE WHEN telefono.carrier <> "0"  THEN (SELECT nombre_carrier
															 FROM   bdinteg:"informix".si_carriers
															 WHERE  cve_carrier = telefono.carrier ) ELSE '' END carrier,
					status_tel,
					cofetel,
					movil_fijo
		FROM        bdinteg:"informix".si_telefonos_actual telefono,
					bdinteg:"informix".si_carriers carrier
		WHERE       telefono.numcte IN (SELECT act.numcte FROM bdisac:"informix".tmp_actualiza_datos act)
		AND         telefono.status_tel = 'A'
		GROUP BY    telefono.numcte, casa, celular, oficina, otro, extension, carrier, status_tel, cofetel,movil_fijo
		INTO TEMP tmp_telefonos_unica  WITH NO LOG;
		
		FOREACH
			SELECT  numcte, casa, celular, oficina, otro, extension, carrier, status_tel, cofetel,movil_fijo 
			INTO    cNumcte, cCasa, cCelular, cOficina, cOtro, cExtension, cCarrier, cStatus_tel, cCofetel, cMovil_fijo
			FROM    bdisac:tmp_telefonos_unica
			
			IF EXISTS (SELECT 1 FROM bdiunica@stag_ids1170:"informix".uni_telefonos WHERE numcte = cNumcte) THEN
				UPDATE bdiunica@stag_ids1170:"informix".uni_telefonos
				SET casa = cCasa, celular = cCelular, oficina = cOficina, otro = cOtro, extension = cExtension, carrier = cCarrier, status_tel = cStatus_tel, cofetel = cCofetel,movil_fijo = cMovil_fijo
				WHERE numcte = cNumcte;	
			ELSE
				INSERT INTO bdiunica@stag_ids1170:"informix".uni_telefonos(numcte, casa, celular, oficina, otro, extension, carrier, status_tel, cofetel,movil_fijo)
				VALUES (cNumcte, cCasa, cCelular, cOficina, cOtro, cExtension, cCarrier, cStatus_tel, cCofetel, cMovil_fijo);
			END IF;
		END FOREACH;

		DROP TABLE IF EXISTS tmp_telefonos_unica;

		
		-- OBTENEMOS LOS CORREOS DE LOS CLIENTES		
		SELECT	act.numcte, co.correo_elec, co.tipo_correo, co.status_correo, co.valido 
		FROM 	bdisac:"informix".tmp_actualiza_datos act,
				bdinteg:"informix".si_correos co
		WHERE	co.numcte = act.numcte
		INTO TEMP tmp_correos_unica  WITH NO LOG;
		
		FOREACH
			SELECT	numcte, correo_elec, tipo_correo, status_correo, valido 
			INTO	cNumcte, cCorreo_elec, cTipo_correo, cStatus_correo, cValido
			FROM	bdinteg:tmp_correos_unica
			
			IF EXISTS (SELECT numcte FROM bdiunica@stag_ids1170:"informix".uni_correo WHERE numcte = cNumcte) THEN
				UPDATE bdiunica@stag_ids1170:"informix".uni_correo
				SET correo_elec = cCorreo_elec, tipo_correo = cTipo_correo, status_correo = cStatus_correo, valido = cValido
				WHERE numcte = cNumcte;					
			ELSE
				INSERT INTO bdiunica@stag_ids1170:"informix".uni_correo (numcte,correo_elec,tipo_correo,status_correo,valido)
				VALUES (cNumcte, cCorreo_elec, cTipo_correo, cStatus_correo, cValido);
			END IF;
		END FOREACH;

		DROP TABLE IF EXISTS tmp_correos_unica;

		
		-- ACTUALIZAMOS LOS CREDITOS DE LOS CLIENTES
		SELECT   act.numcte,act.num_credito,cred.num_producto,cred.sucursal,cred.status_cred,cred.fecha_apertura, monto_otorgado AS linea_credito,
				 (SELECT COUNT(tipo_tarjeta) FROM bdicred:"informix".sd_tarjeta 
				  WHERE  status_tar = 'A' AND tipo_tarjeta = 'A' 
				  AND    cred.num_credito = num_credito) AS no_tc_adi,
				 tc.secuencia, tc.num_tarjeta,tc.expiracion,tc.tipo_tarjeta,tc.status_tar
		FROM     bdisac:"informix".tmp_actualiza_datos act,
                 bdicred:"informix".sd_maecred cred,
				 bdicred:"informix".sd_tarjeta tc,
				 bdicred:"informix".sd_maesdos sdos
		WHERE    cred.numcte = act.numcte
        AND      cred.num_credito = act.num_credito
        AND      cred.num_credito = tc.num_credito
		AND      cred.num_credito = sdos.num_credito
		GROUP BY act.numcte,act.num_credito,cred.num_producto,cred.sucursal,cred.status_cred,cred.fecha_apertura,monto_otorgado,
				 no_tc_adi,tc.secuencia, tc.num_tarjeta,tc.expiracion,tc.tipo_tarjeta,tc.status_tar
		INTO TEMP tmp_creditos_unica  WITH NO LOG;
		 
		FOREACH
			SELECT  numcte, num_credito, num_producto, sucursal, status_cred, fecha_apertura, linea_credito, no_tc_adi, secuencia, num_tarjeta, expiracion, tipo_tarjeta, status_tar
			INTO	cNumCte, cNumCredito, cNumProducto, cSucursal, cStatusCred, dFechaApertura, dMontoOtorgado, dNoTcAdi, sSecuencia, cNumTarjeta, dExpiracion, cTipoTarjeta, cStatusTar
			FROM	bdisac:tmp_creditos_unica
			
			IF EXISTS (SELECT num_credito FROM bdiunica@stag_ids1170:"informix".uni_credito crd WHERE crd.numcte = cNumcte AND crd.num_credito = cNumCredito AND crd.num_producto = cNumProducto AND crd.num_tarjeta = cNumTarjeta) THEN
				UPDATE	bdiunica@stag_ids1170:"informix".uni_credito crd
				SET		crd.numcte = cNumCte, crd.num_credito = cNumCredito, crd.num_producto = cNumProducto, crd.sucursal = cSucursal,
						crd.status_cred = cStatusCred, crd.fecha_apertura = dFechaApertura, crd.linea_credito = dMontoOtorgado,
						crd.no_tc_adi = dNoTcAdi, crd.secuencia = sSecuencia, crd.num_tarjeta = cNumTarjeta, crd.expiracion = dExpiracion,
						crd.tipo_tarjeta = cTipoTarjeta, crd.status_tar = cStatusTar
				WHERE	crd.numcte = cNumcte AND crd.num_credito = cNumCredito AND crd.num_producto = cNumProducto AND crd.num_tarjeta = cNumTarjeta;
			ELSE
				INSERT INTO bdiunica@stag_ids1170:"informix".uni_credito (numcte, num_credito, num_producto, sucursal, status_cred, fecha_apertura, linea_credito, no_tc_adi, secuencia, num_tarjeta, expiracion, tipo_tarjeta, status_tar)
				VALUES		(cNumCte, cNumCredito, cNumProducto, cSucursal, cStatusCred, dFechaApertura, dMontoOtorgado, dNoTcAdi, sSecuencia, cNumTarjeta, dExpiracion, cTipoTarjeta, cStatusTar);
			END IF;
		END FOREACH;

		DROP TABLE IF EXISTS tmp_creditos_unica;
		TRUNCATE TABLE bdisac:"informix".tmp_actualiza_datos;
		-- TERMINA DE ACTUALIZAR CREDITOS - CLIENTE
		
		LET cVarDataErr = 'EJECUCION EXITOSA DAT';

		SELECT  DBINFO('utc_to_datetime',sh_curtime)
		INTO    dFechaFin
		FROM    sysmaster:"informix".sysshmvals;

		--INSERTAMOS REGISTRO DE EJECUCION DEL PROCESO
		INSERT INTO bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso (nombre_proceso, fecha_inicio, fecha_fin, status_ejecucion, observacion, fecha_proceso, tipo_proceso)
		VALUES (cProceso, dFechaIni, dFechaFin, iEstatus, cVarDataErr, pFechaInicio, pTipoProceso);
	END IF;

	RETURN cProceso, cCodRet, cVarDataErr;

	END;
END PROCEDURE;