CREATE PROCEDURE "informix".sp_dinya_insdatoenv
	(pNo_Control CHAR(12),
	 pUsua_envio CHAR(8),
	 pSuc_origen CHAR(4),
	 pImporte_total MONEY(16,2),
	 pImporte_pago MONEY(16,2),
	 pImporte_envio MONEY(16,2),
	 pComision MONEY(16,2),
	 pIva MONEY(16,2),
	 pNum_ident CHAR(25),
	 pNombre1Rem CHAR(26),
	 pNombre2Rem CHAR(26),
	 pApellido1Rem CHAR(26),
	 pApellido2Rem CHAR(26),
	 pTelefono_rem CHAR(20),
	 pDirec_rem	CHAR(80),
	 pNombre1Ben CHAR(26),
	 pNombre2Ben CHAR(26),
	 pApellido1Ben CHAR(26),
	 pApellido2Ben CHAR(26),
	 pTelefono_ben CHAR(20),
	 pDirec_ben CHAR(80),
	 pMensaje CHAR(100),
	 pForma_pago CHAR(1),
	 pCuentaCargo CHAR(20),
	 pEfectivo MONEY(16,2),
	 pCargoCta MONEY(16,2),
	 pFolioSuc CHAR(16),
	 pTransacc_suc CHAR(4)
	 )
RETURNING  CHAR(5),CHAR(5);

DEFINE cCodRet 			CHAR(5);
DEFINE cFijo			CHAR(5);
DEFINE iSqlErr			INTEGER;
DEFINE dFecha_envio		DATE;
DEFINE iSam_error		INTEGER;
DEFINE cMensaje			CHAR(50);
DEFINE mSdo_disponible  MONEY(16,2);
DEFINE vTipoProducto	INTEGER;

LET cCodRet 			= '00000';
LET cFijo				= '00000';
LET iSqlErr				= 0;
LET dFecha_envio		= '';
LET iSam_error			= 0;
LET cMensaje			= '';
LET mSdo_disponible 	= 0;
LET vTipoProducto		= 0;


BEGIN

	ON EXCEPTION SET iSqlErr,iSam_error,cMensaje
		IF iSqlErr != 0 THEN
			LET cCodRet= iSqlErr;
			INSERT INTO bdisac:"informix".sac_mensajeerror (sql_error, iSam_error, descripcion, origen_error, fecha, fecha_insert)
			VALUES (iSqlErr,iSam_error,cMensaje,'sp_DinYa_InsDatoEnv',dFecha_envio,CURRENT );
			RETURN cFijo,cCodRet;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/respaldosbd/felipe/sp_DinYa_InsDatoEnv.out";
	--TRACE ON;

	--SET ISOLATION TO CURSOR STABILITY;
    --SET ISOLATION TO COMMITTED READ LAST COMMITTED; 
    --SET ISOLATION COMMITTED READ;
    SET ISOLATION DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF pNo_Control = '' OR  pUsua_envio = '' OR  pSuc_origen = '' OR  pImporte_total = '' OR  pImporte_total <= '0.00' OR
	pImporte_pago = '' OR pImporte_pago = '0.00' OR pImporte_envio = '' OR pImporte_envio = '0.00' OR pComision = '' OR
	pIva = '' OR  pNombre1Rem = '' OR  pApellido1Rem = '' OR pTelefono_rem = '' OR  pNombre1Ben = '' OR pApellido1Ben = '' 
	OR  pTelefono_ben = '' OR pForma_pago = ''  OR pFolioSuc = '' OR pTransacc_suc = '' THEN

		LET cCodRet = '00001';
		RETURN cFijo,cCodRet;
	END IF;
  
	IF pCargoCta IS NULL OR pCargoCta = '' THEN
		LET pCargoCta = '0.00';
	END IF;

	SELECT fecha_hoy INTO dFecha_envio
	FROM bdisac:"informix".sac_fechas;


--BUSCA TIPOS DE PRODUCTO INVALIDOS PARA ENVIO DE DINERO---- Modifica: Noe Medina Fecha:05-06-2017-----------------------------
	LET vTipoProducto = (select producto from bdicheq:sc_maechq where cuenta=trim(pCuentaCargo));

	IF (select count(*) from bdisac:"informix".sac_param where cod_param='120' and valor like '%' || vTipoProducto || '%') > 0 THEN
		LET cCodRet = '00000';
		LET cFijo	= '00151';
		RETURN cFijo,cCodRet;
	END IF;
-------------------------------------------------------------------------------------------------------------------------------

	IF EXISTS (SELECT {+INDEX (bdisac:"informix".sac_enviosdineroya idxsac_envdinya13_1)} 1 FROM bdisac:"informix".sac_enviosdineroya WHERE no_control = pNo_Control and estatus is not null) THEN
		LET cCodRet = '00002';
		RETURN cFijo,cCodRet;
	END IF;
	
	INSERT INTO bdisac:"informix".sac_enviosdineroya
	(no_control, fecha_envio, estatus, hora_envio, usua_envio, suc_origen, importe_total,
	importe_pago, importe_envio, comision, iva,identificacion, num_ident,pri_nom_rem,
	seg_nom_rem, apell_pat_rem, apell_mat_rem, telefono_rem, direc_rem, pri_nom_ben,
	seg_nom_ben, apell_pat_ben, apell_mat_ben, telefono_ben, direc_ben, mensaje)
	VALUES
	(pNo_Control,dFecha_envio,'00',CURRENT HOUR TO SECOND,pUsua_envio,pSuc_origen,
	pImporte_total,pImporte_pago,pImporte_envio,pComision,pIva,'00',pNum_ident,
	pNombre1Rem,pNombre2Rem,pApellido1Rem,pApellido2Rem,pTelefono_rem,pDirec_rem,pNombre1Ben,
	pNombre2Ben,pApellido1Ben,pApellido2Ben, pTelefono_ben,pDirec_ben,pMensaje);
		
	CALL bdisac:"informix".sp_grabapagoservicio (pSuc_origen,'07','001', LPAD(TRIM(pNo_Control),12,'0'),SUBSTR(LPAD(TRIM(pNo_Control),12,'0'),12,1),
	pForma_pago, pImporte_pago,'0.00','0.00',pComision,pIva,pCuentaCargo,pUsua_envio,pFolioSuc, pTransacc_suc,dFecha_envio)
	RETURNING cCodRet;

	IF cCodRet = 0 THEN
		
		IF pForma_pago = '3' AND pEfectivo = 0  THEN
			LET cCodRet = '00022';
		ELIF pForma_pago = '2' OR pForma_pago = '3' THEN
			SELECT sdo_actual - (sdo_cong + sdo_retenido) AS sdo_disponible
			INTO mSdo_disponible
			FROM bdicheq:"informix".sc_maechq WHERE cuenta = pCuentaCargo;
					
			IF mSdo_disponible < pCargoCta THEN
				LET cCodRet = '00032';
			END IF;
		END IF;
			
		IF cCodRet = 0 THEN
			CALL bdisac:"informix".sp_dinya_InsertaEnvios (pNo_Control,pEfectivo,pCargoCta,pCuentaCargo,pSuc_origen,pFolioSuc)
			RETURNING cCodRet,pFolioSuc;
		END IF;
				

		IF cCodRet <> 0 THEN
			DELETE {+INDEX (bdisac:"informix".sac_enviosdineroya idxsac_envdinya13_1)} FROM bdisac:"informix".sac_enviosdineroya 
			WHERE no_control = pNo_Control and estatus is not null;
				
			DELETE FROM bdisac:"informix".sac_movimientos 
			WHERE id_sucursal = pSuc_origen
			AND numcategoria = '07'
			AND numconvenio = '001'
			AND referencia1 = pNo_Control;
		ELSE
			UPDATE {+INDEX (bdisac:"informix".sac_enviosdineroya idxsac_envdinya13_1)} bdisac:"informix".sac_enviosdineroya 
			SET estatus = '01'
			WHERE no_control = pNo_Control and estatus is not null;
		END IF;
	END IF;

	RETURN cFijo,cCodRet;
END
END PROCEDURE
Document
'DESCRIPCION: Consulta los envios que estan pendientes de realizar su pago',
'AUTOR: Antonio Bastidas',
'FECHA: 03 de Noviembre de 2009',
'BD: BDISAC',
'VERSION: 20091204.1225',
'DESCRIPCION: Se envía el parámetro de dFecha_envio al proceso de sp_grabapagoservicio',
'AUTOR: Antonio Bastidas',
'FECHA: 08 de abril de 2010',
'BD: BDISAC',
'VERSION: 20100804.1728',
'DESCRIPCION: Se valida que el efectivo no vaya en 0 cuando el tipo de pago sea mixto',
'y que cuando sea cargo a cuenta o mixto la cuenta cargo tenga saldo suficiente para realizar el cargo',
'AUTOR: Dulce Ramírez',
'FECHA: 12 de mayo de 2010',
'BD: BDISAC',
'VERSION: 20100512.1154',
'DESCRIPCION: Se retira la direccion del beneficiario como dato obligatorio,se agregan reglas de informix ',
'AUTOR: Felipe Urias',
'FECHA: 19 de octubre de 2011',
'BD: BDISAC',
'VERSION: 20111119.1230';

