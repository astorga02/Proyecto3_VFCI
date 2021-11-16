//INSTITUTO TECNOLÓGICO DE COSTA RICA
//VERIFICACIÓN FUNCIONAL DE CIRCUITOS INTEGRADOS
//Proyecto 2
//Lenguaje: SystemVerilog
//Creado por: Mac Alfred Pinnock Chacón (mcalfred32@gmail.com) y Susana Astorga (susana.0297.ar@gmail.com)

interface dut_if (input bit clk);

//variables que conectan con el DUT
  logic [2:0]  r_mode;  //modo de redondeo (1,2,3,4) en binario
  logic [31:0] fp_X, fp_Y; //entradas
  logic [31:0] fp_Z; //salida
  logic ovrf, udrf; //banderas de overflow y underflow

  clocking cb_clk @(posedge clk);  //cada que se de un flanco positivo de reloj
    default input #1step output #3ns;
        input fp_Z;  //resultado salida
        input ovrf;  // overflow
        input udrf;  //underflow
        output r_mode;  //modo redondeo
        output fp_X; //dato de entrada x
        output fp_Y; //dato de entrada y
  endclocking 


  property underf; //se crea una restricción para la bandera de underflow
    @(negedge clk) (~|cb_clk.fp_Z[30:23] & ~cb_clk.fp_Z[22]) |-> cb_clk.udrf;  
  endproperty

   error_underf: assert property (underf) else $display("Error de bandera underflow"); //condicional de la restricción 
   pass_underf: cover property (underf) $display("Bandera underflow activada");

  property overf; //se crea una restricción para la bandera de overflow
    @(negedge clk) (&cb_clk.fp_Z[30:23] & ~cb_clk.fp_Z[22]) |-> cb_clk.ovrf;
  endproperty
  
  pass_overf: cover property (overf) $display("Bandera overflow activada");
  error_overf: assert property (overf) else $display("Error de bandera overflow"); //condicional de la restricción 
   


endinterface  