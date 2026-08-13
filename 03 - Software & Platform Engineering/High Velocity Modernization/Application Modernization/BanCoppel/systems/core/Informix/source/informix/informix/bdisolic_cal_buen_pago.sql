CREATE PROCEDURE "informix".cal_buen_pago(o_numcte  CHAR(20),pflujo CHAR(1))

RETURNING   CHAR(05), -- codigo de retorno
            CHAR(30); -- cadena buen pago 30 meses



-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret      CHAR(5);
DEFINE vsqlerr       INTEGER;
DEFINE sql_err       SMALLINT;
DEFINE isam_err      SMALLINT;
DEFINE error_info    CHAR(100);

DEFINE vcadena_pago  CHAR(30);

LET scod_ret      = "000";
LET vsqlerr       = 0;
LET vcadena_pago  = "";
LET error_info    = "";

BEGIN
   ON EXCEPTION SET sql_err, isam_err, error_info
      LET scod_ret = sql_err;
      drop table pas_fecha;
      drop table mat_paso;
      drop table pas_final;
      drop table cadena_fin;
      RETURN scod_ret, "ISAM : "||isam_err;
   END EXCEPTION;


--SET DEBUG FILE TO "/pisa/buen_pago.out";
--TRACE ON;

		IF pflujo = "1" THEN--incremento
			select case when year(mdy(month(fecha),'01',year(fecha))) <> case when tl28 is null then year(mdy(month(tl17),'01',year(tl17)) - 1 units month) else year(mdy(month(tl28),'01',year(tl28))) end
					 then (year(mdy(month(fecha),'01',year(fecha))) - case when tl28 is null then year(mdy(month(tl17),'01',year(tl17)) - 1 units month) else year(mdy(month(tl28),'01',year(tl28))) end ) * 12 
					 else 0
				   end +
				   month(mdy(month(fecha),'01',year(fecha))) -  case when tl28 is null then month(mdy(month(tl17),'01',year(tl17)) - 1 units month) else  month(mdy(month(tl28),'01',year(tl28))) end meses_pos,
				trim(tl27) cadena
			from bdiburo:br_tl_bc
			where num_cliente = o_numcte
			and tl02 not in (SELECT b.tipo_negocio FROM bdisolic:ss_cat_tiponegocio_sic b WHERE b.institucion = institucion)
			into temp pas_fecha with no log;
		ELSE --solicitud
				select case when year(mdy(month(fecha),'01',year(fecha))) <> case when tl28 is null then year(mdy(month(tl17),'01',year(tl17)) - 1 units month) else year(mdy(month(tl28),'01',year(tl28))) end
					 then (year(mdy(month(fecha),'01',year(fecha))) - case when tl28 is null then year(mdy(month(tl17),'01',year(tl17)) - 1 units month) else year(mdy(month(tl28),'01',year(tl28))) end ) * 12 
					 else 0
				   end +
				   month(mdy(month(fecha),'01',year(fecha))) -  case when tl28 is null then month(mdy(month(tl17),'01',year(tl17)) - 1 units month) else  month(mdy(month(tl28),'01',year(tl28))) end meses_pos,
				trim(tl27) cadena
				from bdiburo:br_tl 
				where num_cliente = o_numcte
				and tl02 not in (SELECT b.tipo_negocio FROM bdisolic:ss_cat_tiponegocio_sic b WHERE b.institucion = institucion)
				into temp pas_fecha with no log;
		END IF

        select replace(replace(replace(substr('                        ',1,meses_pos)||cadena,'U','0'),'X','0'),'-','0') matriz
        from pas_fecha into temp mat_paso with no log;

        select
        case when nvl(substr(matriz,1,1),0) in ('','0') then '0' else case when substr(matriz,1,1) >= '3' then substr(matriz,1,1)  else 'S' end end _1, 
        case when nvl(substr(matriz,2,1),0) in ('','0') then '0' else case when substr(matriz,2,1) >= '3' then substr(matriz,2,1)  else 'S' end end _2, 
        case when nvl(substr(matriz,3,1),0) in ('','0') then '0' else case when substr(matriz,3,1) >= '3' then substr(matriz,3,1)  else 'S' end end _3, 
        case when nvl(substr(matriz,4,1),0) in ('','0') then '0' else case when substr(matriz,4,1) >= '3' then substr(matriz,4,1)  else 'S' end end _4, 
        case when nvl(substr(matriz,5,1),0) in ('','0') then '0' else case when substr(matriz,5,1) >= '3' then substr(matriz,5,1)  else 'S' end end _5, 
        case when nvl(substr(matriz,6,1),0) in ('','0') then '0' else case when substr(matriz,6,1) >= '3' then substr(matriz,6,1)  else 'S' end end _6, 
        case when nvl(substr(matriz,7,1),0) in ('','0') then '0' else case when substr(matriz,7,1) >= '3' then substr(matriz,7,1)  else 'S' end end _7, 
        case when nvl(substr(matriz,8,1),0) in ('','0') then '0' else case when substr(matriz,8,1) >= '3' then substr(matriz,8,1)  else 'S' end end _8, 
        case when nvl(substr(matriz,9,1),0) in ('','0') then '0' else case when substr(matriz,9,1) >= '3' then substr(matriz,9,1)  else 'S' end end _9, 
        case when nvl(substr(matriz,10,1),0) in ('','0') then '0' else case when substr(matriz,10,1) >= '3' then substr(matriz,10,1)  else 'S' end end _10, 
        case when nvl(substr(matriz,11,1),0) in ('','0') then '0' else case when substr(matriz,11,1) >= '3' then substr(matriz,11,1)  else 'S' end end _11, 
        case when nvl(substr(matriz,12,1),0) in ('','0') then '0' else case when substr(matriz,12,1) >= '3' then substr(matriz,12,1)  else 'S' end end _12, 
        case when nvl(substr(matriz,13,1),0) in ('','0') then '0' else case when substr(matriz,13,1) >= '3' then substr(matriz,13,1)  else 'S' end end _13, 
        case when nvl(substr(matriz,14,1),0) in ('','0') then '0' else case when substr(matriz,14,1) >= '3' then substr(matriz,14,1)  else 'S' end end _14, 
        case when nvl(substr(matriz,15,1),0) in ('','0') then '0' else case when substr(matriz,15,1) >= '3' then substr(matriz,15,1)  else 'S' end end _15, 
        case when nvl(substr(matriz,16,1),0) in ('','0') then '0' else case when substr(matriz,16,1) >= '3' then substr(matriz,16,1)  else 'S' end end _16, 
        case when nvl(substr(matriz,17,1),0) in ('','0') then '0' else case when substr(matriz,17,1) >= '3' then substr(matriz,17,1)  else 'S' end end _17, 
        case when nvl(substr(matriz,18,1),0) in ('','0') then '0' else case when substr(matriz,18,1) >= '3' then substr(matriz,18,1)  else 'S' end end _18, 
        case when nvl(substr(matriz,19,1),0) in ('','0') then '0' else case when substr(matriz,19,1) >= '3' then substr(matriz,19,1)  else 'S' end end _19, 
        case when nvl(substr(matriz,20,1),0) in ('','0') then '0' else case when substr(matriz,20,1) >= '3' then substr(matriz,20,1)  else 'S' end end _20, 
        case when nvl(substr(matriz,21,1),0) in ('','0') then '0' else case when substr(matriz,21,1) >= '3' then substr(matriz,21,1)  else 'S' end end _21, 
        case when nvl(substr(matriz,22,1),0) in ('','0') then '0' else case when substr(matriz,22,1) >= '3' then substr(matriz,22,1)  else 'S' end end _22, 
        case when nvl(substr(matriz,23,1),0) in ('','0') then '0' else case when substr(matriz,23,1) >= '3' then substr(matriz,23,1)  else 'S' end end _23, 
        case when nvl(substr(matriz,24,1),0) in ('','0') then '0' else case when substr(matriz,24,1) >= '3' then substr(matriz,24,1)  else 'S' end end _24, 
        case when nvl(substr(matriz,25,1),0) in ('','0') then '0' else case when substr(matriz,25,1) >= '3' then substr(matriz,25,1)  else 'S' end end _25, 
        case when nvl(substr(matriz,26,1),0) in ('','0') then '0' else case when substr(matriz,26,1) >= '3' then substr(matriz,26,1)  else 'S' end end _26, 
        case when nvl(substr(matriz,27,1),0) in ('','0') then '0' else case when substr(matriz,27,1) >= '3' then substr(matriz,27,1)  else 'S' end end _27, 
        case when nvl(substr(matriz,28,1),0) in ('','0') then '0' else case when substr(matriz,28,1) >= '3' then substr(matriz,28,1)  else 'S' end end _28, 
        case when nvl(substr(matriz,29,1),0) in ('','0') then '0' else case when substr(matriz,29,1) >= '3' then substr(matriz,29,1)  else 'S' end end _29, 
        case when nvl(substr(matriz,30,1),0) in ('','0') then '0' else case when substr(matriz,30,1) >= '3' then substr(matriz,30,1)  else 'S' end end _30
        from mat_paso
        into temp pas_final with no log;

        select 
        case when (select count(*) from pas_final where _1 = '0') - (select count(*) from pas_final) = '0'  then ' ' when (select count(*) from pas_final where _1 in ('3','4','5','6','7','9')) > 0 then  (select max(_1) from pas_final where _1 not in('','S')) else 'S'end _1,
        case when (select count(*) from pas_final where _2 = '0') - (select count(*) from pas_final) = '0'  then ' ' when (select count(*) from pas_final where _2 in ('3','4','5','6','7','9')) > 0 then  (select max(_2) from pas_final where _2 not in('','S')) else 'S'end _2,
        case when (select count(*) from pas_final where _3 = '0') - (select count(*) from pas_final) = '0'  then ' ' when (select count(*) from pas_final where _3 in ('3','4','5','6','7','9')) > 0 then  (select max(_3) from pas_final where _3 not in('','S')) else 'S'end _3,
        case when (select count(*) from pas_final where _4 = '0') - (select count(*) from pas_final) = '0'  then ' ' when (select count(*) from pas_final where _4 in ('3','4','5','6','7','9')) > 0 then  (select max(_4) from pas_final where _4 not in('','S')) else 'S'end _4,
        case when (select count(*) from pas_final where _5 = '0') - (select count(*) from pas_final) = '0'  then ' ' when (select count(*) from pas_final where _5 in ('3','4','5','6','7','9')) > 0 then  (select max(_5) from pas_final where _5 not in('','S')) else 'S'end _5,
        case when (select count(*) from pas_final where _6 = '0') - (select count(*) from pas_final) = '0'  then ' ' when (select count(*) from pas_final where _6 in ('3','4','5','6','7','9')) > 0 then  (select max(_6) from pas_final where _6 not in('','S')) else 'S'end _6,
        case when (select count(*) from pas_final where _7 = '0') - (select count(*) from pas_final) = '0'  then ' ' when (select count(*) from pas_final where _7 in ('3','4','5','6','7','9')) > 0 then  (select max(_7) from pas_final where _7 not in('','S')) else 'S'end _7,
        case when (select count(*) from pas_final where _8 = '0') - (select count(*) from pas_final) = '0'  then ' ' when (select count(*) from pas_final where _8 in ('3','4','5','6','7','9')) > 0 then  (select max(_8) from pas_final where _8 not in('','S')) else 'S'end _8,
        case when (select count(*) from pas_final where _9 = '0') - (select count(*) from pas_final) = '0'  then ' ' when (select count(*) from pas_final where _9  in ('3','4','5','6','7','9')) > 0 then  (select max(_9) from pas_final where _9 not in('','S')) else 'S'end _9,
        case when (select count(*) from pas_final where _10 = '0') - (select count(*) from pas_final) = '0'  then ' ' when (select count(*) from pas_final where _10 in ('3','4','5','6','7','9')) > 0 then  (select max(_10) from pas_final where _10 not in('','S')) else 'S'end _10,
        case when (select count(*) from pas_final where _11 = '0') - (select count(*) from pas_final) = '0'  then ' ' when (select count(*) from pas_final where _11 in ('3','4','5','6','7','9')) > 0 then  (select max(_11) from pas_final where _11 not in('','S')) else 'S'end _11,
        case when (select count(*) from pas_final where _12 = '0') - (select count(*) from pas_final) = '0'  then ' ' when (select count(*) from pas_final where _12 in ('3','4','5','6','7','9')) > 0 then  (select max(_12) from pas_final where _12 not in('','S')) else 'S'end _12,
        case when (select count(*) from pas_final where _13 = '0') - (select count(*) from pas_final) = '0'  then ' ' when (select count(*) from pas_final where _13 in ('3','4','5','6','7','9')) > 0 then  (select max(_13) from pas_final where _13 not in('','S')) else 'S'end _13,
        case when (select count(*) from pas_final where _14 = '0') - (select count(*) from pas_final) = '0'  then ' ' when (select count(*) from pas_final where _14 in ('3','4','5','6','7','9')) > 0 then  (select max(_14) from pas_final where _14 not in('','S')) else 'S'end _14,
        case when (select count(*) from pas_final where _15 = '0') - (select count(*) from pas_final) = '0'  then ' ' when (select count(*) from pas_final where _15 in ('3','4','5','6','7','9')) > 0 then  (select max(_15) from pas_final where _15 not in('','S')) else 'S'end _15,
        case when (select count(*) from pas_final where _16 = '0') - (select count(*) from pas_final) = '0'  then ' ' when (select count(*) from pas_final where _16 in ('3','4','5','6','7','9')) > 0 then  (select max(_16) from pas_final where _16 not in('','S')) else 'S'end _16,
        case when (select count(*) from pas_final where _17 = '0') - (select count(*) from pas_final) = '0'  then ' ' when (select count(*) from pas_final where _17 in ('3','4','5','6','7','9')) > 0 then  (select max(_17) from pas_final where _17 not in('','S')) else 'S'end _17,
        case when (select count(*) from pas_final where _18 = '0') - (select count(*) from pas_final) = '0'  then ' ' when (select count(*) from pas_final where _18 in ('3','4','5','6','7','9')) > 0 then  (select max(_18) from pas_final where _18 not in('','S')) else 'S'end _18,
        case when (select count(*) from pas_final where _19 = '0') - (select count(*) from pas_final) = '0'  then ' ' when (select count(*) from pas_final where _19 in ('3','4','5','6','7','9')) > 0 then  (select max(_19) from pas_final where _19 not in('','S')) else 'S' end _19,
        case when (select count(*) from pas_final where _20 = '0') - (select count(*) from pas_final) = '0'  then ' ' when (select count(*) from pas_final where _20 in ('3','4','5','6','7','9')) > 0 then  (select max(_20) from pas_final where _20 not in('','S')) else 'S'end _20,
        case when (select count(*) from pas_final where _21 = '0') - (select count(*) from pas_final) = '0'  then ' ' when (select count(*) from pas_final where _21 in ('3','4','5','6','7','9')) > 0 then  (select max(_21) from pas_final where _21 not in('','S')) else 'S'end _21,
        case when (select count(*) from pas_final where _22 = '0') - (select count(*) from pas_final) = '0'  then ' ' when (select count(*) from pas_final where _22 in ('3','4','5','6','7','9')) > 0 then  (select max(_22) from pas_final where _22 not in('','S')) else 'S'end _22,
        case when (select count(*) from pas_final where _23 = '0') - (select count(*) from pas_final) = '0'  then ' ' when (select count(*) from pas_final where _23 in ('3','4','5','6','7','9')) > 0 then  (select max(_23) from pas_final where _23 not in('','S')) else 'S'end _23,
        case when (select count(*) from pas_final where _24 = '0') - (select count(*) from pas_final) = '0'  then ' ' when (select count(*) from pas_final where _24 in ('3','4','5','6','7','9')) > 0 then  (select max(_24) from pas_final where _24 not in('','S')) else 'S'end _24,
        case when (select count(*) from pas_final where _25 = '0') - (select count(*) from pas_final) = '0'  then ' ' when (select count(*) from pas_final where _25 in ('3','4','5','6','7','9')) > 0 then  (select max(_25) from pas_final where _25 not in('','S')) else 'S'end _25,
        case when (select count(*) from pas_final where _26 = '0') - (select count(*) from pas_final) = '0'  then ' ' when (select count(*) from pas_final where _26 in ('3','4','5','6','7','9')) > 0 then  (select max(_26) from pas_final where _26 not in('','S')) else 'S'end _26,
        case when (select count(*) from pas_final where _27 = '0') - (select count(*) from pas_final) = '0'  then ' ' when (select count(*) from pas_final where _27 in ('3','4','5','6','7','9')) > 0 then  (select max(_27) from pas_final where _27 not in('','S')) else 'S'end _27,
        case when (select count(*) from pas_final where _28 = '0') - (select count(*) from pas_final) = '0'  then ' ' when (select count(*) from pas_final where _28 in ('3','4','5','6','7','9')) > 0 then  (select max(_28) from pas_final where _28 not in('','S')) else 'S'end _28,
        case when (select count(*) from pas_final where _29 = '0') - (select count(*) from pas_final) = '0'  then ' ' when (select count(*) from pas_final where _29 in ('3','4','5','6','7','9')) > 0 then  (select max(_29) from pas_final where _29 not in('','S')) else 'S'end _29,
        case when (select count(*) from pas_final where _30 = '0') - (select count(*) from pas_final) = '0'  then ' ' when (select count(*) from pas_final where _30 in ('3','4','5','6','7','9')) > 0 then  (select max(_30) from pas_final where _30 not in('','S')) else 'S'end _30
        from pas_final
        group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30
        into temp cadena_fin with no log;

        select _1||_2||_3||_4||_5||_6||_7||_8||_9||_10||_11||_12||_13||_14||_15||_16||_17||_18||_19||_20||_21||_22||_23||_24||_25||_26||_27||_28||_29||_30 
        into vcadena_pago
        from cadena_fin;

        drop table pas_fecha;
        drop table mat_paso;
        drop table pas_final;
        drop table cadena_fin;

        LET scod_ret  = "000";
        RETURN scod_ret, vcadena_pago;
END
END PROCEDURE;