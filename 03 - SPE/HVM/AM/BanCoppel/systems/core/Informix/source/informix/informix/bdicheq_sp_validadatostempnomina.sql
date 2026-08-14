Create Procedure "informix".sp_validadatostempnomina(cEmpresa Char(3), dFecha_gen date, iFolio Integer)
RETURNING CHAR(3), Char(16); 

    --Declaracion de variables
    Define cCodRet            	    	Char(3);
    Define cCodRet2           	    	Char(5);
    Define cCodRet3           	    	Char(50);
    Define vSqlErr                      Integer;
    Define vIsamErr      	            Integer;
    Define vDescErr                     Char(50);
    Define cNumeroFolio       	    	Char(16);
    Define cEstatus		     	    	Char(1);
    Define cNomArcEnc         	    	Char(17);
    Define cNomArcDet         	    	Char(17);
    Define iTotalRegEnc       	    	Integer;
    Define iTotalRegDet       	    	Integer;
    Define mImpTotEnc         	    	Money(14,2);
    Define mImpTotDet         	    	Money(14,2);
    Define cNumEmpEnc         	    	Char(10);
    Define cNumEmpDet                   Char(10);
    Define cCuentaEje                   Char(20);
    Define dFechaActual                 Date;
    Define dFechaAplicacion             Date;
    Define cEstatusCuenta     	    	Char(1);
    Define iRegNegativos          	    Integer;
    Define cNombreArchivoSinExtension   Char(20);
    Define cdirectorioArchivo1    	    Char(800);
    Define cdirectorioArchivo2    	    Char(800);
    Define cdirectorioArchivo3   	    Char(800);
    Define creaArch              	    Char(800);
    Define iTipoEmpresa           	    Integer;
    Define siValorConcepto          	smallint;
    Define cCargo						Char(1);
    Define cMotivo						Char(2);
    
    Define iCtas        INTEGER;
    Define iCuenta      INTEGER;
    Define cCuentaAbono CHAR(20);
    Define iSumCuentas  INT8;
    Define mImporte     MONEY(14,2);
    Define mSumImporte  MONEY(18,2);

    --Inicializacion de Variables
    Let cCodRet = "000";
    Let cCodRet2 = "";
    Let cCodRet3 = "";
    Let vSqlErr = 0;
    Let vIsamErr = 0;
    Let vDescErr = '';
    Let cNumeroFolio = "";
    Let cEstatus = '';
    Let cNomArcEnc = '';
    Let cNomArcDet = '';
    Let iTotalRegEnc = 0 ;
    Let iTotalRegDet = 0 ;
    Let mImpTotEnc = 0;
    Let mImpTotDet = 0;
    Let cNumEmpEnc = '0';
    Let cNumEmpDet = '0';
    Let cCuentaEje = '';
    Let dFechaAplicacion = '' ;
    Let cEstatusCuenta = '';
    Let iRegNegativos = 0;
    Let cNombreArchivoSinExtension = '';
    Let cdirectorioArchivo1 = '';
    Let cdirectorioArchivo2 = '';
    Let cdirectorioArchivo3 = '';
    Let creaArch = '';
    Let iTipoEmpresa = 0;
    Let cCargo = '';
    Let cMotivo = '';
    
    LET iCtas = 0;
    LET iCuenta = 0;
    LET cCuentaAbono = '';
    LET iSumCuentas = 0;
    LET mImporte = 0.00;
    LET mSumImporte = 0.00;
    
    Begin

    ON EXCEPTION SET vSqlErr, vIsamErr, vDescErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_validadatostempnomina.err";
        TRACE ON;
        ROLLBACK WORK;
        IF vSqlErr != 0 THEN
            LET cCodRet = vSqlErr;
            LET cCodRet2 = vIsamErr;
            LET cCodRet3 = vDescErr;
            RETURN cCodRet, cNumeroFolio;
        END IF;
    END EXCEPTION;
    
    ON EXCEPTION IN (-239)
        ROLLBACK WORK;
        Let cCodRet = '550';
        RETURN cCodRet, cNumeroFolio;
    END EXCEPTION WITH RESUME;	
    
    ON EXCEPTION IN (-1207)
        ROLLBACK WORK;
        Let cCodRet = '550';
        RETURN cCodRet, cNumeroFolio;
    END EXCEPTION WITH RESUME;	

    ON EXCEPTION IN (-100)
        Let cCodRet = '550';
        ROLLBACK WORK;
        RETURN cCodRet, cNumeroFolio;
    END EXCEPTION WITH RESUME;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_validadatostempnomina.out";
    --- TRACE ON;
    
    BEGIN WORK;
    
    -- // Busco los datos en las tablas temporales
    If Not Exists (Select nombre_archivo 
                     From bdicheq:sc_nominaencabezadosumariotemp
                    Where empresa = cEmpresa 
                      And fecha_gen = dFecha_gen 
                      And folio_archivo = iFolio ) Then
        Let cCodRet = "600";   --No Existen los Datos en la Tabla Temporal del Encabaezado
        ROLLBACK WORK;
        Return cCodRet, cNumeroFolio;
    End If

    Select empresa, nombre_archivo, cuenta_cargo, fecha_aplicacion, total_registros, importe_tot
      Into cNumEmpEnc, cNomArcEnc, cCuentaEje, dFechaAplicacion, iTotalRegEnc, mImpTotEnc
      From bdicheq:sc_nominaencabezadosumariotemp 
     where empresa = cEmpresa 
       And fecha_gen = dFecha_gen 
       And folio_archivo = iFolio;

    -- // Obtengo el tipo empresa. 1-Externa, 2-Interna
    Select tipo_empresa 
      into iTipoEmpresa 
      from sc_nominaempresas 
     where codigo = cNumEmpEnc;

    Select Limit 1 concepto 
      Into siValorConcepto
      From bdicheq:sc_nominamovimientostemp
     Where nombre_archivo = cNomArcEnc  ;

    /* Cambio Validacion para que si la empresa es interna pero tiene un
    concepto diferente a nomina se tome como externa para el cobro de impuestos */
    if (iTipoEmpresa = 2) and (siValorConcepto <> 1) and (siValorConcepto <> 5) then
        Let iTipoEmpresa = 1;
    end if

    -- // Valida cuenta eje si empresa es Externa ó si es Externa-Externa
    If iTipoEmpresa <> 2 Then
        If Not Exists (Select cuenta From bdicheq:sc_maechq Where empresa = '001' And cuenta = cCuentaEje) Then
            Let cCodRet  = "100"; --La cuenta NO Existe en la Base de Datos
            ROLLBACK WORK;
            RETURN cCodRet, cNumeroFolio;
        Else
            Select status_cta,motivo 
              Into cEstatusCuenta,cMotivo 
              From bdicheq:sc_maechq
             Where empresa = '001' 
               And cuenta = cCuentaEje;

            If cEstatusCuenta IN('2','6','7','8') Then --- La Cuenta esta Cancelada
                Let cCodRet = "100";
                ROLLBACK WORK;
                Return cCodRet, cNumeroFolio;
            Elif cEstatusCuenta = '3' Then --- La Cuenta esta Bloqueada
                Select cargo 
                  Into cCargo 
                  From sc_bloqueo 
                 Where codigo = cMotivo;
                 
                IF cCargo = 'N' THEN
                    Let cCodRet = "100";
                    ROLLBACK WORK;
                    Return cCodRet, cNumeroFolio;
                End IF
            End If
        End If
    End If

    Select fecha_hoy 
      Into dFechaActual 
      From bdicheq:sc_fechas 
     Where empresa = '001';
     
    If dFechaAplicacion < dFechaActual Then
        Let cCodRet  = "150"; --- La Fecha de Aplicacion es menor a la fecha Actual
        ROLLBACK WORK;
        RETURN cCodRet, cNumeroFolio;
    End If

    Select NVL(status, '') 
      Into cEstatus 
      From bdicheq:sc_nominaencabezadosumario
     Where empresa = cEmpresa 
       And fecha_gen = dFecha_gen 
       And folio_archivo = iFolio;

    If cEstatus = '1' Then
        Let cCodRet  = "200"; --- Archivo ya fue Validado Pero No Procesado
        ROLLBACK WORK;
        RETURN cCodRet, cNumeroFolio;
    Elif cEstatus In ('2', '3') Then
        Let cCodRet  = "250"; --- Archivo ya fue procesado
        ROLLBACK WORK;
        RETURN cCodRet, cNumeroFolio;
    End If

    -- // VALIDACIONES DE LOS DATOS DE LAS TABLAS TEMPORALES
    --- Let cNomArcEnc = (trim(cEmpresa) || lpad(year(dFecha_gen),4,0) || lpad(Month(dFecha_gen),2,0) || lpad(day(dFecha_gen),2,0) || lpad(iFolio,2,0));
    If Not Exists (Select distinct(nombre_archivo) From bdicheq:sc_nominamovimientostemp Where nombre_archivo = cNomArcEnc ) Then
        Let cCodRet = "550"; --- Existe el Encabezado pero No Existen los Movimientos (El Detalle)
        ROLLBACK WORK;
        Return cCodRet, cNumeroFolio;
    End If

    -- // Validacion del Nombre del Archivo,Numero de Registros, Importe, Numero de la EmpresA
    Select Count(*), Sum(importe), substr(nombre_archivo,1,3), nombre_archivo
      Into iTotalRegDet, mImpTotDet, cNumEmpDet, cNomArcDet
      From bdicheq:sc_nominamovimientostemp
     Where nombre_archivo = cNomArcEnc -- cNombreArchivo
     Group by nombre_archivo;

    If cNomArcEnc <> cNomArcDet Then
        Let cCodRet = '300';
        ROLLBACK WORK;
        Return cCodRet, cNumeroFolio;
    ElIf iTotalRegEnc <> iTotalRegDet Then
        Let cCodRet = '350';
        ROLLBACK WORK;
        Return cCodRet, cNumeroFolio;
    ElIf mImpTotEnc <> mImpTotDet Then
        Let cCodRet = '400';
        ROLLBACK WORK;
        Return cCodRet, cNumeroFolio;
    ElIf cNumEmpEnc <> cNumEmpDet Then
        Let cCodRet = '450';
        ROLLBACK WORK;
        Return cCodRet, cNumeroFolio;
    End If --Else

    -- // Validacion de Rojos (- negativos)
    Select Count(importe) 
      into iRegNegativos 
      From bdicheq:sc_nominamovimientostemp 
     Where importe < 0;
     
    If iRegNegativos > 0 Then
        Let cCodRet = '400'; --- Importes totales no coinciden o saldos negativos
        ROLLBACK WORK;
        Return cCodRet, cNumeroFolio;
    End If

    -- // Se manda ejecutar el sp del genera folio
    Call sp_generafolionomina("informix") 
    Returning  cCodRet,  cNumeroFolio;

    -- // Aqui se hacen los Inserts Macivos a las tablas
    Insert Into bdicheq:sc_nominaencabezadosumario(empresa,fecha_gen,folio_archivo,nombre_archivo,sentido,cuenta_cargo,fecha_aplicacion,total_registros,importe_tot,status,fecha_insert,folio_acuserecibo)
    Select empresa, fecha_gen, folio_archivo, nombre_archivo, sentido, cuenta_cargo, fecha_aplicacion, total_registros, (importe_tot / 100), '1', dFechaActual, cNumeroFolio
      From bdicheq:sc_nominaencabezadosumariotemp
     Where empresa = cEmpresa 
       And fecha_gen = dFecha_gen 
       And folio_archivo = iFolio;

    Insert Into bdicheq:sc_nominamovimientos (nombre_archivo, num_empleado, apell_paterno, apell_materno, nombres, cuenta_abono, importe, concepto, status)
    Select nombre_archivo, num_empleado, apell_paterno, apell_materno, nombres, cuenta_abono, (importe / 100), concepto, '0'
      From bdicheq:sc_nominamovimientostemp
     Where nombre_archivo = cNomArcDet;
     
    /* #########################  Genera Cifras de Control  ######################### */
    Foreach
        Select cuenta_abono, (importe / 100)
          Into cCuentaAbono, mImporte
          From sc_nominamovimientostemp
         Where nombre_archivo = cNomArcDet
         
        LET iCtas = iCtas + 1;
        LET iCuenta = SUBSTR(cCuentaAbono,3,9)::INTEGER;
        LET iSumCuentas = ( iSumCuentas + ( iCuenta / 10000 ) );
        LET mSumImporte = mSumImporte + mImporte;
        
        Let cCuentaAbono = '';
        Let mImporte = 0.00;
        Let iCuenta = 0;
    End Foreach;
    
    INSERT INTO sc_cifr_ctl_disp
    ( nombre_archivo, fecha_aplicacion, no_cuentas, suma_cuentas, suma_importe )
    VALUES
    ( cNomArcDet, dFechaAplicacion, iCtas, iSumCuentas, mSumImporte );
    /* #########################  Genera Cifras de Control  ######################### */

    -- // Borro los Registros de las Tablas Temporales
    Delete from bdicheq:sc_nominamovimientostemp 
     Where nombre_archivo = cNomArcDet;
     
    Delete from bdicheq:sc_nominaencabezadosumariotemp 
     Where empresa = cEmpresa 
       And fecha_gen = dFecha_gen 
       And folio_archivo = iFolio;

    -- // Extraigo el nombre del archivo sin la extension
    Let cNombreArchivoSinExtension = SubString(Trim(cNomArcEnc) From 1 For 13);

    --- Comando Para Crear Archivos (rm -f NombreArchivo.ext)
    --- Comando Para Eliminar Archivos  (rm -rf NombreArchivo.ext)
    
    /* ################################################################################################################################
    Let cdirectorioArchivo1 = "rm -rf /tmp/traspasobanco/archivosnomina/" || Trim(cNomArcEnc);
    SYSTEM cdirectorioArchivo1;
    ################################################################################################################################ */
    
    Let cdirectorioArchivo1 = "mv /tmp/traspasobanco/archivosnomina/"||Trim(cNomArcEnc)||" /resplogifx/conciliachq/"||Trim(cNomArcEnc);
    SYSTEM cdirectorioArchivo1;

    Let cdirectorioArchivo2 = "rm -rf /tmp/traspasobanco/archivosnomina/" || Trim(cNombreArchivoSinExtension) || "enc_sum.txt";
    SYSTEM cdirectorioArchivo2;

    Let cdirectorioArchivo3 = "rm -rf /tmp/traspasobanco/archivosnomina/" || Trim(cNombreArchivoSinExtension) || "mov.txt";
    SYSTEM cdirectorioArchivo3;

    COMMIT WORK;
    
    Return cCodRet, cNumeroFolio;
    
    End
    
