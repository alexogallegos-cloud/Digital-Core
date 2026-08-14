Create Procedure "informix".sp_consultadocumentosdesolicitudes(
cNumeroCliente                      Char(20)
)

Returning Char(3) as cCodRet, Char(35) as Descripcion;

Define cCodRet                             Char(3);
Define cDescripcion                     Char(35);
Define vsqlerr                                 Integer ;


Let cDescripcion = "";
Let cCodRet = '000';

Begin

ON EXCEPTION SET vsqlerr
    IF vsqlerr <> 0 THEN
        Let cCodRet = vsqlerr;
        Return cCodRet, " ";
    END IF;
END EXCEPTION;

--Validacion del Parametro
If (Trim(cNumeroCliente) = " ") Or (cNumeroCliente Is Null) Then
    Let cCodRet = '112';
    Return cCodRet, " ";
End If

ForEach
	select  Distinct b.descripcion
	Into cDescripcion
	from bdidigital:dg_expediente a,
	     bdidigital:dg_tipodocumento b
	where a.empresa = '001' and cliente = cNumeroCliente
	 and a.cod_docto = b.cod_docto
/*    
    If siVuelta = 1 Then
        Let cDato1 = cDescripcion;
    Elif siVuelta = 2 Then
        Let cDato3 = cDescripcion
    Elif siVuelta = 3 Then
        Let cDato3 = cDescripcion
    End If
*/
    Return cCodRet, cDescripcion With Resume;

End ForEach

--Let cDescripcion = cDato1 ||","|| ||" "|| cDato2 ||","|| ||" "|| cDato3;

--Return cCodRet, cDescripcion;

End
End Procedure;