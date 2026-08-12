CREATE PROCEDURE "informix".sp_buscarctesamigrar(pnumcte CHAR(20),iOpcion INTEGER, pSucursal CHAR(4), pNombreEmbozado CHAR(60), pNumEjecutivo CHAR(8))
RETURNING	 CHAR(6), --Codigo Retorno
             CHAR(20), --Numero de Cliente
			 CHAR(20), --Numero de Credito
			 CHAR(60), --Direccion de la sucursal
			 CHAR(4), --Sucursal
			 CHAR(1), -- Bandera Verifica Estatus
			 CHAR(20),--Descripcion Estatus
			 CHAR(20),-- Fecha de solicitud
			 CHAR(10),--MONTO LINEA
			 CHAR(10),--IVA
			 CHAR(10),--INTERES MORATORIO
			 CHAR(10),--INTERES ORDINARIO
			 CHAR(6),--BIN
			 CHAR(8),--CODIGO DEL PRODUCTO
			 CHAR(8); --CLAVE TAJETA
			
             										 
DEFINE iSqlerr				INTEGER;
DEFINE iExiste				INTEGER;
DEFINE cCodret				CHAR(6);
DEFINE cCliente     		CHAR(20);
DEFINE cSucursal    		CHAR(20);
DEFINE iFlagstatus  		CHAR(1);
DEFINE cStatus      		CHAR(20);
DEFINE cFchsoli     		CHAR(20);
DEFINE cNomSuc      		CHAR(60);
DEFINE cLineaCredito 		CHAR(10);
DEFINE cCat          		CHAR(10);
DEFINE cInteresOrdinario 	CHAR(10);
DEFINE cInteresMoratorio 	CHAR(10);
DEFINE cCodBin      		CHAR(6);
DEFINE cCodProd 			CHAR(8);
DEFINE cCodClaveTar 		CHAR(8);
DEFINE cNumCredito 			CHAR(20);
DEFINE cDireccionSucursal 	CHAR(80);
DEFINE cSolOro 				VARCHAR(20);
DEFINE cLineaTeorica 		DECIMAL(18,2);
DEFINE v_valor		 		MONEY(14,2);
DEFINE v_capacidad_pago 	MONEY(14,2);
DEFINE iPlazo 				INTEGER; 
DEFINE sNombreCliente 		CHAR(100);
DEFINE sNumTarjeta			CHAR(16);
DEFINE sMiembro				CHAR(2);
DEFINE sCodRetOro           CHAR(6);
DEFINE sMsjRetOro           VARCHAR(100);

LET sCodRetOro              = '';
LET sMsjRetOro              = '';
--INICIALIZANDO VARIABLES
LET iSqlerr    			= 0;
LET iExiste	   			= 0;
LET cCodret    			= "000000";
LET cCliente  	 		= "";
LET iFlagstatus			= "";
LET cStatus    			= "";
LET cFchsoli   			= "";
LET cSucursal  			= "";
LET cNomSuc    			= "";
LET cLineaCredito		= "";
LET cCat                = "";
LET cInteresOrdinario	= "";
LET cInteresMoratorio	= "";
LET cCodBin				= "";
LET cCodProd			= "";
LET cCodClaveTar		= "";
LET cNumCredito 		= "";
LET cDireccionSucursal 	= "";
LET cSolOro 			= "";
LET cLineaTeorica 		= "";
LET v_valor		  		= 0;
LET v_capacidad_pago 	= 0;
LET iPlazo 		  		= 0;
LET sNombreCliente		= "";
LET sNumTarjeta			= "";
LET sMiembro			= "";


