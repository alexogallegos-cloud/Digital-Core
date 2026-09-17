CREATE PROCEDURE "informix".sp_generareportepp(pNumSolicitud CHAR(20), pSucursal CHAR(5), cPlazo CHAR(2), iMontoTotal DECIMAL (16,2),cCapacidad_pres DECIMAL(18,2), pProducto CHAR(4),pTipo CHAR(1))
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
			DECIMAL (16,2)  AS MontoTotalApagar;

--DEFINICION DE VARIABLES
    DEFINE cCodret 					CHAR(5);
	DEFINE sql_err  				INTEGER;
	DEFINE cNombre   				CHAR(100);
	DEFINE cNumCredito 				CHAR(20);
	DEFINE cDiasPago    			CHAR(12);
	DEFINE cCuenta					CHAR(12);
	DEFINE cIva						DECIMAL(14,2);
	--DEFINE iMontoTotal  			DECIMAL (16,2);
	DEFINE iMontoTotalCredito  		DECIMAL (16,2);
	DEFINE cInteresOrdinario 		DECIMAL (16,2);
	--DEFINE cPlazo 				CHAR(2);
	DEFINE cInteresMoratorio 		DECIMAL (16,2);
	DEFINE cPeriodoPlazo			CHAR(1);
   	DEFINE cFecha	 				DATE;
    DEFINE cDireccion       		CHAR(150);
	DEFINE cCalle           		CHAR(50);
	DEFINE cNumExtCalle     		CHAR(5);
	DEFINE cNumIntCalle     		CHAR(5);
	DEFINE cNombreZona      		CHAR(30);
	DEFINE cMunicipio       		CHAR(30);
	DEFINE cEstado					CHAR(30);
	DEFINE cCodPostal				CHAR(11);
	DEFINE cCiudad					CHAR(40);
	--DEFINE cCapacidad_pres		DECIMAL(18,2);
	DEFINE cNumcte					CHAR(9);
	DEFINE cApli_factor     		DECIMAL (16,2);
	DEFINE cMontoTotales    		DECIMAL(16,2);
	DEFINE Periodo  				INTEGER;
	DEFINE FechaCouta  				DATE;
	DEFINE Fechaaper				DATE;
	DEFINE SaldoInicial  			MONEY(14,2);
	DEFINE Mensualidad  			MONEY(14,2);
	DEFINE Intereses  				MONEY(14,2);
	DEFINE IvaInteres  				MONEY(14,2);
	DEFINE Capital  				MONEY(14,2);
	DEFINE SaldoFinal  				MONEY(14,2);
	DEFINE DiasPeriodo  			SMALLINT;
	DEFINE cSucursal 				CHAR (5);
	DEFINE cDivisa					CHAR (2);
	DEFINE i 						INTEGER;
	DEFINE v_cat 					DECIMAL(14,2);
	
	DEFINE cNumSolCredito 			CHAR(20);
