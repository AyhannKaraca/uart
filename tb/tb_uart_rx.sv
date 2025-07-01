module tb_uart_rx();

    logic        clk;
    logic        rstn;
    logic [7:0]  dout;
    logic        rx;
    logic        rx_done_tick;
    logic        rx_active;

    uart_rx i_uart_rx(
        .clk_i(clk),
        .rstn_i(rstn),
        .rx_i(rx),
        .rx_dout_o(dout),
        .rx_done_tick_o(rx_done_tick),
        .rx_active_o(rx_active)
    );

    logic [9:0] c_00 = {1'b1,8'h00,1'b0};
    logic [9:0] c_ab = {1'b1,8'hab,1'b0};
    logic [9:0] c_fd = {1'b1,8'hfd,1'b0};

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
        for(int i = 0; i<10; i++)begin
            rx = c_00[i];
            #100;
        end
        #400;
        for(int i = 0; i<10; i++)begin
            rx = c_ab[i];
            #100;
        end
        #400;
        for(int i = 0; i<10; i++)begin
            rx = c_fd[i];
            #100;
        end
        #300;
        $finish;
    end

        
   initial begin
      $dumpfile("dump.vcd");
      $dumpvars();
   end
    
endmodule
