CREATE PROCEDURE "informix".sp_imagen_ine(pNumCte char(20))
       RETURNING CHAR(5), SMALLINT;
	   
DEFINE vcodret CHAR(5);
DEFINE vsqlerr INTEGER;
DEFINE residuo SMALLINT;
DEFINE registros SMALLINT;
DEFINE docto   CHAR(4);
DEFINE psecuencia SMALLINT;



LET vcodret = '00005';
LET vsqlerr = 0;
LET residuo = 0;
LET registros = 0;
LET docto='';
LET psecuencia=0;
	   
BEGIN
	ON EXCEPTION SET vsqlerr
			IF vsqlerr <> 0 THEN
				LET vcodret = vsqlerr;
				RETURN vcodret, psecuencia;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
FOREACH
SELECT mod(max(NVL(secuencia,0)),2) as residuo, MAX(NVL(secuencia,0)) as registros INTO residuo, registros FROM "informix".dg_expediente_img1 WHERE cod_docto="0001" AND cliente= pNumCte
END FOREACH;

if residuo =0 then
 let psecuencia = registros - 1;
 
else
 let psecuencia = registros;
 
end if;

if psecuencia >=1 then
select LIMIT 1 cod_docto into docto from  dg_expediente_img1 where cod_docto='0001' and (imagen is not null) and  cliente= pNumCte and secuencia= psecuencia;
end if;

if docto is not null  or docto <>'' then
 let vcodret='00000';

else
let vcodret='00001';

end if; 

RETURN vcodret, psecuencia;

END;
END PROCEDURE;