CREATE PROCEDURE "informix".sp_telactualizartelefonoscliente()
RETURNING CHAR(6), INTEGER;
-- execute PROCEDURE "informix".sp_telactualizartelefonoscliente();
	--Declaracion de Variables  Si_Direcciones
	DEFINE   iNumcte        	CHAR(20);
	DEFINE   iSecuencia   		INTEGER;
	DEFINE   iTipo_dir      	CHAR(1);
	DEFINE   cCalle         	CHAR(40);
	DEFINE   cColonia      		CHAR(60);
	DEFINE   cEntre_calles  	CHAR(40);
	DEFINE   cPais          	CHAR(3);
	DEFINE   cEstado        	CHAR(2);
	DEFINE   cCiudad        	CHAR(3);
	DEFINE   cMunicipio     	CHAR(5);
	DEFINE   cCod_postal    	CHAR(5);
	DEFINE   cApart_postal  	CHAR(11);
	DEFINE   cTipo_telef1   	CHAR(1);
	DEFINE   cTelefono1     	CHAR(13);
	DEFINE   cTipo_telef2   	CHAR(1);
	DEFINE   cTelefono2     	CHAR(13);
	DEFINE   cTipo_telef3      	CHAR(1);
	DEFINE   cTelefono3        	CHAR(13);
	DEFINE   iExtension         CHAR(5);
	DEFINE   cEstado_inegi      CHAR(2);
	DEFINE   cMunicipio_inegi   CHAR(3);
	DEFINE   cLocalidad_inegi   CHAR(4);
	DEFINE   cNumerociudad     	smallint;
	DEFINE   cNumeroextcalle    CHAR(10);
	DEFINE   cNumerointcalle    CHAR(10);
	DEFINE   cDepartamento      CHAR(6);
	DEFINE   cNumerocalle       CHAR(10);
	DEFINE   cNumerocolonia     INTEGER;
	DEFINE   cPuntocardinal     CHAR(1);
	DEFINE   cUnidadhabitac     CHAR(1);
	DEFINE   iManzana           smallint;
	DEFINE   iOtros             smallint;
	DEFINE   iAndador           smallint;
	DEFINE   iEtapa             smallint;
	DEFINE   iLote              smallint;
	DEFINE   iEdIFicio          smallint;
	DEFINE   iEntrada           smallint;
	DEFINE   cObservaciones    	CHAR(80);
	DEFINE   cUser_insert       CHAR(8);
	DEFINE   dFecha_insert      DATE;

   --Declaracion  de Variables CB_GESTIONES_TELEFONICAS
	DEFINE   cNum_Sol       CHAR(20); 
	DEFINE   cNumcTel       CHAR(20);
	DEFINE   cTel           CHAR(10);
	DEFINE   cTipo_tel      CHAR(10);
	DEFINE   sSecuencia     INTEGER;

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
	DEFINE  dFechaHoy	       	DATE;
	DEFINE  MAXSecuencia        CHAR(10); 
	DEFINE  MAXSecuencia2      	CHAR(10); 
	DEFINE  iCont			    INTEGER;
	DEFINE  cCodret			   	CHAR(6);
	DEFINE  cCodret1		  	CHAR(6);
	DEFINE  iSqlErr		  		INTEGER;
	DEFINE  iContador           INTEGER;
	
	DEFINE  cCodret2      CHAR(6);
	DEFINE  cBandera1     CHAR(1);  
	DEFINE  cBandera2     CHAR(1);
	DEFINE  cBandera3     CHAR(1);
	
	DEFINE  cCodret3      CHAR(6);

	LET iCont 		= 0;
	LET cCodret 	= "000000";
	LET iSqlErr	    = 0;
    LET  iContador  = 0;

-- SET DEBUG FILE TO  "sp_telActualizarTelefonosCliente.out";
-- TRACE ON;
 
BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodret = iSqlErr;
			RETURN cCodret,iContador;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	
	SELECT fecha_hoy 
	INTO dFechaHoy
	FROM bdicred:sd_fechas
	WHERE empresa = '001';

	FOREACH

		SELECT num_solicitud, numcte, telefono, tipo_telefono ,secuencia
		INTO cNum_sol, cNumcTel, cTel, cTipo_tel ,sSecuencia
		FROM Bdicobranza:cb_gestion_telefonica
		WHERE status = 'NP'

		--Verifica Existe el Cliente en Bdinteg:si_direcciones
		IF NOT EXISTS ( SELECT DISTINCT numcte  FROM Bdinteg:si_direcciones WHERE  numcte = cNumcTel ) THEN
			LET iCont = 2;
			UPDATE Bdicobranza:cb_gestion_telefonica SET status = 'ER'  WHERE num_solicitud = cNum_sol and numcte = cNumcTel and secuencia = sSecuencia;			
			CONTINUE FOREACH;
		END IF;
		
		--LET iContador = iContador + 1;
		
		-- BANDERA PARA LA VALIDACION DE LA EJECUCION DEL PROCESO
		LET iCont = 1;

		IF cTipo_tel  = 'P'  THEN
		
			SELECT MAX(secuencia)
			INTO MAXSecuencia
			FROM Bdinteg:si_direcciones
			WHERE numcte =  cNumcTel     --'000018538' 
			AND tipo_dir = 1;

			SELECT numcte, secuencia, tipo_dir, calle, colonia, municipio, entre_calles, pais, estado, ciudad, cod_postal,
				   /*tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, extension,*/ estado_inegi, municipio_inegi,
			       localidad_inegi, numerociudad, numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, 
				   puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones,
				   user_insert, fecha_insert
			INTO iNumcte,iSecuencia, iTipo_dir,cCalle, cColonia, cMunicipio, cEntre_calles, cPais , cEstado, cCiudad, cCod_postal,
			     /*cTipo_telef1, cTelefono1, cTipo_telef2, cTelefono2, cTipo_telef3, cTelefono3, iExtension,*/ cEstado_inegi, cMunicipio_inegi,
				 cLocalidad_inegi, cNumerociudad, cNumeroextcalle, cNumerointcalle, cDepartamento, cNumerocalle, cNumerocolonia,
				 cPuntocardinal, cUnidadhabitac, iManzana, iOtros , iAndador, iEtapa, iLote, iEdificio, iEntrada, cObservaciones,
				 cUser_insert, dFecha_insert
			FROM Bdinteg:si_direcciones
			WHERE numcte = cNumcTel         --'000018538' 
			AND secuencia = MAXSecuencia   --168 
			AND tipo_dir = 1;
			
			select  tipo_tel,telefono 
			into  cTipo_telef1, cTelefono1
			from bdinteg:si_telefonos 
			where numcte = iNumcte 
				and tipo_tel = 1 and secuencia = (select max(secuencia) from bdinteg:si_telefonos 
													where numcte = iNumcte and tipo_tel = 1);
										
			select  tipo_tel,telefono 
			into  cTipo_telef2, cTelefono2
			from bdinteg:si_telefonos 
			where numcte = iNumcte 
				and tipo_tel = 2 and secuencia = (select max(secuencia) from bdinteg:si_telefonos 
													where numcte = iNumcte and tipo_tel = 2);
												
			select  tipo_tel,telefono ,extension
			into  cTipo_telef3, cTelefono3, iExtension
			from bdinteg:si_telefonos 
			where numcte = iNumcte 
				and tipo_tel = 3 and secuencia = (select max(secuencia) from bdinteg:si_telefonos 
													where numcte = iNumcte and tipo_tel = 3);
		
			EXECUTE PROCEDURE Bdinteg:direcciones('001', 'A', iNumcte, iSecuencia, iTipo_dir, cCalle, cColonia, cMunicipio,
												  cEntre_calles, cPais, cEstado, cCiudad, cCod_postal, 'P', cTel, cTipo_telef2,
												  cTelefono2, cTipo_telef3, cTelefono3, iExtension, cEstado_inegi, cMunicipio_inegi,
												  cLocalidad_inegi, cNumerociudad, cNumeroextcalle, cNumerointcalle, cDepartamento,
												  cNumerocalle, cNumerocolonia, cPuntocardinal, cUnidadhabitac, iManzana, iOtros,
												  iAndador, iEtapa, iLote, iEdificio, iEntrada, cObservaciones, cUser_insert, dFecha_insert, null)
			INTO cCodret1;
			IF cCodret1 = '000' then
				EXECUTE PROCEDURE bdinteg:sp_validatelefono('001',cTel,cTelefono2,cTelefono3)
				INTO cCodret2, cBandera1,cBandera2,cBandera3;
				EXECUTE PROCEDURE bdinteg:sp_actvalidacioncofetel('001',iNumcte,cBandera1,cBandera2,cBandera3,iTipo_dir,1)
				INTO cCodret3;
			ELSE 
				LET iCont = 3;
            END IF;
			
		ELIF  cTipo_tel  = 'C'  THEN
		
			SELECT MAX(secuencia)
			INTO MAXSecuencia
			FROM Bdinteg:si_direcciones
			WHERE numcte =  cNumcTel     --'000018538' 
			AND tipo_dir = 1;

			SELECT numcte, secuencia, tipo_dir, calle, colonia, municipio, entre_calles, pais, estado, ciudad, cod_postal,
				/*   tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, extension,*/ estado_inegi, municipio_inegi,
			       localidad_inegi, numerociudad, numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, 
				   puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones,
				   user_insert, fecha_insert
			INTO iNumcte,iSecuencia, iTipo_dir,cCalle, cColonia, cMunicipio, cEntre_calles, cPais , cEstado, cCiudad, cCod_postal,
			    /* cTipo_telef1, cTelefono1, cTipo_telef2, cTelefono2, cTipo_telef3, cTelefono3, iExtension,*/ cEstado_inegi, cMunicipio_inegi,
				 cLocalidad_inegi, cNumerociudad, cNumeroextcalle, cNumerointcalle, cDepartamento, cNumerocalle, cNumerocolonia,
				 cPuntocardinal, cUnidadhabitac, iManzana, iOtros , iAndador, iEtapa, iLote, iEdIFicio, iEntrada, cObservaciones,
				 cUser_insert, dFecha_insert
			FROM Bdinteg:si_direcciones
			WHERE numcte = cNumcTel         --'000018538' 
			AND secuencia = MAXSecuencia   --168 
			AND tipo_dir = 1;
			
				select  tipo_tel,telefono 
			into  cTipo_telef1, cTelefono1
			from bdinteg:si_telefonos 
			where numcte = iNumcte 
				and tipo_tel = 1 and secuencia = (select max(secuencia) from bdinteg:si_telefonos 
													where numcte = iNumcte and tipo_tel = 1);
										
			select  tipo_tel,telefono 
			into  cTipo_telef2, cTelefono2
			from bdinteg:si_telefonos 
			where numcte = iNumcte 
				and tipo_tel = 2 and secuencia = (select max(secuencia) from bdinteg:si_telefonos 
													where numcte = iNumcte and tipo_tel = 2);
												
			select  tipo_tel,telefono ,extension
			into  cTipo_telef3, cTelefono3, iExtension
			from bdinteg:si_telefonos 
			where numcte = iNumcte 
				and tipo_tel = 3 and secuencia = (select max(secuencia) from bdinteg:si_telefonos 
													where numcte = iNumcte and tipo_tel = 3);
													
			EXECUTE PROCEDURE Bdinteg:direcciones('001' , 'A' ,iNumcte,  iSecuencia,   iTipo_dir, cCalle, cColonia, cMunicipio,
                                        		  cEntre_calles ,cPais  ,cEstado  ,cCiudad      ,cCod_postal , cTipo_telef1 ,cTelefono1,
												  'C' ,  cTel , cTipo_telef3 , cTelefono3 ,iExtension   ,cEstado_inegi     ,cMunicipio_inegi,
												  cLocalidad_inegi , cNumerociudad ,cNumeroextcalle ,cNumerointcalle  ,cDepartamento ,cNumerocalle,
												  cNumerocolonia ,cPuntocardinal ,cUnidadhabitac ,iManzana ,iOtros        ,iAndador   ,iEtapa,
												  iLote   ,iEdIFicio ,iEntrada   ,cObservaciones  ,cUser_insert   ,dFecha_insert ,null)
			INTO cCodret1;
            IF cCodret1 = '000' THEN		
				EXECUTE PROCEDURE bdinteg:sp_validatelefono('001',cTelefono1,cTel,cTelefono3)
				INTO cCodret2, cBandera1,cBandera2,cBandera3;
				EXECUTE PROCEDURE bdinteg:sp_actvalidacioncofetel('001',iNumcte,cBandera1,cBandera2,cBandera3,iTipo_dir,1)
				INTO cCodret3;
			ELSE
			   LET iCont = 3;
			END IF;
		ELIF  cTipo_tel  = 'A'  THEN
		
			SELECT MAX(secuencia)
			INTO MAXSecuencia
			FROM Bdinteg:si_direcciones
			WHERE numcte =  cNumcTel     --'000018538' 
			AND tipo_dir = 1;

			SELECT numcte, secuencia, tipo_dir, calle, colonia, municipio, entre_calles, pais, estado, ciudad, cod_postal,
				 /*  tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, extension,*/ estado_inegi, municipio_inegi,
			       localidad_inegi, numerociudad, numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, 
				   puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones,
				   user_insert, fecha_insert
			INTO iNumcte,iSecuencia, iTipo_dir,cCalle, cColonia, cMunicipio, cEntre_calles, cPais , cEstado, cCiudad, cCod_postal,
			     /*cTipo_telef1, cTelefono1, cTipo_telef2, cTelefono2, cTipo_telef3, cTelefono3, iExtension,*/ cEstado_inegi, cMunicipio_inegi,
				 cLocalidad_inegi, cNumerociudad, cNumeroextcalle, cNumerointcalle, cDepartamento, cNumerocalle, cNumerocolonia,
				 cPuntocardinal, cUnidadhabitac, iManzana, iOtros , iAndador, iEtapa, iLote, iEdificio, iEntrada, cObservaciones,
				 cUser_insert, dFecha_insert
			FROM Bdinteg:si_direcciones
			WHERE numcte = cNumcTel         --'000018538' 
			AND secuencia = MAXSecuencia    --168 
			AND tipo_dir = 1;	
		
			select  tipo_tel,telefono 
			into  cTipo_telef1, cTelefono1
			from bdinteg:si_telefonos 
			where numcte = iNumcte 
				and tipo_tel = 1 and secuencia = (select max(secuencia) from bdinteg:si_telefonos 
													where numcte = iNumcte and tipo_tel = 1);
										
			select  tipo_tel,telefono 
			into  cTipo_telef2, cTelefono2
			from bdinteg:si_telefonos 
			where numcte = iNumcte 
				and tipo_tel = 2 and secuencia = (select max(secuencia) from bdinteg:si_telefonos 
													where numcte = iNumcte and tipo_tel = 2);
												
			select  tipo_tel,telefono ,extension
			into  cTipo_telef3, cTelefono3, iExtension
			from bdinteg:si_telefonos 
			where numcte = iNumcte 
				and tipo_tel = 3 and secuencia = (select max(secuencia) from bdinteg:si_telefonos 
													where numcte = iNumcte and tipo_tel = 3);
		    
		
			IF cTelefono1  =  ''  THEN 
				EXECUTE PROCEDURE Bdinteg:direcciones('001' , 'A' , iNumcte,  iSecuencia,   iTipo_dir, cCalle, cColonia, cMunicipio,
                                 				      cEntre_calles ,cPais  ,cEstado  ,cCiudad      ,cCod_postal , 'P' ,cTel ,cTipo_telef2 ,
													  cTelefono2 ,cTipo_telef3 , cTelefono3 ,iExtension   ,cEstado_inegi     ,cMunicipio_inegi,
													  cLocalidad_inegi , cNumerociudad ,cNumeroextcalle ,cNumerointcalle  ,cDepartamento,
													  cNumerocalle ,cNumerocolonia ,cPuntocardinal ,cUnidadhabitac ,iManzana ,iOtros,
													  iAndador ,iEtapa ,iLote,iEdIFicio,iEntrada,cObservaciones,cUser_insert,dFecha_insert  ,null)
				INTO cCodret1;
				
            IF cCodret1 ='000' THEN
				EXECUTE PROCEDURE bdinteg:sp_validatelefono('001',cTel,cTelefono2,cTelefono3)
				INTO cCodret2, cBandera1,cBandera2,cBandera3;
				EXECUTE PROCEDURE bdinteg:sp_actvalidacioncofetel('001',iNumcte,cBandera1,cBandera2,cBandera3,iTipo_dir,1)
				INTO cCodret3;
		    ELSE
			   LET iCont = 3;
			END IF;

			ELIF  cTelefono2  =  ''  THEN 
				EXECUTE PROCEDURE Bdinteg:direcciones('001' , 'A' ,iNumcte,  iSecuencia,   iTipo_dir, cCalle, cColonia, cMunicipio,
				                                      cEntre_calles ,cPais  ,cEstado ,cCiudad ,cCod_postal, cTipo_telef1 ,cTelefono1,'P', cTel,
													  cTipo_telef3 , cTelefono3 ,iExtension,cEstado_inegi,cMunicipio_inegi,cLocalidad_inegi,
													  cNumerociudad ,cNumeroextcalle,cNumerointcalle ,cDepartamento,cNumerocalle,cNumerocolonia,
													  cPuntocardinal ,cUnidadhabitac ,iManzana ,iOtros ,iAndador ,iEtapa ,iLote,iEdIFicio,
													  iEntrada ,cObservaciones  ,cUser_insert   ,dFecha_insert ,null)
				INTO cCodret1;

            IF cCodret1 ='000' THEN
				EXECUTE PROCEDURE bdinteg:sp_validatelefono('001',cTelefono1,cTel,cTelefono3)
				INTO cCodret2, cBandera1,cBandera2,cBandera3;
				EXECUTE PROCEDURE bdinteg:sp_actvalidacioncofetel('001',iNumcte,cBandera1,cBandera2,cBandera3,iTipo_dir,1)
				INTO cCodret3;
			ELSE
			   LET iCont = 3;
			END IF;

			ELIF  cTelefono3  =  ''  THEN 
				EXECUTE PROCEDURE Bdinteg:direcciones('001' , 'A'  ,iNumcte, iSecuencia, iTipo_dir, cCalle, cColonia, cMunicipio, cEntre_calles ,
				                                      cPais  ,cEstado ,cCiudad ,cCod_postal , cTipo_telef1 ,cTelefono1 ,cTipo_telef2, cTelefono2,
													  'P'  , cTel ,iExtension ,cEstado_inegi ,cMunicipio_inegi ,cLocalidad_inegi , cNumerociudad,
													  cNumeroextcalle,cNumerointcalle ,cDepartamento ,cNumerocalle ,cNumerocolonia ,cPuntocardinal,
													  cUnidadhabitac ,iManzana ,iOtros ,iAndador ,iEtapa ,iLote ,iEdIFicio ,iEntrada ,cObservaciones,
													  cUser_insert   ,dFecha_insert  ,null)
				INTO cCodret1;

            IF cCodret1 ='000' THEN
				EXECUTE PROCEDURE bdinteg:sp_validatelefono('001',cTelefono1,cTelefono2,cTel)
				INTO cCodret2, cBandera1,cBandera2,cBandera3;
				EXECUTE PROCEDURE bdinteg:sp_actvalidacioncofetel('001',iNumcte,cBandera1,cBandera2,cBandera3,iTipo_dir,1)
				INTO cCodret3;
			ELSE
			   LET iCont = 3;
			END IF;
			
			END IF
		END IF
		
		IF cTipo_tel = 'I' THEN

			SELECT MAX(secuencia)
			INTO MAXSecuencia
			FROM Bdinteg:si_direcciones
			WHERE numcte =  cNumcTel     --'000018538' 
			AND tipo_dir = 1;

			SELECT numcte, secuencia, tipo_dir, calle, colonia, municipio, entre_calles, pais, estado, ciudad, cod_postal,
				 /*  tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, extension, */estado_inegi, municipio_inegi,
			       localidad_inegi, numerociudad, numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, 
				   puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones,
				   user_insert, fecha_insert
			INTO iNumcte,iSecuencia, iTipo_dir,cCalle, cColonia, cMunicipio, cEntre_calles, cPais , cEstado, cCiudad, cCod_postal,
			     /*cTipo_telef1, cTelefono1, cTipo_telef2, cTelefono2, cTipo_telef3, cTelefono3, iExtension, */cEstado_inegi, cMunicipio_inegi,
				 cLocalidad_inegi, cNumerociudad, cNumeroextcalle, cNumerointcalle, cDepartamento, cNumerocalle, cNumerocolonia,
				 cPuntocardinal, cUnidadhabitac, iManzana, iOtros , iAndador, iEtapa, iLote, iEdIFicio, iEntrada, cObservaciones,
				 cUser_insert, dFecha_insert
			FROM Bdinteg:si_direcciones
			WHERE numcte = cNumcTel         --'000018538' 
			AND secuencia = MAXSecuencia   --168 
			AND tipo_dir = 1;	

				select  tipo_tel,telefono 
			into  cTipo_telef1, cTelefono1
			from bdinteg:si_telefonos 
			where numcte = iNumcte 
				and tipo_tel = 1 and secuencia = (select max(secuencia) from bdinteg:si_telefonos 
													where numcte = iNumcte and tipo_tel = 1);
										
			select  tipo_tel,telefono 
			into  cTipo_telef2, cTelefono2
			from bdinteg:si_telefonos 
			where numcte = iNumcte 
				and tipo_tel = 2 and secuencia = (select max(secuencia) from bdinteg:si_telefonos 
													where numcte = iNumcte and tipo_tel = 2);
												
			select  tipo_tel,telefono ,extension
			into  cTipo_telef3, cTelefono3, iExtension
			from bdinteg:si_telefonos 
			where numcte = iNumcte 
				and tipo_tel = 3 and secuencia = (select max(secuencia) from bdinteg:si_telefonos 
													where numcte = iNumcte and tipo_tel = 3);
		    

			IF cTel = cTelefono1 THEN 
				EXECUTE PROCEDURE Bdinteg:direcciones('001' , 'A' , iNumcte,  iSecuencia, iTipo_dir, cCalle, cColonia, cMunicipio, cEntre_calles ,cPais ,cEstado,
				                                      cCiudad ,cCod_postal ,' ',' ',cTipo_telef2 , cTelefono2 ,cTipo_telef3 ,cTelefono3,iExtension,
													  cEstado_inegi ,cMunicipio_inegi ,cLocalidad_inegi, cNumerociudad ,cNumeroextcalle ,cNumerointcalle,
													  cDepartamento ,cNumerocalle ,cNumerocolonia ,cPuntocardinal ,cUnidadhabitac ,iManzana ,iOtros,
													  iAndador ,iEtapa ,iLote ,iEdificio ,iEntrada ,cObservaciones ,cUser_insert ,dFecha_insert ,null)
				INTO cCodret1;
			ELIF cTel = cTelefono2 THEN 
				EXECUTE PROCEDURE Bdinteg:direcciones('001' , 'A' ,iNumcte, iSecuencia, iTipo_dir, cCalle, cColonia, cMunicipio, cEntre_calles,
				                                     cPais ,cEstado,cCiudad ,cCod_postal ,cTipo_telef1,cTelefono1,' ' ,' ' ,cTipo_telef3,
													 cTelefono3,iExtension ,cEstado_inegi ,cMunicipio_inegi ,cLocalidad_inegi, cNumerociudad,
													 cNumeroextcalle ,cNumerointcalle ,cDepartamento ,cNumerocalle ,cNumerocolonia ,cPuntocardinal,
													 cUnidadhabitac ,iManzana ,iOtros, iAndador,iEtapa,iLote,iEdIFicio ,iEntrada ,cObservaciones,
													 cUser_insert ,dFecha_insert  ,null)
				INTO cCodret1;
			ELIF cTel = cTelefono3 THEN 
				EXECUTE PROCEDURE Bdinteg:direcciones('001' , 'A' , iNumcte, iSecuencia, iTipo_dir, cCalle, cColonia, cMunicipio, cEntre_calles,
				                                     cPais ,cEstado ,cCiudad  ,cCod_postal ,cTipo_telef1,cTelefono1,cTipo_telef2,  cTelefono2,
													 ' ', ' ',iExtension ,cEstado_inegi ,cMunicipio_inegi ,cLocalidad_inegi, cNumerociudad,
													 cNumeroextcalle ,cNumerointcalle ,cDepartamento ,cNumerocalle ,cNumerocolonia ,cPuntocardinal,
													 cUnidadhabitac ,iManzana ,iOtros, iAndador,iEtapa,iLote,iEdIFicio ,iEntrada ,cObservaciones,
													 cUser_insert ,dFecha_insert ,null)
				INTO cCodret1;
			ELSE
				SELECT MAX(secuencia)
				INTO MAXSecuencia2
				FROM Bdinteg:si_direcciones
				WHERE numcte = cNumcTel --'000018538'
				AND tipo_dir = 2;
				
				IF MAXSecuencia2 IS NULL THEN
					LET iCont = 3;
					UPDATE Bdicobranza:cb_gestion_telefonica SET status = 'ER'  WHERE num_solicitud = cNum_sol and numcte = cNumcTel and secuencia = sSecuencia;			
					CONTINUE FOREACH;				
				END IF;

				SELECT numcte,secuencia,tipo_dir,calle,colonia,municipio,entre_calles,pais,estado,ciudad,cod_postal,/*tipo_telef1,telefono1,tipo_telef2,
				      telefono2,tipo_telef3,telefono3,extension,*/estado_inegi,municipio_inegi,localidad_inegi,numerociudad,numeroextcalle,
					  numerointcalle,departamento,numerocalle,numerocolonia,puntocardinal,unidadhabitac,manzana,otros,Andador,etapa,lote,edificio,
					  entrada,observaciones,user_insert,fecha_insert
				INTO iNumcte,iSecuencia, iTipo_dir,cCalle, cColonia, cMunicipio, cEntre_calles, cPais , cEstado, cCiudad,  cCod_postal, /*cTipo_telef1,
				     cTelefono1, cTipo_telef2, cTelefono2, cTipo_telef3, cTelefono3,*/ iExtension, cEstado_inegi, cMunicipio_inegi, cLocalidad_inegi,
					 cNumerociudad, cNumeroextcalle, cNumerointcalle, cDepartamento, cNumerocalle, cNumerocolonia, cPuntocardinal, cUnidadhabitac,
					 iManzana, iOtros , iAndador, iEtapa, iLote, iEdIFicio, iEntrada, cObservaciones, cUser_insert, dFecha_insert
				FROM Bdinteg:si_direcciones
				WHERE numcte =  cNumcTel                 --'000018538'
				AND secuencia =  MAXSecuencia2    -- 29				
				AND tipo_dir = 2;
			
				select  tipo_tel,telefono 
			into  cTipo_telef1, cTelefono1
			from bdinteg:si_telefonos 
			where numcte = iNumcte 
				and tipo_tel = 1 and secuencia = (select max(secuencia) from bdinteg:si_telefonos 
													where numcte = iNumcte and tipo_tel = 1);
										
			select  tipo_tel,telefono 
			into  cTipo_telef2, cTelefono2
			from bdinteg:si_telefonos 
			where numcte = iNumcte 
				and tipo_tel = 2 and secuencia = (select max(secuencia) from bdinteg:si_telefonos 
													where numcte = iNumcte and tipo_tel = 2);
												
			select  tipo_tel,telefono ,extension
			into  cTipo_telef3, cTelefono3, iExtension
			from bdinteg:si_telefonos 
			where numcte = iNumcte 
				and tipo_tel = 3 and secuencia = (select max(secuencia) from bdinteg:si_telefonos 
													where numcte = iNumcte and tipo_tel = 3);
		    
				
				IF cTel = cTelefono1 THEN 
					EXECUTE PROCEDURE Bdinteg:direcciones('001' , 'A' , iNumcte, iSecuencia, iTipo_dir, cCalle, cColonia, cMunicipio, cEntre_calles ,cPais ,cEstado,
					                                      cCiudad  ,cCod_postal ,'','',cTipo_telef2, cTelefono2 ,cTipo_telef3 ,cTelefono3,iExtension,cEstado_inegi,
														  cMunicipio_inegi   ,cLocalidad_inegi , cNumerociudad ,cNumeroextcalle ,cNumerointcalle  ,cDepartamento ,
														  cNumerocalle ,cNumerocolonia ,cPuntocardinal ,cUnidadhabitac ,iManzana ,iOtros ,iAndador ,iEtapa ,iLote,
														  iEdIFicio ,iEntrada ,cObservaciones ,cUser_insert ,dFecha_insert ,null)
					INTO cCodret1;
				ELIF cTel = cTelefono2 THEN 
					EXECUTE PROCEDURE Bdinteg:direcciones('001' , 'A' , iNumcte, iSecuencia, iTipo_dir, cCalle, cColonia, cMunicipio, cEntre_calles,
					                                      cPais,cEstado,cCiudad,cCod_postal,cTipo_telef1,cTelefono1,'','',cTipo_telef3, cTelefono3,
														  iExtension,cEstado_inegi,cMunicipio_inegi,cLocalidad_inegi, cNumerociudad,cNumeroextcalle,
														  cNumerointcalle,cDepartamento,cNumerocalle,cNumerocolonia,cPuntocardinal,cUnidadhabitac,
														  iManzana,iOtros,iAndador,iEtapa,iLote,iEdIFicio,iEntrada,cObservaciones,cUser_insert,
														  dFecha_insert,null)
					INTO cCodret1;
				ELIF cTel = cTelefono3 THEN 
					EXECUTE PROCEDURE Bdinteg:direcciones('001','A',iNumcte,iSecuencia,iTipo_dir,cCalle,cColonia,cMunicipio,cEntre_calles,cPais,
					                                      cEstado,cCiudad,cCod_postal,cTipo_telef1,cTelefono1,cTipo_telef2,cTelefono2 ,'' , '',
														  iExtension,cEstado_inegi,cMunicipio_inegi,cLocalidad_inegi,cNumerociudad,cNumeroextcalle,
														  cNumerointcalle,cDepartamento,cNumerocalle,cNumerocolonia,cPuntocardinal,cUnidadhabitac,
														  iManzana,iOtros,iAndador,iEtapa,iLote,iEdificio,iEntrada,cObservaciones,cUser_insert,
														  dFecha_insert ,null)
					INTO cCodret1;
				END IF
			END IF 
		END IF 
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

		IF cTipo_tel  = 'T'  THEN
			SELECT MAX(secuencia)
			INTO MAXSecuencia2
			FROM Bdinteg:si_direcciones
			WHERE tipo_dir = 2
			AND numcte = cNumcTel; --'000018538'
			
			IF MAXSecuencia2 IS NULL THEN
				LET iCont = 3;
				UPDATE Bdicobranza:cb_gestion_telefonica SET status = 'ER'  WHERE num_solicitud = cNum_sol and numcte = cNumcTel and secuencia = sSecuencia;			
				CONTINUE FOREACH;				
			END IF;

			SELECT numcte,secuencia,tipo_dir,calle,colonia,municipio,entre_calles,pais,estado,ciudad,cod_postal,/*tipo_telef1,telefono1,tipo_telef2,
			       telefono2,tipo_telef3,telefono3,extension,*/estado_inegi,municipio_inegi,localidad_inegi,numerociudad,numeroextcalle,
				   numerointcalle,departamento,numerocalle,numerocolonia,puntocardinal,unidadhabitac,manzana,otros,Andador,etapa,lote,edificio,
				   entrada,observaciones,user_insert,fecha_insert
			INTO iNumcte,iSecuencia, iTipo_dir,cCalle, cColonia, cMunicipio, cEntre_calles, cPais , cEstado, cCiudad,  cCod_postal, /*cTipo_telef1,
			     cTelefono1, cTipo_telef2, cTelefono2, cTipo_telef3, cTelefono3, iExtension, */cEstado_inegi, cMunicipio_inegi, cLocalidad_inegi,
				 cNumerociudad, cNumeroextcalle, cNumerointcalle, cDepartamento, cNumerocalle, cNumerocolonia, cPuntocardinal, cUnidadhabitac,
				 iManzana, iOtros , iAndador, iEtapa, iLote, iEdIFicio, iEntrada, cObservaciones, cUser_insert, dFecha_insert
			FROM Bdinteg:si_direcciones
			WHERE numcte =  cNumcTel                 -- '000018538'
			AND secuencia =  MAXSecuencia2
			AND tipo_dir = 2;		

				select  tipo_tel,telefono 
			into  cTipo_telef1, cTelefono1
			from bdinteg:si_telefonos 
			where numcte = iNumcte 
				and tipo_tel = 1 and secuencia = (select max(secuencia) from bdinteg:si_telefonos 
													where numcte = iNumcte and tipo_tel = 1);
										
			select  tipo_tel,telefono 
			into  cTipo_telef2, cTelefono2
			from bdinteg:si_telefonos 
			where numcte = iNumcte 
				and tipo_tel = 2 and secuencia = (select max(secuencia) from bdinteg:si_telefonos 
													where numcte = iNumcte and tipo_tel = 2);
												
			select  tipo_tel,telefono ,extension
			into  cTipo_telef3, cTelefono3, iExtension
			from bdinteg:si_telefonos 
			where numcte = iNumcte 
				and tipo_tel = 3 and secuencia = (select max(secuencia) from bdinteg:si_telefonos 
													where numcte = iNumcte and tipo_tel = 3);
		    
			EXECUTE PROCEDURE Bdinteg:direcciones('001','A',iNumcte,iSecuencia,iTipo_dir,cCalle,cColonia,cMunicipio,cEntre_calles,cPais,cEstado,
			                                     cCiudad,cCod_postal,cTipo_telef1,cTelefono1,cTipo_telef2,cTelefono2,'T',cTel,iExtension,
												 cEstado_inegi,cMunicipio_inegi,cLocalidad_inegi,cNumerociudad,cNumeroextcalle,cNumerointcalle,
												 cDepartamento,cNumerocalle,cNumerocolonia,cPuntocardinal,cUnidadhabitac,iManzana,iOtros,
												 iAndador,iEtapa,iLote,iEdIFicio,iEntrada,cObservaciones,cUser_insert,dFecha_insert  ,null)
			INTO cCodret1;	
			
            IF cCodret1 ='000' THEN
				EXECUTE PROCEDURE bdinteg:sp_validatelefono('001',cTelefono1,cTelefono2,cTel)
				INTO cCodret2, cBandera1,cBandera2,cBandera3;
				EXECUTE PROCEDURE bdinteg:sp_actvalidacioncofetel('001',iNumcte,cBandera1,cBandera2,cBandera3,iTipo_dir,1)
				INTO cCodret3;
		    ELSE
			   LET iCont = 3;
			END IF;

		END IF;

		--Se valida la ejecucion del procedimiento direcciones para cualquier tipo de telefono
		IF cCodret1 <> '000' THEN
			LET iCont = 3;
			UPDATE Bdicobranza:cb_gestion_telefonica SET status = 'ER'  WHERE num_solicitud = cNum_sol and numcte = cNumcTel and secuencia = sSecuencia;			
			CONTINUE FOREACH;
		END IF;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  IF  iCont <> 3 THEN 
       LET iContador = iContador + 1;
		UPDATE Bdicobranza:cb_gestion_telefonica SET status = 'PR', fecha_ejecucion = dFechaHoy WHERE num_solicitud = cNum_sol and numcte = cNumcTel and secuencia = sSecuencia;			
		CONTINUE FOREACH;
      END IF;

	END FOREACH

	IF iCont = 0 THEN
		LET cCodret = '000001'; -- NO EXISTEN REGISTROS EN LA TABLA cb_gestion_telefonica para los NP
		RETURN cCodret,iContador;
	ELIF iCont = 2 THEN
		LET cCodret = '000002'; -- NO EXISTE EL REGISTRO EN si_direcciones
		RETURN cCodret,iContador;
	ELIF iCont = 3 THEN
		LET cCodret = '000003'; -- PROBLEMAS EN LA EJECUCION DEL PROCEDIMIENTO direcciones
		RETURN cCodret,iContador;
	END IF;

	RETURN cCodret,iContador;

