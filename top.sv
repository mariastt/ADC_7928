`timescale 1ns / 1ps

module top #(
    parameter DOUT_WIDTH = 8,
    parameter FREQUENCY_DIVIDER = 4,                         // делитель чатоты
    parameter NUM_OF_ADC = 4                                 // количество АЦП 
)(
    input    CLK,
    input    rstn,
    
    input logic [4:0] sel [0:3],                             // 5 bits to choose from 32 channels
    
    axistream_if.master m_axis,
    spi_if.master m_spi[NUM_OF_ADC]
);

    axistream_if #(.DWIDTH(DOUT_WIDTH), .USER_WIDTH(3)) axis_adc[NUM_OF_ADC](CLK);
                
    genvar k;
    generate
        for (k=0; k < 4; k++) begin
            ad7928 adc (.CLK(CLK),
                        .rstn(rstn),
                        .m_axis(axis_adc[k]),
                        .m_spi(m_spi[k])
                        ); 
        end
    endgenerate 
                  
    mux MUX      (.CLK(CLK),
                  .rstn(rstn),
                  .s_axis(axis_adc),
                  .m_axis(m_axis),
                  .select_channel(sel)
                  );               
    
endmodule