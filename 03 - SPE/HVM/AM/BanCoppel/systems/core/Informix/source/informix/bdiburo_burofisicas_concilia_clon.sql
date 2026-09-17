create procedure "informix".burofisicas_concilia_clon()
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
   define cProceso                  char(4);
   define cMensaje                  char(50);   
   define iIsamErr                  integer;
   define vempresa                  char(3);
   define vcodret2                  char(5);
   
   let vcodret = "000";
   let cProceso = '0057';
   let cMensaje = '';
   let iIsamErr = 0;
   let vempresa = '001';
   let vcodret2 = '';
   
BEGIN

   on exception set iSqlErr, iIsamErr
      if iSqlErr != 0 then
         let vcodret = iSqlErr;
		 
		 let cMensaje = trim(vcodret) || ' - ' || iIsamErr;
	     CALL bdicobranza:sp_inserta_bitacora_cob(vempresa, cProceso, vcodret, cMensaje, '02') RETURNING vcodret2;
		 
         return vcodret;
      end if;
   end exception;

   
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
   let vfecha_reporte   = '';	
   let vclave_usu       = '';
   let vclave_usu_bc    = '';
   
   
--SET DEBUG FILE TO "/ifxsif01/macf/sics/burofisicas_concilia_clon.trc";
--TRACE ON; 

set isolation to dirty read;
set lock mode to wait 3;

   CALL bdicobranza:sp_inserta_bitacora_cob(vempresa, cProceso, vcodret, cMensaje, '01') RETURNING vcodret2; 

   select upper(valor) into vclave_usu
      from br_param
      where cod_param = 1;

   select upper(valor) into vclave_usu_bc
      from br_param
      where cod_param = 127;

	select  first 1 fecha_reporte  INTO vfecha_reporte
	from br_burofisicas_describe_clon;
	
   let vdia  = substr(vfecha_reporte,1,2);
   let vmes  = substr(vfecha_reporte,3,2);
   let vanio = substr(vfecha_reporte,5,4);
   let vfecha_cinta = mdy(vmes,vdia,vanio);

-- Extracción Círculo de Crédito
  let vsql = 'echo " unload to '''|| '/resplogifx/burodecredito/xburofis_clon.unl'''||" delimiter '|' "||
             '" > /resplogifx/burodecredito/genburofis_clon.sql';

  system vsql;
--                  ' trim(replace(replace(registro,'||'''BC30560001'''||','||'''TGD0924BAN'''||'),'||'''3002CV9903FIN'''||','||'''3002NV9903FIN'''||'))::lvarchar ' ||  
  let vsql = 'echo "'||
			 ' select registro from bdiburo:br_burofisicas_clon where numreg=1' ||
             ' union ' ||
             ' select case when substr(a.registro,1,2)='||'''TL'''||' and a.registro matches '||'''*3002CV9903FIN'''||' ' ||  
             ' THEN trim((select registro from bdiburo:br_burofisicas_clon where numreg=a.numreg-3))::lvarchar ||' || 
                  ' trim((select registro from bdiburo:br_burofisicas_clon where numreg=a.numreg-2))::lvarchar ||' ||
                  ' trim((select registro from bdiburo:br_burofisicas_clon where numreg=a.numreg-1))::lvarchar||' || 
