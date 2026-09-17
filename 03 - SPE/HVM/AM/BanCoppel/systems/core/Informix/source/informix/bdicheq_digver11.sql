create procedure "informix".digver11(pcuenta char(19))
  returning char(5), char(1);

  define cod_ret char(5);
  define digito,vlongcta smallint;
  define digito1 char(1);
  define n1,n2,n3,n4,n5,n6,n7,n8,n9,n10,n11,n12,
         n13,n14,n15,n16,n17,n18,n19 smallint;
  define div, suma, i, aux, res smallint;

-- ********************************************************************
-- Inicializa variables
-- ********************************************************************
let cod_ret = "000";
let digito  = "0";
let suma    = 0;
let aux     = 0;


let n1  = pcuenta[1,1];
let n2  = pcuenta[2,2];
let n3  = pcuenta[3,3];
let n4  = pcuenta[4,4];
let n5  = pcuenta[5,5];
let n6  = pcuenta[6,6];
let n7  = pcuenta[7,7];
let n8  = pcuenta[8,8];
let n9  = pcuenta[9,9];
let n10 = pcuenta[10,10];
let n11 = pcuenta[11,11];
let n12 = pcuenta[12,12];
let n13 = pcuenta[13,13];
let n14 = pcuenta[14,14];
let n15 = pcuenta[15,15];
let n16 = pcuenta[16,16];
let n17 = pcuenta[17,17];
let n18 = pcuenta[18,18];
let n19 = pcuenta[19,19];

-- *******************************************************************
-- Aplica el peso 2,3,4,5,6,7,2,3 de derecha a izquierda
-- *******************************************************************
let vlongcta = length(pcuenta);
if vlongcta = 19 then
   let n19 = n19 * 2;
   let n18 = n18 * 3;
   let n17 = n17 * 4;
   let n16 = n16 * 5;
   let n15 = n15 * 6;
   let n14 = n14 * 7;
   let n13 = n13 * 2;
   let n12 = n12 * 3;
   let n11 = n11 * 4;
   let n10 = n10 * 5;
   let n9  = n9  * 6;
   let n8  = n8  * 7;
   let n7  = n7  * 2;
   let n6  = n6  * 3;
   let n5  = n5  * 4;
   let n4  = n4  * 5;
   let n3  = n3  * 6;
   let n2  = n2  * 7;
   let n1  = n1  * 2;
   let suma = n1+n2+n3+n4+n5+n6+n7+n8+n9+n10+n11+n12+n13+n14+n15+
              n16+n17+n18+n19;
end if
if vlongcta = 18 then
   let n18 = n18 * 2;
   let n17 = n17 * 3;
   let n16 = n16 * 4;
   let n15 = n15 * 5;
   let n14 = n14 * 6;
   let n13 = n13 * 7;
   let n12 = n12 * 2;
   let n11 = n11 * 3;
   let n10 = n10 * 4;
   let n9  = n9  * 5;
   let n8  = n8  * 6;
   let n7  = n7  * 7;
   let n6  = n6  * 2;
   let n5  = n5  * 3;
   let n4  = n4  * 4;
   let n3  = n3  * 5;
   let n2  = n2  * 6;
   let n1  = n1  * 7;
   let suma = n1+n2+n3+n4+n5+n6+n7+n8+n9+n10+n11+n12+n13+n14+n15+
              n16+n17+n18;
end if
if vlongcta = 17 then
   let n17 = n17 * 2;
   let n16 = n16 * 3;
   let n15 = n15 * 4;
   let n14 = n14 * 5;
   let n13 = n13 * 6;
   let n12 = n12 * 7;
   let n11 = n11 * 2;
   let n10 = n10 * 3;
   let n9  = n9  * 4;
   let n8  = n8  * 5;
   let n7  = n7  * 6;
   let n6  = n6  * 7;
   let n5  = n5  * 2;
   let n4  = n4  * 3;
   let n3  = n3  * 4;
   let n2  = n2  * 5;
   let n1  = n1  * 6;
   let suma = n1+n2+n3+n4+n5+n6+n7+n8+n9+n10+n11+n12+n13+n14+n15+
              n16+n17;
end if
if vlongcta = 16 then
   let n16 = n16 * 2;
   let n15 = n15 * 3;
   let n14 = n14 * 4;
   let n13 = n13 * 5;
   let n12 = n12 * 6;
   let n11 = n11 * 7;
   let n10 = n10 * 2;
   let n9  = n9  * 3;
   let n8  = n8  * 4;
   let n7  = n7  * 5;
   let n6  = n6  * 6;
   let n5  = n5  * 7;
   let n4  = n4  * 2;
   let n3  = n3  * 3;
   let n2  = n2  * 4;
   let n1  = n1  * 5;
   let suma = n1+n2+n3+n4+n5+n6+n7+n8+n9+n10+n11+n12+n13+n14+n15+
              n16;
