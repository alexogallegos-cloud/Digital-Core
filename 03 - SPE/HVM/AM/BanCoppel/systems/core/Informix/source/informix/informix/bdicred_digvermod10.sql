create procedure "informix".digvermod10(pcuenta char(20))
       returning char(5),char(1);

   DEFINE vcodret     CHAR(5);
   DEFINE i,k,n,p,n1,n2 INTEGER;
   DEFINE vdigver     CHAR(1);
   DEFINE vctaaux     CHAR(20);
   define vaux        char(2);




   LET vcodret = "000";
   LET vdigver = "0";
   LET vctaaux = pcuenta;

   LET n = 0;

   for i = 1 to 20
       if i = 1 then let k = vctaaux[1,1]; end if;
       if i = 2 then let k = vctaaux[2,2]; end if;
       if i = 3 then let k = vctaaux[3,3]; end if;
       if i = 4 then let k = vctaaux[4,4]; end if;
       if i = 5 then let k = vctaaux[5,5]; end if;
       if i = 6 then let k = vctaaux[6,6]; end if;
       if i = 7 then let k = vctaaux[7,7]; end if;
       if i = 8 then let k = vctaaux[8,8]; end if;
       if i = 9 then let k = vctaaux[9,9]; end if;
       if i = 10 then let k = vctaaux[10,10]; end if;
       if i = 11 then let k = vctaaux[11,11]; end if;
       if i = 12 then let k = vctaaux[12,12]; end if;
       if i = 13 then let k = vctaaux[13,13]; end if;
       if i = 14 then let k = vctaaux[14,14]; end if;
       if i = 15 then let k = vctaaux[15,15]; end if;
       if i = 16 then let k = vctaaux[16,16]; end if;
       if i = 17 then let k = vctaaux[17,17]; end if;
       if i = 18 then let k = vctaaux[18,18]; end if;
       if i = 19 then let k = vctaaux[19,19]; end if;
       if i = 20 then let k = vctaaux[20,20]; end if;
       IF k IS NOT NULL THEN
          if mod(i,2) = 0 then
             LET p = 1;
          else
             LET p = 2;
          end if
          let vaux = lpad(k*p,2,"0");
          let n1 = vaux[1];
          let n2 = vaux[2];
          LET n = n + n1 + n2;
       END IF;
   end for
   let n = n;
   if mod(n,10) = 0 then
      let k = n;
   else
      let k = n - mod(n,10) + 10;
   end if
   LET vdigver = k - n;
   RETURN vcodret, vdigver;
end procedure;