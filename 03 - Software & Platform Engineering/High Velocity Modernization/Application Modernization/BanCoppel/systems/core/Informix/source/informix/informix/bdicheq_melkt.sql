create procedure "informix".melkt(pempresa char(3))

    returning char(5),char(4), references text;

   define vcodret char(5);
   define vproducto char(4);
   define vpolitica references text;

   
   let vcodret = "000";
   let vproducto = "";
   let vpolitica = "";
  foreach
     select politica into vpolitica
        from sc_politicasprod
        where empresa = pempresa
     return vcodret,vproducto,vpolitica;
  end foreach
end procedure;