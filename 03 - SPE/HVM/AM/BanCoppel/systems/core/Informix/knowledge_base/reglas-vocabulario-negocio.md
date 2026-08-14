# Vocabulario de Negocio — BanCoppel Informix
> Generado: 2026-08-14 · Fuente: digital-brain/brain.db

## Propósito
Términos de negocio más frecuentes extraídos automáticamente del código SPL de BanCoppel.
Cada entrada es un `business_name` que aparece en 3 o más reglas — lo que indica que es un
concepto recurrente y relevante en el sistema.

Usar este vocabulario para:
- Mapear terminología del sistema a conceptos de negocio
- Identificar patrones funcionales transversales
- Alimentar análisis de equivalencia en modernización (7R)

## Top términos recurrentes (300 con ≥3 apariciones)

| Término | Apariciones | Sub_tipo | Dominios |
|---|---|---|---|
| Sin recuperacion y registros mayor a cero | 186 | CÓDIGO_RETORNO | D01,D44,D36,D10 |
| No registros igual a cero y registros mayor a cero | 113 | CÓDIGO_RETORNO | D07,D15,D01,D03,D02,D05,D10 |
| Valida parametros de entrada | 68 | CÓDIGO_RETORNO | D08,D02 |
| Existe igual a "1" | 33 | CÓDIGO_RETORNO | D04 |
| Existe no proporcionado | 32 | CÓDIGO_RETORNO | D08,D04,D02,D26,D05 |
| Registros mayor a cero y sin recuperacion | 25 | CÓDIGO_RETORNO | D01,D02,D06 |
| Número crédito no proporcionado | 24 | CÓDIGO_RETORNO | D03 |
| [1001] iCont = 0 | 22 | CÓDIGO_RETORNO | D01,D02 |
| [1001] pRegistros > 0 | 20 | CÓDIGO_RETORNO | D01 |
| Los movimientos traspasados no coinciden con los movimientos a… | 18 | CÁLCULO_ARITMÉTICO | D04 |
| No regs igual a cero y registros mayor a cero | 17 | CÓDIGO_RETORNO | D01 |
| LISR Art.54/135 | 16 | CÁLCULO_FECHA | D02 |
| Interés proyec — tasa diaria (base año comercial) | 16 | CÁLCULO_FECHA | D02 |
| Fecha hoy no proporcionado | 16 | CÓDIGO_RETORNO | D03,D02 |
| Empresa vacío | 16 | CÓDIGO_RETORNO | D03,D11,D02 |
| Conversion de tasa de interes de decimal a porcentaje para reporte | 16 | CÁLCULO_ARITMÉTICO | D02 |
| vingresomensual: iIngreso * iValor | 15 | CÁLCULO_ARITMÉTICO | D02 |
| Empresa igual a cero o empresa vacío o sucursal igual a cero o sucursal vacío o  | 15 | CÓDIGO_RETORNO | D10 |
| propaga error al ejecutar registra evento/notificación | 13 | EXCEPCIÓN | D01,D06,D16 |
| Número cte no proporcionado | 13 | CÓDIGO_RETORNO | D04,D03,D02,D26 |
| Validación saldos credinomq tablatemp | 12 | CÁLCULO_ARITMÉTICO | D11 |
| Faltan parametros | 12 | CÓDIGO_RETORNO | D02,D08,D15 |
| Cálculo de res IVA (impuesto — SAT) otros cargos (factor 16) | 12 | CÁLCULO_ARITMÉTICO | D04,D08 |
| Checar valores nulos en los parametros | 12 | CÓDIGO_RETORNO | D15 |
| vBaseisr: vRetencionIsr vValor_tasa_isr | 11 | CÁLCULO_ARITMÉTICO | D04 |
| [1001] iRegistros = 0 | 11 | CÓDIGO_RETORNO | D01 |
| Remocion de sobretasa de la tasa de interes (division inversa) | 11 | CÁLCULO_ARITMÉTICO | D03,D06 |
| Ajuste de tasa de interes por sobretasa (factor multiplicativo) | 11 | CÁLCULO_ARITMÉTICO | D03,D06 |
| v_Isr_valida: vBaseisr vValor_tasa_isr | 10 | CÁLCULO_ARITMÉTICO | D04 |
| vValor_tasa: v_tasa_isr viDias vaniobase | 10 | CÁLCULO_PORCENTUAL | D04 |
| Tasa (de interés) mensual — tasa mensual (÷12) | 10 | CÁLCULO_ARITMÉTICO | D04,D03,D06 |
| Cálculo de otros cargos (factor 16) | 10 | CÁLCULO_ARITMÉTICO | D04 |
| Cuenta no proporcionado | 10 | CÓDIGO_RETORNO | D04,D03 |
| Aplicacion de sobretasa a tasa de mora en proyeccion de credito | 10 | CÁLCULO_ARITMÉTICO | D03 |
| EXCEPCIÓN: cCodRetSp::INTEGER < 0 | 9 | EXCEPCIÓN | D01 |
| propaga error al ejecutar consultar CCE | 8 | EXCEPCIÓN | D01 |
| dImp_Isr_Fin: iDiasProyec * pAniobase | 8 | CÁLCULO_FECHA | D02 |
| dImp_Isr_Fin: iDiasProyec * iAniobase | 8 | CÁLCULO_FECHA | D02 |
| Verifica recepcion correcta de datos | 8 | CÓDIGO_RETORNO | D10,D02 |
| Valida campos requeridos | 8 | CÓDIGO_RETORNO | D02 |
| Tpo persona vacío o tpo persona no proporcionado | 8 | CÓDIGO_RETORNO | D04,D35,D02 |
| Tipo de persona no proporcionado | 8 | CÓDIGO_RETORNO | D08,D02 |
| Terminã correctamente | 8 | CÓDIGO_RETORNO | D04,D03 |
| Reporte de cac lineacredito | 8 | CONTROL_FLUJO | D06 |
| Remocion de sobretasa moratoria (division inversa) | 8 | CÁLCULO_ARITMÉTICO | D03,D06 |
| Pago no es el ultimo reversa en orden | 8 | CÓDIGO_RETORNO,CONTROL_FLUJO | D03 |
| Monto325 — conversión desde porcentaje (÷100) (vmMonto325) | 8 | CÁLCULO_ARITMÉTICO | D15 |
| Interes diario sobre capital neto de traslados no vencidos y amortizados | 8 | CÁLCULO_FECHA | D03 |
| Interes diario sobre capital ajustado por traslados en periodo inhibido | 8 | CÁLCULO_FECHA | D03 |
| Fechaproc diferente de fecha hoy | 8 | CÓDIGO_RETORNO | D04 |
| Datos de entrada incompletos | 8 | CÓDIGO_RETORNO | D35,D13 |
| Calcula temporal | 8 | CÁLCULO_ARITMÉTICO | D16 |
| Ajuste de tasa de mora por sobretasa moratoria (factor multiplicativo) | 8 | CÁLCULO_ARITMÉTICO | D03,D06 |
| Web service no proporcionado o web service vacío o país trnf no proporcionado o  | 7 | CÓDIGO_RETORNO | D04 |
| Umbral de: validartipodatos | 7 | UMBRAL_SIMPLE | D11 |
| Tim estado civ — inversión de signo (debe/haber) | 7 | CÁLCULO_ARITMÉTICO,CÁLCULO_INVERSIÓN | D06 |
| Remocion de sobretasa de la tasa a favor del cliente (division inversa) | 7 | CÁLCULO_ARITMÉTICO | D03 |
| Parametros de entrada invalidos | 7 | CÓDIGO_RETORNO | D03,D06 |
| No tiene tarjetas | 7 | CÓDIGO_RETORNO | D16 |
| Interes acumulado en mes actual y siguiente en cierre de inversion | 7 | CÁLCULO_FECHA | D04 |
| IVA sobre comision: (comision) x tasa IVA (16% o 8% frontera) | 7 | CÁLCULO_ARITMÉTICO | D04 |
| Formato de fecha | 7 | CONSTRUCCIÓN_CADENA,CÁLCULO_FECHA,CÁLCULO_ARITMÉTI | D01,D03,D09,D02,D15 |
| Comision minima RECO ajustada por factor de prevencion | 7 | CÁLCULO_ARITMÉTICO | D04 |
| Comision maxima RECO ajustada por factor de prevencion | 7 | CÁLCULO_ARITMÉTICO | D04 |
| Ajuste de tasa a favor del cliente por sobretasa (factor multiplicativo) | 7 | CÁLCULO_ARITMÉTICO | D03 |
| propaga error al ejecutar consulta | 6 | EXCEPCIÓN | D01,D12 |
| dIvaInt: ivaint intereses iva | 6 | CÁLCULO_ARITMÉTICO | D03 |
| dIntereses: intereses intereses sdoinicial tasaint idiasperiodo fecha | 6 | CÁLCULO_FECHA | D03 |
| dImp_Isr_Ini: iDiasISR * pAniobase | 6 | CÁLCULO_FECHA | D02 |
| Valida que el cliente no sea blanco | 6 | CÓDIGO_RETORNO | D14,D04 |
| Usuario diferente de "user" | 6 | CÓDIGO_RETORNO | D04,D02 |
| Tipo de usuario no valido | 6 | CÓDIGO_RETORNO | D23 |
| Tasa de interes con IVA incluido convertida a decimal (Credisol) | 6 | CÁLCULO_INTERÉS | D03,D06 |
| Tasa (de interés) periodo — tasa mensual (÷12) | 6 | CÁLCULO_PORCENTUAL | D03 |
| Tasa (de interés) mensual mora — tasa mensual (÷12) | 6 | CÁLCULO_ARITMÉTICO | D03 |
| Tasa (de interés) diario — conversión desde porcentaje (÷100) | 6 | CÁLCULO_PORCENTUAL | D03 |
| Sin registros y registros mayor a cero | 6 | CÓDIGO_RETORNO | D01 |
| Ruta arch vacío | 6 | CÓDIGO_RETORNO | D03 |
| Remocion de sobretasa de tasa de interes en domiciliacion (division) | 6 | CÁLCULO_ARITMÉTICO | D03 |
| Remocion de sobretasa de mora en proyeccion de credito (division) | 6 | CÁLCULO_ARITMÉTICO | D03 |
| Numcte no proporcionado | 6 | CÓDIGO_RETORNO | D03,D02,D26 |
| No existe información del reporte del cierre diario de la… | 6 | CÓDIGO_RETORNO | D23 |
| Monto interés — tasa diaria (base año comercial) | 6 | CÁLCULO_FECHA,CÁLCULO_PORCENTUAL | D04 |
| Interes mensual dPagoReq: monto x (tasa div 100) div 360 x 30 (base anio comerci | 6 | CÁLCULO_PORCENTUAL,CÁLCULO_ARITMÉTICO | D03 |
| Interes diario sobre monto de linea de credito en centavos (proyecta) | 6 | CÁLCULO_ARITMÉTICO | D03 |
| IVA sobre intereses redondeado a centavos | 6 | CÁLCULO_ARITMÉTICO | D03,D06 |
| Fechaproc no proporcionado | 6 | CÓDIGO_RETORNO | D04 |
| Empresa vacío o fecha vacío | 6 | CÓDIGO_RETORNO | D16 |
| El archivo ya fue procesado | 6 | CÓDIGO_RETORNO | D08 |
| Cálculo de tot tipo | 6 | CÁLCULO_ARITMÉTICO | D06 |
| Cálculo de monto udi | 6 | CÁLCULO_ARITMÉTICO | D04,D10 |
| Cálculo de monto 500 (factor 500) | 6 | CÁLCULO_ARITMÉTICO | D01 |
| Cálculo de monto 50 (factor 50) | 6 | CÁLCULO_ARITMÉTICO | D01 |
| Cálculo de interés grav | 6 | CÁLCULO_ARITMÉTICO | D03 |
| Cálculo de cuota Captación — cuentas de ahorro/depósito (factor 10) | 6 | CÁLCULO_ARITMÉTICO | D03 |
| Cuenta no proporcionado o cuenta vacío | 6 | CÓDIGO_RETORNO | D04 |
| Conversion de tasa de interes de porcentaje a decimal (proyeccion Credisol) | 6 | CÁLCULO_INTERÉS | D03,D06 |
| Conversion de tasa anual de porcentaje a decimal para tabla de amortizacion | 6 | CÁLCULO_PORCENTUAL | D03 |
| Comision por-mil MN: monto x factor x prevencion / 1000 | 6 | CÁLCULO_ARITMÉTICO | D04 |
| Ajuste de tasa de interes por sobretasa en domiciliacion (multiplicacion) | 6 | CÁLCULO_ARITMÉTICO | D03 |
| vimpisr: vtotal * vtasa_isr * vaniobase / 100 | 5 | CÁLCULO_PORCENTUAL | D04 |
| propaga error al ejecutar obtiene parámetro | 5 | EXCEPCIÓN | D01 |
| propaga error al ejecutar ctemoral | 5 | EXCEPCIÓN | D01 |
| propaga error al ejecutar consulta CNSIF | 5 | EXCEPCIÓN | D01 |
| dTasas: tasas tasas ow tasa interes 100 12 | 5 | CÁLCULO_PORCENTUAL | D03 |
| calcula IVA sobre importe de comisión o convenio | 5 | CÁLCULO_FISCAL,CÁLCULO_ARITMÉTICO | D04,D05,D06 |
| [154] vCantReg = 0 | 5 | CÓDIGO_RETORNO | D03 |
| Valor presente de monto adicional descontado a tasa periodica (plazo max) | 5 | CÁLCULO_ARITMÉTICO | D03 |
| Valor presente de monto adicional descontado a tasa periodica (plazo +3) | 5 | CÁLCULO_ARITMÉTICO | D03 |
| Validacion de campos requeridos | 5 | CÓDIGO_RETORNO | D15,D02 |
| Usuario diferente de usuario o usuario no proporcionado | 5 | CÓDIGO_RETORNO | D04 |
| Umbral de: maxdelq0to11mos motor | 5 | UMBRAL_SIMPLE | D03 |
| Umbral de: arrpagoint 18082010 | 5 | UMBRAL_RANGO,UMBRAL_SIMPLE | D04 |
| Total porc atendidas — conversión a porcentaje (×100) | 5 | CÁLCULO_ARITMÉTICO | D03 |
| Tasa diaria: tasa anual en porcentaje dividida entre dias del anio | 5 | CÁLCULO_ARITMÉTICO | D03 |
| Sdoactual no proporcionado | 5 | CÓDIGO_RETORNO | D04 |
| Sdo deudor no proporcionado | 5 | CÓDIGO_RETORNO | D03 |
| Reserva en pesos: valorreserva = (valor_reserva x valorSM) x 30.42 dias/bimestre | 5 | CÁLCULO_ARITMÉTICO | D03 |
| Remocion de sobretasa de tasa de interes en apertura de credito | 5 | CÁLCULO_ARITMÉTICO | D03 |
| Remocion de sobretasa de tasa a favor del cliente en apertura de credito | 5 | CÁLCULO_ARITMÉTICO | D03 |
| Remocion de sobretasa de la tasa de interes en proyeccion de credito | 5 | CÁLCULO_ARITMÉTICO | D03 |
| Registros mayor a cero y no registros igual a cero | 5 | CÓDIGO_RETORNO | D01 |
| Porc atendidas — conversión a porcentaje (×100) | 5 | CÁLCULO_ARITMÉTICO | D03 |
| Nueva forma de calcular el iva | 5 | CÁLCULO_FISCAL | D04 |
| No registros igual a cero y sin registros | 5 | CÓDIGO_RETORNO | D01 |
| No existe el archivo | 5 | CÓDIGO_RETORNO | D08 |
| Mensualización: dPago_Mes = ... div 12 (conversion anual a mensual) | 5 | CÁLCULO_PORCENTUAL | D03 |
| Inversion de signo de tasa de mora para registro contable en apertura | 5 | CÁLCULO_INVERSIÓN | D03 |
| Interés proy — tasa diaria (base año comercial) | 5 | CÁLCULO_FECHA | D02 |
| Interes diario sobre monto de provision del mes previo | 5 | CÁLCULO_ARITMÉTICO | D03 |
| Interes diario sobre monto de provision del mes actual | 5 | CÁLCULO_ARITMÉTICO | D03 |
| Interes diario sobre monto adicional en centavos (proyecta prestamos) | 5 | CÁLCULO_ARITMÉTICO | D03 |
| Interes del mes previo: provision diaria por dias de provision | 5 | CÁLCULO_ARITMÉTICO | D03 |
| Interes del mes actual: provision diaria por dias de provision | 5 | CÁLCULO_ARITMÉTICO | D03 |
| Importe total — conversión desde porcentaje (÷100) | 5 | CÁLCULO_PORCENTUAL | D05 |
| IVA sobre comisiones pendientes: saldo pendiente x tasa IVA | 5 | CÁLCULO_ARITMÉTICO | D03 |
| Fórmula: mc cal dia c interno | 5 | CÁLCULO_ARITMÉTICO | D32 |
| Directorio no proporcionado o directorio vacío | 5 | CÓDIGO_RETORNO | D04 |
| Código mn no proporcionado | 5 | CÓDIGO_RETORNO | D04 |
| Cuenta no existe en fecha | 5 | CÓDIGO_RETORNO | D04,D02 |
| Consulta aproximacion | 5 | CÁLCULO_MONETARIO | D06 |
| Carga archivo dotacion masiva | 5 | EXCEPCIÓN,CÁLCULO_ARITMÉTICO | D01 |
| Calcula monto (conversión porcentual (÷100)) | 5 | CÁLCULO_PORCENTUAL | D03,D08,D15 |
| Aplicacion de sobretasa a tasa de interes en proyeccion de credito | 5 | CÁLCULO_ARITMÉTICO | D03 |
| Aplicacion de sobretasa a tasa de interes en apertura de credito | 5 | CÁLCULO_ARITMÉTICO | D03 |
| Aplicacion de sobretasa a tasa a favor del cliente en apertura de credito | 5 | CÁLCULO_ARITMÉTICO | D03 |
| Accrual diario de interes moratorio ordinario sobre saldo vencido | 5 | CÁLCULO_ARITMÉTICO | D03 |
| vtasa_periodo: vtasa periodo ivamas | 4 | CÁLCULO_ARITMÉTICO | D03 |
| vmonto_com: vcuantos | 4 | CÁLCULO_ARITMÉTICO | D04 |
| vimpisr: vcapital * vtasa_isr * vaniobase / 100 | 4 | CÁLCULO_PORCENTUAL | D04 |
| v_numero_anios: numero anios numero anios logn 100 | 4 | CÁLCULO_PORCENTUAL | D03 |
| v_clave4: concatena clave4 posicion11 fec ult monto | 4 | CONSTRUCCIÓN_CADENA | D03 |
| vTasaMora: tasamora sobretasa | 4 | CÁLCULO_ARITMÉTICO | D03 |
| vCodRet 400: apertura credito restructura | 4 | CÓDIGO_RETORNO | D03 |
| umbral: iDifDias > 31 AND iDifDias < 361 | 4 | UMBRAL_RANGO | D04 |
| umbral: iDifDias < 361 | 4 | UMBRAL_FECHA | D04 |
| umbral: iDifDias < 32 | 4 | UMBRAL_FECHA | D04 |
| propaga error al ejecutar guarda Comisión bancaria | 4 | EXCEPCIÓN | D01 |
| propaga error al ejecutar guarda CCE | 4 | EXCEPCIÓN | D01 |
| propaga error al ejecutar graba detalle, archivo y tarjeta de crédito | 4 | EXCEPCIÓN | D01 |
| propaga error al ejecutar consulta auditoría | 4 | EXCEPCIÓN | D01 |
| propaga error al ejecutar consulta Administrador | 4 | EXCEPCIÓN | D01 |
| propaga error al ejecutar consulta (general) | 4 | EXCEPCIÓN | D01 |
| propaga error al ejecutar [polisemia] Cálculo y día hábil | 4 | EXCEPCIÓN | D01,D12 |
| mIntereses: mintereses msdoinicial mtasaint sdiasperiodo 360 | 4 | CÁLCULO_ARITMÉTICO | D03 |
| dt_fecha_reporte = vmes∣∣'/'∣∣vdia∣∣'/'∣∣vano | 4 | CONSTRUCCIÓN_CADENA | D03 |
| d_monto_nvo_ret: monto nvo negacion contable | 4 | CÁLCULO_INVERSIÓN | D03 |
| cTimEdoCiv = monthadd(dtFechSol, cEdoCiv x -1) | 4 | CÁLCULO_INVERSIÓN | D06 |
| cFechaPresentacion = substr(cFechaPresentacion,7,2)∣∣chr(47)∣∣substr(cFechaPrese | 4 | CONSTRUCCIÓN_CADENA | D13 |
| cCodRet='105' — vcodret | 4 | CÓDIGO_RETORNO | D10 |
| cCodRet='00002' — v_sCodRetValidaRef <>"00000" | 4 | CÓDIGO_RETORNO | D08 |
| [999] SUBSTR(pcuenta, 1, 2) = '80' | 4 | CÓDIGO_RETORNO | D04 |
| [99999] iTotales > 0 | 4 | CÓDIGO_RETORNO | D01 |
| [777] vdisp_mes > vlimite_aut | 4 | CÓDIGO_RETORNO | D04 |
| [1001] iCodRetSp = 3 | 4 | CÓDIGO_RETORNO | D01 |
| Ya existe registro previo del credito con cliente y credito 6001… | 4 | CÓDIGO_RETORNO | D03 |
| Verifica que haya almenos un parametro de busqueda | 4 | CÓDIGO_RETORNO | D04 |
| Validación de codret | 4 | CÓDIGO_RETORNO | D04,D08 |
| Validacion de los datos de entrada | 4 | CÓDIGO_RETORNO | D11 |
| Valida que la cuenta no sea blanco | 4 | CÓDIGO_RETORNO | D04 |
| Umbral de: cal circulocredito cjunk2 | 4 | UMBRAL_SIMPLE | D06 |
| Umbral de: cal circulocredito cjunk | 4 | UMBRAL_SIMPLE,UMBRAL_RANGO | D06 |
| Tasa mensual: tasa anual de interes dividida entre el plazo en meses | 4 | CÁLCULO_ARITMÉTICO | D03 |
| Tasa mensual con IVA: tasa anual IVA dividida entre el plazo (Credisol) | 4 | CÁLCULO_ARITMÉTICO | D03 |
| Sql err < mayor a cero | 4 | CÓDIGO_RETORNO | D03,D08 |
| Solamente debe enviar un solo parametro. | 4 | CÓDIGO_RETORNO | D04 |
| Sin registro y registros mayor a cero | 4 | CÓDIGO_RETORNO | D07,D01 |
| Se verifica que almenos se incluya el parametro empresa | 4 | CÓDIGO_RETORNO | D04 |
| Se validan los parametros de entrada | 4 | CÓDIGO_RETORNO | D08 |
| Se omite el monto ya que el monto al inicio del periodo es… | 4 | CÁLCULO_MONETARIO | D03 |
| Saldo promedio — redondeo financiero | 4 | CÁLCULO_ARITMÉTICO | D04 |
| Saldo promedio — proyección anual comercial (×360) | 4 | CÁLCULO_PORCENTUAL | D03 |
| Saldo promedio positivo = saldo acumulado / dias con saldo positivo | 4 | CÁLCULO_FECHA | D04 |
| Reserva Buro SIC gradual: vImporteReservaBuroCC = dResCalificacion * dPorResSic  | 4 | CÁLCULO_ARITMÉTICO | D03 |
| Ratio monto vs saldo SIC: v_mtovssdo_sic = (mto_pagar_propios + mto_pagar_otros) | 4 | CÁLCULO_ARITMÉTICO | D03 |
| Provision diaria de inversion: capital por tasa anual entre dias del anio | 4 | CÁLCULO_INTERÉS | D04 |
| Proceso exitoso | 4 | CÓDIGO_RETORNO | D23 |
| Probabilidad de incumplimiento dPI: modelo logistico CNBV B-5 (iACT, iHIST, dPor | 4 | CÁLCULO_ARITMÉTICO | D03 |
| Porcentaje pago 4 periodos: NVL(sum(v_prom) div 4, 0) | 4 | CÁLCULO_ARITMÉTICO,CÁLCULO_MONETARIO | D03 |
| Por si el archivo no  se genera | 4 | CÓDIGO_RETORNO | D11 |
| Por Factor | 4 | CÁLCULO_PORCENTUAL | D04 |
| Parámetro no proporcionado o parámetro vacío | 4 | CÓDIGO_RETORNO | D04 |
| Parametros de entrada estan en blanco. | 4 | CÓDIGO_RETORNO | D08 |
| Numcte no proporcionado o numcte vacío | 4 | CÓDIGO_RETORNO | D04,D03,D02 |
| No existe el cliente | 4 | CÓDIGO_RETORNO | D04 |
| MtoMoraCopeMa: mto mora cope tasacope 100 | 4 | CÁLCULO_ARITMÉTICO | D03 |
| Monto cashback325 — conversión desde porcentaje (÷100) (vmMontoCashback325) | 4 | CÁLCULO_ARITMÉTICO | D15 |
| Meses de atraso: v_meses = v_dias_atraso div 30.4 (dias a meses para calificacio | 4 | CÁLCULO_ARITMÉTICO | D03 |
| La cuenta no existe en la base de datos | 4 | CÓDIGO_RETORNO | D04 |
| La cuenta no existe | 4 | CONTROL_FLUJO,CÓDIGO_RETORNO | D01,D03 |
| La cuenta Ord. no se encuentra activa | 4 | CÓDIGO_RETORNO | D04,D08 |
| Inversion de signo de tasa de mora para registro contable en domiciliacion | 4 | CÁLCULO_INVERSIÓN | D03 |
| Inversion de signo de tasa de mora para estado de cuenta | 4 | CÁLCULO_INVERSIÓN | D03 |
| Interes moratorio diario: saldo vencido por tasa anual entre dias del anio | 4 | CÁLCULO_FECHA | D03 |
| Interes moratorio de copropiedad: saldo vencido por tasa de copropiedad | 4 | CÁLCULO_FECHA | D03 |
| Interes del mes activo: provision diaria por dias del mes en cierre | 4 | CÁLCULO_FECHA | D04 |
| Importe — conversión desde porcentaje (÷100) | 4 | CÁLCULO_PORCENTUAL | D11,D08 |
| IVA truncado: monto comision x tasa IVA (2 decimales) | 4 | CÁLCULO_ARITMÉTICO | D04 |
| IVA truncado: comision aplicada x tasa IVA (2 decimales) | 4 | CÁLCULO_ARITMÉTICO | D04 |
| IVA sobre monto de comision en cargo por referencia celular | 4 | CÁLCULO_ARITMÉTICO | D04,D03 |
| IVA sobre comision: monto comision x tasa IVA | 4 | CÁLCULO_ARITMÉTICO | D04 |
| IVA sobre comision de disposicion (tasa IVA por sucursal) | 4 | CÁLCULO_ARITMÉTICO | D03 |
| Fecha inicial no debe ser mayor a la fecha final | 4 | CÓDIGO_RETORNO | D04 |
| Fecha cierre producto de pago: dt_cierre_prod = dt_ini_per_proc - 1 dia | 4 | CÁLCULO_ARITMÉTICO | D03 |
| Falta parametro de transaccion iva. | 4 | CÓDIGO_RETORNO | D04,D08 |
| Falta parametro de transaccion comision. | 4 | CÓDIGO_RETORNO | D04,D08 |
| Factor de capitalizacion periodica: 1 mas tasa del periodo (8 decimales) | 4 | CÁLCULO_MONETARIO | D03 |
| Extrae base de comision de saldo IVA-incluido: disponible/(1+IVA) | 4 | CÁLCULO_ARITMÉTICO | D04 |
| Estatus igual a "RR" | 4 | CÓDIGO_RETORNO | D03 |
| Estatus crédito igual a "FF" | 4 | CÓDIGO_RETORNO | D03 |
| El numero de solicitud no existe | 4 | CÓDIGO_RETORNO | D03 |
| El Archivo ya fue procesado | 4 | CÓDIGO_RETORNO | D08 |
| Debe retornar forndos insuficientes | 4 | CÓDIGO_RETORNO | D04 |
| Código retorno sp::integer igual a "2" y registros mayor a cero | 4 | CÓDIGO_RETORNO | D01 |
| Código de retorno diferente de "00000" | 4 | CÓDIGO_RETORNO | D04 |
| Cálculo de mtopagosudi | 4 | CÁLCULO_ARITMÉTICO | D04,D10 |
| Cálculo de mtofin (factor 36000) | 4 | CÁLCULO_ARITMÉTICO | D11 |
| Cálculo de monto IVA (impuesto — SAT) | 4 | CÁLCULO_ARITMÉTICO | D04 |
| Cálculo de interés grav inh | 4 | CÁLCULO_ARITMÉTICO | D03 |
| Cálculo de do acum mes Captación — cuentas de ahorro/depósito | 4 | CÁLCULO_ARITMÉTICO | D03 |
| Cálculo de ahorro pago | 4 | CÁLCULO_ARITMÉTICO | D03 |
| Credito disponible: limite menos intereses proyectados menos saldo retenido | 4 | CÁLCULO_INVERSIÓN | D03 |
| Convierte comision TCC de porcentaje a tasa decimal (div100) | 4 | CÁLCULO_PORCENTUAL | D16 |
| Conversion de tasa contractual a decimal para calificacion anual | 4 | CÁLCULO_PORCENTUAL | D03 |
| Conservar el calculo a 12 como calculo anual de tasa de interes | 4 | CÁLCULO_INTERÉS | D06 |
| Comision total dispersion = registros aplicados x comision unitaria | 4 | CÁLCULO_ARITMÉTICO | D04 |
| Comision pendiente = saldo capital actual x factor de comision | 4 | CÁLCULO_ARITMÉTICO | D03 |
| Comision pendiente = linea otorgada x factor de comision | 4 | CÁLCULO_ARITMÉTICO | D03 |
| Comision fija ajustada por factor de prevencion | 4 | CÁLCULO_ARITMÉTICO | D04 |
| Comision de disposicion: monto x factor efectivo / 100 | 4 | CÁLCULO_PORCENTUAL | D03 |
| Cliente no tiene cuentas | 4 | CÓDIGO_RETORNO | D04 |
| Cant rep mayor o igual a "1" | 4 | CÓDIGO_RETORNO | D02 |
| Calcula folio sobre folio | 4 | CONSTRUCCIÓN_CADENA | D03 |
| C existe igual a "1" | 4 | CÓDIGO_RETORNO | D04 |
| Base comision de saldo IVA-incluido: disponible / (1 + tasa IVA) | 4 | CÁLCULO_ARITMÉTICO | D04 |
| Aplicacion de sobretasa a tasa a favor del cliente en domiciliacion | 4 | CÁLCULO_ARITMÉTICO | D03 |
| Actualizo diferente de "1" | 4 | CÓDIGO_RETORNO | D04,D03 |
| Actualización maenoc | 4 | CÁLCULO_ARITMÉTICO,UMBRAL_SIMPLE,UMBRAL_RANGO | D04 |
| vsdo_cong x -1 | 3 | CÁLCULO_INVERSIÓN | D04 |
| vnomtabla: vruta ∣∣ vtabla ∣∣ vdia ∣∣ vmes ∣∣ vano | 3 | CONSTRUCCIÓN_CADENA | D04 |
| vmontoRet x -1 | 3 | CÁLCULO_INVERSIÓN | D08 |
| vmonto x -1 | 3 | CÁLCULO_INVERSIÓN | D04 |
| vinteres: vprovdia * vdiasmact | 3 | CÁLCULO_FECHA | D04 |
| vintdia: vsdo_promedio vvalor_tasa vnumdias vdias_prom | 3 | CÁLCULO_FECHA | D04 |
| vcuotasvenc: vcuotasvenc fecha vfechaini 12 | 3 | CÁLCULO_ARITMÉTICO | D03 |
| vacum_sdo_pos: vsdo_actual vdias | 3 | CÁLCULO_FECHA | D04 |
| v_cVarPrueba4 = importeEnterado∣∣NVL(ROUND(v_mEnteroTotal::INT8),0)∣∣importeSald | 3 | CÁLCULO_ARITMÉTICO | D15 |
| v_cVarPrueba4 = importeEnterado="0"∣∣importeSaldoPendienteRecaudar="0"∣∣</Totale | 3 | CONSTRUCCIÓN_CADENA | D15 |
| si vcodret = "400" | 3 | CONTROL_FLUJO | D04 |
| sNivIngreso: mIngresoMensual * cIngresoMensualParam | 3 | CÁLCULO_ARITMÉTICO | D06 |
| propaga error al ejecutar reversión CCE | 3 | EXCEPCIÓN | D01 |
| propaga error al ejecutar reversa | 3 | EXCEPCIÓN | D14,D01 |
| propaga error al ejecutar reporte y portabilidad | 3 | EXCEPCIÓN | D01 |
| propaga error al ejecutar reporte producto | 3 | EXCEPCIÓN | D01 |
| propaga error al ejecutar reporte perfil de usuario y usuario | 3 | EXCEPCIÓN | D01 |
| propaga error al ejecutar procedimiento validahoraejec | 3 | EXCEPCIÓN | D01 |
| propaga error al ejecutar procedimiento guardadireccionesctemoral | 3 | EXCEPCIÓN | D01 |
| propaga error al ejecutar procedimiento ctanvl2 genportada | 3 | EXCEPCIÓN | D02 |
| propaga error al ejecutar obtiene TEF | 3 | EXCEPCIÓN | D01 |
| propaga error al ejecutar guarda ctemoral | 3 | EXCEPCIÓN | D01 |
| propaga error al ejecutar guarda apoderado y ctemoral | 3 | EXCEPCIÓN | D01 |
| propaga error al ejecutar fal | 3 | EXCEPCIÓN | D01 |
| propaga error al ejecutar estatus, solicitud, auditoría y celular | 3 | EXCEPCIÓN | D01 |
| propaga error al ejecutar consultar ctemoral | 3 | EXCEPCIÓN | D01 |
| propaga error al ejecutar consulta productos | 3 | EXCEPCIÓN | D01 |
| propaga error al ejecutar [polisemia] Cálculo y fecha | 3 | EXCEPCIÓN | D01 |
| msdo_retenido x -1 | 3 | CÁLCULO_INVERSIÓN | D04 |
| msdo_cong x -1 | 3 | CÁLCULO_INVERSIÓN | D04 |
| mTasaFavor: mtasafavor sobre tasa | 3 | CÁLCULO_ARITMÉTICO | D03 |
| mSaldoSBC x -1 | 3 | CÁLCULO_INVERSIÓN | D04 |
| intBancoOrd: vchrparametro | 3 | CÁLCULO_ARITMÉTICO | D08 |
| iIngresoMensual: iIngreso * iValor | 3 | CÁLCULO_ARITMÉTICO | D02 |
| dtFechaISR: dtFechaISR ∣∣ "/" concat | 3 | CONSTRUCCIÓN_CADENA | D02 |
| dPromPcAnCHAR: dPromPcAnCHAR ∣∣ SUBST concat | 3 | CONSTRUCCIÓN_CADENA | D02 |
| dMax: max ow endeud tot | 3 | CÁLCULO_ARITMÉTICO | D03 |
| dEI: ei endeud tot max | 3 | CÁLCULO_ARITMÉTICO | D03 |
| codret 100 — BEGIN on exception sql_err isam_err | 3 | CÓDIGO_RETORNO | D12 |
| cCodRet='1001' — iCont = 0 | 3 | CÓDIGO_RETORNO | D02 |
| [600] ( vestado = 'P' ) | 3 | CÓDIGO_RETORNO | D04 |
| [549] (vfecha_hoy < vfechacalendario ) | 3 | CÓDIGO_RETORNO | D04 |

## Patrones de validación más frecuentes

- `Sin recuperacion y registros mayor a cero` — 186 reglas
- `No registros igual a cero y registros mayor a cero` — 113 reglas
- `Valida parametros de entrada` — 68 reglas
- `Existe igual a "1"` — 33 reglas
- `Existe no proporcionado` — 32 reglas
- `Registros mayor a cero y sin recuperacion` — 25 reglas
- `Número crédito no proporcionado` — 24 reglas
- `[1001] iCont = 0` — 22 reglas
- `[1001] pRegistros > 0` — 20 reglas
- `No regs igual a cero y registros mayor a cero` — 17 reglas
- `Fecha hoy no proporcionado` — 16 reglas
- `Empresa vacío` — 16 reglas
- `Empresa igual a cero o empresa vacío o sucursal igual a cero o sucursal vacío o ` — 15 reglas
- `Número cte no proporcionado` — 13 reglas
- `Faltan parametros` — 12 reglas
- `Checar valores nulos en los parametros` — 12 reglas
- `[1001] iRegistros = 0` — 11 reglas
- `Cuenta no proporcionado` — 10 reglas
- `Verifica recepcion correcta de datos` — 8 reglas
- `Valida campos requeridos` — 8 reglas
- `Tpo persona vacío o tpo persona no proporcionado` — 8 reglas
- `Tipo de persona no proporcionado` — 8 reglas
- `Terminã correctamente` — 8 reglas
- `Fechaproc diferente de fecha hoy` — 8 reglas
- `Datos de entrada incompletos` — 8 reglas
- `Web service no proporcionado o web service vacío o país trnf no proporcionado o ` — 7 reglas
- `Parametros de entrada invalidos` — 7 reglas
- `Pago no es el ultimo reversa en orden` — 7 reglas
- `No tiene tarjetas` — 7 reglas
- `Valida que el cliente no sea blanco` — 6 reglas