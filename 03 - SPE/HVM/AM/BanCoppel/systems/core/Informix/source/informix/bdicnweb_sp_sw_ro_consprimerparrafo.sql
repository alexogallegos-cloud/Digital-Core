create procedure "informix".sp_sw_ro_consprimerparrafo()
	returning char(255)
	
	define lParrafo lvarchar(1024);
	define cSeccion char(255);
	define iTamCorteCadena int;
	define iTamTotalParrafo int;
	define iSaltoCadena int;
	
	let lParrafo = ', en nombre y representación de BanCoppel, S.A., Institución de Banca Mpultiple ("BanCoppel"), personalidad que tenemos acreditada ante esta H. Autoridad, la cual consta en la escritura pública número 15230 de fecha 05 de junio de 2010, otorgada ante la fe del licenciado Gerardo Gaxiola Díaz, Notario Público No. 167 del estado de Sinaloa; señalando como domicilio para oír y recibir toda clase de notificaciones y documentos relacionadps con el presente escrito, el ubicado en Insurgentes Sur 553 - 6° Piso Edif. Fiesta Inn, Col. Escandón, 11800 México, D.F., y autorizando individualmente para los mismos efectos, así como para realizar toda clase de gestiones relacionadas con el presente a ';
	let iTamCorteCadena = 255;
	let iTamTotalParrafo = length(lParrafo);
	let iSaltoCadena = 1;
	
	begin
		while iSaltoCadena < iTamTotalParrafo
			let cSeccion = substr(lParrafo, iSaltoCadena, iTamCorteCadena);
			return cSeccion with resume;
			
			let iSaltoCadena = iSaltoCadena + iTamCorteCadena;
		end while;
	end;
	
end procedure;