--                  ' trim(replace(registro,'||'''BC30560001'''||','||'''TGD0924BAN'''||'))::lvarchar ' ||  
                  ' trim(replace(registro,'''||vclave_usu_bc||''','''||vclave_usu||'''))::lvarchar ' ||  
             ' ELSE trim((select registro from bdiburo:br_burofisicas_clon where numreg=a.numreg-3))::lvarchar||' ||
                  ' trim((select registro from bdiburo:br_burofisicas_clon where numreg=a.numreg-2))::lvarchar||' ||  
                  ' trim((select registro from bdiburo:br_burofisicas_clon where numreg=a.numreg-1))::lvarchar||' ||  
--                 ' trim(replace(registro,'||'''BC30560001'''||','||'''TGD0924BAN'''||'))::lvarchar' ||  
                 ' trim(replace(registro,'''||vclave_usu_bc||''','''||vclave_usu||'''))::lvarchar' ||  
             ' END' ||  
             ' from bdiburo:br_burofisicas_clon a where substr(a.registro,1,2)='||'''TL'''||' '||  
             ' union ' ||  
             ' select '||'''TRLR'''||'||lpad(sum(saldo_actual)::dec(14,0),14,'||'''0'''||')||'||''''''||'||lpad(sum(saldo_venc)::dec(14,0),14,'||'''0'''||')' ||  
             ' ||'||'''001'''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||' ||  
             ' '||'''000000000'''||'||'||''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||'''000000BANCOPPEL       '''||'||RPAD('||'''INSURGENTES SUR 553 PISO 6 COL. ESCANDON C.P. 11800 MEXICO D.F.'''||',160,'||'''*'''||') ' ||  
             ' from bdiburo:br_burofisicas_describe_clon;' ||
             ' " >> /resplogifx/burodecredito/genburofis_clon.sql';

  system vsql;

  let vsql = 'dbaccess bdiburo /resplogifx/burodecredito/genburofis_clon.sql';
  system vsql;

  let vsql = "sed 's/&/ /g' /resplogifx/burodecredito/xburofis_clon.unl > /resplogifx/burodecredito/xburofis1_clon.unl ";
  system vsql;

  let vsql = "sed 's/[~]*|//g' /resplogifx/burodecredito/xburofis1_clon.unl > /resplogifx/burodecredito/xburofis2_clon.unl ";
  system vsql;

  let vsql = "sed 's/|//g' /resplogifx/burodecredito/xburofis2_clon.unl > /resplogifx/burodecredito/xburofis1_clon.unl ";
  system vsql;

  --LET vsql = "cat  /resplogifx/burodecredito/xburofis1.unl | tr -d '\n' > /resplogifx/burodecredito/cinta_circulo"||vfecha_reporte||".txt ";
  LET vsql = "cat  /resplogifx/burodecredito/xburofis1_clon.unl | tr -d '\n' > /resplogifx/burodecredito/cinta_circulo_clon"||vfecha_reporte||".txt ";
  SYSTEM vsql;

  let vsql = "rm /resplogifx/burodecredito/xburofis_clon.unl /resplogifx/burodecredito/xburofis1_clon.unl /resplogifx/burodecredito/xburofis2_clon.unl";     
  system vsql;     

  let vsql = "gzip /resplogifx/burodecredito/cinta_circulo_clon"||vfecha_reporte||".txt ";
  system vsql;

  let vsql = '';

-- Extracción Buró de Crédito
  let vsql = 'echo " unload to '''|| '/resplogifx/burodecredito/xburofis_bc_clon.unl'''||" delimiter '|' "||
             '" > /resplogifx/burodecredito/genburofis_bc_clon.sql';

  system vsql;
--                  ' trim(replace(registro,'||'''3002CV9903FIN'''||','||'''3002NV9903FIN'''||'))::lvarchar ' ||  
  let vsql = 'echo "'||
