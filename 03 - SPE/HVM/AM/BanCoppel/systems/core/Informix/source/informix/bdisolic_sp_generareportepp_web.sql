CREATE PROCEDURE "informix".sp_generareportepp_web(pNumSolicitud CHAR(20), pSucursal CHAR(5), cPlazo CHAR(2),iMontoTotal DECIMAL (16,2),
                                    cCapacidad_pres DECIMAL(18,2), pProducto CHAR(4),pTipo CHAR(1), pFrecuencia INTEGER)
RETURNING	CHAR(5)   		AS Codret,
			CHAR(9) 		AS NumCte,
			CHAR(100) 		AS NOMBRE,
			CHAR(20)  		AS NumCredito,
			CHAR(2)   		AS diasDePago,
			CHAR(12)  		AS cuenta,
			CHAR(10)  		AS Iva,
			DECIMAL (16,2)	AS MontoTotal,
			DECIMAL (16,2)  AS interesOrdinario,
			CHAR(2)   		AS Plazo,
			DECIMAL (16,2) 	AS TasaIntMoratorio,
			CHAR(1)	  		AS PeriodoPlazo,
			CHAR(12)  		AS Fecha,
			CHAR(150) 		AS Direccion,
			CHAR(40)  		AS Ciudad,
			DECIMAL(16,2) 	AS Capacidad_Pres,
			DECIMAL (16,2)	AS cApli_factor,
			DECIMAL (16,2)  AS MontoTotalApagar,
			CHAR(50) 		AS DiasPago,
			CHAR(1)			AS Mercadeo; -- JAF 07/05/2021

--DEFINICION DE VARIABLES
    DEFINE cCodret 			CHAR(5);
	DEFINE sql_err  		INTEGER;
	DEFINE cNombre   		CHAR(100);
	DEFINE cNumCredito 		CHAR(20);
	DEFINE cDiasPago    	CHAR(12);
	DEFINE cCuenta			CHAR(12);
	DEFINE cIva				DECIMAL(14,2);
	--DEFINE iMontoTotal  	DECIMAL (16,2);
	DEFINE iMontoTotalCredito  	DECIMAL (16,2);
	DEFINE cInteresOrdinario DECIMAL (16,2);
	--DEFINE cPlazo 			CHAR(2);
	DEFINE cInteresMoratorio DECIMAL (16,2);
	DEFINE cPeriodoPlazo	CHAR(1);
   	DEFINE cFecha	 		DATE;
    DEFINE cDireccion       CHAR(150);
	DEFINE cCalle           CHAR(50);
	DEFINE cNumExtCalle     CHAR(5);
	DEFINE cNumIntCalle     CHAR(5);
	DEFINE cNombreZona      CHAR(30);
	DEFINE cMunicipio       CHAR(30);
	DEFINE cEstado			CHAR(30);
	DEFINE cCodPostal		CHAR(11);
	DEFINE cCiudad			CHAR(40);
	DEFINE cColonia			CHAR(60);
	DEFINE cTelefono		CHAR(13);
	DEFINE cCorreo		    CHAR(100);
	--DEFINE cCapacidad_pres	DECIMAL(18,2);
	DEFINE cNumcte			CHAR(9);
	DEFINE cApli_factor     DECIMAL (16,2);
	DEFINE cMontoTotales    DECIMAL(16,2);
	DEFINE Periodo  		INTEGER;
	DEFINE FechaCouta  		DATE;
	DEFINE Fechaaper		DATE;
	DEFINE SaldoInicial  	MONEY(14,2);
	DEFINE Mensualidad  	MONEY(14,2);
	DEFINE Intereses  		MONEY(14,2);
	DEFINE IvaInteres  		MONEY(14,2);
	DEFINE Capital  		MONEY(14,2);
	DEFINE SaldoFinal  		MONEY(14,2);
	DEFINE DiasPeriodo  	SMALLINT;
	DEFINE cSucursal 		CHAR (5);
	DEFINE cDivisa			CHAR (2);
	DEFINE i 				INTEGER;
	DEFINE v_cat 			DECIMAL(14,2);
	DEFINE iDiaPago  		INTEGER;	
	DEFINE iDiaCorte  		INTEGER;	
	DEFINE cDiasdePago  	CHAR(50);	
	DEFINE dtFechaT  		DATE;	
	DEFINE cNumMesesPagos   CHAR(3);
	DEFINE iFrecuencia   	INTEGER;
	
	DEFINE cCodRet2         CHAR(6);
	DEFINE cMensajeRet      VARCHAR(80,1);
	DEFINE vCatFinal        DECIMAL(21,10);
	DEFINE dPagoReq      	DECIMAL(18,2);
	DEFINE mComisionApertura    MONEY(14,2);
	DEFINE dPorcComisionAper	DECIMAL(9,6);
	DEFINE cCodRetTDif			CHAR(6);			-- COD RETORNO TASAS DIFERENCIADAS	
	DEFINE V_MERCADEO		CHAR(1); -- JAF 07/05/2021
