CREATE PROCEDURE "informix".sp_rep_regulatorios_irb(pEmpresa char(03))
returning 
          char(06) as resultado,
          char(80) as mensaje;
		  
--EXECUTE PROCEDURE "informix".sp_rep_regulatorios_irb('001');

--************************ Definicion de variables *****************************
DEFINE cMensajeRet, cMensajeRet2     CHAR(80);

define iCodRet,isam_err    	integer;
define error_info			char(80);
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
define pFechaReporte         date;
define PrimerDiaMes         date;
define UltimoDiaMes         date;
define vDia,v_mes_corte     char(2);
define vMes,v_mes_appdate   char(2);
define vAnio                char(4);

define cNumCliente          char(20);
define cNumCredito          char(20);
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
define vCurrent               char(25);
define vdia2                  date; 
define vHora,vHora_2          char(8);
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
define vfechareporte  date;
define cFechaappdate  char(8);   

-----------------------------------------------------------------------------
DEFINE bandera1 					CHAR(20);
DEFINE bandera2 					CHAR(20);
DEFINE v1_num_solicitud 			CHAR(20);
DEFINE v1_numcte 					CHAR(20);
DEFINE v1_sdo_actual 				DECIMAL(14,2);
DEFINE v1_sdo_vencido 				DECIMAL(14,2);
DEFINE v1_int_vencido 				DECIMAL(14,2);
DEFINE v1_iva_int_vencido 			DECIMAL(14,2);
DEFINE v1_int_mora_ordi 			DECIMAL(14,2);
DEFINE v1_iva_int_mora_ordi 		DECIMAL(14,2);
DEFINE v1_int_mora_cope 			DECIMAL(14,2);
DEFINE v1_iva_int_mora_cope 		DECIMAL(14,2);
DEFINE v1_meses_vencidos 			INTEGER;
DEFINE v1_fecha 					DATE;
DEFINE v1_situacion 				CHAR(06);
-----------------------------------------------------------------------------

let vNumproceso    = '0053';
let v_term         = '';   let v_name_suffix       = '';  let v_character_blanks    = '';   let v_presence_ckn_svn = '';   let v_thoroughfare_type = '';
let v_mes_corte    = '';   let v_age               = '';  let v_time_residence      = '';   let v_number_debt_obli = '';   let v_postal_code       = '';
let v_time_job     = '';   let v_number_dependents = '';  let v_number_people_house = '';   let v_telephone        = '';   let v_nombrezona        = '';  
let v_gender       = '';   let v_application_date  = '';  let v_down_payment        = '';   let v_apartment_number = '';   let v_type_residence    = '';
let v_house_number = '';   let v_monthly_expense   = '';  let v_first_name          = '';   let v_middle_name      = '';   let v_last_name         =  '';                  
let v_city_name    = '';   let v_state             = '';  let v_job_type            = '';   let v_status_credito   = '';   let v_years_credit_exp  = 0;              
let v_postal_code4 = '';   let v_application_id    = '';  let v_compras_PURCHASES   = 0;    let v_intereses        = 0;    let v_saldo_corte       = 0;
let v_numcte       = '';   let v_num_credito       = '';  let v_meses_vencidos      = 0;    let v_pago_minimo      = 0;    let v_iva               = 0;                           
let v_rendimientos = 0;    let v_comisiones        = 0;   let v_MOB                 = 0;    let v_limite_credito   = 0;     
let vCurrent       = '';   let vHora               = '';  let cMensajeRet2          = '';   let cNumCte            = '';   let vHora_2             = '';
let dMesesVencidos = 0;    let v_sdo_disponible    = 0;   let v_monthly_income      = 0;    let dComisiones        = 0; 
let dRendimientos  = 0;    let v_mes_appdate       = '';  let dSdoCorteAnterior     = 0;    
let v_yearly_house_income           = '';   let dDisposicionesWithdrawals = 0;    let v_application_status        = '';  
let v_sdo_corte_anterior            = 0;    let v_pagos_PAYMENTS          = 0;    let v_disposiciones_WITHDRAWALS = 0;
let v_numero_disposiciones_CASH_ATM = 0;    let v_numero_pagos_PAYMENTS   = 0;    let v_numero_compras_PURCHASES  = 0;
let v_requested_amount              = 0;    let iNumeroPagosPayments      = 0;    let iNumeroDisposicionesCashATM = 0;
let v_number_prev_loans_bank        = '';   let iNumeroComprasPurchases   = 0;    let v_thoroughfare_name         = '';                                                                                    
let v_fecha_apertura  = date(1);  let v_fecha_limite_pago = date(1);  let v_fechacorte_actual = date(1);
let v_fecha_finmesant = date(1);  let dFechaEmision       = date(0);  let vdia2               = date(1); 
let v_fecha_emision   = date(1);  let v_fecha_nac         = date(1);  let v_fecha_insert      = date(1);
let v_fecha_corte     = date(1);  let cFechaappdate       = '';
let vFechaappdate     = date(1);
  


