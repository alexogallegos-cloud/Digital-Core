CREATE PROCEDURE "informix".sp_catalogotramite(pCliente CHAR(20),pProducto CHAR(4),pOpcion CHAR(1), pPagina smallint)
RETURNING CHAR(5) AS cCodeRet,  CHAR(30) AS sDescripcion, CHAR (12) AS cNumCta;

--Definicion
DEFINE cCodigoRet CHAR(5);
DEFINE iSqlErr  INTEGER;
DEFINE sDescripcion CHAR(30);
DEFINE cNumCta CHAR(12);

--AsignaciÃ³n
LET cCodigoRet = '00000';
LET iSqlErr = 0;
LET sDescripcion = "";
LET cNumCta = "";

BEGIN 	
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			  LET cCodigoRet = iSqlErr;
		RETURN cCodigoRet,sDescripcion,cNumCta;
		END IF;
	END EXCEPTION;
	
		--SET DEBUG FILE TO '/home/sysifx/Bryan/255/sp_catalogotramite.out'; --- MODIFICAR RUTA DEL ARCHIVO
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;
	if pOpcion = '1' Then
	
		FOREACH 
			SELECT  descripcion INTO sDescripcion FROM bdinteg:"informix".si_cattipotramitecitas where activo = 1
			RETURN cCodigoRet,sDescripcion,cNumCta WITH RESUME;
		END FOREACH
	ELSE
		FOREACH
		
			SELECT SKIP pPagina  DISTINCT cuenta
			INTO cNumCta			
			FROM bdicheq:"informix".sc_maechq
			WHERE num_cte =  pCliente
			AND  producto <> pProducto
			ORDER BY cuenta DESC			
			
			RETURN cCodigoRet,sDescripcion,cNumCta WITH RESUME;	
		END FOREACH
	END IF;
END
END PROCEDURE
DOCUMENT
'Folio: 255.1 - RQM 10 610-4 Incluir cambios finales al servicio de Portabilidad de Nomina en Sucursales',
'Autor: Bryan Limon',
'BD: bdinteg/ Central',
'Fecha: 25/07/2017',
'Descripcion: se crea procedimiento para cargar los catalogos activos de tramites citas.';

CREATE PROCEDURE "informix".sp_catcompaniacita()
RETURNING CHAR(5) AS cCodeRet, CHAR(4) AS sClave, CHAR(30) AS sComapania;

--Definicion
DEFINE cCodigoRet CHAR(5);
DEFINE iSqlErr  INTEGER;
DEFINE sComapania CHAR(30);
DEFINE sClave CHAR(4);

--AsignaciÃ³n
LET cCodigoRet = '00000';
LET iSqlErr = 0;
LET sComapania = "";
LET sClave = "";

BEGIN 	
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			  LET cCodigoRet = iSqlErr;
		RETURN cCodigoRet,sClave,sComapania;
		END IF;
	END EXCEPTION;
	
		--SET DEBUG FILE TO '/home/sysifx/Bryan/255/sp_catalogotramite.out'; --- MODIFICAR RUTA DEL ARCHIVO
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;
		
		FOREACH 
			SELECT clave,nombre_compania INTO sClave,sComapania FROM bdinteg:"informix".si_catcompaniacita WHERE activo = 1	
			RETURN cCodigoRet,sClave,sComapania with resume;
		END FOREACH					
END
END PROCEDURE
DOCUMENT
'Folio: 255.1 - RQM 10 610-4 Incluir cambios finales al servicio de Portabilidad de Nomina en Sucursales',
'Autor: Bryan Limon',
'BD: bdinteg/ Central',
'Fecha: 25/07/2017',
'Descripcion: se crea procedimiento para cargar los catalogos activos de las companias telefonicas.';

CREATE PROCEDURE "informix".sp_inserta_movil_tramitecita(pEmpresa CHAR(3), pNumCte CHAR(20),pNumCelular CHAR(13),pCarrier SMALLINT, pTipoTelefono SMALLINT, pUsuario CHAR(8),pOpcion CHAR(1))
RETURNING CHAR(6) As cCodRet,
CHAR(20) As cNumCte,
CHAR(50) As cNombre,
CHAR(13) As cTelefono,
SMALLINT As sCarrier,
CHAR(1) AS sCofetel;

