// Active Monitor //

class axi4_active_monitor extends uvm_monitor;
        uvm_component_utils(axi4_active_monitor)
        virtual axi_interface vif;
        uvm_analysis_port#(axi4_seq_item) a_mon_port;
        axi4_seq_item in_item;

        function new(string name = "axi4_active_monitor",  uvm_component parent = null);
                super.new(name, parent);
        endfunction
  
        function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                a_mon_port = new("a_mon_port", this);
                if( !(uvm_config_db#(virtual axi_interface)::get(this, "", "vif", vif) )
                        `uvm_fatal("ACTIVE_MONITOR", "NO VIRTUAL INTERFACE IN ACTIVE MONITOR")
        endfunction

        task run_phase(uvm_phase phase);
                repeat(3)@(vif.mon_cb);
                forever begin
                        in_item = axi4_seq_item::type_id::create("in_item");

                        repeat()@(vif.mon_cb);
                end
        endtask


endclass
