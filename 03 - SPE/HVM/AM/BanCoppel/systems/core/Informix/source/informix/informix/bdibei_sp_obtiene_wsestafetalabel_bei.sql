CREATE PROCEDURE "informix".sp_obtiene_wsestafetalabel_bei(pCliente char(20), pSolicitud char(10), pSecuencia integer)
   returning 
   CHAR(5), --CodRet
   CHAR(8), --effectiveDate
   CHAR(13), --Cellphone
   CHAR(30), --ContactName
   CHAR(50), --CorporateName
   CHAR(10), --CustomerNumber
   CHAR(13), --PhoneNumber
   CHAR(1), --Valid
   CHAR(3), --DestinationCountryId
   CHAR(2), --NumbersOfLabels
   CHAR(6), --DestinationAddress1
   CHAR(6), --Manzana
   CHAR(6), --Otros
   CHAR(6), --Andador
   CHAR(6), --Etapa
   CHAR(6), --Lote
   CHAR(6), --Edificio
   CHAR(6), --Entrada
   CHAR(80), --Observaciones
   CHAR(1),  -- TipoDir
   CHAR(4), --CostCenter o Sucursal
   CHAR(75) --Content

--*************************************************************************
--| Procedimiento   : "informix".sp_obtiene_wsestafetalabel_bei
--| VersiÃ³n         : 1.0
--| Creado por      : Juan Daniel Lazalde
--| Fecha creacion  : 12 Agosto de 2013
--| DescripciÃ³n     : Se otiene los parametros de entrada para el web service de estafeta
--*************************************************************************
--Modifico: Cesar Adrian Mendoza Gonzalez
--Actividad: Se modifica para retornar los token con topes maximo.
--Fecha: 04-06-2015
--SolilcitÃ³: Gabriela Aguilar (BanCoppel)
--BD:bdibei.
--*************************************************************************
--Modifico: Manuel Ramos Figueroa
--Actividad: Se modifica para retornar la vigencia original de la guÃ­a (campo "vEffectiveDate") en caso de una reimpresiÃ³n.
--Fecha: 13-08-2015
--SolilcitÃ³: Gabriela Aguilar (BanCoppel)
--BD:bdibei.
--************************************************************************
--Modifico: Gabriela Aguilar Mendoza
--Actividad: Se modifica para ampliar a 14 dias la vigencia original de la guÃ­a (campo "vEffectiveDate").
--Fecha: 28-02-2017
--SolilcitÃ³: Alejandro Vazquez (BanCoppel)
--BD:bdibei.
---------------------------------------------------------------------------------------------

    DEFINE cod_ret CHAR(5);
    DEFINE sql_err INTEGER;
	DEFINE vTramaRet CHAR(36);	
	DEFINE vSecDomicilio smallint;
	DEFINE vEffectiveDate CHAR(8);
	DEFINE vCellPhone CHAR(13);
	DEFINE vContactName CHAR(30);
	DEFINE vCorporateName CHAR(50);
	DEFINE vCustomerNumber CHAR(10);
	DEFINE vPhoneNumber CHAR(13);
	DEFINE vValid CHAR(1);
	DEFINE vDestinationCountryId CHAR(3);
	DEFINE vNumbersOfLabels CHAR(2);
	DEFINE vDestinationaddress1 CHAR(6);
	DEFINE vDestinationaddress2 int;
	DEFINE vDestinationManzana CHAR(6);
	DEFINE vDestinationOtros CHAR(6);
	DEFINE vDestinationAndador CHAR(6); 
	DEFINE vDestinationEtapa CHAR(6);
	DEFINE vDestinationLote CHAR(6);
	DEFINE vDestinationEdificio CHAR(6);
	DEFINE vDestinationEntrada CHAR(6);
	DEFINE vDestinationObservaciones CHAR(80);
	DEFINE vTipoDir char(1);
	DEFINE vContent CHAR(75);
	DEFINE vSeriesContent CHAR(6);
	DEFINE vContaToken DECIMAL;
	DEFINE vSeriesContentToken CHAR(9);
	DEFINE vContador int; --Contador para el manejo de las comas (,)entre tokens series
	DEFINE vContadorTkn int; 
	DEFINE vFecha date;
	DEFINE vCostCenter CHAR(4);
	DEFINE vConjunto INTEGER;
	DEFINE vCount INTEGER;
	DEFINE vMaxLine INTEGER;
	DEFINE vMaxTrama INTEGER;
	DEFINE vBandera INTEGER;
	DEFINE vSeries CHAR(5);
	DEFINE vCntToken INTEGER;
	DEFINE vFechaAtencion DATE;
	DEFINE vnombre_contacto CHAR(9);
	DEFINE vnombre1 CHAR(26);
    DEFINE vapell_paterno  CHAR(26);
	DEFINE vapell_materno  CHAR(26);
	DEFINE vnumsol INTEGER;
	DEFINE vtabname INTEGER;
	
		-- INICIALIZAR
	LET cod_ret = '00000';
	LET vTramaRet='';	
	LET vEffectiveDate = '';
	LET vCellPhone='';
	LET vContactName='';
	LET vCorporateName='';
	LET vCustomerNumber='';
	LET vPhoneNumber='';
	LET vValid='1';
	LET vDestinationCountryId='';
	LET vNumbersOfLabels='';
	LET vDestinationaddress1='';
	LET vDestinationManzana='';
	LET vDestinationOtros='';
	LET vDestinationAndador='';
	LET vDestinationEtapa='';
	LET vDestinationLote='';
	LET vDestinationEdificio='';
	LET vDestinationEntrada='';
	LET vDestinationObservaciones='';
	LET vTipoDir=0;	
	LET vFecha = current::date + 14;
	LET vSecDomicilio = 0;
	LET vCostCenter = '';
	LET vContent = '';
	LET vSeriesContent = '';
	LET vContaToken = '';
	LET vSeriesContentToken = '';
	LET vContador = 0;
	LET vContadorTkn = 0;
    LET vDestinationaddress2=0;
	LET vCntToken = 0;
	LET vSeries = '';
	LET vBandera = 0;
	LET vMaxLine = 25;
	LET vConjunto = 0;
	LET vCount = 0;
	LET vnombre_contacto='';
	LET vnombre1 ='';
	LET vapell_paterno ='';
	LET vapell_materno ='';
	LET vnumsol=  0;
	LET vtabname=  0;
	
		
	--SET DEBUG FILE TO '/informix/gaby/ArchivosOut/sp_obtiene_wsestafetalabel_bei.out';
	--TRACE ON;
	
	BEGIN	
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				LET cod_ret = sql_err;
				RETURN cod_ret,vEffectiveDate,vCellPhone,vContactName,vCorporateName,vCustomerNumber,vPhoneNumber,vValid,vDestinationCountryId,vNumbersOfLabels,vDestinationaddress1,vDestinationManzana,vDestinationOtros, vDestinationAndador,vDestinationEtapa,vDestinationLote,vDestinationEdificio,vDestinationEntrada,vDestinationObservaciones,vTipoDir,vCostCenter,vContent;
		  END IF ;
		END EXCEPTION ;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		
		SELECT tipo_dir INTO vTipoDir
		FROM bdinteg:'informix'.si_direcciones
		WHERE numcte = pCliente
		AND secuencia = NVL(pSecuencia,0);

		
		select count (*) into vnumsol FROM bdibei:'informix'.bei_solicitudtoken WHERE solicitud = pSolicitud AND numcte = pCliente AND id_status = 120; 
		IF( vnumsol>0) THEN
			SELECT f_atencion::date + 14 INTO vFechaAtencion
			FROM bdibei:'informix'.bei_solicitudtoken
			WHERE solicitud = pSolicitud
			AND numcte = pCliente;
			

			LET vEffectiveDate = YEAR (vFechaAtencion) || LPAD(MONTH(vFechaAtencion),2,'0') ||  LPAD(DAY(vFechaAtencion),2,'0') ;
		ELSE
			--Datos de direcciÃ³n	
			LET vEffectiveDate = YEAR (vFecha) || LPAD(MONTH(vFecha),2,'0') ||  LPAD(DAY(vFecha),2,'0') ;
		END IF;

		--CellPhone
		select telefono INTO vCellPhone from bdinteg:'informix'.si_telefonos_actual where numcte = pCliente and tipo_tel = 2;
        --Nombre de contacto
		
		
		select nombre_contacto into vnombre_contacto from bdinteg:"informix".si_ctepm where numcte = pCliente;
				
		select nombre1, apell_paterno, apell_materno into vnombre1, vapell_paterno, vapell_materno
		--trim(nombre1) || ' ' ||  trim(apell_paterno) || ' ' || trim(apell_materno) INTO vContactName
        from bdinteg:"informix".si_cliente where numcte=vnombre_contacto;
		
		IF ((vnombre1<>'') AND  (vapell_paterno<>'') AND (vapell_materno<>''))   THEN
		let vContactName= trim(vnombre1) || ' ' ||  trim(vapell_paterno) || ' ' || trim(vapell_materno); 
		
		elif((vnombre1=='') AND  (vapell_paterno<>'') AND (vapell_materno<>''))   THEN
			let vnombre1='_' ;
			let vContactName= trim(vnombre1) || ' ' ||  trim(vapell_paterno) || ' ' || trim(vapell_materno); 
		ELIF ((vnombre1<>'') AND  (vapell_paterno=='') AND (vapell_materno<>'')) THEN
			let vapell_paterno='_'; 
			let vContactName= trim(vnombre1) || ' ' ||  trim(vapell_paterno) || ' ' || trim(vapell_materno) ;
		ELIF ((vnombre1<>'') AND  (vapell_paterno<>'') AND (vapell_materno=='')) THEN
			let   vapell_materno='_';
			let vContactName= trim(vnombre1) || ' ' ||  trim(vapell_paterno) || ' ' || trim(vapell_materno) ;
			
		ELIF ((vnombre1<>'') AND  (vapell_paterno='') AND (vapell_materno=='')) THEN
			let vapell_paterno='_'; 
			let vapell_materno='_';
			let vContactName= trim(vnombre1) || ' ' ||  trim(vapell_paterno) || ' ' || trim(vapell_materno) ;
		ELIF 	((vnombre1=='') AND  (vapell_paterno=='') AND (vapell_materno=='')) THEN
			let vnombre1='  ' ;
			let vapell_paterno='_'; 
			let vapell_materno='_';
			let vContactName= trim(vnombre1) || ' ' ||  trim(vapell_paterno) || ' ' || trim(vapell_materno) ;
		ELIF 	((vnombre1=='') AND  (vapell_paterno=='') AND (vapell_materno<>'')) THEN
			let vnombre1='_' ;
			let vapell_paterno='_'; 
			let vContactName= trim(vnombre1) || ' ' ||  trim(vapell_paterno) || ' ' || trim(vapell_materno) ;	
		END IF;
		
		
		
		
        --Razon social
		select razon_social INTO vCorporateName from bdinteg:'informix'.si_cliente where numcte = pCliente;
        --Numero de cliente
		select numcte INTO vCustomerNumber from 'informix'.bei_solicitudtoken where solicitud = pSolicitud;
        --PhoneNumber
		select telefono INTO vPhoneNumber from bdinteg:'informix'.si_telefonos_actual where numcte = pCliente and tipo_tel = 1;
                     
		LET vDestinationCountryId = 'MEX';
		LET vNumbersOfLabels = 1; --Min 1 Max 70
		
		select sec_domicilio INTO vSecDomicilio from 'informix'.bei_solicitudtoken where solicitud = pSolicitud;
		
		if vSecDomicilio = 1 or vSecDomicilio = 2  then
			select 'Mz ' || nvl(manzana,'') , 'Ot ' || nvl(otros,''), 'An ' || nvl(andador,''), 'Et' || nvl(etapa,''), 'Lt ' || nvl(lote,''), 'Ed ' || nvl(edificio,''), 'En ' || nvl(entrada,''), '' || nvl(observaciones,'') 
			INTO vDestinationManzana, vDestinationOtros, vDestinationAndador, vDestinationEtapa, vDestinationLote, vDestinationEdificio, vDestinationEntrada, vDestinationObservaciones
			from bdinteg:'informix'.si_direcciones_actual where numcte = pCliente and unidadhabitac = 'S' and secuencia = vSecDomicilio and tipo_dir = vTipoDir;
				
		else
			select 'Mz ' || nvl(manzana,'') , 'Ot ' || nvl(otros,''), 'An ' || nvl(andador,''), 'Et' || nvl(etapa,''), 'Lt ' || nvl(lote,''), 'Ed ' || nvl(edificio,''), 'En ' || nvl(entrada,''), '' || nvl(observaciones,'') 
			INTO vDestinationManzana, vDestinationOtros, vDestinationAndador, vDestinationEtapa, vDestinationLote, vDestinationEdificio, vDestinationEntrada, vDestinationObservaciones
			from bdinteg:'informix'.si_direcciones where numcte = pCliente and unidadhabitac = 'S' and secuencia = vSecDomicilio and tipo_dir = vTipoDir;		
		end if;
				
		select sucursal INTO vCostCenter from 'informix'.bei_solicitudtoken where solicitud = pSolicitud and numcte = pCliente;
 
		--Formar los tokens
		LET vContent = 'Token ';
		LET vContaToken = 5;

		
		SELECT count (*) into vtabname FROM sysmaster:systabnames where tabname = 'tmp_series'; 
		
		if (vtabname>0 ) then
		     drop table tmp_series;
	    end if;	
		
        select count(ns_token) as cToken 
		INTO vContadorTkn
		FROM 'informix'.bei_tokensolicitud where solicitud =  pSolicitud and numcte = pCliente;
		
		if (vContadorTkn < 5) then	
			FOREACH
				select NS_TOKEN as Series
				INTO vSeriesContentToken
				FROM 'informix'.bei_tokensolicitud where solicitud = pSolicitud and numcte = pCliente order by series asc			
					IF (vContador == 0) THEN
						LET vContent = trim(vContent) || ' ' || trim(vSeriesContentToken);
						LET vContador = 1; --Contador para el manejo de las comas entre tokens series
					ELSE
						LET vCount = LENGTH(vContent)+LENGTH(vSeriesContentToken);
						IF (vCount>vMaxLine) THEN
							LET vContent = trim(vContent) || '|' || trim(vSeriesContentToken);
							LET vCount=0;
							LET vMaxLine=vMaxLine+vMaxLine;
						ELSE
							LET vContent = trim(vContent) || ',' || trim(vSeriesContentToken);
						END IF;
					END IF;
			END FOREACH;
		else
			FOREACH -- Cilco para contar cuantos conjuntos abra.
				select substr(NS_TOKEN,1,6) as Series
				INTO vSeries
				FROM 'informix'.bei_tokensolicitud where solicitud = pSolicitud and numcte = pCliente group by 1
				LET vBandera = vBandera + 1;
			END FOREACH;
			IF (vBandera >1) THEN
				LET vContent = '';
			END IF;
			FOREACH
				select substr(NS_TOKEN,1,6) as Series, count(ns_token) as cToken 
				INTO vSeriesContent, vContaToken
				FROM 'informix'.bei_tokensolicitud where solicitud = pSolicitud and numcte = pCliente group by 1 order by ctoken desc
				if (vContaToken > 1) then
					IF (vConjunto<1)THEN
						LET vContent = trim(vContent) || ' ' ||  trim(vSeriesContent);			    
					ELIF (vConjunto>0 AND vCntToken=0) THEN
						LET vContent = trim(vContent) || '|' ||  trim(vSeriesContent);	
					ELIF (vConjunto>0 AND vCntToken=1) THEN
						LET vContent = trim(vContent) || ',' ||  trim(vSeriesContent);	
					END IF;
					FOREACH
						select substr(NS_TOKEN,7,9) 
						INTO vSeriesContentToken
						FROM 'informix'.bei_tokensolicitud where ns_token like vSeriesContent || '%' and solicitud = pSolicitud and numcte = pCliente
						
						IF (vContador == 0) THEN
							LET vContent = trim(vContent) || trim(vSeriesContentToken);
						ELSE
							LET vCount = LENGTH(vContent)+LENGTH(vSeriesContentToken);
							IF (vCount>vMaxLine) THEN
								LET vMaxLine=vMaxLine+vMaxLine;
								LET vContent = trim(vContent) || '|' || trim(vSeriesContentToken);
								LET vCount=0;
								LET vCntToken=1;
							ELSE
								LET vContent = trim(vContent) || ',' || trim(vSeriesContentToken);
							END IF;
						END IF;
						LET vContador = 1; --Contador para el manejo de las comas entre tokens series		
					END FOREACH;
					LET vContador = 0; --Contador para el manejo de las comas entre tokens series
					LET vConjunto = vConjunto + 1;
				else
					if (vContaToken == 1) then					
						
						select NS_TOKEN
						INTO vSeriesContentToken
						FROM 'informix'.bei_tokensolicitud where ns_token like vSeriesContent || '%' and solicitud = pSolicitud and numcte = pCliente;
						
						if (vContador == 0) then
							LET vContent = trim(vContent) || '|' || trim(vSeriesContentToken);
							LET vContador = 1; --Contador para el manejo de las comas entre tokens series
						else
							LET vContent = trim(vContent) || ',' || trim(vSeriesContentToken);
							
						end if;					
						
					end if;
				end if;						
			END FOREACH;

		end if;
		LET vContador = 0; --Contador para el manejo de las comas entre tokens series
		 if exists(SELECT tabname FROM sysmaster:systabnames where tabname = 'tmp_series' ) then
		     drop table tmp_series;
	           end if;
			
                    LET vCellPhone = nvl(vCellPhone,'');		
		LET vContactName = nvl(vContactName,'');
		LET vCorporateName = nvl(vCorporateName,'');
		LET vCustomerNumber = nvl(vCustomerNumber,'');
		LET vPhoneNumber = nvl(vPhoneNumber,'');
		LET vValid = nvl(vValid,'');
		LET vDestinationCountryId = nvl(vDestinationCountryId,'');
		LET vNumbersOfLabels = nvl(vNumbersOfLabels,'');
		LET vDestinationaddress1 = nvl(vDestinationaddress1,'');
		
		LET vDestinationManzana = nvl(vDestinationManzana,'');
		LET vDestinationOtros = nvl(vDestinationOtros,'');
		LET vDestinationAndador = nvl(vDestinationAndador,'');
		LET vDestinationEtapa = nvl(vDestinationEtapa,'');
		LET vDestinationLote = nvl(vDestinationLote,'');
		LET vDestinationEdificio = nvl(vDestinationEdificio,'');
		LET vDestinationEntrada = nvl(vDestinationEntrada,'');
		LET vDestinationObservaciones = nvl(vDestinationObservaciones,'');
		
		LET vCostCenter = nvl(vCostCenter,'');
		
		LET vDestinationaddress2=LENGTH(vDestinationManzana)+LENGTH(vDestinationOtros)+LENGTH(vDestinationAndador)+LENGTH(vDestinationEtapa)+LENGTH(vDestinationLote)+LENGTH(vDestinationEdificio)+LENGTH(vDestinationEntrada)+LENGTH(vDestinationObservaciones);
		IF (vDestinationaddress2=0) THEN
		  LET vDestinationObservaciones='--';
		END IF;
	RETURN cod_ret, vEffectiveDate,vCellPhone,vContactName,vCorporateName,vCustomerNumber,vPhoneNumber,vValid,vDestinationCountryId,vNumbersOfLabels,vDestinationaddress1,vDestinationManzana,vDestinationOtros, vDestinationAndador,		       vDestinationEtapa,vDestinationLote,vDestinationEdificio,vDestinationEntrada,vDestinationObservaciones,vTipoDir,vCostCenter,vContent; 
                    
	END;	
END PROCEDURE;