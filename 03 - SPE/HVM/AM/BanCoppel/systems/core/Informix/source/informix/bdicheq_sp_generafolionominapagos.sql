CREATE PROCEDURE "informix".sp_generafolionominapagos( cNombreUsuario CHAR(8) )
RETURNING  CHAR(3), CHAR(16);
        
    --- Realizo   : Martin Valenzuela Ojeda
    --- Proyecto  : Dispercion Nomina BanCoppel
    --- Actividad : Genera un numero de folio, ya sea de Dispercion o para Acuse de Recibo, este numero de folio se forma de:
    ---             numero de usuario + la hora + minutos +segundos + dos dijitos que se generan aleatoriamente
    --- Fecha     : Abril de 2008
   
    Define cCodRet                      CHAR(3);
    Define cNumeroFolio                 CHAR(16);
    Define iNumeroAleatorio             Integer ;
    Define cHoraDispercion              DateTime Hour To Second ;
    Define cHoraDispercionFormateada    CHAR(6) ;
    Define cHora                        CHAR(2);
    Define cMinutos                     CHAR(2);
    Define cSegundos                    CHAR(2);
    Define cNumeroFormateado            CHAR(2);

    Let cCodRet = '000';
    Let cNumeroFolio = '';
    Let cHoraDispercion = '';
    Let cHoraDispercionFormateada = '';
    Let cHora = '';
    Let cMinutos = '';
    Let cSegundos = '';
    Let cNumeroFormateado = '';
	
    --Let cHoraDispercion = Current ;
    SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND
	INTO cHoraDispercion
	FROM sysmaster:"informix".sysshmvals;
	
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