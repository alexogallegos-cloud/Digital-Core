create procedure "informix".sp_genera_archivo(archivo char(100), descripcion char (200))
           returning char(05);

    define vsys        char(300);

    let vsys = "";

    let vsys = ' echo '|| trim(descripcion) || ' >> ' || trim(archivo);
    system vsys;
    
  return "00000";
end procedure;