BEGIN
	ON EXCEPTION SET iSqlerr
		IF iSqlerr <> 0 THEN
			LET cCodret = iSqlerr;
			RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/home/sysifx/Oscar/736/sp_buscarctesamigrar.out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF pnumcte IS NULL OR pnumcte = '' OR iOpcion is NULL  THEN
		LET cCodret="000100";
		RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
	END IF;
	

	SELECT numcte,num_credito,nomsuc,sucursal,flagstatussol,status,fchsoli 
	INTO cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli
	FROM bdicred:"informix".sd_ctesamigrar WHERE numcte = TRIM(pnumcte);
   
	IF iOpcion=0  THEN
		IF DBINFO("sqlca.sqlerrd2") = '0' THEN -- No existe el cliente
			LET cCodret="000001";
			RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
		ELSE
			IF (iFlagstatus IS NULL OR iFlagstatus='' OR iFlagstatus=3) THEN
				RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
			END IF;
		END IF;
	END IF;
	
	IF iOpcion=1  THEN -- Solicitud Rechazada
		IF NVL(pSucursal,'') = '' THEN
			LET cCodret="000100";
		ELSE
			SELECT TRIM(suc.nombre), (TRIM(suc.direccion1) || ", " || TRIM(suc.direccion2) || ", " || TRIM(ciu.nombre) || ", " || TRIM(est.nombre)) As Direccion 
			INTO cNomSuc,cDireccionSucursal
			FROM bdinteg: "informix".si_sucursales suc
			INNER JOIN bdinteg: "informix".si_estados est
			ON est.estado = suc.estado
			INNER JOIN bdinteg: "informix".si_ciudades ciu
			ON suc.ciudad = ciu.ciudad and suc.estado = ciu.estado
			WHERE  suc.empresa = '001'
			AND sucursal = pSucursal
			AND suc.tpo_sucursal = 'S';
			
			UPDATE  bdicred:"informix".sd_ctesamigrar SET  flagstatussol='3',status="Rechazada",fchsoli=TO_CHAR(current), sucursal = pSucursal, nomsuc =  cNomSuc, domsuc = TRIM(cDireccionSucursal) WHERE numcte=pnumcte;
		END IF;
		RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
	END IF;
   
	IF iOpcion=2 THEN -- Solicitud Aceptada
		IF NVL(pSucursal, '') = '' OR NVL(pNombreEmbozado,'') = '' OR NVL(pNumEjecutivo,'') = '' THEN
			LET cCodret="000100";
		ELSE
			SELECT TRIM(suc.nombre), (TRIM(suc.direccion1) || ", " || TRIM(suc.direccion2) || ", " || TRIM(ciu.nombre) || ", " || TRIM(est.nombre)) As Direccion 
			INTO cNomSuc,cDireccionSucursal
			FROM bdinteg: "informix".si_sucursales suc
			INNER JOIN bdinteg: "informix".si_estados est
			ON est.estado = suc.estado
			INNER JOIN bdinteg: "informix".si_ciudades ciu
			ON suc.ciudad = ciu.ciudad and suc.estado = ciu.estado
			WHERE  suc.empresa = '001'
			AND sucursal = pSucursal
			AND suc.tpo_sucursal = 'S';			
			
			SELECT TRIM(apell_paterno) || " " || TRIM(apell_materno) || " " || TRIM(nombre1) || " " || TRIM(nombre2) AS Nombre, b.num_tarjeta , SUBSTR(YEAR(c.fecha_apertura),3,2)
			INTO sNombreCliente, sNumTarjeta, sMiembro
			FROM bdicred:"informix".sd_ctesamigrar a			
			INNER JOIN bdicred:"informix".sd_tarjeta b ON a.num_credito = b.num_credito
			INNER JOIN bdicred:"informix".sd_maecred c ON c.num_credito = a.num_credito
			WHERE a.numcte = pnumcte 
			AND a.num_credito = cNumCredito 
			AND b.numcte = a.numcte
			AND c.numcte = b.numcte
			AND b.status_tar = 'A';
			
			UPDATE  bdicred:"informix".sd_ctesamigrar SET  flagstatussol = '1',status = "Aceptada", fchsoli = TO_CHAR(current), sucursal = pSucursal, nomsuc =  cNomSuc, domsuc = TRIM(cDireccionSucursal) 
			WHERE numcte = pnumcte;
			
			LET sNombreCliente = REPLACE(sNombreCliente,"  ", " ");
			
			--INSERT INTO bdicred:"informix".sd_credito_upgrade(empresa, num_credito, numcte, numerotarjeta, numero_credito_upgrade, numerotarjeta_upgrade, num_producto_upgrade, tipotar, nombre, nombre_embosado, bandtarjpersonal, tipo_proceso, nombre_archivo, master, tipo_dom, miembro, resultado, bclonadocompleto, user_insert, fecha_insert, fecha_cancelaupgrade)
			--VALUES('001', cNumCredito, pnumcte, sNumTarjeta, '', '', '8100', 'TIT', TRIM(sNombreCliente), TRIM(pNombreEmbozado), '1', '1', '', '1', '1', sMiembro, '0', '0', pNumEjecutivo,CURRENT,NULL);

            EXECUTE PROCEDURE "informix".sp_graba_prod_upgrade('001', cNumCredito, pnumcte, sNumTarjeta, 'TIT', TRIM(sNombreCliente), 
             TRIM(pNombreEmbozado), '1', '1', pNumEjecutivo, '3', '', '8100') INTO sCodRetOro, sMsjRetOro;
		END IF;		
		RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
	END IF;
  
	IF iOpcion=3 THEN
		RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
	END IF;
  
	IF iOpcion=4 THEN
	  --SE OBTIENE EL VALOR DE LA TASA DE INTERES ORDINARIO
	  SELECT a.valor,b.cat_caratula,b.monto_min_cred INTO cInteresOrdinario,Ccat,cLineaCredito
	  FROM bdinteg:"informix".si_fechavalor AS a,bdicred:"informix".sd_definicion AS b
	  WHERE a.tasa = b.cod_tasa_base AND fecha = (SELECT MAX(fecha)
	  FROM bdinteg:"informix".si_fechavalor
	  WHERE  tasa=b.cod_tasa_base    --
	  AND b.num_producto = '8100');

	--SE OBTIENE EL VALOR DE LA TASA DE INTERES MORATORIO
	  SELECT a.valor INTO cInteresMoratorio
	  FROM bdinteg:"informix".si_fechavalor AS a, bdicred:"informix".sd_definicion AS b
	  WHERE a.tasa = b.cod_tasa_mora AND fecha = (SELECT MAX(fecha)
	  FROM bdinteg:"informix".si_fechavalor 
	  WHERE  tasa=b.cod_tasa_mora AND b.num_producto = '8100');  -- FMV 13-MAY-11 SE OMITE a.tasa para mostrar las tasas en reporte
	  LET cInteresMoratorio = cInteresMoratorio - cInteresOrdinario;
		IF cInteresMoratorio < 0 THEN
				LET cInteresMoratorio= cInteresMoratorio * -1;
		END IF;
	RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
	END IF;
 
	IF iOpcion=5 THEN
		SELECT codproductotarjeta,clave_tipotarjeta,bin  
		INTO cCodProd,cCodClaveTar,cCodBin 
		FROM intercard:"informix".tipotarjeta 
		WHERE codproductotarjeta = '005'
		AND Tipo = 'C'
		AND clave = '007';
		
		RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
	END IF;
	
	IF iOpcion = 6 THEN
		IF NVL(pnumcte,'') = '' THEN
			LET cCodret="000100";
		ELSE
			DELETE bdicred:"informix".sd_credito_upgrade WHERE numcte = pnumcte AND num_credito = cNumCredito;		
			UPDATE bdicred:"informix".sd_ctesamigrar SET sucursal = '',nomsuc = '',domsuc = '',flagstatussol = null,status = '',fchsoli = '' WHERE numcte = pnumcte;
			RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
		END IF;
	END IF;
	
  
END;
END PROCEDURE
DOCUMENT
'Se crea SP para consultar los  de clientes candidatos a actualizar su Tarjeta de Credito Visa Bancoppel a Tarjeta de Credito Oro Bancoppel',
'asi como actualizar su estatus (Aceptada, Rechazada) e insertar la solicitud.',
'AUTOR : Oscar Marquez 98681011',
'FECHA : 26/03/2021',
'BD    : BDICRED';

create procedure "informix".sp_rep_regulatorios_irb_compl(pEmpresa char(03))
returning 
          char(06) as resultado,
          char(80) as mensaje;

