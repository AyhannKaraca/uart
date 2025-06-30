module tb_uart_rx();

    logic        clk;
    logic        rstn;
    logic [7:0]  dout;
    logic        rx;
    logic        rx_done_tick;

    uart_rx i_uart_rx(
        .clk_i(clk),
        .rstn_i(rstn),
        .rx_i(rx),
        .rx_dout_o(dout),
        .rx_done_tick_o(rx_done_tick)
    );

    initial forever begin
        clk = 0;
        #5;
        clk = 1;
        #5;
    end
    initial begin
        rstn = 0;
        #100;
        rstn = 1;


        rx	 = 0;
        #100;


        rx	 = 1; //10101011 0xAB
        #100;
        rx	 = 1;
        #100;
        rx	 = 0;
        #100;
        rx	 = 1;
        #100;
        rx	 = 0;
        #100;
        rx	 = 1;
        #100;
        rx	 = 0;
        #100;
        rx	 = 1;
        #100;
        rx	 = 1;
        #100;
        rx	 = 1;
        #100;

        #300;
        $finish;
    end

        
   initial begin
      $dumpfile("dump.vcd");
      $dumpvars();
   end
    
endmodule