END;
END PROCEDURE
DOCUMENT
'CREACION     : VALENTIN LOPEZ',
'DESCRIPCION  : Actualiza los Telefonos de los Clientes con Base ala Tabla "cb_gestion_telefonica" ',
'FECHA    	  : AGOSTO 2010',
'VERSION  	  : 20100813.1630';

CREATE PROCEDURE "informix".sp_carga_sms_latinia()
RETURNING CHAR(6), CHAR(80);

/* 	MARIA ELIZABETH ANZURES IBARGUEN
	24-OCTUBRE-2012
	ARCHIVO QUE CARGA MOVIMEINTOS SMS LATINIA A TABLA CB_SMS_LATINIA PARA TOMAR LA INFORMACION EN LA GENERACIN DE REPORTES*/

--DECLARACION DE VARIABLES
	DEFINE sql_err		INTEGER;
	DEFINE isam_err		INTEGER;
	DEFINE error_info	CHAR(80);
	DEFINE cCod_ret		CHAR(6);
	DEFINE vempresa     CHAR(3);
	DEFINE cproceso     CHAR(4);
	DEFINE vvcCod_ret   CHAR(6);
	DEFINE cMensaje		CHAR(80);
	DEFINE cCadena		CHAR(500);
	DEFINE vRuta		CHAR(100);
	DEFINE cSql         CHAR(2204);	
	DEFINE pNomArch 	CHAR(100);
	DEFINE vNomArch		CHAR(100);
	DEFINE X 			CHAR(100);
	DEFINE vfecha 		DATE;
	DEFINE vfecha_cat 	DATE;
	
	----variables
	DEFINE vnumcte					CHAR(20);
	DEFINE vtelefonoreconstruido	CHAR(13);
	DEFINE vtipotelefono			SMALLINT;
	DEFINE vsecuencia				SMALLINT;
	DEFINE vnumext					CHAR(5);
	DEFINE vfinllamada				SMALLINT;
	DEFINE vnumempleado				CHAR(8);
	DEFINE vnumcuenta				CHAR(20);
	DEFINE vplazo					CHAR(2);
	DEFINE vimporte					DECIMAL(18,2);
	DEFINE vtipoconvenio			CHAR(1);
	DEFINE vhorainicio				DATE;

