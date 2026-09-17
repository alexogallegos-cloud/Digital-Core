create procedure "informix".burocred1(pempresa char(3),psucursal char(4),pusuario char(8),
		pSolicitud char(20),pMontoSol money(14,2))
RETURNING CHAR(05);

	define vregistro char(255);
	define vregistro1 char(255);
        define vregistro2 char(255);
	define vcliente char(20);
	define vlen integer;
	define vmonto money(14,2);
	define vpos char(2);
	define vpo1 char(5);
	define vdia char(2);
	define vmes char(2);
	define vanio char(4);
	-- Variables para ver si se va a Buro o no --
	define vfconbr date;
	define vf1mes date;
	define vstatus char(2);
	define vcodret char(5);
	define vapell_pat char(15);
	define vecampo1 char(4);
	define vecampo2 char(2);
	define vecampo3 char(25);
	define vecampo4 char(3);
	define vecampo5 char(2);
	define vecampo6 char(4);
	define vecampo7 char(10);
	define vecampo8 char(8);
	define vecampo9 char(1);
	define vecampo10 char(2);
	define vecampo11 char(2);
	define vecampo12 char(9);
	define vecampo13 char(2);
	define vecampo14 char(2);
	define vecampo15 char(1);
	define vecampo16 char(4);
	define vecampo17 char(7);
	define vexiste integer;
	-- Datos del Cliente --
	define vdcampo1 char(2);
	define vdcampo2 char(26);
	define vdcampo3 char(26);
	define vdcampo4 char(26);
	define vdcampo5 char(26);
	define vdcampo6 char(10);
	define vdcampo7 char(13);
	define vdcampo8 char(2);
	define vdcampo9 char(1);
	define vdcampo10 char(1);
	define vdcampo11 char(1);
	define vdcampo12 char(2);
	define vscampo1 char(2);
	define vscampo2 char(40);
	define vscampo3 char(40);
	define vscampo4 char(40);
	define vscampo5 char(40);
	define vscampo6 char(40);
	define vscampo7 char(4);
	define vscampo8 char(5);
	define vscampo9 char(1);
        define vexiste1 smallint;
        define vquita char(40);
        define vespacio char(1);
        define archivo char(40);
        define vsql		 char(200);
        define vruta_interfase	 char(200);
        define varchivo	 char(60);
        define vretorno nchar(800);
        define vmanzana smallint;
        define vandador smallint;
        define vlote smallint;
        define vedificio smallint;
        define ventrada smallint;
        define vsecuencia smallint;
	LET vregistro ="";
	LET vcliente ="";
	let vlen =0;
	let vmonto =0;
	let vpos="";
	let vdia="";
	let vmes="";
	let vanio="";
	let vfconbr="";
	let vf1mes="";
	let vstatus="";
	let vcodret="000";
	let vapell_pat="";
	let vretorno = "";


    select status_solicitud into vstatus
    from bdisolic:ss_solicitudes where num_solicitud =pSolicitud;

    if trim(vstatus) = "RR" THEN
           let vregistro="ERRRUR25";
           let vcodret="260";
	   return vcodret;
    end if

   -- Declaracion de Constantes para Generacion de Registro s desea ver que significa cada campo
   -- Favor de consultar el manual -->
	let vecampo1="INTL";
	let vecampo2="11";
	let vecampo3="                         ";
	let vecampo4="001";
	let vecampo5="MX";
	let vecampo6="0000";
	--let vecampo7="PMI0865RDC"; --usuario
	--let vecampo8="08T0PM69";  --password
	let vecampo9="I";
	let vecampo10="BB";
	let vecampo11="MX";
	let vecampo12="0"; --monto solicitado
	let vecampo13="SP";
	let vecampo14="03";
	let vecampo15=" ";
	let vecampo16="    ";
	let vecampo17="0000000";
	let vexiste=0;
select trim(valor) into vecampo7
  from bdiburo:br_param
  where cod_param = 1;
