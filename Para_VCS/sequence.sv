//INSTITUTO TECNOLÓGICO DE COSTA RICA
//VERIFICACIÓN FUNCIONAL DE CIRCUITOS INTEGRADOS
//Proyecto 2
//Lenguaje: SystemVerilog
//Creado por: Mac Alfred Pinnock Chacón (mcalfred32@gmail.com) y Susana Astorga (susana.0297.ar@gmail.com)
// Secuencia aleatoria 
class seq_aleatoria extends uvm_sequence;
  `uvm_object_utils(seq_aleatoria); //se registra la clase en la fábrica
  function new(string name="seq_aleatoria"); //se crea el constructor
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info("SEQ", "Inicio de la secuencia aletoria", UVM_HIGH)
    for(int i = 0; i < numero_tests; i++)begin
      Item item = Item::type_id::create("item");
      item.c_item_aleat.constraint_mode(1); //Resticciones para cada caso
      item.c_r_mode.constraint_mode(1); //Se activa la restriccion para el modo de redondeo, esta activa siempre
      item.c_ovrf.constraint_mode(0);
      item.c_udrf.constraint_mode(0);
      item.c_NaN.constraint_mode(0);
      item.c_inf.constraint_mode(0);
      start_item(item);
      if( !item.randomize() )
        `uvm_error("SEQ", "Fallo en aleatorizar")
      `uvm_info("SEQ",$sformatf("Nuevo item: %s", item.convert2str()), UVM_HIGH);
      finish_item(item);
    end
    `uvm_info("SEQ",$sformatf("Se generaron %0d items del tipo aleatorio", numero_tests),UVM_LOW);
  endtask
endclass