end if
if vlongcta = 15 then
   let n15 = n15 * 2;
   let n14 = n14 * 3;
   let n13 = n13 * 4;
   let n12 = n12 * 5;
   let n11 = n11 * 6;
   let n10 = n10 * 7;
   let n9  = n9  * 2;
   let n8  = n8  * 3;
   let n7  = n7  * 4;
   let n6  = n6  * 5;
   let n5  = n5  * 6;
   let n4  = n4  * 7;
   let n3  = n3  * 2;
   let n2  = n2  * 3;
   let n1  = n1  * 4;
   let suma = n1+n2+n3+n4+n5+n6+n7+n8+n9+n10+n11+n12+n13+n14+n15;
end if

if vlongcta = 14 then
   let n14 = n14 * 2;
   let n13 = n13 * 3;
   let n12 = n12 * 4;
   let n11 = n11 * 5;
   let n10 = n10 * 6;
   let n9  = n9  * 7;
   let n8  = n8  * 2;
   let n7  = n7  * 3;
   let n6  = n6  * 4;
   let n5  = n5  * 5;
   let n4  = n4  * 6;
   let n3  = n3  * 7;
   let n2  = n2  * 2;
   let n1  = n1  * 3;
   let suma = n1+n2+n3+n4+n5+n6+n7+n8+n9+n10+n11+n12+n13+n14;
end if

if vlongcta = 13 then
   let n13 = n13 * 2;
   let n12 = n12 * 3;
   let n11 = n11 * 4;
   let n10 = n10 * 5;
   let n9  = n9  * 6;
   let n8  = n8  * 7;
   let n7  = n7  * 2;
   let n6  = n6  * 3;
   let n5  = n5  * 4;
   let n4  = n4  * 5;
   let n3  = n3  * 6;
   let n2  = n2  * 7;
   let n1  = n1  * 2;
   let suma = n1+n2+n3+n4+n5+n6+n7+n8+n9+n10+n11+n12+n13;
end if
if vlongcta = 12 then
   let n12 = n12 * 2;
   let n11 = n11 * 3;
   let n10 = n10 * 4;
   let n9  = n9  * 5;
   let n8  = n8  * 6;
   let n7  = n7  * 7;
   let n6  = n6  * 2;
   let n5  = n5  * 3;
   let n4  = n4  * 4;
   let n3  = n3  * 5;
   let n2  = n2  * 6;
   let n1  = n1  * 7;
   let suma = n1+n2+n3+n4+n5+n6+n7+n8+n9+n10+n11+n12;
end if
if vlongcta = 11 then
   let n11 = n11 * 2;
   let n10 = n10 * 3;
   let n9  = n9  * 4;
   let n8  = n8  * 5;
   let n7  = n7  * 6;
   let n6  = n6  * 7;
   let n5  = n5  * 2;
   let n4  = n4  * 3;
   let n3  = n3  * 4;
   let n2  = n2  * 5;
   let n1  = n1  * 6;
   let suma = n1+n2+n3+n4+n5+n6+n7+n8+n9+n10+n11;
end if
if vlongcta = 10 then
   let n10 = n10 * 2;
   let n9  = n9  * 3;
   let n8  = n8  * 4;
   let n7  = n7  * 5;
   let n6  = n6  * 6;
   let n5  = n5  * 7;
   let n4  = n4  * 2;
   let n3  = n3  * 3;
   let n2  = n2  * 4;
   let n1  = n1  * 5;
   let suma = n1+n2+n3+n4+n5+n6+n7+n8+n9+n10;
end if
if vlongcta = 9 then
   let n9  = n9  * 2;
   let n8  = n8  * 3;
   let n7  = n7  * 4;
   let n6  = n6  * 5;
   let n5  = n5  * 6;
   let n4  = n4  * 7;
   let n3  = n3  * 2;
   let n2  = n2  * 3;
   let n1  = n1  * 4;
   let suma = n1+n2+n3+n4+n5+n6+n7+n8+n9;
end if
if vlongcta = 8 then
   let n8  = n8  * 2;
   let n7  = n7  * 3;
   let n6  = n6  * 4;
   let n5  = n5  * 5;
   let n4  = n4  * 6;
   let n3  = n3  * 7;
   let n2  = n2  * 2;
   let n1  = n1  * 3;
   let suma = n1+n2+n3+n4+n5+n6+n7+n8;
end if

-- *******************************************************************
-- Obtiene el residuo
-- *******************************************************************
let res = mod(suma,11);
if res = 0 then
   let digito = 0;
else
   let digito = 11 - res;
end if
if digito = 10 then
   let digito = 0;
end if
let digito1 = digito;
return cod_ret, digito1;
end procedure;