select trim(valor) into vecampo8
  from bdiburo:br_param
  where cod_param = 2;
  let vecampo12=lpad(round(pMontoSol,0),9,"0");
  let vregistro= vecampo1||vecampo2||vecampo3||vecampo4||vecampo5||
	     vecampo6||vecampo7||vecampo8||vecampo9||vecampo10||vecampo11||vecampo12||vecampo13||
	     vecampo14||vecampo15||vecampo16||vecampo17;
	-- Datos del Cliente --
	let vdcampo1="PN"; --Identificador de cadena--
	let vdcampo2=""; --Apellido Paterno PN--
	let vdcampo3=""; --Apellido Materno 00--
	let vdcampo4=""; --Primer Nombre 02--
	let vdcampo5=""; --Segundo Nombre 03--
	let vdcampo6=""; --Fecha de Nacimiento 04--
	let vdcampo7=""; --RFC 05--
	let vdcampo8="MX"; --Nacionalidad MX o EX 08--
	let vdcampo9=""; --Residencia o Tipo Vivienda 09 1=Prop 2=Renta 3=Pension--
	let vdcampo10=""; --Estado Civil 11 --
	let vdcampo11=""; --Sexo 12--
	let vdcampo12=""; --Dependiente 17--
	-- Direccion del Cliente --
	let vscampo1="PA"; --Identificador de cadena--
	let vscampo2=""; --Direccion Linea 1 PA--
	let vscampo3=""; --Direccion Linea 2 00--
	let vscampo4=""; --Colonia o Poblacion 01--
	let vscampo5=""; --Delegacion o Municipio 02--
	let vscampo6=""; --Nombre Ciudad 03--
	let vscampo7=""; --Estado 04--
	let vscampo8=""; --Codigo Postal 05--
	let vscampo9=""; --Tipo de Domicilio 10--

        select numcte into vcliente
              from bdisolic:ss_solicitudes  where num_solicitud =pSolicitud;

--	select count(*) into vexiste from bdisolic:ss_histburo where num_solicitud = vcliente;
  --      if vexiste = 0 then
	--   let vexiste=0;
	--   let vfconbr="";
        --   insert into bdisolic:ss_histburo values(vcliente,vfecha_hoy);
      --  else
    	--  select fecha_consulta into vfconbr
 		--      from bdisolic:ss_histburo  where num_solicitud = vcliente;
-- 	end if
--	select pri_dia_mes into vf1mes  from bdicred:sd_fechas;
	-- Regresa sin Valor si tengo una consulta en el Mes --
	--if vexiste >=1 then
  	  -- if vfconbr >= vf1mes then
		--let vregistro="";
	--	return vcodret;
	  -- end if
