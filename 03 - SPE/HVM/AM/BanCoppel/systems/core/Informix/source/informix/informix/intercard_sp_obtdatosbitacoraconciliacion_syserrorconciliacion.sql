CREATE PROCEDURE "informix".sp_obtdatosbitacoraconciliacion_syserrorconciliacion
(
psArchivoOrigen char(3),
psFechaInicial DateTime  year to fraction(5),
psFechaFinal DateTime  year to fraction(5)
)

--Regresa Valores
RETURNING Integer as codretorno, Datetime YEAR TO FRACTION (5)  AS FechaConciliacion, char(3) AS ArchivoOrigen, char(8) AS Usuario, char(25) AS Actividad, char(500) AS DescripcionError ;

--*******************************************************************************************************
-- Realizo   : Edgar Ivan Rochin Rocha
-- Proyecto : Conciliacion
-- Actividad : Obtiene Datos principales de las tablas bitacora_conciliacion y syserror_conciliacion
-- Fecha     : Agosto de 2008
--*******************************************************************************************************
--Define Variables
DEFINE vdFechaCon DateTime  year to fraction(5);
DEFINE vsArchivoO char(3);
DEFINE vsUsuario char(8) ;
DEFINE vsActividad char (25);
DEFINE vsDescripcionError char (500);
DEFINE visqlerr integer ;
DEFINE iCodRet Integer ;

--Inicializa Variables
LET vdFechaCon = CURRENT ;
LET vsArchivoO = '' ;
LET vsUsuario = '';
LET vsActividad = '' ;
LET vsDescripcionError = '';
LET visqlerr = 0;
LET iCodRet = 0;


BEGIN
--cacha el error en caso de que exista y regresa un valor predeterminado
ON EXCEPTION SET visqlerr
        IF visqlerr <> 0 THEN
            LET iCodRet = visqlerr;
            RETURN iCodRet, vdFechaCon, vsArchivoO,  vsUsuario, vsActividad, vsDescripcionError;

        END IF ;
    END EXCEPTION ;


IF(psFechaInicial = "") OR (psFechaInicial is null) THEN
    LET iCodRet = 1 ;
    RETURN iCodRet, vdFechaCon, vsArchivoO,  vsUsuario, vsActividad, vsDescripcionError;
END IF ;

IF (psFechaFinal = "") OR (psFechaFinal is null) THEN
    LET iCodRet = 2;
     RETURN iCodRet, vdFechaCon, vsArchivoO,  vsUsuario, vsActividad, vsDescripcionError;
END IF ;


IF (psArchivoOrigen = '')  Then

        SET ISOLATION TO DIRTY READ ;
        LET iCodRet = 0;
        ForEach
            SELECT bitacora.fechaconciliacion, bitacora.archivoorigen, bitacora.empleado, bitacora.actividad, error.descripcionerror
            INTO vdFechaCon, vsArchivoO,  vsUsuario, vsActividad, vsDescripcionError
            FROM intercard:bitacora_conciliacion AS bitacora
            INNER JOIN intercard:syserror_conciliacion AS error ON bitacora.keyx = error.keyx AND bitacora.flagerror = 'V'
            WHERE bitacora.FechaConciliacion >=  psFechaInicial  AND bitacora.FechaConciliacion <= psFechaFinal

            RETURN iCodRet, vdFechaCon, vsArchivoO,  vsUsuario, vsActividad, vsDescripcionError   WITH RESUME ;

        End ForEach
Else

        LET iCodRet = 0;
        ForEach
            SELECT bitacora.fechaconciliacion, bitacora.archivoorigen, bitacora.empleado, bitacora.actividad, error.descripcionerror
            INTO vdFechaCon, vsArchivoO,  vsUsuario, vsActividad, vsDescripcionError
            FROM intercard:bitacora_conciliacion AS bitacora
            INNER JOIN intercard:syserror_conciliacion AS error ON bitacora.keyx = error.keyx AND bitacora.flagerror = 'V'
            WHERE bitacora.ArchivoOrigen = psArchivoOrigen AND bitacora.FechaConciliacion >=  psFechaInicial  AND bitacora.FechaConciliacion <= psFechaFinal

            RETURN iCodRet, vdFechaCon, vsArchivoO,  vsUsuario, vsActividad, vsDescripcionError  WITH RESUME ;


        End ForEach

End If ;
END
END PROCEDURE ;