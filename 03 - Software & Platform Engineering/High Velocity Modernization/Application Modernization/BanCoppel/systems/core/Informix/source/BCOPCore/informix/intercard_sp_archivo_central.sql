CREATE PROCEDURE "informix".sp_archivo_central(pArchivoOrigen char(3))
        returning integer, integer, integer, integer, char(3), char(8);


--****************************************************************************************************
-- DESCRIPCION: CREA UN ARCHIVO CON LOS REGISTROS  GENERADOS POR LA CONCILIACION ( TMC, TMD, VNC, VND, VIC, VID, TCC, TCD )
-- AUTOR : Mauricio Leon
-- FECHA : 08/01/2008
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard
-- MODIFICADO : 01/04/2008   --ZERO 
--***************************************************************************************************


define vcodret integer ;
define vTipoConc integer ;
define vTipoMovA integer ;
define vTipoMovC integer ;
define vTipoMovR integer ;
define sql_err integer ;
define vsql char(710);
define vTipo char(3);
define vSucursal char(3);
define vUsuario char(8);

DEFINE vdtFechaConciliacion DATETIME YEAR TO FRACTION ;

LET vdtFechaConciliacion = CURRENT ;

Let vSucursal = "";
Let vcodret =0;
Let vTipoConc = 0;
Let vTipoMovA =0;
Let vTipoMovC =0;
Let vTipoMovR =0;
Let vsql = '';
Let vTipo = "";
Let vUsuario = "";

-- Fecha: 18/12/2007
-- Descarga la tabla central en archivo .txt