--ASIGNACION DE VARIABLES
    LET cCodret 			= "00000";
	LET sql_err	   			= 0;
	LET cNombre				= "";
	LET cNumCredito			= "";
	LET cDiasPago			= "";
	LET cCuenta				= "";
	LET cIva				= 0;
	LET cInteresOrdinario	= 0.0;
	LET cInteresMoratorio	= 0.0;
	LET cPeriodoPlazo		= "";
    LET cFecha 	    		= "";
	LET cDireccion          = "";
	LET cCalle              = "";
	LET cNumExtCalle        = "";
	LET cNumIntCalle        = "";
	LET cNombreZona         = "";
	LET cMunicipio          = "";
	LET cEstado				= "";
	LET cCodPostal			= "";
	LET cCiudad				= "";
	LET cColonia            = "";
	LET cTelefono           = "";
	LET cCorreo             = "";
	LET cNumcte				= '';
	LET cApli_factor   		= "";
	LET iMontoTotalCredito 	= 0.00;
	LET cSucursal 			= "";
	LET cDivisa 			= "";
	LET Periodo				= 0;
	LET FechaCouta			= "";
	LET Fechaaper			= "";
	LET SaldoInicial		= 0;
	LET Mensualidad			= 0;
	LET Intereses			= 0;
	LET IvaInteres			= 0;
	LET Capital				= 0;
	LET SaldoFinal			= 0;
	LET DiasPeriodo			= 0;
	LET cMontoTotales   	= 0;
	LET i 					= 0;
	LET iDiaPago            = 0; 	
	LET iDiaCorte           = 0; 	
	LET cDiasdePago  	    = "";
	LET dtFechaT  			= DATE(1);
	LET cNumMesesPagos  	= "";
	LET iFrecuencia  		= 0;
	
	LET cCodRet2            = "000000";
	LET cMensajeRet         = "Se realizo el calculo correctamente";
	LET vCatFinal           = 0;
	LET dPagoReq            = 0;
	LET mComisionApertura   = 0;
	LET dPorcComisionAper   = 0;
	LET cCodRetTDif			= '';
	LET V_MERCADEO			= ""; -- JAF 07/05/2021	

	BEGIN
		--MANEJO DE EXCEPCIONES (ERRORES)
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				let cCodret = sql_err;
				RETURN cCodret, '', '','','','','','','','','','','','','','','','','','';
			END IF;
		END EXCEPTION;
			
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
			--SET DEBUG FILE TO "/tmp/sp_generareportepp.out";
			--TRACE ON;
			--VALIDA EL NUMERO DE PRODUCTO
			IF pProducto = "" THEN
					LET cCodret ='00111'; -- PRODUCTO VACIO
					RETURN cCodret,'','','','','','','','','','','','','','','','','','','';
			END IF
			--VALIDA PARAMETROS DE ENTRADA
			IF  (pNumSolicitud IS NULL OR pNumSolicitud = "") OR (pTipo IS NULL OR pTipo = "") OR (pTipo <> 1 AND pTipo <> 2 AND pTipo <> 3) OR (pFrecuencia IS NULL) THEN
					LET cCodret ='00110'; -- FALTAN PARAMETROS
					RETURN cCodret,'','','','','','','','','','','','','','','','','','','';
			END IF;
			IF NOT EXISTS ( SELECT num_solicitud FROM bdisolic:"informix".ss_solicitudes where num_solicitud = pNumSolicitud  AND num_producto = pProducto) THEN
					LET cCodret	='00120'; -- EL NUÃâÃÅ¡MERO DE SOLICITUD PARA EL pProducto NO EXISTE
					RETURN cCodret,'','','','','','','','','','','','','','','','','','','';
			END IF
			IF (pTipo = 1 OR pTipo = 2) AND (pSucursal IS NULL OR pSucursal = "")  THEN
					LET cCodret	='00130';  --FALTAN SUCURSAL
					RETURN cCodret,'','','','','','','','','','','','','','','','','','','';
			END IF;
			--SE OBTIENE LA FECHA  DEL DIA DEL REPORTE
			SELECT fecha_hoy 
			INTO cFecha 
			FROM bdinteg:"informix".si_fechas;
			LET cDiasPago = substr(cFecha,4,2);
			-- SE OBTIENE EL IVALOR DEL IVA                                         DSB 12/01/2010 SE MODIFICA POR EL CAT 
			--SELECT NVL(valor,'') 
			--INTO cIva 
			--FROM bdicred:sd_param 
			--WHERE cod_param='037';
		
			IF pProducto = '6400' THEN				
				SELECT dia_pago,frecuencia_pgo INTO iDiaCorte , iFrecuencia
				FROM "informix".ss_sol_nomina  
				WHERE num_solicitud = pNumSolicitud;				
				
				IF pFrecuencia = 0 THEN
					LET pFrecuencia = iFrecuencia;
				END IF;
				
				IF pFrecuencia = 2 THEN
					EXECUTE PROCEDURE bdisolic:"informix".sp_obtienefechapago('001',cFecha,pNumSolicitud)					
					INTO cCodRet,dtFechaT,iDiaPago;	
					IF cCodRet::INTEGER <> 0  THEN	
						LET cCodRet    = "00140";	--Ocurrio un Error al obtener la fecha de pago del credito para credinomina.
						RETURN cCodret,'','','','','','','','','','','','','','','','','','','';
					END IF;	
					IF DAY(dtFechaT) = iDiaCorte THEN 					
						EXECUTE PROCEDURE bdisolic:"informix".sp_obtienefechapago('001',dtFechaT,pNumSolicitud)					
						INTO cCodRet,dtFechaT,iDiaPago;	
						IF cCodRet::INTEGER <> 0  THEN	
							LET cCodRet    = "00140";	--Ocurrio un Error al obtener la fecha de pago del credito para credinomina.
						RETURN cCodret,'','','','','','','','','','','','','','','','','','','';
					END IF;	
					END IF;
					LET cDiasdePago = "Los dias "|| iDiaPago|| " y " ||DAY(dtFechaT)||" de cada mes.";
				ELSE
					LET cDiasdePago = "Los dias "|| iDiaCorte|| " de cada mes.";
				END IF;		
					
				
			ELSE 
				IF pFrecuencia = 0 THEN
						LET pFrecuencia = 1;
				END IF;
			END IF;
			--RQM 10 751	se calcula el cat 
			-- RQM 10 737 
            
            select  tasa_interes, (CASE WHEN (tasa_moratorios - tasa_interes) < 0 THEN 0 ELSE (tasa_moratorios - tasa_interes) END)
            into cInteresOrdinario, cInteresMoratorio  
            from bdicred:"informix".sd_maecredcrd 
            where empresa = '001'
            and num_credito = pNumSolicitud;

            IF (cInteresOrdinario is null or cInteresOrdinario = 0) THEN
			
                --SE OBTIENE EL  VALOR DE LA TASA DE INTERES ORDINARIO
                /*SELECT a.valor, b.periodo_plazo 
                INTO cInteresOrdinario, cPeriodoPlazo 
                FROM bdinteg:"informix".si_fechavalor AS a,
                     bdicred:"informix".sd_definicion AS b
                WHERE a.tasa = b.cod_tasa_base       
                AND fecha = (SELECT MAX(fecha) 
							FROM bdinteg:"informix".si_fechavalor 
							WHERE  tasa=b.cod_tasa_base    -- FMV 13-MAY-11 SE OMITE a.tasa para mostrar las tasas en reporte
							AND b.num_producto = pProducto);

                --SE OBTIENE EL VALOR DE LA TASA DE INTERES MORATORIO
                SELECT a.valor 
                INTO cInteresMoratorio 
                FROM bdinteg:"informix".si_fechavalor AS a, bdicred:"informix".sd_definicion AS b
                WHERE a.tasa = b.cod_tasa_mora 
				AND fecha = (SELECT MAX(fecha) 
			                FROM bdinteg:"informix".si_fechavalor
			                WHERE  tasa=b.cod_tasa_mora AND b.num_producto = pProducto);  -- FMV 13-MAY-11 SE OMITE a.tasa para mostrar las tasas en reporte*/
							
                SELECT periodo_plazo INTO cPeriodoPlazo 
                FROM bdicred:"informix".sd_definicion
                WHERE num_producto = pProducto;
							
				EXECUTE PROCEDURE bdicred:"informix".sp_obtiene_tasa_int_diferenciadas('001', pNumSolicitud, '') INTO cCodRetTDif, cInteresOrdinario, cInteresMoratorio;
							
                LET cInteresMoratorio = cInteresMoratorio - cInteresOrdinario;
				
            ELSE
                SELECT periodo_plazo 
                INTO cPeriodoPlazo 
                FROM bdicred:"informix".sd_definicion 
                where empresa = '001'
                AND num_producto = pProducto;
            END IF;
			
			--JMAH --se agrega para conocer la periodicidad de pago del prestamo
			SELECT SUBSTR(tipo_pago,1,1)
			INTO cPeriodoPlazo
			FROM  bdicred:"informix".sd_cattipopago 
			WHERE valor = pFrecuencia;				
				
			--SE OBTIENE EL NUMERO DE CLIENTE
			SELECT numcte 
			INTO cNumCte 
			FROM "informix".ss_solicitudes 
			WHERE empresa = '001' 
			AND num_solicitud = pNumSolicitud;
			--SE OBTIENE EL DOMICILIO DEL CLIENTE
			SELECT TRIM(nombre1)|| ' ' || TRIM(nombre2) ||' '||TRIM( apell_paterno) ||' '|| TRIM(apell_materno) AS Nombre,numcte 
			INTO cNombre,cNumCte
			FROM bdinteg:"informix".si_cliente 
			WHERE numcte = cNumCte;	
			-- JAF 07/MAYO/2021
			SELECT string1 INTO V_MERCADEO 
			FROM   bdinteg:si_ctepf 
			WHERE  numcte = cNumCte;		
			
			--SECCION PARA EL REPORTE TIPO 1 CONTRATO
			IF pTipo = 1 THEN 
				--VALOR DE LA COMISION A COBRAR POR PAGO ANTICIPADO
				SELECT apli_factor 
				INTO cApli_factor 
				FROM bdicred:"informix".sd_tpcomis 
				WHERE cod_comis = '6903'; 
				
				--EN ESTE CICLO SE EJECUTA EL PROCEDIMIENTO PROYECTA PREÃâÃâ°STAMO PARA OBTENER EL VALOR TOTAL A PAGAR
				FOREACH 
					EXECUTE PROCEDURE  "informix".sp_proyecta_prestamos(iMontoTotal, '0',cCapacidad_pres,pProducto,pSucursal,'1','0',pNumSolicitud,'',pFrecuencia)
					INTO cCodRet, Periodo,FechaCouta,SaldoInicial,Mensualidad,Intereses,IvaInteres,Capital,SaldoFinal,DiasPeriodo,Fechaaper,cNumMesesPagos
					LET cMontoTotales = cMontoTotales  + Intereses + IvaInteres ;
				END FOREACH;
				LET iMontoTotalCredito= iMontoTotal + cMontoTotales;
				LET cDiasPago=  SubStr(cFecha,4,2);
				
				IF pProducto = '6400' THEN	
						--se obtiene el porcentaje de comision por apertura.
					SELECT valor INTO dPorcComisionAper
					FROM   bdicred:"informix".sd_param
					WHERE  cod_param = '040';			
				
					IF ( dPorcComisionAper is null ) THEN LET dPorcComisionAper = 0; END IF;

					IF ( dPorcComisionAper > 0 ) THEN
						LET mComisionApertura= ROUND(iMontoTotal * (dPorcComisionAper/100),2);
					END IF	
				END IF
				--RQM 10 751
				-- RQM 10 737 

				LET dPagoReq = iMontoTotal / ((1- pow((1+((cInteresOrdinario /100)/( pFrecuencia * 12 ))),-cPlazo)) / ((cInteresOrdinario /100)/( pFrecuencia * 12 )) ) ;

				EXECUTE PROCEDURE bdicred:"informix".sp_calculo_tiir_pp(iMontoTotal,dPagoReq,cPlazo,(12 * pFrecuencia),mComisionApertura) 
				INTO cCodRet2,cMensajeRet,vCatFinal;
				LET cIva = vCatFinal;
				
				SELECT calle, numeroextcalle, colonia, cod_postal  
				INTO cCalle,cNumExtCalle,cColonia, cCodPostal 
				FROM BDINTEG:si_direcciones WHERE  numcte = cNumCte
				AND secuencia=(SELECT MAX(secuencia) 
								FROM bdinteg: si_direcciones 
								WHERE numcte = cNumCte
								AND tipo_dir = '1');
								
				SELECT  telefono INTO cTelefono
				FROM BDINTEG: si_telefonos WHERE numcte = cNumCte
				AND secuencia=(SELECT MAX(secuencia) 
								FROM bdinteg: si_telefonos 
								WHERE numcte = cNumCte
								AND status_tel  = 'A');
				
				SELECT  lower(correo_elec) INTO cCorreo
				FROM BDINTEG: si_correos WHERE numcte = cNumCte
				AND secuencia=(SELECT MAX(secuencia) 
								FROM bdinteg: si_correos 
								WHERE numcte = cNumCte
								AND status_correo  = 'A');

				LET  cDireccion = TRIM(cCalle) || '-'||TRIM(cNumExtCalle) || '-'||TRIM(cColonia) ||'-'||TRIM(cCodPostal) || '-' || TRIM(cTelefono) || '-' || TRIM(cCorreo);
			
				RETURN cCodret, cNumCte, cNombre,pNumSolicitud,cDiasPago,cCuenta,cIva,iMontoTotal,cInteresOrdinario,cPlazo,cInteresMoratorio,cPeriodoPlazo,cFecha,cDireccion,cCiudad,cCapacidad_pres,cApli_factor,iMontoTotalCredito,cDiasdePago, V_MERCADEO   WITH RESUME;
			--SECCION PARA EL PAGARA 
			ELIF pTipo = 2 THEN
					--OBTIENE LA CIUDAD
					SELECT NVL(b.nombreciudad,'') 
					INTO cCiudad 
					FROM bdinteg:"informix".si_catciudades AS b, bdinteg:"informix".si_sucursales AS a
					WHERE a.estado= b.numeroestado AND a.ciudad= b.numerociudad AND a.sucursal= pSucursal;
					--OBTIENE LA DIRECCIOÃâÃâN DEL CLIENTE
					SELECT TRIM(f.nombrecalle)||' '||TRIM(a.numeroextcalle)||' '||TRIM(a.numerointcalle),TRIM(g.nombrezona),TRIM(g.municipiozona), TRIM(c.estado),a.cod_postal
					INTO cCalle,cNombreZona,cMunicipio,cEstado, cCodPostal 
					FROM bdinteg:"informix".si_direcciones AS a,--bdinteg:si_ciudades as b,
					"informix".ss_circulo_edos AS c,bdinteg:"informix".si_catcalles f, bdinteg:"informix".si_catzonas g
					WHERE a.numcte=cNumCte
					AND a.secuencia=(SELECT MAX(secuencia) 
									FROM bdinteg:"informix".si_direcciones 
									WHERE numcte = a.numcte 
									AND tipo_dir = '1')
					AND c.empresa = "001" 
					AND a.estado = c.clave 
					AND a.numerociudad = g.numerociudad 
					AND a.numerocolonia = g.numerocolonia
					AND a.numerocalle = f.numerocalle;

					LET  cDireccion = TRIM(cCalle) || ' '||TRIM(cNombreZona) || ' '||TRIM(cMunicipio) ||', '||TRIM(cEstado) || ' ' || cCodPostal;
					RETURN cCodret, cNumCte, cNombre,pNumSolicitud,cDiasPago,cCuenta,cIva,iMontoTotal,cInteresOrdinario,cPlazo,cInteresMoratorio,cPeriodoPlazo,cFecha,cDireccion,cCiudad,cCapacidad_pres,cApli_factor,iMontoTotalCredito,cDiasdePago, V_MERCADEO  WITH RESUME;
			--SECCION DE CODIGO PARA EL TIPO 3 (REIMPRESIOÃâÃâN)
			ELIF pTipo = 3 THEN 
					SELECT num_cta
					INTO cCuenta
					FROM bdicred:"informix".sd_ctascarg
					WHERE  empresa = '001'
					AND num_credito = pNumSolicitud;
					
					
					select  cat 
					into cIva
					from bdicred:"informix".sd_maecredanexocrd 
					where empresa = '001'
					and num_credito = pNumSolicitud;
					
					IF NVL(cIva,0)=0 THEN
						SELECT cat_caratula INTO cIva
						FROM bdicred:"informix".sd_definicion 
						WHERE num_producto = pProducto;
					END IF

			
					
					LET cCapacidad_pres		= 0.00;
					LET iMontoTotal			= "";
					LET cPlazo				= "";
					--SE OBTENIE LA FECHA, LA SUCURSAL Y LA DIVISA, CUANDO ES REIMPRESIOÃâÃâN
					--OBTIENE EL NUM DE CUENTA CON EL QUE ESTA APERTURADO
					--SE OBTIENE LA FECHA  DEL DIA DE LA APERTURA 
					SELECT fecha_apertura, sucursal,divisa 
					INTO cDiasPago, cSucursal,cDivisa 
					FROM bdicred:"informix".sd_maecredcrd 
					WHERE num_credito = pNumSolicitud;
					LET cDiasPago = SUBSTR(cDiasPago,4,2);
					--VALOR DEL IVA A COBRAR
					SELECT apli_factor
					INTO cApli_factor
					FROM bdicred:"informix".sd_tpcomis
					WHERE cod_comis = '6903';
					FOREACH
						EXECUTE PROCEDURE  "informix".sp_proyecta_prestamos('0', '0','0',pProducto,cSucursal,'2','0',pNumSolicitud,'',pFrecuencia)
						INTO cCodRet, Periodo,FechaCouta,SaldoInicial,Mensualidad,Intereses,IvaInteres,Capital,SaldoFinal,DiasPeriodo,Fechaaper,cNumMesesPagos
						LET cMontoTotales = cMontoTotales  + Intereses + IvaInteres ;
						LET i = i + 1;
						IF i = 1 THEN 
							--SE OBTIENE EL PRIMER RENGLON PARA TOMAR EL MONTO DE LA MENSUALIDAD Y EL SALDO INICIAL 
							LET iMontoTotal = SaldoInicial;
							LET cCapacidad_pres = Mensualidad;
						END IF
						LET cPlazo = i;
					END FOREACH;
					IF pProducto = "6400" THEN		--JMAH				
						LET cDireccion = pFrecuencia;
					END IF;
					LET iMontoTotalCredito= iMontoTotal + cMontoTotales;
					--CDIVISA RETORNARA EN EL CAMPO CIUDAD, YA QUE PARA LA REIMPRESIOÃâÃâN DE CARATULA ES NECESARIO LA DIVISA Y NO ASI LA CIUDAD, Y CON EL OBJETIVO DE NO AGREGAR UN PARAMETRO D SALIDA MAÃâÃÂS SE REUTILIZARAÃâÃÂ EL CORRESPONDIENTE A LA CIUDAD.
					RETURN cCodret, cNumCte, cNombre,pNumSolicitud,cDiasPago,cCuenta,cIva,iMontoTotal,cInteresOrdinario,cPlazo,cInteresMoratorio,cPeriodoPlazo,cFecha,cDireccion,cDivisa,cCapacidad_pres,cApli_factor,iMontoTotalCredito,cDiasdePago, V_MERCADEO   WITH RESUME;
			END IF;
	END;
END PROCEDURE