--             ' select replace(registro,'||'''TGD0924BAN'''||','||'''BC30560001'''||') from bdiburo:br_burofisicas where numreg=1' ||
             ' select replace(registro,'''||vclave_usu||''','''||vclave_usu_bc||''') from bdiburo:br_burofisicas_clon where numreg=1' ||
             ' union ' ||
             ' select case when substr(a.registro,1,2)='||'''TL'''||' and a.registro matches '||'''*3002CV9903FIN'''||' ' ||
             ' THEN trim((select registro from bdiburo:br_burofisicas_clon where numreg=a.numreg-3))::lvarchar ||' ||  
                  ' trim((select registro from bdiburo:br_burofisicas_clon where numreg=a.numreg-2))::lvarchar ||' || 
                  ' trim((select registro from bdiburo:br_burofisicas_clon where numreg=a.numreg-1))::lvarchar||' || 
--                  ' trim(replace(registro,'||'''TGD0924BAN'''||','||'''BC30560001'''||'))::lvarchar ' || 
                  ' trim(replace(registro,'''||vclave_usu||''','''||vclave_usu_bc||'''))::lvarchar ' || 
             ' ELSE trim((select registro from bdiburo:br_burofisicas_clon where numreg=a.numreg-3))::lvarchar||' ||  
                  ' trim((select registro from bdiburo:br_burofisicas_clon where numreg=a.numreg-2))::lvarchar||' ||
                  ' trim((select registro from bdiburo:br_burofisicas_clon where numreg=a.numreg-1))::lvarchar||' ||  
--                  ' trim(replace(registro,'||'''TGD0924BAN'''||','||'''BC30560001'''||'))::lvarchar ' ||  
                  ' trim(replace(registro,'''||vclave_usu||''','''||vclave_usu_bc||'''))::lvarchar ' ||  
             ' END' ||  
--             ' from bdiburo:br_burofisicas a where substr(a.registro,1,2)='||'''TL'''||' and substr(registro,11,10)='||'''BC30560001'''||' '||  
             ' from bdiburo:br_burofisicas_clon a where substr(a.registro,1,2)='||'''TL'''||
             ' union ' ||  
             ' select '||'''TRLR'''||'||lpad(sum(saldo_actual)::dec(14,0),14,'||'''0'''||')||'||''''''||'||lpad(sum(saldo_venc)::dec(14,0),14,'||'''0'''||')' ||  
             ' ||'||'''001'''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||' ||  
             ' '||'''000000000'''||'||'||''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||'''000000BANCOPPEL       '''||'||RPAD('||'''INSURGENTES SUR 553 PISO 6 COL. ESCANDON C.P. 11800 MEXICO D.F.'''||',160,'||'''*'''||') ' ||  
--             ' from bdiburo:br_burofisicas_describe where num_credito in (select substr(registro,38,12) from bdiburo:br_burofisicas where substr(registro,1,2)='||'''TL'''||' and substr(registro,11,10)='||'''BC30560001'''||');' ||
             ' from bdiburo:br_burofisicas_describe_clon '||
             ' " >> /resplogifx/burodecredito/genburofis_bc_clon.sql';

  system vsql;

  let vsql = 'dbaccess bdiburo /resplogifx/burodecredito/genburofis_bc_clon.sql';
  system vsql;

  let vsql = "sed 's/&/ /g' /resplogifx/burodecredito/xburofis_bc_clon.unl > /resplogifx/burodecredito/xburofis1_bc_clon.unl ";
  system vsql;

  let vsql = "sed 's/[~]*|//g' /resplogifx/burodecredito/xburofis1_bc_clon.unl > /resplogifx/burodecredito/xburofis2_bc_clon.unl ";
  system vsql;

  let vsql = "sed 's/|//g' /resplogifx/burodecredito/xburofis2_bc_clon.unl > /resplogifx/burodecredito/xburofis1_bc_clon.unl ";
  system vsql;

  --LET vsql = "cat  /resplogifx/burodecredito/xburofis1_bc.unl | tr -d '\n' > /resplogifx/burodecredito/cinta_buro"||vfecha_reporte||".txt ";  --MACF
  LET vsql = "cat  /resplogifx/burodecredito/xburofis1_bc_clon.unl | tr -d '\n' > /resplogifx/burodecredito/cinta_buro_clon"||vfecha_reporte||".txt "; 
  SYSTEM vsql;

  let vsql = "rm /resplogifx/burodecredito/xburofis_bc_clon.unl /resplogifx/burodecredito/xburofis1_bc_clon.unl /resplogifx/burodecredito/xburofis2_bc_clon.unl";   
  system vsql;    

  let vsql = "gzip /resplogifx/burodecredito/cinta_buro_clon"||vfecha_reporte||".txt ";
  system vsql;

  let vsql = 'echo "------ CIFRAS GENERALES ------" > /resplogifx/burodecredito/cifrasdecontrol_clon'||vfecha_reporte||'.txt';
  system vsql;

  select count(*) into tb_total_cns from br_burofisicas_concilia_clon where empresa = '001' and motivo = 'CNS' and fecha_cinta = vfecha_cinta;

  let vsql = 'echo " Créditos excluidos por ser Clientes Nuevos = => '||tb_total_cns|| '" >> /resplogifx/burodecredito/cifrasdecontrol_clon'||vfecha_reporte||'.txt';
  system vsql;

  select count(*) into tb_total_no_procesados from br_burofisicas_concilia_clon where empresa = '001' and motivo = 'CNP' and fecha_cinta = vfecha_cinta;

  let vsql = 'echo " Créditos no procesados = => '||tb_total_no_procesados|| '" >> /resplogifx/burodecredito/cifrasdecontrol_clon'||vfecha_reporte||'.txt';
  system vsql;

  select int_calculo into iTotalProcesados from br_burofisicas_concilia_clon where empresa = '001' and motivo = 'TCP' and fecha_cinta = vfecha_cinta;
  
  let vsql = 'echo " TOTAL créditos procesados = => '||iTotalProcesados|| '" >> /resplogifx/burodecredito/cifrasdecontrol_clon'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " " >> /resplogifx/burodecredito/cifrasdecontrol_clon'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " " >> /resplogifx/burodecredito/cifrasdecontrol_clon'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo "------ CIFRAS BURO DE CREDITO ------" >> /resplogifx/burodecredito/cifrasdecontrol_clon'||vfecha_reporte||'.txt';
  system vsql;

--  select count(*) into tb_total_seg_tl_bc from bdiburo:br_burofisicas_describe where num_credito in (select substr(registro,38,12) from bdiburo:br_burofisicas where substr(registro,1,2)='TL' and substr(registro,11,10)='BC30560001');
  select count(*) into tb_total_seg_tl_bc from bdiburo:br_burofisicas_describe_clon where num_credito in (select substr(registro,38,12) from bdiburo:br_burofisicas_clon where substr(registro,1,2)='TL' and substr(registro,11,10)=vclave_usu);

  let vsql = 'echo " Créditos reportados = => '||tb_total_seg_tl_bc|| '" >> /resplogifx/burodecredito/cifrasdecontrol_clon'||vfecha_reporte||'.txt';
  system vsql;

  select count(*) into tb_total_cps_bc from br_burofisicas_concilia_clon where empresa = '001' and motivo = 'CPS' and fecha_cinta = vfecha_cinta;

  let vsql = 'echo " Créditos excluidos por error en Código Postal = => '||tb_total_cps_bc|| '" >> /resplogifx/burodecredito/cifrasdecontrol_clon'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " Créditos excluidos por ser Clientes Nuevos = => '||tb_total_cns|| '" >> /resplogifx/burodecredito/cifrasdecontrol_clon'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " Créditos no procesados = => '||tb_total_no_procesados|| '" >> /resplogifx/burodecredito/cifrasdecontrol_clon'||vfecha_reporte||'.txt';
  system vsql;

--  let vsql = 'echo " TOTAL Créditos procesados Buró de Crédito = => '||tb_total_seg_tl_bc+tb_total_cps_bc+tb_total_cns+tb_total_no_procesados|| '" >> /resplogifx/burodecredito/cifrasdecontrol'||vfecha_reporte||'.txt';
  let vsql = 'echo " TOTAL Créditos procesados Buró de Crédito = => '||tb_total_seg_tl_bc+tb_total_cns+tb_total_no_procesados|| '" >> /resplogifx/burodecredito/cifrasdecontrol_clon'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " " >> /resplogifx/burodecredito/cifrasdecontrol_clon'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo "------ S a l d o s  Reportados a Buró de Crédito------" >> /resplogifx/burodecredito/cifrasdecontrol_clon'||vfecha_reporte||'.txt';
  system vsql;

  --select lpad(sum(saldo_actual)::dec(14,0),14,"0"),lpad(sum(saldo_venc)::dec(14,0),14,"0") into tb_total_sdo_actual_bc,tb_total_sdo_vencido_bc
  --from bdiburo:br_burofisicas_describe where num_credito in (select substr(registro,38,12) from bdiburo:br_burofisicas where substr(registro,1,2)='TL' and substr(registro,11,10)=vclave_usu);
  select lpad(sum(saldo_actual)::dec(14,0),14,"0"),lpad(sum(saldo_venc)::dec(14,0),14,"0") into tb_total_sdo_actual_bc,tb_total_sdo_vencido_bc
  from bdiburo:br_burofisicas_describe_clon where num_tarjeta in (select substr(registro,38,16) from bdiburo:br_burofisicas_clon where substr(registro,1,2)='TL' and substr(registro,11,10)=vclave_usu);
--  from bdiburo:br_burofisicas_describe where num_credito in (select substr(registro,38,12) from bdiburo:br_burofisicas where substr(registro,1,2)='TL' and substr(registro,11,10)='BC30560001');

  let vsql = 'echo " Saldo actual = => '||tb_total_sdo_actual_bc|| '" >> /resplogifx/burodecredito/cifrasdecontrol_clon'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " Saldo vencido = => '||tb_total_sdo_vencido_bc|| '" >> /resplogifx/burodecredito/cifrasdecontrol_clon'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " " >> /resplogifx/burodecredito/cifrasdecontrol_clon'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " " >> /resplogifx/burodecredito/cifrasdecontrol_clon'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo "------ CIFRAS CIRCULO DE CREDITO ------" >> /resplogifx/burodecredito/cifrasdecontrol_clon'||vfecha_reporte||'.txt';
  system vsql;

--  select count(*) into tb_total_seg_tl from bdiburo:br_burofisicas_describe; 

--  let vsql = 'echo " Créditos reportados = => '||tb_total_seg_tl|| '" >> /resplogifx/burodecredito/cifrasdecontrol'||vfecha_reporte||'.txt';
  let vsql = 'echo " Créditos reportados = => '||tb_total_seg_tl_bc|| '" >> /resplogifx/burodecredito/cifrasdecontrol_clon'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " Créditos excluidos por ser Clientes Nuevos = => '||tb_total_cns|| '" >> /resplogifx/burodecredito/cifrasdecontrol_clon'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " Créditos no procesados = => '||tb_total_no_procesados|| '" >> /resplogifx/burodecredito/cifrasdecontrol_clon'||vfecha_reporte||'.txt';
  system vsql;

--  let vsql = 'echo " TOTAL Créditos procesados Círculo de Crédito = => '||tb_total_seg_tl + tb_total_cns + tb_total_no_procesados|| '" >> /resplogifx/burodecredito/cifrasdecontrol'||vfecha_reporte||'.txt';
  let vsql = 'echo " TOTAL Créditos procesados Círculo de Crédito = => '||tb_total_seg_tl_bc + tb_total_cns + tb_total_no_procesados|| '" >> /resplogifx/burodecredito/cifrasdecontrol_clon'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " " >> /resplogifx/burodecredito/cifrasdecontrol_clon'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo "------ S a l d o s  Reportados a Círculo de Crédito------" >> /resplogifx/burodecredito/cifrasdecontrol_clon'||vfecha_reporte||'.txt';
  system vsql;

--  select lpad(sum(saldo_actual)::dec(14,0),14,"0"),lpad(sum(saldo_venc)::dec(14,0),14,"0") into tb_total_sdo_actual,tb_total_sdo_vencido
--  from bdiburo:br_burofisicas_describe;

--  let vsql = 'echo " Saldo actual = => '||tb_total_sdo_actual|| '" >> /resplogifx/burodecredito/cifrasdecontrol'||vfecha_reporte||'.txt';
  let vsql = 'echo " Saldo actual = => '||tb_total_sdo_actual_bc|| '" >> /resplogifx/burodecredito/cifrasdecontrol_clon'||vfecha_reporte||'.txt';
  system vsql;

--  let vsql = 'echo " Saldo vencido = => '||tb_total_sdo_vencido|| '" >> /resplogifx/burodecredito/cifrasdecontrol'||vfecha_reporte||'.txt';
  let vsql = 'echo " Saldo vencido = => '||tb_total_sdo_vencido_bc|| '" >> /resplogifx/burodecredito/cifrasdecontrol_clon'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " " >> /resplogifx/burodecredito/cifrasdecontrol_clon'||vfecha_reporte||'.txt';
  system vsql;

  CALL bdicobranza:sp_inserta_bitacora_cob(vempresa, cProceso, vcodret, cMensaje, '03') RETURNING vcodret2; 
  
  return vcodret;

END;
end procedure;