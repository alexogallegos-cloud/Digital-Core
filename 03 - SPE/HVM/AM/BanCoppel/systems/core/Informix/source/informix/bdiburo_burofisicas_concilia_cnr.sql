create procedure "informix".burofisicas_concilia_cnr()
--EXECUTE PROCEDURE burofisicas_concilia_cnr();
       returning char(5);


   define vcodret                   char(5);
   define vsql                      char(1500);
   define iTotalProcesados          integer;
   define iSqlErr                   integer;
   define tb_total_sdo_actual       decimal(20,2);
   define tb_total_sdo_vencido      decimal(20,2);
   define tb_total_seg_tl           decimal(20);
   define tb_total_sdo_actual_bc    decimal(20,2);
   define tb_total_sdo_vencido_bc   decimal(20,2);
   define tb_total_seg_tl_bc        decimal(20);
   define tb_total_cps_bc           integer;
   define tb_total_cns              integer;
   define tb_total_no_procesados    integer;
   define vdia                      char(02);
   define vmes                      char(02);
   define vanio                     char(4);
   define vfecha_cinta              date;
   define vfecha_reporte 			char(08);   
   define vclave_usu                char(10);
   define vclave_usu_bc             char(10);

BEGIN

   on exception set iSqlErr
      if iSqlErr != 0 then
         let vcodret = iSqlErr;
         return vcodret;
      end if;
   end exception;

   let vcodret = "000";
   let vsql = "";
   let iTotalProcesados = 0;
   let tb_total_sdo_actual     = 0;
   let tb_total_sdo_vencido    = 0;
   let tb_total_seg_tl         = 0;
   let tb_total_seg_tl_bc      = 0;
   let tb_total_sdo_actual_bc  = 0;
   let tb_total_sdo_vencido_bc = 0;
   let tb_total_cps_bc         = 0;
   let tb_total_cns         = 0;
   let tb_total_no_procesados  = 0;
   let vdia  = '';
   let vmes  = '';
   let vanio = '';
   let vfecha_cinta = date(0);
   let vfecha_reporte = '';
   let vclave_usu   = '';
   let vclave_usu_bc    = '';

--SET DEBUG FILE TO "burofisicas_concilia_cnr.out";
--TRACE ON; 

set isolation to dirty read;
set lock mode to wait 3;

   select upper(valor) into vclave_usu
      from br_param
      where cod_param = 1;

   select upper(valor) into vclave_usu_bc
      from br_param
      where cod_param = 128;

	select  first 1 fecha_reporte  INTO vfecha_reporte
	from br_burofisicas_describe_cnr;

   let vdia  = substr(vfecha_reporte,1,2);
   let vmes  = substr(vfecha_reporte,3,2);
   let vanio = substr(vfecha_reporte,5,4);
   let vfecha_cinta = mdy(vmes,vdia,vanio);



-- Extracción Círculo de Crédito
  let vsql = 'echo " unload to '''|| '/resplogifx/burodecredito/xburofiscnr.unl'''||" delimiter '|' "||
             '" > /resplogifx/burodecredito/genburofiscnr.sql';
  system vsql;

  let vsql = 'echo "'||
             ' select registro from bdiburo:br_burofisicas_cnr where numreg=1' ||
             ' union ' ||
             ' select case when substr(a.registro,1,2)='||'''TL'''||' and a.registro matches '||'''*3002CV9903FIN'''||' ' ||  
             ' THEN trim((select registro from bdiburo:br_burofisicas_cnr where numreg=a.numreg-3))::lvarchar ||' || 
                  ' trim((select registro from bdiburo:br_burofisicas_cnr where numreg=a.numreg-2))::lvarchar ||' ||
                  ' trim((select registro from bdiburo:br_burofisicas_cnr where numreg=a.numreg-1))::lvarchar||' || 
