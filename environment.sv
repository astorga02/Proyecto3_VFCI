//INSTITUTO TECNOLÓGICO DE COSTA RICA
//VERIFICACIÓN FUNCIONAL DE CIRCUITOS INTEGRADOS
//Proyecto 2
//Lenguaje: SystemVerilog
//Creado por: Mac Alfred Pinnock Chacón (mcalfred32@gmail.com) y Susana Astorga Rodríguez (susana.0297.ar@gmail.com)


class env extends uvm_env;

  `uvm_component_utils(env) //se registra la clase en la fábrica
  
  function new(string name="env", uvm_component parent=null); //se crea el constructor
    super.new(name,parent);
  endfunction

  agent  agente_instancia; //instancio un puntero para el agente - agent handle
  scoreboard scoreboard_instancia; //scoreboard handle

  virtual function void build_phase(uvm_phase phase); //se crea contenido en la fase build
    super.build_phase(phase);
    agente_instancia = agent::type_id::create("agente_instancia",this);  //se llaman de la fábrica
    scoreboard_instancia = scoreboard::type_id::create("scoreboard_instancia",this); //se llaman de la fábrica
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agente_instancia.monitor_instancia.mon_analysis_port.connect(scoreboard_instancia.m_analysis_imp);  //se conectan los puertos de análisis 
  endfunction

endclass
