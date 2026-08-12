CREATE PROCEDURE "informix".sp_dias_vencido(pempresa char (3), pnum_credito char(20))
	returning char(6), Integer;
---bdicred
--10-10-2008
--Creado por:
--Juan Andres
--Obtener dias de vencido de un credito

--17-10-2008
--Modifico:
--Abraham Ayala
--No se antepuso la base de datos a la que corresponden las tablas de los select

--24-06-2009
--Modifico: Lorenzo Ibarra Garcia
--Se eliminó la condición de si la fecha de vencido es null para que regrese un código
--de retorno "000" con 0 dias de vencido y no un código "002" como se venia haciendo.

--11-12-2009
--Modifico: Walber Castro
--Se cambió el tipo de dato de la variable iDiasVenc de smallint a integer

	define dFecha_Hoy       date;
	define dFecha_Venc      date;
	define iDiasVenc        Integer;
	define sCodRet          char(6);
	define isql_err         Integer;

	--Set debug file to '/tmp/sp_dias_vencidos.out';
	--trace on;

	Begin
	    On Exception set isql_err
	        Let sCodRet = isql_err;
	        return sCodRet, 0;
	    End Exception;

	    Let sCodRet = '000';
	    Let iDiasVenc = 0;

	    Select fecha_hoy
	    Into dFecha_Hoy
	    From bdicred:sd_fechas
	    Where empresa = pempresa;

	    select fecha_vencto
	    Into dFecha_Venc
	    From bdicred:sd_maecredanexo
	    Where empresa     = pempresa  and
	          num_credito = pnum_credito;

	    If not dFecha_Venc is null then
	        Let iDiasVenc = dFecha_Hoy - dFecha_Venc;
	    end if
        
	    return sCodRet , iDiasVenc;
	End;
End procedure;