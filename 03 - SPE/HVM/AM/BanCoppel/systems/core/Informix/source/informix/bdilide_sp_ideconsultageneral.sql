CREATE PROCEDURE "informix".sp_ideconsultageneral(pNumeroCliente CHAR(20), pFechaDepositos CHAR(6), pFechaRecaudacion CHAR(6))

    -- DATOS A REGRESAR
    -- Jesus Montoya
    -- Modificó: Juan A Coronel - Junio 2008
    
	--*******************************************************************************************************
		-- Modifico   :Alejandro Osuna
		-- Actividad : Se modifico todas las variables money, se pasaron de (10,2) a (16,2)
		-- Fecha     : 07 de Enero de 2008
	--*******************************************************************************************************

    RETURNING
    CHAR(5),     -- Codigo de Retorno
    MONEY(16,2), -- Importe Excedente     -- imp_gravado
    MONEY(16,2), -- Impuesto Determindado -- imp_arecaudar
    MONEY(16,2), -- Imp recaudado         -- imp_recaudado
    MONEY(16,2), -- Imp pendiente         -- vImppendiente = imp_arecaudar - imp_recaudado
    MONEY(16,2), -- Imp Total Depositos   -- imp_acumulado
    MONEY(16,2); -- Imp Recaud Periodos Ant

    -- DEFINICION DE VARIABLES
    DEFINE vCodRet          CHAR(5);
    DEFINE vImpacumulado    MONEY(16,2);
    DEFINE vImprecaudado    MONEY(16,2);
    DEFINE vImppendiente    MONEY(16,2);
    DEFINE vImpperiodosant  MONEY(16,2);
    DEFINE vAno             CHAR(4);
    DEFINE vPorcentaje      CHAR(5);
    define vImpGravado      MONEY(16,2);
    define vImpaRecaudar    MONEY(16,2);
    define dDiaprimero      date;
    define dDiaUltimo       date;
    define AuxvCodRet       char(6);


    --INICIALIZACION DE VARIABLES--
    LET vCodRet = "000";
    LET vImpacumulado = 0;
    LET vImprecaudado = 0;
    LET vImppendiente = 0;
    LET vImpperiodosant = 0;
    LET vAno = 0;
    LET vPorcentaje = "";
    let vImpGravado    = 0;
    Let vImpaRecaudar  = 0;


    ForEach --Si la consulta no trae filas, las variables no se cargan quedan como estan inicializadas
        SELECT  nvl(imp_acumulado, 0), --nvl(imp_recaudado, 0), ( nvl(imp_arecaudar, 0) - nvl(imp_recaudado, 0) ),
                nvl(imp_gravado,0), nvl(imp_arecaudar,0)
        INTO vImpacumulado, --vImprecaudado,  vImppendiente, 
            vImpGravado, vImpaRecaudar
        FROM bdilide:sl_retlide
        WHERE num_cte = pNumeroCliente
        AND aniomes = pFechaDepositos
        --AND pendiente = 'S';
    End ForEach;

    -- SE OBTIENE EL IMPUESTO RECAUDADO DE LOS MESES ANTERIORES EN EL MES ACTUAL.
    -------------------------------------------------------------------------------
    -- Modificó: Anselmo Verdugo - Julio 2008
         
    SELECT nvl(SUM(imp_recaudado), 0)
    INTO vImpperiodosant
    FROM bdilide:sl_detlide
    WHERE CAST(TO_CHAR(fecha_ret, '%Y%m') as char(6))  = pFechaRecaudacion AND aniomes < pFechaRecaudacion AND num_cte = pNumeroCliente;

    ------------------------------------------------------------------------------

    execute procedure bdinteg:sp_diaprimeroultimomesanio(substr(pFechaRecaudacion, 5, 2), substr(pFechaRecaudacion, 1, 4) ) into AuxvCodRet, dDiaprimero, dDiaUltimo;
    If AuxvCodRet <> '000000' then
        Let vCodRet = '200'; --Error al calcular rangos de fechas
    End if;

    --Se obtiene el monto recaudado para los depositos del aniomes consultado, durante el periodo de recaudaciones consultado
    --Si no hay filas que sumar, devolverá cero como valor
    Select nvl(sum(nvl(imp_recaudado,0)),0)   --Debe ser igual al campo imp_recaudado de sl_constancias para el aniomes consultado.
    Into vImprecaudado
    From sl_detlide
    Where num_cte = pNumeroCliente
    and aniomes = pFechaDepositos
    and fecha_ret >= dDiaprimero 
    and fecha_ret <= dDiaUltimo;

    Let vImppendiente = vImpaRecaudar - vImprecaudado;

    RETURN vCodRet, vImpGravado, vImpaRecaudar, vImprecaudado, vImppendiente, vImpacumulado, vImpperiodosant;
END PROCEDURE;