--********************** Inicializacion de variables ***************************
let cMensajeRet = 'El proceso de REPORTES IRB se realizó correctamente';
let iCodRet                 = 0;
let isam_err				= 0;
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
let vfechareporte = date(1);
-----------------------------------------------------------------------------
LET bandera1 					= "";
LET bandera2 					= "";
LET v1_num_solicitud 			= "";
LET v1_numcte 					= "";
LET v1_sdo_actual 				= 0;
LET v1_sdo_vencido 				= 0;
LET v1_int_vencido 				= 0;
LET v1_iva_int_vencido 			= 0;
LET v1_int_mora_ordi 			= 0;
LET v1_iva_int_mora_ordi 		= 0;
LET v1_int_mora_cope 			= 0;
LET v1_iva_int_mora_cope 		= 0;
LET v1_meses_vencidos 			= 0;
LET v1_fecha 					= DATE(1);
LET v1_situacion 				= "";
-----------------------------------------------------------------------------


--**************************** Control de errores ******************************
begin
    on exception set iCodRet, isam_err, error_info
	if iCodRet <> 0 then
--            execute procedure sp_obtener_hora() into vhora_fin;
        	let SCodRet = iCodRet;
        	  --   let cMensajeRet ='Error al generar los REPORTES IRB >> '||NombreArchivo;
            let cMensajeRet ='Error REPORTES IRB >> '||trim(NombreArchivo)|| ' - ' || trim(error_info) || ' - ' ||trim(v_num_solicitud)||' - '||trim(v1_num_solicitud);
--  		      let cMensajeRet ='Error>>'||trim(NombreArchivo)|| ' - ' ||trim(v_num_solicitud)||' - '||trim(v1_num_solicitud);
			      
            update bdicred:sd_param
               set valor = cont
             where empresa = pEmpresa and cod_param = '038';
             
              	
			return SCodRet,cMensajeRet ;
        end if;
    end exception;

  -- Set debug file to "/tmp/sp_rep_regulatorios_irb.out";
  -- trace on;

--*******************a******** Programa principal *******************************
    -- obtener la hora que inicio la ejecucion el proceso
    --execute procedure sp_obtener_hora() into vhora_inicio;

    -- obtener la fecha de hoy
    select fecha_hoy,pri_dia_mes into vfecha_hoy,pFechaReporte from bdicred:sd_fechas where empresa = pEmpresa;


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
  select trim(valor) into cont from bdicred:sd_param where cod_param = '038';

    if cont is null or cont = '' then
       let SCodRet = '000010';
       let cMensajeRet = 'No se encuentra el valor del número de reporte a ejecutar para IRB.';
       return SCodRet,cMensajeRet ;
    elif cont < 1 or cont >=6 then
       let SCodRet = '000020';
       let cMensajeRet = 'El valor del número de reporte a ejecutar para IRB no es válido.';
    end if;

--obtener los rangos de fechas para el mes del reporte en cuestion
    let PrimerDiaMes = pFechaReporte - 1 units month;
    let UltimoDiaMes = pFechaReporte - 1 units day;
    
