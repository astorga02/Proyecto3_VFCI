//INSTITUTO TECNOLÓGICO DE COSTA RICA
//VERIFICACIÓN FUNCIONAL DE CIRCUITOS INTEGRADOS
//Proyecto 2
//Lenguaje: SystemVerilog
//Creado por: Mac Alfred Pinnock Chacón (mcalfred32@gmail.com) y Susana Astorga (susana.0297.ar@gmail.com)
class Item extends uvm_sequence_item;

  `uvm_object_utils(Item)  //se registra la clase en la fábrica

  rand bit [31:0]fp_X; //aleatorizacion de las entradas y del modo de redondeo
  rand bit [31:0]fp_Y;
  rand bit [2:0] r_mode;
  bit [31:0] fp_Z; //defincion de la variable de salida
  bit ovrf; //bandera (0/1) en caso de overflow
  bit udrf; //bandera (0/1) en caso de underflow
  
  virtual function string convert2str();
    return $sformatf("fp_X=%0b, fp_Y=%0b, fp_Z=%0b, r_mode=%0b, ovrf=%0b, udrf=%0b",fp_X, fp_Y, fp_Z, r_mode, ovrf, udrf);
  endfunction
  
  function new(string name = "Item"); //se crea el constructor
    super.new(name);
  endfunction
  
    //RESTRICCIONES

  //restricción dato de exponente y mantisa
  constraint c_item_aleat  {

    //exponente
    fp_X[30:23] <= 8'hFE;
    fp_Y[30:23] <= 8'hFE;

     //Mantisa
    fp_X[22:0] <= 23'h8F;
    fp_Y[22:0] <= 23'h8F;    
 
  }

  //restricción de redondeo
  constraint c_r_mode {r_mode<=3'b100;}

  //restricción para underflow    - todo exponente ceros
  constraint c_udrf {
    (fp_X[30:23] + fp_Y[30:23] - 127 <= 0)|(~|fp_X[30:23])|(~|fp_Y[30:23]); 
  }

  //restricción para overflow     - todo exponente unos
  constraint c_ovrf {
    ((fp_X[30:23]+fp_Y[30:23]-127)==8'hFF)|( (&fp_X[30:23] & ~|fp_X[22:0]) & |fp_Y[30:23] )|( (&fp_Y[30:23] & ~|fp_X[22:0]) & |fp_X[30:23] );
  }  

  //restricción para inf
  constraint c_inf {
    (&fp_X[30:23] & ~|fp_X[22:0])   |   (&fp_Y[30:23] & ~|fp_Y[22:0]);
  } 

  //restricción para NaN
  constraint c_NaN {  
    (&fp_X[30:23] & |fp_X[21:0])  |  (&fp_Y[30:23] & |fp_Y[21:0])   |   ((&fp_X[30:23] & ~|fp_X[21:0]) & ~|fp_Y[21:0])   |   ((&fp_Y[30:23] & ~|fp_Y[21:0]) & ~|fp_X[21:0]);
  }


endclass
