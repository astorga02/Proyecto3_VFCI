//INSTITUTO TECNOLÓGICO DE COSTA RICA
//VERIFICACIÓN FUNCIONAL DE CIRCUITOS INTEGRADOS
//Proyecto 2
//Lenguaje: SystemVerilog
//Creado por: Mac Alfred Pinnock Chacón (mcalfred32@gmail.com) y Susana Astorga (susana.0297.ar@gmail.com)
class monitor extends uvm_monitor;

  `uvm_component_utils(monitor) //se registra la clase en la fábrica

  function new(string name="monitor",uvm_component parent=null); //se crea el constructor
    super.new(name,parent);
  endfunction

  uvm_analysis_port #(Item) mon_analysis_port; //se genera el puerto de análisis puerto por donde se envían las transacciones hacia el scoreboard
  virtual dut_if vif; //interface virtual

  virtual function void build_phase(uvm_phase phase); //contrucción de la interface virtual
    super.build_phase(phase);
    if(!uvm_config_db#(virtual dut_if)::get(this,"","dut_vif",vif))
      `uvm_fatal("MON","No se pudo obtener la interface virtual")
    mon_analysis_port = new("mon_analysis_port", this); //se instancia el puerto de análisis
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever @(vif.cb_clk) begin //espera a que se de un flanco positvo de reloj en cb_clk
      
      Item item = Item::type_id::create("item");
      //Asignaciones 
      item.fp_Z = vif.cb_clk.fp_Z;   //resultado salida
      item.ovrf = vif.cb_clk.ovrf;   // overflow
      item.udrf = vif.cb_clk.udrf;   //underflow
      item.r_mode = vif.r_mode;  //modo de redondeo
      item.fp_X = vif.fp_X;      //dato x
      item.fp_Y = vif.fp_Y;      //dato y

      mon_analysis_port.write(item);
      `uvm_info("MON",$sformatf("SAW item %s", item.convert2str()),UVM_HIGH)
    
    end
  endtask
endclass