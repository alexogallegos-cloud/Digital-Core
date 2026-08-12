Create Procedure "informix".sp_validadatostempnomina_bpi(cEmpresa Char(3), dFecha_gen date, iFolio Integer)
RETURNING CHAR(3), Char(16);

-------------------------------------------------------------------------------------------------------
--Realizó: Jose Ruben Lopez
--Solicito:Jorge Nuñez
--Fecha: 28/06/2013
--Actividad:Se manejo excepcion para cuando se repita el empleado
--BD: bdicheq
-------------------------------------------------------------------------------------------------------

--Declaracion de variables
Define cCodRet            	    	Char(3);
Define cNumeroFolio       	    	Char(16) ;
Define cEstatus		     	    	Char(1);
Define cNomArcEnc         	    	Char(17);
Define cNomArcDet         	    	Char(17);
Define iTotalRegEnc       	    	Integer ;
Define iTotalRegDet       	    	Integer ;
Define mImpTotEnc         	    	Money(14,2);
Define mImpTotDet         	    	Money(14,2);
Define cNumEmpEnc         	    	Char(10);
Define cNumEmpDet                   Char(10);
Define cCuentaEje                   Char(20);
Define dFechaActual                 Date;
Define dFechaAplicacion             Date;
Define cEstatusCuenta     	    	Char(1);
Define iRegNegativos          	    Integer ;
Define cNombreArchivoSinExtension   Char(20);
Define cdirectorioArchivo1    	    Char(800);
Define cdirectorioArchivo2    	    Char(800);
Define cdirectorioArchivo3   	    Char(800);
Define creaArch              	    Char(800);
Define iTipoEmpresa           	    Integer;
Define vSqlErr, vIsamErr      	    Integer;
Define siValorConcepto          	smallint;
Define cCargo						Char(1);
Define cMotivo						Char(2);
DEFINE iExiste                      INTEGER;
DEFINE iAceptab                     INTEGER;
DEFINE vValida                      INTEGER;