--	SET DEBUG FILE TO "carga_sms.out ";
--	TRACE ON;

--DEFINICIAON DE VARIABLES
	LET cCod_ret  	= "000000";
	LET sql_err   	= 0;
	LET cMensaje  	= "PROCESO EXITOSO";
	LET cCadena   	= "";
	LET vRuta     	= "";
	LET cSql      	= "";
	LET vempresa    = '001';
	LET cproceso    = '2077';
	LET pNomArch 	= '';
	let vfecha 		= DATE(1);
	let vfecha_cat	= date(1);
	let vNomArch	= '';
	let X ='';
	
	---VARIABLES
	LET vnumcte					='';
	LET vtelefonoreconstruido	='';
	LET vtipotelefono			=0;
	LET vsecuencia				=0;
	LET vnumext					='';
	LET vfinllamada				=0;
	LET vnumempleado			='';
	LET vnumcuenta				='';
	LET vplazo					='';
	LET vimporte				=0;
	LET vtipoconvenio			='';
	LET vhorainicio				=DATE(1);

      BEGIN
  
        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
			LET cMensaje = error_info;
		  CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '02')
            RETURNING vvcCod_ret;
			    RETURN cCod_ret, cMensaje;	    
	    END EXCEPTION;
		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
	--SE MANDA LLAMAR SP PARA INSERTAR EN BITACORA EL INICIO DE LA EJECUCION DE SP
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '01')
        RETURNING vvcCod_ret;
 
	--SELECCIONAMOS LA FECHA DEL DIA
	select fecha_hoy 
		into vfecha 
	from bdicred:sd_fechas 
	where empresa = '001';

		--SELECCIONAMOS LA RUTA 
    select valor_alfabetico 
		into vRuta 
    from bdicobranza:cb_param_campania
    where empresa = '001'
		and tipo_campania = 1
		and grupo_parametro = 'ARCHIVOS'
		and num_parametro = 36;	

