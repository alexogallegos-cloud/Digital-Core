Create Procedure "informix".sp_actualiza_solicitudes_inserta_datos
(
dMontoNuevo                                           Decimal(16,2),
cEmpresa                                                 Char(3),
cNumeroSolicitud                                    Char(20),
cNumeroCliente                                       Char(9),
iSecuencia                                                Integer,
cJustificacion                                            Char(400),
dMontoAnterior                                          Decimal(16,2),
cEstatusSolicitud                                      Char(2),
cEstatusSolicitudNuevo                          Char(2),
cUsuario                                                     Char(20),
dFechaHoy                                                 Date 
)

Returning Char(3);

Define cCodRet                                Char(3);
Define vsqlerr                                    Integer ;
Define cParametroErroneo            Boolean ;

Let cCodRet = '000';
Let cParametroErroneo = 'F';

Begin

ON EXCEPTION SET vsqlerr
    IF vsqlerr <> 0 THEN
        Let cCodRet = vsqlerr;
        Return cCodRet;
    END IF;
END EXCEPTION;


--Validacion de Parametros
If (dMontoNuevo = " ") Or (dMontoNuevo = 0.00) Or (dMontoNuevo Is Null) Then
    Let cParametroErroneo = 'T';
Elif (cEmpresa = " ") Or (cEmpresa Is Null) Then
    Let cParametroErroneo = 'T';
Elif (cNumeroSolicitud = " ") Or (cNumeroSolicitud Is Null) Then
    Let cParametroErroneo = 'T';
Elif (cNumeroCliente = " ") Or (cNumeroCliente Is Null) Then
    Let cParametroErroneo = 'T';
Elif (iSecuencia = " ") Or (iSecuencia = 0) Or  (iSecuencia Is Null) Then
    Let cParametroErroneo = 'T';
Elif (cJustificacion = " ") Or (cJustificacion Is Null) Then
    Let cParametroErroneo = 'T';
Elif (dMontoAnterior = " ") Or  (dMontoAnterior Is Null) Then
    Let cParametroErroneo = 'T';
Elif (cEstatusSolicitud = " ") Or (cEstatusSolicitud Is Null) Then
    Let cParametroErroneo = 'T';
Elif (cEstatusSolicitudNuevo = " ") Or (cEstatusSolicitudNuevo Is Null) Then
    Let cParametroErroneo = 'T';
Elif (cUsuario = " ") Or (cUsuario Is Null) Then
    Let cParametroErroneo = 'T';
Elif (dFechaHoy = " ") Or (dFechaHoy Is Null) Then
    Let cParametroErroneo = 'T';
End If
                                                                                 
If cParametroErroneo = 'T' Then
    Let cCodRet = '222';
    Return cCodRet;
End If                                                
                
                                                                                                                                                                                                                                    
update bdisolic:ss_solicitudes 
set monto_solicitado = dMontoNuevo
where empresa = Trim(cEmpresa) And num_solicitud = Trim(cNumeroSolicitud);

Insert Into bdisolic:ss_autorizacion_especial 
(empresa, num_solicitud, numcte, secuencia, comentario, montolinea_ant, montolinea_nvo, status_ant, status_nvo, usuario_modif, fecha_modif) 
values(Trim(cEmpresa), Trim(cNumeroSolicitud), Trim(cNumeroCliente), iSecuencia, Trim(cJustificacion), dMontoAnterior, dMontoNuevo, Trim(cEstatusSolicitud), 
Trim(cEstatusSolicitudNuevo), Trim(cUsuario), dFechaHoy::Date);

Return cCodRet;

End 
End Procedure;