Create Procedure "informix".sp_generafoliocredi
(
cNombreUsuario      Char(8),
iFolConsec          Smallint
)


RETURNING  Char(3), Char(16);

Define cCodRet                     Char(3);
Define cNumeroFolio                Char(16);

Define cHoraDispercion             DateTime Hour To Second ;
Define cHoraDispercionFormateada   Char(6) ;
Define cHora                       Char(2);
Define cMinutos                    Char(2);
Define cSegundos                   Char(2);
Define cNumeroFormateado           Char(2);

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

Begin

    --VALIDACIONES
    If (cNombreUsuario = "") Or (cNombreUsuario = " ") Or (cNombreUsuario Is Null) Then
          Let cCodRet = '100';
          Let cNumeroFolio = "";
          Return cCodRet, cNumeroFolio;
    Else
           If iFolConsec In (0,1,2,3,4,5,6,7,8,9) Then
                Let cNumeroFormateado = '0' || iFolConsec;
                Let cNumeroFolio = cNombreUsuario || cHoraDispercionFormateada || cNumeroFormateado;
           Else
                Let cNumeroFolio = cNombreUsuario || cHoraDispercionFormateada || iFolConsec;
           End If

               Let cCodRet = '000';
               Return cCodRet, cNumeroFolio;
    End If

End

End Procedure;