End Procedure

DOCUMENT
'AUTOR :Armando Mercado',
'DESCRIPCION: Se crea proceso de nómina para preparar información para dispersión.',
'Captacion',
'FECHA : Octubre de 2008',
'VERSION: 200810',
'BD    : BDICHEQ',
'Modifico :Antonio Bastidas',
'DESCRIPCION: Se realizo la validacion del tipo de bloqueo de la cuenta eje, Adapto para nomina altas nuevas empresa 001',
'Captacion',
'FECHA : Octubre de 2009',
'VERSION: 20091023.1700',
'BD    : BDICHEQ';

create procedure "informix".calc_int(pempresa char(3),
                                     pcta_chq char(20))

returning char(5),money(14,2),decimal(9,6),
          money(14,2),money(14,2),
          money(14,2),money(14,2),
          char(3),char(2);

define vstatus_cta,vfisica,vcobraisr,vexento_isr char(1);
define v_pag_int_canc,v_cal_int_chq,v_pagint char(1);
define vtip_per char(2);
define vcod,vcodret char(5);
define vsuc_cta char(4);
define vtasa char(8);
define v_plaza char(3);
define v_producto char(4);
define v_moneda,v_long_cta char(2);
define vnum_cte char(20);
define vcuenta char(20);
define vvalor_tasa decimal(9,6);
define vacum_sdo_pos ,vsdo_actual,vsdo_retenido,vsdo_cong,v_mtopag,
       vsdo_prom,vmto_min_isr,vtot_int,visr,vtot_canc money(14,2);