// Secuencia para explotar alternancia   
class seq_alternancia extends uvm_sequence;
  `uvm_object_utils(seq_alternancia); //se registra la clase en la fábrica
  function new(string name="seq_alternancia"); //se crea el constructor
    super.new(name);
  endfunction
   bit [31:0] seq_values[4] = {32'h0, 32'hFFFFFFFF, 32'hAAAAAAAA, 32'h55555555}; // con este orden nos aseguramos de pasar por todos los bits de las entradas
  int num_item = 0; 
  virtual task body();
    `uvm_info("SEQ", "Inicio de la secuencia con alternancia", UVM_HIGH)
    foreach(seq_values[i]) begin
      foreach(seq_values[j]) begin
        Item item = Item::type_id::create("item");
        start_item(item);
        item.c_item_aleat.constraint_mode(0); //Resticciones para cada caso
        item.c_r_mode.constraint_mode(1); //Se activa la restriccion para el modo de redondeo, esta activa siempre  
        item.c_ovrf.constraint_mode(0);
        item.c_udrf.constraint_mode(0);
        item.c_NaN.constraint_mode(0);
        item.c_inf.constraint_mode(0);
        if( !item.randomize() )   // randomize para aleatorizar el modo de redondeo
          `uvm_error("SEQ", "Fallo en aleatorizar")
        item.fp_X = seq_values[i];
        item.fp_Y = seq_values[j];
        num_item++;
        `uvm_info("SEQ",$sformatf("Nuevo item: %s", item.convert2str()), UVM_HIGH);
        finish_item(item);
      end
    end

    `uvm_info("SEQ",$sformatf("Se generaron %0d items del tipo alternancia", num_item), UVM_LOW);
  endtask

endclass

// Secuencia para overflow
class seq_overflow extends uvm_sequence;
  `uvm_object_utils(seq_overflow); //se registra la clase en la fábrica
  function new(string name="seq_overflow"); //se crea el constructor
    super.new(name);
  endfunction

  virtual task body();
    for(int i = 0; i <= numero_tests; i++)begin
      Item item = Item::type_id::create("item");
      item.c_r_mode.constraint_mode(1); //Se activa la restriccion para el modo de redondeo, esta activa siempre
      item.c_item_aleat.constraint_mode(0);
      item.c_ovrf.constraint_mode(1); //se activa la restriccion porque se va a utlizar el caso de overflow
      item.c_udrf.constraint_mode(0);
      item.c_NaN.constraint_mode(0);
      item.c_inf.constraint_mode(0);
      start_item(item);
      if(!item.randomize())begin
        `uvm_error("SEQ", "Fallo en alaeatorizar"); 
      end
      `uvm_info("SEQ",$sformatf("Nuevo item: %s", item.convert2str()), UVM_HIGH);
      finish_item(item);
    end
    `uvm_info("SEQ",$sformatf("Se generaron %0d items del tipo overflow", numero_tests),UVM_LOW);
  endtask
endclass


// Secuencia underflow
class seq_underflow extends uvm_sequence;
  `uvm_object_utils(seq_underflow); //se registra la clase en la fábrica
  function new(string name="seq_underflow");  //se crea el constructor
    super.new(name);
  endfunction

  virtual task body();
    for(int i = 0; i < numero_tests; i++)begin
      Item item = Item::type_id::create("item");
      item.c_r_mode.constraint_mode(1); //Se activa la restriccion para el modo de redondeo, esta activa siempre
      item.c_item_aleat.constraint_mode(0);
      item.c_ovrf.constraint_mode(0);
      item.c_udrf.constraint_mode(1); //se activa la restriccion porque se va a utlizar el caso de underflow
      item.c_NaN.constraint_mode(0);
      item.c_inf.constraint_mode(0);
      start_item(item);
      if( !item.randomize() )begin
        `uvm_error("SEQ", "Fallo en aleatorizar")
      end
      `uvm_info("SEQ",$sformatf("Nuevo item: %s", item.convert2str()), UVM_HIGH);
      finish_item(item);
    end
    `uvm_info("SEQ",$sformatf("Se generaron %0d items del tipo underflow", numero_tests),UVM_LOW);
  endtask
endclass


// Secuencia que genere NaN
class seq_NaN extends uvm_sequence;

  `uvm_object_utils(seq_NaN);  //se registra la clase en la fábrica
  
  function new(string name="seq_NaN");  //se crea el constructor
    super.new(name);
  endfunction

  virtual task body();
    for(int i = 0; i < numero_tests; i++)begin
      Item item = Item::type_id::create("item");
      item.c_r_mode.constraint_mode(1); //Se activa la restriccion para el modo de redondeo, esta activa siempre
      item.c_item_aleat.constraint_mode(0);
      item.c_ovrf.constraint_mode(0);
      item.c_udrf.constraint_mode(0);
      item.c_NaN.constraint_mode(1); //se activa la restriccion porque se va a utlizar el caso de no ser un número
      item.c_inf.constraint_mode(0);
      start_item(item);
      if(!item.randomize()) begin
        `uvm_error("SEQ", "Fallo en aleatorizar")
      end
      `uvm_info("SEQ",$sformatf("Nuevo item: %s", item.convert2str()), UVM_HIGH);
      finish_item(item);
    end
    `uvm_info("SEQ",$sformatf("Se generaron %0d items del tipo NaN", numero_tests),UVM_LOW);
  endtask
endclass

// Secuencia para inf
class seq_inf extends uvm_sequence;

  `uvm_object_utils(seq_inf);  //se registra la clase en la fábrica
  
  function new(string name="seq_inf");  //se crea el constructor
    super.new(name);
  endfunction
  
  virtual task body();
    for(int i = 0; i <= numero_tests; i++)begin
      Item item = Item::type_id::create("item");
      item.c_r_mode.constraint_mode(1); //Se activa la restriccion para el modo de redondeo, esta activa siempre
      item.c_item_aleat.constraint_mode(0);
      item.c_ovrf.constraint_mode(0);
      item.c_udrf.constraint_mode(0);
      item.c_NaN.constraint_mode(0);
      item.c_inf.constraint_mode(1); //se activa la restriccion porque se va a utlizar el caso de infinito
      start_item(item);
      if(!item.randomize())begin
        `uvm_error("SEQ", "Fallo en aleatorizar")
      end
      `uvm_info("SEQ",$sformatf("Nuevo item: %s", item.convert2str()), UVM_HIGH);
      finish_item(item);
    end
    `uvm_info("SEQ",$sformatf("Se generaron %0d items del tipo inf", numero_tests),UVM_LOW);
  endtask
endclass

  // A partir de aqui se definen los escenarios de prueba, 2 en total, que llaman a las secuencias de los casos difinidos
  // anteriormente.
  // Escenario 1:
  // Aleatorio
class escenario1 extends  uvm_sequence;
  `uvm_object_utils(escenario1); //se registra la clase en la fábrica
  function new(string name="escenario1"); //se crea el constructor
    super.new(name);
  endfunction

  seq_aleatoria Secuencia_aleatorio;
  task body();
    string concatenado;
    concatenado = {"Dato_X",",","Dato_Y",",","Resultado_final_Z_DUT",",","Resultado_final_esperado",",","Modo_redondeo",",","Overflow",",","Underflow"};//orden de las columnas para la impresion del reporte
      $system($sformatf("echo %0s >> reporte.csv", concatenado));
    `uvm_do(Secuencia_aleatorio); //se inicializa la secuencia del caso de modo aleatorio definido anteriromente.
 endtask
endclass

  // Escenario 2: Overflow Underflow inf NaN
class escenario2 extends  uvm_sequence;

  `uvm_object_utils(escenario2); //se registra la clase en la fábrica
  
  function new(string name="escenario2"); //se crea el constructor
    super.new(name);
  endfunction
  seq_alternancia Secuencia_alternancia; //se inicializa la secuencia del caso de alternancia definido anteriromente.
  seq_overflow Secuencia_overflow; //se inicializa la secuencia del caso de overflow definido anteriromente.
  seq_underflow Secuencia_underflow; //se inicializa la secuencia del caso de underflow definido anteriromente.
  seq_NaN Secuencia_NaN; //se inicializa la secuencia del caso de no es numero definido anteriromente.
  seq_inf Secuencia_inf; //se inicializa la secuencia del caso deinfinito definido anteriromente.
  task body();
     string concatenado;
     concatenado = {"Dato_X",",","Dato_Y",",","Resultado_final_Z_DUT",",","Resultado_final_esperado",",","Modo_redondeo",",","Overflow",",","Underflow"};//orden de las columnas para el reporte
     $system($sformatf("echo %0s >> reporte.csv", concatenado));
    `uvm_do(Secuencia_alternancia);
    `uvm_do(Secuencia_overflow);
    `uvm_do(Secuencia_underflow);
    `uvm_do(Secuencia_NaN);
    `uvm_do(Secuencia_inf);
  endtask
endclass