--	end if
	select Trim(apell_paterno), Trim(apell_materno), Trim(nombre1),
  	        Trim(nombre2),fecha_nac, Trim(rfc), Trim(habita_en), Trim(estado_civil),
  	        Trim(sexo), nvl(dependientes,"0")
		    INTO vdcampo2,vdcampo3,vdcampo4,vdcampo5,vdcampo6,
		        vdcampo7,vdcampo9,vdcampo10,vdcampo11,vdcampo12
		    FROM bdinteg:si_cliente a, bdinteg:si_ctepf b
		    WHERE a.numcte = b.numcte  and b.numcte = vcliente;

	  -- Cambia las Ñ de los Nombres y Apellidos --

         let vexiste = length(vdcampo2);
         let vexiste1 = 0;
         let vquita = "";
         let vespacio = " ";
         while vexiste1 < vexiste
           if vdcampo2[1,1]="~" or vdcampo2[1,1]=" " or vdcampo2[1,1]="." then
              let vespacio = "F";
           else
             if vespacio = "F" then
               if vdcampo2[1,1] = "#" then
                 let vquita = trim(vquita)||" Ñ";
               else
                 let vquita = trim(vquita)||" "||vdcampo2[1,1];
               end if
               let vespacio ="";
             else
               if vdcampo2[1,1] = "#" then
                 let vquita = trim(vquita)||"Ñ";
               else
                 let vquita = trim(vquita)||vdcampo2[1,1];
               end if
             end if
           end if;
           let vdcampo2 = vdcampo2[2,26];
           let vexiste1 = vexiste1 + 1;
         end while;
         let vdcampo2 = trim(vquita);
         let vexiste = length(vdcampo3);
         let vexiste1 = 0;
         let vquita = "";
         let vespacio = " ";
         while vexiste1 < vexiste
           if vdcampo3[1,1]="~" or vdcampo3[1,1]=" " or vdcampo3[1,1]="." then
              let vespacio = "F";
           else
             if vespacio = "F" then
               if vdcampo3[1,1] = "#" then
                 let vquita = trim(vquita)||" Ñ";
               else
                 let vquita = trim(vquita)||" "||vdcampo3[1,1];
               end if
               let vespacio ="";
             else
               if vdcampo3[1,1] = "#" then
                 let vquita = trim(vquita)||"Ñ";
               else
                 let vquita = trim(vquita)||vdcampo3[1,1];
               end if
             end if
           end if;
           let vdcampo3 = vdcampo3[2,26];
           let vexiste1 = vexiste1 + 1;
         end while;
         let vdcampo3 = trim(vquita);
         let vexiste = length(vdcampo4);
         let vexiste1 = 0;
         let vquita = "";
         let vespacio = " ";
         while vexiste1 < vexiste
           if vdcampo4[1,1]="~" or vdcampo4[1,1]=" "  or vdcampo4[1,1]="." then
              let vespacio = "F";
           else
             if vespacio = "F" then
               if vdcampo4[1,1] = "#" then
                 let vquita = trim(vquita)||" Ñ";
               else
                 let vquita = trim(vquita)||" "||vdcampo4[1,1];
               end if
               let vespacio ="";
             else
               if vdcampo4[1,1] = "#" then
                 let vquita = trim(vquita)||"Ñ";
               else
                 let vquita = trim(vquita)||vdcampo4[1,1];
               end if
             end if
           end if;
           let vdcampo4 = vdcampo4[2,26];
           let vexiste1 = vexiste1 + 1;
         end while;
         let vdcampo4 = trim(vquita);
         let vexiste = length(vdcampo5);
         let vexiste1 = 0;
         let vquita = "";
         let vespacio =" ";
         while vexiste1 < vexiste
           if vdcampo5[1,1]="~" or vdcampo5[1,1]=" " or vdcampo5[1,1]="." then
              let vespacio ="F";
           else
            if vespacio = "F" then
               if vdcampo5[1,1] = "#" then
                 let vquita = trim(vquita)||" Ñ";
               else
                 let vquita = trim(vquita)||" "||vdcampo5[1,1];
               end if
	       let vespacio ="";
            else
               if vdcampo5[1,1] = "#" then
                 let vquita = trim(vquita)||"Ñ";
               else
                 let vquita = trim(vquita)||vdcampo5[1,1];
               end if
            end if
           end if;
           let vdcampo5 = vdcampo5[2,26];
           let vexiste1 = vexiste1 + 1;
         end while;
         let vdcampo5 = trim(vquita);
         if vdcampo9 ="01" or vdcampo9 ="05" Then
	       	   let vdcampo9="1";
	 else
	   if vdcampo9 ="02" Then
	    let vdcampo9="2";
	   else
	     if vdcampo9 ="03"  or vdcampo9 = "04" Then
	       let vdcampo9="3";
	     else
	      let vdcampo9="0";
	     end if
	   end if
	 end if
         if vdcampo10 ="D" Then
	       	   let vdcampo10="D";
	 else
	   if vdcampo10 ="U" Then
	    let vdcampo10="F";
	   else
	     if vdcampo10 ="C" Then
	       let vdcampo10="M";
	     else
	      if vdcampo10 ="S" Then
	         let vdcampo10="S";
	      else
	         if vdcampo10 ="V" Then
		    let vdcampo10="W";
	         end if
	      end if
	     end if
	   end if
	 end if
	-- Carga los datos de la Direccion del Cliente --
    select max(secuencia) into vsecuencia
      from bdinteg:si_direcciones
	           WHERE  numcte=vcliente AND tipo_dir='1';
    SELECT Trim(f.nombrecalle),
           Trim(a.numeroextcalle)||' '||Trim(a.numerointcalle),
                   Trim(g.nombrezona), --Trim(d.nombre_inegi),
	           Trim(b.nombre), Trim(c.estado), a.cod_postal, a.tipo_dir,
                   manzana,andador,lote,edificio,entrada
	           INTO   vscampo2,vscampo3,vscampo4,--vscampo5,
                          vscampo6, vscampo7,vscampo8,vscampo9,
                   vmanzana,vandador,vlote,vedificio,ventrada
	           FROM  bdinteg:si_direcciones as a,
                      bdinteg:si_ciudades as b,
                     bdisolic:ss_circulo_edos as c,
	           --     bdinteg:si_municipio_inegi d,
                      bdinteg:si_catcalles f,
                      bdinteg:si_catzonas g
	           WHERE  a.numcte=vcliente AND a.secuencia=vsecuencia
                   AND a.pais = b.pais
	           AND a.estado = b.estado
                   AND a.ciudad = b.ciudad
                   AND a.estado = c.clave
	        ----   AND a.estado =d.estado_inegi
	        --   AND d.municipio_inegi = a.ciudad
                   AND a.numerocolonia = g.numerocolonia
                   AND a.numerociudad = g.numerociudad
                   AND a.numerocalle = f.numerocalle;
       let vscampo2 = trim(vscampo2)||' '||trim(vscampo3);
       let vexiste = length(vscampo2);
       if vexiste < 26 then
         let vscampo3 = "";
         if vmanzana > 0 then
           let vscampo3 ="mza. "||trim(vmanzana);
         end if
         if vandador > 0 then
           let vscampo3 =trim(vscampo3)||"and. "||trim(vmanzana);
         end if
         if vlote > 0 then
           let vscampo3 =trim(vscampo3)||"lt. "||trim(vlote);
         end if
         if vedificio > 0 then
           let vscampo3 =trim(vscampo3)||"ed. "||trim(vedificio);
         end if
         if ventrada > 0 then
           let vscampo3 =trim(vscampo3)||"ent. "||trim(ventrada);
         end if
       let vscampo2 = trim(vscampo2)||' '||trim(vscampo3);
       end if
       let vscampo2 = trim(vscampo2);
       let vexiste = length(vscampo2);
       let vexiste1 = 0;
       let vquita = "";
       let vespacio = " ";
       while vexiste1 < vexiste
        if vscampo2[1,1]="~" or vscampo2[1,1]=" " or vscampo2[1,1]="." then
           let vespacio = "F";
        else
          if vespacio = "F" then
            let vquita = trim(vquita)||" "||vscampo2[1,1];
            let vespacio = "";
          else
            let vquita = trim(vquita)||vscampo2[1,1];
          end if
        end if;
        let vscampo2 = vscampo2[2,26];
        let vexiste1 = vexiste1 + 1;
       end while;
       let vscampo2 = trim(vquita);
       if vscampo9 ="1" Then
	   let vscampo9="H";
       else
         if vscampo9 ="2" Then
           let vscampo9="B";
          end if
       end if

    let vregistro=trim(vregistro)||vdcampo1;
    let vlen=length(vdcampo2);
    let vpos=lpad(vlen,2,'0');
    let vregistro=Trim(vregistro)||vpos||vdcampo2;
    let vlen=length(vdcampo3);
    let vpos=lpad(vlen,2,'0');
    let vregistro=trim(vregistro)||'00'||vpos||vdcampo3;
    let vlen=length(vdcampo4);
    let vpos=lpad(vlen,2,'0');
    let vregistro=trim(vregistro)||'02'||vpos||vdcampo4;
    let vlen=length(vdcampo5);
    let vpos=lpad(vlen,2,'0');
    if vlen  > 0 then
      let vregistro=trim(vregistro)||'03'||vpos||vdcampo5;
    end if

    let vdia=vdcampo6[4,5];
    let vdia=lpad(vdia,2,'0');
    let vmes=vdcampo6[1,2];
    let vmes=lpad(vmes,2,'0');
    let vanio=vdcampo6[7,10];
    let vdcampo6=vdia||vmes||vanio;
    let vlen=length(vdcampo6);
    let vpos=lpad(vlen,2,'0');
    let vregistro=trim(vregistro)||'04'||vpos||vdcampo6;
    let vlen=length(vdcampo7);
    let vpos=lpad(vlen,2,'0');
    let vregistro=trim(vregistro)||'05'||vpos||vdcampo7;
    let vlen=length(vdcampo8);
    let vpos=lpad(vlen,2,'0');
    let vregistro=trim(vregistro)||'08'||vpos||vdcampo8;
    let vlen=length(vdcampo9);
    let vpos=lpad(vlen,2,'0');
    let vregistro=trim(vregistro)||'09'||vpos||vdcampo9;
    let vlen =length(vdcampo10);
    let vpos=lpad(vlen,2,'0');
    let vregistro=trim(vregistro)||'11'||vpos||vdcampo10;
    let vlen=length(vdcampo11);
    let vpos=lpad(vlen,2,'0');
    let vregistro=trim(vregistro)||'12'||vpos||vdcampo11;
    if trim(vdcampo12) != "0" then
       if length(trim(vdcampo12)) < 2 then
         let vdcampo12 = "0"||trim(vdcampo12);
       end if
       let vlen=length(vdcampo12);
       let vpos=lpad(vlen,2,'0');
       let vregistro=trim(vregistro)||'17'||vpos||vdcampo12;
    else
       let vregistro=trim(vregistro)||'170201';
    end if
    let vregistro=trim(vregistro)||vscampo1;
    let vlen=length(vscampo2);
    let vpos=lpad(vlen,2,'0');
    let vregistro1=vpos||vscampo2;
    let vscampo3 = "";
    let vexiste = length(vscampo3);
    let vexiste1 = 0;
    let vquita = "";
    let vespacio = " ";
    while vexiste1 < vexiste
     if vscampo3[1,1]="~" or vscampo3[1,1]=" " or vscampo3[1,1]="." then
       let vespacio = "F";
     else
      if vespacio = "F" then
	let vquita = trim(vquita)||" "||vscampo3[1,1];
	let vespacio = "";
      else
	let vquita = trim(vquita)||vscampo3[1,1];
      end if
     end if;
     let vscampo3 = vscampo3[2,26];
     let vexiste1 = vexiste1 + 1;
    end while;
    let vscampo3 = trim(vquita);
    let vlen=length(vscampo3);
    let vpos=lpad(vlen,2,'0');
    --let vregistro1='00'||vpos|| vscampo3;
    let vexiste = length(vscampo4);
    let vexiste1 = 0;
    let vquita = "";
    let vespacio = " ";
    while vexiste1 < vexiste
     if vscampo4[1,1]="~" or vscampo4[1,1]=" " or vscampo4[1,1]="." then
       let vespacio = "F";
     else
      if vespacio = "F" then
	let vquita = trim(vquita)||" "||vscampo4[1,1];
	let vespacio = "";
      else
	let vquita = trim(vquita)||vscampo4[1,1];
      end if
     end if;
     let vscampo4 = vscampo4[2,26];
     let vexiste1 = vexiste1 + 1;
    end while;
    let vscampo4= trim(vquita);
    let vlen=length(vscampo4);
    let vpos= lpad(vlen,2,'0');
    let vregistro1= trim(vregistro1)||'01'||vpos|| vscampo4;
{    let vexiste = length(vscampo5);
    let vexiste1 = 0;
    let vquita = "";
    let vespacio = " ";
    while vexiste1 < vexiste
     if vscampo5[1,1]="~" or vscampo5[1,1]=" " or vscampo5[1,1]="." then
       let vespacio = "F";
     else
      if vespacio = "F" then
	let vquita = trim(vquita)||" "||vscampo5[1,1];
	let vespacio = "";
      else
	let vquita = trim(vquita)||vscampo5[1,1];
      end if
     end if;
     let vscampo5 = vscampo5[2,26];
     let vexiste1 = vexiste1 + 1;
    end while;
    let vscampo5 = trim(vquita);
    let vlen= length(vscampo5);
    let vpos= lpad(vlen,2,'0');
    let vregistro1= trim(vregistro1)||'02'||vpos||vscampo5;
}
    let vexiste = length(vscampo6);
    let vexiste1 = 0;
    let vquita = "";
    let vespacio = " ";
    while vexiste1 < vexiste
     if vscampo6[1,1]="~" or vscampo6[1,1]=" " or vscampo6[1,1]="." then
       let vespacio = "F";
       let vexiste1 = vexiste1 + 1;
       let vscampo6 = vscampo6[2,26];
     else
      if vespacio = "F" then
        if vscampo6[1,22] = "MUNICIPIO DE ( OTROS )" then
	    let vquita = trim(vquita);
            let vexiste1 = vexiste1 + 22;
            let vscampo6 = vscampo6[23,26];
        else
          if vscampo6[1,12] = "MUNICIPIO DE"  THEN
	    let vquita = trim(vquita);
            let vexiste1 = vexiste1 + 12;
            let vscampo6 = vscampo6[13,26];
          else
	   let vquita = trim(vquita)||" "||vscampo6[1,1];
	   let vespacio = "";
           let vexiste1 = vexiste1 + 1;
           let vscampo6 = vscampo6[2,26];
          end if;
        end if;
      else
	let vquita = trim(vquita)||vscampo6[1,1];
        let vexiste1 = vexiste1 + 1;
        let vscampo6 = vscampo6[2,26];
      end if
     end if;
    end while;
    let vscampo6 = trim(vquita);
    let vlen= length(vscampo6);
    let vpos= lpad(vlen,2,'0');
    let vregistro1= trim(vregistro1)||'03'||vpos||vscampo6;
    let vexiste = length(vscampo7);
    let vexiste1 = 0;
    let vquita = "";
    let vespacio = " ";
    while vexiste1 < vexiste
     if vscampo7[1,1]="~" or vscampo7[1,1]=" " or vscampo7[1,1]="." then
       let vespacio = "F";
     else
      if vespacio = "F" then
	let vquita = trim(vquita)||" "||vscampo7[1,1];
	let vespacio = "";
      else
	let vquita = trim(vquita)||vscampo7[1,1];
      end if
     end if;
     let vscampo7 = vscampo7[2,4];
     let vexiste1 = vexiste1 + 1;
    end while;
    let vscampo7 = trim(vquita);
    let vlen= length(vscampo7);
    let vpos= lpad(vlen,2,'0');
    let vregistro1= trim(vregistro1)||'04'||vpos||vscampo7;
    let vlen= length(vscampo8);
    let vpos= lpad(vlen,2,'0');
    let vregistro2='05'||vpos||vscampo8;
    let vlen= length(vscampo9);
    let vpos= lpad(vlen,2,'0');
    let vregistro2=trim(vregistro2)||'10'||vpos||vscampo9;
    -- Marca el FIN de Trailer -->
   let vlen= length(vregistro)+length(vregistro1)+length(vregistro2);
   let vlen= trunc(vlen + 15);
   let vpo1= lpad(vlen,5,'0');
   let vregistro2=trim(vregistro2)||'ES05'||vpo1||'0002**';
   --delete from bdiburo:br_traslado where num_solicitud = pSolicitud;
   --delete from bdiburo:sb_regreso where num_solicitud = pSolicitud;
   insert into bdiburo:br_traslado
    values(pSolicitud,vregistro,vregistro1,vregistro2,5);
   let vexiste1 = 0;
   let vexiste = 10;
--   while vexiste1 < vexiste
 --     let vexiste1 = 0;
  --    select 1 into vexiste1
   --      from bdiburo:sb_regreso where num_solicitud =pSolicitud;
   --   if vexiste1 is null then let vexiste1 = 0; end if;
    --  if vexiste1 >= 1 then
    --     let vexiste1 = 11;
    --  end if
--   end while;
--call ins_consulta_buro(pempresa,psucursal,pusuario,pSolicitud)
--returning vcodret;
return vcodret;
end procedure
;