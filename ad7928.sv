`timescale 1ns / 1ps


module ad7928 # (
    parameter DOUT_WIDTH = 8,
    parameter FREQUENCY_DIVIDER = 4,
    parameter WRITE = 1,
    parameter SEQ = 0,
    parameter DONT_CARE = 0,
    parameter [1:0] PM = 'b11,
    parameter SHADOW = 0,
    parameter RANGE = 0,
    parameter CODING = 0
   )     
   (
    input      CLK,
    input      rstn,
    
    axistream_if.master m_axis,
    spi_if.master m_spi
);
    
    reg [2:0] cntr_scale = 0;

    reg [15:0] mem_control_reg = 0;  // MOSI (DIN in AD7928)
    reg [15:0] mem_dout = 0;         // MISO (DOUT in AD7928)

    reg [5:0] cnt = 1'b0;
    reg [1:0] rst_cnt = 2'b0;
    reg [2:0] ctrl_reg_addr_cnt = 3'b0;
  
  
    always @(posedge CLK) begin
    // делитель частоты    
        if (cntr_scale == (FREQUENCY_DIVIDER - 'b1)) begin
            cntr_scale <= 0;
            m_spi.sck <= 1;
        end
        else begin
            cntr_scale <= cntr_scale + 1; 
            if (cntr_scale == (FREQUENCY_DIVIDER/2 - 'b1)) 
                m_spi.sck <= 0;     
        end  
    end


    always @(posedge CLK or negedge rstn) begin
        if (!rstn) begin
            mem_dout <= 0;
            m_axis.tdata <= 0;
            m_axis.tuser <= 0;
            m_axis.tvalid <= 0;
        end
        // проверка на negedge SCLK
        else begin
            m_axis.tvalid <= 0; 
            if (cntr_scale == 1) begin
                if (cnt <= 5'd17) 
                    mem_dout <= { mem_dout[14:0], m_spi.miso };
                else if (cnt == 5'd18) begin
                    m_axis.tdata <= mem_dout[11 -: DOUT_WIDTH];
                    m_axis.tuser <= mem_dout[14:12];
                    m_axis.tvalid <= 1;           
                end          
            end
        end 
    end 

    always @(posedge CLK or negedge rstn) begin
        if (!rstn) begin
            m_spi.cs_n <= 1;
            m_spi.mosi_o <= 0;
            mem_control_reg <= 0;
            rst_cnt = 2'd3;
            cnt <= 0;
        end
        // проверка на posedge SCLK
        else if (cntr_scale == 'd3) begin
     
            if (cnt != 5'd20)
                cnt <= cnt + 1'b1;
            else begin
                cnt <= 5'b0;
            end
            
            if (cnt == 1'b0) begin
                mem_control_reg[12:10] <= ctrl_reg_addr_cnt;
                {mem_control_reg[15:13], mem_control_reg[9:0]} <= {WRITE, SEQ, DONT_CARE, PM, SHADOW, DONT_CARE, RANGE, CODING}; // 13'b1_0_0_11_0_0_0_0_0000;
            end 
            else if (cnt == 1'b1) begin
                m_spi.cs_n <= 1'b0;  
            end 
            else if (cnt == 5'd17) begin
                     m_spi.cs_n <= 1'b1;
            end 
            else if (cnt == 5'd20) begin
                if (ctrl_reg_addr_cnt != 3'd7) 
                    ctrl_reg_addr_cnt <= ctrl_reg_addr_cnt + 3'd1;
                else 
                    ctrl_reg_addr_cnt <= 0;
            end
  
            if (rst_cnt > 2'd1) begin
                if (cnt == 5'd1)
                    m_spi.mosi_o <= 1;
                if (cnt == 5'd20)
                    rst_cnt <= rst_cnt - 1'd1;
            end
            else begin
                 if (cnt == 5'd20 && rst_cnt != 0)
                     rst_cnt <= rst_cnt - 1'd1;
                 if (cnt >= 1 && cnt <= 5'd16)
                     {m_spi.mosi_o, mem_control_reg} <= { mem_control_reg, 1'b0 };
            end  
        end
    end  
    
    assign m_axis.tstrb = 0;
    assign m_axis.tkeep = 0;
    assign m_axis.tlast = 0;
    assign m_axis.tid = 0;
    assign m_axis.tdest = 0;
    assign m_axis.tready = 0;
    
    assign m_spi.mosi_i = 0;
    assign m_spi.mosi_oen = 0;
    
endmodule