CREATE PROCEDURE "informix".sp_consulta_datoscteremesa( pNumCte	CHAR(20) )
	RETURNING CHAR(5)	AS cCodRet,
						Char(40)	AS cPrimerNombre,
						Char(40)	AS cSegundoNombre,
						Char(40)	AS cApellidoPaterno,
						Char(40)	AS cApellidoMaterno,
						Date	 	AS dFechaNacimiento,
						Char(3) 	AS cIdNacionalidad,
						Char(3) 	AS cIdPaisNacimiento,
						Char(2) 	AS cIdEstadoNacimiento,
						Char(1) 	AS cSexo,
						Char(2) 	AS cTipoIdentificacion,
						Char(30) 	AS cNoIdentificacion,
						Char(3) 	AS cIdPaisEmision,
						Date	 	AS dFechaVencimiento,
						Char(3) 	AS cIdOcupacion,
						Char(2) 	AS cTipoCte,
						Char(2) 	AS cIdEstado,
						Char(3) 	AS cIdCiudad,
						Char(5) 	AS cIdMunicipio,
						integer 	AS iNumColonia,
						integer 	AS iNumCalle,
						integer 	AS iNumeroCiudad,
						Char(10) 	AS cNumExterior,
						Char(10) 	AS cNumInterior,
						Char(10) 	AS cDepartamento,
						Char(5) 	AS cCodPostal,
						Char(13) 	AS cTelefono,
						Char(13) 	AS cTelefonoCelular,
						Char(3) 	AS cIdPaisDomExt,
						Char(100) 	AS cCorreoElectronico,
						integer 	AS iClavePuesto,
						integer 	AS iClaveSubPuesto;

		--Declaracion de variables
		DEFINE cCodRet 		    		CHAR(5);
		DEFINE iSqlErr					INTEGER;
		DEFINE cTipoCliente				CHAR(1);
		DEFINE cNumCte					CHAR(20);
		
		DEFINE cFecha 					DATE;
		DEFINE cPrimerNombre			Char(40);		
        DEFINE cSegundoNombre           Char(40);
		DEFINE cApellidoPaterno         Char(40);
		DEFINE cApellidoMaterno         Char(40);
		DEFINE dFechaNacimiento     	Date;
		DEFINE cIdNacionalidad          Char(3);
		DEFINE cIdPaisNacimiento		Char(3);
		
		DEFINE cIdEstadoNacimiento      Char(2);
		DEFINE cSexo					Char(1);
		DEFINE cTipoIdentificacion      Char(2);
		DEFINE cNoIdentificacion		Char(30);
		DEFINE cIdPaisEmision			Char(3);
		DEFINE dFechaVencimiento		Date;
		DEFINE cIdOcupacion             Char(3);
		DEFINE cTipoCte					Char(2);
		DEFINE cIdEstado				Char(2);
		DEFINE cIdCiudad				Char(3);
		DEFINE cIdMunicipio				Char(5);
		DEFINE iNumColonia				integer;
		DEFINE iNumCalle				integer;
		DEFINE iNumCiudad				integer;
		DEFINE cNumExterior             Char(10);
		DEFINE cNumInterior             Char(10);
		DEFINE cDepartamento			Char(10);
		DEFINE cCodPostal				Char(5);
		DEFINE cTelefono				Char(13);
		DEFINE cTelefonoCelular         Char(13);
		DEFINE cIdPaisDomExt			Char(3);
		DEFINE cCorreoElectronico       Char(100);
		DEFINE iClavePuesto				integer;
		DEFINE iClaveSubPuesto          integer;
        DEFINE cSec_ingreso             Char(5);
		
		--Inicializacion
		LET cCodRet 				= '00002'; --Codigo 00000 = Exitoso; 00001 = Cliente titular 00002 = No es titular o no existe
		LET iSqlErr					= 0;
		LET cTipoCliente			= '';
		LET dFechaNacimiento		= '01-01-1900';
		LET dFechaVencimiento		= '01-01-1900';
		
		LET cPrimerNombre			= '';
		LET cSegundoNombre			= '';
		LET cApellidoPaterno		= '';
		LET cApellidoMaterno		= '';
		
		LET cIdNacionalidad			= '';
		LET cIdPaisNacimiento		= '';
		LET cIdEstadoNacimiento 	= '';
		LET cSexo					= '';
		LET cTipoIdentificacion 	= '';
		LET cNoIdentificacion		= '';
		LET cIdPaisEmision			= '';
		
		LET cIdOcupacion			= '';
		LET cTipoCte				= '';
		LET cIdEstado				= '';
		LET cIdCiudad				= '';
		LET cIdMunicipio			= '';
		LET iNumColonia				= 0;
		LET iNumCalle				= 0;
		LET iNumCiudad				= 0;
		LET cNumExterior			= '';
		LET cNumInterior			= '';
		LET cDepartamento			= '';
		LET cCodPostal				= '';
		LET cTelefono				= '';
		LET cTelefonoCelular		= '';
		LET cIdPaisDomExt			= '';
		LET cCorreoElectronico		= '';
		
		LET iClavePuesto			= 0;
		LET iClaveSubPuesto			= 0;

        LET cSec_ingreso            = '';

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cPrimerNombre, cSegundoNombre, cApellidoPaterno,  cApellidoMaterno, dFechaNacimiento, cIdNacionalidad, cIdPaisNacimiento, cIdEstadoNacimiento, 
			              cSexo, cTipoIdentificacion, cNoIdentificacion, cIdPaisEmision, dFechaVencimiento, cIdOcupacion, cTipoCte, cIdEstado, cIdCiudad, cIdMunicipio, iNumColonia, 
						  iNumCalle, iNumCiudad, cNumExterior, cNumInterior, cDepartamento, cCodPostal, cTelefono, cTelefonoCelular, cIdPaisDomExt, cCorreoElectronico, iClavePuesto, iClaveSubPuesto;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/informix/EPG/sp_consulta_datoscteremesa.out';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF NVL(pNumCte, '') = '' THEN
		LET cCodRet = '00002';
		--DATOS VACIOS, ERROR.
		LET iClavePuesto=5;
		LET iClaveSubPuesto=2;
		RETURN cCodRet, cPrimerNombre, cSegundoNombre, cApellidoPaterno,  cApellidoMaterno, dFechaNacimiento, cIdNacionalidad, cIdPaisNacimiento, cIdEstadoNacimiento, 
			   cSexo, cTipoIdentificacion, cNoIdentificacion, cIdPaisEmision, dFechaVencimiento, cIdOcupacion, cTipoCte, cIdEstado, cIdCiudad, cIdMunicipio, iNumColonia, 
			   iNumCalle, iNumCiudad, cNumExterior, cNumInterior, cDepartamento, cCodPostal, cTelefono, cTelefonoCelular, cIdPaisDomExt, cCorreoElectronico, iClavePuesto, iClaveSubPuesto;
	ELSE

		SELECT	nombre1, nombre2, apell_paterno, apell_materno
		INTO	cPrimerNombre, cSegundoNombre, cApellidoPaterno, cApellidoMaterno
		FROM	bdinteg: "informix".si_cliente WHERE numcte = pNumCte;
		
		SELECT	fecha_nac, nacionalidad, sexo, codidentifi, numidentifi, profesion, lugar_nac, id_pais
		INTO	dFechaNacimiento, cIdNacionalidad, cSexo, cTipoIdentificacion, cNoIdentificacion, cIdOcupacion, cIdEstadoNacimiento, cIdPaisNacimiento
		FROM	bdinteg: "informix".si_ctepf WHERE numcte = pNumCte;
		
		SELECT	fecha_vencimiento, tipo_cte, pais_emision
		INTO	dFechaVencimiento, cTipoCte, cIdPaisEmision
		FROM	bdisac: "informix".sac_cte_remesas WHERE numcte = pNumCte;
		
		SELECT	telefono
		INTO	cTelefono
		FROM	bdinteg: "informix".si_telefonos WHERE numcte = pNumCte AND tipo_tel=1 AND status_tel='A'
         AND secuencia  = (SELECT MAX(secuencia) FROM bdinteg: "informix".si_telefonos 
                            WHERE tipo_tel  = 1 AND status_tel='A'
                              AND numcte = pNumCte);
        
        SELECT	telefono
		INTO	cTelefonoCelular
		FROM	bdinteg: "informix".si_telefonos WHERE numcte = pNumCte AND tipo_tel=2 AND status_tel='A'
         AND secuencia  = (SELECT MAX(secuencia) FROM bdinteg: "informix".si_telefonos 
                            WHERE tipo_tel  = 2 AND status_tel='A'
                              AND numcte = pNumCte);
		
		SELECT	correo_elec
		  INTO	cCorreoElectronico
          FROM bdinteg:"informix".si_correos WHERE numcte = pNumCte and status_correo = 'A' 
           AND secuencia = (SELECT max(secuencia) FROM  bdinteg: "informix".si_correos 
                             WHERE numcte = pNumCte and status_correo = 'A');
		
		SELECT	estado, ciudad, municipio, numerocolonia, numerocalle, numerociudad, numeroextcalle, numerointcalle, departamento, cod_postal, pais
		  INTO	cIdEstado, cIdCiudad, cIdMunicipio, iNumColonia, iNumCalle, iNumCiudad, cNumExterior, cNumInterior, cDepartamento,cCodPostal, cIdPaisDomExt
		  FROM	bdinteg: "informix".si_direcciones_actual WHERE tipo_dir = 1 AND numcte = pNumCte;
		
        IF cIdEstado = '9' AND cIdMunicipio = '' THEN
            LET cIdMunicipio = cIdCiudad;
        END IF;

        IF cIdEstado = '09' AND cIdMunicipio = '' THEN
            LET cIdMunicipio = cIdCiudad;  
        END IF;

        --SELECT claveopcionpuesto, clavesubopcionpuesto
        -- INTO iClavePuesto,iClaveSubPuesto
        --  FROM bdinteg: "informix".si_ingresos 
        -- WHERE numcte = pNumCte  
        --   AND sec_ingreso = (SELECT MAX(sec_ingreso) FROM  bdinteg: "informix".si_ingresos 
        --                       WHERE numcte = pNumCte);
		
		LET cCodRet = '00000';
		LET iClavePuesto=7;
		LET iClaveSubPuesto=99;
	END IF;
    

	RETURN cCodRet, cPrimerNombre, cSegundoNombre, cApellidoPaterno,  cApellidoMaterno, dFechaNacimiento, cIdNacionalidad, cIdPaisNacimiento, cIdEstadoNacimiento, 
				  cSexo, cTipoIdentificacion, cNoIdentificacion, cIdPaisEmision, dFechaVencimiento, cIdOcupacion, cTipoCte, cIdEstado, cIdCiudad, cIdMunicipio, iNumColonia, 
				  iNumCalle, iNumCiudad, cNumExterior, cNumInterior, cDepartamento, cCodPostal, cTelefono, cTelefonoCelular, cIdPaisDomExt, cCorreoElectronico, iClavePuesto, iClaveSubPuesto;
				  
