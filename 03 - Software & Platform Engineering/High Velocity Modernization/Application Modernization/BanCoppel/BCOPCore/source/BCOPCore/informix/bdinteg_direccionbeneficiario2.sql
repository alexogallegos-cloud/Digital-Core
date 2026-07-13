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