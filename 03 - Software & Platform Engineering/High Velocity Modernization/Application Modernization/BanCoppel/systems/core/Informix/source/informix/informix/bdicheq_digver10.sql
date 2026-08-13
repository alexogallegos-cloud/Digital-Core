create procedure "informix".digver10(pcuenta char(15))
  returning char(5), char(1);

  define cod_ret char(5);
  define p		integer;
  define n1  	integer;
  define n2  	integer;
  define n  	integer;
  define i  	integer;
  define k  	integer;
  define vaux	char(2);
  define digito10	integer;
  

-- ********************************************************************
-- Inicializa variables
-- ********************************************************************
	let cod_ret = "000";
	let p		= 0;
	let n1  	= 0;
	let n2  	= 0;
	let n  		= 0;
	let i  		= 0;
	let k  		= 0;
	let vaux	= "";
	let digito10	= 0;

    If pcuenta = "" Then
        LET digito10 = 0;
    Else
        For i = 1 To length(TRIM(pcuenta))
            LET k = SUBSTR(pcuenta, i, 1);
            If MOD(i,2) = 0 Then
                LET p = 1;
            Else
                LET p = 2;
            End If
            LET vaux = LPAD(k * p, 2, "0");
            LET n1 = SUBSTR(vaux, 1, 1);
            LET n2 = SUBSTR(vaux, 2, 1);
            LET n = n + n1 + n2;
        end for
    End If
    If MOD(n,10) = 0 Then
        LET k = n;
    Else
        LET k = n - MOD(n,10) + 10;
    End If

	LET digito10 = k - n;
return cod_ret, digito10;
end procedure;