create procedure "informix".sp_rep_regulatorios_irb_repr(pEmpresa char(03))
returning 
          char(06) as resultado,
          char(150) as mensaje;

--************************ Definicion de variables *****************************
DEFINE cMensajeRet           CHAR(150);

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
define vDia                 char(2);
define vMes                 char(2);
define vAnio                char(4);

--define cNumCliente          char(20);
--define cNumCredito          char(20);
--define dFechaApertura       date;
--define sMesesVencidos       smallint;
--define cStatusCredito       char(02);
--define dPagoMinimo          dec(18,2);
--define dSaldoCorte          dec(18,2);
--define dSdoDisponible       dec(18,2);
--define dFechaLimitePago     date;
--define dFechaCorte          date;
--define dPagosPAYMENTS       dec(18,2);
--define dComprasPURCHASES    dec(18,2);
--define dDispWITHDRAWALS     dec(18,2);
--define dIntereses           dec(18,2);
--define dMOB                 dec(18,2);
--define dLimiteCredito       dec(18,2);
define dTasa                dec(5,2);
define dFecha               date;
--define dSdoCorteAnt         dec(18,2);
--define dIva                 dec(18,2);
--define iNumDispCASHATM      dec(18,2);
--define iNumPagosPAYMENTS    dec(18,2);
--define iNumCompPURCHASES    dec(18,2);
--define iImpComisiones       dec(18,2);
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

define cNumCte          char(20); 
define cNumCredito      char(20);
define dFechaApertura   date;
define dMesesVencidos   decimal(18,2);
define cStatusCredito   char(15);
define dPagoMinimo      decimal(18,2);
define dSaldoCorte      decimal(18,2);
define dSdoDisponible   decimal(18,2);
define dFechaLimitePago date;
define dFechaCorte      date;
define dFechaEmision      date;
define dSdoCorteAnterior decimal(18,2);
define dPagosPayments   decimal(18,2);
define dComprasPurchases decimal(18,2);
define dDisposicionesWithdrawals decimal(18,2);
define dIntereses       decimal(18,2);
define dIva             decimal(18,2);
define dRendimientos    decimal(18,2);
define iNumeroDisposicionesCashATM integer;
define iNumeroPagosPayments integer;
define iNumeroComprasPurchases integer;
define dComisiones      decimal(18,2);
define dMOB             decimal(18,2);
define dLimiteCredito   decimal(18,2);
define v_requested_amount      decimal(18,2);
define v_application_date     char(08);
define vFechaappdate, v_fechacorte_actual          date;
define v_name_suffix          char(1);
define v_character_blanks     char(1);
define v_thoroughfare_type    char(1);
define v_num_solicitud, v_numcte        char(20);
define v_application_status   char(2);
define v_fecha_insert, v_fecha_nac      date;
define v_last_name, v_first_name, v_middle_name, v_job_type     char(50);
define v_nombrezona, v_thoroughfare_name, v_city_name, v_state  char(50);
define v_gender                                                 char(06);
define v_postal_code, v_postal_code4                            char(5);
define v_house_number, v_apartment_number                       char(10);  
define v_years_credit_exp                                       smallint;
define v_fecha_finmesant                                        date;
--********************** Inicializacion de variables ***************************
let cMensajeRet = 'El proceso de REPORTES IRB se realizó correctamente';
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

--let cNumCliente          = '';
let cNumCredito          = '';
let dFechaApertura       = date(0);
--let sMesesVencidos       = 0;
let cStatusCredito       = '';
let dPagoMinimo          = 0;
let dSaldoCorte          = 0;
let dSdoDisponible       = 0;
let dFechaLimitePago     = date(0);
let dFechaCorte          = date(0);
let dPagosPAYMENTS       = 0;
let dComprasPURCHASES    = 0;
--let dDispWITHDRAWALS     = 0;
let dIntereses           = 0;
let dMOB                 = 0;
let dLimiteCredito       = 0;
let dTasa                = 0;
let dFecha               = date(0);
--let dSdoCorteAnt         = 0;
let dIva                 = 0;
--let iNumDispCASHATM      = 0;
--let iNumPagosPAYMENTS    = 0;
--let iNumCompPURCHASES    = 0;
--let iImpComisiones       = 0;
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

