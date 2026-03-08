module axi4_assertions(

        input logic ACLK,ARESETn,

        input logic [31:0]AWADDR,

        input logic AWVALID,AWREADY,

        input logic [31:0]WDATA,

        input logic WVALID,WREADY,

        input logic[1:0]BRESP,

        input logic BVALID,BREADY,

        input logic [31:0]ARADDR,

        input logic ARVALID,ARREADY,

        input logic [31:0]RDATA,

        input logic RVALID,RREADY

);

        property p1;
                @(posedge ACLK) disable iff(!ARESETn)
                $rose(AWVALID) |=> ($stable(AWADDR) && $stable(AWVALID)) until_with (AWREADY);
        endproperty

        property p2;
                @(posedge ACLK) disable iff(!ARESETn)
                $rose(WVALID) |=> ($stable(WDATA) && $stable(WVALID)) until_with (WREADY);
        endproperty

        property p3;
                @(posedge ACLK) disable iff(!ARESETn)
                $rose(BVALID) |=> ($stable(BRESP) && $stable(BVALID)) until_with (BREADY);
        endproperty

        property p4;
                @(posedge ACLK) disable iff(!ARESETn)
                $rose(ARVALID) |=> ($stable(ARADDR) && $stable(ARVALID)) until_with (ARREADY);
        endproperty

        property p5;
                @(posedge ACLK) disable iff(!ARESETn)
                $rose(RVALID) |=> ($stable(RDATA) && $stable(RVALID)) until_with (RREADY);
        endproperty

        write_address_handshake:assert property(p1)
                                $info("p1-write address handshake assertion passed ADDR=%0h  AWVALID=%0h   AWREADY=%0h ",AWADDR, AWVALID, AWREADY);
        else
                $info("p1-write address handshake assertion failed ADDR=%0h  AWVALID=%0h  AWREADY=%0h ",AWADDR, AWVALID, AWREADY);

        write_data_handshake:assert property(p2)
        $info("p2-write data handshake assertion passed WVALID=%0h WREADY=%0h WDATA=%0h",WVALID,WREADY,WDATA);
        else
                $info("p2-write data handshake assertion failed WVALID=%0h WREADY=%0h WDATA=%0h",WVALID,WREADY,WDATA);

        write_response_handshake:assert property(p3)
        $info("p3-write response handshake assertion passed BVALID=%0h BREADY=%0h BRESP=%0h",BVALID,BREADY,BRESP);
        else
                $info("p3-write response handshake assertion failed BVALID = %0h BREADY = %0h BRESP=%0h",BVALID,BREADY,BRESP);

        read_data_handshake:assert property(p4)
        $info("p4-read data handshake assertion passed ARVALID =%0h ARADDR =%0h ARREADY=%0h",ARVALID,ARADDR,ARREADY);
        else
                $info("p4-read data handshake assertion failed ARVALID=%0h ARADDR=%0h  ARREADY=%0h",ARVALID,ARADDR,ARREADY);

        read_response_handshake:assert property(p5)
        $info("p5-read response handshake assertion passed RVALID=%0h RREADY=%0h RDATA=%0h",RVALID,RREADY,RDATA);
        else
                $info("p5-read response handshake assertion failed RVALID = %0h RREADY =%0h RDATA=%0h",RVALID,RREADY,RDATA);

endmodule
 