define vdia_sdo_pos,longitud smallint;
define sql_err integer;
define hoy date;


-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************
let vsdo_prom = 0;
let vvalor_tasa = 0;
let vsdo_actual = 0;
let vtot_int = 0;
let visr = 0;
let vtot_canc = 0;
let vcodret = "000";

begin
on exception set sql_err
   if sql_err <> 0 then
      let vcodret = sql_err;
      return vcodret,vsdo_prom,vvalor_tasa,vsdo_actual,vtot_int,
          visr,vtot_canc,vsuc_cta,v_moneda;
   end if;
end exception;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

select mc.cuenta,sucursal,mc.plaza,mc.producto,num_cte,
       dia_sdo_pos,acum_sdo_pos,sdo_actual,status_cta,sdo_retenido,sdo_cong,
       pr.divisa,mc.cobraisr 
   into vcuenta,vsuc_cta,v_plaza,v_producto,vnum_cte,vdia_sdo_pos,
        vacum_sdo_pos,vsdo_actual,vstatus_cta,vsdo_retenido,
        vsdo_cong,v_moneda,vcobraisr
   from sc_maechq mc,sc_maenoc mn,sc_producto pr
   where mc.empresa = pempresa and mc.cuenta = pcta_chq and
         mn.empresa = mc.empresa and mn.cuenta = mc.cuenta and
         mc.empresa = pr.empresa and mc.producto = pr.producto;   