--Inicializacion de Variables
Let cCodRet  = "000";
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
LET iExiste = 0;
LET iAceptab = 0;
LET vValida = 0;
--*********************************************
--SET DEBUG FILE TO "/home/informix/ivonne/sp_validadatostempnomina_bpi.out";
--TRACE ON;
--*********************************************
Set Isolation Dirty Read;

   Begin

    ON EXCEPTION SET vSqlErr, vIsamErr
		ROLLBACK WORK;
		IF vSqlErr != 0 THEN
				LET cCodRet = vSqlErr;
				RETURN cCodRet, cNumeroFolio;
		END IF;
    END EXCEPTION;
	ON EXCEPTION IN (-239)--SE REPITE EL EMPLEADO
		ROLLBACK WORK;
		delete bdicheq:"informix".sc_nominaencabezadosumario_bpi where empresa=cEmpresa and folio_archivo=iFolio and fecha_gen=dFecha_gen; 
		delete bdibpi:"informix".bpi_dispersarchivo where nombre_archivo=cNomArcEnc and id_empresa=cEmpresa;
		delete bdicheq:"informix".sc_nominamovimientos_bpi where nombre_archivo=cNomArcEnc;
		
		delete bdicheq:"informix".sc_NominaArchTemp;
		delete bdicheq:"informix".sc_nominaencabezadosumariotemp where nombre_archivo=cNomArcEnc;
		delete bdicheq:"informix".sc_nominamovimientostemp where nombre_archivo=cNomArcEnc;
		Let cCodRet = '551';
		RETURN cCodRet, cNumeroFolio;
	END EXCEPTION;
	ON EXCEPTION IN (-1207)
		ROLLBACK WORK;
		Let cCodRet = '550';
		RETURN cCodRet, cNumeroFolio;
	END EXCEPTION WITH RESUME;

	ON EXCEPTION IN (-100)
		
		ROLLBACK WORK;
		delete bdicheq:"informix".sc_nominaencabezadosumario_bpi where empresa=cEmpresa and folio_archivo=iFolio and fecha_gen=dFecha_gen; 
		delete bdibpi:"informix".bpi_dispersarchivo where nombre_archivo=cNomArcEnc and id_empresa=cEmpresa;
		delete bdicheq:"informix".sc_nominamovimientos_bpi where nombre_archivo=cNomArcEnc;
		
		delete bdicheq:"informix".sc_NominaArchTemp;
		delete bdicheq:"informix".sc_nominaencabezadosumariotemp where nombre_archivo=cNomArcEnc;
		delete bdicheq:"informix".sc_nominamovimientostemp where nombre_archivo=cNomArcEnc;
		Let cCodRet = '551';
		RETURN cCodRet, cNumeroFolio;
	END EXCEPTION;
    BEGIN WORK;
	
    --Busco los datos en las tablas temporales
    -- If Not Exists (Select nombre_archivo From bdicheq:"informix".sc_nominaencabezadosumariotemp
                    -- Where empresa = cEmpresa And fecha_gen = dFecha_gen And folio_archivo = iFolio ) Then
        -- Let cCodRet = "600";   --No Existen los Datos en la Tabla Temporal del Encabaezado
        -- ROLLBACK WORK;
        -- Return cCodRet, cNumeroFolio;
    -- End If
	
	 --Busco los datos en las tablas temporales
	SELECT COUNT(*) 
	INTO   vValida
	FROM   bdicheq:"informix".sc_nominaencabezadosumariotemp
    WHERE  empresa       = cEmpresa 
	AND    fecha_gen     = dFecha_gen  
	AND    folio_archivo = iFolio;
	
	IF  vValida = 0 THEN 
	    LET cCodRet = "600";   --No Existen los Datos en la Tabla Temporal del Encabaezado
        ROLLBACK WORK;
        RETURN cCodRet, cNumeroFolio;
    END IF
	
	
    Select empresa, nombre_archivo, cuenta_cargo, fecha_aplicacion, total_registros, importe_tot
    Into cNumEmpEnc, cNomArcEnc, cCuentaEje, dFechaAplicacion, iTotalRegEnc, mImpTotEnc
    From bdicheq:"informix".sc_nominaencabezadosumariotemp where empresa = cEmpresa And fecha_gen = dFecha_gen And folio_archivo = iFolio;

    --Obtengo el tipo empresa. 1-Externa, 2-Interna
    Select tipo_empresa into iTipoEmpresa from bdicheq:"informix".sc_nominaempresas where codigo = cNumEmpEnc;

    Select Limit 1 concepto Into  siValorConcepto
    From bdicheq:"informix".sc_nominamovimientostemp
    Where nombre_archivo = cNomArcEnc  ;

    /* Cambio Validacion para que si la empresa es interna pero tiene un
    concepto diferente a nomina se tome como externa para el cobro de impuestos */


        if (iTipoEmpresa = 2) and (siValorConcepto <> 1) and (siValorConcepto <> 5) then
                    Let iTipoEmpresa= 1;
    end if

        --Valida cuenta eje si empresa es Externa ó si es Externa-Externa
    If iTipoEmpresa <> 2 Then
        
		/* If Not Exists (Select cuenta From bdicheq:"informix".sc_maechq Where empresa = '001' And cuenta = cCuentaEje) Then
            Let cCodRet  = "100"; --La cuenta NO Existe en la Base de Datos
            ROLLBACK WORK;
            RETURN cCodRet, cNumeroFolio;
			 */
		
		LET vValida = 0;
		
		SELECT COUNT(*) 
        INTO   vValida	
		FROM   bdicheq:"informix".sc_maechq 
		WHERE  empresa = '001' 
		AND    cuenta = cCuentaEje;
		
	    IF vValida = 0 THEN 
		   LET cCodRet  = "100"; --La cuenta NO Existe en la Base de Datos
           ROLLBACK WORK;
           RETURN cCodRet, cNumeroFolio;
        Else
            Select status_cta,motivo Into cEstatusCuenta,cMotivo From bdicheq:"informix".sc_maechq
            Where empresa = '001' And cuenta = cCuentaEje;

            If    cEstatusCuenta = '2' Then   --La Cuenta esta Cancelada
                  Let cCodRet = "100";
                  ROLLBACK WORK;
                  Return cCodRet, cNumeroFolio;
				  
            ELIF  cEstatusCuenta = '3' Then   --La Cuenta esta Bloqueada
			      SELECT "1" ,    opcion
                  INTO   iExiste, iAceptab 
                  FROM   bdicheq:sc_ctabloqueo 
                  WHERE  cuenta = cCuentaEje;
				  
                  IF  iExiste = "1" THEN				  
                      IF iAceptab  IN("3","4") THEN
                         LET cCodRet = "820";
				  	     ROLLBACK WORK;
				  	     RETURN cCodRet, cNumeroFolio;
                      END IF;
                  ELSE
				      SELECT cargo 
				      INTO   cCargo 
				      FROM   bdicheq:"informix".sc_bloqueo 
				      WHERE  codigo = cMotivo;
                      
				      IF  cCargo = 'N' THEN
                          LET cCodRet = "820";
                          ROLLBACK WORK;
                          RETURN cCodRet, cNumeroFolio;
                      END IF;	
                  END IF;
            END IF;	
        END IF;
    END IF;

    Select fecha_hoy Into dFechaActual From bdicheq:"informix".sc_fechas Where empresa = '001';
    If dFechaAplicacion < dFechaActual Then
        Let cCodRet  = "150"; --La Fecha de Aplicacion es menor a la fecha Actual
        ROLLBACK WORK;
        RETURN cCodRet, cNumeroFolio;
    End If

    Select NVL(status, '') Into cEstatus From bdicheq:"informix".sc_nominaencabezadosumario_bpi
    Where empresa = cEmpresa And fecha_gen = dFecha_gen And folio_archivo = iFolio;

    If cEstatus = '1' Then
        Let cCodRet  = "200"; --Archivo ya fue Validado Pero No Procesado
        ROLLBACK WORK;
        RETURN cCodRet, cNumeroFolio;
    Elif cEstatus In ('2', '3') Then
        Let cCodRet  = "250"; --Archivo ya fue procesado
        ROLLBACK WORK;
        RETURN cCodRet, cNumeroFolio;
    End If

    --VALIDACIONES DE LOS DATOS DE LAS TABLAS TEMPORALES
    --Let cNomArcEnc = (trim(cEmpresa) || lpad(year(dFecha_gen),4,0) || lpad(Month(dFecha_gen),2,0) || lpad(day(dFecha_gen),2,0) || lpad(iFolio,2,0));
    /*     If Not Exists (Select distinct(nombre_archivo) From bdicheq:"informix".sc_nominamovimientostemp Where nombre_archivo = cNomArcEnc ) Then
        Let cCodRet = "550";   --Existe el Encabezado pero No Existen los Movimientos (El Detalle)
        ROLLBACK WORK;
        Return cCodRet, cNumeroFolio;
		 */
    LET vValida = 0;

	SELECT COUNT(*)
	INTO   vValida
	FROM   bdicheq:"informix".sc_nominamovimientostemp 
	WHERE  nombre_archivo = cNomArcEnc;
		
		
	IF  vValida = 0 THEN 
	    LET cCodRet = "550"; --Existe el Encabezado pero No Existen los Movimientos (El Detalle)
	    ROLLBACK WORK;
        RETURN cCodRet, cNumeroFolio;
	END IF;

    --Validacion del Nombre del Archivo,Numero de Registros, Importe, Numero de la EmpresA
    Select Count(*), Sum(importe), substr(nombre_archivo,1,3), nombre_archivo
    Into iTotalRegDet, mImpTotDet, cNumEmpDet, cNomArcDet
    From bdicheq:"informix".sc_nominamovimientostemp
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


    --Validacion de Rojos (- negativos)
    Select Count(importe) into iRegNegativos From bdicheq:"informix".sc_nominamovimientostemp Where importe < 0;
    If iRegNegativos > 0 Then
        Let cCodRet = '400';   --Importes totales no coinciden o saldos negativos
        ROLLBACK WORK;
        Return cCodRet, cNumeroFolio;
    End If

    --Se manda ejecutar el sp del genera folio
    Call sp_generafolionomina("informix") Returning  cCodRet,  cNumeroFolio;

    --Aqui se hacen los Inserts Macivos a las tablas
    Insert Into bdicheq:sc_nominaencabezadosumario_bpi (empresa, fecha_gen, folio_archivo, nombre_archivo, sentido, cuenta_cargo, fecha_aplicacion, total_registros, importe_tot, status, fecha_insert, folio_acuserecibo)
        Select empresa, fecha_gen, folio_archivo, nombre_archivo, sentido, cuenta_cargo, fecha_aplicacion, total_registros, (importe_tot / 100), '1', dFechaActual, cNumeroFolio
        From bdicheq:"informix".sc_nominaencabezadosumariotemp
        Where empresa = cEmpresa And fecha_gen = dFecha_gen And folio_archivo = iFolio;

    Insert Into bdicheq:sc_nominamovimientos_bpi (nombre_archivo, num_empleado, apell_paterno, apell_materno, nombres, cuenta_abono, importe, concepto, status)
        Select nombre_archivo, num_empleado, apell_paterno, apell_materno, nombres, cuenta_abono, (importe / 100), concepto, '0'
        From bdicheq:"informix".sc_nominamovimientostemp
        Where nombre_archivo = cNomArcDet;

    --Borro los Registros de las Tablas Temporales
    Delete from bdicheq:"informix".sc_nominamovimientostemp Where nombre_archivo = cNomArcDet;
    Delete from bdicheq:"informix".sc_nominaencabezadosumariotemp Where empresa = cEmpresa And fecha_gen = dFecha_gen And folio_archivo = iFolio;

    --Extraigo el nombre del archivo sin la extension
    Let cNombreArchivoSinExtension = SubString(Trim(cNomArcEnc) From 1 For 13);

    --Comando Para Crear Archivos (rm -f NombreArchivo.ext)
    --Comando Para Eliminar Archivos  (rm -rf NombreArchivo.ext)

    Let cdirectorioArchivo1 = "rm -rf /resplogifx/conciliachq/nominaempresanet/" || Trim(cNomArcEnc);
    SYSTEM cdirectorioArchivo1;

    Let cdirectorioArchivo2 = "rm -rf /resplogifx/conciliachq/nominaempresanet/" || Trim(cNombreArchivoSinExtension) || "enc_sum.txt";
    SYSTEM cdirectorioArchivo2;

    Let cdirectorioArchivo3 = "rm -rf /resplogifx/conciliachq/nominaempresanet/" || Trim(cNombreArchivoSinExtension) || "mov.txt";
    SYSTEM cdirectorioArchivo3;

    COMMIT WORK;
    Return cCodRet, cNumeroFolio;
End
End Procedure;