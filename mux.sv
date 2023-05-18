`timescale 1ns / 1ps

module mux #(
    parameter DOUT_WIDTH = 8,
    parameter FREQUENCY_DIVIDER = 4,        
    parameter NUM_OF_ADC = 4             
)(
    axistream_if.slave s_axis[NUM_OF_ADC],
    input  CLK,
    input  rstn,
  
    input  logic [4:0] select_channel [0:3],     // 5 bits to choose from 32 channels for 4 outputs dout
    
    axistream_if.master m_axis
    );
             
    int m;
    logic valid;
    logic [3:0] valid_adc;
    logic [31:0] s_axis_tdata_o_;
    
    //AxiStream 4 buses               
     always @(posedge CLK) 
     begin
         if (!rstn) begin
             m_axis.tdata <= 0;
             m_axis.tvalid <= 0;
             valid_adc <= 0;
             s_axis_tdata_o_ <= 0;
         end
         
         else begin
         // ждём когда все данные valid, и выставляем общий valid в 1
             m_axis.tvalid <= 0;
             if (valid_adc == 4'b1111) begin
                 m_axis.tvalid <= 1;
                 m_axis.tdata <= s_axis_tdata_o_;
             end
        // выставление valid на отдельных каналах 
             if (m_axis.tvalid) 
                 valid_adc <= 4'b0000;
             valid = s_axis[0].tvalid | s_axis[1].tvalid | s_axis[2].tvalid | s_axis[3].tvalid;
             if (valid) begin   
                 for (int j = 0; j < NUM_OF_ADC; j++) begin
                     if (select_channel[j][4:3] == 0)
                         if (s_axis[0].tvalid && s_axis[0].tuser == select_channel[j][2:0]) 
                         begin
                             s_axis_tdata_o_[8*j +: DOUT_WIDTH] <= s_axis[0].tdata;
                             valid_adc[j] <= 1;
                         end
                         
                     if (select_channel[j][4:3] == 1)
                         if (s_axis[1].tvalid && s_axis[1].tuser == select_channel[j][2:0]) 
                         begin
                             s_axis_tdata_o_[8*j +: DOUT_WIDTH] <= s_axis[1].tdata;
                             valid_adc[j] <= 1;
                         end
                         
                     if (select_channel[j][4:3] == 2)
                         if (s_axis[2].tvalid && s_axis[2].tuser == select_channel[j][2:0]) 
                         begin
                             s_axis_tdata_o_[8*j +: DOUT_WIDTH] <= s_axis[2].tdata;
                             valid_adc[j] <= 1;
                         end
                         
                     if (select_channel[j][4:3] == 3)
                         if (s_axis[3].tvalid && s_axis[3].tuser == select_channel[j][2:0]) 
                         begin
                             s_axis_tdata_o_[8*j +: DOUT_WIDTH] <= s_axis[3].tdata;
                             valid_adc[j] <= 1;
                         end
                 end 
             end  
         end
     end

    assign m_axis.tstrb = 0;
    assign m_axis.tkeep = 0;
    assign m_axis.tlast = 0;
    assign m_axis.tid = 0;
    assign m_axis.tdest = 0;
    assign m_axis.tready = 0;
          
endmodule