--ASIGNACION DE VARIABLES
    LET cCodret 					= "00000";
	LET sql_err	   					= 0;
	LET cNombre						= "";
	LET cNumCredito					= "";
	LET cDiasPago					= "";
	LET cCuenta						= "";
	LET cIva						= 0;
	LET cInteresOrdinario			= 0.0;
	LET cInteresMoratorio			= 0.0;
	LET cPeriodoPlazo				= "";
    LET cFecha 	    				= "";
	LET cDireccion          		= "";
	LET cCalle              		= "";
	LET cNumExtCalle        		= "";
	LET cNumIntCalle        		= "";
	LET cNombreZona         		= "";
	LET cMunicipio          		= "";
	LET cEstado						= "";
	LET cCodPostal					= "";
	LET cCiudad						= "";
	LET cNumcte						= '';
	LET cApli_factor   				= "";
	LET iMontoTotalCredito 			= 0.00;
	LET cSucursal 					= "";
	LET cDivisa 					= "";
	LET Periodo						= 0;
	LET FechaCouta					= "";
	LET Fechaaper					= "";
	LET SaldoInicial				= 0;
	LET Mensualidad					= 0;
	LET Intereses					= 0;
	LET IvaInteres					= 0;
	LET Capital						= 0;
	LET SaldoFinal					= 0;
	LET DiasPeriodo					= 0;
	LET cMontoTotales   			= 0;
	LET i 							= 0;
	
	LET cNumSolCredito				= "";
	
	BEGIN
	
			--MANEJO DE EXCEPCIONES (ERRORES)
			ON EXCEPTION SET sql_err
				IF sql_err <> 0 THEN
					let cCodret = sql_err;
					RETURN cCodret, '', '','','','','','','','','','','','','','','','';
				END IF;
			END EXCEPTION;

			--SET DEBUG FILE TO "/tmp/sp_GeneraReportePP.out";
			--TRACE ON;
			
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			
			--VALIDA EL NUMERO DE PRODUCTO
			IF pProducto = "" THEN
					LET cCodret ='00111'; -- PRODUCTO VACIO
					RETURN cCodret,'','','','','','','','','','','','','','','','','';
			END IF
			
			--VALIDA PARAMETROS DE ENTRADA
			IF  (pNumSolicitud IS NULL OR pNumSolicitud = "") OR (pTipo IS NULL OR pTipo = "") OR (pTipo <> 1 AND pTipo <> 2 AND pTipo <> 3) THEN
					LET cCodret ='00110'; -- FALTAN PARAMETROS
					RETURN cCodret,'','','','','','','','','','','','','','','','','';
			END IF;

			SELECT num_solicitud
			INTO cNumSolCredito
			FROM bdisolic:"informix".ss_solicitudes where num_solicitud = pNumSolicitud  AND num_producto = pProducto;
			
			LET cNumSolCredito = NVL(cNumSolCredito,'');
			
			IF( cNumSolCredito IS NULL OR cNumSolCredito = "" ) THEN
					LET cCodret	='00120'; -- EL NÃMERO DE SOLICITUD PARA EL pProducto NO EXISTE
					RETURN cCodret,'','','','','','','','','','','','','','','','','';
			END IF
			
			IF (pTipo = 1 OR pTipo = 2) AND (pSucursal IS NULL OR pSucursal = "")  THEN
					LET cCodret	='00130';  --FALTAN SUCURSAL
					RETURN cCodret,'','','','','','','','','','','','','','','','','';
			END IF;
			--SE OBTIENE LA FECHA  DEL DIA DEL REPORTE
			SELECT fecha_hoy 
			INTO cFecha 
			FROM bdinteg:si_fechas;
			LET cDiasPago = substr(cFecha,4,2);
			-- SE OBTIENE EL IVALOR DEL IVA                                         DSB 12/01/2010 SE MODIFICA POR EL CAT 
			--SELECT NVL(valor,'') 
			--INTO cIva 
			--FROM bdicred:sd_param 
			--WHERE cod_param='037';
			
			--SE OBTIENE FECHA DE APERTURA (PrÃ©stamo Flexible)
			IF pProducto = '6800' THEN
				SELECT LIMIT 1 fecha_apertura
				INTO cFecha
				FROM bdicred:sd_maecredcrd 
				WHERE empresa = '001' 
					AND num_credito = pNumSolicitud;
			END IF

            SELECT cat_caratula INTO cIva FROM bdicred:sd_definicion WHERE num_producto = pProducto;

            SELECT tasa_interes, (tasa_moratorios - tasa_interes) 
            INTO cInteresOrdinario, cInteresMoratorio  
            FROM bdicred:sd_maecredcrd 
            WHERE empresa = '001'
            AND num_credito = pNumSolicitud;

            IF (cInteresOrdinario IS NULL OR cInteresOrdinario = 0) THEN

                --SE OBTIENE EL  VALOR DE LA TASA DE INTERES ORDINARIO
                SELECT a.valor, b.periodo_plazo
                INTO cInteresOrdinario, cPeriodoPlazo 
                FROM bdinteg:si_fechavalor AS a,
                            bdicred:sd_definicion AS b
                WHERE a.tasa = b.cod_tasa_base       
                AND fecha = (SELECT MAX(fecha) 
                FROM bdinteg:si_fechavalor 
                WHERE  tasa=b.cod_tasa_base    -- FMV 13-MAY-11 SE OMITE a.tasa para mostrar las tasas en reporte
                AND b.num_producto = pProducto);

                --SE OBTIENE EL VALOR DE LA TASA DE INTERES MORATORIO
                SELECT a.valor 
                INTO cInteresMoratorio 
                FROM bdinteg:si_fechavalor AS a, bdicred:sd_definicion AS b
                WHERE a.tasa = b.cod_tasa_mora AND fecha = (SELECT MAX(fecha) 
                FROM bdinteg:si_fechavalor
                WHERE  tasa=b.cod_tasa_mora AND b.num_producto = pProducto);  -- FMV 13-MAY-11 SE OMITE a.tasa para mostrar las tasas en reporte
                LET cInteresMoratorio = cInteresMoratorio - cInteresOrdinario;
            ELSE
                SELECT periodo_plazo 
                INTO cPeriodoPlazo 
                FROM bdicred:sd_definicion 
                where empresa = '001'
                AND num_producto = pProducto;
            END IF;

			--SE OBTIENE EL NUMERO DE CLIENTE
			SELECT numcte 
			INTO cNumCte 
			FROM bdisolic:ss_solicitudes 
			WHERE empresa = '001' 
			AND num_solicitud = pNumSolicitud;
			--SE OBTIENE EL DOMICILIO DEL CLIENTE
			SELECT TRIM(nombre1)|| ' ' || TRIM(nombre2) ||' '||TRIM( apell_paterno) ||' '|| TRIM(apell_materno) AS Nombre,numcte 
			INTO cNombre,cNumCte
			FROM bdinteg:si_cliente 
			WHERE numcte = cNumCte;	
			--SECCION PARA EL REPORTE TIPO 1 CONTRATO
			IF pTipo = 1 THEN 
					--VALOR DE LA COMISIÃN A COBRAR POR PAGO ANTICIPADO
					SELECT apli_factor 
					INTO cApli_factor 
					FROM bdicred:sd_tpcomis 
					WHERE cod_comis = '6903'; 
					
					--EN ESTE CICLO SE EJECUTA EL PROCEDIMIENTO PROYECTA PRÃSTAMO PARA OBTENER EL VALOR TOTAL A PAGAR
					FOREACH 
						EXECUTE PROCEDURE  sp_proyecta_prestamos(iMontoTotal, '0',cCapacidad_pres,pProducto,pSucursal,'1','0','','')
						INTO cCodRet, Periodo,FechaCouta,SaldoInicial,Mensualidad,Intereses,IvaInteres,Capital,SaldoFinal,DiasPeriodo,Fechaaper
						LET cMontoTotales = cMontoTotales  + Intereses + IvaInteres ;
					END FOREACH;
					LET iMontoTotalCredito= iMontoTotal + cMontoTotales;
					LET cDiasPago=  SubStr(cFecha,4,2);
					RETURN cCodret, cNumCte, cNombre,pNumSolicitud,cDiasPago,cCuenta,cIva,iMontoTotal,cInteresOrdinario,cPlazo,cInteresMoratorio,cPeriodoPlazo,cFecha,cDireccion,cCiudad,cCapacidad_pres,cApli_factor,iMontoTotalCredito   WITH RESUME;
			--SECCION PARA EL PAGARÃ 
			ELIF pTipo = 2 THEN
					--OBTIENE LA CIUDAD
					SELECT NVL(b.nombreciudad,'') 
					INTO cCiudad 
					FROM bdinteg:si_catciudades AS b, bdinteg:si_sucursales AS a
					WHERE a.estado= b.numeroestado AND a.ciudad= b.numerociudad AND a.sucursal= pSucursal;
					--OBTIENE LA DIRECCIÃN DEL CLIENTE
					SELECT TRIM(f.nombrecalle)||' '||TRIM(a.numeroextcalle)||' '||TRIM(a.numerointcalle),TRIM(g.nombrezona),TRIM(g.municipiozona), TRIM(c.estado),a.cod_postal
					INTO cCalle,cNombreZona,cMunicipio,cEstado, cCodPostal 
					FROM bdinteg:si_direcciones AS a,--bdinteg:si_ciudades as b,
					bdisolic:ss_circulo_edos AS c,bdinteg:si_catcalles f, bdinteg:si_catzonas g
					WHERE a.numcte=cNumCte AND a.secuencia=(SELECT MAX(secuencia) 
					FROM bdinteg:si_direcciones 
					WHERE numcte = a.numcte 
					AND tipo_dir = '1')
					AND c.empresa = "001" 
					AND a.estado = c.clave 
					AND a.numerociudad = g.numerociudad 
					AND a.numerocolonia = g.numerocolonia
					AND a.numerocalle = f.numerocalle;

					LET  cDireccion = TRIM(cCalle) || ' '||TRIM(cNombreZona) || ' '||TRIM(cMunicipio) ||', '||TRIM(cEstado) || ' ' || cCodPostal;
					RETURN cCodret, cNumCte, cNombre,pNumSolicitud,cDiasPago,cCuenta,cIva,iMontoTotal,cInteresOrdinario,cPlazo,cInteresMoratorio,cPeriodoPlazo,cFecha,cDireccion,cCiudad,cCapacidad_pres,cApli_factor,iMontoTotalCredito  WITH RESUME;
			--SECCION DE CODIGO PARA EL TIPO 3 (REIMPRESIÃN)
			ELIF pTipo = 3 THEN 
					SELECT num_cta
					INTO cCuenta
					FROM bdicred:sd_ctascarg
					WHERE  empresa = '001'
					AND num_credito = pNumSolicitud;
					
					
					SELECT  cat 
					INTO cIva
					FROM bdicred:"informix".sd_maecredanexocrd 
					WHERE empresa = '001'
					AND num_credito = pNumSolicitud;
					
					IF NVL(cIva,0)=0 THEN
						SELECT cat_caratula INTO cIva
						FROM bdicred:"informix".sd_definicion 
						WHERE num_producto = pProducto;
					END IF
					LET cCapacidad_pres		= 0.00;
					LET iMontoTotal			= "";
					LET cPlazo				= "";
					--SE OBTENIE LA FECHA, LA SUCURSAL Y LA DIVISA, CUANDO ES REIMPRESIÃN
					--OBTIENE EL NUM DE CUENTA CON EL QUE ESTA APERTURADO
					--SE OBTIENE LA FECHA  DEL DIA DE LA APERTURA 
					SELECT fecha_apertura, sucursal,divisa 
					INTO cDiasPago, cSucursal,cDivisa 
					FROM bdicred:sd_maecredcrd 
					WHERE num_credito = pNumSolicitud;
					LET cDiasPago = SUBSTR(cDiasPago,4,2);
					--VALOR DEL IVA A COBRAR
					SELECT apli_factor
					INTO cApli_factor
					FROM bdicred:sd_tpcomis
					WHERE cod_comis = '6903';
					FOREACH
						EXECUTE PROCEDURE  sp_proyecta_prestamos('0', '0','0',pProducto,cSucursal,'2','0',pNumSolicitud,'')
						INTO cCodRet, Periodo,FechaCouta,SaldoInicial,Mensualidad,Intereses,IvaInteres,Capital,SaldoFinal,DiasPeriodo,Fechaaper
						LET cMontoTotales = cMontoTotales  + Intereses + IvaInteres ;
						LET i = i + 1;
						IF i = 1 THEN 
							--SE OBTIENE EL PRIMER RENGLON PARA TOMAR EL MONTO DE LA MENSUALIDAD Y EL SALDO INICIAL 
							LET iMontoTotal = SaldoInicial;
							LET cCapacidad_pres = Mensualidad;
						END IF
						LET cPlazo = i;
					END FOREACH;
					LET iMontoTotalCredito= iMontoTotal + cMontoTotales;
					--CDIVISA RETORNARA EN EL CAMPO CIUDAD, YA QUE PARA LA REIMPRESIÃN DE CARATULA ES NECESARIO LA DIVISA Y NO ASI LA CIUDAD, Y CON EL OBJETIVO DE NO AGREGAR UN PARAMETRO D SALIDA MÃS SE REUTILIZARÃ EL CORRESPONDIENTE A LA CIUDAD.
					RETURN cCodret, cNumCte, cNombre,pNumSolicitud,cDiasPago,cCuenta,cIva,iMontoTotal,cInteresOrdinario,cPlazo,cInteresMoratorio,cPeriodoPlazo,cFecha,cDireccion,cDivisa,cCapacidad_pres,cApli_factor,iMontoTotalCredito   WITH RESUME;
			END IF;
	END;