--                  ' trim(replace(registro,'||'''BY30560001'''||','||'''TGD0924BAN'''||'))::lvarchar ' ||  
                  ' trim(replace(registro,'''||vclave_usu_bc||''','''||vclave_usu||'''))::lvarchar ' ||  
             ' ELSE trim((select registro from bdiburo:br_burofisicas_cnr where numreg=a.numreg-3))::lvarchar||' ||  
                  ' trim((select registro from bdiburo:br_burofisicas_cnr where numreg=a.numreg-2))::lvarchar||' ||  
                  ' trim((select registro from bdiburo:br_burofisicas_cnr where numreg=a.numreg-1))::lvarchar||' ||
--                 ' trim(replace(registro,'||'''BY30560001'''||','||'''TGD0924BAN'''||'))::lvarchar' ||  
                 ' trim(replace(registro,'''||vclave_usu_bc||''','''||vclave_usu||'''))::lvarchar' ||  
             ' END' ||  
             ' from bdiburo:br_burofisicas_cnr a where substr(a.registro,1,2)='||'''TL'''||' '||  
             ' union ' ||  
             ' select '||'''TRLR'''||'||lpad(sum(saldo_actual)::dec(14,0),14,'||'''0'''||')||'||''''''||'||lpad(sum(saldo_venc)::dec(14,0),14,'||'''0'''||')' ||  
			 ' ||'||'''001'''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||  ''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||   ''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||
             '''000000BANCOPPEL       '''||'||RPAD('||'''INSURGENTES SUR 553 PISO 6 COL. ESCANDON C.P. 11800 MEXICO D.F.'''||',160,'||'''*'''||') ' ||  			 
             --' ||'||'''001'''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||' ||  
             --' '||'''000000000'''||'||'||''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||'''000000BANCOPPEL       '''||'||RPAD('||'''INSURGENTES SUR 553 PISO 6 COL. ESCANDON C.P. 11800 MEXICO D.F.'''||',160,'||'''*'''||') ' ||  
             ' from bdiburo:br_burofisicas_describe_cnr where fecha_reporte = '''|| vfecha_reporte ||''';' ||
             ' " >> /resplogifx/burodecredito/genburofiscnr.sql';
 system vsql;

  let vsql = 'dbaccess bdiburo /resplogifx/burodecredito/genburofiscnr.sql';
  system vsql;

  let vsql = "sed 's/&/ /g' /resplogifx/burodecredito/xburofiscnr.unl > /resplogifx/burodecredito/xburofis1cnr.unl ";
  system vsql;

  let vsql = "sed 's/[~]*|//g' /resplogifx/burodecredito/xburofis1cnr.unl > /resplogifx/burodecredito/xburofis2cnr.unl ";
  system vsql;

  let vsql = "sed 's/|//g' /resplogifx/burodecredito/xburofis2cnr.unl > /resplogifx/burodecredito/xburofis1cnr.unl ";
  system vsql;

  LET vsql = "cat  /resplogifx/burodecredito/xburofis1cnr.unl | tr -d '\n' > /resplogifx/burodecredito/cinta_circulocnr"||vfecha_reporte||".txt ";
  SYSTEM vsql;

  let vsql = "gzip /resplogifx/burodecredito/cinta_circulocnr"||vfecha_reporte||".txt ";
  system vsql;

  let vsql = "rm /resplogifx/burodecredito/xburofiscnr.unl /resplogifx/burodecredito/xburofis1cnr.unl /resplogifx/burodecredito/xburofis2cnr.unl";    
  system vsql;   

  let vsql = '';


-- Extracción Buró de Crédito
  let vsql = 'echo " unload to '''|| '/resplogifx/burodecredito/xburofis_bccnr.unl'''||" delimiter '|' "||
             '" > /resplogifx/burodecredito/genburofis_bccnr.sql';
  system vsql;

  let vsql = 'echo "'||
