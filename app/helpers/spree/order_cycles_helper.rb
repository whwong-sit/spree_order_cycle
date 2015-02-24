module Spree
    module OrderCyclesHelper
        ##
        #  Constructs a <tr> of a pickup_table
        def construct_html_table_line(user, line_items, item_name_to_idx)

            # debug [user, line_items.length, item_name_to_idx.keys]

            #consolidate  line_items for user. 
            # only item.name & item.qty is required
            lis = line_items.map {|x| {:name => x.name, :qty => x.quantity}}
            item_name_to_qty = lis.group_by { |x| x[:name] } .map {|k,v| [k, v.sum {|x| x[:qty]}]}.to_h

            idxs = item_name_to_qty.keys.map { |x| item_name_to_idx[x] }
            idxs.sort!

            idx_to_item_name = item_name_to_idx.map { |k,v| [v,k] }.to_h


            blankies = []
            idxs.each_with_index { |x, idx| blankies <<  x - (idx > 0 ? idxs[idx-1] + 1: 0)   }

            item_qtys = idxs.map do |x| 
                name = idx_to_item_name[x]
                qty = item_name_to_qty[name]
                qty
            end

            # useful for debug
            # [item_qtys]
            #[item_qtys, item_name_to_qty.to_a, idx_to_item_name.to_a]
            #[idxs, blankies]
            row_str = ['<tr class="line-item">',"<td> #{user} </td>"]
            blankies.each do |x|
                row_str << "<td/>" * x
                row_str << "<td> #{item_qtys.shift} </td>"
            end

            line_length = item_name_to_idx.length  #total number of columns
            row_str << "<td/>" * (line_length - idxs.last - 1) #the remaining empty cells
            row_str << "</tr>"

            row_str.join
        end
    end
end