--******Variable para pruebas******	
	--LET PrimerDiaMes = mdy('05','01','2015');
	--LET UltimoDiaMes = mdy('05','31','2015');
--------------------------------------------------
	
-- obtener por separado el dia, mes y año de la fecha en cuestion para el nombre del archivo
    let vDia = lpad(day(UltimoDiaMes),2,'0');
    let vMes = lpad(month(UltimoDiaMes),2,'0');
    let vAnio = lpad(year(UltimoDiaMes),4,'0');

    LET v_fecha_finmesant = pFechaReporte -1 UNITS day;
    LET v_fechacorte_actual = mdy(month(v_fecha_finmesant),20,year(v_fecha_finmesant));
         
	--LET cont = 2;
    
    if(cont = 1) then
    --crea el reporte ss_solicitudes del RQM 07 044 Generacion de informacion para el proyecto IRB
    -- Tarda menos de 1 minuto aprox.

        let NombreArchivo = trim('Solicitudes_' || trim(vdia) || trim(vMes) || trim(vAnio) || '.txt');
        let cSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/archivoscartera/' || trim(NombreArchivo) ||
            ' DELIMITER ' || '''|'''  ||
            ' select' ||
            ' num_solicitud,' ||
            ' numcte,' ||
            ' sucursal,' ||
            ' status_solicitud,' ||
            ' monto_solicitado,' ||
            ' user_insert,' ||
            ' fecha_insert' ||
            ' from bdisolic:ss_solicitudes' ||
            ' where empresa=''001'' and num_solicitud>'''' and fecha_insert >= ''' || PrimerDiaMes || ''' ' ||
            ' and fecha_insert <= ''' || UltimoDiaMes || '''; "' ||
            ' > /resplogifx/archivoscartera/QuerySolicitudes.sql';
        system cSql;

        let cSql='';
        let cSql = 'dbaccess bdisolic /resplogifx/archivoscartera/QuerySolicitudes.sql';
        system cSql;
        let cSql = 'rm /resplogifx/archivoscartera/QuerySolicitudes.sql';
        system cSql;

--ss_solicitudes

        let NombreArchivoCifras = trim('SolicitudesCifrasControl_' || trim(vdia) || trim(vMes) || trim(vAnio) || '.txt');
        let cSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/archivoscartera/' || trim(NombreArchivoCifras) ||
            ' DELIMITER ' || '''|'''  || 
            ' select count(*)::integer' ||
            ' from bdisolic:ss_solicitudes' ||
            ' where empresa=''001'' and num_solicitud>'''' and fecha_insert >= ''' || PrimerDiaMes || ''' ' ||
            ' and fecha_insert <= ''' || UltimoDiaMes || '''; "' ||
            ' > /resplogifx/archivoscartera/QuerySolicitudesCifrasControl.sql';
        system cSql;

        let cSql='';
        let cSql = 'dbaccess bdisolic /resplogifx/archivoscartera/QuerySolicitudesCifrasControl.sql';
        system cSql;
        let cSql = 'rm /resplogifx/archivoscartera/QuerySolicitudesCifrasControl.sql';
        system cSql;

        let cont = cont + 1;

        update bdicred:sd_param
        set valor = cont
        where empresa = pEmpresa and cod_param = '038';
		 
    end if;

    if(cont = 2) then
    -- crea el reporte cartera_vendida de RQM 07 044
    -- Tarda 3 min. aprox.
	
	select max(fechareporte) into vfechareporte 
	from bdicobranza:cb_rep_cart_quebrantar;
	
--******Variable para prueba******	
	--let vfechareporte = mdy('05','27','2015');
---------------------------------------------------

		IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'sd_cartera_temp' ) THEN
		
			TRUNCATE TABLE "informix".sd_cartera_temp drop storage;
		
		ELSE
			CREATE TABLE "informix".sd_cartera_temp(num_solicitud CHAR(20) NOT NULL, numcte CHAR(20), sdo_actual DECIMAL(14,2),
													sdo_vencido DECIMAL(14,2), int_vencido DECIMAL(14,2),
													iva_int_vencido DECIMAL(14,2), int_mora_ordi DECIMAL(14,2),
													iva_int_mora_ordi DECIMAL(14,2), int_mora_cope DECIMAL(14,2), 
													iva_int_mora_cope DECIMAL(14,2), meses_vencidos INTEGER, fecha DATE,
													situacion CHAR(06));
		END IF;
		
		
		SELECT LIMIT 1 a.num_solicitud
		INTO bandera1
		FROM bdisolic:"informix".ss_solicitudes a, 
			bdicred:"informix".sd_maecred c, 
			bdicobranza:"informix".cb_rep_cart_quebrantar e 
		WHERE a.empresa = pEmpresa
		AND a.empresa = c.empresa 
		AND a.num_solicitud = c.num_credito 
		AND a.num_solicitud = e.num_credito 
		AND e.excluido = 'B' 
		AND e.fechareporte = vfechareporte;
		
		SELECT LIMIT 1 a.num_solicitud
		INTO bandera2
		FROM bdisolic:"informix".ss_solicitudes a, 
			bdicred:"informix".sd_maecred c, 
			bdicobranza:"informix".cb_rep_cart_quebrantar e, 
			bdicred:"informix".sd_maecred_vendida f 
		WHERE a.empresa = pEmpresa
		AND a.empresa = c.empresa
		AND a.num_solicitud = c.num_credito
		AND c.status_cred = 'CV'
		AND a.empresa = f.empresa
		AND a.num_solicitud = f.num_credito
		AND a.num_solicitud = e.num_credito
		AND f.fecha >= PrimerDiaMes
		AND f.fecha <= UltimoDiaMes
		AND e.fechareporte = vfechareporte;
		
		IF bandera1 IS NULL THEN
			LET bandera1 = '';
		END IF;
		
		IF bandera2 IS NULL THEN
			LET bandera2 = '';
		END IF;
		
		IF bandera1 <> '' THEN
			FOREACH WITH HOLD
				SELECT a.num_solicitud, a.numcte, sdo_actual, sdo_vencido, int_vencido, iva_int_vencido, int_mora_ordi, iva_int_mora_ordi, 
						int_mora_cope, iva_int_mora_cope, meses_vencidos, e.fecha_baja, 'BAJA' as situacion
				INTO v1_num_solicitud, v1_numcte, v1_sdo_actual, v1_sdo_vencido, v1_int_vencido, v1_iva_int_vencido, 
					v1_int_mora_ordi, v1_iva_int_mora_ordi, v1_int_mora_cope, v1_iva_int_mora_cope, v1_meses_vencidos, v1_fecha, v1_situacion
				FROM bdisolic:"informix".ss_solicitudes a, 
					bdicred:"informix".sd_maecred c, 
					bdicobranza:"informix".cb_rep_cart_quebrantar e 
				WHERE a.empresa = pEmpresa
				AND a.empresa = c.empresa 
				AND a.num_solicitud = c.num_credito 
				AND a.num_solicitud = e.num_credito 
				AND e.excluido = 'B' 
				AND e.fechareporte = vfechareporte
				
				BEGIN;
					INSERT INTO "informix".sd_cartera_temp 
						(num_solicitud, numcte, sdo_actual,	sdo_vencido, int_vencido, iva_int_vencido, int_mora_ordi, iva_int_mora_ordi,
						int_mora_cope, iva_int_mora_cope, meses_vencidos, fecha, situacion)
					VALUES 
						(v1_num_solicitud, v1_numcte, v1_sdo_actual, v1_sdo_vencido, v1_int_vencido, v1_iva_int_vencido, v1_int_mora_ordi,
						v1_iva_int_mora_ordi, v1_int_mora_cope, v1_iva_int_mora_cope, v1_meses_vencidos, v1_fecha, v1_situacion);
				COMMIT;
				
				LET v1_num_solicitud = ""; LET v1_numcte = ""; LET v1_sdo_actual = 0; LET v1_sdo_vencido = 0; LET v1_int_vencido = 0; 
				LET v1_iva_int_vencido = 0; LET v1_int_mora_ordi = 0; LET v1_iva_int_mora_ordi = 0; LET v1_int_mora_cope = 0;
				LET v1_iva_int_mora_cope = 0; LET v1_meses_vencidos = 0; LET v1_fecha = DATE(1); LET v1_situacion = "";
			END FOREACH;
		END IF;
		
		IF bandera2 <> '' THEN
			FOREACH WITH HOLD
				SELECT a.num_solicitud, a.numcte, sdo_actual, sdo_vencido, int_vencido, iva_int_vencido, int_mora_ordi, iva_int_mora_ordi, 
						int_mora_cope, iva_int_mora_cope, meses_vencidos, f.fecha, 'VENTA' as situacion 
				INTO v1_num_solicitud, v1_numcte, v1_sdo_actual, v1_sdo_vencido, v1_int_vencido, v1_iva_int_vencido, 
					v1_int_mora_ordi, v1_iva_int_mora_ordi, v1_int_mora_cope, v1_iva_int_mora_cope, v1_meses_vencidos, v1_fecha, v1_situacion
				FROM bdisolic:"informix".ss_solicitudes a, 
					bdicred:"informix".sd_maecred c, 
					bdicobranza:"informix".cb_rep_cart_quebrantar e, 
					bdicred:"informix".sd_maecred_vendida f 
				WHERE a.empresa = pEmpresa
				AND a.empresa = c.empresa
				AND a.num_solicitud = c.num_credito
				AND c.status_cred = 'CV'
				AND a.empresa = f.empresa
				AND a.num_solicitud = f.num_credito
				AND a.num_solicitud = e.num_credito
				AND f.fecha >= PrimerDiaMes
				AND f.fecha <= UltimoDiaMes
				AND e.fechareporte = vfechareporte
					
				BEGIN;
					INSERT INTO "informix".sd_cartera_temp 
						(num_solicitud, numcte, sdo_actual,	sdo_vencido, int_vencido, iva_int_vencido, int_mora_ordi, iva_int_mora_ordi,
						int_mora_cope, iva_int_mora_cope, meses_vencidos, fecha, situacion)
					VALUES 
						(v1_num_solicitud, v1_numcte, v1_sdo_actual, v1_sdo_vencido, v1_int_vencido, v1_iva_int_vencido, v1_int_mora_ordi,
						v1_iva_int_mora_ordi, v1_int_mora_cope, v1_iva_int_mora_cope, v1_meses_vencidos, v1_fecha, v1_situacion);
				COMMIT;
				
				LET v1_num_solicitud = ""; LET v1_numcte = ""; LET v1_sdo_actual = 0; LET v1_sdo_vencido = 0; LET v1_int_vencido = 0;
				LET v1_iva_int_vencido = 0; LET v1_int_mora_ordi = 0; LET v1_iva_int_mora_ordi = 0; LET v1_int_mora_cope = 0;
				LET v1_iva_int_mora_cope = 0; LET v1_meses_vencidos = 0; LET v1_fecha = DATE(1); LET v1_situacion = "";			
			END FOREACH;
			
			UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_cartera_temp;
		END IF;

        let NombreArchivo = trim('CarteraVendida_' || trim(vdia) || trim(vMes) || trim(vAnio) || '.txt');
        let cSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/archivoscartera/' || trim(NombreArchivo) ||
			' DELIMITER ' || '''|'''  || 
			' select' ||
			' *' ||
		' from "informix".sd_cartera_temp; "' || 
		' > /resplogifx/archivoscartera/QueryCarteraVendida.sql';
        system cSql;


        let cSql='';
        let cSql = 'dbaccess bdicred /resplogifx/archivoscartera/QueryCarteraVendida.sql';
        system cSql;
        let cSql = 'rm /resplogifx/archivoscartera/QueryCarteraVendida.sql';
        system cSql;
	
        let NombreArchivoCifras = trim('CarteraVendidaCifrasControl_' || trim(vdia) || trim(vMes) || trim(vAnio) || '.txt');
        let cSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/archivoscartera/' || trim(NombreArchivoCifras) ||
            ' DELIMITER ' || '''|'''  || 
            ' select count(*)::integer,' ||
            ' sum(sdo_actual),' ||
            ' sum(sdo_vencido),' ||
            ' sum(int_vencido),' ||
            ' sum(iva_int_vencido),' ||
            ' sum(int_mora_ordi),' ||
            ' sum(iva_int_mora_ordi),' ||
            ' sum(int_mora_cope),' ||
            ' sum(iva_int_mora_cope)' ||
        ' from "informix".sd_cartera_temp; "' || 
        ' > /resplogifx/archivoscartera/QueryCarteraVendidaCifrasControl.sql';
        system cSql;

        let cSql='';
        let cSql = 'dbaccess bdicred /resplogifx/archivoscartera/QueryCarteraVendidaCifrasControl.sql';
        system cSql;
        let cSql = 'rm /resplogifx/archivoscartera/QueryCarteraVendidaCifrasControl.sql';
        system cSql;

        let cont=cont + 1;

        update bdicred:sd_param
           set valor = cont
         where empresa = pEmpresa and cod_param = '038';

    end if;

    if(cont=3) then
    -- crea el reporte originations del RQM 07 044 Generacion para el proyecto IRB
    -- Tarda 1:15 aprox. (una hora quince minutos)
    	let NombreArchivo = trim('Originations_' || trim(vdia) || trim(vMes) || trim(vAnio) || '.txt');
  
      select limit 1 application_date into v_application_date
        from bdicred:originations
       where application_id >= '';
	
	    IF v_application_date IS NULL or v_application_date = '' THEN LET v_application_date = '01011900'; END IF; 
	
	    --LET vFechaappdate = substr(to_char(v_application_date),1,2) || '/' || substr(to_char(v_application_date),3,2) || '/' || substr(to_char(v_application_date),5,4);  
	    LET cFechaappdate = substr(to_char(v_application_date),1,2) || '/' || substr(to_char(v_application_date),3,2) || '/' || substr(to_char(v_application_date),5,4);
	    LET vFechaappdate = cFechaappdate; 

      
      IF (month(vFechaappdate) <> month(v_fechacorte_actual)) THEN
	       truncate bdicred:originations drop storage;
	    END IF;
            
 	    SELECT {+INDEX(bdisolic:ss_solicitudes idx_fecins_numsol)} a.num_solicitud ApplicationId,
 	           a.numcte numcte,
          	 substr(a.fecha_insert, 1, 2)||substr(a.fecha_insert, 4, 2)||substr(a.fecha_insert, 7, 4) ApplicationDate, 
          	 (case when a.status_solicitud = 'AN' then 'C' 
          	       when a.status_solicitud = 'AP' then 'A'   
          	       when a.status_solicitud = 'AT' then 'A'   
          	       when a.status_solicitud = 'BC' then 'P'   
          	       when a.status_solicitud = 'CC' then 'P'   
          	       when a.status_solicitud = 'CE' then 'P'   
          	       when a.status_solicitud = 'EE' then 'P'   
          	       when a.status_solicitud = 'OA' then 'P'   
          	       when a.status_solicitud = 'OS' then 'P'   
          	       when a.status_solicitud = 'PC' then 'P'   
          	       when a.status_solicitud = 'RT' then 'R'   
          	       when a.status_solicitud = 'CV' then 'R'   
          	       when a.status_solicitud = 'CR' then 'R'   
          	 end) Application_Status,    
          	 a.monto_solicitado  Requested_Amount, 
             a.fecha_insert  fecha_insert    
 	      FROM bdisolic:ss_solicitudes a
 	       WHERE a.fecha_insert BETWEEN PrimerDiaMes AND UltimoDiaMes
 	         AND a.num_solicitud not in (select application_id from bdicred:originations)
        INTO temp base_solicitudes WITH no log;
        
             
        --CREATE INDEX idx_base_solicitudes ON base_solicitudes(ApplicationId);
        --UPDATE STATISTICS MEDIUM FOR TABLE base_solicitudes;
 	   
 	    LET v_term = ' '; 
      LET v_down_payment = '9999999999'; 
      LET v_presence_ckn_svn = '0';
      LET v_time_residence = '998';
      LET v_time_job = '998';
      LET v_monthly_expense = '999999999999';
      LET v_number_dependents = '999';
      LET v_number_people_house = '999'; 
      LET v_yearly_house_income = '9999999999';
      LET v_number_prev_loans_bank = '99';
      LET v_name_suffix = ' ';
      LET v_character_blanks = ' ';
      LET v_thoroughfare_type = ' ';
        
     	FOREACH WITH HOLD
          SELECT ApplicationId, numcte, ApplicationDate, Application_Status, Requested_Amount, fecha_insert
            INTO v_num_solicitud, v_numcte, v_application_date, v_application_status, v_requested_amount, v_fecha_insert 
            FROM base_solicitudes
         
   	      SELECT b.apell_paterno, b.nombre1, b.nombre2, c.sexo, f.descripcion, c.fecha_nac
   	        INTO v_last_name, v_first_name, v_middle_name, v_gender, v_job_type, v_fecha_nac 
   	        FROM bdinteg:si_cliente b join bdinteg:si_ctepf c on b.numcte = c.numcte  
            	                   left outer join bdinteg:si_profesion f on f.profesion = c.profesion
           WHERE b.numcte = v_numcte;   
  	      
 	      
          SELECT LIMIT 1 d.cod_postal, d.cod_postal, d.numeroextcalle, e.nombrezona, e.nombrezona, d.departamento, e.poblacionzona, h.nombre
            INTO v_postal_code, v_postal_code4, v_house_number, v_nombrezona, v_thoroughfare_name, v_apartment_number, v_city_name, v_state 
   	       FROM bdinteg:si_direcciones_actual d  
            	                join bdinteg:si_catzonas e on e.numerociudad = d.numerociudad and e.numerocolonia = d.numerocolonia
            	                join bdinteg:si_ciudades i on i.ciudad_coppel = d.numerociudad join bdinteg:si_estados h on h.estado = i.estado 
   	       WHERE d.numcte = v_numcte
             AND d.tipo_dir = '1';
          
   	      
   	      SELECT LIMIT 1 tel.telefono INTO v_telephone
   	        FROM bdinteg:si_telefonos_actual tel 
           WHERE tel.numcte = v_numcte  
             AND tel.tipo_tel = 1 
             AND tel.cofetel ='V'
             AND tel.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
            											 where numcte = tel.numcte  and tipo_tel = 1 and cofetel ='V');
                                        
   	      
   	      SELECT year(today) - year(fecha_apertura) --years_credit_exp
            INTO v_years_credit_exp  
            FROM bdicred:sd_maecred  
           WHERE empresa = pEmpresa  
           	 AND num_credito = v_num_solicitud;  
   	      
   	     SELECT
          	   case when k.elemento = '5' then 'O'   
          		      when k.elemento = '6' then 'X'   
          		      when k.elemento = '7' then 'X'   
          		      when k.elemento = '8' then 'R'   
          		      when k.elemento = '9' then 'X'   
          	   end type_residence
          INTO v_type_residence  
          from bdisolic:ss_detalle_scoring  j   
        	      join bdisolic:ss_scoring_element k on k.empresa = j.empresa and k.grupo = j.grupo and k.seccion = j.seccion and k.elemento = j.elemento 
                       and k.activa = '1'   
         where j.empresa= pEmpresa  
           and j.seccion = '2'  
           and j.grupo = '5'  
           and j.tpo_persona = '01'  
           and j.num_solicitud = v_num_solicitud; 
   	      
   	    
         --SELECT g.ingreso_mensual Monthly_Income,    
         SELECT g.ingreso_mensual,
          	  (case when g.evalua_cc = '0' then '0'  
          		      when g.evalua_cc = '1' then '1'  
          		      when g.evalua_cc = '2' then '1'  
          		      when g.evalua_cc = '3' then '1'  
          		      when g.evalua_cc = 'X' then '999'  
          		end) Number_Debt_Obli 
   	      INTO v_monthly_income, v_number_debt_obli
          FROM bdisolic:ss_resum_scor_fin g 
         WHERE g.empresa = pEmpresa   
           AND g.num_solicitud = v_num_solicitud;
           
          LET v_age = trunc((round((year(v_fecha_insert) - year(v_fecha_nac)),2)),0); 
   
   	      
     	       BEGIN WORK;
    	           INSERT INTO bdicred:originations(application_id, application_date, application_status, requested_amount, term, down_payment, 
                 postal_code, postal_code4, last_name, first_name, middle_name, name_suffix, character_blanks, house_number, nombrezona, thoroughfare_name,
                 thoroughfare_type, apartment_number, city_name, state, gender, age, job_type, type_residence, telephone, presence_ckn_svn, time_residence,
                 time_job, monthly_income, monthly_expense, number_dependents, number_people_house, yearly_house_income, number_debt_obli, years_credit_exp, 
                 number_prev_loans_bank)
                 VALUES(v_num_solicitud, v_application_date, v_application_status, v_requested_amount, v_term, v_down_payment, v_postal_code, 
                   v_postal_code4, v_last_name, v_first_name, v_middle_name, v_name_suffix, v_character_blanks, v_house_number, v_nombrezona, v_thoroughfare_name,
                   v_thoroughfare_type, v_apartment_number, v_city_name, v_state, v_gender, v_age, v_job_type, v_type_residence, v_telephone, v_presence_ckn_svn,
                   v_time_residence, v_time_job, v_monthly_income, v_monthly_expense, v_number_dependents, v_number_people_house, v_yearly_house_income,
                   v_number_debt_obli, v_years_credit_exp, v_number_prev_loans_bank);
             COMMIT WORK;
             
       END FOREACH;
	     
	     UPDATE statistics medium FOR TABLE "informix".originations;
	     
	     DROP TABLE base_solicitudes;
	     
	     let cSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/archivoscartera/' || trim(NombreArchivo) ||
                ' DELIMITER ' || '''|'''  || ' select * from originations;" > /resplogifx/archivoscartera/QueryOriginations.sql'; 
        system cSql;

        let cSql='';
        let cSql = 'dbaccess bdicred /resplogifx/archivoscartera/QueryOriginations.sql';
        system cSql;
        let cSql = 'rm /resplogifx/archivoscartera/QueryOriginations.sql';
        system cSql;

        let cont = cont + 1;

        update bdicred:sd_param
           set valor = cont
         where empresa = pEmpresa and cod_param = '038';

        
    end if;

    if(cont=4) then
    	let NombreArchivoCifras = trim('OriginationsCifrasControl_' || trim(vdia) || trim(vMes) || trim(vAnio) || '.txt');
        let cSql = 'echo "UNLOAD TO /resplogifx/archivoscartera/' || trim(NombreArchivoCifras) ||
            ' DELIMITER ' || '''|'''  || ' select count(*)::integer from originations;" > /resplogifx/archivoscartera/QueryOriginationsCifrasControl.sql';
        system cSql;

        let cSql='';
        let cSql = 'dbaccess bdicred /resplogifx/archivoscartera/QueryOriginationsCifrasControl.sql';
        system cSql;
        let cSql = 'rm /resplogifx/archivoscartera/QueryOriginationsCifrasControl.sql';
        system cSql;

        let cont = cont + 1;

        update bdicred:sd_param
           set valor = cont
         where empresa = pEmpresa and cod_param = '038';
    end if;

--IPCB 03092013/ inicializa valor para proxima ejecución del reporte completo
    update bdicred:sd_param
       set valor = '1'
     where empresa = pEmpresa and cod_param = '038';

	return SCodRet,cMensajeRet ;
end;
end procedure;