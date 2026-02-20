// Passive Agent

class axi4_passive_agent extends uvm_agent;
    `uvm_component_utils(axi4_passive_agent)
    axi4_passive_monitor p_mon_h;

//---------------------------------new constructor--------------------------------//
    function new(string name = "axi4_passive_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

//--------------------------------build phase-----------------------------------//
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        p_mon_h = axi4_passive_monitor::type_id::create("p_mon_h", this);
    endfunction

endclass

