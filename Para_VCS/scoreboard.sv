//INSTITUTO TECNOLÓGICO DE COSTA RICA
//VERIFICACIÓN FUNCIONAL DE CIRCUITOS INTEGRADOS
//Proyecto 2
//Lenguaje: SystemVerilog
//Creado por: Mac Alfred Pinnock Chacón (mcalfred32@gmail.com) y Susana Astorga (susana.0297.ar@gmail.com)

class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
    function new(string name="scoreboard",uvm_component parent=null);
        super.new(name, parent);
    endfunction
    // se definen las variables necesarias para correr las pruebas y definir algunos parametros de seguridad para hacer las
    // comparaciones pertienentes y evaluar el correcto funcionamiento del DUT 
    int num_item;
    real mantisaZ; //variables con decimales
    real agregado; //variable para un cálculo de seguridad
    real exponenteZ;
    real tot_mantisaZ; 
  	string concatenado1;
    string concatenado2;
    string Dato_X_reporte;
    string Dato_Y_reporte;
    string Resultado_final_Z_DUT;
    string Resultado_final_esperado;
    string Modo_redondeo_reporte;
    string Overflow_reporte;
    string Underflow_reporte;
    bit [31:0] resultZ;
    bit [32:0] mantisaZ_sinredo; // variable sin redondeo
    bit und_X,over_X,nan_X,inf_X;
    bit und_Y,over_Y,nan_Y,inf_Y;
    bit und_Z,over_Z,nan_Z,inf_Z;
    bit signo_salida;
  	bit [24:0] mantisa_datoZ; 
  	bit [22:0] mantisa_dato_X;
    bit [22:0] mantisa_dato_Y;
    bit [22:0] redo_mantisa_datoZ;
    bit [7:0] exponente_dato_X;
    bit [7:0] exponente_dato_Y;
    bit [7:0] exponente_dato_Z;   

	
    uvm_analysis_imp #(Item, scoreboard) m_analysis_imp;

    virtual function void build_phase(uvm_phase phase);
      	super.build_phase(phase);
        m_analysis_imp = new("m_analysis_imp",this);
    endfunction

    virtual function void write(Item item);
        //lógica para el redondeo del resultado
        nan_Z = 0;
        inf_Z = 0;
        exponente_dato_X = item.fp_X[30:23];
        mantisa_dato_X = item.fp_X[22:0];
        exponente_dato_Y = item.fp_Y[30:23];
        mantisa_dato_Y = item.fp_Y[22:0];
        signo_salida = item.fp_X[31]^item.fp_Y[31];
        agregado = (($itor(mantisa_dato_X))*($itor(mantisa_dato_Y)))/8388608+mantisa_dato_Y+8388608;
        exponenteZ = exponente_dato_X+exponente_dato_Y-127;
        mantisaZ = mantisa_dato_X + agregado; //valor decimal
        mantisaZ_sinredo = mantisaZ;
        tot_mantisaZ = (mantisaZ-$itor(mantisaZ_sinredo)); //valor decimal exacto
		
        for (int i = 32; i>=0; --i) begin  
            if (mantisaZ_sinredo[i]) begin
                num_item = i;
                break;
            end
        end

      	exponenteZ=exponenteZ+num_item-23;  
        mantisaZ_sinredo=mantisaZ*(2**(32-num_item));
        mantisa_datoZ=mantisaZ_sinredo[32:9];//el resultado se trunca
        if (tot_mantisaZ!=0) begin  //se redondea por que el valor no es exacto
            $display("Resultado redondeado");
          if (item.r_mode == 3'b000) begin //se redondea de acuerdo a los tipos de redondeo que hay en binario (de 0 a 3 en decimal),
                                          // para tener una copia de seguridad de lo que deberia de salir del DUT
                 // redondea al más cercano                   
                  	if (mantisaZ_sinredo[8]) begin
                      	if (mantisaZ_sinredo[7:0]!=0) begin
                            mantisa_datoZ+=1;
                        end else begin
                            if (mantisaZ_sinredo[10]) begin
                                mantisa_datoZ+=1;
                            end
                        end
                    end
                end

          if (item.r_mode == 3'b001)begin  //redondea a cero 
                    //no se hace nada debido a que ya está truncado
                end
          if (item.r_mode == 3'b010)begin  //el último bit depende del signo del resultado, redondea para abajo                    
                    if (signo_salida) begin
                        mantisa_datoZ+=1;
                    end
                end
          if (item.r_mode == 3'b011)begin  //el último bit depende del signo del resultado, redondea para arriba
                    if (!signo_salida) begin
                        mantisa_datoZ+=1;
                    end
                end
          if (item.r_mode == 3'b100)begin  //suma 1 al dato de mantisa
                    if (mantisaZ_sinredo[8]) begin
                        mantisa_datoZ+=1;
                    end
                end             
        end         
      	      
        if ($rtoi(exponenteZ)<=0) begin
            exponente_dato_Z=8'b0; //Underflow
        end 
        else if ($rtoi(exponenteZ)>=255) begin
            exponente_dato_Z=8'b11111111; //Overflow
        end
        else begin
            exponente_dato_Z=exponenteZ; //Normal
        end
      	
      	if (mantisa_datoZ[24]) begin
            redo_mantisa_datoZ=mantisa_datoZ[23:1];
            exponenteZ+=1; 
        end else begin
           redo_mantisa_datoZ=mantisa_datoZ[22:0];
        end

        // se definen los estados de las variables tipo bit segun el estado lógico de las compraciones que se hacen
        // para todos los casos de overflow, underflow, infinito y not a number, esto para luego evaluar si alguna de estabs banderas
        // está activa y establecer la variable de compracion o seguridad para luego ser comparada con la salida del DUT
        und_X  =!(|exponente_dato_X)?1 : 0; //si el exponente es 0 entonces hay underflow
        over_X =(&exponente_dato_X)? 1 : 0; //si todo el exponente son 1 entonces es overflow
        und_Y  =!(|exponente_dato_Y)?1 : 0; //si el exponente es 0 entonces hay underflow
        over_Y =(&exponente_dato_Y)? 1 : 0; //si todo el exponente son 1 entonces es overflow
        und_Z  =!(|exponente_dato_Z)?1 : 0; 
        und_Z= und_Z|und_Y|und_X;
        over_Z =(&exponente_dato_Z)? 1 : 0; 
        over_Z = over_X|over_Y|over_Z;
      	inf_X = &exponente_dato_X & ~|mantisa_dato_X; //definición de inf
        inf_Y = &exponente_dato_Y & ~|mantisa_dato_Y;
        inf_Z = {und_X & over_Y} | {over_X & und_Y} | inf_Z; 
        inf_Z = inf_X | inf_Y | inf_Z;
        nan_X = &exponente_dato_X & |mantisa_dato_X; //definicion de NaN
        nan_Y = &exponente_dato_Y & |mantisa_dato_Y;
        nan_Z = {und_X & over_Y} | {over_X & und_Y} | nan_Z; 
        nan_Z = nan_X | nan_Y | nan_Z; 
         
        // se establece la variable z de salida de copia de seguridad para poder comparar con la salida del DUT
        // de acuerdo con el tipo caso en el que se encuentre, NaN, inf, und_Z, over_z o el caso en que todo esté
        // bien en el resultado esperado y no se cumpla con niguno de los casos anteriores, o sea, un 
        // funcionamiento esperado del DUT
        if (nan_Z) begin
          resultZ={signo_salida,1'b0,8'hFF,1'b1,22'b0};  //resultado final correcto para ese caso
        end 
        else if (inf_Z) begin
          resultZ={signo_salida, 8'hFF,23'b0};        //resultado final correcto para ese caso
        end
        else if (und_Z) begin
            resultZ={signo_salida,8'b0,23'b0};  //resultado final correcto para ese caso
        end 
        else if (over_Z) begin
            resultZ={signo_salida,8'hFF,23'b0};  //resultado final correcto para ese caso
        end
        else begin
            resultZ={signo_salida,exponente_dato_Z,redo_mantisa_datoZ};  //resultado final correcto si no es ningun caso de esquina
        end

      `uvm_info("SCBD", $sformatf("Mode = %b Entrada x = %b Entrada y = %b Resultado del DUT = %b Resultado esperado = %b Overflow = %b Underflow = %b", item.r_mode,item.fp_X,item.fp_Y,item.fp_Z,resultZ,item.ovrf,item.udrf), UVM_LOW)  

      if(item.fp_Z != resultZ ) begin // se compara el dato esperado correcto con el del DUT
        `uvm_error("SCBD",$sformatf("Todo mal, los resultados no coinciden  Resultado del DUT = %b Resultado esperado = %b", item.fp_Z,resultZ))
        end else begin
          `uvm_info("SCBD",$sformatf("Todo bien, los resultados si coinciden Resultado del DUT = %b Resultado esperado = %b", item.fp_Z,resultZ), UVM_HIGH)
        end
      
        //Impresion del reporte
        Dato_X_reporte.bintoa(item.fp_X);
        Dato_Y_reporte.bintoa(item.fp_Y);
        Resultado_final_Z_DUT.bintoa(item.fp_Z);
        Resultado_final_esperado.bintoa(resultZ);
        Modo_redondeo_reporte.bintoa(item.r_mode);
        Overflow_reporte.bintoa(item.ovrf);  
        Underflow_reporte.bintoa(item.udrf);      
        concatenado1 = {Dato_X_reporte,",",Dato_Y_reporte,",",Resultado_final_Z_DUT,",",Resultado_final_esperado,",",Modo_redondeo_reporte,",",Overflow_reporte,",",Underflow_reporte};//orden de las columnas
      $system($sformatf("echo %0s >> reporte.csv", concatenado1));
    endfunction
endclass