END PROCEDURE
DOCUMENT
'AUTOR      : Cristian Valentina Aguilar',
'DESCRIPCION: Este procedimiento genera el reporte del contraro de prestamo personal.',
'FECHA      : 21/09/2009',
'VERSION    : 20090921.1634',
'BD         : BDISOLIC',
'Modifico	: Cristian Valentina Aguilar',
'DESCRIPCION: Se agregÃ³ la consulta para el tipo 3 (utilizado para la reimpresiÃ³n de caratula de prÃ©stamo personal,', 
			' Se separÃ³ la consulta a la tabla si_cliente (Donde trae el nombre del cliente) ya que anteriormente se consultaba haciendo un join a esta tabla',
			' Se valido que el nÃºmero de solicitud, ingresado como parametro de entrada exista',
'FECHA		: 2009/10/12',
'VERSION	: 20091012.1039',
'Modifico	: Noel Eleazar Gerardo Garcia',
'DESCRIPCION: Se le quito el plazo al sp_proyecta_prestamos para calcularlo (validacion de sp solo acepta dos parametros para calcular el tercero),', 
			' se modifico el sp_proyecta_prestamos para obtener la fecha de reeimpresion se agrega parametro de entrada (num credito y de salida fecha apertura),',
'FECHA		: 2009/10/20',
'VERSION	: 20091020.0825',
'Modifico	: Noel Eleazar Gerardo Garcia',
'DESCRIPCION: Se agrega el codigo de producto para consultar el interes ordinario y el periodo plazo,', 
'FECHA		: 2009/10/22',
'VERSION	: 20091022.0444',
'Modifico	: Noel Eleazar Gerardo Garcia',
'DESCRIPCION: Se le agregan tres parametros de entrada para calcular los resultados al cliente ,', 
'FECHA		: 2009/10/26',
'VERSION	: 20091026.1114',
'Modifico	: Noel Eleazar Gerardo Garcia',
'DESCRIPCION: Se le agregan parametro vacio para la fecha futura al sp_proyecta_prestamos,', 
'FECHA		: 2009/10/27',
'VERSION	: 20091027.0525',
'Modifico	: Noel Eleazar Gerardo Garcia',
'DESCRIPCION: Se modifica para que muestre el nombre del cliente,', 
'FECHA		: 2009/11/06',
'VERSION	: 20091106.1229',
'Modifico	: Noel Eleazar Gerardo Garcia',
'DESCRIPCION: Se modifica para la reimpresion obtener los datos aperturados se mandan vacios los parametros mto, plazo y capacidad pres al proyecta,', 
'FECHA		: 2009/11/10',
'VERSION	: 20091110.0118',
'Modifico	: Noel Eleazar Gerardo Garcia',
'DESCRIPCION: SE PARAMETRIZA EL PRODUCTO,', 
'FECHA		: 2009/12/02',
'VERSION	: 20091202.0225',
'Modifico	: Noel Eleazar Gerardo Garcia',
'DESCRIPCION: SE AGREGA EL CAT DE SD_DEFINICION,', 
'FECHA		: 2010/01/12',
'VERSION	: 1200.0000';

