
/*
 * spi.sv -- SPI interface
 *
 * 2019, Alexander Orlov <alxorlov@olvs.miee.ru>
 */

interface spi_if ();

	logic cs_n;
	logic sck;
	logic miso;
	logic mosi_i;
	logic mosi_o, mosi_oen;

	modport master (
		output cs_n,
		output sck,
		input miso,
		input mosi_i,
		output mosi_o, mosi_oen
	);

endinterface