--let vfecha = '10-23-2012';----------------------pruebas
--let vRuta ='/informix/eli/'; --------------------pruebas	
	---------------------------------------------CARGAR ARCHIVO A LA TABLA	---------------------------------------------------------------------
	
		--ASIGNAMOS NOMBRE AL ARCHIVO
		LET pNomArch = 'sms_latinia'|| to_char(vfecha,'%d%m%Y')||'.txt';
		let vNomArch = pNomArch;
	
		LET cCadena = 'echo " load from ' || SUBSTR(vRuta,1,LENGTH(vRuta)) || SUBSTR(vNomArch,1,
			LENGTH(vNomArch))  || ' insert into bdicobranza:cb_sms_latinia " >' || SUBSTR(vRuta,1,LENGTH(vRuta)) || 'smsmovimientoslatinia.sql';
			System SUBSTR(cCadena,1,LENGTH(cCadena));
			let cCadena = 'dbaccess bdicobranza ' || SUBSTR(vRuta,1,LENGTH(vRuta)) || 'smsmovimientoslatinia.sql';
		System SUBSTR(cCadena,1,LENGTH(cCadena));
		  
		--BORRA EL ARCHIVO 
        let cCadena = 'rm ' || SUBSTR(vRuta,1,LENGTH(vRuta)) || 'smsmovimientoslatinia.sql';
        System SUBSTR(cCadena,1,LENGTH(cCadena));
		
		--SE COMPRIME DE NUEVO EL ARCHIVO	
/*		LET cSql = "gzip " || trim(vRuta) || trim(vNomArch); 
*/		system cSql;
	
	
	--SE MANDA LLAMAR SP PARA INSERTAR EN BITACORA EL FINAL DE LA EJECUCION DE SP
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '03')
		RETURNING vvcCod_ret;
		
RETURN cCod_ret, cMensaje;

END;
END PROCEDURE;