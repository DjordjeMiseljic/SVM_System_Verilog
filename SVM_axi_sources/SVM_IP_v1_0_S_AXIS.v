
`timescale 1 ns / 1 ps

	module SVM_IP_v1_0_S_AXIS #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line

		// AXI4Stream sink: Data Width
		parameter integer C_S_AXIS_TDATA_WIDTH	= 32
	)
	(
		// Users to add ports here
        input wire SVM_SREADY,
        output wire SVM_SVALID,
        output wire [C_S_AXIS_TDATA_WIDTH-1 :0] SVM_SDATA,
		// User ports ends
		// Do not modify the ports beyond this line

		// AXI4Stream sink: Clock
		input wire  S_AXIS_ACLK,
		// AXI4Stream sink: Reset
		input wire  S_AXIS_ARESETN,
		// Ready to accept data in
		output wire  S_AXIS_TREADY,
		// Data in
		input wire [C_S_AXIS_TDATA_WIDTH-1 : 0] S_AXIS_TDATA,
		// Byte qualifier
		input wire [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] S_AXIS_TSTRB,
		// Indicates boundary of last packet
		input wire  S_AXIS_TLAST,
		// Data is in valid
		input wire  S_AXIS_TVALID
	);



	wire  	axis_ready;
    wire    axis_valid;
    wire [C_S_AXIS_TDATA_WIDTH-1 : 0]   axis_data;
	
	
	
	assign S_AXIS_TREADY	= axis_ready;
    assign axis_ready    =   SVM_SREADY;
    
    assign SVM_SVALID	= axis_valid;
    assign axis_valid    =  S_AXIS_TVALID;
        
    assign SVM_SDATA	= axis_data;
    assign axis_data = S_AXIS_TDATA;
	
	

	endmodule