END
END PROCEDURE
DOCUMENT
'DescripciÃÆÃÆÃâÃÂ³n	: Se inserta campo numcte para utilizar en remesas',
'Autor			: Geovani Garcia Ochoa',
'FECHA			: 28/02/2017',
'BD				: bdisac',
'FOLIO		: 198 - RQM 10 784 B ASE DE DATOS PARA EL ALTA DE USUARIOS DE REMESAS',
'-------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_confpagoservicio_hs (cSucursal CHAR (4), cCategoria CHAR (2), cConvenio CHAR(5), cReferencia1 CHAR (40), cReferencia2 CHAR(40), cReferencia3 CHAR(40), cReferencia4 CHAR(40), cFolio_suc CHAR (16))

    RETURNING
    CHAR(5), CHAR(200);

    -- Definicion de Variables
    DEFINE cCodRet      CHAR(5);
    DEFINE iSql_err     INTEGER;
	DEFINE iIsamErr	    INTEGER;
	DEFINE cDescripcion CHAR (200);
	DEFINE vcadena_ent  CHAR (100);
    DEFINE scont        INT8; 
    DEFINE scont2       INT8; 
    DEFINE wBegin       CHAR(1);
	DEFINE vCodRet      CHAR(5);
	DEFINE vCodRetInt	CHAR(5);
	DEFINE vRfc			CHAR(13);
	DeFINE cReferenciaC CHAR(40);
	
     LET scont	       = 0; 
     LET scont2	       = 0; 
     LET cCodRet       = "00000";
     LET iSql_err      = 0;
	 LET iIsamErr      = 0;
	 LET cDescripcion  = "ACTUALIZACION FLAG-SUCURSAL EXITOSA.";
	 LET vcadena_ent   = cSucursal||'|'||cCategoria||'|'||cConvenio||'|'||TRIM(cReferencia1)||'|'||TRIM(cReferencia2)||'|'||TRIM(cReferencia3)||'|'||TRIM(cReferencia4)||'|'||cFolio_suc;
	 LET vCodRet	   = '00000';
	 LET vCodRetInt	   = '00000';
	 LET vRfc 	       = '';

	--SET DEBUG FILE TO '/informix/JorgeRivas/evidencias/sp_confpagoservicio_hs.out';
	--TRACE ON;
	 

    BEGIN
        ON EXCEPTION SET iSql_err, iIsamErr, cDescripcion
           IF iSql_err <> 0 THEN
              LET cCodRet = iSql_err;

              ROLLBACK WORK;

              IF (wBegin = "S") THEN
                 BEGIN WORK;
              END IF;               

			   INSERT INTO "informix".sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)
				VALUES (cCodRet,iIsamErr,cDescripcion ||' '|| scont||'-'||scont2,'sp_confpagoservicio',today,CURRENT);

			   INSERT INTO "informix".sac_log_envios (proceso, folio_suc, importe, cod_ret, cadena_ent, fecha_insert, hora_insert)
						values ('sp_confpagoservicio', cFolio_suc, 0, cCodRet, vcadena_ent, CURRENT, CURRENT);	

               RETURN cCodRet, cDescripcion;

           END IF;
        END EXCEPTION;

       ON EXCEPTION IN (-535)
          LET wBegin = "S";
          ROLLBACK WORK;
          BEGIN WORK;
       END EXCEPTION WITH RESUME;
     SET ISOLATION COMMITTED READ;

		SET ISOLATION TO DIRTY READ;
	    SET LOCK MODE TO WAIT 3;

--	2014.01.07 FRG-i
	--SET ISOLATION TO DIRTY READ;
	--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
	SET LOCK MODE TO WAIT 5;

    LET wBegin = "N";

            IF cSucursal <> "" AND cCategoria <> "" AND cConvenio <> "" AND TRIM(cReferencia1) <> ""  AND cFolio_suc <> "" THEN

                BEGIN WORK;

					UPDATE "informix".sac_movimientos
					   SET  flag_confirmacion_sucursal = 1, referencia3 = cReferencia3, referencia4 = cReferencia4
					 WHERE id_sucursal = cSucursal
					   AND numcategoria = cCategoria
					   AND  numconvenio = cConvenio
					   AND referencia1 = TRIM(cReferencia1)
					   AND folio_suc = cFolio_suc;

					LET scont  = dbinfo("sqlca.sqlerrd2");
					LET scont2 = dbinfo("sqlca.sqlerrd1"); 


					IF(scont = 0) THEN
					   --ROLLBACK WORK;

						LET cCodRet = "00002";
						LET cDescripcion = "No existe registro en Tabla bdisac:sac_movimientos";

						INSERT INTO "informix".sac_log_envios (proceso, folio_suc, importe, cod_ret, cadena_ent, fecha_insert, hora_insert)
							VALUES ('sp_confpagoservicio', cFolio_suc, 0, cCodRet, vcadena_ent, CURRENT, CURRENT);

						INSERT INTO "informix".sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)
							VALUES (cCodRet,iIsamErr,scont||' - '||scont2,'sp_confpagoservicio - dbinfo',today,CURRENT);

					   IF (wBegin = "S") THEN
						  BEGIN WORK;
					   END IF;
					END IF;
					
					IF(cCodRet = "00000") THEN
						   
						LET scont  = dbinfo("sqlca.sqlerrd2");
						LET scont2 = dbinfo("sqlca.sqlerrd1"); 


						IF(scont = 0) THEN
						   --ROLLBACK WORK;

							LET cCodRet = "00002";
							LET cDescripcion = "No existe registro en Tabla bdicheq:sc_movdia";

							INSERT INTO "informix".sac_log_envios (proceso, folio_suc, importe, cod_ret, cadena_ent, fecha_insert, hora_insert)
								VALUES ('sp_confpagoservicio', cFolio_suc, 0, cCodRet, vcadena_ent, CURRENT, CURRENT);

							INSERT INTO "informix".sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)
								VALUES (cCodRet,iIsamErr,scont||' - '||scont2,'sp_confpagoservicio - dbinfo',today,CURRENT);

						   IF (wBegin = "S") THEN
							  BEGIN WORK;
						   END IF;
						END IF;
					END IF;
					
					EXECUTE PROCEDURE "informix".sp_tae_notifications(cFolio_suc) INTO vCodRetInt;

				   IF(cCodRet <> "00000") THEN
					  ROLLBACK WORK;
				   ELSE
					  COMMIT WORK;
				   END IF;

				   IF (wBegin = "S") THEN
					 BEGIN WORK;
				   END IF;

            ELSE
                -- Indica que uno de los campos llave viene vacio
                LET cCodRet = "00001";
			    LET cDescripcion = "Uno de los campos llave esta vacio.";
			   INSERT INTO "informix".sac_log_envios (proceso, folio_suc, importe, cod_ret, cadena_ent, fecha_insert, hora_insert)
				values ('sp_confpagoservicio', cFolio_suc, 0, cCodRet, vcadena_ent, CURRENT, CURRENT);	
            END IF;

      RETURN cCodRet, cDescripcion;
    END;
END PROCEDURE
DOCUMENT
'AUTOR : JosÃ© Angel LÃ³pez Adams',
'DESCRIPCION: Se encarga de confirmar el  movimiento para indicar que todo se grabo bien en sucursal',
'EJECUTADO O LLAMADO POR: Caja.exe()',
'FECHA : Septiembre de 2008',
'VERSION: 20080930',
'MODIFICO : Antonio Bastidas',
'DESCRIPCION: Se redimenciona el tamaÃ±o de referencia1 y referencia2 a 20 caracteres',
'EJECUTADO O LLAMADO POR: Procesos - DineroYa',
'FECHA : Diciembre de 2009',
'VERSION: 20091208.1627',
'MODIFICO : FRG',
'DESCRIPCION: Se agrega una tabla-bitacora para guardar los datos de entrada al SP',
'EJECUTADO O LLAMADO POR: Procesos - EjecuciÃ³n ConfirmaciÃ³n de Pago de Servicios',
'FECHA : Septiembre de 2011',
'VERSION: 20110905.1820',
'BD: bdisac',
'MODIFICO: Eduardo LÃ³pez Cuevas',
'EJECUTADO O LLAMADO POR: caja.exe',
'FECHA: 20130809.1721',
'MODIFICO : FRG',
'DESCRIPCION: Se agrega instrucciÃ³n para evitar bloqueos en tabla.',
'EJECUTADO O LLAMADO POR: Procesos - EjecuciÃ³n ConfirmaciÃ³n de Pago de Servicios',
'FECHA : Enero 2014',
'BD: bdisac',
'EJECUTADO O LLAMADO POR: caja.exe',
'FECHA: 20140107.1340',
'BD: bdisac',
'MODIFICO : Jorge ROberto',
'DESCRIPCION: actualizamos la referencia de la sc_movdia para pagos de servicio',
'EJECUTADO O LLAMADO POR: Procesos - Pago de servicios TAECOPPEL',
'FECHA : 14/10/2020';