if vcuenta is null then
   let vcodret = "100";
   return vcodret,vsdo_prom,vvalor_tasa,vsdo_actual,vtot_int,
          visr,vtot_canc,vsuc_cta,v_moneda;
end if

-- *****************************************************************************
-- Asignacion de Variables
-- *****************************************************************************

      select valor into v_pag_int_canc
         from sc_param
         where empresa = pempresa and descripcion = "pagintcancta";

      select fecha_hoy into hoy from sc_fechas where empresa = pempresa;

-- Determina si el Producto paga intereses
      select paga_interes,mto_pag_int,tasa into v_pagint,v_mtopag,vtasa
         from sc_producto
         where empresa = pempresa and producto = v_producto;

-- Determina el Saldo Promedio de la cuenta
      if vdia_sdo_pos > 0 then
         let vsdo_prom = vacum_sdo_pos / vdia_sdo_pos;
      else
         let vsdo_prom = 0;
      end if

-- Determina el tipo de persona
   select tpo_persona into vtip_per
      from bdinteg:si_cliente where numcte = vnum_cte;
	  
   select es_fisica,exento_isr into vfisica,vexento_isr
      from bdinteg:si_tipper where tpo_persona = vtip_per;
  
  if vfisica = "S" then
      let vtip_per = "F ";
   else
      let vtip_per = "M ";
   end if
      
    IF vexento_isr  NOT IN ("N","S") THEN 
       IF vcobraisr <> "" then
           IF vcobraisr = "S" then
              let vexento_isr = "N";
           ELSE
              let vexento_isr = "S";
           END IF
        END IF
	END IF  
	 
   if v_pag_int_canc = "S" and v_pagint = "S" and vsdo_prom >= v_mtopag then
      call calc_tasa(pempresa,vtasa,vtip_per,vsdo_prom)
           returning vcod,vvalor_tasa;
      if vcod = "000" then
         let vtot_int = vacum_sdo_pos * vvalor_tasa / 100 / 360;

         -- Verificar el sdo promedio para si/no retener ISR
         if vexento_isr = "N" then        
            call calc_isr(pempresa,pcta_chq,hoy,vvalor_tasa,vtot_int,
                          vsdo_prom,vdia_sdo_pos,vfisica)
                 returning vcod,visr;
         end if
      end if
   end if

let vtot_canc = vsdo_actual + vtot_int - visr;

return vcodret,vsdo_prom,vvalor_tasa,vsdo_actual,vtot_int,
       visr,vtot_canc,vsuc_cta,v_moneda;
end
end procedure;