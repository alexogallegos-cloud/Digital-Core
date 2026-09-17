Create Procedure "informix".sp_nominatotalivacomision_bpi( cNombreArchivo           Char(17),
                                                       mValorIva                Money(14,2),
                                                       mValorComisionDispercion Money(14,2) )
Returning Char(3),
          Char(100),
          Money(14,3),
          Money(14,3),
          Money(14,3),
          Money(14,3),
          Money(14,3);

    --- Realizo   : Martín Valenzuela Ojeda
    --- Proyecto  : Dispercion Nomina BanCoppel
    --- Actividad : Calcula el Total del Iva y de la Comision de Disperción para todos los Empleados que hayan sido Aplicados (status = 1,3)
    --- Fecha     : Abril-2008

	DEFINE GLOBAL mtotalregspei         INTEGER		DEFAULT 0;
    Define mImporteTotalAplicado        Money(14,3);
    Define cCodRet                      Char(3);
    Define cMensaje                     Char(100);
    Define iNumeroRegistrosAplicados    Integer ;
    Define mTotaliva                    Money(14,3);
    Define mTotalComision               Money(14,3);
    Define mTotalPagado                 Money(14,3);
    Define mTotalCargo                  Money(14,3);
    Define mTotalNoPagado			    Money(14,3);
    DEFINE  vsqlerr                     Integer ;

    Let cCodRet = '000';
    Let cMensaje = "";
    Let mImporteTotalAplicado = 0;
    Let iNumeroRegistrosAplicados = 0;
    Let mTotaliva = 0;
    Let mTotalComision = 0;
    Let mTotalPagado = 0;
    Let mTotalCargo = 0;
    Let mTotalNoPagado = 0;

    --Set debug file to "informix/dmr2/sp_nominatotalivacomision.out";
    --Trace on;

    Begin

    ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            Let cCodRet = vsqlerr;
            Let cMensaje  = "Error Marcado Por Informix";
            Return cCodRet, cMensaje, null, null, null, null, null;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    If (Trim(cNombreArchivo) <> "") And (mValorIva is not Null Or mValorComisionDispercion is not Null ) Then
        Select {+INDEX(bdicheq:sc_nominamovimientos_bpi idx_nominamovimientos_bpi2)}
               NVL(Count(*),0)
          Into iNumeroRegistrosAplicados
          From bdicheq:sc_nominamovimientos_bpi
         Where nombre_archivo = cNombreArchivo
           And (status = '1' Or status = '3');  /* El valor 1 es de Aplicados y el 3 de Cuentas Bloqueadas */

        --- Let mTotaliva = iNumeroRegistrosAplicados * mValorIva;
        --- Let mTotalComision = iNumeroRegistrosAplicados * mValorComisionDispercion;
		
		IF iNumeroRegistrosAplicados > mtotalregspei THEN 
		   LET iNumeroRegistrosAplicados = iNumeroRegistrosAplicados - mtotalregspei;
		ELSE
		   LET iNumeroRegistrosAplicados = 0;
		END IF;

        Let mTotalComision = iNumeroRegistrosAplicados * mValorComisionDispercion;
        Let mTotaliva = mTotalComision * mValorIva; /* Nueva Forma de Calcular el Iva */
        Let cMensaje = "Calculos de Iva y Comision Efectuados Correctamente";

        /* Se saca el importe abonado a cuentas */
        Select {+INDEX(bdicheq:sc_nominamovimientos_bpi idx_nominamovimientos_bpi2)}
               NVL(sum(importe),0)
          Into mTotalPagado
          From bdicheq:sc_nominamovimientos_bpi
         Where nombre_archivo = cNombreArchivo
           And status = '1';

        /* Se saca el importe No abonado a cuentas */
        Select {+INDEX(bdicheq:sc_nominamovimientos_bpi idx_nominamovimientos_bpi2)}
               NVL(sum(importe),0)
          Into mTotalNoPagado
          From bdicheq:sc_nominamovimientos_bpi
         Where nombre_archivo = cNombreArchivo
           And status > '1';

        /* Se saca el cargo total, para evaluar el saldo */
        Let mTotalCargo = mTotalPagado + mTotalComision + mTotaliva;
    Else
        Let cCodRet = '170';
        Let cMensaje = "Error: Nombre de Archivo No Valido";
        Let mTotaliva = 0;
        Let mTotalComision = 0;

        Return cCodRet, cMensaje, mTotaliva, mTotalComision, mTotalPagado, mTotalNoPagado, mTotalCargo;
    End If

    Return cCodRet, cMensaje, mTotaliva, mTotalComision, mTotalPagado, mTotalNoPagado, mTotalCargo;

    End

End Procedure;