--************************ Definicion de variables *****************************
DEFINE cMensajeRet, cMensajeRet2     CHAR(80);

define iCodRet              integer;
define SCodRet              char(06);
define cSql                 char(5000);
define vfecha_hoy           DATE;
define cont                 integer;
define vFecha_proceso       DATE;
define vhora_inicio         char(8);
define vhora_fin            char(8);
define vstatus_proceso      char(2);
define NombreArchivo        char(50);
define NombreArchivoCifras  char(50);
define FechaReporte         date;
define PrimerDiaMes         date;
define UltimoDiaMes         date;
define vDia,v_mes_corte     char(2);
define vMes,v_mes_appdate   char(2);
define vAnio                char(4);

define cNumCliente          char(20);
define cNumCredito          char(20);
define cauxNumCredito          char(20);
define dFechaApertura       date;
define sMesesVencidos       smallint;
define cStatusCredito       char(02);
define dPagoMinimo          dec(18,2);
define dSaldoCorte          dec(18,2);
define dSdoDisponible       dec(18,2);
define dFechaLimitePago     date;
define dFechaCorte          date;
define dPagosPAYMENTS       dec(18,2);
define dComprasPURCHASES    dec(18,2);
define dDispWITHDRAWALS     dec(18,2);
define dIntereses           dec(18,2);
define dMOB                 dec(18,2);
define dLimiteCredito       dec(18,2);
define dTasa                dec(9,6);
define v_tasa               dec(5,2);
define dFecha               date;
define dSdoCorteAnt         dec(18,2);
define dIva                 dec(18,2);
define iNumDispCASHATM      dec(18,2);
define iNumPagosPAYMENTS    dec(18,2);
define iNumCompPURCHASES    dec(18,2);
define iImpComisiones       dec(18,2);
define dFechaIni            date;

define cApplicationId      char(20);
define cApplicationDate    char(08);
define cApplicationStatus  char(02);
define dRequestedAmount    decimal(18,2);
define cTerm               char(01);
define cDownPayment        char(10);
define cPostalCode         char(05);
define cPostalCode4        char(05);
define cLastName           char(50);
define cFirstName          char(50);
define cMiddleName         char(50);
define cNameSuffix         char(01);
define cCharacterBlanks    char(01);
define cHouseNumber        char(10);
define cNombreZona         char(50);
define cThoroughfareName   char(50);
define cThoroughfareType   char(01);
define cApartmentNumber    char(10);
define cCityName           char(50);
define cGender             char(06);
define cAge                char(03);
define cJobType            char(50);
define cTelephone          char(15);
define cPresenceCknSvn     char(01);
define cTimeResidence      char(03);
define cTimeJob            char(03);
define dMonthlyIncome      decimal(18,2);
define dMonthlyExpense     char(12);   
define cNumberDependents   char(03);
define cNumberPeopleHouse  char(03);
define cYearlyHouseIncome  char(10);
define cNumberDebtObli     char(03);
define cNumberPrevLoansBank char(02);
define cState               char(50);
define cTypeResidence	   char(15);
define sYearsCreditExp	   smallint;
define cnumerociudad	   smallint;

define v_term, v_name_suffix, v_character_blanks, v_presence_ckn_svn, v_thoroughfare_type                char(01);
define v_application_status, v_number_prev_loans_bank                                                    char(02);
define v_age, v_time_residence,v_time_job,v_number_dependents,v_number_people_house, v_number_debt_obli  char(03);
define v_postal_code, v_postal_code4                                                                     char(05);
define v_gender                                                                                          char(06);
define v_application_date                                                                                char(08);
define v_down_payment, v_apartment_number, v_house_number, v_yearly_house_income                         char(10);
define v_monthly_expense                                                                                 char(12);
define v_type_residence, v_telephone                                                                     char(15);
define v_application_id                                                                                  char(20);
define v_last_name, v_first_name, v_middle_name, v_nombrezona, v_thoroughfare_name, v_city_name, v_state char(50);
define v_job_type                                                                                        char(50);
define v_monthly_income, v_requested_amount                                                              decimal(18,2);
define v_years_credit_exp                                                                                smallint;

define v_status_credito                                                                                  char(15);
define v_numcte, v_num_credito                                                                           char(20);
define v_fecha_apertura, v_fecha_limite_pago, v_fecha_corte                                              date;
define v_meses_vencidos, v_pago_minimo, v_saldo_corte, v_sdo_disponible, v_sdo_corte_anterior, v_pagos_PAYMENTS, v_compras_PURCHASES  decimal(18,2);
define v_disposiciones_WITHDRAWALS, v_intereses, v_iva, v_rendimientos, v_comisiones, v_MOB, v_limite_credito                         decimal(18,2);
define v_numero_disposiciones_CASH_ATM, v_numero_pagos_PAYMENTS, v_numero_compras_PURCHASES              integer;

define vNumproceso            char(4);                  
define vCurrent, vCurrent2    char(25);
define vdia2                  date; 
define vhora, vhora2          char(8);
define vHora3                 char(22);
define v_fecha_emision        date;  
define v_num_solicitud        char(20);
define v_fecha_insert, v_fecha_nac, v_fechacorte_actual, v_fecha_finmesant         date;
define cNumCte          char(20);
define dMesesVencidos   decimal(18,2);
define dDisposicionesWithdrawals decimal(18,2);
define dFechaEmision      date;
define dSdoCorteAnterior decimal(18,2);
define iNumeroDisposicionesCashATM integer;
define iNumeroPagosPayments integer;
define iNumeroComprasPurchases integer;
define dComisiones      decimal(18,2);
define dRendimientos    decimal(18,2);
define vFechaappdate    date;

