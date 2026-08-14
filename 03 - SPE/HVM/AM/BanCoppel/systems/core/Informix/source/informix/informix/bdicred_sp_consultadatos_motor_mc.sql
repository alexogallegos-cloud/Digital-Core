CREATE PROCEDURE "informix".sp_consultadatos_motor_mc(pEmpresa CHAR(4), pNumSol CHAR(20))
RETURNING
	CHAR(6) 	   as cCodRet,
	CHAR(200)	   as cRutaArchivo,
	CHAR(20)	   as cSolBanco,
	CHAR(20)	   as cNumCteBco;
-------------------------------------------- DEFINICION DE VARIABLES ---------------------------
--DEFINICION DE VARIABLES DATOS DEL CLIENTE
DEFINE cNumCte                  CHAR(20);      --nÃºmero de cliente Coppel
DEFINE cNumCteBco		        CHAR(20);      --nÃºmero de cliente Bancoppel
DEFINE cB_INE		            INTEGER;      --Flag de validaciÃ³n INE B_ife
DEFINE cCurp 					CHAR(20);      --Corresponde al CURP del cliente 
DEFINE dtFechaCte			    CHAR(10);          --Corresponde a la fecha de alta del cliente
DEFINE dtFechaNac 				CHAR(10);          --Corresponde a la Fecha de Nacimiento del cliente 
DEFINE cSexo                    CHAR(1);       --Corresponde al genero del cliente 
DEFINE cEdo_Civil               CHAR(50);      --Correspojde al estado civil del cliente -**
DEFINE iTiem_Edo_Civil          INTEGER;      --Corresponde al tiempo del estado civil 
DEFINE iTiem_Edo_Civil_meses    INTEGER;      --Corresponde al tiempo de estado civil en  meses
DEFINE cEscolaridad             CHAR(50);      --Corresponde al grÃ¡do mÃ¡ximo de estudios del cliente 
DEFINE cHabita_en               CHAR (50);     --Tipo de vivienda del cliente -**
DEFINE cTipoResidencia          CHAR (50);     --Corresponde al tipo de residencia
DEFINE cEntidad                 CHAR(50);      --Corresponde a la entidad de residencia del cliente -**
DEFINE vLocalidad        		VARCHAR(200);  -- Corresponde a la localidad del cliente
DEFINE iTiem_Residencia   		INTEGER;      --Corresponde al tiempo de residencia  
DEFINE cGeoCte		  		    CHAR(20);      --Corresponde a las cordenadas de localizaciÃ³n del cliente 
DEFINE cFlagGeoMov			    CHAR(1);       --Corresponde al flag de geolocalizaciÃ³n 
DEFINE iFlagGeoSuc		        VARCHAR(2);       --Correspode al flag de geolocalizacion diderente a la ubicaciÃ³n de la sucursal
DEFINE cTelCasa                 CHAR(13);      --Corresponde al telÃ©fono de casa del cliente
DEFINE cTelTrabajo              CHAR(13);      --Corresponde al telÃ©fono de trabajo del cliente
DEFINE iBanderaReferencia		CHAR(1);       --Corresponde a un flag de coincidencia de las referencias telefÃ³nicas vs las enviadas a supervisiÃ³n
DEFINE sValida_Cel	            VARCHAR(2);      --iValidaCel (nÃºmero de tel celulares activos y validados deberÃ­a ser max=1
DEFINE cOcupacion               CHAR(50);      --Corresponde a la ocupaciÃ³n del cliente
DEFINE iTiem_Ocupacion          INTEGER;      --Corresponde al tiempo que lleva laborando
DEFINE cProfesion             	CHAR(3);       --profesiÃ³n del cliente
DEFINE sId_actividad		    SMALLINT;      --ID de la actividad que realiza el cliente
DEFINE cDescAct 			    CHAR(60);      --descripciÃ³n de la actividad que realiza el cliente
DEFINE sId_subactividad	        SMALLINT;      --ID de la sub- actividad que realiza el cliente
DEFINE vDescSubAct      		VARCHAR (50);  --descripciÃ³n de la actividad que realiza el cliente
DEFINE mIngreso_Mensual			DECIMAL;         --Corresponde al ingreso mensual reportado por el cliente
DEFINE mIngreso_Neto            DECIMAL;         --Corresponde al ingreso mensual neto del cliente ** validar si viene de informaciÃ³n de coppel
DEFINE cCompIngresos			CHAR(1);       --Corresponde al flag comprobante de ingresos del cliente
DEFINE dIngresoCac              DECIMAL(14,2); --Corresponde al ingreso del cliente con comprobante de ingresos valido por Mesa de Control
DEFINE sCompValido      		SMALLINT;      --Corresponde al flag de validaciÃ³n por parte de mesa de control del comprobante de ingreso
DEFINE sFlagHuella              CHAR(1);      --corresponde a la coincidencia o no de la hulla del cliente banco vs coppel
DEFINE cCod_Ult_Identif         CHAR(2);       --Corresponde a la Ãºltima identificacion presentada por el cliente ( INE,PASAPORTE....ETC)
DEFINE sEdadCte					SMALLINT;       --Corresponde a la edad del cliente
DEFINE pMeses_historia_grupo 	SMALLINT;       --Corresponde a
DEFINE pSituacion_pago_grupo 	DECIMAL(5,2);   --Corresponde a

--DEFINICION DE VARIABLES DE CUENTA COPPEL
DEFINE dtUltimaCompra           CHAR(10) ;           --Fecha Ãºltima compra
DEFINE cPuntualidadCoppel       CHAR(2);        --clasicficaciÃ³n del cliente Coppel de acuerdo al comportamiento de pago en todas sus cuentas
DEFINE dEficienciaCoppel    	DECIMAL(5,2);   --Calculo que realiza el sistema de historial de pagos del cliente Coppel
DEFINE dSituacionPagoCoppel     CHAR(8);   --calculo que realiza el sistema de historial de pagos del cliente Coppel
DEFINE iCredDigitalesAct        INTEGER;        --cuenta de crÃ©ditos digitales activos
DEFINE cSituacionEspecial       CHAR(1);        --Corresponde a la revisiÃ³n de situaciones especiales que pueda tener el cliente en coppel
DEFINE sCausaSituacion          SMALLINT;       --Causa de la situaciÃ³n especial
DEFINE cMotivoRech            	CHAR(1);        --Motivo del rechazo en Coppel
DEFINE cDescMvo             	CHAR(300);      --descripciÃ³n del motivo del rechazo en Coppel 
DEFINE sHist_meses              SMALLINT;       -- tiempo de experiencia crediticia en Coppel del cliente pendiente -->Preca
DEFINE cCteExcep		      	CHAR(20);       --Cliente coppel que presenta excepciÃ³n
DEFINE dtmaxFechaAperturaDelProducto CHAR(10) ;      --fecha mÃ¡xima de apertura del producto de porcentaje mÃ¡s bajo y si existe empate se toma el mÃ¡s reciente , no son CC, FF
DEFINE cFechaUltimoPago         CHAR(13);       --fecha ultimo pago
DEFINE dtMinFechaAperturasinFF  CHAR(10) ;           --MÃ­nima fecha de apertura de las cuentas que no son FFen sd_maecredcrd
DEFINE dtminFechaApertura       CHAR(10) ;           --fecha minima de apertura que tenga el cliente
DEFINE mAbonoTotal              DECIMAL(14,2);    --abono total de sus cuentas Coppel
DEFINE mAbonoVencidoTotal       DECIMAL(14,2);    --Abono vencido total vencido de sus cuentas Coppel
DEFINE mAbonoMuebles         	DECIMAL(14,2);    --Abono mensual del cliente en muebles
DEFINE mAbonoPrestamos       	DECIMAL(14,2);    --Abono mensual del cliente en prestamo
DEFINE mAbonoRopa            	DECIMAL(14,2);    --Abono mensual del cliente en ropa
DEFINE mAbonoAire    		    DECIMAL(14,2);    --Abono mensual del cliente en tiempo aire
DEFINE mAbonoAfiliados 	        DECIMAL(14,2);    --Abono mensual del cliente en afiliados
DEFINE mAbonoReestructura 	    DECIMAL(14,2);    --Abono mensual del cliente en reestructuras
DEFINE mVencidoMuebles 	        DECIMAL(14,2);    --vencido mensual del cliente en muebles
DEFINE mVencidoRopa 	        DECIMAL(14,2);    --vencido mensual del cliente en ropa
DEFINE mVencidoPrestamos        DECIMAL(14,2);    --vencido mensual del cliente en prestamo personal
DEFINE mVencidoAire             DECIMAL(14,2);    --vencido mensual del cliente en tiempo aire
DEFINE mVencidoAfiliados        DECIMAL(14,2);    --vencido mensual del cliente en afiliados
DEFINE mVencidoReestructura     DECIMAL(14,2);    --vencido mensual del cliente en reestructura
DEFINE mTotalVencido            DECIMAL(14,2);    --total vencido de sus cuentas Coppel
DEFINE mPagoMinimo              DECIMAL(14,2);    --Corresponde al pago mÃ­nimo del cliente
DEFINE mLinea_tienda            DECIMAL(14,2);    --Corresponde a la lÃ­nea de crÃ©dito del cliente
DEFINE cTipoSolOS		    	CHAR(1);        --Corresponde al tipo de solicitud ( titular/prospecto) de la Ãºltima OS registrada
DEFINE mSaldoRopa				DECIMAL;          --Corresponde al saldo pendinete de ropa
DEFINE mSaldoMuebles			DECIMAL;          --Corresponde al saldo pendinete de muebles
DEFINE mSaldoPrestamos			DECIMAL;          --Corresponde al saldo pendinete de ropprestamos

--DEFINICION DE VARIABLES DE BANCO
DEFINE mCompro_banco            	DECIMAL (14,2);   --Corresponde a los compromisos banco del cliente 
DEFINE dComprobanco_TDC         	DECIMAL(14,2);  --Corresponde a los compromisos de tarjeta de crÃ©dito Bancoppel
DEFINE mCompro_bancoPP				DECIMAL(14,2);
DEFINE iMaxSalVencidoBancoppel  	INTEGER;        --MÃ¡ximo saldo vencido de sus cuentas Bancoppel sin considerar status CC,FF
DEFINE iCtas_StatusCV           	INTEGER;        --Corresponde al nÃºmero de cuentas que tienen estatus CV ( crÃ©dito vendido Bancoppel) sin considerar estatus CC,FF
DEFINE iCred_StatusFC           	INTEGER;        --Corresponde al conteo de crÃ©ditos con estatus FC
DEFINE iCred_StatusFF_restru    	INTEGER;        --Corresponde al conteo de crÃ©ditos con estatus FC en maecred y que no tienen FF en maecredcrd
DEFINE iCredits_riesgoD         	INTEGER;        --Corresponde a situaciones especiales,no se considderan estatus CC,FF
DEFINE iCredits_riesgoE        		INTEGER;        --Corresponde a situaciones especiales,no se considderan estatus CC,FF
DEFINE iCredits_riesgoC         	INTEGER;        --Corresponde a situaciones especiales,no se considderan estatus CC,FF
DEFINE iMaxMontoReserva         	INTEGER;        --Corresponde a situaciones especiales,no se considderan estatus CC,FF
DEFINE iCred_StatusDif_FF       	INTEGER;        --Corresponde a los crÃ©ditos con estatus diferente de FF en sd_maecredcrd
DEFINE dMaxSalVencidoCRD        	DECIMAL(18,2);  --Corresponde al mÃ¡ximo saldo vencido de los creditdos con estatus distinto FF y producto <> 6011
DEFINE iCuentasStatusCVsinFF    	INTEGER;        --Corresponde al nÃºmero de cuentas que tienen estatus CV ( crÃ©dito vendido Bancoppel) sin considerar estatus FF
DEFINE iCtas_StatusDif_FF_6011  	INTEGER;        --Corresponde al # de cuentas con estatuus <> FF y producto =6011
DEFINE iCtas_StatusFF_6011      	INTEGER;        --Corresponde al # de cuentas con estatuus = FF y producto =6011
DEFINE iCredRiesgoD_sinFF		 	INTEGER;        --Corresponde a situaciones especiales, no se considderan estatus FF
DEFINE iCredRiesgoE_sinFF			INTEGER;        --Corresponde a situaciones especiales,no se considderan estatus FF
DEFINE iCredRiesgoC_sinFF		 	INTEGER;        --Corresponde a situaciones especiales,no se considderan estatus FF
DEFINE dmaxMontoReservaRiesgoC_sinFF DECIMAL(18,2);  --Corresponde a situaciones especiales,no se considderan estatus FF
DEFINE iReprestamos             	INTEGER;        --correpsonde al flag represtamos
DEFINE cSolBanco					CHAR(20);
DEFINE sFlag_oro					SMALLINT;       --Corresponde al flag de tarjeta Oro
DEFINE vClvEdoCob       			VARCHAR(10);    --Corresponde a la variable Clave Estado Cobranza 
DEFINE cEstado                      CHAR(30);
DEFINE cMunicipio                   CHAR(30);
DEFINE cVigenciaBancoppel       	CHAR(20);       --Vigencia Bancoppel 
DEFINE dLineaBanco              	DECIMAL(14,2);  --LÃ­nea de utilizaciÃ³n  Bancoppel
DEFINE cResultadoOsTel          	CHAR(1);        --Corresponde al resultado de la Orden de SupervisiÃ³n telÃ©fonico
DEFINE cTieneOstel              	CHAR(1);        --Corresponde al flag que identifica si la solicitud tiene o no Orden de supervisiÃ³n telÃ©fonica
DEFINE cEnvioCat                	CHAR(1);        --Corresponde al flag que identifica si  la solicitud se envio al Centro de atenciÃ³n telefÃ³nica CAT
DEFINE iSolMc				    	INTEGER;        --Corresponde al numero de veces que se ha enviado la solicitud a mesa de control
DEFINE iSolMcAux		        	INTEGER;        --Corresponde al numero de veces que se ha enviado la solicitud referencia a mesa de control
DEFINE iSecuenciaOs			    	VARCHAR(20);        --Corresponde a la secuencia de orden de supervisiÃ³n  de la Ãºltima OS registrada
DEFINE cStatusRespOs		    	CHAR(1);        --Corresponde al estatus de la respuesta de orden de supervisiÃ³n  de la Ãºltima OS registrada
DEFINE dtFecha_Respuesta			CHAR(10);           --Corresponde a la fecha de respuesta de la Orden de SupervisiÃ³n  de la Ãºltima OS registrada
DEFINE cMotivoRechBcpl  			CHAR(1); 		--Motivo de rechazo BanCoppel
DEFINE cDescripcion					CHAR(60);
DEFINE cRiesgoViviendaCpl  			CHAR(1);
DEFINE cRiesgoViviendaBcpl  		CHAR(1);
DEFINE cActRiesgoCpl        		CHAR(1);
DEFINE cActRiesgoBCpl				CHAR(1);
DEFINE cDescpRiesgo					CHAR(120);
DEFINE cEjecucion	  				CHAR(1);


--DEFINICION DE VARIABLES DE BURÃ
DEFINE dCompromisos                 DECIMAL(14,2); --Corresponde a los compromisos de todas las cuentas del cliente BC
DEFINE dMontoUdis                   DECIMAL(14,2); --monto en UDIS de la observaciÃ³n mÃ¡s reciente
DEFINE cInstitucion                 CHAR(2);       --nombre de la instituciÃ³n de la observaciÃ³n mÃ¡s reciente
DEFINE cClvObser                    CHAR(2);       --clave de observaciÃ³n mÃ¡s reciente (vStatus) 
DEFINE iNumCtas_ClvOb               VARCHAR(20);       --NÃºmero de cuentas que tienen clave de observaciÃ³n FD,PS,SU,CV,PC,SG,SP,SR,UP,FR en BurÃ³, no considera comunicaciones y servicios
DEFINE iMax_MOP                     VARCHAR(20);       --MÃ¡ximo MOP actual, no considera Comunicaciones y servicios,cuentas Bancoppel con clave de observaciÃ³n RV
DEFINE cInstCta_MayorMOP            VARCHAR(30);       --Nombre de instituciÃ³n de cuenta con mayor MOP
DEFINE dMonto_UDIS_MayorMOP         DECIMAL(14,2); --Monto UDIS de  cuenta con mayor MOP
DEFINE iMax_MOP_Hist_6m             VARCHAR(20);       --MÃ¡ximo_MOP histÃ³rico 6 meses de cuentas con >=100 UDIS
DEFINE cInstCta_MayorMOP_6m         CHAR(2);       --Nombre de instituciÃ³n de cuenta con mayor MOP histÃ³rico 6 meses de cuentas con >=100 UDIS
DEFINE dMontoUDIS_MM_6m             DECIMAL(14,2); --Monto UDIS de cuenta con mayor MOP histÃ³rico 6 meses de cuentas con >=100 UDIS
DEFINE iMM_Histo_12m                VARCHAR(20);       --MÃ¡ximo_MOP histÃ³rico 12 meses de cuentas con >=100 UDIS
DEFINE cInstCta_MayorMOP_12m        CHAR(2);       --Nombre de instituciÃ³n de cuenta con mayor MOP histÃ³rico 12 meses de cuentas con >=100 UDIS
DEFINE dMontoUDIS_MM_12m            DECIMAL(14,2); --Monto UDIS de cuenta con mayor MOP histÃ³rico 12 meses de cuentas con >=100 UDIS
DEFINE iNumCtasMOP_4_12m            INTEGER;       --NÃºmero de cuentas MOP =4 Ãºltimos 12 meses, UDIS >=100 & Sin comunicaciones ni servicios
DEFINE iNumCtasMOP_5_12m            INTEGER;       --NÃºmero de cuentas MOP =5 Ãºltimos 12 meses, UDIS >=100 & Sin comunicaciones ni servicios
DEFINE iNumCtasMOP_mayor5_12m       INTEGER;       --NÃºmero de cuentas MOP >5 Ãºltimos 12 meses, UDIS >=100 & Sin comunicaciones ni servicios
DEFINE iMOP4_12mCon1o2   			INTEGER;       --NÃºmero de cuentas MOP =4 Ãºltimos 12 meses, UDIS >=100, no considera telecomunicaciones ni servicios, deberÃ¡ considerar los 6 meses mÃ¡s recientes con valores 1 0 2
DEFINE iMOP5_12mCon1o2   			INTEGER;       --NÃºmero de cuentas MOP =5 Ãºltimos 12 meses, UDIS >=100, no considera telecomunicaciones ni servicios, deberÃ¡ considerar los 6 meses mÃ¡s recientes con valores 1 0 2
DEFINE iMOPmayor5_12mCon1o2			INTEGER;       --NÃºmero de cuentas MOP >5 Ãºltimos 12 meses, UDIS >=100, no considera telecomunicaciones ni servicios, deberÃ¡ considerar los 6 meses mÃ¡s recientes con valores 1 0 2
DEFINE cInstCta_MayorMOP_30m        CHAR(2);       --Nombre de instituciÃ³n de cuenta con mayor MOP histÃ³rico 30 meses de cuentas con >=100 UDIS
DEFINE dMontoUDIS_MM_Rech           DECIMAL(14,2); --Monto UDIS de cuenta con mayor MOP, de cuenta que provoca el rechazo
DEFINE iNumCtasMOP_4_30m            INTEGER;       --NÃºmero de cuentas MOP =4 Ãºltimos 30 meses, UDIS >=100 & Sin comunicaciones ni servicios
DEFINE iNumCtasMOP_5_30m            INTEGER;       --NÃºmero de cuentas MOP =5 Ãºltimos 30 meses, UDIS >=100 & Sin comunicaciones ni servicios
DEFINE iNumCtasMOP_mayor5_30m       INTEGER;       --NÃºmero de cuentas MOP >5 Ãºltimos 30 meses, UDIS >=100, sin comunicaciones ni servicios
DEFINE iCtasMOP_4_30mCon1o2         INTEGER;       --NÃºmero de cuentas MOP =4 Ãºltimos 30 meses, UDIS >=100, no considera telecomunicaciones ni servicios, deberÃ¡ considerar los 12 meses mÃ¡s recientes con valores 1 0 2
DEFINE iCtasMOP_5_30mCon1o2         INTEGER;       --NÃºmero de cuentas MOP =4 Ãºltimos 30 meses, UDIS >=100, no considera telecomunicaciones ni servicios, deberÃ¡ considerar los 12 meses mÃ¡s recientes con valores 1 0 2
DEFINE iCtasMOP_mayor5_30mCon1o2    INTEGER;       --NÃºmero de cuentas MOP >5 Ãºltimos 30 meses, UDIS >=100, no considera telecomunicaciones ni servicios, deberÃ¡ considerar los 12 meses mÃ¡s recientes con valores 1 0 2
DEFINE cInstitucionMMOP_provocaRech CHAR(2);       --Nombre de instituciÃ³n de cuenta con mayor MOP (Ãºltimos 30 dÃ­as),de cuenta que provoca el rechazo
DEFINE dMontoUDIS_30d_Rech          DECIMAL(14,2); --Monto UDIS de cuenta con mayor MOP (Ãºltimos 30 dÃ­as), de cuenta que provoca el rechazo
DEFINE iMM_Histo_30m                VARCHAR(20);       --MÃ¡ximo_MOP histÃ³rico 30 meses de cuentas con >=100 UDIS (Se jerarquizan por fecha_reporte, " para mns de salida")
DEFINE cInstCta_MM_30m_Rech         CHAR(2);       --Nombre de instituciÃ³n de cuenta con mayor MOP (maximo Mop histrico 30 meses..) de cuenta que provoca el rechazo
DEFINE dMotoUDIS_MM_30m_Rech        DECIMAL(14,2); --Monto UDIS de cuenta con mayor MOP (maximo Mop histrico 30 meses..) de la cuenta que provoca el rechazo
DEFINE iMM_act_Bancos               VARCHAR(20);       --MÃ¡ximo_MOP actual de bancos
DEFINE iMM_hist_alto_Bancos         VARCHAR(20);       --MÃ¡ximo_MOP historico mÃ¡s alto bancos
DEFINE iMM_hist_Bancos              VARCHAR(20);       --MÃ¡ximo_MOP historico bancos
DEFINE iCtasBancosMOP_tl26          INTEGER;       --NÃºmero de cuentas del cliente que son "Banco,Bancos,Bancoppel" ,tl06 = R ( revolvente) y con MOP actual (tl26) en  MOP 2,3,4,5,6,7,96,97,99
DEFINE iCtasBancosMOP_tl38          INTEGER;       --NÃºmero de cuentas del cliente que son "Banco,Bancos,Bancoppel" ,tl06 = R ( revolvente) y con MOP historico mÃ¡s alto (tl38) en MOP 2,3,4,5,6,7,96,97,99
DEFINE iCtasBancosMOP_tl27          INTEGER;       --NÃºmero de cuentas del cliente que son "Banco,Bancos,Bancoppel" , tl06 = R ( revolvente) y con MOP historico (tl27) en MOP 2,3,4,5,6,7,96,97,99
DEFINE iCtasBancosMOP_act_hist_alto INTEGER;       --Numero de cuentas de Bancos con MOP actual, historico e historico mÃ¡s alto ( incluye Bancoppel)
DEFINE iCtasComServMOP_tl26         INTEGER;       --NÃºmero de cuentas del cliente que son "'COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL'"  y con MOP actual (tl26) en MOP 3,4,5,6,7,96,97,99
DEFINE iCtasComServMOP_tl38         INTEGER;       --NÃºmero de cuentas del cliente que son "'COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL'"  y con MOP historico mÃ¡s alto  (tl38) en MOP 3,4,5,6,7,96,97,99
DEFINE iCtasComServMOP_tl27         INTEGER;       --NÃºmero de cuentas del cliente que son "'COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL'"  y con MOP historico  (tl27) en MOP 3,4,5,6,7,96,97,99
DEFINE iCtasCSM_act_hist_alto       INTEGER;       --NÃºmero de cuentas del cliente que son "'COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL'"  y con MOP actual o MOP historico o MOP historico mÃ¡s alto en MOP 3,4,5,6,7,96,97,99
DEFINE iCtasComServMOP_tl26_12m     INTEGER;       --NÃºmero de cuentas del cliente que son "'COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL'"  y con MOP actual (tl26) y menos de 12 meses en MOP 2,3,4,5,6,7,96,97,99
DEFINE iCtasComServMOP_tl38_12m     INTEGER;       --NÃºmero de cuentas del cliente que son "'COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL'"  y con MOP historico mÃ¡s alto  (tl38) y menos de 12 meses en MOP 2,3,4,5,6,7,96,97,99
DEFINE iCtasComServMOP_tl27_12m     INTEGER;       --NÃºmero de cuentas del cliente que son "'COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL'"  y con MOP historico  (tl27)  y menos de 12 meses en MOP 2,3,4,5,6,7,96,97,99
DEFINE iCtasCSM_ActHistAlto_12m     INTEGER;       --NÃºmero de cuentas del cliente que son "'COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL'"  y con MOP actual o MOP historico o MOP historico mÃ¡s alto  y menos de 12 meses en MOP 2,3,4,5,6,7,96,97,99
DEFINE iMaxMOP_actBancos            VARCHAR(20);       --MÃ¡ximo_MOP actual de bancos reportadas el Ãºltimo aÃ±o
DEFINE iMaxMOP_histAltBancos        VARCHAR(20);      --MÃ¡ximo_MOP historico mÃ¡s alto de bancos reportadas el Ãºltimo aÃ±o
DEFINE iMaxMOP_histBancos           VARCHAR(20);      --MÃ¡ximo_MOP historico de bancos reportadas el Ãºltimo aÃ±o
DEFINE iMaxMOP_actCtas              VARCHAR(20);      --Maximo_MOP actual de todas las cuentas
DEFINE iMaxMOP_histAltCtas          VARCHAR(20);       --Maximo_MOP histroico mÃ¡s alto de todas las cuentas
DEFINE iMaxMOP_histCtas             VARCHAR(20);       --Maximo_MOP historico de todas las cuentas
DEFINE iCtas_SinComServ             INTEGER;       --NÃºmero de cuentas sin comunicaciones ni servicios
DEFINE iCtas_SinComServ_pagar       INTEGER;       --NÃºmero de cuentas sin comunicaciones ni servicios con monto a pagar >0
DEFINE iNumCtas_SHBr                INTEGER;       --NÃºmero de cuentas, son de servicios ,hipoteca y bienes raÃ­ces
DEFINE iNumCtas_SHBr_pagar          INTEGER;       --NÃºmero de cuentas con monto a pagar >0, servicios (tl02), hipoteca (tl06=M),bienes raÃ­ces (tl07=RE)



--DEFINICION DE VARIABLES DE SOLICITUD
DEFINE dtFechaSolicitud         CHAR(10);
DEFINE cCteProsp		        CHAR(20);       --numero de cliente prospecto
DEFINE cStatusSol_CteProsp      CHAR(2);        --Corresponde al estatus de la solicitud del cliente prospecto 
DEFINE cTipo_Alta_CteProsp      CHAR(1);        --Tipo de Alta Cte Prospecto
DEFINE cCteProspVig			    CHAR(20);       --Corresponde a la vigencia del cliente  prospecto
DEFINE cSucursal   			    CHAR(4);        --Numero de Sucursal
DEFINE iFlagEmpleado            CHAR(1);       --Corresponde al flag de empleado Coppel y/o Bancoppel
DEFINE sEntidad_Localidad		CHAR(1);       --Corresponde a la variable entidad/localidad 
DEFINE iCanal_Sol         	    CHAR(1);        --Corresponde al canal por el cual se originÃ³ la solicitud
DEFINE iCanalV1				    CHAR(2);        --Canal de solicitud ingresada por prospectÃ©o
DEFINE cTp_solicitud            CHAR(1);        --tipo de solicitud
DEFINE cNum_Producto            CHAR(4);        --tipo de producto
DEFINE cStatusSolicitud         CHAR(2);        --estatus de la solicitud
DEFINE cCausa_Sol			    CHAR(3);        --causa del rechazo de la solicitud
DEFINE cTipoRech                CHAR(1);        --tipo de rechazo de la solicitud
DEFINE cTipoGrupo 			    CHAR(2);        --grupo de evaluaciÃ³n al cual pertenece la solicitud
DEFINE cSituacion  				CHAR(1); 		--Situacion del producto de porcentaje mÃ¡s bajo y si existe empate se toma el mÃ¡s reciente 
DEFINE cProducto                CHAR(4);        --producto de porcentaje mÃ¡s bajo y si existe empate se toma el mÃ¡s reciente
DEFINE dminProcentajeProductoMasReciente DECIMAL(6,2);   --porcentaje mÃ­nimo del producto mÃ¡s reciente
DEFINE sFlagForzarEnvioMC       CHAR;       --Etatus de la Ãºltima solicitud que no terminÃ³ en (AN,PC) y que su producto si se envÃ­a a mesa de control (6300,6400,7600,7700,9100,9300,6001,6800)
DEFINE cNumSol_Os			    CHAR(20);       --Corresponde al numero de solicitud de la Orden de supervisiÃ³n  de la Ãºltima OS registrada
DEFINE sScore_coppel            SMALLINT;       --Corresponde a los puntos asignados en la evaluaciÃ³n del score de Coppel
DEFINE dValor_3s                DECIMAL(14,2);  --Corresponde al valor del score  de Circulo de crÃ©dito 
DEFINE cFolioMovil         	    CHAR(20);       --Folio solicitud movil
DEFINE cStatusMovil             CHAR(1);        --Estatus solicitud movil
DEFINE sBc_Score                SMALLINT;  		--valor del score ( Indica la calificaciÃ³n del score solicitado "nÃºmero positivo")
DEFINE cInstitucionClvExclusionMasReciente CHAR(2); -- Corresponde a la INSTITUCION de exclusion mÃ¡s reciente
DEFINE vClvExclusionMasReciente INTEGER;	-- Corresponde a la CALVE de exclusion mÃ¡s reciente



--DEFINICION DE VARIABLES DE PARAMETRICOS
DEFINE HR0048               INTEGER;       --Number of ever satisfactory trades open 12 months or older (NÃºmero de cuenta abiertas con 12 meses o mÃ¡s).
DEFINE HR0050               VARCHAR(20);       --# de cuentas abiertas en los ultimos 6 meses o mas. Grupo 53
DEFINE TR0002               VARCHAR(20);        --NUMERO PROMEDIO DE MESES
DEFINE TR0001               VARCHAR(20);      --EL MES MAXIMO DE LA CUENTA ABIERTA MAS VIEJA
DEFINE IQ0002               VARCHAR(20);       --Numero de consultas al cliente por instituciÃ³n
DEFINE BC_421               DECIMAL(18,2); --Corresponde a la variable que se calcula actualmente
DEFINE BC_85               VARCHAR(20);       --Corresponde a la variable que se calcula actualmente
DEFINE BC_93               VARCHAR(20);        --Corresponde a la variable que se calcula actualmente
DEFINE BC1                  INTEGER;       --la mÃ¡xima cantidad de meses entre la fecha y la fecha de apertura de la cuenta
DEFINE BC_101               INTEGER;       --Corresponde a la variable que se calcula actualmente
DEFINE BC_117               INTEGER;       --Corresponde a la variable que se calcula actualmente
DEFINE BC_119               INTEGER;       --Corresponde a la variable que se calcula actualmente
DEFINE BC_20                INTEGER;       --Corresponde a la variable que se calcula actualmente
DEFINE UT0034               INTEGER;       --Utilization percent of bank revolving trades (Porcentaje de utilizaciÃ³n en cuentas revolventes bancarias).
DEFINE dSaldo_linea_credi	VARCHAR(30);  --Corresponde a variables para prestamo
DEFINE dSaldo_limit_credi   VARCHAR(30);  --Corresponde a variables para prestamo


--DEFINICION DE VARIABLES DE EVALUACIÃN
DEFINE cRTipo3           CHAR(1);       --Corresponde a la clave de envÃ­o a OS ( A,R,D.....)
DEFINE cVigSolOS         CHAR(1);       --Corresponde si la solicitud estÃ¡ vigente o vencida para envÃ­o a OS (vVigente)
DEFINE sBuenPagos        CHAR(30);      --Corresponde al buen pago 
DEFINE sFlagBuenPago12   CHAR(1);      --Corresponde al flag de buen pago 12meses
DEFINE sFlagBuenPago30   CHAR(1);      --Corresponde al flag de buen pago 30meses
DEFINE cNuevoStatusOstel CHAR(2);       --Corresponde al estatus despuÃ©s de la OS tel*** Oscar solicita tabla **rev
DEFINE dMontoOtorgado    DECIMAL(18,4); --Corresponde al monto otorgado 
DEFINE mCapacidad_pago   DECIMAL(14,2);   --Corresponde a la capacidad de pago 
DEFINE iExisteCliente    INTEGER;       --Conteo de solicitudes del cliente para producto Coppel con estatus diferente de 'PC','AN','MC'
DEFINE cTipo_movimiento  CHAR(1);       --Correspode al tipo de movimiento ( U,M) unico, mixto 
DEFINE dCompromisosCac   DECIMAL(14,2); --Compromisos registrados en las tabla ss_solicitudes_cac ( aparentemenete son los compromisos validados por Mesa de Control, ya no se usa)
DEFINE dtFechaAux        CHAR(10);          --Fecha de la Ãºltima consulta realizada que no sea de Bancoppel
DEFINE dTasa             DECIMAL(9,6);  --
DEFINE dtasaMora		 DECIMAL(9,6);
DEFINE cOrigenSol        CHAR(1);       --Corresponde al origen ( contiene T,B,vacio)*
DEFINE cOrigenCte        CHAR(1);       --Corresponde al origen del cliente ( prospecto, titular...)
DEFINE mImporte_hip      DECIMAL;         --Corresponde al monto de la hipoteca del cliente
DEFINE iMeses_hist_Val   INTEGER;      	--NÃºmero de de meses de historia validos del cliente de acuerdo a su edad
DEFINE sCteLargo8        SMALLINT;      --Determina si es grupo 8
DEFINE sCteLargo         CHAR;      --Corresponde a clientes con cuenta de captaciÃ³n en su primer producto ( solo dÃ©bito)
DEFINE vgrupoA 			 SMALLINT;		--Conteo por empresa y cliente de la tabla sd_grupo_cliente
DEFINE NumSolMovil		 CHAR(20);		--Numero de solicitud movil de la tabla ss_solicitudes_movil
DEFINE iFlag2credito 	 SMALLINT;		--Variable flag sale del procedure sp_valida2Credito
DEFINE cCodRetDoc		CHAR(6);

------------------------------------------------------------------------------
------------------  DEFINICION DE VARIABLES DE REINGENIERIA ------------------
------------------------------------------------------------------------------

DEFINE mosSncOldestRevTLOpnd					 INTEGER; ----------------------
DEFINE numInq0to2Mos							 INTEGER;
DEFINE pctBankILTL								 DECIMAL(18,2);
DEFINE pctTL30pDaysEverColl						 CHAR(10); --fico
DEFINE avgMosInFileTLRptd0To2Mos				 CHAR(10); --fico
DEFINE highestUtilOnBankNatlRevTL				 INTEGER; ----------------------
DEFINE lowestRatingIL							 INTEGER;
DEFINE lowestRatingRevOpen						 INTEGER;
DEFINE maxDelq0To11Mos							 CHAR(10); --fico
DEFINE mosSncOldestBankNatlRevOpenTLOpnd		 INTEGER;
DEFINE netFrctTLOpnd0To35Mos					 CHAR(10); --fico
DEFINE totBalDelqTL								 DECIMAL(18,2);
DEFINE numFinInq0to5Mos							 INTEGER;
DEFINE maxDelqEver								 INTEGER;
DEFINE pctInq0To2MosByInq0To11Mos				 CHAR(10); --fico
DEFINE numRetTLOpnd0to5Mos						 INTEGER; --fico
DEFINE num_sumasaldoscuentasabiertas			 DECIMAL(18,2);
DEFINE num_sumalineascuentasabiertas			 DECIMAL(18,2);
DEFINE pct_usocuentasabiertas				 	 DECIMAL(18,2);
DEFINE num_antiguedadpromediocuentas12meses		 INTEGER; ----------------------
DEFINE num_consultasfinanciera					 INTEGER;
DEFINE num_maxplazodias							 INT8;
DEFINE clv_tipoproductocrediticio				 CHAR(2);	
DEFINE num_montofechamorosamasgravemasreciente	 DECIMAL(18,2);
DEFINE num_totalperiodosreportados				 INTEGER;
DEFINE num_porcentajecorrientepromedio			 DECIMAL(18,2);
DEFINE num_lineacreditopromedio					 INTEGER;
DEFINE num_arrendamiento						 INTEGER;
DEFINE num_tiendacomercial						 INTEGER;
DEFINE clv_worstcurrentmop						 INTEGER;	
DEFINE num_direcciones							 INTEGER;
DEFINE num_montopeoratrasohistoricomasreciente	 DECIMAL(18,2);
DEFINE num_mesespeoratrasohistoricomasreciente	 INTEGER;
DEFINE num_sumasaldoscuentasrevolventessintelcos DECIMAL(18,2);	
DEFINE num_sumalineascuentasrevolventessintelcos DECIMAL(18,2);
DEFINE pct_usocuentasrevolventessintelcos		 DECIMAL(18,2);
DEFINE num_tarjetacredito						 INTEGER;
DEFINE num_consultas90dias						 INT8;
DEFINE num_cuentasMOP3							 INT8;
DEFINE num_cuentas								 INT8;
DEFINE num_consultassic						 	 INT8;

--------

------------------------
DEFINE NumCuentaPagoMinimo 		INT8;
DEFINE dSalariomin				DECIMAL(18,2);
DEFINE dTasa_Ordinaria 			DECIMAL(18,2);
DEFINE dTasa_Moratoria 			DECIMAL(18,2);
DEFINE diva 					DECIMAL(18,2);
DEFINE dDiaspromedio 			DECIMAL(18,2);
DEFINE dTope_ingre 				DECIMAL(18,2);
DEFINE dcVeces_smb 				DECIMAL(18,2);
DEFINE dPorcpermitido 			DECIMAL(18,2);
DEFINE dMesespermitido 			DECIMAL(18,2);
DEFINE dMinimomesespermitido 	DECIMAL(18,2);
------------------------
--Cambios Olivia
DEFINE cBRM_reing INTEGER;

--DEFINICION DE VARIABLES DE ERROR
DEFINE iSqlErr         INTEGER;
DEFINE iIsamErr        INTEGER;
DEFINE cCodRet         CHAR(6);
DEFINE cMensaje_ret    VARCHAR(100,1);

DEFINE cMes				CHAR(2);
DEFINE cDia				CHAR(2);
DEFINE cAnio			CHAR(4);
DEFINE cNomArch			CHAR(100);
DEFINE cRutaArchivo		CHAR(200);
DEFINE cSql				CHAR(9000);
DEFINE iRegistros		INTEGER;
DEFINE dtFechaHoy           DATE;


--------------------------- DECLARACION DE VARIABLES ---------------------------

--INICIALIZACION DE VARIABLES DATOS DEL CLIENTE
LET dtFechaHoy         = DATE(1);      

LET cNumCte               ="";     
LET cNumCteBco		      ="";      
LET cCurp  				  ="";
LET cB_INE                =0;     
       
LET dtFechaCte			  = '01/01/1900';          
LET dtFechaNac 			  = '01/01/1900';
LET cSexo                 ="";       
LET cEdo_Civil            ="";       
LET iTiem_Edo_Civil       = 0;       
LET iTiem_Edo_Civil_meses = 0;      
LET cEscolaridad          ="";
LET cHabita_en            ="??";      
LET cTipoResidencia       = "";      
LET cEntidad              ="";
LET vLocalidad         	  = '';
LET iTiem_Residencia   	  = 0;      
LET cGeoCte		  		  ='';      
LET cFlagGeoMov			  ='';       
LET iFlagGeoSuc		      = '0';     
LET cTelCasa              ="";      
LET cTelTrabajo           ="";     
LET iBanderaReferencia	  = '0';                                           
LET sValida_Cel	          = '0';      
LET COcupacion            = "";      
LET iTiem_Ocupacion       = 0;      
LET cProfesion            ="";
LET sId_actividad		  = 0;      
LET cDescAct              ="";                                        
LET sId_subactividad	  = 0;      
LET vDescSubAct           = "";                                         
LET mIngreso_Mensual	  = 0;         
LET mIngreso_Neto         = 0;         
LET cCompIngresos		  ="";       
LET dIngresoCac           = 0; 
LET sCompValido      	  = 0;       
LET sFlagHuella           = '0';      
LET cCod_Ult_Identif      ="";       
LET sEdadCte			  = 0;
LET pMeses_historia_grupo = 0;
LET pSituacion_pago_grupo = 0;


--INICIALIZACION DE VARIABLES DE CUENTA COPPEL
LET dtUltimaCompra       		 	= '01/01/1900';          
LET cPuntualidadCoppel   		  	='';        
LET dEficienciaCoppel			  	= 0;       
LET dSituacionPagoCoppel		  	= '0.00'; 
LET iCredDigitalesAct    		  	= 0;
LET cSituacionEspecial   		  	="?";
LET sCausaSituacion      		  	= 0;       
LET cMotivoRech          		  	="";   
LET cDescMvo            		  	="Pre-Calificacion Aprobada";
LET sHist_meses               	  	= 0;      
LET cCteExcep           		  	="";
LET dtmaxFechaAperturaDelProducto 	= '01/01/1900';          
LET cFechaUltimoPago     		  	="";
LET dtminFechaAperturasinFF 	  	= '01/01/1900';
LET dtminFechaApertura 			  	= '01/01/1900';
LET mAbonoTotal          			= 0;                
LET mAbonoVencidoTotal   			= 0;    
LET mAbonoMuebles    	 			= 0;        
LET mAbonoPrestamos    				= 0;
LET mAbonoRopa        				= 0;
LET mAbonoAire           			= 0;
LET mAbonoAfiliados     			= 0;
LET mAbonoReestructura   			= 0;
LET mVencidoMuebles 	 			= 0;
LET mVencidoRopa 	     			= 0; 
LET mVencidoPrestamos    			= 0; 
LET mVencidoAire         			= 0; 
LET mVencidoAfiliados    			= 0;
LET mVencidoReestructura 			= 0;  
LET mTotalVencido        			= 0;
LET mPagoMinimo          			= 0;
LET mLinea_tienda        			= 0;    
LET cTipoSolOS		     			="";      
LET mSaldoRopa			 			= 0;
LET mSaldoMuebles		 			= 0;
LET mSaldoPrestamos		 			= 0;

--INICIALIZACION DE VARIABLES DE BANCO
LET mCompro_banco           = 0;    
LET mCompro_bancoPP			= 0;
LET dComprobanco_TDC        = 0;  
LET iMaxSalVencidoBancoppel = 0; 
LET iCtas_StatusCV          = 0;
LET iCred_StatusFC          = 0; 
LET iCred_StatusFF_restru   = 0;
LET iCredits_riesgoD        = 0;
LET iCredits_riesgoE        = 0; 
LET iCredits_riesgoC        = 0; 
LET iMaxMontoReserva        = 0;
LET iCred_StatusDif_FF      = 0;
LET dMaxSalVencidoCRD       = 0;
LET iCuentasStatusCVsinFF   = 0;
LET iCtas_StatusDif_FF_6011 = 0;
LET iCtas_StatusFF_6011     = 0; 
LET iCredRiesgoD_sinFF      = 0;
LET iCredRiesgoE_sinFF      = 0;             
LET iCredRiesgoC_sinFF      = 0; 
LET dmaxMontoReservaRiesgoC_sinFF = 0;
LET iReprestamos           	= 0;
LET cSolBanco				= pNumSol;
LET sFlag_oro		        = 0;       
LET vClvEdoCob              ="";    
LET cEstado 				='';
LET cMunicipio 				='';
LET cVigenciaBancoppel      ="";
LET dLineaBanco		        = 0;
LET cResultadoOsTel         ="";         
LET cTieneOstel             ="";        
LET cEnvioCat               ="";        
LET iSolMc			        = 0;        
LET iSolMcAux		        = 0;        
LET iSecuenciaOs	        = '0';        
LET cStatusRespOs	        ="";        
LET dtFecha_Respuesta       = '01/01/1900';       
LET cMotivoRechBcpl 		= "";
LET cDescripcion			="";
LET cRiesgoViviendaCpl  	=""; 
LET cRiesgoViviendaBcpl 	="";
LET cActRiesgoCpl       	="";
LET cActRiesgoBCpl			="";
LET cDescpRiesgo			= "";
LET cEjecucion	  			= "";
 

--INICIALIZACION DE VARIABLES DE BURÃ
LET dCompromisos              = 0; 
LET dMontoUdis                = 0; 
LET cInstitucion              ="";
LET cClvObser				  ="";
LET iNumCtas_ClvOb            = '0';       
LET iMax_MOP                  = '0';     
LET cInstCta_MayorMOP         ="";       
LET dMonto_UDIS_MayorMOP      = 0; 
LET iMax_MOP_Hist_6m          = '0';       
LET cInstCta_MayorMOP_6m      ="";       
LET dMontoUDIS_MM_6m          = 0; 
LET iMM_Histo_12m             = '0';       
LET cInstCta_MayorMOP_12m     ="";      
LET dMontoUDIS_MM_12m         = 0; 
LET iNumCtasMOP_4_12m         = 0;       
LET iNumCtasMOP_5_12m         = 0;       
LET iNumCtasMOP_mayor5_12m    = 0;       
LET iMOP4_12mCon1o2           = 0;                                  
LET iMOP5_12mCon1o2           = 0;       
LET iMOPmayor5_12mCon1o2      = 0;
LET cInstCta_MayorMOP_30m     ="";       
LET dMontoUDIS_MM_Rech        = 0; 
LET iNumCtasMOP_4_30m         = 0;       
LET iNumCtasMOP_5_30m         = 0;       
LET iNumCtasMOP_mayor5_30m    = 0;
LET iCtasMOP_4_30mCon1o2      = 0;
LET iCtasMOP_5_30mCon1o2      = 0;
LET iCtasMOP_mayor5_30mCon1o2 = 0;    
LET cInstitucionMMOP_provocaRech ="";       
LET dMontoUDIS_30d_Rech          = 0; 
LET iMM_Histo_30m                = '0';        
LET cInstCta_MM_30m_Rech         =""; 
LET dMotoUDIS_MM_30m_Rech        = 0; 
LET iMM_act_Bancos               = '0';        
LET iMM_hist_alto_Bancos         = '0';       
LET iMM_hist_Bancos              ='0';       
LET iCtasBancosMOP_tl26          = 0;       
LET iCtasBancosMOP_tl38          = 0;       
LET iCtasBancosMOP_tl27          = 0;       
LET iCtasBancosMOP_act_hist_alto = 0;      
LET iCtasComServMOP_tl26         = 0;       
LET iCtasComServMOP_tl38         = 0;       
LET iCtasComServMOP_tl27         = 0;       
LET iCtasCSM_act_hist_alto       = 0;        
LET iCtasComServMOP_tl26_12m     = 0;       
LET iCtasComServMOP_tl38_12m     = 0;       
LET iCtasComServMOP_tl27_12m     = 0;        
LET iCtasCSM_ActHistAlto_12m     = 0;       
LET iMaxMOP_actBancos            = '0';       
LET iMaxMOP_histAltBancos        = '0';        
LET iMaxMOP_histBancos           = '0';       
LET iMaxMOP_actCtas              = '0';       
LET iMaxMOP_histAltCtas          = '0';       
LET iMaxMOP_histCtas             = '0';       
LET iCtas_SinComServ             = 0;       
LET iCtas_SinComServ_pagar       = 0;      
LET iNumCtas_SHBr                = 0;       
LET iNumCtas_SHBr_pagar          = 0;       

--INICIALIZACION DE VARIABLES DE SOLICITUD
LET dtFechaSolicitud       = '01-01-1900';
LET cCteProsp		       ="";
LET cStatusSol_CteProsp    ="";
LET cTipo_Alta_CteProsp	   ="";
LET cCteProspVig		   ="";
LET cSucursal   	       ="";
LET iFlagEmpleado          = '0';
LET sEntidad_Localidad     ='0';
LET iCanal_Sol             = '0';
LET iCanalV1		       = '0';
LET cTp_solicitud          ="?";
LET cNum_Producto          ="";
LET cStatusSolicitud       ="";
LET cCausa_Sol		       ="";
LET cTipoRech              ="";  
LET cTipoGrupo 		       ="";
LET cSituacion             = "?";
LET cProducto              ='????';   
LET dminProcentajeProductoMasReciente = 0;
LET sFlagForzarEnvioMC     = '0';
LET cNumSol_Os		       ="";
LET sScore_coppel          = 0;
LET dValor_3s              = 0;
LET cFolioMovil            ="";
LET cStatusMovil           ='';
LET sBc_Score              = 0;  
LET cInstitucionClvExclusionMasReciente = "";
LET vClvExclusionMasReciente = 0;


--INICIALIZACION DE VARIABLES DE PARAMETRICOS
LET HR0048             = 0;
LET HR0050             = '0';
LET TR0002             = '0';
LET TR0001             = '0';
LET IQ0002             = '0';
LET BC_421             = 0;
LET BC_85              = '0';
LET BC_93              = '0';
LET BC1                = 0;
LET BC_101             = 0;
LET BC_117             = 0;
LET BC_119             = 0;
LET BC_20              = 0;
LET UT0034             = 0;
LET dSaldo_linea_credi = '0.00';
LET dSaldo_limit_credi = '0.00';


--INICIALIZACION DE VARIABLES DE EVALUACIÃN
LET cRTipo3           ="";
LET cVigSolOS		  ="";
LET sBuenPagos        = "";
LET sFlagBuenPago12	  = '0';
LET sFlagBuenPago30	  = '0';
LET cNuevoStatusOstel ="";
LET dMontoOtorgado    = 0;
LET mCapacidad_pago   = 0;
LET iExisteCliente    = 0;
LET cTipo_movimiento  ="";
LET dCompromisosCac   = 0;
LET dtFechaAux		  = '01/01/1900';
LET dTasa			  = 0;
LET dtasaMora = 0;
LET cOrigenSol        ='1';
LET cOrigenCte		  ="";
LET mImporte_hip      = 0;
LET iMeses_hist_Val   = 0;
LET sCteLargo8		  = 0;
LET sCteLargo         = '0';
LET vgrupoA 		  = 0;
LET NumSolMovil		  = '';
LET iFlag2credito 	  = 0;



--INICIALIZACION DE VARIABLES DE REINGENIERIALET mosSncOldestRevTLOpnd				= 0;
LET numInq0to2Mos						= 0;
LET pctBankILTL							= 0;
LET pctTL30pDaysEverColl				= '0';
LET avgMosInFileTLRptd0To2Mos			= '0';
LET highestUtilOnBankNatlRevTL			= -999;
LET lowestRatingIL						= 0;
LET lowestRatingRevOpen					= 0;
LET maxDelq0To11Mos						= '0';
LET mosSncOldestBankNatlRevOpenTLOpnd	= 0;
LET netFrctTLOpnd0To35Mos				= '0';
LET totBalDelqTL						= 0;
LET numFinInq0to5Mos					= 0;
LET maxDelqEver							= 0;
LET pctInq0To2MosByInq0To11Mos			= 0;
LET numRetTLOpnd0to5Mos					= 0;
LET num_sumasaldoscuentasabiertas		= 0;
LET num_sumalineascuentasabiertas		= 0;
LET pct_usocuentasabiertas				= 0;
LET num_antiguedadpromediocuentas12meses 	= 0;
LET num_consultasfinanciera					= 0;
LET num_maxplazodias						= 0;
LET clv_tipoproductocrediticio				= 0;
LET num_montofechamorosamasgravemasreciente		= 0;
--LET num_mesesfechamorosamasgravemasreciente		= 0;
LET num_totalperiodosreportados					= 0;
LET num_porcentajecorrientepromedio				= -1;
LET num_lineacreditopromedio					= 0;
LET num_arrendamiento							= 0;
LET num_tiendacomercial							= 0;
LET clv_worstcurrentmop							= 0;
LET num_direcciones								= 0;
LET num_montopeoratrasohistoricomasreciente		= 0;
LET num_mesespeoratrasohistoricomasreciente		= 0;
LET num_sumasaldoscuentasrevolventessintelcos	= 0;	
LET num_sumalineascuentasrevolventessintelcos 	= 0;
LET pct_usocuentasrevolventessintelcos		 	= 0;
LET num_tarjetacredito						 	= 0;
LET num_consultas90dias						 	= 0;
LET num_cuentasMOP3								= 0;
LET num_cuentas								 	= 0;
LET num_consultassic							= 0;
LET NumCuentaPagoMinimo 						= 0;


--parametros tdc visa Olivia
LET dSalariomin 			= 0;
LET dTasa_Ordinaria 		= 0; --
LET dTasa_Moratoria 		= 0; 
LET diva 					= 0;
LET dDiaspromedio 			= 0;
LET dTope_ingre 			= 0;
LET dcVeces_smb 			= 0;
LET dPorcpermitido 			= 0;
LET dMesespermitido 		= 0;
LET dMinimomesespermitido 	= 0;
LET cBRM_reing = 0;

LET cMes				= '';
LET cDia				= '';
LET cAnio			    = '';
LET cNomArch			= '';
LET cRutaArchivo		= '';
LET cSql				= '';
LET iRegistros = 0;

------------------------

--DECLARACION DE VARIABLES DE ERROR
LET iSqlErr  = 0;
LET iIsamErr = 0;
LET cCodRet  ="000000";
LET cCodRetDoc = "000000";
LET cMensaje_ret        = '';

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr
		IF iSqlErr != 0 THEN
			LET cCodRetDoc = iSqlErr;
			INSERT INTO bdisolic:"informix".ax_paso values ("bdicred:sp_consultadatos_motor_mc", cCodRetDoc, CURRENT ||iIsamErr||'|'||TRIM(pNumSol));
			RETURN  NVL(cCodRetDoc,000000), nvl(cRutaArchivo,''), nvl(cSolBanco,''),	nvl(cNumCteBco,'');
		END IF;
	END EXCEPTION;
    
    --SET debug file to '/informix/Oscar/SpMEsa/sp_consultadatos_motor_mc.out';
    --TRACE ON; 
    
	SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;
	-----------------------------
	SELECT fecha_hoy
    INTO dtFechaHoy
    FROM bdicred:"informix".sd_fechas
    WHERE empresa = pEmpresa;

	LET cNomArch = TRIM(cSolBanco);
	LET cNomArch = TRIM(cNomArch) || '.txt';

	--LET cRutaArchivo = '/informix/Oscar/' || TRIM(cNomArch);
    --LET cRutaArchivo = '/ifxsif01/ash/' || TRIM(cNomArch);
    LET cRutaArchivo = '/tmp/mfinis/' || TRIM(cNomArch);

    --Elimina archivo
	LET cSQL = 'rm -rf ' || TRIM(cRutaArchivo);		
	SYSTEM cSQL;	
	--Crea archivo vacio
	LET cSQL = 'touch ' || TRIM(cRutaArchivo);
	SYSTEM cSQL;
END
		
			IF NVL(pEmpresa,'') = '' OR nvl(pNumSol,'') = '' THEN
				LET cCodRetDoc = '020202';
			ELSE
		EXECUTE procedure bdicred:sp_consultadatos_motor(pEmpresa, pNumSol)
		INTO cCodRet,cSolBanco,cNumCteBco,cNumCte,pEmpresa, 
		cStatusSolicitud,cCausa_Sol, cNum_Producto,cTipoGrupo,cTp_solicitud,
		cB_INE,cHabita_en,cPuntualidadCoppel,cProfesion,iCredDigitalesAct,
		sId_actividad,cDescAct,sId_subactividad,vDescSubAct,cSituacionEspecial, 
		sCausaSituacion,cMotivoRech,cMotivoRechBcpl,cTipoRech,cDescMvo,
		mTotalVencido,mAbonoTotal,mAbonoVencidoTotal,sHist_meses,cCteExcep,
		iCtas_StatusCV,iMaxSalVencidoBancoppel,dEficienciaCoppel,iCred_StatusFC,
		iCred_StatusFF_restru,iCredits_riesgoD,iCredits_riesgoE,iCredits_riesgoC,
		iMaxMontoReserva,iCred_StatusDif_FF,dMaxSalVencidoCRD,iCuentasStatusCVsinFF,
		iCtas_StatusDif_FF_6011,iCredRiesgoD_sinFF,iCredRiesgoE_sinFF,iCredRiesgoC_sinFF,
		dmaxMontoReservaRiesgoC_sinFF,dtMinFechaAperturasinFF,dtMinFechaApertura,
		cSituacion,dtmaxFechaAperturaDelProducto,cProducto,dminProcentajeProductoMasReciente,
		mAbonoMuebles,mAbonoPrestamos,mAbonoRopa,mAbonoAire,mAbonoAfiliados,
		mAbonoReestructura,mVencidoMuebles,mVencidoRopa,mVencidoPrestamos,mVencidoAire,
		mVencidoAfiliados,mVencidoReestructura,cFechaUltimoPago,iReprestamos,
		cOrigenSol,cDescripcion,cRiesgoViviendaCpl,cRiesgoViviendaBcpl,cActRiesgoCpl,
		cActRiesgoBCpl,cDescpRiesgo,cEjecucion,iMax_MOP,cInstCta_MayorMOP,
		dMonto_UDIS_MayorMOP,iMax_MOP_Hist_6m,cInstCta_MayorMOP_6m,dMontoUDIS_MM_6m,
		iMM_Histo_12m,cInstCta_MayorMOP_12m,dMontoUDIS_MM_12m,iNumCtasMOP_4_12m,
		iNumCtasMOP_5_12m,iNumCtasMOP_mayor5_12m,iMOP4_12mCon1o2,iMOP5_12mCon1o2,
		iMOPmayor5_12mCon1o2,cInstitucionMMOP_provocaRech,dMontoUDIS_MM_Rech,iNumCtasMOP_4_30m,
		iNumCtasMOP_5_30m,iNumCtasMOP_mayor5_30m,iCtasMOP_4_30mCon1o2,iCtasMOP_5_30mCon1o2,
		iCtasMOP_mayor5_30mCon1o2,iMM_Histo_30m,cInstCta_MM_30m_Rech,dMotoUDIS_MM_30m_Rech,
		iNumCtas_ClvOb,dMontoUdis,cInstitucion,cClvObser,sBc_Score,
		vClvExclusionMasReciente,cInstitucionClvExclusionMasReciente,iCtas_SinComServ,
		iCtas_SinComServ_pagar,iNumCtas_SHBr,iNumCtas_SHBr_pagar,BC1,BC_101,
		iMM_act_Bancos,iMM_hist_alto_Bancos,iMM_hist_Bancos,BC_117,iCtasBancosMOP_tl26,
		iCtasBancosMOP_tl38,iCtasBancosMOP_tl27,iCtasBancosMOP_act_hist_alto,BC_119,
		iCtasComServMOP_tl26,iCtasComServMOP_tl38,iCtasComServMOP_tl27,iCtasCSM_act_hist_alto,
		BC_20,iCtasComServMOP_tl26_12m,iCtasComServMOP_tl38_12m,iCtasComServMOP_tl27_12m,
		iCtasCSM_ActHistAlto_12m,BC_421,dtFechaAux,BC_85,iMaxMOP_actBancos,
		iMaxMOP_histAltBancos,iMaxMOP_histBancos,BC_93,iMaxMOP_actCtas,iMaxMOP_histAltCtas,
		iMaxMOP_histCtas,dSituacionPagoCoppel,mIngreso_Mensual, mPagoMinimo,  sCteLargo8,
		iMeses_hist_Val,cTipo_Alta_CteProsp,mLinea_tienda,mImporte_hip,dTasa,
		sFlagHuella,cResultadoOsTel,cTieneOstel,cEnvioCat,iSolMc,
		iSolMcAux,cCod_Ult_Identif,cTelCasa,cTelTrabajo,sValida_Cel,
		dtUltimaCompra,iBanderareferencia,dtFechaCte,cFolioMovil,
		cFlagGeoMov,iFlagGeoSuc,iCanal_Sol,cOrigenCte,sFlagForzarEnvioMC,
		iSecuenciaOs,cStatusRespOs,dtFecha_Respuesta, cNumSol_Os,cCompIngresos,
		dIngresoCac,sCompValido,cTipo_movimiento,cSucursal,cTipoSolOS, 
		dCompromisosCac,sFlag_oro,mIngreso_Neto,dtFechaNac,cSexo,
		cEdo_Civil,iTiem_Edo_Civil,HR0048,UT0034,cOcupacion,iTiem_Ocupacion,
		cEscolaridad,cTipoResidencia,iTiem_Residencia,vClvEdoCob,vLocalidad,
		cEntidad,sCteLargo,sScore_coppel,cCURP,iFlagEmpleado,dValor_3s,
		cStatusMovil,cCteProsp,cStatusSol_CteProsp,cRTipo3,cVigSolOS,  sBuenPagos,
		dCompromisos,sFlagBuenPago12,sFlagBuenPago30,sEntidad_Localidad,cNuevoStatusOstel,
		cCteProspVig,mCompro_banco,dComprobanco_TDC,mCompro_bancoPP,cGeoCte,iCanalV1,
		HR0050,TR0002,TR0001, IQ0002,iCtas_StatusFF_6011,dSaldo_linea_credi,
		dSaldo_limit_credi,iTiem_Edo_Civil_meses,dMontoOtorgado,mCapacidad_pago,
		cVigenciaBancoppel,dLineaBanco,iExisteCliente,mSaldoRopa,mSaldoMuebles,
		mSaldoPrestamos,mosSncOldestRevTLOpnd,numInq0to2Mos,pctBankILTL,pctTL30pDaysEverColl,
		avgMosInFileTLRptd0To2Mos,highestUtilOnBankNatlRevTL,lowestRatingIL,lowestRatingRevOpen,
		maxDelq0To11Mos,mosSncOldestBankNatlRevOpenTLOpnd,netFrctTLOpnd0To35Mos,totBalDelqTL,
		numFinInq0to5Mos,maxDelqEver,pctInq0To2MosByInq0To11Mos,numRetTLOpnd0to5Mos,
		num_sumasaldoscuentasabiertas,num_sumalineascuentasabiertas,pct_usocuentasabiertas,
		num_antiguedadpromediocuentas12meses,num_consultasfinanciera,num_maxplazodias,
		clv_tipoproductocrediticio,num_montofechamorosamasgravemasreciente,num_totalperiodosreportados,
		num_porcentajecorrientepromedio,  num_lineacreditopromedio,num_arrendamiento,
		num_tiendacomercial,clv_worstcurrentmop,num_direcciones,num_montopeoratrasohistoricomasreciente,
		num_mesespeoratrasohistoricomasreciente,num_sumasaldoscuentasrevolventessintelcos,
		num_sumalineascuentasrevolventessintelcos,pct_usocuentasrevolventessintelcos,
		num_tarjetacredito,num_consultas90dias,num_cuentasMOP3,num_cuentas,num_consultassic,
		vgrupoA,NumSolMovil,iFlag2credito,NumCuentaPagoMinimo,dtFechaSolicitud,
		sEdadCte,pMeses_historia_grupo,pSituacion_pago_grupo,dSalariomin,dTasa_Ordinaria,
		dTasa_Moratoria,  diva,dDiaspromedio,dTope_ingre,dcVeces_smb,dPorcpermitido,
		dMesespermitido,  dMinimomesespermitido,cEstado,cMunicipio,cBRM_reing;

				LET totBalDelqTL = substr(totBalDelqTL,2);
				LET num_sumasaldoscuentasabiertas = substr(num_sumasaldoscuentasabiertas,2);
				LET num_sumalineascuentasabiertas = substr(num_sumalineascuentasabiertas,2);

			END IF;
		IF cCodRet::INTEGER <> 0 THEN
			INSERT INTO bdisolic:"informix".ax_paso values ("bdicred:sp_consultadatos_motor_mc", cCodRet, CURRENT ||iIsamErr||' | '||TRIM(pNumSol));
		END IF;
		
		 LET cSQL = '';
			LET cSQL = 'echo "' || NVL(cCodRet,000000)|| ' | ' || trim(nvl(cSolBanco,''))|| ' | ' ||	nvl(cNumCteBco,'')|| ' | ' ||	nvl(cNumCte,'')|| ' | ' || nvl(pEmpresa,'')|| ' | ' || 
				TRIM(NVL(cStatusSolicitud,''))|| ' | ' || NVL(cCausa_Sol,"")|| ' | ' || NVL(cNum_Producto,'')|| ' | ' || NVL(cTipoGrupo,'')|| ' | ' || NVL(cTp_solicitud,'?')|| ' | ' ||
				NVL(cB_INE,'')|| ' | ' || NVL(cHabita_en,'??')|| ' | ' || nvl(cPuntualidadCoppel,'')|| ' | ' || NVL(cProfesion,'')|| ' | ' ||NVL(iCredDigitalesAct,0)|| ' | ' ||
				NVL(sId_actividad,0)|| ' | ' || nvl(cDescAct,'')|| ' | ' || NVL(sId_subactividad,0)|| ' | ' || nvl(vDescSubAct,'')|| ' | ' || NVL(cSituacionEspecial,"?")|| ' | ' ||
				NVL(sCausaSituacion,-99)|| ' | ' || nvl(cMotivoRech,'')|| ' | ' || nvl(cMotivoRechBcpl,'')|| ' | ' || nvl(cTipoRech,'')|| ' | ' || nvl(cDescMvo,'')|| ' | ' ||
				nvl(mTotalVencido,0)|| ' | ' || nvl(mAbonoTotal,0)|| ' | ' || nvl(mAbonoVencidoTotal,0)|| ' | ' || nvl(sHist_meses,0)|| ' | ' || nvl(cCteExcep,'')|| ' | ' ||
				nvl(iCtas_StatusCV,0)|| ' | ' || nvl(iMaxSalVencidoBancoppel,0)|| ' | ' || nvl(dEficienciaCoppel,0)|| ' | ' ||nvl(iCred_StatusFC,0)|| ' | ' ||
				nvl(iCred_StatusFF_restru,0)|| ' | ' || nvl(iCredits_riesgoD,0)|| ' | ' || nvl(iCredits_riesgoE,0)|| ' | ' || nvl(iCredits_riesgoC,0)|| ' | ' ||
				nvl(iMaxMontoReserva,0)|| ' | ' || nvl(iCred_StatusDif_FF,0)|| ' | ' || nvl(dMaxSalVencidoCRD,0)|| ' | ' || nvl(iCuentasStatusCVsinFF,0)|| ' | ' ||
				nvl(iCtas_StatusDif_FF_6011,0)|| ' | ' || nvl(iCredRiesgoD_sinFF,0)|| ' | ' || nvl(iCredRiesgoE_sinFF,0)|| ' | ' || nvl(iCredRiesgoC_sinFF,0)|| ' | ' ||
				nvl(dmaxMontoReservaRiesgoC_sinFF,0)|| ' | ' ||NVL(dtMinFechaAperturasinFF,'01/01/1900')|| ' | ' || NVL(dtMinFechaApertura,'01/01/1900')|| ' | ' ||
				nvl(cSituacion,'')|| ' | ' || NVL(dtmaxFechaAperturaDelProducto,'01/01/1900')|| ' | ' || NVL(cProducto,"")|| ' | ' || NVL(dminProcentajeProductoMasReciente,0)|| ' | ' ||
				nvl(mAbonoMuebles,0)|| ' | ' || nvl(mAbonoPrestamos,0)|| ' | ' || nvl(mAbonoRopa,0)|| ' | ' || nvl(mAbonoAire,0)|| ' | ' || nvl(mAbonoAfiliados,0)|| ' | ' ||
				nvl(mAbonoReestructura,0)|| ' | ' || nvl(mVencidoMuebles,0)|| ' | ' || nvl(mVencidoRopa,0)|| ' | ' ||Nvl(mVencidoPrestamos,0)|| ' | ' || nvl(mVencidoAire,0)|| ' | ' || 
				nvl(mVencidoAfiliados,0)|| ' | ' || nvl(mVencidoReestructura,0)|| ' | ' || nvl(cFechaUltimoPago,'1900-01-01')|| ' | ' || nvl(iReprestamos,0)|| ' | ' ||
				nvl(cOrigenSol,'1')|| ' | ' ||nvl(cDescripcion,'')|| ' | ' || NVL(cRiesgoViviendaCpl,"")|| ' | ' ||NVL(cRiesgoViviendaBcpl,"")|| ' | ' || NVL(cActRiesgoCpl,'')|| ' | ' ||
				nvl(cActRiesgoBCpl,'')|| ' | ' ||	nvl(cDescpRiesgo,'')|| ' | ' || nvl(cEjecucion,'0')|| ' | ' || nvl(iMax_MOP,'0')|| ' | ' || Nvl(cInstCta_MayorMOP,'')|| ' | ' ||
				nvl(dMonto_UDIS_MayorMOP,0)|| ' | ' || nvl(iMax_MOP_Hist_6m,'0')|| ' | ' || NVL(cInstCta_MayorMOP_6m,'')|| ' | ' ||NVL(dMontoUDIS_MM_6m,0)|| ' | ' ||
				NVL(iMM_Histo_12m,'0')|| ' | ' || nvl(cInstCta_MayorMOP_12m,'')|| ' | ' ||  nvl(dMontoUDIS_MM_12m,0)|| ' | ' || nvl(iNumCtasMOP_4_12m,0)|| ' | ' ||
				nvl(iNumCtasMOP_5_12m,0)|| ' | ' || nvl(iNumCtasMOP_mayor5_12m,0)|| ' | ' || nvl(iMOP4_12mCon1o2,0)|| ' | ' || nvl(iMOP5_12mCon1o2,0)|| ' | ' ||
				nvl(iMOPmayor5_12mCon1o2,0)|| ' | ' || nvl(cInstitucionMMOP_provocaRech,'')|| ' | ' || nvl(dMontoUDIS_MM_Rech,0)|| ' | ' || nvl(iNumCtasMOP_4_30m,0)|| ' | ' ||
				nvl(iNumCtasMOP_5_30m,0)|| ' | ' ||nvl(iNumCtasMOP_mayor5_30m,0)|| ' | ' || nvl(iCtasMOP_4_30mCon1o2,0)|| ' | ' || nvl(iCtasMOP_5_30mCon1o2,0)|| ' | ' ||
				nvl(iCtasMOP_mayor5_30mCon1o2,0)|| ' | ' || nvl(iMM_Histo_30m,'0')|| ' | ' ||nvl(cInstCta_MM_30m_Rech,'')|| ' | ' ||nvl(dMotoUDIS_MM_30m_Rech,0)|| ' | ' ||
				nvl(iNumCtas_ClvOb,'0')|| ' | ' ||nvl(dMontoUdis,0)|| ' | ' ||nvl(cInstitucion,'')|| ' | ' || nvl(cClvObser,'0')|| ' | ' || nvl(sBc_Score,0)|| ' | ' ||
				nvl(vClvExclusionMasReciente,0)|| ' | ' || nvl(cInstitucionClvExclusionMasReciente,'')|| ' | ' || nvl(iCtas_SinComServ,0)|| ' | ' ||
				nvl(iCtas_SinComServ_pagar,0)|| ' | ' || nvl(iNumCtas_SHBr,0)|| ' | ' || nvl(iNumCtas_SHBr_pagar,0)|| ' | ' || nvl(BC1,-1)|| ' | ' || nvl(BC_101,0)|| ' | ' ||
				nvl(iMM_act_Bancos,'0')|| ' | ' || nvl(iMM_hist_alto_Bancos,'0')|| ' | ' || nvl(iMM_hist_Bancos,'0')|| ' | ' || nvl(BC_117,0)|| ' | ' || nvl(iCtasBancosMOP_tl26,0)|| ' | ' ||
				nvl(iCtasBancosMOP_tl38,0)|| ' | ' || nvl(iCtasBancosMOP_tl27,0)|| ' | ' || nvl(iCtasBancosMOP_act_hist_alto,0)|| ' | ' || nvl(BC_119,0)|| ' | ' ||
				nvl(iCtasComServMOP_tl26,0)|| ' | ' || nvl(iCtasComServMOP_tl38,0)|| ' | ' ||nvl(iCtasComServMOP_tl27,0)|| ' | ' || nvl(iCtasCSM_act_hist_alto,0)|| ' | ' ||
				nvl(BC_20,0)|| ' | ' || nvl(iCtasComServMOP_tl26_12m,0)|| ' | ' ||nvl(iCtasComServMOP_tl38_12m,0)|| ' | ' || nvl(iCtasComServMOP_tl27_12m,0)|| ' | ' ||
				nvl(iCtasCSM_ActHistAlto_12m,0)|| ' | ' || nvl(BC_421,0)|| ' | ' ||nVL(dtFechaAux,'01/01/1900')|| ' | ' ||nvl(BC_85,'0')|| ' | ' ||	NVL(iMaxMOP_actBancos,'0')|| ' | ' || 
				NVL(iMaxMOP_histAltBancos,'0')|| ' | ' ||nvl(iMaxMOP_histBancos,'0')|| ' | ' || nvl(BC_93,'0')|| ' | ' || nvl(iMaxMOP_actCtas,'0')|| ' | ' || nvl(iMaxMOP_histAltCtas,'0')|| ' | ' ||
				nvl(iMaxMOP_histCtas,'0')|| ' | ' || nvl(dSituacionPagoCoppel,'0.00')|| ' | ' || nvl(mIngreso_Mensual,0)|| ' | ' ||nvl(mPagoMinimo,0)|| ' | ' ||nvl(sCteLargo8,0)|| ' | ' ||
				nvl(iMeses_hist_Val,0)|| ' | ' || nvl(cTipo_Alta_CteProsp,'')|| ' | ' || nvl(mLinea_tienda,0)|| ' | ' || nvl(mImporte_hip,0)|| ' | ' || nvl(dTasa,0)|| ' | ' ||
				nvl(sFlagHuella,'0')|| ' | ' || nvl(cResultadoOsTel,'')|| ' | ' || nvl(cTieneOstel,'')|| ' | ' ||nvl(cEnvioCat,'')|| ' | ' ||nvl(iSolMc,0)|| ' | ' ||
				nvl(iSolMcAux,0)|| ' | ' ||nvl(cCod_Ult_Identif,0)|| ' | ' || NVL(cTelCasa,"")|| ' | ' || NVL(cTelTrabajo,'')|| ' | ' || NVL(sValida_Cel,'0')|| ' | ' ||
				NVL(dtUltimaCompra,'01/01/1900')|| ' | ' ||nvl(iBanderareferencia,'0')|| ' | ' || NVL(dtFechaCte,'01/01/1900')|| ' | ' ||NVL(cFolioMovil,"")|| ' | ' ||
				NVL(cFlagGeoMov,"")|| ' | ' || nvl(iFlagGeoSuc,'0')|| ' | ' || nvl(iCanal_Sol,'0')|| ' | ' || nvl(cOrigenCte,'')|| ' | ' || nvl(sFlagForzarEnvioMC,'0')|| ' | ' ||
				nvl(iSecuenciaOs,'0')|| ' | ' || nvl(cStatusRespOs,'')|| ' | ' ||NVL(dtFecha_Respuesta, 01/01/1900)|| ' | ' || nvl(cNumSol_Os,'')|| ' | ' ||nvl(cCompIngresos,'')|| ' | ' ||
				nvl(dIngresoCac,0)|| ' | ' || NVL(sCompValido, 0)|| ' | ' || nvl(cTipo_movimiento,'')|| ' | ' || NVL(cSucursal,'')|| ' | ' ||NVL(cTipoSolOS,'')|| ' | ' ||
				NVL(dCompromisosCac,0)|| ' | ' ||NVL(sFlag_oro,0)|| ' | ' || nvl(mIngreso_Neto,0)|| ' | ' ||NVL(dtFechaNac,'01/01/1900')|| ' | ' || NVL(cSexo,'')|| ' | ' ||
				nvl(cEdo_Civil,'')|| ' | ' || nvl(iTiem_Edo_Civil,-99)|| ' | ' || nvl(HR0048,-1)|| ' | ' || nvl(UT0034,-999)|| ' | ' || nvl(cOcupacion,'')|| ' | ' ||nvl(iTiem_Ocupacion, -99)|| ' | ' ||
				nvl(cEscolaridad,'')|| ' | ' || nvl(cTipoResidencia,'')|| ' | ' || nvl(iTiem_Residencia, -99)|| ' | ' || NVL(vClvEdoCob,'')|| ' | ' || NVL(vLocalidad,'')|| ' | ' ||
				NVL(cEntidad,'')|| ' | ' || NVL(sCteLargo,'0')|| ' | ' || nvl(sScore_coppel,0)|| ' | ' || NVL(cCURP,'')|| ' | ' || NVL(iFlagEmpleado,'0')|| ' | ' || NVL(dValor_3s,0)|| ' | ' ||
				nvl(cStatusMovil,'')|| ' | ' || nvl(cCteProsp,'')|| ' | ' || nvl(cStatusSol_CteProsp,'')|| ' | ' || nvl(cRTipo3,'')|| ' | ' || NVL(cVigSolOS,'')|| ' | ' || nvl(sBuenPagos,'')|| ' | ' ||
				nvl(dCompromisos,0)|| ' | ' ||nvl(sFlagBuenPago12,'0')|| ' | ' || NVL(sFlagBuenPago30,'0')|| ' | ' ||NVL(sEntidad_Localidad,'0')|| ' | ' ||nvl(cNuevoStatusOstel,'')|| ' | ' ||
				nvl(cCteProspVig,'')|| ' | ' ||NVL(mCompro_banco,0)|| ' | ' || nvl(dComprobanco_TDC,0)|| ' | ' || NVL(mCompro_bancoPP,0)|| ' | ' || nvl(cGeoCte,'')|| ' | ' ||nvl(iCanalV1,'99')|| ' | ' ||
				nvl(HR0050,'-1')|| ' | ' || nvl(TR0002,'-999')|| ' | ' || nvl(TR0001,'-999')|| ' | ' || nvl(IQ0002,'0')|| ' | ' || NVL(iCtas_StatusFF_6011,0)|| ' | ' || NVL(dSaldo_linea_credi,'0.00')|| ' | ' ||
				NVL(dSaldo_limit_credi,'0.00')|| ' | ' || nvl(iTiem_Edo_Civil_meses, -99)|| ' | ' ||nvl(dMontoOtorgado,0)|| ' | ' || nvl(mCapacidad_pago,0)|| ' | ' ||
				nvl(cVigenciaBancoppel,'')|| ' | ' || nvl(dLineaBanco,0)|| ' | ' || nvl(iExisteCliente,0)|| ' | ' || nvl(mSaldoRopa,0)|| ' | ' || nvl(mSaldoMuebles,0)|| ' | ' ||
				nvl(mSaldoPrestamos,0)|| ' | ' || nvl(mosSncOldestRevTLOpnd,-1)|| ' | ' ||nvl(numInq0to2Mos,0)|| ' | ' || nvl(pctBankILTL,0)|| ' | ' || nvl(pctTL30pDaysEverColl,'0')|| ' | ' ||
				nvl(avgMosInFileTLRptd0To2Mos,'0')|| ' | ' || nvl(highestUtilOnBankNatlRevTL,-999)|| ' | ' || nvl(lowestRatingIL,0)|| ' | ' || nvl(lowestRatingRevOpen,0)|| ' | ' ||
				nvl(maxDelq0To11Mos,'99')|| ' | ' || nvl(mosSncOldestBankNatlRevOpenTLOpnd,-1)|| ' | ' || nvl(netFrctTLOpnd0To35Mos,'0')|| ' | ' ||nvl(totBalDelqTL,0)|| ' | ' ||
				nvl(numFinInq0to5Mos,0)|| ' | ' || nvl(maxDelqEver,99)|| ' | ' || nvl(pctInq0To2MosByInq0To11Mos,'0')|| ' | ' ||nvl(numRetTLOpnd0to5Mos,'0')|| ' | ' ||
				nvl(num_sumasaldoscuentasabiertas,'0.00')|| ' | ' || nvl(num_sumalineascuentasabiertas,'0.00')|| ' | ' || nvl(pct_usocuentasabiertas,0)|| ' | ' ||
				nvl(num_antiguedadpromediocuentas12meses,0)|| ' | ' || nvl(num_consultasfinanciera,0)|| ' | ' || nvl(num_maxplazodias,-1)|| ' | ' ||
				nvl(clv_tipoproductocrediticio,'')|| ' | ' ||nvl(num_montofechamorosamasgravemasreciente,-1)|| ' | ' || nvl(num_totalperiodosreportados,0)|| ' | ' ||
				nvl(num_porcentajecorrientepromedio,-1)|| ' | ' || nvl(num_lineacreditopromedio,-2)|| ' | ' ||nvl(num_arrendamiento,0)|| ' | ' ||
				nvl(num_tiendacomercial,0)|| ' | ' ||nvl(clv_worstcurrentmop,-2)|| ' | ' || nvl(num_direcciones,0)|| ' | ' || nvl(num_montopeoratrasohistoricomasreciente,-1)|| ' | ' ||
				nvl(num_mesespeoratrasohistoricomasreciente,-1)|| ' | ' || nvl(num_sumasaldoscuentasrevolventessintelcos,0)|| ' | ' ||
				nvl(num_sumalineascuentasrevolventessintelcos,0)|| ' | ' || nvl(pct_usocuentasrevolventessintelcos,0)|| ' | ' ||
				nvl(num_tarjetacredito,0)|| ' | ' || nvl(num_consultas90dias,0)|| ' | ' || nvl(num_cuentasMOP3,0)|| ' | ' || nvl(num_cuentas,0)|| ' | ' || nvl(num_consultassic,0)|| ' | ' ||
				nvl(vgrupoA,'')|| ' | ' || nvl(NumSolMovil,'')|| ' | ' || nvl(iFlag2credito,0)|| ' | ' || nvl(NumCuentaPagoMinimo,0)|| ' | ' ||NVL(dtFechaSolicitud, '01/01/1900')|| ' | ' ||
				NVL(sEdadCte,0)|| ' | ' || nvl(pMeses_historia_grupo,0)|| ' | ' || nvl(pSituacion_pago_grupo,0)|| ' | ' || NVL(dSalariomin,0)|| ' | ' || NVL(dTasa_Ordinaria,0)|| ' | ' ||
				NVL(dTasa_Moratoria,0)|| ' | ' ||NVL(diva,0)|| ' | ' || NVL(dDiaspromedio,0)|| ' | ' ||NVL(dTope_ingre,0)|| ' | ' ||NVL(dcVeces_smb,0)|| ' | ' || NVL(dPorcpermitido,0)|| ' | ' ||
				NVL(dMesespermitido,0)|| ' | ' ||NVL(dMinimomesespermitido,0)|| ' | ' ||NVL(cEstado,'')|| ' | ' ||NVL(cMunicipio,'')|| ' | ' || NVL(cBRM_reing,0)||' | ' ||'" >> ' || cRutaArchivo;
			SYSTEM cSQL;

			--LET iRegistros = iRegistros + 1;

			--IF iRegistros = 100 THEN
			--	EXIT FOREACH;
			--END IF;		
	RETURN  NVL(cCodRetDoc,000000), nvl(cRutaArchivo,''), nvl(cSolBanco,''),	nvl(cNumCteBco,'');
	
END PROCEDURE
DOCUMENT 
'----------------------------------------------------------------------------',
'Descripcion : Se genera sp para generaciÃ³n de archivo de texto con las variables generadas por el proceso de consulta.',
'Modifico    : Vera Mariscal',
'Fecha       : 30/08/2023',
'BD          : BDICRED';

CREATE PROCEDURE "informix".cargo_ref_cel --33 PARAMETROS
      ( pTarjeta             CHAR(16),
        pSucursal            CHAR(4),
        pUsuario             CHAR(8),
        pNumTran             CHAR(4),
        pNumTranS            CHAR(4),
        pFolio               CHAR(16),
        pNumCredito          CHAR(20),
        pDocumento           INTEGER,
        pMonto               MONEY(16,2),
        pMonto2              MONEY(16,2),
        pCashTranCen         CHAR(4),
        pCashFolio           CHAR(15),
        pDivisa              CHAR(2),
        pReferencia          CHAR(40),
        pComSucursal         CHAR(4),
        pComUsuario          CHAR(8),
        pComNumTran          CHAR(4),
        pComNumTranS         CHAR(4),
        pComFolio            CHAR(16),
        pComNumCredito       CHAR(20),
        pComDocumento        INTEGER,
        pComMonto            MONEY(16,2),
        pComDivisa           CHAR(2),
        pComReferencia       CHAR(40),
        pComBandera          CHAR(1),
        pSurcharge           CHAR(1),  -- jom Se agrega para identificar el tipo de comision   (F=No aplica,V=Aplica)
        pComCashNumTran      CHAR(4),
        pComCashNumTranS     CHAR(4),
        pComCashFolio        CHAR(16),
        pComCashDocumento    INTEGER,
        pComCashMonto        MONEY(16,2),
        pComCashDivisa       CHAR(2),
        pComCashReferencia   CHAR(40))

   RETURNING CHAR(5),       -- Codigo de Retorno
             CHAR(4),       -- Transaccion
             DATE,          -- Fecha Aplicacion
             MONEY(16,2),   -- Saldo Disponible
             MONEY(16,2),   -- Importe Cargado
             CHAR(5),       -- Codigo de Retorno Comision
             CHAR(4),       -- Transaccion Comision
             DATE,          -- Fecha Aplicacion Comision
             MONEY(16,2),   -- Saldo Disponible Comision
             MONEY(16,2);   -- Importe Cargado ComisioN

   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************
   DEFINE cod_ret               CHAR(5);
   DEFINE cod_ret2              CHAR(5);
   DEFINE cod_ret_inc           CHAR(5);
   DEFINE sql_err               SMALLINT;
   DEFINE isam_err              SMALLINT;
   DEFINE error_info            CHAR(40);
   DEFINE nrows                 SMALLINT;
   DEFINE Mensaje               CHAR(80);
   DEFINE Mensaje_inc           CHAR(80);

   DEFINE NumProducto           CHAR(4);
   DEFINE StatusCred            CHAR(2);
   DEFINE Saldo                 MONEY(16,2);
   DEFINE SaldoCom              MONEY(16,2);
   DEFINE TipoCredito           CHAR(2);
   DEFINE MontoOtorgado         MONEY(16,2);
   DEFINE v_com1_dlls           MONEY(16,2);
   DEFINE v_com2_dlls           MONEY(16,2);
   DEFINE v_mtofavor_dlls       MONEY(16,2);
   DEFINE v_mto1_dlls           MONEY(16,2);
   DEFINE v_mto2_dlls           MONEY(16,2);
   DEFINE MtoTot                MONEY(16,2);
   DEFINE TotCargo              MONEY(16,2);
   DEFINE TotComision           MONEY(16,2);
   DEFINE CodigoRef             INTEGER;
   DEFINE CodigoFun             CHAR(3);
   DEFINE wEmpresa              CHAR(3);
   DEFINE wSucursal             CHAR(4);
   DEFINE wDivisa               CHAR(2);
   DEFINE FechaHoy              DATE;
   DEFINE pForzado              CHAR(1);
   DEFINE wBegin                CHAR(1);
   DEFINE vusuario              CHAR(8);
   DEFINE v_paso                SMALLINT;
   DEFINE v_mn                  CHAR(2);
   DEFINE v_dv                  CHAR(2);
   DEFINE v_valor               SMALLINT;
   DEFINE v_tipocambio          DECIMAL(14,6);
   DEFINE v_mensaje             VARCHAR(100);
   DEFINE TasaIva               DECIMAL(5,3);
   DEFINE Iva                   DECIMAL(14,2);
   DEFINE vMtoComDisp           DECIMAL(14,2);
   DEFINE vMtoComDisp_iva       DECIMAL(14,2);     -- RRG Se agrega para el proyecto de circular 22/2010 comisiones ATM 26/10/2010
   DEFINE v_faplica             CHAR(1);
   DEFINE v_factor              DECIMAL(9,6);
   DEFINE v_rangos              CHAR(1);
   DEFINE v_rmax                MONEY(14,2);
   DEFINE v_codparam            CHAR(4);
   DEFINE vSdoPos               DECIMAL(14,2);
   DEFINE vMtoPaso              DECIMAL(14,2);
-- Jom INI Bloqueo de cuentas
   DEFINE vBloqueo              INTEGER;
-- Jom FIN Bloqueo de cuentas
   DEFINE vMtoFavor             DECIMAL(16,2);
   DEFINE vMtoPaso2             DECIMAL(16,2);
   DEFINE pNumTranFavor         CHAR(4);
   DEFINE pNumTranFavor2         CHAR(4);
-- Jom INI limites
   DEFINE vnum_cliente          char(20);
   DEFINE vcodret               char(05);
   DEFINE vmsje_limites         char(80);
   DEFINE vid_autor             char(01);
   DEFINE vid_transacc          char(02);
   DEFINE vid_canal             char(02);
   DEFINE vuser_limit           char(08);
-- Jom FIN limites
   DEFINE vEscajero             char(01);
   DEFINE v_bloqprod            INTEGER;
   DEFINE vValDocto             char(01);
   DEFINE cAplica_restriccion   char(1);
   DEFINE vMensaje              char(100);
   DEFINE cCodCaracter          char(2);
-- Selecciona comision por tipo de producto JOM INI
   DEFINE vCodigoComisionEfe     CHAR(04);
-- Selecciona comision por tipo de producto JOM FIN
   DEFINE dfh_pre_devol_an      DATE;
   DEFINE dfh_devol_an          DATE;
   DEFINE dfh_trasp_devol       DATE;
   DEFINE dSdoCapInsol          DECIMAL(18,2);
   DEFINE v_tp_proceso          CHAR (1);
   DEFINE total_movimiento      DECIMAL(10,2);
   DEFINE saldo_incremento      DECIMAL(10,2);
   DEFINE vIndDispEfec          INTEGER; --RQM 10 1225
   DEFINE vIndDispEfecProd      CHAR(1); --RQM 10 1225
   DEFINE vLinCredAct           DECIMAL(18,2); --RQM 10 1225
   DEFINE v_sdoacumulado        DECIMAL(18,2); --RQM 10 1225
   DEFINE v_montoact            DECIMAL(18,2); --RQM 10 1225
   DEFINE cMen_ret              CHAR(100); --RQM 10 1225
   DEFINE vDispEfec             CHAR(1); --RQM 10 1225
   DEFINE v_bactsaldo           SMALLINT; --RQM 10 1225
   DEFINE cMtoVen               DECIMAL(18,2);
   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************

   ON EXCEPTION SET sql_err, isam_err, error_info
      --SET DEBUG FILE TO "CargoLineaCredito.err";
   --   TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET cod_ret = sql_err;
      LET Saldo = 0;
      LET FechaHoy = NULL;
      RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
         cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;
   END EXCEPTION;

--SET DEBUG FILE TO "/RESPALDOS/Prueba_SP_cargoref_tdc/cargoref_cel.out";
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************

   LET wBegin           = "N";
   LET vusuario         = USER;
   LET cod_ret          = "000";
   LET Saldo            = 0;
   LET SaldoCom         = 0;
   LET cod_ret2         = "000";
   LET cod_ret_inc      = "000";
   LET isam_err         = 0;
   LET error_info       = '';
   LET nrows            = 0;
   LET Mensaje          = '';
   LET Mensaje_inc      = '';
   LET NumProducto      = '';
   LET StatusCred       = '';
   LET cMtoVen          = 0;
   LET TipoCredito      = '';
   LET MontoOtorgado    = 0;
   LET FechaHoy         = NULL;
   LET pForzado         = '';
   LET v_paso           = 0;
   LET MtoTot           = 0;
   LET TotCargo         = 0;
   LET TotComision      = 0;
   LET CodigoRef        = 0;
   LET CodigoFun        = '';
   LET wSucursal        = '';
   LET wDivisa          = '';
   LET v_valor          = 0;
   LET v_tipocambio     = 0;
   LET v_mensaje        = "??";
   LET v_com1_dlls      = 0;
   LET v_com2_dlls      = 0;
   LET v_mtofavor_dlls  = 0;
   LET v_mto1_dlls      = 0;
   LET v_mto2_dlls      = 0;
   LET vMtoComDisp      = 0;
   LET vMtoComDisp_iva  = 0;
   LET vMtoPaso         = 0;
   LET v_mn             ='';
   LET v_dv             ='';
   LET TasaIva          = 0;
   LET Iva              = 0;
   LET v_faplica        = '';
   LET v_factor         = 0;
   LET v_rangos         ='';
   LET v_rmax           = 0;
-- Jom INI Bloqueo de cuentas
   LET vBloqueo         = 0;
-- Jom FIN Bloqueo de cuentas
   LET vMtoFavor        = 0;
   LET pNumTranFavor = pNumTran;
   LET pNumTranFavor2 = pNumTran;
-- Jom INI limites
   LET vnum_cliente     = '';
   LET vcodret          = '';
   LET vmsje_limites    = '';
   LET vid_autor        = '';
   LET vid_transacc     = '';
   LET vid_canal        = '';
   LET vuser_limit      = '';
-- Jom FIN limites
   LET v_bloqprod       = 0;
   LET vMtoPaso2       = 0;
   LET vEscajero = '0';
   LET vValDocto = '';
   LET cAplica_restriccion = '0';
   LET vMensaje = '';
   LET cCodCaracter = '';
   LET v_codparam   = '';
   LET wEmpresa     = '';
   LET vSdoPos      = 0;
-- Selecciona comision por tipo de producto JOM INI
   LET vCodigoComisionEfe = '';
-- Selecciona comision por tipo de producto JOM FIN
   LET dfh_pre_devol_an = date(1);
   LET dfh_devol_an     = date(1);
   LET dfh_trasp_devol  = date(1);
   LET dSdoCapInsol = 0;
   
   LET v_tp_proceso = "";
   LET total_movimiento = 0;
   LET saldo_incremento = 0;
   LET vIndDispEfec     = 0; --RQM 10 1225
   LET vLinCredAct      = 0; --RQM 10 1225
   LET cMen_ret         = ''; --RQM 10 1225
   LET vDispEfec        = 0; --RQM 10 1225
   LET vIndDispEfecProd = ''; --RQM 10 1225
   LET v_montoact       = 0; --RQM 10 1225
   LET v_bactsaldo      = 0; --RQM 10 1225
   LET v_sdoacumulado   = 0; --RQM 10 1225  
   
   
   --se obtiene la transaccion a favor de acuerdo a la transaccion recibida
    SELECT transacc_favor,cajero,aplica_restriccion
    INTO pNumTranFavor,vEscajero,cAplica_restriccion
    FROM "informix".sd_conceptoscargoscredito
    WHERE transacc = pNumTran;

    IF dbinfo("sqlca.sqlerrd2") = 0 THEN--cuando no exista en la tabla se pone el valor por default
      LET pNumTranFavor = pNumTran;
      LET vEscajero = '0';
      LET cAplica_restriccion = '0';
    END IF;

    IF LENGTH(TRIM(pSucursal)) = 3 then
       LET pSucursal = "9" || TRIM(pSucursal);
    END IF

   SELECT valor INTO v_mn FROM bdinteg:"informix".si_param WHERE cod_param = 15; -- codigo mn
   SELECT valor INTO v_dv FROM bdinteg:"informix".si_param WHERE cod_param = 17; -- divisa de cambio
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

   SELECT fecha_hoy
     INTO FechaHoy
     FROM "informix".sd_fechas;
    --WHERE empresa = wEmpresa;

   -- ************************
   -- Busca Datos del Credito*
   -- ************************
       SELECT a.empresa, a.sucursal, a.divisa, a.num_producto, a.status_cred,
              b.monto_otorgado - (b.sdo_cap_insoluto + sdo_retenido),
          c.cod_tipcred, d.iva, e.fecha_proceso,
          CASE WHEN sdo_capital < 0 THEN  sdo_capital * -1 ELSE 0 END,
          a.id_unidad_prod, numcte,Cod_caract_2, cod_comision_efectivo, sdo_cap_insoluto,
          b.sdo_acum_vencido, a.diferimiento_int, c.ind_disp_efec, nvl(b.monto_vencido + b.mto_venc_trasp,0) --RQM 10 1225
         INTO wEmpresa, wSucursal, wDivisa, NumProducto, StatusCred,
              Saldo, TipoCredito, TasaIva, FechaHoy, vSdoPos,
              vBloqueo, vnum_cliente,cCodCaracter, vCodigoComisionEfe, dSdoCapInsol,
              v_sdoacumulado, vDispEfec, vIndDispEfecProd, cMtoVen --RQM 10 1225
         FROM "informix".sd_maecred a, "informix".sd_maesdos b, "informix".sd_definicion c, "informix".sd_maecredanexo e,
          bdinteg:"informix".si_sucursales d
        WHERE a.num_credito = pNumCredito
          AND a.empresa = "001"
          AND b.num_credito = a.num_credito
          AND a.empresa = b.empresa
          AND c.num_producto = a.num_producto
          AND e.num_credito = a.num_credito
          AND e.empresa = a.empresa
          AND d.empresa = a.empresa
          AND d.sucursal = pSucursal;

   LET nrows = dbinfo("sqlca.sqlerrd2");
   IF(nrows = 0) THEN
      LET Saldo = 0;
      IF pNumTranS = "9999" then
        LET cod_ret = "100";
      ELSE
        LET cod_ret = "008";
      END IF
      RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
         cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;
   END IF;

   IF(TipoCredito <> "03") THEN -- Credito no es tarjeta
      LET cod_ret = "206";
      RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
         cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;
   END IF;
   
   -- Obtiene marcas de creditos pre-cancelados por devolucion de anualidad
   SELECT nvl(date(fecha_pre_devol_anual),date(1)), nvl(date(fecha_devol_anual),date(1)), nvl(date(fecha_trasp_devol_anual), date(1))
     INTO dfh_pre_devol_an, dfh_devol_an, dfh_trasp_devol
     FROM bdicred:sd_indicador_cred WHERE empresa = "001" AND num_credito = pNumCredito;

-- ini -- Se agrega bloqueo de cuentas
-- Bloqueo de cuentas operaciones
-- id_unidad_prod = 2 = bloqueo pago
-- id_unidad_prod = 3 = bloqueo disposicion
-- id_unidad_prod = 4 = bloqueo pago y disposicion

--Jom ini Bloqueo de creditos
   IF ((vBloqueo = 3 or vBloqueo = 4) AND (cAplica_restriccion = '0') ) OR    ((vBloqueo = 3 or vBloqueo = 4) AND  cAplica_restriccion = '1' AND NVL(cCodCaracter,'') = '01') THEN -- Bloqueado
     -- Identifica si el cliente esta marcado como precancelado por devolucion de comision por anualidad y permita realizar el retiro de lo abonado
    IF vBloqueo = 4 AND nvl(dfh_pre_devol_an,date(1)) > date(1) AND nvl(dfh_devol_an,date(1)) = date(1) AND dSdoCapInsol < 0 THEN
        LET cod_ret = "000"; 
    ELIF vBloqueo = 4 AND nvl(dfh_pre_devol_an,date(1)) > date(1) AND nvl(dfh_devol_an,date(1)) > date(1) AND dSdoCapInsol = 0 THEN
        LET cod_ret = "1207";   -- Credito cancelado. (la devolucion ya se retiro)
        RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
        cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;
    ELIF vBloqueo = 4 AND nvl(dfh_pre_devol_an,date(1)) > date(1) AND nvl(dfh_devol_an,date(1)) = date(1) AND nvl(dfh_trasp_devol,date(1)) > date(1) THEN
        LET cod_ret = "1209";   -- DEVOLUCION DE ANUALIDAD HA SIDO TRASPASADA. FAVOR DE TRAMITAR ACLARACION
        RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
        cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;   
     ELSE
        LET cod_ret = "207";
        RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
         cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;
     END IF;
   END IF
-- Jom Fin Bloqueo de creditos

   -- Si el credito tiene devolucion de anualidad, el retiro sea por el monto total de la devolucion.
   IF vBloqueo = 4 AND nvl(dfh_pre_devol_an,date(1)) > date(1) AND nvl(dfh_devol_an,date(1)) = date(1) AND dSdoCapInsol < 0 THEN
     IF (dSdoCapInsol * -1) != pMonto THEN -- Si monto a retirar no corresponde con monto de devolucion no procede retiro.
        LET cod_ret = '1206';
        RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
         cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;
     END IF;
     IF pNumTran != '6900' OR pNumTranS != '6900' THEN -- Si retiro no es en ventanilla, no procede retiro.
        LET cod_ret = '1210';
        RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
         cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;
     END IF;
   END IF;

   IF SUBSTR(StatusCred,1,1) IN ("B", "F", "C") OR (StatusCred in ('E1','E2','E3') and cMtoVen > 0)  THEN -- Cancelado o Bloqueado

     IF NOT (StatusCred IN ('BT','BA','E1','E2','E3') AND cAplica_restriccion = '1' ) THEN
        LET cod_ret = "207";
        RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
         cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;
     END IF

   END IF;

    select count(*)
      into v_bloqprod
      from bdicred:"informix".sd_bloqueoprod
     where num_producto=NumProducto
       and transac_bloq in (pNumTran,pNumTranFavor,pComNumTran,pComNumTranS,pComCashNumTran,pComCashNumTranS);

   IF v_bloqprod > 0  THEN -- bloqueo por producto
      LET cod_ret = "199";
      RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
         cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;
   END IF;

   -- ****************************
   -- Valida Datos del Plasticos *
   -- ****************************

   SELECT valida_docto
     INTO vValDocto
     FROM bdinteg:"informix".si_transacc
    WHERE empresa = wEmpresa
      AND sistema = "06"
      AND numero = pNumTran;

   IF ( nvl(vValDocto,'') <> 'T' ) then
       SELECT COUNT(*) INTO v_valor
         FROM "informix".sd_tarjeta
        WHERE empresa = wEmpresa
          AND num_tarjeta = pTarjeta
          AND status_tar = "A";
--          AND expiracion >= FechaHoy;

       IF v_valor IS NULL OR v_valor = 0  AND cAplica_restriccion = '0' THEN -- No hay Plasticos Asignados
          LET cod_ret = "208";
          RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
             cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;
       END IF;
   END IF;

   -- ********************************************************
   -- Extrae Tipo de Cambio si se requiere para la operacion *
   -- ********************************************************
    IF pDivisa <> v_mn OR pComDivisa <> v_mn OR pComCashDivisa <> v_mn THEN
        SELECT precio_venta INTO v_tipocambio
              FROM bdinteg:"informix".si_tpcambio
         WHERE empresa = "001"
           AND divisa = v_dv
           AND clase_tpcambio = "O"
           AND fecha_tpcambio = (SELECT MAX(fecha_tpcambio)
                       FROM bdinteg:"informix".si_tpcambio
                      WHERE empresa = "001"
                        AND divisa = v_dv);
    END IF

   -- *******************************************************
   -- Valoriza Movimientos en Moneda Diferente a 01 (Pesos) *
   -- *******************************************************

   IF pDivisa <> v_mn THEN
    LET v_mto1_dlls = pMonto;
    LET pMonto = v_mto1_dlls * v_tipocambio;
    LET v_mto2_dlls = pMonto2;
    LET pMonto2 = v_mto2_dlls * v_tipocambio;
   END IF

   IF pComMonto > 0 THEN
    IF pComDivisa <> v_mn THEN
        LET v_com1_dlls = pComMonto;
        LET pComMonto = v_com1_dlls * v_tipocambio;
    END IF
   END IF

   IF pComCashMonto > 0 THEN
    IF pComCashDivisa <> v_mn THEN
        LET v_com2_dlls = pComCashMonto;
        LET pComCashMonto = v_com1_dlls * v_tipocambio;
    END IF
   END IF
   -- *********************************************
   -- Extrae Comision por disposicion de efectivo *
   -- *********************************************
   
   -- AAME Se contempla la nueva transaccion 6846 para el cargo del impuesto GDF. 2013-08-13
   -- PIQV Se contempla transaccion 6845 para el cargo del impuesto GDF Banca por Internet sin cobrar comision. 2013-08-20

   IF  pNumTrans IN ("6952","0800","6900","0871","0872","0873","6846","6845","8105","6800","6871","6872","6873","8022","8045","4316","4317") THEN    
   --IF  pNumTrans IN ("6952","6800","6900","6871","6872","6873","6846","6845","8105") THEN 
        SELECT valor INTO v_codparam
          FROM "informix".sd_param
         WHERE empresa = wEmpresa
           AND cod_param = "334";

        IF vSdoPos > 0 AND vSdoPos < pMonto THEN
            LET vMtoPaso = pMonto - vSdoPos;
        ELIF vSdoPos > 0 AND vSdoPos >= pMonto THEN
            LET vMtoPaso = 0;
        ELIF vSdoPos = 0 THEN
            LET vMtoPaso = pMonto;
        END IF

        IF vMtoPaso > 0 AND pNumTrans NOT IN ("6846","6845","8022","8045") THEN  -- AAME Para que realice el calculo del monto Paso pero sin cobrar comision. 2013-08-13
-- Selecciona comision por tipo de producto JOM INI

                SELECT form_aplica, monto, apli_factor, consi_rango, monto_max
                  INTO v_faplica, vMtoComDisp, v_factor, v_rangos, v_rmax
                  FROM "informix".sd_tpcomis
                 WHERE empresa = wEmpresa
                   AND cod_comis = vCodigoComisionEfe;

--                SELECT form_aplica, monto, apli_factor, consi_rango, monto_max
--                  INTO v_faplica, vMtoComDisp, v_factor, v_rangos, v_rmax
--                  FROM "informix".sd_tpcomis
--                 WHERE empresa = wEmpresa
--                   AND cod_comis = v_codparam;

-- Selecciona comision por tipo de producto JOM FIN

                IF v_faplica = 2 THEN
                        LET vMtoComDisp = vMtoPaso * (v_factor/100);
                END IF

                IF v_rangos = "1" THEN
                        IF vMtoComDisp < v_rmax THEN
                                LET vMtoComDisp = v_rmax;
                        END IF
                END IF
        END IF
   END IF

   -- *******************************************************
   -- Calcula Iva Global por Comision, solo para validacion *
   -- *******************************************************
             -- RRG Se modifica para el proyecto de circular 22/2010 comisiones ATM 26/10/2010
   if (pSurcharge = 'V') then
      LET Iva = (pComCashMonto * TasaIva) ;     -- RRG Se modifica para el proyecto de circular 22/2010 comisiones ATM 26/10/2010
   else
      LET Iva = (pComMonto + pComCashMonto) * TasaIva;     -- RRG Se modifica para el proyecto de circular 22/2010 comisiones ATM 26/10/2010
   end if;
   LET vMtoComDisp_iva = vMtoComDisp * TasaIva;     -- RRG Se agrega para el proyecto de circular 22/2010 comisiones ATM 26/10/2010
   LET Iva = Iva +  vMtoComDisp_iva;                -- RRG Se agrega para el proyecto de circular 22/2010 comisiones ATM 26/10/2010

   
   -- *******************************************************
   -- Valida bitacora para incrementos de linea de credito  *
   -- *******************************************************   
    LET total_movimiento = pMonto + pMonto2 + pComMonto + pComCashMonto + vMtoComDisp + Iva;
    /*
    SELECT tp_proceso
        INTO v_tp_proceso
    FROM bdicred:sd_status_incremento_reduccion 
        WHERE  empresa = wEmpresa AND num_credito = pNumCredito AND tp_proceso = "R";

    IF NVL (v_tp_proceso,"") <> "" THEN
    
        EXECUTE PROCEDURE bdicred:sp_incremento_reduccion (wEmpresa,pNumCredito,0,total_movimiento,"I",0,pNumTran)
            INTO cod_ret_inc,Mensaje_inc, saldo_incremento;
            
            IF cod_ret_inc ::INTEGER = 0 THEN 
                LET Saldo = saldo_incremento;
            END IF;
            
    END IF;
	*/
   -- ***************************************
   -- Valida Disponible vs Monto Movimiento *
   -- ***************************************
   IF Saldo < total_movimiento THEN
     LET cod_ret = "005";
     RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
            cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;
   END IF 
   
   -- ******************************************************
   -- Valida Monto solicitado en disposicion en efectivo   * 
   -- vs Monto otorgado en credito - RQM 10 1225           * 
   -- ******************************************************    
    IF nvl(vIndDispEfecProd,'') = '1' AND pNumTrans in ('0800','6800','0871','0872','0873','6900','7380','8105','8112','6952','6871','6872','6873') AND  nvl(vDispEfec,'') in (1,2) THEN --El indicador de porcentaje de efectivo
            EXECUTE PROCEDURE bdicred:"informix".sp_evaldispefec_cred (pNumCredito,pMonto) 
                INTO cod_ret, vIndDispEfec, vLinCredAct, cMen_ret;                                                                                                                                                                                                                                                                                                                                                  
            IF cod_ret != '00000' THEN --Codigos de retorno controlados
               IF (cod_ret in ('00301','00302','00303') and pNumTrans in ('0871','0872','0873','6871','6872','6873')) THEN
                    LET cod_ret = "005";
               ELSE
                    IF cod_ret = '00301' THEN
                        LET cod_ret = LTRIM('00301', '00');
                    ELIF cod_ret = '00302' THEN
                        LET cod_ret = LTRIM('00302', '00');
                    ELIF cod_ret = '00303' THEN 
                          LET cod_ret = LTRIM('00303', '00');
                    END IF;                                            
               END IF;
               RETURN cod_ret, pNumTrans, FechaHoy, Saldo, MtoTot, cod_ret2, pComNumTran, FechaHoy, SaldoCom, TotComision;  
            ELSE --Se permite la disposicion
                IF vSdoPos > 0 AND vSdoPos <= pMonto THEN
                    LET v_montoact = v_sdoacumulado + (pMonto - vSdoPos);
                ELIF vSdoPos > 0 AND vSdoPos > pMonto   THEN
                    LET v_montoact = v_sdoacumulado;                
                ELSE
                    LET v_montoact = pMonto + v_sdoacumulado;
                END IF
                LET v_bactsaldo = 1;            
            END IF; 
    END IF;
    
   -- *********************************************
   -- validacion de limites de operaciones        *
   -- *********************************************
--validacion de limites jom ini
    select usuario
      into vuser_limit
      from bdinteg:"informix".si_usuario_limites
     where usuario = pUsuario
       and empresa = wEmpresa;

      if ( vuser_limit is not null or vuser_limit <> '' ) then
    -- // validacion adicional para reconocimiento de canal 120612
        IF (vuser_limit = "intercar") then
            select id_transacc, id_canal
              into vid_transacc, vid_canal
              from bdinteg:"informix".si_transacc_limites
             where transacc = pNumTrans
               and sistema = '06'
               and empresa = wEmpresa;
         ELSE
          SELECT id_canal
          into vid_canal
             from bdinteg:si_canales
          where cc_canal = psucursal;

            select id_transacc, id_canal
              into vid_transacc, vid_canal
              from bdinteg:"informix".si_transacc_limites
             where transacc = pNumTrans
               and sistema = '06'
               and empresa = wEmpresa
                and id_canal = vid_canal;
         END IF;



            if (vid_transacc is not null or vid_transacc <> '') then
-- RQI 01 050 Ajuste envio de mensajes JOM INI
-- Se agrega el parametro de tarjeta
                execute procedure bdinteg:"informix".sp_limite_max(vnum_cliente, pNumCredito, vid_transacc, vid_canal, FechaHoy, pMonto,pTarjeta,pFolio,preferencia)
-- RQI 01 050 Ajuste envio de mensajes JOM FIN
                into vcodret, vmsje_limites, vid_autor;

                if (vcodret = '00035') then
                     LET cod_ret = "035";
                     RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
                            cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;

                end if;
            end if;
        end if;

--validacion de limites jom ini

   -- ***********************************
   -- Determina Total de la Transaccion *
   -- ***********************************
   LET MtoTot =pMonto + pMonto2 + pComMonto + pComCashMonto + vMtoComDisp + Iva;
   LET TotComision = pComMonto + pComCashMonto + vMtoComDisp + Iva;
   LET SaldoCom = Saldo - TotComision;

   -- *************************************************************************
   -- *         Afecta Movimiento(s) de Cargo y Comision Respectivamente      *
   -- *************************************************************************

   -- ******************************************************
   -- Afecta Movto(s) de Disposicion en Cajeros y/o Compra *
   -- ******************************************************
   LET vMtoFavor= pMonto - vMtoPaso;

   IF pDivisa <> v_mn THEN
        LET v_mtofavor_dlls =  vMtoFavor / v_tipocambio;
    else
        LET v_mtofavor_dlls = 0;
    end if;


   IF vMtoFavor > 0 THEN
        EXECUTE PROCEDURE "informix".cargo_cred(wEmpresa, pNumCredito, pSucursal,
                         pUsuario, pNumTranFavor, vMtoFavor, pFolio,
                         pTarjeta, v_mtofavor_dlls, v_tipocambio,
                         FechaHoy, pReferencia,"","")
        INTO cod_ret;

        IF cod_ret <> "000" THEN
            LET TotComision = 0;
            LET Saldo = 0;
            RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
                   cod_ret2, pComNumTran, FechaHoy, SaldoCom, TotComision;

        END IF;
   END IF;

   IF vMtoPaso > 0 THEN
        EXECUTE PROCEDURE "informix".cargo_cred(wEmpresa, pNumCredito, pSucursal,
                         pUsuario, pNumTrans, vMtoPaso, pFolio,
                         pTarjeta, v_mto1_dlls, v_tipocambio,
                         FechaHoy, pReferencia,"","")
        INTO cod_ret;

        IF cod_ret <> "000" THEN
            LET TotComision = 0;
            LET Saldo = 0;
            RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
                   cod_ret2, pComNumTran, FechaHoy, SaldoCom, TotComision;
        END IF;
   END IF;
    
    --En caso de no tener saldo a favor se acumula la disposicion de efectivo
    IF v_bactsaldo = 1 THEN --RQM 10 1225-2
        UPDATE bdicred:"informix".sd_maesdos 
        SET sdo_acum_vencido = v_montoact
        WHERE empresa='001' and num_credito = pNumCredito;
    END IF;

   -- ***********************************************************
   -- Afecta Movimiento(s) por Comision de Disposicion o COmpra *
   -- ***********************************************************
   IF pComMonto > 0 THEN

-- jon ini mod surcharge
        if (pSurcharge = 'V') then
            if (pComNumTrans = '0857') then     -- red
                LET pComNumTrans = '0890';
            elif (pComNumTrans = '0858') then -- convenio
                LET pComNumTrans = '0891';
            elif (pComNumTrans = '0859') then -- internacional
                LET pComNumTrans = '0892';
            end if;
        end if;
-- jon fin mod surcharge

        EXECUTE PROCEDURE "informix".cargo_cred(wEmpresa, pNumCredito, pSucursal,
                                     pUsuario,pComNumTrans,pComMonto, pComFolio,
                                     pTarjeta, v_com1_dlls, v_tipocambio,
                                     FechaHoy, pComReferencia,"","")
        INTO cod_ret;

        IF cod_ret <> "000" THEN
            LET cod_ret2 = cod_ret;
                    LET TotComision = 0;
                    LET Saldo = 0;
                    RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
                           cod_ret2, pComNumTran, FechaHoy, SaldoCom, TotComision;

        END IF
   END IF

   -- ********************************************
   -- Afecta Movto(s) de Disposicion en Comercio *
   -- ********************************************
   IF pMonto2 > 0 THEN

        EXECUTE PROCEDURE "informix".cargo_cred(wEmpresa, pNumCredito, pSucursal,
                                     pUsuario, pCashTranCen, pMonto2,pCashFolio,
                                     pTarjeta, v_mto2_dlls, v_tipocambio,
                                     FechaHoy, pReferencia,"","")
        INTO cod_ret;

        IF cod_ret <> "000" THEN
                LET TotComision = 0;
                LET Saldo = 0;
                RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
                       cod_ret2, pComNumTran, FechaHoy, SaldoCom, TotComision;

        END IF

   END IF

   -- **************************************************************
   -- Afecta Movimiento(s) por Comision de Disposicion en Comercio *
   -- **************************************************************
   IF pComCashMonto > 0 THEN

        EXECUTE PROCEDURE "informix".cargo_cred(wEmpresa, pNumCredito, pSucursal,
                                     pUsuario,pComCashNumTrans, pComCashMonto,
                     pComCashFolio, pTarjeta, v_com2_dlls,
                     v_tipocambio, FechaHoy,
                     pComCashReferencia,"","")
        INTO cod_ret;

        IF cod_ret <> "000" THEN
        LET cod_ret2 = cod_ret;
                LET TotComision = 0;
                LET Saldo = 0;
                RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
                       cod_ret2, pComNumTran, FechaHoy, SaldoCom, TotComision;

        END IF
   END IF

   -- **************************************************************
   -- Afecta Movimiento(s) por Comision de Disposicion de Efectivo *
   -- **************************************************************
   IF vMtoComDisp > 0 THEN

        EXECUTE PROCEDURE "informix".cargo_cred(wEmpresa, pNumCredito, pSucursal,
                                     pUsuario,v_codparam, vMtoComDisp,
                                     pFolio, pTarjeta, v_com2_dlls,
                                     v_tipocambio, FechaHoy,
                                     pComCashReferencia,"","")
        INTO cod_ret;

        IF cod_ret <> "000" THEN
                LET TotComision = 0;
                LET Saldo = 0;
                RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
                       cod_ret2, pComNumTran, FechaHoy, SaldoCom, TotComision;

        END IF
   END IF

   LET Saldo = Saldo - MtoTot;

-- jom ini -- Se elimina el iva del total comision
   if (pSurcharge = 'V' or vEscajero = '1') then
      LET TotComision = vMtoComDisp + vMtoComDisp_iva;      -- RRG Se modifica para el proyecto de circular 22/2010 comisiones ATM 26/10/2010
   else
      LET TotComision = TotComision - Iva;
   end if;
-- jom fin

   RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
      cod_ret2, pComNumTran, FechaHoy, SaldoCom, TotComision;


END PROCEDURE;