CREATE PROCEDURE "informix".sp_app_submitpayment_web
(
	ptxn_status			CHAR(1),
	punirefnum			CHAR(16),
	prefnum				CHAR(30),
	pcode				CHAR(3),
	pchanneldid			CHAR(3),
	plocationunit		CHAR(15),
	pnnumber			CHAR(15),
	ptypecode			CHAR(3),
	pcountrycode		CHAR(3),
	pstatecode			CHAR(3),
	pterminalid			CHAR(15),
	pprocessdate		CHAR(8),
	pprocesstime		CHAR(6),
	pcustomernumber		CHAR(20),
	pfirstname			CHAR(40),
	pmiddlename			CHAR(40),
	plastname			CHAR(40),
	pmommaidenname	 	CHAR(40),
	padress				CHAR(80),
	pcity				CHAR(40),
	pcountrycodeadr		CHAR(3),
	pstatecodeadr		CHAR(3),
	pzipcode			CHAR(10),
	pemail				CHAR(100),
	phomephonenum		CHAR(15),
	pnumbercel			CHAR(15),
	preceiveemail		CHAR(3),
	preceivesms			CHAR(3),
	ptypecodeci			CHAR(3),
	pnumberci			CHAR(20),
	pexpirationdate		CHAR(8),
	pissuercc			CHAR(3),
	pdateofbirth		CHAR(8),
	pcontrycode			CHAR(5),
	pr_operacion		CHAR(5),
	pr_code				CHAR(4),
	pr_message			CHAR(255),
	pr_code_d			CHAR(4),
	pr_message_d		CHAR(255),
	pr_processdate		CHAR(8),
	pr_processtime		CHAR(6),
	pr_rule				CHAR(3),
	pr_value			CHAR(3),
	pr_globtracknum		CHAR(20),
	pr_ordstatuscode	CHAR(3),
	pr_ordstatusdate	CHAR(8),
	pr_ordstatustime	CHAR(6),
	pr_uniquerefnum		CHAR(16),
	pr_codesalecom		CHAR(3),
	pr_countrycode		CHAR(3),
	pr_statecodesale	CHAR(3),
	pr_saledate			CHAR(8),
	pr_saletime			CHAR(6),
	pr_countrycode_o	CHAR(3),
	pr_currencycode		CHAR(3),
	pr_servicecode		CHAR(3),
	pr_countrycode_d	CHAR(3),
	pr_currencycod_d	CHAR(3),
	pr_delimethodcod	CHAR(3),
	pr_playnwcode		CHAR(3),
	pr_paysubnwcode		CHAR(15),
	pr_branchnumber		CHAR(15),
	pr_accounttcod		CHAR(3),
	pr_accountnumber	CHAR(30),
	pr_originamount		CHAR(20),
	pr_destinamount		CHAR(20),
	pr_rexchangerate	CHAR(21),
	pr_wholesalerate	CHAR(21),
	pr_deexhangerate	CHAR(21),
	pr_servfeeamount	CHAR(20),
	pr_discountamoun	CHAR(20),
	pr_typecode			CHAR(3),
	pr_accountnum		CHAR(30),
	pr_biccode			CHAR(11),
	pr_refnumber		CHAR(30),
	pr_customernum		CHAR(20),
	pr_firstname		CHAR(40),
	pr_middlename		CHAR(40),
	pr_lastname			CHAR(40),
	pr_mommaidenname 	CHAR(40),
	pr_address			CHAR(80),
	pr_city				CHAR(40),
	pr_countrycode_a	CHAR(3),
	pr_statecode		CHAR(3),
	pr_zipcode			CHAR(10),
	pr_typecode_i		CHAR(3),
	pr_number			CHAR(20),
	pr_expirdate		CHAR(8),
	pr_isscontrycode	CHAR(3),
	pr_issstatecode		CHAR(3),
	pr_dateofbirth		CHAR(8),
	pr_customernum_b 	CHAR(20),
	pr_firstname_b		CHAR(40),
	pr_middlename_b		CHAR(40),
	pr_lastname_b		CHAR(40),
	pr_mommaidenna_b 	CHAR(40),
	pr_firstname_f		CHAR(40),
	pr_middlename_f		CHAR(40),
	pr_lastname_f		CHAR(40),
	pr_mommaidenna_f 	CHAR(40),
	pr_address_b		CHAR(80),
	pr_city_b			CHAR(40),
	pr_countrycode_b	CHAR(3),
	pr_statecode_b		CHAR(3),
	pr_zipcode_b		CHAR(10),
	pr_email			CHAR(100),
	pr_homephonenum 	CHAR(15),
	pr_workphonenum		CHAR(15),
	pr_number_cl		CHAR(15),
	pr_receiveemail		CHAR(3),
	pr_receivesms		CHAR(3),
	pr_typecode_ib		CHAR(3),
	pr_number_ib		CHAR(20),
	pr_expirdate_ib		CHAR(8),
	pr_issconcode_ib	CHAR(3),
	pr_issstacode_ib	CHAR(3),
	pr_reastypecode		CHAR(3),
	pr_refortransfer	CHAR(40),
	pr_sourceoffunds	CHAR(40),
	pr_securphrase		CHAR(40),
	pr_feemessage		CHAR(255),
	puser_insert		CHAR(8),
	pfecha				DATE,
	pNumCte			    CHAR(20)
)
RETURNING CHAR (5)	 AS cCodRet, 
		  CHAR (255) AS cr_Message, --1.2
		  CHAR (255) AS cr_Message_Detail; --1.3.2
		  
	  
--Declaracion de variables 
		DEFINE cCodRet 		    	CHAR(5);
		DEFINE iSqlErr				INTEGER;
		DEFINE imenscode			INTEGER;
		DEFINE cr_Message			CHAR (255);
		DEFINE cr_Message_Detail	CHAR (255);
		
		DEFINE crsp_CodRet			CHAR(5);
		DEFINE crsp_Message			CHAR (255);
		DEFINE crsp_Message_Detail	CHAR (255);
		DEFINE c_Mess_D				CHAR (255);
		DEFINE vfec_nac				DATE;
		
		DEFINE vCodRet				CHAR(5);
		DEFINE vcuenta				INTEGER;
		DEFINE vCategoria			CHAR(2);
		DEFINE vConvenio			CHAR(5);
		
		
-----------------------------------------------------------------------------------------------------------------------------------
		LET cCodRet 			= '00000'; --Codigo 00000 = OK; 00001 = No hubo datos
		LET iSqlErr				= 0;
		LET imenscode			= 0;
        LET cr_Message			= pr_message;
		LET cr_Message_Detail	= pr_message_d;
		
		LET crsp_CodRet			= '';
		LET crsp_Message		= '';
		LET crsp_Message_Detail	= '';
		LET c_Mess_D			= pr_message_d;
		
		LET vcuenta				= 0;
		LET vCodRet				= '00000';
		LET vCategoria			= '07';
		LET vConvenio			= '009';
		
BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cr_Message, cr_Message_Detail;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/informix/ENP/sp_app_submitpayment.out';
	--TRACE ON;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;  
		
		IF NVL(punirefnum, '') = '' OR NVL(pnnumber, '') = '' OR NVL(puser_insert, '') = '' OR NVL(pfecha, '') = '' OR NVL(prefnum, '') = '' THEN
			 LET cCodRet = '00001';
			 --DATOS VACIOS, ERROR.
			 RETURN cCodRet, NVL(cr_Message, ''),  NVL(cr_Message_Detail, '');

		ELSE
		
			-- verifica si los mensajes de regreso estan en el catalado para regresarlos en espanol 
			EXECUTE PROCEDURE BDISAC: "informix".sp_app_mensajes ('PAYI', pr_code, pr_code_d)
			INTO crsp_CodRet, crsp_Message, crsp_Message_Detail;	
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				-- no trajo resultados del llamado al sp
				LET cCodRet = '00001';
			ELSE
				IF crsp_CodRet = '00000' THEN
					LET cr_Message = crsp_Message;
					LET imenscode = 1;
				ELSE
					IF crsp_CodRet = '00001' THEN
						LET cr_Message = crsp_Message;
					ELSE
						IF crsp_CodRet = '00002' THEN
							LET imenscode = 1;
						END IF;
					END IF;
				END IF;
			END IF;
			IF imenscode = 1 then
				IF pr_code_d = "D001" THEN
					LET imenscode = 20;
				ELIF  pr_code_d = "D002" THEN
					LET imenscode = 28;
				ELIF  pr_code_d = "D003" THEN
					LET imenscode = 19;
				ELIF  pr_code_d = "D004" THEN
					LET imenscode = 20;
				ELIF  pr_code_d = "D005" THEN
					LET imenscode = 20;
				END IF;
				-- corta parametro en mensaje ingles "Required Parameter: {0} Parameter Key"
				LET c_Mess_D = SUBSTR(c_Mess_D, imenscode);
				LET c_Mess_D = REPLACE(c_Mess_D, " Parameter Key","");
				-- concatenar parametro con el mensaje en espanol "El parametro requerido: {0} parametro clave."
				LET crsp_Message_Detail = REPLACE(crsp_Message_Detail,"{0}", trim(c_Mess_D));
				-- asigna mensaje que devera retornar
				LET cr_Message_Detail = crsp_Message_Detail;
			END IF;
			--Inserta registro
			IF (cCodRet = '00000')THEN
								
				INSERT INTO bdisac: "informix".sac_app_payi (txn_status,unirefnum,refnum,code,channeldid,locationunit,nnumber,typecode,countrycode,statecode,terminalid,processdate,processtime,customernumber,firstname,middlename,lastname,mommaidenname,adress,city,countrycodeadr,statecodeadr,zipcode,email,homephonenum,numbercel,receiveemail,receivesms,typecodeci,numberci,expirationdate,issuercc,dateofbirth,contrycode,r_operacion,r_code,r_message,r_code_d,r_message_d,r_processdate,r_processtime,r_rule,r_value,r_globtracknum,r_ordstatuscode,r_ordstatusdate,r_ordstatustime,r_uniquerefnum,r_codesalecom,r_countrycode,r_statecodesale,r_saledate,r_saletime,r_countrycode_o,r_currencycode,r_servicecode,r_countrycode_d,r_currencycod_d,r_delimethodcod,r_playnwcode,r_paysubnwcode,r_branchnumber,r_accounttcod,r_accountnumber,r_originamount,r_destinamount,r_rexchangerate,r_wholesalerate,r_deexhangerate,r_servfeeamount,r_discountamoun,r_typecode,r_accountnum,r_biccode,r_refnumber,r_customernum,r_firstname,r_middlename,r_lastname,r_mommaidenname,r_address,r_city,r_countrycode_a,r_statecode,r_zipcode,r_typecode_i,r_number,r_expirdate,r_isscontrycode,r_issstatecode,r_dateofbirth,r_customernum_b,r_firstname_b,r_middlename_b,r_lastname_b,r_mommaidenna_b,r_firstname_f,r_middlename_f,r_lastname_f,r_mommaidenna_f,r_address_b,r_city_b,r_countrycode_b,r_statecode_b,r_zipcode_b,r_email,r_homephonenum,r_workphonenum,r_number_cl,r_receiveemail,r_receivesms,r_typecode_ib,r_number_ib,r_expirdate_ib,r_issconcode_ib,r_issstacode_ib,r_reastypecode,r_refortransfer,r_sourceoffunds,r_securphrase,r_feemessage,user_insert,fecha,numcte) 
				VALUES (ptxn_status, punirefnum, prefnum, pcode, pchanneldid, plocationunit, pnnumber, ptypecode, pcountrycode, pstatecode, pterminalid, pprocessdate, pprocesstime, pcustomernumber, pfirstname, pmiddlename, plastname, pmommaidenname, padress, pcity, pcountrycodeadr, pstatecodeadr, pzipcode, pemail, phomephonenum, pnumbercel, preceiveemail, preceivesms, ptypecodeci, pnumberci, pexpirationdate, pissuercc, pdateofbirth, pcontrycode, pr_operacion, pr_code, cr_Message, pr_code_d, cr_Message_Detail,  pr_processdate, pr_processtime, pr_rule, pr_value, pr_globtracknum, pr_ordstatuscode, pr_ordstatusdate, pr_ordstatustime, pr_uniquerefnum, pr_codesalecom, pr_countrycode, pr_statecodesale, pr_saledate, pr_saletime, pr_countrycode_o, pr_currencycode, pr_servicecode, pr_countrycode_d, pr_currencycod_d, pr_delimethodcod, pr_playnwcode, pr_paysubnwcode, pr_branchnumber, pr_accounttcod, pr_accountnumber, pr_originamount, pr_destinamount, pr_rexchangerate, pr_wholesalerate, pr_deexhangerate, pr_servfeeamount, pr_discountamoun, pr_typecode, pr_accountnum, pr_biccode, pr_refnumber, pr_customernum, pr_firstname, pr_middlename, pr_lastname, pr_mommaidenname, pr_address, pr_city, pr_countrycode_a, pr_statecode, pr_zipcode, pr_typecode_i, pr_number, pr_expirdate, pr_isscontrycode, pr_issstatecode, pr_dateofbirth, pr_customernum_b, pr_firstname_b, pr_middlename_b, pr_lastname_b, pr_mommaidenna_b, pr_firstname_f, pr_middlename_f, pr_lastname_f, pr_mommaidenna_f, pr_address_b, pr_city_b, pr_countrycode_b, pr_statecode_b, pr_zipcode_b, pr_email, pr_homephonenum, pr_workphonenum, pr_number_cl, pr_receiveemail, pr_receivesms, pr_typecode_ib, pr_number_ib, pr_expirdate_ib, pr_issconcode_ib, pr_issstacode_ib, pr_reastypecode, pr_refortransfer, pr_sourceoffunds, pr_securphrase, pr_feemessage, puser_insert, CURRENT,pNumCte);
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '00001';
				--La ejecucion de este procedimiento se paso al procedimiento 'bdisac:sp_pago_appiza_web'
				--ELSE
				--	LET vfec_nac = MDY(SUBSTRING(pdateofbirth FROM 5 FOR 2), SUBSTRING(pdateofbirth FROM 7 FOR 2), SUBSTRING(pdateofbirth FROM 1 FOR 4));
				--	EXECUTE PROCEDURE bdisac:"informix".sp_actualizaremesa(vCategoria, vConvenio, punirefnum, pfirstname, pmiddlename, plastname, pmommaidenname, vfec_nac, pr_currencycode, pr_originamount)
				--	INTO vCodRet, vcuenta;
				END IF;
	            ---------------------------------------------------------------------------------
				IF
					pnnumber <> '' or pnnumber IS NOT NULL THEN
					IF EXISTS (SELECT * FROM bdinteg:"informix".si_sucursales WHERE sucursal NOT IN ('9250', '9251', '9764','5011','5003') AND sucursal = pnnumber) THEN
						EXECUTE PROCEDURE bdinteg: "informix".sp_inserta_msjafore(pNumcte,'',pnnumber,'') INTO cCodRet;
						IF 
							cCodRet <> '00000' THEN
							INSERT INTO bdisac:"informix".sac_procesos_jobs(proceso, fecha_proceso, status, user_insert, fecha_insert, numero_ejecuciones, nombre_sp, descripcion)
							VALUES ('sp_pago_wu_web', CURRENT, '0', 'informix', CURRENT, NULL, 'sp_inserta_msjafore', 'Codigo retorno: '|| cCodRet);
						END IF;
					END IF;
				END IF;
				----------------------------------------------------------------------------------
			END IF;

			RETURN cCodRet, NVL(cr_Message, ''),  NVL(cr_Message_Detail, '') ;
			
		END IF;
	END;
END PROCEDURE
DOCUMENT
'AUTOR : 95992243 - Trinidad Hernandez',
'DESCRIPCION: Servira para insertar en la tabla sac_app_payi',
'FOLIO: 1543 - PagosApprizaDLL',
'FECHA : 22/03/2016',
'VERSION: 20160318.0921',	
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------',
'Descripcion: Se insertan campo numcte para Trabajar en remesas',
'Autor      : Geovani Garcia Ochoa',
'FECHA DE CREACION    : 28/02/2017',
'BD         : bdisac ',
'FOLIO: 198 - RQM 10 784 B ASE DE DATOS PARA EL ALTA DE USUARIOS DE REMESAS',
'-----------------------------------------------------------------------------------------------------',
'Descripcion: Se quita llamado a sp_actualizaremesa, este se paso a sp_pago_appiza_web',
'Autor      : Aaron Lopez Ruiz',
'FECHA DE CREACION    : 15/08/2019',
'BD         : bdisac ',
'FOLIO: RQI 62 663 Remesas Web',
'-----------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_app_submitpayment_web
(
	ptxn_status			        CHAR(1),
	punirefnum			        CHAR(16),
	prefnum				        CHAR(30),
	pcode				        CHAR(3),
	pchanneldid			        CHAR(3),
	plocationunit		        CHAR(15),
	pnnumber			        CHAR(15),
	ptypecode			        CHAR(3),
	pcountrycode		        CHAR(3),
	pstatecode			        CHAR(3),
	pterminalid			        CHAR(15),
	pprocessdate		        CHAR(8),
	pprocesstime		        CHAR(6),
	pcustomernumber		        CHAR(20),
	pfirstname			        CHAR(40),
	pmiddlename			        CHAR(40),
	plastname			        CHAR(40),
	pmommaidenname	 	        CHAR(40),
	padress				        CHAR(80),
	pcity				        CHAR(40),
	pcountrycodeadr		        CHAR(3),
	pstatecodeadr		        CHAR(3),
	pzipcode			        CHAR(10),
	pemail				        CHAR(100),
	phomephonenum		        CHAR(15),
	pnumbercel			        CHAR(15),
	preceiveemail		        CHAR(3),
	preceivesms			        CHAR(3),
	ptypecodeci			        CHAR(3),
	pnumberci			        CHAR(20),
	pexpirationdate		        CHAR(8),
	pissuercc			        CHAR(3),
	pdateofbirth		        CHAR(8),
	pcontrycode			        CHAR(5),
	pr_operacion		        CHAR(5),
	pr_code				        CHAR(4),
	pr_message			        CHAR(255),
	pr_code_d			        CHAR(4),
	pr_message_d		        CHAR(255),
	pr_processdate		        CHAR(8),
	pr_processtime		        CHAR(6),
	pr_rule				        CHAR(3),
	pr_value			        CHAR(3),
	pr_globtracknum		        CHAR(20),
	pr_ordstatuscode	        CHAR(3),
	pr_ordstatusdate	        CHAR(8),
	pr_ordstatustime	        CHAR(6),
	pr_uniquerefnum		        CHAR(16),
	pr_codesalecom		        CHAR(3),
	pr_countrycode		        CHAR(3),
	pr_statecodesale	        CHAR(3),
	pr_saledate			        CHAR(8),
	pr_saletime			        CHAR(6),
	pr_countrycode_o	        CHAR(3),
	pr_currencycode		        CHAR(3),
	pr_servicecode		        CHAR(3),
	pr_countrycode_d	        CHAR(3),
	pr_currencycod_d	        CHAR(3),
	pr_delimethodcod	        CHAR(3),
	pr_playnwcode		        CHAR(3),
	pr_paysubnwcode		        CHAR(15),
	pr_branchnumber		        CHAR(15),
	pr_accounttcod		        CHAR(3),
	pr_accountnumber	        CHAR(30),
	pr_originamount		        CHAR(20),
	pr_destinamount		        CHAR(20),
	pr_rexchangerate	        CHAR(21),
	pr_wholesalerate	        CHAR(21),
	pr_deexhangerate	        CHAR(21),
	pr_servfeeamount	        CHAR(20),
	pr_discountamoun	        CHAR(20),
	pr_typecode			        CHAR(3),
	pr_accountnum		        CHAR(30),
	pr_biccode			        CHAR(11),
	pr_refnumber		        CHAR(30),
	pr_customernum		        CHAR(20),
	pr_firstname		        CHAR(40),
	pr_middlename		        CHAR(40),
	pr_lastname			        CHAR(40),
	pr_mommaidenname 	        CHAR(40),
	pr_address			        CHAR(80),
	pr_city				        CHAR(40),
	pr_countrycode_a	        CHAR(3),
	pr_statecode		        CHAR(3),
	pr_zipcode			        CHAR(10),
	pr_typecode_i		        CHAR(3),
	pr_number			        CHAR(20),
	pr_expirdate		        CHAR(8),
	pr_isscontrycode	        CHAR(3),
	pr_issstatecode		        CHAR(3),
	pr_dateofbirth		        CHAR(8),
	pr_customernum_b 	        CHAR(20),
	pr_firstname_b		        CHAR(40),
	pr_middlename_b		        CHAR(40),
	pr_lastname_b		        CHAR(40),
	pr_mommaidenna_b 	        CHAR(40),
	pr_firstname_f		        CHAR(40),
	pr_middlename_f		        CHAR(40),
	pr_lastname_f		        CHAR(40),
	pr_mommaidenna_f 	        CHAR(40),
	pr_address_b		        CHAR(80),
	pr_city_b			        CHAR(40),
	pr_countrycode_b	        CHAR(3),
	pr_statecode_b		        CHAR(3),
	pr_zipcode_b		        CHAR(10),
	pr_email			        CHAR(100),
	pr_homephonenum 	        CHAR(15),
	pr_workphonenum		        CHAR(15),
	pr_number_cl		        CHAR(15),
	pr_receiveemail		        CHAR(3),
	pr_receivesms		        CHAR(3),
	pr_typecode_ib		        CHAR(3),
	pr_number_ib		        CHAR(20),
	pr_expirdate_ib		        CHAR(8),
	pr_issconcode_ib	        CHAR(3),
	pr_issstacode_ib	        CHAR(3),
	pr_reastypecode		        CHAR(3),
	pr_refortransfer	        CHAR(40),
	pr_sourceoffunds	        CHAR(40),
	pr_securphrase		        CHAR(40),
	pr_feemessage		        CHAR(255),
	puser_insert		        CHAR(8),
	pfecha				        DATE,
	pNumCte			            CHAR(20),
    pr_occupationcode		    CHAR(3),
    pr_nationalitycode		    CHAR(3),
    pr_relationshiptosendercode	CHAR(3),
    pr_reasonfortransfercode	CHAR(3),
    pr_reasonfortransfer		CHAR(100)
)
RETURNING CHAR (5)	 AS cCodRet, 
		  CHAR (255) AS cr_Message, --1.2
		  CHAR (255) AS cr_Message_Detail; --1.3.2
		  
	  
