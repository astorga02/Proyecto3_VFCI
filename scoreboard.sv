//INSTITUTO TECNOLÓGICO DE COSTA RICA
//VERIFICACIÓN FUNCIONAL DE CIRCUITOS INTEGRADOS
//Proyecto 2
//Lenguaje: SystemVerilog
//Creado por: Mac Alfred Pinnock Chacón (mcalfred32@gmail.com) y Susana Astorga

class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
    
    function new(string name="scoreboard",uvm_component parent=null);
        super.new(name, parent);
    endfunction

    int num_item;
    bit [31:0] resultZ;
    bit [32:0] mantisaZ_sinredo; // variable sin redondeo
    real mantisaZ; //variables con decimales
    real exponenteZ;
    real tot_mantisaZ; 
  	string concatenado;
    bit sign_field_Z;
    bit underflow_en_entrada_X,overflow_en_entrada_X,nan_X,inf_X,underflow_en_entrada_Y,overflow_en_entrada_Y,nan_Y,inf_Y,underflow_en_entrada_Z,overflow_en_entrada_Z,nan_Z,inf_Z;
  	string Dato_X, Dato_Y, Resultado_final_Z, Resultado_final_correcto, Modo_redondeo, Overflow, Underflow;
  	bit [24:0] mantisa_datoZ; 
  	bit [22:0] mantisa_dato_X, mantisa_dato_Y, redo_mantisa_datoZ;
    bit [7:0] exponente_dato_X;
    bit exponente_dato_Y;
    bit exponente_dato_Z;   


    uvm_analysis_imp #(Item, scoreboard) m_analysis_imp;

    virtual function void build_phase(uvm_phase phase);
      	super.build_phase(phase);
        m_analysis_imp = new("m_analysis_imp",this);
    endfunction

    virtual function void write(Item item);
        //lógica para el redondeo del resultado
        nan_Z=0;
        inf_Z=0;
        exponente_dato_X=item.fp_X[30:23];
        mantisa_dato_X=item.fp_X[22:0];
        exponente_dato_Y=item.fp_Y[30:23];
        mantisa_dato_Y=item.fp_Y[22:0];
        sign_field_Z=item.fp_X[31]^item.fp_Y[31];
        exponenteZ=exponente_dato_X+exponente_dato_Y-127; 
        mantisaZ=mantisa_dato_X+(($itor(mantisa_dato_X))*($itor(mantisa_dato_Y)))/8388608+mantisa_dato_Y+8388608; //valor decimal
        mantisaZ_sinredo=mantisaZ;
        tot_mantisaZ=(mantisaZ-$itor(mantisaZ_sinredo)); //valor decimal exacto
		
        for (int i=32; i>=0; --i) begin  
            if (mantisaZ_sinredo[i]) begin
                num_item=i;
                break;
            end
        end

      	exponenteZ=exponenteZ+num_item-23;  
        mantisaZ_sinredo=mantisaZ*(2**(32-num_item));
        mantisa_datoZ=mantisaZ_sinredo[32:9];//el resultado se trunca
        if (tot_mantisaZ!=0) begin  //se redondea por que el valor no es exacto
            $display("Resultado redondeado");
            case (item.r_mode) //se redondea de acuerdo a los tipos de redondeo que hay
                3'b000:begin // redondea al más cercano                   
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

                3'b001:begin  //redondea a cero 
                    //no se hace nada debido a que ya está truncado
                end
                3'b010:begin  //el último bit depende del signo del resultado, redondea para abajo                    
                    if (sign_field_Z) begin
                        mantisa_datoZ+=1;
                    end
                end
                3'b011:begin  //el último bit depende del signo del resultado, redondea para arriba
                    if (!sign_field_Z) begin
                        mantisa_datoZ+=1;
                    end
                end
                3'b100:begin  //suma 1 al dato de mantisa
                    if (mantisaZ_sinredo[8]) begin
                        mantisa_datoZ+=1;
                    end
                end
                default: begin
                    //ya está truncado
                end
            endcase            
        end         
      	if (mantisa_datoZ[24]) begin
            redo_mantisa_datoZ=mantisa_datoZ[23:1];
            exponenteZ+=1; 
        end else begin
           redo_mantisa_datoZ=mantisa_datoZ[22:0];
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

        underflow_en_entrada_X  =!(|exponente_dato_X)?1 : 0; //si el exponente es 0 entonces hay underflow
        overflow_en_entrada_X =(&exponente_dato_X)? 1 : 0; //si todo el exponente es 1 entonces es overflow
        underflow_en_entrada_Y  =!(|exponente_dato_Y)?1 : 0; //si el exponente es 0 entonces hay underflow
        overflow_en_entrada_Y =(&exponente_dato_Y)? 1 : 0; //si todo el exponente es 1 entonces es overflow      
        underflow_en_entrada_Z  =!(|exponente_dato_Z)?1 : 0; 
        underflow_en_entrada_Z= underflow_en_entrada_Z|underflow_en_entrada_Y|underflow_en_entrada_X;
        overflow_en_entrada_Z =(&exponente_dato_Z)? 1 : 0; 
        overflow_en_entrada_Z = overflow_en_entrada_X|overflow_en_entrada_Y|overflow_en_entrada_Z;       
        nan_X = &exponente_dato_X & |mantisa_dato_X; //definicion de NaN
        nan_Y = &exponente_dato_Y & |mantisa_dato_Y;

        nan_Z = {underflow_en_entrada_X & overflow_en_entrada_Y} | {overflow_en_entrada_X & underflow_en_entrada_Y} | nan_Z; 
        nan_Z = nan_X | nan_Y | nan_Z;       
        inf_X = &exponente_dato_X & ~|mantisa_dato_X; //definición de inf
        inf_Y = &exponente_dato_Y & ~|mantisa_dato_Y;
        inf_Z = {underflow_en_entrada_X & overflow_en_entrada_Y} | {overflow_en_entrada_X & underflow_en_entrada_Y} | inf_Z; 
        inf_Z = inf_X | inf_Y | inf_Z;      

        if (nan_Z) begin
          resultZ={sign_field_Z,1'b0,8'hFF,1'b1,22'b0};  //resultado final correcto 
        end 
        else if (inf_Z) begin
          resultZ={sign_field_Z, 8'hFF,23'b0};        //resultado final correcto      
        end
        else if (underflow_en_entrada_Z) begin
            resultZ={sign_field_Z,8'b0,23'b0};  //resultado final correcto 
        end 
        else if (overflow_en_entrada_Z) begin
            resultZ={sign_field_Z,8'hFF,23'b0};  //resultado final correcto 
        end
        else begin
          resultZ={sign_field_Z,exponente_dato_Z,redo_mantisa_datoZ};  //resultado final correcto 
        end
        `uvm_info("SCBD", $sformatf("Mode=%b Op_x=%b Op_y=%b Result=%b Correct=%b Overflow=%b Underflow=%b", item.r_mode,item.fp_X,item.fp_Y,item.fp_Z,resultZ,item.ovrf,item.udrf), UVM_LOW)        
        //Impresion del reporte
        Dato_X.bintoa(item.fp_X);
        Dato_Y.bintoa(item.fp_Y);
        Resultado_final_Z.bintoa(item.fp_Z);
        Resultado_final_correcto.bintoa(resultZ);
        Modo_redondeo.bintoa(item.r_mode);
        Overflow.bintoa(item.ovrf);  
        Underflow.bintoa(item.udrf);      
        concatenado = {Dato_X,",",Dato_Y,",",Resultado_final_Z,",",Resultado_final_correcto,",",Modo_redondeo,",",Overflow,",",Underflow};//orden de las columnas
        $system($sformatf("echo %0s >> reporte.csv", concatenado));
    endfunction
endclass