Begin

	on exception set sql_err
		if sql_err <> 0 then
			let vcodret = sql_err;
			return vcodret, vTipoMovA, vTipoMovC, vTipoMovR, vSucursal, vUsuario;
		end if;
	end exception;

    let vsql = '';
    let vsql = 'rm -f /tmp/conciliacion/*';
    SYSTEM vsql;
    let vsql = '';

    IF pArchivoOrigen = "VNC" OR pArchivoOrigen = "VND" OR pArchivoOrigen = "VIC" OR pArchivoOrigen = "VID" OR pArchivoOrigen = "PNC" OR  pArchivoOrigen = "TCC" OR pArchivoOrigen = "TCD" THEN
        let vTipoConc = 1;
        let vTipo = 'POS';
    ELIF pArchivoOrigen = "TMC" OR pArchivoOrigen = "TMD" OR pArchivoOrigen = "TMP" THEN
        let vTipoConc = 2;
    ELSE
        let vTipoConc = 3;
    END IF;


    IF vTipoConc = 1 OR vTipoConc = 2 THEN

        SET LOCK MODE TO WAIT  ;
        SET ISOLATION TO DIRTY READ ;
        SELECT Sucursal, Usuario INTO vSucursal, vUsuario FROM Parametros;

        IF vTipoConc = 1 AND (vSucursal IS NULL OR Trim(vSucursal) = "" OR vUsuario IS NULL OR Trim(vUsuario) = "") THEN
            let vcodret = 4;
            Return vcodret, vTipoMovA, vTipoMovC, vTipoMovR, vSucursal, vUsuario;
        ELIF vTipoConc = 2 AND (vSucursal IS NULL OR Trim(vSucursal) = "" OR vUsuario IS NULL OR Trim(vUsuario) = "") THEN
            let vcodret = 5;
            Return vcodret, vTipoMovA, vTipoMovC, vTipoMovR, vSucursal, vUsuario;
        END IF ;

        SET LOCK MODE TO WAIT  ;
        SET ISOLATION TO DIRTY READ ;
        SELECT MAX(FechaConciliacion) INTO vdtFechaConciliacion  FROM Central WHERE ArchivoOrigen = pArchivoOrigen ;          

        SET LOCK MODE TO WAIT  ;
        SET ISOLATION TO DIRTY READ ;
        SELECT COUNT( tipomov ) INTO vTipoMovA FROM central  WHERE tipomov = 'A'  AND fechaconciliacion = vdtFechaConciliacion AND CAST(TO_CHAR(fechaconciliacion, '%Y%m%d') as char(8)) LIKE '' || CAST(TO_CHAR(current, '%Y%m%d') as char(8)) || '%' AND ArchivoOrigen = pArchivoOrigen;

        SET LOCK MODE TO WAIT  ;
        SET ISOLATION TO DIRTY READ ;
        SELECT COUNT( tipomov ) INTO vTipoMovC FROM central  WHERE tipomov = 'C'  AND fechaconciliacion = vdtFechaConciliacion AND CAST(TO_CHAR(fechaconciliacion, '%Y%m%d') as char(8)) LIKE '' || CAST(TO_CHAR(current, '%Y%m%d') as char(8)) || '%' AND ArchivoOrigen = pArchivoOrigen;

        SET LOCK MODE TO WAIT  ;
        SET ISOLATION TO DIRTY READ ;
        SELECT COUNT( tipomov ) INTO vTipoMovR FROM central  WHERE tipomov = 'R'  AND fechaconciliacion = vdtFechaConciliacion AND CAST(TO_CHAR(fechaconciliacion, '%Y%m%d') as char(8)) LIKE '' || CAST(TO_CHAR(current, '%Y%m%d') as char(8)) || '%' AND ArchivoOrigen = pArchivoOrigen;


    END IF ;


    IF vTipoConc = 1  THEN --POS
          
        
          -- ley de transparencia
          let vsql = 'echo "UNLOAD TO ' || '''/tmp/conciliacion/CON' || vTipo || '_' || pArchivoOrigen || '_' || CAST(TO_CHAR(current, '%d%m%Y') as char(8)) || '.txt''' || ' DELIMITER ' || '''|'''  || ' SELECT Ident_det, TipoMov, transaccion, Sucursal, folioSucursal, NumTarjeta, Documento, Importe, Moneda, Referencia, FolioOrig, DoctoOrig, TransaccionOrig, MontoOriginal, RFC, RefTransaccion, Divisa, MontoDivisa, NumCajero, TipoTransInterEmpresa, Convenio, MontoComInterEmpresa, FormadePago, Control FROM central WHERE fechaconciliacion = ''' || vdtFechaConciliacion || ''' AND CAST(TO_CHAR(fechaconciliacion, ''%Y%m%d'') as char(8)) LIKE ''' || CAST(TO_CHAR(current, '%Y%m%d') as char(8)) || '%'' AND ArchivoOrigen = ''' || pArchivoOrigen || '''" > /tmp/conciliacion/cargaarchivocentral.sql' ;
          --let vsql = 'echo "UNLOAD TO ' || '''/tmp/conciliacion/CON' || vTipo || '_' || pArchivoOrigen || '_' || CAST(TO_CHAR(current, '%d%m%Y') as char(8)) || '.txt''' || ' DELIMITER ' || '''|'''  || ' SELECT Ident_det, TipoMov, transaccion, Sucursal, folioSucursal, NumTarjeta, Documento, Importe, Moneda, Referencia, FolioOrig, DoctoOrig, TransaccionOrig, MontoOriginal, RFC, RefTransaccion, 0 FROM central WHERE fechaconciliacion = ''' || vdtFechaConciliacion || ''' AND CAST(TO_CHAR(fechaconciliacion, ''%Y%m%d'') as char(8)) LIKE ''' || CAST(TO_CHAR(current, '%Y%m%d') as char(8)) || '%'' AND ArchivoOrigen = ''' || pArchivoOrigen || '''" > /tmp/conciliacion/cargaarchivocentral.sql' ;

          SYSTEM vsql;

         let vsql = '';
         let vsql = 'dbaccess intercard /tmp/conciliacion/cargaarchivocentral.sql';
         SYSTEM vsql;

         let vcodret = 1;

    ELIF vTipoConc = 2  THEN --ATM

        -- ley de transparencia
         let vsql = 'echo "UNLOAD TO ' || '''/tmp/conciliacion/CONA' || pArchivoOrigen || '_' || CAST(TO_CHAR(current, '%d%m%Y') as char(8)) || '.txt''' || ' DELIMITER ' || '''|''' || ' SELECT Ident_det, TipoMov, transaccion, Sucursal, folioSucursal, NumTarjeta, Documento, Importe, Moneda, Referencia, FolioOrig, DoctoOrig, TransaccionOrig, MontoOriginal, RFC, RefTransaccion, Divisa, MontoDivisa, NumCajero, TipoTransInterEmpresa, Convenio, MontoComInterEmpresa, FormadePago, Control FROM central WHERE fechaconciliacion = ''' || vdtFechaConciliacion || ''' AND CAST(TO_CHAR(fechaconciliacion, ''%Y%m%d'') as char(8)) LIKE ''' || CAST(TO_CHAR(current, '%Y%m%d') as char(8)) || '%'' AND ArchivoOrigen = ''' || pArchivoOrigen || '''" > /tmp/conciliacion/cargaarchivocentral.sql';
         --let vsql = 'echo "UNLOAD TO ' || '''/tmp/conciliacion/CONA' || pArchivoOrigen || '_' || CAST(TO_CHAR(current, '%d%m%Y') as char(8)) || '.txt''' || ' DELIMITER ' || '''|''' || ' SELECT Ident_det, TipoMov, transaccion, Sucursal, folioSucursal, NumTarjeta, Documento, Importe, Moneda, Referencia, FolioOrig, DoctoOrig, TransaccionOrig, MontoOriginal, RFC, RefTransaccion, 0 FROM central WHERE fechaconciliacion = ''' || vdtFechaConciliacion || ''' AND CAST(TO_CHAR(fechaconciliacion, ''%Y%m%d'') as char(8)) LIKE ''' || CAST(TO_CHAR(current, '%Y%m%d') as char(8)) || '%'' AND ArchivoOrigen = ''' || pArchivoOrigen || '''" > /tmp/conciliacion/cargaarchivocentral.sql';


          SYSTEM vsql;

         let vsql = '';
         let vsql = 'dbaccess intercard /tmp/conciliacion/cargaarchivocentral.sql';
         SYSTEM vsql;

         let vcodret = 2;

    ELIF vTipoConc = 3  THEN

        let vcodret = 3;

    END IF ;
   
    Return vcodret, vTipoMovA, vTipoMovC, vTipoMovR, vSucursal, vUsuario;

end;
END PROCEDURE;