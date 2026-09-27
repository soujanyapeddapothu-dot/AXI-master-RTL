`timescale 1ns / 1ps

module axi_master(
aclk,arst,
awid,awaddr,awburst_length,awburst_size,awburst_type,awvalid,awready,
wid,wdata,wstrb,wlast,wvalid,wready,
bid,bresp,bvalid,bready,
arid,araddr,arburst_length,arburst_size,arburst_type,arvalid,arready,
rid,rdata,rlast,rresp,rvalid,rready
);
	parameter ADDR_WIDTH 	= 32;
	parameter DATA_WIDTH 	= 32;
	parameter DATA_DEPTH    = 32;
	parameter BURST_LENGTH 	= 4;
	parameter STRB_SIZE  	= DATA_WIDTH/8;
	parameter BURST_SIZE 	= $clog2(STRB_SIZE);
	parameter ID_SIZE    	= $clog2(ADDR_WIDTH);
	parameter OKAY          = 2'b00;
	parameter EX_OKAY       = 2'b01;
	parameter FIXED         = 2'b00;
	parameter INCR          = 2'b01;
	parameter WRAP          = 2'b10;
	integer i,j,k;
	input                     aclk;
    input                     arst;
    //---------------------( AW )-------------------	
    output reg  [ID_SIZE-1:0]      awid;
    output reg  [ADDR_WIDTH-1:0]   awaddr;
    output reg  [7:0]              awburst_length;
    output reg  [3:0]              awburst_size;
    output reg  [1:0]              awburst_type;
    output reg                     awvalid;
    input                          awready;
    //-------------------------( W )----------------
   output reg  [ID_SIZE-1:0]       wid;
   output reg  [DATA_WIDTH-1:0]    wdata;
   output reg  [STRB_SIZE-1:0]     wstrb;
   output reg                      wlast;
   output reg                      wvalid;
   input                           wready;
    //----------------------( B )--------------------
   input   [ID_SIZE-1:0]        bid;
   input   [1:0]              	bresp;
   input                        bvalid;
   output reg                   bready;
    //----------------------( AR )----------------
    output reg  [ID_SIZE-1:0]      arid;
    output reg  [ADDR_WIDTH-1:0]   araddr;
    output reg  [7:0]              arburst_length;
    output reg  [3:0]              arburst_size;
    output reg  [1:0]              arburst_type;
    output reg                     arvalid;
    input                          arready;
    //--------------------------( R )---------------
   input   [ID_SIZE-1:0]     	    rid;
   input  [DATA_WIDTH-1:0]       	rdata;
   input                            rlast;
   input   [1:0]                    rresp;
   input                            rvalid;
   output reg                       rready;

 always @(posedge aclk) begin
        if (arst) begin
            awid           <= 0;
            awaddr         <= 32'h00000000;
            awburst_length <= 0;
            awburst_size   <= 0;
            awburst_type   <= 0;
            awvalid        <= 0;
            wid            <= 0;
            wdata          <= 0;
            wstrb          <= 0;
            wlast          <= 0;
            wvalid         <= 0;
            bready         <= 0;
            arid           <= 0;
            araddr         <= 0;
            arburst_length <= 0;
            arburst_size   <= 0;
            arburst_type   <= 0;
            arvalid        <= 0;
            rready         <= 0;
        end
  else begin

        //================ WRITE ADDRESS CHANNEL ================//
   if (!awvalid) begin
     for(i=0;i<=BURST_LENGTH;i++)begin
		awid							<= 1'b1;
		awburst_length					<= BURST_LENGTH;	
		awburst_size					<= BURST_SIZE; 
		awburst_type					<= INCR;
		if(awburst_type==FIXED) awaddr 	<= 32'h10;
		if(awburst_type==INCR)	awaddr	<= 32'h10+i;        
		awvalid		                    <= 1'b1;
		wait(awready == 1'b1);
    end
  end
else if (awvalid && awready) begin
    awvalid        <= 1'b0;
end
    if(!wvalid)begin
      for(j=0;j<=BURST_LENGTH;j++)begin
		wid			<= awid;
		wdata		<= j*2+1;
		wstrb		<= 2'b11;
		wlast		<= (j==BURST_LENGTH)? 1'b1 : 1'b0;
		wvalid		<= 1'b1;
		wait(wready == 1'b1);
     end
   end
   else if(wvalid && wready)begin
      wvalid<=1'b0;
   end
    if(!bvalid)begin
       bready <= 1'b1;
       bready <= 1'b0;
    end       
    if(!arvalid)begin
      for(k=0;k<=BURST_LENGTH;k++)begin
		arid							<= awid;
		arburst_length					<= BURST_LENGTH;
		arburst_size					<= BURST_SIZE;
		arburst_type					<= INCR;
		if(arburst_type== FIXED) araddr <= 32'h10;
		if(arburst_type== INCR)	 araddr <= 32'h10+k;
		arvalid		 <= 1'b1;
		wait(arready == 1'b1);
	 end
    end
   else if(arvalid && arready)begin
      arvalid<=1'b0;
  end
  if(!rvalid) begin
    for(k=0; k<=BURST_LENGTH; k++) begin
        rready <= 1'b1;
        wait(rvalid == 1'b1);
        if(rvalid && rready) begin
            rready <= 1'b0;
        end
    end
end
  end
    end
endmodule

