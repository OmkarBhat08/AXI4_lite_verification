program axi4_assertions(ACLK,ARESETn,bit [31:0]AWADDR,AWVALID,AWREADY,bit [31:0]WDATA,WVALID,WREADY,BRESP,BVALID,BREADY,bit [31:0]ARADDR,ARVALID,ARREADY,bit [31:0]RDATA,RVALID,RREADY);
        input ACLK,RESETn;
        input bit [31:0]AWADDR;
        input AWVALID,AWREADY;
        input bit [31:0]WDATA,
        input WVALID,WREADY;
        input BRESP,BVALID,BREADY;
        input bit [31:0]ARADDR,
        input ARVALID,ARREADY;
        input bit [31:0]RDATA,
        input RVALID,RREADY;

        property p1;
                @(posedge ACLK) disable iff(!ARESETn)
                $rose(AWVALID) |-> ($stable(AWADDR) && AWVALID) until_with (AWREADY);
        endproperty

        property p2;
                @(posedge ACLK) disable iff(!ARESETn)
                $rose(WVALID) |-> ($stable(WDATA) && WVALID) until_with (WREADY);
        endproperty

        property p3;
                @(posedge ACLK) disable iff(!ARESETn)
                $rose(BVALID) |-> ($stable(BRESP) && BVALID) until_with (BREADY);
        endproperty

        property p4;
                @(posedge ACLK) disable iff(!ARESETn)
                $rose(ARVALID) |-> ($stable(ARADDR) && ARVALID) until_with (ARREADY);
        endproperty

        property p5;
                @(posedge ACLK) disable iff(!ARESETn)
                $rose(RVALID) |-> ($stable(RDATA) && RVALID) until_with (RREADY);
        endproperty

        write_address_handshake:assert property(p1)
        $info("write address handshake assertion passed");
        else
                $info("write address handshake assertion failed");

        write_data_handshake:assert property(p2)
        $info("write data handshake assertion passed");
        else
                $info("write data handshake assertion failed");

        read_address_handshake:assert property(p3)
        $info("read address handshake assertion passed");
        else
                $info("read address handshake assertion failed");

        read_data_handshake:assert property(p4)
        $info("read data handshake assertion passed");
        else
                $info("read data handshake assertion failed");

        read_response_handshake:assert property(p5)
        $info("read response handshake assertion passed");
        else
                $info("read response handshake assertion failed");
        read_data_handshake:assert property(p4)
	      $info("read data handshake assertion passed");
	      else
		         $info("read data handshake assertion failed");

endprogram
