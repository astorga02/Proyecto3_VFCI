//INSTITUTO TECNOLÓGICO DE COSTA RICA
//VERIFICACIÓN FUNCIONAL DE CIRCUITOS INTEGRADOS
//Proyecto 2
//Lenguaje: SystemVerilog
//Creado por: Mac Alfred Pinnock Chacón (mcalfred32@gmail.com) y Susana Astorga

//`timescale 1ns / 1ps

//`include "uvm_macros.svh"
//`include "multiplicador_32_bits_FP_IEEE.sv"
`include "interface.sv"
`include "sequence_item.sv"
`include "sequence.sv"
`include "monitor.sv"
`include "driver.sv"
`include "scoreboard.sv"
`include "agent.sv"
`include "environment.sv"
`include "test.sv"

module top_testbench;

	import uvm_pkg::*;
	reg clk;

  	always #10 clk =~ clk;
  	dut_if _if(clk);
	
	top dut0(     //se conecta con el DUT
  	.clk (clk),
  	.r_mode(_if.r_mode),
  	.fp_X(_if.fp_X), .fp_Y(_if.fp_Y),
  	.fp_Z(_if.fp_Z),
  	.ovrf(_if.ovrf), .udrf(_if.udrf));


	initial begin
		clk <= 0;
		`uvm_info("TOP", "Test start", UVM_LOW);
		uvm_config_db#(virtual dut_if)::set(null,"uvm_test_top","dut_vif",_if); //se conecta la interface virtual con el test_top
      run_test("test_10"); //se coloca el nombre del test a probar (test_01 o test_10)
	end
	
endmodule