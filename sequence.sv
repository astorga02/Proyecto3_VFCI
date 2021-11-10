//INSTITUTO TECNOLÓGICO DE COSTA RICA
//VERIFICACIÓN FUNCIONAL DE CIRCUITOS INTEGRADOS
//Proyecto 2
//Lenguaje: SystemVerilog
//Creado por: Mac Alfred Pinnock Chacón (mcalfred32@gmail.com) y Susana Astorga
// Secuencia aleatoria 
class seq_aleatoria extends uvm_sequence;
  
  `uvm_object_utils(seq_aleatoria); //se registra la clase en la fábrica
  
  function new(string name="seq_aleatoria"); //se crea el constructor
    super.new(name);
  endfunction

  //rand int num_item; //número de items que van a ser enviados


  //num_item = numero_tests;  // Limite de la cantidad aleatoria de items enviados, o sea un número entre 5 y 10

  virtual task body();
    `uvm_info("SEQ", "Inicio de la secuencia aletoria", UVM_HIGH)

    for(int i = 0; i < numero_tests; i++)begin
      Item item = Item::type_id::create("item");

      // Configuración de constraints
      item.c_item_aleat.constraint_mode(1);
      item.c_r_mode.constraint_mode(1);
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

// Secuencia con alternancia   
class seq_alternancia extends uvm_sequence;
  
  `uvm_object_utils(seq_alternancia); //se registra la clase en la fábrica
  
  function new(string name="seq_alternancia"); //se crea el constructor
    super.new(name);
  endfunction

  // Posibles valores de X y Y
  bit [31:0] seq_values[4] = {32'h0, 32'hFFFFFFFF, 32'h55555555, 32'hAAAAAAAA};

  int num_item = 0; 

  virtual task body();
    `uvm_info("SEQ", "Inicio de la secuencia con alternancia", UVM_HIGH)
    foreach(seq_values[i]) begin
      foreach(seq_values[j]) begin
        Item item = Item::type_id::create("item");
        
        start_item(item);

        // Configuración de constraints
        item.c_item_aleat.constraint_mode(0);
        item.c_r_mode.constraint_mode(1);   
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

// Secuencia que genere overflow
class seq_overflow extends uvm_sequence;

  `uvm_object_utils(seq_overflow); //se registra la clase en la fábrica
  
  function new(string name="seq_overflow"); //se crea el constructor
    super.new(name);
  endfunction

  virtual task body();
    for(int i = 0; i <= numero_tests; i++)begin
      
      Item item = Item::type_id::create("item");

      // Configuración de constraints
      item.c_r_mode.constraint_mode(1);
      item.c_item_aleat.constraint_mode(0);
      item.c_ovrf.constraint_mode(1);
      item.c_udrf.constraint_mode(0);
      item.c_NaN.constraint_mode(0);
      item.c_inf.constraint_mode(0);

      start_item(item);

      if( !item.randomize() )
        `uvm_error("SEQ", "Fallo en alaeatorizar")
      
      `uvm_info("SEQ",$sformatf("Nuevo item: %s", item.convert2str()), UVM_HIGH);
      
      finish_item(item);

    end

    `uvm_info("SEQ",$sformatf("Se generaron %0d items del tipo overflow", numero_tests),UVM_LOW);
  endtask
endclass


