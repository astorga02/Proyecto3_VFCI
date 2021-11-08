//INSTITUTO TECNOLÓGICO DE COSTA RICA
//VERIFICACIÓN FUNCIONAL DE CIRCUITOS INTEGRADOS
//Proyecto 2
//Lenguaje: SystemVerilog
//Creado por: Mac Alfred Pinnock Chacón (mcalfred32@gmail.com) y Susana Astorga
class test extends uvm_test;

  `uvm_component_utils(test) //se registra la clase en la fábrica
  
  function new(string name = "test",uvm_component parent=null); //se crea el constructor
    super.new(name,parent);
  endfunction
  
  env ambiente_instancia; //instancio un puntero para el ambiente
  seq_aleatoria  seq; //instancio un puntero para el secuenciador
  virtual dut_if  vif; //interface virtual

  virtual function void build_phase(uvm_phase phase); //contrucción de la interface virtual
    super.build_phase(phase);
    ambiente_instancia = env::type_id::create("ambiente_instancia",this);  //se instancia el ambiente 
    if(!uvm_config_db#(virtual dut_if)::get(this, "", "dut_vif",vif)) 
      `uvm_fatal("TEST","Did not get vif")

    uvm_config_db#(virtual dut_if)::set(this, "ambiente_instancia.agente_instancia.*","dut_vif",vif); //se conecta la interface virtual dentro del ambiente, agente
    
    //se crea el secuenciador y se aleatoriza
    seq = seq_aleatoria::type_id::create("seq");
    seq.randomize();  

  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this); //se levanta una objeción 
    // apply_reset();

    seq.start(ambiente_instancia.agente_instancia.secuenciador_instancia); //se inicializa el secuenciador
    #200;
    phase.drop_objection(this); //luego se baja la objeción 

  endtask

  
endclass


// Test del escenario 1
class test_01 extends test;
  `uvm_component_utils(test_01) //se registra la clase en la fábrica
  
  function new(string name="escenario1",uvm_component parent=null); //se crea el constructor
    super.new(name,parent);
  endfunction

  //env ambiente_instancia;
  escenario1 seq;   //instancio un puntero para el secuenciador de este primer escenario
  //virtual dut_if  vif;

  virtual function void build_phase(uvm_phase phase); //contrucción de la interface virtual
    super.build_phase(phase);
    seq = escenario1::type_id::create("seq");
    seq.randomize();

  endfunction

  virtual task run_phase(uvm_phase phase); //task del escenario 1 
    `uvm_info("escenario1", "Iniciando la ejecucion de la prueba", UVM_HIGH)
    phase.raise_objection(this);
    seq.start(ambiente_instancia.agente_instancia.secuenciador_instancia);
    #200;
    phase.drop_objection(this);

  endtask

endclass  //endclass : test_01


// Test del escenario 2: Se generan secuencias que causen overflow, underflow, inf y NaN
class test_10 extends  test;

  `uvm_component_utils(test_10) //se registra la clase en la fábrica
  
  function new(string name = "escenario2",uvm_component parent=null); //se crea el constructor
    super.new(name,parent);
  endfunction
  
  escenario2 seq;  //instancio un puntero para el secuenciador de este segundo escenario

  virtual function void build_phase(uvm_phase phase); //contrucción de la interface virtual
    super.build_phase(phase);
    seq = escenario2::type_id::create("seq");
    seq.randomize();

  endfunction

  virtual task run_phase(uvm_phase phase); //task del escenario 2
    `uvm_info("escenario2", "Iniciando la ejecucion de la prueba", UVM_HIGH)
    phase.raise_objection(this);
    seq.start(ambiente_instancia.agente_instancia.secuenciador_instancia);
    #200;
    phase.drop_objection(this);

  endtask

endclass : test_10