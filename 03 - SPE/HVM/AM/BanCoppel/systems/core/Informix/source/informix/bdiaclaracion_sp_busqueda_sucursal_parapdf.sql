CREATE PROCEDURE "informix".sp_busqueda_sucursal_parapdf(n_Sucursal CHAR(10))


 RETURNING  CHAR(11) AS numero_sucursal, CHAR(76) AS nombre_sucursal;
 
DEFINE resultado_nombre_sucursal        CHAR(75);
DEFINE resultado_numero_sucursal        CHAR(10);  


BEGIN
      

    SELECT suc.sucursal as numero, suc.nombre as nombre
    INTO resultado_numero_sucursal, resultado_nombre_sucursal

    FROM bdinteg:si_sucursales suc 

    WHERE suc.sucursal = n_Sucursal;                       

    return resultado_numero_sucursal || '*'  , resultado_nombre_sucursal;
END

end procedure;