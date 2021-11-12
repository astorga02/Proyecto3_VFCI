//INSTITUTO TECNOLÓGICO DE COSTA RICA
//VERIFICACIÓN FUNCIONAL DE CIRCUITOS INTEGRADOS
//Proyecto 2
//Lenguaje: SystemVerilog
//Creado por: Mac Alfred Pinnock Chacón (mcalfred32@gmail.com) y Susana Astorga Rodríguez (susana.0297.ar@gmail.com)
class driver extends uvm_driver #(Item); //instancio el driver con el parámetro Item que va a recibir
  `uvm_component_utils(driver) //se registra la clase en la fábrica
  function new(string name= "driver", uvm_component parent = null); //se crea el constructor
    super.new(name,parent);
  endfunction

  virtual dut_if vif; //interface virtual que se va a conectar al DUT

  virtual function void build_phase(uvm_phase phase);  //contrucción de la interface virtual
    super.build_phase(phase);
    if(!uvm_config_db#(virtual dut_if)::get(this,"","dut_vif", vif))
      `uvm_fatal("DRV", "No se pudo obtener la interface virtual");
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      Item m_item;  //se crea un puntero de tipo Item 
      `uvm_info("DRV", $sformatf("Espere el elemento del secuenciador"), UVM_HIGH);
      seq_item_port.get_next_item(m_item);  //espera hasta que haya un item en el secuenciador
      drive_item(m_item); //lo procesa
      seq_item_port.item_done(); //una vez que termina de procesar continua con otro item
    end
  endtask

  virtual task drive_item(Item m_item);
    @(vif.cb_clk); //espera a que se de un flanco positvo de reloj en cb_clk
      vif.cb_clk.fp_X <= m_item.fp_X;
      vif.cb_clk.fp_Y <= m_item.fp_Y;
      vif.cb_clk.r_mode <= m_item.r_mode;
  endtask 
endclass