--DefiniciÃ³n de Variables 
DEFINE cCodRet			CHAR (6);
DEFINE cCofetel 		CHAR(1);
DEFINE cNumCte          CHAR(20);
DEFINE cNombre			CHAR(50);
DEFINE sNumTelefonos    SMALLINT;
DEFINE sSecuencia		SMALLINT;
DEFINE sCarrier			SMALLINT;
DEFINE cValCasa         CHAR (1);
DEFINE cValCelular      CHAR (1);
DEFINE cTelefono	  	CHAR(13);
DEFINE cValOficina      CHAR (1);
DEFINE cCodRetSP        CHAR (5);
DEFINE iSqlErr          INTEGER;
DEFINE sCofetel			CHAR(1);

--InicializaciÃ³n de Variables

LET cCodRet          = '000000';
LET cCofetel         = '';
LET sNumTelefonos    = 0;
LET sSecuencia       = 0;
LET cValCasa         = '';
LET cValCelular      = '';
LET cTelefono    = '';
LET cNumCte			 = '';
LET cNombre  	 = '';
LET cValOficina      = '';
LET sCarrier		 = 0;
LET cCodRetSP        = '00000';
LET iSqlErr          = 0;
LET sCofetel		 = '';

BEGIN	
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			let cCodRet = iSqlErr;
			RETURN cCodRet,NVL(cNumCte,''),NVL(cNombre,''),NVL(cTelefono,''),NVL(sCarrier,''),NVL(sCofetel,'');
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/home/sysifx/Bryan/255/sp_inserta_movil_tramitecita.out";
	--TRACE ON; 
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF pOpcion = '1' Then
		IF NVL(pEmpresa,'') <> '' AND NVL(pNumCte,'') <> ''  AND NVL(pNumCelular,'') <> '' AND NVL(pCarrier,'') <> '' AND NVL(pTipoTelefono,'') <> '' AND NVL(pUsuario,'') <> '' THEN
				
				SELECT clave
				INTO sCarrier
				FROM bdinteg:"informix".si_catcompaniacita
				WHERE clave = pCarrier;
				
				IF dbinfo ("sqlca.sqlerrd2") = 0 then-- No hay informacion
					LET cCodRet = '001289';
					RETURN cCodRet,NVL(cNumCte,''),NVL(cNombre,''),NVL(cTelefono,''),NVL(sCarrier,''),NVL(sCofetel,'');
				END IF;

				SELECT numcte
				INTO cNumCte
				FROM bdinteg:"informix".si_cliente
				WHERE empresa = pEmpresa 
				AND numcte = pNumCte;

				IF dbinfo ("sqlca.sqlerrd2") = 0 then-- No hay informacion
					LET cCodRet = '001289';
					RETURN cCodRet,NVL(cNumCte,''),NVL(cNombre,''),NVL(cTelefono,''),NVL(sCarrier,''),NVL(sCofetel,'');
				END IF;
				
				IF (SELECT count(telefono) FROM bdinteg:"informix".si_telefonos WHERE telefono = pNumCelular AND verificado = 'V')> 0 THEN									
					
					IF (SELECT count(numcte) FROM bdinteg:"informix".si_telefonos WHERE telefono = pNumCelular AND verificado = 'V' AND numcte <> cNumCte) > 0 THEN
						
						UPDATE bdinteg:"informix".si_telefonos SET verificado= 'F' WHERE telefono = pNumCelular AND verificado = 'V' AND status_tel = 'A' AND numcte <> cNumCte;
						UPDATE bdinteg:"informix".si_telefonos_actual SET cofetel = 'F' WHERE telefono = pNumCelular AND cofetel = 'V' AND status_tel = 'A' AND numcte <> cNumCte;
						
						SELECT max(secuencia)
						INTO sSecuencia
						FROM bdinteg:"informix".si_telefonos
						WHERE numcte = pNumCte;
					
						IF NVL(sSecuencia,'') = '' THEN 
							LET sSecuencia = 0;
						END IF;

						LET sSecuencia = sSecuencia + 1;
						
						IF (SELECT count(numcte) FROM bdinteg:"informix".si_telefonos WHERE telefono = pNumCelular AND verificado = 'V' AND numcte = cNumCte) > 0	 THEN
													
							UPDATE bdinteg:"informix".si_telefonos SET
							empresa = pEmpresa,telefono = pNumCelular,tipo_tel = pTipoTelefono,
							extension = '',carrier = pCarrier,canal = 1,contacto = 0,cofetel = '',
							fecha_hora = CURRENT,user_insert = pUsuario WHERE telefono = pNumCelular  AND status_tel = 'A' AND verificado = 'V' AND numcte = cNumCte;
							
							UPDATE bdinteg:"informix".si_telefonos_actual SET
							empresa = pEmpresa,telefono = pNumCelular,tipo_tel = pTipoTelefono,
							extension = '',carrier = pCarrier,canal = 1,contacto = 0,cofetel = '',
							fecha_hora = CURRENT,user_insert = pUsuario WHERE telefono = pNumCelular  AND status_tel = 'A' AND cofetel = 'V' AND numcte = cNumCte;							
						ELSE
							INSERT INTO bdinteg:"informix".si_telefonos (empresa,numcte,telefono,tipo_tel,status_tel,secuencia,extension,carrier,canal,contacto,cofetel,fecha_hora,user_insert,verificado) 
							VALUES (pEmpresa,pNumCte,pNumCelular,pTipoTelefono,'A',sSecuencia,'',pCarrier,1,0,cCofetel,CURRENT,pUsuario, '');
						END IF;			
						RETURN cCodRet,NVL(cNumCte,''),NVL(cNombre,''),NVL(cTelefono,''),NVL(sCarrier,''),NVL(sCofetel,'');
					END IF;
				ELSE
						EXECUTE PROCEDURE bdinteg:"informix".sp_validatelefono(pEmpresa,'',pNumCelular,'') 
						INTO cCodRetSP,cValCasa, cValCelular, cValOficina;

						IF cValCelular = '1' THEN 
							LET cCofetel = 'V';
						ELIF cValCelular = '0' THEN
							LET cCodRet = '001380';
							RETURN cCodRet,NVL(cNumCte,''),NVL(cNombre,''),NVL(cTelefono,''),NVL(sCarrier,''),NVL(sCofetel,'');
						END IF;

						
						SELECT max(secuencia)
						INTO sSecuencia
						FROM bdinteg:"informix".si_telefonos
						WHERE numcte = pNumCte;
					
						IF NVL(sSecuencia,'') = '' THEN 
							LET sSecuencia = 0;
						END IF;

						LET sSecuencia = sSecuencia + 1;
							
							IF(SELECT count(telefono) FROM bdinteg:"informix".si_telefonos WHERE numcte = pNumCte AND tipo_tel = pTipoTelefono AND status_tel = 'A') > 0 THEN
								UPDATE bdinteg:"informix".si_telefonos SET
								empresa = pEmpresa,telefono = pNumCelular,tipo_tel = pTipoTelefono,
								extension = '',carrier = pCarrier,canal = 1,contacto = 0,cofetel = '',
								fecha_hora = CURRENT,user_insert = pUsuario, verificado = '' WHERE numcte = pNumCte AND tipo_tel = pTipoTelefono AND status_tel = 'A';
								
								UPDATE bdinteg:"informix".si_telefonos_actual SET
								empresa = pEmpresa,telefono = pNumCelular,tipo_tel = pTipoTelefono,
								extension = '',carrier = pCarrier,canal = 1,contacto = 0,cofetel = '',
								fecha_hora = CURRENT,user_insert = pUsuario WHERE numcte = pNumCte AND tipo_tel = pTipoTelefono AND status_tel = 'A';
							ELSE
								INSERT INTO bdinteg:"informix".si_telefonos (empresa,numcte,telefono,tipo_tel,status_tel,secuencia,extension,carrier,canal,contacto,cofetel,fecha_hora,user_insert,verificado) 
								VALUES (pEmpresa,pNumCte,pNumCelular,pTipoTelefono,'A',sSecuencia,'',pCarrier,1,0,cCofetel,CURRENT,pUsuario,'');
							END IF;			
				END IF;
		ELSE
			LET cCodRet = '000051';
		END IF;
	ELIF pOpcion = '2' Then
		IF NVL(pNumCte,'') <> '' AND NVL(pTipoTelefono,'')<>'' THEN

			SELECT numcte, TRIM (TRIM(nombre1) ||' '|| TRIM(nombre2)) ||' '|| TRIM(TRIM(apell_paterno) || ' ' || TRIM(apell_materno))
			INTO cNumCte, cNombre
			FROM bdinteg:"informix".si_cliente
			WHERE numcte = pNumCte;

			IF dbinfo ("sqlca.sqlerrd2") = 0 then-- No hay informacion
				LET cCodRet = '001289';
				RETURN cCodRet,NVL(cNumCte,''),NVL(cNombre,''),NVL(cTelefono,''),NVL(sCarrier,''),NVL(sCofetel,'');
			END IF;

			SELECT telefono, carrier,cofetel
			INTO cTelefono, sCarrier, sCofetel
			FROM bdinteg:"informix".si_telefonos
			WHERE tipo_tel = pTipoTelefono
			AND numcte = pNumCte
			AND status_tel = 'A'
			AND secuencia = (SELECT MAX(Secuencia)			
			FROM bdinteg:"informix".si_telefonos
			WHERE tipo_tel = pTipoTelefono
			AND numcte = pNumCte); 						
		ELSE
			LET cCodRet = '000051';
		END IF;
	END IF;
