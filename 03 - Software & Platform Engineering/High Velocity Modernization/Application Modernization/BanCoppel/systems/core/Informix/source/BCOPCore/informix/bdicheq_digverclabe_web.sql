CREATE PROCEDURE "informix".digverclabe_web(pcuenta char(20))
       returning char(5),char(1);

   DEFINE vcodret     CHAR(5);
   DEFINE i,k,n,p,n1,n2 INTEGER;
   DEFINE vdigver     CHAR(1);
   DEFINE vctaaux     CHAR(20);
   define vaux        char(2);

-- SET DEBUG FILE TO "digito10.out";
-- TRACE ON;
   LET vcodret = "00000";
   LET vdigver = "0";
   LET vctaaux = pcuenta;
   LET n = LENGTH(pcuenta);
   LET p = 0;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;
	
   FOR i = 1 TO n 
       LET n1 = SUBSTR(vctaaux,i,1);
       if i IN (1,4,7,10,13,16,19) then 
	let k = n1 * 3  ;
       end if;

       if i IN (2,5,8,11,14,17,20) then 
	let k = n1 * 7  ;
       end if;

       if i IN (3,6,9,12,15,18) then 
	let k = n1 * 1  ;
       end if;

       IF k >= 10 THEN LET k = MOD(k,10); END IF

       LET p = p + k;
   END FOR
 
   LET p = MOD(p, 10);
   IF p > 0 THEN 
      LET p = 10 - p;
   END IF
      LET vdigver = p;

   RETURN vcodret, vdigver;
END PROCEDURE;