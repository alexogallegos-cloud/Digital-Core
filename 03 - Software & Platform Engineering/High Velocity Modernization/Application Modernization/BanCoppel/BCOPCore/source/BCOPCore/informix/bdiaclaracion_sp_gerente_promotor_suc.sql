CREATE PROCEDURE "informix".sp_gerente_promotor_suc(p_Sucursal CHAR(4),p_Perfil integer)
 RETURNING CHAR(15) AS ejecutivo;

DEFINE resultado_ejecutivo CHAR(15);


---Promotor
IF p_Perfil == 6 THEN
    FOREACH
        SELECT left (ejecutivo,15) || '*' into resultado_ejecutivo 
            FROM bdinteg:si_ejecut where sucursal = p_Sucursal and password <> 'BAJA' and (puesto = 003 or puesto = 008)                 
        return resultado_ejecutivo with resume;
    END FOREACH;
END IF

---Gerente
IF p_Perfil == 5 THEN
    FOREACH
        SELECT limit 1 left (ejecutivo,15) || '*' into resultado_ejecutivo 
            FROM bdinteg:si_ejecut where sucursal = p_Sucursal and password <> 'BAJA' and (puesto = 001)                 
        return resultado_ejecutivo with resume;
    END FOREACH;
END IF

END PROCEDURE;