let vNumproceso    = '0054';
let v_term         = '';   let v_name_suffix       = '';  let v_character_blanks    = '';   let v_presence_ckn_svn = '';   let v_thoroughfare_type = '';
let v_mes_corte    = '';   let v_age               = '';  let v_time_residence      = '';   let v_number_debt_obli = '';   let v_postal_code       = '';
let v_time_job     = '';   let v_number_dependents = '';  let v_number_people_house = '';   let v_telephone        = '';   let v_nombrezona        = '';  
let v_gender       = '';   let v_application_date  = '';  let v_down_payment        = '';   let v_apartment_number = '';   let v_type_residence    = '';
let v_house_number = '';   let v_monthly_expense   = '';  let v_first_name          = '';   let v_middle_name      = '';   let v_last_name         =  '';                  
let v_city_name    = '';   let v_state             = '';  let v_job_type            = '';   let v_status_credito   = '';   let v_years_credit_exp  = 0;              
let v_postal_code4 = '';   let v_application_id    = '';  let v_compras_PURCHASES   = 0;    let v_intereses        = 0;    let v_saldo_corte       = 0;
let v_numcte       = '';   let v_num_credito       = '';  let v_meses_vencidos      = 0;    let v_pago_minimo      = 0;    let v_iva               = 0;                           
let v_rendimientos = 0;    let v_comisiones        = 0;   let v_MOB                 = 0;    let v_limite_credito   = 0;    let vHora3              = ''; 
let vCurrent       = '';   let vCurrent2           = '';  let vhora                 = '';   let vhora2             = '';   let cMensajeRet2        = ''; 
let cNumCte        = '';   let dMesesVencidos      = 0;   let v_sdo_disponible      = 0;    let v_monthly_income   = 0;    let dComisiones         = 0; 
let dRendimientos  = 0;    let v_mes_appdate       = '';  let dSdoCorteAnterior     = 0;    
let v_yearly_house_income           = '';   let dDisposicionesWithdrawals = 0;    let v_application_status        = '';  
let v_sdo_corte_anterior            = 0;    let v_pagos_PAYMENTS          = 0;    let v_disposiciones_WITHDRAWALS = 0;
let v_numero_disposiciones_CASH_ATM = 0;    let v_numero_pagos_PAYMENTS   = 0;    let v_numero_compras_PURCHASES  = 0;
let v_requested_amount              = 0;    let iNumeroPagosPayments      = 0;    let iNumeroDisposicionesCashATM = 0;
let v_number_prev_loans_bank        = '';   let iNumeroComprasPurchases   = 0;    let v_thoroughfare_name         = '';                                                                                    
let v_fecha_apertura  = date(1);  let v_fecha_limite_pago = date(1);  let v_fechacorte_actual = date(1);
let v_fecha_finmesant = date(1);  let dFechaEmision       = date(0);  let vdia2               = date(1); 
let v_fecha_emision   = date(1);  let v_fecha_nac         = date(1);  let v_fecha_insert      = date(1);
let v_fecha_corte     = date(1);
let vFechaappdate     = date(1);
  


--********************** Inicializacion de variables ***************************
let cMensajeRet = 'El proceso de REPORTES IRB_COMPL se realizó correctamente';
let iCodRet                 = 0;
let SCodRet                 = '000000';
let cont                    = 1;
let cSql                    = '';
let vFecha_proceso          = date(0);
let vhora_inicio            = '';
let vhora_fin               = '';
let vstatus_proceso         = '';
let NombreArchivo           = '';
let NombreArchivoCifras     = '';
let vDia                    = '';
let vMes                    = '';
let vAnio                   = '';

let cNumCliente          = '';
let cNumCredito          = '';
let cauxNumCredito       = '';
let dFechaApertura       = date(0);
let sMesesVencidos       = 0;
let cStatusCredito       = '';
let dPagoMinimo          = 0;
let dSaldoCorte          = 0;
let dSdoDisponible       = 0;
let dFechaLimitePago     = date(0);
let dFechaCorte          = date(0);
let dPagosPAYMENTS       = 0;
let dComprasPURCHASES    = 0;
let dDispWITHDRAWALS     = 0;
let dIntereses           = 0;
let dMOB                 = 0;
let dLimiteCredito       = 0;
let dTasa                = 0;
let dFecha               = date(0);
let dSdoCorteAnt         = 0;
let dIva                 = 0;
let iNumDispCASHATM      = 0;
let iNumPagosPAYMENTS    = 0;
let iNumCompPURCHASES    = 0;
let iImpComisiones       = 0;
let dFechaIni            = date(0);

let cApplicationId      = '';
let cApplicationDate    = '';
let cApplicationStatus  = '';
let dRequestedAmount    = 0;
let cTerm               = '';
let cDownPayment        = '';
let cPostalCode         = '';
let cPostalCode4        = '';
let cLastName           = '';
let cFirstName          = '';
let cMiddleName         = '';
let cNameSuffix         = '';
let cCharacterBlanks    = '';
let cHouseNumber        = '';
let cNombreZona         = '';
let cThoroughfareName   = '';
let cThoroughfareType   = '';
let cApartmentNumber    = '';
let cCityName           = '';
let cGender             = '';
let cAge                = '';
let cJobType            = '';
let cTelephone          = '';
let cPresenceCknSvn     = '';
let cTimeResidence      = '';
let cTimeJob            = '';
let dMonthlyIncome      = '';
let dMonthlyExpense     = '';
let cNumberDependents   = '';
let cNumberPeopleHouse  = '';
let cYearlyHouseIncome  = '';
let cNumberDebtObli     = '';
let cNumberPrevLoansBank = '';
let cState		= '';
let cTypeResidence	= '';
let sYearsCreditExp	= 0;
let cnumerociudad = 0;
let v_tasa = 0;

--**************************** Control de errores ******************************
begin
    on exception set iCodRet
	if iCodRet <> 0 then
--            execute procedure sp_obtener_hora() into vhora_fin;
        	let SCodRet = iCodRet;
--            let cMensajeRet ='Error al generar los REPORTES IRB_COMPL >> '||NombreArchivo;
            let cMensajeRet ='Error al generar los REPORTES IRB_COMPL >> '||cauxNumCredito;
			
            update bdicred:sd_param
               set valor = cont
             where empresa = pEmpresa and cod_param = '078';
             
              	
			return SCodRet,cMensajeRet ;
        end if;
    end exception;

