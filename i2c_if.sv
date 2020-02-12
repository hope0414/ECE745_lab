typedef enum bit {W, R} i2c_op_t;
interface i2c_if #(
	int I2C_DATA_WIDTH = 8,
	int I2C_ADDR_WIDTH = 7
	)
(
	inout triand SDA,
	input triand SCL

	);

parameter ad = 1;

bit SDA_o = 1'b1;
bit i2c_op = 0;

reg [I2C_ADDR_WIDTH - 1 : 0] address;
bit addr_flag;
bit restart_flag;

assign SDA = SDA_o ? 'bz:'b0;
//sda = sda_o? 'bz:'b0
task wait_for_i2c_transfer ( output i2c_op_t op, output bit [I2C_DATA_WIDTH-1:0] write_data []);
//The wait_for_i2c_transfer task is called in order to wait for an i2c transfer to be initiated by the DUT.
//The task will block until the transfer has been initiated and the initial part of the transfer has been captured.
//The task returns the information received in the first part of the transfer.
	int i, j;
	//bit prev_sda;
//typedef enum {W, R} i2c_op_t;
//do begin
	if(!restart_flag) begin
		do
			@(negedge SDA);
		while(!SCL);
		restart_flag = 0;
	end


	for(i = 0; i < I2C_ADDR_WIDTH; i++)
		begin
			@(posedge SCL);
			address[I2C_ADDR_WIDTH - 1 - i] = SDA;
		end

		@(posedge SCL);
		if(SDA)	i2c_op = 1;
		else	i2c_op = 0;

		if(i2c_op)	begin
			op = R;
		end
		else	begin
			op = W;
		end


		@(negedge SCL);
		if(address == ad)	begin
		SDA_o = 0;
		//addr_flag = 0;
		end
		else	begin
		SDA_o = 1;
		//addr_flag = 1;
		end

		if(op == W)	begin
			@(negedge SCL);
			SDA_o = 1;
			//$display("Yes");
		end

i = 0;
	if(op == W)	begin
		forever

			begin
				@(posedge SCL);
				//prev_sda = SDA;
				@(SDA or negedge SCL);
				if(!SCL) begin
					write_data = new[i + 1](write_data);
					write_data[i][7] = SDA;
				end	// new data
				else if(SDA)	begin
					//$display("STOP");
					break;
				end
				else if(!SDA)	begin
					restart_flag = 1;
					break;
				end

				for(j = 6; j >= 0; j--)
					begin
						@(posedge SCL);
						//$display("DATA: %d", SDA);
						write_data[i][j] = SDA;
						//$display("index: %d", j);
					end
					//$display("Write_data[%d] = %p", i, write_data[i]);
					@(negedge SCL);
					SDA_o = 0;
					@(negedge SCL);
					SDA_o = 1;
					i++;
			end

	end
endtask : wait_for_i2c_transfer
//bit [I2C_DATA_WIDTH-1:0] data;
task provide_read_data ( input bit [I2C_DATA_WIDTH-1:0] read_data []);
//If the transfer is a read operation, the responder needs to provide data to the DUT at the end of the transfer.
//The provide_read_data task provides read data to complete a read operation.
int i, j;
i = 0;
@(posedge SCL);
if(SDA == 1) begin
	@(posedge SCL);
	@(SDA);
	if(!SDA) begin
		restart_flag = 1;
	end
end
else begin
	forever
		begin
 		for(j = 7; j >= 0; j--)begin	//8 bit
				@(negedge SCL);
				//$display("New bit");
				SDA_o = read_data[i][j];
				//$display("SDA_o: %d", SDA_o);
				//$display("index: %d", j);
				//data[j] = read_data[i][I2C_ADDR_WIDTH - 1 - j];
			end
			@(negedge SCL);
			SDA_o = 1;	//release SCL
				//data = read_data[i];

			@(posedge SCL);
			if(SDA == 0) begin
				//$display("SDA: %d, Yes, ACK", SDA);
				i++;
			end
			else begin
				@(posedge SCL);
				@(SDA);
				if(!SDA) begin
					restart_flag = 1;
				end
				else begin
					//$display("==== STOP ====");
				end
				break;
			end
		end
	end

endtask : provide_read_data

//bit [I2C_DATA_WIDTH - 1: 0] monitor_data;

task monitor ( output bit [I2C_ADDR_WIDTH-1:0] addr, output i2c_op_t op, output bit [I2C_DATA_WIDTH-1:0] data []);
//The monitor task observes the full transfer and returns observed information from the transfer in its arguments,
//just as the WB interface master_monitor task operated.

//The i2c_op_t is an enumerated type, that you need to define.
//It includes all of the different operations performed by I2C in its enumerations.
int i, j;

	if(!restart_flag) begin
		do
			@(negedge SDA);
		while(!SCL);
		//$display("========== Start ===========");
	//int i, j;
	end

	for(i = 0; i < I2C_ADDR_WIDTH; i++)
		begin
			@(posedge SCL);
			addr[I2C_ADDR_WIDTH - 1 - i] = SDA;
		end
		//$write("address: %b, ", addr);

		@(posedge SCL);
		if(SDA)	begin
			op = R;
			$display("I2C_BUS READ Transfer: ");
		end
		else begin
			op = W;
			$display("I2C_BUS WRITE Transfer: ");
		end

		@(negedge SCL);

		if(op == W)	begin
			@(negedge SCL);
		//	SDA_o = 1;
			//$display("Yes");
		end
	//for(i = 0; ; i++)	begin
	i = 0;
	if(op == W)	begin
		forever
		begin
			@(posedge SCL);
			//prev_sda = SDA;
			@(SDA or negedge SCL);
			if(!SCL) begin
				data = new[i + 1](data);
				data[i][7] = SDA;
			end	// new data
			else if(SDA)	begin
				//$display("STOP");
				break;
			end
			else if(!SDA)	begin

				break;
			end

			for(j = 6; j >= 0; j--)
				begin
					@(posedge SCL);
					//$display("DATA: %d", SDA);
					data[i][j] = SDA;
					//$display("index: %d", j);
				end
				//$display("Write_data[%d] = %p", i, write_data[i]);
				@(negedge SCL);

				@(negedge SCL);

				i++;
		end
	end

	if(op == R) begin
		@(posedge SCL);
		if(SDA == 1) begin
			@(posedge SCL);
			@(SDA);
			if(!SDA) begin
				//restart_flag = 1;
			end
		end
		else begin
			forever
				begin
				for(j = 7; j >= 0; j--)begin	//8 bit
						@(posedge SCL);
						data = new[i + 1](data);
						//$display("New bit");
						//SDA_o = read_data[i][j];
						data[i][j] = SDA;
						//$display("SDA: %d", SDA);
						//$display("index: %d", j);
						//data[j] = read_data[i][I2C_ADDR_WIDTH - 1 - j];
					end
					@(negedge SCL);
					//SDA_o = 1;	//release SCL
						//data = read_data[i];

					@(posedge SCL);
					if(SDA == 0) begin
						//$display("SDA: %d, Yes, ACK", SDA);
						i++;
					end
					else begin
						@(posedge SCL);
						@(SDA);
						if(!SDA) begin
							//restart_flag = 1;
							//$display("==== RE-start ====");
						end
						else begin
							//$display("==== STOP ====");
						end
						break;
					end
				end
			end
		end

endtask : monitor

endinterface
