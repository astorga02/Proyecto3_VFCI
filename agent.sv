//INSTITUTO TECNOLÓGICO DE COSTA RICA
//VERIFICACIÓN FUNCIONAL DE CIRCUITOS INTEGRADOS
//Proyecto 2
//Lenguaje: SystemVerilog
//Creado por: Mac Alfred Pinnock Chacón (mcalfred32@gmail.com) y Susana Sevilla
class agent extends uvm_agent;

  `uvm_component_utils(agent) //se registra la clase en la fábrica

  function new(string name="agent",uvm_component parent=null); //se crea el constructor
    super.new(name, parent);
  endfunction

  driver  driver_instancia;  //driver handle
  monitor monitor_instancia;  //monitor handle
  uvm_sequencer #(Item) secuenciador_instancia;  //sequencer handle

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    driver_instancia = driver::type_id::create("driver_instancia",this);  //se saca de la fábrica     
    secuenciador_instancia = uvm_sequencer#(Item)::type_id::create("secuenciador_instancia",this); //se saca de la fábrica 
    monitor_instancia = monitor::type_id::create("monitor_instancia",this);  //se saca de la fábrica 
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    driver_instancia.seq_item_port.connect(secuenciador_instancia.seq_item_export);  //se conecta el puerto de análisis del secuenciador con el driver 
  endfunction

endclass 