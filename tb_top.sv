`timescale 1ns / 1ps

module tb_top #(
    parameter DOUT_WIDTH = 8,
    parameter FREQUENCY_DIVIDER = 4,
    parameter NUM_OF_ADC = 4
)();

    logic CLK;
    logic rstn;
    logic [4:0] sel [0:3];
        
    axistream_if axis_intf(CLK);
    spi_if spi_intf[NUM_OF_ADC]();


    top dut (.CLK(CLK),
             .rstn(rstn),            
             .sel(sel),
             .m_axis(axis_intf),
             .m_spi(spi_intf)
             );
             
    logic [15:0] DIN_ADC [0:NUM_OF_ADC-1];   // data to ADC
    logic [15:0] DOUT_ADC [0:NUM_OF_ADC-1];  // data from ADC
    logic [3:0] i = 0;
             
             
    initial CLK = 0;
    always #10 CLK <= ~CLK;
    
    initial begin
        rstn = 0;
        #610;
        @(posedge CLK);
        #1;
        rstn = 1;
        
        sel[0] = 'd20; 
        sel[1] = 'd11;
        sel[2] = 'd29;
        sel[3] = 'd0;
        
        forever begin  
                
            fork
                begin
                   @(negedge spi_intf[0].master.cs_n); 
                   DOUT_ADC[0][11:4] = $random();
                   {DOUT_ADC[0][15:12], DOUT_ADC[0][3:0]} = {1'b0, DIN_ADC[0][12:10], 4'b0};
                   spi_intf[0].master.miso = DOUT_ADC[0][15];
                end
                
                begin
                   @(negedge spi_intf[1].master.cs_n); 
                   DOUT_ADC[1][11:4] = $random();
                   {DOUT_ADC[1][15:12], DOUT_ADC[1][3:0]} = {1'b0, DIN_ADC[1][12:10], 4'b0};
                   spi_intf[1].master.miso = DOUT_ADC[1][15];
                end
                
                begin
                   @(negedge spi_intf[2].master.cs_n); 
                   DOUT_ADC[2][11:4] = $random();
                   {DOUT_ADC[2][15:12], DOUT_ADC[2][3:0]} = {1'b0, DIN_ADC[2][12:10], 4'b0};
                   spi_intf[2].master.miso = DOUT_ADC[2][15];
                end
                
                begin
                   @(negedge spi_intf[3].master.cs_n);
                   DOUT_ADC[3][11:4] = $random();
                   {DOUT_ADC[3][15:12], DOUT_ADC[3][3:0]} = {1'b0, DIN_ADC[3][12:10], 4'b0};
                   spi_intf[3].master.miso = DOUT_ADC[3][15]; 
                end
            join
            
            i = 14;
                
            repeat (16) begin
                @(negedge spi_intf[0].master.sck);
                    fork
                        begin
                            DIN_ADC[0] = { DIN_ADC[0][14:0], spi_intf[0].master.mosi_o };
                            #1;
                            spi_intf[0].master.miso = DOUT_ADC[0][i]; 
                        end
                        begin
                            DIN_ADC[1] = { DIN_ADC[1][14:0], spi_intf[1].master.mosi_o };
                            #1;
                            spi_intf[1].master.miso = DOUT_ADC[1][i]; 
                        end
                        begin
                            DIN_ADC[2] = { DIN_ADC[2][14:0], spi_intf[2].master.mosi_o };
                            #1;
                            spi_intf[2].master.miso = DOUT_ADC[2][i]; 
                        end
                        begin
                            DIN_ADC[3] = { DIN_ADC[3][14:0], spi_intf[3].master.mosi_o };
                            #1;
                            spi_intf[3].master.miso = DOUT_ADC[3][i]; 
                        end
                    join
                    if (i != 0)  
                        i--;
                end            
        end    
        
    end

endmodule