RETURN cCodRet,NVL(cNumCte,''),NVL(cNombre,''),NVL(cTelefono,''),NVL(sCarrier,''),NVL(sCofetel,'');

END
END PROCEDURE
DOCUMENT
'Folio: 255.1 - RQM 10 610-4 Incluir cambios finales al servicio de Portabilidad de Nomina en Sucursales',
'Autor: Bryan Limon',
'BD: bdinteg/ Central',
'Fecha: 25/07/2017',
'Descripcion: se crea procedimiento insertar el telefono y validar la compaÃ±ia.';

CREATE PROCEDURE "informix".direccionbeneficiario2( cEmpresa      CHAR(3),
                                                   cNumcte       CHAR(20),
                                                   cNumcteBenef  CHAR(20),									   
                                                   sOperador     CHAR(10),
                                                   dFechaSistema DATE )
RETURNING CHAR(5),CHAR(1);

    --*************************************************************************
    --| Procedimiento   : direccionbeneficiario
    --| VersiÃ³n         : 1.0
    --| Creado por      : Martha Aguirre
    --| Fecha creacion  : Junio de 2010
    --| DescripciÃ³n     : Guarda la direcciÃ³n del beneficiario del cliente
    --|					: cuando Ã©ste vive en el mismo domicilio del cte.
    --*************************************************************************

    -- // DECLARACION DE VARIABLES
    DEFINE cCodret CHAR(5);
    DEFINE iSecCte INTEGER;
    DEFINE cCalle CHAR (40);
    DEFINE cColonia CHAR (60);
    DEFINE cEntreCalles CHAR (40);
    DEFINE cPais CHAR(3);
    DEFINE cEstado CHAR(2);
    DEFINE cCiudad CHAR(3);
    DEFINE cMunicipio CHAR(5);
    DEFINE cCodPostal CHAR (5);
    DEFINE cApartPostal CHAR (11);
    DEFINE iTipoTel1 SMALLINT;
    DEFINE cTel1 CHAR(13);
    DEFINE iTipoTel2 SMALLINT;
    DEFINE cTel2 CHAR(13);
    DEFINE iTipoTel3 SMALLINT;
    DEFINE cTel3 CHAR(13);
    DEFINE cExtension CHAR(5);
    DEFINE cEdoInegi CHAR (5);
    DEFINE cMunicipioInegi CHAR(3);
    DEFINE cLocalidadInegi CHAR(4);
    DEFINE sNumCiudad SMALLINT;
    DEFINE cNumeroExtCalle CHAR (10);
    DEFINE cNumeroIntCalle CHAR (10);
    DEFINE cDepartamento CHAR (6);
    DEFINE iNumeroCalle INTEGER;
    DEFINE iNumeroColonia INTEGER;
    DEFINE cPuntoCardinal CHAR(1);
    DEFINE cUnidHabit CHAR (1);
    DEFINE sManzana SMALLINT;
    DEFINE sOtros SMALLINT;
    DEFINE sAndador SMALLINT;
    DEFINE sEtapa SMALLINT;
    DEFINE sLote SMALLINT;
    DEFINE sEdificio SMALLINT;
    DEFINE sEntrada SMALLINT;
    DEFINE cObservaciones CHAR(80);
    DEFINE cIndCofeteltel1 CHAR (1);
    DEFINE cIndCofeteltel2 CHAR (1);
    DEFINE cIndCofeteltel3 CHAR (1);
    DEFINE cTipoCteBenef CHAR(1);
    DEFINE vCanal SMALLINT;
    DEFINE vTipoTel SMALLINT;
    DEFINE iCarrier SMALLINT;
    DEFINE v_CodRetTel CHAR(5);
    
    -- // INICIALIZACIÃ¿N DE VARIABLES
    LET cCodret = '00000';
    LET iSecCte = 0;
    LET cCalle = '';
    LET cColonia = '';
    LET cEntreCalles = '';
    LET cPais = '';
    LET cEstado = '';
    LET cCiudad = '';
    LET cMunicipio = '';
    LET cCodPostal = '';
    LET cApartPostal = '';
    LET iTipoTel1 = 0;
    LET cTel1 = '';
    LET iTipoTel2 = 0;
    LET cTel2 = '';
    LET iTipoTel3 = 0;
    LET cTel3 = '';
    LET cExtension = '';
    LET cEdoInegi = '';
    LET cMunicipioInegi = '';
    LET cLocalidadInegi = '';
    LET sNumCiudad = 0;
    LET cNumeroExtCalle = '';
    LET cNumeroIntCalle = '';
    LET cDepartamento = '';
    LET iNumeroCalle = 0;
    LET iNumeroColonia = 0;
    LET cPuntoCardinal = '';
    LET cUnidHabit = '';
    LET sManzana = 0;
    LET sOtros = 0;
    LET sAndador = 0;
    LET sEtapa = 0;
    LET sLote = 0;
    LET sEdificio = 0;
    LET sEntrada = 0;
    LET cObservaciones = '';
    LET cIndCofeteltel1 = '';
    LET cIndCofeteltel2 = '';
    LET cIndCofeteltel3 = '';
    
    LET vCanal = 1;
    LET vTipoTel = 0;
    LET iCarrier = 0;
    LET v_CodRetTel = '';
    LET cTipoCteBenef='';
	--SET DEBUG FILE TO '/informix/tmp/direccionbeneficiario.sql';
	--TRACE ON;

    BEGIN

      --Validar si el cliente cumple con la longitun indicada
        IF  (length(cNumcteBenef) > 9) THEN
            
              LET cNumcteBenef = SUBSTR(cNumcteBenef,0,9);
                     
        END IF;
	--FIN DEL BLOQUE

	IF (cEmpresa = '' or cNumcte = '' OR cNumcteBenef = '' or sOperador = '') THEN
	
		LET cCodret = '00001'; -- Parametros en blanco
		RETURN cCodret,cTipoCteBenef;
				
	END IF;

    IF EXISTS ( SELECT 1 
                  FROM bdinteg:si_cliente 
                 WHERE empresa = cEmpresa 
                   AND numcte = cNumcte ) THEN
        /*        
        SELECT MAX (secuencia) 
          INTO iSecCte 
          FROM bdinteg:si_direcciones 
         WHERE numcte = cNumcte 
           AND tipo_dir = 1;
        */
           
      
        SELECT tipo_cliente 
          INTO cTipoCteBenef FROM si_cliente
         WHERE numcte = cNumcteBenef;
        
	IF cTipoCteBenef  ='2' THEN     
			SELECT dir.calle, dir.colonia, dir.entre_calles, dir.pais, dir.estado, dir.ciudad, dir.municipio, dir.cod_postal, dir.apart_postal,
				   tel1.tipo_tel, tel1.telefono, 
				   --tel2.tipo_tel, tel2.telefono, 
					--tel3.tipo_tel, tel3.telefono, tel3.extension, 
				   dir.estado_inegi,dir.municipio_inegi, dir.localidad_inegi, dir.numerociudad, dir.numeroextcalle, dir.numerointcalle, dir.departamento, 
				   dir.numerocalle, dir.numerocolonia, dir.puntocardinal, dir.unidadhabitac, dir.manzana, dir.otros, dir.andador, dir.etapa, dir.lote, 
				   dir.edificio, dir.entrada, dir.observaciones, dir.ind_cofeteltel1, dir.ind_cofeteltel2, dir.ind_cofeteltel3 
			  INTO cCalle, cColonia, cEntreCalles, cPais, cEstado, cCiudad, cMunicipio, cCodPostal, cApartPostal,
				   iTipoTel1, cTel1, 
				   --iTipoTel2, cTel2,
				  -- iTipoTel3, cTel3, cExtension, 
				   cEdoInegi, cMunicipioInegi, cLocalidadInegi, sNumCiudad, cNumeroExtCalle, cNumeroIntCalle, cDepartamento,
				   iNumeroCalle, iNumeroColonia, cPuntoCardinal, cUnidHabit, sManzana, sOtros, sAndador, sEtapa, sLote,
				   sEdificio, sEntrada, cObservaciones, cIndCofeteltel1, cIndCofeteltel2, cIndCofeteltel3
			  FROM si_direcciones_actual dir
			  LEFT OUTER JOIN si_telefonos_actual tel1 ON ( tel1.numcte = dir.numcte AND tel1.tipo_tel = 1 )
			  LEFT OUTER JOIN si_telefonos_actual tel2 ON ( tel2.numcte = dir.numcte AND tel2.tipo_tel = 2 )
			  LEFT OUTER JOIN si_telefonos_actual tel3 ON ( tel3.numcte = dir.numcte AND tel3.tipo_tel = 3 )
			 WHERE dir.numcte = cNumcte
			   AND dir.tipo_dir = 1;

    /*ELSE
    
         SELECT dir.calle, dir.colonia, dir.entre_calles, dir.pais, dir.estado, dir.ciudad, dir.municipio, dir.cod_postal, dir.apart_postal,
               tel1.tipo_tel, tel1.telefono, tel2.tipo_tel, tel2.telefono, tel3.tipo_tel, tel3.telefono, tel3.extension, dir.estado_inegi,
               dir.municipio_inegi, dir.localidad_inegi, dir.numerociudad, dir.numeroextcalle, dir.numerointcalle, dir.departamento, 
               dir.numerocalle, dir.numerocolonia, dir.puntocardinal, dir.unidadhabitac, dir.manzana, dir.otros, dir.andador, dir.etapa, dir.lote, 
               dir.edificio, dir.entrada, dir.observaciones, dir.ind_cofeteltel1, dir.ind_cofeteltel2, dir.ind_cofeteltel3 
          INTO cCalle, cColonia, cEntreCalles, cPais, cEstado, cCiudad, cMunicipio, cCodPostal, cApartPostal,
               iTipoTel1, cTel1, iTipoTel2, cTel2, iTipoTel3, cTel3, cExtension, cEdoInegi,
               cMunicipioInegi, cLocalidadInegi, sNumCiudad, cNumeroExtCalle, cNumeroIntCalle, cDepartamento,
               iNumeroCalle, iNumeroColonia, cPuntoCardinal, cUnidHabit, sManzana, sOtros, sAndador, sEtapa, sLote,
               sEdificio, sEntrada, cObservaciones, cIndCofeteltel1, cIndCofeteltel2, cIndCofeteltel3
          FROM si_direcciones_actual dir
          LEFT OUTER JOIN si_telefonos_actual tel1 ON ( tel1.numcte = dir.numcte AND tel1.tipo_tel = 1 )
          LEFT OUTER JOIN si_telefonos_actual tel2 ON ( tel2.numcte = dir.numcte AND tel2.tipo_tel = 2 )
          LEFT OUTER JOIN si_telefonos_actual tel3 ON ( tel3.numcte = dir.numcte AND tel3.tipo_tel = 3 )
         WHERE dir.numcte = cNumcte
           AND dir.tipo_dir = 1;*/
    
  
		   
			--Validar maxima secuencia de direcciones
			--Validar todo de la sd_direcciones_actual

			IF EXISTS ( SELECT unique 1 
						FROM bdinteg:si_direcciones_actual
						WHERE numcte = cNumcteBenef) THEN
						   
				SELECT MAX (secuencia) 
				INTO iSecCte 
				FROM bdinteg:si_direcciones_actual 
				WHERE numcte = cNumcteBenef; 
				   
				LET iSecCte = iSecCte + 1;
			ELSE
				LET iSecCte = 1;
			END IF;
		
			--Validar maxima secuencia de direcciones
			--Validar todo de la sd_direcciones_actual

			INSERT INTO bdinteg:si_direcciones
			(numcte,secuencia,tipo_dir,calle,colonia,entre_calles,
			pais,estado,ciudad,municipio,cod_postal,apart_postal,
			/* tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,telefono3,extension, */
			estado_inegi,municipio_inegi,localidad_inegi,
			numerociudad,numeroextcalle,numerointcalle,departamento,
			numerocalle,numerocolonia,puntocardinal,unidadhabitac,
			manzana,otros,andador,etapa,lote,edificio,entrada,
			observaciones, ind_cofeteltel1, ind_cofeteltel2,
			ind_cofeteltel3,user_insert,fecha_insert)
			VALUES
			(cNumcteBenef, iSecCte,'1', cCalle, cColonia, cEntreCalles,
			cPais,cEstado, cCiudad, cMunicipio, cCodPostal,cApartPostal,
			/* cTipoTel1, cTel1, cTipoTel2, cTel2, cTipoTel3, cTel3, cExtension, */
			cEdoInegi, cMunicipioInegi, cLocalidadInegi,
			sNumCiudad, cNumeroExtCalle, cNumeroIntCalle, cDepartamento,
			iNumeroCalle, iNumeroColonia, cPuntoCardinal, cUnidHabit,
			sManzana, sOtros, sAndador, sEtapa, sLote, sEdificio, sEntrada,
			cObservaciones, cIndCofeteltel1, cIndCofeteltel2,
			cIndCofeteltel3, sOperador, dFechaSistema);	
          
  

			IF ( ( iTipoTel1 is not null AND iTipoTel1 > 0 ) AND ( cTel1 is not null AND cTel1 <> '' ) ) THEN
				LET vTipoTel = 1;
				LET iCarrier = 0;
				
				CALL sp_registra_telefonos(cEmpresa, cNumcteBenef, cTel1, vTipoTel, cExtension, iCarrier, vCanal, sOperador)
				RETURNING v_CodRetTel;
			END IF;
        
			IF ( ( iTipoTel2 is not null AND iTipoTel2 > 00 ) AND ( cTel2 is not null AND cTel2 <> '' ) ) THEN
				LET vTipoTel = 2;
				
				SELECT carrier
				  INTO iCarrier
				  FROM si_telefonos_actual
				 WHERE numcte = cNumcte
				   AND tipo_tel = 2;
				   
				IF iCarrier is null THEN
					LET iCarrier = 0;
				END IF;
				  
				/*CALL sp_registra_telefonos(cEmpresa, cNumcteBenef, cTel2, vTipoTel, cExtension, iCarrier, vCanal, sOperador)
				RETURNING v_CodRetTel;*/
			END IF;
        
			IF ( ( iTipoTel3 is not null AND iTipoTel3 > 0 ) AND ( cTel3 is not null AND cTel3 <> '' ) ) THEN
				LET vTipoTel = 3;
				LET iCarrier = 0;
				
				CALL sp_registra_telefonos(cEmpresa, cNumcteBenef, cTel3, vTipoTel, cExtension, iCarrier, vCanal, sOperador)
				RETURNING v_CodRetTel;
			END IF;
	 END IF;
    ELSE
        LET cCodret = '00001'; -- No existe el cliente titular;
    END IF;
    
    		RETURN cCodret,cTipoCteBenef;

    END;
  
  
END PROCEDURE;