let cNumCte          = '';
let cNumCredito      = '';
let dFechaApertura   = date(0);
let dMesesVencidos   = 0;
let cStatusCredito   = '';
let dPagoMinimo      = 0;
let dSaldoCorte      = 0;
let dSdoDisponible   = 0;
let dFechaLimitePago = date(0);
let dFechaCorte      = date(0);
let dFechaEmision      = date(0);
let dSdoCorteAnterior = 0;
let dPagosPayments    = 0;
let dComprasPurchases = 0;
let dDisposicionesWithdrawals = 0;
let dIntereses       = 0;
let dIva             = 0;
let dRendimientos    = 0;
let iNumeroDisposicionesCashATM = 0;
let iNumeroPagosPayments = 0;
let iNumeroComprasPurchases = 0;
let dComisiones      = 0;
let dMOB             = 0;
let dLimiteCredito   = 0;
let v_application_date  = '';
let vFechaappdate     = date(1);
let v_fechacorte_actual = date(1);
let v_name_suffix  = '';
let v_character_blanks = '';
let v_thoroughfare_type = ''; 
let v_num_solicitud = '';
let v_numcte = '';
let v_application_status = '';
let v_requested_amount = 0;
let v_fecha_insert = date(1);
let v_last_name = ''; 
let v_first_name = '';
let v_middle_name = '';
let v_gender = '';
let v_job_type = '';
let v_fecha_nac = date(1);
let v_postal_code = '';
let v_postal_code4 = '';
let v_house_number = '';
let v_nombrezona = ''; 
let v_thoroughfare_name = '';
let v_city_name = '';
let v_state = '';
let v_apartment_number = '';
let v_years_credit_exp = 0;
let v_fecha_finmesant = date(1);

--**************************** Control de errores ******************************
begin
    on exception set iCodRet
	if iCodRet <> 0 then
--            execute procedure sp_obtener_hora() into vhora_fin;
        	let SCodRet = iCodRet;
            let cMensajeRet ='Error al generar los REPORTES IRB >> '||NombreArchivo||' --> '||cNumCredito;
			
            --update bdicred:sd_param
            --   set valor = cont
            -- where empresa = pEmpresa and cod_param = '038';
					     	
			return SCodRet,cMensajeRet ;
        end if;
    end exception;

--Set debug file to "sp_rep_regulatorios_irb.out";
--trace on;

--*******************a******** Programa principal *******************************
    -- obtener la hora que inicio la ejecucion el proceso
    --execute procedure sp_obtener_hora() into vhora_inicio;

    -- obtener la fecha de hoy
    select fecha_hoy,pri_dia_mes into vfecha_hoy,FechaReporte from bdicred:sd_fechas where empresa = pEmpresa;

-- temporal solo para pruebas
--let vfecha_hoy = mdy('06','07','2013');
--let FechaReporte = mdy('06','01','2013');
-- temporal solo para pruebas

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
  /*
  select trim(valor) into cont from bdicred:sd_param where cod_param = '038';

    if cont is null or cont = '' then
       let SCodRet = '000010';
       let cMensajeRet = 'No se encuentra el valor del número de reporte a ejecutar para IRB.';
       return SCodRet,cMensajeRet ;
    --elif cont < 1 or cont >6 then
    --   let SCodRet = '000020';
    --   let cMensajeRet = 'El valor del número de reporte a ejecutar para IRB no es válido.';
    end if;
  */
  
--obtener los rangos de fechas para el mes del reporte en cuestion
    let PrimerDiaMes = FechaReporte - 1 units month;
    let UltimoDiaMes = FechaReporte - 1 units day;
   
   
-- obtener por separado el dia, mes y año de la fecha en cuestion para el nombre del archivo
    let vDia = lpad(day(UltimoDiaMes),2,'0');
    let vMes = lpad(month(UltimoDiaMes),2,'0');
    let vAnio = lpad(year(UltimoDiaMes),4,'0');

    LET v_fecha_finmesant = FechaReporte -1 UNITS day;
    LET v_fechacorte_actual = mdy(month(v_fecha_finmesant),20,year(v_fecha_finmesant));