CREATE PROCEDURE "informix".sp_bitacora_ife(pnumcte char(9), pejecutivo char(8), psucursal char(5), pcadena_anverso CHAR(2200), 
                  pcadena_reverso CHAR(2200), pflag_idbox char(1), pflag_ws char(1), pflag_captura char(1), presultado char(50), 
                  pcausa_rechazo char(100),  pCod_Resp_IFE char(10), pResp_IFE char(50), pTime_IFE char(30),  pAccess_IFE char(30),
                  pStamp_IFE char(30), pOCR_IFE char(1), pApPat_IFE char(1), pApMat_IFE char(1), pNombre_IFE char(1), pCalleNum_IFE char(1),
                  pColCp_IFE char(1), pMpoEnt_IFE char(1), pFolioNal_IFE char(1), pAnioReg_IFE char(1), pEmision_IFE char(1), pCveElec_IFE char(1),
                  pCurp_IFE char(1), pEstado char(1), pMpio_IFE char(1), pLocalidad_IFE char(1), pSeccion_IFE char(1), pAnioEmision_IFE char(1),
                  pVigencia_IFE char(1), pEdad_IFE char(1), pSexo_IFE char(1), pANSI2_IFE char(1), pANSI7_IFE char(1), pModelo_IFE char(25))

RETURNING	 VARCHAR(5) --Codigo de Retorno

	DEFINE iSqlErr			INTEGER;
    DEFINE sErrParseo       CHAR(5);
	
	DEFINE cCodRet         CHAR(5);
    DEFINE sPonderacion     SMALLINT;
	DEFINE cSituacionCte        CHAR(1);
    DEFINE sCausaCte            SMALLINT;

    LET iSqlErr = 0;
    LET sErrParseo='';
	LET cCodRet='00000';
	LET sPonderacion = "0";
	LET cSituacionCte   ="";
	LET sCausaCte  = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr;
			END IF;
		END EXCEPTION;
		
       -- SET DEBUG FILE TO '/tmp/cristo/bitacora_ife.sql';
		--TRACE ON;

		SET LOCK MODE TO WAIT 3;
		
        IF TRIM(pModelo_IFE)<>'' THEN

            INSERT INTO si_bitacora_ife (numcte, ejecutivo, sucursal, cadena_anverso, cadena_reverso, flag_idbox, flag_ws,
                                         flag_captura, resultado, causa_rechazo, fecha, cod_resp_ife, resp_ife, time_ife, access_ife, stamp_ife,
                                         ocr_ife, appat_ife, apmat_ife, nombre_ife, callenum_ife, colcp_ife, mpoent_ife, folional_ife, anioreg_ife, 
                                         emision_ife, cveelec_ife, curp_ife, estado, mpio_ife, localidad_ife, seccion_ife, anioemision_ife, vigencia_ife, 
                                         edad_ife, sexo_ife, ansi2_ife, ansi7_ife, modelo_ife)
                                  VALUES(pnumcte, pejecutivo, psucursal, pcadena_anverso, pcadena_reverso, pflag_idbox, pflag_ws, 
                                         pflag_captura, presultado, pcausa_rechazo, current, pCod_Resp_IFE, pResp_IFE, pTime_IFE,  pAccess_IFE, pStamp_IFE, 
                                         pOCR_IFE, pApPat_IFE, pApMat_IFE, pNombre_IFE, pCalleNum_IFE,pColCp_IFE, pMpoEnt_IFE, pFolioNal_IFE, pAnioReg_IFE, 
                                         pEmision_IFE, pCveElec_IFE, pCurp_IFE, pEstado, pMpio_IFE, pLocalidad_IFE, pSeccion_IFE, pAnioEmision_IFE, pVigencia_IFE, 
                                         pEdad_IFE, pSexo_IFE, pANSI2_IFE, pANSI7_IFE, pModelo_IFE);

            EXECUTE PROCEDURE sp_parsea_cadena_idbx (pnumcte) INTO sErrParseo;
			
			IF TRIM(pCod_Resp_IFE) IN ('90','91','92','93','94') THEN
				IF pOCR_IFE='F' OR TRIM(pApPat_IFE)='F' OR TRIM(pApMat_IFE)='F' OR TRIM(pNombre_IFE)='F' THEN
					LET presultado = 'Falso';
					LET pcausa_rechazo = 'Datos NO Validos de Acuerdo al WS del INE';
					UPDATE si_bitacora_ife SET resultado=presultado, causa_rechazo=pcausa_rechazo WHERE numcte=pnumcte and fecha=current;
				END IF;
			END IF;
			
			 IF TRIM(presultado) = 'Verdadero' THEN
			 
				 EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(5,'001',pNumCte,'P',109,'', '','', '', '','','')
				 INTO cCodRet, sPonderacion,cSituacionCte,sCausaCte;
			
			 END IF;
			 
        END IF;

		RETURN '00000';
	END
END PROCEDURE;