--Declaracion de variables 
		DEFINE cCodRet 		    	CHAR(5);
		DEFINE iSqlErr				INTEGER;
		DEFINE imenscode			INTEGER;
		DEFINE cr_Message			CHAR (255);
		DEFINE cr_Message_Detail	CHAR (255);
		
		DEFINE crsp_CodRet			CHAR(5);
		DEFINE crsp_Message			CHAR (255);
		DEFINE crsp_Message_Detail	CHAR (255);
		DEFINE c_Mess_D				CHAR (255);
		DEFINE vfec_nac				DATE;
		
		DEFINE vCodRet				CHAR(5);
		DEFINE vcuenta				INTEGER;
		DEFINE vCategoria			CHAR(2);
		DEFINE vConvenio			CHAR(5);
		
        --EPG 22/04/2021
        DEFINE refeferencia_remesa  CHAR(12);
		DEFINE tipo_remesa          INTEGER;
        --EPG 22/04/2021
-----------------------------------------------------------------------------------------------------------------------------------
		LET cCodRet 			= '00000'; --Codigo 00000 = OK; 00001 = No hubo datos
		LET iSqlErr				= 0;
		LET imenscode			= 0;
        LET cr_Message			= pr_message;
		LET cr_Message_Detail	= pr_message_d;
		
		LET crsp_CodRet			= '';
		LET crsp_Message		= '';
		LET crsp_Message_Detail	= '';
		LET c_Mess_D			= pr_message_d;
		
		LET vcuenta				= 0;
		LET vCodRet				= '00000';
		LET vCategoria			= '07';
		LET vConvenio			= '009';
        
        --EPG 22/04/2021
        LET refeferencia_remesa = '';
        LET tipo_remesa         = 0;
        --EPG 22/04/2021
		
BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cr_Message, cr_Message_Detail;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/informix/ENP/sp_app_submitpayment.out';
	--TRACE ON;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;  
		
		IF NVL(punirefnum, '') = '' OR NVL(pnnumber, '') = '' OR NVL(puser_insert, '') = '' OR NVL(pfecha, '') = '' OR NVL(prefnum, '') = '' THEN
			 LET cCodRet = '00001';
			 --DATOS VACIOS, ERROR.
			 RETURN cCodRet, NVL(cr_Message, ''),  NVL(cr_Message_Detail, '');

		ELSE
		
			-- verifica si los mensajes de regreso estan en el catalado para regresarlos en espanol 
			EXECUTE PROCEDURE BDISAC: "informix".sp_app_mensajes ('PAYI', pr_code, pr_code_d)
			INTO crsp_CodRet, crsp_Message, crsp_Message_Detail;	
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				-- no trajo resultados del llamado al sp
				LET cCodRet = '00001';
			ELSE
				IF crsp_CodRet = '00000' THEN
					LET cr_Message = crsp_Message;
					LET imenscode = 1;
				ELSE
					IF crsp_CodRet = '00001' THEN
						LET cr_Message = crsp_Message;
					ELSE
						IF crsp_CodRet = '00002' THEN
							LET imenscode = 1;
						END IF;
					END IF;
				END IF;
			END IF;
			IF imenscode = 1 then
				IF pr_code_d = "D001" THEN
					LET imenscode = 20;
				ELIF  pr_code_d = "D002" THEN
					LET imenscode = 28;
				ELIF  pr_code_d = "D003" THEN
					LET imenscode = 19;
				ELIF  pr_code_d = "D004" THEN
					LET imenscode = 20;
				ELIF  pr_code_d = "D005" THEN
					LET imenscode = 20;
				END IF;
				-- corta parametro en mensaje ingles "Required Parameter: {0} Parameter Key"
				LET c_Mess_D = SUBSTR(c_Mess_D, imenscode);
				LET c_Mess_D = REPLACE(c_Mess_D, " Parameter Key","");
				-- concatenar parametro con el mensaje en espanol "El parametro requerido: {0} parametro clave."
				LET crsp_Message_Detail = REPLACE(crsp_Message_Detail,"{0}", trim(c_Mess_D));
				-- asigna mensaje que devera retornar
				LET cr_Message_Detail = crsp_Message_Detail;
			END IF;
			
			--Inserta registro
			IF (cCodRet = '00000')THEN
								
				---EPG 22/04/2021
                ---Valido si la remesa es Money Gram 
                SELECT referencia1 INTO refeferencia_remesa FROM bdisac:"informix".sac_movimientos WHERE numcategoria = vCategoria and numconvenio = vConvenio and folio_suc = prefnum;
                LET tipo_remesa = LENGTH(refeferencia_remesa);
                IF tipo_remesa = 8 THEN --Si es Money Gram guardo la referencia de Appriza 
                   UPDATE bdisac:"informix".sac_movimientos SET referencia4 = pr_uniquerefnum WHERE referencia1 = punirefnum and folio_suc = prefnum;
                END IF;
                ---EPG 22/04/2021

                INSERT INTO bdisac: "informix".sac_app_payi (txn_status,unirefnum,refnum,code,channeldid,locationunit,nnumber,typecode,countrycode,statecode,terminalid,processdate,processtime,customernumber,firstname,middlename,lastname,mommaidenname,adress,city,countrycodeadr,statecodeadr,zipcode,email,homephonenum,numbercel,receiveemail,receivesms,typecodeci,numberci,expirationdate,issuercc,dateofbirth,contrycode,r_operacion,r_code,r_message,r_code_d,r_message_d,r_processdate,r_processtime,r_rule,r_value,r_globtracknum,r_ordstatuscode,r_ordstatusdate,r_ordstatustime,r_uniquerefnum,r_codesalecom,r_countrycode,r_statecodesale,r_saledate,r_saletime,r_countrycode_o,r_currencycode,r_servicecode,r_countrycode_d,r_currencycod_d,r_delimethodcod,r_playnwcode,r_paysubnwcode,r_branchnumber,r_accounttcod,r_accountnumber,r_originamount,r_destinamount,r_rexchangerate,r_wholesalerate,r_deexhangerate,r_servfeeamount,r_discountamoun,r_typecode,r_accountnum,r_biccode,r_refnumber,r_customernum,r_firstname,r_middlename,r_lastname,r_mommaidenname,r_address,r_city,r_countrycode_a,r_statecode,r_zipcode,r_typecode_i,r_number,r_expirdate,r_isscontrycode,r_issstatecode,r_dateofbirth,r_customernum_b,r_firstname_b,r_middlename_b,r_lastname_b,r_mommaidenna_b,r_firstname_f,r_middlename_f,r_lastname_f,r_mommaidenna_f,r_address_b,r_city_b,r_countrycode_b,r_statecode_b,r_zipcode_b,r_email,r_homephonenum,r_workphonenum,r_number_cl,r_receiveemail,r_receivesms,r_typecode_ib,r_number_ib,r_expirdate_ib,r_issconcode_ib,r_issstacode_ib,r_reastypecode,r_refortransfer,r_sourceoffunds,r_securphrase,r_feemessage,user_insert,fecha,numcte, r_occupationcode, r_nationalitycode, r_relationshiptosendercode, r_reasonfortransfercode, r_reasonfortransfer) 
				VALUES (ptxn_status, punirefnum, prefnum, pcode, pchanneldid, plocationunit, pnnumber, ptypecode, pcountrycode, pstatecode, pterminalid, pprocessdate, pprocesstime, pcustomernumber, pfirstname, pmiddlename, plastname, pmommaidenname, padress, pcity, pcountrycodeadr, pstatecodeadr, pzipcode, pemail, phomephonenum, pnumbercel, preceiveemail, preceivesms, ptypecodeci, pnumberci, pexpirationdate, pissuercc, pdateofbirth, pcontrycode, pr_operacion, pr_code, cr_Message, pr_code_d, cr_Message_Detail,  pr_processdate, pr_processtime, pr_rule, pr_value, pr_globtracknum, pr_ordstatuscode, pr_ordstatusdate, pr_ordstatustime, pr_uniquerefnum, pr_codesalecom, pr_countrycode, pr_statecodesale, pr_saledate, pr_saletime, pr_countrycode_o, pr_currencycode, pr_servicecode, pr_countrycode_d, pr_currencycod_d, pr_delimethodcod, pr_playnwcode, pr_paysubnwcode, pr_branchnumber, pr_accounttcod, pr_accountnumber, pr_originamount, pr_destinamount, pr_rexchangerate, pr_wholesalerate, pr_deexhangerate, pr_servfeeamount, pr_discountamoun, pr_typecode, pr_accountnum, pr_biccode, pr_refnumber, pr_customernum, pr_firstname, pr_middlename, pr_lastname, pr_mommaidenname, pr_address, pr_city, pr_countrycode_a, pr_statecode, pr_zipcode, pr_typecode_i, pr_number, pr_expirdate, pr_isscontrycode, pr_issstatecode, pr_dateofbirth, pr_customernum_b, pr_firstname_b, pr_middlename_b, pr_lastname_b, pr_mommaidenna_b, pr_firstname_f, pr_middlename_f, pr_lastname_f, pr_mommaidenna_f, pr_address_b, pr_city_b, pr_countrycode_b, pr_statecode_b, pr_zipcode_b, pr_email, pr_homephonenum, pr_workphonenum, pr_number_cl, pr_receiveemail, pr_receivesms, pr_typecode_ib, pr_number_ib, pr_expirdate_ib, pr_issconcode_ib, pr_issstacode_ib, pr_reastypecode, pr_refortransfer, pr_sourceoffunds, pr_securphrase, pr_feemessage, puser_insert, CURRENT,pNumCte, pr_occupationcode, pr_nationalitycode, pr_relationshiptosendercode, pr_reasonfortransfercode, pr_reasonfortransfer);

				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '00001';
				--La ejecucion de este procedimiento se paso al procedimiento 'bdisac:sp_pago_appiza_web'
				--ELSE
				--	LET vfec_nac = MDY(SUBSTRING(pdateofbirth FROM 5 FOR 2), SUBSTRING(pdateofbirth FROM 7 FOR 2), SUBSTRING(pdateofbirth FROM 1 FOR 4));
				--	EXECUTE PROCEDURE bdisac:"informix".sp_actualizaremesa(vCategoria, vConvenio, punirefnum, pfirstname, pmiddlename, plastname, pmommaidenname, vfec_nac, pr_currencycode, pr_originamount)
				--	INTO vCodRet, vcuenta;
				END IF;

            ---------------------------------------------------------------------------------
            IF
                pnnumber <> '' or pnnumber IS NOT NULL THEN
                IF EXISTS (SELECT * FROM bdinteg:"informix".si_sucursales WHERE sucursal NOT IN ('9250', '9251', '9764','5011','5003') AND sucursal = pnnumber) THEN
                    EXECUTE PROCEDURE bdinteg: "informix".sp_inserta_msjafore(pNumcte,'',pnnumber,'') INTO cCodRet;
                    IF 
                        cCodRet <> '00000' THEN
                        INSERT INTO bdisac:"informix".sac_procesos_jobs(proceso, fecha_proceso, status, user_insert, fecha_insert, numero_ejecuciones, nombre_sp, descripcion)
                        VALUES ('sp_pago_wu_web', CURRENT, '0', 'informix', CURRENT, NULL, 'sp_inserta_msjafore', 'Codigo retorno: '|| cCodRet);
                    END IF;
                END IF;
            END IF;
            ----------------------------------------------------------------------------------
			END IF;

			RETURN cCodRet, NVL(cr_Message, ''),  NVL(cr_Message_Detail, '') ;
			
		END IF;