/*
    if(cont = 1) then
    --crea el reporte ss_solicitudes del RQM 07 044 Generacion de informacion para el proyecto IRB
    -- Tarda menos de 1 minuto aprox.

        let NombreArchivo = trim('Solicitudes_' || trim(vdia) || trim(vMes) || trim(vAnio) || '.txt');
        let cSql = 'echo "UNLOAD TO /resplogifx/archivoscartera/' || trim(NombreArchivo) ||
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
        let cSql = 'echo "UNLOAD TO /resplogifx/archivoscartera/' || trim(NombreArchivoCifras) ||
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
        let NombreArchivo = trim('CarteraVendida_' || trim(vdia) || trim(vMes) || trim(vAnio) || '.txt');
        let cSql = 'echo "UNLOAD TO /resplogifx/archivoscartera/' || trim(NombreArchivo) ||
            ' DELIMITER ' || '''|'''  || ' select' ||
            ' a.num_solicitud,' ||
            ' a.numcte,' ||
            ' sdo_actual,' ||
            ' sdo_vencido,' ||
            ' int_vencido,' ||
            ' iva_int_vencido,' ||
            ' int_mora_ordi,' ||
            ' iva_int_mora_ordi,' ||
            ' int_mora_cope,' ||
            ' iva_int_mora_cope,' ||
            ' meses_vencidos,' ||
            ' fecha' ||
        ' from bdisolic:ss_solicitudes a,' ||
            ' bdicred:sd_maecred c,' ||
            ' bdicred:sd_maecred_vendida d,' ||
            ' bdicobranza:cb_rep_cart_quebrantar e' ||
        ' where a.empresa=''' || pEmpresa || ''' ' ||
        ' and a.empresa=c.empresa' ||
        ' and a.num_solicitud=c.num_credito' ||
        ' and c.status_cred = ''CV''' ||
        ' and a.empresa = d.empresa' ||
        ' and a.num_solicitud=d.num_credito' ||
        ' and a.num_solicitud = e.num_credito' ||
        ' and d.fecha >= ''' || PrimerDiaMes || ''' ' ||
        ' and d.fecha <= ''' || UltimoDiaMes || ''' ' ||
        ' and e.fechareporte=(select max(fechareporte)' ||
        ' from bdicobranza:cb_rep_cart_quebrantar' ||
        ' where a.num_solicitud=num_credito);"' ||
        ' > /resplogifx/archivoscartera/QueryCarteraVendida.sql';
        system cSql;

        let cSql='';
        let cSql = 'dbaccess bdicred /resplogifx/archivoscartera/QueryCarteraVendida.sql';
        system cSql;
        let cSql = 'rm /resplogifx/archivoscartera/QueryCarteraVendida.sql';
        system cSql;

        let NombreArchivoCifras = trim('CarteraVendidaCifrasControl_' || trim(vdia) || trim(vMes) || trim(vAnio) || '.txt');
        let cSql = 'echo "UNLOAD TO /resplogifx/archivoscartera/' || trim(NombreArchivoCifras) ||
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
        ' from bdisolic:ss_solicitudes a,' ||
            ' bdicred:sd_maecred c,' ||
            ' bdicred:sd_maecred_vendida d,' ||
            ' bdicobranza:cb_rep_cart_quebrantar e' ||
        ' where a.empresa=''' || pEmpresa || ''' ' ||
        ' and a.empresa=c.empresa' ||
        ' and a.num_solicitud=c.num_credito' ||
        ' and c.status_cred = ''CV''' ||
        ' and a.empresa = d.empresa' ||
        ' and a.num_solicitud=d.num_credito' ||
        ' and a.num_solicitud = e.num_credito' ||
        ' and d.fecha >= ''' || PrimerDiaMes || ''' ' ||
        ' and d.fecha <= ''' || UltimoDiaMes || ''' ' ||
        ' and e.fechareporte=(select max(fechareporte)' ||
        ' from bdicobranza:cb_rep_cart_quebrantar' ||
        ' where a.num_solicitud=num_credito);"' ||
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
-- crea el reporte payment_hist del RQM 07 044
-- Tarda 9 min aprox.

*/
        let NombreArchivo = trim('PaymentHist_' || trim(vdia) || trim(vMes) || trim(vAnio) || '.txt');
        let cSql = 'echo "set isolation to dirty read; UNLOAD TO /resplogifx/archivoscartera/' || trim(NombreArchivo) ||
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
          ' and a.num_credito > ''600000000000'';"' ||
          ' > /resplogifx/archivoscartera/QueryPayMenthist.sql';
        system cSql;

        let cSql='';
        let cSql = 'dbaccess bdicred /resplogifx/archivoscartera/QueryPayMenthist.sql';
        system cSql;
        let cSql = 'rm /resplogifx/archivoscartera/QueryPayMenthist.sql';
        system cSql;

        let NombreArchivoCifras = trim('PaymentHistCifrasControl_' || trim(vdia) || trim(vMes) || trim(vAnio) || '.txt');
        let cSql = 'echo "set isolation to dirty read; UNLOAD TO /resplogifx/archivoscartera/' || trim(NombreArchivoCifras) ||
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
          ' left outer join bdicred@pld_tcp:sd_encabezado2_edocta c on c.fecha_emision = mdy('||vMes||',20,'||vAnio||') and c.num_credito = a.num_credito ' ||
          ' where a.fecha = ''' || UltimoDiaMes || ''' ' ||
             ' and a.empresa = ''' || pEmpresa || ''' ' ||
             ' and a.num_credito > ''600000000000'';"' ||
             ' > /resplogifx/archivoscartera/QueryPayMenthistCifrasControl.sql';
        system cSql;

        let cSql='';
        let cSql = 'dbaccess bdicred /resplogifx/archivoscartera/QueryPayMenthistCifrasControl.sql';
        system cSql;
        let cSql = 'rm /resplogifx/archivoscartera/QueryPayMenthistCifrasControl.sql';
        system cSql;

        --let cont=cont + 1;

        --update bdicred:sd_param
        --   set valor = cont
        -- where empresa = pEmpresa and cod_param = '038';

    --end if;

/*
    --if(cont=4) then

    	let NombreArchivo = trim('Originations_' || trim(vdia) || trim(vMes) || trim(vAnio) || '.txt');
  
      select limit 1 application_date into v_application_date
        from bdicred:originations
       where application_id >= '';
	
	    LET vFechaappdate = substr(to_char(v_application_date),1,2) || '/' || substr(to_char(v_application_date),3,2) || '/' || substr(to_char(v_application_date),5,4);  
	    
	    IF (vFechaappdate < v_fechacorte_actual) THEN
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
 	   
 	    LET cTerm = ' '; 
      LET cDownPayment = '9999999999'; 
      LET cPresenceCknSvn = '0'; 
      LET cTimeResidence = '998';
      LET cTimeJob = '998';
      LET dMonthlyExpense = '999999999999';
      LET cNumberDependents = '999';
      LET cNumberPeopleHouse = '999'; 
      LET cYearlyHouseIncome = '9999999999';
      LET cNumberPrevLoansBank = '99';
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
          
   	      
   	      SELECT LIMIT 1 tel.telefono INTO cTelephone
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
          INTO cTypeResidence  
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
   	      INTO dMonthlyIncome, cNumberDebtObli
          FROM bdisolic:ss_resum_scor_fin g 
         WHERE g.empresa = pEmpresa   
           AND g.num_solicitud = v_num_solicitud;
           
          LET cAge = trunc((round((year(v_fecha_insert) - year(v_fecha_nac)),2)),0); 
   
   	      
     	       BEGIN WORK;
    	           INSERT INTO bdicred:originations(application_id, application_date, application_status, requested_amount, term, down_payment, 
                 postal_code, postal_code4, last_name, first_name, middle_name, name_suffix, character_blanks, house_number, nombrezona, thoroughfare_name,
                 thoroughfare_type, apartment_number, city_name, state, gender, age, job_type, type_residence, telephone, presence_ckn_svn, time_residence,
                 time_job, monthly_income, monthly_expense, number_dependents, number_people_house, yearly_house_income, number_debt_obli, years_credit_exp, 
                 number_prev_loans_bank)
                 VALUES(v_num_solicitud, v_application_date, v_application_status, v_requested_amount, cTerm, cDownPayment, v_postal_code, 
                   v_postal_code4, v_last_name, v_first_name, v_middle_name, v_name_suffix, v_character_blanks, v_house_number, v_nombrezona, v_thoroughfare_name,
                   v_thoroughfare_type, v_apartment_number, v_city_name, v_state, v_gender, cAge, v_job_type, cTypeResidence, cTelephone, cPresenceCknSvn,
                   cTimeResidence, cTimeJob, dMonthlyIncome, dMonthlyExpense, cNumberDependents, cNumberPeopleHouse, cYearlyHouseIncome,
                   cNumberDebtObli, v_years_credit_exp, cNumberPrevLoansBank);
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

        
--    end if;



  --  if(cont=5) then
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
  --  end if;


    if(cont=6) then
    -- base BVR Tarda 4:30 aprox. (Cuatro horas treinta minutos)

        UPDATE statistics medium FOR TABLE "informix".basebvr;
		
        let dFechaIni = date((mdy(vMes,20,vAnio) - 1 units month) + 1 units day);

		select
            a.numcte numcte, a.num_credito num_credito, a.fecha_apertura fecha_apertura
		from bdicred:sd_maecred a
        where a.empresa = pEmpresa 
          and a.num_credito>=''
          and a.status_cred in ('AA','BA','BT')
--and sucursal in ('0002','0003','0009','0015')
and a.num_credito not in (select num_credito from basebvr)
        into temp cartera_basebvr with no log;

        foreach with hold

            select numcte, num_credito, fecha_apertura
              into cNumCte,cNumCredito,dFechaApertura
            from cartera_basebvr
            
            select nvl(b.mto_fin_ven_trasp,0) meses_vencidos,
                   case when b.monto_vencido > 0 then 'TRANSITORIO' 
                        when b.mto_venc_trasp > 0 then 'VENCIDO'
                        else 'VIGENTE' end status_credito,
                    date((b.fecha + 1 units month)) - 4 fecha_limite_pago,
                    b.monto_otorgado Limite_Credito
             into dMesesVencidos,cStatusCredito,dFechaLimitePago,dLimiteCredito
             from bdicred:sd_maesdoshist b
            where b.fecha = mdy(vMes,20,vAnio)
              and b.empresa = pEmpresa
              and b.num_credito = cNumCredito;

            if dMesesVencidos is null and cStatusCredito is null and dFechaLimitePago is null and dLimiteCredito is null then continue foreach; end if;

            select
--                    c.pago_minimo, 
                    c.sdo_pagar pago_minimo, 
                    nvl(c.sdo_debe,0) + nvl(c.interes_pago_total_tc,0) saldo_corte,
--                    c.saldo_corte,
--                    c.sdo_disponible sdo_disponible, 
                    c.sdo_disponible, 
--                    c.fecha_corte,
                    c.fecha_emision fecha_corte,
--                    c.pagos_payments,
                    c.menos_abonos pagos_payments,
--                    c.compras_purchases,
                    c.mas_compras compras_purchases,
                    c.mas_disp_efectivo disposiciones_withdrawals, 
--                    c.disposiciones_withdrawals, 
                    c.mas_intereses intereses,
--                    c.intereses,
                    c.fecha_emision,
--                    case when to_char(a.fecha_apertura,'%Y%m') = to_char(c.fecha_emision,'%Y%m') 
--                       then (month(c.fecha_emision) - month(a.fecha_apertura)) + ((year(c.fecha_emision) - year(a.fecha_apertura)) * 12) + 1
--                       else (month(c.fecha_emision) - month(a.fecha_apertura)) + ((year(c.fecha_emision) - year(a.fecha_apertura)) * 12)
--                      end MOB,
                    d.tasa_anual::decimal(5,2) 
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
            from bdicred@pld_tcp:sd_encabezado2_edocta c
            inner join bdicred@pld_tcp:sd_pie_edocta d on d.fecha_emision=c.fecha_emision and d.num_credito=c.num_credito
--            from bdicred:sd_encabezado2_edocta c
--from encabezado2_edocta c
--            inner join bdicred:sd_pie_edocta d on d.fecha_emision=c.fecha_emision and d.num_credito=c.num_credito
            where c.fecha_emision = mdy(vMes,20,vAnio)
              and c.num_credito = cNumCredito;
--              where c.num_credito = cNumCredito;


              if dFechaApertura = dFechaEmision then
                 let dMOB = (month(dFechaEmision) - month(dFechaApertura)) + ((year(dFechaEmision) - year(dFechaApertura)) * 12) + 1;
              else
                 let dMOB = (month(dFechaEmision) - month(dFechaApertura)) + ((year(dFechaEmision) - year(dFechaApertura)) * 12);
              end if

--                    case when to_char(a.fecha_apertura,'%Y%m') = to_char(c.fecha_emision,'%Y%m') 
--                         then (month(c.fecha_emision) - month(a.fecha_apertura)) + ((year(c.fecha_emision) - year(a.fecha_apertura)) * 12) + 1
--                         else (month(c.fecha_emision) - month(a.fecha_apertura)) + ((year(c.fecha_emision) - year(a.fecha_apertura)) * 12)
--                        end MOB,

			select nvl(sdo_debe,0) + nvl(interes_pago_total_tc,0)
--			select saldo_corte_ant
              into dSdoCorteAnterior
              from bdicred@pld_tcp:sd_encabezado2_edocta
--              from bdicred:sd_encabezado2_edocta
--from encabezado2_edocta_ant
  			 where fecha_emision = (mdy(vMes,20,vAnio) - 1 units month)
			   and num_credito = cNumCredito;
--              where num_credito = cNumCredito;

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

-- DISPOSICIONES Y DESEMBOLSOS
            select {+INDEX(sd_movhis inx_movhis)} count(*) into iNumeroDisposicionesCashATM
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


-- COMISIONES DE TARJETA DE CREDITO
			select {+INDEX(sd_movhis inx_movhis)} nvl(sum(monto),0) into dComisiones
			  from bdicred:sd_movhis
			 where empresa=pEmpresa
			   and fecha_mov >= dFechaIni and fecha_mov <= mdy(vMes,20,vAnio)
			   and num_credito = cNumCredito
			   and codigo_fun ='339'
			   and codigo_ref in (50,51,1,3,24,25,26,17,18,19,90,91,92,93,94,95,6,7,8)
			   and reversado='N';

        begin work;

        insert into basebvr
                (numcte,num_credito,fecha_apertura,meses_vencidos,status_credito,pago_minimo,saldo_corte,sdo_disponible,fecha_limite_pago,
                fecha_corte,sdo_corte_anterior,pagos_PAYMENTS,compras_PURCHASES,disposiciones_WITHDRAWALS,intereses,iva,rendimientos,
                numero_disposiciones_CASH_ATM,numero_pagos_PAYMENTS,numero_compras_PURCHASES,comisiones,MOB,limite_credito,tasa)
             values
                (cNumCte,cNumCredito,dFechaApertura,dMesesVencidos,cStatusCredito,dPagoMinimo,dSaldoCorte,dSdoDisponible,dFechaLimitePago,
                dFechaCorte,dSdoCorteAnterior,dPagosPayments,dComprasPurchases,dDisposicionesWithdrawals,dIntereses,dIva,dRendimientos,
                iNumeroDisposicionesCashATM,iNumeroPagosPayments,iNumeroComprasPurchases,dComisiones,dMOB,dLimiteCredito,dTasa); 
          commit work;
	end foreach;

    CREATE INDEX idx_credito_basebvr ON basebvr(num_credito) online;

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
         where empresa = pEmpresa and cod_param = '038';

    end if;

    if(cont=7) then
        let NombreArchivoCifras = trim('BaseBvrCifrasControl_' || trim(vdia) || trim(vMes) || trim(vAnio) || '.txt');
        let cSql = 'echo "UNLOAD TO /resplogifx/archivoscartera/' || trim(NombreArchivoCifras) ||
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
         where empresa = pEmpresa and cod_param = '038';
    end if;

    update bdicred:sd_param
       set valor = '1'
     where empresa = pEmpresa and cod_param = '038';
*/

	return SCodRet,cMensajeRet ;
end;
end procedure;