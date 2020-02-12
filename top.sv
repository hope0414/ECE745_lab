`timescale 1ns / 10ps

`include "../../../verification_ip/interface_packages/i2c_pkg/src/i2c_if.sv"

module top();

parameter int WB_ADDR_WIDTH = 2;
parameter int WB_DATA_WIDTH = 8;
parameter int NUM_I2C_SLAVES = 1;
parameter int I2C_ADDR_WIDTH = 7;
parameter int I2C_DATA_WIDTH = 8;



bit  clk;
bit  rst = 1'b1;
wire cyc;
wire stb;
wire we;
tri ack;
wire [WB_ADDR_WIDTH-1:0] adr;
wire [WB_DATA_WIDTH-1:0] dat_wr_o;
wire [WB_DATA_WIDTH-1:0] dat_rd_i;
wire irq;
tri  [NUM_I2C_SLAVES-1:0] scl;
tri  [NUM_I2C_SLAVES-1:0] sda;

int i;
// ****************************************************************************
// Clock generator
initial begin: clk_gen
	clk = 1'b0;
	forever begin

	#5 clk = ~clk;
	end
end: clk_gen

// ****************************************************************************
// Reset generator
initial begin: rst_gen
	#113 rst = 0;
end: rst_gen

// ****************************************************************************
// Monitor Wishbone bus and display transfers in the transcript
bit [WB_ADDR_WIDTH - 1 : 0] addr_m;
bit [WB_DATA_WIDTH - 1 : 0] data_m;
bit we_m;
initial begin: wb_monitoring
	#113
	forever begin

	wb_bus.master_monitor(addr_m, data_m, we_m);


	//$display("address: %h, data: %h, we: %d", addr_m, data_m, we_m);
	end
end: wb_monitoring
// ****************************************************************************
// Define the flow of the simulation
byte DON_CMDR;