-- Set debug file to "/RESPALDOSNEW/mbucio/sp_rep_regulatorios_irb_complMIB032.trc";
--  trace on;



--*******************a******** Programa principal *******************************
    -- obtener la hora que inicio la ejecucion el proceso
    --execute procedure sp_obtener_hora() into vhora_inicio;
 
    -- obtener la fecha de hoy
    select fecha_hoy,pri_dia_mes into vfecha_hoy,FechaReporte from bdicred:sd_fechas where empresa = pEmpresa;

/*
    --obtener la fecha en la que se realizara la ejecucucion.
    select fecha_proceso, status_proceso
      into vFecha_proceso, vstatus_proceso
      from bdicred:sd_control_procesos where empresa = pEmpresa and
           cod_proceso = 'CrearReportesIBR';

    if (vFecha_prox_proceso != vfecha_hoy) then
        return 'Hoy no se ejecuta el proceso "sp_crear_reportes_IBR()"';
    end if;
 
    -- checar si hoy ya se ejecuto y si finalizo correctamente
    if (vFecha_proceso=vfecha_hoy) then
        if(vstatus_proceso='F') then
            return 'El proceso "sp_crear_reportes_IBR()" ' ||
                   ' ya fue ejecutado hoy y finalizado con exito';
        end if;
        -- checar si se esta esjecutando el proceso
        if(vstatus_proceso='I') then
            return 'El proceso "sp_crear_reportes_IBR()" esta en ejecucion';
        end if;
    end if;

    -- checar si hoy se ejecuta
    --IF vFecha_prox_proceso=vfecha_hoy then

    -- actualizar el control proceso
        UPDATE bdicred:sd_control_procesos
               SET hora_inicio = vhora_inicio,
                   status_proceso = 'I',
                   fecha_proceso = vfecha_hoy,
                   mensaje = 'Proceso "sp_crear_reportes_IBR" en ejecusion'
             where cod_proceso = 'CrearReportesIBR';

    -- obtiene el numero de reporte con el que inicializara
    select parametros into cont
    from bdicred:sd_control_procesos where empresa = pEmpresa and
         cod_proceso = 'CrearReportesIBR';
*/

-- obtener el ultimo reporte generado.
  select trim(valor) into cont from bdicred:sd_param where cod_param = '078';

    if cont is null or cont = '' then
       let SCodRet = '000010';
       let cMensajeRet = 'No se encuentra el valor del número de reporte a ejecutar para IRB_COMPL.';
       return SCodRet,cMensajeRet ;
    elif cont < 1 or cont >=6 then
       let SCodRet = '000020';
       let cMensajeRet = 'El valor del número de reporte a ejecutar para IRB_COMPL no es válido.';
    end if;

--obtener los rangos de fechas para el mes del reporte en cuestion
    let PrimerDiaMes = FechaReporte - 1 units month;
    let UltimoDiaMes = FechaReporte - 1 units day;
    
    
-- obtener por separado el dia, mes y año de la fecha en cuestion para el nombre del archivo
    let vDia = lpad(day(UltimoDiaMes),2,'0');
    let vMes = lpad(month(UltimoDiaMes),2,'0');
    let vAnio = lpad(year(UltimoDiaMes),4,'0');

    LET v_fecha_finmesant = FechaReporte -1 UNITS day;
    LET v_fechacorte_actual = mdy(month(v_fecha_finmesant),20,year(v_fecha_finmesant));
         
 
 
    if(cont=1) then
