create procedure "informix".sp_cancelatarj(pempresa char (3),ptarj char(20),ptipo char(1))
returning char(5);

DEFINE vcodret CHAR(5);
DEFINE vsqlerr INTEGER;
define vtarjeta char(20);
define vstatusint char(3);
define vstatust char(3);
define cBinTar char(6);

LET vcodret = "002";
LET vsqlerr = 0;
LET vtarjeta ='';
let vstatust ='';
let vstatusint ='';
let cBinTar ='';

BEGIN

ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            RETURN vcodret;
        END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET debug file to "/tmp/cantarj.out";
--trace on;

if pempresa='' or pempresa is null  or ptarj ='' or ptarj is null or ptipo ='' or ptipo is null then 
    let vcodret='0001';
    return vcodret;
end if;


if ptipo='1' then 
--credito
    SELECT  codstatustarjeta into vstatusint  FROM intercard:tarjeta WHERE numtarjeta=ptarj;
    
    let vstatusint=nvl(vstatusint,'');
	
--DSB PAY INICIO
LET cBinTar = SUBSTR(ptarj,1,6);

IF TRIM(cBinTar) = '514014' THEN

	 if vstatusint <> 'CAN' and vstatusint<> 'INA'  then 
		UPDATE intercard:"informix".tarjeta SET codstatustarjeta='CAN' WHERE numtarjeta=ptarj;
	 END IF;

Let vcodret='00000';
ELSE
--DSB PAY FIN

    if vstatusint = 'CAN'  then 
      SELECT status_tar into vstatust FROM bdicred:sd_tarjeta WHERE num_tarjeta=ptarj;
         let vstatust=nvl(vstatust,'');
         if vstatust <>'C' then
            UPDATE bdicred:sd_tarjeta SET status_tar='C'  WHERE  num_tarjeta=ptarj;

         end if;
         
        Let vcodret='00000';
    elif   vstatusint<> 'INA'  then 
        if  vstatusint = 'ACT' then
             SELECT status_tar into vstatust FROM bdicred:sd_tarjeta WHERE num_tarjeta=ptarj;
             let vstatust=nvl(vstatust,'');
             if vstatust ='C' then
                UPDATE intercard:tarjeta SET codstatustarjeta='CAN' WHERE numtarjeta=ptarj;
            end if;   
        else
        
        UPDATE intercard:tarjeta SET codstatustarjeta='CAN' WHERE numtarjeta=ptarj;
        
        end if;        
        Let vcodret='00000';
    end if;
	
END IF;


elif ptipo='2' then 

   SELECT  codstatustarjeta into vstatusint  FROM intercard:tarjeta WHERE numtarjeta=ptarj;
    
    let vstatusint=nvl(vstatusint,'');

     if vstatusint = 'CAN'  then 

         SELECT status_tar into vstatust FROM bdicheq:sc_tarjeta WHERE num_tarjeta=ptarj;
         let vstatust=nvl(vstatust,'');
         if vstatust <>'C' then
            UPDATE bdicheq:sc_tarjeta SET status_tar='C'  WHERE  num_tarjeta=ptarj;

           
         end if;
          Let vcodret='00000';

    elif   vstatusint <> 'INA' then 
        let vstatusint=vstatusint;
        if ( vstatusint = 'ACT') then 
             SELECT status_tar into vstatust FROM bdicheq:sc_tarjeta WHERE num_tarjeta=ptarj;
             let vstatust=nvl(vstatust,'');
                if vstatust ='C' then
                     UPDATE intercard:tarjeta SET codstatustarjeta='CAN' WHERE numtarjeta=ptarj;
                end if
            --
        else
        UPDATE intercard:tarjeta SET codstatustarjeta='CAN' WHERE numtarjeta=ptarj;
        end if
        Let vcodret='00000';
    end if;
end if;

 return vcodret;
end
end procedure;