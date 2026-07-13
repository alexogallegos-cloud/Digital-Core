create function "informix".locate(p_instring char(1000), p_lookfor char(1)) returning integer;

define w_work char(1000);
define w_token char(1);
define w_location smallint;
define i smallint;

if ((p_instring is NULL) or (p_lookfor = '')) then
let w_location = -1;
return w_location;
end if;

let w_work = p_instring;
let w_token = p_lookfor;
let w_location = 0;

for i = 1 to length(w_work)
if ( substr(w_work,i,1) = w_token ) then
let w_location = i;
exit for ;
end if;
end for;

return w_location;
end function;