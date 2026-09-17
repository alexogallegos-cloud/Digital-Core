CREATE PROCEDURE "informix".tabla_dual ()
define existe int;

let existe = 0;
select count(*) into existe from systables
where tabname = "dual";

if (existe = 0)
then 
create table "informix".dual
  (
    dual char(1)
  )  ;

insert into dual values("X");
end if;

end procedure;