// Secuencia que genere underflow
class seq_underflow extends uvm_sequence;

  `uvm_object_utils(seq_underflow); //se registra la clase en la fábrica
   
  function new(string name="seq_underflow");  //se crea el constructor
    super.new(name);
  endfunction

  virtual task body();
    for(int i = 0; i < numero_tests; i++)begin
      
      Item item = Item::type_id::create("item");

      // Configuración de constraints
      item.c_r_mode.constraint_mode(1);
      item.c_item_aleat.constraint_mode(0);
      item.c_ovrf.constraint_mode(0);
      item.c_udrf.constraint_mode(1);
      item.c_NaN.constraint_mode(0);
      item.c_inf.constraint_mode(0);

      start_item(item);

      if( !item.randomize() )
        `uvm_error("SEQ", "Fallo en aleatorizar")
      
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

      // Configuración de constraints
      item.c_r_mode.constraint_mode(1);
      item.c_item_aleat.constraint_mode(0);
      item.c_ovrf.constraint_mode(0);
      item.c_udrf.constraint_mode(0);
      item.c_NaN.constraint_mode(1);
      item.c_inf.constraint_mode(0);

      start_item(item);

      if( !item.randomize() )
        `uvm_error("SEQ", "Fallo en aleatorizar")
      
      `uvm_info("SEQ",$sformatf("Nuevo item: %s", item.convert2str()), UVM_HIGH);
      
      finish_item(item);

    end

    `uvm_info("SEQ",$sformatf("Se generaron %0d items del tipo NaN", numero_tests),UVM_LOW);
  endtask
endclass



// Secuencia que genere inf
class seq_inf extends uvm_sequence;

  `uvm_object_utils(seq_inf);  //se registra la clase en la fábrica
  
  function new(string name="seq_inf");  //se crea el constructor
    super.new(name);
  endfunction
  
  virtual task body();
    for(int i = 0; i <= numero_tests; i++)begin
      
      Item item = Item::type_id::create("item");

      // Configuración de constraints
      item.c_r_mode.constraint_mode(1);
      item.c_item_aleat.constraint_mode(0);
      item.c_ovrf.constraint_mode(0);
      item.c_udrf.constraint_mode(0);
      item.c_NaN.constraint_mode(0);
      item.c_inf.constraint_mode(1);

      start_item(item);

      if( !item.randomize() )
        `uvm_error("SEQ", "Fallo en aleatorizar")
      
      `uvm_info("SEQ",$sformatf("Nuevo item: %s", item.convert2str()), UVM_HIGH);
      
      finish_item(item);

    end

    `uvm_info("SEQ",$sformatf("Se generaron %0d items del tipo inf", numero_tests),UVM_LOW);
  endtask
endclass





  // Escenario 1, dos tipos de secuencias:
  // Aleatorio
  // Alternancia (cambiar abajo)
class escenario1 extends  uvm_sequence;

  `uvm_object_utils(escenario1); //se registra la clase en la fábrica
  
  function new(string name="escenario1"); //se crea el constructor
    super.new(name);
  endfunction

  seq_aleatoria Secuencia_aleatorio;

  task body();
    string concatenado;
    concatenado = {"Dato_X",",","Dato_Y",",","Resultado_final_Z",",","Resultado_final_correcto",",","Modo_redondeo",",","Overflow",",","Underflow"};//orden de las columnas
      $system($sformatf("echo %0s >> reporte.csv", concatenado));
    `uvm_do(Secuencia_aleatorio);
endtask : body


 endclass : escenario1


  // Escenario 2, tres tipos de secuencias:
  // Overflow
  // Underflow
  // inf
  // NaN
class escenario2 extends  uvm_sequence;

  `uvm_object_utils(escenario2); //se registra la clase en la fábrica
  
  function new(string name="escenario2"); //se crea el constructor
    super.new(name);
  endfunction
  
  seq_alternancia Secuencia_alternancia;
  seq_overflow Secuencia_overflow;
  seq_underflow Secuencia_underflow;
  seq_NaN Secuencia_NaN;
  seq_inf Secuencia_inf;

  task body();
     string concatenado;
     concatenado = {"Dato_X",",","Dato_Y",",","Resultado_final_Z",",","Resultado_final_correcto",",","Modo_redondeo",",","Overflow",",","Underflow"};//orden de las columnas
     $system($sformatf("echo %0s >> reporte.csv", concatenado));
    `uvm_do(Secuencia_alternancia);
    `uvm_do(Secuencia_overflow);
    `uvm_do(Secuencia_underflow);
    `uvm_do(Secuencia_NaN);
    `uvm_do(Secuencia_inf);
  endtask : body


endclass : escenario2