END;
END PROCEDURE
DOCUMENT
'AUTOR : 95992243 - Trinidad Hernandez',
'DESCRIPCION: Servira para insertar en la tabla sac_app_payi',
'FOLIO: 1543 - PagosApprizaDLL',
'FECHA : 22/03/2016',
'VERSION: 20160318.0921',	
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------',
'Descripcion: Se insertan campo numcte para Trabajar en remesas',
'Autor      : Geovani Garcia Ochoa',
'FECHA DE CREACION    : 28/02/2017',
'BD         : bdisac ',
'FOLIO: 198 - RQM 10 784 B ASE DE DATOS PARA EL ALTA DE USUARIOS DE REMESAS',
'-----------------------------------------------------------------------------------------------------',
'Descripcion: Se quita llamado a sp_actualizaremesa, este se paso a sp_pago_appiza_web',
'Autor      : Aaron Lopez Ruiz',
'FECHA DE CREACION    : 15/08/2019',
'BD         : bdisac ',
'FOLIO: RQI 62 663 Remesas Web',
'-----------------------------------------------------------------------------------------------------',
'Descripcion: Se agregan campos requeridos para Appriza Pay - Money Gram',
'Autor      : Eduardo Pineda GuzmÃ¡n',
'FECHA DE CREACION    : 22/04/2021',
'BD         : bdisac ',
'FOLIO: RQM 10 1389 - Money Gram',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_guardarespuestapayi2
(
    pSucursal 		            CHAR (4), 
    pTxn_Status					CHAR(1), 
    pConfirmation_nm 			CHAR (11), 
    pBank_Ref_Num			 	CHAR(20), 
    pUser_name 					CHAR(20), 
    pTerminal 					CHAR(15), 
    pAgent_Dt 					CHAR(8), 
    pAgent_Tm 					CHAR(6), 
    pR_First_Name				CHAR(40), 
    pR_Middle_Name 				CHAR(40), 
    pR_Last_Name 				CHAR(40), 
    pR_Mother_M_Name 			CHAR(40),
    pR_Type_Cd 					CHAR(3), 
    pR_Issuer_Cd 				CHAR(3), 
    pR_Issuer_State_Cd			CHAR(3), 
    pR_Issuer_Country_Cd		CHAR(3), 
    pR_Identif_Type				CHAR(5),
    pR_Identif_Nm 				CHAR(20), 
    pR_Expiration_Dt			CHAR(8),
    pR_Fecha_Nac 				CHAR(8),
    pR_Nacionalidad 			CHAR(50),
    pR_pais_nac 				CHAR(20),	
    pR_Nom_Calle 				CHAR(50),
    pR_Num_Ext 					CHAR(5),
    pR_Num_Int 					CHAR(5),
    pR_Depto 					CHAR(10),
    pR_Colonia					CHAR(80),
    pR_Cp						CHAR(5),
    pR_Mncpo_Delg 				CHAR(50),
    pR_Ciudad					CHAR(50),
    pR_Estado 					CHAR(50),
    pR_Telefono 				CHAR(15),
    pTipo_Pago 					CHAR(1),
    pOpCode 					CHAR(4), 
    pProcess_Msg		 		CHAR(255), 	
    pError_Param_Full_Name		CHAR(255), 
    pTrans_Status_Cd			CHAR(3), 
    pTrans_Status_Dt 			CHAR(8),
    pProcess_Dt 				CHAR(8), 
    pProcess_Tm 				CHAR(6), 
    pUsuario 					CHAR(8),
    pNumCte						CHAR(20)
)


	--DATOS A REGRESAR---
    RETURNING
    CHAR(5);   -- Codigo de Retorno
	
	 --DEFINICION DE VARIABLES--
    DEFINE sql_err                INT;
    DEFINE cCodRet                CHAR(5);
	DEFINE cAgent_Trans_Type_Code CHAR(4);
	DEFINE cAgent_Cd              CHAR(3);
	DEFINE cRegion_Sd             CHAR(15);
	DEFINE cBranch_Sd             CHAR(15);
	DEFINE cState_Cd              CHAR(3);
	DEFINE cCountry_Cd            CHAR(3);
	DEFINE vfec_nac				  DATE;
	DEFINE vCodRet				CHAR(5);
	DEFINE vcuenta				INTEGER;
	DEFINE p_moneda_origen 		CHAR(3);
	DEFINE p_importe_origen 	MONEY;
	DEFINE vCategoria			CHAR(2);
	DEFINE vConvenio			CHAR(5);
	
	
	
        --INICIALIZACION DE VARIABLES--
    LET sql_err                = 0;
    LET cCodRet                = '00000';
	LET cAgent_Trans_Type_Code = 'PAYI';
	LET cAgent_Cd              = '';
	LET cRegion_Sd             = '';
	LET cBranch_Sd             = '';
	LET cState_Cd              = '';
	LET cCountry_Cd            = '';
	LET vcuenta					= 0;
	LET vCodRet					= '00000';
	LET p_moneda_origen			= '';
	LET p_importe_origen		= 0;
	LET vCategoria				= '07';
	LET vConvenio				= '004';
	
	
	--SET DEBUG FILE TO "/respaldosbd/Dulce/sp_GuardaRespuestaPayi2.out";
    --TRACE ON;

    
	--SET DEBUG FILE TO "/ifxsif01/ENP/sp_GuardaRespuestaPayi2.out";
    --TRACE ON;

    
	
	BEGIN

    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cCodRet = sql_err;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;
	
	IF pSucursal = "" OR  pSucursal IS NULL OR pTxn_Status = "" OR pTxn_Status IS NULL OR pConfirmation_nm = "" OR pConfirmation_nm IS NULL 
	    OR pBank_Ref_Num = "" OR pBank_Ref_Num IS NULL OR pUser_name = "" OR pUser_name IS NULL OR pTerminal = "" OR pTerminal IS NULL 
		OR pAgent_Dt = "" OR pAgent_Dt IS NULL OR pAgent_Tm = "" OR pAgent_Tm IS NULL 
		OR pR_First_Name = "" OR pR_First_Name IS NULL OR pR_Last_Name = "" OR pR_Last_Name IS NULL 
		OR pR_Type_Cd = "" OR pR_Type_Cd IS NULL OR pR_Issuer_Cd = "" OR pR_Issuer_Cd IS NULL 
		OR pR_Issuer_State_Cd = "" OR pR_Issuer_State_Cd IS NULL OR pR_Issuer_Country_Cd = "" OR pR_Issuer_Country_Cd IS NULL 
		OR pR_Identif_Nm = "" OR pR_Identif_Nm IS NULL OR pR_Expiration_Dt = "" OR pR_Expiration_Dt IS NULL 
		OR pUsuario = "" OR pUsuario IS NULL OR pR_pais_nac = "" OR pR_pais_nac IS NULL THEN
		LET cCodRet = "00001";
		RETURN cCodRet;
	END IF;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	EXECUTE PROCEDURE bdisac:"informix".sp_consultasucursal (pSucursal) 
	INTO cCodRet, cAgent_Cd, cRegion_Sd, cBranch_Sd, cState_Cd, cCountry_Cd;
	IF cCodRet = "00000" THEN
		INSERT INTO "informix".sac_bts_payi (txn_status, agent_trans_type_code, agent_cd, confirmation_nm, bank_ref_nm, region_sd, branch_sd, state_cd, 
		        country_cd, user_name, terminal, agent_dt, agent_tm, r_first_name, r_middle_name, r_last_name, r_mother_m_name, r_type_cd, 
				r_issuer_cd, r_issuer_state_cd, r_issuer_country_cd, r_identif_type, r_identif_nm, r_expiration_dt, r_fecha_nac, r_nacionalidad, r_pais_nac,
				r_nom_calle, r_num_ext, r_num_int, r_depto, r_colonia, r_cp, r_mncpo_deleg, r_ciudad, r_estado, r_telefono, tipo_pago, sucursal,
				opcode, process_msg, error_param_full_name, trans_status_cd, trans_status_dt, process_dt, process_tm, user_insert, fecha_insert,numcte)
		VALUES(pTxn_Status, cAgent_Trans_Type_Code, cAgent_Cd, pConfirmation_Nm, pBank_Ref_Num, cRegion_Sd, cBranch_Sd, cState_Cd,
         		cCountry_Cd, pUser_Name, pTerminal, pAgent_Dt, pAgent_Tm, pR_First_Name, pR_Middle_Name, pR_Last_Name, pR_Mother_M_Name, pR_Type_Cd,  
				pR_Issuer_Cd, pR_Issuer_State_Cd, pR_Issuer_Country_Cd, pR_Identif_Type, pR_Identif_Nm, pR_Expiration_Dt, pR_Fecha_Nac, pR_Nacionalidad, pR_pais_nac,
				pR_Nom_Calle, pR_Num_Ext, pR_Num_Int, pR_Depto, pR_Colonia, pR_Cp, pR_Mncpo_Delg, pR_Ciudad, pR_Estado, pR_Telefono, pTipo_Pago, pSucursal, 
				pOpCode, pProcess_Msg, pError_Param_Full_Name, pTrans_Status_Cd, pTrans_Status_Dt, pProcess_Dt, pProcess_Tm, pUsuario, CURRENT,pNumCte);
				
		--Busco datos de query
		EXECUTE PROCEDURE bdisac:"informix".sp_obtieneremadic(vCategoria, vConvenio, pConfirmation_Nm)
		INTO vCodRet, p_moneda_origen, p_importe_origen;
		
		--Actualizo tabla de datos para limites de remesas mensuales
		LET vfec_nac = MDY(SUBSTRING(pR_Fecha_Nac FROM 5 FOR 2), SUBSTRING(pR_Fecha_Nac FROM 7 FOR 2), SUBSTRING(pR_Fecha_Nac FROM 1 FOR 4));
		EXECUTE PROCEDURE bdisac:"informix".sp_actualizaremesa(vCategoria, vConvenio, pConfirmation_Nm, pR_First_Name, pR_Middle_Name, pR_Last_Name, pR_Mother_M_Name, vfec_nac, p_moneda_origen, p_importe_origen)
		INTO vCodRet, vcuenta;

            ---------------------------------------------------------------------------------
        IF
            pSucursal <> '' or pSucursal IS NOT NULL THEN
            IF EXISTS (SELECT * FROM bdinteg:"informix".si_sucursales WHERE sucursal NOT IN ('9250', '9251', '9764','5011','5003') AND sucursal = pSucursal) THEN
                EXECUTE PROCEDURE bdinteg:"informix".sp_inserta_msjafore(pNumcte,'',pSucursal,'') INTO cCodRet;
                IF 
                    cCodRet <> '00000' THEN
                    INSERT INTO bdisac:"informix".sac_procesos_jobs(proceso, fecha_proceso, status, user_insert, fecha_insert, numero_ejecuciones, nombre_sp, descripcion)
                    VALUES ('sp_pago_wu_web', CURRENT, '0', 'informix', CURRENT, NULL, 'sp_inserta_msjafore', 'Codigo retorno: '|| cCodRet);
                END IF;
            END IF;
        END IF;
        ----------------------------------------------------------------------------------
       
		
	END IF;
	
	RETURN cCodRet;
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea SP para guardar los datos de envio y recepciÃÂ³n del mensaje PAYI de BTS',
'AUTOR : Dulce Ramirez',
'FECHA : 05/Enero/2011',
'Ver.  : 1.1',
'BD    : bdisac',
'VER   : 1.1',
'MODIFICO: Felipe Urias',
'FECHA : 12/Abril/2012',
'DESCRIPCION: se agrego el campo r_pais_nac como parametro a guardar en tabla',
'MODIFICO: FRG',
'FECHA : 09/Mayo/2012',
'DESCRIPCION: se clona el SP con nombre sp_guardarespuestapayi2.sql',
'para no afectar el flujo actual en Prod. al guardar el campo r_pais_nac',
'****************************************************************************************************',
'DescripciÃÂ³n: Se inserta campo numcte para utilizar en remesas',
'Autor      : Geovani Garcia Ochoa',
'FECHA DE CREACION    : 28/02/2017',
'BD         : bdisac',
'FOLIO		: 198 - RQM 10 784 B ASE DE DATOS PARA EL ALTA DE USUARIOS DE REMESAS',
'-------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_soldespagoskyonline(pFolioSuc char(16)) 
	--RETORNOS
	RETURNING
	CHAR(5) AS cCodigoRet, CHAR(850) AS cTrama; 
	
	--Definicion de Variables
	DEFINE cCodigoRet  	CHAR(5);
	DEFINE cTrama    	CHAR(850);
	DEFINE iSqlErr 		INTEGER;
	DEFINE cEnte_id 			CHAR(3);
	DEFINE cNumero_cuenta 	    CHAR(12);
	DEFINE cFecha_depo_banco    CHAR(10);
	DEFINE cImporte_transaccion CHAR(13);
	DEFINE cAutorizacion 	CHAR(10);
	DEFINE cMpel_id 		CHAR(15);
	DEFINE cUsoFuturo1 		CHAR(256);
	DEFINE cUsoFuturo2 		CHAR(256);
	DEFINE cUsoFuturo3 		CHAR(256);
	DEFINE cFolio_pago 		CHAR(10);
	DEFINE cTrancinterac    CHAR(5);
	DEFINE cTrancservice    CHAR(5);
	
	--Inicializacion de variables
	LET cCodigoRet = '00000';
	LET cTrama = '';
	LET iSqlErr = 0;
	LET cEnte_id ='';
	LET cNumero_cuenta ='';
	LET cFecha_depo_banco ='';
	LET cImporte_transaccion ='';
	LET cAutorizacion =''; 	
	LET cMpel_id ='';		
	LET cUsoFuturo1 	='';	
	LET cUsoFuturo2 	=''; 		
	LET cUsoFuturo3 	='';
	LET cFolio_pago 	=''; 
	LET cTrancinterac 	='';
	LET cTrancservice   ='';
	
	--SET DEBUG FILE TO '/home/sysifx/JesusAlbertoLI';
	--TRACE ON;
	
	BEGIN 
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodigoRet = iSqlErr;
				RETURN TRIM(NVL(cCodigoRet,"")),TRIM( NVL(cTrama,""));
			END IF;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO dirty READ;
		
		
		--Validamos parÃ¡metros para que no sean nulos
		IF NVL(pFolioSuc,'') = '' THEN
			 LET cCodigoRet = '00001';			 RETURN TRIM(NVL(cCodigoRet,"")),TRIM( NVL(cTrama,""));
        ELSE
		
		if (SELECT COUNT(*) FROM "informix".sac_sky_wsgpago  WHERE folio_suc = pFolioSuc AND id_respuesta ='000'  ) = 0 then 
			 LET cCodigoRet = '00002';			 RETURN TRIM(NVL(cCodigoRet,"")),TRIM( NVL(cTrama,""));
		END IF;
		SELECT trans_interact
		INTO cTrancinterac		
		FROM bdisac: "informix".sac_intrfz_serv  
		WHERE numcategoria = '06' and numconvenio='001' and num_trama = '2';
		
		
		SELECT trans_servicio
		INTO cTrancservice		
		FROM bdisac: "informix".sac_intrfz_serv  
		WHERE numcategoria = '06' and numconvenio='001' and num_trama = '2';
		
		
		SELECT valor 
		INTO cEnte_id 
		FROM bdisac: "informix".sac_param 
		WHERE cod_param = '114';
		
		SELECT referencia1 
		INTO cNumero_cuenta 
		FROM bdisac: "informix".sac_movimientos 
		WHERE folio_suc = pFolioSuc;
		
		--Fecha actual del sistema
		LET cfecha_depo_banco =
		SUBSTR(CURRENT, 9,  2)     ||'/'|| -- DD 
		SUBSTR(CURRENT, 6,  2)     ||'/'|| -- MM  
		SUBSTR(CURRENT, 1,  4)     ||' '|| -- AAAA   
					'';
		
		SELECT importe_pago 
		INTO cImporte_transaccion 
		FROM bdisac: "informix".sac_movimientos 
		WHERE folio_suc = pFolioSuc;
		
		LET cFolio_pago = SUBSTR(pFolioSuc, 7,  10);
		
		SELECT autorizacion
		INTO cAutorizacion
		FROM bdisac: "informix".sac_sky_wsgpago 
		WHERE folio_suc = pFolioSuc;
		
		SELECT mpel_id 
		INTO cMpel_id
		FROM bdisac: "informix".sac_sky_wsgpago 
		WHERE folio_suc = pFolioSuc;
		
		--concatenar todas la variables en cTrama
LET cTrama = NVL(cTrancinterac,'') || NVL(cTrancservice,'') || NVL(cEnte_id,'') || NVL(cNumero_cuenta,'') || NVL(cFecha_depo_banco,'') || NVL(SUBSTR(cImporte_transaccion,2,12),'0.00') || NVL(cFolio_pago,'') || NVL(cAutorizacion,'') || NVL(cMpel_id,'') || NVL(cUsoFuturo1,'') || NVL(cUsoFuturo2,'') || NVL(cUsoFuturo3,'');	
 
	END IF;
	
	RETURN TRIM(NVL(cCodigoRet,'')),NVL(cTrama,'');
	
	END;
END PROCEDURE;