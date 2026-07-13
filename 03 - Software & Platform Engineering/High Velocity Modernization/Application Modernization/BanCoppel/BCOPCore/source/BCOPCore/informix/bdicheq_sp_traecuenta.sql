create procedure "informix".sp_traecuenta( pempresa char(3),
                                           pcliente  char(20),
                                           ptipo char(1) )
returning char(5),   -- vcodret
          char(20),  -- vcuenta
          char(15);  -- pcliente

    -- ********************************************************************
    -- Nombre:              sp_traecuenta
    -- Version              1.0.0
    -- Objetivo:            Consulta de Cuentas de cheque por Cliente
    -- SI es tipo = 1, consulta por el Cliente;  Si es tipo=2, Consulta por
    -- el Numero de Cuenta.
    -- Creado por:          Jaime Santiago
    -- Modificado por:      Alejandro Rueda
    -- Fecha:               Febrero 2010
    -- ********************************************************************

    -- // Definicion de variables
    DEFINE vcodret         char(5);
    DEFINE vsqlerr         integer;
    DEFINE vcuenta         char(20);
    DEFINE pcliente2       char(20); 
    
    LET vcodret      = "000";
    LET vsqlerr      = 0;

    -- SET DEBUG FILE TO "/tmp/sp_traecuenta.out";
    -- TRACE ON;
    
    BEGIN
    
    on exception set vsqlerr
        IF vsqlerr <> 0 then
            LET vcodret = vsqlerr;
            return vcodret,null,null;
        END IF;
    END exception;
    
    --//Si la opcion es 2, buscamos el Numero del Cliente.
    IF ptipo = 2 THEN
        LET pcliente2 = pcliente;
        LET pcliente = " ";  
        
        SELECT distinct num_cte
          INTO pcliente
          FROM bdicheq:sc_maechq
         WHERE num_cte = pcliente2;
         
        IF pcliente = "" OR pcliente IS NULL THEN
            LET vcodret  = "104"; --//No existe el nuemro de cliente
            return vcodret, "", pcliente ;
        END IF
        
    --//Si la opcion es 3, buscamos el Numero del Cliente x la cuenta.
    ELIF ptipo = 3 THEN
        LET pcliente2 = pcliente;
        LET pcliente = " ";  
        
        SELECT distinct num_cte
          INTO pcliente
          FROM bdicheq:sc_maechq
         WHERE cuenta = pcliente2;
    END IF 

    -- CONSULTA QUE DEVUELVE LAS CUENTAS DE CHEQUES DE EL CLIENTE SELECCIONADO.
    LET vcuenta = "";
    
    FOREACH
        SELECT cuenta
          INTO vcuenta
          FROM bdicheq:sc_maechq mae, 
               bdicheq:sc_producto prod 
         WHERE mae.num_cte = pcliente
           AND mae.producto = prod.producto
           AND mae.status_cta NOT IN('2','6','7','8')
           AND prod.val_chequeras = 'S'
         ORDER BY cuenta
         
        return vcodret, vcuenta, pcliente with resume;
    END FOREACH;

    IF vcuenta = "" OR vcuenta IS NULL THEN
        LET vcodret = "995"; --//cliente no tiene cuenta con chequeras
        return vcodret, "", pcliente;
    END IF;

    END
    
END procedure;