--             ' select replace(registro,'||'''TGD0924BAN'''||','||'''BY30560001'''||') from bdiburo:br_burofisicas_cnr where numreg=1' ||
             ' select replace(registro,'''||vclave_usu||''','''||vclave_usu_bc||''') from bdiburo:br_burofisicas_cnr where numreg=1' ||
             ' union ' ||
/*
             ' select case when a.registro matches '||'''*0208CONOCIDO*'''||' ' ||  
                   ' THEN trim(replace(registro,'||'''0208CONOCIDO'''||','||''''''||'))::lvarchar ' ||  
             ' else a.registro END ' ||
             '   from bdiburo:br_burofisicas_cnr a where substr(a.registro,1,2)='||'''PA'''||' ' ||  
             ' union ' ||
*/
             ' select case when substr(a.registro,1,2)='||'''TL'''||' and a.registro matches '||'''*3002CV9903FIN'''||' ' ||  
             ' THEN trim((select registro from bdiburo:br_burofisicas_cnr where numreg=a.numreg-3))::lvarchar ||' ||
                  ' trim((select registro from bdiburo:br_burofisicas_cnr where numreg=a.numreg-2))::lvarchar||' || 
                  ' trim((select registro from bdiburo:br_burofisicas_cnr where numreg=a.numreg-1))::lvarchar||' || 
--                  ' trim(replace(registro,'||'''3002CV9903FIN'''||','||'''3002CV9903FIN'''||'))::lvarchar ' ||  
--                 ' trim(replace(registro,'||'''TGD0924BAN'''||','||'''BY30560001'''||'))::lvarchar' ||  
                 ' trim(replace(registro,'''||vclave_usu||''','''||vclave_usu_bc||'''))::lvarchar' ||  
             ' ELSE trim((select registro from bdiburo:br_burofisicas_cnr where numreg=a.numreg-3))::lvarchar||' ||
                  ' trim((select registro from bdiburo:br_burofisicas_cnr where numreg=a.numreg-2))::lvarchar||' ||  
                  ' trim((select registro from bdiburo:br_burofisicas_cnr where numreg=a.numreg-1))::lvarchar||' ||  
--                 ' trim(registro)::lvarchar' ||  
--                 ' trim(replace(registro,'||'''TGD0924BAN'''||','||'''BY30560001'''||'))::lvarchar' ||  
                 ' trim(replace(registro,'''||vclave_usu||''','''||vclave_usu_bc||'''))::lvarchar' ||  
             ' END' ||  
             ' from bdiburo:br_burofisicas_cnr a where substr(a.registro,1,2)='||'''TL'''||' '||  
             ' union ' ||  
             ' select '||'''TRLR'''||'||lpad(sum(saldo_actual)::dec(14,0),14,'||'''0'''||')||'||''''''||'||lpad(sum(saldo_venc)::dec(14,0),14,'||'''0'''||')' ||  
             --' ||'||'''001'''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||' ||  
             --' '||'''000000000'''||'||'||''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||'''000000BANCOPPEL       '''||'||RPAD('||'''INSURGENTES SUR 553 PISO 6 COL. ESCANDON C.P. 11800 MEXICO D.F.'''||',160,'||'''*'''||') ' ||  
             ' ||'||'''001'''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||  ''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||   ''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||
             '''000000BANCOPPEL       '''||'||RPAD('||'''INSURGENTES SUR 553 PISO 6 COL. ESCANDON C.P. 11800 MEXICO D.F.'''||',160,'||'''*'''||') ' ||  			 
             ' from bdiburo:br_burofisicas_describe_cnr where fecha_reporte = '''|| vfecha_reporte ||'''' ||
             ' " >> /resplogifx/burodecredito/genburofis_bccnr.sql';
 system vsql;

  let vsql = 'dbaccess bdiburo /resplogifx/burodecredito/genburofis_bccnr.sql';
  system vsql;

  let vsql = "sed 's/&/ /g' /resplogifx/burodecredito/xburofis_bccnr.unl > /resplogifx/burodecredito/xburofis1_bccnr.unl ";
  system vsql;

  let vsql = "sed 's/[~]*|//g' /resplogifx/burodecredito/xburofis1_bccnr.unl > /resplogifx/burodecredito/xburofis2_bccnr.unl ";
  system vsql;

  let vsql = "sed 's/|//g' /resplogifx/burodecredito/xburofis2_bccnr.unl > /resplogifx/burodecredito/xburofis1_bccnr.unl ";
  system vsql;

  LET vsql = "cat  /resplogifx/burodecredito/xburofis1_bccnr.unl | tr -d '\n' > /resplogifx/burodecredito/cinta_burocnr"||vfecha_reporte||".txt ";
  SYSTEM vsql;

  let vsql = "rm /resplogifx/burodecredito/xburofis_bccnr.unl /resplogifx/burodecredito/xburofis1_bccnr.unl /resplogifx/burodecredito/xburofis2_bccnr.unl";   
  system vsql;    

  let vsql = "gzip /resplogifx/burodecredito/cinta_burocnr"||vfecha_reporte||".txt ";
  system vsql;

  let vsql = 'echo "------ CIFRAS GENERALES ------" > /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  select count(*) into tb_total_cns from br_burofisicas_concilia_cnr where empresa = '001' and motivo = 'CNS' and fecha_cinta = vfecha_cinta;

  let vsql = 'echo " Créditos excluidos por ser Clientes Nuevos = => '||tb_total_cns|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  select count(*) into tb_total_no_procesados from br_burofisicas_concilia_cnr where empresa = '001' and motivo = 'CNP' and fecha_cinta = vfecha_cinta;

  let vsql = 'echo " Créditos no procesados = => '||tb_total_no_procesados|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  select int_calculo into iTotalProcesados from br_burofisicas_concilia_cnr where empresa = '001' and motivo = 'TCP' and fecha_cinta = vfecha_cinta;
  
  let vsql = 'echo " TOTAL créditos procesados = => '||iTotalProcesados|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " " >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " " >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo "------ CIFRAS BURO DE CREDITO ------" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

	

	SELECT --{+INDEX(br_burofisicas_cnr idx_burofisicas_cnr_reg)} 
		registro FROM bdiburo:br_burofisicas_cnr INTO TEMP reg_tl WITH NO LOG; -- ** RQI 21 331 

--  select count(*) into tb_total_seg_tl_bc from bdiburo:br_burofisicas_describe_cnr where num_credito in (select substr(registro,38,12) from bdiburo:br_burofisicas_cnr where substr(registro,1,2)='TL' and substr(registro,11,10)='BY30560001');
  --select count(*) into tb_total_seg_tl_bc from bdiburo:br_burofisicas_describe_cnr where num_credito in (select substr(registro,38,12) from bdiburo:br_burofisicas_cnr where substr(registro,1,2)='TL' and substr(registro,11,10)=vclave_usu);
  select count(*) into tb_total_seg_tl_bc from bdiburo:br_burofisicas_describe_cnr where num_credito in (select substr(registro,38,12) from reg_tl where substr(registro,1,2)='TL' and substr(registro,11,10)=vclave_usu);

  let vsql = 'echo " Créditos reportados = => '||tb_total_seg_tl_bc|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  select count(*) into tb_total_cps_bc from br_burofisicas_concilia_cnr where empresa = '001' and motivo = 'CPS' and fecha_cinta = vfecha_cinta;

  let vsql = 'echo " Créditos excluidos por error en CÃ?Â³digo Postal = => '||tb_total_cps_bc|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " Créditos excluidos por ser Clientes Nuevos = => '||tb_total_cns|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " Créditos no procesados = => '||tb_total_no_procesados|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

--  let vsql = 'echo " TOTAL Créditos procesados Buró de Crédito = => '||tb_total_seg_tl_bc+tb_total_cps_bc+tb_total_cns+tb_total_no_procesados|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  let vsql = 'echo " TOTAL Créditos procesados Buró de Crédito = => '||tb_total_seg_tl_bc+tb_total_cns+tb_total_no_procesados|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " " >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo "------ S a l d o s  Reportados a Buró de Crédito------" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  --select lpad(sum(saldo_actual)::dec(14,0),14,"0"),lpad(sum(saldo_venc)::dec(14,0),14,"0") into tb_total_sdo_actual_bc,tb_total_sdo_vencido_bc
  --from bdiburo:br_burofisicas_describe_cnr where num_credito in (select substr(registro,38,12) from bdiburo:br_burofisicas_cnr where substr(registro,1,2)='TL' and substr(registro,11,10)=vclave_usu);
  select lpad(sum(saldo_actual)::dec(14,0),14,"0"),lpad(sum(saldo_venc)::dec(14,0),14,"0") into tb_total_sdo_actual_bc,tb_total_sdo_vencido_bc
  from bdiburo:br_burofisicas_describe_cnr where num_credito in (select substr(registro,38,12) from reg_tl where substr(registro,1,2)='TL' and substr(registro,11,10)=vclave_usu);
--  from bdiburo:br_burofisicas_describe_cnr where num_credito in (select substr(registro,38,12) from bdiburo:br_burofisicas_cnr where substr(registro,1,2)='TL' and substr(registro,11,10)='BY30560001');

  let vsql = 'echo " Saldo actual = => '||tb_total_sdo_actual_bc|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " Saldo vencido = => '||tb_total_sdo_vencido_bc|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " " >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " " >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo "------ CIFRAS CIRCULO DE CREDITO ------" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

--  select count(*) into tb_total_seg_tl from bdiburo:br_burofisicas_describe_cnr; 

--  let vsql = 'echo " Créditos reportados = => '||tb_total_seg_tl|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  let vsql = 'echo " Créditos reportados = => '||tb_total_seg_tl_bc|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " Créditos excluidos por ser Clientes Nuevos = => '||tb_total_cns|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " Créditos no procesados = => '||tb_total_no_procesados|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

--  let vsql = 'echo " TOTAL Créditos procesados Círculo de Crédito = => '||tb_total_seg_tl + tb_total_cns + tb_total_no_procesados|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  let vsql = 'echo " TOTAL Créditos procesados Círculo de Crédito = => '||tb_total_seg_tl_bc + tb_total_cns + tb_total_no_procesados|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " " >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo "------ S a l d o s  Reportados a Círculo de Crédito------" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

--  select lpad(sum(saldo_actual)::dec(14,0),14,"0"),lpad(sum(saldo_venc)::dec(14,0),14,"0") into tb_total_sdo_actual,tb_total_sdo_vencido
--  from bdiburo:br_burofisicas_describe_cnr;

--  let vsql = 'echo " Saldo actual = => '||tb_total_sdo_actual|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  let vsql = 'echo " Saldo actual = => '||tb_total_sdo_actual_bc|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

--  let vsql = 'echo " Saldo vencido = => '||tb_total_sdo_vencido|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  let vsql = 'echo " Saldo vencido = => '||tb_total_sdo_vencido_bc|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " " >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;
  
	BEGIN;
		DROP INDEX "informix".idx_burofisicas_cnr_reg;
	COMMIT;
	
	UPDATE STATISTICS MEDIUM FOR TABLE "informix".br_burofisicas_cnr;

  return vcodret;

END;
end procedure;