-- crea el reporte payment_hist del RQM 07 044
-- Tarda 9 min aprox.
        
        let NombreArchivo = trim('PaymentHist_' || trim(vdia) || trim(vMes) || trim(vAnio) || '.txt');
        
        /*let cSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/archivoscartera/' || trim(NombreArchivo) ||
          ' DELIMITER ' || '''|'''  || ' select ' || 
          ' a.num_credito application_id,' ||
          ' a.fecha record_date,' ||
          ' b.status_cred status,' ||
          ' a.sdo_cap_insoluto saldo,' ||
          ' a.sdo_capital saldo_vigente,' ||
          ' a.mto_venc_trasp saldo_vdo_ex,' ||
          ' a.cap_tras_no_venci saldo_vdo_no_ex,' ||
          ' a.monto_vencido + a.mto_venc_trasp + a.cap_tras_no_venci saldo_vencido,' ||
          ' nvl(a.mto_fin_ven_trasp,0) delinquency_status,' ||
          ' b.fecha_apertura fecha_salida,' ||
          ' a.monto_otorgado linea_de_credito, ' ||
		  ' (select interes_pago_total_tc from bdicred@pld_tcp:sd_encabezado2_edocta where fecha_emision = mdy('||vMes||',20,'||vAnio||') - 1 units month and num_credito = a.num_credito) ' ||
		  ' saldo_a_pagar, ' ||
		  ' c.menos_abonos pago_realizado, ' ||
		  ' case when ' ||
		  ' (select interes_pago_total_tc from bdicred@pld_tcp:sd_encabezado2_edocta where fecha_emision = mdy('||vMes||',20,'||vAnio||') - 1 units month and num_credito = a.num_credito) <= 0 and c.menos_abonos = 0 then ''I'' else ' ||
		  ' case when (select interes_pago_total_tc from bdicred@pld_tcp:sd_encabezado2_edocta where fecha_emision = mdy('||vMes||',20,'||vAnio||') - 1 units month and num_credito = a.num_credito) = 0 and c.menos_abonos > 0 then ''T'' else ''N'' end end ' ||
      ' status_pago_cliente ' ||
          ' from bdicred:sd_maesdoscont a ' ||
          ' join bdicred:sd_maecredcont b on b.empresa = a.empresa and b.num_credito = a.num_credito and b.fecha = a.fecha ' ||
          ' left outer join bdicred@pld_tcp:sd_encabezado2_edocta c on c.fecha_emision = mdy('||vMes||',20,'||vAnio||') and c.num_credito = a.num_credito ' ||
          ' where a.fecha = ''' || UltimoDiaMes || ''' ' ||
          ' and a.empresa = ''' || pEmpresa || ''' ' ||
          ' and a.num_credito > ''600000000000'' ' ||
          ' and b.campo_trab3 <> ''BAJA'';"' ||
          ' > /resplogifx/archivoscartera/QueryPayMenthist.sql'; */
        
        let cSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/archivoscartera/' || trim(NombreArchivo) ||
          ' DELIMITER ' || '''|'''  || ' select ' || 
          ' a.num_credito application_id,' ||
          ' a.fecha record_date,' ||
          ' b.status_cred status,' ||
          ' a.sdo_cap_insoluto saldo,' ||
          ' a.sdo_capital saldo_vigente,' ||
          ' a.mto_venc_trasp saldo_vdo_ex,' ||
          ' a.cap_tras_no_venci saldo_vdo_no_ex,' ||
          ' a.monto_vencido + a.mto_venc_trasp + a.cap_tras_no_venci saldo_vencido,' ||
          ' nvl(a.mto_fin_ven_trasp,0) delinquency_status,' ||
          ' b.fecha_apertura fecha_salida,' ||
          ' a.monto_otorgado linea_de_credito, ' ||
          ' (select interes_pago_total_tc from bdicred:sd_info_edocta where fecha_emision = mdy('||vMes||',20,'||vAnio||') - 1 units month and num_credito = a.num_credito) ' ||
		    --' (select interes_pago_total_tc from bdicred@pld_tcp:sd_encabezado2_edocta where fecha_emision = mdy('||vMes||',20,'||vAnio||') - 1 units month and num_credito = a.num_credito) ' ||
		      ' saldo_a_pagar, ' ||
		      ' c.menos_abonos pago_realizado, ' ||
		      ' case when ' ||
		      ' (select interes_pago_total_tc from bdicred:sd_info_edocta where fecha_emision = mdy('||vMes||',20,'||vAnio||') - 1 units month and num_credito = a.num_credito) <= 0 and c.menos_abonos = 0 then ''I'' else ' ||
       -- ' (select interes_pago_total_tc from bdicred@pld_tcp:sd_encabezado2_edocta where fecha_emision = mdy('||vMes||',20,'||vAnio||') - 1 units month and num_credito = a.num_credito) <= 0 and c.menos_abonos = 0 then ''I'' else ' ||
		      ' case when (select interes_pago_total_tc from bdicred:sd_info_edocta where fecha_emision = mdy('||vMes||',20,'||vAnio||') - 1 units month and num_credito = a.num_credito) = 0 and c.menos_abonos > 0 then ''T'' else ''N'' end end ' ||
		   -- ' case when (select interes_pago_total_tc from bdicred@pld_tcp:sd_encabezado2_edocta where fecha_emision = mdy('||vMes||',20,'||vAnio||') - 1 units month and num_credito = a.num_credito) = 0 and c.menos_abonos > 0 then ''T'' else ''N'' end end ' ||      
          ' status_pago_cliente ' ||
          ' from bdicred:sd_maesdoscont a ' ||
          ' join bdicred:sd_maecredcont b on b.empresa = a.empresa and b.num_credito = a.num_credito and b.fecha = a.fecha ' ||
          ' left outer join bdicred:sd_info_edocta c on c.fecha_emision = mdy('||vMes||',20,'||vAnio||') and c.num_credito = a.num_credito ' ||
       -- ' left outer join bdicred@pld_tcp:sd_encabezado2_edocta c on c.fecha_emision = mdy('||vMes||',20,'||vAnio||') and c.num_credito = a.num_credito ' ||
          ' where a.fecha = ''' || UltimoDiaMes || ''' ' ||
          ' and a.empresa = ''' || pEmpresa || ''' ' ||
          ' and a.num_credito > ''600000000000'' ' ||
          ' and b.campo_trab3 <> ''BAJA'';"' ||
          ' > /resplogifx/archivoscartera/QueryPayMenthist.sql';
        
        system cSql;

        let cSql='';
        let cSql = 'dbaccess bdicred /resplogifx/archivoscartera/QueryPayMenthist.sql';
        system cSql;
        let cSql = 'rm /resplogifx/archivoscartera/QueryPayMenthist.sql';
        system cSql;

        
        let NombreArchivoCifras = trim('PaymentHistCifrasControl_' || trim(vdia) || trim(vMes) || trim(vAnio) || '.txt');
        let cSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/archivoscartera/' || trim(NombreArchivoCifras) ||
          ' DELIMITER ' || '''|'''  || 
          ' select ' || trim(vdia) || trim(vMes) || trim(vAnio) || ',count(*)::integer,' ||
          ' sum(a.sdo_cap_insoluto),' ||
          ' sum(a.sdo_capital),' ||
          ' sum(a.mto_venc_trasp),' ||
          ' sum(a.cap_tras_no_venci),' ||
          ' sum(a.monto_vencido + a.mto_venc_trasp + a.cap_tras_no_venci),' ||
          ' sum(a.monto_otorgado),' ||
          ' sum(c.sdo_pagar)' ||
          ' from bdicred:sd_maesdoscont a ' ||
          ' join bdicred:sd_maecredcont b on b.empresa = a.empresa and b.num_credito = a.num_credito and b.fecha = a.fecha ' ||
          ' left outer join bdicred:sd_info_edocta c on c.fecha_emision = mdy('||vMes||',20,'||vAnio||') and c.num_credito = a.num_credito ' ||
          --' left outer join bdicred@pld_tcp:sd_encabezado2_edocta c on c.fecha_emision = mdy('||vMes||',20,'||vAnio||') and c.num_credito = a.num_credito ' ||
          ' where a.fecha = ''' || UltimoDiaMes || ''' ' ||
             ' and a.empresa = ''' || pEmpresa || ''' ' ||
             ' and a.num_credito > ''600000000000'' ' ||
             ' and b.campo_trab3 <> ''BAJA'';"' ||
             ' > /resplogifx/archivoscartera/QueryPayMenthistCifrasControl.sql';
        system cSql;

        let cSql='';
        let cSql = 'dbaccess bdicred /resplogifx/archivoscartera/QueryPayMenthistCifrasControl.sql';
        system cSql;
        let cSql = 'rm /resplogifx/archivoscartera/QueryPayMenthistCifrasControl.sql';
        system cSql;

        let cont=cont + 1;

        update bdicred:sd_param
           set valor = cont
         where empresa = pEmpresa and cod_param = '078';
       
    end if;

    
  if(cont=2) then
     
     set isolation to dirty read;
     
      select limit 1 fecha_corte INTO v_fecha_corte
        from bdicred:basebvr
       where num_credito >= ''; 
      
      IF v_fecha_corte < v_fechacorte_actual THEN
          truncate "informix".basebvr drop storage;
      END IF;  
 		
      let dFechaIni = date((mdy(vMes,20,vAnio) - 1 units month) + 1 units day);

  		 select a.numcte numcte, a.num_credito num_credito, a.fecha_apertura fecha_apertura
  		   from bdicred:sd_maecred a
        where a.empresa = pEmpresa 
          and a.num_credito>=''
          and a.status_cred in ('AA','BA','BT')
          and a.num_credito not in (select num_credito from bdicred:basebvr)
          and a.campo_trab3 <> 'BAJA'
         into temp cartera_basebvr with no log;
  
         
  
      foreach with hold

            select numcte, num_credito, fecha_apertura
              into cNumCte,cNumCredito,dFechaApertura
              from cartera_basebvr
            
let cauxNumCredito  = cNumCredito;

            select limit 1 nvl(b.mto_fin_ven_trasp,0) meses_vencidos,
                   case when b.monto_vencido > 0  then 'TRANSITORIO' 
                        when b.mto_venc_trasp > 0 then 'VENCIDO'
                        else 'VIGENTE' end status_credito,
                    date((b.fecha + 1 units month)) - 4 fecha_limite_pago,
                    b.monto_otorgado Limite_Credito
             into dMesesVencidos, v_status_credito, dFechaLimitePago, dLimiteCredito
             from bdicred:sd_maesdoshist b
            where b.fecha = mdy(vMes,20,vAnio)
              and b.empresa = pEmpresa
              and b.num_credito = cNumCredito;

            if v_status_credito is null and dFechaLimitePago is null and dLimiteCredito is null then continue foreach; end if;

            select limit 1
                    c.sdo_pagar pago_minimo, 
                    nvl(c.sdo_debe,0) + nvl(c.interes_pago_total_tc,0) saldo_corte,
                    c.sdo_disponible, 
                    c.fecha_emision fecha_corte,
                    c.menos_abonos pagos_payments,
                    c.mas_compras compras_purchases,
                    c.mas_disp_efectivo disposiciones_withdrawals, 
                    c.mas_intereses intereses,
                    c.fecha_emision,
/*                    case when to_char(a.fecha_apertura,'%Y%m') = to_char(c.fecha_emision,'%Y%m') 
                         then (month(c.fecha_emision) - month(a.fecha_apertura)) + ((year(c.fecha_emision) - year(a.fecha_apertura)) * 12) + 1
                         else (month(c.fecha_emision) - month(a.fecha_apertura)) + ((year(c.fecha_emision) - year(a.fecha_apertura)) * 12)
                        end MOB,*/
                    --d.tasa_anual::decimal(5,2)  --macf
                    c.tasa_anual 
              into dPagoMinimo, 
                    dSaldoCorte,
                    dSdoDisponible, 
                    dFechaCorte,
                    dPagosPayments,
                    dComprasPurchases,
                    dDisposicionesWithdrawals, 
                    dIntereses,
                    dFechaEmision,
--                    dMOB,
                    dTasa 
             --from bdicred@pld_tcp:sd_encabezado2_edocta c
               from bdicred:sd_info_edocta c
                 --inner join bdicred@pld_tcp:sd_pie_edocta d on d.fecha_emision=c.fecha_emision and d.num_credito=c.num_credito  
            where c.fecha_emision = mdy(vMes,20,vAnio)
              and c.num_credito = cNumCredito;


              if dFechaApertura = dFechaEmision then
                 let dMOB = (month(dFechaEmision) - month(dFechaApertura)) + ((year(dFechaEmision) - year(dFechaApertura)) * 12) + 1;
              else
                 let dMOB = (month(dFechaEmision) - month(dFechaApertura)) + ((year(dFechaEmision) - year(dFechaApertura)) * 12);
              end if
/*
                    case when to_char(a.fecha_apertura,'%Y%m') = to_char(c.fecha_emision,'%Y%m') 
                         then (month(c.fecha_emision) - month(a.fecha_apertura)) + ((year(c.fecha_emision) - year(a.fecha_apertura)) * 12) + 1
                         else (month(c.fecha_emision) - month(a.fecha_apertura)) + ((year(c.fecha_emision) - year(a.fecha_apertura)) * 12)
                        end MOB,*/

			select limit 1 nvl(sdo_debe,0) + nvl(interes_pago_total_tc,0)
              into dSdoCorteAnterior
              --from bdicred@pld_tcp:sd_encabezado2_edocta
              from bdicred:sd_info_edocta
  			 where fecha_emision = (mdy(vMes,20,vAnio) - 1 units month)
			   and num_credito = cNumCredito;


-- TRASPASO INTERES VIGENTE A VENCIDO
            if dIntereses >= 0 then
                select {+INDEX(sd_movhis inx_movhis)} nvl(sum(monto),0) into dIva
                  from bdicred:sd_movhis
                 where empresa = pEmpresa
                   and fecha_mov = mdy(vMes,20,vAnio)
                   and num_credito = cNumCredito
                   and codigo_fun = '605' 
                   and codigo_ref = 3
                   and reversado='N';
             else
                let dIva = 0;
             end if;

        
        select limit 1 nvl(num_atm_ch+num_vtn_ch,0) as numdisposiciones, nvl(num_pagos_ch,0) as num_pagos, nvl(num_pos_ch,0) as num_compras  
          into iNumeroDisposicionesCashATM, iNumeroPagosPayments, iNumeroComprasPurchases 
          from bdicred:sd_indicador_cred
         where empresa = pEmpresa
           and num_credito = cNumCredito;   

-- DISPOSICIONES Y DESEMBOLSOS
/*      select {+INDEX(sd_movhis inx_movhis)} count(*) into iNumeroDisposicionesCashATM
			  from bdicred:sd_movhis
			 where empresa=pEmpresa
		  	   and fecha_mov >= dFechaIni and fecha_mov <= mdy(vMes,20,vAnio)
			   and num_credito = cNumCredito
			   and codigo_fun ='002'
			   and codigo_ref IN (50,30,40,41,42,34,35,36,60,61,62,63,64)
			   and reversado='N';
-- PAGOS
			select {+INDEX(sd_movhis inx_movhis)} count(*) into iNumeroPagosPayments
			  from bdicred:sd_movhis
		 	 where empresa=pEmpresa
			   and fecha_mov >= dFechaIni and fecha_mov <= mdy(vMes,20,vAnio)
			   and num_credito = cNumCredito
			   and codigo_fun in (select cod_fun from bdicred:sd_conceptospagomanual) 
			   and codigo_ref=1
			   and reversado='N';


            select {+INDEX(sd_movhis inx_movhis)} count(*) into iNumeroComprasPurchases
			  from bdicred:sd_movhis
			 where empresa=pEmpresa
			   and fecha_mov >= dFechaIni and fecha_mov <= mdy(vMes,20,vAnio)
			   and num_credito = cNumCredito
			   and codigo_fun ='002'
			   and codigo_ref in (37,57)
			   and reversado='N';
*/

-- COMISIONES DE TARJETA DE CREDITO
			select {+INDEX(sd_movhis inx_movhis)} nvl(sum(monto),0) into dComisiones
			  from bdicred:sd_movhis
			 where empresa=pEmpresa
			   and fecha_mov >= dFechaIni and fecha_mov <= mdy(vMes,20,vAnio)
			   and num_credito = cNumCredito
			   and codigo_fun ='339'
			   and codigo_ref in (50,51,1,3,24,25,26,17,18,19,90,91,92,93,94,95,6,7,8)
			   and reversado='N';

        BEGIN WORK;

              INSERT INTO bdicred:basebvr
                      (numcte,num_credito,fecha_apertura,meses_vencidos,status_credito,pago_minimo,saldo_corte,sdo_disponible,fecha_limite_pago,
                      fecha_corte,sdo_corte_anterior,pagos_PAYMENTS,compras_PURCHASES,disposiciones_WITHDRAWALS,intereses,iva,rendimientos,
                      numero_disposiciones_CASH_ATM,numero_pagos_PAYMENTS,numero_compras_PURCHASES,comisiones,MOB,limite_credito,tasa)
                   values
                      (cNumCte,cNumCredito,dFechaApertura,dMesesVencidos,v_status_credito,dPagoMinimo,dSaldoCorte,dSdoDisponible,dFechaLimitePago,
                      dFechaCorte,dSdoCorteAnterior,dPagosPayments,dComprasPurchases,dDisposicionesWithdrawals,dIntereses,dIva,dRendimientos,
                      iNumeroDisposicionesCashATM,iNumeroPagosPayments,iNumeroComprasPurchases,dComisiones,dMOB,dLimiteCredito,dTasa);
                
        COMMIT WORK;
let cauxNumCredito  = '';
	end foreach;
 
  UPDATE statistics medium FOR TABLE "informix".basebvr;
 
  DROP TABLE cartera_basebvr;
 
    

    let NombreArchivo = trim('BaseBvr_' || trim(vdia) || trim(vMes) || trim(vAnio) || '.txt');
    let cSql = 'echo "UNLOAD TO /resplogifx/archivoscartera/' || trim(NombreArchivo) ||
               ' DELIMITER ' || '''|'''  || ' select * from basebvr;" > /resplogifx/archivoscartera/QueryBaseBvr.sql';
    system cSql;
	
    let cSql='';
    let cSql = 'dbaccess bdicred /resplogifx/archivoscartera/QueryBaseBvr.sql';
    system cSql;
    
	let cSql = 'rm /resplogifx/archivoscartera/QueryBaseBvr.sql';
    system cSql; 

    let cont=cont + 1;

    update bdicred:sd_param
         set valor = cont
         where empresa = pEmpresa and cod_param = '078';         
  
   
  end if;

   --return SCodRet,cMensajeRet;  --- solo para Test MACF

    if(cont=3) then
        let NombreArchivoCifras = trim('BaseBvrCifrasControl_' || trim(vdia) || trim(vMes) || trim(vAnio) || '.txt');
        let cSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/archivoscartera/' || trim(NombreArchivoCifras) ||
       ' DELIMITER ' || '''|'''  || 
       ' select count(*)::integer,sum(pago_minimo),sum(saldo_corte),sum(sdo_disponible),sum(sdo_corte_anterior),' ||
       ' sum(pagos_PAYMENTS),sum(compras_PURCHASES),sum(disposiciones_WITHDRAWALS),sum(intereses),sum(iva),0,' ||
       ' sum(numero_disposiciones_CASH_ATM),sum(numero_pagos_PAYMENTS),sum(numero_compras_PURCHASES),sum(comisiones),sum(limite_credito) ' ||
       ' from basebvr;" > /resplogifx/archivoscartera/QueryBaseBvrCifrasControl.sql';

        system cSql;
        let cSql='';
        let cSql = 'dbaccess bdicred /resplogifx/archivoscartera/QueryBaseBvrCifrasControl.sql';
        system cSql;
        let cSql = 'rm /resplogifx/archivoscartera/QueryBaseBvrCifrasControl.sql';
        system cSql; 

        let cont=cont + 1;

        update bdicred:sd_param
           set valor = cont
         where empresa = pEmpresa and cod_param = '078';
    end if;

    update bdicred:sd_param
       set valor = '1'
     where empresa = pEmpresa and cod_param = '078';


	return SCodRet,cMensajeRet ;
end;
end procedure;