//write_data
/*
initial begin: test_flow
	#113
	wb_bus.master_write(2'b00, 8'b11xx_xxxx);	//1
	wb_bus.master_write(2'b01, 8'h01);	//3.1
	wb_bus.master_write(2'b10, 8'bxxxx_x110);	//3.2

	//wb_bus.master_read(2'b10, DON_CMDR);
	//wait(irq == 1'b1);
	while(!irq) @(posedge clk); //3.3
	wb_bus.master_read(2'b10, DON_CMDR);


	wb_bus.master_write(2'b10, 8'bxxxx_x100);	//3.4

	//wb_bus.master_read(2'b10, DON_CMDR);
	while(!irq) @(posedge clk);	//3.5
	wb_bus.master_read(2'b10, DON_CMDR);

	wb_bus.master_write(2'b01, 8'h02);	//3.6 slave address

	wb_bus.master_write(2'b10, 8'bxxxx_x001);	//3.7

	//wb_bus.master_read(2'b10, DON_CMDR);
	while(!irq) @(posedge clk);	//3.8
	wb_bus.master_read(2'b10, DON_CMDR);

	for(i = 0; i < 32; i++) begin
		wb_bus.master_write(2'b01, i);	//3.9

		wb_bus.master_write(2'b10, 8'bxxxx_x001);	//3.10


		//wb_bus.master_read(2'b10, DON_CMDR);
		while(!irq) @(posedge clk); //3.11

		wb_bus.master_read(2'b10, DON_CMDR);

	end
	wb_bus.master_write(2'b10, 8'bxxxx_x101);	//3.12

	//wb_bus.master_read(2'b10, DON_CMDR);
	while(!irq) @(posedge clk);	//3.13
	wb_bus.master_read(2'b10, DON_CMDR);


end: test_flow
*/
/*
bit [7:0] data_read;
initial begin: test_flow
	#113
	wb_bus.master_write(2'b00, 8'b11xx_xxxx);	//1
	wb_bus.master_write(2'b01, 8'h01);	//3.1
	wb_bus.master_write(2'b10, 8'bxxxx_x110);	//3.2

	//wb_bus.master_read(2'b10, DON_CMDR);
	//wait(irq == 1'b1);
	while(!irq) @(posedge clk); //3.3
	wb_bus.master_read(2'b10, DON_CMDR);


	wb_bus.master_write(2'b10, 8'bxxxx_x100);	//3.4

	//wb_bus.master_read(2'b10, DON_CMDR);
	while(!irq) @(posedge clk);	//3.5
	wb_bus.master_read(2'b10, DON_CMDR);

	wb_bus.master_write(2'b01, 8'h03);	//3.6 slave address

	wb_bus.master_write(2'b10, 8'bxxxx_x001);	//3.7

	//wb_bus.master_read(2'b10, DON_CMDR);
	while(!irq) @(posedge clk);	//3.8
	wb_bus.master_read(2'b10, DON_CMDR);

	//for(i = 0; i < 3; i++) begin
		//wb_bus.master_write(2'b01, 78);	//3.9
		repeat(31) begin
		wb_bus.master_write(2'b10, 8'bxxxx_x010);	//3.10

		while(!irq) @(posedge clk); //3.3
		wb_bus.master_read(2'b10, DON_CMDR);

		wb_bus.master_read(2'b01, data_read);
		//wb_bus.master_read(2'b10, DON_CMDR)array;

		end
	//end
	wb_bus.master_write(2'b10, 8'bxxxx_x011);	//3.10

	while(!irq) @(posedge clk); //3.3
	wb_bus.master_read(2'b10, DON_CMDR);

	wb_bus.master_read(2'b01, data_read);
	wb_bus.master_write(2'b10, 8'bxxxx_x101);	//3.12

	//wb_bus.master_read(2'b10, DON_CMDR);
	while(!irq) @(posedge clk);	//3.13
	wb_bus.master_read(2'b10, DON_CMDR);


end: test_flow
*/
task write_data_seq (input int times, input int value);
	wb_bus.master_write(2'b00, 8'b11xx_xxxx);	//1
	wb_bus.master_write(2'b01, 8'h01);	//3.1
	wb_bus.master_write(2'b10, 8'bxxxx_x110);	//3.2

	//wb_bus.master_read(2'b10, DON_CMDR);
	//wait(irq == 1'b1);
	while(!irq) @(posedge clk); //3.3
	wb_bus.master_read(2'b10, DON_CMDR);


	wb_bus.master_write(2'b10, 8'bxxxx_x100);	//3.4

	//wb_bus.master_read(2'b10, DON_CMDR);
	while(!irq) @(posedge clk);	//3.5
	wb_bus.master_read(2'b10, DON_CMDR);

	wb_bus.master_write(2'b01, 8'h02);	//3.6 slave address

	wb_bus.master_write(2'b10, 8'bxxxx_x001);	//3.7

	//wb_bus.master_read(2'b10, DON_CMDR);
	while(!irq) @(posedge clk);	//3.8
	wb_bus.master_read(2'b10, DON_CMDR);

	for(i = 0; i < times; i++) begin
		wb_bus.master_write(2'b01, value);	//3.9

		wb_bus.master_write(2'b10, 8'bxxxx_x001);	//3.10


		//wb_bus.master_read(2'b10, DON_CMDR);
		while(!irq) @(posedge clk); //3.11

		wb_bus.master_read(2'b10, DON_CMDR);

	end
	wb_bus.master_write(2'b10, 8'bxxxx_x101);	//3.12

	//wb_bus.master_read(2'b10, DON_CMDR);
	while(!irq) @(posedge clk);	//3.13
	wb_bus.master_read(2'b10, DON_CMDR);


endtask

bit [7:0] data_read;
task read_data_seq(input int times);
	wb_bus.master_write(2'b00, 8'b11xx_xxxx);	//1
	wb_bus.master_write(2'b01, 8'h01);	//3.1
	wb_bus.master_write(2'b10, 8'bxxxx_x110);	//3.2

	//wb_bus.master_read(2'b10, DON_CMDR);
	//wait(irq == 1'b1);
	while(!irq) @(posedge clk); //3.3
	wb_bus.master_read(2'b10, DON_CMDR);


	wb_bus.master_write(2'b10, 8'bxxxx_x100);	//3.4

	//wb_bus.master_read(2'b10, DON_CMDR);
	while(!irq) @(posedge clk);	//3.5
	wb_bus.master_read(2'b10, DON_CMDR);

	wb_bus.master_write(2'b01, 8'h03);	//3.6 slave address

	wb_bus.master_write(2'b10, 8'bxxxx_x001);	//3.7

	//wb_bus.master_read(2'b10, DON_CMDR);
	while(!irq) @(posedge clk);	//3.8
	wb_bus.master_read(2'b10, DON_CMDR);

	//for(i = 0; i < 3; i++) begin
		//wb_bus.master_write(2'b01, 78);	//3.9
		repeat(times - 1) begin
		wb_bus.master_write(2'b10, 8'bxxxx_x010);	//3.10

		while(!irq) @(posedge clk); //3.3
		wb_bus.master_read(2'b10, DON_CMDR);

		wb_bus.master_read(2'b01, data_read);
		//wb_bus.master_read(2'b10, DON_CMDR)array;

		end
	//end
	wb_bus.master_write(2'b10, 8'bxxxx_x011);	//3.10

	while(!irq) @(posedge clk); //3.3
	wb_bus.master_read(2'b10, DON_CMDR);

	wb_bus.master_read(2'b01, data_read);
	wb_bus.master_write(2'b10, 8'bxxxx_x101);	//3.12

	//wb_bus.master_read(2'b10, DON_CMDR);
	while(!irq) @(posedge clk);	//3.13
	wb_bus.master_read(2'b10, DON_CMDR);

endtask

//bit [I2C_ADDR_WIDTH - 1 : 0] addr_m2;
//bit [I2C_DATA_WIDTH -1 : 0] data_m2[];

bit [I2C_DATA_WIDTH - 1 : 0]  array[];
int i_loop;
initial begin: loop
	i2c_op_t operation;
	bit [I2C_ADDR_WIDTH - 1 : 0] addr_m2;
	bit [I2C_DATA_WIDTH -1 : 0] data_m2[];
	//data_m2 = new[32];
	array = new[1];
	//foreach(array[k])	array[k] = 64 - k;
	array[0] = 63;
 	i_loop = 0;
	//data_m2 = new[32];
	#113
	forever	begin
	i2c_bus.wait_for_i2c_transfer(operation, data_m2);
	if(operation == R)	begin
		i2c_bus.provide_read_data(array);
		array[0]--;
		i_loop++;
	end
	end
end: loop

int i_testbench;
initial begin:testbench
	#113
	i_testbench = 64;
	repeat(64) begin
	write_data_seq(1, i_testbench);
	read_data_seq(1);
	i_testbench++;
	end
end: testbench

initial begin:monitor_i2c_bus
	bit [I2C_ADDR_WIDTH -1 : 0] monitor_addr;
	i2c_op_t monitor_op;
	bit [I2C_DATA_WIDTH-1:0] monitor_data[];
	forever begin

	i2c_bus.monitor(monitor_addr, monitor_op, monitor_data);
	if(monitor_op == W)
		$display("Addr: %d, operation: WRITE, data: %p", monitor_addr, monitor_data);
	else
		$display("Addr: %d, operation: READ, data: %p", monitor_addr, monitor_data);

	//$display("========== STOP ===========");
	end

end: monitor_i2c_bus

/*
initial begin: monitor_i2c_bus
	int i, j, size;
	//i2c_if.monitor(addr_m, operation, data_m);
	size = data_m[].size;
	if(operation == R) begin
		$display("I2C_BUS WRITE transfer:");
		for(i = 0; i < size; i++)
			$display("data[%d] = %h", i, data_m[i]);

	end
	else	begin
		$display("I2C_BUS READ transfer:");
		for(i = 0; i < size; i++)
			$display("data[%d] = %h", i, data_m[i]);
	end
end: monitor_i2c_bus
*/
// ****************************************************************************
// Instantiate the Wishbone master Bus Functional Model
wb_if       #(
      .ADDR_WIDTH(WB_ADDR_WIDTH),
      .DATA_WIDTH(WB_DATA_WIDTH)
      )
wb_bus (
  // System sigals
  .clk_i(clk),
  .rst_i(rst),
  // Master signals
  .cyc_o(cyc),
  .stb_o(stb),
  .ack_i(ack),
  .adr_o(adr),
  .we_o(we),
  // Slave signals
  .cyc_i(),
  .stb_i(),
  .ack_o(),
  .adr_i(),
  .we_i(),
  // Shred signals
  .dat_o(dat_wr_o),
  .dat_i(dat_rd_i)
  );

// ****************************************************************************
// Instantiate the DUT - I2C Multi-Bus Controller
\work.iicmb_m_wb(str) #(.g_bus_num(NUM_I2C_SLAVES)) DUT
  (
    // ------------------------------------
    // -- Wishbone signals:
    .clk_i(clk),         // in    std_logic;                            -- Clock
    .rst_i(rst),         // in    std_logic;                            -- Synchronous reset (active high)
    // -------------
    .cyc_i(cyc),         // in    std_logic;                            -- Valid bus cycle indication
    .stb_i(stb),         // in    std_logic;                            -- Slave selection
    .ack_o(ack),         //   out std_logic;                            -- Acknowledge output
    .adr_i(adr),         // in    std_logic_vector(1 downto 0);         -- Low bits of Wishbone address
    .we_i(we),           // in    std_logic;                            -- Write enable
    .dat_i(dat_wr_o),    // in    std_logic_vector(7 downto 0);         -- Data input
    .dat_o(dat_rd_i),    //   out std_logic_vector(7 downto 0);         -- Data output
    // ------------------------------------
    // ------------------------------------
    // -- Interrupt request:
    .irq(irq),           //   out std_logic;                            -- Interrupt request
    // ------------------------------------
    // ------------------------------------
    // -- I2C interfaces:
    .scl_i(scl),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Clock inputs
    .sda_i(sda),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Data inputs
    .scl_o(scl),         //   out std_logic_vector(0 to g_bus_num - 1); -- I2C Clock outputs
    .sda_o(sda)          //   out std_logic_vector(0 to g_bus_num - 1)  -- I2C Data outputs
    // ------------------------------------
  );

i2c_if i2c_bus(
	.SDA(sda),
	.SCL(scl)

	);

endmodule
