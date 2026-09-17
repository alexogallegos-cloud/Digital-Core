create procedure "informix".exponencia(ValorBase decimal(13,9), ValorExpo decimal(13,9))
returning  decimal(13,9), char(70);
define Exp       char(70);
define Resultado decimal(13,9);

let Resultado = pow(ValorBase, ValorExpo);
let Exp       = Resultado;

return  Resultado, Exp;
end procedure
;