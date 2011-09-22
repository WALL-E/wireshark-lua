-- 自定义协议，把每个TCP流的数据导出为文件
-- table性能需要调整

custom_port = 5005
root_dir = "E:\\output\\"

do
	tb_list = {}
    local function init_listener()
        local tap = Listener.new("ip")
        function tap.reset()
			tb_list = {}
        end
        function tap.draw()
			for k, v in pairs(tb_list) do
				--print(table.concat(v,""))
				out = assert(io.open(k, "a"))
				out:write(table.concat(v,""))
				out:flush()
				out:close()
			end
        end
    end
    init_listener()
end

-- dissector函数   
Customer_protocol = Proto("Customer","Customer Protocol","Customer Protocol") 
function Customer_protocol.dissector(buffer,pinfo,tree)
	outfile = root_dir .. tostring(pinfo.dst).. "_" 
	outfile = outfile .. tostring(pinfo.dst_port).. "_"
	outfile = outfile .. tostring(pinfo.src).. "_" 
	outfile = outfile .. tostring(pinfo.src_port)
	
	pinfo.cols.protocol = "Customer"
    pinfo.cols.info = "Customer data"
    local subtree = tree:add(Customer_protocol,buffer(),"Customer Protocol")
	subtree:add(buffer(0,buffer:len()),"Customer data")
	
	if gui_enabled() then
		return
	end
	
	local len = buffer:len()
	if tb_list[outfile] == nil then
		tb_list[outfile] = {}
	end
	
	for i=0,len do
		table.insert(tb_list[outfile], tostring(buffer(i,1)))
	end
end

 
tcp_table = DissectorTable.get("tcp.port")  
tcp_table:add(5005,Customer_protocol)