create procedure "informix".sp_inicializa(pvchrFase varchar(10))
returning char(5);


   define sql_err 			integer;
   define codret 			char(5);

   BEGIN WORK;
   begin
      -- Error Handler
      on exception set sql_err
         if sql_err <> 0 then
            let codret = sql_err;
            rollback work;
		    RETURN codret;
         end if;
      end exception;

   UPDATE tblcajero SET mnysaldodisponible = 100000001.01, intnumincsr = 0
   WHERE dtfechaop = '03/16/2004';


   UPDATE tblpago
   SET vchrclaverastreo = "BSI" || intpkpago || pvchrFase;

   UPDATE tblparametros
   SET vchrvalor = '0'
   WHERE vchrcveparametro = 'FOLIO_OPCAJERO';

	INSERT INTO tblhistbitacora
	SELECT * FROM tblbitacoramsj;
	
	DELETE FROM tblbitacoramsj;
	
	

   commit work;

   return 0;

  	end

 end procedure;