Create Procedure "informix".sp_generafolionomina( cNombreUsuario Char(8) )
RETURNING  Char(3), Char(16);
        
    --- Realizo   : Martin Valenzuela Ojeda
    --- Proyecto  : Dispercion Nomina BanCoppel
    --- Actividad : Genera un numero de folio, ya sea de Dispercion o para Acuse de Recibo, este numero de folio se forma de:
    ---             numero de usuario + la hora + minutos +segundos + dos dijitos que se generan aleatoriamente
    --- Fecha     : Abril de 2008
    
    Define cCodRet                      Char(3);
    Define cNumeroFolio                 Char(16);
    Define iNumeroAleatorio             Integer ;
    Define cHoraDispercion              DateTime Hour To Second ;
    Define cHoraDispercionFormateada    Char(6) ;
    Define cHora                        Char(2);
    Define cMinutos                     Char(2);
    Define cSegundos                    Char(2);
    Define cNumeroFormateado            Char(2);

    Let cCodRet = '000';
    Let cNumeroFolio = '';
    Let cHoraDispercion = '';
    Let cHoraDispercionFormateada = '';
    Let cHora = '';
    Let cMinutos = '';
    Let cSegundos = '';
    Let cNumeroFormateado = '';
    Let cHoraDispercion = Current ;
    Let cHora = Substr(cHoraDispercion, 1, 2);
    Let cMinutos = Substr(cHoraDispercion, 4, 2);
    Let cSegundos = Substr(cHoraDispercion, 7, 2);
    Let cHoraDispercionFormateada = cHora || cMinutos || cSegundos;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    Begin

    /* VALIDACIONES */
    If (cNombreUsuario = "") Or (cNombreUsuario = " ") Or (cNombreUsuario Is Null) Then
        Let cCodRet = '100';
        Let cNumeroFolio = "";
        Return cCodRet, cNumeroFolio;
    Else
        Call sp_random() 
        Returning iNumeroAleatorio;

        If iNumeroAleatorio In (0,1,2,3,4,5,6,7,8,9) Then
            Let cNumeroFormateado = '0' || iNumeroAleatorio;
            Let cNumeroFolio = cNombreUsuario || cHoraDispercionFormateada || cNumeroFormateado;
        Else
            Let cNumeroFolio = cNombreUsuario || cHoraDispercionFormateada || iNumeroAleatorio;
        End If

    Let cCodRet = '000';
    
    Return cCodRet, cNumeroFolio;
    
    End If

    End

End Procedure;