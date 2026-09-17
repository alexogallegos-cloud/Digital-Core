create procedure "informix".calculo_parametrico
(
    pnum_solicitud char(20)
)
returning integer;

    define iSuma    integer;
    define iPuntos  integer;

begin
    Let iSuma   = 0;
    Let iPuntos = 0;

    Foreach
    Select 
            decode(nvl(sg.agrupar, ''), '', sum(nvl(dc.valor,0)), max(nvl(dc.valor,0))) as suma 
    Into iPuntos
    From bdisolic:ss_detalle_scoring dc, bdisolic:ss_scoring_grupo sg, bdisolic:ss_solicitudes sol 
    Where sg.empresa = dc.empresa 
    and sg.grupo = dc.grupo 
    and sg.seccion = dc.seccion 
    and dc.num_solicitud = pnum_solicitud 
    and dc.seccion = '2' 
    and dc.empresa = '001' 
    and sol.num_solicitud = dc.num_solicitud 
    and sol.empresa = dc.empresa 
    Group By sol.num_solicitud, sg.empresa, sg.seccion, sg.agrupar 

        Let iSuma = iSuma + iPuntos;

    End foreach;

    return iSuma;

end;
end procedure;